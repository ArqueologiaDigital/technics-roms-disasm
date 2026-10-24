

; --------------------------------------------------------------------------
; sub_F4E000
; Called from: T_F40CB0 (x0)
; Touches: (0x2078) (0x207A) (0x20B8)
; Calls:   sub_F4E029
; Evidence: thunk slot T_F40CB0 holds `jp 0x00F4E000`, and 0xF4E000 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4E000:		; <- T_F40CB0
	cp	(PanelMode:16), 0x0c	; F4E000  cp (0x2078),0x0c
	jr	z, sub_F4D935_Return	; F4E005  jr Z,0xf4e028
	cp	(PanelMode:16), 0x0d	; F4E007  cp (0x2078),0x0d
	jr	z, sub_F4D935_Return	; F4E00C  jr Z,0xf4e028
	cp	(UI_ScreenLatch:16), 0x0e	; F4E00E  cp (0x207a),0x0e
	jr	z, sub_F4D935_Return	; F4E013  jr Z,0xf4e028
	ld	a, (UiEvent_Byte1:16)	; F4E015  ld A,(0x20b8)
	cp	a, 13	; F4E019  cp A,0x0d
	jr	z, sub_F4D935_Skip	; F4E01C  jr Z,0xf4e025
	cp	a, 14	; F4E01E  cp A,0x0e
	jr	z, sub_F4D935_Skip	; F4E021  jr Z,0xf4e025
	jr	sub_F4D935_Return	; F4E023  jr T,0xf4e028
sub_F4D935_Skip:
	calr	sub_F4E029	; F4E025  calr 0xf4e029
sub_F4D935_Return:
	ret	; F4E028  ret

; --------------------------------------------------------------------------
; sub_F4E029
; Called from: in-module: 0xF4E025
; Touches: (0x20B9)
; Calls:   sub_F4E04B
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4E029 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4E029:
	xor	c, c	; F4E029  xor C,C
	ld	de, (UiEvent_Byte2:16)	; F4E02B  ld DE,(0x20b9)
	and	e, d	; F4E02F  and E,D
sub_F4E029_Entry:
	ldfr_berp	e, 0x3d	; F4E031  ld RH3,E
	ld	a, c	; F4E034  ld A,C
	scf	; F4E036  scf
	xorcfb_erp	0x3d	; F4E037  xorcf A,RH3
	jr	c, sub_F4E029_Skip	; F4E03A  jr C,0xf4e043
	pushw	bc	; F4E03C  push BC
	pushw	de	; F4E03D  push DE
	calr	sub_F4E04B	; F4E03E  calr 0xf4e04b
	popw	de	; F4E041  pop DE
	popw	bc	; F4E042  pop BC
sub_F4E029_Skip:
	inc	1, c	; F4E043  inc 1,C
	cp	c, 8	; F4E045  cp C,0x08
	jr	c, sub_F4E029_Entry	; F4E048  jr C,0xf4e031
	ret	; F4E04A  ret

; --------------------------------------------------------------------------
; sub_F4E04B
; Called from: in-module: 0xF4E03E
; Touches: (0x20B8)
; Calls:   SeqTrackKey_UpdateTrackState
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4E04B is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4E04B:
	ld	a, (UiEvent_Byte1:16)	; F4E04B  ld A,(0x20b8)
	cp	a, 13	; F4E04F  cp A,0x0d
	jr	nz, sub_F4E04B_Skip	; F4E052  jr NZ,0xf4e057
	add	c, 8	; F4E054  add C,0x08
sub_F4E04B_Skip:
	calr	SeqTrackKey_UpdateTrackState	; F4E057  calr 0xf4e05b
	ret	; F4E05A  ret

; --------------------------------------------------------------------------
; SeqTrackKey_UpdateTrackState
; Called from: in-module: 0xF4E057 0xF4E58D
; Touches: (0x2078) (0x207C) (0x3000) (0x3002) (0x3736)
; Calls:   SeqRecord_DisarmTrack SeqTrack_PlayOnWhileStopped SeqTrack_PlayOffWhileStopped SeqRecord_ArmTrack SeqTrack_SwitchPlayOffWhileRunning SeqTrack_SwitchPlayOnWhileRunning
;          StepRecordPartSelect_OnTrackKey TrackClear_OnTrackKey
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4E05B is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrackKey_UpdateTrackState: (0x3736) := track C; then by panel mode / screen -- REALTIME RECORD (mode 5) or screen
;   9, SEQ PLAY (mode 8), screens 0x0F / 0x1C -- and by the track's bits in the record mask (0x3000)/(0x3002) and the
;   playing mask (0x60341E)/(0x603420) and whether transport B runs, calls one of SeqRecord_DisarmTrack, SeqRecord_ArmTrack, SeqTrack_PlayOffWhileStopped,
;   SeqTrack_SwitchPlayOffWhileRunning, SeqTrack_PlayOnWhileStopped, SeqTrack_SwitchPlayOnWhileRunning, StepRecordPartSelect_OnTrackKey or TrackClear_OnTrackKey, which set or clear those bits and requeue the
;   REC/PLAY labels. SeqTrackKey_Press calls it with the soft key's track; sub_F4E04B with C + 8 for UiEvent_Byte1
;   0x0D. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave4_k.json)
SeqTrackKey_UpdateTrackState:
	ld	(14134:16), c	; F4E05B  ld (0x3736),C
	cp	(PanelMode:16), 0x08	; F4E05F  cp (0x2078),0x08
	jrl	z, SeqTrackKey_UpdateTrackState_Skip9	; F4E064  jrl Z,0xf4e104
	cp	(PanelMode:16), 0x05	; F4E067  cp (0x2078),0x05
	jr	z, SeqTrackKey_UpdateTrackState_Skip	; F4E06C  jr Z,0xf4e088
	cp	(UI_ScreenId:16), 0x09	; F4E06E  cp (0x207c),0x09
	jr	z, SeqTrackKey_UpdateTrackState_Skip	; F4E073  jr Z,0xf4e088
	cp	(UI_ScreenId:16), 0x0f	; F4E075  cp (0x207c),0x0f
	jrl	z, SeqTrackKey_UpdateTrackState_Skip14	; F4E07A  jrl Z,0xf4e148
	cp	(UI_ScreenId:16), 0x1c	; F4E07D  cp (0x207c),0x1c
	jrl	z, SeqTrackKey_UpdateTrackState_Skip15	; F4E082  jrl Z,0xf4e14d
	jrl	SeqTrackKey_UpdateTrackState_Return	; F4E085  jrl T,0xf4e150
SeqTrackKey_UpdateTrackState_Skip:
	ld	c, (14134:16)	; F4E088  ld C,(0x3736)
	cp	c, 16	; F4E08C  cp C,0x10
	jr	nc, SeqTrackKey_UpdateTrackState_Skip2	; F4E08F  jr NC,0xf4e09e
	ld	de, (12288:16)	; F4E091  ld DE,(0x3000)
	ld	a, c	; F4E095  ld A,C
	scf	; F4E097  scf
	xorcf_a_16	de	; F4E098  xorcf A,DE
	jr	c, SeqTrackKey_UpdateTrackState_Skip4	; F4E09A  jr C,0xf4e0bf
	jr	SeqTrackKey_UpdateTrackState_Join	; F4E09C  jr T,0xf4e0ac
SeqTrackKey_UpdateTrackState_Skip2:
	ld	de, (12290:16)	; F4E09E  ld DE,(0x3002)
	ld	a, c	; F4E0A2  ld A,C
	sub	a, 16	; F4E0A4  sub A,0x10
	scf	; F4E0A7  scf
	xorcf_a_16	de	; F4E0A8  xorcf A,DE
	jr	c, SeqTrackKey_UpdateTrackState_Skip4	; F4E0AA  jr C,0xf4e0bf
SeqTrackKey_UpdateTrackState_Join:
	bit	2, (TransportB_State:8)	; F4E0AC  bit 2,(0x96)
	jr	z, SeqTrackKey_UpdateTrackState_Skip3	; F4E0AF  jr Z,0xf4e0b4
	jrl	SeqTrackKey_UpdateTrackState_Return	; F4E0B1  jrl T,0xf4e150
SeqTrackKey_UpdateTrackState_Skip3:
	pushw	bc	; F4E0B4  push BC
	calr	SeqRecord_DisarmTrack	; F4E0B5  calr 0xf4e151
	popw	bc	; F4E0B8  pop BC
	calr	SeqTrack_PlayOnWhileStopped	; F4E0B9  calr 0xf4e426
	jrl	SeqTrackKey_UpdateTrackState_Return	; F4E0BC  jrl T,0xf4e150
SeqTrackKey_UpdateTrackState_Skip4:
	ld	c, (14134:16)	; F4E0BF  ld C,(0x3736)
	cp	c, 16	; F4E0C3  cp C,0x10
	jr	nc, SeqTrackKey_UpdateTrackState_Skip5	; F4E0C6  jr NC,0xf4e0d6
	ld	de, (6304798:24)	; F4E0C8  ld DE,(0x60341e)
	ld	a, c	; F4E0CD  ld A,C
	scf	; F4E0CF  scf
	xorcf_a_16	de	; F4E0D0  xorcf A,DE
	jr	c, SeqTrackKey_UpdateTrackState_Skip7	; F4E0D2  jr C,0xf4e0f6
	jr	SeqTrackKey_UpdateTrackState_Join2	; F4E0D4  jr T,0xf4e0e5
SeqTrackKey_UpdateTrackState_Skip5:
	ld	de, (6304800:24)	; F4E0D6  ld DE,(0x603420)
	ld	a, c	; F4E0DB  ld A,C
	sub	a, 16	; F4E0DD  sub A,0x10
	scf	; F4E0E0  scf
	xorcf_a_16	de	; F4E0E1  xorcf A,DE
	jr	c, SeqTrackKey_UpdateTrackState_Skip7	; F4E0E3  jr C,0xf4e0f6
SeqTrackKey_UpdateTrackState_Join2:
	bit	2, (TransportB_State:8)	; F4E0E5  bit 2,(0x96)
	jr	z, SeqTrackKey_UpdateTrackState_Skip6	; F4E0E8  jr Z,0xf4e0ec
	jr	SeqTrackKey_UpdateTrackState_Return	; F4E0EA  jr T,0xf4e150
SeqTrackKey_UpdateTrackState_Skip6:
	calr	SeqTrack_PlayOffWhileStopped	; F4E0EC  calr 0xf4e32a
	pushw	bc	; F4E0EF  push BC
	calr	SeqRecord_DisarmTrack	; F4E0F0  calr 0xf4e151
	popw	bc	; F4E0F3  pop BC
	jr	SeqTrackKey_UpdateTrackState_Return	; F4E0F4  jr T,0xf4e150
SeqTrackKey_UpdateTrackState_Skip7:
	bit	2, (TransportB_State:8)	; F4E0F6  bit 2,(0x96)
	jr	z, SeqTrackKey_UpdateTrackState_Skip8	; F4E0F9  jr Z,0xf4e0fd
	jr	SeqTrackKey_UpdateTrackState_Return	; F4E0FB  jr T,0xf4e150
SeqTrackKey_UpdateTrackState_Skip8:
	pushw	bc	; F4E0FD  push BC
	calr	SeqRecord_ArmTrack	; F4E0FE  calr 0xf4e259
	popw	bc	; F4E101  pop BC
	jr	SeqTrackKey_UpdateTrackState_Return	; F4E102  jr T,0xf4e150
SeqTrackKey_UpdateTrackState_Skip9:
	ld	c, (14134:16)	; F4E104  ld C,(0x3736)
	cp	c, 16	; F4E108  cp C,0x10
	jr	nc, SeqTrackKey_UpdateTrackState_Skip10	; F4E10B  jr NC,0xf4e11b
	ld	de, (6304798:24)	; F4E10D  ld DE,(0x60341e)
	ld	a, c	; F4E112  ld A,C
	scf	; F4E114  scf
	xorcf_a_16	de	; F4E115  xorcf A,DE
	jr	c, SeqTrackKey_UpdateTrackState_Skip12	; F4E117  jr C,0xf4e139
	jr	SeqTrackKey_UpdateTrackState_Join3	; F4E119  jr T,0xf4e12a
SeqTrackKey_UpdateTrackState_Skip10:
	ld	de, (6304800:24)	; F4E11B  ld DE,(0x603420)
	ld	a, c	; F4E120  ld A,C
	sub	a, 16	; F4E122  sub A,0x10
	scf	; F4E125  scf
	xorcf_a_16	de	; F4E126  xorcf A,DE
	jr	c, SeqTrackKey_UpdateTrackState_Skip12	; F4E128  jr C,0xf4e139
SeqTrackKey_UpdateTrackState_Join3:
	bit	2, (TransportB_State:8)	; F4E12A  bit 2,(0x96)
	jr	z, SeqTrackKey_UpdateTrackState_Skip11	; F4E12D  jr Z,0xf4e134
	calr	SeqTrack_SwitchPlayOffWhileRunning	; F4E12F  calr 0xf4e390
	jr	SeqTrackKey_UpdateTrackState_Return	; F4E132  jr T,0xf4e150
SeqTrackKey_UpdateTrackState_Skip11:
	calr	SeqTrack_PlayOffWhileStopped	; F4E134  calr 0xf4e32a
	jr	SeqTrackKey_UpdateTrackState_Return	; F4E137  jr T,0xf4e150
SeqTrackKey_UpdateTrackState_Skip12:
	bit	2, (TransportB_State:8)	; F4E139  bit 2,(0x96)
	jr	z, SeqTrackKey_UpdateTrackState_Skip13	; F4E13C  jr Z,0xf4e143
	calr	SeqTrack_SwitchPlayOnWhileRunning	; F4E13E  calr 0xf4e478
	jr	SeqTrackKey_UpdateTrackState_Return	; F4E141  jr T,0xf4e150
SeqTrackKey_UpdateTrackState_Skip13:
	calr	SeqTrack_PlayOnWhileStopped	; F4E143  calr 0xf4e426
	jr	SeqTrackKey_UpdateTrackState_Return	; F4E146  jr T,0xf4e150
SeqTrackKey_UpdateTrackState_Skip14:
	calr	StepRecordPartSelect_OnTrackKey	; F4E148  calr 0xf4e4c4
	jr	SeqTrackKey_UpdateTrackState_Return	; F4E14B  jr T,0xf4e150
SeqTrackKey_UpdateTrackState_Skip15:
	calr	TrackClear_OnTrackKey	; F4E14D  calr 0xf4e4f6
SeqTrackKey_UpdateTrackState_Return:
	ret	; F4E150  ret

; --------------------------------------------------------------------------
; SeqRecord_DisarmTrack
; Called from: in-module: 0xF4E0B5 0xF4E0F0 0xF4E5D5
; Touches: (0x0C05) (0x2078) (0x3000) (0x3002) (0x3736)  |  0x000000
; Calls:   T_SeqScreen_QueueTrackRecPlayLabels T_TimedEventRing_Discard T_SeqRecord_RewindForTake CycleRecord_CheckOn T_CycleRecord_SetUpRecordTrack T_NoteRouting_RebuildForSong
;          SeqRecord_SelectArmedTrackPart
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4E151 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_DisarmTrack: Clears track (0x3736)'s bit in the record mask (0x3000)/(0x3002) and re-queues the REC/PLAY
;   labels; outside panel mode 5 sets (0x0C05) := 0xE4 and empties the timed-event ring, in mode 5 runs T_SeqRecord_RewindForTake,
;   CycleRecord_SetUpRecordTrack when cycle record is on, and the routing rebuild; ends with SeqRecord_SelectArmedTrackPart.
;   RealtimeRecordScreen_LcdKeyRow2 runs it for every track above the lowest armed one. Basis: callers + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave4_l.json)
SeqRecord_DisarmTrack:
	ld	c, (14134:16)	; F4E151  ld C,(0x3736)
	cp	c, 16	; F4E155  cp C,0x10
	jr	nc, SeqRecord_DisarmTrack_Skip	; F4E158  jr NC,0xf4e169
	ld	de, (12288:16)	; F4E15A  ld DE,(0x3000)
	ld	a, c	; F4E15E  ld A,C
	rcf	; F4E160  rcf
	stcf_a_16	de	; F4E161  stcf A,DE
	ld	(12288:16), de	; F4E163  ld (0x3000),DE
	jr	SeqRecord_DisarmTrack_Join	; F4E167  jr T,0xf4e179
SeqRecord_DisarmTrack_Skip:
	ld	de, (12290:16)	; F4E169  ld DE,(0x3002)
	ld	a, c	; F4E16D  ld A,C
	sub	a, 16	; F4E16F  sub A,0x10
	rcf	; F4E172  rcf
	stcf_a_16	de	; F4E173  stcf A,DE
	ld	(12290:16), de	; F4E175  ld (0x3002),DE
SeqRecord_DisarmTrack_Join:
	call	T_SeqScreen_QueueTrackRecPlayLabels	; F4E179  call 0xf40e10
	ld	xwa, (12288:16)	; F4E17D  ld XWA,(0x3000)
	cp	xwa, 0	; F4E181  cp XWA,0x00000000
	jr	nz, SeqRecord_DisarmTrack_Skip2	; F4E187  jr NZ,0xf4e189
SeqRecord_DisarmTrack_Skip2:
	cp	(PanelMode:16), 0x05	; F4E189  cp (0x2078),0x05
	jr	z, SeqRecord_DisarmTrack_Skip3	; F4E18E  jr Z,0xf4e19b
	ld	(3077:16), 228	; F4E190  ld (0x0c05),0xe4
	call	T_TimedEventRing_Discard	; F4E195  call 0xf40a14
	jr	SeqRecord_DisarmTrack_Join2	; F4E199  jr T,0xf4e1ae
SeqRecord_DisarmTrack_Skip3:
	call	T_SeqRecord_RewindForTake	; F4E19B  call 0xf409d0
	calr	CycleRecord_CheckOn	; F4E19F  calr 0xf4e30f
	cp	a, 0:i3	; F4E1A2  cp A,0
	jr	nz, SeqRecord_DisarmTrack_Skip4	; F4E1A4  jr NZ,0xf4e1aa
	call	T_CycleRecord_SetUpRecordTrack	; F4E1A6  call 0xf40bdc
SeqRecord_DisarmTrack_Skip4:
	call	T_NoteRouting_RebuildForSong	; F4E1AA  call 0xf411b8
SeqRecord_DisarmTrack_Join2:
	calr	SeqRecord_SelectArmedTrackPart	; F4E1AE  calr 0xf4e1b6
	ret	; F4E1B1  ret

; --------------------------------------------------------------------------
; SeqRecord_SelectArmedTrackPart_Call
; Called from: T_SeqRecord_SelectArmedTrackPart_Call (x1)
; Touches: nothing with an absolute address
; Calls:   SeqRecord_SelectArmedTrackPart
; Evidence: thunk slot T_SeqRecord_SelectArmedTrackPart_Call holds `jp 0x00F4E1B2`, and 0xF4E1B2 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_SelectArmedTrackPart_Call: calls SeqRecord_SelectArmedTrackPart and returns (notes/prom_ab_wrapper_names.py; DERIVATIVE)
SeqRecord_SelectArmedTrackPart_Call:		; <- T_SeqRecord_SelectArmedTrackPart_Call
	calr	SeqRecord_SelectArmedTrackPart	; F4E1B2  calr 0xf4e1b6
	ret	; F4E1B5  ret

; --------------------------------------------------------------------------
; SeqRecord_SelectArmedTrackPart
; Called from: in-module: 0xF4E1AE 0xF4E1B2 0xF4E30B
; Touches: (0x0DB5) (0x2250) (0x3000)  |  0x000000 0x603422
; Calls:   T_Queue2E00_AppendRegs
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4E1B6 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_SelectArmedTrackPart: Makes the part fed by the lowest record-armed track (BStore_TrackToPart; above 0x1F
;   -> 0; the master part 0x20 is skipped) the current part: UI_PartIndex := it, (0x0DB5) b0 set, and the part-select
;   post Queue2E00 (W 0xFF, DE 0x1090) that RealtimeRecord_Disarm and ModeLeave_SeqPlay also make. Tail of
;   SeqRecord_DisarmTrack and of its arm twin. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_p.json)
SeqRecord_SelectArmedTrackPart:
	and	(0x0db5:16), 0xfe	; F4E1B6  and (0x0db5),0xfe
	xor	bc, bc	; F4E1BB  xor BC,BC
	xor	xwa, xwa	; F4E1BD  xor XWA,XWA
	ld	xwa, (12288:16)	; F4E1BF  ld XWA,(0x3000)
SeqRecord_SelectArmedTrackPart_Loop:
	cp	c, 16	; F4E1C3  cp C,0x10
	jr	nc, SeqRecord_SelectArmedTrackPart_Skip	; F4E1C6  jr NC,0xf4e1d5
	ld	de, wa	; F4E1C8  ld DE,WA
	ld	a, c	; F4E1CA  ld A,C
	scf	; F4E1CC  scf
	xorcf_a_16	de	; F4E1CD  xorcf A,DE
	ld	wa, de	; F4E1CF  ld WA,DE
	jr	c, SeqRecord_SelectArmedTrackPart_Skip3	; F4E1D1  jr C,0xf4e211
	jr	SeqRecord_SelectArmedTrackPart_Join	; F4E1D3  jr T,0xf4e1e7
SeqRecord_SelectArmedTrackPart_Skip:
	pushw	wa	; F4E1D5  push WA
	ld	de, qwa	; F4E1D6  ld DE,QWA
	ld	a, c	; F4E1D9  ld A,C
	sub	a, 16	; F4E1DB  sub A,0x10
	scf	; F4E1DE  scf
	xorcf_a_16	de	; F4E1DF  xorcf A,DE
	ld	qwa, de	; F4E1E1  ld QWA,DE
	popw	wa	; F4E1E4  pop WA
	jr	c, SeqRecord_SelectArmedTrackPart_Skip3	; F4E1E5  jr C,0xf4e211
SeqRecord_SelectArmedTrackPart_Join:
	cp	c, 16	; F4E1E7  cp C,0x10
	jr	nc, SeqRecord_SelectArmedTrackPart_Skip2	; F4E1EA  jr NC,0xf4e1f7
	ld	de, wa	; F4E1EC  ld DE,WA
	ld	a, c	; F4E1EE  ld A,C
	rcf	; F4E1F0  rcf
	stcf_a_16	de	; F4E1F1  stcf A,DE
	ld	wa, de	; F4E1F3  ld WA,DE
	jr	SeqRecord_SelectArmedTrackPart_Join2	; F4E1F5  jr T,0xf4e207
SeqRecord_SelectArmedTrackPart_Skip2:
	pushw	wa	; F4E1F7  push WA
	ld	de, qwa	; F4E1F8  ld DE,QWA
	ld	a, c	; F4E1FB  ld A,C
	sub	a, 16	; F4E1FD  sub A,0x10
	rcf	; F4E200  rcf
	stcf_a_16	de	; F4E201  stcf A,DE
	ld	qwa, de	; F4E203  ld QWA,DE
	popw	wa	; F4E206  pop WA
SeqRecord_SelectArmedTrackPart_Join2:
	cp	xwa, 0	; F4E207  cp XWA,0x00000000
	jr	nz, SeqRecord_SelectArmedTrackPart_Join5	; F4E20D  jr NZ,0xf4e256
	jr	SeqRecord_SelectArmedTrackPart_Join3	; F4E20F  jr T,0xf4e21a
SeqRecord_SelectArmedTrackPart_Skip3:
	inc	1, c	; F4E211  inc 1,C
	cp	c, 17	; F4E213  cp C,0x11
	jr	c, SeqRecord_SelectArmedTrackPart_Loop	; F4E216  jr C,0xf4e1c3
	jr	SeqRecord_SelectArmedTrackPart_Join5	; F4E218  jr T,0xf4e256
SeqRecord_SelectArmedTrackPart_Join3:
	ld	xhl, BStore_TrackToPart	; F4E21A  ld XHL,0x00603422
	ld	iy, bc	; F4E21F  ld IY,BC
	ld	a, (xhl+iy)	; F4E221  ld A,(XHL+IY)
	cp	a, 32	; F4E226  cp A,0x20
	jr	z, SeqRecord_SelectArmedTrackPart_Return	; F4E229  jr Z,0xf4e258
	cp	a, 31	; F4E22B  cp A,0x1f
	jr	ugt, SeqRecord_SelectArmedTrackPart_Skip4	; F4E22E  jr UGT,0xf4e252
SeqRecord_SelectArmedTrackPart_Join4:
	xor	w, w	; F4E230  xor W,W
	ld	iy, wa	; F4E232  ld IY,WA
	ld	xix, IdentityMap_F4E5DC	; F4E234  ld XIX,0x00f4e5dc
	ld	a, (xix+iy)	; F4E239  ld A,(XIX+IY)
	ld	(UI_PartIndex:16), a	; F4E23E  ld (0x2250),A
	or	(0x0db5:16), 0x01	; F4E242  or (0x0db5),0x01
	ld	w, 255:opc	; F4E247  ld W,0xff
	ldw	de, 4240	; F4E249  ld DE,0x1090
	call	T_Queue2E00_AppendRegs	; F4E24C  call 0xf40f3c
	jr	SeqRecord_SelectArmedTrackPart_Return	; F4E250  jr T,0xf4e258
SeqRecord_SelectArmedTrackPart_Skip4:
	ld	a, 0:opc	; F4E252  ld A,0x00
	jr	SeqRecord_SelectArmedTrackPart_Join4	; F4E254  jr T,0xf4e230
SeqRecord_SelectArmedTrackPart_Join5:
	jr	SeqRecord_SelectArmedTrackPart_Join3	; F4E256  jr T,0xf4e21a
SeqRecord_SelectArmedTrackPart_Return:
	ret	; F4E258  ret

; --------------------------------------------------------------------------
; SeqRecord_ArmTrack
; Called from: in-module: 0xF4E0FE
; Touches: (0x0C05) (0x2078) (0x207A) (0x3000) (0x3002) (0x34BB) (0x34D4)
;          (0x360B) (0x3736)  |  0x000000
; Calls:   T_SeqScreen_QueueTrackRecPlayLabels T_TimedEventRing_Discard T_SeqRecord_RewindForTake CycleRecord_CheckOn T_CycleRecord_SetUpRecordTrack T_NoteRouting_RebuildForSong T_Transport_StopAllRunning
;          SeqRecord_SelectArmedTrackPart
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4E259 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqRecord_ArmTrack: Arms track (0x3736) for recording: on CYCLE RECORD (screen latch 6, CYCLE on) the record mask is
;   cleared first; sets its bit in (0x3000)/(0x3002), clears it in the playing mask (0x60341E), re-queues REC/PLAY
;   labels; mode 5: (0x34D4) |= 0x10, T_SeqRecord_RewindForTake, cycle set-up, route rebuild, else (0x0C05) := 0xE4 + ring discard;
;   stops transports unless C starts/runs; SeqRecord_SelectArmedTrackPart. Twin of SeqRecord_DisarmTrack. Basis:
;   caller + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave5_p.json)
SeqRecord_ArmTrack:
	ld	c, (14134:16)	; F4E259  ld C,(0x3736)
	ld	xwa, (12288:16)	; F4E25D  ld XWA,(0x3000)
	cp	xwa, 0	; F4E261  cp XWA,0x00000000
	jr	nz, SeqRecord_ArmTrack_Skip	; F4E267  jr NZ,0xf4e26e
	and	(0x34bb:16), 0xfb	; F4E269  and (0x34bb),0xfb
SeqRecord_ArmTrack_Skip:
	cp	(UI_ScreenLatch:16), 0x06	; F4E26E  cp (0x207a),0x06
	jr	nz, SeqRecord_ArmTrack_Skip2	; F4E273  jr NZ,0xf4e281
	bit	1, (0x360b:16)	; F4E275  bit 1,(0x360b)
	jr	z, SeqRecord_ArmTrack_Skip2	; F4E279  jr Z,0xf4e281
	xor	xwa, xwa	; F4E27B  xor XWA,XWA
	ld	(12288:16), xwa	; F4E27D  ld (0x3000),XWA
SeqRecord_ArmTrack_Skip2:
	ld	c, (14134:16)	; F4E281  ld C,(0x3736)
	cp	c, 16	; F4E285  cp C,0x10
	jr	nc, SeqRecord_ArmTrack_Skip3	; F4E288  jr NC,0xf4e299
	ld	de, (12288:16)	; F4E28A  ld DE,(0x3000)
	ld	a, c	; F4E28E  ld A,C
	scf	; F4E290  scf
	stcf_a_16	de	; F4E291  stcf A,DE
	ld	(12288:16), de	; F4E293  ld (0x3000),DE
	jr	SeqRecord_ArmTrack_Join	; F4E297  jr T,0xf4e2a9
SeqRecord_ArmTrack_Skip3:
	ld	de, (12290:16)	; F4E299  ld DE,(0x3002)
	ld	a, c	; F4E29D  ld A,C
	sub	a, 16	; F4E29F  sub A,0x10
	scf	; F4E2A2  scf
	stcf_a_16	de	; F4E2A3  stcf A,DE
	ld	(12290:16), de	; F4E2A5  ld (0x3002),DE
SeqRecord_ArmTrack_Join:
	cp	c, 16	; F4E2A9  cp C,0x10
	jr	nc, SeqRecord_ArmTrack_Skip4	; F4E2AC  jr NC,0xf4e2bf
	ld	de, (6304798:24)	; F4E2AE  ld DE,(0x60341e)
	ld	a, c	; F4E2B3  ld A,C
	rcf	; F4E2B5  rcf
	stcf_a_16	de	; F4E2B6  stcf A,DE
	ld	(6304798:24), de	; F4E2B8  ld (0x60341e),DE
	jr	SeqRecord_ArmTrack_Join2	; F4E2BD  jr T,0xf4e2d1
SeqRecord_ArmTrack_Skip4:
	ld	de, (6304800:24)	; F4E2BF  ld DE,(0x603420)
	ld	a, c	; F4E2C4  ld A,C
	sub	a, 16	; F4E2C6  sub A,0x10
	rcf	; F4E2C9  rcf
	stcf_a_16	de	; F4E2CA  stcf A,DE
	ld	(6304800:24), de	; F4E2CC  ld (0x603420),DE
SeqRecord_ArmTrack_Join2:
	call	T_SeqScreen_QueueTrackRecPlayLabels	; F4E2D1  call 0xf40e10
	cp	(PanelMode:16), 0x05	; F4E2D5  cp (0x2078),0x05
	jr	z, SeqRecord_ArmTrack_Skip5	; F4E2DA  jr Z,0xf4e2e7
	ld	(3077:16), 228	; F4E2DC  ld (0x0c05),0xe4
	call	T_TimedEventRing_Discard	; F4E2E1  call 0xf40a14
	jr	SeqRecord_ArmTrack_Join3	; F4E2E5  jr T,0xf4e2ff
SeqRecord_ArmTrack_Skip5:
	or	(0x34d4:16), 0x10	; F4E2E7  or (0x34d4),0x10
	call	T_SeqRecord_RewindForTake	; F4E2EC  call 0xf409d0
	calr	CycleRecord_CheckOn	; F4E2F0  calr 0xf4e30f
	cp	a, 0:i3	; F4E2F3  cp A,0
	jr	nz, SeqRecord_ArmTrack_Skip6	; F4E2F5  jr NZ,0xf4e2fb
	call	T_CycleRecord_SetUpRecordTrack	; F4E2F7  call 0xf40bdc
SeqRecord_ArmTrack_Skip6:
	call	T_NoteRouting_RebuildForSong	; F4E2FB  call 0xf411b8
SeqRecord_ArmTrack_Join3:
	ld	a, (TransportC_State:8)	; F4E2FF  ld A,(0x95)
	and	a, 5	; F4E302  and A,0x05
	jr	nz, SeqRecord_ArmTrack_Skip7	; F4E305  jr NZ,0xf4e30b
	call	T_Transport_StopAllRunning	; F4E307  call 0xf409ac
SeqRecord_ArmTrack_Skip7:
	calr	SeqRecord_SelectArmedTrackPart	; F4E30B  calr 0xf4e1b6
	ret	; F4E30E  ret

; --------------------------------------------------------------------------
; CycleRecord_CheckOn
; Called from: T_CycleRecord_CheckOn (x2); in-module: 0xF4E19F 0xF4E2F0
; Touches: (0x207A) (0x360B)
; Evidence: thunk slot T_CycleRecord_CheckOn holds `jp 0x00F4E30F`, and 0xF4E30F is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CheckOn: A := 0 when the screen latch is a CYCLE RECORD screen (UI_ScreenLatch 6 or 8) and its CYCLE
;   switch ((0x360B) bit 1) is on; otherwise A := 0xFF. Preserves BC. Both callers branch on A == 0 to the cycle-
;   record path. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave3_i.json)
CycleRecord_CheckOn:		; <- T_CycleRecord_CheckOn
	xor	a, a	; F4E30F  xor A,A
	pushw	bc	; F4E311  push BC
	cp	(UI_ScreenLatch:16), 0x06	; F4E312  cp (0x207a),0x06
	jr	z, CycleRecord_CheckOn_Skip	; F4E317  jr Z,0xf4e320
	cp	(UI_ScreenLatch:16), 0x08	; F4E319  cp (0x207a),0x08
	jr	nz, CycleRecord_CheckOn_Skip2	; F4E31E  jr NZ,0xf4e326
CycleRecord_CheckOn_Skip:
	bit	1, (0x360b:16)	; F4E320  bit 1,(0x360b)
	jr	nz, CycleRecord_CheckOn_Epilogue	; F4E324  jr NZ,0xf4e328
CycleRecord_CheckOn_Skip2:
	ld	a, 255:opc	; F4E326  ld A,0xff
CycleRecord_CheckOn_Epilogue:
	popw	bc	; F4E328  pop BC
	ret	; F4E329  ret

; --------------------------------------------------------------------------
; SeqTrack_PlayOffWhileStopped
; Called from: T_SeqTrack_PlayOffWhileStopped (x1); in-module: 0xF4E0EC 0xF4E134
; Touches: (0x34D4) (0x3736)
; Calls:   T_SeqScreen_QueueTrackRecPlayLabels T_NoteRouting_RebuildForSong T_SeqTrack_CompletePlayOff
; Evidence: thunk slot T_SeqTrack_PlayOffWhileStopped holds `jp 0x00F4E32A`, and 0xF4E32A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrack_PlayOffWhileStopped: Track (0x3736) loses its bit in the playing-track mask (0x60341E/0x603420); REC/PLAY
;   labels re-queued (T_SeqScreen_QueueTrackRecPlayLabels), (0x34D4) |= 0x10, NoteRouting_RebuildForSong, then
;   T_SeqTrack_CompletePlayOff with that bit, which drops it from (0x3008)/(0x300C). The transport-B-stopped arm (SeqTrack_SwitchPlayOffWhileRunning is the
;   running one) of SeqMasterTrack_SwitchOff (track 16) and of the track button handler SeqTrackKey_UpdateTrackState. Basis: callers +
;   caller header + body. (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
SeqTrack_PlayOffWhileStopped:		; <- T_SeqTrack_PlayOffWhileStopped
	ld	c, (14134:16)	; F4E32A  ld C,(0x3736)
	cp	c, 16	; F4E32E  cp C,0x10
	jr	nc, SeqTrack_PlayOffWhileStopped_Skip	; F4E331  jr NC,0xf4e344
	ld	de, (6304798:24)	; F4E333  ld DE,(0x60341e)
	ld	a, c	; F4E338  ld A,C
	rcf	; F4E33A  rcf
	stcf_a_16	de	; F4E33B  stcf A,DE
	ld	(6304798:24), de	; F4E33D  ld (0x60341e),DE
	jr	SeqTrack_PlayOffWhileStopped_Join	; F4E342  jr T,0xf4e356
SeqTrack_PlayOffWhileStopped_Skip:
	ld	de, (6304800:24)	; F4E344  ld DE,(0x603420)
	ld	a, c	; F4E349  ld A,C
	sub	a, 16	; F4E34B  sub A,0x10
	rcf	; F4E34E  rcf
	stcf_a_16	de	; F4E34F  stcf A,DE
	ld	(6304800:24), de	; F4E351  ld (0x603420),DE
SeqTrack_PlayOffWhileStopped_Join:
	call	T_SeqScreen_QueueTrackRecPlayLabels	; F4E356  call 0xf40e10
	or	(0x34d4:16), 0x10	; F4E35A  or (0x34d4),0x10
	pushw	bc	; F4E35F  push BC
	call	T_NoteRouting_RebuildForSong	; F4E360  call 0xf411b8
	popw	bc	; F4E364  pop BC
	ld	c, (14134:16)	; F4E365  ld C,(0x3736)
	xor	xwa, xwa	; F4E369  xor XWA,XWA
	cp	c, 16	; F4E36B  cp C,0x10
	jr	nc, SeqTrack_PlayOffWhileStopped_Skip2	; F4E36E  jr NC,0xf4e37b
	ld	de, wa	; F4E370  ld DE,WA
	ld	a, c	; F4E372  ld A,C
	scf	; F4E374  scf
	stcf_a_16	de	; F4E375  stcf A,DE
	ld	wa, de	; F4E377  ld WA,DE
	jr	SeqTrack_PlayOffWhileStopped_Join2	; F4E379  jr T,0xf4e38b
SeqTrack_PlayOffWhileStopped_Skip2:
	pushw	wa	; F4E37B  push WA
	ld	de, qwa	; F4E37C  ld DE,QWA
	ld	a, c	; F4E37F  ld A,C
	sub	a, 16	; F4E381  sub A,0x10
	scf	; F4E384  scf
	stcf_a_16	de	; F4E385  stcf A,DE
	ld	qwa, de	; F4E387  ld QWA,DE
	popw	wa	; F4E38A  pop WA
SeqTrack_PlayOffWhileStopped_Join2:
	call	T_SeqTrack_CompletePlayOff	; F4E38B  call 0xf409d4
	ret	; F4E38F  ret

; --------------------------------------------------------------------------
; SeqTrack_SwitchPlayOffWhileRunning
; Called from: T_SeqTrack_SwitchPlayOffWhileRunning (x1); in-module: 0xF4E12F
; Touches: (0x2071) (0x2078) (0x3736)  |  0x000000
; Calls:   T_SeqScreen_QueueTrackRecPlayLabels T_Transport_StopAllRunning T_TransportB_Stop T_SeqTrack_CompletePlayOff
; Evidence: thunk slot T_SeqTrack_SwitchPlayOffWhileRunning holds `jp 0x00F4E390`, and 0xF4E390 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrack_SwitchPlayOffWhileRunning: Track (0x3736) PLAY off while transport B runs: clears its bit in
;   (0x60341E)/(0x603420), queues the REC/PLAY labels; if no track is left playing, stops (Transport_StopAllRunning,
;   or TransportB_Stop while transport A runs; PanelMode 8 also sets UI_Request_Hi bit 4); then hands that track to
;   SeqTrack_CompletePlayOff, which queues its switch-off events. SeqTrack_PlayOffWhileStopped is the stopped-transport twin. Basis: callers + body +
;   twin. (notes/naming-pilot-2026-10-06/proposals_wave4_n.json)
SeqTrack_SwitchPlayOffWhileRunning:		; <- T_SeqTrack_SwitchPlayOffWhileRunning
	ld	c, (14134:16)	; F4E390  ld C,(0x3736)
	xor	b, b	; F4E394  xor B,B
	cp	c, 16	; F4E396  cp C,0x10
	jr	nc, SeqTrack_SwitchPlayOffWhileRunning_Skip	; F4E399  jr NC,0xf4e3ac
	ld	de, (6304798:24)	; F4E39B  ld DE,(0x60341e)
	ld	a, c	; F4E3A0  ld A,C
	rcf	; F4E3A2  rcf
	stcf_a_16	de	; F4E3A3  stcf A,DE
	ld	(6304798:24), de	; F4E3A5  ld (0x60341e),DE
	jr	SeqTrack_SwitchPlayOffWhileRunning_Join	; F4E3AA  jr T,0xf4e3be
SeqTrack_SwitchPlayOffWhileRunning_Skip:
	ld	de, (6304800:24)	; F4E3AC  ld DE,(0x603420)
	ld	a, c	; F4E3B1  ld A,C
	sub	a, 16	; F4E3B3  sub A,0x10
	rcf	; F4E3B6  rcf
	stcf_a_16	de	; F4E3B7  stcf A,DE
	ld	(6304800:24), de	; F4E3B9  ld (0x603420),DE
SeqTrack_SwitchPlayOffWhileRunning_Join:
	call	T_SeqScreen_QueueTrackRecPlayLabels	; F4E3BE  call 0xf40e10
	ld	xwa, (6304798:24)	; F4E3C2  ld XWA,(0x60341e)
	cp	xwa, 0	; F4E3C7  cp XWA,0x00000000
	jr	nz, SeqTrack_SwitchPlayOffWhileRunning_Join2	; F4E3CD  jr NZ,0xf4e3e2
	bit	2, (TransportA_State:8)	; F4E3CF  bit 2,(0x94)
	jr	nz, SeqTrack_SwitchPlayOffWhileRunning_Skip2	; F4E3D2  jr NZ,0xf4e3dc
	pushw	bc	; F4E3D4  push BC
	call	T_Transport_StopAllRunning	; F4E3D5  call 0xf409ac
	popw	bc	; F4E3D9  pop BC
	jr	SeqTrack_SwitchPlayOffWhileRunning_Join2	; F4E3DA  jr T,0xf4e3e2
SeqTrack_SwitchPlayOffWhileRunning_Skip2:
	pushw	bc	; F4E3DC  push BC
	call	T_TransportB_Stop	; F4E3DD  call 0xf409a8
	popw	bc	; F4E3E1  pop BC
SeqTrack_SwitchPlayOffWhileRunning_Join2:
	ld	xwa, (6304798:24)	; F4E3E2  ld XWA,(0x60341e)
	cp	xwa, 0	; F4E3E7  cp XWA,0x00000000
	jr	nz, SeqTrack_SwitchPlayOffWhileRunning_Skip3	; F4E3ED  jr NZ,0xf4e3fb
	cp	(PanelMode:16), 0x08	; F4E3EF  cp (0x2078),0x08
	jr	nz, SeqTrack_SwitchPlayOffWhileRunning_Skip3	; F4E3F4  jr NZ,0xf4e3fb
	or	(UI_Request_Hi:16), 0x10	; F4E3F6  or (0x2071),0x10
SeqTrack_SwitchPlayOffWhileRunning_Skip3:
	ld	c, (14134:16)	; F4E3FB  ld C,(0x3736)
	xor	xwa, xwa	; F4E3FF  xor XWA,XWA
	cp	c, 16	; F4E401  cp C,0x10
	jr	nc, SeqTrack_SwitchPlayOffWhileRunning_Skip4	; F4E404  jr NC,0xf4e411
	ld	de, wa	; F4E406  ld DE,WA
	ld	a, c	; F4E408  ld A,C
	scf	; F4E40A  scf
	stcf_a_16	de	; F4E40B  stcf A,DE
	ld	wa, de	; F4E40D  ld WA,DE
	jr	SeqTrack_SwitchPlayOffWhileRunning_Join3	; F4E40F  jr T,0xf4e421
SeqTrack_SwitchPlayOffWhileRunning_Skip4:
	pushw	wa	; F4E411  push WA
	ld	de, qwa	; F4E412  ld DE,QWA
	ld	a, c	; F4E415  ld A,C
	sub	a, 16	; F4E417  sub A,0x10
	scf	; F4E41A  scf
	stcf_a_16	de	; F4E41B  stcf A,DE
	ld	qwa, de	; F4E41D  ld QWA,DE
	popw	wa	; F4E420  pop WA
SeqTrack_SwitchPlayOffWhileRunning_Join3:
	call	T_SeqTrack_CompletePlayOff	; F4E421  call 0xf409d4
	ret	; F4E425  ret

; --------------------------------------------------------------------------
; SeqTrack_PlayOnWhileStopped
; Called from: T_SeqTrack_PlayOnWhileStopped (x1); in-module: 0xF4E0B9 0xF4E143
; Touches: (0x34BB) (0x34D4) (0x3736)  |  0x000000
; Calls:   T_Transport_StopAllRunning T_SeqScreen_QueueTrackRecPlayLabels T_NoteRouting_RebuildForSong
; Evidence: thunk slot T_SeqTrack_PlayOnWhileStopped holds `jp 0x00F4E426`, and 0xF4E426 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrack_PlayOnWhileStopped: Track (0x3736) PLAY on with transport B stopped: if no track was playing it clears the
;   locate flag ((0x34BB) bit 3) and runs Transport_StopAllRunning; then sets the position request (0x34D4) bit 4 and
;   the track's bit in (0x60341E)/(0x603420), re-queues the REC/PLAY labels, rebuilds the note routing. The stopped-
;   transport ON arm of SeqTrackKey_UpdateTrackState and of SeqMasterTrack_SwitchOn (T_SeqTrack_PlayOnWhileStopped);
;   SeqTrack_PlayOffWhileStopped is the OFF twin. Basis: callers + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_o.json)
SeqTrack_PlayOnWhileStopped:		; <- T_SeqTrack_PlayOnWhileStopped
	ld	xwa, (6304798:24)	; F4E426  ld XWA,(0x60341e)
	cp	xwa, 0	; F4E42B  cp XWA,0x00000000
	jr	nz, SeqTrack_PlayOnWhileStopped_Skip	; F4E431  jr NZ,0xf4e43e
	and	(0x34bb:16), 0xf7	; F4E433  and (0x34bb),0xf7
	pushw	bc	; F4E438  push BC
	call	T_Transport_StopAllRunning	; F4E439  call 0xf409ac
	popw	bc	; F4E43D  pop BC
SeqTrack_PlayOnWhileStopped_Skip:
	or	(0x34d4:16), 0x10	; F4E43E  or (0x34d4),0x10
	ld	c, (14134:16)	; F4E443  ld C,(0x3736)
	cp	c, 16	; F4E447  cp C,0x10
	jr	nc, SeqTrack_PlayOnWhileStopped_Skip2	; F4E44A  jr NC,0xf4e45d
	ld	de, (6304798:24)	; F4E44C  ld DE,(0x60341e)
	ld	a, c	; F4E451  ld A,C
	scf	; F4E453  scf
	stcf_a_16	de	; F4E454  stcf A,DE
	ld	(6304798:24), de	; F4E456  ld (0x60341e),DE
	jr	SeqTrack_PlayOnWhileStopped_Join	; F4E45B  jr T,0xf4e46f
SeqTrack_PlayOnWhileStopped_Skip2:
	ld	de, (6304800:24)	; F4E45D  ld DE,(0x603420)
	ld	a, c	; F4E462  ld A,C
	sub	a, 16	; F4E464  sub A,0x10
	scf	; F4E467  scf
	stcf_a_16	de	; F4E468  stcf A,DE
	ld	(6304800:24), de	; F4E46A  ld (0x603420),DE
SeqTrack_PlayOnWhileStopped_Join:
	call	T_SeqScreen_QueueTrackRecPlayLabels	; F4E46F  call 0xf40e10
	call	T_NoteRouting_RebuildForSong	; F4E473  call 0xf411b8
	ret	; F4E477  ret

; --------------------------------------------------------------------------
; SeqTrack_SwitchPlayOnWhileRunning
; Called from: T_SeqTrack_SwitchPlayOnWhileRunning (x1); in-module: 0xF4E13E
; Touches: (0x34BB) (0x34D4) (0x3736)  |  0x000000
; Calls:   T_SeqScreen_QueueTrackRecPlayLabels T_NoteRouting_RebuildForSong
; Evidence: thunk slot T_SeqTrack_SwitchPlayOnWhileRunning holds `jp 0x00F4E478`, and 0xF4E478 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrack_SwitchPlayOnWhileRunning: Track (0x3736) PLAY on while transport B runs: if no track was playing it clears
;   the locate flag ((0x34BB) bit 3) and sets the position request (0x34D4) bit 4; then sets the track's bit in
;   (0x60341E)/(0x603420), re-queues the REC/PLAY labels, rebuilds the note routing. The running-transport ON arm of
;   SeqTrackKey_UpdateTrackState and of SeqMasterTrack_SwitchOn (T_SeqTrack_SwitchPlayOnWhileRunning); SeqTrack_SwitchPlayOffWhileRunning is the
;   OFF twin. Basis: callers + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
SeqTrack_SwitchPlayOnWhileRunning:		; <- T_SeqTrack_SwitchPlayOnWhileRunning
	ld	c, (14134:16)	; F4E478  ld C,(0x3736)
	ld	xwa, (6304798:24)	; F4E47C  ld XWA,(0x60341e)
	cp	xwa, 0	; F4E481  cp XWA,0x00000000
	jr	nz, SeqTrack_SwitchPlayOnWhileRunning_Skip	; F4E487  jr NZ,0xf4e493
	and	(0x34bb:16), 0xf7	; F4E489  and (0x34bb),0xf7
	or	(0x34d4:16), 0x10	; F4E48E  or (0x34d4),0x10
SeqTrack_SwitchPlayOnWhileRunning_Skip:
	cp	c, 16	; F4E493  cp C,0x10
	jr	nc, SeqTrack_SwitchPlayOnWhileRunning_Skip2	; F4E496  jr NC,0xf4e4a9
	ld	de, (6304798:24)	; F4E498  ld DE,(0x60341e)
	ld	a, c	; F4E49D  ld A,C
	scf	; F4E49F  scf
	stcf_a_16	de	; F4E4A0  stcf A,DE
	ld	(6304798:24), de	; F4E4A2  ld (0x60341e),DE
	jr	SeqTrack_SwitchPlayOnWhileRunning_Join	; F4E4A7  jr T,0xf4e4bb
SeqTrack_SwitchPlayOnWhileRunning_Skip2:
	ld	de, (6304800:24)	; F4E4A9  ld DE,(0x603420)
	ld	a, c	; F4E4AE  ld A,C
	sub	a, 16	; F4E4B0  sub A,0x10
	scf	; F4E4B3  scf
	stcf_a_16	de	; F4E4B4  stcf A,DE
	ld	(6304800:24), de	; F4E4B6  ld (0x603420),DE
SeqTrack_SwitchPlayOnWhileRunning_Join:
	call	T_SeqScreen_QueueTrackRecPlayLabels	; F4E4BB  call 0xf40e10
	call	T_NoteRouting_RebuildForSong	; F4E4BF  call 0xf411b8
	ret	; F4E4C3  ret

; --------------------------------------------------------------------------
; StepRecordPartSelect_OnTrackKey
; Called from: in-module: 0xF4E148
; Touches: nothing with an absolute address
; Calls:   StepRecordPartSelect_ChooseTrack
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4E4C4 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; StepRecordPartSelect_OnTrackKey: `calr StepRecordPartSelect_ChooseTrack / ret`: in panel mode 6 on screen 0x0F (StepRecordPartSelect) a
;   track key chooses track C: (0x0E5B) := BStore_TrackToPart[C], the chosen track (0x0E5C) := C + 1
;   (StepRecordPartSelect_OpenStepRecord needs 1..0x11), repaint. SeqTrackKey_UpdateTrackState's screen-0x0F arm.
;   Basis: caller + body + flag reader. (notes/naming-pilot-2026-10-06/proposals_wave5_p.json)
StepRecordPartSelect_OnTrackKey:
	calr	StepRecordPartSelect_ChooseTrack	; F4E4C4  calr 0xf4e4c8
	ret	; F4E4C7  ret

; --------------------------------------------------------------------------
; StepRecordPartSelect_ChooseTrack
; Called from: in-module: 0xF4E4C4
; Touches: (0x0E5B) (0x0E5C) (0x2078) (0x207C) (0x2095)  |  0x603422
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4E4C8 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; StepRecordPartSelect_ChooseTrack: In panel mode 6 on screen 0x0F (STEP RECORD part select), track key C chooses
;   track C: (0x0E5B) := BStore_TrackToPart[C], (0x0E5C) := C + 1, repaint (UI_ScreenFlags bit 4). The body behind
;   StepRecordPartSelect_OnTrackKey. Basis: caller (header) + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_s.json)
StepRecordPartSelect_ChooseTrack:
	cp	(PanelMode:16), 0x06	; F4E4C8  cp (0x2078),0x06
	jr	nz, StepRecordPartSelect_ChooseTrack_Return	; F4E4CD  jr NZ,0xf4e4f5
	cp	(UI_ScreenId:16), 0x0f	; F4E4CF  cp (0x207c),0x0f
	jr	nz, StepRecordPartSelect_ChooseTrack_Return	; F4E4D4  jr NZ,0xf4e4f5
	ld	xhl, BStore_TrackToPart	; F4E4D6  ld XHL,0x00603422
	xor	b, b	; F4E4DB  xor B,B
	ld	iy, bc	; F4E4DD  ld IY,BC
	ld	e, c	; F4E4DF  ld E,C
	ld	a, (xiy+hl)	; F4E4E1  ld A,(XIY+HL)
	ld	(3675:16), a	; F4E4E6  ld (0x0e5b),A
	inc	1, e	; F4E4EA  inc 1,E
	ld	(3676:16), e	; F4E4EC  ld (0x0e5c),E
	or	(UI_ScreenFlags:16), 0x10	; F4E4F0  or (0x2095),0x10
StepRecordPartSelect_ChooseTrack_Return:
	ret	; F4E4F5  ret

; --------------------------------------------------------------------------
; TrackClear_OnTrackKey
; Called from: in-module: 0xF4E14D
; Touches: (0x207A) (0x207C) (0x207E)
; Calls:   TrackClear_ToggleTrackSelection
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4E4F6 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackClear_OnTrackKey: With UI_ScreenStage != 1 and latch == screen: TrackClear_ToggleTrackSelection toggles track C's bit
;   (BitWeight_F4E5FC) in the TRACK CLEAR selection mask (0x0DBE) and requests a repaint.
;   SeqTrackKey_UpdateTrackState's screen-0x1C (TRACK CLEAR) arm; TrackClear_LcdKeyRow2 clears every selected track.
;   Basis: caller + body + mask reader. (notes/naming-pilot-2026-10-06/proposals_wave5_p.json)
TrackClear_OnTrackKey:
	cp	(UI_ScreenStage:16), 0x01	; F4E4F6  cp (0x207e),0x01
	jr	z, TrackClear_OnTrackKey_Return	; F4E4FB  jr Z,0xf4e50a
	ld	a, (UI_ScreenLatch:16)	; F4E4FD  ld A,(0x207a)
	cp	a, (UI_ScreenId:16)	; F4E501  cp A,(0x207c)
	jr	nz, TrackClear_OnTrackKey_Return	; F4E505  jr NZ,0xf4e50a
	calr	TrackClear_ToggleTrackSelection	; F4E507  calr 0xf4e50b
TrackClear_OnTrackKey_Return:
	ret	; F4E50A  ret

; --------------------------------------------------------------------------
; TrackClear_ToggleTrackSelection
; Called from: in-module: 0xF4E507
; Touches: (0x0DBE) (0x2095)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4E50B is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackClear_ToggleTrackSelection: Toggles track BC's bit (BitWeight_F4E5FC[BC] = 1 << BC) in the TRACK CLEAR
;   selection mask (0x0DBE) and sets UI_ScreenFlags bit 4 to request a repaint. TrackClear_OnTrackKey's action on a
;   track key; SongEdit_ResetJobFields zeroes the mask. Basis: caller + caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_t.json)
TrackClear_ToggleTrackSelection:
	ld	hl, bc	; F4E50B  ld HL,BC
	sla	hl, 1	; F4E50D  sla 0x01,HL
	ld	xix, BitWeight_F4E5FC	; F4E510  ld XIX,0x00f4e5fc
	ld	hl, (xix+hl)	; F4E515  ld HL,(XIX+HL)
	xor	(0x0dbe:16), hl	; F4E51A  xor (0x0dbe),HL
	or	(UI_ScreenFlags:16), 0x10	; F4E51E  or (0x2095),0x10
	ret	; F4E523  ret

; --------------------------------------------------------------------------
; T_F40CB4_Nop
; Called from: T_F40CB4 (x14)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_F40CB4 holds `jp 0x00F4E524`, and 0xF4E524 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Purpose: none -- the entry is a lone `ret`.  Named T_F40CB4_Nop after what reaches it
;          (was sub_F4E524; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
T_F40CB4_Nop:		; <- T_F40CB4
	ret	; F4E524  ret

; --------------------------------------------------------------------------
; Seq_RequestRewindOnEvent
; Called from: T_Seq_RequestRewindOnEvent (x0)
; Touches: (0x207A) (0x20B8) (0x20B9)
; Calls:   Seq_RequestRewindIfIdle
; Evidence: thunk slot T_Seq_RequestRewindOnEvent holds `jp 0x00F4E525`, and 0xF4E525 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_RequestRewindOnEvent: UiListB_ClassA8 handler [5] (T_Seq_RequestRewindOnEvent): on a class-0xA8 record with code 0x11 whose bit 1
;   is both changed and set ((0x20B9) & (0x20BA)), and not on screen latch 0x0E, Seq_RequestRewindIfIdle calls T_Seq_RequestRewind
;   when tracks play ((0x60341E) != 0), none is armed ((0x3000) = 0) and transports A and B are stopped. Bit 0 of the
;   same code drives Transport_StopAllRunning in sub_F0003C. Basis: table slot + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_k.json)
Seq_RequestRewindOnEvent:		; <- T_Seq_RequestRewindOnEvent
	ld	a, (UiEvent_Byte1:16)	; F4E525  ld A,(0x20b8)
	cp	a, 17	; F4E529  cp A,0x11
	jr	nz, Seq_RequestRewindOnEvent_Return	; F4E52C  jr NZ,0xf4e544
	ld	wa, (UiEvent_Byte2:16)	; F4E52E  ld WA,(0x20b9)
	and	a, w	; F4E532  and A,W
	bit	1, a	; F4E534  bit 0x01,A
	jr	z, Seq_RequestRewindOnEvent_Return	; F4E537  jr Z,0xf4e544
	cp	(UI_ScreenLatch:16), 0x0e	; F4E539  cp (0x207a),0x0e
	jr	z, Seq_RequestRewindOnEvent_Return	; F4E53E  jr Z,0xf4e544
	call	Seq_RequestRewindIfIdle	; F4E540  call 0xf4e545
Seq_RequestRewindOnEvent_Return:
	ret	; F4E544  ret

; --------------------------------------------------------------------------
; Seq_RequestRewindIfIdle
; Called from: in-module: 0xF4E540
; Touches: (0x3000)  |  0x000000
; Calls:   T_Seq_RequestRewind
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4E545 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_RequestRewindIfIdle: Calls T_Seq_RequestRewind when tracks play ((0x60341E) != 0), none is armed ((0x3000) = 0)
;   and transports A and B are stopped. Seq_RequestRewindOnEvent's body for the class-0xA8 code-0x11 bit-1 event.
;   Basis: caller header + body. (notes/naming-pilot-2026-10-06/proposals_wave5_p.json)
Seq_RequestRewindIfIdle:
	ld	xwa, (6304798:24)	; F4E545  ld XWA,(0x60341e)
	cp	xwa, 0	; F4E54A  cp XWA,0x00000000
	jr	z, Seq_RequestRewindIfIdle_Return	; F4E550  jr Z,0xf4e56e
	bit	2, (TransportB_State:8)	; F4E552  bit 2,(0x96)
	jr	nz, Seq_RequestRewindIfIdle_Return	; F4E555  jr NZ,0xf4e56e
	ld	xwa, (12288:16)	; F4E557  ld XWA,(0x3000)
	cp	xwa, 0	; F4E55B  cp XWA,0x00000000
	jr	nz, Seq_RequestRewindIfIdle_Return	; F4E561  jr NZ,0xf4e56e
	bit	2, (TransportA_State:8)	; F4E563  bit 2,(0x94)
	jr	nz, Seq_RequestRewindIfIdle_Return	; F4E566  jr NZ,0xf4e56e
	pushw	iy	; F4E568  push IY
	call	T_Seq_RequestRewind	; F4E569  call 0xf409e0
	popw	iy	; F4E56D  pop IY
Seq_RequestRewindIfIdle_Return:
	ret	; F4E56E  ret

; --------------------------------------------------------------------------
; SeqTrackKey_Press
; Called from: T_SeqTrackKey_Press (x24)
; Touches: (0x207A) (0x207C) (0x207E) (0x3602)
; Calls:   SeqTrackKey_UpdateTrackState
; Evidence: thunk slot T_SeqTrackKey_Press holds `jp 0x00F4E56F`, and 0xF4E56F is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrackKey_Press: Track key gate: with the track index the soft key left in (0x3602) <= 15, UI_ScreenStage != 1 and
;   UI_ScreenLatch == UI_ScreenId, calls SeqTrackKey_UpdateTrackState with C = that track, which per panel mode / screen updates the
;   track's bit in the track masks (0x3000)/(0x3002) and (0x60341E)/(0x603420). Basis: callers + body.
;   (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
SeqTrackKey_Press:		; <- T_SeqTrackKey_Press
	cp	(0x3602:16), 0x0f	; F4E56F  cp (0x3602),0x0f
	jr	ugt, SeqTrackKey_Press_Return2	; F4E574  jr UGT,0xf4e590
	cp	(UI_ScreenStage:16), 0x01	; F4E576  cp (0x207e),0x01
	jr	z, SeqTrackKey_Press_Return2	; F4E57B  jr Z,0xf4e590
	ld	a, (UI_ScreenLatch:16)	; F4E57D  ld A,(0x207a)
	cp	a, (UI_ScreenId:16)	; F4E581  cp A,(0x207c)
	jr	nz, SeqTrackKey_Press_Return2	; F4E585  jr NZ,0xf4e590
	xor	bc, bc	; F4E587  xor BC,BC
	ld	c, (13826:16)	; F4E589  ld C,(0x3602)
	calr	SeqTrackKey_UpdateTrackState	; F4E58D  calr 0xf4e05b
SeqTrackKey_Press_Return2:
	ret	; F4E590  ret

; --------------------------------------------------------------------------
; T_F40CB8_Nop
; Called from: T_F40CB8 (x0)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_F40CB8 holds `jp 0x00F4E591`, and 0xF4E591 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Purpose: none -- the entry is a lone `ret`.  Named T_F40CB8_Nop after what reaches it
;          (was sub_F4E591; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
T_F40CB8_Nop:		; <- T_F40CB8
	ret	; F4E591  ret

; --------------------------------------------------------------------------
; RealtimeRecordScreen_LcdKeyRow2
; Called from: T_RealtimeRecordScreen_LcdKeyRow2 (x1)
; Touches: (0x3000) (0x3002) (0x3736)  |  0x000000
; Calls:   SeqRecord_DisarmTrack
; Evidence: thunk slot T_RealtimeRecordScreen_LcdKeyRow2 holds `jp 0x00F4E592`, and 0xF4E592 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; RealtimeRecordScreen_LcdKeyRow2: the LcdKeyRow2 action of RealtimeRecordScreen -- called only by LcdKeyRow2_RealtimeRecordScreen.
RealtimeRecordScreen_LcdKeyRow2:		; <- T_RealtimeRecordScreen_LcdKeyRow2
	ld	xwa, (12288:16)	; F4E592  ld XWA,(0x3000)
	cp	xwa, 0	; F4E596  cp XWA,0x00000000
	jr	z, RealtimeRecordScreen_LcdKeyRow2_Return3	; F4E59C  jr Z,0xf4e5db
	xor	bc, bc	; F4E59E  xor BC,BC
RealtimeRecordScreen_LcdKeyRow2_Loop:
	cp	c, 16	; F4E5A0  cp C,0x10
	jr	nc, RealtimeRecordScreen_LcdKeyRow2_Skip	; F4E5A3  jr NC,0xf4e5b2
	ld	iz, (12288:16)	; F4E5A5  ld IZ,(0x3000)
	ld	a, c	; F4E5A9  ld A,C
	scf	; F4E5AB  scf
	xorcf_a_16	iz	; F4E5AC  xorcf A,IZ
	jr	nc, RealtimeRecordScreen_LcdKeyRow2_Join2	; F4E5AE  jr NC,0xf4e5c9
	jr	RealtimeRecordScreen_LcdKeyRow2_Join	; F4E5B0  jr T,0xf4e5c0
RealtimeRecordScreen_LcdKeyRow2_Skip:
	ld	iz, (12290:16)	; F4E5B2  ld IZ,(0x3002)
	ld	a, c	; F4E5B6  ld A,C
	sub	a, 16	; F4E5B8  sub A,0x10
	scf	; F4E5BB  scf
	xorcf_a_16	iz	; F4E5BC  xorcf A,IZ
	jr	nc, RealtimeRecordScreen_LcdKeyRow2_Join2	; F4E5BE  jr NC,0xf4e5c9
RealtimeRecordScreen_LcdKeyRow2_Join:
	inc	1, c	; F4E5C0  inc 1,C
	cp	c, 17	; F4E5C2  cp C,0x11
	jr	c, RealtimeRecordScreen_LcdKeyRow2_Loop	; F4E5C5  jr C,0xf4e5a0
	jr	RealtimeRecordScreen_LcdKeyRow2_Return3	; F4E5C7  jr T,0xf4e5db
RealtimeRecordScreen_LcdKeyRow2_Join2:
	inc	1, c	; F4E5C9  inc 1,C
	cp	c, 17	; F4E5CB  cp C,0x11
	jr	nc, RealtimeRecordScreen_LcdKeyRow2_Return3	; F4E5CE  jr NC,0xf4e5db
	ld	(14134:16), c	; F4E5D0  ld (0x3736),C
	pushw	bc	; F4E5D4  push BC
	calr	SeqRecord_DisarmTrack	; F4E5D5  calr 0xf4e151
	popw	bc	; F4E5D8  pop BC
	jr	RealtimeRecordScreen_LcdKeyRow2_Join2	; F4E5D9  jr T,0xf4e5c9
RealtimeRecordScreen_LcdKeyRow2_Return3:
	ret	; F4E5DB  ret

; --------------------------------------------------------------------------
; IdentityMap_F4E5DC -- 32 bytes, and entry k = k for every k.  The name
;                       describes the CONTENT and claims nothing about the
;                       purpose.
; Read by: one site: `ld XIX,0x00f4e5dc` at 0xF4E234.  (The byte scan for
;          the address hits 0xF4E235, which is that instruction's OPERAND
;          field, 1 byte in.)
; Entry count: 32, from the island's own extent: 0xF4E5FC starts
;              BitWeight_F4E5FC, whose own reader is at 0xF4E510.
; Evidence: all 32 bytes are re-read and compared with 0..31 on every emit.
; Unknown: why an identity map exists at all.  A table that returns its own
;          index changes nothing at run time.  prom_b has a THIRD one at
;          0xF5EE75 (IdentityMap_0_31, converted in round 2) with the same
;          content and the same open question; three copies is a fact this
;          records, not an explanation.
; --------------------------------------------------------------------------
IdentityMap_F4E5DC:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F4E5DC  [0..15]
	.byte	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F	; F4E5EC  [16..31]


; --------------------------------------------------------------------------
; BitWeight_F4E5FC -- sixteen 16-bit little-endian words, entry k = 1 << k:
;                     0x0001, 0x0002, 0x0004 ... 0x8000.  Content-
;                     descriptive name, asserted word for word on every
;                     emit.
; Read by: one site: `ld XIX,0x00f4e5fc` at 0xF4E510.  (The byte scan for
;          the address hits 0xF4E511, which is that instruction's OPERAND
;          field, 1 byte in.)
; Entry count: 16 words = 32 bytes.  The island runs from the end of
;              IdentityMap_F4E5DC to 0xF4E61C, where the module's 0x0E
;              padding starts, and 32 bytes hold exactly sixteen 1<<k
;              weights with nothing left over -- a seventeenth would need
;              the padding byte.
; Evidence: every word is unpacked and compared with 1 << k on every emit.
; Unknown: which 16 flags the weights index.
; --------------------------------------------------------------------------
BitWeight_F4E5FC:
	.short	0x0001	; F4E5FC  [0] = 1 << 0
	.short	0x0002	; F4E5FE  [1] = 1 << 1
	.short	0x0004	; F4E600  [2] = 1 << 2
	.short	0x0008	; F4E602  [3] = 1 << 3
	.short	0x0010	; F4E604  [4] = 1 << 4
	.short	0x0020	; F4E606  [5] = 1 << 5
	.short	0x0040	; F4E608  [6] = 1 << 6
	.short	0x0080	; F4E60A  [7] = 1 << 7
	.short	0x0100	; F4E60C  [8] = 1 << 8
	.short	0x0200	; F4E60E  [9] = 1 << 9
	.short	0x0400	; F4E610  [10] = 1 << 10
	.short	0x0800	; F4E612  [11] = 1 << 11
	.short	0x1000	; F4E614  [12] = 1 << 12
	.short	0x2000	; F4E616  [13] = 1 << 13
	.short	0x4000	; F4E618  [14] = 1 << 14
	.short	0x8000	; F4E61A  [15] = 1 << 15

	.fill	1508, 1, 0x0E	; F4E61C-F4EBFF  `ret` padding (asserted pure 0x0E)
