
; ==============================================================================
; 0xF65000-0xF6D001 -- THREE MODULES AT THE HEAD OF THE 0x065000 `.incbin` SPAN
;   69 thunk slots -- the top FOUR runs of notes/prom_b_module_frontier.py --
;   converted as one contiguous block
; ==============================================================================
;
; WHY THIS BLOCK.  notes/prom_b_module_frontier.py ranks whole thunk RUNS by the
; CONTIGUOUS unconverted extent of their targets, and its top four runs all point
; into this one `.incbin` span:
;
;   T_F42ED0-T_F42F04  14 slots  extent 20,977  targets 0xF67434-0xF6C625
;   T_StepRecord_OnEnter-T_StepRecord_ButtonByTrackKind   3 slots  extent 14,463  targets 0xF675CC-0xF6AE4B
;   T_F42B70-T_SequencerMedley_LcdKeyRow4  48 slots  extent  2,648  targets 0xF65C00-0xF66658
;   T_F432C0-T_F432CC   4 slots  extent      9  targets 0xF65000-0xF65009
;
; 69 slots.  Every target of all four is inside 0xF65000-0xF6D001, which is what
; checks() asserts run by run, so this one span retires all four.
; notes/prom_b_f65000_frontier_delta.py re-derives the before/after from the ROM
; and from this file.
;
; ⚠ WHERE THE BOUNDARIES COME FROM.  Not from a linear decode -- see
; notes/prom_a_linear_decode_check.py for why one pins nothing.  Five CONTENT
; rules run FIRST and become barriers the code walk may not enter, then a
; recursive descent seeded from the thunk targets and from every opcode-anchored
; `call`/`jp` site in prom_a+prom_b fills in the rest:
;
;   PTRTAB  >= 3 consecutive 4-byte LE words, all in 0x00F60000-0x00F6FFFF
;   RAMTAB  >= 4 consecutive 4-byte LE words, all below 0x10000
;   BITTAB  >= 8 consecutive 4-byte LE words with w[k] == w[0] << k
;   IDENT   >= 12 bytes counting up by one WITHOUT wrapping past 0xFF
;   ASCII   >= 20 consecutive bytes in 0x20-0x7E
;
; Each was calibrated against every maximal run of PROVEN instruction text
; already in this file -- 2,948 runs, 54,814 bytes AT COMMIT 2707125, which is
; the revision to quote because that corpus grows every time a round converts
; anything -- and each fires ZERO times there
; (`python3 notes/prom_b_f65000_layout.py --null --rev 2707125`).  ⚠ The ASCII threshold
; is TWENTY because at ten the same corpus yields three false positives and at
; eight, seven.  The cost is real and is not hidden: the 9-byte string
; `VOLUME = ` at 0xF67DC6 is NOT promoted; it sits inside the code segment that
; starts at 0xF67D6F and comes out as `db` bytes.
;
; ⚠ CORRECTED 2026-08-25 (round 5): A SIXTH RULE, AND IT DEMOTED FOUR RUNS.
; An unreached run whose linear decode consumes it exactly, holds no undefined
; opcode and lands every relative branch on a boundary was accepted as CODE.
; That rule was calibrated only against pointer tables, strings and 0x0E padding.
; Measured against proven DATA it had never seen -- the 4,011 display-list
; records of notes/FINDINGS-ui-display-list.md, 39,329 bytes whose framing is
; self-checking -- it accepts 13.9% of record-aligned 16-byte chunks as code.
; Requiring the decode to END IN A FLOW END (`ret`, `reti`, an unconditional
; `jp`/`jr`) takes that to 1 of 1,884 chunks, and to ZERO at 32 bytes and above:
;     python3 notes/prom_b_f0ea9f_layout.py --null-accept
; Four runs of this block failed the new rule and are now `.byte` with the reason
; in their headers: 0xF65DCC (6), 0xF65DF1 (6), 0xF6A475 (40) and 0xF6B006 (24).
; 0xF6A475 is the one that matters -- 40 bytes reading
; `10 ff 11 19 1a 17 ff 12 13 14 15 16 ff 18 ff ...`, a lookup table over the
; same 0x00-0x1F alphabet as IndexMap_F6A455 immediately above it, which round 4
; printed as `rcf / swi 7 / scf / pop F / jp 0xff17 / ...`.
;
; ⚠ AND THE BARRIER IS NOT COSMETIC.  Two of the descent's four seed sources are
; ADDRESSES THE FIRMWARE STORES rather than jumps it makes -- the 32-bit
; immediates an instruction loads, and every in-range entry of every table the
; PTRTAB rule frames.  Together they are what makes the walk reach most of the
; block (`python3 notes/prom_b_f65000_layout.py --seeds` prices the table
; entries; without them the 122-byte handler at 0xF67D6F -- entry [8] of FIVE
; dispatch tables -- came out as `.byte`).  But a stored address is as often a
; DATA address.  Measured on
; this exact range
; (`python3 notes/prom_b_f65000_layout.py --barrier`): with the barrier the walk
; claims 24478 bytes; without it, 25890, of which 1411 fall inside an object a content
; rule framed -- whole 32-entry pointer tables at 0xF6828B and 0xF685C1 among
; them.  `--conflicts` is the count that caught it and checks() asserts it is
; zero.
;
; LAYOUT.  97 segments: 46 code (25900 bytes), 31 dispatch tables (2412 bytes),
; 2 RAM-pointer tables (256 bytes), 1 bit-weight table (128 bytes), 6 index maps
; (286 bytes), 1 string (40 bytes), 7 unsplit `.byte` runs (121 bytes) and
; 3 runs of 0x0E `ret` padding (3627 bytes).  Substantive: 29143 of 32770.
;
; WHAT THE BLOCK TOUCHES, measured over the transcription itself.  Heaviest
; absolute operands: 0x603422 (x31) 0x60347E (x13) 0x610000 (x9) 0x603500 (x9) 0x600A14 (x7).
; Heaviest 16-bit RAM words: (0x0EF5) (x74) (0x0E63) (x55) (0x0E53) (x55) (0x126E) (x49) (0x2075) (x41).
; 0x603400-0x6034FF and 0x610000 are the SONG STORE's bank workspace and
; directory (notes/FINDINGS-prom_b-song-store.md, notes/FINDINGS-memory-map.md);
; (0x2075) is the UI redraw-request byte of notes/FINDINGS-prom_b-field-blink.md.
; That is a measurement of what the code ADDRESSES, not a claim about what the
; block IS, and no routine here is given a semantic name on the strength of it.
;
; ⚠ WHAT IS NOT ESTABLISHED.  What any of the three modules is FOR.  Every
; routine is `sub_XXXXXX` with a computed header claiming only its entry point,
; what it touches and what it calls.
;
; ⚠ WHAT IS LEFT.  0xF6D002-0xF77FFF stays `.incbin`.  0xF6D002-0xF6EFFF is the
; screen-TEXT block -- 43 runs of 10 or more printable bytes in 8190 bytes,
; interleaved with code the descent enters THROUGH them -- and splitting text
; from code there needs an ASCII rule with a null this round does not have (at
; 20 bytes the rule misses most of those runs; at 10 it has three false
; positives).  Above that, only 2 thunk slot(s) point anywhere into
; 0xF6D002-0xF77FFF at all -- T_MidiFileLoad_LcdKeyRow1 -> 0xF6F400, T_MidiFileSave_WriteSeqBankSmf -> 0xF6F404, so a split there would rest on a linear decode.
;
; REGENERATE:  python3 notes/gen_prom_b_f65000_module.py
; CHECKS:      python3 notes/gen_prom_b_f65000_module.py --checks
; AUDIT:       python3 notes/prom_b_f65000_header_audit.py
; ==============================================================================


; --------------------------------------------------------------------------
; SongEdit_SaveTimeSigOfDeletedMeasures
; Called from: T_SongEdit_SaveTimeSigOfDeletedMeasures (x2)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_SongEdit_SaveTimeSigOfDeletedMeasures holds `jp 0x00F65000`, and 0xF65000 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_SaveTimeSigOfDeletedMeasures: MEASURE DELETE on the master track, before the measures go: 0x0D92..0x0D9D
;   cleared (sub_F6500C); with Seq_FindMasterTrack's track, unless the range runs into the 0x82 end, sub_F653A5 copies
;   the last 3-byte tag-0x87 time-signature record found at the start (before the first 0x81 beat mark) of measures
;   (0x0C73)..+(0x0C77) to 0x0D92. A jump vector (`jrl` into sub_F6500C's body) behind T_SongEdit_SaveTimeSigOfDeletedMeasures, which
;   SongEdit_DeleteMeasures calls for a part-0x20 track; T_SongEdit_ReinsertTimeSigAfterDelete re-inserts the record afterwards. Basis: caller +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave5_r.json)
SongEdit_SaveTimeSigOfDeletedMeasures:		; <- T_SongEdit_SaveTimeSigOfDeletedMeasures
	jrl	sub_F6500C_Join	; F65000  jrl T,0xf65027

; --------------------------------------------------------------------------
; SongEdit_InsertTimeSigsForMeasureInsert
; Called from: T_SongEdit_InsertTimeSigsForMeasureInsert (x2)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_SongEdit_InsertTimeSigsForMeasureInsert holds `jp 0x00F65003`, and 0xF65003 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_InsertTimeSigsForMeasureInsert: MEASURE INSERT on the master track, before MeasureInsert_Execute's
;   MeasureInsert_InsertWithinTrack: unless measure (0x0C73) is the song end, captures the tag-0x87 time-signature record in force at
;   measure (0x0C73) (scan of measures 1..(0x0C73)-1, sub_F653A5) and, when (0x0C75) differs, the one in force at
;   measure (0x0C75); sub_F65489 then inserts each captured 3-byte record at the start of its measure
;   (BStore_AllocChain + T_BStore_CopyRangeBackward gap + sub_F65761). A jump vector behind T_SongEdit_InsertTimeSigsForMeasureInsert. Basis: caller + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave5_r.json)
SongEdit_InsertTimeSigsForMeasureInsert:		; <- T_SongEdit_InsertTimeSigsForMeasureInsert
	jrl	sub_F6500C_Join3	; F65003  jrl T,0xf65191

; --------------------------------------------------------------------------
; SongEdit_InsertTimeSigsForMeasureCopy
; Called from: T_SongEdit_InsertTimeSigsForMeasureCopy (x2)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_SongEdit_InsertTimeSigsForMeasureCopy holds `jp 0x00F65006`, and 0xF65006 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_InsertTimeSigsForMeasureCopy: MEASURE COPY on the master track, before SongEdit_CopyMeasures' SongEdit_CopyMeasuresWithinTrack:
;   unless source (0x0C73) = destination (0x0C75), captures the tag-0x87 time-signature record in force at measure
;   (0x0C73) and, unless (0x0C75)+(0x0C77) is (0x0C73) or past the end, the one in force at measure (0x0C75)+(0x0C77),
;   then inserts each 3-byte record at the start of its measure (sub_F65489). A jump vector behind T_SongEdit_InsertTimeSigsForMeasureCopy. Basis:
;   caller + body. (notes/naming-pilot-2026-10-06/proposals_wave5_r.json)
SongEdit_InsertTimeSigsForMeasureCopy:		; <- T_SongEdit_InsertTimeSigsForMeasureCopy
	jrl	sub_F6500C_Join4	; F65006  jrl T,0xf65286

; --------------------------------------------------------------------------
; SongEdit_ReinsertTimeSigAfterDelete
; Called from: T_SongEdit_ReinsertTimeSigAfterDelete (x2)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_SongEdit_ReinsertTimeSigAfterDelete holds `jp 0x00F65009`, and 0xF65009 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_ReinsertTimeSigAfterDelete: MEASURE DELETE on the master track, after the measures went: if T_SongEdit_SaveTimeSigOfDeletedMeasures
;   captured a time-signature record (0x0D92 != 0), seeks measure (0x0C73) of the master track, grows its chain by 3
;   bytes (BStore_AllocChain), opens a 3-byte gap there (T_BStore_CopyRangeBackward = BStore_CopyRangeBackward) and writes the record into it
;   (sub_F65761). A jump vector behind T_SongEdit_ReinsertTimeSigAfterDelete, which SongEdit_DeleteMeasures calls after SongEdit_DeleteMeasuresFromTrack when the track
;   is the master track (0x0D1D). Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave5_r.json)
SongEdit_ReinsertTimeSigAfterDelete:		; <- T_SongEdit_ReinsertTimeSigAfterDelete
	jrl	sub_F6500C_Join2	; F65009  jrl T,0xf650b4

; --------------------------------------------------------------------------
; sub_F6500C
; Called from: in-module: 0xF65027 0xF65191 0xF65286
; Touches: (0x0C57) (0x0C5D) (0x0C61) (0x0C67) (0x0C6B) (0x0C73) (0x0C75)
;          (0x0C77) (0x0C90) (0x0CAE) +27 more  |  0x60347E 0x6034A0
; Calls:   sub_F6500C T_Seq_FindMasterTrack T_BStore_ValidateSavedCursor T_BStore_SeekMeasure sub_F653A5 BStore_RemapErrorCode
;          T_BStore_AllocChain T_BStore_SaveCursor T_BStore_CopyRangeBackward sub_F65761 sub_F65489
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF6500C is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F6500C:
	xor	wa, wa	; F6500C  xor WA,WA
	ld	(3474:16), wa	; F6500E  ld (0x0d92),WA
	ld	(3476:16), wa	; F65012  ld (0x0d94),WA
	ld	(3478:16), wa	; F65016  ld (0x0d96),WA
	ld	(3480:16), wa	; F6501A  ld (0x0d98),WA
	ld	(3482:16), wa	; F6501E  ld (0x0d9a),WA
	ld	(3484:16), wa	; F65022  ld (0x0d9c),WA
	ret	; F65026  ret
sub_F6500C_Join:
	calr	sub_F6500C	; F65027  calr 0xf6500c
	call	T_Seq_FindMasterTrack	; F6502A  call 0xf427a0
	cp	w, 0:i3	; F6502E  cp W,0
	jrl	z, sub_F6500C_Skip	; F65030  jrl Z,0xf650b0
	ld	(3486:16), w	; F65033  ld (0x0d9e),W
	ld	a, w	; F65037  ld A,W
	xor	w, w	; F65039  xor W,W
	ld	(3354:16), wa	; F6503B  ld (0x0d1a),WA
	call	T_BStore_ValidateSavedCursor	; F6503F  call 0xf42770
	cp	(BStore_ErrorCode:16), 0x00	; F65043  cp (0x0d4a),0x00
	jr	nz, sub_F6500C_Skip	; F65048  jr NZ,0xf650b0
	ld	(3278:16), iy	; F6504A  ld (0x0cce),IY
	ld	wa, (BStore_CursorBlock:16)	; F6504E  ld WA,(0x345c)
	ld	(3276:16), wa	; F65052  ld (0x0ccc),WA
	ld	a, (3486:16)	; F65056  ld A,(0x0d9e)
	ld	w, a	; F6505A  ld W,A
	ld	de, (3187:16)	; F6505C  ld DE,(0x0c73)
	ld	(3216:16), de	; F65060  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F65064  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F65068  cp (0x0d4a),0x00
	jr	nz, sub_F6500C_Skip	; F6506D  jr NZ,0xf650b0
	ld	a, (3486:16)	; F6506F  ld A,(0x0d9e)
	ld	w, a	; F65073  ld W,A
	ld	de, (3187:16)	; F65075  ld DE,(0x0c73)
	add	de, (0x0c77:16)	; F65079  add DE,(0x0c77)
	ld	(3216:16), de	; F6507D  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F65081  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F65085  cp (0x0d4a),0x00
	jr	nz, sub_F6500C_Skip	; F6508A  jr NZ,0xf650b0
	ld	xhl, (BStore_CursorBlockAddr:16)	; F6508C  ld XHL,(0x126e)
	cp	(xhl+iy), 0x82	; F65090  cp (XHL+IY),0x82
	jr	z, sub_F6500C_Skip	; F65096  jr Z,0xf650b0
	ld	wa, (3187:16)	; F65098  ld WA,(0x0c73)
	ld	(3498:16), wa	; F6509C  ld (0x0daa),WA
	ld	wa, (3191:16)	; F650A0  ld WA,(0x0c77)
	ld	(3500:16), wa	; F650A4  ld (0x0dac),WA
	ld	xix, 3474	; F650A8  ld XIX,0x00000d92
	calr	sub_F653A5	; F650AD  calr 0xf653a5
sub_F6500C_Skip:
	calr	BStore_RemapErrorCode	; F650B0  calr 0xf65792
	ret	; F650B3  ret
sub_F6500C_Join2:
	cp	(0x0d92:16), 0x00	; F650B4  cp (0x0d92),0x00
	jrl	z, sub_F6500C_Skip2	; F650B9  jrl Z,0xf6518d
	ld	a, (3486:16)	; F650BC  ld A,(0x0d9e)
	ld	w, a	; F650C0  ld W,A
	ld	de, (3187:16)	; F650C2  ld DE,(0x0c73)
	ld	(3216:16), de	; F650C6  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F650CA  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F650CE  cp (0x0d4a),0x00
	jrl	nz, sub_F6500C_Skip2	; F650D3  jrl NZ,0xf6518d
	ld	(3488:16), iy	; F650D6  ld (0x0da0),IY
	ld	wa, (BStore_CursorBlock:16)	; F650DA  ld WA,(0x345c)
	ld	(3490:16), wa	; F650DE  ld (0x0da2),WA
	ldw	(BStore_AllocBytesWanted:16), 3	; F650E2  ld (0x0cae),0x0003
	xor	hl, hl	; F650E8  xor HL,HL
	ld	l, (3486:16)	; F650EA  ld L,(0x0d9e)
	dec	1, hl	; F650EE  dec 1,HL
	xor	wa, wa	; F650F0  xor WA,WA
	push	xix	; F650F2  push XIX
	ld	xix, 6304928	; F650F3  ld XIX,0x006034a0
	ld	a, (xix+hl)	; F650F8  ld A,(XIX+HL)
	pop	xix	; F650FD  pop XIX
	ld	(BStore_LastBlockUsed:16), wa	; F650FE  ld (0x0cc6),WA
	ld	(3278:16), wa	; F65102  ld (0x0cce),WA
	sla	hl, 1	; F65106  sla 0x01,HL
	push	xde	; F65109  push XDE
	ld	xde, 6304894	; F6510A  ld XDE,0x0060347e
	ld	wa, (xde+hl)	; F6510F  ld WA,(XDE+HL)
	pop	xde	; F65114  pop XDE
	ld	(BStore_LinkBlock:16), wa	; F65115  ld (0x0cc0),WA
	ld	(3276:16), wa	; F65119  ld (0x0ccc),WA
	call	T_BStore_AllocChain	; F6511D  call 0xf427b4
	cp	(BStore_ErrorCode:16), 0x00	; F65121  cp (0x0d4a),0x00
	jr	nz, sub_F6500C_Skip2	; F65126  jr NZ,0xf6518d
	ld	(3300:16), de	; F65128  ld (0x0ce4),DE
	ld	(BStore_LastBlockFree:16), wa	; F6512C  ld (0x0d08),WA
	ld	(3302:16), wa	; F65130  ld (0x0ce6),WA
	ld	ix, wa	; F65134  ld IX,WA
	ld	wa, (3300:16)	; F65136  ld WA,(0x0ce4)
	ld	(3159:16), wa	; F6513A  ld (0x0c57),WA
	call	T_BStore_SaveCursor	; F6513E  call 0xf427b0
	ld	wa, (BStore_LinkBlock:16)	; F65142  ld WA,(0x0cc0)
	ld	(3169:16), wa	; F65146  ld (0x0c61),WA
	ld	wa, (BStore_LastBlockUsed:16)	; F6514A  ld WA,(0x0cc6)
	ld	(3175:16), wa	; F6514E  ld (0x0c67),WA
	ld	wa, (3300:16)	; F65152  ld WA,(0x0ce4)
	ld	(3159:16), wa	; F65156  ld (0x0c57),WA
	ld	wa, (3302:16)	; F6515A  ld WA,(0x0ce6)
	ld	(3165:16), wa	; F6515E  ld (0x0c5d),WA
	ld	de, (3490:16)	; F65162  ld DE,(0x0da2)
	ld	wa, (3488:16)	; F65166  ld WA,(0x0da0)
	ld	(3179:16), wa	; F6516A  ld (0x0c6b),WA
	call	T_BStore_CopyRangeBackward	; F6516E  call 0xf4277c
	cp	(BStore_ErrorCode:16), 0x00	; F65172  cp (0x0d4a),0x00
	jr	nz, sub_F6500C_Skip2	; F65177  jr NZ,0xf6518d
	ld	xix, 3474	; F65179  ld XIX,0x00000d92
	ld	hl, (3490:16)	; F6517E  ld HL,(0x0da2)
	ld	(3260:16), hl	; F65182  ld (0x0cbc),HL
	ld	iy, (3488:16)	; F65186  ld IY,(0x0da0)
	calr	sub_F65761	; F6518A  calr 0xf65761
sub_F6500C_Skip2:
	calr	BStore_RemapErrorCode	; F6518D  calr 0xf65792
	ret	; F65190  ret
sub_F6500C_Join3:
	calr	sub_F6500C	; F65191  calr 0xf6500c
	call	T_Seq_FindMasterTrack	; F65194  call 0xf427a0
	cp	w, 0:i3	; F65198  cp W,0
	jrl	z, sub_F6500C_Skip4	; F6519A  jrl Z,0xf65282
	ld	(3486:16), w	; F6519D  ld (0x0d9e),W
	xor	wa, wa	; F651A1  xor WA,WA
	ld	a, (3486:16)	; F651A3  ld A,(0x0d9e)
	ld	(3354:16), wa	; F651A7  ld (0x0d1a),WA
	call	T_BStore_ValidateSavedCursor	; F651AB  call 0xf42770
	cp	(BStore_ErrorCode:16), 0x00	; F651AF  cp (0x0d4a),0x00
	jrl	nz, sub_F6500C_Skip4	; F651B4  jrl NZ,0xf65282
	ld	(3278:16), iy	; F651B7  ld (0x0cce),IY
	ld	wa, (BStore_CursorBlock:16)	; F651BB  ld WA,(0x345c)
	ld	(3276:16), wa	; F651BF  ld (0x0ccc),WA
	ld	w, (3486:16)	; F651C3  ld W,(0x0d9e)
	ld	a, w	; F651C7  ld A,W
	ld	de, (3187:16)	; F651C9  ld DE,(0x0c73)
	ld	(3216:16), de	; F651CD  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F651D1  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F651D5  cp (0x0d4a),0x00
	jrl	nz, sub_F6500C_Skip4	; F651DA  jrl NZ,0xf65282
	ld	xhl, (BStore_CursorBlockAddr:16)	; F651DD  ld XHL,(0x126e)
	cp	(xhl+iy), 0x82	; F651E1  cp (XHL+IY),0x82
	jrl	z, sub_F6500C_Skip4	; F651E7  jrl Z,0xf65282
	ld	(3488:16), iy	; F651EA  ld (0x0da0),IY
	ld	wa, (BStore_CursorBlock:16)	; F651EE  ld WA,(0x345c)
	ld	(3490:16), wa	; F651F2  ld (0x0da2),WA
	ldw	(3498:16), 1	; F651F6  ld (0x0daa),0x0001
	ld	bc, (3187:16)	; F651FC  ld BC,(0x0c73)
	dec	1, bc	; F65200  dec 1,BC
	ld	(3500:16), bc	; F65202  ld (0x0dac),BC
	ld	xix, 3474	; F65206  ld XIX,0x00000d92
	calr	sub_F653A5	; F6520B  calr 0xf653a5
	cp	(BStore_ErrorCode:16), 0x00	; F6520E  cp (0x0d4a),0x00
	jr	nz, sub_F6500C_Skip4	; F65213  jr NZ,0xf65282
	ld	wa, (3187:16)	; F65215  ld WA,(0x0c73)
	cp	wa, (0x0c75:16)	; F65219  cp WA,(0x0c75)
	jr	z, sub_F6500C_Skip3	; F6521D  jr Z,0xf6526f
	ld	w, (3486:16)	; F6521F  ld W,(0x0d9e)
	ld	a, w	; F65223  ld A,W
	ld	de, (3189:16)	; F65225  ld DE,(0x0c75)
	ld	(3216:16), de	; F65229  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F6522D  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F65231  cp (0x0d4a),0x00
	jr	nz, sub_F6500C_Skip4	; F65236  jr NZ,0xf65282
	ld	xhl, (BStore_CursorBlockAddr:16)	; F65238  ld XHL,(0x126e)
	cp	(xhl+iy), 0x82	; F6523C  cp (XHL+IY),0x82
	jr	z, sub_F6500C_Skip3	; F65242  jr Z,0xf6526f
	ld	(3492:16), iy	; F65244  ld (0x0da4),IY
	ld	wa, (BStore_CursorBlock:16)	; F65248  ld WA,(0x345c)
	ld	(3494:16), wa	; F6524C  ld (0x0da6),WA
	ldw	(3498:16), 1	; F65250  ld (0x0daa),0x0001
	ld	bc, (3189:16)	; F65256  ld BC,(0x0c75)
	dec	1, bc	; F6525A  dec 1,BC
	ld	(3500:16), bc	; F6525C  ld (0x0dac),BC
	ld	xix, 3480	; F65260  ld XIX,0x00000d98
	calr	sub_F653A5	; F65265  calr 0xf653a5
	cp	(BStore_ErrorCode:16), 0x00	; F65268  cp (0x0d4a),0x00
	jr	nz, sub_F6500C_Skip4	; F6526D  jr NZ,0xf65282
sub_F6500C_Skip3:
	ld	wa, (3187:16)	; F6526F  ld WA,(0x0c73)
	ld	(3502:16), wa	; F65273  ld (0x0dae),WA
	ld	wa, (3189:16)	; F65277  ld WA,(0x0c75)
	ld	(3504:16), wa	; F6527B  ld (0x0db0),WA
	calr	sub_F65489	; F6527F  calr 0xf65489
sub_F6500C_Skip4:
	calr	BStore_RemapErrorCode	; F65282  calr 0xf65792
	ret	; F65285  ret
sub_F6500C_Join4:
	calr	sub_F6500C	; F65286  calr 0xf6500c
	call	T_Seq_FindMasterTrack	; F65289  call 0xf427a0
	cp	w, 0:i3	; F6528D  cp W,0
	jrl	z, sub_F6500C_Skip6	; F6528F  jrl Z,0xf653a1
	ld	(3486:16), w	; F65292  ld (0x0d9e),W
	xor	wa, wa	; F65296  xor WA,WA
	ld	a, (3486:16)	; F65298  ld A,(0x0d9e)
	ld	(3354:16), wa	; F6529C  ld (0x0d1a),WA
	call	T_BStore_ValidateSavedCursor	; F652A0  call 0xf42770
	cp	(BStore_ErrorCode:16), 0x00	; F652A4  cp (0x0d4a),0x00
	jrl	nz, sub_F6500C_Skip6	; F652A9  jrl NZ,0xf653a1
	ld	(3278:16), iy	; F652AC  ld (0x0cce),IY
	ld	wa, (BStore_CursorBlock:16)	; F652B0  ld WA,(0x345c)
	ld	(3276:16), wa	; F652B4  ld (0x0ccc),WA
	ld	wa, (3187:16)	; F652B8  ld WA,(0x0c73)
	cp	wa, (0x0c75:16)	; F652BC  cp WA,(0x0c75)
	jrl	z, sub_F6500C_Skip6	; F652C0  jrl Z,0xf653a1
	ld	w, (3486:16)	; F652C3  ld W,(0x0d9e)
	ld	a, w	; F652C7  ld A,W
	ld	de, (3187:16)	; F652C9  ld DE,(0x0c73)
	ld	(3216:16), de	; F652CD  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F652D1  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F652D5  cp (0x0d4a),0x00
	jrl	nz, sub_F6500C_Skip6	; F652DA  jrl NZ,0xf653a1
	ld	xhl, (BStore_CursorBlockAddr:16)	; F652DD  ld XHL,(0x126e)
	cp	(xhl+iy), 0x82	; F652E1  cp (XHL+IY),0x82
	jrl	z, sub_F6500C_Skip6	; F652E7  jrl Z,0xf653a1
	ld	(3488:16), iy	; F652EA  ld (0x0da0),IY
	ld	wa, (BStore_CursorBlock:16)	; F652EE  ld WA,(0x345c)
	ld	(3490:16), wa	; F652F2  ld (0x0da2),WA
	ldw	(3498:16), 1	; F652F6  ld (0x0daa),0x0001
	ld	bc, (3187:16)	; F652FC  ld BC,(0x0c73)
	dec	1, bc	; F65300  dec 1,BC
	ld	(3500:16), bc	; F65302  ld (0x0dac),BC
	ld	xix, 3474	; F65306  ld XIX,0x00000d92
	calr	sub_F653A5	; F6530B  calr 0xf653a5
	cp	(BStore_ErrorCode:16), 0x00	; F6530E  cp (0x0d4a),0x00
	jrl	nz, sub_F6500C_Skip6	; F65313  jrl NZ,0xf653a1
	ld	wa, (3189:16)	; F65316  ld WA,(0x0c75)
	add	wa, (0x0c77:16)	; F6531A  add WA,(0x0c77)
	cp	wa, (0x0c73:16)	; F6531E  cp WA,(0x0c73)
	jr	z, sub_F6500C_Join5	; F65322  jr Z,0xf6538a
	ld	w, (3486:16)	; F65324  ld W,(0x0d9e)
	ld	a, w	; F65328  ld A,W
	ld	de, (3189:16)	; F6532A  ld DE,(0x0c75)
	add	de, (0x0c77:16)	; F6532E  add DE,(0x0c77)
	ld	(3216:16), de	; F65332  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F65336  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F6533A  cp (0x0d4a),0x00
	jr	z, sub_F6500C_Skip5	; F6533F  jr Z,0xf6534f
	cp	(BStore_ErrorCode:16), 0x08	; F65341  cp (0x0d4a),0x08
	jr	nz, sub_F6500C_Skip6	; F65346  jr NZ,0xf653a1
	ld	(BStore_ErrorCode:16), 0	; F65348  ld (0x0d4a),0x00
	jr	sub_F6500C_Join5	; F6534D  jr T,0xf6538a
sub_F6500C_Skip5:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F6534F  ld XHL,(0x126e)
	cp	(xhl+iy), 0x82	; F65353  cp (XHL+IY),0x82
	jr	z, sub_F6500C_Join5	; F65359  jr Z,0xf6538a
	ld	(3492:16), iy	; F6535B  ld (0x0da4),IY
	ld	wa, (BStore_CursorBlock:16)	; F6535F  ld WA,(0x345c)
	ld	(3494:16), wa	; F65363  ld (0x0da6),WA
	ldw	(3498:16), 1	; F65367  ld (0x0daa),0x0001
	ld	bc, (3189:16)	; F6536D  ld BC,(0x0c75)
	add	bc, (0x0c77:16)	; F65371  add BC,(0x0c77)
	dec	1, bc	; F65375  dec 1,BC
	ld	(3500:16), bc	; F65377  ld (0x0dac),BC
	ld	xix, 3480	; F6537B  ld XIX,0x00000d98
	calr	sub_F653A5	; F65380  calr 0xf653a5
	cp	(BStore_ErrorCode:16), 0x00	; F65383  cp (0x0d4a),0x00
	jr	nz, sub_F6500C_Skip6	; F65388  jr NZ,0xf653a1
sub_F6500C_Join5:
	ld	wa, (3187:16)	; F6538A  ld WA,(0x0c73)
	ld	(3502:16), wa	; F6538E  ld (0x0dae),WA
	ld	wa, (3189:16)	; F65392  ld WA,(0x0c75)
	add	wa, (0x0c77:16)	; F65396  add WA,(0x0c77)
	ld	(3504:16), wa	; F6539A  ld (0x0db0),WA
	calr	sub_F65489	; F6539E  calr 0xf65489
sub_F6500C_Skip6:
	calr	BStore_RemapErrorCode	; F653A1  calr 0xf65792
	ret	; F653A4  ret

; --------------------------------------------------------------------------
; sub_F653A5
; Called from: in-module: 0xF650AD 0xF6520B 0xF65265 0xF6530B 0xF65380
; Touches: (0x0C90) (0x0CBC) (0x0CBE) (0x0D1C) (0x0D4A) (0x0D9E) (0x0DAA)
;          (0x0DAC) (0x126E) (0x345C)
; Calls:   T_BStore_SeekMeasure T_BStore_ReadCursorAdvance_Call Words3AtXIX_Clear T_F427A8 BStore_RemapErrorCode
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF653A5 is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F653A5:
	ld	w, (3486:16)	; F653A5  ld W,(0x0d9e)
	ld	a, w	; F653A9  ld A,W
	ld	de, (3498:16)	; F653AB  ld DE,(0x0daa)
	ld	(3216:16), de	; F653AF  ld (0x0c90),DE
	push	xix	; F653B3  push XIX
	call	T_BStore_SeekMeasure	; F653B4  call 0xf42774
	pop	xix	; F653B8  pop XIX
	cp	(BStore_ErrorCode:16), 0x00	; F653B9  cp (0x0d4a),0x00
	jrl	nz, sub_F653A5_Skip5	; F653BE  jrl NZ,0xf6547a
	ld	(3262:16), iy	; F653C1  ld (0x0cbe),IY
	ld	wa, (BStore_CursorBlock:16)	; F653C5  ld WA,(0x345c)
	ld	(3260:16), wa	; F653C9  ld (0x0cbc),WA
	xor	de, de	; F653CD  xor DE,DE
sub_F653A5_Join:
	cp	de, (0x0dac:16)	; F653CF  cp DE,(0x0dac)
	jrl	z, sub_F653A5_Skip5	; F653D3  jrl Z,0xf6547a
	xor	c, c	; F653D6  xor C,C
sub_F653A5_Join2:
	cp	c, (0x0d1c:16)	; F653D8  cp C,(0x0d1c)
	jr	z, sub_F653A5_Skip4	; F653DC  jr Z,0xf65451
sub_F653A5_Loop:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F653DE  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F653E2  ld A,(XHL+IY)
	cp	a, 129	; F653E7  cp A,0x81
	jr	z, sub_F653A5_Skip	; F653EA  jr Z,0xf65401
	cp	a, 130	; F653EC  cp A,0x82
	jrl	z, sub_F653A5_Skip5	; F653EF  jrl Z,0xf6547a
	cp	a, 135	; F653F2  cp A,0x87
	jr	z, sub_F653A5_Skip2	; F653F5  jr Z,0xf65414
sub_F653A5_Loop2:
	pushw	bc	; F653F7  push BC
	push	xix	; F653F8  push XIX
	call	T_BStore_ReadCursorAdvance_Call	; F653F9  call 0xf4270c
	pop	xix	; F653FD  pop XIX
	popw	bc	; F653FE  pop BC
	jr	sub_F653A5_Loop	; F653FF  jr T,0xf653de
sub_F653A5_Skip:
	inc	1, c	; F65401  inc 1,C
	pushw	bc	; F65403  push BC
	push	xix	; F65404  push XIX
	call	T_BStore_ReadCursorAdvance_Call	; F65405  call 0xf4270c
	pop	xix	; F65409  pop XIX
	popw	bc	; F6540A  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F6540B  cp (0x0d4a),0x00
	jr	nz, sub_F653A5_Skip5	; F65410  jr NZ,0xf6547a
	jr	sub_F653A5_Join2	; F65412  jr T,0xf653d8
sub_F653A5_Skip2:
	cp	c, 0:i3	; F65414  cp C,0
	jr	nz, sub_F653A5_Loop2	; F65416  jr NZ,0xf653f7
	xor	hl, hl	; F65418  xor HL,HL
sub_F653A5_Join3:
	cp	hl, 2:i3	; F6541A  cp HL,2
	jr	ugt, sub_F653A5_Loop	; F6541C  jr UGT,0xf653de
	ld	(xix+hl), a	; F6541E  ld (XIX+HL),A
	push	xhl	; F65423  push XHL
	pushw	bc	; F65424  push BC
	push	xix	; F65425  push XIX
	call	T_BStore_ReadCursorAdvance_Call	; F65426  call 0xf4270c
	pop	xix	; F6542A  pop XIX
	popw	bc	; F6542B  pop BC
	pop	xhl	; F6542C  pop XHL
	cp	(BStore_ErrorCode:16), 0x00	; F6542D  cp (0x0d4a),0x00
	jr	nz, sub_F653A5_Skip5	; F65432  jr NZ,0xf6547a
	push	xde	; F65434  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F65435  ld XDE,(0x126e)
	ld	a, (xde+iy)	; F65439  ld A,(XDE+IY)
	pop	xde	; F6543E  pop XDE
	bit	7, a	; F6543F  bit 0x07,A
	jr	z, sub_F653A5_Skip3	; F65442  jr Z,0xf6544d
	cp	hl, 2:i3	; F65444  cp HL,2
	jr	z, sub_F653A5_Skip3	; F65446  jr Z,0xf6544d
	calr	Words3AtXIX_Clear	; F65448  calr 0xf6547e
	jr	sub_F653A5_Loop	; F6544B  jr T,0xf653de
sub_F653A5_Skip3:
	inc	1, hl	; F6544D  inc 1,HL
	jr	sub_F653A5_Join3	; F6544F  jr T,0xf6541a
sub_F653A5_Skip4:
	inc	1, de	; F65451  inc 1,DE
	push	xiz	; F65453  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F65454  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F65458  ld XDE3,XIZ
	pop	xiz	; F6545B  pop XIZ
	push_lerp	0x38	; F6545C  push XDE3
	push	xhl	; F6545F  push XHL
	pushw	de	; F65460  push DE
	push	xiy	; F65461  push XIY
	push	xix	; F65462  push XIX
	call	T_F427A8	; F65463  call 0xf427a8
	pop	xix	; F65467  pop XIX
	pop	xiy	; F65468  pop XIY
	popw	de	; F65469  pop DE
	pop	xhl	; F6546A  pop XHL
	pop_lerp	0x38	; F6546B  pop XDE3
	push	xiz	; F6546E  push XIZ
	ldto_lerp	xiz, 0x38	; F6546F  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F65472  ld (0x126e),XIZ
	pop	xiz	; F65476  pop XIZ
	jrl	sub_F653A5_Join	; F65477  jrl T,0xf653cf
sub_F653A5_Skip5:
	calr	BStore_RemapErrorCode	; F6547A  calr 0xf65792
	ret	; F6547D  ret

; --------------------------------------------------------------------------
; Words3AtXIX_Clear
; Called from: in-module: 0xF65448
; Touches: nothing with an absolute address
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF6547E is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Words3AtXIX_Clear(XIX): zero the three words at XIX.
Words3AtXIX_Clear:
	xor	wa, wa	; F6547E  xor WA,WA
	ld	(xix), wa	; F65480  ld (XIX),WA
	ld	(xix+2), wa	; F65482  ld (XIX+0x02),WA
	ld	(xix+4), wa	; F65485  ld (XIX+0x04),WA
	ret	; F65488  ret

; --------------------------------------------------------------------------
; sub_F65489
; Called from: in-module: 0xF6527F 0xF6539E
; Touches: (0x0C57) (0x0C5D) (0x0C61) (0x0C67) (0x0C6B) (0x0CAE) (0x0CBC)
;          (0x0CC0) (0x0CC6) (0x0CCC) +16 more  |  0x60347E 0x6034A0
; Calls:   T_BStore_AllocChain T_BStore_SaveCursor T_BStore_CopyRangeBackward sub_F65761 T_BStore_SeekBlock BStore_RemapErrorCode
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF65489 is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F65489:
	ld	l, (3486:16)	; F65489  ld L,(0x0d9e)
	cp	l, 0:i3	; F6548D  cp L,0
	jrl	z, sub_F65489_Join7	; F6548F  jrl Z,0xf6575d
	ld	a, (3474:16)	; F65492  ld A,(0x0d92)
	ld	w, (3480:16)	; F65496  ld W,(0x0d98)
	cp	a, 0:i3	; F6549A  cp A,0
	jr	nz, sub_F65489_Skip	; F6549C  jr NZ,0xf654a6
	cp	w, 0:i3	; F6549E  cp W,0
	jrl	z, sub_F65489_Join7	; F654A0  jrl Z,0xf6575d
	jrl	sub_F65489_Join	; F654A3  jrl T,0xf6553a
sub_F65489_Skip:
	cp	w, 0:i3	; F654A6  cp W,0
	jrl	nz, sub_F65489_Skip2	; F654A8  jrl NZ,0xf655c9
	xor	hl, hl	; F654AB  xor HL,HL
	xor	wa, wa	; F654AD  xor WA,WA
	ld	wa, (3276:16)	; F654AF  ld WA,(0x0ccc)
	ld	(BStore_LinkBlock:16), wa	; F654B3  ld (0x0cc0),WA
	ld	wa, (3278:16)	; F654B7  ld WA,(0x0cce)
	ld	(BStore_LastBlockUsed:16), wa	; F654BB  ld (0x0cc6),WA
	ldw	(BStore_AllocBytesWanted:16), 3	; F654BF  ld (0x0cae),0x0003
	call	T_BStore_AllocChain	; F654C5  call 0xf427b4
	cp	(BStore_ErrorCode:16), 0x00	; F654C9  cp (0x0d4a),0x00
	jrl	nz, sub_F65489_Join7	; F654CE  jrl NZ,0xf6575d
	ld	(3300:16), de	; F654D1  ld (0x0ce4),DE
	ld	wa, (BStore_LastBlockFree:16)	; F654D5  ld WA,(0x0d08)
	ld	(3302:16), wa	; F654D9  ld (0x0ce6),WA
	ld	ix, wa	; F654DD  ld IX,WA
	ld	wa, (3300:16)	; F654DF  ld WA,(0x0ce4)
	ld	(3159:16), wa	; F654E3  ld (0x0c57),WA
	call	T_BStore_SaveCursor	; F654E7  call 0xf427b0
	ld	wa, (3276:16)	; F654EB  ld WA,(0x0ccc)
	ld	(3169:16), wa	; F654EF  ld (0x0c61),WA
	ld	wa, (3278:16)	; F654F3  ld WA,(0x0cce)
	ld	(3175:16), wa	; F654F7  ld (0x0c67),WA
	ld	wa, (3300:16)	; F654FB  ld WA,(0x0ce4)
	ld	(3159:16), wa	; F654FF  ld (0x0c57),WA
	ld	wa, (3302:16)	; F65503  ld WA,(0x0ce6)
	ld	(3165:16), wa	; F65507  ld (0x0c5d),WA
	ld	de, (3490:16)	; F6550B  ld DE,(0x0da2)
	ld	wa, (3488:16)	; F6550F  ld WA,(0x0da0)
	ld	(3179:16), wa	; F65513  ld (0x0c6b),WA
	call	T_BStore_CopyRangeBackward	; F65517  call 0xf4277c
	cp	(BStore_ErrorCode:16), 0x00	; F6551B  cp (0x0d4a),0x00
	jrl	nz, sub_F65489_Join7	; F65520  jrl NZ,0xf6575d
	ld	xix, 3474	; F65523  ld XIX,0x00000d92
	ld	hl, (3490:16)	; F65528  ld HL,(0x0da2)
	ld	(3260:16), hl	; F6552C  ld (0x0cbc),HL
	ld	iy, (3488:16)	; F65530  ld IY,(0x0da0)
	calr	sub_F65761	; F65534  calr 0xf65761
	jrl	sub_F65489_Join7	; F65537  jrl T,0xf6575d
sub_F65489_Join:
	xor	hl, hl	; F6553A  xor HL,HL
	xor	wa, wa	; F6553C  xor WA,WA
	ld	wa, (3276:16)	; F6553E  ld WA,(0x0ccc)
	ld	(BStore_LinkBlock:16), wa	; F65542  ld (0x0cc0),WA
	ld	wa, (3278:16)	; F65546  ld WA,(0x0cce)
	ld	(BStore_LastBlockUsed:16), wa	; F6554A  ld (0x0cc6),WA
	ldw	(BStore_AllocBytesWanted:16), 3	; F6554E  ld (0x0cae),0x0003
	call	T_BStore_AllocChain	; F65554  call 0xf427b4
	cp	(BStore_ErrorCode:16), 0x00	; F65558  cp (0x0d4a),0x00
	jrl	nz, sub_F65489_Join7	; F6555D  jrl NZ,0xf6575d
	ld	(3300:16), de	; F65560  ld (0x0ce4),DE
	ld	wa, (BStore_LastBlockFree:16)	; F65564  ld WA,(0x0d08)
	ld	(3302:16), wa	; F65568  ld (0x0ce6),WA
	ld	ix, wa	; F6556C  ld IX,WA
	ld	wa, (3300:16)	; F6556E  ld WA,(0x0ce4)
	ld	(3159:16), wa	; F65572  ld (0x0c57),WA
	call	T_BStore_SaveCursor	; F65576  call 0xf427b0
	ld	wa, (3276:16)	; F6557A  ld WA,(0x0ccc)
	ld	(3169:16), wa	; F6557E  ld (0x0c61),WA
	ld	wa, (3278:16)	; F65582  ld WA,(0x0cce)
	ld	(3175:16), wa	; F65586  ld (0x0c67),WA
	ld	wa, (3300:16)	; F6558A  ld WA,(0x0ce4)
	ld	(3159:16), wa	; F6558E  ld (0x0c57),WA
	ld	wa, (3302:16)	; F65592  ld WA,(0x0ce6)
	ld	(3165:16), wa	; F65596  ld (0x0c5d),WA
	ld	de, (3494:16)	; F6559A  ld DE,(0x0da6)
	ld	wa, (3492:16)	; F6559E  ld WA,(0x0da4)
	ld	(3179:16), wa	; F655A2  ld (0x0c6b),WA
	call	T_BStore_CopyRangeBackward	; F655A6  call 0xf4277c
	cp	(BStore_ErrorCode:16), 0x00	; F655AA  cp (0x0d4a),0x00
	jrl	nz, sub_F65489_Join7	; F655AF  jrl NZ,0xf6575d
	ld	xix, 3480	; F655B2  ld XIX,0x00000d98
	ld	hl, (3494:16)	; F655B7  ld HL,(0x0da6)
	ld	(3260:16), hl	; F655BB  ld (0x0cbc),HL
	ld	iy, (3492:16)	; F655BF  ld IY,(0x0da4)
	calr	sub_F65761	; F655C3  calr 0xf65761
	jrl	sub_F65489_Join7	; F655C6  jrl T,0xf6575d
sub_F65489_Skip2:
	xor	hl, hl	; F655C9  xor HL,HL
	xor	wa, wa	; F655CB  xor WA,WA
	ld	wa, (3276:16)	; F655CD  ld WA,(0x0ccc)
	ld	(BStore_LinkBlock:16), wa	; F655D1  ld (0x0cc0),WA
	ld	wa, (3278:16)	; F655D5  ld WA,(0x0cce)
	ld	(BStore_LastBlockUsed:16), wa	; F655D9  ld (0x0cc6),WA
	ldw	(BStore_AllocBytesWanted:16), 6	; F655DD  ld (0x0cae),0x0006
	call	T_BStore_AllocChain	; F655E3  call 0xf427b4
	cp	(BStore_ErrorCode:16), 0x00	; F655E7  cp (0x0d4a),0x00
	jrl	nz, sub_F65489_Join7	; F655EC  jrl NZ,0xf6575d
	ld	(3496:16), de	; F655EF  ld (0x0da8),DE
	ld	wa, (BStore_LastBlockFree:16)	; F655F3  ld WA,(0x0d08)
	sub	wa, 3	; F655F7  sub WA,0x0003
	cp	wa, 5:i3	; F655FB  cp WA,5
	jr	c, sub_F65489_Skip3	; F655FD  jr C,0xf65605
	ld	(3300:16), de	; F655FF  ld (0x0ce4),DE
	jr	sub_F65489_Join2	; F65603  jr T,0xf65624
sub_F65489_Skip3:
	ld	hl, de	; F65605  ld HL,DE
	call	T_BStore_SeekBlock	; F65607  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F6560B  ld XHL,(0x126e)
	ld	hl, (xhl+1)	; F6560F  ld HL,(XHL+0x01)
	ld	(3300:16), hl	; F65612  ld (0x0ce4),HL
	ldw	hl, 5	; F65616  ld HL,0x0005
	sub	hl, wa	; F65619  sub HL,WA
	ld	wa, hl	; F6561B  ld WA,HL
	ldw	hl, 255	; F6561D  ld HL,0x00ff
	sub	hl, wa	; F65620  sub HL,WA
	ld	wa, hl	; F65622  ld WA,HL
sub_F65489_Join2:
	ld	(3302:16), wa	; F65624  ld (0x0ce6),WA
	ld	ix, wa	; F65628  ld IX,WA
	ld	wa, (3300:16)	; F6562A  ld WA,(0x0ce4)
	ld	(3159:16), wa	; F6562E  ld (0x0c57),WA
	call	T_BStore_SaveCursor	; F65632  call 0xf427b0
	ld	wa, (3276:16)	; F65636  ld WA,(0x0ccc)
	ld	(3169:16), wa	; F6563A  ld (0x0c61),WA
	ld	wa, (3278:16)	; F6563E  ld WA,(0x0cce)
	ld	(3175:16), wa	; F65642  ld (0x0c67),WA
	ld	wa, (3300:16)	; F65646  ld WA,(0x0ce4)
	ld	(3159:16), wa	; F6564A  ld (0x0c57),WA
	ld	wa, (3302:16)	; F6564E  ld WA,(0x0ce6)
	ld	(3165:16), wa	; F65652  ld (0x0c5d),WA
	ld	wa, (3502:16)	; F65656  ld WA,(0x0dae)
	cp	wa, (0x0db0:16)	; F6565A  cp WA,(0x0db0)
	jr	ugt, sub_F65489_Skip4	; F6565E  jr UGT,0xf6566e
	ld	de, (3494:16)	; F65660  ld DE,(0x0da6)
	ld	wa, (3492:16)	; F65664  ld WA,(0x0da4)
	ld	(3179:16), wa	; F65668  ld (0x0c6b),WA
	jr	sub_F65489_Join3	; F6566C  jr T,0xf6567a
sub_F65489_Skip4:
	ld	de, (3490:16)	; F6566E  ld DE,(0x0da2)
	ld	wa, (3488:16)	; F65672  ld WA,(0x0da0)
	ld	(3179:16), wa	; F65676  ld (0x0c6b),WA
sub_F65489_Join3:
	call	T_BStore_CopyRangeBackward	; F6567A  call 0xf4277c
	cp	(BStore_ErrorCode:16), 0x00	; F6567E  cp (0x0d4a),0x00
	jrl	nz, sub_F65489_Join7	; F65683  jrl NZ,0xf6575d
	ld	wa, (3502:16)	; F65686  ld WA,(0x0dae)
	cp	wa, (0x0db0:16)	; F6568A  cp WA,(0x0db0)
	jr	ugt, sub_F65489_Skip5	; F6568E  jr UGT,0xf656a3
	ld	xix, 3480	; F65690  ld XIX,0x00000d98
	ld	hl, (3494:16)	; F65695  ld HL,(0x0da6)
	ld	(3260:16), hl	; F65699  ld (0x0cbc),HL
	ld	iy, (3492:16)	; F6569D  ld IY,(0x0da4)
	jr	sub_F65489_Join4	; F656A1  jr T,0xf656b4
sub_F65489_Skip5:
	ld	xix, 3474	; F656A3  ld XIX,0x00000d92
	ld	hl, (3490:16)	; F656A8  ld HL,(0x0da2)
	ld	(3260:16), hl	; F656AC  ld (0x0cbc),HL
	ld	iy, (3488:16)	; F656B0  ld IY,(0x0da0)
sub_F65489_Join4:
	calr	sub_F65761	; F656B4  calr 0xf65761
	xor	wa, wa	; F656B7  xor WA,WA
	xor	hl, hl	; F656B9  xor HL,HL
	ld	l, (3486:16)	; F656BB  ld L,(0x0d9e)
	dec	1, hl	; F656BF  dec 1,HL
	push	xix	; F656C1  push XIX
	ld	xix, 6304928	; F656C2  ld XIX,0x006034a0
	ld	a, (xix+hl)	; F656C7  ld A,(XIX+HL)
	pop	xix	; F656CC  pop XIX
	xor	w, w	; F656CD  xor W,W
	ld	(3175:16), wa	; F656CF  ld (0x0c67),WA
	sla	hl, 1	; F656D3  sla 0x01,HL
	push	xix	; F656D6  push XIX
	ld	xix, 6304894	; F656D7  ld XIX,0x0060347e
	ld	wa, (xix+hl)	; F656DC  ld WA,(XIX+HL)
	pop	xix	; F656E1  pop XIX
	ld	(3169:16), wa	; F656E2  ld (0x0c61),WA
	ld	wa, (3496:16)	; F656E6  ld WA,(0x0da8)
	ld	(3159:16), wa	; F656EA  ld (0x0c57),WA
	ld	wa, (BStore_LastBlockFree:16)	; F656EE  ld WA,(0x0d08)
	ld	(3165:16), wa	; F656F2  ld (0x0c5d),WA
	ld	ix, wa	; F656F6  ld IX,WA
	call	T_BStore_SaveCursor	; F656F8  call 0xf427b0
	ld	wa, (3502:16)	; F656FC  ld WA,(0x0dae)
	cp	wa, (0x0db0:16)	; F65700  cp WA,(0x0db0)
	jr	ugt, sub_F65489_Skip6	; F65704  jr UGT,0xf65714
	ld	de, (3490:16)	; F65706  ld DE,(0x0da2)
	ld	wa, (3488:16)	; F6570A  ld WA,(0x0da0)
	ld	(3179:16), wa	; F6570E  ld (0x0c6b),WA
	jr	sub_F65489_Join5	; F65712  jr T,0xf65720
sub_F65489_Skip6:
	ld	de, (3494:16)	; F65714  ld DE,(0x0da6)
	ld	wa, (3492:16)	; F65718  ld WA,(0x0da4)
	ld	(3179:16), wa	; F6571C  ld (0x0c6b),WA
sub_F65489_Join5:
	call	T_BStore_CopyRangeBackward	; F65720  call 0xf4277c
	cp	(BStore_ErrorCode:16), 0x00	; F65724  cp (0x0d4a),0x00
	jrl	nz, sub_F65489_Join7	; F65729  jrl NZ,0xf6575d
	ld	wa, (3502:16)	; F6572C  ld WA,(0x0dae)
	cp	wa, (0x0db0:16)	; F65730  cp WA,(0x0db0)
	jr	ugt, sub_F65489_Skip7	; F65734  jr UGT,0xf65749
	ld	xix, 3474	; F65736  ld XIX,0x00000d92
	ld	iy, (3488:16)	; F6573B  ld IY,(0x0da0)
	ld	hl, (3490:16)	; F6573F  ld HL,(0x0da2)
	ld	(3260:16), hl	; F65743  ld (0x0cbc),HL
	jr	sub_F65489_Join6	; F65747  jr T,0xf6575a
sub_F65489_Skip7:
	ld	xix, 3480	; F65749  ld XIX,0x00000d98
	ld	iy, (3492:16)	; F6574E  ld IY,(0x0da4)
	ld	hl, (3494:16)	; F65752  ld HL,(0x0da6)
	ld	(3260:16), hl	; F65756  ld (0x0cbc),HL
sub_F65489_Join6:
	calr	sub_F65761	; F6575A  calr 0xf65761
sub_F65489_Join7:
	calr	BStore_RemapErrorCode	; F6575D  calr 0xf65792
	ret	; F65760  ret

; --------------------------------------------------------------------------
; sub_F65761
; Called from: in-module: 0xF6518A 0xF65534 0xF655C3 0xF656B4 0xF6575A
; Touches: (0x0D4A) (0x126E)
; Calls:   T_BStore_SeekBlock T_BStore_ReadCursorAdvance_Call BStore_RemapErrorCode
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF65761 is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F65761:
	xor	bc, bc	; F65761  xor BC,BC
	call	T_BStore_SeekBlock	; F65763  call 0xf427bc
sub_F65761_Join:
	cp	bc, 2:i3	; F65767  cp BC,2
	jr	ugt, sub_F65761_Skip	; F65769  jr UGT,0xf6578e
	ld	hl, bc	; F6576B  ld HL,BC
	ld	a, (xix+hl)	; F6576D  ld A,(XIX+HL)
	push	xde	; F65772  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F65773  ld XDE,(0x126e)
	ld	(xde+iy), a	; F65777  ld (XDE+IY),A
	pop	xde	; F6577C  pop XDE
	pushw	bc	; F6577D  push BC
	call	T_BStore_ReadCursorAdvance_Call	; F6577E  call 0xf4270c
	popw	bc	; F65782  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F65783  cp (0x0d4a),0x00
	jr	nz, sub_F65761_Skip	; F65788  jr NZ,0xf6578e
	inc	1, bc	; F6578A  inc 1,BC
	jr	sub_F65761_Join	; F6578C  jr T,0xf65767
sub_F65761_Skip:
	calr	BStore_RemapErrorCode	; F6578E  calr 0xf65792
	ret	; F65791  ret

; --------------------------------------------------------------------------
; BStore_RemapErrorCode
; Called from: in-module: 0xF650B0 0xF6518D 0xF65282 0xF653A1 0xF6547A
;              0xF6575D 0xF6578E
; Touches: (0x0D4A)
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription
;           (the sites are listed above), so 0xF65792 is an instruction
;           boundary.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_RemapErrorCode: BStore_ErrorCode = Remap_0D4A_F657A7[BStore_ErrorCode].
BStore_RemapErrorCode:
	xor	hl, hl	; F65792  xor HL,HL
	ld	l, (BStore_ErrorCode:16)	; F65794  ld L,(0x0d4a)
	ld	xde, Remap_0D4A_F657A7	; F65798  ld XDE,0x00f657a7
	ld	l, (xde+hl)	; F6579D  ld L,(XDE+HL)
	ld	(BStore_ErrorCode:16), l	; F657A2  ld (0x0d4a),L
	ret	; F657A6  ret
; --------------------------------------------------------------------------
; Remap_0D4A_F657A7 -- 0xF657A7-0xF657B2, 12 bytes: 0 0 2 3 4 5 6 0 0 9 10 11.
;   Converted 2026-09-25 (lane promb): the source framed the first 11 bytes as
;   instructions (`push SR`, `pop SR`, `max`, `halt`, `ei 0` ...) under the
;   label sub_F657A7 and the 12th as `Data_F657B2` ("everything about it
;   except its bytes" unknown).
; Read by: BStore_RemapErrorCode -- L = (0x0D4A), `ld XDE,0x00F657A7 / ld L,(XDE+HL)`,
;   `ld (0x0D4A),L`, called from seven sites in this module.  Entry k is k
;   itself except 1, 7 and 8, which become 0: the routine replaces three
;   values of (0x0D4A) by zero and leaves the others alone.
; Entry count: 12 -- the bytes that follow are the module's 0x0E padding;
;   what bounds (0x0D4A) is not decoded here.
; --------------------------------------------------------------------------
Remap_0D4A_F657A7:
	.byte	0x00, 0x00, 0x02, 0x03, 0x04, 0x05, 0x06, 0x00, 0x00, 0x09, 0x0A, 0x0B	; F657A7  [0..11]

	.fill	1101, 1, 0x0E	; F657B3-F65BFF  `ret` padding (asserted pure 0x0E)
