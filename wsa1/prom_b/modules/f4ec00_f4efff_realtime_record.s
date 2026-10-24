

; --------------------------------------------------------------------------
; sub_F4EC00
; Called from: T_F40CE0 (x0)
; Touches: (0x2070) (0x3000)  |  0x000000
; Evidence: thunk slot T_F40CE0 holds `jp 0x00F4EC00`, and 0xF4EC00 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4EC00:		; <- T_F40CE0
	ld	xwa, (6304798:24)	; F4EC00  ld XWA,(0x60341e)
	cp	xwa, 0	; F4EC05  cp XWA,0x00000000
	jr	z, sub_F4EC00_Return	; F4EC0B  jr Z,0xf4ec24
	ld	xwa, (12288:16)	; F4EC0D  ld XWA,(0x3000)
	cp	xwa, 0	; F4EC11  cp XWA,0x00000000
	jr	nz, sub_F4EC00_Return	; F4EC17  jr NZ,0xf4ec24
	bit	2, (TransportB_State:8)	; F4EC19  bit 2,(0x96)
	jr	z, sub_F4EC00_Return	; F4EC1C  jr Z,0xf4ec24
	ldw	(UI_Request:16), 520	; F4EC1E  ld (0x2070),0x0208
sub_F4EC00_Return:
	ret	; F4EC24  ret

; --------------------------------------------------------------------------
; Var34BB_ClearBits04
; Called from: T_Var34BB_ClearBits04 (x0)
; Touches: (0x34BB)
; Evidence: thunk slot T_Var34BB_ClearBits04 holds `jp 0x00F4EC25`, and 0xF4EC25 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Var34BB_ClearBits04: m_and_mi8 MB16, 0x34bb, 0xfb (single-cell template; the cell's meaning is not established unless it is named)
Var34BB_ClearBits04:		; <- T_Var34BB_ClearBits04
	and	(0x34bb:16), 0xfb	; F4EC25  and (0x34bb),0xfb
	ret	; F4EC2A  ret

; --------------------------------------------------------------------------
; RealtimeRecord_Arm
; Called from: T_RealtimeRecord_Arm (x1)
; Touches: nothing with an absolute address
; Calls:   RealtimeRecord_ArmAtFirstMeasure
; Evidence: thunk slot T_RealtimeRecord_Arm holds `jp 0x00F4EC2B`, and 0xF4EC2B is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; RealtimeRecord_Arm: `calr RealtimeRecord_ArmAtFirstMeasure / ret`: current measure := 1, (0x34D3) bit 1 := 1 -- the flag
;   RealtimeRecord_Disarm tests and clears -- (0x34BB) bit 3 set and cleared again at measure 1, (0x34D4) bit 4
;   (position request) set, Transport_StopAllRunning. ModeEnter_RealtimeRecord, the ENTER of panel mode 5, calls it
;   through T_RealtimeRecord_Arm. Basis: caller + body + the disarm twin. (notes/naming-pilot-2026-10-06/proposals_wave4_l.json)
RealtimeRecord_Arm:		; <- T_RealtimeRecord_Arm
	calr	RealtimeRecord_ArmAtFirstMeasure	; F4EC2B  calr 0xf4ec2f
	ret	; F4EC2E  ret

; --------------------------------------------------------------------------
; RealtimeRecord_ArmAtFirstMeasure
; Called from: in-module: 0xF4EC2B
; Touches: (0x34BB) (0x34D3) (0x34D4) (0x3552)
; Calls:   T_Transport_StopAllRunning
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4EC2F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; RealtimeRecord_ArmAtFirstMeasure: Current measure (0x3552) := 1, (0x34D3) b1 := 1 (the flag RealtimeRecord_Disarm
;   tests), (0x34BB) b3 set and cleared again at measure 1, (0x34D4) b4 set, Transport_StopAllRunning. The body behind
;   the RealtimeRecord_Arm stub (ModeEnter_RealtimeRecord). Basis: caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_p.json)
RealtimeRecord_ArmAtFirstMeasure:
	ldw	(13650:16), 1	; F4EC2F  ld (0x3552),0x0001
	or	(0x34d3:16), 0x02	; F4EC35  or (0x34d3),0x02
	or	(0x34bb:16), 0x08	; F4EC3A  or (0x34bb),0x08
	cpw	(0x3552:16), 0x0001	; F4EC3F  cp (0x3552),0x0001
	jr	nz, RealtimeRecord_ArmAtFirstMeasure_Skip	; F4EC45  jr NZ,0xf4ec4c
	and	(0x34bb:16), 0xf7	; F4EC47  and (0x34bb),0xf7
RealtimeRecord_ArmAtFirstMeasure_Skip:
	or	(0x34d4:16), 0x10	; F4EC4C  or (0x34d4),0x10
	call	T_Transport_StopAllRunning	; F4EC51  call 0xf409ac
	ret	; F4EC55  ret

; --------------------------------------------------------------------------
; RealtimeRecord_Disarm
; Called from: T_RealtimeRecord_Disarm (x2)
; Touches: (0x0DB5) (0x0DE4) (0x2250) (0x34D3)
; Calls:   T_Queue2E00_AppendRegs T_SeqRecord_EndTake T_Transport_StopAllRunning T_F40CB4 T_SeqBufRing_Discard
; Evidence: thunk slot T_RealtimeRecord_Disarm holds `jp 0x00F4EC56`, and 0xF4EC56 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; RealtimeRecord_Disarm: If (0x34D3) bit 1 is set (RealtimeRecord_ArmAtFirstMeasure sets it; ModeEnter_RealtimeRecord reaches that through
;   T_RealtimeRecord_Arm): UI_PartIndex := 0, Queue2E00 post (W 0xFF, DE 0x1090), T_SeqRecord_EndTake (SeqRecord_EndTake), Transport_StopAllRunning,
;   (0x0DB5) bit 0 := 0; then always clears that bit and empties SeqBuf_Ring. Called by ModeLeave_RealtimeRecord and
;   by Transport_StopWhileRecording, which sets the bit again afterwards. Basis: callers + body + the setter.
;   (notes/naming-pilot-2026-10-06/proposals_wave3_j.json)
RealtimeRecord_Disarm:		; <- T_RealtimeRecord_Disarm
	ld	(3556:16), 0	; F4EC56  ld (0x0de4),0x00
	bit	1, (0x34d3:16)	; F4EC5B  bit 1,(0x34d3)
	jr	z, RealtimeRecord_Disarm_Skip2	; F4EC5F  jr Z,0xf4ec80
	ld	(UI_PartIndex:16), 0	; F4EC61  ld (0x2250),0x00
	ld	w, 255:opc	; F4EC66  ld W,0xff
	ldw	de, 4240	; F4EC68  ld DE,0x1090
	call	T_Queue2E00_AppendRegs	; F4EC6B  call 0xf40f3c
	call	T_SeqRecord_EndTake	; F4EC6F  call 0xf409d8
	call	T_Transport_StopAllRunning	; F4EC73  call 0xf409ac
	call	T_F40CB4	; F4EC77  call 0xf40cb4
	and	(0x0db5:16), 0xfe	; F4EC7B  and (0x0db5),0xfe
RealtimeRecord_Disarm_Skip2:
	and	(0x34d3:16), 0xfd	; F4EC80  and (0x34d3),0xfd
	call	T_SeqBufRing_Discard	; F4EC85  call 0xf40a10
	ret	; F4EC89  ret

; --------------------------------------------------------------------------
; RealtimeRecord_InitOnModeEnter
; Called from: T_RealtimeRecord_InitOnModeEnter (x1)
; Touches: (0x0C02) (0x34BA) (0x34D2)
; Evidence: thunk slot T_RealtimeRecord_InitOnModeEnter holds `jp 0x00F4EC8A`, and 0xF4EC8A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; RealtimeRecord_InitOnModeEnter: Clears (0x34D2) bit 7 (set by SeqRecord_BeginTake when a take starts), (0x34BA) := 0xFF and
;   (0x0C02) := 0. The meanings of (0x34BA) and (0x0C02) are not established. The first call of
;   ModeEnter_RealtimeRecord (slot T_RealtimeRecord_InitOnModeEnter), before Seq_RestorePlayingTrackMask. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_m.json)
RealtimeRecord_InitOnModeEnter:		; <- T_RealtimeRecord_InitOnModeEnter
	and	(0x34d2:16), 0x7f	; F4EC8A  and (0x34d2),0x7f
	ld	(13498:16), 255	; F4EC8F  ld (0x34ba),0xff
	ld	(3074:16), 0	; F4EC94  ld (0x0c02),0x00
	ret	; F4EC99  ret

; --------------------------------------------------------------------------
; sub_F4EC9A
; Called from: T_F40CF4 (x0)
; Touches: (0x3552)
; Evidence: thunk slot T_F40CF4 holds `jp 0x00F4EC9A`, and 0xF4EC9A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4EC9A:		; <- T_F40CF4
	cpw	(0x3552:16), 0x0000	; F4EC9A  cp (0x3552),0x0000
	jr	nz, sub_F4EC2F_Return	; F4ECA0  jr NZ,0xf4eca8
	ldw	(13650:16), 1	; F4ECA2  ld (0x3552),0x0001
sub_F4EC2F_Return:
	ret	; F4ECA8  ret

; --------------------------------------------------------------------------
; sub_F4ECA9
; Called from: T_F40CF8 (x1)
; Touches: (0x0C11) (0x0DE4) (0x207D) (0x3000) (0x3002) (0x34D4)
; Calls:   T_SeqRecord_RewindForTake T_NoteRouting_RebuildForSong T_SeqRecord_SelectArmedTrackPart_Call
; Evidence: thunk slot T_F40CF8 holds `jp 0x00F4ECA9`, and 0xF4ECA9 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4ECA9:		; <- T_F40CF8
	cp	(UI_ScreenId_Previous:16), 0x05	; F4ECA9  cp (0x207d),0x05
	jr	z, sub_F4EC2F_Skip3	; F4ECAE  jr Z,0xf4ecb0
sub_F4EC2F_Skip3:
	cp	(UI_ScreenId_Previous:16), 0x05	; F4ECB0  cp (0x207d),0x05
	jr	z, sub_F4EC2F_Skip4	; F4ECB5  jr Z,0xf4ecb9
	jr	sub_F4EC2F_Return2	; F4ECB7  jr T,0xf4ed0b
sub_F4EC2F_Skip4:
	cp	(0x0de4:16), 0x01	; F4ECB9  cp (0x0de4),0x01
	jr	nz, sub_F4EC2F_Return2	; F4ECBE  jr NZ,0xf4ed0b
	xor	xbc, xbc	; F4ECC0  xor XBC,XBC
	ld	(12288:16), xbc	; F4ECC2  ld (0x3000),XBC
sub_F4EC2F_Loop:
	pushw	de	; F4ECC6  push DE
	cp	c, 16	; F4ECC7  cp C,0x10
	jr	nc, sub_F4EC2F_Skip5	; F4ECCA  jr NC,0xf4ecdb
	ld	de, (12288:16)	; F4ECCC  ld DE,(0x3000)
	ld	a, c	; F4ECD0  ld A,C
	scf	; F4ECD2  scf
	stcf_a_16	de	; F4ECD3  stcf A,DE
	ld	(12288:16), de	; F4ECD5  ld (0x3000),DE
	jr	sub_F4EC2F_Join	; F4ECD9  jr T,0xf4eceb
sub_F4EC2F_Skip5:
	ld	de, (12290:16)	; F4ECDB  ld DE,(0x3002)
	ld	a, c	; F4ECDF  ld A,C
	sub	a, 16	; F4ECE1  sub A,0x10
	scf	; F4ECE4  scf
	stcf_a_16	de	; F4ECE5  stcf A,DE
	ld	(12290:16), de	; F4ECE7  ld (0x3002),DE
sub_F4EC2F_Join:
	popw	de	; F4ECEB  pop DE
	ld	(3089:16), c	; F4ECEC  ld (0x0c11),C
	ld	c, (3089:16)	; F4ECF0  ld C,(0x0c11)
	inc	1, c	; F4ECF4  inc 1,C
	cp	c, 4:i3	; F4ECF6  cp C,4
	jr	ule, sub_F4EC2F_Loop	; F4ECF8  jr ULE,0xf4ecc6
	or	(0x34d4:16), 0x10	; F4ECFA  or (0x34d4),0x10
	call	T_SeqRecord_RewindForTake	; F4ECFF  call 0xf409d0
	call	T_NoteRouting_RebuildForSong	; F4ED03  call 0xf411b8
	call	T_SeqRecord_SelectArmedTrackPart_Call	; F4ED07  call 0xf40cc0
sub_F4EC2F_Return2:
	ret	; F4ED0B  ret

; --------------------------------------------------------------------------
; Seq_DelayedLocateToMeasure_Call
; Called from: T_Seq_DelayedLocateToMeasure_Call (x1)
; Touches: nothing with an absolute address
; Calls:   Seq_DelayedLocateToMeasure
; Evidence: thunk slot T_Seq_DelayedLocateToMeasure_Call holds `jp 0x00F4ED0C`, and 0xF4ED0C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_DelayedLocateToMeasure_Call: `calr Seq_DelayedLocateToMeasure / ret` behind T_Seq_DelayedLocateToMeasure_Call, run on every Seq_MainLoopService pass.
;   Seq_DelayedLocateToMeasure, unless transport C runs: re-arms the locate countdown (0x0C05) := 0xE4 while the measure keys are held
;   (screen 0x12 SEQ PLAY: held-button bits 8/9; screen 0x0A: bits 10/11), else counts it down and at 0x80 clears it
;   and calls T_Seq_LocateToCurrentMeasure -- the deferred locate SeqPlayScreen_StepMeasure arms with (0x0C05) := 0xE4
;   after stepping the measure. Basis: caller + body + the arming site. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_k.json)
Seq_DelayedLocateToMeasure_Call:		; <- T_Seq_DelayedLocateToMeasure_Call
	calr	Seq_DelayedLocateToMeasure	; F4ED0C  calr 0xf4ed10
	ret	; F4ED0F  ret

; --------------------------------------------------------------------------
; Seq_DelayedLocateToMeasure
; Called from: in-module: 0xF4ED0C
; Touches: (0x0C05) (0x207C) (0x2084) (0x2088) (0x34BB)
; Calls:   T_Seq_LocateToCurrentMeasure
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4ED10 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_DelayedLocateToMeasure: Unless transport C runs: re-arms the locate countdown (0x0C05) := 0xE4 and sets (0x34BB)
;   b2 while the measure keys are held (screen 0x12: held-pair bits 8/9; screen 0x0A: held bits 10/11), else counts it
;   down and at 0x80 clears it and calls T_Seq_LocateToCurrentMeasure. The body of Seq_DelayedLocateToMeasure_Call.
;   Basis: caller header + body. (notes/naming-pilot-2026-10-06/proposals_wave5_p.json)
Seq_DelayedLocateToMeasure:
	bit	2, (TransportC_State:8)	; F4ED10  bit 2,(0x95)
	jr	z, Seq_DelayedLocateToMeasure_Skip	; F4ED13  jr Z,0xf4ed17
	jr	sub_F4ED10_Return	; F4ED15  jr T,0xf4ed83
Seq_DelayedLocateToMeasure_Skip:
	ld	a, (UI_ScreenId:16)	; F4ED17  ld A,(0x207c)
	cp	a, 10	; F4ED1B  cp A,0x0a
	jr	z, sub_F4ED10_Entry	; F4ED1E  jr Z,0xf4ed3b
	cp	a, 18	; F4ED20  cp A,0x12
	jr	z, Seq_DelayedLocateToMeasure_Skip2	; F4ED23  jr Z,0xf4ed27
	jr	sub_F4ED10_Join	; F4ED25  jr T,0xf4ed67
Seq_DelayedLocateToMeasure_Skip2:
	ld	wa, (PanelButton_HeldMask:16)	; F4ED27  ld WA,(0x2088)
	and	wa, (PanelButton_HeldPairPos:16)	; F4ED2B  and WA,(0x2084)
	bit	8, wa	; F4ED2F  bit 0x08,WA
	jr	nz, sub_F4ED10_Skip3	; F4ED32  jr NZ,0xf4ed5d
	bit	9, wa	; F4ED34  bit 0x09,WA
	jr	nz, sub_F4ED10_Skip3	; F4ED37  jr NZ,0xf4ed5d
	jr	sub_F4ED10_Join	; F4ED39  jr T,0xf4ed67
sub_F4ED10_Entry:
	ldfr_werp	de, 0x3e	; F4ED3B  ld QHL3,DE
	ld	de, (PanelButton_HeldMask:16)	; F4ED3E  ld DE,(0x2088)
	and	de, 1024	; F4ED42  and DE,0x0400
	ldto_werp	de, 0x3e	; F4ED46  ld DE,QHL3
	jr	nz, sub_F4ED10_Skip3	; F4ED49  jr NZ,0xf4ed5d
	ldfr_werp	de, 0x3e	; F4ED4B  ld QHL3,DE
	ld	de, (PanelButton_HeldMask:16)	; F4ED4E  ld DE,(0x2088)
	and	de, 2048	; F4ED52  and DE,0x0800
	ldto_werp	de, 0x3e	; F4ED56  ld DE,QHL3
	jr	nz, sub_F4ED10_Skip3	; F4ED59  jr NZ,0xf4ed5d
	jr	sub_F4ED10_Join	; F4ED5B  jr T,0xf4ed67
sub_F4ED10_Skip3:
	ld	(3077:16), 228	; F4ED5D  ld (0x0c05),0xe4
	or	(0x34bb:16), 0x04	; F4ED62  or (0x34bb),0x04
sub_F4ED10_Join:
	bit	7, (0x0c05:16)	; F4ED67  bit 7,(0x0c05)
	jr	z, sub_F4ED10_Return	; F4ED6B  jr Z,0xf4ed83
	cp	(0x0c05:16), 0x80	; F4ED6D  cp (0x0c05),0x80
	jr	le, sub_F4ED10_Skip4	; F4ED72  jr LE,0xf4ed7a
	dec	1, (3077:16)	; F4ED74  dec 1,(0x0c05)
	jr	sub_F4ED10_Return	; F4ED78  jr T,0xf4ed83
sub_F4ED10_Skip4:
	ld	(3077:16), 0	; F4ED7A  ld (0x0c05),0x00
	call	T_Seq_LocateToCurrentMeasure	; F4ED7F  call 0xf409dc
sub_F4ED10_Return:
	ret	; F4ED83  ret

; --------------------------------------------------------------------------
; SongMemory_UpdateFreePercent
; Called from: T_SongMemory_UpdateFreePercent (x4)
; Touches: (0x0C08) (0x207C) (0x2095) (0x3608)
; Evidence: thunk slot T_SongMemory_UpdateFreePercent holds `jp 0x00F4ED84`, and 0xF4ED84 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongMemory_UpdateFreePercent: On screens 6, 9 and 0x12 only: (0x0C08) := min(99, 100 * BStore_FreeCount /
;   BStore_BlockCount + 1), then UI_ScreenFlags |= 0x10. (0x0C08) is what 'MEMORY = nn %' prints on the realtime-
;   record screen; ScreenEnter of SEQ PLAY / REALTIME RECORD call it (T_SongMemory_UpdateFreePercent). Basis: callers + body + caption.
;   (notes/naming-pilot-2026-10-06/proposals_wave2_c.json)
SongMemory_UpdateFreePercent:		; <- T_SongMemory_UpdateFreePercent
	ld	a, (UI_ScreenId:16)	; F4ED84  ld A,(0x207c)
	cp	a, 6:i3	; F4ED88  cp A,6
	jr	z, SongMemory_UpdateFreePercent_Skip5	; F4ED8A  jr Z,0xf4ed98
	cp	a, 9	; F4ED8C  cp A,0x09
	jr	z, SongMemory_UpdateFreePercent_Skip5	; F4ED8F  jr Z,0xf4ed98
	cp	a, 18	; F4ED91  cp A,0x12
	jr	z, SongMemory_UpdateFreePercent_Skip5	; F4ED94  jr Z,0xf4ed98
	jr	SongMemory_UpdateFreePercent_Return2	; F4ED96  jr T,0xf4edc5
SongMemory_UpdateFreePercent_Skip5:
	ldw	wa, 100	; F4ED98  ld WA,0x0064
	mul	xwa, (BStore_FreeCount:24)	; F4ED9B  mul XWA,(0x6034ba)
	ld	de, qwa	; F4EDA0  ld DE,QWA
	ld	bc, (BStore_BlockCount:16)	; F4EDA3  ld BC,(0x3608)
	ld	qwa, de	; F4EDA7  ld QWA,DE
	div	xwa, bc	; F4EDAA  div XWA,BC
	ld	de, qwa	; F4EDAC  ld DE,QWA
	add	wa, 1	; F4EDAF  add WA,0x0001
	cp	wa, 100	; F4EDB3  cp WA,0x0064
	jr	c, SongMemory_UpdateFreePercent_Skip	; F4EDB7  jr C,0xf4edbc
	ldw	wa, 99	; F4EDB9  ld WA,0x0063
SongMemory_UpdateFreePercent_Skip:
	ld	(3080:16), wa	; F4EDBC  ld (0x0c08),WA
	or	(UI_ScreenFlags:16), 0x10	; F4EDC0  or (0x2095),0x10
SongMemory_UpdateFreePercent_Return2:
	ret	; F4EDC5  ret

; --------------------------------------------------------------------------
; SeqPlayScreen_StepMeasure
; Called from: in-module: 0xF4EEE2 0xF4EEEF
; Touches: (0x0C05) (0x2075) (0x207C) (0x2088) (0x209B) (0x34D9) (0x3552)
; Calls:   T_TimedEventRing_Discard
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4EDC6 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqPlayScreen_StepMeasure: SEQUENCER PLAY: steps the current measure (0x3552) by Table_F4EF38[W & 7] (1,1,2..7), up
;   when W bit 3 is clear (max 999), down when set (min 1; special values >= 0x8000 become 1); then (0x0C05) = 0xE4,
;   T_TimedEventRing_Discard, UI_RequestBits |= 9, dial arms 0x8889. Skipped while transport C runs or (0x34D9) bit 2;
;   clears request bits 0/3 while transport B runs. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_d.json)
SeqPlayScreen_StepMeasure:
	cp	(UI_ScreenId:16), 0x12	; F4EDC6  cp (0x207c),0x12
	jr	nz, SeqPlayScreen_StepMeasure_Skip	; F4EDCB  jr NZ,0xf4eddd
	ldfr_werp	de, 0x3e	; F4EDCD  ld QHL3,DE
	ld	de, (PanelButton_HeldMask:16)	; F4EDD0  ld DE,(0x2088)
	and	de, 512	; F4EDD4  and DE,0x0200
	ldto_werp	de, 0x3e	; F4EDD8  ld DE,QHL3
	jr	z, SeqPlayScreen_StepMeasure_Skip	; F4EDDB  jr Z,0xf4eddd
SeqPlayScreen_StepMeasure_Skip:
	bit	2, (TransportC_State:8)	; F4EDDD  bit 2,(0x95)
	jrl	nz, sub_F4EDC6_Skip2	; F4EDE0  jrl NZ,0xf4ee64
	bit	2, (0x34d9:16)	; F4EDE3  bit 2,(0x34d9)
	jrl	nz, sub_F4EDC6_Skip2	; F4EDE7  jrl NZ,0xf4ee64
	ld	a, w	; F4EDEA  ld A,W
	ld	b, w	; F4EDEC  ld B,W
	xor	w, w	; F4EDEE  xor W,W
	and	a, 7	; F4EDF0  and A,0x07
	ld	iy, wa	; F4EDF3  ld IY,WA
	ld	xix, Table_F4EF38	; F4EDF5  ld XIX,0x00f4ef38
	ld	a, (xix+iy)	; F4EDFA  ld A,(XIX+IY)
	bit	3, b	; F4EDFF  bit 0x03,B
	jr	z, sub_F4ED10_Entry2	; F4EE02  jr Z,0xf4ee2a
	ldfr_werp	de, 0x3e	; F4EE04  ld QHL3,DE
	ld	de, (13650:16)	; F4EE07  ld DE,(0x3552)
	and	de, 32768	; F4EE0B  and DE,0x8000
	ldto_werp	de, 0x3e	; F4EE0F  ld DE,QHL3
	jr	nz, sub_F4ED10_Join3	; F4EE12  jr NZ,0xf4ee50
	sub	(0x3552:16), wa	; F4EE14  sub (0x3552),WA
	jr	c, SeqPlayScreen_StepMeasure_Join2	; F4EE18  jr C,0xf4ee22
	cpw	(0x3552:16), 0x0000	; F4EE1A  cp (0x3552),0x0000
	jr	nz, sub_F4ED10_Join3	; F4EE20  jr NZ,0xf4ee50
SeqPlayScreen_StepMeasure_Join2:
	ldw	(13650:16), 1	; F4EE22  ld (0x3552),0x0001
	jr	sub_F4ED10_Join3	; F4EE28  jr T,0xf4ee50
sub_F4ED10_Entry2:
	ldfr_werp	de, 0x3e	; F4EE2A  ld QHL3,DE
	ld	de, (13650:16)	; F4EE2D  ld DE,(0x3552)
	and	de, 32768	; F4EE31  and DE,0x8000
	ldto_werp	de, 0x3e	; F4EE35  ld DE,QHL3
	jr	z, sub_F4ED10_Skip6	; F4EE38  jr Z,0xf4ee3c
	jr	SeqPlayScreen_StepMeasure_Join2	; F4EE3A  jr T,0xf4ee22
sub_F4ED10_Skip6:
	add	(0x3552:16), wa	; F4EE3C  add (0x3552),WA
	cpw	(0x3552:16), 0x03e7	; F4EE40  cp (0x3552),0x03e7
	jr	ugt, sub_F4ED10_Skip7	; F4EE46  jr UGT,0xf4ee4a
	jr	sub_F4ED10_Join3	; F4EE48  jr T,0xf4ee50
sub_F4ED10_Skip7:
	ldw	(13650:16), 999	; F4EE4A  ld (0x3552),0x03e7
sub_F4ED10_Join3:
	ld	(3077:16), 228	; F4EE50  ld (0x0c05),0xe4
	call	T_TimedEventRing_Discard	; F4EE55  call 0xf40a14
	or	(UI_RequestBits:16), 0x09	; F4EE59  or (0x2075),0x09
	ldw	(PanelDial_DownButton:16), 34953	; F4EE5E  ld (0x209b),0x8889  <- arms prom_a PanelButton_Accept's substitution for panel button code 0x0D (0xF86615); see the 0xF7D2D8 banner
sub_F4EDC6_Skip2:
	bit	2, (TransportB_State:8)	; F4EE64  bit 2,(0x96)
	jr	z, sub_F4ED10_Return3	; F4EE67  jr Z,0xf4ee6e
	and	(UI_RequestBits:16), 0xf6	; F4EE69  and (0x2075),0xf6
sub_F4ED10_Return3:
	ret	; F4EE6E  ret

; --------------------------------------------------------------------------
; RecordScreen_LcdKeyRow1
; Called from: T_RecordScreen_LcdKeyRow1 (x2)
; Touches: nothing with an absolute address
; Calls:   CountIn_ToggleEnable
; Evidence: thunk slot T_RecordScreen_LcdKeyRow1 holds `jp 0x00F4EE6F`, and 0xF4EE6F is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; RecordScreen_LcdKeyRow1: the LcdKeyRow1 action of CycleRecordScreen, RealtimeRecordScreen -- called only by LcdKeyRow1_CycleRecordScreen, LcdKeyRow1_RealtimeRecordScreen.
RecordScreen_LcdKeyRow1:		; <- T_RecordScreen_LcdKeyRow1
	calr	CountIn_ToggleEnable	; F4EE6F  calr 0xf4ee73
	ret	; F4EE72  ret

; --------------------------------------------------------------------------
; CountIn_ToggleEnable
; Called from: in-module: 0xF4EE6F
; Touches: (0x34D9) (0x3552)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4EE73 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CountIn_ToggleEnable: Toggles (0x34D9) bit 0, the count-in setting -- SeqRecord_RewindForTake copies it into bit 1, which
;   Transport_StartAllFromZero tests to start with a count-in -- except while a count-in runs ((0x34D9) bit 2 and
;   measure bit 15) or while transport A runs with neither bit set. The LcdKeyRow1 action of the CYCLE RECORD and
;   REALTIME RECORD screens (RecordScreen_LcdKeyRow1). Basis: caller + body + the bit's readers. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_l.json)
CountIn_ToggleEnable:
	bit	2, (0x34d9:16)	; F4EE73  bit 2,(0x34d9)
	jr	z, CountIn_ToggleEnable_Skip	; F4EE77  jr Z,0xf4ee89
	ldfr_werp	de, 0x3e	; F4EE79  ld QHL3,DE
	ld	de, (13650:16)	; F4EE7C  ld DE,(0x3552)
	and	de, 32768	; F4EE80  and DE,0x8000
	ldto_werp	de, 0x3e	; F4EE84  ld DE,QHL3
	jr	nz, CountIn_ToggleEnable_Return	; F4EE87  jr NZ,0xf4eeac
CountIn_ToggleEnable_Skip:
	bit	2, (TransportA_State:8)	; F4EE89  bit 2,(0x94)
	jr	z, CountIn_ToggleEnable_Skip2	; F4EE8C  jr Z,0xf4ee9a
	bit	0, (0x34d9:16)	; F4EE8E  bit 0,(0x34d9)
	jr	nz, CountIn_ToggleEnable_Skip2	; F4EE92  jr NZ,0xf4ee9a
	bit	1, (0x34d9:16)	; F4EE94  bit 1,(0x34d9)
	jr	z, CountIn_ToggleEnable_Return	; F4EE98  jr Z,0xf4eeac
CountIn_ToggleEnable_Skip2:
	bit	0, (0x34d9:16)	; F4EE9A  bit 0,(0x34d9)
	jr	z, CountIn_ToggleEnable_Skip3	; F4EE9E  jr Z,0xf4eea7
	and	(0x34d9:16), 0xfe	; F4EEA0  and (0x34d9),0xfe
	jr	CountIn_ToggleEnable_Return	; F4EEA5  jr T,0xf4eeac
CountIn_ToggleEnable_Skip3:
	or	(0x34d9:16), 0x01	; F4EEA7  or (0x34d9),0x01
CountIn_ToggleEnable_Return:
	ret	; F4EEAC  ret

; --------------------------------------------------------------------------
; SeqPlayScreen_EnsureMeasureNonZero
; Called from: T_SeqPlayScreen_EnsureMeasureNonZero (x1)
; Touches: (0x3552)
; Evidence: thunk slot T_SeqPlayScreen_EnsureMeasureNonZero holds `jp 0x00F4EEAD`, and 0xF4EEAD is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqPlayScreen_EnsureMeasureNonZero: Current measure (0x3552) := 1 when it is 0. Called only by
;   ScreenEnter_SeqPlayScreen (slot T_SeqPlayScreen_EnsureMeasureNonZero); sub_F4EC9A is a byte-identical copy (slot T_F40CF4, no caller). Basis:
;   caller + body. (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
SeqPlayScreen_EnsureMeasureNonZero:		; <- T_SeqPlayScreen_EnsureMeasureNonZero
	cpw	(0x3552:16), 0x0000	; F4EEAD  cp (0x3552),0x0000
	jr	nz, SeqPlayScreen_EnsureMeasureNonZero_Return2	; F4EEB3  jr NZ,0xf4eebb
	ldw	(13650:16), 1	; F4EEB5  ld (0x3552),0x0001
SeqPlayScreen_EnsureMeasureNonZero_Return2:
	ret	; F4EEBB  ret

; --------------------------------------------------------------------------
; sub_F4EEBC
; Called from: T_F40D08 (x0)
; Touches: (0x3552)  |  0x000000
; Calls:   T_Seq_RequestRewind
; Evidence: thunk slot T_F40D08 holds `jp 0x00F4EEBC`, and 0xF4EEBC is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4EEBC:		; <- T_F40D08
	ld	xwa, (6304798:24)	; F4EEBC  ld XWA,(0x60341e)
	cp	xwa, 0	; F4EEC1  cp XWA,0x00000000
	jr	z, sub_F4EE73_Return3	; F4EEC7  jr Z,0xf4eed8
	bit	2, (TransportB_State:8)	; F4EEC9  bit 2,(0x96)
	jr	nz, sub_F4EE73_Return3	; F4EECC  jr NZ,0xf4eed8
	call	T_Seq_RequestRewind	; F4EECE  call 0xf409e0
	ldw	(13650:16), 1	; F4EED2  ld (0x3552),0x0001
sub_F4EE73_Return3:
	ret	; F4EED8  ret

; --------------------------------------------------------------------------
; SeqPlayScreen_LcdKeyRow1
; Called from: T_SeqPlayScreen_LcdKeyRow1 (x1)
; Touches: nothing with an absolute address
; Calls:   SeqPlayScreen_StepMeasure
; Evidence: thunk slot T_SeqPlayScreen_LcdKeyRow1 holds `jp 0x00F4EED9`, and 0xF4EED9 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqPlayScreen_LcdKeyRow1: the LcdKeyRow1 action of SeqPlayScreen -- called only by LcdKeyRow1_SeqPlayScreen.
SeqPlayScreen_LcdKeyRow1:		; <- T_SeqPlayScreen_LcdKeyRow1
	cp	bc, 8	; F4EED9  cp BC,0x0008
	jr	nz, SeqPlayScreen_LcdKeyRow1_Return4	; F4EEDD  jr NZ,0xf4eee5
	and	w, 247	; F4EEDF  and W,0xf7
	calr	SeqPlayScreen_StepMeasure	; F4EEE2  calr 0xf4edc6
SeqPlayScreen_LcdKeyRow1_Return4:
	ret	; F4EEE5  ret

; --------------------------------------------------------------------------
; SeqPlayScreen_LcdKeyRow2
; Called from: T_SeqPlayScreen_LcdKeyRow2 (x1)
; Touches: nothing with an absolute address
; Calls:   SeqPlayScreen_StepMeasure
; Evidence: thunk slot T_SeqPlayScreen_LcdKeyRow2 holds `jp 0x00F4EEE6`, and 0xF4EEE6 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqPlayScreen_LcdKeyRow2: the LcdKeyRow2 action of SeqPlayScreen -- called only by LcdKeyRow2_SeqPlayScreen.
SeqPlayScreen_LcdKeyRow2:		; <- T_SeqPlayScreen_LcdKeyRow2
	cp	bc, 9	; F4EEE6  cp BC,0x0009
	jr	nz, SeqPlayScreen_LcdKeyRow2_Return	; F4EEEA  jr NZ,0xf4eef2
	or	w, 8	; F4EEEC  or W,0x08
	calr	SeqPlayScreen_StepMeasure	; F4EEEF  calr 0xf4edc6
SeqPlayScreen_LcdKeyRow2_Return:
	ret	; F4EEF2  ret

; --------------------------------------------------------------------------
; sub_F4EEF3
; Called from: T_F40D18 (x2)
; Touches: (0x207A) (0x2084) (0x2088) (0x2095)
; Evidence: thunk slot T_F40D18 holds `jp 0x00F4EEF3`, and 0xF4EEF3 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4EEF3:		; <- T_F40D18
	ldfr_werp	de, 0x3e	; F4EEF3  ld QHL3,DE
	ld	de, (PanelButton_HeldMask:16)	; F4EEF6  ld DE,(0x2088)
	and	de, 512	; F4EEFA  and DE,0x0200
	ldto_werp	de, 0x3e	; F4EEFE  ld DE,QHL3
	jr	z, sub_F4EEF3_Return	; F4EF01  jr Z,0xf4ef13
	ldfr_werp	de, 0x3e	; F4EF03  ld QHL3,DE
	ld	de, (PanelButton_HeldPairPos:16)	; F4EF06  ld DE,(0x2084)
	and	de, 512	; F4EF0A  and DE,0x0200
	ldto_werp	de, 0x3e	; F4EF0E  ld DE,QHL3
	jr	nz, sub_F4EEF3_Return	; F4EF11  jr NZ,0xf4ef13
sub_F4EEF3_Return:
	ret	; F4EF13  ret
	cp	(UI_ScreenLatch:16), 0x06	; F4EF14  cp (0x207a),0x06
	jr	z, sub_F4EEF3_Skip	; F4EF19  jr Z,0xf4ef29
	cp	(UI_ScreenLatch:16), 0x12	; F4EF1B  cp (0x207a),0x12
	jr	z, sub_F4EEF3_Skip	; F4EF20  jr Z,0xf4ef29
	cp	(UI_ScreenLatch:16), 0x09	; F4EF22  cp (0x207a),0x09
	jr	nz, sub_F4EEF3_Return2	; F4EF27  jr NZ,0xf4ef2e
sub_F4EEF3_Skip:
	or	(UI_ScreenFlags:16), 0x10	; F4EF29  or (0x2095),0x10
sub_F4EEF3_Return2:
	ret	; F4EF2E  ret

; --------------------------------------------------------------------------
; Table_F4EF2F -- 9 bytes: 0x01 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08.
; Read by: NOTHING that this tree can find.  No site in prom_a or prom_b
;          spells 0xF4EF2F as a 32-bit word.  It sits between the `ret` at
;          0xF4EF2E that closes the routine above and Table_F4EF38, which
;          does have a reader.
; Entry count: 9 bytes, bounded below by that `ret` and above by 0xF4EF38,
;              whose address a decoded instruction names.  Nothing
;              establishes an ENTRY size, so the object is emitted as bytes.
; Evidence: the extent only.  The name is the address and claims nothing
;           else.
; Unknown: everything except the bytes.  Note that Table_F4EF38's eight
;          bytes are 0x01 0x01 0x02 ... 0x07, i.e. these nine minus the
;          trailing 0x08 -- a near-duplicate, in a module whose tail also
;          carries the 36-byte exact duplicate Table_F4EF40.  Recorded, not
;          explained.
; --------------------------------------------------------------------------
Table_F4EF2F:
	.byte	0x01, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08	; F4EF2F  [0..8]


; --------------------------------------------------------------------------
; Table_F4EF38 -- 8 bytes: 0x01 0x01 0x02 0x03 0x04 0x05 0x06 0x07.
; Read by: one site: `ld XIX,0x00f4ef38` at 0xF4EDF5.  (The byte scan for
;          the address hits 0xF4EDF6, which is that instruction's OPERAND
;          field, 1 byte in.)  The value comes out at the `ld A,(XIX+IY)`
;          two instructions later.
; Entry count: 8, and it is the CODE that fixes it, not the extent: the
;              reader is preceded at 0xF4EDF0 by `and A,0x07` and 0xF4EDF3
;              by `ld IY,WA`, so the index can only be 0..7.  Both
;              instructions are read back out of the proven transcription on
;              every emit.
; Evidence: the two instructions above plus the reader, all taken from the
;           transcription rather than typed.
; Unknown: what the eight values select.
; --------------------------------------------------------------------------
Table_F4EF38:
	.byte	0x01, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07	; F4EF38  [0..7]


; --------------------------------------------------------------------------
; Table_F4EF40 -- 36 bytes that are BYTE-IDENTICAL to 0xF4EF1C-0xF4EF3F, the
;                 tail of the routine at 0xF4EF14 together with the two
;                 tables after it.  The equality is asserted on every emit.
; Read by: nothing.  No site in prom_a or prom_b spells 0xF4EF40, 0xF4EF53
;          or 0xF4EF5C as a 32-bit word.
; Why it is DATA and not code: decoded from its own first byte it reads `jrl
;                              GT,0xF52E63` -- a jump into the 3,571-byte
;                              run of 0x0E padding at 0xF5220E-0xF52FFF.  It
;                              is the SOURCE run that starts on an
;                              instruction: 0xF4EF1C is inside the
;                              transcribed routine at 0xF4EF14, and
;                              0xF4EF40's copy begins EIGHT bytes into that
;                              routine's first instruction pair, so no entry
;                              point can land on it.
; Entry count: 36 bytes, from the duplicate's own extent: it starts at the
;              byte after Table_F4EF38 and the byte after it, 0xF4EF64,
;              opens the 156-byte 0x0E padding run that closes the module.
;              36 is also exactly len(0xF4EF14..0xF4EF3F) - 8.
; Evidence: at(0xF4EF40, 36) == at(0xF4EF1C, 36), re-read and compared on
;           every emit.
; Unknown: how it got here.  A build that emitted a routine twice and a link
;          that dropped the first eight bytes of the second copy would
;          produce exactly this; so would a hand-patched object.  Nothing in
;          the ROM decides between them.
; --------------------------------------------------------------------------
Table_F4EF40:
	.byte	0x7A, 0x20, 0x3F, 0x12, 0x66, 0x07, 0xC1, 0x7A, 0x20, 0x3F, 0x09, 0x6E, 0x05, 0xC1, 0x95, 0x20	; F4EF40  [0..15]
	.byte	0x3E, 0x10, 0x0E, 0x01, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x01, 0x02, 0x03	; F4EF50  [16..31]
	.byte	0x04, 0x05, 0x06, 0x07	; F4EF60  [32..35]

	.fill	156, 1, 0x0E	; F4EF64-F4EFFF  `ret` padding (asserted pure 0x0E)
