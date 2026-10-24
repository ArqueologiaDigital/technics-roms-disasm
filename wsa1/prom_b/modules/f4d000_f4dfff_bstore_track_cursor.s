

; --------------------------------------------------------------------------
; BStore_AdvanceCursorForWrite_B
; Called from: T_BStore_AdvanceCursorForWrite_B (x9)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_AdvanceCursorForWrite_B holds `jp 0x00F4D000`, and 0xF4D000 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_AdvanceCursorForWrite_B: prom_b copy of BStore_AdvanceCursorForWrite without its (0x1238) flag:
;   BStore_CursorOffset + 1, or at offset 255 BStore_ExtendChainAtCursor_B (new block, cursor at offset 5) when a
;   block is free (none free: cursor left at 255). Slot T_BStore_AdvanceCursorForWrite_B (x9): the record writers' 'write a byte
;   (T_BStore_WriteCursorByte), then advance' step, e.g. SeqRecord_TerminateTrackAtCursor. Basis: callers + body +
;   twin. (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
BStore_AdvanceCursorForWrite_B:		; <- T_BStore_AdvanceCursorForWrite_B
	jr	BStore_StepCursorOneByte_Join2	; F4D000  jr T,0xf4d05f

; --------------------------------------------------------------------------
; BStore_ExtendChainAtCursor_B
; Called from: T_BStore_ExtendChainAtCursor_B (x1); in-module: 0xF4D072
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_ExtendChainAtCursor_B holds `jp 0x00F4D002`, and 0xF4D002 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ExtendChainAtCursor_B: Allocates a block (BStore_AllocBlock_B), links it after the cursor block (its +3 :=
;   new, new +1 := old, new +3 := 0xFFFF), moves the cursor to it at offset 5 and refreshes
;   SongMemory_UpdateFreePercent. prom_b copy of BStore_ExtendChainAtCursor; called by the write-cursor step behind
;   T_BStore_AdvanceCursorForWrite_B (twin of BStore_AdvanceCursorForWrite) at offset 255, and via T_BStore_ExtendChainAtCursor_B. Basis: twin + caller chain.
;   (notes/naming-pilot-2026-10-06/proposals_wave5_p.json)
BStore_ExtendChainAtCursor_B:		; <- T_BStore_ExtendChainAtCursor_B
	jrl	BStore_StepCursorOneByte_Join3	; F4D002  jrl T,0xf4d07e

; --------------------------------------------------------------------------
; TimedEventRing_ReadNext_Veneer
; Called from: T_TimedEventRing_ReadNext_Veneer (x2)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_TimedEventRing_ReadNext_Veneer holds `jp 0x00F4D005`, and 0xF4D005 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TimedEventRing_ReadNext_Veneer: Veneer: `jrl` to 0xF4D11D (local label BStore_WriteCursorByte_Join4), which, with XHL = the ring
;   block 0x600800, returns A = TimedEvents_Ring[get index (+2)] and advances that index modulo 0x200; the count is
;   not touched. TimedEvents_ClearEndedTrackBits reads its {0x82, n} records with it (slot T_TimedEventRing_ReadNext_Veneer, twice). Basis:
;   caller + body. (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
TimedEventRing_ReadNext_Veneer:		; <- T_TimedEventRing_ReadNext_Veneer
	jrl	BStore_WriteCursorByte_Join4	; F4D005  jrl T,0xf4d11d

; --------------------------------------------------------------------------
; TimedEventRing_SkipByte_Veneer
; Called from: T_TimedEventRing_SkipByte_Veneer (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_TimedEventRing_SkipByte_Veneer holds `jp 0x00F4D008`, and 0xF4D008 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TimedEventRing_SkipByte_Veneer: Veneer `jrl` to 0xF4D13E (labelled BStore_WriteCursorByte_Join5), which with XHL = the ring
;   control block 0x600800 advances its get index (+2) by one, wrapping at 0x200, without reading the byte.
;   TimedEvents_ClearEndedTrackBits uses it after reading a 0x82 status to step over the record's next byte. Basis:
;   caller + body (target read). (notes/naming-pilot-2026-10-06/proposals_wave4_n.json)
TimedEventRing_SkipByte_Veneer:		; <- T_TimedEventRing_SkipByte_Veneer
	jrl	BStore_WriteCursorByte_Join5	; F4D008  jrl T,0xf4d13e

; --------------------------------------------------------------------------
; BStore_WriteCursorByte_Join6_Veneer
; Called from: T_BStore_WriteCursorByte_Join6_Veneer (x3)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_WriteCursorByte_Join6_Veneer holds `jp 0x00F4D00B`, and 0xF4D00B is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_WriteCursorByte_Join6_Veneer: jumps to BStore_WriteCursorByte_Join6 (notes/prom_ab_wrapper_names.py; DERIVATIVE)
BStore_WriteCursorByte_Join6_Veneer:		; <- T_BStore_WriteCursorByte_Join6_Veneer
	jrl	BStore_WriteCursorByte_Join6	; F4D00B  jrl T,0xf4d155

; --------------------------------------------------------------------------
; BStore_ClearSongStore
; Called from: T_BStore_ClearSongStore (x2)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_ClearSongStore holds `jp 0x00F4D00E`, and 0xF4D00E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ClearSongStore: Empties the song store: a `jrl` to BStore_WriteCursorByte_Join7, which zeroes (0x3010) and (0x360C),
;   clears the in-use bit and sets head 0xFFFF in all 17 directory entries, rebuilds the free list over every heap
;   block (BStore_FormatHeap), resets the workspace fields, copies the reset ranges into all ten bank copies (BStore_CopyWorkspaceRangesToAllBanks,
;   BStore_CopyChainStateToAllBanks), and zeroes BStore_Password and (0x6034D6). Run by INITIAL TOTAL (Initial_Total, SysExInitial_Total
;   through T_F40A00) and by BStore_ResetWorkspaceToDefault. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_k.json)
BStore_ClearSongStore:		; <- T_BStore_ClearSongStore
	jrl	BStore_WriteCursorByte_Join7	; F4D00E  jrl T,0xf4d16e

; --------------------------------------------------------------------------
; BStore_ClearTrackIfInRange
; Called from: T_BStore_ClearTrackIfInRange (x2)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_ClearTrackIfInRange holds `jp 0x00F4D011`, and 0xF4D011 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ClearTrackIfInRange: Veneer to the range check in front of BStore_ClearTrack: when 1 <= (0x0C70) <= 17,
;   empties track (0x0C70)-1 (BStore_ClearTrack); else nothing. Slot T_BStore_ClearTrackIfInRange (and T_F40A04 -> T_BStore_ClearTrackIfInRange):
;   SeqRecord_BeginTake clears each take track with it before SeqRecord_AllocTakeChains. Basis: caller + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
BStore_ClearTrackIfInRange:		; <- T_BStore_ClearTrackIfInRange
	jrl	BStore_CopyChainStateToAllBanks_Join	; F4D011  jrl T,0xf4d333

; --------------------------------------------------------------------------
; BStore_SpliceChainIntoTrack
; Called from: T_BStore_SpliceChainIntoTrack (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_SpliceChainIntoTrack holds `jp 0x00F4D014`, and 0xF4D014 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_SpliceChainIntoTrack: Veneer (slot T_BStore_SpliceChainIntoTrack) to the routine after BStore_ClearTrack: for track (0x349F) moves
;   the bytes from (0x3548/0x354A) to the track end down to (0x34EA/0x34EC) (T_BStore_CopyRangeForward_Call, the unnamed range copy
;   sub_F62DC9), frees blocks past the new end, puts the live cursor there, then inserts chain 0x34EE[t]'s payload
;   block by block (T_BStore_AppendBytes_Veneer, each block freed; the last up to 0x3532[t]). CycleRecord_CommitTake's
;   splice. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
BStore_SpliceChainIntoTrack:		; <- T_BStore_SpliceChainIntoTrack
	jrl	BStore_ClearTrack_Join2	; F4D014  jrl T,0xf4d3e1

; --------------------------------------------------------------------------
; BStore_SeekChainToBeat
; Called from: T_BStore_SeekChainToBeat (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_SeekChainToBeat holds `jp 0x00F4D017`, and 0xF4D017 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_SeekChainToBeat: `jrl` to 0xF4D5B7: opens chain A (track + 1) and walks it counting 0x81 beat marks (IX)
;   until IX = (0x0C55), tracking the measure (DE) by the time signature; returns A = (0x0D1C) beats per bar, DE the
;   measure, C the beat in it and the cursor there; 0x82 first gives BStore_ErrorCode 8. BStore_SeekChainToMeasure's
;   beat twin; Seq_LocateToSongPosition calls it per track. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_l.json)
BStore_SeekChainToBeat:		; <- T_BStore_SeekChainToBeat
	jrl	sub_F4D346_Join4	; F4D017  jrl T,0xf4d5b7

; --------------------------------------------------------------------------
; BStore_ClearTrack_Join2_Veneer
; Called from: T_BStore_ClearTrack_Join2_Veneer (x0)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_ClearTrack_Join2_Veneer holds `jp 0x00F4D01A`, and 0xF4D01A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ClearTrack_Join2_Veneer: jumps to BStore_ClearTrack_Join2 (notes/prom_ab_wrapper_names.py; DERIVATIVE)
BStore_ClearTrack_Join2_Veneer:		; <- T_BStore_ClearTrack_Join2_Veneer
	jrl	BStore_ClearTrack_Join2	; F4D01A  jrl T,0xf4d3e1

; --------------------------------------------------------------------------
; BStore_BlockAddrFromHL
; Called from: T_BStore_BlockAddrFromHL (x21)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_BlockAddrFromHL holds `jp 0x00F4D01D`, and 0xF4D01D is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_BlockAddrFromHL: XHL := BStore_HeapBase + (HL - 1) * 0x100, the address of 1-based block HL (XWA and XIX
;   preserved) -- BStore_BlockAddrFromIY with the number in HL. Slot T_BStore_BlockAddrFromHL (x21): CycleRecord_AllocRecordChain, the
;   take allocators and the compaction scans call it with HL = a block number and then touch its header. Basis:
;   callers + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
BStore_BlockAddrFromHL:		; <- T_BStore_BlockAddrFromHL
	jrl	BStore_CursorAdvanceXHL_Join	; F4D01D  jrl T,0xf4d7a7
	jrl	BStore_FormatHeap	; F4D020  jrl T,0xf4d7bd

; --------------------------------------------------------------------------
; BStore_AllocBlock_B_Veneer
; Called from: T_BStore_AllocBlock_B_Veneer (x6)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_AllocBlock_B_Veneer holds `jp 0x00F4D023`, and 0xF4D023 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_AllocBlock_B_Veneer: Veneer: `jrl` to BStore_AllocBlock_B, prom_b's copy of BStore_AllocBlock -- pops BStore_FreeHead,
;   unlinks it, sets the block's bit 7, decrements BStore_FreeCount; IX = the block, W = 0, or W = 0xFF with an empty
;   free list. Slot T_BStore_AllocBlock_B_Veneer: EditScreen_EnterNoteEdit allocates the first block of an empty part chain with it; also
;   SeqRecord_AllocTakeChains and the cycle-record code. Basis: callers + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_m.json)
BStore_AllocBlock_B_Veneer:		; <- T_BStore_AllocBlock_B_Veneer
	jrl	BStore_AllocBlock_B	; F4D023  jrl T,0xf4d861

; --------------------------------------------------------------------------
; BStore_FreeChain_B_Veneer
; Called from: T_BStore_FreeChain_B_Veneer (x2)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_FreeChain_B_Veneer holds `jp 0x00F4D026`, and 0xF4D026 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_FreeChain_B_Veneer: jumps to BStore_FreeChain_B (notes/prom_ab_wrapper_names.py; DERIVATIVE)
BStore_FreeChain_B_Veneer:		; <- T_BStore_FreeChain_B_Veneer
	jrl	BStore_FreeChain_B	; F4D026  jrl T,0xf4d89d
	jrl	BStore_BlockAddrFromIY	; F4D029  jrl T,0xf4d935

; --------------------------------------------------------------------------
; BStore_StepCursorOneByte
; Called from: T_BStore_StepCursorOneByte (x15)
; Touches: (0x345C) (0x345E) (0x3604)
; Calls:   BStore_ExtendChainAtCursor_B BStore_AllocBlock_B T_SongMemory_UpdateFreePercent
; Evidence: thunk slot T_BStore_StepCursorOneByte holds `jp 0x00F4D02C`, and 0xF4D02C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_StepCursorOneByte: Steps the block-store cursor (BStore_CursorBlock, BStore_CursorOffset) one byte: offset +
;   1, or at offset 255 the block's +3 next link with offset 5 (the first payload byte). No end check.
;   Seq_SeekTrackToBeatTick uses it with BStore_ReadCursorByte to peek the byte after a beat mark. Basis: callers +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave4_n.json)
BStore_StepCursorOneByte:		; <- T_BStore_StepCursorOneByte
	push	xix	; F4D02C  push XIX
	ld	wa, (BStore_CursorOffset:16)	; F4D02D  ld WA,(0x345e)
	cp	wa, 255	; F4D031  cp WA,0x00ff
	jr	nz, BStore_StepCursorOneByte_Skip	; F4D035  jr NZ,0xf4d057
	xor	xhl, xhl	; F4D037  xor XHL,XHL
	ld	hl, (BStore_CursorBlock:16)	; F4D039  ld HL,(0x345c)
	dec	1, xhl	; F4D03D  dec 1,XHL
	sla	xhl, 8	; F4D03F  sla 0x08,XHL
	ld	xix, (BStore_HeapBase:16)	; F4D042  ld XIX,(0x3604)
	lda	xwa, (xix+0:8)	; F4D046  lda XWA,XIX+0x00
	add	xhl, xwa	; F4D049  add XHL,XWA
	ld	wa, (xhl+3)	; F4D04B  ld WA,(XHL+0x03)
	ld	(BStore_CursorBlock:16), wa	; F4D04E  ld (0x345c),WA
	ldw	wa, 5	; F4D052  ld WA,0x0005
	jr	BStore_StepCursorOneByte_Join	; F4D055  jr T,0xf4d059
BStore_StepCursorOneByte_Skip:
	inc	1, wa	; F4D057  inc 1,WA
BStore_StepCursorOneByte_Join:
	ld	(BStore_CursorOffset:16), wa	; F4D059  ld (0x345e),WA
	pop	xix	; F4D05D  pop XIX
	ret	; F4D05E  ret
BStore_StepCursorOneByte_Join2:
	ld	wa, (BStore_CursorOffset:16)	; F4D05F  ld WA,(0x345e)
	cp	wa, 255	; F4D063  cp WA,0x00ff
	jr	nz, BStore_StepCursorOneByte_Skip2	; F4D067  jr NZ,0xf4d077
	cpw	(BStore_FreeCount:24), 0x0000	; F4D069  cp (0x6034ba),0x0000
	jr	z, BStore_StepCursorOneByte_Return	; F4D070  jr Z,0xf4d07d
	calr	BStore_ExtendChainAtCursor_B	; F4D072  calr 0xf4d002
	jr	BStore_StepCursorOneByte_Return	; F4D075  jr T,0xf4d07d
BStore_StepCursorOneByte_Skip2:
	inc	1, wa	; F4D077  inc 1,WA
	ld	(BStore_CursorOffset:16), wa	; F4D079  ld (0x345e),WA
BStore_StepCursorOneByte_Return:
	ret	; F4D07D  ret
BStore_StepCursorOneByte_Join3:
	push	xix	; F4D07E  push XIX
	calr	BStore_AllocBlock_B	; F4D07F  calr 0xf4d861
	ld	wa, ix	; F4D082  ld WA,IX
	xor	xhl, xhl	; F4D084  xor XHL,XHL
	ld	hl, (BStore_CursorBlock:16)	; F4D086  ld HL,(0x345c)
	dec	1, xhl	; F4D08A  dec 1,XHL
	sla	xhl, 8	; F4D08C  sla 0x08,XHL
	pushw	wa	; F4D08F  push WA
	ld	xix, (BStore_HeapBase:16)	; F4D090  ld XIX,(0x3604)
	lda	xwa, (xix+0:8)	; F4D094  lda XWA,XIX+0x00
	add	xhl, xwa	; F4D097  add XHL,XWA
	popw	wa	; F4D099  pop WA
	ld	(xhl+3), wa	; F4D09A  ld (XHL+0x03),WA
	xor	xhl, xhl	; F4D09D  xor XHL,XHL
	ld	hl, wa	; F4D09F  ld HL,WA
	dec	1, xhl	; F4D0A1  dec 1,XHL
	sla	xhl, 8	; F4D0A3  sla 0x08,XHL
	pushw	wa	; F4D0A6  push WA
	ld	xix, (BStore_HeapBase:16)	; F4D0A7  ld XIX,(0x3604)
	lda	xwa, (xix+0:8)	; F4D0AB  lda XWA,XIX+0x00
	add	xhl, xwa	; F4D0AE  add XHL,XWA
	popw	wa	; F4D0B0  pop WA
	ld	bc, (BStore_CursorBlock:16)	; F4D0B1  ld BC,(0x345c)
	ld	(xhl+1), bc	; F4D0B5  ld (XHL+0x01),BC
	ldw	(xhl+3), 0xffff	; F4D0B8  ld (XHL+0x03),0xffff
	ld	(BStore_CursorBlock:16), wa	; F4D0BD  ld (0x345c),WA
	push	xwa	; F4D0C1  push XWA
	push	xbc	; F4D0C2  push XBC
	push	xde	; F4D0C3  push XDE
	push	xhl	; F4D0C4  push XHL
	push	xix	; F4D0C5  push XIX
	push	xiy	; F4D0C6  push XIY
	push	xiz	; F4D0C7  push XIZ
	call	T_SongMemory_UpdateFreePercent	; F4D0C8  call 0xf40d00
	pop	xiz	; F4D0CC  pop XIZ
	pop	xiy	; F4D0CD  pop XIY
	pop	xix	; F4D0CE  pop XIX
	pop	xhl	; F4D0CF  pop XHL
	pop	xde	; F4D0D0  pop XDE
	pop	xbc	; F4D0D1  pop XBC
	pop	xwa	; F4D0D2  pop XWA
	ldw	(BStore_CursorOffset:16), 5	; F4D0D3  ld (0x345e),0x0005
	pop	xix	; F4D0D9  pop XIX
	ret	; F4D0DA  ret

; --------------------------------------------------------------------------
; BStore_ReadCursorByte
; Called from: T_BStore_ReadCursorByte (x18)
; Touches: (0x345C) (0x345E) (0x3604)
; Evidence: thunk slot T_BStore_ReadCursorByte holds `jp 0x00F4D0DB`, and 0xF4D0DB is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ReadCursorByte: A = the byte at BStore_HeapBase + (BStore_CursorBlock - 1) * 256 + BStore_CursorOffset.
BStore_ReadCursorByte:		; <- T_BStore_ReadCursorByte
	push	xix	; F4D0DB  push XIX
	xor	xhl, xhl	; F4D0DC  xor XHL,XHL
	ld	hl, (BStore_CursorBlock:16)	; F4D0DE  ld HL,(0x345c)
	dec	1, xhl	; F4D0E2  dec 1,XHL
	sla	xhl, 8	; F4D0E4  sla 0x08,XHL
	ld	xix, (BStore_HeapBase:16)	; F4D0E7  ld XIX,(0x3604)
	lda	xwa, (xix+0:8)	; F4D0EB  lda XWA,XIX+0x00
	add	xhl, xwa	; F4D0EE  add XHL,XWA
	ld	iy, (BStore_CursorOffset:16)	; F4D0F0  ld IY,(0x345e)
	ld	a, (xhl+iy)	; F4D0F4  ld A,(XHL+IY)
	pop	xix	; F4D0F9  pop XIX
	ret	; F4D0FA  ret

; --------------------------------------------------------------------------
; BStore_WriteCursorByte
; Called from: T_BStore_WriteCursorByte (x14)
; Touches: (0x3010) (0x345C) (0x345E) (0x34D1) (0x3604) (0x360C)  |
;          0x600800 0x60080A 0x603500
; Calls:   BStore_FormatHeap T_F40A8C BStore_CopyWorkspaceRangesToAllBanks BStore_CopyChainStateToAllBanks
; Evidence: thunk slot T_BStore_WriteCursorByte holds `jp 0x00F4D0FB`, and 0xF4D0FB is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_WriteCursorByte(A): store A at the cursor address BStore_ReadCursorByte reads.
BStore_WriteCursorByte:		; <- T_BStore_WriteCursorByte
	push	xix	; F4D0FB  push XIX
	xor	xhl, xhl	; F4D0FC  xor XHL,XHL
	ld	hl, (BStore_CursorBlock:16)	; F4D0FE  ld HL,(0x345c)
	dec	1, xhl	; F4D102  dec 1,XHL
	sla	xhl, 8	; F4D104  sla 0x08,XHL
	pushw	wa	; F4D107  push WA
	ld	xix, (BStore_HeapBase:16)	; F4D108  ld XIX,(0x3604)
	lda	xwa, (xix+0:8)	; F4D10C  lda XWA,XIX+0x00
	add	xhl, xwa	; F4D10F  add XHL,XWA
	popw	wa	; F4D111  pop WA
	ld	iy, (BStore_CursorOffset:16)	; F4D112  ld IY,(0x345e)
	ld	(xhl+iy), a	; F4D116  ld (XHL+IY),A
	pop	xix	; F4D11B  pop XIX
	ret	; F4D11C  ret
BStore_WriteCursorByte_Join4:
	ld	iy, (xhl+2)	; F4D11D  ld IY,(XHL+0x02)
	ld	xhl, TimedEvents_Ring	; F4D120  ld XHL,0x0060080a
	ld	a, (xhl+iy)	; F4D125  ld A,(XHL+IY)
	inc	1, iy	; F4D12A  inc 1,IY
	cp	iy, 512	; F4D12C  cp IY,0x0200
	jr	c, BStore_WriteCursorByte_Skip3	; F4D130  jr C,0xf4d135
	ldw	iy, 0	; F4D132  ld IY,0x0000
BStore_WriteCursorByte_Skip3:
	ld	xhl, 6293504	; F4D135  ld XHL,0x00600800
	ld	(xhl+2), iy	; F4D13A  ld (XHL+0x02),IY
	ret	; F4D13D  ret
BStore_WriteCursorByte_Join5:
	ld	iy, (xhl+2)	; F4D13E  ld IY,(XHL+0x02)
	inc	1, iy	; F4D141  inc 1,IY
	cp	iy, 512	; F4D143  cp IY,0x0200
	jr	c, BStore_WriteCursorByte_Skip4	; F4D147  jr C,0xf4d14c
	ldw	iy, 0	; F4D149  ld IY,0x0000
BStore_WriteCursorByte_Skip4:
	ld	xhl, 6293504	; F4D14C  ld XHL,0x00600800
	ld	(xhl+2), iy	; F4D151  ld (XHL+0x02),IY
	ret	; F4D154  ret
BStore_WriteCursorByte_Join6:
	and	(0x34d1:16), 0xfb	; F4D155  and (0x34d1),0xfb
	ld	xhl, 6293504	; F4D15A  ld XHL,0x00600800
	ld	wa, (xhl+8)	; F4D15F  ld WA,(XHL+0x08)
	cp	wa, 10	; F4D162  cp WA,0x000a
	jr	ugt, BStore_WriteCursorByte_Return2	; F4D166  jr UGT,0xf4d16d
	or	(0x34d1:16), 0x04	; F4D168  or (0x34d1),0x04
BStore_WriteCursorByte_Return2:
	ret	; F4D16D  ret
BStore_WriteCursorByte_Join7:
	xor	xwa, xwa	; F4D16E  xor XWA,XWA
	ld	(12304:16), xwa	; F4D170  ld (0x3010),XWA
	xor	xwa, xwa	; F4D174  xor XWA,XWA
	ld	(13836:16), xwa	; F4D176  ld (0x360c),XWA
	xor	iy, iy	; F4D17A  xor IY,IY
	xor	wa, wa	; F4D17C  xor WA,WA
BStore_WriteCursorByte_Join8:
	inc	1, a	; F4D17E  inc 1,A
	cp	a, 17	; F4D180  cp A,0x11
	jr	ugt, BStore_WriteCursorByte_Skip5	; F4D183  jr UGT,0xf4d19d
	ld	xix, 6305024	; F4D185  ld XIX,0x00603500
	and	(xix+iy), 0x7f	; F4D18A  and (XIX+IY),0x7f
	inc	1, iy	; F4D190  inc 1,IY
	ldw	(xix+iy), 0xffff	; F4D192  ld (XIX+IY),0xffff
	inc	2, iy	; F4D199  inc 2,IY
	jr	BStore_WriteCursorByte_Join8	; F4D19B  jr T,0xf4d17e
BStore_WriteCursorByte_Skip5:
	calr	BStore_FormatHeap	; F4D19D  calr 0xf4d7bd
	call	T_F40A8C	; F4D1A0  call 0xf40a8c
	calr	BStore_CopyWorkspaceRangesToAllBanks	; F4D1A4  calr 0xf4d1b8
	ldw	(BStore_Password:24), 0	; F4D1A7  ld (0x60341c),0x0000
	ld	(6304982:24), 0	; F4D1AE  ld (0x6034d6),0x00
	calr	BStore_CopyChainStateToAllBanks	; F4D1B4  calr 0xf4d238
	ret	; F4D1B7  ret

; --------------------------------------------------------------------------
; BStore_CopyWorkspaceRangesToAllBanks
; Called from: in-module: 0xF4D1A4
; Touches:   |  0x603400 0x603414 0x603446 0x610000
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4D1B8 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_CopyWorkspaceRangesToAllBanks: Copies workspace bytes +0x00..+0x08, +0x14..+0x1B and +0x46..+0x51 (0x603400 /
;   0x603414 / 0x603446) to the same offsets of all ten bank copies 0x610000 + n * 0xC00. Called once, in the song-
;   store reset behind T_BStore_ClearSongStore (INITIAL TOTAL, BStore_ResetWorkspaceToDefault), which then copies the other reset
;   fields with BStore_CopyChainStateToAllBanks, as BStore_CopyByteD6ToAllBanks does for one byte. Basis: caller + body + siblings.
;   (notes/naming-pilot-2026-10-06/proposals_wave4_k.json)
BStore_CopyWorkspaceRangesToAllBanks:
	push	xwa	; F4D1B8  push XWA
	push	xix	; F4D1B9  push XIX
	push	xiy	; F4D1BA  push XIY
	push	xbc	; F4D1BB  push XBC
	push	xde	; F4D1BC  push XDE
	xor	xwa, xwa	; F4D1BD  xor XWA,XWA
BStore_CopyWorkspaceRangesToAllBanks_Loop:
	ldw	bc, 9	; F4D1BF  ld BC,0x0009
	ld	de, wa	; F4D1C2  ld DE,WA
	mul	de, 3072	; F4D1C4  mul DE,0x0c00
	ld	xix, 6356992	; F4D1C8  ld XIX,0x00610000
	lda	xix, (xix+de)	; F4D1CD  lda XIX,XIX+DE
	lda	xix, (xix+0:8)	; F4D1D2  lda XIX,XIX+0x00
	ld	xiy, 6304768	; F4D1D5  ld XIY,0x00603400
	ldir85	; F4D1DA  ldir
	inc	1, wa	; F4D1DC  inc 1,WA
	cp	wa, 10	; F4D1DE  cp WA,0x000a
	jr	c, BStore_CopyWorkspaceRangesToAllBanks_Loop	; F4D1E2  jr C,0xf4d1bf
	xor	xwa, xwa	; F4D1E4  xor XWA,XWA
BStore_CopyWorkspaceRangesToAllBanks_Loop2:
	ldw	bc, 8	; F4D1E6  ld BC,0x0008
	ld	de, wa	; F4D1E9  ld DE,WA
	mul	de, 3072	; F4D1EB  mul DE,0x0c00
	ld	xix, 6356992	; F4D1EF  ld XIX,0x00610000
	lda	xix, (xix+de)	; F4D1F4  lda XIX,XIX+DE
	lda	xix, (xix+20)	; F4D1F9  lda XIX,XIX+0x14
	ld	xiy, 6304788	; F4D1FC  ld XIY,0x00603414
	ldir85	; F4D201  ldir
	inc	1, wa	; F4D203  inc 1,WA
	cp	wa, 10	; F4D205  cp WA,0x000a
	jr	c, BStore_CopyWorkspaceRangesToAllBanks_Loop2	; F4D209  jr C,0xf4d1e6
	xor	xwa, xwa	; F4D20B  xor XWA,XWA
BStore_CopyWorkspaceRangesToAllBanks_Loop3:
	ldw	bc, 12	; F4D20D  ld BC,0x000c
	ld	de, wa	; F4D210  ld DE,WA
	mul	de, 3072	; F4D212  mul DE,0x0c00
	ld	xix, 6356992	; F4D216  ld XIX,0x00610000
	lda	xix, (xix+de)	; F4D21B  lda XIX,XIX+DE
	lda	xix, (xix+70)	; F4D220  lda XIX,XIX+0x46
	ld	xiy, 6304838	; F4D223  ld XIY,0x00603446
	ldir85	; F4D228  ldir
	inc	1, wa	; F4D22A  inc 1,WA
	cp	wa, 10	; F4D22C  cp WA,0x000a
	jr	c, BStore_CopyWorkspaceRangesToAllBanks_Loop3	; F4D230  jr C,0xf4d20d
	pop	xde	; F4D232  pop XDE
	pop	xbc	; F4D233  pop XBC
	pop	xiy	; F4D234  pop XIY
	pop	xix	; F4D235  pop XIX
	pop	xwa	; F4D236  pop XWA
	ret	; F4D237  ret

; --------------------------------------------------------------------------
; BStore_CopyChainStateToAllBanks
; Called from: in-module: 0xF4D1B4
; Touches: (0x0C70)  |  0x603407 0x60341C 0x60347E 0x6034B8 0x6034D6
;          0x603500 +1 more
; Calls:   BStore_ClearTrack
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4D238 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_CopyChainStateToAllBanks: Copies workspace fields into each of the ten bank copies at 0x610000 + n x 0xC00:
;   +0x07 (1 byte), BStore_Password (+0x1C, 2), the track directory 0x60347E (+0x7E, 51), BStore_FreeHead/FreeCount
;   (+0xB8, 4), the chain table 0x603500 (+0x100, 51) and +0xD6 (1). The last step of the block-store reset that
;   BStore_ResetWorkspaceToDefault runs through T_BStore_ClearSongStore (BStore_ClearSongStore -> 0xF4D16E). Basis: caller chain + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave4_l.json)
BStore_CopyChainStateToAllBanks:
	push	xwa	; F4D238  push XWA
	push	xix	; F4D239  push XIX
	push	xiy	; F4D23A  push XIY
	push	xbc	; F4D23B  push XBC
	push	xde	; F4D23C  push XDE
	xor	xwa, xwa	; F4D23D  xor XWA,XWA
BStore_CopyChainStateToAllBanks_Loop:
	ldw	bc, 1	; F4D23F  ld BC,0x0001
	ld	de, wa	; F4D242  ld DE,WA
	mul	de, 3072	; F4D244  mul DE,0x0c00
	ld	xix, 6356992	; F4D248  ld XIX,0x00610000
	lda	xix, (xix+de)	; F4D24D  lda XIX,XIX+DE
	lda	xix, (xix+7)	; F4D252  lda XIX,XIX+0x07
	ld	xiy, 6304775	; F4D255  ld XIY,0x00603407
	ldir85	; F4D25A  ldir
	inc	1, wa	; F4D25C  inc 1,WA
	cp	wa, 10	; F4D25E  cp WA,0x000a
	jr	c, BStore_CopyChainStateToAllBanks_Loop	; F4D262  jr C,0xf4d23f
	xor	xwa, xwa	; F4D264  xor XWA,XWA
BStore_CopyChainStateToAllBanks_Loop2:
	ldw	bc, 2	; F4D266  ld BC,0x0002
	ld	de, wa	; F4D269  ld DE,WA
	mul	de, 3072	; F4D26B  mul DE,0x0c00
	ld	xix, 6356992	; F4D26F  ld XIX,0x00610000
	lda	xix, (xix+de)	; F4D274  lda XIX,XIX+DE
	lda	xix, (xix+28)	; F4D279  lda XIX,XIX+0x1c
	ld	xiy, BStore_Password	; F4D27C  ld XIY,0x0060341c
	ldir85	; F4D281  ldir
	inc	1, wa	; F4D283  inc 1,WA
	cp	wa, 10	; F4D285  cp WA,0x000a
	jr	c, BStore_CopyChainStateToAllBanks_Loop2	; F4D289  jr C,0xf4d266
	xor	xwa, xwa	; F4D28B  xor XWA,XWA
BStore_CopyChainStateToAllBanks_Loop3:
	ldw	bc, 51	; F4D28D  ld BC,0x0033
	ld	de, wa	; F4D290  ld DE,WA
	mul	de, 3072	; F4D292  mul DE,0x0c00
	ld	xix, 6356992	; F4D296  ld XIX,0x00610000
	lda	xix, (xix+de)	; F4D29B  lda XIX,XIX+DE
	lda	xix, (xix+126)	; F4D2A0  lda XIX,XIX+0x7e
	ld	xiy, 6304894	; F4D2A3  ld XIY,0x0060347e
	ldir85	; F4D2A8  ldir
	inc	1, wa	; F4D2AA  inc 1,WA
	cp	wa, 10	; F4D2AC  cp WA,0x000a
	jr	c, BStore_CopyChainStateToAllBanks_Loop3	; F4D2B0  jr C,0xf4d28d
	xor	xwa, xwa	; F4D2B2  xor XWA,XWA
BStore_CopyChainStateToAllBanks_Loop4:
	ldw	bc, 4	; F4D2B4  ld BC,0x0004
	ld	de, wa	; F4D2B7  ld DE,WA
	mul	de, 3072	; F4D2B9  mul DE,0x0c00
	ld	xix, 6356992	; F4D2BD  ld XIX,0x00610000
	lda	xix, (xix+de)	; F4D2C2  lda XIX,XIX+DE
	lda	xix, (xix+184)	; F4D2C7  lda XIX,XIX+0x00b8
	ld	xiy, BStore_FreeHead	; F4D2CC  ld XIY,0x006034b8
	ldir85	; F4D2D1  ldir
	inc	1, wa	; F4D2D3  inc 1,WA
	cp	wa, 10	; F4D2D5  cp WA,0x000a
	jr	c, BStore_CopyChainStateToAllBanks_Loop4	; F4D2D9  jr C,0xf4d2b4
	xor	xwa, xwa	; F4D2DB  xor XWA,XWA
BStore_CopyChainStateToAllBanks_Loop5:
	ldw	bc, 51	; F4D2DD  ld BC,0x0033
	ld	de, wa	; F4D2E0  ld DE,WA
	mul	de, 3072	; F4D2E2  mul DE,0x0c00
	ld	xix, 6356992	; F4D2E6  ld XIX,0x00610000
	lda	xix, (xix+de)	; F4D2EB  lda XIX,XIX+DE
	lda	xix, (xix+0x0100)	; F4D2F0  lda XIX,XIX+0x0100
	ld	xiy, 6305024	; F4D2F5  ld XIY,0x00603500
	ldir85	; F4D2FA  ldir
	inc	1, wa	; F4D2FC  inc 1,WA
	cp	wa, 10	; F4D2FE  cp WA,0x000a
	jr	c, BStore_CopyChainStateToAllBanks_Loop5	; F4D302  jr C,0xf4d2dd
	xor	xwa, xwa	; F4D304  xor XWA,XWA
BStore_CopyChainStateToAllBanks_Loop6:
	ldw	bc, 1	; F4D306  ld BC,0x0001
	ld	de, wa	; F4D309  ld DE,WA
	mul	de, 3072	; F4D30B  mul DE,0x0c00
	ld	xix, 6356992	; F4D30F  ld XIX,0x00610000
	lda	xix, (xix+de)	; F4D314  lda XIX,XIX+DE
	lda	xix, (xix+214)	; F4D319  lda XIX,XIX+0x00d6
	ld	xiy, 6304982	; F4D31E  ld XIY,0x006034d6
	ldir85	; F4D323  ldir
	inc	1, wa	; F4D325  inc 1,WA
	cp	wa, 10	; F4D327  cp WA,0x000a
	jr	c, BStore_CopyChainStateToAllBanks_Loop6	; F4D32B  jr C,0xf4d306
	pop	xde	; F4D32D  pop XDE
	pop	xbc	; F4D32E  pop XBC
	pop	xiy	; F4D32F  pop XIY
	pop	xix	; F4D330  pop XIX
	pop	xwa	; F4D331  pop XWA
	ret	; F4D332  ret
BStore_CopyChainStateToAllBanks_Join:
	ld	a, (3184:16)	; F4D333  ld A,(0x0c70)
	cp	a, 1:i3	; F4D337  cp A,1
	jr	c, BStore_CopyChainStateToAllBanks_Return	; F4D339  jr C,0xf4d345
	cp	a, 17	; F4D33B  cp A,0x11
	jr	ule, BStore_CopyChainStateToAllBanks_Skip	; F4D33E  jr ULE,0xf4d342
	jr	BStore_CopyChainStateToAllBanks_Return	; F4D340  jr T,0xf4d345
BStore_CopyChainStateToAllBanks_Skip:
	calr	BStore_ClearTrack	; F4D342  calr 0xf4d346
BStore_CopyChainStateToAllBanks_Return:
	ret	; F4D345  ret

; --------------------------------------------------------------------------
; BStore_ClearTrack
; Called from: in-module: 0xF4D342
; Touches: (0x0C55) (0x0C57) (0x0C5D) (0x0C61) (0x0C67) (0x0C6B) (0x0C70)
;          (0x0D1C) (0x0D1D) (0x0D4A) +11 more  |  0x003460 0x003482
;          0x0034EE 0x003510 0x003532 0x60347E +4 more
; Calls:   BStore_FreeChain_B T_BStore_LoadGeometry_Call T_BStore_CopyRangeForward_Call T_BStore_AppendBytes_Veneer T_BStore_OpenChain_Call T_BStore_LoadStartBeatsPerBar T_BStore_TimeSigNextMeasure_Call
;          BStore_CursorAdvanceXHL
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4D346 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ClearTrack: Empties track (0x0C70)-1: its bit cleared in the saved track mask (0x3010)/(0x3012); end cursor
;   0x60347E/0x6034A0[t] and live cursor 0x3460/0x3482[t] := 0xFFFF / 5; an in-use directory entry loses bit 7 and its
;   chain is freed (BStore_FreeChain_B). Reached via T_BStore_ClearTrackIfInRange/T_F40A04 (take start, step-record, track-assign, SMF
;   import); twin of TRACK CLEAR's SongEdit_ClearTrack. Basis: callers + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_p.json)
BStore_ClearTrack:
	xor	wa, wa	; F4D346  xor WA,WA
	ld	a, (3184:16)	; F4D348  ld A,(0x0c70)
	dec	1, a	; F4D34C  dec 1,A
	ld	iy, wa	; F4D34E  ld IY,WA
	pushw	bc	; F4D350  push BC
	ld	c, a	; F4D351  ld C,A
	cp	c, 16	; F4D353  cp C,0x10
	jr	nc, BStore_ClearTrack_Skip	; F4D356  jr NC,0xf4d367
	ld	iz, (12304:16)	; F4D358  ld IZ,(0x3010)
	ld	a, c	; F4D35C  ld A,C
	rcf	; F4D35E  rcf
	stcf_a_16	iz	; F4D35F  stcf A,IZ
	ld	(12304:16), iz	; F4D361  ld (0x3010),IZ
	jr	BStore_ClearTrack_Join	; F4D365  jr T,0xf4d379
BStore_ClearTrack_Skip:
	ld	iz, (12306:16)	; F4D367  ld IZ,(0x3012)
	ld	a, c	; F4D36B  ld A,C
	pushw	wa	; F4D36D  push WA
	sub	a, 16	; F4D36E  sub A,0x10
	rcf	; F4D371  rcf
	stcf_a_16	iz	; F4D372  stcf A,IZ
	popw	wa	; F4D374  pop WA
	ld	(12306:16), iz	; F4D375  ld (0x3012),IZ
BStore_ClearTrack_Join:
	popw	bc	; F4D379  pop BC
	ld	xix, 6304928	; F4D37A  ld XIX,0x006034a0
	ld	(xix+iy), 0x05	; F4D37F  ld (XIX+IY),0x05
	ld	xix, 13442	; F4D385  ld XIX,0x00003482
	ld	(xix+iy), 0x05	; F4D38A  ld (XIX+IY),0x05
	sla	iy, 1	; F4D390  sla 0x01,IY
	ld	xix, 6304894	; F4D393  ld XIX,0x0060347e
	ldw	(xix+iy), 0xffff	; F4D398  ld (XIX+IY),0xffff
	ld	xix, 13408	; F4D39F  ld XIX,0x00003460
	ldw	(xix+iy), 0xffff	; F4D3A4  ld (XIX+IY),0xffff
	muls	wa, 3	; F4D3AB  muls WA,0x0003
	ld	iy, wa	; F4D3AF  ld IY,WA
	ld	xix, 6305024	; F4D3B1  ld XIX,0x00603500
	bit	7, (xix+iy)	; F4D3B6  bit 7,(XIX+IY)
	jr	z, BStore_ClearTrack_Return	; F4D3BB  jr Z,0xf4d3e0
	and	(xix+iy), 0x7f	; F4D3BD  and (XIX+IY),0x7f
	inc	1, iy	; F4D3C3  inc 1,IY
	ld	wa, (xix+iy)	; F4D3C5  ld WA,(XIX+IY)
	cp	wa, 65535	; F4D3CA  cp WA,0xffff
	jr	z, BStore_ClearTrack_Return	; F4D3CE  jr Z,0xf4d3e0
	ldw	(xix+iy), 0xffff	; F4D3D0  ld (XIX+IY),0xffff
	ld	iy, wa	; F4D3D7  ld IY,WA
	ld	wa, (BStore_BlockCount:16)	; F4D3D9  ld WA,(0x3608)
	calr	BStore_FreeChain_B	; F4D3DD  calr 0xf4d89d
BStore_ClearTrack_Return:
	ret	; F4D3E0  ret
BStore_ClearTrack_Join2:
	push	xiy	; F4D3E1  push XIY
	call	T_BStore_LoadGeometry_Call	; F4D3E2  call 0xf427fc
	ld	(BStore_ErrorCode:16), 0	; F4D3E6  ld (0x0d4a),0x00
	xor	wa, wa	; F4D3EB  xor WA,WA
	ld	a, (13642:16)	; F4D3ED  ld A,(0x354a)
	ld	(3175:16), wa	; F4D3F1  ld (0x0c67),WA
	ld	wa, (13640:16)	; F4D3F5  ld WA,(0x3548)
	ld	(3169:16), wa	; F4D3F9  ld (0x0c61),WA
	ld	wa, (13546:16)	; F4D3FD  ld WA,(0x34ea)
	ld	(3159:16), wa	; F4D401  ld (0x0c57),WA
	xor	wa, wa	; F4D405  xor WA,WA
	ld	a, (13548:16)	; F4D407  ld A,(0x34ec)
	ld	(3165:16), wa	; F4D40B  ld (0x0c5d),WA
	xor	wa, wa	; F4D40F  xor WA,WA
	xor	hl, hl	; F4D411  xor HL,HL
	ld	l, (13471:16)	; F4D413  ld L,(0x349f)
	ld	xiy, 6304928	; F4D417  ld XIY,0x006034a0
	ld	a, (xiy+hl)	; F4D41C  ld A,(XIY+HL)
	ld	(3179:16), wa	; F4D421  ld (0x0c6b),WA
	sla	hl, 1	; F4D425  sla 0x01,HL
	ld	xiy, 6304894	; F4D428  ld XIY,0x0060347e
	ld	de, (xiy+hl)	; F4D42D  ld DE,(XIY+HL)
	call	T_BStore_CopyRangeForward_Call	; F4D432  call 0xf427e8
	cp	(BStore_ErrorCode:16), 0x00	; F4D436  cp (0x0d4a),0x00
	jr	z, BStore_ClearTrack_Skip2	; F4D43B  jr Z,0xf4d440
	jrl	sub_F4D346_Epilogue	; F4D43D  jrl T,0xf4d5b5
BStore_ClearTrack_Skip2:
	xor	hl, hl	; F4D440  xor HL,HL
	ld	l, (13471:16)	; F4D442  ld L,(0x349f)
	ld	wa, ix	; F4D446  ld WA,IX
	dec	1, wa	; F4D448  dec 1,WA
	ld	xiy, 6304928	; F4D44A  ld XIY,0x006034a0
	ld	(xiy+hl), a	; F4D44F  ld (XIY+HL),A
	sla	hl, 1	; F4D454  sla 0x01,HL
	xor	xwa, xwa	; F4D457  xor XWA,XWA
	ld	wa, (3159:16)	; F4D459  ld WA,(0x0c57)
	ld	xiy, 6304894	; F4D45D  ld XIY,0x0060347e
	ld	(xiy+hl), wa	; F4D462  ld (XIY+HL),WA
	dec	1, xwa	; F4D467  dec 1,XWA
	sla	xwa, 8	; F4D469  sla 0x08,XWA
	push	xwa	; F4D46C  push XWA
	ld	xiy, (BStore_HeapBase:16)	; F4D46D  ld XIY,(0x3604)
	lda	xwa, (xiy+0:8)	; F4D471  lda XWA,XIY+0x00
	ld	xhl, xwa	; F4D474  ld XHL,XWA
	pop	xwa	; F4D476  pop XWA
	add	xhl, xwa	; F4D477  add XHL,XWA
	cpw	(xhl+3), 0xffff	; F4D479  cp (XHL+0x03),0xffff
	jr	z, BStore_ClearTrack_Skip3	; F4D47E  jr Z,0xf4d48a
	ld	iy, (xhl+3)	; F4D480  ld IY,(XHL+0x03)
	ld	wa, (BStore_BlockCount:16)	; F4D483  ld WA,(0x3608)
	calr	BStore_FreeChain_B	; F4D487  calr 0xf4d89d
BStore_ClearTrack_Skip3:
	xor	hl, hl	; F4D48A  xor HL,HL
	ld	l, (13471:16)	; F4D48C  ld L,(0x349f)
	ld	a, (13548:16)	; F4D490  ld A,(0x34ec)
	ld	xiy, 13442	; F4D494  ld XIY,0x00003482
	ld	(xiy+hl), a	; F4D499  ld (XIY+HL),A
	sla	hl, 1	; F4D49E  sla 0x01,HL
	ld	wa, (13546:16)	; F4D4A1  ld WA,(0x34ea)
	ld	xiy, 13408	; F4D4A5  ld XIY,0x00003460
	ld	(xiy+hl), wa	; F4D4AA  ld (XIY+HL),WA
	xor	xwa, xwa	; F4D4AF  xor XWA,XWA
	ld	xiy, 13550	; F4D4B1  ld XIY,0x000034ee
	ld	wa, (xiy+hl)	; F4D4B6  ld WA,(XIY+HL)
	ld	(BStore_CursorBlock:16), wa	; F4D4BB  ld (0x345c),WA
	dec	1, xwa	; F4D4BF  dec 1,XWA
	sla	xwa, 8	; F4D4C1  sla 0x08,XWA
	push	xwa	; F4D4C4  push XWA
	ld	xiy, (BStore_HeapBase:16)	; F4D4C5  ld XIY,(0x3604)
	lda	xwa, (xiy+0:8)	; F4D4C9  lda XWA,XIY+0x00
	ld	xde, xwa	; F4D4CC  ld XDE,XWA
	pop	xwa	; F4D4CE  pop XWA
	add	xwa, xde	; F4D4CF  add XWA,XDE
	ldw	(xwa+1), 0x0000	; F4D4D1  ld (XWA+0x01),0x0000
	ld	xiz, 13584	; F4D4D6  ld XIZ,0x00003510
	ld	de, (xiz+hl)	; F4D4DB  ld DE,(XIZ+HL)
	ld	xiz, 13550	; F4D4E0  ld XIZ,0x000034ee
	cp	(xiz+hl), de	; F4D4E5  cp (XIZ+HL),DE
	jr	z, sub_F4D346_Entry	; F4D4EA  jr Z,0xf4d55f
	ld	xix, 6332416	; F4D4EC  ld XIX,0x0060a000
	ldw	bc, 256	; F4D4F1  ld BC,0x0100
	ld	xiy, xwa	; F4D4F4  ld XIY,XWA
	ldirw	; F4D4F6  ldirw
	ld	iy, (BStore_CursorBlock:16)	; F4D4F8  ld IY,(0x345c)
	ldw	wa, 1	; F4D4FC  ld WA,0x0001
	pushw	de	; F4D4FF  push DE
	calr	BStore_FreeChain_B	; F4D500  calr 0xf4d89d
	popw	de	; F4D503  pop DE
BStore_ClearTrack_Join3:
	ldw	wa, 256	; F4D504  ld WA,0x0100
	sub	wa, 5	; F4D507  sub WA,0x0005
	ld	w, a	; F4D50B  ld W,A
	ld	a, (13471:16)	; F4D50D  ld A,(0x349f)
	inc	1, a	; F4D511  inc 1,A
	ld	xiy, 6332421	; F4D513  ld XIY,0x0060a005
	pushw	de	; F4D518  push DE
	call	T_BStore_AppendBytes_Veneer	; F4D519  call 0xf42894
	popw	de	; F4D51D  pop DE
	ld	xhl, 6332416	; F4D51E  ld XHL,0x0060a000
	cp	de, (xhl+3)	; F4D523  cp DE,(XHL+0x03)
	jr	nz, BStore_ClearTrack_Skip4	; F4D526  jr NZ,0xf4d52a
	jr	sub_F4D346_Entry	; F4D528  jr T,0xf4d55f
BStore_ClearTrack_Skip4:
	xor	xwa, xwa	; F4D52A  xor XWA,XWA
	ld	wa, (xhl+3)	; F4D52C  ld WA,(XHL+0x03)
	ld	(BStore_CursorBlock:16), wa	; F4D52F  ld (0x345c),WA
	dec	1, xwa	; F4D533  dec 1,XWA
	sla	xwa, 8	; F4D535  sla 0x08,XWA
	push	xwa	; F4D538  push XWA
	ld	xiy, (BStore_HeapBase:16)	; F4D539  ld XIY,(0x3604)
	lda	xwa, (xiy+0:8)	; F4D53D  lda XWA,XIY+0x00
	ld	xbc, xwa	; F4D540  ld XBC,XWA
	pop	xwa	; F4D542  pop XWA
	add	xbc, xwa	; F4D543  add XBC,XWA
	ld	xiy, xbc	; F4D545  ld XIY,XBC
	ld	xix, 6332416	; F4D547  ld XIX,0x0060a000
	ldw	bc, 256	; F4D54C  ld BC,0x0100
	ldirw	; F4D54F  ldirw
	ld	iy, (BStore_CursorBlock:16)	; F4D551  ld IY,(0x345c)
	ldw	wa, 1	; F4D555  ld WA,0x0001
	pushw	de	; F4D558  push DE
	calr	BStore_FreeChain_B	; F4D559  calr 0xf4d89d
	popw	de	; F4D55C  pop DE
	jr	BStore_ClearTrack_Join3	; F4D55D  jr T,0xf4d504
sub_F4D346_Entry:
	.byte 0xD7, 0x0A, 0xA8	; F4D55F  ld QDE0,0   [llvm-mc cannot encode this]
	ld	(BStore_CursorBlock:16), de	; F4D562  ld (0x345c),DE
	dec	1, xde	; F4D566  dec 1,XDE
	sla	xde, 8	; F4D568  sla 0x08,XDE
	ld	xiy, (BStore_HeapBase:16)	; F4D56B  ld XIY,(0x3604)
	lda	xwa, (xiy+0:8)	; F4D56F  lda XWA,XIY+0x00
	add	xde, xwa	; F4D572  add XDE,XWA
	ld	xiy, xde	; F4D574  ld XIY,XDE
	ld	xix, 6332416	; F4D576  ld XIX,0x0060a000
	ldw	bc, 256	; F4D57B  ld BC,0x0100
	ldirw	; F4D57E  ldirw
	ld	iy, (BStore_CursorBlock:16)	; F4D580  ld IY,(0x345c)
	ldw	wa, 1	; F4D584  ld WA,0x0001
	calr	BStore_FreeChain_B	; F4D587  calr 0xf4d89d
	xor	hl, hl	; F4D58A  xor HL,HL
	ld	l, (13471:16)	; F4D58C  ld L,(0x349f)
	xor	wa, wa	; F4D590  xor WA,WA
	ld	xiy, 13618	; F4D592  ld XIY,0x00003532
	ld	a, (xiy+hl)	; F4D597  ld A,(XIY+HL)
	sub	wa, 5	; F4D59C  sub WA,0x0005
	cp	wa, 0:i3	; F4D5A0  cp WA,0
	jr	z, sub_F4D346_Epilogue	; F4D5A2  jr Z,0xf4d5b5
	ld	w, a	; F4D5A4  ld W,A
	ld	a, (13471:16)	; F4D5A6  ld A,(0x349f)
	inc	1, a	; F4D5AA  inc 1,A
	ld	xiy, 6332421	; F4D5AC  ld XIY,0x0060a005
	call	T_BStore_AppendBytes_Veneer	; F4D5B1  call 0xf42894
sub_F4D346_Epilogue:
	pop	xiy	; F4D5B5  pop XIY
	ret	; F4D5B6  ret
sub_F4D346_Join4:
	push	xwa	; F4D5B7  push XWA
	push	xbc	; F4D5B8  push XBC
	push	xde	; F4D5B9  push XDE
	push	xhl	; F4D5BA  push XHL
	push	xix	; F4D5BB  push XIX
	push	xiy	; F4D5BC  push XIY
	push	xiz	; F4D5BD  push XIZ
	call	T_BStore_LoadGeometry_Call	; F4D5BE  call 0xf427fc
	pop	xiz	; F4D5C2  pop XIZ
	pop	xiy	; F4D5C3  pop XIY
	pop	xix	; F4D5C4  pop XIX
	pop	xhl	; F4D5C5  pop XHL
	pop	xde	; F4D5C6  pop XDE
	pop	xbc	; F4D5C7  pop XBC
	pop	xwa	; F4D5C8  pop XWA
	ld	(BStore_ErrorCode:16), 0	; F4D5C9  ld (0x0d4a),0x00
	ld	(3357:16), w	; F4D5CE  ld (0x0d1d),W
	call	T_BStore_OpenChain_Call	; F4D5D2  call 0xf427f8
	ld	xhl, (BStore_CursorBlockAddr:16)	; F4D5D6  ld XHL,(0x126e)
	cp	(BStore_ErrorCode:16), 0x00	; F4D5DA  cp (0x0d4a),0x00
	jr	nz, sub_F4D346_Return2	; F4D5DF  jr NZ,0xf4d650
	ldw	iy, 5	; F4D5E1  ld IY,0x0005
	ld	wa, (BStore_CursorBlock:16)	; F4D5E4  ld WA,(0x345c)
	push	xhl	; F4D5E8  push XHL
	pushw	iy	; F4D5E9  push IY
	call	T_BStore_LoadStartBeatsPerBar	; F4D5EA  call 0xf427f0
	popw	iy	; F4D5EE  pop IY
	pop	xhl	; F4D5EF  pop XHL
	xor	de, de	; F4D5F0  xor DE,DE
	inc	1, de	; F4D5F2  inc 1,DE
	xor	ix, ix	; F4D5F4  xor IX,IX
	xor	bc, bc	; F4D5F6  xor BC,BC
sub_F4D346_Loop:
	cp	c, (0x0d1c:16)	; F4D5F8  cp C,(0x0d1c)
	jr	nz, sub_F4D346_Skip5	; F4D5FC  jr NZ,0xf4d60e
	inc	1, de	; F4D5FE  inc 1,DE
	push	xhl	; F4D600  push XHL
	pushw	de	; F4D601  push DE
	pushw	iy	; F4D602  push IY
	pushw	ix	; F4D603  push IX
	call	T_BStore_TimeSigNextMeasure_Call	; F4D604  call 0xf427f4
	popw	ix	; F4D608  pop IX
	popw	iy	; F4D609  pop IY
	popw	de	; F4D60A  pop DE
	pop	xhl	; F4D60B  pop XHL
	xor	bc, bc	; F4D60C  xor BC,BC
sub_F4D346_Skip5:
	cp	ix, (0x0c55:16)	; F4D60E  cp IX,(0x0c55)
	jr	nz, sub_F4D346_Loop2	; F4D612  jr NZ,0xf4d61a
	ld	a, (3356:16)	; F4D614  ld A,(0x0d1c)
	jr	sub_F4D346_Return2	; F4D618  jr T,0xf4d650
sub_F4D346_Loop2:
	ld	a, (xhl+iy)	; F4D61A  ld A,(XHL+IY)
	cp	a, 130	; F4D61F  cp A,0x82
	jr	z, sub_F4D346_Skip6	; F4D622  jr Z,0xf4d626
	jr	nz, sub_F4D346_Skip7	; F4D624  jr NZ,0xf4d62d
sub_F4D346_Skip6:
	ld	(BStore_ErrorCode:16), 8	; F4D626  ld (0x0d4a),0x08
	jr	sub_F4D346_Return2	; F4D62B  jr T,0xf4d650
sub_F4D346_Skip7:
	cp	a, 129	; F4D62D  cp A,0x81
	jr	z, sub_F4D346_Skip8	; F4D630  jr Z,0xf4d63e
	calr	BStore_CursorAdvanceXHL	; F4D632  calr 0xf4d758
	cp	(BStore_ErrorCode:16), 0x00	; F4D635  cp (0x0d4a),0x00
	jr	z, sub_F4D346_Loop2	; F4D63A  jr Z,0xf4d61a
	jr	sub_F4D346_Return2	; F4D63C  jr T,0xf4d650
sub_F4D346_Skip8:
	inc	1, c	; F4D63E  inc 1,C
	inc	1, ix	; F4D640  inc 1,IX
	ld	wa, (BStore_CursorBlock:16)	; F4D642  ld WA,(0x345c)
	calr	BStore_CursorAdvanceXHL	; F4D646  calr 0xf4d758
	cp	(BStore_ErrorCode:16), 0x00	; F4D649  cp (0x0d4a),0x00
	jr	z, sub_F4D346_Loop	; F4D64E  jr Z,0xf4d5f8
sub_F4D346_Return2:
	ret	; F4D650  ret

; --------------------------------------------------------------------------
; BStore_SkipBeatMarks
; Called from: T_BStore_SkipBeatMarks (x0); in-module: 0xF4D6DB
; Touches: (0x0D4A)
; Calls:   BStore_CursorAdvanceXHL
; Evidence: thunk slot T_BStore_SkipBeatMarks holds `jp 0x00F4D651`, and 0xF4D651 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_SkipBeatMarks: Advances the block-store cursor (byte (XHL+IY), crossing blocks with BStore_CursorAdvanceXHL) past B 0x81
;   beat marks and adds their count to IX; an 0x82 end tag stops it with BStore_ErrorCode 8. BStore_SeekChainToMeasure
;   calls it once per measure with B = (0x0D1C), the beats per measure. Basis: caller + caller header + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
BStore_SkipBeatMarks:		; <- T_BStore_SkipBeatMarks
	xor	c, c	; F4D651  xor C,C
BStore_SkipBeatMarks_Loop:
	cp	c, b	; F4D653  cp C,B
	jr	z, BStore_SkipBeatMarks_Join2	; F4D655  jr Z,0xf4d68b
BStore_SkipBeatMarks_Loop2:
	ld	a, (xhl+iy)	; F4D657  ld A,(XHL+IY)
	cp	a, 130	; F4D65C  cp A,0x82
	jr	z, BStore_SkipBeatMarks_Skip	; F4D65F  jr Z,0xf4d663
	jr	BStore_SkipBeatMarks_Join	; F4D661  jr T,0xf4d66a
BStore_SkipBeatMarks_Skip:
	ld	(BStore_ErrorCode:16), 8	; F4D663  ld (0x0d4a),0x08
	jr	BStore_SkipBeatMarks_Join2	; F4D668  jr T,0xf4d68b
BStore_SkipBeatMarks_Join:
	cp	a, 129	; F4D66A  cp A,0x81
	jr	z, BStore_SkipBeatMarks_Skip2	; F4D66D  jr Z,0xf4d67d
	pushw	bc	; F4D66F  push BC
	calr	BStore_CursorAdvanceXHL	; F4D670  calr 0xf4d758
	popw	bc	; F4D673  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F4D674  cp (0x0d4a),0x00
	jr	z, BStore_SkipBeatMarks_Loop2	; F4D679  jr Z,0xf4d657
	jr	BStore_SkipBeatMarks_Join2	; F4D67B  jr T,0xf4d68b
BStore_SkipBeatMarks_Skip2:
	inc	1, c	; F4D67D  inc 1,C
	pushw	bc	; F4D67F  push BC
	calr	BStore_CursorAdvanceXHL	; F4D680  calr 0xf4d758
	popw	bc	; F4D683  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F4D684  cp (0x0d4a),0x00
	jr	z, BStore_SkipBeatMarks_Loop	; F4D689  jr Z,0xf4d653
BStore_SkipBeatMarks_Join2:
	xor	b, b	; F4D68B  xor B,B
	add	ix, bc	; F4D68D  add IX,BC
	ret	; F4D68F  ret

; --------------------------------------------------------------------------
; BStore_SeekChainToMeasure
; Called from: T_BStore_SeekChainToMeasure (x7)
; Touches: (0x0C90) (0x0D1C) (0x0D1D) (0x0D4A) (0x126E)
; Calls:   T_BStore_LoadGeometry_Call T_BStore_OpenChain_Call T_BStore_LoadStartBeatsPerBar BStore_SkipBeatMarks T_BStore_TimeSigNextMeasure_Call
; Evidence: thunk slot T_BStore_SeekChainToMeasure holds `jp 0x00F4D690`, and 0xF4D690 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_SeekChainToMeasure: Opens chain A (track + 1) and walks it from measure 1 to measure (0x0C90), skipping
;   (0x0D1C) 0x81 beat marks per measure (BStore_SkipBeatMarks; 0x82 = end -> BStore_ErrorCode 8); returns A = (0x0D1C), IX =
;   beats before the measure, cursor at its start. prom_a's edit screens call it as 'prom_b's seek to that measure'.
;   Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave2_f.json)
BStore_SeekChainToMeasure:		; <- T_BStore_SeekChainToMeasure
	ld	(BStore_ErrorCode:16), 0	; F4D690  ld (0x0d4a),0x00
	ld	(3357:16), w	; F4D695  ld (0x0d1d),W
	push	xwa	; F4D699  push XWA
	push	xbc	; F4D69A  push XBC
	push	xde	; F4D69B  push XDE
	push	xhl	; F4D69C  push XHL
	push	xix	; F4D69D  push XIX
	push	xiy	; F4D69E  push XIY
	push	xiz	; F4D69F  push XIZ
	call	T_BStore_LoadGeometry_Call	; F4D6A0  call 0xf427fc
	pop	xiz	; F4D6A4  pop XIZ
	pop	xiy	; F4D6A5  pop XIY
	pop	xix	; F4D6A6  pop XIX
	pop	xhl	; F4D6A7  pop XHL
	pop	xde	; F4D6A8  pop XDE
	pop	xbc	; F4D6A9  pop XBC
	pop	xwa	; F4D6AA  pop XWA
	call	T_BStore_OpenChain_Call	; F4D6AB  call 0xf427f8
	ld	xhl, (BStore_CursorBlockAddr:16)	; F4D6AF  ld XHL,(0x126e)
	cp	(BStore_ErrorCode:16), 0x00	; F4D6B3  cp (0x0d4a),0x00
	jr	nz, BStore_SeekChainToMeasure_Return	; F4D6B8  jr NZ,0xf4d6f5
	ldw	iy, 5	; F4D6BA  ld IY,0x0005
	push	xhl	; F4D6BD  push XHL
	pushw	iy	; F4D6BE  push IY
	call	T_BStore_LoadStartBeatsPerBar	; F4D6BF  call 0xf427f0
	popw	iy	; F4D6C3  pop IY
	pop	xhl	; F4D6C4  pop XHL
	xor	de, de	; F4D6C5  xor DE,DE
	inc	1, de	; F4D6C7  inc 1,DE
	xor	ix, ix	; F4D6C9  xor IX,IX
BStore_SeekChainToMeasure_Join3:
	cp	de, (0x0c90:16)	; F4D6CB  cp DE,(0x0c90)
	jr	nz, BStore_SeekChainToMeasure_Skip3	; F4D6CF  jr NZ,0xf4d6d7
	ld	a, (3356:16)	; F4D6D1  ld A,(0x0d1c)
	jr	BStore_SeekChainToMeasure_Return	; F4D6D5  jr T,0xf4d6f5
BStore_SeekChainToMeasure_Skip3:
	ld	b, (3356:16)	; F4D6D7  ld B,(0x0d1c)
	calr	BStore_SkipBeatMarks	; F4D6DB  calr 0xf4d651
	cp	(BStore_ErrorCode:16), 0x00	; F4D6DE  cp (0x0d4a),0x00
	jr	nz, BStore_SeekChainToMeasure_Return	; F4D6E3  jr NZ,0xf4d6f5
	inc	1, de	; F4D6E5  inc 1,DE
	push	xhl	; F4D6E7  push XHL
	pushw	de	; F4D6E8  push DE
	pushw	iy	; F4D6E9  push IY
	pushw	ix	; F4D6EA  push IX
	call	T_BStore_TimeSigNextMeasure_Call	; F4D6EB  call 0xf427f4
	popw	ix	; F4D6EF  pop IX
	popw	iy	; F4D6F0  pop IY
	popw	de	; F4D6F1  pop DE
	pop	xhl	; F4D6F2  pop XHL
	jr	BStore_SeekChainToMeasure_Join3	; F4D6F3  jr T,0xf4d6cb
BStore_SeekChainToMeasure_Return:
	ret	; F4D6F5  ret

; --------------------------------------------------------------------------
; Seq_BeatsToMeasureAndBeat
; Called from: T_Seq_BeatsToMeasureAndBeat (x2)
; Touches: (0x0C55) (0x0C8A) (0x0D1C) (0x0D1D) (0x0D4A)
; Calls:   T_BStore_LoadGeometry_Call T_BStore_LoadStartBeatsPerBar T_BStore_TimeSigNextMeasure_Call
; Evidence: thunk slot T_Seq_BeatsToMeasureAndBeat holds `jp 0x00F4D6F6`, and 0xF4D6F6 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_BeatsToMeasureAndBeat: Converts the beat count (0x0C55) into DE = measure (1-based), C = beat in that measure, A
;   = beats per bar: without a master track ((0x0C8A) bit 2 clear) by dividing by the song's beats per bar (0x6034D7);
;   with one, by walking its time signatures (BStore_LoadStartBeatsPerBar, then BStore_TimeSigNextMeasure_Call per
;   measure). Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave4_n.json)
Seq_BeatsToMeasureAndBeat:		; <- T_Seq_BeatsToMeasureAndBeat
	pushw	wa	; F4D6F6  push WA
	call	T_BStore_LoadGeometry_Call	; F4D6F7  call 0xf427fc
	popw	wa	; F4D6FB  pop WA
	ld	(BStore_ErrorCode:16), 0	; F4D6FC  ld (0x0d4a),0x00
	bit	2, (0x0c8a:16)	; F4D701  bit 2,(0x0c8a)
	jr	nz, Seq_BeatsToMeasureAndBeat_Skip4	; F4D705  jr NZ,0xf4d729
	xor	de, de	; F4D707  xor DE,DE
	ld	wa, (3157:16)	; F4D709  ld WA,(0x0c55)
	xor	bc, bc	; F4D70D  xor BC,BC
	ld	c, (6304983:24)	; F4D70F  ld C,(0x6034d7)
	ld	qwa, de	; F4D714  ld QWA,DE
	div	xwa, bc	; F4D717  div XWA,BC
	ld	de, qwa	; F4D719  ld DE,QWA
	ld	c, e	; F4D71C  ld C,E
	ld	de, wa	; F4D71E  ld DE,WA
	inc	1, de	; F4D720  inc 1,DE
	ld	a, (6304983:24)	; F4D722  ld A,(0x6034d7)
	jr	Seq_BeatsToMeasureAndBeat_Return2	; F4D727  jr T,0xf4d757
Seq_BeatsToMeasureAndBeat_Skip4:
	ld	(3357:16), w	; F4D729  ld (0x0d1d),W
	call	T_BStore_LoadStartBeatsPerBar	; F4D72D  call 0xf427f0
	xor	wa, wa	; F4D731  xor WA,WA
	ld	a, (3356:16)	; F4D733  ld A,(0x0d1c)
	ld	bc, (3157:16)	; F4D737  ld BC,(0x0c55)
	xor	de, de	; F4D73B  xor DE,DE
	inc	1, de	; F4D73D  inc 1,DE
Seq_BeatsToMeasureAndBeat_Join4:
	cp	bc, wa	; F4D73F  cp BC,WA
	jr	c, Seq_BeatsToMeasureAndBeat_Return2	; F4D741  jr C,0xf4d757
	sub	bc, wa	; F4D743  sub BC,WA
	inc	1, de	; F4D745  inc 1,DE
	pushw	bc	; F4D747  push BC
	pushw	de	; F4D748  push DE
	call	T_BStore_TimeSigNextMeasure_Call	; F4D749  call 0xf427f4
	popw	de	; F4D74D  pop DE
	popw	bc	; F4D74E  pop BC
	xor	wa, wa	; F4D74F  xor WA,WA
	ld	a, (3356:16)	; F4D751  ld A,(0x0d1c)
	jr	Seq_BeatsToMeasureAndBeat_Join4	; F4D755  jr T,0xf4d73f
Seq_BeatsToMeasureAndBeat_Return2:
	ret	; F4D757  ret

; --------------------------------------------------------------------------
; BStore_CursorAdvanceXHL
; Called from: in-module: 0xF4D632 0xF4D646 0xF4D670 0xF4D680
; Touches: (0x0CA4) (0x0D4A) (0x345C) (0x3604)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4D758 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_CursorAdvanceXHL: BStore_CursorAdvance's twin with the block address in XHL: IY += 1; past 0xFF it follows
;   the block's NEXT link (+3) -- error 8 at 0xFFFF, 10 above BStore_BlockLimit -- sets BStore_CursorBlock and XHL =
;   BStore_HeapBase + (n - 1) * 0x100 itself, error 11 if that block is not allocated, else IY = 5. Used by the chain
;   walks at sub_F4D346_Join4 (behind T_BStore_SeekChainToBeat, Seq_LocateToSongPosition's per-track seek) and BStore_SkipBeatMarks to step over
;   events between 0x81 beat marks. Basis: callers + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_k.json)
BStore_CursorAdvanceXHL:
	push	xix	; F4D758  push XIX
	inc	1, iy	; F4D759  inc 1,IY
	cp	iy, 255	; F4D75B  cp IY,0x00ff
	jr	le, BStore_CursorAdvanceXHL_Epilogue	; F4D75F  jr LE,0xf4d7a5
	ld	wa, (xhl+3)	; F4D761  ld WA,(XHL+0x03)
	cp	wa, 65535	; F4D764  cp WA,0xffff
	jr	ule, BStore_CursorAdvanceXHL_Skip	; F4D768  jr ULE,0xf4d771
	ld	(BStore_ErrorCode:16), 8	; F4D76A  ld (0x0d4a),0x08
	jr	BStore_CursorAdvanceXHL_Epilogue	; F4D76F  jr T,0xf4d7a5
BStore_CursorAdvanceXHL_Skip:
	cp	wa, (BStore_BlockLimit:16)	; F4D771  cp WA,(0x0ca4)
	jr	ule, BStore_CursorAdvanceXHL_Skip2	; F4D775  jr ULE,0xf4d77e
	ld	(BStore_ErrorCode:16), 10	; F4D777  ld (0x0d4a),0x0a
	jr	BStore_CursorAdvanceXHL_Epilogue	; F4D77C  jr T,0xf4d7a5
BStore_CursorAdvanceXHL_Skip2:
	ld	qwa, 0	; F4D77E  ld QWA,0
	ld	(BStore_CursorBlock:16), wa	; F4D781  ld (0x345c),WA
	ld	xhl, xwa	; F4D785  ld XHL,XWA
	dec	1, xhl	; F4D787  dec 1,XHL
	sla	xhl, 8	; F4D789  sla 0x08,XHL
	push	xwa	; F4D78C  push XWA
	ld	xix, (BStore_HeapBase:16)	; F4D78D  ld XIX,(0x3604)
	lda	xwa, (xix+0:8)	; F4D791  lda XWA,XIX+0x00
	add	xhl, xwa	; F4D794  add XHL,XWA
	pop	xwa	; F4D796  pop XWA
	bit	7, (xhl)	; F4D797  bit 7,(XHL)
	jr	nz, BStore_CursorAdvanceXHL_Skip3	; F4D799  jr NZ,0xf4d7a2
	ld	(BStore_ErrorCode:16), 11	; F4D79B  ld (0x0d4a),0x0b
	jr	BStore_CursorAdvanceXHL_Epilogue	; F4D7A0  jr T,0xf4d7a5
BStore_CursorAdvanceXHL_Skip3:
	ldw	iy, 5	; F4D7A2  ld IY,0x0005
BStore_CursorAdvanceXHL_Epilogue:
	pop	xix	; F4D7A5  pop XIX
	ret	; F4D7A6  ret
BStore_CursorAdvanceXHL_Join:
	push	xix	; F4D7A7  push XIX
	ld	qhl, 0	; F4D7A8  ld QHL,0
	dec	1, xhl	; F4D7AB  dec 1,XHL
	sla	xhl, 8	; F4D7AD  sla 0x08,XHL
	push	xwa	; F4D7B0  push XWA
	ld	xix, (BStore_HeapBase:16)	; F4D7B1  ld XIX,(0x3604)
	lda	xwa, (xix+0:8)	; F4D7B5  lda XWA,XIX+0x00
	add	xhl, xwa	; F4D7B8  add XHL,XWA
	pop	xwa	; F4D7BA  pop XWA
	pop	xix	; F4D7BB  pop XIX
	ret	; F4D7BC  ret

; --------------------------------------------------------------------------
; BStore_FormatHeap
; Called from: in-module: 0xF4D19D
; Touches: (0x3608)  |  0x000003 0x000100 0x003460 0x003482 0x60347E
;          0x6034A0 +1 more
; Calls:   BStore_BlockAddrFromIY
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4D7BD is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_FormatHeap: Links every block 1..BStore_BlockCount into one free chain (header bit 7 clear, prev/next links,
;   first byte 0x82), BStore_FreeHead := 1, BStore_FreeCount := BlockCount; the 17 chain-table entries at 0x603500 :=
;   {0, 0xFFFF}; the track cursors 0x3460/0x3482 and the directory 0x60347E/0x6034A0 := {0xFFFF, 5}. First step of the
;   block-store reset BStore_ResetWorkspaceToDefault reaches via T_BStore_ClearSongStore. Basis: caller chain + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_l.json)
BStore_FormatHeap:
	ldw	iy, 1	; F4D7BD  ld IY,0x0001
	calr	BStore_BlockAddrFromIY	; F4D7C0  calr 0xf4d935
	ldw	(BStore_FreeHead:24), 1	; F4D7C3  ld (0x6034b8),0x0001
	ld	xiy, xhl	; F4D7CA  ld XIY,XHL
	xor	hl, hl	; F4D7CC  xor HL,HL
	ldw	de, 2	; F4D7CE  ld DE,0x0002
	ld	bc, (BStore_BlockCount:16)	; F4D7D1  ld BC,(0x3608)
	ld	(BStore_FreeCount:24), bc	; F4D7D5  ld (0x6034ba),BC
	dec	1, bc	; F4D7DA  dec 1,BC
	and	(xiy), 0x7f	; F4D7DC  and (XIY),0x7f
	ld	(xiy+1), hl	; F4D7DF  ld (XIY+0x01),HL
	ld	(xiy+3), de	; F4D7E2  ld (XIY+0x03),DE
	ld	(xiy+5), 130	; F4D7E5  ld (XIY+0x05),0x82
	inc	1, hl	; F4D7E9  inc 1,HL
	inc	1, de	; F4D7EB  inc 1,DE
	add	xiy, 256	; F4D7ED  add XIY,0x00000100
	djnz16	bc, -26	; F4D7F3  djnz BC,0xf4d7dc
	and	(xiy), 0x7f	; F4D7F6  and (XIY),0x7f
	ld	(xiy+1), hl	; F4D7F9  ld (XIY+0x01),HL
	ldw	(xiy+3), 0xffff	; F4D7FC  ld (XIY+0x03),0xffff
	ld	(xiy+5), 130	; F4D801  ld (XIY+0x05),0x82
	ld	xhl, 6305024	; F4D805  ld XHL,0x00603500
	ldw	bc, 17	; F4D80A  ld BC,0x0011
	ld	(xhl), 0	; F4D80D  ld (XHL),0x00
	ldw	(xhl+1), 0xffff	; F4D810  ld (XHL+0x01),0xffff
	add	xhl, 3	; F4D815  add XHL,0x00000003
	djnz16	bc, -17	; F4D81B  djnz BC,0xf4d80d
	ld	xhl, 13408	; F4D81E  ld XHL,0x00003460
	ldw	bc, 17	; F4D823  ld BC,0x0011
	ldw	(xhl), 0xffff	; F4D826  ld (XHL),0xffff
	inc	2, xhl	; F4D82A  inc 2,XHL
	djnz16	bc, -9	; F4D82C  djnz BC,0xf4d826
	ld	xhl, 13442	; F4D82F  ld XHL,0x00003482
	ldw	bc, 17	; F4D834  ld BC,0x0011
	ld	(xhl), 5	; F4D837  ld (XHL),0x05
	inc	1, xhl	; F4D83A  inc 1,XHL
	djnz16	bc, -8	; F4D83C  djnz BC,0xf4d837
	ld	xhl, 6304894	; F4D83F  ld XHL,0x0060347e
	ldw	bc, 17	; F4D844  ld BC,0x0011
	ldw	(xhl), 0xffff	; F4D847  ld (XHL),0xffff
	inc	2, xhl	; F4D84B  inc 2,XHL
	djnz16	bc, -9	; F4D84D  djnz BC,0xf4d847
	ld	xhl, 6304928	; F4D850  ld XHL,0x006034a0
	ldw	bc, 17	; F4D855  ld BC,0x0011
	ld	(xhl), 5	; F4D858  ld (XHL),0x05
	inc	1, xhl	; F4D85B  inc 1,XHL
	djnz16	bc, -8	; F4D85D  djnz BC,0xf4d858
	ret	; F4D860  ret

; --------------------------------------------------------------------------
; BStore_AllocBlock_B
; Called from: in-module: 0xF4D07F
; Touches: nothing with an absolute address
; Calls:   BStore_BlockAddrFromIY
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4D861 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_AllocBlock_B: BStore_AllocBlock_B: the second block allocator -- pops the head of the free list
;   (BStore_FreeHead), links it, marks it used (bit 7) and decrements BStore_FreeCount, like BStore_AllocBlock but
;   without that routine's cursor save and through BStore_BlockAddrFromIY instead of BStore_SeekBlock_Alloc; W = 0 on success,
;   0xFF when the list is empty. Reached through BStore_AllocBlock_B_Veneer. Basis: body compared with
;   BStore_AllocBlock + the veneer batch m named. (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
BStore_AllocBlock_B:
	ld	iy, (BStore_FreeHead:24)	; F4D861  ld IY,(0x6034b8)
	cp	iy, 65535	; F4D866  cp IY,0xffff
	jr	z, BStore_AllocBlock_B_Skip2	; F4D86A  jr Z,0xf4d899
	calr	BStore_BlockAddrFromIY	; F4D86C  calr 0xf4d935
	ld	wa, (xhl+3)	; F4D86F  ld WA,(XHL+0x03)
	ld	(BStore_FreeHead:24), wa	; F4D872  ld (0x6034b8),WA
	ld	ix, iy	; F4D877  ld IX,IY
	cp	wa, 65535	; F4D879  cp WA,0xffff
	jr	z, BStore_AllocBlock_B_Skip	; F4D87D  jr Z,0xf4d889
	ld	iy, wa	; F4D87F  ld IY,WA
	calr	BStore_BlockAddrFromIY	; F4D881  calr 0xf4d935
	ldw	(xhl+1), 0x0000	; F4D884  ld (XHL+0x01),0x0000
BStore_AllocBlock_B_Skip:
	ld	iy, ix	; F4D889  ld IY,IX
	calr	BStore_BlockAddrFromIY	; F4D88B  calr 0xf4d935
	or	(xhl), 0x80	; F4D88E  or (XHL),0x80
	decw	1, (BStore_FreeCount:24)	; F4D891  decw 1,(0x6034ba)
	ld	w, 0:opc	; F4D896  ld W,0x00
BStore_AllocBlock_B_Return:
	ret	; F4D898  ret
BStore_AllocBlock_B_Skip2:
	ld	w, 255:opc	; F4D899  ld W,0xff
	jr	BStore_AllocBlock_B_Return	; F4D89B  jr T,0xf4d898

; --------------------------------------------------------------------------
; BStore_FreeChain_B
; Called from: in-module: 0xF4D3DD 0xF4D487 0xF4D500 0xF4D559 0xF4D587
; Touches: (0x0C88)
; Calls:   BStore_BlockAddrFromIY
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4D89D is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_FreeChain_B: prom_b's copy of BStore_FreeChain: (0x0C88) := WA (block limit), BStore_FreeHead := IY, walks
;   the chain from block IY clearing each bit 7 and writing the 0x82 tag at +5, detaches it from its predecessor,
;   links the old head after the last block and adds the count to BStore_FreeCount. Reached by BStore_ClearTrack (5 sites)
;   and via BStore_FreeChain_B_Veneer (slot T_BStore_FreeChain_B_Veneer) from SeqRecord_FreeTakeChain2 / CycleRecord_FreeRecordChain with WA = 0xFFFF. Basis: twin + body
;   + callers. (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
BStore_FreeChain_B:
	ld	(3208:16), wa	; F4D89D  ld (0x0c88),WA
	ld	bc, (BStore_FreeHead:24)	; F4D8A1  ld BC,(0x6034b8)
	ld	(BStore_FreeHead:24), iy	; F4D8A6  ld (0x6034b8),IY
	xor	wa, wa	; F4D8AB  xor WA,WA
	calr	BStore_BlockAddrFromIY	; F4D8AD  calr 0xf4d935
	ld	ix, (xhl+1)	; F4D8B0  ld IX,(XHL+0x01)
	ld	de, ix	; F4D8B3  ld DE,IX
	cp	ix, 0:i3	; F4D8B5  cp IX,0
	jr	z, BStore_FreeChain_B_Skip3	; F4D8B7  jr Z,0xf4d91a
	ld	iy, ix	; F4D8B9  ld IY,IX
	ldw	(xhl+1), 0x0000	; F4D8BB  ld (XHL+0x01),0x0000
	calr	BStore_BlockAddrFromIY	; F4D8C0  calr 0xf4d935
	ld	ix, iy	; F4D8C3  ld IX,IY
	ld	iy, (xhl+3)	; F4D8C5  ld IY,(XHL+0x03)
BStore_FreeChain_B_Loop:
	calr	BStore_BlockAddrFromIY	; F4D8C8  calr 0xf4d935
	ld	ix, iy	; F4D8CB  ld IX,IY
	ld	iy, (xhl+3)	; F4D8CD  ld IY,(XHL+0x03)
	cp	iy, 65535	; F4D8D0  cp IY,0xffff
	jr	z, BStore_FreeChain_B_Skip	; F4D8D4  jr Z,0xf4d8ed
BStore_FreeChain_B_Loop2:
	and	(xhl), 0x7f	; F4D8D6  and (XHL),0x7f
	ld	(xhl+5), 130	; F4D8D9  ld (XHL+0x05),0x82
	inc	1, wa	; F4D8DD  inc 1,WA
	cp	wa, (0x0c88:16)	; F4D8DF  cp WA,(0x0c88)
	jr	nz, BStore_FreeChain_B_Loop	; F4D8E3  jr NZ,0xf4d8c8
	dec	1, wa	; F4D8E5  dec 1,WA
BStore_FreeChain_B_Join:
	calr	BStore_BlockAddrFromIY	; F4D8E7  calr 0xf4d935
	ld	(xhl+1), de	; F4D8EA  ld (XHL+0x01),DE
BStore_FreeChain_B_Skip:
	cp	de, 0:i3	; F4D8ED  cp DE,0
	jr	z, BStore_FreeChain_B_Skip2	; F4D8EF  jr Z,0xf4d8fb
	pushw	iy	; F4D8F1  push IY
	ld	iy, de	; F4D8F2  ld IY,DE
	calr	BStore_BlockAddrFromIY	; F4D8F4  calr 0xf4d935
	popw	iy	; F4D8F7  pop IY
	ld	(xhl+3), iy	; F4D8F8  ld (XHL+0x03),IY
BStore_FreeChain_B_Skip2:
	ld	iy, ix	; F4D8FB  ld IY,IX
	calr	BStore_BlockAddrFromIY	; F4D8FD  calr 0xf4d935
	and	(xhl), 0x7f	; F4D900  and (XHL),0x7f
	ld	(xhl+5), 130	; F4D903  ld (XHL+0x05),0x82
	ld	(xhl+3), bc	; F4D907  ld (XHL+0x03),BC
	ld	iy, bc	; F4D90A  ld IY,BC
	calr	BStore_BlockAddrFromIY	; F4D90C  calr 0xf4d935
	ld	(xhl+1), ix	; F4D90F  ld (XHL+0x01),IX
	inc	1, wa	; F4D912  inc 1,WA
	add	(BStore_FreeCount:24), wa	; F4D914  add (0x6034ba),WA
	ret	; F4D919  ret
BStore_FreeChain_B_Skip3:
	calr	BStore_BlockAddrFromIY	; F4D91A  calr 0xf4d935
	ld	ix, iy	; F4D91D  ld IX,IY
	ld	iy, (xhl+3)	; F4D91F  ld IY,(XHL+0x03)
	cp	iy, 65535	; F4D922  cp IY,0xffff
	jr	nz, BStore_FreeChain_B_Loop2	; F4D926  jr NZ,0xf4d8d6
	ldw	(3208:16), 0	; F4D928  ld (0x0c88),0x0000
	ld	iy, ix	; F4D92E  ld IY,IX
	and	(xhl), 0x7f	; F4D930  and (XHL),0x7f
	jr	BStore_FreeChain_B_Join	; F4D933  jr T,0xf4d8e7

; --------------------------------------------------------------------------
; BStore_BlockAddrFromIY
; Called from: in-module: 0xF4D7C0 0xF4D86C 0xF4D881 0xF4D88B 0xF4D8AD
;              0xF4D8C0 0xF4D8C8 0xF4D8E7 +4 more
; Touches: (0x3604)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4D935 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_BlockAddrFromIY: XHL := (BStore_HeapBase) + (IY - 1) * 0x100, the address of 1-based block IY, without
;   touching the cursor (XIX preserved; the `lda XIX,XIX+0` is a no-op). BStore_FormatHeap, BStore_AllocBlock_B and
;   BStore_FreeChain_B fetch every block they link this way; BStore_SetCursorBlockAddrFromIY is the same arithmetic
;   plus the store to BStore_CursorBlockAddr. Basis: callers + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_o.json)
BStore_BlockAddrFromIY:
	push	xix	; F4D935  push XIX
	xor	xhl, xhl	; F4D936  xor XHL,XHL
	ld	hl, iy	; F4D938  ld HL,IY
	dec	1, xhl	; F4D93A  dec 1,XHL
	sla	xhl, 8	; F4D93C  sla 0x08,XHL
	ld	xix, (BStore_HeapBase:16)	; F4D93F  ld XIX,(0x3604)
	lda	xix, (xix+0:8)	; F4D943  lda XIX,XIX+0x00
	add	xhl, xix	; F4D946  add XHL,XIX
	pop	xix	; F4D948  pop XIX
	ret	; F4D949  ret
	.fill	1718, 1, 0x0E	; F4D94A-F4DFFF  `ret` padding (asserted pure 0x0E)
