

; --------------------------------------------------------------------------
; BStore_AppendBytes_Join3_Veneer
; Called from: T_BStore_AppendBytes_Join3_Veneer (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_AppendBytes_Join3_Veneer holds `jp 0x00F7AA00`, and 0xF7AA00 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
BStore_AppendBytes_Join3_Veneer:		; <- T_BStore_AppendBytes_Join3_Veneer
	jr	BStore_AppendBytes_Join3	; F7AA00  jr T,0xf7aa04

; --------------------------------------------------------------------------
; BStore_AppendBytes_Join4_Veneer
; Called from: T_BStore_AppendBytes_Join4_Veneer (x1)
; Touches: (0x207E) (0x212E) (0x215E) (0x34BB)
; Calls:   T_Seq_SaveTrackMaskAndStopAll T_Seq_RestoreTrackMaskAndRewind
; Evidence: thunk slot T_BStore_AppendBytes_Join4_Veneer holds `jp 0x00F7AA02`, and 0xF7AA02 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
BStore_AppendBytes_Join4_Veneer:		; <- T_BStore_AppendBytes_Join4_Veneer
	jr	BStore_AppendBytes_Join4	; F7AA02  jr T,0xf7aa1f
BStore_AppendBytes_Join3:
	call	T_Seq_SaveTrackMaskAndStopAll	; F7AA04  call 0xf409f8
	ld	(UI_ScreenStage:16), 0	; F7AA08  ld (0x207e),0x00
	ldw	(8542:16), 0	; F7AA0D  ld (0x215e),0x0000
	orw	(0x212e:16), 0x0100	; F7AA13  or (0x212e),0x0100
	or	(0x34bb:16), 0x04	; F7AA19  or (0x34bb),0x04
	ret	; F7AA1E  ret
BStore_AppendBytes_Join4:
	call	T_Seq_RestoreTrackMaskAndRewind	; F7AA1F  call 0xf409f4
	and	(0x34bb:16), 0xfb	; F7AA23  and (0x34bb),0xfb
	ret	; F7AA28  ret

; --------------------------------------------------------------------------
; SongClear_InitFields
; Called from: T_SongClear_InitFields (x1)
; Touches: (0x0E02) (0x12F6) (0x2070) (0x207B) (0x20A9) (0x2880) (0x360A)
; Calls:   SongStore_LoadSongHeaderToDisplay
; Evidence: thunk slot T_SongClear_InitFields holds `jp 0x00F7AA29`, and 0xF7AA29 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongClear_InitFields: Paint_SongClear's first step (slot T_SongClear_InitFields): unless the previous screen was SONG CLEAR
;   (0x1B), UI_StatusCode := 0xFF, the song field (0x0E02) := BStore_CurrentBank, DisplayListB_Stage := song + 1 and
;   SongStore_LoadSongHeaderToDisplay; when it was and UI_StatusCode is 0x23 (job done), UI_Request := 0x0201 and
;   (0x20A9) bit 0 cleared. Basis: caller + body + siblings (AdvanceDelay_InitFields). (notes/naming-
;   pilot-2026-10-06/proposals_wave7_z.json)
SongClear_InitFields:		; <- T_SongClear_InitFields
	cp	(UI_ScreenLatch_Previous:16), 0x1b	; F7AA29  cp (0x207b),0x1b
	jr	z, BStore_AppendBytes_Skip4	; F7AA2E  jr Z,0xf7aa49
	ld	(UI_StatusCode:16), 255	; F7AA30  ld (0x2880),0xff
	ld	a, (BStore_CurrentBank:16)	; F7AA35  ld A,(0x360a)
	ld	(3586:16), a	; F7AA39  ld (0x0e02),A
	inc	1, a	; F7AA3D  inc 1,A
	ld	(DisplayListB_Stage:16), a	; F7AA3F  ld (0x12f6),A
	call	SongStore_LoadSongHeaderToDisplay	; F7AA43  call 0xf7aa5e
	jr	BStore_AppendBytes_Return	; F7AA47  jr T,0xf7aa5d
BStore_AppendBytes_Skip4:
	cp	(UI_StatusCode:16), 0x23	; F7AA49  cp (0x2880),0x23
	jr	nz, BStore_AppendBytes_Return	; F7AA4E  jr NZ,0xf7aa5d
	ldw	(UI_Request:16), 513	; F7AA50  ld (0x2070),0x0201
	and	(0x20a9:16), 0xfe	; F7AA56  and (0x20a9),0xfe
	jr	BStore_AppendBytes_Return	; F7AA5B  jr T,0xf7aa5d
BStore_AppendBytes_Return:
	ret	; F7AA5D  ret

; --------------------------------------------------------------------------
; SongStore_LoadSongHeaderToDisplay -- read 6 bytes from bank (0x0E02)'s
;                                      copy at 0x00610000 + n*0xC00 + 0xCA
;                                      into (0x12F7)-(0x12FC), the fields
;                                      the SEQUENCER PLAY screen draws
; Called from: in-module: 0xF7AA43 0xF7AAAA 0xF7AAD8
; Inputs:  (0x0E02) = bank/song index, 0-based
; Outputs: (0x12F7)..(0x12FC)
; Touches: (0x0E02)  |  0x0000CA 0x0012F7 0x610000
; Evidence: `sla 0x0b,XWA / sla 0x0a,XBC / add` at 0xF7AA6D-0xF7AA73 is the
;           n*0xC00 bank index notes/FINDINGS-prom_b-block-store.md reads at
;           0xF64B3D; `add XIY,0x000000ca` fixes the field offset and `ld
;           XIX,0x000012f7 / ld BC,0x0006 / ldir` the destination and
;           length.  DIRECTION: TLCS-900 `ldir` writes (XIX)+ and reads
;           (XIY)+ -- ../mame/src/devices/cpu/tlcs900/900tbl.hxx:2483 with
;           :5437-5438 -- so the bank is the SOURCE.  (0x12F7) is drawn by
;           14 interpreter-B display-list records (`python3
;           notes/prom_b_var_screens.py --var 0x12F7`)
; Unknown: what the six bytes mean individually
; --------------------------------------------------------------------------
SongStore_LoadSongHeaderToDisplay:
	xor	xbc, xbc	; F7AA5E  xor XBC,XBC
	xor	xwa, xwa	; F7AA60  xor XWA,XWA
	ld	a, (3586:16)	; F7AA62  ld A,(0x0e02)
	ld	c, a	; F7AA66  ld C,A
	ld	xiy, 6356992	; F7AA68  ld XIY,0x00610000
	sla	xwa, 11	; F7AA6D  sla 0x0b,XWA
	sla	xbc, 10	; F7AA70  sla 0x0a,XBC
	add	xwa, xbc	; F7AA73  add XWA,XBC
	add	xiy, xwa	; F7AA75  add XIY,XWA
	add	xiy, 202	; F7AA77  add XIY,0x000000ca
	ld	xix, DisplayListB_Stage+1	; F7AA7D  ld XIX,0x000012f7
	ldw	bc, 6	; F7AA82  ld BC,0x0006
	ldir85	; F7AA85  ldir
	ret	; F7AA87  ret

; --------------------------------------------------------------------------
; T_F428BC_Nop
; Called from: T_F428BC (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_F428BC holds `jp 0x00F7AA88`, and 0xF7AA88 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Purpose: none -- the entry is a lone `ret`.  Named T_F428BC_Nop after what reaches it
;          (was sub_F7AA88; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
T_F428BC_Nop:		; <- T_F428BC
	ret	; F7AA88  ret

; --------------------------------------------------------------------------
; SongClear_SoftKeyCol4
; Called from: T_SongClear_SoftKeyCol4 (x1)
; Touches: (0x0E02) (0x12F6) (0x2075) (0x207E)
; Calls:   SongStore_LoadSongHeaderToDisplay
; Evidence: thunk slot T_SongClear_SoftKeyCol4 holds `jp 0x00F7AA89`, and 0xF7AA89 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongClear_SoftKeyCol4: the SoftKeyCol4 action of SongClear -- called only by SoftKeyCol4_SongClear.
SongClear_SoftKeyCol4:		; <- T_SongClear_SoftKeyCol4
	cp	(UI_ScreenStage:16), 0x01	; F7AA89  cp (0x207e),0x01
	jr	z, SongStore_LoadSongHeaderToDisplay_Return	; F7AA8E  jr Z,0xf7aaae
	or	(UI_RequestBits:16), 0x09	; F7AA90  or (0x2075),0x09
	ld	a, (3586:16)	; F7AA95  ld A,(0x0e02)
	cp	a, 10	; F7AA99  cp A,0x0a
	jr	z, SongStore_LoadSongHeaderToDisplay_Return	; F7AA9C  jr Z,0xf7aaae
	inc	1, a	; F7AA9E  inc 1,A
	ld	(3586:16), a	; F7AAA0  ld (0x0e02),A
	inc	1, a	; F7AAA4  inc 1,A
	ld	(DisplayListB_Stage:16), a	; F7AAA6  ld (0x12f6),A
	call	SongStore_LoadSongHeaderToDisplay	; F7AAAA  call 0xf7aa5e
SongStore_LoadSongHeaderToDisplay_Return:
	ret	; F7AAAE  ret

; --------------------------------------------------------------------------
; SongClear_SoftKeyCol3
; Called from: T_SongClear_SoftKeyCol3 (x1)
; Touches: (0x0E02) (0x12F6) (0x2075) (0x207E)
; Calls:   SongStore_LoadSongHeaderToDisplay
; Evidence: thunk slot T_SongClear_SoftKeyCol3 holds `jp 0x00F7AAAF`, and 0xF7AAAF is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongClear_SoftKeyCol3: the SoftKeyCol3 action of SongClear -- called only by SoftKeyCol3_SongClear.
SongClear_SoftKeyCol3:		; <- T_SongClear_SoftKeyCol3
	cp	(UI_ScreenStage:16), 0x01	; F7AAAF  cp (0x207e),0x01
	jr	z, SongStore_LoadSongHeaderToDisplay_Return2	; F7AAB4  jr Z,0xf7aadc
	or	(UI_RequestBits:16), 0x09	; F7AAB6  or (0x2075),0x09
	ld	a, (3586:16)	; F7AABB  ld A,(0x0e02)
	cp	a, 0:i3	; F7AABF  cp A,0
	jr	z, SongStore_LoadSongHeaderToDisplay_Return2	; F7AAC1  jr Z,0xf7aadc
	cp	a, 10	; F7AAC3  cp A,0x0a
	jr	nz, SongStore_LoadSongHeaderToDisplay_Skip	; F7AAC6  jr NZ,0xf7aacc
	ld	a, 9:opc	; F7AAC8  ld A,0x09
	jr	SongStore_LoadSongHeaderToDisplay_Join	; F7AACA  jr T,0xf7aace
SongStore_LoadSongHeaderToDisplay_Skip:
	dec	1, a	; F7AACC  dec 1,A
SongStore_LoadSongHeaderToDisplay_Join:
	ld	(3586:16), a	; F7AACE  ld (0x0e02),A
	inc	1, a	; F7AAD2  inc 1,A
	ld	(DisplayListB_Stage:16), a	; F7AAD4  ld (0x12f6),A
	call	SongStore_LoadSongHeaderToDisplay	; F7AAD8  call 0xf7aa5e
SongStore_LoadSongHeaderToDisplay_Return2:
	ret	; F7AADC  ret

; --------------------------------------------------------------------------
; SongClear_LcdKeyRow5
; Called from: T_SongClear_LcdKeyRow5 (x1)
; Touches: (0x2070) (0x207E)
; Evidence: thunk slot T_SongClear_LcdKeyRow5 holds `jp 0x00F7AADD`, and 0xF7AADD is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongClear_LcdKeyRow5: the LcdKeyRow5 action of SongClear -- called only by LcdKeyRow5_SongClear.
SongClear_LcdKeyRow5:		; <- T_SongClear_LcdKeyRow5
	cp	(UI_ScreenStage:16), 0x01	; F7AADD  cp (0x207e),0x01
	jr	nz, SongStore_LoadSongHeaderToDisplay_Return3	; F7AAE2  jr NZ,0xf7aaef
	ld	(UI_ScreenStage:16), 0	; F7AAE4  ld (0x207e),0x00
	ldw	(UI_Request:16), 32794	; F7AAE9  ld (0x2070),0x801a
SongStore_LoadSongHeaderToDisplay_Return3:
	ret	; F7AAEF  ret

; --------------------------------------------------------------------------
; SongClear_LcdKeyRow4
; Called from: T_SongClear_LcdKeyRow4 (x1)
; Touches: (0x0D4A) (0x0E02) (0x2070) (0x2071) (0x2075) (0x207E) (0x2880)
;          (0x3010) (0x360A) (0x360C)
; Calls:   T_SongClear_ClearBank SongClear_ClearBankTrackMask
; Evidence: thunk slot T_SongClear_LcdKeyRow4 holds `jp 0x00F7AAF0`, and 0xF7AAF0 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongClear_LcdKeyRow4: the LcdKeyRow4 action of SongClear -- called only by LcdKeyRow4_SongClear.
SongClear_LcdKeyRow4:		; <- T_SongClear_LcdKeyRow4
	and	(UI_RequestBits:16), 0xf6	; F7AAF0  and (0x2075),0xf6
	cp	(UI_ScreenStage:16), 0x01	; F7AAF5  cp (0x207e),0x01
	jr	z, SongStore_LoadSongHeaderToDisplay_Skip2	; F7AAFA  jr Z,0xf7ab08
	ld	(UI_ScreenStage:16), 1	; F7AAFC  ld (0x207e),0x01
	or	(UI_Request_Hi:16), 0x10	; F7AB01  or (0x2071),0x10
	jr	SongStore_LoadSongHeaderToDisplay_Return4	; F7AB06  jr T,0xf7ab3e
SongStore_LoadSongHeaderToDisplay_Skip2:
	ld	(UI_StatusCode:16), 255	; F7AB08  ld (0x2880),0xff
	ld	(BStore_ErrorCode:16), 0	; F7AB0D  ld (0x0d4a),0x00
	call	T_SongClear_ClearBank	; F7AB12  call 0xf426e0
	call	SongClear_ClearBankTrackMask	; F7AB16  call 0xf7ab3f
	ld	a, (3586:16)	; F7AB1A  ld A,(0x0e02)
	cp	a, (BStore_CurrentBank:16)	; F7AB1E  cp A,(0x360a)
	jr	nz, SongStore_LoadSongHeaderToDisplay_Skip3	; F7AB22  jr NZ,0xf7ab2e
	xor	xwa, xwa	; F7AB24  xor XWA,XWA
	ld	(12304:16), xwa	; F7AB26  ld (0x3010),XWA
	ld	(13836:16), xwa	; F7AB2A  ld (0x360c),XWA
SongStore_LoadSongHeaderToDisplay_Skip3:
	ld	(UI_ScreenStage:16), 0	; F7AB2E  ld (0x207e),0x00
	ld	(UI_StatusCode:16), 35	; F7AB33  ld (0x2880),0x23
	ldw	(UI_Request:16), 16555	; F7AB38  ld (0x2070),0x40ab
SongStore_LoadSongHeaderToDisplay_Return4:
	ret	; F7AB3E  ret

; --------------------------------------------------------------------------
; SongClear_ClearBankTrackMask
; Called from: in-module: 0xF7AB16
; Touches: (0x0E02) (0x360C)  |  0x00001E 0x610000
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7AB3F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongClear_ClearBankTrackMask: Zeroes the +0x1E long -- the song's track mask, (0x360C) as
;   BStore_Workspace_SaveToBank stores it -- in bank copy (0x0E02) at 0x610000 + n*0xC00; with (0x0E02) = 10 (ALL) in
;   all ten bank copies, and (0x360C) itself. SongClear_LcdKeyRow4 runs it right after T_SongClear_ClearBank. Basis:
;   caller + body. (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
SongClear_ClearBankTrackMask:
	cp	(0x0e02:16), 0x0a	; F7AB3F  cp (0x0e02),0x0a
	jr	nz, SongClear_ClearBankTrackMask_Skip	; F7AB44  jr NZ,0xf7ab76
	xor	xwa, xwa	; F7AB46  xor XWA,XWA
	ld	(13836:16), xwa	; F7AB48  ld (0x360c),XWA
	ld	xde, 6356992	; F7AB4C  ld XDE,0x00610000
SongClear_ClearBankTrackMask_Loop:
	ld	xhl, xwa	; F7AB51  ld XHL,XWA
	push	xbc	; F7AB53  push XBC
	ld	xbc, xhl	; F7AB54  ld XBC,XHL
	sla	xhl, 11	; F7AB56  sla 0x0b,XHL
	sla	xbc, 10	; F7AB59  sla 0x0a,XBC
	add	xhl, xbc	; F7AB5C  add XHL,XBC
	pop	xbc	; F7AB5E  pop XBC
	add	xhl, xde	; F7AB5F  add XHL,XDE
	add	xhl, 30	; F7AB61  add XHL,0x0000001e
	push	xbc	; F7AB67  push XBC
	xor	xbc, xbc	; F7AB68  xor XBC,XBC
	ld	(xhl), xbc	; F7AB6A  ld (XHL),XBC
	pop	xbc	; F7AB6C  pop XBC
	inc	1, a	; F7AB6D  inc 1,A
	cp	a, 10	; F7AB6F  cp A,0x0a
	jr	c, SongClear_ClearBankTrackMask_Loop	; F7AB72  jr C,0xf7ab51
	jr	SongClear_ClearBankTrackMask_Return	; F7AB74  jr T,0xf7ab9b
SongClear_ClearBankTrackMask_Skip:
	ld	xde, 6356992	; F7AB76  ld XDE,0x00610000
	push	xbc	; F7AB7B  push XBC
	xor	xwa, xwa	; F7AB7C  xor XWA,XWA
	ld	a, (3586:16)	; F7AB7E  ld A,(0x0e02)
	ld	xbc, xwa	; F7AB82  ld XBC,XWA
	sla	xwa, 11	; F7AB84  sla 0x0b,XWA
	sla	xbc, 10	; F7AB87  sla 0x0a,XBC
	add	xwa, xbc	; F7AB8A  add XWA,XBC
	pop	xbc	; F7AB8C  pop XBC
	add	xde, xwa	; F7AB8D  add XDE,XWA
	add	xde, 30	; F7AB8F  add XDE,0x0000001e
	push	xbc	; F7AB95  push XBC
	xor	xbc, xbc	; F7AB96  xor XBC,XBC
	ld	(xde), xbc	; F7AB98  ld (XDE),XBC
	pop	xbc	; F7AB9A  pop XBC
SongClear_ClearBankTrackMask_Return:
	ret	; F7AB9B  ret

; --------------------------------------------------------------------------
; TrackClear_ResetSelectionOnEntry
; Called from: T_TrackClear_ResetSelectionOnEntry (x1)
; Touches: (0x0DBE) (0x207A) (0x207B) (0x212E) (0x215E)
; Evidence: thunk slot T_TrackClear_ResetSelectionOnEntry holds `jp 0x00F7AB9C`, and 0xF7AB9C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackClear_ResetSelectionOnEntry: On a newly entered screen (UI_ScreenLatch != UI_ScreenLatch_Previous): the TRACK
;   CLEAR selection mask (0x0DBE) := 0, (0x215E) := 0, (0x212E) |= 0x100 (the pair TrackClear_ReturnToStageZero also
;   resets). Paint_TrackClear calls it (slot T_TrackClear_ResetSelectionOnEntry) at stage 0 before drawing. Basis: caller + body + RAM use.
;   (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
TrackClear_ResetSelectionOnEntry:		; <- T_TrackClear_ResetSelectionOnEntry
	ld	a, (UI_ScreenLatch:16)	; F7AB9C  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F7ABA0  cp A,(0x207b)
	jr	z, TrackClear_ResetSelectionOnEntry_Return2	; F7ABA4  jr Z,0xf7abb8
	ldw	(3518:16), 0	; F7ABA6  ld (0x0dbe),0x0000
	ldw	(8542:16), 0	; F7ABAC  ld (0x215e),0x0000
	orw	(0x212e:16), 0x0100	; F7ABB2  or (0x212e),0x0100
TrackClear_ResetSelectionOnEntry_Return2:
	ret	; F7ABB8  ret

; --------------------------------------------------------------------------
; TrackClear_OnLeave
; Called from: T_TrackClear_OnLeave (x1)
; Touches: (0x0E46) (0x207A) (0x3010) (0x360C)
; Calls:   T_Seq_RequestRewind
; Evidence: thunk slot T_TrackClear_OnLeave holds `jp 0x00F7ABB9`, and 0xF7ABB9 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackClear_OnLeave: the LEAVE work of TrackClear -- the one unnamed routine ScreenLeaveBody_TrackClear calls, and nothing else calls it
;   (notes/prom_ab_screen_enter_leave_work.py).
TrackClear_OnLeave:		; <- T_TrackClear_OnLeave
	cp	(UI_ScreenLatch:16), 0x1c	; F7ABB9  cp (0x207a),0x1c
	jr	z, TrackClear_OnLeave_Return3	; F7ABBE  jr Z,0xf7abdb
	ld	wa, (3654:16)	; F7ABC0  ld WA,(0x0e46)
	xor	wa, 65535	; F7ABC4  xor WA,0xffff
	and	(0x360c:16), wa	; F7ABC8  and (0x360c),WA
	ld	(6304798:24), wa	; F7ABCC  ld (0x60341e),WA
	xor	xwa, xwa	; F7ABD1  xor XWA,XWA
	ld	(12304:16), xwa	; F7ABD3  ld (0x3010),XWA
	call	T_Seq_RequestRewind	; F7ABD7  call 0xf409e0
TrackClear_OnLeave_Return3:
	ret	; F7ABDB  ret

; --------------------------------------------------------------------------
; TrackClear_ReturnToStageZero
; Called from: T_TrackClear_ReturnToStageZero (x2)
; Touches: (0x0DBE) (0x2071) (0x2075) (0x207E) (0x212E) (0x215E)
; Evidence: thunk slot T_TrackClear_ReturnToStageZero holds `jp 0x00F7ABDC`, and 0xF7ABDC is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackClear_ReturnToStageZero: UI_ScreenStage = 0 and UI_Request_Hi |= 0x10 -- back to stage 0 of TrackClear_StageNonZero;
;   called by ExitKey_TrackClear_StageNonZero, LcdKeyRow3_TrackClear_StageNonZero (notes/prom_ab_stage_zero_names.py).
TrackClear_ReturnToStageZero:		; <- T_TrackClear_ReturnToStageZero
	and	(UI_RequestBits:16), 0xf6	; F7ABDC  and (0x2075),0xf6
	cp	(UI_ScreenStage:16), 0x01	; F7ABE1  cp (0x207e),0x01
	jr	z, TrackClear_ReturnToStageZero_Skip2	; F7ABE6  jr Z,0xf7abea
	jr	TrackClear_ReturnToStageZero_Return4	; F7ABE8  jr T,0xf7ac06
TrackClear_ReturnToStageZero_Skip2:
	ld	(UI_ScreenStage:16), 0	; F7ABEA  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7ABEF  or (0x2071),0x10
	ldw	(3518:16), 0	; F7ABF4  ld (0x0dbe),0x0000
	ldw	(8542:16), 0	; F7ABFA  ld (0x215e),0x0000
	orw	(0x212e:16), 0x0100	; F7AC00  or (0x212e),0x0100
TrackClear_ReturnToStageZero_Return4:
	ret	; F7AC06  ret

; --------------------------------------------------------------------------
; TrackClear_LcdKeyRow2
; Called from: T_TrackClear_LcdKeyRow2 (x2)
; Touches: (0x0C70) (0x0D4A) (0x0DBE) (0x0E46) (0x2070) (0x2071) (0x2075)
;          (0x207E) (0x212E) (0x215E) +2 more
; Calls:   T_SongEdit_ClearTrack_Call
; Evidence: thunk slot T_TrackClear_LcdKeyRow2 holds `jp 0x00F7AC07`, and 0xF7AC07 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackClear_LcdKeyRow2: the LcdKeyRow2 action of TrackClear_StageNonZero, TrackClear_StageZero -- called only by LcdKeyRow2_TrackClear_StageNonZero, LcdKeyRow2_TrackClear_StageZero.
TrackClear_LcdKeyRow2:		; <- T_TrackClear_LcdKeyRow2
	and	(UI_RequestBits:16), 0xf6	; F7AC07  and (0x2075),0xf6
	cp	(UI_ScreenStage:16), 0x01	; F7AC0C  cp (0x207e),0x01
	jr	z, TrackClear_LcdKeyRow2_Skip3	; F7AC11  jr Z,0xf7ac1e
	ld	(UI_ScreenStage:16), 1	; F7AC13  ld (0x207e),0x01
	or	(UI_Request_Hi:16), 0x10	; F7AC18  or (0x2071),0x10
	ret	; F7AC1D  ret
TrackClear_LcdKeyRow2_Skip3:
	cpw	(0x0dbe:16), 0x0000	; F7AC1E  cp (0x0dbe),0x0000
	jr	nz, TrackClear_LcdKeyRow2_Skip4	; F7AC24  jr NZ,0xf7ac32
	ld	(UI_ScreenStage:16), 0	; F7AC26  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7AC2B  or (0x2071),0x10
	jr	sub_F7AB3F_Return5	; F7AC30  jr T,0xf7ac9c
TrackClear_LcdKeyRow2_Skip4:
	xor	c, c	; F7AC32  xor C,C
	ld	hl, (3518:16)	; F7AC34  ld HL,(0x0dbe)
sub_F7AB3F_Entry:
	ldfr_werp	hl, 0x3e	; F7AC38  ld QHL3,HL
	ld	a, c	; F7AC3B  ld A,C
	scf	; F7AC3D  scf
	xorcfw_erp	0x3e	; F7AC3E  xorcf A,QHL3
	jr	c, sub_F7AB3F_Skip5	; F7AC41  jr C,0xf7ac5d
	ld	a, c	; F7AC43  ld A,C
	inc	1, a	; F7AC45  inc 1,A
	ld	(3184:16), a	; F7AC47  ld (0x0c70),A
	pushw	bc	; F7AC4B  push BC
	pushw	hl	; F7AC4C  push HL
	ld	(UI_StatusCode:16), 255	; F7AC4D  ld (0x2880),0xff
	ld	(BStore_ErrorCode:16), 0	; F7AC52  ld (0x0d4a),0x00
	call	T_SongEdit_ClearTrack_Call	; F7AC57  call 0xf426e4
	popw	hl	; F7AC5B  pop HL
	popw	bc	; F7AC5C  pop BC
sub_F7AB3F_Skip5:
	inc	1, c	; F7AC5D  inc 1,C
	cp	c, 15	; F7AC5F  cp C,0x0f
	jr	ule, sub_F7AB3F_Entry	; F7AC62  jr ULE,0xf7ac38
	ld	bc, (3518:16)	; F7AC64  ld BC,(0x0dbe)
	ld	wa, (12304:16)	; F7AC68  ld WA,(0x3010)
	and	bc, wa	; F7AC6C  and BC,WA
	xor	(0x3010:16), bc	; F7AC6E  xor (0x3010),BC
	ld	wa, (3518:16)	; F7AC72  ld WA,(0x0dbe)
	ld	(3654:16), wa	; F7AC76  ld (0x0e46),WA
	ldw	(3518:16), 0	; F7AC7A  ld (0x0dbe),0x0000
	ldw	(8542:16), 0	; F7AC80  ld (0x215e),0x0000
	orw	(0x212e:16), 0x0100	; F7AC86  or (0x212e),0x0100
	ld	(UI_ScreenStage:16), 0	; F7AC8C  ld (0x207e),0x00
	ld	(UI_StatusCode:16), 35	; F7AC91  ld (0x2880),0x23
	ldw	(UI_Request:16), 16555	; F7AC96  ld (0x2070),0x40ab
sub_F7AB3F_Return5:
	ret	; F7AC9C  ret

; --------------------------------------------------------------------------
; TrackMerge_InitFields
; Called from: T_TrackMerge_InitFields (x1)
; Touches: (0x0DBA)
; Calls:   TrackMerge_LoadSavedFields
; Evidence: thunk slot T_TrackMerge_InitFields holds `jp 0x00F7AC9D`, and 0xF7AC9D is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_InitFields: Paint_TrackMerge's stage-0 init (slot T_TrackMerge_InitFields): TrackMerge_LoadSavedFields reloads the three fields
;   (0x0C13)/(0x0C14)/(0x0C15) and their display cells from the saved copies 0x603459..0x60345B, then the field cursor
;   (0x0DBA) := 1. Basis: caller + body + siblings (MeasureDelete_InitFields). (notes/naming-
;   pilot-2026-10-06/proposals_wave7_z.json)
TrackMerge_InitFields:		; <- T_TrackMerge_InitFields
	calr	TrackMerge_LoadSavedFields	; F7AC9D  calr 0xf7afd8
	ld	(3514:16), 1	; F7ACA0  ld (0x0dba),0x01
	ret	; F7ACA5  ret

; --------------------------------------------------------------------------
; TrackMerge_OnLeave
; Called from: T_TrackMerge_OnLeave (x1)
; Touches: (0x207A) (0x3010) (0x360C)
; Calls:   T_Seq_RequestRewind
; Evidence: thunk slot T_TrackMerge_OnLeave holds `jp 0x00F7ACA6`, and 0xF7ACA6 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_OnLeave: the LEAVE work of TrackMerge -- the one unnamed routine ScreenLeaveBody_TrackMerge calls, and nothing else calls it
;   (notes/prom_ab_screen_enter_leave_work.py).
TrackMerge_OnLeave:		; <- T_TrackMerge_OnLeave
	cp	(UI_ScreenLatch:16), 0x1f	; F7ACA6  cp (0x207a),0x1f
	jr	z, TrackMerge_OnLeave_Return6	; F7ACAB  jr Z,0xf7acc4
	ld	xwa, (12304:16)	; F7ACAD  ld XWA,(0x3010)
	or	(0x360c:16), xwa	; F7ACB1  or (0x360c),XWA
	ld	(6304798:24), xwa	; F7ACB5  ld (0x60341e),XWA
	xor	xwa, xwa	; F7ACBA  xor XWA,XWA
	ld	(12304:16), xwa	; F7ACBC  ld (0x3010),XWA
	call	T_Seq_RequestRewind	; F7ACC0  call 0xf409e0
TrackMerge_OnLeave_Return6:
	ret	; F7ACC4  ret

; --------------------------------------------------------------------------
; TrackMerge_SelectField1
; Called from: T_TrackMerge_SelectField1 (x1)
; Touches: (0x0DBA) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_TrackMerge_SelectField1 holds `jp 0x00F7ACC5`, and 0xF7ACC5 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 1 into (0x0DBA) and requests a redraw (UI_RequestBits);
;           (0x0DBA) is read by LcdKeyRow2/3/4_TrackMerge_StageZero, so it is the TrackMerge screen's field cell.
; Unknown: what field 1 is on that screen.
; --------------------------------------------------------------------------
TrackMerge_SelectField1:		; <- T_TrackMerge_SelectField1
	ld	(3514:16), 1	; F7ACC5  ld (0x0dba),0x01
	or	(UI_RequestBits:16), 0x09	; F7ACCA  or (0x2075),0x09
	ret	; F7ACCF  ret

; --------------------------------------------------------------------------
; TrackMerge_SelectField2
; Called from: T_TrackMerge_SelectField2 (x1)
; Touches: (0x0DBA) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_TrackMerge_SelectField2 holds `jp 0x00F7ACD0`, and 0xF7ACD0 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 2 into (0x0DBA) and requests a redraw (UI_RequestBits);
;           (0x0DBA) is read by LcdKeyRow2/3/4_TrackMerge_StageZero, so it is the TrackMerge screen's field cell.
; Unknown: what field 2 is on that screen.
; --------------------------------------------------------------------------
TrackMerge_SelectField2:		; <- T_TrackMerge_SelectField2
	ld	(3514:16), 2	; F7ACD0  ld (0x0dba),0x02
	or	(UI_RequestBits:16), 0x09	; F7ACD5  or (0x2075),0x09
	ret	; F7ACDA  ret

; --------------------------------------------------------------------------
; TrackMerge_SelectField3
; Called from: T_TrackMerge_SelectField3 (x1)
; Touches: (0x0DBA) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_TrackMerge_SelectField3 holds `jp 0x00F7ACDB`, and 0xF7ACDB is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 3 into (0x0DBA) and requests a redraw (UI_RequestBits);
;           (0x0DBA) is read by LcdKeyRow2/3/4_TrackMerge_StageZero, so it is the TrackMerge screen's field cell.
; Unknown: what field 3 is on that screen.
; --------------------------------------------------------------------------
TrackMerge_SelectField3:		; <- T_TrackMerge_SelectField3
	ld	(3514:16), 3	; F7ACDB  ld (0x0dba),0x03
	or	(UI_RequestBits:16), 0x09	; F7ACE0  or (0x2075),0x09
	ret	; F7ACE5  ret

; --------------------------------------------------------------------------
; TrackMerge_StepSelectedFieldUp
; Called from: T_TrackMerge_StepSelectedFieldUp (x1)
; Touches: (0x0C4E) (0x0C4F) (0x0DBA)
; Calls:   TrackMerge_StepSourceTrack1 TrackMerge_StepSourceTrack2 TrackMerge_StepDestTrack
; Evidence: thunk slot T_TrackMerge_StepSelectedFieldUp holds `jp 0x00F7ACE6`, and 0xF7ACE6 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_StepSelectedFieldUp: (0x0C4E) := key code W, (0x0C4F) := W & 0x80, then the stepper for TRACK MERGE field
;   (0x0DBA): 1 TrackMerge_StepSourceTrack1, 2 TrackMerge_StepSourceTrack2, 3 TrackMerge_StepDestTrack.
;   SoftKeyCol5_TrackMerge_StageZero calls it for the UPPER switch (W bit 7 clear, so the steppers add); the lower one
;   calls the identical TrackMerge_StageZero_SoftKeyCol5. Basis: caller + body + sibling
;   (N0teChange_StepSelectedFieldUp). (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
TrackMerge_StepSelectedFieldUp:		; <- T_TrackMerge_StepSelectedFieldUp
	ld	(3150:16), w	; F7ACE6  ld (0x0c4e),W
	and	w, 128	; F7ACEA  and W,0x80
	ld	(3151:16), w	; F7ACED  ld (0x0c4f),W
	cp	(0x0dba:16), 0x01	; F7ACF1  cp (0x0dba),0x01
	jr	nz, TrackMerge_StepSelectedFieldUp_Skip6	; F7ACF6  jr NZ,0xf7acfd
	calr	TrackMerge_StepSourceTrack1	; F7ACF8  calr 0xf7ad42
	jr	TrackMerge_StepSelectedFieldUp_Return7	; F7ACFB  jr T,0xf7ad13
TrackMerge_StepSelectedFieldUp_Skip6:
	cp	(0x0dba:16), 0x02	; F7ACFD  cp (0x0dba),0x02
	jr	nz, TrackMerge_StepSelectedFieldUp_Skip7	; F7AD02  jr NZ,0xf7ad09
	calr	TrackMerge_StepSourceTrack2	; F7AD04  calr 0xf7ad8f
	jr	TrackMerge_StepSelectedFieldUp_Return7	; F7AD07  jr T,0xf7ad13
TrackMerge_StepSelectedFieldUp_Skip7:
	cp	(0x0dba:16), 0x03	; F7AD09  cp (0x0dba),0x03
	jr	nz, TrackMerge_StepSelectedFieldUp_Return7	; F7AD0E  jr NZ,0xf7ad13
	calr	TrackMerge_StepDestTrack	; F7AD10  calr 0xf7addc
TrackMerge_StepSelectedFieldUp_Return7:
	ret	; F7AD13  ret

; --------------------------------------------------------------------------
; TrackMerge_StageZero_SoftKeyCol5
; Called from: T_TrackMerge_StageZero_SoftKeyCol5 (x1)
; Touches: (0x0C4E) (0x0C4F) (0x0DBA)
; Calls:   TrackMerge_StepSourceTrack1 TrackMerge_StepSourceTrack2 TrackMerge_StepDestTrack
; Evidence: thunk slot T_TrackMerge_StageZero_SoftKeyCol5 holds `jp 0x00F7AD14`, and 0xF7AD14 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_StageZero_SoftKeyCol5: the SoftKeyCol5 action of TrackMerge_StageZero -- called only by SoftKeyCol5_TrackMerge_StageZero.
TrackMerge_StageZero_SoftKeyCol5:		; <- T_TrackMerge_StageZero_SoftKeyCol5
	ld	(3150:16), w	; F7AD14  ld (0x0c4e),W
	and	w, 128	; F7AD18  and W,0x80
	ld	(3151:16), w	; F7AD1B  ld (0x0c4f),W
	cp	(0x0dba:16), 0x01	; F7AD1F  cp (0x0dba),0x01
	jr	nz, TrackMerge_StageZero_SoftKeyCol5_Skip8	; F7AD24  jr NZ,0xf7ad2b
	calr	TrackMerge_StepSourceTrack1	; F7AD26  calr 0xf7ad42
	jr	TrackMerge_StageZero_SoftKeyCol5_Return8	; F7AD29  jr T,0xf7ad41
TrackMerge_StageZero_SoftKeyCol5_Skip8:
	cp	(0x0dba:16), 0x02	; F7AD2B  cp (0x0dba),0x02
	jr	nz, TrackMerge_StageZero_SoftKeyCol5_Skip9	; F7AD30  jr NZ,0xf7ad37
	calr	TrackMerge_StepSourceTrack2	; F7AD32  calr 0xf7ad8f
	jr	TrackMerge_StageZero_SoftKeyCol5_Return8	; F7AD35  jr T,0xf7ad41
TrackMerge_StageZero_SoftKeyCol5_Skip9:
	cp	(0x0dba:16), 0x03	; F7AD37  cp (0x0dba),0x03
	jr	nz, TrackMerge_StageZero_SoftKeyCol5_Return8	; F7AD3C  jr NZ,0xf7ad41
	calr	TrackMerge_StepDestTrack	; F7AD3E  calr 0xf7addc
TrackMerge_StageZero_SoftKeyCol5_Return8:
	ret	; F7AD41  ret

; --------------------------------------------------------------------------
; TrackMerge_StepSourceTrack1
; Called from: in-module: 0xF7ACF8 0xF7AD26
; Touches: (0x0C13) (0x0C14) (0x0C4F) (0x12F6) (0x2075)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7AD42 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_StepSourceTrack1: Steps TRACK MERGE's first source track (0x0C13) by 1 in direction (0x0C4F) (0x80 =
;   down) over 1..16 with wrap-around, skipping the second source (0x0C14); stores it to (0x0C13), the saved copy
;   0x603459 and DisplayListB_Stage. Field 1 of TrackMerge_StepSelectedFieldUp / TrackMerge_StageZero_SoftKeyCol5;
;   TrackMerge_LcdKeyRow2 passes (0x0C13) to TrackMerge_Execute as source (0x0C70). Basis: callers + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
TrackMerge_StepSourceTrack1:
	or	(UI_RequestBits:16), 0x09	; F7AD42  or (0x2075),0x09
	ld	a, (3091:16)	; F7AD47  ld A,(0x0c13)
	cp	(0x0c4f:16), 0x80	; F7AD4B  cp (0x0c4f),0x80
	jr	z, TrackMerge_StepSourceTrack1_Loop2	; F7AD50  jr Z,0xf7ad6b
TrackMerge_StepSourceTrack1_Loop:
	inc	1, a	; F7AD52  inc 1,A
	cp	a, 16	; F7AD54  cp A,0x10
	jr	ule, TrackMerge_StepSourceTrack1_Skip	; F7AD57  jr ULE,0xf7ad63
	ld	a, 1:opc	; F7AD59  ld A,0x01
	cp	a, (0x0c14:16)	; F7AD5B  cp A,(0x0c14)
	jr	nz, TrackMerge_StepSourceTrack1_Join	; F7AD5F  jr NZ,0xf7ad81
	jr	TrackMerge_StepSourceTrack1_Loop	; F7AD61  jr T,0xf7ad52
TrackMerge_StepSourceTrack1_Skip:
	cp	a, (0x0c14:16)	; F7AD63  cp A,(0x0c14)
	jr	z, TrackMerge_StepSourceTrack1_Loop	; F7AD67  jr Z,0xf7ad52
	jr	TrackMerge_StepSourceTrack1_Join	; F7AD69  jr T,0xf7ad81
TrackMerge_StepSourceTrack1_Loop2:
	dec	1, a	; F7AD6B  dec 1,A
	cp	a, 0:i3	; F7AD6D  cp A,0
	jr	ugt, TrackMerge_StepSourceTrack1_Skip2	; F7AD6F  jr UGT,0xf7ad7b
	ld	a, 16:opc	; F7AD71  ld A,0x10
	cp	a, (0x0c14:16)	; F7AD73  cp A,(0x0c14)
	jr	nz, TrackMerge_StepSourceTrack1_Join	; F7AD77  jr NZ,0xf7ad81
	jr	TrackMerge_StepSourceTrack1_Loop2	; F7AD79  jr T,0xf7ad6b
TrackMerge_StepSourceTrack1_Skip2:
	cp	a, (0x0c14:16)	; F7AD7B  cp A,(0x0c14)
	jr	z, TrackMerge_StepSourceTrack1_Loop2	; F7AD7F  jr Z,0xf7ad6b
TrackMerge_StepSourceTrack1_Join:
	ld	(3091:16), a	; F7AD81  ld (0x0c13),A
	ld	(6304857:24), a	; F7AD85  ld (0x603459),A
	ld	(DisplayListB_Stage:16), a	; F7AD8A  ld (0x12f6),A
	ret	; F7AD8E  ret

; --------------------------------------------------------------------------
; TrackMerge_StepSourceTrack2
; Called from: in-module: 0xF7AD04 0xF7AD32
; Touches: (0x0C13) (0x0C14) (0x0C4F) (0x12F7) (0x2075)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7AD8F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_StepSourceTrack2: Steps TRACK MERGE's second source track (0x0C14) by 1 in direction (0x0C4F) over 1..16
;   with wrap-around, skipping the first source (0x0C13); stores it to (0x0C14), the saved copy 0x60345A and
;   DisplayListB_Stage+1. Field 2 of TrackMerge_StepSelectedFieldUp / TrackMerge_StageZero_SoftKeyCol5;
;   TrackMerge_LcdKeyRow2 passes it as source (0x0C71). Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_z.json)
TrackMerge_StepSourceTrack2:
	or	(UI_RequestBits:16), 0x09	; F7AD8F  or (0x2075),0x09
	ld	a, (3092:16)	; F7AD94  ld A,(0x0c14)
	cp	(0x0c4f:16), 0x80	; F7AD98  cp (0x0c4f),0x80
	jr	z, TrackMerge_StepSourceTrack2_Loop2	; F7AD9D  jr Z,0xf7adb8
TrackMerge_StepSourceTrack2_Loop:
	inc	1, a	; F7AD9F  inc 1,A
	cp	a, 16	; F7ADA1  cp A,0x10
	jr	ule, TrackMerge_StepSourceTrack2_Skip	; F7ADA4  jr ULE,0xf7adb0
	ld	a, 1:opc	; F7ADA6  ld A,0x01
	cp	a, (0x0c13:16)	; F7ADA8  cp A,(0x0c13)
	jr	nz, TrackMerge_StepSourceTrack2_Join	; F7ADAC  jr NZ,0xf7adce
	jr	TrackMerge_StepSourceTrack2_Loop	; F7ADAE  jr T,0xf7ad9f
TrackMerge_StepSourceTrack2_Skip:
	cp	a, (0x0c13:16)	; F7ADB0  cp A,(0x0c13)
	jr	z, TrackMerge_StepSourceTrack2_Loop	; F7ADB4  jr Z,0xf7ad9f
	jr	TrackMerge_StepSourceTrack2_Join	; F7ADB6  jr T,0xf7adce
TrackMerge_StepSourceTrack2_Loop2:
	dec	1, a	; F7ADB8  dec 1,A
	cp	a, 0:i3	; F7ADBA  cp A,0
	jr	ugt, TrackMerge_StepSourceTrack2_Skip2	; F7ADBC  jr UGT,0xf7adc8
	ld	a, 16:opc	; F7ADBE  ld A,0x10
	cp	a, (0x0c13:16)	; F7ADC0  cp A,(0x0c13)
	jr	nz, TrackMerge_StepSourceTrack2_Join	; F7ADC4  jr NZ,0xf7adce
	jr	TrackMerge_StepSourceTrack2_Loop2	; F7ADC6  jr T,0xf7adb8
TrackMerge_StepSourceTrack2_Skip2:
	cp	a, (0x0c13:16)	; F7ADC8  cp A,(0x0c13)
	jr	z, TrackMerge_StepSourceTrack2_Loop2	; F7ADCC  jr Z,0xf7adb8
TrackMerge_StepSourceTrack2_Join:
	ld	(3092:16), a	; F7ADCE  ld (0x0c14),A
	ld	(6304858:24), a	; F7ADD2  ld (0x60345a),A
	ld	(DisplayListB_Stage+1:16), a	; F7ADD7  ld (0x12f7),A
	ret	; F7ADDB  ret

; --------------------------------------------------------------------------
; TrackMerge_StepDestTrack
; Called from: in-module: 0xF7AD10 0xF7AD3E
; Touches: (0x0C15) (0x12F8)
; Calls:   SeqJob_StepValueInRange
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7ADDC is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_StepDestTrack: Steps TRACK MERGE's destination track (0x0C15) with SeqJob_StepValueInRange over 1..16
;   (clamped, no wrap); stores it to (0x0C15), the saved copy 0x60345B and DisplayListB_Stage+2. Field 3 of
;   TrackMerge_StepSelectedFieldUp / TrackMerge_StageZero_SoftKeyCol5; TrackMerge_LcdKeyRow2 passes it as the
;   destination (0x0C72). Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
TrackMerge_StepDestTrack:
	ld	a, (3093:16)	; F7ADDC  ld A,(0x0c15)
	ld	l, 1:opc	; F7ADE0  ld L,0x01
	ld	h, 16:opc	; F7ADE2  ld H,0x10
	calr	SeqJob_StepValueInRange	; F7ADE4  calr 0xf7ccdb
	ld	(3093:16), a	; F7ADE7  ld (0x0c15),A
	ld	(6304859:24), a	; F7ADEB  ld (0x60345b),A
	ld	(DisplayListB_Stage+2:16), a	; F7ADF0  ld (0x12f8),A
	ret	; F7ADF4  ret

; --------------------------------------------------------------------------
; TrackMerge_ReturnToStageZero
; Called from: T_TrackMerge_ReturnToStageZero (x2)
; Touches: (0x2071) (0x2075) (0x207E)
; Evidence: thunk slot T_TrackMerge_ReturnToStageZero holds `jp 0x00F7ADF5`, and 0xF7ADF5 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_ReturnToStageZero: UI_ScreenStage = 0 and UI_Request_Hi |= 0x10 -- back to stage 0 of TrackMerge_StageNonZero;
;   called by ExitKey_TrackMerge_StageNonZero, LcdKeyRow4_TrackMerge_StageNonZero (notes/prom_ab_stage_zero_names.py).
TrackMerge_ReturnToStageZero:		; <- T_TrackMerge_ReturnToStageZero
	cp	(UI_ScreenStage:16), 0x01	; F7ADF5  cp (0x207e),0x01
	jr	nz, TrackMerge_ReturnToStageZero_Return	; F7ADFA  jr NZ,0xf7ae0b
	and	(UI_RequestBits:16), 0xf6	; F7ADFC  and (0x2075),0xf6
	ld	(UI_ScreenStage:16), 0	; F7AE01  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7AE06  or (0x2071),0x10
TrackMerge_ReturnToStageZero_Return:
	ret	; F7AE0B  ret

; --------------------------------------------------------------------------
; TrackMerge_LcdKeyRow2
; Called from: T_TrackMerge_LcdKeyRow2 (x2)
; Touches: (0x0C13) (0x0C14) (0x0C15) (0x0C70) (0x0C71) (0x0C72) (0x0D4A)
;          (0x2070) (0x2071) (0x2075) +5 more
; Calls:   T_TrackMerge_Execute
; Evidence: thunk slot T_TrackMerge_LcdKeyRow2 holds `jp 0x00F7AE0C`, and 0xF7AE0C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_LcdKeyRow2: the LcdKeyRow2 action of TrackMerge_StageNonZero, TrackMerge_StageZero -- called only by LcdKeyRow2_TrackMerge_StageNonZero, LcdKeyRow2_TrackMerge_StageZero.
TrackMerge_LcdKeyRow2:		; <- T_TrackMerge_LcdKeyRow2
	and	(UI_RequestBits:16), 0xf6	; F7AE0C  and (0x2075),0xf6
	cp	(UI_ScreenStage:16), 0x01	; F7AE11  cp (0x207e),0x01
	jr	z, TrackMerge_LcdKeyRow2_Skip	; F7AE16  jr Z,0xf7ae25
	ld	(UI_ScreenStage:16), 1	; F7AE18  ld (0x207e),0x01
	or	(UI_Request_Hi:16), 0x10	; F7AE1D  or (0x2071),0x10
	jrl	sub_F7ADDC_Return2	; F7AE22  jrl T,0xf7af59
TrackMerge_LcdKeyRow2_Skip:
	ld	a, (3091:16)	; F7AE25  ld A,(0x0c13)
	ld	(3184:16), a	; F7AE29  ld (0x0c70),A
	ld	a, (3092:16)	; F7AE2D  ld A,(0x0c14)
	ld	(3185:16), a	; F7AE31  ld (0x0c71),A
	ld	a, (3093:16)	; F7AE35  ld A,(0x0c15)
	ld	(3186:16), a	; F7AE39  ld (0x0c72),A
	ld	(UI_StatusCode:16), 255	; F7AE3D  ld (0x2880),0xff
	ld	(BStore_ErrorCode:16), 0	; F7AE42  ld (0x0d4a),0x00
	call	T_TrackMerge_Execute	; F7AE47  call 0xf426e8
	cp	(UI_StatusCode:16), 0xff	; F7AE4B  cp (0x2880),0xff
	jrl	z, sub_F7ADDC_Skip8	; F7AE50  jrl Z,0xf7af4f
	ldw	(UI_Request:16), 16555	; F7AE53  ld (0x2070),0x40ab
	ld	(UI_ScreenStage:16), 0	; F7AE59  ld (0x207e),0x00
	cp	(UI_StatusCode:16), 0x23	; F7AE5E  cp (0x2880),0x23
	jrl	nz, sub_F7ADDC_Return2	; F7AE63  jrl NZ,0xf7af59
	ld	c, (3184:16)	; F7AE66  ld C,(0x0c70)
	dec	1, c	; F7AE6A  dec 1,C
	ldfr_berp	a, 0x3c	; F7AE6C  ld RL3,A
	ldfr_werp	de, 0x3e	; F7AE6F  ld QHL3,DE
	ld	de, (12304:16)	; F7AE72  ld DE,(0x3010)
	ld	a, c	; F7AE76  ld A,C
	cp	a, 16	; F7AE78  cp A,0x10
	jr	lt, TrackMerge_LcdKeyRow2_Skip2	; F7AE7B  jr LT,0xf7ae84
	ld	de, (12306:16)	; F7AE7D  ld DE,(0x3012)
	sub	a, 16	; F7AE81  sub A,0x10
TrackMerge_LcdKeyRow2_Skip2:
	rcf	; F7AE84  rcf
	stcf_a_16	de	; F7AE85  stcf A,DE
	ldto_berp	a, 0x3c	; F7AE87  ld A,RL3
	cp	c, 16	; F7AE8A  cp C,0x10
	jr	lt, TrackMerge_LcdKeyRow2_Skip3	; F7AE8D  jr LT,0xf7ae95
	ld	(12306:16), de	; F7AE8F  ld (0x3012),DE
	jr	sub_F7ADDC_Entry	; F7AE93  jr T,0xf7ae99
TrackMerge_LcdKeyRow2_Skip3:
	ld	(12304:16), de	; F7AE95  ld (0x3010),DE
sub_F7ADDC_Entry:
	ldto_werp	de, 0x3e	; F7AE99  ld DE,QHL3
	xor	b, b	; F7AE9C  xor B,B
	ld	xix, SongStore_BitMask32	; F7AE9E  ld XIX,0x00f7af5a
	sla	c, 2	; F7AEA3  sla 0x02,C
	ld	xwa, (xix+bc)	; F7AEA6  ld XWA,(XIX+BC)
	xor	xwa, 4294967295	; F7AEAB  xor XWA,0xffffffff
	and	(0x360c:16), xwa	; F7AEB1  and (0x360c),XWA
	ld	c, (3185:16)	; F7AEB5  ld C,(0x0c71)
	dec	1, c	; F7AEB9  dec 1,C
	ldfr_berp	a, 0x3c	; F7AEBB  ld RL3,A
	ldfr_werp	de, 0x3e	; F7AEBE  ld QHL3,DE
	ld	de, (12304:16)	; F7AEC1  ld DE,(0x3010)
	ld	a, c	; F7AEC5  ld A,C
	cp	a, 16	; F7AEC7  cp A,0x10
	jr	lt, sub_F7ADDC_Skip4	; F7AECA  jr LT,0xf7aed3
	ld	de, (12306:16)	; F7AECC  ld DE,(0x3012)
	sub	a, 16	; F7AED0  sub A,0x10
sub_F7ADDC_Skip4:
	rcf	; F7AED3  rcf
	stcf_a_16	de	; F7AED4  stcf A,DE
	ldto_berp	a, 0x3c	; F7AED6  ld A,RL3
	cp	c, 16	; F7AED9  cp C,0x10
	jr	lt, sub_F7ADDC_Skip5	; F7AEDC  jr LT,0xf7aee4
	ld	(12306:16), de	; F7AEDE  ld (0x3012),DE
	jr	sub_F7ADDC_Entry2	; F7AEE2  jr T,0xf7aee8
sub_F7ADDC_Skip5:
	ld	(12304:16), de	; F7AEE4  ld (0x3010),DE
sub_F7ADDC_Entry2:
	ldto_werp	de, 0x3e	; F7AEE8  ld DE,QHL3
	xor	b, b	; F7AEEB  xor B,B
	ld	xix, SongStore_BitMask32	; F7AEED  ld XIX,0x00f7af5a
	sla	c, 2	; F7AEF2  sla 0x02,C
	ld	xwa, (xix+bc)	; F7AEF5  ld XWA,(XIX+BC)
	xor	xwa, 4294967295	; F7AEFA  xor XWA,0xffffffff
	and	(0x360c:16), xwa	; F7AF00  and (0x360c),XWA
	ld	c, (3186:16)	; F7AF04  ld C,(0x0c72)
	dec	1, c	; F7AF08  dec 1,C
	ldfr_berp	a, 0x3c	; F7AF0A  ld RL3,A
	ldfr_werp	de, 0x3e	; F7AF0D  ld QHL3,DE
	ld	de, (12304:16)	; F7AF10  ld DE,(0x3010)
	ld	a, c	; F7AF14  ld A,C
	cp	a, 16	; F7AF16  cp A,0x10
	jr	lt, sub_F7ADDC_Skip6	; F7AF19  jr LT,0xf7af22
	ld	de, (12306:16)	; F7AF1B  ld DE,(0x3012)
	sub	a, 16	; F7AF1F  sub A,0x10
sub_F7ADDC_Skip6:
	scf	; F7AF22  scf
	stcf_a_16	de	; F7AF23  stcf A,DE
	ldto_berp	a, 0x3c	; F7AF25  ld A,RL3
	cp	c, 16	; F7AF28  cp C,0x10
	jr	lt, sub_F7ADDC_Skip7	; F7AF2B  jr LT,0xf7af33
	ld	(12306:16), de	; F7AF2D  ld (0x3012),DE
	jr	sub_F7ADDC_Entry3	; F7AF31  jr T,0xf7af37
sub_F7ADDC_Skip7:
	ld	(12304:16), de	; F7AF33  ld (0x3010),DE
sub_F7ADDC_Entry3:
	ldto_werp	de, 0x3e	; F7AF37  ld DE,QHL3
	xor	b, b	; F7AF3A  xor B,B
	ld	xix, SongStore_BitMask32	; F7AF3C  ld XIX,0x00f7af5a
	sla	c, 2	; F7AF41  sla 0x02,C
	ld	xwa, (xix+bc)	; F7AF44  ld XWA,(XIX+BC)
	or	(0x360c:16), xwa	; F7AF49  or (0x360c),XWA
	jr	sub_F7ADDC_Return2	; F7AF4D  jr T,0xf7af59
sub_F7ADDC_Skip8:
	ld	(UI_ScreenStage:16), 0	; F7AF4F  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7AF54  or (0x2071),0x10
sub_F7ADDC_Return2:
	ret	; F7AF59  ret

; SongStore_BitMask32 -- 32-bit single-bit masks, and it is TWO BYTES SHORT
;
; Read by:  three sites, all in this module, all with the same four
;   instructions: `xor B,B / ld XIX,0x00F7AF5A / sla 0x02,C / ld XWA,(XIX+BC)`
;   at 0xF7AE9E, 0xF7AEED and 0xF7AF3C.  The value is then applied to the 32-bit
;   variable (0x360C) -- `xor XWA,0xFFFFFFFF / and (0x360C),XWA` at the first two
;   (clear bit C) and `or (0x360C),XWA` at the third (set bit C).
; Index:    C = (0x0C70)-1, (0x0C71)-1 and (0x0C72)-1 respectively.  The
;   surrounding code splits the same index across two 16-bit words with
;   `cp A,0x10 / sub A,0x10` (0xF7AE78, 0xF7AE81), reading (0x3010) below 16 and
;   (0x3012) at or above it -- i.e. the design's index range is 0..31.
; Layout:   4-byte little-endian entries, stride fixed by the `sla 0x02,C`.
; Extent:   126 bytes, 0xF7AF5A-0xF7AFD7.  0xF7AF59 is the `ret` that ends the
;   routine above and 0xF7AFD8 is `calr`ed from 0xF7AC9D, so both ends are
;   instructions.
;
;
; Evidence: the three `ld XIX,0x00F7AF5A` sites are a whole-image scan at every
;   byte offset, re-run on every emit -- it can only over-count, so three is an
;   upper bound that happens to be exact here (each one is followed by the same
;   `sla 0x02,C / ld XWA,(XIX+BC)` pair).  The malformation below is asserted as
;   a byte equality against a table this emitter constructs, so it cannot drift.
;
; ⚠ THE TABLE IS MALFORMED, AND THIS IS A MEASUREMENT, NOT A READING.
;   The 126 bytes are byte-for-byte the ideal table `1<<k` for k = 0..31, LE32,
;   with TWO 0x00 BYTES MISSING at byte offset 9 -- inside entry 2.  The emitter
;   asserts that equality on every run, so it cannot drift.  Consequences, as
;   arithmetic on the bytes:
;       index 0 -> 0x00000001   index 1 -> 0x00000002   (both correct)
;       index 2 -> 0x00080004   (not 4)
;       index 3 -> 0x00100000   ... every later entry is the ideal one shifted
;       index 31 -> starts at 0xF7AFD6, TWO BYTES PAST the island, so its top
;                   half is the first two bytes of the instruction at 0xF7AFD8
;   ⚠ What this lane has NOT established: whether C ever exceeds 1 at run time.
;   The `cp A,0x10 / sub A,0x10` split is evidence that 0..31 is intended, and
;   the three readers are reached from a code path that also writes (0x3010) and
;   (0x3012); none of that is a measurement of a live index.  Reported as a
;   defect in the DATA, with the run-time consequence left open.
SongStore_BitMask32:
	.byte	0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x04, 0x00, 0x08, 0x00, 0x00, 0x00, 0x10, 0x00	; F7AF5A
	.byte	0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x01	; F7AF6A
	.byte	0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x10	; F7AF7A
	.byte	0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00	; F7AF8A
	.byte	0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00	; F7AF9A
	.byte	0x10, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00	; F7AFAA
	.byte	0x00, 0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00	; F7AFBA
	.byte	0x00, 0x10, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x80	; F7AFCA


; --------------------------------------------------------------------------
; TrackMerge_LoadSavedFields
; Called from: in-module: 0xF7AC9D
; Touches: (0x0C13) (0x0C14) (0x0C15) (0x12F6) (0x12F7) (0x12F8)
; Evidence: the label is here because it is the target of `calr 0xf7afd8` at
;           0xF7AC9D -- and it is the first instruction after the
;           SongStore_BitMask32 island; the address is an instruction
;           boundary of this transcription (re-asserted on every emit)
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_LoadSavedFields: TRACK MERGE: copies the three saved track fields 0x603459..0x60345B (battery RAM) into
;   the working cells (0x0C13)/(0x0C14)/(0x0C15) and DisplayListB_Stage+0..+2. TrackMerge_InitFields calls it before
;   setting the field cursor (0x0DBA) := 1, as MeasureDelete_InitFields calls MeasureDelete_LoadSavedFields. Basis:
;   caller + body + siblings. (notes/naming-pilot-2026-10-06/proposals_wave8_b8.json)
TrackMerge_LoadSavedFields:
	ld	a, (6304857:24)	; F7AFD8  ld A,(0x603459)
	ld	(3091:16), a	; F7AFDD  ld (0x0c13),A
	ld	(DisplayListB_Stage:16), a	; F7AFE1  ld (0x12f6),A
	ld	a, (6304858:24)	; F7AFE5  ld A,(0x60345a)
	ld	(3092:16), a	; F7AFEA  ld (0x0c14),A
	ld	(DisplayListB_Stage+1:16), a	; F7AFEE  ld (0x12f7),A
	ld	a, (6304859:24)	; F7AFF2  ld A,(0x60345b)
	ld	(3093:16), a	; F7AFF7  ld (0x0c15),A
	ld	(DisplayListB_Stage+2:16), a	; F7AFFB  ld (0x12f8),A
	ret	; F7AFFF  ret

; --------------------------------------------------------------------------
; MeasureDelete_InitFields
; Called from: T_MeasureDelete_InitFields (x1)
; Touches: (0x0DD4) (0x12FB)
; Calls:   MeasureDelete_LoadSavedFields
; Evidence: thunk slot T_MeasureDelete_InitFields holds `jp 0x00F7B000`, and 0xF7B000 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureDelete_InitFields: Paint_MeasureDelete's stage-0 init: MeasureDelete_LoadSavedFields, field cursor (0x0DD4) = 1 (notes/prom_b_seqjob_field_names.py)
MeasureDelete_InitFields:		; <- T_MeasureDelete_InitFields
	calr	MeasureDelete_LoadSavedFields	; F7B000  calr 0xf7b1d1
	ld	(3540:16), 1	; F7B003  ld (0x0dd4),0x01
	ld	(DisplayListB_Stage+5:16), 1	; F7B008  ld (0x12fb),0x01
	ret	; F7B00D  ret

; --------------------------------------------------------------------------
; MeasureDelete_OnLeave
; Called from: T_MeasureDelete_OnLeave (x1)
; Touches: (0x207A)
; Calls:   T_Seq_RequestRewind
; Evidence: thunk slot T_MeasureDelete_OnLeave holds `jp 0x00F7B00E`, and 0xF7B00E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureDelete_OnLeave: the LEAVE work of MeasureDelete -- the one unnamed routine ScreenLeaveBody_MeasureDelete calls, and nothing else calls it
;   (notes/prom_ab_screen_enter_leave_work.py).
MeasureDelete_OnLeave:		; <- T_MeasureDelete_OnLeave
	cp	(UI_ScreenLatch:16), 0x23	; F7B00E  cp (0x207a),0x23
	jr	z, MeasureDelete_OnLeave_Return	; F7B013  jr Z,0xf7b019
	call	T_Seq_RequestRewind	; F7B015  call 0xf409e0
MeasureDelete_OnLeave_Return:
	ret	; F7B019  ret

; --------------------------------------------------------------------------
; MeasureDelete_SelectField1
; Called from: T_MeasureDelete_SelectField1 (x1)
; Touches: (0x0DD4) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_MeasureDelete_SelectField1 holds `jp 0x00F7B01A`, and 0xF7B01A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 1 into (0x0DD4) and requests a redraw (UI_RequestBits);
;           (0x0DD4) is read by LcdKeyRow2/3/4_MeasureDelete_StageZero, so it is the MeasureDelete screen's field cell.
; Unknown: what field 1 is on that screen.
; --------------------------------------------------------------------------
MeasureDelete_SelectField1:		; <- T_MeasureDelete_SelectField1
	ld	(3540:16), 1	; F7B01A  ld (0x0dd4),0x01
	or	(UI_RequestBits:16), 0x09	; F7B01F  or (0x2075),0x09
	ret	; F7B024  ret

; --------------------------------------------------------------------------
; MeasureDelete_SelectField2
; Called from: T_MeasureDelete_SelectField2 (x1)
; Touches: (0x0DD4) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_MeasureDelete_SelectField2 holds `jp 0x00F7B025`, and 0xF7B025 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 2 into (0x0DD4) and requests a redraw (UI_RequestBits);
;           (0x0DD4) is read by LcdKeyRow2/3/4_MeasureDelete_StageZero, so it is the MeasureDelete screen's field cell.
; Unknown: what field 2 is on that screen.
; --------------------------------------------------------------------------
MeasureDelete_SelectField2:		; <- T_MeasureDelete_SelectField2
	ld	(3540:16), 2	; F7B025  ld (0x0dd4),0x02
	or	(UI_RequestBits:16), 0x08	; F7B02A  or (0x2075),0x08
	or	(UI_RequestBits:16), 0x01	; F7B02F  or (0x2075),0x01
	ret	; F7B034  ret

; --------------------------------------------------------------------------
; MeasureDelete_SelectField3
; Called from: T_MeasureDelete_SelectField3 (x1)
; Touches: (0x0DD4) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_MeasureDelete_SelectField3 holds `jp 0x00F7B035`, and 0xF7B035 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 3 into (0x0DD4) and requests a redraw (UI_RequestBits);
;           (0x0DD4) is read by LcdKeyRow2/3/4_MeasureDelete_StageZero, so it is the MeasureDelete screen's field cell.
; Unknown: what field 3 is on that screen.
; --------------------------------------------------------------------------
MeasureDelete_SelectField3:		; <- T_MeasureDelete_SelectField3
	ld	(3540:16), 3	; F7B035  ld (0x0dd4),0x03
	or	(UI_RequestBits:16), 0x08	; F7B03A  or (0x2075),0x08
	or	(UI_RequestBits:16), 0x01	; F7B03F  or (0x2075),0x01
	ret	; F7B044  ret

; --------------------------------------------------------------------------
; MeasureDelete_StepFieldUp
; Called from: T_MeasureDelete_StepFieldUp (x4)
; Touches: (0x0C4E) (0x0C4F) (0x0DD4) (0x207E)
; Calls:   MeasureDelete_StepTrack MeasureDelete_StepFirstMeasure MeasureDelete_StepLastMeasure
; Evidence: thunk slot T_MeasureDelete_StepFieldUp holds `jp 0x00F7B045`, and 0xF7B045 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureDelete_StepFieldUp: at stage 1 leaves through MeasureDelete_ReturnToStageZero; else (0x0C4E) = W, (0x0C4F) = 0 (up) and
;   steps field (0x0DD4) (notes/prom_b_seqjob_field_names.py)
MeasureDelete_StepFieldUp:		; <- T_MeasureDelete_StepFieldUp
	cp	(UI_ScreenStage:16), 0x01	; F7B045  cp (0x207e),0x01
	jr	nz, MeasureDelete_StepFieldUp_Skip	; F7B04A  jr NZ,0xf7b04e
	jr	MeasureDelete_ReturnToStageZero	; F7B04C  jr T,0xf7b07a
MeasureDelete_StepFieldUp_Skip:
	ld	(3150:16), w	; F7B04E  ld (0x0c4e),W
	ld	(3151:16), 0	; F7B052  ld (0x0c4f),0x00
	cp	(0x0dd4:16), 0x01	; F7B057  cp (0x0dd4),0x01
	jr	nz, MeasureDelete_StepFieldUp_Skip2	; F7B05C  jr NZ,0xf7b063
	calr	MeasureDelete_StepTrack	; F7B05E  calr 0xf7b0b7
	jr	MeasureDelete_StepFieldUp_Return2	; F7B061  jr T,0xf7b079
MeasureDelete_StepFieldUp_Skip2:
	cp	(0x0dd4:16), 0x02	; F7B063  cp (0x0dd4),0x02
	jr	nz, MeasureDelete_StepFieldUp_Skip3	; F7B068  jr NZ,0xf7b06f
	calr	MeasureDelete_StepFirstMeasure	; F7B06A  calr 0xf7b0f2
	jr	MeasureDelete_StepFieldUp_Return2	; F7B06D  jr T,0xf7b079
MeasureDelete_StepFieldUp_Skip3:
	cp	(0x0dd4:16), 0x03	; F7B06F  cp (0x0dd4),0x03
	jr	nz, MeasureDelete_StepFieldUp_Return2	; F7B074  jr NZ,0xf7b079
	calr	MeasureDelete_StepLastMeasure	; F7B076  calr 0xf7b128
MeasureDelete_StepFieldUp_Return2:
	ret	; F7B079  ret

; --------------------------------------------------------------------------
; MeasureDelete_ReturnToStageZero
; Called from: T_MeasureDelete_ReturnToStageZero (x0)
; Touches: (0x2071) (0x2075) (0x207E)
; Evidence: thunk slot T_MeasureDelete_ReturnToStageZero holds `jp 0x00F7B07A`, and 0xF7B07A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureDelete_ReturnToStageZero: UI_ScreenStage = 0, UI_Request_Hi |= 0x10 (notes/prom_b_seqjob_field_names.py)
MeasureDelete_ReturnToStageZero:		; <- T_MeasureDelete_ReturnToStageZero
	and	(UI_RequestBits:16), 0xf6	; F7B07A  and (0x2075),0xf6
	ld	(UI_ScreenStage:16), 0	; F7B07F  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7B084  or (0x2071),0x10
	jr	MeasureDelete_StepFieldUp_Return2	; F7B089  jr T,0xf7b079

; --------------------------------------------------------------------------
; MeasureDelete_StepFieldDown
; Called from: T_MeasureDelete_StepFieldDown (x2)
; Touches: (0x0C4E) (0x0C4F) (0x0DD4)
; Calls:   MeasureDelete_StepTrack MeasureDelete_StepFirstMeasure MeasureDelete_StepLastMeasure
; Evidence: thunk slot T_MeasureDelete_StepFieldDown holds `jp 0x00F7B08B`, and 0xF7B08B is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureDelete_StepFieldDown: (0x0C4E) = W, (0x0C4F) = 0x80 (down), steps field (0x0DD4) (notes/prom_b_seqjob_field_names.py)
MeasureDelete_StepFieldDown:		; <- T_MeasureDelete_StepFieldDown
	ld	(3150:16), w	; F7B08B  ld (0x0c4e),W
	ld	(3151:16), 128	; F7B08F  ld (0x0c4f),0x80
	cp	(0x0dd4:16), 0x01	; F7B094  cp (0x0dd4),0x01
	jr	nz, MeasureDelete_StepFieldDown_Skip4	; F7B099  jr NZ,0xf7b0a0
	calr	MeasureDelete_StepTrack	; F7B09B  calr 0xf7b0b7
	jr	MeasureDelete_StepFieldDown_Return3	; F7B09E  jr T,0xf7b0b6
MeasureDelete_StepFieldDown_Skip4:
	cp	(0x0dd4:16), 0x02	; F7B0A0  cp (0x0dd4),0x02
	jr	nz, MeasureDelete_StepFieldDown_Skip5	; F7B0A5  jr NZ,0xf7b0ac
	calr	MeasureDelete_StepFirstMeasure	; F7B0A7  calr 0xf7b0f2
	jr	MeasureDelete_StepFieldDown_Return3	; F7B0AA  jr T,0xf7b0b6
MeasureDelete_StepFieldDown_Skip5:
	cp	(0x0dd4:16), 0x03	; F7B0AC  cp (0x0dd4),0x03
	jr	nz, MeasureDelete_StepFieldDown_Return3	; F7B0B1  jr NZ,0xf7b0b6
	calr	MeasureDelete_StepLastMeasure	; F7B0B3  calr 0xf7b128
MeasureDelete_StepFieldDown_Return3:
	ret	; F7B0B6  ret

; --------------------------------------------------------------------------
; MeasureDelete_StepTrack
; Called from: in-module: 0xF7B05E 0xF7B09B
; Touches: (0x0C13) (0x0C35) (0x0DD5) (0x12F6)
; Calls:   SeqJob_StepTrack
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7B0B7 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureDelete_StepTrack: field 1 of the page (Track, FirstMeasure, LastMeasure), stepped in the direction (0x0C4F) holds (notes/prom_b_seqjob_field_names.py)
MeasureDelete_StepTrack:
	ld	a, (3091:16)	; F7B0B7  ld A,(0x0c13)
	ld	l, 1:opc	; F7B0BB  ld L,0x01
	ld	h, 18:opc	; F7B0BD  ld H,0x12
	calr	SeqJob_StepTrack	; F7B0BF  calr 0xf7cd30
	cp	a, 18	; F7B0C2  cp A,0x12
	jr	z, MeasureDelete_StepTrack_Skip	; F7B0C5  jr Z,0xf7b0db
	ld	(3091:16), a	; F7B0C7  ld (0x0c13),A
	ld	(6304860:24), a	; F7B0CB  ld (0x60345c),A
	ld	(3541:16), a	; F7B0D0  ld (0x0dd5),A
	and	(0x0c35:16), 0xfe	; F7B0D4  and (0x0c35),0xfe
	jr	MeasureDelete_StepTrack_Join	; F7B0D9  jr T,0xf7b0ed
MeasureDelete_StepTrack_Skip:
	ld	(3541:16), a	; F7B0DB  ld (0x0dd5),A
	ld	(3091:16), a	; F7B0DF  ld (0x0c13),A
	ld	(6304860:24), a	; F7B0E3  ld (0x60345c),A
	or	(0x0c35:16), 0x01	; F7B0E8  or (0x0c35),0x01
MeasureDelete_StepTrack_Join:
	ld	(DisplayListB_Stage:16), a	; F7B0ED  ld (0x12f6),A
	ret	; F7B0F1  ret

; --------------------------------------------------------------------------
; MeasureDelete_StepFirstMeasure
; Called from: in-module: 0xF7B06A 0xF7B0A7
; Touches: (0x0C18) (0x0DD6) (0x0DD8) (0x12F7) (0x12F9)
; Calls:   SeqJob_StepMeasure
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7B0F2 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureDelete_StepFirstMeasure: field 2 of the page (Track, FirstMeasure, LastMeasure), stepped in the direction (0x0C4F) holds (notes/prom_b_seqjob_field_names.py)
MeasureDelete_StepFirstMeasure:
	ld	wa, (3096:16)	; F7B0F2  ld WA,(0x0c18)
	calr	SeqJob_StepMeasure	; F7B0F6  calr 0xf7cd5f
	ld	(3096:16), wa	; F7B0F9  ld (0x0c18),WA
	ld	(6304861:24), wa	; F7B0FD  ld (0x60345d),WA
	cp	wa, (0x0dd8:16)	; F7B102  cp WA,(0x0dd8)
	jr	ule, MeasureDelete_StepFirstMeasure_Skip	; F7B106  jr ULE,0xf7b110
	ld	(3544:16), wa	; F7B108  ld (0x0dd8),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7B10C  ld (0x12f9),WA
MeasureDelete_StepFirstMeasure_Skip:
	ld	(3542:16), wa	; F7B110  ld (0x0dd6),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7B114  ld (0x12f7),WA
	ld	wa, (3544:16)	; F7B118  ld WA,(0x0dd8)
	sub	wa, (0x0dd6:16)	; F7B11C  sub WA,(0x0dd6)
	inc	1, wa	; F7B120  inc 1,WA
	ld	(6304863:24), wa	; F7B122  ld (0x60345f),WA
	ret	; F7B127  ret

; --------------------------------------------------------------------------
; MeasureDelete_StepLastMeasure
; Called from: in-module: 0xF7B076 0xF7B0B3
; Touches: (0x0C18) (0x0DD6) (0x0DD8) (0x12F7) (0x12F9)
; Calls:   SeqJob_StepMeasure
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7B128 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureDelete_StepLastMeasure: field 3 of the page (Track, FirstMeasure, LastMeasure), stepped in the direction (0x0C4F) holds (notes/prom_b_seqjob_field_names.py)
MeasureDelete_StepLastMeasure:
	ld	wa, (3544:16)	; F7B128  ld WA,(0x0dd8)
	calr	SeqJob_StepMeasure	; F7B12C  calr 0xf7cd5f
	ld	(3544:16), wa	; F7B12F  ld (0x0dd8),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7B133  ld (0x12f9),WA
	cp	wa, (0x0dd6:16)	; F7B137  cp WA,(0x0dd6)
	jr	nc, MeasureDelete_StepLastMeasure_Skip	; F7B13B  jr NC,0xf7b14e
	ld	(3542:16), wa	; F7B13D  ld (0x0dd6),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7B141  ld (0x12f7),WA
	ld	(3096:16), wa	; F7B145  ld (0x0c18),WA
	ld	(6304861:24), wa	; F7B149  ld (0x60345d),WA
MeasureDelete_StepLastMeasure_Skip:
	ld	(3544:16), wa	; F7B14E  ld (0x0dd8),WA
	ld	wa, (3544:16)	; F7B152  ld WA,(0x0dd8)
	sub	wa, (0x0dd6:16)	; F7B156  sub WA,(0x0dd6)
	inc	1, wa	; F7B15A  inc 1,WA
	ld	(6304863:24), wa	; F7B15C  ld (0x60345f),WA
	ret	; F7B161  ret

; --------------------------------------------------------------------------
; MeasureDelete_LcdKeyRow3
; Called from: T_MeasureDelete_LcdKeyRow3 (x2)
; Touches: (0x0C13) (0x0C18) (0x0C1C) (0x0C35) (0x0C70) (0x0C73) (0x0C77)
;          (0x0D4A) (0x0DD6) (0x0DD8) +5 more
; Calls:   T_SongEdit_DeleteMeasures
; Evidence: thunk slot T_MeasureDelete_LcdKeyRow3 holds `jp 0x00F7B162`, and 0xF7B162 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureDelete_LcdKeyRow3: the LcdKeyRow3 action of MeasureDelete_StageNonZero, MeasureDelete_StageZero -- called only by LcdKeyRow3_MeasureDelete_StageNonZero, LcdKeyRow3_MeasureDelete_StageZero.
MeasureDelete_LcdKeyRow3:		; <- T_MeasureDelete_LcdKeyRow3
	and	(UI_RequestBits:16), 0xf6	; F7B162  and (0x2075),0xf6
	cp	(UI_ScreenStage:16), 0x01	; F7B167  cp (0x207e),0x01
	jr	z, MeasureDelete_LcdKeyRow3_Skip2	; F7B16C  jr Z,0xf7b17a
	ld	(UI_ScreenStage:16), 1	; F7B16E  ld (0x207e),0x01
	or	(UI_Request_Hi:16), 0x10	; F7B173  or (0x2071),0x10
	jr	MeasureDelete_LcdKeyRow3_Return	; F7B178  jr T,0xf7b1d0
MeasureDelete_LcdKeyRow3_Skip2:
	ld	a, (3091:16)	; F7B17A  ld A,(0x0c13)
	bit	0, (0x0c35:16)	; F7B17E  bit 0,(0x0c35)
	jr	z, MeasureDelete_LcdKeyRow3_Skip3	; F7B182  jr Z,0xf7b186
	ld	a, 127:opc	; F7B184  ld A,0x7f
MeasureDelete_LcdKeyRow3_Skip3:
	ld	(3184:16), a	; F7B186  ld (0x0c70),A
	ld	wa, (3096:16)	; F7B18A  ld WA,(0x0c18)
	ld	(3187:16), wa	; F7B18E  ld (0x0c73),WA
	ld	wa, (3544:16)	; F7B192  ld WA,(0x0dd8)
	sub	wa, (0x0dd6:16)	; F7B196  sub WA,(0x0dd6)
	inc	1, wa	; F7B19A  inc 1,WA
	ld	(3100:16), wa	; F7B19C  ld (0x0c1c),WA
	ld	(3191:16), wa	; F7B1A0  ld (0x0c77),WA
	ld	(UI_StatusCode:16), 255	; F7B1A4  ld (0x2880),0xff
	ld	(BStore_ErrorCode:16), 0	; F7B1A9  ld (0x0d4a),0x00
	call	T_SongEdit_DeleteMeasures	; F7B1AE  call 0xf426ec
	cp	(UI_StatusCode:16), 0xff	; F7B1B2  cp (0x2880),0xff
	jr	z, MeasureDelete_LcdKeyRow3_Skip4	; F7B1B7  jr Z,0xf7b1c6
	ldw	(UI_Request:16), 16555	; F7B1B9  ld (0x2070),0x40ab
	ld	(UI_ScreenStage:16), 0	; F7B1BF  ld (0x207e),0x00
	jr	MeasureDelete_LcdKeyRow3_Return	; F7B1C4  jr T,0xf7b1d0
MeasureDelete_LcdKeyRow3_Skip4:
	ld	(UI_ScreenStage:16), 0	; F7B1C6  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7B1CB  or (0x2071),0x10
MeasureDelete_LcdKeyRow3_Return:
	ret	; F7B1D0  ret

; --------------------------------------------------------------------------
; MeasureDelete_LoadSavedFields
; Called from: in-module: 0xF7B000
; Touches: (0x0C13) (0x0C18) (0x0C1C) (0x0C35) (0x0DD5) (0x0DD6) (0x0DD8)
;          (0x12F6) (0x12F7) (0x12F9)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7B1D1 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureDelete_LoadSavedFields: copies the job's saved fields from battery RAM 0x6034xx into the working cells (notes/prom_b_seqjob_field_names.py)
MeasureDelete_LoadSavedFields:
	ld	a, (6304860:24)	; F7B1D1  ld A,(0x60345c)
	ld	(3091:16), a	; F7B1D6  ld (0x0c13),A
	ld	(3541:16), a	; F7B1DA  ld (0x0dd5),A
	ld	(DisplayListB_Stage:16), a	; F7B1DE  ld (0x12f6),A
	ld	wa, (6304861:24)	; F7B1E2  ld WA,(0x60345d)
	ld	(3096:16), wa	; F7B1E7  ld (0x0c18),WA
	ld	(3542:16), wa	; F7B1EB  ld (0x0dd6),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7B1EF  ld (0x12f7),WA
	ld	wa, (6304863:24)	; F7B1F3  ld WA,(0x60345f)
	dec	1, wa	; F7B1F8  dec 1,WA
	add	wa, (6304861:24)	; F7B1FA  add WA,(0x60345d)
	ld	(3544:16), wa	; F7B1FF  ld (0x0dd8),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7B203  ld (0x12f9),WA
	ld	wa, (3544:16)	; F7B207  ld WA,(0x0dd8)
	sub	wa, (0x0dd6:16)	; F7B20B  sub WA,(0x0dd6)
	inc	1, wa	; F7B20F  inc 1,WA
	ld	(6304863:24), wa	; F7B211  ld (0x60345f),WA
	ld	(3100:16), wa	; F7B216  ld (0x0c1c),WA
	and	(0x0c35:16), 0xfe	; F7B21A  and (0x0c35),0xfe
	cp	(0x0c13:16), 0x12	; F7B21F  cp (0x0c13),0x12
	jr	nz, MeasureDelete_LoadSavedFields_Return	; F7B224  jr NZ,0xf7b22b
	or	(0x0c35:16), 0x01	; F7B226  or (0x0c35),0x01
MeasureDelete_LoadSavedFields_Return:
	ret	; F7B22B  ret

; --------------------------------------------------------------------------
; MeasureErase_InitFields
; Called from: T_MeasureErase_InitFields (x1)
; Touches: (0x0DBB) (0x12FC)
; Calls:   MeasureErase_LoadSavedFields
; Evidence: thunk slot T_MeasureErase_InitFields holds `jp 0x00F7B22C`, and 0xF7B22C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureErase_InitFields: Paint_MeasureErase's stage-0 init: MeasureErase_LoadSavedFields, field cursor (0x0DBB) = 1 (notes/prom_b_seqjob_field_names.py)
MeasureErase_InitFields:		; <- T_MeasureErase_InitFields
	calr	MeasureErase_LoadSavedFields	; F7B22C  calr 0xf7b457
	ld	(3515:16), 1	; F7B22F  ld (0x0dbb),0x01
	ld	(DisplayListB_Stage+6:16), 1	; F7B234  ld (0x12fc),0x01
	ret	; F7B239  ret

; --------------------------------------------------------------------------
; MeasureErase_OnLeave
; Called from: T_MeasureErase_OnLeave (x1)
; Touches: (0x207A)
; Calls:   T_Seq_RequestRewind
; Evidence: thunk slot T_MeasureErase_OnLeave holds `jp 0x00F7B23A`, and 0xF7B23A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureErase_OnLeave: the LEAVE work of MeasureErase -- the one unnamed routine ScreenLeaveBody_MeasureErase calls, and nothing else calls it
;   (notes/prom_ab_screen_enter_leave_work.py).
MeasureErase_OnLeave:		; <- T_MeasureErase_OnLeave
	cp	(UI_ScreenLatch:16), 0x20	; F7B23A  cp (0x207a),0x20
	jr	z, MeasureErase_OnLeave_Return2	; F7B23F  jr Z,0xf7b245
	call	T_Seq_RequestRewind	; F7B241  call 0xf409e0
MeasureErase_OnLeave_Return2:
	ret	; F7B245  ret

; --------------------------------------------------------------------------
; MeasureErase_SelectField1
; Called from: T_MeasureErase_SelectField1 (x1)
; Touches: (0x0DBB) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_MeasureErase_SelectField1 holds `jp 0x00F7B246`, and 0xF7B246 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 1 into (0x0DBB) and requests a redraw (UI_RequestBits);
;           (0x0DBB) is read by LcdKeyRow1..4_MeasureErase_StageZero, so it is the MeasureErase screen's field cell.
; Unknown: what field 1 is on that screen.
; --------------------------------------------------------------------------
MeasureErase_SelectField1:		; <- T_MeasureErase_SelectField1
	ld	(3515:16), 1	; F7B246  ld (0x0dbb),0x01
	or	(UI_RequestBits:16), 0x09	; F7B24B  or (0x2075),0x09
	ret	; F7B250  ret

; --------------------------------------------------------------------------
; MeasureErase_SelectField2
; Called from: T_MeasureErase_SelectField2 (x1)
; Touches: (0x0DBB) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_MeasureErase_SelectField2 holds `jp 0x00F7B251`, and 0xF7B251 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 2 into (0x0DBB) and requests a redraw (UI_RequestBits);
;           (0x0DBB) is read by LcdKeyRow1..4_MeasureErase_StageZero, so it is the MeasureErase screen's field cell.
; Unknown: what field 2 is on that screen.
; --------------------------------------------------------------------------
MeasureErase_SelectField2:		; <- T_MeasureErase_SelectField2
	ld	(3515:16), 2	; F7B251  ld (0x0dbb),0x02
	or	(UI_RequestBits:16), 0x08	; F7B256  or (0x2075),0x08
	or	(UI_RequestBits:16), 0x01	; F7B25B  or (0x2075),0x01
	ret	; F7B260  ret

; --------------------------------------------------------------------------
; MeasureErase_SelectField3
; Called from: T_MeasureErase_SelectField3 (x1)
; Touches: (0x0DBB) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_MeasureErase_SelectField3 holds `jp 0x00F7B261`, and 0xF7B261 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 3 into (0x0DBB) and requests a redraw (UI_RequestBits);
;           (0x0DBB) is read by LcdKeyRow1..4_MeasureErase_StageZero, so it is the MeasureErase screen's field cell.
; Unknown: what field 3 is on that screen.
; --------------------------------------------------------------------------
MeasureErase_SelectField3:		; <- T_MeasureErase_SelectField3
	ld	(3515:16), 3	; F7B261  ld (0x0dbb),0x03
	or	(UI_RequestBits:16), 0x08	; F7B266  or (0x2075),0x08
	or	(UI_RequestBits:16), 0x01	; F7B26B  or (0x2075),0x01
	ret	; F7B270  ret

; --------------------------------------------------------------------------
; MeasureErase_SelectField4
; Called from: T_MeasureErase_SelectField4 (x1)
; Touches: (0x0DBB) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_MeasureErase_SelectField4 holds `jp 0x00F7B271`, and 0xF7B271 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 4 into (0x0DBB) and requests a redraw (UI_RequestBits);
;           (0x0DBB) is read by LcdKeyRow1..4_MeasureErase_StageZero, so it is the MeasureErase screen's field cell.
; Unknown: what field 4 is on that screen.
; --------------------------------------------------------------------------
MeasureErase_SelectField4:		; <- T_MeasureErase_SelectField4
	ld	(3515:16), 4	; F7B271  ld (0x0dbb),0x04
	or	(UI_RequestBits:16), 0x09	; F7B276  or (0x2075),0x09
	ret	; F7B27B  ret

; --------------------------------------------------------------------------
; MeasureErase_StepFieldUp
; Called from: T_MeasureErase_StepFieldUp (x4)
; Touches: (0x0C4E) (0x0C4F) (0x0DBB) (0x207E)
; Calls:   MeasureErase_StepTrack MeasureErase_StepFirstMeasure MeasureErase_StepLastMeasure MeasureErase_StepEraseData
; Evidence: thunk slot T_MeasureErase_StepFieldUp holds `jp 0x00F7B27C`, and 0xF7B27C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureErase_StepFieldUp: at stage 1 leaves through MeasureErase_ReturnToStageZero; else (0x0C4E) = W, (0x0C4F) = 0 (up) and
;   steps field (0x0DBB) (notes/prom_b_seqjob_field_names.py)
MeasureErase_StepFieldUp:		; <- T_MeasureErase_StepFieldUp
	cp	(UI_ScreenStage:16), 0x01	; F7B27C  cp (0x207e),0x01
	jr	nz, MeasureErase_StepFieldUp_Skip	; F7B281  jr NZ,0xf7b285
	jr	MeasureErase_ReturnToStageZero	; F7B283  jr T,0xf7b2bd
MeasureErase_StepFieldUp_Skip:
	ld	(3150:16), w	; F7B285  ld (0x0c4e),W
	ld	(3151:16), 0	; F7B289  ld (0x0c4f),0x00
	cp	(0x0dbb:16), 0x01	; F7B28E  cp (0x0dbb),0x01
	jr	nz, MeasureErase_StepFieldUp_Skip2	; F7B293  jr NZ,0xf7b29a
	calr	MeasureErase_StepTrack	; F7B295  calr 0xf7b306
	jr	MeasureErase_StepFieldUp_Return3	; F7B298  jr T,0xf7b2bc
MeasureErase_StepFieldUp_Skip2:
	cp	(0x0dbb:16), 0x02	; F7B29A  cp (0x0dbb),0x02
	jr	nz, MeasureErase_StepFieldUp_Skip3	; F7B29F  jr NZ,0xf7b2a6
	calr	MeasureErase_StepFirstMeasure	; F7B2A1  calr 0xf7b341
	jr	MeasureErase_StepFieldUp_Return3	; F7B2A4  jr T,0xf7b2bc
MeasureErase_StepFieldUp_Skip3:
	cp	(0x0dbb:16), 0x03	; F7B2A6  cp (0x0dbb),0x03
	jr	nz, MeasureErase_StepFieldUp_Skip4	; F7B2AB  jr NZ,0xf7b2b2
	calr	MeasureErase_StepLastMeasure	; F7B2AD  calr 0xf7b377
	jr	MeasureErase_StepFieldUp_Return3	; F7B2B0  jr T,0xf7b2bc
MeasureErase_StepFieldUp_Skip4:
	cp	(0x0dbb:16), 0x04	; F7B2B2  cp (0x0dbb),0x04
	jr	nz, MeasureErase_StepFieldUp_Return3	; F7B2B7  jr NZ,0xf7b2bc
	calr	MeasureErase_StepEraseData	; F7B2B9  calr 0xf7b3b1
MeasureErase_StepFieldUp_Return3:
	ret	; F7B2BC  ret

; --------------------------------------------------------------------------
; MeasureErase_ReturnToStageZero
; Called from: T_MeasureErase_ReturnToStageZero (x0)
; Touches: (0x2071) (0x2075) (0x207E)
; Evidence: thunk slot T_MeasureErase_ReturnToStageZero holds `jp 0x00F7B2BD`, and 0xF7B2BD is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureErase_ReturnToStageZero: UI_ScreenStage = 0, UI_Request_Hi |= 0x10 (notes/prom_b_seqjob_field_names.py)
MeasureErase_ReturnToStageZero:		; <- T_MeasureErase_ReturnToStageZero
	and	(UI_RequestBits:16), 0xf6	; F7B2BD  and (0x2075),0xf6
	ld	(UI_ScreenStage:16), 0	; F7B2C2  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7B2C7  or (0x2071),0x10
	jr	MeasureErase_StepFieldUp_Return3	; F7B2CC  jr T,0xf7b2bc

; --------------------------------------------------------------------------
; MeasureErase_StepFieldDown
; Called from: T_MeasureErase_StepFieldDown (x2)
; Touches: (0x0C4E) (0x0C4F) (0x0DBB)
; Calls:   MeasureErase_StepTrack MeasureErase_StepFirstMeasure MeasureErase_StepLastMeasure MeasureErase_StepEraseData
; Evidence: thunk slot T_MeasureErase_StepFieldDown holds `jp 0x00F7B2CE`, and 0xF7B2CE is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureErase_StepFieldDown: (0x0C4E) = W, (0x0C4F) = 0x80 (down), steps field (0x0DBB) (notes/prom_b_seqjob_field_names.py)
MeasureErase_StepFieldDown:		; <- T_MeasureErase_StepFieldDown
	ld	(3150:16), w	; F7B2CE  ld (0x0c4e),W
	ld	(3151:16), 128	; F7B2D2  ld (0x0c4f),0x80
	cp	(0x0dbb:16), 0x01	; F7B2D7  cp (0x0dbb),0x01
	jr	nz, MeasureErase_StepFieldDown_Skip5	; F7B2DC  jr NZ,0xf7b2e3
	calr	MeasureErase_StepTrack	; F7B2DE  calr 0xf7b306
	jr	MeasureErase_StepFieldDown_Return4	; F7B2E1  jr T,0xf7b305
MeasureErase_StepFieldDown_Skip5:
	cp	(0x0dbb:16), 0x02	; F7B2E3  cp (0x0dbb),0x02
	jr	nz, MeasureErase_StepFieldDown_Skip6	; F7B2E8  jr NZ,0xf7b2ef
	calr	MeasureErase_StepFirstMeasure	; F7B2EA  calr 0xf7b341
	jr	MeasureErase_StepFieldDown_Return4	; F7B2ED  jr T,0xf7b305
MeasureErase_StepFieldDown_Skip6:
	cp	(0x0dbb:16), 0x03	; F7B2EF  cp (0x0dbb),0x03
	jr	nz, MeasureErase_StepFieldDown_Skip7	; F7B2F4  jr NZ,0xf7b2fb
	calr	MeasureErase_StepLastMeasure	; F7B2F6  calr 0xf7b377
	jr	MeasureErase_StepFieldDown_Return4	; F7B2F9  jr T,0xf7b305
MeasureErase_StepFieldDown_Skip7:
	cp	(0x0dbb:16), 0x04	; F7B2FB  cp (0x0dbb),0x04
	jr	nz, MeasureErase_StepFieldDown_Return4	; F7B300  jr NZ,0xf7b305
	calr	MeasureErase_StepEraseData	; F7B302  calr 0xf7b3b1
MeasureErase_StepFieldDown_Return4:
	ret	; F7B305  ret

; --------------------------------------------------------------------------
; MeasureErase_StepTrack
; Called from: in-module: 0xF7B295 0xF7B2DE
; Touches: (0x0C13) (0x0C2E) (0x0C35) (0x12F6)
; Calls:   SeqJob_StepTrack
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7B306 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureErase_StepTrack: field 1 of the page (Track, FirstMeasure, LastMeasure, EraseData), stepped in the direction (0x0C4F) holds (notes/prom_b_seqjob_field_names.py)
MeasureErase_StepTrack:
	ld	a, (3091:16)	; F7B306  ld A,(0x0c13)
	ld	l, 1:opc	; F7B30A  ld L,0x01
	ld	h, 18:opc	; F7B30C  ld H,0x12
	calr	SeqJob_StepTrack	; F7B30E  calr 0xf7cd30
	cp	a, 18	; F7B311  cp A,0x12
	jr	z, MeasureErase_StepTrack_Skip	; F7B314  jr Z,0xf7b32a
	ld	(3091:16), a	; F7B316  ld (0x0c13),A
	ld	(6304865:24), a	; F7B31A  ld (0x603461),A
	ld	(3118:16), a	; F7B31F  ld (0x0c2e),A
	and	(0x0c35:16), 0xfd	; F7B323  and (0x0c35),0xfd
	jr	MeasureErase_StepTrack_Join	; F7B328  jr T,0xf7b33c
MeasureErase_StepTrack_Skip:
	ld	(3118:16), a	; F7B32A  ld (0x0c2e),A
	ld	(3091:16), a	; F7B32E  ld (0x0c13),A
	ld	(6304865:24), a	; F7B332  ld (0x603461),A
	or	(0x0c35:16), 0x02	; F7B337  or (0x0c35),0x02
MeasureErase_StepTrack_Join:
	ld	(DisplayListB_Stage:16), a	; F7B33C  ld (0x12f6),A
	ret	; F7B340  ret

; --------------------------------------------------------------------------
; MeasureErase_StepFirstMeasure
; Called from: in-module: 0xF7B2A1 0xF7B2EA
; Touches: (0x0C18) (0x0C2A) (0x0C2C) (0x12F7) (0x12F9)
; Calls:   SeqJob_StepMeasure
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7B341 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureErase_StepFirstMeasure: field 2 of the page (Track, FirstMeasure, LastMeasure, EraseData), stepped in the direction (0x0C4F) holds (notes/prom_b_seqjob_field_names.py)
MeasureErase_StepFirstMeasure:
	ld	wa, (3096:16)	; F7B341  ld WA,(0x0c18)
	calr	SeqJob_StepMeasure	; F7B345  calr 0xf7cd5f
	ld	(3096:16), wa	; F7B348  ld (0x0c18),WA
	ld	(6304866:24), wa	; F7B34C  ld (0x603462),WA
	cp	wa, (0x0c2c:16)	; F7B351  cp WA,(0x0c2c)
	jr	ule, MeasureErase_StepFirstMeasure_Skip	; F7B355  jr ULE,0xf7b35f
	ld	(3116:16), wa	; F7B357  ld (0x0c2c),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7B35B  ld (0x12f9),WA
MeasureErase_StepFirstMeasure_Skip:
	ld	(3114:16), wa	; F7B35F  ld (0x0c2a),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7B363  ld (0x12f7),WA
	ld	wa, (3116:16)	; F7B367  ld WA,(0x0c2c)
	sub	wa, (0x0c2a:16)	; F7B36B  sub WA,(0x0c2a)
	inc	1, wa	; F7B36F  inc 1,WA
	ld	(6304868:24), wa	; F7B371  ld (0x603464),WA
	ret	; F7B376  ret

; --------------------------------------------------------------------------
; MeasureErase_StepLastMeasure
; Called from: in-module: 0xF7B2AD 0xF7B2F6
; Touches: (0x0C18) (0x0C2A) (0x0C2C) (0x12F7) (0x12F9)
; Calls:   SeqJob_StepMeasure
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7B377 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureErase_StepLastMeasure: field 3 of the page (Track, FirstMeasure, LastMeasure, EraseData), stepped in the direction (0x0C4F) holds (notes/prom_b_seqjob_field_names.py)
MeasureErase_StepLastMeasure:
	ld	wa, (3116:16)	; F7B377  ld WA,(0x0c2c)
	calr	SeqJob_StepMeasure	; F7B37B  calr 0xf7cd5f
	ld	(3116:16), wa	; F7B37E  ld (0x0c2c),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7B382  ld (0x12f9),WA
	cp	wa, (0x0c2a:16)	; F7B386  cp WA,(0x0c2a)
	jr	nc, MeasureErase_StepLastMeasure_Skip	; F7B38A  jr NC,0xf7b39d
	ld	(3114:16), wa	; F7B38C  ld (0x0c2a),WA
	ld	(3096:16), wa	; F7B390  ld (0x0c18),WA
	ld	(6304866:24), wa	; F7B394  ld (0x603462),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7B399  ld (0x12f7),WA
MeasureErase_StepLastMeasure_Skip:
	ld	(3116:16), wa	; F7B39D  ld (0x0c2c),WA
	ld	wa, (3116:16)	; F7B3A1  ld WA,(0x0c2c)
	sub	wa, (0x0c2a:16)	; F7B3A5  sub WA,(0x0c2a)
	inc	1, wa	; F7B3A9  inc 1,WA
	ld	(6304868:24), wa	; F7B3AB  ld (0x603464),WA
	ret	; F7B3B0  ret

; --------------------------------------------------------------------------
; MeasureErase_StepEraseData
; Called from: in-module: 0xF7B2B9 0xF7B302
; Touches: (0x0C16) (0x0C4F) (0x12FB)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7B3B1 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureErase_StepEraseData: field 4 of the page (Track, FirstMeasure, LastMeasure, EraseData), stepped in the direction (0x0C4F) holds (notes/prom_b_seqjob_field_names.py)
MeasureErase_StepEraseData:
	ld	a, (3094:16)	; F7B3B1  ld A,(0x0c16)
	ld	l, 0:opc	; F7B3B5  ld L,0x00
	ld	h, 2:opc	; F7B3B7  ld H,0x02
	cp	(0x0c4f:16), 0x80	; F7B3B9  cp (0x0c4f),0x80
	jr	z, MeasureErase_StepEraseData_Skip	; F7B3BE  jr Z,0xf7b3c8
	inc	1, a	; F7B3C0  inc 1,A
	cp	a, h	; F7B3C2  cp A,H
	jr	ugt, MeasureErase_StepEraseData_Skip2	; F7B3C4  jr UGT,0xf7b3d0
	jr	MeasureErase_StepEraseData_Join	; F7B3C6  jr T,0xf7b3d2
MeasureErase_StepEraseData_Skip:
	cp	a, l	; F7B3C8  cp A,L
	jr	z, MeasureErase_StepEraseData_Join	; F7B3CA  jr Z,0xf7b3d2
	dec	1, a	; F7B3CC  dec 1,A
	jr	MeasureErase_StepEraseData_Join	; F7B3CE  jr T,0xf7b3d2
MeasureErase_StepEraseData_Skip2:
	ld	a, h	; F7B3D0  ld A,H
MeasureErase_StepEraseData_Join:
	ld	(3094:16), a	; F7B3D2  ld (0x0c16),A
	ld	(6304870:24), a	; F7B3D6  ld (0x603466),A
	ld	(DisplayListB_Stage+5:16), a	; F7B3DB  ld (0x12fb),A
	ret	; F7B3DF  ret

; --------------------------------------------------------------------------
; MeasureErase_LcdKeyRow2
; Called from: T_MeasureErase_LcdKeyRow2 (x2)
; Touches: (0x0C13) (0x0C16) (0x0C18) (0x0C1C) (0x0C2A) (0x0C2C) (0x0C35)
;          (0x0C70) (0x0C73) (0x0C77) +7 more
; Calls:   T_MeasureErase_Execute
; Evidence: thunk slot T_MeasureErase_LcdKeyRow2 holds `jp 0x00F7B3E0`, and 0xF7B3E0 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureErase_LcdKeyRow2: the LcdKeyRow2 action of MeasureErase_StageNonZero, MeasureErase_StageZero -- called only by LcdKeyRow2_MeasureErase_StageNonZero, LcdKeyRow2_MeasureErase_StageZero.
MeasureErase_LcdKeyRow2:		; <- T_MeasureErase_LcdKeyRow2
	and	(UI_RequestBits:16), 0xf6	; F7B3E0  and (0x2075),0xf6
	cp	(UI_ScreenStage:16), 0x01	; F7B3E5  cp (0x207e),0x01
	jr	z, MeasureErase_LcdKeyRow2_Skip3	; F7B3EA  jr Z,0xf7b3f8
	ld	(UI_ScreenStage:16), 1	; F7B3EC  ld (0x207e),0x01
	or	(UI_Request_Hi:16), 0x10	; F7B3F1  or (0x2071),0x10
	jr	MeasureErase_LcdKeyRow2_Return	; F7B3F6  jr T,0xf7b456
MeasureErase_LcdKeyRow2_Skip3:
	ld	a, (3091:16)	; F7B3F8  ld A,(0x0c13)
	bit	1, (0x0c35:16)	; F7B3FC  bit 1,(0x0c35)
	jr	z, MeasureErase_LcdKeyRow2_Skip4	; F7B400  jr Z,0xf7b404
	ld	a, 127:opc	; F7B402  ld A,0x7f
MeasureErase_LcdKeyRow2_Skip4:
	ld	(3184:16), a	; F7B404  ld (0x0c70),A
	ld	wa, (3096:16)	; F7B408  ld WA,(0x0c18)
	ld	(3187:16), wa	; F7B40C  ld (0x0c73),WA
	ld	wa, (3116:16)	; F7B410  ld WA,(0x0c2c)
	sub	wa, (0x0c2a:16)	; F7B414  sub WA,(0x0c2a)
	inc	1, wa	; F7B418  inc 1,WA
	ld	(3100:16), wa	; F7B41A  ld (0x0c1c),WA
	ld	(3191:16), wa	; F7B41E  ld (0x0c77),WA
	ld	a, (3094:16)	; F7B422  ld A,(0x0c16)
	ld	(3193:16), a	; F7B426  ld (0x0c79),A
	ld	(UI_StatusCode:16), 255	; F7B42A  ld (0x2880),0xff
	ld	(BStore_ErrorCode:16), 0	; F7B42F  ld (0x0d4a),0x00
	call	T_MeasureErase_Execute	; F7B434  call 0xf426f0
	cp	(UI_StatusCode:16), 0xff	; F7B438  cp (0x2880),0xff
	jr	z, MeasureErase_LcdKeyRow2_Skip5	; F7B43D  jr Z,0xf7b44c
	ldw	(UI_Request:16), 16555	; F7B43F  ld (0x2070),0x40ab
	ld	(UI_ScreenStage:16), 0	; F7B445  ld (0x207e),0x00
	jr	MeasureErase_LcdKeyRow2_Return	; F7B44A  jr T,0xf7b456
MeasureErase_LcdKeyRow2_Skip5:
	ld	(UI_ScreenStage:16), 0	; F7B44C  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7B451  or (0x2071),0x10
MeasureErase_LcdKeyRow2_Return:
	ret	; F7B456  ret

; --------------------------------------------------------------------------
; MeasureErase_LoadSavedFields
; Called from: in-module: 0xF7B22C
; Touches: (0x0C13) (0x0C16) (0x0C18) (0x0C1C) (0x0C2A) (0x0C2C) (0x0C2E)
;          (0x0C35) (0x12F6) (0x12F7) +2 more
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7B457 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureErase_LoadSavedFields: copies the job's saved fields from battery RAM 0x6034xx into the working cells (notes/prom_b_seqjob_field_names.py)
MeasureErase_LoadSavedFields:
	ld	a, (6304865:24)	; F7B457  ld A,(0x603461)
	ld	(3091:16), a	; F7B45C  ld (0x0c13),A
	ld	(3118:16), a	; F7B460  ld (0x0c2e),A
	ld	(DisplayListB_Stage:16), a	; F7B464  ld (0x12f6),A
	ld	wa, (6304866:24)	; F7B468  ld WA,(0x603462)
	ld	(3096:16), wa	; F7B46D  ld (0x0c18),WA
	ld	(3114:16), wa	; F7B471  ld (0x0c2a),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7B475  ld (0x12f7),WA
	ld	wa, (6304868:24)	; F7B479  ld WA,(0x603464)
	dec	1, wa	; F7B47E  dec 1,WA
	add	wa, (6304866:24)	; F7B480  add WA,(0x603462)
	ld	(3116:16), wa	; F7B485  ld (0x0c2c),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7B489  ld (0x12f9),WA
	ld	wa, (3116:16)	; F7B48D  ld WA,(0x0c2c)
	sub	wa, (0x0c2a:16)	; F7B491  sub WA,(0x0c2a)
	inc	1, wa	; F7B495  inc 1,WA
	ld	(6304868:24), wa	; F7B497  ld (0x603464),WA
	ld	(3100:16), wa	; F7B49C  ld (0x0c1c),WA
	ld	a, (6304870:24)	; F7B4A0  ld A,(0x603466)
	ld	(3094:16), a	; F7B4A5  ld (0x0c16),A
	ld	(DisplayListB_Stage+5:16), a	; F7B4A9  ld (0x12fb),A
	and	(0x0c35:16), 0xfd	; F7B4AD  and (0x0c35),0xfd
	cp	(0x0c13:16), 0x12	; F7B4B2  cp (0x0c13),0x12
	jr	nz, MeasureErase_LoadSavedFields_Return	; F7B4B7  jr NZ,0xf7b4be
	or	(0x0c35:16), 0x02	; F7B4B9  or (0x0c35),0x02
MeasureErase_LoadSavedFields_Return:
	ret	; F7B4BE  ret

; --------------------------------------------------------------------------
; MeasureInsert_InitFields
; Called from: T_MeasureInsert_InitFields (x1)
; Touches: (0x0DDA) (0x12FF)
; Calls:   MeasureInsert_LoadSavedFields
; Evidence: thunk slot T_MeasureInsert_InitFields holds `jp 0x00F7B4BF`, and 0xF7B4BF is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_InitFields: Paint_MeasureInsert's stage-0 init (thunk T_MeasureInsert_InitFields): MeasureInsert_LoadSavedFields, MeasureInsert_Field = 1.  MEASURE INSERT: FROM TRACK / FIRST MEASURE / LAST MEASURE | TO TRACK / START MEASURE / REPEAT
MeasureInsert_InitFields:		; <- T_MeasureInsert_InitFields
	calr	MeasureInsert_LoadSavedFields	; F7B4BF  calr 0xf7b852
	ld	a, 1:opc	; F7B4C2  ld A,0x01
	ld	(MeasureInsert_Field:16), a	; F7B4C4  ld (0x0dda),A
	ld	(DisplayListB_Stage+9:16), a	; F7B4C8  ld (0x12ff),A
	ret	; F7B4CC  ret

; --------------------------------------------------------------------------
; MeasureInsert_OnLeave
; Called from: T_MeasureInsert_OnLeave (x1)
; Touches: (0x207A) (0x3010) (0x360C)
; Calls:   T_Seq_RequestRewind
; Evidence: thunk slot T_MeasureInsert_OnLeave holds `jp 0x00F7B4CD`, and 0xF7B4CD is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_OnLeave: the LEAVE work of MeasureInsert -- the one unnamed routine ScreenLeaveBody_MeasureInsert calls, and nothing else calls it
;   (notes/prom_ab_screen_enter_leave_work.py).
MeasureInsert_OnLeave:		; <- T_MeasureInsert_OnLeave
	cp	(UI_ScreenLatch:16), 0x22	; F7B4CD  cp (0x207a),0x22
	jr	z, MeasureInsert_OnLeave_Return2	; F7B4D2  jr Z,0xf7b4eb
	ld	xwa, (12304:16)	; F7B4D4  ld XWA,(0x3010)
	or	(0x360c:16), xwa	; F7B4D8  or (0x360c),XWA
	ld	(6304798:24), xwa	; F7B4DC  ld (0x60341e),XWA
	xor	xwa, xwa	; F7B4E1  xor XWA,XWA
	ld	(12304:16), xwa	; F7B4E3  ld (0x3010),XWA
	call	T_Seq_RequestRewind	; F7B4E7  call 0xf409e0
MeasureInsert_OnLeave_Return2:
	ret	; F7B4EB  ret

; --------------------------------------------------------------------------
; MeasureInsert_SelectField1
; Called from: T_MeasureInsert_SelectField1 (x1)
; Touches: (0x0DDA) (0x2075)
; Evidence: thunk slot T_MeasureInsert_SelectField1 holds `jp 0x00F7B4EC`, and 0xF7B4EC is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_SelectField1: moves the MeasureInsert screen's cursor to field 1 -- stores 1 into MeasureInsert_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
MeasureInsert_SelectField1:		; <- T_MeasureInsert_SelectField1
	ld	(MeasureInsert_Field:16), 1	; F7B4EC  ld (0x0dda),0x01
	or	(UI_RequestBits:16), 0x09	; F7B4F1  or (0x2075),0x09
	ret	; F7B4F6  ret

; --------------------------------------------------------------------------
; MeasureInsert_SelectField2
; Called from: T_MeasureInsert_SelectField2 (x1)
; Touches: (0x0DDA) (0x2075)
; Evidence: thunk slot T_MeasureInsert_SelectField2 holds `jp 0x00F7B4F7`, and 0xF7B4F7 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_SelectField2: moves the MeasureInsert screen's cursor to field 2 -- stores 2 into MeasureInsert_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
MeasureInsert_SelectField2:		; <- T_MeasureInsert_SelectField2
	ld	(MeasureInsert_Field:16), 2	; F7B4F7  ld (0x0dda),0x02
	or	(UI_RequestBits:16), 0x08	; F7B4FC  or (0x2075),0x08
	or	(UI_RequestBits:16), 0x01	; F7B501  or (0x2075),0x01
	ret	; F7B506  ret

; --------------------------------------------------------------------------
; MeasureInsert_SelectField3
; Called from: T_MeasureInsert_SelectField3 (x1)
; Touches: (0x0DDA) (0x2075)
; Evidence: thunk slot T_MeasureInsert_SelectField3 holds `jp 0x00F7B507`, and 0xF7B507 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_SelectField3: moves the MeasureInsert screen's cursor to field 3 -- stores 3 into MeasureInsert_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
MeasureInsert_SelectField3:		; <- T_MeasureInsert_SelectField3
	ld	(MeasureInsert_Field:16), 3	; F7B507  ld (0x0dda),0x03
	or	(UI_RequestBits:16), 0x08	; F7B50C  or (0x2075),0x08
	or	(UI_RequestBits:16), 0x01	; F7B511  or (0x2075),0x01
	ret	; F7B516  ret

; --------------------------------------------------------------------------
; MeasureInsert_SelectField4
; Called from: T_MeasureInsert_SelectField4 (x1)
; Touches: (0x0DDA) (0x2075)
; Evidence: thunk slot T_MeasureInsert_SelectField4 holds `jp 0x00F7B517`, and 0xF7B517 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_SelectField4: moves the MeasureInsert screen's cursor to field 4 -- stores 4 into MeasureInsert_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
MeasureInsert_SelectField4:		; <- T_MeasureInsert_SelectField4
	ld	(MeasureInsert_Field:16), 4	; F7B517  ld (0x0dda),0x04
	or	(UI_RequestBits:16), 0x09	; F7B51C  or (0x2075),0x09
	ret	; F7B521  ret

; --------------------------------------------------------------------------
; MeasureInsert_SelectField5
; Called from: T_MeasureInsert_SelectField5 (x1)
; Touches: (0x0DDA) (0x2075)
; Evidence: thunk slot T_MeasureInsert_SelectField5 holds `jp 0x00F7B522`, and 0xF7B522 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_SelectField5: moves the MeasureInsert screen's cursor to field 5 -- stores 5 into MeasureInsert_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
MeasureInsert_SelectField5:		; <- T_MeasureInsert_SelectField5
	ld	(MeasureInsert_Field:16), 5	; F7B522  ld (0x0dda),0x05
	or	(UI_RequestBits:16), 0x08	; F7B527  or (0x2075),0x08
	or	(UI_RequestBits:16), 0x01	; F7B52C  or (0x2075),0x01
	ret	; F7B531  ret

; --------------------------------------------------------------------------
; MeasureInsert_SelectField6
; Called from: T_MeasureInsert_SelectField6 (x1)
; Touches: (0x0DDA) (0x2075)
; Evidence: thunk slot T_MeasureInsert_SelectField6 holds `jp 0x00F7B532`, and 0xF7B532 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_SelectField6: moves the MeasureInsert screen's cursor to field 6 -- stores 6 into MeasureInsert_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
MeasureInsert_SelectField6:		; <- T_MeasureInsert_SelectField6
	ld	(MeasureInsert_Field:16), 6	; F7B532  ld (0x0dda),0x06
	or	(UI_RequestBits:16), 0x09	; F7B537  or (0x2075),0x09
	ret	; F7B53C  ret

; --------------------------------------------------------------------------
; MeasureInsert_StepFieldUp
; Called from: T_MeasureInsert_StepFieldUp (x2)
; Touches: (0x0C4E) (0x0C4F) (0x0DDA)
; Calls:   MeasureInsert_StepFromTrack MeasureInsert_StepFirstMeasure MeasureInsert_StepLastMeasure MeasureInsert_StepToTrack MeasureInsert_StepStartMeasure MeasureInsert_StepRepeat
; Evidence: thunk slot T_MeasureInsert_StepFieldUp holds `jp 0x00F7B53D`, and 0xF7B53D is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_StepFieldUp: (0x0C4E) = W, (0x0C4F) = 0 (up), then field MeasureInsert_Field 1..6 -> MeasureInsert_StepFromTrack / MeasureInsert_StepFirstMeasure / MeasureInsert_StepLastMeasure / MeasureInsert_StepToTrack / MeasureInsert_StepStartMeasure / MeasureInsert_StepRepeat.  (field order: the page text, checked against each stepper's helper; notes/prom_b_seqjob_field_names.py for the pattern)
MeasureInsert_StepFieldUp:		; <- T_MeasureInsert_StepFieldUp
	ld	(3150:16), w	; F7B53D  ld (0x0c4e),W
	ld	(3151:16), 0	; F7B541  ld (0x0c4f),0x00
	cp	(MeasureInsert_Field:16), 0x01	; F7B546  cp (0x0dda),0x01
	jr	nz, MeasureInsert_StepFieldUp_Skip	; F7B54B  jr NZ,0xf7b552
	calr	MeasureInsert_StepFromTrack	; F7B54D  calr 0xf7b5f5
	jr	MeasureInsert_StepFieldUp_Return3	; F7B550  jr T,0xf7b58b
MeasureInsert_StepFieldUp_Skip:
	cp	(MeasureInsert_Field:16), 0x02	; F7B552  cp (0x0dda),0x02
	jr	nz, MeasureInsert_StepFieldUp_Skip2	; F7B557  jr NZ,0xf7b55e
	calr	MeasureInsert_StepFirstMeasure	; F7B559  calr 0xf7b65e
	jr	MeasureInsert_StepFieldUp_Return3	; F7B55C  jr T,0xf7b58b
MeasureInsert_StepFieldUp_Skip2:
	cp	(MeasureInsert_Field:16), 0x03	; F7B55E  cp (0x0dda),0x03
	jr	nz, MeasureInsert_StepFieldUp_Skip3	; F7B563  jr NZ,0xf7b56a
	calr	MeasureInsert_StepLastMeasure	; F7B565  calr 0xf7b694
	jr	MeasureInsert_StepFieldUp_Return3	; F7B568  jr T,0xf7b58b
MeasureInsert_StepFieldUp_Skip3:
	cp	(MeasureInsert_Field:16), 0x04	; F7B56A  cp (0x0dda),0x04
	jr	nz, MeasureInsert_StepFieldUp_Skip4	; F7B56F  jr NZ,0xf7b576
	calr	MeasureInsert_StepToTrack	; F7B571  calr 0xf7b6ce
	jr	MeasureInsert_StepFieldUp_Return3	; F7B574  jr T,0xf7b58b
MeasureInsert_StepFieldUp_Skip4:
	cp	(MeasureInsert_Field:16), 0x05	; F7B576  cp (0x0dda),0x05
	jr	nz, MeasureInsert_StepFieldUp_Skip5	; F7B57B  jr NZ,0xf7b580
	calr	MeasureInsert_StepStartMeasure	; F7B57D  calr 0xf7b737
MeasureInsert_StepFieldUp_Skip5:
	cp	(MeasureInsert_Field:16), 0x06	; F7B580  cp (0x0dda),0x06
	jr	nz, MeasureInsert_StepFieldUp_Return3	; F7B585  jr NZ,0xf7b58b
	call	MeasureInsert_StepRepeat	; F7B587  call 0xf7b74c
MeasureInsert_StepFieldUp_Return3:
	ret	; F7B58B  ret

; --------------------------------------------------------------------------
; MeasureInsert_StepFieldDown
; Called from: T_MeasureInsert_StepFieldDown (x2)
; Touches: (0x0C4E) (0x0C4F) (0x0DDA) (0x2071) (0x2075) (0x207E)
; Calls:   MeasureInsert_StepFromTrack MeasureInsert_StepFirstMeasure MeasureInsert_StepLastMeasure MeasureInsert_StepToTrack MeasureInsert_StepStartMeasure MeasureInsert_StepRepeat
; Evidence: thunk slot T_MeasureInsert_StepFieldDown holds `jp 0x00F7B58C`, and 0xF7B58C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_StepFieldDown: the same with (0x0C4F) = 0x80 (down).
MeasureInsert_StepFieldDown:		; <- T_MeasureInsert_StepFieldDown
	cp	(UI_ScreenStage:16), 0x01	; F7B58C  cp (0x207e),0x01
	jr	nz, MeasureInsert_StepFieldDown_Skip6	; F7B591  jr NZ,0xf7b595
	jr	MeasureInsert_StepFieldDown_Join	; F7B593  jr T,0xf7b5e4
MeasureInsert_StepFieldDown_Skip6:
	ld	(3150:16), w	; F7B595  ld (0x0c4e),W
	ld	(3151:16), 128	; F7B599  ld (0x0c4f),0x80
	cp	(MeasureInsert_Field:16), 0x01	; F7B59E  cp (0x0dda),0x01
	jr	nz, MeasureInsert_StepFieldDown_Skip7	; F7B5A3  jr NZ,0xf7b5aa
	calr	MeasureInsert_StepFromTrack	; F7B5A5  calr 0xf7b5f5
	jr	MeasureInsert_StepFieldDown_Return4	; F7B5A8  jr T,0xf7b5e3
MeasureInsert_StepFieldDown_Skip7:
	cp	(MeasureInsert_Field:16), 0x02	; F7B5AA  cp (0x0dda),0x02
	jr	nz, MeasureInsert_StepFieldDown_Skip8	; F7B5AF  jr NZ,0xf7b5b6
	calr	MeasureInsert_StepFirstMeasure	; F7B5B1  calr 0xf7b65e
	jr	MeasureInsert_StepFieldDown_Return4	; F7B5B4  jr T,0xf7b5e3
MeasureInsert_StepFieldDown_Skip8:
	cp	(MeasureInsert_Field:16), 0x03	; F7B5B6  cp (0x0dda),0x03
	jr	nz, MeasureInsert_StepFieldDown_Skip9	; F7B5BB  jr NZ,0xf7b5c2
	calr	MeasureInsert_StepLastMeasure	; F7B5BD  calr 0xf7b694
	jr	MeasureInsert_StepFieldDown_Return4	; F7B5C0  jr T,0xf7b5e3
MeasureInsert_StepFieldDown_Skip9:
	cp	(MeasureInsert_Field:16), 0x04	; F7B5C2  cp (0x0dda),0x04
	jr	nz, MeasureInsert_StepFieldDown_Skip10	; F7B5C7  jr NZ,0xf7b5ce
	calr	MeasureInsert_StepToTrack	; F7B5C9  calr 0xf7b6ce
	jr	MeasureInsert_StepFieldDown_Return4	; F7B5CC  jr T,0xf7b5e3
MeasureInsert_StepFieldDown_Skip10:
	cp	(MeasureInsert_Field:16), 0x05	; F7B5CE  cp (0x0dda),0x05
	jr	nz, MeasureInsert_StepFieldDown_Skip11	; F7B5D3  jr NZ,0xf7b5d8
	calr	MeasureInsert_StepStartMeasure	; F7B5D5  calr 0xf7b737
MeasureInsert_StepFieldDown_Skip11:
	cp	(MeasureInsert_Field:16), 0x06	; F7B5D8  cp (0x0dda),0x06
	jr	nz, MeasureInsert_StepFieldDown_Return4	; F7B5DD  jr NZ,0xf7b5e3
	call	MeasureInsert_StepRepeat	; F7B5DF  call 0xf7b74c
MeasureInsert_StepFieldDown_Return4:
	ret	; F7B5E3  ret
MeasureInsert_StepFieldDown_Join:
	and	(UI_RequestBits:16), 0xf6	; F7B5E4  and (0x2075),0xf6
	ld	(UI_ScreenStage:16), 0	; F7B5E9  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7B5EE  or (0x2071),0x10
	jr	MeasureInsert_StepFieldDown_Return4	; F7B5F3  jr T,0xf7b5e3

; --------------------------------------------------------------------------
; MeasureInsert_StepFromTrack
; Called from: in-module: 0xF7B54D 0xF7B5A5
; Touches: (0x0C13) (0x0C14) (0x0C35) (0x0DDB) (0x0DE0) (0x12F6) (0x12FB)
; Calls:   SeqJob_StepTrack
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7B5F5 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_StepFromTrack: field 1 of the page; steps with SeqJob_StepTrack.
MeasureInsert_StepFromTrack:
	ld	a, (3091:16)	; F7B5F5  ld A,(0x0c13)
	ld	l, 1:opc	; F7B5F9  ld L,0x01
	ld	h, 18:opc	; F7B5FB  ld H,0x12
	calr	SeqJob_StepTrack	; F7B5FD  calr 0xf7cd30
	cp	a, 18	; F7B600  cp A,0x12
	jr	z, MeasureInsert_StepFromTrack_Skip2	; F7B603  jr Z,0xf7b636
	bit	2, (0x0c35:16)	; F7B605  bit 2,(0x0c35)
	jr	z, MeasureInsert_StepFromTrack_Skip	; F7B609  jr Z,0xf7b61e
	ld	l, a	; F7B60B  ld L,A
	ld	(3552:16), l	; F7B60D  ld (0x0de0),L
	ld	(3092:16), l	; F7B611  ld (0x0c14),L
	ld	(6304876:24), l	; F7B615  ld (0x60346c),L
	ld	(DisplayListB_Stage+5:16), l	; F7B61A  ld (0x12fb),L
MeasureInsert_StepFromTrack_Skip:
	ld	(3091:16), a	; F7B61E  ld (0x0c13),A
	ld	(6304871:24), a	; F7B622  ld (0x603467),A
	ld	(3547:16), a	; F7B627  ld (0x0ddb),A
	ld	(DisplayListB_Stage:16), a	; F7B62B  ld (0x12f6),A
	and	(0x0c35:16), 0xfb	; F7B62F  and (0x0c35),0xfb
	jr	MeasureInsert_StepFromTrack_Return	; F7B634  jr T,0xf7b65d
MeasureInsert_StepFromTrack_Skip2:
	ld	(3547:16), a	; F7B636  ld (0x0ddb),A
	ld	(3091:16), a	; F7B63A  ld (0x0c13),A
	ld	(6304871:24), a	; F7B63E  ld (0x603467),A
	ld	(DisplayListB_Stage:16), a	; F7B643  ld (0x12f6),A
	ld	(3552:16), a	; F7B647  ld (0x0de0),A
	ld	(3092:16), a	; F7B64B  ld (0x0c14),A
	ld	(6304876:24), a	; F7B64F  ld (0x60346c),A
	ld	(DisplayListB_Stage+5:16), a	; F7B654  ld (0x12fb),A
	or	(0x0c35:16), 0x04	; F7B658  or (0x0c35),0x04
MeasureInsert_StepFromTrack_Return:
	ret	; F7B65D  ret

; --------------------------------------------------------------------------
; MeasureInsert_StepFirstMeasure
; Called from: in-module: 0xF7B559 0xF7B5B1
; Touches: (0x0C18) (0x0DDC) (0x0DDE) (0x12F7) (0x12F9)
; Calls:   SeqJob_StepMeasure
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7B65E is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_StepFirstMeasure: field 2 of the page; steps with SeqJob_StepMeasure.
MeasureInsert_StepFirstMeasure:
	ld	wa, (3096:16)	; F7B65E  ld WA,(0x0c18)
	calr	SeqJob_StepMeasure	; F7B662  calr 0xf7cd5f
	ld	(3096:16), wa	; F7B665  ld (0x0c18),WA
	ld	(6304872:24), wa	; F7B669  ld (0x603468),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7B66E  ld (0x12f7),WA
	cp	wa, (0x0dde:16)	; F7B672  cp WA,(0x0dde)
	jr	ule, MeasureInsert_StepFirstMeasure_Skip	; F7B676  jr ULE,0xf7b680
	ld	(3550:16), wa	; F7B678  ld (0x0dde),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7B67C  ld (0x12f9),WA
MeasureInsert_StepFirstMeasure_Skip:
	ld	(3548:16), wa	; F7B680  ld (0x0ddc),WA
	ld	wa, (3550:16)	; F7B684  ld WA,(0x0dde)
	sub	wa, (0x0ddc:16)	; F7B688  sub WA,(0x0ddc)
	inc	1, wa	; F7B68C  inc 1,WA
	ld	(6304874:24), wa	; F7B68E  ld (0x60346a),WA
	ret	; F7B693  ret

; --------------------------------------------------------------------------
; MeasureInsert_StepLastMeasure
; Called from: in-module: 0xF7B565 0xF7B5BD
; Touches: (0x0C18) (0x0DDC) (0x0DDE) (0x12F7) (0x12F9)
; Calls:   SeqJob_StepMeasure
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7B694 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_StepLastMeasure: field 3 of the page; steps with SeqJob_StepMeasure.
MeasureInsert_StepLastMeasure:
	ld	wa, (3550:16)	; F7B694  ld WA,(0x0dde)
	calr	SeqJob_StepMeasure	; F7B698  calr 0xf7cd5f
	ld	(3550:16), wa	; F7B69B  ld (0x0dde),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7B69F  ld (0x12f9),WA
	cp	wa, (0x0ddc:16)	; F7B6A3  cp WA,(0x0ddc)
	jr	nc, MeasureInsert_StepLastMeasure_Skip	; F7B6A7  jr NC,0xf7b6ba
	ld	(3548:16), wa	; F7B6A9  ld (0x0ddc),WA
	ld	(3096:16), wa	; F7B6AD  ld (0x0c18),WA
	ld	(6304872:24), wa	; F7B6B1  ld (0x603468),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7B6B6  ld (0x12f7),WA
MeasureInsert_StepLastMeasure_Skip:
	ld	(3550:16), wa	; F7B6BA  ld (0x0dde),WA
	ld	wa, (3550:16)	; F7B6BE  ld WA,(0x0dde)
	sub	wa, (0x0ddc:16)	; F7B6C2  sub WA,(0x0ddc)
	inc	1, wa	; F7B6C6  inc 1,WA
	ld	(6304874:24), wa	; F7B6C8  ld (0x60346a),WA
	ret	; F7B6CD  ret

; --------------------------------------------------------------------------
; MeasureInsert_StepToTrack
; Called from: in-module: 0xF7B571 0xF7B5C9
; Touches: (0x0C13) (0x0C14) (0x0C35) (0x0DDB) (0x0DE0) (0x12F6) (0x12FB)
; Calls:   SeqJob_StepTrack
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7B6CE is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_StepToTrack: field 4 of the page; steps with SeqJob_StepTrack.
MeasureInsert_StepToTrack:
	ld	a, (3092:16)	; F7B6CE  ld A,(0x0c14)
	ld	l, 1:opc	; F7B6D2  ld L,0x01
	ld	h, 18:opc	; F7B6D4  ld H,0x12
	calr	SeqJob_StepTrack	; F7B6D6  calr 0xf7cd30
	cp	a, 18	; F7B6D9  cp A,0x12
	jr	z, MeasureInsert_StepToTrack_Skip2	; F7B6DC  jr Z,0xf7b70f
	bit	2, (0x0c35:16)	; F7B6DE  bit 2,(0x0c35)
	jr	z, MeasureInsert_StepToTrack_Skip	; F7B6E2  jr Z,0xf7b6f7
	ld	l, a	; F7B6E4  ld L,A
	ld	(3547:16), l	; F7B6E6  ld (0x0ddb),L
	ld	(3091:16), l	; F7B6EA  ld (0x0c13),L
	ld	(6304871:24), l	; F7B6EE  ld (0x603467),L
	ld	(DisplayListB_Stage:16), l	; F7B6F3  ld (0x12f6),L
MeasureInsert_StepToTrack_Skip:
	ld	(3092:16), a	; F7B6F7  ld (0x0c14),A
	ld	(6304876:24), a	; F7B6FB  ld (0x60346c),A
	ld	(3552:16), a	; F7B700  ld (0x0de0),A
	ld	(DisplayListB_Stage+5:16), a	; F7B704  ld (0x12fb),A
	and	(0x0c35:16), 0xfb	; F7B708  and (0x0c35),0xfb
	jr	MeasureInsert_StepToTrack_Return	; F7B70D  jr T,0xf7b736
MeasureInsert_StepToTrack_Skip2:
	ld	(3552:16), a	; F7B70F  ld (0x0de0),A
	ld	(3092:16), a	; F7B713  ld (0x0c14),A
	ld	(6304876:24), a	; F7B717  ld (0x60346c),A
	ld	(DisplayListB_Stage+5:16), a	; F7B71C  ld (0x12fb),A
	ld	(3547:16), a	; F7B720  ld (0x0ddb),A
	ld	(3091:16), a	; F7B724  ld (0x0c13),A
	ld	(6304871:24), a	; F7B728  ld (0x603467),A
	ld	(DisplayListB_Stage:16), a	; F7B72D  ld (0x12f6),A
	or	(0x0c35:16), 0x04	; F7B731  or (0x0c35),0x04
MeasureInsert_StepToTrack_Return:
	ret	; F7B736  ret

; --------------------------------------------------------------------------
; MeasureInsert_StepStartMeasure
; Called from: in-module: 0xF7B57D 0xF7B5D5
; Touches: (0x0C1A) (0x12FC)
; Calls:   SeqJob_StepMeasure
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7B737 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_StepStartMeasure: field 5 of the page; steps with SeqJob_StepMeasure.
MeasureInsert_StepStartMeasure:
	ld	wa, (3098:16)	; F7B737  ld WA,(0x0c1a)
	calr	SeqJob_StepMeasure	; F7B73B  calr 0xf7cd5f
	ld	(3098:16), wa	; F7B73E  ld (0x0c1a),WA
	ld	(6304877:24), wa	; F7B742  ld (0x60346d),WA
	ld	(DisplayListB_Stage+6:16), wa	; F7B747  ld (0x12fc),WA
	ret	; F7B74B  ret

; --------------------------------------------------------------------------
; MeasureInsert_StepRepeat
; Called from: in-module: 0xF7B587 0xF7B5DF
; Touches: (0x0E17) (0x12FE)
; Calls:   SeqJob_StepValueInRange
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7B74C is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_StepRepeat: field 6 of the page; steps with SeqJob_StepValueInRange, 0..127.
MeasureInsert_StepRepeat:
	ld	a, (3607:16)	; F7B74C  ld A,(0x0e17)
	ld	l, 0:opc	; F7B750  ld L,0x00
	ld	h, 127:opc	; F7B752  ld H,0x7f
	call	SeqJob_StepValueInRange	; F7B754  call 0xf7ccdb
	ld	(3607:16), a	; F7B758  ld (0x0e17),A
	ld	(DisplayListB_Stage+8:16), a	; F7B75C  ld (0x12fe),A
	ret	; F7B760  ret

; --------------------------------------------------------------------------
; MeasureInsert_ReturnToStageZero
; Called from: T_MeasureInsert_ReturnToStageZero (x2)
; Touches: (0x2071) (0x2075) (0x207E)
; Evidence: thunk slot T_MeasureInsert_ReturnToStageZero holds `jp 0x00F7B761`, and 0xF7B761 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_ReturnToStageZero: UI_ScreenStage = 0 and UI_Request_Hi |= 0x10 -- back to stage 0 of MeasureInsert_StageNonZero;
;   called by ExitKey_MeasureInsert_StageNonZero, LcdKeyRow5_MeasureInsert_StageNonZero (notes/prom_ab_stage_zero_names.py).
MeasureInsert_ReturnToStageZero:		; <- T_MeasureInsert_ReturnToStageZero
	and	(UI_RequestBits:16), 0xf6	; F7B761  and (0x2075),0xf6
	ld	(UI_ScreenStage:16), 0	; F7B766  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7B76B  or (0x2071),0x10
	ret	; F7B770  ret

; --------------------------------------------------------------------------
; MeasureInsert_LcdKeyRow1
; Called from: T_MeasureInsert_LcdKeyRow1 (x2)
; Touches: (0x0C13) (0x0C14) (0x0C18) (0x0C1A) (0x0C1C) (0x0C35) (0x0C70)
;          (0x0C71) (0x0C73) (0x0C75) +11 more
; Calls:   T_MeasureInsert_Execute MeasureInsert_RepeatInsert
; Evidence: thunk slot T_MeasureInsert_LcdKeyRow1 holds `jp 0x00F7B771`, and 0xF7B771 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_LcdKeyRow1: the LcdKeyRow1 action of MeasureInsert_StageNonZero, MeasureInsert_StageZero -- called only by LcdKeyRow1_MeasureInsert_StageNonZero, LcdKeyRow1_MeasureInsert_StageZero.
MeasureInsert_LcdKeyRow1:		; <- T_MeasureInsert_LcdKeyRow1
	and	(UI_RequestBits:16), 0xf6	; F7B771  and (0x2075),0xf6
	cp	(UI_ScreenStage:16), 0x01	; F7B776  cp (0x207e),0x01
	jr	z, MeasureInsert_LcdKeyRow1_Skip	; F7B77B  jr Z,0xf7b78a
	ld	(UI_ScreenStage:16), 1	; F7B77D  ld (0x207e),0x01
	or	(UI_Request_Hi:16), 0x10	; F7B782  or (0x2071),0x10
	jrl	sub_F7B74C_Return	; F7B787  jrl T,0xf7b851
MeasureInsert_LcdKeyRow1_Skip:
	ld	wa, (3096:16)	; F7B78A  ld WA,(0x0c18)
	ld	(3187:16), wa	; F7B78E  ld (0x0c73),WA
	ld	wa, (3098:16)	; F7B792  ld WA,(0x0c1a)
	ld	(3189:16), wa	; F7B796  ld (0x0c75),WA
	ld	wa, (3550:16)	; F7B79A  ld WA,(0x0dde)
	sub	wa, (0x0ddc:16)	; F7B79E  sub WA,(0x0ddc)
	inc	1, wa	; F7B7A2  inc 1,WA
	ld	(3100:16), wa	; F7B7A4  ld (0x0c1c),WA
	ld	(3191:16), wa	; F7B7A8  ld (0x0c77),WA
	ld	a, (3092:16)	; F7B7AC  ld A,(0x0c14)
	ld	(3185:16), a	; F7B7B0  ld (0x0c71),A
	ld	(3184:16), 127	; F7B7B4  ld (0x0c70),0x7f
	bit	2, (0x0c35:16)	; F7B7B9  bit 2,(0x0c35)
	jr	nz, MeasureInsert_LcdKeyRow1_Skip2	; F7B7BD  jr NZ,0xf7b7c7
	ld	a, (3091:16)	; F7B7BF  ld A,(0x0c13)
	ld	(3184:16), a	; F7B7C3  ld (0x0c70),A
MeasureInsert_LcdKeyRow1_Skip2:
	ld	(UI_StatusCode:16), 255	; F7B7C7  ld (0x2880),0xff
	ld	(BStore_ErrorCode:16), 0	; F7B7CC  ld (0x0d4a),0x00
	call	T_MeasureInsert_Execute	; F7B7D1  call 0xf426f4
	cp	(UI_StatusCode:16), 0xff	; F7B7D5  cp (0x2880),0xff
	jr	z, sub_F7B74C_Skip7	; F7B7DA  jr Z,0xf7b847
	cp	(UI_StatusCode:16), 0x23	; F7B7DC  cp (0x2880),0x23
	jr	nz, MeasureInsert_LcdKeyRow1_Skip3	; F7B7E1  jr NZ,0xf7b7ee
	call	MeasureInsert_RepeatInsert	; F7B7E3  call 0xf7cda0
	cp	(UI_StatusCode:16), 0xff	; F7B7E7  cp (0x2880),0xff
	jr	z, sub_F7B74C_Skip7	; F7B7EC  jr Z,0xf7b847
MeasureInsert_LcdKeyRow1_Skip3:
	ldw	(UI_Request:16), 16555	; F7B7EE  ld (0x2070),0x40ab
	ld	(UI_ScreenStage:16), 0	; F7B7F4  ld (0x207e),0x00
	cp	(UI_StatusCode:16), 0x23	; F7B7F9  cp (0x2880),0x23
	jr	nz, sub_F7B74C_Return	; F7B7FE  jr NZ,0xf7b851
	cp	(0x0c70:16), 0x7f	; F7B800  cp (0x0c70),0x7f
	jr	nz, MeasureInsert_LcdKeyRow1_Skip4	; F7B805  jr NZ,0xf7b80f
	ldw	(12304:16), 65535	; F7B807  ld (0x3010),0xffff
	jr	sub_F7B74C_Return	; F7B80D  jr T,0xf7b851
MeasureInsert_LcdKeyRow1_Skip4:
	ld	c, (3185:16)	; F7B80F  ld C,(0x0c71)
	dec	1, c	; F7B813  dec 1,C
	ldfr_berp	a, 0x3c	; F7B815  ld RL3,A
	ldfr_werp	de, 0x3e	; F7B818  ld QHL3,DE
	ld	de, (12304:16)	; F7B81B  ld DE,(0x3010)
	ld	a, c	; F7B81F  ld A,C
	cp	a, 16	; F7B821  cp A,0x10
	jr	lt, MeasureInsert_LcdKeyRow1_Skip5	; F7B824  jr LT,0xf7b82d
	ld	de, (12306:16)	; F7B826  ld DE,(0x3012)
	sub	a, 16	; F7B82A  sub A,0x10
MeasureInsert_LcdKeyRow1_Skip5:
	scf	; F7B82D  scf
	stcf_a_16	de	; F7B82E  stcf A,DE
	ldto_berp	a, 0x3c	; F7B830  ld A,RL3
	cp	c, 16	; F7B833  cp C,0x10
	jr	lt, MeasureInsert_LcdKeyRow1_Skip6	; F7B836  jr LT,0xf7b83e
	ld	(12306:16), de	; F7B838  ld (0x3012),DE
	jr	sub_F7B74C_Entry	; F7B83C  jr T,0xf7b842
MeasureInsert_LcdKeyRow1_Skip6:
	ld	(12304:16), de	; F7B83E  ld (0x3010),DE
sub_F7B74C_Entry:
	ldto_werp	de, 0x3e	; F7B842  ld DE,QHL3
	jr	sub_F7B74C_Return	; F7B845  jr T,0xf7b851
sub_F7B74C_Skip7:
	ld	(UI_ScreenStage:16), 0	; F7B847  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7B84C  or (0x2071),0x10
sub_F7B74C_Return:
	ret	; F7B851  ret

; --------------------------------------------------------------------------
; MeasureInsert_LoadSavedFields
; Called from: in-module: 0xF7B4BF
; Touches: (0x0C13) (0x0C14) (0x0C18) (0x0C1A) (0x0C1C) (0x0C35) (0x0DDB)
;          (0x0DDC) (0x0DDE) (0x0DE0) +7 more
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7B852 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_LoadSavedFields: copies the job's saved fields from battery RAM 0x6034xx into the working cells and the display stage.
MeasureInsert_LoadSavedFields:
	ld	a, (6304871:24)	; F7B852  ld A,(0x603467)
	cp	a, 127	; F7B857  cp A,0x7f
	jr	nz, MeasureInsert_LoadSavedFields_Skip	; F7B85A  jr NZ,0xf7b860
	set	2, (0x0c35:16)	; F7B85C  set 2,(0x0c35)
MeasureInsert_LoadSavedFields_Skip:
	ld	(3091:16), a	; F7B860  ld (0x0c13),A
	ld	(3547:16), a	; F7B864  ld (0x0ddb),A
	ld	(DisplayListB_Stage:16), a	; F7B868  ld (0x12f6),A
	ld	wa, (6304872:24)	; F7B86C  ld WA,(0x603468)
	ld	(3096:16), wa	; F7B871  ld (0x0c18),WA
	ld	(3548:16), wa	; F7B875  ld (0x0ddc),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7B879  ld (0x12f7),WA
	ld	wa, (6304874:24)	; F7B87D  ld WA,(0x60346a)
	dec	1, wa	; F7B882  dec 1,WA
	add	wa, (6304872:24)	; F7B884  add WA,(0x603468)
	ld	(3550:16), wa	; F7B889  ld (0x0dde),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7B88D  ld (0x12f9),WA
	ld	wa, (3550:16)	; F7B891  ld WA,(0x0dde)
	sub	wa, (0x0ddc:16)	; F7B895  sub WA,(0x0ddc)
	inc	1, wa	; F7B899  inc 1,WA
	ld	(6304874:24), wa	; F7B89B  ld (0x60346a),WA
	ld	(3100:16), wa	; F7B8A0  ld (0x0c1c),WA
	ld	a, (6304876:24)	; F7B8A4  ld A,(0x60346c)
	ld	(3092:16), a	; F7B8A9  ld (0x0c14),A
	ld	(3552:16), a	; F7B8AD  ld (0x0de0),A
	ld	(DisplayListB_Stage+5:16), a	; F7B8B1  ld (0x12fb),A
	ld	wa, (6304877:24)	; F7B8B5  ld WA,(0x60346d)
	ld	(3098:16), wa	; F7B8BA  ld (0x0c1a),WA
	ld	(DisplayListB_Stage+6:16), wa	; F7B8BE  ld (0x12fc),WA
	ld	a, (3607:16)	; F7B8C2  ld A,(0x0e17)
	ld	(DisplayListB_Stage+8:16), a	; F7B8C6  ld (0x12fe),A
	and	(0x0c35:16), 0xfb	; F7B8CA  and (0x0c35),0xfb
	cp	(0x0c13:16), 0x12	; F7B8CF  cp (0x0c13),0x12
	jr	nz, MeasureInsert_LoadSavedFields_Return	; F7B8D4  jr NZ,0xf7b8db
	or	(0x0c35:16), 0x04	; F7B8D6  or (0x0c35),0x04
MeasureInsert_LoadSavedFields_Return:
	ret	; F7B8DB  ret

; --------------------------------------------------------------------------
; MeasureC0py_InitFields
; Called from: T_MeasureC0py_InitFields (x1)
; Touches: (0x0DBC) (0x12FF)
; Calls:   MeasureC0py_LoadSavedFields
; Evidence: thunk slot T_MeasureC0py_InitFields holds `jp 0x00F7B8DC`, and 0xF7B8DC is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_InitFields: Paint_MeasureC0py's stage-0 init (thunk T_MeasureC0py_InitFields): MeasureC0py_LoadSavedFields, MeasureC0py_Field = 1.  MEASURE C0PY: the same six fields
MeasureC0py_InitFields:		; <- T_MeasureC0py_InitFields
	calr	MeasureC0py_LoadSavedFields	; F7B8DC  calr 0xf7bc73
	ld	a, 1:opc	; F7B8DF  ld A,0x01
	ld	(MeasureC0py_Field:16), a	; F7B8E1  ld (0x0dbc),A
	ld	(DisplayListB_Stage+9:16), a	; F7B8E5  ld (0x12ff),A
	ret	; F7B8E9  ret

; --------------------------------------------------------------------------
; MeasureC0py_OnLeave
; Called from: T_MeasureC0py_OnLeave (x1)
; Touches: (0x207A) (0x3010) (0x360C)
; Calls:   T_Seq_RequestRewind
; Evidence: thunk slot T_MeasureC0py_OnLeave holds `jp 0x00F7B8EA`, and 0xF7B8EA is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_OnLeave: the LEAVE work of MeasureC0py -- the one unnamed routine ScreenLeaveBody_MeasureC0py calls, and nothing else calls it
;   (notes/prom_ab_screen_enter_leave_work.py).
MeasureC0py_OnLeave:		; <- T_MeasureC0py_OnLeave
	cp	(UI_ScreenLatch:16), 0x21	; F7B8EA  cp (0x207a),0x21
	jr	z, MeasureC0py_OnLeave_Return2	; F7B8EF  jr Z,0xf7b908
	ld	xwa, (12304:16)	; F7B8F1  ld XWA,(0x3010)
	or	(0x360c:16), xwa	; F7B8F5  or (0x360c),XWA
	ld	(6304798:24), xwa	; F7B8F9  ld (0x60341e),XWA
	xor	xwa, xwa	; F7B8FE  xor XWA,XWA
	ld	(12304:16), xwa	; F7B900  ld (0x3010),XWA
	call	T_Seq_RequestRewind	; F7B904  call 0xf409e0
MeasureC0py_OnLeave_Return2:
	ret	; F7B908  ret

; --------------------------------------------------------------------------
; MeasureC0py_SelectField1
; Called from: T_MeasureC0py_SelectField1 (x1)
; Touches: (0x0DBC) (0x2075)
; Evidence: thunk slot T_MeasureC0py_SelectField1 holds `jp 0x00F7B909`, and 0xF7B909 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_SelectField1: moves the MeasureC0py screen's cursor to field 1 -- stores 1 into MeasureC0py_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
MeasureC0py_SelectField1:		; <- T_MeasureC0py_SelectField1
	ld	(MeasureC0py_Field:16), 1	; F7B909  ld (0x0dbc),0x01
	or	(UI_RequestBits:16), 0x09	; F7B90E  or (0x2075),0x09
	ret	; F7B913  ret

; --------------------------------------------------------------------------
; MeasureC0py_SelectField2
; Called from: T_MeasureC0py_SelectField2 (x1)
; Touches: (0x0DBC) (0x2075)
; Evidence: thunk slot T_MeasureC0py_SelectField2 holds `jp 0x00F7B914`, and 0xF7B914 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_SelectField2: moves the MeasureC0py screen's cursor to field 2 -- stores 2 into MeasureC0py_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
MeasureC0py_SelectField2:		; <- T_MeasureC0py_SelectField2
	ld	(MeasureC0py_Field:16), 2	; F7B914  ld (0x0dbc),0x02
	or	(UI_RequestBits:16), 0x08	; F7B919  or (0x2075),0x08
	or	(UI_RequestBits:16), 0x01	; F7B91E  or (0x2075),0x01
	ret	; F7B923  ret

; --------------------------------------------------------------------------
; MeasureC0py_SelectField3
; Called from: T_MeasureC0py_SelectField3 (x1)
; Touches: (0x0DBC) (0x2075)
; Evidence: thunk slot T_MeasureC0py_SelectField3 holds `jp 0x00F7B924`, and 0xF7B924 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_SelectField3: moves the MeasureC0py screen's cursor to field 3 -- stores 3 into MeasureC0py_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
MeasureC0py_SelectField3:		; <- T_MeasureC0py_SelectField3
	ld	(MeasureC0py_Field:16), 3	; F7B924  ld (0x0dbc),0x03
	or	(UI_RequestBits:16), 0x08	; F7B929  or (0x2075),0x08
	or	(UI_RequestBits:16), 0x01	; F7B92E  or (0x2075),0x01
	ret	; F7B933  ret

; --------------------------------------------------------------------------
; MeasureC0py_SelectField4
; Called from: T_MeasureC0py_SelectField4 (x1)
; Touches: (0x0DBC) (0x2075)
; Evidence: thunk slot T_MeasureC0py_SelectField4 holds `jp 0x00F7B934`, and 0xF7B934 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_SelectField4: moves the MeasureC0py screen's cursor to field 4 -- stores 4 into MeasureC0py_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
MeasureC0py_SelectField4:		; <- T_MeasureC0py_SelectField4
	ld	(MeasureC0py_Field:16), 4	; F7B934  ld (0x0dbc),0x04
	or	(UI_RequestBits:16), 0x09	; F7B939  or (0x2075),0x09
	ret	; F7B93E  ret

; --------------------------------------------------------------------------
; MeasureC0py_SelectField5
; Called from: T_MeasureC0py_SelectField5 (x1)
; Touches: (0x0DBC) (0x2075)
; Evidence: thunk slot T_MeasureC0py_SelectField5 holds `jp 0x00F7B93F`, and 0xF7B93F is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_SelectField5: moves the MeasureC0py screen's cursor to field 5 -- stores 5 into MeasureC0py_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
MeasureC0py_SelectField5:		; <- T_MeasureC0py_SelectField5
	ld	(MeasureC0py_Field:16), 5	; F7B93F  ld (0x0dbc),0x05
	or	(UI_RequestBits:16), 0x08	; F7B944  or (0x2075),0x08
	or	(UI_RequestBits:16), 0x01	; F7B949  or (0x2075),0x01
	ret	; F7B94E  ret

; --------------------------------------------------------------------------
; MeasureC0py_SelectField6
; Called from: T_MeasureC0py_SelectField6 (x1)
; Touches: (0x0DBC) (0x2075)
; Evidence: thunk slot T_MeasureC0py_SelectField6 holds `jp 0x00F7B94F`, and 0xF7B94F is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_SelectField6: moves the MeasureC0py screen's cursor to field 6 -- stores 6 into MeasureC0py_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
MeasureC0py_SelectField6:		; <- T_MeasureC0py_SelectField6
	ld	(MeasureC0py_Field:16), 6	; F7B94F  ld (0x0dbc),0x06
	or	(UI_RequestBits:16), 0x09	; F7B954  or (0x2075),0x09
	ret	; F7B959  ret

; --------------------------------------------------------------------------
; MeasureC0py_StepFieldUp
; Called from: T_MeasureC0py_StepFieldUp (x2)
; Touches: (0x0C4E) (0x0C4F) (0x0DBC)
; Calls:   MeasureC0py_StepFromTrack MeasureC0py_StepFirstMeasure MeasureC0py_StepLastMeasure MeasureC0py_StepToTrack MeasureC0py_StepStartMeasure MeasureC0py_StepRepeat
; Evidence: thunk slot T_MeasureC0py_StepFieldUp holds `jp 0x00F7B95A`, and 0xF7B95A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_StepFieldUp: (0x0C4E) = W, (0x0C4F) = 0 (up), then field MeasureC0py_Field 1..6 -> MeasureC0py_StepFromTrack / MeasureC0py_StepFirstMeasure / MeasureC0py_StepLastMeasure / MeasureC0py_StepToTrack / MeasureC0py_StepStartMeasure / MeasureC0py_StepRepeat.  (field order: the page text, checked against each stepper's helper; notes/prom_b_seqjob_field_names.py for the pattern)
MeasureC0py_StepFieldUp:		; <- T_MeasureC0py_StepFieldUp
	ld	(3150:16), w	; F7B95A  ld (0x0c4e),W
	ld	(3151:16), 0	; F7B95E  ld (0x0c4f),0x00
	cp	(MeasureC0py_Field:16), 0x01	; F7B963  cp (0x0dbc),0x01
	jr	nz, MeasureC0py_StepFieldUp_Skip2	; F7B968  jr NZ,0xf7b96f
	calr	MeasureC0py_StepFromTrack	; F7B96A  calr 0xf7ba16
	jr	MeasureC0py_StepFieldUp_Return3	; F7B96D  jr T,0xf7b9aa
MeasureC0py_StepFieldUp_Skip2:
	cp	(MeasureC0py_Field:16), 0x02	; F7B96F  cp (0x0dbc),0x02
	jr	nz, MeasureC0py_StepFieldUp_Skip3	; F7B974  jr NZ,0xf7b97b
	calr	MeasureC0py_StepFirstMeasure	; F7B976  calr 0xf7ba7f
	jr	MeasureC0py_StepFieldUp_Return3	; F7B979  jr T,0xf7b9aa
MeasureC0py_StepFieldUp_Skip3:
	cp	(MeasureC0py_Field:16), 0x03	; F7B97B  cp (0x0dbc),0x03
	jr	nz, MeasureC0py_StepFieldUp_Skip4	; F7B980  jr NZ,0xf7b987
	calr	MeasureC0py_StepLastMeasure	; F7B982  calr 0xf7bab5
	jr	MeasureC0py_StepFieldUp_Return3	; F7B985  jr T,0xf7b9aa
MeasureC0py_StepFieldUp_Skip4:
	cp	(MeasureC0py_Field:16), 0x04	; F7B987  cp (0x0dbc),0x04
	jr	nz, MeasureC0py_StepFieldUp_Skip5	; F7B98C  jr NZ,0xf7b993
	calr	MeasureC0py_StepToTrack	; F7B98E  calr 0xf7baef
	jr	MeasureC0py_StepFieldUp_Return3	; F7B991  jr T,0xf7b9aa
MeasureC0py_StepFieldUp_Skip5:
	cp	(MeasureC0py_Field:16), 0x05	; F7B993  cp (0x0dbc),0x05
	jr	nz, MeasureC0py_StepFieldUp_Skip6	; F7B998  jr NZ,0xf7b99f
	calr	MeasureC0py_StepStartMeasure	; F7B99A  calr 0xf7bb58
	jr	MeasureC0py_StepFieldUp_Return3	; F7B99D  jr T,0xf7b9aa
MeasureC0py_StepFieldUp_Skip6:
	cp	(MeasureC0py_Field:16), 0x06	; F7B99F  cp (0x0dbc),0x06
	jr	nz, MeasureC0py_StepFieldUp_Return3	; F7B9A4  jr NZ,0xf7b9aa
	call	MeasureC0py_StepRepeat	; F7B9A6  call 0xf7bb6d
MeasureC0py_StepFieldUp_Return3:
	ret	; F7B9AA  ret

; --------------------------------------------------------------------------
; MeasureC0py_StepFieldDown
; Called from: T_MeasureC0py_StepFieldDown (x2)
; Touches: (0x0C4E) (0x0C4F) (0x0DBC) (0x2071) (0x2075) (0x207E)
; Calls:   MeasureC0py_StepFromTrack MeasureC0py_StepFirstMeasure MeasureC0py_StepLastMeasure MeasureC0py_StepToTrack MeasureC0py_StepStartMeasure MeasureC0py_StepRepeat
; Evidence: thunk slot T_MeasureC0py_StepFieldDown holds `jp 0x00F7B9AB`, and 0xF7B9AB is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_StepFieldDown: the same with (0x0C4F) = 0x80 (down).
MeasureC0py_StepFieldDown:		; <- T_MeasureC0py_StepFieldDown
	cp	(UI_ScreenStage:16), 0x01	; F7B9AB  cp (0x207e),0x01
	jr	nz, MeasureC0py_StepFieldDown_Skip7	; F7B9B0  jr NZ,0xf7b9b4
	jr	MeasureC0py_StepFieldDown_Join	; F7B9B2  jr T,0xf7ba05
MeasureC0py_StepFieldDown_Skip7:
	ld	(3150:16), w	; F7B9B4  ld (0x0c4e),W
	ld	(3151:16), 128	; F7B9B8  ld (0x0c4f),0x80
	cp	(MeasureC0py_Field:16), 0x01	; F7B9BD  cp (0x0dbc),0x01
	jr	nz, MeasureC0py_StepFieldDown_Skip8	; F7B9C2  jr NZ,0xf7b9c9
	calr	MeasureC0py_StepFromTrack	; F7B9C4  calr 0xf7ba16
	jr	MeasureC0py_StepFieldDown_Return4	; F7B9C7  jr T,0xf7ba04
MeasureC0py_StepFieldDown_Skip8:
	cp	(MeasureC0py_Field:16), 0x02	; F7B9C9  cp (0x0dbc),0x02
	jr	nz, MeasureC0py_StepFieldDown_Skip9	; F7B9CE  jr NZ,0xf7b9d5
	calr	MeasureC0py_StepFirstMeasure	; F7B9D0  calr 0xf7ba7f
	jr	MeasureC0py_StepFieldDown_Return4	; F7B9D3  jr T,0xf7ba04
MeasureC0py_StepFieldDown_Skip9:
	cp	(MeasureC0py_Field:16), 0x03	; F7B9D5  cp (0x0dbc),0x03
	jr	nz, MeasureC0py_StepFieldDown_Skip10	; F7B9DA  jr NZ,0xf7b9e1
	calr	MeasureC0py_StepLastMeasure	; F7B9DC  calr 0xf7bab5
	jr	MeasureC0py_StepFieldDown_Return4	; F7B9DF  jr T,0xf7ba04
MeasureC0py_StepFieldDown_Skip10:
	cp	(MeasureC0py_Field:16), 0x04	; F7B9E1  cp (0x0dbc),0x04
	jr	nz, MeasureC0py_StepFieldDown_Skip11	; F7B9E6  jr NZ,0xf7b9ed
	calr	MeasureC0py_StepToTrack	; F7B9E8  calr 0xf7baef
	jr	MeasureC0py_StepFieldDown_Return4	; F7B9EB  jr T,0xf7ba04
MeasureC0py_StepFieldDown_Skip11:
	cp	(MeasureC0py_Field:16), 0x05	; F7B9ED  cp (0x0dbc),0x05
	jr	nz, MeasureC0py_StepFieldDown_Skip12	; F7B9F2  jr NZ,0xf7b9f9
	calr	MeasureC0py_StepStartMeasure	; F7B9F4  calr 0xf7bb58
	jr	MeasureC0py_StepFieldDown_Return4	; F7B9F7  jr T,0xf7ba04
MeasureC0py_StepFieldDown_Skip12:
	cp	(MeasureC0py_Field:16), 0x06	; F7B9F9  cp (0x0dbc),0x06
	jr	nz, MeasureC0py_StepFieldDown_Return4	; F7B9FE  jr NZ,0xf7ba04
	call	MeasureC0py_StepRepeat	; F7BA00  call 0xf7bb6d
MeasureC0py_StepFieldDown_Return4:
	ret	; F7BA04  ret
MeasureC0py_StepFieldDown_Join:
	and	(UI_RequestBits:16), 0xf6	; F7BA05  and (0x2075),0xf6
	ld	(UI_ScreenStage:16), 0	; F7BA0A  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7BA0F  or (0x2071),0x10
	jr	MeasureC0py_StepFieldDown_Return4	; F7BA14  jr T,0xf7ba04

; --------------------------------------------------------------------------
; MeasureC0py_StepFromTrack
; Called from: in-module: 0xF7B96A 0xF7B9C4
; Touches: (0x0C13) (0x0C14) (0x0C2F) (0x0C34) (0x0C35) (0x12F6) (0x12FB)
; Calls:   SeqJob_StepTrack
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7BA16 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_StepFromTrack: field 1 of the page; steps with SeqJob_StepTrack.
MeasureC0py_StepFromTrack:
	ld	a, (3091:16)	; F7BA16  ld A,(0x0c13)
	ld	l, 1:opc	; F7BA1A  ld L,0x01
	ld	h, 18:opc	; F7BA1C  ld H,0x12
	calr	SeqJob_StepTrack	; F7BA1E  calr 0xf7cd30
	cp	a, 18	; F7BA21  cp A,0x12
	jr	z, MeasureC0py_StepFromTrack_Skip2	; F7BA24  jr Z,0xf7ba57
	bit	3, (0x0c35:16)	; F7BA26  bit 3,(0x0c35)
	jr	z, MeasureC0py_StepFromTrack_Skip	; F7BA2A  jr Z,0xf7ba3f
	ld	l, a	; F7BA2C  ld L,A
	ld	(3124:16), l	; F7BA2E  ld (0x0c34),L
	ld	(3092:16), l	; F7BA32  ld (0x0c14),L
	ld	(6304884:24), l	; F7BA36  ld (0x603474),L
	ld	(DisplayListB_Stage+5:16), a	; F7BA3B  ld (0x12fb),A
MeasureC0py_StepFromTrack_Skip:
	ld	(3091:16), a	; F7BA3F  ld (0x0c13),A
	ld	(6304879:24), a	; F7BA43  ld (0x60346f),A
	ld	(3119:16), a	; F7BA48  ld (0x0c2f),A
	ld	(DisplayListB_Stage:16), a	; F7BA4C  ld (0x12f6),A
	and	(0x0c35:16), 0xf7	; F7BA50  and (0x0c35),0xf7
	jr	MeasureC0py_StepFromTrack_Return	; F7BA55  jr T,0xf7ba7e
MeasureC0py_StepFromTrack_Skip2:
	ld	(3119:16), a	; F7BA57  ld (0x0c2f),A
	ld	(3091:16), a	; F7BA5B  ld (0x0c13),A
	ld	(6304879:24), a	; F7BA5F  ld (0x60346f),A
	ld	(DisplayListB_Stage:16), a	; F7BA64  ld (0x12f6),A
	ld	(3124:16), a	; F7BA68  ld (0x0c34),A
	ld	(3092:16), a	; F7BA6C  ld (0x0c14),A
	ld	(6304884:24), a	; F7BA70  ld (0x603474),A
	ld	(DisplayListB_Stage+5:16), a	; F7BA75  ld (0x12fb),A
	or	(0x0c35:16), 0x08	; F7BA79  or (0x0c35),0x08
MeasureC0py_StepFromTrack_Return:
	ret	; F7BA7E  ret

; --------------------------------------------------------------------------
; MeasureC0py_StepFirstMeasure
; Called from: in-module: 0xF7B976 0xF7B9D0
; Touches: (0x0C18) (0x0C30) (0x0C32) (0x12F7) (0x12F9)
; Calls:   SeqJob_StepMeasure
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7BA7F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_StepFirstMeasure: field 2 of the page; steps with SeqJob_StepMeasure.
MeasureC0py_StepFirstMeasure:
	ld	wa, (3096:16)	; F7BA7F  ld WA,(0x0c18)
	calr	SeqJob_StepMeasure	; F7BA83  calr 0xf7cd5f
	ld	(3096:16), wa	; F7BA86  ld (0x0c18),WA
	ld	(6304880:24), wa	; F7BA8A  ld (0x603470),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7BA8F  ld (0x12f7),WA
	cp	wa, (0x0c32:16)	; F7BA93  cp WA,(0x0c32)
	jr	ule, MeasureC0py_StepFirstMeasure_Skip	; F7BA97  jr ULE,0xf7baa1
	ld	(3122:16), wa	; F7BA99  ld (0x0c32),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7BA9D  ld (0x12f9),WA
MeasureC0py_StepFirstMeasure_Skip:
	ld	(3120:16), wa	; F7BAA1  ld (0x0c30),WA
	ld	wa, (3122:16)	; F7BAA5  ld WA,(0x0c32)
	sub	wa, (0x0c30:16)	; F7BAA9  sub WA,(0x0c30)
	inc	1, wa	; F7BAAD  inc 1,WA
	ld	(6304882:24), wa	; F7BAAF  ld (0x603472),WA
	ret	; F7BAB4  ret

; --------------------------------------------------------------------------
; MeasureC0py_StepLastMeasure
; Called from: in-module: 0xF7B982 0xF7B9DC
; Touches: (0x0C18) (0x0C30) (0x0C32) (0x12F7) (0x12F9)
; Calls:   SeqJob_StepMeasure
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7BAB5 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_StepLastMeasure: field 3 of the page; steps with SeqJob_StepMeasure.
MeasureC0py_StepLastMeasure:
	ld	wa, (3122:16)	; F7BAB5  ld WA,(0x0c32)
	calr	SeqJob_StepMeasure	; F7BAB9  calr 0xf7cd5f
	ld	(3122:16), wa	; F7BABC  ld (0x0c32),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7BAC0  ld (0x12f9),WA
	cp	wa, (0x0c30:16)	; F7BAC4  cp WA,(0x0c30)
	jr	nc, MeasureC0py_StepLastMeasure_Skip	; F7BAC8  jr NC,0xf7badb
	ld	(3120:16), wa	; F7BACA  ld (0x0c30),WA
	ld	(3096:16), wa	; F7BACE  ld (0x0c18),WA
	ld	(6304880:24), wa	; F7BAD2  ld (0x603470),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7BAD7  ld (0x12f7),WA
MeasureC0py_StepLastMeasure_Skip:
	ld	(3122:16), wa	; F7BADB  ld (0x0c32),WA
	ld	wa, (3122:16)	; F7BADF  ld WA,(0x0c32)
	sub	wa, (0x0c30:16)	; F7BAE3  sub WA,(0x0c30)
	inc	1, wa	; F7BAE7  inc 1,WA
	ld	(6304882:24), wa	; F7BAE9  ld (0x603472),WA
	ret	; F7BAEE  ret

; --------------------------------------------------------------------------
; MeasureC0py_StepToTrack
; Called from: in-module: 0xF7B98E 0xF7B9E8
; Touches: (0x0C13) (0x0C14) (0x0C2F) (0x0C34) (0x0C35) (0x12F6) (0x12FB)
; Calls:   SeqJob_StepTrack
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7BAEF is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_StepToTrack: field 4 of the page; steps with SeqJob_StepTrack.
MeasureC0py_StepToTrack:
	ld	a, (3092:16)	; F7BAEF  ld A,(0x0c14)
	ld	l, 1:opc	; F7BAF3  ld L,0x01
	ld	h, 18:opc	; F7BAF5  ld H,0x12
	calr	SeqJob_StepTrack	; F7BAF7  calr 0xf7cd30
	cp	a, 18	; F7BAFA  cp A,0x12
	jr	z, MeasureC0py_StepToTrack_Skip2	; F7BAFD  jr Z,0xf7bb30
	bit	3, (0x0c35:16)	; F7BAFF  bit 3,(0x0c35)
	jr	z, MeasureC0py_StepToTrack_Skip	; F7BB03  jr Z,0xf7bb18
	ld	l, a	; F7BB05  ld L,A
	ld	(3119:16), l	; F7BB07  ld (0x0c2f),L
	ld	(3091:16), l	; F7BB0B  ld (0x0c13),L
	ld	(6304879:24), l	; F7BB0F  ld (0x60346f),L
	ld	(DisplayListB_Stage:16), a	; F7BB14  ld (0x12f6),A
MeasureC0py_StepToTrack_Skip:
	ld	(3092:16), a	; F7BB18  ld (0x0c14),A
	ld	(6304884:24), a	; F7BB1C  ld (0x603474),A
	ld	(3124:16), a	; F7BB21  ld (0x0c34),A
	ld	(DisplayListB_Stage+5:16), a	; F7BB25  ld (0x12fb),A
	and	(0x0c35:16), 0xf7	; F7BB29  and (0x0c35),0xf7
	jr	MeasureC0py_StepToTrack_Return	; F7BB2E  jr T,0xf7bb57
MeasureC0py_StepToTrack_Skip2:
	ld	(3124:16), a	; F7BB30  ld (0x0c34),A
	ld	(3092:16), a	; F7BB34  ld (0x0c14),A
	ld	(6304884:24), a	; F7BB38  ld (0x603474),A
	ld	(DisplayListB_Stage+5:16), a	; F7BB3D  ld (0x12fb),A
	ld	(3119:16), a	; F7BB41  ld (0x0c2f),A
	ld	(3091:16), a	; F7BB45  ld (0x0c13),A
	ld	(6304879:24), a	; F7BB49  ld (0x60346f),A
	ld	(DisplayListB_Stage:16), a	; F7BB4E  ld (0x12f6),A
	or	(0x0c35:16), 0x08	; F7BB52  or (0x0c35),0x08
MeasureC0py_StepToTrack_Return:
	ret	; F7BB57  ret

; --------------------------------------------------------------------------
; MeasureC0py_StepStartMeasure
; Called from: in-module: 0xF7B99A 0xF7B9F4
; Touches: (0x0C1A) (0x12FC)
; Calls:   SeqJob_StepMeasure
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7BB58 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_StepStartMeasure: field 5 of the page; steps with SeqJob_StepMeasure.
MeasureC0py_StepStartMeasure:
	ld	wa, (3098:16)	; F7BB58  ld WA,(0x0c1a)
	calr	SeqJob_StepMeasure	; F7BB5C  calr 0xf7cd5f
	ld	(3098:16), wa	; F7BB5F  ld (0x0c1a),WA
	ld	(6304885:24), wa	; F7BB63  ld (0x603475),WA
	ld	(DisplayListB_Stage+6:16), wa	; F7BB68  ld (0x12fc),WA
	ret	; F7BB6C  ret

; --------------------------------------------------------------------------
; MeasureC0py_StepRepeat
; Called from: in-module: 0xF7B9A6 0xF7BA00
; Touches: (0x0E16) (0x12FE)
; Calls:   SeqJob_StepValueInRange
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7BB6D is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_StepRepeat: field 6 of the page; steps with SeqJob_StepValueInRange, 0..127.
MeasureC0py_StepRepeat:
	ld	a, (3606:16)	; F7BB6D  ld A,(0x0e16)
	ld	l, 0:opc	; F7BB71  ld L,0x00
	ld	h, 127:opc	; F7BB73  ld H,0x7f
	call	SeqJob_StepValueInRange	; F7BB75  call 0xf7ccdb
	ld	(3606:16), a	; F7BB79  ld (0x0e16),A
	ld	(DisplayListB_Stage+8:16), a	; F7BB7D  ld (0x12fe),A
	ret	; F7BB81  ret

; --------------------------------------------------------------------------
; MeasureC0py_ReturnToStageZero
; Called from: T_MeasureC0py_ReturnToStageZero (x2)
; Touches: (0x2071) (0x2075) (0x207E)
; Evidence: thunk slot T_MeasureC0py_ReturnToStageZero holds `jp 0x00F7BB82`, and 0xF7BB82 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_ReturnToStageZero: UI_ScreenStage = 0 and UI_Request_Hi |= 0x10 -- back to stage 0 of MeasureC0py_StageNonZero;
;   called by ExitKey_MeasureC0py_StageNonZero, LcdKeyRow5_MeasureC0py_StageNonZero (notes/prom_ab_stage_zero_names.py).
MeasureC0py_ReturnToStageZero:		; <- T_MeasureC0py_ReturnToStageZero
	and	(UI_RequestBits:16), 0xf6	; F7BB82  and (0x2075),0xf6
	ld	(UI_ScreenStage:16), 0	; F7BB87  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7BB8C  or (0x2071),0x10
	ret	; F7BB91  ret

; --------------------------------------------------------------------------
; MeasureC0py_LcdKeyRow1
; Called from: T_MeasureC0py_LcdKeyRow1 (x2)
; Touches: (0x0C13) (0x0C14) (0x0C18) (0x0C1A) (0x0C1C) (0x0C30) (0x0C32)
;          (0x0C35) (0x0C70) (0x0C71) +11 more
; Calls:   T_SongEdit_CopyMeasures MeasureC0py_RepeatCopy
; Evidence: thunk slot T_MeasureC0py_LcdKeyRow1 holds `jp 0x00F7BB92`, and 0xF7BB92 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_LcdKeyRow1: the LcdKeyRow1 action of MeasureC0py_StageNonZero, MeasureC0py_StageZero -- called only by LcdKeyRow1_MeasureC0py_StageNonZero, LcdKeyRow1_MeasureC0py_StageZero.
MeasureC0py_LcdKeyRow1:		; <- T_MeasureC0py_LcdKeyRow1
	and	(UI_RequestBits:16), 0xf6	; F7BB92  and (0x2075),0xf6
	cp	(UI_ScreenStage:16), 0x01	; F7BB97  cp (0x207e),0x01
	jr	z, MeasureC0py_LcdKeyRow1_Skip	; F7BB9C  jr Z,0xf7bbab
	ld	(UI_ScreenStage:16), 1	; F7BB9E  ld (0x207e),0x01
	or	(UI_Request_Hi:16), 0x10	; F7BBA3  or (0x2071),0x10
	jrl	sub_F7BB6D_Return	; F7BBA8  jrl T,0xf7bc72
MeasureC0py_LcdKeyRow1_Skip:
	ld	wa, (3096:16)	; F7BBAB  ld WA,(0x0c18)
	ld	(3187:16), wa	; F7BBAF  ld (0x0c73),WA
	ld	wa, (3098:16)	; F7BBB3  ld WA,(0x0c1a)
	ld	(3189:16), wa	; F7BBB7  ld (0x0c75),WA
	ld	wa, (3122:16)	; F7BBBB  ld WA,(0x0c32)
	sub	wa, (0x0c30:16)	; F7BBBF  sub WA,(0x0c30)
	inc	1, wa	; F7BBC3  inc 1,WA
	ld	(3100:16), wa	; F7BBC5  ld (0x0c1c),WA
	ld	(3191:16), wa	; F7BBC9  ld (0x0c77),WA
	ld	a, (3092:16)	; F7BBCD  ld A,(0x0c14)
	ld	(3185:16), a	; F7BBD1  ld (0x0c71),A
	ld	(3184:16), 127	; F7BBD5  ld (0x0c70),0x7f
	bit	3, (0x0c35:16)	; F7BBDA  bit 3,(0x0c35)
	jr	nz, MeasureC0py_LcdKeyRow1_Skip2	; F7BBDE  jr NZ,0xf7bbe8
	ld	a, (3091:16)	; F7BBE0  ld A,(0x0c13)
	ld	(3184:16), a	; F7BBE4  ld (0x0c70),A
MeasureC0py_LcdKeyRow1_Skip2:
	ld	(UI_StatusCode:16), 255	; F7BBE8  ld (0x2880),0xff
	ld	(BStore_ErrorCode:16), 0	; F7BBED  ld (0x0d4a),0x00
	call	T_SongEdit_CopyMeasures	; F7BBF2  call 0xf426f8
	cp	(UI_StatusCode:16), 0xff	; F7BBF6  cp (0x2880),0xff
	jr	z, sub_F7BB6D_Skip7	; F7BBFB  jr Z,0xf7bc68
	cp	(UI_StatusCode:16), 0x23	; F7BBFD  cp (0x2880),0x23
	jr	nz, MeasureC0py_LcdKeyRow1_Skip3	; F7BC02  jr NZ,0xf7bc0f
	call	MeasureC0py_RepeatCopy	; F7BC04  call 0xf7ce04
	cp	(UI_StatusCode:16), 0xff	; F7BC08  cp (0x2880),0xff
	jr	z, sub_F7BB6D_Skip7	; F7BC0D  jr Z,0xf7bc68
MeasureC0py_LcdKeyRow1_Skip3:
	ldw	(UI_Request:16), 16555	; F7BC0F  ld (0x2070),0x40ab
	ld	(UI_ScreenStage:16), 0	; F7BC15  ld (0x207e),0x00
	cp	(UI_StatusCode:16), 0x23	; F7BC1A  cp (0x2880),0x23
	jr	nz, sub_F7BB6D_Return	; F7BC1F  jr NZ,0xf7bc72
	cp	(0x0c70:16), 0x7f	; F7BC21  cp (0x0c70),0x7f
	jr	nz, MeasureC0py_LcdKeyRow1_Skip4	; F7BC26  jr NZ,0xf7bc30
	ldw	(12304:16), 65535	; F7BC28  ld (0x3010),0xffff
	jr	sub_F7BB6D_Return	; F7BC2E  jr T,0xf7bc72
MeasureC0py_LcdKeyRow1_Skip4:
	ld	c, (3185:16)	; F7BC30  ld C,(0x0c71)
	dec	1, c	; F7BC34  dec 1,C
	ldfr_berp	a, 0x3c	; F7BC36  ld RL3,A
	ldfr_werp	de, 0x3e	; F7BC39  ld QHL3,DE
	ld	de, (12304:16)	; F7BC3C  ld DE,(0x3010)
	ld	a, c	; F7BC40  ld A,C
	cp	a, 16	; F7BC42  cp A,0x10
	jr	lt, MeasureC0py_LcdKeyRow1_Skip5	; F7BC45  jr LT,0xf7bc4e
	ld	de, (12306:16)	; F7BC47  ld DE,(0x3012)
	sub	a, 16	; F7BC4B  sub A,0x10
MeasureC0py_LcdKeyRow1_Skip5:
	scf	; F7BC4E  scf
	stcf_a_16	de	; F7BC4F  stcf A,DE
	ldto_berp	a, 0x3c	; F7BC51  ld A,RL3
	cp	c, 16	; F7BC54  cp C,0x10
	jr	lt, MeasureC0py_LcdKeyRow1_Skip6	; F7BC57  jr LT,0xf7bc5f
	ld	(12306:16), de	; F7BC59  ld (0x3012),DE
	jr	sub_F7BB6D_Entry	; F7BC5D  jr T,0xf7bc63
MeasureC0py_LcdKeyRow1_Skip6:
	ld	(12304:16), de	; F7BC5F  ld (0x3010),DE
sub_F7BB6D_Entry:
	ldto_werp	de, 0x3e	; F7BC63  ld DE,QHL3
	jr	sub_F7BB6D_Return	; F7BC66  jr T,0xf7bc72
sub_F7BB6D_Skip7:
	ld	(UI_ScreenStage:16), 0	; F7BC68  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7BC6D  or (0x2071),0x10
sub_F7BB6D_Return:
	ret	; F7BC72  ret

; --------------------------------------------------------------------------
; MeasureC0py_LoadSavedFields
; Called from: in-module: 0xF7B8DC
; Touches: (0x0C13) (0x0C14) (0x0C18) (0x0C1A) (0x0C1C) (0x0C2F) (0x0C30)
;          (0x0C32) (0x0C34) (0x0C35) +7 more
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7BC73 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_LoadSavedFields: copies the job's saved fields from battery RAM 0x6034xx into the working cells and the display stage.
MeasureC0py_LoadSavedFields:
	ld	a, (6304879:24)	; F7BC73  ld A,(0x60346f)
	cp	a, 127	; F7BC78  cp A,0x7f
	jr	nz, MeasureC0py_LoadSavedFields_Skip	; F7BC7B  jr NZ,0xf7bc81
	set	3, (0x0c35:16)	; F7BC7D  set 3,(0x0c35)
MeasureC0py_LoadSavedFields_Skip:
	ld	(3091:16), a	; F7BC81  ld (0x0c13),A
	ld	(3119:16), a	; F7BC85  ld (0x0c2f),A
	ld	(DisplayListB_Stage:16), a	; F7BC89  ld (0x12f6),A
	ld	wa, (6304880:24)	; F7BC8D  ld WA,(0x603470)
	ld	(3096:16), wa	; F7BC92  ld (0x0c18),WA
	ld	(3120:16), wa	; F7BC96  ld (0x0c30),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7BC9A  ld (0x12f7),WA
	ld	wa, (6304882:24)	; F7BC9E  ld WA,(0x603472)
	dec	1, wa	; F7BCA3  dec 1,WA
	add	wa, (6304880:24)	; F7BCA5  add WA,(0x603470)
	ld	(3122:16), wa	; F7BCAA  ld (0x0c32),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7BCAE  ld (0x12f9),WA
	ld	wa, (3122:16)	; F7BCB2  ld WA,(0x0c32)
	sub	wa, (0x0c30:16)	; F7BCB6  sub WA,(0x0c30)
	inc	1, wa	; F7BCBA  inc 1,WA
	ld	(6304882:24), wa	; F7BCBC  ld (0x603472),WA
	ld	(3100:16), wa	; F7BCC1  ld (0x0c1c),WA
	ld	a, (6304884:24)	; F7BCC5  ld A,(0x603474)
	ld	(3092:16), a	; F7BCCA  ld (0x0c14),A
	ld	(3124:16), a	; F7BCCE  ld (0x0c34),A
	ld	(DisplayListB_Stage+5:16), a	; F7BCD2  ld (0x12fb),A
	ld	wa, (6304885:24)	; F7BCD6  ld WA,(0x603475)
	ld	(3098:16), wa	; F7BCDB  ld (0x0c1a),WA
	ld	(DisplayListB_Stage+6:16), wa	; F7BCDF  ld (0x12fc),WA
	ld	a, (3606:16)	; F7BCE3  ld A,(0x0e16)
	ld	(DisplayListB_Stage+8:16), a	; F7BCE7  ld (0x12fe),A
	and	(0x0c35:16), 0xf7	; F7BCEB  and (0x0c35),0xf7
	cp	(0x0c13:16), 0x12	; F7BCF0  cp (0x0c13),0x12
	jr	nz, MeasureC0py_LoadSavedFields_Return	; F7BCF5  jr NZ,0xf7bcfc
	or	(0x0c35:16), 0x08	; F7BCF7  or (0x0c35),0x08
MeasureC0py_LoadSavedFields_Return:
	ret	; F7BCFC  ret

; --------------------------------------------------------------------------
; Vel0cityChange_InitFields
; Called from: T_Vel0cityChange_InitFields (x1)
; Touches: (0x0C16) (0x0C1E) (0x0C24) (0x0DB8) (0x12FB) (0x12FC)
; Calls:   Vel0cityChange_LoadSavedFields
; Evidence: thunk slot T_Vel0cityChange_InitFields holds `jp 0x00F7BCFD`, and 0xF7BCFD is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_InitFields: Paint_Vel0cityChange's stage-0 init: Vel0cityChange_LoadSavedFields, field cursor (0x0db8) = 1 (notes/prom_b_seqjob_field_names.py)
Vel0cityChange_InitFields:		; <- T_Vel0cityChange_InitFields
	calr	Vel0cityChange_LoadSavedFields	; F7BCFD  calr 0xf7bf74
	ld	(3094:16), 0	; F7BD00  ld (0x0c16),0x00
	ld	(6304950:24), 0	; F7BD05  ld (0x6034b6),0x00
	xor	wa, wa	; F7BD0B  xor WA,WA
	ld	a, (3102:16)	; F7BD0D  ld A,(0x0c1e)
	ld	(3108:16), a	; F7BD11  ld (0x0c24),A
	ld	(DisplayListB_Stage+5:16), a	; F7BD15  ld (0x12fb),A
	ld	(3512:16), 1	; F7BD19  ld (0x0db8),0x01
	ld	(DisplayListB_Stage+6:16), 1	; F7BD1E  ld (0x12fc),0x01
	ret	; F7BD23  ret

; --------------------------------------------------------------------------
; Vel0cityChange_OnLeave
; Called from: T_Vel0cityChange_OnLeave (x1)
; Touches: (0x207A)
; Calls:   T_Seq_RequestRewind
; Evidence: thunk slot T_Vel0cityChange_OnLeave holds `jp 0x00F7BD24`, and 0xF7BD24 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_OnLeave: the LEAVE work of Vel0cityChange -- the one unnamed routine ScreenLeaveBody_Vel0cityChange calls, and nothing else calls it
;   (notes/prom_ab_screen_enter_leave_work.py).
Vel0cityChange_OnLeave:		; <- T_Vel0cityChange_OnLeave
	cp	(UI_ScreenLatch:16), 0x1d	; F7BD24  cp (0x207a),0x1d
	jr	z, Vel0cityChange_OnLeave_Return2	; F7BD29  jr Z,0xf7bd2f
	call	T_Seq_RequestRewind	; F7BD2B  call 0xf409e0
Vel0cityChange_OnLeave_Return2:
	ret	; F7BD2F  ret

; --------------------------------------------------------------------------
; Vel0cityChange_StageZero_LcdKeyRow1
; Called from: T_Vel0cityChange_StageZero_LcdKeyRow1 (x1)
; Touches: (0x0DB8) (0x12FC) (0x2075)
; Evidence: thunk slot T_Vel0cityChange_StageZero_LcdKeyRow1 holds `jp 0x00F7BD30`, and 0xF7BD30 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_StageZero_LcdKeyRow1: the LcdKeyRow1 action of Vel0cityChange_StageZero -- called only by LcdKeyRow1_Vel0cityChange_StageZero.
Vel0cityChange_StageZero_LcdKeyRow1:		; <- T_Vel0cityChange_StageZero_LcdKeyRow1
	ld	(3512:16), 1	; F7BD30  ld (0x0db8),0x01
	ld	(DisplayListB_Stage+6:16), 1	; F7BD35  ld (0x12fc),0x01
	or	(UI_RequestBits:16), 0x09	; F7BD3A  or (0x2075),0x09
	ret	; F7BD3F  ret

; --------------------------------------------------------------------------
; Vel0cityChange_StageZero_LcdKeyRow2
; Called from: T_Vel0cityChange_StageZero_LcdKeyRow2 (x1)
; Touches: (0x0DB8) (0x12FC) (0x2075)
; Evidence: thunk slot T_Vel0cityChange_StageZero_LcdKeyRow2 holds `jp 0x00F7BD40`, and 0xF7BD40 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_StageZero_LcdKeyRow2: the LcdKeyRow2 action of Vel0cityChange_StageZero -- called only by LcdKeyRow2_Vel0cityChange_StageZero.
Vel0cityChange_StageZero_LcdKeyRow2:		; <- T_Vel0cityChange_StageZero_LcdKeyRow2
	ld	(3512:16), 2	; F7BD40  ld (0x0db8),0x02
	ld	(DisplayListB_Stage+6:16), 2	; F7BD45  ld (0x12fc),0x02
	or	(UI_RequestBits:16), 0x08	; F7BD4A  or (0x2075),0x08
	or	(UI_RequestBits:16), 0x01	; F7BD4F  or (0x2075),0x01
	ret	; F7BD54  ret

; --------------------------------------------------------------------------
; Vel0cityChange_StageZero_LcdKeyRow3
; Called from: T_Vel0cityChange_StageZero_LcdKeyRow3 (x1)
; Touches: (0x0DB8) (0x12FC) (0x2075)
; Evidence: thunk slot T_Vel0cityChange_StageZero_LcdKeyRow3 holds `jp 0x00F7BD55`, and 0xF7BD55 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_StageZero_LcdKeyRow3: the LcdKeyRow3 action of Vel0cityChange_StageZero -- called only by LcdKeyRow3_Vel0cityChange_StageZero.
Vel0cityChange_StageZero_LcdKeyRow3:		; <- T_Vel0cityChange_StageZero_LcdKeyRow3
	ld	(3512:16), 3	; F7BD55  ld (0x0db8),0x03
	ld	(DisplayListB_Stage+6:16), 3	; F7BD5A  ld (0x12fc),0x03
	or	(UI_RequestBits:16), 0x08	; F7BD5F  or (0x2075),0x08
	or	(UI_RequestBits:16), 0x01	; F7BD64  or (0x2075),0x01
	ret	; F7BD69  ret

; --------------------------------------------------------------------------
; Vel0cityChange_StageZero_LcdKeyRow4
; Called from: T_Vel0cityChange_StageZero_LcdKeyRow4 (x1)
; Touches: (0x0DB8) (0x12FC) (0x2075)
; Evidence: thunk slot T_Vel0cityChange_StageZero_LcdKeyRow4 holds `jp 0x00F7BD6A`, and 0xF7BD6A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_StageZero_LcdKeyRow4: the LcdKeyRow4 action of Vel0cityChange_StageZero -- called only by LcdKeyRow4_Vel0cityChange_StageZero.
Vel0cityChange_StageZero_LcdKeyRow4:		; <- T_Vel0cityChange_StageZero_LcdKeyRow4
	ld	(3512:16), 4	; F7BD6A  ld (0x0db8),0x04
	ld	(DisplayListB_Stage+6:16), 4	; F7BD6F  ld (0x12fc),0x04
	or	(UI_RequestBits:16), 0x08	; F7BD74  or (0x2075),0x08
	or	(UI_RequestBits:16), 0x01	; F7BD79  or (0x2075),0x01
	ret	; F7BD7E  ret

; --------------------------------------------------------------------------
; Vel0cityChange_StepFieldUp
; Called from: T_Vel0cityChange_StepFieldUp (x4)
; Touches: (0x0C4E) (0x0C4F) (0x0DB8) (0x207E)
; Calls:   Vel0cityChange_StepTrack Vel0cityChange_StepFirstMeasure Vel0cityChange_StepLastMeasure Vel0cityChange_StepVelocity
; Evidence: thunk slot T_Vel0cityChange_StepFieldUp holds `jp 0x00F7BD7F`, and 0xF7BD7F is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_StepFieldUp: at stage 1 leaves through Vel0cityChange_ReturnToStageZero; else (0x0C4E) = W, (0x0C4F) = 0 (up) and
;   steps field (0x0db8) (notes/prom_b_seqjob_field_names.py)
Vel0cityChange_StepFieldUp:		; <- T_Vel0cityChange_StepFieldUp
	cp	(UI_ScreenStage:16), 0x01	; F7BD7F  cp (0x207e),0x01
	jr	nz, Vel0cityChange_StepFieldUp_Skip2	; F7BD84  jr NZ,0xf7bd88
	jr	Vel0cityChange_ReturnToStageZero	; F7BD86  jr T,0xf7bdc0
Vel0cityChange_StepFieldUp_Skip2:
	ld	(3150:16), w	; F7BD88  ld (0x0c4e),W
	ld	(3151:16), 0	; F7BD8C  ld (0x0c4f),0x00
	cp	(0x0db8:16), 0x01	; F7BD91  cp (0x0db8),0x01
	jr	nz, Vel0cityChange_StepFieldUp_Skip3	; F7BD96  jr NZ,0xf7bd9d
	calr	Vel0cityChange_StepTrack	; F7BD98  calr 0xf7be0c
	jr	Vel0cityChange_StepFieldUp_Return3	; F7BD9B  jr T,0xf7bdbf
Vel0cityChange_StepFieldUp_Skip3:
	cp	(0x0db8:16), 0x02	; F7BD9D  cp (0x0db8),0x02
	jr	nz, Vel0cityChange_StepFieldUp_Skip4	; F7BDA2  jr NZ,0xf7bda9
	calr	Vel0cityChange_StepFirstMeasure	; F7BDA4  calr 0xf7be43
	jr	Vel0cityChange_StepFieldUp_Return3	; F7BDA7  jr T,0xf7bdbf
Vel0cityChange_StepFieldUp_Skip4:
	cp	(0x0db8:16), 0x03	; F7BDA9  cp (0x0db8),0x03
	jr	nz, Vel0cityChange_StepFieldUp_Skip5	; F7BDAE  jr NZ,0xf7bdb5
	calr	Vel0cityChange_StepLastMeasure	; F7BDB0  calr 0xf7be79
	jr	Vel0cityChange_StepFieldUp_Return3	; F7BDB3  jr T,0xf7bdbf
Vel0cityChange_StepFieldUp_Skip5:
	cp	(0x0db8:16), 0x04	; F7BDB5  cp (0x0db8),0x04
	jr	nz, Vel0cityChange_StepFieldUp_Return3	; F7BDBA  jr NZ,0xf7bdbf
	calr	Vel0cityChange_StepVelocity	; F7BDBC  calr 0xf7beb3
Vel0cityChange_StepFieldUp_Return3:
	ret	; F7BDBF  ret

; --------------------------------------------------------------------------
; Vel0cityChange_ReturnToStageZero
; Called from: T_Vel0cityChange_ReturnToStageZero (x0)
; Touches: (0x2071) (0x2075) (0x207E)
; Calls:   Vel0cityChange_LoadSavedFields
; Evidence: thunk slot T_Vel0cityChange_ReturnToStageZero holds `jp 0x00F7BDC0`, and 0xF7BDC0 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_ReturnToStageZero: UI_ScreenStage = 0, UI_Request_Hi |= 0x10 (notes/prom_b_seqjob_field_names.py)
Vel0cityChange_ReturnToStageZero:		; <- T_Vel0cityChange_ReturnToStageZero
	and	(UI_RequestBits:16), 0xf6	; F7BDC0  and (0x2075),0xf6
	calr	Vel0cityChange_LoadSavedFields	; F7BDC5  calr 0xf7bf74
	ld	(UI_ScreenStage:16), 0	; F7BDC8  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7BDCD  or (0x2071),0x10
	jr	Vel0cityChange_StepFieldUp_Return3	; F7BDD2  jr T,0xf7bdbf

; --------------------------------------------------------------------------
; Vel0cityChange_StepFieldDown
; Called from: T_Vel0cityChange_StepFieldDown (x2)
; Touches: (0x0C4E) (0x0C4F) (0x0DB8)
; Calls:   Vel0cityChange_StepTrack Vel0cityChange_StepFirstMeasure Vel0cityChange_StepLastMeasure Vel0cityChange_StepVelocity
; Evidence: thunk slot T_Vel0cityChange_StepFieldDown holds `jp 0x00F7BDD4`, and 0xF7BDD4 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_StepFieldDown: (0x0C4E) = W, (0x0C4F) = 0x80 (down), steps field (0x0db8) (notes/prom_b_seqjob_field_names.py)
Vel0cityChange_StepFieldDown:		; <- T_Vel0cityChange_StepFieldDown
	ld	(3150:16), w	; F7BDD4  ld (0x0c4e),W
	ld	(3151:16), 128	; F7BDD8  ld (0x0c4f),0x80
	cp	(0x0db8:16), 0x01	; F7BDDD  cp (0x0db8),0x01
	jr	nz, Vel0cityChange_StepFieldDown_Skip6	; F7BDE2  jr NZ,0xf7bde9
	calr	Vel0cityChange_StepTrack	; F7BDE4  calr 0xf7be0c
	jr	Vel0cityChange_StepFieldDown_Return4	; F7BDE7  jr T,0xf7be0b
Vel0cityChange_StepFieldDown_Skip6:
	cp	(0x0db8:16), 0x02	; F7BDE9  cp (0x0db8),0x02
	jr	nz, Vel0cityChange_StepFieldDown_Skip7	; F7BDEE  jr NZ,0xf7bdf5
	calr	Vel0cityChange_StepFirstMeasure	; F7BDF0  calr 0xf7be43
	jr	Vel0cityChange_StepFieldDown_Return4	; F7BDF3  jr T,0xf7be0b
Vel0cityChange_StepFieldDown_Skip7:
	cp	(0x0db8:16), 0x03	; F7BDF5  cp (0x0db8),0x03
	jr	nz, Vel0cityChange_StepFieldDown_Skip8	; F7BDFA  jr NZ,0xf7be01
	calr	Vel0cityChange_StepLastMeasure	; F7BDFC  calr 0xf7be79
	jr	Vel0cityChange_StepFieldDown_Return4	; F7BDFF  jr T,0xf7be0b
Vel0cityChange_StepFieldDown_Skip8:
	cp	(0x0db8:16), 0x04	; F7BE01  cp (0x0db8),0x04
	jr	nz, Vel0cityChange_StepFieldDown_Return4	; F7BE06  jr NZ,0xf7be0b
	calr	Vel0cityChange_StepVelocity	; F7BE08  calr 0xf7beb3
Vel0cityChange_StepFieldDown_Return4:
	ret	; F7BE0B  ret

; --------------------------------------------------------------------------
; Vel0cityChange_StepTrack
; Called from: in-module: 0xF7BD98 0xF7BDE4
; Touches: (0x0C13) (0x0C35) (0x12F6)
; Calls:   SeqJob_StepTrack17
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7BE0C is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_StepTrack: field 1 of the page (Track, FirstMeasure, LastMeasure, Velocity), stepped in the direction (0x0C4F) holds (notes/prom_b_seqjob_field_names.py)
Vel0cityChange_StepTrack:
	ld	a, (3091:16)	; F7BE0C  ld A,(0x0c13)
	ld	l, 1:opc	; F7BE10  ld L,0x01
	ld	h, 17:opc	; F7BE12  ld H,0x11
	calr	SeqJob_StepTrack17	; F7BE14  calr 0xf7cd01
	cp	a, 17	; F7BE17  cp A,0x11
	jr	z, Vel0cityChange_StepTrack_Skip	; F7BE1A  jr Z,0xf7be30
	ld	(3091:16), a	; F7BE1C  ld (0x0c13),A
	ld	(6304945:24), a	; F7BE20  ld (0x6034b1),A
	ld	(DisplayListB_Stage:16), a	; F7BE25  ld (0x12f6),A
	and	(0x0c35:16), 0xdf	; F7BE29  and (0x0c35),0xdf
	jr	Vel0cityChange_StepTrack_Return	; F7BE2E  jr T,0xf7be42
Vel0cityChange_StepTrack_Skip:
	ld	(3091:16), a	; F7BE30  ld (0x0c13),A
	ld	(6304945:24), a	; F7BE34  ld (0x6034b1),A
	ld	(DisplayListB_Stage:16), a	; F7BE39  ld (0x12f6),A
	or	(0x0c35:16), 0x20	; F7BE3D  or (0x0c35),0x20
Vel0cityChange_StepTrack_Return:
	ret	; F7BE42  ret

; --------------------------------------------------------------------------
; Vel0cityChange_StepFirstMeasure
; Called from: in-module: 0xF7BDA4 0xF7BDF0
; Touches: (0x0C18) (0x0C20) (0x0C22) (0x12F7) (0x12F9)
; Calls:   SeqJob_StepMeasure
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7BE43 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_StepFirstMeasure: field 2 of the page (Track, FirstMeasure, LastMeasure, Velocity), stepped in the direction (0x0C4F) holds (notes/prom_b_seqjob_field_names.py)
Vel0cityChange_StepFirstMeasure:
	ld	wa, (3096:16)	; F7BE43  ld WA,(0x0c18)
	calr	SeqJob_StepMeasure	; F7BE47  calr 0xf7cd5f
	ld	(3096:16), wa	; F7BE4A  ld (0x0c18),WA
	ld	(6304946:24), wa	; F7BE4E  ld (0x6034b2),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7BE53  ld (0x12f7),WA
	cp	wa, (0x0c22:16)	; F7BE57  cp WA,(0x0c22)
	jr	ule, Vel0cityChange_StepFirstMeasure_Skip	; F7BE5B  jr ULE,0xf7be65
	ld	(3106:16), wa	; F7BE5D  ld (0x0c22),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7BE61  ld (0x12f9),WA
Vel0cityChange_StepFirstMeasure_Skip:
	ld	(3104:16), wa	; F7BE65  ld (0x0c20),WA
	ld	wa, (3106:16)	; F7BE69  ld WA,(0x0c22)
	sub	wa, (0x0c20:16)	; F7BE6D  sub WA,(0x0c20)
	inc	1, wa	; F7BE71  inc 1,WA
	ld	(6304948:24), wa	; F7BE73  ld (0x6034b4),WA
	ret	; F7BE78  ret

; --------------------------------------------------------------------------
; Vel0cityChange_StepLastMeasure
; Called from: in-module: 0xF7BDB0 0xF7BDFC
; Touches: (0x0C18) (0x0C20) (0x0C22) (0x12F7) (0x12F9)
; Calls:   SeqJob_StepMeasure
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7BE79 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_StepLastMeasure: field 3 of the page (Track, FirstMeasure, LastMeasure, Velocity), stepped in the direction (0x0C4F) holds (notes/prom_b_seqjob_field_names.py)
Vel0cityChange_StepLastMeasure:
	ld	wa, (3106:16)	; F7BE79  ld WA,(0x0c22)
	calr	SeqJob_StepMeasure	; F7BE7D  calr 0xf7cd5f
	ld	(3106:16), wa	; F7BE80  ld (0x0c22),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7BE84  ld (0x12f9),WA
	cp	wa, (0x0c20:16)	; F7BE88  cp WA,(0x0c20)
	jr	nc, Vel0cityChange_StepLastMeasure_Skip	; F7BE8C  jr NC,0xf7be9f
	ld	(3104:16), wa	; F7BE8E  ld (0x0c20),WA
	ld	(3096:16), wa	; F7BE92  ld (0x0c18),WA
	ld	(6304946:24), wa	; F7BE96  ld (0x6034b2),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7BE9B  ld (0x12f7),WA
Vel0cityChange_StepLastMeasure_Skip:
	ld	(3106:16), wa	; F7BE9F  ld (0x0c22),WA
	ld	wa, (3106:16)	; F7BEA3  ld WA,(0x0c22)
	sub	wa, (0x0c20:16)	; F7BEA7  sub WA,(0x0c20)
	inc	1, wa	; F7BEAB  inc 1,WA
	ld	(6304948:24), wa	; F7BEAD  ld (0x6034b4),WA
	ret	; F7BEB2  ret

; --------------------------------------------------------------------------
; Vel0cityChange_StepVelocity
; Called from: in-module: 0xF7BDBC 0xF7BE08
; Touches: (0x0C1E) (0x0C24) (0x0C4F) (0x12FB) (0x2075)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7BEB3 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_StepVelocity: field 4 of the page (Track, FirstMeasure, LastMeasure, Velocity), stepped in the direction (0x0C4F) holds (notes/prom_b_seqjob_field_names.py)
Vel0cityChange_StepVelocity:
	or	(UI_RequestBits:16), 0x09	; F7BEB3  or (0x2075),0x09
	ld	a, (3102:16)	; F7BEB8  ld A,(0x0c1e)
	cp	(0x0c4f:16), 0x80	; F7BEBC  cp (0x0c4f),0x80
	jr	z, Vel0cityChange_StepVelocity_Skip2	; F7BEC1  jr Z,0xf7bece
	inc	1, a	; F7BEC3  inc 1,A
	cp	a, 128	; F7BEC5  cp A,0x80
	jr	nz, Vel0cityChange_StepVelocity_Skip	; F7BEC8  jr NZ,0xf7becc
	ld	a, 127:opc	; F7BECA  ld A,0x7f
Vel0cityChange_StepVelocity_Skip:
	jr	Vel0cityChange_StepVelocity_Join	; F7BECC  jr T,0xf7bed7
Vel0cityChange_StepVelocity_Skip2:
	dec	1, a	; F7BECE  dec 1,A
	cp	a, 128	; F7BED0  cp A,0x80
	jr	nz, Vel0cityChange_StepVelocity_Join	; F7BED3  jr NZ,0xf7bed7
	ld	a, 129:opc	; F7BED5  ld A,0x81
Vel0cityChange_StepVelocity_Join:
	ld	(3102:16), a	; F7BED7  ld (0x0c1e),A
	ld	(6304956:24), a	; F7BEDB  ld (0x6034bc),A
	xor	w, w	; F7BEE0  xor W,W
	ld	a, (3102:16)	; F7BEE2  ld A,(0x0c1e)
	ld	(3108:16), a	; F7BEE6  ld (0x0c24),A
	ldw	de, 127	; F7BEEA  ld DE,0x007f
	ld	(DisplayListB_Stage+5:16), a	; F7BEED  ld (0x12fb),A
	jr	Vel0cityChange_StepVelocity_Return	; F7BEF1  jr T,0xf7bef3
Vel0cityChange_StepVelocity_Return:
	ret	; F7BEF3  ret

; --------------------------------------------------------------------------
; Vel0cityChange_LcdKeyRow2
; Called from: T_Vel0cityChange_LcdKeyRow2 (x2)
; Touches: (0x0C13) (0x0C1E) (0x0C20) (0x0C22) (0x0C35) (0x0C70) (0x0C73)
;          (0x0C77) (0x0C7A) (0x0C7B) +6 more
; Calls:   T_Vel0cityChange_Execute
; Evidence: thunk slot T_Vel0cityChange_LcdKeyRow2 holds `jp 0x00F7BEF4`, and 0xF7BEF4 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_LcdKeyRow2: the LcdKeyRow2 action of Vel0cityChange_StageNonZero, Vel0cityChange_StageZero -- called only by LcdKeyRow2_Vel0cityChange_StageNonZero, LcdKeyRow2_Vel0cityChange_StageZero.
Vel0cityChange_LcdKeyRow2:		; <- T_Vel0cityChange_LcdKeyRow2
	and	(UI_RequestBits:16), 0xf6	; F7BEF4  and (0x2075),0xf6
	cp	(UI_ScreenStage:16), 0x01	; F7BEF9  cp (0x207e),0x01
	jr	z, Vel0cityChange_LcdKeyRow2_Skip3	; F7BEFE  jr Z,0xf7bf0c
	ld	(UI_ScreenStage:16), 1	; F7BF00  ld (0x207e),0x01
	or	(UI_Request_Hi:16), 0x10	; F7BF05  or (0x2071),0x10
	jr	Vel0cityChange_LcdKeyRow2_Return2	; F7BF0A  jr T,0xf7bf73
Vel0cityChange_LcdKeyRow2_Skip3:
	ld	a, (3091:16)	; F7BF0C  ld A,(0x0c13)
	bit	5, (0x0c35:16)	; F7BF10  bit 5,(0x0c35)
	jr	z, Vel0cityChange_LcdKeyRow2_Skip4	; F7BF14  jr Z,0xf7bf18
	ld	a, 127:opc	; F7BF16  ld A,0x7f
Vel0cityChange_LcdKeyRow2_Skip4:
	ld	(3184:16), a	; F7BF18  ld (0x0c70),A
	ld	wa, (6304946:24)	; F7BF1C  ld WA,(0x6034b2)
	ld	(3187:16), wa	; F7BF21  ld (0x0c73),WA
	ld	wa, (3106:16)	; F7BF25  ld WA,(0x0c22)
	sub	wa, (0x0c20:16)	; F7BF29  sub WA,(0x0c20)
	inc	1, wa	; F7BF2D  inc 1,WA
	ld	(6304948:24), wa	; F7BF2F  ld (0x6034b4),WA
	ld	(3191:16), wa	; F7BF34  ld (0x0c77),WA
	ld	(3194:16), 0	; F7BF38  ld (0x0c7a),0x00
	ld	a, (3102:16)	; F7BF3D  ld A,(0x0c1e)
	ld	(3195:16), a	; F7BF41  ld (0x0c7b),A
	jr	Vel0cityChange_LcdKeyRow2_Join2	; F7BF45  jr T,0xf7bf47
Vel0cityChange_LcdKeyRow2_Join2:
	ld	(UI_StatusCode:16), 255	; F7BF47  ld (0x2880),0xff
	ld	(BStore_ErrorCode:16), 0	; F7BF4C  ld (0x0d4a),0x00
	call	T_Vel0cityChange_Execute	; F7BF51  call 0xf426fc
	cp	(UI_StatusCode:16), 0xff	; F7BF55  cp (0x2880),0xff
	jr	z, Vel0cityChange_LcdKeyRow2_Skip5	; F7BF5A  jr Z,0xf7bf69
	ldw	(UI_Request:16), 16555	; F7BF5C  ld (0x2070),0x40ab
	ld	(UI_ScreenStage:16), 0	; F7BF62  ld (0x207e),0x00
	jr	Vel0cityChange_LcdKeyRow2_Return2	; F7BF67  jr T,0xf7bf73
Vel0cityChange_LcdKeyRow2_Skip5:
	ld	(UI_ScreenStage:16), 0	; F7BF69  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7BF6E  or (0x2071),0x10
Vel0cityChange_LcdKeyRow2_Return2:
	ret	; F7BF73  ret

; --------------------------------------------------------------------------
; Vel0cityChange_LoadSavedFields
; Called from: in-module: 0xF7BCFD 0xF7BDC5
; Touches: (0x0C13) (0x0C16) (0x0C18) (0x0C1C) (0x0C1E) (0x0C1F) (0x0C20)
;          (0x0C22) (0x0C24) (0x0C35) +3 more
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7BF74 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_LoadSavedFields: copies the job's saved fields from battery RAM 0x6034xx into the working cells (notes/prom_b_seqjob_field_names.py)
Vel0cityChange_LoadSavedFields:
	ld	a, (6304945:24)	; F7BF74  ld A,(0x6034b1)
	ld	(3091:16), a	; F7BF79  ld (0x0c13),A
	ld	(DisplayListB_Stage:16), a	; F7BF7D  ld (0x12f6),A
	ld	wa, (6304946:24)	; F7BF81  ld WA,(0x6034b2)
	ld	(3096:16), wa	; F7BF86  ld (0x0c18),WA
	ld	(3104:16), wa	; F7BF8A  ld (0x0c20),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7BF8E  ld (0x12f7),WA
	ld	wa, (6304948:24)	; F7BF92  ld WA,(0x6034b4)
	dec	1, wa	; F7BF97  dec 1,WA
	add	wa, (6304946:24)	; F7BF99  add WA,(0x6034b2)
	ld	(3106:16), wa	; F7BF9E  ld (0x0c22),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7BFA2  ld (0x12f9),WA
	ld	wa, (3106:16)	; F7BFA6  ld WA,(0x0c22)
	sub	wa, (0x0c20:16)	; F7BFAA  sub WA,(0x0c20)
	inc	1, wa	; F7BFAE  inc 1,WA
	ld	(6304948:24), wa	; F7BFB0  ld (0x6034b4),WA
	ld	(3100:16), wa	; F7BFB5  ld (0x0c1c),WA
	ld	a, (6304950:24)	; F7BFB9  ld A,(0x6034b6)
	ld	(3094:16), a	; F7BFBE  ld (0x0c16),A
	ld	a, (6304956:24)	; F7BFC2  ld A,(0x6034bc)
	ld	(3102:16), a	; F7BFC7  ld (0x0c1e),A
	ld	(3108:16), a	; F7BFCB  ld (0x0c24),A
	ld	a, (6304957:24)	; F7BFCF  ld A,(0x6034bd)
	ld	(3103:16), a	; F7BFD4  ld (0x0c1f),A
	and	(0x0c35:16), 0xdf	; F7BFD8  and (0x0c35),0xdf
	cp	(0x0c13:16), 0x11	; F7BFDD  cp (0x0c13),0x11
	jr	nz, Vel0cityChange_LoadSavedFields_Return	; F7BFE2  jr NZ,0xf7bfe9
	or	(0x0c35:16), 0x20	; F7BFE4  or (0x0c35),0x20
Vel0cityChange_LoadSavedFields_Return:
	ret	; F7BFE9  ret

; --------------------------------------------------------------------------
; Quantize_InitFields
; Called from: T_Quantize_InitFields (x1)
; Touches: (0x0C25) (0x0C26) (0x0C28) (0x0C35) (0x0C36) (0x0C37) (0x0C3A)
;          (0x0C4A) (0x0DB9) (0x0E04) +15 more
; Evidence: thunk slot T_Quantize_InitFields holds `jp 0x00F7BFEA`, and 0xF7BFEA is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_InitFields: Paint_Quantize's stage-0 init (thunk T_Quantize_InitFields): copies the saved fields from battery RAM 0x603477.. into the working cells.
Quantize_InitFields:		; <- T_Quantize_InitFields
	ld	a, (UI_ScreenLatch_Previous:16)	; F7BFEA  ld A,(0x207b)
	cp	a, (UI_ScreenLatch:16)	; F7BFEE  cp A,(0x207a)
	jr	z, Quantize_InitFields_Skip	; F7BFF2  jr Z,0xf7bffd
	ld	(4927:16), a	; F7BFF4  ld (0x133f),A
	ld	(UI_StatusCode:16), 255	; F7BFF8  ld (0x2880),0xff
Quantize_InitFields_Skip:
	ld	a, (6304887:24)	; F7BFFD  ld A,(0x603477)
	ld	(3126:16), a	; F7C002  ld (0x0c36),A
	inc	1, a	; F7C006  inc 1,A
	ld	(3109:16), a	; F7C008  ld (0x0c25),A
	ld	(DisplayListB_Stage:16), a	; F7C00C  ld (0x12f6),A
	ld	wa, (6304888:24)	; F7C010  ld WA,(0x603478)
	ld	(3146:16), wa	; F7C015  ld (0x0c4a),WA
	ld	(3110:16), wa	; F7C019  ld (0x0c26),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7C01D  ld (0x12f7),WA
	ld	wa, (6304890:24)	; F7C021  ld WA,(0x60347a)
	dec	1, wa	; F7C026  dec 1,WA
	add	wa, (6304888:24)	; F7C028  add WA,(0x603478)
	ld	(3112:16), wa	; F7C02D  ld (0x0c28),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7C031  ld (0x12f9),WA
	ld	wa, (3112:16)	; F7C035  ld WA,(0x0c28)
	sub	wa, (0x0c26:16)	; F7C039  sub WA,(0x0c26)
	inc	1, wa	; F7C03D  inc 1,WA
	ld	(6304890:24), wa	; F7C03F  ld (0x60347a),WA
	ld	(3130:16), wa	; F7C044  ld (0x0c3a),WA
	xor	wa, wa	; F7C048  xor WA,WA
	ld	a, (6304892:24)	; F7C04A  ld A,(0x60347c)
	ld	(3127:16), a	; F7C04F  ld (0x0c37),A
	ld	(DisplayListB_Stage+5:16), a	; F7C053  ld (0x12fb),A
	ld	(3513:16), 1	; F7C057  ld (0x0db9),0x01
	ld	(DisplayListB_Stage+8:16), 1	; F7C05C  ld (0x12fe),0x01
	ld	a, (3588:16)	; F7C061  ld A,(0x0e04)
	ld	(DisplayListB_Stage+6:16), a	; F7C065  ld (0x12fc),A
	ld	a, (3589:16)	; F7C069  ld A,(0x0e05)
	ld	(DisplayListB_Stage+7:16), a	; F7C06D  ld (0x12fd),A
	and	(0x0c35:16), 0xef	; F7C071  and (0x0c35),0xef
	cp	(0x603477:24), 0x11	; F7C076  cp (0x603477),0x11
	jr	nz, Quantize_InitFields_Skip2	; F7C07C  jr NZ,0xf7c083
	or	(0x0c35:16), 0x10	; F7C07E  or (0x0c35),0x10
Quantize_InitFields_Skip2:
	cp	(UI_StatusCode:16), 0x23	; F7C083  cp (0x2880),0x23
	jr	nz, Quantize_InitFields_Return2	; F7C088  jr NZ,0xf7c0ae
	cp	(0x133f:16), 0x1a	; F7C08A  cp (0x133f),0x1a
	jr	z, Quantize_InitFields_Skip3	; F7C08F  jr Z,0xf7c0a8
	bit	2, (TransportB_State:8)	; F7C091  bit 2,(0x96)
	jr	nz, Quantize_InitFields_Return2	; F7C094  jr NZ,0xf7c0ae
	xor	xwa, xwa	; F7C096  xor XWA,XWA
	ld	(12296:16), xwa	; F7C098  ld (0x3008),XWA
	ld	(12300:16), xwa	; F7C09C  ld (0x300c),XWA
	ldw	(UI_Request:16), 32774	; F7C0A0  ld (0x2070),0x8006
	jr	Quantize_InitFields_Return2	; F7C0A6  jr T,0xf7c0ae
Quantize_InitFields_Skip3:
	ldw	(UI_Request:16), 32794	; F7C0A8  ld (0x2070),0x801a
Quantize_InitFields_Return2:
	ret	; F7C0AE  ret

; --------------------------------------------------------------------------
; Quantize_OnLeave
; Called from: T_Quantize_OnLeave (x1)
; Touches: (0x207A)
; Calls:   T_Seq_RequestRewind
; Evidence: thunk slot T_Quantize_OnLeave holds `jp 0x00F7C0AF`, and 0xF7C0AF is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_OnLeave: the LEAVE work of Quantize -- the one unnamed routine ScreenLeaveBody_Quantize calls, and nothing else calls it
;   (notes/prom_ab_screen_enter_leave_work.py).
Quantize_OnLeave:		; <- T_Quantize_OnLeave
	cp	(UI_ScreenLatch:16), 0x1e	; F7C0AF  cp (0x207a),0x1e
	jr	z, Quantize_OnLeave_Return3	; F7C0B4  jr Z,0xf7c0ba
	call	T_Seq_RequestRewind	; F7C0B6  call 0xf409e0
Quantize_OnLeave_Return3:
	ret	; F7C0BA  ret

; --------------------------------------------------------------------------
; Quantize_SelectField1
; Called from: T_Quantize_SelectField1 (x1)
; Touches: (0x0DB9) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_Quantize_SelectField1 holds `jp 0x00F7C0BB`, and 0xF7C0BB is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 1 into (0x0DB9) and requests a redraw (UI_RequestBits);
;           (0x0DB9) is read by LcdKeyRow3/4_Quantize_StageZero, so it is the Quantize screen's field cell.
; Unknown: what field 1 is on that screen.
; --------------------------------------------------------------------------
Quantize_SelectField1:		; <- T_Quantize_SelectField1
	ld	(3513:16), 1	; F7C0BB  ld (0x0db9),0x01
	or	(UI_RequestBits:16), 0x09	; F7C0C0  or (0x2075),0x09
	ret	; F7C0C5  ret

; --------------------------------------------------------------------------
; Quantize_SelectField2
; Called from: T_Quantize_SelectField2 (x1)
; Touches: (0x0DB9) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_Quantize_SelectField2 holds `jp 0x00F7C0C6`, and 0xF7C0C6 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 2 into (0x0DB9) and requests a redraw (UI_RequestBits);
;           (0x0DB9) is read by LcdKeyRow3/4_Quantize_StageZero, so it is the Quantize screen's field cell.
; Unknown: what field 2 is on that screen.
; --------------------------------------------------------------------------
Quantize_SelectField2:		; <- T_Quantize_SelectField2
	ld	(3513:16), 2	; F7C0C6  ld (0x0db9),0x02
	or	(UI_RequestBits:16), 0x08	; F7C0CB  or (0x2075),0x08
	or	(UI_RequestBits:16), 0x01	; F7C0D0  or (0x2075),0x01
	ret	; F7C0D5  ret

; --------------------------------------------------------------------------
; Quantize_SelectField3
; Called from: T_Quantize_SelectField3 (x1)
; Touches: (0x0DB9) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_Quantize_SelectField3 holds `jp 0x00F7C0D6`, and 0xF7C0D6 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 3 into (0x0DB9) and requests a redraw (UI_RequestBits);
;           (0x0DB9) is read by LcdKeyRow3/4_Quantize_StageZero, so it is the Quantize screen's field cell.
; Unknown: what field 3 is on that screen.
; --------------------------------------------------------------------------
Quantize_SelectField3:		; <- T_Quantize_SelectField3
	ld	(3513:16), 3	; F7C0D6  ld (0x0db9),0x03
	or	(UI_RequestBits:16), 0x08	; F7C0DB  or (0x2075),0x08
	or	(UI_RequestBits:16), 0x01	; F7C0E0  or (0x2075),0x01
	ret	; F7C0E5  ret

; --------------------------------------------------------------------------
; Quantize_SelectField4
; Called from: T_Quantize_SelectField4 (x1)
; Touches: (0x0DB9) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_Quantize_SelectField4 holds `jp 0x00F7C0E6`, and 0xF7C0E6 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 4 into (0x0DB9) and requests a redraw (UI_RequestBits);
;           (0x0DB9) is read by LcdKeyRow3/4_Quantize_StageZero, so it is the Quantize screen's field cell.
; Unknown: what field 4 is on that screen.
; --------------------------------------------------------------------------
Quantize_SelectField4:		; <- T_Quantize_SelectField4
	ld	(3513:16), 4	; F7C0E6  ld (0x0db9),0x04
	or	(UI_RequestBits:16), 0x09	; F7C0EB  or (0x2075),0x09
	ret	; F7C0F0  ret

; --------------------------------------------------------------------------
; Quantize_StepFieldUp
; Called from: T_Quantize_StepFieldUp (x4)
; Touches: (0x0C4E) (0x0C4F) (0x0DB9) (0x207E)
; Calls:   Quantize_StepTrack Quantize_StepFirstMeasure Quantize_StepLastMeasure Quantize_StepValue Quantize_StepStrength Quantize_StepWindow
; Evidence: thunk slot T_Quantize_StepFieldUp holds `jp 0x00F7C0F1`, and 0xF7C0F1 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_StepFieldUp: at stage 1 leaves through Quantize_ReturnToStageZero; else (0x0C4F) = 0 (up) and field (0x0DB9) 1..6 -> Quantize_StepTrack / _StepFirstMeasure / _StepLastMeasure / _StepValue / _StepStrength / _StepWindow.  (field order: the page text, checked against each stepper's helper; notes/prom_b_seqjob_field_names.py for the pattern)
Quantize_StepFieldUp:		; <- T_Quantize_StepFieldUp
	cp	(UI_ScreenStage:16), 0x01	; F7C0F1  cp (0x207e),0x01
	jr	nz, Quantize_StepFieldUp_Skip4	; F7C0F6  jr NZ,0xf7c0fa
	jr	Quantize_ReturnToStageZero	; F7C0F8  jr T,0xf7c13e
Quantize_StepFieldUp_Skip4:
	ld	(3150:16), w	; F7C0FA  ld (0x0c4e),W
	ld	(3151:16), 0	; F7C0FE  ld (0x0c4f),0x00
	ld	a, (3513:16)	; F7C103  ld A,(0x0db9)
	cp	a, 1:i3	; F7C107  cp A,1
	jr	nz, Quantize_StepFieldUp_Skip5	; F7C109  jr NZ,0xf7c110
	calr	Quantize_StepTrack	; F7C10B  calr 0xf7c1c1
	jr	Quantize_StepFieldUp_Return4	; F7C10E  jr T,0xf7c13d
Quantize_StepFieldUp_Skip5:
	cp	a, 2:i3	; F7C110  cp A,2
	jr	nz, Quantize_StepFieldUp_Skip6	; F7C112  jr NZ,0xf7c119
	calr	Quantize_StepFirstMeasure	; F7C114  calr 0xf7c20b
	jr	Quantize_StepFieldUp_Return4	; F7C117  jr T,0xf7c13d
Quantize_StepFieldUp_Skip6:
	cp	a, 3:i3	; F7C119  cp A,3
	jr	nz, Quantize_StepFieldUp_Skip7	; F7C11B  jr NZ,0xf7c122
	calr	Quantize_StepLastMeasure	; F7C11D  calr 0xf7c242
	jr	Quantize_StepFieldUp_Return4	; F7C120  jr T,0xf7c13d
Quantize_StepFieldUp_Skip7:
	cp	a, 4:i3	; F7C122  cp A,4
	jr	nz, Quantize_StepFieldUp_Skip8	; F7C124  jr NZ,0xf7c12b
	calr	Quantize_StepValue	; F7C126  calr 0xf7c27c
	jr	Quantize_StepFieldUp_Return4	; F7C129  jr T,0xf7c13d
Quantize_StepFieldUp_Skip8:
	cp	a, 5:i3	; F7C12B  cp A,5
	jr	nz, Quantize_StepFieldUp_Skip9	; F7C12D  jr NZ,0xf7c135
	call	Quantize_StepStrength	; F7C12F  call 0xf7c2ab
	jr	Quantize_StepFieldUp_Return4	; F7C133  jr T,0xf7c13d
Quantize_StepFieldUp_Skip9:
	cp	a, 6:i3	; F7C135  cp A,6
	jr	nz, Quantize_StepFieldUp_Return4	; F7C137  jr NZ,0xf7c13d
	call	Quantize_StepWindow	; F7C139  call 0xf7c2d3
Quantize_StepFieldUp_Return4:
	ret	; F7C13D  ret

; --------------------------------------------------------------------------
; Quantize_ReturnToStageZero
; Called from: T_Quantize_ReturnToStageZero (x0)
; Touches: (0x0C25) (0x0C26) (0x0C36) (0x0C37) (0x0C3A) (0x0C4A) (0x2071)
;          (0x2075) (0x207E)
; Evidence: thunk slot T_Quantize_ReturnToStageZero holds `jp 0x00F7C13E`, and 0xF7C13E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_ReturnToStageZero: writes the track / measure cells back to battery RAM 0x603477.., then UI_ScreenStage = 0 and UI_Request_Hi |= 0x10 -- the stage-1 exit of Quantize_StepFieldUp.
Quantize_ReturnToStageZero:		; <- T_Quantize_ReturnToStageZero
	and	(UI_RequestBits:16), 0xf6	; F7C13E  and (0x2075),0xf6
	ld	a, (3126:16)	; F7C143  ld A,(0x0c36)
	ld	(6304887:24), a	; F7C147  ld (0x603477),A
	inc	1, a	; F7C14C  inc 1,A
	ld	(3109:16), a	; F7C14E  ld (0x0c25),A
	ld	wa, (3146:16)	; F7C152  ld WA,(0x0c4a)
	ld	(6304888:24), wa	; F7C156  ld (0x603478),WA
	ld	(3110:16), wa	; F7C15B  ld (0x0c26),WA
	ld	wa, (3130:16)	; F7C15F  ld WA,(0x0c3a)
	ld	(6304890:24), wa	; F7C163  ld (0x60347a),WA
	ld	a, (6304892:24)	; F7C168  ld A,(0x60347c)
	ld	(3127:16), a	; F7C16D  ld (0x0c37),A
	ld	(UI_ScreenStage:16), 0	; F7C171  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7C176  or (0x2071),0x10
	jr	Quantize_StepFieldUp_Return4	; F7C17B  jr T,0xf7c13d

; --------------------------------------------------------------------------
; Quantize_StepFieldDown
; Called from: T_Quantize_StepFieldDown (x2)
; Touches: (0x0C4E) (0x0C4F) (0x0DB9)
; Calls:   Quantize_StepTrack Quantize_StepFirstMeasure Quantize_StepLastMeasure Quantize_StepValue Quantize_StepStrength Quantize_StepWindow
; Evidence: thunk slot T_Quantize_StepFieldDown holds `jp 0x00F7C17D`, and 0xF7C17D is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_StepFieldDown: the same with (0x0C4F) = 0x80 (down).
Quantize_StepFieldDown:		; <- T_Quantize_StepFieldDown
	ld	(3150:16), w	; F7C17D  ld (0x0c4e),W
	ld	(3151:16), 128	; F7C181  ld (0x0c4f),0x80
	ld	a, (3513:16)	; F7C186  ld A,(0x0db9)
	cp	a, 1:i3	; F7C18A  cp A,1
	jr	nz, Quantize_StepFieldDown_Skip10	; F7C18C  jr NZ,0xf7c193
	calr	Quantize_StepTrack	; F7C18E  calr 0xf7c1c1
	jr	Quantize_StepFieldDown_Return5	; F7C191  jr T,0xf7c1c0
Quantize_StepFieldDown_Skip10:
	cp	a, 2:i3	; F7C193  cp A,2
	jr	nz, Quantize_StepFieldDown_Skip11	; F7C195  jr NZ,0xf7c19c
	calr	Quantize_StepFirstMeasure	; F7C197  calr 0xf7c20b
	jr	Quantize_StepFieldDown_Return5	; F7C19A  jr T,0xf7c1c0
Quantize_StepFieldDown_Skip11:
	cp	a, 3:i3	; F7C19C  cp A,3
	jr	nz, Quantize_StepFieldDown_Skip12	; F7C19E  jr NZ,0xf7c1a5
	calr	Quantize_StepLastMeasure	; F7C1A0  calr 0xf7c242
	jr	Quantize_StepFieldDown_Return5	; F7C1A3  jr T,0xf7c1c0
Quantize_StepFieldDown_Skip12:
	cp	a, 4:i3	; F7C1A5  cp A,4
	jr	nz, Quantize_StepFieldDown_Skip13	; F7C1A7  jr NZ,0xf7c1ae
	calr	Quantize_StepValue	; F7C1A9  calr 0xf7c27c
	jr	Quantize_StepFieldDown_Return5	; F7C1AC  jr T,0xf7c1c0
Quantize_StepFieldDown_Skip13:
	cp	a, 5:i3	; F7C1AE  cp A,5
	jr	nz, Quantize_StepFieldDown_Skip14	; F7C1B0  jr NZ,0xf7c1b8
	call	Quantize_StepStrength	; F7C1B2  call 0xf7c2ab
	jr	Quantize_StepFieldDown_Return5	; F7C1B6  jr T,0xf7c1c0
Quantize_StepFieldDown_Skip14:
	cp	a, 6:i3	; F7C1B8  cp A,6
	jr	nz, Quantize_StepFieldDown_Return5	; F7C1BA  jr NZ,0xf7c1c0
	call	Quantize_StepWindow	; F7C1BC  call 0xf7c2d3
Quantize_StepFieldDown_Return5:
	ret	; F7C1C0  ret

; --------------------------------------------------------------------------
; Quantize_StepTrack
; Called from: in-module: 0xF7C10B 0xF7C18E
; Touches: (0x0C25) (0x0C35) (0x0C36) (0x12F6)
; Calls:   SeqJob_StepTrack17
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7C1C1 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_StepTrack: field 1: SeqJob_StepTrack17.
Quantize_StepTrack:
	ld	a, (6304887:24)	; F7C1C1  ld A,(0x603477)
	inc	1, a	; F7C1C6  inc 1,A
	ld	l, 1:opc	; F7C1C8  ld L,0x01
	ld	h, 17:opc	; F7C1CA  ld H,0x11
	calr	SeqJob_StepTrack17	; F7C1CC  calr 0xf7cd01
	cp	a, 17	; F7C1CF  cp A,0x11
	jr	z, Quantize_StepTrack_Skip	; F7C1D2  jr Z,0xf7c1f0
	dec	1, a	; F7C1D4  dec 1,A
	ld	(6304887:24), a	; F7C1D6  ld (0x603477),A
	ld	(3126:16), a	; F7C1DB  ld (0x0c36),A
	inc	1, a	; F7C1DF  inc 1,A
	ld	(3109:16), a	; F7C1E1  ld (0x0c25),A
	ld	(DisplayListB_Stage:16), a	; F7C1E5  ld (0x12f6),A
	and	(0x0c35:16), 0xef	; F7C1E9  and (0x0c35),0xef
	jr	Quantize_StepTrack_Return	; F7C1EE  jr T,0xf7c20a
Quantize_StepTrack_Skip:
	dec	1, a	; F7C1F0  dec 1,A
	ld	(6304887:24), a	; F7C1F2  ld (0x603477),A
	ld	(3126:16), a	; F7C1F7  ld (0x0c36),A
	inc	1, a	; F7C1FB  inc 1,A
	ld	(3109:16), a	; F7C1FD  ld (0x0c25),A
	ld	(DisplayListB_Stage:16), a	; F7C201  ld (0x12f6),A
	or	(0x0c35:16), 0x10	; F7C205  or (0x0c35),0x10
Quantize_StepTrack_Return:
	ret	; F7C20A  ret

; --------------------------------------------------------------------------
; Quantize_StepFirstMeasure
; Called from: in-module: 0xF7C114 0xF7C197
; Touches: (0x0C26) (0x0C28) (0x0C4A) (0x12F7) (0x12F9)
; Calls:   SeqJob_StepMeasure
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7C20B is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_StepFirstMeasure: field 2: SeqJob_StepMeasure, stage +1.
Quantize_StepFirstMeasure:
	ld	wa, (6304888:24)	; F7C20B  ld WA,(0x603478)
	calr	SeqJob_StepMeasure	; F7C210  calr 0xf7cd5f
	ld	(6304888:24), wa	; F7C213  ld (0x603478),WA
	ld	(3146:16), wa	; F7C218  ld (0x0c4a),WA
	cp	wa, (0x0c28:16)	; F7C21C  cp WA,(0x0c28)
	jr	ule, Quantize_StepFirstMeasure_Skip	; F7C220  jr ULE,0xf7c22a
	ld	(3112:16), wa	; F7C222  ld (0x0c28),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7C226  ld (0x12f9),WA
Quantize_StepFirstMeasure_Skip:
	ld	(3110:16), wa	; F7C22A  ld (0x0c26),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7C22E  ld (0x12f7),WA
	ld	wa, (3112:16)	; F7C232  ld WA,(0x0c28)
	sub	wa, (0x0c26:16)	; F7C236  sub WA,(0x0c26)
	inc	1, wa	; F7C23A  inc 1,WA
	ld	(6304890:24), wa	; F7C23C  ld (0x60347a),WA
	ret	; F7C241  ret

; --------------------------------------------------------------------------
; Quantize_StepLastMeasure
; Called from: in-module: 0xF7C11D 0xF7C1A0
; Touches: (0x0C26) (0x0C28) (0x0C4A) (0x12F7) (0x12F9)
; Calls:   SeqJob_StepMeasure
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7C242 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_StepLastMeasure: field 3: SeqJob_StepMeasure, stage +3.
Quantize_StepLastMeasure:
	ld	wa, (3112:16)	; F7C242  ld WA,(0x0c28)
	calr	SeqJob_StepMeasure	; F7C246  calr 0xf7cd5f
	ld	(3112:16), wa	; F7C249  ld (0x0c28),WA
	cp	wa, (0x0c26:16)	; F7C24D  cp WA,(0x0c26)
	jr	nc, Quantize_StepLastMeasure_Skip	; F7C251  jr NC,0xf7c264
	ld	(3110:16), wa	; F7C253  ld (0x0c26),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7C257  ld (0x12f7),WA
	ld	(6304888:24), wa	; F7C25B  ld (0x603478),WA
	ld	(3146:16), wa	; F7C260  ld (0x0c4a),WA
Quantize_StepLastMeasure_Skip:
	ld	(3112:16), wa	; F7C264  ld (0x0c28),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7C268  ld (0x12f9),WA
	ld	wa, (3112:16)	; F7C26C  ld WA,(0x0c28)
	sub	wa, (0x0c26:16)	; F7C270  sub WA,(0x0c26)
	inc	1, wa	; F7C274  inc 1,WA
	ld	(6304890:24), wa	; F7C276  ld (0x60347a),WA
	ret	; F7C27B  ret

; --------------------------------------------------------------------------
; Quantize_StepValue
; Called from: in-module: 0xF7C126 0xF7C1A9
; Touches: (0x0C37) (0x0C4F) (0x12FB)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7C27C is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_StepValue: field 4: (0x0C37) 0..6, stage +5 -- the VALUE caption's string-table readout in DL_TrackValueFirstMeasureLastMeasureStrengthWindow.
Quantize_StepValue:
	ld	a, (3127:16)	; F7C27C  ld A,(0x0c37)
	ld	l, 0:opc	; F7C280  ld L,0x00
	ld	h, 6:opc	; F7C282  ld H,0x06
	cp	(0x0c4f:16), 0x80	; F7C284  cp (0x0c4f),0x80
	jr	z, Quantize_StepValue_Skip	; F7C289  jr Z,0xf7c293
	inc	1, a	; F7C28B  inc 1,A
	cp	a, h	; F7C28D  cp A,H
	jr	ugt, Quantize_StepValue_Skip2	; F7C28F  jr UGT,0xf7c29b
	jr	Quantize_StepValue_Join	; F7C291  jr T,0xf7c29d
Quantize_StepValue_Skip:
	cp	a, l	; F7C293  cp A,L
	jr	z, Quantize_StepValue_Join	; F7C295  jr Z,0xf7c29d
	dec	1, a	; F7C297  dec 1,A
	jr	Quantize_StepValue_Join	; F7C299  jr T,0xf7c29d
Quantize_StepValue_Skip2:
	ld	a, h	; F7C29B  ld A,H
Quantize_StepValue_Join:
	ld	(3127:16), a	; F7C29D  ld (0x0c37),A
	ld	(6304892:24), a	; F7C2A1  ld (0x60347c),A
	ld	(DisplayListB_Stage+5:16), a	; F7C2A6  ld (0x12fb),A
	ret	; F7C2AA  ret

; --------------------------------------------------------------------------
; Quantize_StepStrength
; Called from: in-module: 0xF7C12F 0xF7C1B2
; Touches: (0x0C4F) (0x0E04) (0x12FC)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7C2AB is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_StepStrength: field 5: (0x0E04) 0..100, stage +6 -- the STRENGTH caption's unsigned readout.
Quantize_StepStrength:
	xor	l, l	; F7C2AB  xor L,L
	ld	h, 100:opc	; F7C2AD  ld H,0x64
	ld	a, (3588:16)	; F7C2AF  ld A,(0x0e04)
	cp	(0x0c4f:16), 0x80	; F7C2B3  cp (0x0c4f),0x80
	jr	z, Quantize_StepStrength_Skip	; F7C2B8  jr Z,0xf7c2c4
	inc	1, a	; F7C2BA  inc 1,A
	cp	a, h	; F7C2BC  cp A,H
	jr	le, Quantize_StepStrength_Join	; F7C2BE  jr LE,0xf7c2ca
	ld	a, h	; F7C2C0  ld A,H
	jr	Quantize_StepStrength_Join	; F7C2C2  jr T,0xf7c2ca
Quantize_StepStrength_Skip:
	cp	a, l	; F7C2C4  cp A,L
	jr	z, Quantize_StepStrength_Join	; F7C2C6  jr Z,0xf7c2ca
	dec	1, a	; F7C2C8  dec 1,A
Quantize_StepStrength_Join:
	ld	(3588:16), a	; F7C2CA  ld (0x0e04),A
	ld	(DisplayListB_Stage+6:16), a	; F7C2CE  ld (0x12fc),A
	ret	; F7C2D2  ret

; --------------------------------------------------------------------------
; Quantize_StepWindow
; Called from: in-module: 0xF7C139 0xF7C1BC
; Touches: (0x0C4F) (0x0E05)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7C2D3 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_StepWindow: field 6: (0x0E05) -100..100 -- the WINDOW caption's SIGNED readout (stage +7).
Quantize_StepWindow:
	ld	a, (3589:16)	; F7C2D3  ld A,(0x0e05)
	ld	l, 156:opc	; F7C2D7  ld L,0x9c
	ld	h, 100:opc	; F7C2D9  ld H,0x64
	cp	(0x0c4f:16), 0x80	; F7C2DB  cp (0x0c4f),0x80
	jr	z, Quantize_StepWindow_Skip	; F7C2E0  jr Z,0xf7c2ec
	inc	1, a	; F7C2E2  inc 1,A
	cp	a, h	; F7C2E4  cp A,H
	jr	le, Quantize_StepWindow_Join	; F7C2E6  jr LE,0xf7c2f4
	ld	a, h	; F7C2E8  ld A,H
	jr	Quantize_StepWindow_Join	; F7C2EA  jr T,0xf7c2f4
Quantize_StepWindow_Skip:
	dec	1, a	; F7C2EC  dec 1,A
	cp	a, l	; F7C2EE  cp A,L
	jr	ge, Quantize_StepWindow_Join	; F7C2F0  jr GE,0xf7c2f4
	ld	a, l	; F7C2F2  ld A,L
Quantize_StepWindow_Join:
	ld	(3589:16), a	; F7C2F4  ld (0x0e05),A
	jr	Quantize_StepWindow_StoreDisplayValue	; F7C2F8  jr T,0xf7c30b

; SongStore_Island_F7C2FA -- 17 bytes, unexplained
;
; Read by:  NOTHING.  No site in prom_a or prom_b spells 0x00F7C2FA (checked on
;   every emit by a whole-image scan at every byte offset, which can only
;   over-count, so a zero is a real zero).
; Extent:   by abutment only.  The instruction at 0xF7C2F8 is `jr T,0xf7c30b`,
;   which steps over exactly these 17 bytes, and 0xF7C30B begins a routine that
;   ends in `ret`.  No thunk target lands inside the range.
; Evidence: the zero-reference result and the `jr` that steps over it are both
;   re-checked on every emit, as is "no thunk target lands inside it".  Nothing
;   else here is claimed.
; Unknown:  everything else.  It is emitted as `.byte` because a linear decode
;   would silently resynchronise past it; whether it is data, dead code or a
;   fragment left by the linker is not established.
SongStore_Island_F7C2FA:
	.byte	0xC8, 0xD0, 0xC9, 0x33, 0x07, 0x6E, 0x06, 0xD8, 0xC8, 0x64, 0x00, 0x68, 0x04, 0xD8, 0xCA, 0x9C	; F7C2FA
	.byte	0x00	; F7C30A


; --------------------------------------------------------------------------
; Quantize_StepWindow_StoreDisplayValue
; Called from: no thunk slot, no in-module call site and no dispatch entry
;              -- reached only by a branch from the routine above
; Touches: (0x12FD)
; Evidence: the label is here because it is the target of `jr T,0xf7c30b` at
;           0xF7C2F8, the jump that steps over the 17 bytes of
;           SongStore_Island_F7C2FA; the address is an instruction boundary
;           of this transcription (re-asserted on every emit)
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_StepWindow_StoreDisplayValue: The tail of Quantize_StepWindow, split off by the 17-byte
;   SongStore_Island_F7C2FA: DisplayListB_Stage+7 := A, the WINDOW value just stored in (0x0E05) -- the signed readout
;   its header names (stage +7). Reached only by Quantize_StepWindow's `jr` over the island. Basis: caller + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
Quantize_StepWindow_StoreDisplayValue:
	ld	(DisplayListB_Stage+7:16), a	; F7C30B  ld (0x12fd),A
	ret	; F7C30F  ret

; --------------------------------------------------------------------------
; Quantize_SelectField5
; Called from: T_Quantize_SelectField5 (x1)
; Touches: (0x0DB9) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_Quantize_SelectField5 holds `jp 0x00F7C310`, and 0xF7C310 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 5 into (0x0DB9) and requests a redraw (UI_RequestBits);
;           (0x0DB9) is read by LcdKeyRow3/4_Quantize_StageZero, so it is the Quantize screen's field cell.
; Unknown: what field 5 is on that screen.
; --------------------------------------------------------------------------
Quantize_SelectField5:		; <- T_Quantize_SelectField5
	ld	(UI_RequestBits:16), 9	; F7C310  ld (0x2075),0x09
	ld	(3513:16), 5	; F7C315  ld (0x0db9),0x05
	ret	; F7C31A  ret

; --------------------------------------------------------------------------
; Quantize_SelectField6
; Called from: T_Quantize_SelectField6 (x1)
; Touches: (0x0DB9) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_Quantize_SelectField6 holds `jp 0x00F7C31B`, and 0xF7C31B is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 6 into (0x0DB9) and requests a redraw (UI_RequestBits);
;           (0x0DB9) is read by LcdKeyRow3/4_Quantize_StageZero, so it is the Quantize screen's field cell.
; Unknown: what field 6 is on that screen.
; --------------------------------------------------------------------------
Quantize_SelectField6:		; <- T_Quantize_SelectField6
	ld	(UI_RequestBits:16), 9	; F7C31B  ld (0x2075),0x09
	ld	(3513:16), 6	; F7C320  ld (0x0db9),0x06
	ret	; F7C325  ret

; --------------------------------------------------------------------------
; Quantize_LcdKeyRow3
; Called from: T_Quantize_LcdKeyRow3 (x2)
; Touches: (0x0C26) (0x0C28) (0x0C35) (0x0C37) (0x0C70) (0x0C73) (0x0C77)
;          (0x0C7F) (0x0D4A) (0x2070) +4 more
; Calls:   T_Quantize_Execute
; Evidence: thunk slot T_Quantize_LcdKeyRow3 holds `jp 0x00F7C326`, and 0xF7C326 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_LcdKeyRow3: the LcdKeyRow3 action of Quantize_StageNonZero, Quantize_StageZero -- called only by LcdKeyRow3_Quantize_StageNonZero, LcdKeyRow3_Quantize_StageZero.
Quantize_LcdKeyRow3:		; <- T_Quantize_LcdKeyRow3
	and	(UI_RequestBits:16), 0xf6	; F7C326  and (0x2075),0xf6
	cp	(UI_ScreenStage:16), 0x01	; F7C32B  cp (0x207e),0x01
	jr	z, Quantize_LcdKeyRow3_Skip	; F7C330  jr Z,0xf7c33f
	ld	(UI_ScreenStage:16), 1	; F7C332  ld (0x207e),0x01
	or	(UI_Request_Hi:16), 0x10	; F7C337  or (0x2071),0x10
	jrl	Quantize_LcdKeyRow3_Return	; F7C33C  jrl T,0xf7c3b1
Quantize_LcdKeyRow3_Skip:
	ld	a, (6304887:24)	; F7C33F  ld A,(0x603477)
	bit	4, (0x0c35:16)	; F7C344  bit 4,(0x0c35)
	jr	z, Quantize_LcdKeyRow3_Skip2	; F7C348  jr Z,0xf7c34e
	ld	a, 127:opc	; F7C34A  ld A,0x7f
	jr	Quantize_LcdKeyRow3_Join	; F7C34C  jr T,0xf7c355
Quantize_LcdKeyRow3_Skip2:
	ld	a, (6304887:24)	; F7C34E  ld A,(0x603477)
	inc	1, a	; F7C353  inc 1,A
Quantize_LcdKeyRow3_Join:
	ld	(3184:16), a	; F7C355  ld (0x0c70),A
	ld	wa, (6304888:24)	; F7C359  ld WA,(0x603478)
	ld	(3187:16), wa	; F7C35E  ld (0x0c73),WA
	ld	wa, (3112:16)	; F7C362  ld WA,(0x0c28)
	sub	wa, (0x0c26:16)	; F7C366  sub WA,(0x0c26)
	inc	1, wa	; F7C36A  inc 1,WA
	ld	(6304890:24), wa	; F7C36C  ld (0x60347a),WA
	ld	(3191:16), wa	; F7C371  ld (0x0c77),WA
	ld	a, (3127:16)	; F7C375  ld A,(0x0c37)
	ld	(6304892:24), a	; F7C379  ld (0x60347c),A
	sla	a, 1	; F7C37E  sla 0x01,A
	ld	(3199:16), a	; F7C381  ld (0x0c7f),A
	ld	(UI_StatusCode:16), 255	; F7C385  ld (0x2880),0xff
	ld	(BStore_ErrorCode:16), 0	; F7C38A  ld (0x0d4a),0x00
	call	T_Quantize_Execute	; F7C38F  call 0xf42700
	cp	(UI_StatusCode:16), 0xff	; F7C393  cp (0x2880),0xff
	jr	z, Quantize_LcdKeyRow3_Skip3	; F7C398  jr Z,0xf7c3a7
	ldw	(UI_Request:16), 16555	; F7C39A  ld (0x2070),0x40ab
	ld	(UI_ScreenStage:16), 0	; F7C3A0  ld (0x207e),0x00
	jr	Quantize_LcdKeyRow3_Return	; F7C3A5  jr T,0xf7c3b1
Quantize_LcdKeyRow3_Skip3:
	or	(UI_Request_Hi:16), 0x10	; F7C3A7  or (0x2071),0x10
	ld	(UI_ScreenStage:16), 0	; F7C3AC  ld (0x207e),0x00
Quantize_LcdKeyRow3_Return:
	ret	; F7C3B1  ret

; --------------------------------------------------------------------------
; S0ngC0py_InitFields
; Called from: T_S0ngC0py_InitFields (x1)
; Touches: (0x0E0C) (0x0E0D) (0x0E0E) (0x0E0F) (0x12F6) (0x12F7) (0x1304)
;          (0x1305) (0x207B)  |  0x0012F8 0x0012FE
; Calls:   SongStore_CopyBankSongName
; Evidence: thunk slot T_S0ngC0py_InitFields holds `jp 0x00F7C3B2`, and 0xF7C3B2 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; S0ngC0py_InitFields: Paint_S0ngC0py's init (slot T_S0ngC0py_InitFields): unless the previous screen was S0NG C0PY (0x2A),
;   S0ngC0py_FromSong = S0ngC0py_ToSong = 1 with both 6-character names staged (SongStore_CopyBankSongName to 0x12F8 /
;   0x12FE), and S0ngC0py_FromTrack = S0ngC0py_ToTrack = 1, each with its DisplayListB_Stage cell. Basis: caller +
;   body + siblings (AdvanceDelay_InitFields). (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
S0ngC0py_InitFields:		; <- T_S0ngC0py_InitFields
	cp	(UI_ScreenLatch_Previous:16), 0x2a	; F7C3B2  cp (0x207b),0x2a
	jr	z, S0ngC0py_InitFields_Return	; F7C3B7  jr Z,0xf7c3ed
	ld	a, 1:opc	; F7C3B9  ld A,0x01
	ld	(S0ngC0py_FromSong:16), a	; F7C3BB  ld (0x0e0c),A
	ld	(DisplayListB_Stage:16), a	; F7C3BF  ld (0x12f6),A
	ld	xix, DisplayListB_Stage+2	; F7C3C3  ld XIX,0x000012f8
	call	SongStore_CopyBankSongName	; F7C3C8  call 0xf7c440
	ld	(S0ngC0py_ToSong:16), a	; F7C3CC  ld (0x0e0d),A
	ld	(DisplayListB_Stage+1:16), a	; F7C3D0  ld (0x12f7),A
	ld	xix, DisplayListB_Stage+8	; F7C3D4  ld XIX,0x000012fe
	call	SongStore_CopyBankSongName	; F7C3D9  call 0xf7c440
	ld	(S0ngC0py_FromTrack:16), a	; F7C3DD  ld (0x0e0e),A
	ld	(DisplayListB_Stage+14:16), a	; F7C3E1  ld (0x1304),A
	ld	(S0ngC0py_ToTrack:16), a	; F7C3E5  ld (0x0e0f),A
	ld	(DisplayListB_Stage+15:16), a	; F7C3E9  ld (0x1305),A
S0ngC0py_InitFields_Return:
	ret	; F7C3ED  ret

; --------------------------------------------------------------------------
; sub_F7C3EE
; Called from: T_F42A0C (x0)
; Touches: (0x207A)
; Calls:   T_Seq_RequestRewind
; Evidence: thunk slot T_F42A0C holds `jp 0x00F7C3EE`, and 0xF7C3EE is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F7C3EE:		; <- T_F42A0C
	cp	(UI_ScreenLatch:16), 0x2a	; F7C3EE  cp (0x207a),0x2a
	jr	z, sub_F7C3EE_Return	; F7C3F3  jr Z,0xf7c3f9
	call	T_Seq_RequestRewind	; F7C3F5  call 0xf409e0
sub_F7C3EE_Return:
	ret	; F7C3F9  ret

; --------------------------------------------------------------------------
; S0ngC0py_StageZero_SoftKeyCol1
; Called from: T_S0ngC0py_StageZero_SoftKeyCol1 (x1)
; Touches: (0x0E0C) (0x12F6) (0x2075)  |  0x0012F8
; Calls:   SongStore_CopyBankSongName
; Evidence: thunk slot T_S0ngC0py_StageZero_SoftKeyCol1 holds `jp 0x00F7C3FA`, and 0xF7C3FA is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; S0ngC0py_StageZero_SoftKeyCol1: the SoftKeyCol1 action of S0ngC0py_StageZero -- called only by SoftKeyCol1_S0ngC0py_StageZero.
S0ngC0py_StageZero_SoftKeyCol1:		; <- T_S0ngC0py_StageZero_SoftKeyCol1
	or	(UI_RequestBits:16), 0x08	; F7C3FA  or (0x2075),0x08
	ld	a, (S0ngC0py_FromSong:16)	; F7C3FF  ld A,(0x0e0c)
	ld	l, 1:opc	; F7C403  ld L,0x01
	cp	a, l	; F7C405  cp A,L
	jr	ule, S0ngC0py_StageZero_SoftKeyCol1_Return	; F7C407  jr ULE,0xf7c41c
	dec	1, a	; F7C409  dec 1,A
	ld	(S0ngC0py_FromSong:16), a	; F7C40B  ld (0x0e0c),A
	ld	(DisplayListB_Stage:16), a	; F7C40F  ld (0x12f6),A
	ld	xix, DisplayListB_Stage+2	; F7C413  ld XIX,0x000012f8
	call	SongStore_CopyBankSongName	; F7C418  call 0xf7c440
S0ngC0py_StageZero_SoftKeyCol1_Return:
	ret	; F7C41C  ret

; --------------------------------------------------------------------------
; S0ngC0py_StageZero_SoftKeyCol2
; Called from: T_S0ngC0py_StageZero_SoftKeyCol2 (x1)
; Touches: (0x0E0C) (0x12F6) (0x2075)  |  0x0012F8
; Calls:   SongStore_CopyBankSongName
; Evidence: thunk slot T_S0ngC0py_StageZero_SoftKeyCol2 holds `jp 0x00F7C41D`, and 0xF7C41D is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; S0ngC0py_StageZero_SoftKeyCol2: the SoftKeyCol2 action of S0ngC0py_StageZero -- called only by SoftKeyCol2_S0ngC0py_StageZero.
S0ngC0py_StageZero_SoftKeyCol2:		; <- T_S0ngC0py_StageZero_SoftKeyCol2
	or	(UI_RequestBits:16), 0x08	; F7C41D  or (0x2075),0x08
	ld	a, (S0ngC0py_FromSong:16)	; F7C422  ld A,(0x0e0c)
	ld	l, 10:opc	; F7C426  ld L,0x0a
	cp	a, l	; F7C428  cp A,L
	jr	nc, S0ngC0py_StageZero_SoftKeyCol2_Return	; F7C42A  jr NC,0xf7c43f
	inc	1, a	; F7C42C  inc 1,A
	ld	(S0ngC0py_FromSong:16), a	; F7C42E  ld (0x0e0c),A
	ld	(DisplayListB_Stage:16), a	; F7C432  ld (0x12f6),A
	ld	xix, DisplayListB_Stage+2	; F7C436  ld XIX,0x000012f8
	call	SongStore_CopyBankSongName	; F7C43B  call 0xf7c440
S0ngC0py_StageZero_SoftKeyCol2_Return:
	ret	; F7C43F  ret

; --------------------------------------------------------------------------
; SongStore_CopyBankSongName
; Called from: in-module: 0xF7C3C8 0xF7C3D9 0xF7C418 0xF7C43B 0xF7C4D7
;              0xF7C4FA
; Touches:   |  0x0000CA 0x610000
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7C440 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongStore_CopyBankSongName: Copies the 6 bytes at 0x610000 + A*0xC00 + 0xCA -- bank A's copy of BStore_SongName
;   (workspace +0xCA, the 6-character song name) -- to (XIX). SONG COPY uses it to fill its FROM (0x12F8) and TO
;   (0x12FE) name fields; A is its 1-based song number, used unadjusted. Basis: callers + body + RAM names.
;   (notes/naming-pilot-2026-10-06/proposals_wave2_f.json)
SongStore_CopyBankSongName:
	ld	xiy, 6356992	; F7C440  ld XIY,0x00610000
	xor	xhl, xhl	; F7C445  xor XHL,XHL
	xor	xbc, xbc	; F7C447  xor XBC,XBC
	ld	l, a	; F7C449  ld L,A
	ld	c, l	; F7C44B  ld C,L
	sla	xhl, 11	; F7C44D  sla 0x0b,XHL
	sla	xbc, 10	; F7C450  sla 0x0a,XBC
	add	xhl, xbc	; F7C453  add XHL,XBC
	add	xiy, xhl	; F7C455  add XIY,XHL
	add	xiy, 202	; F7C457  add XIY,0x000000ca
	ldw	bc, 6	; F7C45D  ld BC,0x0006
	ldir85	; F7C460  ldir
	ret	; F7C462  ret

; --------------------------------------------------------------------------
; S0ngC0py_StageZero_SoftKeyCol3
; Called from: T_S0ngC0py_StageZero_SoftKeyCol3 (x1)
; Touches: (0x0E0E) (0x0E0F) (0x1304) (0x1305) (0x2075)
; Evidence: thunk slot T_S0ngC0py_StageZero_SoftKeyCol3 holds `jp 0x00F7C463`, and 0xF7C463 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; S0ngC0py_StageZero_SoftKeyCol3: the SoftKeyCol3 action of S0ngC0py_StageZero -- called only by SoftKeyCol3_S0ngC0py_StageZero.
S0ngC0py_StageZero_SoftKeyCol3:		; <- T_S0ngC0py_StageZero_SoftKeyCol3
	or	(UI_RequestBits:16), 0x08	; F7C463  or (0x2075),0x08
	ld	a, (S0ngC0py_FromTrack:16)	; F7C468  ld A,(0x0e0e)
	ld	l, 1:opc	; F7C46C  ld L,0x01
	cp	a, l	; F7C46E  cp A,L
	jr	z, S0ngC0py_StageZero_SoftKeyCol3_Return	; F7C470  jr Z,0xf7c48b
	dec	1, a	; F7C472  dec 1,A
	ld	(S0ngC0py_FromTrack:16), a	; F7C474  ld (0x0e0e),A
	ld	(DisplayListB_Stage+14:16), a	; F7C478  ld (0x1304),A
	cp	(S0ngC0py_ToTrack:16), 0x12	; F7C47C  cp (0x0e0f),0x12
	jr	nz, S0ngC0py_StageZero_SoftKeyCol3_Return	; F7C481  jr NZ,0xf7c48b
	ld	(S0ngC0py_ToTrack:16), a	; F7C483  ld (0x0e0f),A
	ld	(DisplayListB_Stage+15:16), a	; F7C487  ld (0x1305),A
S0ngC0py_StageZero_SoftKeyCol3_Return:
	ret	; F7C48B  ret

; --------------------------------------------------------------------------
; S0ngC0py_StageZero_SoftKeyCol4
; Called from: T_S0ngC0py_StageZero_SoftKeyCol4 (x1)
; Touches: (0x0E0E) (0x0E0F) (0x1304) (0x1305) (0x2075)
; Evidence: thunk slot T_S0ngC0py_StageZero_SoftKeyCol4 holds `jp 0x00F7C48C`, and 0xF7C48C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; S0ngC0py_StageZero_SoftKeyCol4: the SoftKeyCol4 action of S0ngC0py_StageZero -- called only by SoftKeyCol4_S0ngC0py_StageZero.
S0ngC0py_StageZero_SoftKeyCol4:		; <- T_S0ngC0py_StageZero_SoftKeyCol4
	or	(UI_RequestBits:16), 0x08	; F7C48C  or (0x2075),0x08
	ld	a, (S0ngC0py_FromTrack:16)	; F7C491  ld A,(0x0e0e)
	ld	l, 18:opc	; F7C495  ld L,0x12
	cp	a, l	; F7C497  cp A,L
	jr	z, S0ngC0py_StageZero_SoftKeyCol4_Return2	; F7C499  jr Z,0xf7c4b8
	inc	1, a	; F7C49B  inc 1,A
	ld	(S0ngC0py_FromTrack:16), a	; F7C49D  ld (0x0e0e),A
	ld	(DisplayListB_Stage+14:16), a	; F7C4A1  ld (0x1304),A
	cp	a, 18	; F7C4A5  cp A,0x12
	jr	nz, S0ngC0py_StageZero_SoftKeyCol4_Return2	; F7C4A8  jr NZ,0xf7c4b8
	cp	(S0ngC0py_ToTrack:16), a	; F7C4AA  cp (0x0e0f),A
	jr	z, S0ngC0py_StageZero_SoftKeyCol4_Return2	; F7C4AE  jr Z,0xf7c4b8
	ld	(S0ngC0py_ToTrack:16), a	; F7C4B0  ld (0x0e0f),A
	ld	(DisplayListB_Stage+15:16), a	; F7C4B4  ld (0x1305),A
S0ngC0py_StageZero_SoftKeyCol4_Return2:
	ret	; F7C4B8  ret

; --------------------------------------------------------------------------
; S0ngC0py_StageZero_SoftKeyCol5
; Called from: T_S0ngC0py_StageZero_SoftKeyCol5 (x1)
; Touches: (0x0E0D) (0x12F7) (0x2075)  |  0x0012FE
; Calls:   SongStore_CopyBankSongName
; Evidence: thunk slot T_S0ngC0py_StageZero_SoftKeyCol5 holds `jp 0x00F7C4B9`, and 0xF7C4B9 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; S0ngC0py_StageZero_SoftKeyCol5: the SoftKeyCol5 action of S0ngC0py_StageZero -- called only by SoftKeyCol5_S0ngC0py_StageZero.
S0ngC0py_StageZero_SoftKeyCol5:		; <- T_S0ngC0py_StageZero_SoftKeyCol5
	or	(UI_RequestBits:16), 0x08	; F7C4B9  or (0x2075),0x08
	ld	a, (S0ngC0py_ToSong:16)	; F7C4BE  ld A,(0x0e0d)
	ld	l, 1:opc	; F7C4C2  ld L,0x01
	cp	a, l	; F7C4C4  cp A,L
	jr	z, S0ngC0py_StageZero_SoftKeyCol5_Return3	; F7C4C6  jr Z,0xf7c4db
	dec	1, a	; F7C4C8  dec 1,A
	ld	(S0ngC0py_ToSong:16), a	; F7C4CA  ld (0x0e0d),A
	ld	(DisplayListB_Stage+1:16), a	; F7C4CE  ld (0x12f7),A
	ld	xix, DisplayListB_Stage+8	; F7C4D2  ld XIX,0x000012fe
	call	SongStore_CopyBankSongName	; F7C4D7  call 0xf7c440
S0ngC0py_StageZero_SoftKeyCol5_Return3:
	ret	; F7C4DB  ret

; --------------------------------------------------------------------------
; S0ngC0py_StageZero_SoftKeyCol6
; Called from: T_S0ngC0py_StageZero_SoftKeyCol6 (x1)
; Touches: (0x0E0D) (0x12F7) (0x2075)  |  0x0012FE
; Calls:   SongStore_CopyBankSongName
; Evidence: thunk slot T_S0ngC0py_StageZero_SoftKeyCol6 holds `jp 0x00F7C4DC`, and 0xF7C4DC is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; S0ngC0py_StageZero_SoftKeyCol6: the SoftKeyCol6 action of S0ngC0py_StageZero -- called only by SoftKeyCol6_S0ngC0py_StageZero.
S0ngC0py_StageZero_SoftKeyCol6:		; <- T_S0ngC0py_StageZero_SoftKeyCol6
	or	(UI_RequestBits:16), 0x08	; F7C4DC  or (0x2075),0x08
	ld	a, (S0ngC0py_ToSong:16)	; F7C4E1  ld A,(0x0e0d)
	ld	l, 10:opc	; F7C4E5  ld L,0x0a
	cp	a, l	; F7C4E7  cp A,L
	jr	z, S0ngC0py_StageZero_SoftKeyCol6_Return4	; F7C4E9  jr Z,0xf7c4fe
	inc	1, a	; F7C4EB  inc 1,A
	ld	(S0ngC0py_ToSong:16), a	; F7C4ED  ld (0x0e0d),A
	ld	(DisplayListB_Stage+1:16), a	; F7C4F1  ld (0x12f7),A
	ld	xix, DisplayListB_Stage+8	; F7C4F5  ld XIX,0x000012fe
	call	SongStore_CopyBankSongName	; F7C4FA  call 0xf7c440
S0ngC0py_StageZero_SoftKeyCol6_Return4:
	ret	; F7C4FE  ret

; --------------------------------------------------------------------------
; S0ngC0py_StageZero_SoftKeyCol7
; Called from: T_S0ngC0py_StageZero_SoftKeyCol7 (x1)
; Touches: (0x0E0E) (0x0E0F) (0x1304) (0x1305) (0x2075)
; Evidence: thunk slot T_S0ngC0py_StageZero_SoftKeyCol7 holds `jp 0x00F7C4FF`, and 0xF7C4FF is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; S0ngC0py_StageZero_SoftKeyCol7: the SoftKeyCol7 action of S0ngC0py_StageZero -- called only by SoftKeyCol7_S0ngC0py_StageZero.
S0ngC0py_StageZero_SoftKeyCol7:		; <- T_S0ngC0py_StageZero_SoftKeyCol7
	or	(UI_RequestBits:16), 0x08	; F7C4FF  or (0x2075),0x08
	ld	a, (S0ngC0py_ToTrack:16)	; F7C504  ld A,(0x0e0f)
	ld	l, 1:opc	; F7C508  ld L,0x01
	cp	a, l	; F7C50A  cp A,L
	jr	z, S0ngC0py_StageZero_SoftKeyCol7_Return5	; F7C50C  jr Z,0xf7c527
	dec	1, a	; F7C50E  dec 1,A
	ld	(S0ngC0py_ToTrack:16), a	; F7C510  ld (0x0e0f),A
	ld	(DisplayListB_Stage+15:16), a	; F7C514  ld (0x1305),A
	cp	(S0ngC0py_FromTrack:16), 0x12	; F7C518  cp (0x0e0e),0x12
	jr	nz, S0ngC0py_StageZero_SoftKeyCol7_Return5	; F7C51D  jr NZ,0xf7c527
	ld	(S0ngC0py_FromTrack:16), a	; F7C51F  ld (0x0e0e),A
	ld	(DisplayListB_Stage+14:16), a	; F7C523  ld (0x1304),A
S0ngC0py_StageZero_SoftKeyCol7_Return5:
	ret	; F7C527  ret

; --------------------------------------------------------------------------
; S0ngC0py_StageZero_SoftKeyCol8
; Called from: T_S0ngC0py_StageZero_SoftKeyCol8 (x1)
; Touches: (0x0E0E) (0x0E0F) (0x1304) (0x1305) (0x2075)
; Evidence: thunk slot T_S0ngC0py_StageZero_SoftKeyCol8 holds `jp 0x00F7C528`, and 0xF7C528 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; S0ngC0py_StageZero_SoftKeyCol8: the SoftKeyCol8 action of S0ngC0py_StageZero -- called only by SoftKeyCol8_S0ngC0py_StageZero.
S0ngC0py_StageZero_SoftKeyCol8:		; <- T_S0ngC0py_StageZero_SoftKeyCol8
	or	(UI_RequestBits:16), 0x08	; F7C528  or (0x2075),0x08
	ld	a, (S0ngC0py_ToTrack:16)	; F7C52D  ld A,(0x0e0f)
	ld	l, 18:opc	; F7C531  ld L,0x12
	cp	a, l	; F7C533  cp A,L
	jr	z, S0ngC0py_StageZero_SoftKeyCol8_Return6	; F7C535  jr Z,0xf7c554
	inc	1, a	; F7C537  inc 1,A
	ld	(S0ngC0py_ToTrack:16), a	; F7C539  ld (0x0e0f),A
	ld	(DisplayListB_Stage+15:16), a	; F7C53D  ld (0x1305),A
	cp	a, 18	; F7C541  cp A,0x12
	jr	nz, S0ngC0py_StageZero_SoftKeyCol8_Return6	; F7C544  jr NZ,0xf7c554
	cp	(S0ngC0py_FromTrack:16), a	; F7C546  cp (0x0e0e),A
	jr	z, S0ngC0py_StageZero_SoftKeyCol8_Return6	; F7C54A  jr Z,0xf7c554
	ld	(S0ngC0py_FromTrack:16), a	; F7C54C  ld (0x0e0e),A
	ld	(DisplayListB_Stage+14:16), a	; F7C550  ld (0x1304),A
S0ngC0py_StageZero_SoftKeyCol8_Return6:
	ret	; F7C554  ret

; --------------------------------------------------------------------------
; S0ngC0py_LcdKeyRow2
; Called from: T_S0ngC0py_LcdKeyRow2 (x2)
; Touches: (0x0E0C) (0x0E0D) (0x0E0E) (0x0E34) (0x2070) (0x2071) (0x207E)  |
;          0x000022 0x610000
; Calls:   T_S0ngC0py_Execute
; Evidence: thunk slot T_S0ngC0py_LcdKeyRow2 holds `jp 0x00F7C555`, and 0xF7C555 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; S0ngC0py_LcdKeyRow2: the LcdKeyRow2 action of S0ngC0py_StageNonZero, S0ngC0py_StageZero -- called only by LcdKeyRow2_S0ngC0py_StageNonZero, LcdKeyRow2_S0ngC0py_StageZero.
S0ngC0py_LcdKeyRow2:		; <- T_S0ngC0py_LcdKeyRow2
	cp	(UI_ScreenStage:16), 0x00	; F7C555  cp (0x207e),0x00
	jrl	nz, S0ngC0py_LcdKeyRow2_Skip2	; F7C55A  jrl NZ,0xf7c5b0
	ld	(3636:16), 0	; F7C55D  ld (0x0e34),0x00
	cp	(S0ngC0py_FromTrack:16), 0x12	; F7C562  cp (0x0e0e),0x12
	jrl	z, S0ngC0py_LcdKeyRow2_Skip	; F7C567  jrl Z,0xf7c5a4
	ld	a, (S0ngC0py_FromSong:16)	; F7C56A  ld A,(0x0e0c)
	cp	a, (S0ngC0py_ToSong:16)	; F7C56E  cp A,(0x0e0d)
	jrl	z, S0ngC0py_LcdKeyRow2_Skip	; F7C572  jrl Z,0xf7c5a4
	ld	xde, 6356992	; F7C575  ld XDE,0x00610000
	push	xbc	; F7C57A  push XBC
	xor	xhl, xhl	; F7C57B  xor XHL,XHL
	ld	l, (S0ngC0py_FromSong:16)	; F7C57D  ld L,(0x0e0c)
	dec	1, l	; F7C581  dec 1,L
	ld	xbc, xhl	; F7C583  ld XBC,XHL
	sla	xhl, 11	; F7C585  sla 0x0b,XHL
	sla	xbc, 10	; F7C588  sla 0x0a,XBC
	add	xhl, xbc	; F7C58B  add XHL,XBC
	pop	xbc	; F7C58D  pop XBC
	add	xde, xhl	; F7C58E  add XDE,XHL
	ld	xhl, 34	; F7C590  ld XHL,0x00000022
	add	xhl, xde	; F7C595  add XHL,XDE
	xor	bc, bc	; F7C597  xor BC,BC
	ld	c, (S0ngC0py_FromTrack:16)	; F7C599  ld C,(0x0e0e)
	dec	1, c	; F7C59D  dec 1,C
	ld	a, (xhl+bc)	; F7C59F  ld A,(XHL+BC)
S0ngC0py_LcdKeyRow2_Skip:
	ld	(UI_ScreenStage:16), 1	; F7C5A4  ld (0x207e),0x01
	or	(UI_Request_Hi:16), 0x10	; F7C5A9  or (0x2071),0x10
	jr	S0ngC0py_LcdKeyRow2_Return7	; F7C5AE  jr T,0xf7c5bf
S0ngC0py_LcdKeyRow2_Skip2:
	call	T_S0ngC0py_Execute	; F7C5B0  call 0xf4271c
	ldw	(UI_Request:16), 16555	; F7C5B4  ld (0x2070),0x40ab
	ld	(UI_ScreenStage:16), 0	; F7C5BA  ld (0x207e),0x00
S0ngC0py_LcdKeyRow2_Return7:
	ret	; F7C5BF  ret

; --------------------------------------------------------------------------
; S0ngC0py_ReturnToStageZero
; Called from: T_S0ngC0py_ReturnToStageZero (x2)
; Touches: (0x2071) (0x207E)
; Evidence: thunk slot T_S0ngC0py_ReturnToStageZero holds `jp 0x00F7C5C0`, and 0xF7C5C0 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; S0ngC0py_ReturnToStageZero: UI_ScreenStage = 0 and UI_Request_Hi |= 0x10 -- back to stage 0 of S0ngC0py_StageNonZero;
;   called by ExitKey_S0ngC0py_StageNonZero, LcdKeyRow3_S0ngC0py_StageNonZero (notes/prom_ab_stage_zero_names.py).
S0ngC0py_ReturnToStageZero:		; <- T_S0ngC0py_ReturnToStageZero
	ld	(UI_ScreenStage:16), 0	; F7C5C0  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7C5C5  or (0x2071),0x10
	ret	; F7C5CA  ret

; --------------------------------------------------------------------------
; PanelWrite_OnEnter
; Called from: T_PanelWrite_OnEnter (x1)
; Touches: (0x2070) (0x207A) (0x207B) (0x2880)
; Evidence: thunk slot T_PanelWrite_OnEnter holds `jp 0x00F7C5CB`, and 0xF7C5CB is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; PanelWrite_OnEnter: Paint_PanelWrite's first step (slot T_PanelWrite_OnEnter): on a newly entered screen (latch changed)
;   UI_StatusCode := 0xFF; otherwise, when UI_StatusCode is 0x23 (PanelWrite_Execute finished), UI_Request := 0x801A,
;   back to screen 0x1A (EDIT). Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
PanelWrite_OnEnter:		; <- T_PanelWrite_OnEnter
	ld	a, (UI_ScreenLatch:16)	; F7C5CB  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F7C5CF  cp A,(0x207b)
	jr	z, PanelWrite_OnEnter_Skip3	; F7C5D3  jr Z,0xf7c5dc
	ld	(UI_StatusCode:16), 255	; F7C5D5  ld (0x2880),0xff
	jr	PanelWrite_OnEnter_Return8	; F7C5DA  jr T,0xf7c5e9
PanelWrite_OnEnter_Skip3:
	cp	(UI_StatusCode:16), 0x23	; F7C5DC  cp (0x2880),0x23
	jr	nz, PanelWrite_OnEnter_Return8	; F7C5E1  jr NZ,0xf7c5e9
	ldw	(UI_Request:16), 32794	; F7C5E3  ld (0x2070),0x801a
PanelWrite_OnEnter_Return8:
	ret	; F7C5E9  ret

; --------------------------------------------------------------------------
; sub_F7C5EA
; Called from: T_F42AB8 (x0)
; Touches: (0x207A)
; Calls:   T_Seq_RequestRewind
; Evidence: thunk slot T_F42AB8 holds `jp 0x00F7C5EA`, and 0xF7C5EA is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F7C5EA:		; <- T_F42AB8
	cp	(UI_ScreenLatch:16), 0x2e	; F7C5EA  cp (0x207a),0x2e
	jr	z, sub_F7C440_Return9	; F7C5EF  jr Z,0xf7c5f5
	call	T_Seq_RequestRewind	; F7C5F1  call 0xf409e0
sub_F7C440_Return9:
	ret	; F7C5F5  ret

; --------------------------------------------------------------------------
; PanelWrite_Execute
; Called from: T_PanelWrite_Execute (x1)
; Touches: (0x2070) (0x2880)
; Calls:   T_BStore_Workspace_StoreParamImage
; Evidence: thunk slot T_PanelWrite_Execute holds `jp 0x00F7C5F6`, and 0xF7C5F6 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; PanelWrite_Execute: The PANEL WRITE job: T_BStore_Workspace_StoreParamImage copies the parameter image 0x7600-0x7FFF
;   into the song workspace, then UI_StatusCode := 0x23 and UI_Request := 0x40AB, the completion message the other
;   song-edit jobs post. ScreenButtonBody_PanelWrite runs it for key codes 6 and 23 (the latter the variant-1 +0x11
;   rewrite of 6). Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
PanelWrite_Execute:		; <- T_PanelWrite_Execute
	call	T_BStore_Workspace_StoreParamImage	; F7C5F6  call 0xf42574
	ld	(UI_StatusCode:16), 35	; F7C5FA  ld (0x2880),0x23
	ldw	(UI_Request:16), 16555	; F7C5FF  ld (0x2070),0x40ab
	ret	; F7C605  ret

; --------------------------------------------------------------------------
; Transp0se_InitFields
; Called from: T_Transp0se_InitFields (x1)
; Touches: (0x0DF6) (0x12FC) (0x2070) (0x207B) (0x2880)
; Calls:   Transp0se_StageDisplayFields
; Evidence: thunk slot T_Transp0se_InitFields holds `jp 0x00F7C606`, and 0xF7C606 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Transp0se_InitFields: Paint_Transp0se's stage-0 init (slot T_Transp0se_InitFields): unless the previous screen was TRANSP0SE
;   (0x2B), Transp0se_StageDisplayFields stages the saved cells (0x0DF7)..(0x0DFC) into DisplayListB_Stage, the field cursor (0x0DF6) :=
;   1 and UI_StatusCode := 0xFF; then, when UI_StatusCode is 0x23 (job done), UI_Request := 0x801A, back to EDIT.
;   Basis: caller + body + siblings (AdvanceDelay_InitFields). (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
Transp0se_InitFields:		; <- T_Transp0se_InitFields
	cp	(UI_ScreenLatch_Previous:16), 0x2b	; F7C606  cp (0x207b),0x2b
	jr	z, Transp0se_InitFields_Skip4	; F7C60B  jr Z,0xf7c61f
	calr	Transp0se_StageDisplayFields	; F7C60D  calr 0xf7c62d
	ld	a, 1:opc	; F7C610  ld A,0x01
	ld	(3574:16), a	; F7C612  ld (0x0df6),A
	ld	(DisplayListB_Stage+6:16), a	; F7C616  ld (0x12fc),A
	ld	(UI_StatusCode:16), 255	; F7C61A  ld (0x2880),0xff
Transp0se_InitFields_Skip4:
	cp	(UI_StatusCode:16), 0x23	; F7C61F  cp (0x2880),0x23
	jr	nz, Transp0se_InitFields_Return10	; F7C624  jr NZ,0xf7c62c
	ldw	(UI_Request:16), 32794	; F7C626  ld (0x2070),0x801a
Transp0se_InitFields_Return10:
	ret	; F7C62C  ret

; --------------------------------------------------------------------------
; Transp0se_StageDisplayFields
; Called from: in-module: 0xF7C60D
; Touches: (0x0DF6) (0x0DF7) (0x0DF8) (0x0DFA) (0x0DFC) (0x0E00) (0x12F6)
;          (0x12F7) (0x12F9) (0x12FB) +1 more
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7C62D is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Transp0se_StageDisplayFields: TRANSP0SE: its working cells into DisplayListB_Stage -- track (0x0DF7) -> +0, the
;   1..999 pair (0x0DF8)/(0x0DFA) (first <= last, as Transp0se_KeypadCommit keeps them) -> +1/+3, the signed value
;   (0x0DFC) -> +5 -- field cursor (0x0DF6) := 1 (+6), and (0x0E00) := (0x0DFA) - (0x0DF8) + 1. Transp0se_InitFields
;   calls it unless the previous screen was TRANSP0SE; cf. N0teChange_StageDisplayFields. Basis: caller + body + twin.
;   (notes/naming-pilot-2026-10-06/proposals_wave8_b8.json)
Transp0se_StageDisplayFields:
	ld	a, (3575:16)	; F7C62D  ld A,(0x0df7)
	ld	(DisplayListB_Stage:16), a	; F7C631  ld (0x12f6),A
	ld	wa, (3576:16)	; F7C635  ld WA,(0x0df8)
	ld	(DisplayListB_Stage+1:16), wa	; F7C639  ld (0x12f7),WA
	ld	wa, (3578:16)	; F7C63D  ld WA,(0x0dfa)
	ld	(DisplayListB_Stage+3:16), wa	; F7C641  ld (0x12f9),WA
	ld	a, (3580:16)	; F7C645  ld A,(0x0dfc)
	ld	(DisplayListB_Stage+5:16), a	; F7C649  ld (0x12fb),A
	ld	a, 1:opc	; F7C64D  ld A,0x01
	ld	(3574:16), a	; F7C64F  ld (0x0df6),A
	ld	(DisplayListB_Stage+6:16), a	; F7C653  ld (0x12fc),A
	ld	wa, (3578:16)	; F7C657  ld WA,(0x0dfa)
	sub	wa, (0x0df8:16)	; F7C65B  sub WA,(0x0df8)
	inc	1, wa	; F7C65F  inc 1,WA
	ld	(3584:16), wa	; F7C661  ld (0x0e00),WA
	ret	; F7C665  ret

; --------------------------------------------------------------------------
; Transp0se_OnLeave
; Called from: T_Transp0se_OnLeave (x1)
; Touches: (0x207A)
; Calls:   T_Seq_RequestRewind
; Evidence: thunk slot T_Transp0se_OnLeave holds `jp 0x00F7C666`, and 0xF7C666 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Transp0se_OnLeave: the LEAVE work of Transp0se -- the one unnamed routine ScreenLeaveBody_Transp0se calls, and nothing else calls it
;   (notes/prom_ab_screen_enter_leave_work.py).
Transp0se_OnLeave:		; <- T_Transp0se_OnLeave
	cp	(UI_ScreenLatch:16), 0x2b	; F7C666  cp (0x207a),0x2b
	jr	z, Transp0se_OnLeave_Return	; F7C66B  jr Z,0xf7c671
	call	T_Seq_RequestRewind	; F7C66D  call 0xf409e0
Transp0se_OnLeave_Return:
	ret	; F7C671  ret

; --------------------------------------------------------------------------
; Transp0se_SelectField1
; Called from: T_Transp0se_SelectField1 (x1)
; Touches: (0x0DF6) (0x12FC) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_Transp0se_SelectField1 holds `jp 0x00F7C672`, and 0xF7C672 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 1 into (0x0DF6) and requests a redraw (UI_RequestBits);
;           (0x0DF6) is read by Paint_Transp0se, so it is the Transp0se screen's field cell.
; Unknown: what field 1 is on that screen.
; --------------------------------------------------------------------------
Transp0se_SelectField1:		; <- T_Transp0se_SelectField1
	or	(UI_RequestBits:16), 0x01	; F7C672  or (0x2075),0x01
	ld	a, 1:opc	; F7C677  ld A,0x01
	ld	(3574:16), a	; F7C679  ld (0x0df6),A
	ld	(DisplayListB_Stage+6:16), a	; F7C67D  ld (0x12fc),A
	ret	; F7C681  ret

; --------------------------------------------------------------------------
; Transp0se_SelectField2
; Called from: T_Transp0se_SelectField2 (x1)
; Touches: (0x0DF6) (0x12FC) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_Transp0se_SelectField2 holds `jp 0x00F7C682`, and 0xF7C682 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 2 into (0x0DF6) and requests a redraw (UI_RequestBits);
;           (0x0DF6) is read by Paint_Transp0se, so it is the Transp0se screen's field cell.
; Unknown: what field 2 is on that screen.
; --------------------------------------------------------------------------
Transp0se_SelectField2:		; <- T_Transp0se_SelectField2
	or	(UI_RequestBits:16), 0x01	; F7C682  or (0x2075),0x01
	ld	a, 2:opc	; F7C687  ld A,0x02
	ld	(3574:16), a	; F7C689  ld (0x0df6),A
	ld	(DisplayListB_Stage+6:16), a	; F7C68D  ld (0x12fc),A
	ret	; F7C691  ret

; --------------------------------------------------------------------------
; Transp0se_SelectField3
; Called from: T_Transp0se_SelectField3 (x1)
; Touches: (0x0DF6) (0x12FC) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_Transp0se_SelectField3 holds `jp 0x00F7C692`, and 0xF7C692 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 3 into (0x0DF6) and requests a redraw (UI_RequestBits);
;           (0x0DF6) is read by Paint_Transp0se, so it is the Transp0se screen's field cell.
; Unknown: what field 3 is on that screen.
; --------------------------------------------------------------------------
Transp0se_SelectField3:		; <- T_Transp0se_SelectField3
	or	(UI_RequestBits:16), 0x01	; F7C692  or (0x2075),0x01
	ld	a, 3:opc	; F7C697  ld A,0x03
	ld	(3574:16), a	; F7C699  ld (0x0df6),A
	ld	(DisplayListB_Stage+6:16), a	; F7C69D  ld (0x12fc),A
	ret	; F7C6A1  ret

; --------------------------------------------------------------------------
; Transp0se_SelectField4
; Called from: T_Transp0se_SelectField4 (x1)
; Touches: (0x0DF6) (0x12FC) (0x2075)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_Transp0se_SelectField4 holds `jp 0x00F7C6A2`, and 0xF7C6A2 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 4 into (0x0DF6) and requests a redraw (UI_RequestBits);
;           (0x0DF6) is read by Paint_Transp0se, so it is the Transp0se screen's field cell.
; Unknown: what field 4 is on that screen.
; --------------------------------------------------------------------------
Transp0se_SelectField4:		; <- T_Transp0se_SelectField4
	or	(UI_RequestBits:16), 0x01	; F7C6A2  or (0x2075),0x01
	ld	a, 4:opc	; F7C6A7  ld A,0x04
	ld	(3574:16), a	; F7C6A9  ld (0x0df6),A
	ld	(DisplayListB_Stage+6:16), a	; F7C6AD  ld (0x12fc),A
	ret	; F7C6B1  ret

; --------------------------------------------------------------------------
; Transp0se_StepFieldUp
; Called from: T_Transp0se_StepFieldUp (x2)
; Touches: (0x0C4E) (0x0C4F) (0x0DF6) (0x2075)
; Evidence: thunk slot T_Transp0se_StepFieldUp holds `jp 0x00F7C6B2`, and 0xF7C6B2 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Transp0se_StepFieldUp: TRANSPOSE: UI_RequestBits |= 8, (0x0C4E) := W, (0x0C4F) := W & 0x80 (0 = up at both call
;   sites), then steps the selected field (0x0DF6) = 1..4 through SongStore_DispatchA_1 (track, measures, ...). Its
;   callers take it for the UPPER switch (W bit 7 clear) and T_Transp0se_StepSelectedFieldDown (Transp0se_StepSelectedFieldDown) for the lower one -- the
;   Quantize_StepFieldUp / _StepFieldDown pattern. Basis: callers + body + sibling screens. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_j.json)
Transp0se_StepFieldUp:		; <- T_Transp0se_StepFieldUp
	or	(UI_RequestBits:16), 0x08	; F7C6B2  or (0x2075),0x08
	ld	(3150:16), w	; F7C6B7  ld (0x0c4e),W
	and	w, 128	; F7C6BB  and W,0x80
	ld	(3151:16), w	; F7C6BE  ld (0x0c4f),W
	ld	l, (3574:16)	; F7C6C2  ld L,(0x0df6)
	cp	l, 1:i3	; F7C6C6  cp L,1
	jp	c, (sub_F7C6B2_Code:24)	; F7C6C8  jp C,0xf7c6e5
	cp	l, 4:i3	; F7C6CD  cp L,4
	jp	ugt, (sub_F7C6B2_Code:24)	; F7C6CF  jp UGT,0xf7c6e5
	xor	h, h	; F7C6D4  xor H,H
	sla	hl, 2	; F7C6D6  sla 0x02,HL
	ld	xde, SongStore_DispatchA_1	; F7C6D9  ld XDE,0x00f7c6e6
	ld	xhl, (xde+hl)	; F7C6DE  ld XHL,(XDE+HL)
	call	(xhl)	; F7C6E3  call T,XHL
sub_F7C6B2_Code:
	ret	; F7C6E5  ret

; SongStore_DispatchA_1 -- 5 pointers, dispatched on (0x0DF6)
; Read by: one site: the `ld XDE,0x00F7C6E6` at 0xF7C6D9, 13 bytes in front
;          of the table.  (A byte scan for the address reports 0xF7C6DA,
;          which is that instruction's OPERAND field, one byte in -- the
;          instruction is at 0xF7C6D9.)  The reader is `ld L,(var) / cp L,1
;          / jp C,<ret> / cp L,4 / jp UGT,<ret> / xor H,H / sla 0x02,HL / ld
;          XDE,0x00F7C6E6 / ld XHL,(XDE+HL) / call XHL`.
; Entry count: 5, from the reader's OWN upper bound `cp L,4` at 0xF7C6CD --
;              not from dividing the byte extent by 4.  Cross-checked two
;              ways on every emit: all 5 entries land on an instruction
;              boundary of this transcription, and the word one entry
;              further on (0x2075C10E) is not an address in this module.  ⚠
;              index 0 is never selected: the reader's lower bound is `cp
;              L,1 / jp C,<ret>`.
; Entry 0: 0xF7C6FA, which is a bare `ret` -- the 0x0E padding byte doing
;          duty as a do-nothing handler.  All six tables in this module
;          share it.
; Evidence: the `ld XDE,0x00F7C6E6` at 0xF7C6D9 is the only site in prom_a
;           or prom_b that spells this address (whole-image scan at every
;           byte offset, re-run on every emit; the hit is at 0xF7C6DA, the
;           OPERAND field of that instruction, which starts one byte
;           earlier, where the byte is 0x42 = `ld XDE,imm32` -- reader_of()
;           re-checks that byte), and the five instructions after it are the
;           index arithmetic quoted above.  The word count comes from that
;           reader's own `cp L,4`, not from the byte extent.
; Unknown: what selects (0x0DF6), and what the four live handlers do -- they
;          are sub_XXXXXX below.
SongStore_DispatchA_1:
	.long	SongStore_DispatchA_1_Nop0	; [0] -> SongStore_DispatchA_1_Nop0
	.long	SongStore_DispatchA_Case1	; [1] -> SongStore_DispatchA_Case1
	.long	SongStore_DispatchA_Case2	; [2] -> SongStore_DispatchA_Case2
	.long	SongStore_DispatchA_Case3	; [3] -> SongStore_DispatchA_Case3
	.long	SongStore_DispatchA_Case4	; [4] -> SongStore_DispatchA_Case4


; --------------------------------------------------------------------------
; SongStore_DispatchA_1_Nop0
; Called from: dispatch entry SongStore_DispatchA_1[0],
;              SongStore_DispatchA_2[0], SongStore_DispatchB_1[0],
;              SongStore_DispatchB_2[0], SongStore_DispatchC_1[0],
;              SongStore_DispatchC_2[0]
; Touches: nothing with an absolute address
; Evidence: 0xF7C6FA is stored as entry 0 of SongStore_DispatchA_1, a table
;           whose reader ends `ld XHL,(XDE+HL) / call XHL`, and it is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).
; Purpose: none -- the entry is a lone `ret`.  Named SongStore_DispatchA_1_Nop0 after what reaches it
;          (was sub_F7C6FA; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
SongStore_DispatchA_1_Nop0:
	ret	; F7C6FA  ret

; --------------------------------------------------------------------------
; Transp0se_StepSelectedFieldDown
; Called from: T_Transp0se_StepSelectedFieldDown (x2)
; Touches: (0x0C4E) (0x0C4F) (0x0DF6) (0x2075)
; Evidence: thunk slot T_Transp0se_StepSelectedFieldDown holds `jp 0x00F7C6FB`, and 0xF7C6FB is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Transp0se_StepSelectedFieldDown: (0x0C4E) := W, (0x0C4F) := W & 0x80 (0x80 = down), UI_RequestBits |= 9, then
;   SongStore_DispatchA_2[(0x0DF6)] for TRANSP0SE field 1..4 (track via SeqJob_StepTrack17, start/end measure via
;   SeqJob_StepMeasure, ...). Both TRANSP0SE step keys call it when W bit 7 is set; its twin Transp0se_StepFieldUp
;   (UI_RequestBits |= 8) when clear. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave3_g.json)
Transp0se_StepSelectedFieldDown:		; <- T_Transp0se_StepSelectedFieldDown
	or	(UI_RequestBits:16), 0x09	; F7C6FB  or (0x2075),0x09
	ld	(3150:16), w	; F7C700  ld (0x0c4e),W
	and	w, 128	; F7C704  and W,0x80
	ld	(3151:16), w	; F7C707  ld (0x0c4f),W
	ld	l, (3574:16)	; F7C70B  ld L,(0x0df6)
	cp	l, 1:i3	; F7C70F  cp L,1
	jp	c, (sub_F7C6FB_Code:24)	; F7C711  jp C,0xf7c72e
	cp	l, 4:i3	; F7C716  cp L,4
	jp	ugt, (sub_F7C6FB_Code:24)	; F7C718  jp UGT,0xf7c72e
	xor	h, h	; F7C71D  xor H,H
	sla	hl, 2	; F7C71F  sla 0x02,HL
	ld	xde, SongStore_DispatchA_2	; F7C722  ld XDE,0x00f7c72f
	ld	xhl, (xde+hl)	; F7C727  ld XHL,(XDE+HL)
	call	(xhl)	; F7C72C  call T,XHL
sub_F7C6FB_Code:
	ret	; F7C72E  ret

; SongStore_DispatchA_2 -- 5 pointers, dispatched on (0x0DF6)
; Read by: one site: the `ld XDE,0x00F7C72F` at 0xF7C722, 13 bytes in front
;          of the table.  (A byte scan for the address reports 0xF7C723,
;          which is that instruction's OPERAND field, one byte in -- the
;          instruction is at 0xF7C722.)  The reader is `ld L,(var) / cp L,1
;          / jp C,<ret> / cp L,4 / jp UGT,<ret> / xor H,H / sla 0x02,HL / ld
;          XDE,0x00F7C72F / ld XHL,(XDE+HL) / call XHL`.
; Entry count: 5, from the reader's OWN upper bound `cp L,4` at 0xF7C716 --
;              not from dividing the byte extent by 4.  Cross-checked two
;              ways on every emit: all 5 entries land on an instruction
;              boundary of this transcription, and the word one entry
;              further on (0x3E2075C1) is not an address in this module.  ⚠
;              index 0 is never selected: the reader's lower bound is `cp
;              L,1 / jp C,<ret>`.
; Entry 0: 0xF7C6FA, which is a bare `ret` -- the 0x0E padding byte doing
;          duty as a do-nothing handler.  All six tables in this module
;          share it.
; Evidence: the `ld XDE,0x00F7C72F` at 0xF7C722 is the only site in prom_a
;           or prom_b that spells this address (whole-image scan at every
;           byte offset, re-run on every emit; the hit is at 0xF7C723, the
;           OPERAND field of that instruction, which starts one byte
;           earlier, where the byte is 0x42 = `ld XDE,imm32` -- reader_of()
;           re-checks that byte), and the five instructions after it are the
;           index arithmetic quoted above.  The word count comes from that
;           reader's own `cp L,4`, not from the byte extent.
; Unknown: what selects (0x0DF6), and what the four live handlers do -- they
;          are sub_XXXXXX below.
SongStore_DispatchA_2:
	.long	SongStore_DispatchA_1_Nop0	; [0] -> SongStore_DispatchA_1_Nop0
	.long	SongStore_DispatchA_Case1	; [1] -> SongStore_DispatchA_Case1
	.long	SongStore_DispatchA_Case2	; [2] -> SongStore_DispatchA_Case2
	.long	SongStore_DispatchA_Case3	; [3] -> SongStore_DispatchA_Case3
	.long	SongStore_DispatchA_Case4	; [4] -> SongStore_DispatchA_Case4


; --------------------------------------------------------------------------
; SongStore_DispatchA_Case1
; Called from: dispatch entry SongStore_DispatchA_1[1],
;              SongStore_DispatchA_2[1]
; Touches: (0x0DF7) (0x12F6) (0x2075)
; Calls:   SeqJob_StepTrack17
; Evidence: 0xF7C743 is stored as entry 1 of SongStore_DispatchA_1, a table
;           whose reader ends `ld XHL,(XDE+HL) / call XHL`, and it is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
SongStore_DispatchA_Case1:
	or	(UI_RequestBits:16), 0x09	; F7C743  or (0x2075),0x09
	ld	a, (3575:16)	; F7C748  ld A,(0x0df7)
	ld	l, 1:opc	; F7C74C  ld L,0x01
	ld	h, 17:opc	; F7C74E  ld H,0x11
	calr	SeqJob_StepTrack17	; F7C750  calr 0xf7cd01
	ld	(3575:16), a	; F7C753  ld (0x0df7),A
	ld	(DisplayListB_Stage:16), a	; F7C757  ld (0x12f6),A
	ret	; F7C75B  ret

; --------------------------------------------------------------------------
; SongStore_DispatchA_Case2
; Called from: dispatch entry SongStore_DispatchA_1[2],
;              SongStore_DispatchA_2[2]
; Touches: (0x0DF8) (0x0DFA) (0x0E00) (0x0E08) (0x12F7) (0x12F9)
; Calls:   SeqJob_StepMeasure
; Evidence: 0xF7C75C is stored as entry 2 of SongStore_DispatchA_1, a table
;           whose reader ends `ld XHL,(XDE+HL) / call XHL`, and it is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
SongStore_DispatchA_Case2:
	ld	wa, (3576:16)	; F7C75C  ld WA,(0x0df8)
	calr	SeqJob_StepMeasure	; F7C760  calr 0xf7cd5f
	ld	(3576:16), wa	; F7C763  ld (0x0df8),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7C767  ld (0x12f7),WA
	cp	wa, (0x0dfa:16)	; F7C76B  cp WA,(0x0dfa)
	jr	ule, SongStore_DispatchA_Case2_Skip	; F7C76F  jr ULE,0xf7c779
	ld	(3578:16), wa	; F7C771  ld (0x0dfa),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7C775  ld (0x12f9),WA
SongStore_DispatchA_Case2_Skip:
	ld	wa, (3578:16)	; F7C779  ld WA,(0x0dfa)
	sub	wa, (0x0df8:16)	; F7C77D  sub WA,(0x0df8)
	inc	1, wa	; F7C781  inc 1,WA
	ld	(3592:16), wa	; F7C783  ld (0x0e08),WA
	ld	(3584:16), wa	; F7C787  ld (0x0e00),WA
	ret	; F7C78B  ret

; --------------------------------------------------------------------------
; SongStore_DispatchA_Case3
; Called from: dispatch entry SongStore_DispatchA_1[3],
;              SongStore_DispatchA_2[3]
; Touches: (0x0DF8) (0x0DFA) (0x0E00) (0x0E08) (0x12F7) (0x12F9)
; Calls:   SeqJob_StepMeasure
; Evidence: 0xF7C78C is stored as entry 3 of SongStore_DispatchA_1, a table
;           whose reader ends `ld XHL,(XDE+HL) / call XHL`, and it is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
SongStore_DispatchA_Case3:
	ld	wa, (3578:16)	; F7C78C  ld WA,(0x0dfa)
	calr	SeqJob_StepMeasure	; F7C790  calr 0xf7cd5f
	ld	(3578:16), wa	; F7C793  ld (0x0dfa),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7C797  ld (0x12f9),WA
	cp	wa, (0x0df8:16)	; F7C79B  cp WA,(0x0df8)
	jr	nc, SongStore_DispatchA_Case3_Skip	; F7C79F  jr NC,0xf7c7a9
	ld	(3576:16), wa	; F7C7A1  ld (0x0df8),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7C7A5  ld (0x12f7),WA
SongStore_DispatchA_Case3_Skip:
	ld	wa, (3578:16)	; F7C7A9  ld WA,(0x0dfa)
	sub	wa, (0x0df8:16)	; F7C7AD  sub WA,(0x0df8)
	inc	1, wa	; F7C7B1  inc 1,WA
	ld	(3592:16), wa	; F7C7B3  ld (0x0e08),WA
	ld	(3584:16), wa	; F7C7B7  ld (0x0e00),WA
	ret	; F7C7BB  ret

; --------------------------------------------------------------------------
; SongStore_DispatchA_Case4
; Called from: dispatch entry SongStore_DispatchA_1[4],
;              SongStore_DispatchA_2[4]
; Touches: (0x0C4F) (0x0DFC) (0x129C) (0x12FB) (0x2075)
; Evidence: 0xF7C7BC is stored as entry 4 of SongStore_DispatchA_1, a table
;           whose reader ends `ld XHL,(XDE+HL) / call XHL`, and it is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
SongStore_DispatchA_Case4:
	or	(UI_RequestBits:16), 0x09	; F7C7BC  or (0x2075),0x09
	ld	a, (3580:16)	; F7C7C1  ld A,(0x0dfc)
	cp	(0x0c4f:16), 0x80	; F7C7C5  cp (0x0c4f),0x80
	jr	z, SongStore_DispatchA_Case4_Skip	; F7C7CA  jr Z,0xf7c7d7
	inc	1, a	; F7C7CC  inc 1,A
	cp	a, 128	; F7C7CE  cp A,0x80
	jr	nz, SongStore_DispatchA_Case4_Join	; F7C7D1  jr NZ,0xf7c7e0
	ld	a, 127:opc	; F7C7D3  ld A,0x7f
	jr	SongStore_DispatchA_Case4_Join	; F7C7D5  jr T,0xf7c7e0
SongStore_DispatchA_Case4_Skip:
	dec	1, a	; F7C7D7  dec 1,A
	cp	a, 128	; F7C7D9  cp A,0x80
	jr	nz, SongStore_DispatchA_Case4_Join	; F7C7DC  jr NZ,0xf7c7e0
	ld	a, 129:opc	; F7C7DE  ld A,0x81
SongStore_DispatchA_Case4_Join:
	ld	(3580:16), a	; F7C7E0  ld (0x0dfc),A
	ld	(DisplayListB_Stage+5:16), a	; F7C7E4  ld (0x12fb),A
	ld	(4764:16), a	; F7C7E8  ld (0x129c),A
	ldw	de, 127	; F7C7EC  ld DE,0x007f
	ret	; F7C7EF  ret

; --------------------------------------------------------------------------
; Transp0se_LcdKeyRow2
; Called from: T_Transp0se_LcdKeyRow2 (x2)
; Touches: (0x0C70) (0x0C73) (0x0C77) (0x0DF7) (0x0DF8) (0x0E00) (0x2070)
;          (0x2071) (0x2075) (0x207E) +1 more
; Calls:   T_Transp0se_Execute
; Evidence: thunk slot T_Transp0se_LcdKeyRow2 holds `jp 0x00F7C7F0`, and 0xF7C7F0 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Transp0se_LcdKeyRow2: the LcdKeyRow2 action of Transp0se_StageNonZero, Transp0se_StageZero -- called only by LcdKeyRow2_Transp0se_StageNonZero, LcdKeyRow2_Transp0se_StageZero.
Transp0se_LcdKeyRow2:		; <- T_Transp0se_LcdKeyRow2
	and	(UI_RequestBits:16), 0xf6	; F7C7F0  and (0x2075),0xf6
	cp	(UI_ScreenStage:16), 0x01	; F7C7F5  cp (0x207e),0x01
	jr	z, Transp0se_LcdKeyRow2_Skip	; F7C7FA  jr Z,0xf7c808
	ld	(UI_ScreenStage:16), 1	; F7C7FC  ld (0x207e),0x01
	or	(UI_Request_Hi:16), 0x10	; F7C801  or (0x2071),0x10
	jr	Transp0se_LcdKeyRow2_Return	; F7C806  jr T,0xf7c842
Transp0se_LcdKeyRow2_Skip:
	ld	a, (3575:16)	; F7C808  ld A,(0x0df7)
	ld	(3184:16), a	; F7C80C  ld (0x0c70),A
	ld	wa, (3576:16)	; F7C810  ld WA,(0x0df8)
	ld	(3187:16), wa	; F7C814  ld (0x0c73),WA
	ld	wa, (3584:16)	; F7C818  ld WA,(0x0e00)
	ld	(3191:16), wa	; F7C81C  ld (0x0c77),WA
	call	T_Transp0se_Execute	; F7C820  call 0xf42714
	cp	(UI_StatusCode:16), 0xff	; F7C824  cp (0x2880),0xff
	jr	z, Transp0se_LcdKeyRow2_Skip2	; F7C829  jr Z,0xf7c838
	ld	(UI_ScreenStage:16), 0	; F7C82B  ld (0x207e),0x00
	ldw	(UI_Request:16), 16555	; F7C830  ld (0x2070),0x40ab
	jr	Transp0se_LcdKeyRow2_Return	; F7C836  jr T,0xf7c842
Transp0se_LcdKeyRow2_Skip2:
	ld	(UI_ScreenStage:16), 0	; F7C838  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7C83D  or (0x2071),0x10
Transp0se_LcdKeyRow2_Return:
	ret	; F7C842  ret

; --------------------------------------------------------------------------
; Transp0se_ReturnToStageZero
; Called from: T_Transp0se_ReturnToStageZero (x2)
; Touches: (0x2071) (0x2075) (0x207E)
; Evidence: thunk slot T_Transp0se_ReturnToStageZero holds `jp 0x00F7C843`, and 0xF7C843 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Transp0se_ReturnToStageZero: UI_ScreenStage = 0 and UI_Request_Hi |= 0x10 -- back to stage 0 of Transp0se_StageNonZero;
;   called by ExitKey_Transp0se_StageNonZero, LcdKeyRow3_Transp0se_StageNonZero (notes/prom_ab_stage_zero_names.py).
Transp0se_ReturnToStageZero:		; <- T_Transp0se_ReturnToStageZero
	and	(UI_RequestBits:16), 0xf6	; F7C843  and (0x2075),0xf6
	ld	(UI_ScreenStage:16), 0	; F7C848  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7C84D  or (0x2071),0x10
	ret	; F7C852  ret

; --------------------------------------------------------------------------
; N0teChange_InitFields
; Called from: T_N0teChange_InitFields (x1)
; Touches: (0x0DED) (0x1301) (0x207B)
; Calls:   N0teChange_StageDisplayFields
; Evidence: thunk slot T_N0teChange_InitFields holds `jp 0x00F7C853`, and 0xF7C853 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; N0teChange_InitFields: Paint_N0teChange's stage-0 init (slot T_N0teChange_InitFields): unless the previous screen was N0TE CHANGE
;   (0x2D), N0teChange_StageDisplayFields and the field cursor N0teChange_Field := 1 (DisplayListB_Stage+11). Basis:
;   caller + body + siblings (AdvanceDelay_InitFields). (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
N0teChange_InitFields:		; <- T_N0teChange_InitFields
	cp	(UI_ScreenLatch_Previous:16), 0x2d	; F7C853  cp (0x207b),0x2d
	jr	z, N0teChange_InitFields_Return	; F7C858  jr Z,0xf7c868
	call	N0teChange_StageDisplayFields	; F7C85A  call 0xf7c869
	ld	a, 1:opc	; F7C85E  ld A,0x01
	ld	(N0teChange_Field:16), a	; F7C860  ld (0x0ded),A
	ld	(DisplayListB_Stage+11:16), a	; F7C864  ld (0x1301),A
N0teChange_InitFields_Return:
	ret	; F7C868  ret

; --------------------------------------------------------------------------
; N0teChange_StageDisplayFields
; Called from: in-module: 0xF7C85A
; Touches: (0x0DEE) (0x0DF0) (0x0DF2) (0x0DF4) (0x0DF5) (0x129E) (0x12F6)
;          (0x12F7) (0x12F8) (0x12F9) +5 more
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7C869 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; N0teChange_StageDisplayFields: N0TE CHANGE's fields into DisplayListB_Stage for its page: the track (0x0DEE), N0teChange_FromMeasure /
;   _ToMeasure, the two notes split into octave and note name by `divs WA,12`; (0x129E) = the measure count,
;   To - From + 1.
N0teChange_StageDisplayFields:
	ld	a, (3566:16)	; F7C869  ld A,(0x0dee)
	ld	(DisplayListB_Stage:16), a	; F7C86D  ld (0x12f6),A
	ld	wa, (N0teChange_FromMeasure:16)	; F7C871  ld WA,(0x0df0)
	ld	(DisplayListB_Stage+6:16), wa	; F7C875  ld (0x12fc),WA
	ld	wa, (N0teChange_ToMeasure:16)	; F7C879  ld WA,(0x0df2)
	ld	(DisplayListB_Stage+9:16), wa	; F7C87D  ld (0x12ff),WA
	ld	a, (N0teChange_FromNote:16)	; F7C881  ld A,(0x0df4)
	ld	(DisplayListB_Stage+5:16), a	; F7C885  ld (0x12fb),A
	xor	w, w	; F7C889  xor W,W
	ld	l, 12:opc	; F7C88B  ld L,0x0c
	divs	wa, l	; F7C88D  divs WA,L
	ld	(DisplayListB_Stage+1:16), w	; F7C88F  ld (0x12f7),W
	ld	(DisplayListB_Stage+2:16), a	; F7C893  ld (0x12f8),A
	ld	a, (N0teChange_ToNote:16)	; F7C897  ld A,(0x0df5)
	ld	(DisplayListB_Stage+8:16), a	; F7C89B  ld (0x12fe),A
	xor	w, w	; F7C89F  xor W,W
	ld	l, 12:opc	; F7C8A1  ld L,0x0c
	divs	wa, l	; F7C8A3  divs WA,L
	ld	(DisplayListB_Stage+3:16), w	; F7C8A5  ld (0x12f9),W
	ld	(DisplayListB_Stage+4:16), a	; F7C8A9  ld (0x12fa),A
	ld	wa, (N0teChange_ToMeasure:16)	; F7C8AD  ld WA,(0x0df2)
	sub	wa, (N0teChange_FromMeasure:16)	; F7C8B1  sub WA,(0x0df0)
	inc	1, wa	; F7C8B5  inc 1,WA
	ld	(4766:16), wa	; F7C8B7  ld (0x129e),WA
	ret	; F7C8BB  ret

; --------------------------------------------------------------------------
; N0teChange_OnLeave
; Called from: T_N0teChange_OnLeave (x1)
; Touches: (0x207A)
; Calls:   T_Seq_RequestRewind
; Evidence: thunk slot T_N0teChange_OnLeave holds `jp 0x00F7C8BC`, and 0xF7C8BC is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; N0teChange_OnLeave: the LEAVE work of N0teChange -- the one unnamed routine ScreenLeaveBody_N0teChange calls, and nothing else calls it
;   (notes/prom_ab_screen_enter_leave_work.py).
N0teChange_OnLeave:		; <- T_N0teChange_OnLeave
	cp	(UI_ScreenLatch:16), 0x2d	; F7C8BC  cp (0x207a),0x2d
	jr	z, N0teChange_OnLeave_Return	; F7C8C1  jr Z,0xf7c8c7
	call	T_Seq_RequestRewind	; F7C8C3  call 0xf409e0
N0teChange_OnLeave_Return:
	ret	; F7C8C7  ret

; --------------------------------------------------------------------------
; N0teChange_SelectField1
; Called from: T_N0teChange_SelectField1 (x1)
; Touches: (0x0DED) (0x1301) (0x2075)
; Evidence: thunk slot T_N0teChange_SelectField1 holds `jp 0x00F7C8C8`, and 0xF7C8C8 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; N0teChange_SelectField1: moves the N0teChange screen's cursor to field 1 -- stores 1 into N0teChange_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
N0teChange_SelectField1:		; <- T_N0teChange_SelectField1
	or	(UI_RequestBits:16), 0x09	; F7C8C8  or (0x2075),0x09
	ld	a, 1:opc	; F7C8CD  ld A,0x01
	ld	(N0teChange_Field:16), a	; F7C8CF  ld (0x0ded),A
	ld	(DisplayListB_Stage+11:16), a	; F7C8D3  ld (0x1301),A
	ret	; F7C8D7  ret

; --------------------------------------------------------------------------
; N0teChange_SelectField2
; Called from: T_N0teChange_SelectField2 (x1)
; Touches: (0x0DED) (0x1301) (0x2075)
; Evidence: thunk slot T_N0teChange_SelectField2 holds `jp 0x00F7C8D8`, and 0xF7C8D8 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; N0teChange_SelectField2: moves the N0teChange screen's cursor to field 2 -- stores 2 into N0teChange_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
N0teChange_SelectField2:		; <- T_N0teChange_SelectField2
	or	(UI_RequestBits:16), 0x09	; F7C8D8  or (0x2075),0x09
	ld	a, 2:opc	; F7C8DD  ld A,0x02
	ld	(N0teChange_Field:16), a	; F7C8DF  ld (0x0ded),A
	ld	(DisplayListB_Stage+11:16), a	; F7C8E3  ld (0x1301),A
	ret	; F7C8E7  ret

; --------------------------------------------------------------------------
; N0teChange_SelectField3
; Called from: T_N0teChange_SelectField3 (x1)
; Touches: (0x0DED) (0x1301) (0x2075)
; Evidence: thunk slot T_N0teChange_SelectField3 holds `jp 0x00F7C8E8`, and 0xF7C8E8 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; N0teChange_SelectField3: moves the N0teChange screen's cursor to field 3 -- stores 3 into N0teChange_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
N0teChange_SelectField3:		; <- T_N0teChange_SelectField3
	or	(UI_RequestBits:16), 0x09	; F7C8E8  or (0x2075),0x09
	ld	a, 3:opc	; F7C8ED  ld A,0x03
	ld	(N0teChange_Field:16), a	; F7C8EF  ld (0x0ded),A
	ld	(DisplayListB_Stage+11:16), a	; F7C8F3  ld (0x1301),A
	ret	; F7C8F7  ret

; --------------------------------------------------------------------------
; N0teChange_SelectField4
; Called from: T_N0teChange_SelectField4 (x1)
; Touches: (0x0DED) (0x1301) (0x2075)
; Evidence: thunk slot T_N0teChange_SelectField4 holds `jp 0x00F7C8F8`, and 0xF7C8F8 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; N0teChange_SelectField4: moves the N0teChange screen's cursor to field 4 -- stores 4 into N0teChange_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
N0teChange_SelectField4:		; <- T_N0teChange_SelectField4
	or	(UI_RequestBits:16), 0x09	; F7C8F8  or (0x2075),0x09
	ld	a, 4:opc	; F7C8FD  ld A,0x04
	ld	(N0teChange_Field:16), a	; F7C8FF  ld (0x0ded),A
	ld	(DisplayListB_Stage+11:16), a	; F7C903  ld (0x1301),A
	ret	; F7C907  ret

; --------------------------------------------------------------------------
; N0teChange_SelectField5
; Called from: T_N0teChange_SelectField5 (x1)
; Touches: (0x0DED) (0x1301) (0x2075)
; Evidence: thunk slot T_N0teChange_SelectField5 holds `jp 0x00F7C908`, and 0xF7C908 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; N0teChange_SelectField5: moves the N0teChange screen's cursor to field 5 -- stores 5 into N0teChange_Field
;   and requests the redraw, nothing else (notes/prom_b_select_field_names.py).
N0teChange_SelectField5:		; <- T_N0teChange_SelectField5
	or	(UI_RequestBits:16), 0x09	; F7C908  or (0x2075),0x09
	ld	a, 5:opc	; F7C90D  ld A,0x05
	ld	(N0teChange_Field:16), a	; F7C90F  ld (0x0ded),A
	ld	(DisplayListB_Stage+11:16), a	; F7C913  ld (0x1301),A
	ret	; F7C917  ret

; --------------------------------------------------------------------------
; N0teChange_StepSelectedFieldUp
; Called from: T_N0teChange_StepSelectedFieldUp (x2)
; Touches: (0x0C4E) (0x0C4F) (0x0DED) (0x2075)
; Evidence: thunk slot T_N0teChange_StepSelectedFieldUp holds `jp 0x00F7C918`, and 0xF7C918 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; N0teChange_StepSelectedFieldUp: (0x0C4E) := key code W, (0x0C4F) := W & 0x80, then the stepper for N0teChange_Field
;   1..5 from SongStore_DispatchB_1 (case 1 = SeqJob_StepTrack17 on (0x0DEE), ...). NOTE CHANGE's soft key 5 calls it
;   for the UPPER switch (W bit 7 clear, so the steppers add); the LOWER switch calls the identical twin N0teChange_StepFieldDown.
;   Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave3_h.json)
N0teChange_StepSelectedFieldUp:		; <- T_N0teChange_StepSelectedFieldUp
	or	(UI_RequestBits:16), 0x09	; F7C918  or (0x2075),0x09
	ld	(3150:16), w	; F7C91D  ld (0x0c4e),W
	and	w, 128	; F7C921  and W,0x80
	ld	(3151:16), w	; F7C924  ld (0x0c4f),W
	ld	l, (N0teChange_Field:16)	; F7C928  ld L,(0x0ded)
	cp	l, 1:i3	; F7C92C  cp L,1
	jp	c, (sub_F7C918_Code:24)	; F7C92E  jp C,0xf7c94b
	cp	l, 5:i3	; F7C933  cp L,5
	jp	ugt, (sub_F7C918_Code:24)	; F7C935  jp UGT,0xf7c94b
	xor	h, h	; F7C93A  xor H,H
	sla	hl, 2	; F7C93C  sla 0x02,HL
	ld	xde, SongStore_DispatchB_1	; F7C93F  ld XDE,0x00f7c94c
	ld	xhl, (xde+hl)	; F7C944  ld XHL,(XDE+HL)
	call	(xhl)	; F7C949  call T,XHL
sub_F7C918_Code:
	ret	; F7C94B  ret

; SongStore_DispatchB_1 -- 6 pointers, dispatched on (0x0DED)
; Read by: one site: the `ld XDE,0x00F7C94C` at 0xF7C93F, 13 bytes in front
;          of the table.  (A byte scan for the address reports 0xF7C940,
;          which is that instruction's OPERAND field, one byte in -- the
;          instruction is at 0xF7C93F.)  The reader is `ld L,(var) / cp L,1
;          / jp C,<ret> / cp L,5 / jp UGT,<ret> / xor H,H / sla 0x02,HL / ld
;          XDE,0x00F7C94C / ld XHL,(XDE+HL) / call XHL`.
; Entry count: 6, from the reader's OWN upper bound `cp L,5` at 0xF7C933 --
;              not from dividing the byte extent by 4.  Cross-checked two
;              ways on every emit: all 6 entries land on an instruction
;              boundary of this transcription, and the word one entry
;              further on (0x3E2075C1) is not an address in this module.  ⚠
;              index 0 is never selected: the reader's lower bound is `cp
;              L,1 / jp C,<ret>`.
; Entry 0: 0xF7C6FA, which is a bare `ret` -- the 0x0E padding byte doing
;          duty as a do-nothing handler.  All six tables in this module
;          share it.
; Evidence: the `ld XDE,0x00F7C94C` at 0xF7C93F is the only site in prom_a
;           or prom_b that spells this address (whole-image scan at every
;           byte offset, re-run on every emit; the hit is at 0xF7C940, the
;           OPERAND field of that instruction, which starts one byte
;           earlier, where the byte is 0x42 = `ld XDE,imm32` -- reader_of()
;           re-checks that byte), and the five instructions after it are the
;           index arithmetic quoted above.  The word count comes from that
;           reader's own `cp L,5`, not from the byte extent.
; Unknown: what selects (0x0DED), and what the four live handlers do -- they
;          are sub_XXXXXX below.
SongStore_DispatchB_1:
	.long	SongStore_DispatchA_1_Nop0	; [0] -> SongStore_DispatchA_1_Nop0
	.long	SongStore_DispatchB_Case1	; [1] -> SongStore_DispatchB_Case1
	.long	SongStore_DispatchB_Case2	; [2] -> SongStore_DispatchB_Case2
	.long	SongStore_DispatchB_Case3	; [3] -> SongStore_DispatchB_Case3
	.long	SongStore_DispatchB_Case4	; [4] -> SongStore_DispatchB_Case4
	.long	SongStore_DispatchB_Case5	; [5] -> SongStore_DispatchB_Case5


; --------------------------------------------------------------------------
; N0teChange_StepFieldDown
; Called from: T_N0teChange_StepFieldDown (x2)
; Touches: (0x0C4E) (0x0C4F) (0x0DED) (0x2075)
; Evidence: thunk slot T_N0teChange_StepFieldDown holds `jp 0x00F7C964`, and 0xF7C964 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; N0teChange_StepFieldDown: NOTE CHANGE: (0x0C4E) := W, (0x0C4F) := W & 0x80 (0x80, down: callers pass bit 7 set),
;   then steps field N0teChange_Field 1..5 through SongStore_DispatchB_2 (SeqJob_StepMeasure etc.). The down twin of
;   N0teChange_StepSelectedFieldUp (SongStore_DispatchB_1); same shape as AdvanceDelay_StepFieldDown. Basis: callers + body + sibling.
;   (notes/naming-pilot-2026-10-06/proposals_wave3_i.json)
N0teChange_StepFieldDown:		; <- T_N0teChange_StepFieldDown
	or	(UI_RequestBits:16), 0x09	; F7C964  or (0x2075),0x09
	ld	(3150:16), w	; F7C969  ld (0x0c4e),W
	and	w, 128	; F7C96D  and W,0x80
	ld	(3151:16), w	; F7C970  ld (0x0c4f),W
	ld	l, (N0teChange_Field:16)	; F7C974  ld L,(0x0ded)
	cp	l, 1:i3	; F7C978  cp L,1
	jp	c, (sub_F7C964_Code:24)	; F7C97A  jp C,0xf7c997
	cp	l, 5:i3	; F7C97F  cp L,5
	jp	ugt, (sub_F7C964_Code:24)	; F7C981  jp UGT,0xf7c997
	xor	h, h	; F7C986  xor H,H
	sla	hl, 2	; F7C988  sla 0x02,HL
	ld	xde, SongStore_DispatchB_2	; F7C98B  ld XDE,0x00f7c998
	ld	xhl, (xde+hl)	; F7C990  ld XHL,(XDE+HL)
	call	(xhl)	; F7C995  call T,XHL
sub_F7C964_Code:
	ret	; F7C997  ret

; SongStore_DispatchB_2 -- 6 pointers, dispatched on (0x0DED)
; Read by: one site: the `ld XDE,0x00F7C998` at 0xF7C98B, 13 bytes in front
;          of the table.  (A byte scan for the address reports 0xF7C98C,
;          which is that instruction's OPERAND field, one byte in -- the
;          instruction is at 0xF7C98B.)  The reader is `ld L,(var) / cp L,1
;          / jp C,<ret> / cp L,5 / jp UGT,<ret> / xor H,H / sla 0x02,HL / ld
;          XDE,0x00F7C998 / ld XHL,(XDE+HL) / call XHL`.
; Entry count: 6, from the reader's OWN upper bound `cp L,5` at 0xF7C97F --
;              not from dividing the byte extent by 4.  Cross-checked two
;              ways on every emit: all 6 entries land on an instruction
;              boundary of this transcription, and the word one entry
;              further on (0x3E2075C1) is not an address in this module.  ⚠
;              index 0 is never selected: the reader's lower bound is `cp
;              L,1 / jp C,<ret>`.
; Entry 0: 0xF7C6FA, which is a bare `ret` -- the 0x0E padding byte doing
;          duty as a do-nothing handler.  All six tables in this module
;          share it.
; Evidence: the `ld XDE,0x00F7C998` at 0xF7C98B is the only site in prom_a
;           or prom_b that spells this address (whole-image scan at every
;           byte offset, re-run on every emit; the hit is at 0xF7C98C, the
;           OPERAND field of that instruction, which starts one byte
;           earlier, where the byte is 0x42 = `ld XDE,imm32` -- reader_of()
;           re-checks that byte), and the five instructions after it are the
;           index arithmetic quoted above.  The word count comes from that
;           reader's own `cp L,5`, not from the byte extent.
; Unknown: what selects (0x0DED), and what the four live handlers do -- they
;          are sub_XXXXXX below.
SongStore_DispatchB_2:
	.long	SongStore_DispatchA_1_Nop0	; [0] -> SongStore_DispatchA_1_Nop0
	.long	SongStore_DispatchB_Case1	; [1] -> SongStore_DispatchB_Case1
	.long	SongStore_DispatchB_Case2	; [2] -> SongStore_DispatchB_Case2
	.long	SongStore_DispatchB_Case3	; [3] -> SongStore_DispatchB_Case3
	.long	SongStore_DispatchB_Case4	; [4] -> SongStore_DispatchB_Case4
	.long	SongStore_DispatchB_Case5	; [5] -> SongStore_DispatchB_Case5


; --------------------------------------------------------------------------
; SongStore_DispatchB_Case1
; Called from: dispatch entry SongStore_DispatchB_1[1],
;              SongStore_DispatchB_2[1]
; Touches: (0x0DEE) (0x12F6) (0x2075)
; Calls:   SeqJob_StepTrack17
; Evidence: 0xF7C9B0 is stored as entry 1 of SongStore_DispatchB_1, a table
;           whose reader ends `ld XHL,(XDE+HL) / call XHL`, and it is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
SongStore_DispatchB_Case1:
	or	(UI_RequestBits:16), 0x09	; F7C9B0  or (0x2075),0x09
	ld	a, (3566:16)	; F7C9B5  ld A,(0x0dee)
	ld	l, 1:opc	; F7C9B9  ld L,0x01
	ld	h, 17:opc	; F7C9BB  ld H,0x11
	calr	SeqJob_StepTrack17	; F7C9BD  calr 0xf7cd01
	ld	(3566:16), a	; F7C9C0  ld (0x0dee),A
	ld	(DisplayListB_Stage:16), a	; F7C9C4  ld (0x12f6),A
	ret	; F7C9C8  ret

; --------------------------------------------------------------------------
; SongStore_DispatchB_Case2
; Called from: dispatch entry SongStore_DispatchB_1[2],
;              SongStore_DispatchB_2[2]
; Touches: (0x0DF0) (0x0DF2) (0x129E) (0x12FC) (0x12FF)
; Calls:   SeqJob_StepMeasure
; Evidence: 0xF7C9C9 is stored as entry 2 of SongStore_DispatchB_1, a table
;           whose reader ends `ld XHL,(XDE+HL) / call XHL`, and it is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
SongStore_DispatchB_Case2:
	ld	wa, (N0teChange_FromMeasure:16)	; F7C9C9  ld WA,(0x0df0)
	calr	SeqJob_StepMeasure	; F7C9CD  calr 0xf7cd5f
	ld	(N0teChange_FromMeasure:16), wa	; F7C9D0  ld (0x0df0),WA
	ld	(DisplayListB_Stage+6:16), wa	; F7C9D4  ld (0x12fc),WA
	cp	wa, (N0teChange_ToMeasure:16)	; F7C9D8  cp WA,(0x0df2)
	jr	ule, SongStore_DispatchB_Case2_Skip	; F7C9DC  jr ULE,0xf7c9e6
	ld	(N0teChange_ToMeasure:16), wa	; F7C9DE  ld (0x0df2),WA
	ld	(DisplayListB_Stage+9:16), wa	; F7C9E2  ld (0x12ff),WA
SongStore_DispatchB_Case2_Skip:
	ld	wa, (N0teChange_ToMeasure:16)	; F7C9E6  ld WA,(0x0df2)
	sub	wa, (N0teChange_FromMeasure:16)	; F7C9EA  sub WA,(0x0df0)
	inc	1, wa	; F7C9EE  inc 1,WA
	ld	(4766:16), wa	; F7C9F0  ld (0x129e),WA
	ret	; F7C9F4  ret

; --------------------------------------------------------------------------
; SongStore_DispatchB_Case3
; Called from: dispatch entry SongStore_DispatchB_1[3],
;              SongStore_DispatchB_2[3]
; Touches: (0x0DF0) (0x0DF2) (0x129E) (0x12FC) (0x12FF)
; Calls:   SeqJob_StepMeasure
; Evidence: 0xF7C9F5 is stored as entry 3 of SongStore_DispatchB_1, a table
;           whose reader ends `ld XHL,(XDE+HL) / call XHL`, and it is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
SongStore_DispatchB_Case3:
	ld	wa, (N0teChange_ToMeasure:16)	; F7C9F5  ld WA,(0x0df2)
	calr	SeqJob_StepMeasure	; F7C9F9  calr 0xf7cd5f
	ld	(N0teChange_ToMeasure:16), wa	; F7C9FC  ld (0x0df2),WA
	ld	(DisplayListB_Stage+9:16), wa	; F7CA00  ld (0x12ff),WA
	cp	wa, (N0teChange_FromMeasure:16)	; F7CA04  cp WA,(0x0df0)
	jr	nc, SongStore_DispatchB_Case3_Skip	; F7CA08  jr NC,0xf7ca12
	ld	(N0teChange_FromMeasure:16), wa	; F7CA0A  ld (0x0df0),WA
	ld	(DisplayListB_Stage+6:16), wa	; F7CA0E  ld (0x12fc),WA
SongStore_DispatchB_Case3_Skip:
	ld	wa, (N0teChange_ToMeasure:16)	; F7CA12  ld WA,(0x0df2)
	sub	wa, (N0teChange_FromMeasure:16)	; F7CA16  sub WA,(0x0df0)
	inc	1, wa	; F7CA1A  inc 1,WA
	ld	(4766:16), wa	; F7CA1C  ld (0x129e),WA
	ret	; F7CA20  ret

; --------------------------------------------------------------------------
; SongStore_DispatchB_Case4
; Called from: dispatch entry SongStore_DispatchB_1[4],
;              SongStore_DispatchB_2[4]
; Touches: (0x0DF4) (0x12F7) (0x12F8) (0x12FB) (0x2075)
; Calls:   SeqJob_StepValueInRange
; Evidence: 0xF7CA21 is stored as entry 4 of SongStore_DispatchB_1, a table
;           whose reader ends `ld XHL,(XDE+HL) / call XHL`, and it is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
SongStore_DispatchB_Case4:
	or	(UI_RequestBits:16), 0x09	; F7CA21  or (0x2075),0x09
	ld	a, (N0teChange_FromNote:16)	; F7CA26  ld A,(0x0df4)
	ld	l, 0:opc	; F7CA2A  ld L,0x00
	ld	h, 127:opc	; F7CA2C  ld H,0x7f
	calr	SeqJob_StepValueInRange	; F7CA2E  calr 0xf7ccdb
	ld	(N0teChange_FromNote:16), a	; F7CA31  ld (0x0df4),A
	ld	(DisplayListB_Stage+5:16), a	; F7CA35  ld (0x12fb),A
	xor	w, w	; F7CA39  xor W,W
	ld	l, 12:opc	; F7CA3B  ld L,0x0c
	divs	wa, l	; F7CA3D  divs WA,L
	ld	(DisplayListB_Stage+1:16), w	; F7CA3F  ld (0x12f7),W
	ld	(DisplayListB_Stage+2:16), a	; F7CA43  ld (0x12f8),A
	ret	; F7CA47  ret

; --------------------------------------------------------------------------
; SongStore_DispatchB_Case5
; Called from: dispatch entry SongStore_DispatchB_1[5],
;              SongStore_DispatchB_2[5]
; Touches: (0x0DF5) (0x12F9) (0x12FA) (0x12FE) (0x2075)
; Calls:   SeqJob_StepValueInRange
; Evidence: 0xF7CA48 is stored as entry 5 of SongStore_DispatchB_1, a table
;           whose reader ends `ld XHL,(XDE+HL) / call XHL`, and it is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
SongStore_DispatchB_Case5:
	or	(UI_RequestBits:16), 0x09	; F7CA48  or (0x2075),0x09
	ld	a, (N0teChange_ToNote:16)	; F7CA4D  ld A,(0x0df5)
	ld	l, 0:opc	; F7CA51  ld L,0x00
	ld	h, 127:opc	; F7CA53  ld H,0x7f
	calr	SeqJob_StepValueInRange	; F7CA55  calr 0xf7ccdb
	ld	(N0teChange_ToNote:16), a	; F7CA58  ld (0x0df5),A
	ld	(DisplayListB_Stage+8:16), a	; F7CA5C  ld (0x12fe),A
	xor	w, w	; F7CA60  xor W,W
	ld	l, 12:opc	; F7CA62  ld L,0x0c
	divs	wa, l	; F7CA64  divs WA,L
	ld	(DisplayListB_Stage+3:16), w	; F7CA66  ld (0x12f9),W
	ld	(DisplayListB_Stage+4:16), a	; F7CA6A  ld (0x12fa),A
	ret	; F7CA6E  ret

; --------------------------------------------------------------------------
; N0teChange_LcdKeyRow4
; Called from: T_N0teChange_LcdKeyRow4 (x2)
; Touches: (0x0C70) (0x0C73) (0x0C77) (0x0DEE) (0x0DF0) (0x129E) (0x2070)
;          (0x2071) (0x2075) (0x207E) +1 more
; Calls:   T_N0teChange_Execute
; Evidence: thunk slot T_N0teChange_LcdKeyRow4 holds `jp 0x00F7CA6F`, and 0xF7CA6F is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; N0teChange_LcdKeyRow4: the LcdKeyRow4 action of N0teChange_StageNonZero, N0teChange_StageZero -- called only by LcdKeyRow4_N0teChange_StageNonZero, LcdKeyRow4_N0teChange_StageZero.
N0teChange_LcdKeyRow4:		; <- T_N0teChange_LcdKeyRow4
	and	(UI_RequestBits:16), 0xf6	; F7CA6F  and (0x2075),0xf6
	cp	(UI_ScreenStage:16), 0x01	; F7CA74  cp (0x207e),0x01
	jr	z, N0teChange_LcdKeyRow4_Skip	; F7CA79  jr Z,0xf7ca87
	ld	(UI_ScreenStage:16), 1	; F7CA7B  ld (0x207e),0x01
	or	(UI_Request_Hi:16), 0x10	; F7CA80  or (0x2071),0x10
	jr	N0teChange_LcdKeyRow4_Return	; F7CA85  jr T,0xf7cac1
N0teChange_LcdKeyRow4_Skip:
	ld	a, (3566:16)	; F7CA87  ld A,(0x0dee)
	ld	(3184:16), a	; F7CA8B  ld (0x0c70),A
	ld	wa, (N0teChange_FromMeasure:16)	; F7CA8F  ld WA,(0x0df0)
	ld	(3187:16), wa	; F7CA93  ld (0x0c73),WA
	ld	wa, (4766:16)	; F7CA97  ld WA,(0x129e)
	ld	(3191:16), wa	; F7CA9B  ld (0x0c77),WA
	call	T_N0teChange_Execute	; F7CA9F  call 0xf42718
	cp	(UI_StatusCode:16), 0xff	; F7CAA3  cp (0x2880),0xff
	jr	z, N0teChange_LcdKeyRow4_Skip2	; F7CAA8  jr Z,0xf7cab7
	ld	(UI_ScreenStage:16), 0	; F7CAAA  ld (0x207e),0x00
	ldw	(UI_Request:16), 16555	; F7CAAF  ld (0x2070),0x40ab
	jr	N0teChange_LcdKeyRow4_Return	; F7CAB5  jr T,0xf7cac1
N0teChange_LcdKeyRow4_Skip2:
	ld	(UI_ScreenStage:16), 0	; F7CAB7  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7CABC  or (0x2071),0x10
N0teChange_LcdKeyRow4_Return:
	ret	; F7CAC1  ret

; --------------------------------------------------------------------------
; N0teChange_ReturnToStageZero
; Called from: T_N0teChange_ReturnToStageZero (x2)
; Touches: (0x2071) (0x2075) (0x207E)
; Evidence: thunk slot T_N0teChange_ReturnToStageZero holds `jp 0x00F7CAC2`, and 0xF7CAC2 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; N0teChange_ReturnToStageZero: UI_ScreenStage = 0 and UI_Request_Hi |= 0x10 -- back to stage 0 of N0teChange_StageNonZero;
;   called by ExitKey_N0teChange_StageNonZero, LcdKeyRow5_N0teChange_StageNonZero (notes/prom_ab_stage_zero_names.py).
N0teChange_ReturnToStageZero:		; <- T_N0teChange_ReturnToStageZero
	and	(UI_RequestBits:16), 0xf6	; F7CAC2  and (0x2075),0xf6
	ld	(UI_ScreenStage:16), 0	; F7CAC7  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7CACC  or (0x2071),0x10
	ret	; F7CAD1  ret

; --------------------------------------------------------------------------
; AdvanceDelay_InitFields
; Called from: T_AdvanceDelay_InitFields (x1)
; Touches: (0x0DE5) (0x0DE6) (0x0DE8) (0x0DEA) (0x0DEC) (0x0E06) (0x12F6)
;          (0x12F7) (0x12F9) (0x12FB) +2 more
; Evidence: thunk slot T_AdvanceDelay_InitFields holds `jp 0x00F7CAD2`, and 0xF7CAD2 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; AdvanceDelay_InitFields: Paint_AdvanceDelay's init (thunk T_AdvanceDelay_InitFields): unless the previous screen was 0x2C, copies the working cells to the display stage and sets AdvanceDelay_Field = 1.
AdvanceDelay_InitFields:		; <- T_AdvanceDelay_InitFields
	cp	(UI_ScreenLatch_Previous:16), 0x2c	; F7CAD2  cp (0x207b),0x2c
	jr	z, AdvanceDelay_InitFields_Return	; F7CAD7  jr Z,0xf7cb11
	ld	a, (3558:16)	; F7CAD9  ld A,(0x0de6)
	ld	(DisplayListB_Stage:16), a	; F7CADD  ld (0x12f6),A
	ld	wa, (3560:16)	; F7CAE1  ld WA,(0x0de8)
	ld	(DisplayListB_Stage+1:16), wa	; F7CAE5  ld (0x12f7),WA
	ld	wa, (3562:16)	; F7CAE9  ld WA,(0x0dea)
	ld	(DisplayListB_Stage+3:16), wa	; F7CAED  ld (0x12f9),WA
	ld	wa, (3562:16)	; F7CAF1  ld WA,(0x0dea)
	sub	wa, (0x0de8:16)	; F7CAF5  sub WA,(0x0de8)
	inc	1, wa	; F7CAF9  inc 1,WA
	ld	(3590:16), wa	; F7CAFB  ld (0x0e06),WA
	ld	a, (3564:16)	; F7CAFF  ld A,(0x0dec)
	ld	(DisplayListB_Stage+5:16), a	; F7CB03  ld (0x12fb),A
	ld	a, 1:opc	; F7CB07  ld A,0x01
	ld	(AdvanceDelay_Field:16), a	; F7CB09  ld (0x0de5),A
	ld	(DisplayListB_Stage+6:16), a	; F7CB0D  ld (0x12fc),A
AdvanceDelay_InitFields_Return:
	ret	; F7CB11  ret

; --------------------------------------------------------------------------
; AdvanceDelay_OnLeave
; Called from: T_AdvanceDelay_OnLeave (x1)
; Touches: (0x207A)
; Calls:   T_Seq_RequestRewind
; Evidence: thunk slot T_AdvanceDelay_OnLeave holds `jp 0x00F7CB12`, and 0xF7CB12 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; AdvanceDelay_OnLeave: the LEAVE work of AdvanceDelay -- the one unnamed routine ScreenLeaveBody_AdvanceDelay calls, and nothing else calls it
;   (notes/prom_ab_screen_enter_leave_work.py).
AdvanceDelay_OnLeave:		; <- T_AdvanceDelay_OnLeave
	cp	(UI_ScreenLatch:16), 0x2c	; F7CB12  cp (0x207a),0x2c
	jr	z, AdvanceDelay_OnLeave_Return	; F7CB17  jr Z,0xf7cb1d
	call	T_Seq_RequestRewind	; F7CB19  call 0xf409e0
AdvanceDelay_OnLeave_Return:
	ret	; F7CB1D  ret

; --------------------------------------------------------------------------
; AdvanceDelay_SelectField1
; Called from: T_AdvanceDelay_SelectField1 (x1)
; Touches: (0x0DE5) (0x12FC)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_AdvanceDelay_SelectField1 holds `jp 0x00F7CB1E`, and 0xF7CB1E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 1 into AdvanceDelay_Field and requests a redraw (UI_RequestBits);
;           AdvanceDelay_Field is the AdvanceDelay screen's field cell (named in wsa1_ram.inc).
; Unknown: what field 1 is on that screen.
; --------------------------------------------------------------------------
AdvanceDelay_SelectField1:		; <- T_AdvanceDelay_SelectField1
	ld	a, 1:opc	; F7CB1E  ld A,0x01
	ld	(AdvanceDelay_Field:16), a	; F7CB20  ld (0x0de5),A
	ld	(DisplayListB_Stage+6:16), a	; F7CB24  ld (0x12fc),A
	ret	; F7CB28  ret

; --------------------------------------------------------------------------
; AdvanceDelay_SelectField2
; Called from: T_AdvanceDelay_SelectField2 (x1)
; Touches: (0x0DE5) (0x12FC)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_AdvanceDelay_SelectField2 holds `jp 0x00F7CB29`, and 0xF7CB29 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 2 into AdvanceDelay_Field and requests a redraw (UI_RequestBits);
;           AdvanceDelay_Field is the AdvanceDelay screen's field cell (named in wsa1_ram.inc).
; Unknown: what field 2 is on that screen.
; --------------------------------------------------------------------------
AdvanceDelay_SelectField2:		; <- T_AdvanceDelay_SelectField2
	ld	a, 2:opc	; F7CB29  ld A,0x02
	ld	(AdvanceDelay_Field:16), a	; F7CB2B  ld (0x0de5),A
	ld	(DisplayListB_Stage+6:16), a	; F7CB2F  ld (0x12fc),A
	ret	; F7CB33  ret

; --------------------------------------------------------------------------
; AdvanceDelay_SelectField3
; Called from: T_AdvanceDelay_SelectField3 (x1)
; Touches: (0x0DE5) (0x12FC)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_AdvanceDelay_SelectField3 holds `jp 0x00F7CB34`, and 0xF7CB34 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 3 into AdvanceDelay_Field and requests a redraw (UI_RequestBits);
;           AdvanceDelay_Field is the AdvanceDelay screen's field cell (named in wsa1_ram.inc).
; Unknown: what field 3 is on that screen.
; --------------------------------------------------------------------------
AdvanceDelay_SelectField3:		; <- T_AdvanceDelay_SelectField3
	ld	a, 3:opc	; F7CB34  ld A,0x03
	ld	(AdvanceDelay_Field:16), a	; F7CB36  ld (0x0de5),A
	ld	(DisplayListB_Stage+6:16), a	; F7CB3A  ld (0x12fc),A
	ret	; F7CB3E  ret

; --------------------------------------------------------------------------
; AdvanceDelay_SelectField4
; Called from: T_AdvanceDelay_SelectField4 (x1)
; Touches: (0x0DE5) (0x12FC)
; Superseded 2026-10-03, when the routine was named; the earlier stanza, verbatim:
; Evidence: thunk slot T_AdvanceDelay_SelectField4 holds `jp 0x00F7CB3F`, and 0xF7CB3F is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; Evidence: it stores 4 into AdvanceDelay_Field and requests a redraw (UI_RequestBits);
;           AdvanceDelay_Field is the AdvanceDelay screen's field cell (named in wsa1_ram.inc).
; Unknown: what field 4 is on that screen.
; --------------------------------------------------------------------------
AdvanceDelay_SelectField4:		; <- T_AdvanceDelay_SelectField4
	ld	a, 4:opc	; F7CB3F  ld A,0x04
	ld	(AdvanceDelay_Field:16), a	; F7CB41  ld (0x0de5),A
	ld	(DisplayListB_Stage+6:16), a	; F7CB45  ld (0x12fc),A
	ret	; F7CB49  ret

; --------------------------------------------------------------------------
; AdvanceDelay_StepFieldUp
; Called from: T_AdvanceDelay_StepFieldUp (x2)
; Touches: (0x0C4E) (0x0C4F) (0x0DE5) (0x2075)
; Evidence: thunk slot T_AdvanceDelay_StepFieldUp holds `jp 0x00F7CB4A`, and 0xF7CB4A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; AdvanceDelay_StepFieldUp: (0x0C4E) = W, (0x0C4F) = 0 (up), then field AdvanceDelay_Field 1..4 through the SongStore_DispatchC_1 table.
AdvanceDelay_StepFieldUp:		; <- T_AdvanceDelay_StepFieldUp
	ld	(3150:16), w	; F7CB4A  ld (0x0c4e),W
	ld	(3151:16), 0	; F7CB4E  ld (0x0c4f),0x00
	or	(UI_RequestBits:16), 0x09	; F7CB53  or (0x2075),0x09
	ld	l, (AdvanceDelay_Field:16)	; F7CB58  ld L,(0x0de5)
	cp	l, 1:i3	; F7CB5C  cp L,1
	jp	c, (sub_F7CB4A_Code:24)	; F7CB5E  jp C,0xf7cb7b
	cp	l, 4:i3	; F7CB63  cp L,4
	jp	ugt, (sub_F7CB4A_Code:24)	; F7CB65  jp UGT,0xf7cb7b
	xor	h, h	; F7CB6A  xor H,H
	sla	hl, 2	; F7CB6C  sla 0x02,HL
	ld	xde, SongStore_DispatchC_1	; F7CB6F  ld XDE,0x00f7cb7c
	ld	xhl, (xde+hl)	; F7CB74  ld XHL,(XDE+HL)
	call	(xhl)	; F7CB79  call T,XHL
sub_F7CB4A_Code:
	ret	; F7CB7B  ret

; SongStore_DispatchC_1 -- 5 pointers, dispatched on (0x0DE5)
; Read by: one site: the `ld XDE,0x00F7CB7C` at 0xF7CB6F, 13 bytes in front
;          of the table.  (A byte scan for the address reports 0xF7CB70,
;          which is that instruction's OPERAND field, one byte in -- the
;          instruction is at 0xF7CB6F.)  The reader is `ld L,(var) / cp L,1
;          / jp C,<ret> / cp L,4 / jp UGT,<ret> / xor H,H / sla 0x02,HL / ld
;          XDE,0x00F7CB7C / ld XHL,(XDE+HL) / call XHL`.
; Entry count: 5, from the reader's OWN upper bound `cp L,4` at 0xF7CB63 --
;              not from dividing the byte extent by 4.  Cross-checked two
;              ways on every emit: all 5 entries land on an instruction
;              boundary of this transcription, and the word one entry
;              further on (0x400C4EF1) is not an address in this module.  ⚠
;              index 0 is never selected: the reader's lower bound is `cp
;              L,1 / jp C,<ret>`.
; Entry 0: 0xF7C6FA, which is a bare `ret` -- the 0x0E padding byte doing
;          duty as a do-nothing handler.  All six tables in this module
;          share it.
; Evidence: the `ld XDE,0x00F7CB7C` at 0xF7CB6F is the only site in prom_a
;           or prom_b that spells this address (whole-image scan at every
;           byte offset, re-run on every emit; the hit is at 0xF7CB70, the
;           OPERAND field of that instruction, which starts one byte
;           earlier, where the byte is 0x42 = `ld XDE,imm32` -- reader_of()
;           re-checks that byte), and the five instructions after it are the
;           index arithmetic quoted above.  The word count comes from that
;           reader's own `cp L,4`, not from the byte extent.
; Unknown: what selects (0x0DE5), and what the four live handlers do -- they
;          are sub_XXXXXX below.
SongStore_DispatchC_1:
	.long	SongStore_DispatchA_1_Nop0	; [0] -> SongStore_DispatchA_1_Nop0
	.long	SongStore_DispatchC_Case1	; [1] -> SongStore_DispatchC_Case1
	.long	SongStore_DispatchC_Case2	; [2] -> SongStore_DispatchC_Case2
	.long	SongStore_DispatchC_Case3	; [3] -> SongStore_DispatchC_Case3
	.long	SongStore_DispatchC_Case4	; [4] -> SongStore_DispatchC_Case4


; --------------------------------------------------------------------------
; AdvanceDelay_StepFieldDown
; Called from: T_AdvanceDelay_StepFieldDown (x2)
; Touches: (0x0C4E) (0x0C4F) (0x0DE5) (0x2075)
; Evidence: thunk slot T_AdvanceDelay_StepFieldDown holds `jp 0x00F7CB90`, and 0xF7CB90 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; AdvanceDelay_StepFieldDown: the same with (0x0C4F) = 0x80 (down).
AdvanceDelay_StepFieldDown:		; <- T_AdvanceDelay_StepFieldDown
	ld	(3150:16), w	; F7CB90  ld (0x0c4e),W
	ld	(3151:16), 128	; F7CB94  ld (0x0c4f),0x80
	or	(UI_RequestBits:16), 0x09	; F7CB99  or (0x2075),0x09
	ld	(3150:16), w	; F7CB9E  ld (0x0c4e),W
	and	w, 128	; F7CBA2  and W,0x80
	ld	(3151:16), w	; F7CBA5  ld (0x0c4f),W
	ld	l, (AdvanceDelay_Field:16)	; F7CBA9  ld L,(0x0de5)
	cp	l, 1:i3	; F7CBAD  cp L,1
	jp	c, (sub_F7CB90_Code:24)	; F7CBAF  jp C,0xf7cbcc
	cp	l, 4:i3	; F7CBB4  cp L,4
	jp	ugt, (sub_F7CB90_Code:24)	; F7CBB6  jp UGT,0xf7cbcc
	xor	h, h	; F7CBBB  xor H,H
	sla	hl, 2	; F7CBBD  sla 0x02,HL
	ld	xde, SongStore_DispatchC_2	; F7CBC0  ld XDE,0x00f7cbcd
	ld	xhl, (xde+hl)	; F7CBC5  ld XHL,(XDE+HL)
	call	(xhl)	; F7CBCA  call T,XHL
sub_F7CB90_Code:
	ret	; F7CBCC  ret

; SongStore_DispatchC_2 -- 5 pointers, dispatched on (0x0DE5)
; Read by: one site: the `ld XDE,0x00F7CBCD` at 0xF7CBC0, 13 bytes in front
;          of the table.  (A byte scan for the address reports 0xF7CBC1,
;          which is that instruction's OPERAND field, one byte in -- the
;          instruction is at 0xF7CBC0.)  The reader is `ld L,(var) / cp L,1
;          / jp C,<ret> / cp L,4 / jp UGT,<ret> / xor H,H / sla 0x02,HL / ld
;          XDE,0x00F7CBCD / ld XHL,(XDE+HL) / call XHL`.
; Entry count: 5, from the reader's OWN upper bound `cp L,4` at 0xF7CBB4 --
;              not from dividing the byte extent by 4.  Cross-checked two
;              ways on every emit: all 5 entries land on an instruction
;              boundary of this transcription, and the word one entry
;              further on (0x3E2075C1) is not an address in this module.  ⚠
;              index 0 is never selected: the reader's lower bound is `cp
;              L,1 / jp C,<ret>`.
; Entry 0: 0xF7C6FA, which is a bare `ret` -- the 0x0E padding byte doing
;          duty as a do-nothing handler.  All six tables in this module
;          share it.
; Evidence: the `ld XDE,0x00F7CBCD` at 0xF7CBC0 is the only site in prom_a
;           or prom_b that spells this address (whole-image scan at every
;           byte offset, re-run on every emit; the hit is at 0xF7CBC1, the
;           OPERAND field of that instruction, which starts one byte
;           earlier, where the byte is 0x42 = `ld XDE,imm32` -- reader_of()
;           re-checks that byte), and the five instructions after it are the
;           index arithmetic quoted above.  The word count comes from that
;           reader's own `cp L,4`, not from the byte extent.
; Unknown: what selects (0x0DE5), and what the four live handlers do -- they
;          are sub_XXXXXX below.
SongStore_DispatchC_2:
	.long	SongStore_DispatchA_1_Nop0	; [0] -> SongStore_DispatchA_1_Nop0
	.long	SongStore_DispatchC_Case1	; [1] -> SongStore_DispatchC_Case1
	.long	SongStore_DispatchC_Case2	; [2] -> SongStore_DispatchC_Case2
	.long	SongStore_DispatchC_Case3	; [3] -> SongStore_DispatchC_Case3
	.long	SongStore_DispatchC_Case4	; [4] -> SongStore_DispatchC_Case4


; --------------------------------------------------------------------------
; SongStore_DispatchC_Case1
; Called from: dispatch entry SongStore_DispatchC_1[1],
;              SongStore_DispatchC_2[1]
; Touches: (0x0DE6) (0x12F6) (0x2075)
; Calls:   SeqJob_StepTrack17
; Evidence: 0xF7CBE1 is stored as entry 1 of SongStore_DispatchC_1, a table
;           whose reader ends `ld XHL,(XDE+HL) / call XHL`, and it is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
SongStore_DispatchC_Case1:
	or	(UI_RequestBits:16), 0x09	; F7CBE1  or (0x2075),0x09
	ld	a, (3558:16)	; F7CBE6  ld A,(0x0de6)
	ld	l, 1:opc	; F7CBEA  ld L,0x01
	ld	h, 17:opc	; F7CBEC  ld H,0x11
	calr	SeqJob_StepTrack17	; F7CBEE  calr 0xf7cd01
	ld	(3558:16), a	; F7CBF1  ld (0x0de6),A
	ld	(DisplayListB_Stage:16), a	; F7CBF5  ld (0x12f6),A
	ret	; F7CBF9  ret

; --------------------------------------------------------------------------
; SongStore_DispatchC_Case2
; Called from: dispatch entry SongStore_DispatchC_1[2],
;              SongStore_DispatchC_2[2]
; Touches: (0x0DE8) (0x0DEA) (0x0E06) (0x12F7) (0x12F9)
; Calls:   SeqJob_StepMeasure
; Evidence: 0xF7CBFA is stored as entry 2 of SongStore_DispatchC_1, a table
;           whose reader ends `ld XHL,(XDE+HL) / call XHL`, and it is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
SongStore_DispatchC_Case2:
	ld	wa, (3560:16)	; F7CBFA  ld WA,(0x0de8)
	call	SeqJob_StepMeasure	; F7CBFE  call 0xf7cd5f
	ld	(3560:16), wa	; F7CC02  ld (0x0de8),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7CC06  ld (0x12f7),WA
	cp	wa, (0x0dea:16)	; F7CC0A  cp WA,(0x0dea)
	jr	ule, SongStore_DispatchC_Case2_Skip	; F7CC0E  jr ULE,0xf7cc18
	ld	(3562:16), wa	; F7CC10  ld (0x0dea),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7CC14  ld (0x12f9),WA
SongStore_DispatchC_Case2_Skip:
	ld	wa, (3562:16)	; F7CC18  ld WA,(0x0dea)
	sub	wa, (0x0de8:16)	; F7CC1C  sub WA,(0x0de8)
	inc	1, wa	; F7CC20  inc 1,WA
	ld	(3590:16), wa	; F7CC22  ld (0x0e06),WA
	ret	; F7CC26  ret

; --------------------------------------------------------------------------
; SongStore_DispatchC_Case3
; Called from: dispatch entry SongStore_DispatchC_1[3],
;              SongStore_DispatchC_2[3]
; Touches: (0x0DE8) (0x0DEA) (0x0E06) (0x12F7) (0x12F9)
; Calls:   SeqJob_StepMeasure
; Evidence: 0xF7CC27 is stored as entry 3 of SongStore_DispatchC_1, a table
;           whose reader ends `ld XHL,(XDE+HL) / call XHL`, and it is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
SongStore_DispatchC_Case3:
	ld	wa, (3562:16)	; F7CC27  ld WA,(0x0dea)
	call	SeqJob_StepMeasure	; F7CC2B  call 0xf7cd5f
	ld	(3562:16), wa	; F7CC2F  ld (0x0dea),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7CC33  ld (0x12f9),WA
	cp	wa, (0x0de8:16)	; F7CC37  cp WA,(0x0de8)
	jr	nc, SongStore_DispatchC_Case3_Skip	; F7CC3B  jr NC,0xf7cc45
	ld	(3560:16), wa	; F7CC3D  ld (0x0de8),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7CC41  ld (0x12f7),WA
SongStore_DispatchC_Case3_Skip:
	ld	wa, (3562:16)	; F7CC45  ld WA,(0x0dea)
	sub	wa, (0x0de8:16)	; F7CC49  sub WA,(0x0de8)
	inc	1, wa	; F7CC4D  inc 1,WA
	ld	(3590:16), wa	; F7CC4F  ld (0x0e06),WA
	ret	; F7CC53  ret

; --------------------------------------------------------------------------
; SongStore_DispatchC_Case4
; Called from: dispatch entry SongStore_DispatchC_1[4],
;              SongStore_DispatchC_2[4]
; Touches: (0x0DEC) (0x12FB)
; Evidence: 0xF7CC54 is stored as entry 4 of SongStore_DispatchC_1, a table
;           whose reader ends `ld XHL,(XDE+HL) / call XHL`, and it is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
SongStore_DispatchC_Case4:
	ld	a, (3564:16)	; F7CC54  ld A,(0x0dec)
	ld	l, 160:opc	; F7CC58  ld L,0xa0
	ld	h, 96:opc	; F7CC5A  ld H,0x60
	bit	7, w	; F7CC5C  bit 0x07,W
	jr	nz, SongStore_DispatchC_Case4_Skip	; F7CC5F  jr NZ,0xf7cc6b
	inc	1, a	; F7CC61  inc 1,A
	cp	a, h	; F7CC63  cp A,H
	jr	le, SongStore_DispatchC_Case4_Join	; F7CC65  jr LE,0xf7cc73
	ld	a, h	; F7CC67  ld A,H
	jr	SongStore_DispatchC_Case4_Join	; F7CC69  jr T,0xf7cc73
SongStore_DispatchC_Case4_Skip:
	dec	1, a	; F7CC6B  dec 1,A
	cp	a, l	; F7CC6D  cp A,L
	jr	ge, SongStore_DispatchC_Case4_Join	; F7CC6F  jr GE,0xf7cc73
	ld	a, l	; F7CC71  ld A,L
SongStore_DispatchC_Case4_Join:
	ld	(3564:16), a	; F7CC73  ld (0x0dec),A
	ld	(DisplayListB_Stage+5:16), a	; F7CC77  ld (0x12fb),A
	ret	; F7CC7B  ret

; --------------------------------------------------------------------------
; AdvanceDelay_LcdKeyRow3
; Called from: T_AdvanceDelay_LcdKeyRow3 (x2)
; Touches: (0x0C70) (0x0C73) (0x0C77) (0x0DE6) (0x0DE8) (0x0E06) (0x2070)
;          (0x2071) (0x207E) (0x2880)
; Calls:   T_AdvanceDelay_Execute
; Evidence: thunk slot T_AdvanceDelay_LcdKeyRow3 holds `jp 0x00F7CC7C`, and 0xF7CC7C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; AdvanceDelay_LcdKeyRow3: the LcdKeyRow3 action of AdvanceDelay_StageNonZero, AdvanceDelay_StageZero -- called only by LcdKeyRow3_AdvanceDelay_StageNonZero, LcdKeyRow3_AdvanceDelay_StageZero.
AdvanceDelay_LcdKeyRow3:		; <- T_AdvanceDelay_LcdKeyRow3
	cp	(UI_ScreenStage:16), 0x01	; F7CC7C  cp (0x207e),0x01
	jr	z, AdvanceDelay_LcdKeyRow3_Skip	; F7CC81  jr Z,0xf7cc8f
	ld	(UI_ScreenStage:16), 1	; F7CC83  ld (0x207e),0x01
	or	(UI_Request_Hi:16), 0x10	; F7CC88  or (0x2071),0x10
	jr	AdvanceDelay_LcdKeyRow3_Return	; F7CC8D  jr T,0xf7ccc9
AdvanceDelay_LcdKeyRow3_Skip:
	ld	a, (3558:16)	; F7CC8F  ld A,(0x0de6)
	ld	(3184:16), a	; F7CC93  ld (0x0c70),A
	ld	wa, (3560:16)	; F7CC97  ld WA,(0x0de8)
	ld	(3187:16), wa	; F7CC9B  ld (0x0c73),WA
	ld	wa, (3590:16)	; F7CC9F  ld WA,(0x0e06)
	ld	(3191:16), wa	; F7CCA3  ld (0x0c77),WA
	call	T_AdvanceDelay_Execute	; F7CCA7  call 0xf42720
	ld	(UI_ScreenStage:16), 0	; F7CCAB  ld (0x207e),0x00
	cp	(UI_StatusCode:16), 0xff	; F7CCB0  cp (0x2880),0xff
	jr	nz, AdvanceDelay_LcdKeyRow3_Skip2	; F7CCB5  jr NZ,0xf7ccc3
	ld	(UI_ScreenStage:16), 0	; F7CCB7  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7CCBC  or (0x2071),0x10
	jr	AdvanceDelay_LcdKeyRow3_Return	; F7CCC1  jr T,0xf7ccc9
AdvanceDelay_LcdKeyRow3_Skip2:
	ldw	(UI_Request:16), 16555	; F7CCC3  ld (0x2070),0x40ab
AdvanceDelay_LcdKeyRow3_Return:
	ret	; F7CCC9  ret

; --------------------------------------------------------------------------
; AdvanceDelay_ReturnToStageZero
; Called from: T_AdvanceDelay_ReturnToStageZero (x2)
; Touches: (0x2071) (0x2075) (0x207E)
; Evidence: thunk slot T_AdvanceDelay_ReturnToStageZero holds `jp 0x00F7CCCA`, and 0xF7CCCA is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; AdvanceDelay_ReturnToStageZero: UI_ScreenStage = 0 and UI_Request_Hi |= 0x10 -- back to stage 0 of AdvanceDelay_StageNonZero;
;   called by ExitKey_AdvanceDelay_StageNonZero, LcdKeyRow4_AdvanceDelay_StageNonZero (notes/prom_ab_stage_zero_names.py).
AdvanceDelay_ReturnToStageZero:		; <- T_AdvanceDelay_ReturnToStageZero
	ld	(UI_ScreenStage:16), 0	; F7CCCA  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F7CCCF  or (0x2071),0x10
	ret	; F7CCD4  ret
	and	(UI_RequestBits:16), 0xf6	; F7CCD5  and (0x2075),0xf6
	ret	; F7CCDA  ret

; --------------------------------------------------------------------------
; SeqJob_StepValueInRange
; Called from: in-module: 0xF7ADE4 0xF7B754 0xF7BB75 0xF7CA2E 0xF7CA55
; Touches: (0x0C4E) (0x0C4F)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7CCDB is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqJob_StepValueInRange: A +- 1 in the direction (0x0C4F) holds (0x80 = down), clamped to L..H -- SeqJob_StepTrack17
;   with a caller-given upper bound. MEASURE INSERT / MEASURE COPY repeat (0..127), NOTE CHANGE's notes (0..127) and a
;   1..16 field step their fields with it. Basis: callers + body + sibling. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_c.json)
SeqJob_StepValueInRange:
	ld	c, (3150:16)	; F7CCDB  ld C,(0x0c4e)
	ld	c, 1:opc	; F7CCDF  ld C,0x01
	cp	(0x0c4f:16), 0x80	; F7CCE1  cp (0x0c4f),0x80
	jr	nz, SeqJob_StepValueInRange_Skip	; F7CCE6  jr NZ,0xf7ccea
	jr	SeqJob_StepValueInRange_Join	; F7CCE8  jr T,0xf7ccf6
SeqJob_StepValueInRange_Skip:
	add	a, c	; F7CCEA  add A,C
	cp	a, h	; F7CCEC  cp A,H
	jr	ugt, SeqJob_StepValueInRange_Skip2	; F7CCEE  jr UGT,0xf7ccf2
	jr	SeqJob_StepValueInRange_Return	; F7CCF0  jr T,0xf7cd00
SeqJob_StepValueInRange_Skip2:
	ld	a, h	; F7CCF2  ld A,H
	jr	SeqJob_StepValueInRange_Return	; F7CCF4  jr T,0xf7cd00
SeqJob_StepValueInRange_Join:
	sub	a, c	; F7CCF6  sub A,C
	cp	a, l	; F7CCF8  cp A,L
	jr	lt, SeqJob_StepValueInRange_Skip3	; F7CCFA  jr LT,0xf7ccfe
	jr	SeqJob_StepValueInRange_Return	; F7CCFC  jr T,0xf7cd00
SeqJob_StepValueInRange_Skip3:
	ld	a, l	; F7CCFE  ld A,L
SeqJob_StepValueInRange_Return:
	ret	; F7CD00  ret

; --------------------------------------------------------------------------
; SeqJob_StepTrack17
; Called from: in-module: 0xF7BE14 0xF7C1CC 0xF7C750 0xF7C9BD 0xF7CBEE
; Touches: (0x0C4E) (0x0C4F)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7CD01 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqJob_StepTrack17: A +- 1 by (0x0C4F); up: past 17 -> H, down: below L -> L.  The TRACK helper of VEL0CITY CHANGE
;   and the SongStore dispatchers.  SeqJob_StepTrack's UP path is THIS code: its `jr NZ` at 0xF7CD3B jumps to 0xF7CD10, so
;   SeqJob_StepTrack's own `cp A,18` copy (0xF7CD3F-0xF7CD4F) never runs (notes/prom_b_seqjob_field_names.py)
SeqJob_StepTrack17:
	ld	c, (3150:16)	; F7CD01  ld C,(0x0c4e)
	ld	c, 1:opc	; F7CD05  ld C,0x01
	cp	(0x0c4f:16), 0x80	; F7CD07  cp (0x0c4f),0x80
	jr	nz, SeqJob_StepTrack17_Loop	; F7CD0C  jr NZ,0xf7cd10
	jr	SeqJob_StepTrack17_Join	; F7CD0E  jr T,0xf7cd21
SeqJob_StepTrack17_Loop:
	add	a, c	; F7CD10  add A,C
	cp	a, 17	; F7CD12  cp A,0x11
	jr	ugt, SeqJob_StepTrack17_Loop2	; F7CD15  jr UGT,0xf7cd19
	jr	SeqJob_StepTrack17_Return	; F7CD17  jr T,0xf7cd2f
SeqJob_StepTrack17_Loop2:
	ld	a, h	; F7CD19  ld A,H
	jr	SeqJob_StepTrack17_Return	; F7CD1B  jr T,0xf7cd2f
	ld	a, 17:opc	; F7CD1D  ld A,0x11
	jr	SeqJob_StepTrack17_Return	; F7CD1F  jr T,0xf7cd2f
SeqJob_StepTrack17_Join:
	sub	a, c	; F7CD21  sub A,C
	cp	a, l	; F7CD23  cp A,L
	jr	lt, SeqJob_StepTrack17_Loop3	; F7CD25  jr LT,0xf7cd29
	jr	SeqJob_StepTrack17_Return	; F7CD27  jr T,0xf7cd2f
SeqJob_StepTrack17_Loop3:
	ld	a, l	; F7CD29  ld A,L
	jr	SeqJob_StepTrack17_Return	; F7CD2B  jr T,0xf7cd2f
	ld	a, 17:opc	; F7CD2D  ld A,0x11
SeqJob_StepTrack17_Return:
	ret	; F7CD2F  ret

; --------------------------------------------------------------------------
; SeqJob_StepTrack
; Called from: in-module: 0xF7B0BF 0xF7B30E 0xF7B5FD 0xF7B6D6 0xF7BA1E
;              0xF7BAF7
; Touches: (0x0C4E) (0x0C4F)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7CD30 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqJob_StepTrack: A +- 1 by (0x0C4F) (0x80 = down), bounded L..18 -- the TRACK field of every EDIT job (notes/prom_b_seqjob_field_names.py)
SeqJob_StepTrack:
	ld	c, (3150:16)	; F7CD30  ld C,(0x0c4e)
	ld	c, 1:opc	; F7CD34  ld C,0x01
	cp	(0x0c4f:16), 0x80	; F7CD36  cp (0x0c4f),0x80
	jr	nz, SeqJob_StepTrack17_Loop	; F7CD3B  jr NZ,0xf7cd10
	jr	SeqJob_StepTrack_Join	; F7CD3D  jr T,0xf7cd50
	add	a, c	; F7CD3F  add A,C
	cp	a, 18	; F7CD41  cp A,0x12
	jr	ugt, SeqJob_StepTrack17_Loop2	; F7CD44  jr UGT,0xf7cd19
	jr	SeqJob_StepTrack_Return	; F7CD46  jr T,0xf7cd5e
	ld	a, h	; F7CD48  ld A,H
	jr	SeqJob_StepTrack_Return	; F7CD4A  jr T,0xf7cd5e
	ld	a, 18:opc	; F7CD4C  ld A,0x12
	jr	SeqJob_StepTrack_Return	; F7CD4E  jr T,0xf7cd5e
SeqJob_StepTrack_Join:
	sub	a, c	; F7CD50  sub A,C
	cp	a, l	; F7CD52  cp A,L
	jr	lt, SeqJob_StepTrack17_Loop3	; F7CD54  jr LT,0xf7cd29
	jr	SeqJob_StepTrack17_Return	; F7CD56  jr T,0xf7cd2f
	ld	a, l	; F7CD58  ld A,L
	jr	SeqJob_StepTrack_Return	; F7CD5A  jr T,0xf7cd5e
	ld	a, 18:opc	; F7CD5C  ld A,0x12
SeqJob_StepTrack_Return:
	ret	; F7CD5E  ret

; --------------------------------------------------------------------------
; SeqJob_StepMeasure
; Called from: in-module: 0xF7B0F6 0xF7B12C 0xF7B345 0xF7B37B 0xF7B662
;              0xF7B698 0xF7B73B 0xF7BA83 +12 more
; Touches: (0x0C4E) (0x0C4F) (0x0E18) (0x2075)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7CD5F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqJob_StepMeasure: WA +- SongStore_StepSizeTable[(0x0E18)] by (0x0C4F), clamped 1..999 -- the MEASURE fields (notes/prom_b_seqjob_field_names.py)
SeqJob_StepMeasure:
	or	(UI_RequestBits:16), 0x09	; F7CD5F  or (0x2075),0x09
	ld	l, (3150:16)	; F7CD64  ld L,(0x0c4e)
	ld	l, (3608:16)	; F7CD68  ld L,(0x0e18)
	xor	h, h	; F7CD6C  xor H,H
	push	xde	; F7CD6E  push XDE
	ld	xde, SongStore_StepSizeTable	; F7CD6F  ld XDE,0x00f7cd98
	ld	l, (xde+hl)	; F7CD74  ld L,(XDE+HL)
	pop	xde	; F7CD79  pop XDE
	cp	(0x0c4f:16), 0x80	; F7CD7A  cp (0x0c4f),0x80
	jr	z, SeqJob_StepMeasure_Skip	; F7CD7F  jr Z,0xf7cd8e
	add	wa, hl	; F7CD81  add WA,HL
	cp	wa, 999	; F7CD83  cp WA,0x03e7
	jr	ule, SeqJob_StepMeasure_Return	; F7CD87  jr ULE,0xf7cd97
	ldw	wa, 999	; F7CD89  ld WA,0x03e7
	jr	SeqJob_StepMeasure_Return	; F7CD8C  jr T,0xf7cd97
SeqJob_StepMeasure_Skip:
	sub	wa, hl	; F7CD8E  sub WA,HL
	cp	wa, 1:i3	; F7CD90  cp WA,1
	jr	ge, SeqJob_StepMeasure_Return	; F7CD92  jr GE,0xf7cd97
	ldw	wa, 1	; F7CD94  ld WA,0x0001
SeqJob_StepMeasure_Return:
	ret	; F7CD97  ret

; SongStore_StepSizeTable -- the increment ladder for a held +/- key
;
; Read by:  one site, 0xF7CD6F `ld XDE,0x00F7CD98` then `ld L,(XDE+HL)` at
;   0xF7CD74, with HL = (0x0E18) zero-extended.
; Layout:   8 bytes, one per entry: 0, 1, 2, 3, 10, 50, 100, 200.
; Extent:   8 bytes.  0xF7CD97 is the `ret` above it; 0xF7CDA0 is `call`ed from
;   0xF7B7E3, so it is an instruction.  ⚠ The reader zero-extends L with no
;   upper-bound test, so 8 is the extent of the OBJECT by abutment, not a bound
;   the code enforces on the index.
; What the value does: it is added to WA and the sum clamped to 999
;   (`cp WA,0x03e7` at 0xF7CD83), or subtracted and clamped to 1
;   (`cp WA,1` at 0xF7CD90), selected by `cp (0x0C4F),0x80` at 0xF7CD7A.
; Evidence: the eight byte values and the single reader are both re-read from
;   the image on every emit; the clamp constants 0x03E7 and 1 are read off
;   0xF7CD83 and 0xF7CD90 in this transcription.
; Unknown:  what (0x0E18) counts.  A ladder 1,2,3,10,50,100,200 over a 1..999
;   range is the shape of a held-key acceleration, but nothing here measures it.
SongStore_StepSizeTable:
	.byte	0x00, 0x01, 0x02, 0x03, 0x0A, 0x32, 0x64, 0xC8	; F7CD98


; --------------------------------------------------------------------------
; MeasureInsert_RepeatInsert
; Called from: in-module: 0xF7B7E3
; Touches: (0x0C14) (0x0C35) (0x0C70) (0x0C73) (0x0C75) (0x0C77) (0x0C8A)
;          (0x0D4A) (0x0E17) (0x2880)
; Calls:   T_MeasureInsert_Execute
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7CDA0 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_RepeatInsert: MEASURE INSERT's repeat: when the repeat count (0x0E17) is non-zero and (0x0C8A) bit 3
;   clear, runs T_MeasureInsert_Execute (0x0E17) more times from the destination track (0x0C14) (0x7F = all with
;   (0x0C35) bit 2), source measure = the saved insert measure 0x60346D, destination (0x0C75) = it + count (0x0C77),
;   advanced by the count after each status 0x23. MeasureInsert_LcdKeyRow1 calls it after a successful first insert.
;   Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
MeasureInsert_RepeatInsert:
	cp	(0x0e17:16), 0x00	; F7CDA0  cp (0x0e17),0x00
	jr	z, MeasureInsert_RepeatInsert_Return	; F7CDA5  jr Z,0xf7ce03
	bit	3, (0x0c8a:16)	; F7CDA7  bit 3,(0x0c8a)
	jr	nz, MeasureInsert_RepeatInsert_Return	; F7CDAB  jr NZ,0xf7ce03
	ld	c, (3607:16)	; F7CDAD  ld C,(0x0e17)
	ld	a, (3092:16)	; F7CDB1  ld A,(0x0c14)
	bit	2, (0x0c35:16)	; F7CDB5  bit 2,(0x0c35)
	jr	z, MeasureInsert_RepeatInsert_Skip	; F7CDB9  jr Z,0xf7cdbd
	ld	a, 127:opc	; F7CDBB  ld A,0x7f
MeasureInsert_RepeatInsert_Skip:
	ld	(3184:16), a	; F7CDBD  ld (0x0c70),A
	ld	wa, (6304877:24)	; F7CDC1  ld WA,(0x60346d)
	ld	(3187:16), wa	; F7CDC6  ld (0x0c73),WA
	ld	wa, (6304877:24)	; F7CDCA  ld WA,(0x60346d)
	add	wa, (0x0c77:16)	; F7CDCF  add WA,(0x0c77)
	ld	(3189:16), wa	; F7CDD3  ld (0x0c75),WA
	ld	(UI_StatusCode:16), 255	; F7CDD7  ld (0x2880),0xff
	ld	(BStore_ErrorCode:16), 0	; F7CDDC  ld (0x0d4a),0x00
	pushw	bc	; F7CDE1  push BC
	call	T_MeasureInsert_Execute	; F7CDE2  call 0xf426f4
	popw	bc	; F7CDE6  pop BC
	cp	(UI_StatusCode:16), 0x23	; F7CDE7  cp (0x2880),0x23
	jr	nz, MeasureInsert_RepeatInsert_Return	; F7CDEC  jr NZ,0xf7ce03
	bit	3, (0x0c8a:16)	; F7CDEE  bit 3,(0x0c8a)
	jr	nz, MeasureInsert_RepeatInsert_Return	; F7CDF2  jr NZ,0xf7ce03
	ld	wa, (3189:16)	; F7CDF4  ld WA,(0x0c75)
	add	wa, (0x0c77:16)	; F7CDF8  add WA,(0x0c77)
	ld	(3189:16), wa	; F7CDFC  ld (0x0c75),WA
	djnz8	c, -44	; F7CE00  djnz C,0xf7cdd7
MeasureInsert_RepeatInsert_Return:
	ret	; F7CE03  ret

; --------------------------------------------------------------------------
; MeasureC0py_RepeatCopy
; Called from: in-module: 0xF7BC04
; Touches: (0x0C14) (0x0C35) (0x0C70) (0x0C73) (0x0C75) (0x0C77) (0x0C8A)
;          (0x0D4A) (0x0E16) (0x2880)
; Calls:   T_SongEdit_CopyMeasures
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF7CE04 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureC0py_RepeatCopy: MEASURE COPY's repeat: when the repeat count (0x0E16) is non-zero and (0x0C8A) bit 3 clear,
;   runs T_SongEdit_CopyMeasures (0x0E16) more times from the destination track (0x0C14) (0x7F = all with (0x0C35) bit
;   3), source measure = the saved destination measure 0x603475, destination (0x0C75) = it + count (0x0C77), advanced
;   by the count after each status 0x23. MeasureC0py_LcdKeyRow1 calls it after a successful first copy. Basis: caller
;   + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
MeasureC0py_RepeatCopy:
	cp	(0x0e16:16), 0x00	; F7CE04  cp (0x0e16),0x00
	jr	z, MeasureC0py_RepeatCopy_Return	; F7CE09  jr Z,0xf7ce67
	bit	3, (0x0c8a:16)	; F7CE0B  bit 3,(0x0c8a)
	jr	nz, MeasureC0py_RepeatCopy_Return	; F7CE0F  jr NZ,0xf7ce67
	ld	c, (3606:16)	; F7CE11  ld C,(0x0e16)
	ld	a, (3092:16)	; F7CE15  ld A,(0x0c14)
	bit	3, (0x0c35:16)	; F7CE19  bit 3,(0x0c35)
	jr	z, MeasureC0py_RepeatCopy_Skip	; F7CE1D  jr Z,0xf7ce21
	ld	a, 127:opc	; F7CE1F  ld A,0x7f
MeasureC0py_RepeatCopy_Skip:
	ld	(3184:16), a	; F7CE21  ld (0x0c70),A
	ld	wa, (6304885:24)	; F7CE25  ld WA,(0x603475)
	ld	(3187:16), wa	; F7CE2A  ld (0x0c73),WA
	ld	wa, (6304885:24)	; F7CE2E  ld WA,(0x603475)
	add	wa, (0x0c77:16)	; F7CE33  add WA,(0x0c77)
	ld	(3189:16), wa	; F7CE37  ld (0x0c75),WA
	ld	(UI_StatusCode:16), 255	; F7CE3B  ld (0x2880),0xff
	ld	(BStore_ErrorCode:16), 0	; F7CE40  ld (0x0d4a),0x00
	pushw	bc	; F7CE45  push BC
	call	T_SongEdit_CopyMeasures	; F7CE46  call 0xf426f8
	popw	bc	; F7CE4A  pop BC
	cp	(UI_StatusCode:16), 0x23	; F7CE4B  cp (0x2880),0x23
	jr	nz, MeasureC0py_RepeatCopy_Return	; F7CE50  jr NZ,0xf7ce67
	bit	3, (0x0c8a:16)	; F7CE52  bit 3,(0x0c8a)
	jr	nz, MeasureC0py_RepeatCopy_Return	; F7CE56  jr NZ,0xf7ce67
	ld	wa, (3189:16)	; F7CE58  ld WA,(0x0c75)
	add	wa, (0x0c77:16)	; F7CE5C  add WA,(0x0c77)
	ld	(3189:16), wa	; F7CE60  ld (0x0c75),WA
	djnz8	c, -44	; F7CE64  djnz C,0xf7ce3b
MeasureC0py_RepeatCopy_Return:
	ret	; F7CE67  ret
	.fill	408, 1, 0x0E	; F7CE68-F7CFFF  `ret` padding (asserted pure 0x0E)
