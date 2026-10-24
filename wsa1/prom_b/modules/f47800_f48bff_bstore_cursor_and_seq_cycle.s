

; ==============================================================================
; 0xF47800-0xF4EFFF -- EIGHT MODULES AT THE HEAD OF THE 0x047800 `.incbin` SPAN
;   92 thunk slots, including six of prom_b's ten most-referenced unconverted
;   targets, converted as one contiguous block
; ==============================================================================
;
; WHY THIS BLOCK.  notes/prom_b_call_graph.py ranks the unconverted thunk SLOTS
; of the whole image by an opcode-anchored reference upper bound.  Of the ELEVEN
; unconverted slots at x13 or more, EIGHT pointed here -- 0xF4E56F (x24),
; 0xF4D01D (x21), 0xF4D0DB (x18), 0xF4D02C (x15), 0xF4E524 (x14), 0xF4D0FB (x14),
; 0xF48580 (x13), 0xF48464 (x13) -- all inside this one `.incbin` span.
; ⚠ That is a THRESHOLD, not "N of the top ten": two slots tie at x13, two at x14
; and two at x15, so a top-N phrasing would depend on how the sort broke the ties.
; notes/prom_b_round3_frontier_delta.py re-derives both 11 and 8 from the ROM and
; asserts the threshold is tie-free.  notes/prom_b_module_frontier.py ranks whole
; RUNS, and the span holds nine of them; the eight modules converted here own 92
; thunk slots between them, the largest single-span slot count left in prom_b.
;
; ⚠ WHERE THE BOUNDARIES COME FROM.  notes/prom_a_linear_decode_check.py's
; warning applies: a TLCS-900 linear decode resynchronises within a couple of
; instructions, so "it decodes cleanly" pins nothing.  Every segment edge here is
; the `.incbin`'s own start, the first byte of a maximal 0x0E run whose purity is
; re-read on every emit, a THUNK TARGET, or an address a decoded instruction of
; this transcription names.  The split itself came from
; notes/prom_b_module_trace.py 0xF47800 0xF55000 -- a recursive descent from the
; span's 103 thunk entry points -- and every run it never reached was read by
; hand before being called code or data.
;
; LAYOUT.  Eight code modules, each closed by a run of 0x0E (`ret`) padding:
;   0xF47800-0xF487E9  code     0xF487EA-0xF48BFF  1,046 bytes of padding
;   0xF48C00-0xF48C19  data     Table_WsaSoundRamS0Wsa1
;   0xF48C1A-0xF494B7  code     0xF494B8-0xF497FF    840 bytes of padding
;   0xF49800-0xF4B7AC  code     0xF4B7AD-0xF4B7CC  IdentityMap_F4B7AD
;                               0xF4B7CD-0xF4BFFF  2,099 bytes of padding
;   0xF4C000-0xF4C3F1  data     DL_CreatorSelectController, ScreenButtonHandlers_CreatorSelectController, BitMask_F4C3E9
;   0xF4C3F2-0xF4C735  code     0xF4C736-0xF4C7FF    202 bytes of padding
;   0xF4C800-0xF4CB5A  code     0xF4CB5B-0xF4CFFF  1,189 bytes of padding
;   0xF4D000-0xF4D949  code     0xF4D94A-0xF4DFFF  1,718 bytes of padding
;   0xF4E000-0xF4E5DB  code     0xF4E5DC-0xF4E61B  IdentityMap_F4E5DC,
;                                                  BitWeight_F4E5FC
;                               0xF4E61C-0xF4EBFF  1,508 bytes of padding
;   0xF4EC00-0xF4EF2E  code     0xF4EF2F-0xF4EF63  Table_F4EF2F / _F4EF38 /
;                                                  _F4EF40
;                               0xF4EF64-0xF4EFFF    156 bytes of padding
;
; THE DATA, AND WHAT IT IS
;
;   0xF48C00  Table_WsaSoundRamS0Wsa1 -- 'WSA SOUND RAM S0', then 'WSA1', then six bytes.
;             The routine at the very next address copies the first sixteen to a
;             stack frame with `ldirw` and the next four with `ld XBC,(...)`.
;             The island's END is 0xF48C1A, the target of thunk slot T_DiskFile_CheckSignature, so
;             it is pinned by an entry point the hardware uses, not by a reading.
;
;   0xF4C000  DL_F4C000 -- 81 UI display-list records.  Their own length bytes
;             walk from 0xF4C000 onto 0xF4C38D exactly, which is where the
;             pointer table starts; that walk IS the record count's proof and it
;             is re-run on every emit.  Nothing spells 0xF4C000 as a 32-bit word,
;             so the list's caller is not established and the records are emitted
;             as framed `.byte` rows rather than rendered.
;             ⚠ 2026-09-25 (lane promb): the callers ARE in this module, with
;             24-bit `lda` operands -- Paint_CreatorSelectController and Paint_CreatorSelectControllerNames -- and the span is
;             six pieces, rendered below as DL_CreatorSelectController et al.
;
;   0xF4C38D  ScreenButtonHandlers_CreatorSelectController -- 23 pointers, 19 of them the default thunk
;             stub 0x00F42C70.
;
;   0xF4B7AD / 0xF4E5DC  two more IDENTITY MAPS, 32 bytes of 0..31 each, joining
;             the one at 0xF5EE75 that round 2 converted.  Three copies is a fact
;             recorded here, not an explanation.
;
;   0xF4EF40  Table_F4EF40 -- 36 bytes byte-identical to 0xF4EF1C-0xF4EF3F, with
;             no reference anywhere in either ROM.  Decoded as code its first
;             byte is `jrl GT,0xF52E63`, a jump into a padding run.  Dead
;             duplicate, recorded and not explained.
;
; ⚠ WHAT IS NOT ESTABLISHED.  What any of the eight modules is FOR.  Every
; routine here is `sub_XXXXXX` with a computed header claiming only its entry
; point and what it touches, per this tree's rule that a stated gap beats a
; plausible guess.
;
; ⚠ CORRECTED 2026-08-29 (wave 7 round 3).  This paragraph used to read "WHAT IS
; LEFT.  0xF4F000-0xF54FFF stays `.incbin`", and that span is now CONVERTED --
; see the module banner at 0xF4F000 below and notes/gen_prom_b_f4f000_module.py.
; The reason given here was that notes/prom_b_module_trace.py reaches none of
; 0xF4EF14-0xF53019 because no thunk slot points at it, so a code/data split
; would rest on a linear decode.  That reason was right about the TOOL and wrong
; about the SPAN: eleven slots of the thunk run T_F42E44-T_F42E6C do point into
; 0xF53000, and the boundaries the conversion uses come from
; notes/prom_b_f4f000_layout.py's content rules and a descent from those slots,
; not from a linear decode.  What module_trace cannot reach, it cannot reach;
; that is a limit of module_trace.
;
; REGENERATE:  python3 notes/gen_prom_b_f47800_module.py
; CHECKS:      python3 notes/gen_prom_b_f47800_module.py --checks
; ==============================================================================


; --------------------------------------------------------------------------
; sub_F47800
; Called from: T_F40B44 (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_F40B44 holds `jp 0x00F47800`, and 0xF47800 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F47800:		; <- T_F40B44
	jr	sub_F47800_Skip	; F47800  jr T,0xf4780a

; --------------------------------------------------------------------------
; sub_F47802
; Called from: T_F40B48 (x1)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_F40B48 holds `jp 0x00F47802`, and 0xF47802 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F47802:		; <- T_F40B48
	jr	sub_F47816_Join	; F47802  jr T,0xf47833

; --------------------------------------------------------------------------
; BStore_DirEntryHeadAtIY
; Called from: T_BStore_DirEntryHeadAtIY (x1); in-module: 0xF48512 0xF48751
; Touches: nothing with an absolute address
; Evidence: thunk slot T_BStore_DirEntryHeadAtIY holds `jp 0x00F47804`, and 0xF47804 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_DirEntryHeadAtIY: WA := the head block word (+1..+2) of block-store directory entry 0x603500 + IY; callers
;   pass IY = 3 * track. A `jrl` into its body at SeqTrackCursors_SaveTrack_Join (0xF483FC). SeqCycle_LocateToStart and SeqTrackCursors_RewindPlaying
;   store it as a track's saved cursor block (0x3460[t], offset 5); CycleRecord_CaptureStartCursors also calls it. Basis: callers + body +
;   the directory layout. (notes/naming-pilot-2026-10-06/proposals_wave4_k.json)
BStore_DirEntryHeadAtIY:		; <- T_BStore_DirEntryHeadAtIY
	jrl	SeqTrackCursors_SaveTrack_Join	; F47804  jrl T,0xf483fc

; --------------------------------------------------------------------------
; sub_F47807
; Called from: T_F40B50 (x0)
; Touches: nothing with an absolute address
; Calls:   T_F4097C sub_F47816
; Evidence: thunk slot T_F40B50 holds `jp 0x00F47807`, and 0xF47807 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F47807:		; <- T_F40B50
	jrl	sub_F47C7C	; F47807  jrl T,0xf47c7c
sub_F47800_Skip:
	call	T_F4097C	; F4780A  call 0xf4097c
	calr	sub_F47816	; F4780E  calr 0xf47816
	call	T_F4097C	; F47811  call 0xf4097c
	ret	; F47815  ret

; --------------------------------------------------------------------------
; sub_F47816
; Called from: in-module: 0xF4780E
; Touches: (0x3008)  |  0x000000
; Calls:   sub_F4783A sub_F479A2
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF47816 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F47816:
	ld	xwa, (6304798:24)	; F47816  ld XWA,(0x60341e)
	cp	xwa, 0	; F4781B  cp XWA,0x00000000
	jr	z, sub_F47816_Return	; F47821  jr Z,0xf47832
	ld	xwa, (12296:16)	; F47823  ld XWA,(0x3008)
	cp	xwa, 0	; F47827  cp XWA,0x00000000
	jr	z, sub_F47816_Return	; F4782D  jr Z,0xf47832
	calr	sub_F4783A	; F4782F  calr 0xf4783a
sub_F47816_Return:
	ret	; F47832  ret
sub_F47816_Join:
	calr	sub_F479A2	; F47833  calr 0xf479a2
	calr	sub_F4783A	; F47836  calr 0xf4783a
	ret	; F47839  ret

; --------------------------------------------------------------------------
; sub_F4783A
; Called from: in-module: 0xF4782F 0xF47836
; Touches: (0x207A) (0x3000) (0x3008) (0x33E0) (0x33E2) (0x33E4) (0x33E8)
;          (0x3452) (0x3454) (0x345B) +13 more  |  0x000000 0x003440
; Calls:   sub_F479AD sub_F47A73 sub_F47C25 T_SeqCycle_CheckOn sub_F47F9A sub_F479A2
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4783A is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4783A:
	and	(0x34d1:16), 0xfb	; F4783A  and (0x34d1),0xfb
	ei	6	; F4783F  ei 0x06
	ld	wa, (TransportB_Beat:8)	; F47841  ld WA,(0x91)
	ld	(13394:16), wa	; F47844  ld (0x3452),WA
	ld	a, (Seq_BeatTick:8)	; F47848  ld A,(0x93)
	ld	(13396:16), a	; F4784B  ld (0x3454),A
	ei	0	; F4784F  ei 0x00
	ld	a, (13396:16)	; F47851  ld A,(0x3454)
	ld	e, (13403:16)	; F47855  ld E,(0x345b)
	cp	a, e	; F47859  cp A,E
	jr	c, sub_F4783A_Skip	; F4785B  jr C,0xf47861
	sub	a, e	; F4785D  sub A,E
	jr	sub_F4783A_Join	; F4785F  jr T,0xf47866
sub_F4783A_Skip:
	add	a, 96	; F47861  add A,0x60
	sub	a, e	; F47864  sub A,E
sub_F4783A_Join:
	ld	(13288:16), a	; F47866  ld (0x33e8),A
	xor	w, w	; F4786A  xor W,W
	sub	(0x33e0:16), wa	; F4786C  sub (0x33e0),WA
	jr	nc, sub_F4783A_Skip2	; F47870  jr NC,0xf47878
	ldw	(13280:16), 0	; F47872  ld (0x33e0),0x0000
sub_F4783A_Skip2:
	ld	a, (13396:16)	; F47878  ld A,(0x3454)
	ld	(13403:16), a	; F4787C  ld (0x345b),A
	xor	wa, wa	; F47880  xor WA,WA
	xor	bc, bc	; F47882  xor BC,BC
	ld	xix, 13376	; F47884  ld XIX,0x00003440
	ld	c, 17:opc	; F47889  ld C,0x11
	ld	(xix+), a	; F4788B  ld (XIX+),A
	djnz16	bc, -6	; F4788E  djnz BC,0xf4788b
	xor	wa, wa	; F47891  xor WA,WA
	ld	a, (13288:16)	; F47893  ld A,(0x33e8)
	sub	(0x33e4:16), wa	; F47897  sub (0x33e4),WA
	jr	nc, sub_F4783A_Skip3	; F4789B  jr NC,0xf478a3
	ldw	(13284:16), 0	; F4789D  ld (0x33e4),0x0000
sub_F4783A_Skip3:
	ldw	(13282:16), 0	; F478A3  ld (0x33e2),0x0000
	calr	sub_F479AD	; F478A9  calr 0xf479ad
	ld	a, 42:opc	; F478AC  ld A,0x2a
	bit	5, (0x34d0:16)	; F478AE  bit 5,(0x34d0)
	jr	z, sub_F4783A_Skip4	; F478B2  jr Z,0xf478b6
	ld	a, 17:opc	; F478B4  ld A,0x11
sub_F4783A_Skip4:
	ld	(13474:16), a	; F478B6  ld (0x34a2),A
sub_F4783A_Join2:
	xor	bc, bc	; F478BA  xor BC,BC
	ld	c, (13474:16)	; F478BC  ld C,(0x34a2)
	dec	1, bc	; F478C0  dec 1,BC
	dec	1, bc	; F478C2  dec 1,BC
	ld	wa, (13284:16)	; F478C4  ld WA,(0x33e4)
	ld	de, (13280:16)	; F478C8  ld DE,(0x33e0)
	cp	wa, de	; F478CC  cp WA,DE
	jr	ugt, sub_F4783A_Skip6	; F478CE  jr UGT,0xf478dd
	cp	wa, bc	; F478D0  cp WA,BC
	jr	c, sub_F4783A_Skip5	; F478D2  jr C,0xf478d7
	jrl	sub_F4783A_Return	; F478D4  jrl T,0xf479a1
sub_F4783A_Skip5:
	ld	(13472:16), a	; F478D7  ld (0x34a0),A
	jr	sub_F4783A_Join3	; F478DB  jr T,0xf478e6
sub_F4783A_Skip6:
	cp	de, bc	; F478DD  cp DE,BC
	jrl	nc, sub_F4783A_Return	; F478DF  jrl NC,0xf479a1
	ld	(13472:16), e	; F478E2  ld (0x34a0),E
sub_F4783A_Join3:
	calr	sub_F47A73	; F478E6  calr 0xf47a73
	bit	2, (0x34d1:16)	; F478E9  bit 2,(0x34d1)
	jrl	nz, sub_F4783A_Join5	; F478ED  jrl NZ,0xf4799e
	bit	4, (0x34d0:16)	; F478F0  bit 4,(0x34d0)
	jr	nz, sub_F4783A_Skip7	; F478F4  jr NZ,0xf478ff
	cpw	(0x33e2:16), 0x0078	; F478F6  cp (0x33e2),0x0078
	jrl	ugt, sub_F4783A_Return	; F478FC  jrl UGT,0xf479a1
sub_F4783A_Skip7:
	calr	sub_F47C25	; F478FF  calr 0xf47c25
	bit	2, (TransportB_State:8)	; F47902  bit 2,(0x96)
	jr	nz, sub_F4783A_Skip8	; F47905  jr NZ,0xf4790d
	bit	5, (0x34d4:16)	; F47907  bit 5,(0x34d4)
	jr	z, sub_F4783A_Skip12	; F4790B  jr Z,0xf47978
sub_F4783A_Skip8:
	call	T_SeqCycle_CheckOn	; F4790D  call 0xf40aa4
	cp	a, 0:i3	; F47911  cp A,0
	jr	nz, sub_F4783A_Skip12	; F47913  jr NZ,0xf47978
	ld	xwa, (14022:16)	; F47915  ld XWA,(0x36c6)
	cp	xwa, 0	; F47919  cp XWA,0x00000000
	jr	nz, sub_F4783A_Skip12	; F4791F  jr NZ,0xf47978
	cp	(UI_ScreenLatch:16), 0x06	; F47921  cp (0x207a),0x06
	jr	z, sub_F4783A_Skip9	; F47926  jr Z,0xf4792f
	cp	(UI_ScreenLatch:16), 0x08	; F47928  cp (0x207a),0x08
	jr	nz, sub_F4783A_Skip10	; F4792D  jr NZ,0xf47943
sub_F4783A_Skip9:
	bit	1, (0x360b:16)	; F4792F  bit 1,(0x360b)
	jr	z, sub_F4783A_Skip12	; F47933  jr Z,0xf47978
	ld	xwa, (12288:16)	; F47935  ld XWA,(0x3000)
	cp	xwa, 0	; F47939  cp XWA,0x00000000
	jr	z, sub_F4783A_Skip10	; F4793F  jr Z,0xf47943
	jr	sub_F4783A_Join4	; F47941  jr T,0xf47949
sub_F4783A_Skip10:
	bit	1, (0x3731:16)	; F47943  bit 1,(0x3731)
	jr	z, sub_F4783A_Join5	; F47947  jr Z,0xf4799e
sub_F4783A_Join4:
	res	1, (0x3731:16)	; F47949  res 1,(0x3731)
	ld	xwa, (14026:16)	; F4794D  ld XWA,(0x36ca)
	ld	(14022:16), xwa	; F47951  ld (0x36c6),XWA
	ld	(13466:16), xwa	; F47955  ld (0x349a),XWA
	ld	(12296:16), xwa	; F47959  ld (0x3008),XWA
	calr	sub_F47F9A	; F4795D  calr 0xf47f9a
	cp	(0x3752:16), 0x00	; F47960  cp (0x3752),0x00
	jr	z, sub_F4783A_Skip11	; F47965  jr Z,0xf47976
	ld	a, (14169:16)	; F47967  ld A,(0x3759)
	dec	1, a	; F4796B  dec 1,A
	ld	(14164:16), a	; F4796D  ld (0x3754),A
	or	(0x3754:16), 0x80	; F47971  or (0x3754),0x80
sub_F4783A_Skip11:
	jr	sub_F4783A_Join5	; F47976  jr T,0xf4799e
sub_F4783A_Skip12:
	bit	2, (0x34d1:16)	; F47978  bit 2,(0x34d1)
	jr	nz, sub_F4783A_Join5	; F4797C  jr NZ,0xf4799e
	bit	4, (0x34d0:16)	; F4797E  bit 4,(0x34d0)
	jr	nz, sub_F4783A_Skip13	; F47982  jr NZ,0xf4798c
	cpw	(0x33e2:16), 0x0078	; F47984  cp (0x33e2),0x0078
	jr	ugt, sub_F4783A_Return	; F4798A  jr UGT,0xf479a1
sub_F4783A_Skip13:
	add	(0x34a0:16), 0x02	; F4798C  add (0x34a0),0x02
	ld	a, (13474:16)	; F47991  ld A,(0x34a2)
	cp	(13472:16), a	; F47995  cp (0x34a0),A
	jr	nc, sub_F4783A_Return	; F47999  jr NC,0xf479a1
	jrl	sub_F4783A_Join2	; F4799B  jrl T,0xf478ba
sub_F4783A_Join5:
	calr	sub_F479A2	; F4799E  calr 0xf479a2
sub_F4783A_Return:
	ret	; F479A1  ret

; --------------------------------------------------------------------------
; sub_F479A2
; Called from: in-module: 0xF47833 0xF4799E
; Touches: (0x33E0) (0x33E4)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF479A2 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F479A2:
	xor	wa, wa	; F479A2  xor WA,WA
	ld	(13284:16), wa	; F479A4  ld (0x33e4),WA
	ld	(13280:16), wa	; F479A8  ld (0x33e0),WA
	ret	; F479AC  ret

; --------------------------------------------------------------------------
; sub_F479AD
; Called from: in-module: 0xF478A9
; Touches: (0x3008) (0x33DA) (0x33E8) (0x349F)  |  0x0033E0
; Calls:   sub_F47A41 sub_F47A5D
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF479AD is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F479AD:
	push	xwa	; F479AD  push XWA
	push	xbc	; F479AE  push XBC
	push	xde	; F479AF  push XDE
	push	xhl	; F479B0  push XHL
	push	xix	; F479B1  push XIX
	push	xiy	; F479B2  push XIY
	push	xiz	; F479B3  push XIZ
	xor	bc, bc	; F479B4  xor BC,BC
	ld	(13471:16), c	; F479B6  ld (0x349f),C
sub_F479AD_Loop:
	ld	c, (13471:16)	; F479BA  ld C,(0x349f)
	ld	xwa, (6304798:24)	; F479BE  ld XWA,(0x60341e)
	and	xwa, (0x3008:16)	; F479C3  and XWA,(0x3008)
	cp	c, 16	; F479C7  cp C,0x10
	jr	nc, sub_F479AD_Skip	; F479CA  jr NC,0xf479d9
	ld	de, wa	; F479CC  ld DE,WA
	ld	a, c	; F479CE  ld A,C
	scf	; F479D0  scf
	xorcf_a_16	de	; F479D1  xorcf A,DE
	ld	wa, de	; F479D3  ld WA,DE
	jr	c, sub_F479AD_Skip4	; F479D5  jr C,0xf47a2e
	jr	sub_F479AD_Join	; F479D7  jr T,0xf479eb
sub_F479AD_Skip:
	pushw	wa	; F479D9  push WA
	ld	de, qwa	; F479DA  ld DE,QWA
	ld	a, c	; F479DD  ld A,C
	sub	a, 16	; F479DF  sub A,0x10
	scf	; F479E2  scf
	xorcf_a_16	de	; F479E3  xorcf A,DE
	ld	qwa, de	; F479E5  ld QWA,DE
	popw	wa	; F479E8  pop WA
	jr	c, sub_F479AD_Skip4	; F479E9  jr C,0xf47a2e
sub_F479AD_Join:
	calr	sub_F47A41	; F479EB  calr 0xf47a41
	cp	(0x33da:16), 0x00	; F479EE  cp (0x33da),0x00
	jr	z, sub_F479AD_Skip4	; F479F3  jr Z,0xf47a2e
	xor	hl, hl	; F479F5  xor HL,HL
	ld	l, (13274:16)	; F479F7  ld L,(0x33da)
sub_F479AD_Join2:
	calr	sub_F47A5D	; F479FB  calr 0xf47a5d
	ld	bc, (xhl+1)	; F479FE  ld BC,(XHL+0x01)
	xor	de, de	; F47A01  xor DE,DE
	ld	e, (13288:16)	; F47A03  ld E,(0x33e8)
	cp	bc, de	; F47A07  cp BC,DE
	jr	c, sub_F479AD_Skip2	; F47A09  jr C,0xf47a0f
	sub	bc, de	; F47A0B  sub BC,DE
	jr	sub_F479AD_Join3	; F47A0D  jr T,0xf47a11
sub_F479AD_Skip2:
	xor	bc, bc	; F47A0F  xor BC,BC
sub_F479AD_Join3:
	ld	(xhl+1), bc	; F47A11  ld (XHL+0x01),BC
	ld	xiy, 13280	; F47A14  ld XIY,0x000033e0
	cp	(xiy), bc	; F47A19  cp (XIY),BC
	jr	ule, sub_F479AD_Skip3	; F47A1B  jr ULE,0xf47a1f
	ld	(xiy), bc	; F47A1D  ld (XIY),BC
sub_F479AD_Skip3:
	cp	(xhl+5), 0xff	; F47A1F  cp (XHL+0x05),0xff
	jr	z, sub_F479AD_Skip4	; F47A23  jr Z,0xf47a2e
	xor	wa, wa	; F47A25  xor WA,WA
	ld	a, (xhl+5)	; F47A27  ld A,(XHL+0x05)
	ld	hl, wa	; F47A2A  ld HL,WA
	jr	sub_F479AD_Join2	; F47A2C  jr T,0xf479fb
sub_F479AD_Skip4:
	inc	1, (13471:16)	; F47A2E  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F47A32  cp (0x349f),0x11
	jr	c, sub_F479AD_Loop	; F47A37  jr C,0xf479ba
	pop	xiz	; F47A39  pop XIZ
	pop	xiy	; F47A3A  pop XIY
	pop	xix	; F47A3B  pop XIX
	pop	xhl	; F47A3C  pop XHL
	pop	xde	; F47A3D  pop XDE
	pop	xbc	; F47A3E  pop XBC
	pop	xwa	; F47A3F  pop XWA
	ret	; F47A40  ret

; --------------------------------------------------------------------------
; sub_F47A41
; Called from: in-module: 0xF479EB 0xF47AD0 0xF4821C
; Touches: (0x33DA) (0x349F)  |  0x003038
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF47A41 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F47A41:
	push	xhl	; F47A41  push XHL
	xor	bc, bc	; F47A42  xor BC,BC
	ld	c, (13471:16)	; F47A44  ld C,(0x349f)
	ld	iy, bc	; F47A48  ld IY,BC
	sla	iy, 1	; F47A4A  sla 0x01,IY
	ld	xhl, 12344	; F47A4D  ld XHL,0x00003038
	ld	bc, (xhl+iy)	; F47A52  ld BC,(XHL+IY)
	ld	(13274:16), bc	; F47A57  ld (0x33da),BC
	pop	xhl	; F47A5B  pop XHL
	ret	; F47A5C  ret

; --------------------------------------------------------------------------
; sub_F47A5D
; Called from: T_F40B58 (x2); in-module: 0xF479FB 0xF47AE5 0xF47B74 0xF47BB3
;              0xF47BFF 0xF481CA 0xF48260 0xF482A4
; Touches:   |  0x00325A
; Evidence: thunk slot T_F40B58 holds `jp 0x00F47A5D`, and 0xF47A5D is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F47A5D:		; <- T_F40B58
	ld	qhl, 0	; F47A5D  ld QHL,0
	dec	1, hl	; F47A60  dec 1,HL
	sla	hl, 1	; F47A62  sla 0x01,HL
	ld	wa, hl	; F47A65  ld WA,HL
	sla	hl, 1	; F47A67  sla 0x01,HL
	add	hl, wa	; F47A6A  add HL,WA
	add	xhl, 12890	; F47A6C  add XHL,0x0000325a
	ret	; F47A72  ret

; --------------------------------------------------------------------------
; sub_F47A73
; Called from: in-module: 0xF478E6
; Touches: (0x3008) (0x33E0) (0x349F) (0x34A0) (0x34D1)
; Calls:   sub_F47AD0
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF47A73 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F47A73:
	xor	b, b	; F47A73  xor B,B
	ld	c, (13472:16)	; F47A75  ld C,(0x34a0)
	cp	(0x33e0:16), bc	; F47A79  cp (0x33e0),BC
	jr	ugt, sub_F47A73_Return	; F47A7D  jr UGT,0xf47acf
	ldw	(13280:16), 65535	; F47A7F  ld (0x33e0),0xffff
	ld	(13471:16), 0	; F47A85  ld (0x349f),0x00
sub_F47A73_Loop:
	ld	c, (13471:16)	; F47A8A  ld C,(0x349f)
	ld	xwa, (6304798:24)	; F47A8E  ld XWA,(0x60341e)
	and	xwa, (0x3008:16)	; F47A93  and XWA,(0x3008)
	cp	c, 16	; F47A97  cp C,0x10
	jr	nc, sub_F47A73_Skip	; F47A9A  jr NC,0xf47aa9
	ld	de, wa	; F47A9C  ld DE,WA
	ld	a, c	; F47A9E  ld A,C
	scf	; F47AA0  scf
	xorcf_a_16	de	; F47AA1  xorcf A,DE
	ld	wa, de	; F47AA3  ld WA,DE
	jr	c, sub_F47A73_Skip2	; F47AA5  jr C,0xf47ac4
	jr	sub_F47A73_Join	; F47AA7  jr T,0xf47abb
sub_F47A73_Skip:
	pushw	wa	; F47AA9  push WA
	ld	de, qwa	; F47AAA  ld DE,QWA
	ld	a, c	; F47AAD  ld A,C
	sub	a, 16	; F47AAF  sub A,0x10
	scf	; F47AB2  scf
	xorcf_a_16	de	; F47AB3  xorcf A,DE
	ld	qwa, de	; F47AB5  ld QWA,DE
	popw	wa	; F47AB8  pop WA
	jr	c, sub_F47A73_Skip2	; F47AB9  jr C,0xf47ac4
sub_F47A73_Join:
	calr	sub_F47AD0	; F47ABB  calr 0xf47ad0
	bit	2, (0x34d1:16)	; F47ABE  bit 2,(0x34d1)
	jr	nz, sub_F47A73_Return	; F47AC2  jr NZ,0xf47acf
sub_F47A73_Skip2:
	inc	1, (13471:16)	; F47AC4  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F47AC8  cp (0x349f),0x11
	jr	c, sub_F47A73_Loop	; F47ACD  jr C,0xf47a8a
sub_F47A73_Return:
	ret	; F47ACF  ret

; --------------------------------------------------------------------------
; sub_F47AD0
; Called from: in-module: 0xF47ABB
; Touches: (0x33DA) (0x33DD) (0x33DE) (0x33DF) (0x33E0) (0x33E2) (0x3454)
;          (0x349F) (0x34A0) (0x34D1)  |  0x003015 0x003038
; Calls:   sub_F47A41 sub_F47A5D T_BStore_WriteCursorByte_Join6_Veneer T_TimedEventRing_Put
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF47AD0 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F47AD0:
	calr	sub_F47A41	; F47AD0  calr 0xf47a41
	cp	(0x33da:16), 0x00	; F47AD3  cp (0x33da),0x00
	jrl	z, sub_F47AD0_Return	; F47AD8  jrl Z,0xf47c19
	xor	hl, hl	; F47ADB  xor HL,HL
	ld	l, (13274:16)	; F47ADD  ld L,(0x33da)
sub_F47AD0_Join:
	ld	(13279:16), l	; F47AE1  ld (0x33df),L
	calr	sub_F47A5D	; F47AE5  calr 0xf47a5d
	ld	a, (xhl+4)	; F47AE8  ld A,(XHL+0x04)
	ld	(13277:16), a	; F47AEB  ld (0x33dd),A
	ld	a, (xhl+5)	; F47AEF  ld A,(XHL+0x05)
	ld	(13278:16), a	; F47AF2  ld (0x33de),A
	xor	wa, wa	; F47AF6  xor WA,WA
	ld	a, (13472:16)	; F47AF8  ld A,(0x34a0)
	cp	(xhl+1), wa	; F47AFC  cp (XHL+0x01),WA
	jr	ule, sub_F47AD0_Skip	; F47AFF  jr ULE,0xf47b12
	ld	wa, (xhl+1)	; F47B01  ld WA,(XHL+0x01)
	cp	wa, (0x33e0:16)	; F47B04  cp WA,(0x33e0)
	jrl	nc, sub_F47AD0_Join4	; F47B08  jrl NC,0xf47c09
	ld	(13280:16), wa	; F47B0B  ld (0x33e0),WA
	jrl	sub_F47AD0_Join4	; F47B0F  jrl T,0xf47c09
sub_F47AD0_Skip:
	push	xhl	; F47B12  push XHL
	call	T_BStore_WriteCursorByte_Join6_Veneer	; F47B13  call 0xf40c6c
	pop	xhl	; F47B17  pop XHL
	bit	2, (0x34d1:16)	; F47B18  bit 2,(0x34d1)
	jrl	nz, sub_F47AD0_Return	; F47B1C  jrl NZ,0xf47c19
	addw	(0x33e2:16), 0x0003	; F47B1F  add (0x33e2),0x0003
	ld	e, (xhl)	; F47B25  ld E,(XHL)
	ld	d, (xhl+1)	; F47B27  ld D,(XHL+0x01)
	ld	a, (xhl+3)	; F47B2A  ld A,(XHL+0x03)
	pushw	wa	; F47B2D  push WA
	call	T_TimedEventRing_Put	; F47B2E  call 0xf41d64
	inc	2, xsp	; F47B32  inc 2,XSP
	ld	a, (13396:16)	; F47B34  ld A,(0x3454)
	add	a, d	; F47B38  add A,D
	cp	a, 96	; F47B3A  cp A,0x60
	jr	c, sub_F47AD0_Skip2	; F47B3D  jr C,0xf47b42
	sub	a, 96	; F47B3F  sub A,0x60
sub_F47AD0_Skip2:
	pushw	wa	; F47B42  push WA
	call	T_TimedEventRing_Put	; F47B43  call 0xf41d64
	inc	2, xsp	; F47B47  inc 2,XSP
	ld	a, e	; F47B49  ld A,E
	pushw	wa	; F47B4B  push WA
	call	T_TimedEventRing_Put	; F47B4C  call 0xf41d64
	inc	2, xsp	; F47B50  inc 2,XSP
	xor	a, a	; F47B52  xor A,A
	pushw	wa	; F47B54  push WA
	call	T_TimedEventRing_Put	; F47B55  call 0xf41d64
	inc	2, xsp	; F47B59  inc 2,XSP
	ld	a, (13471:16)	; F47B5B  ld A,(0x349f)
	pushw	wa	; F47B5F  push WA
	call	T_TimedEventRing_Put	; F47B60  call 0xf41d64
	inc	2, xsp	; F47B64  inc 2,XSP
	cp	(0x33dd:16), 0x00	; F47B66  cp (0x33dd),0x00
	jr	z, sub_F47AD0_Skip3	; F47B6B  jr Z,0xf47b81
	push	xhl	; F47B6D  push XHL
	xor	hl, hl	; F47B6E  xor HL,HL
	ld	l, (13277:16)	; F47B70  ld L,(0x33dd)
	calr	sub_F47A5D	; F47B74  calr 0xf47a5d
	ld	a, (13278:16)	; F47B77  ld A,(0x33de)
	ld	(xhl+5), a	; F47B7B  ld (XHL+0x05),A
	pop	xhl	; F47B7E  pop XHL
	jr	sub_F47AD0_Join2	; F47B7F  jr T,0xf47ba5
sub_F47AD0_Skip3:
	push	xhl	; F47B81  push XHL
	xor	iy, iy	; F47B82  xor IY,IY
	xor	wa, wa	; F47B84  xor WA,WA
	ld	a, (13471:16)	; F47B86  ld A,(0x349f)
	ld	iy, wa	; F47B8A  ld IY,WA
	sla	iy, 1	; F47B8C  sla 0x01,IY
	ld	xhl, 12344	; F47B8F  ld XHL,0x00003038
	ld	a, (13278:16)	; F47B94  ld A,(0x33de)
	cp	a, 255	; F47B98  cp A,0xff
	jr	nz, sub_F47AD0_Skip4	; F47B9B  jr NZ,0xf47b9f
	ld	a, 0:opc	; F47B9D  ld A,0x00
sub_F47AD0_Skip4:
	ld	(xhl+iy), a	; F47B9F  ld (XHL+IY),A
	pop	xhl	; F47BA4  pop XHL
sub_F47AD0_Join2:
	cp	(0x33de:16), 0xff	; F47BA5  cp (0x33de),0xff
	jr	z, sub_F47AD0_Skip5	; F47BAA  jr Z,0xf47bc0
	push	xhl	; F47BAC  push XHL
	xor	hl, hl	; F47BAD  xor HL,HL
	ld	l, (13278:16)	; F47BAF  ld L,(0x33de)
	calr	sub_F47A5D	; F47BB3  calr 0xf47a5d
	ld	a, (13277:16)	; F47BB6  ld A,(0x33dd)
	ld	(xhl+4), a	; F47BBA  ld (XHL+0x04),A
	pop	xhl	; F47BBD  pop XHL
	jr	sub_F47AD0_Join3	; F47BBE  jr T,0xf47be2
sub_F47AD0_Skip5:
	push	xhl	; F47BC0  push XHL
	xor	iy, iy	; F47BC1  xor IY,IY
	xor	wa, wa	; F47BC3  xor WA,WA
	ld	a, (13471:16)	; F47BC5  ld A,(0x349f)
	ld	iy, wa	; F47BC9  ld IY,WA
	sla	iy, 1	; F47BCB  sla 0x01,IY
	ld	xhl, 12344	; F47BCE  ld XHL,0x00003038
	ld	a, (13277:16)	; F47BD3  ld A,(0x33dd)
	ld	xiz, xhl	; F47BD7  ld XIZ,XHL
	lda	xiz, (xiz+iy)	; F47BD9  lda XIZ,XIZ+IY
	ld	(xiz+1), a	; F47BDE  ld (XIZ+0x01),A
	pop	xhl	; F47BE1  pop XHL
sub_F47AD0_Join3:
	ld	(xhl+4), 0	; F47BE2  ld (XHL+0x04),0x00
	ld	xix, 12309	; F47BE6  ld XIX,0x00003015
	ld	c, (xix)	; F47BEB  ld C,(XIX)
	ld	(xhl+5), c	; F47BED  ld (XHL+0x05),C
	ld	a, (13279:16)	; F47BF0  ld A,(0x33df)
	ld	(xix), a	; F47BF4  ld (XIX),A
	cp	c, 255	; F47BF6  cp C,0xff
	jr	z, sub_F47AD0_Join4	; F47BF9  jr Z,0xf47c09
	xor	hl, hl	; F47BFB  xor HL,HL
	ld	l, c	; F47BFD  ld L,C
	calr	sub_F47A5D	; F47BFF  calr 0xf47a5d
	ld	a, (13279:16)	; F47C02  ld A,(0x33df)
	ld	(xhl+4), a	; F47C06  ld (XHL+0x04),A
sub_F47AD0_Join4:
	cp	(0x33de:16), 0xff	; F47C09  cp (0x33de),0xff
	jr	z, sub_F47AD0_Return	; F47C0E  jr Z,0xf47c19
	xor	hl, hl	; F47C10  xor HL,HL
	ld	l, (13278:16)	; F47C12  ld L,(0x33de)
	jrl	sub_F47AD0_Join	; F47C16  jrl T,0xf47ae1
sub_F47AD0_Return:
	ret	; F47C19  ret

; --------------------------------------------------------------------------
; sub_F47C1A
; Called from: in-module: 0xF47C64
; Touches: (0x34A0) (0x34A1)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF47C1A is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F47C1A:
	ld	a, (13472:16)	; F47C1A  ld A,(0x34a0)
	jr	sub_F47C1A_Join	; F47C1E  jr T,0xf47c20
sub_F47C1A_Join:
	ld	(13473:16), a	; F47C20  ld (0x34a1),A
	ret	; F47C24  ret

; --------------------------------------------------------------------------
; sub_F47C25
; Called from: in-module: 0xF478FF
; Touches: (0x3008) (0x300A) (0x33E4) (0x349F) (0x34A0) (0x34D1)
; Calls:   sub_F47C1A sub_F47C7C
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF47C25 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F47C25:
	xor	b, b	; F47C25  xor B,B
	ld	c, (13472:16)	; F47C27  ld C,(0x34a0)
	cp	(0x33e4:16), bc	; F47C2B  cp (0x33e4),BC
	jr	ugt, sub_F47C25_Return	; F47C2F  jr UGT,0xf47c7b
	ldw	(13284:16), 96	; F47C31  ld (0x33e4),0x0060
	ld	(13471:16), 0	; F47C37  ld (0x349f),0x00
sub_F47C25_Loop:
	ld	c, (13471:16)	; F47C3C  ld C,(0x349f)
	cp	c, 16	; F47C40  cp C,0x10
	jr	nc, sub_F47C25_Skip	; F47C43  jr NC,0xf47c54
	pushw	wa	; F47C45  push WA
	ld	iz, (12296:16)	; F47C46  ld IZ,(0x3008)
	ld	a, c	; F47C4A  ld A,C
	scf	; F47C4C  scf
	xorcf_a_16	iz	; F47C4D  xorcf A,IZ
	popw	wa	; F47C4F  pop WA
	jr	c, sub_F47C25_Skip2	; F47C50  jr C,0xf47c70
	jr	sub_F47C25_Join	; F47C52  jr T,0xf47c64
sub_F47C25_Skip:
	pushw	wa	; F47C54  push WA
	ld	iz, (12298:16)	; F47C55  ld IZ,(0x300a)
	ld	a, c	; F47C59  ld A,C
	sub	a, 16	; F47C5B  sub A,0x10
	scf	; F47C5E  scf
	xorcf_a_16	iz	; F47C5F  xorcf A,IZ
	popw	wa	; F47C61  pop WA
	jr	c, sub_F47C25_Skip2	; F47C62  jr C,0xf47c70
sub_F47C25_Join:
	calr	sub_F47C1A	; F47C64  calr 0xf47c1a
	calr	sub_F47C7C	; F47C67  calr 0xf47c7c
	bit	2, (0x34d1:16)	; F47C6A  bit 2,(0x34d1)
	jr	nz, sub_F47C25_Return	; F47C6E  jr NZ,0xf47c7b
sub_F47C25_Skip2:
	inc	1, (13471:16)	; F47C70  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F47C74  cp (0x349f),0x11
	jr	c, sub_F47C25_Loop	; F47C79  jr C,0xf47c3c
sub_F47C25_Return:
	ret	; F47C7B  ret

; --------------------------------------------------------------------------
; sub_F47C7C
; Called from: in-module: 0xF47C67
; Touches: (0x3008) (0x300A) (0x33E2) (0x345C) (0x345E) (0x3494) (0x3496)
;          (0x3498) (0x349E) (0x349F) +12 more  |  0x0034A4 0x00365E
;          0x003680 0x0036E9 0xFFFFF8
; Calls:   sub_F4802B BStore_ReadCursorByte_Call BStore_StepCursorOneByte_Call sub_F48056 CycleRecord_CheckIsRecordTrack_Copy T_F40BE8
;          T_SeqCycle_CheckOn T_F40ABC sub_F47F3E BStore_StepCursorToNextLeadByte sub_F4812F T_Seq_StopAll_Veneer +12
;          more
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF47C7C is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F47C7C:
	ld	c, (13471:16)	; F47C7C  ld C,(0x349f)
	calr	sub_F4802B	; F47C80  calr 0xf4802b
	ld	(13652:16), 0	; F47C83  ld (0x3554),0x00
sub_F47C7C_Join:
	calr	BStore_ReadCursorByte_Call	; F47C88  calr 0xf4840e
	ld	(13470:16), a	; F47C8B  ld (0x349e),A
	cp	a, 130	; F47C8F  cp A,0x82
	jr	nz, sub_F47C7C_Skip	; F47C92  jr NZ,0xf47c97
	jrl	sub_F47C7C_Join7	; F47C94  jrl T,0xf47eeb
sub_F47C7C_Skip:
	cp	a, 129	; F47C97  cp A,0x81
	jr	z, sub_F47C7C_Skip2	; F47C9A  jr Z,0xf47cb6
	ld	de, (BStore_CursorBlock:16)	; F47C9C  ld DE,(0x345c)
	ld	bc, (BStore_CursorOffset:16)	; F47CA0  ld BC,(0x345e)
	calr	BStore_StepCursorOneByte_Call	; F47CA4  calr 0xf4842f
	calr	BStore_ReadCursorByte_Call	; F47CA7  calr 0xf4840e
	ld	(13464:16), a	; F47CAA  ld (0x3498),A
	ld	(BStore_CursorBlock:16), de	; F47CAE  ld (0x345c),DE
	ld	(BStore_CursorOffset:16), bc	; F47CB2  ld (0x345e),BC
sub_F47C7C_Skip2:
	calr	sub_F48056	; F47CB6  calr 0xf48056
	cp	a, 0:i3	; F47CB9  cp A,0
	jrl	z, sub_F47C7C_Join9	; F47CBB  jrl Z,0xf47f36
	cp	(0x349e:16), 0x81	; F47CBE  cp (0x349e),0x81
	jrl	nz, sub_F47C7C_Join3	; F47CC3  jrl NZ,0xf47d43
	calr	CycleRecord_CheckIsRecordTrack_Copy	; F47CC6  calr 0xf47f69
	cp	a, 0:i3	; F47CC9  cp A,0
	jr	nz, sub_F47C7C_Skip3	; F47CCB  jr NZ,0xf47cdd
	ld	(14056:16), 129	; F47CCD  ld (0x36e8),0x81
	ld	(14064:16), 1	; F47CD2  ld (0x36f0),0x01
	call	T_F40BE8	; F47CD7  call 0xf40be8
	jr	sub_F47C7C_Join3	; F47CDB  jr T,0xf47d43
sub_F47C7C_Skip3:
	call	T_SeqCycle_CheckOn	; F47CDD  call 0xf40aa4
	cp	a, 0:i3	; F47CE1  cp A,0
	jr	nz, sub_F47C7C_Join3	; F47CE3  jr NZ,0xf47d43
	ld	a, (13471:16)	; F47CE5  ld A,(0x349f)
	sll	a, 1	; F47CE9  sll 0x01,A
	ld	de, (BStore_CursorBlock:16)	; F47CEC  ld DE,(0x345c)
	ld	xbc, 13918	; F47CF0  ld XBC,0x0000365e
	.byte 0xD3, 0x03, 0xE4, 0xE0, 0xFA	; F47CF5  cp (XBC+A),DE   [llvm-mc cannot encode this]
	jr	nz, sub_F47C7C_Join3	; F47CFA  jr NZ,0xf47d43
	srl	a, 1	; F47CFC  srl 0x01,A
	ld	e, (BStore_CursorOffset:16)	; F47CFF  ld E,(0x345e)
	ld	xbc, 13952	; F47D03  ld XBC,0x00003680
	.byte 0xC3, 0x03, 0xE4, 0xE0, 0xFD	; F47D08  cp (XBC+A),E   [llvm-mc cannot encode this]
	jr	nz, sub_F47C7C_Join3	; F47D0D  jr NZ,0xf47d43
	call	T_F40ABC	; F47D0F  call 0xf40abc
	calr	sub_F47F3E	; F47D13  calr 0xf47f3e
	ld	a, (13471:16)	; F47D16  ld A,(0x349f)
	cp	a, 16	; F47D1A  cp A,0x10
	jr	nc, sub_F47C7C_Skip4	; F47D1D  jr NC,0xf47d2c
	ld	bc, (14022:16)	; F47D1F  ld BC,(0x36c6)
	rcf	; F47D23  rcf
	stcf_a_16	bc	; F47D24  stcf A,BC
	ld	(14022:16), bc	; F47D26  ld (0x36c6),BC
	jr	sub_F47C7C_Join2	; F47D2A  jr T,0xf47d3c
sub_F47C7C_Skip4:
	pushw	wa	; F47D2C  push WA
	ld	bc, (14024:16)	; F47D2D  ld BC,(0x36c8)
	sub	a, 16	; F47D31  sub A,0x10
	rcf	; F47D34  rcf
	stcf_a_16	bc	; F47D35  stcf A,BC
	ld	(14024:16), bc	; F47D37  ld (0x36c8),BC
	popw	wa	; F47D3B  pop WA
sub_F47C7C_Join2:
	set	1, (0x3731:16)	; F47D3C  set 1,(0x3731)
	jrl	sub_F47C7C_Join9	; F47D40  jrl T,0xf47f36
sub_F47C7C_Join3:
	ld	wa, (BStore_CursorBlock:16)	; F47D43  ld WA,(0x345c)
	ld	(13460:16), wa	; F47D47  ld (0x3494),WA
	ld	wa, (BStore_CursorOffset:16)	; F47D4B  ld WA,(0x345e)
	ld	(13462:16), wa	; F47D4F  ld (0x3496),WA
	calr	BStore_StepCursorToNextLeadByte	; F47D53  calr 0xf48107
	pushw	wa	; F47D56  push WA
	ld	a, e	; F47D57  ld A,E
	inc	1, a	; F47D59  inc 1,A
	ld	(14064:16), a	; F47D5B  ld (0x36f0),A
	popw	wa	; F47D5F  pop WA
	ld	(14140:16), de	; F47D60  ld (0x373c),DE
	ld	xiy, MIDI_UART_Configure_Data	; F47D64  ld XIY,0x00fffff8
	cp	(xiy), 0x10	; F47D69  cp (XIY),0x10
	jr	c, sub_F47C7C_Skip5	; F47D6C  jr C,0xf47d71
	calr	sub_F4812F	; F47D6E  calr 0xf4812f
sub_F47C7C_Skip5:
	cp	de, 18	; F47D71  cp DE,0x0012
	jr	c, sub_F47C7C_Skip9	; F47D75  jr C,0xf47dd3
	ld	c, (13471:16)	; F47D77  ld C,(0x349f)
	cp	c, 16	; F47D7B  cp C,0x10
	jr	nc, sub_F47C7C_Skip6	; F47D7E  jr NC,0xf47d8e
	ld	iz, (6304798:24)	; F47D80  ld IZ,(0x60341e)
	ld	a, c	; F47D85  ld A,C
	scf	; F47D87  scf
	xorcf_a_16	iz	; F47D88  xorcf A,IZ
	jr	nc, sub_F47C7C_Skip8	; F47D8A  jr NC,0xf47dc4
	jr	sub_F47C7C_Join4	; F47D8C  jr T,0xf47d9d
sub_F47C7C_Skip6:
	ld	iz, (6304800:24)	; F47D8E  ld IZ,(0x603420)
	ld	a, c	; F47D93  ld A,C
	sub	a, 16	; F47D95  sub A,0x10
	scf	; F47D98  scf
	xorcf_a_16	iz	; F47D99  xorcf A,IZ
	jr	nc, sub_F47C7C_Skip8	; F47D9B  jr NC,0xf47dc4
sub_F47C7C_Join4:
	cp	c, 16	; F47D9D  cp C,0x10
	jr	nc, sub_F47C7C_Skip7	; F47DA0  jr NC,0xf47db1
	ld	iz, (12296:16)	; F47DA2  ld IZ,(0x3008)
	ld	a, c	; F47DA6  ld A,C
	rcf	; F47DA8  rcf
	stcf_a_16	iz	; F47DA9  stcf A,IZ
	ld	(12296:16), iz	; F47DAB  ld (0x3008),IZ
	jr	sub_F47C7C_Join5	; F47DAF  jr T,0xf47dc1
sub_F47C7C_Skip7:
	ld	iz, (12298:16)	; F47DB1  ld IZ,(0x300a)
	ld	a, c	; F47DB5  ld A,C
	sub	a, 16	; F47DB7  sub A,0x10
	rcf	; F47DBA  rcf
	stcf_a_16	iz	; F47DBB  stcf A,IZ
	ld	(12298:16), iz	; F47DBD  ld (0x300a),IZ
sub_F47C7C_Join5:
	jrl	sub_F47C7C_Return	; F47DC1  jrl T,0xf47f3d
sub_F47C7C_Skip8:
	call	T_Seq_StopAll_Veneer	; F47DC4  call 0xf40a7c
	call	T_UiStatus_ShowMessage0E	; F47DC8  call 0xf40a5c
	call	T_SeqRecord_SoundAlert_Veneer	; F47DCC  call 0xf40bc8
	jrl	sub_F47C7C_Return	; F47DD0  jrl T,0xf47f3d
sub_F47C7C_Skip9:
	pushw	de	; F47DD3  push DE
	popw	de	; F47DD4  pop DE
	ld	a, (13470:16)	; F47DD5  ld A,(0x349e)
	cp	a, 129	; F47DD9  cp A,0x81
	jr	z, sub_F47C7C_Join6	; F47DDC  jr Z,0xf47e04
	ld	c, (13471:16)	; F47DDE  ld C,(0x349f)
	cp	c, 16	; F47DE2  cp C,0x10
	jr	nc, sub_F47C7C_Skip10	; F47DE5  jr NC,0xf47df5
	ld	iz, (6304798:24)	; F47DE7  ld IZ,(0x60341e)
	ld	a, c	; F47DEC  ld A,C
	scf	; F47DEE  scf
	xorcf_a_16	iz	; F47DEF  xorcf A,IZ
	jr	nc, sub_F47C7C_Skip11	; F47DF1  jr NC,0xf47e07
	jr	sub_F47C7C_Join6	; F47DF3  jr T,0xf47e04
sub_F47C7C_Skip10:
	ld	iz, (6304800:24)	; F47DF5  ld IZ,(0x603420)
	ld	a, c	; F47DFA  ld A,C
	sub	a, 16	; F47DFC  sub A,0x10
	scf	; F47DFF  scf
	xorcf_a_16	iz	; F47E00  xorcf A,IZ
	jr	nc, sub_F47C7C_Skip11	; F47E02  jr NC,0xf47e07
sub_F47C7C_Join6:
	jrl	sub_F47C7C_Join	; F47E04  jrl T,0xf47c88
sub_F47C7C_Skip11:
	call	T_BStore_WriteCursorByte_Join6_Veneer	; F47E07  call 0xf40c6c
	bit	2, (0x34d1:16)	; F47E0B  bit 2,(0x34d1)
	jr	z, sub_F47C7C_Skip12	; F47E0F  jr Z,0xf47e24
	ld	wa, (13460:16)	; F47E11  ld WA,(0x3494)
	ld	(BStore_CursorBlock:16), wa	; F47E15  ld (0x345c),WA
	ld	wa, (13462:16)	; F47E19  ld WA,(0x3496)
	ld	(BStore_CursorOffset:16), wa	; F47E1D  ld (0x345e),WA
	jrl	sub_F47C7C_Join9	; F47E21  jrl T,0xf47f36
sub_F47C7C_Skip12:
	calr	CycleRecord_CheckIsRecordTrack_Copy	; F47E24  calr 0xf47f69
	cp	a, 0:i3	; F47E27  cp A,0
	jr	nz, sub_F47C7C_Skip13	; F47E29  jr NZ,0xf47e4b
	ld	a, (13470:16)	; F47E2B  ld A,(0x349e)
	cp	a, 130	; F47E2F  cp A,0x82
	jr	z, sub_F47C7C_Skip13	; F47E32  jr Z,0xf47e4b
	ld	(14056:16), a	; F47E34  ld (0x36e8),A
	ldw	bc, 5	; F47E38  ld BC,0x0005
	ld	xde, 14057	; F47E3B  ld XDE,0x000036e9
	ld	xhl, 13476	; F47E40  ld XHL,0x000034a4
	ldir83	; F47E45  ldir
	call	T_F40BE8	; F47E47  call 0xf40be8
sub_F47C7C_Skip13:
	ld	de, (14140:16)	; F47E4B  ld DE,(0x373c)
	addw	(0x33e2:16), 0x0007	; F47E4F  add (0x33e2),0x0007
	ld	a, (13470:16)	; F47E55  ld A,(0x349e)
	ld	c, a	; F47E59  ld C,A
	and	c, 240	; F47E5B  and C,0xf0
	cp	c, 144	; F47E5E  cp C,0x90
	jr	z, sub_F47C7C_Skip16	; F47E61  jr Z,0xf47eaf
	cp	a, 210	; F47E63  cp A,0xd2
	jr	z, sub_F47C7C_Skip20	; F47E66  jr Z,0xf47ec7
	cp	a, 211	; F47E68  cp A,0xd3
	jr	z, sub_F47C7C_Skip22	; F47E6B  jr Z,0xf47ed3
	cp	a, 209	; F47E6D  cp A,0xd1
	jr	z, sub_F47C7C_Skip21	; F47E70  jr Z,0xf47ecd
	cp	a, 208	; F47E72  cp A,0xd0
	jr	z, sub_F47C7C_Skip21	; F47E75  jr Z,0xf47ecd
	cp	c, 176	; F47E77  cp C,0xb0
	jr	z, sub_F47C7C_Skip18	; F47E7A  jr Z,0xf47ebb
	cp	c, 192	; F47E7C  cp C,0xc0
	jr	z, sub_F47C7C_Skip17	; F47E7F  jr Z,0xf47eb5
	cp	a, 128	; F47E81  cp A,0x80
	jr	z, sub_F47C7C_Skip19	; F47E84  jr Z,0xf47ec1
	cp	a, 135	; F47E86  cp A,0x87
	jr	z, sub_F47C7C_Skip14	; F47E89  jr Z,0xf47e8e
	jrl	sub_F47C7C_Join	; F47E8B  jrl T,0xf47c88
sub_F47C7C_Skip14:
	ld	a, (13477:16)	; F47E8E  ld A,(0x34a5)
	ld	(14164:16), a	; F47E92  ld (0x3754),A
	or	(0x3754:16), 0x80	; F47E96  or (0x3754),0x80
	bit	4, (0x34d0:16)	; F47E9B  bit 4,(0x34d0)
	jr	z, sub_F47C7C_Skip15	; F47E9F  jr Z,0xf47eac
	cp	(0x34a4:16), 0x00	; F47EA1  cp (0x34a4),0x00
	jr	nz, sub_F47C7C_Skip15	; F47EA6  jr NZ,0xf47eac
	call	T_F40AC0	; F47EA8  call 0xf40ac0
sub_F47C7C_Skip15:
	jrl	sub_F47C7C_Join	; F47EAC  jrl T,0xf47c88
sub_F47C7C_Skip16:
	calr	sub_F481B5	; F47EAF  calr 0xf481b5
	jrl	sub_F47C7C_Join	; F47EB2  jrl T,0xf47c88
sub_F47C7C_Skip17:
	calr	sub_F482AC	; F47EB5  calr 0xf482ac
	jrl	sub_F47C7C_Join	; F47EB8  jrl T,0xf47c88
sub_F47C7C_Skip18:
	calr	sub_F482B0	; F47EBB  calr 0xf482b0
	jrl	sub_F47C7C_Join	; F47EBE  jrl T,0xf47c88
sub_F47C7C_Skip19:
	calr	sub_F482C0	; F47EC1  calr 0xf482c0
	jrl	sub_F47C7C_Join	; F47EC4  jrl T,0xf47c88
sub_F47C7C_Skip20:
	calr	sub_F48309	; F47EC7  calr 0xf48309
	jrl	sub_F47C7C_Join	; F47ECA  jrl T,0xf47c88
sub_F47C7C_Skip21:
	calr	sub_F48309	; F47ECD  calr 0xf48309
	jrl	sub_F47C7C_Join	; F47ED0  jrl T,0xf47c88
sub_F47C7C_Skip22:
	bit	4, (0x34d0:16)	; F47ED3  bit 4,(0x34d0)
	jr	z, sub_F47C7C_Skip23	; F47ED7  jr Z,0xf47ee5
	cp	(0x34a4:16), 0x00	; F47ED9  cp (0x34a4),0x00
	jr	nz, sub_F47C7C_Skip23	; F47EDE  jr NZ,0xf47ee5
	or	(0x34d1:16), 0x40	; F47EE0  or (0x34d1),0x40
sub_F47C7C_Skip23:
	calr	sub_F48309	; F47EE5  calr 0xf48309
	jrl	sub_F47C7C_Join	; F47EE8  jrl T,0xf47c88
sub_F47C7C_Join7:
	call	CycleRecord_CheckIsRecordTrack_Copy	; F47EEB  call 0xf47f69
	cp	a, 0:i3	; F47EEF  cp A,0
	jr	nz, sub_F47C7C_Skip25	; F47EF1  jr NZ,0xf47f27
	call	T_F40BEC	; F47EF3  call 0xf40bec
	calr	sub_F47F3E	; F47EF7  calr 0xf47f3e
	ld	a, (13471:16)	; F47EFA  ld A,(0x349f)
	cp	a, 16	; F47EFE  cp A,0x10
	jr	nc, sub_F47C7C_Skip24	; F47F01  jr NC,0xf47f10
	ld	bc, (14022:16)	; F47F03  ld BC,(0x36c6)
	rcf	; F47F07  rcf
	stcf_a_16	bc	; F47F08  stcf A,BC
	ld	(14022:16), bc	; F47F0A  ld (0x36c6),BC
	jr	sub_F47C7C_Join8	; F47F0E  jr T,0xf47f20
sub_F47C7C_Skip24:
	pushw	wa	; F47F10  push WA
	ld	bc, (14024:16)	; F47F11  ld BC,(0x36c8)
	sub	a, 16	; F47F15  sub A,0x10
	rcf	; F47F18  rcf
	stcf_a_16	bc	; F47F19  stcf A,BC
	ld	(14024:16), bc	; F47F1B  ld (0x36c8),BC
	popw	wa	; F47F1F  pop WA
sub_F47C7C_Join8:
	call	T_F40ABC	; F47F20  call 0xf40abc
	jrl	sub_F47C7C_Join	; F47F24  jrl T,0xf47c88
sub_F47C7C_Skip25:
	call	T_BStore_WriteCursorByte_Join6_Veneer	; F47F27  call 0xf40c6c
	bit	2, (0x34d1:16)	; F47F2B  bit 2,(0x34d1)
	jr	nz, sub_F47C7C_Join9	; F47F2F  jr NZ,0xf47f36
	calr	sub_F48358	; F47F31  calr 0xf48358
	jr	sub_F47C7C_Join9	; F47F34  jr T,0xf47f36
sub_F47C7C_Join9:
	ld	c, (13471:16)	; F47F36  ld C,(0x349f)
	calr	SeqTrackCursors_SaveTrack	; F47F3A  calr 0xf483b2
sub_F47C7C_Return:
	ret	; F47F3D  ret

; --------------------------------------------------------------------------
; sub_F47F3E
; Called from: in-module: 0xF47D13 0xF47EF7
; Touches: (0x349F) (0x3744) (0x3746)  |  0x0033EA 0x003440
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF47F3E is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F47F3E:
	xor	xbc, xbc	; F47F3E  xor XBC,XBC
	ld	c, (13471:16)	; F47F40  ld C,(0x349f)
	ld	xix, 13376	; F47F44  ld XIX,0x00003440
	lda	xix, (xix+bc)	; F47F49  lda XIX,XIX+BC
	ld	a, (xix)	; F47F4E  ld A,(XIX)
	ld	(14150:16), a	; F47F50  ld (0x3746),A
	mul	bc, 2	; F47F54  mul BC,0x0002
	ld	xix, 13290	; F47F58  ld XIX,0x000033ea
	lda	xix, (xix+bc)	; F47F5D  lda XIX,XIX+BC
	ld	wa, (xix)	; F47F62  ld WA,(XIX)
	ld	(14148:16), wa	; F47F64  ld (0x3744),WA
	ret	; F47F68  ret

; --------------------------------------------------------------------------
; CycleRecord_CheckIsRecordTrack_Copy
; Called from: in-module: 0xF47CC6 0xF47E24 0xF47EEB 0xF47FA2
; Touches: (0x207A) (0x3000) (0x349F) (0x360B) (0x36D6)  |  0x000000
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF47F69 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CheckIsRecordTrack_Copy: an exact copy of CycleRecord_CheckIsRecordTrack (prom_b 0xF49A3D) -- all 17 instructions equal, operands included,
;   but the targets of its jr / jrl / djnz (notes/wsa1_exact_copy_names.py).
CycleRecord_CheckIsRecordTrack_Copy:
	xor	a, a	; F47F69  xor A,A
	push	xbc	; F47F6B  push XBC
	ld	xbc, (12288:16)	; F47F6C  ld XBC,(0x3000)
	cp	xbc, 0	; F47F70  cp XBC,0x00000000
	jr	z, CycleRecord_CheckIsRecordTrack_Copy_Skip2	; F47F76  jr Z,0xf47f96
	cp	(UI_ScreenLatch:16), 0x06	; F47F78  cp (0x207a),0x06
	jr	z, CycleRecord_CheckIsRecordTrack_Copy_Skip	; F47F7D  jr Z,0xf47f86
	cp	(UI_ScreenLatch:16), 0x08	; F47F7F  cp (0x207a),0x08
	jr	nz, CycleRecord_CheckIsRecordTrack_Copy_Skip2	; F47F84  jr NZ,0xf47f96
CycleRecord_CheckIsRecordTrack_Copy_Skip:
	ld	b, (13471:16)	; F47F86  ld B,(0x349f)
	cp	b, (0x36d6:16)	; F47F8A  cp B,(0x36d6)
	jr	nz, CycleRecord_CheckIsRecordTrack_Copy_Skip2	; F47F8E  jr NZ,0xf47f96
	bit	1, (0x360b:16)	; F47F90  bit 1,(0x360b)
	jr	nz, CycleRecord_CheckIsRecordTrack_Copy_Epilogue	; F47F94  jr NZ,0xf47f98
CycleRecord_CheckIsRecordTrack_Copy_Skip2:
	ld	a, 255:opc	; F47F96  ld A,0xff
CycleRecord_CheckIsRecordTrack_Copy_Epilogue:
	pop	xbc	; F47F98  pop XBC
	ret	; F47F99  ret

; --------------------------------------------------------------------------
; sub_F47F9A
; Called from: T_F40B78 (x0); in-module: 0xF4795D
; Touches: (0x349F) (0x36D6)  |  0x003460 0x003482
; Calls:   CycleRecord_CheckIsRecordTrack_Copy sub_F47FE0
; Evidence: thunk slot T_F40B78 holds `jp 0x00F47F9A`, and 0xF47F9A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F47F9A:		; <- T_F40B78
	ld	a, (14038:16)	; F47F9A  ld A,(0x36d6)
	ld	(13471:16), a	; F47F9E  ld (0x349f),A
	call	CycleRecord_CheckIsRecordTrack_Copy	; F47FA2  call 0xf47f69
	cp	a, 0:i3	; F47FA6  cp A,0
	jr	z, sub_F47F9A_Skip	; F47FA8  jr Z,0xf47faf
	calr	sub_F47FE0	; F47FAA  calr 0xf47fe0
	jr	sub_F47F9A_Return	; F47FAD  jr T,0xf47fdf
sub_F47F9A_Skip:
	ld	xix, 13408	; F47FAF  ld XIX,0x00003460
	xor	xwa, xwa	; F47FB4  xor XWA,XWA
	ld	a, (14038:16)	; F47FB6  ld A,(0x36d6)
	sll	xwa, 1	; F47FBA  sll 0x01,XWA
	add	xix, xwa	; F47FBD  add XIX,XWA
	ld	wa, (xix)	; F47FBF  ld WA,(XIX)
	pushw	wa	; F47FC1  push WA
	push	xix	; F47FC2  push XIX
	ld	xiy, 13442	; F47FC3  ld XIY,0x00003482
	xor	xwa, xwa	; F47FC8  xor XWA,XWA
	ld	a, (14038:16)	; F47FCA  ld A,(0x36d6)
	add	xiy, xwa	; F47FCE  add XIY,XWA
	ld	c, (xiy)	; F47FD0  ld C,(XIY)
	pushw	bc	; F47FD2  push BC
	push	xiy	; F47FD3  push XIY
	calr	sub_F47FE0	; F47FD4  calr 0xf47fe0
	pop	xiy	; F47FD7  pop XIY
	popw	bc	; F47FD8  pop BC
	ld	(xiy), c	; F47FD9  ld (XIY),C
	pop	xix	; F47FDB  pop XIX
	popw	wa	; F47FDC  pop WA
	ld	(xix), wa	; F47FDD  ld (XIX),WA
sub_F47F9A_Return:
	ret	; F47FDF  ret

; --------------------------------------------------------------------------
; sub_F47FE0
; Called from: in-module: 0xF47FAA 0xF47FD4
; Touches: (0x3744) (0x3746)  |  0x0033EA 0x003440 0x003460 0x003482
;          0x00362A 0x00364C
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF47FE0 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F47FE0:
	ldw	bc, 17	; F47FE0  ld BC,0x0011
	ld	xde, 13408	; F47FE3  ld XDE,0x00003460
	ld	xhl, 13866	; F47FE8  ld XHL,0x0000362a
	ldirw93	; F47FED  ldirw
	ldw	bc, 17	; F47FEF  ld BC,0x0011
	ld	xde, 13442	; F47FF2  ld XDE,0x00003482
	ld	xhl, 13900	; F47FF7  ld XHL,0x0000364c
	ldir83	; F47FFC  ldir
	xor	bc, bc	; F47FFE  xor BC,BC
	ld	xde, 13290	; F48000  ld XDE,0x000033ea
	ld	wa, (14148:16)	; F48005  ld WA,(0x3744)
sub_F47FE0_Loop:
	ld	(xde+), wa	; F48009  ld (XDE+),WA
	inc	1, bc	; F4800C  inc 1,BC
	cp	bc, 17	; F4800E  cp BC,0x0011
	jr	c, sub_F47FE0_Loop	; F48012  jr C,0xf48009
	xor	bc, bc	; F48014  xor BC,BC
	ld	xde, 13376	; F48016  ld XDE,0x00003440
	ld	a, (14150:16)	; F4801B  ld A,(0x3746)
sub_F47FE0_Loop2:
	ld	(xde+), a	; F4801F  ld (XDE+),A
	inc	1, bc	; F48022  inc 1,BC
	cp	bc, 17	; F48024  cp BC,0x0011
	jr	c, sub_F47FE0_Loop2	; F48028  jr C,0xf4801f
	ret	; F4802A  ret

; --------------------------------------------------------------------------
; sub_F4802B
; Called from: in-module: 0xF47C80
; Touches: (0x345C) (0x345E)  |  0x003460 0x003482
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4802B is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4802B:
	xor	wa, wa	; F4802B  xor WA,WA
	ld	a, c	; F4802D  ld A,C
	ld	iy, wa	; F4802F  ld IY,WA
	ld	xhl, 13408	; F48031  ld XHL,0x00003460
	sla	iy, 1	; F48036  sla 0x01,IY
	ld	wa, (xhl+iy)	; F48039  ld WA,(XHL+IY)
	ld	(BStore_CursorBlock:16), wa	; F4803E  ld (0x345c),WA
	ld	xhl, 13442	; F48042  ld XHL,0x00003482
	srl	iy, 1	; F48047  srl 0x01,IY
	xor	wa, wa	; F4804A  xor WA,WA
	ld	a, (xhl+iy)	; F4804C  ld A,(XHL+IY)
	ld	(BStore_CursorOffset:16), wa	; F48051  ld (0x345e),WA
	ret	; F48055  ret

; --------------------------------------------------------------------------
; sub_F48056
; Called from: in-module: 0xF47CB6
; Touches: (0x33E4) (0x3452) (0x3454) (0x3498) (0x349E) (0x349F) (0x34A1)  |
;          0x0033EA 0x003440
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF48056 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F48056:
	cp	(0x349e:16), 0x81	; F48056  cp (0x349e),0x81
	jr	nz, sub_F48056_Skip2	; F4805B  jr NZ,0xf480b9
	ld	xhl, 13376	; F4805D  ld XHL,0x00003440
	xor	wa, wa	; F48062  xor WA,WA
	ld	a, (13471:16)	; F48064  ld A,(0x349f)
	ld	iy, wa	; F48068  ld IY,WA
	cp	(xhl+iy), 0x00	; F4806A  cp (XHL+IY),0x00
	jr	z, sub_F48056_Skip	; F48070  jr Z,0xf48077
	ld	a, 96:opc	; F48072  ld A,0x60
	jrl	sub_F48056_Join2	; F48074  jrl T,0xf480f8
sub_F48056_Skip:
	ld	xhl, 13290	; F48077  ld XHL,0x000033ea
	sla	iy, 1	; F4807C  sla 0x01,IY
	ld	wa, (xhl+iy)	; F4807F  ld WA,(XHL+IY)
	cp	wa, (0x3452:16)	; F48084  cp WA,(0x3452)
	jr	c, sub_F48056_Entry	; F48088  jr C,0xf480a4
	sub	wa, (0x3452:16)	; F4808A  sub WA,(0x3452)
	muls	wa, 96	; F4808E  muls WA,0x0060
	add	wa, 96	; F48092  add WA,0x0060
	xor	bc, bc	; F48096  xor BC,BC
	ld	c, (13396:16)	; F48098  ld C,(0x3454)
	sub	wa, bc	; F4809C  sub WA,BC
	cp	(13473:16), a	; F4809E  cp (0x34a1),A
	jr	c, sub_F48056_Join2	; F480A2  jr C,0xf480f8
sub_F48056_Entry:
	.byte 0xD3, 0x07, 0xEC, 0xF4, 0x61	; F480A4  incw 1,(XHL+IY)   [llvm-mc cannot encode this]
	ld	xhl, 13376	; F480A9  ld XHL,0x00003440
	srl	iy, 1	; F480AE  srl 0x01,IY
	ld	(xhl+iy), 0x01	; F480B1  ld (XHL+IY),0x01
	jr	sub_F48056_Join	; F480B7  jr T,0xf480f4
sub_F48056_Skip2:
	xor	wa, wa	; F480B9  xor WA,WA
	ld	a, (13471:16)	; F480BB  ld A,(0x349f)
	ld	iy, wa	; F480BF  ld IY,WA
	ld	xhl, 13290	; F480C1  ld XHL,0x000033ea
	sla	iy, 1	; F480C6  sla 0x01,IY
	ld	wa, (xhl+iy)	; F480C9  ld WA,(XHL+IY)
	cp	wa, (0x3452:16)	; F480CE  cp WA,(0x3452)
	jr	c, sub_F48056_Join	; F480D2  jr C,0xf480f4
	sub	wa, (0x3452:16)	; F480D4  sub WA,(0x3452)
	muls	wa, 96	; F480D8  muls WA,0x0060
	xor	bc, bc	; F480DC  xor BC,BC
	ld	c, (13464:16)	; F480DE  ld C,(0x3498)
	add	wa, bc	; F480E2  add WA,BC
	ld	c, (13396:16)	; F480E4  ld C,(0x3454)
	cp	wa, bc	; F480E8  cp WA,BC
	jr	c, sub_F48056_Join	; F480EA  jr C,0xf480f4
	sub	wa, bc	; F480EC  sub WA,BC
	cp	(13473:16), a	; F480EE  cp (0x34a1),A
	jr	c, sub_F48056_Join2	; F480F2  jr C,0xf480f8
sub_F48056_Join:
	ld	a, 255:opc	; F480F4  ld A,0xff
	jr	sub_F48056_Return	; F480F6  jr T,0xf48106
sub_F48056_Join2:
	xor	w, w	; F480F8  xor W,W
	cp	(0x33e4:16), wa	; F480FA  cp (0x33e4),WA
	jr	ule, sub_F48056_Skip3	; F480FE  jr ULE,0xf48104
	ld	(13284:16), wa	; F48100  ld (0x33e4),WA
sub_F48056_Skip3:
	xor	wa, wa	; F48104  xor WA,WA
sub_F48056_Return:
	ret	; F48106  ret

; --------------------------------------------------------------------------
; BStore_StepCursorToNextLeadByte
; Called from: T_BStore_StepCursorToNextLeadByte (x1); in-module: 0xF47D53
; Touches:   |  0x0034A4
; Calls:   BStore_StepCursorOneByte_Call BStore_ReadCursorByte_Call
; Evidence: thunk slot T_BStore_StepCursorToNextLeadByte holds `jp 0x00F48107`, and 0xF48107 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_StepCursorToNextLeadByte: From the event at the BStore cursor, steps a byte at a time
;   (T_BStore_StepCursorOneByte, T_BStore_ReadCursorByte) to the next byte with bit 7 set (lead byte or 0x81 / 0x82
;   tag), copying the first 5 bytes passed to 0x34A4[]; DE = bytes passed (gives up at 18). Slot T_BStore_StepCursorToNextLeadByte:
;   CycleRecord_StepCursorOneEvent's step; the playback reader sub_F47C7C stores DE + 1 in (0x36F0). Basis: callers +
;   caller header + body. (notes/naming-pilot-2026-10-06/proposals_wave8_a8.json)
BStore_StepCursorToNextLeadByte:		; <- T_BStore_StepCursorToNextLeadByte
	xor	de, de	; F48107  xor DE,DE
BStore_StepCursorToNextLeadByte_Loop:
	calr	BStore_StepCursorOneByte_Call	; F48109  calr 0xf4842f
	calr	BStore_ReadCursorByte_Call	; F4810C  calr 0xf4840e
	bit	7, a	; F4810F  bit 0x07,A
	jr	z, BStore_StepCursorToNextLeadByte_Skip	; F48112  jr Z,0xf48115
BStore_StepCursorToNextLeadByte_Return:
	ret	; F48114  ret
BStore_StepCursorToNextLeadByte_Skip:
	cp	de, 5:i3	; F48115  cp DE,5
	jr	nc, BStore_StepCursorToNextLeadByte_Skip2	; F48117  jr NC,0xf48125
	ld	xhl, 13476	; F48119  ld XHL,0x000034a4
	ld	iy, de	; F4811E  ld IY,DE
	ld	(xhl+iy), a	; F48120  ld (XHL+IY),A
BStore_StepCursorToNextLeadByte_Skip2:
	inc	1, de	; F48125  inc 1,DE
	cp	de, 18	; F48127  cp DE,0x0012
	jr	c, BStore_StepCursorToNextLeadByte_Loop	; F4812B  jr C,0xf48109
	jr	BStore_StepCursorToNextLeadByte_Return	; F4812D  jr T,0xf48114

; --------------------------------------------------------------------------
; sub_F4812F
; Called from: in-module: 0xF47D6E
; Touches: (0x349E)
; Calls:   T_SeqRecord_SoundAlert_Veneer T_UiStatus_ShowMessage0E
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4812F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F4812F:
	push	xwa	; F4812F  push XWA
	push	xbc	; F48130  push XBC
	push	xde	; F48131  push XDE
	push	xhl	; F48132  push XHL
	push	xix	; F48133  push XIX
	push	xiy	; F48134  push XIY
	push	xiz	; F48135  push XIZ
	inc	1, de	; F48136  inc 1,DE
	ld	a, (13470:16)	; F48138  ld A,(0x349e)
	ld	l, a	; F4813C  ld L,A
	and	l, 240	; F4813E  and L,0xf0
	cp	l, 144	; F48141  cp L,0x90
	jr	z, sub_F4812F_Skip	; F48144  jr Z,0xf4816b
	cp	l, 176	; F48146  cp L,0xb0
	jr	z, sub_F4812F_Skip2	; F48149  jr Z,0xf48171
	cp	l, 192	; F4814B  cp L,0xc0
	jr	z, sub_F4812F_Skip3	; F4814E  jr Z,0xf48177
	cp	a, 210	; F48150  cp A,0xd2
	jr	z, sub_F4812F_Skip5	; F48153  jr Z,0xf48183
	cp	l, 208	; F48155  cp L,0xd0
	jr	z, sub_F4812F_Skip6	; F48158  jr Z,0xf48189
	cp	a, 129	; F4815A  cp A,0x81
	jr	z, sub_F4812F_Skip4	; F4815D  jr Z,0xf4817d
	cp	a, 128	; F4815F  cp A,0x80
	jr	z, sub_F4812F_Skip7	; F48162  jr Z,0xf4818f
	cp	a, 135	; F48164  cp A,0x87
	jr	z, sub_F4812F_Skip8	; F48167  jr Z,0xf48195
	jr	sub_F4812F_Join	; F48169  jr T,0xf4819b
sub_F4812F_Skip:
	cp	e, 6:i3	; F4816B  cp E,6
	jr	z, sub_F4812F_Epilogue	; F4816D  jr Z,0xf481ad
	jr	sub_F4812F_Join2	; F4816F  jr T,0xf481a5
sub_F4812F_Skip2:
	cp	e, 6:i3	; F48171  cp E,6
	jr	z, sub_F4812F_Epilogue	; F48173  jr Z,0xf481ad
	jr	sub_F4812F_Join2	; F48175  jr T,0xf481a5
sub_F4812F_Skip3:
	cp	e, 6:i3	; F48177  cp E,6
	jr	z, sub_F4812F_Epilogue	; F48179  jr Z,0xf481ad
	jr	sub_F4812F_Join2	; F4817B  jr T,0xf481a5
sub_F4812F_Skip4:
	cp	e, 1:i3	; F4817D  cp E,1
	jr	z, sub_F4812F_Epilogue	; F4817F  jr Z,0xf481ad
	jr	sub_F4812F_Join2	; F48181  jr T,0xf481a5
sub_F4812F_Skip5:
	cp	e, 4:i3	; F48183  cp E,4
	jr	z, sub_F4812F_Epilogue	; F48185  jr Z,0xf481ad
	jr	sub_F4812F_Join2	; F48187  jr T,0xf481a5
sub_F4812F_Skip6:
	cp	e, 3:i3	; F48189  cp E,3
	jr	z, sub_F4812F_Epilogue	; F4818B  jr Z,0xf481ad
	jr	sub_F4812F_Join2	; F4818D  jr T,0xf481a5
sub_F4812F_Skip7:
	cp	e, 4:i3	; F4818F  cp E,4
	jr	z, sub_F4812F_Epilogue	; F48191  jr Z,0xf481ad
	jr	sub_F4812F_Join2	; F48193  jr T,0xf481a5
sub_F4812F_Skip8:
	cp	e, 3:i3	; F48195  cp E,3
	jr	z, sub_F4812F_Epilogue	; F48197  jr Z,0xf481ad
	jr	sub_F4812F_Join2	; F48199  jr T,0xf481a5
sub_F4812F_Join:
	call	T_SeqRecord_SoundAlert_Veneer	; F4819B  call 0xf40bc8
	call	T_UiStatus_ShowMessage0E	; F4819F  call 0xf40a5c
	jr	sub_F4812F_Epilogue	; F481A3  jr T,0xf481ad
sub_F4812F_Join2:
	call	T_SeqRecord_SoundAlert_Veneer	; F481A5  call 0xf40bc8
	call	T_UiStatus_ShowMessage0E	; F481A9  call 0xf40a5c
sub_F4812F_Epilogue:
	pop	xiz	; F481AD  pop XIZ
	pop	xiy	; F481AE  pop XIY
	pop	xix	; F481AF  pop XIX
	pop	xhl	; F481B0  pop XHL
	pop	xde	; F481B1  pop XDE
	pop	xbc	; F481B2  pop XBC
	pop	xwa	; F481B3  pop XWA
	ret	; F481B4  ret

; --------------------------------------------------------------------------
; sub_F481B5
; Called from: in-module: 0xF47EAF
; Touches: (0x33DA) (0x33DB) (0x33DE) (0x33DF) (0x33E0) (0x349E) (0x349F)
;          (0x34A0) (0x34A5) (0x34A6) +2 more  |  0x003015 0x003038
; Calls:   sub_F47A5D sub_F48318 T_TimedEventRing_Put sub_F47A41
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF481B5 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F481B5:
	xor	xix, xix	; F481B5  xor XIX,XIX
	ld	xix, 12309	; F481B7  ld XIX,0x00003015
	cp	(xix), 0xff	; F481BC  cp (XIX),0xff
	jrl	z, sub_F481B5_Return	; F481BF  jrl Z,0xf482ab
	xor	hl, hl	; F481C2  xor HL,HL
	ld	l, (xix)	; F481C4  ld L,(XIX)
	ld	(13279:16), l	; F481C6  ld (0x33df),L
	calr	sub_F47A5D	; F481CA  calr 0xf47a5d
	ld	a, (13477:16)	; F481CD  ld A,(0x34a5)
	ld	(xhl), a	; F481D1  ld (XHL),A
	ld	a, 96:opc	; F481D3  ld A,0x60
	mul	wa, (0x34a8:16)	; F481D5  mul WA,(0x34a8)
	xor	de, de	; F481D9  xor DE,DE
	ld	e, (13479:16)	; F481DB  ld E,(0x34a7)
	add	e, (13472:16)	; F481DF  add E,(0x34a0)
	add	wa, de	; F481E3  add WA,DE
	ld	de, wa	; F481E5  ld DE,WA
	cp	de, (0x33e0:16)	; F481E7  cp DE,(0x33e0)
	jr	nc, sub_F481B5_Skip	; F481EB  jr NC,0xf481f1
	ld	(13280:16), de	; F481ED  ld (0x33e0),DE
sub_F481B5_Skip:
	ld	(xhl+1), e	; F481F1  ld (XHL+0x01),E
	ld	(xhl+2), d	; F481F4  ld (XHL+0x02),D
	ld	a, (13470:16)	; F481F7  ld A,(0x349e)
	ld	(xhl+3), a	; F481FB  ld (XHL+0x03),A
	push	xhl	; F481FE  push XHL
	ldw	de, 2	; F481FF  ld DE,0x0002
	calr	sub_F48318	; F48202  calr 0xf48318
	ld	a, (13478:16)	; F48205  ld A,(0x34a6)
	pop	xhl	; F48209  pop XHL
	pushw	wa	; F4820A  push WA
	call	T_TimedEventRing_Put	; F4820B  call 0xf41d64
	inc	2, xsp	; F4820F  inc 2,XSP
	ld	a, (13471:16)	; F48211  ld A,(0x349f)
	pushw	wa	; F48215  push WA
	call	T_TimedEventRing_Put	; F48216  call 0xf41d64
	inc	2, xsp	; F4821A  inc 2,XSP
	calr	sub_F47A41	; F4821C  calr 0xf47a41
	ld	a, (13275:16)	; F4821F  ld A,(0x33db)
	ld	(xhl+4), a	; F48223  ld (XHL+0x04),A
	ld	a, (xhl+5)	; F48226  ld A,(XHL+0x05)
	ld	(13278:16), a	; F48229  ld (0x33de),A
	ld	(xhl+5), 255	; F4822D  ld (XHL+0x05),0xff
	cp	(0x33da:16), 0x00	; F48231  cp (0x33da),0x00
	jr	nz, sub_F481B5_Skip2	; F48236  jr NZ,0xf48253
	xor	iy, iy	; F48238  xor IY,IY
	xor	wa, wa	; F4823A  xor WA,WA
	ld	a, (13471:16)	; F4823C  ld A,(0x349f)
	ld	iy, wa	; F48240  ld IY,WA
	sla	iy, 1	; F48242  sla 0x01,IY
	ld	xhl, 12344	; F48245  ld XHL,0x00003038
	ld	a, (13279:16)	; F4824A  ld A,(0x33df)
	ld	(xhl+iy), a	; F4824E  ld (XHL+IY),A
sub_F481B5_Skip2:
	cp	(0x33db:16), 0x00	; F48253  cp (0x33db),0x00
	jr	z, sub_F481B5_Skip3	; F48258  jr Z,0xf4826a
	xor	hl, hl	; F4825A  xor HL,HL
	ld	l, (13275:16)	; F4825C  ld L,(0x33db)
	calr	sub_F47A5D	; F48260  calr 0xf47a5d
	ld	a, (13279:16)	; F48263  ld A,(0x33df)
	ld	(xhl+5), a	; F48267  ld (XHL+0x05),A
sub_F481B5_Skip3:
	xor	iy, iy	; F4826A  xor IY,IY
	xor	wa, wa	; F4826C  xor WA,WA
	ld	a, (13471:16)	; F4826E  ld A,(0x349f)
	ld	iy, wa	; F48272  ld IY,WA
	sla	iy, 1	; F48274  sla 0x01,IY
	ld	xhl, 12344	; F48277  ld XHL,0x00003038
	ld	a, (13279:16)	; F4827C  ld A,(0x33df)
	ld	xiz, xhl	; F48280  ld XIZ,XHL
	lda	xiz, (xiz+iy)	; F48282  lda XIZ,XIZ+IY
	ld	(xiz+1), a	; F48287  ld (XIZ+0x01),A
	xor	xix, xix	; F4828A  xor XIX,XIX
	ld	xix, 12309	; F4828C  ld XIX,0x00003015
	ld	a, (13278:16)	; F48291  ld A,(0x33de)
	ld	(xix), a	; F48295  ld (XIX),A
	cp	(0x33de:16), 0xff	; F48297  cp (0x33de),0xff
	jr	z, sub_F481B5_Return	; F4829C  jr Z,0xf482ab
	xor	hl, hl	; F4829E  xor HL,HL
	ld	l, (13278:16)	; F482A0  ld L,(0x33de)
	calr	sub_F47A5D	; F482A4  calr 0xf47a5d
	ld	(xhl+4), 0	; F482A7  ld (XHL+0x04),0x00
sub_F481B5_Return:
	ret	; F482AB  ret

; --------------------------------------------------------------------------
; sub_F482AC
; Called from: in-module: 0xF47EB5
; Touches: nothing with an absolute address
; Calls:   sub_F48309
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF482AC is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F482AC:
	calr	sub_F48309	; F482AC  calr 0xf48309
	ret	; F482AF  ret

; --------------------------------------------------------------------------
; sub_F482B0
; Called from: in-module: 0xF47EBB
; Touches: (0x34A5)
; Calls:   sub_F48309
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF482B0 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F482B0:
	cp	(0x34a5:16), 0x48	; F482B0  cp (0x34a5),0x48
	jr	z, sub_F482B0_Skip	; F482B5  jr Z,0xf482bc
	calr	sub_F48309	; F482B7  calr 0xf48309
	jr	sub_F482B0_Return	; F482BA  jr T,0xf482bf
sub_F482B0_Skip:
	calr	sub_F48309	; F482BC  calr 0xf48309
sub_F482B0_Return:
	ret	; F482BF  ret

; --------------------------------------------------------------------------
; sub_F482C0
; Called from: in-module: 0xF47EC1
; Touches: (0x349F) (0x34A4) (0x34A5) (0x34D0) (0x7EE2)  |  0x603422
; Calls:   T_Queue2E00_AppendRegs T_Tempo_ApplyBpm sub_F48309
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF482C0 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F482C0:
	ld	l, (13471:16)	; F482C0  ld L,(0x349f)
	xor	h, h	; F482C4  xor H,H
	ld	xiy, BStore_TrackToPart	; F482C6  ld XIY,0x00603422
	ld	a, (xiy+hl)	; F482CB  ld A,(XIY+HL)
	cp	a, 32	; F482D0  cp A,0x20
	jr	nz, sub_F482C0_Skip	; F482D3  jr NZ,0xf48305
	bit	4, (0x34d0:16)	; F482D5  bit 4,(0x34d0)
	jr	z, sub_F482C0_Skip	; F482D9  jr Z,0xf48305
	cp	(0x34a4:16), 0x00	; F482DB  cp (0x34a4),0x00
	jr	nz, sub_F482C0_Skip	; F482E0  jr NZ,0xf48305
	ld	wa, (13477:16)	; F482E2  ld WA,(0x34a5)
	sla	a, 1	; F482E6  sla 0x01,A
	srl	wa, 1	; F482E9  srl 0x01,WA
	and	w, 1	; F482EC  and W,0x01
	pushw	wa	; F482EF  push WA
	ld	e, 122:opc	; F482F0  ld E,0x7a
	ld	d, 0:opc	; F482F2  ld D,0x00
	ld	w, 255:opc	; F482F4  ld W,0xff
	call	T_Queue2E00_AppendRegs	; F482F6  call 0xf40f3c
	popw	wa	; F482FA  pop WA
	ld	(32482:16), wa	; F482FB  ld (0x7ee2),WA
	call	T_Tempo_ApplyBpm	; F482FF  call 0xf40794
	jr	sub_F482C0_Return	; F48303  jr T,0xf48308
sub_F482C0_Skip:
	calr	sub_F48309	; F48305  calr 0xf48309
sub_F482C0_Return:
	ret	; F48308  ret

; --------------------------------------------------------------------------
; sub_F48309
; Called from: in-module: 0xF47EC7 0xF47ECD 0xF47EE5 0xF482AC 0xF482B7
;              0xF482BC 0xF48305
; Touches: (0x349F)
; Calls:   sub_F48318 T_TimedEventRing_Put
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF48309 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F48309:
	calr	sub_F48318	; F48309  calr 0xf48318
	ld	a, (13471:16)	; F4830C  ld A,(0x349f)
	pushw	wa	; F48310  push WA
	call	T_TimedEventRing_Put	; F48311  call 0xf41d64
	inc	2, xsp	; F48315  inc 2,XSP
	ret	; F48317  ret

; --------------------------------------------------------------------------
; sub_F48318
; Called from: in-module: 0xF48202 0xF48309
; Touches: (0x3454) (0x349E) (0x34A0)  |  0x0034A5
; Calls:   T_TimedEventRing_Put
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF48318 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F48318:
	ld	a, (13470:16)	; F48318  ld A,(0x349e)
	pushw	wa	; F4831C  push WA
	call	T_TimedEventRing_Put	; F4831D  call 0xf41d64
	inc	2, xsp	; F48321  inc 2,XSP
	ld	a, (13472:16)	; F48323  ld A,(0x34a0)
	add	a, (13396:16)	; F48327  add A,(0x3454)
	cp	a, 96	; F4832B  cp A,0x60
	jr	c, sub_F48318_Skip	; F4832E  jr C,0xf48333
	sub	a, 96	; F48330  sub A,0x60
sub_F48318_Skip:
	pushw	wa	; F48333  push WA
	call	T_TimedEventRing_Put	; F48334  call 0xf41d64
	inc	2, xsp	; F48338  inc 2,XSP
	xor	ix, ix	; F4833A  xor IX,IX
sub_F48318_Join:
	cp	de, 2:i3	; F4833C  cp DE,2
	jr	nc, sub_F48318_Skip2	; F4833E  jr NC,0xf48341
	ret	; F48340  ret
sub_F48318_Skip2:
	ld	xhl, 13477	; F48341  ld XHL,0x000034a5
	ld	a, (xhl+ix)	; F48346  ld A,(XHL+IX)
	inc	1, ix	; F4834B  inc 1,IX
	pushw	wa	; F4834D  push WA
	call	T_TimedEventRing_Put	; F4834E  call 0xf41d64
	inc	2, xsp	; F48352  inc 2,XSP
	dec	1, de	; F48354  dec 1,DE
	jr	sub_F48318_Join	; F48356  jr T,0xf4833c

; --------------------------------------------------------------------------
; sub_F48358
; Called from: in-module: 0xF47F31
; Touches: (0x3454) (0x349F) (0x34A0) (0x36C6) (0x36C8)
; Calls:   T_TimedEventRing_Put T_SeqCycle_CheckOn
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF48358 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F48358:
	ld	a, 130:opc	; F48358  ld A,0x82
	pushw	wa	; F4835A  push WA
	call	T_TimedEventRing_Put	; F4835B  call 0xf41d64
	inc	2, xsp	; F4835F  inc 2,XSP
	ld	a, (13472:16)	; F48361  ld A,(0x34a0)
	add	a, (13396:16)	; F48365  add A,(0x3454)
	cp	a, 96	; F48369  cp A,0x60
	jr	c, sub_F48358_Skip	; F4836C  jr C,0xf48371
	sub	a, 96	; F4836E  sub A,0x60
sub_F48358_Skip:
	pushw	wa	; F48371  push WA
	call	T_TimedEventRing_Put	; F48372  call 0xf41d64
	inc	2, xsp	; F48376  inc 2,XSP
	ld	a, (13471:16)	; F48378  ld A,(0x349f)
	pushw	wa	; F4837C  push WA
	call	T_TimedEventRing_Put	; F4837D  call 0xf41d64
	inc	2, xsp	; F48381  inc 2,XSP
	call	T_SeqCycle_CheckOn	; F48383  call 0xf40aa4
	cp	a, 0:i3	; F48387  cp A,0
	jr	nz, sub_F48358_Return	; F48389  jr NZ,0xf483b1
	ld	a, (13471:16)	; F4838B  ld A,(0x349f)
	cp	a, 16	; F4838F  cp A,0x10
	jr	nc, sub_F48358_Skip2	; F48392  jr NC,0xf483a1
	ld	bc, (14022:16)	; F48394  ld BC,(0x36c6)
	rcf	; F48398  rcf
	stcf_a_16	bc	; F48399  stcf A,BC
	ld	(14022:16), bc	; F4839B  ld (0x36c6),BC
	jr	sub_F48358_Return	; F4839F  jr T,0xf483b1
sub_F48358_Skip2:
	pushw	wa	; F483A1  push WA
	ld	bc, (14024:16)	; F483A2  ld BC,(0x36c8)
	sub	a, 16	; F483A6  sub A,0x10
	rcf	; F483A9  rcf
	stcf_a_16	bc	; F483AA  stcf A,BC
	ld	(14024:16), bc	; F483AC  ld (0x36c8),BC
	popw	wa	; F483B0  pop WA
sub_F48358_Return:
	ret	; F483B1  ret

; --------------------------------------------------------------------------
; SeqTrackCursors_SaveTrack
; Called from: T_SeqTrackCursors_SaveTrack (x3); in-module: 0xF47F3A
; Touches: (0x345C) (0x345E) (0x3604)  |  0x003460 0x003482 0x603500
; Evidence: thunk slot T_SeqTrackCursors_SaveTrack holds `jp 0x00F483B2`, and 0xF483B2 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrackCursors_SaveTrack: Track C's saved cursor := the block-store cursor: word 0x3460[C] := BStore_CursorBlock,
;   byte 0x3482[C] := BStore_CursorOffset (TrackCursor_Save's twin, indexed by C instead of IY). Its three directory
;   callers pass C = (0x349F), the track the locate loop just sought with BStore_SeekChainToMeasure. Basis: callers +
;   body + twin. (notes/naming-pilot-2026-10-06/proposals_wave4_l.json)
SeqTrackCursors_SaveTrack:		; <- T_SeqTrackCursors_SaveTrack
	xor	wa, wa	; F483B2  xor WA,WA
	ld	a, c	; F483B4  ld A,C
	ld	iy, wa	; F483B6  ld IY,WA
	ld	xhl, 13408	; F483B8  ld XHL,0x00003460
	sla	iy, 1	; F483BD  sla 0x01,IY
	ld	wa, (BStore_CursorBlock:16)	; F483C0  ld WA,(0x345c)
	ld	(xhl+iy), wa	; F483C4  ld (XHL+IY),WA
	ld	xhl, 13442	; F483C9  ld XHL,0x00003482
	ld	wa, (BStore_CursorOffset:16)	; F483CE  ld WA,(0x345e)
	srl	iy, 1	; F483D2  srl 0x01,IY
	ld	(xhl+iy), a	; F483D5  ld (XHL+IY),A
	ret	; F483DA  ret
	push	xix	; F483DB  push XIX
	ld	qhl, 0	; F483DC  ld QHL,0
	ld	hl, (BStore_CursorBlock:16)	; F483DF  ld HL,(0x345c)
	dec	1, xhl	; F483E3  dec 1,XHL
	sla	xhl, 8	; F483E5  sla 0x08,XHL
	ld	xix, (BStore_HeapBase:16)	; F483E8  ld XIX,(0x3604)
	lda	xwa, (xix+0:8)	; F483EC  lda XWA,XIX+0x00
	add	xhl, xwa	; F483EF  add XHL,XWA
	ld	iy, (BStore_CursorOffset:16)	; F483F1  ld IY,(0x345e)
	ld	a, (xhl+iy)	; F483F5  ld A,(XHL+IY)
	pop	xix	; F483FA  pop XIX
	ret	; F483FB  ret
SeqTrackCursors_SaveTrack_Join:
	ld	xhl, 6305024	; F483FC  ld XHL,0x00603500
	ld	xiz, xhl	; F48401  ld XIZ,XHL
	lda	xiz, (xiz+iy)	; F48403  lda XIZ,XIZ+IY
	ld	wa, (xiz+1)	; F48408  ld WA,(XIZ+0x01)
	jr	SeqTrackCursors_SaveTrack_Return	; F4840B  jr T,0xf4840d
SeqTrackCursors_SaveTrack_Return:
	ret	; F4840D  ret

; --------------------------------------------------------------------------
; BStore_ReadCursorByte_Call
; Called from: in-module: 0xF47C88 0xF47CA7 0xF4810C
; Touches: (0x345C) (0x345E)
; Calls:   T_BStore_ReadCursorByte BStore_StepCursorOneByte_Call_Nop
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4840E is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ReadCursorByte_Call: `call T_BStore_ReadCursorByte` / `jr` / `ret`: A = the byte at the block-store cursor.
;   The bytes after its ret (0xF48415-0xF4842E) are an unreached inline version of the same read.
;   BStore_StepCursorToNextLeadByte reads each byte with it. Basis: caller header + body (wrapper). (notes/naming-
;   pilot-2026-10-06/proposals_wave9_d9.json)
BStore_ReadCursorByte_Call:
	call	T_BStore_ReadCursorByte	; F4840E  call 0xf40c54
	jr	BStore_ReadCursorByte_Call_Return	; F48412  jr T,0xf48414
BStore_ReadCursorByte_Call_Return:
	ret	; F48414  ret
	calr	BStore_StepCursorOneByte_Call_Nop	; F48415  calr 0xf48463
	xor	xhl, xhl	; F48418  xor XHL,XHL
	ld	hl, (BStore_CursorBlock:16)	; F4841A  ld HL,(0x345c)
	dec	1, xhl	; F4841E  dec 1,XHL
	sla	xhl, 8	; F48420  sla 0x08,XHL
	add	xhl, xwa	; F48423  add XHL,XWA
	ld	iy, (BStore_CursorOffset:16)	; F48425  ld IY,(0x345e)
	ld	a, (xhl+iy)	; F48429  ld A,(XHL+IY)
	ret	; F4842E  ret

; --------------------------------------------------------------------------
; BStore_StepCursorOneByte_Call
; Called from: in-module: 0xF47CA4 0xF48109
; Touches: (0x345C) (0x345E)
; Calls:   T_BStore_StepCursorOneByte BStore_StepCursorOneByte_Call_Nop
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4842F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_StepCursorOneByte_Call: `call T_BStore_StepCursorOneByte` / `jr` / `ret`: steps the block-store cursor one
;   byte (offset + 1, or the +3 next block at offset 5). The bytes after its ret (0xF48436-0xF48462) are an unreached
;   inline version of the same step. BStore_StepCursorToNextLeadByte steps with it. Basis: caller header + body
;   (wrapper). (notes/naming-pilot-2026-10-06/proposals_wave9_d9.json)
BStore_StepCursorOneByte_Call:
	call	T_BStore_StepCursorOneByte	; F4842F  call 0xf40c50
	jr	BStore_StepCursorOneByte_Call_Return	; F48433  jr T,0xf48435
BStore_StepCursorOneByte_Call_Return:
	ret	; F48435  ret
	ld	wa, (BStore_CursorOffset:16)	; F48436  ld WA,(0x345e)
	cp	wa, 255	; F4843A  cp WA,0x00ff
	jr	nz, BStore_StepCursorOneByte_Call_Skip	; F4843E  jr NZ,0xf4845c
	calr	BStore_StepCursorOneByte_Call_Nop	; F48440  calr 0xf48463
	xor	xhl, xhl	; F48443  xor XHL,XHL
	ld	hl, (BStore_CursorBlock:16)	; F48445  ld HL,(0x345c)
	dec	1, xhl	; F48449  dec 1,XHL
	sla	xhl, 8	; F4844B  sla 0x08,XHL
	add	xhl, xwa	; F4844E  add XHL,XWA
	ld	wa, (xhl+3)	; F48450  ld WA,(XHL+0x03)
	ld	(BStore_CursorBlock:16), wa	; F48453  ld (0x345c),WA
	ldw	wa, 5	; F48457  ld WA,0x0005
	jr	BStore_StepCursorOneByte_Call_Join	; F4845A  jr T,0xf4845e
BStore_StepCursorOneByte_Call_Skip:
	inc	1, wa	; F4845C  inc 1,WA
BStore_StepCursorOneByte_Call_Join:
	ld	(BStore_CursorOffset:16), wa	; F4845E  ld (0x345e),WA
	ret	; F48462  ret

; --------------------------------------------------------------------------
; BStore_StepCursorOneByte_Call_Nop
; Called from: in-module: 0xF48415 0xF48440
; Touches: nothing with an absolute address
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF48463 is an instruction boundary.
;
; Purpose: none -- the entry is a lone `ret`.  Named BStore_StepCursorOneByte_Call_Nop after what reaches it
;          (was sub_F48463; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
BStore_StepCursorOneByte_Call_Nop:
	ret	; F48463  ret

; --------------------------------------------------------------------------
; SeqCycle_LocateToStart
; Called from: T_SeqCycle_LocateToStart (x13)
; Touches: (0x207A) (0x2095) (0x349A) (0x349C) (0x349F) (0x34D4) (0x3552)
;          (0x361E) (0x3622) (0x36C6) +2 more  |  0x003460 0x003482 0x00362A
;          0x00364C
; Calls:   SeqTrackCursors_ResetAll T_SeqCycle_LocateTracksToCurrentMeasure T_CycleRecord_CheckIsRecordTrack BStore_DirEntryHeadAtIY T_Nop_CallsEmptyDirectorySlot_Veneer T_PartNotes_ReleaseAllTrackNotes
;          T_F41F18
; Evidence: thunk slot T_SeqCycle_LocateToStart holds `jp 0x00F48464`, and 0xF48464 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqCycle_LocateToStart: (0x3552), the CURRENT MEASURE, := the CYCLE START MEASURE (CyclePlay's 0x361E, or
;   CycleRecord's 0x3622 when UI_ScreenLatch is 6/8); locates every track there (T_SeqCycle_LocateTracksToCurrentMeasure with the playing mask forced
;   to all ones), saves the 17 track cursors 0x3460/0x3482 to 0x362A/0x364C (restored at the cycle wrap), releases
;   notes and resets controllers. Basis: callers + DL captions + body. (wsa1/notes/naming-
;   pilot-2026-10-06/proposals_prom_b.json)
SeqCycle_LocateToStart:		; <- T_SeqCycle_LocateToStart
	cp	(UI_ScreenLatch:16), 0x06	; F48464  cp (0x207a),0x06
	jr	z, SeqCycle_LocateToStart_Skip	; F48469  jr Z,0xf48478
	cp	(UI_ScreenLatch:16), 0x08	; F4846B  cp (0x207a),0x08
	jr	z, SeqCycle_LocateToStart_Skip	; F48470  jr Z,0xf48478
	ld	wa, (13854:16)	; F48472  ld WA,(0x361e)
	jr	SeqCycle_LocateToStart_Join	; F48476  jr T,0xf4847c
SeqCycle_LocateToStart_Skip:
	ld	wa, (13858:16)	; F48478  ld WA,(0x3622)
SeqCycle_LocateToStart_Join:
	ld	(13650:16), wa	; F4847C  ld (0x3552),WA
	or	(UI_ScreenFlags:16), 0x10	; F48480  or (0x2095),0x10
	calr	SeqTrackCursors_ResetAll	; F48485  calr 0xf486d9
	ld	xwa, (6304798:24)	; F48488  ld XWA,(0x60341e)
	push	xwa	; F4848D  push XWA
	ld	xwa, 4294967295	; F4848E  ld XWA,0xffffffff
	ld	(6304798:24), xwa	; F48493  ld (0x60341e),XWA
	call	T_SeqCycle_LocateTracksToCurrentMeasure	; F48498  call 0xf40ab0
	pop	xwa	; F4849C  pop XWA
	ld	(6304798:24), xwa	; F4849D  ld (0x60341e),XWA
	cpw	(0x3552:16), 0x0001	; F484A2  cp (0x3552),0x0001
	jrl	nz, SeqCycle_LocateToStart_Skip5	; F484A8  jrl NZ,0xf48544
	ld	c, (14038:16)	; F484AB  ld C,(0x36d6)
	ld	(13471:16), c	; F484AF  ld (0x349f),C
	call	T_CycleRecord_CheckIsRecordTrack	; F484B3  call 0xf40be4
	cp	a, 0:i3	; F484B7  cp A,0
	jr	nz, SeqCycle_LocateToStart_Join2	; F484B9  jr NZ,0xf484e1
	ld	a, (14038:16)	; F484BB  ld A,(0x36d6)
	cp	a, 16	; F484BF  cp A,0x10
	jr	nc, SeqCycle_LocateToStart_Skip2	; F484C2  jr NC,0xf484d1
	ld	de, (13466:16)	; F484C4  ld DE,(0x349a)
	scf	; F484C8  scf
	stcf_a_16	de	; F484C9  stcf A,DE
	ld	(13466:16), de	; F484CB  ld (0x349a),DE
	jr	SeqCycle_LocateToStart_Join2	; F484CF  jr T,0xf484e1
SeqCycle_LocateToStart_Skip2:
	pushw	wa	; F484D1  push WA
	ld	de, (13468:16)	; F484D2  ld DE,(0x349c)
	sub	a, 16	; F484D6  sub A,0x10
	scf	; F484D9  scf
	stcf_a_16	de	; F484DA  stcf A,DE
	ld	(13468:16), de	; F484DC  ld (0x349c),DE
	popw	wa	; F484E0  pop WA
SeqCycle_LocateToStart_Join2:
	ld	(13471:16), 0	; F484E1  ld (0x349f),0x00
	xor	iy, iy	; F484E6  xor IY,IY
	xor	ix, ix	; F484E8  xor IX,IX
SeqCycle_LocateToStart_Loop:
	xor	bc, bc	; F484EA  xor BC,BC
	ld	c, (13471:16)	; F484EC  ld C,(0x349f)
	cp	c, 16	; F484F0  cp C,0x10
	jr	nc, SeqCycle_LocateToStart_Skip3	; F484F3  jr NC,0xf48502
	ld	iz, (13466:16)	; F484F5  ld IZ,(0x349a)
	ld	a, c	; F484F9  ld A,C
	scf	; F484FB  scf
	xorcf_a_16	iz	; F484FC  xorcf A,IZ
	jr	c, SeqCycle_LocateToStart_Skip4	; F484FE  jr C,0xf48531
	jr	SeqCycle_LocateToStart_Join3	; F48500  jr T,0xf48510
SeqCycle_LocateToStart_Skip3:
	ld	iz, (13468:16)	; F48502  ld IZ,(0x349c)
	ld	a, c	; F48506  ld A,C
	sub	a, 16	; F48508  sub A,0x10
	scf	; F4850B  scf
	xorcf_a_16	iz	; F4850C  xorcf A,IZ
	jr	c, SeqCycle_LocateToStart_Skip4	; F4850E  jr C,0xf48531
SeqCycle_LocateToStart_Join3:
	push	xix	; F48510  push XIX
	push	xiy	; F48511  push XIY
	call	BStore_DirEntryHeadAtIY	; F48512  call 0xf47804
	pop	xiy	; F48516  pop XIY
	pop	xix	; F48517  pop XIX
	ld	xhl, 13408	; F48518  ld XHL,0x00003460
	ld	(xhl+ix), wa	; F4851D  ld (XHL+IX),WA
	ld	xhl, 13442	; F48522  ld XHL,0x00003482
	ex16	iy, bc	; F48527  ex IY,BC
	ld	(xhl+iy), 0x05	; F48529  ld (XHL+IY),0x05
	ex16	iy, bc	; F4852F  ex IY,BC
SeqCycle_LocateToStart_Skip4:
	add	iy, 3	; F48531  add IY,0x0003
	add	ix, 2	; F48535  add IX,0x0002
	inc	1, (13471:16)	; F48539  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F4853D  cp (0x349f),0x11
	jr	c, SeqCycle_LocateToStart_Loop	; F48542  jr C,0xf484ea
SeqCycle_LocateToStart_Skip5:
	ld	xwa, (13466:16)	; F48544  ld XWA,(0x349a)
	ld	(14026:16), xwa	; F48548  ld (0x36ca),XWA
	ld	(14022:16), xwa	; F4854C  ld (0x36c6),XWA
	ldw	bc, 17	; F48550  ld BC,0x0011
	ld	xde, 13866	; F48553  ld XDE,0x0000362a
	ld	xhl, 13408	; F48558  ld XHL,0x00003460
	ldirw93	; F4855D  ldirw
	ldw	bc, 17	; F4855F  ld BC,0x0011
	ld	xde, 13900	; F48562  ld XDE,0x0000364c
	ld	xhl, 13442	; F48567  ld XHL,0x00003482
	ldir83	; F4856C  ldir
	call	T_Nop_CallsEmptyDirectorySlot_Veneer	; F4856E  call 0xf40a90
	call	T_PartNotes_ReleaseAllTrackNotes	; F48572  call 0xf413c8
	call	T_F41F18	; F48576  call 0xf41f18
	or	(0x34d4:16), 0x10	; F4857A  or (0x34d4),0x10
	ret	; F4857F  ret

; --------------------------------------------------------------------------
; SeqCycle_CaptureEndCursors
; Called from: T_SeqCycle_CaptureEndCursors (x13)
; Touches: (0x207A) (0x3552) (0x3620) (0x3624)  |  0x003460 0x003482
;          0x00365E 0x003680
; Calls:   SeqTrackCursors_Save SeqTrackCursors_ResetAll T_SeqTrackCursors_LocateAllToCurrentMeasure SeqTrackCursors_StepAllBack SeqTrackCursors_RestoreSaved
; Evidence: thunk slot T_SeqCycle_CaptureEndCursors holds `jp 0x00F48580`, and 0xF48580 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqCycle_CaptureEndCursors: Saves the live track cursors, locates to CYCLE END MEASURE + 1 (CyclePlay's 0x3620, or
;   CycleRecord's 0x3624 when UI_ScreenLatch is 6/8), stores the 17 cursors there in 0x365E/0x3680 -- what the
;   playback loop compares against -- then restores (0x3552) and the cursors. First call of the cycle-arming triple.
;   Basis: callers + DL captions + body. (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
SeqCycle_CaptureEndCursors:		; <- T_SeqCycle_CaptureEndCursors
	calr	SeqTrackCursors_Save	; F48580  calr 0xf4869b
	ld	wa, (13650:16)	; F48583  ld WA,(0x3552)
	pushw	wa	; F48587  push WA
	cp	(UI_ScreenLatch:16), 0x06	; F48588  cp (0x207a),0x06
	jr	z, SeqCycle_CaptureEndCursors_Skip6	; F4858D  jr Z,0xf4859c
	cp	(UI_ScreenLatch:16), 0x08	; F4858F  cp (0x207a),0x08
	jr	z, SeqCycle_CaptureEndCursors_Skip6	; F48594  jr Z,0xf4859c
	ld	wa, (13856:16)	; F48596  ld WA,(0x3620)
	jr	SeqCycle_CaptureEndCursors_Join4	; F4859A  jr T,0xf485a0
SeqCycle_CaptureEndCursors_Skip6:
	ld	wa, (13860:16)	; F4859C  ld WA,(0x3624)
SeqCycle_CaptureEndCursors_Join4:
	inc	1, wa	; F485A0  inc 1,WA
	ld	(13650:16), wa	; F485A2  ld (0x3552),WA
	calr	SeqTrackCursors_ResetAll	; F485A6  calr 0xf486d9
	call	T_SeqTrackCursors_LocateAllToCurrentMeasure	; F485A9  call 0xf40a9c
	calr	SeqTrackCursors_StepAllBack	; F485AD  calr 0xf485d7
	ldw	bc, 17	; F485B0  ld BC,0x0011
	ld	xde, 13918	; F485B3  ld XDE,0x0000365e
	ld	xhl, 13408	; F485B8  ld XHL,0x00003460
	ldirw93	; F485BD  ldirw
	ldw	bc, 17	; F485BF  ld BC,0x0011
	ld	xde, 13952	; F485C2  ld XDE,0x00003680
	ld	xhl, 13442	; F485C7  ld XHL,0x00003482
	ldir83	; F485CC  ldir
	popw	wa	; F485CE  pop WA
	ld	(13650:16), wa	; F485CF  ld (0x3552),WA
	calr	SeqTrackCursors_RestoreSaved	; F485D3  calr 0xf486ba
	ret	; F485D6  ret

; --------------------------------------------------------------------------
; SeqTrackCursors_StepAllBack
; Called from: in-module: 0xF485AD 0xF487C0
; Touches: (0x345C) (0x345E) (0x349F)  |  0x003460 0x003482
; Calls:   BStore_StepCursorBackToLeadByte
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF485D7 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrackCursors_StepAllBack: For each track 0..16 whose saved cursor (0x3460/0x3482) is in use (block != 0xFFFF):
;   loads it into the block-store cursor, steps it back to the previous byte with bit 7 set (BStore_StepCursorBackToLeadByte, following the
;   previous-block link at +1), and stores it back. SeqCycle_CaptureEndCursors (and its CycleRecord twin CycleRecord_CaptureEndCursors)
;   runs it between locating to END + 1 and copying the cursors to 0x365E/0x3680. Basis: callers + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave4_l.json)
SeqTrackCursors_StepAllBack:
	ld	(13471:16), 0	; F485D7  ld (0x349f),0x00
SeqTrackCursors_StepAllBack_Loop:
	xor	wa, wa	; F485DC  xor WA,WA
	ld	xix, 13408	; F485DE  ld XIX,0x00003460
	ld	a, (13471:16)	; F485E3  ld A,(0x349f)
	sll	wa, 1	; F485E7  sll 0x01,WA
	ld	wa, (xix+wa)	; F485EA  ld WA,(XIX+WA)
	cp	wa, 65535	; F485EF  cp WA,0xffff
	jr	z, SeqTrackCursors_StepAllBack_Skip	; F485F3  jr Z,0xf4863b
	ld	(BStore_CursorBlock:16), wa	; F485F5  ld (0x345c),WA
	xor	wa, wa	; F485F9  xor WA,WA
	ld	xix, 13442	; F485FB  ld XIX,0x00003482
	ld	a, (13471:16)	; F48600  ld A,(0x349f)
	ld	a, (xix+a)	; F48604  ld A,(XIX+A)
	ld	(BStore_CursorOffset:16), wa	; F48609  ld (0x345e),WA
	calr	BStore_StepCursorBackToLeadByte	; F4860D  calr 0xf48647
	xor	wa, wa	; F48610  xor WA,WA
	ld	xix, 13408	; F48612  ld XIX,0x00003460
	ld	a, (13471:16)	; F48617  ld A,(0x349f)
	sll	wa, 1	; F4861B  sll 0x01,WA
	ld	bc, (BStore_CursorBlock:16)	; F4861E  ld BC,(0x345c)
	ld	(xix+wa), bc	; F48622  ld (XIX+WA),BC
	xor	wa, wa	; F48627  xor WA,WA
	ld	xix, 13442	; F48629  ld XIX,0x00003482
	ld	a, (13471:16)	; F4862E  ld A,(0x349f)
	ld	bc, (BStore_CursorOffset:16)	; F48632  ld BC,(0x345e)
	ld	(xix+wa), c	; F48636  ld (XIX+WA),C
SeqTrackCursors_StepAllBack_Skip:
	inc	1, (13471:16)	; F4863B  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F4863F  cp (0x349f),0x11
	jr	c, SeqTrackCursors_StepAllBack_Loop	; F48644  jr C,0xf485dc
	ret	; F48646  ret

; --------------------------------------------------------------------------
; BStore_StepCursorBackToLeadByte
; Called from: T_BStore_StepCursorBackToLeadByte (x3); in-module: 0xF4860D
; Touches: (0x0D4A) (0x345C) (0x345E)  |  0x000001
; Calls:   T_BStore_ReadCursorByte BStore_GetHeapBase_B
; Evidence: thunk slot T_BStore_StepCursorBackToLeadByte holds `jp 0x00F48647`, and 0xF48647 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_StepCursorBackToLeadByte: Steps the block-store cursor back to the previous byte with bit 7 set (an event
;   lead byte, 0x81 or 0x82); below offset 5 it follows the block's previous link (+1) to offset 255; link 0 = chain
;   start: BStore_ErrorCode := 0xFF (else 0). SeqTrackCursors_StepAllBack runs it on every saved cursor; backward twin
;   of BStore_StepCursorOneByte. Basis: caller header + body. (notes/naming-pilot-2026-10-06/proposals_wave5_p.json)
BStore_StepCursorBackToLeadByte:		; <- T_BStore_StepCursorBackToLeadByte
	ld	(BStore_ErrorCode:16), 0	; F48647  ld (0x0d4a),0x00
BStore_StepCursorBackToLeadByte_Loop:
	cpw	(BStore_CursorOffset:16), 0x0005	; F4864C  cp (0x345e),0x0005
	jr	ule, BStore_StepCursorBackToLeadByte_Skip	; F48652  jr ULE,0xf48662
	decw	1, (BStore_CursorOffset:16)	; F48654  decw 1,(0x345e)
BStore_StepCursorBackToLeadByte_Join:
	call	T_BStore_ReadCursorByte	; F48658  call 0xf40c54
	bit	7, a	; F4865C  bit 0x07,A
	jr	z, BStore_StepCursorBackToLeadByte_Loop	; F4865F  jr Z,0xf4864c
	ret	; F48661  ret
BStore_StepCursorBackToLeadByte_Skip:
	calr	BStore_GetHeapBase_B	; F48662  calr 0xf48690
	ld	ix, (BStore_CursorBlock:16)	; F48665  ld IX,(0x345c)
	extz	xix	; F48669  extz XIX
	dec	1, xix	; F4866B  dec 1,XIX
	sll	xix, 8	; F4866D  sll 0x08,XIX
	add	xiy, xix	; F48670  add XIY,XIX
	add	xiy, 1	; F48672  add XIY,0x00000001
	ld	wa, (xiy)	; F48678  ld WA,(XIY)
	cp	wa, 0:i3	; F4867A  cp WA,0
	jr	z, BStore_StepCursorBackToLeadByte_Skip2	; F4867C  jr Z,0xf4868a
	ld	(BStore_CursorBlock:16), wa	; F4867E  ld (0x345c),WA
	ldw	(BStore_CursorOffset:16), 255	; F48682  ld (0x345e),0x00ff
	jr	BStore_StepCursorBackToLeadByte_Join	; F48688  jr T,0xf48658
BStore_StepCursorBackToLeadByte_Skip2:
	ld	(BStore_ErrorCode:16), 255	; F4868A  ld (0x0d4a),0xff
	ret	; F4868F  ret

; --------------------------------------------------------------------------
; BStore_GetHeapBase_B
; Called from: in-module: 0xF48662
; Touches: (0x3604)  |  0x000000
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF48690 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_GetHeapBase_B: XIY = BStore_HeapBase -- prom_b's copy of prom_a's BStore_GetHeapBase.
BStore_GetHeapBase_B:
	ld	xiy, (BStore_HeapBase:16)	; F48690  ld XIY,(0x3604)
	add	xiy, 0	; F48694  add XIY,0x00000000
	ret	; F4869A  ret

; --------------------------------------------------------------------------
; SeqTrackCursors_Save
; Called from: T_SeqTrackCursors_Save (x7); in-module: 0xF48580 0xF487A7
; Touches:   |  0x003460 0x003482 0x003692 0x0036B4
; Evidence: thunk slot T_SeqTrackCursors_Save holds `jp 0x00F4869B`, and 0xF4869B is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrackCursors_Save: Copies the 17 live track cursors -- block words 0x3460[] and offsets 0x3482[] -- to 0x3692[] /
;   0x36B4[]; SeqTrackCursors_RestoreSaved copies them back. First step of SeqCycle_CaptureEndCursors ('saves the live track cursors'),
;   also slot T_SeqTrackCursors_Save for the cycle-record code. Basis: caller header + body + inverse twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_m.json)
SeqTrackCursors_Save:		; <- T_SeqTrackCursors_Save
	ldw	bc, 17	; F4869B  ld BC,0x0011
	ld	xde, 13970	; F4869E  ld XDE,0x00003692
	ld	xhl, 13408	; F486A3  ld XHL,0x00003460
	ldirw93	; F486A8  ldirw
	ldw	bc, 17	; F486AA  ld BC,0x0011
	ld	xde, 14004	; F486AD  ld XDE,0x000036b4
	ld	xhl, 13442	; F486B2  ld XHL,0x00003482
	ldir83	; F486B7  ldir
	ret	; F486B9  ret

; --------------------------------------------------------------------------
; SeqTrackCursors_RestoreSaved
; Called from: T_SeqTrackCursors_RestoreSaved (x7); in-module: 0xF485D3 0xF487E6
; Touches:   |  0x003460 0x003482 0x003692 0x0036B4
; Evidence: thunk slot T_SeqTrackCursors_RestoreSaved holds `jp 0x00F486BA`, and 0xF486BA is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrackCursors_RestoreSaved: Copies the 17 track cursors back from the save area: block words 0x3692 -> 0x3460
;   (ldirw) and offsets 0x36B4 -> 0x3482 (ldir). Its twin SeqTrackCursors_Save saves them there; SeqCycle_CaptureEndCursors
;   saves, relocates to capture the end cursors, then calls this to put the live cursors back. Basis: caller + body +
;   twin. (notes/naming-pilot-2026-10-06/proposals_wave4_n.json)
SeqTrackCursors_RestoreSaved:		; <- T_SeqTrackCursors_RestoreSaved
	ldw	bc, 17	; F486BA  ld BC,0x0011
	ld	xde, 13408	; F486BD  ld XDE,0x00003460
	ld	xhl, 13970	; F486C2  ld XHL,0x00003692
	ldirw93	; F486C7  ldirw
	ldw	bc, 17	; F486C9  ld BC,0x0011
	ld	xde, 13442	; F486CC  ld XDE,0x00003482
	ld	xhl, 14004	; F486D1  ld XHL,0x000036b4
	ldir83	; F486D6  ldir
	ret	; F486D8  ret

; --------------------------------------------------------------------------
; SeqTrackCursors_ResetAll
; Called from: in-module: 0xF48485 0xF485A6 0xF487B9
; Touches:   |  0x003460 0x003482
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF486D9 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SeqTrackCursors_ResetAll: All 17 track cursors := block word 1 (0x3460[]) and offset 5 (0x3482[]), the first payload
;   byte after a block's 5-byte header. SeqCycle_LocateToStart / SeqCycle_CaptureEndCursors call it just before
;   relocating every track to a measure. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave2_c.json)
SeqTrackCursors_ResetAll:
	xor	bc, bc	; F486D9  xor BC,BC
	ldw	wa, 1	; F486DB  ld WA,0x0001
	ld	xde, 13408	; F486DE  ld XDE,0x00003460
SeqTrackCursors_ResetAll_Loop:
	ld	(xde+bc), wa	; F486E3  ld (XDE+BC),WA
	inc	2, bc	; F486E8  inc 2,BC
	cp	bc, 34	; F486EA  cp BC,0x0022
	jr	c, SeqTrackCursors_ResetAll_Loop	; F486EE  jr C,0xf486e3
	xor	bc, bc	; F486F0  xor BC,BC
	ld	xde, 13442	; F486F2  ld XDE,0x00003482
	ld	a, 5:opc	; F486F7  ld A,0x05
SeqTrackCursors_ResetAll_Loop2:
	ld	(xde+bc), a	; F486F9  ld (XDE+BC),A
	inc	1, bc	; F486FE  inc 1,BC
	cp	bc, 17	; F48700  cp BC,0x0011
	jr	c, SeqTrackCursors_ResetAll_Loop2	; F48704  jr C,0xf486f9
	ret	; F48706  ret

; --------------------------------------------------------------------------
; CycleRecord_CaptureStartCursors
; Called from: T_CycleRecord_CaptureStartCursors (x1)
; Touches: (0x349F) (0x3552) (0x3622) (0x36D6)  |  0x003460 0x003482
;          0x00362A 0x00364C
; Calls:   T_SeqTrackCursors_LocateAllToCurrentMeasure BStore_DirEntryHeadAtIY
; Evidence: thunk slot T_CycleRecord_CaptureStartCursors holds `jp 0x00F48707`, and 0xF48707 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CaptureStartCursors: CYCLE RECORD counterpart of SeqCycle_LocateToStart's capture: with (0x3552) := the
;   cycle start measure (0x3622) and the 0x60341E mask forced to all ones, locates all tracks there (at measure 1 the
;   record track (0x36D6) gets its directory head, offset 5), copies the 17 cursors to 0x362A/0x364C and restores
;   (0x3552); the live cursors are left there. CycleRecord_CommitTake (T_CycleRecord_CaptureStartCursors). Basis: caller + body + twin.
;   (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
CycleRecord_CaptureStartCursors:		; <- T_CycleRecord_CaptureStartCursors
	ld	wa, (13650:16)	; F48707  ld WA,(0x3552)
	pushw	wa	; F4870B  push WA
	ld	wa, (13858:16)	; F4870C  ld WA,(0x3622)
	ld	(13650:16), wa	; F48710  ld (0x3552),WA
	ld	xwa, (6304798:24)	; F48714  ld XWA,(0x60341e)
	push	xwa	; F48719  push XWA
	ld	xwa, 4294967295	; F4871A  ld XWA,0xffffffff
	ld	(6304798:24), xwa	; F4871F  ld (0x60341e),XWA
	call	T_SeqTrackCursors_LocateAllToCurrentMeasure	; F48724  call 0xf40a9c
	pop	xwa	; F48728  pop XWA
	ld	(6304798:24), xwa	; F48729  ld (0x60341e),XWA
	cpw	(0x3552:16), 0x0001	; F4872E  cp (0x3552),0x0001
	jr	nz, CycleRecord_CaptureStartCursors_Skip2	; F48734  jr NZ,0xf48783
	ld	(13471:16), 0	; F48736  ld (0x349f),0x00
	xor	iy, iy	; F4873B  xor IY,IY
	xor	ix, ix	; F4873D  xor IX,IX
CycleRecord_CaptureStartCursors_Loop3:
	xor	bc, bc	; F4873F  xor BC,BC
	ld	c, (13471:16)	; F48741  ld C,(0x349f)
	ld	a, (14038:16)	; F48745  ld A,(0x36d6)
	cp	(13471:16), a	; F48749  cp (0x349f),A
	jr	nz, CycleRecord_CaptureStartCursors_Skip	; F4874D  jr NZ,0xf48770
	push	xix	; F4874F  push XIX
	push	xiy	; F48750  push XIY
	call	BStore_DirEntryHeadAtIY	; F48751  call 0xf47804
	pop	xiy	; F48755  pop XIY
	pop	xix	; F48756  pop XIX
	ld	xhl, 13408	; F48757  ld XHL,0x00003460
	ld	(xhl+ix), wa	; F4875C  ld (XHL+IX),WA
	ld	xhl, 13442	; F48761  ld XHL,0x00003482
	ex16	iy, bc	; F48766  ex IY,BC
	ld	(xhl+iy), 0x05	; F48768  ld (XHL+IY),0x05
	ex16	iy, bc	; F4876E  ex IY,BC
CycleRecord_CaptureStartCursors_Skip:
	add	iy, 3	; F48770  add IY,0x0003
	add	ix, 2	; F48774  add IX,0x0002
	inc	1, (13471:16)	; F48778  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F4877C  cp (0x349f),0x11
	jr	c, CycleRecord_CaptureStartCursors_Loop3	; F48781  jr C,0xf4873f
CycleRecord_CaptureStartCursors_Skip2:
	ldw	bc, 17	; F48783  ld BC,0x0011
	ld	xde, 13866	; F48786  ld XDE,0x0000362a
	ld	xhl, 13408	; F4878B  ld XHL,0x00003460
	ldirw93	; F48790  ldirw
	ldw	bc, 17	; F48792  ld BC,0x0011
	ld	xde, 13900	; F48795  ld XDE,0x0000364c
	ld	xhl, 13442	; F4879A  ld XHL,0x00003482
	ldir83	; F4879F  ldir
	popw	wa	; F487A1  pop WA
	ld	(13650:16), wa	; F487A2  ld (0x3552),WA
	ret	; F487A6  ret

; --------------------------------------------------------------------------
; CycleRecord_CaptureEndCursors
; Called from: T_CycleRecord_CaptureEndCursors (x1)
; Touches: (0x3552) (0x3624)  |  0x003460 0x003482 0x00365E 0x003680
; Calls:   SeqTrackCursors_Save SeqTrackCursors_ResetAll T_SeqTrackCursors_LocateAllToCurrentMeasure SeqTrackCursors_StepAllBack SeqTrackCursors_RestoreSaved
; Evidence: thunk slot T_CycleRecord_CaptureEndCursors holds `jp 0x00F487A7`, and 0xF487A7 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CycleRecord_CaptureEndCursors: SeqCycle_CaptureEndCursors with the CYCLE RECORD end measure only: saves the live
;   cursors, locates to (0x3624) + 1, steps every cursor back to its lead byte (SeqTrackCursors_StepAllBack), stores
;   the 17 cursors in 0x365E/0x3680, restores (0x3552) and the live cursors. CycleRecord_CommitTake (T_CycleRecord_CaptureEndCursors);
;   SeqTrackCursors_StepAllBack's header already calls it the CycleRecord twin. Basis: caller + body + twin.
;   (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
CycleRecord_CaptureEndCursors:		; <- T_CycleRecord_CaptureEndCursors
	calr	SeqTrackCursors_Save	; F487A7  calr 0xf4869b
	ld	wa, (13650:16)	; F487AA  ld WA,(0x3552)
	pushw	wa	; F487AE  push WA
	ld	wa, (13860:16)	; F487AF  ld WA,(0x3624)
	inc	1, wa	; F487B3  inc 1,WA
	ld	(13650:16), wa	; F487B5  ld (0x3552),WA
	calr	SeqTrackCursors_ResetAll	; F487B9  calr 0xf486d9
	call	T_SeqTrackCursors_LocateAllToCurrentMeasure	; F487BC  call 0xf40a9c
	calr	SeqTrackCursors_StepAllBack	; F487C0  calr 0xf485d7
	ldw	bc, 17	; F487C3  ld BC,0x0011
	ld	xde, 13918	; F487C6  ld XDE,0x0000365e
	ld	xhl, 13408	; F487CB  ld XHL,0x00003460
	ldirw93	; F487D0  ldirw
	ldw	bc, 17	; F487D2  ld BC,0x0011
	ld	xde, 13952	; F487D5  ld XDE,0x00003680
	ld	xhl, 13442	; F487DA  ld XHL,0x00003482
	ldir83	; F487DF  ldir
	popw	wa	; F487E1  pop WA
	ld	(13650:16), wa	; F487E2  ld (0x3552),WA
	calr	SeqTrackCursors_RestoreSaved	; F487E6  calr 0xf486ba
	ret	; F487E9  ret
	.fill	1046, 1, 0x0E	; F487EA-F48BFF  `ret` padding (asserted pure 0x0E)
