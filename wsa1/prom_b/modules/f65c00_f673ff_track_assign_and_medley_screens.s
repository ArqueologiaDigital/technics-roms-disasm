

; --------------------------------------------------------------------------
; sub_F65C00
; Called from: T_F42BB4 (x1)
; Touches: (0x2130) (0x215E)
; Evidence: thunk slot T_F42BB4 holds `jp 0x00F65C00`, and 0xF65C00 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F65C00:		; <- T_F42BB4
	orw	(0x2130:16), 0x0100	; F65C00  or (0x2130),0x0100
	ldw	(8542:16), 0	; F65C06  ld (0x215e),0x0000
	ret	; F65C0C  ret

; --------------------------------------------------------------------------
; sub_F65C0D
; Called from: T_F42BB8 (x1)
; Touches: (0x212E) (0x2130) (0x2160)
; Calls:   sub_F65C0D_Nop sub_F65C27
; Evidence: thunk slot T_F42BB8 holds `jp 0x00F65C0D`, and 0xF65C0D is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F65C0D:		; <- T_F42BB8
	andw	(0x2130:16), 0xfeff	; F65C0D  and (0x2130),0xfeff
	orw	(0x212e:16), 0x0100	; F65C13  or (0x212e),0x0100
	ldw	(8544:16), 0	; F65C19  ld (0x2160),0x0000
	calr	sub_F65C0D_Nop	; F65C1F  calr 0xf665b3
	call	sub_F65C27	; F65C22  call 0xf65c27
	ret	; F65C26  ret

; --------------------------------------------------------------------------
; sub_F65C27
; Called from: in-module: 0xF65C22
; Touches: (0x360A)  |  0x603400 0x610000
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF65C27 is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F65C27:
	push	xhl	; F65C27  push XHL
	push	xbc	; F65C28  push XBC
	push	xix	; F65C29  push XIX
	push	xiy	; F65C2A  push XIY
	ld	xix, 6356992	; F65C2B  ld XIX,0x00610000
	xor	xhl, xhl	; F65C30  xor XHL,XHL
	ld	l, (BStore_CurrentBank:16)	; F65C32  ld L,(0x360a)
	ld	xbc, xhl	; F65C36  ld XBC,XHL
	sla	xhl, 11	; F65C38  sla 0x0b,XHL
	sla	xbc, 10	; F65C3B  sla 0x0a,XBC
	add	xhl, xbc	; F65C3E  add XHL,XBC
	add	xix, xhl	; F65C40  add XIX,XHL
	ld	xiy, 6304768	; F65C42  ld XIY,0x00603400
	ldw	bc, 3072	; F65C47  ld BC,0x0c00
	ldir85	; F65C4A  ldir
	pop	xiy	; F65C4C  pop XIY
	pop	xix	; F65C4D  pop XIX
	pop	xbc	; F65C4E  pop XBC
	pop	xhl	; F65C4F  pop XHL
	ret	; F65C50  ret

; --------------------------------------------------------------------------
; sub_F65C51
; Called from: T_F42B70 (x1)
; Touches: (0x0C00) (0x0C02)
; Evidence: thunk slot T_F42B70 holds `jp 0x00F65C51`, and 0xF65C51 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F65C51:		; <- T_F42B70
	ld	(3074:16), 2	; F65C51  ld (0x0c02),0x02
	ldw	(3072:16), 0	; F65C56  ld (0x0c00),0x0000
	ret	; F65C5C  ret
	ret	; F65C5D  ret

; --------------------------------------------------------------------------
; TrackAssign_StageZero_LcdKeyRow2
; Called from: T_TrackAssign_StageZero_LcdKeyRow2 (x1)
; Touches: (0x0C03) (0x0C06) (0x0C07) (0x0DC0)  |  0x603422
; Calls:   TrackAssign_CommitEditedPart
; Evidence: thunk slot T_TrackAssign_StageZero_LcdKeyRow2 holds `jp 0x00F65C5E`, and 0xF65C5E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssign_StageZero_LcdKeyRow2: the LcdKeyRow2 action of TrackAssign_StageZero -- called only by LcdKeyRow2_TrackAssign_StageZero.
TrackAssign_StageZero_LcdKeyRow2:		; <- T_TrackAssign_StageZero_LcdKeyRow2
	calr	TrackAssign_CommitEditedPart	; F65C5E  calr 0xf65d26
	ld	(3520:16), 0	; F65C61  ld (0x0dc0),0x00
	ld	a, (3075:16)	; F65C66  ld A,(0x0c03)
	bit	0, (0x0c07:16)	; F65C6A  bit 0,(0x0c07)
	jr	nz, TrackAssign_StageZero_LcdKeyRow2_Skip	; F65C6E  jr NZ,0xf65c78
	cp	a, 7:i3	; F65C70  cp A,7
	jr	z, TrackAssign_StageZero_LcdKeyRow2_Join	; F65C72  jr Z,0xf65c7f
	inc	1, a	; F65C74  inc 1,A
	jr	TrackAssign_StageZero_LcdKeyRow2_Join	; F65C76  jr T,0xf65c7f
TrackAssign_StageZero_LcdKeyRow2_Skip:
	cp	a, 15	; F65C78  cp A,0x0f
	jr	z, TrackAssign_StageZero_LcdKeyRow2_Join	; F65C7B  jr Z,0xf65c7f
	inc	1, a	; F65C7D  inc 1,A
TrackAssign_StageZero_LcdKeyRow2_Join:
	ld	(3075:16), a	; F65C7F  ld (0x0c03),A
	ld	xhl, BStore_TrackToPart	; F65C83  ld XHL,0x00603422
	xor	wa, wa	; F65C88  xor WA,WA
	ld	a, (3075:16)	; F65C8A  ld A,(0x0c03)
	ld	iy, wa	; F65C8E  ld IY,WA
	ld	a, (xhl+iy)	; F65C90  ld A,(XHL+IY)
	ld	(3078:16), a	; F65C95  ld (0x0c06),A
	ret	; F65C99  ret

; --------------------------------------------------------------------------
; TrackAssign_StageZero_LcdKeyRow1
; Called from: T_TrackAssign_StageZero_LcdKeyRow1 (x1)
; Touches: (0x0C03) (0x0C06) (0x0C07) (0x0DC0)  |  0x603422
; Calls:   TrackAssign_CommitEditedPart
; Evidence: thunk slot T_TrackAssign_StageZero_LcdKeyRow1 holds `jp 0x00F65C9A`, and 0xF65C9A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssign_StageZero_LcdKeyRow1: the LcdKeyRow1 action of TrackAssign_StageZero -- called only by LcdKeyRow1_TrackAssign_StageZero.
TrackAssign_StageZero_LcdKeyRow1:		; <- T_TrackAssign_StageZero_LcdKeyRow1
	calr	TrackAssign_CommitEditedPart	; F65C9A  calr 0xf65d26
	ld	(3520:16), 0	; F65C9D  ld (0x0dc0),0x00
	ld	a, (3075:16)	; F65CA2  ld A,(0x0c03)
	bit	0, (0x0c07:16)	; F65CA6  bit 0,(0x0c07)
	jr	nz, TrackAssign_StageZero_LcdKeyRow1_Skip	; F65CAA  jr NZ,0xf65cb4
	cp	a, 0:i3	; F65CAC  cp A,0
	jr	z, TrackAssign_StageZero_LcdKeyRow1_Join	; F65CAE  jr Z,0xf65cbb
	dec	1, a	; F65CB0  dec 1,A
	jr	TrackAssign_StageZero_LcdKeyRow1_Join	; F65CB2  jr T,0xf65cbb
TrackAssign_StageZero_LcdKeyRow1_Skip:
	cp	a, 8	; F65CB4  cp A,0x08
	jr	z, TrackAssign_StageZero_LcdKeyRow1_Join	; F65CB7  jr Z,0xf65cbb
	dec	1, a	; F65CB9  dec 1,A
TrackAssign_StageZero_LcdKeyRow1_Join:
	ld	(3075:16), a	; F65CBB  ld (0x0c03),A
	ld	xhl, BStore_TrackToPart	; F65CBF  ld XHL,0x00603422
	xor	wa, wa	; F65CC4  xor WA,WA
	ld	a, (3075:16)	; F65CC6  ld A,(0x0c03)
	ld	iy, wa	; F65CCA  ld IY,WA
	ld	a, (xhl+iy)	; F65CCC  ld A,(XHL+IY)
	ld	(3078:16), a	; F65CD1  ld (0x0c06),A
	ret	; F65CD5  ret

; --------------------------------------------------------------------------
; TrackAssign_SelectTrackGroup
; Called from: T_TrackAssign_SelectTrackGroup (x2)
; Touches: (0x0C03) (0x0C06) (0x0C07) (0x0DC0)  |  0x603422
; Calls:   TrackAssign_CommitEditedPart
; Evidence: thunk slot T_TrackAssign_SelectTrackGroup holds `jp 0x00F65CD6`, and 0xF65CD6 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssign_SelectTrackGroup: BC = 10 (LcdKeyRow3) clears (0x0C07) bit 0 and sets (0x0C03) = 0; BC = 11 (LcdKeyRow4) sets the bit and (0x0C03) = 8;
;   then (0x0C06) = the byte map 0x603422[(0x0C03)].  Called by LcdKeyRow3/4_TrackAssign_StageZero.
TrackAssign_SelectTrackGroup:		; <- T_TrackAssign_SelectTrackGroup
	cp	bc, 10	; F65CD6  cp BC,0x000a
	jr	z, TrackAssign_SelectTrackGroup_Skip	; F65CDA  jr Z,0xf65ce3
	cp	bc, 11	; F65CDC  cp BC,0x000b
	jr	z, TrackAssign_SelectTrackGroup_Skip2	; F65CE0  jr Z,0xf65cf7
	ret	; F65CE2  ret
TrackAssign_SelectTrackGroup_Skip:
	calr	TrackAssign_CommitEditedPart	; F65CE3  calr 0xf65d26
	ld	(3520:16), 0	; F65CE6  ld (0x0dc0),0x00
	and	(0x0c07:16), 0xfe	; F65CEB  and (0x0c07),0xfe
	ld	(3075:16), 0	; F65CF0  ld (0x0c03),0x00
	jr	TrackAssign_SelectTrackGroup_Join	; F65CF5  jr T,0xf65d04
TrackAssign_SelectTrackGroup_Skip2:
	calr	TrackAssign_CommitEditedPart	; F65CF7  calr 0xf65d26
	ld	(3520:16), 0	; F65CFA  ld (0x0dc0),0x00
	or	(0x0c07:16), 0x01	; F65CFF  or (0x0c07),0x01
TrackAssign_SelectTrackGroup_Join:
	bit	0, (0x0c07:16)	; F65D04  bit 0,(0x0c07)
	jr	z, TrackAssign_SelectTrackGroup_Skip3	; F65D08  jr Z,0xf65d0f
	ld	(3075:16), 8	; F65D0A  ld (0x0c03),0x08
TrackAssign_SelectTrackGroup_Skip3:
	ld	xhl, BStore_TrackToPart	; F65D0F  ld XHL,0x00603422
	xor	wa, wa	; F65D14  xor WA,WA
	ld	a, (3075:16)	; F65D16  ld A,(0x0c03)
	ld	iy, wa	; F65D1A  ld IY,WA
	ld	a, (xhl+iy)	; F65D1C  ld A,(XHL+IY)
	ld	(3078:16), a	; F65D21  ld (0x0c06),A
	ret	; F65D25  ret

; --------------------------------------------------------------------------
; TrackAssign_CommitEditedPart
; Called from: in-module: 0xF65C5E 0xF65C9A 0xF65CE3 0xF65CF7 0xF66564
; Touches: (0x0C03) (0x0C06) (0x0C83) (0x0DCF)  |  0x603422
; Calls:   T_BStore_Veneers T_NoteRouting_RebuildForSong
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF65D26 is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssign_CommitEditedPart: If the edited part (0x0C06) differs from BStore_TrackToPart[(0x0C03)], writes it there
;   (the old part goes back to (0x0C06)), sets (0x0DCF) and (0x0C83) = track, runs T_BStore_Veneers (BStore_ApplyTrackPartChange
;   reworks the track) and rebuilds note routing. TRACK ASSIGN calls it before moving the track cursor and on leave.
;   Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave2_f.json)
TrackAssign_CommitEditedPart:
	xor	wa, wa	; F65D26  xor WA,WA
	ld	a, (3075:16)	; F65D28  ld A,(0x0c03)
	ld	iy, wa	; F65D2C  ld IY,WA
	push	xde	; F65D2E  push XDE
	ld	xde, BStore_TrackToPart	; F65D2F  ld XDE,0x00603422
	ld	a, (xde+iy)	; F65D34  ld A,(XDE+IY)
	pop	xde	; F65D39  pop XDE
	cp	a, (0x0c06:16)	; F65D3A  cp A,(0x0c06)
	jr	nz, TrackAssign_CommitEditedPart_Skip	; F65D3E  jr NZ,0xf65d41
	ret	; F65D40  ret
TrackAssign_CommitEditedPart_Skip:
	ld	a, (3078:16)	; F65D41  ld A,(0x0c06)
	xor	w, w	; F65D45  xor W,W
	ld	iy, wa	; F65D47  ld IY,WA
	push	xde	; F65D49  push XDE
	ld	xde, MaskTable_F65F5C	; F65D4A  ld XDE,0x00f65f5c
	ld	c, (xde+iy)	; F65D4F  ld C,(XDE+IY)
	ld	a, (3075:16)	; F65D54  ld A,(0x0c03)
	ld	iy, wa	; F65D58  ld IY,WA
	ld	xde, BStore_TrackToPart	; F65D5A  ld XDE,0x00603422
	ld	a, (xde+iy)	; F65D5F  ld A,(XDE+IY)
	ld	iy, wa	; F65D64  ld IY,WA
	ld	xde, MaskTable_F65F5C	; F65D66  ld XDE,0x00f65f5c
	ld	a, (xde+iy)	; F65D6B  ld A,(XDE+IY)
	pop	xde	; F65D70  pop XDE
	and	a, c	; F65D71  and A,C
	cp	a, 0:i3	; F65D73  cp A,0
	jr	z, TrackAssign_CommitEditedPart_Return	; F65D75  jr Z,0xf65d79
	jr	TrackAssign_CommitEditedPart_Join	; F65D77  jr T,0xf65d7a
TrackAssign_CommitEditedPart_Return:
	ret	; F65D79  ret
TrackAssign_CommitEditedPart_Join:
	ld	xhl, BStore_TrackToPart	; F65D7A  ld XHL,0x00603422
	xor	wa, wa	; F65D7F  xor WA,WA
	ld	a, (3075:16)	; F65D81  ld A,(0x0c03)
	ld	iy, wa	; F65D85  ld IY,WA
	ld	a, (3078:16)	; F65D87  ld A,(0x0c06)
	ld	c, (xhl+iy)	; F65D8B  ld C,(XHL+IY)
	ld	(3078:16), c	; F65D90  ld (0x0c06),C
	ld	(xhl+iy), a	; F65D94  ld (XHL+IY),A
	ld	(3535:16), a	; F65D99  ld (0x0dcf),A
	ld	a, (3075:16)	; F65D9D  ld A,(0x0c03)
	ld	(3203:16), a	; F65DA1  ld (0x0c83),A
	call	T_BStore_Veneers	; F65DA5  call 0xf42800
	call	T_NoteRouting_RebuildForSong	; F65DA9  call 0xf411b8
	ret	; F65DAD  ret

; --------------------------------------------------------------------------
; TrackAssign_IsLocalControlDashed_Copy
; Called from: T_TrackAssign_IsLocalControlDashed_Copy (x1)
; Touches: (0x0C03) (0x0C06)  |  0x603422
; Evidence: thunk slot T_TrackAssign_IsLocalControlDashed_Copy holds `jp 0x00F65DAE`, and 0xF65DAE is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssign_IsLocalControlDashed_Copy: an exact copy of TrackAssign_IsLocalControlDashed (prom_b 0xF65DD3) -- all 13 instructions equal, operands included,
;   but the targets of its jr / jrl / djnz (notes/wsa1_exact_copy_names.py).
TrackAssign_IsLocalControlDashed_Copy:		; <- T_TrackAssign_IsLocalControlDashed_Copy
	cp	a, (0x0c03:16)	; F65DAE  cp A,(0x0c03)
	jr	z, TrackAssign_IsLocalControlDashed_Copy_Skip2	; F65DB2  jr Z,0xf65dc4
	ld	xhl, BStore_TrackToPart	; F65DB4  ld XHL,0x00603422
	xor	w, w	; F65DB9  xor W,W
	ld	iy, wa	; F65DBB  ld IY,WA
	ld	a, (xhl+iy)	; F65DBD  ld A,(XHL+IY)
	jr	TrackAssign_IsLocalControlDashed_Copy_Join2	; F65DC2  jr T,0xf65dc8
TrackAssign_IsLocalControlDashed_Copy_Skip2:
	ld	a, (3078:16)	; F65DC4  ld A,(0x0c06)
TrackAssign_IsLocalControlDashed_Copy_Join2:
	ld	a, 170:opc	; F65DC8  ld A,0xaa
	jr	TrackAssign_IsLocalControlDashed_Copy_Return	; F65DCA  jr T,0xf65dd2

; --------------------------------------------------------------------------
; UNREACHED CODE, not data (was `Data_F65DCC`), part of TrackAssign_IsLocalControlDashed_Copy:
;   `ld A,0x55 / ld W,(0x0C03)` beside the arm that sets A = 0xAA; (0x0C03) is the cell the
;   routine compares A with at its entry (0xF65DAE); the decode ends on the `ret` the jr above
;   targets.
;   Nothing in prom_b branches to, calls or spells 0xF65DCC (code_islands.py searches every
;   jr/jrl/calr displacement and jp/call/24-bit operand); it is recorded as code because it
;   decodes as such and fits the code beside it, not because it runs.
; --------------------------------------------------------------------------
	ld	a, 85:opc	; F65DCC  ld A,0x55
	ld	w, (3075:16)	; F65DCE  ld W,(0x0c03)

TrackAssign_IsLocalControlDashed_Copy_Return:
	ret	; F65DD2  ret

; --------------------------------------------------------------------------
; TrackAssign_IsLocalControlDashed
; Called from: T_TrackAssign_IsLocalControlDashed (x2)
; Touches: (0x0C03) (0x0C06)  |  0x603422
; Evidence: thunk slot T_TrackAssign_IsLocalControlDashed holds `jp 0x00F65DD3`, and 0xF65DD3 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssign_IsLocalControlDashed: Returns A = 0x55 when track A's LOCAL CONTROL cell should read '-- ', else 0xAA;
;   in this build always 0xAA -- the part lookup ((0x0C06) for the selected track (0x0C03), else
;   BStore_TrackToPart[A]) is overwritten and the 0x55 arm is unreached. TrackAssign_DrawLocalControlColumn and prom_a
;   sub_F819A2 test it. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave9_d9.json)
TrackAssign_IsLocalControlDashed:		; <- T_TrackAssign_IsLocalControlDashed
	cp	a, (0x0c03:16)	; F65DD3  cp A,(0x0c03)
	jr	z, TrackAssign_IsLocalControlDashed_Skip	; F65DD7  jr Z,0xf65de9
	ld	xhl, BStore_TrackToPart	; F65DD9  ld XHL,0x00603422
	xor	w, w	; F65DDE  xor W,W
	ld	iy, wa	; F65DE0  ld IY,WA
	ld	a, (xhl+iy)	; F65DE2  ld A,(XHL+IY)
	jr	TrackAssign_IsLocalControlDashed_Join	; F65DE7  jr T,0xf65ded
TrackAssign_IsLocalControlDashed_Skip:
	ld	a, (3078:16)	; F65DE9  ld A,(0x0c06)
TrackAssign_IsLocalControlDashed_Join:
	ld	a, 170:opc	; F65DED  ld A,0xaa
	jr	TrackAssign_IsLocalControlDashed_Return	; F65DEF  jr T,0xf65df7

; --------------------------------------------------------------------------
; UNREACHED CODE, not data (was `Data_F65DF1`), part of TrackAssign_IsLocalControlDashed:
;   the same six bytes as 0xF65DCC, in the next routine.
;   Nothing in prom_b branches to, calls or spells 0xF65DF1 (code_islands.py searches every
;   jr/jrl/calr displacement and jp/call/24-bit operand); it is recorded as code because it
;   decodes as such and fits the code beside it, not because it runs.
; --------------------------------------------------------------------------
	ld	a, 85:opc	; F65DF1  ld A,0x55
	ld	w, (3075:16)	; F65DF3  ld W,(0x0c03)

TrackAssign_IsLocalControlDashed_Return:
	ret	; F65DF7  ret

; --------------------------------------------------------------------------
; TrackAssign_StageZero_SoftKeyCol4
; Called from: T_TrackAssign_StageZero_SoftKeyCol4 (x1)
; Touches: (0x0C03) (0x0C06) (0x0DC0) (0x2075)  |  0x603422
; Evidence: thunk slot T_TrackAssign_StageZero_SoftKeyCol4 holds `jp 0x00F65DF8`, and 0xF65DF8 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssign_StageZero_SoftKeyCol4: the SoftKeyCol4 action of TrackAssign_StageZero -- called only by SoftKeyCol4_TrackAssign_StageZero.
TrackAssign_StageZero_SoftKeyCol4:		; <- T_TrackAssign_StageZero_SoftKeyCol4
	bit	2, (TransportB_State:8)	; F65DF8  bit 2,(0x96)
	jr	z, TrackAssign_StageZero_SoftKeyCol4_Skip	; F65DFB  jr Z,0xf65dfe
	ret	; F65DFD  ret
TrackAssign_StageZero_SoftKeyCol4_Skip:
	or	(UI_RequestBits:16), 0x08	; F65DFE  or (0x2075),0x08
	ld	a, (3078:16)	; F65E03  ld A,(0x0c06)
	bit	7, w	; F65E07  bit 0x07,W
	jr	z, TrackAssign_StageZero_SoftKeyCol4_Skip2	; F65E0A  jr Z,0xf65e26
	cp	a, 0:i3	; F65E0C  cp A,0
	jr	z, TrackAssign_StageZero_SoftKeyCol4_Join	; F65E0E  jr Z,0xf65e3f
	ld	l, a	; F65E10  ld L,A
	xor	h, h	; F65E12  xor H,H
	push	xde	; F65E14  push XDE
	ld	xde, ClampDec_0to31	; F65E15  ld XDE,0x00f65e54
	ld	a, (xde+hl)	; F65E1A  ld A,(XDE+HL)
	pop	xde	; F65E1F  pop XDE
	ld	(3078:16), a	; F65E20  ld (0x0c06),A
	jr	TrackAssign_StageZero_SoftKeyCol4_Join	; F65E24  jr T,0xf65e3f
TrackAssign_StageZero_SoftKeyCol4_Skip2:
	cp	a, 31	; F65E26  cp A,0x1f
	jr	z, TrackAssign_StageZero_SoftKeyCol4_Join	; F65E29  jr Z,0xf65e3f
	ld	l, a	; F65E2B  ld L,A
	xor	h, h	; F65E2D  xor H,H
	push	xde	; F65E2F  push XDE
	ld	xde, ClampInc_0to31	; F65E30  ld XDE,0x00f65e74
	ld	a, (xde+hl)	; F65E35  ld A,(XDE+HL)
	pop	xde	; F65E3A  pop XDE
	ld	(3078:16), a	; F65E3B  ld (0x0c06),A
TrackAssign_StageZero_SoftKeyCol4_Join:
	ld	(3520:16), 0	; F65E3F  ld (0x0dc0),0x00
	ld	xhl, BStore_TrackToPart	; F65E44  ld XHL,0x00603422
	xor	w, w	; F65E49  xor W,W
	ld	a, (3075:16)	; F65E4B  ld A,(0x0c03)
	ld	iy, wa	; F65E4F  ld IY,WA
	jr	TrackAssign_StageZero_SoftKeyCol4_Return	; F65E51  jr T,0xf65e53
TrackAssign_StageZero_SoftKeyCol4_Return:
	ret	; F65E53  ret
; --------------------------------------------------------------------------
; ClampDec_0to31 -- 0xF65E54-0xF65E73, 32 bytes: entry k is k-1 (k = 1..31);
;   entry 0 (0x00) is never read.  ClampInc_0to31 -- 0xF65E74-0xF65E93, 32
;   bytes: entry k is k+1 (k = 0..30); entry 31 (0x1F) is never read.
;   Converted 2026-09-25 (lane promb).
; Read by: TrackAssign_StageZero_SoftKeyCol4, on the byte at (0x0C06): with bit 7 of W set it skips
;   when the byte is 0 and otherwise does `ld XDE,0x00F65E54 / ld A,(XDE+HL)`
;   (0xF65E15); with bit 7 clear it skips when the byte is 0x1F and otherwise
;   does `ld XDE,0x00F65E74 / ld A,(XDE+HL)` (0xF65E30); either way the result
;   goes back to (0x0C06).  So the pair steps a 0..31 value down or up by one
;   without wrapping, and the two entries the guards exclude are the ones
;   that would leave the range.
; ⚠ CORRECTED 2026-09-25: these 64 bytes were `sub_F65E54` (a label this
;   lane's own pointer pass put on the first byte, which the source had
;   framed as a `nop`), `IndexMap_F65E55` (62 bytes, "read by nothing" -- the
;   reader names 0xF65E54 and 0xF65E74, never 0xF65E55 -- and filed as an
;   index map of unexplained purpose) and `Data_F65E93` (one byte, filed as
;   nothing known but its bytes).  The boundaries were one byte off at both
;   ends; the reader fixes them.
; --------------------------------------------------------------------------
ClampDec_0to31:
	.byte	0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E	; F65E54  [0..15]
	.byte	0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E	; F65E64  [16..31]
ClampInc_0to31:
	.byte	0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10	; F65E74  [0..15]
	.byte	0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x1F	; F65E84  [16..31]


; --------------------------------------------------------------------------
; TrackAssign_StageZero_LcdKeyRow3
; Called from: T_TrackAssign_StageZero_LcdKeyRow3 (x1)
; Touches: nothing with an absolute address
; Calls:   sub_F65E98
; Evidence: thunk slot T_TrackAssign_StageZero_LcdKeyRow3 holds `jp 0x00F65E94`, and 0xF65E94 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssign_StageZero_LcdKeyRow3: the LcdKeyRow3 action of TrackAssign_StageZero -- called only by LcdKeyRow3_TrackAssign_StageZero.
TrackAssign_StageZero_LcdKeyRow3:		; <- T_TrackAssign_StageZero_LcdKeyRow3
	calr	sub_F65E98	; F65E94  calr 0xf65e98
	ret	; F65E97  ret

; --------------------------------------------------------------------------
; sub_F65E98
; Called from: in-module: 0xF65E94
; Touches: (0x0C03) (0x0C06) (0x0C0D) (0x0C83) (0x0DCF) (0x2071) (0x2075)
;          (0x207E)  |  0x603422
; Calls:   T_BStore_Veneers T_NoteRouting_RebuildForSong
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF65E98 is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F65E98:
	and	(UI_RequestBits:16), 0xf7	; F65E98  and (0x2075),0xf7
	bit	2, (TransportC_State:8)	; F65E9D  bit 2,(0x95)
	jr	z, sub_F65E98_Skip	; F65EA0  jr Z,0xf65ea3
	ret	; F65EA2  ret
sub_F65E98_Skip:
	xor	wa, wa	; F65EA3  xor WA,WA
	ld	a, (3075:16)	; F65EA5  ld A,(0x0c03)
	ld	iy, wa	; F65EA9  ld IY,WA
	push	xde	; F65EAB  push XDE
	ld	xde, BStore_TrackToPart	; F65EAC  ld XDE,0x00603422
	ld	a, (xde+iy)	; F65EB1  ld A,(XDE+IY)
	pop	xde	; F65EB6  pop XDE
	cp	a, (0x0c06:16)	; F65EB7  cp A,(0x0c06)
	jr	nz, sub_F65E98_Return	; F65EBB  jr NZ,0xf65ec5
	ld	(UI_ScreenStage:16), 0	; F65EBD  ld (0x207e),0x00
	jrl	sub_F65E98_Return	; F65EC2  jrl T,0xf65ec5
sub_F65E98_Return:
	ret	; F65EC5  ret
	ld	a, (3078:16)	; F65EC6  ld A,(0x0c06)
	xor	w, w	; F65ECA  xor W,W
	ld	iy, wa	; F65ECC  ld IY,WA
	push	xde	; F65ECE  push XDE
	ld	xde, MaskTable_F65F5C	; F65ECF  ld XDE,0x00f65f5c
	ld	c, (xde+iy)	; F65ED4  ld C,(XDE+IY)
	ld	a, (3075:16)	; F65ED9  ld A,(0x0c03)
	ld	iy, wa	; F65EDD  ld IY,WA
	ld	xde, BStore_TrackToPart	; F65EDF  ld XDE,0x00603422
	ld	a, (xde+iy)	; F65EE4  ld A,(XDE+IY)
	ld	(3085:16), a	; F65EE9  ld (0x0c0d),A
	ld	iy, wa	; F65EED  ld IY,WA
	ld	xde, MaskTable_F65F5C	; F65EEF  ld XDE,0x00f65f5c
	ld	a, (xde+iy)	; F65EF4  ld A,(XDE+IY)
	pop	xde	; F65EF9  pop XDE
	and	a, c	; F65EFA  and A,C
	cp	a, 0:i3	; F65EFC  cp A,0
	jr	z, sub_F65E98_Skip2	; F65EFE  jr Z,0xf65f02
	jr	sub_F65E98_Join	; F65F00  jr T,0xf65f23
sub_F65E98_Skip2:
	ld	a, (3075:16)	; F65F02  ld A,(0x0c03)
	ld	iy, wa	; F65F06  ld IY,WA
	push	xde	; F65F08  push XDE
	ld	xde, BStore_TrackToPart	; F65F09  ld XDE,0x00603422
	ld	a, (xde+iy)	; F65F0E  ld A,(XDE+IY)
	pop	xde	; F65F13  pop XDE
	ld	(3085:16), a	; F65F14  ld (0x0c0d),A
	ld	(UI_ScreenStage:16), 1	; F65F18  ld (0x207e),0x01
	or	(UI_Request_Hi:16), 0x10	; F65F1D  or (0x2071),0x10
	ret	; F65F22  ret
sub_F65E98_Join:
	ld	xhl, BStore_TrackToPart	; F65F23  ld XHL,0x00603422
	xor	wa, wa	; F65F28  xor WA,WA
	ld	a, (3075:16)	; F65F2A  ld A,(0x0c03)
	ld	iy, wa	; F65F2E  ld IY,WA
	ld	a, (3078:16)	; F65F30  ld A,(0x0c06)
	ld	c, (xhl+iy)	; F65F34  ld C,(XHL+IY)
	ld	(3078:16), c	; F65F39  ld (0x0c06),C
	ld	(xhl+iy), a	; F65F3D  ld (XHL+IY),A
	ld	(3535:16), a	; F65F42  ld (0x0dcf),A
	ld	a, (3075:16)	; F65F46  ld A,(0x0c03)
	ld	(3203:16), a	; F65F4A  ld (0x0c83),A
	call	T_BStore_Veneers	; F65F4E  call 0xf42800
	call	T_NoteRouting_RebuildForSong	; F65F52  call 0xf411b8
	ld	(UI_ScreenStage:16), 0	; F65F56  ld (0x207e),0x00
	ret	; F65F5B  ret
; --------------------------------------------------------------------------
; MaskTable_F65F5C -- 0xF65F5C-0xF65F7B, 32 bytes, every one 0xFF.
;   Converted 2026-09-25 (lane promb): the source framed them as 32 `swi 7`.
; Read by: TrackAssign_CommitEditedPart (0xF65D4A, 0xF65D66) and sub_F65E98 (0xF65ECF,
;   0xF65EEF), each twice: C = entry[(0x0C06)] and A = entry[(0x603422 +
;   (0x0C03))], then `and A,C` and a jump on zero.  With every entry 0xFF the
;   AND is zero only if one looked-up byte is zero, which no entry is -- so in
;   this build the table admits everything.
; Entry count: 32, the range ClampDec_0to31 / ClampInc_0to31 keep (0x0C06)
;   in; the table ends where TrackAssign_StageZero_SoftKeyCol5, a thunk target, begins.
; Unknown: what a zero entry would have excluded, and why 0x603422's byte
;   (which can be 0x20, per ByteMap_F6F985) would index past entry 31.
; --------------------------------------------------------------------------
MaskTable_F65F5C:
	.byte	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF	; F65F5C  [0..15]
	.byte	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF	; F65F6C  [16..31]

; --------------------------------------------------------------------------
; TrackAssign_StageZero_SoftKeyCol5
; Called from: T_TrackAssign_StageZero_SoftKeyCol5 (x1)
; Touches: (0x0C03) (0x2075)
; Calls:   T_NoteRouting_RebuildForSong
; Evidence: thunk slot T_TrackAssign_StageZero_SoftKeyCol5 holds `jp 0x00F65F7C`, and 0xF65F7C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssign_StageZero_SoftKeyCol5: the SoftKeyCol5 action of TrackAssign_StageZero -- called only by SoftKeyCol5_TrackAssign_StageZero.
TrackAssign_StageZero_SoftKeyCol5:		; <- T_TrackAssign_StageZero_SoftKeyCol5
	bit	2, (TransportB_State:8)	; F65F7C  bit 2,(0x96)
	jr	nz, sub_F65F7C_Return	; F65F7F  jr NZ,0xf65fdc
	ld	c, (3075:16)	; F65F81  ld C,(0x0c03)
	ld	wa, (6304852:24)	; F65F85  ld WA,(0x603454)
	ldfr_berp	a, 0x3c	; F65F8A  ld RL3,A
	ldfr_werp	wa, 0x3e	; F65F8D  ld QHL3,WA
	ld	a, c	; F65F90  ld A,C
	scf	; F65F92  scf
	xorcfw_erp	0x3e	; F65F93  xorcf A,QHL3
	ldto_berp	a, 0x3c	; F65F96  ld A,RL3
	jr	c, sub_F65F7C_Entry	; F65F99  jr C,0xf65fb8
	ldfr_berp	a, 0x3c	; F65F9B  ld RL3,A
	ldfr_werp	de, 0x3e	; F65F9E  ld QHL3,DE
	ld	de, (6304852:24)	; F65FA1  ld DE,(0x603454)
	ld	a, c	; F65FA6  ld A,C
	rcf	; F65FA8  rcf
	stcf_a_16	de	; F65FA9  stcf A,DE
	ldto_berp	a, 0x3c	; F65FAB  ld A,RL3
	ld	(6304852:24), de	; F65FAE  ld (0x603454),DE
	ldto_werp	de, 0x3e	; F65FB3  ld DE,QHL3
	jr	sub_F65F7C_Join	; F65FB6  jr T,0xf65fd3
sub_F65F7C_Entry:
	ldfr_berp	a, 0x3c	; F65FB8  ld RL3,A
	ldfr_werp	de, 0x3e	; F65FBB  ld QHL3,DE
	ld	de, (6304852:24)	; F65FBE  ld DE,(0x603454)
	ld	a, c	; F65FC3  ld A,C
	scf	; F65FC5  scf
	stcf_a_16	de	; F65FC6  stcf A,DE
	ldto_berp	a, 0x3c	; F65FC8  ld A,RL3
	ld	(6304852:24), de	; F65FCB  ld (0x603454),DE
	ldto_werp	de, 0x3e	; F65FD0  ld DE,QHL3
sub_F65F7C_Join:
	and	(UI_RequestBits:16), 0xf7	; F65FD3  and (0x2075),0xf7
	call	T_NoteRouting_RebuildForSong	; F65FD8  call 0xf411b8
sub_F65F7C_Return:
	ret	; F65FDC  ret

; --------------------------------------------------------------------------
; TrackAssign_StageZero_SoftKeyCol7
; Called from: T_TrackAssign_StageZero_SoftKeyCol7 (x1)
; Touches: (0x0C03) (0x2075)  |  0x603433
; Calls:   T_NoteRouting_RebuildForSong
; Evidence: thunk slot T_TrackAssign_StageZero_SoftKeyCol7 holds `jp 0x00F65FDD`, and 0xF65FDD is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssign_StageZero_SoftKeyCol7: the SoftKeyCol7 action of TrackAssign_StageZero -- called only by SoftKeyCol7_TrackAssign_StageZero.
TrackAssign_StageZero_SoftKeyCol7:		; <- T_TrackAssign_StageZero_SoftKeyCol7
	bit	2, (TransportB_State:8)	; F65FDD  bit 2,(0x96)
	jr	nz, TrackAssign_StageZero_SoftKeyCol7_Return	; F65FE0  jr NZ,0xf6601f
	ld	xhl, 6304819	; F65FE2  ld XHL,0x00603433
	xor	bc, bc	; F65FE7  xor BC,BC
	ld	c, (3075:16)	; F65FE9  ld C,(0x0c03)
	ld	iy, bc	; F65FED  ld IY,BC
	ld	c, (xhl+iy)	; F65FEF  ld C,(XHL+IY)
	bit	7, w	; F65FF4  bit 0x07,W
	jr	z, TrackAssign_StageZero_SoftKeyCol7_Skip2	; F65FF7  jr Z,0xf66008
	cp	c, 0:i3	; F65FF9  cp C,0
	jr	z, TrackAssign_StageZero_SoftKeyCol7_Skip	; F65FFB  jr Z,0xf66006
	dec	1, c	; F65FFD  dec 1,C
	ld	(xhl+iy), c	; F65FFF  ld (XHL+IY),C
	jr	TrackAssign_StageZero_SoftKeyCol7_Join	; F66004  jr T,0xf66016
TrackAssign_StageZero_SoftKeyCol7_Skip:
	jr	TrackAssign_StageZero_SoftKeyCol7_Join	; F66006  jr T,0xf66016
TrackAssign_StageZero_SoftKeyCol7_Skip2:
	cp	c, 32	; F66008  cp C,0x20
	jr	z, TrackAssign_StageZero_SoftKeyCol7_Join	; F6600B  jr Z,0xf66016
	inc	1, c	; F6600D  inc 1,C
	ld	(xhl+iy), c	; F6600F  ld (XHL+IY),C
	jr	TrackAssign_StageZero_SoftKeyCol7_Join	; F66014  jr T,0xf66016
TrackAssign_StageZero_SoftKeyCol7_Join:
	or	(UI_RequestBits:16), 0x08	; F66016  or (0x2075),0x08
	call	T_NoteRouting_RebuildForSong	; F6601B  call 0xf411b8
TrackAssign_StageZero_SoftKeyCol7_Return:
	ret	; F6601F  ret

; --------------------------------------------------------------------------
; TrackAssign_StageNonZero_LcdKeyRow2
; Called from: T_TrackAssign_StageNonZero_LcdKeyRow2 (x1)
; Touches: (0x0C03) (0x0C06) (0x0C70) (0x0DC0) (0x2071) (0x2075) (0x207E)
;          (0x212E) (0x215E) (0x3010)  |  0x603422
; Calls:   T_F40A04 T_F40CB4
; Evidence: thunk slot T_TrackAssign_StageNonZero_LcdKeyRow2 holds `jp 0x00F66020`, and 0xF66020 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssign_StageNonZero_LcdKeyRow2: the LcdKeyRow2 action of TrackAssign_StageNonZero -- called only by LcdKeyRow2_TrackAssign_StageNonZero.
TrackAssign_StageNonZero_LcdKeyRow2:		; <- T_TrackAssign_StageNonZero_LcdKeyRow2
	and	(UI_RequestBits:16), 0xf7	; F66020  and (0x2075),0xf7
	bit	2, (TransportC_State:8)	; F66025  bit 2,(0x95)
	jr	z, TrackAssign_StageNonZero_LcdKeyRow2_Skip	; F66028  jr Z,0xf6602b
	ret	; F6602A  ret
TrackAssign_StageNonZero_LcdKeyRow2_Skip:
	ld	(3520:16), 0	; F6602B  ld (0x0dc0),0x00
	ld	xwa, (6304798:24)	; F66030  ld XWA,(0x60341e)
	ld	(12304:16), xwa	; F66035  ld (0x3010),XWA
	ld	a, (3075:16)	; F66039  ld A,(0x0c03)
	inc	1, a	; F6603D  inc 1,A
	ld	(3184:16), a	; F6603F  ld (0x0c70),A
	call	T_F40A04	; F66043  call 0xf40a04
	ld	xwa, (12304:16)	; F66047  ld XWA,(0x3010)
	ld	(6304798:24), xwa	; F6604B  ld (0x60341e),XWA
	call	T_F40CB4	; F66050  call 0xf40cb4
	ld	(8542:16), wa	; F66054  ld (0x215e),WA
	orw	(0x212e:16), 0x0100	; F66058  or (0x212e),0x0100
	xor	wa, wa	; F6605E  xor WA,WA
	ld	a, (3075:16)	; F66060  ld A,(0x0c03)
	ld	iy, wa	; F66064  ld IY,WA
	ld	a, (3078:16)	; F66066  ld A,(0x0c06)
	push	xde	; F6606A  push XDE
	ld	xde, BStore_TrackToPart	; F6606B  ld XDE,0x00603422
	ld	(xde+iy), a	; F66070  ld (XDE+IY),A
	pop	xde	; F66075  pop XDE
	ld	(UI_ScreenStage:16), 0	; F66076  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F6607B  or (0x2071),0x10
	ret	; F66080  ret

; --------------------------------------------------------------------------
; TrackAssign_ReturnToStageZero
; Called from: T_TrackAssign_ReturnToStageZero (x2)
; Touches: (0x0DC0) (0x2071) (0x2075) (0x207E)
; Evidence: thunk slot T_TrackAssign_ReturnToStageZero holds `jp 0x00F66081`, and 0xF66081 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssign_ReturnToStageZero: unless (0x95) bit 2: (0x0DC0) = 0, UI_ScreenStage = 0, UI_Request_Hi |= 0x10.  Called by ExitKey_ and
;   LcdKeyRow3_TrackAssign_StageNonZero.
TrackAssign_ReturnToStageZero:		; <- T_TrackAssign_ReturnToStageZero
	and	(UI_RequestBits:16), 0xf7	; F66081  and (0x2075),0xf7
	bit	2, (TransportC_State:8)	; F66086  bit 2,(0x95)
	jr	z, TrackAssign_ReturnToStageZero_Skip	; F66089  jr Z,0xf6608c
	ret	; F6608B  ret
TrackAssign_ReturnToStageZero_Skip:
	ld	(3520:16), 0	; F6608C  ld (0x0dc0),0x00
	ld	(UI_ScreenStage:16), 0	; F66091  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F66096  or (0x2071),0x10
	ret	; F6609B  ret

; --------------------------------------------------------------------------
; SequencerMedley_ClampSongRange_Call
; Called from: T_SequencerMedley_ClampSongRange_Call (x0)
; Touches: nothing with an absolute address
; Calls:   SequencerMedley_ClampSongRange
; Evidence: thunk slot T_SequencerMedley_ClampSongRange_Call holds `jp 0x00F6609C`, and 0xF6609C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SequencerMedley_ClampSongRange_Call: calls SequencerMedley_ClampSongRange and returns -- `calr SequencerMedley_ClampSongRange / ret`.
SequencerMedley_ClampSongRange_Call:		; <- T_SequencerMedley_ClampSongRange_Call
	calr	SequencerMedley_ClampSongRange	; F6609C  calr 0xf660a0
	ret	; F6609F  ret

; --------------------------------------------------------------------------
; SequencerMedley_ClampSongRange
; Called from: in-module: 0xF6609C 0xF662D8
; Touches: (0x0E35) (0x2208) (0x2209) (0x220B)
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF660A0 is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SequencerMedley_ClampSongRange: clamps Medley_FirstSong to the source's last song (9 / 19 / 99) and Medley_LastSong (to 0 when beyond it), then
;   keeps FIRST <= LAST, moving whichever one C (the previous FIRST) says did not change.
SequencerMedley_ClampSongRange:
	pushw	hl	; F660A0  push HL
	ld	a, (Medley_FirstSong:16)	; F660A1  ld A,(0x2208)
	ld	l, 9:opc	; F660A5  ld L,0x09
	cp	(Medley_Source:16), 0x00	; F660A7  cp (0x220b),0x00
	jr	z, SequencerMedley_ClampSongRange_Skip	; F660AC  jr Z,0xf660b9
	ld	l, 19:opc	; F660AE  ld L,0x13
	cp	(Medley_FileType:16), 0x00	; F660B0  cp (0x0e35),0x00
	jr	z, SequencerMedley_ClampSongRange_Skip	; F660B5  jr Z,0xf660b9
	ld	l, 99:opc	; F660B7  ld L,0x63
SequencerMedley_ClampSongRange_Skip:
	cp	a, l	; F660B9  cp A,L
	jr	ule, SequencerMedley_ClampSongRange_Skip2	; F660BB  jr ULE,0xf660c1
	ld	(Medley_FirstSong:16), l	; F660BD  ld (0x2208),L
SequencerMedley_ClampSongRange_Skip2:
	ld	a, (Medley_LastSong:16)	; F660C1  ld A,(0x2209)
	cp	a, l	; F660C5  cp A,L
	jr	ule, SequencerMedley_ClampSongRange_Skip3	; F660C7  jr ULE,0xf660ce
	ld	(Medley_LastSong:16), 0	; F660C9  ld (0x2209),0x00
SequencerMedley_ClampSongRange_Skip3:
	ld	a, (Medley_FirstSong:16)	; F660CE  ld A,(0x2208)
	cp	a, (Medley_LastSong:16)	; F660D2  cp A,(0x2209)
	jr	ule, SequencerMedley_ClampSongRange_Epilogue	; F660D6  jr ULE,0xf660ea
	cp	a, c	; F660D8  cp A,C
	jr	z, SequencerMedley_ClampSongRange_Skip4	; F660DA  jr Z,0xf660e2
	ld	(Medley_LastSong:16), a	; F660DC  ld (0x2209),A
	jr	SequencerMedley_ClampSongRange_Epilogue	; F660E0  jr T,0xf660ea
SequencerMedley_ClampSongRange_Skip4:
	ld	a, (Medley_LastSong:16)	; F660E2  ld A,(0x2209)
	ld	(Medley_FirstSong:16), a	; F660E6  ld (0x2208),A
SequencerMedley_ClampSongRange_Epilogue:
	popw	hl	; F660EA  pop HL
	ret	; F660EB  ret

; --------------------------------------------------------------------------
; T_F42B78_Nop
; Called from: T_F42B78 (x0)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_F42B78 holds `jp 0x00F660EC`, and 0xF660EC is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Purpose: none -- the entry is a lone `ret`.  Named T_F42B78_Nop after what reaches it
;          (was sub_F660EC; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
T_F42B78_Nop:		; <- T_F42B78
	ret	; F660EC  ret

; --------------------------------------------------------------------------
; SequencerMedley_InitOnEntry
; Called from: T_SequencerMedley_InitOnEntry (x1)
; Touches: (0x0DC1) (0x0E48) (0x207A) (0x207B) (0x22D0) (0x7F4D)
; Calls:   BStore_LoadBankDirectory T_MidiFilePlay_SnapshotRecordBytes Blink_EnableThenStop
; Evidence: thunk slot T_SequencerMedley_InitOnEntry holds `jp 0x00F660ED`, and 0xF660ED is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SequencerMedley_InitOnEntry: on a newly entered screen: (0x0E48) = (0x7F4D), Medley_Playing = 0, (0x22D0) = 0, (0x605068) |= 0x8000,
;   BStore_LoadBankDirectory, T_MidiFilePlay_SnapshotRecordBytes; then Blink_EnableThenStop unless the medley plays.  Called by Paint_SequencerMedley.
SequencerMedley_InitOnEntry:		; <- T_SequencerMedley_InitOnEntry
	ld	a, (UI_ScreenLatch:16)	; F660ED  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F660F1  cp A,(0x207b)
	jr	z, SequencerMedley_InitOnEntry_Skip5	; F660F5  jr Z,0xf66118
	ld	a, (32589:16)	; F660F7  ld A,(0x7f4d)
	ld	(3656:16), a	; F660FB  ld (0x0e48),A
	xor	a, a	; F660FF  xor A,A
	ld	(Medley_Playing:16), a	; F66101  ld (0x0dc1),A
	ld	(Medley_Countdown:16), a	; F66105  ld (0x22d0),A
	orw	(0x605068:24), 0x8000	; F66109  or (0x605068),0x8000
	call	BStore_LoadBankDirectory	; F66110  call 0xf66123
	call	T_MidiFilePlay_SnapshotRecordBytes	; F66114  call 0xf42410
SequencerMedley_InitOnEntry_Skip5:
	cp	(Medley_Playing:16), 0x01	; F66118  cp (0x0dc1),0x01
	jr	z, SequencerMedley_InitOnEntry_Return	; F6611D  jr Z,0xf66122
	calr	Blink_EnableThenStop	; F6611F  calr 0xf661f3
SequencerMedley_InitOnEntry_Return:
	ret	; F66122  ret

; --------------------------------------------------------------------------
; BStore_LoadBankDirectory
; Called from: in-module: 0xF66110
; Touches: (0x360A) (0x360C)  |  0x603400 0x610000
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF66123 is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_LoadBankDirectory: (0x60341E) = (0x360C); copies 3,072 bytes from 0x610000 + BStore_CurrentBank * 0xC00 to 0x603500, the song directory
;   SmfSize_Pass and the block store walk.
BStore_LoadBankDirectory:
	ld	xwa, (13836:16)	; F66123  ld XWA,(0x360c)
	ld	(6304798:24), xwa	; F66127  ld (0x60341e),XWA
	ld	xix, 6356992	; F6612C  ld XIX,0x00610000
	xor	xwa, xwa	; F66131  xor XWA,XWA
	ld	a, (BStore_CurrentBank:16)	; F66133  ld A,(0x360a)
	ld	xiy, xwa	; F66137  ld XIY,XWA
	sla	xwa, 11	; F66139  sla 0x0b,XWA
	sla	xiy, 10	; F6613C  sla 0x0a,XIY
	add	xwa, xiy	; F6613F  add XWA,XIY
	add	xix, xwa	; F66141  add XIX,XWA
	ld	xiy, 6304768	; F66143  ld XIY,0x00603400
	ldw	bc, 3072	; F66148  ld BC,0x0c00
	ldir85	; F6614B  ldir
	ret	; F6614D  ret

; --------------------------------------------------------------------------
; SequencerMedley_OnLeave
; Called from: T_SequencerMedley_OnLeave (x1)
; Touches: (0x0DC1) (0x0E48) (0x207A) (0x22D0) (0x34BB) (0x34D0)
; Calls:   SequencerMedley_StopPlayback T_Disk_PortA3_Release_Entry T_F42E94 T_F42E98 T_PartRecords_RestoreShadowedField T_NoteRouting_RebuildForSong
; Evidence: thunk slot T_SequencerMedley_OnLeave holds `jp 0x00F6614E`, and 0xF6614E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SequencerMedley_OnLeave: the LEAVE work of SequencerMedley -- the one unnamed routine ScreenLeaveBody_SequencerMedley calls, and nothing else calls it
;   (notes/prom_ab_screen_enter_leave_work.py).
SequencerMedley_OnLeave:		; <- T_SequencerMedley_OnLeave
	cp	(UI_ScreenLatch:16), 0x13	; F6614E  cp (0x207a),0x13
	jr	z, SequencerMedley_OnLeave_Return	; F66153  jr Z,0xf66190
	call	SequencerMedley_StopPlayback	; F66155  call 0xf66201
	call	T_Disk_PortA3_Release_Entry	; F66159  call 0xf425f0
	and	(0x34d0:16), 0xfb	; F6615D  and (0x34d0),0xfb
	ld	(Medley_Countdown:16), 0	; F66162  ld (0x22d0),0x00
	and	(0x34bb:16), 0xfb	; F66167  and (0x34bb),0xfb
	ldw	(6312040:24), 0	; F6616C  ld (0x605068),0x0000
	bit	2, (0x0e48:16)	; F66173  bit 2,(0x0e48)
	jr	z, SequencerMedley_OnLeave_Skip	; F66177  jr Z,0xf6617f
	call	T_F42E94	; F66179  call 0xf42e94
	jr	SequencerMedley_OnLeave_Join	; F6617D  jr T,0xf66183
SequencerMedley_OnLeave_Skip:
	call	T_F42E98	; F6617F  call 0xf42e98
SequencerMedley_OnLeave_Join:
	call	T_PartRecords_RestoreShadowedField	; F66183  call 0xf42414
	ld	(Medley_Playing:16), 0	; F66187  ld (0x0dc1),0x00
	call	T_NoteRouting_RebuildForSong	; F6618C  call 0xf411b8
SequencerMedley_OnLeave_Return:
	ret	; F66190  ret

; --------------------------------------------------------------------------
; SequencerMedley_LcdKeyRow2
; Called from: T_SequencerMedley_LcdKeyRow2 (x1)
; Touches: (0x0DC1) (0x0E35) (0x0E36) (0x2071) (0x2075) (0x220B) (0x2880)
; Calls:   T_Medley_Start T_F42E94 T_Medley_NormFileCommand Blink_EnableThenStop
; Evidence: thunk slot T_SequencerMedley_LcdKeyRow2 holds `jp 0x00F66191`, and 0xF66191 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SequencerMedley_LcdKeyRow2: the LcdKeyRow2 action of SequencerMedley -- called only by LcdKeyRow2_SequencerMedley.
SequencerMedley_LcdKeyRow2:		; <- T_SequencerMedley_LcdKeyRow2
	cp	(Medley_Playing:16), 0x00	; F66191  cp (0x0dc1),0x00
	jr	nz, SequencerMedley_LcdKeyRow2_Return2	; F66196  jr NZ,0xf661f2
	and	(UI_RequestBits:16), 0xf7	; F66198  and (0x2075),0xf7
	ld	(UI_StatusCode:16), 255	; F6619D  ld (0x2880),0xff
	ld	a, (Medley_Source:16)	; F661A2  ld A,(0x220b)
	cp	a, 0:i3	; F661A6  cp A,0
	jr	z, SequencerMedley_LcdKeyRow2_Skip2	; F661A8  jr Z,0xf661b5
	cp	a, 1:i3	; F661AA  cp A,1
	jr	nz, SequencerMedley_LcdKeyRow2_Skip3	; F661AC  jr NZ,0xf661d5
	cp	(Medley_FileType:16), 0x01	; F661AE  cp (0x0e35),0x01
	jr	nz, SequencerMedley_LcdKeyRow2_Skip3	; F661B3  jr NZ,0xf661d5
SequencerMedley_LcdKeyRow2_Skip2:
	ld	(UI_StatusCode:16), 35	; F661B5  ld (0x2880),0x23
	ld	(Medley_Playing:16), 1	; F661BA  ld (0x0dc1),0x01
	call	T_Medley_Start	; F661BF  call 0xf4302c
	call	T_F42E94	; F661C3  call 0xf42e94
	cp	(UI_StatusCode:16), 0x04	; F661C7  cp (0x2880),0x04
	jr	ugt, SequencerMedley_LcdKeyRow2_Join2	; F661CC  jr UGT,0xf661e3
	or	(UI_Request_Hi:16), 0x10	; F661CE  or (0x2071),0x10
	jr	SequencerMedley_LcdKeyRow2_Join2	; F661D3  jr T,0xf661e3
SequencerMedley_LcdKeyRow2_Skip3:
	ld	(Medley_Playing:16), 1	; F661D5  ld (0x0dc1),0x01
	ld	(3638:16), 0	; F661DA  ld (0x0e36),0x00
	call	T_Medley_NormFileCommand	; F661DF  call 0xf4257c
SequencerMedley_LcdKeyRow2_Join2:
	cp	(UI_StatusCode:16), 0x04	; F661E3  cp (0x2880),0x04
	jr	ugt, SequencerMedley_LcdKeyRow2_Return2	; F661E8  jr UGT,0xf661f2
	calr	Blink_EnableThenStop	; F661EA  calr 0xf661f3
	ld	(Medley_Playing:16), 0	; F661ED  ld (0x0dc1),0x00
SequencerMedley_LcdKeyRow2_Return2:
	ret	; F661F2  ret

; --------------------------------------------------------------------------
; Blink_EnableThenStop
; Called from: in-module: 0xF6611F 0xF661EA
; Touches: nothing with an absolute address
; Calls:   T_Blink_SetEnable T_Blink_Stop
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF661F3 is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Blink_EnableThenStop: T_Blink_SetEnable(1) then T_Blink_Stop.
Blink_EnableThenStop:
	pushw	1	; F661F3  push 0x0001
	call	T_Blink_SetEnable	; F661F6  call 0xf42e28
	inc	2, xsp	; F661FA  inc 2,XSP
	call	T_Blink_Stop	; F661FC  call 0xf42e24
	ret	; F66200  ret

; --------------------------------------------------------------------------
; SequencerMedley_StopPlayback
; Called from: T_SequencerMedley_StopPlayback (x1); in-module: 0xF66155
; Touches: (0x0DC1) (0x0E35) (0x0E36) (0x0E48) (0x220B) (0x22D0)
; Calls:   T_Medley_Stop T_F42E98 T_Medley_NormFileCommand
; Evidence: thunk slot T_SequencerMedley_StopPlayback holds `jp 0x00F66201`, and 0xF66201 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SequencerMedley_StopPlayback: when Medley_Playing is 1: clears it and (0x22D0); for an INT source, or FD with a NORM file: T_Medley_Stop and, unless
;   (0x0E48) bit 2, T_F42E98; otherwise (0x0E36) = 1 and T_Medley_NormFileCommand.  Called by LcdKeyRow3_SequencerMedley and SequencerMedley_OnLeave.
; ⚠ CORRECTED 2026-10-06: Medley_FileType = 1 is a MIDI FILE, not a NORM file -- Medley_Stop's own header says FD + MIDI FILE -> Medley_StopMidiFile; a NORM file takes the other branch, T_Medley_NormFileCommand.
SequencerMedley_StopPlayback:		; <- T_SequencerMedley_StopPlayback
	cp	(Medley_Playing:16), 0x01	; F66201  cp (0x0dc1),0x01
	jr	nz, SequencerMedley_StopPlayback_Return	; F66206  jr NZ,0xf66245
	ld	(Medley_Playing:16), 0	; F66208  ld (0x0dc1),0x00
	ld	a, (Medley_Source:16)	; F6620D  ld A,(0x220b)
	cp	a, 0:i3	; F66211  cp A,0
	jr	z, SequencerMedley_StopPlayback_Skip	; F66213  jr Z,0xf66220
	cp	a, 1:i3	; F66215  cp A,1
	jr	nz, SequencerMedley_StopPlayback_Skip3	; F66217  jr NZ,0xf6623c
	cp	(Medley_FileType:16), 0x01	; F66219  cp (0x0e35),0x01
	jr	nz, SequencerMedley_StopPlayback_Skip3	; F6621E  jr NZ,0xf6623c
SequencerMedley_StopPlayback_Skip:
	ld	(Medley_Playing:16), 0	; F66220  ld (0x0dc1),0x00
	ld	(Medley_Countdown:16), 0	; F66225  ld (0x22d0),0x00
	call	T_Medley_Stop	; F6622A  call 0xf43030
	bit	2, (0x0e48:16)	; F6622E  bit 2,(0x0e48)
	jr	z, SequencerMedley_StopPlayback_Skip2	; F66232  jr Z,0xf66236
	jr	SequencerMedley_StopPlayback_Return	; F66234  jr T,0xf66245
SequencerMedley_StopPlayback_Skip2:
	call	T_F42E98	; F66236  call 0xf42e98
	jr	SequencerMedley_StopPlayback_Return	; F6623A  jr T,0xf66245
SequencerMedley_StopPlayback_Skip3:
	ld	(3638:16), 1	; F6623C  ld (0x0e36),0x01
	call	T_Medley_NormFileCommand	; F66241  call 0xf4257c
SequencerMedley_StopPlayback_Return:
	ret	; F66245  ret

; --------------------------------------------------------------------------
; Medley_SelectField1
; Called from: T_Medley_SelectField1 (x2)
; Touches: (0x0C0F) (0x1302)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_Medley_SelectField1 holds `jp 0x00F66246`, and 0xF66246 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 1 into Medley_Field and requests a redraw (UI_RequestBits);
;           Medley_Field is the Medley screen's field cell (named in wsa1_ram.inc).
; Unknown: what field 1 is on that screen.
; --------------------------------------------------------------------------
Medley_SelectField1:		; <- T_Medley_SelectField1
	ld	a, 1:opc	; F66246  ld A,0x01
	ld	(Medley_Field:16), a	; F66248  ld (0x0c0f),A
	ld	(DisplayListB_Stage+12:16), a	; F6624C  ld (0x1302),A
	ret	; F66250  ret

; --------------------------------------------------------------------------
; Medley_SelectField2
; Called from: T_Medley_SelectField2 (x1)
; Touches: (0x0C0F) (0x1302)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_Medley_SelectField2 holds `jp 0x00F66251`, and 0xF66251 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 2 into Medley_Field and requests a redraw (UI_RequestBits);
;           Medley_Field is the Medley screen's field cell (named in wsa1_ram.inc).
; Unknown: what field 2 is on that screen.
; --------------------------------------------------------------------------
Medley_SelectField2:		; <- T_Medley_SelectField2
	ld	a, 2:opc	; F66251  ld A,0x02
	ld	(Medley_Field:16), a	; F66253  ld (0x0c0f),A
	ld	(DisplayListB_Stage+12:16), a	; F66257  ld (0x1302),A
	ret	; F6625B  ret

; --------------------------------------------------------------------------
; SequencerMedley_StepFieldUp
; Called from: T_SequencerMedley_StepFieldUp (x1)
; Touches: (0x0C0F)
; Calls:   SequencerMedley_StepFirstSong SequencerMedley_StepLastSong
; Evidence: thunk slot T_SequencerMedley_StepFieldUp holds `jp 0x00F6625C`, and 0xF6625C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SequencerMedley_StepFieldUp: clears bit 7 of W, then SequencerMedley_StepFirstSong (Medley_Field 1) or _StepLastSong (2): the step goes UP.
SequencerMedley_StepFieldUp:		; <- T_SequencerMedley_StepFieldUp
	and	w, 127	; F6625C  and W,0x7f
	cp	(Medley_Field:16), 0x01	; F6625F  cp (0x0c0f),0x01
	jr	z, SequencerMedley_StepFieldUp_Skip4	; F66264  jr Z,0xf6626f
	cp	(Medley_Field:16), 0x02	; F66266  cp (0x0c0f),0x02
	jr	z, SequencerMedley_StepFieldUp_Skip5	; F6626B  jr Z,0xf66274
	jr	SequencerMedley_StepFieldUp_Return2	; F6626D  jr T,0xf66277
SequencerMedley_StepFieldUp_Skip4:
	calr	SequencerMedley_StepFirstSong	; F6626F  calr 0xf66294
	jr	SequencerMedley_StepFieldUp_Return2	; F66272  jr T,0xf66277
SequencerMedley_StepFieldUp_Skip5:
	calr	SequencerMedley_StepLastSong	; F66274  calr 0xf662f7
SequencerMedley_StepFieldUp_Return2:
	ret	; F66277  ret

; --------------------------------------------------------------------------
; SequencerMedley_StepFieldDown
; Called from: T_SequencerMedley_StepFieldDown (x1)
; Touches: (0x0C0F)
; Calls:   SequencerMedley_StepFirstSong SequencerMedley_StepLastSong
; Evidence: thunk slot T_SequencerMedley_StepFieldDown holds `jp 0x00F66278`, and 0xF66278 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SequencerMedley_StepFieldDown: sets bit 7 of W, then the same dispatch on Medley_Field: the step goes DOWN.
SequencerMedley_StepFieldDown:		; <- T_SequencerMedley_StepFieldDown
	or	w, 128	; F66278  or W,0x80
	cp	(Medley_Field:16), 0x01	; F6627B  cp (0x0c0f),0x01
	jr	z, SequencerMedley_StepFieldDown_Skip6	; F66280  jr Z,0xf6628b
	cp	(Medley_Field:16), 0x02	; F66282  cp (0x0c0f),0x02
	jr	z, SequencerMedley_StepFieldDown_Skip7	; F66287  jr Z,0xf66290
	jr	SequencerMedley_StepFieldDown_Return3	; F66289  jr T,0xf66293
SequencerMedley_StepFieldDown_Skip6:
	calr	SequencerMedley_StepFirstSong	; F6628B  calr 0xf66294
	jr	SequencerMedley_StepFieldDown_Return3	; F6628E  jr T,0xf66293
SequencerMedley_StepFieldDown_Skip7:
	calr	SequencerMedley_StepLastSong	; F66290  calr 0xf662f7
SequencerMedley_StepFieldDown_Return3:
	ret	; F66293  ret

; --------------------------------------------------------------------------
; SequencerMedley_StepFirstSong
; Called from: in-module: 0xF6626F 0xF6628B
; Touches: (0x0E35) (0x2075) (0x2208) (0x220B)
; Calls:   SequencerMedley_ClampRangeAfterStep
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF66294 is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SequencerMedley_StepFirstSong: unless (0x95) bit 2: W bit 7 set -> Medley_FirstSong - 1 (floor 0); clear -> + 1 up to 9 (INT), 19 (disk, NORM file)
;   or 99 (MIDI file); then the range fix-up 0xF662D7 and repaint bit 3.
SequencerMedley_StepFirstSong:
	bit	2, (TransportC_State:8)	; F66294  bit 2,(0x95)
	jr	z, SequencerMedley_StepFirstSong_Skip	; F66297  jr Z,0xf6629a
	ret	; F66299  ret
SequencerMedley_StepFirstSong_Skip:
	ld	c, (Medley_FirstSong:16)	; F6629A  ld C,(0x2208)
	bit	7, w	; F6629E  bit 0x07,W
	jr	z, SequencerMedley_StepFirstSong_Skip2	; F662A1  jr Z,0xf662b0
	cp	(Medley_FirstSong:16), 0x00	; F662A3  cp (0x2208),0x00
	jr	z, SequencerMedley_StepFirstSong_Join	; F662A8  jr Z,0xf662ce
	dec	1, (Medley_FirstSong:16)	; F662AA  dec 1,(0x2208)
	jr	SequencerMedley_StepFirstSong_Join	; F662AE  jr T,0xf662ce
SequencerMedley_StepFirstSong_Skip2:
	ld	a, 9:opc	; F662B0  ld A,0x09
	cp	(Medley_Source:16), 0x00	; F662B2  cp (0x220b),0x00
	jr	z, SequencerMedley_StepFirstSong_Skip3	; F662B7  jr Z,0xf662c4
	ld	a, 19:opc	; F662B9  ld A,0x13
	cp	(Medley_FileType:16), 0x00	; F662BB  cp (0x0e35),0x00
	jr	z, SequencerMedley_StepFirstSong_Skip3	; F662C0  jr Z,0xf662c4
	ld	a, 99:opc	; F662C2  ld A,0x63
SequencerMedley_StepFirstSong_Skip3:
	cp	(Medley_FirstSong:16), a	; F662C4  cp (0x2208),A
	jr	z, SequencerMedley_StepFirstSong_Join	; F662C8  jr Z,0xf662ce
	inc	1, (Medley_FirstSong:16)	; F662CA  inc 1,(0x2208)
SequencerMedley_StepFirstSong_Join:
	calr	SequencerMedley_ClampRangeAfterStep	; F662CE  calr 0xf662d7
	or	(UI_RequestBits:16), 0x08	; F662D1  or (0x2075),0x08
	ret	; F662D6  ret

; --------------------------------------------------------------------------
; SequencerMedley_ClampRangeAfterStep
; Called from: in-module: 0xF662CE 0xF66331
; Touches: (0x2208)
; Calls:   SequencerMedley_ClampSongRange T_F42580
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF662D7 is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SequencerMedley_ClampRangeAfterStep: After a FIRST/LAST SONG step (C = Medley_FirstSong before it):
;   SequencerMedley_ClampSongRange, then if Medley_FirstSong changed calls T_F42580 with W = 1 (moved down) or 0
;   (moved up) -- a lone `ret` in this build. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_f.json)
SequencerMedley_ClampRangeAfterStep:
	pushw	bc	; F662D7  push BC
	calr	SequencerMedley_ClampSongRange	; F662D8  calr 0xf660a0
	popw	bc	; F662DB  pop BC
	cp	c, (Medley_FirstSong:16)	; F662DC  cp C,(0x2208)
	jr	z, SequencerMedley_ClampRangeAfterStep_Return	; F662E0  jr Z,0xf662f6
	cp	(Medley_FirstSong:16), c	; F662E2  cp (0x2208),C
	jr	ugt, SequencerMedley_ClampRangeAfterStep_Skip	; F662E6  jr UGT,0xf662f0
	ld	w, 1:opc	; F662E8  ld W,0x01
	call	T_F42580	; F662EA  call 0xf42580
	jr	SequencerMedley_ClampRangeAfterStep_Return	; F662EE  jr T,0xf662f6
SequencerMedley_ClampRangeAfterStep_Skip:
	ld	w, 0:opc	; F662F0  ld W,0x00
	call	T_F42580	; F662F2  call 0xf42580
SequencerMedley_ClampRangeAfterStep_Return:
	ret	; F662F6  ret

; --------------------------------------------------------------------------
; SequencerMedley_StepLastSong
; Called from: in-module: 0xF66274 0xF66290
; Touches: (0x0E35) (0x2075) (0x2208) (0x2209) (0x220B)
; Calls:   SequencerMedley_ClampRangeAfterStep
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF662F7 is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SequencerMedley_StepLastSong: the same as SequencerMedley_StepFirstSong on Medley_LastSong.
SequencerMedley_StepLastSong:
	bit	2, (TransportC_State:8)	; F662F7  bit 2,(0x95)
	jr	z, SequencerMedley_StepLastSong_Skip	; F662FA  jr Z,0xf662fd
	ret	; F662FC  ret
SequencerMedley_StepLastSong_Skip:
	ld	c, (Medley_FirstSong:16)	; F662FD  ld C,(0x2208)
	bit	7, w	; F66301  bit 0x07,W
	jr	z, SequencerMedley_StepLastSong_Skip2	; F66304  jr Z,0xf66313
	cp	(Medley_LastSong:16), 0x00	; F66306  cp (0x2209),0x00
	jr	z, SequencerMedley_StepLastSong_Join	; F6630B  jr Z,0xf66331
	dec	1, (Medley_LastSong:16)	; F6630D  dec 1,(0x2209)
	jr	SequencerMedley_StepLastSong_Join	; F66311  jr T,0xf66331
SequencerMedley_StepLastSong_Skip2:
	ld	a, 9:opc	; F66313  ld A,0x09
	cp	(Medley_Source:16), 0x00	; F66315  cp (0x220b),0x00
	jr	z, SequencerMedley_StepLastSong_Skip3	; F6631A  jr Z,0xf66327
	ld	a, 19:opc	; F6631C  ld A,0x13
	cp	(Medley_FileType:16), 0x00	; F6631E  cp (0x0e35),0x00
	jr	z, SequencerMedley_StepLastSong_Skip3	; F66323  jr Z,0xf66327
	ld	a, 99:opc	; F66325  ld A,0x63
SequencerMedley_StepLastSong_Skip3:
	cp	(Medley_LastSong:16), a	; F66327  cp (0x2209),A
	jr	z, SequencerMedley_StepLastSong_Join	; F6632B  jr Z,0xf66331
	inc	1, (Medley_LastSong:16)	; F6632D  inc 1,(0x2209)
SequencerMedley_StepLastSong_Join:
	calr	SequencerMedley_ClampRangeAfterStep	; F66331  calr 0xf662d7
	or	(UI_RequestBits:16), 0x08	; F66334  or (0x2075),0x08
	ret	; F66339  ret

; --------------------------------------------------------------------------
; SequencerMedley_SetSourceInternal
; Called from: T_SequencerMedley_SetSourceInternal (x2)
; Touches: (0x0DC1) (0x0E35) (0x12FE) (0x1300) (0x1303) (0x1304) (0x2208)
;          (0x2209) (0x220B)
; Evidence: thunk slot T_SequencerMedley_SetSourceInternal holds `jp 0x00F6633A`, and 0xF6633A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SequencerMedley_SetSourceInternal: when not playing: Medley_Source = 0 (INT) and Medley_FileType = 0, each to its display stage, and both songs
;   clamped to 9 (an INT medley has ten songs).  Called by SoftKeyCol2_SequencerMedley and Paint_SequencerMedley.
SequencerMedley_SetSourceInternal:		; <- T_SequencerMedley_SetSourceInternal
	cp	(Medley_Playing:16), 0x00	; F6633A  cp (0x0dc1),0x00
	jr	nz, SequencerMedley_SetSourceInternal_Return	; F6633F  jr NZ,0xf66381
	ld	a, 0:opc	; F66341  ld A,0x00
	ld	(Medley_Source:16), a	; F66343  ld (0x220b),A
	ld	(DisplayListB_Stage+13:16), a	; F66347  ld (0x1303),A
	ld	a, 0:opc	; F6634B  ld A,0x00
	ld	(Medley_FileType:16), a	; F6634D  ld (0x0e35),A
	ld	(DisplayListB_Stage+14:16), a	; F66351  ld (0x1304),A
	cp	(Medley_FirstSong:16), 0x0a	; F66355  cp (0x2208),0x0a
	jr	c, SequencerMedley_SetSourceInternal_Skip4	; F6635A  jr C,0xf66361
	ld	(Medley_FirstSong:16), 9	; F6635C  ld (0x2208),0x09
SequencerMedley_SetSourceInternal_Skip4:
	ld	a, (Medley_FirstSong:16)	; F66361  ld A,(0x2208)
	inc	1, a	; F66365  inc 1,A
	ld	(DisplayListB_Stage+8:16), a	; F66367  ld (0x12fe),A
	cp	(Medley_LastSong:16), 0x0a	; F6636B  cp (0x2209),0x0a
	jr	c, SequencerMedley_SetSourceInternal_Skip5	; F66370  jr C,0xf66377
	ld	(Medley_LastSong:16), 9	; F66372  ld (0x2209),0x09
SequencerMedley_SetSourceInternal_Skip5:
	ld	a, (Medley_LastSong:16)	; F66377  ld A,(0x2209)
	inc	1, a	; F6637B  inc 1,A
	ld	(DisplayListB_Stage+10:16), a	; F6637D  ld (0x1300),A
SequencerMedley_SetSourceInternal_Return:
	ret	; F66381  ret

; --------------------------------------------------------------------------
; SequencerMedley_SoftKeyCol3
; Called from: T_SequencerMedley_SoftKeyCol3 (x1)
; Touches: (0x0DC1) (0x0E35) (0x12FE) (0x1300) (0x1303) (0x2208) (0x2209)
;          (0x220B)
; Evidence: thunk slot T_SequencerMedley_SoftKeyCol3 holds `jp 0x00F66382`, and 0xF66382 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SequencerMedley_SoftKeyCol3: the SoftKeyCol3 action of SequencerMedley -- called only by SoftKeyCol3_SequencerMedley.
SequencerMedley_SoftKeyCol3:		; <- T_SequencerMedley_SoftKeyCol3
	cp	(Medley_Playing:16), 0x00	; F66382  cp (0x0dc1),0x00
	jr	nz, SequencerMedley_SoftKeyCol3_Return2	; F66387  jr NZ,0xf663d5
	ld	a, 1:opc	; F66389  ld A,0x01
	ld	(Medley_Source:16), a	; F6638B  ld (0x220b),A
	ld	(DisplayListB_Stage+13:16), a	; F6638F  ld (0x1303),A
	ld	a, 20:opc	; F66393  ld A,0x14
	cp	(Medley_FileType:16), 0x00	; F66395  cp (0x0e35),0x00
	jr	z, SequencerMedley_SoftKeyCol3_Skip6	; F6639A  jr Z,0xf6639e
	ld	a, 100:opc	; F6639C  ld A,0x64
SequencerMedley_SoftKeyCol3_Skip6:
	cp	(Medley_FirstSong:16), a	; F6639E  cp (0x2208),A
	jr	c, SequencerMedley_SoftKeyCol3_Skip7	; F663A2  jr C,0xf663aa
	dec	1, a	; F663A4  dec 1,A
	ld	(Medley_FirstSong:16), a	; F663A6  ld (0x2208),A
SequencerMedley_SoftKeyCol3_Skip7:
	ld	a, (Medley_FirstSong:16)	; F663AA  ld A,(0x2208)
	inc	1, a	; F663AE  inc 1,A
	ld	(DisplayListB_Stage+8:16), a	; F663B0  ld (0x12fe),A
	ld	a, 20:opc	; F663B4  ld A,0x14
	cp	(Medley_FileType:16), 0x00	; F663B6  cp (0x0e35),0x00
	jr	z, SequencerMedley_SoftKeyCol3_Skip8	; F663BB  jr Z,0xf663bf
	ld	a, 100:opc	; F663BD  ld A,0x64
SequencerMedley_SoftKeyCol3_Skip8:
	cp	(Medley_LastSong:16), a	; F663BF  cp (0x2209),A
	jr	c, SequencerMedley_SoftKeyCol3_Skip9	; F663C3  jr C,0xf663cb
	dec	1, a	; F663C5  dec 1,A
	ld	(Medley_LastSong:16), a	; F663C7  ld (0x2209),A
SequencerMedley_SoftKeyCol3_Skip9:
	ld	a, (Medley_LastSong:16)	; F663CB  ld A,(0x2209)
	inc	1, a	; F663CF  inc 1,A
	ld	(DisplayListB_Stage+10:16), a	; F663D1  ld (0x1300),A
SequencerMedley_SoftKeyCol3_Return2:
	ret	; F663D5  ret

; --------------------------------------------------------------------------
; T_F42C20_Nop
; Called from: T_F42C20 (x0)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_F42C20 holds `jp 0x00F663D6`, and 0xF663D6 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Purpose: none -- the entry is a lone `ret`.  Named T_F42C20_Nop after what reaches it
;          (was sub_F663D6; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
T_F42C20_Nop:		; <- T_F42C20
	ret	; F663D6  ret

; --------------------------------------------------------------------------
; SequencerMedley_SoftKeyCol8
; Called from: T_SequencerMedley_SoftKeyCol8 (x1)
; Touches: (0x0DC1) (0x0E35) (0x12FE) (0x1300) (0x1304) (0x2208) (0x2209)
; Evidence: thunk slot T_SequencerMedley_SoftKeyCol8 holds `jp 0x00F663D7`, and 0xF663D7 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SequencerMedley_SoftKeyCol8: the SoftKeyCol8 action of SequencerMedley -- called only by SoftKeyCol8_SequencerMedley.
SequencerMedley_SoftKeyCol8:		; <- T_SequencerMedley_SoftKeyCol8
	cp	(Medley_Playing:16), 0x00	; F663D7  cp (0x0dc1),0x00
	jr	nz, SequencerMedley_SoftKeyCol8_Return3	; F663DC  jr NZ,0xf66414
	ld	a, 0:opc	; F663DE  ld A,0x00
	ld	(Medley_FileType:16), a	; F663E0  ld (0x0e35),A
	ld	(DisplayListB_Stage+14:16), a	; F663E4  ld (0x1304),A
	cp	(Medley_FirstSong:16), 0x14	; F663E8  cp (0x2208),0x14
	jr	c, SequencerMedley_SoftKeyCol8_Skip10	; F663ED  jr C,0xf663f4
	ld	(Medley_FirstSong:16), 19	; F663EF  ld (0x2208),0x13
SequencerMedley_SoftKeyCol8_Skip10:
	ld	a, (Medley_FirstSong:16)	; F663F4  ld A,(0x2208)
	inc	1, a	; F663F8  inc 1,A
	ld	(DisplayListB_Stage+8:16), a	; F663FA  ld (0x12fe),A
	cp	(Medley_LastSong:16), 0x14	; F663FE  cp (0x2209),0x14
	jr	c, SequencerMedley_SoftKeyCol8_Skip11	; F66403  jr C,0xf6640a
	ld	(Medley_LastSong:16), 19	; F66405  ld (0x2209),0x13
SequencerMedley_SoftKeyCol8_Skip11:
	ld	a, (Medley_LastSong:16)	; F6640A  ld A,(0x2209)
	inc	1, a	; F6640E  inc 1,A
	ld	(DisplayListB_Stage+10:16), a	; F66410  ld (0x1300),A
SequencerMedley_SoftKeyCol8_Return3:
	ret	; F66414  ret

; --------------------------------------------------------------------------
; SequencerMedley_SoftKeyCol7
; Called from: T_SequencerMedley_SoftKeyCol7 (x1)
; Touches: (0x0DC1) (0x0E35) (0x12FE) (0x1300) (0x1304) (0x2208) (0x2209)
;          (0x220B)
; Evidence: thunk slot T_SequencerMedley_SoftKeyCol7 holds `jp 0x00F66415`, and 0xF66415 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SequencerMedley_SoftKeyCol7: the SoftKeyCol7 action of SequencerMedley -- called only by SoftKeyCol7_SequencerMedley.
SequencerMedley_SoftKeyCol7:		; <- T_SequencerMedley_SoftKeyCol7
	cp	(Medley_Playing:16), 0x00	; F66415  cp (0x0dc1),0x00
	jr	nz, SequencerMedley_SoftKeyCol7_Return4	; F6641A  jr NZ,0xf66459
	cp	(Medley_Source:16), 0x01	; F6641C  cp (0x220b),0x01
	jr	nz, SequencerMedley_SoftKeyCol7_Return4	; F66421  jr NZ,0xf66459
	ld	a, 1:opc	; F66423  ld A,0x01
	ld	(Medley_FileType:16), a	; F66425  ld (0x0e35),A
	ld	(DisplayListB_Stage+14:16), a	; F66429  ld (0x1304),A
	cp	(Medley_FirstSong:16), 0x64	; F6642D  cp (0x2208),0x64
	jr	c, SequencerMedley_SoftKeyCol7_Skip12	; F66432  jr C,0xf66439
	ld	(Medley_FirstSong:16), 99	; F66434  ld (0x2208),0x63
SequencerMedley_SoftKeyCol7_Skip12:
	ld	a, (Medley_FirstSong:16)	; F66439  ld A,(0x2208)
	inc	1, a	; F6643D  inc 1,A
	ld	(DisplayListB_Stage+8:16), a	; F6643F  ld (0x12fe),A
	cp	(Medley_LastSong:16), 0x64	; F66443  cp (0x2209),0x64
	jr	c, SequencerMedley_SoftKeyCol7_Skip13	; F66448  jr C,0xf6644f
	ld	(Medley_LastSong:16), 99	; F6644A  ld (0x2209),0x63
SequencerMedley_SoftKeyCol7_Skip13:
	ld	a, (Medley_LastSong:16)	; F6644F  ld A,(0x2209)
	inc	1, a	; F66453  inc 1,A
	ld	(DisplayListB_Stage+10:16), a	; F66455  ld (0x1300),A
SequencerMedley_SoftKeyCol7_Return4:
	ret	; F66459  ret

; --------------------------------------------------------------------------
; SequencerMedley_LcdKeyRow4
; Called from: T_SequencerMedley_LcdKeyRow4 (x1)
; Touches: (0x0DC1) (0x0E35) (0x0E36) (0x2071) (0x220B) (0x22D0) (0x2880)
; Calls:   T_Medley_Next T_F42E94 T_Medley_NormFileCommand
; Evidence: thunk slot T_SequencerMedley_LcdKeyRow4 holds `jp 0x00F6645A`, and 0xF6645A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SequencerMedley_LcdKeyRow4: the LcdKeyRow4 action of SequencerMedley -- called only by LcdKeyRow4_SequencerMedley.
SequencerMedley_LcdKeyRow4:		; <- T_SequencerMedley_LcdKeyRow4
	cp	(Medley_Playing:16), 0x01	; F6645A  cp (0x0dc1),0x01
	jr	nz, SequencerMedley_LcdKeyRow4_Return5	; F6645F  jr NZ,0xf664ad
	ld	a, (Medley_Source:16)	; F66461  ld A,(0x220b)
	cp	a, 0:i3	; F66465  cp A,0
	jr	z, SequencerMedley_LcdKeyRow4_Skip14	; F66467  jr Z,0xf66474
	cp	a, 1:i3	; F66469  cp A,1
	jr	nz, SequencerMedley_LcdKeyRow4_Skip15	; F6646B  jr NZ,0xf66498
	cp	(Medley_FileType:16), 0x01	; F6646D  cp (0x0e35),0x01
	jr	nz, SequencerMedley_LcdKeyRow4_Skip15	; F66472  jr NZ,0xf66498
SequencerMedley_LcdKeyRow4_Skip14:
	cp	(Medley_Countdown:16), 0x00	; F66474  cp (0x22d0),0x00
	jr	nz, SequencerMedley_LcdKeyRow4_Return5	; F66479  jr NZ,0xf664ad
	ld	(UI_StatusCode:16), 35	; F6647B  ld (0x2880),0x23
	call	T_Medley_Next	; F66480  call 0xf43034
	call	T_F42E94	; F66484  call 0xf42e94
	cp	(UI_StatusCode:16), 0x04	; F66488  cp (0x2880),0x04
	jr	ugt, SequencerMedley_LcdKeyRow4_Join2	; F6648D  jr UGT,0xf664a1
	ld	(UI_Request_Hi:16), 16	; F6648F  ld (0x2071),0x10
	jr	SequencerMedley_LcdKeyRow4_Join2	; F66494  jr T,0xf664a1
	jr	SequencerMedley_LcdKeyRow4_Return5	; F66496  jr T,0xf664ad
SequencerMedley_LcdKeyRow4_Skip15:
	ld	(3638:16), 2	; F66498  ld (0x0e36),0x02
	call	T_Medley_NormFileCommand	; F6649D  call 0xf4257c
SequencerMedley_LcdKeyRow4_Join2:
	cp	(UI_StatusCode:16), 0x04	; F664A1  cp (0x2880),0x04
	jr	ugt, SequencerMedley_LcdKeyRow4_Return5	; F664A6  jr UGT,0xf664ad
	ld	(Medley_Playing:16), 0	; F664A8  ld (0x0dc1),0x00
SequencerMedley_LcdKeyRow4_Return5:
	ret	; F664AD  ret

; --------------------------------------------------------------------------
; StepRecordPartSelect_OpenStepRecord
; Called from: T_StepRecordPartSelect_OpenStepRecord (x8)
; Touches: (0x0C90) (0x0DC8) (0x0E5C) (0x12A0) (0x2070)
; Evidence: thunk slot T_StepRecordPartSelect_OpenStepRecord holds `jp 0x00F664AE`, and 0xF664AE is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; StepRecordPartSelect_OpenStepRecord: (0x0C90) = 1, (0x0DC8) = 0, and when the chosen part (0x0E5C) is 1..0x11: (0x12A0) = 0 and UI_Request = 0x800E,
;   screen 0x0E = STEP RECORD.  Called by all eight SoftKeyColN_StepRecordPartSelect.
StepRecordPartSelect_OpenStepRecord:		; <- T_StepRecordPartSelect_OpenStepRecord
	ldw	(3216:16), 1	; F664AE  ld (0x0c90),0x0001
	ldw	(3528:16), 0	; F664B4  ld (0x0dc8),0x0000
	cp	(0x0e5c:16), 0x00	; F664BA  cp (0x0e5c),0x00
	jr	z, StepRecordPartSelect_OpenStepRecord_Return6	; F664BF  jr Z,0xf664d4
	cp	(0x0e5c:16), 0x11	; F664C1  cp (0x0e5c),0x11
	jr	ugt, StepRecordPartSelect_OpenStepRecord_Return6	; F664C6  jr UGT,0xf664d4
	ldw	(4768:16), 0	; F664C8  ld (0x12a0),0x0000
	ldw	(UI_Request:16), 32782	; F664CE  ld (0x2070),0x800e
StepRecordPartSelect_OpenStepRecord_Return6:
	ret	; F664D4  ret

; --------------------------------------------------------------------------
; StepRecordPartSelect_ResetOnEntry
; Called from: T_StepRecordPartSelect_ResetOnEntry (x1)
; Touches: (0x0C00) (0x0E5C) (0x207A) (0x207B) (0x2130) (0x215E) (0x2160)
;          (0x3010) (0x34BB)
; Calls:   T_Transport_StopAllRunning
; Evidence: thunk slot T_StepRecordPartSelect_ResetOnEntry holds `jp 0x00F664D5`, and 0xF664D5 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; StepRecordPartSelect_ResetOnEntry: (0x3010) = (0x60341E); on a newly entered screen (latch changed): chosen part (0x0E5C) = 0, (0x2130) |= 0x100,
;   (0x2160) = 0xFFFF, (0x215E) = 0, (0x0C00) = 0, T_Transport_StopAllRunning; then (0x34BB) |= 4.  Called by Paint_StepRecordPartSelect.
StepRecordPartSelect_ResetOnEntry:		; <- T_StepRecordPartSelect_ResetOnEntry
	ld	xwa, (6304798:24)	; F664D5  ld XWA,(0x60341e)
	ld	(12304:16), xwa	; F664DA  ld (0x3010),XWA
	ld	a, (UI_ScreenLatch:16)	; F664DE  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F664E2  cp A,(0x207b)
	jr	z, StepRecordPartSelect_ResetOnEntry_Skip16	; F664E6  jr Z,0xf66509
	ld	(3676:16), 0	; F664E8  ld (0x0e5c),0x00
	orw	(0x2130:16), 0x0100	; F664ED  or (0x2130),0x0100
	ldw	(8544:16), 65535	; F664F3  ld (0x2160),0xffff
	ldw	(8542:16), 0	; F664F9  ld (0x215e),0x0000
	ldw	(3072:16), 0	; F664FF  ld (0x0c00),0x0000
	call	T_Transport_StopAllRunning	; F66505  call 0xf409ac
StepRecordPartSelect_ResetOnEntry_Skip16:
	or	(0x34bb:16), 0x04	; F66509  or (0x34bb),0x04
	ret	; F6650E  ret

; --------------------------------------------------------------------------
; StepRecordPartSelect_OnLeave
; Called from: T_StepRecordPartSelect_OnLeave (x1)
; Touches: (0x3010) (0x34BB)
; Calls:   T_F40CB4
; Evidence: thunk slot T_StepRecordPartSelect_OnLeave holds `jp 0x00F6650F`, and 0xF6650F is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; StepRecordPartSelect_OnLeave: the LEAVE work of StepRecordPartSelect -- the one unnamed routine ScreenLeaveBody_StepRecordPartSelect calls, and nothing else calls it
;   (notes/prom_ab_screen_enter_leave_work.py).
StepRecordPartSelect_OnLeave:		; <- T_StepRecordPartSelect_OnLeave
	ld	xwa, (12304:16)	; F6650F  ld XWA,(0x3010)
	ld	(6304798:24), xwa	; F66513  ld (0x60341e),XWA
	call	T_F40CB4	; F66518  call 0xf40cb4
	and	(0x34bb:16), 0xfb	; F6651C  and (0x34bb),0xfb
	ret	; F66521  ret

; --------------------------------------------------------------------------
; sub_F66522
; Called from: T_F42BDC (x0)
; Touches: (0x0C03) (0x0C07)
; Evidence: thunk slot T_F42BDC holds `jp 0x00F66522`, and 0xF66522 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F66522:		; <- T_F42BDC
	and	(0x0c07:16), 0xfe	; F66522  and (0x0c07),0xfe
	ld	(3075:16), 0	; F66527  ld (0x0c03),0x00

; --------------------------------------------------------------------------
; sub_F66522_Join
; Called from: T_F42BE4 (x1)
; Touches: (0x0C03) (0x0C06) (0x0C07) (0x207B) (0x34BB)  |  0x603422
; Calls:   T_Transport_StopAllRunning
; Evidence: thunk slot T_F42BE4 holds `jp 0x00F6652C`, and 0xF6652C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F66522_Join:		; <- T_F42BE4
	cp	(UI_ScreenLatch_Previous:16), 0x10	; F6652C  cp (0x207b),0x10
	jr	z, sub_F662F7_Skip17	; F66531  jr Z,0xf66546
	and	(0x0c07:16), 0xfe	; F66533  and (0x0c07),0xfe
	ld	(3075:16), 0	; F66538  ld (0x0c03),0x00
	call	T_Transport_StopAllRunning	; F6653D  call 0xf409ac
	or	(0x34bb:16), 0x04	; F66541  or (0x34bb),0x04
sub_F662F7_Skip17:
	ld	xhl, BStore_TrackToPart	; F66546  ld XHL,0x00603422
	xor	wa, wa	; F6654B  xor WA,WA
	ld	a, (3075:16)	; F6654D  ld A,(0x0c03)
	ld	iy, wa	; F66551  ld IY,WA
	ld	a, (xhl+iy)	; F66553  ld A,(XHL+IY)
	ld	(3078:16), a	; F66558  ld (0x0c06),A
	ret	; F6655C  ret

; --------------------------------------------------------------------------
; TrackAssign_OnLeave
; Called from: T_TrackAssign_OnLeave (x1)
; Touches: (0x207A) (0x34BB)
; Calls:   TrackAssign_CommitEditedPart
; Evidence: thunk slot T_TrackAssign_OnLeave holds `jp 0x00F6655D`, and 0xF6655D is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssign_OnLeave: the LEAVE work of TrackAssign -- the one unnamed routine ScreenLeaveBody_TrackAssign calls, and nothing else calls it
;   (notes/prom_ab_screen_enter_leave_work.py).
TrackAssign_OnLeave:		; <- T_TrackAssign_OnLeave
	cp	(UI_ScreenLatch:16), 0x10	; F6655D  cp (0x207a),0x10
	jr	z, TrackAssign_OnLeave_Return7	; F66562  jr Z,0xf6656c
	calr	TrackAssign_CommitEditedPart	; F66564  calr 0xf65d26
	and	(0x34bb:16), 0xfb	; F66567  and (0x34bb),0xfb
TrackAssign_OnLeave_Return7:
	ret	; F6656C  ret

; --------------------------------------------------------------------------
; T_F42BE0_Nop
; Called from: T_F42BE0 (x0)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_F42BE0 holds `jp 0x00F6656D`, and 0xF6656D is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Purpose: none -- the entry is a lone `ret`.  Named T_F42BE0_Nop after what reaches it
;          (was sub_F6656D; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
T_F42BE0_Nop:		; <- T_F42BE0
	ret	; F6656D  ret

; --------------------------------------------------------------------------
; TrackAssign_StageZero_LcdKeyRow5
; Called from: T_TrackAssign_StageZero_LcdKeyRow5 (x1)
; Touches: (0x2070)
; Evidence: thunk slot T_TrackAssign_StageZero_LcdKeyRow5 holds `jp 0x00F6656E`, and 0xF6656E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssign_StageZero_LcdKeyRow5: the LcdKeyRow5 action of TrackAssign_StageZero -- called only by LcdKeyRow5_TrackAssign_StageZero.
TrackAssign_StageZero_LcdKeyRow5:		; <- T_TrackAssign_StageZero_LcdKeyRow5
	bit	7, w	; F6656E  bit 0x07,W
	jr	z, TrackAssign_StageZero_LcdKeyRow5_Return8	; F66571  jr Z,0xf66579
	ldw	(UI_Request:16), 32785	; F66573  ld (0x2070),0x8011
TrackAssign_StageZero_LcdKeyRow5_Return8:
	ret	; F66579  ret

; --------------------------------------------------------------------------
; AfterT0uchSetting_SetRecordEnable
; Called from: T_AfterT0uchSetting_SetRecordEnable (x1)
; Touches: (0x7FC2)
; Evidence: thunk slot T_AfterT0uchSetting_SetRecordEnable holds `jp 0x00F6657A`, and 0xF6657A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; AfterT0uchSetting_SetRecordEnable: AFTER T0UCH SETTING: LCD key row 3 (code 10) sets (0x7FC2) bit 0, row 4 (code 11)
;   clears it; CP2-side presses (W bit 7) are ignored. ScreenButton_AfterT0uchSetting calls it with BC = the code and
;   then redraws (0x7FC2) through DL_AfterTouchRecord (AND mask 0x01) and DLTable_DisableEnable, so bit 0 is the
;   'AFTER TOUCH RECORD : EN / DIS' setting. Basis: caller + screen text + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_r.json)
AfterT0uchSetting_SetRecordEnable:		; <- T_AfterT0uchSetting_SetRecordEnable
	bit	7, w	; F6657A  bit 0x07,W
	jr	nz, AfterT0uchSetting_SetRecordEnable_Return9	; F6657D  jr NZ,0xf66597
	cp	bc, 10	; F6657F  cp BC,0x000a
	jr	z, AfterT0uchSetting_SetRecordEnable_Skip18	; F66583  jr Z,0xf66592
	cp	bc, 11	; F66585  cp BC,0x000b
	jr	nz, AfterT0uchSetting_SetRecordEnable_Return9	; F66589  jr NZ,0xf66597
	and	(0x7fc2:16), 0xfe	; F6658B  and (0x7fc2),0xfe
	jr	AfterT0uchSetting_SetRecordEnable_Return9	; F66590  jr T,0xf66597
AfterT0uchSetting_SetRecordEnable_Skip18:
	or	(0x7fc2:16), 0x01	; F66592  or (0x7fc2),0x01
AfterT0uchSetting_SetRecordEnable_Return9:
	ret	; F66597  ret

; --------------------------------------------------------------------------
; sub_F66598
; Called from: T_F42BF0 (x0)
; Touches: (0x207A) (0x2095)
; Evidence: thunk slot T_F42BF0 holds `jp 0x00F66598`, and 0xF66598 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F66598:		; <- T_F42BF0
	cp	(UI_ScreenLatch:16), 0x06	; F66598  cp (0x207a),0x06
	jr	z, sub_F662F7_Skip19	; F6659D  jr Z,0xf665ad
	cp	(UI_ScreenLatch:16), 0x12	; F6659F  cp (0x207a),0x12
	jr	z, sub_F662F7_Skip19	; F665A4  jr Z,0xf665ad
	cp	(UI_ScreenLatch:16), 0x09	; F665A6  cp (0x207a),0x09
	jr	nz, sub_F662F7_Return10	; F665AB  jr NZ,0xf665b2
sub_F662F7_Skip19:
	or	(UI_ScreenFlags:16), 0x10	; F665AD  or (0x2095),0x10
sub_F662F7_Return10:
	ret	; F665B2  ret

; --------------------------------------------------------------------------
; sub_F65C0D_Nop
; Called from: in-module: 0xF65C1F
; Touches: nothing with an absolute address
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF665B3 is an instruction
;           boundary.
; Purpose: none -- the entry is a lone `ret`.  Named sub_F65C0D_Nop after what reaches it
;          (was sub_F665B3; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
sub_F65C0D_Nop:
	ret	; F665B3  ret

; --------------------------------------------------------------------------
; TrackAssignPresets_InitFromCurrentBank
; Called from: T_TrackAssignPresets_InitFromCurrentBank (x1)
; Touches: (0x0DFD) (0x0DFE) (0x12F6) (0x12F7) (0x12F8) (0x2070) (0x207B)
;          (0x2880) (0x34BB) (0x360A)
; Evidence: thunk slot T_TrackAssignPresets_InitFromCurrentBank holds `jp 0x00F665B4`, and 0xF665B4 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssignPresets_InitFromCurrentBank: unless the previous screen latch is 0x11: (0x0DFD) = 1, (0x0DFE) = BStore_CurrentBank (+1 to the display stage),
;   UI_StatusCode = 0; then, if UI_StatusCode is 0x23, requests screen 0x10.  Called by Paint_TrackAssignPresets.
TrackAssignPresets_InitFromCurrentBank:		; <- T_TrackAssignPresets_InitFromCurrentBank
	cp	(UI_ScreenLatch_Previous:16), 0x11	; F665B4  cp (0x207b),0x11
	jr	z, TrackAssignPresets_InitFromCurrentBank_Skip20	; F665B9  jr Z,0xf665e3
	or	(0x34bb:16), 0x04	; F665BB  or (0x34bb),0x04
	ld	(UI_StatusCode:16), 0	; F665C0  ld (0x2880),0x00
	ld	a, 1:opc	; F665C5  ld A,0x01
	ld	(3581:16), a	; F665C7  ld (0x0dfd),A
	dec	1, a	; F665CB  dec 1,A
	ld	(DisplayListB_Stage:16), a	; F665CD  ld (0x12f6),A
	ld	(DisplayListB_Stage+2:16), a	; F665D1  ld (0x12f8),A
	ld	a, (BStore_CurrentBank:16)	; F665D5  ld A,(0x360a)
	ld	(3582:16), a	; F665D9  ld (0x0dfe),A
	inc	1, a	; F665DD  inc 1,A
	ld	(DisplayListB_Stage+1:16), a	; F665DF  ld (0x12f7),A
TrackAssignPresets_InitFromCurrentBank_Skip20:
	cp	(UI_StatusCode:16), 0x23	; F665E3  cp (0x2880),0x23
	jr	nz, TrackAssignPresets_InitFromCurrentBank_Return11	; F665E8  jr NZ,0xf665f0
	ldw	(UI_Request:16), 32784	; F665EA  ld (0x2070),0x8010
TrackAssignPresets_InitFromCurrentBank_Return11:
	ret	; F665F0  ret

; --------------------------------------------------------------------------
; T_F42BFC_Nop
; Called from: T_F42BFC (x0)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_F42BFC holds `jp 0x00F665F1`, and 0xF665F1 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Purpose: none -- the entry is a lone `ret`.  Named T_F42BFC_Nop after what reaches it
;          (was sub_F665F1; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
T_F42BFC_Nop:		; <- T_F42BFC
	ret	; F665F1  ret

; --------------------------------------------------------------------------
; TrackAssignPresets_SelectField1
; Called from: T_TrackAssignPresets_SelectField1 (x1)
; Touches: (0x0DFD) (0x12F6)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_TrackAssignPresets_SelectField1 holds `jp 0x00F665F2`, and 0xF665F2 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 1 into (0x0DFD) and 1 - 1 into DisplayListB_Stage; (0x0DFD) is read by
;           ScreenLeaveBody_TrackAssignPresets, so it is the TrackAssignPresets screen's field cell.
; Unknown: what field 1 is on that screen.
; --------------------------------------------------------------------------
TrackAssignPresets_SelectField1:		; <- T_TrackAssignPresets_SelectField1
	ld	a, 1:opc	; F665F2  ld A,0x01
	ld	(3581:16), a	; F665F4  ld (0x0dfd),A
	dec	1, a	; F665F8  dec 1,A
	ld	(DisplayListB_Stage:16), a	; F665FA  ld (0x12f6),A
	ret	; F665FE  ret

; --------------------------------------------------------------------------
; TrackAssignPresets_SelectField2
; Called from: T_TrackAssignPresets_SelectField2 (x1)
; Touches: (0x0DFD) (0x12F6)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_TrackAssignPresets_SelectField2 holds `jp 0x00F665FF`, and 0xF665FF is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 2 into (0x0DFD) and 2 - 1 into DisplayListB_Stage; (0x0DFD) is read by
;           ScreenLeaveBody_TrackAssignPresets, so it is the TrackAssignPresets screen's field cell.
; Unknown: what field 2 is on that screen.
; --------------------------------------------------------------------------
TrackAssignPresets_SelectField2:		; <- T_TrackAssignPresets_SelectField2
	ld	a, 2:opc	; F665FF  ld A,0x02
	ld	(3581:16), a	; F66601  ld (0x0dfd),A
	dec	1, a	; F66605  dec 1,A
	ld	(DisplayListB_Stage:16), a	; F66607  ld (0x12f6),A
	ret	; F6660B  ret

; --------------------------------------------------------------------------
; TrackAssignPresets_SelectField3
; Called from: T_TrackAssignPresets_SelectField3 (x1)
; Touches: (0x0DFD) (0x12F6)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_TrackAssignPresets_SelectField3 holds `jp 0x00F6660C`, and 0xF6660C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 3 into (0x0DFD) and 3 - 1 into DisplayListB_Stage; (0x0DFD) is read by
;           ScreenLeaveBody_TrackAssignPresets, so it is the TrackAssignPresets screen's field cell.
; Unknown: what field 3 is on that screen.
; --------------------------------------------------------------------------
TrackAssignPresets_SelectField3:		; <- T_TrackAssignPresets_SelectField3
	ld	a, 3:opc	; F6660C  ld A,0x03
	ld	(3581:16), a	; F6660E  ld (0x0dfd),A
	dec	1, a	; F66612  dec 1,A
	ld	(DisplayListB_Stage:16), a	; F66614  ld (0x12f6),A
	ret	; F66618  ret

; --------------------------------------------------------------------------
; TrackAssignPresets_BankUp
; Called from: T_TrackAssignPresets_BankUp (x1)
; Touches: (0x0DFE) (0x12F7) (0x2075)
; Evidence: thunk slot T_TrackAssignPresets_BankUp holds `jp 0x00F66619`, and 0xF66619 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssignPresets_BankUp: (0x0DFE) + 1, stopping at 10, and (0x0DFE) + 1 to DisplayListB_Stage+1; repaint bit 3.  (0x0DFE) is the bank
;   the page shows: TrackAssignPresets_InitFromCurrentBank loads it from BStore_CurrentBank.  Called by SoftKeyCol3_TrackAssignPresets.
TrackAssignPresets_BankUp:		; <- T_TrackAssignPresets_BankUp
	or	(UI_RequestBits:16), 0x08	; F66619  or (0x2075),0x08
	and	(UI_RequestBits:16), 0xfe	; F6661E  and (0x2075),0xfe
	ld	a, (3582:16)	; F66623  ld A,(0x0dfe)
	cp	a, 10	; F66627  cp A,0x0a
	jr	z, TrackAssignPresets_BankUp_Skip21	; F6662A  jr Z,0xf6662e
	inc	1, a	; F6662C  inc 1,A
TrackAssignPresets_BankUp_Skip21:
	ld	(3582:16), a	; F6662E  ld (0x0dfe),A
	inc	1, a	; F66632  inc 1,A
	ld	(DisplayListB_Stage+1:16), a	; F66634  ld (0x12f7),A
	ret	; F66638  ret

; --------------------------------------------------------------------------
; TrackAssignPresets_BankDown
; Called from: T_TrackAssignPresets_BankDown (x1)
; Touches: (0x0DFE) (0x12F7) (0x2075)
; Evidence: thunk slot T_TrackAssignPresets_BankDown holds `jp 0x00F66639`, and 0xF66639 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssignPresets_BankDown: (0x0DFE) - 1, stopping at 0, mirrored +1 to DisplayListB_Stage+1.  Called by SoftKeyCol2_TrackAssignPresets.
TrackAssignPresets_BankDown:		; <- T_TrackAssignPresets_BankDown
	or	(UI_RequestBits:16), 0x08	; F66639  or (0x2075),0x08
	and	(UI_RequestBits:16), 0xfe	; F6663E  and (0x2075),0xfe
	ld	a, (3582:16)	; F66643  ld A,(0x0dfe)
	cp	a, 0:i3	; F66647  cp A,0
	jr	z, TrackAssignPresets_BankDown_Skip22	; F66649  jr Z,0xf6664d
	dec	1, a	; F6664B  dec 1,A
TrackAssignPresets_BankDown_Skip22:
	ld	(3582:16), a	; F6664D  ld (0x0dfe),A
	inc	1, a	; F66651  inc 1,A
	ld	(DisplayListB_Stage+1:16), a	; F66653  ld (0x12f7),A
	ret	; F66657  ret

; --------------------------------------------------------------------------
; TrackAssignPresets_SoftKeyCol6
; Called from: T_TrackAssignPresets_SoftKeyCol6 (x1)
; Touches: (0x2070) (0x2880)
; Calls:   TrackAssignPresets_ApplyPreset
; Evidence: thunk slot T_TrackAssignPresets_SoftKeyCol6 holds `jp 0x00F66658`, and 0xF66658 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssignPresets_SoftKeyCol6: the SoftKeyCol6 action of TrackAssignPresets -- called only by SoftKeyCol6_TrackAssignPresets.
TrackAssignPresets_SoftKeyCol6:		; <- T_TrackAssignPresets_SoftKeyCol6
	call	TrackAssignPresets_ApplyPreset	; F66658  call 0xf66668
	ld	(UI_StatusCode:16), 35	; F6665C  ld (0x2880),0x23
	ldw	(UI_Request:16), 16555	; F66661  ld (0x2070),0x40ab
	ret	; F66667  ret

; --------------------------------------------------------------------------
; TrackAssignPresets_ApplyPreset
; Called from: in-module: 0xF66658
; Touches: (0x0DFD) (0x0DFE) (0x0E02) (0x124C) (0x360A) (0x7F4D)  |
;          0x603422 0x603433 0x610000
; Calls:   TrackAssignPresets_ApplyToAllSongs T_SongClear_ClearBank T_Queue2C00_AppendRegs T_Queue2C00_DrainPassAB T_NoteRouting_RebuildForSong
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF66668 is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssignPresets_ApplyPreset: TRACK ASSIGN PRESETS: for preset (0x0DFD) 1 = TECHNICS SET-UP1 ( 1-16), 2 = SET-UP2
;   (17-32), 3 = GM SET-UP, clears song bank (0x0DFE) (T_SongClear_ClearBank; bank 10 = all, via TrackAssignPresets_ApplyToAllSongs), writes
;   the preset's 16 track-to-part bytes (+0x22; track 17 := part 0x20), the +0xC6 GM flag and 16 bytes at +0x33 to the
;   bank copy and, for the current bank, the workspace, where GM mode (0x7F4D) bit 2 then follows (CPU-2 post);
;   rebuilds note routing. Called only by TrackAssignPresets_SoftKeyCol6 (page: 'Any existing song will be cleared.
;   Press 0K'). Basis: caller + screen text + body. (notes/naming-pilot-2026-10-06/proposals_wave5_r.json)
TrackAssignPresets_ApplyPreset:
	ld	a, (3581:16)	; F66668  ld A,(0x0dfd)
	cp	a, 1:i3	; F6666C  cp A,1
	jrl	c, TrackAssignPresets_ApplyPreset_Join2	; F6666E  jrl C,0xf667c7
	cp	a, 3:i3	; F66671  cp A,3
	jrl	ugt, TrackAssignPresets_ApplyPreset_Join2	; F66673  jrl UGT,0xf667c7
	cp	(0x0dfe:16), 0x0a	; F66676  cp (0x0dfe),0x0a
	jr	nz, TrackAssignPresets_ApplyPreset_Skip	; F6667B  jr NZ,0xf66684
	call	TrackAssignPresets_ApplyToAllSongs	; F6667D  call 0xf6682c
	jrl	TrackAssignPresets_ApplyPreset_Join2	; F66681  jrl T,0xf667c7
TrackAssignPresets_ApplyPreset_Skip:
	ld	l, (3586:16)	; F66684  ld L,(0x0e02)
	pushw	hl	; F66688  push HL
	ld	a, (3582:16)	; F66689  ld A,(0x0dfe)
	ld	(3586:16), a	; F6668D  ld (0x0e02),A
	call	T_SongClear_ClearBank	; F66691  call 0xf426e0
	popw	hl	; F66695  pop HL
	ld	(3586:16), l	; F66696  ld (0x0e02),L
	xor	hl, hl	; F6669A  xor HL,HL
	ld	l, (3581:16)	; F6669C  ld L,(0x0dfd)
	dec	1, l	; F666A0  dec 1,L
	sla	l, 4	; F666A2  sla 0x04,L
	ld	xde, IndexMap_F667CC	; F666A5  ld XDE,0x00f667cc
	lda	xiy, (xde+hl)	; F666AA  lda XIY,XDE+HL
	ld	xix, 6356992	; F666AF  ld XIX,0x00610000
	xor	xwa, xwa	; F666B4  xor XWA,XWA
	ld	a, (3582:16)	; F666B6  ld A,(0x0dfe)
	ld	xbc, xwa	; F666BA  ld XBC,XWA
	sla	xwa, 11	; F666BC  sla 0x0b,XWA
	sla	xbc, 10	; F666BF  sla 0x0a,XBC
	add	xwa, xbc	; F666C2  add XWA,XBC
	lda	xix, (xix+wa)	; F666C4  lda XIX,XIX+WA
	ld	xwa, 34	; F666C9  ld XWA,0x00000022
	add	xix, xwa	; F666CE  add XIX,XWA
	ldw	bc, 16	; F666D0  ld BC,0x0010
	ldir85	; F666D3  ldir
	ld	(xix), 32	; F666D5  ld (XIX),0x20
	push	xhl	; F666D8  push XHL
	push	xde	; F666D9  push XDE
	ld	a, 0:opc	; F666DA  ld A,0x00
	cp	(0x0dfd:16), 0x03	; F666DC  cp (0x0dfd),0x03
	jr	nz, TrackAssignPresets_ApplyPreset_Skip2	; F666E1  jr NZ,0xf666e5
	ld	a, 255:opc	; F666E3  ld A,0xff
TrackAssignPresets_ApplyPreset_Skip2:
	ld	xix, 6356992	; F666E5  ld XIX,0x00610000
	push	xbc	; F666EA  push XBC
	xor	xbc, xbc	; F666EB  xor XBC,XBC
	xor	xhl, xhl	; F666ED  xor XHL,XHL
	ld	l, (3582:16)	; F666EF  ld L,(0x0dfe)
	ld	c, l	; F666F3  ld C,L
	sla	xhl, 11	; F666F5  sla 0x0b,XHL
	sla	xbc, 10	; F666F8  sla 0x0a,XBC
	add	xhl, xbc	; F666FB  add XHL,XBC
	pop	xbc	; F666FD  pop XBC
	lda	xix, (xix+hl)	; F666FE  lda XIX,XIX+HL
	ld	xde, xix	; F66703  ld XDE,XIX
	ld	xhl, 198	; F66705  ld XHL,0x000000c6
	add	xde, xhl	; F6670A  add XDE,XHL
	ld	(xde), a	; F6670C  ld (XDE),A
	pop	xde	; F6670E  pop XDE
	pop	xhl	; F6670F  pop XHL
	ld	a, (3582:16)	; F66710  ld A,(0x0dfe)
	cp	a, (BStore_CurrentBank:16)	; F66714  cp A,(0x360a)
	jr	nz, TrackAssignPresets_ApplyPreset_Skip4	; F66718  jr NZ,0xf6673c
	lda	xiy, (xde+hl)	; F6671A  lda XIY,XDE+HL
	ld	xix, BStore_TrackToPart	; F6671F  ld XIX,0x00603422
	ldw	bc, 16	; F66724  ld BC,0x0010
	ldir85	; F66727  ldir
	ld	(xix), 32	; F66729  ld (XIX),0x20
	ld	a, 0:opc	; F6672C  ld A,0x00
	cp	(0x0dfd:16), 0x03	; F6672E  cp (0x0dfd),0x03
	jr	nz, TrackAssignPresets_ApplyPreset_Skip3	; F66733  jr NZ,0xf66737
	ld	a, 255:opc	; F66735  ld A,0xff
TrackAssignPresets_ApplyPreset_Skip3:
	ld	(6304966:24), a	; F66737  ld (0x6034c6),A
TrackAssignPresets_ApplyPreset_Skip4:
	ld	xde, IndexMap_F667CC + 0x30	; F6673C  ld XDE,0x00f667fc
	lda	xiy, (xde+hl)	; F66741  lda XIY,XDE+HL
	ld	xix, 6356992	; F66746  ld XIX,0x00610000
	xor	xwa, xwa	; F6674B  xor XWA,XWA
	xor	xbc, xbc	; F6674D  xor XBC,XBC
	ld	a, (3582:16)	; F6674F  ld A,(0x0dfe)
	ld	c, a	; F66753  ld C,A
	sla	xwa, 11	; F66755  sla 0x0b,XWA
	sla	xbc, 10	; F66758  sla 0x0a,XBC
	add	xwa, xbc	; F6675B  add XWA,XBC
	lda	xix, (xix+wa)	; F6675D  lda XIX,XIX+WA
	ld	xwa, 51	; F66762  ld XWA,0x00000033
	add	xix, xwa	; F66767  add XIX,XWA
	ldw	bc, 16	; F66769  ld BC,0x0010
	ldir85	; F6676C  ldir
	ld	a, (3582:16)	; F6676E  ld A,(0x0dfe)
	cp	a, (BStore_CurrentBank:16)	; F66772  cp A,(0x360a)
	jr	nz, TrackAssignPresets_ApplyPreset_Join2	; F66776  jr NZ,0xf667c7
	lda	xiy, (xde+hl)	; F66778  lda XIY,XDE+HL
	ld	xix, 6304819	; F6677D  ld XIX,0x00603433
	ldw	bc, 16	; F66782  ld BC,0x0010
	ldir85	; F66785  ldir
	ld	a, (3582:16)	; F66787  ld A,(0x0dfe)
	cp	a, (BStore_CurrentBank:16)	; F6678B  cp A,(0x360a)
	jr	nz, TrackAssignPresets_ApplyPreset_Join2	; F6678F  jr NZ,0xf667c7
	cp	(0x0dfd:16), 0x03	; F66791  cp (0x0dfd),0x03
	jr	z, TrackAssignPresets_ApplyPreset_Skip5	; F66796  jr Z,0xf667a7
	bit	2, (0x7f4d:16)	; F66798  bit 2,(0x7f4d)
	jr	z, TrackAssignPresets_ApplyPreset_Join2	; F6679C  jr Z,0xf667c7
	and	(0x7f4d:16), 0xfb	; F6679E  and (0x7f4d),0xfb
	xor	a, a	; F667A3  xor A,A
	jr	TrackAssignPresets_ApplyPreset_Join	; F667A5  jr T,0xf667b4
TrackAssignPresets_ApplyPreset_Skip5:
	bit	2, (0x7f4d:16)	; F667A7  bit 2,(0x7f4d)
	jr	nz, TrackAssignPresets_ApplyPreset_Join2	; F667AB  jr NZ,0xf667c7
	or	(0x7f4d:16), 0x04	; F667AD  or (0x7f4d),0x04
	ld	a, 4:opc	; F667B2  ld A,0x04
TrackAssignPresets_ApplyPreset_Join:
	ld	e, 145:opc	; F667B4  ld E,0x91
	ld	d, 3:opc	; F667B6  ld D,0x03
	ld	w, 4:opc	; F667B8  ld W,0x04
	ld	(4684:16), 1	; F667BA  ld (0x124c),0x01
	call	T_Queue2C00_AppendRegs	; F667BF  call 0xf40f38
	call	T_Queue2C00_DrainPassAB	; F667C3  call 0xf40018
TrackAssignPresets_ApplyPreset_Join2:
	call	T_NoteRouting_RebuildForSong	; F667C7  call 0xf411b8
	ret	; F667CB  ret

; --------------------------------------------------------------------------
; IndexMap_F667CC -- 32 bytes at 0xF667CC counting 0x00..0x1F; 16 bytes at
;                    0xF667EC counting 0x00..0x0F; 32 bytes at 0xF667FC
;                    counting 0x00..0x1F; 16 bytes at 0xF6681C counting
;                    0x00..0x0F.  The name describes the CONTENT and claims
;                    nothing about the purpose.
; Read by: 2 byte-scan hits: 2 instruction operands -- `ld XDE,0x00f667cc`
;          at 0xF666A5 (operand field 1 byte in); `ld XDE,0x00f667cc` at
;          0xF6683F (operand field 1 byte in)
; Entry count: 96 bytes.  The run is maximal: the run starts at 0x00 and the
;              rule does not wrap, so it cannot extend left at all, and the
;              byte at 0xF6682C is 0x1D, not the 0x10 that would extend it.
; Evidence: every byte is compared with its predecessor + 1 on every emit.
;           The IDENT rule (no wraparound past 0xFF) fires ZERO times over
;           the 54,814 bytes of proven prom_b instruction text; ⚠ WITH
;           wraparound allowed it eats the 0xFF that ends the `jrl` at
;           0xF6A9A7, which is why the no-wrap clause is in the rule.
; Unknown: why an index map that returns its own index exists at all.
;          prom_b now has several; that is recorded, not explained.
; --------------------------------------------------------------------------
IndexMap_F667CC:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F667CC  [0..15]
	.byte	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F	; F667DC  [16..31]
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F667EC  [32..47]
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F667FC  [48..63]
	.byte	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F	; F6680C  [64..79]
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F6681C  [80..95]


; --------------------------------------------------------------------------
; TrackAssignPresets_ApplyToAllSongs
; Called from: in-module: 0xF6667D
; Touches: (0x0DFD) (0x124C) (0x7F4D)  |  0x603422 0x603433 0x610000
; Calls:   T_BStore_FreeList_Init_Veneer BStore_ResetAllDirectoriesAndCursors T_Queue2C00_AppendRegs T_Queue2C00_DrainPassAB
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF6682C is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackAssignPresets_ApplyToAllSongs: TRACK ASSIGN PRESETS with song (0x0DFE) = 10 (all): frees every block (T_BStore_FreeList_Init_Veneer
;   -> BStore_FreeList_Init) and empties all directories and saved cursors, live and in the ten banks (BStore_ResetAllDirectoriesAndCursors);
;   then writes preset (0x0DFD)'s track-to-part bytes (track 17 := 0x20), GM flag and +0x33 bytes to the workspace and
;   all ten banks; GM mode bit 2 follows. Basis: caller + caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_t.json)
TrackAssignPresets_ApplyToAllSongs:
	call	T_BStore_FreeList_Init_Veneer	; F6682C  call 0xf42880
	call	BStore_ResetAllDirectoriesAndCursors	; F66830  call 0xf66950
	xor	hl, hl	; F66834  xor HL,HL
	ld	l, (3581:16)	; F66836  ld L,(0x0dfd)
	dec	1, l	; F6683A  dec 1,L
	sla	l, 4	; F6683C  sla 0x04,L
	ld	xde, IndexMap_F667CC	; F6683F  ld XDE,0x00f667cc
	lda	xiy, (xde+hl)	; F66844  lda XIY,XDE+HL
	ld	xix, BStore_TrackToPart	; F66849  ld XIX,0x00603422
	ldw	bc, 16	; F6684E  ld BC,0x0010
	ldir85	; F66851  ldir
	ld	(xix), 32	; F66853  ld (XIX),0x20
	ld	a, 0:opc	; F66856  ld A,0x00
	cp	(0x0dfd:16), 0x03	; F66858  cp (0x0dfd),0x03
	jr	nz, TrackAssignPresets_ApplyToAllSongs_Skip	; F6685D  jr NZ,0xf66861
	ld	a, 255:opc	; F6685F  ld A,0xff
TrackAssignPresets_ApplyToAllSongs_Skip:
	ld	(6304966:24), a	; F66861  ld (0x6034c6),A
	ldib_erp	52, 0	; F66866  ld RC3,0
TrackAssignPresets_ApplyToAllSongs_Loop:
	ld	xix, 6356992	; F66869  ld XIX,0x00610000
	push	xbc	; F6686E  push XBC
	xor	xbc, xbc	; F6686F  xor XBC,XBC
	xor	xwa, xwa	; F66871  xor XWA,XWA
	ldto_berp	a, 0x34	; F66873  ld A,RC3
	ld	c, a	; F66876  ld C,A
	sla	xwa, 11	; F66878  sla 0x0b,XWA
	sla	xbc, 10	; F6687B  sla 0x0a,XBC
	add	xwa, xbc	; F6687E  add XWA,XBC
	pop	xbc	; F66880  pop XBC
	add	xix, xwa	; F66881  add XIX,XWA
	ld	xwa, 34	; F66883  ld XWA,0x00000022
	add	xix, xwa	; F66888  add XIX,XWA
	lda	xiy, (xde+hl)	; F6688A  lda XIY,XDE+HL
	ldw	bc, 16	; F6688F  ld BC,0x0010
	ldir85	; F66892  ldir
	ld	(xix), 32	; F66894  ld (XIX),0x20
	ld	xix, 6356992	; F66897  ld XIX,0x00610000
	push	xbc	; F6689C  push XBC
	xor	xbc, xbc	; F6689D  xor XBC,XBC
	xor	xwa, xwa	; F6689F  xor XWA,XWA
	ldto_berp	a, 0x34	; F668A1  ld A,RC3
	ld	c, a	; F668A4  ld C,A
	sla	xwa, 11	; F668A6  sla 0x0b,XWA
	sla	xbc, 10	; F668A9  sla 0x0a,XBC
	add	xwa, xbc	; F668AC  add XWA,XBC
	pop	xbc	; F668AE  pop XBC
	add	xix, xwa	; F668AF  add XIX,XWA
	ld	xwa, 198	; F668B1  ld XWA,0x000000c6
	add	xix, xwa	; F668B6  add XIX,XWA
	ld	a, 0:opc	; F668B8  ld A,0x00
	cp	(0x0dfd:16), 0x03	; F668BA  cp (0x0dfd),0x03
	jr	nz, TrackAssignPresets_ApplyToAllSongs_Skip2	; F668BF  jr NZ,0xf668c3
	ld	a, 255:opc	; F668C1  ld A,0xff
TrackAssignPresets_ApplyToAllSongs_Skip2:
	ld	(xix), a	; F668C3  ld (XIX),A
	inc1b_erp	52	; F668C5  inc 1,RC3
	cp_erpb	52, 10	; F668C8  cp RC3,0x0a
	jr	c, TrackAssignPresets_ApplyToAllSongs_Loop	; F668CC  jr C,0xf66869
	ld	xde, IndexMap_F667CC + 0x30	; F668CE  ld XDE,0x00f667fc
	lda	xiy, (xde+hl)	; F668D3  lda XIY,XDE+HL
	ld	xix, 6304819	; F668D8  ld XIX,0x00603433
	ldw	bc, 16	; F668DD  ld BC,0x0010
	ldir85	; F668E0  ldir
	ldib_erp	52, 0	; F668E2  ld RC3,0
TrackAssignPresets_ApplyToAllSongs_Loop2:
	ld	xix, 6356992	; F668E5  ld XIX,0x00610000
	push	xbc	; F668EA  push XBC
	xor	xbc, xbc	; F668EB  xor XBC,XBC
	xor	xwa, xwa	; F668ED  xor XWA,XWA
	ldto_berp	a, 0x34	; F668EF  ld A,RC3
	ld	c, a	; F668F2  ld C,A
	sla	xwa, 11	; F668F4  sla 0x0b,XWA
	sla	xbc, 10	; F668F7  sla 0x0a,XBC
	add	xwa, xbc	; F668FA  add XWA,XBC
	pop	xbc	; F668FC  pop XBC
	add	xix, xwa	; F668FD  add XIX,XWA
	ld	xwa, 51	; F668FF  ld XWA,0x00000033
	add	xix, xwa	; F66904  add XIX,XWA
	lda	xiy, (xde+hl)	; F66906  lda XIY,XDE+HL
	ldw	bc, 16	; F6690B  ld BC,0x0010
	ldir85	; F6690E  ldir
	inc1b_erp	52	; F66910  inc 1,RC3
	cp_erpb	52, 10	; F66913  cp RC3,0x0a
	jr	c, TrackAssignPresets_ApplyToAllSongs_Loop2	; F66917  jr C,0xf668e5
	cp	(0x0dfd:16), 0x03	; F66919  cp (0x0dfd),0x03
	jr	z, TrackAssignPresets_ApplyToAllSongs_Skip3	; F6691E  jr Z,0xf6692f
	bit	2, (0x7f4d:16)	; F66920  bit 2,(0x7f4d)
	jr	z, TrackAssignPresets_ApplyToAllSongs_Return	; F66924  jr Z,0xf6694f
	and	(0x7f4d:16), 0xfb	; F66926  and (0x7f4d),0xfb
	xor	a, a	; F6692B  xor A,A
	jr	TrackAssignPresets_ApplyToAllSongs_Join	; F6692D  jr T,0xf6693c
TrackAssignPresets_ApplyToAllSongs_Skip3:
	bit	2, (0x7f4d:16)	; F6692F  bit 2,(0x7f4d)
	jr	nz, TrackAssignPresets_ApplyToAllSongs_Return	; F66933  jr NZ,0xf6694f
	or	(0x7f4d:16), 0x04	; F66935  or (0x7f4d),0x04
	ld	a, 4:opc	; F6693A  ld A,0x04
TrackAssignPresets_ApplyToAllSongs_Join:
	ld	e, 145:opc	; F6693C  ld E,0x91
	ld	d, 3:opc	; F6693E  ld D,0x03
	ld	w, 4:opc	; F66940  ld W,0x04
	ld	(4684:16), 1	; F66942  ld (0x124c),0x01
	call	T_Queue2C00_AppendRegs	; F66947  call 0xf40f38
	call	T_Queue2C00_DrainPassAB	; F6694B  call 0xf40018
TrackAssignPresets_ApplyToAllSongs_Return:
	ret	; F6694F  ret

; --------------------------------------------------------------------------
; BStore_ResetAllDirectoriesAndCursors
; Called from: in-module: 0xF66830
; Touches:   |  0x60347E 0x6034A0 0x603500 0x610000
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF66950 is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ResetAllDirectoriesAndCursors: Empties every track directory and cursor: live directory 0x603500 (17 x {0x00,
;   0xFFFF}), live cursors 0x3460 (0xFFFF) / 0x3482 (5), saved cursors 0x60347E (0xFFFF) / 0x6034A0 (5), the same
;   three in each of the ten banks (0x610000 + n*0xC00 + 0x100 / +0x7E / +0xA0), and the 16 words 0x0D50 (0) and bytes
;   0x0D70 (5). Frees no block -- TrackAssignPresets_ApplyToAllSongs calls T_BStore_FreeList_Init_Veneer (BStore_FreeList_Init) just
;   before. Has no `ret`: it ends in the 0x0E padding at 0xF66A32. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_x.json)
BStore_ResetAllDirectoriesAndCursors:
	ld	xix, 6305024	; F66950  ld XIX,0x00603500
	xor	bc, bc	; F66955  xor BC,BC
BStore_ResetAllDirectoriesAndCursors_Loop3:
	ld	(xix+bc), 0x00	; F66957  ld (XIX+BC),0x00
	inc	1, bc	; F6695D  inc 1,BC
	ldw	(xix+bc), 0xffff	; F6695F  ld (XIX+BC),0xffff
	inc	2, bc	; F66966  inc 2,BC
	cp	bc, 51	; F66968  cp BC,0x0033
	jr	c, BStore_ResetAllDirectoriesAndCursors_Loop3	; F6696C  jr C,0xf66957
	ld	xix, 13408	; F6696E  ld XIX,0x00003460
	ldw	wa, 65535	; F66973  ld WA,0xffff
	ld	c, 17:opc	; F66976  ld C,0x11
	ld	(xix+), wa	; F66978  ld (XIX+),WA
	djnz8	c, -6	; F6697B  djnz C,0xf66978
	ld	xix, 13442	; F6697E  ld XIX,0x00003482
	ld	a, 5:opc	; F66983  ld A,0x05
	ld	c, 17:opc	; F66985  ld C,0x11
	ld	(xix+), a	; F66987  ld (XIX+),A
	djnz8	c, -6	; F6698A  djnz C,0xf66987
	ld	xix, 6304894	; F6698D  ld XIX,0x0060347e
	ldw	wa, 65535	; F66992  ld WA,0xffff
	ld	c, 17:opc	; F66995  ld C,0x11
	ld	(xix+), wa	; F66997  ld (XIX+),WA
	djnz8	c, -6	; F6699A  djnz C,0xf66997
	ld	xix, 6304928	; F6699D  ld XIX,0x006034a0
	ld	a, 5:opc	; F669A2  ld A,0x05
	ld	c, 17:opc	; F669A4  ld C,0x11
	ld	(xix+), a	; F669A6  ld (XIX+),A
	djnz8	c, -6	; F669A9  djnz C,0xf669a6
	ldib_erp	52, 0	; F669AC  ld RC3,0
	ld	xde, 6356992	; F669AF  ld XDE,0x00610000
BStore_ResetAllDirectoriesAndCursors_Loop4:
	push	xbc	; F669B4  push XBC
	xor	xbc, xbc	; F669B5  xor XBC,XBC
	xor	xhl, xhl	; F669B7  xor XHL,XHL
	ldto_berp	l, 0x34	; F669B9  ld L,RC3
	ld	c, l	; F669BC  ld C,L
	sla	xhl, 11	; F669BE  sla 0x0b,XHL
	sla	xbc, 10	; F669C1  sla 0x0a,XBC
	add	xhl, xbc	; F669C4  add XHL,XBC
	pop	xbc	; F669C6  pop XBC
	add	xhl, xde	; F669C7  add XHL,XDE
	ld	xix, 256	; F669C9  ld XIX,0x00000100
	add	xix, xhl	; F669CE  add XIX,XHL
	xor	bc, bc	; F669D0  xor BC,BC
BStore_ResetAllDirectoriesAndCursors_Loop5:
	ld	(xix+bc), 0x00	; F669D2  ld (XIX+BC),0x00
	inc	1, bc	; F669D8  inc 1,BC
	ldw	(xix+bc), 0xffff	; F669DA  ld (XIX+BC),0xffff
	inc	2, bc	; F669E1  inc 2,BC
	cp	bc, 51	; F669E3  cp BC,0x0033
	jr	c, BStore_ResetAllDirectoriesAndCursors_Loop5	; F669E7  jr C,0xf669d2
	ld	xix, 126	; F669E9  ld XIX,0x0000007e
	add	xix, xhl	; F669EE  add XIX,XHL
	ldw	wa, 65535	; F669F0  ld WA,0xffff
	ld	c, 17:opc	; F669F3  ld C,0x11
	ld	(xix+), wa	; F669F5  ld (XIX+),WA
	djnz8	c, -6	; F669F8  djnz C,0xf669f5
	ld	xix, 160	; F669FB  ld XIX,0x000000a0
	add	xix, xhl	; F66A00  add XIX,XHL
	ld	a, 5:opc	; F66A02  ld A,0x05
	ld	c, 17:opc	; F66A04  ld C,0x11
	ld	(xix+), a	; F66A06  ld (XIX+),A
	djnz8	c, -6	; F66A09  djnz C,0xf66a06
	inc1b_erp	52	; F66A0C  inc 1,RC3
	cp_erpb	52, 10	; F66A0F  cp RC3,0x0a
	jrl	c, BStore_ResetAllDirectoriesAndCursors_Loop4	; F66A13  jrl C,0xf669b4
	ld	xix, 3408	; F66A16  ld XIX,0x00000d50
	xor	wa, wa	; F66A1B  xor WA,WA
	ld	c, 16:opc	; F66A1D  ld C,0x10
	ld	(xix+), wa	; F66A1F  ld (XIX+),WA
	djnz8	c, -6	; F66A22  djnz C,0xf66a1f
	ld	xix, 3440	; F66A25  ld XIX,0x00000d70
	ld	c, 16:opc	; F66A2A  ld C,0x10
	ld	(xix+), a	; F66A2C  ld (XIX+),A
	djnz8	c, -6	; F66A2F  djnz C,0xf66a2c
	.fill	2510, 1, 0x0E	; F66A32-F673FF  `ret` padding (asserted pure 0x0E)
