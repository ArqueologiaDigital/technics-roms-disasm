

; --------------------------------------------------------------------------
; BStore_CompactBlocks_Veneer
; Called from: T_BStore_CompactBlocks_Veneer (x2)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_CompactBlocks_Veneer holds `jp 0x00F4C800`, and 0xF4C800 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_CompactBlocks_Veneer: `jr` to BStore_CompactBlocks, which compacts the block heap: repeatedly moves the highest in-use
;   block (header bit 7) into the lowest free one (256-byte copy, chain links or the ten banks' chain-table entries
;   repointed), then sets (0x603452) and runs BStore_ThreadFreeListFrom. SeqFile_Load calls it (T_BStore_CompactBlocks_Veneer) before reading the song's
;   blocks after the free head. BStore_CompactBlocks should carry BStore_CompactBlocks. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_l.json)
BStore_CompactBlocks_Veneer:		; <- T_BStore_CompactBlocks_Veneer
	jr	BStore_CompactBlocks	; F4C800  jr T,0xf4c811

; --------------------------------------------------------------------------
; BStore_RebuildFreeListAfterLoad_Veneer
; Called from: T_BStore_RebuildFreeListAfterLoad_Veneer (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_RebuildFreeListAfterLoad_Veneer holds `jp 0x00F4C802`, and 0xF4C802 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_RebuildFreeListAfterLoad_Veneer: Veneer: `jr` to BStore_RebuildFreeListAfterLoad, which sets (0x34CE) := BStore_BlockCount, finds
;   the first block from 1 whose header bit 7 (in use) is clear and threads it and every later block onto the free
;   list (BStore_FreeHead / BStore_FreeCount; none left -> 0xFFFF / 0). SeqFile_LoadAllBanks calls it (slot T_BStore_RebuildFreeListAfterLoad_Veneer)
;   after reading the SEQ into the heap; for an empty store it sets the free head to 1 and runs
;   BStore_RebuildFreeChain instead. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
BStore_RebuildFreeListAfterLoad_Veneer:		; <- T_BStore_RebuildFreeListAfterLoad_Veneer
	jr	BStore_RebuildFreeListAfterLoad	; F4C802  jr T,0xf4c804

; --------------------------------------------------------------------------
; BStore_RebuildFreeListAfterLoad
; Called from: in-module: 0xF4CA8E
; Touches: nothing with an absolute address
; Calls:   BStore_LatchBlockCount BStore_FindFreeBlockUp BStore_ThreadFreeListFrom
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4C804 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_RebuildFreeListAfterLoad: (0x34CE) := BStore_BlockCount; from block 1 finds the first block whose header bit
;   7 is clear (BStore_FindFreeBlockUp) and threads it and every later block onto the free list (BStore_ThreadFreeListFrom:
;   BStore_FreeHead/FreeCount, none -> 0xFFFF / 0). The body behind BStore_RebuildFreeListAfterLoad_Veneer; also
;   SysExDump_RestoreSavedCurrentBank. Basis: caller (veneer header) + body. (notes/naming-pilot-2026-10-06/proposals_wave5_p.json)
BStore_RebuildFreeListAfterLoad:
	calr	BStore_LatchBlockCount	; F4C804  calr 0xf4c85a
	ldw	de, 1	; F4C807  ld DE,0x0001
	calr	BStore_FindFreeBlockUp	; F4C80A  calr 0xf4c89e
	calr	BStore_ThreadFreeListFrom	; F4C80D  calr 0xf4c9b4
	ret	; F4C810  ret

; --------------------------------------------------------------------------
; BStore_CompactBlocks
; Called from: in-module: 0xF4CA3F 0xF4CAB5
; Touches: (0x34CE)
; Calls:   BStore_LatchBlockCount BStore_FindUsedBlockDown BStore_FindFreeBlockUp BStore_RelocateBlock BStore_ThreadFreeListFrom
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4C811 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_CompactBlocks: Compacts the block heap: (0x34CE) := BStore_BlockCount; while the lowest free block DE is
;   below the highest used block BC, copies BC into DE (256-byte ldir, source bit 7 cleared) and repoints the
;   neighbour links or, for a chain head / tail, the ten bank copies' directory heads (+0x100) / saved-cursor blocks
;   (+0x7E); then (0x603452) := used blocks rounded up to 4, x16, and the free list is rebuilt from DE (BStore_ThreadFreeListFrom).
;   BStore_CompactBlocks_Veneer jumps here; SeqFile_PrepareSaveAllBanks and SysExDump_PrepareSequencerData run it
;   before a save / dump. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
BStore_CompactBlocks:
	calr	BStore_LatchBlockCount	; F4C811  calr 0xf4c85a
	pushw	wa	; F4C814  push WA
	sla	wa, 4	; F4C815  sla 0x04,WA
	ld	(6304850:24), wa	; F4C818  ld (0x603452),WA
	popw	wa	; F4C81D  pop WA
	ld	bc, wa	; F4C81E  ld BC,WA
	calr	BStore_FindUsedBlockDown	; F4C820  calr 0xf4c863
	ldw	de, 1	; F4C823  ld DE,0x0001
	calr	BStore_FindFreeBlockUp	; F4C826  calr 0xf4c89e
	ld	wa, (13518:16)	; F4C829  ld WA,(0x34ce)
	cp	de, wa	; F4C82D  cp DE,WA
	jr	ugt, BStore_CompactBlocks_Return	; F4C82F  jr UGT,0xf4c859
BStore_CompactBlocks_Join:
	cp	de, bc	; F4C831  cp DE,BC
	jr	ugt, BStore_CompactBlocks_Skip	; F4C833  jr UGT,0xf4c83a
	calr	BStore_RelocateBlock	; F4C835  calr 0xf4c8dd
	jr	BStore_CompactBlocks_Join	; F4C838  jr T,0xf4c831
BStore_CompactBlocks_Skip:
	pushw	de	; F4C83A  push DE
	dec	1, de	; F4C83B  dec 1,DE
	ld	iz, de	; F4C83D  ld IZ,DE
	and	iz, 3	; F4C83F  and IZ,0x0003
	jr	z, BStore_CompactBlocks_Skip2	; F4C843  jr Z,0xf4c84d
	add	de, 4	; F4C845  add DE,0x0004
	and	de, 65532	; F4C849  and DE,0xfffc
BStore_CompactBlocks_Skip2:
	sla	de, 4	; F4C84D  sla 0x04,DE
	ld	(6304850:24), de	; F4C850  ld (0x603452),DE
	popw	de	; F4C855  pop DE
	calr	BStore_ThreadFreeListFrom	; F4C856  calr 0xf4c9b4
BStore_CompactBlocks_Return:
	ret	; F4C859  ret

; --------------------------------------------------------------------------
; BStore_LatchBlockCount
; Called from: in-module: 0xF4C804 0xF4C811
; Touches: (0x34CE) (0x3608)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4C85A is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_LatchBlockCount: (0x34CE) := BStore_BlockCount, also returned in WA: the upper bound that
;   BStore_FindFreeBlockUp and BStore_ThreadFreeListFrom scan to. First step of BStore_CompactBlocks (which also turns
;   WA into (0x603452) and the starting BC) and of BStore_RebuildFreeListAfterLoad. Basis: callers + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
BStore_LatchBlockCount:
	ld	wa, (BStore_BlockCount:16)	; F4C85A  ld WA,(0x3608)
	ld	(13518:16), wa	; F4C85E  ld (0x34ce),WA
	ret	; F4C862  ret

; --------------------------------------------------------------------------
; BStore_FindUsedBlockDown
; Called from: in-module: 0xF4C820 0xF4C8E9
; Touches: (0x0C9A)
; Calls:   T_BStore_BlockAddrFromHL
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4C863 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_FindUsedBlockDown: From block BC downwards, finds the first block whose header bit 7 (allocated) is set:
;   returns BC = that block and XHL = its address (BStore_BlockAddrFromHL), or BC = 0 when none. BStore_CompactBlocks
;   starts it at the last block to find the highest used one, BStore_RelocateBlock re-runs it after each move. Basis:
;   callers + body. (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
BStore_FindUsedBlockDown:
	ld	hl, bc	; F4C863  ld HL,BC
	call	T_BStore_BlockAddrFromHL	; F4C865  call 0xf40c84
	ldw	(3226:16), 0	; F4C869  ld (0x0c9a),0x0000
BStore_FindUsedBlockDown_Join:
	cpw	(0x0c9a:16), 0x0001	; F4C86F  cp (0x0c9a),0x0001
	jr	z, BStore_FindUsedBlockDown_Return	; F4C875  jr Z,0xf4c89d
	ld	a, (xhl+0:8)	; F4C877  ld A,(XHL+0x00)
	bit	7, a	; F4C87A  bit 0x07,A
	jr	z, BStore_FindUsedBlockDown_Skip	; F4C87D  jr Z,0xf4c887
	ldw	(3226:16), 1	; F4C87F  ld (0x0c9a),0x0001
	jr	BStore_FindUsedBlockDown_Join	; F4C885  jr T,0xf4c86f
BStore_FindUsedBlockDown_Skip:
	dec	1, bc	; F4C887  dec 1,BC
	cp	bc, 0:i3	; F4C889  cp BC,0
	jr	nz, BStore_FindUsedBlockDown_Skip2	; F4C88B  jr NZ,0xf4c895
	ldw	(3226:16), 1	; F4C88D  ld (0x0c9a),0x0001
	jr	BStore_FindUsedBlockDown_Join	; F4C893  jr T,0xf4c86f
BStore_FindUsedBlockDown_Skip2:
	ld	hl, bc	; F4C895  ld HL,BC
	call	T_BStore_BlockAddrFromHL	; F4C897  call 0xf40c84
	jr	BStore_FindUsedBlockDown_Join	; F4C89B  jr T,0xf4c86f
BStore_FindUsedBlockDown_Return:
	ret	; F4C89D  ret

; --------------------------------------------------------------------------
; BStore_FindFreeBlockUp
; Called from: in-module: 0xF4C80A 0xF4C826 0xF4C8EC
; Touches: (0x0C9A) (0x34CE)
; Calls:   T_BStore_BlockAddrFromHL
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4C89E is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_FindFreeBlockUp: From block DE upwards, finds the first block whose header bit 7 (allocated) is clear:
;   returns DE = that block and XHL = its address, or DE past (0x34CE) (BStore_LatchBlockCount) when none.
;   BStore_CompactBlocks and BStore_RebuildFreeListAfterLoad start it at block 1; BStore_RelocateBlock re-runs it
;   after each move. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
BStore_FindFreeBlockUp:
	ld	hl, de	; F4C89E  ld HL,DE
	call	T_BStore_BlockAddrFromHL	; F4C8A0  call 0xf40c84
	ldw	(3226:16), 0	; F4C8A4  ld (0x0c9a),0x0000
BStore_FindFreeBlockUp_Join:
	cpw	(0x0c9a:16), 0x0001	; F4C8AA  cp (0x0c9a),0x0001
	jr	z, BStore_FindFreeBlockUp_Return	; F4C8B0  jr Z,0xf4c8dc
	ld	a, (xhl+0:8)	; F4C8B2  ld A,(XHL+0x00)
	bit	7, a	; F4C8B5  bit 0x07,A
	jr	nz, BStore_FindFreeBlockUp_Skip	; F4C8B8  jr NZ,0xf4c8c2
	ldw	(3226:16), 1	; F4C8BA  ld (0x0c9a),0x0001
	jr	BStore_FindFreeBlockUp_Join	; F4C8C0  jr T,0xf4c8aa
BStore_FindFreeBlockUp_Skip:
	inc	1, de	; F4C8C2  inc 1,DE
	ld	wa, (13518:16)	; F4C8C4  ld WA,(0x34ce)
	cp	de, wa	; F4C8C8  cp DE,WA
	jr	ule, BStore_FindFreeBlockUp_Skip2	; F4C8CA  jr ULE,0xf4c8d4
	ldw	(3226:16), 1	; F4C8CC  ld (0x0c9a),0x0001
	jr	BStore_FindFreeBlockUp_Join	; F4C8D2  jr T,0xf4c8aa
BStore_FindFreeBlockUp_Skip2:
	ld	hl, de	; F4C8D4  ld HL,DE
	call	T_BStore_BlockAddrFromHL	; F4C8D6  call 0xf40c84
	jr	BStore_FindFreeBlockUp_Join	; F4C8DA  jr T,0xf4c8aa
BStore_FindFreeBlockUp_Return:
	ret	; F4C8DC  ret

; --------------------------------------------------------------------------
; BStore_RelocateBlock
; Called from: in-module: 0xF4C835
; Touches: nothing with an absolute address
; Calls:   BStore_RelocateGetBlockAddrs BStore_RelocateCopyBlock BStore_RelocateRepointPrevLink BStore_RelocateRepointNextLink BStore_FindUsedBlockDown BStore_FindFreeBlockUp
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4C8DD is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_RelocateBlock: One BStore_CompactBlocks step: copies used block BC into free block DE (256-byte ldir, the
;   source's bit 7 cleared), repoints the neighbours (prev's +3 / next's +1) or, at a chain head / tail, the ten bank
;   copies' directory heads (+0x100) / saved-cursor blocks (+0x7E) from BC to DE, then steps BC down to the next used
;   block and DE up to the next free one. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
BStore_RelocateBlock:
	calr	BStore_RelocateGetBlockAddrs	; F4C8DD  calr 0xf4c8f0
	calr	BStore_RelocateCopyBlock	; F4C8E0  calr 0xf4c901
	calr	BStore_RelocateRepointPrevLink	; F4C8E3  calr 0xf4c911
	calr	BStore_RelocateRepointNextLink	; F4C8E6  calr 0xf4c96b
	calr	BStore_FindUsedBlockDown	; F4C8E9  calr 0xf4c863
	calr	BStore_FindFreeBlockUp	; F4C8EC  calr 0xf4c89e
	ret	; F4C8EF  ret

; --------------------------------------------------------------------------
; BStore_RelocateGetBlockAddrs
; Called from: in-module: 0xF4C8DD
; Touches: nothing with an absolute address
; Calls:   T_BStore_BlockAddrFromHL
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4C8F0 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_RelocateGetBlockAddrs: First step of BStore_RelocateBlock: XIY := the address of used block BC (the source)
;   and XIX := that of free block DE (the destination), via T_BStore_BlockAddrFromHL, for the 256-byte ldir that
;   follows. Basis: caller header + body. (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
BStore_RelocateGetBlockAddrs:
	ld	hl, bc	; F4C8F0  ld HL,BC
	call	T_BStore_BlockAddrFromHL	; F4C8F2  call 0xf40c84
	ld	xiy, xhl	; F4C8F6  ld XIY,XHL
	ld	hl, de	; F4C8F8  ld HL,DE
	call	T_BStore_BlockAddrFromHL	; F4C8FA  call 0xf40c84
	ld	xix, xhl	; F4C8FE  ld XIX,XHL
	ret	; F4C900  ret

; --------------------------------------------------------------------------
; BStore_RelocateCopyBlock
; Called from: in-module: 0xF4C8E0
; Touches: nothing with an absolute address
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4C901 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_RelocateCopyBlock: Copies the 256-byte block at XIY to XIX (ldir) and clears bit 7 (in use) of the source
;   header: the move step of BStore_RelocateBlock after BStore_RelocateGetBlockAddrs set the two addresses. BC, XIX and XIY preserved.
;   Basis: caller header + body. (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
BStore_RelocateCopyBlock:
	pushw	bc	; F4C901  push BC
	push	xix	; F4C902  push XIX
	push	xiy	; F4C903  push XIY
	ldw	bc, 256	; F4C904  ld BC,0x0100
	ldir85	; F4C907  ldir
	pop	xiy	; F4C909  pop XIY
	and	(xiy+0:8), 0x7f	; F4C90A  and (XIY+0x00),0x7f
	pop	xix	; F4C90E  pop XIX
	popw	bc	; F4C90F  pop BC
	ret	; F4C910  ret

; --------------------------------------------------------------------------
; BStore_RelocateRepointPrevLink
; Called from: in-module: 0xF4C8E3
; Touches:   |  0x000003 0x610000
; Calls:   T_BStore_BlockAddrFromHL
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4C911 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_RelocateRepointPrevLink: BStore_RelocateBlock's backward-link fix for a block moved BC -> DE (XIX = its new
;   copy): returns IY = its +3 next; when its +1 prev is set, that block's +3 next := DE; when 0 (chain head), every
;   in-use directory entry of the ten bank copies (0x610000 + n*0xC00 + 0x100, 17 x 3 bytes) whose head is BC gets DE.
;   Basis: caller header + body. (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
BStore_RelocateRepointPrevLink:
	ld	wa, (xix+3)	; F4C911  ld WA,(XIX+0x03)
	ld	iy, wa	; F4C914  ld IY,WA
	pushw	iy	; F4C916  push IY
	ld	wa, (xix+1)	; F4C917  ld WA,(XIX+0x01)
	cp	wa, 0:i3	; F4C91A  cp WA,0
	jr	nz, BStore_RelocateRepointPrevLink_Skip4	; F4C91C  jr NZ,0xf4c960
	xor	hl, hl	; F4C91E  xor HL,HL
BStore_RelocateRepointPrevLink_Join:
	cp	l, 10	; F4C920  cp L,0x0a
	jr	nc, BStore_RelocateRepointPrevLink_Skip3	; F4C923  jr NC,0xf4c95e
	xor	xwa, xwa	; F4C925  xor XWA,XWA
	ld	wa, hl	; F4C927  ld WA,HL
	mul	wa, 3072	; F4C929  mul WA,0x0c00
	add	xwa, 6356992	; F4C92D  add XWA,0x00610000
	lda	xiz, (xwa+0x0100)	; F4C933  lda XIZ,XWA+0x0100
	ld	xix, xiz	; F4C938  ld XIX,XIZ
BStore_RelocateRepointPrevLink_Join2:
	lda	xwa, (xiz+51)	; F4C93A  lda XWA,XIZ+0x33
	cp	xix, xwa	; F4C93D  cp XIX,XWA
	jr	z, BStore_RelocateRepointPrevLink_Skip2	; F4C93F  jr Z,0xf4c95a
	ld	a, (xix)	; F4C941  ld A,(XIX)
	bit	7, a	; F4C943  bit 0x07,A
	jr	z, BStore_RelocateRepointPrevLink_Skip	; F4C946  jr Z,0xf4c952
	ld	wa, (xix+1)	; F4C948  ld WA,(XIX+0x01)
	cp	wa, bc	; F4C94B  cp WA,BC
	jr	nz, BStore_RelocateRepointPrevLink_Skip	; F4C94D  jr NZ,0xf4c952
	ld	(xix+1), de	; F4C94F  ld (XIX+0x01),DE
BStore_RelocateRepointPrevLink_Skip:
	add	xix, 3	; F4C952  add XIX,0x00000003
	jr	BStore_RelocateRepointPrevLink_Join2	; F4C958  jr T,0xf4c93a
BStore_RelocateRepointPrevLink_Skip2:
	inc	1, l	; F4C95A  inc 1,L
	jr	BStore_RelocateRepointPrevLink_Join	; F4C95C  jr T,0xf4c920
BStore_RelocateRepointPrevLink_Skip3:
	jr	BStore_RelocateRepointPrevLink_Epilogue	; F4C95E  jr T,0xf4c969
BStore_RelocateRepointPrevLink_Skip4:
	ld	hl, wa	; F4C960  ld HL,WA
	call	T_BStore_BlockAddrFromHL	; F4C962  call 0xf40c84
	ld	(xhl+3), de	; F4C966  ld (XHL+0x03),DE
BStore_RelocateRepointPrevLink_Epilogue:
	popw	iy	; F4C969  pop IY
	ret	; F4C96A  ret

; --------------------------------------------------------------------------
; BStore_RelocateRepointNextLink
; Called from: in-module: 0xF4C8E6
; Touches:   |  0x000002 0x610000
; Calls:   T_BStore_BlockAddrFromHL
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4C96B is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_RelocateRepointNextLink: BStore_RelocateBlock's forward-link fix for a block moved BC -> DE: when its next IY
;   (from BStore_RelocateRepointPrevLink) is not 0xFFFF, that block's +1 prev := DE; at a chain tail, every saved end-cursor block word of
;   the ten bank copies (0x610000 + n*0xC00 + 0x7E, 17 words) equal to BC becomes DE. Basis: caller header + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
BStore_RelocateRepointNextLink:
	ld	wa, iy	; F4C96B  ld WA,IY
	cp	wa, 65535	; F4C96D  cp WA,0xffff
	jr	nz, BStore_RelocateRepointNextLink_Skip4	; F4C971  jr NZ,0xf4c9aa
	xor	hl, hl	; F4C973  xor HL,HL
BStore_RelocateRepointNextLink_Join:
	cp	l, 10	; F4C975  cp L,0x0a
	jr	nc, BStore_RelocateRepointNextLink_Skip3	; F4C978  jr NC,0xf4c9a8
	xor	xwa, xwa	; F4C97A  xor XWA,XWA
	ld	wa, hl	; F4C97C  ld WA,HL
	mul	wa, 3072	; F4C97E  mul WA,0x0c00
	add	xwa, 6356992	; F4C982  add XWA,0x00610000
	lda	xiz, (xwa+126)	; F4C988  lda XIZ,XWA+0x7e
	ld	xix, xiz	; F4C98B  ld XIX,XIZ
BStore_RelocateRepointNextLink_Join2:
	lda	xwa, (xiz+34)	; F4C98D  lda XWA,XIZ+0x22
	cp	xix, xwa	; F4C990  cp XIX,XWA
	jr	z, BStore_RelocateRepointNextLink_Skip2	; F4C992  jr Z,0xf4c9a4
	ld	wa, (xix)	; F4C994  ld WA,(XIX)
	cp	wa, bc	; F4C996  cp WA,BC
	jr	nz, BStore_RelocateRepointNextLink_Skip	; F4C998  jr NZ,0xf4c99c
	ld	(xix), de	; F4C99A  ld (XIX),DE
BStore_RelocateRepointNextLink_Skip:
	add	xix, 2	; F4C99C  add XIX,0x00000002
	jr	BStore_RelocateRepointNextLink_Join2	; F4C9A2  jr T,0xf4c98d
BStore_RelocateRepointNextLink_Skip2:
	inc	1, l	; F4C9A4  inc 1,L
	jr	BStore_RelocateRepointNextLink_Join	; F4C9A6  jr T,0xf4c975
BStore_RelocateRepointNextLink_Skip3:
	jr	BStore_RelocateRepointNextLink_Return	; F4C9A8  jr T,0xf4c9b3
BStore_RelocateRepointNextLink_Skip4:
	ld	hl, wa	; F4C9AA  ld HL,WA
	call	T_BStore_BlockAddrFromHL	; F4C9AC  call 0xf40c84
	ld	(xhl+1), de	; F4C9B0  ld (XHL+0x01),DE
BStore_RelocateRepointNextLink_Return:
	ret	; F4C9B3  ret

; --------------------------------------------------------------------------
; BStore_ThreadFreeListFrom
; Called from: in-module: 0xF4C80D 0xF4C856
; Touches: (0x34CE)
; Calls:   T_BStore_BlockAddrFromHL BStore_ThreadFreeBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4C9B4 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ThreadFreeListFrom: Rebuilds the free list as blocks DE..(0x34CE): BStore_FreeHead := DE, each block's bit 7
;   cleared, prev/next linked, +5 := 0x82, the last one's next := 0xFFFF, BStore_FreeCount := the number threaded; DE
;   past the bound -> FreeHead 0xFFFF, FreeCount 0. Last step of BStore_CompactBlocks (DE = first block after the
;   compacted data) and of BStore_RebuildFreeListAfterLoad. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_s.json)
BStore_ThreadFreeListFrom:
	ld	wa, (13518:16)	; F4C9B4  ld WA,(0x34ce)
	cp	de, wa	; F4C9B8  cp DE,WA
	jr	ule, BStore_ThreadFreeListFrom_Skip	; F4C9BA  jr ULE,0xf4c9cc
	ldw	(BStore_FreeCount:24), 0	; F4C9BC  ld (0x6034ba),0x0000
	ldw	(BStore_FreeHead:24), 65535	; F4C9C3  ld (0x6034b8),0xffff
	jr	BStore_ThreadFreeListFrom_Return	; F4C9CA  jr T,0xf4ca09
BStore_ThreadFreeListFrom_Skip:
	ld	(BStore_FreeHead:24), de	; F4C9CC  ld (0x6034b8),DE
	ld	wa, de	; F4C9D1  ld WA,DE
	ldw	(BStore_FreeCount:24), 0	; F4C9D3  ld (0x6034ba),0x0000
	ld	ix, wa	; F4C9DA  ld IX,WA
	inc	1, ix	; F4C9DC  inc 1,IX
	ldw	iy, 0	; F4C9DE  ld IY,0x0000
	ld	hl, wa	; F4C9E1  ld HL,WA
	call	T_BStore_BlockAddrFromHL	; F4C9E3  call 0xf40c84
BStore_ThreadFreeListFrom_Join:
	ld	iz, (13518:16)	; F4C9E7  ld IZ,(0x34ce)
	cp	wa, iz	; F4C9EB  cp WA,IZ
	jr	nc, BStore_ThreadFreeListFrom_Skip2	; F4C9ED  jr NC,0xf4c9f4
	calr	BStore_ThreadFreeBlock	; F4C9EF  calr 0xf4ca0a
	jr	BStore_ThreadFreeListFrom_Join	; F4C9F2  jr T,0xf4c9e7
BStore_ThreadFreeListFrom_Skip2:
	ld	(xhl+0:8), 0x7f	; F4C9F4  ld (XHL+0x00),0x7f
	incw	1, (BStore_FreeCount:24)	; F4C9F8  incw 1,(0x6034ba)
	ld	(xhl+1), iy	; F4C9FD  ld (XHL+0x01),IY
	ldw	(xhl+3), 0xffff	; F4CA00  ld (XHL+0x03),0xffff
	ld	(xhl+5), 130	; F4CA05  ld (XHL+0x05),0x82
BStore_ThreadFreeListFrom_Return:
	ret	; F4CA09  ret

; --------------------------------------------------------------------------
; BStore_ThreadFreeBlock
; Called from: in-module: 0xF4C9EF
; Touches: nothing with an absolute address
; Calls:   T_BStore_BlockAddrFromHL
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4CA0A is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ThreadFreeBlock: One step of BStore_ThreadFreeListFrom: block WA (at XHL) gets bit 7 cleared, prev := IY,
;   next := IX, an 0x82 at +5, and BStore_FreeCount += 1; then IY := WA, WA := IX, IX += 1 and XHL := the next block's
;   address. The loop ends with the last block's next = 0xFFFF. Basis: caller + caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_w.json)
BStore_ThreadFreeBlock:
	and	(xhl+0:8), 0x7f	; F4CA0A  and (XHL+0x00),0x7f
	incw	1, (BStore_FreeCount:24)	; F4CA0E  incw 1,(0x6034ba)
	ld	(xhl+1), iy	; F4CA13  ld (XHL+0x01),IY
	ld	(xhl+3), ix	; F4CA16  ld (XHL+0x03),IX
	ld	(xhl+5), 130	; F4CA19  ld (XHL+0x05),0x82
	ld	iy, wa	; F4CA1D  ld IY,WA
	ld	wa, ix	; F4CA1F  ld WA,IX
	inc	1, ix	; F4CA21  inc 1,IX
	ld	hl, wa	; F4CA23  ld HL,WA
	call	T_BStore_BlockAddrFromHL	; F4CA25  call 0xf40c84
	ret	; F4CA29  ret

; --------------------------------------------------------------------------
; SysExDump_PrepareSequencerData
; Called from: T_SysExDump_PrepareSequencerData (x1)
; Touches: (0x360A) (0x360C)
; Calls:   BStore_Workspace_CopyToBank BStore_CompactBlocks BStore_Workspace_CopyFromBank
; Evidence: thunk slot T_SysExDump_PrepareSequencerData holds `jp 0x00F4CA2A`, and 0xF4CA2A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExDump_PrepareSequencerData: Before a sequencer SysEx dump: workspace (0x6034D0) := BStore_CurrentBank and
;   (0x6034D1) := the saved track mask (0x360C); copies the workspace into its bank copy (0x610000 + bank * 0xC00),
;   runs BStore_CompactBlocks (which writes the size (0x603452)), and copies the bank copy back with (0x603452) and the free
;   head/count kept. SysExDump_SequencerUsedBytes then reports 16 * (0x603452). Basis: caller + body + twins.
;   (notes/naming-pilot-2026-10-06/proposals_wave4_n.json)
SysExDump_PrepareSequencerData:		; <- T_SysExDump_PrepareSequencerData
	ld	a, (BStore_CurrentBank:16)	; F4CA2A  ld A,(0x360a)
	ld	(6304976:24), a	; F4CA2E  ld (0x6034d0),A
	ld	xwa, (13836:16)	; F4CA33  ld XWA,(0x360c)
	ld	(6304977:24), xwa	; F4CA37  ld (0x6034d1),XWA
	calr	BStore_Workspace_CopyToBank	; F4CA3C  calr 0xf4cb0d
	calr	BStore_CompactBlocks	; F4CA3F  calr 0xf4c811
	pushw	(0x603452:24)	; F4CA42  pushw (0x603452)
	pushw	(BStore_FreeHead:24)	; F4CA47  pushw (0x6034b8)
	pushw	(BStore_FreeCount:24)	; F4CA4C  pushw (0x6034ba)
	calr	BStore_Workspace_CopyFromBank	; F4CA51  calr 0xf4cb34
	popw	(BStore_FreeCount:24)	; F4CA54  popw (0x6034ba)
	popw	(BStore_FreeHead:24)	; F4CA59  popw (0x6034b8)
	popw	(0x603452:24)	; F4CA5E  popw (0x603452)
	ret	; F4CA63  ret

; --------------------------------------------------------------------------
; SysExDump_RestoreSavedCurrentBank
; Called from: T_SysExDump_RestoreSavedCurrentBank (x1)
; Touches: (0x34BB) (0x3552) (0x360A) (0x360C)
; Calls:   BStore_RebuildFreeListAfterLoad
; Evidence: thunk slot T_SysExDump_RestoreSavedCurrentBank holds `jp 0x00F4CA64`, and 0xF4CA64 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExDump_RestoreSavedCurrentBank: After a received SEQUENCER dump: BStore_CurrentBank := (0x6034D0) and (0x360C) :=
;   (0x6034D1) -- where SysExDump_PrepareSequencerData stashed them before sending -- both cleared, (0x3552) := 1,
;   (0x34BB) bit 3 cleared, then BStore_RebuildFreeListAfterLoad. SysEx twin of SeqFile_RestoreSavedCurrentBank.
;   Basis: caller + body + twins. (notes/naming-pilot-2026-10-06/proposals_wave9_d9.json)
SysExDump_RestoreSavedCurrentBank:		; <- T_SysExDump_RestoreSavedCurrentBank
	ld	a, (6304976:24)	; F4CA64  ld A,(0x6034d0)
	ld	(BStore_CurrentBank:16), a	; F4CA69  ld (0x360a),A
	ld	(6304976:24), 0	; F4CA6D  ld (0x6034d0),0x00
	ld	xwa, (6304977:24)	; F4CA73  ld XWA,(0x6034d1)
	ld	(13836:16), xwa	; F4CA78  ld (0x360c),XWA
	xor	xwa, xwa	; F4CA7C  xor XWA,XWA
	ld	(6304977:24), xwa	; F4CA7E  ld (0x6034d1),XWA
	ldw	(13650:16), 1	; F4CA83  ld (0x3552),0x0001
	and	(0x34bb:16), 0xf7	; F4CA89  and (0x34bb),0xf7
	calr	BStore_RebuildFreeListAfterLoad	; F4CA8E  calr 0xf4c804
	ret	; F4CA91  ret

; --------------------------------------------------------------------------
; SeqFile_PrepareSaveAllBanks
; Called from: T_SeqFile_PrepareSaveAllBanks (x1)
; Touches: (0x360A) (0x360C)  |  0x610000
; Calls:   BStore_Workspace_CopyToBank BStore_CompactBlocks BStore_Workspace_CopyFromBank
; Evidence: thunk slot T_SeqFile_PrepareSaveAllBanks holds `jp 0x00F4CA92`, and 0xF4CA92 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqFile_PrepareSaveAllBanks: First step of SeqFile_SaveAllBanks (T_SeqFile_PrepareSaveAllBanks): workspace -> its bank copy (BStore_Workspace_CopyToBank),
;   the current bank (0x360A) and (0x360C) stashed at bank 0's copy +0xD0/+0xD1 (0x6100D0), BStore_CompactBlocks (which sets
;   (0x603452), the SEQ length in 16-byte units the save writes), then bank copy -> workspace (BStore_Workspace_CopyFromBank) keeping
;   (0x603452), BStore_FreeHead and BStore_FreeCount. SeqFile_RestoreSavedCurrentBank (T_SeqFile_RestoreSavedCurrentBank, run by SeqFile_LoadAllBanks) takes the
;   stash back; twin of SysExDump_PrepareSequencerData (SysExDump_SequencerUsedBytes), which stashes at 0x6034D0. Basis: caller + body +
;   inverse. (notes/naming-pilot-2026-10-06/proposals_wave4_k.json)
SeqFile_PrepareSaveAllBanks:		; <- T_SeqFile_PrepareSaveAllBanks
	calr	BStore_Workspace_CopyToBank	; F4CA92  calr 0xf4cb0d
	ld	xde, 6356992	; F4CA95  ld XDE,0x00610000
	lda	xde, (xde+208)	; F4CA9A  lda XDE,XDE+0x00d0
	ld	a, (BStore_CurrentBank:16)	; F4CA9F  ld A,(0x360a)
	ld	(xde), a	; F4CAA3  ld (XDE),A
	ld	xde, 6356992	; F4CAA5  ld XDE,0x00610000
	lda	xde, (xde+209)	; F4CAAA  lda XDE,XDE+0x00d1
	ld	xwa, (13836:16)	; F4CAAF  ld XWA,(0x360c)
	ld	(xde), xwa	; F4CAB3  ld (XDE),XWA
	calr	BStore_CompactBlocks	; F4CAB5  calr 0xf4c811
	pushw	(0x603452:24)	; F4CAB8  pushw (0x603452)
	pushw	(BStore_FreeHead:24)	; F4CABD  pushw (0x6034b8)
	pushw	(BStore_FreeCount:24)	; F4CAC2  pushw (0x6034ba)
	calr	BStore_Workspace_CopyFromBank	; F4CAC7  calr 0xf4cb34
	popw	(BStore_FreeCount:24)	; F4CACA  popw (0x6034ba)
	popw	(BStore_FreeHead:24)	; F4CACF  popw (0x6034b8)
	popw	(0x603452:24)	; F4CAD4  popw (0x603452)
	ret	; F4CAD9  ret

; --------------------------------------------------------------------------
; SeqFile_RestoreSavedCurrentBank
; Called from: T_SeqFile_RestoreSavedCurrentBank (x1)
; Touches: (0x34BB) (0x3552) (0x360A) (0x360C)  |  0x610000
; Evidence: thunk slot T_SeqFile_RestoreSavedCurrentBank holds `jp 0x00F4CADA`, and 0xF4CADA is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqFile_RestoreSavedCurrentBank: After the all-banks SQF has been read into the ten bank copies: BStore_CurrentBank
;   := byte +0xD0 of bank copy 0 and (0x360C) (the song track mask) := its long at +0xD1 -- where SeqFile_PrepareSaveAllBanks stores
;   them before SeqFile_SaveAllBanks writes -- clearing both fields; current measure := 1, (0x34BB) bit 3 cleared.
;   Called by SeqFile_LoadAllBanks. Basis: caller + body + save twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_l.json)
SeqFile_RestoreSavedCurrentBank:		; <- T_SeqFile_RestoreSavedCurrentBank
	ld	xde, 6356992	; F4CADA  ld XDE,0x00610000
	lda	xde, (xde+208)	; F4CADF  lda XDE,XDE+0x00d0
	ld	a, (xde)	; F4CAE4  ld A,(XDE)
	ld	(BStore_CurrentBank:16), a	; F4CAE6  ld (0x360a),A
	ld	(xde), 0	; F4CAEA  ld (XDE),0x00
	ld	xde, 6356992	; F4CAED  ld XDE,0x00610000
	lda	xde, (xde+209)	; F4CAF2  lda XDE,XDE+0x00d1
	ld	xwa, (xde)	; F4CAF7  ld XWA,(XDE)
	ld	(13836:16), xwa	; F4CAF9  ld (0x360c),XWA
	xor	xwa, xwa	; F4CAFD  xor XWA,XWA
	ld	(xde), xwa	; F4CAFF  ld (XDE),XWA
	ldw	(13650:16), 1	; F4CB01  ld (0x3552),0x0001
	and	(0x34bb:16), 0xf7	; F4CB07  and (0x34bb),0xf7
	ret	; F4CB0C  ret

; --------------------------------------------------------------------------
; BStore_Workspace_CopyToBank
; Called from: in-module: 0xF4CA3C 0xF4CA92
; Touches: (0x360A)  |  0x603400 0x610000
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4CB0D is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_Workspace_CopyToBank: Copies the 3 KiB song workspace 0x603400 into its bank copy 0x610000 +
;   BStore_CurrentBank * 0xC00 (ldirw of 0x600 words, XHL source, XDE destination), all registers saved; unlike
;   BStore_Workspace_SaveToBank it does not stash (0x360C). First step of SeqFile_PrepareSaveAllBanks and of
;   SysExDump_PrepareSequencerData, whose headers call it "workspace -> its bank copy". Basis: callers + body + twin.
;   (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
BStore_Workspace_CopyToBank:
	push	xwa	; F4CB0D  push XWA
	push	xbc	; F4CB0E  push XBC
	push	xhl	; F4CB0F  push XHL
	push	xde	; F4CB10  push XDE
	xor	wa, wa	; F4CB11  xor WA,WA
	ld	a, (BStore_CurrentBank:16)	; F4CB13  ld A,(0x360a)
	ldw	bc, 1536	; F4CB17  ld BC,0x0600
	ld	xhl, 6304768	; F4CB1A  ld XHL,0x00603400
	ld	xde, 6356992	; F4CB1F  ld XDE,0x00610000
	mul	wa, 3072	; F4CB24  mul WA,0x0c00
	lda	xde, (xde+wa)	; F4CB28  lda XDE,XDE+WA
	ldirw93	; F4CB2D  ldirw
	pop	xde	; F4CB2F  pop XDE
	pop	xhl	; F4CB30  pop XHL
	pop	xbc	; F4CB31  pop XBC
	pop	xwa	; F4CB32  pop XWA
	ret	; F4CB33  ret

; --------------------------------------------------------------------------
; BStore_Workspace_CopyFromBank
; Called from: in-module: 0xF4CA51 0xF4CAC7
; Touches: (0x360A)  |  0x603400 0x610000
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4CB34 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_Workspace_CopyFromBank: Inverse of BStore_Workspace_CopyToBank: bank copy 0x610000 + BStore_CurrentBank *
;   0xC00 back into the workspace 0x603400 (0x600 words), registers saved, without BStore_Workspace_LoadFromBank's
;   (0x360C) / free-list restore. SeqFile_PrepareSaveAllBanks and SysExDump_PrepareSequencerData run it after
;   BStore_CompactBlocks with (0x603452), BStore_FreeHead and BStore_FreeCount pushed around it. Basis: callers + body
;   + twin. (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
BStore_Workspace_CopyFromBank:
	push	xwa	; F4CB34  push XWA
	push	xbc	; F4CB35  push XBC
	push	xhl	; F4CB36  push XHL
	push	xde	; F4CB37  push XDE
	xor	wa, wa	; F4CB38  xor WA,WA
	ld	a, (BStore_CurrentBank:16)	; F4CB3A  ld A,(0x360a)
	ldw	bc, 1536	; F4CB3E  ld BC,0x0600
	ld	xde, 6304768	; F4CB41  ld XDE,0x00603400
	ld	xhl, 6356992	; F4CB46  ld XHL,0x00610000
	mul	wa, 3072	; F4CB4B  mul WA,0x0c00
	lda	xhl, (xhl+wa)	; F4CB4F  lda XHL,XHL+WA
	ldirw93	; F4CB54  ldirw
	pop	xde	; F4CB56  pop XDE
	pop	xhl	; F4CB57  pop XHL
	pop	xbc	; F4CB58  pop XBC
	pop	xwa	; F4CB59  pop XWA
	ret	; F4CB5A  ret
	.fill	1189, 1, 0x0E	; F4CB5B-F4CFFF  `ret` padding (asserted pure 0x0E)
