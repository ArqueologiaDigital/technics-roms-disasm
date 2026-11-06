
; ==============================================================================
; 0xF7A400-0xF7CFFF -- THE BLOCK-STORE ALLOCATOR AND THE SONG-STORE COMMANDS
;   the free-list half of the 256-byte block heap, and the 132-entry command
;   module that drives it from the SEQUENCER screens
; ==============================================================================
;
; WHY THIS BLOCK.  notes/prom_b_module_frontier.py joins the thunk table's run
; decomposition (notes/prom_b_thunk_modules.py) with the converted/unconverted
; split (notes/prom_b_call_graph.py) and ranks runs by contiguous unconverted
; target extent.  T_BStore_AppendBytes_Join3_Veneer-T_F42ABC comes out with the most unconverted prom_b
; targets of any run in the image -- 132, every one of them inside ONE .incbin
; span, 8,906 bytes of extent, summed reference upper bound 172.  Immediately
; below it in the same span sits 0xF42880-0xF42894 (6 slots), whose target
; notes/FINDINGS-prom_b-block-store.md had already singled out:
;     "T_BStore_AllocBlock_Veneer -> 0xF7A402 is the block allocator itself -- it is what
;      BStore_AllocChain calls at 0xF63A18 for each block of a new chain.
;      It is the natural next conversion."
; Both runs are converted here, in one contiguous span.
;
; EXTENT.  0xF7A400-0xF7A7EA and 0xF7AA00-0xF7CE67 are code and data;
; 0xF7A7EB-0xF7A9FF (533 bytes) and 0xF7CE68-0xF7CFFF (408 bytes) are 0x0E
; (`ret`) padding, re-asserted to be pure 0x0E on every emit.  Below 0xF7A400
; is the font/bitmap data that FINDINGS-fonts.md covers; it stays .incbin.
;
; THE TWO HALVES
;
;  1. 0xF7A400-0xF7A7EA -- THE ALLOCATOR the block store one module down does
;     not contain.  It owns the free list: head in (0x6034B8), count in
;     (0x6034BA), 0xFFFF for "empty".  BStore_FreeList_Init threads every one of
;     the (0x3608) blocks onto it; BStore_AllocBlock pops one; BStore_FreeChain
;     splices a whole chain back.  The 256-byte record layout is exactly the one
;     FINDINGS-prom_b-block-store.md reads off 0xF63A3A/0xF63A46/0xF63A4B:
;         +0 flags (bit 7 = allocated) | +1..2 prev | +3..4 next | +5.. payload
;     BStore_AppendBytes is the writer: it appends to the chain of DIRECTORY
;     ENTRY (0x1008) -- 1-based, 3-byte stride, the same directory
;     FINDINGS-prom_b-block-store.md reads off BStore_OpenChain -- and allocates
;     a new block when the cursor would pass offset 0xFF, the new one restarting
;     at 0x100-0xFB = 5.
;
;     BStore_FreeList_Init also clears FIVE 17-entry arrays, and 17 is read off
;     its own `ld BC,0x0011` loops, not guessed:
;         0x00603500  17 x 3  the DIRECTORY (flags byte + head word 0xFFFF)
;         0x0060347E  17 x 2  saved cursor BLOCK numbers, cleared to 0xFFFF
;         0x006034A0  17 x 1  saved cursor OFFSETS, cleared to 5
;         0x00003460  17 x 2  an internal-RAM twin of the pair above
;         0x00003482  17 x 1
;     The two pairs abut exactly at 17 (0x0060347E + 17*2 = 0x006034A0) and are
;     0x22 apart, which is the displacement the append path uses
;     (`ld A,(XIX+0x22)` at 0xF7A6A5).  At 16 entries they would NOT abut.
;     Re-read on demand by `python3 notes/prom_b_songstore_checks.py --arrays`.
;     ⚠ This CORRECTS two documents: FINDINGS-memory-map.md said "16 saved
;     cursors", and FINDINGS-prom_b-block-store.md said the directory's entry
;     count was not established.
;
;  2. 0xF7AA00-0xF7CE67 -- THE COMMAND MODULE.  ⚠ The `SongStore_` prefix on
;     the data objects below names the SCREEN GROUP these handlers serve, which
;     is what the evidence reaches; it is not a proven subsystem name.  132 thunk slots, mostly small
;     handlers that read a mode byte, edit one variable, and post a message.
;     The idiom repeats: `cp (0x207E),0x01` gates on an edit mode, `or (0x2075),n`
;     and `and (0x2075),n` set and clear request bits, (0x2070) takes a 16-bit
;     message code, (0x2880) a status byte and (0x0D4A) an error code -- the same
;     two bytes the block store's error table feeds.
;
; THE TEN BANKS ARE THE TEN SONGS.  FINDINGS-prom_b-block-store.md closed with
; "What this module is FOR -- not established", and this module answers it as far
; as the bytes can.  At 0xF7AA35 the bank index the block store banks on becomes
; the number the screen shows:
;         ld A,(0x360a) / ld (0x0e02),A / inc 1,A / ld (0x12f6),A
; (0x360A) is the bank selector FINDINGS-prom_b-block-store.md derives at
; 0xF64B3D, prom_a bounds it to 0..9, this module bounds (0x0E02) the same way
; (`cp A,0x0a` at 0xF7AA99, `cp A,0x0a` / `ld A,0x09` at 0xF7AAC3 for the wrap),
; and (0x12F6) is drawn by 23 interpreter-B display-list records on the screens
; whose interpreter-A text reads SEQUENCER PLAY, S0NG, MEASURE = , TIME SIG.= ,
; REALTIME RECORD (`python3 notes/prom_b_var_screens.py --var 0x12F6`).
; ⚠ The display-list proximity is the WEAK link and the tool says so: "near:" is
; nearness in the code, not a proof that this record labels that variable.  The
; assignment chain and the two bounds are the strong part.
;
; WHAT IS NOT ESTABLISHED.  What 122 of the 132 command handlers DO.  They are
; `sub_XXXXXX` with a computed header that claims only the entry point, per this
; tree's rule that a stated gap beats a plausible guess.  Naming them needs the
; message codes in (0x2070), and nothing in this lane decodes those yet.
;
; REGENERATE:  python3 notes/gen_prom_b_songstore_module.py
; CHECKS:      python3 notes/gen_prom_b_songstore_module.py --checks
; ==============================================================================


; --------------------------------------------------------------------------
; BStore_FreeList_Init_Veneer -- veneer.  `jr T,0xF7A40A`, and 0xF7A40A is `calr 0xF7A428 /
;               ret`, so this entry point reaches BStore_FreeList_Init.
; Called from: T_BStore_FreeList_Init_Veneer (x2)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_FreeList_Init_Veneer holds `jp 0x00F7A400`; the two instructions
;           the hop passes through (0xF7A40A and 0xF7A40D) are read out of
;           this transcription by the emitter's veneer_of(), not typed.
; Unknown: why the extra hop exists.  prom_b 0xF62C00 opens with the same
;          shape and neither module explains it.
; --------------------------------------------------------------------------
; BStore_FreeList_Init_Veneer: Veneer (slot T_BStore_FreeList_Init_Veneer): `jr` to `calr BStore_FreeList_Init / ret`, which rebuilds the
;   whole heap as one free list and empties the 17 directory entries and the track cursors. SongClear_ClearBank and
;   TrackAssignPresets_ApplyToAllSongs call it to free every block; sibling of BStore_AllocBlock_Veneer /
;   BStore_FreeChain_Veneer. Basis: body (veneer) + callers. (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
BStore_FreeList_Init_Veneer:		; <- T_BStore_FreeList_Init_Veneer
	jr	BStore_LatchHeapBase_Veneer_Skip	; F7A400  jr T,0xf7a40a

; --------------------------------------------------------------------------
; BStore_AllocBlock_Veneer -- veneer.  `jr T,0xF7A40E`, and 0xF7A40E is `calr 0xF7A4DB /
;               ret`, so this entry point reaches BStore_AllocBlock.
; Called from: T_BStore_AllocBlock_Veneer (x17)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_AllocBlock_Veneer holds `jp 0x00F7A402`; the two instructions
;           the hop passes through (0xF7A40E and 0xF7A411) are read out of
;           this transcription by the emitter's veneer_of(), not typed.
; Unknown: why the extra hop exists.  prom_b 0xF62C00 opens with the same
;          shape and neither module explains it.
; --------------------------------------------------------------------------
; BStore_AllocBlock_Veneer: Veneer: `jr` to `calr BStore_AllocBlock / ret` -- allocates one block-store block (W = 0,
;   (0x126E) = its address; W = 0xFF when the free list is empty). Directory slot T_BStore_AllocBlock_Veneer, 17 callers, among them
;   BStore_AllocChain and BStore_ExtendChainAtCursor. Basis: body (veneer) + callers. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_i.json)
BStore_AllocBlock_Veneer:		; <- T_BStore_AllocBlock_Veneer
	jr	BStore_LatchHeapBase_Veneer_Join	; F7A402  jr T,0xf7a40e

; --------------------------------------------------------------------------
; BStore_FreeChain_Veneer -- veneer.  `jr T,0xF7A412`, and 0xF7A412 is `calr 0xF7A539 /
;               ret`, so this entry point reaches BStore_FreeChain.
; Called from: T_BStore_FreeChain_Veneer (x7)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_FreeChain_Veneer holds `jp 0x00F7A404`; the two instructions
;           the hop passes through (0xF7A412 and 0xF7A415) are read out of
;           this transcription by the emitter's veneer_of(), not typed.
; Unknown: why the extra hop exists.  prom_b 0xF62C00 opens with the same
;          shape and neither module explains it.
; --------------------------------------------------------------------------
; BStore_FreeChain_Veneer: Veneer: `jr` to `calr BStore_FreeChain / ret` -- frees the chain starting at block IY back
;   onto the free list (BStore_FreeHead, BStore_FreeCount += blocks). Slot T_BStore_FreeChain_Veneer (x7): SongEdit_ClearTrack,
;   BStore_TruncateChainAfterBlock, BStore_EmptyBank, SongCopy_ClearDestTrack; sibling of BStore_AllocBlock_Veneer.
;   Basis: body (veneer) + callers. (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
BStore_FreeChain_Veneer:		; <- T_BStore_FreeChain_Veneer
	jr	BStore_LatchHeapBase_Veneer_Join2	; F7A404  jr T,0xf7a412

; --------------------------------------------------------------------------
; BStore_LatchHeapBase_Veneer_Join3_Veneer -- veneer.  `jr T,0xF7A416`, and 0xF7A416 is `calr 0xF7A5FF /
;               ret`, so this entry point reaches BStore_SeekBlock_Alloc.
; Called from: T_BStore_LatchHeapBase_Veneer_Join3_Veneer (x0)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_LatchHeapBase_Veneer_Join3_Veneer holds `jp 0x00F7A406`; the two instructions
;           the hop passes through (0xF7A416 and 0xF7A419) are read out of
;           this transcription by the emitter's veneer_of(), not typed.
; Unknown: why the extra hop exists.  prom_b 0xF62C00 opens with the same
;          shape and neither module explains it.
; --------------------------------------------------------------------------
; BStore_LatchHeapBase_Veneer_Join3_Veneer: jumps to BStore_LatchHeapBase_Veneer_Join3 (notes/prom_ab_wrapper_names.py; DERIVATIVE)
BStore_LatchHeapBase_Veneer_Join3_Veneer:		; <- T_BStore_LatchHeapBase_Veneer_Join3_Veneer
	jr	BStore_LatchHeapBase_Veneer_Join3	; F7A406  jr T,0xf7a416

; --------------------------------------------------------------------------
; BStore_LatchHeapBase_Veneer
; Called from: T_BStore_LatchHeapBase_Veneer (x1)
; Touches: nothing with an absolute address
; Calls:   BStore_FreeList_Init BStore_AllocBlock BStore_FreeChain
;          BStore_SeekBlock_Alloc
; Evidence: thunk slot T_BStore_LatchHeapBase_Veneer holds `jp 0x00F7A408`, and 0xF7A408 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
BStore_LatchHeapBase_Veneer:		; <- T_BStore_LatchHeapBase_Veneer
	jr	BStore_LatchHeapBase	; F7A408  jr T,0xf7a41a
BStore_LatchHeapBase_Veneer_Skip:
	calr	BStore_FreeList_Init	; F7A40A  calr 0xf7a428
	ret	; F7A40D  ret
BStore_LatchHeapBase_Veneer_Join:
	calr	BStore_AllocBlock	; F7A40E  calr 0xf7a4db
	ret	; F7A411  ret
BStore_LatchHeapBase_Veneer_Join2:
	calr	BStore_FreeChain	; F7A412  calr 0xf7a539
	ret	; F7A415  ret
BStore_LatchHeapBase_Veneer_Join3:
	calr	BStore_SeekBlock_Alloc	; F7A416  calr 0xf7a5ff
	ret	; F7A419  ret

; --------------------------------------------------------------------------
; BStore_LatchHeapBase -- copy the 32-bit heap base (0x3604) into (0x12A2)
; Called from: no thunk slot, no in-module call site and no dispatch entry
;              -- reached only by a branch from the routine above
; Inputs:  none
; Outputs: (0x12A2) = (0x3604)
; Touches: (0x3604)  |  0x0012A2
; Evidence: the five instructions at 0xF7A41A-0xF7A427.  (0x12A2) is where
;           BStore_SeekBlock_Alloc adds the block offset, so it is the
;           allocator's private copy of the heap base; notes/FINDINGS-
;           prom_b-block-store.md fixes (0x3604) = 0x00617800 by inverse
;           arithmetic at 0xF5E2F0 and 0xF61F1C
; Unknown: why the copy is remade at the head of FOUR routines here
;          (0xF7A41A, 0xF7A428, 0xF7A4DB, 0xF7A539) instead of once at init
; --------------------------------------------------------------------------
BStore_LatchHeapBase:
	ld	xhl, BStore_AllocHeapBase	; F7A41A  ld XHL,0x000012a2
	push	xde	; F7A41F  push XDE
	ld	xde, (BStore_HeapBase:16)	; F7A420  ld XDE,(0x3604)
	ld	(xhl), xde	; F7A424  ld (XHL),XDE
	pop	xde	; F7A426  pop XDE
	ret	; F7A427  ret

; --------------------------------------------------------------------------
; BStore_FreeList_Init -- build the free list over all (0x3608) blocks and
;                         clear the five per-song arrays.  Block n gets prev
;                         = n-1, next = n+1, tag 0x82 at payload offset 0;
;                         the last block gets next = 0xFFFF.  Free-list head
;                         (0x6034B8) = 1, free count (0x6034BA) = (0x3608)
; Called from: in-module: 0xF7A40A
; Inputs:  (0x3604) heap base, (0x3608) block count
; Outputs: the whole heap, (0x6034B8), (0x6034BA), and 17 entries in each of
;          0x00603500 (3 bytes), 0x00603460 (2), 0x00603482 (1), 0x0060347E
;          (2), 0x006034A0 (1)
; Touches: (0x126E) (0x3604) (0x3608)  |  0x000003 0x000100 0x0012A2
;          0x003460 0x003482 0x60347E +2 more
; Calls:   BStore_SeekBlock_Alloc
; Evidence: `ld (0x6034b8),0x0001` at 0xF7A43B; `ld BC,(0x3608) / ld
;           (0x6034ba),BC / dec 1,BC` at 0xF7A44B-0xF7A454 followed by a
;           `djnz BC` body that writes +0x01, +0x03, +0x05 and advances `add
;           XIY,0x00000100`; the 0xFFFF terminator at 0xF7A47A.  The record
;           layout is the one notes/FINDINGS-prom_b-block-store.md reads off
;           0xF63A3A/0xF63A46/0xF63A4B
; Unknown: what the five arrays hold.  0x0060347E/0x006034A0 are the SAVED
;          CURSOR pair that block-store routine 0xF63924 writes;
;          0x00603460/0x00603482 have the same word+byte shape and the same
;          0x22 separation but no reader was traced in this module
; --------------------------------------------------------------------------
BStore_FreeList_Init:
	ld	xhl, BStore_AllocHeapBase	; F7A428  ld XHL,0x000012a2
	push	xde	; F7A42D  push XDE
	ld	xde, (BStore_HeapBase:16)	; F7A42E  ld XDE,(0x3604)
	ld	(xhl), xde	; F7A432  ld (XHL),XDE
	pop	xde	; F7A434  pop XDE
	ldw	iy, 1	; F7A435  ld IY,0x0001
	calr	BStore_SeekBlock_Alloc	; F7A438  calr 0xf7a5ff
	ldw	(BStore_FreeHead:24), 1	; F7A43B  ld (0x6034b8),0x0001
	ld	xiy, (BStore_CursorBlockAddr:16)	; F7A442  ld XIY,(0x126e)
	xor	xhl, xhl	; F7A446  xor XHL,XHL
	ldw	de, 2	; F7A448  ld DE,0x0002
	ld	bc, (BStore_BlockCount:16)	; F7A44B  ld BC,(0x3608)
	ld	(BStore_FreeCount:24), bc	; F7A44F  ld (0x6034ba),BC
	dec	1, bc	; F7A454  dec 1,BC
	and	(xiy), 0x7f	; F7A456  and (XIY),0x7f
	ld	(xiy+1), hl	; F7A459  ld (XIY+0x01),HL
	ld	(xiy+3), de	; F7A45C  ld (XIY+0x03),DE
	ld	(xiy+5), 130	; F7A45F  ld (XIY+0x05),0x82
	inc	1, hl	; F7A463  inc 1,HL
	inc	1, de	; F7A465  inc 1,DE
	add	xiy, 256	; F7A467  add XIY,0x00000100
	djnz16	bc, -26	; F7A46D  djnz BC,0xf7a456
	and	(xiy), 0x7f	; F7A470  and (XIY),0x7f
	ld	(xiy+1), hl	; F7A473  ld (XIY+0x01),HL
	ld	(xiy+5), 130	; F7A476  ld (XIY+0x05),0x82
	ldw	(xiy+3), 0xffff	; F7A47A  ld (XIY+0x03),0xffff
	ld	xhl, 6305024	; F7A47F  ld XHL,0x00603500
	ldw	bc, 17	; F7A484  ld BC,0x0011
	ld	(xhl), 0	; F7A487  ld (XHL),0x00
	ldw	(xhl+1), 0xffff	; F7A48A  ld (XHL+0x01),0xffff
	add	xhl, 3	; F7A48F  add XHL,0x00000003
	djnz16	bc, -17	; F7A495  djnz BC,0xf7a487
	ld	xhl, 13408	; F7A498  ld XHL,0x00003460
	ldw	bc, 17	; F7A49D  ld BC,0x0011
	ldw	(xhl), 0xffff	; F7A4A0  ld (XHL),0xffff
	inc	2, xhl	; F7A4A4  inc 2,XHL
	djnz16	bc, -9	; F7A4A6  djnz BC,0xf7a4a0
	ld	xhl, 13442	; F7A4A9  ld XHL,0x00003482
	ldw	bc, 17	; F7A4AE  ld BC,0x0011
	ld	(xhl), 5	; F7A4B1  ld (XHL),0x05
	inc	1, xhl	; F7A4B4  inc 1,XHL
	djnz16	bc, -8	; F7A4B6  djnz BC,0xf7a4b1
	ld	xhl, 6304894	; F7A4B9  ld XHL,0x0060347e
	ldw	bc, 17	; F7A4BE  ld BC,0x0011
	ldw	(xhl), 0xffff	; F7A4C1  ld (XHL),0xffff
	inc	2, xhl	; F7A4C5  inc 2,XHL
	djnz16	bc, -9	; F7A4C7  djnz BC,0xf7a4c1
	ld	xhl, 6304928	; F7A4CA  ld XHL,0x006034a0
	ldw	bc, 17	; F7A4CF  ld BC,0x0011
	ld	(xhl), 5	; F7A4D2  ld (XHL),0x05
	inc	1, xhl	; F7A4D5  inc 1,XHL
	djnz16	bc, -8	; F7A4D7  djnz BC,0xf7a4d2
	ret	; F7A4DA  ret

; --------------------------------------------------------------------------
; BStore_AllocBlock -- allocate one block: pop the free-list head, unlink
;                      it, set its bit 7, decrement the free count
; Called from: in-module: 0xF7A40E 0xF7A6F9 0xF7A783
; Inputs:  none
; Outputs: W = 0 on success and (0x126E) = the block's address; W = 0xFF
;          when the free list is empty
; Touches: (0x126E) (0x3604)  |  0x0012A2
; Calls:   BStore_SeekBlock_Alloc
; Evidence: `ld IY,(0x6034b8) / cp IY,0xffff / jr Z,0xf7a536` at
;           0xF7A4E8-0xF7A4F1 with 0xF7A536 doing `ld W,0xff / ret`; the
;           success path ends `ld W,0x00 / ret` at 0xF7A533.  `or
;           (XHL),0x80` at 0xF7A526 is the allocated bit that block-store's
;           `bit 7,(XHL)` tests, and `decw 1,(0x6034ba)` at 0xF7A529 is the
;           free count.  Its caller is named in notes/FINDINGS-prom_b-block-
;           store.md: BStore_AllocChain reads the same W at 0xF63A2F and
;           turns 0xFF into error code 5
; Unknown: nothing outstanding
; --------------------------------------------------------------------------
BStore_AllocBlock:
	ld	xhl, BStore_AllocHeapBase	; F7A4DB  ld XHL,0x000012a2
	push	xde	; F7A4E0  push XDE
	ld	xde, (BStore_HeapBase:16)	; F7A4E1  ld XDE,(0x3604)
	ld	(xhl), xde	; F7A4E5  ld (XHL),XDE
	pop	xde	; F7A4E7  pop XDE
	ld	iy, (BStore_FreeHead:24)	; F7A4E8  ld IY,(0x6034b8)
	cp	iy, 65535	; F7A4ED  cp IY,0xffff
	jr	z, BStore_AllocBlock_Skip2	; F7A4F1  jr Z,0xf7a536
	ld	xde, (BStore_CursorBlockAddr:16)	; F7A4F3  ld XDE,(0x126e)
	push	xde	; F7A4F7  push XDE
	calr	BStore_SeekBlock_Alloc	; F7A4F8  calr 0xf7a5ff
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7A4FB  ld XHL,(0x126e)
	ld	wa, (xhl+3)	; F7A4FF  ld WA,(XHL+0x03)
	ld	(BStore_FreeHead:24), wa	; F7A502  ld (0x6034b8),WA
	ld	ix, iy	; F7A507  ld IX,IY
	cp	wa, 65535	; F7A509  cp WA,0xffff
	jr	z, BStore_AllocBlock_Skip	; F7A50D  jr Z,0xf7a51d
	ld	iy, wa	; F7A50F  ld IY,WA
	calr	BStore_SeekBlock_Alloc	; F7A511  calr 0xf7a5ff
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7A514  ld XHL,(0x126e)
	ldw	(xhl+1), 0x0000	; F7A518  ld (XHL+0x01),0x0000
BStore_AllocBlock_Skip:
	ld	iy, ix	; F7A51D  ld IY,IX
	calr	BStore_SeekBlock_Alloc	; F7A51F  calr 0xf7a5ff
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7A522  ld XHL,(0x126e)
	or	(xhl), 0x80	; F7A526  or (XHL),0x80
	decw	1, (BStore_FreeCount:24)	; F7A529  decw 1,(0x6034ba)
	pop	xde	; F7A52E  pop XDE
	ld	(BStore_CursorBlockAddr:16), xde	; F7A52F  ld (0x126e),XDE
	ld	w, 0:opc	; F7A533  ld W,0x00
	ret	; F7A535  ret
BStore_AllocBlock_Skip2:
	ld	w, 255:opc	; F7A536  ld W,0xff
	ret	; F7A538  ret

; --------------------------------------------------------------------------
; BStore_FreeChain -- free a chain: walk it from block IY, clear each bit 7,
;                     splice the whole run back onto the free list, and add
;                     the number of blocks freed to (0x6034BA)
; Called from: in-module: 0xF7A412
; Inputs:  IY = first block of the chain, BC = the block to link on after
; Outputs: (0x6034B8) = IY, (0x6034BA) += the number of blocks freed
; Touches: (0x0C88) (0x126E) (0x3604)  |  0x0012A2
; Calls:   BStore_SeekBlock_Alloc
; Evidence: `ld BC,(0x6034b8) / ld (0x6034b8),IY` at 0xF7A54A-0xF7A54F is
;           the head swap; `and (XHL),0x7f` at 0xF7A5C2 and 0xF7A5FA clears
;           the allocated bit; the count accumulates in WA (`inc 1,WA` at
;           0xF7A5D8) and lands with `add (0x6034ba),WA` at 0xF7A5DA.
;           0xF7A5C9 `ld (XHL+0x03),BC` is what re-attaches the old head
; Unknown: (0x0C88) is used as scratch for the loop bound (`ld (0x0c88),WA`
;          at 0xF7A546, cleared at 0xF7A5F2); nothing else here reads it
; --------------------------------------------------------------------------
BStore_FreeChain:
	ld	xhl, BStore_AllocHeapBase	; F7A539  ld XHL,0x000012a2
	push	xde	; F7A53E  push XDE
	ld	xde, (BStore_HeapBase:16)	; F7A53F  ld XDE,(0x3604)
	ld	(xhl), xde	; F7A543  ld (XHL),XDE
	pop	xde	; F7A545  pop XDE
	ld	(3208:16), wa	; F7A546  ld (0x0c88),WA
	ld	bc, (BStore_FreeHead:24)	; F7A54A  ld BC,(0x6034b8)
	ld	(BStore_FreeHead:24), iy	; F7A54F  ld (0x6034b8),IY
	xor	wa, wa	; F7A554  xor WA,WA
	calr	BStore_SeekBlock_Alloc	; F7A556  calr 0xf7a5ff
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7A559  ld XHL,(0x126e)
	ld	ix, (xhl+1)	; F7A55D  ld IX,(XHL+0x01)
	ld	de, ix	; F7A560  ld DE,IX
	cp	ix, 0:i3	; F7A562  cp IX,0
	jrl	z, BStore_FreeChain_Skip3	; F7A564  jrl Z,0xf7a5e0
	ld	iy, ix	; F7A567  ld IY,IX
	ldw	(xhl+1), 0x0000	; F7A569  ld (XHL+0x01),0x0000
	calr	BStore_SeekBlock_Alloc	; F7A56E  calr 0xf7a5ff
	ld	ix, iy	; F7A571  ld IX,IY
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7A573  ld XHL,(0x126e)
	ld	iy, (xhl+3)	; F7A577  ld IY,(XHL+0x03)
BStore_FreeChain_Loop:
	calr	BStore_SeekBlock_Alloc	; F7A57A  calr 0xf7a5ff
	ld	ix, iy	; F7A57D  ld IX,IY
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7A57F  ld XHL,(0x126e)
	ld	iy, (xhl+3)	; F7A583  ld IY,(XHL+0x03)
	cp	iy, 65535	; F7A586  cp IY,0xffff
	jr	z, BStore_FreeChain_Skip	; F7A58A  jr Z,0xf7a5a7
BStore_FreeChain_Loop2:
	and	(xhl), 0x7f	; F7A58C  and (XHL),0x7f
	ld	(xhl+5), 130	; F7A58F  ld (XHL+0x05),0x82
	inc	1, wa	; F7A593  inc 1,WA
	cp	wa, (0x0c88:16)	; F7A595  cp WA,(0x0c88)
	jr	nz, BStore_FreeChain_Loop	; F7A599  jr NZ,0xf7a57a
	dec	1, wa	; F7A59B  dec 1,WA
BStore_FreeChain_Join:
	calr	BStore_SeekBlock_Alloc	; F7A59D  calr 0xf7a5ff
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7A5A0  ld XHL,(0x126e)
	ld	(xhl+1), de	; F7A5A4  ld (XHL+0x01),DE
BStore_FreeChain_Skip:
	cp	de, 0:i3	; F7A5A7  cp DE,0
	jr	z, BStore_FreeChain_Skip2	; F7A5A9  jr Z,0xf7a5b9
	pushw	iy	; F7A5AB  push IY
	ld	iy, de	; F7A5AC  ld IY,DE
	calr	BStore_SeekBlock_Alloc	; F7A5AE  calr 0xf7a5ff
	popw	iy	; F7A5B1  pop IY
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7A5B2  ld XHL,(0x126e)
	ld	(xhl+3), iy	; F7A5B6  ld (XHL+0x03),IY
BStore_FreeChain_Skip2:
	ld	iy, ix	; F7A5B9  ld IY,IX
	calr	BStore_SeekBlock_Alloc	; F7A5BB  calr 0xf7a5ff
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7A5BE  ld XHL,(0x126e)
	and	(xhl), 0x7f	; F7A5C2  and (XHL),0x7f
	ld	(xhl+5), 130	; F7A5C5  ld (XHL+0x05),0x82
	ld	(xhl+3), bc	; F7A5C9  ld (XHL+0x03),BC
	ld	iy, bc	; F7A5CC  ld IY,BC
	calr	BStore_SeekBlock_Alloc	; F7A5CE  calr 0xf7a5ff
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7A5D1  ld XHL,(0x126e)
	ld	(xhl+1), ix	; F7A5D5  ld (XHL+0x01),IX
	inc	1, wa	; F7A5D8  inc 1,WA
	add	(BStore_FreeCount:24), wa	; F7A5DA  add (0x6034ba),WA
	ret	; F7A5DF  ret
BStore_FreeChain_Skip3:
	calr	BStore_SeekBlock_Alloc	; F7A5E0  calr 0xf7a5ff
	ld	ix, iy	; F7A5E3  ld IX,IY
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7A5E5  ld XHL,(0x126e)
	ld	iy, (xhl+3)	; F7A5E9  ld IY,(XHL+0x03)
	cp	iy, 65535	; F7A5EC  cp IY,0xffff
	jr	nz, BStore_FreeChain_Loop2	; F7A5F0  jr NZ,0xf7a58c
	ldw	(3208:16), 0	; F7A5F2  ld (0x0c88),0x0000
	ld	iy, ix	; F7A5F8  ld IY,IX
	and	(xhl), 0x7f	; F7A5FA  and (XHL),0x7f
	jr	BStore_FreeChain_Join	; F7A5FD  jr T,0xf7a59d

; --------------------------------------------------------------------------
; BStore_SeekBlock_Alloc -- seek: (0x126E) = (0x12A2) + (IY-1)*0x100, i.e.
;                           address of 1-based block IY.  Returns XHL = 0
; Called from: in-module: 0xF7A416 0xF7A438 0xF7A4F8 0xF7A511 0xF7A51F
;              0xF7A556 0xF7A56E 0xF7A57A +8 more
; Inputs:  IY = block number, 1-based
; Outputs: (0x126E) = the block's address; XHL = 0
; Touches: (0x126E) (0x12A2)
; Evidence: the seven instructions at 0xF7A5FF-0xF7A612.  This is the SAME
;           arithmetic notes/FINDINGS-prom_b-block-store.md attributes to
;           BStore_SeekBlock (0xF63BAE) -- `(0x126E) = base + (n-1)*0x100`
;           -- but the two are NOT one routine: this one takes its block
;           number in IY and adds (0x12A2), the allocator's own copy of the
;           base, where 0xF63BAE takes HL and adds (0x3604) directly.  As
;           BYTES they are 20 and 18 long and differ at 18 of the first 20
;           offsets -- the diff is printed by
;           notes/prom_b_songstore_checks.py.  Two objects computing the
;           same thing, so this name carries a suffix instead of borrowing
;           0xF63BAE's outright
; Unknown: nothing outstanding
; --------------------------------------------------------------------------
BStore_SeekBlock_Alloc:
	ld	hl, iy	; F7A5FF  ld HL,IY
	extz	xhl	; F7A601  extz XHL
	dec	1, hl	; F7A603  dec 1,HL
	sla	xhl, 8	; F7A605  sla 0x08,XHL
	add	xhl, (BStore_AllocHeapBase:16)	; F7A608  add XHL,(0x12a2)
	ld	(BStore_CursorBlockAddr:16), xhl	; F7A60C  ld (0x126e),XHL
	xor	xhl, xhl	; F7A610  xor XHL,XHL
	ret	; F7A612  ret

; --------------------------------------------------------------------------
; BStore_AppendBytes_Veneer
; Called from: T_BStore_AppendBytes_Veneer (x8)
; Touches: nothing with an absolute address
; Calls:   BStore_AppendBytes
; Evidence: thunk slot T_BStore_AppendBytes_Veneer holds `jp 0x00F7A613`, and 0xF7A613 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
BStore_AppendBytes_Veneer:		; <- T_BStore_AppendBytes_Veneer
	calr	BStore_AppendBytes	; F7A613  calr 0xf7a617
	ret	; F7A616  ret

; --------------------------------------------------------------------------
; BStore_AppendBytes -- append C bytes from (XIY) to the chain of DIRECTORY
;                       ENTRY (0x1008), allocating a new block when the
;                       cursor would overflow past offset 0xFF
; Called from: in-module: 0xF7A613
; Inputs:  XIY = source bytes, W = count (moved to C), A = directory entry
;          number, 1-based
; Outputs: W = 0 on success; on failure it raises message 0x40AB, status
;          (0x2880) = 0x0F and returns without appending
; Touches: (0x0C57) (0x0C5D) (0x0C61) (0x0C67) (0x0C6B) (0x1008) (0x126E)
;          (0x1272) (0x2070) (0x2075) +1 more  |  0x003460 0x60347E 0x603500
; Calls:   T_BStore_DirEntryOffsetX2_Call T_BStore_CopyRangeBackward_Call T_BStore_WriteBytesAtSongPosition_Call BStore_AllocBlock
;          BStore_SeekBlock_Alloc T_F41020
; Evidence: `ld (0x1272),XIY / ld (0x1008),A / ld C,W` at 0xF7A618-0xF7A620.
;           The cursor pair is indexed by the entry: XIZ = (n-1)*2 selects a
;           word in 0x0060347E and a byte in the array 0x22 further on
;           (0x006034A0) -- `ld A,(XIX+0x22)` at 0xF7A6A5 with XIX =
;           0x0060347E + XIZ/2.  The overflow test is `add WA,BC / cp
;           WA,0xff / jr UGT` at 0xF7A6B0-0xF7A6B6 and the new-block offset
;           is `sub WA,0x00fb` at 0xF7A6F0 -- 251, exactly the payload size
;           0x100-5 that block-store computes at 0xF639B8.  The failure path
;           0xF7A76A writes (0x2880) = 0x0F, the same status byte block-
;           store's error table feeds.  That (0x1008) is a DIRECTORY entry
;           and not the song is read off 0xF7A7A8-0xF7A7CC: `ld A,(0x1008) /
;           dec 1,A / *3 / ld XIX,0x00603500 / or (XIX+IZ),0x80 / ld
;           (XDE3+0x0001),IY` sets that entry's in-use bit and head block --
;           the 3-byte stride and the bit-7 flag notes/FINDINGS-prom_b-
;           block-store.md reads off BStore_OpenChain at 0xF638BB
; Unknown: what the two thunk calls around the copy do: 0xF42EF8/0xF42EFC
;          bracket it and 0xF427EC does the move.  Neither target is
;          converted, so the copy itself is not read here
; --------------------------------------------------------------------------
; Resolved (naming wave 5, notes/naming-pilot-2026-10-06/proposals_wave5_r.json): 0xF42EFC is
;   T_BStore_WriteBytesAtSongPosition_Call, which writes the BC new bytes at the song position into the gap the
;   copy opened.  0xF42EF8 is still not read here.
BStore_AppendBytes:
	pushw	bc	; F7A617  push BC
	ld	(4722:16), xiy	; F7A618  ld (0x1272),XIY
	ld	(BStore_DirEntry:16), a	; F7A61C  ld (0x1008),A
	ld	c, w	; F7A620  ld C,W
	call	T_BStore_DirEntryOffsetX2_Call	; F7A622  call 0xf42ef8
	extz	xiz	; F7A626  extz XIZ
	ld	xix, 6304894	; F7A628  ld XIX,0x0060347e
	xor	b, b	; F7A62D  xor B,B
BStore_AppendBytes_Join:
	ld	iy, (xix+iz)	; F7A62F  ld IY,(XIX+IZ)
	cp	iy, 65535	; F7A634  cp IY,0xffff
	jrl	z, BStore_AppendBytes_Skip3	; F7A638  jrl Z,0xf7a782
	ld	(3169:16), iy	; F7A63B  ld (0x0c61),IY
	srl	iz, 1	; F7A63F  srl 0x01,IZ
	ldfr_lerp	xix, 0x38	; F7A642  ld XDE3,XIX
	add	xix, xiz	; F7A645  add XIX,XIZ
	ld	a, (xix+34)	; F7A647  ld A,(XIX+0x22)
	ldto_lerp	xix, 0x38	; F7A64A  ld XIX,XDE3
	xor	w, w	; F7A64D  xor W,W
	sla	iz, 1	; F7A64F  sla 0x01,IZ
	ld	(3175:16), wa	; F7A652  ld (0x0c67),WA
	ld	xix, 13408	; F7A656  ld XIX,0x00003460
BStore_AppendBytes_Join2:
	ld	de, (xix+iz)	; F7A65B  ld DE,(XIX+IZ)
	cp	de, 65535	; F7A660  cp DE,0xffff
	jr	nz, BStore_AppendBytes_Skip	; F7A664  jr NZ,0xf7a67f
	ld	(xix+iz), iy	; F7A666  ld (XIX+IZ),IY
	srl	iz, 1	; F7A66B  srl 0x01,IZ
	ldfr_lerp	xix, 0x38	; F7A66E  ld XDE3,XIX
	add	xix, xiz	; F7A671  add XIX,XIZ
	ld	(xix+34), 5	; F7A673  ld (XIX+0x22),0x05
	ldto_lerp	xix, 0x38	; F7A677  ld XIX,XDE3
	sla	iz, 1	; F7A67A  sla 0x01,IZ
	jr	BStore_AppendBytes_Join2	; F7A67D  jr T,0xf7a65b
BStore_AppendBytes_Skip:
	srl	iz, 1	; F7A67F  srl 0x01,IZ
	ldfr_lerp	xix, 0x38	; F7A682  ld XDE3,XIX
	add	xix, xiz	; F7A685  add XIX,XIZ
	ld	iy, (xix+34)	; F7A687  ld IY,(XIX+0x22)
	ldto_lerp	xix, 0x38	; F7A68A  ld XIX,XDE3
	sla	iz, 1	; F7A68D  sla 0x01,IZ
	and	iy, 255	; F7A690  and IY,0x00ff
	ld	(3179:16), iy	; F7A694  ld (0x0c6b),IY
	ld	xix, 6304894	; F7A698  ld XIX,0x0060347e
	srl	iz, 1	; F7A69D  srl 0x01,IZ
	ldfr_lerp	xix, 0x38	; F7A6A0  ld XDE3,XIX
	add	xix, xiz	; F7A6A3  add XIX,XIZ
	ld	a, (xix+34)	; F7A6A5  ld A,(XIX+0x22)
	ldto_lerp	xix, 0x38	; F7A6A8  ld XIX,XDE3
	xor	w, w	; F7A6AB  xor W,W
	sla	iz, 1	; F7A6AD  sla 0x01,IZ
	add	wa, bc	; F7A6B0  add WA,BC
	cp	wa, 255	; F7A6B2  cp WA,0x00ff
	jr	ugt, BStore_AppendBytes_Skip2	; F7A6B6  jr UGT,0xf7a6f0
	ld	iy, (xix+iz)	; F7A6B8  ld IY,(XIX+IZ)
	ld	(3159:16), iy	; F7A6BD  ld (0x0c57),IY
	ld	(3165:16), wa	; F7A6C1  ld (0x0c5d),WA
	srl	iz, 1	; F7A6C5  srl 0x01,IZ
	ldfr_lerp	xix, 0x38	; F7A6C8  ld XDE3,XIX
	add	xix, xiz	; F7A6CB  add XIX,XIZ
	ld	(xix+34), a	; F7A6CD  ld (XIX+0x22),A
	ldto_lerp	xix, 0x38	; F7A6D0  ld XIX,XDE3
	sla	iz, 1	; F7A6D3  sla 0x01,IZ
	push	xwa	; F7A6D6  push XWA
	push	xhl	; F7A6D7  push XHL
	push	xbc	; F7A6D8  push XBC
	push	xde	; F7A6D9  push XDE
	push	xix	; F7A6DA  push XIX
	push	xiy	; F7A6DB  push XIY
	push	xiz	; F7A6DC  push XIZ
	call	T_BStore_CopyRangeBackward_Call	; F7A6DD  call 0xf427ec
	pop	xiz	; F7A6E1  pop XIZ
	pop	xiy	; F7A6E2  pop XIY
	pop	xix	; F7A6E3  pop XIX
	pop	xde	; F7A6E4  pop XDE
	pop	xbc	; F7A6E5  pop XBC
	pop	xhl	; F7A6E6  pop XHL
	pop	xwa	; F7A6E7  pop XWA
	call	T_BStore_WriteBytesAtSongPosition_Call	; F7A6E8  call 0xf42efc
	xor	w, w	; F7A6EC  xor W,W
	popw	bc	; F7A6EE  pop BC
	ret	; F7A6EF  ret
BStore_AppendBytes_Skip2:
	sub	wa, 251	; F7A6F0  sub WA,0x00fb
	ld	(3165:16), wa	; F7A6F4  ld (0x0c5d),WA
	pushw	de	; F7A6F8  push DE
	calr	BStore_AllocBlock	; F7A6F9  calr 0xf7a4db
	popw	de	; F7A6FC  pop DE
	cp	w, 255	; F7A6FD  cp W,0xff
	jr	z, BStore_AppendBytes_Loop	; F7A700  jr Z,0xf7a76a
	ld	iy, ix	; F7A702  ld IY,IX
	ld	xix, 6304894	; F7A704  ld XIX,0x0060347e
	srl	iz, 1	; F7A709  srl 0x01,IZ
	ld	wa, (3165:16)	; F7A70C  ld WA,(0x0c5d)
	ldfr_lerp	xix, 0x38	; F7A710  ld XDE3,XIX
	add	xix, xiz	; F7A713  add XIX,XIZ
	ld	(xix+34), a	; F7A715  ld (XIX+0x22),A
	ldto_lerp	xix, 0x38	; F7A718  ld XIX,XDE3
	sla	iz, 1	; F7A71B  sla 0x01,IZ
	calr	BStore_SeekBlock_Alloc	; F7A71E  calr 0xf7a5ff
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7A721  ld XHL,(0x126e)
	ldw	(xhl+3), 0xffff	; F7A725  ld (XHL+0x03),0xffff
	ld	(3159:16), iy	; F7A72A  ld (0x0c57),IY
	ld	wa, iy	; F7A72E  ld WA,IY
	pushw	de	; F7A730  push DE
	ld	xix, 6304894	; F7A731  ld XIX,0x0060347e
	ld	de, (xix+iz)	; F7A736  ld DE,(XIX+IZ)
	ld	(xhl+1), de	; F7A73B  ld (XHL+0x01),DE
	ld	(xix+iz), wa	; F7A73E  ld (XIX+IZ),WA
	ld	iy, de	; F7A743  ld IY,DE
	calr	BStore_SeekBlock_Alloc	; F7A745  calr 0xf7a5ff
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7A748  ld XHL,(0x126e)
	ld	(xhl+3), wa	; F7A74C  ld (XHL+0x03),WA
	popw	de	; F7A74F  pop DE
	push	xwa	; F7A750  push XWA
	push	xhl	; F7A751  push XHL
	push	xbc	; F7A752  push XBC
	push	xde	; F7A753  push XDE
	push	xix	; F7A754  push XIX
	push	xiy	; F7A755  push XIY
	push	xiz	; F7A756  push XIZ
	call	T_BStore_CopyRangeBackward_Call	; F7A757  call 0xf427ec
	pop	xiz	; F7A75B  pop XIZ
	pop	xiy	; F7A75C  pop XIY
	pop	xix	; F7A75D  pop XIX
	pop	xde	; F7A75E  pop XDE
	pop	xbc	; F7A75F  pop XBC
	pop	xhl	; F7A760  pop XHL
	pop	xwa	; F7A761  pop XWA
	call	T_BStore_WriteBytesAtSongPosition_Call	; F7A762  call 0xf42efc
	xor	w, w	; F7A766  xor W,W
	popw	bc	; F7A768  pop BC
	ret	; F7A769  ret
BStore_AppendBytes_Loop:
	ld	w, 104:opc	; F7A76A  ld W,0x68
	call	T_F41020	; F7A76C  call 0xf41020
	and	(UI_RequestBits:16), 0x6f	; F7A770  and (0x2075),0x6f
	ld	(UI_StatusCode:16), 15	; F7A775  ld (0x2880),0x0f
	ldw	(UI_Request:16), 16555	; F7A77A  ld (0x2070),0x40ab
	popw	bc	; F7A780  pop BC
	ret	; F7A781  ret
BStore_AppendBytes_Skip3:
	push	xix	; F7A782  push XIX
	calr	BStore_AllocBlock	; F7A783  calr 0xf7a4db
	ld	iy, ix	; F7A786  ld IY,IX
	pop	xix	; F7A788  pop XIX
	cp	w, 255	; F7A789  cp W,0xff
	jr	z, BStore_AppendBytes_Loop	; F7A78C  jr Z,0xf7a76a
	ld	(xix+iz), iy	; F7A78E  ld (XIX+IZ),IY
	srl	iz, 1	; F7A793  srl 0x01,IZ
	ldfr_lerp	xix, 0x38	; F7A796  ld XDE3,XIX
	add	xix, xiz	; F7A799  add XIX,XIZ
	ld	(xix+34), 5	; F7A79B  ld (XIX+0x22),0x05
	ldto_lerp	xix, 0x38	; F7A79F  ld XIX,XDE3
	sla	iz, 1	; F7A7A2  sla 0x01,IZ
	pushw	wa	; F7A7A5  push WA
	pushw	iz	; F7A7A6  push IZ
	push	xix	; F7A7A7  push XIX
	ld	a, (BStore_DirEntry:16)	; F7A7A8  ld A,(0x1008)
	dec	1, a	; F7A7AC  dec 1,A
	ld	w, a	; F7A7AE  ld W,A
	sla	a, 1	; F7A7B0  sla 0x01,A
	add	a, w	; F7A7B3  add A,W
	xor	w, w	; F7A7B5  xor W,W
	ld	iz, wa	; F7A7B7  ld IZ,WA
	ld	xix, 6305024	; F7A7B9  ld XIX,0x00603500
	or	(xix+iz), 0x80	; F7A7BE  or (XIX+IZ),0x80
	ldfr_lerp	xix, 0x38	; F7A7C4  ld XDE3,XIX
	lda	xix, (xix+iz)	; F7A7C7  lda XIX,XIX+IZ
	.byte 0xF3, 0x39, 0x01, 0x00, 0x55	; F7A7CC  ld (XDE3+0x0001),IY   [llvm-mc cannot encode this]
	ldto_lerp	xix, 0x38	; F7A7D1  ld XIX,XDE3
	pop	xix	; F7A7D4  pop XIX
	popw	iz	; F7A7D5  pop IZ
	popw	wa	; F7A7D6  pop WA
	calr	BStore_SeekBlock_Alloc	; F7A7D7  calr 0xf7a5ff
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7A7DA  ld XHL,(0x126e)
	ldw	(xhl+1), 0x0000	; F7A7DE  ld (XHL+0x01),0x0000
	ldw	(xhl+3), 0xffff	; F7A7E3  ld (XHL+0x03),0xffff
	jrl	BStore_AppendBytes_Join	; F7A7E8  jrl T,0xf7a62f
	.fill	533, 1, 0x0E	; F7A7EB-F7A9FF  `ret` padding (asserted pure 0x0E)
