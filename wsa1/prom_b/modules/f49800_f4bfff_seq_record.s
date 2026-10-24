

; --------------------------------------------------------------------------
; SeqRecord_LoadTakeCursor_Veneer
; Called from: T_SeqRecord_LoadTakeCursor_Veneer (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_SeqRecord_LoadTakeCursor_Veneer holds `jp 0x00F49800`, and 0xF49800 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_LoadTakeCursor_Veneer: Veneer (slot T_SeqRecord_LoadTakeCursor_Veneer): `jr` to SeqRecord_LoadTakeCursor, which loads the block-store cursor from
;   track C's take cursor (block word 0x340C[C], offset byte 0x342E[C]) -- the arrays the take start (SeqRecord_AllocTakeChains)
;   points at each take track's first block, offset 5. SeqRecord_TerminateTakeTracks calls it before writing the end
;   tags. Basis: caller + body + array writer. (notes/naming-pilot-2026-10-06/proposals_wave5_p.json)
SeqRecord_LoadTakeCursor_Veneer:		; <- T_SeqRecord_LoadTakeCursor_Veneer
	jr	SeqRecord_LoadTakeCursor	; F49800  jr T,0xf4980d

; --------------------------------------------------------------------------
; SeqRecord_SaveTakeCursor_Veneer
; Called from: T_SeqRecord_SaveTakeCursor_Veneer (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_SeqRecord_SaveTakeCursor_Veneer holds `jp 0x00F49802`, and 0xF49802 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_SaveTakeCursor_Veneer: Veneer (slot T_SeqRecord_SaveTakeCursor_Veneer): `jr` to SeqRecord_SaveTakeCursor, which stores the block-store cursor
;   back into track C's take cursor (0x340C[C] word, 0x342E[C] byte). SeqRecord_TerminateTakeTracks calls it after the
;   end tags; inverse of SeqRecord_LoadTakeCursor_Veneer's target. Basis: caller + body + inverse twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_p.json)
SeqRecord_SaveTakeCursor_Veneer:		; <- T_SeqRecord_SaveTakeCursor_Veneer
	jr	SeqRecord_SaveTakeCursor	; F49802  jr T,0xf49838

; --------------------------------------------------------------------------
; SeqRecord_SoundAlert_Veneer
; Called from: T_SeqRecord_SoundAlert_Veneer (x4)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_SeqRecord_SoundAlert_Veneer holds `jp 0x00F49804`, and 0xF49804 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_SoundAlert_Veneer: Veneer (slot T_SeqRecord_SoundAlert_Veneer): `jr` to SeqRecord_SoundAlert, which posts the CPU-2 message F0 50 87 08
;   (A = 8, T_F41020 = Msg0716_PostSysEx50_87) -- the same message DiskError_SoundAlertAndWait sends on disk failures.
;   Called only on sequencer failure paths: SeqRecord_AllocTakeChains out of blocks, and two Seq_StopAll /
;   UiStatus_ShowMessage0E paths. Basis: callers + body + same-message twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_w.json)
SeqRecord_SoundAlert_Veneer:		; <- T_SeqRecord_SoundAlert_Veneer
	jr	SeqRecord_SoundAlert	; F49804  jr T,0xf49861

; --------------------------------------------------------------------------
; SeqRecord_DrainEventRingAtTakeEnd
; Called from: T_SeqRecord_DrainEventRingAtTakeEnd (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_SeqRecord_DrainEventRingAtTakeEnd holds `jp 0x00F49806`, and 0xF49806 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_DrainEventRingAtTakeEnd: Veneer (slot T_SeqRecord_DrainEventRingAtTakeEnd): `jr` to 0xF49868 (SeqRecord_SoundAlert_Join): (0x34DD) b1 set
;   around SeqRecord_WriteRingEventsToTracks -- the drain that writes SeqBuf_Ring's events into the take tracks -- then (0x34DD) b1 and
;   (0x34D4) b1 cleared; unlike SeqRecord_DrainEventRing no (0x3004) test. SeqRecord_EndTake runs it before
;   SeqRecord_TerminateTakeTracks. Basis: caller + body + sibling. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_p.json)
SeqRecord_DrainEventRingAtTakeEnd:		; <- T_SeqRecord_DrainEventRingAtTakeEnd
	jr	SeqRecord_SoundAlert_Join	; F49806  jr T,0xf49868

; --------------------------------------------------------------------------
; SeqRecord_DrainEventRing
; Called from: T_SeqRecord_DrainEventRing (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_SeqRecord_DrainEventRing holds `jp 0x00F49808`, and 0xF49808 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_DrainEventRing: `jr` into 0xF4987B: while a take runs ((0x3004) non-zero) clears (0x34D0) bit 3 and runs
;   SeqRecord_WriteRingEventsToTracks, which takes every event out of SeqBuf_Ring (0x81 beat marks, 0x9n, 0xBn, 0xCn, 0xD0-0xD3) and writes
;   it into its track through the block-store cursor; then clears (0x34DD) bit 1 and (0x34D4) bit 1.
;   Seq_MainLoopService calls it every pass through T_SeqRecord_DrainEventRing. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_l.json)
SeqRecord_DrainEventRing:		; <- T_SeqRecord_DrainEventRing
	jr	SeqRecord_SoundAlert_Join2	; F49808  jr T,0xf4987b

; --------------------------------------------------------------------------
; sub_F4980A
; Called from: T_F40BD4 (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_F40BD4 holds `jp 0x00F4980A`, and 0xF4980A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4980A:		; <- T_F40BD4
	jrl	sub_F4A50E_Join	; F4980A  jrl T,0xf4a51f

; --------------------------------------------------------------------------
; SeqRecord_LoadTakeCursor
; Called from: in-module: 0xF49D34 0xF49F95 0xF4A2EA 0xF4A404
; Touches: (0x345C) (0x345E)  |  0x00340C 0x00342E
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4980D is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_LoadTakeCursor: Block-store cursor := track C's take cursor (BStore_CursorBlock := 0x340C[C],
;   BStore_CursorOffset := 0x342E[C]) -- the arrays SeqRecord_AllocTakeChains points at each take track's first block.
;   The body behind SeqRecord_LoadTakeCursor_Veneer; inverse of SeqRecord_SaveTakeCursor. Basis: caller (veneer
;   header) + body + array writer. (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
SeqRecord_LoadTakeCursor:
	xor	wa, wa	; F4980D  xor WA,WA
	ld	a, c	; F4980F  ld A,C
	ld	iy, wa	; F49811  ld IY,WA
	ld	xhl, 13324	; F49813  ld XHL,0x0000340c
	sla	iy, 1	; F49818  sla 0x01,IY
	ld	wa, (xhl+iy)	; F4981B  ld WA,(XHL+IY)
	ld	(BStore_CursorBlock:16), wa	; F49820  ld (0x345c),WA
	ld	xhl, 13358	; F49824  ld XHL,0x0000342e
	srl	iy, 1	; F49829  srl 0x01,IY
	xor	wa, wa	; F4982C  xor WA,WA
	ld	a, (xhl+iy)	; F4982E  ld A,(XHL+IY)
	ld	(BStore_CursorOffset:16), wa	; F49833  ld (0x345e),WA
	ret	; F49837  ret

; --------------------------------------------------------------------------
; SeqRecord_SaveTakeCursor
; Called from: in-module: 0xF49D84 0xF4A0FB 0xF4A3DE 0xF4A4DF
; Touches: (0x345C) (0x345E)  |  0x00340C 0x00342E
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49838 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_SaveTakeCursor: Track C's take cursor := the block-store cursor (0x340C[C] := BStore_CursorBlock,
;   0x342E[C] := BStore_CursorOffset). The body behind SeqRecord_SaveTakeCursor_Veneer; inverse of
;   SeqRecord_LoadTakeCursor. Basis: caller (veneer header) + body + inverse. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_s.json)
SeqRecord_SaveTakeCursor:
	xor	wa, wa	; F49838  xor WA,WA
	ld	a, c	; F4983A  ld A,C
	ld	iy, wa	; F4983C  ld IY,WA
	ld	xhl, 13324	; F4983E  ld XHL,0x0000340c
	sla	iy, 1	; F49843  sla 0x01,IY
	ld	wa, (BStore_CursorBlock:16)	; F49846  ld WA,(0x345c)
	ld	(xhl+iy), wa	; F4984A  ld (XHL+IY),WA
	ld	xhl, 13358	; F4984F  ld XHL,0x0000342e
	ld	wa, (BStore_CursorOffset:16)	; F49854  ld WA,(0x345e)
	srl	iy, 1	; F49858  srl 0x01,IY
	ld	(xhl+iy), a	; F4985B  ld (XHL+IY),A
	ret	; F49860  ret

; --------------------------------------------------------------------------
; SeqRecord_SoundAlert
; Called from: in-module: 0xF49B3F 0xF4A501
; Touches: (0x3004) (0x34D0) (0x34D4) (0x34DD)  |  0x000000
; Calls:   T_F41020 SeqRecord_WriteRingEventsToTracks
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49861 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_SoundAlert: Posts the CPU-2 message F0 50 87 08 (A = 8, T_F41020 = Msg0716_PostSysEx50_87), the alert
;   DiskError_SoundAlertAndWait also sends. The target of SeqRecord_SoundAlert_Veneer; also called directly after a
;   take track is terminated (SeqRecord_TerminateTrackOnMemoryFull), and from SeqRecord_ResetControllersAfterRingOverflow only when the ROM byte at 0xFFFFF8 is >= 0x10 (it is
;   0x02). Its tail labels (0xF49868, 0xF4987B) are the drain entries of SeqRecord_DrainEventRing*. Basis: caller
;   header + body. (notes/naming-pilot-2026-10-06/proposals_wave8_a8.json)
SeqRecord_SoundAlert:
	ld	a, 8:opc	; F49861  ld A,0x08
	call	T_F41020	; F49863  call 0xf41020
	ret	; F49867  ret
SeqRecord_SoundAlert_Join:
	or	(0x34dd:16), 0x02	; F49868  or (0x34dd),0x02
	calr	SeqRecord_WriteRingEventsToTracks	; F4986D  calr 0xf498a0
	and	(0x34dd:16), 0xfd	; F49870  and (0x34dd),0xfd
	and	(0x34d4:16), 0xfd	; F49875  and (0x34d4),0xfd
	ret	; F4987A  ret
SeqRecord_SoundAlert_Join2:
	ld	xwa, (12292:16)	; F4987B  ld XWA,(0x3004)
	cp	xwa, 0	; F4987F  cp XWA,0x00000000
	jr	z, SeqRecord_SoundAlert_Skip2	; F49885  jr Z,0xf49895
	bit	3, (0x34d0:16)	; F49887  bit 3,(0x34d0)
	jr	z, SeqRecord_SoundAlert_Skip	; F4988B  jr Z,0xf49892
	and	(0x34d0:16), 0xf7	; F4988D  and (0x34d0),0xf7
SeqRecord_SoundAlert_Skip:
	calr	SeqRecord_WriteRingEventsToTracks	; F49892  calr 0xf498a0
SeqRecord_SoundAlert_Skip2:
	and	(0x34dd:16), 0xfd	; F49895  and (0x34dd),0xfd
	and	(0x34d4:16), 0xfd	; F4989A  and (0x34d4),0xfd
	ret	; F4989F  ret

; --------------------------------------------------------------------------
; SeqRecord_WriteRingEventsToTracks
; Called from: in-module: 0xF4986D 0xF49892
; Touches: (0x349F) (0x34AA) (0x34AB) (0x34AD) (0x34AE) (0x34B0) (0x34D4)
;          (0x34DD) (0x36F0)  |  0x0034AA 0x600A0A 0x600A14
; Calls:   T_SeqBufRing_IsEmpty SeqRecord_CloseHeldNotesAtCycleWrap SeqRecord_ResetControllersAfterRingOverflow SeqRecord_ReadRingEvent CycleRecord_CheckIsRecordTrack SeqRecord_WriteCtrlEventToTakeTrack
;          CycleRecord_WriteEventToRecordTrack SeqRecord_SkipUnhandledRingEvent SeqRecord_CloseHeldNote SeqRecord_WriteNoteOn CycleRecord_WriteNoteOnToRecordTrack SeqRecord_WriteEventToTakeTrack
;          +4 more
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF498A0 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_WriteRingEventsToTracks: Takes events out of SeqBuf_Ring until it is empty (T_SeqBufRing_IsEmpty) and
;   writes each into its track by type: 0x81 beat mark, 0x9n, 0xBn, 0xCn, 0xD0-0xD3 (record tracks via
;   CycleRecord_CheckIsRecordTrack, others another path). The drain body that SeqRecord_DrainEventRing and
;   SeqRecord_DrainEventRingAtTakeEnd reach. Basis: callers' headers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_d9.json)
SeqRecord_WriteRingEventsToTracks:
	call	T_SeqBufRing_IsEmpty	; F498A0  call 0xf41d90
	cp	wa, 0:i3	; F498A4  cp WA,0
	jr	nz, SeqRecord_WriteRingEventsToTracks_Skip12	; F498A6  jr NZ,0xf498b1
	calr	SeqRecord_CloseHeldNotesAtCycleWrap	; F498A8  calr 0xf49ade
	calr	SeqRecord_ResetControllersAfterRingOverflow	; F498AB  calr 0xf49afd
	jrl	SeqRecord_WriteRingEventsToTracks_Return	; F498AE  jrl T,0xf49a3c
SeqRecord_WriteRingEventsToTracks_Skip12:
	bit	1, (0x34dd:16)	; F498B1  bit 1,(0x34dd)
	jr	nz, SeqRecord_WriteRingEventsToTracks_Skip13	; F498B5  jr NZ,0xf498bd
	bit	1, (0x34d4:16)	; F498B7  bit 1,(0x34d4)
	jr	nz, SeqRecord_WriteRingEventsToTracks_Skip13	; F498BB  jr NZ,0xf498bd
SeqRecord_WriteRingEventsToTracks_Skip13:
	ld	xhl, 6294026	; F498BD  ld XHL,0x00600a0a
	ld	iy, (xhl+2)	; F498C2  ld IY,(XHL+0x02)
	ld	xhl, SeqBuf_Ring	; F498C5  ld XHL,0x00600a14
	ld	a, (xhl+iy)	; F498CA  ld A,(XHL+IY)
	cp	a, 129	; F498CF  cp A,0x81
	jrl	z, SeqRecord_WriteRingEventsToTracks_Skip15	; F498D2  jrl Z,0xf499bc
	ld	w, 240:opc	; F498D5  ld W,0xf0
	and	w, a	; F498D7  and W,A
	cp	w, 144	; F498D9  cp W,0x90
	jr	z, SeqRecord_WriteRingEventsToTracks_Skip14	; F498DC  jr Z,0xf49937
	cp	a, 210	; F498DE  cp A,0xd2
	jrl	z, SeqRecord_WriteRingEventsToTracks_Skip16	; F498E1  jrl Z,0xf499da
	cp	a, 209	; F498E4  cp A,0xd1
	jrl	z, SeqRecord_WriteRingEventsToTracks_Join	; F498E7  jrl Z,0xf49a0b
	cp	a, 211	; F498EA  cp A,0xd3
	jr	nz, SeqRecord_WriteRingEventsToTracks_Skip2	; F498ED  jr NZ,0xf4991e
	ldw	bc, 4	; F498EF  ld BC,0x0004
	calr	SeqRecord_ReadRingEvent	; F498F2  calr 0xf49ca9
	ld	a, (13485:16)	; F498F5  ld A,(0x34ad)
	ld	(13471:16), a	; F498F9  ld (0x349f),A
	calr	CycleRecord_CheckIsRecordTrack	; F498FD  calr 0xf49a3d
	cp	a, 0:i3	; F49900  cp A,0
	jr	z, SeqRecord_WriteRingEventsToTracks_Skip	; F49902  jr Z,0xf4990c
	ldw	de, 3	; F49904  ld DE,0x0003
	calr	SeqRecord_WriteCtrlEventToTakeTrack	; F49907  calr 0xf4a2b6
	jr	SeqRecord_WriteRingEventsToTracks	; F4990A  jr T,0xf498a0
SeqRecord_WriteRingEventsToTracks_Skip:
	ld	(14064:16), 3	; F4990C  ld (0x36f0),0x03
	ld	a, (13485:16)	; F49911  ld A,(0x34ad)
	ld	(13471:16), a	; F49915  ld (0x349f),A
	calr	CycleRecord_WriteEventToRecordTrack	; F49919  calr 0xf49ce6
	jr	SeqRecord_WriteRingEventsToTracks	; F4991C  jr T,0xf498a0
SeqRecord_WriteRingEventsToTracks_Skip2:
	cp	a, 208	; F4991E  cp A,0xd0
	jr	nz, SeqRecord_WriteRingEventsToTracks_Skip3	; F49921  jr NZ,0xf49926
	jrl	SeqRecord_WriteRingEventsToTracks_Join	; F49923  jrl T,0xf49a0b
SeqRecord_WriteRingEventsToTracks_Skip3:
	cp	w, 192	; F49926  cp W,0xc0
	jr	z, SeqRecord_WriteRingEventsToTracks_Skip7	; F49929  jr Z,0xf4997d
	cp	w, 176	; F4992B  cp W,0xb0
	jrl	z, SeqRecord_WriteRingEventsToTracks_Skip9	; F4992E  jrl Z,0xf499cb
	calr	SeqRecord_SkipUnhandledRingEvent	; F49931  calr 0xf49c7d
	jrl	SeqRecord_WriteRingEventsToTracks	; F49934  jrl T,0xf498a0
SeqRecord_WriteRingEventsToTracks_Skip14:
	ldw	bc, 5	; F49937  ld BC,0x0005
	calr	SeqRecord_ReadRingEvent	; F4993A  calr 0xf49ca9
	bit	1, (0x34d4:16)	; F4993D  bit 1,(0x34d4)
	jr	z, SeqRecord_WriteRingEventsToTracks_Skip4	; F49941  jr Z,0xf49948
	ld	(13483:16), 0	; F49943  ld (0x34ab),0x00
SeqRecord_WriteRingEventsToTracks_Skip4:
	cp	(0x34ad:16), 0x00	; F49948  cp (0x34ad),0x00
	jr	nz, SeqRecord_WriteRingEventsToTracks_Skip5	; F4994D  jr NZ,0xf49955
	calr	SeqRecord_CloseHeldNote	; F4994F  calr 0xf4a0ff
	jrl	SeqRecord_WriteRingEventsToTracks	; F49952  jrl T,0xf498a0
SeqRecord_WriteRingEventsToTracks_Skip5:
	ld	a, (13486:16)	; F49955  ld A,(0x34ae)
	ld	(13471:16), a	; F49959  ld (0x349f),A
	calr	CycleRecord_CheckIsRecordTrack	; F4995D  calr 0xf49a3d
	cp	a, 0:i3	; F49960  cp A,0
	jr	z, SeqRecord_WriteRingEventsToTracks_Skip6	; F49962  jr Z,0xf4996a
	calr	SeqRecord_WriteNoteOn	; F49964  calr 0xf49f6d
	jrl	SeqRecord_WriteRingEventsToTracks	; F49967  jrl T,0xf498a0
SeqRecord_WriteRingEventsToTracks_Skip6:
	ld	a, (13486:16)	; F4996A  ld A,(0x34ae)
	ld	(13471:16), a	; F4996E  ld (0x349f),A
	ld	(14064:16), 6	; F49972  ld (0x36f0),0x06
	calr	CycleRecord_WriteNoteOnToRecordTrack	; F49977  calr 0xf49cc2
	jrl	SeqRecord_WriteRingEventsToTracks	; F4997A  jrl T,0xf498a0
SeqRecord_WriteRingEventsToTracks_Skip7:
	ldw	bc, 7	; F4997D  ld BC,0x0007
	calr	SeqRecord_ReadRingEvent	; F49980  calr 0xf49ca9
	ld	a, (13488:16)	; F49983  ld A,(0x34b0)
	ld	(13471:16), a	; F49987  ld (0x349f),A
	calr	CycleRecord_CheckIsRecordTrack	; F4998B  calr 0xf49a3d
	cp	a, 0:i3	; F4998E  cp A,0
	jr	z, SeqRecord_WriteRingEventsToTracks_Skip8	; F49990  jr Z,0xf499a9
	ldw	de, 6	; F49992  ld DE,0x0006
	ld	hl, de	; F49995  ld HL,DE
	xor	bc, bc	; F49997  xor BC,BC
	ld	xix, 13482	; F49999  ld XIX,0x000034aa
	ld	c, (xix+hl)	; F4999E  ld C,(XIX+HL)
	calr	SeqRecord_WriteEventToTakeTrack	; F499A3  calr 0xf4a2c8
	jrl	SeqRecord_WriteRingEventsToTracks	; F499A6  jrl T,0xf498a0
SeqRecord_WriteRingEventsToTracks_Skip8:
	ld	(14064:16), 6	; F499A9  ld (0x36f0),0x06
	ld	a, (13488:16)	; F499AE  ld A,(0x34b0)
	ld	(13471:16), a	; F499B2  ld (0x349f),A
	calr	CycleRecord_WriteEventToRecordTrack	; F499B6  calr 0xf49ce6
	jrl	SeqRecord_WriteRingEventsToTracks	; F499B9  jrl T,0xf498a0
SeqRecord_WriteRingEventsToTracks_Skip15:
	ld	(13482:16), 129	; F499BC  ld (0x34aa),0x81
	call	T_SeqBufRing_Get	; F499C1  call 0xf41d84
	calr	SeqRecord_WriteBeatMarkAndAgeHeldNotes	; F499C5  calr 0xf49d00
	jrl	SeqRecord_WriteRingEventsToTracks	; F499C8  jrl T,0xf498a0
SeqRecord_WriteRingEventsToTracks_Skip9:
	ldw	bc, 7	; F499CB  ld BC,0x0007
	calr	SeqRecord_ReadRingEvent	; F499CE  calr 0xf49ca9
	ldw	de, 6	; F499D1  ld DE,0x0006
	calr	SeqRecord_WriteParamEvent	; F499D4  calr 0xf4a26d
	jrl	SeqRecord_WriteRingEventsToTracks	; F499D7  jrl T,0xf498a0
SeqRecord_WriteRingEventsToTracks_Skip16:
	ldw	bc, 5	; F499DA  ld BC,0x0005
	calr	SeqRecord_ReadRingEvent	; F499DD  calr 0xf49ca9
	ld	a, (13486:16)	; F499E0  ld A,(0x34ae)
	ld	(13471:16), a	; F499E4  ld (0x349f),A
	calr	CycleRecord_CheckIsRecordTrack	; F499E8  calr 0xf49a3d
	cp	a, 0:i3	; F499EB  cp A,0
	jr	z, SeqRecord_WriteRingEventsToTracks_Skip10	; F499ED  jr Z,0xf499f8
	ldw	de, 4	; F499EF  ld DE,0x0004
	calr	SeqRecord_WritePitchBendToTakeTrack	; F499F2  calr 0xf4a2a4
	jrl	SeqRecord_WriteRingEventsToTracks	; F499F5  jrl T,0xf498a0
SeqRecord_WriteRingEventsToTracks_Skip10:
	ld	(14064:16), 4	; F499F8  ld (0x36f0),0x04
	ld	a, (13486:16)	; F499FD  ld A,(0x34ae)
	ld	(13471:16), a	; F49A01  ld (0x349f),A
	calr	CycleRecord_WriteEventToRecordTrack	; F49A05  calr 0xf49ce6
	jrl	SeqRecord_WriteRingEventsToTracks	; F49A08  jrl T,0xf498a0
SeqRecord_WriteRingEventsToTracks_Join:
	ldw	bc, 4	; F49A0B  ld BC,0x0004
	calr	SeqRecord_ReadRingEvent	; F49A0E  calr 0xf49ca9
	ld	a, (13485:16)	; F49A11  ld A,(0x34ad)
	ld	(13471:16), a	; F49A15  ld (0x349f),A
	calr	CycleRecord_CheckIsRecordTrack	; F49A19  calr 0xf49a3d
	cp	a, 0:i3	; F49A1C  cp A,0
	jr	z, SeqRecord_WriteRingEventsToTracks_Skip11	; F49A1E  jr Z,0xf49a29
	ldw	de, 3	; F49A20  ld DE,0x0003
	calr	SeqRecord_WriteCtrlEventToTakeTrack	; F49A23  calr 0xf4a2b6
	jrl	SeqRecord_WriteRingEventsToTracks	; F49A26  jrl T,0xf498a0
SeqRecord_WriteRingEventsToTracks_Skip11:
	ld	(14064:16), 3	; F49A29  ld (0x36f0),0x03
	ld	a, (13485:16)	; F49A2E  ld A,(0x34ad)
	ld	(13471:16), a	; F49A32  ld (0x349f),A
	calr	CycleRecord_WriteEventToRecordTrack	; F49A36  calr 0xf49ce6
	jrl	SeqRecord_WriteRingEventsToTracks	; F49A39  jrl T,0xf498a0
SeqRecord_WriteRingEventsToTracks_Return:
	ret	; F49A3C  ret

; --------------------------------------------------------------------------
; CycleRecord_CheckIsRecordTrack
; Called from: T_CycleRecord_CheckIsRecordTrack (x9); in-module: 0xF498FD 0xF4995D 0xF4998B 0xF499E8
;              0xF49A19 0xF49CC2 0xF49CE6 0xF49D2D +1 more
; Touches: (0x207A) (0x3000) (0x349F) (0x34AA) (0x34AB) (0x34AC) (0x34AD)
;          (0x34AE) (0x34AF) (0x34B0) +9 more  |  0x000000
; Evidence: thunk slot T_CycleRecord_CheckIsRecordTrack holds `jp 0x00F49A3D`, and 0xF49A3D is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CheckIsRecordTrack: A := 0 when tracks are record-armed ((0x3000) != 0), the screen latch is a CYCLE
;   RECORD screen (6 or 8), the track in (0x349F) is the cycle record track (0x36D6) and the CYCLE switch ((0x360B)
;   bit 1) is on; otherwise A := 0xFF. Preserves XBC. SeqCycle_LocateToStart and the cycle deferred actions call it
;   (slot T_CycleRecord_CheckIsRecordTrack) with (0x349F) := (0x36D6) and branch on A == 0. Basis: callers + body + CycleRecord_CheckOn /
;   SetUpRecordTrack headers. (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
CycleRecord_CheckIsRecordTrack:		; <- T_CycleRecord_CheckIsRecordTrack
	xor	a, a	; F49A3D  xor A,A
	push	xbc	; F49A3F  push XBC
	ld	xbc, (12288:16)	; F49A40  ld XBC,(0x3000)
	cp	xbc, 0	; F49A44  cp XBC,0x00000000
	jr	z, CycleRecord_CheckIsRecordTrack_Skip2	; F49A4A  jr Z,0xf49a6a
	cp	(UI_ScreenLatch:16), 0x06	; F49A4C  cp (0x207a),0x06
	jr	z, CycleRecord_CheckIsRecordTrack_Skip	; F49A51  jr Z,0xf49a5a
	cp	(UI_ScreenLatch:16), 0x08	; F49A53  cp (0x207a),0x08
	jr	nz, CycleRecord_CheckIsRecordTrack_Skip2	; F49A58  jr NZ,0xf49a6a
CycleRecord_CheckIsRecordTrack_Skip:
	ld	b, (13471:16)	; F49A5A  ld B,(0x349f)
	cp	b, (0x36d6:16)	; F49A5E  cp B,(0x36d6)
	jr	nz, CycleRecord_CheckIsRecordTrack_Skip2	; F49A62  jr NZ,0xf49a6a
	bit	1, (0x360b:16)	; F49A64  bit 1,(0x360b)
	jr	nz, CycleRecord_CheckIsRecordTrack_Epilogue	; F49A68  jr NZ,0xf49a6c
CycleRecord_CheckIsRecordTrack_Skip2:
	ld	a, 255:opc	; F49A6A  ld A,0xff
CycleRecord_CheckIsRecordTrack_Epilogue:
	pop	xbc	; F49A6C  pop XBC
	ret	; F49A6D  ret
	ld	a, (13846:16)	; F49A6E  ld A,(0x3616)
	bit	7, (0x361a:16)	; F49A72  bit 7,(0x361a)
	jr	z, CycleRecord_CheckIsRecordTrack_Skip3	; F49A76  jr Z,0xf49a83
	set	0, a	; F49A78  set 0x00,A
	ld	(13846:16), a	; F49A7B  ld (0x3616),A
	res	7, (0x361a:16)	; F49A7F  res 7,(0x361a)
CycleRecord_CheckIsRecordTrack_Skip3:
	bit	7, (0x361b:16)	; F49A83  bit 7,(0x361b)
	jr	z, CycleRecord_CheckIsRecordTrack_Skip4	; F49A87  jr Z,0xf49a94
	set	1, a	; F49A89  set 0x01,A
	ld	(13846:16), a	; F49A8C  ld (0x3616),A
	res	7, (0x361b:16)	; F49A90  res 7,(0x361b)
CycleRecord_CheckIsRecordTrack_Skip4:
	bit	7, (0x3618:16)	; F49A94  bit 7,(0x3618)
	jr	z, CycleRecord_CheckIsRecordTrack_Skip5	; F49A98  jr Z,0xf49aa5
	set	2, a	; F49A9A  set 0x02,A
	ld	(13846:16), a	; F49A9D  ld (0x3616),A
	res	7, (0x3618:16)	; F49AA1  res 7,(0x3618)
CycleRecord_CheckIsRecordTrack_Skip5:
	ld	a, (13846:16)	; F49AA5  ld A,(0x3616)
	ld	(13482:16), a	; F49AA9  ld (0x34aa),A
	ld	a, (13847:16)	; F49AAD  ld A,(0x3617)
	ld	(13483:16), a	; F49AB1  ld (0x34ab),A
	ld	a, (13848:16)	; F49AB5  ld A,(0x3618)
	ld	(13484:16), a	; F49AB9  ld (0x34ac),A
	ld	a, (13849:16)	; F49ABD  ld A,(0x3619)
	ld	(13485:16), a	; F49AC1  ld (0x34ad),A
	ld	a, (13850:16)	; F49AC5  ld A,(0x361a)
	ld	(13486:16), a	; F49AC9  ld (0x34ae),A
	ld	a, (13851:16)	; F49ACD  ld A,(0x361b)
	ld	(13487:16), a	; F49AD1  ld (0x34af),A
	ld	a, (13852:16)	; F49AD5  ld A,(0x361c)
	ld	(13488:16), a	; F49AD9  ld (0x34b0),A
	ret	; F49ADD  ret

; --------------------------------------------------------------------------
; SeqRecord_CloseHeldNotesAtCycleWrap
; Called from: in-module: 0xF498A8
; Touches: (0x34AA) (0x34AB) (0x34B8) (0x34B9)
; Calls:   SeqRecord_CloseAllHeldNotes
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49ADE is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_CloseHeldNotesAtCycleWrap: When (0x34B8) bit 4 is set -- only 0xF45F95 sets it, when the cycle-record
;   measure (0x3552) reaches the cycle end (0x3624) and is put back to the start (0x3622) -- (0x34B9) := the last
;   event's tick ((0x34AB), 0 after a 0x81 beat mark) and SeqRecord_CloseAllHeldNotes closes every held note of every take track at
;   that tick (SeqRecord_CloseHeldNote per slot); bit 4 cleared. SeqRecord_WriteRingEventsToTracks runs it once
;   SeqBuf_Ring is empty. Basis: caller + body + flag writer. (notes/naming-
;   pilot-2026-10-06/proposals_wave10_b10.json)
SeqRecord_CloseHeldNotesAtCycleWrap:
	bit	4, (0x34b8:16)	; F49ADE  bit 4,(0x34b8)
	jr	z, SeqRecord_CloseHeldNotesAtCycleWrap_Return	; F49AE2  jr Z,0xf49afc
	ld	a, (13483:16)	; F49AE4  ld A,(0x34ab)
	cp	(0x34aa:16), 0x81	; F49AE8  cp (0x34aa),0x81
	jr	nz, SeqRecord_CloseHeldNotesAtCycleWrap_Skip6	; F49AED  jr NZ,0xf49af1
	xor	a, a	; F49AEF  xor A,A
SeqRecord_CloseHeldNotesAtCycleWrap_Skip6:
	ld	(13497:16), a	; F49AF1  ld (0x34b9),A
	calr	SeqRecord_CloseAllHeldNotes	; F49AF5  calr 0xf49bfa
	res	4, (0x34b8:16)	; F49AF8  res 4,(0x34b8)
SeqRecord_CloseHeldNotesAtCycleWrap_Return:
	ret	; F49AFC  ret

; --------------------------------------------------------------------------
; SeqRecord_ResetControllersAfterRingOverflow
; Called from: in-module: 0xF498AB
; Touches: (0x34AA) (0x34AB) (0x34B8) (0x34B9)  |  0xFFFFF8
; Calls:   SeqRecord_WriteModulationResetToTakeTracks SeqRecord_WritePitchBendResetToTakeTracks SeqRecord_CloseAllHeldNotes SeqRecord_SoundAlert
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49AFD is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_ResetControllersAfterRingOverflow: Handles the (0x34B8) flags prom_a's SeqBuf tail ORs in when SeqBuf_Ring
;   has no room for an event ((0x60F31F) & 0xB0 >> 4: modulation 0x10 -> bit 0, pitch bend 0x20 -> bit 1): bit 0 ->
;   SeqRecord_WriteModulationResetToTakeTracks writes {0xD1, tick, 0} to every take track, bit 1 -> SeqRecord_WritePitchBendResetToTakeTracks {0xD2, tick, 0, 0x40}, bit 2 ->
;   SeqRecord_CloseAllHeldNotes closes all held notes; (0x34B8) := 0; SeqRecord_SoundAlert only if ROM byte 0xFFFFF8 >= 0x10 (it is
;   0x02). Run by SeqRecord_WriteRingEventsToTracks on an empty ring. Basis: caller + body + flag writer.
;   (notes/naming-pilot-2026-10-06/proposals_wave10_b10.json)
SeqRecord_ResetControllersAfterRingOverflow:
	cp	(0x34b8:16), 0x00	; F49AFD  cp (0x34b8),0x00
	jr	z, SeqRecord_ResetControllersAfterRingOverflow_Return2	; F49B02  jr Z,0xf49b42
	ld	a, (13483:16)	; F49B04  ld A,(0x34ab)
	cp	(0x34aa:16), 0x81	; F49B08  cp (0x34aa),0x81
	jr	nz, SeqRecord_ResetControllersAfterRingOverflow_Skip7	; F49B0D  jr NZ,0xf49b11
	xor	a, a	; F49B0F  xor A,A
SeqRecord_ResetControllersAfterRingOverflow_Skip7:
	ld	(13497:16), a	; F49B11  ld (0x34b9),A
	bit	0, (0x34b8:16)	; F49B15  bit 0,(0x34b8)
	jr	z, SeqRecord_ResetControllersAfterRingOverflow_Skip8	; F49B19  jr Z,0xf49b1e
	calr	SeqRecord_WriteModulationResetToTakeTracks	; F49B1B  calr 0xf49b43
SeqRecord_ResetControllersAfterRingOverflow_Skip8:
	bit	1, (0x34b8:16)	; F49B1E  bit 1,(0x34b8)
	jr	z, SeqRecord_ResetControllersAfterRingOverflow_Skip9	; F49B22  jr Z,0xf49b27
	calr	SeqRecord_WritePitchBendResetToTakeTracks	; F49B24  calr 0xf49b5c
SeqRecord_ResetControllersAfterRingOverflow_Skip9:
	bit	2, (0x34b8:16)	; F49B27  bit 2,(0x34b8)
	jr	z, SeqRecord_ResetControllersAfterRingOverflow_Skip10	; F49B2B  jr Z,0xf49b30
	calr	SeqRecord_CloseAllHeldNotes	; F49B2D  calr 0xf49bfa
SeqRecord_ResetControllersAfterRingOverflow_Skip10:
	ld	(13496:16), 0	; F49B30  ld (0x34b8),0x00
	ld	xiy, MIDI_UART_Configure_Data	; F49B35  ld XIY,0x00fffff8
	cp	(xiy), 0x10	; F49B3A  cp (XIY),0x10
	jr	c, SeqRecord_ResetControllersAfterRingOverflow_Return2	; F49B3D  jr C,0xf49b42
	calr	SeqRecord_SoundAlert	; F49B3F  calr 0xf49861
SeqRecord_ResetControllersAfterRingOverflow_Return2:
	ret	; F49B42  ret

; --------------------------------------------------------------------------
; SeqRecord_WriteModulationResetToTakeTracks
; Called from: in-module: 0xF49B1B
; Touches: (0x34AA) (0x34AB) (0x34AC) (0x34B9)
; Calls:   sub_F49B7A
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49B43 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_WriteModulationResetToTakeTracks: Builds the modulation event {0xD1, tick (0x34B9), 0} (DE = 3) and
;   sub_F49B7A writes it, slot byte := each track, to every track 0..16 still in the take via
;   SeqRecord_WriteCtrlEventToTakeTrack. SeqRecord_ResetControllersAfterRingOverflow runs it for (0x34B8) bit 0, a
;   modulation event lost to a full SeqBuf_Ring. Basis: caller + body + SeqBuf_PutModulationEvent's layout.
;   (notes/naming-pilot-2026-10-06/proposals_wave11_a11.json)
SeqRecord_WriteModulationResetToTakeTracks:
	ldw	de, 3	; F49B43  ld DE,0x0003
	ld	(13482:16), 209	; F49B46  ld (0x34aa),0xd1
	ld	a, (13497:16)	; F49B4B  ld A,(0x34b9)
	ld	(13483:16), a	; F49B4F  ld (0x34ab),A
	ld	(13484:16), 0	; F49B53  ld (0x34ac),0x00
	calr	sub_F49B7A	; F49B58  calr 0xf49b7a
	ret	; F49B5B  ret

; --------------------------------------------------------------------------
; SeqRecord_WritePitchBendResetToTakeTracks
; Called from: in-module: 0xF49B24
; Touches: (0x34AA) (0x34AB) (0x34AC) (0x34AD) (0x34B9)
; Calls:   sub_F49BBA
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49B5C is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_WritePitchBendResetToTakeTracks: Builds the pitch-bend centre event {0xD2, tick (0x34B9), 0x00, 0x40} (DE
;   = 4) for every take track (sub_F49BBA -> SeqRecord_WritePitchBendToTakeTrack); run by
;   SeqRecord_ResetControllersAfterRingOverflow for (0x34B8) bit 1. As built the loop stores the track at +3 (over the
;   0x40) while the writer takes the track from +4 (0x34AE), so each pass writes {0xD2, tick, 0, t} to track (0x34AE).
;   Basis: caller + body + SeqBuf_PutPitchBendEvent's layout. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_a11.json)
SeqRecord_WritePitchBendResetToTakeTracks:
	ldw	de, 4	; F49B5C  ld DE,0x0004
	ld	(13482:16), 210	; F49B5F  ld (0x34aa),0xd2
	ld	a, (13497:16)	; F49B64  ld A,(0x34b9)
	ld	(13483:16), a	; F49B68  ld (0x34ab),A
	ld	(13484:16), 0	; F49B6C  ld (0x34ac),0x00
	ld	(13485:16), 64	; F49B71  ld (0x34ad),0x40
	calr	sub_F49BBA	; F49B76  calr 0xf49bba
	ret	; F49B79  ret

; --------------------------------------------------------------------------
; sub_F49B7A
; Called from: in-module: 0xF49B58
; Touches: (0x3004) (0x3006) (0x349F) (0x34AD)
; Calls:   SeqRecord_WriteCtrlEventToTakeTrack
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49B7A is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F49B7A:
	ld	(13471:16), 0	; F49B7A  ld (0x349f),0x00
sub_F49B7A_Loop:
	xor	bc, bc	; F49B7F  xor BC,BC
	ld	c, (13471:16)	; F49B81  ld C,(0x349f)
	cp	c, 16	; F49B85  cp C,0x10
	jr	nc, sub_F49B7A_Skip	; F49B88  jr NC,0xf49b97
	ld	iz, (12292:16)	; F49B8A  ld IZ,(0x3004)
	ld	a, c	; F49B8E  ld A,C
	scf	; F49B90  scf
	xorcf_a_16	iz	; F49B91  xorcf A,IZ
	jr	c, sub_F49B7A_Skip2	; F49B93  jr C,0xf49bae
	jr	sub_F49B7A_Join	; F49B95  jr T,0xf49ba5
sub_F49B7A_Skip:
	ld	iz, (12294:16)	; F49B97  ld IZ,(0x3006)
	ld	a, c	; F49B9B  ld A,C
	sub	a, 16	; F49B9D  sub A,0x10
	scf	; F49BA0  scf
	xorcf_a_16	iz	; F49BA1  xorcf A,IZ
	jr	c, sub_F49B7A_Skip2	; F49BA3  jr C,0xf49bae
sub_F49B7A_Join:
	ld	(13485:16), c	; F49BA5  ld (0x34ad),C
	pushw	de	; F49BA9  push DE
	calr	SeqRecord_WriteCtrlEventToTakeTrack	; F49BAA  calr 0xf4a2b6
	popw	de	; F49BAD  pop DE
sub_F49B7A_Skip2:
	inc	1, (13471:16)	; F49BAE  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F49BB2  cp (0x349f),0x11
	jr	c, sub_F49B7A_Loop	; F49BB7  jr C,0xf49b7f
	ret	; F49BB9  ret

; --------------------------------------------------------------------------
; sub_F49BBA
; Called from: in-module: 0xF49B76
; Touches: (0x3004) (0x3006) (0x349F) (0x34AD)
; Calls:   SeqRecord_WritePitchBendToTakeTrack
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49BBA is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F49BBA:
	ld	(13471:16), 0	; F49BBA  ld (0x349f),0x00
sub_F49BBA_Loop:
	xor	bc, bc	; F49BBF  xor BC,BC
	ld	c, (13471:16)	; F49BC1  ld C,(0x349f)
	cp	c, 16	; F49BC5  cp C,0x10
	jr	nc, sub_F49BBA_Skip	; F49BC8  jr NC,0xf49bd7
	ld	iz, (12292:16)	; F49BCA  ld IZ,(0x3004)
	ld	a, c	; F49BCE  ld A,C
	scf	; F49BD0  scf
	xorcf_a_16	iz	; F49BD1  xorcf A,IZ
	jr	c, sub_F49BBA_Skip2	; F49BD3  jr C,0xf49bee
	jr	sub_F49BBA_Join	; F49BD5  jr T,0xf49be5
sub_F49BBA_Skip:
	ld	iz, (12294:16)	; F49BD7  ld IZ,(0x3006)
	ld	a, c	; F49BDB  ld A,C
	sub	a, 16	; F49BDD  sub A,0x10
	scf	; F49BE0  scf
	xorcf_a_16	iz	; F49BE1  xorcf A,IZ
	jr	c, sub_F49BBA_Skip2	; F49BE3  jr C,0xf49bee
sub_F49BBA_Join:
	ld	(13485:16), c	; F49BE5  ld (0x34ad),C
	pushw	de	; F49BE9  push DE
	calr	SeqRecord_WritePitchBendToTakeTrack	; F49BEA  calr 0xf4a2a4
	popw	de	; F49BED  pop DE
sub_F49BBA_Skip2:
	inc	1, (13471:16)	; F49BEE  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F49BF2  cp (0x349f),0x11
	jr	c, sub_F49BBA_Loop	; F49BF7  jr C,0xf49bbf
	ret	; F49BF9  ret

; --------------------------------------------------------------------------
; SeqRecord_CloseAllHeldNotes
; Called from: in-module: 0xF49AF5 0xF49B2D
; Touches: (0x3004) (0x3006) (0x33DA) (0x33DE) (0x349F) (0x34AB) (0x34AC)
;          (0x34AE) (0x34B9)
; Calls:   SeqRecord_LoadHeldNoteListHeadTail SeqRecord_HeldNoteSlotAddress SeqRecord_CloseHeldNote
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49BFA is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_CloseAllHeldNotes: For every track 0..16 still in the take, walks its held-note list (head 0x3016[2t],
;   slots linked by +7) and closes each note at tick (0x34B9) through SeqRecord_CloseHeldNote ((0x34AC) := note,
;   (0x34AE) := track). Run by SeqRecord_CloseHeldNotesAtCycleWrap and, for (0x34B8) bit 2, by
;   SeqRecord_ResetControllersAfterRingOverflow. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_a11.json)
SeqRecord_CloseAllHeldNotes:
	ld	(13471:16), 0	; F49BFA  ld (0x349f),0x00
SeqRecord_CloseAllHeldNotes_Loop:
	xor	bc, bc	; F49BFF  xor BC,BC
	ld	c, (13471:16)	; F49C01  ld C,(0x349f)
	cp	c, 16	; F49C05  cp C,0x10
	jr	nc, SeqRecord_CloseAllHeldNotes_Skip	; F49C08  jr NC,0xf49c17
	ld	iz, (12292:16)	; F49C0A  ld IZ,(0x3004)
	ld	a, c	; F49C0E  ld A,C
	scf	; F49C10  scf
	xorcf_a_16	iz	; F49C11  xorcf A,IZ
	jr	c, SeqRecord_CloseAllHeldNotes_Skip2	; F49C13  jr C,0xf49c71
	jr	SeqRecord_CloseAllHeldNotes_Join	; F49C15  jr T,0xf49c25
SeqRecord_CloseAllHeldNotes_Skip:
	ld	iz, (12294:16)	; F49C17  ld IZ,(0x3006)
	ld	a, c	; F49C1B  ld A,C
	sub	a, 16	; F49C1D  sub A,0x10
	scf	; F49C20  scf
	xorcf_a_16	iz	; F49C21  xorcf A,IZ
	jr	c, SeqRecord_CloseAllHeldNotes_Skip2	; F49C23  jr C,0xf49c71
SeqRecord_CloseAllHeldNotes_Join:
	calr	SeqRecord_LoadHeldNoteListHeadTail	; F49C25  calr 0xf4a53e
	cp	(0x33da:16), 0x00	; F49C28  cp (0x33da),0x00
	jr	z, SeqRecord_CloseAllHeldNotes_Skip2	; F49C2D  jr Z,0xf49c71
	xor	hl, hl	; F49C2F  xor HL,HL
	ld	l, (13274:16)	; F49C31  ld L,(0x33da)
SeqRecord_CloseAllHeldNotes_Join2:
	calr	SeqRecord_HeldNoteSlotAddress	; F49C35  calr 0xf4a56c
	ld	a, (xhl+7)	; F49C38  ld A,(XHL+0x07)
	ld	(13278:16), a	; F49C3B  ld (0x33de),A
	ld	a, (13497:16)	; F49C3F  ld A,(0x34b9)
	ld	(13483:16), a	; F49C43  ld (0x34ab),A
	ld	a, (xhl)	; F49C47  ld A,(XHL)
	ld	(13484:16), a	; F49C49  ld (0x34ac),A
	ld	c, (13471:16)	; F49C4D  ld C,(0x349f)
	ld	(13486:16), c	; F49C51  ld (0x34ae),C
	ld	a, (13278:16)	; F49C55  ld A,(0x33de)
	pushw	wa	; F49C59  push WA
	calr	SeqRecord_CloseHeldNote	; F49C5A  calr 0xf4a0ff
	popw	wa	; F49C5D  pop WA
	ld	(13278:16), a	; F49C5E  ld (0x33de),A
	cp	(0x33de:16), 0xff	; F49C62  cp (0x33de),0xff
	jr	z, SeqRecord_CloseAllHeldNotes_Skip2	; F49C67  jr Z,0xf49c71
	xor	xhl, xhl	; F49C69  xor XHL,XHL
	ld	l, (13278:16)	; F49C6B  ld L,(0x33de)
	jr	SeqRecord_CloseAllHeldNotes_Join2	; F49C6F  jr T,0xf49c35
SeqRecord_CloseAllHeldNotes_Skip2:
	inc	1, (13471:16)	; F49C71  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F49C75  cp (0x349f),0x11
	jr	c, SeqRecord_CloseAllHeldNotes_Loop	; F49C7A  jr C,0xf49bff
	ret	; F49C7C  ret

; --------------------------------------------------------------------------
; SeqRecord_SkipUnhandledRingEvent
; Called from: in-module: 0xF49931
; Touches:   |  0x600A0A 0x600A14
; Calls:   T_SeqBufRing_IsEmpty T_SeqBufRing_Get
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49C7D is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_SkipUnhandledRingEvent: Takes the lead byte out of SeqBuf_Ring, then every following byte until the next
;   byte with bit 7 set (the next event's lead) or an empty ring. SeqRecord_WriteRingEventsToTracks's arm for a lead
;   byte that is none of 0x81, 0x9n, 0xBn, 0xCn, 0xD0-0xD3 -- e.g. SeqBuf_PutTempoEvent's 0x80. Basis: caller + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave10_b10.json)
SeqRecord_SkipUnhandledRingEvent:
	call	T_SeqBufRing_IsEmpty	; F49C7D  call 0xf41d90
	cp	wa, 0:i3	; F49C81  cp WA,0
	jr	z, SeqRecord_SkipUnhandledRingEvent_Return	; F49C83  jr Z,0xf49ca8
	call	T_SeqBufRing_Get	; F49C85  call 0xf41d84
	call	T_SeqBufRing_IsEmpty	; F49C89  call 0xf41d90
	cp	wa, 0:i3	; F49C8D  cp WA,0
	jr	z, SeqRecord_SkipUnhandledRingEvent_Return	; F49C8F  jr Z,0xf49ca8
	ld	xhl, 6294026	; F49C91  ld XHL,0x00600a0a
	ld	iy, (xhl+2)	; F49C96  ld IY,(XHL+0x02)
	ld	xhl, SeqBuf_Ring	; F49C99  ld XHL,0x00600a14
	ld	a, (xhl+iy)	; F49C9E  ld A,(XHL+IY)
	bit	7, a	; F49CA3  bit 0x07,A
	jr	z, SeqRecord_SkipUnhandledRingEvent	; F49CA6  jr Z,0xf49c7d
SeqRecord_SkipUnhandledRingEvent_Return:
	ret	; F49CA8  ret

; --------------------------------------------------------------------------
; SeqRecord_ReadRingEvent
; Called from: in-module: 0xF498F2 0xF4993A 0xF49980 0xF499CE 0xF499DD
;              0xF49A0E
; Touches:   |  0x0034AA
; Calls:   T_SeqBufRing_Get
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49CA9 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_ReadRingEvent: Takes BC bytes out of SeqBuf_Ring (T_SeqBufRing_Get) into the event record at
;   0x34AA[0..BC-1]. SeqRecord_WriteRingEventsToTracks calls it with the event's length: 4 for 0xD0/0xD1/0xD3, 5 for
;   0x9n and 0xD2, 7 for 0xBn/0xCn -- the layouts of prom_a's SeqBuf_Put*Event. Basis: caller + body + encoders.
;   (notes/naming-pilot-2026-10-06/proposals_wave10_b10.json)
SeqRecord_ReadRingEvent:
	xor	ix, ix	; F49CA9  xor IX,IX
SeqRecord_ReadRingEvent_Loop:
	call	T_SeqBufRing_Get	; F49CAB  call 0xf41d84
	ld	xhl, 13482	; F49CAF  ld XHL,0x000034aa
	ld	(xhl+ix), a	; F49CB4  ld (XHL+IX),A
	inc	1, ix	; F49CB9  inc 1,IX
	dec	1, bc	; F49CBB  dec 1,BC
	cp	bc, 0:i3	; F49CBD  cp BC,0
	jr	nz, SeqRecord_ReadRingEvent_Loop	; F49CBF  jr NZ,0xf49cab
	ret	; F49CC1  ret

; --------------------------------------------------------------------------
; CycleRecord_WriteNoteOnToRecordTrack
; Called from: in-module: 0xF49977
; Touches: (0x34AE) (0x34AF)  |  0x0034AA 0x0036E8
; Calls:   CycleRecord_CheckIsRecordTrack CycleRecord_WriteStagedEventToRecordTrack
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49CC2 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_WriteNoteOnToRecordTrack: For the cycle record track (CycleRecord_CheckIsRecordTrack A = 0): (0x34AE) :=
;   0x10, (0x34AF) := 0, making the note event [0x9n, tick, note, velocity, 0x10, 0x00] with the duration placeholder
;   SeqRecord_WriteNoteOn writes; copies 8 bytes of 0x34AA to 0x36E8 and CycleRecord_WriteStagedEventToRecordTrack writes (0x36F0) = 6 of them into
;   track (0x36D6) (sub_F4AEEE: BStore_AppendBytes, entry + 1). The drain's note-on arm for that track. Basis: caller
;   + body. (notes/naming-pilot-2026-10-06/proposals_wave10_b10.json)
CycleRecord_WriteNoteOnToRecordTrack:
	calr	CycleRecord_CheckIsRecordTrack	; F49CC2  calr 0xf49a3d
	cp	a, 0:i3	; F49CC5  cp A,0
	jr	nz, CycleRecord_WriteNoteOnToRecordTrack_Return	; F49CC7  jr NZ,0xf49ce5
	ld	(13486:16), 16	; F49CC9  ld (0x34ae),0x10
	ld	(13487:16), 0	; F49CCE  ld (0x34af),0x00
	ldw	bc, 8	; F49CD3  ld BC,0x0008
	ld	xde, 14056	; F49CD6  ld XDE,0x000036e8
	ld	xhl, 13482	; F49CDB  ld XHL,0x000034aa
	ldir83	; F49CE0  ldir
	calr	CycleRecord_WriteStagedEventToRecordTrack	; F49CE2  calr 0xf4abe8
CycleRecord_WriteNoteOnToRecordTrack_Return:
	ret	; F49CE5  ret

; --------------------------------------------------------------------------
; CycleRecord_WriteEventToRecordTrack
; Called from: in-module: 0xF49919 0xF499B6 0xF49A05 0xF49A36 0xF4A29E
; Touches:   |  0x0034AA 0x0036E8
; Calls:   CycleRecord_CheckIsRecordTrack CycleRecord_WriteStagedEventToRecordTrack
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49CE6 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_WriteEventToRecordTrack: For the cycle record track (CycleRecord_CheckIsRecordTrack A = 0): copies 8
;   bytes of the event record 0x34AA to 0x36E8 and CycleRecord_WriteStagedEventToRecordTrack writes (0x36F0) of them into track (0x36D6)'s chain
;   (sub_F4AEEE: BStore_AppendBytes on entry (0x36D6) + 1). The drain's 0xD0-0xD3 and 0xCn arms and
;   SeqRecord_WriteParamEvent set (0x36F0) := 3 / 4 / 6 first. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave10_b10.json)
CycleRecord_WriteEventToRecordTrack:
	calr	CycleRecord_CheckIsRecordTrack	; F49CE6  calr 0xf49a3d
	cp	a, 0:i3	; F49CE9  cp A,0
	jr	nz, CycleRecord_WriteEventToRecordTrack_Return	; F49CEB  jr NZ,0xf49cff
	ldw	bc, 8	; F49CED  ld BC,0x0008
	ld	xde, 14056	; F49CF0  ld XDE,0x000036e8
	ld	xhl, 13482	; F49CF5  ld XHL,0x000034aa
	ldir83	; F49CFA  ldir
	calr	CycleRecord_WriteStagedEventToRecordTrack	; F49CFC  calr 0xf4abe8
CycleRecord_WriteEventToRecordTrack_Return:
	ret	; F49CFF  ret

; --------------------------------------------------------------------------
; SeqRecord_WriteBeatMarkAndAgeHeldNotes
; Called from: in-module: 0xF499C5
; Touches: (0x3004) (0x3006) (0x33DA) (0x33DE) (0x345E) (0x349F) (0x374C)
; Calls:   CycleRecord_CheckIsRecordTrack SeqRecord_LoadTakeCursor T_BStore_WriteCursorByte T_BStore_AdvanceCursorForWrite_B SeqRecord_TerminateTrackOnMemoryFull SeqRecord_SaveTakeCursor
;          SeqRecord_LoadHeldNoteListHeadTail SeqRecord_HeldNoteSlotAddress SeqRecord_SplitHeldNoteAtBeatLimit
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49D00 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_WriteBeatMarkAndAgeHeldNotes: On a 0x81 beat mark from SeqBuf_Ring: each track 0..16 of the take
;   ((0x3004)/(0x3006)) other than the cycle record track gets 0x81 at its take cursor (out of free blocks with < 9
;   bytes left it is dropped from the take and terminated, SeqRecord_TerminateTrackOnMemoryFull); then every take track's held-note slots get +1
;   on their beat count (byte +1), a note reaching 127 beats being split (SeqRecord_SplitHeldNoteAtBeatLimit). The drain's 0x81 arm. Basis:
;   caller + body. (notes/naming-pilot-2026-10-06/proposals_wave10_b10.json)
SeqRecord_WriteBeatMarkAndAgeHeldNotes:
	ld	(13471:16), 0	; F49D00  ld (0x349f),0x00
SeqRecord_WriteBeatMarkAndAgeHeldNotes_Loop:
	xor	bc, bc	; F49D05  xor BC,BC
	ld	c, (13471:16)	; F49D07  ld C,(0x349f)
	cp	c, 16	; F49D0B  cp C,0x10
	jr	nc, SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip	; F49D0E  jr NC,0xf49d1e
	ld	iz, (12292:16)	; F49D10  ld IZ,(0x3004)
	ld	a, c	; F49D14  ld A,C
	scf	; F49D16  scf
	xorcf_a_16	iz	; F49D17  xorcf A,IZ
	jrl	c, SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip7	; F49D19  jrl C,0xf49dd9
	jr	SeqRecord_WriteBeatMarkAndAgeHeldNotes_Join	; F49D1C  jr T,0xf49d2d
SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip:
	ld	iz, (12294:16)	; F49D1E  ld IZ,(0x3006)
	ld	a, c	; F49D22  ld A,C
	sub	a, 16	; F49D24  sub A,0x10
	scf	; F49D27  scf
	xorcf_a_16	iz	; F49D28  xorcf A,IZ
	jrl	c, SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip7	; F49D2A  jrl C,0xf49dd9
SeqRecord_WriteBeatMarkAndAgeHeldNotes_Join:
	calr	CycleRecord_CheckIsRecordTrack	; F49D2D  calr 0xf49a3d
	cp	a, 0:i3	; F49D30  cp A,0
	jr	z, SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip5	; F49D32  jr Z,0xf49d87
	calr	SeqRecord_LoadTakeCursor	; F49D34  calr 0xf4980d
	cpw	(BStore_FreeCount:24), 0x0000	; F49D37  cp (0x6034ba),0x0000
	jr	nz, SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip2	; F49D3E  jr NZ,0xf49d4d
	ldw	wa, 255	; F49D40  ld WA,0x00ff
	sub	wa, (BStore_CursorOffset:16)	; F49D43  sub WA,(0x345e)
	cp	wa, 9	; F49D47  cp WA,0x0009
	jr	c, SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip3	; F49D4B  jr C,0xf49d59
SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip2:
	ld	a, 129:opc	; F49D4D  ld A,0x81
	call	T_BStore_WriteCursorByte	; F49D4F  call 0xf40c58
	call	T_BStore_AdvanceCursorForWrite_B	; F49D53  call 0xf40c64
	jr	SeqRecord_WriteBeatMarkAndAgeHeldNotes_Join3	; F49D57  jr T,0xf49d80
SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip3:
	cp	c, 16	; F49D59  cp C,0x10
	jr	nc, SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip4	; F49D5C  jr NC,0xf49d6d
	ld	iz, (12292:16)	; F49D5E  ld IZ,(0x3004)
	ld	a, c	; F49D62  ld A,C
	rcf	; F49D64  rcf
	stcf_a_16	iz	; F49D65  stcf A,IZ
	ld	(12292:16), iz	; F49D67  ld (0x3004),IZ
	jr	SeqRecord_WriteBeatMarkAndAgeHeldNotes_Join2	; F49D6B  jr T,0xf49d7d
SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip4:
	ld	iz, (12294:16)	; F49D6D  ld IZ,(0x3006)
	ld	a, c	; F49D71  ld A,C
	sub	a, 16	; F49D73  sub A,0x10
	rcf	; F49D76  rcf
	stcf_a_16	iz	; F49D77  stcf A,IZ
	ld	(12294:16), iz	; F49D79  ld (0x3006),IZ
SeqRecord_WriteBeatMarkAndAgeHeldNotes_Join2:
	calr	SeqRecord_TerminateTrackOnMemoryFull	; F49D7D  calr 0xf4a4f6
SeqRecord_WriteBeatMarkAndAgeHeldNotes_Join3:
	ld	c, (13471:16)	; F49D80  ld C,(0x349f)
	calr	SeqRecord_SaveTakeCursor	; F49D84  calr 0xf49838
SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip5:
	calr	SeqRecord_LoadHeldNoteListHeadTail	; F49D87  calr 0xf4a53e
	cp	(0x33da:16), 0x00	; F49D8A  cp (0x33da),0x00
	jr	z, SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip7	; F49D8F  jr Z,0xf49dd9
	xor	hl, hl	; F49D91  xor HL,HL
	ld	l, (13274:16)	; F49D93  ld L,(0x33da)
SeqRecord_WriteBeatMarkAndAgeHeldNotes_Join4:
	ld	(14156:16), l	; F49D97  ld (0x374c),L
	calr	SeqRecord_HeldNoteSlotAddress	; F49D9B  calr 0xf4a56c
	xor	wa, wa	; F49D9E  xor WA,WA
	ld	a, (xhl+1)	; F49DA0  ld A,(XHL+0x01)
	cp	a, 127	; F49DA3  cp A,0x7f
	jr	nc, SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip6	; F49DA6  jr NC,0xf49dbc
	inc	1, a	; F49DA8  inc 1,A
	ld	(xhl+1), a	; F49DAA  ld (XHL+0x01),A
	cp	(xhl+7), 0xff	; F49DAD  cp (XHL+0x07),0xff
	jr	z, SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip7	; F49DB1  jr Z,0xf49dd9
	xor	wa, wa	; F49DB3  xor WA,WA
	ld	a, (xhl+7)	; F49DB5  ld A,(XHL+0x07)
	ld	hl, wa	; F49DB8  ld HL,WA
	jr	SeqRecord_WriteBeatMarkAndAgeHeldNotes_Join4	; F49DBA  jr T,0xf49d97
SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip6:
	push	(0x349f:16)	; F49DBC  push (0x349f)
	call	SeqRecord_SplitHeldNoteAtBeatLimit	; F49DC0  call 0xf49de6
	pop	(0x349f:16)	; F49DC4  pop (0x349f)
	cp	(0x33de:16), 0xff	; F49DC8  cp (0x33de),0xff
	jr	z, SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip7	; F49DCD  jr Z,0xf49dd9
	xor	wa, wa	; F49DCF  xor WA,WA
	ld	a, (13278:16)	; F49DD1  ld A,(0x33de)
	ld	hl, wa	; F49DD5  ld HL,WA
	jr	SeqRecord_WriteBeatMarkAndAgeHeldNotes_Join4	; F49DD7  jr T,0xf49d97
SeqRecord_WriteBeatMarkAndAgeHeldNotes_Skip7:
	inc	1, (13471:16)	; F49DD9  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F49DDD  cp (0x349f),0x11
	jrl	c, SeqRecord_WriteBeatMarkAndAgeHeldNotes_Loop	; F49DE2  jrl C,0xf49d05
	ret	; F49DE5  ret

; --------------------------------------------------------------------------
; SeqRecord_SplitHeldNoteAtBeatLimit
; Called from: in-module: 0xF49DC0
; Touches: (0x33DE)
; Calls:   sub_F49DF8 sub_F49F46 SeqRecord_WriteNoteOn
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49DE6 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_SplitHeldNoteAtBeatLimit: For the held note in slot (0x374C) that SeqRecord_WriteBeatMarkAndAgeHeldNotes
;   found at 127 beats: sub_F49DF8 closes its event with duration 95 - start tick and 0x7F beats and frees the slot,
;   sub_F49F46 rebuilds {status, tick 0, note, velocity, track} at 0x34AA, and SeqRecord_WriteNoteOn re-opens it.
;   Basis: caller + body + SeqRecord_WriteNoteOn header. (notes/naming-pilot-2026-10-06/proposals_wave11_a11.json)
SeqRecord_SplitHeldNoteAtBeatLimit:
	calr	sub_F49DF8	; F49DE6  calr 0xf49df8
	calr	sub_F49F46	; F49DE9  calr 0xf49f46
	push	(0x33de:16)	; F49DEC  push (0x33de)
	calr	SeqRecord_WriteNoteOn	; F49DF0  calr 0xf49f6d
	pop	(0x33de:16)	; F49DF3  pop (0x33de)
	ret	; F49DF7  ret

; --------------------------------------------------------------------------
; sub_F49DF8
; Called from: in-module: 0xF49DE6
; Touches: (0x33DD) (0x33DE) (0x33DF) (0x345C) (0x345E) (0x34AE) (0x374C)
;          (0x374D) (0x374E) (0x374F)  |  0x003014 0x003016
; Calls:   SeqRecord_HeldNoteSlotAddress sub_F49F15 T_BStore_ReadCursorByte T_BStore_StepCursorOneByte T_BStore_WriteCursorByte
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49DF8 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F49DF8:
	xor	hl, hl	; F49DF8  xor HL,HL
	ld	l, (14156:16)	; F49DFA  ld L,(0x374c)
	ld	(13279:16), l	; F49DFE  ld (0x33df),L
	calr	SeqRecord_HeldNoteSlotAddress	; F49E02  calr 0xf4a56c
	ld	a, (xhl+6)	; F49E05  ld A,(XHL+0x06)
	ld	(13277:16), a	; F49E08  ld (0x33dd),A
	ld	a, (xhl+7)	; F49E0C  ld A,(XHL+0x07)
	ld	(13278:16), a	; F49E0F  ld (0x33de),A
	ld	a, (xhl+2)	; F49E13  ld A,(XHL+0x02)
	ld	c, 95:opc	; F49E16  ld C,0x5f
	sub	c, a	; F49E18  sub C,A
	ld	a, c	; F49E1A  ld A,C
	push	xhl	; F49E1C  push XHL
	pushw	wa	; F49E1D  push WA
	ld	wa, (xhl+3)	; F49E1E  ld WA,(XHL+0x03)
	ld	(BStore_CursorBlock:16), wa	; F49E21  ld (0x345c),WA
	xor	wa, wa	; F49E25  xor WA,WA
	ld	a, (xhl+5)	; F49E27  ld A,(XHL+0x05)
	ld	(BStore_CursorOffset:16), wa	; F49E2A  ld (0x345e),WA
	calr	sub_F49F15	; F49E2E  calr 0xf49f15
	calr	sub_F49F15	; F49E31  calr 0xf49f15
	call	T_BStore_ReadCursorByte	; F49E34  call 0xf40c54
	ld	(14157:16), a	; F49E38  ld (0x374d),A
	call	T_BStore_StepCursorOneByte	; F49E3C  call 0xf40c50
	call	T_BStore_StepCursorOneByte	; F49E40  call 0xf40c50
	call	T_BStore_ReadCursorByte	; F49E44  call 0xf40c54
	ld	(14158:16), a	; F49E48  ld (0x374e),A
	call	T_BStore_StepCursorOneByte	; F49E4C  call 0xf40c50
	call	T_BStore_ReadCursorByte	; F49E50  call 0xf40c54
	ld	(14159:16), a	; F49E54  ld (0x374f),A
	call	T_BStore_StepCursorOneByte	; F49E58  call 0xf40c50
	popw	wa	; F49E5C  pop WA
	and	a, 127	; F49E5D  and A,0x7f
	call	T_BStore_WriteCursorByte	; F49E60  call 0xf40c58
	call	T_BStore_StepCursorOneByte	; F49E64  call 0xf40c50
	ld	a, 127:opc	; F49E68  ld A,0x7f
	call	T_BStore_WriteCursorByte	; F49E6A  call 0xf40c58
	pop	xhl	; F49E6E  pop XHL
	cp	(0x33dd:16), 0x00	; F49E6F  cp (0x33dd),0x00
	jr	z, sub_F49DF8_Skip	; F49E74  jr Z,0xf49e8a
	push	xhl	; F49E76  push XHL
	xor	hl, hl	; F49E77  xor HL,HL
	ld	l, (13277:16)	; F49E79  ld L,(0x33dd)
	calr	SeqRecord_HeldNoteSlotAddress	; F49E7D  calr 0xf4a56c
	ld	a, (13278:16)	; F49E80  ld A,(0x33de)
	ld	(xhl+7), a	; F49E84  ld (XHL+0x07),A
	pop	xhl	; F49E87  pop XHL
	jr	sub_F49DF8_Join	; F49E88  jr T,0xf49eae
sub_F49DF8_Skip:
	push	xhl	; F49E8A  push XHL
	xor	iy, iy	; F49E8B  xor IY,IY
	xor	bc, bc	; F49E8D  xor BC,BC
	ld	c, (13486:16)	; F49E8F  ld C,(0x34ae)
	ld	iy, bc	; F49E93  ld IY,BC
	sla	iy, 1	; F49E95  sla 0x01,IY
	ld	xhl, 12310	; F49E98  ld XHL,0x00003016
	ld	a, (13278:16)	; F49E9D  ld A,(0x33de)
	cp	a, 255	; F49EA1  cp A,0xff
	jr	nz, sub_F49DF8_Skip2	; F49EA4  jr NZ,0xf49ea8
	ld	a, 0:opc	; F49EA6  ld A,0x00
sub_F49DF8_Skip2:
	ld	(xhl+iy), a	; F49EA8  ld (XHL+IY),A
	pop	xhl	; F49EAD  pop XHL
sub_F49DF8_Join:
	cp	(0x33de:16), 0xff	; F49EAE  cp (0x33de),0xff
	jr	z, sub_F49DF8_Skip3	; F49EB3  jr Z,0xf49ec9
	push	xhl	; F49EB5  push XHL
	xor	hl, hl	; F49EB6  xor HL,HL
	ld	l, (13278:16)	; F49EB8  ld L,(0x33de)
	calr	SeqRecord_HeldNoteSlotAddress	; F49EBC  calr 0xf4a56c
	ld	a, (13277:16)	; F49EBF  ld A,(0x33dd)
	ld	(xhl+6), a	; F49EC3  ld (XHL+0x06),A
	pop	xhl	; F49EC6  pop XHL
	jr	sub_F49DF8_Join2	; F49EC7  jr T,0xf49eeb
sub_F49DF8_Skip3:
	push	xhl	; F49EC9  push XHL
	xor	iy, iy	; F49ECA  xor IY,IY
	xor	bc, bc	; F49ECC  xor BC,BC
	ld	c, (13486:16)	; F49ECE  ld C,(0x34ae)
	ld	iy, bc	; F49ED2  ld IY,BC
	sla	iy, 1	; F49ED4  sla 0x01,IY
	ld	xhl, 12310	; F49ED7  ld XHL,0x00003016
	ld	a, (13277:16)	; F49EDC  ld A,(0x33dd)
	ld	xiz, xhl	; F49EE0  ld XIZ,XHL
	lda	xiz, (xiz+iy)	; F49EE2  lda XIZ,XIZ+IY
	ld	(xiz+1), a	; F49EE7  ld (XIZ+0x01),A
	pop	xhl	; F49EEA  pop XHL
sub_F49DF8_Join2:
	ld	(xhl+6), 0	; F49EEB  ld (XHL+0x06),0x00
	ld	xix, 12308	; F49EEF  ld XIX,0x00003014
	ld	c, (xix)	; F49EF4  ld C,(XIX)
	ld	(xhl+7), c	; F49EF6  ld (XHL+0x07),C
	ld	a, (13279:16)	; F49EF9  ld A,(0x33df)
	ld	(xix), a	; F49EFD  ld (XIX),A
	cp	c, 255	; F49EFF  cp C,0xff
	jr	z, sub_F49DF8_Return	; F49F02  jr Z,0xf49f14
	xor	xhl, xhl	; F49F04  xor XHL,XHL
	ld	l, c	; F49F06  ld L,C
	calr	SeqRecord_HeldNoteSlotAddress	; F49F08  calr 0xf4a56c
	ld	a, (13279:16)	; F49F0B  ld A,(0x33df)
	ld	(xhl+6), a	; F49F0F  ld (XHL+0x06),A
	jr	sub_F49DF8_Return	; F49F12  jr T,0xf49f14
sub_F49DF8_Return:
	ret	; F49F14  ret

; --------------------------------------------------------------------------
; sub_F49F15
; Called from: in-module: 0xF49E2E 0xF49E31
; Touches: (0x345C) (0x345E) (0x3604)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49F15 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F49F15:
	push	xix	; F49F15  push XIX
	ld	wa, (BStore_CursorOffset:16)	; F49F16  ld WA,(0x345e)
	cp	wa, 5:i3	; F49F1A  cp WA,5
	jr	nz, sub_F49F15_Skip	; F49F1C  jr NZ,0xf49f3e
	xor	xhl, xhl	; F49F1E  xor XHL,XHL
	ld	hl, (BStore_CursorBlock:16)	; F49F20  ld HL,(0x345c)
	dec	1, xhl	; F49F24  dec 1,XHL
	sla	xhl, 8	; F49F26  sla 0x08,XHL
	ld	xix, (BStore_HeapBase:16)	; F49F29  ld XIX,(0x3604)
	lda	xwa, (xix+0:8)	; F49F2D  lda XWA,XIX+0x00
	add	xhl, xwa	; F49F30  add XHL,XWA
	ld	wa, (xhl+1)	; F49F32  ld WA,(XHL+0x01)
	ld	(BStore_CursorBlock:16), wa	; F49F35  ld (0x345c),WA
	ldw	wa, 255	; F49F39  ld WA,0x00ff
	jr	sub_F49F15_Join	; F49F3C  jr T,0xf49f40
sub_F49F15_Skip:
	dec	1, wa	; F49F3E  dec 1,WA
sub_F49F15_Join:
	ld	(BStore_CursorOffset:16), wa	; F49F40  ld (0x345e),WA
	pop	xix	; F49F44  pop XIX
	ret	; F49F45  ret

; --------------------------------------------------------------------------
; sub_F49F46
; Called from: in-module: 0xF49DE9
; Touches: (0x349F) (0x374D) (0x374E) (0x374F)  |  0x0034AA
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49F46 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F49F46:
	ld	xhl, 13482	; F49F46  ld XHL,0x000034aa
	ld	a, (14157:16)	; F49F4B  ld A,(0x374d)
	ld	(xhl+0:8), a	; F49F4F  ld (XHL+0x00),A
	ld	a, 0:opc	; F49F52  ld A,0x00
	ld	(xhl+1), a	; F49F54  ld (XHL+0x01),A
	ld	a, (14158:16)	; F49F57  ld A,(0x374e)
	ld	(xhl+2), a	; F49F5B  ld (XHL+0x02),A
	ld	a, (14159:16)	; F49F5E  ld A,(0x374f)
	ld	(xhl+3), a	; F49F62  ld (XHL+0x03),A
	ld	a, (13471:16)	; F49F65  ld A,(0x349f)
	ld	(xhl+4), a	; F49F69  ld (XHL+0x04),A
	ret	; F49F6C  ret

; --------------------------------------------------------------------------
; SeqRecord_WriteNoteOn
; Called from: in-module: 0xF49964 0xF49DF0
; Touches: (0x3004) (0x3006) (0x33DA) (0x33DB) (0x33DE) (0x33DF) (0x345C)
;          (0x345E) (0x349F) (0x34AA) +4 more  |  0x003014 0x003016
; Calls:   SeqRecord_LoadTakeCursor SeqRecord_HeldNoteSlotAddress SeqRecord_TerminateTrackOnMemoryFull T_BStore_WriteCursorByte T_BStore_AdvanceCursorForWrite_B SeqRecord_LoadHeldNoteListHeadTail
;          SeqRecord_SaveTakeCursor
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF49F6D is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_WriteNoteOn: Track (0x34AE), if in the take: writes [0x9n & 0xFA, tick, note, velocity, 0x10, 0x00] at its
;   take cursor and takes a held-note slot off the free list (0x3014) -- note, beats 0, start tick, the note byte's
;   cursor -- appending it to the track's list (0x3016); writes nothing when no slot is free, and out of blocks (< 14
;   bytes) drops the track (SeqRecord_TerminateTrackOnMemoryFull). The drain's velocity > 0 note arm; also re-opens a note split at 127 beats.
;   Basis: caller + body + slot users. (notes/naming-pilot-2026-10-06/proposals_wave10_b10.json)
SeqRecord_WriteNoteOn:
	xor	bc, bc	; F49F6D  xor BC,BC
	ld	c, (13486:16)	; F49F6F  ld C,(0x34ae)
	cp	c, 16	; F49F73  cp C,0x10
	jr	nc, SeqRecord_WriteNoteOn_Skip	; F49F76  jr NC,0xf49f86
	ld	iz, (12292:16)	; F49F78  ld IZ,(0x3004)
	ld	a, c	; F49F7C  ld A,C
	scf	; F49F7E  scf
	xorcf_a_16	iz	; F49F7F  xorcf A,IZ
	jrl	c, SeqRecord_WriteNoteOn_Return	; F49F81  jrl C,0xf4a0fe
	jr	SeqRecord_WriteNoteOn_Join	; F49F84  jr T,0xf49f95
SeqRecord_WriteNoteOn_Skip:
	ld	iz, (12294:16)	; F49F86  ld IZ,(0x3006)
	ld	a, c	; F49F8A  ld A,C
	sub	a, 16	; F49F8C  sub A,0x10
	scf	; F49F8F  scf
	xorcf_a_16	iz	; F49F90  xorcf A,IZ
	jrl	c, SeqRecord_WriteNoteOn_Return	; F49F92  jrl C,0xf4a0fe
SeqRecord_WriteNoteOn_Join:
	calr	SeqRecord_LoadTakeCursor	; F49F95  calr 0xf4980d
	xor	xix, xix	; F49F98  xor XIX,XIX
	ld	xix, 12308	; F49F9A  ld XIX,0x00003014
	cp	(xix), 0xff	; F49F9F  cp (XIX),0xff
	jrl	z, SeqRecord_WriteNoteOn_Return	; F49FA2  jrl Z,0xf4a0fe
	xor	hl, hl	; F49FA5  xor HL,HL
	ld	l, (xix)	; F49FA7  ld L,(XIX)
	ld	(13279:16), l	; F49FA9  ld (0x33df),L
	calr	SeqRecord_HeldNoteSlotAddress	; F49FAD  calr 0xf4a56c
	cpw	(BStore_FreeCount:24), 0x0000	; F49FB0  cp (0x6034ba),0x0000
	jr	nz, SeqRecord_WriteNoteOn_Skip3	; F49FB7  jr NZ,0xf49ff4
	ldw	wa, 255	; F49FB9  ld WA,0x00ff
	sub	wa, (BStore_CursorOffset:16)	; F49FBC  sub WA,(0x345e)
	cp	wa, 14	; F49FC0  cp WA,0x000e
	jr	nc, SeqRecord_WriteNoteOn_Skip3	; F49FC4  jr NC,0xf49ff4
	ld	c, (13486:16)	; F49FC6  ld C,(0x34ae)
	cp	c, 16	; F49FCA  cp C,0x10
	jr	nc, SeqRecord_WriteNoteOn_Skip2	; F49FCD  jr NC,0xf49fde
	ld	iz, (12292:16)	; F49FCF  ld IZ,(0x3004)
	ld	a, c	; F49FD3  ld A,C
	rcf	; F49FD5  rcf
	stcf_a_16	iz	; F49FD6  stcf A,IZ
	ld	(12292:16), iz	; F49FD8  ld (0x3004),IZ
	jr	SeqRecord_WriteNoteOn_Join2	; F49FDC  jr T,0xf49fee
SeqRecord_WriteNoteOn_Skip2:
	ld	iz, (12294:16)	; F49FDE  ld IZ,(0x3006)
	ld	a, c	; F49FE2  ld A,C
	sub	a, 16	; F49FE4  sub A,0x10
	rcf	; F49FE7  rcf
	stcf_a_16	iz	; F49FE8  stcf A,IZ
	ld	(12294:16), iz	; F49FEA  ld (0x3006),IZ
SeqRecord_WriteNoteOn_Join2:
	calr	SeqRecord_TerminateTrackOnMemoryFull	; F49FEE  calr 0xf4a4f6
	jrl	SeqRecord_WriteNoteOn_Join3	; F49FF1  jrl T,0xf4a0f7
SeqRecord_WriteNoteOn_Skip3:
	push	xhl	; F49FF4  push XHL
	ld	a, (13482:16)	; F49FF5  ld A,(0x34aa)
	and	a, 250	; F49FF9  and A,0xfa
	call	T_BStore_WriteCursorByte	; F49FFC  call 0xf40c58
	call	T_BStore_AdvanceCursorForWrite_B	; F4A000  call 0xf40c64
	ld	a, (13483:16)	; F4A004  ld A,(0x34ab)
	call	T_BStore_WriteCursorByte	; F4A008  call 0xf40c58
	call	T_BStore_AdvanceCursorForWrite_B	; F4A00C  call 0xf40c64
	ld	a, (13484:16)	; F4A010  ld A,(0x34ac)
	call	T_BStore_WriteCursorByte	; F4A014  call 0xf40c58
	pop	xhl	; F4A018  pop XHL
	ld	(xhl), a	; F4A019  ld (XHL),A
	ld	(xhl+1), 0	; F4A01B  ld (XHL+0x01),0x00
	ld	a, (13483:16)	; F4A01F  ld A,(0x34ab)
	ld	(xhl+2), a	; F4A023  ld (XHL+0x02),A
	ld	wa, (BStore_CursorBlock:16)	; F4A026  ld WA,(0x345c)
	ld	(xhl+3), wa	; F4A02A  ld (XHL+0x03),WA
	ld	wa, (BStore_CursorOffset:16)	; F4A02D  ld WA,(0x345e)
	ld	(xhl+5), a	; F4A031  ld (XHL+0x05),A
	ld	c, (13486:16)	; F4A034  ld C,(0x34ae)
	ld	a, (13471:16)	; F4A038  ld A,(0x349f)
	ld	(13471:16), c	; F4A03C  ld (0x349f),C
	calr	SeqRecord_LoadHeldNoteListHeadTail	; F4A040  calr 0xf4a53e
	ld	(13471:16), a	; F4A043  ld (0x349f),A
	ld	a, (13275:16)	; F4A047  ld A,(0x33db)
	ld	(xhl+6), a	; F4A04B  ld (XHL+0x06),A
	ld	a, (xhl+7)	; F4A04E  ld A,(XHL+0x07)
	ld	(13278:16), a	; F4A051  ld (0x33de),A
	ld	(xhl+7), 255	; F4A055  ld (XHL+0x07),0xff
	cp	(0x33da:16), 0x00	; F4A059  cp (0x33da),0x00
	jr	nz, SeqRecord_WriteNoteOn_Skip4	; F4A05E  jr NZ,0xf4a07b
	xor	iy, iy	; F4A060  xor IY,IY
	xor	wa, wa	; F4A062  xor WA,WA
	ld	a, (13486:16)	; F4A064  ld A,(0x34ae)
	ld	iy, wa	; F4A068  ld IY,WA
	sla	iy, 1	; F4A06A  sla 0x01,IY
	ld	xhl, 12310	; F4A06D  ld XHL,0x00003016
	ld	a, (13279:16)	; F4A072  ld A,(0x33df)
	ld	(xhl+iy), a	; F4A076  ld (XHL+IY),A
SeqRecord_WriteNoteOn_Skip4:
	cp	(0x33db:16), 0x00	; F4A07B  cp (0x33db),0x00
	jr	z, SeqRecord_WriteNoteOn_Skip5	; F4A080  jr Z,0xf4a092
	xor	hl, hl	; F4A082  xor HL,HL
	ld	l, (13275:16)	; F4A084  ld L,(0x33db)
	calr	SeqRecord_HeldNoteSlotAddress	; F4A088  calr 0xf4a56c
	ld	a, (13279:16)	; F4A08B  ld A,(0x33df)
	ld	(xhl+7), a	; F4A08F  ld (XHL+0x07),A
SeqRecord_WriteNoteOn_Skip5:
	xor	iy, iy	; F4A092  xor IY,IY
	xor	wa, wa	; F4A094  xor WA,WA
	ld	a, (13486:16)	; F4A096  ld A,(0x34ae)
	ld	iy, wa	; F4A09A  ld IY,WA
	sla	iy, 1	; F4A09C  sla 0x01,IY
	ld	xhl, 12310	; F4A09F  ld XHL,0x00003016
	ld	a, (13279:16)	; F4A0A4  ld A,(0x33df)
	ld	xiz, xhl	; F4A0A8  ld XIZ,XHL
	lda	xiz, (xiz+iy)	; F4A0AA  lda XIZ,XIZ+IY
	ld	(xiz+1), a	; F4A0AF  ld (XIZ+0x01),A
	xor	xix, xix	; F4A0B2  xor XIX,XIX
	ld	xix, 12308	; F4A0B4  ld XIX,0x00003014
	ld	a, (13278:16)	; F4A0B9  ld A,(0x33de)
	ld	(xix), a	; F4A0BD  ld (XIX),A
	cp	(0x33de:16), 0xff	; F4A0BF  cp (0x33de),0xff
	jr	z, SeqRecord_WriteNoteOn_Skip6	; F4A0C4  jr Z,0xf4a0d3
	xor	hl, hl	; F4A0C6  xor HL,HL
	ld	l, (13278:16)	; F4A0C8  ld L,(0x33de)
	calr	SeqRecord_HeldNoteSlotAddress	; F4A0CC  calr 0xf4a56c
	ld	(xhl+6), 0	; F4A0CF  ld (XHL+0x06),0x00
SeqRecord_WriteNoteOn_Skip6:
	call	T_BStore_AdvanceCursorForWrite_B	; F4A0D3  call 0xf40c64
	ld	a, (13485:16)	; F4A0D7  ld A,(0x34ad)
	call	T_BStore_WriteCursorByte	; F4A0DB  call 0xf40c58
	call	T_BStore_AdvanceCursorForWrite_B	; F4A0DF  call 0xf40c64
	ld	a, 16:opc	; F4A0E3  ld A,0x10
	call	T_BStore_WriteCursorByte	; F4A0E5  call 0xf40c58
	call	T_BStore_AdvanceCursorForWrite_B	; F4A0E9  call 0xf40c64
	ld	a, 0:opc	; F4A0ED  ld A,0x00
	call	T_BStore_WriteCursorByte	; F4A0EF  call 0xf40c58
	call	T_BStore_AdvanceCursorForWrite_B	; F4A0F3  call 0xf40c64
SeqRecord_WriteNoteOn_Join3:
	ld	c, (13486:16)	; F4A0F7  ld C,(0x34ae)
	calr	SeqRecord_SaveTakeCursor	; F4A0FB  calr 0xf49838
SeqRecord_WriteNoteOn_Return:
	ret	; F4A0FE  ret

; --------------------------------------------------------------------------
; SeqRecord_CloseHeldNote
; Called from: in-module: 0xF4994F 0xF49C5A
; Touches: (0x3004) (0x3006) (0x33DA) (0x33DD) (0x33DE) (0x33DF) (0x345C)
;          (0x345E) (0x349F) (0x34AB) +2 more  |  0x003014 0x003016
; Calls:   SeqRecord_LoadHeldNoteListHeadTail SeqRecord_HeldNoteSlotAddress T_BStore_StepCursorOneByte T_BStore_WriteCursorByte
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A0FF is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_CloseHeldNote: Track (0x34AE), if in the take: finds its held-note slot for note (0x34AC), writes the
;   duration -- ticks ((0x34AB) - start tick, borrowing 96 per beat; at least 2) and the slot's beat count -- over the
;   0x10 0x00 placeholder of the note event, unlinks the slot and returns it to the free list (0x3014). The drain's
;   velocity-0 0x9n arm and SeqRecord_CloseAllHeldNotes's close-all. Basis: callers + body + SeqRecord_WriteNoteOn. (notes/naming-
;   pilot-2026-10-06/proposals_wave10_b10.json)
SeqRecord_CloseHeldNote:
	ld	c, (13486:16)	; F4A0FF  ld C,(0x34ae)
	cp	c, 16	; F4A103  cp C,0x10
	jr	nc, SeqRecord_CloseHeldNote_Skip	; F4A106  jr NC,0xf4a116
	ld	iz, (12292:16)	; F4A108  ld IZ,(0x3004)
	ld	a, c	; F4A10C  ld A,C
	scf	; F4A10E  scf
	xorcf_a_16	iz	; F4A10F  xorcf A,IZ
	jrl	c, SeqRecord_CloseHeldNote_Return	; F4A111  jrl C,0xf4a26c
	jr	SeqRecord_CloseHeldNote_Join	; F4A114  jr T,0xf4a125
SeqRecord_CloseHeldNote_Skip:
	ld	iz, (12294:16)	; F4A116  ld IZ,(0x3006)
	ld	a, c	; F4A11A  ld A,C
	sub	a, 16	; F4A11C  sub A,0x10
	scf	; F4A11F  scf
	xorcf_a_16	iz	; F4A120  xorcf A,IZ
	jrl	c, SeqRecord_CloseHeldNote_Return	; F4A122  jrl C,0xf4a26c
SeqRecord_CloseHeldNote_Join:
	ld	a, (13471:16)	; F4A125  ld A,(0x349f)
	ld	(13471:16), c	; F4A129  ld (0x349f),C
	calr	SeqRecord_LoadHeldNoteListHeadTail	; F4A12D  calr 0xf4a53e
	ld	(13471:16), a	; F4A130  ld (0x349f),A
	cp	(0x33da:16), 0x00	; F4A134  cp (0x33da),0x00
	jrl	z, SeqRecord_CloseHeldNote_Return	; F4A139  jrl Z,0xf4a26c
	xor	hl, hl	; F4A13C  xor HL,HL
	ld	l, (13274:16)	; F4A13E  ld L,(0x33da)
SeqRecord_CloseHeldNote_Join2:
	ld	(13279:16), l	; F4A142  ld (0x33df),L
	calr	SeqRecord_HeldNoteSlotAddress	; F4A146  calr 0xf4a56c
	ld	a, (xhl+6)	; F4A149  ld A,(XHL+0x06)
	ld	(13277:16), a	; F4A14C  ld (0x33dd),A
	ld	a, (xhl+7)	; F4A150  ld A,(XHL+0x07)
	ld	(13278:16), a	; F4A153  ld (0x33de),A
	ld	a, (xhl)	; F4A157  ld A,(XHL)
	cp	a, (0x34ac:16)	; F4A159  cp A,(0x34ac)
	jrl	nz, SeqRecord_CloseHeldNote_Skip7	; F4A15D  jrl NZ,0xf4a25c
	ld	d, (xhl+1)	; F4A160  ld D,(XHL+0x01)
	ld	a, (xhl+2)	; F4A163  ld A,(XHL+0x02)
	ld	c, (13483:16)	; F4A166  ld C,(0x34ab)
	cp	c, a	; F4A16A  cp C,A
	jr	nc, SeqRecord_CloseHeldNote_Skip2	; F4A16C  jr NC,0xf4a177
	add	c, 96	; F4A16E  add C,0x60
	cp	d, 0:i3	; F4A171  cp D,0
	jr	z, SeqRecord_CloseHeldNote_Skip2	; F4A173  jr Z,0xf4a177
	dec	1, d	; F4A175  dec 1,D
SeqRecord_CloseHeldNote_Skip2:
	sub	c, a	; F4A177  sub C,A
	ld	a, c	; F4A179  ld A,C
	cp	d, 0:i3	; F4A17B  cp D,0
	jr	nz, SeqRecord_CloseHeldNote_Skip3	; F4A17D  jr NZ,0xf4a185
	cp	a, 2:i3	; F4A17F  cp A,2
	jr	nc, SeqRecord_CloseHeldNote_Skip3	; F4A181  jr NC,0xf4a185
	ld	a, 2:opc	; F4A183  ld A,0x02
SeqRecord_CloseHeldNote_Skip3:
	push	xhl	; F4A185  push XHL
	pushw	de	; F4A186  push DE
	pushw	wa	; F4A187  push WA
	ld	wa, (xhl+3)	; F4A188  ld WA,(XHL+0x03)
	ld	(BStore_CursorBlock:16), wa	; F4A18B  ld (0x345c),WA
	xor	wa, wa	; F4A18F  xor WA,WA
	ld	a, (xhl+5)	; F4A191  ld A,(XHL+0x05)
	ld	(BStore_CursorOffset:16), wa	; F4A194  ld (0x345e),WA
	call	T_BStore_StepCursorOneByte	; F4A198  call 0xf40c50
	call	T_BStore_StepCursorOneByte	; F4A19C  call 0xf40c50
	popw	wa	; F4A1A0  pop WA
	and	a, 127	; F4A1A1  and A,0x7f
	call	T_BStore_WriteCursorByte	; F4A1A4  call 0xf40c58
	call	T_BStore_StepCursorOneByte	; F4A1A8  call 0xf40c50
	popw	de	; F4A1AC  pop DE
	ld	a, d	; F4A1AD  ld A,D
	and	a, 127	; F4A1AF  and A,0x7f
	call	T_BStore_WriteCursorByte	; F4A1B2  call 0xf40c58
	pop	xhl	; F4A1B6  pop XHL
	cp	(0x33dd:16), 0x00	; F4A1B7  cp (0x33dd),0x00
	jr	z, SeqRecord_CloseHeldNote_Skip4	; F4A1BC  jr Z,0xf4a1d2
	push	xhl	; F4A1BE  push XHL
	xor	hl, hl	; F4A1BF  xor HL,HL
	ld	l, (13277:16)	; F4A1C1  ld L,(0x33dd)
	calr	SeqRecord_HeldNoteSlotAddress	; F4A1C5  calr 0xf4a56c
	ld	a, (13278:16)	; F4A1C8  ld A,(0x33de)
	ld	(xhl+7), a	; F4A1CC  ld (XHL+0x07),A
	pop	xhl	; F4A1CF  pop XHL
	jr	SeqRecord_CloseHeldNote_Join3	; F4A1D0  jr T,0xf4a1f6
SeqRecord_CloseHeldNote_Skip4:
	push	xhl	; F4A1D2  push XHL
	xor	iy, iy	; F4A1D3  xor IY,IY
	xor	bc, bc	; F4A1D5  xor BC,BC
	ld	c, (13486:16)	; F4A1D7  ld C,(0x34ae)
	ld	iy, bc	; F4A1DB  ld IY,BC
	sla	iy, 1	; F4A1DD  sla 0x01,IY
	ld	xhl, 12310	; F4A1E0  ld XHL,0x00003016
	ld	a, (13278:16)	; F4A1E5  ld A,(0x33de)
	cp	a, 255	; F4A1E9  cp A,0xff
	jr	nz, SeqRecord_CloseHeldNote_Skip5	; F4A1EC  jr NZ,0xf4a1f0
	ld	a, 0:opc	; F4A1EE  ld A,0x00
SeqRecord_CloseHeldNote_Skip5:
	ld	(xhl+iy), a	; F4A1F0  ld (XHL+IY),A
	pop	xhl	; F4A1F5  pop XHL
SeqRecord_CloseHeldNote_Join3:
	cp	(0x33de:16), 0xff	; F4A1F6  cp (0x33de),0xff
	jr	z, SeqRecord_CloseHeldNote_Skip6	; F4A1FB  jr Z,0xf4a211
	push	xhl	; F4A1FD  push XHL
	xor	hl, hl	; F4A1FE  xor HL,HL
	ld	l, (13278:16)	; F4A200  ld L,(0x33de)
	calr	SeqRecord_HeldNoteSlotAddress	; F4A204  calr 0xf4a56c
	ld	a, (13277:16)	; F4A207  ld A,(0x33dd)
	ld	(xhl+6), a	; F4A20B  ld (XHL+0x06),A
	pop	xhl	; F4A20E  pop XHL
	jr	SeqRecord_CloseHeldNote_Join4	; F4A20F  jr T,0xf4a233
SeqRecord_CloseHeldNote_Skip6:
	push	xhl	; F4A211  push XHL
	xor	iy, iy	; F4A212  xor IY,IY
	xor	bc, bc	; F4A214  xor BC,BC
	ld	c, (13486:16)	; F4A216  ld C,(0x34ae)
	ld	iy, bc	; F4A21A  ld IY,BC
	sla	iy, 1	; F4A21C  sla 0x01,IY
	ld	xhl, 12310	; F4A21F  ld XHL,0x00003016
	ld	a, (13277:16)	; F4A224  ld A,(0x33dd)
	ld	xiz, xhl	; F4A228  ld XIZ,XHL
	lda	xiz, (xiz+iy)	; F4A22A  lda XIZ,XIZ+IY
	ld	(xiz+1), a	; F4A22F  ld (XIZ+0x01),A
	pop	xhl	; F4A232  pop XHL
SeqRecord_CloseHeldNote_Join4:
	ld	(xhl+6), 0	; F4A233  ld (XHL+0x06),0x00
	ld	xix, 12308	; F4A237  ld XIX,0x00003014
	ld	c, (xix)	; F4A23C  ld C,(XIX)
	ld	(xhl+7), c	; F4A23E  ld (XHL+0x07),C
	ld	a, (13279:16)	; F4A241  ld A,(0x33df)
	ld	(xix), a	; F4A245  ld (XIX),A
	cp	c, 255	; F4A247  cp C,0xff
	jr	z, SeqRecord_CloseHeldNote_Return	; F4A24A  jr Z,0xf4a26c
	xor	xhl, xhl	; F4A24C  xor XHL,XHL
	ld	l, c	; F4A24E  ld L,C
	calr	SeqRecord_HeldNoteSlotAddress	; F4A250  calr 0xf4a56c
	ld	a, (13279:16)	; F4A253  ld A,(0x33df)
	ld	(xhl+6), a	; F4A257  ld (XHL+0x06),A
	jr	SeqRecord_CloseHeldNote_Return	; F4A25A  jr T,0xf4a26c
SeqRecord_CloseHeldNote_Skip7:
	cp	(0x33de:16), 0xff	; F4A25C  cp (0x33de),0xff
	jr	z, SeqRecord_CloseHeldNote_Return	; F4A261  jr Z,0xf4a26c
	xor	xhl, xhl	; F4A263  xor XHL,XHL
	ld	l, (13278:16)	; F4A265  ld L,(0x33de)
	jrl	SeqRecord_CloseHeldNote_Join2	; F4A269  jrl T,0xf4a142
SeqRecord_CloseHeldNote_Return:
	ret	; F4A26C  ret

; --------------------------------------------------------------------------
; SeqRecord_WriteParamEvent
; Called from: in-module: 0xF499D4
; Touches: (0x349F) (0x34B0) (0x36F0)  |  0x0034AA
; Calls:   CycleRecord_CheckIsRecordTrack SeqRecord_WriteEventToTakeTrack CycleRecord_WriteEventToRecordTrack
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A26D is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_WriteParamEvent: The drain's 0xBn arm (SeqBuf_PutParamEvent's {0xB0, tick, number, class, value, mask,
;   slot}): the track is byte 6 of the record (also to (0x349F)); not the cycle record track ->
;   SeqRecord_WriteEventToTakeTrack writes the 6 bytes before the slot; the cycle record track -> (0x36F0) := 6,
;   CycleRecord_WriteEventToRecordTrack. Basis: caller + body + encoder. (notes/naming-
;   pilot-2026-10-06/proposals_wave10_b10.json)
SeqRecord_WriteParamEvent:
	ld	hl, de	; F4A26D  ld HL,DE
	xor	bc, bc	; F4A26F  xor BC,BC
	ld	xix, 13482	; F4A271  ld XIX,0x000034aa
	ld	c, (xix+hl)	; F4A276  ld C,(XIX+HL)
	ld	a, (13488:16)	; F4A27B  ld A,(0x34b0)
	ld	(13471:16), a	; F4A27F  ld (0x349f),A
	pushw	de	; F4A283  push DE
	calr	CycleRecord_CheckIsRecordTrack	; F4A284  calr 0xf49a3d
	popw	de	; F4A287  pop DE
	cp	a, 0:i3	; F4A288  cp A,0
	jr	z, SeqRecord_WriteParamEvent_Skip	; F4A28A  jr Z,0xf4a291
	calr	SeqRecord_WriteEventToTakeTrack	; F4A28C  calr 0xf4a2c8
	jr	SeqRecord_WriteParamEvent_Return	; F4A28F  jr T,0xf4a2a3
SeqRecord_WriteParamEvent_Skip:
	ld	(14064:16), 6	; F4A291  ld (0x36f0),0x06
	ld	a, (13488:16)	; F4A296  ld A,(0x34b0)
	ld	(13471:16), a	; F4A29A  ld (0x349f),A
	calr	CycleRecord_WriteEventToRecordTrack	; F4A29E  calr 0xf49ce6
	jr	SeqRecord_WriteParamEvent_Return	; F4A2A1  jr T,0xf4a2a3
SeqRecord_WriteParamEvent_Return:
	ret	; F4A2A3  ret

; --------------------------------------------------------------------------
; SeqRecord_WritePitchBendToTakeTrack
; Called from: in-module: 0xF499F2 0xF49BEA
; Touches:   |  0x0034AA
; Calls:   SeqRecord_WriteEventToTakeTrack
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A2A4 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_WritePitchBendToTakeTrack: C := 0x34AA[DE] (the event's slot byte), then SeqRecord_WriteEventToTakeTrack
;   writes the DE bytes before it. Its callers are the drain's 0xD2 (pitch bend) arm and sub_F49BBA's pitch-bend
;   reset, both with DE = 4; byte-identical to SeqRecord_WriteCtrlEventToTakeTrack. Basis: callers + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave10_b10.json)
SeqRecord_WritePitchBendToTakeTrack:
	ld	hl, de	; F4A2A4  ld HL,DE
	xor	bc, bc	; F4A2A6  xor BC,BC
	ld	xix, 13482	; F4A2A8  ld XIX,0x000034aa
	ld	c, (xix+hl)	; F4A2AD  ld C,(XIX+HL)
	calr	SeqRecord_WriteEventToTakeTrack	; F4A2B2  calr 0xf4a2c8
	ret	; F4A2B5  ret

; --------------------------------------------------------------------------
; SeqRecord_WriteCtrlEventToTakeTrack
; Called from: in-module: 0xF49907 0xF49A23 0xF49BAA
; Touches:   |  0x0034AA
; Calls:   SeqRecord_WriteEventToTakeTrack
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A2B6 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_WriteCtrlEventToTakeTrack: C := 0x34AA[DE] (the slot byte), then SeqRecord_WriteEventToTakeTrack writes
;   the DE bytes before it. Callers: the drain's 0xD3 and 0xD0/0xD1 arms (expression, pressure, modulation: {0xDn,
;   tick, value, slot}) and sub_F49B7A's modulation reset, all with DE = 3; twin of
;   SeqRecord_WritePitchBendToTakeTrack. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave10_b10.json)
SeqRecord_WriteCtrlEventToTakeTrack:
	ld	hl, de	; F4A2B6  ld HL,DE
	xor	bc, bc	; F4A2B8  xor BC,BC
	ld	xix, 13482	; F4A2BA  ld XIX,0x000034aa
	ld	c, (xix+hl)	; F4A2BF  ld C,(XIX+HL)
	calr	SeqRecord_WriteEventToTakeTrack	; F4A2C4  calr 0xf4a2c8
	ret	; F4A2C7  ret

; --------------------------------------------------------------------------
; SeqRecord_WriteEventToTakeTrack
; Called from: in-module: 0xF499A3 0xF4A28C 0xF4A2B2 0xF4A2C4
; Touches: (0x3004) (0x3006) (0x345C) (0x345E) (0x349F)  |  0x0000FF
;          0x0034AA
; Calls:   SeqRecord_LoadTakeCursor SeqRecord_TerminateTrackOnMemoryFull T_BStore_BlockAddrFromHL BStore_ExtendChainAtCursor_B_SaveRegs SeqRecord_SaveTakeCursor
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A2C8 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_WriteEventToTakeTrack: Track C, if in the take: copies DE bytes of the event record 0x34AA to its take
;   cursor (SeqRecord_LoadTakeCursor / SaveTakeCursor), continuing in a new block through BStore_ExtendChainAtCursor_B_SaveRegs
;   (T_BStore_ExtendChainAtCursor_B) past offset 0xFF; with no free block and fewer than DE + 8 bytes left it drops
;   the track from the take ((0x3004)/(0x3006) bit cleared) and terminates it (SeqRecord_TerminateTrackOnMemoryFull). The drain's 0xCn arm and
;   the three writers above call it. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave10_b10.json)
SeqRecord_WriteEventToTakeTrack:
	cp	c, 16	; F4A2C8  cp C,0x10
	jr	nc, SeqRecord_WriteEventToTakeTrack_Skip	; F4A2CB  jr NC,0xf4a2db
	ld	iz, (12292:16)	; F4A2CD  ld IZ,(0x3004)
	ld	a, c	; F4A2D1  ld A,C
	scf	; F4A2D3  scf
	xorcf_a_16	iz	; F4A2D4  xorcf A,IZ
	jrl	c, SeqRecord_WriteEventToTakeTrack_Return	; F4A2D6  jrl C,0xf4a3e1
	jr	SeqRecord_WriteEventToTakeTrack_Join	; F4A2D9  jr T,0xf4a2ea
SeqRecord_WriteEventToTakeTrack_Skip:
	ld	iz, (12294:16)	; F4A2DB  ld IZ,(0x3006)
	ld	a, c	; F4A2DF  ld A,C
	sub	a, 16	; F4A2E1  sub A,0x10
	scf	; F4A2E4  scf
	xorcf_a_16	iz	; F4A2E5  xorcf A,IZ
	jrl	c, SeqRecord_WriteEventToTakeTrack_Return	; F4A2E7  jrl C,0xf4a3e1
SeqRecord_WriteEventToTakeTrack_Join:
	calr	SeqRecord_LoadTakeCursor	; F4A2EA  calr 0xf4980d
	cpw	(BStore_FreeCount:24), 0x0000	; F4A2ED  cp (0x6034ba),0x0000
	jr	nz, SeqRecord_WriteEventToTakeTrack_Skip3	; F4A2F4  jr NZ,0xf4a33f
	ldw	wa, 256	; F4A2F6  ld WA,0x0100
	sub	wa, (BStore_CursorOffset:16)	; F4A2F9  sub WA,(0x345e)
	ld	iy, de	; F4A2FD  ld IY,DE
	add	iy, 8	; F4A2FF  add IY,0x0008
	cp	wa, iy	; F4A303  cp WA,IY
	jr	nc, SeqRecord_WriteEventToTakeTrack_Skip3	; F4A305  jr NC,0xf4a33f
	pushw	de	; F4A307  push DE
	ld	hl, de	; F4A308  ld HL,DE
	ld	xix, 13482	; F4A30A  ld XIX,0x000034aa
	ld	c, (xix+hl)	; F4A30F  ld C,(XIX+HL)
	cp	c, 16	; F4A314  cp C,0x10
	jr	nc, SeqRecord_WriteEventToTakeTrack_Skip2	; F4A317  jr NC,0xf4a328
	ld	iz, (12292:16)	; F4A319  ld IZ,(0x3004)
	ld	a, c	; F4A31D  ld A,C
	rcf	; F4A31F  rcf
	stcf_a_16	iz	; F4A320  stcf A,IZ
	ld	(12292:16), iz	; F4A322  ld (0x3004),IZ
	jr	SeqRecord_WriteEventToTakeTrack_Join2	; F4A326  jr T,0xf4a338
SeqRecord_WriteEventToTakeTrack_Skip2:
	ld	iz, (12294:16)	; F4A328  ld IZ,(0x3006)
	ld	a, c	; F4A32C  ld A,C
	sub	a, 16	; F4A32E  sub A,0x10
	rcf	; F4A331  rcf
	stcf_a_16	iz	; F4A332  stcf A,IZ
	ld	(12294:16), iz	; F4A334  ld (0x3006),IZ
SeqRecord_WriteEventToTakeTrack_Join2:
	calr	SeqRecord_TerminateTrackOnMemoryFull	; F4A338  calr 0xf4a4f6
	popw	de	; F4A33B  pop DE
	jrl	SeqRecord_WriteEventToTakeTrack_Join4	; F4A33C  jrl T,0xf4a3d2
SeqRecord_WriteEventToTakeTrack_Skip3:
	xor	ix, ix	; F4A33F  xor IX,IX
	ld	xhl, 13482	; F4A341  ld XHL,0x000034aa
	ld	xiy, 13482	; F4A346  ld XIY,0x000034aa
	ld	wa, (BStore_CursorOffset:16)	; F4A34B  ld WA,(0x345e)
	add	wa, de	; F4A34F  add WA,DE
	cp	wa, 256	; F4A351  cp WA,0x0100
	jr	ugt, SeqRecord_WriteEventToTakeTrack_Skip4	; F4A355  jr UGT,0xf4a37e
	ld	ix, (BStore_CursorOffset:16)	; F4A357  ld IX,(0x345e)
	ld	hl, (BStore_CursorBlock:16)	; F4A35B  ld HL,(0x345c)
	call	T_BStore_BlockAddrFromHL	; F4A35F  call 0xf40c84
	lda	xhl, (xhl+ix)	; F4A363  lda XHL,XHL+IX
	ld	xix, xhl	; F4A368  ld XIX,XHL
	ld	bc, de	; F4A36A  ld BC,DE
	ldir85	; F4A36C  ldir
	and	xix, 255	; F4A36E  and XIX,0x000000ff
	cp	ix, 5:i3	; F4A374  cp IX,5
	jr	ugt, SeqRecord_WriteEventToTakeTrack_Join3	; F4A376  jr UGT,0xf4a3c3
	add	ix, 256	; F4A378  add IX,0x0100
	jr	SeqRecord_WriteEventToTakeTrack_Join3	; F4A37C  jr T,0xf4a3c3
SeqRecord_WriteEventToTakeTrack_Skip4:
	ld	ix, (BStore_CursorOffset:16)	; F4A37E  ld IX,(0x345e)
	ldw	bc, 256	; F4A382  ld BC,0x0100
	sub	bc, ix	; F4A385  sub BC,IX
	ld	hl, (BStore_CursorBlock:16)	; F4A387  ld HL,(0x345c)
	call	T_BStore_BlockAddrFromHL	; F4A38B  call 0xf40c84
	lda	xhl, (xhl+ix)	; F4A38F  lda XHL,XHL+IX
	ld	xix, xhl	; F4A394  ld XIX,XHL
	ldir85	; F4A396  ldir
	calr	BStore_ExtendChainAtCursor_B_SaveRegs	; F4A398  calr 0xf4a4e3
	ldw	ix, 5	; F4A39B  ld IX,0x0005
	ld	hl, (BStore_CursorBlock:16)	; F4A39E  ld HL,(0x345c)
	call	T_BStore_BlockAddrFromHL	; F4A3A2  call 0xf40c84
	lda	xhl, (xhl+ix)	; F4A3A6  lda XHL,XHL+IX
	ld	xix, xhl	; F4A3AB  ld XIX,XHL
	sub	wa, 256	; F4A3AD  sub WA,0x0100
	ld	bc, wa	; F4A3B1  ld BC,WA
	ldir85	; F4A3B3  ldir
	and	xix, 255	; F4A3B5  and XIX,0x000000ff
	cp	ix, 5:i3	; F4A3BB  cp IX,5
	jr	ugt, SeqRecord_WriteEventToTakeTrack_Join3	; F4A3BD  jr UGT,0xf4a3c3
	add	ix, 256	; F4A3BF  add IX,0x0100
SeqRecord_WriteEventToTakeTrack_Join3:
	cp	ix, 255	; F4A3C3  cp IX,0x00ff
	jr	ugt, SeqRecord_WriteEventToTakeTrack_Skip5	; F4A3C7  jr UGT,0xf4a3cf
	ld	(BStore_CursorOffset:16), ix	; F4A3C9  ld (0x345e),IX
	jr	SeqRecord_WriteEventToTakeTrack_Join4	; F4A3CD  jr T,0xf4a3d2
SeqRecord_WriteEventToTakeTrack_Skip5:
	calr	BStore_ExtendChainAtCursor_B_SaveRegs	; F4A3CF  calr 0xf4a4e3
SeqRecord_WriteEventToTakeTrack_Join4:
	ld	hl, de	; F4A3D2  ld HL,DE
	ld	xix, 13482	; F4A3D4  ld XIX,0x000034aa
	ld	c, (xix+hl)	; F4A3D9  ld C,(XIX+HL)
	calr	SeqRecord_SaveTakeCursor	; F4A3DE  calr 0xf49838
SeqRecord_WriteEventToTakeTrack_Return:
	ret	; F4A3E1  ret
	cp	c, 16	; F4A3E2  cp C,0x10
	jr	nc, SeqRecord_WriteEventToTakeTrack_Skip6	; F4A3E5  jr NC,0xf4a3f5
	ld	iz, (12292:16)	; F4A3E7  ld IZ,(0x3004)
	ld	a, c	; F4A3EB  ld A,C
	scf	; F4A3ED  scf
	xorcf_a_16	iz	; F4A3EE  xorcf A,IZ
	jrl	c, SeqRecord_WriteEventToTakeTrack_Return2	; F4A3F0  jrl C,0xf4a4e2
	jr	SeqRecord_WriteEventToTakeTrack_Join5	; F4A3F3  jr T,0xf4a404
SeqRecord_WriteEventToTakeTrack_Skip6:
	ld	iz, (12294:16)	; F4A3F5  ld IZ,(0x3006)
	ld	a, c	; F4A3F9  ld A,C
	sub	a, 16	; F4A3FB  sub A,0x10
	scf	; F4A3FE  scf
	xorcf_a_16	iz	; F4A3FF  xorcf A,IZ
	jrl	c, SeqRecord_WriteEventToTakeTrack_Return2	; F4A401  jrl C,0xf4a4e2
SeqRecord_WriteEventToTakeTrack_Join5:
	calr	SeqRecord_LoadTakeCursor	; F4A404  calr 0xf4980d
	cpw	(BStore_FreeCount:24), 0x0000	; F4A407  cp (0x6034ba),0x0000
	jr	nz, SeqRecord_WriteEventToTakeTrack_Skip8	; F4A40E  jr NZ,0xf4a44f
	ldw	wa, 256	; F4A410  ld WA,0x0100
	sub	wa, (BStore_CursorOffset:16)	; F4A413  sub WA,(0x345e)
	ld	iy, de	; F4A417  ld IY,DE
	add	iy, 8	; F4A419  add IY,0x0008
	cp	wa, iy	; F4A41D  cp WA,IY
	jr	nc, SeqRecord_WriteEventToTakeTrack_Skip8	; F4A41F  jr NC,0xf4a44f
	ld	c, (13471:16)	; F4A421  ld C,(0x349f)
	cp	c, 16	; F4A425  cp C,0x10
	jr	nc, SeqRecord_WriteEventToTakeTrack_Skip7	; F4A428  jr NC,0xf4a439
	ld	iz, (12292:16)	; F4A42A  ld IZ,(0x3004)
	ld	a, c	; F4A42E  ld A,C
	rcf	; F4A430  rcf
	stcf_a_16	iz	; F4A431  stcf A,IZ
	ld	(12292:16), iz	; F4A433  ld (0x3004),IZ
	jr	SeqRecord_WriteEventToTakeTrack_Join6	; F4A437  jr T,0xf4a449
SeqRecord_WriteEventToTakeTrack_Skip7:
	ld	iz, (12294:16)	; F4A439  ld IZ,(0x3006)
	ld	a, c	; F4A43D  ld A,C
	sub	a, 16	; F4A43F  sub A,0x10
	rcf	; F4A442  rcf
	stcf_a_16	iz	; F4A443  stcf A,IZ
	ld	(12294:16), iz	; F4A445  ld (0x3006),IZ
SeqRecord_WriteEventToTakeTrack_Join6:
	calr	SeqRecord_TerminateTrackOnMemoryFull	; F4A449  calr 0xf4a4f6
	jrl	SeqRecord_WriteEventToTakeTrack_Join8	; F4A44C  jrl T,0xf4a4db
SeqRecord_WriteEventToTakeTrack_Skip8:
	ld	xiy, 13482	; F4A44F  ld XIY,0x000034aa
	ld	wa, (BStore_CursorOffset:16)	; F4A454  ld WA,(0x345e)
	add	wa, de	; F4A458  add WA,DE
	cp	wa, 256	; F4A45A  cp WA,0x0100
	jr	ugt, SeqRecord_WriteEventToTakeTrack_Skip9	; F4A45E  jr UGT,0xf4a487
	ld	ix, (BStore_CursorOffset:16)	; F4A460  ld IX,(0x345e)
	ld	hl, (BStore_CursorBlock:16)	; F4A464  ld HL,(0x345c)
	call	T_BStore_BlockAddrFromHL	; F4A468  call 0xf40c84
	lda	xhl, (xhl+ix)	; F4A46C  lda XHL,XHL+IX
	ld	xix, xhl	; F4A471  ld XIX,XHL
	ld	bc, de	; F4A473  ld BC,DE
	ldir85	; F4A475  ldir
	and	xix, 255	; F4A477  and XIX,0x000000ff
	cp	ix, 5:i3	; F4A47D  cp IX,5
	jr	ugt, SeqRecord_WriteEventToTakeTrack_Join7	; F4A47F  jr UGT,0xf4a4cc
	add	ix, 256	; F4A481  add IX,0x0100
	jr	SeqRecord_WriteEventToTakeTrack_Join7	; F4A485  jr T,0xf4a4cc
SeqRecord_WriteEventToTakeTrack_Skip9:
	ld	ix, (BStore_CursorOffset:16)	; F4A487  ld IX,(0x345e)
	ldw	bc, 256	; F4A48B  ld BC,0x0100
	sub	bc, ix	; F4A48E  sub BC,IX
	ld	hl, (BStore_CursorBlock:16)	; F4A490  ld HL,(0x345c)
	call	T_BStore_BlockAddrFromHL	; F4A494  call 0xf40c84
	lda	xhl, (xhl+ix)	; F4A498  lda XHL,XHL+IX
	ld	xix, xhl	; F4A49D  ld XIX,XHL
	ldir85	; F4A49F  ldir
	calr	BStore_ExtendChainAtCursor_B_SaveRegs	; F4A4A1  calr 0xf4a4e3
	ldw	ix, 5	; F4A4A4  ld IX,0x0005
	ld	hl, (BStore_CursorBlock:16)	; F4A4A7  ld HL,(0x345c)
	call	T_BStore_BlockAddrFromHL	; F4A4AB  call 0xf40c84
	lda	xhl, (xhl+ix)	; F4A4AF  lda XHL,XHL+IX
	ld	xix, xhl	; F4A4B4  ld XIX,XHL
	sub	wa, 256	; F4A4B6  sub WA,0x0100
	ld	bc, wa	; F4A4BA  ld BC,WA
	ldir85	; F4A4BC  ldir
	and	xix, 255	; F4A4BE  and XIX,0x000000ff
	cp	ix, 5:i3	; F4A4C4  cp IX,5
	jr	ugt, SeqRecord_WriteEventToTakeTrack_Join7	; F4A4C6  jr UGT,0xf4a4cc
	add	ix, 256	; F4A4C8  add IX,0x0100
SeqRecord_WriteEventToTakeTrack_Join7:
	cp	ix, 255	; F4A4CC  cp IX,0x00ff
	jr	ugt, SeqRecord_WriteEventToTakeTrack_Skip10	; F4A4D0  jr UGT,0xf4a4d8
	ld	(BStore_CursorOffset:16), ix	; F4A4D2  ld (0x345e),IX
	jr	SeqRecord_WriteEventToTakeTrack_Join8	; F4A4D6  jr T,0xf4a4db
SeqRecord_WriteEventToTakeTrack_Skip10:
	calr	BStore_ExtendChainAtCursor_B_SaveRegs	; F4A4D8  calr 0xf4a4e3
SeqRecord_WriteEventToTakeTrack_Join8:
	ld	c, (13471:16)	; F4A4DB  ld C,(0x349f)
	calr	SeqRecord_SaveTakeCursor	; F4A4DF  calr 0xf49838
SeqRecord_WriteEventToTakeTrack_Return2:
	ret	; F4A4E2  ret

; --------------------------------------------------------------------------
; BStore_ExtendChainAtCursor_B_SaveRegs
; Called from: in-module: 0xF4A398 0xF4A3CF 0xF4A4A1 0xF4A4D8
; Touches: nothing with an absolute address
; Calls:   T_BStore_ExtendChainAtCursor_B
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A4E3 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ExtendChainAtCursor_B_SaveRegs: Calls T_BStore_ExtendChainAtCursor_B (a new block linked after the cursor
;   block, cursor to its offset 5) with XWA, XBC, XDE, XHL, XIX, XIY and XIZ saved around it.
;   SeqRecord_WriteEventToTakeTrack calls it when an event's bytes run past offset 0xFF. Basis: caller + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave11_a11.json)
BStore_ExtendChainAtCursor_B_SaveRegs:
	push	xwa	; F4A4E3  push XWA
	push	xbc	; F4A4E4  push XBC
	push	xde	; F4A4E5  push XDE
	push	xhl	; F4A4E6  push XHL
	push	xix	; F4A4E7  push XIX
	push	xiy	; F4A4E8  push XIY
	push	xiz	; F4A4E9  push XIZ
	call	T_BStore_ExtendChainAtCursor_B	; F4A4EA  call 0xf40c68
	pop	xiz	; F4A4EE  pop XIZ
	pop	xiy	; F4A4EF  pop XIY
	pop	xix	; F4A4F0  pop XIX
	pop	xhl	; F4A4F1  pop XHL
	pop	xde	; F4A4F2  pop XDE
	pop	xbc	; F4A4F3  pop XBC
	pop	xwa	; F4A4F4  pop XWA
	ret	; F4A4F5  ret

; --------------------------------------------------------------------------
; SeqRecord_TerminateTrackOnMemoryFull
; Called from: in-module: 0xF49D7D 0xF49FEE 0xF4A338 0xF4A449
; Touches: (0x349F) (0x34D1)
; Calls:   T_SeqRecord_TerminateTrackAtCursor_Veneer sub_F4A50E SeqRecord_SoundAlert T_Var34D1_SetBits20_Veneer
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A4F6 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_TerminateTrackOnMemoryFull: (C = a track its caller has just cleared from the take mask) (0x349F) := C,
;   SeqRecord_TerminateTrackAtCursor (0x81 and the 0x82 end tag at the take cursor),
;   SeqRecord_SetRecordedTracksPlaying when no track is left in the take ((0x3004) long = 0), SeqRecord_SoundAlert,
;   (0x34D1) |= 0x30. All four callers reach it only with BStore_FreeCount = 0 and too few bytes left in the block.
;   Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave11_a11.json)
SeqRecord_TerminateTrackOnMemoryFull:
	ld	(13471:16), c	; F4A4F6  ld (0x349f),C
	call	T_SeqRecord_TerminateTrackAtCursor_Veneer	; F4A4FA  call 0xf40a98
	calr	sub_F4A50E	; F4A4FE  calr 0xf4a50e
	calr	SeqRecord_SoundAlert	; F4A501  calr 0xf49861
	call	T_Var34D1_SetBits20_Veneer	; F4A504  call 0xf40a80
	or	(0x34d1:16), 0x10	; F4A508  or (0x34d1),0x10
	ret	; F4A50D  ret

; --------------------------------------------------------------------------
; sub_F4A50E
; Called from: in-module: 0xF4A4FE
; Touches: (0x3004) (0x349F)  |  0x000000 0x603422
; Calls:   T_SeqRecord_SetRecordedTracksPlaying_Veneer
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A50E is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4A50E:
	ld	xwa, (12292:16)	; F4A50E  ld XWA,(0x3004)
	cp	xwa, 0	; F4A512  cp XWA,0x00000000
	jr	nz, sub_F4A50E_Return	; F4A518  jr NZ,0xf4a51e
	call	T_SeqRecord_SetRecordedTracksPlaying_Veneer	; F4A51A  call 0xf40a78
sub_F4A50E_Return:
	ret	; F4A51E  ret
sub_F4A50E_Join:
	xor	wa, wa	; F4A51F  xor WA,WA
	ld	a, (13471:16)	; F4A521  ld A,(0x349f)
	ld	iy, wa	; F4A525  ld IY,WA
	ld	xix, BStore_TrackToPart	; F4A527  ld XIX,0x00603422
	ld	a, (xix+iy)	; F4A52C  ld A,(XIX+IY)
	ld	iy, wa	; F4A531  ld IY,WA
	ld	xix, IdentityMap_F4B7AD	; F4A533  ld XIX,0x00f4b7ad
	ld	a, (xix+iy)	; F4A538  ld A,(XIX+IY)
	ret	; F4A53D  ret

; --------------------------------------------------------------------------
; SeqRecord_LoadHeldNoteListHeadTail
; Called from: in-module: 0xF49C25 0xF49D87 0xF4A040 0xF4A12D 0xF4AD32
; Touches: (0x33DA) (0x33DB) (0x349F)  |  0x003016
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A53E is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_LoadHeldNoteListHeadTail: (0x33DA) := 0x3016[2t], (0x33DB) := 0x3016[2t+1] for track t = (0x349F): the
;   first and last held-note slots of the track's list (0 = empty), as SeqRecord_WriteNoteOn appends a slot -- head
;   written when (0x33DA) = 0, old tail's +7 linked, new slot made the tail. Preserves BC, IY, XHL. Basis: callers +
;   body + the list writer. (notes/naming-pilot-2026-10-06/proposals_wave11_a11.json)
SeqRecord_LoadHeldNoteListHeadTail:
	pushw	bc	; F4A53E  push BC
	pushw	iy	; F4A53F  push IY
	push	xhl	; F4A540  push XHL
	xor	bc, bc	; F4A541  xor BC,BC
	ld	c, (13471:16)	; F4A543  ld C,(0x349f)
	ld	iy, bc	; F4A547  ld IY,BC
	sla	iy, 1	; F4A549  sla 0x01,IY
	ld	xhl, 12310	; F4A54C  ld XHL,0x00003016
	ld	c, (xhl+iy)	; F4A551  ld C,(XHL+IY)
	ld	(13274:16), c	; F4A556  ld (0x33da),C
	ld	xiz, xhl	; F4A55A  ld XIZ,XHL
	lda	xiz, (xiz+iy)	; F4A55C  lda XIZ,XIZ+IY
	ld	c, (xiz+1)	; F4A561  ld C,(XIZ+0x01)
	ld	(13275:16), c	; F4A564  ld (0x33db),C
	pop	xhl	; F4A568  pop XHL
	popw	iy	; F4A569  pop IY
	popw	bc	; F4A56A  pop BC
	ret	; F4A56B  ret

; --------------------------------------------------------------------------
; SeqRecord_HeldNoteSlotAddress
; Called from: in-module: 0xF49C35 0xF49D9B 0xF49E02 0xF49E7D 0xF49EBC
;              0xF49F08 0xF49FAD 0xF4A088 +8 more
; Touches:   |  0x00305A
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A56C is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_HeldNoteSlotAddress: XHL := 0x305A + (HL - 1) * 8: the address of 1-based held-note slot HL (8 bytes: +0
;   note, +1 beats, +2 start tick, +3/+5 the note byte's cursor, +6 previous, +7 next; free list head at 0x3014). Used
;   by SeqRecord_WriteNoteOn, SeqRecord_CloseHeldNote, SeqRecord_WriteBeatMarkAndAgeHeldNotes and the cycle-record
;   slot opener. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave11_a11.json)
SeqRecord_HeldNoteSlotAddress:
	push	xwa	; F4A56C  push XWA
	ld	qhl, 0	; F4A56D  ld QHL,0
	ld	xwa, 12378	; F4A570  ld XWA,0x0000305a
	dec	1, xhl	; F4A575  dec 1,XHL
	sla	xhl, 3	; F4A577  sla 0x03,XHL
	add	xhl, xwa	; F4A57A  add XHL,XWA
	pop	xwa	; F4A57C  pop XWA
	ret	; F4A57D  ret

; --------------------------------------------------------------------------
; SeqRecord_SaveCursorBaseline
; Called from: T_SeqRecord_SaveCursorBaseline (x3)
; Touches: (0x36FA) (0x36FC)
; Calls:   SeqRecord_CopyTrackCursorsToBaseline
; Evidence: thunk slot T_SeqRecord_SaveCursorBaseline holds `jp 0x00F4A57E`, and 0xF4A57E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_SaveCursorBaseline: Copies the 17 saved track cursors (workspace +0x7E block words, +0xA0 offsets) to the
;   backup 0x36FE/0x3720 that SeqRecord_RestoreCursorBaseline restores before each cycle-record pass, then sets the take-chain heads
;   0x36FA/0x36FC to 0xFFFF without freeing them. Run on entering REALTIME RECORD and on both stop arms of
;   Transport_StopWhileRecording. Basis: callers + body + restore/free siblings. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_h.json)
SeqRecord_SaveCursorBaseline:		; <- T_SeqRecord_SaveCursorBaseline
	calr	SeqRecord_CopyTrackCursorsToBaseline	; F4A57E  calr 0xf4a58e
	ldw	(14074:16), 65535	; F4A581  ld (0x36fa),0xffff
	ldw	(14076:16), 65535	; F4A587  ld (0x36fc),0xffff
	ret	; F4A58D  ret

; --------------------------------------------------------------------------
; SeqRecord_CopyTrackCursorsToBaseline
; Called from: in-module: 0xF4A57E
; Touches:   |  0x0036FE 0x003720 0x60347E 0x6034A0
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A58E is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_CopyTrackCursorsToBaseline: Copies the 17 per-track cursors of the song workspace -- block words 0x60347E
;   and offsets 0x6034A0, the append point BStore_AppendBytes advances -- to the record baseline 0x36FE / 0x3720. The
;   copy step of SeqRecord_SaveCursorBaseline; SeqRecord_RestoreCursorBaseline (proposed in this batch) copies them
;   back. Basis: caller + body + inverse. (notes/naming-pilot-2026-10-06/proposals_wave4_n.json)
SeqRecord_CopyTrackCursorsToBaseline:
	ldw	bc, 17	; F4A58E  ld BC,0x0011
	ld	xde, 14078	; F4A591  ld XDE,0x000036fe
	ld	xhl, 6304894	; F4A596  ld XHL,0x0060347e
	ldirw93	; F4A59B  ldirw
	ldw	bc, 17	; F4A59D  ld BC,0x0011
	ld	xde, 14112	; F4A5A0  ld XDE,0x00003720
	ld	xhl, 6304928	; F4A5A5  ld XHL,0x006034a0
	ldir83	; F4A5AA  ldir
	ret	; F4A5AC  ret

; --------------------------------------------------------------------------
; CycleRecord_SetUpRecordTrack
; Called from: T_CycleRecord_SetUpRecordTrack (x6)
; Touches: (0x3731)
; Calls:   CycleRecord_RestartPass
; Evidence: thunk slot T_CycleRecord_SetUpRecordTrack holds `jp 0x00F4A5AD`, and 0xF4A5AD is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_SetUpRecordTrack: Clears (0x3731) bit 0, then CycleRecord_RestartPass: if the record mask (0x3000) is non-zero, the
;   lowest armed track becomes (0x36D6), gets its bit in (0x60341E), and has its block-store cursors placed at cycle-
;   record start (0x3622) and end+1 (0x3624) by CycleRecord_CopyCycleRangeToTakeChain2. Every caller runs it only with cycle record on: (0x360B)
;   bit 1 tested directly, or CycleRecord_CheckOn returning 0 (screen 6/8 + that bit). Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_f.json)
CycleRecord_SetUpRecordTrack:		; <- T_CycleRecord_SetUpRecordTrack
	res	0, (0x3731:16)	; F4A5AD  res 0,(0x3731)
	calr	CycleRecord_RestartPass	; F4A5B1  calr 0xf4a5b5
	ret	; F4A5B4  ret

; --------------------------------------------------------------------------
; CycleRecord_RestartPass
; Called from: T_CycleRecord_RestartPass (x3); in-module: 0xF4A5B1
; Touches: (0x0D4A) (0x3000) (0x3002) (0x34D4) (0x34D9) (0x3552) (0x36D4)
;          (0x36D6) (0x3751)  |  0x000000
; Calls:   SeqRecord_RestoreCursorBaseline T_SeqCycle_CaptureEndCursors T_SeqCycle_LocateToStart T_Seq_SetTrackBeatsFromTransportB CycleRecord_FreeRecordChain SeqRecord_FreeTakeChain2
;          CycleRecord_CopyCycleRangeToTakeChain2 CycleRecord_AllocRecordChain CycleRecord_PlayTrackFromTakeChain2 T_Seq_ResetPositionOnRequest
; Evidence: thunk slot T_CycleRecord_RestartPass holds `jp 0x00F4A5B5`, and 0xF4A5B5 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_RestartPass: The body behind the CycleRecord_SetUpRecordTrack stub (which first clears (0x3731) bit 0):
;   restores the saved track cursors from the baseline (SeqRecord_RestoreCursorBaseline), re-captures the cycle end and locates to the
;   cycle start (with (0x3751) bit 0 set), then, when tracks are armed, makes the lowest armed track the record track
;   (0x36D6), adds it to the playing mask and places its cursors (CycleRecord_FreeRecordChain, SeqRecord_FreeTakeChain2, CycleRecord_CopyCycleRangeToTakeChain2, CycleRecord_AllocRecordChain,
;   CycleRecord_PlayTrackFromTakeChain2), (0x34D4) bit 4, T_Seq_ResetPositionOnRequest. The Dispatch_3629 arms reach it through T_CycleRecord_RestartPass when a cycle bound changes
;   during a cycle-record take. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave4_k.json)
; Correction (naming wave 5, notes/naming-pilot-2026-10-06/proposals_wave5_p.json): of the calls above,
;   CycleRecord_CopyCycleRangeToTakeChain2 does more than place cursors: it copies the record track's data from the
;   cycle start to the cycle end measure into take chain 2 (0x36FC), padding a short track with 0x81 beat marks.
CycleRecord_RestartPass:		; <- T_CycleRecord_RestartPass
	calr	SeqRecord_RestoreCursorBaseline	; F4A5B5  calr 0xf4b414
	set	0, (0x3751:16)	; F4A5B8  set 0,(0x3751)
	call	T_SeqCycle_CaptureEndCursors	; F4A5BC  call 0xf40b60
	call	T_SeqCycle_LocateToStart	; F4A5C0  call 0xf40b5c
	call	T_Seq_SetTrackBeatsFromTransportB	; F4A5C4  call 0xf40ac4
	res	0, (0x3751:16)	; F4A5C8  res 0,(0x3751)
	ld	xwa, (12288:16)	; F4A5CC  ld XWA,(0x3000)
	cp	xwa, 0	; F4A5D0  cp XWA,0x00000000
	jrl	z, CycleRecord_RestartPass_Return	; F4A5D6  jrl Z,0xf4a660
	bit	0, (0x34d9:16)	; F4A5D9  bit 0,(0x34d9)
	jr	z, CycleRecord_RestartPass_Skip	; F4A5DD  jr Z,0xf4a5e7
	ld	wa, (13650:16)	; F4A5DF  ld WA,(0x3552)
	ld	(14036:16), wa	; F4A5E3  ld (0x36d4),WA
CycleRecord_RestartPass_Skip:
	xor	wa, wa	; F4A5E7  xor WA,WA
CycleRecord_RestartPass_Loop:
	cp	a, 16	; F4A5E9  cp A,0x10
	jr	nc, CycleRecord_RestartPass_Skip2	; F4A5EC  jr NC,0xf4a5f9
	ld	iz, (12288:16)	; F4A5EE  ld IZ,(0x3000)
	scf	; F4A5F2  scf
	xorcf_a_16	iz	; F4A5F3  xorcf A,IZ
	jr	c, CycleRecord_RestartPass_Skip4	; F4A5F5  jr C,0xf4a633
	jr	CycleRecord_RestartPass_Join	; F4A5F7  jr T,0xf4a607
CycleRecord_RestartPass_Skip2:
	pushw	wa	; F4A5F9  push WA
	ld	iz, (12290:16)	; F4A5FA  ld IZ,(0x3002)
	sub	a, 16	; F4A5FE  sub A,0x10
	scf	; F4A601  scf
	xorcf_a_16	iz	; F4A602  xorcf A,IZ
	popw	wa	; F4A604  pop WA
	jr	c, CycleRecord_RestartPass_Skip4	; F4A605  jr C,0xf4a633
CycleRecord_RestartPass_Join:
	ld	(14038:16), a	; F4A607  ld (0x36d6),A
	cp	a, 16	; F4A60B  cp A,0x10
	jr	nc, CycleRecord_RestartPass_Skip3	; F4A60E  jr NC,0xf4a61f
	ld	de, (6304798:24)	; F4A610  ld DE,(0x60341e)
	scf	; F4A615  scf
	stcf_a_16	de	; F4A616  stcf A,DE
	ld	(6304798:24), de	; F4A618  ld (0x60341e),DE
	jr	CycleRecord_RestartPass_Join2	; F4A61D  jr T,0xf4a631
CycleRecord_RestartPass_Skip3:
	ld	de, (6304800:24)	; F4A61F  ld DE,(0x603420)
	pushw	wa	; F4A624  push WA
	sub	a, 16	; F4A625  sub A,0x10
	scf	; F4A628  scf
	stcf_a_16	de	; F4A629  stcf A,DE
	popw	wa	; F4A62B  pop WA
	ld	(6304800:24), de	; F4A62C  ld (0x603420),DE
CycleRecord_RestartPass_Join2:
	jr	CycleRecord_RestartPass_Join3	; F4A631  jr T,0xf4a63a
CycleRecord_RestartPass_Skip4:
	inc	1, a	; F4A633  inc 1,A
	cp	a, 17	; F4A635  cp A,0x11
	jr	c, CycleRecord_RestartPass_Loop	; F4A638  jr C,0xf4a5e9
CycleRecord_RestartPass_Join3:
	calr	CycleRecord_FreeRecordChain	; F4A63A  calr 0xf4a6cf
	calr	SeqRecord_FreeTakeChain2	; F4A63D  calr 0xf4a6e7
	calr	CycleRecord_CopyCycleRangeToTakeChain2	; F4A640  calr 0xf4a756
	cp	(BStore_ErrorCode:16), 0x00	; F4A643  cp (0x0d4a),0x00
	jr	nz, CycleRecord_RestartPass_Return	; F4A648  jr NZ,0xf4a660
	calr	CycleRecord_AllocRecordChain	; F4A64A  calr 0xf4ab8a
	cp	(BStore_ErrorCode:16), 0x00	; F4A64D  cp (0x0d4a),0x00
	jr	nz, CycleRecord_RestartPass_Return	; F4A652  jr NZ,0xf4a660
	calr	CycleRecord_PlayTrackFromTakeChain2	; F4A654  calr 0xf4a6ff
	or	(0x34d4:16), 0x10	; F4A657  or (0x34d4),0x10
	call	T_Seq_ResetPositionOnRequest	; F4A65C  call 0xf40aac
CycleRecord_RestartPass_Return:
	ret	; F4A660  ret

; --------------------------------------------------------------------------
; sub_F4A661
; Called from: T_F40BE0 (x2)
; Touches: (0x3000) (0x3002) (0x34D4) (0x34D9)
; Calls:   CycleRecord_FreeRecordChain SeqRecord_FreeTakeChain2 T_SeqRecord_RewindForTake T_NoteRouting_RebuildForSong
; Evidence: thunk slot T_F40BE0 holds `jp 0x00F4A661`, and 0xF4A661 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4A661:		; <- T_F40BE0
	calr	CycleRecord_FreeRecordChain	; F4A661  calr 0xf4a6cf
	calr	SeqRecord_FreeTakeChain2	; F4A664  calr 0xf4a6e7
	bit	1, (0x34d9:16)	; F4A667  bit 1,(0x34d9)
	jr	nz, sub_F4A5B5_Skip5	; F4A66B  jr NZ,0xf4a672
	and	(0x34d4:16), 0xf7	; F4A66D  and (0x34d4),0xf7
sub_F4A5B5_Skip5:
	xor	wa, wa	; F4A672  xor WA,WA
sub_F4A5B5_Join4:
	cp	a, 17	; F4A674  cp A,0x11
	jr	nc, sub_F4A5B5_Join6	; F4A677  jr NC,0xf4a6c1
	cp	a, 16	; F4A679  cp A,0x10
	jr	nc, sub_F4A5B5_Skip6	; F4A67C  jr NC,0xf4a689
	ld	de, (12288:16)	; F4A67E  ld DE,(0x3000)
	scf	; F4A682  scf
	xorcf_a_16	de	; F4A683  xorcf A,DE
	jr	nc, sub_F4A5B5_Skip7	; F4A685  jr NC,0xf4a69b
	jr	sub_F4A5B5_Join5	; F4A687  jr T,0xf4a697
sub_F4A5B5_Skip6:
	pushw	wa	; F4A689  push WA
	ld	de, (12290:16)	; F4A68A  ld DE,(0x3002)
	sub	a, 16	; F4A68E  sub A,0x10
	scf	; F4A691  scf
	xorcf_a_16	de	; F4A692  xorcf A,DE
	popw	wa	; F4A694  pop WA
	jr	nc, sub_F4A5B5_Skip7	; F4A695  jr NC,0xf4a69b
sub_F4A5B5_Join5:
	inc	1, a	; F4A697  inc 1,A
	jr	sub_F4A5B5_Join4	; F4A699  jr T,0xf4a674
sub_F4A5B5_Skip7:
	cp	a, 16	; F4A69B  cp A,0x10
	jr	nc, sub_F4A5B5_Skip8	; F4A69E  jr NC,0xf4a6af
	ld	de, (6304798:24)	; F4A6A0  ld DE,(0x60341e)
	rcf	; F4A6A5  rcf
	stcf_a_16	de	; F4A6A6  stcf A,DE
	ld	(6304798:24), de	; F4A6A8  ld (0x60341e),DE
	jr	sub_F4A5B5_Join6	; F4A6AD  jr T,0xf4a6c1
sub_F4A5B5_Skip8:
	pushw	wa	; F4A6AF  push WA
	ld	de, (6304800:24)	; F4A6B0  ld DE,(0x603420)
	sub	a, 16	; F4A6B5  sub A,0x10
	rcf	; F4A6B8  rcf
	stcf_a_16	de	; F4A6B9  stcf A,DE
	ld	(6304800:24), de	; F4A6BB  ld (0x603420),DE
	popw	wa	; F4A6C0  pop WA
sub_F4A5B5_Join6:
	or	(0x34d4:16), 0x10	; F4A6C1  or (0x34d4),0x10
	call	T_SeqRecord_RewindForTake	; F4A6C6  call 0xf409d0
	call	T_NoteRouting_RebuildForSong	; F4A6CA  call 0xf411b8
	ret	; F4A6CE  ret

; --------------------------------------------------------------------------
; CycleRecord_FreeRecordChain
; Called from: T_CycleRecord_FreeRecordChain (x3); in-module: 0xF4A63A 0xF4A661 0xF4A806 0xF4AF91
;              0xF4AFC0 0xF4B05E 0xF4B15C
; Touches: (0x36FA)
; Calls:   T_BStore_FreeChain_B_Veneer
; Evidence: thunk slot T_CycleRecord_FreeRecordChain holds `jp 0x00F4A6CF`, and 0xF4A6CF is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_FreeRecordChain: If (0x36FA) holds a block number (not 0xFFFF): (0x36FA) := 0xFFFF and that whole chain
;   goes back to the free list (T_BStore_FreeChain_B_Veneer -> BStore_FreeChain_B, WA = 0xFFFF). (0x36FA) is the chain CycleRecord_AllocRecordChain allocates for
;   the cycle-record track and enters as its directory chain. Run by CycleRecord_SetUpRecordTrack's body before
;   allocating again and by the REALTIME RECORD key that turns cycle record off. Basis: callers + body + allocator.
;   (notes/naming-pilot-2026-10-06/proposals_wave4_l.json)
CycleRecord_FreeRecordChain:		; <- T_CycleRecord_FreeRecordChain
	ld	iy, (14074:16)	; F4A6CF  ld IY,(0x36fa)
	cp	iy, 65535	; F4A6D3  cp IY,0xffff
	jr	z, CycleRecord_FreeRecordChain_Return	; F4A6D7  jr Z,0xf4a6e6
	ldw	(14074:16), 65535	; F4A6D9  ld (0x36fa),0xffff
	ldw	wa, 65535	; F4A6DF  ld WA,0xffff
	call	T_BStore_FreeChain_B_Veneer	; F4A6E2  call 0xf40c94
CycleRecord_FreeRecordChain_Return:
	ret	; F4A6E6  ret

; --------------------------------------------------------------------------
; SeqRecord_FreeTakeChain2
; Called from: T_SeqRecord_FreeTakeChain2 (x3); in-module: 0xF4A63D 0xF4A664 0xF4A803 0xF4AF7D
;              0xF4AFB7 0xF4B061 0xF4B067 0xF4B0EB +3 more
; Touches: (0x36FC)
; Calls:   T_BStore_FreeChain_B_Veneer
; Evidence: thunk slot T_SeqRecord_FreeTakeChain2 holds `jp 0x00F4A6E7`, and 0xF4A6E7 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_FreeTakeChain2: If the second take-chain head (0x36FC) is set, frees that whole chain (T_BStore_FreeChain_B_Veneer ->
;   BStore_FreeChain_B_Veneer -> the BStore_FreeChain copy BStore_FreeChain_B, count 0xFFFF) and sets the head to 0xFFFF; CycleRecord_FreeRecordChain does the
;   same for (0x36FA). Run when LcdKeyRow2_RealtimeRecordScreen switches CYCLE record off and before each cycle-record
;   set-up (CycleRecord_RestartPass). Basis: callers + body + SeqRecord_SaveCursorBaseline header. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_m.json)
SeqRecord_FreeTakeChain2:		; <- T_SeqRecord_FreeTakeChain2
	ld	iy, (14076:16)	; F4A6E7  ld IY,(0x36fc)
	cp	iy, 65535	; F4A6EB  cp IY,0xffff
	jr	z, SeqRecord_FreeTakeChain2_Return	; F4A6EF  jr Z,0xf4a6fe
	ldw	(14076:16), 65535	; F4A6F1  ld (0x36fc),0xffff
	ldw	wa, 65535	; F4A6F7  ld WA,0xffff
	call	T_BStore_FreeChain_B_Veneer	; F4A6FA  call 0xf40c94
SeqRecord_FreeTakeChain2_Return:
	ret	; F4A6FE  ret

; --------------------------------------------------------------------------
; CycleRecord_PlayTrackFromTakeChain2
; Called from: in-module: 0xF4A654 0xF4AFBD 0xF4B07E
; Touches: (0x349A) (0x349C) (0x36C6) (0x36CA) (0x36D6) (0x36FC)  |
;          0x003460 0x003482
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A6FF is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_PlayTrackFromTakeChain2: Record track (0x36D6)'s live cursor 0x3460[t]/0x3482[t] := head of take chain 2
;   (0x36FC), offset 5; the track joins the playing set (0x349A)/(0x349C), which is copied to (0x36CA) and (0x36C6).
;   Last placement step of CycleRecord_RestartPass. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_p.json)
CycleRecord_PlayTrackFromTakeChain2:
	ld	xix, 13408	; F4A6FF  ld XIX,0x00003460
	xor	xwa, xwa	; F4A704  xor XWA,XWA
	ld	a, (14038:16)	; F4A706  ld A,(0x36d6)
	sll	xwa, 1	; F4A70A  sll 0x01,XWA
	add	xix, xwa	; F4A70D  add XIX,XWA
	ld	wa, (14076:16)	; F4A70F  ld WA,(0x36fc)
	ld	(xix), wa	; F4A713  ld (XIX),WA
	ld	xix, 13442	; F4A715  ld XIX,0x00003482
	xor	xwa, xwa	; F4A71A  xor XWA,XWA
	ld	a, (14038:16)	; F4A71C  ld A,(0x36d6)
	add	xix, xwa	; F4A720  add XIX,XWA
	ld	(xix), 5	; F4A722  ld (XIX),0x05
	ld	a, (14038:16)	; F4A725  ld A,(0x36d6)
	cp	a, 16	; F4A729  cp A,0x10
	jr	nc, CycleRecord_PlayTrackFromTakeChain2_Skip	; F4A72C  jr NC,0xf4a73b
	ld	de, (13466:16)	; F4A72E  ld DE,(0x349a)
	scf	; F4A732  scf
	stcf_a_16	de	; F4A733  stcf A,DE
	ld	(13466:16), de	; F4A735  ld (0x349a),DE
	jr	CycleRecord_PlayTrackFromTakeChain2_Join	; F4A739  jr T,0xf4a749
CycleRecord_PlayTrackFromTakeChain2_Skip:
	ld	de, (13468:16)	; F4A73B  ld DE,(0x349c)
	sub	a, 16	; F4A73F  sub A,0x10
	scf	; F4A742  scf
	stcf_a_16	de	; F4A743  stcf A,DE
	ld	(13468:16), de	; F4A745  ld (0x349c),DE
CycleRecord_PlayTrackFromTakeChain2_Join:
	ld	xwa, (13466:16)	; F4A749  ld XWA,(0x349a)
	ld	(14026:16), xwa	; F4A74D  ld (0x36ca),XWA
	ld	(14022:16), xwa	; F4A751  ld (0x36c6),XWA
	ret	; F4A755  ret

; --------------------------------------------------------------------------
; CycleRecord_CopyCycleRangeToTakeChain2
; Called from: in-module: 0xF4A640 0xF4B064
; Touches: (0x0C90) (0x0D4A) (0x345C) (0x345E) (0x3622) (0x3624) (0x36D6)
;          (0x36D8) (0x36DA) (0x36DC) +1 more  |  0x603500
; Calls:   T_SeqMasterTrack_UpdateActive T_BStore_SeekChainToMeasure CycleRecord_FillTakeChain2WithBeatMarks CycleRecord_CopyPaddedRangeToTakeChain2 T_BStore_StepCursorBackToLeadByte CycleRecord_CopyRangeToTakeChain2
;          CycleRecord_AbortMemoryFull
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A756 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CopyCycleRangeToTakeChain2: Fills take chain 2 (0x36FC) with record track (0x36D6)'s data from the cycle
;   start measure (0x3622) to the end measure (0x3624): seeks both bounds, copies the range (CycleRecord_CopyRangeToTakeChain2 ->
;   CycleRecord_CopyRangeIntoGrowingChain); a track ending early is padded (CycleRecord_CopyPaddedRangeToTakeChain2), an empty one gets that many 0x81 beat marks
;   (CycleRecord_FillTakeChain2WithBeatMarks); failures -> CycleRecord_AbortMemoryFull. CycleRecord_RestartPass step. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_p.json)
CycleRecord_CopyCycleRangeToTakeChain2:
	xor	xwa, xwa	; F4A756  xor XWA,XWA
	ld	a, (14038:16)	; F4A758  ld A,(0x36d6)
	mul	a, 3	; F4A75C  mul A,0x03
	ld	xix, 6305024	; F4A75F  ld XIX,0x00603500
	add	xix, xwa	; F4A764  add XIX,XWA
	bit	7, (xix)	; F4A766  bit 7,(XIX)
	jr	nz, CycleRecord_CopyCycleRangeToTakeChain2_Skip	; F4A768  jr NZ,0xf4a76c
	jr	CycleRecord_CopyCycleRangeToTakeChain2_Join	; F4A76A  jr T,0xf4a78a
CycleRecord_CopyCycleRangeToTakeChain2_Skip:
	ld	wa, (13858:16)	; F4A76C  ld WA,(0x3622)
	ld	(3216:16), wa	; F4A770  ld (0x0c90),WA
	call	T_SeqMasterTrack_UpdateActive	; F4A774  call 0xf40aa8
	ld	a, (14038:16)	; F4A778  ld A,(0x36d6)
	add	a, 1	; F4A77C  add A,0x01
	call	T_BStore_SeekChainToMeasure	; F4A77F  call 0xf40c5c
	cp	(BStore_ErrorCode:16), 0x00	; F4A783  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyCycleRangeToTakeChain2_Skip2	; F4A788  jr Z,0xf4a79b
CycleRecord_CopyCycleRangeToTakeChain2_Join:
	ld	(BStore_ErrorCode:16), 0	; F4A78A  ld (0x0d4a),0x00
	calr	CycleRecord_FillTakeChain2WithBeatMarks	; F4A78F  calr 0xf4a813
	cp	(BStore_ErrorCode:16), 0x00	; F4A792  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyCycleRangeToTakeChain2_Return	; F4A797  jr Z,0xf4a7fd
	jr	CycleRecord_CopyCycleRangeToTakeChain2_Join2	; F4A799  jr T,0xf4a7fa
CycleRecord_CopyCycleRangeToTakeChain2_Skip2:
	ld	wa, (BStore_CursorBlock:16)	; F4A79B  ld WA,(0x345c)
	ld	(14040:16), wa	; F4A79F  ld (0x36d8),WA
	ld	(14042:16), iy	; F4A7A3  ld (0x36da),IY
	ld	wa, (13860:16)	; F4A7A7  ld WA,(0x3624)
	inc	1, wa	; F4A7AB  inc 1,WA
	ld	(3216:16), wa	; F4A7AD  ld (0x0c90),WA
	call	T_SeqMasterTrack_UpdateActive	; F4A7B1  call 0xf40aa8
	ld	a, (14038:16)	; F4A7B5  ld A,(0x36d6)
	add	a, 1	; F4A7B9  add A,0x01
	call	T_BStore_SeekChainToMeasure	; F4A7BC  call 0xf40c5c
	cp	(BStore_ErrorCode:16), 0x00	; F4A7C0  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyCycleRangeToTakeChain2_Skip3	; F4A7C5  jr Z,0xf4a7d8
	ld	(BStore_ErrorCode:16), 0	; F4A7C7  ld (0x0d4a),0x00
	calr	CycleRecord_CopyPaddedRangeToTakeChain2	; F4A7CC  calr 0xf4a976
	cp	(BStore_ErrorCode:16), 0x00	; F4A7CF  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyCycleRangeToTakeChain2_Return	; F4A7D4  jr Z,0xf4a7fd
	jr	CycleRecord_CopyCycleRangeToTakeChain2_Join2	; F4A7D6  jr T,0xf4a7fa
CycleRecord_CopyCycleRangeToTakeChain2_Skip3:
	ld	(BStore_CursorOffset:16), iy	; F4A7D8  ld (0x345e),IY
	call	T_BStore_StepCursorBackToLeadByte	; F4A7DC  call 0xf40b6c
	ld	wa, (BStore_CursorBlock:16)	; F4A7E0  ld WA,(0x345c)
	ld	(14044:16), wa	; F4A7E4  ld (0x36dc),WA
	ld	wa, (BStore_CursorOffset:16)	; F4A7E8  ld WA,(0x345e)
	ld	(14046:16), wa	; F4A7EC  ld (0x36de),WA
	calr	CycleRecord_CopyRangeToTakeChain2	; F4A7F0  calr 0xf4aa88
	cp	(BStore_ErrorCode:16), 0x00	; F4A7F3  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyCycleRangeToTakeChain2_Return	; F4A7F8  jr Z,0xf4a7fd
CycleRecord_CopyCycleRangeToTakeChain2_Join2:
	calr	CycleRecord_AbortMemoryFull	; F4A7FA  calr 0xf4a7fe
CycleRecord_CopyCycleRangeToTakeChain2_Return:
	ret	; F4A7FD  ret

; --------------------------------------------------------------------------
; CycleRecord_AbortMemoryFull
; Called from: in-module: 0xF4A7FA 0xF4A886 0xF4ABE4 0xF4AC46 0xF4AC9F
;              0xF4AF3A 0xF4B156
; Touches: (0x0D4A) (0x34D1)
; Calls:   SeqRecord_FreeTakeChain2 CycleRecord_FreeRecordChain T_Var34D1_SetBits20
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A7FE is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_AbortMemoryFull: Cycle-record failure exit: BStore_ErrorCode := 0xFF, frees take chain 2 and the record
;   chain (SeqRecord_FreeTakeChain2, CycleRecord_FreeRecordChain), posts song-memory-full (Var34D1_SetBits20 ->
;   Seq_ShowMemoryFullOnRequest) and (0x34D1) bit 4 (UI_Request 0x0201 on the next RECORD ScreenEnter). Run when no
;   block is free (CycleRecord_AllocRecordChain) or a copy failed (CycleRecord_CopyCycleRangeToTakeChain2,
;   CycleRecord_CommitTake). Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
CycleRecord_AbortMemoryFull:
	ld	(BStore_ErrorCode:16), 255	; F4A7FE  ld (0x0d4a),0xff
	calr	SeqRecord_FreeTakeChain2	; F4A803  calr 0xf4a6e7
	calr	CycleRecord_FreeRecordChain	; F4A806  calr 0xf4a6cf
	call	T_Var34D1_SetBits20	; F4A809  call 0xf40a08
	or	(0x34d1:16), 0x10	; F4A80D  or (0x34d1),0x10
	ret	; F4A812  ret

; --------------------------------------------------------------------------
; CycleRecord_FillTakeChain2WithBeatMarks
; Called from: in-module: 0xF4A78F 0xF4AF80 0xF4AFBA 0xF4B06A
; Touches: (0x0D4A)
; Calls:   T_SeqTrackCursors_Save CycleRecord_AllocTakeChain2 CycleRecord_CountCycleRangeBeats CycleRecord_AppendBeatMarks T_SeqTrackCursors_RestoreSaved
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A813 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_FillTakeChain2WithBeatMarks: Starts take chain 2 (0x36FC) as one block holding the 0x82 end tag and
;   makes it record track (0x36D6)'s end cursor (CycleRecord_AllocTakeChain2; no free block -> CycleRecord_AbortMemoryFull), then
;   appends one 0x81 beat mark per beat of the cycle range (count from CycleRecord_CountCycleRangeBeats: (0x3624)-(0x3622)+1 bars x
;   TransportA_BeatsPerBar, or via CycleRecord_BeatsBeforeMeasureFromTimeSigs). Track cursors saved/restored around it.
;   CycleRecord_CopyCycleRangeToTakeChain2's empty-track arm. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_s.json)
CycleRecord_FillTakeChain2WithBeatMarks:
	call	T_SeqTrackCursors_Save	; F4A813  call 0xf40b68
	calr	CycleRecord_AllocTakeChain2	; F4A817  calr 0xf4a82c
	cp	(BStore_ErrorCode:16), 0x00	; F4A81A  cp (0x0d4a),0x00
	jr	nz, CycleRecord_FillTakeChain2WithBeatMarks_Skip	; F4A81F  jr NZ,0xf4a827
	calr	CycleRecord_CountCycleRangeBeats	; F4A821  calr 0xf4a88a
	calr	CycleRecord_AppendBeatMarks	; F4A824  calr 0xf4a90a
CycleRecord_FillTakeChain2WithBeatMarks_Skip:
	call	T_SeqTrackCursors_RestoreSaved	; F4A827  call 0xf40b64
	ret	; F4A82B  ret

; --------------------------------------------------------------------------
; CycleRecord_AllocTakeChain2
; Called from: in-module: 0xF4A817 0xF4A9A3 0xF4AA8C
; Touches: (0x0D4A) (0x36D6) (0x36FC)  |  0x000005 0x60347E 0x6034A0
; Calls:   T_BStore_AllocBlock_B_Veneer T_BStore_BlockAddrFromHL CycleRecord_AbortMemoryFull
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A82C is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_AllocTakeChain2: Starts take chain 2: with a free block allocates one (T_BStore_AllocBlock_B_Veneer),
;   (0x36FC) := it, in use, prev 0, next 0xFFFF, 0x82 end tag at offset 5, and points record track (0x36D6)'s end
;   cursor (0x60347E[t], 0x6034A0[t] = 5) at it; no free block -> CycleRecord_AbortMemoryFull. The (0x36FC) twin of
;   CycleRecord_AllocRecordChain. Basis: callers + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
CycleRecord_AllocTakeChain2:
	ld	(BStore_ErrorCode:16), 0	; F4A82C  ld (0x0d4a),0x00
	cpw	(BStore_FreeCount:24), 0x0000	; F4A831  cp (0x6034ba),0x0000
	jr	z, CycleRecord_AllocTakeChain2_Skip	; F4A838  jr Z,0xf4a886
	call	T_BStore_AllocBlock_B_Veneer	; F4A83A  call 0xf40c88
	ld	(14076:16), ix	; F4A83E  ld (0x36fc),IX
	ld	hl, ix	; F4A842  ld HL,IX
	call	T_BStore_BlockAddrFromHL	; F4A844  call 0xf40c84
	or	(xhl), 0x80	; F4A848  or (XHL),0x80
	ldw	(xhl+1), 0x0000	; F4A84B  ld (XHL+0x01),0x0000
	ldw	(xhl+3), 0xffff	; F4A850  ld (XHL+0x03),0xffff
	add	xhl, 5	; F4A855  add XHL,0x00000005
	ld	(xhl), 130	; F4A85B  ld (XHL),0x82
	ld	xix, 6304894	; F4A85E  ld XIX,0x0060347e
	xor	xwa, xwa	; F4A863  xor XWA,XWA
	ld	a, (14038:16)	; F4A865  ld A,(0x36d6)
	sll	xwa, 1	; F4A869  sll 0x01,XWA
	add	xix, xwa	; F4A86C  add XIX,XWA
	ld	hl, (14076:16)	; F4A86E  ld HL,(0x36fc)
	ld	(xix), hl	; F4A872  ld (XIX),HL
	ld	xix, 6304928	; F4A874  ld XIX,0x006034a0
	xor	xwa, xwa	; F4A879  xor XWA,XWA
	ld	a, (14038:16)	; F4A87B  ld A,(0x36d6)
	add	xix, xwa	; F4A87F  add XIX,XWA
	ld	(xix), 5	; F4A881  ld (XIX),0x05
	jr	CycleRecord_AllocTakeChain2_Return	; F4A884  jr T,0xf4a889
CycleRecord_AllocTakeChain2_Skip:
	calr	CycleRecord_AbortMemoryFull	; F4A886  calr 0xf4a7fe
CycleRecord_AllocTakeChain2_Return:
	ret	; F4A889  ret

; --------------------------------------------------------------------------
; CycleRecord_CountCycleRangeBeats
; Called from: in-module: 0xF4A821 0xF4A9AD
; Touches: (0x0C8A) (0x0D1D)
; Calls:   T_SeqMasterTrack_UpdateActive CycleRecord_CountCycleRangeBeatsFromBeatsPerBar CycleRecord_CountCycleRangeBeatsFromTimeSigs
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A88A is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CountCycleRangeBeats: (0x36F2) := the beats in measures (0x3622)..(0x3624): after
;   SeqMasterTrack_UpdateActive, with MASTER off ((0x0C8A) bit 2 clear) ((0x3624) + 1 - (0x3622)) x
;   TransportA_BeatsPerBar (CycleRecord_CountCycleRangeBeatsFromBeatsPerBar); with MASTER on, (0x0D1D) := W and CycleRecord_CountCycleRangeBeatsFromTimeSigs takes the time-signature beat
;   count before measure (0x3624)+1 minus that before (0x3622) (CycleRecord_BeatsBeforeMeasureFromTimeSigs). Basis: callers + caller header + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
CycleRecord_CountCycleRangeBeats:
	call	T_SeqMasterTrack_UpdateActive	; F4A88A  call 0xf40aa8
	bit	2, (0x0c8a:16)	; F4A88E  bit 2,(0x0c8a)
	jr	nz, CycleRecord_CountCycleRangeBeats_Skip	; F4A892  jr NZ,0xf4a899
	calr	CycleRecord_CountCycleRangeBeatsFromBeatsPerBar	; F4A894  calr 0xf4a8f0
	jr	CycleRecord_CountCycleRangeBeats_Return	; F4A897  jr T,0xf4a8a0
CycleRecord_CountCycleRangeBeats_Skip:
	ld	(3357:16), w	; F4A899  ld (0x0d1d),W
	calr	CycleRecord_CountCycleRangeBeatsFromTimeSigs	; F4A89D  calr 0xf4a8a1
CycleRecord_CountCycleRangeBeats_Return:
	ret	; F4A8A0  ret

; --------------------------------------------------------------------------
; CycleRecord_CountCycleRangeBeatsFromTimeSigs
; Called from: in-module: 0xF4A89D
; Touches: (0x0C90) (0x345C) (0x345E) (0x3622) (0x3624) (0x36F2)
; Calls:   CycleRecord_BeatsBeforeMeasureFromTimeSigs
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A8A1 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CountCycleRangeBeatsFromTimeSigs: (0x36F2) := beats before measure (0x3624)+1 minus beats before measure
;   (0x3622), each summed from the master track's time-signature records by CycleRecord_BeatsBeforeMeasureFromTimeSigs (chain (0x0D1D)); BStore cursor
;   kept. The MASTER-on arm of CycleRecord_CountCycleRangeBeats. Basis: caller + caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_a8.json)
CycleRecord_CountCycleRangeBeatsFromTimeSigs:
	pushw	(BStore_CursorBlock:16)	; F4A8A1  pushw (0x345c)
	pushw	(BStore_CursorOffset:16)	; F4A8A5  pushw (0x345e)
	ld	bc, (13860:16)	; F4A8A9  ld BC,(0x3624)
	inc	1, bc	; F4A8AD  inc 1,BC
	ld	(3216:16), bc	; F4A8AF  ld (0x0c90),BC
	ld	a, w	; F4A8B3  ld A,W
	pushw	wa	; F4A8B5  push WA
	calr	CycleRecord_BeatsBeforeMeasureFromTimeSigs	; F4A8B6  calr 0xf4b771
	popw	wa	; F4A8B9  pop WA
	popw	(BStore_CursorOffset:16)	; F4A8BA  popw (0x345e)
	popw	(BStore_CursorBlock:16)	; F4A8BE  popw (0x345c)
	ld	(14066:16), ix	; F4A8C2  ld (0x36f2),IX
	pushw	(BStore_CursorBlock:16)	; F4A8C6  pushw (0x345c)
	pushw	(BStore_CursorOffset:16)	; F4A8CA  pushw (0x345e)
	ld	bc, (13858:16)	; F4A8CE  ld BC,(0x3622)
	ld	(3216:16), bc	; F4A8D2  ld (0x0c90),BC
	ld	a, w	; F4A8D6  ld A,W
	pushw	wa	; F4A8D8  push WA
	calr	CycleRecord_BeatsBeforeMeasureFromTimeSigs	; F4A8D9  calr 0xf4b771
	popw	wa	; F4A8DC  pop WA
	popw	(BStore_CursorOffset:16)	; F4A8DD  popw (0x345e)
	popw	(BStore_CursorBlock:16)	; F4A8E1  popw (0x345c)
	ld	wa, (14066:16)	; F4A8E5  ld WA,(0x36f2)
	sub	wa, ix	; F4A8E9  sub WA,IX
	ld	(14066:16), wa	; F4A8EB  ld (0x36f2),WA
	ret	; F4A8EF  ret

; --------------------------------------------------------------------------
; CycleRecord_CountCycleRangeBeatsFromBeatsPerBar
; Called from: in-module: 0xF4A894
; Touches: (0x3622) (0x3624) (0x36F2)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A8F0 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CountCycleRangeBeatsFromBeatsPerBar: (0x36F2) := ((0x3624) + 1 - (0x3622)) x TransportA_BeatsPerBar, the
;   cycle range's beats at one fixed meter. The MASTER-off arm of CycleRecord_CountCycleRangeBeats. Basis: caller +
;   caller header + body. (notes/naming-pilot-2026-10-06/proposals_wave8_a8.json)
CycleRecord_CountCycleRangeBeatsFromBeatsPerBar:
	xor	xwa, xwa	; F4A8F0  xor XWA,XWA
	ld	wa, (13860:16)	; F4A8F2  ld WA,(0x3624)
	inc	1, wa	; F4A8F6  inc 1,WA
	sub	wa, (0x3622:16)	; F4A8F8  sub WA,(0x3622)
	xor	bc, bc	; F4A8FC  xor BC,BC
	ld	c, (TransportA_BeatsPerBar:24)	; F4A8FE  ld C,(0x605000)
	mul	xwa, bc	; F4A903  mul XWA,BC
	ld	(14066:16), wa	; F4A905  ld (0x36f2),WA
	ret	; F4A909  ret

; --------------------------------------------------------------------------
; CycleRecord_AppendBeatMarks
; Called from: in-module: 0xF4A824 0xF4A9CB 0xF4AFA3 0xF4B203
; Touches: (0x36F2)
; Calls:   CycleRecord_AppendBeatMark
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A90A is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_AppendBeatMarks: Appends (0x36F2) 0x81 beat marks at record track (0x36D6)'s end cursor, one per
;   CycleRecord_AppendBeatMark, counting (0x36F2) down to 0. The fill / pad step of CycleRecord_FillTakeChain2WithBeatMarks,
;   CycleRecord_CopyPaddedRangeToTakeChain2 and CycleRecord_PadTrackPastCycleEnd, which set (0x36F2) to the beats
;   missing. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
CycleRecord_AppendBeatMarks:
	cpw	(0x36f2:16), 0x0000	; F4A90A  cp (0x36f2),0x0000
	jr	nz, CycleRecord_AppendBeatMarks_Skip	; F4A910  jr NZ,0xf4a914
	jr	CycleRecord_AppendBeatMarks_Return	; F4A912  jr T,0xf4a91d
CycleRecord_AppendBeatMarks_Skip:
	calr	CycleRecord_AppendBeatMark	; F4A914  calr 0xf4a91e
	decw	1, (14066:16)	; F4A917  decw 1,(0x36f2)
	jr	CycleRecord_AppendBeatMarks	; F4A91B  jr T,0xf4a90a
CycleRecord_AppendBeatMarks_Return:
	ret	; F4A91D  ret

; --------------------------------------------------------------------------
; CycleRecord_AppendBeatMark
; Called from: in-module: 0xF4A914 0xF4B1E0
; Touches: (0x0D4A) (0x36D6)  |  0x0036E0
; Calls:   CycleRecord_MoveSongPositionToTrackEnd T_BStore_AppendBytes_Veneer
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A91E is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_AppendBeatMark: Inserts one 0x81 beat mark at record track (0x36D6)'s end cursor: CycleRecord_MoveSongPositionToTrackEnd copies the
;   end cursor (0x60347E/0x6034A0[t]) into the live cursor (0x3460/0x3482[t]), then T_BStore_AppendBytes_Veneer with A
;   = track + 1, W = 1, XIY = 0x36E0 holding 0x81. The per-beat body of CycleRecord_AppendBeatMarks; CycleRecord_PadTrackPastCycleEnd
;   also writes the first mark of a new track with it. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_w.json)
CycleRecord_AppendBeatMark:
	calr	CycleRecord_MoveSongPositionToTrackEnd	; F4A91E  calr 0xf4a93c
	ld	xiy, 14048	; F4A921  ld XIY,0x000036e0
	ld	(xiy), 129	; F4A926  ld (XIY),0x81
	ld	a, (14038:16)	; F4A929  ld A,(0x36d6)
	add	a, 1	; F4A92D  add A,0x01
	ld	w, 1:opc	; F4A930  ld W,0x01
	ld	(BStore_ErrorCode:16), 0	; F4A932  ld (0x0d4a),0x00
	call	T_BStore_AppendBytes_Veneer	; F4A937  call 0xf42894
	ret	; F4A93B  ret

; --------------------------------------------------------------------------
; CycleRecord_MoveSongPositionToTrackEnd
; Called from: in-module: 0xF4A91E 0xF4AF28
; Touches: (0x345E) (0x36D6)  |  0x003460 0x003482 0x60347E 0x6034A0
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A93C is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_MoveSongPositionToTrackEnd: Record track (0x36D6)'s song position := its end cursor: 0x3460[t] :=
;   0x60347E[t] (block), 0x3482[t] := 0x6034A0[t] (offset). CycleRecord_AppendBeatMark runs it before inserting at the
;   position; the T_F40BE8 append (sub_F4AF08) likewise before sub_F4AEEE appends. Basis: caller + caller header +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave8_a8.json)
CycleRecord_MoveSongPositionToTrackEnd:
	xor	hl, hl	; F4A93C  xor HL,HL
	ld	l, (14038:16)	; F4A93E  ld L,(0x36d6)
	sll	l, 1	; F4A942  sll 0x01,L
	ld	xiy, 6304894	; F4A945  ld XIY,0x0060347e
	ld	xix, 13408	; F4A94A  ld XIX,0x00003460
	ld	wa, (xiy+hl)	; F4A94F  ld WA,(XIY+HL)
	ld	(xix+hl), wa	; F4A954  ld (XIX+HL),WA
	ld	l, (14038:16)	; F4A959  ld L,(0x36d6)
	ld	wa, (BStore_CursorOffset:16)	; F4A95D  ld WA,(0x345e)
	ld	xiy, 6304928	; F4A961  ld XIY,0x006034a0
	ld	xix, 13442	; F4A966  ld XIX,0x00003482
	ld	a, (xiy+hl)	; F4A96B  ld A,(XIY+HL)
	ld	(xix+hl), a	; F4A970  ld (XIX+HL),A
	ret	; F4A975  ret

; --------------------------------------------------------------------------
; CycleRecord_CopyPaddedRangeToTakeChain2
; Called from: in-module: 0xF4A7CC
; Touches: (0x0D4A) (0x36D6) (0x36F2) (0x3732) (0x3734)  |  0x60347E
;          0x6034A0
; Calls:   T_SeqTrackCursors_Save CycleRecord_AllocTakeChain2 CycleRecord_CountCycleRangeBeats CycleRecord_CopyFromCycleStartToTakeChain2 CycleRecord_CountTakeChain2BeatMarks CycleRecord_AppendBeatMarks
;          T_SeqTrackCursors_RestoreSaved
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A976 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CopyPaddedRangeToTakeChain2: For a record track that ends before the cycle end: keeps its end cursor in
;   (0x3732)/(0x3734), starts take chain 2 (CycleRecord_AllocTakeChain2), copies from the cycle start measure to the track's end into
;   it (CycleRecord_CopyFromCycleStartToTakeChain2), counts the 0x81 beat marks copied (CycleRecord_CountTakeChain2BeatMarks) and appends the missing ones up to the range's
;   beat count (CycleRecord_CountCycleRangeBeats, CycleRecord_AppendBeatMarks). CycleRecord_CopyCycleRangeToTakeChain2's 'ends early, padded' arm. Basis:
;   caller + body. (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
CycleRecord_CopyPaddedRangeToTakeChain2:
	call	T_SeqTrackCursors_Save	; F4A976  call 0xf40b68
	xor	hl, hl	; F4A97A  xor HL,HL
	ld	l, (14038:16)	; F4A97C  ld L,(0x36d6)
	sll	l, 1	; F4A980  sll 0x01,L
	ld	xix, 6304894	; F4A983  ld XIX,0x0060347e
	ld	wa, (xix+hl)	; F4A988  ld WA,(XIX+HL)
	ld	(14130:16), wa	; F4A98D  ld (0x3732),WA
	ld	l, (14038:16)	; F4A991  ld L,(0x36d6)
	ld	xix, 6304928	; F4A995  ld XIX,0x006034a0
	ld	a, (xix+hl)	; F4A99A  ld A,(XIX+HL)
	ld	(14132:16), a	; F4A99F  ld (0x3734),A
	calr	CycleRecord_AllocTakeChain2	; F4A9A3  calr 0xf4a82c
	cp	(BStore_ErrorCode:16), 0x00	; F4A9A6  cp (0x0d4a),0x00
	jr	nz, CycleRecord_CopyPaddedRangeToTakeChain2_Skip	; F4A9AB  jr NZ,0xf4a9ce
	calr	CycleRecord_CountCycleRangeBeats	; F4A9AD  calr 0xf4a88a
	calr	CycleRecord_CopyFromCycleStartToTakeChain2	; F4A9B0  calr 0xf4a9d3
	cp	(BStore_ErrorCode:16), 0x00	; F4A9B3  cp (0x0d4a),0x00
	jr	nz, CycleRecord_CopyPaddedRangeToTakeChain2_Skip	; F4A9B8  jr NZ,0xf4a9ce
	ld	wa, (14066:16)	; F4A9BA  ld WA,(0x36f2)
	pushw	wa	; F4A9BE  push WA
	calr	CycleRecord_CountTakeChain2BeatMarks	; F4A9BF  calr 0xf4aa59
	popw	wa	; F4A9C2  pop WA
	sub	wa, (0x36f2:16)	; F4A9C3  sub WA,(0x36f2)
	ld	(14066:16), wa	; F4A9C7  ld (0x36f2),WA
	calr	CycleRecord_AppendBeatMarks	; F4A9CB  calr 0xf4a90a
CycleRecord_CopyPaddedRangeToTakeChain2_Skip:
	call	T_SeqTrackCursors_RestoreSaved	; F4A9CE  call 0xf40b64
	ret	; F4A9D2  ret

; --------------------------------------------------------------------------
; CycleRecord_CopyFromCycleStartToTakeChain2
; Called from: in-module: 0xF4A9B0
; Touches: (0x0C57) (0x0C5D) (0x0C61) (0x0C67) (0x0C6B) (0x0C90) (0x0D4A)
;          (0x345C) (0x345E) (0x3622) +4 more  |  0x60347E 0x6034A0
; Calls:   T_SeqMasterTrack_UpdateActive T_BStore_SeekChainToMeasure CycleRecord_CopyRangeIntoGrowingChain CycleRecord_SetEndCursorAtTakeChain2EndTag sub_F4AB42
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4A9D3 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CopyFromCycleStartToTakeChain2: Seeks record track (0x36D6) to the cycle start measure (0x3622) and
;   copies from there up to its saved end cursor ((0x3732) block / (0x3734) offset) into take chain 2 from offset 5
;   (CycleRecord_CopyRangeIntoGrowingChain; failure -> BStore_ErrorCode 0xFF), then CycleRecord_SetEndCursorAtTakeChain2EndTag puts the track's end cursor on take chain 2's
;   0x82. The copy step of CycleRecord_CopyPaddedRangeToTakeChain2. Basis: caller + caller header + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
CycleRecord_CopyFromCycleStartToTakeChain2:
	ld	(BStore_ErrorCode:16), 0	; F4A9D3  ld (0x0d4a),0x00
	ld	wa, (13858:16)	; F4A9D8  ld WA,(0x3622)
	ld	(3216:16), wa	; F4A9DC  ld (0x0c90),WA
	call	T_SeqMasterTrack_UpdateActive	; F4A9E0  call 0xf40aa8
	ld	a, (14038:16)	; F4A9E4  ld A,(0x36d6)
	inc	1, a	; F4A9E8  inc 1,A
	call	T_BStore_SeekChainToMeasure	; F4A9EA  call 0xf40c5c
	ld	wa, (BStore_CursorBlock:16)	; F4A9EE  ld WA,(0x345c)
	ld	(3169:16), wa	; F4A9F2  ld (0x0c61),WA
	ld	(3175:16), iy	; F4A9F6  ld (0x0c67),IY
	ld	wa, (14076:16)	; F4A9FA  ld WA,(0x36fc)
	ld	(3159:16), wa	; F4A9FE  ld (0x0c57),WA
	ldw	(3165:16), 5	; F4AA02  ld (0x0c5d),0x0005
	ld	a, (14132:16)	; F4AA08  ld A,(0x3734)
	xor	w, w	; F4AA0C  xor W,W
	ld	(3179:16), wa	; F4AA0E  ld (0x0c6b),WA
	ld	de, (14130:16)	; F4AA12  ld DE,(0x3732)
	call	CycleRecord_CopyRangeIntoGrowingChain	; F4AA16  call 0xf4b462
	cp	(BStore_ErrorCode:16), 0x00	; F4AA1A  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyFromCycleStartToTakeChain2_Skip	; F4AA1F  jr Z,0xf4aa26
	ld	(BStore_ErrorCode:16), 255	; F4AA21  ld (0x0d4a),0xff
CycleRecord_CopyFromCycleStartToTakeChain2_Skip:
	calr	CycleRecord_SetEndCursorAtTakeChain2EndTag	; F4AA26  calr 0xf4adcc
	ret	; F4AA29  ret
	ld	xix, 6304894	; F4AA2A  ld XIX,0x0060347e
	xor	xwa, xwa	; F4AA2F  xor XWA,XWA
	ld	a, (14038:16)	; F4AA31  ld A,(0x36d6)
	sll	xwa, 1	; F4AA35  sll 0x01,XWA
	add	xix, xwa	; F4AA38  add XIX,XWA
	ld	wa, (xix)	; F4AA3A  ld WA,(XIX)
	ld	(BStore_CursorBlock:16), wa	; F4AA3C  ld (0x345c),WA
	ld	xix, 6304928	; F4AA40  ld XIX,0x006034a0
	xor	xwa, xwa	; F4AA45  xor XWA,XWA
	ld	a, (14038:16)	; F4AA47  ld A,(0x36d6)
	add	xix, xwa	; F4AA4B  add XIX,XWA
	ld	a, (xix)	; F4AA4D  ld A,(XIX)
	xor	w, w	; F4AA4F  xor W,W
	ld	(BStore_CursorOffset:16), wa	; F4AA51  ld (0x345e),WA
	calr	sub_F4AB42	; F4AA55  calr 0xf4ab42
	ret	; F4AA58  ret

; --------------------------------------------------------------------------
; CycleRecord_CountTakeChain2BeatMarks
; Called from: in-module: 0xF4A9BF
; Touches: (0x345C) (0x345E) (0x36F2) (0x36FC)
; Calls:   T_BStore_ReadCursorByte CycleRecord_StepCursorOneEvent
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4AA59 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CountTakeChain2BeatMarks: (0x36F2) := the number of 0x81 beat marks in take chain 2 (0x36FC), walking it
;   event by event (CycleRecord_StepCursorOneEvent) from offset 5 to its 0x82 end tag. CycleRecord_CopyPaddedRangeToTakeChain2 subtracts
;   it from the range's beat count to get the marks still to append. Basis: caller + caller header + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
CycleRecord_CountTakeChain2BeatMarks:
	ld	wa, (14076:16)	; F4AA59  ld WA,(0x36fc)
	ld	(BStore_CursorBlock:16), wa	; F4AA5D  ld (0x345c),WA
	ldw	(BStore_CursorOffset:16), 5	; F4AA61  ld (0x345e),0x0005
	ldw	(14066:16), 0	; F4AA67  ld (0x36f2),0x0000
CycleRecord_CountTakeChain2BeatMarks_Join:
	call	T_BStore_ReadCursorByte	; F4AA6D  call 0xf40c54
	cp	a, 129	; F4AA71  cp A,0x81
	jr	z, CycleRecord_CountTakeChain2BeatMarks_Skip	; F4AA74  jr Z,0xf4aa81
	cp	a, 130	; F4AA76  cp A,0x82
	jr	z, CycleRecord_CountTakeChain2BeatMarks_Return	; F4AA79  jr Z,0xf4aa87
CycleRecord_CountTakeChain2BeatMarks_Join2:
	call	CycleRecord_StepCursorOneEvent	; F4AA7B  call 0xf4aedd
	jr	CycleRecord_CountTakeChain2BeatMarks_Join	; F4AA7F  jr T,0xf4aa6d
CycleRecord_CountTakeChain2BeatMarks_Skip:
	incw	1, (14066:16)	; F4AA81  incw 1,(0x36f2)
	jr	CycleRecord_CountTakeChain2BeatMarks_Join2	; F4AA85  jr T,0xf4aa7b
CycleRecord_CountTakeChain2BeatMarks_Return:
	ret	; F4AA87  ret

; --------------------------------------------------------------------------
; CycleRecord_CopyRangeToTakeChain2
; Called from: in-module: 0xF4A7F0
; Touches: (0x0C57) (0x0C5D) (0x0C61) (0x0C67) (0x0C6B) (0x0D4A) (0x36D8)
;          (0x36DA) (0x36DC) (0x36DE) +1 more
; Calls:   T_SeqTrackCursors_Save CycleRecord_AllocTakeChain2 CycleRecord_CopyRangeIntoGrowingChain CycleRecord_TerminateTakeChain2AtCopyEnd T_SeqTrackCursors_RestoreSaved
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4AA88 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CopyRangeToTakeChain2: The copy step of CycleRecord_CopyCycleRangeToTakeChain2 once both bounds were
;   found: starts take chain 2 (CycleRecord_AllocTakeChain2), copies record track (0x36D6)'s bytes from the cycle-start position
;   (0x36D8/0x36DA) to the cycle-end position (0x36DC/0x36DE) into it from offset 5 (CycleRecord_CopyRangeIntoGrowingChain), then sets the end
;   cursor at the copy's end and writes the 0x82 end tag (CycleRecord_TerminateTakeChain2AtCopyEnd); failure -> BStore_ErrorCode 0xFF. Basis: caller
;   + body. (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
CycleRecord_CopyRangeToTakeChain2:
	call	T_SeqTrackCursors_Save	; F4AA88  call 0xf40b68
	calr	CycleRecord_AllocTakeChain2	; F4AA8C  calr 0xf4a82c
	cp	(BStore_ErrorCode:16), 0x00	; F4AA8F  cp (0x0d4a),0x00
	jr	nz, CycleRecord_CopyRangeToTakeChain2_Skip	; F4AA94  jr NZ,0xf4aad0
	ld	wa, (14076:16)	; F4AA96  ld WA,(0x36fc)
	ld	(3159:16), wa	; F4AA9A  ld (0x0c57),WA
	ldw	(3165:16), 5	; F4AA9E  ld (0x0c5d),0x0005
	ld	wa, (14040:16)	; F4AAA4  ld WA,(0x36d8)
	ld	(3169:16), wa	; F4AAA8  ld (0x0c61),WA
	ld	wa, (14042:16)	; F4AAAC  ld WA,(0x36da)
	ld	(3175:16), wa	; F4AAB0  ld (0x0c67),WA
	ld	de, (14044:16)	; F4AAB4  ld DE,(0x36dc)
	ld	wa, (14046:16)	; F4AAB8  ld WA,(0x36de)
	ld	(3179:16), wa	; F4AABC  ld (0x0c6b),WA
	call	CycleRecord_CopyRangeIntoGrowingChain	; F4AAC0  call 0xf4b462
	cp	(BStore_ErrorCode:16), 0x00	; F4AAC4  cp (0x0d4a),0x00
	jr	nz, CycleRecord_CopyRangeToTakeChain2_Skip	; F4AAC9  jr NZ,0xf4aad0
	calr	CycleRecord_TerminateTakeChain2AtCopyEnd	; F4AACB  calr 0xf4aada
	jr	CycleRecord_CopyRangeToTakeChain2_Join	; F4AACE  jr T,0xf4aad5
CycleRecord_CopyRangeToTakeChain2_Skip:
	ld	(BStore_ErrorCode:16), 255	; F4AAD0  ld (0x0d4a),0xff
CycleRecord_CopyRangeToTakeChain2_Join:
	call	T_SeqTrackCursors_RestoreSaved	; F4AAD5  call 0xf40b64
	ret	; F4AAD9  ret

; --------------------------------------------------------------------------
; CycleRecord_TerminateTakeChain2AtCopyEnd
; Called from: in-module: 0xF4AACB
; Touches: (0x0C57) (0x345C) (0x345E) (0x36D6)  |  0x60347E 0x6034A0
; Calls:   T_BStore_WriteCursorByte
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4AADA is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_TerminateTakeChain2AtCopyEnd: After CycleRecord_CopyRangeToTakeChain2's copy: record track (0x36D6)'s
;   end cursor := the copy's destination end (block (0x0C57), offset IX), the block-store cursor := the same, and an
;   0x82 end tag is written there (T_BStore_WriteCursorByte). Basis: caller + caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_w.json)
CycleRecord_TerminateTakeChain2AtCopyEnd:
	xor	hl, hl	; F4AADA  xor HL,HL
	ld	l, (14038:16)	; F4AADC  ld L,(0x36d6)
	ld	wa, ix	; F4AAE0  ld WA,IX
	ld	xde, 6304928	; F4AAE2  ld XDE,0x006034a0
	ld	(xde+hl), a	; F4AAE7  ld (XDE+HL),A
	ld	(BStore_CursorOffset:16), wa	; F4AAEC  ld (0x345e),WA
	sla	hl, 1	; F4AAF0  sla 0x01,HL
	ld	wa, (3159:16)	; F4AAF3  ld WA,(0x0c57)
	ld	xde, 6304894	; F4AAF7  ld XDE,0x0060347e
	ld	(xde+hl), wa	; F4AAFC  ld (XDE+HL),WA
	ld	(BStore_CursorBlock:16), wa	; F4AB01  ld (0x345c),WA
	ld	a, 130:opc	; F4AB05  ld A,0x82
	call	T_BStore_WriteCursorByte	; F4AB07  call 0xf40c58
	ret	; F4AB0B  ret

; --------------------------------------------------------------------------
; CycleRecord_SetEndCursorAtCopiedEndTag
; Called from: in-module: 0xF4B33E
; Touches: (0x0C57) (0x345C) (0x345E) (0x36D6)  |  0x60347E 0x6034A0
; Calls:   T_BStore_StepCursorBackToLeadByte
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4AB0C is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_SetEndCursorAtCopiedEndTag: After CycleRecord_AppendUnplayedRest's copy: block-store cursor := the
;   copy's destination end (block (0x0C57), offset IX), stepped back to its lead byte
;   (T_BStore_StepCursorBackToLeadByte, i.e. the copied 0x82), and that position becomes record track (0x36D6)'s end
;   cursor (0x6034A0[t] offset, 0x60347E[t] block). Basis: caller + caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_w.json)
CycleRecord_SetEndCursorAtCopiedEndTag:
	ld	(BStore_CursorOffset:16), ix	; F4AB0C  ld (0x345e),IX
	ld	wa, (3159:16)	; F4AB10  ld WA,(0x0c57)
	ld	(BStore_CursorBlock:16), wa	; F4AB14  ld (0x345c),WA
	call	T_BStore_StepCursorBackToLeadByte	; F4AB18  call 0xf40b6c
	xor	hl, hl	; F4AB1C  xor HL,HL
	ld	l, (14038:16)	; F4AB1E  ld L,(0x36d6)
	ld	xde, 6304928	; F4AB22  ld XDE,0x006034a0
	ld	wa, (BStore_CursorOffset:16)	; F4AB27  ld WA,(0x345e)
	ld	(xde+hl), a	; F4AB2B  ld (XDE+HL),A
	sla	hl, 1	; F4AB30  sla 0x01,HL
	ld	xde, 6304894	; F4AB33  ld XDE,0x0060347e
	ld	wa, (BStore_CursorBlock:16)	; F4AB38  ld WA,(0x345c)
	ld	(xde+hl), wa	; F4AB3C  ld (XDE+HL),WA
	ret	; F4AB41  ret

; --------------------------------------------------------------------------
; sub_F4AB42
; Called from: in-module: 0xF4AA55
; Touches: (0x0D4A) (0x36D6)  |  0x0036E0
; Calls:   sub_F4AB60 T_BStore_AppendBytes_Veneer
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4AB42 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4AB42:
	calr	sub_F4AB60	; F4AB42  calr 0xf4ab60
	ld	xiy, 14048	; F4AB45  ld XIY,0x000036e0
	ld	(xiy), 130	; F4AB4A  ld (XIY),0x82
	ld	a, (14038:16)	; F4AB4D  ld A,(0x36d6)
	add	a, 1	; F4AB51  add A,0x01
	ld	w, 1:opc	; F4AB54  ld W,0x01
	ld	(BStore_ErrorCode:16), 0	; F4AB56  ld (0x0d4a),0x00
	call	T_BStore_AppendBytes_Veneer	; F4AB5B  call 0xf42894
	ret	; F4AB5F  ret

; --------------------------------------------------------------------------
; sub_F4AB60
; Called from: in-module: 0xF4AB42 0xF4AE4F 0xF4AE79 0xF4AE87 0xF4AED9
; Touches: (0x345C) (0x345E) (0x36D6)  |  0x003460 0x003482
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4AB60 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4AB60:
	xor	hl, hl	; F4AB60  xor HL,HL
	ld	l, (14038:16)	; F4AB62  ld L,(0x36d6)
	sll	l, 1	; F4AB66  sll 0x01,L
	ld	wa, (BStore_CursorBlock:16)	; F4AB69  ld WA,(0x345c)
	ld	xix, 13408	; F4AB6D  ld XIX,0x00003460
	ld	(xix+hl), wa	; F4AB72  ld (XIX+HL),WA
	ld	l, (14038:16)	; F4AB77  ld L,(0x36d6)
	ld	wa, (BStore_CursorOffset:16)	; F4AB7B  ld WA,(0x345e)
	ld	xix, 13442	; F4AB7F  ld XIX,0x00003482
	ld	(xix+hl), a	; F4AB84  ld (XIX+HL),A
	ret	; F4AB89  ret

; --------------------------------------------------------------------------
; CycleRecord_AllocRecordChain
; Called from: in-module: 0xF4A64A 0xF4AF94 0xF4AFC3 0xF4B074 0xF4B100
; Touches: (0x0D4A) (0x36D6) (0x36FA)  |  0x000005 0x60347E 0x6034A0
; Calls:   T_BStore_AllocBlock_B_Veneer T_BStore_BlockAddrFromHL CycleRecord_AbortMemoryFull
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4AB8A is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_AllocRecordChain: Allocates one block as the cycle-record chain (0x36FA): in use, prev 0, next 0xFFFF,
;   an 0x82 end tag at offset 5, and makes it record track (0x36D6)'s end cursor (0x60347E[t], 0x6034A0[t] = 5); no
;   free block -> CycleRecord_AbortMemoryFull (memory full). The chain CycleRecord_FreeRecordChain frees; CycleRecord_RestartPass step.
;   Basis: caller + body + undo twin. (notes/naming-pilot-2026-10-06/proposals_wave5_p.json)
CycleRecord_AllocRecordChain:
	ld	(BStore_ErrorCode:16), 0	; F4AB8A  ld (0x0d4a),0x00
	cpw	(BStore_FreeCount:24), 0x0000	; F4AB8F  cp (0x6034ba),0x0000
	jr	z, CycleRecord_AllocRecordChain_Skip	; F4AB96  jr Z,0xf4abe4
	call	T_BStore_AllocBlock_B_Veneer	; F4AB98  call 0xf40c88
	ld	(14074:16), ix	; F4AB9C  ld (0x36fa),IX
	ld	hl, ix	; F4ABA0  ld HL,IX
	call	T_BStore_BlockAddrFromHL	; F4ABA2  call 0xf40c84
	or	(xhl), 0x80	; F4ABA6  or (XHL),0x80
	ldw	(xhl+1), 0x0000	; F4ABA9  ld (XHL+0x01),0x0000
	ldw	(xhl+3), 0xffff	; F4ABAE  ld (XHL+0x03),0xffff
	add	xhl, 5	; F4ABB3  add XHL,0x00000005
	ld	(xhl), 130	; F4ABB9  ld (XHL),0x82
	ld	xix, 6304894	; F4ABBC  ld XIX,0x0060347e
	xor	xwa, xwa	; F4ABC1  xor XWA,XWA
	ld	a, (14038:16)	; F4ABC3  ld A,(0x36d6)
	sll	xwa, 1	; F4ABC7  sll 0x01,XWA
	add	xix, xwa	; F4ABCA  add XIX,XWA
	ld	hl, (14074:16)	; F4ABCC  ld HL,(0x36fa)
	ld	(xix), hl	; F4ABD0  ld (XIX),HL
	ld	xix, 6304928	; F4ABD2  ld XIX,0x006034a0
	xor	xwa, xwa	; F4ABD7  xor XWA,XWA
	ld	a, (14038:16)	; F4ABD9  ld A,(0x36d6)
	add	xix, xwa	; F4ABDD  add XIX,XWA
	ld	(xix), 5	; F4ABDF  ld (XIX),0x05
	jr	CycleRecord_AllocRecordChain_Return	; F4ABE2  jr T,0xf4abe7
CycleRecord_AllocRecordChain_Skip:
	calr	CycleRecord_AbortMemoryFull	; F4ABE4  calr 0xf4a7fe
CycleRecord_AllocRecordChain_Return:
	ret	; F4ABE7  ret

; --------------------------------------------------------------------------
; CycleRecord_WriteStagedEventToRecordTrack
; Called from: in-module: 0xF49CE2 0xF49CFC
; Touches: (0x3731)
; Calls:   sub_F4ABFC sub_F4AC81
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4ABE8 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_WriteStagedEventToRecordTrack: Writes the event staged at 0x36E8 ((0x36F0) bytes) into cycle record
;   track (0x36D6): sub_F4AE15 steps back from the track's end cursor by beat marks and ticks against (0x3452) /
;   (0x36E9), sub_F4ACB1 opens a held-note slot for a 0x9n event, sub_F4AEEE runs BStore_AppendBytes, an error ->
;   CycleRecord_AbortMemoryFull. With (0x3731) bit 0 set and Seq_BeatTick > 0x14 (sub_F4ABFC) the walk starts at take
;   chain 2's 0x82 tag instead, and the track's end cursor is restored after. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_a11.json)
CycleRecord_WriteStagedEventToRecordTrack:
	bit	0, (0x3731:16)	; F4ABE8  bit 0,(0x3731)
	jr	z, CycleRecord_WriteStagedEventToRecordTrack_Skip	; F4ABEC  jr Z,0xf4abf8
	cp	(Seq_BeatTick:8), 0x14	; F4ABEE  cp (0x93),0x14
	jr	ule, CycleRecord_WriteStagedEventToRecordTrack_Skip	; F4ABF2  jr ULE,0xf4abf8
	calr	sub_F4ABFC	; F4ABF4  calr 0xf4abfc
	ret	; F4ABF7  ret
CycleRecord_WriteStagedEventToRecordTrack_Skip:
	calr	sub_F4AC81	; F4ABF8  calr 0xf4ac81
	ret	; F4ABFB  ret

; --------------------------------------------------------------------------
; sub_F4ABFC
; Called from: in-module: 0xF4ABF4
; Touches: (0x0D4A) (0x345C) (0x345E) (0x36D6) (0x3732) (0x3734)  |
;          0x60347E 0x6034A0
; Calls:   T_SeqTrackCursors_Save CycleRecord_SetEndCursorAtTakeChain2EndTag sub_F4AE15 sub_F4ACB1 sub_F4AEEE CycleRecord_AbortMemoryFull
;          T_SeqTrackCursors_RestoreSaved
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4ABFC is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4ABFC:
	call	T_SeqTrackCursors_Save	; F4ABFC  call 0xf40b68
	ld	wa, (BStore_CursorBlock:16)	; F4AC00  ld WA,(0x345c)
	ld	bc, (BStore_CursorOffset:16)	; F4AC04  ld BC,(0x345e)
	pushw	wa	; F4AC08  push WA
	pushw	bc	; F4AC09  push BC
	xor	hl, hl	; F4AC0A  xor HL,HL
	ld	l, (14038:16)	; F4AC0C  ld L,(0x36d6)
	sll	l, 1	; F4AC10  sll 0x01,L
	ld	xix, 6304894	; F4AC13  ld XIX,0x0060347e
	ld	wa, (xix+hl)	; F4AC18  ld WA,(XIX+HL)
	ld	(14130:16), wa	; F4AC1D  ld (0x3732),WA
	ld	l, (14038:16)	; F4AC21  ld L,(0x36d6)
	ld	xix, 6304928	; F4AC25  ld XIX,0x006034a0
	ld	a, (xix+hl)	; F4AC2A  ld A,(XIX+HL)
	ld	(14132:16), a	; F4AC2F  ld (0x3734),A
	calr	CycleRecord_SetEndCursorAtTakeChain2EndTag	; F4AC33  calr 0xf4adcc
	calr	sub_F4AE15	; F4AC36  calr 0xf4ae15
	calr	sub_F4ACB1	; F4AC39  calr 0xf4acb1
	calr	sub_F4AEEE	; F4AC3C  calr 0xf4aeee
	cp	(BStore_ErrorCode:16), 0x00	; F4AC3F  cp (0x0d4a),0x00
	jr	z, sub_F4ABFC_Skip	; F4AC44  jr Z,0xf4ac49
	calr	CycleRecord_AbortMemoryFull	; F4AC46  calr 0xf4a7fe
sub_F4ABFC_Skip:
	xor	hl, hl	; F4AC49  xor HL,HL
	ld	l, (14038:16)	; F4AC4B  ld L,(0x36d6)
	sll	l, 1	; F4AC4F  sll 0x01,L
	ld	xix, 6304894	; F4AC52  ld XIX,0x0060347e
	ld	wa, (14130:16)	; F4AC57  ld WA,(0x3732)
	ld	(xix+hl), wa	; F4AC5B  ld (XIX+HL),WA
	ld	l, (14038:16)	; F4AC60  ld L,(0x36d6)
	ld	xix, 6304928	; F4AC64  ld XIX,0x006034a0
	ld	a, (14132:16)	; F4AC69  ld A,(0x3734)
	ld	(xix+hl), a	; F4AC6D  ld (XIX+HL),A
	popw	bc	; F4AC72  pop BC
	popw	wa	; F4AC73  pop WA
	ld	(BStore_CursorBlock:16), wa	; F4AC74  ld (0x345c),WA
	ld	(BStore_CursorOffset:16), bc	; F4AC78  ld (0x345e),BC
	call	T_SeqTrackCursors_RestoreSaved	; F4AC7C  call 0xf40b64
	ret	; F4AC80  ret

; --------------------------------------------------------------------------
; sub_F4AC81
; Called from: in-module: 0xF4ABF8
; Touches: (0x0D4A) (0x345C) (0x345E)
; Calls:   T_SeqTrackCursors_Save sub_F4AE15 sub_F4ACB1 sub_F4AEEE CycleRecord_AbortMemoryFull T_SeqTrackCursors_RestoreSaved
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4AC81 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4AC81:
	call	T_SeqTrackCursors_Save	; F4AC81  call 0xf40b68
	ld	wa, (BStore_CursorBlock:16)	; F4AC85  ld WA,(0x345c)
	ld	bc, (BStore_CursorOffset:16)	; F4AC89  ld BC,(0x345e)
	pushw	wa	; F4AC8D  push WA
	pushw	bc	; F4AC8E  push BC
	calr	sub_F4AE15	; F4AC8F  calr 0xf4ae15
	calr	sub_F4ACB1	; F4AC92  calr 0xf4acb1
	calr	sub_F4AEEE	; F4AC95  calr 0xf4aeee
	cp	(BStore_ErrorCode:16), 0x00	; F4AC98  cp (0x0d4a),0x00
	jr	z, sub_F4AC81_Skip	; F4AC9D  jr Z,0xf4aca2
	calr	CycleRecord_AbortMemoryFull	; F4AC9F  calr 0xf4a7fe
sub_F4AC81_Skip:
	popw	bc	; F4ACA2  pop BC
	popw	wa	; F4ACA3  pop WA
	ld	(BStore_CursorBlock:16), wa	; F4ACA4  ld (0x345c),WA
	ld	(BStore_CursorOffset:16), bc	; F4ACA8  ld (0x345e),BC
	call	T_SeqTrackCursors_RestoreSaved	; F4ACAC  call 0xf40b64
	ret	; F4ACB0  ret

; --------------------------------------------------------------------------
; sub_F4ACB1
; Called from: in-module: 0xF4AC39 0xF4AC92
; Touches: (0x33DA) (0x33DB) (0x33DE) (0x33DF) (0x345C) (0x345E) (0x349F)
;          (0x36D6) (0x36E8) (0x36E9) +2 more  |  0x003014 0x003016 0x003460
;          0x003482
; Calls:   SeqRecord_HeldNoteSlotAddress T_BStore_StepCursorOneByte SeqRecord_LoadHeldNoteListHeadTail
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4ACB1 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4ACB1:
	ld	a, (14056:16)	; F4ACB1  ld A,(0x36e8)
	and	a, 240	; F4ACB5  and A,0xf0
	cp	a, 144	; F4ACB8  cp A,0x90
	jrl	nz, sub_F4ACB1_Return	; F4ACBB  jrl NZ,0xf4adc1
	xor	xix, xix	; F4ACBE  xor XIX,XIX
	ld	xix, 12308	; F4ACC0  ld XIX,0x00003014
	cp	(xix), 0xff	; F4ACC5  cp (XIX),0xff
	jrl	z, sub_F4ACB1_Return	; F4ACC8  jrl Z,0xf4adc1
	xor	hl, hl	; F4ACCB  xor HL,HL
	ld	l, (xix)	; F4ACCD  ld L,(XIX)
	ld	(13279:16), l	; F4ACCF  ld (0x33df),L
	calr	SeqRecord_HeldNoteSlotAddress	; F4ACD3  calr 0xf4a56c
	ld	a, (14058:16)	; F4ACD6  ld A,(0x36ea)
	ld	(xhl), a	; F4ACDA  ld (XHL),A
	ld	(xhl+1), 0	; F4ACDC  ld (XHL+0x01),0x00
	ld	a, (14057:16)	; F4ACE0  ld A,(0x36e9)
	ld	(xhl+2), a	; F4ACE4  ld (XHL+0x02),A
	push	xhl	; F4ACE7  push XHL
	xor	hl, hl	; F4ACE8  xor HL,HL
	ld	l, (14038:16)	; F4ACEA  ld L,(0x36d6)
	sll	l, 1	; F4ACEE  sll 0x01,L
	ld	xix, 13408	; F4ACF1  ld XIX,0x00003460
	ld	wa, (xix+hl)	; F4ACF6  ld WA,(XIX+HL)
	ld	(BStore_CursorBlock:16), wa	; F4ACFB  ld (0x345c),WA
	ld	l, (14038:16)	; F4ACFF  ld L,(0x36d6)
	ld	xix, 13442	; F4AD03  ld XIX,0x00003482
	xor	w, w	; F4AD08  xor W,W
	ld	a, (xix+hl)	; F4AD0A  ld A,(XIX+HL)
	ld	(BStore_CursorOffset:16), wa	; F4AD0F  ld (0x345e),WA
	call	T_BStore_StepCursorOneByte	; F4AD13  call 0xf40c50
	call	T_BStore_StepCursorOneByte	; F4AD17  call 0xf40c50
	pop	xhl	; F4AD1B  pop XHL
	ld	wa, (BStore_CursorBlock:16)	; F4AD1C  ld WA,(0x345c)
	ld	(xhl+3), wa	; F4AD20  ld (XHL+0x03),WA
	ld	wa, (BStore_CursorOffset:16)	; F4AD23  ld WA,(0x345e)
	ld	(xhl+5), a	; F4AD27  ld (XHL+0x05),A
	ld	c, (14038:16)	; F4AD2A  ld C,(0x36d6)
	ld	(13471:16), c	; F4AD2E  ld (0x349f),C
	calr	SeqRecord_LoadHeldNoteListHeadTail	; F4AD32  calr 0xf4a53e
	ld	a, (13275:16)	; F4AD35  ld A,(0x33db)
	ld	(xhl+6), a	; F4AD39  ld (XHL+0x06),A
	ld	a, (xhl+7)	; F4AD3C  ld A,(XHL+0x07)
	ld	(13278:16), a	; F4AD3F  ld (0x33de),A
	ld	(xhl+7), 255	; F4AD43  ld (XHL+0x07),0xff
	cp	(0x33da:16), 0x00	; F4AD47  cp (0x33da),0x00
	jr	nz, sub_F4ACB1_Skip	; F4AD4C  jr NZ,0xf4ad69
	xor	iy, iy	; F4AD4E  xor IY,IY
	xor	wa, wa	; F4AD50  xor WA,WA
	ld	a, (14038:16)	; F4AD52  ld A,(0x36d6)
	ld	iy, wa	; F4AD56  ld IY,WA
	sla	iy, 1	; F4AD58  sla 0x01,IY
	ld	xhl, 12310	; F4AD5B  ld XHL,0x00003016
	ld	a, (13279:16)	; F4AD60  ld A,(0x33df)
	ld	(xhl+iy), a	; F4AD64  ld (XHL+IY),A
sub_F4ACB1_Skip:
	cp	(0x33db:16), 0x00	; F4AD69  cp (0x33db),0x00
	jr	z, sub_F4ACB1_Skip2	; F4AD6E  jr Z,0xf4ad80
	xor	hl, hl	; F4AD70  xor HL,HL
	ld	l, (13275:16)	; F4AD72  ld L,(0x33db)
	calr	SeqRecord_HeldNoteSlotAddress	; F4AD76  calr 0xf4a56c
	ld	a, (13279:16)	; F4AD79  ld A,(0x33df)
	ld	(xhl+7), a	; F4AD7D  ld (XHL+0x07),A
sub_F4ACB1_Skip2:
	xor	iy, iy	; F4AD80  xor IY,IY
	xor	wa, wa	; F4AD82  xor WA,WA
	ld	a, (14038:16)	; F4AD84  ld A,(0x36d6)
	ld	iy, wa	; F4AD88  ld IY,WA
	sla	iy, 1	; F4AD8A  sla 0x01,IY
	ld	xhl, 12310	; F4AD8D  ld XHL,0x00003016
	ld	a, (13279:16)	; F4AD92  ld A,(0x33df)
	ld	xiz, xhl	; F4AD96  ld XIZ,XHL
	lda	xiz, (xiz+iy)	; F4AD98  lda XIZ,XIZ+IY
	ld	(xiz+1), a	; F4AD9D  ld (XIZ+0x01),A
	xor	xix, xix	; F4ADA0  xor XIX,XIX
	ld	xix, 12308	; F4ADA2  ld XIX,0x00003014
	ld	a, (13278:16)	; F4ADA7  ld A,(0x33de)
	ld	(xix), a	; F4ADAB  ld (XIX),A
	cp	(0x33de:16), 0xff	; F4ADAD  cp (0x33de),0xff
	jr	z, sub_F4ACB1_Return	; F4ADB2  jr Z,0xf4adc1
	xor	hl, hl	; F4ADB4  xor HL,HL
	ld	l, (13278:16)	; F4ADB6  ld L,(0x33de)
	calr	SeqRecord_HeldNoteSlotAddress	; F4ADBA  calr 0xf4a56c
	ld	(xhl+6), 0	; F4ADBD  ld (XHL+0x06),0x00
sub_F4ACB1_Return:
	ret	; F4ADC1  ret
	ld	wa, (14074:16)	; F4ADC2  ld WA,(0x36fa)
	ld	(BStore_CursorBlock:16), wa	; F4ADC6  ld (0x345c),WA
	jr	CycleRecord_SetEndCursorAtTakeChain2EndTag_Join	; F4ADCA  jr T,0xf4add4

; --------------------------------------------------------------------------
; CycleRecord_SetEndCursorAtTakeChain2EndTag
; Called from: in-module: 0xF4AA26 0xF4AC33
; Touches: (0x345C) (0x345E) (0x36D6) (0x36FC)  |  0x60347E 0x6034A0
; Calls:   T_BStore_ReadCursorByte CycleRecord_StepCursorOneEvent
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4ADCC is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_SetEndCursorAtTakeChain2EndTag: From take chain 2's head block (0x36FC), offset 5, walks event by event
;   (CycleRecord_StepCursorOneEvent) to the 0x82 end tag and makes that position record track (0x36D6)'s end cursor
;   (0x60347E[t], 0x6034A0[t]). CycleRecord_CopyFromCycleStartToTakeChain2's last step; sub_F4ABFC uses it too, and an
;   unlabelled entry at 0xF4ADC2 does the same from the record chain (0x36FA). Basis: caller + caller header + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave8_a8.json)
CycleRecord_SetEndCursorAtTakeChain2EndTag:
	ld	wa, (14076:16)	; F4ADCC  ld WA,(0x36fc)
	ld	(BStore_CursorBlock:16), wa	; F4ADD0  ld (0x345c),WA
CycleRecord_SetEndCursorAtTakeChain2EndTag_Join:
	ldw	(BStore_CursorOffset:16), 5	; F4ADD4  ld (0x345e),0x0005
CycleRecord_SetEndCursorAtTakeChain2EndTag_Join2:
	call	T_BStore_ReadCursorByte	; F4ADDA  call 0xf40c54
	cp	a, 130	; F4ADDE  cp A,0x82
	jr	z, CycleRecord_SetEndCursorAtTakeChain2EndTag_Skip	; F4ADE1  jr Z,0xf4ade9
	call	CycleRecord_StepCursorOneEvent	; F4ADE3  call 0xf4aedd
	jr	CycleRecord_SetEndCursorAtTakeChain2EndTag_Join2	; F4ADE7  jr T,0xf4adda
CycleRecord_SetEndCursorAtTakeChain2EndTag_Skip:
	ld	xix, 6304894	; F4ADE9  ld XIX,0x0060347e
	xor	xwa, xwa	; F4ADEE  xor XWA,XWA
	ld	a, (14038:16)	; F4ADF0  ld A,(0x36d6)
	sll	xwa, 1	; F4ADF4  sll 0x01,XWA
	add	xix, xwa	; F4ADF7  add XIX,XWA
	ld	wa, (BStore_CursorBlock:16)	; F4ADF9  ld WA,(0x345c)
	ld	(xix), wa	; F4ADFD  ld (XIX),WA
	ld	xix, 6304928	; F4ADFF  ld XIX,0x006034a0
	xor	xwa, xwa	; F4AE04  xor XWA,XWA
	ld	a, (14038:16)	; F4AE06  ld A,(0x36d6)
	add	xix, xwa	; F4AE0A  add XIX,XWA
	ld	wa, (BStore_CursorOffset:16)	; F4AE0C  ld WA,(0x345e)
	xor	w, w	; F4AE10  xor W,W
	ld	(xix), a	; F4AE12  ld (XIX),A
	ret	; F4AE14  ret

; --------------------------------------------------------------------------
; sub_F4AE15
; Called from: in-module: 0xF4AC36 0xF4AC8F
; Touches: (0x0D4A) (0x3452) (0x345C) (0x345E) (0x36D6) (0x36E9) (0x36F1)  |
;          0x0033EA 0x60347E 0x6034A0
; Calls:   T_BStore_StepCursorBackToLeadByte sub_F4AB60 T_BStore_ReadCursorByte CycleRecord_StepCursorOneEvent T_BStore_StepCursorOneByte
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4AE15 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4AE15:
	ld	xix, 6304894	; F4AE15  ld XIX,0x0060347e
	xor	xwa, xwa	; F4AE1A  xor XWA,XWA
	ld	a, (14038:16)	; F4AE1C  ld A,(0x36d6)
	sll	xwa, 1	; F4AE20  sll 0x01,XWA
	add	xix, xwa	; F4AE23  add XIX,XWA
	ld	wa, (xix)	; F4AE25  ld WA,(XIX)
	ld	(BStore_CursorBlock:16), wa	; F4AE27  ld (0x345c),WA
	ld	xix, 6304928	; F4AE2B  ld XIX,0x006034a0
	xor	xwa, xwa	; F4AE30  xor XWA,XWA
	ld	a, (14038:16)	; F4AE32  ld A,(0x36d6)
	add	xix, xwa	; F4AE36  add XIX,XWA
	ld	a, (xix)	; F4AE38  ld A,(XIX)
	xor	w, w	; F4AE3A  xor W,W
	ld	(BStore_CursorOffset:16), wa	; F4AE3C  ld (0x345e),WA
	res	0, (0x36f1:16)	; F4AE40  res 0,(0x36f1)
sub_F4AE15_Loop:
	call	T_BStore_StepCursorBackToLeadByte	; F4AE44  call 0xf40b6c
	cp	(BStore_ErrorCode:16), 0x00	; F4AE48  cp (0x0d4a),0x00
	jr	z, sub_F4AE15_Skip	; F4AE4D  jr Z,0xf4ae53
	calr	sub_F4AB60	; F4AE4F  calr 0xf4ab60
	ret	; F4AE52  ret
sub_F4AE15_Skip:
	call	T_BStore_ReadCursorByte	; F4AE53  call 0xf40c54
	cp	a, 129	; F4AE57  cp A,0x81
	jr	nz, sub_F4AE15_Skip4	; F4AE5A  jr NZ,0xf4ae91
	ld	xhl, 13290	; F4AE5C  ld XHL,0x000033ea
	xor	wa, wa	; F4AE61  xor WA,WA
	ld	a, (14038:16)	; F4AE63  ld A,(0x36d6)
	sll	wa, 1	; F4AE67  sll 0x01,WA
	ld	wa, (xhl+wa)	; F4AE6A  ld WA,(XHL+WA)
	cp	wa, (0x3452:16)	; F4AE6F  cp WA,(0x3452)
	jr	ugt, sub_F4AE15_Skip2	; F4AE73  jr UGT,0xf4ae7d
	call	CycleRecord_StepCursorOneEvent	; F4AE75  call 0xf4aedd
	calr	sub_F4AB60	; F4AE79  calr 0xf4ab60
	ret	; F4AE7C  ret
sub_F4AE15_Skip2:
	bit	0, (0x36f1:16)	; F4AE7D  bit 0,(0x36f1)
	jr	z, sub_F4AE15_Skip3	; F4AE81  jr Z,0xf4ae8b
	call	CycleRecord_StepCursorOneEvent	; F4AE83  call 0xf4aedd
	calr	sub_F4AB60	; F4AE87  calr 0xf4ab60
	ret	; F4AE8A  ret
sub_F4AE15_Skip3:
	set	0, (0x36f1:16)	; F4AE8B  set 0,(0x36f1)
	jr	sub_F4AE15_Loop	; F4AE8F  jr T,0xf4ae44
sub_F4AE15_Skip4:
	ld	xhl, 13290	; F4AE91  ld XHL,0x000033ea
	xor	wa, wa	; F4AE96  xor WA,WA
	ld	a, (14038:16)	; F4AE98  ld A,(0x36d6)
	sll	wa, 1	; F4AE9C  sll 0x01,WA
	ld	wa, (xhl+wa)	; F4AE9F  ld WA,(XHL+WA)
	cp	wa, (0x3452:16)	; F4AEA4  cp WA,(0x3452)
	jr	ugt, sub_F4AE15_Skip5	; F4AEA8  jr UGT,0xf4aeac
	jr	sub_F4AE15_Join	; F4AEAA  jr T,0xf4aeb2
sub_F4AE15_Skip5:
	bit	0, (0x36f1:16)	; F4AEAC  bit 0,(0x36f1)
	jr	z, sub_F4AE15_Loop	; F4AEB0  jr Z,0xf4ae44
sub_F4AE15_Join:
	ld	de, (BStore_CursorBlock:16)	; F4AEB2  ld DE,(0x345c)
	ld	bc, (BStore_CursorOffset:16)	; F4AEB6  ld BC,(0x345e)
	pushw	de	; F4AEBA  push DE
	pushw	bc	; F4AEBB  push BC
	call	T_BStore_StepCursorOneByte	; F4AEBC  call 0xf40c50
	call	T_BStore_ReadCursorByte	; F4AEC0  call 0xf40c54
	popw	bc	; F4AEC4  pop BC
	popw	de	; F4AEC5  pop DE
	ld	(BStore_CursorBlock:16), de	; F4AEC6  ld (0x345c),DE
	ld	(BStore_CursorOffset:16), bc	; F4AECA  ld (0x345e),BC
	cp	(14057:16), a	; F4AECE  cp (0x36e9),A
	jrl	c, sub_F4AE15_Loop	; F4AED2  jrl C,0xf4ae44
	call	CycleRecord_StepCursorOneEvent	; F4AED5  call 0xf4aedd
	calr	sub_F4AB60	; F4AED9  calr 0xf4ab60
	ret	; F4AEDC  ret

; --------------------------------------------------------------------------
; CycleRecord_StepCursorOneEvent
; Called from: in-module: 0xF4AA7B 0xF4ADE3 0xF4AE75 0xF4AE83 0xF4AED5
;              0xF4B0AB 0xF4B24B 0xF4B35B +2 more
; Touches: (0x36F0)
; Calls:   T_BStore_StepCursorToNextLeadByte
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4AEDD is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_StepCursorOneEvent: Steps the block-store cursor past the current event to the next lead byte: T_BStore_StepCursorToNextLeadByte
;   -> BStore_StepCursorToNextLeadByte steps a byte at a time (BStore_StepCursorOneByte, BStore_ReadCursorByte) until a byte with bit 7
;   set, copying up to 5 data bytes to 0x34A4[]; (0x36F0) is kept across the call. The cycle-record walks' event step.
;   Basis: callers + body (target read). (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
CycleRecord_StepCursorOneEvent:
	ld	w, (14064:16)	; F4AEDD  ld W,(0x36f0)
	push	w	; F4AEE1  push W
	call	T_BStore_StepCursorToNextLeadByte	; F4AEE3  call 0xf40b40
	pop	w	; F4AEE7  pop W
	ld	(14064:16), w	; F4AEE9  ld (0x36f0),W
	ret	; F4AEED  ret

; --------------------------------------------------------------------------
; sub_F4AEEE
; Called from: in-module: 0xF4AC3C 0xF4AC95 0xF4AF30
; Touches: (0x0D4A) (0x36D6) (0x36F0)  |  0x0036E8
; Calls:   T_BStore_AppendBytes_Veneer
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4AEEE is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4AEEE:
	ld	xiy, 14056	; F4AEEE  ld XIY,0x000036e8
	ld	a, (14038:16)	; F4AEF3  ld A,(0x36d6)
	add	a, 1	; F4AEF7  add A,0x01
	ld	w, (14064:16)	; F4AEFA  ld W,(0x36f0)
	ld	(BStore_ErrorCode:16), 0	; F4AEFE  ld (0x0d4a),0x00
	call	T_BStore_AppendBytes_Veneer	; F4AF03  call 0xf42894
	ret	; F4AF07  ret

; --------------------------------------------------------------------------
; sub_F4AF08
; Called from: T_F40BE8 (x2)
; Touches: (0x0D4A) (0x345C) (0x345E) (0x349F) (0x36FA) (0x3751)
; Calls:   T_SeqTrackCursors_Save CycleRecord_MoveSongPositionToTrackEnd sub_F4AEEE CycleRecord_AbortMemoryFull T_SeqTrackCursors_RestoreSaved
; Evidence: thunk slot T_F40BE8 holds `jp 0x00F4AF08`, and 0xF4AF08 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4AF08:		; <- T_F40BE8
	cp	(0x36fa:16), 0xff	; F4AF08  cp (0x36fa),0xff
	jr	z, sub_F4AEEE_Return	; F4AF0D  jr Z,0xf4af50
	bit	0, (0x3751:16)	; F4AF0F  bit 0,(0x3751)
	jr	nz, sub_F4AEEE_Return	; F4AF13  jr NZ,0xf4af50
	call	T_SeqTrackCursors_Save	; F4AF15  call 0xf40b68
	ld	wa, (BStore_CursorBlock:16)	; F4AF19  ld WA,(0x345c)
	ld	bc, (BStore_CursorOffset:16)	; F4AF1D  ld BC,(0x345e)
	ld	e, (13471:16)	; F4AF21  ld E,(0x349f)
	pushw	wa	; F4AF25  push WA
	pushw	bc	; F4AF26  push BC
	pushw	de	; F4AF27  push DE
	calr	CycleRecord_MoveSongPositionToTrackEnd	; F4AF28  calr 0xf4a93c
	ld	(BStore_ErrorCode:16), 0	; F4AF2B  ld (0x0d4a),0x00
	calr	sub_F4AEEE	; F4AF30  calr 0xf4aeee
	cp	(BStore_ErrorCode:16), 0x00	; F4AF33  cp (0x0d4a),0x00
	jr	z, sub_F4AEEE_Skip	; F4AF38  jr Z,0xf4af3d
	calr	CycleRecord_AbortMemoryFull	; F4AF3A  calr 0xf4a7fe
sub_F4AEEE_Skip:
	popw	de	; F4AF3D  pop DE
	popw	bc	; F4AF3E  pop BC
	popw	wa	; F4AF3F  pop WA
	ld	(13471:16), e	; F4AF40  ld (0x349f),E
	ld	(BStore_CursorBlock:16), wa	; F4AF44  ld (0x345c),WA
	ld	(BStore_CursorOffset:16), bc	; F4AF48  ld (0x345e),BC
	call	T_SeqTrackCursors_RestoreSaved	; F4AF4C  call 0xf40b64
sub_F4AEEE_Return:
	ret	; F4AF50  ret

; --------------------------------------------------------------------------
; sub_F4AF51
; Called from: T_F40BFC (x2)
; Touches: (0x2070) (0x2880) (0x3000) (0x36F2) (0x36F4)  |  0x000000
; Calls:   T_SeqBufRing_Discard_Veneer T_PartNotes_ReleaseAllTrackNotes T_F41F18 SeqRecord_FreeTakeChain2 CycleRecord_FillTakeChain2WithBeatMarks sub_F4B433
;          sub_F4B08B CycleRecord_FreeRecordChain CycleRecord_AllocRecordChain T_SeqTrackCursors_Save CycleRecord_AppendBeatMarks T_SeqTrackCursors_RestoreSaved +2
;          more
; Evidence: thunk slot T_F40BFC holds `jp 0x00F4AF51`, and 0xF4AF51 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4AF51:		; <- T_F40BFC
	ld	xwa, (12288:16)	; F4AF51  ld XWA,(0x3000)
	cp	xwa, 0	; F4AF55  cp XWA,0x00000000
	jrl	z, sub_F4AEEE_Return2	; F4AF5B  jrl Z,0xf4afd4
	call	T_SeqBufRing_Discard_Veneer	; F4AF5E  call 0xf40a60
	call	T_PartNotes_ReleaseAllTrackNotes	; F4AF62  call 0xf413c8
	call	T_F41F18	; F4AF66  call 0xf41f18
	bit	2, (TransportB_State:8)	; F4AF6A  bit 2,(0x96)
	jr	nz, sub_F4AEEE_Skip2	; F4AF6D  jr NZ,0xf4af7d
	ld	xwa, (12288:16)	; F4AF6F  ld XWA,(0x3000)
	cp	xwa, 0	; F4AF73  cp XWA,0x00000000
	jr	nz, sub_F4AEEE_Skip3	; F4AF79  jr NZ,0xf4afb7
	jr	sub_F4AEEE_Return2	; F4AF7B  jr T,0xf4afd4
sub_F4AEEE_Skip2:
	calr	SeqRecord_FreeTakeChain2	; F4AF7D  calr 0xf4a6e7
	calr	CycleRecord_FillTakeChain2WithBeatMarks	; F4AF80  calr 0xf4a813
	calr	sub_F4B433	; F4AF83  calr 0xf4b433
	ld	wa, (14066:16)	; F4AF86  ld WA,(0x36f2)
	ld	(14068:16), wa	; F4AF8A  ld (0x36f4),WA
	calr	sub_F4B08B	; F4AF8E  calr 0xf4b08b
	calr	CycleRecord_FreeRecordChain	; F4AF91  calr 0xf4a6cf
	calr	CycleRecord_AllocRecordChain	; F4AF94  calr 0xf4ab8a
	ld	wa, (14068:16)	; F4AF97  ld WA,(0x36f4)
	ld	(14066:16), wa	; F4AF9B  ld (0x36f2),WA
	call	T_SeqTrackCursors_Save	; F4AF9F  call 0xf40b68
	calr	CycleRecord_AppendBeatMarks	; F4AFA3  calr 0xf4a90a
	call	T_SeqTrackCursors_RestoreSaved	; F4AFA6  call 0xf40b64
	ld	(UI_StatusCode:16), 35	; F4AFAA  ld (0x2880),0x23
	ldw	(UI_Request:16), 16555	; F4AFAF  ld (0x2070),0x40ab
	jr	sub_F4AEEE_Return2	; F4AFB5  jr T,0xf4afd4
sub_F4AEEE_Skip3:
	calr	SeqRecord_FreeTakeChain2	; F4AFB7  calr 0xf4a6e7
	calr	CycleRecord_FillTakeChain2WithBeatMarks	; F4AFBA  calr 0xf4a813
	calr	CycleRecord_PlayTrackFromTakeChain2	; F4AFBD  calr 0xf4a6ff
	calr	CycleRecord_FreeRecordChain	; F4AFC0  calr 0xf4a6cf
	calr	CycleRecord_AllocRecordChain	; F4AFC3  calr 0xf4ab8a
	calr	sub_F4AFD5	; F4AFC6  calr 0xf4afd5
	ld	(UI_StatusCode:16), 35	; F4AFC9  ld (0x2880),0x23
	ldw	(UI_Request:16), 16555	; F4AFCE  ld (0x2070),0x40ab
sub_F4AEEE_Return2:
	ret	; F4AFD4  ret

; --------------------------------------------------------------------------
; sub_F4AFD5
; Called from: in-module: 0xF4AFC6
; Touches: (0x0D4A) (0x3000) (0x3002) (0x34D4) (0x34D9) (0x3552) (0x36D4)
;          (0x36D6) (0x3731) (0x3751)  |  0x000000
; Calls:   SeqRecord_RestoreCursorBaseline T_SeqCycle_CaptureEndCursors T_SeqCycle_LocateToStart T_Seq_SetTrackBeatsFromTransportB CycleRecord_FreeRecordChain SeqRecord_FreeTakeChain2
;          CycleRecord_CopyCycleRangeToTakeChain2 CycleRecord_FillTakeChain2WithBeatMarks CycleRecord_AllocRecordChain CycleRecord_PlayTrackFromTakeChain2 T_Seq_ResetPositionOnRequest
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4AFD5 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4AFD5:
	res	0, (0x3731:16)	; F4AFD5  res 0,(0x3731)
	calr	SeqRecord_RestoreCursorBaseline	; F4AFD9  calr 0xf4b414
	set	0, (0x3751:16)	; F4AFDC  set 0,(0x3751)
	call	T_SeqCycle_CaptureEndCursors	; F4AFE0  call 0xf40b60
	call	T_SeqCycle_LocateToStart	; F4AFE4  call 0xf40b5c
	call	T_Seq_SetTrackBeatsFromTransportB	; F4AFE8  call 0xf40ac4
	res	0, (0x3751:16)	; F4AFEC  res 0,(0x3751)
	ld	xwa, (12288:16)	; F4AFF0  ld XWA,(0x3000)
	cp	xwa, 0	; F4AFF4  cp XWA,0x00000000
	jrl	z, sub_F4AFD5_Return	; F4AFFA  jrl Z,0xf4b08a
	bit	0, (0x34d9:16)	; F4AFFD  bit 0,(0x34d9)
	jr	z, sub_F4AFD5_Skip	; F4B001  jr Z,0xf4b00b
	ld	wa, (13650:16)	; F4B003  ld WA,(0x3552)
	ld	(14036:16), wa	; F4B007  ld (0x36d4),WA
sub_F4AFD5_Skip:
	xor	wa, wa	; F4B00B  xor WA,WA
sub_F4AFD5_Loop:
	cp	a, 16	; F4B00D  cp A,0x10
	jr	nc, sub_F4AFD5_Skip2	; F4B010  jr NC,0xf4b01d
	ld	iz, (12288:16)	; F4B012  ld IZ,(0x3000)
	scf	; F4B016  scf
	xorcf_a_16	iz	; F4B017  xorcf A,IZ
	jr	c, sub_F4AFD5_Skip4	; F4B019  jr C,0xf4b057
	jr	sub_F4AFD5_Join	; F4B01B  jr T,0xf4b02b
sub_F4AFD5_Skip2:
	pushw	wa	; F4B01D  push WA
	ld	iz, (12290:16)	; F4B01E  ld IZ,(0x3002)
	sub	a, 16	; F4B022  sub A,0x10
	scf	; F4B025  scf
	xorcf_a_16	iz	; F4B026  xorcf A,IZ
	popw	wa	; F4B028  pop WA
	jr	c, sub_F4AFD5_Skip4	; F4B029  jr C,0xf4b057
sub_F4AFD5_Join:
	ld	(14038:16), a	; F4B02B  ld (0x36d6),A
	cp	a, 16	; F4B02F  cp A,0x10
	jr	nc, sub_F4AFD5_Skip3	; F4B032  jr NC,0xf4b043
	ld	de, (6304798:24)	; F4B034  ld DE,(0x60341e)
	scf	; F4B039  scf
	stcf_a_16	de	; F4B03A  stcf A,DE
	ld	(6304798:24), de	; F4B03C  ld (0x60341e),DE
	jr	sub_F4AFD5_Join2	; F4B041  jr T,0xf4b055
sub_F4AFD5_Skip3:
	ld	de, (6304800:24)	; F4B043  ld DE,(0x603420)
	pushw	wa	; F4B048  push WA
	sub	a, 16	; F4B049  sub A,0x10
	scf	; F4B04C  scf
	stcf_a_16	de	; F4B04D  stcf A,DE
	popw	wa	; F4B04F  pop WA
	ld	(6304800:24), de	; F4B050  ld (0x603420),DE
sub_F4AFD5_Join2:
	jr	sub_F4AFD5_Join3	; F4B055  jr T,0xf4b05e
sub_F4AFD5_Skip4:
	inc	1, a	; F4B057  inc 1,A
	cp	a, 17	; F4B059  cp A,0x11
	jr	c, sub_F4AFD5_Loop	; F4B05C  jr C,0xf4b00d
sub_F4AFD5_Join3:
	calr	CycleRecord_FreeRecordChain	; F4B05E  calr 0xf4a6cf
	calr	SeqRecord_FreeTakeChain2	; F4B061  calr 0xf4a6e7
	calr	CycleRecord_CopyCycleRangeToTakeChain2	; F4B064  calr 0xf4a756
	calr	SeqRecord_FreeTakeChain2	; F4B067  calr 0xf4a6e7
	calr	CycleRecord_FillTakeChain2WithBeatMarks	; F4B06A  calr 0xf4a813
	cp	(BStore_ErrorCode:16), 0x00	; F4B06D  cp (0x0d4a),0x00
	jr	nz, sub_F4AFD5_Return	; F4B072  jr NZ,0xf4b08a
	calr	CycleRecord_AllocRecordChain	; F4B074  calr 0xf4ab8a
	cp	(BStore_ErrorCode:16), 0x00	; F4B077  cp (0x0d4a),0x00
	jr	nz, sub_F4AFD5_Return	; F4B07C  jr NZ,0xf4b08a
	calr	CycleRecord_PlayTrackFromTakeChain2	; F4B07E  calr 0xf4a6ff
	or	(0x34d4:16), 0x10	; F4B081  or (0x34d4),0x10
	call	T_Seq_ResetPositionOnRequest	; F4B086  call 0xf40aac
sub_F4AFD5_Return:
	ret	; F4B08A  ret

; --------------------------------------------------------------------------
; sub_F4B08B
; Called from: in-module: 0xF4AF8E
; Touches: (0x345C) (0x345E) (0x36D6) (0x36F2) (0x36FC)  |  0x003460
;          0x003482
; Calls:   T_BStore_ReadCursorByte CycleRecord_StepCursorOneEvent
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4B08B is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4B08B:
	ld	wa, (14076:16)	; F4B08B  ld WA,(0x36fc)
	ld	(BStore_CursorBlock:16), wa	; F4B08F  ld (0x345c),WA
	ldw	(BStore_CursorOffset:16), 5	; F4B093  ld (0x345e),0x0005
	incw	1, (14066:16)	; F4B099  incw 1,(0x36f2)
sub_F4B08B_Join:
	call	T_BStore_ReadCursorByte	; F4B09D  call 0xf40c54
	cp	a, 129	; F4B0A1  cp A,0x81
	jr	z, sub_F4B08B_Skip	; F4B0A4  jr Z,0xf4b0b1
	cp	a, 130	; F4B0A6  cp A,0x82
	jr	z, sub_F4B08B_Skip2	; F4B0A9  jr Z,0xf4b0bd
sub_F4B08B_Loop:
	call	CycleRecord_StepCursorOneEvent	; F4B0AB  call 0xf4aedd
	jr	sub_F4B08B_Join	; F4B0AF  jr T,0xf4b09d
sub_F4B08B_Skip:
	decw	1, (14066:16)	; F4B0B1  decw 1,(0x36f2)
	cpw	(0x36f2:16), 0x0000	; F4B0B5  cp (0x36f2),0x0000
	jr	nz, sub_F4B08B_Loop	; F4B0BB  jr NZ,0xf4b0ab
sub_F4B08B_Skip2:
	ld	xix, 13408	; F4B0BD  ld XIX,0x00003460
	xor	xwa, xwa	; F4B0C2  xor XWA,XWA
	ld	a, (14038:16)	; F4B0C4  ld A,(0x36d6)
	sll	xwa, 1	; F4B0C8  sll 0x01,XWA
	add	xix, xwa	; F4B0CB  add XIX,XWA
	ld	wa, (BStore_CursorBlock:16)	; F4B0CD  ld WA,(0x345c)
	ld	(xix), wa	; F4B0D1  ld (XIX),WA
	ld	xix, 13442	; F4B0D3  ld XIX,0x00003482
	xor	xwa, xwa	; F4B0D8  xor XWA,XWA
	ld	a, (14038:16)	; F4B0DA  ld A,(0x36d6)
	add	xix, xwa	; F4B0DE  add XIX,XWA
	ld	wa, (BStore_CursorOffset:16)	; F4B0E0  ld WA,(0x345e)
	ld	(xix), a	; F4B0E4  ld (XIX),A
	ret	; F4B0E6  ret

; --------------------------------------------------------------------------
; sub_F4B0E7
; Called from: T_F40BEC (x1)
; Touches: (0x345C) (0x345E) (0x36FA) (0x36FC) (0x3731)
; Calls:   SeqRecord_FreeTakeChain2 CycleRecord_AllocRecordChain
; Evidence: thunk slot T_F40BEC holds `jp 0x00F4B0E7`, and 0xF4B0E7 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4B0E7:		; <- T_F40BEC
	set	0, (0x3731:16)	; F4B0E7  set 0,(0x3731)
	calr	SeqRecord_FreeTakeChain2	; F4B0EB  calr 0xf4a6e7
	ld	wa, (14074:16)	; F4B0EE  ld WA,(0x36fa)
	ld	(14076:16), wa	; F4B0F2  ld (0x36fc),WA
	ldw	(BStore_CursorOffset:16), 5	; F4B0F6  ld (0x345e),0x0005
	ld	(BStore_CursorBlock:16), wa	; F4B0FC  ld (0x345c),WA
	calr	CycleRecord_AllocRecordChain	; F4B100  calr 0xf4ab8a
	ret	; F4B103  ret

; --------------------------------------------------------------------------
; CycleRecord_CommitTake
; Called from: T_CycleRecord_CommitTake (x1)
; Touches: (0x0D4A) (0x349F) (0x36D6) (0x3731)
; Calls:   CycleRecord_AppendUnplayedRest SeqRecord_FreeTakeChain2 CycleRecord_SaveTrackEndCursor SeqRecord_RestoreCursorBaseline CycleRecord_PadTrackPastCycleEnd T_CycleRecord_CaptureEndCursors
;          T_CycleRecord_CaptureStartCursors CycleRecord_SetUpSplice T_BStore_SpliceChainIntoTrack CycleRecord_AbortMemoryFull CycleRecord_FreeRecordChain
; Evidence: thunk slot T_CycleRecord_CommitTake holds `jp 0x00F4B104`, and 0xF4B104 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CommitTake: Cycle-record end of a take (SeqRecord_EndTake's alternative to SeqRecord_TerminateTakeTracks
;   when CycleRecord_CheckOnPreviousScreen = 0): copies take chain 2's unplayed rest after the recorded data, restores the cursor baseline,
;   splices chain (0x36FA) into record track (0x36D6) (CycleRecord_SetUpSplice, T_BStore_SpliceChainIntoTrack), frees chain 2; no free block / error:
;   baseline, CycleRecord_AbortMemoryFull, both chains freed. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_p.json)
CycleRecord_CommitTake:		; <- T_CycleRecord_CommitTake
	res	0, (0x3731:16)	; F4B104  res 0,(0x3731)
	cpw	(BStore_FreeCount:24), 0x0000	; F4B108  cp (0x6034ba),0x0000
	jr	z, sub_F4B08B_Skip3	; F4B10F  jr Z,0xf4b153
	ld	(BStore_ErrorCode:16), 0	; F4B111  ld (0x0d4a),0x00
	calr	CycleRecord_AppendUnplayedRest	; F4B116  calr 0xf4b2d5
	cp	(BStore_ErrorCode:16), 0x00	; F4B119  cp (0x0d4a),0x00
	jr	nz, sub_F4B08B_Skip3	; F4B11E  jr NZ,0xf4b153
	calr	SeqRecord_FreeTakeChain2	; F4B120  calr 0xf4a6e7
	calr	CycleRecord_SaveTrackEndCursor	; F4B123  calr 0xf4b2ab
	calr	SeqRecord_RestoreCursorBaseline	; F4B126  calr 0xf4b414
	ld	(BStore_ErrorCode:16), 0	; F4B129  ld (0x0d4a),0x00
	calr	CycleRecord_PadTrackPastCycleEnd	; F4B12E  calr 0xf4b160
	cp	(BStore_ErrorCode:16), 0x00	; F4B131  cp (0x0d4a),0x00
	jr	nz, sub_F4B08B_Skip3	; F4B136  jr NZ,0xf4b153
	call	T_CycleRecord_CaptureEndCursors	; F4B138  call 0xf40b74
	call	T_CycleRecord_CaptureStartCursors	; F4B13C  call 0xf40b70
	calr	CycleRecord_SetUpSplice	; F4B140  calr 0xf4b36e
	ld	a, (14038:16)	; F4B143  ld A,(0x36d6)
	ld	(13471:16), a	; F4B147  ld (0x349f),A
	call	T_BStore_SpliceChainIntoTrack	; F4B14B  call 0xf40c8c
	calr	SeqRecord_FreeTakeChain2	; F4B14F  calr 0xf4a6e7
	ret	; F4B152  ret
sub_F4B08B_Skip3:
	calr	SeqRecord_RestoreCursorBaseline	; F4B153  calr 0xf4b414
	calr	CycleRecord_AbortMemoryFull	; F4B156  calr 0xf4a7fe
	calr	SeqRecord_FreeTakeChain2	; F4B159  calr 0xf4a6e7
	calr	CycleRecord_FreeRecordChain	; F4B15C  calr 0xf4a6cf
	ret	; F4B15F  ret

; --------------------------------------------------------------------------
; CycleRecord_PadTrackPastCycleEnd
; Called from: in-module: 0xF4B12E
; Touches: (0x0D4A) (0x3604) (0x36D6) (0x36F2) (0x36F4)  |  0x000000
;          0x000001 0x000002 0x60347E 0x6034A0 0x603500
; Calls:   T_BStore_AllocBlock_B_Veneer CycleRecord_AppendBeatMark CycleRecord_CountTrackBeatMarks CycleRecord_CountBeatsToCycleEnd CycleRecord_AppendBeatMarks
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4B160 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_PadTrackPastCycleEnd: At commit: if record track (0x36D6)'s directory entry is unused, allocates its
;   first block (in use, head, end cursor offset 5) and writes one 0x81; then counts the track's 0x81 beat marks
;   (CycleRecord_CountTrackBeatMarks) against (0x3624)+1 bars of beats (CycleRecord_CountBeatsToCycleEnd) and appends the shortfall + 2 beat marks (CycleRecord_AppendBeatMarks).
;   No free block -> BStore_ErrorCode 0xFF. CycleRecord_CommitTake step after the baseline restore. Basis: caller +
;   body + sibling. (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
CycleRecord_PadTrackPastCycleEnd:
	ld	(BStore_ErrorCode:16), 0	; F4B160  ld (0x0d4a),0x00
	xor	xwa, xwa	; F4B165  xor XWA,XWA
	ld	a, (14038:16)	; F4B167  ld A,(0x36d6)
	mul	a, 3	; F4B16B  mul A,0x03
	ld	xix, 6305024	; F4B16E  ld XIX,0x00603500
	add	xix, xwa	; F4B173  add XIX,XWA
	bit	7, (xix)	; F4B175  bit 7,(XIX)
	jr	nz, CycleRecord_PadTrackPastCycleEnd_Skip	; F4B177  jr NZ,0xf4b1e3
	cpw	(BStore_FreeCount:24), 0x0000	; F4B179  cp (0x6034ba),0x0000
	jrl	z, CycleRecord_PadTrackPastCycleEnd_Skip2	; F4B180  jrl Z,0xf4b207
	push	xix	; F4B183  push XIX
	call	T_BStore_AllocBlock_B_Veneer	; F4B184  call 0xf40c88
	ld	hl, ix	; F4B188  ld HL,IX
	ld	xiy, (BStore_HeapBase:16)	; F4B18A  ld XIY,(0x3604)
	add	xiy, 0	; F4B18E  add XIY,0x00000000
	extz	xix	; F4B194  extz XIX
	dec	1, xix	; F4B196  dec 1,XIX
	sll	xix, 8	; F4B198  sll 0x08,XIX
	add	xiy, xix	; F4B19B  add XIY,XIX
	set	7, (xiy)	; F4B19D  set 7,(XIY)
	add	xiy, 1	; F4B19F  add XIY,0x00000001
	ldw	(xiy), 0x0000	; F4B1A5  ld (XIY),0x0000
	add	xiy, 2	; F4B1A9  add XIY,0x00000002
	ldw	(xiy), 0xffff	; F4B1AF  ld (XIY),0xffff
	pop	xix	; F4B1B3  pop XIX
	set	7, (xix)	; F4B1B4  set 7,(XIX)
	add	xix, 1	; F4B1B6  add XIX,0x00000001
	ld	(xix), hl	; F4B1BC  ld (XIX),HL
	ld	xix, 6304894	; F4B1BE  ld XIX,0x0060347e
	xor	xwa, xwa	; F4B1C3  xor XWA,XWA
	ld	a, (14038:16)	; F4B1C5  ld A,(0x36d6)
	sll	xwa, 1	; F4B1C9  sll 0x01,XWA
	add	xix, xwa	; F4B1CC  add XIX,XWA
	ld	(xix), hl	; F4B1CE  ld (XIX),HL
	ld	xix, 6304928	; F4B1D0  ld XIX,0x006034a0
	xor	xwa, xwa	; F4B1D5  xor XWA,XWA
	ld	a, (14038:16)	; F4B1D7  ld A,(0x36d6)
	add	xix, xwa	; F4B1DB  add XIX,XWA
	ld	(xix), 5	; F4B1DD  ld (XIX),0x05
	calr	CycleRecord_AppendBeatMark	; F4B1E0  calr 0xf4a91e
CycleRecord_PadTrackPastCycleEnd_Skip:
	calr	CycleRecord_CountTrackBeatMarks	; F4B1E3  calr 0xf4b20d
	calr	CycleRecord_CountBeatsToCycleEnd	; F4B1E6  calr 0xf4b258
	ld	wa, (14066:16)	; F4B1E9  ld WA,(0x36f2)
	cp	wa, (0x36f4:16)	; F4B1ED  cp WA,(0x36f4)
	jr	ugt, CycleRecord_PadTrackPastCycleEnd_Return	; F4B1F1  jr UGT,0xf4b206
	ld	wa, (14068:16)	; F4B1F3  ld WA,(0x36f4)
	sub	wa, (0x36f2:16)	; F4B1F7  sub WA,(0x36f2)
	add	wa, 2	; F4B1FB  add WA,0x0002
	ld	(14066:16), wa	; F4B1FF  ld (0x36f2),WA
	calr	CycleRecord_AppendBeatMarks	; F4B203  calr 0xf4a90a
CycleRecord_PadTrackPastCycleEnd_Return:
	ret	; F4B206  ret
CycleRecord_PadTrackPastCycleEnd_Skip2:
	ld	(BStore_ErrorCode:16), 255	; F4B207  ld (0x0d4a),0xff
	ret	; F4B20C  ret

; --------------------------------------------------------------------------
; CycleRecord_CountTrackBeatMarks
; Called from: in-module: 0xF4B1E3
; Touches: (0x345C) (0x345E) (0x36D6) (0x36F2)  |  0x000001 0x603500
; Calls:   T_BStore_ReadCursorByte CycleRecord_StepCursorOneEvent
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4B20D is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CountTrackBeatMarks: (0x36F2) := the number of 0x81 beat marks in record track (0x36D6)'s chain, from
;   its directory head (0x603500 + 3t + 1), offset 5, to the 0x82 end tag, stepping with CycleRecord_StepCursorOneEvent; a 0xFFFF head
;   returns with (0x36F2) untouched. CycleRecord_PadTrackPastCycleEnd compares it with the beats up to the cycle end.
;   Basis: caller + caller header + body. (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
CycleRecord_CountTrackBeatMarks:
	xor	xwa, xwa	; F4B20D  xor XWA,XWA
	ld	a, (14038:16)	; F4B20F  ld A,(0x36d6)
	mul	a, 3	; F4B213  mul A,0x03
	ld	xix, 6305024	; F4B216  ld XIX,0x00603500
	add	xix, xwa	; F4B21B  add XIX,XWA
	add	xix, 1	; F4B21D  add XIX,0x00000001
	ld	wa, (xix)	; F4B223  ld WA,(XIX)
	cp	wa, 65535	; F4B225  cp WA,0xffff
	jr	nz, CycleRecord_CountTrackBeatMarks_Skip	; F4B229  jr NZ,0xf4b22d
	jr	CycleRecord_CountTrackBeatMarks_Return	; F4B22B  jr T,0xf4b257
CycleRecord_CountTrackBeatMarks_Skip:
	ld	(BStore_CursorBlock:16), wa	; F4B22D  ld (0x345c),WA
	ldw	(BStore_CursorOffset:16), 5	; F4B231  ld (0x345e),0x0005
	ldw	(14066:16), 0	; F4B237  ld (0x36f2),0x0000
CycleRecord_CountTrackBeatMarks_Join:
	call	T_BStore_ReadCursorByte	; F4B23D  call 0xf40c54
	cp	a, 129	; F4B241  cp A,0x81
	jr	z, CycleRecord_CountTrackBeatMarks_Skip2	; F4B244  jr Z,0xf4b251
	cp	a, 130	; F4B246  cp A,0x82
	jr	z, CycleRecord_CountTrackBeatMarks_Return	; F4B249  jr Z,0xf4b257
CycleRecord_CountTrackBeatMarks_Join2:
	call	CycleRecord_StepCursorOneEvent	; F4B24B  call 0xf4aedd
	jr	CycleRecord_CountTrackBeatMarks_Join	; F4B24F  jr T,0xf4b23d
CycleRecord_CountTrackBeatMarks_Skip2:
	incw	1, (14066:16)	; F4B251  incw 1,(0x36f2)
	jr	CycleRecord_CountTrackBeatMarks_Join2	; F4B255  jr T,0xf4b24b
CycleRecord_CountTrackBeatMarks_Return:
	ret	; F4B257  ret

; --------------------------------------------------------------------------
; CycleRecord_CountBeatsToCycleEnd
; Called from: in-module: 0xF4B1E6
; Touches: (0x0C8A) (0x0D1D)
; Calls:   T_SeqMasterTrack_UpdateActive CycleRecord_CountBeatsToCycleEndFromBeatsPerBar CycleRecord_CountBeatsToCycleEndFromTimeSigs
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4B258 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CountBeatsToCycleEnd: (0x36F4) := the beats up to the cycle end: after SeqMasterTrack_UpdateActive, with
;   MASTER off ((0x0C8A) bit 2 clear) ((0x3624) + 1) x TransportA_BeatsPerBar (CycleRecord_CountBeatsToCycleEndFromBeatsPerBar); with MASTER on, (0x0D1D)
;   := W and CycleRecord_CountBeatsToCycleEndFromTimeSigs takes the time-signature beat count before measure (0x3624) + 1 (CycleRecord_BeatsBeforeMeasureFromTimeSigs). Same shape as
;   CycleRecord_CountCycleRangeBeats, measured from the song start. Basis: caller + caller header + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_w.json)
CycleRecord_CountBeatsToCycleEnd:
	call	T_SeqMasterTrack_UpdateActive	; F4B258  call 0xf40aa8
	bit	2, (0x0c8a:16)	; F4B25C  bit 2,(0x0c8a)
	jr	nz, CycleRecord_CountBeatsToCycleEnd_Skip	; F4B260  jr NZ,0xf4b267
	calr	CycleRecord_CountBeatsToCycleEndFromBeatsPerBar	; F4B262  calr 0xf4b295
	jr	CycleRecord_CountBeatsToCycleEnd_Return	; F4B265  jr T,0xf4b26e
CycleRecord_CountBeatsToCycleEnd_Skip:
	ld	(3357:16), w	; F4B267  ld (0x0d1d),W
	calr	CycleRecord_CountBeatsToCycleEndFromTimeSigs	; F4B26B  calr 0xf4b26f
CycleRecord_CountBeatsToCycleEnd_Return:
	ret	; F4B26E  ret

; --------------------------------------------------------------------------
; CycleRecord_CountBeatsToCycleEndFromTimeSigs
; Called from: in-module: 0xF4B26B
; Touches: (0x0C90) (0x345C) (0x345E) (0x3624) (0x36F4)
; Calls:   CycleRecord_BeatsBeforeMeasureFromTimeSigs
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4B26F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CountBeatsToCycleEndFromTimeSigs: (0x36F4) := beats before measure (0x3624)+1, summed from the master
;   track's time-signature records by CycleRecord_BeatsBeforeMeasureFromTimeSigs (chain (0x0D1D)); BStore cursor kept. The MASTER-on arm of
;   CycleRecord_CountBeatsToCycleEnd. Basis: caller + caller header + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_a8.json)
CycleRecord_CountBeatsToCycleEndFromTimeSigs:
	pushw	(BStore_CursorBlock:16)	; F4B26F  pushw (0x345c)
	pushw	(BStore_CursorOffset:16)	; F4B273  pushw (0x345e)
	ld	bc, (13860:16)	; F4B277  ld BC,(0x3624)
	inc	1, bc	; F4B27B  inc 1,BC
	ld	(3216:16), bc	; F4B27D  ld (0x0c90),BC
	ld	a, w	; F4B281  ld A,W
	pushw	wa	; F4B283  push WA
	calr	CycleRecord_BeatsBeforeMeasureFromTimeSigs	; F4B284  calr 0xf4b771
	popw	wa	; F4B287  pop WA
	popw	(BStore_CursorOffset:16)	; F4B288  popw (0x345e)
	popw	(BStore_CursorBlock:16)	; F4B28C  popw (0x345c)
	ld	(14068:16), ix	; F4B290  ld (0x36f4),IX
	ret	; F4B294  ret

; --------------------------------------------------------------------------
; CycleRecord_CountBeatsToCycleEndFromBeatsPerBar
; Called from: in-module: 0xF4B262
; Touches: (0x3624) (0x36F4)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4B295 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CountBeatsToCycleEndFromBeatsPerBar: (0x36F4) := ((0x3624) + 1) x TransportA_BeatsPerBar, the beats from
;   the song start to the cycle end at one fixed meter. The MASTER-off arm of CycleRecord_CountBeatsToCycleEnd. Basis:
;   caller + caller header + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave8_a8.json)
CycleRecord_CountBeatsToCycleEndFromBeatsPerBar:
	xor	xwa, xwa	; F4B295  xor XWA,XWA
	ld	wa, (13860:16)	; F4B297  ld WA,(0x3624)
	inc	1, wa	; F4B29B  inc 1,WA
	xor	bc, bc	; F4B29D  xor BC,BC
	ld	c, (TransportA_BeatsPerBar:24)	; F4B29F  ld C,(0x605000)
	mul	xwa, bc	; F4B2A4  mul XWA,BC
	ld	(14068:16), wa	; F4B2A6  ld (0x36f4),WA
	ret	; F4B2AA  ret

; --------------------------------------------------------------------------
; CycleRecord_SaveTrackEndCursor
; Called from: in-module: 0xF4B123
; Touches: (0x36D6) (0x36F6) (0x36F8)  |  0x60347E 0x6034A0
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4B2AB is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_SaveTrackEndCursor: (0x36F6)/(0x36F8) := record track (0x36D6)'s end cursor (0x60347E[t] word,
;   0x6034A0[t] byte), taken in CycleRecord_CommitTake after the take's data is complete and before
;   SeqRecord_RestoreCursorBaseline overwrites those arrays; CycleRecord_SetUpSplice later stores it as the splice
;   chain's end (0x3510[t]/0x3532[t]). Basis: caller + body + reader. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_s.json)
CycleRecord_SaveTrackEndCursor:
	ld	xix, 6304894	; F4B2AB  ld XIX,0x0060347e
	xor	xwa, xwa	; F4B2B0  xor XWA,XWA
	ld	a, (14038:16)	; F4B2B2  ld A,(0x36d6)
	sll	xwa, 1	; F4B2B6  sll 0x01,XWA
	add	xix, xwa	; F4B2B9  add XIX,XWA
	ld	wa, (xix)	; F4B2BB  ld WA,(XIX)
	ld	(14070:16), wa	; F4B2BD  ld (0x36f6),WA
	ld	xix, 6304928	; F4B2C1  ld XIX,0x006034a0
	xor	xwa, xwa	; F4B2C6  xor XWA,XWA
	ld	a, (14038:16)	; F4B2C8  ld A,(0x36d6)
	add	xix, xwa	; F4B2CC  add XIX,XWA
	ld	a, (xix)	; F4B2CE  ld A,(XIX)
	ld	(14072:16), a	; F4B2D0  ld (0x36f8),A
	ret	; F4B2D4  ret

; --------------------------------------------------------------------------
; CycleRecord_AppendUnplayedRest
; Called from: in-module: 0xF4B116
; Touches: (0x0C57) (0x0C5D) (0x0C61) (0x0C67) (0x0D4A) (0x36D6)  |
;          0x003460 0x003482 0x60347E 0x6034A0
; Calls:   CycleRecord_SetCopySourceEndAtEndTag CycleRecord_CopyRangeIntoGrowingChain CycleRecord_SetEndCursorAtCopiedEndTag
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4B2D5 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_AppendUnplayedRest: First step of CycleRecord_CommitTake: copies record track (0x36D6)'s bytes from its
;   live cursor (0x3460/0x3482[t], where playback of take chain 2 stopped) up to the 0x82 end tag (CycleRecord_SetCopySourceEndAtEndTag) onto
;   its end cursor (0x60347E/0x6034A0[t], the recorded data's write position) with CycleRecord_CopyRangeIntoGrowingChain, then sets the end
;   cursor on the copied end tag (CycleRecord_SetEndCursorAtCopiedEndTag); failure -> BStore_ErrorCode 0xFF. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_s.json)
CycleRecord_AppendUnplayedRest:
	ld	xix, 13408	; F4B2D5  ld XIX,0x00003460
	xor	xwa, xwa	; F4B2DA  xor XWA,XWA
	ld	a, (14038:16)	; F4B2DC  ld A,(0x36d6)
	sll	xwa, 1	; F4B2E0  sll 0x01,XWA
	add	xix, xwa	; F4B2E3  add XIX,XWA
	ld	wa, (xix)	; F4B2E5  ld WA,(XIX)
	ld	(3169:16), wa	; F4B2E7  ld (0x0c61),WA
	ld	xix, 13442	; F4B2EB  ld XIX,0x00003482
	xor	xwa, xwa	; F4B2F0  xor XWA,XWA
	ld	a, (14038:16)	; F4B2F2  ld A,(0x36d6)
	add	xix, xwa	; F4B2F6  add XIX,XWA
	ld	a, (xix)	; F4B2F8  ld A,(XIX)
	xor	w, w	; F4B2FA  xor W,W
	ld	(3175:16), wa	; F4B2FC  ld (0x0c67),WA
	ld	xix, 6304894	; F4B300  ld XIX,0x0060347e
	xor	xwa, xwa	; F4B305  xor XWA,XWA
	ld	a, (14038:16)	; F4B307  ld A,(0x36d6)
	sll	xwa, 1	; F4B30B  sll 0x01,XWA
	add	xix, xwa	; F4B30E  add XIX,XWA
	ld	wa, (xix)	; F4B310  ld WA,(XIX)
	ld	(3159:16), wa	; F4B312  ld (0x0c57),WA
	ld	xix, 6304928	; F4B316  ld XIX,0x006034a0
	xor	xwa, xwa	; F4B31B  xor XWA,XWA
	ld	a, (14038:16)	; F4B31D  ld A,(0x36d6)
	add	xix, xwa	; F4B321  add XIX,XWA
	ld	a, (xix)	; F4B323  ld A,(XIX)
	xor	w, w	; F4B325  xor W,W
	ld	(3165:16), wa	; F4B327  ld (0x0c5d),WA
	calr	CycleRecord_SetCopySourceEndAtEndTag	; F4B32B  calr 0xf4b342
	call	CycleRecord_CopyRangeIntoGrowingChain	; F4B32E  call 0xf4b462
	cp	(BStore_ErrorCode:16), 0x00	; F4B332  cp (0x0d4a),0x00
	jr	z, CycleRecord_AppendUnplayedRest_Skip	; F4B337  jr Z,0xf4b33e
	ld	(BStore_ErrorCode:16), 255	; F4B339  ld (0x0d4a),0xff
CycleRecord_AppendUnplayedRest_Skip:
	calr	CycleRecord_SetEndCursorAtCopiedEndTag	; F4B33E  calr 0xf4ab0c
	ret	; F4B341  ret

; --------------------------------------------------------------------------
; CycleRecord_SetCopySourceEndAtEndTag
; Called from: in-module: 0xF4B32B
; Touches: (0x0C61) (0x0C67) (0x0C6B) (0x345C) (0x345E)
; Calls:   T_BStore_ReadCursorByte CycleRecord_StepCursorOneEvent
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4B342 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_SetCopySourceEndAtEndTag: From the copy source start (block (0x0C61), offset (0x0C67)) walks event by
;   event (CycleRecord_StepCursorOneEvent) to the 0x82 end tag and makes it the copy's source end: DE := its block, (0x0C6B) := its
;   offset. CycleRecord_AppendUnplayedRest's bound for the copy of the unplayed rest. Basis: caller + caller header +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
CycleRecord_SetCopySourceEndAtEndTag:
	ld	wa, (3169:16)	; F4B342  ld WA,(0x0c61)
	ld	(BStore_CursorBlock:16), wa	; F4B346  ld (0x345c),WA
	ld	wa, (3175:16)	; F4B34A  ld WA,(0x0c67)
	ld	(BStore_CursorOffset:16), wa	; F4B34E  ld (0x345e),WA
CycleRecord_SetCopySourceEndAtEndTag_Join:
	call	T_BStore_ReadCursorByte	; F4B352  call 0xf40c54
	cp	a, 130	; F4B356  cp A,0x82
	jr	z, CycleRecord_SetCopySourceEndAtEndTag_Skip	; F4B359  jr Z,0xf4b361
	call	CycleRecord_StepCursorOneEvent	; F4B35B  call 0xf4aedd
	jr	CycleRecord_SetCopySourceEndAtEndTag_Join	; F4B35F  jr T,0xf4b352
CycleRecord_SetCopySourceEndAtEndTag_Skip:
	ld	de, (BStore_CursorBlock:16)	; F4B361  ld DE,(0x345c)
	ld	wa, (BStore_CursorOffset:16)	; F4B365  ld WA,(0x345e)
	ld	(3179:16), wa	; F4B369  ld (0x0c6b),WA
	ret	; F4B36D  ret

; --------------------------------------------------------------------------
; CycleRecord_SetUpSplice
; Called from: in-module: 0xF4B140
; Touches: (0x345C) (0x345E) (0x34EA) (0x34EC) (0x3548) (0x354A) (0x36D6)
;          (0x36F6) (0x36F8) (0x36FA)  |  0x0034EE 0x003510 0x003532
;          0x00362A 0x00364C 0x00365E +1 more
; Calls:   CycleRecord_StepCursorOneEvent
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4B36E is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_SetUpSplice: Loads the splice parameters for record track t = (0x36D6): (0x34EA)/(0x34EC) := its cycle-
;   start cursor (0x362A/0x364C[t]); (0x3548)/(0x354A) := its cycle-end cursor (0x365E/0x3680[t]) stepped past one
;   event (CycleRecord_StepCursorOneEvent); 0x34EE[t] := the record chain head (0x36FA); 0x3510/0x3532[t] := (0x36F6)/(0x36F8).
;   CycleRecord_CommitTake then runs BStore_SpliceChainIntoTrack (T_BStore_SpliceChainIntoTrack) on them. Basis: caller + body + reader.
;   (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
CycleRecord_SetUpSplice:
	ld	xix, 13866	; F4B36E  ld XIX,0x0000362a
	xor	xwa, xwa	; F4B373  xor XWA,XWA
	ld	a, (14038:16)	; F4B375  ld A,(0x36d6)
	sll	xwa, 1	; F4B379  sll 0x01,XWA
	add	xix, xwa	; F4B37C  add XIX,XWA
	ld	wa, (xix)	; F4B37E  ld WA,(XIX)
	ld	(13546:16), wa	; F4B380  ld (0x34ea),WA
	ld	xix, 13900	; F4B384  ld XIX,0x0000364c
	xor	xwa, xwa	; F4B389  xor XWA,XWA
	ld	a, (14038:16)	; F4B38B  ld A,(0x36d6)
	add	xix, xwa	; F4B38F  add XIX,XWA
	ld	a, (xix)	; F4B391  ld A,(XIX)
	ld	(13548:16), a	; F4B393  ld (0x34ec),A
	ld	xix, 13918	; F4B397  ld XIX,0x0000365e
	xor	xwa, xwa	; F4B39C  xor XWA,XWA
	ld	a, (14038:16)	; F4B39E  ld A,(0x36d6)
	sll	xwa, 1	; F4B3A2  sll 0x01,XWA
	add	xix, xwa	; F4B3A5  add XIX,XWA
	ld	wa, (xix)	; F4B3A7  ld WA,(XIX)
	ld	(BStore_CursorBlock:16), wa	; F4B3A9  ld (0x345c),WA
	ld	xix, 13952	; F4B3AD  ld XIX,0x00003680
	xor	xwa, xwa	; F4B3B2  xor XWA,XWA
	ld	a, (14038:16)	; F4B3B4  ld A,(0x36d6)
	add	xix, xwa	; F4B3B8  add XIX,XWA
	ld	a, (xix)	; F4B3BA  ld A,(XIX)
	ld	(BStore_CursorOffset:16), a	; F4B3BC  ld (0x345e),A
	call	CycleRecord_StepCursorOneEvent	; F4B3C0  call 0xf4aedd
	ld	wa, (BStore_CursorBlock:16)	; F4B3C4  ld WA,(0x345c)
	ld	(13640:16), wa	; F4B3C8  ld (0x3548),WA
	ld	a, (BStore_CursorOffset:16)	; F4B3CC  ld A,(0x345e)
	ld	(13642:16), a	; F4B3D0  ld (0x354a),A
	ld	xix, 13550	; F4B3D4  ld XIX,0x000034ee
	xor	xwa, xwa	; F4B3D9  xor XWA,XWA
	ld	a, (14038:16)	; F4B3DB  ld A,(0x36d6)
	sll	xwa, 1	; F4B3DF  sll 0x01,XWA
	add	xix, xwa	; F4B3E2  add XIX,XWA
	ld	wa, (14074:16)	; F4B3E4  ld WA,(0x36fa)
	ld	(xix), wa	; F4B3E8  ld (XIX),WA
	ld	xix, 13584	; F4B3EA  ld XIX,0x00003510
	xor	xwa, xwa	; F4B3EF  xor XWA,XWA
	ld	a, (14038:16)	; F4B3F1  ld A,(0x36d6)
	sll	xwa, 1	; F4B3F5  sll 0x01,XWA
	add	xix, xwa	; F4B3F8  add XIX,XWA
	ld	wa, (14070:16)	; F4B3FA  ld WA,(0x36f6)
	ld	(xix), wa	; F4B3FE  ld (XIX),WA
	ld	xix, 13618	; F4B400  ld XIX,0x00003532
	xor	xwa, xwa	; F4B405  xor XWA,XWA
	ld	a, (14038:16)	; F4B407  ld A,(0x36d6)
	add	xix, xwa	; F4B40B  add XIX,XWA
	ld	a, (14072:16)	; F4B40D  ld A,(0x36f8)
	ld	(xix), a	; F4B411  ld (XIX),A
	ret	; F4B413  ret

; --------------------------------------------------------------------------
; SeqRecord_RestoreCursorBaseline
; Called from: T_SeqRecord_RestoreCursorBaseline (x3); in-module: 0xF4A5B5 0xF4AFD9 0xF4B126 0xF4B153
; Touches:   |  0x0036FE 0x003720 0x60347E 0x6034A0
; Evidence: thunk slot T_SeqRecord_RestoreCursorBaseline holds `jp 0x00F4B414`, and 0xF4B414 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_RestoreCursorBaseline: Inverse of SeqRecord_CopyTrackCursorsToBaseline: the 17 workspace track cursors
;   0x60347E (words) / 0x6034A0 (bytes) := the baseline 0x36FE / 0x3720 saved on entering REALTIME RECORD.
;   LcdKeyRow2_RealtimeRecordScreen runs it when it turns CYCLE record off; CycleRecord_RestartPass (cycle-record setup) and
;   SeqRecord_EndTake before each pass. Basis: callers + body + inverse. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_n.json)
SeqRecord_RestoreCursorBaseline:		; <- T_SeqRecord_RestoreCursorBaseline
	ldw	bc, 17	; F4B414  ld BC,0x0011
	ld	xde, 6304894	; F4B417  ld XDE,0x0060347e
	ld	xhl, 14078	; F4B41C  ld XHL,0x000036fe
	ldirw93	; F4B421  ldirw
	ldw	bc, 17	; F4B423  ld BC,0x0011
	ld	xde, 6304928	; F4B426  ld XDE,0x006034a0
	ld	xhl, 14112	; F4B42B  ld XHL,0x00003720
	ldir83	; F4B430  ldir
	ret	; F4B432  ret

; --------------------------------------------------------------------------
; sub_F4B433
; Called from: in-module: 0xF4AF83
; Touches: (0x345C) (0x345E) (0x36F2) (0x36FA)
; Calls:   T_BStore_ReadCursorByte CycleRecord_StepCursorOneEvent
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4B433 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4B433:
	ld	wa, (14074:16)	; F4B433  ld WA,(0x36fa)
	ld	(BStore_CursorBlock:16), wa	; F4B437  ld (0x345c),WA
	ldw	(BStore_CursorOffset:16), 5	; F4B43B  ld (0x345e),0x0005
	ldw	(14066:16), 0	; F4B441  ld (0x36f2),0x0000
sub_F4B433_Join:
	call	T_BStore_ReadCursorByte	; F4B447  call 0xf40c54
	cp	a, 129	; F4B44B  cp A,0x81
	jr	z, sub_F4B433_Skip	; F4B44E  jr Z,0xf4b45b
	cp	a, 130	; F4B450  cp A,0x82
	jr	z, sub_F4B433_Return	; F4B453  jr Z,0xf4b461
sub_F4B433_Join2:
	call	CycleRecord_StepCursorOneEvent	; F4B455  call 0xf4aedd
	jr	sub_F4B433_Join	; F4B459  jr T,0xf4b447
sub_F4B433_Skip:
	incw	1, (14066:16)	; F4B45B  incw 1,(0x36f2)
	jr	sub_F4B433_Join2	; F4B45F  jr T,0xf4b455
sub_F4B433_Return:
	ret	; F4B461  ret

; --------------------------------------------------------------------------
; CycleRecord_CopyRangeIntoGrowingChain
; Called from: in-module: 0xF4AA16 0xF4AAC0 0xF4B32E
; Touches: (0x0C57) (0x0C59) (0x0C5D) (0x0C61) (0x0C63) (0x0C67) (0x0C6B)
;          (0x0C96) (0x0C98) (0x0C9A) +4 more
; Calls:   BStore_SetCursorBlockAddr T_BStore_CopyAcrossBlocks CycleRecord_StepCopySrcToNextBlock CycleRecord_StepCopyDestToNextBlockOrAlloc
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4B462 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CopyRangeIntoGrowingChain: Forward copy of chain bytes from block (0x0C61) / offset (0x0C67) through
;   block DE / offset (0x0C6B) to block (0x0C57) / offset (0x0C5D) (T_BStore_CopyAcrossBlocks); the source follows its
;   +3 links (CycleRecord_StepCopySrcToNextBlock, error 11 on a free block), the destination too but at a chain end allocates and links a new
;   block (CycleRecord_StepCopyDestToNextBlockOrAlloc). sub_F62DC9 (BStore_CopyRangeForward_Call) is the same copy without the allocation. Basis:
;   callers + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
CycleRecord_CopyRangeIntoGrowingChain:
	ld	(BStore_ErrorCode:16), 0	; F4B462  ld (0x0d4a),0x00
	ld	hl, (3169:16)	; F4B467  ld HL,(0x0c61)
	calr	BStore_SetCursorBlockAddr	; F4B46B  calr 0xf4b75f
	push	xwa	; F4B46E  push XWA
	ld	xwa, (BStore_CursorBlockAddr:16)	; F4B46F  ld XWA,(0x126e)
	ld	(BStore_CopySrcAddr:16), xwa	; F4B473  ld (0x0c63),XWA
	ld	hl, (3159:16)	; F4B477  ld HL,(0x0c57)
	calr	BStore_SetCursorBlockAddr	; F4B47B  calr 0xf4b75f
	ld	xwa, (BStore_CursorBlockAddr:16)	; F4B47E  ld XWA,(0x126e)
	ld	(BStore_CopyDestAddr:16), xwa	; F4B482  ld (0x0c59),XWA
	pop	xwa	; F4B486  pop XWA
	cp	de, (0x0c61:16)	; F4B487  cp DE,(0x0c61)
	jr	nz, CycleRecord_CopyRangeIntoGrowingChain_Skip	; F4B48B  jr NZ,0xf4b4ae
	ldw	iy, 256	; F4B48D  ld IY,0x0100
	sub	iy, (0x0c67:16)	; F4B490  sub IY,(0x0c67)
	ld	(3226:16), iy	; F4B494  ld (0x0c9a),IY
	ld	iy, (3175:16)	; F4B498  ld IY,(0x0c67)
	ldw	ix, 256	; F4B49C  ld IX,0x0100
	sub	ix, (0x0c5d:16)	; F4B49F  sub IX,(0x0c5d)
	ld	(3228:16), ix	; F4B4A3  ld (0x0c9c),IX
	ld	ix, (3165:16)	; F4B4A7  ld IX,(0x0c5d)
	jrl	CycleRecord_CopyRangeIntoGrowingChain_Join7	; F4B4AB  jrl T,0xf4b65e
CycleRecord_CopyRangeIntoGrowingChain_Skip:
	ld	wa, (3165:16)	; F4B4AE  ld WA,(0x0c5d)
	cp	wa, (0x0c67:16)	; F4B4B2  cp WA,(0x0c67)
	jr	c, CycleRecord_CopyRangeIntoGrowingChain_Skip2	; F4B4B6  jr C,0xf4b4bc
	jr	z, CycleRecord_CopyRangeIntoGrowingChain_Skip3	; F4B4B8  jr Z,0xf4b4be
	jr	ugt, CycleRecord_CopyRangeIntoGrowingChain_Skip4	; F4B4BA  jr UGT,0xf4b4c1
CycleRecord_CopyRangeIntoGrowingChain_Skip2:
	jr	CycleRecord_CopyRangeIntoGrowingChain_Join	; F4B4BC  jr T,0xf4b4c4
CycleRecord_CopyRangeIntoGrowingChain_Skip3:
	jrl	CycleRecord_CopyRangeIntoGrowingChain_Join3	; F4B4BE  jrl T,0xf4b550
CycleRecord_CopyRangeIntoGrowingChain_Skip4:
	jrl	CycleRecord_CopyRangeIntoGrowingChain_Join5	; F4B4C1  jrl T,0xf4b5c0
CycleRecord_CopyRangeIntoGrowingChain_Join:
	ldw	wa, 256	; F4B4C4  ld WA,0x0100
	sub	wa, (0x0c5d:16)	; F4B4C7  sub WA,(0x0c5d)
	ldw	bc, 256	; F4B4CB  ld BC,0x0100
	sub	bc, (0x0c67:16)	; F4B4CE  sub BC,(0x0c67)
	sub	wa, bc	; F4B4D2  sub WA,BC
	ld	(3222:16), wa	; F4B4D4  ld (0x0c96),WA
	ldw	bc, 256	; F4B4D8  ld BC,0x0100
	sub	bc, 5	; F4B4DB  sub BC,0x0005
	sub	bc, wa	; F4B4DF  sub BC,WA
	ld	(3224:16), bc	; F4B4E1  ld (0x0c98),BC
	ld	iy, (3175:16)	; F4B4E5  ld IY,(0x0c67)
	ld	ix, (3165:16)	; F4B4E9  ld IX,(0x0c5d)
	ldw	bc, 256	; F4B4ED  ld BC,0x0100
	sub	bc, (0x0c67:16)	; F4B4F0  sub BC,(0x0c67)
	call	T_BStore_CopyAcrossBlocks	; F4B4F4  call 0xf427c0
	call	CycleRecord_StepCopySrcToNextBlock	; F4B4F8  call 0xf4b726
	cp	(BStore_ErrorCode:16), 0x00	; F4B4FC  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyRangeIntoGrowingChain_Loop	; F4B501  jr Z,0xf4b506
	jrl	CycleRecord_CopyRangeIntoGrowingChain_Return	; F4B503  jrl T,0xf4b69e
CycleRecord_CopyRangeIntoGrowingChain_Loop:
	cp	de, (0x0c61:16)	; F4B506  cp DE,(0x0c61)
	jr	nz, CycleRecord_CopyRangeIntoGrowingChain_Skip5	; F4B50A  jr NZ,0xf4b50e
	jr	CycleRecord_CopyRangeIntoGrowingChain_Join2	; F4B50C  jr T,0xf4b53a
CycleRecord_CopyRangeIntoGrowingChain_Skip5:
	ld	bc, (3222:16)	; F4B50E  ld BC,(0x0c96)
	call	T_BStore_CopyAcrossBlocks	; F4B512  call 0xf427c0
	call	CycleRecord_StepCopyDestToNextBlockOrAlloc	; F4B516  call 0xf4b69f
	cp	(BStore_ErrorCode:16), 0x00	; F4B51A  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyRangeIntoGrowingChain_Skip6	; F4B51F  jr Z,0xf4b524
	jrl	CycleRecord_CopyRangeIntoGrowingChain_Return	; F4B521  jrl T,0xf4b69e
CycleRecord_CopyRangeIntoGrowingChain_Skip6:
	ld	bc, (3224:16)	; F4B524  ld BC,(0x0c98)
	call	T_BStore_CopyAcrossBlocks	; F4B528  call 0xf427c0
	call	CycleRecord_StepCopySrcToNextBlock	; F4B52C  call 0xf4b726
	cp	(BStore_ErrorCode:16), 0x00	; F4B530  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyRangeIntoGrowingChain_Loop	; F4B535  jr Z,0xf4b506
	jrl	CycleRecord_CopyRangeIntoGrowingChain_Return	; F4B537  jrl T,0xf4b69e
CycleRecord_CopyRangeIntoGrowingChain_Join2:
	ld	wa, (3222:16)	; F4B53A  ld WA,(0x0c96)
	ld	(3228:16), wa	; F4B53E  ld (0x0c9c),WA
	ldw	bc, 256	; F4B542  ld BC,0x0100
	sub	bc, 5	; F4B545  sub BC,0x0005
	ld	(3226:16), bc	; F4B549  ld (0x0c9a),BC
	jrl	CycleRecord_CopyRangeIntoGrowingChain_Join7	; F4B54D  jrl T,0xf4b65e
CycleRecord_CopyRangeIntoGrowingChain_Join3:
	ldw	bc, 256	; F4B550  ld BC,0x0100
	sub	bc, (0x0c67:16)	; F4B553  sub BC,(0x0c67)
	ld	iy, (3175:16)	; F4B557  ld IY,(0x0c67)
	ld	ix, (3165:16)	; F4B55B  ld IX,(0x0c5d)
	call	T_BStore_CopyAcrossBlocks	; F4B55F  call 0xf427c0
	call	CycleRecord_StepCopySrcToNextBlock	; F4B563  call 0xf4b726
	cp	(BStore_ErrorCode:16), 0x00	; F4B567  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyRangeIntoGrowingChain_Skip7	; F4B56C  jr Z,0xf4b571
	jrl	CycleRecord_CopyRangeIntoGrowingChain_Return	; F4B56E  jrl T,0xf4b69e
CycleRecord_CopyRangeIntoGrowingChain_Skip7:
	call	CycleRecord_StepCopyDestToNextBlockOrAlloc	; F4B571  call 0xf4b69f
	cp	(BStore_ErrorCode:16), 0x00	; F4B575  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyRangeIntoGrowingChain_Loop2	; F4B57A  jr Z,0xf4b57f
	jrl	CycleRecord_CopyRangeIntoGrowingChain_Return	; F4B57C  jrl T,0xf4b69e
CycleRecord_CopyRangeIntoGrowingChain_Loop2:
	cp	de, (0x0c61:16)	; F4B57F  cp DE,(0x0c61)
	jr	nz, CycleRecord_CopyRangeIntoGrowingChain_Skip8	; F4B583  jr NZ,0xf4b587
	jr	CycleRecord_CopyRangeIntoGrowingChain_Join4	; F4B585  jr T,0xf4b5ae
CycleRecord_CopyRangeIntoGrowingChain_Skip8:
	ldw	bc, 256	; F4B587  ld BC,0x0100
	sub	bc, 5	; F4B58A  sub BC,0x0005
	call	T_BStore_CopyAcrossBlocks	; F4B58E  call 0xf427c0
	call	CycleRecord_StepCopySrcToNextBlock	; F4B592  call 0xf4b726
	cp	(BStore_ErrorCode:16), 0x00	; F4B596  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyRangeIntoGrowingChain_Skip9	; F4B59B  jr Z,0xf4b5a0
	jrl	CycleRecord_CopyRangeIntoGrowingChain_Return	; F4B59D  jrl T,0xf4b69e
CycleRecord_CopyRangeIntoGrowingChain_Skip9:
	call	CycleRecord_StepCopyDestToNextBlockOrAlloc	; F4B5A0  call 0xf4b69f
	cp	(BStore_ErrorCode:16), 0x00	; F4B5A4  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyRangeIntoGrowingChain_Loop2	; F4B5A9  jr Z,0xf4b57f
	jrl	CycleRecord_CopyRangeIntoGrowingChain_Return	; F4B5AB  jrl T,0xf4b69e
CycleRecord_CopyRangeIntoGrowingChain_Join4:
	ldw	bc, 256	; F4B5AE  ld BC,0x0100
	sub	bc, 5	; F4B5B1  sub BC,0x0005
	ld	(3228:16), bc	; F4B5B5  ld (0x0c9c),BC
	ld	(3226:16), bc	; F4B5B9  ld (0x0c9a),BC
	jrl	CycleRecord_CopyRangeIntoGrowingChain_Join7	; F4B5BD  jrl T,0xf4b65e
CycleRecord_CopyRangeIntoGrowingChain_Join5:
	ldw	wa, 256	; F4B5C0  ld WA,0x0100
	sub	wa, (0x0c67:16)	; F4B5C3  sub WA,(0x0c67)
	ldw	bc, 256	; F4B5C7  ld BC,0x0100
	sub	bc, (0x0c5d:16)	; F4B5CA  sub BC,(0x0c5d)
	sub	wa, bc	; F4B5CE  sub WA,BC
	ld	(3222:16), wa	; F4B5D0  ld (0x0c96),WA
	ldw	bc, 256	; F4B5D4  ld BC,0x0100
	sub	bc, 5	; F4B5D7  sub BC,0x0005
	sub	bc, wa	; F4B5DB  sub BC,WA
	ld	(3224:16), bc	; F4B5DD  ld (0x0c98),BC
	ld	iy, (3175:16)	; F4B5E1  ld IY,(0x0c67)
	ld	ix, (3165:16)	; F4B5E5  ld IX,(0x0c5d)
	ldw	bc, 256	; F4B5E9  ld BC,0x0100
	sub	bc, (0x0c5d:16)	; F4B5EC  sub BC,(0x0c5d)
	call	T_BStore_CopyAcrossBlocks	; F4B5F0  call 0xf427c0
	call	CycleRecord_StepCopyDestToNextBlockOrAlloc	; F4B5F4  call 0xf4b69f
	cp	(BStore_ErrorCode:16), 0x00	; F4B5F8  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyRangeIntoGrowingChain_Skip10	; F4B5FD  jr Z,0xf4b602
	jrl	CycleRecord_CopyRangeIntoGrowingChain_Return	; F4B5FF  jrl T,0xf4b69e
CycleRecord_CopyRangeIntoGrowingChain_Skip10:
	ld	bc, (3222:16)	; F4B602  ld BC,(0x0c96)
	call	T_BStore_CopyAcrossBlocks	; F4B606  call 0xf427c0
	call	CycleRecord_StepCopySrcToNextBlock	; F4B60A  call 0xf4b726
	cp	(BStore_ErrorCode:16), 0x00	; F4B60E  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyRangeIntoGrowingChain_Loop3	; F4B613  jr Z,0xf4b618
	jrl	CycleRecord_CopyRangeIntoGrowingChain_Return	; F4B615  jrl T,0xf4b69e
CycleRecord_CopyRangeIntoGrowingChain_Loop3:
	cp	de, (0x0c61:16)	; F4B618  cp DE,(0x0c61)
	jr	nz, CycleRecord_CopyRangeIntoGrowingChain_Skip11	; F4B61C  jr NZ,0xf4b620
	jr	CycleRecord_CopyRangeIntoGrowingChain_Join6	; F4B61E  jr T,0xf4b64b
CycleRecord_CopyRangeIntoGrowingChain_Skip11:
	ld	bc, (3224:16)	; F4B620  ld BC,(0x0c98)
	call	T_BStore_CopyAcrossBlocks	; F4B624  call 0xf427c0
	call	CycleRecord_StepCopyDestToNextBlockOrAlloc	; F4B628  call 0xf4b69f
	cp	(BStore_ErrorCode:16), 0x00	; F4B62C  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyRangeIntoGrowingChain_Skip12	; F4B631  jr Z,0xf4b636
	jrl	CycleRecord_CopyRangeIntoGrowingChain_Return	; F4B633  jrl T,0xf4b69e
CycleRecord_CopyRangeIntoGrowingChain_Skip12:
	ld	bc, (3222:16)	; F4B636  ld BC,(0x0c96)
	call	T_BStore_CopyAcrossBlocks	; F4B63A  call 0xf427c0
	call	CycleRecord_StepCopySrcToNextBlock	; F4B63E  call 0xf4b726
	cp	(BStore_ErrorCode:16), 0x00	; F4B642  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyRangeIntoGrowingChain_Loop3	; F4B647  jr Z,0xf4b618
	jr	CycleRecord_CopyRangeIntoGrowingChain_Return	; F4B649  jr T,0xf4b69e
CycleRecord_CopyRangeIntoGrowingChain_Join6:
	ld	wa, (3224:16)	; F4B64B  ld WA,(0x0c98)
	ld	(3228:16), wa	; F4B64F  ld (0x0c9c),WA
	ldw	wa, 256	; F4B653  ld WA,0x0100
	sub	wa, 5	; F4B656  sub WA,0x0005
	ld	(3226:16), wa	; F4B65A  ld (0x0c9a),WA
CycleRecord_CopyRangeIntoGrowingChain_Join7:
	ldw	wa, 255	; F4B65E  ld WA,0x00ff
	sub	wa, (0x0c6b:16)	; F4B661  sub WA,(0x0c6b)
	ld	bc, (3226:16)	; F4B665  ld BC,(0x0c9a)
	sub	bc, wa	; F4B669  sub BC,WA
	ld	(3232:16), bc	; F4B66B  ld (0x0ca0),BC
	cp	(0x0c9c:16), bc	; F4B66F  cp (0x0c9c),BC
	jr	ugt, CycleRecord_CopyRangeIntoGrowingChain_Skip13	; F4B673  jr UGT,0xf4b677
	jr	CycleRecord_CopyRangeIntoGrowingChain_Join8	; F4B675  jr T,0xf4b67d
CycleRecord_CopyRangeIntoGrowingChain_Skip13:
	call	T_BStore_CopyAcrossBlocks	; F4B677  call 0xf427c0
	jr	CycleRecord_CopyRangeIntoGrowingChain_Return	; F4B67B  jr T,0xf4b69e
CycleRecord_CopyRangeIntoGrowingChain_Join8:
	ld	bc, (3228:16)	; F4B67D  ld BC,(0x0c9c)
	call	T_BStore_CopyAcrossBlocks	; F4B681  call 0xf427c0
	call	CycleRecord_StepCopyDestToNextBlockOrAlloc	; F4B685  call 0xf4b69f
	cp	(BStore_ErrorCode:16), 0x00	; F4B689  cp (0x0d4a),0x00
	jr	z, CycleRecord_CopyRangeIntoGrowingChain_Skip14	; F4B68E  jr Z,0xf4b692
	jr	CycleRecord_CopyRangeIntoGrowingChain_Return	; F4B690  jr T,0xf4b69e
CycleRecord_CopyRangeIntoGrowingChain_Skip14:
	ld	bc, (3232:16)	; F4B692  ld BC,(0x0ca0)
	sub	bc, (0x0c9c:16)	; F4B696  sub BC,(0x0c9c)
	call	T_BStore_CopyAcrossBlocks	; F4B69A  call 0xf427c0
CycleRecord_CopyRangeIntoGrowingChain_Return:
	ret	; F4B69E  ret

; --------------------------------------------------------------------------
; CycleRecord_StepCopyDestToNextBlockOrAlloc
; Called from: in-module: 0xF4B516 0xF4B571 0xF4B5A0 0xF4B5F4 0xF4B628
;              0xF4B685
; Touches: (0x0C57) (0x0C59) (0x0D4A) (0x126E) (0x3604) (0x373E)
; Calls:   T_BStore_AllocBlock_B_Veneer T_BStore_BlockAddrFromHL
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4B69F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_StepCopyDestToNextBlockOrAlloc: Moves the copy destination (BStore_CopyDestAddr, block (0x0C57)) to its
;   +3 next block; at the chain end (0xFFFF) allocates one (none free / not in use -> error 11), marks it in use,
;   links it (+1 = old block, old +3 = new, +3 = 0xFFFF); IX = 5. CycleRecord_CopyRangeIntoGrowingChain's destination
;   step. Basis: caller + caller header + body. (notes/naming-pilot-2026-10-06/proposals_wave8_a8.json)
CycleRecord_StepCopyDestToNextBlockOrAlloc:
	xor	xix, xix	; F4B69F  xor XIX,XIX
	ld	wa, (3159:16)	; F4B6A1  ld WA,(0x0c57)
	ld	(14142:16), wa	; F4B6A5  ld (0x373e),WA
	ld	xix, (BStore_CopyDestAddr:16)	; F4B6A9  ld XIX,(0x0c59)
	ld	(BStore_CursorBlockAddr:16), xix	; F4B6AD  ld (0x126e),XIX
	ld	wa, (xix+3)	; F4B6B1  ld WA,(XIX+0x03)
	ld	(3159:16), wa	; F4B6B4  ld (0x0c57),WA
	cp	wa, 65535	; F4B6B8  cp WA,0xffff
	jr	nz, CycleRecord_StepCopyDestToNextBlockOrAlloc_Skip	; F4B6BC  jr NZ,0xf4b6fe
	cpw	(BStore_FreeCount:24), 0x0000	; F4B6BE  cp (0x6034ba),0x0000
	jr	z, CycleRecord_StepCopyDestToNextBlockOrAlloc_Skip2	; F4B6C5  jr Z,0xf4b713
	ld	wa, (BStore_FreeHead:24)	; F4B6C7  ld WA,(0x6034b8)
	ld	(3159:16), wa	; F4B6CC  ld (0x0c57),WA
	push	xiy	; F4B6D0  push XIY
	push	xix	; F4B6D1  push XIX
	push	xwa	; F4B6D2  push XWA
	call	T_BStore_AllocBlock_B_Veneer	; F4B6D3  call 0xf40c88
	ld	hl, ix	; F4B6D7  ld HL,IX
	call	T_BStore_BlockAddrFromHL	; F4B6D9  call 0xf40c84
	or	(xhl), 0x80	; F4B6DD  or (XHL),0x80
	ld	wa, (14142:16)	; F4B6E0  ld WA,(0x373e)
	ld	(xhl+1), wa	; F4B6E4  ld (XHL+0x01),WA
	ldw	(xhl+3), 0xffff	; F4B6E7  ld (XHL+0x03),0xffff
	ld	hl, (14142:16)	; F4B6EC  ld HL,(0x373e)
	call	T_BStore_BlockAddrFromHL	; F4B6F0  call 0xf40c84
	ld	wa, (3159:16)	; F4B6F4  ld WA,(0x0c57)
	ld	(xhl+3), wa	; F4B6F8  ld (XHL+0x03),WA
	pop	xwa	; F4B6FB  pop XWA
	pop	xix	; F4B6FC  pop XIX
	pop	xiy	; F4B6FD  pop XIY
CycleRecord_StepCopyDestToNextBlockOrAlloc_Skip:
	extz	xwa	; F4B6FE  extz XWA
	dec	1, xwa	; F4B700  dec 1,XWA
	sla	xwa, 8	; F4B702  sla 0x08,XWA
	add	xwa, (BStore_HeapBase:16)	; F4B705  add XWA,(0x3604)
	ld	(BStore_CursorBlockAddr:16), xwa	; F4B709  ld (0x126e),XWA
	bit	7, (xix)	; F4B70D  bit 7,(XIX)
	bit	7, (xwa)	; F4B70F  bit 7,(XWA)
	jr	nz, CycleRecord_StepCopyDestToNextBlockOrAlloc_Skip3	; F4B711  jr NZ,0xf4b71a
CycleRecord_StepCopyDestToNextBlockOrAlloc_Skip2:
	ld	(BStore_ErrorCode:16), 11	; F4B713  ld (0x0d4a),0x0b
	jr	CycleRecord_StepCopyDestToNextBlockOrAlloc_Return	; F4B718  jr T,0xf4b725
CycleRecord_StepCopyDestToNextBlockOrAlloc_Skip3:
	ld	xwa, (BStore_CursorBlockAddr:16)	; F4B71A  ld XWA,(0x126e)
	ld	(BStore_CopyDestAddr:16), xwa	; F4B71E  ld (0x0c59),XWA
	ldw	ix, 5	; F4B722  ld IX,0x0005
CycleRecord_StepCopyDestToNextBlockOrAlloc_Return:
	ret	; F4B725  ret

; --------------------------------------------------------------------------
; CycleRecord_StepCopySrcToNextBlock
; Called from: in-module: 0xF4B4F8 0xF4B52C 0xF4B563 0xF4B592 0xF4B60A
;              0xF4B63E
; Touches: (0x0C61) (0x0C63) (0x0CA6) (0x0D4A) (0x126E) (0x3604)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4B726 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_StepCopySrcToNextBlock: Moves the copy source (BStore_CopySrcAddr) to its +3 next block ((0x0C61) := its
;   number, (0x126E) := its address; not in use -> error 11), IY = 5. CycleRecord_CopyRangeIntoGrowingChain's source
;   step; an exact copy of the BStore copy's source step CycleRecord_StepCopySrcToNextBlock_Copy. Basis: caller + caller header + body + twin.
;   (notes/naming-pilot-2026-10-06/proposals_wave8_a8.json)
CycleRecord_StepCopySrcToNextBlock:
	xor	iy, iy	; F4B726  xor IY,IY
	ld	xiy, (BStore_CopySrcAddr:16)	; F4B728  ld XIY,(0x0c63)
	ld	(BStore_GeomBase:16), xiy	; F4B72C  ld (0x0ca6),XIY
	ld	wa, (xiy+3)	; F4B730  ld WA,(XIY+0x03)
	ld	(3169:16), wa	; F4B733  ld (0x0c61),WA
	extz	xwa	; F4B737  extz XWA
	dec	1, xwa	; F4B739  dec 1,XWA
	sla	xwa, 8	; F4B73B  sla 0x08,XWA
	add	xwa, (BStore_HeapBase:16)	; F4B73E  add XWA,(0x3604)
	ld	(BStore_CursorBlockAddr:16), xwa	; F4B742  ld (0x126e),XWA
	bit	7, (xwa)	; F4B746  bit 7,(XWA)
	jr	nz, CycleRecord_StepCopySrcToNextBlock_Skip	; F4B748  jr NZ,0xf4b751
	ld	(BStore_ErrorCode:16), 11	; F4B74A  ld (0x0d4a),0x0b
	jr	CycleRecord_StepCopySrcToNextBlock_Return	; F4B74F  jr T,0xf4b75e
CycleRecord_StepCopySrcToNextBlock_Skip:
	push	xwa	; F4B751  push XWA
	ld	xwa, (BStore_CursorBlockAddr:16)	; F4B752  ld XWA,(0x126e)
	ld	(BStore_CopySrcAddr:16), xwa	; F4B756  ld (0x0c63),XWA
	pop	xwa	; F4B75A  pop XWA
	ldw	iy, 5	; F4B75B  ld IY,0x0005
CycleRecord_StepCopySrcToNextBlock_Return:
	ret	; F4B75E  ret

; --------------------------------------------------------------------------
; BStore_SetCursorBlockAddr
; Called from: in-module: 0xF4B46B 0xF4B47B
; Touches: (0x126E) (0x3604)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4B75F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_SetCursorBlockAddr(HL = block number): BStore_CursorBlockAddr = BStore_HeapBase + (HL - 1) * 256; XHL = 0.
BStore_SetCursorBlockAddr:
	dec	1, hl	; F4B75F  dec 1,HL
	extz	xhl	; F4B761  extz XHL
	sla	xhl, 8	; F4B763  sla 0x08,XHL
	add	xhl, (BStore_HeapBase:16)	; F4B766  add XHL,(0x3604)
	ld	(BStore_CursorBlockAddr:16), xhl	; F4B76A  ld (0x126e),XHL
	xor	xhl, xhl	; F4B76E  xor XHL,XHL
	ret	; F4B770  ret

; --------------------------------------------------------------------------
; CycleRecord_BeatsBeforeMeasureFromTimeSigs
; Called from: in-module: 0xF4A8B6 0xF4A8D9 0xF4B284
; Touches: (0x0C8A) (0x0D1C) (0x374A)
; Calls:   T_BStore_TimeSigFirstMeasure T_F427A8
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4B771 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_BeatsBeforeMeasureFromTimeSigs: IX := the beats in measures 1..BC-1 (BC capped at 1000), summed from the
;   master track's time signatures: BStore_TimeSigFirstMeasure, then per measure IX += (0x0D1C) and T_F427A8
;   (sub_F63749, next measure's meter) until the walk hits the end ((0x0C8A) bit 5). The helper of both
;   CycleRecord_*FromTimeSigs routines. Basis: callers + callers' headers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_d9.json)
CycleRecord_BeatsBeforeMeasureFromTimeSigs:
	cp	bc, 1000	; F4B771  cp BC,0x03e8
	jr	ule, CycleRecord_BeatsBeforeMeasureFromTimeSigs_Skip	; F4B775  jr ULE,0xf4b77a
	ldw	bc, 1000	; F4B777  ld BC,0x03e8
CycleRecord_BeatsBeforeMeasureFromTimeSigs_Skip:
	xor	xix, xix	; F4B77A  xor XIX,XIX
	ldw	(14154:16), 1	; F4B77C  ld (0x374a),0x0001
	pushw	ix	; F4B782  push IX
	pushw	bc	; F4B783  push BC
	call	T_BStore_TimeSigFirstMeasure	; F4B784  call 0xf427a4
	popw	bc	; F4B788  pop BC
	popw	ix	; F4B789  pop IX
CycleRecord_BeatsBeforeMeasureFromTimeSigs_Loop:
	cp	(0x374a:16), bc	; F4B78A  cp (0x374a),BC
	jr	nc, CycleRecord_BeatsBeforeMeasureFromTimeSigs_Return	; F4B78E  jr NC,0xf4b7ac
	incw	1, (14154:16)	; F4B790  incw 1,(0x374a)
	xor	wa, wa	; F4B794  xor WA,WA
	ld	a, (3356:16)	; F4B796  ld A,(0x0d1c)
	add	ix, wa	; F4B79A  add IX,WA
	bit	5, (0x0c8a:16)	; F4B79C  bit 5,(0x0c8a)
	jr	nz, CycleRecord_BeatsBeforeMeasureFromTimeSigs_Loop	; F4B7A0  jr NZ,0xf4b78a
	pushw	ix	; F4B7A2  push IX
	pushw	bc	; F4B7A3  push BC
	call	T_F427A8	; F4B7A4  call 0xf427a8
	popw	bc	; F4B7A8  pop BC
	popw	ix	; F4B7A9  pop IX
	jr	CycleRecord_BeatsBeforeMeasureFromTimeSigs_Loop	; F4B7AA  jr T,0xf4b78a
CycleRecord_BeatsBeforeMeasureFromTimeSigs_Return:
	ret	; F4B7AC  ret

; --------------------------------------------------------------------------
; IdentityMap_F4B7AD -- 32 bytes, and entry k = k for every k.  The name
;                       describes the CONTENT and claims nothing about the
;                       purpose.
; Read by: one site: `ld XIX,0x00f4b7ad` at 0xF4A533.  (The byte scan for
;          the address hits 0xF4A534, which is that instruction's OPERAND
;          field, 1 byte in.)
; Entry count: 32, from the island's own extent: the next byte, 0xF4B7CD,
;              opens the 0x0E padding run that closes the module.
; Evidence: all 32 bytes are re-read and compared with 0..31 on every emit.
; Unknown: why an identity map exists at all.  A table that returns its own
;          index changes nothing at run time.  prom_b has a THIRD one at
;          0xF5EE75 (IdentityMap_0_31, converted in round 2) with the same
;          content and the same open question; three copies is a fact this
;          records, not an explanation.
; --------------------------------------------------------------------------
IdentityMap_F4B7AD:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F4B7AD  [0..15]
	.byte	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F	; F4B7BD  [16..31]

	.fill	2099, 1, 0x0E	; F4B7CD-F4BFFF  `ret` padding (asserted pure 0x0E)
