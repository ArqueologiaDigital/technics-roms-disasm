
; ---------------------------------------------------------------------
; Data_F82000 -- four LE32 words, every one 0x00000080
;
; Read by: 0xF8202C `ld XWA,0x00F82000 / push XWA / push 0x0001 / call 0xF42DC8`.
; Unknown:  everything else.  Four equal words are not a table this tree can
;          frame from one call site, and 0x80 is not identified.  Declared as
;          data only because a linear decode prints `db` on all four.
; Evidence: the four words, read out of the ROM by notes/prom_a_boot_checks.py.
; ---------------------------------------------------------------------
Data_F82000:
	.long 0x00000080                                 ; F82000  [  0]
	.long 0x00000080                                 ; F82004  [  1]
	.long 0x00000080                                 ; F82008  [  2]
	.long 0x00000080                                 ; F8200C  [  3]
; MainTask_PhaseVector: the boot phase vector of module 0 (MainTask_Loop's block) -- ModuleInitDirectory_F82641 reaches it; the walker calls slot k (4 bytes)
;   for boot phase k (notes/prom_a_module_boot_phase_names.py).  2026-10-04.
MainTask_PhaseVector:
	jp Ring_InitAllFourteen                                        ; F82010  1b d4 25 f8
	jp MainTask_PhaseVector_Ret                                        ; F82014  1b 2f 26 f8
	jp Var7FC1_Clear                                        ; F82018  1b 28 26 f8
	jp MainTask_PhaseVector_Ret                                        ; F8201C  1b 2f 26 f8
	jp MainTask_PhaseVector_Ret                                        ; F82020  1b 2f 26 f8
	jp MainTask_PhaseVector_Ret                                        ; F82024  1b 2f 26 f8
; MainTask_Loop -- CPU 1's main loop: poll the rota flags and rings for ever
; Evidence: ends with unconditional `jrl MainTask_Loop` (0xF821C5); entered by `jp` from MainTask_Entry (0xF8282E) and published as prom_b slot T_F40014.  `tset n,(0x88)` / `tset n,(0x98)` gate PanelHold_Tick, SC1_TxFlush, Link_ServiceTask, Blink_Tick (bit 7 at 0xF82182, FINDINGS-prom_b-field-blink.md) etc.; it services the MIDI-in rings (MidiIn_RoutePortA/B), MIDI_DrainQueue, PanelWire_Service, PanelEvent_Service, UiEventList_Publish.
; The four instructions at 0xF8202C-0xF8203A are jumped over by the `jr` at 0xF8202A.
MainTask_Loop:
	ei 0x00                                              ; F82028  06 00
	jr .LF8203B                                          ; F8202A  68 0f
	ld XWA,Data_F82000                                   ; F8202C  40 00 20 f8 00
	push XWA                                             ; F82031  38
	pushw 0x01                                           ; F82032  0b 01 00
	call T_MsgQueue_Send_StackArg                                        ; F82035  1d c8 2d f4
	inc 6,XSP                                            ; F82039  ef 66
.LF8203B:
	call T_PanelLed_FlashTransportBeat                                        ; F8203B  1d 74 06 f4
	tset	0, (0x98:8)                                  ; F8203F  f0 98 a8
	jr nz, .LF82050                                      ; F82042  6e 0c
	call T_AnalogScan_All                                ; F82044  1d 34 1b f4
	call T_SC1_Service                                   ; F82048  1d 04 0f f4
	call T_PanelWire_Service                                        ; F8204C  1d 14 06 f4
.LF82050:
	cp	(MainTask_TickCountdown:8), 0x00                               ; F82050  c0 c2 3f 00
	jr nz, .LF82059                                      ; F82054  6e 03
	calr MainTask_RearmTickCountdown                                      ; F82056  1e 6f 01
.LF82059:
	ei 0x06                                              ; F82059  06 06
	ld	a, (MIDI_RX_Flags:8)                                      ; F8205B  c0 9e 21
	and A,0x2c                                           ; F8205E  c9 cc 2c
	jr z, .LF82075                                       ; F82061  66 12
	call T_MidiInARing_Init                               ; F82063  1d b8 1d f4
	and	(MIDI_RX_Flags:8), 0xd3                               ; F82067  c0 9e 3c d3
	ei 0x00                                              ; F8206B  06 00
	call T_PartNotes_ReleaseAllReceivedMidiIn                                        ; F8206D  1d c0 13 f4
	call T_F40894                                        ; F82071  1d 94 08 f4
.LF82075:
	ei 0x00                                              ; F82075  06 00
	call T_SysExRx_PollRing601646                                        ; F82077  1d e8 08 f4
	cp	(0x89:8), 0xff                               ; F8207B  c0 89 3f ff
	jr z, .LF8208C                                       ; F8207F  66 0b
	call T_MidiInARing_IsEmpty                            ; F82081  1d b4 1d f4
	and WA,WA                                            ; F82085  d8 c0
	jr z, .LF8208C                                       ; F82087  66 03
	calr MidiIn_RoutePortA                                      ; F82089  1e 78 01
.LF8208C:
	call T_MidiInBRing_IsEmpty                            ; F8208C  1d d8 1d f4
	and WA,WA                                            ; F82090  d8 c0
	jr z, .LF82097                                       ; F82092  66 03
	calr MidiIn_RoutePortB                                      ; F82094  1e 3d 02
.LF82097:
	tset	0, (0x88:8)                                  ; F82097  f0 88 a8
	jr nz, .LF820A0                                      ; F8209A  6e 04
	call T_PanelHold_Tick                                ; F8209C  1d 74 0f f4
.LF820A0:
	tset	1, (0x88:8)                                  ; F820A0  f0 88 a9
	jr nz, .LF820A9                                      ; F820A3  6e 04
	call T_PanelLed_Refresh                                        ; F820A5  1d 68 06 f4
.LF820A9:
	ei 0x00                                              ; F820A9  06 00
	tset	2, (0x88:8)                                  ; F820AB  f0 88 aa
	jr nz, .LF820B0                                      ; F820AE  6e 00
.LF820B0:
	tset	3, (0x88:8)                                  ; F820B0  f0 88 ab
	jr nz, .LF820B9                                      ; F820B3  6e 04
	call T_SysExThirdRegion_FetchNextChunk                                        ; F820B5  1d 50 12 f4
.LF820B9:
	calr MainTask_ServiceTimedEvents                                      ; F820B9  1e e8 02
	calr TimedEvents_Service                                      ; F820BC  1e 23 03
	call T_Ring60195A_IsEmpty                            ; F820BF  1d 24 1d f4
	and WA,WA                                            ; F820C3  d8 c0
	jr z, .LF820CB                                       ; F820C5  66 04
	call T_MIDI_DrainQueue                               ; F820C7  1d 28 07 f4
.LF820CB:
	call T_Ring601C6E_IsEmpty                            ; F820CB  1d b0 1e f4
	and WA,WA                                            ; F820CF  d8 c0
	jr z, .LF820D7                                       ; F820D1  66 04
	call T_SysExRx_PollRing601C6E                                        ; F820D3  1d 04 09 f4
.LF820D7:
	call T_Ring60000C_IsEmpty                            ; F820D7  1d 8c 1e f4
	and WA,WA                                            ; F820DB  d8 c0
	jr z, .LF820E3                                       ; F820DD  66 04
	call T_Cpu2Query_DrainRecordReplies                                        ; F820DF  1d 3c 10 f4
.LF820E3:
	call T_Ring601850_IsEmpty                            ; F820E3  1d 68 1e f4
	and WA,WA                                            ; F820E7  d8 c0
	jr z, .LF820EF                                       ; F820E9  66 04
	call T_F413B8                                        ; F820EB  1d b8 13 f4
.LF820EF:
	ei 0x00                                              ; F820EF  06 00
	call T_PanelEvent_Service                                        ; F820F1  1d 34 06 f4
	cp	(0x2e00:16), 0xff                            ; F820F5  c1 00 2e 3f ff
	jr z, .LF82100                                       ; F820FA  66 04
	call T_UiEventList_Publish                           ; F820FC  1d 50 0f f4
.LF82100:
	cp	(UI_ScreenFlags:16), 0x00                            ; F82100  c1 95 20 3f 00
	jr nz, .LF8210E                                      ; F82105  6e 07
	cp	(UI_Request_Hi:16), 0x00                            ; F82107  c1 71 20 3f 00
	jr z, .LF82120                                       ; F8210C  66 12
.LF8210E:
	call T_PanelTask_Step                                ; F8210E  1d 34 0f f4
	ld a, (UI_ScreenLatch:16)                                   ; F82112  c1 7a 20 21
	cp	a, (UI_ScreenLatch_Previous:16)                               ; F82116  c1 7b 20 f1
	jr z, .LF82120                                       ; F8211A  66 04
	call T_NoteRouting_Rebuild                                        ; F8211C  1d bc 11 f4
.LF82120:
	call MainTask_RunUiPassC                                      ; F82120  1d d7 21 f8
	calr MainTask_ServiceTimedEvents                                      ; F82124  1e 7d 02
	calr TimedEvents_Service                                      ; F82127  1e b8 02
	call T_Ring601850_IsEmpty                            ; F8212A  1d 68 1e f4
	and WA,WA                                            ; F8212E  d8 c0
	jr z, .LF82136                                       ; F82130  66 04
	call T_F413B8                                        ; F82132  1d b8 13 f4
.LF82136:
	call T_Ring608A0A_IsEmpty                            ; F82136  1d dc 1c f4
	and WA,WA                                            ; F8213A  d8 c0
	jr z, .LF82142                                       ; F8213C  66 04
	call T_Ring608A0A_DrainAll                           ; F8213E  1d 80 23 f4
.LF82142:
	tset	6, (0x98:8)                                  ; F82142  f0 98 ae
	jr nz, .LF8214B                                      ; F82145  6e 04
	call MainTask_PanelTimersTick                                      ; F82147  1d e9 21 f8
.LF8214B:
	tset	4, (0x88:8)                                  ; F8214B  f0 88 ac
	jr nz, .LF82160                                      ; F8214E  6e 10
	call T_StepRecord_Tick                                        ; F82150  1d dc 2e f4
	call T_PanelLed_ProcessRequests                                        ; F82154  1d 64 06 f4
	call T_SC1_TxFlush                                   ; F82158  1d 08 0f f4
	call T_TestMode_Tick                                        ; F8215C  1d 4c 01 f4
.LF82160:
	tset	5, (0x88:8)                                  ; F82160  f0 88 ad
	jr nz, .LF82175                                      ; F82163  6e 10
	call T_Link_ServiceTask                              ; F82165  1d d8 0e f4
	call T_EditScreen_Tick_Call                                        ; F82169  1d 08 03 f4
	call T_Medley_Tick                                        ; F8216D  1d 20 30 f4
	call T_Disk_TickCountdowns                                        ; F82171  1d c4 25 f4
.LF82175:
	tset	6, (0x88:8)                                  ; F82175  f0 88 ae
	jr nz, .LF82182                                      ; F82178  6e 08
	call T_PanelLed_ProcessRequests                                        ; F8217A  1d 64 06 f4
	call T_SC1_TxFlush                                   ; F8217E  1d 08 0f f4
.LF82182:
	tset	7, (0x88:8)                                  ; F82182  f0 88 af
	jr nz, .LF8218F                                      ; F82185  6e 08
	call T_MidiOut_RunPeriodicTimeouts                                        ; F82187  1d 5c 07 f4
	call T_Blink_Tick                                    ; F8218B  1d 2c 2e f4
.LF8218F:
	ei 0x00                                              ; F8218F  06 00
	ld XIY,0x000034d0                                    ; F82191  45 d0 34 00 00
	bit 1,(XIY)                                          ; F82196  b5 c9
	jr z, .LF821A5                                       ; F82198  66 0b
	and (XIY),0xfd                                       ; F8219A  85 3c fd
	call T_PartNotes_ReleaseAllTrackNotes                                        ; F8219D  1d c8 13 f4
	call T_F41F18                                        ; F821A1  1d 18 1f f4
.LF821A5:
	bit	7, (MidiIn_SongSelectValue:8)                                   ; F821A5  f0 a3 cf
	jr z, .LF821AE                                       ; F821A8  66 04
	call T_MidiFilePlay_OnSongSelect                                        ; F821AA  1d 84 25 f4
.LF821AE:
	calr MainTask_RearmTickCountdown                                      ; F821AE  1e 17 00
	calr MainTask_ServiceTimedEvents                                      ; F821B1  1e f0 01
	xor A,A                                              ; F821B4  c9 d1
	ld	(0xc1:8), a                                      ; F821B6  f0 c1 41
	call T_Seq_MainLoopService                                        ; F821B9  1d c8 09 f4
	call T_StepRecord_MainLoopService                                        ; F821BD  1d d0 2e f4
	call T_MidiFilePlay_Tick                                        ; F821C1  1d 50 09 f4
	jrl MainTask_Loop                                       ; F821C5  78 60 fe
; MainTask_RearmTickCountdown -- (0xC1)=0, call T_F409C4, then reload the tick countdown (0xC2) with 10
; Evidence: `xor A / ld (0xC1),A / call T_F409C4 / ld A,0x0A / ld (0xC2),A`; INTTR4_SequencerTick decrements (0xC2) once per tick (0xF83024); MainTask_Loop calls this when (0xC2) is 0 (0xF82050) and unconditionally at the end of each pass (0xF821AE).
; T_F409C4 -> T_F40B44 -> prom_b sub_F47800 is unnamed.
MainTask_RearmTickCountdown:
	xor A,A                                              ; F821C8  c9 d1
	ld	(0xc1:8), a                                      ; F821CA  f0 c1 41
	call T_F409C4                                        ; F821CD  1d c4 09 f4
	ld a, 0x0a:opc                                          ; F821D1  21 0a
	ld	(MainTask_TickCountdown:8), a                                      ; F821D3  f0 c2 41
	ret                                                  ; F821D6  0e
; MainTask_RunUiPassC -- run UI event pass C, then empty the 0x2030 event list and the 0x2C00 queue
; Evidence: call T_UiEventList_RunPassC, call T_List2030_ProcessEvents (unnamed), ld (0x2030),0xFF (the list PanelGroupQueue_ExpandToEvents fills), call Queue2C00_DrainPassAB; one caller, MainTask_Loop 0xF82120.
MainTask_RunUiPassC:
	call T_UiEventList_RunPassC                          ; F821D7  1d 64 0f f4
	call T_List2030_ProcessEvents                                        ; F821DB  1d 80 07 f4
	ld (0x2030:16), 0xff                                 ; F821DF  f1 30 20 00 ff
	call Queue2C00_DrainPassAB                                      ; F821E4  1d ac 23 f8
	ret                                                  ; F821E8  0e
; MainTask_PanelTimersTick -- one tick of the panel timers
; Evidence: call T_F413CC (unnamed), T_PanelTimers_Step, T_PanelHold_Tick; called from MainTask_Loop when `tset 6,(0x98)` finds bit 6 clear (0xF82142).  The 4 instructions after its `ret` (0xF821F6) are not reached from here.
MainTask_PanelTimersTick:
	call T_F413CC                                        ; F821E9  1d cc 13 f4
	call T_PanelTimers_Step                              ; F821ED  1d 44 0f f4
	call T_PanelHold_Tick                                ; F821F1  1d 74 0f f4
	ret                                                  ; F821F5  0e
	call T_PartNotes_ReleaseAllTrackNotes                                        ; F821F6  1d c8 13 f4
	call T_F41F18                                        ; F821FA  1d 18 1f f4
	and	(0x34d0:16), 0xfd                            ; F821FE  c1 d0 34 3c fd
	ret                                                  ; F82203  0e
; MidiIn_RoutePortA -- split pending MIDI IN port A bytes into a run of note-class messages or a run of other messages, and hand the run to its consumer
; Evidence: ring 0x600C1E (MidiIn_PumpPortA's), scanned from (ring-8) to (ring-4) mod 0x400.  Note class = status 0x8n, 0x9n, or 0xBn whose next byte is >=0x7B (cp 0x7B at 0xF8224A/0xF82280).  At the first class change it stores the position in (ring-6) and calls T_MidiInA_ProcessRing (prom_a MidiInA_ProcessRing) for a note run, or MidiIn_PumpPortA + T_F41F14 + Queue2C00_DrainPassAB otherwise; then (ring-8)=(ring-6) and (ring-2) += bytes consumed.
; Called from MainTask_Loop 0xF82089 when (0x89)!=0xFF and the ring is not empty.
MidiIn_RoutePortA:
	ld XHL,MidiIn_PortARing                                    ; F82204  43 1e 0c 60 00
	ld iy, (xhl-8)                                       ; F82209  9b f8 25
	ld ix, (xhl-4)                                       ; F8220C  9b fc 24
	xor BC,BC                                            ; F8220F  d9 d1
	ld IZ,BC                                             ; F82211  d9 8e
.LF82213:
	bit	7, (xhl+iy)                          ; F82213  f3 07 ec f4 cf
	jr nz, .LF82227                                      ; F82218  6e 0d
	inc 1,IZ                                             ; F8221A  de 61
	minc1_16 iy, 0x03ff                                  ; F8221C  dd 38 ff 03
	cp IY,IX                                             ; F82220  dc f5
	jrl z, .LF822A6                                      ; F82222  76 81 00
	jr .LF82213                                          ; F82225  68 ec
.LF82227:
	ld	c, (xhl+iy)                                  ; F82227  c3 07 ec f4 23
	and C,0xf0                                           ; F8222C  cb cc f0
	cp C,0x90                                            ; F8222F  cb cf 90
	jr z, .LF82252                                       ; F82232  66 1e
	cp C,0x80                                            ; F82234  cb cf 80
	jr z, .LF82252                                       ; F82237  66 19
	cp C,0xb0                                            ; F82239  cb cf b0
	jr nz, .LF82254                                      ; F8223C  6e 16
	ld DE,IY                                             ; F8223E  dd 8a
	inc 1,IZ                                             ; F82240  de 61
	minc1_16 iy, 0x03ff                                  ; F82242  dd 38 ff 03
	cp IY,IX                                             ; F82246  dc f5
	jr z, .LF822A6                                       ; F82248  66 5c
	cp	(xhl+iy), 0x7b                       ; F8224A  c3 07 ec f4 3f 7b
	jr c, .LF82254                                       ; F82250  67 02
.LF82252:
	ld b, 0x01:opc                                          ; F82252  22 01
.LF82254:
	bit	7, (xhl+iy)                          ; F82254  f3 07 ec f4 cf
	jr z, .LF8229C                                       ; F82259  66 41
	ld	a, (xhl+iy)                                  ; F8225B  c3 07 ec f4 21
	and A,0xf0                                           ; F82260  c9 cc f0
	cp A,0x90                                            ; F82263  c9 cf 90
	jr z, .LF8228C                                       ; F82266  66 24
	cp A,0x80                                            ; F82268  c9 cf 80
	jr z, .LF8228C                                       ; F8226B  66 1f
	cp A,0xb0                                            ; F8226D  c9 cf b0
	jr nz, .LF82291                                      ; F82270  6e 1f
	ld DE,IY                                             ; F82272  dd 8a
	ld WA,IZ                                             ; F82274  de 88
	inc 1,IZ                                             ; F82276  de 61
	minc1_16 iy, 0x03ff                                  ; F82278  dd 38 ff 03
	cp IY,IX                                             ; F8227C  dc f5
	jr z, .LF822A6                                       ; F8227E  66 26
	cp	(xhl+iy), 0x7b                       ; F82280  c3 07 ec f4 3f 7b
	ld IZ,WA                                             ; F82286  d8 8e
	ld IY,DE                                             ; F82288  da 8d
	jr c, .LF82291                                       ; F8228A  67 05
.LF8228C:
	or B,0x02                                            ; F8228C  ca ce 02
	jr .LF82294                                          ; F8228F  68 03
.LF82291:
	and B,0xfd                                           ; F82291  ca cc fd
.LF82294:
	cp b, 0x01:i3                                          ; F82294  ca d9
	jr z, .LF822AB                                       ; F82296  66 13
	cp b, 0x02:i3                                          ; F82298  ca da
	jr z, .LF822B5                                       ; F8229A  66 19
.LF8229C:
	inc 1,IZ                                             ; F8229C  de 61
	minc1_16 iy, 0x03ff                                  ; F8229E  dd 38 ff 03
	cp IY,IX                                             ; F822A2  dc f5
	jr nz, .LF82254                                      ; F822A4  6e ae
.LF822A6:
	bit 0x00,B                                           ; F822A6  ca 33 00
	jr z, .LF822B5                                       ; F822A9  66 0a
.LF822AB:
	pushw iz                                             ; F822AB  2e
	ld (xhl-6), iy                                       ; F822AC  bb fa 55
	call T_MidiInA_ProcessRing                                        ; F822AF  1d b4 13 f4
	jr .LF822C4                                          ; F822B3  68 0f
.LF822B5:
	pushw iz                                             ; F822B5  2e
	ld (xhl-6), iy                                       ; F822B6  bb fa 55
	call T_MidiIn_PumpPortA                              ; F822B9  1d 44 07 f4
	call T_F41F14                                        ; F822BD  1d 14 1f f4
	calr Queue2C00_DrainPassAB                                      ; F822C1  1e e8 00
.LF822C4:
	ld XHL,MidiIn_PortARing                                    ; F822C4  43 1e 0c 60 00
	ld wa, (xhl-6)                                       ; F822C9  9b fa 20
	ld (xhl-8), wa                                       ; F822CC  bb f8 50
	popw wa                                              ; F822CF  48
	add (xhl-2), wa                                      ; F822D0  9b fe 88
	ret                                                  ; F822D3  0e
; MidiIn_RoutePortB -- MidiIn_RoutePortA for MIDI IN port B
; Evidence: the same code on ring 0x601028; the note run goes to T_MidiInB_ProcessRing (prom_a MidiInB_ProcessRing), the rest to T_MidiIn_PumpPortB + T_F41F14 + Queue2C00_DrainPassAB (0xF8237F-0xF82391).  Called from MainTask_Loop 0xF82094.
MidiIn_RoutePortB:
	ld XHL,MidiIn_PortBRing                                    ; F822D4  43 28 10 60 00
	ld iy, (xhl-8)                                       ; F822D9  9b f8 25
	ld ix, (xhl-4)                                       ; F822DC  9b fc 24
	xor BC,BC                                            ; F822DF  d9 d1
	ld IZ,BC                                             ; F822E1  d9 8e
.LF822E3:
	bit	7, (xhl+iy)                          ; F822E3  f3 07 ec f4 cf
	jr nz, .LF822F7                                      ; F822E8  6e 0d
	inc 1,IZ                                             ; F822EA  de 61
	minc1_16 iy, 0x03ff                                  ; F822EC  dd 38 ff 03
	cp IY,IX                                             ; F822F0  dc f5
	jrl z, .LF82376                                      ; F822F2  76 81 00
	jr .LF822E3                                          ; F822F5  68 ec
.LF822F7:
	ld	c, (xhl+iy)                                  ; F822F7  c3 07 ec f4 23
	and C,0xf0                                           ; F822FC  cb cc f0
	cp C,0x90                                            ; F822FF  cb cf 90
	jr z, .LF82322                                       ; F82302  66 1e
	cp C,0x80                                            ; F82304  cb cf 80
	jr z, .LF82322                                       ; F82307  66 19
	cp C,0xb0                                            ; F82309  cb cf b0
	jr nz, .LF82324                                      ; F8230C  6e 16
	ld DE,IY                                             ; F8230E  dd 8a
	inc 1,IZ                                             ; F82310  de 61
	minc1_16 iy, 0x03ff                                  ; F82312  dd 38 ff 03
	cp IY,IX                                             ; F82316  dc f5
	jr z, .LF82376                                       ; F82318  66 5c
	cp	(xhl+iy), 0x7b                       ; F8231A  c3 07 ec f4 3f 7b
	jr c, .LF82324                                       ; F82320  67 02
.LF82322:
	ld b, 0x01:opc                                          ; F82322  22 01
.LF82324:
	bit	7, (xhl+iy)                          ; F82324  f3 07 ec f4 cf
	jr z, .LF8236C                                       ; F82329  66 41
	ld	a, (xhl+iy)                                  ; F8232B  c3 07 ec f4 21
	and A,0xf0                                           ; F82330  c9 cc f0
	cp A,0x90                                            ; F82333  c9 cf 90
	jr z, .LF8235C                                       ; F82336  66 24
	cp A,0x80                                            ; F82338  c9 cf 80
	jr z, .LF8235C                                       ; F8233B  66 1f
	cp A,0xb0                                            ; F8233D  c9 cf b0
	jr nz, .LF82361                                      ; F82340  6e 1f
	ld DE,IY                                             ; F82342  dd 8a
	ld WA,IZ                                             ; F82344  de 88
	inc 1,IZ                                             ; F82346  de 61
	minc1_16 iy, 0x03ff                                  ; F82348  dd 38 ff 03
	cp IY,IX                                             ; F8234C  dc f5
	jr z, .LF82376                                       ; F8234E  66 26
	cp	(xhl+iy), 0x7b                       ; F82350  c3 07 ec f4 3f 7b
	ld IZ,WA                                             ; F82356  d8 8e
	ld IY,DE                                             ; F82358  da 8d
	jr c, .LF82361                                       ; F8235A  67 05
.LF8235C:
	or B,0x02                                            ; F8235C  ca ce 02
	jr .LF82364                                          ; F8235F  68 03
.LF82361:
	and B,0xfd                                           ; F82361  ca cc fd
.LF82364:
	cp b, 0x01:i3                                          ; F82364  ca d9
	jr z, .LF8237B                                       ; F82366  66 13
	cp b, 0x02:i3                                          ; F82368  ca da
	jr z, .LF82385                                       ; F8236A  66 19
.LF8236C:
	inc 1,IZ                                             ; F8236C  de 61
	minc1_16 iy, 0x03ff                                  ; F8236E  dd 38 ff 03
	cp IY,IX                                             ; F82372  dc f5
	jr nz, .LF82324                                      ; F82374  6e ae
.LF82376:
	bit 0x00,B                                           ; F82376  ca 33 00
	jr z, .LF82385                                       ; F82379  66 0a
.LF8237B:
	pushw iz                                             ; F8237B  2e
	ld (xhl-6), iy                                       ; F8237C  bb fa 55
	call T_MidiInB_ProcessRing                                        ; F8237F  1d f8 13 f4
	jr .LF82394                                          ; F82383  68 0f
.LF82385:
	pushw iz                                             ; F82385  2e
	ld (xhl-6), iy                                       ; F82386  bb fa 55
	call T_MidiIn_PumpPortB                              ; F82389  1d 58 33 f4
	call T_F41F14                                        ; F8238D  1d 14 1f f4
	calr Queue2C00_DrainPassAB                                      ; F82391  1e 18 00
.LF82394:
	ld XHL,MidiIn_PortBRing                                    ; F82394  43 28 10 60 00
	ld wa, (xhl-6)                                       ; F82399  9b fa 20
	ld (xhl-8), wa                                       ; F8239C  bb f8 50
	popw wa                                              ; F8239F  48
	add (xhl-2), wa                                      ; F823A0  9b fe 88
	ret                                                  ; F823A3  0e
; MainTask_ServiceTimedEvents -- MainTask_Loop's call into TimedEvents_Service
; Evidence: `calr sub_F823AB` (a bare `ret`) then `calr TimedEvents_Service`; called three times per pass, 0xF820B9, 0xF82124, 0xF821B1.
MainTask_ServiceTimedEvents:
	calr MainTask_ServiceTimedEvents_Nop                                      ; F823A4  1e 04 00
	calr TimedEvents_Service                                      ; F823A7  1e 38 00
	ret                                                  ; F823AA  0e
MainTask_ServiceTimedEvents_Nop:
	ret                                                  ; F823AB  0e
; ---------------------------------------------------------------------
; Queue2C00_DrainPassAB -- run pass A and pass B over the 0x2C00 event
;                           queue, then empty it
;
; Called from: prom_b directory slot T_Queue2C00_DrainPassAB (T_F40018).
; Body:    return at once when (0x2C00) is already 0xFF (empty).
;          Otherwise `call 0xf40f5c` and `call 0xf40f60`, then write 0xFF
;          to 0x2C00 and zero the cursor (0x60F000).
; Evidence: `cp (0x2c00),0xff` at 0xF823AC; `call 0xf40f5c` at 0xF823B3 and
;          `call 0xf40f60` at 0xF823B7, and prom_b's directory says
;          T_UiEventList_RunPassA (T_F40F5C) is UiEventList_RunPassA (0xF8697E) and T_UiEventList_RunPassB (T_F40F60) is
;          UiEventList_RunPassB (0xF8699D) -- both already named, both
;          setting (0x20AD) to 0x2C00, i.e. running over THIS queue.
;          `ld (0x2c00),0xff` at 0xF823BB and `ld (0x60f000),0x0000` at
;          0xF823C0 are the emptying.
; ---------------------------------------------------------------------
Queue2C00_DrainPassAB:
	cp	(0x2c00:16), 0xff                            ; F823AC  c1 00 2c 3f ff
	jr z, .LF823C7                                       ; F823B1  66 14
	call T_UiEventList_RunPassA                          ; F823B3  1d 5c 0f f4
	call T_UiEventList_RunPassB                          ; F823B7  1d 60 0f f4
	ld (0x2c00:16), 0xff                                 ; F823BB  f1 00 2c 00 ff
	ldw (0x60f000:24), 0x00                             ; F823C0  f2 00 f0 60 02 00 00
.LF823C7:
	ret                                                  ; F823C7  0e
; ---------------------------------------------------------------------
; Queue2C00_DrainPassB -- the same, running pass B ONLY
;
; Called from: prom_b directory slot T_Queue2C00_DrainPassB (T_F40038).
; ★ BORROWED SHAPE, WITH THE DIFF: 0xF823AC and 0xF823C8 do the same four
;          things and 0xF823C8 omits ONE call.  They are 28 and 24 bytes;
;          the difference is the four bytes `1d 5c 0f f4` (`call 0xf40f5c`,
;          pass A) at 0xF823B3, and the remaining 24 bytes are identical
;          except for the two `jr` displacements that the missing four
;          bytes shift.  Check Y1 recomputes that.
; Evidence: `cp (0x2c00),0xff` at 0xF823C8, `call 0xf40f60` at 0xF823CF,
;          `ld (0x2c00),0xff` at 0xF823D3.
; ---------------------------------------------------------------------
Queue2C00_DrainPassB:
	cp	(0x2c00:16), 0xff                            ; F823C8  c1 00 2c 3f ff
	jr z, .LF823DF                                       ; F823CD  66 10
	call T_UiEventList_RunPassB                          ; F823CF  1d 60 0f f4
	ld (0x2c00:16), 0xff                                 ; F823D3  f1 00 2c 00 ff
	ldw (0x60f000:24), 0x00                             ; F823D8  f2 00 f0 60 02 00 00
.LF823DF:
	ret                                                  ; F823DF  0e
	ret                                                  ; F823E0  0e
	ret                                                  ; F823E1  0e
; TimedEvents_Service -- service the time-stamped event ring 0x60080A
; Evidence: (0x34D0) bit 5 set -> T_Seq_RewindOnMidiStart and T_MIDI_Clock_CatchUpIfAnySlot instead; otherwise (ring-4)!=(ring-8) -> TimedEvents_DrainDue, else res 6,(0x34D4).  Called from MainTask_ServiceTimedEvents and MainTask_Loop 0xF820BC/0xF82127.
; Ring 0x60080A (capacity 0x200, FINDINGS-prom_a-ring-buffers.md) is filled at 0xFEA57C/0xFEA585; why its bytes are time-stamped is TimedEvents_DispatchDueRun's evidence.
TimedEvents_Service:
	bit	5, (0x34d0:16)                               ; F823E2  f1 d0 34 cd
	jr z, .LF823F1                                       ; F823E6  66 09
	call T_Seq_RewindOnMidiStart                                        ; F823E8  1d e4 09 f4
	call T_MIDI_Clock_CatchUpIfAnySlot                                        ; F823EC  1d 20 07 f4
	ret                                                  ; F823F0  0e
.LF823F1:
	ld XIX,TimedEvents_Ring                                    ; F823F1  44 0a 08 60 00
	ld wa, (xix-4)                                       ; F823F6  9c fc 20
	cp	wa, (xix-8)                                  ; F823F9  9c f8 f0
	jr nz, .LF82403                                      ; F823FC  6e 05
	res	6, (0x34d4:16)                               ; F823FE  f1 d4 34 b6
	ret                                                  ; F82402  0e
.LF82403:
	calr TimedEvents_DrainDue                                      ; F82403  1e 01 00
	ret                                                  ; F82406  0e
; TimedEvents_DrainDue -- dispatch due runs of ring 0x60080A until it is empty or the head is not yet due
; Evidence: only when (0x34D4) bit 6 or (0x96) bit 2 is set; loop `ld WA,(XIX-4) / cp (XIX-8),WA / jr z` -> TimedEvents_DispatchDueRun -> `and IZ,IZ / jr nz`.  Also prom_b directory slot T_F4003C.
TimedEvents_DrainDue:
	ld XIX,TimedEvents_Ring                                    ; F82407  44 0a 08 60 00
	bit	6, (0x34d4:16)                               ; F8240C  f1 d4 34 ce
	jr nz, .LF82417                                      ; F82410  6e 05
	bit	2, (TransportB_State:8)                                   ; F82412  f0 96 ca
	jr z, .LF82426                                       ; F82415  66 0f
.LF82417:
	ld wa, (xix-4)                                       ; F82417  9c fc 20
	cp	wa, (xix-8)                                  ; F8241A  9c f8 f0
	jr z, .LF82426                                       ; F8241D  66 07
	calr TimedEvents_DispatchDueRun                                      ; F8241F  1e 05 00
	and IZ,IZ                                            ; F82422  de c6
	jr nz, .LF82417                                      ; F82424  6e f1
.LF82426:
	ret                                                  ; F82426  0e
; TimedEvents_DispatchDueRun -- take the next run of same-class, due events off ring 0x60080A and hand it to that class's consumer
; Evidence: finds the first status byte (bit 7), classifies it (TimedEvents_ClassifyStatus); unless (0x34D4) bit 6, a following byte <0x60 is a stamp compared with the tick (0x93) and a not-yet-due head returns IZ=0 (0xF8246C-0xF82481).  The run grows over same-class events until a class change or a not-yet-due stamp (TimedEvents_IsNotYetDue); (ring-6)=end, then class 1 -> T_TimedEvents_ProcessRing, 2 -> T_NoteRouting_Rebuild, 3 -> T_TimedEvents_ClearEndedTrackBits, 0 -> T_F41F10 + Queue2C00_DrainPassAB; commit (ring-8)=(ring-6), (ring-2)+=IZ.
; Out: IZ = bytes consumed.  What the classes are is not established.
TimedEvents_DispatchDueRun:
	ld XHL,TimedEvents_Ring                                    ; F82427  43 0a 08 60 00
	ld iy, (xhl-8)                                       ; F8242C  9b f8 25
	ld ix, (xhl-4)                                       ; F8242F  9b fc 24
	xor IZ,IZ                                            ; F82432  de d6
.LF82434:
	bit	7, (xhl+iy)                          ; F82434  f3 07 ec f4 cf
	jr nz, .LF82448                                      ; F82439  6e 0d
	inc 1,IZ                                             ; F8243B  de 61
	minc1_16 iy, 0x01ff                                  ; F8243D  dd 38 ff 01
	cp IY,IX                                             ; F82441  dc f5
	jr nz, .LF82434                                      ; F82443  6e ef
	jrl .LF824C8                                         ; F82445  78 80 00
.LF82448:
	ld	a, (xhl+iy)                                  ; F82448  c3 07 ec f4 21
	calr TimedEvents_ClassifyStatus                                      ; F8244D  1e db 00
	ld C,E                                               ; F82450  cd 8b
	inc 1,IZ                                             ; F82452  de 61
	minc1_16 iy, 0x01ff                                  ; F82454  dd 38 ff 01
	cp IY,IX                                             ; F82458  dc f5
	jr z, .LF824C8                                       ; F8245A  66 6c
	bit	6, (0x34d4:16)                               ; F8245C  f1 d4 34 ce
	jr nz, .LF82484                                      ; F82460  6e 22
	ld	b, (xhl+iy)                                  ; F82462  c3 07 ec f4 22
	cp B,0x60                                            ; F82467  ca cf 60
	jr nc, .LF82484                                      ; F8246A  6f 18
	ld	e, (Seq_BeatTick:8)                                      ; F8246C  c0 93 25
	ld D,B                                               ; F8246F  ca 8c
	cp B,E                                               ; F82471  cd f2
	jr ugt, .LF82478                                     ; F82473  6b 03
	add B,0x60                                           ; F82475  ca c8 60
.LF82478:
	sub B,E                                              ; F82478  cd a2
	cp B,0x30                                            ; F8247A  ca cf 30
	ld B,D                                               ; F8247D  cc 8a
	jr nc, .LF82484                                      ; F8247F  6f 03
	xor IZ,IZ                                            ; F82481  de d6
	ret                                                  ; F82483  0e
.LF82484:
	bit	7, (xhl+iy)                          ; F82484  f3 07 ec f4 cf
	jr z, .LF824D6                                       ; F82489  66 4b
	ld	a, (xhl+iy)                                  ; F8248B  c3 07 ec f4 21
	calr TimedEvents_ClassifyStatus                                      ; F82490  1e 98 00
	ld A,E                                               ; F82493  cd 89
	cp A,C                                               ; F82495  cb f1
	jr nz, .LF824C4                                      ; F82497  6e 2b
.LF82499:
	ld DE,IY                                             ; F82499  dd 8a
	ld	(0xbc:8), iz                                     ; F8249B  f0 bc 56
	inc 1,IZ                                             ; F8249E  de 61
	minc1_16 iy, 0x01ff                                  ; F824A0  dd 38 ff 01
	cp IY,IX                                             ; F824A4  dc f5
	jr z, .LF824C8                                       ; F824A6  66 20
	bit	6, (0x34d4:16)                               ; F824A8  f1 d4 34 ce
	jr nz, .LF82484                                      ; F824AC  6e d6
	ld	w, (xhl+iy)                                  ; F824AE  c3 07 ec f4 20
	calr TimedEvents_IsNotYetDue                                      ; F824B3  1e 90 00
	jr c, .LF824E2                                       ; F824B6  67 2a
	inc 1,IZ                                             ; F824B8  de 61
	minc1_16 iy, 0x01ff                                  ; F824BA  dd 38 ff 01
	cp IY,IX                                             ; F824BE  dc f5
	jr z, .LF824C8                                       ; F824C0  66 06
	jr .LF82484                                          ; F824C2  68 c0
.LF824C4:
	cp C,A                                               ; F824C4  c9 f3
	jr z, .LF82499                                       ; F824C6  66 d1
.LF824C8:
	cp c, 0x01:i3                                          ; F824C8  cb d9
	jr z, .LF824E9                                       ; F824CA  66 1d
	cp c, 0x02:i3                                          ; F824CC  cb da
	jr z, .LF824F3                                       ; F824CE  66 23
	cp c, 0x03:i3                                          ; F824D0  cb db
	jr z, .LF824FD                                       ; F824D2  66 29
	jr .LF82507                                          ; F824D4  68 31
.LF824D6:
	inc 1,IZ                                             ; F824D6  de 61
	minc1_16 iy, 0x01ff                                  ; F824D8  dd 38 ff 01
	cp IY,IX                                             ; F824DC  dc f5
	jr z, .LF824C8                                       ; F824DE  66 e8
	jr .LF82484                                          ; F824E0  68 a2
.LF824E2:
	ld IY,DE                                             ; F824E2  da 8d
	ld	iz, (0xbc:8)                                 ; F824E4  d0 bc 26
	jr .LF824C8                                          ; F824E7  68 df
.LF824E9:
	pushw iz                                             ; F824E9  2e
	ld (xhl-6), iy                                       ; F824EA  bb fa 55
	call T_TimedEvents_ProcessRing                                        ; F824ED  1d bc 13 f4
	jr .LF82512                                          ; F824F1  68 1f
.LF824F3:
	pushw iz                                             ; F824F3  2e
	ld (xhl-6), iy                                       ; F824F4  bb fa 55
	call T_NoteRouting_Rebuild                                        ; F824F7  1d bc 11 f4
	jr .LF82512                                          ; F824FB  68 15
.LF824FD:
	pushw iz                                             ; F824FD  2e
	ld (xhl-6), iy                                       ; F824FE  bb fa 55
	call T_TimedEvents_ClearEndedTrackBits                                        ; F82501  1d 0c 0a f4
	jr .LF82512                                          ; F82505  68 0b
.LF82507:
	pushw iz                                             ; F82507  2e
	ld (xhl-6), iy                                       ; F82508  bb fa 55
	call T_F41F10                                        ; F8250B  1d 10 1f f4
	calr Queue2C00_DrainPassAB                                      ; F8250F  1e 9a fe
.LF82512:
	ld XIX,TimedEvents_Ring                                    ; F82512  44 0a 08 60 00
	ld wa, (xix-6)                                       ; F82517  9c fa 20
	ld (xix-8), wa                                       ; F8251A  bc f8 50
	popw iz                                              ; F8251D  4e
	add (xix-2), iz                                      ; F8251E  9c fe 8e
	cp	wa, (xix-4)                                  ; F82521  9c fc f0
	jr nz, .LF8252A                                      ; F82524  6e 04
	res	6, (0x34d4:16)                               ; F82526  f1 d4 34 b6
.LF8252A:
	ret                                                  ; F8252A  0e
; TimedEvents_ClassifyStatus -- E = class of status byte A: 0x82 -> 3, 0x88 -> 2, 0x9n -> 1, anything else -> 0
; Evidence: `ld E,3 / cp A,0x82 / jr z`, `xor E,E / cp A,0x88 / ld E,2`, `and A,0xF0 / cp A,0x90 / ld E,1`; called twice by TimedEvents_DispatchDueRun.
TimedEvents_ClassifyStatus:
	ld e, 0x03:opc                                          ; F8252B  25 03
	cp A,0x82                                            ; F8252D  c9 cf 82
	jr z, .LF82545                                       ; F82530  66 13
	xor E,E                                              ; F82532  cd d5
	cp A,0x88                                            ; F82534  c9 cf 88
	jr nz, .LF8253B                                      ; F82537  6e 02
	ld e, 0x02:opc                                          ; F82539  25 02
.LF8253B:
	and A,0xf0                                           ; F8253B  c9 cc f0
	cp A,0x90                                            ; F8253E  c9 cf 90
	jr nz, .LF82545                                      ; F82541  6e 02
	ld e, 0x01:opc                                          ; F82543  25 01
.LF82545:
	ret                                                  ; F82545  0e
; TimedEvents_IsNotYetDue -- C set when stamp W is less than 0x30 ticks ahead of the tick counter (0x93), modulo 0x60
; Evidence: W<0x60: W -= (0x93), +0x60 unless the result is >0; then `cp W,0x30`.  W>=0x60 compares as is (not due).  (0x93) is the tick SeqBuf_AppendEvent stamps; 0x60 = 96 is the tick count the INTTR4 comment at 0xF82FDF calls one beat.
; Called from TimedEvents_DispatchDueRun 0xF824B3.
TimedEvents_IsNotYetDue:
	cp W,0x60                                            ; F82546  c8 cf 60
	jr nc, .LF82553                                      ; F82549  6f 08
	sub	w, (Seq_BeatTick:8)                                  ; F8254B  c0 93 a0
	jr gt, .LF82553                                      ; F8254E  6a 03
	add W,0x60                                           ; F82550  c8 c8 60
.LF82553:
	cp W,0x30                                            ; F82553  c8 cf 30
	ret                                                  ; F82556  0e
; SeqBuf_FlushStaged -- copy the bytes staged at 0xAE into the sequencer event ring and leave staging mode
; Evidence: with `ei 6`, for HL=0..(0xAC)-1: E=(0xAE+HL), SeqBuf_PutByte; then res 0,(0xAA) and (0xAC)=0.  SeqBuf_AppendMarker's bit-0-of-(0xAA) path writes to 0xAE+(0xAC).  prom_b directory slot T_SeqBuf_FlushStaged, called from 0xFAE9C7 and 0xFCAD6E.
SeqBuf_FlushStaged:
	push XIX                                             ; F82557  3c
	pushw hl                                             ; F82558  2b
	ld XIX,0x000000ae                                    ; F82559  44 ae 00 00 00
	xor HL,HL                                            ; F8255E  db d3
	ei 0x06                                              ; F82560  06 06
.LF82562:
	cp	hl, (SeqBuf_StagedCount:8)                                 ; F82562  d0 ac f3
	jr nc, .LF82573                                      ; F82565  6f 0c
	ld	e, (xix+hl)                                  ; F82567  c3 07 f0 ec 25
	calr SeqBuf_PutByte                                      ; F8256C  1e 31 00
	inc 1,HL                                             ; F8256F  db 61
	jr .LF82562                                          ; F82571  68 ef
.LF82573:
	res	0, (SeqBuf_Flags:8)                                   ; F82573  f0 aa b0
	ldw (SeqBuf_StagedCount:8), 0x00:io                                     ; F82576  0a ac 00 00
	ei 0x00                                              ; F8257A  06 00
	popw hl                                              ; F8257C  4b
	pop XIX                                              ; F8257D  5c
	ret                                                  ; F8257E  0e
	bit	0, (SeqBuf_Flags:8)                                   ; F8257F  f0 aa c8
	jr nz, .LF8258A                                      ; F82582  6e 06
	ld e, 0x81:opc                                          ; F82584  25 81
	calr SeqBuf_PutByte                                      ; F82586  1e 17 00
	ret                                                  ; F82589  0e
.LF8258A:
	push XIX                                             ; F8258A  3c
	ld XIX,0x000000ae                                    ; F8258B  44 ae 00 00 00
	ld	hl, (SeqBuf_StagedCount:8)                                 ; F82590  d0 ac 23
	ld	(xix+hl), 0x81                               ; F82593  f3 07 f0 ec 00 81
	inc 1,HL                                             ; F82599  db 61
	ld	(SeqBuf_StagedCount:8), hl                                     ; F8259B  f0 ac 53
	pop XIX                                              ; F8259E  5c
	ret                                                  ; F8259F  0e
; SeqBuf_PutByte -- append byte E to the 512-byte sequencer event ring at 0x600A14
; In: E.  Evidence: XIX=0x600A14; drops when (XIX-2) (free count, 0x600A12) is 0; else (XIX+HL)=E with HL=(XIX-4) (write index), HL+1 mod 0x200 (minc1_16 0x1FF), free count -1.  Same ring and fields as SeqBuf_AppendMarker.
SeqBuf_PutByte:
	push XIX                                             ; F825A0  3c
	pushw hl                                             ; F825A1  2b
	pushw wa                                             ; F825A2  28
	ld XIX,SeqBuf_Ring                                    ; F825A3  44 14 0a 60 00
	ld wa, (xix-2)                                       ; F825A8  9c fe 20
	and WA,WA                                            ; F825AB  d8 c0
	jr z, .LF825C3                                       ; F825AD  66 14
	ld hl, (xix-4)                                       ; F825AF  9c fc 23
	ld	(xix+hl), e                                  ; F825B2  f3 07 f0 ec 45
	minc1_16 hl, 0x01ff                                  ; F825B7  db 38 ff 01
	dec 1,WA                                             ; F825BB  d8 69
	ld (xix-4), hl                                       ; F825BD  bc fc 53
	ld (xix-2), wa                                       ; F825C0  bc fe 50
.LF825C3:
	popw wa                                              ; F825C3  48
	popw hl                                              ; F825C4  4b
	pop XIX                                              ; F825C5  5c
	ret                                                  ; F825C6  0e
; ---------------------------------------------------------------------
; Ring601850_ServiceIfNotEmpty -- runs Ring601850_ProcessNoteEvents exactly when ring 0x601850 holds data
;
; Evidence: 0xF825C7 `call 0xF41E68` = prom_b slot T_Ring601850_IsEmpty;
;           0xF825CB `and WA,WA` and 0xF825CD `jr z,.LF825D3` skip the
;           body when it returns zero; 0xF825CF `call 0xF413B8` = prom_b
;           slot T_F413B8 -> prom_a Ring601850_ProcessNoteEvents runs when it does not. ★
;           POLARITY, and it is the opposite of what the callee's name
;           suggests: Ring601850_IsEmpty (0xF84B6E) loads WA=0, compares
;           the read cursor (0x601848) with the write cursor (0x60184C)
;           and loads 0xFFFF only when they DIFFER -- so it returns ZERO
;           when the ring IS empty. Reached only through prom_b slot
;           T_F40020
; Unknown:  what Ring601850_ProcessNoteEvents does with the ring and what the ring
;           carries. ⚠ AND THE POLARITY ABOVE IS A FACT ABOUT ALL
;           FOURTEEN `Ring*_IsEmpty` ROUTINES, not just this one; none
;           of them is renamed here, because renaming fourteen prom_a
;           labels and their fourteen prom_b slots is a mass rename and
;           this wave has measured what those cost
; Was `sub_F825C7`, named by notes/prom_a_census_round8.py (bucket round 9).
; ---------------------------------------------------------------------
Ring601850_ServiceIfNotEmpty:
	call T_Ring601850_IsEmpty                            ; F825C7  1d 68 1e f4
	and WA,WA                                            ; F825CB  d8 c0
	jr z, .LF825D3                                       ; F825CD  66 04
	call T_F413B8                                        ; F825CF  1d b8 13 f4
.LF825D3:
	ret                                                  ; F825D3  0e
; ---------------------------------------------------------------------
; Ring_InitAllFourteen -- initialises ALL FOURTEEN of CPU 1's ring buffers, between
;                         five stores nothing in this tree names
;
; Evidence: fourteen consecutive `call` instructions at 0xF825E5,
;           0xF825E9, 0xF825ED, 0xF825F1, 0xF825F5, 0xF825F9, 0xF825FD,
;           0xF82601, 0xF82605, 0xF82609, 0xF8260D, 0xF82611, 0xF82615
;           and 0xF82619, whose operands are the prom_b slots
;           T_Ring608A0A_Init, T_Ring60480A_Init, T_Ring60000C_Init,
;           T_Ring601B64_Init, T_TimedEventRing_Init, T_SeqBufRing_Init,
;           T_MidiInARing_Init, T_MidiInBRing_Init, T_Ring601432_Init,
;           T_Ring60153C_Init, T_Ring601646_Init, T_Ring601850_Init,
;           T_Ring60195A_Init and T_Ring601C6E_Init -- that is EVERY
;           `T_Ring*_Init` label in prom_b, each exactly once, and
;           prom_b has exactly fourteen of them (`grep -c
;           '^T_Ring[0-9A-F]*_Init:' prom_b/wsa1_prom_b.s`). Around
;           them: 0xF825D4-0xF825DE writes 0xFF to (0x88) and (0x98) and
;           zeroes the longword at (0x80), 0xF825E1 calls sub_F831B3,
;           and 0xF8261D/0xF82622 write 0xFF to (0x2E00) and (0x2000).
;           Entered by the `jp` at 0xF82010, the first of six jump slots
;           that follow Data_F82000
; Unknown:  what the five stores mean -- (0x80), (0x88), (0x98),
;           (0x2000) and (0x2E00) are named by nothing in this tree --
;           and what sub_F831B3 does, which this file already refuses to
;           say because device 0x7F's role is open. ★ THE NAME COUNTS
;           THE CALLS, NOT THE RINGS: it claims fourteen Init entries
;           are called, which is checked, and nothing about whether
;           fourteen is all the machine has
; Was `sub_F825D4`, named by notes/prom_a_census_round8.py (bucket round 9).
; ---------------------------------------------------------------------
Ring_InitAllFourteen:
	ld a, 0xff:opc                                          ; F825D4  21 ff
	ld	(0x88:8), a                                      ; F825D6  f0 88 41
	ld	(0x98:8), a                                      ; F825D9  f0 98 41
	xor XWA,XWA                                          ; F825DC  e8 d0
	ld	(Tick_Count:8), xwa                                    ; F825DE  f0 80 60
	call sub_F831B3                                        ; F825E1  1d b3 31 f8
	call T_Ring608A0A_Init                               ; F825E5  1d e0 1c f4
	call T_Ring60480A_Init                               ; F825E9  1d 04 1d f4
	call T_Ring60000C_Init                               ; F825ED  1d 90 1e f4
	call T_Ring601B64_Init                               ; F825F1  1d 4c 1d f4
	call T_TimedEventRing_Init                               ; F825F5  1d 70 1d f4
	call T_SeqBufRing_Init                               ; F825F9  1d 94 1d f4
	call T_MidiInARing_Init                               ; F825FD  1d b8 1d f4
	call T_MidiInBRing_Init                               ; F82601  1d dc 1d f4
	call T_Ring601432_Init                               ; F82605  1d 00 1e f4
	call T_Ring60153C_Init                               ; F82609  1d 24 1e f4
	call T_Ring601646_Init                               ; F8260D  1d 48 1e f4
	call T_Ring601850_Init                               ; F82611  1d 6c 1e f4
	call T_Ring60195A_Init                               ; F82615  1d 28 1d f4
	call T_Ring601C6E_Init                               ; F82619  1d b4 1e f4
	ld (0x2e00:16), 0xff                                 ; F8261D  f1 00 2e 00 ff
	ld (0x2000:16), 0xff                                 ; F82622  f1 00 20 00 ff
	ret                                                  ; F82627  0e
; ---------------------------------------------------------------------
; Var7FC1_Clear -- (0x7FC1) = 0
;
; A single-cell accessor of the C-compiled half of prom_a: 2
; instructions, 0xF82628 to 0xF8262D, with no branch.
; Called from: 1 proven call sites, first a 0xF82018.
; Evidence: the body decoded from the ROM matches one of the 15
;          templates in notes/prom_a_naming_round3.py EXACTLY,
;          instruction for instruction, and touches exactly ONE
;          absolute address, 0x7FC1.  The name states the cell and the
;          direction and claims nothing about meaning.
; Unknown:  what (0x7FC1) holds.
; ---------------------------------------------------------------------
Var7FC1_Clear:
	ld (0x7fc1:16), 0x00                                 ; F82628  f1 c1 7f 00 00
	ret                                                  ; F8262D  0e
T_F4001C_Nop:
	ret                                                  ; F8262E  0e
MainTask_PhaseVector_Ret:
	ret                                                  ; F8262F  0e
; ModuleInit_Phase0Veneer -- directory-callable `calr ModuleInit_RunPhase0 / ret`
; Evidence: prom_b slot T_ModuleInit_Phase0Veneer is `jp ModuleInit_Phase0Veneer`.
ModuleInit_Phase0Veneer:
	calr ModuleInit_RunPhase0                                          ; F82630  1e ff 01
	ret                                                  ; F82633  0e
; ModuleInit_Phase1Veneer -- directory-callable `calr ModuleInit_RunPhase1 / ret`
; Evidence: prom_b slot T_ModuleInit_Phase1Veneer is `jp ModuleInit_Phase1Veneer`.
ModuleInit_Phase1Veneer:
	calr ModuleInit_RunPhase1                                          ; F82634  1e ff 01
	ret                                                  ; F82637  0e
; ModuleInit_Phase2Veneer -- directory-callable `calr ModuleInit_RunPhase2 / ret`
; Evidence: prom_b slot T_ModuleInit_Phase2Veneer is `jp ModuleInit_Phase2Veneer`; called from prom_a 0xFB3DC0.  The `call T_F413B8 / ret` at 0xF8263C after it is unlabelled.
ModuleInit_Phase2Veneer:
	calr ModuleInit_RunPhase2                                          ; F82638  1e ff 01
	ret                                                  ; F8263B  0e
	call T_F413B8                                        ; F8263C  1d b8 13 f4
	ret                                                  ; F82640  0e
; ---------------------------------------------------------------------
; ModuleInitDirectory_F82641 -- ★★ the 25 modules the machine boots, and their
; 0xFFFFFFFF terminator
;
; Read by: ONE site, the walker at 0xF82846-0xF8286F (`ld XHL,0x00F82641 /
;          ld XIX,(XHL+) / cp XIX,0xFFFFFFFF / ...`).
; Inputs:  WA = the phase, 0x00/0x04/0x08/0x0C/0x10, set by the five entry
;          points 0xF82832/36/3A/3E/42.
; Layout:  one LE32 per module, each an address in prom_b's directory
;          0xF40000-0xF44018.  The word AT that address is the module's phase
;          vector base; the walker skips a module whose vector base reads
;          0x0E0E0E0E (four RET bytes = the slot is pad).
; ENTRY COUNT 26 (25 modules + terminator), and how it is established: the
;          walker's own `cp XIX,0xFFFFFFFF`, and the ROM has exactly one
;          0xFFFFFFFF word in the run -- at 0xF826A5.  ★ LAST-ENTRY TEST:
;          0xF82641 + 26*4 = 0xF826A9, which is where this `.incbin` span ended
;          and where the already-converted RESET tail begins (`ld (0x6E),0x04`).
;          A 25th or 27th word would put that boundary inside an instruction.
; Evidence: the walker, plus all 25 pointers dereferenced in prom_b by
;          notes/prom_a_boot_checks.py: every one is inside 0xF40000-0xF44018,
;          every vector base it names is inside prom_a or prom_b, and the FIRST
;          (0x00F40000 -> 0x00F82010) lands on the six `jp` slots at 0xF82010 in
;          this very block.
; Unknown:  which module is which.  The 25 are recorded by ADDRESS only.
; ---------------------------------------------------------------------
ModuleInitDirectory_F82641:
	.long T_MainTask_PhaseVector                                   ; F82641  [  0]
	.long T_SC1_Vtable                               ; F82645  [  1]
	.long T_RingPutBlock_EntryThunks                 ; F82649  [  2]
	.long T_PanelWire_EntryThunks                                   ; F8264D  [  3]
	.long T_PanelEvent_PhaseVector                                   ; F82651  [  4]
	.long T_PanelLed_PhaseVector                                   ; F82655  [  5]
	.long T_AnalogScan_PhaseVector                                   ; F82659  [  6]
	.long T_MIDI_EntryThunks                         ; F8265D  [  7]
	.long T_MidiIn_EntryThunks                       ; F82661  [  8]
	.long T_SysexBulkDump_PhaseVector                                   ; F82665  [  9]
	.long T_SysExModule_EntryThunks                                   ; F82669  [ 10]
	.long T_ParamModule_PhaseVector                                   ; F8266D  [ 11]
	.long T_PanelTask_EntryVectors                   ; F82671  [ 12]
	.long T_LCD_EntryThunks                          ; F82675  [ 13]
	.long T_F40240                                   ; F82679  [ 14]
	.long T_F40210                                   ; F8267D  [ 15]
	.long T_F401D0                                   ; F82681  [ 16]
	.long T_DebugMonitor_PhaseVector                                   ; F82685  [ 17]
	.long T_DiskScreens_PhaseVector                                   ; F82689  [ 18]
	.long T_F409C0                                   ; F8268D  [ 19]
	.long T_Msg0716_InitAllRecords_Entry                                   ; F82691  [ 20]
	.long T_NoteRouting_PhaseVector                                   ; F82695  [ 21]
	.long T_Ram3800_Start_Entry                                   ; F82699  [ 22]
	.long T_Disk_PhaseVector                                   ; F8269D  [ 23]
	.long T_EditScreen_PhaseVector                                   ; F826A1  [ 24]
	.long 0xffffffff                                 ; F826A5  [ 25]

; ==============================================================================
; RESET -- 0xF826A9, the address in the reset vector at 0xFFFF00
; ==============================================================================
;
; Structure: disarm the watchdog, program every port, program the timers, start
; them, program the memory controller, program the two UARTs, clear internal RAM
; and work DRAM, then jump into prom_b.  There is no stack yet -- the first
; instruction that needs one is on the far side of the jump (`ld XSP,0x0060EB80`
; at 0xF85606, reached through the prom_b thunk table), so nothing here may
; call.
;
; The memory-controller block below is the primary evidence for the CPU 1 memory
; map; notes/FINDINGS-memory-map.md gives the resulting map together with the
; parts of it that are NOT established.
;
RESET:
	; --- watchdog off ------------------------------------------------------
	ld (WDMOD:8),0x04:io
	ld (WDCR:8),0xB1:io		; 0xB1 is conventionally the watchdog DISABLE code.
				; NOT citable here: MAME stubs wdcr_w entirely
				; (tmp95c061.cpp:1126-1128) and no databook is in
				; these trees.  prom_c writes the same value.

	; --- ports -------------------------------------------------------------
	ld (P6:8),0x1B:io
	ld (P6FC:8),0x1F:io		; five alternate functions on port 6.  P6 is
				; "shared with CS0, CS1, CS3/LCAS, RAS, REFOUT"
				; (tmp95c061.h:19), so this turns on RAS and
				; REFOUT -- the DRAM controller is live -- and
				; makes the CS3 pin LCAS.  CS2 is NOT on port 6,
				; which is why the boot ROM's own chip select
				; needs no enabling here.
	ld (P2:8),0xFF:io
	ld (P2FC:8),0xFF:io		; port 2 entirely A16-A23
	ld (P5:8),0xFF:io
	ld (P5FC:8),0x24:io
	ld (P5CR:8),0x2C:io
	ld (P7:8),0xFF:io
	ld (P7FC:8),0x00:io
	ld (P7CR:8),0x33:io
	ld (P8:8),0xFF:io
	ld (P8FC:8),0x29:io		; port 8 is "shared with TXD0, TXD1, RXD0, RXD1,
				; CTS0, SCLK0, SCLK1" (tmp95c061.h:21); which
				; of bits 0/3/5 is which pin is NOT established
	ld (P8CR:8),0x09:io
	ld (PA:8),0xF9:io
	ld (PAFC:8),0x00:io
	ld (PACR:8),0x0E:io
	ld (PB:8),0xF3:io
	ld (PBFC:8),0x00:io
	ld (PBCR:8),0x0C:io

	; --- 8-bit timers 0-3 --------------------------------------------------
	ld (TRUN:8),0x00:io		; everything stopped while it is programmed
	ld (T01MOD:8),0x0D:io	; timer1 clock select = 3 -> phiT256 = fc/2048
				; (tap numbering per tmp94c241.cpp:1400/1528;
				; see notes/FINDINGS-system-clock.md section 6)
	ld (TFFCR:8),0x00:io
	ld (TREG0:8),0x0F:io
	ld (TREG1:8),0x1C:io		; 28 counts of phiT256 -> 488.28 Hz at 28 MHz
	ld (T23MOD:8),0x01:io
	ld (TREG2:8),0x00:io
	ld (TREG3:8),0x00:io
	ld (TRDC:8),0x00:io

	; --- 16-bit timers 4-7 -------------------------------------------------
	ld (T4MOD:8),0x05:io		; bits[1:0]=01 -> phiT1 = fc/8
	ld (T4FFCR:8),0x00:io
	ld (T45CR:8),0x00:io
	ld (TREG4L:8),0x01:io	; TREG4 = 0x0001
	ld (TREG4H:8),0x00:io
	ld (TREG5L:8),0x09:io	; TREG5 = 0x3D09 = 15625 -> 140.0 BPM.
	ld (TREG5H:8),0x3D:io	; INTTR4 (vector 0xFFFF50) is the sequencer tick;
				; the runtime tempo setter at 0xFAA373 computes
				; TREG5 = 140000000/(64*BPM), and 140,000,000 is
				; 5*fc.  That is the primary clock lever --
				; notes/FINDINGS-system-clock.md.
	ld (T5MOD:8),0x02:io
	ld (T5FFCR:8),0x00:io
	ld (TREG6L:8),0x98:io	; TREG6 = 0x3A98 = 15000
	ld (TREG6H:8),0x3A:io
	ld (TREG7L:8),0x98:io	; TREG7 = 0x3A98 = 15000
	ld (TREG7H:8),0x3A:io
	ld (TRUN:8),0xB7:io		; bit 7 = prescaler run (tmp95c061.cpp:672).  Bits 0-2
				; start 8-bit timers 0-2, bit 3 (timer 3) stays
				; off, bits 4-5 start 16-bit timers 4 and 5 --
				; timer 4 is the sequencer tick.

	; --- memory controller: block starts, then window masks ----------------
	; MSARn = A23-A16 of the block start.
	ld (MSAR0:8),0x78:io		; CS0 -> 0x780000.  ⚠ every CS0 device this
				; firmware actually touches lies at or above
				; 0x790000, and a byte census of prom_a+prom_b
				; finds nothing at all in 0x680000-0x78FFFF.
				; Of the two decoders that survive the
				; elimination, only the literal-base one puts
				; the window at 0x780000; the truncated-base one
				; puts it at 0x600000 and leaves the low 1.5 MB
				; of it empty.  See the MAMR note below.
	ld (MSAR1:8),0x00:io		; CS1 -> 0x000000, the static RAM
	ld (MSAR2:8),0xE0:io		; CS2 -> 0xE00000, the program EPROM area:
				; prom_b at 0xF00000, prom_a at 0xF80000
	ld (MSAR3:8),0x60:io		; CS3 -> 0x600000, the work DRAM (P6FC above
				; makes this pin LCAS)
	ld (MAMR0:8),0x3F:io
	ld (MAMR1:8),0x7F:io
	ld (MAMR2:8),0x3F:io
	ld (MAMR3:8),0x0F:io	; MAMR = window size.  MAME stores it and never decodes
			; it, and no databook is in these trees, so this is
			; ELIMINATION rather than decode:
			; scripts/analysis/mamr_reading_elimination.py feeds
			; eight candidate decoders {32 KB, 64 KB per MAMR unit}
			; x {base truncated to the window, base literal} x
			; {higher-numbered CS wins, lower wins} the values above
			; and checks each against facts from this firmware --
			; the DRAM must be on CS3, 0x7E0000 must be on CS0, the
			; EPROMs on CS2, and so on.  TWO of the eight survive,
			; and they differ only in the base convention:
			;   MAMR0 0x3F -> 2 MB     CS0 0x600000-0x7FFFFF
			;                       OR CS0 0x780000-0x97FFFF  ⚠
			;   MAMR1 0x7F -> 4 MB     CS1 0x000000-0x3FFFFF
			;   MAMR2 0x3F -> 2 MB     CS2 0xE00000-0xFFFFFF
			;   MAMR3 0x0F -> 512 KB   CS3 0x600000-0x67FFFF
			; So 32 KB per unit and higher-CS-wins are established
			; against the alternatives on the table; CS0's own
			; window is NOT ESTABLISHED, and that is the only row
			; the two survivors disagree on.

	; --- pattern generators off --------------------------------------------
	ld (PG0REG:8),0x00:io
	ld (PG1REG:8),0x00:io
	ld (PG01CR:8),0x00:io

	; --- serial channel 0 = the MIDI port ----------------------------------
	; Proven by traffic, not by inference: 0xFA544F onwards writes the MIDI
	; System Real-Time status bytes FC/F8/FE/FA/FB and 0xFA7D76 writes F6
	; straight into SC0BUF, and nothing else in any of the four images does.
	ld (SC0CR:8),0x00:io
	ld (SC0MOD:8),0x29:io	; bits[3:2] = 2 -> 8-bit UART, bits[1:0] = 1 ->
				; baud-rate generator as the clock source; both
				; decoded in tmp94c241_serial.cpp:271-285.
				; Bit 5 is the receive enable -- prom_c writes
				; 0x09 for the same port with that bit clear.
				; The name "RXE" is recalled, not cited: it
				; appears nowhere in src/devices/cpu/tlcs900/.
	ld (BR0CR:8),0x0C:io	; boot value: divide by 768.  ⚠ NOT the operative
			; one.  The runtime init at 0xFA58F2 overwrites it with
			; 0x0E (divide by 896) unless (0xFFFFF8) == 0x24, and
			; prom_a[0xFFFFF8] is 0x02 -- it is the separator byte
			; inside the build tag at the very end of this file.
			; 896 * 31250 = 28,000,000; 768 * 31250 = 24,000,000.
			; The parts list contains a 24 MHz oscillator too, so
			; this branch is a real variant, and lever 1 alone
			; cannot pick between them.  See the notes.
	ld (SC1CR:8),0x00:io
	ld (SC1MOD:8),0x01:io
	ld (BR1CR:8),0x36:io
	ld (ODE:8),0x03:io		; open-drain enable, bits 0 and 1.  Which outputs
				; those are is NOT established.

	; --- DRAM controller ---------------------------------------------------
	ld (DREFCR:8),0x71:io	; refresh enabled.  Field layout NOT established.
	ld (DMEMCR:8),0x8D:io	; access control.  Field layout NOT established.
				; 0xF830AC rewrites this as 0x2D immediately
				; before `set 5,(P6)` and `halt`, i.e. self
				; refresh for power-down.

	; --- chip-select enable + per-area access timing -----------------------
	; Bit layout NOT established -- see include/tmp95c061_sfr.inc.  Bit 3 is
	; set exactly on CS2 and CS3, which on this machine are exactly the two
	; 16-bit-wide areas (the flash unlock addresses on CPU 2 prove the width
	; for that CS2; here it is inference from the identical B2CS value).
	ld (B0CS:8),0x14:io
	ld (B1CS:8),0x17:io
	ld (B2CS:8),0x1B:io
	ld (B3CS:8),0x19:io
	ld (BEXCS:8),0x03:io		; everything outside the four areas
	ld (ADMOD:8),0x3F:io

	; --- interrupt controller ----------------------------------------------
	ld (IIMC:8),0x05:io
	ld (DMA0V:8),0x00:io		; no micro-DMA channel armed yet.  DMA2V is
	ld (DMA1V:8),0x00:io		; armed later, at 0xF8E166, with 0x12 -> vector
	ld (DMA2V:8),0x00:io		; 0x48 = INTT2: that is the engine that pushes
	ld (DMA3V:8),0x00:io		; packets at the other CPU through 0x7C0000.

	; --- clear internal RAM, 0x000080-0x0051FF -----------------------------
	; 0x1460 stores of 4 bytes = 0x5180 bytes from 0x80.  This is the only
	; thing that puts a size on the CS1 static RAM, and it is a lower bound,
	; not the chip size.
	ldw BC,0x1460
	ld XIX,0x00000080
	xor XWA,XWA
RESET__clear_iram:
	ld (xix+), XWA
	djnz16 BC,RESET__clear_iram

	; --- clear work DRAM, 0x600000-0x6033FF --------------------------------
	ld XBC,0x00000D00
	ld XIX,0x00600000
RESET__clear_dram_lo:
	ld (xix+), XWA
	sub XBC,0x00000001
	jr NZ,RESET__clear_dram_lo

	; --- clear work DRAM, 0x604000-0x60FFFF --------------------------------
	; ⚠ Note the hole: 0x603400-0x603FFF is deliberately NOT cleared, and it
	; is live -- prom_b reads it at 0xF440A5 (`ld XHL,0x00603400`).  That is
	; a preserved region across a warm restart, in the same spirit as the
	; KN5000's power-fail area.
	ld XBC,0x00003000
	ld XIX,0x00604000
RESET__clear_dram_hi:
	ld (xix+), XWA
	sub XBC,0x00000001
	jr NZ,RESET__clear_dram_hi

	; --- into prom_b -------------------------------------------------------
	; 0xF42D60 is a slot in prom_b's linker thunk table; it holds
	; `jp 0xF85606`, and 0xF85606 is `ld XSP,0x0060EB80`.  This single
	; instruction is one of the four things that fix prom_b's base.
	jp T_Kernel_InitRam

; ==============================================================================
; 0xF827C8-0xF82CFE -- CONVERTED 2026-08-25 (wave 5 round 3); the power-on block's
; own banner is below.  This line said "not yet converted" until then.
; ==============================================================================
; CORRECTED 2026-08-25 (wave 5 round 2): this banner read "0xF827C8-0xFFFEFF",
; the range it covered when the file was ONE `.incbin`.  prom_a/insert_region.py
; splits the directive under a banner and cannot know the banner exists, so a
; banner like this goes stale silently and the byte gate cannot see it.  A check
; in notes/prom_a_byte_checks.py now re-derives every such banner's range from
; the `.incbin` beneath it.
;
; ★ WHAT IS IN HERE, and it is worth a wave: the three POWER-ON CHORDS the
; emulation gap list's gap O asks about (ROM version display at 0xF82952 /
; 0xF8295F, FACTORY CLEAR at 0xF828DF / 0xF828E9, the unidentified third at
; 0xF82A0A / 0xF82A18), the MODEL-VARIANT detection at 0xF82882 and the
; expansion-board check at 0xF828C3.  1,335 bytes.
; ==============================================================================
; 0xF827C8-0xF82CFE -- ★★★ THE POWER-ON BLOCK: variant strap, expansion-board
; identification, the three service chords, and the ROM VERSION SCREEN that
; NAMES prom_d
; ==============================================================================
;
; Converted 2026-08-25 (wave 5 round 3).  This 1,335-byte span was the last
; unconverted piece of the reset path, and it answers or advances four entries
; on the emulator's request list
; (kn7000_mame/notes/WSA1-EMULATION-DISASM-GAPS.md).
;
; ★★★ GAP D -- CLOSED, and by a label the machine itself prints.
;   VersionScreen_Show (0xF82A28) makes TWO remote reads over the link, using the
;   same (dst, count, src) argument shape as the remote-flash module:
;       dst RAM 0x2640, count 11, src remote 0x00FFFFF0
;       dst RAM 0x264C, count 11, src remote 0x00F7FFF0
;   and then draws a screen whose three labels are the ASCII "WSA-A:", "WSA-C:"
;   and "WSA-D:" (inside VersionScreen_DisplayLists below).  The three value
;   records point at, in order, 0x00FFFFF5 -- prom_a's OWN tag, read locally --
;   0x00002645 and 0x00002651, i.e. each buffer + 5.
;   The four ROM images in hand end like this:
;       prom_a 0xFFFFF0  "wsaa_822\x02ssf"
;       prom_c 0xFFFFF0  "wsac_230\x02ssf"
;       prom_d 0x07FFF0  "wsad_54.ssf"
;   so remote 0x00FFFFF0 is prom_c and remote 0x00F7FFF0 is prom_d at CPU 2
;   base 0x00F00000.  The tie is not just the string: the firmware CARRIES A
;   SPECIAL CASE FOR prom_d'S ONE-BYTE-SHORTER TAG.  `cp (XIX+0x15),0x6673` at
;   0xF82A93 tests the SECOND buffer's bytes +9/+10 for the ASCII "sf", and only
;   `wsad_54.ssf` has "sf" there -- `wsac_230\x02ss` has "ss" -- and when it
;   matches, 0xF82A9A-0xF82AA3 shifts the version field right by one and pads
;   with a space.  A firmware that did not expect prom_d's exact tag could not
;   contain that branch.
;   ⚠ What this does NOT say: it does not identify the flash at 0xE80000, and it
;   does not say prom_d is that flash.  It says prom_d is the image CPU 2 reads
;   at 0x00F00000-0x00F7FFFF.  notes/FINDINGS-memory-map.md sec.5 should be read
;   against that.
;
; ★★ GAP C -- the count in every note that quotes it CHANGES here.  This block
;   contains TWO more converted `call 0xF4123C` (Link_WaitBlockDone) sites,
;   0xF828A8 and 0xF82A45/0xF82A6C, neither of them a remote-FLASH read: one
;   reads 10 bytes from remote 0x00C00000, the others read 11 bytes from the two
;   ROM tails.  Re-run notes/prom_a_converted_callers.py 0xF4123C after this
;   block lands; the honest sentence is "any link block transfer", not "a
;   remote-flash read".
;
; ★★ GAP O -- the three power-on chords, and the VARIANT STRAP that picks
;   between their two forms.  Variant_SetFromPB0 (0xF82882) is SIX
;   instructions across its whole address extent 0xF82882-0xF8288E:
;   `ld A,0x01 / bit 0,(PB) / jr NZ / ld A,0x02` then `ld (0xC4),A` and `ret`.
;   ⚠ This paragraph said "four instructions" and then listed five; corrected
;   2026-08-30 against the listing, and the count is now asserted by
;   notes/prom_a_census_round8.py --selftest, which counts across the ADDRESS
;   EXTENT because a label-bounded count stops at an internal label.
;   So (0x00C4) -- the model-variant flag the emulator's variant
;   survey went looking for -- is 1 when PORT B BIT 0 reads HIGH and 2 when it
;   reads LOW, and it is set once, here, on the reset path.  Each of the three
;   chord tests then opens `cp (0xC4),0x01` and takes a different panel shadow
;   byte for each variant:
;       FACTORY CLEAR   0xF828D9  variant 1 -> (0x2B38) == 0x07 exactly
;                                 variant 2 -> (0x2B38) & 0x03 == 0x03
;       ROM VERSION     0xF8294C  variant 1 -> (0x2B32) & 0x07 == 0x07
;                                 variant 2 -> (0x2B30) & 0x70 == 0x70
;       third chord     0xF82A04  variant 1 -> (0x2B3A) & 0xE0 == 0xE0
;                                 variant 2 -> (0x2B33) & 0xE0 == 0xE0
;   All six are re-read from the ROM by notes/prom_a_boot_checks.py.
;
; ★ AND THE EXPANSION BOARD.  ExtBoard_Identify (0xF8288F) reads 10 bytes from
;   remote 0x00C00000 into RAM 0x2640 and compares them with the ASCII
;   "WSA1 EXTBD" at 0xF828C7; on a match it writes 0x5A to (0x00C5), otherwise
;   (0x00C5) stays 0.  So (0x00C5) is the expansion-board-present flag and
;   0x00C00000 is the board's window -- which is the same base the two
;   already-converted 0xFC00xx callers of the packet builder use.
;
; Routines whose meaning is not established are `sub_XXXXXX` on purpose.
; ==============================================================================
; MainTask_Entry -- entry of CPU 1's first kernel task: power-on initialisation, then MainTask_Loop
; Evidence: EntryPoint_Records[0] is {0x00F4005C, 0x0060E800, 0x8800, 3} and slot T_MainTask_Entry is `jp MainTask_Entry` (prom_c's record 0 is MAIN).  Body: INTET10=0x30, INTE45=0x40, INTET54=0x03; T_CheckingDevice_RunSelfTest; PowerFail_VerifySavedBlocks; Variant_SetFromPB0; ModuleInit_RunPhase0; ExtBoard_Identify; ModuleInit_RunPhaseByChecksums; ModuleInit_RunPhase3; Irq_InitLevelsTC23; waits for (0x80)>=0x384; the three power-on chords; Kernel_StartTask(2); `jp MainTask_Loop`.
MainTask_Entry:
	ld (INTET10:8), 0x30:io                                      ; F827C8  08 73 30
	ld (INTE45:8), 0x40:io                                      ; F827CB  08 71 40
	ld (INTET54:8), 0x03:io                                      ; F827CE  08 75 03
	call T_CheckingDevice_RunSelfTest                                        ; F827D1  1d 44 01 f4
	calr PowerFail_VerifySavedBlocks                                          ; F827D5  1e a8 04
	calr Variant_SetFromPB0                              ; F827D8  1e a7 00
	ei 0x00                                              ; F827DB  06 00
	calr ModuleInit_RunPhase0                                      ; F827DD  1e 52 00
	calr Variant_SendPortBToCpu2                                          ; F827E0  1e 05 05
	ei 0x06                                              ; F827E3  06 06
	calr PowerOnChord_ClearRamAndReset                                            ; F827E5  1e e9 00
	ei 0x00                                              ; F827E8  06 00
	calr ExtBoard_Identify                               ; F827EA  1e a2 00
	res	4, (P7:8)                                   ; F827ED  f0 13 b4
	calr ModuleInit_RunPhaseByChecksums                                          ; F827F0  1e b8 04
	ei 0x00                                              ; F827F3  06 00
	calr ExtBoard_Identify                               ; F827F5  1e 97 00
	call T_TestMode_SelectFromPowerOnKeys                                        ; F827F8  1d 48 01 f4
	calr ModuleInit_RunPhase3                                      ; F827FC  1e 3f 00
	calr Irq_InitLevelsTC23                                      ; F827FF  1e 6e 00
	ei 0x00                                              ; F82802  06 00
.LF82804:
	cpw	(Tick_Count:8), 0x0384                             ; F82804  d0 80 3f 84 03
	jr c, .LF82804                                       ; F82809  67 f9
	res	5, (P7:8)                                   ; F8280B  f0 13 b5
	calr PowerOnChord_ShowRevisionLeds                                          ; F8280E  1e 3b 01
	ei 0x00                                              ; F82811  06 00
	calr PowerOnChord_VersionScreen                                          ; F82813  1e ee 01
	ld XIX,0x00000097                                    ; F82816  44 97 00 00 00
	ld A,(XIX)                                           ; F8281B  84 21
	and A,0x03                                           ; F8281D  c9 cc 03
	or A,0x02                                            ; F82820  c9 ce 02
	ld (XIX),A                                           ; F82823  b4 41
	ld a, 0x02:opc                                          ; F82825  21 02
	call T_Kernel_StartTask                              ; F82827  1d 6c 2d f4
	set	3, (TRUN:8)                                   ; F8282B  f0 20 bb
	jp MainTask_Loop                                          ; F8282E  1b 28 20 f8
; ModuleInit_RunPhase0 -- run phase 0 (offset 0x00) of every module in ModuleInitDirectory_F82641
; Evidence: `ld A,0x00 / jr 0xF82846`, the walker that calls (vector + WA) for each of the 25 modules.  Callers: MainTask_Entry 0xF827DD, ModuleInit_Phase0Veneer.
ModuleInit_RunPhase0:
	ld a, 0x00:opc                                          ; F82832  21 00
	jr .LF82846                                          ; F82834  68 10
; ModuleInit_RunPhase1 -- run phase 1 (offset 0x04) of every module
; Evidence: `ld A,0x04 / jr 0xF82846`.  Callers: ModuleInit_RunPhaseByChecksums (both power-fail checksums valid), ModuleInit_Phase1Veneer.
ModuleInit_RunPhase1:
	ld a, 0x04:opc                                          ; F82836  21 04
	jr .LF82846                                          ; F82838  68 0c
; ModuleInit_RunPhase2 -- run phase 2 (offset 0x08) of every module
; Evidence: `ld A,0x08 / jr 0xF82846`.  Callers: ModuleInit_RunPhaseByChecksums (a checksum failed), ModuleInit_Phase2Veneer.
ModuleInit_RunPhase2:
	ld a, 0x08:opc                                          ; F8283A  21 08
	jr .LF82846                                          ; F8283C  68 08
; ModuleInit_RunPhase3 -- run phase 3 (offset 0x0C) of every module
; Evidence: `ld A,0x0C / jr 0xF82846`; caller MainTask_Entry 0xF827FC.  This label's span also holds the unlabelled phase-4 entry 0xF82842 (`ld A,0x10`) and the walker 0xF82846-0xF8286F.
ModuleInit_RunPhase3:
	ld a, 0x0c:opc                                          ; F8283E  21 0c
	jr .LF82846                                          ; F82840  68 04
	ld a, 0x10:opc                                          ; F82842  21 10
	jr .LF82846                                          ; F82844  68 00
.LF82846:
	extz WA                                              ; F82846  d8 12
	ld XHL,ModuleInitDirectory_F82641                    ; F82848  43 41 26 f8 00
.LF8284D:
	ld xix, (xhl+)                                    ; F8284D  e5 ee 24
	cp XIX,0xffffffff                                    ; F82850  ec cf ff ff ff ff
	jr z, .LF8286F                                       ; F82856  66 17
	ld XIX,(XIX)                                         ; F82858  a4 24
	cp XIX,0x0e0e0e0e                                    ; F8285A  ec cf 0e 0e 0e 0e
	jr z, .LF8286D                                       ; F82860  66 0b
	lda	xix, (xix+wa)                                ; F82862  f3 07 f0 e0 34
	push XHL                                             ; F82867  3b
	pushw wa                                             ; F82868  28
	call (xix)                                           ; F82869  b4 e8
	popw wa                                              ; F8286B  48
	pop XHL                                              ; F8286C  5b
.LF8286D:
	jr .LF8284D                                          ; F8286D  68 de
.LF8286F:
	ret                                                  ; F8286F  0e
; Irq_InitLevelsTC23 -- write 0xDD to INTETC23
; Evidence: `ld (0x7A),0xDD / ret`; 0x7A is INTETC23 in include/tmp95c061_sfr.inc.  One caller, MainTask_Entry 0xF827FF.  The DSP_ChannelRegs_Write8 call at 0xF82874 after the `ret` is a separate unlabelled fragment.
Irq_InitLevelsTC23:
	ld (INTETC23:8), 0xdd:io                                      ; F82870  08 7a dd
	ret                                                  ; F82873  0e
	ld XIY,Link_HandshakeTimeouts                                    ; F82874  45 db 07 60 00
	push XIY                                             ; F82879  3d
	pushw wa                                             ; F8287A  28
	call T_DSP_ChannelRegs_Write8                        ; F8287B  1d e0 2d f4
	inc 6,XSP                                            ; F8287F  ef 66
	ret                                                  ; F82881  0e
; ---------------------------------------------------------------------
; ★ WHICH VARIANT IS WHICH -- the header below says "Unknown: which physical
;          variant is 1 and which is 2", and the tree has since answered it.
;          ⚠ ANSWERED BY ROUND 11, NOT HERE:
;          notes/wave7_panel_names_round11.py --variant. This block only
;          carries the answer to the routine that raises the question, which
;          had gone eleven rounds without it.
;
; VARIANT 2 -- PORT B BIT 0 LOW -- IS THE SX-WSA1R, the rack this service
;          manual documents. The panel event lists the strap selects
;          (0xF8A851 `cp (0xC4),0x01`, taking 0xF8B446 for 1 and 0xF8B4B2
;          otherwise) say which matrix bits the firmware expects to move, and
;          on all twelve wire segments variant 2's answer is the manual's own
;          diode list -- CP1 "D1-23, 25-48" and CP2 "D57-60, 65, 66, 73-77"
;          -- including the missing SW24, the empty segment 6, and 4/2/5
;          fitted switches on CP2's three segments. Variant 1 contradicts it
;          on six of the twelve, expecting sixteen switches this instrument
;          does not have.
;
; Round 11 settles it three independent ways -- the diode coverage above, the
;          three power-on service chords, and the number-pad value tables
;          (only variant 2's, at 0xF8AE57, makes segment-1 bit b the key
;          printed b). Re-derived independently, and by the coverage argument
;          alone, by notes/prom_a_panel_control_map.py --variant.
; ⚠ Variant 1's panel is NOT identified. The keyboard SX-WSA1 is the obvious
;          candidate and no SX-WSA1 material exists in these trees, so it
;          stays a candidate.
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; Variant_SetFromPB0 -- sets (0x00C4), the model-variant flag, from PORT B bit 0
;
; Evidence: 0xF82882 `ldb a, 0x01`, 0xF82884 `bit_dd8 0x00, 0x1f` (PB is
;           0x1F in include/tmp95c061_sfr.inc), 0xF82889 `ldb a, 0x02`
;           on the not-taken arm, 0xF8288B `st_dd8b a, 0xc4`. Six
;           instructions counted across the routine's whole address
;           extent 0xF82882-0xF8288E, `ret` included. This listing's own
;           power-on-block header already states the name and the
;           reading -- 1 when PB0 reads HIGH, 2 when it reads LOW -- and
;           the six chord tests that branch on it are re-read from the
;           ROM by notes/prom_a_boot_checks.py
; Unknown:  which physical variant is 1 and which is 2. The strap is a
;           pin state and no schematic in this tree names it
; Was `sub_F82882`, named by notes/prom_a_census_round8.py (bucket T1).
; ---------------------------------------------------------------------
Variant_SetFromPB0:
	ld a, 0x01:opc                                          ; F82882  21 01
	bit	0, (PB:8)                                   ; F82884  f0 1f c8
	jr nz, .LF8288B                                      ; F82887  6e 02
	ld a, 0x02:opc                                          ; F82889  21 02
.LF8288B:
	ld	(Variant_Flag:8), a                                      ; F8288B  f0 c4 41
	ret                                                  ; F8288E  0e
; ---------------------------------------------------------------------
; ExtBoard_Identify -- reads the expansion board's 10-byte header and sets
;                      (0x00C5) to 0x5A if it matches
;
; Evidence: 0xF8288F `ldio 0xc5, 0x00` clears the flag; 0xF8289B `ld
;           XWA,0x00c00000` and 0xF82898 `pushw 0x0a` are the remote
;           address and length handed to the link block read at 0xF828A1
;           and 0xF828A8; 0xF828AC `ldb c, 0x0a`, 0xF828AE `ld
;           XIX,0x00002640` and 0xF828B3 `ld XIY,0x00f828c7` set up the
;           10-byte compare whose only success path is 0xF828C3 `ldio
;           0xc5, 0x5a`. 0xF828C7 is ExtBoardMagic_Wsa1Extbd, the ASCII
;           "WSA1 EXTBD", already labelled in this listing, and that
;           label's own header names (0x00C5) as this routine's output.
;           Called from prom_a 0xF827EA and 0xF827F5, both `calr`, in
;           the reset path
; Unknown:  what reads (0x00C5) afterwards, and what the other 0x30
;           bytes of the board header at 0x00C00000 mean. ★ SUPERSEDES
;           round 7's --apply-strings refusal header, which recorded
;           only that 0xF828B3 loads the text at 0xF828C7 and declined
;           to name the routine from it; that fact is kept above and the
;           refusal is not, because the two headers contradicted each
;           other in one file
; Was `sub_F8288F`, named by notes/prom_a_census_round8.py (bucket T1).
; ---------------------------------------------------------------------
ExtBoard_Identify:
	ld (0xc5:8), 0x00:io                                      ; F8288F  08 c5 00
	ld XWA,UI_DrawScratch                                    ; F82892  40 40 26 00 00
	push XWA                                             ; F82897  38
	pushw 0x0a                                           ; F82898  0b 0a 00
	ld XWA,0x00c00000                                    ; F8289B  40 00 00 c0 00
	push XWA                                             ; F828A0  38
	call T_Link_SendCommandE2                            ; F828A1  1d f0 0e f4
	lda xsp, (xsp+0x0a)                                  ; F828A5  bf 0a 37
	call T_Link_WaitBlockDone                            ; F828A8  1d 3c 12 f4
	ld c, 0x0a:opc                                          ; F828AC  23 0a
	ld XIX,UI_DrawScratch                                    ; F828AE  44 40 26 00 00
	ld XIY,ExtBoardMagic_Wsa1Extbd                       ; F828B3  45 c7 28 f8 00
.LF828B8:
	ld a, (xix+)                                      ; F828B8  c5 f0 21
	cp a, (xiy+)                                      ; F828BB  c5 f4 f1
	jr nz, .LF828C6                                      ; F828BE  6e 06
	djnz8 c, .LF828B8                                    ; F828C0  cb 1c f5
	ld (0xc5:8), 0x5a:io                                      ; F828C3  08 c5 5a
.LF828C6:
	ret                                                  ; F828C6  0e
; ---------------------------------------------------------------------
; ExtBoardMagic_Wsa1Extbd -- the 10 ASCII bytes "WSA1 EXTBD"
;
; Read by: ONE site, the compare loop at 0xF828AC-0xF828C2 (`ld C,0x0A /
;          ld XIX,0x00002640 / ld XIY,0x00F828C7 / ld A,(XIX+) / cp A,(XIY+) /
;          jr NZ / djnz C`).
; Inputs:  RAM 0x2640, which the ten instructions above it fill from remote
;          0x00C00000 over the link.
; Outputs: (0x00C5) = 0x5A on a full 10-byte match; untouched (0) otherwise.
; ENTRY COUNT 10 bytes, from the loop's own `ld C,0x0A` -- not from counting
;          printable characters.  ★ LAST-ENTRY TEST: 0xF828C7 + 10 = 0xF828D1,
;          which is `cp (0x7FCA),0x5AA5`, the next instruction and a `calr`
;          target from 0xF827E5.  An 11-byte reading puts that call one byte
;          inside an instruction -- it is the single offender
;          notes/prom_a_linear_decode_check.py reported for this span.
; Evidence: the bytes, asserted verbatim in notes/prom_a_boot_checks.py.
; ★ Renamed from `ExtBoardMagic_F828C7` in round 10 (framed -> content) by notes/prom_a_census_round8.py:
; the distinguishing part becomes the ROM's own bytes instead of an
; address: 0x57 0x53 0x41 0x31 0x20 0x45 0x58 0x54 0x42 0x44 is `WSA1
; EXTBD`, the ten bytes ExtBoard_Identify compares. ⚠ Round 9's framed
; scan reads `.ascii` runs and this object is emitted as `.byte`,
; which is why it measured zero promotable objects and why that
; sentence is corrected above
; ---------------------------------------------------------------------
ExtBoardMagic_Wsa1Extbd:
	.byte 0x57, 0x53, 0x41, 0x31, 0x20, 0x45, 0x58, 0x54, 0x42, 0x44          ; F828C7
; PowerOnChord_ClearRamAndReset -- unless (0x7FCA)=0x5AA5, on the FACTORY CLEAR chord zero both RAMs and restart
; Evidence: returns at once when (0x7FCA)=0x5AA5; chord: variant 1 (0x2B38)=0x07, variant 2 (0x2B38)&3=3 (FINDINGS-prom_a-boot-and-version-screen.md §4).  On it: ei 7, zero 0x1FE0 longs from 0x80 and 0x20000 longs from 0x600000, (0x7FD2)=(0x7FD4)=0, (0x7FC7),0x18, (0x7FCA)=0x5AA5, (0x7FD1)=0, (0x97) bits, `jrl RESET`.  Without it: (0x7FC7) bit 4 cleared, (0x97),0x20.
; Caller: MainTask_Entry 0xF827E5.
PowerOnChord_ClearRamAndReset:
	cpw	(0x7fca:16), 0x5aa5                          ; F828D1  d1 ca 7f 3f a5 5a
	jr z, .LF82940                                       ; F828D7  66 67
	cp	(Variant_Flag:8), 0x01                               ; F828D9  c0 c4 3f 01
	jr nz, .LF828E9                                      ; F828DD  6e 0a
	ld a, (Panel_SwitchShadow+0x18:16)                                   ; F828DF  c1 38 2b 21
	cp a, 0x07:i3                                          ; F828E3  c9 df
	jr nz, .LF82941                                      ; F828E5  6e 5a
	jr .LF828F4                                          ; F828E7  68 0b
.LF828E9:
	ld a, (Panel_SwitchShadow+0x18:16)                                   ; F828E9  c1 38 2b 21
	and A,0x03                                           ; F828ED  c9 cc 03
	cp a, 0x03:i3                                          ; F828F0  c9 db
	jr nz, .LF82941                                      ; F828F2  6e 4d
.LF828F4:
	ei 0x07                                              ; F828F4  06 07
	ldw bc, 0x1fe0                                       ; F828F6  31 e0 1f
	ld XIX,0x00000080                                    ; F828F9  44 80 00 00 00
	xor XWA,XWA                                          ; F828FE  e8 d0
.LF82900:
	ld (xix+), xwa                                    ; F82900  f5 f2 60
	djnz16 bc, .LF82900                                  ; F82903  d9 1c fa
	ld XBC,0x00020000                                    ; F82906  41 00 00 02 00
	ld XIX,0x00600000                                    ; F8290B  44 00 00 60 00
.LF82910:
	ld (xix+), xwa                                    ; F82910  f5 f2 60
	sub XBC,0x00000001                                   ; F82913  e9 ca 01 00 00 00
	jr nz, .LF82910                                      ; F82919  6e f5
	xor WA,WA                                            ; F8291B  d8 d0
	ld (0x7fd2:16), wa                                  ; F8291D  f1 d2 7f 50
	ld (0x7fd4:16), wa                                  ; F82921  f1 d4 7f 50
	or	(0x7fc7:16), 0x18                            ; F82925  c1 c7 7f 3e 18
	ldw (0x7fca:16), 0x5aa5                              ; F8292A  f1 ca 7f 02 a5 5a
	and	(0x97:8), 0x03                               ; F82930  c0 97 3c 03
	ld (0x7fd1:16), 0x00                                 ; F82934  f1 d1 7f 00 00
	or	(0x97:8), 0x01                               ; F82939  c0 97 3e 01
	jrl RESET                                             ; F8293D  78 69 fd
.LF82940:
	ret                                                  ; F82940  0e
.LF82941:
	and	(0x7fc7:16), 0xef                            ; F82941  c1 c7 7f 3c ef
	or	(0x97:8), 0x20                               ; F82946  c0 97 3e 20
	jr .LF82940                                          ; F8294A  68 f4
; 2026-10-05: CPU 2's build tags, read over the link by the two power-on chords.  0x00FFFFF0 was spelled
;   BUILD_TAG, this image's own tag at the same number -- a false cross-reference: the link reads prom_c's
;   ('wsac_230'; original_ROMs/wsa1_prom_c.ic28's last 16 bytes).  0x00F7FFF0 is prom_d's ('wsad_54.ssf'), shown
;   under 'WSA-D:' (the power-on block's header above).
	.equ PromC_BuildTag, 0x00FFFFF0
	.equ PromD_BuildTag, 0x00F7FFF0

; PowerOnChord_ShowRevisionLeds -- on its chord, show the prom_a and prom_c revision nibbles on panel LEDs, for ever
; Evidence: chord variant 1 (0x2B32)&7=7, variant 2 (0x2B30)&0x70=0x70; reads 11 bytes of remote 0x00FFFFF0 (0xF82974 loads BUILD_TAG, ROM text 'wsaa_822'; remotely it is prom_c's tag) into 0x2640 via T_Link_SendCommandE2 + T_Link_WaitBlockDone, (0x2648)=0xFF on failure; then loops: RomRevisions_ShowOnLeds, T_SC1_Entry_F40F18_Ret, wait 50 ticks of (0x80).  Never returns.
; Caller: MainTask_Entry 0xF8280E.  The LCD version screen is the other chord, PowerOnChord_VersionScreen.
PowerOnChord_ShowRevisionLeds:
	cp	(Variant_Flag:8), 0x01                               ; F8294C  c0 c4 3f 01
	jr nz, .LF8295F                                      ; F82950  6e 0d
	ld a, (Panel_SwitchShadow+0x12:16)                                   ; F82952  c1 32 2b 21
	and A,0x07                                           ; F82956  c9 cc 07
	cp a, 0x07:i3                                          ; F82959  c9 df
	jr nz, .LF829A5                                      ; F8295B  6e 48
	jr .LF8296B                                          ; F8295D  68 0c
.LF8295F:
	ld a, (Panel_SwitchShadow+0x10:16)                                   ; F8295F  c1 30 2b 21
	and A,0x70                                           ; F82963  c9 cc 70
	cp A,0x70                                            ; F82966  c9 cf 70
	jr nz, .LF829A5                                      ; F82969  6e 3a
.LF8296B:
	ld XWA,UI_DrawScratch                                    ; F8296B  40 40 26 00 00
	push XWA                                             ; F82970  38
	pushw 0x0b                                           ; F82971  0b 0b 00
	ld XWA,PromC_BuildTag                                    ; F82974  40 f0 ff ff 00
	push XWA                                             ; F82979  38
	call T_Link_SendCommandE2                            ; F8297A  1d f0 0e f4
	lda xsp, (xsp+0x0a)                                  ; F8297E  bf 0a 37
	call T_Link_WaitBlockDone                            ; F82981  1d 3c 12 f4
	and WA,WA                                            ; F82985  d8 c0
	jr z, .LF8298E                                       ; F82987  66 05
	ld (UI_DrawScratch+8:16), 0xff                                 ; F82989  f1 48 26 00 ff
.LF8298E:
	calr RomRevisions_ShowOnLeds                                      ; F8298E  1e 15 00
	call T_SC1_Entry_F40F18_Ret                          ; F82991  1d 18 0f f4
	ld	de, (Tick_Count:8)                                 ; F82995  d0 80 22
.LF82998:
	ld	wa, (Tick_Count:8)                                 ; F82998  d0 80 20
	sub WA,DE                                            ; F8299B  da a0
	cp WA,0x0032                                         ; F8299D  d8 cf 32 00
	jr c, .LF82998                                       ; F829A1  67 f5
	jr .LF8298E                                          ; F829A3  68 e9
.LF829A5:
	ret                                                  ; F829A5  0e
; RomRevisions_ShowOnLeds -- send the two ROM revision nibbles to two panel LED wires
; Evidence: A = LedNibblePatterns_F829F4[(0xFFFFF8)&0x0F] (prom_a's own tag) -> T_PanelLed_SendByte with W=0, then [(0x2648)&0x0F] (the tag read from remote 0xFFFFF0) -> W=1; on variant 2 ((0xC4)!=1) A is `srl 4` first; ends with T_SC1_TxFlush.
RomRevisions_ShowOnLeds:
	ld c, (BUILD_TAG+8:24)                                 ; F829A6  c2 f8 ff ff 23
	and C,0x0f                                           ; F829AB  cb cc 0f
	ld XIY,LedNibblePatterns_F829F4                      ; F829AE  45 f4 29 f8 00
	ld	a, (xiy+c)                                   ; F829B3  c3 03 f4 e4 21
	cp	(Variant_Flag:8), 0x01                               ; F829B8  c0 c4 3f 01
	jr z, .LF829C5                                       ; F829BC  66 07
	srl a, 0x04                                          ; F829BE  c9 ef 04
	ld w, 0x00:opc                                          ; F829C1  20 00
	jr .LF829C7                                          ; F829C3  68 02
.LF829C5:
	ld w, 0x00:opc                                          ; F829C5  20 00
.LF829C7:
	call T_PanelLed_SendByte                                        ; F829C7  1d 78 06 f4
	ld c, (UI_DrawScratch+8:16)                                   ; F829CB  c1 48 26 23
	and C,0x0f                                           ; F829CF  cb cc 0f
	ld XIY,LedNibblePatterns_F829F4                      ; F829D2  45 f4 29 f8 00
	ld	a, (xiy+c)                                   ; F829D7  c3 03 f4 e4 21
	cp	(Variant_Flag:8), 0x01                               ; F829DC  c0 c4 3f 01
	jr z, .LF829E9                                       ; F829E0  66 07
	srl a, 0x04                                          ; F829E2  c9 ef 04
	ld w, 0x01:opc                                          ; F829E5  20 01
	jr .LF829EB                                          ; F829E7  68 02
.LF829E9:
	ld w, 0x01:opc                                          ; F829E9  20 01
.LF829EB:
	call T_PanelLed_SendByte                                        ; F829EB  1d 78 06 f4
	call T_SC1_TxFlush                                   ; F829EF  1d 08 0f f4
	ret                                                  ; F829F3  0e
; ---------------------------------------------------------------------
; LedNibblePatterns_F829F4 -- 16 bytes: one panel-LED bit pattern per nibble
;
; Read by: TWO sites, both `ld XIY,0x00F829F4 / ld A,(XIY+C)` -- 0xF829AE with
;          C = (0xFFFFF8) & 0x0F and 0xF829D2 with C = (0x2648) & 0x0F.  Those
;          two bytes are the ninth byte of prom_a's OWN tag and the ninth byte
;          of the tag read from remote 0x00FFFFF0 (prom_c), i.e. the revision
;          nibble of each ROM.  The byte then goes to `call 0xF40678` with
;          W = 0 for the first and W = 1 for the second -- two LED wires -- and
;          on variant 2 (`cp (0xC4),0x01` false) it is first `srl 0x04,A`,
;          moving the pattern into the LOW nibble.
; ENTRY COUNT 16, from the reader's own `and C,0x0F` -- 0x0F is the largest
;          index it can produce, so 16 entries.  Not counted by eye.
;          ★ LAST-ENTRY TEST: 0xF829F4 + 16 = 0xF82A04, which is
;          `cp (0xC4),0x01`, the first instruction of the third chord test and a
;          `calr` target from 0xF82813.  Fifteen or seventeen entries land at
;          0xF82A03 or 0xF82A05, neither of which is an instruction boundary.
; ★ THE TABLE IS A FORMULA, not an arbitrary map:
;          entry[n] == 0x80 | (bitreverse4(n) << 3)
;          for all sixteen n -- bit 7 is a constant marker and n's four bits are
;          emitted in reverse order into bits 6,5,4,3.  Asserted for every entry
;          by notes/prom_a_boot_checks.py, which computes the formula rather
;          than storing the table.
; Evidence: the two readers, the mask, and the formula check above.
; Unknown:  which physical LEDs wires 0 and 1 light.  That is emulation gap O
;          and this table does not answer it; what it does give the panel lane
;          is the exact bit ORDER the firmware expects on a wire.
; ---------------------------------------------------------------------
LedNibblePatterns_F829F4:
	.byte 0x80, 0xc0, 0xa0, 0xe0, 0x90, 0xd0, 0xb0, 0xf0, 0x88, 0xc8, 0xa8, 0xe8, 0x98, 0xd8, 0xb8, 0xf8  ; F829F4
; PowerOnChord_VersionScreen -- on its chord, show the ROM VERSION screen
; Evidence: variant 1 (0x2B3A)&0xE0=0xE0, variant 2 (0x2B33)&0xE0=0xE0 -> `calr VersionScreen_Show`; caller MainTask_Entry 0xF82813.
PowerOnChord_VersionScreen:
	cp	(Variant_Flag:8), 0x01                               ; F82A04  c0 c4 3f 01
	jr nz, .LF82A18                                      ; F82A08  6e 0e
	ld a, (Panel_SwitchShadow+0x1a:16)                                   ; F82A0A  c1 3a 2b 21
	and A,0xe0                                           ; F82A0E  c9 cc e0
	cp A,0xe0                                            ; F82A11  c9 cf e0
	jr nz, .LF82A27                                      ; F82A14  6e 11
	jr .LF82A24                                          ; F82A16  68 0c
.LF82A18:
	ld a, (Panel_SwitchShadow+0x13:16)                                   ; F82A18  c1 33 2b 21
	and A,0xe0                                           ; F82A1C  c9 cc e0
	cp A,0xe0                                            ; F82A1F  c9 cf e0
	jr nz, .LF82A27                                      ; F82A22  6e 03
.LF82A24:
	calr VersionScreen_Show                              ; F82A24  1e 01 00
.LF82A27:
	ret                                                  ; F82A27  0e
; ---------------------------------------------------------------------
; VersionScreen_Show -- reads the two 11-byte ROM tail tags over the link and
;                       stages them for the version screen
;
; Evidence: 0xF82A38 `ld XWA,0x00fffff0` with 0xF82A35 `pushw 0x0b` into
;           0xF82A2F `ld XIX,0x00002640`, and 0xF82A5F `ld
;           XWA,0x00f7fff0` with 0xF82A5C `pushw 0x0b` into 0xF82A56 `ld
;           XIX,0x0000264c`, each through the link block read at
;           0xF82A3E/0xF82A45 and 0xF82A65/0xF82A6C; 0xF82A28 `m_cp_mi16
;           MW8, 0x80, 0x03e8` spins until the tick counter passes 1000
;           before either read. This listing already names the routine
;           in the power-on block's own header
; ⚠ TWO CLAIMS CORRECTED IN ROUND 8, both by this file's own contents.
;           (a) This header said "nothing here draws anything". The body RUNS
;           THREE DISPLAY LISTS, and this same file says so ninety lines below.
;           The two 11-byte tags are staged at 0x2640 and 0x264C AND drawn here.
;           (b) It said 0x00FFFFF0 is "prom_a's OWN tail tag". It is not --
;           0x00FFFFF0 is PROM_C's tag; prom_a reads its own locally at
;           0x00FFFFF5. Calling the remote one local revived a local/remote
;           confusion this tree had already settled, so it is named explicitly
;           here to stop it coming back a third time.
; Unknown:  which of the three lists carries which tag, and what the second
;           read at 0x00F7FFF0 is for. Called from prom_a 0xF82A24 (calr)
; Was `sub_F82A28`, named by notes/prom_a_census_round8.py (bucket T1).
; ---------------------------------------------------------------------
VersionScreen_Show:
	cpw	(Tick_Count:8), 0x03e8                             ; F82A28  d0 80 3f e8 03
	jr c, VersionScreen_Show                             ; F82A2D  67 f9
	ld XIX,UI_DrawScratch                                    ; F82A2F  44 40 26 00 00
	push XIX                                             ; F82A34  3c
	pushw 0x0b                                           ; F82A35  0b 0b 00
	ld XWA,PromC_BuildTag                                    ; F82A38  40 f0 ff ff 00
	push XWA                                             ; F82A3D  38
	call T_Link_SendCommandE2                            ; F82A3E  1d f0 0e f4
	lda xsp, (xsp+0x0a)                                  ; F82A42  bf 0a 37
	call T_Link_WaitBlockDone                            ; F82A45  1d 3c 12 f4
	and WA,WA                                            ; F82A49  d8 c0
	jr z, .LF82A56                                       ; F82A4B  66 09
	ldw	(xix+5), 0x7245                              ; F82A4D  bc 05 02 45 72
	ld (XIX+0x07),0x72                                   ; F82A52  bc 07 00 72
.LF82A56:
	ld XIX,UI_DrawScratch+12                                    ; F82A56  44 4c 26 00 00
	push XIX                                             ; F82A5B  3c
	pushw 0x0b                                           ; F82A5C  0b 0b 00
	ld XWA,PromD_BuildTag                                   ; F82A5F  40 f0 ff f7 00
	push XWA                                             ; F82A64  38
	call T_Link_SendCommandE2                            ; F82A65  1d f0 0e f4
	lda xsp, (xsp+0x0a)                                  ; F82A69  bf 0a 37
	call T_Link_WaitBlockDone                            ; F82A6C  1d 3c 12 f4
	ld XIX,UI_DrawScratch                                    ; F82A70  44 40 26 00 00
	and WA,WA                                            ; F82A75  d8 c0
	jr z, .LF82A82                                       ; F82A77  66 09
	ldw	(xix+17), 0x7245                             ; F82A79  bc 11 02 45 72
	ld (XIX+0x13),0x72                                   ; F82A7E  bc 13 00 72
.LF82A82:
	cpw	(xix+9), 0x6673                              ; F82A82  9c 09 3f 73 66
	jr nz, .LF82A93                                      ; F82A87  6e 0a
	ld WA,(XIX+0x05)                                     ; F82A89  9c 05 20
	ld (XIX+0x06),WA                                     ; F82A8C  bc 06 50
	ld (XIX+0x05),0x20                                   ; F82A8F  bc 05 00 20
.LF82A93:
	cpw	(xix+21), 0x6673                             ; F82A93  9c 15 3f 73 66
	jr nz, .LF82AA4                                      ; F82A98  6e 0a
	ld WA,(XIX+0x11)                                     ; F82A9A  9c 11 20
	ld (XIX+0x12),WA                                     ; F82A9D  bc 12 50
	ld (XIX+0x11),0x20                                   ; F82AA0  bc 11 00 20
.LF82AA4:
	res	5, (P7:8)                                   ; F82AA4  f0 13 b5
	call T_LCD_BlankThenSetPanel3Layer_Copy                                        ; F82AA7  1d 10 2e f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F82AAB  f1 40 25 00 00
	ld (LCD_CurrentLayer:16), 0x00                                 ; F82AB0  f1 40 25 00 00
	ld XWA,VersionScreen_DisplayLists+0x69               ; F82AB5  40 6c 2b f8 00
	push XWA                                             ; F82ABA  38
	ld XWA,VersionScreen_DisplayLists                    ; F82ABB  40 03 2b f8 00
	push XWA                                             ; F82AC0  38
	call T_DisplayList_Run_Stack                         ; F82AC1  1d 00 2e f4
	inc 8,XSP                                            ; F82AC5  ef 60
	cpw (BUILD_TAG+10:24), 0x6673                        ; F82AC7  d2 fa ff ff 3f 73 66   "sf" at BUILD_TAG+10
	jr nz, .LF82ADC                                      ; F82ACE  6e 0c
	ld XWA,VersionScreen_DisplayLists+0x9C               ; F82AD0  40 9f 2b f8 00
	ld XHL,VersionScreen_DisplayLists+0x69               ; F82AD5  43 6c 2b f8 00
	jr .LF82AE6                                          ; F82ADA  68 0a
.LF82ADC:
	ld XWA,VersionScreen_Glyphs                          ; F82ADC  40 b0 2b f8 00
	ld XHL,VersionScreen_DisplayLists+0x7A               ; F82AE1  43 7d 2b f8 00
.LF82AE6:
	push XWA                                             ; F82AE6  38
	push XHL                                             ; F82AE7  3b
	call T_DisplayListB_Run_Stack                        ; F82AE8  1d 04 2e f4
	inc 8,XSP                                            ; F82AEC  ef 60
	call T_LCD_ShowAllLayers_StackFrame_Copy                                        ; F82AEE  1d 14 2e f4
	ld XDE,0x00400000                                    ; F82AF2  42 00 00 40 00
.LF82AF7:
	nop                                                  ; F82AF7  00
	dec 1,XDE                                            ; F82AF8  ea 69
	cp XDE,0x00000000                                    ; F82AFA  ea cf 00 00 00 00
	jr nz, .LF82AF7                                      ; F82B00  6e f5
	ret                                                  ; F82B02  0e
; ---------------------------------------------------------------------
; VersionScreen_DisplayLists -- ★★★ the ROM VERSION screen, 173 bytes of
; display-list records, and the three labels that name prom_a, prom_c and prom_d
;
; Read by: THREE sites, all in VersionScreen_Show:
;          0xF82AB5-0xF82AC1  (start 0xF82B03, end 0xF82B6C) -> T_DisplayList_Run_Stack (T_F42E00)
;          0xF82AD0-0xF82AE8  (start 0xF82B6C, end 0xF82B9F) -> T_DisplayListB_Run_Stack (T_F42E04)
;          0xF82ADC-0xF82AE8  (start 0xF82B7D, end 0xF82BB0) -> T_DisplayListB_Run_Stack (T_F42E04)
;          T_DisplayList_Run_Stack (T_F42E00) -> prom_b 0xF31800 and T_DisplayListB_Run_Stack (T_F42E04) -> 0xF31814 are the two
;          display-list draw entries (notes/FINDINGS-ui-display-list.md).
; Layout:  the (opcode, length) record format of that note.  The ASCII in it,
;          in order: "ROM VERSION", "WSA-A:", "WSA-C:", "WSA-D:",
;          "Software Group".
; ★ The four 17-byte value records at 0xF82B6C, 0xF82B7D, 0xF82B8E and 0xF82B9F
;   each carry TWO LE32 pointers, and they are what tie the screen to the ROMs:
;       0xF82B6C  0x00002640, 0x00FFFFF5   <- prom_a's own tag + 5
;       0xF82B7D  0x00002640, 0x00002645   <- the 0xFFFFF0 buffer + 5 = prom_c
;       0xF82B8E  0x0000264C, 0x00002651   <- the 0xF7FFF0 buffer + 5 = prom_d
;       0xF82B9F  0x00002640, 0x00FFFFF5
;   and their y coordinates 0x5E, 0x73, 0x88 are the SAME three values the
;   "WSA-A:"/"WSA-C:"/"WSA-D:" label records carry.  +5 is the offset of the
;   version digits in a "wsaX_NNN" tag.
; ENTRY COUNT: not a table, a byte-coded list; the extent 0xF82B03-0xF82BAF is
;          fixed by the three (start, end) pairs the reader itself pushes, whose
;          union is exactly [0xF82B03, 0xF82BB0).  ★ LAST-ENTRY TEST: 0xF82BB0
;          is the END operand of the third call, and the byte after it begins the
;          glyph block below.
; Evidence: the two pointer pairs and the three y coordinates, all re-read from
;          the ROM by notes/prom_a_boot_checks.py, together with the four ROM
;          tail strings.
; Unknown:  the record opcodes are not re-decoded here; prom_b's interpreter
;          notes own that.
; ---------------------------------------------------------------------
VersionScreen_DisplayLists:
	.byte 0x1c, 0x11, 0x70, 0x00, 0x17, 0x00, 0x52, 0x4f, 0x4d, 0x20, 0x56, 0x45, 0x52, 0x53, 0x49, 0x4f  ; F82B03
	.byte 0x4e, 0x1c, 0x0c, 0x6b, 0x00, 0x5e, 0x00, 0x57, 0x53, 0x41, 0x2d, 0x41, 0x3a, 0x1c, 0x0c, 0x6b  ; F82B13
	.byte 0x00, 0x73, 0x00, 0x57, 0x53, 0x41, 0x2d, 0x43, 0x3a, 0x1c, 0x0c, 0x6b, 0x00, 0x88, 0x00, 0x57  ; F82B23
	.byte 0x53, 0x41, 0x2d, 0x44, 0x3a, 0x06, 0x12, 0xfa, 0x21, 0x53, 0x6f, 0x66, 0x74, 0x77, 0x61, 0x72  ; F82B33
	.byte 0x65, 0x20, 0x47, 0x72, 0x6f, 0x75, 0x70, 0x0a, 0x0a, 0x32, 0x00, 0x41, 0x00, 0x0b, 0x01, 0xb1  ; F82B43
	.byte 0x00, 0x03, 0x0c, 0xb0, 0x2b, 0xf8, 0x00, 0xf1, 0x21, 0x08, 0x00, 0x0a, 0x00, 0x03, 0x0c, 0x00  ; F82B53
	.byte 0x2c, 0xf8, 0x00, 0x39, 0x02, 0x04, 0x00, 0x20, 0x00, 0x07, 0x11, 0x40, 0x26, 0x00, 0x00, 0x1c  ; F82B63
	.byte 0xf5, 0xff, 0xff, 0x00, 0x03, 0x00, 0xad, 0x00, 0x5e, 0x00, 0x07, 0x11, 0x40, 0x26, 0x00, 0x00  ; F82B73
	.byte 0x1c, 0x45, 0x26, 0x00, 0x00, 0x03, 0x00, 0xad, 0x00, 0x73, 0x00, 0x07, 0x11, 0x4c, 0x26, 0x00  ; F82B83
	.byte 0x00, 0x1c, 0x51, 0x26, 0x00, 0x00, 0x03, 0x00, 0xad, 0x00, 0x88, 0x00, 0x07, 0x11, 0x40, 0x26  ; F82B93
	.byte 0x00, 0x00, 0x1c, 0xf5, 0xff, 0xff, 0x00, 0x04, 0x00, 0xa2, 0x00, 0x5e, 0x00  ; F82BA3
; ---------------------------------------------------------------------
; VersionScreen_Glyphs -- 208 bytes of bitmap that the version screen's last
; display list points into
;
; Read by: NOT ESTABLISHED as a table.  0xF82BB0 is the end operand of the third
;          draw call above, and 0xF82C80 is a `calr` target from 0xF827D5, so
;          the extent is pinned at both ends by instructions; what is between is
;          declared data because a linear decode of it produces nothing that
;          resembles a routine (no prologue, no `ret`, 26 `db` bytes).
; Evidence: the two boundary instructions, asserted in
;          notes/prom_a_boot_checks.py.
; Unknown:  everything about the content.  It opens `FF FF 8C 0C 0C 0C 0C 0C 0C
;          1E C0 C0 40 3C 66 C3 FF C0 66 3C`, which reads as 8-pixel-wide glyph
;          rows, but this tree has not decoded the format and does not claim it.
; ---------------------------------------------------------------------
VersionScreen_Glyphs:
	.byte 0xff, 0xff, 0x8c, 0x0c, 0x0c, 0x0c, 0x0c, 0x0c, 0x0c, 0x1e, 0xc0, 0xc0, 0x40, 0x3c, 0x66, 0xc3  ; F82BB0
	.byte 0xff, 0xc0, 0x66, 0x3c, 0x00, 0x00, 0x00, 0x1f, 0x33, 0x61, 0x60, 0x60, 0x33, 0x1e, 0xe0, 0x60  ; F82BC0
	.byte 0x60, 0x6e, 0x73, 0x63, 0x63, 0x63, 0x63, 0xf7, 0x00, 0x00, 0x00, 0x77, 0x39, 0x31, 0x31, 0x31  ; F82BD0
	.byte 0x31, 0xfb, 0x18, 0x18, 0x00, 0x38, 0x99, 0x9b, 0x9b, 0x9b, 0x99, 0xfc, 0x00, 0x00, 0x00, 0xf9  ; F82BE0
	.byte 0x9b, 0x0b, 0x01, 0x00, 0x9b, 0xf1, 0x00, 0x00, 0x00, 0xf0, 0x38, 0x00, 0xf0, 0x38, 0x98, 0xf0  ; F82BF0
	.byte 0xff, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80  ; F82C00
	.byte 0x80, 0x80, 0x80, 0x80, 0x80, 0xff, 0x80, 0x80, 0x87, 0x9f, 0xb6, 0x87, 0x87, 0x86, 0x80, 0xff  ; F82C10
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x05, 0x03, 0x17, 0x0f, 0x5f, 0x3f, 0xbe, 0x5d, 0xab  ; F82C20
	.byte 0x57, 0x2d, 0x15, 0x08, 0x00, 0xff, 0x00, 0x00, 0x01, 0x07, 0xcf, 0xfd, 0x78, 0x33, 0x00, 0xff  ; F82C30
	.byte 0xff, 0x00, 0x00, 0x00, 0x20, 0x70, 0xf8, 0xfc, 0xf6, 0xec, 0xdc, 0xb4, 0x74, 0xd0, 0xd0, 0x40  ; F82C40
	.byte 0x40, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x71, 0xc7, 0x8c, 0xdb, 0xf6, 0x63, 0xc1, 0x00, 0xff  ; F82C50
	.byte 0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01  ; F82C60
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0xff, 0x01, 0xc1, 0xc7, 0xf9, 0xe1, 0xc1, 0x81, 0x81, 0x01, 0xff  ; F82C70
; PowerFail_VerifySavedBlocks -- check the two 512-byte blocks the power-fail NMI check-summed; result in (0x7FD1)
; Evidence: (0x7FD1)=0; PowerFail_VerifyChecksum512 on XIY=0x7620/XIX=0x7FD2 sets bit 0 when it matches, on 0x617800/0x7FD4 bit 1 -- the same two pairs NMI_PowerFail_SaveAndHalt hands PowerFail_Checksum512 (0xF83086/0xF83093).
; Caller: MainTask_Entry 0xF827D5; ModuleInit_RunPhaseByChecksums reads the bits.
PowerFail_VerifySavedBlocks:
	ld XHL,0x00007fd1                                    ; F82C80  43 d1 7f 00 00
	ld (XHL),0x00                                        ; F82C85  b3 00 00
	ld XIY,Combination_Current                                    ; F82C88  45 20 76 00 00
	ld XIX,0x00007fd2                                    ; F82C8D  44 d2 7f 00 00
	calr PowerFail_VerifyChecksum512                                      ; F82C92  1e 3e 00
	jr c, .LF82C99                                       ; F82C95  67 02
	set 0,(XHL)                                          ; F82C97  b3 b8
.LF82C99:
	ld XIY,0x00617800                                    ; F82C99  45 00 78 61 00
	ld XIX,0x00007fd4                                    ; F82C9E  44 d4 7f 00 00
	calr PowerFail_VerifyChecksum512                                      ; F82CA3  1e 2d 00
	jr c, .LF82CAA                                       ; F82CA6  67 02
	set 1,(XHL)                                          ; F82CA8  b3 b9
.LF82CAA:
	ret                                                  ; F82CAA  0e
; ModuleInit_RunPhaseByChecksums -- run module phase 1 when both saved blocks verified, else phase 2
; Evidence: (0x7FD1) bit 0 and bit 1 set -> ModuleInit_RunPhase1; bit 0 clear -> (0x97)&0x23|0x01, bit 1 clear -> (0x97)&0x37|0x14, then ModuleInit_RunPhase2.  Caller MainTask_Entry 0xF827F0.
ModuleInit_RunPhaseByChecksums:
	ld XHL,0x00007fd1                                    ; F82CAB  43 d1 7f 00 00
	bit 0,(XHL)                                          ; F82CB0  b3 c8
	jr z, .LF82CBD                                       ; F82CB2  66 09
	bit 1,(XHL)                                          ; F82CB4  b3 c9
	jr z, .LF82CC7                                       ; F82CB6  66 0f
	calr ModuleInit_RunPhase1                                          ; F82CB8  1e 7b fb
	jr .LF82CD2                                          ; F82CBB  68 15
.LF82CBD:
	and	(0x97:8), 0x23                               ; F82CBD  c0 97 3c 23
	or	(0x97:8), 0x01                               ; F82CC1  c0 97 3e 01
	jr .LF82CCF                                          ; F82CC5  68 08
.LF82CC7:
	and	(0x97:8), 0x37                               ; F82CC7  c0 97 3c 37
	or	(0x97:8), 0x14                               ; F82CCB  c0 97 3e 14
.LF82CCF:
	calr ModuleInit_RunPhase2                                          ; F82CCF  1e 68 fb
.LF82CD2:
	ret                                                  ; F82CD2  0e
; PowerFail_VerifyChecksum512 -- C clear when NOT(sum of 256 words at XIY) equals the word at (XIX)
; Evidence: PowerFail_Checksum512's loop (`ld BC,0x100 / add WA,(XIY+) / djnz / cpl WA`) followed by `cp (XIX),WA` and scf/rcf instead of the store.  Called twice by PowerFail_VerifySavedBlocks.
PowerFail_VerifyChecksum512:
	ldw bc, 0x0100                                       ; F82CD3  31 00 01
	xor WA,WA                                            ; F82CD6  d8 d0
.LF82CD8:
	add wa, (xiy+)                                    ; F82CD8  d5 f5 80
	djnz16 bc, .LF82CD8                                  ; F82CDB  d9 1c fa
	cpl WA                                               ; F82CDE  d8 06
	cp (XIX),WA                                          ; F82CE0  94 f8
	jr z, .LF82CE6                                       ; F82CE2  66 02
	scf                                                  ; F82CE4  11
	ret                                                  ; F82CE5  0e
.LF82CE6:
	rcf                                                  ; F82CE6  10
	ret                                                  ; F82CE7  0e
; Variant_SendPortBToCpu2: Sends CPU 1's port B byte to CPU 2: Link_SendCommandE1 with source 0x00001F (PB, whose bit
;   0 Variant_SetFromPB0 reads), count 1, CPU-2 destination 0x0000FFF8 -- the byte prom_c sub_F9915C samples once
;   after power-on (bit 0 -> 0x00F35F = 1 / 2, the same encoding Variant_SetFromPB0 gives Variant_Flag).
;   MainTask_Entry calls it after ModuleInit_RunPhase0. Basis: caller + body + CPU-2 reader. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_b8.json)
Variant_SendPortBToCpu2:
	ldw wa, 0xfff8                                       ; F82CE8  30 f8 ff
	extz XWA                                             ; F82CEB  e8 12
	push XWA                                             ; F82CED  38
	pushw 0x01                                           ; F82CEE  0b 01 00
	ldw wa, 0x1f                                         ; F82CF1  30 1f 00
	extz XWA                                             ; F82CF4  e8 12
	push XWA                                             ; F82CF6  38
	call T_Link_SendCommandE1                            ; F82CF7  1d ec 0e f4
	lda xsp, (xsp+0x0a)                                  ; F82CFB  bf 0a 37
	ret                                                  ; F82CFE  0e

; ==============================================================================
; 0xF82CFF-0xF82EA1 -- the interrupt entry points that live in prom_a's low half
; ==============================================================================
; Reached from the vector table at 0xFFFF00 (end of this file).  Everything here
; was converted with prom_a/roundtrip.py, which re-assembles each instruction and
; compares bytes before printing it; the trailing "; ADDR bytes" comment on every
; line is that comparison, kept so a reader can check the decode against unidasm.

; ---------------------------------------------------------------------
; INTWD_Reboot -- watchdog interrupt: restart the machine
;
; Called from: vector slot 0x24 (0xFFFF24 holds 0x00F82CFF)
; Inputs:  none
; Outputs: never returns -- control resumes at RESET, which re-programs every
;          SFR from scratch.  The stack pointer is NOT reset here; RESET does not
;          set one either, so the first stack user is `ld XSP,0x0060EB80` on the
;          far side of the jump into prom_b.
; Evidence: the body is one instruction and it settles the "Reboot" half --
;          `jrl T,RESET` at 0xF82CFF (78 a7 f9), whose displacement resolves
;          to 0xF826A9, which is RESET. The slot binding is emitted as `.long
;          INTWD_Reboot` in the vector table at the end of this file, so the
;          BYTE GATE proves 0xFFFF24 holds this address.
;          ⚠ the "INTWD" half is convention, not a citation -- Notes.
; Notes:   the slot name "INTWD" is the conventional TLCS-900/H order, not a
;          citation (MAME does not name slots below 0x28).  prom_c's 0x24 slot
;          does the same thing, which is corroboration, not proof.
; ---------------------------------------------------------------------
INTWD_Reboot:
	jrl T,RESET                                       ; F82CFF  78 a7 f9

; ---------------------------------------------------------------------
; IRQ_UnusedVector_Hang -- deliberate dead end for every vector not used
;
; Called from: vector slots 0x04-0x18 (SWI1-SWI6) and 0x2C (INT4) land on the
;          seven NOPs at 0xF82D02-0xF82D08 and fall through into the loop;
;          slots 0x38, 0x3C, 0x40, 0x54, 0x58, 0x5C, 0x70 and 0x78 point at
;          0xF82D09 directly.
; Inputs:  none
; Outputs: none -- it never returns and never executes RETI, so the interrupt
;          stays acknowledged and the machine stops.  This is a trap, not a
;          "do nothing" stub, and it is worth knowing when reading a hang.
; Notes:   the seven NOPs are one byte apart because each SWI slot points one
;          byte further along; that is the whole reason they exist.
; ---------------------------------------------------------------------
IRQ_UnusedVector_SWI1:
	nop                                           ; F82D02  00
IRQ_UnusedVector_SWI2:
	nop                                           ; F82D03  00
IRQ_UnusedVector_SWI3:
	nop                                           ; F82D04  00
IRQ_UnusedVector_SWI4:
	nop                                           ; F82D05  00
IRQ_UnusedVector_SWI5:
	nop                                           ; F82D06  00
IRQ_UnusedVector_SWI6:
	nop                                           ; F82D07  00
IRQ_UnusedVector_INT4:
	nop                                           ; F82D08  00
IRQ_UnusedVector_Hang:
	jr T,IRQ_UnusedVector_Hang                                 ; F82D09  68 fe

; ---------------------------------------------------------------------
; INTT1_Tick -- 8-bit timer 1 interrupt: the firmware's periodic time base
;
; Called from: vector slot 0x44 (0xFFFF44 holds 0x00F82D0B)
; Inputs:  the RAM state below
; Outputs: (0x80) long ++, (0x605A00) word ++, (0xA1) saturating counter,
;          transport state bytes (0x94)/(0x95)/(0x96), MIDI real-time transmit
;          requests in (0xA0), and whichever bit of (0x88) the rota clears this
;          tick.  Registers WA and XHL are preserved.
; Evidence: the slot is emitted as `.long INTT1_Tick`, so the byte gate proves
;          0xFFFF44 holds 0xF82D0B. "Periodic time base" is not read off the
;          slot name: the first two memory operations after the pushes are
;          `(0x80) += 1` (0xF82D11) and `(0x605A00) += 1` (0xF82D14), both
;          unconditional and before any branch, so something is counted on
;          every single entry. The second is pinned by
;          notes/prom_a_byte_checks.py ("INTT1_Tick increments (0x605A00) at
;          0xF82D14").
;          ⚠ "INTT1" is the TLCS-900/H slot convention, as for INTWD above.
; Notes:   RESET programs T01MOD/TREG1 and starts timer 1 (TRUN bit 1); the
;          rate that comes out of those two values is worked out in
;          notes/FINDINGS-system-clock.md, not restated here.
;
;          RAM the handler touches, and what can be said about each WITHOUT
;          guessing (all of it is CS1 static RAM -- the 16-bit-direct operands
;          like (0x7F32) are RAM addresses 0x007F32, not the 0x7F0000 port):
;            (0x80)     32-bit, incremented every tick.  A free-running tick
;                       count; nothing here reads it.
;            (0x605A00) 16-bit work-DRAM counter, incremented every tick.
;            (0x9D)/(0x9E) a 0..0x86 counter and a flag byte carried together.
;                       When the counter passes 0x86 it wraps to 0 and requests
;                       (0xA0) bit 4.  135 ticks per wrap -- see below.
;            (0x9C)     counted up while bit 7 of (0x9E) is set, and at 0xA5
;                       rewrites (0x9E) as (0x9E & 0x7F) | 0x20.
;            (0xA1)     saturating counter, stops at 0xF2.
;            (0x88)     bitmap the rota below clears one bit of at a time.
;            (0x94)(0x95)(0x96) three state bytes taking the values 0x01, 0x06,
;                       0x10, 0x86 -- three copies of one small state machine.
;                       Which three things they belong to is NOT established.
;            (0x2078)   compared against 0x0D before any request is posted.
;            (0x7F32)/(0x7F34) bit 2 of each gates the whole transport section.
;
;          ★ THREE OF THOSE ARE NAMED BY THE MIDI HANDLERS, not by this routine
;          -- MIDI_TX_Ready (0xFA542F) and MIDI_RX_Byte (0xFA5496), both
;          converted further down this file:
;            (0xA0) is the MIDI System Real Time TRANSMIT REQUEST bitmap.  The
;                   transmit interrupt turns bit 0 into 0xF8 TIMING CLOCK, bit 1
;                   into 0xFA START, bit 2 into 0xFB CONTINUE, bit 3 into 0xFC
;                   STOP and bit 4 into 0xFE ACTIVE SENSING.  So the two `or
;                   (0xA0),0x08` / `or (0xA0),0x01` sites below are STOP and
;                   TIMING CLOCK, and the 135-tick wrap requests ACTIVE SENSING.
;            (0x9E) bit 7 is set when a 0xFE ACTIVE SENSING is RECEIVED
;                   (0xFA5509), and (0x9C) -- which the receive interrupt zeroes
;                   on every incoming byte (0xFA54AE) -- is therefore the
;                   receive-inactivity timer.  Giving up at 0xA5 = 166 ticks.
;            (0xA1) is the gap between incoming 0xF8 TIMING CLOCK bytes, in
;                   ticks; 0xFA553E turns it into TREG5, the tempo.  That
;                   conversion is lever B of notes/FINDINGS-system-clock.md.
;          At the 488.28 Hz that note derives, 135 ticks is 277 ms and 166 ticks
;          is 340 ms -- one either side of MIDI 1.0's 300 ms active-sensing
;          rule, which is what a correct implementation looks like.
;
;          0xF40724 is a prom_b thunk holding `jp 0xFA590F`; that routine is the
;          work poster -- it either sets (0x77) to 0xDD or, when (0x89) is 0xFF,
;          calls into prom_b and clears (0xA0).  So "or (0xA0),n; call 0xF40724"
;          is "queue this MIDI real-time byte and wake the sender".
; ---------------------------------------------------------------------
INTT1_Tick:
	pushw wa                                      ; F82D0B  28
	push XHL                                      ; F82D0C  3b
	xor XHL,XHL                                   ; F82D0D  eb d3
	inc 1,XHL                                     ; F82D0F  eb 61
	add	(Tick_Count:8), xhl                         ; F82D11  e0 80 8b
	incw 0x01, (Fdc_TickCount:24)                   ; F82D14  d2 00 5a 60 61
	push SR                                       ; F82D19  02
	ei 0x06                                       ; F82D1A  06 06
	ld	a, (MIDI_RX_Flags:8)                               ; F82D1C  c0 9e 21
	ld	w, (0x9d:8)                               ; F82D1F  c0 9d 20
	bit 0x07,A                                    ; F82D22  c9 33 07
	jr Z,.LF82D36                                 ; F82D25  66 0f
	inc	1, (0x9c:8)                           ; F82D27  c0 9c 61
	cp	(0x9c:8), 0xa5                        ; F82D2A  c0 9c 3f a5
	jr ULE,.LF82D36                               ; F82D2E  63 06
	and A,0x7f                                    ; F82D30  c9 cc 7f
	or A,0x20                                     ; F82D33  c9 ce 20
.LF82D36:
	inc 1,W                                       ; F82D36  c8 61
	cp W,0x86                                     ; F82D38  c8 cf 86
	jr ULE,.LF82D47                               ; F82D3B  63 0a
	ld w, 0x00:opc                                   ; F82D3D  20 00
	or	(MidiTx_RealtimePending:8), 0x10                        ; F82D3F  c0 a0 3e 10
	call T_MIDI_PostSendWork                      ; F82D43  1d 24 07 f4
.LF82D47:
	ld	(0x9d:8), w                               ; F82D47  f0 9d 40
	ld	(MIDI_RX_Flags:8), a                               ; F82D4A  f0 9e 41
	pop SR                                        ; F82D4D  03
	ld	a, (0xa1:8)                               ; F82D4E  c0 a1 21
	cp A,0xf1                                     ; F82D51  c9 cf f1
	jr UGT,.LF82D58                               ; F82D54  6b 02
	inc 1,A                                       ; F82D56  c9 61
.LF82D58:
	ld	(0xa1:8), a                               ; F82D58  f0 a1 41
	bit	2, (MidiCfg_ModeBits:16)                        ; F82D5B  f1 32 7f ca
	jr NZ,.LF82DCB                                ; F82D5F  6e 6a
	inc	1, (0x90:8)                           ; F82D61  c0 90 61
	bit	0, (TransportC_State:8)                            ; F82D64  f0 95 c8
	jr NZ,.LF82D9D                                ; F82D67  6e 34
	bit	5, (TransportC_State:8)                            ; F82D69  f0 95 cd
	jr NZ,.LF82D73                                ; F82D6C  6e 05
	ld (0x90:8), 0x00:io                               ; F82D6E  08 90 00
	jr T,.LF82DE5                                 ; F82D71  68 72
.LF82D73:
	cp	(0x90:8), 0x01                        ; F82D73  c0 90 3f 01
	jr NC,.LF82DE5                                ; F82D77  6f 6c
	ld (TransportC_State:8), 0x10:io                               ; F82D79  08 95 10
.LF82D7C:
	cp	(PanelMode:16), 0x0d                     ; F82D7C  c1 78 20 3f 0d
	jr Z,.LF82D9B                                 ; F82D81  66 18
	bit	2, (0x7f34:16)                        ; F82D83  f1 34 7f ca
	jr Z,.LF82D9B                                 ; F82D87  66 12
	bit	2, (MidiCfg_ModeBits:16)                        ; F82D89  f1 32 7f ca
	jr NZ,.LF82D9B                                ; F82D8D  6e 0c
	push SR                                       ; F82D8F  02
	ei 0x06                                       ; F82D90  06 06
	or	(MidiTx_RealtimePending:8), 0x08                        ; F82D92  c0 a0 3e 08
	call T_MIDI_PostSendWork                      ; F82D96  1d 24 07 f4
	pop SR                                        ; F82D9A  03
.LF82D9B:
	jr T,.LF82DE5                                 ; F82D9B  68 48
.LF82D9D:
	cp	(0x90:8), 0x01                        ; F82D9D  c0 90 3f 01
	jr ULE,.LF82DE5                               ; F82DA1  63 42
	ld (TransportC_State:8), 0x06:io                               ; F82DA3  08 95 06
	bit	0, (TransportA_State:8)                            ; F82DA6  f0 94 c8
	jr Z,.LF82DAE                                 ; F82DA9  66 03
	ld (TransportA_State:8), 0x06:io                               ; F82DAB  08 94 06
.LF82DAE:
	bit	0, (TransportB_State:8)                            ; F82DAE  f0 96 c8
	jr Z,.LF82DB6                                 ; F82DB1  66 03
	ld (TransportB_State:8), 0x06:io                               ; F82DB3  08 96 06
.LF82DB6:
	cp	(PanelMode:16), 0x0d                     ; F82DB6  c1 78 20 3f 0d
	jr Z,.LF82DC9                                 ; F82DBB  66 0c
	push SR                                       ; F82DBD  02
	ei 0x06                                       ; F82DBE  06 06
	or	(MidiTx_RealtimePending:8), 0x01                        ; F82DC0  c0 a0 3e 01
	call T_MIDI_PostSendWork                      ; F82DC4  1d 24 07 f4
	pop SR                                        ; F82DC8  03
.LF82DC9:
	jr T,.LF82DE5                                 ; F82DC9  68 1a
.LF82DCB:
	bit	3, (TransportA_State:8)                            ; F82DCB  f0 94 cb
	jr Z,.LF82DD3                                 ; F82DCE  66 03
	ld (TransportA_State:8), 0x10:io                               ; F82DD0  08 94 10
.LF82DD3:
	bit	3, (TransportB_State:8)                            ; F82DD3  f0 96 cb
	jr Z,.LF82DDB                                 ; F82DD6  66 03
	ld (TransportB_State:8), 0x10:io                               ; F82DD8  08 96 10
.LF82DDB:
	bit	3, (TransportC_State:8)                            ; F82DDB  f0 95 cb
	jr Z,.LF82DE5                                 ; F82DDE  66 05
	ld (TransportC_State:8), 0x10:io                               ; F82DE0  08 95 10
	jr T,.LF82D7C                                 ; F82DE3  68 97
.LF82DE5:
	ld	a, (0x86:8)                               ; F82DE5  c0 86 21
	inc 1,A                                       ; F82DE8  c9 61
	cp a, 0x02:i3                                   ; F82DEA  c9 da
	jr ULE,.LF82DF3                               ; F82DEC  63 05
	sub A,A                                       ; F82DEE  c9 a1
	inc	1, (0x87:8)                           ; F82DF0  c0 87 61
.LF82DF3:
	ld	(0x86:8), a                               ; F82DF3  f0 86 41
	sll a, 0x02                                   ; F82DF6  c9 ee 02
	ld XHL,INTT1_Phase_Table                             ; F82DF9  43 05 2e f8 00
	ld xhl,(xhl+a)                                ; F82DFE  e3 03 ec e0 23   ld XHL,(XHL+A) -- the table fetch
	jp (xhl)                                      ; F82E03  b3 d8

; ---------------------------------------------------------------------
; INTT1_Phase_Table -- 3-entry dispatch table for INTT1's tail
;
; Read by:  0xF82DF9 (`ld XHL,INTT1_Phase_Table`), indexed by (0x86)*4.
; Evidence: all three entries are emitted as symbols, so the byte gate checks
;          their addresses. THREE is fixed by the reader, not by inspection:
;          0xF82DE5-0xF82DF6 is `ld A,(0x86) / inc 1,A / cps A,0x02 / jr ULE /
;          sub A,A` and then `sll a,0x02`, so the index can only be 0, 1 or 2
;          and a fourth slot can never be addressed.
; Layout:   3 x LE32 code pointer.  (0x86) counts 0,1,2 and (0x87) is
;           incremented on every wrap, so each phase runs once in three ticks.
; ---------------------------------------------------------------------
INTT1_Phase_Table:
	.long INTT1_Phase0_Idle		; F82E05  11 2e f8 00
	.long INTT1_Phase1_ClearFlags	; F82E09  14 2e f8 00
	.long INTT1_Phase2_Rota		; F82E0D  23 2e f8 00

INTT1_Phase0_Idle:
	jrl T,INTT1_Return                                      ; F82E11  78 88 00
INTT1_Phase1_ClearFlags:
	and	(0x98:8), 0x6e                        ; F82E14  c0 98 3c 6e
	bit	0, (0x87:8)                            ; F82E18  f0 87 c8
	jr NZ,.LF82E20                                ; F82E1B  6e 03
	jrl T,INTT1_Return                                      ; F82E1D  78 7c 00
.LF82E20:
	jrl T,INTT1_Return                                      ; F82E20  78 79 00
INTT1_Phase2_Rota:
	ld	a, (0x87:8)                               ; F82E23  c0 87 21
	and A,0x0f                                    ; F82E26  c9 cc 0f
	sll a, 0x02                                   ; F82E29  c9 ee 02
	ld XHL,INTT1_Rota_Table                             ; F82E2C  43 38 2e f8 00
	ld xhl,(xhl+a)                                ; F82E31  e3 03 ec e0 23   ld XHL,(XHL+A) -- the table fetch
	jp (xhl)                                      ; F82E36  b3 d8

; ---------------------------------------------------------------------
; INTT1_Rota_Table -- 16-entry dispatch table for the (0x88) bit rota
;
; Read by:  0xF82E2C (`ld XHL,INTT1_Rota_Table`), indexed by ((0x87) & 0x0F)*4.
; Evidence: SIXTEEN is fixed by the reader: 0xF82E23 is `ld A,(0x87) / and
;          A,0x0F / sll a,0x02`, so the byte offset formed is 0..60 and a
;          seventeenth slot cannot be addressed. All 16 entries are emitted as
;          symbols, so the byte gate checks every target. "Seven distinct
;          targets" is the count of distinct symbols in the list below, with
;          multiplicities 4 + 4 + 4 + 1 + 1 + 1 + 1 = 16.
; Layout:   16 x LE32 code pointer.  Only seven distinct targets appear; the
;           repetition is the schedule:
;             bit 0 and bit 1 of (0x88) are cleared at slots 0,4,8,12 / 1,5,9,13
;             bit 3 of (0x88) (with bit 6 of (0x98)) at slots 3,7,11,15
;             bits 4,5,6,7 of (0x88) once each, at slots 2,6,10,14
;           i.e. four fast bits and four slow ones, all off the same counter.
; Notes:    what the bits GATE is not established here -- only that the rota
;           clears them and nothing in this handler sets them, so they must be
;           set by whatever consumes them.
; ---------------------------------------------------------------------
INTT1_Rota_Table:
	.long INTT1_Rota_Clear_88_b0		; F82E38  78 2e f8 00
	.long INTT1_Rota_Clear_88_b1		; F82E3C  7d 2e f8 00
	.long INTT1_Rota_Clear_88_b4		; F82E40  8a 2e f8 00
	.long INTT1_Rota_Clear_98_b6_88_b3	; F82E44  82 2e f8 00
	.long INTT1_Rota_Clear_88_b0		; F82E48  78 2e f8 00
	.long INTT1_Rota_Clear_88_b1		; F82E4C  7d 2e f8 00
	.long INTT1_Rota_Clear_88_b5		; F82E50  8f 2e f8 00
	.long INTT1_Rota_Clear_98_b6_88_b3	; F82E54  82 2e f8 00
	.long INTT1_Rota_Clear_88_b0		; F82E58  78 2e f8 00
	.long INTT1_Rota_Clear_88_b1		; F82E5C  7d 2e f8 00
	.long INTT1_Rota_Clear_88_b6		; F82E60  94 2e f8 00
	.long INTT1_Rota_Clear_98_b6_88_b3	; F82E64  82 2e f8 00
	.long INTT1_Rota_Clear_88_b0		; F82E68  78 2e f8 00
	.long INTT1_Rota_Clear_88_b1		; F82E6C  7d 2e f8 00
	.long INTT1_Rota_Clear_88_b7		; F82E70  99 2e f8 00
	.long INTT1_Rota_Clear_98_b6_88_b3	; F82E74  82 2e f8 00


; ---------------------------------------------------------------------
; INTT1_Rota_Clear_* / INTT1_Return -- the rota's seven leaves and the exit
;
; Called from: INTT1_Rota_Table only.
; Inputs:  none
; Outputs: clears one bit of (0x88) -- and, on the 0x98 leaf, bit 6 of (0x98)
;          as well.
; Notes:   INTT1_Return pops the two registers the handler saved and jumps to
;          0xF42D68, a prom_b thunk holding `jp 0xF857B7` = IRQ_Epilogue, the
;          one place this firmware decides whether an interrupt return should
;          also reschedule.  See the kernel block at 0xF856EC.
; ---------------------------------------------------------------------
INTT1_Rota_Clear_88_b0:
	res	0, (0x88:8)                            ; F82E78  f0 88 b0
	jr T,INTT1_Return                                 ; F82E7B  68 1f
INTT1_Rota_Clear_88_b1:
	res	1, (0x88:8)                            ; F82E7D  f0 88 b1
	jr T,INTT1_Return                                 ; F82E80  68 1a
INTT1_Rota_Clear_98_b6_88_b3:
	res	6, (0x98:8)                            ; F82E82  f0 98 b6
	res	3, (0x88:8)                            ; F82E85  f0 88 b3
	jr T,INTT1_Return                                 ; F82E88  68 12
INTT1_Rota_Clear_88_b4:
	res	4, (0x88:8)                            ; F82E8A  f0 88 b4
	jr T,INTT1_Return                                 ; F82E8D  68 0d
INTT1_Rota_Clear_88_b5:
	res	5, (0x88:8)                            ; F82E8F  f0 88 b5
	jr T,INTT1_Return                                 ; F82E92  68 08
INTT1_Rota_Clear_88_b6:
	res	6, (0x88:8)                            ; F82E94  f0 88 b6
	jr T,INTT1_Return                                 ; F82E97  68 03
INTT1_Rota_Clear_88_b7:
	res	7, (0x88:8)                            ; F82E99  f0 88 b7
INTT1_Return:
	pop XHL                                       ; F82E9C  5b
	popw wa                                       ; F82E9D  48
	jp T_IRQ_Epilogue                             ; F82E9E  1b 68 2d f4

; ==============================================================================
; 0xF82EA2-0xF8306D -- INTTR4: the sequencer tick, and the event-buffer append
; ==============================================================================

; ---------------------------------------------------------------------
; INTTR4_SequencerTick -- 16-bit timer 4 interrupt: the musical time base
;
; Called from: vector slot 0x50 (0xFFFF50 holds 0x00F82EA2)
; Inputs:  the transport state bytes (0x94)/(0x95)/(0x96), each of which the
;          MIDI receive path and INTT1_Tick also write; TREG5, which the tempo
;          setter at 0xFAA373 and the MIDI-clock tracker at 0xFA553E both write.
; Outputs: three tick/beat/bar counters advanced, MIDI real-time bytes queued in
;          (0xA0), the countdown at (0xC2) decremented, and -- when transport B
;          wraps a beat and (0x3004) is non-zero -- a byte appended to the event
;          ring buffer.  WA, XHL and XIY are preserved; it exits through the
;          shared epilogue at 0xF42D68 rather than RETI.
;
; Evidence: the slot is emitted as `.long INTTR4_SequencerTick`, so the byte
;          gate proves 0xFFFF50 holds 0xF82EA2. "Musical time base" is
;          arithmetic in the body: FOUR separate wrap tests against 0x60 = 96
;          (0xF82EB1, 0xF82ECD, 0xF82EE2, 0xF82F0D) and the MIDI-clock gate
;          `ld A,(0x8D) / and A,0x03` at 0xF82FDF, with 96 / 4 = 24 = MIDI
;          1.0's Timing Clocks per quarter note. The third, independent
;          agreement (the tempo setter) is spelled out above.
; ★ 96 TICKS PER BEAT, and it is cross-checked twice:
;     * every one of the four counters here wraps at 0x60 = 96;
;     * the MIDI clock is emitted when (0x8D) mod 4 == 0 (0xF82FDF), and
;       96 / 4 = 24, which is exactly MIDI 1.0's 24 Timing Clocks per quarter
;       note.  Two unrelated constants agreeing on the same beat length.
;     * the runtime tempo setter computes TREG5 = 140,000,000 / (64 * BPM)
;       (notes/FINDINGS-system-clock.md); with timer 4 on phiT1 = fc/8 and
;       fc = 28 MHz that is 2,187,500 / BPM, i.e. 96 ticks per beat.  Third
;       agreement, from a completely different routine.
;
; THREE TRANSPORTS, NOT ONE.  (0x94), (0x95) and (0x96) are three copies of the
; same state byte, each with its own tick/beat pair:
;     (0x94)  ticks (0x8B), beats (0x8C), bars (0x605002), bar length (0x605000)
;     (0x95)  ticks (0x8D), beats (0x8E)          -- also the MIDI clock source
;     (0x96)  ticks (0x93), beats (0x91)          -- also drives the event buffer
; ⚠ WHICH THREE THINGS they are (song / pattern / metronome? recorder / player /
; external sync?) is NOT established.  What IS established is that all three obey
; the same bit layout: bit 2 = running, bit 3 and bit 0 appear as edge triggers,
; and the values written are 0x01, 0x06, 0x08, 0x10 and 0x86.
;
; (0xA6)/(0xA7) with (0xA8) bits 0 and 3 are a pair of SCHEDULED TICKS: when
; transport B's tick reaches one of them and the matching arm bit is set, (0x94)
; is forced to 0x01 or 0x08 and the arm bit is cleared.  That is a one-shot
; "change state at tick N" mechanism.
;
; (0x7F32) bit 2 replaces the whole handler with the one at 0xF83120 -- the two
; are alternates, not a fast path.  The same bit gates INTT1_Tick's transport
; section, so it is a mode selector for the machine as a whole.  Not identified.
; ---------------------------------------------------------------------
INTTR4_SequencerTick:
	pushw wa                                      ; F82EA2  28
	push XHL                                      ; F82EA3  3b
	push XIY                                      ; F82EA4  3d
	ld XIY,SeqBuf_Ring                             ; F82EA5  45 14 0a 60 00   XIY = the event ring buffer's body; its header is at XIY-4
	ld XHL,0x00000084                             ; F82EAA  43 84 00 00 00
	incm8 0x01, (xhl)                             ; F82EAF  83 61   (0x84) = the free-running 96-per-beat tick
	cp (XHL),0x60                                 ; F82EB1  83 3f 60   0x60 = 96
	jr c, .LF82EB9                                ; F82EB4  67 03
	ld (XHL),0x00                                 ; F82EB6  b3 00 00
.LF82EB9:
	bit	2, (MidiCfg_ModeBits:16)                        ; F82EB9  f1 32 7f ca   whatever (0x7F32) bit 2 selects, it swaps the whole handler out
	jr z, .LF82EC3                                ; F82EBD  66 04
	jp INTTR4_SequencerTick_Alt                                   ; F82EBF  1b 20 31 f8
.LF82EC3:
	bit	2, (TransportC_State:8)                            ; F82EC3  f0 95 ca   transport C running?
	jr z, .LF82EDA                                ; F82EC6  66 12
	ld	a, (TransportC_Tick:8)                               ; F82EC8  c0 8d 21
	inc 1,A                                       ; F82ECB  c9 61   (0x8D) = its tick, 0..95
	cp A,0x60                                     ; F82ECD  c9 cf 60
	jr lt, .LF82ED7                               ; F82ED0  61 05
	xor A,A                                       ; F82ED2  c9 d1
	incw	1, (TransportC_Beat:8)                           ; F82ED4  d0 8e 61   (0x8E) = its beat, 16-bit
.LF82ED7:
	ld	(TransportC_Tick:8), a                               ; F82ED7  f0 8d 41
.LF82EDA:
	bit	2, (TransportA_State:8)                            ; F82EDA  f0 94 ca   transport A running?
	jr z, .LF82F05                                ; F82EDD  66 26
	inc	1, (TransportA_Tick:8)                           ; F82EDF  c0 8b 61   (0x8B) = its tick, 0..95
	cp	(TransportA_Tick:8), 0x60                        ; F82EE2  c0 8b 3f 60
	jr c, .LF82F05                                ; F82EE6  67 1d
	ld (TransportA_Tick:8), 0x00:io                               ; F82EE8  08 8b 00
	inc	1, (TransportA_Beat:8)                           ; F82EEB  c0 8c 61   (0x8C) = its beat
	ld	a, (TransportA_Beat:8)                               ; F82EEE  c0 8c 21
	ld w, (TransportA_BeatsPerBar:24)                          ; F82EF1  c2 00 50 60 20   (0x605000) = beats per bar
	ex	(0xc3:8), w                           ; F82EF6  c0 c3 30
	cp A,W                                        ; F82EF9  c8 f1
	jr c, .LF82F05                                ; F82EFB  67 08
	ld (TransportA_Beat:8), 0x00:io                               ; F82EFD  08 8c 00
	inc 0x01, (TransportA_Bar:24)                    ; F82F00  c2 02 50 60 61   (0x605002) = the bar counter, 16-bit
.LF82F05:
	bit	2, (TransportB_State:8)                            ; F82F05  f0 96 ca   transport B running?
	jr z, .LF82F24                                ; F82F08  66 1a
	inc	1, (Seq_BeatTick:8)                           ; F82F0A  c0 93 61   (0x93) = its tick
	cp	(Seq_BeatTick:8), 0x60                        ; F82F0D  c0 93 3f 60
	jr lt, .LF82F24                               ; F82F11  61 11
	ld (Seq_BeatTick:8), 0x00:io                               ; F82F13  08 93 00
	incw	1, (TransportB_Beat:8)                           ; F82F16  d0 91 61
	xor XHL,XHL                                   ; F82F19  eb d3
	cp (0x3004:16), xhl                          ; F82F1B  e1 04 30 fb
	jr z, .LF82F24                                ; F82F1F  66 03
	calr SeqBuf_AppendMarker                                 ; F82F21  1e 10 01
.LF82F24:
	bit	2, (TransportC_State:8)                            ; F82F24  f0 95 ca
	jr z, .LF82F3B                                ; F82F27  66 12
	bit	0, (TransportA_State:8)                            ; F82F29  f0 94 c8
	jr z, .LF82F31                                ; F82F2C  66 03
	ld (TransportA_State:8), 0x06:io                               ; F82F2E  08 94 06
.LF82F31:
	bit	0, (TransportB_State:8)                            ; F82F31  f0 96 c8
	jr z, .LF82F39                                ; F82F34  66 03
	ld (TransportB_State:8), 0x06:io                               ; F82F36  08 96 06
.LF82F39:
	jr .LF82F8B                                   ; F82F39  68 50
.LF82F3B:
	bit	7, (TransportA_State:8)                            ; F82F3B  f0 94 cf
	jr z, .LF82F8B                                ; F82F3E  66 4b
	bit	2, (TransportA_State:8)                            ; F82F40  f0 94 ca
	jr z, .LF82F88                                ; F82F43  66 43
	cp	(TransportA_Tick:8), 0x5f                        ; F82F45  c0 8b 3f 5f
	jr c, .LF82F86                                ; F82F49  67 3b
	cp	(TransportA_Bar:24), 0x01                   ; F82F4B  c2 02 50 60 3f 01
	jr c, .LF82F86                                ; F82F51  67 33
	ld a, (TransportA_BeatsPerBar:24)                          ; F82F53  c2 00 50 60 21
	dec 1,A                                       ; F82F58  c9 69
	cp	(TransportA_Beat:8), a                           ; F82F5A  c0 8c f9
	jr c, .LF82F86                                ; F82F5D  67 27
	ld a, 0x01:opc                                   ; F82F5F  21 01
	ld	(TransportC_State:8), a                               ; F82F61  f0 95 41
	ld	(TransportB_State:8), a                               ; F82F64  f0 96 41
	cp	(PanelMode:16), 0x0d                     ; F82F67  c1 78 20 3f 0d
	jr z, .LF82F86                                ; F82F6C  66 18
	bit	2, (0x7f34:16)                        ; F82F6E  f1 34 7f ca
	jr z, .LF82F86                                ; F82F72  66 12
	bit	2, (MidiCfg_ModeBits:16)                        ; F82F74  f1 32 7f ca
	jr nz, .LF82F86                               ; F82F78  6e 0c
	push SR                                       ; F82F7A  02
	ei 0x06                                       ; F82F7B  06 06
	or	(MidiTx_RealtimePending:8), 0x02                        ; F82F7D  c0 a0 3e 02
	call T_MIDI_PostSendWork                      ; F82F81  1d 24 07 f4
	pop SR                                        ; F82F85  03
.LF82F86:
	jr .LF82F8B                                   ; F82F86  68 03
.LF82F88:
	ld (TransportA_State:8), 0x86:io                               ; F82F88  08 94 86
.LF82F8B:
	bit	3, (TransportC_State:8)                            ; F82F8B  f0 95 cb
	jr z, .LF82FCA                                ; F82F8E  66 3a
	ld	a, (TransportC_Tick:8)                               ; F82F90  c0 8d 21
	cp a, 0x00:i3                                   ; F82F93  c9 d8
	jr z, .LF82FA8                                ; F82F95  66 11
	cp A,0x18                                     ; F82F97  c9 cf 18
	jr z, .LF82FA8                                ; F82F9A  66 0c
	cp A,0x30                                     ; F82F9C  c9 cf 30
	jr z, .LF82FA8                                ; F82F9F  66 07
	cp A,0x48                                     ; F82FA1  c9 cf 48
	jr z, .LF82FA8                                ; F82FA4  66 02
	jr .LF82FDA                                   ; F82FA6  68 32
.LF82FA8:
	ld (TransportC_State:8), 0x10:io                               ; F82FA8  08 95 10
	cp	(PanelMode:16), 0x0d                     ; F82FAB  c1 78 20 3f 0d
	jr z, .LF82FCA                                ; F82FB0  66 18
	bit	2, (0x7f34:16)                        ; F82FB2  f1 34 7f ca
	jr z, .LF82FCA                                ; F82FB6  66 12
	bit	2, (MidiCfg_ModeBits:16)                        ; F82FB8  f1 32 7f ca
	jr nz, .LF82FCA                               ; F82FBC  6e 0c
	push SR                                       ; F82FBE  02
	ei 0x06                                       ; F82FBF  06 06
	or	(MidiTx_RealtimePending:8), 0x08                        ; F82FC1  c0 a0 3e 08   queue 0xFC STOP
	call T_MIDI_PostSendWork                      ; F82FC5  1d 24 07 f4
	pop SR                                        ; F82FC9  03
.LF82FCA:
	bit	3, (TransportA_State:8)                            ; F82FCA  f0 94 cb
	jr z, .LF82FD2                                ; F82FCD  66 03
	ld (TransportA_State:8), 0x10:io                               ; F82FCF  08 94 10
.LF82FD2:
	bit	3, (TransportB_State:8)                            ; F82FD2  f0 96 cb
	jr z, .LF82FDA                                ; F82FD5  66 03
	ld (TransportB_State:8), 0x10:io                               ; F82FD7  08 96 10
.LF82FDA:
	bit	2, (TransportC_State:8)                            ; F82FDA  f0 95 ca
	jr z, .LF82FFA                                ; F82FDD  66 1b
	ld	a, (TransportC_Tick:8)                               ; F82FDF  c0 8d 21   (0x8D) mod 4 -- 96 ticks/beat / 4 = 24, the MIDI clock rate
	and A,0x03                                    ; F82FE2  c9 cc 03
	jr nz, .LF82FFA                               ; F82FE5  6e 13
	cp	(PanelMode:16), 0x0d                     ; F82FE7  c1 78 20 3f 0d
	jr z, .LF82FFA                                ; F82FEC  66 0c
	push SR                                       ; F82FEE  02
	ei 0x06                                       ; F82FEF  06 06
	or	(MidiTx_RealtimePending:8), 0x01                        ; F82FF1  c0 a0 3e 01   queue 0xF8 TIMING CLOCK
	call T_MIDI_PostSendWork                      ; F82FF5  1d 24 07 f4
	pop SR                                        ; F82FF9  03
.LF82FFA:
	bit	2, (TransportB_State:8)                            ; F82FFA  f0 96 ca
	jr z, .LF83024                                ; F82FFD  66 25
	ld	a, (Seq_BeatTick:8)                               ; F82FFF  c0 93 21
	bit	3, (0xa8:8)                            ; F83002  f0 a8 cb
	jr z, .LF83013                                ; F83005  66 0c
	cp	(0xa7:8), a                           ; F83007  c0 a7 f9   a scheduled tick for transport A, armed by (0xA8) bit 3
	jr nz, .LF83013                               ; F8300A  6e 07
	ld (TransportA_State:8), 0x08:io                               ; F8300C  08 94 08
	and	(0xa8:8), 0xf7                        ; F8300F  c0 a8 3c f7
.LF83013:
	bit	0, (0xa8:8)                            ; F83013  f0 a8 c8
	jr z, .LF83024                                ; F83016  66 0c
	cp	(0xa6:8), a                           ; F83018  c0 a6 f9   a scheduled tick for transport A, armed by (0xA8) bit 0
	jr nz, .LF83024                               ; F8301B  6e 07
	ld (TransportA_State:8), 0x01:io                               ; F8301D  08 94 01
	and	(0xa8:8), 0xfe                        ; F83020  c0 a8 3c fe
.LF83024:
	cp	(MainTask_TickCountdown:8), 0x00                        ; F83024  c0 c2 3f 00   (0xC2) is a plain countdown, decremented once per tick
	jr z, INTTR4_Return                                ; F83028  66 03
	dec	1, (MainTask_TickCountdown:8)                           ; F8302A  c0 c2 69
INTTR4_Return:
	pop XIY                                       ; F8302D  5d
	pop XHL                                       ; F8302E  5b
	popw wa                                       ; F8302F  48
	jp T_IRQ_Epilogue                             ; F83030  1b 68 2d f4

; ---------------------------------------------------------------------
; SeqBuf_AppendMarker -- push one 0x81 byte into the event ring buffer
;
; Called from: INTTR4_SequencerTick (0xF82F21), on a transport-B beat wrap when
;          (0x3004) is non-zero.  0xFA56CB is a second, byte-for-byte identical
;          copy of this routine that uses XIX instead of XIY.
; Inputs:  XIY = 0x600A14, the buffer body.  The header sits just below it:
;              (XIY-4) = (0x600A10)  the 16-bit write index
;              (XIY-2) = (0x600A12)  the 16-bit REMAINING SPACE
; Outputs: one byte 0x81 stored, the index advanced modulo 0x200 and the
;          remaining-space count decremented.  When the count is already zero
;          nothing is written -- the buffer drops, it does not wrap over live
;          data.  (0xAC) is reset to 0.
; Evidence: "Marker" is LITERAL -- the value stored is the immediate 0x81 in
;          both arms, `ld (XIY+HL),0x81` at 0xF83044 and `ld
;          (XHL+0x00AE),0x81` at 0xF83062; nothing computes it. "Ring" is
;          `minc1_16 hl,0x01ff` at 0xF8304A, a modular increment by 0x200,
;          together with the `ld WA,(XIY-2) / and WA,WA / jr z` guard at
;          0xF8303A-0xF8303F that DROPS when the space count is zero instead
;          of wrapping over live data.
;          ⚠ what the 0x81 means is not established -- Notes.
; Notes:   `minc1_16 hl, 0x01ff` is the modular increment, and it is what fixes
;          the ring at 512 bytes.
;
;          ⚠ THE SECOND PATH IS A DIFFERENT BUFFER.  If bit 0 of (0xAA) is set,
;          the byte goes to (0x00AE + (0xAC)) instead -- a plain linear array in
;          static RAM indexed by a counter that never wraps, and the ring is left
;          untouched.  A capture/trace mode is the obvious reading, and it is
;          only a reading: nothing here says what consumes either buffer.
;
;          The value stored is the constant 0x81.  What that marker means is NOT
;          established; the neighbouring routine at 0xF830C6 appends a caller-
;          supplied byte followed by the current tick (0x93), so this buffer
;          holds tagged, time-stamped events of some kind.
; ---------------------------------------------------------------------
SeqBuf_AppendMarker:
	bit	0, (SeqBuf_Flags:8)                            ; F83034  f0 aa c8
	jr nz, SeqBuf_AppendMarker__trace                               ; F83037  6e 24
	pushw wa                                      ; F83039  28
	ld wa, (xiy-2)                                ; F8303A  9d fe 20
	and WA,WA                                     ; F8303D  d8 c0
	jr z, SeqBuf_AppendMarker__full                                ; F8303F  66 15
	ld hl, (xiy-4)                                ; F83041  9d fc 23
	ld	(xiy+hl), 0x81                        ; F83044  f3 07 f4 ec 00 81
	minc1_16 hl, 0x01ff                           ; F8304A  db 38 ff 01   wrap HL modulo 0x200: the ring is 512 bytes
	dec 1,WA                                      ; F8304E  d8 69
	ld (xiy-4), hl                                ; F83050  bd fc 53
	ld (xiy-2), wa                                ; F83053  bd fe 50
SeqBuf_AppendMarker__full:
	popw wa                                       ; F83056  48
	ldw (SeqBuf_StagedCount:8), 0x00:io                              ; F83057  0a ac 00 00
	jr SeqBuf_AppendMarker__done                                   ; F8305B  68 10
SeqBuf_AppendMarker__trace:
	ld	hl, (SeqBuf_StagedCount:8)                          ; F8305D  d0 ac 23
	extz XHL                                      ; F83060  eb 12
	ld (XHL+0x00ae),0x81                          ; F83062  f3 ed ae 00 00 81
	inc 1,HL                                      ; F83068  db 61
	ld	(SeqBuf_StagedCount:8), hl                              ; F8306A  f0 ac 53
SeqBuf_AppendMarker__done:
	ret                                           ; F8306D  0e

; ==============================================================================
; 0xF8306E-0xF830C5 -- NMI: the power-fail handler, and its checksum helper
; ==============================================================================

; ---------------------------------------------------------------------
; NMI_PowerFail_SaveAndHalt -- last rites when the supply starts to fall
;
; Called from: vector slot 0x20 (0xFFFF20 holds 0x00F8306E).  0x20 is the one
;          slot MAME does name for this part -- NMI, tmp95c061.cpp:505.
; Inputs:  bit 1 of (0x97) -- when clear, the save is skipped entirely and the
;          machine goes straight to the halt below.
; Outputs: two checksums written to (0x7FD2) and (0x7FD4); (0x7FC7) and
;          (0x7FCA) zeroed; DMEMCR rewritten; P6 bit 5 and P7 bits 4-5 driven;
;          the CPU halted.  It never returns.
; Evidence: the slot is emitted as `.long NMI_PowerFail_SaveAndHalt`, so the
;          byte gate proves 0xFFFF20 -- and unlike INTWD the slot NAME is a
;          citation too: 0x20 is NMI in MAME's own table (tmp95c061.cpp:505).
;          "SaveAndHalt" is the body: two 512-byte blocks check-summed and
;          stored (0xF83086-0xF8309F), DMEMCR (SFR 0x5B) rewritten to 0x2D at
;          0xF830AC, and `halt` at 0xF830B3 inside a `jr` back to itself -- a
;          stop that re-stops if anything wakes it.
;          ⚠ "PowerFail" is the READING of that shape, not a citation. See
;          Notes.
; Notes:   the shape of this routine is what identifies it, not a string:
;            * it drives two port pins, then makes a service call and two
;              cross-ROM calls -- the orderly-shutdown notifications;
;            * it check-sums two blocks and stores the results;
;            * it rewrites DMEMCR (0x5B) from the 0x8D that RESET programmed to
;              0x2D and sets bit 5 of P6, then HALTs in a loop that re-halts
;              if anything wakes it.  P6 is the port carrying RAS/REFOUT
;              (tmp95c061.h:19), so this is putting the work DRAM into a
;              self-sustaining refresh and stopping the core.  The exact DMEMCR
;              field that changes is NOT established -- MAME stores the register
;              and decodes nothing (tmp95c061.cpp:1353).
;
;          THE TWO CHECKSUMMED BLOCKS, and why they matter:
;            0x007620 for 512 bytes -> checksum word at 0x007FD2
;            0x617800 for 512 bytes -> checksum word at 0x007FD4
;          The first is CS1 static RAM, the second is work DRAM inside the
;          0x617800 record array that the memory-map note already records.  A
;          checksum taken at power-down over exactly these two blocks is how a
;          machine decides at the next power-up whether its retained settings
;          survived; the KN5000 does the same thing with its own power-fail
;          area (see the sibling project's notes).  ⚠ That is the SHAPE of the
;          mechanism.  This routine only writes the checksums -- the code that
;          verifies them at boot has not been traced yet, so "battery-backed"
;          is NOT established here.
;
;          `swi 7` with A = 0x0C, C = 0 is a service call: the SWI7 vector
;          reaches SWI7_ServiceCall_Dispatch (0xF8E9A5, converted below), which
;          indexes SWI7_ServiceTable with A & 0x3F.  Slot 0x0C is 0xF8F7B8.
;          0xF4030C and 0xF40A28 are prom_b thunks, holding `jp 0xFE8005` and
;          `jp 0xF45D09`.
; ---------------------------------------------------------------------
NMI_PowerFail_SaveAndHalt:
	set	5, (P7:8)                            ; F8306E  f0 13 bd
	set	4, (P7:8)                            ; F83071  f0 13 bc
	xor C,C                                       ; F83074  cb d3
	ld a, 0x0c:opc                                   ; F83076  21 0c
	swi 7                                         ; F83078  ff
	bit	1, (0x97:8)                            ; F83079  f0 97 c9
	jr z, NMI_PowerFail__stop                                ; F8307C  66 22
	call T_PowerFail_PrepareSongWorkspace                                 ; F8307E  1d 0c 03 f4
	call T_SeqRecord_TerminateTracksIfRecording                                 ; F83082  1d 28 0a f4
	ld XIY,Combination_Current                             ; F83086  45 20 76 00 00
	ld XIX,0x00007fd2                             ; F8308B  44 d2 7f 00 00
	calr PowerFail_Checksum512                                 ; F83090  1e 23 00
	ld XIY,0x00617800                             ; F83093  45 00 78 61 00
	ld XIX,0x00007fd4                             ; F83098  44 d4 7f 00 00
	calr PowerFail_Checksum512                                 ; F8309D  1e 16 00
NMI_PowerFail__stop:
	xor WA,WA                                     ; F830A0  d8 d0
	ld (0x7fc7:16), a                            ; F830A2  f1 c7 7f 41
	ld (0x7fca:16), wa                           ; F830A6  f1 ca 7f 50
	ei 0x07                                       ; F830AA  06 07
	ld (DMEMCR:8), 0x2d:io                               ; F830AC  08 5b 2d
	nop                                           ; F830AF  00
	set	5, (P6:8)                            ; F830B0  f0 12 bd
NMI_PowerFail__halt:
	halt                                          ; F830B3  05
	jr NMI_PowerFail__halt                                   ; F830B4  68 fd

; ---------------------------------------------------------------------
; PowerFail_Checksum512 -- 16-bit ones-complement sum of 512 bytes
;
; NAME NOTE: called NVRAM_Checksum512 until 2026-08-24. Renamed because the header
; below states the boot-time verification has NOT been traced, so "NVRAM" asserted
; non-volatility this tree has not established. Labels get grepped and propagate;
; headers do not. This project has already had to retract a persisted-RAM claim once.
;
; Called from: NMI_PowerFail_SaveAndHalt, twice (0xF83090, 0xF8309D)
; Inputs:  XIY = first byte of the block; XIX = where to put the result
; Outputs: (XIX) = NOT (sum of the 256 little-endian words at XIY).  XIY is left
;          past the end of the block; WA and BC are clobbered.
; Evidence: "512" is literal: `ldw bc,0x0100` at 0xF830B6 is 256 iterations and
;          `add_spiw wa,0xf5` is `add WA,(XIY+)`, a WORD post-increment, so
;          256 x 2 = 512 bytes. "Ones-complement" is `cpl WA` at 0xF830C1,
;          immediately before the `ld (XIX),WA` store. Both callers hand it a
;          512-byte block -- 0x007620 and 0x617800, set up at 0xF83086 and
;          0xF83093.
; Notes:   `add_spiw wa, 0xf5` is `add WA,(XIY+)` -- 0xF5 is the register-address
;          byte for XIY with a post-increment of 2 (the same encoding the RESET
;          block documents as MEM_XIX_PI4 for XIX/+4; see
;          include/tmp95c061_sfr.inc).  256 words x 2 = 512 bytes.
; ---------------------------------------------------------------------
PowerFail_Checksum512:
	ldw bc, 0x0100                                ; F830B6  31 00 01
	xor WA,WA                                     ; F830B9  d8 d0
PowerFail_Checksum512__loop:
	add wa, (xiy+)                             ; F830BB  d5 f5 80
	djnz16 bc, PowerFail_Checksum512__loop                           ; F830BE  d9 1c fa
	cpl WA                                        ; F830C1  d8 06
	ld (XIX),WA                                   ; F830C3  b4 50
	ret                                           ; F830C5  0e

; ==============================================================================
; 0xF830C6-0xF855FF -- the sequencer event append, the 0x7F0000 slot driver, and
; CPU 1's BYTE RING-BUFFER LIBRARY
; ==============================================================================
;
; This whole span was one `.incbin` until 2026-08-25.  It is three things:
;
;   0xF830C6-0xF83215   336  three routines that belong with the 0xF82Cxx
;                            interrupt block above: the sequencer event append,
;                            the alternate INTTR4 tail, and the driver for the
;                            0x7F0000 address/data register pair
;   0xF83216-0xF83FFF  3562  0x0E pad
;   0xF84000-0xF84C6B  3180  the ring-buffer CLASS (25 routines) and its
;                            INSTANCE BANK (15 groups of 11 veneers)
;   0xF84C6C-0xF855FF  2452  0x0E pad
;
; Why this span and not another: notes/prom_a_call_graph.py --modules ranks the
; prom_b directory module T_Ring608A0A_Get (T_F41CD0)-T_Ring601C6E_GetCommit (T_F41EC4) (126 slots, reference upper bound
; 245) as the largest heavily-referenced prom_a module still unconverted, and
; all 126 of its slots land in 0xF842DF-0xF84BBC.
;
; The structural facts below are all re-derived from the ROM by
; `python3 notes/prom_a_ringbuf_map.py`, which prints its own check list; the
; assembly is emitted by `python3 notes/gen_prom_a_ringbuf_module.py`.
; Prose: notes/FINDINGS-prom_a-ring-buffers.md.
; ---------------------------------------------------------------------
; SeqBuf_AppendEvent -- push <caller's byte><current tick> into the event ring
;
; Called from: NOTHING NAMES IT.  notes/prom_a_ringbuf_map.py resolves every
;          absolute `call`/`jp` and every PC-relative `calr`/`jr`/`jrl` in
;          prom_a + prom_b and finds no site whose target is 0xF830C6, and no
;          prom_b directory slot points here either.  0xF830C5 is the `ret` of
;          PowerFail_Checksum512, so it is not reached by fall-through.  Either
;          it is called through a pointer held in a register or it is dead; this
;          tree has NOT established which.
; Inputs:  A = the event byte.  (0x93) = the current tick, appended after it.
;          (0xAA) bit 0 selects the trace path, exactly as in
;          SeqBuf_AppendMarker above.
; Outputs: two bytes appended to the 512-byte ring at 0x600A14 and its write
;          index and free count updated; or, on the trace path, two bytes
;          appended to the linear array at 0x00AE.  (0xAC) is the trace index
;          and is reset to 0 on the ring path.
; Evidence: it is the SAME BUFFER as SeqBuf_AppendMarker -- `ld XIY,0x00600A14`
;          at 0xF830D5, the write index at (XIY-4) = (0x600A10), the free count
;          at (XIY-2) = (0x600A12) and `minc1_16 hl,0x01ff`, the modular
;          increment that fixes the ring at 512 bytes.  What distinguishes this
;          routine from the marker one is that it stores TWO bytes, the
;          caller's A and then `ld A,(0x93)`, and decrements the free count
;          twice.
;          0x600A14 is also ring 5 of the instance bank below, and that
;          independently gives it capacity 0x200: every one of its nine
;          published veneers calls a 0x200-capacity class routine
;          (notes/prom_a_ringbuf_map.py, check "every instance names ONE
;          capacity").
; ★ RETRACTED, 2026-08-25 (round-2 audit, F1).  This header said 0xFA570C was
;          "a NEAR-TWIN of this routine" that "differ[s], in the guard, by ONE
;          BYTE".  That is FALSE and the follow-on sentence -- "which was
;          intended is not established" -- only made sense under it.  Measured:
;          75 of the 90 positional bytes differ, and the common prefix is FOUR
;          bytes (`f0 aa c8` and the opcode byte of the `jr NZ`, whose
;          displacement already differs).  This routine is 28 instructions over
;          0xF830C6-0xF8311F; 0xFA570C is 27 over 0xFA570C-0xFA5762.  They are
;          two INDEPENDENTLY WRITTEN routines that share an algorithm and a
;          buffer, not one routine with a typo.  Re-derived by
;          notes/prom_a_byte_checks.py, checks named "SeqBuf twins:".
;          What they actually do differently:
;            base register     XIY throughout      | XIX throughout
;            critical section  push XIY .. pop XIY | push SR / ei 0x06 .. pop SR
;            free count        decw 1,(XIY+0xfe)   | decw 2,(XIX+0xfe) once
;                              TWICE               |
;            write cursor      ld (0x600a10),HL    | ld (XIX+0xfc),HL
;                              (absolute)          | (indexed; SAME cell)
;            trace path        extz XHL, XHL-rel,  | ld XIX,0x000000ae, XIX-rel,
;                              (0x93) loaded TWICE | (0x93) loaded once
;                              (2nd load is dead)  |
;          WHAT SURVIVES, and is still checked: both append two bytes to the
;          SAME 512-byte ring 0x600A14, both net-decrement the free count by 2,
;          and their guards read DIFFERENT cells of that ring's control block --
;          0x600A12 is the free count the class's own Put tests, 0x600A0C is the
;          READ cursor (§1 of notes/FINDINGS-prom_a-ring-buffers.md gives the
;          field layout).  A guard on the read cursor is not a bounds test on
;          free space; whether that is a defect is NOT established here.
; ---------------------------------------------------------------------
SeqBuf_AppendEvent:
	bit	0, (SeqBuf_Flags:8)                                   ; F830C6  f0 aa c8
	jr nz, SeqBuf_AppendEvent__trace                     ; F830C9  6e 38
	cpw	(SeqBuf_RingFree:24), 0x0002                        ; F830CB  d2 12 0a 60 3f 02 00
	jr c, SeqBuf_AppendEvent__drop                       ; F830D2  67 2a
	push XIY                                             ; F830D4  3d
	ld XIY,SeqBuf_Ring                                    ; F830D5  45 14 0a 60 00
	ld hl, (xiy-4)                                       ; F830DA  9d fc 23
	ld	(xiy+hl), a                                  ; F830DD  f3 07 f4 ec 41
	decm 0x01, (xiy-2)                                   ; F830E2  9d fe 69
	minc1_16 hl, 0x01ff                                  ; F830E5  db 38 ff 01
	ld	a, (Seq_BeatTick:8)                                      ; F830E9  c0 93 21
	ld	(xiy+hl), a                                  ; F830EC  f3 07 f4 ec 41
	minc1_16 hl, 0x01ff                                  ; F830F1  db 38 ff 01
	decm 0x01, (xiy-2)                                   ; F830F5  9d fe 69
	ld (SeqBuf_RingPut:24), hl                                ; F830F8  f2 10 0a 60 53
	pop XIY                                              ; F830FD  5d
SeqBuf_AppendEvent__drop:
	ldw (SeqBuf_StagedCount:8), 0x00:io                                     ; F830FE  0a ac 00 00
	ret                                                  ; F83102  0e
SeqBuf_AppendEvent__trace:
	ld	hl, (SeqBuf_StagedCount:8)                                 ; F83103  d0 ac 23
	extz XHL                                             ; F83106  eb 12
	ld (XHL+0x00ae),A                                    ; F83108  f3 ed ae 00 41
	ld	a, (Seq_BeatTick:8)                                      ; F8310D  c0 93 21
	inc 1,HL                                             ; F83110  db 61
	ld (XHL+0x00ae),A                                    ; F83112  f3 ed ae 00 41
	ld	a, (Seq_BeatTick:8)                                      ; F83117  c0 93 21
	inc 1,HL                                             ; F8311A  db 61
	ld	(SeqBuf_StagedCount:8), hl                                     ; F8311C  f0 ac 53
	ret                                                  ; F8311F  0e
; ---------------------------------------------------------------------
; INTTR4_SequencerTick_Alt -- the alternate tail of the sequencer tick handler
;
; Called from: exactly one site, the `jp 0xF83120` at 0xF82EBF, taken when
;          (0x7F32) bit 2 is set.  Re-derived by notes/prom_a_ringbuf_map.py's
;          check "0xF83120 is named exactly once".  It does not return: the
;          `jrl 0xF82FFA` at 0xF8316E rejoins the handler's common exit.
; Inputs:  the transport state bytes (0x94) (0x95) (0x96) and their tick
;          counters (0x8B) (0x8D) (0x93).
; Outputs: each running transport's tick advanced by one, modulo 4; two of the
;          three state bytes forced to 6 under a condition.
; Evidence: the three arms are byte-identical in shape and differ only in which
;          pair of addresses they name -- (0x96)/(0x93), (0x95)/(0x8D),
;          (0x94)/(0x8B) -- which is what makes them three transports rather
;          than three unrelated tests.  The same three state bytes and the same
;          three counters are what the converted INTTR4 block above uses, and
;          `xor A,0x03 / and A,0x03 / jr Z` before `inc 1,(counter)` is a
;          modulo-4 guard, not a comparison against a constant.
; Unknown: what (0x7F32) bit 2 selects, and therefore why there are two tails.
;          The header of the block above already records that the bit "swaps the
;          whole handler out"; this is the half it swaps in.  The value 6 is
;          also unexplained.
; ---------------------------------------------------------------------
INTTR4_SequencerTick_Alt:
	bit	2, (TransportB_State:8)                                   ; F83120  f0 96 ca
	jr z, .LF83133                                       ; F83123  66 0e
	ld	a, (Seq_BeatTick:8)                                      ; F83125  c0 93 21
	xor A,0x03                                           ; F83128  c9 cd 03
	and A,0x03                                           ; F8312B  c9 cc 03
	jr z, .LF83133                                       ; F8312E  66 03
	inc	1, (Seq_BeatTick:8)                                  ; F83130  c0 93 61
.LF83133:
	bit	2, (TransportC_State:8)                                   ; F83133  f0 95 ca
	jr z, .LF83146                                       ; F83136  66 0e
	ld	a, (TransportC_Tick:8)                                      ; F83138  c0 8d 21
	xor A,0x03                                           ; F8313B  c9 cd 03
	and A,0x03                                           ; F8313E  c9 cc 03
	jr z, .LF83146                                       ; F83141  66 03
	inc	1, (TransportC_Tick:8)                                  ; F83143  c0 8d 61
.LF83146:
	bit	2, (TransportA_State:8)                                   ; F83146  f0 94 ca
	jr z, .LF83159                                       ; F83149  66 0e
	ld	a, (TransportA_Tick:8)                                      ; F8314B  c0 8b 21
	xor A,0x03                                           ; F8314E  c9 cd 03
	and A,0x03                                           ; F83151  c9 cc 03
	jr z, .LF83159                                       ; F83154  66 03
	inc	1, (TransportA_Tick:8)                                  ; F83156  c0 8b 61
.LF83159:
	bit	2, (TransportC_State:8)                                   ; F83159  f0 95 ca
	jr z, .LF8316E                                       ; F8315C  66 10
	bit	0, (TransportA_State:8)                                   ; F8315E  f0 94 c8
	jr z, .LF83166                                       ; F83161  66 03
	ld (TransportA_State:8), 0x06:io                                      ; F83163  08 94 06
.LF83166:
	bit	0, (TransportB_State:8)                                   ; F83166  f0 96 c8
	jr z, .LF8316E                                       ; F83169  66 03
	ld (TransportB_State:8), 0x06:io                                      ; F8316B  08 96 06
.LF8316E:
	jrl .LF82FFA                                             ; F8316E  78 89 fe
; ---------------------------------------------------------------------
; Dev7F_WriteSlot8_Slot0 .. _Slot3, and Dev7F_WriteSlot8 -- the driver for the
; 0x7F0000 address/data register pair
;
; Called from: the four entries are prom_b directory slots T_Dev7F_WriteSlot8_Slot0 (T_F40004), T_Dev7F_WriteSlot8_Slot1 (T_F40008),
;          T_Dev7F_WriteSlot8_Slot2 (T_F4000C) and T_Dev7F_WriteSlot8_Slot3 (T_F40010) (notes/prom_a_xref.py on each).  The common
;          body 0xF83197 is named by five PC-relative `calr` sites and nothing
;          else -- 0xF8318F, and the four inside sub_F831B3 -- re-derived by
;          notes/prom_a_ringbuf_map.py.
; Inputs:  XHL = an eight-byte block in memory.  W = the slot number, supplied
;          by whichever of the four entry stubs was called.
; Outputs: eight bytes written to the device, one per register.
; Evidence: this is the device notes/FINDINGS-memory-map.md already lists at
;          0x7F0000/0x7F0002 as an "address-register + data-register pair, 8
;          writes per slot, slot = (n<<5) | 0x10" -- and it cites THESE
;          instructions, `0xF8319A ld XIX,0x007F0000`, `0xF831A8 ld (XIX),W`,
;          `0xF831AA ld (XIX+0x02),A`, from a byte census taken while the
;          routine itself was still .incbin.  The arithmetic is `sll 0x05,W`
;          (slot times 32), `or W,0x10` (the block's base offset inside the
;          slot) and `inc 1,W` once per iteration, with `ldw bc,0x0008`
;          iterations; the data comes from `ld A,(XHL+)`, a post-incrementing
;          byte read.
;          The four stubs are the same five instructions with a different `ld
;          W,n` and a `jr` into the shared TAIL at 0xF8318F -- the `calr` into
;          the body plus the four pops -- which is what makes them four entries
;          of one routine and not four routines.  Slot 3's stub falls into that
;          tail instead of jumping to it.
; Unknown: what the device is.  FINDINGS-memory-map.md records that CPU 2 drives
;          0xE00000 with a byte-identical shape and that whether the two are one
;          dual-ported chip is open.
; ---------------------------------------------------------------------
Dev7F_WriteSlot8_Slot0:
	pushw wa                                             ; F83171  28
	push XHL                                             ; F83172  3b
	push XIX                                             ; F83173  3c
	pushw bc                                             ; F83174  29
	xor W,W                                              ; F83175  c8 d0
	jr Dev7F_WriteSlot8__enter                           ; F83177  68 16
Dev7F_WriteSlot8_Slot1:
	pushw wa                                             ; F83179  28
	push XHL                                             ; F8317A  3b
	push XIX                                             ; F8317B  3c
	pushw bc                                             ; F8317C  29
	ld w, 0x01:opc                                          ; F8317D  20 01
	jr Dev7F_WriteSlot8__enter                           ; F8317F  68 0e
Dev7F_WriteSlot8_Slot2:
	pushw wa                                             ; F83181  28
	push XHL                                             ; F83182  3b
	push XIX                                             ; F83183  3c
	pushw bc                                             ; F83184  29
	ld w, 0x02:opc                                          ; F83185  20 02
	jr Dev7F_WriteSlot8__enter                           ; F83187  68 06
Dev7F_WriteSlot8_Slot3:
	pushw wa                                             ; F83189  28
	push XHL                                             ; F8318A  3b
	push XIX                                             ; F8318B  3c
	pushw bc                                             ; F8318C  29
	ld w, 0x03:opc                                          ; F8318D  20 03
Dev7F_WriteSlot8__enter:
	calr Dev7F_WriteSlot8                                ; F8318F  1e 05 00
	popw bc                                              ; F83192  49
	pop XIX                                              ; F83193  5c
	pop XHL                                              ; F83194  5b
	popw wa                                              ; F83195  48
	ret                                                  ; F83196  0e
Dev7F_WriteSlot8:
	sll w, 0x05                                          ; F83197  c8 ee 05
	ld XIX,0x007f0000                                    ; F8319A  44 00 00 7f 00
	ldw bc, 0x08                                         ; F8319F  31 08 00
.LF831A2:
	ld a, (xhl+)                                      ; F831A2  c5 ec 21
	or W,0x10                                            ; F831A5  c8 ce 10
	ld (XIX),W                                           ; F831A8  b4 40
	ld (XIX+0x02),A                                      ; F831AA  bc 02 41
	inc 1,W                                              ; F831AD  c8 61
	djnz16 bc, .LF831A2                                  ; F831AF  d9 1c f0
	ret                                                  ; F831B2  0e
; ---------------------------------------------------------------------
; sub_F831B3 -- writes a fixed pattern to all four 0x7F0000 slots
;
; NAMED sub_XXXXXX ON PURPOSE.  What it writes is plain; what that MEANS is not,
; and this tree prefers an address label with a stated gap to a plausible guess.
;
; Called from: one site, `call 0xF831B3` at prom_a 0xF825E1 -- inside the boot
;          block at 0xF80000-0xF826A8, which is still .incbin, so the calling
;          context is not established.
; Inputs:  none.
; Outputs: four eight-byte blocks written through Dev7F_WriteSlot8, one per
;          slot, followed by four 32-bit writes to the device.
; Evidence: `ld WA,0x0005` and four `pushw wa` build the eight-byte source block
;          on the stack; the four `calr Dev7F_WriteSlot8` calls set W to 0, 1, 2
;          and 3 in turn.  The second phase is a four-iteration loop
;          (`ldw bc,0x0004`) whose register index starts at 0x1F and advances by
;          0x20 (`add W,0x20`), which is the same `(n<<5)|0x10` slot stride the
;          block driver uses, at offset 0x0F inside the slot.
; Unknown: ★ the four `ld XHL,XSP / add XHL,8|6|4|2` sources OVERLAP each other
;          and reach ABOVE the four words this routine pushed.  Read literally,
;          slot 0 is written from XSP+8..XSP+15 and slot 3 from XSP+2..XSP+9,
;          so only the last two slots see the pushed 0x0005 words at all and the
;          first read runs into this routine's own return address.  That is what
;          the bytes say; whether it is a firmware defect or a calling
;          convention this tree has not reconstructed is NOT established, and no
;          claim either way belongs in a name.  The value 0x0005, and the
;          32-bit pattern the second phase assembles out of QW/QA, are also
;          unexplained.
; ---------------------------------------------------------------------
sub_F831B3:
	ldw wa, 0x05                                         ; F831B3  30 05 00
	pushw wa                                             ; F831B6  28
	pushw wa                                             ; F831B7  28
	pushw wa                                             ; F831B8  28
	pushw wa                                             ; F831B9  28
	xor W,W                                              ; F831BA  c8 d0
	ld XHL,XSP                                           ; F831BC  ef 8b
	add XHL,0x00000008                                   ; F831BE  eb c8 08 00 00 00
	calr Dev7F_WriteSlot8                                ; F831C4  1e d0 ff
	ld w, 0x01:opc                                          ; F831C7  20 01
	ld XHL,XSP                                           ; F831C9  ef 8b
	add XHL,0x00000006                                   ; F831CB  eb c8 06 00 00 00
	calr Dev7F_WriteSlot8                                ; F831D1  1e c3 ff
	ld w, 0x02:opc                                          ; F831D4  20 02
	ld XHL,XSP                                           ; F831D6  ef 8b
	add XHL,0x00000004                                   ; F831D8  eb c8 04 00 00 00
	calr Dev7F_WriteSlot8                                ; F831DE  1e b6 ff
	ld w, 0x03:opc                                          ; F831E1  20 03
	ld XHL,XSP                                           ; F831E3  ef 8b
	add XHL,0x00000002                                   ; F831E5  eb c8 02 00 00 00
	calr Dev7F_WriteSlot8                                ; F831EB  1e a9 ff
	ld XIX,0x007f0000                                    ; F831EE  44 00 00 7f 00
	ldw bc, 0x04                                         ; F831F3  31 04 00
	ld w, 0x1f:opc                                          ; F831F6  20 1f
	ld a, 0x01:opc                                          ; F831F8  21 01
.LF831FA:
	or W,0x10                                            ; F831FA  c8 ce 10
	ld XIY,XWA                                           ; F831FD  e8 8d
	ldfr_berp a, 0xe3                                      ; F831FF  c7 e3 99   ld QW,A
	ldfr_berp a, 0xe2                                      ; F83202  c7 e2 99   ld QA,A
	ld A,W                                               ; F83205  c8 89
	ld (XIX),XWA                                         ; F83207  b4 60
	ld XWA,XIY                                           ; F83209  ed 88
	add W,0x20                                           ; F8320B  c8 c8 20
	djnz16 bc, .LF831FA                                  ; F8320E  d9 1c e9
	popw wa                                              ; F83211  48
	popw wa                                              ; F83212  48
	popw wa                                              ; F83213  48
	popw wa                                              ; F83214  48
	ret                                                  ; F83215  0e

; 0xF83216-0xF83FFF -- 3562 bytes of 0x0E, the encoding of RET.  padding between the 0xF83000 and 0xF84000 link groups
; EVERY byte of the run is checked, not sampled:
; notes/gen_prom_a_ringbuf_module.py refuses to emit this directive
; unless set(ROM[lo:hi]) == {0x0E}.
	.fill 3562, 1, 0x0E
