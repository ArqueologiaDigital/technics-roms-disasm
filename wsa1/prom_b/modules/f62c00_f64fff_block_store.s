

; ==============================================================================
; 0xF62C00-0xF64FFF -- THE BLOCK STORE
;   a chained 256-byte record heap, its 3-byte directory, and the banked 3 KiB
;   workspace that both live in
; ==============================================================================
;
; WHY THIS BLOCK.  notes/prom_b_call_graph.py ranks unconverted prom_b thunk
; targets by an opcode-anchored reference upper bound.  The top two in the whole
; image are BOTH in this module -- T_BStore_CursorAdvance -> 0xF635C9 (x43) and
; T_BStore_SeekBlock -> 0xF63BAE (x42) -- and 49 thunk slots, the contiguous run
; 0xF42770-0xF42830, point into it.  None of it was converted before.
;
; EXTENT.  0xF62C00-0xF64C0F is code and data; 0xF64C10-0xF64FFF is 1008 bytes
; of 0x0E (`ret`) padding to the 4 KiB boundary, where the next module starts.
; The module is preceded by 2,347 bytes of the same padding (0xF622D5-0xF62BFF).
;
; WHAT IT MANAGES -- three objects, all established from the bytes:
;
;  1. A HEAP OF 256-BYTE BLOCKS based at (0x3604), (0x3608) of them.
;         +0        flags; bit 7 set = allocated
;         +1..+2    PREVIOUS block number, 16-bit
;         +3..+4    NEXT block number, 16-bit; 0xFFFF terminates the chain
;         +5..+0xFF payload, 251 bytes
;     The 5 is not a guess: BStore_AllocChain computes the capacity as
;     `ld HL,0x0100 / sub HL,0x0005` (0xF639B8) and BStore_CursorAdvance
;     restarts the offset at exactly 5 when it steps into a new block.
;     (0x3604) = 0x00617800 -- forced by the INVERSE arithmetic that two other
;     prom_b modules spell with a literal (0xF5E2F0, 0xF61F1C); see the header
;     on BStore_SeekBlock.
;
;  2. A DIRECTORY of 3-byte entries at 0x00603500.
;         +0        flags; bit 7 set = entry in use
;         +1..+2    head block number, 16-bit; 0xFFFF = empty
;     Read off BStore_OpenChain, which is the only routine here that touches it.
;
;  3. A 3 KiB WORKSPACE at 0x00603400-0x00603FFF, banked into
;     0x00610000 + n*0xC00 with n = (0x360A).
;     notes/FINDINGS-memory-map.md already recorded 0x603400-0x603FFF as the one
;     3 KiB hole prom_a's two boot clear loops deliberately skip.  This module is
;     what the hole is for.  prom_a bounds n to 0..9 (0xF8143F `cp A,0` on the
;     way down, 0xF814D2 `cp A,0x09` on the way up), so there are TEN banks --
;     and 0x610000 + 10*0xC00 = 0x617800, the heap base.  The two regions abut
;     with no slack.  That is consistency between two independently derived
;     constants, not proof that they were laid out together.
;     Fields of the workspace this module names: +0x1E (a copy of (0x360C)),
;     +0x22 (16 bytes, values 0x00-0x1F with 0x20 meaning empty), +0x7E (16-bit
;     saved cursor block numbers), +0xA0 (saved cursor byte offsets), +0xB8,
;     +0xBA (the free-block count), +0xC6, +0xD4, +0xD7.
;     ADDED 2026-08-25: the +0x7E / +0xA0 pair has SEVENTEEN entries, and so does
;     the directory at 0x00603500 -- read off the `ld BC,0x0011` loops of
;     BStore_FreeList_Init (0xF7A428), converted below.  That closes this
;     module's "how many directory entries" gap and corrects
;     FINDINGS-memory-map.md, which said 16 saved cursors.
;     Check: python3 notes/prom_b_songstore_checks.py --arrays
;
; THE CURSOR is the pair ((0x126E) = block address, IY = byte offset), with
; (0x345C) carrying the block number.  BStore_CursorAdvance is the only thing
; that moves it across a block boundary.
;
; THE PAYLOAD IS A TAGGED BYTE STREAM.  The tag values this module compares
; against, with the number of comparison sites for each (census emitted by the
; generator, not typed):
;     0x80 x1   0x81 x9   0x82 x11   0x84 x6   0x85 x2   0x86 x2   0x87 x2
; 0x82 and 0x84 are what BStore_ValidateSavedCursor requires a saved cursor to
; be pointing at.
; ⚠ What the tags MEAN is not established.  0x81 is counted (a delimiter of
; something) and 0x82 stops a forward walk with error 8; that is all the bytes
; say.
;
; ERROR CODES, in (0x0D4A).  The table below is the complete census of
; `ld (0x0D4A),imm` in this module: every code, how many sites write it, and
; where.  It is emitted by the generator from the proven transcription, so the
; counts cannot drift from the bytes.
;
;     0x00  35 sites: 0xF62CFE 0xF62DC9 0xF6306A 0xF6349F 0xF63679 0xF63731 ...
;           cleared on entry to a routine -- no error
;     0x01   2 sites: 0xF638C1 0xF638DE
;           directory entry number is 0 (0xF638C1), or its bit 7 is clear
;           (0xF638DE)
;     0x02   1 site : 0xF638F9
;           the directory head block number is 0xFFFF -- the chain is empty
;     0x05   4 sites: 0xF639F1 0xF63A2F 0xF64655 0xF647C4
;           more blocks needed than (0x6034BA) reports free (0xF639F1), or the
;           allocator at thunk T_BStore_AllocBlock_Veneer returned failure (0xF63A2F).  The two
;           further sites are not read
;     0x06   1 site : 0xF6350A
;           the tag byte at the cursor is 0x84 (`cp (XHL+IY),0x84` at
;           0xF63502)
;     0x07   1 site : 0xF63587
;           the tag byte at the cursor is 0x82 (`cp (XHL+IY),0x82` at
;           0xF6357F)
;     0x08   2 sites: 0xF62DA0 0xF635DE
;           tag 0x82 reached while walking forward (0xF62D9B).  The second
;           site, 0xF635DE, is UNREACHABLE -- see the header on
;           BStore_CursorAdvance
;     0x0A   7 sites: 0xF62CC7 0xF63351 0xF633C2 0xF634E1 0xF6352C 0xF635EB ...
;           block number greater than (0x0CA4), the block count
;     0x0B  13 sites: 0xF62CAB 0xF62CDF 0xF62CF8 0xF6301E 0xF63055 0xF632CD ...
;           the block's bit 7 is clear, or the tag at the cursor is not one of
;           the values the caller expected
; ⚠ These are the values this module WRITES.  Nothing here shows that no other
; module writes (0x0D4A), and BStore_ErrorToStatusByte indexes a 72-entry table
; with it, which would allow codes up to 0x47.
;
; ⚠ WHAT THIS MODULE IS FOR is NOT established.  The obvious reading -- that a
; directory of chained byte streams with delimiter tags, in the one RAM region
; that survives a warm restart, is the sequencer's song memory -- is a reading.
; What supports it is only circumstantial: (0x126E), the cursor, sits in the same
; 0x12xx page as (0x12F6) and (0x12FC), which interpreter-B display-list records
; draw on the screen whose interpreter-A text reads "SEQUENCER PLAY", "S0NG",
; "CYCLE:", "MEASURE = " and "TIME SIG.= "
; (`python3 notes/prom_b_var_screens.py --var 0x12F6`).  Adjacency in a RAM page
; is not evidence about a routine, so the names below say "BStore", not "Song".
;
; REPRODUCE THIS WHOLE BLOCK:
;     python3 notes/gen_prom_b_blockstore_module.py
; Its code runs come from notes/llvm_roundtrip_autoforce.py, which proves the
; listing rebuilds the range byte for byte before printing it; its three data
; islands are the runs notes/prom_b_module_trace.py never reaches by following
; control flow from the module's own entry points; and every caller list and
; every count in a header below is computed by the generator, not typed.
; ==============================================================================

; --------------------------------------------------------------------------
; BStore_Veneers -- three long-branch veneers
;
; Called from:
;   thunk slots T_BStore_Veneers
;   (both lists are emitted by this script, not typed)
; Evidence: three unconditional branches and nothing else -- `jr T,0xF62C66`,
;   `jrl T,0xF64A7A`, `jrl T,0xF64A9F`.
; Unknown: why the module needs veneers at all when the thunk table could
;   name the three targets directly.
; --------------------------------------------------------------------------
BStore_Veneers:		; <- T_BStore_Veneers
	jr	BStore_LoadGeometry_Call_Join2	; F62C00  jr T,0xf62c66
sub_F62C02:
	jrl	sub_F64A7A	; F62C02  jrl T,0xf64a7a
; SongGmFlag_OnEventPassB_Veneer: Veneer (`jrl` to 0xF64A9F, still the local label sub_F64A34_Join) for
;   UiListB_Class91[3]: a user change of record 0x91 byte 3 bit 2, the GM-mode bit (0x7F4D), stops the sequencer
;   (T_F40A20), sets (0x34D4) bit 4 and stores it as the song's GM flag (0x6034C6) = 0xFF / 0; skipped once when
;   (0x124C) bit 0 marks the change as the song's own (Seq_ApplyLoadedSongSetup). Basis: table index + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
SongGmFlag_OnEventPassB_Veneer:		; <- T_SongGmFlag_OnEventPassB_Veneer
	jrl	sub_F64A34_Join	; F62C05  jrl T,0xf64a9f

; --------------------------------------------------------------------------
; BStore_StubTable -- 28 `calr <routine> / ret` entry stubs
;
; Called from:
;   thunk slots T_BStore_StubTable
;   (both lists are emitted by this script, not typed)
; Layout, counted by this script from the transcription's own instruction
;   boundaries: 26 stubs of 4 bytes, 1 stub of 5 bytes, 1 stub of 9 bytes.
;   The table runs 0xF62C08-0xF62C7D, 118 bytes, and abuts
;   BStore_ValidateSavedCursor at 0xF62C7E.
;   It is NOT a fixed stride, and anything that assumes one walks off the
;   table -- notes/prom_b_module_trace.py did exactly that.  The two odd
;   ones, with the size this script MEASURED for each:
;     0xF62C28 is 9 bytes -- it also does `ld (0x0E02),0x00`
;     0xF62C31 is 5 bytes -- it also does `push WA`
; Entry points: 7 of the 28 stubs have their own thunk slot and 0 are
;   called from inside the module; the remaining 21 are entered from
;   outside by address.
; Evidence: every `calr` target in the table is also an entry point that
;   something else reaches.
; --------------------------------------------------------------------------
BStore_StubTable:		; <- T_BStore_StubTable
	calr	BStore_SeekMeasure	; F62C08  calr 0xf62cfe
	ret	; F62C0B  ret
; BStore_CopyRangeForward_Call: BStore_StubTable slot `calr sub_F62DC9 / ret` behind T_BStore_CopyRangeForward_Call. sub_F62DC9 is
;   BStore_CopyRangeBackward's forward twin: LDIR from (0x0C61)/(0x0C67) through the end (block DE, offset (0x0C6B))
;   to (0x0C57)/(0x0C5D), following +3 NEXT links, error 11 on a free block. SongEdit_DeleteMeasuresFromTrack and
;   MeasureErase_EraseTrack use it (via T_F42778) to move the chain down over a gap. Basis: table slot + target body +
;   twin + target's callers. (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
BStore_CopyRangeForward_Call:		; <- T_BStore_CopyRangeForward_Call
	calr	sub_F62DC9	; F62C0C  calr 0xf62dc9
	ret	; F62C0F  ret
; BStore_CopyRangeBackward_Call: BStore_StubTable slot `calr BStore_CopyRangeBackward / ret` behind T_BStore_CopyRangeBackward_Call. BStore_CopyRangeBackward copies the
;   chain bytes from the cursor (block DE, offset (0x0C6B)) up to the source end (block (0x0C61), offset (0x0C67)) so
;   they end at the destination end ((0x0C57)/(0x0C5D)), back to front with LDDR, following the blocks' +1 back links.
;   BStore_AppendBytes and StepRecord_BStoreAppendBytes use it to open the gap the new bytes are then copied into.
;   Basis: callers + body (target read). (notes/naming-pilot-2026-10-06/proposals_wave4_n.json)
BStore_CopyRangeBackward_Call:		; <- T_BStore_CopyRangeBackward_Call
	calr	BStore_CopyRangeBackward	; F62C10  calr 0xf6306a
	ret	; F62C13  ret
; BStore_LoadStartBeatsPerBar: T_BStore_LoadStartBeatsPerBar entry: BStore_TimeSigFirstMeasure -- (0x0D1C) := the song's beats per bar (0x6034D7); when
;   (0x0C8A) bit 2 (a master track was found) it opens chain (0x0D1D) and takes the value from its leading tag-0x87
;   records (next byte + 1) up to the first 0x81 beat mark. BStore_CursorBlock is preserved. Callers then count
;   (0x0D1C) beat marks per measure. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave3_h.json)
BStore_LoadStartBeatsPerBar:		; <- T_BStore_LoadStartBeatsPerBar
	calr	BStore_TimeSigFirstMeasure	; F62C14  calr 0xf6364d
	ret	; F62C17  ret
; BStore_TimeSigNextMeasure_Call: `calr sub_F63749 / ret` (BStore_StubTable slot behind T_BStore_TimeSigNextMeasure_Call). sub_F63749 steps
;   the time-signature cursor (0x0CF0)/(0x0CF4) one measure (past (0x0D1C) 0x81 beat marks), so (0x0D1C) = the beats
;   per bar of the measure entered (a 0x87 record there sets it). Run once per measure by BStore_SeekChainToMeasure,
;   BStore_ClearTrack and Seq_BeatsToMeasureAndBeat after counting a measure's beats. Basis: callers + body (target read). (notes/naming-
;   pilot-2026-10-06/proposals_wave3_i.json)
BStore_TimeSigNextMeasure_Call:		; <- T_BStore_TimeSigNextMeasure_Call
	calr	sub_F63749	; F62C18  calr 0xf63749
	ret	; F62C1B  ret
BStore_OpenChain_Call:		; <- T_BStore_OpenChain_Call
	calr	BStore_OpenChain	; F62C1C  calr 0xf638bb
	ret	; F62C1F  ret
; BStore_LoadGeometry_Call: calls BStore_LoadGeometry and returns (notes/prom_ab_wrapper_names.py; DERIVATIVE)
BStore_LoadGeometry_Call:		; <- T_BStore_LoadGeometry_Call
	calr	BStore_LoadGeometry	; F62C20  calr 0xf63be5
	ret	; F62C23  ret
	calr	BStore_CursorAdvance	; F62C24  calr 0xf635c9
	ret	; F62C27  ret
	calr	SongEdit_ResetJobFields	; F62C28  calr 0xf63a59
	ld	(3586:16), 0	; F62C2B  ld (0x0e02),0x00
	ret	; F62C30  ret
	calr	BStore_ValidateSavedCursor	; F62C31  calr 0xf62c7e
	pushw	wa	; F62C34  push WA
	ret	; F62C35  ret
	calr	BStore_MovePosForward	; F62C36  calr 0xf63317
	ret	; F62C39  ret
	calr	BStore_MovePosBackward	; F62C3A  calr 0xf63383
	ret	; F62C3D  ret
	calr	BStore_ReadBlockByteAtIX	; F62C3E  calr 0xf633f5
	ret	; F62C41  ret
	calr	BStore_ErrorToStatusByte	; F62C42  calr 0xf6342c
	ret	; F62C45  ret
	calr	BStore_OpenChainAtSavedCursor	; F62C46  calr 0xf63489
	ret	; F62C49  ret
	calr	BStore_TruncateChainAfterBlock	; F62C4A  calr 0xf63510
	ret	; F62C4D  ret
	calr	sub_F6353E	; F62C4E  calr 0xf6353e
	ret	; F62C51  ret
	calr	Seq_FindMasterTrack	; F62C52  calr 0xf6360e
	ret	; F62C55  ret
	calr	BStore_SaveCursor	; F62C56  calr 0xf63924
	ret	; F62C59  ret
	calr	BStore_AllocChain	; F62C5A  calr 0xf63988
	ret	; F62C5D  ret
	calr	BStore_CopyAcrossBlocks	; F62C5E  calr 0xf63bc0
	ret	; F62C61  ret
	calr	sub_F63C02	; F62C62  calr 0xf63c02
	ret	; F62C65  ret
BStore_LoadGeometry_Call_Join2:
	calr	BStore_ApplyTrackPartChange	; F62C66  calr 0xf63c41
	ret	; F62C69  ret
	calr	SongEdit_CheckAllTracksToStartMeasure	; F62C6A  calr 0xf6452b
	ret	; F62C6D  ret
	calr	SongEdit_CheckFreeBlocksForInsert	; F62C6E  calr 0xf64594
	ret	; F62C71  ret
	calr	SongEdit_CheckFreeBlocksForCopy	; F62C72  calr 0xf6466e
	ret	; F62C75  ret
	calr	BStore_BlocksNeededToGrow	; F62C76  calr 0xf647dd
	ret	; F62C79  ret
	calr	BStore_BlocksFreedByShrink	; F62C7A  calr 0xf64838
	ret	; F62C7D  ret

; --------------------------------------------------------------------------
; BStore_ValidateSavedCursor -- is entry n's saved cursor still valid?
;
; Called from:
;   thunk slots T_BStore_ValidateSavedCursor
;   4 call sites inside the module:
;     0xF62C31 0xF6453C 0xF645B1 0xF64695
;   (both lists are emitted by this script, not typed)
; Inputs:  A = entry number, 1-based.
; Outputs: (0x0D4A) = 0 on success, else an error code; on success
;   (0x345C) = the cursor's block number and (0x126E) = that block's address.
; What it does: L = A-1; C = the byte at 0x006034A0[L]; requires 5 <= C <= 0xFF;
;   WA = the 16-bit word at 0x0060347E[L*2]; requires WA <= (0x0CA4) (the block
;   count); seeks that block; requires its bit 7 set; requires the payload byte
;   at offset C to be tag 0x82 or 0x84.
; Evidence: 0xF62C96 `ld XDE,0x006034A0`, 0xF62CB6 `ld XDE,0x0060347E`,
;   0xF62CA1 `cp BC,5`, 0xF62CC1 `cp WA,(0x0CA4)`, 0xF62CDB `bit 7,(XHL)`,
;   0xF62CE8/0xF62CF0 `cp (XHL+IY),0x82` / `0x84`.  The pair (word at +0x7E,
;   byte at +0xA0) is a CURSOR because BStore_SaveCursor writes exactly that
;   pair from the live block number and offset.
; Unknown: 5 as the lower bound on C is the 5-byte block header, but the
;   UPPER bound is odd: BC was cleared with `xor BC,BC` before the byte was
;   loaded into C, so `cp BC,0x00FF` can never fail.  Dead as written.
; --------------------------------------------------------------------------
BStore_ValidateSavedCursor:		; <- T_BStore_ValidateSavedCursor
	pushw	wa	; F62C7E  push WA
	calr	BStore_OpenChain	; F62C7F  calr 0xf638bb
	popw	wa	; F62C82  pop WA
	cp	(BStore_ErrorCode:16), 0x00	; F62C83  cp (0x0d4a),0x00
	jr	z, BStore_ValidateSavedCursor_Skip	; F62C88  jr Z,0xf62c8d
	jrl	BStore_ValidateSavedCursor_Return	; F62C8A  jrl T,0xf62cfd
BStore_ValidateSavedCursor_Skip:
	xor	hl, hl	; F62C8D  xor HL,HL
	dec	1, a	; F62C8F  dec 1,A
	ld	l, a	; F62C91  ld L,A
	xor	bc, bc	; F62C93  xor BC,BC
	push	xde	; F62C95  push XDE
	ld	xde, 6304928	; F62C96  ld XDE,0x006034a0
	ld	c, (xde+hl)	; F62C9B  ld C,(XDE+HL)
	pop	xde	; F62CA0  pop XDE
	cp	bc, 5:i3	; F62CA1  cp BC,5
	jr	c, BStore_ValidateSavedCursor_Skip2	; F62CA3  jr C,0xf62cab
	cp	bc, 255	; F62CA5  cp BC,0x00ff
	jr	ule, BStore_ValidateSavedCursor_Skip3	; F62CA9  jr ULE,0xf62cb2
BStore_ValidateSavedCursor_Skip2:
	ld	(BStore_ErrorCode:16), 11	; F62CAB  ld (0x0d4a),0x0b
	jr	BStore_ValidateSavedCursor_Return	; F62CB0  jr T,0xf62cfd
BStore_ValidateSavedCursor_Skip3:
	sla	hl, 1	; F62CB2  sla 0x01,HL
	push	xde	; F62CB5  push XDE
	ld	xde, 6304894	; F62CB6  ld XDE,0x0060347e
	ld	wa, (xde+hl)	; F62CBB  ld WA,(XDE+HL)
	pop	xde	; F62CC0  pop XDE
	cp	wa, (BStore_BlockLimit:16)	; F62CC1  cp WA,(0x0ca4)
	jr	ule, BStore_ValidateSavedCursor_Skip4	; F62CC5  jr ULE,0xf62cce
	ld	(BStore_ErrorCode:16), 10	; F62CC7  ld (0x0d4a),0x0a
	jr	BStore_ValidateSavedCursor_Return	; F62CCC  jr T,0xf62cfd
BStore_ValidateSavedCursor_Skip4:
	ld	(BStore_CursorBlock:16), wa	; F62CCE  ld (0x345c),WA
	ld	hl, wa	; F62CD2  ld HL,WA
	calr	BStore_SeekBlock	; F62CD4  calr 0xf63bae
	ld	xhl, (BStore_CursorBlockAddr:16)	; F62CD7  ld XHL,(0x126e)
	bit	7, (xhl)	; F62CDB  bit 7,(XHL)
	jr	nz, BStore_ValidateSavedCursor_Skip5	; F62CDD  jr NZ,0xf62ce6
	ld	(BStore_ErrorCode:16), 11	; F62CDF  ld (0x0d4a),0x0b
	jr	BStore_ValidateSavedCursor_Return	; F62CE4  jr T,0xf62cfd
BStore_ValidateSavedCursor_Skip5:
	ld	iy, bc	; F62CE6  ld IY,BC
	cp	(xhl+iy), 0x82	; F62CE8  cp (XHL+IY),0x82
	jr	z, BStore_ValidateSavedCursor_Return	; F62CEE  jr Z,0xf62cfd
	cp	(xhl+iy), 0x84	; F62CF0  cp (XHL+IY),0x84
	jr	z, BStore_ValidateSavedCursor_Return	; F62CF6  jr Z,0xf62cfd
	ld	(BStore_ErrorCode:16), 11	; F62CF8  ld (0x0d4a),0x0b
BStore_ValidateSavedCursor_Return:
	ret	; F62CFD  ret
; BStore_SeekMeasure: Opens chain W ((0x0D1D)) and walks its cursor to the start of measure (0x0C90): beats per bar
;   (0x0D1C) from the chain head (BStore_TimeSigFirstMeasure: song default (0x6034D7), tag-0x87 records), then per measure passes
;   (0x0D1C) tag-0x81 beat markers (BStore_CountMarkersForward, count in (0x0DC8)) and re-reads time-sig records
;   (sub_F63749); returns A = (0x0D1C), DE = measure, (0x0D4A) = error. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_d.json)
BStore_SeekMeasure:		; <- T_BStore_SeekMeasure
	ld	(BStore_ErrorCode:16), 0	; F62CFE  ld (0x0d4a),0x00
	ld	(3357:16), w	; F62D03  ld (0x0d1d),W
	calr	BStore_OpenChain	; F62D07  calr 0xf638bb
	cp	(BStore_ErrorCode:16), 0x00	; F62D0A  cp (0x0d4a),0x00
	jr	z, BStore_SeekMeasure_Skip	; F62D0F  jr Z,0xf62d14
	jrl	BStore_SeekMeasure_Return	; F62D11  jrl T,0xf62d8b
BStore_SeekMeasure_Skip:
	ldw	iy, 5	; F62D14  ld IY,0x0005
	push	xiz	; F62D17  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F62D18  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F62D1C  ld XDE3,XIZ
	pop	xiz	; F62D1F  pop XIZ
	push_lerp	0x38	; F62D20  push XDE3
	push	xhl	; F62D23  push XHL
	push	xiy	; F62D24  push XIY
	calr	BStore_TimeSigFirstMeasure	; F62D25  calr 0xf6364d
	pop	xiy	; F62D28  pop XIY
	pop	xhl	; F62D29  pop XHL
	pop_lerp	0x38	; F62D2A  pop XDE3
	push	xiz	; F62D2D  push XIZ
	ldto_lerp	xiz, 0x38	; F62D2E  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F62D31  ld (0x126e),XIZ
	pop	xiz	; F62D35  pop XIZ
	xor	de, de	; F62D36  xor DE,DE
	inc	1, de	; F62D38  inc 1,DE
	xor	xix, xix	; F62D3A  xor XIX,XIX
BStore_SeekMeasure_Join:
	cp	de, (0x0c90:16)	; F62D3C  cp DE,(0x0c90)
	jr	nz, BStore_SeekMeasure_Skip2	; F62D40  jr NZ,0xf62d48
	ld	a, (3356:16)	; F62D42  ld A,(0x0d1c)
	jr	BStore_SeekMeasure_Return	; F62D46  jr T,0xf62d8b
BStore_SeekMeasure_Skip2:
	ld	b, (3356:16)	; F62D48  ld B,(0x0d1c)
	call	BStore_CountMarkersForward	; F62D4C  call 0xf62d8c
	cp	(BStore_ErrorCode:16), 0x00	; F62D50  cp (0x0d4a),0x00
	jr	z, BStore_SeekMeasure_Skip3	; F62D55  jr Z,0xf62d59
	jr	BStore_SeekMeasure_Return	; F62D57  jr T,0xf62d8b
BStore_SeekMeasure_Skip3:
	ld	(3528:16), ix	; F62D59  ld (0x0dc8),IX
	inc	1, de	; F62D5D  inc 1,DE
	push	xiz	; F62D5F  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F62D60  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F62D64  ld XDE3,XIZ
	pop	xiz	; F62D67  pop XIZ
	push_lerp	0x38	; F62D68  push XDE3
	push	xhl	; F62D6B  push XHL
	pushw	de	; F62D6C  push DE
	push	xiy	; F62D6D  push XIY
	push	xix	; F62D6E  push XIX
	calr	sub_F63749	; F62D6F  calr 0xf63749
	pop	xix	; F62D72  pop XIX
	pop	xiy	; F62D73  pop XIY
	popw	de	; F62D74  pop DE
	pop	xhl	; F62D75  pop XHL
	pop_lerp	0x38	; F62D76  pop XDE3
	push	xiz	; F62D79  push XIZ
	ldto_lerp	xiz, 0x38	; F62D7A  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F62D7D  ld (0x126e),XIZ
	pop	xiz	; F62D81  pop XIZ
	cp	(BStore_ErrorCode:16), 0x00	; F62D82  cp (0x0d4a),0x00
	jr	nz, BStore_SeekMeasure_Return	; F62D87  jr NZ,0xf62d8b
	jr	BStore_SeekMeasure_Join	; F62D89  jr T,0xf62d3c
BStore_SeekMeasure_Return:
	ret	; F62D8B  ret

; --------------------------------------------------------------------------
; BStore_CountMarkersForward -- walk forward over B tag-0x81 markers
;
; Called from:
;   1 call site inside the module:
;     0xF62D4C
;   (both lists are emitted by this script, not typed)
; Inputs:  B = how many 0x81 markers to pass, IY = the byte offset in the
;   current block, (0x126E) = the current block.
; Outputs: IX += C (the markers actually passed); (0x0D4A) = 8 if tag 0x82 was
;   found first.
; Evidence: 0xF62D9B `cp A,0x82` -> `ld (0x0D4A),0x08`, 0xF62DA7 `cp A,0x81`
;   -> `inc 1,C`; both arms call BStore_CursorAdvance.
; Unknown: what a 0x81 marker delimits.
; --------------------------------------------------------------------------
BStore_CountMarkersForward:
	xor	c, c	; F62D8C  xor C,C
BStore_CountMarkersForward_Loop:
	cp	c, b	; F62D8E  cp C,B
	jr	z, BStore_CountMarkersForward_Join	; F62D90  jr Z,0xf62dc4
BStore_CountMarkersForward_Loop2:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F62D92  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F62D96  ld A,(XHL+IY)
	cp	a, 130	; F62D9B  cp A,0x82
	jr	nz, BStore_CountMarkersForward_Skip	; F62D9E  jr NZ,0xf62da7
	ld	(BStore_ErrorCode:16), 8	; F62DA0  ld (0x0d4a),0x08
	jr	BStore_CountMarkersForward_Join	; F62DA5  jr T,0xf62dc4
BStore_CountMarkersForward_Skip:
	cp	a, 129	; F62DA7  cp A,0x81
	jr	z, BStore_CountMarkersForward_Skip2	; F62DAA  jr Z,0xf62db8
	calr	BStore_CursorAdvance	; F62DAC  calr 0xf635c9
	cp	(BStore_ErrorCode:16), 0x00	; F62DAF  cp (0x0d4a),0x00
	jr	z, BStore_CountMarkersForward_Loop2	; F62DB4  jr Z,0xf62d92
	jr	BStore_CountMarkersForward_Join	; F62DB6  jr T,0xf62dc4
BStore_CountMarkersForward_Skip2:
	inc	1, c	; F62DB8  inc 1,C
	calr	BStore_CursorAdvance	; F62DBA  calr 0xf635c9
	cp	(BStore_ErrorCode:16), 0x00	; F62DBD  cp (0x0d4a),0x00
	jr	z, BStore_CountMarkersForward_Loop	; F62DC2  jr Z,0xf62d8e
BStore_CountMarkersForward_Join:
	xor	b, b	; F62DC4  xor B,B
	add	ix, bc	; F62DC6  add IX,BC
	ret	; F62DC8  ret
sub_F62DC9:		; <- T_F42778
	ld	(BStore_ErrorCode:16), 0	; F62DC9  ld (0x0d4a),0x00
	ld	hl, (3169:16)	; F62DCE  ld HL,(0x0c61)
	calr	BStore_SeekBlock	; F62DD2  calr 0xf63bae
	push	xwa	; F62DD5  push XWA
	ld	xwa, (BStore_CursorBlockAddr:16)	; F62DD6  ld XWA,(0x126e)
	ld	(BStore_CopySrcAddr:16), xwa	; F62DDA  ld (0x0c63),XWA
	ld	hl, (3159:16)	; F62DDE  ld HL,(0x0c57)
	calr	BStore_SeekBlock	; F62DE2  calr 0xf63bae
	ld	xwa, (BStore_CursorBlockAddr:16)	; F62DE5  ld XWA,(0x126e)
	ld	(BStore_CopyDestAddr:16), xwa	; F62DE9  ld (0x0c59),XWA
	pop	xwa	; F62DED  pop XWA
	cp	de, (0x0c61:16)	; F62DEE  cp DE,(0x0c61)
	jr	nz, sub_F62DC9_Skip	; F62DF2  jr NZ,0xf62e15
	ldw	iy, 256	; F62DF4  ld IY,0x0100
	sub	iy, (0x0c67:16)	; F62DF7  sub IY,(0x0c67)
	ld	(3226:16), iy	; F62DFB  ld (0x0c9a),IY
	ld	iy, (3175:16)	; F62DFF  ld IY,(0x0c67)
	ldw	ix, 256	; F62E03  ld IX,0x0100
	sub	ix, (0x0c5d:16)	; F62E06  sub IX,(0x0c5d)
	ld	(3228:16), ix	; F62E0A  ld (0x0c9c),IX
	ld	ix, (3165:16)	; F62E0E  ld IX,(0x0c5d)
	jrl	sub_F62DC9_Join7	; F62E12  jrl T,0xf62fbc
sub_F62DC9_Skip:
	ld	wa, (3165:16)	; F62E15  ld WA,(0x0c5d)
	cp	wa, (0x0c67:16)	; F62E19  cp WA,(0x0c67)
	jr	c, sub_F62DC9_Skip2	; F62E1D  jr C,0xf62e23
	jr	z, sub_F62DC9_Skip3	; F62E1F  jr Z,0xf62e25
	jr	ugt, sub_F62DC9_Skip4	; F62E21  jr UGT,0xf62e28
sub_F62DC9_Skip2:
	jr	sub_F62DC9_Join	; F62E23  jr T,0xf62e2b
sub_F62DC9_Skip3:
	jrl	sub_F62DC9_Join3	; F62E25  jrl T,0xf62eb4
sub_F62DC9_Skip4:
	jrl	sub_F62DC9_Join5	; F62E28  jrl T,0xf62f22
sub_F62DC9_Join:
	ldw	wa, 256	; F62E2B  ld WA,0x0100
	sub	wa, (0x0c5d:16)	; F62E2E  sub WA,(0x0c5d)
	ldw	bc, 256	; F62E32  ld BC,0x0100
	sub	bc, (0x0c67:16)	; F62E35  sub BC,(0x0c67)
	sub	wa, bc	; F62E39  sub WA,BC
	ld	(3222:16), wa	; F62E3B  ld (0x0c96),WA
	ldw	bc, 256	; F62E3F  ld BC,0x0100
	sub	bc, 5	; F62E42  sub BC,0x0005
	sub	bc, wa	; F62E46  sub BC,WA
	ld	(3224:16), bc	; F62E48  ld (0x0c98),BC
	ld	iy, (3175:16)	; F62E4C  ld IY,(0x0c67)
	ld	ix, (3165:16)	; F62E50  ld IX,(0x0c5d)
	ldw	bc, 256	; F62E54  ld BC,0x0100
	sub	bc, (0x0c67:16)	; F62E57  sub BC,(0x0c67)
	calr	BStore_CopyAcrossBlocks	; F62E5B  calr 0xf63bc0
	call	CycleRecord_StepCopySrcToNextBlock_Copy	; F62E5E  call 0xf63031
	cp	(BStore_ErrorCode:16), 0x00	; F62E62  cp (0x0d4a),0x00
	jr	z, sub_F62DC9_Loop	; F62E67  jr Z,0xf62e6c
	jrl	sub_F62DC9_Return	; F62E69  jrl T,0xf62ff9
sub_F62DC9_Loop:
	cp	de, (0x0c61:16)	; F62E6C  cp DE,(0x0c61)
	jr	nz, sub_F62DC9_Skip5	; F62E70  jr NZ,0xf62e74
	jr	sub_F62DC9_Join2	; F62E72  jr T,0xf62e9e
sub_F62DC9_Skip5:
	ld	bc, (3222:16)	; F62E74  ld BC,(0x0c96)
	calr	BStore_CopyAcrossBlocks	; F62E78  calr 0xf63bc0
	call	sub_F62FFA	; F62E7B  call 0xf62ffa
	cp	(BStore_ErrorCode:16), 0x00	; F62E7F  cp (0x0d4a),0x00
	jr	z, sub_F62DC9_Skip6	; F62E84  jr Z,0xf62e89
	jrl	sub_F62DC9_Return	; F62E86  jrl T,0xf62ff9
sub_F62DC9_Skip6:
	ld	bc, (3224:16)	; F62E89  ld BC,(0x0c98)
	calr	BStore_CopyAcrossBlocks	; F62E8D  calr 0xf63bc0
	call	CycleRecord_StepCopySrcToNextBlock_Copy	; F62E90  call 0xf63031
	cp	(BStore_ErrorCode:16), 0x00	; F62E94  cp (0x0d4a),0x00
	jr	z, sub_F62DC9_Loop	; F62E99  jr Z,0xf62e6c
	jrl	sub_F62DC9_Return	; F62E9B  jrl T,0xf62ff9
sub_F62DC9_Join2:
	ld	wa, (3222:16)	; F62E9E  ld WA,(0x0c96)
	ld	(3228:16), wa	; F62EA2  ld (0x0c9c),WA
	ldw	bc, 256	; F62EA6  ld BC,0x0100
	sub	bc, 5	; F62EA9  sub BC,0x0005
	ld	(3226:16), bc	; F62EAD  ld (0x0c9a),BC
	jrl	sub_F62DC9_Join7	; F62EB1  jrl T,0xf62fbc
sub_F62DC9_Join3:
	ldw	bc, 256	; F62EB4  ld BC,0x0100
	sub	bc, (0x0c67:16)	; F62EB7  sub BC,(0x0c67)
	ld	iy, (3175:16)	; F62EBB  ld IY,(0x0c67)
	ld	ix, (3165:16)	; F62EBF  ld IX,(0x0c5d)
	calr	BStore_CopyAcrossBlocks	; F62EC3  calr 0xf63bc0
	call	CycleRecord_StepCopySrcToNextBlock_Copy	; F62EC6  call 0xf63031
	cp	(BStore_ErrorCode:16), 0x00	; F62ECA  cp (0x0d4a),0x00
	jr	z, sub_F62DC9_Skip7	; F62ECF  jr Z,0xf62ed4
	jrl	sub_F62DC9_Return	; F62ED1  jrl T,0xf62ff9
sub_F62DC9_Skip7:
	call	sub_F62FFA	; F62ED4  call 0xf62ffa
	cp	(BStore_ErrorCode:16), 0x00	; F62ED8  cp (0x0d4a),0x00
	jr	z, sub_F62DC9_Loop2	; F62EDD  jr Z,0xf62ee2
	jrl	sub_F62DC9_Return	; F62EDF  jrl T,0xf62ff9
sub_F62DC9_Loop2:
	cp	de, (0x0c61:16)	; F62EE2  cp DE,(0x0c61)
	jr	nz, sub_F62DC9_Skip8	; F62EE6  jr NZ,0xf62eea
	jr	sub_F62DC9_Join4	; F62EE8  jr T,0xf62f10
sub_F62DC9_Skip8:
	ldw	bc, 256	; F62EEA  ld BC,0x0100
	sub	bc, 5	; F62EED  sub BC,0x0005
	calr	BStore_CopyAcrossBlocks	; F62EF1  calr 0xf63bc0
	call	CycleRecord_StepCopySrcToNextBlock_Copy	; F62EF4  call 0xf63031
	cp	(BStore_ErrorCode:16), 0x00	; F62EF8  cp (0x0d4a),0x00
	jr	z, sub_F62DC9_Skip9	; F62EFD  jr Z,0xf62f02
	jrl	sub_F62DC9_Return	; F62EFF  jrl T,0xf62ff9
sub_F62DC9_Skip9:
	call	sub_F62FFA	; F62F02  call 0xf62ffa
	cp	(BStore_ErrorCode:16), 0x00	; F62F06  cp (0x0d4a),0x00
	jr	z, sub_F62DC9_Loop2	; F62F0B  jr Z,0xf62ee2
	jrl	sub_F62DC9_Return	; F62F0D  jrl T,0xf62ff9
sub_F62DC9_Join4:
	ldw	bc, 256	; F62F10  ld BC,0x0100
	sub	bc, 5	; F62F13  sub BC,0x0005
	ld	(3228:16), bc	; F62F17  ld (0x0c9c),BC
	ld	(3226:16), bc	; F62F1B  ld (0x0c9a),BC
	jrl	sub_F62DC9_Join7	; F62F1F  jrl T,0xf62fbc
sub_F62DC9_Join5:
	ldw	wa, 256	; F62F22  ld WA,0x0100
	sub	wa, (0x0c67:16)	; F62F25  sub WA,(0x0c67)
	ldw	bc, 256	; F62F29  ld BC,0x0100
	sub	bc, (0x0c5d:16)	; F62F2C  sub BC,(0x0c5d)
	sub	wa, bc	; F62F30  sub WA,BC
	ld	(3222:16), wa	; F62F32  ld (0x0c96),WA
	ldw	bc, 256	; F62F36  ld BC,0x0100
	sub	bc, 5	; F62F39  sub BC,0x0005
	sub	bc, wa	; F62F3D  sub BC,WA
	ld	(3224:16), bc	; F62F3F  ld (0x0c98),BC
	ld	iy, (3175:16)	; F62F43  ld IY,(0x0c67)
	ld	ix, (3165:16)	; F62F47  ld IX,(0x0c5d)
	ldw	bc, 256	; F62F4B  ld BC,0x0100
	sub	bc, (0x0c5d:16)	; F62F4E  sub BC,(0x0c5d)
	calr	BStore_CopyAcrossBlocks	; F62F52  calr 0xf63bc0
	call	sub_F62FFA	; F62F55  call 0xf62ffa
	cp	(BStore_ErrorCode:16), 0x00	; F62F59  cp (0x0d4a),0x00
	jr	z, sub_F62DC9_Skip10	; F62F5E  jr Z,0xf62f63
	jrl	sub_F62DC9_Return	; F62F60  jrl T,0xf62ff9
sub_F62DC9_Skip10:
	ld	bc, (3222:16)	; F62F63  ld BC,(0x0c96)
	calr	BStore_CopyAcrossBlocks	; F62F67  calr 0xf63bc0
	call	CycleRecord_StepCopySrcToNextBlock_Copy	; F62F6A  call 0xf63031
	cp	(BStore_ErrorCode:16), 0x00	; F62F6E  cp (0x0d4a),0x00
	jr	z, sub_F62DC9_Loop3	; F62F73  jr Z,0xf62f78
	jrl	sub_F62DC9_Return	; F62F75  jrl T,0xf62ff9
sub_F62DC9_Loop3:
	cp	de, (0x0c61:16)	; F62F78  cp DE,(0x0c61)
	jr	nz, sub_F62DC9_Skip11	; F62F7C  jr NZ,0xf62f80
	jr	sub_F62DC9_Join6	; F62F7E  jr T,0xf62fa9
sub_F62DC9_Skip11:
	ld	bc, (3224:16)	; F62F80  ld BC,(0x0c98)
	calr	BStore_CopyAcrossBlocks	; F62F84  calr 0xf63bc0
	call	sub_F62FFA	; F62F87  call 0xf62ffa
	cp	(BStore_ErrorCode:16), 0x00	; F62F8B  cp (0x0d4a),0x00
	jr	z, sub_F62DC9_Skip12	; F62F90  jr Z,0xf62f95
	jrl	sub_F62DC9_Return	; F62F92  jrl T,0xf62ff9
sub_F62DC9_Skip12:
	ld	bc, (3222:16)	; F62F95  ld BC,(0x0c96)
	calr	BStore_CopyAcrossBlocks	; F62F99  calr 0xf63bc0
	call	CycleRecord_StepCopySrcToNextBlock_Copy	; F62F9C  call 0xf63031
	cp	(BStore_ErrorCode:16), 0x00	; F62FA0  cp (0x0d4a),0x00
	jr	z, sub_F62DC9_Loop3	; F62FA5  jr Z,0xf62f78
	jr	sub_F62DC9_Return	; F62FA7  jr T,0xf62ff9
sub_F62DC9_Join6:
	ld	wa, (3224:16)	; F62FA9  ld WA,(0x0c98)
	ld	(3228:16), wa	; F62FAD  ld (0x0c9c),WA
	ldw	wa, 256	; F62FB1  ld WA,0x0100
	sub	wa, 5	; F62FB4  sub WA,0x0005
	ld	(3226:16), wa	; F62FB8  ld (0x0c9a),WA
sub_F62DC9_Join7:
	ldw	wa, 255	; F62FBC  ld WA,0x00ff
	sub	wa, (0x0c6b:16)	; F62FBF  sub WA,(0x0c6b)
	ld	bc, (3226:16)	; F62FC3  ld BC,(0x0c9a)
	sub	bc, wa	; F62FC7  sub BC,WA
	ld	(3232:16), bc	; F62FC9  ld (0x0ca0),BC
	cp	(0x0c9c:16), bc	; F62FCD  cp (0x0c9c),BC
	jr	nc, sub_F62DC9_Skip13	; F62FD1  jr NC,0xf62fd5
	jr	sub_F62DC9_Join8	; F62FD3  jr T,0xf62fda
sub_F62DC9_Skip13:
	calr	BStore_CopyAcrossBlocks	; F62FD5  calr 0xf63bc0
	jr	sub_F62DC9_Return	; F62FD8  jr T,0xf62ff9
sub_F62DC9_Join8:
	ld	bc, (3228:16)	; F62FDA  ld BC,(0x0c9c)
	calr	BStore_CopyAcrossBlocks	; F62FDE  calr 0xf63bc0
	call	sub_F62FFA	; F62FE1  call 0xf62ffa
	cp	(BStore_ErrorCode:16), 0x00	; F62FE5  cp (0x0d4a),0x00
	jr	z, sub_F62DC9_Skip14	; F62FEA  jr Z,0xf62fee
	jr	sub_F62DC9_Return	; F62FEC  jr T,0xf62ff9
sub_F62DC9_Skip14:
	ld	bc, (3232:16)	; F62FEE  ld BC,(0x0ca0)
	sub	bc, (0x0c9c:16)	; F62FF2  sub BC,(0x0c9c)
	calr	BStore_CopyAcrossBlocks	; F62FF6  calr 0xf63bc0
sub_F62DC9_Return:
	ret	; F62FF9  ret
sub_F62FFA:
	xor	xix, xix	; F62FFA  xor XIX,XIX
	ld	xix, (BStore_CopyDestAddr:16)	; F62FFC  ld XIX,(0x0c59)
	ld	(BStore_CursorBlockAddr:16), xix	; F63000  ld (0x126e),XIX
	ld	wa, (xix+3)	; F63004  ld WA,(XIX+0x03)
	ld	(3159:16), wa	; F63007  ld (0x0c57),WA
	extz	xwa	; F6300B  extz XWA
	dec	1, xwa	; F6300D  dec 1,XWA
	sla	xwa, 8	; F6300F  sla 0x08,XWA
	add	xwa, (BStore_HeapBase:16)	; F63012  add XWA,(0x3604)
	ld	(BStore_CursorBlockAddr:16), xwa	; F63016  ld (0x126e),XWA
	bit	7, (xwa)	; F6301A  bit 7,(XWA)
	jr	nz, sub_F62FFA_Skip	; F6301C  jr NZ,0xf63025
	ld	(BStore_ErrorCode:16), 11	; F6301E  ld (0x0d4a),0x0b
	jr	sub_F62FFA_Return	; F63023  jr T,0xf63030
sub_F62FFA_Skip:
	ld	xwa, (BStore_CursorBlockAddr:16)	; F63025  ld XWA,(0x126e)
	ld	(BStore_CopyDestAddr:16), xwa	; F63029  ld (0x0c59),XWA
	ldw	ix, 5	; F6302D  ld IX,0x0005
sub_F62FFA_Return:
	ret	; F63030  ret
; CycleRecord_StepCopySrcToNextBlock_Copy: an exact copy of CycleRecord_StepCopySrcToNextBlock (prom_b 0xF4B726) -- all 20 instructions equal, operands included,
;   but the targets of its jr / jrl / djnz (notes/wsa1_exact_copy_names.py).
CycleRecord_StepCopySrcToNextBlock_Copy:
	xor	iy, iy	; F63031  xor IY,IY
	ld	xiy, (BStore_CopySrcAddr:16)	; F63033  ld XIY,(0x0c63)
	ld	(BStore_GeomBase:16), xiy	; F63037  ld (0x0ca6),XIY
	ld	wa, (xiy+3)	; F6303B  ld WA,(XIY+0x03)
	ld	(3169:16), wa	; F6303E  ld (0x0c61),WA
	extz	xwa	; F63042  extz XWA
	dec	1, xwa	; F63044  dec 1,XWA
	sla	xwa, 8	; F63046  sla 0x08,XWA
	add	xwa, (BStore_HeapBase:16)	; F63049  add XWA,(0x3604)
	ld	(BStore_CursorBlockAddr:16), xwa	; F6304D  ld (0x126e),XWA
	bit	7, (xwa)	; F63051  bit 7,(XWA)
	jr	nz, CycleRecord_StepCopySrcToNextBlock_Copy_Skip	; F63053  jr NZ,0xf6305c
	ld	(BStore_ErrorCode:16), 11	; F63055  ld (0x0d4a),0x0b
	jr	CycleRecord_StepCopySrcToNextBlock_Copy_Return	; F6305A  jr T,0xf63069
CycleRecord_StepCopySrcToNextBlock_Copy_Skip:
	push	xwa	; F6305C  push XWA
	ld	xwa, (BStore_CursorBlockAddr:16)	; F6305D  ld XWA,(0x126e)
	ld	(BStore_CopySrcAddr:16), xwa	; F63061  ld (0x0c63),XWA
	pop	xwa	; F63065  pop XWA
	ldw	iy, 5	; F63066  ld IY,0x0005
CycleRecord_StepCopySrcToNextBlock_Copy_Return:
	ret	; F63069  ret
; BStore_CopyRangeBackward: Copies the chain bytes from the cursor (block DE, offset (0x0C6B)) up to the source end
;   (block (0x0C61), offset (0x0C67)) so they end at the destination end ((0x0C57)/(0x0C5D)), back to front with LDDR,
;   following the blocks' +1 back links (error 11 on a free block). Opens a gap ahead of inserted bytes. Basis:
;   callers + body (as BStore_CopyRangeBackward_Call's header says). (notes/naming-
;   pilot-2026-10-06/proposals_wave5_q.json)
BStore_CopyRangeBackward:		; <- T_BStore_CopyRangeBackward
	ld	(BStore_ErrorCode:16), 0	; F6306A  ld (0x0d4a),0x00
	ld	hl, (3169:16)	; F6306F  ld HL,(0x0c61)
	calr	BStore_SeekBlock	; F63073  calr 0xf63bae
	ld	xwa, (BStore_CursorBlockAddr:16)	; F63076  ld XWA,(0x126e)
	ld	(BStore_CopySrcAddr:16), xwa	; F6307A  ld (0x0c63),XWA
	ld	hl, (3159:16)	; F6307E  ld HL,(0x0c57)
	calr	BStore_SeekBlock	; F63082  calr 0xf63bae
	ld	xwa, (BStore_CursorBlockAddr:16)	; F63085  ld XWA,(0x126e)
	ld	(BStore_CopyDestAddr:16), xwa	; F63089  ld (0x0c59),XWA
	cp	de, (0x0c61:16)	; F6308D  cp DE,(0x0c61)
	jr	nz, BStore_CopyRangeBackward_Skip	; F63091  jr NZ,0xf630ba
	ld	iy, (3175:16)	; F63093  ld IY,(0x0c67)
	sub	iy, 5	; F63097  sub IY,0x0005
	inc	1, iy	; F6309B  inc 1,IY
	ld	(3226:16), iy	; F6309D  ld (0x0c9a),IY
	ld	iy, (3175:16)	; F630A1  ld IY,(0x0c67)
	ld	ix, (3165:16)	; F630A5  ld IX,(0x0c5d)
	sub	ix, 5	; F630A9  sub IX,0x0005
	inc	1, ix	; F630AD  inc 1,IX
	ld	(3228:16), ix	; F630AF  ld (0x0c9c),IX
	ld	ix, (3165:16)	; F630B3  ld IX,(0x0c5d)
	jrl	BStore_CopyRangeBackward_Join5	; F630B7  jrl T,0xf63243
BStore_CopyRangeBackward_Skip:
	ld	wa, (3165:16)	; F630BA  ld WA,(0x0c5d)
	cp	wa, (0x0c67:16)	; F630BE  cp WA,(0x0c67)
	jr	ugt, BStore_CopyRangeBackward_Skip2	; F630C2  jr UGT,0xf630c8
	jr	z, BStore_CopyRangeBackward_Skip3	; F630C4  jr Z,0xf630ca
	jr	BStore_CopyRangeBackward_Join	; F630C6  jr T,0xf630cd
BStore_CopyRangeBackward_Skip2:
	jr	BStore_CopyRangeBackward_Join2	; F630C8  jr T,0xf630d0
BStore_CopyRangeBackward_Skip3:
	jrl	BStore_CopyRangeBackward_Join3	; F630CA  jrl T,0xf6314b
BStore_CopyRangeBackward_Join:
	jrl	BStore_CopyRangeBackward_Join4	; F630CD  jrl T,0xf631b5
BStore_CopyRangeBackward_Join2:
	sub	wa, (0x0c67:16)	; F630D0  sub WA,(0x0c67)
	ld	(3222:16), wa	; F630D4  ld (0x0c96),WA
	ldw	bc, 256	; F630D8  ld BC,0x0100
	sub	bc, 5	; F630DB  sub BC,0x0005
	sub	bc, wa	; F630DF  sub BC,WA
	ld	(3224:16), bc	; F630E1  ld (0x0c98),BC
	ld	iy, (3175:16)	; F630E5  ld IY,(0x0c67)
	ld	ix, (3165:16)	; F630E9  ld IX,(0x0c5d)
	ld	bc, (3175:16)	; F630ED  ld BC,(0x0c67)
	sub	bc, 5	; F630F1  sub BC,0x0005
	inc	1, bc	; F630F5  inc 1,BC
	calr	BStore_CopyAcrossBlocksBackward	; F630F7  calr 0xf63280
	call	BStore_CopySrcToPrevBlock	; F630FA  call 0xf632a9
	cp	(BStore_ErrorCode:16), 0x00	; F630FE  cp (0x0d4a),0x00
	jrl	nz, BStore_CopyRangeBackward_Return	; F63103  jrl NZ,0xf6327f
BStore_CopyRangeBackward_Loop:
	cp	de, (0x0c61:16)	; F63106  cp DE,(0x0c61)
	jrl	z, BStore_CopyRangeBackward_Skip4	; F6310A  jrl Z,0xf63135
	ld	bc, (3222:16)	; F6310D  ld BC,(0x0c96)
	calr	BStore_CopyAcrossBlocksBackward	; F63111  calr 0xf63280
	call	BStore_CopyDestToPrevBlock	; F63114  call 0xf632e0
	cp	(BStore_ErrorCode:16), 0x00	; F63118  cp (0x0d4a),0x00
	jrl	nz, BStore_CopyRangeBackward_Return	; F6311D  jrl NZ,0xf6327f
	ld	bc, (3224:16)	; F63120  ld BC,(0x0c98)
	calr	BStore_CopyAcrossBlocksBackward	; F63124  calr 0xf63280
	call	BStore_CopySrcToPrevBlock	; F63127  call 0xf632a9
	cp	(BStore_ErrorCode:16), 0x00	; F6312B  cp (0x0d4a),0x00
	jr	z, BStore_CopyRangeBackward_Loop	; F63130  jr Z,0xf63106
	jrl	BStore_CopyRangeBackward_Return	; F63132  jrl T,0xf6327f
BStore_CopyRangeBackward_Skip4:
	ld	wa, (3222:16)	; F63135  ld WA,(0x0c96)
	ld	(3228:16), wa	; F63139  ld (0x0c9c),WA
	ldw	bc, 256	; F6313D  ld BC,0x0100
	sub	bc, 5	; F63140  sub BC,0x0005
	ld	(3226:16), bc	; F63144  ld (0x0c9a),BC
	jrl	BStore_CopyRangeBackward_Join5	; F63148  jrl T,0xf63243
BStore_CopyRangeBackward_Join3:
	ld	bc, (3175:16)	; F6314B  ld BC,(0x0c67)
	sub	bc, 5	; F6314F  sub BC,0x0005
	inc	1, bc	; F63153  inc 1,BC
	ld	iy, (3175:16)	; F63155  ld IY,(0x0c67)
	ld	ix, (3165:16)	; F63159  ld IX,(0x0c5d)
	calr	BStore_CopyAcrossBlocksBackward	; F6315D  calr 0xf63280
	call	BStore_CopyDestToPrevBlock	; F63160  call 0xf632e0
	cp	(BStore_ErrorCode:16), 0x00	; F63164  cp (0x0d4a),0x00
	jrl	nz, BStore_CopyRangeBackward_Return	; F63169  jrl NZ,0xf6327f
	call	BStore_CopySrcToPrevBlock	; F6316C  call 0xf632a9
	cp	(BStore_ErrorCode:16), 0x00	; F63170  cp (0x0d4a),0x00
	jrl	nz, BStore_CopyRangeBackward_Return	; F63175  jrl NZ,0xf6327f
BStore_CopyRangeBackward_Loop2:
	cp	de, (0x0c61:16)	; F63178  cp DE,(0x0c61)
	jrl	z, BStore_CopyRangeBackward_Skip5	; F6317C  jrl Z,0xf631a3
	ldw	bc, 256	; F6317F  ld BC,0x0100
	sub	bc, 5	; F63182  sub BC,0x0005
	calr	BStore_CopyAcrossBlocksBackward	; F63186  calr 0xf63280
	call	BStore_CopyDestToPrevBlock	; F63189  call 0xf632e0
	cp	(BStore_ErrorCode:16), 0x00	; F6318D  cp (0x0d4a),0x00
	jrl	nz, BStore_CopyRangeBackward_Return	; F63192  jrl NZ,0xf6327f
	call	BStore_CopySrcToPrevBlock	; F63195  call 0xf632a9
	cp	(BStore_ErrorCode:16), 0x00	; F63199  cp (0x0d4a),0x00
	jr	z, BStore_CopyRangeBackward_Loop2	; F6319E  jr Z,0xf63178
	jrl	BStore_CopyRangeBackward_Return	; F631A0  jrl T,0xf6327f
BStore_CopyRangeBackward_Skip5:
	ldw	bc, 256	; F631A3  ld BC,0x0100
	sub	bc, 5	; F631A6  sub BC,0x0005
	ld	(3228:16), bc	; F631AA  ld (0x0c9c),BC
	ld	(3226:16), bc	; F631AE  ld (0x0c9a),BC
	jrl	BStore_CopyRangeBackward_Join5	; F631B2  jrl T,0xf63243
BStore_CopyRangeBackward_Join4:
	ld	wa, (3175:16)	; F631B5  ld WA,(0x0c67)
	sub	wa, (0x0c5d:16)	; F631B9  sub WA,(0x0c5d)
	ld	(3222:16), wa	; F631BD  ld (0x0c96),WA
	ldw	bc, 256	; F631C1  ld BC,0x0100
	sub	bc, 5	; F631C4  sub BC,0x0005
	sub	bc, wa	; F631C8  sub BC,WA
	ld	(3224:16), bc	; F631CA  ld (0x0c98),BC
	ld	iy, (3175:16)	; F631CE  ld IY,(0x0c67)
	ld	ix, (3165:16)	; F631D2  ld IX,(0x0c5d)
	ld	bc, (3165:16)	; F631D6  ld BC,(0x0c5d)
	sub	bc, 5	; F631DA  sub BC,0x0005
	inc	1, bc	; F631DE  inc 1,BC
	calr	BStore_CopyAcrossBlocksBackward	; F631E0  calr 0xf63280
	call	BStore_CopyDestToPrevBlock	; F631E3  call 0xf632e0
	cp	(BStore_ErrorCode:16), 0x00	; F631E7  cp (0x0d4a),0x00
	jrl	nz, BStore_CopyRangeBackward_Return	; F631EC  jrl NZ,0xf6327f
	ld	bc, (3222:16)	; F631EF  ld BC,(0x0c96)
	calr	BStore_CopyAcrossBlocksBackward	; F631F3  calr 0xf63280
	call	BStore_CopySrcToPrevBlock	; F631F6  call 0xf632a9
	cp	(BStore_ErrorCode:16), 0x00	; F631FA  cp (0x0d4a),0x00
	jrl	nz, BStore_CopyRangeBackward_Return	; F631FF  jrl NZ,0xf6327f
BStore_CopyRangeBackward_Loop3:
	cp	de, (0x0c61:16)	; F63202  cp DE,(0x0c61)
	jrl	z, BStore_CopyRangeBackward_Skip6	; F63206  jrl Z,0xf63230
	ld	bc, (3224:16)	; F63209  ld BC,(0x0c98)
	calr	BStore_CopyAcrossBlocksBackward	; F6320D  calr 0xf63280
	call	BStore_CopyDestToPrevBlock	; F63210  call 0xf632e0
	cp	(BStore_ErrorCode:16), 0x00	; F63214  cp (0x0d4a),0x00
	jrl	nz, BStore_CopyRangeBackward_Return	; F63219  jrl NZ,0xf6327f
	ld	bc, (3222:16)	; F6321C  ld BC,(0x0c96)
	calr	BStore_CopyAcrossBlocksBackward	; F63220  calr 0xf63280
	call	BStore_CopySrcToPrevBlock	; F63223  call 0xf632a9
	cp	(BStore_ErrorCode:16), 0x00	; F63227  cp (0x0d4a),0x00
	jr	z, BStore_CopyRangeBackward_Loop3	; F6322C  jr Z,0xf63202
	jr	BStore_CopyRangeBackward_Return	; F6322E  jr T,0xf6327f
BStore_CopyRangeBackward_Skip6:
	ld	wa, (3224:16)	; F63230  ld WA,(0x0c98)
	ld	(3228:16), wa	; F63234  ld (0x0c9c),WA
	ldw	wa, 256	; F63238  ld WA,0x0100
	sub	wa, 5	; F6323B  sub WA,0x0005
	ld	(3226:16), wa	; F6323F  ld (0x0c9a),WA
BStore_CopyRangeBackward_Join5:
	ld	wa, (3179:16)	; F63243  ld WA,(0x0c6b)
	sub	wa, 5	; F63247  sub WA,0x0005
	ld	bc, (3226:16)	; F6324B  ld BC,(0x0c9a)
	sub	bc, wa	; F6324F  sub BC,WA
	ld	(3232:16), bc	; F63251  ld (0x0ca0),BC
	cp	(0x0c9c:16), bc	; F63255  cp (0x0c9c),BC
	jr	nc, BStore_CopyRangeBackward_Skip7	; F63259  jr NC,0xf6325d
	jr	BStore_CopyRangeBackward_Join6	; F6325B  jr T,0xf63262
BStore_CopyRangeBackward_Skip7:
	calr	BStore_CopyAcrossBlocksBackward	; F6325D  calr 0xf63280
	jr	BStore_CopyRangeBackward_Return	; F63260  jr T,0xf6327f
BStore_CopyRangeBackward_Join6:
	ld	bc, (3228:16)	; F63262  ld BC,(0x0c9c)
	calr	BStore_CopyAcrossBlocksBackward	; F63266  calr 0xf63280
	call	BStore_CopyDestToPrevBlock	; F63269  call 0xf632e0
	cp	(BStore_ErrorCode:16), 0x00	; F6326D  cp (0x0d4a),0x00
	jr	nz, BStore_CopyRangeBackward_Return	; F63272  jr NZ,0xf6327f
	ld	bc, (3232:16)	; F63274  ld BC,(0x0ca0)
	sub	bc, (0x0c9c:16)	; F63278  sub BC,(0x0c9c)
	calr	BStore_CopyAcrossBlocksBackward	; F6327C  calr 0xf63280
BStore_CopyRangeBackward_Return:
	ret	; F6327F  ret
; BStore_CopyAcrossBlocksBackward: LDDR twin of BStore_CopyAcrossBlocks: copies BC bytes downward from source block
;   (0x0C63) + IY to destination block (0x0C59) + IX, then IY / IX := the offsets just below the copied runs; nothing
;   when BC = 0. BStore_CopyRangeBackward's per-segment copy (12 call sites). Basis: caller + caller header + body +
;   twin. (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
BStore_CopyAcrossBlocksBackward:
	pushw	wa	; F63280  push WA
	push	xde	; F63281  push XDE
	push	xhl	; F63282  push XHL
	cp	bc, 0:i3	; F63283  cp BC,0
	jr	z, BStore_CopyAcrossBlocksBackward_Epilogue	; F63285  jr Z,0xf632a5
	ld	xhl, (BStore_CopySrcAddr:16)	; F63287  ld XHL,(0x0c63)
	ld	xde, (BStore_CopyDestAddr:16)	; F6328B  ld XDE,(0x0c59)
	extz	xiy	; F6328F  extz XIY
	extz	xix	; F63291  extz XIX
	add	xhl, xiy	; F63293  add XHL,XIY
	add	xde, xix	; F63295  add XDE,XIX
	.byte 0x83, 0x13	; F63297  lddr   [llvm-mc cannot encode this]
	sub	xhl, (BStore_CopySrcAddr:16)	; F63299  sub XHL,(0x0c63)
	sub	xde, (BStore_CopyDestAddr:16)	; F6329D  sub XDE,(0x0c59)
	ld	iy, hl	; F632A1  ld IY,HL
	ld	ix, de	; F632A3  ld IX,DE
BStore_CopyAcrossBlocksBackward_Epilogue:
	pop	xhl	; F632A5  pop XHL
	pop	xde	; F632A6  pop XDE
	popw	wa	; F632A7  pop WA
	ret	; F632A8  ret
; BStore_CopySrcToPrevBlock: Steps BStore_CopyRangeBackward's source to the previous block: (0x0C61) := the +1
;   PREVIOUS link of block (0x0C63), (0x0C63) := its address (0x617800-based via BStore_HeapBase), IY = 0xFF (its last
;   byte); error 11 when that block is not allocated. Twin of BStore_CopyDestToPrevBlock. Basis: caller + caller
;   header + body. (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
BStore_CopySrcToPrevBlock:
	xor	iy, iy	; F632A9  xor IY,IY
	ld	xiy, (BStore_CopySrcAddr:16)	; F632AB  ld XIY,(0x0c63)
	ld	(BStore_CursorBlockAddr:16), xiy	; F632AF  ld (0x126e),XIY
	ld	wa, (xiy+1)	; F632B3  ld WA,(XIY+0x01)
	ld	(3169:16), wa	; F632B6  ld (0x0c61),WA
	extz	xwa	; F632BA  extz XWA
	dec	1, xwa	; F632BC  dec 1,XWA
	sla	xwa, 8	; F632BE  sla 0x08,XWA
	add	xwa, (BStore_HeapBase:16)	; F632C1  add XWA,(0x3604)
	ld	(BStore_CursorBlockAddr:16), xwa	; F632C5  ld (0x126e),XWA
	bit	7, (xwa)	; F632C9  bit 7,(XWA)
	jr	nz, BStore_CopySrcToPrevBlock_Skip	; F632CB  jr NZ,0xf632d4
	ld	(BStore_ErrorCode:16), 11	; F632CD  ld (0x0d4a),0x0b
	jr	BStore_CopySrcToPrevBlock_Return	; F632D2  jr T,0xf632df
BStore_CopySrcToPrevBlock_Skip:
	ld	xwa, (BStore_CursorBlockAddr:16)	; F632D4  ld XWA,(0x126e)
	ld	(BStore_CopySrcAddr:16), xwa	; F632D8  ld (0x0c63),XWA
	ldw	iy, 255	; F632DC  ld IY,0x00ff
BStore_CopySrcToPrevBlock_Return:
	ret	; F632DF  ret
; BStore_CopyDestToPrevBlock: Steps BStore_CopyRangeBackward's destination to the previous block: (0x0C57) := the +1
;   PREVIOUS link of block (0x0C59), (0x0C59) := its address, IX = 0xFF; error 11 when that block is not allocated.
;   Twin of BStore_CopySrcToPrevBlock. Basis: caller + caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_t.json)
BStore_CopyDestToPrevBlock:
	xor	ix, ix	; F632E0  xor IX,IX
	ld	xix, (BStore_CopyDestAddr:16)	; F632E2  ld XIX,(0x0c59)
	ld	(BStore_CursorBlockAddr:16), xix	; F632E6  ld (0x126e),XIX
	ld	wa, (xix+1)	; F632EA  ld WA,(XIX+0x01)
	ld	(3159:16), wa	; F632ED  ld (0x0c57),WA
	extz	xwa	; F632F1  extz XWA
	dec	1, xwa	; F632F3  dec 1,XWA
	sla	xwa, 8	; F632F5  sla 0x08,XWA
	add	xwa, (BStore_HeapBase:16)	; F632F8  add XWA,(0x3604)
	ld	(BStore_CursorBlockAddr:16), xwa	; F632FC  ld (0x126e),XWA
	bit	7, (xwa)	; F63300  bit 7,(XWA)
	jr	nz, BStore_CopyDestToPrevBlock_Skip	; F63302  jr NZ,0xf6330b
	ld	(BStore_ErrorCode:16), 11	; F63304  ld (0x0d4a),0x0b
	jr	BStore_CopyDestToPrevBlock_Return	; F63309  jr T,0xf63316
BStore_CopyDestToPrevBlock_Skip:
	ld	xwa, (BStore_CursorBlockAddr:16)	; F6330B  ld XWA,(0x126e)
	ld	(BStore_CopyDestAddr:16), xwa	; F6330F  ld (0x0c59),XWA
	ldw	ix, 255	; F63313  ld IX,0x00ff
BStore_CopyDestToPrevBlock_Return:
	ret	; F63316  ret
; BStore_MovePosForward: Moves the chain position (block (0x0CE8), offset (0x0CEA)) forward by BStore_AllocBytesWanted
;   bytes, following +3 next links (251 payload bytes per block, resuming at offset 5); error 10 past
;   BStore_BlockLimit, 11 on a free block. MeasureInsert_InsertWithinTrack / SongEdit_CopyMeasuresWithinTrack use it
;   to re-base a source position after the range ahead of it grew. Basis: callers (named in this batch) + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
BStore_MovePosForward:		; <- T_BStore_MovePosForward
	ldw	wa, 256	; F63317  ld WA,0x0100
	sub	wa, (0x0cea:16)	; F6331A  sub WA,(0x0cea)
	cp	wa, (BStore_AllocBytesWanted:16)	; F6331E  cp WA,(0x0cae)
	jr	ugt, BStore_MovePosForward_Skip	; F63322  jr UGT,0xf63326
	jr	BStore_MovePosForward_Join	; F63324  jr T,0xf63330
BStore_MovePosForward_Skip:
	ld	wa, (BStore_AllocBytesWanted:16)	; F63326  ld WA,(0x0cae)
	add	(0x0cea:16), wa	; F6332A  add (0x0cea),WA
	jr	BStore_MovePosForward_Return	; F6332E  jr T,0xf63382
BStore_MovePosForward_Join:
	ld	de, (BStore_AllocBytesWanted:16)	; F63330  ld DE,(0x0cae)
	sub	de, wa	; F63334  sub DE,WA
	ldw	wa, 256	; F63336  ld WA,0x0100
	sub	wa, 5	; F63339  sub WA,0x0005
	ld	hl, (3304:16)	; F6333D  ld HL,(0x0ce8)
	calr	BStore_SeekBlock	; F63341  calr 0xf63bae
BStore_MovePosForward_Join2:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F63344  ld XHL,(0x126e)
	ld	bc, (xhl+3)	; F63348  ld BC,(XHL+0x03)
	cp	bc, (BStore_BlockLimit:16)	; F6334B  cp BC,(0x0ca4)
	jr	ule, BStore_MovePosForward_Skip2	; F6334F  jr ULE,0xf63358
	ld	(BStore_ErrorCode:16), 10	; F63351  ld (0x0d4a),0x0a
	jr	BStore_MovePosForward_Return	; F63356  jr T,0xf63382
BStore_MovePosForward_Skip2:
	ld	(3304:16), bc	; F63358  ld (0x0ce8),BC
	ld	hl, bc	; F6335C  ld HL,BC
	calr	BStore_SeekBlock	; F6335E  calr 0xf63bae
	ld	xhl, (BStore_CursorBlockAddr:16)	; F63361  ld XHL,(0x126e)
	bit	7, (xhl)	; F63365  bit 7,(XHL)
	jr	nz, BStore_MovePosForward_Skip3	; F63367  jr NZ,0xf63370
	ld	(BStore_ErrorCode:16), 11	; F63369  ld (0x0d4a),0x0b
	jr	BStore_MovePosForward_Return	; F6336E  jr T,0xf63382
BStore_MovePosForward_Skip3:
	cp	de, wa	; F63370  cp DE,WA
	jr	ugt, BStore_MovePosForward_Skip4	; F63372  jr UGT,0xf63376
	jr	BStore_MovePosForward_Join3	; F63374  jr T,0xf6337a
BStore_MovePosForward_Skip4:
	sub	de, wa	; F63376  sub DE,WA
	jr	BStore_MovePosForward_Join2	; F63378  jr T,0xf63344
BStore_MovePosForward_Join3:
	add	de, 5	; F6337A  add DE,0x0005
	ld	(3306:16), de	; F6337E  ld (0x0cea),DE
BStore_MovePosForward_Return:
	ret	; F63382  ret
; BStore_MovePosBackward: Moves the chain position (block (0x0CE8), offset (0x0CEA)) back by BStore_AllocBytesWanted
;   bytes, following +1 previous links (continuing at offset 255); error 10 past BStore_BlockLimit, 11 on a free
;   block. The reverse of BStore_MovePosForward; SongEdit_CopyMeasuresToTrack / _WithinTrack use it when a destination
;   range shrinks. Basis: callers (named in this batch) + body. (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
BStore_MovePosBackward:		; <- T_BStore_MovePosBackward
	ld	wa, (3306:16)	; F63383  ld WA,(0x0cea)
	sub	wa, 4	; F63387  sub WA,0x0004
	cp	wa, (BStore_AllocBytesWanted:16)	; F6338B  cp WA,(0x0cae)
	jr	ugt, BStore_MovePosBackward_Skip	; F6338F  jr UGT,0xf63393
	jr	BStore_MovePosBackward_Join	; F63391  jr T,0xf633a1
BStore_MovePosBackward_Skip:
	sub	wa, (BStore_AllocBytesWanted:16)	; F63393  sub WA,(0x0cae)
	add	wa, 4	; F63397  add WA,0x0004
	ld	(3306:16), wa	; F6339B  ld (0x0cea),WA
	jr	BStore_MovePosBackward_Return	; F6339F  jr T,0xf633f4
BStore_MovePosBackward_Join:
	ld	de, (BStore_AllocBytesWanted:16)	; F633A1  ld DE,(0x0cae)
	sub	de, wa	; F633A5  sub DE,WA
	ldw	wa, 256	; F633A7  ld WA,0x0100
	sub	wa, 5	; F633AA  sub WA,0x0005
	ld	hl, (3304:16)	; F633AE  ld HL,(0x0ce8)
	calr	BStore_SeekBlock	; F633B2  calr 0xf63bae
BStore_MovePosBackward_Join2:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F633B5  ld XHL,(0x126e)
	ld	bc, (xhl+1)	; F633B9  ld BC,(XHL+0x01)
	cp	bc, (BStore_BlockLimit:16)	; F633BC  cp BC,(0x0ca4)
	jr	ule, BStore_MovePosBackward_Skip2	; F633C0  jr ULE,0xf633c9
	ld	(BStore_ErrorCode:16), 10	; F633C2  ld (0x0d4a),0x0a
	jr	BStore_MovePosBackward_Return	; F633C7  jr T,0xf633f4
BStore_MovePosBackward_Skip2:
	ld	(3304:16), bc	; F633C9  ld (0x0ce8),BC
	ld	hl, bc	; F633CD  ld HL,BC
	calr	BStore_SeekBlock	; F633CF  calr 0xf63bae
	ld	xhl, (BStore_CursorBlockAddr:16)	; F633D2  ld XHL,(0x126e)
	bit	7, (xhl)	; F633D6  bit 7,(XHL)
	jr	nz, BStore_MovePosBackward_Skip3	; F633D8  jr NZ,0xf633e1
	ld	(BStore_ErrorCode:16), 11	; F633DA  ld (0x0d4a),0x0b
	jr	BStore_MovePosBackward_Return	; F633DF  jr T,0xf633f4
BStore_MovePosBackward_Skip3:
	cp	de, wa	; F633E1  cp DE,WA
	jr	ugt, BStore_MovePosBackward_Skip4	; F633E3  jr UGT,0xf633e7
	jr	BStore_MovePosBackward_Join3	; F633E5  jr T,0xf633eb
BStore_MovePosBackward_Skip4:
	sub	de, wa	; F633E7  sub DE,WA
	jr	BStore_MovePosBackward_Join2	; F633E9  jr T,0xf633b5
BStore_MovePosBackward_Join3:
	ldw	wa, 255	; F633EB  ld WA,0x00ff
	sub	wa, de	; F633EE  sub WA,DE
	ld	(3306:16), wa	; F633F0  ld (0x0cea),WA
BStore_MovePosBackward_Return:
	ret	; F633F4  ret
; BStore_ReadBlockByteAtIX: A = (BStore_CursorBlockAddr)[IX].
BStore_ReadBlockByteAtIX:		; <- T_BStore_ReadBlockByteAtIX
	ld	xhl, (BStore_CursorBlockAddr:16)	; F633F5  ld XHL,(0x126e)
	ld	a, (xhl+ix)	; F633F9  ld A,(XHL+IX)
	ret	; F633FE  ret
BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_12:		; <- T_BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_12
	ld	xiy, BStore_ErrorStatusTable + 0xC	; F633FF  ld XIY,0x00f6344d
	calr	BStore_ErrorToStatusByte_Sub	; F63404  calr 0xf63431
	ret	; F63407  ret
BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_24:		; <- T_BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_24
	ld	xiy, BStore_ErrorStatusTable + 0x18	; F63408  ld XIY,0x00f63459
	calr	BStore_ErrorToStatusByte_Sub	; F6340D  calr 0xf63431
	ret	; F63410  ret
BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_36:		; <- T_BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_36
	ld	xiy, BStore_ErrorStatusTable + 0x24	; F63411  ld XIY,0x00f63465
	calr	BStore_ErrorToStatusByte_Sub	; F63416  calr 0xf63431
	ret	; F63419  ret
BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_48:		; <- T_BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_48
	ld	xiy, BStore_ErrorStatusTable + 0x30	; F6341A  ld XIY,0x00f63471
	calr	BStore_ErrorToStatusByte_Sub	; F6341F  calr 0xf63431
	ret	; F63422  ret
BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_60:		; <- T_BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_60
	ld	xiy, BStore_ErrorStatusTable + 0x3C	; F63423  ld XIY,0x00f6347d
	calr	BStore_ErrorToStatusByte_Sub	; F63428  calr 0xf63431
	ret	; F6342B  ret

; --------------------------------------------------------------------------
; BStore_ErrorToStatusByte -- (0x2880) = ErrorStatusTable[(0x0D4A)]
;
; Called from:
;   thunk slots T_BStore_ErrorToStatusByte
;   1 call site inside the module:
;     0xF62C42
;   (both lists are emitted by this script, not typed)
; Evidence: the whole routine is five instructions -- 0xF6342C
;   `ld XIY,0x00F63441`, `xor HL,HL`, `ld L,(0x0D4A)`, `ld A,(XIY+HL)`,
;   `ld (0x2880),A`.  It is the only site in prom_a+prom_b that spells
;   0x00F63441.
; Unknown: what (0x2880) is consumed by.  No interpreter-B display-list record
;   names it (notes/prom_b_var_screens.py --var 0x2880 prints nothing).
; --------------------------------------------------------------------------
BStore_ErrorToStatusByte:		; <- T_BStore_ErrorToStatusByte
	ld	xiy, BStore_ErrorStatusTable	; F6342C  ld XIY,0x00f63441
BStore_ErrorToStatusByte_Sub:
	xor	hl, hl	; F63431  xor HL,HL
	ld	l, (BStore_ErrorCode:16)	; F63433  ld L,(0x0d4a)
	ld	a, (xiy+hl)	; F63437  ld A,(XIY+HL)
	ld	(UI_StatusCode:16), a	; F6343C  ld (0x2880),A
	ret	; F63440  ret

; --- BStore_ErrorStatusTable: 72 bytes at 0xF63441 ---
;     indexed by the error code (0x0D4A); the byte it yields is stored to
;     (0x2880).  Read by BStore_ErrorToStatusByte (0xF6342C), the only site in
;     prom_a+prom_b that names 0x00F63441.  Extent is abutment: the next byte,
;     0xF63489, is thunk T_BStore_OpenChainAtSavedCursor's target.  72 bytes lay out as 6 rows of 12
;     with only four distinct non-0xFF values (0x23 at row+0 and row+7, 0x0F
;     at row+5, and row+9 taking 0xFF,0xFF,0x35,0x1D,0x1C,0x1B).  What the
;     value MEANS is not established.
;     Evidence: the bytes above, re-asserted by assert_data_islands() in
;     notes/gen_prom_b_blockstore_module.py before this text can be emitted.
;     The literal 0x00F63441 appears 1 time in CPU 1's two ROMs, counted by
;     addr_sites() at EVERY byte offset: prom_b 0xF6342D.  Those are the
;     addresses of the LITERAL, which is one or more bytes PAST the start of
;     the instruction carrying it -- the instruction addresses in the
;     paragraph above are not the same numbers and are not meant to be.
BStore_ErrorStatusTable:
	.byte	0x23, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0xFF, 0x23, 0xFF, 0xFF, 0xFF, 0xFF	; +0x00
	.byte	0x23, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0xFF, 0x23, 0xFF, 0xFF, 0xFF, 0xFF	; +0x0C
	.byte	0x23, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0xFF, 0x23, 0xFF, 0x35, 0xFF, 0xFF	; +0x18
	.byte	0x23, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0xFF, 0x23, 0xFF, 0x1D, 0xFF, 0xFF	; +0x24
	.byte	0x23, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0xFF, 0x23, 0xFF, 0x1C, 0xFF, 0xFF	; +0x30
	.byte	0x23, 0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0xFF, 0x23, 0xFF, 0x1B, 0xFF, 0xFF	; +0x3C
; BStore_OpenChainAtSavedCursor: T_BStore_OpenChainAtSavedCursor's body: BStore_OpenChain for entry A (error 1 is cleared and returned as 0); then entry A's saved
;   cursor -- offset byte 0x6034A0[A-1], 5..255, else error 11; block word 0x60347E[A-1], <= BStore_BlockLimit,
;   else error 10 -- becomes BStore_CursorBlock (BStore_SeekBlock); the block must be allocated (bit 7, else 11)
;   and the byte at the offset not tag 0x84 (else error 6).
BStore_OpenChainAtSavedCursor:		; <- T_BStore_OpenChainAtSavedCursor
	pushw	wa	; F63489  push WA
	calr	BStore_OpenChain	; F6348A  calr 0xf638bb
	popw	wa	; F6348D  pop WA
	cp	(BStore_ErrorCode:16), 0x00	; F6348E  cp (0x0d4a),0x00
	jr	z, BStore_OpenChainAtSavedCursor_Skip2	; F63493  jr Z,0xf634a7
	cp	(BStore_ErrorCode:16), 0x01	; F63495  cp (0x0d4a),0x01
	jr	z, BStore_OpenChainAtSavedCursor_Skip	; F6349A  jr Z,0xf6349f
	jrl	BStore_OpenChainAtSavedCursor_Return	; F6349C  jrl T,0xf6350f
BStore_OpenChainAtSavedCursor_Skip:
	ld	(BStore_ErrorCode:16), 0	; F6349F  ld (0x0d4a),0x00
	jrl	BStore_OpenChainAtSavedCursor_Return	; F634A4  jrl T,0xf6350f
BStore_OpenChainAtSavedCursor_Skip2:
	xor	hl, hl	; F634A7  xor HL,HL
	dec	1, a	; F634A9  dec 1,A
	ld	l, a	; F634AB  ld L,A
	xor	bc, bc	; F634AD  xor BC,BC
	push	xix	; F634AF  push XIX
	ld	xix, 6304928	; F634B0  ld XIX,0x006034a0
	ld	c, (xix+hl)	; F634B5  ld C,(XIX+HL)
	pop	xix	; F634BA  pop XIX
	cp	bc, 5:i3	; F634BB  cp BC,5
	jr	c, BStore_OpenChainAtSavedCursor_Skip3	; F634BD  jr C,0xf634c5
	cp	bc, 255	; F634BF  cp BC,0x00ff
	jr	ule, BStore_OpenChainAtSavedCursor_Skip4	; F634C3  jr ULE,0xf634cc
BStore_OpenChainAtSavedCursor_Skip3:
	ld	(BStore_ErrorCode:16), 11	; F634C5  ld (0x0d4a),0x0b
	jr	BStore_OpenChainAtSavedCursor_Return	; F634CA  jr T,0xf6350f
BStore_OpenChainAtSavedCursor_Skip4:
	sla	hl, 1	; F634CC  sla 0x01,HL
	push	xix	; F634CF  push XIX
	ld	xix, 6304894	; F634D0  ld XIX,0x0060347e
	ld	wa, (xix+hl)	; F634D5  ld WA,(XIX+HL)
	pop	xix	; F634DA  pop XIX
	cp	wa, (BStore_BlockLimit:16)	; F634DB  cp WA,(0x0ca4)
	jr	ule, BStore_OpenChainAtSavedCursor_Skip5	; F634DF  jr ULE,0xf634e8
	ld	(BStore_ErrorCode:16), 10	; F634E1  ld (0x0d4a),0x0a
	jr	BStore_OpenChainAtSavedCursor_Return	; F634E6  jr T,0xf6350f
BStore_OpenChainAtSavedCursor_Skip5:
	ld	(BStore_CursorBlock:16), wa	; F634E8  ld (0x345c),WA
	ld	hl, wa	; F634EC  ld HL,WA
	calr	BStore_SeekBlock	; F634EE  calr 0xf63bae
	ld	xhl, (BStore_CursorBlockAddr:16)	; F634F1  ld XHL,(0x126e)
	bit	7, (xhl)	; F634F5  bit 7,(XHL)
	jr	nz, BStore_OpenChainAtSavedCursor_Skip6	; F634F7  jr NZ,0xf63500
	ld	(BStore_ErrorCode:16), 11	; F634F9  ld (0x0d4a),0x0b
	jr	BStore_OpenChainAtSavedCursor_Return	; F634FE  jr T,0xf6350f
BStore_OpenChainAtSavedCursor_Skip6:
	ld	iy, bc	; F63500  ld IY,BC
	cp	(xhl+iy), 0x84	; F63502  cp (XHL+IY),0x84
	jr	nz, BStore_OpenChainAtSavedCursor_Return	; F63508  jr NZ,0xf6350f
	ld	(BStore_ErrorCode:16), 6	; F6350A  ld (0x0d4a),0x06
BStore_OpenChainAtSavedCursor_Return:
	ret	; F6350F  ret
; BStore_TruncateChainAfterBlock: WA = a block number: reads its next link (+3); 0xFFFF -> nothing to do; >
;   BStore_BlockLimit -> BStore_ErrorCode 10; else BStore_FreeChain (via T_BStore_FreeChain_Veneer) from that next block, which re-
;   links the predecessor to the chain's end. Every caller first runs BStore_SaveCursor, which leaves WA = (0x0C57),
;   the cursor block. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave2_e.json)
BStore_TruncateChainAfterBlock:		; <- T_BStore_TruncateChainAfterBlock
	ld	hl, wa	; F63510  ld HL,WA
	calr	BStore_SeekBlock	; F63512  calr 0xf63bae
	ld	xhl, (BStore_CursorBlockAddr:16)	; F63515  ld XHL,(0x126e)
	ld	wa, (xhl+3)	; F63519  ld WA,(XHL+0x03)
	ld	(BStore_CursorBlock:16), wa	; F6351C  ld (0x345c),WA
	cp	wa, 65535	; F63520  cp WA,0xffff
	jr	z, BStore_TruncateChainAfterBlock_Return	; F63524  jr Z,0xf6353d
	cp	wa, (BStore_BlockLimit:16)	; F63526  cp WA,(0x0ca4)
	jr	ule, BStore_TruncateChainAfterBlock_Skip	; F6352A  jr ULE,0xf63533
	ld	(BStore_ErrorCode:16), 10	; F6352C  ld (0x0d4a),0x0a
	jr	BStore_TruncateChainAfterBlock_Return	; F63531  jr T,0xf6353d
BStore_TruncateChainAfterBlock_Skip:
	ld	iy, wa	; F63533  ld IY,WA
	ld	wa, (BStore_BlockLimit:16)	; F63535  ld WA,(0x0ca4)
	call	T_BStore_FreeChain_Veneer	; F63539  call 0xf42888
BStore_TruncateChainAfterBlock_Return:
	ret	; F6353D  ret
sub_F6353E:		; <- T_F42798
	xor	de, de	; F6353E  xor DE,DE
	xor	c, c	; F63540  xor C,C
	xor	wa, wa	; F63542  xor WA,WA
	ldw	(BStore_AllocBytesWanted:16), 1	; F63544  ld (0x0cae),0x0001
	and	(0x0c8a:16), 0xfd	; F6354A  and (0x0c8a),0xfd
	calr	BStore_SeekBlock	; F6354F  calr 0xf63bae
sub_F6353E_Loop:
	cp	de, (0x0c77:16)	; F63552  cp DE,(0x0c77)
	jrl	z, sub_F6353E_Return	; F63556  jrl Z,0xf635c8
	xor	bc, bc	; F63559  xor BC,BC
sub_F6353E_Join:
	cp	c, (0x0d1c:16)	; F6355B  cp C,(0x0d1c)
	jr	z, sub_F6353E_Skip3	; F6355F  jr Z,0xf6359b
sub_F6353E_Loop2:
	bit	1, (0x0c8a:16)	; F63561  bit 1,(0x0c8a)
	jr	z, sub_F6353E_Skip	; F63565  jr Z,0xf63576
	incw	1, (BStore_AllocBytesWanted:16)	; F63567  incw 1,(0x0cae)
	calr	BStore_CursorAdvance	; F6356B  calr 0xf635c9
	cp	(BStore_ErrorCode:16), 0x00	; F6356E  cp (0x0d4a),0x00
	jrl	nz, sub_F6353E_Return	; F63573  jrl NZ,0xf635c8
sub_F6353E_Skip:
	or	(0x0c8a:16), 0x02	; F63576  or (0x0c8a),0x02
	ld	xhl, (BStore_CursorBlockAddr:16)	; F6357B  ld XHL,(0x126e)
	cp	(xhl+iy), 0x82	; F6357F  cp (XHL+IY),0x82
	jr	nz, sub_F6353E_Skip2	; F63585  jr NZ,0xf6358f
	ld	(BStore_ErrorCode:16), 7	; F63587  ld (0x0d4a),0x07
	jrl	sub_F6353E_Return	; F6358C  jrl T,0xf635c8
sub_F6353E_Skip2:
	cp	(xhl+iy), 0x81	; F6358F  cp (XHL+IY),0x81
	jr	nz, sub_F6353E_Loop2	; F63595  jr NZ,0xf63561
	inc	1, c	; F63597  inc 1,C
	jr	sub_F6353E_Join	; F63599  jr T,0xf6355b
sub_F6353E_Skip3:
	inc	1, de	; F6359B  inc 1,DE
	push	xiz	; F6359D  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F6359E  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F635A2  ld XDE3,XIZ
	pop	xiz	; F635A5  pop XIZ
	push_lerp	0x38	; F635A6  push XDE3
	push	xhl	; F635A9  push XHL
	pushw	de	; F635AA  push DE
	push	xiy	; F635AB  push XIY
	push	xix	; F635AC  push XIX
	calr	sub_F63749	; F635AD  calr 0xf63749
	pop	xix	; F635B0  pop XIX
	pop	xiy	; F635B1  pop XIY
	popw	de	; F635B2  pop DE
	pop	xhl	; F635B3  pop XHL
	pop_lerp	0x38	; F635B4  pop XDE3
	push	xiz	; F635B7  push XIZ
	ldto_lerp	xiz, 0x38	; F635B8  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F635BB  ld (0x126e),XIZ
	pop	xiz	; F635BF  pop XIZ
	cp	(BStore_ErrorCode:16), 0x00	; F635C0  cp (0x0d4a),0x00
	jrl	z, sub_F6353E_Loop	; F635C5  jrl Z,0xf63552
sub_F6353E_Return:
	ret	; F635C8  ret

; --------------------------------------------------------------------------
; BStore_CursorAdvance -- ++cursor, following the chain at a block end
;
; Called from:
;   thunk slots T_BStore_CursorAdvance
;   15 call sites inside the module:
;     0xF62C24 0xF62DAC 0xF62DBA 0xF6356B 0xF636B2 0xF636D9 0xF636E4 0xF6371E
;     0xF63796 0xF637B9 0xF637CB 0xF6380B 0xF63857 0xF63872 0xF649C9
;   (both lists are emitted by this script, not typed)
; Inputs:  IY = byte offset in the current block, (0x126E) = block address.
; Outputs: IY, (0x126E), (0x345C) advanced; (0x0D4A) = 0, or 0x0A / 0x0B.
; What it does: `inc 1,IY`; while IY is still <= 0xFF it returns; otherwise it
;   reads the 16-bit NEXT-block number at header offset +3, range-checks it
;   against (0x0CA4), seeks it, checks bit 7 of the new block's byte 0, and
;   restarts the offset at 5.
; Evidence: 0xF635CB `cp IY,0x00FF`, 0xF635D5 `ld WA,(XHL+0x03)`,
;   0xF635E5 `cp WA,(0x0CA4)`, 0xF635FF `bit 7,(XHL)`, 0xF6360A `ld IY,0x0005`.
;   The constant 5 is the same 5 that BStore_AllocChain subtracts from 0x100
;   (0xF639BB `sub HL,0x0005`) to get the payload capacity of a block.
; Unknown: 0xF635D8 `cp WA,0xFFFF / jr ULE` is a comparison that can never
;   fail on a 16-bit register, so the `ld (0x0D4A),0x08` at 0xF635DE is
;   UNREACHABLE.  Error 8 is still produced -- by BStore_CountMarkersForward
;   and 0xF62DA0 -- so the code is dead, not the code path.
; --------------------------------------------------------------------------
BStore_CursorAdvance:		; <- T_BStore_CursorAdvance
	inc	1, iy	; F635C9  inc 1,IY
	cp	iy, 255	; F635CB  cp IY,0x00ff
	jr	le, BStore_CursorAdvance_Return	; F635CF  jr LE,0xf6360d
	ld	xhl, (BStore_CursorBlockAddr:16)	; F635D1  ld XHL,(0x126e)
	ld	wa, (xhl+3)	; F635D5  ld WA,(XHL+0x03)
	cp	wa, 65535	; F635D8  cp WA,0xffff
	jr	ule, BStore_CursorAdvance_Skip	; F635DC  jr ULE,0xf635e5
	ld	(BStore_ErrorCode:16), 8	; F635DE  ld (0x0d4a),0x08
	jr	BStore_CursorAdvance_Return	; F635E3  jr T,0xf6360d
BStore_CursorAdvance_Skip:
	cp	wa, (BStore_BlockLimit:16)	; F635E5  cp WA,(0x0ca4)
	jr	ule, BStore_CursorAdvance_Skip2	; F635E9  jr ULE,0xf635f2
	ld	(BStore_ErrorCode:16), 10	; F635EB  ld (0x0d4a),0x0a
	jr	BStore_CursorAdvance_Return	; F635F0  jr T,0xf6360d
BStore_CursorAdvance_Skip2:
	ld	(BStore_CursorBlock:16), wa	; F635F2  ld (0x345c),WA
	ld	hl, wa	; F635F6  ld HL,WA
	calr	BStore_SeekBlock	; F635F8  calr 0xf63bae
	ld	xhl, (BStore_CursorBlockAddr:16)	; F635FB  ld XHL,(0x126e)
	bit	7, (xhl)	; F635FF  bit 7,(XHL)
	jr	nz, BStore_CursorAdvance_Skip3	; F63601  jr NZ,0xf6360a
	ld	(BStore_ErrorCode:16), 11	; F63603  ld (0x0d4a),0x0b
	jr	BStore_CursorAdvance_Return	; F63608  jr T,0xf6360d
BStore_CursorAdvance_Skip3:
	ldw	iy, 5	; F6360A  ld IY,0x0005
BStore_CursorAdvance_Return:
	ret	; F6360D  ret
; Seq_FindMasterTrack: W := 1 + the first track 0..(0x0CA3) whose BStore_TrackToPart byte is 0x20, and (0x0C8A) bit 2
;   set -- only when (0x360E) bit 0 (the bit S0ngC0py_CopyAllTracks shows as '(MASTER: ON') is set; else W = 0.
;   Seq_LoadTimeSigAtCurrentMeasure reads the time signature from that track. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_f.json)
Seq_FindMasterTrack:		; <- T_Seq_FindMasterTrack
	xor	w, w	; F6360E  xor W,W
	and	(0x0c8a:16), 0xfb	; F63610  and (0x0c8a),0xfb
	xor	hl, hl	; F63615  xor HL,HL
	bit	6, (0x0c8a:16)	; F63617  bit 6,(0x0c8a)
	jr	nz, Seq_FindMasterTrack_Join	; F6361B  jr NZ,0xf63620
	nop	; F6361D  nop
	nop	; F6361E  nop
	nop	; F6361F  nop
Seq_FindMasterTrack_Join:
	cp	l, (0x0ca3:16)	; F63620  cp L,(0x0ca3)
	jr	ule, Seq_FindMasterTrack_Skip	; F63624  jr ULE,0xf63628
	jr	Seq_FindMasterTrack_Return	; F63626  jr T,0xf6364c
Seq_FindMasterTrack_Skip:
	push	xix	; F63628  push XIX
	ld	xix, BStore_TrackToPart	; F63629  ld XIX,0x00603422
	cp	(xix+hl), 0x20	; F6362E  cp (XIX+HL),0x20
	pop	xix	; F63634  pop XIX
	jr	nz, Seq_FindMasterTrack_Skip2	; F63635  jr NZ,0xf63648
	bit	0, (0x360e:16)	; F63637  bit 0,(0x360e)
	jr	z, Seq_FindMasterTrack_Return	; F6363B  jr Z,0xf6364c
	or	(0x0c8a:16), 0x04	; F6363D  or (0x0c8a),0x04
	ld	w, l	; F63642  ld W,L
	inc	1, w	; F63644  inc 1,W
	jr	Seq_FindMasterTrack_Return	; F63646  jr T,0xf6364c
Seq_FindMasterTrack_Skip2:
	inc	1, l	; F63648  inc 1,L
	jr	Seq_FindMasterTrack_Join	; F6364A  jr T,0xf63620
Seq_FindMasterTrack_Return:
	ret	; F6364C  ret
; BStore_TimeSigFirstMeasure: Time-signature walk, first measure: (0x0D1C) := the song's beats per bar (0x6034D7);
;   when (0x0C8A) bit 2 it opens chain (0x0D1D), keeps its head block in (0x0CEC), takes (0x0D1C) from leading
;   tag-0x87 records and at the first 0x81 beat mark lets BStore_TimeSigAdvanceOneMeasure leave the time-sig cursor (0x0CF0)/(0x0CF4) at
;   measure 2; a 0x82 or 0x84 tag before any beat mark sets (0x0C8A) bit 5 and keeps the default. BStore_CursorBlock
;   is preserved. BStore_TimeSigNextMeasure_Call's target (sub_F63749) continues from that cursor. Behind the
;   BStore_LoadStartBeatsPerBar stub; BStore_SeekMeasure and CycleRecord_BeatsBeforeMeasureFromTimeSigs start with it. Basis: callers + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave4_k.json)
BStore_TimeSigFirstMeasure:		; <- T_BStore_TimeSigFirstMeasure
	pushw	(BStore_CursorBlock:16)	; F6364D  pushw (0x345c)
	and	(0x0c8a:16), 0xdf	; F63651  and (0x0c8a),0xdf
	ld	a, (6304983:24)	; F63656  ld A,(0x6034d7)
	ld	(3356:16), a	; F6365B  ld (0x0d1c),A
	bit	2, (0x0c8a:16)	; F6365F  bit 2,(0x0c8a)
	jrl	z, BStore_TimeSigFirstMeasure_Join2	; F63663  jrl Z,0xf63744
	ld	a, (3357:16)	; F63666  ld A,(0x0d1d)
	calr	BStore_OpenChain	; F6366A  calr 0xf638bb
	cp	(BStore_ErrorCode:16), 0x00	; F6366D  cp (0x0d4a),0x00
	jr	z, BStore_TimeSigFirstMeasure_Skip	; F63672  jr Z,0xf63681
	and	(0x0c8a:16), 0xfb	; F63674  and (0x0c8a),0xfb
	ld	(BStore_ErrorCode:16), 0	; F63679  ld (0x0d4a),0x00
	jrl	BStore_TimeSigFirstMeasure_Join2	; F6367E  jrl T,0xf63744
BStore_TimeSigFirstMeasure_Skip:
	xor	hl, hl	; F63681  xor HL,HL
	push	xwa	; F63683  push XWA
	ld	xwa, (BStore_CursorBlockAddr:16)	; F63684  ld XWA,(0x126e)
	ld	(3308:16), xwa	; F63688  ld (0x0cec),XWA
	pop	xwa	; F6368C  pop XWA
	ldw	iy, 5	; F6368D  ld IY,0x0005
BStore_TimeSigFirstMeasure_Loop:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F63690  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F63694  ld A,(XHL+IY)
	ld	w, a	; F63699  ld W,A
	cp	w, 135	; F6369B  cp W,0x87
	jr	z, BStore_TimeSigFirstMeasure_Skip2	; F6369E  jr Z,0xf636bf
	cp	w, 130	; F636A0  cp W,0x82
	jrl	z, BStore_TimeSigFirstMeasure_Join	; F636A3  jrl Z,0xf63731
	cp	w, 132	; F636A6  cp W,0x84
	jrl	z, BStore_TimeSigFirstMeasure_Join	; F636A9  jrl Z,0xf63731
	cp	w, 129	; F636AC  cp W,0x81
	jrl	z, BStore_TimeSigFirstMeasure_Skip3	; F636AF  jrl Z,0xf6372b
	calr	BStore_CursorAdvance	; F636B2  calr 0xf635c9
	cp	(BStore_ErrorCode:16), 0x00	; F636B5  cp (0x0d4a),0x00
	jr	z, BStore_TimeSigFirstMeasure_Loop	; F636BA  jr Z,0xf63690
	jrl	BStore_TimeSigFirstMeasure_Join	; F636BC  jrl T,0xf63731
BStore_TimeSigFirstMeasure_Skip2:
	ld	a, w	; F636BF  ld A,W
	ld	hl, wa	; F636C1  ld HL,WA
	rrc	a	; F636C3  rrc 0x01,A
	and	wa, 128	; F636C6  and WA,0x0080
	ld	(3340:16), wa	; F636CA  ld (0x0d0c),WA
	and	hl, 2	; F636CE  and HL,0x0002
	.byte 0xCF, 0xE9, 0x02	; F636D2  rrc 0x02,L   [llvm-mc cannot encode this]
	ld	(3342:16), hl	; F636D5  ld (0x0d0e),HL
	calr	BStore_CursorAdvance	; F636D9  calr 0xf635c9
	cp	(BStore_ErrorCode:16), 0x00	; F636DC  cp (0x0d4a),0x00
	jrl	nz, BStore_TimeSigFirstMeasure_Join	; F636E1  jrl NZ,0xf63731
	calr	BStore_CursorAdvance	; F636E4  calr 0xf635c9
	cp	(BStore_ErrorCode:16), 0x00	; F636E7  cp (0x0d4a),0x00
	jrl	nz, BStore_TimeSigFirstMeasure_Join	; F636EC  jrl NZ,0xf63731
	ld	wa, (3340:16)	; F636EF  ld WA,(0x0d0c)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F636F3  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F636F7  ld A,(XHL+IY)
	push	xiz	; F636FC  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F636FD  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x30	; F63701  ld XWA3,XIZ
	pop	xiz	; F63704  pop XIZ
	push_lerp	0x30	; F63705  push XWA3
	push	xiy	; F63708  push XIY
	push	xhl	; F63709  push XHL
	pop	xhl	; F6370A  pop XHL
	pop	xiy	; F6370B  pop XIY
	pop_lerp	0x30	; F6370C  pop XWA3
	push	xiz	; F6370F  push XIZ
	ldto_lerp	xiz, 0x30	; F63710  ld XIZ,XWA3
	ld	(BStore_CursorBlockAddr:16), xiz	; F63713  ld (0x126e),XIZ
	pop	xiz	; F63717  pop XIZ
	inc	1, a	; F63718  inc 1,A
	ld	(3356:16), a	; F6371A  ld (0x0d1c),A
	calr	BStore_CursorAdvance	; F6371E  calr 0xf635c9
	cp	(BStore_ErrorCode:16), 0x00	; F63721  cp (0x0d4a),0x00
	jr	nz, BStore_TimeSigFirstMeasure_Join	; F63726  jr NZ,0xf63731
	jrl	BStore_TimeSigFirstMeasure_Loop	; F63728  jrl T,0xf63690
BStore_TimeSigFirstMeasure_Skip3:
	call	BStore_TimeSigAdvanceOneMeasure	; F6372B  call 0xf6382b
	jr	BStore_TimeSigFirstMeasure_Join2	; F6372F  jr T,0xf63744
BStore_TimeSigFirstMeasure_Join:
	ld	(BStore_ErrorCode:16), 0	; F63731  ld (0x0d4a),0x00
	ld	a, (6304983:24)	; F63736  ld A,(0x6034d7)
	ld	(3356:16), a	; F6373B  ld (0x0d1c),A
	or	(0x0c8a:16), 0x20	; F6373F  or (0x0c8a),0x20
BStore_TimeSigFirstMeasure_Join2:
	popw	(BStore_CursorBlock:16)	; F63744  popw (0x345c)
	ret	; F63748  ret
sub_F63749:		; <- T_F427A8
	pushw	(BStore_CursorBlock:16)	; F63749  pushw (0x345c)
	bit	2, (0x0c8a:16)	; F6374D  bit 2,(0x0c8a)
	jrl	z, sub_F63749_Join	; F63751  jrl Z,0xf63821
	bit	5, (0x0c8a:16)	; F63754  bit 5,(0x0c8a)
	jrl	nz, sub_F63749_Join	; F63758  jrl NZ,0xf63821
	xor	hl, hl	; F6375B  xor HL,HL
	ld	xhl, (3312:16)	; F6375D  ld XHL,(0x0cf0)
	ld	(BStore_CursorBlockAddr:16), xhl	; F63761  ld (0x126e),XHL
	ld	iy, (3316:16)	; F63765  ld IY,(0x0cf4)
sub_F63749_Loop:
	ld	a, (xhl+iy)	; F63769  ld A,(XHL+IY)
	ld	w, a	; F6376E  ld W,A
	cp	w, 135	; F63770  cp W,0x87
	jr	z, sub_F63749_Skip3	; F63773  jr Z,0xf637a8
	cp	w, 130	; F63775  cp W,0x82
	jr	nz, sub_F63749_Skip	; F63778  jr NZ,0xf63782
	or	(0x0c8a:16), 0x20	; F6377A  or (0x0c8a),0x20
	jrl	sub_F63749_Join	; F6377F  jrl T,0xf63821
sub_F63749_Skip:
	cp	w, 132	; F63782  cp W,0x84
	jr	nz, sub_F63749_Skip2	; F63785  jr NZ,0xf63790
	ldw	iy, 5	; F63787  ld IY,0x0005
	ld	xhl, (3308:16)	; F6378A  ld XHL,(0x0cec)
	jr	sub_F63749_Loop	; F6378E  jr T,0xf63769
sub_F63749_Skip2:
	cp	w, 129	; F63790  cp W,0x81
	jrl	z, sub_F63749_Skip6	; F63793  jrl Z,0xf6381d
	calr	BStore_CursorAdvance	; F63796  calr 0xf635c9
	cp	(BStore_ErrorCode:16), 0x00	; F63799  cp (0x0d4a),0x00
	jr	z, sub_F63749_Loop	; F6379E  jr Z,0xf63769
	ld	(BStore_ErrorCode:16), 0	; F637A0  ld (0x0d4a),0x00
	jrl	sub_F63749_Join	; F637A5  jrl T,0xf63821
sub_F63749_Skip3:
	ld	l, w	; F637A8  ld L,W
	xor	l, l	; F637AA  xor L,L
	ld	a, w	; F637AC  ld A,W
	rrc	a	; F637AE  rrc 0x01,A
	and	wa, 128	; F637B1  and WA,0x0080
	ld	(3340:16), wa	; F637B5  ld (0x0d0c),WA
	calr	BStore_CursorAdvance	; F637B9  calr 0xf635c9
	cp	(BStore_ErrorCode:16), 0x00	; F637BC  cp (0x0d4a),0x00
	jr	z, sub_F63749_Skip4	; F637C1  jr Z,0xf637cb
	ld	(BStore_ErrorCode:16), 0	; F637C3  ld (0x0d4a),0x00
	jrl	sub_F63749_Join	; F637C8  jrl T,0xf63821
sub_F63749_Skip4:
	calr	BStore_CursorAdvance	; F637CB  calr 0xf635c9
	cp	(BStore_ErrorCode:16), 0x00	; F637CE  cp (0x0d4a),0x00
	jr	z, sub_F63749_Skip5	; F637D3  jr Z,0xf637dc
	ld	(BStore_ErrorCode:16), 0	; F637D5  ld (0x0d4a),0x00
	jr	sub_F63749_Join	; F637DA  jr T,0xf63821
sub_F63749_Skip5:
	ld	wa, (3340:16)	; F637DC  ld WA,(0x0d0c)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F637E0  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F637E4  ld A,(XHL+IY)
	push	xiz	; F637E9  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F637EA  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x3c	; F637EE  ld XHL3,XIZ
	pop	xiz	; F637F1  pop XIZ
	push_lerp	0x3c	; F637F2  push XHL3
	push	xiy	; F637F5  push XIY
	push	xhl	; F637F6  push XHL
	pop	xhl	; F637F7  pop XHL
	pop	xiy	; F637F8  pop XIY
	pop_lerp	0x3c	; F637F9  pop XHL3
	push	xiz	; F637FC  push XIZ
	ldto_lerp	xiz, 0x3c	; F637FD  ld XIZ,XHL3
	ld	(BStore_CursorBlockAddr:16), xiz	; F63800  ld (0x126e),XIZ
	pop	xiz	; F63804  pop XIZ
	inc	1, a	; F63805  inc 1,A
	ld	(3356:16), a	; F63807  ld (0x0d1c),A
	calr	BStore_CursorAdvance	; F6380B  calr 0xf635c9
	cp	(BStore_ErrorCode:16), 0x00	; F6380E  cp (0x0d4a),0x00
	jrl	z, sub_F63749_Loop	; F63813  jrl Z,0xf63769
	ld	(BStore_ErrorCode:16), 0	; F63816  ld (0x0d4a),0x00
	jr	sub_F63749_Join	; F6381B  jr T,0xf63821
sub_F63749_Skip6:
	call	BStore_TimeSigAdvanceOneMeasure	; F6381D  call 0xf6382b
sub_F63749_Join:
	popw	(BStore_CursorBlock:16)	; F63821  popw (0x345c)
	ld	(BStore_ErrorCode:16), 0	; F63825  ld (0x0d4a),0x00
	ret	; F6382A  ret
; BStore_TimeSigAdvanceOneMeasure: Shared tail of the time-signature walk: steps the cursor past (0x0D1C) 0x81 beat
;   marks (a 0x84 tag restarts at offset 5 of the chain head (0x0CEC)) and stores the position reached as the time-sig
;   cursor (0x0CF0)/(0x0CF4); reaching 0x82 instead sets (0x0C8A) bit 5. Called by BStore_TimeSigFirstMeasure at its
;   first beat mark and by sub_F63749 (BStore_TimeSigNextMeasure_Call's target). Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_q.json)
BStore_TimeSigAdvanceOneMeasure:
	xor	bc, bc	; F6382B  xor BC,BC
BStore_TimeSigAdvanceOneMeasure_Join:
	cp	(3356:16), c	; F6382D  cp (0x0d1c),C
	jr	z, BStore_TimeSigAdvanceOneMeasure_Skip4	; F63831  jr Z,0xf6387e
	ld	xhl, (BStore_CursorBlockAddr:16)	; F63833  ld XHL,(0x126e)
	cp	(xhl+iy), 0x82	; F63837  cp (XHL+IY),0x82
	jr	nz, BStore_TimeSigAdvanceOneMeasure_Skip	; F6383D  jr NZ,0xf63847
	or	(0x0c8a:16), 0x20	; F6383F  or (0x0c8a),0x20
	jrl	BStore_TimeSigAdvanceOneMeasure_Return	; F63844  jrl T,0xf638ba
BStore_TimeSigAdvanceOneMeasure_Skip:
	cp	(xhl+iy), 0x81	; F63847  cp (XHL+IY),0x81
	jr	z, BStore_TimeSigAdvanceOneMeasure_Skip3	; F6384D  jr Z,0xf63870
	cp	(xhl+iy), 0x84	; F6384F  cp (XHL+IY),0x84
	jr	z, BStore_TimeSigAdvanceOneMeasure_Skip2	; F63855  jr Z,0xf63863
	calr	BStore_CursorAdvance	; F63857  calr 0xf635c9
	cp	(BStore_ErrorCode:16), 0x00	; F6385A  cp (0x0d4a),0x00
	jr	nz, BStore_TimeSigAdvanceOneMeasure_Skip7	; F6385F  jr NZ,0xf638b0
	jr	BStore_TimeSigAdvanceOneMeasure_Join	; F63861  jr T,0xf6382d
BStore_TimeSigAdvanceOneMeasure_Skip2:
	ldw	iy, 5	; F63863  ld IY,0x0005
	ld	xhl, (3308:16)	; F63866  ld XHL,(0x0cec)
	ld	(BStore_CursorBlockAddr:16), xhl	; F6386A  ld (0x126e),XHL
	jr	BStore_TimeSigAdvanceOneMeasure_Join	; F6386E  jr T,0xf6382d
BStore_TimeSigAdvanceOneMeasure_Skip3:
	inc	1, c	; F63870  inc 1,C
	calr	BStore_CursorAdvance	; F63872  calr 0xf635c9
	cp	(BStore_ErrorCode:16), 0x00	; F63875  cp (0x0d4a),0x00
	jr	nz, BStore_TimeSigAdvanceOneMeasure_Skip7	; F6387A  jr NZ,0xf638b0
	jr	BStore_TimeSigAdvanceOneMeasure_Join	; F6387C  jr T,0xf6382d
BStore_TimeSigAdvanceOneMeasure_Skip4:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F6387E  ld XHL,(0x126e)
	cp	(xhl+iy), 0x82	; F63882  cp (XHL+IY),0x82
	jr	nz, BStore_TimeSigAdvanceOneMeasure_Skip5	; F63888  jr NZ,0xf63891
	or	(0x0c8a:16), 0x20	; F6388A  or (0x0c8a),0x20
	jr	BStore_TimeSigAdvanceOneMeasure_Return	; F6388F  jr T,0xf638ba
BStore_TimeSigAdvanceOneMeasure_Skip5:
	cp	(xhl+iy), 0x84	; F63891  cp (XHL+IY),0x84
	jr	nz, BStore_TimeSigAdvanceOneMeasure_Skip6	; F63897  jr NZ,0xf638a0
	ldw	iy, 5	; F63899  ld IY,0x0005
	ld	xhl, (3308:16)	; F6389C  ld XHL,(0x0cec)
BStore_TimeSigAdvanceOneMeasure_Skip6:
	ld	(3316:16), iy	; F638A0  ld (0x0cf4),IY
	push	xwa	; F638A4  push XWA
	ld	xwa, (BStore_CursorBlockAddr:16)	; F638A5  ld XWA,(0x126e)
	ld	(3312:16), xwa	; F638A9  ld (0x0cf0),XWA
	pop	xwa	; F638AD  pop XWA
	jr	BStore_TimeSigAdvanceOneMeasure_Return	; F638AE  jr T,0xf638ba
BStore_TimeSigAdvanceOneMeasure_Skip7:
	or	(0x0c8a:16), 0x20	; F638B0  or (0x0c8a),0x20
	ld	(BStore_ErrorCode:16), 0	; F638B5  ld (0x0d4a),0x00
BStore_TimeSigAdvanceOneMeasure_Return:
	ret	; F638BA  ret

; --------------------------------------------------------------------------
; BStore_OpenChain -- directory lookup: entry n -> cursor at its head
;
; Called from:
;   thunk slots T_BStore_OpenChain
;   5 call sites inside the module:
;     0xF62C1C 0xF62C7F 0xF62D07 0xF6348A 0xF6366A
;   (both lists are emitted by this script, not typed)
; Inputs:  A = entry number, 1-based.
; Outputs: (0x345C) = head block number, (0x126E) = its address, (0x0D4A) = 0
;   or 0x01 / 0x02 / 0x0A / 0x0B.
; THE DIRECTORY, and this routine is where its shape is read off:
;   base 0x00603500, stride 3 (`muls WA,0x0003` at 0xF638CA),
;   +0 flags -- bit 7 set means the entry is in use (`bit 7,(XDE+IY)`),
;   +1..+2 the 16-bit head BLOCK NUMBER, 0xFFFF meaning empty
;          (`inc 1,IY` then `ld WA,(XDE+IY)`, then `cp WA,0xFFFF`).
; Evidence: 0xF638D1 and 0xF638E8 both `ld XDE,0x00603500`.  The 32-bit immediate
;   0x00603500 occurs 67 times in prom_a+prom_b, counted here.
;   So this directory is not private to this module.
; Unknown: what (0x0C90) is.  It bounds a loop over the directory at 0xF62D3C
;   and nothing fixes its value.
;   ⚠ CORRECTED 2026-08-25: this line used to read "how many directory entries
;   there are" is unknown.  It is 17 -- BStore_FreeList_Init (0xF7A428, below)
;   clears the array with `ld XHL,0x00603500 / ld BC,0x0011 / ld (XHL),0x00 /
;   ld (XHL+0x01),0xFFFF / add XHL,0x00000003 / djnz BC`, and TLCS-900 djnz
;   decrements THEN tests, so 17 entries of 3 bytes, 51 bytes in all.  That is
;   the INITIALISED extent; (0x0C90) is still a separate unknown.
;   Check: python3 notes/prom_b_songstore_checks.py --arrays
; --------------------------------------------------------------------------
BStore_OpenChain:		; <- T_BStore_OpenChain
	xor	w, w	; F638BB  xor W,W
	cp	a, 0:i3	; F638BD  cp A,0
	jr	nz, BStore_OpenChain_Skip	; F638BF  jr NZ,0xf638c8
	ld	(BStore_ErrorCode:16), 1	; F638C1  ld (0x0d4a),0x01
	jr	BStore_OpenChain_Return	; F638C6  jr T,0xf63923
BStore_OpenChain_Skip:
	dec	1, a	; F638C8  dec 1,A
	muls	wa, 3	; F638CA  muls WA,0x0003
	ld	iy, wa	; F638CE  ld IY,WA
	push	xde	; F638D0  push XDE
	ld	xde, 6305024	; F638D1  ld XDE,0x00603500
	bit	7, (xde+iy)	; F638D6  bit 7,(XDE+IY)
	pop	xde	; F638DB  pop XDE
	jr	nz, BStore_OpenChain_Skip2	; F638DC  jr NZ,0xf638e5
	ld	(BStore_ErrorCode:16), 1	; F638DE  ld (0x0d4a),0x01
	jr	BStore_OpenChain_Return	; F638E3  jr T,0xf63923
BStore_OpenChain_Skip2:
	inc	1, iy	; F638E5  inc 1,IY
	push	xde	; F638E7  push XDE
	ld	xde, 6305024	; F638E8  ld XDE,0x00603500
	ld	wa, (xde+iy)	; F638ED  ld WA,(XDE+IY)
	pop	xde	; F638F2  pop XDE
	cp	wa, 65535	; F638F3  cp WA,0xffff
	jr	nz, BStore_OpenChain_Skip3	; F638F7  jr NZ,0xf63900
	ld	(BStore_ErrorCode:16), 2	; F638F9  ld (0x0d4a),0x02
	jr	BStore_OpenChain_Return	; F638FE  jr T,0xf63923
BStore_OpenChain_Skip3:
	cp	wa, (BStore_BlockLimit:16)	; F63900  cp WA,(0x0ca4)
	jr	ule, BStore_OpenChain_Skip4	; F63904  jr ULE,0xf6390d
	ld	(BStore_ErrorCode:16), 10	; F63906  ld (0x0d4a),0x0a
	jr	BStore_OpenChain_Return	; F6390B  jr T,0xf63923
BStore_OpenChain_Skip4:
	ld	(BStore_CursorBlock:16), wa	; F6390D  ld (0x345c),WA
	ld	hl, wa	; F63911  ld HL,WA
	calr	BStore_SeekBlock	; F63913  calr 0xf63bae
	ld	xhl, (BStore_CursorBlockAddr:16)	; F63916  ld XHL,(0x126e)
	bit	7, (xhl)	; F6391A  bit 7,(XHL)
	jr	nz, BStore_OpenChain_Return	; F6391C  jr NZ,0xf63923
	ld	(BStore_ErrorCode:16), 11	; F6391E  ld (0x0d4a),0x0b
BStore_OpenChain_Return:
	ret	; F63923  ret

; --------------------------------------------------------------------------
; BStore_SaveCursor -- store entry n's cursor, in RAM and in its bank
;
; Called from:
;   thunk slots T_BStore_SaveCursor
;   4 call sites inside the module:
;     0xF62C56 0xF63F81 0xF64524 0xF648EE
;   (both lists are emitted by this script, not typed)
; Inputs:  (0x0D1A) = entry number 1-based; IX = the byte offset; (0x0C57) =
;   the block number.
; What it does: writes the offset byte to 0x006034A0[n-1] and the block-number
;   word to 0x0060347E[(n-1)*2], and then writes the SAME two values into the
;   saved copy of the workspace at 0x00610000 + (0x360A)*0xC00 + 0xA0 / + 0x7E.
; Evidence: 0xF6392E and 0xF6393F name the two RAM arrays; 0xF6394E
;   `ld XIZ,0x00610000` with `sla 0x0B,XWA` + `sla 0x0A,XBC` (i.e. n*0x800 +
;   n*0x400 = n*0xC00) and then the same two offsets 0xA0 and 0x7E as literals.
;   This routine is why the (+0x7E word, +0xA0 byte) pair is called a cursor:
;   it is written here from a live block number and offset, and read back by
;   BStore_ValidateSavedCursor.
; --------------------------------------------------------------------------
BStore_SaveCursor:		; <- T_BStore_SaveCursor
	push	xde	; F63924  push XDE
	push	xiz	; F63925  push XIZ
	ld	hl, (3354:16)	; F63926  ld HL,(0x0d1a)
	dec	1, hl	; F6392A  dec 1,HL
	ld	wa, ix	; F6392C  ld WA,IX
	ld	xde, 6304928	; F6392E  ld XDE,0x006034a0
	ld	(xde+hl), a	; F63933  ld (XDE+HL),A
	sla	hl, 1	; F63938  sla 0x01,HL
	ld	wa, (3159:16)	; F6393B  ld WA,(0x0c57)
	ld	xde, 6304894	; F6393F  ld XDE,0x0060347e
	ld	(xde+hl), wa	; F63944  ld (XDE+HL),WA
	push	xbc	; F63949  push XBC
	xor	xbc, xbc	; F6394A  xor XBC,XBC
	xor	xwa, xwa	; F6394C  xor XWA,XWA
	ld	xiz, 6356992	; F6394E  ld XIZ,0x00610000
	ld	a, (BStore_CurrentBank:16)	; F63953  ld A,(0x360a)
	ld	c, a	; F63957  ld C,A
	sla	xwa, 11	; F63959  sla 0x0b,XWA
	sla	xbc, 10	; F6395C  sla 0x0a,XBC
	add	xwa, xbc	; F6395F  add XWA,XBC
	pop	xbc	; F63961  pop XBC
	add	xiz, xwa	; F63962  add XIZ,XWA
	ld	xde, 160	; F63964  ld XDE,0x000000a0
	add	xde, xiz	; F63969  add XDE,XIZ
	ld	wa, ix	; F6396B  ld WA,IX
	ld	(xde+hl), a	; F6396D  ld (XDE+HL),A
	sla	hl, 1	; F63972  sla 0x01,HL
	ld	xde, 126	; F63975  ld XDE,0x0000007e
	add	xde, xiz	; F6397A  add XDE,XIZ
	ld	wa, (3159:16)	; F6397C  ld WA,(0x0c57)
	ld	(xde+hl), wa	; F63980  ld (XDE+HL),WA
	pop	xiz	; F63985  pop XIZ
	pop	xde	; F63986  pop XDE
	ret	; F63987  ret

; --------------------------------------------------------------------------
; BStore_AllocChain -- allocate a chain long enough for N bytes
;
; Called from:
;   thunk slots T_BStore_AllocChain
;   2 call sites inside the module:
;     0xF62C5A 0xF648B2
;   (both lists are emitted by this script, not typed)
; Inputs:  (0x0CAE) = byte count wanted, (0x0CC6) = bytes already in the last
;   block, (0x0CC0) = the block to link the new chain onto.
; Outputs: (0x0CAC) = blocks allocated, (0x0D08) = bytes free in the last one,
;   (0x0CC2) = the last block's address, (0x0D4A) = 0 or 0x05.
; THE BLOCK CAPACITY, and this is where it is read off: 0xF639B8-0xF639BB
;   `ld HL,0x0100 / sub HL,0x0005` and then `div XWA,HL` -- 0x100 bytes per
;   block, 5 of them header, 251 payload.  The same `0x100 - 5` appears at
;   0xF62E3F-0xF62E42.
; THE BLOCK HEADER's two link fields are written here:
;   0xF63A3A `ld (XHL+0x03),IX`      -- the NEXT block number,
;   0xF63A46 `ld (XHL+0x03),0xFFFF`  -- end of chain,
;   0xF63A4B `ld (XHL+0x01),DE`      -- the PREVIOUS block number.
;   So the chain is DOUBLY linked and 0xFFFF is the terminator, which is the
;   same 0xFFFF BStore_OpenChain tests the directory head against.
; Evidence: also 0xF639EA `cp WA,(0x6034BA)` -> error 5, which is what makes
;   the workspace word at +0xBA the free-block count.
; Unknown: the allocator itself is not here -- 0xF63A18 calls thunk T_BStore_AllocBlock_Veneer
;   -> 0xF7A402, in another module.
; --------------------------------------------------------------------------
BStore_AllocChain:		; <- T_BStore_AllocChain
	ldw	wa, 255	; F63988  ld WA,0x00ff
	sub	wa, (BStore_LastBlockUsed:16)	; F6398B  sub WA,(0x0cc6)
	cp	(BStore_AllocBytesWanted:16), wa	; F6398F  cp (0x0cae),WA
	jr	ugt, BStore_AllocChain_Skip	; F63993  jr UGT,0xf639ae
	ldw	(BStore_BlocksAllocated:16), 0	; F63995  ld (0x0cac),0x0000
	ld	wa, (BStore_LastBlockUsed:16)	; F6399B  ld WA,(0x0cc6)
	add	wa, (BStore_AllocBytesWanted:16)	; F6399F  add WA,(0x0cae)
	ld	(BStore_LastBlockFree:16), wa	; F639A3  ld (0x0d08),WA
	ld	de, (BStore_LinkBlock:16)	; F639A7  ld DE,(0x0cc0)
	jrl	BStore_AllocChain_Return	; F639AB  jrl T,0xf63a58
BStore_AllocChain_Skip:
	ld	de, (BStore_AllocBytesWanted:16)	; F639AE  ld DE,(0x0cae)
	sub	de, wa	; F639B2  sub DE,WA
	ld	(3346:16), de	; F639B4  ld (0x0d12),DE
	ldw	hl, 256	; F639B8  ld HL,0x0100
	sub	hl, 5	; F639BB  sub HL,0x0005
	add	de, hl	; F639BF  add DE,HL
	dec	1, de	; F639C1  dec 1,DE
	ld	wa, de	; F639C3  ld WA,DE
	xor	de, de	; F639C5  xor DE,DE
	ld	qwa, de	; F639C7  ld QWA,DE
	div	xwa, hl	; F639CA  div XWA,HL
	ld	de, qwa	; F639CC  ld DE,QWA
	ld	(BStore_BlocksAllocated:16), wa	; F639CF  ld (0x0cac),WA
	mul	xwa, hl	; F639D3  mul XWA,HL
	ld	de, qwa	; F639D5  ld DE,QWA
	sub	wa, (0x0d12:16)	; F639D8  sub WA,(0x0d12)
	sub	hl, wa	; F639DC  sub HL,WA
	add	hl, 4	; F639DE  add HL,0x0004
	ld	(BStore_LastBlockFree:16), hl	; F639E2  ld (0x0d08),HL
	ld	wa, (BStore_BlocksAllocated:16)	; F639E6  ld WA,(0x0cac)
	cp	wa, (BStore_FreeCount:24)	; F639EA  cp WA,(0x6034ba)
	jr	ule, BStore_AllocChain_Skip2	; F639EF  jr ULE,0xf639f8
	ld	(BStore_ErrorCode:16), 5	; F639F1  ld (0x0d4a),0x05
	jr	BStore_AllocChain_Return	; F639F6  jr T,0xf63a58
BStore_AllocChain_Skip2:
	ld	de, (BStore_LinkBlock:16)	; F639F8  ld DE,(0x0cc0)
	xor	bc, bc	; F639FC  xor BC,BC
	ld	hl, de	; F639FE  ld HL,DE
	calr	BStore_SeekBlock	; F63A00  calr 0xf63bae
BStore_AllocChain_Join:
	cp	bc, (BStore_BlocksAllocated:16)	; F63A03  cp BC,(0x0cac)
	jr	nc, BStore_AllocChain_Return	; F63A07  jr NC,0xf63a58
	push	xiz	; F63A09  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F63A0A  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F63A0E  ld XDE3,XIZ
	pop	xiz	; F63A11  pop XIZ
	push_lerp	0x38	; F63A12  push XDE3
	push	xhl	; F63A15  push XHL
	pushw	bc	; F63A16  push BC
	pushw	de	; F63A17  push DE
	call	T_BStore_AllocBlock_Veneer	; F63A18  call 0xf42884
	popw	de	; F63A1C  pop DE
	popw	bc	; F63A1D  pop BC
	pop	xhl	; F63A1E  pop XHL
	pop_lerp	0x38	; F63A1F  pop XDE3
	push	xiz	; F63A22  push XIZ
	ldto_lerp	xiz, 0x38	; F63A23  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F63A26  ld (0x126e),XIZ
	pop	xiz	; F63A2A  pop XIZ
	cp	w, 0:i3	; F63A2B  cp W,0
	jr	z, BStore_AllocChain_Skip3	; F63A2D  jr Z,0xf63a36
	ld	(BStore_ErrorCode:16), 5	; F63A2F  ld (0x0d4a),0x05
	jr	BStore_AllocChain_Return	; F63A34  jr T,0xf63a58
BStore_AllocChain_Skip3:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F63A36  ld XHL,(0x126e)
	ld	(xhl+3), ix	; F63A3A  ld (XHL+0x03),IX
	ld	hl, ix	; F63A3D  ld HL,IX
	calr	BStore_SeekBlock	; F63A3F  calr 0xf63bae
	ld	xhl, (BStore_CursorBlockAddr:16)	; F63A42  ld XHL,(0x126e)
	ldw	(xhl+3), 0xffff	; F63A46  ld (XHL+0x03),0xffff
	ld	(xhl+1), de	; F63A4B  ld (XHL+0x01),DE
	ld	(BStore_LastBlockAddr:16), xhl	; F63A4E  ld (0x0cc2),XHL
	ld	de, ix	; F63A52  ld DE,IX
	inc	1, bc	; F63A54  inc 1,BC
	jr	BStore_AllocChain_Join	; F63A56  jr T,0xf63a03
BStore_AllocChain_Return:
	ret	; F63A58  ret
; SongEdit_ResetJobFields: Resets the song-edit job settings: workspace bytes/words 0x603458..0x60347C and
;   0x6034B1..0x6034BD, (0x0DBE)/(0x0E16)/(0x0E17)/(0x0C35) = 0, (0x0E04)/(0x0E05) = 100, NOTE CHANGE from/to measure
;   = 1, from/to note = 0, span (0x129E) = 1, and the from/to measure pairs at 0x0DE6.. / 0x0DF7.. = 1. Basis: callers
;   + body -- run in BStore_BootPhase3; byte-identical twin of SongEdit_ResetJobFields_Copy, which SongClear_ClearBank runs.
;   (notes/naming-pilot-2026-10-06/proposals_wave2_d.json)
SongEdit_ResetJobFields:		; <- T_SongEdit_ResetJobFields
	ld	(6304856:24), 0	; F63A59  ld (0x603458),0x00
	ldw	(3518:16), 0	; F63A5F  ld (0x0dbe),0x0000
	ld	(6304857:24), 1	; F63A65  ld (0x603459),0x01
	ld	(6304858:24), 2	; F63A6B  ld (0x60345a),0x02
	ld	(6304859:24), 3	; F63A71  ld (0x60345b),0x03
	ld	(6304860:24), 1	; F63A77  ld (0x60345c),0x01
	ldw	(6304861:24), 1	; F63A7D  ld (0x60345d),0x0001
	ldw	(6304863:24), 1	; F63A84  ld (0x60345f),0x0001
	ld	(6304865:24), 1	; F63A8B  ld (0x603461),0x01
	ldw	(6304866:24), 1	; F63A91  ld (0x603462),0x0001
	ldw	(6304868:24), 1	; F63A98  ld (0x603464),0x0001
	ld	(6304870:24), 0	; F63A9F  ld (0x603466),0x00
	ld	(6304871:24), 1	; F63AA5  ld (0x603467),0x01
	ldw	(6304872:24), 1	; F63AAB  ld (0x603468),0x0001
	ldw	(6304874:24), 1	; F63AB2  ld (0x60346a),0x0001
	ld	(6304876:24), 1	; F63AB9  ld (0x60346c),0x01
	ldw	(6304877:24), 1	; F63ABF  ld (0x60346d),0x0001
	ld	(3607:16), 0	; F63AC6  ld (0x0e17),0x00
	ld	(6304879:24), 1	; F63ACB  ld (0x60346f),0x01
	ldw	(6304880:24), 1	; F63AD1  ld (0x603470),0x0001
	ldw	(6304882:24), 1	; F63AD8  ld (0x603472),0x0001
	ld	(6304884:24), 1	; F63ADF  ld (0x603474),0x01
	ldw	(6304885:24), 1	; F63AE5  ld (0x603475),0x0001
	ld	(3606:16), 0	; F63AEC  ld (0x0e16),0x00
	ld	(6304945:24), 1	; F63AF1  ld (0x6034b1),0x01
	ldw	(6304946:24), 1	; F63AF7  ld (0x6034b2),0x0001
	ldw	(6304948:24), 1	; F63AFE  ld (0x6034b4),0x0001
	ld	(6304950:24), 0	; F63B05  ld (0x6034b6),0x00
	ld	(6304951:24), 0	; F63B0B  ld (0x6034b7),0x00
	ld	(6304956:24), 0	; F63B11  ld (0x6034bc),0x00
	ld	(6304957:24), 0	; F63B17  ld (0x6034bd),0x00
	ld	(6304887:24), 0	; F63B1D  ld (0x603477),0x00
	ldw	(6304888:24), 1	; F63B23  ld (0x603478),0x0001
	ldw	(6304890:24), 1	; F63B2A  ld (0x60347a),0x0001
	ld	(6304892:24), 2	; F63B31  ld (0x60347c),0x02
	ld	(3125:16), 0	; F63B37  ld (0x0c35),0x00
	ld	(3588:16), 100	; F63B3C  ld (0x0e04),0x64
	ld	(3589:16), 100	; F63B41  ld (0x0e05),0x64
	ldw	wa, 1	; F63B46  ld WA,0x0001
	ld	(3566:16), a	; F63B49  ld (0x0dee),A
	ld	(N0teChange_FromMeasure:16), wa	; F63B4D  ld (0x0df0),WA
	ld	(N0teChange_ToMeasure:16), wa	; F63B51  ld (0x0df2),WA
	ld	(3584:16), wa	; F63B55  ld (0x0e00),WA
	xor	a, a	; F63B59  xor A,A
	ld	(N0teChange_FromNote:16), a	; F63B5B  ld (0x0df4),A
	ld	(N0teChange_ToNote:16), a	; F63B5F  ld (0x0df5),A
	ld	wa, (N0teChange_ToMeasure:16)	; F63B63  ld WA,(0x0df2)
	sub	wa, (N0teChange_FromMeasure:16)	; F63B67  sub WA,(0x0df0)
	inc	1, wa	; F63B6B  inc 1,WA
	ld	(4766:16), wa	; F63B6D  ld (0x129e),WA
	ldw	wa, 1	; F63B71  ld WA,0x0001
	ld	(3575:16), a	; F63B74  ld (0x0df7),A
	ld	(3576:16), wa	; F63B78  ld (0x0df8),WA
	ld	(3578:16), wa	; F63B7C  ld (0x0dfa),WA
	xor	a, a	; F63B80  xor A,A
	ld	(3580:16), a	; F63B82  ld (0x0dfc),A
	ld	wa, (3578:16)	; F63B86  ld WA,(0x0dfa)
	sub	wa, (0x0df8:16)	; F63B8A  sub WA,(0x0df8)
	inc	1, wa	; F63B8E  inc 1,WA
	ld	(3584:16), wa	; F63B90  ld (0x0e00),WA
	ldw	wa, 1	; F63B94  ld WA,0x0001
	ld	(3558:16), a	; F63B97  ld (0x0de6),A
	ld	(3560:16), wa	; F63B9B  ld (0x0de8),WA
	ld	(3562:16), wa	; F63B9F  ld (0x0dea),WA
	ld	(3590:16), wa	; F63BA3  ld (0x0e06),WA
	xor	a, a	; F63BA7  xor A,A
	ld	(3564:16), a	; F63BA9  ld (0x0dec),A
	ret	; F63BAD  ret

; --------------------------------------------------------------------------
; BStore_SeekBlock -- point the cursor at block n
;
; Called from:
;   thunk slots T_BStore_SeekBlock
;   17 call sites inside the module:
;     0xF62CD4 0xF62DD2 0xF62DE2 0xF63073 0xF63082 0xF63341 0xF6335E 0xF633B2
;     0xF633CF 0xF634EE 0xF63512 0xF6354F 0xF635F8 0xF63913 0xF63A00 0xF63A3F
;     0xF64A41
;   (both lists are emitted by this script, not typed)
; Inputs:  HL = block number, 1-based.   Outputs: (0x126E) = its address.
; What it does: (0x126E) = (0x3604) + (HL-1) * 0x100.
; Evidence: the four instructions `dec 1,HL / extz XHL / sla 0x08,XHL /
;   add XHL,(0x3604)`.
; AND (0x3604) IS 0x00617800.  That is not read off here -- it is forced by
;   the INVERSE, which two other prom_b modules spell with a literal:
;     0xF5E2F0  ld XHL,(0x126E) / sub XHL,0x00617800 / srl 0x08,XHL / inc 1,HL
;     0xF61F1C  ld XHL,(0x0E1F) / ld (0x126E),XHL / sub XHL,0x00617800 /
;               sra 0x08,XHL / inc 1,HL
;   Both recover a 1-based block number from (0x126E); composing either with
;   this routine gives n back if and only if (0x3604) = 0x00617800.
;   notes/FINDINGS-memory-map.md already had `0x617800 + n*0x100 -- a 256-byte
;   record array' from 0xF61F5B; this identifies the array.
; --------------------------------------------------------------------------
BStore_SeekBlock:		; <- T_BStore_SeekBlock
	dec	1, hl	; F63BAE  dec 1,HL
	extz	xhl	; F63BB0  extz XHL
	sla	xhl, 8	; F63BB2  sla 0x08,XHL
	add	xhl, (BStore_HeapBase:16)	; F63BB5  add XHL,(0x3604)
	ld	(BStore_CursorBlockAddr:16), xhl	; F63BB9  ld (0x126e),XHL
	xor	xhl, xhl	; F63BBD  xor XHL,XHL
	ret	; F63BBF  ret

; --------------------------------------------------------------------------
; BStore_CopyAcrossBlocks -- ldir between two blocks, by block number
;
; Called from:
;   thunk slots T_BStore_CopyAcrossBlocks
;   13 call sites inside the module:
;     0xF62C5E 0xF62E5B 0xF62E78 0xF62E8D 0xF62EC3 0xF62EF1 0xF62F52 0xF62F67
;     0xF62F84 0xF62F99 0xF62FD5 0xF62FDE 0xF62FF6
;   (both lists are emitted by this script, not typed)
; Inputs:  BC = byte count; IX = offset in the destination block; IY = offset
;   in the source block; (0x0C59) = destination block address, (0x0C63) =
;   source block address.  Returns at once when BC = 0.
; Evidence: `extz XIX / extz XIY / add XIY,XHL / add XIX,XDE / ldir` with
;   XHL = (0x0C63) and XDE = (0x0C59), then both bases subtracted again so the
;   caller's offsets survive.  TLCS-900 `ldir` copies (XIX)+ <- (XIY)+ --
;   ../mame/src/devices/cpu/tlcs900/900tbl.hxx:2483 writes through p1 and reads
;   p2, and :5437-5438 set p1 = reg(op-1) = XIX and p2 = reg(op) = XIY for the
;   0x85 prefix.  So (0x0C59) is the DESTINATION.
;   0xF62DC9 sets them: (0x0C63) from block (0x0C61), (0x0C59) from block
;   (0x0C57).
; --------------------------------------------------------------------------
BStore_CopyAcrossBlocks:		; <- T_BStore_CopyAcrossBlocks
	pushw	wa	; F63BC0  push WA
	push	xde	; F63BC1  push XDE
	push	xhl	; F63BC2  push XHL
	cp	bc, 0:i3	; F63BC3  cp BC,0
	jr	z, BStore_CopyAcrossBlocks_Epilogue	; F63BC5  jr Z,0xf63be1
	ld	xhl, (BStore_CopySrcAddr:16)	; F63BC7  ld XHL,(0x0c63)
	ld	xde, (BStore_CopyDestAddr:16)	; F63BCB  ld XDE,(0x0c59)
	extz	xix	; F63BCF  extz XIX
	extz	xiy	; F63BD1  extz XIY
	add	xiy, xhl	; F63BD3  add XIY,XHL
	add	xix, xde	; F63BD5  add XIX,XDE
	ldir85	; F63BD7  ldir
	sub	xiy, (BStore_CopySrcAddr:16)	; F63BD9  sub XIY,(0x0c63)
	sub	xix, (BStore_CopyDestAddr:16)	; F63BDD  sub XIX,(0x0c59)
BStore_CopyAcrossBlocks_Epilogue:
	pop	xhl	; F63BE1  pop XHL
	pop	xde	; F63BE2  pop XDE
	popw	wa	; F63BE3  pop WA
	ret	; F63BE4  ret

; --------------------------------------------------------------------------
; BStore_LoadGeometry -- copy the store's geometry into the 0x0Cxx page
;
; Called from:
;   thunk slots T_BStore_LoadGeometry
;   3 call sites inside the module:
;     0xF62C20 0xF63C10 0xF63C46
;   (both lists are emitted by this script, not typed)
; What it does: (0x0CA2) = 0x11; (0x0CA4) = (0x3608) (the block COUNT);
;   (0x0CA6) = (0x3604) (the block store BASE); (0x0CA3) = 0x10.
; Evidence: six instructions, all immediates or direct moves.
;   (0x0CA4) being the block count is what makes the `cp WA,(0x0CA4)` bounds
;   checks in BStore_CursorAdvance and BStore_OpenChain range checks.
; Unknown: what 0x11 and 0x10 are.  0x10 is used as a loop bound over the
;   16-byte array at 0x00603422 (0xF63620 `cp L,(0x0CA3)`), so 0x10 = 16
;   entries there; 0x11 has no established use.
; --------------------------------------------------------------------------
BStore_LoadGeometry:		; <- T_BStore_LoadGeometry
	push	xiy	; F63BE5  push XIY
	ld	(3234:16), 17	; F63BE6  ld (0x0ca2),0x11
	ld	iy, (BStore_BlockCount:16)	; F63BEB  ld IY,(0x3608)
	ld	(BStore_BlockLimit:16), iy	; F63BEF  ld (0x0ca4),IY
	ld	xiy, (BStore_HeapBase:16)	; F63BF3  ld XIY,(0x3604)
	ld	(BStore_GeomBase:16), xiy	; F63BF7  ld (0x0ca6),XIY
	ld	(3235:16), 16	; F63BFB  ld (0x0ca3),0x10
	pop	xiy	; F63C00  pop XIY
	ret	; F63C01  ret
sub_F63C02:		; <- T_F427C8
	nop	; F63C02  nop
	nop	; F63C03  nop
	nop	; F63C04  nop
	ret	; F63C05  ret
; TrackMerge_RewriteSource2ForPart: TRACK MERGE's part fix-up, reached only through T_TrackMerge_RewriteSource2ForPart when the two sources play
;   different parts: with track (0x0C83) (= source 2 - 1) in 0..16, rewrites that track from measure 1 for the part in
;   (0x0D44) (= source 1's part, set by the caller) with BStore_RewriteTrackForPart, then T_F40A1C; (0x0D45) bits 0-1
;   cleared before and after. BStore_ApplyTrackPartChange without its range check, rewind and BStore_Map32 lookup.
;   Basis: caller + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
TrackMerge_RewriteSource2ForPart:		; <- T_TrackMerge_RewriteSource2ForPart
	ld	(BStore_ErrorCode:16), 0	; F63C06  ld (0x0d4a),0x00
	and	(0x0d45:16), 0xfc	; F63C0B  and (0x0d45),0xfc
	calr	BStore_LoadGeometry	; F63C10  calr 0xf63be5
	ld	a, (3203:16)	; F63C13  ld A,(0x0c83)
	cp	a, 16	; F63C17  cp A,0x10
	jr	ugt, sub_F63C02_Skip	; F63C1A  jr UGT,0xf63c37
	cp	a, 0:i3	; F63C1C  cp A,0
	jr	c, sub_F63C02_Skip	; F63C1E  jr C,0xf63c37
	xor	hl, hl	; F63C20  xor HL,HL
	ld	l, (3184:16)	; F63C22  ld L,(0x0c70)
	dec	1, l	; F63C26  dec 1,L
	ld	l, (3185:16)	; F63C28  ld L,(0x0c71)
	dec	1, l	; F63C2C  dec 1,L
	ld	a, (3203:16)	; F63C2E  ld A,(0x0c83)
	inc	1, a	; F63C32  inc 1,A
	calr	BStore_RewriteTrackForPart	; F63C34  calr 0xf63ce0
sub_F63C02_Skip:
	call	T_F40A1C	; F63C37  call 0xf40a1c
	and	(0x0d45:16), 0xfc	; F63C3B  and (0x0d45),0xfc
	ret	; F63C40  ret
; BStore_ApplyTrackPartChange: After TRACK ASSIGN moved track (0x0C83) from part (0x0C06) to
;   BStore_TrackToPart[(0x0C83)]: when both are in range and differ, (0x0D44) := BStore_Map32[new part], requests a
;   rewind (T_Seq_RequestRewind) and rewrites the track's stream from measure 1 for the new part (BStore_RewriteTrackForPart); then
;   BStore_ResetWorkspaceFields. Reached by T_BStore_Veneers -> F62C00 -> F62C66 stub. Basis: callers + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
BStore_ApplyTrackPartChange:		; <- T_BStore_ApplyTrackPartChange
	and	(0x0d45:16), 0xfc	; F63C41  and (0x0d45),0xfc
	calr	BStore_LoadGeometry	; F63C46  calr 0xf63be5
	ld	a, (3203:16)	; F63C49  ld A,(0x0c83)
	cp	a, 16	; F63C4D  cp A,0x10
	jr	ugt, BStore_ApplyTrackPartChange_Skip	; F63C50  jr UGT,0xf63cb6
	ld	a, (3078:16)	; F63C52  ld A,(0x0c06)
	cp	a, 31	; F63C56  cp A,0x1f
	jr	ugt, BStore_ApplyTrackPartChange_Skip	; F63C59  jr UGT,0xf63cb6
	ld	(BStore_ErrorCode:16), 0	; F63C5B  ld (0x0d4a),0x00
	and	(0x0c8a:16), 0xbf	; F63C60  and (0x0c8a),0xbf
	xor	hl, hl	; F63C65  xor HL,HL
	ld	l, (3203:16)	; F63C67  ld L,(0x0c83)
	push	xde	; F63C6B  push XDE
	ld	xde, BStore_TrackToPart	; F63C6C  ld XDE,0x00603422
	ld	a, (xde+hl)	; F63C71  ld A,(XDE+HL)
	pop	xde	; F63C76  pop XDE
	cp	a, (0x0c06:16)	; F63C77  cp A,(0x0c06)
	jr	z, BStore_ApplyTrackPartChange_Skip	; F63C7B  jr Z,0xf63cb6
	ld	l, (3203:16)	; F63C7D  ld L,(0x0c83)
	xor	h, h	; F63C81  xor H,H
	push	xde	; F63C83  push XDE
	ld	xde, BStore_TrackToPart	; F63C84  ld XDE,0x00603422
	ld	l, (xde+hl)	; F63C89  ld L,(XDE+HL)
	pop	xde	; F63C8E  pop XDE
	xor	h, h	; F63C8F  xor H,H
	push	xde	; F63C91  push XDE
	ld	xde, BStore_Map32	; F63C92  ld XDE,0x00f63cc0
	ld	l, (xde+hl)	; F63C97  ld L,(XDE+HL)
	pop	xde	; F63C9C  pop XDE
	cp	l, 255	; F63C9D  cp L,0xff
	jr	z, BStore_ApplyTrackPartChange_Skip	; F63CA0  jr Z,0xf63cb6
	ld	(3396:16), l	; F63CA2  ld (0x0d44),L
	ld	a, (3203:16)	; F63CA6  ld A,(0x0c83)
	inc	1, a	; F63CAA  inc 1,A
	pushw	wa	; F63CAC  push WA
	call	T_Seq_RequestRewind	; F63CAD  call 0xf409e0
	popw	wa	; F63CB1  pop WA
	call	BStore_RewriteTrackForPart	; F63CB2  call 0xf63ce0
BStore_ApplyTrackPartChange_Skip:
	call	T_F40A1C	; F63CB6  call 0xf40a1c
	and	(0x0d45:16), 0xfc	; F63CBA  and (0x0d45),0xfc
	ret	; F63CBF  ret

; --- BStore_Map32: 32 bytes at 0xF63CC0 ---
;     32 bytes, the identity map 0x00..0x1F.  Read as `ld L,(0x00F63CC0+L)` at
;     0xF63C97 and 0xF64040, in both cases with L already fetched from the
;     16-byte array at 0x00603422, and in both cases the result is tested
;     against 0xFF and the operation skipped when it matches.  No entry IS
;     0xFF, so in this firmware the map skips nothing; that is a fact about
;     these 32 bytes, not a claim about the design.
;     Evidence: the bytes above, re-asserted by assert_data_islands() in
;     notes/gen_prom_b_blockstore_module.py before this text can be emitted.
;     The literal 0x00F63CC0 appears 2 times in CPU 1's two ROMs, counted by
;     addr_sites() at EVERY byte offset: prom_b 0xF63C93, 0xF6403C.  Those are
;     the addresses of the LITERAL, which is one or more bytes PAST the start
;     of the instruction carrying it -- the instruction addresses in the
;     paragraph above are not the same numbers and are not meant to be.
BStore_Map32:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; +0x00
	.byte	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F	; +0x10
; BStore_RewriteTrackForPart: Rewrites track A in place from measure 1 for a new part (read cursor IY, write cursor IX
;   via T_BStore_WriteCursorAdvance_Call): keeps 0x80/0x81/0x85/0x86/0xD3 marks, 0x9n notes and (unless (0x0D45) bit 0) 0xD1/0xD2, gives kept
;   0xCn records byte 2 := (0x0D44), filters/rewrites 0xBn via sub_F63F88, drops the rest; ends 0x82, save cursor,
;   truncate. BStore_ApplyTrackPartChange (header: rewrites the track's stream for the new part) and
;   TrackMerge_RewriteSource2ForPart call it. Basis: callers + caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_t.json)
BStore_RewriteTrackForPart:
	and	(0x0c8a:16), 0xfb	; F63CE0  and (0x0c8a),0xfb
	xor	w, w	; F63CE5  xor W,W
	ld	(BStore_ErrorCode:16), 0	; F63CE7  ld (0x0d4a),0x00
	ld	(3354:16), wa	; F63CEC  ld (0x0d1a),WA
	ldw	(3216:16), 1	; F63CF0  ld (0x0c90),0x0001
	calr	BStore_SeekMeasure	; F63CF6  calr 0xf62cfe
	cp	(BStore_ErrorCode:16), 0x00	; F63CF9  cp (0x0d4a),0x00
	jr	z, BStore_RewriteTrackForPart_Skip	; F63CFE  jr Z,0xf63d03
	jrl	sub_F63CE0_Return	; F63D00  jrl T,0xf63f87
BStore_RewriteTrackForPart_Skip:
	push	xhl	; F63D03  push XHL
	ld	xhl, (BStore_CursorBlockAddr:16)	; F63D04  ld XHL,(0x126e)
	ld	(3254:16), xhl	; F63D08  ld (0x0cb6),XHL
	pop	xhl	; F63D0C  pop XHL
	ld	(3258:16), iy	; F63D0D  ld (0x0cba),IY
	ld	wa, (BStore_CursorBlock:16)	; F63D11  ld WA,(0x345c)
	ld	(3252:16), wa	; F63D15  ld (0x0cb4),WA
	ld	(3262:16), iy	; F63D19  ld (0x0cbe),IY
	ld	(3260:16), wa	; F63D1D  ld (0x0cbc),WA
	ld	ix, iy	; F63D21  ld IX,IY
BStore_RewriteTrackForPart_Loop:
	push	xde	; F63D23  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F63D24  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F63D28  ld A,(XDE+IY)
	pop	xde	; F63D2D  pop XDE
	cp	a, 130	; F63D2E  cp A,0x82
	jrl	z, sub_F63CE0_Skip16	; F63D31  jrl Z,0xf63f6e
	cp	a, 129	; F63D34  cp A,0x81
	jr	z, BStore_RewriteTrackForPart_Loop3	; F63D37  jr Z,0xf63d83
	cp	a, 128	; F63D39  cp A,0x80
	jr	z, BStore_RewriteTrackForPart_Loop3	; F63D3C  jr Z,0xf63d83
	cp	a, 210	; F63D3E  cp A,0xd2
	jr	z, BStore_RewriteTrackForPart_Skip2	; F63D41  jr Z,0xf63d7d
	cp	a, 209	; F63D43  cp A,0xd1
	jr	z, BStore_RewriteTrackForPart_Skip2	; F63D46  jr Z,0xf63d7d
	cp	a, 133	; F63D48  cp A,0x85
	jr	z, BStore_RewriteTrackForPart_Loop3	; F63D4B  jr Z,0xf63d83
	cp	a, 134	; F63D4D  cp A,0x86
	jr	z, BStore_RewriteTrackForPart_Loop3	; F63D50  jr Z,0xf63d83
	cp	a, 211	; F63D52  cp A,0xd3
	jr	z, BStore_RewriteTrackForPart_Loop3	; F63D55  jr Z,0xf63d83
	ld	(4696:16), a	; F63D57  ld (0x1258),A
	ld	w, 240:opc	; F63D5B  ld W,0xf0
	and	w, a	; F63D5D  and W,A
	cp	w, 144	; F63D5F  cp W,0x90
	jr	z, BStore_RewriteTrackForPart_Loop3	; F63D62  jr Z,0xf63d83
	cp	w, 192	; F63D64  cp W,0xc0
	jr	z, sub_F63CE0_Entry	; F63D67  jr Z,0xf63dc1
	cp	w, 176	; F63D69  cp W,0xb0
	jrl	z, sub_F63CE0_Skip4	; F63D6C  jrl Z,0xf63e4a
BStore_RewriteTrackForPart_Loop2:
	call	T_BStore_ReadCursorAdvance_Call	; F63D6F  call 0xf4270c
	cp	(BStore_ErrorCode:16), 0x00	; F63D73  cp (0x0d4a),0x00
	jr	z, BStore_RewriteTrackForPart_Loop	; F63D78  jr Z,0xf63d23
	jrl	sub_F63CE0_Return	; F63D7A  jrl T,0xf63f87
BStore_RewriteTrackForPart_Skip2:
	bit	0, (0x0d45:16)	; F63D7D  bit 0,(0x0d45)
	jr	nz, BStore_RewriteTrackForPart_Loop2	; F63D81  jr NZ,0xf63d6f
BStore_RewriteTrackForPart_Loop3:
	push	xhl	; F63D83  push XHL
	ld	xhl, (3254:16)	; F63D84  ld XHL,(0x0cb6)
	ld	(xhl+ix), a	; F63D88  ld (XHL+IX),A
	pop	xhl	; F63D8D  pop XHL
	call	T_BStore_WriteCursorAdvance_Call	; F63D8E  call 0xf42710
	cp	(BStore_ErrorCode:16), 0x00	; F63D92  cp (0x0d4a),0x00
	jrl	nz, sub_F63CE0_Return	; F63D97  jrl NZ,0xf63f87
	call	T_BStore_ReadCursorAdvance_Call	; F63D9A  call 0xf4270c
	cp	(BStore_ErrorCode:16), 0x00	; F63D9E  cp (0x0d4a),0x00
	jrl	nz, sub_F63CE0_Return	; F63DA3  jrl NZ,0xf63f87
	push	xde	; F63DA6  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F63DA7  ld XDE,(0x126e)
	bit	7, (xde+iy)	; F63DAB  bit 7,(XDE+IY)
	pop	xde	; F63DB0  pop XDE
	jrl	nz, BStore_RewriteTrackForPart_Loop	; F63DB1  jrl NZ,0xf63d23
	push	xde	; F63DB4  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F63DB5  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F63DB9  ld A,(XDE+IY)
	pop	xde	; F63DBE  pop XDE
	jr	BStore_RewriteTrackForPart_Loop3	; F63DBF  jr T,0xf63d83
sub_F63CE0_Entry:
	ldfr_berp	a, 0x3c	; F63DC1  ld RL3,A
	ld	a, (3397:16)	; F63DC4  ld A,(0x0d45)
	and	a, 3	; F63DC8  and A,0x03
	ldto_berp	a, 0x3c	; F63DCB  ld A,RL3
	jr	nz, BStore_RewriteTrackForPart_Loop2	; F63DCE  jr NZ,0xf63d6f
	push	xiz	; F63DD0  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F63DD1  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F63DD5  ld XDE3,XIZ
	pop	xiz	; F63DD8  pop XIZ
	push_lerp	0x38	; F63DD9  push XDE3
	pushw	wa	; F63DDC  push WA
	push	xiy	; F63DDD  push XIY
	pushw	(0x0cbc:16)	; F63DDE  pushw (0x0cbc)
	calr	sub_F6411C	; F63DE2  calr 0xf6411c
	popw	(0x0cbc:16)	; F63DE5  popw (0x0cbc)
	pop	xiy	; F63DE9  pop XIY
	popw	wa	; F63DEA  pop WA
	pop_lerp	0x38	; F63DEB  pop XDE3
	push	xiz	; F63DEE  push XIZ
	ldto_lerp	xiz, 0x38	; F63DEF  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F63DF2  ld (0x126e),XIZ
	pop	xiz	; F63DF6  pop XIZ
	cp	l, 0:i3	; F63DF7  cp L,0
	jrl	nz, BStore_RewriteTrackForPart_Loop2	; F63DF9  jrl NZ,0xf63d6f
	xor	c, c	; F63DFC  xor C,C
sub_F63CE0_Join:
	cp	c, 2:i3	; F63DFE  cp C,2
	jr	nz, sub_F63CE0_Skip3	; F63E00  jr NZ,0xf63e06
	ld	a, (3396:16)	; F63E02  ld A,(0x0d44)
sub_F63CE0_Skip3:
	push	xhl	; F63E06  push XHL
	ld	xhl, (3254:16)	; F63E07  ld XHL,(0x0cb6)
	ld	(xhl+ix), a	; F63E0B  ld (XHL+IX),A
	pop	xhl	; F63E10  pop XHL
	pushw	bc	; F63E11  push BC
	call	T_BStore_WriteCursorAdvance_Call	; F63E12  call 0xf42710
	popw	bc	; F63E16  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F63E17  cp (0x0d4a),0x00
	jrl	nz, sub_F63CE0_Return	; F63E1C  jrl NZ,0xf63f87
	pushw	bc	; F63E1F  push BC
	call	T_BStore_ReadCursorAdvance_Call	; F63E20  call 0xf4270c
	popw	bc	; F63E24  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F63E25  cp (0x0d4a),0x00
	jrl	nz, sub_F63CE0_Return	; F63E2A  jrl NZ,0xf63f87
	inc	1, c	; F63E2D  inc 1,C
	push	xde	; F63E2F  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F63E30  ld XDE,(0x126e)
	bit	7, (xde+iy)	; F63E34  bit 7,(XDE+IY)
	pop	xde	; F63E39  pop XDE
	jrl	nz, BStore_RewriteTrackForPart_Loop	; F63E3A  jrl NZ,0xf63d23
	push	xde	; F63E3D  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F63E3E  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F63E42  ld A,(XDE+IY)
	pop	xde	; F63E47  pop XDE
	jr	sub_F63CE0_Join	; F63E48  jr T,0xf63dfe
sub_F63CE0_Skip4:
	ld	(3401:16), a	; F63E4A  ld (0x0d49),A
	and	(0x0d49:16), 0x02	; F63E4E  and (0x0d49),0x02
	ldib_erp	60, 6	; F63E53  ld RL3,6
	sla	(0x0d49:16)	; F63E56  sla (0x0d49)
	.byte 0xC7, 0x3C, 0x1C, 0xF8	; F63E5A  djnz RL3,0xf63e56   [llvm-mc cannot encode this]
	push	xiz	; F63E5E  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F63E5F  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F63E63  ld XDE3,XIZ
	pop	xiz	; F63E66  pop XIZ
	push_lerp	0x38	; F63E67  push XDE3
	pushw	wa	; F63E6A  push WA
	push	xiy	; F63E6B  push XIY
	pushw	(0x0cbc:16)	; F63E6C  pushw (0x0cbc)
	calr	sub_F63F88	; F63E70  calr 0xf63f88
	popw	(0x0cbc:16)	; F63E73  popw (0x0cbc)
	pop	xiy	; F63E77  pop XIY
	popw	wa	; F63E78  pop WA
	pop_lerp	0x38	; F63E79  pop XDE3
	push	xiz	; F63E7C  push XIZ
	ldto_lerp	xiz, 0x38	; F63E7D  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F63E80  ld (0x126e),XIZ
	pop	xiz	; F63E84  pop XIZ
	cp	(BStore_ErrorCode:16), 0x00	; F63E85  cp (0x0d4a),0x00
	jrl	nz, sub_F63CE0_Return	; F63E8A  jrl NZ,0xf63f87
	bit	0, (0x0d46:16)	; F63E8D  bit 0,(0x0d46)
	jr	nz, sub_F63CE0_Skip5	; F63E91  jr NZ,0xf63e9d
	bit	2, (0x0d46:16)	; F63E93  bit 2,(0x0d46)
	jrl	nz, BStore_RewriteTrackForPart_Loop3	; F63E97  jrl NZ,0xf63d83
	jrl	BStore_RewriteTrackForPart_Loop2	; F63E9A  jrl T,0xf63d6f
sub_F63CE0_Skip5:
	xor	c, c	; F63E9D  xor C,C
sub_F63CE0_Join2:
	cp	c, 0:i3	; F63E9F  cp C,0
	jr	nz, sub_F63CE0_Skip6	; F63EA1  jr NZ,0xf63ea6
	jrl	sub_F63CE0_Join3	; F63EA3  jrl T,0xf63f2b
sub_F63CE0_Skip6:
	cp	c, 2:i3	; F63EA6  cp C,2
	jr	nz, sub_F63CE0_Skip14	; F63EA8  jr NZ,0xf63f12
	ld	a, (3396:16)	; F63EAA  ld A,(0x0d44)
	cp	(0x1258:16), 0xb5	; F63EAE  cp (0x1258),0xb5
	jr	z, sub_F63CE0_Skip7	; F63EB3  jr Z,0xf63ee1
	cp	(0x1258:16), 0xbc	; F63EB5  cp (0x1258),0xbc
	jr	z, sub_F63CE0_Skip8	; F63EBA  jr Z,0xf63ee8
	cp	(0x1258:16), 0xbd	; F63EBC  cp (0x1258),0xbd
	jr	z, sub_F63CE0_Skip9	; F63EC1  jr Z,0xf63eef
	cp	(0x1258:16), 0xb8	; F63EC3  cp (0x1258),0xb8
	jr	z, sub_F63CE0_Skip10	; F63EC8  jr Z,0xf63ef6
	cp	(0x1258:16), 0xb9	; F63ECA  cp (0x1258),0xb9
	jr	z, sub_F63CE0_Skip11	; F63ECF  jr Z,0xf63efd
	cp	(0x1258:16), 0xba	; F63ED1  cp (0x1258),0xba
	jr	z, sub_F63CE0_Skip12	; F63ED6  jr Z,0xf63f04
	cp	(0x1258:16), 0xbb	; F63ED8  cp (0x1258),0xbb
	jr	z, sub_F63CE0_Skip13	; F63EDD  jr Z,0xf63f0b
	jr	sub_F63CE0_Join3	; F63EDF  jr T,0xf63f2b
sub_F63CE0_Skip7:
	ld	a, 181:opc	; F63EE1  ld A,0xb5
	and	a, 127	; F63EE3  and A,0x7f
	jr	sub_F63CE0_Join3	; F63EE6  jr T,0xf63f2b
sub_F63CE0_Skip8:
	ld	a, 188:opc	; F63EE8  ld A,0xbc
	and	a, 127	; F63EEA  and A,0x7f
	jr	sub_F63CE0_Join3	; F63EED  jr T,0xf63f2b
sub_F63CE0_Skip9:
	ld	a, 189:opc	; F63EEF  ld A,0xbd
	and	a, 127	; F63EF1  and A,0x7f
	jr	sub_F63CE0_Join3	; F63EF4  jr T,0xf63f2b
sub_F63CE0_Skip10:
	ld	a, 184:opc	; F63EF6  ld A,0xb8
	and	a, 127	; F63EF8  and A,0x7f
	jr	sub_F63CE0_Join3	; F63EFB  jr T,0xf63f2b
sub_F63CE0_Skip11:
	ld	a, 185:opc	; F63EFD  ld A,0xb9
	and	a, 127	; F63EFF  and A,0x7f
	jr	sub_F63CE0_Join3	; F63F02  jr T,0xf63f2b
sub_F63CE0_Skip12:
	ld	a, 186:opc	; F63F04  ld A,0xba
	and	a, 127	; F63F06  and A,0x7f
	jr	sub_F63CE0_Join3	; F63F09  jr T,0xf63f2b
sub_F63CE0_Skip13:
	ld	a, 187:opc	; F63F0B  ld A,0xbb
	and	a, 127	; F63F0D  and A,0x7f
	jr	sub_F63CE0_Join3	; F63F10  jr T,0xf63f2b
sub_F63CE0_Skip14:
	cp	c, 3:i3	; F63F12  cp C,3
	jr	nz, sub_F63CE0_Skip15	; F63F14  jr NZ,0xf63f1c
	ld	a, (3537:16)	; F63F16  ld A,(0x0dd1)
	jr	sub_F63CE0_Join3	; F63F1A  jr T,0xf63f2b
sub_F63CE0_Skip15:
	cp	c, 4:i3	; F63F1C  cp C,4
	jr	nz, sub_F63CE0_Join3	; F63F1E  jr NZ,0xf63f2b
	cp	(0x0dd0:16), 0xff	; F63F20  cp (0x0dd0),0xff
	jr	z, sub_F63CE0_Join3	; F63F25  jr Z,0xf63f2b
	ld	a, (3536:16)	; F63F27  ld A,(0x0dd0)
sub_F63CE0_Join3:
	push	xhl	; F63F2B  push XHL
	ld	xhl, (3254:16)	; F63F2C  ld XHL,(0x0cb6)
	ld	(xhl+ix), a	; F63F30  ld (XHL+IX),A
	pop	xhl	; F63F35  pop XHL
	pushw	bc	; F63F36  push BC
	call	T_BStore_WriteCursorAdvance_Call	; F63F37  call 0xf42710
	popw	bc	; F63F3B  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F63F3C  cp (0x0d4a),0x00
	jr	nz, sub_F63CE0_Return	; F63F41  jr NZ,0xf63f87
	pushw	bc	; F63F43  push BC
	call	T_BStore_ReadCursorAdvance_Call	; F63F44  call 0xf4270c
	popw	bc	; F63F48  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F63F49  cp (0x0d4a),0x00
	jr	nz, sub_F63CE0_Return	; F63F4E  jr NZ,0xf63f87
	inc	1, c	; F63F50  inc 1,C
	push	xde	; F63F52  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F63F53  ld XDE,(0x126e)
	bit	7, (xde+iy)	; F63F57  bit 7,(XDE+IY)
	pop	xde	; F63F5C  pop XDE
	jrl	nz, BStore_RewriteTrackForPart_Loop	; F63F5D  jrl NZ,0xf63d23
	push	xde	; F63F60  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F63F61  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F63F65  ld A,(XDE+IY)
	pop	xde	; F63F6A  pop XDE
	jrl	sub_F63CE0_Join2	; F63F6B  jrl T,0xf63e9f
sub_F63CE0_Skip16:
	push	xhl	; F63F6E  push XHL
	ld	xhl, (3254:16)	; F63F6F  ld XHL,(0x0cb6)
	ld	(xhl+ix), a	; F63F73  ld (XHL+IX),A
	pop	xhl	; F63F78  pop XHL
	ld	wa, (3252:16)	; F63F79  ld WA,(0x0cb4)
	ld	(3159:16), wa	; F63F7D  ld (0x0c57),WA
	calr	BStore_SaveCursor	; F63F81  calr 0xf63924
	calr	BStore_TruncateChainAfterBlock	; F63F84  calr 0xf63510
sub_F63CE0_Return:
	ret	; F63F87  ret
sub_F63F88:
	ld	a, (3078:16)	; F63F88  ld A,(0x0c06)
	ld	(3508:16), a	; F63F8C  ld (0x0db4),A
sub_F63F90:
	call	T_BStore_ReadCursorAdvance_Call	; F63F90  call 0xf4270c
	cp	(BStore_ErrorCode:16), 0x00	; F63F94  cp (0x0d4a),0x00
	jrl	nz, sub_F63F90_Return	; F63F99  jrl NZ,0xf6411b
	call	T_BStore_ReadCursorAdvance_Call	; F63F9C  call 0xf4270c
	cp	(BStore_ErrorCode:16), 0x00	; F63FA0  cp (0x0d4a),0x00
	jrl	nz, sub_F63F90_Return	; F63FA5  jrl NZ,0xf6411b
	ld	(3536:16), 255	; F63FA8  ld (0x0dd0),0xff
	push	xde	; F63FAD  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F63FAE  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F63FB2  ld A,(XDE+IY)
	pop	xde	; F63FB7  pop XDE
	and	a, 127	; F63FB8  and A,0x7f
	cp	a, 72	; F63FBB  cp A,0x48
	jrl	z, sub_F63F90_Skip3	; F63FBE  jrl Z,0xf6409b
	and	(0x0d46:16), 0xfb	; F63FC1  and (0x0d46),0xfb
	ld	l, (3078:16)	; F63FC6  ld L,(0x0c06)
	ld	l, (3078:16)	; F63FCA  ld L,(0x0c06)
	push	xde	; F63FCE  push XDE
	ld	e, a	; F63FCF  ld E,A
	ld	d, (4696:16)	; F63FD1  ld D,(0x1258)
	and	d, 4	; F63FD5  and D,0x04
	sla	d, 5	; F63FD8  sla 0x05,D
	or	e, d	; F63FDB  or E,D
	ld	(4696:16), e	; F63FDD  ld (0x1258),E
	ld	a, e	; F63FE1  ld A,E
	pop	xde	; F63FE3  pop XDE
	cp	(0x1258:16), 0xb5	; F63FE4  cp (0x1258),0xb5
	jr	z, sub_F63F90_Skip	; F63FE9  jr Z,0xf64015
	cp	(0x1258:16), 0xbc	; F63FEB  cp (0x1258),0xbc
	jr	z, sub_F63F90_Skip	; F63FF0  jr Z,0xf64015
	cp	(0x1258:16), 0xbd	; F63FF2  cp (0x1258),0xbd
	jr	z, sub_F63F90_Skip	; F63FF7  jr Z,0xf64015
	cp	(0x1258:16), 0xb8	; F63FF9  cp (0x1258),0xb8
	jr	z, sub_F63F90_Skip	; F63FFE  jr Z,0xf64015
	cp	(0x1258:16), 0xb9	; F64000  cp (0x1258),0xb9
	jr	z, sub_F63F90_Skip	; F64005  jr Z,0xf64015
	cp	(0x1258:16), 0xba	; F64007  cp (0x1258),0xba
	jr	z, sub_F63F90_Skip	; F6400C  jr Z,0xf64015
	cp	(0x1258:16), 0xbb	; F6400E  cp (0x1258),0xbb
	jr	nz, sub_F63F90_Skip2	; F64013  jr NZ,0xf64038
sub_F63F90_Skip:
	xor	hl, hl	; F64015  xor HL,HL
	ld	l, (3203:16)	; F64017  ld L,(0x0c83)
	push	xde	; F6401B  push XDE
	ld	xde, BStore_TrackToPart	; F6401C  ld XDE,0x00603422
	ld	l, (xde+hl)	; F64021  ld L,(XDE+HL)
	pop	xde	; F64026  pop XDE
	ld	(3537:16), l	; F64027  ld (0x0dd1),L
	or	(0x0d46:16), 0x01	; F6402B  or (0x0d46),0x01
	and	(0x0dd2:16), 0xfe	; F64030  and (0x0dd2),0xfe
	jrl	sub_F63F90_Return	; F64035  jrl T,0xf6411b
sub_F63F90_Skip2:
	xor	h, h	; F64038  xor H,H
	push	xde	; F6403A  push XDE
	ld	xde, BStore_Map32	; F6403B  ld XDE,0x00f63cc0
	ld	l, (xde+hl)	; F64040  ld L,(XDE+HL)
	pop	xde	; F64045  pop XDE
	cp	a, l	; F64046  cp A,L
	jr	nz, sub_F63F90_Loop	; F64048  jr NZ,0xf64090
	call	T_BStore_ReadCursorAdvance_Call	; F6404A  call 0xf4270c
	cp	(BStore_ErrorCode:16), 0x00	; F6404E  cp (0x0d4a),0x00
	jrl	nz, sub_F63F90_Return	; F64053  jrl NZ,0xf6411b
	push	xde	; F64056  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F64057  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F6405B  ld A,(XDE+IY)
	pop	xde	; F64060  pop XDE
	cp	a, 3:i3	; F64061  cp A,3
	jr	c, sub_F63F90_Loop	; F64063  jr C,0xf64090
	cp	a, 11	; F64065  cp A,0x0b
	jr	ugt, sub_F63F90_Loop	; F64068  jr UGT,0xf64090
	ldfr_berp	a, 0x3c	; F6406A  ld RL3,A
	ld	a, (3397:16)	; F6406D  ld A,(0x0d45)
	and	a, 3	; F64071  and A,0x03
	ldto_berp	a, 0x3c	; F64074  ld A,RL3
	jr	z, sub_F63F90_Join	; F64077  jr Z,0xf6407f
	ld	c, 3:opc	; F64079  ld C,0x03
	cp	a, c	; F6407B  cp A,C
	jr	nz, sub_F63F90_Loop	; F6407D  jr NZ,0xf64090
sub_F63F90_Join:
	or	(0x0d46:16), 0x01	; F6407F  or (0x0d46),0x01
	and	(0x0dd2:16), 0xfe	; F64084  and (0x0dd2),0xfe
	ld	(3537:16), a	; F64089  ld (0x0dd1),A
	jrl	sub_F63F90_Return	; F6408D  jrl T,0xf6411b
sub_F63F90_Loop:
	and	(0x0d46:16), 0xfa	; F64090  and (0x0d46),0xfa
	jrl	sub_F63F90_Return	; F64095  jrl T,0xf6411b
	jrl	sub_F63F90_Return	; F64098  jrl T,0xf6411b
sub_F63F90_Skip3:
	call	T_BStore_ReadCursorAdvance_Call	; F6409B  call 0xf4270c
	cp	(BStore_ErrorCode:16), 0x00	; F6409F  cp (0x0d4a),0x00
	jrl	nz, sub_F63F90_Return	; F640A4  jrl NZ,0xf6411b
	push	xde	; F640A7  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F640A8  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F640AC  ld A,(XDE+IY)
	pop	xde	; F640B1  pop XDE
	cp	a, 5:i3	; F640B2  cp A,5
	jr	nz, sub_F63F90_Skip5	; F640B4  jr NZ,0xf640fc
	and	(0x0d46:16), 0xfe	; F640B6  and (0x0d46),0xfe
	call	T_BStore_ReadCursorAdvance_Call	; F640BB  call 0xf4270c
	cp	(BStore_ErrorCode:16), 0x00	; F640BF  cp (0x0d4a),0x00
	jr	nz, sub_F63F90_Return	; F640C4  jr NZ,0xf6411b
	call	T_BStore_ReadCursorAdvance_Call	; F640C6  call 0xf4270c
	cp	(BStore_ErrorCode:16), 0x00	; F640CA  cp (0x0d4a),0x00
	jr	nz, sub_F63F90_Return	; F640CF  jr NZ,0xf6411b
	push	xde	; F640D1  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F640D2  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F640D6  ld A,(XDE+IY)
	pop	xde	; F640DB  pop XDE
	and	a, 127	; F640DC  and A,0x7f
	or	a, (3401:16)	; F640DF  or A,(0x0d49)
	ldfr_berp	a, 0x3c	; F640E3  ld RL3,A
	and	a, 252	; F640E6  and A,0xfc
	ldto_berp	a, 0x3c	; F640E9  ld A,RL3
	jr	nz, sub_F63F90_Skip4	; F640EC  jr NZ,0xf640f5
	and	(0x0d46:16), 0xfb	; F640EE  and (0x0d46),0xfb
	jr	sub_F63F90_Return	; F640F3  jr T,0xf6411b
sub_F63F90_Skip4:
	or	(0x0d46:16), 0x04	; F640F5  or (0x0d46),0x04
	jr	sub_F63F90_Return	; F640FA  jr T,0xf6411b
sub_F63F90_Skip5:
	and	(0x0d46:16), 0xfb	; F640FC  and (0x0d46),0xfb
	cp	(0x0c06:16), 0x0f	; F64101  cp (0x0c06),0x0f
	jr	nz, sub_F63F90_Loop	; F64106  jr NZ,0xf64090
	push	xde	; F64108  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F64109  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F6410D  ld A,(XDE+IY)
	pop	xde	; F64112  pop XDE
	cp	a, 3:i3	; F64113  cp A,3
	jrl	nz, sub_F63F90_Loop	; F64115  jrl NZ,0xf64090
	jrl	sub_F63F90_Join	; F64118  jrl T,0xf6407f
sub_F63F90_Return:
	ret	; F6411B  ret
sub_F6411C:
	xor	hl, hl	; F6411C  xor HL,HL
	call	T_BStore_ReadCursorAdvance_Call	; F6411E  call 0xf4270c
	cp	(BStore_ErrorCode:16), 0x00	; F64122  cp (0x0d4a),0x00
	jr	nz, sub_F6411C_Return	; F64127  jr NZ,0xf6415d
	call	T_BStore_ReadCursorAdvance_Call	; F64129  call 0xf4270c
	cp	(BStore_ErrorCode:16), 0x00	; F6412D  cp (0x0d4a),0x00
	jr	nz, sub_F6411C_Return	; F64132  jr NZ,0xf6415d
	push	xde	; F64134  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F64135  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F64139  ld A,(XDE+IY)
	pop	xde	; F6413E  pop XDE
	call	T_BStore_ReadCursorAdvance_Call	; F6413F  call 0xf4270c
	cp	(BStore_ErrorCode:16), 0x00	; F64143  cp (0x0d4a),0x00
	jr	nz, sub_F6411C_Return	; F64148  jr NZ,0xf6415d
	push	xde	; F6414A  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F6414B  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F6414F  ld A,(XDE+IY)
	pop	xde	; F64154  pop XDE
	xor	l, l	; F64155  xor L,L
	cp	a, 0:i3	; F64157  cp A,0
	jr	ule, sub_F6411C_Return	; F64159  jr ULE,0xf6415d
	ld	l, 1:opc	; F6415B  ld L,0x01
sub_F6411C_Return:
	ret	; F6415D  ret

; --- BStore_Table_F6415E: 48 bytes at 0xF6415E ---
;     48 bytes.  NO site in prom_a or prom_b spells the address 0x00F6415E, so
;     what reads it is unknown and its extent rests only on abutment: 0xF6418E
;     is thunk T_F42804's target and 0xF6415D is the `ret` of the routine
;     above.  It reads as two 24-byte rows, each `07 08 09 FF FF FF FF` / `00
;     01 02 FF FF FF FF` twice, six 0xFF, then `90 FF` and a repeated byte
;     (0x51 / 0x50).  Structure NOT established.
;     Evidence: the bytes above, re-asserted by assert_data_islands() in
;     notes/gen_prom_b_blockstore_module.py before this text can be emitted.
;     The literal 0x00F6415E appears 0 times in CPU 1's two ROMs, counted by
;     addr_sites() at EVERY byte offset: nowhere.  Those are the addresses of
;     the LITERAL, which is one or more bytes PAST the start of the
;     instruction carrying it -- the instruction addresses in the paragraph
;     above are not the same numbers and are not meant to be.
BStore_Table_F6415E:
	.byte	0x07, 0x08, 0x09, 0xFF, 0xFF, 0xFF, 0xFF, 0x07, 0x08, 0x09, 0xFF, 0xFF	; +0x00
	.byte	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x90, 0xFF, 0x51, 0x51	; +0x0C
	.byte	0x00, 0x01, 0x02, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x01, 0x02, 0xFF, 0xFF	; +0x18
	.byte	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x90, 0xFF, 0x50, 0x50	; +0x24
sub_F6418E:		; <- T_F42804
	ld	(BStore_ErrorCode:16), 0	; F6418E  ld (0x0d4a),0x00
	ld	w, (3357:16)	; F64193  ld W,(0x0d1d)
	ld	a, (3185:16)	; F64197  ld A,(0x0c71)
	push	xde	; F6419B  push XDE
	push	xhl	; F6419C  push XHL
	xor	hl, hl	; F6419D  xor HL,HL
	ld	xde, BStore_TrackToPart	; F6419F  ld XDE,0x00603422
	ld	l, (3184:16)	; F641A4  ld L,(0x0c70)
	dec	1, l	; F641A8  dec 1,L
	ld	l, (xde+hl)	; F641AA  ld L,(XDE+HL)
	ld	(3078:16), l	; F641AF  ld (0x0c06),L
	pop	xhl	; F641B3  pop XHL
	pop	xde	; F641B4  pop XDE
	ld	de, (3189:16)	; F641B5  ld DE,(0x0c75)
	ld	(3216:16), de	; F641B9  ld (0x0c90),DE
	calr	BStore_SeekMeasure	; F641BD  calr 0xf62cfe
	cp	(BStore_ErrorCode:16), 0x00	; F641C0  cp (0x0d4a),0x00
	jrl	nz, sub_F6418E_Return	; F641C5  jrl NZ,0xf6452a
	push	xhl	; F641C8  push XHL
	ld	xhl, (BStore_CursorBlockAddr:16)	; F641C9  ld XHL,(0x126e)
	ld	(3254:16), xhl	; F641CD  ld (0x0cb6),XHL
	pop	xhl	; F641D1  pop XHL
	ld	(3258:16), iy	; F641D2  ld (0x0cba),IY
	ld	wa, (BStore_CursorBlock:16)	; F641D6  ld WA,(0x345c)
	ld	(3252:16), wa	; F641DA  ld (0x0cb4),WA
	ld	(3262:16), iy	; F641DE  ld (0x0cbe),IY
	ld	(3260:16), wa	; F641E2  ld (0x0cbc),WA
	ld	ix, iy	; F641E6  ld IX,IY
	xor	de, de	; F641E8  xor DE,DE
sub_F6418E_Join:
	cp	de, (0x0c77:16)	; F641EA  cp DE,(0x0c77)
	jrl	z, sub_F6418E_Skip17	; F641EE  jrl Z,0xf644cb
	xor	c, c	; F641F1  xor C,C
sub_F6418E_Join2:
	cp	c, (0x0d1c:16)	; F641F3  cp C,(0x0d1c)
	jrl	z, sub_F6418E_Skip16	; F641F7  jrl Z,0xf644a3
sub_F6418E_Loop:
	push	xde	; F641FA  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F641FB  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F641FF  ld A,(XDE+IY)
	pop	xde	; F64204  pop XDE
	ld	(4696:16), a	; F64205  ld (0x1258),A
	cp	a, 130	; F64209  cp A,0x82
	jrl	z, sub_F6418E_Skip17	; F6420C  jrl Z,0xf644cb
	cp	a, 129	; F6420F  cp A,0x81
	jrl	z, sub_F6418E_Skip15	; F64212  jrl Z,0xf64473
	cp	a, 210	; F64215  cp A,0xd2
	jr	z, sub_F6418E_Skip	; F64218  jr Z,0xf6424f
	cp	a, 209	; F6421A  cp A,0xd1
	jr	z, sub_F6418E_Skip	; F6421D  jr Z,0xf6424f
	cp	a, 133	; F6421F  cp A,0x85
	jr	z, sub_F6418E_Loop3	; F64222  jr Z,0xf64255
	cp	a, 134	; F64224  cp A,0x86
	jr	z, sub_F6418E_Loop3	; F64227  jr Z,0xf64255
	ld	w, 240:opc	; F64229  ld W,0xf0
	and	w, a	; F6422B  and W,A
	cp	w, 144	; F6422D  cp W,0x90
	jr	z, sub_F6418E_Loop3	; F64230  jr Z,0xf64255
	cp	w, 176	; F64232  cp W,0xb0
	jrl	z, sub_F6418E_Skip3	; F64235  jrl Z,0xf64334
	cp	w, 192	; F64238  cp W,0xc0
	jr	z, sub_F6418E_Entry	; F6423B  jr Z,0xf6429b
sub_F6418E_Loop2:
	pushw	bc	; F6423D  push BC
	pushw	de	; F6423E  push DE
	call	T_BStore_ReadCursorAdvance_Call	; F6423F  call 0xf4270c
	popw	de	; F64243  pop DE
	popw	bc	; F64244  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F64245  cp (0x0d4a),0x00
	jr	z, sub_F6418E_Loop	; F6424A  jr Z,0xf641fa
	jrl	sub_F6418E_Return	; F6424C  jrl T,0xf6452a
sub_F6418E_Skip:
	bit	0, (0x0d45:16)	; F6424F  bit 0,(0x0d45)
	jr	nz, sub_F6418E_Loop2	; F64253  jr NZ,0xf6423d
sub_F6418E_Loop3:
	push	xhl	; F64255  push XHL
	ld	xhl, (3254:16)	; F64256  ld XHL,(0x0cb6)
	ld	(xhl+ix), a	; F6425A  ld (XHL+IX),A
	pop	xhl	; F6425F  pop XHL
	pushw	bc	; F64260  push BC
	pushw	de	; F64261  push DE
	call	T_BStore_WriteCursorAdvance_Call	; F64262  call 0xf42710
	popw	de	; F64266  pop DE
	popw	bc	; F64267  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F64268  cp (0x0d4a),0x00
	jrl	nz, sub_F6418E_Return	; F6426D  jrl NZ,0xf6452a
	pushw	bc	; F64270  push BC
	pushw	de	; F64271  push DE
	call	T_BStore_ReadCursorAdvance_Call	; F64272  call 0xf4270c
	popw	de	; F64276  pop DE
	popw	bc	; F64277  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F64278  cp (0x0d4a),0x00
	jrl	nz, sub_F6418E_Return	; F6427D  jrl NZ,0xf6452a
	push	xde	; F64280  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F64281  ld XDE,(0x126e)
	bit	7, (xde+iy)	; F64285  bit 7,(XDE+IY)
	pop	xde	; F6428A  pop XDE
	jrl	nz, sub_F6418E_Loop	; F6428B  jrl NZ,0xf641fa
	push	xde	; F6428E  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F6428F  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F64293  ld A,(XDE+IY)
	pop	xde	; F64298  pop XDE
	jr	sub_F6418E_Loop3	; F64299  jr T,0xf64255
sub_F6418E_Entry:
	ldfr_berp	a, 0x3c	; F6429B  ld RL3,A
	ld	a, (3397:16)	; F6429E  ld A,(0x0d45)
	and	a, 3	; F642A2  and A,0x03
	ldto_berp	a, 0x3c	; F642A5  ld A,RL3
	jr	nz, sub_F6418E_Loop2	; F642A8  jr NZ,0xf6423d
	push	xiz	; F642AA  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F642AB  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F642AF  ld XDE3,XIZ
	pop	xiz	; F642B2  pop XIZ
	push_lerp	0x38	; F642B3  push XDE3
	pushw	wa	; F642B6  push WA
	pushw	bc	; F642B7  push BC
	pushw	de	; F642B8  push DE
	push	xiy	; F642B9  push XIY
	pushw	(0x0cbc:16)	; F642BA  pushw (0x0cbc)
	calr	sub_F6411C	; F642BE  calr 0xf6411c
	popw	(0x0cbc:16)	; F642C1  popw (0x0cbc)
	pop	xiy	; F642C5  pop XIY
	popw	de	; F642C6  pop DE
	popw	bc	; F642C7  pop BC
	popw	wa	; F642C8  pop WA
	pop_lerp	0x38	; F642C9  pop XDE3
	push	xiz	; F642CC  push XIZ
	ldto_lerp	xiz, 0x38	; F642CD  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F642D0  ld (0x126e),XIZ
	pop	xiz	; F642D4  pop XIZ
	cp	l, 0:i3	; F642D5  cp L,0
	jrl	nz, sub_F6418E_Loop2	; F642D7  jrl NZ,0xf6423d
	ld	(3400:16), 0	; F642DA  ld (0x0d48),0x00
sub_F6418E_Join3:
	cp	(0x0d48:16), 0x02	; F642DF  cp (0x0d48),0x02
	jr	nz, sub_F6418E_Skip2	; F642E4  jr NZ,0xf642ea
	ld	a, (3396:16)	; F642E6  ld A,(0x0d44)
sub_F6418E_Skip2:
	push	xhl	; F642EA  push XHL
	ld	xhl, (3254:16)	; F642EB  ld XHL,(0x0cb6)
	ld	(xhl+ix), a	; F642EF  ld (XHL+IX),A
	pop	xhl	; F642F4  pop XHL
	pushw	bc	; F642F5  push BC
	pushw	de	; F642F6  push DE
	call	T_BStore_WriteCursorAdvance_Call	; F642F7  call 0xf42710
	popw	de	; F642FB  pop DE
	popw	bc	; F642FC  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F642FD  cp (0x0d4a),0x00
	jrl	nz, sub_F63CE0_Return	; F64302  jrl NZ,0xf63f87
	pushw	bc	; F64305  push BC
	pushw	de	; F64306  push DE
	call	T_BStore_ReadCursorAdvance_Call	; F64307  call 0xf4270c
	popw	de	; F6430B  pop DE
	popw	bc	; F6430C  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F6430D  cp (0x0d4a),0x00
	jrl	nz, sub_F63CE0_Return	; F64312  jrl NZ,0xf63f87
	inc	1, (3400:16)	; F64315  inc 1,(0x0d48)
	push	xde	; F64319  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F6431A  ld XDE,(0x126e)
	bit	7, (xde+iy)	; F6431E  bit 7,(XDE+IY)
	pop	xde	; F64323  pop XDE
	jrl	nz, sub_F6418E_Loop	; F64324  jrl NZ,0xf641fa
	push	xde	; F64327  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F64328  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F6432C  ld A,(XDE+IY)
	pop	xde	; F64331  pop XDE
	jr	sub_F6418E_Join3	; F64332  jr T,0xf642df
sub_F6418E_Skip3:
	ld	(3401:16), a	; F64334  ld (0x0d49),A
	and	(0x0d49:16), 0x02	; F64338  and (0x0d49),0x02
	ldib_erp	60, 6	; F6433D  ld RL3,6
	sla	(0x0d49:16)	; F64340  sla (0x0d49)
	.byte 0xC7, 0x3C, 0x1C, 0xF8	; F64344  djnz RL3,0xf64340   [llvm-mc cannot encode this]
	push	xiz	; F64348  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F64349  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F6434D  ld XDE3,XIZ
	pop	xiz	; F64350  pop XIZ
	push_lerp	0x38	; F64351  push XDE3
	pushw	wa	; F64354  push WA
	pushw	bc	; F64355  push BC
	pushw	de	; F64356  push DE
	push	xiy	; F64357  push XIY
	pushw	(0x0cbc:16)	; F64358  pushw (0x0cbc)
	calr	sub_F63F90	; F6435C  calr 0xf63f90
	popw	(0x0cbc:16)	; F6435F  popw (0x0cbc)
	pop	xiy	; F64363  pop XIY
	popw	de	; F64364  pop DE
	popw	bc	; F64365  pop BC
	popw	wa	; F64366  pop WA
	pop_lerp	0x38	; F64367  pop XDE3
	push	xiz	; F6436A  push XIZ
	ldto_lerp	xiz, 0x38	; F6436B  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F6436E  ld (0x126e),XIZ
	pop	xiz	; F64372  pop XIZ
	cp	(BStore_ErrorCode:16), 0x00	; F64373  cp (0x0d4a),0x00
	jrl	nz, sub_F63CE0_Return	; F64378  jrl NZ,0xf63f87
	bit	0, (0x0d46:16)	; F6437B  bit 0,(0x0d46)
	jr	nz, sub_F6418E_Skip4	; F6437F  jr NZ,0xf6438b
	bit	2, (0x0d46:16)	; F64381  bit 2,(0x0d46)
	jrl	nz, sub_F6418E_Loop3	; F64385  jrl NZ,0xf64255
	jrl	sub_F6418E_Loop2	; F64388  jrl T,0xf6423d
sub_F6418E_Skip4:
	ld	(3399:16), 0	; F6438B  ld (0x0d47),0x00
sub_F6418E_Join4:
	cp	(0x0d47:16), 0x00	; F64390  cp (0x0d47),0x00
	jr	nz, sub_F6418E_Skip5	; F64395  jr NZ,0xf6439a
	jrl	sub_F6418E_Join5	; F64397  jrl T,0xf64428
sub_F6418E_Skip5:
	cp	(0x0d47:16), 0x02	; F6439A  cp (0x0d47),0x02
	jr	nz, sub_F6418E_Skip13	; F6439F  jr NZ,0xf64409
	ld	a, (3396:16)	; F643A1  ld A,(0x0d44)
	cp	(0x1258:16), 0xb5	; F643A5  cp (0x1258),0xb5
	jr	z, sub_F6418E_Skip6	; F643AA  jr Z,0xf643d8
	cp	(0x1258:16), 0xbc	; F643AC  cp (0x1258),0xbc
	jr	z, sub_F6418E_Skip7	; F643B1  jr Z,0xf643df
	cp	(0x1258:16), 0xbd	; F643B3  cp (0x1258),0xbd
	jr	z, sub_F6418E_Skip8	; F643B8  jr Z,0xf643e6
	cp	(0x1258:16), 0xb8	; F643BA  cp (0x1258),0xb8
	jr	z, sub_F6418E_Skip9	; F643BF  jr Z,0xf643ed
	cp	(0x1258:16), 0xb9	; F643C1  cp (0x1258),0xb9
	jr	z, sub_F6418E_Skip10	; F643C6  jr Z,0xf643f4
	cp	(0x1258:16), 0xba	; F643C8  cp (0x1258),0xba
	jr	z, sub_F6418E_Skip11	; F643CD  jr Z,0xf643fb
	cp	(0x1258:16), 0xbb	; F643CF  cp (0x1258),0xbb
	jr	z, sub_F6418E_Skip12	; F643D4  jr Z,0xf64402
	jr	sub_F6418E_Join5	; F643D6  jr T,0xf64428
sub_F6418E_Skip6:
	ld	a, 181:opc	; F643D8  ld A,0xb5
	and	a, 127	; F643DA  and A,0x7f
	jr	sub_F6418E_Join5	; F643DD  jr T,0xf64428
sub_F6418E_Skip7:
	ld	a, 188:opc	; F643DF  ld A,0xbc
	and	a, 127	; F643E1  and A,0x7f
	jr	sub_F6418E_Join5	; F643E4  jr T,0xf64428
sub_F6418E_Skip8:
	ld	a, 189:opc	; F643E6  ld A,0xbd
	and	a, 127	; F643E8  and A,0x7f
	jr	sub_F6418E_Join5	; F643EB  jr T,0xf64428
sub_F6418E_Skip9:
	ld	a, 184:opc	; F643ED  ld A,0xb8
	and	a, 127	; F643EF  and A,0x7f
	jr	sub_F6418E_Join5	; F643F2  jr T,0xf64428
sub_F6418E_Skip10:
	ld	a, 185:opc	; F643F4  ld A,0xb9
	and	a, 127	; F643F6  and A,0x7f
	jr	sub_F6418E_Join5	; F643F9  jr T,0xf64428
sub_F6418E_Skip11:
	ld	a, 186:opc	; F643FB  ld A,0xba
	and	a, 127	; F643FD  and A,0x7f
	jr	sub_F6418E_Join5	; F64400  jr T,0xf64428
sub_F6418E_Skip12:
	ld	a, 187:opc	; F64402  ld A,0xbb
	and	a, 127	; F64404  and A,0x7f
	jr	sub_F6418E_Join5	; F64407  jr T,0xf64428
sub_F6418E_Skip13:
	cp	(0x0d47:16), 0x03	; F64409  cp (0x0d47),0x03
	jr	nz, sub_F6418E_Skip14	; F6440E  jr NZ,0xf64416
	ld	a, (3537:16)	; F64410  ld A,(0x0dd1)
	jr	sub_F6418E_Join5	; F64414  jr T,0xf64428
sub_F6418E_Skip14:
	cp	(0x0d47:16), 0x04	; F64416  cp (0x0d47),0x04
	jr	nz, sub_F6418E_Join5	; F6441B  jr NZ,0xf64428
	cp	(0x0dd0:16), 0xff	; F6441D  cp (0x0dd0),0xff
	jr	z, sub_F6418E_Join5	; F64422  jr Z,0xf64428
	ld	a, (3536:16)	; F64424  ld A,(0x0dd0)
sub_F6418E_Join5:
	push	xhl	; F64428  push XHL
	ld	xhl, (3254:16)	; F64429  ld XHL,(0x0cb6)
	ld	(xhl+ix), a	; F6442D  ld (XHL+IX),A
	pop	xhl	; F64432  pop XHL
	pushw	bc	; F64433  push BC
	pushw	de	; F64434  push DE
	call	T_BStore_WriteCursorAdvance_Call	; F64435  call 0xf42710
	popw	de	; F64439  pop DE
	popw	bc	; F6443A  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F6443B  cp (0x0d4a),0x00
	jrl	nz, sub_F6418E_Return	; F64440  jrl NZ,0xf6452a
	pushw	bc	; F64443  push BC
	pushw	de	; F64444  push DE
	call	T_BStore_ReadCursorAdvance_Call	; F64445  call 0xf4270c
	popw	de	; F64449  pop DE
	popw	bc	; F6444A  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F6444B  cp (0x0d4a),0x00
	jrl	nz, sub_F63CE0_Return	; F64450  jrl NZ,0xf63f87
	inc	1, (3399:16)	; F64453  inc 1,(0x0d47)
	push	xde	; F64457  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F64458  ld XDE,(0x126e)
	bit	7, (xde+iy)	; F6445C  bit 7,(XDE+IY)
	pop	xde	; F64461  pop XDE
	jrl	nz, sub_F6418E_Loop	; F64462  jrl NZ,0xf641fa
	push	xde	; F64465  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F64466  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F6446A  ld A,(XDE+IY)
	pop	xde	; F6446F  pop XDE
	jrl	sub_F6418E_Join4	; F64470  jrl T,0xf64390
sub_F6418E_Skip15:
	push	xhl	; F64473  push XHL
	ld	xhl, (3254:16)	; F64474  ld XHL,(0x0cb6)
	ld	(xhl+ix), a	; F64478  ld (XHL+IX),A
	pop	xhl	; F6447D  pop XHL
	pushw	bc	; F6447E  push BC
	pushw	de	; F6447F  push DE
	call	T_BStore_WriteCursorAdvance_Call	; F64480  call 0xf42710
	popw	de	; F64484  pop DE
	popw	bc	; F64485  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F64486  cp (0x0d4a),0x00
	jrl	nz, sub_F6418E_Return	; F6448B  jrl NZ,0xf6452a
	pushw	bc	; F6448E  push BC
	pushw	de	; F6448F  push DE
	call	T_BStore_ReadCursorAdvance_Call	; F64490  call 0xf4270c
	popw	de	; F64494  pop DE
	popw	bc	; F64495  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F64496  cp (0x0d4a),0x00
	jrl	nz, sub_F6418E_Return	; F6449B  jrl NZ,0xf6452a
	inc	1, c	; F6449E  inc 1,C
	jrl	sub_F6418E_Join2	; F644A0  jrl T,0xf641f3
sub_F6418E_Skip16:
	inc	1, de	; F644A3  inc 1,DE
	push	xiz	; F644A5  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F644A6  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F644AA  ld XDE3,XIZ
	pop	xiz	; F644AD  pop XIZ
	push_lerp	0x38	; F644AE  push XDE3
	push	xhl	; F644B1  push XHL
	pushw	de	; F644B2  push DE
	push	xiy	; F644B3  push XIY
	push	xix	; F644B4  push XIX
	calr	sub_F63749	; F644B5  calr 0xf63749
	pop	xix	; F644B8  pop XIX
	pop	xiy	; F644B9  pop XIY
	popw	de	; F644BA  pop DE
	pop	xhl	; F644BB  pop XHL
	pop_lerp	0x38	; F644BC  pop XDE3
	push	xiz	; F644BF  push XIZ
	ldto_lerp	xiz, 0x38	; F644C0  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F644C3  ld (0x126e),XIZ
	pop	xiz	; F644C7  pop XIZ
	jrl	sub_F6418E_Join	; F644C8  jrl T,0xf641ea
sub_F6418E_Skip17:
	ld	(3262:16), iy	; F644CB  ld (0x0cbe),IY
	ld	(3258:16), ix	; F644CF  ld (0x0cba),IX
	ld	wa, (3260:16)	; F644D3  ld WA,(0x0cbc)
	ld	(3169:16), wa	; F644D7  ld (0x0c61),WA
	ld	wa, (3262:16)	; F644DB  ld WA,(0x0cbe)
	ld	(3175:16), wa	; F644DF  ld (0x0c67),WA
	ld	wa, (3252:16)	; F644E3  ld WA,(0x0cb4)
	ld	(3159:16), wa	; F644E7  ld (0x0c57),WA
	ld	wa, (3258:16)	; F644EB  ld WA,(0x0cba)
	ld	(3165:16), wa	; F644EF  ld (0x0c5d),WA
	xor	hl, hl	; F644F3  xor HL,HL
	ld	l, (3185:16)	; F644F5  ld L,(0x0c71)
	dec	1, hl	; F644F9  dec 1,HL
	xor	wa, wa	; F644FB  xor WA,WA
	ld	xde, 6304928	; F644FD  ld XDE,0x006034a0
	ld	a, (xde+hl)	; F64502  ld A,(XDE+HL)
	ld	(3179:16), wa	; F64507  ld (0x0c6b),WA
	sla	hl, 1	; F6450B  sla 0x01,HL
	ld	xde, 6304894	; F6450E  ld XDE,0x0060347e
	ld	de, (xde+hl)	; F64513  ld DE,(XDE+HL)
	calr	sub_F62DC9	; F64518  calr 0xf62dc9
	cp	(BStore_ErrorCode:16), 0x00	; F6451B  cp (0x0d4a),0x00
	jr	nz, sub_F6418E_Return	; F64520  jr NZ,0xf6452a
	dec	1, ix	; F64522  dec 1,IX
	calr	BStore_SaveCursor	; F64524  calr 0xf63924
	calr	BStore_TruncateChainAfterBlock	; F64527  calr 0xf63510
sub_F6418E_Return:
	ret	; F6452A  ret
; SongEdit_CheckAllTracksToStartMeasure: All-tracks pre-check of MEASURE ERASE / MEASURE DELETE: for each track
;   1..(0x0CA2) whose saved cursor validates, seeks its chain to the job's first measure (0x0C73) under the master
;   track's time signatures (Seq_FindMasterTrack, BStore_SeekMeasure); errors 1 and 8 (no data, chain ends first) are
;   skipped, any other returns with BStore_ErrorCode set. MeasureErase_Execute and SongEdit_DeleteMeasures call it
;   (T_SongEdit_CheckAllTracksToStartMeasure) in all-tracks mode before touching any track. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_o.json)
SongEdit_CheckAllTracksToStartMeasure:		; <- T_SongEdit_CheckAllTracksToStartMeasure
	ld	(BStore_ErrorCode:16), 0	; F6452B  ld (0x0d4a),0x00
	ld	a, 1:opc	; F64530  ld A,0x01
SongEdit_CheckAllTracksToStartMeasure_Join:
	cp	a, (0x0ca2:16)	; F64532  cp A,(0x0ca2)
	jr	ugt, SongEdit_CheckAllTracksToStartMeasure_Return	; F64536  jr UGT,0xf64593
	ld	(3214:16), a	; F64538  ld (0x0c8e),A
	calr	BStore_ValidateSavedCursor	; F6453C  calr 0xf62c7e
	cp	(BStore_ErrorCode:16), 0x00	; F6453F  cp (0x0d4a),0x00
	jr	z, SongEdit_CheckAllTracksToStartMeasure_Skip2	; F64544  jr Z,0xf6455d
	cp	(BStore_ErrorCode:16), 0x01	; F64546  cp (0x0d4a),0x01
	jr	z, SongEdit_CheckAllTracksToStartMeasure_Skip	; F6454B  jr Z,0xf64556
	cp	(BStore_ErrorCode:16), 0x08	; F6454D  cp (0x0d4a),0x08
	jr	z, SongEdit_CheckAllTracksToStartMeasure_Skip	; F64552  jr Z,0xf64556
	jr	SongEdit_CheckAllTracksToStartMeasure_Return	; F64554  jr T,0xf64593
SongEdit_CheckAllTracksToStartMeasure_Skip:
	ld	(BStore_ErrorCode:16), 0	; F64556  ld (0x0d4a),0x00
	jr	SongEdit_CheckAllTracksToStartMeasure_Join2	; F6455B  jr T,0xf6458b
SongEdit_CheckAllTracksToStartMeasure_Skip2:
	calr	Seq_FindMasterTrack	; F6455D  calr 0xf6360e
	ld	hl, (3187:16)	; F64560  ld HL,(0x0c73)
	ld	(3216:16), hl	; F64564  ld (0x0c90),HL
	ld	a, (3214:16)	; F64568  ld A,(0x0c8e)
	calr	BStore_SeekMeasure	; F6456C  calr 0xf62cfe
	cp	(BStore_ErrorCode:16), 0x00	; F6456F  cp (0x0d4a),0x00
	jr	z, SongEdit_CheckAllTracksToStartMeasure_Join2	; F64574  jr Z,0xf6458b
	cp	(BStore_ErrorCode:16), 0x01	; F64576  cp (0x0d4a),0x01
	jr	z, SongEdit_CheckAllTracksToStartMeasure_Skip3	; F6457B  jr Z,0xf64586
	cp	(BStore_ErrorCode:16), 0x08	; F6457D  cp (0x0d4a),0x08
	jr	z, SongEdit_CheckAllTracksToStartMeasure_Skip3	; F64582  jr Z,0xf64586
	jr	SongEdit_CheckAllTracksToStartMeasure_Return	; F64584  jr T,0xf64593
SongEdit_CheckAllTracksToStartMeasure_Skip3:
	ld	(BStore_ErrorCode:16), 0	; F64586  ld (0x0d4a),0x00
SongEdit_CheckAllTracksToStartMeasure_Join2:
	ld	a, (3214:16)	; F6458B  ld A,(0x0c8e)
	inc	1, a	; F6458F  inc 1,A
	jr	SongEdit_CheckAllTracksToStartMeasure_Join	; F64591  jr T,0xf64532
SongEdit_CheckAllTracksToStartMeasure_Return:
	ret	; F64593  ret
; SongEdit_CheckFreeBlocksForInsert: All-tracks pre-check of MEASURE INSERT: (0x0D40) := BStore_FreeCount; for each
;   track that reaches the insert measure (0x0C75), sizes the (0x0C77) measures from (0x0C73) in bytes (sub_F6353E ->
;   BStore_AllocBytesWanted), converts them to blocks (BStore_BlocksNeededToGrow -> (0x0D3E)) and subtracts them, returning error 5
;   when the free blocks run out. MeasureInsert_Execute calls it (T_SongEdit_CheckFreeBlocksForInsert) in all-tracks mode before inserting.
;   Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
SongEdit_CheckFreeBlocksForInsert:		; <- T_SongEdit_CheckFreeBlocksForInsert
	ld	wa, (BStore_FreeCount:24)	; F64594  ld WA,(0x6034ba)
	ld	(3392:16), wa	; F64599  ld (0x0d40),WA
	ld	(BStore_ErrorCode:16), 0	; F6459D  ld (0x0d4a),0x00
	ld	a, 1:opc	; F645A2  ld A,0x01
SongEdit_CheckFreeBlocksForInsert_Join:
	cp	a, (0x0ca2:16)	; F645A4  cp A,(0x0ca2)
	jr	ule, SongEdit_CheckFreeBlocksForInsert_Skip	; F645A8  jr ULE,0xf645ad
	jrl	SongEdit_CheckFreeBlocksForInsert_Return	; F645AA  jrl T,0xf6466d
SongEdit_CheckFreeBlocksForInsert_Skip:
	ld	(3214:16), a	; F645AD  ld (0x0c8e),A
	calr	BStore_ValidateSavedCursor	; F645B1  calr 0xf62c7e
	cp	(BStore_ErrorCode:16), 0x00	; F645B4  cp (0x0d4a),0x00
	jr	z, SongEdit_CheckFreeBlocksForInsert_Skip3	; F645B9  jr Z,0xf645d4
	cp	(BStore_ErrorCode:16), 0x01	; F645BB  cp (0x0d4a),0x01
	jr	z, SongEdit_CheckFreeBlocksForInsert_Skip2	; F645C0  jr Z,0xf645cc
	cp	(BStore_ErrorCode:16), 0x08	; F645C2  cp (0x0d4a),0x08
	jr	z, SongEdit_CheckFreeBlocksForInsert_Skip2	; F645C7  jr Z,0xf645cc
	jrl	SongEdit_CheckFreeBlocksForInsert_Return	; F645C9  jrl T,0xf6466d
SongEdit_CheckFreeBlocksForInsert_Skip2:
	ld	(BStore_ErrorCode:16), 0	; F645CC  ld (0x0d4a),0x00
	jrl	SongEdit_CheckFreeBlocksForInsert_Join2	; F645D1  jrl T,0xf64664
SongEdit_CheckFreeBlocksForInsert_Skip3:
	calr	Seq_FindMasterTrack	; F645D4  calr 0xf6360e
	ld	hl, (3189:16)	; F645D7  ld HL,(0x0c75)
	ld	(3216:16), hl	; F645DB  ld (0x0c90),HL
	ld	a, (3214:16)	; F645DF  ld A,(0x0c8e)
	calr	BStore_SeekMeasure	; F645E3  calr 0xf62cfe
	cp	(BStore_ErrorCode:16), 0x00	; F645E6  cp (0x0d4a),0x00
	jr	z, SongEdit_CheckFreeBlocksForInsert_Skip5	; F645EB  jr Z,0xf64604
	cp	(BStore_ErrorCode:16), 0x01	; F645ED  cp (0x0d4a),0x01
	jr	z, SongEdit_CheckFreeBlocksForInsert_Skip4	; F645F2  jr Z,0xf645fd
	cp	(BStore_ErrorCode:16), 0x08	; F645F4  cp (0x0d4a),0x08
	jr	z, SongEdit_CheckFreeBlocksForInsert_Skip4	; F645F9  jr Z,0xf645fd
	jr	SongEdit_CheckFreeBlocksForInsert_Return	; F645FB  jr T,0xf6466d
SongEdit_CheckFreeBlocksForInsert_Skip4:
	ld	(BStore_ErrorCode:16), 0	; F645FD  ld (0x0d4a),0x00
	jr	SongEdit_CheckFreeBlocksForInsert_Join2	; F64602  jr T,0xf64664
SongEdit_CheckFreeBlocksForInsert_Skip5:
	ld	wa, (3187:16)	; F64604  ld WA,(0x0c73)
	ld	(3216:16), wa	; F64608  ld (0x0c90),WA
	ld	w, (3357:16)	; F6460C  ld W,(0x0d1d)
	ld	a, (3214:16)	; F64610  ld A,(0x0c8e)
	calr	BStore_SeekMeasure	; F64614  calr 0xf62cfe
	cp	(BStore_ErrorCode:16), 0x00	; F64617  cp (0x0d4a),0x00
	jr	z, SongEdit_CheckFreeBlocksForInsert_Skip6	; F6461C  jr Z,0xf6462c
	cp	(BStore_ErrorCode:16), 0x08	; F6461E  cp (0x0d4a),0x08
	jr	nz, SongEdit_CheckFreeBlocksForInsert_Return	; F64623  jr NZ,0xf6466d
	ld	(BStore_ErrorCode:16), 0	; F64625  ld (0x0d4a),0x00
	jr	SongEdit_CheckFreeBlocksForInsert_Join2	; F6462A  jr T,0xf64664
SongEdit_CheckFreeBlocksForInsert_Skip6:
	ld	hl, (BStore_CursorBlock:16)	; F6462C  ld HL,(0x345c)
	calr	sub_F6353E	; F64630  calr 0xf6353e
	cp	(BStore_ErrorCode:16), 0x00	; F64633  cp (0x0d4a),0x00
	jr	z, SongEdit_CheckFreeBlocksForInsert_Skip8	; F64638  jr Z,0xf64648
	cp	(BStore_ErrorCode:16), 0x07	; F6463A  cp (0x0d4a),0x07
	jr	z, SongEdit_CheckFreeBlocksForInsert_Skip7	; F6463F  jr Z,0xf64643
	jr	SongEdit_CheckFreeBlocksForInsert_Return	; F64641  jr T,0xf6466d
SongEdit_CheckFreeBlocksForInsert_Skip7:
	ld	(BStore_ErrorCode:16), 0	; F64643  ld (0x0d4a),0x00
SongEdit_CheckFreeBlocksForInsert_Skip8:
	calr	BStore_BlocksNeededToGrow	; F64648  calr 0xf647dd
	ld	wa, (3392:16)	; F6464B  ld WA,(0x0d40)
	cp	wa, (0x0d3e:16)	; F6464F  cp WA,(0x0d3e)
	jr	nc, SongEdit_CheckFreeBlocksForInsert_Skip9	; F64653  jr NC,0xf6465c
	ld	(BStore_ErrorCode:16), 5	; F64655  ld (0x0d4a),0x05
	jr	SongEdit_CheckFreeBlocksForInsert_Return	; F6465A  jr T,0xf6466d
SongEdit_CheckFreeBlocksForInsert_Skip9:
	sub	wa, (0x0d3e:16)	; F6465C  sub WA,(0x0d3e)
	ld	(3392:16), wa	; F64660  ld (0x0d40),WA
SongEdit_CheckFreeBlocksForInsert_Join2:
	ld	a, (3214:16)	; F64664  ld A,(0x0c8e)
	inc	1, a	; F64668  inc 1,A
	jrl	SongEdit_CheckFreeBlocksForInsert_Join	; F6466A  jrl T,0xf645a4
SongEdit_CheckFreeBlocksForInsert_Return:
	ret	; F6466D  ret
; SongEdit_CheckFreeBlocksForCopy: All-tracks pre-check of MEASURE COPY: (0x0D40) := BStore_FreeCount; per track,
;   sizes (0x0C77) measures at the destination (0x0C75) and at the source (0x0C73) (sub_F6353E each) and adds the
;   blocks a smaller copy frees (BStore_BlocksFreedByShrink) or subtracts the blocks a larger one needs (BStore_BlocksNeededToGrow), returning error
;   5 when short. SongEdit_CopyMeasures calls it (T_SongEdit_CheckFreeBlocksForCopy) in all-tracks mode before copying. Basis: caller + body +
;   the insert twin. (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
SongEdit_CheckFreeBlocksForCopy:		; <- T_SongEdit_CheckFreeBlocksForCopy
	and	(0x0c8a:16), 0xf7	; F6466E  and (0x0c8a),0xf7
	and	(0x0c8a:16), 0xef	; F64673  and (0x0c8a),0xef
	ld	wa, (BStore_FreeCount:24)	; F64678  ld WA,(0x6034ba)
	ld	(3392:16), wa	; F6467D  ld (0x0d40),WA
	ld	(BStore_ErrorCode:16), 0	; F64681  ld (0x0d4a),0x00
	ld	a, 1:opc	; F64686  ld A,0x01
SongEdit_CheckFreeBlocksForCopy_Join:
	cp	a, (0x0ca2:16)	; F64688  cp A,(0x0ca2)
	jr	ule, SongEdit_CheckFreeBlocksForCopy_Skip	; F6468C  jr ULE,0xf64691
	jrl	SongEdit_CheckFreeBlocksForCopy_Return	; F6468E  jrl T,0xf647dc
SongEdit_CheckFreeBlocksForCopy_Skip:
	ld	(3214:16), a	; F64691  ld (0x0c8e),A
	calr	BStore_ValidateSavedCursor	; F64695  calr 0xf62c7e
	cp	(BStore_ErrorCode:16), 0x00	; F64698  cp (0x0d4a),0x00
	jr	z, SongEdit_CheckFreeBlocksForCopy_Skip3	; F6469D  jr Z,0xf646b8
	cp	(BStore_ErrorCode:16), 0x01	; F6469F  cp (0x0d4a),0x01
	jr	z, SongEdit_CheckFreeBlocksForCopy_Skip2	; F646A4  jr Z,0xf646b0
	cp	(BStore_ErrorCode:16), 0x08	; F646A6  cp (0x0d4a),0x08
	jr	z, SongEdit_CheckFreeBlocksForCopy_Skip2	; F646AB  jr Z,0xf646b0
	jrl	SongEdit_CheckFreeBlocksForCopy_Return	; F646AD  jrl T,0xf647dc
SongEdit_CheckFreeBlocksForCopy_Skip2:
	ld	(BStore_ErrorCode:16), 0	; F646B0  ld (0x0d4a),0x00
	jrl	SongEdit_CheckFreeBlocksForCopy_Join3	; F646B5  jrl T,0xf647d3
SongEdit_CheckFreeBlocksForCopy_Skip3:
	calr	Seq_FindMasterTrack	; F646B8  calr 0xf6360e
	ld	hl, (3189:16)	; F646BB  ld HL,(0x0c75)
	ld	(3216:16), hl	; F646BF  ld (0x0c90),HL
	ld	a, (3214:16)	; F646C3  ld A,(0x0c8e)
	calr	BStore_SeekMeasure	; F646C7  calr 0xf62cfe
	cp	(BStore_ErrorCode:16), 0x00	; F646CA  cp (0x0d4a),0x00
	jr	z, SongEdit_CheckFreeBlocksForCopy_Join2	; F646CF  jr Z,0xf646fc
	cp	(BStore_ErrorCode:16), 0x01	; F646D1  cp (0x0d4a),0x01
	jr	z, SongEdit_CheckFreeBlocksForCopy_Skip5	; F646D6  jr Z,0xf646f4
	cp	(BStore_ErrorCode:16), 0x08	; F646D8  cp (0x0d4a),0x08
	jr	z, SongEdit_CheckFreeBlocksForCopy_Skip4	; F646DD  jr Z,0xf646e2
	jrl	SongEdit_CheckFreeBlocksForCopy_Return	; F646DF  jrl T,0xf647dc
SongEdit_CheckFreeBlocksForCopy_Skip4:
	ld	wa, (3187:16)	; F646E2  ld WA,(0x0c73)
	cp	wa, (0x0c75:16)	; F646E6  cp WA,(0x0c75)
	jrl	ugt, SongEdit_CheckFreeBlocksForCopy_Return	; F646EA  jrl UGT,0xf647dc
	ld	(BStore_ErrorCode:16), 0	; F646ED  ld (0x0d4a),0x00
	jr	SongEdit_CheckFreeBlocksForCopy_Join2	; F646F2  jr T,0xf646fc
SongEdit_CheckFreeBlocksForCopy_Skip5:
	ld	(BStore_ErrorCode:16), 0	; F646F4  ld (0x0d4a),0x00
	jrl	SongEdit_CheckFreeBlocksForCopy_Join3	; F646F9  jrl T,0xf647d3
SongEdit_CheckFreeBlocksForCopy_Join2:
	ld	hl, (BStore_CursorBlock:16)	; F646FC  ld HL,(0x345c)
	calr	sub_F6353E	; F64700  calr 0xf6353e
	cp	(BStore_ErrorCode:16), 0x00	; F64703  cp (0x0d4a),0x00
	jr	z, SongEdit_CheckFreeBlocksForCopy_Skip7	; F64708  jr Z,0xf6471e
	cp	(BStore_ErrorCode:16), 0x07	; F6470A  cp (0x0d4a),0x07
	jr	z, SongEdit_CheckFreeBlocksForCopy_Skip6	; F6470F  jr Z,0xf64714
	jrl	SongEdit_CheckFreeBlocksForCopy_Return	; F64711  jrl T,0xf647dc
SongEdit_CheckFreeBlocksForCopy_Skip6:
	or	(0x0c8a:16), 0x10	; F64714  or (0x0c8a),0x10
	ld	(BStore_ErrorCode:16), 0	; F64719  ld (0x0d4a),0x00
SongEdit_CheckFreeBlocksForCopy_Skip7:
	ld	wa, (BStore_AllocBytesWanted:16)	; F6471E  ld WA,(0x0cae)
	ld	(3394:16), wa	; F64722  ld (0x0d42),WA
	ld	wa, (3187:16)	; F64726  ld WA,(0x0c73)
	ld	(3216:16), wa	; F6472A  ld (0x0c90),WA
	ld	w, (3357:16)	; F6472E  ld W,(0x0d1d)
	ld	a, (3214:16)	; F64732  ld A,(0x0c8e)
	calr	BStore_SeekMeasure	; F64736  calr 0xf62cfe
	cp	(BStore_ErrorCode:16), 0x00	; F64739  cp (0x0d4a),0x00
	jr	z, SongEdit_CheckFreeBlocksForCopy_Skip8	; F6473E  jr Z,0xf64750
	cp	(BStore_ErrorCode:16), 0x08	; F64740  cp (0x0d4a),0x08
	jrl	nz, SongEdit_CheckFreeBlocksForCopy_Return	; F64745  jrl NZ,0xf647dc
	ld	(BStore_ErrorCode:16), 0	; F64748  ld (0x0d4a),0x00
	jrl	SongEdit_CheckFreeBlocksForCopy_Join3	; F6474D  jrl T,0xf647d3
SongEdit_CheckFreeBlocksForCopy_Skip8:
	ld	hl, (BStore_CursorBlock:16)	; F64750  ld HL,(0x345c)
	calr	sub_F6353E	; F64754  calr 0xf6353e
	cp	(BStore_ErrorCode:16), 0x00	; F64757  cp (0x0d4a),0x00
	jr	z, SongEdit_CheckFreeBlocksForCopy_Skip10	; F6475C  jr Z,0xf64772
	cp	(BStore_ErrorCode:16), 0x07	; F6475E  cp (0x0d4a),0x07
	jr	z, SongEdit_CheckFreeBlocksForCopy_Skip9	; F64763  jr Z,0xf64768
	jrl	SongEdit_CheckFreeBlocksForCopy_Return	; F64765  jrl T,0xf647dc
SongEdit_CheckFreeBlocksForCopy_Skip9:
	or	(0x0c8a:16), 0x08	; F64768  or (0x0c8a),0x08
	ld	(BStore_ErrorCode:16), 0	; F6476D  ld (0x0d4a),0x00
SongEdit_CheckFreeBlocksForCopy_Skip10:
	ld	wa, (3394:16)	; F64772  ld WA,(0x0d42)
	cp	wa, (BStore_AllocBytesWanted:16)	; F64776  cp WA,(0x0cae)
	jr	ugt, SongEdit_CheckFreeBlocksForCopy_Skip11	; F6477A  jr UGT,0xf64780
	jr	c, SongEdit_CheckFreeBlocksForCopy_Skip13	; F6477C  jr C,0xf647a3
	jr	z, SongEdit_CheckFreeBlocksForCopy_Join3	; F6477E  jr Z,0xf647d3
SongEdit_CheckFreeBlocksForCopy_Skip11:
	sub	wa, (BStore_AllocBytesWanted:16)	; F64780  sub WA,(0x0cae)
	bit	4, (0x0c8a:16)	; F64784  bit 4,(0x0c8a)
	jr	z, SongEdit_CheckFreeBlocksForCopy_Skip12	; F64788  jr Z,0xf64792
	bit	3, (0x0c8a:16)	; F6478A  bit 3,(0x0c8a)
	jr	nz, SongEdit_CheckFreeBlocksForCopy_Skip12	; F6478E  jr NZ,0xf64792
	dec	1, wa	; F64790  dec 1,WA
SongEdit_CheckFreeBlocksForCopy_Skip12:
	ld	(BStore_AllocBytesWanted:16), wa	; F64792  ld (0x0cae),WA
	calr	BStore_BlocksFreedByShrink	; F64796  calr 0xf64838
	ld	wa, (3390:16)	; F64799  ld WA,(0x0d3e)
	add	(0x0d40:16), wa	; F6479D  add (0x0d40),WA
	jr	SongEdit_CheckFreeBlocksForCopy_Join3	; F647A1  jr T,0xf647d3
SongEdit_CheckFreeBlocksForCopy_Skip13:
	sub	(BStore_AllocBytesWanted:16), wa	; F647A3  sub (0x0cae),WA
	bit	4, (0x0c8a:16)	; F647A7  bit 4,(0x0c8a)
	jr	z, SongEdit_CheckFreeBlocksForCopy_Skip14	; F647AB  jr Z,0xf647b7
	bit	3, (0x0c8a:16)	; F647AD  bit 3,(0x0c8a)
	jr	nz, SongEdit_CheckFreeBlocksForCopy_Skip14	; F647B1  jr NZ,0xf647b7
	incw	1, (BStore_AllocBytesWanted:16)	; F647B3  incw 1,(0x0cae)
SongEdit_CheckFreeBlocksForCopy_Skip14:
	calr	BStore_BlocksNeededToGrow	; F647B7  calr 0xf647dd
	ld	wa, (3392:16)	; F647BA  ld WA,(0x0d40)
	cp	wa, (0x0d3e:16)	; F647BE  cp WA,(0x0d3e)
	jr	nc, SongEdit_CheckFreeBlocksForCopy_Skip15	; F647C2  jr NC,0xf647cb
	ld	(BStore_ErrorCode:16), 5	; F647C4  ld (0x0d4a),0x05
	jr	SongEdit_CheckFreeBlocksForCopy_Return	; F647C9  jr T,0xf647dc
SongEdit_CheckFreeBlocksForCopy_Skip15:
	sub	wa, (0x0d3e:16)	; F647CB  sub WA,(0x0d3e)
	ld	(3392:16), wa	; F647CF  ld (0x0d40),WA
SongEdit_CheckFreeBlocksForCopy_Join3:
	ld	a, (3214:16)	; F647D3  ld A,(0x0c8e)
	inc	1, a	; F647D7  inc 1,A
	jrl	SongEdit_CheckFreeBlocksForCopy_Join	; F647D9  jrl T,0xf64688
SongEdit_CheckFreeBlocksForCopy_Return:
	ret	; F647DC  ret
; BStore_BlocksNeededToGrow: (0x0D3E) := the blocks entry (0x0C8E) must allocate to grow by BStore_AllocBytesWanted
;   bytes past its saved end cursor: 0 if they fit in the 255 - offset (0x6034A0[n-1]) left in the end block, else
;   ceil(rest / 251); a master-track entry (BStore_TrackToPart 0x20) first adds 10 bytes. The free-space pre-checks
;   SongEdit_CheckFreeBlocksForInsert (MeasureInsert_Execute, via T_SongEdit_CheckFreeBlocksForInsert) and SongEdit_CheckFreeBlocksForCopy (SongEdit_CopyMeasures, via T_SongEdit_CheckFreeBlocksForCopy) charge it
;   against a copy of BStore_FreeCount in (0x0D40), error 5 when short. Basis: callers + their named callers + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave5_r.json)
BStore_BlocksNeededToGrow:		; <- T_BStore_BlocksNeededToGrow
	xor	hl, hl	; F647DD  xor HL,HL
	ld	l, (3214:16)	; F647DF  ld L,(0x0c8e)
	dec	1, hl	; F647E3  dec 1,HL
	push	xde	; F647E5  push XDE
	ld	xde, BStore_TrackToPart	; F647E6  ld XDE,0x00603422
	cp	(xde+hl), 0x20	; F647EB  cp (XDE+HL),0x20
	pop	xde	; F647F1  pop XDE
	jr	nz, BStore_BlocksNeededToGrow_Skip	; F647F2  jr NZ,0xf647fa
	addw	(BStore_AllocBytesWanted:16), 0x000a	; F647F4  add (0x0cae),0x000a
BStore_BlocksNeededToGrow_Skip:
	xor	wa, wa	; F647FA  xor WA,WA
	ldw	wa, 255	; F647FC  ld WA,0x00ff
	push	xde	; F647FF  push XDE
	ld	xde, 6304928	; F64800  ld XDE,0x006034a0
	sub	a, (xde+hl)	; F64805  sub A,(XDE+HL)
	pop	xde	; F6480A  pop XDE
	cp	(BStore_AllocBytesWanted:16), wa	; F6480B  cp (0x0cae),WA
	jr	ugt, BStore_BlocksNeededToGrow_Skip2	; F6480F  jr UGT,0xf64816
	ldw	wa, 0	; F64811  ld WA,0x0000
	jr	BStore_BlocksNeededToGrow_Join	; F64814  jr T,0xf64833
BStore_BlocksNeededToGrow_Skip2:
	ld	de, (BStore_AllocBytesWanted:16)	; F64816  ld DE,(0x0cae)
	sub	de, wa	; F6481A  sub DE,WA
	ldw	wa, 256	; F6481C  ld WA,0x0100
	sub	wa, 5	; F6481F  sub WA,0x0005
	ld	hl, wa	; F64823  ld HL,WA
	add	wa, de	; F64825  add WA,DE
	dec	1, wa	; F64827  dec 1,WA
	xor	de, de	; F64829  xor DE,DE
	ld	qwa, de	; F6482B  ld QWA,DE
	div	xwa, hl	; F6482E  div XWA,HL
	ld	de, qwa	; F64830  ld DE,QWA
BStore_BlocksNeededToGrow_Join:
	ld	(3390:16), wa	; F64833  ld (0x0d3e),WA
	ret	; F64837  ret
; BStore_BlocksFreedByShrink: (0x0D3E) := the blocks released when entry (0x0C8E) shrinks by BStore_AllocBytesWanted
;   bytes: 0 if they fit in the end block's offset - 5 payload bytes (offset = saved end cursor 0x6034A0[n-1]), else
;   (bytes - used) / 251 + 1. SongEdit_CheckFreeBlocksForCopy, SongEdit_CopyMeasures' free-space pre-check (via T_SongEdit_CheckFreeBlocksForCopy), adds it back to
;   its free-block budget (0x0D40) for a track whose range shrinks; twin of BStore_BlocksNeededToGrow. Basis: caller + its named
;   caller + body. (notes/naming-pilot-2026-10-06/proposals_wave5_r.json)
BStore_BlocksFreedByShrink:		; <- T_BStore_BlocksFreedByShrink
	xor	hl, hl	; F64838  xor HL,HL
	ld	l, (3214:16)	; F6483A  ld L,(0x0c8e)
	dec	1, hl	; F6483E  dec 1,HL
	xor	wa, wa	; F64840  xor WA,WA
	push	xde	; F64842  push XDE
	ld	xde, 6304928	; F64843  ld XDE,0x006034a0
	ld	a, (xde+hl)	; F64848  ld A,(XDE+HL)
	pop	xde	; F6484D  pop XDE
	sub	wa, 5	; F6484E  sub WA,0x0005
	cp	(BStore_AllocBytesWanted:16), wa	; F64852  cp (0x0cae),WA
	jr	ugt, BStore_BlocksFreedByShrink_Skip	; F64856  jr UGT,0xf6485d
	ldw	wa, 0	; F64858  ld WA,0x0000
	jr	BStore_BlocksFreedByShrink_Join	; F6485B  jr T,0xf64878
BStore_BlocksFreedByShrink_Skip:
	ld	de, (BStore_AllocBytesWanted:16)	; F6485D  ld DE,(0x0cae)
	sub	de, wa	; F64861  sub DE,WA
	ldw	hl, 256	; F64863  ld HL,0x0100
	sub	hl, 5	; F64866  sub HL,0x0005
	ld	wa, de	; F6486A  ld WA,DE
	xor	de, de	; F6486C  xor DE,DE
	ld	qwa, de	; F6486E  ld QWA,DE
	div	xwa, hl	; F64871  div XWA,HL
	ld	de, qwa	; F64873  ld DE,QWA
	inc	1, wa	; F64876  inc 1,WA
BStore_BlocksFreedByShrink_Join:
	ld	(3390:16), wa	; F64878  ld (0x0d3e),WA
	ret	; F6487C  ret
; SongEdit_PadDestTrackToMeasure: MEASURE COPY when destination track (0x0C8F) ends before measure (0x0C75) (seek
;   error 8): counts its measures (SongEdit_CountDestTrackMeasures), sizes the 0x81 beat marks that finish its last measure plus
;   (0x0C75)-count-1 more (SongEdit_SizeDestTrackPadding), grows the chain (BStore_AllocChain), fills them and a closing 0x82
;   (SongEdit_WriteDestTrackPadding), saves the end cursor. Reached only through T_SongEdit_PadDestTrackToMeasure. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_t.json)
SongEdit_PadDestTrackToMeasure:		; <- T_SongEdit_PadDestTrackToMeasure
	ld	(BStore_ErrorCode:16), 0	; F6487D  ld (0x0d4a),0x00
	calr	SongEdit_CountDestTrackMeasures	; F64882  calr 0xf648f2
	cp	(BStore_ErrorCode:16), 0x00	; F64885  cp (0x0d4a),0x00
	jr	nz, SongEdit_PadDestTrackToMeasure_Return	; F6488A  jr NZ,0xf648f1
	ld	wa, (3189:16)	; F6488C  ld WA,(0x0c75)
	sub	wa, de	; F64890  sub WA,DE
	dec	1, wa	; F64892  dec 1,WA
	ld	(3404:16), wa	; F64894  ld (0x0d4c),WA
	calr	SongEdit_SizeDestTrackPadding	; F64898  calr 0xf6498d
	cp	(BStore_ErrorCode:16), 0x00	; F6489B  cp (0x0d4a),0x00
	jr	nz, SongEdit_PadDestTrackToMeasure_Return	; F648A0  jr NZ,0xf648f1
	ld	wa, (3276:16)	; F648A2  ld WA,(0x0ccc)
	ld	(BStore_LinkBlock:16), wa	; F648A6  ld (0x0cc0),WA
	ld	wa, (3278:16)	; F648AA  ld WA,(0x0cce)
	ld	(BStore_LastBlockUsed:16), wa	; F648AE  ld (0x0cc6),WA
	calr	BStore_AllocChain	; F648B2  calr 0xf63988
	cp	(BStore_ErrorCode:16), 0x00	; F648B5  cp (0x0d4a),0x00
	jr	nz, SongEdit_PadDestTrackToMeasure_Return	; F648BA  jr NZ,0xf648f1
	ld	(3300:16), de	; F648BC  ld (0x0ce4),DE
	ld	wa, (BStore_LastBlockFree:16)	; F648C0  ld WA,(0x0d08)
	ld	(3302:16), wa	; F648C4  ld (0x0ce6),WA
	calr	SongEdit_WriteDestTrackPadding	; F648C8  calr 0xf64a34
	cp	(BStore_ErrorCode:16), 0x00	; F648CB  cp (0x0d4a),0x00
	jr	nz, SongEdit_PadDestTrackToMeasure_Return	; F648D0  jr NZ,0xf648f1
	xor	wa, wa	; F648D2  xor WA,WA
	ld	a, (3215:16)	; F648D4  ld A,(0x0c8f)
	ld	(3354:16), wa	; F648D8  ld (0x0d1a),WA
	ld	ix, iy	; F648DC  ld IX,IY
	ld	(3278:16), iy	; F648DE  ld (0x0cce),IY
	ld	wa, (3260:16)	; F648E2  ld WA,(0x0cbc)
	ld	(3159:16), wa	; F648E6  ld (0x0c57),WA
	ld	(3276:16), wa	; F648EA  ld (0x0ccc),WA
	calr	BStore_SaveCursor	; F648EE  calr 0xf63924
SongEdit_PadDestTrackToMeasure_Return:
	ret	; F648F1  ret
; SongEdit_CountDestTrackMeasures: MEASURE COPY: counts the measures of destination track (0x0C8F) -- seeks it to
;   measure 1 (BStore_SeekMeasure, time signatures from the master track found by Seq_FindMasterTrack), then walks
;   (0x0D1C) 0x81 beat marks per measure, re-reading the meter per measure (sub_F63749,
;   BStore_TimeSigNextMeasure_Call's target), until the 0x82 end tag: DE = measures up to and including the one
;   holding the end tag. Called only by SongEdit_PadDestTrackToMeasure. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_x.json)
SongEdit_CountDestTrackMeasures:
	ld	(BStore_ErrorCode:16), 0	; F648F2  ld (0x0d4a),0x00
	calr	Seq_FindMasterTrack	; F648F7  calr 0xf6360e
	ld	a, (3215:16)	; F648FA  ld A,(0x0c8f)
	ldw	(3216:16), 1	; F648FE  ld (0x0c90),0x0001
	calr	BStore_SeekMeasure	; F64904  calr 0xf62cfe
	cp	(BStore_ErrorCode:16), 0x00	; F64907  cp (0x0d4a),0x00
	jrl	nz, SongEdit_CountDestTrackMeasures_Return	; F6490C  jrl NZ,0xf6498c
	ld	(3262:16), iy	; F6490F  ld (0x0cbe),IY
	ld	wa, (BStore_CursorBlock:16)	; F64913  ld WA,(0x345c)
	ld	(3260:16), wa	; F64917  ld (0x0cbc),WA
	xor	de, de	; F6491B  xor DE,DE
SongEdit_CountDestTrackMeasures_Join:
	xor	c, c	; F6491D  xor C,C
SongEdit_CountDestTrackMeasures_Join2:
	cp	c, (0x0d1c:16)	; F6491F  cp C,(0x0d1c)
	jr	z, SongEdit_CountDestTrackMeasures_Skip2	; F64923  jr Z,0xf6495e
SongEdit_CountDestTrackMeasures_Join3:
	push	xde	; F64925  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F64926  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F6492A  ld A,(XDE+IY)
	pop	xde	; F6492F  pop XDE
	cp	a, 130	; F64930  cp A,0x82
	jr	z, SongEdit_CountDestTrackMeasures_Skip3	; F64933  jr Z,0xf6498a
	cp	a, 129	; F64935  cp A,0x81
	jr	nz, SongEdit_CountDestTrackMeasures_Skip	; F64938  jr NZ,0xf6494d
	inc	1, c	; F6493A  inc 1,C
	pushw	de	; F6493C  push DE
	pushw	bc	; F6493D  push BC
	call	T_BStore_ReadCursorAdvance_Call	; F6493E  call 0xf4270c
	popw	bc	; F64942  pop BC
	popw	de	; F64943  pop DE
	cp	(BStore_ErrorCode:16), 0x00	; F64944  cp (0x0d4a),0x00
	jr	nz, SongEdit_CountDestTrackMeasures_Return	; F64949  jr NZ,0xf6498c
	jr	SongEdit_CountDestTrackMeasures_Join2	; F6494B  jr T,0xf6491f
SongEdit_CountDestTrackMeasures_Skip:
	pushw	de	; F6494D  push DE
	pushw	bc	; F6494E  push BC
	call	T_BStore_ReadCursorAdvance_Call	; F6494F  call 0xf4270c
	popw	bc	; F64953  pop BC
	popw	de	; F64954  pop DE
	cp	(BStore_ErrorCode:16), 0x00	; F64955  cp (0x0d4a),0x00
	jr	nz, SongEdit_CountDestTrackMeasures_Return	; F6495A  jr NZ,0xf6498c
	jr	SongEdit_CountDestTrackMeasures_Join3	; F6495C  jr T,0xf64925
SongEdit_CountDestTrackMeasures_Skip2:
	push	xiz	; F6495E  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F6495F  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F64963  ld XDE3,XIZ
	pop	xiz	; F64966  pop XIZ
	push_lerp	0x38	; F64967  push XDE3
	pushw	de	; F6496A  push DE
	pushw	bc	; F6496B  push BC
	push	xiy	; F6496C  push XIY
	calr	sub_F63749	; F6496D  calr 0xf63749
	pop	xiy	; F64970  pop XIY
	popw	bc	; F64971  pop BC
	popw	de	; F64972  pop DE
	pop_lerp	0x38	; F64973  pop XDE3
	push	xiz	; F64976  push XIZ
	ldto_lerp	xiz, 0x38	; F64977  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F6497A  ld (0x126e),XIZ
	pop	xiz	; F6497E  pop XIZ
	cp	(BStore_ErrorCode:16), 0x00	; F6497F  cp (0x0d4a),0x00
	jr	nz, SongEdit_CountDestTrackMeasures_Return	; F64984  jr NZ,0xf6498c
	inc	1, de	; F64986  inc 1,DE
	jr	SongEdit_CountDestTrackMeasures_Join	; F64988  jr T,0xf6491d
SongEdit_CountDestTrackMeasures_Skip3:
	inc	1, de	; F6498A  inc 1,DE
SongEdit_CountDestTrackMeasures_Return:
	ret	; F6498C  ret
; SongEdit_SizeDestTrackPadding: MEASURE COPY: BStore_AllocBytesWanted := the 0x81 beat marks that complete
;   destination track (0x0C8F)'s last measure ((0x0D1C) minus the marks already in it, after BStore_SeekMeasure to
;   measure DE) plus (0x0D1C) for each of (0x0D4C) further measures (meter re-read per measure by sub_F63749), plus 1
;   for the 0x82 end tag. SongEdit_PadDestTrackToMeasure then grows the chain by that many bytes (BStore_AllocChain).
;   Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave7_x.json)
SongEdit_SizeDestTrackPadding:
	ld	(BStore_ErrorCode:16), 0	; F6498D  ld (0x0d4a),0x00
	ld	w, (3357:16)	; F64992  ld W,(0x0d1d)
	ld	a, (3215:16)	; F64996  ld A,(0x0c8f)
	ld	(3216:16), de	; F6499A  ld (0x0c90),DE
	calr	BStore_SeekMeasure	; F6499E  calr 0xf62cfe
	cp	(BStore_ErrorCode:16), 0x00	; F649A1  cp (0x0d4a),0x00
	jrl	nz, SongEdit_SizeDestTrackPadding_Return	; F649A6  jrl NZ,0xf64a33
	xor	bc, bc	; F649A9  xor BC,BC
	ldw	(BStore_AllocBytesWanted:16), 0	; F649AB  ld (0x0cae),0x0000
SongEdit_SizeDestTrackPadding_Join2:
	push	xde	; F649B1  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F649B2  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F649B6  ld A,(XDE+IY)
	pop	xde	; F649BB  pop XDE
	cp	a, 130	; F649BC  cp A,0x82
	jr	z, SongEdit_SizeDestTrackPadding_Skip2	; F649BF  jr Z,0xf649d6
	cp	a, 129	; F649C1  cp A,0x81
	jr	nz, SongEdit_SizeDestTrackPadding_Skip	; F649C4  jr NZ,0xf649c8
	inc	1, c	; F649C6  inc 1,C
SongEdit_SizeDestTrackPadding_Skip:
	pushw	bc	; F649C8  push BC
	calr	BStore_CursorAdvance	; F649C9  calr 0xf635c9
	popw	bc	; F649CC  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F649CD  cp (0x0d4a),0x00
	jr	nz, SongEdit_SizeDestTrackPadding_Return	; F649D2  jr NZ,0xf64a33
	jr	SongEdit_SizeDestTrackPadding_Join2	; F649D4  jr T,0xf649b1
SongEdit_SizeDestTrackPadding_Skip2:
	ld	a, (3356:16)	; F649D6  ld A,(0x0d1c)
	sub	a, c	; F649DA  sub A,C
	xor	w, w	; F649DC  xor W,W
	ld	(BStore_AllocBytesWanted:16), wa	; F649DE  ld (0x0cae),WA
	nop	; F649E2  nop
	nop	; F649E3  nop
	nop	; F649E4  nop
	nop	; F649E5  nop
	nop	; F649E6  nop
	nop	; F649E7  nop
	nop	; F649E8  nop
	nop	; F649E9  nop
	nop	; F649EA  nop
	nop	; F649EB  nop
	nop	; F649EC  nop
	nop	; F649ED  nop
	nop	; F649EE  nop
	xor	de, de	; F649EF  xor DE,DE
SongEdit_SizeDestTrackPadding_Join:
	cp	de, (0x0d4c:16)	; F649F1  cp DE,(0x0d4c)
	jr	z, SongEdit_SizeDestTrackPadding_Skip3	; F649F5  jr Z,0xf64a2f
	push	xiz	; F649F7  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F649F8  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F649FC  ld XDE3,XIZ
	pop	xiz	; F649FF  pop XIZ
	push_lerp	0x38	; F64A00  push XDE3
	push	xhl	; F64A03  push XHL
	pushw	de	; F64A04  push DE
	push	xiy	; F64A05  push XIY
	push	xix	; F64A06  push XIX
	calr	sub_F63749	; F64A07  calr 0xf63749
	pop	xix	; F64A0A  pop XIX
	pop	xiy	; F64A0B  pop XIY
	popw	de	; F64A0C  pop DE
	pop	xhl	; F64A0D  pop XHL
	pop_lerp	0x38	; F64A0E  pop XDE3
	push	xiz	; F64A11  push XIZ
	ldto_lerp	xiz, 0x38	; F64A12  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F64A15  ld (0x126e),XIZ
	pop	xiz	; F64A19  pop XIZ
	cp	(BStore_ErrorCode:16), 0x00	; F64A1A  cp (0x0d4a),0x00
	jr	nz, SongEdit_SizeDestTrackPadding_Return	; F64A1F  jr NZ,0xf64a33
	inc	1, de	; F64A21  inc 1,DE
	xor	wa, wa	; F64A23  xor WA,WA
	ld	a, (3356:16)	; F64A25  ld A,(0x0d1c)
	add	(BStore_AllocBytesWanted:16), wa	; F64A29  add (0x0cae),WA
	jr	SongEdit_SizeDestTrackPadding_Join	; F64A2D  jr T,0xf649f1
SongEdit_SizeDestTrackPadding_Skip3:
	incw	1, (BStore_AllocBytesWanted:16)	; F64A2F  incw 1,(0x0cae)
SongEdit_SizeDestTrackPadding_Return:
	ret	; F64A33  ret
; SongEdit_WriteDestTrackPadding: MEASURE COPY: from destination track's saved end cursor (block (0x0CCC) via
;   BStore_SeekBlock, offset (0x0CCE)) writes BStore_AllocBytesWanted-1 0x81 beat marks into the chain
;   BStore_AllocChain has just grown, advancing with T_BStore_ReadCursorAdvance_Call, then the 0x82 end tag. Called
;   only by SongEdit_PadDestTrackToMeasure. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_x.json)
SongEdit_WriteDestTrackPadding:
	ld	(BStore_ErrorCode:16), 0	; F64A34  ld (0x0d4a),0x00
	ld	hl, (3276:16)	; F64A39  ld HL,(0x0ccc)
	ld	(3260:16), hl	; F64A3D  ld (0x0cbc),HL
	calr	BStore_SeekBlock	; F64A41  calr 0xf63bae
	ld	iy, (3278:16)	; F64A44  ld IY,(0x0cce)
	decw	1, (BStore_AllocBytesWanted:16)	; F64A48  decw 1,(0x0cae)
	xor	de, de	; F64A4C  xor DE,DE
SongEdit_WriteDestTrackPadding_Loop:
	cp	(BStore_AllocBytesWanted:16), de	; F64A4E  cp (0x0cae),DE
	jr	z, SongEdit_WriteDestTrackPadding_Skip	; F64A52  jr Z,0xf64a6f
	ld	xhl, (BStore_CursorBlockAddr:16)	; F64A54  ld XHL,(0x126e)
	ld	(xhl+iy), 0x81	; F64A58  ld (XHL+IY),0x81
	inc	1, de	; F64A5E  inc 1,DE
	pushw	de	; F64A60  push DE
	call	T_BStore_ReadCursorAdvance_Call	; F64A61  call 0xf4270c
	popw	de	; F64A65  pop DE
	cp	(BStore_ErrorCode:16), 0x00	; F64A66  cp (0x0d4a),0x00
	jr	z, SongEdit_WriteDestTrackPadding_Loop	; F64A6B  jr Z,0xf64a4e
	jr	SongEdit_WriteDestTrackPadding_Return	; F64A6D  jr T,0xf64a79
SongEdit_WriteDestTrackPadding_Skip:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F64A6F  ld XHL,(0x126e)
	ld	(xhl+iy), 0x82	; F64A73  ld (XHL+IY),0x82
SongEdit_WriteDestTrackPadding_Return:
	ret	; F64A79  ret
sub_F64A7A:		; <- T_F42824
	ldw	(3106:16), 1	; F64A7A  ld (0x0c22),0x0001
	ldw	(3112:16), 1	; F64A80  ld (0x0c28),0x0001
	ldw	(3116:16), 1	; F64A86  ld (0x0c2c),0x0001
	ldw	(3122:16), 1	; F64A8C  ld (0x0c32),0x0001
	ldw	(3544:16), 1	; F64A92  ld (0x0dd8),0x0001
	ldw	(3550:16), 1	; F64A98  ld (0x0dde),0x0001
	ret	; F64A9E  ret
sub_F64A34_Join:
	ld	a, (UI_ScreenLatch:16)	; F64A9F  ld A,(0x207a)
	cp	a, 69	; F64AA3  cp A,0x45
	jr	z, sub_F64A34_Skip2	; F64AA6  jr Z,0xf64ab7
	cp	a, 13	; F64AA8  cp A,0x0d
	jr	z, sub_F64A34_Skip2	; F64AAB  jr Z,0xf64ab7
	cp	a, 19	; F64AAD  cp A,0x13
	jr	z, sub_F64A34_Skip2	; F64AB0  jr Z,0xf64ab7
	cp	a, 73	; F64AB2  cp A,0x49
	jr	nz, sub_F64A34_Skip3	; F64AB5  jr NZ,0xf64abf
sub_F64A34_Skip2:
	ld	(4684:16), 0	; F64AB7  ld (0x124c),0x00
	jrl	sub_F64A34_Return2	; F64ABC  jrl T,0xf64b1a
sub_F64A34_Skip3:
	ld	a, (UiEvent_Byte1:16)	; F64ABF  ld A,(0x20b8)
	cp	a, 3:i3	; F64AC3  cp A,3
	jr	nz, sub_F64A34_Return2	; F64AC5  jr NZ,0xf64b1a
	ld	a, (UiEvent_Byte2:16)	; F64AC7  ld A,(0x20b9)
	ld	w, (UiEvent_Byte3:16)	; F64ACB  ld W,(0x20ba)
	cp	w, 255	; F64ACF  cp W,0xff
	jr	z, sub_F64A34_Return2	; F64AD2  jr Z,0xf64b1a
	bit	2, w	; F64AD4  bit 0x02,W
	jr	nz, sub_F64A34_Skip4	; F64AD7  jr NZ,0xf64adb
	jr	sub_F64A34_Return2	; F64AD9  jr T,0xf64b1a
sub_F64A34_Skip4:
	bit	0, (0x124c:16)	; F64ADB  bit 0,(0x124c)
	jr	z, sub_F64A34_Skip5	; F64ADF  jr Z,0xf64ae8
	and	(0x124c:16), 0xfe	; F64AE1  and (0x124c),0xfe
	jr	sub_F64A34_Return2	; F64AE6  jr T,0xf64b1a
sub_F64A34_Skip5:
	and	a, w	; F64AE8  and A,W
	and	a, 4	; F64AEA  and A,0x04
	bit	2, a	; F64AED  bit 0x02,A
	jr	z, sub_F64A34_Skip6	; F64AF0  jr Z,0xf64b07
	call	T_F40A20	; F64AF2  call 0xf40a20
	or	(0x34d4:16), 0x10	; F64AF6  or (0x34d4),0x10
	call	T_F40CB4	; F64AFB  call 0xf40cb4
	ld	(6304966:24), 255	; F64AFF  ld (0x6034c6),0xff
	jr	sub_F64A34_Return2	; F64B05  jr T,0xf64b1a
sub_F64A34_Skip6:
	call	T_F40A20	; F64B07  call 0xf40a20
	or	(0x34d4:16), 0x10	; F64B0B  or (0x34d4),0x10
	call	T_F40CB4	; F64B10  call 0xf40cb4
	ld	(6304966:24), 0	; F64B14  ld (0x6034c6),0x00
sub_F64A34_Return2:
	ret	; F64B1A  ret
; BStore_LoadSongFromCurrentBank: Makes bank BStore_CurrentBank the current song: saves BStore_FreeHead /
;   BStore_FreeCount in (0x0E2B) / (0x0E2D) so BStore_Workspace_LoadFromBank keeps the shared heap's free list across
;   its 0xC00-byte copy, then SongGmFlag_ApplyAndRebuildRouting matches GM mode (0x7F4D) bit 2 to the song's +0xC6 flag (posting the change
;   to CPU 2) and rebuilds note routing, then T_Seq_ApplySongBeatsPerBar and (0x360B) bit 0 cleared.
;   Medley_LoadInternalSong calls it (T_BStore_LoadSongFromCurrentBank) right after BStore_CurrentBank := the song; prom_a's
;   S0ngSelectName_LoadSongFromBank does the same steps inline. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_r.json)
BStore_LoadSongFromCurrentBank:		; <- T_BStore_LoadSongFromCurrentBank
	ld	wa, (BStore_FreeHead:24)	; F64B1B  ld WA,(0x6034b8)
	ld	(3627:16), wa	; F64B20  ld (0x0e2b),WA
	ld	wa, (BStore_FreeCount:24)	; F64B24  ld WA,(0x6034ba)
	ld	(3629:16), wa	; F64B29  ld (0x0e2d),WA
	calr	BStore_Workspace_LoadFromBank	; F64B2D  calr 0xf64b3d
	calr	SongGmFlag_ApplyAndRebuildRouting	; F64B30  calr 0xf64b7a
	call	T_Seq_ApplySongBeatsPerBar	; F64B33  call 0xf40ac8
	and	(0x360b:16), 0xfe	; F64B37  and (0x360b),0xfe
	ret	; F64B3C  ret

; --------------------------------------------------------------------------
; BStore_Workspace_LoadFromBank -- 0x603400 <- bank (0x360A)
;
; Called from:
;   2 call sites inside the module:
;     0xF64B2D 0xF64BDF
;   (both lists are emitted by this script, not typed)
; What it does: `ldir` of 0x0C00 bytes from 0x00610000 + (0x360A)*0xC00 to
;   0x00603400, then (0x360C) = the long at 0x0060341E.
; Evidence: 0xF64B4E `ld XIY,0x00610000` (source), 0xF64B54 `ld XIX,0x00603400`
;   (destination -- see the ldir direction citation on BStore_CopyAcrossBlocks),
;   `ld BC,0x0C00`; the index is `sla 0x0B` + `sla 0x0A` of (0x360A), i.e.
;   n*0x800 + n*0x400 = n*0xC00.
; WHAT THIS SAYS ABOUT THE MEMORY MAP.  0x603400-0x603FFF is exactly the 3 KiB
;   that notes/FINDINGS-memory-map.md records as `work DRAM, deliberately NOT
;   cleared and live' -- the one hole in prom_a's two boot clear loops.  This
;   routine and its mirror are what that hole is for.  prom_a bounds (0x360A):
;   0xF8143F `cp A,0` refuses to decrement below 0 and 0xF814D2 `cp A,0x09`
;   refuses to increment past 9, so n is 0..9 -- TEN banks.  Ten banks of 0xC00
;   starting at 0x610000 end at 0x617800, which is the block store's base.
;   Two independently derived constants abut with no slack.
; Unknown: that abutment is consistency, not proof that the two regions were
;   laid out as one.
; --------------------------------------------------------------------------
BStore_Workspace_LoadFromBank:
	xor	xwa, xwa	; F64B3D  xor XWA,XWA
	ld	a, (BStore_CurrentBank:16)	; F64B3F  ld A,(0x360a)
	ld	xix, xwa	; F64B43  ld XIX,XWA
	sla	xwa, 11	; F64B45  sla 0x0b,XWA
	sla	xix, 10	; F64B48  sla 0x0a,XIX
	add	xwa, xix	; F64B4B  add XWA,XIX
	ld	xiy, 6356992	; F64B4D  ld XIY,0x00610000
	add	xiy, xwa	; F64B52  add XIY,XWA
	ld	xix, 6304768	; F64B54  ld XIX,0x00603400
	ldw	bc, 3072	; F64B59  ld BC,0x0c00
	ldir85	; F64B5C  ldir
	ld	xwa, (6304798:24)	; F64B5E  ld XWA,(0x60341e)
	ld	(13836:16), xwa	; F64B63  ld (0x360c),XWA
	ld	wa, (3627:16)	; F64B67  ld WA,(0x0e2b)
	ld	(BStore_FreeHead:24), wa	; F64B6B  ld (0x6034b8),WA
	ld	wa, (3629:16)	; F64B70  ld WA,(0x0e2d)
	ld	(BStore_FreeCount:24), wa	; F64B74  ld (0x6034ba),WA
	ret	; F64B79  ret
; SongGmFlag_ApplyAndRebuildRouting: When GM mode (0x7F4D) bit 2 disagrees with the song's GM flag (0x6034C6 == 0xFF),
;   sets / clears it, marks the change as the song's own ((0x124C) = 1) and posts the record-0x91 byte-3 value 4 / 0
;   (Queue2C00_AppendRegs, Queue2C00_DrainPassAB); then NoteRouting_RebuildForSong. BStore_LoadSongFromCurrentBank's
;   step after the bank load; Seq_ApplyLoadedSongSetup does the same GM step inline. Basis: caller + caller header +
;   body + twin. (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
SongGmFlag_ApplyAndRebuildRouting:
	cp	(0x6034c6:24), 0xff	; F64B7A  cp (0x6034c6),0xff
	jr	z, SongGmFlag_ApplyAndRebuildRouting_Skip	; F64B80  jr Z,0xf64b91
	bit	2, (0x7f4d:16)	; F64B82  bit 2,(0x7f4d)
	jr	z, SongGmFlag_ApplyAndRebuildRouting_Skip2	; F64B86  jr Z,0xf64bb1
	and	(0x7f4d:16), 0xfb	; F64B88  and (0x7f4d),0xfb
	xor	a, a	; F64B8D  xor A,A
	jr	SongGmFlag_ApplyAndRebuildRouting_Join	; F64B8F  jr T,0xf64b9e
SongGmFlag_ApplyAndRebuildRouting_Skip:
	bit	2, (0x7f4d:16)	; F64B91  bit 2,(0x7f4d)
	jr	nz, SongGmFlag_ApplyAndRebuildRouting_Skip2	; F64B95  jr NZ,0xf64bb1
	or	(0x7f4d:16), 0x04	; F64B97  or (0x7f4d),0x04
	ld	a, 4:opc	; F64B9C  ld A,0x04
SongGmFlag_ApplyAndRebuildRouting_Join:
	ld	(4684:16), 1	; F64B9E  ld (0x124c),0x01
	ld	e, 145:opc	; F64BA3  ld E,0x91
	ld	d, 3:opc	; F64BA5  ld D,0x03
	ld	w, 4:opc	; F64BA7  ld W,0x04
	call	T_Queue2C00_AppendRegs	; F64BA9  call 0xf40f38
	call	T_Queue2C00_DrainPassAB	; F64BAD  call 0xf40018
SongGmFlag_ApplyAndRebuildRouting_Skip2:
	call	T_NoteRouting_RebuildForSong	; F64BB1  call 0xf411b8
	ret	; F64BB5  ret
; BStore_MoveWorkspaceToNextBank: (0x0E2B) / (0x0E2D) = BStore_FreeHead / FreeCount; unless BStore_CurrentBank is 0 the workspace goes back
;   to bank CurrentBank-1 (BStore_Workspace_SaveToBank); then bank CurrentBank is loaded
;   (BStore_Workspace_LoadFromBank).  Thunk T_BStore_MoveWorkspaceToNextBank, called by BStore_ClearPasswordProtectedBanks.
BStore_MoveWorkspaceToNextBank:		; <- T_BStore_MoveWorkspaceToNextBank
	ld	wa, (BStore_FreeHead:24)	; F64BB6  ld WA,(0x6034b8)
	ld	(3627:16), wa	; F64BBB  ld (0x0e2b),WA
	ld	wa, (BStore_FreeCount:24)	; F64BBF  ld WA,(0x6034ba)
	ld	(3629:16), wa	; F64BC4  ld (0x0e2d),WA
	ld	a, (BStore_CurrentBank:16)	; F64BC8  ld A,(0x360a)
	pushw	wa	; F64BCC  push WA
	cp	a, 0:i3	; F64BCD  cp A,0
	jr	z, BStore_MoveWorkspaceToNextBank_Skip3	; F64BCF  jr Z,0xf64bda
	dec	1, a	; F64BD1  dec 1,A
	ld	(BStore_CurrentBank:16), a	; F64BD3  ld (0x360a),A
	calr	BStore_Workspace_SaveToBank	; F64BD7  calr 0xf64be3
BStore_MoveWorkspaceToNextBank_Skip3:
	popw	wa	; F64BDA  pop WA
	ld	(BStore_CurrentBank:16), a	; F64BDB  ld (0x360a),A
	calr	BStore_Workspace_LoadFromBank	; F64BDF  calr 0xf64b3d
	ret	; F64BE2  ret

; --------------------------------------------------------------------------
; BStore_Workspace_SaveToBank -- bank (0x360A) <- 0x603400
;
; Called from:
;   1 call site inside the module:
;     0xF64BD7
;   (both lists are emitted by this script, not typed)
; What it does: the exact mirror of BStore_Workspace_LoadFromBank, and it
;   first writes (0x360C) out to 0x0060341E so the reload can restore it.
; Evidence: 0xF64BE3 `ld XWA,(0x360C)` / `ld (0x0060341E),XWA`, then
;   `ld XIX,0x00610000` (destination) and `ld XIY,0x00603400` (source) --
;   the two registers swapped relative to the load.
; --------------------------------------------------------------------------
BStore_Workspace_SaveToBank:
	ld	xwa, (13836:16)	; F64BE3  ld XWA,(0x360c)
	ld	(6304798:24), xwa	; F64BE7  ld (0x60341e),XWA
	ld	xix, 6356992	; F64BEC  ld XIX,0x00610000
	xor	xwa, xwa	; F64BF1  xor XWA,XWA
	xor	xhl, xhl	; F64BF3  xor XHL,XHL
	ld	l, (BStore_CurrentBank:16)	; F64BF5  ld L,(0x360a)
	ld	a, l	; F64BF9  ld A,L
	sla	xhl, 11	; F64BFB  sla 0x0b,XHL
	sla	xwa, 10	; F64BFE  sla 0x0a,XWA
	add	xhl, xwa	; F64C01  add XHL,XWA
	add	xix, xhl	; F64C03  add XIX,XHL
	ld	xiy, 6304768	; F64C05  ld XIY,0x00603400
	ldw	bc, 3072	; F64C0A  ld BC,0x0c00
	ldir85	; F64C0D  ldir
	ret	; F64C0F  ret
	.fill	1008, 1, 0x0E	; F64C10-F64FFF  ret padding
