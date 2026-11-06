
; ==========================================================================
; 0xF6F000-0xF6F3FF -- AN OLDER BUILD'S COPY OF THE MODULE AT 0xF7AA00-0xF7ADFF
;   Byte for byte the live module this build enters through the routine-
;   directory slots T_BStore_AppendBytes_Join3_Veneer.. (BStore_AppendBytes_Join3_Veneer, BStore_AppendBytes_Join4_Veneer, SongClear_InitFields,
;   SongStore_LoadSongHeaderToDisplay, SongClear_ClearBankTrackMask, TrackClear_ResetSelectionOnEntry ...), 0xBA00
;   lower, except at the nine bytes relocation changes: four `call`s inside
;   the block read the live target - 0xBA00, and the `calr` at 0xF6F3E4 calls
;   0xF7127B where the live copy calls SeqJob_StepValueInRange (0xBA60 higher -- that
;   routine moved 0x60 further between the builds).  It starts on the 4 KB
;   boundary after 0x0E fill (the live copy is preceded by fill too) and ends
;   on the 1 KB boundary 0xF6F400, where this build's MidiFileLoad_LcdKeyRow1 cuts the old
;   copy's last instruction after 4 of its 5 bytes.  Nothing outside these
;   1,024 bytes names an address in them: DEAD in this build.  The same
;   phenomenon as OldBuild_DLHandlerTables_Tail (0xF0ED50) and
;   OldBuild2_ValueGlyph_* (0xF17A5F).
;   Labels are `OldCopy_<live label>` for an entry, `OldCopy_<live address>`
;   for a branch target; a branch to outside the block is spelled
;   `<live target> - <delta>`, since what sits at the old address now is
;   unrelated.  notes/promb-2026-09-25/old_module_copy_f6f000.py checks all of
;   it.
; ==========================================================================
OldCopy_BStore_AppendBytes_Join3_Veneer:
	jr	OldCopy_F7AA04	; F6F000  jr T,0xf6f004
OldCopy_BStore_AppendBytes_Join4_Veneer:
	jr	OldCopy_F7AA1F	; F6F002  jr T,0xf6f01f
OldCopy_F7AA04:
	call	T_Seq_SaveTrackMaskAndStopAll	; F6F004  call 0xf409f8
	ld	(UI_ScreenStage:16), 0	; F6F008  ld (0x207e),0x00
	ldw	(8542:16), 0	; F6F00D  ld (0x215e),0x0000
	orw	(0x212e:16), 0x0100	; F6F013  or (0x212e),0x0100
	or	(0x34bb:16), 0x04	; F6F019  or (0x34bb),0x04
	ret	; F6F01E  ret
OldCopy_F7AA1F:
	call	T_Seq_RestoreTrackMaskAndRewind	; F6F01F  call 0xf409f4
	and	(0x34bb:16), 0xfb	; F6F023  and (0x34bb),0xfb
	ret	; F6F028  ret
OldCopy_SongClear_InitFields:
	cp	(UI_ScreenLatch_Previous:16), 0x1b	; F6F029  cp (0x207b),0x1b
	jr	z, OldCopy_F7AA49	; F6F02E  jr Z,0xf6f049
	ld	(UI_StatusCode:16), 255	; F6F030  ld (0x2880),0xff
	ld	a, (BStore_CurrentBank:16)	; F6F035  ld A,(0x360a)
	ld	(3586:16), a	; F6F039  ld (0x0e02),A
	inc	1, a	; F6F03D  inc 1,A
	ld	(DisplayListB_Stage:16), a	; F6F03F  ld (0x12f6),A
	call	OldCopy_SongStore_LoadSongHeaderToDisplay	; F6F043  call 0xf6f05e
	jr	OldCopy_F7AA5D	; F6F047  jr T,0xf6f05d
OldCopy_F7AA49:
	cp	(UI_StatusCode:16), 0x23	; F6F049  cp (0x2880),0x23
	jr	nz, OldCopy_F7AA5D	; F6F04E  jr NZ,0xf6f05d
	ldw	(UI_Request:16), 513	; F6F050  ld (0x2070),0x0201
	and	(0x20a9:16), 0xfe	; F6F056  and (0x20a9),0xfe
	jr	OldCopy_F7AA5D	; F6F05B  jr T,0xf6f05d
OldCopy_F7AA5D:
	ret	; F6F05D  ret

; --------------------------------------------------------------------------
; OldCopy_SongStore_LoadSongHeaderToDisplay
; Called from: in-module: 0xF6F043 0xF6F0AA 0xF6F0D8
; Touches: (0x0D4A) (0x0E02) (0x12F6) (0x2070) (0x2071) (0x2075) (0x207E)
;          (0x2880) (0x3010) (0x360A) +1 more  |  0x610000
; Calls:   OldCopy_SongStore_LoadSongHeaderToDisplay T_SongClear_ClearBank OldCopy_SongClear_ClearBankTrackMask
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF6F05E is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; ⚠ ANSWERED 2026-09-25: the older build's copy of SongStore_LoadSongHeaderToDisplay
;   (0xF7AA5E); was `sub_F6F05E`, a name that
;   was the address.  See the banner at 0xF6F000: its callers are inside
;   that copy, which is dead here.
; --------------------------------------------------------------------------
OldCopy_SongStore_LoadSongHeaderToDisplay:
	xor	xbc, xbc	; F6F05E  xor XBC,XBC
	xor	xwa, xwa	; F6F060  xor XWA,XWA
	ld	a, (3586:16)	; F6F062  ld A,(0x0e02)
	ld	c, a	; F6F066  ld C,A
	ld	xiy, 6356992	; F6F068  ld XIY,0x00610000
	sla	xwa, 11	; F6F06D  sla 0x0b,XWA
	sla	xbc, 10	; F6F070  sla 0x0a,XBC
	add	xwa, xbc	; F6F073  add XWA,XBC
	add	xiy, xwa	; F6F075  add XIY,XWA
	add	xiy, 202	; F6F077  add XIY,0x000000ca
	ld	xix, DisplayListB_Stage+1	; F6F07D  ld XIX,0x000012f7
	ldw	bc, 6	; F6F082  ld BC,0x0006
	ldir85	; F6F085  ldir
	ret	; F6F087  ret
OldCopy_sub_F7AA88:
	ret	; F6F088  ret
OldCopy_SongClear_SoftKeyCol4:
	cp	(UI_ScreenStage:16), 0x01	; F6F089  cp (0x207e),0x01
	jr	z, OldCopy_F7AAAE	; F6F08E  jr Z,0xf6f0ae
	or	(UI_RequestBits:16), 0x09	; F6F090  or (0x2075),0x09
	ld	a, (3586:16)	; F6F095  ld A,(0x0e02)
	cp	a, 10	; F6F099  cp A,0x0a
	jr	z, OldCopy_F7AAAE	; F6F09C  jr Z,0xf6f0ae
	inc	1, a	; F6F09E  inc 1,A
	ld	(3586:16), a	; F6F0A0  ld (0x0e02),A
	inc	1, a	; F6F0A4  inc 1,A
	ld	(DisplayListB_Stage:16), a	; F6F0A6  ld (0x12f6),A
	call	OldCopy_SongStore_LoadSongHeaderToDisplay	; F6F0AA  call 0xf6f05e
OldCopy_F7AAAE:
	ret	; F6F0AE  ret
OldCopy_SongClear_SoftKeyCol3:
	cp	(UI_ScreenStage:16), 0x01	; F6F0AF  cp (0x207e),0x01
	jr	z, OldCopy_F7AADC	; F6F0B4  jr Z,0xf6f0dc
	or	(UI_RequestBits:16), 0x09	; F6F0B6  or (0x2075),0x09
	ld	a, (3586:16)	; F6F0BB  ld A,(0x0e02)
	cp	a, 0:i3	; F6F0BF  cp A,0
	jr	z, OldCopy_F7AADC	; F6F0C1  jr Z,0xf6f0dc
	cp	a, 10	; F6F0C3  cp A,0x0a
	jr	nz, OldCopy_F7AACC	; F6F0C6  jr NZ,0xf6f0cc
	ld	a, 9:opc	; F6F0C8  ld A,0x09
	jr	OldCopy_F7AACE	; F6F0CA  jr T,0xf6f0ce
OldCopy_F7AACC:
	dec	1, a	; F6F0CC  dec 1,A
OldCopy_F7AACE:
	ld	(3586:16), a	; F6F0CE  ld (0x0e02),A
	inc	1, a	; F6F0D2  inc 1,A
	ld	(DisplayListB_Stage:16), a	; F6F0D4  ld (0x12f6),A
	call	OldCopy_SongStore_LoadSongHeaderToDisplay	; F6F0D8  call 0xf6f05e
OldCopy_F7AADC:
	ret	; F6F0DC  ret
OldCopy_SongClear_LcdKeyRow5:
	cp	(UI_ScreenStage:16), 0x01	; F6F0DD  cp (0x207e),0x01
	jr	nz, OldCopy_F7AAEF	; F6F0E2  jr NZ,0xf6f0ef
	ld	(UI_ScreenStage:16), 0	; F6F0E4  ld (0x207e),0x00
	ldw	(UI_Request:16), 32794	; F6F0E9  ld (0x2070),0x801a
OldCopy_F7AAEF:
	ret	; F6F0EF  ret
OldCopy_SongClear_LcdKeyRow4:
	and	(UI_RequestBits:16), 0xf6	; F6F0F0  and (0x2075),0xf6
	cp	(UI_ScreenStage:16), 0x01	; F6F0F5  cp (0x207e),0x01
	jr	z, OldCopy_F7AB08	; F6F0FA  jr Z,0xf6f108
	ld	(UI_ScreenStage:16), 1	; F6F0FC  ld (0x207e),0x01
	or	(UI_Request_Hi:16), 0x10	; F6F101  or (0x2071),0x10
	jr	OldCopy_F7AB3E	; F6F106  jr T,0xf6f13e
OldCopy_F7AB08:
	ld	(UI_StatusCode:16), 255	; F6F108  ld (0x2880),0xff
	ld	(BStore_ErrorCode:16), 0	; F6F10D  ld (0x0d4a),0x00
	call	T_SongClear_ClearBank	; F6F112  call 0xf426e0
	call	OldCopy_SongClear_ClearBankTrackMask	; F6F116  call 0xf6f13f
	ld	a, (3586:16)	; F6F11A  ld A,(0x0e02)
	cp	a, (BStore_CurrentBank:16)	; F6F11E  cp A,(0x360a)
	jr	nz, OldCopy_F7AB2E	; F6F122  jr NZ,0xf6f12e
	xor	xwa, xwa	; F6F124  xor XWA,XWA
	ld	(12304:16), xwa	; F6F126  ld (0x3010),XWA
	ld	(13836:16), xwa	; F6F12A  ld (0x360c),XWA
OldCopy_F7AB2E:
	ld	(UI_ScreenStage:16), 0	; F6F12E  ld (0x207e),0x00
	ld	(UI_StatusCode:16), 35	; F6F133  ld (0x2880),0x23
	ldw	(UI_Request:16), 16555	; F6F138  ld (0x2070),0x40ab
OldCopy_F7AB3E:
	ret	; F6F13E  ret

; --------------------------------------------------------------------------
; OldCopy_SongClear_ClearBankTrackMask
; Called from: in-module: 0xF6F116
; Touches: (0x0E02) (0x360C)  |  0x610000
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF6F13F is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; ⚠ ANSWERED 2026-09-25: the older build's copy of SongClear_ClearBankTrackMask
;   (0xF7AB3F); was `sub_F6F13F`, a name that
;   was the address.  See the banner at 0xF6F000: its callers are inside
;   that copy, which is dead here.
; --------------------------------------------------------------------------
OldCopy_SongClear_ClearBankTrackMask:
	cp	(0x0e02:16), 0x0a	; F6F13F  cp (0x0e02),0x0a
	jr	nz, OldCopy_F7AB76	; F6F144  jr NZ,0xf6f176
	xor	xwa, xwa	; F6F146  xor XWA,XWA
	ld	(13836:16), xwa	; F6F148  ld (0x360c),XWA
	ld	xde, 6356992	; F6F14C  ld XDE,0x00610000
OldCopy_F7AB51:
	ld	xhl, xwa	; F6F151  ld XHL,XWA
	push	xbc	; F6F153  push XBC
	ld	xbc, xhl	; F6F154  ld XBC,XHL
	sla	xhl, 11	; F6F156  sla 0x0b,XHL
	sla	xbc, 10	; F6F159  sla 0x0a,XBC
	add	xhl, xbc	; F6F15C  add XHL,XBC
	pop	xbc	; F6F15E  pop XBC
	add	xhl, xde	; F6F15F  add XHL,XDE
	add	xhl, 30	; F6F161  add XHL,0x0000001e
	push	xbc	; F6F167  push XBC
	xor	xbc, xbc	; F6F168  xor XBC,XBC
	ld	(xhl), xbc	; F6F16A  ld (XHL),XBC
	pop	xbc	; F6F16C  pop XBC
	inc	1, a	; F6F16D  inc 1,A
	cp	a, 10	; F6F16F  cp A,0x0a
	jr	c, OldCopy_F7AB51	; F6F172  jr C,0xf6f151
	jr	OldCopy_F7AB9B	; F6F174  jr T,0xf6f19b
OldCopy_F7AB76:
	ld	xde, 6356992	; F6F176  ld XDE,0x00610000
	push	xbc	; F6F17B  push XBC
	xor	xwa, xwa	; F6F17C  xor XWA,XWA
	ld	a, (3586:16)	; F6F17E  ld A,(0x0e02)
	ld	xbc, xwa	; F6F182  ld XBC,XWA
	sla	xwa, 11	; F6F184  sla 0x0b,XWA
	sla	xbc, 10	; F6F187  sla 0x0a,XBC
	add	xwa, xbc	; F6F18A  add XWA,XBC
	pop	xbc	; F6F18C  pop XBC
	add	xde, xwa	; F6F18D  add XDE,XWA
	add	xde, 30	; F6F18F  add XDE,0x0000001e
	push	xbc	; F6F195  push XBC
	xor	xbc, xbc	; F6F196  xor XBC,XBC
	ld	(xde), xbc	; F6F198  ld (XDE),XBC
	pop	xbc	; F6F19A  pop XBC
OldCopy_F7AB9B:
	ret	; F6F19B  ret

; --------------------------------------------------------------------------
; Data_F6F19C -- 612 bytes this block could not split.  No content rule
;                framed it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or
;                ASCII -- and the code walk never reached it from a thunk
;                slot, a proven call site, an opcode-anchored call or an
;                entry of a table the firmware transfers to.  So it is
;                emitted as bytes rather than guessed.
; Contains: printable bytes |.z !.{ .f........^!.....!>....z ?.f..F.
;           ......6...4`P....0`......u <..~ ?.f.h..~ ...q
;           >........^!.....!>....u <..~ ?.f..~ ...q >.....?..n..~ ...q
;           >.hj.....#.>.....>*g....a.p.A)+..(...J.....&.KI.a...c....!..0
;           ....0.... .F.P.......^!.....!>...~ ....(.#.p ..@..8........z
;           ?.f...0 ..6...4``....0`...........u >........u >........u >...N.
;           @....O.@...?.n..G.h....?.n....h....?.n......N.@....O.@...?.n....
;           h....?.n..Z.h....?.n......u >....!.O.?.f..a...c.!.....n
;           h.....f.h..i..k.!.....n.h.....f....A.Y4`A...A..u
;           >....!.O.?.f..a...c.!.....n h.....f.h..i..k.!.....n.h.....f....A
;           .Z4`A...A....!'.&.......A.[4`A...A..~ ?.n..u <|
; Read by: nothing in prom_a or prom_b spells this address as a 32-bit word,
;          so whatever reaches it computes the address
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; ⚠ ANSWERED 2026-09-25 (the "nothing but its bytes" verdict that stood
;   here): 0xF6F19C-0xF6F3FF is CODE, the older build's copy of
;   0xF7AB9C-0xF7ADFF -- see the banner at 0xF6F000.  The label
;   `Data_F6F19C` is retired; the lines below mirror the live copy's.
; --------------------------------------------------------------------------
OldCopy_TrackClear_ResetSelectionOnEntry:
	ld	a, (UI_ScreenLatch:16)	; F6F19C  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F6F1A0  cp A,(0x207b)
	jr	z, OldCopy_F7ABB8	; F6F1A4  jr Z,0xf6f1b8
	ldw	(3518:16), 0	; F6F1A6  ld (0x0dbe),0x0000
	ldw	(8542:16), 0	; F6F1AC  ld (0x215e),0x0000
	orw	(0x212e:16), 0x0100	; F6F1B2  or (0x212e),0x0100
OldCopy_F7ABB8:
	ret	; F6F1B8  ret
OldCopy_TrackClear_OnLeave:
	cp	(UI_ScreenLatch:16), 0x1c	; F6F1B9  cp (0x207a),0x1c
	jr	z, OldCopy_F7ABDB	; F6F1BE  jr Z,0xf6f1db
	ld	wa, (3654:16)	; F6F1C0  ld WA,(0x0e46)
	xor	wa, 65535	; F6F1C4  xor WA,0xffff
	and	(0x360c:16), wa	; F6F1C8  and (0x360c),WA
	ld	(6304798:24), wa	; F6F1CC  ld (0x60341e),WA
	xor	xwa, xwa	; F6F1D1  xor XWA,XWA
	ld	(12304:16), xwa	; F6F1D3  ld (0x3010),XWA
	call	T_Seq_RequestRewind	; F6F1D7  call 0xf409e0
OldCopy_F7ABDB:
	ret	; F6F1DB  ret
OldCopy_TrackClear_ReturnToStageZero:
	and	(UI_RequestBits:16), 0xf6	; F6F1DC  and (0x2075),0xf6
	cp	(UI_ScreenStage:16), 0x01	; F6F1E1  cp (0x207e),0x01
	jr	z, OldCopy_F7ABEA	; F6F1E6  jr Z,0xf6f1ea
	jr	OldCopy_F7AC06	; F6F1E8  jr T,0xf6f206
OldCopy_F7ABEA:
	ld	(UI_ScreenStage:16), 0	; F6F1EA  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F6F1EF  or (0x2071),0x10
	ldw	(3518:16), 0	; F6F1F4  ld (0x0dbe),0x0000
	ldw	(8542:16), 0	; F6F1FA  ld (0x215e),0x0000
	orw	(0x212e:16), 0x0100	; F6F200  or (0x212e),0x0100
OldCopy_F7AC06:
	ret	; F6F206  ret
OldCopy_TrackClear_LcdKeyRow2:
	and	(UI_RequestBits:16), 0xf6	; F6F207  and (0x2075),0xf6
	cp	(UI_ScreenStage:16), 0x01	; F6F20C  cp (0x207e),0x01
	jr	z, OldCopy_F7AC1E	; F6F211  jr Z,0xf6f21e
	ld	(UI_ScreenStage:16), 1	; F6F213  ld (0x207e),0x01
	or	(UI_Request_Hi:16), 0x10	; F6F218  or (0x2071),0x10
	ret	; F6F21D  ret
OldCopy_F7AC1E:
	cpw	(0x0dbe:16), 0x0000	; F6F21E  cp (0x0dbe),0x0000
	jr	nz, OldCopy_F7AC32	; F6F224  jr NZ,0xf6f232
	ld	(UI_ScreenStage:16), 0	; F6F226  ld (0x207e),0x00
	or	(UI_Request_Hi:16), 0x10	; F6F22B  or (0x2071),0x10
	jr	OldCopy_F7AC9C	; F6F230  jr T,0xf6f29c
OldCopy_F7AC32:
	xor	c, c	; F6F232  xor C,C
	ld	hl, (3518:16)	; F6F234  ld HL,(0x0dbe)
OldCopy_F7AC38:
	ldfr_werp	hl, 0x3e	; F6F238  ld QHL3,HL
	ld	a, c	; F6F23B  ld A,C
	scf	; F6F23D  scf
	xorcfw_erp	0x3e	; F6F23E  xorcf A,QHL3
	jr	c, OldCopy_F7AC5D	; F6F241  jr C,0xf6f25d
	ld	a, c	; F6F243  ld A,C
	inc	1, a	; F6F245  inc 1,A
	ld	(3184:16), a	; F6F247  ld (0x0c70),A
	pushw	bc	; F6F24B  push BC
	pushw	hl	; F6F24C  push HL
	ld	(UI_StatusCode:16), 255	; F6F24D  ld (0x2880),0xff
	ld	(BStore_ErrorCode:16), 0	; F6F252  ld (0x0d4a),0x00
	call	T_SongEdit_ClearTrack_Call	; F6F257  call 0xf426e4
	popw	hl	; F6F25B  pop HL
	popw	bc	; F6F25C  pop BC
OldCopy_F7AC5D:
	inc	1, c	; F6F25D  inc 1,C
	cp	c, 15	; F6F25F  cp C,0x0f
	jr	ule, OldCopy_F7AC38	; F6F262  jr ULE,0xf6f238
	ld	bc, (3518:16)	; F6F264  ld BC,(0x0dbe)
	ld	wa, (12304:16)	; F6F268  ld WA,(0x3010)
	and	bc, wa	; F6F26C  and BC,WA
	xor	(0x3010:16), bc	; F6F26E  xor (0x3010),BC
	ld	wa, (3518:16)	; F6F272  ld WA,(0x0dbe)
	ld	(3654:16), wa	; F6F276  ld (0x0e46),WA
	ldw	(3518:16), 0	; F6F27A  ld (0x0dbe),0x0000
	ldw	(8542:16), 0	; F6F280  ld (0x215e),0x0000
	orw	(0x212e:16), 0x0100	; F6F286  or (0x212e),0x0100
	ld	(UI_ScreenStage:16), 0	; F6F28C  ld (0x207e),0x00
	ld	(UI_StatusCode:16), 35	; F6F291  ld (0x2880),0x23
	ldw	(UI_Request:16), 16555	; F6F296  ld (0x2070),0x40ab
OldCopy_F7AC9C:
	ret	; F6F29C  ret
OldCopy_TrackMerge_InitFields:
	calr	TrackMerge_LoadSavedFields - 0xBA00	; F6F29D  calr 0xf6f5d8
	ld	(3514:16), 1	; F6F2A0  ld (0x0dba),0x01
	ret	; F6F2A5  ret
OldCopy_TrackMerge_OnLeave:
	cp	(UI_ScreenLatch:16), 0x1f	; F6F2A6  cp (0x207a),0x1f
	jr	z, OldCopy_F7ACC4	; F6F2AB  jr Z,0xf6f2c4
	ld	xwa, (12304:16)	; F6F2AD  ld XWA,(0x3010)
	or	(0x360c:16), xwa	; F6F2B1  or (0x360c),XWA
	ld	(6304798:24), xwa	; F6F2B5  ld (0x60341e),XWA
	xor	xwa, xwa	; F6F2BA  xor XWA,XWA
	ld	(12304:16), xwa	; F6F2BC  ld (0x3010),XWA
	call	T_Seq_RequestRewind	; F6F2C0  call 0xf409e0
OldCopy_F7ACC4:
	ret	; F6F2C4  ret
OldCopy_TrackMerge_SelectField1:
	ld	(3514:16), 1	; F6F2C5  ld (0x0dba),0x01
	or	(UI_RequestBits:16), 0x09	; F6F2CA  or (0x2075),0x09
	ret	; F6F2CF  ret
OldCopy_TrackMerge_SelectField2:
	ld	(3514:16), 2	; F6F2D0  ld (0x0dba),0x02
	or	(UI_RequestBits:16), 0x09	; F6F2D5  or (0x2075),0x09
	ret	; F6F2DA  ret
OldCopy_TrackMerge_SelectField3:
	ld	(3514:16), 3	; F6F2DB  ld (0x0dba),0x03
	or	(UI_RequestBits:16), 0x09	; F6F2E0  or (0x2075),0x09
	ret	; F6F2E5  ret
OldCopy_TrackMerge_StepSelectedFieldUp:
	ld	(3150:16), w	; F6F2E6  ld (0x0c4e),W
	and	w, 128	; F6F2EA  and W,0x80
	ld	(3151:16), w	; F6F2ED  ld (0x0c4f),W
	cp	(0x0dba:16), 0x01	; F6F2F1  cp (0x0dba),0x01
	jr	nz, OldCopy_F7ACFD	; F6F2F6  jr NZ,0xf6f2fd
	calr	OldCopy_TrackMerge_StepSourceTrack1	; F6F2F8  calr 0xf6f342
	jr	OldCopy_F7AD13	; F6F2FB  jr T,0xf6f313
OldCopy_F7ACFD:
	cp	(0x0dba:16), 0x02	; F6F2FD  cp (0x0dba),0x02
	jr	nz, OldCopy_F7AD09	; F6F302  jr NZ,0xf6f309
	calr	OldCopy_TrackMerge_StepSourceTrack2	; F6F304  calr 0xf6f38f
	jr	OldCopy_F7AD13	; F6F307  jr T,0xf6f313
OldCopy_F7AD09:
	cp	(0x0dba:16), 0x03	; F6F309  cp (0x0dba),0x03
	jr	nz, OldCopy_F7AD13	; F6F30E  jr NZ,0xf6f313
	calr	OldCopy_TrackMerge_StepDestTrack	; F6F310  calr 0xf6f3dc
OldCopy_F7AD13:
	ret	; F6F313  ret
OldCopy_TrackMerge_StageZero_SoftKeyCol5:
	ld	(3150:16), w	; F6F314  ld (0x0c4e),W
	and	w, 128	; F6F318  and W,0x80
	ld	(3151:16), w	; F6F31B  ld (0x0c4f),W
	cp	(0x0dba:16), 0x01	; F6F31F  cp (0x0dba),0x01
	jr	nz, OldCopy_F7AD2B	; F6F324  jr NZ,0xf6f32b
	calr	OldCopy_TrackMerge_StepSourceTrack1	; F6F326  calr 0xf6f342
	jr	OldCopy_F7AD41	; F6F329  jr T,0xf6f341
OldCopy_F7AD2B:
	cp	(0x0dba:16), 0x02	; F6F32B  cp (0x0dba),0x02
	jr	nz, OldCopy_F7AD37	; F6F330  jr NZ,0xf6f337
	calr	OldCopy_TrackMerge_StepSourceTrack2	; F6F332  calr 0xf6f38f
	jr	OldCopy_F7AD41	; F6F335  jr T,0xf6f341
OldCopy_F7AD37:
	cp	(0x0dba:16), 0x03	; F6F337  cp (0x0dba),0x03
	jr	nz, OldCopy_F7AD41	; F6F33C  jr NZ,0xf6f341
	calr	OldCopy_TrackMerge_StepDestTrack	; F6F33E  calr 0xf6f3dc
OldCopy_F7AD41:
	ret	; F6F341  ret
OldCopy_TrackMerge_StepSourceTrack1:
	or	(UI_RequestBits:16), 0x09	; F6F342  or (0x2075),0x09
	ld	a, (3091:16)	; F6F347  ld A,(0x0c13)
	cp	(0x0c4f:16), 0x80	; F6F34B  cp (0x0c4f),0x80
	jr	z, OldCopy_F7AD6B	; F6F350  jr Z,0xf6f36b
OldCopy_F7AD52:
	inc	1, a	; F6F352  inc 1,A
	cp	a, 16	; F6F354  cp A,0x10
	jr	ule, OldCopy_F7AD63	; F6F357  jr ULE,0xf6f363
	ld	a, 1:opc	; F6F359  ld A,0x01
	cp	a, (0x0c14:16)	; F6F35B  cp A,(0x0c14)
	jr	nz, OldCopy_F7AD81	; F6F35F  jr NZ,0xf6f381
	jr	OldCopy_F7AD52	; F6F361  jr T,0xf6f352
OldCopy_F7AD63:
	cp	a, (0x0c14:16)	; F6F363  cp A,(0x0c14)
	jr	z, OldCopy_F7AD52	; F6F367  jr Z,0xf6f352
	jr	OldCopy_F7AD81	; F6F369  jr T,0xf6f381
OldCopy_F7AD6B:
	dec	1, a	; F6F36B  dec 1,A
	cp	a, 0:i3	; F6F36D  cp A,0
	jr	ugt, OldCopy_F7AD7B	; F6F36F  jr UGT,0xf6f37b
	ld	a, 16:opc	; F6F371  ld A,0x10
	cp	a, (0x0c14:16)	; F6F373  cp A,(0x0c14)
	jr	nz, OldCopy_F7AD81	; F6F377  jr NZ,0xf6f381
	jr	OldCopy_F7AD6B	; F6F379  jr T,0xf6f36b
OldCopy_F7AD7B:
	cp	a, (0x0c14:16)	; F6F37B  cp A,(0x0c14)
	jr	z, OldCopy_F7AD6B	; F6F37F  jr Z,0xf6f36b
OldCopy_F7AD81:
	ld	(3091:16), a	; F6F381  ld (0x0c13),A
	ld	(6304857:24), a	; F6F385  ld (0x603459),A
	ld	(DisplayListB_Stage:16), a	; F6F38A  ld (0x12f6),A
	ret	; F6F38E  ret
OldCopy_TrackMerge_StepSourceTrack2:
	or	(UI_RequestBits:16), 0x09	; F6F38F  or (0x2075),0x09
	ld	a, (3092:16)	; F6F394  ld A,(0x0c14)
	cp	(0x0c4f:16), 0x80	; F6F398  cp (0x0c4f),0x80
	jr	z, OldCopy_F7ADB8	; F6F39D  jr Z,0xf6f3b8
OldCopy_F7AD9F:
	inc	1, a	; F6F39F  inc 1,A
	cp	a, 16	; F6F3A1  cp A,0x10
	jr	ule, OldCopy_F7ADB0	; F6F3A4  jr ULE,0xf6f3b0
	ld	a, 1:opc	; F6F3A6  ld A,0x01
	cp	a, (0x0c13:16)	; F6F3A8  cp A,(0x0c13)
	jr	nz, OldCopy_F7ADCE	; F6F3AC  jr NZ,0xf6f3ce
	jr	OldCopy_F7AD9F	; F6F3AE  jr T,0xf6f39f
OldCopy_F7ADB0:
	cp	a, (0x0c13:16)	; F6F3B0  cp A,(0x0c13)
	jr	z, OldCopy_F7AD9F	; F6F3B4  jr Z,0xf6f39f
	jr	OldCopy_F7ADCE	; F6F3B6  jr T,0xf6f3ce
OldCopy_F7ADB8:
	dec	1, a	; F6F3B8  dec 1,A
	cp	a, 0:i3	; F6F3BA  cp A,0
	jr	ugt, OldCopy_F7ADC8	; F6F3BC  jr UGT,0xf6f3c8
	ld	a, 16:opc	; F6F3BE  ld A,0x10
	cp	a, (0x0c13:16)	; F6F3C0  cp A,(0x0c13)
	jr	nz, OldCopy_F7ADCE	; F6F3C4  jr NZ,0xf6f3ce
	jr	OldCopy_F7ADB8	; F6F3C6  jr T,0xf6f3b8
OldCopy_F7ADC8:
	cp	a, (0x0c13:16)	; F6F3C8  cp A,(0x0c13)
	jr	z, OldCopy_F7ADB8	; F6F3CC  jr Z,0xf6f3b8
OldCopy_F7ADCE:
	ld	(3092:16), a	; F6F3CE  ld (0x0c14),A
	ld	(6304858:24), a	; F6F3D2  ld (0x60345a),A
	ld	(DisplayListB_Stage+1:16), a	; F6F3D7  ld (0x12f7),A
	ret	; F6F3DB  ret
OldCopy_TrackMerge_StepDestTrack:
	ld	a, (3093:16)	; F6F3DC  ld A,(0x0c15)
	ld	l, 1:opc	; F6F3E0  ld L,0x01
	ld	h, 16:opc	; F6F3E2  ld H,0x10
	calr	SeqJob_StepValueInRange - 0xBA60	; F6F3E4  calr 0xf7127b
	ld	(3093:16), a	; F6F3E7  ld (0x0c15),A
	ld	(6304859:24), a	; F6F3EB  ld (0x60345b),A
	ld	(DisplayListB_Stage+2:16), a	; F6F3F0  ld (0x12f8),A
	ret	; F6F3F4  ret
OldCopy_TrackMerge_ReturnToStageZero:
	cp	(UI_ScreenStage:16), 0x01	; F6F3F5  cp (0x207e),0x01
	jr	nz, TrackMerge_ReturnToStageZero_Return - 0xBA00	; F6F3FA  jr NZ,0xf6f40b
	.byte	0xC1, 0x75, 0x20, 0x3C	; F6F3FC  the first 4 of the 5 bytes of `and (0x2075),0xf6` (live 0xF7ADFC); this build's MidiFileLoad_LcdKeyRow1 begins at 0xF6F400


; --------------------------------------------------------------------------
; MidiFileLoad_LcdKeyRow1
; Called from: T_MidiFileLoad_LcdKeyRow1 (x1)
; Touches: nothing with an absolute address
; Evidence (THUNK): a `jp` slot of the 0xF40000 routine directory holds `jp`
;                   to this address, so the firmware's own routine table
;                   names it.  Only TWO slots reach this module -- T_MidiFileLoad_LcdKeyRow1
;                   and T_MidiFileSave_WriteSeqBankSmf -- which is why the thunk-run frontier
;                   ranks it thirteenth and why it was chosen with a
;                   different tool.  0xF6F400 is an instruction boundary of
;                   this transcription, re-asserted on every emit.  The name
;                   IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MidiFileLoad_LcdKeyRow1: the LcdKeyRow1 action of MidiFileLoad -- called only by LcdKeyRow1_MidiFileLoad.
MidiFileLoad_LcdKeyRow1:		; <- T_MidiFileLoad_LcdKeyRow1
	jp	MidiFileLoad_SelectSeqBankAndReadSmf	; F6F400  jp 0xf6f408

; --------------------------------------------------------------------------
; MidiFileSave_WriteSeqBankSmf
; Called from: T_MidiFileSave_WriteSeqBankSmf (x2)
; Touches: nothing with an absolute address
; Evidence (THUNK): a `jp` slot of the 0xF40000 routine directory holds `jp`
;                   to this address, so the firmware's own routine table
;                   names it.  Only TWO slots reach this module -- T_MidiFileLoad_LcdKeyRow1
;                   and T_MidiFileSave_WriteSeqBankSmf -- which is why the thunk-run frontier
;                   ranks it thirteenth and why it was chosen with a
;                   different tool.  0xF6F404 is an instruction boundary of
;                   this transcription, re-asserted on every emit.  The name
;                   IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MidiFileSave_WriteSeqBankSmf: `jp MidiFileSave_SelectSeqBankAndWriteSmf`: unless Disk_SeqBank is already BStore_CurrentBank, saves the
;   workspace to the current bank, makes Disk_SeqBank current and loads it (MidiFile_LoadWorkspaceFromBank), applies its beats per bar;
;   then Smf_WriteFile (writes the song as a Standard MIDI File) and re-inits the playback rings. Run by the MIDI FILE
;   SAVE row keys. Twin of MidiFileLoad_LcdKeyRow1's load path. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_i.json)
MidiFileSave_WriteSeqBankSmf:		; <- T_MidiFileSave_WriteSeqBankSmf
	jp	MidiFileSave_SelectSeqBankAndWriteSmf	; F6F404  jp 0xf6f440

; --------------------------------------------------------------------------
; MidiFileLoad_SelectSeqBankAndReadSmf
; Called from: in-module: 0xF6F400
; Touches: (0x272B) (0x360A) (0x360B)
; Calls:   MidiFile_SaveWorkspaceToBank MidiFile_LoadWorkspaceFromBank T_Seq_ApplySongBeatsPerBar Smf_ReadFile_Entry T_Ring601850_Init T_SeqBufRing_Init
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF6F408 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MidiFileLoad_SelectSeqBankAndReadSmf: Saves the workspace to the current bank (MidiFile_SaveWorkspaceToBank);
;   unless Disk_SeqBank is already BStore_CurrentBank, makes it current, loads it (MidiFile_LoadWorkspaceFromBank) and applies its beats
;   per bar; then Smf_ReadFile (via Smf_ReadFile_Entry), re-inits the playback rings and clears (0x360B) bit 0. The
;   target of MidiFileLoad_LcdKeyRow1 (`jp`); load-side twin of MidiFileSave_WriteSeqBankSmf's body. Basis: caller +
;   body + twin. (notes/naming-pilot-2026-10-06/proposals_wave6_v.json)
MidiFileLoad_SelectSeqBankAndReadSmf:
	push	xiz	; F6F408  push XIZ
	push	xix	; F6F409  push XIX
	push	xhl	; F6F40A  push XHL
	push	xde	; F6F40B  push XDE
	call	MidiFile_SaveWorkspaceToBank	; F6F40C  call 0xf6f476
	ld	a, (Disk_SeqBank:16)	; F6F410  ld A,(0x272b)
	cp	a, (BStore_CurrentBank:16)	; F6F414  cp A,(0x360a)
	jr	z, MidiFileLoad_SelectSeqBankAndReadSmf_Skip	; F6F418  jr Z,0xf6f42a
	ld	a, (Disk_SeqBank:16)	; F6F41A  ld A,(0x272b)
	ld	(BStore_CurrentBank:16), a	; F6F41E  ld (0x360a),A
	call	MidiFile_LoadWorkspaceFromBank	; F6F422  call 0xf6f4a3
	call	T_Seq_ApplySongBeatsPerBar	; F6F426  call 0xf40ac8
MidiFileLoad_SelectSeqBankAndReadSmf_Skip:
	call	Smf_ReadFile_Entry	; F6F42A  call 0xf6f526
	call	T_Ring601850_Init	; F6F42E  call 0xf41e6c
	call	T_SeqBufRing_Init	; F6F432  call 0xf41d94
	and	(0x360b:16), 0xfe	; F6F436  and (0x360b),0xfe
	pop	xde	; F6F43B  pop XDE
	pop	xhl	; F6F43C  pop XHL
	pop	xix	; F6F43D  pop XIX
	pop	xiz	; F6F43E  pop XIZ
	ret	; F6F43F  ret

; --------------------------------------------------------------------------
; MidiFileSave_SelectSeqBankAndWriteSmf
; Called from: in-module: 0xF6F404
; Touches: (0x272B) (0x360A)
; Calls:   MidiFile_SaveWorkspaceToBank MidiFile_LoadWorkspaceFromBank Seq_RewindAndApplySongGmAndParams T_Seq_ApplySongBeatsPerBar Smf_WriteFile_Veneer T_Ring601850_Init
;          T_SeqBufRing_Init
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF6F440 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MidiFileSave_SelectSeqBankAndWriteSmf: Unless Disk_SeqBank is already BStore_CurrentBank: saves the workspace to the
;   current bank, makes Disk_SeqBank current, loads it (MidiFile_LoadWorkspaceFromBank), rewinds/re-posts its GM mode (Seq_RewindAndApplySongGmAndParams) and
;   applies its beats per bar; then Smf_WriteFile (via Smf_WriteFile_Veneer) and re-inits the playback rings. The body
;   behind MidiFileSave_WriteSeqBankSmf (`jp`), whose header describes it; save-side twin of
;   MidiFileLoad_SelectSeqBankAndReadSmf. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave6_v.json)
MidiFileSave_SelectSeqBankAndWriteSmf:
	push	xiz	; F6F440  push XIZ
	push	xix	; F6F441  push XIX
	push	xhl	; F6F442  push XHL
	push	xde	; F6F443  push XDE
	ld	a, (Disk_SeqBank:16)	; F6F444  ld A,(0x272b)
	cp	a, (BStore_CurrentBank:16)	; F6F448  cp A,(0x360a)
	jr	z, MidiFileSave_SelectSeqBankAndWriteSmf_Skip	; F6F44C  jr Z,0xf6f465
	call	MidiFile_SaveWorkspaceToBank	; F6F44E  call 0xf6f476
	ld	a, (Disk_SeqBank:16)	; F6F452  ld A,(0x272b)
	ld	(BStore_CurrentBank:16), a	; F6F456  ld (0x360a),A
	call	MidiFile_LoadWorkspaceFromBank	; F6F45A  call 0xf6f4a3
	calr	Seq_RewindAndApplySongGmAndParams	; F6F45E  calr 0xf6f4f2
	call	T_Seq_ApplySongBeatsPerBar	; F6F461  call 0xf40ac8
MidiFileSave_SelectSeqBankAndWriteSmf_Skip:
	call	Smf_WriteFile_Veneer	; F6F465  call 0xf73840
	call	T_Ring601850_Init	; F6F469  call 0xf41e6c
	call	T_SeqBufRing_Init	; F6F46D  call 0xf41d94
	pop	xde	; F6F471  pop XDE
	pop	xhl	; F6F472  pop XHL
	pop	xix	; F6F473  pop XIX
	pop	xiz	; F6F474  pop XIZ
	ret	; F6F475  ret

; --------------------------------------------------------------------------
; MidiFile_SaveWorkspaceToBank
; Called from: in-module: 0xF6F40C 0xF6F44E
; Touches: (0x360A) (0x360C)  |  0x603400 0x610000
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF6F476 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MidiFile_SaveWorkspaceToBank: Saves the 3 KiB sequencer workspace 0x603400 to its bank copy 0x610000 +
;   BStore_CurrentBank * 3072 (storing (0x360C) at 0x60341E first): the SMF file module's own copy of
;   BStore_Workspace_SaveToBank (prom_b 0xF64BE3; all 15 instructions equal), the save-side twin of
;   MidiFile_LoadWorkspaceFromBank. Live: MidiFileLoad_SelectSeqBankAndReadSmf and its save twin call it, and
;   0xF6F476 lies past the older build's block 0xF6F000-0xF6F3FF (banner above), so it is not an OldCopy_.
;   Basis: callers + body + twin.
MidiFile_SaveWorkspaceToBank:
	ld	xwa, (13836:16)	; F6F476  ld XWA,(0x360c)
	ld	(6304798:24), xwa	; F6F47A  ld (0x60341e),XWA
	ld	xix, 6356992	; F6F47F  ld XIX,0x00610000
	xor	xwa, xwa	; F6F484  xor XWA,XWA
	xor	xhl, xhl	; F6F486  xor XHL,XHL
	ld	l, (BStore_CurrentBank:16)	; F6F488  ld L,(0x360a)
	ld	a, l	; F6F48C  ld A,L
	sla	xhl, 11	; F6F48E  sla 0x0b,XHL
	sla	xwa, 10	; F6F491  sla 0x0a,XWA
	add	xhl, xwa	; F6F494  add XHL,XWA
	add	xix, xhl	; F6F496  add XIX,XHL
	ld	xiy, 6304768	; F6F498  ld XIY,0x00603400
	ldw	bc, 3072	; F6F49D  ld BC,0x0c00
	ldir85	; F6F4A0  ldir
	ret	; F6F4A2  ret

; --------------------------------------------------------------------------
; MidiFile_LoadWorkspaceFromBank
; Called from: in-module: 0xF6F422 0xF6F45A
; Touches: (0x0E2B) (0x0E2D) (0x360A) (0x360C)  |  0x603400 0x610000
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF6F4A3 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MidiFile_LoadWorkspaceFromBank: Loads the 3 KiB workspace 0x603400 from bank copy 0x610000 + BStore_CurrentBank *
;   0xC00 (ldir) while keeping the heap's live free list (BStore_FreeHead / BStore_FreeCount saved in
;   (0x0E2B)/(0x0E2D) and put back), then (0x360C) := workspace +0x1E: BStore_LoadSongFromCurrentBank's save +
;   BStore_Workspace_LoadFromBank in one. MIDI FILE load / save run it after making Disk_SeqBank current. Basis:
;   callers + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
MidiFile_LoadWorkspaceFromBank:
	ld	wa, (BStore_FreeHead:24)	; F6F4A3  ld WA,(0x6034b8)
	ld	(3627:16), wa	; F6F4A8  ld (0x0e2b),WA
	ld	wa, (BStore_FreeCount:24)	; F6F4AC  ld WA,(0x6034ba)
	ld	(3629:16), wa	; F6F4B1  ld (0x0e2d),WA
	xor	xwa, xwa	; F6F4B5  xor XWA,XWA
	ld	a, (BStore_CurrentBank:16)	; F6F4B7  ld A,(0x360a)
	ld	xix, xwa	; F6F4BB  ld XIX,XWA
	sla	xwa, 11	; F6F4BD  sla 0x0b,XWA
	sla	xix, 10	; F6F4C0  sla 0x0a,XIX
	add	xwa, xix	; F6F4C3  add XWA,XIX
	ld	xiy, 6356992	; F6F4C5  ld XIY,0x00610000
	add	xiy, xwa	; F6F4CA  add XIY,XWA
	ld	xix, 6304768	; F6F4CC  ld XIX,0x00603400
	ldw	bc, 3072	; F6F4D1  ld BC,0x0c00
	ldir85	; F6F4D4  ldir
	ld	wa, (3627:16)	; F6F4D6  ld WA,(0x0e2b)
	ld	(BStore_FreeHead:24), wa	; F6F4DA  ld (0x6034b8),WA
	ld	wa, (3629:16)	; F6F4DF  ld WA,(0x0e2d)
	ld	(BStore_FreeCount:24), wa	; F6F4E3  ld (0x6034ba),WA
	ld	xwa, (6304798:24)	; F6F4E8  ld XWA,(0x60341e)
	ld	(13836:16), xwa	; F6F4ED  ld (0x360c),XWA
	ret	; F6F4F1  ret

; --------------------------------------------------------------------------
; Seq_RewindAndApplySongGmAndParams
; Called from: in-module: 0xF6F45E
; Touches: (0x124C) (0x7F4D)
; Calls:   T_Seq_RequestRewind T_Queue2C00_AppendRegs T_Queue2C00_DrainPassAB T_F42578
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6F4F2 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_RewindAndApplySongGmAndParams: Seq_RequestRewind; GM mode (0x7F4D) bit 2 := the song's GM flag ((0x6034C6) ==
;   0xFF), (0x124C) := 1 and posts record 0x91 byte 3 = 4 / 0 (Queue2C00_AppendRegs, Queue2C00_DrainPassAB); then
;   T_F42578, the song parameter-image restore. MidiFileSave_SelectSeqBankAndWriteSmf runs it after loading
;   Disk_SeqBank; the GM step of SongGmFlag_ApplyAndRebuildRouting / Seq_ApplyLoadedSongSetup without the disagreement
;   test. Basis: caller + body + twins. (notes/naming-pilot-2026-10-06/proposals_wave7_y.json)
Seq_RewindAndApplySongGmAndParams:
	call	T_Seq_RequestRewind	; F6F4F2  call 0xf409e0
	cp	(0x6034c6:24), 0xff	; F6F4F6  cp (0x6034c6),0xff
	jr	z, Seq_RewindAndApplySongGmAndParams_Skip	; F6F4FC  jr Z,0xf6f507
	and	(0x7f4d:16), 0xfb	; F6F4FE  and (0x7f4d),0xfb
	xor	a, a	; F6F503  xor A,A
	jr	Seq_RewindAndApplySongGmAndParams_Join	; F6F505  jr T,0xf6f50e
Seq_RewindAndApplySongGmAndParams_Skip:
	or	(0x7f4d:16), 0x04	; F6F507  or (0x7f4d),0x04
	ld	a, 4:opc	; F6F50C  ld A,0x04
Seq_RewindAndApplySongGmAndParams_Join:
	ld	(4684:16), 1	; F6F50E  ld (0x124c),0x01
	ld	e, 145:opc	; F6F513  ld E,0x91
	ld	d, 3:opc	; F6F515  ld D,0x03
	ld	w, 4:opc	; F6F517  ld W,0x04
	call	T_Queue2C00_AppendRegs	; F6F519  call 0xf40f38
	call	T_Queue2C00_DrainPassAB	; F6F51D  call 0xf40018
	call	T_F42578	; F6F521  call 0xf42578
	ret	; F6F525  ret

; --------------------------------------------------------------------------
; Smf_ReadFile_Entry -- 0xF6F526
; Called from: in-module: 0xF6F42A
; Touches: nothing with an absolute address
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF6F526 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.
; Name:    Smf_ReadFile_Entry -- named 2026-08-31.
; Evidence (BRANCH): the whole routine is `jr 0xF6F530`, a two-byte hop over the
;          eight-byte tag table SmfChunkTags that sits between it and the body.
;          Its only call site in either image is `call 0xf6f526` at 0xF6F42A and
;          no thunk slot names it.
; ⚠ CORRECTED 2026-08-31: this header used to end `Unknown: what the routine is
;          FOR.  Left as sub_XXXXXX with the gap stated`.
; Unknown: what 0xF6F42A is.
; --------------------------------------------------------------------------
Smf_ReadFile_Entry:
	jr	Smf_ReadFile	; F6F526  jr T,0xf6f530

; --------------------------------------------------------------------------
; SmfChunkTags -- 0xF6F528, 8 bytes this block could not split.  No content rule framed
;                it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or ASCII
;                -- and the code walk never reached it from a thunk slot, a
;                proven call site, an opcode-anchored call or an entry of a
;                table the firmware transfers to.  So it is emitted as bytes
;                rather than guessed.
; Contains: printable bytes |MThdMTrk|
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XIY,0x00f6f528` at
;          0xF6F59B (operand field 1 byte in)
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; Name:    SmfChunkTags -- named 2026-08-31.
; Evidence (STRING + USE): the eight bytes are `MThd` followed by `MTrk`, the
;          Standard MIDI File header-chunk and track-chunk tags, and the reader
;          uses them as two four-byte compare templates: `ld XIY,0x00f6f528` at
;          0xF6F59B for the header and `ld XIY,0x00f6f52c` -- the same object,
;          plus four -- at 0xF6F658 for the track.  Both are checked by
;          notes/prom_b_smf_reader.py.
; ⚠ CORRECTED 2026-08-31: this header's `Unknown: everything about it except its
;          bytes` no longer holds; its two readers are named above.
; --------------------------------------------------------------------------
SmfChunkTags:
	.byte	0x4D, 0x54, 0x68, 0x64, 0x4D, 0x54, 0x72, 0x6B	; F6F528  [0..7]

; --------------------------------------------------------------------------
; Smf_ReadFile -- 0xF6F530-0xF6F8A4, 881 bytes
; ★ LABEL ADDED 2026-08-31, not renamed: this routine had none.  The eight
;   tag bytes SmfChunkTags end at 0xF6F52F and the code after them was emitted
;   without a label, so every tool that walks this file by label attributed the
;   whole reader to a DATA object.
; Extent:  bracketed by a flag, not guessed.  0xF6F530 opens
;          `or (0x21E8),0x80` and 0xF6F89F closes `and (0x21E8),0x7F` -- the
;          same bit of the same byte -- four instructions before the `ret` at
;          0xF6F8A4, which is the last row before the next label.
; Called from: `call 0xf6f526` at 0xF6F42A, through the two-byte hop
;          Smf_ReadFile_Entry.  No thunk slot names either address.
; Reads:   one byte at a time through InputStream_GetByte (0xF7138F), from the
;          1,024-byte window at 0x60A700-0x60AAFF whose cursor is (0x1088).
; Evidence (FORMAT): it is a STANDARD MIDI FILE reader, and the case is
;          notes/prom_b_smf_reader.py's 40 checks, every one re-derived from the
;          ROM: the four-byte compare against `MThd` at 0xF6F59B, the retry at
;          +0x80 and the 0x31 error code, the big-endian format / ntrks /
;          division fields landing in (0x1078)-(0x107D), the `MTrk` compare at
;          0xF6F658, and all three of the SMF specification's own rejections --
;          a negative division (SMPTE timecode), a zero division, and a format
;          neither 0 nor 1.
; Unknown: what it does with the events after the header, and which of the RAM
;          bytes it clears at 0xF6F537-0xF6F54F belong to the sequencer.
; --------------------------------------------------------------------------
Smf_ReadFile:

	or	(0x21e8:16), 0x80	; F6F530  or (0x21e8),0x80
	xor	a, a	; F6F535  xor A,A
	ld	(4664:16), a	; F6F537  ld (0x1238),A
	ld	(4665:16), a	; F6F53B  ld (0x1239),A
	ld	(4683:16), a	; F6F53F  ld (0x124b),A
	ld	(4684:16), a	; F6F543  ld (0x124c),A
	ld	(4112:16), a	; F6F547  ld (0x1010),A
	ld	(4711:16), a	; F6F54B  ld (0x1267),A
	ld	(4992:16), 255	; F6F54F  ld (0x1380),0xff
	calr	Smf_ResetRpnState	; F6F554  calr 0xf6f90c
	calr	Smf_ClearPendingNoteSlots	; F6F557  calr 0xf6fb38
	calr	Smf_ClearChannelBankSelects	; F6F55A  calr 0xf6f929
	xor	l, l	; F6F55D  xor L,L
	calr	InputStream_OpenAndReadFirstBlock	; F6F55F  calr 0xf7659b
	ld	w, a	; F6F562  ld W,A
	ld	(InputStream_Status:16), w	; F6F564  ld (0x124a),W
	cp	w, 4:i3	; F6F568  cp W,4
	jrl	z, Smf_ReadFile_Join3	; F6F56A  jrl Z,0xf6f7ad
	cp	w, 8	; F6F56D  cp W,0x08
	jrl	z, Smf_ReadFile_Join3	; F6F570  jrl Z,0xf6f7ad
	cp	w, 5:i3	; F6F573  cp W,5
	jrl	z, Smf_ReadFile_Join3	; F6F575  jrl Z,0xf6f7ad
	ld	(UI_StatusCode:16), 38	; F6F578  ld (0x2880),0x26
	call	T_MessageScreen_Paint	; F6F57D  call 0xf41600
	ldw	(4680:16), 1	; F6F581  ld (0x1248),0x0001
	call	T_Var2216_SetW145C_Call	; F6F587  call 0xf42600
	call	T_DiskProgress_PrintDotForSmf	; F6F58B  call 0xf42604
	ld	xwa, 6334208	; F6F58F  ld XWA,0x0060a700
	ld	(InputStream_Cursor:16), xwa	; F6F594  ld (0x1088),XWA
Smf_ReadFile_Join:
	ldw	bc, 4	; F6F598  ld BC,0x0004
	ld	xiy, SmfChunkTags	; F6F59B  ld XIY,0x00f6f528
	pushw	bc	; F6F5A0  push BC
	push	xiy	; F6F5A1  push XIY
	calr	InputStream_GetByte	; F6F5A2  calr 0xf7138f
	pop	xiy	; F6F5A5  pop XIY
	popw	bc	; F6F5A6  pop BC
	cp	a, (xiy+)	; F6F5A7  cp A,(XIY+)
	jr	z, Smf_ReadFile_Skip2	; F6F5AA  jr Z,0xf6f5d0
	inc	1, (4711:16)	; F6F5AC  inc 1,(0x1267)
	cp	(0x1267:16), 0x01	; F6F5B0  cp (0x1267),0x01
	jr	nz, Smf_ReadFile_Skip	; F6F5B5  jr NZ,0xf6f5c8
	ld	xwa, 6334208	; F6F5B7  ld XWA,0x0060a700
	add	xwa, 128	; F6F5BC  add XWA,0x00000080
	ld	(InputStream_Cursor:16), xwa	; F6F5C2  ld (0x1088),XWA
	jr	Smf_ReadFile_Join	; F6F5C6  jr T,0xf6f598
Smf_ReadFile_Skip:
	ld	(UI_StatusCode:16), 49	; F6F5C8  ld (0x2880),0x31
	jrl	Smf_ReadFile_Join4	; F6F5CD  jrl T,0xf6f7dd
Smf_ReadFile_Skip2:
	djnz16	bc, -51	; F6F5D0  djnz BC,0xf6f5a0
	ldw	bc, 5	; F6F5D3  ld BC,0x0005
	pushw	bc	; F6F5D6  push BC
	calr	InputStream_GetByte	; F6F5D7  calr 0xf7138f
	popw	bc	; F6F5DA  pop BC
	djnz16	bc, -8	; F6F5DB  djnz BC,0xf6f5d6
	ld	(4217:16), a	; F6F5DE  ld (0x1079),A
	calr	InputStream_GetByte	; F6F5E2  calr 0xf7138f
	ld	(Smf_Format:16), a	; F6F5E5  ld (0x1078),A
	calr	InputStream_GetByte	; F6F5E9  calr 0xf7138f
	ld	(4219:16), a	; F6F5EC  ld (0x107b),A
	calr	InputStream_GetByte	; F6F5F0  calr 0xf7138f
	ld	(Smf_TrackCount:16), a	; F6F5F3  ld (0x107a),A
	calr	InputStream_GetByte	; F6F5F7  calr 0xf7138f
	ld	(4221:16), a	; F6F5FA  ld (0x107d),A
	bit	7, a	; F6F5FE  bit 0x07,A
	jrl	nz, Smf_ReadFile_Skip18	; F6F601  jrl NZ,0xf6f7d8
	calr	InputStream_GetByte	; F6F604  calr 0xf7138f
	ld	(Smf_Division:16), a	; F6F607  ld (0x107c),A
	cpw	(Smf_Division:16), 0x0000	; F6F60B  cp (0x107c),0x0000
	jr	nz, Smf_ReadFile_Skip3	; F6F611  jr NZ,0xf6f61b
	ld	(UI_StatusCode:16), 48	; F6F613  ld (0x2880),0x30
	jrl	Smf_ReadFile_Join4	; F6F618  jrl T,0xf6f7dd
Smf_ReadFile_Skip3:
	calr	ClearRam10D3_34Bytes	; F6F61B  calr 0xf6f9c7
	cpw	(Smf_Format:16), 0x0000	; F6F61E  cp (0x1078),0x0000
	jr	z, Smf_ReadFile_Skip4	; F6F624  jr Z,0xf6f655
	cpw	(Smf_Format:16), 0x0001	; F6F626  cp (0x1078),0x0001
	jrl	nz, Smf_ReadFile_Skip18	; F6F62C  jrl NZ,0xf6f7d8
	cpw	(Smf_TrackCount:16), 0x0001	; F6F62F  cp (0x107a),0x0001
	jr	z, Smf_ReadFile_Skip4	; F6F635  jr Z,0xf6f655
	calr	Smf_ReadMultiTrack	; F6F637  calr 0xf71b82
	cp	(0x1238:16), 0x00	; F6F63A  cp (0x1238),0x00
	jrl	nz, Smf_ReadFile_Join2	; F6F63F  jrl NZ,0xf6f780
	cp	(0x1010:16), 0x00	; F6F642  cp (0x1010),0x00
	jrl	z, Smf_ReadFile_Join5	; F6F647  jrl Z,0xf6f7e3
	cp	(UI_StatusCode:16), 0x31	; F6F64A  cp (0x2880),0x31
	jrl	z, Smf_ReadFile_Join2	; F6F64F  jrl Z,0xf6f780
	jrl	Smf_ReadFile_Join3	; F6F652  jrl T,0xf6f7ad
Smf_ReadFile_Skip4:
	ldw	bc, 4	; F6F655  ld BC,0x0004
	ld	xiy, SmfChunkTags + 0x4	; F6F658  ld XIY,0x00f6f52c
	pushw	bc	; F6F65D  push BC
	push	xiy	; F6F65E  push XIY
	calr	InputStream_GetByte	; F6F65F  calr 0xf7138f
	pop	xiy	; F6F662  pop XIY
	popw	bc	; F6F663  pop BC
	cp	a, (xiy+)	; F6F664  cp A,(XIY+)
	jr	z, Smf_ReadFile_Skip5	; F6F667  jr Z,0xf6f671
	ld	(UI_StatusCode:16), 49	; F6F669  ld (0x2880),0x31
	jrl	Smf_ReadFile_Join4	; F6F66E  jrl T,0xf6f7dd
Smf_ReadFile_Skip5:
	djnz16	bc, -23	; F6F671  djnz BC,0xf6f65d
	ld	xix, SmfOut_TrackLength	; F6F674  ld XIX,0x000010c4
	ldw	bc, 4	; F6F679  ld BC,0x0004
	pushw	bc	; F6F67C  push BC
	push	xix	; F6F67D  push XIX
	calr	InputStream_GetByte	; F6F67E  calr 0xf7138f
	pop	xix	; F6F681  pop XIX
	popw	bc	; F6F682  pop BC
	ld	w, (InputStream_Status:16)	; F6F683  ld W,(0x124a)
	cp	w, 1:i3	; F6F687  cp W,1
	jr	z, Smf_ReadFile_Skip6	; F6F689  jr Z,0xf6f691
	cp	w, 253	; F6F68B  cp W,0xfd
	jrl	nz, Smf_ReadFile_Join3	; F6F68E  jrl NZ,0xf6f7ad
Smf_ReadFile_Skip6:
	ld	(xix+), a	; F6F691  ld (XIX+),A
	djnz16	bc, -27	; F6F694  djnz BC,0xf6f67c
	call	T_Seq_RequestRewind	; F6F697  call 0xf409e0
	call	T_SongClear_ClearCurrentBank	; F6F69B  call 0xf42708
	xor	xwa, xwa	; F6F69F  xor XWA,XWA
	ld	(6304798:24), xwa	; F6F6A1  ld (0x60341e),XWA
	ld	(13836:16), xwa	; F6F6A6  ld (0x360c),XWA
	calr	Smf_AllocFirstBlockForAllTracks	; F6F6AA  calr 0xf6f9de
	calr	Smf_PutDefaultTimeSigOnMasterTrack	; F6F6AD  calr 0xf6fa70
	cp	(0x1238:16), 0x00	; F6F6B0  cp (0x1238),0x00
	jrl	nz, Smf_ReadFile_Join2	; F6F6B5  jrl NZ,0xf6f780
	ld	(4529:16), 0	; F6F6B8  ld (0x11b1),0x00
Smf_ReadFile_Loop:
	calr	Smf_ReadVlqBytes_Copy	; F6F6BD  calr 0xf71369
	ld	w, (InputStream_Status:16)	; F6F6C0  ld W,(0x124a)
	cp	w, 1:i3	; F6F6C4  cp W,1
	jr	z, Smf_ReadFile_Skip7	; F6F6C6  jr Z,0xf6f6ce
	cp	w, 253	; F6F6C8  cp W,0xfd
	jrl	nz, Smf_ReadFile_Join3	; F6F6CB  jrl NZ,0xf6f7ad
Smf_ReadFile_Skip7:
	calr	Smf_DecodeVlq	; F6F6CE  calr 0xf6fe1b
	xor	xiy, xiy	; F6F6D1  xor XIY,XIY
Smf_ReadFile_Loop2:
	push	xiy	; F6F6D3  push XIY
	calr	Smf_ApplyDeltaTime	; F6F6D4  calr 0xf710e7
	pop	xiy	; F6F6D7  pop XIY
	inc	1, xiy	; F6F6D8  inc 1,XIY
	cp	xiy, 16	; F6F6DA  cp XIY,0x00000010
	jr	ule, Smf_ReadFile_Loop2	; F6F6E0  jr ULE,0xf6f6d3
	calr	Smf_AddDeltaToHeldNotes	; F6F6E2  calr 0xf712b6
	calr	InputStream_GetByte	; F6F6E5  calr 0xf7138f
	ld	w, (InputStream_Status:16)	; F6F6E8  ld W,(0x124a)
	cp	w, 1:i3	; F6F6EC  cp W,1
	jr	z, Smf_ReadFile_Skip8	; F6F6EE  jr Z,0xf6f6f6
	cp	w, 253	; F6F6F0  cp W,0xfd
	jrl	nz, Smf_ReadFile_Join3	; F6F6F3  jrl NZ,0xf6f7ad
Smf_ReadFile_Skip8:
	cp	a, 255	; F6F6F6  cp A,0xff
	jr	nz, Smf_ReadFile_Skip11	; F6F6F9  jr NZ,0xf6f729
	calr	SmfEvent_Meta	; F6F6FB  calr 0xf6fb51
	ld	w, (InputStream_Status:16)	; F6F6FE  ld W,(0x124a)
	cp	w, 1:i3	; F6F702  cp W,1
	jr	z, Smf_ReadFile_Skip9	; F6F704  jr Z,0xf6f70c
	cp	w, 253	; F6F706  cp W,0xfd
	jrl	nz, Smf_ReadFile_Join3	; F6F709  jrl NZ,0xf6f7ad
Smf_ReadFile_Skip9:
	cp	(0x10cb:16), 0xff	; F6F70C  cp (0x10cb),0xff
	jr	z, Smf_ReadFile_Skip10	; F6F711  jr Z,0xf6f71d
	cp	(0x1238:16), 0x00	; F6F713  cp (0x1238),0x00
	jr	z, Smf_ReadFile_Loop	; F6F718  jr Z,0xf6f6bd
	jrl	Smf_ReadFile_Join2	; F6F71A  jrl T,0xf6f780
Smf_ReadFile_Skip10:
	calr	Smf_TerminateUsedTracks	; F6F71D  calr 0xf6fab7
	calr	Smf_ClearUnusedTracks	; F6F720  calr 0xf6fae8
	calr	InputStream_RefillDone	; F6F723  calr 0xf765de
	jrl	Smf_ReadFile_Join5	; F6F726  jrl T,0xf6f7e3
Smf_ReadFile_Skip11:
	cp	a, 247	; F6F729  cp A,0xf7
	jr	z, Smf_ReadFile_Skip12	; F6F72C  jr Z,0xf6f733
	cp	a, 240	; F6F72E  cp A,0xf0
	jr	nz, Smf_ReadFile_Skip14	; F6F731  jr NZ,0xf6f747
Smf_ReadFile_Skip12:
	calr	SmfEvent_SysEx	; F6F733  calr 0xf71525
	ld	w, (InputStream_Status:16)	; F6F736  ld W,(0x124a)
	cp	w, 1:i3	; F6F73A  cp W,1
	jr	z, Smf_ReadFile_Skip13	; F6F73C  jr Z,0xf6f744
	cp	w, 253	; F6F73E  cp W,0xfd
	jrl	nz, Smf_ReadFile_Join3	; F6F741  jrl NZ,0xf6f7ad
Smf_ReadFile_Skip13:
	jrl	Smf_ReadFile_Loop	; F6F744  jrl T,0xf6f6bd
Smf_ReadFile_Skip14:
	bit	7, a	; F6F747  bit 0x07,A
	jr	z, Smf_ReadFile_Skip16	; F6F74A  jr Z,0xf6f766
	calr	SmfEvent_ReadWithNewStatus	; F6F74C  calr 0xf6fefe
	ld	w, (InputStream_Status:16)	; F6F74F  ld W,(0x124a)
	cp	w, 1:i3	; F6F753  cp W,1
	jr	z, Smf_ReadFile_Skip15	; F6F755  jr Z,0xf6f75c
	cp	w, 253	; F6F757  cp W,0xfd
	jr	nz, Smf_ReadFile_Join3	; F6F75A  jr NZ,0xf6f7ad
Smf_ReadFile_Skip15:
	cp	(0x1238:16), 0x00	; F6F75C  cp (0x1238),0x00
	jr	nz, Smf_ReadFile_Join2	; F6F761  jr NZ,0xf6f780
	jrl	Smf_ReadFile_Loop	; F6F763  jrl T,0xf6f6bd
Smf_ReadFile_Skip16:
	calr	SmfEvent_ReadWithRunningStatus	; F6F766  calr 0xf6fea1
	ld	w, (InputStream_Status:16)	; F6F769  ld W,(0x124a)
	cp	w, 1:i3	; F6F76D  cp W,1
	jr	z, Smf_ReadFile_Skip17	; F6F76F  jr Z,0xf6f776
	cp	w, 253	; F6F771  cp W,0xfd
	jr	nz, Smf_ReadFile_Join3	; F6F774  jr NZ,0xf6f7ad
Smf_ReadFile_Skip17:
	cp	(0x1238:16), 0x00	; F6F776  cp (0x1238),0x00
	jr	nz, Smf_ReadFile_Join2	; F6F77B  jr NZ,0xf6f780
	jrl	Smf_ReadFile_Loop	; F6F77D  jrl T,0xf6f6bd
Smf_ReadFile_Join2:
	calr	InputStream_RefillDone	; F6F780  calr 0xf765de
	call	T_SongClear_ClearCurrentBank	; F6F783  call 0xf42708
	xor	xwa, xwa	; F6F787  xor XWA,XWA
	ld	(6304798:24), xwa	; F6F789  ld (0x60341e),XWA
	ld	(13836:16), xwa	; F6F78E  ld (0x360c),XWA
	call	T_F40CB4	; F6F792  call 0xf40cb4
	ldw	(BStore_Password:24), 0	; F6F796  ld (0x60341c),0x0000
	cp	(UI_StatusCode:16), 0x31	; F6F79D  cp (0x2880),0x31
	jrl	z, Smf_ReadFile_Join8	; F6F7A2  jrl Z,0xf6f89f
	ld	(UI_StatusCode:16), 31	; F6F7A5  ld (0x2880),0x1f
	jrl	Smf_ReadFile_Join8	; F6F7AA  jrl T,0xf6f89f
Smf_ReadFile_Join3:
	calr	InputStream_RefillDone	; F6F7AD  calr 0xf765de
	call	T_SongClear_ClearCurrentBank	; F6F7B0  call 0xf42708
	xor	xwa, xwa	; F6F7B4  xor XWA,XWA
	ld	(6304798:24), xwa	; F6F7B6  ld (0x60341e),XWA
	ld	(13836:16), xwa	; F6F7BB  ld (0x360c),XWA
	call	T_F40CB4	; F6F7BF  call 0xf40cb4
	ldw	(BStore_Password:24), 0	; F6F7C3  ld (0x60341c),0x0000
	ld	l, (InputStream_Status:16)	; F6F7CA  ld L,(0x124a)
	calr	Smf_ResultToStatusCode	; F6F7CE  calr 0xf72f2d
	ld	(UI_StatusCode:16), l	; F6F7D1  ld (0x2880),L
	jrl	Smf_ReadFile_Join8	; F6F7D5  jrl T,0xf6f89f
Smf_ReadFile_Skip18:
	ld	(UI_StatusCode:16), 48	; F6F7D8  ld (0x2880),0x30
Smf_ReadFile_Join4:
	calr	InputStream_RefillDone	; F6F7DD  calr 0xf765de
	jrl	Smf_ReadFile_Join8	; F6F7E0  jrl T,0xf6f89f
Smf_ReadFile_Join5:
	call	T_F40CB4	; F6F7E3  call 0xf40cb4
	calr	Smf_ResetTrackAssignToIdentity	; F6F7E7  calr 0xf6f94e
	ld	(UI_StatusCode:16), 35	; F6F7EA  ld (0x2880),0x23
	call	T_MessageScreen_Paint	; F6F7EF  call 0xf41600
	calr	Smf_BusyDelay	; F6F7F3  calr 0xf72f20
	cp	(0x1239:16), 0xff	; F6F7F6  cp (0x1239),0xff
	jr	z, Smf_ReadFile_Skip19	; F6F7FB  jr Z,0xf6f80c
	ld	c, 0:opc	; F6F7FD  ld C,0x00
	and	(0x7f4d:16), 0xfb	; F6F7FF  and (0x7f4d),0xfb
	ld	(6304966:24), 0	; F6F804  ld (0x6034c6),0x00
	jr	Smf_ReadFile_Join6	; F6F80A  jr T,0xf6f81c
Smf_ReadFile_Skip19:
	or	a, 4	; F6F80C  or A,0x04
	ld	c, 255:opc	; F6F80F  ld C,0xff
	or	(0x7f4d:16), 0x04	; F6F811  or (0x7f4d),0x04
	ld	(6304966:24), 255	; F6F816  ld (0x6034c6),0xff
Smf_ReadFile_Join6:
	calr	BStore_SetGmFlagInCurrentBankCopy	; F6F81C  calr 0xf6f8a5
	ld	(4684:16), 1	; F6F81F  ld (0x124c),0x01
	ld	e, 145:opc	; F6F824  ld E,0x91
	ld	d, 3:opc	; F6F826  ld D,0x03
	ld	w, 4:opc	; F6F828  ld W,0x04
	xor	a, a	; F6F82A  xor A,A
	cp	(0x1239:16), 0x00	; F6F82C  cp (0x1239),0x00
	jr	z, Smf_ReadFile_Skip20	; F6F831  jr Z,0xf6f835
	ld	a, 4:opc	; F6F833  ld A,0x04
Smf_ReadFile_Skip20:
	call	T_Queue2C00_AppendRegs	; F6F835  call 0xf40f38
	call	T_Queue2C00_DrainPassAB	; F6F839  call 0xf40018
	call	T_F42578	; F6F83D  call 0xf42578
	cp	(0x1380:16), 0xff	; F6F841  cp (0x1380),0xff
	jr	z, Smf_ReadFile_Skip21	; F6F846  jr Z,0xf6f866
	ld	a, (4992:16)	; F6F848  ld A,(0x1380)
	ld	w, (MidiCfg_ModeBits:16)	; F6F84C  ld W,(0x7f32)
	and	a, 3	; F6F850  and A,0x03
	and	w, 252	; F6F853  and W,0xfc
	or	a, w	; F6F856  or A,W
	ld	(MidiCfg_ModeBits:16), a	; F6F858  ld (0x7f32),A
	ld	e, 128:opc	; F6F85C  ld E,0x80
	ld	d, 0:opc	; F6F85E  ld D,0x00
	ld	w, 3:opc	; F6F860  ld W,0x03
	call	T_Queue2E00_AppendRegs	; F6F862  call 0xf40f3c
Smf_ReadFile_Skip21:
	ld	xwa, (13836:16)	; F6F866  ld XWA,(0x360c)
	ld	(6304798:24), xwa	; F6F86A  ld (0x60341e),XWA
	bit	0, (0x603420:24)	; F6F86F  bit 0,(0x603420)
	jr	z, Smf_ReadFile_Skip22	; F6F874  jr Z,0xf6f87d
	ld	(14162:16), 1	; F6F876  ld (0x3752),0x01
	jr	Smf_ReadFile_Join7	; F6F87B  jr T,0xf6f882
Smf_ReadFile_Skip22:
	ld	(14162:16), 0	; F6F87D  ld (0x3752),0x00
Smf_ReadFile_Join7:
	and	(0x34bb:16), 0xf7	; F6F882  and (0x34bb),0xf7
	call	T_Seq_RequestRewind	; F6F887  call 0xf409e0
	calr	SmfPart_ResetFineTuneAndBendRange	; F6F88B  calr 0xf6f8c7
	ldw	(BStore_Password:24), 0	; F6F88E  ld (0x60341c),0x0000
	call	T_NoteRouting_RebuildForSong	; F6F895  call 0xf411b8
	ldw	(UI_Request:16), 520	; F6F899  ld (0x2070),0x0208
Smf_ReadFile_Join8:
	and	(0x21e8:16), 0x7f	; F6F89F  and (0x21e8),0x7f
	ret	; F6F8A4  ret

; --------------------------------------------------------------------------
; BStore_SetGmFlagInCurrentBankCopy
; Called from: in-module: 0xF6F81C
; Touches: (0x360A)  |  0x610000
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6F8A5 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_SetGmFlagInCurrentBankCopy: Byte +0xC6 of the current bank's 0xC00-byte copy (0x610000 +
;   BStore_CurrentBank*0xC00) := C -- the bank-copy twin of the song's GM flag 0x6034C6. Smf_ReadFile calls it right
;   after setting (0x6034C6) and GM mode (0x7F4D) bit 2 to the same 0 / 0xFF. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_v.json)
BStore_SetGmFlagInCurrentBankCopy:
	xor	xwa, xwa	; F6F8A5  xor XWA,XWA
	ld	a, (BStore_CurrentBank:16)	; F6F8A7  ld A,(0x360a)
	ld	xhl, xwa	; F6F8AB  ld XHL,XWA
	sla	xwa, 11	; F6F8AD  sla 0x0b,XWA
	sla	xhl, 10	; F6F8B0  sla 0x0a,XHL
	add	xwa, xhl	; F6F8B3  add XWA,XHL
	ld	xhl, 6356992	; F6F8B5  ld XHL,0x00610000
	add	xhl, xwa	; F6F8BA  add XHL,XWA
	ld	xix, xhl	; F6F8BC  ld XIX,XHL
	add	xix, 198	; F6F8BE  add XIX,0x000000c6
	ld	(xix), c	; F6F8C4  ld (XIX),C
	ret	; F6F8C6  ret

; --------------------------------------------------------------------------
; SmfPart_ResetFineTuneAndBendRange
; Called from: in-module: 0xF6F88B
; Touches:   |  0x6036A0
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6F8C7 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfPart_ResetFineTuneAndBendRange: In all 16 channels' 64-byte part records at 0x6036A0 (records 0-7 and 9-16,
;   record 8 skipped as in SmfPart_RecordOffsets): +0x0D := 2 and +0x0C := 0x80 -- the fields the SMF writer exports
;   as RPN 0 (pitch-bend sensitivity, CC 6) and RPN 1 (fine tuning, CC 6/38 = +0x0C>>1, bit 0<<6). Smf_ReadFile runs
;   it on its success path after the import. Basis: caller + body + the writer's reads of the same fields.
;   (notes/naming-pilot-2026-10-06/proposals_wave6_v.json)
SmfPart_ResetFineTuneAndBendRange:
	ld	xix, 6305440	; F6F8C7  ld XIX,0x006036a0
	ld	a, 2:opc	; F6F8CC  ld A,0x02
	ldw	bc, 16	; F6F8CE  ld BC,0x0010
	ld	(xix+13), a	; F6F8D1  ld (XIX+0x0d),A
	add	xix, 64	; F6F8D4  add XIX,0x00000040
	cp	bc, 9	; F6F8DA  cp BC,0x0009
	jr	nz, SmfPart_ResetFineTuneAndBendRange_Skip	; F6F8DE  jr NZ,0xf6f8e6
	add	xix, 64	; F6F8E0  add XIX,0x00000040
SmfPart_ResetFineTuneAndBendRange_Skip:
	djnz16	bc, -24	; F6F8E6  djnz BC,0xf6f8d1
	ld	xix, 6305440	; F6F8E9  ld XIX,0x006036a0
	ld	a, 128:opc	; F6F8EE  ld A,0x80
	ldw	bc, 16	; F6F8F0  ld BC,0x0010
	ld	(xix+12), a	; F6F8F3  ld (XIX+0x0c),A
	add	xix, 64	; F6F8F6  add XIX,0x00000040
	cp	bc, 9	; F6F8FC  cp BC,0x0009
	jr	nz, SmfPart_ResetFineTuneAndBendRange_Skip2	; F6F900  jr NZ,0xf6f908
	add	xix, 64	; F6F902  add XIX,0x00000040
SmfPart_ResetFineTuneAndBendRange_Skip2:
	djnz16	bc, -24	; F6F908  djnz BC,0xf6f8f3
	ret	; F6F90B  ret

; --------------------------------------------------------------------------
; Smf_ResetRpnState
; Called from: in-module: 0xF6F554
; Touches: nothing with an absolute address
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6F90C is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_ResetRpnState: Selected-RPN bytes 0x11D8[16] := 0xFF (none) and the 84 bytes from 0x11E8 := 0: the per-channel
;   RPN value arrays 0x11E8 / 0x11F8 / 0x1208, the fine-tune MSB/LSB cells 0x1218 / 0x1228, and 0x1238..0x123B.
;   Smf_ReadFile's first call, before any event is read. Basis: caller + body + the arrays' readers
;   (SmfCC_UpdateSelectedRpn, SmfCC_PutSelectedRpnValueEvent, SmfCC_CombineFineTuneDataEntry). (notes/naming-
;   pilot-2026-10-06/proposals_wave6_v.json)
Smf_ResetRpnState:
	ldw	wa, 65535	; F6F90C  ld WA,0xffff
	ld	xix, 4568	; F6F90F  ld XIX,0x000011d8
	ldw	bc, 8	; F6F914  ld BC,0x0008
	ld	(xix+), wa	; F6F917  ld (XIX+),WA
	djnz16	bc, -6	; F6F91A  djnz BC,0xf6f917
	xor	wa, wa	; F6F91D  xor WA,WA
	ldw	bc, 42	; F6F91F  ld BC,0x002a
	ld	(xix+), wa	; F6F922  ld (XIX+),WA
	djnz16	bc, -6	; F6F925  djnz BC,0xf6f922
	ret	; F6F928  ret

; --------------------------------------------------------------------------
; Smf_ClearChannelBankSelects
; Called from: in-module: 0xF6F55A 0xF71BB1
; Touches: nothing with an absolute address
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF6F929 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_ClearChannelBankSelects: Zeroes the 16-byte per-channel bank-select tables at 0x1092 (MSB, CC 0) and 0x10A4
;   (LSB, CC 32) that SmfCC_BankSelectMsb / SmfCC_BankSelectLsb fill by MIDI channel. Smf_ReadFile calls it before
;   reading, Smf_ReadMultiTrack before every track chunk. Basis: callers + body + the tables' writers. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_j.json)
Smf_ClearChannelBankSelects:
	push	xwa	; F6F929  push XWA
	push	xbc	; F6F92A  push XBC
	push	xix	; F6F92B  push XIX
	xor	wa, wa	; F6F92C  xor WA,WA
	ld	xix, 4242	; F6F92E  ld XIX,0x00001092
	ldw	bc, 8	; F6F933  ld BC,0x0008
	ld	(xix+), wa	; F6F936  ld (XIX+),WA
	djnz16	bc, -6	; F6F939  djnz BC,0xf6f936
	ld	xix, 4260	; F6F93C  ld XIX,0x000010a4
	ldw	bc, 8	; F6F941  ld BC,0x0008
	ld	(xix+), wa	; F6F944  ld (XIX+),WA
	djnz16	bc, -6	; F6F947  djnz BC,0xf6f944
	pop	xix	; F6F94A  pop XIX
	pop	xbc	; F6F94B  pop XBC
	pop	xwa	; F6F94C  pop XWA
	ret	; F6F94D  ret

; --------------------------------------------------------------------------
; Smf_ResetTrackAssignToIdentity
; Called from: in-module: 0xF6F7E7 0xF71BE2
; Touches: (0x1239)  |  0x603422 0x603433
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6F94E is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_ResetTrackAssignToIdentity: BStore_TrackToPart[0..16] := 0..15, 0x20 and the 16 track MIDI channels at 0x603433
;   := 0..15 (from ByteMap_F6F985/_F6F9A7; (0x1239) only picks a byte-identical copy). Run by both SMF readers after a
;   file is read, so an SMF lands with track n on part n / channel n. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_g.json)
Smf_ResetTrackAssignToIdentity:
	ld	xiy, ByteMap_F6F985	; F6F94E  ld XIY,0x00f6f985
	cp	(0x1239:16), 0x00	; F6F953  cp (0x1239),0x00
	jr	z, Smf_ResetTrackAssignToIdentity_Skip	; F6F958  jr Z,0xf6f95f
	ld	xiy, ByteMap_F6F996	; F6F95A  ld XIY,0x00f6f996
Smf_ResetTrackAssignToIdentity_Skip:
	ld	xix, BStore_TrackToPart	; F6F95F  ld XIX,0x00603422
	ldw	bc, 17	; F6F964  ld BC,0x0011
	ldir85	; F6F967  ldir
	ld	xiy, ByteMap_F6F9A7	; F6F969  ld XIY,0x00f6f9a7
	cp	(0x1239:16), 0x00	; F6F96E  cp (0x1239),0x00
	jr	z, Smf_ResetTrackAssignToIdentity_Skip2	; F6F973  jr Z,0xf6f97a
	ld	xiy, ByteMap_F6F9B7	; F6F975  ld XIY,0x00f6f9b7
Smf_ResetTrackAssignToIdentity_Skip2:
	ld	xix, 6304819	; F6F97A  ld XIX,0x00603433
	ldw	bc, 16	; F6F97F  ld BC,0x0010
	ldir85	; F6F982  ldir
	ret	; F6F984  ret

; --------------------------------------------------------------------------
; ByteMap_F6F985 -- 70 bytes: 4 BYTE MAPS end to end, 17 bytes at 0xF6F985
;                   (0x00..0x20), 17 bytes at 0xF6F996 (0x00..0x20), 16
;                   bytes at 0xF6F9A7 (0x00..0x0F), 20 bytes at 0xF6F9B7
;                   (0x00..0xD8).  Each ascends STRICTLY on its own and the
;                   sequence RESTARTS at each boundary, so this is N maps of
;                   the same shape rather than one long one.  The name
;                   describes the CONTENT; what the index spaces are is not
;                   established here.
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XIY,0x00f6f985` at
;          0xF6F94E (operand field 1 byte in)
; Entry count: 70 bytes.  The run is trimmed of trailing 0xFF, so it claims
;              no padding it did not earn; the byte before it is 0x0E and
;              the LAST byte of it is 0xD8.
; Evidence: every non-0xFF byte is compared with its predecessor on every
;           emit, WITHIN EACH of the 4 maximal ascending runs the rule
;           returns, and the runs are asserted to tile this segment exactly.
;           The BYTEMAP rule fires ZERO times over the proven prom_b
;           instruction text at (16 bytes, 12 values) and also at (20,14),
;           (24,16) and (16,16) (`python3 notes/prom_b_f6d002_layout.py
;           --null-ptr`).
; Unknown: what the two index spaces ARE.  (Who reads it is answered by the
;          CORRECTED paragraph below: Smf_ResetTrackAssignToIdentity.)
; --------------------------------------------------------------------------
; ⚠ CORRECTED 2026-09-25 (lane promb): the object is 66 bytes, four maps of
;   17, 17, 16 and 16, not 70 with a 20-byte fourth map.  The reader fixes the
;   lengths: Smf_ResetTrackAssignToIdentity (0xF6F94E) copies 17 bytes (`ld BC,0x0011 / ldir`)
;   from 0xF6F985 or 0xF6F996 to 0x603422, choosing on (0x1239) == 0, then 16
;   bytes (`ld BC,0x0010 / ldir`) from 0xF6F9A7 or 0xF6F9B7 to 0x603433 on
;   the same test.  The four bytes the old framing ended on, 0x28 0x29 0x3C
;   0xD8 at 0xF6F9C7, begin ClearRam10D3_34Bytes below, which the `calr` at
;   0xF6F61B reaches.  So "who reads it" above is answered (Smf_ResetTrackAssignToIdentity), and
;   the maps are PAIRS OF IDENTICAL COPIES: 0xF6F985 == 0xF6F996 (0x00..0x0F,
;   then 0x20) and 0xF6F9A7 == 0xF6F9B7 (0x00..0x0F) -- (0x1239) selects
;   between byte-identical tables.  What 0x603422 / 0x603433 hold is not
;   established here.
ByteMap_F6F985:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x20	; F6F985  17 -> 0x603422 when (0x1239) == 0
ByteMap_F6F996:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x20	; F6F996  17 -> 0x603422 when (0x1239) != 0
ByteMap_F6F9A7:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F6F9A7  16 -> 0x603433 when (0x1239) == 0
ByteMap_F6F9B7:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F6F9B7  16 -> 0x603433 when (0x1239) != 0

; --------------------------------------------------------------------------
; ClearRam10D3_34Bytes -- 0xF6F9C7-0xF6F9DD (converted 2026-09-25, lane
;   promb; was the last four bytes of ByteMap_F6F985 plus `Data_F6F9CB`,
;   "Unknown: everything about it except its bytes").
; Called from: 0xF6F61B (`calr`).
; Does:    writes seventeen zero WORDS from RAM 0x10D3 up (0x10D3-0x10F4),
;          preserving WA, BC and XIX.
; Evidence: MAME unidasm and llvm-mc agree on every instruction; the call
;          site lands on the first; the `ret` at 0xF6F9DD is followed by
;          Smf_AllocFirstBlockForAllTracks, a routine already proven by its own caller.
; --------------------------------------------------------------------------
ClearRam10D3_34Bytes:
	pushw	wa	; F6F9C7  push WA
	pushw	bc	; F6F9C8  push BC
	push	xix	; F6F9C9  push XIX
	xor	wa, wa	; F6F9CA  xor WA,WA
	ldw	bc, 17	; F6F9CC  ld BC,0x0011
	ld	xix, 4307	; F6F9CF  ld XIX,0x000010d3
ClearRam10D3_34Bytes_Loop:
	ld	(xix+), wa	; F6F9D4  ld (XIX+),WA
	djnz16	bc, ClearRam10D3_34Bytes_Loop	; F6F9D7  djnz BC,0xf6f9d4
	pop	xix	; F6F9DA  pop XIX
	popw	bc	; F6F9DB  pop BC
	popw	wa	; F6F9DC  pop WA
	ret	; F6F9DD  ret


; --------------------------------------------------------------------------
; Smf_AllocFirstBlockForAllTracks
; Called from: in-module: 0xF6F6AA
; Touches: (0x126E) (0x349F) (0x3608)  |  0x603500
; Calls:   T_BStore_AllocBlock_Veneer SongStore_SeekBlock_Copy
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6F9DE is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_AllocFirstBlockForAllTracks: For directory entries 0..16 ((0x349F) counting), while at least 17 blocks are free:
;   allocates a block (T_BStore_AllocBlock_Veneer), marks it used with no links (+1 := 0, +3 := 0xFFFF), sets the
;   entry's in-use bit and head, and points the entry's song position (0x3460 / 0x3482) at its offset 5. Smf_ReadFile
;   runs it after clearing the bank, before reading events; Smf_AllocFirstBlockForAllTracks_B is a copy (Smf_ReadMultiTrack's split pass).
;   Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave6_v.json)
Smf_AllocFirstBlockForAllTracks:
	xor	iy, iy	; F6F9DE  xor IY,IY
	xor	ix, ix	; F6F9E0  xor IX,IX
	ld	(13471:16), 0	; F6F9E2  ld (0x349f),0x00
Smf_AllocFirstBlockForAllTracks_Loop:
	cpw	(BStore_FreeCount:24), 0x0011	; F6F9E7  cp (0x6034ba),0x0011
	jrl	c, Smf_AllocFirstBlockForAllTracks_Return	; F6F9EE  jrl C,0xf6fa6f
	push	xiy	; F6F9F1  push XIY
	push	xix	; F6F9F2  push XIX
	call	T_BStore_AllocBlock_Veneer	; F6F9F3  call 0xf42884
	ld	wa, ix	; F6F9F7  ld WA,IX
	pop	xix	; F6F9F9  pop XIX
	pop	xiy	; F6F9FA  pop XIY
	ld	bc, (BStore_BlockCount:16)	; F6F9FB  ld BC,(0x3608)
	cp	wa, bc	; F6F9FF  cp WA,BC
	jr	ugt, Smf_AllocFirstBlockForAllTracks_Return	; F6FA01  jr UGT,0xf6fa6f
	cp	wa, 0:i3	; F6FA03  cp WA,0
	jr	z, Smf_AllocFirstBlockForAllTracks_Return	; F6FA05  jr Z,0xf6fa6f
	pushw	wa	; F6FA07  push WA
	ld	hl, wa	; F6FA08  ld HL,WA
	calr	SongStore_SeekBlock_Copy	; F6FA0A  calr 0xf72f0a
	ld	xhl, (BStore_CursorBlockAddr:16)	; F6FA0D  ld XHL,(0x126e)
	or	(xhl), 0x80	; F6FA11  or (XHL),0x80
	ldw	(xhl+1), 0x0000	; F6FA14  ld (XHL+0x01),0x0000
	ldw	(xhl+3), 0xffff	; F6FA19  ld (XHL+0x03),0xffff
	popw	wa	; F6FA1E  pop WA
	ld	xhl, 6305024	; F6FA1F  ld XHL,0x00603500
	or	(xhl+iy), 0x80	; F6FA24  or (XHL+IY),0x80
	push	xhl	; F6FA2A  push XHL
	lda	xhl, (xhl+iy)	; F6FA2B  lda XHL,XHL+IY
	ldfr_lerp	xhl, 0x38	; F6FA30  ld XDE3,XHL
	pop	xhl	; F6FA33  pop XHL
	.byte 0xF3, 0x39, 0x01, 0x00, 0x50	; F6FA34  ld (XDE3+0x0001),WA   [llvm-mc cannot encode this]
	ld	xhl, 13408	; F6FA39  ld XHL,0x00003460
	ld	(xhl+ix), wa	; F6FA3E  ld (XHL+IX),WA
	ld	xhl, 13442	; F6FA43  ld XHL,0x00003482
	xor	bc, bc	; F6FA48  xor BC,BC
	ld	c, (13471:16)	; F6FA4A  ld C,(0x349f)
	push	xiy	; F6FA4E  push XIY
	ld	iy, bc	; F6FA4F  ld IY,BC
	ldw	(xhl+iy), 0x0005	; F6FA51  ld (XHL+IY),0x0005
	pop	xiy	; F6FA58  pop XIY
	add	iy, 3	; F6FA59  add IY,0x0003
	add	ix, 2	; F6FA5D  add IX,0x0002
	inc	1, (13471:16)	; F6FA61  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F6FA65  cp (0x349f),0x11
	jrl	c, Smf_AllocFirstBlockForAllTracks_Loop	; F6FA6A  jrl C,0xf6f9e7
	jr	Smf_AllocFirstBlockForAllTracks_Return	; F6FA6D  jr T,0xf6fa6f
Smf_AllocFirstBlockForAllTracks_Return:
	ret	; F6FA6F  ret

; --------------------------------------------------------------------------
; Smf_PutDefaultTimeSigOnMasterTrack
; Called from: in-module: 0xF6F6AD 0xF72F9E
; Touches: (0x1238) (0x360E)
; Calls:   TrackCursor_Load BStore_PutByteAndAdvance TrackCursor_Save
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF6FA70 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_PutDefaultTimeSigOnMasterTrack: At master track 17's cursor (index 16) writes the tag-0x87 time-signature record
;   {0x87, 0x00, 0x03} (Data_F6FAB4: beats per bar = 3+1 = 4, as BStore_TimeSigFirstMeasure reads it), marks the
;   master track used ((0x360E) bit 0) and saves the cursor; stops if a byte store fails ((0x1238)). Called by
;   Smf_ReadFile and by Smf_SplitTrack1ByChannel (the multi-track split) before any event is stored. Basis: callers + body + the
;   tag-0x87 reader. (notes/naming-pilot-2026-10-06/proposals_wave6_v.json)
Smf_PutDefaultTimeSigOnMasterTrack:
	push	xwa	; F6FA70  push XWA
	push	xhl	; F6FA71  push XHL
	push	xbc	; F6FA72  push XBC
	push	xde	; F6FA73  push XDE
	push	xix	; F6FA74  push XIX
	push	xiy	; F6FA75  push XIY
	push	xiz	; F6FA76  push XIZ
	xor	xiy, xiy	; F6FA77  xor XIY,XIY
	ldw	iy, 16	; F6FA79  ld IY,0x0010
	push	xiy	; F6FA7C  push XIY
	calr	TrackCursor_Load	; F6FA7D  calr 0xf7124e
	pop	xiy	; F6FA80  pop XIY
	ldw	bc, 3	; F6FA81  ld BC,0x0003
	ld	xix, Data_F6FAB4	; F6FA84  ld XIX,0x00f6fab4
	ld	a, (xix+)	; F6FA89  ld A,(XIX+)
	pushw	bc	; F6FA8C  push BC
	push	xix	; F6FA8D  push XIX
	push	xiy	; F6FA8E  push XIY
	calr	BStore_PutByteAndAdvance	; F6FA8F  calr 0xf70fda
	pop	xiy	; F6FA92  pop XIY
	pop	xix	; F6FA93  pop XIX
	popw	bc	; F6FA94  pop BC
	cp	(0x1238:16), 0x00	; F6FA95  cp (0x1238),0x00
	jr	nz, Smf_PutDefaultTimeSigOnMasterTrack_Epilogue	; F6FA9A  jr NZ,0xf6faac
	djnz16	bc, -22	; F6FA9C  djnz BC,0xf6fa89
	or	(0x360e:16), 0x01	; F6FA9F  or (0x360e),0x01
	calr	TrackCursor_Save	; F6FAA4  calr 0xf71275
	ld	(4664:16), 0	; F6FAA7  ld (0x1238),0x00
Smf_PutDefaultTimeSigOnMasterTrack_Epilogue:
	pop	xiz	; F6FAAC  pop XIZ
	pop	xiy	; F6FAAD  pop XIY
	pop	xix	; F6FAAE  pop XIX
	pop	xde	; F6FAAF  pop XDE
	pop	xbc	; F6FAB0  pop XBC
	pop	xhl	; F6FAB1  pop XHL
	pop	xwa	; F6FAB2  pop XWA
	ret	; F6FAB3  ret

; --------------------------------------------------------------------------
; Data_F6FAB4 -- 3 bytes this block could not split.  No content rule framed
;                it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or ASCII
;                -- and the code walk never reached it from a thunk slot, a
;                proven call site, an opcode-anchored call or an entry of a
;                table the firmware transfers to.  So it is emitted as bytes
;                rather than guessed.
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XIX,0x00f6fab4` at
;          0xF6FA84 (operand field 1 byte in)
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; Unknown: everything about it except its bytes.
; --------------------------------------------------------------------------
Data_F6FAB4:
	.byte	0x87, 0x00, 0x03	; F6FAB4  [0..2]


; --------------------------------------------------------------------------
; Smf_TerminateUsedTracks
; Called from: in-module: 0xF6F71D
; Touches:   |  0x603500
; Calls:   TrackCursor_Load BStore_PutByteAtCursor Smf_SaveTrackEndCursor
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6FAB7 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_TerminateUsedTracks: For each of the 17 directory entries in use (0x603500[3n] bit 7): loads track n's cursor,
;   writes the 0x82 end tag there and saves that position as the track's end cursor (0x6034A0[n] / 0x60347E[n], via
;   Smf_SaveTrackEndCursor). Smf_ReadFile runs it at the file's End of Track ((0x10CB) = 0xFF, set by SmfEvent_Meta on meta 0x2F).
;   Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave6_v.json)
Smf_TerminateUsedTracks:
	xor	hl, hl	; F6FAB7  xor HL,HL
Smf_TerminateUsedTracks_Loop:
	ld	iy, hl	; F6FAB9  ld IY,HL
	extz	xiy	; F6FABB  extz XIY
	sla	iy, 1	; F6FABD  sla 0x01,IY
	add	iy, hl	; F6FAC0  add IY,HL
	push	xde	; F6FAC2  push XDE
	ld	xde, 6305024	; F6FAC3  ld XDE,0x00603500
	bit	7, (xde+iy)	; F6FAC8  bit 7,(XDE+IY)
	pop	xde	; F6FACD  pop XDE
	jr	z, Smf_TerminateUsedTracks_Skip	; F6FACE  jr Z,0xf6fadf
	ld	iy, hl	; F6FAD0  ld IY,HL
	pushw	hl	; F6FAD2  push HL
	calr	TrackCursor_Load	; F6FAD3  calr 0xf7124e
	ld	a, 130:opc	; F6FAD6  ld A,0x82
	calr	BStore_PutByteAtCursor	; F6FAD8  calr 0xf70fe1
	calr	Smf_SaveTrackEndCursor	; F6FADB  calr 0xf6fb16
	popw	hl	; F6FADE  pop HL
Smf_TerminateUsedTracks_Skip:
	inc	1, hl	; F6FADF  inc 1,HL
	cp	hl, 16	; F6FAE1  cp HL,0x0010
	jr	ule, Smf_TerminateUsedTracks_Loop	; F6FAE5  jr ULE,0xf6fab9
	ret	; F6FAE7  ret

; --------------------------------------------------------------------------
; Smf_ClearUnusedTracks
; Called from: in-module: 0xF6F720
; Touches: (0x0C70) (0x360C) (0x360E)
; Calls:   T_F40A04
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6FAE8 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_ClearUnusedTracks: For tracks 1..17 whose bit in the used mask ((0x360C) bit t, (0x360E) bit 0 for track 17) is
;   still clear, BStore_ClearTrack through T_F40A04 with (0x0C70) = t -- frees the block
;   Smf_AllocFirstBlockForAllTracks gave every track. Smf_ReadFile runs it at End of Track, after
;   Smf_TerminateUsedTracks. Basis: caller + body + T_F40A04's target. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_v.json)
Smf_ClearUnusedTracks:
	xor	c, c	; F6FAE8  xor C,C
Smf_ClearUnusedTracks_Loop:
	ld	de, (13836:16)	; F6FAEA  ld DE,(0x360c)
	ld	a, c	; F6FAEE  ld A,C
	cp	a, 16	; F6FAF0  cp A,0x10
	jr	lt, Smf_ClearUnusedTracks_Skip	; F6FAF3  jr LT,0xf6fafb
	ld	de, (13838:16)	; F6FAF5  ld DE,(0x360e)
	ld	a, 16:opc	; F6FAF9  ld A,0x10
Smf_ClearUnusedTracks_Skip:
	scf	; F6FAFB  scf
	xorcf_a_16	de	; F6FAFC  xorcf A,DE
	jr	nc, Smf_ClearUnusedTracks_Skip2	; F6FAFE  jr NC,0xf6fb0e
	ld	(3184:16), c	; F6FB00  ld (0x0c70),C
	inc	1, (3184:16)	; F6FB04  inc 1,(0x0c70)
	pushw	bc	; F6FB08  push BC
	call	T_F40A04	; F6FB09  call 0xf40a04
	popw	bc	; F6FB0D  pop BC
Smf_ClearUnusedTracks_Skip2:
	inc	1, c	; F6FB0E  inc 1,C
	cp	c, 16	; F6FB10  cp C,0x10
	jr	ule, Smf_ClearUnusedTracks_Loop	; F6FB13  jr ULE,0xf6faea
	ret	; F6FB15  ret

; --------------------------------------------------------------------------
; Smf_SaveTrackEndCursor
; Called from: in-module: 0xF6FADB
; Touches: (0x345C) (0x345E)  |  0x60347E 0x6034A0
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6FB16 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_SaveTrackEndCursor: Track HL's (0-based) end cursor := the BStore cursor: 0x6034A0[HL] := BStore_CursorOffset,
;   0x60347E[HL] := BStore_CursorBlock. Smf_TerminateUsedTracks runs it for each track in use right after writing the
;   0x82 end tag at that track's cursor. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave7_y.json)
Smf_SaveTrackEndCursor:
	push	xix	; F6FB16  push XIX
	ld	wa, (BStore_CursorOffset:16)	; F6FB17  ld WA,(0x345e)
	ld	xix, 6304928	; F6FB1B  ld XIX,0x006034a0
	ld	(xix+hl), a	; F6FB20  ld (XIX+HL),A
	sla	hl, 1	; F6FB25  sla 0x01,HL
	ld	wa, (BStore_CursorBlock:16)	; F6FB28  ld WA,(0x345c)
	ld	xix, 6304894	; F6FB2C  ld XIX,0x0060347e
	ld	(xix+hl), wa	; F6FB31  ld (XIX+HL),WA
	pop	xix	; F6FB36  pop XIX
	ret	; F6FB37  ret

; --------------------------------------------------------------------------
; Smf_ClearPendingNoteSlots
; Called from: in-module: 0xF6F557 0xF71BAB
; Touches: nothing with an absolute address
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6FB38 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_ClearPendingNoteSlots: Clears byte 0 (bit 7 = in use | channel) of all 33 seven-byte pending-note records at
;   0x305A..0x313A, the slots SmfEvent_NoteOn fills and SmfEvent_NoteOff matches. Run by Smf_ReadFile before reading
;   and by Smf_ReadMultiTrack before each track chunk. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_h.json)
Smf_ClearPendingNoteSlots:
	ld	xhl, 12378	; F6FB38  ld XHL,0x0000305a
	xor	iy, iy	; F6FB3D  xor IY,IY
	xor	a, a	; F6FB3F  xor A,A
Smf_ClearPendingNoteSlots_Loop:
	ld	(xhl+iy), a	; F6FB41  ld (XHL+IY),A
	add	iy, 7	; F6FB46  add IY,0x0007
	cp	iy, 224	; F6FB4A  cp IY,0x00e0
	jr	ule, Smf_ClearPendingNoteSlots_Loop	; F6FB4E  jr ULE,0xf6fb41
	ret	; F6FB50  ret

; --------------------------------------------------------------------------
; SmfEvent_Meta
; Called from: in-module: 0xF6F6FB 0xF71CB4
; Touches: (0x10CB) (0x124A)
; Calls:   InputStream_GetByte Smf_ReadVlq Smf_SkipBytes SmfMeta_SetTempo
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6FB51 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_Meta: after an FF byte: reads the meta type; 0x2F (End of Track) reads its length byte and sets (0x10CB) = 0xFF;
;   0x51 (Set Tempo) reads two bytes and SmfMeta_SetTempo; 0x02, 0x03, 0x58 and every other type: Smf_ReadVlq for the
;   length and Smf_SkipBytes.
SmfEvent_Meta:
	calr	InputStream_GetByte	; F6FB51  calr 0xf7138f
	ld	w, (InputStream_Status:16)	; F6FB54  ld W,(0x124a)
	cp	w, 1:i3	; F6FB58  cp W,1
	jr	z, SmfEvent_Meta_Skip	; F6FB5A  jr Z,0xf6fb62
	cp	w, 253	; F6FB5C  cp W,0xfd
	jrl	nz, SmfEvent_Meta_Return	; F6FB5F  jrl NZ,0xf6fc0f
SmfEvent_Meta_Skip:
	ld	(4299:16), 0	; F6FB62  ld (0x10cb),0x00
	cp	a, 2:i3	; F6FB67  cp A,2
	jr	z, SmfEvent_Meta_Skip3	; F6FB69  jr Z,0xf6fb96
	cp	a, 3:i3	; F6FB6B  cp A,3
	jr	z, SmfEvent_Meta_Skip5	; F6FB6D  jr Z,0xf6fbab
	cp	a, 47	; F6FB6F  cp A,0x2f
	jr	z, SmfEvent_Meta_Skip7	; F6FB72  jr Z,0xf6fbc0
	cp	a, 81	; F6FB74  cp A,0x51
	jr	z, SmfEvent_Meta_Skip9	; F6FB77  jr Z,0xf6fbd7
	cp	a, 88	; F6FB79  cp A,0x58
	jrl	z, SmfEvent_Meta_Skip12	; F6FB7C  jrl Z,0xf6fbfc
	calr	Smf_ReadVlq	; F6FB7F  calr 0xf6fd7a
	ld	w, (InputStream_Status:16)	; F6FB82  ld W,(0x124a)
	cp	w, 1:i3	; F6FB86  cp W,1
	jr	z, SmfEvent_Meta_Skip2	; F6FB88  jr Z,0xf6fb90
	cp	w, 253	; F6FB8A  cp W,0xfd
	jrl	nz, SmfEvent_Meta_Return	; F6FB8D  jrl NZ,0xf6fc0f
SmfEvent_Meta_Skip2:
	calr	Smf_SkipBytes	; F6FB90  calr 0xf6fd91
	jrl	SmfEvent_Meta_Return	; F6FB93  jrl T,0xf6fc0f
SmfEvent_Meta_Skip3:
	calr	Smf_ReadVlq	; F6FB96  calr 0xf6fd7a
	ld	w, (InputStream_Status:16)	; F6FB99  ld W,(0x124a)
	cp	w, 1:i3	; F6FB9D  cp W,1
	jr	z, SmfEvent_Meta_Skip4	; F6FB9F  jr Z,0xf6fba6
	cp	w, 253	; F6FBA1  cp W,0xfd
	jr	nz, SmfEvent_Meta_Return	; F6FBA4  jr NZ,0xf6fc0f
SmfEvent_Meta_Skip4:
	calr	Smf_SkipBytes	; F6FBA6  calr 0xf6fd91
	jr	SmfEvent_Meta_Return	; F6FBA9  jr T,0xf6fc0f
SmfEvent_Meta_Skip5:
	calr	Smf_ReadVlq	; F6FBAB  calr 0xf6fd7a
	ld	w, (InputStream_Status:16)	; F6FBAE  ld W,(0x124a)
	cp	w, 1:i3	; F6FBB2  cp W,1
	jr	z, SmfEvent_Meta_Skip6	; F6FBB4  jr Z,0xf6fbbb
	cp	w, 253	; F6FBB6  cp W,0xfd
	jr	nz, SmfEvent_Meta_Return	; F6FBB9  jr NZ,0xf6fc0f
SmfEvent_Meta_Skip6:
	calr	Smf_SkipBytes	; F6FBBB  calr 0xf6fd91
	jr	SmfEvent_Meta_Return	; F6FBBE  jr T,0xf6fc0f
SmfEvent_Meta_Skip7:
	calr	InputStream_GetByte	; F6FBC0  calr 0xf7138f
	ld	w, (InputStream_Status:16)	; F6FBC3  ld W,(0x124a)
	cp	w, 1:i3	; F6FBC7  cp W,1
	jr	z, SmfEvent_Meta_Skip8	; F6FBC9  jr Z,0xf6fbd0
	cp	w, 253	; F6FBCB  cp W,0xfd
	jr	nz, SmfEvent_Meta_Return	; F6FBCE  jr NZ,0xf6fc0f
SmfEvent_Meta_Skip8:
	ld	(4299:16), 255	; F6FBD0  ld (0x10cb),0xff
	jr	SmfEvent_Meta_Return	; F6FBD5  jr T,0xf6fc0f
SmfEvent_Meta_Skip9:
	calr	InputStream_GetByte	; F6FBD7  calr 0xf7138f
	ld	w, (InputStream_Status:16)	; F6FBDA  ld W,(0x124a)
	cp	w, 1:i3	; F6FBDE  cp W,1
	jr	z, SmfEvent_Meta_Skip10	; F6FBE0  jr Z,0xf6fbe7
	cp	w, 253	; F6FBE2  cp W,0xfd
	jr	nz, SmfEvent_Meta_Return	; F6FBE5  jr NZ,0xf6fc0f
SmfEvent_Meta_Skip10:
	calr	InputStream_GetByte	; F6FBE7  calr 0xf7138f
	ld	w, (InputStream_Status:16)	; F6FBEA  ld W,(0x124a)
	cp	w, 1:i3	; F6FBEE  cp W,1
	jr	z, SmfEvent_Meta_Skip11	; F6FBF0  jr Z,0xf6fbf7
	cp	w, 253	; F6FBF2  cp W,0xfd
	jr	nz, SmfEvent_Meta_Return	; F6FBF5  jr NZ,0xf6fc0f
SmfEvent_Meta_Skip11:
	calr	SmfMeta_SetTempo	; F6FBF7  calr 0xf6fc10
	jr	SmfEvent_Meta_Return	; F6FBFA  jr T,0xf6fc0f
SmfEvent_Meta_Skip12:
	calr	Smf_ReadVlq	; F6FBFC  calr 0xf6fd7a
	ld	w, (InputStream_Status:16)	; F6FBFF  ld W,(0x124a)
	cp	w, 1:i3	; F6FC03  cp W,1
	jr	z, SmfEvent_Meta_Skip13	; F6FC05  jr Z,0xf6fc0c
	cp	w, 253	; F6FC07  cp W,0xfd
	jr	nz, SmfEvent_Meta_Return	; F6FC0A  jr NZ,0xf6fc0f
SmfEvent_Meta_Skip13:
	calr	Smf_SkipBytes	; F6FC0C  calr 0xf6fd91
SmfEvent_Meta_Return:
	ret	; F6FC0F  ret

; --------------------------------------------------------------------------
; SmfMeta_SetTempo
; Called from: in-module: 0xF6FBF7
; Touches: (0x1078) (0x107A) (0x108C) (0x108D) (0x108E) (0x108F) (0x11B2)
;          (0x1238) (0x124A) (0x360C) +1 more
; Calls:   InputStream_GetByte Smf_ClampTrackToSlot TrackCursor_Load BStore_PutByteAndAdvance Smf_TicksToPpq96 TrackCursor_Save
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6FC10 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfMeta_SetTempo: the Set Tempo meta event: the microseconds per quarter note (three bytes, the first in A) -> BPM = 234,375 /
;   (tempo >> 8), i.e. 60,000,000 / tempo, clamped to 40..300 -- the range Tempo_ApplyBpm accepts.
SmfMeta_SetTempo:
	ld	(SmfOut_Tempo+2:16), 0	; F6FC10  ld (0x108e),0x00
	ld	(4239:16), a	; F6FC15  ld (0x108f),A
	calr	InputStream_GetByte	; F6FC19  calr 0xf7138f
	ld	w, (InputStream_Status:16)	; F6FC1C  ld W,(0x124a)
	cp	w, 1:i3	; F6FC20  cp W,1
	jr	z, SmfMeta_SetTempo_Skip	; F6FC22  jr Z,0xf6fc2a
	cp	w, 253	; F6FC24  cp W,0xfd
	jrl	nz, SmfMeta_SetTempo_Return	; F6FC27  jrl NZ,0xf6fd79
SmfMeta_SetTempo_Skip:
	ld	(SmfOut_Tempo:16), a	; F6FC2A  ld (0x108c),A
	calr	InputStream_GetByte	; F6FC2E  calr 0xf7138f
	ld	w, (InputStream_Status:16)	; F6FC31  ld W,(0x124a)
	cp	w, 1:i3	; F6FC35  cp W,1
	jr	z, SmfMeta_SetTempo_Skip2	; F6FC37  jr Z,0xf6fc3f
	cp	w, 253	; F6FC39  cp W,0xfd
	jrl	nz, SmfMeta_SetTempo_Return	; F6FC3C  jrl NZ,0xf6fd79
SmfMeta_SetTempo_Skip2:
	ld	(SmfOut_Tempo+1:16), a	; F6FC3F  ld (0x108d),A
	ld	h, (4239:16)	; F6FC43  ld H,(0x108f)
	ld	l, (SmfOut_Tempo:16)	; F6FC47  ld L,(0x108c)
	ldw	wa, 37767	; F6FC4B  ld WA,0x9387
	ldw	de, 3	; F6FC4E  ld DE,0x0003
	ld	qwa, de	; F6FC51  ld QWA,DE
	div	xwa, hl	; F6FC54  div XWA,HL
	ld	de, qwa	; F6FC56  ld DE,QWA
	cp	wa, 40	; F6FC59  cp WA,0x0028
	jr	ugt, SmfMeta_SetTempo_Skip3	; F6FC5D  jr UGT,0xf6fc64
	ldw	wa, 40	; F6FC5F  ld WA,0x0028
	jr	SmfMeta_SetTempo_Join	; F6FC62  jr T,0xf6fc6d
SmfMeta_SetTempo_Skip3:
	cp	wa, 300	; F6FC64  cp WA,0x012c
	jr	c, SmfMeta_SetTempo_Join	; F6FC68  jr C,0xf6fc6d
	ldw	wa, 300	; F6FC6A  ld WA,0x012c
SmfMeta_SetTempo_Join:
	ld	hl, wa	; F6FC6D  ld HL,WA
	ld	w, a	; F6FC6F  ld W,A
	and	a, 127	; F6FC71  and A,0x7f
	and	w, 128	; F6FC74  and W,0x80
	rlc	w	; F6FC77  rlc 0x01,W
	and	h, 1	; F6FC7A  and H,0x01
	sla	h, 1	; F6FC7D  sla 0x01,H
	or	w, h	; F6FC80  or W,H
	ld	xiy, 16	; F6FC82  ld XIY,0x00000010
	cpw	(Smf_Format:16), 0x0000	; F6FC87  cp (0x1078),0x0000
	jr	z, SmfMeta_SetTempo_Skip4	; F6FC8D  jr Z,0xf6fca0
	cpw	(Smf_TrackCount:16), 0x0001	; F6FC8F  cp (0x107a),0x0001
	jr	z, SmfMeta_SetTempo_Skip4	; F6FC95  jr Z,0xf6fca0
	ld	iy, (4530:16)	; F6FC97  ld IY,(0x11b2)
	extz	xiy	; F6FC9B  extz XIY
	calr	Smf_ClampTrackToSlot	; F6FC9D  calr 0xf70c3f
SmfMeta_SetTempo_Skip4:
	pushw	wa	; F6FCA0  push WA
	calr	TrackCursor_Load	; F6FCA1  calr 0xf7124e
	popw	wa	; F6FCA4  pop WA
	ld	bc, wa	; F6FCA5  ld BC,WA
	ld	a, 128:opc	; F6FCA7  ld A,0x80
	cpw	(Smf_Format:16), 0x0000	; F6FCA9  cp (0x1078),0x0000
	jr	z, SmfMeta_SetTempo_Skip5	; F6FCAF  jr Z,0xf6fcbf
	cpw	(Smf_TrackCount:16), 0x0001	; F6FCB1  cp (0x107a),0x0001
	jr	z, SmfMeta_SetTempo_Skip5	; F6FCB7  jr Z,0xf6fcbf
	ld	a, 160:opc	; F6FCB9  ld A,0xa0
	ld	w, 7:opc	; F6FCBB  ld W,0x07
	or	a, w	; F6FCBD  or A,W
SmfMeta_SetTempo_Skip5:
	pushw	bc	; F6FCBF  push BC
	calr	BStore_PutByteAndAdvance	; F6FCC0  calr 0xf70fda
	popw	bc	; F6FCC3  pop BC
	cp	(0x1238:16), 0x00	; F6FCC4  cp (0x1238),0x00
	jrl	nz, SmfMeta_SetTempo_Return	; F6FCC9  jrl NZ,0xf6fd79
	ldw	iy, 16	; F6FCCC  ld IY,0x0010
	cpw	(Smf_Format:16), 0x0000	; F6FCCF  cp (0x1078),0x0000
	jr	z, SmfMeta_SetTempo_Skip6	; F6FCD5  jr Z,0xf6fce8
	cpw	(Smf_TrackCount:16), 0x0001	; F6FCD7  cp (0x107a),0x0001
	jr	z, SmfMeta_SetTempo_Skip6	; F6FCDD  jr Z,0xf6fce8
	ld	iy, (4530:16)	; F6FCDF  ld IY,(0x11b2)
	extz	xiy	; F6FCE3  extz XIY
	calr	Smf_ClampTrackToSlot	; F6FCE5  calr 0xf70c3f
SmfMeta_SetTempo_Skip6:
	sla	iy, 1	; F6FCE8  sla 0x01,IY
	push	xix	; F6FCEB  push XIX
	ld	xix, 4307	; F6FCEC  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F6FCF1  ld WA,(XIX+IY)
	pop	xix	; F6FCF6  pop XIX
	srl	iy, 1	; F6FCF7  srl 0x01,IY
	pushw	bc	; F6FCFA  push BC
	push	xiy	; F6FCFB  push XIY
	calr	Smf_TicksToPpq96	; F6FCFC  calr 0xf7122f
	pop	xiy	; F6FCFF  pop XIY
	popw	bc	; F6FD00  pop BC
	pushw	bc	; F6FD01  push BC
	push	xiy	; F6FD02  push XIY
	calr	BStore_PutByteAndAdvance	; F6FD03  calr 0xf70fda
	pop	xiy	; F6FD06  pop XIY
	popw	bc	; F6FD07  pop BC
	cp	(0x1238:16), 0x00	; F6FD08  cp (0x1238),0x00
	jr	nz, SmfMeta_SetTempo_Return	; F6FD0D  jr NZ,0xf6fd79
	ld	a, c	; F6FD0F  ld A,C
	pushw	bc	; F6FD11  push BC
	push	xiy	; F6FD12  push XIY
	calr	BStore_PutByteAndAdvance	; F6FD13  calr 0xf70fda
	pop	xiy	; F6FD16  pop XIY
	popw	bc	; F6FD17  pop BC
	cp	(0x1238:16), 0x00	; F6FD18  cp (0x1238),0x00
	jr	nz, SmfMeta_SetTempo_Return	; F6FD1D  jr NZ,0xf6fd79
	ld	a, b	; F6FD1F  ld A,B
	push	xiy	; F6FD21  push XIY
	calr	BStore_PutByteAndAdvance	; F6FD22  calr 0xf70fda
	pop	xiy	; F6FD25  pop XIY
	cp	(0x1238:16), 0x00	; F6FD26  cp (0x1238),0x00
	jr	nz, SmfMeta_SetTempo_Return	; F6FD2B  jr NZ,0xf6fd79
	ld	xiy, 16	; F6FD2D  ld XIY,0x00000010
	cpw	(Smf_Format:16), 0x0000	; F6FD32  cp (0x1078),0x0000
	jr	z, SmfMeta_SetTempo_Skip7	; F6FD38  jr Z,0xf6fd4b
	cpw	(Smf_TrackCount:16), 0x0001	; F6FD3A  cp (0x107a),0x0001
	jr	z, SmfMeta_SetTempo_Skip7	; F6FD40  jr Z,0xf6fd4b
	ld	iy, (4530:16)	; F6FD42  ld IY,(0x11b2)
	extz	xiy	; F6FD46  extz XIY
	calr	Smf_ClampTrackToSlot	; F6FD48  calr 0xf70c3f
SmfMeta_SetTempo_Skip7:
	ld	bc, iy	; F6FD4B  ld BC,IY
	ld	de, (13836:16)	; F6FD4D  ld DE,(0x360c)
	ld	a, c	; F6FD51  ld A,C
	cp	a, 16	; F6FD53  cp A,0x10
	jr	lt, SmfMeta_SetTempo_Skip8	; F6FD56  jr LT,0xf6fd5f
	ld	de, (13838:16)	; F6FD58  ld DE,(0x360e)
	sub	a, 16	; F6FD5C  sub A,0x10
SmfMeta_SetTempo_Skip8:
	scf	; F6FD5F  scf
	stcf_a_16	de	; F6FD60  stcf A,DE
	cp	c, 16	; F6FD62  cp C,0x10
	jr	lt, SmfMeta_SetTempo_Skip9	; F6FD65  jr LT,0xf6fd6d
	ld	(13838:16), de	; F6FD67  ld (0x360e),DE
	jr	SmfMeta_SetTempo_Join2	; F6FD6B  jr T,0xf6fd71
SmfMeta_SetTempo_Skip9:
	ld	(13836:16), de	; F6FD6D  ld (0x360c),DE
SmfMeta_SetTempo_Join2:
	calr	TrackCursor_Save	; F6FD71  calr 0xf71275
	ld	(4664:16), 0	; F6FD74  ld (0x1238),0x00
SmfMeta_SetTempo_Return:
	ret	; F6FD79  ret

; --------------------------------------------------------------------------
; Smf_ReadVlq
; Called from: in-module: 0xF6FB7F 0xF6FB96 0xF6FBAB 0xF6FBFC 0xF71525
; Touches: (0x124A)
; Calls:   Smf_ClearVlqBytes Smf_ReadVlqBytes Smf_DecodeVlq
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6FD7A is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_ReadVlq: Smf_ClearVlqBytes, Smf_ReadVlqBytes, and on a good read Smf_DecodeVlq.
Smf_ReadVlq:
	calr	Smf_ClearVlqBytes	; F6FD7A  calr 0xf6fde4
	calr	Smf_ReadVlqBytes	; F6FD7D  calr 0xf6fdf5
	ld	w, (InputStream_Status:16)	; F6FD80  ld W,(0x124a)
	cp	w, 1:i3	; F6FD84  cp W,1
	jr	z, Smf_ReadVlq_Skip	; F6FD86  jr Z,0xf6fd8d
	cp	w, 253	; F6FD88  cp W,0xfd
	jr	nz, Smf_ReadVlq_Return	; F6FD8B  jr NZ,0xf6fd90
Smf_ReadVlq_Skip:
	calr	Smf_DecodeVlq	; F6FD8D  calr 0xf6fe1b
Smf_ReadVlq_Return:
	ret	; F6FD90  ret

; --------------------------------------------------------------------------
; Smf_SkipBytes
; Called from: in-module: 0xF6FB90 0xF6FBA6 0xF6FBBB 0xF6FC0C 0xF71693
; Touches: (0x1088) (0x1198) (0x1238) (0x1248) (0x124A)  |  0x60AAFF
; Calls:   InputStream_Refill T_DiskProgress_PrintDotForSmf
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6FD91 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_SkipBytes: advances InputStream_Cursor by Smf_VlqValue, refilling the 1 KB input window (InputStream_Refill) when it passes
;   0x60AAFF.
Smf_SkipBytes:
	ld	(InputStream_Status:16), 1	; F6FD91  ld (0x124a),0x01
	ld	xix, (InputStream_Cursor:16)	; F6FD96  ld XIX,(0x1088)
	add	xix, (Smf_VlqValue:16)	; F6FD9A  add XIX,(0x1198)
	cp	xix, 6335231	; F6FD9E  cp XIX,0x0060aaff
	jr	ule, Smf_SkipBytes_Skip2	; F6FDA4  jr ULE,0xf6fdda
	push	xix	; F6FDA6  push XIX
	calr	InputStream_Refill	; F6FDA7  calr 0xf765d4
	pop	xix	; F6FDAA  pop XIX
	incw	1, (4680:16)	; F6FDAB  incw 1,(0x1248)
	pushw	wa	; F6FDAF  push WA
	push	xhl	; F6FDB0  push XHL
	pushw	de	; F6FDB1  push DE
	ld	wa, (4680:16)	; F6FDB2  ld WA,(0x1248)
	xor	de, de	; F6FDB6  xor DE,DE
	ldw	hl, 4	; F6FDB8  ld HL,0x0004
	ld	qwa, de	; F6FDBB  ld QWA,DE
	div	xwa, hl	; F6FDBE  div XWA,HL
	ld	de, qwa	; F6FDC0  ld DE,QWA
	cp	de, 0:i3	; F6FDC3  cp DE,0
	jr	nz, Smf_SkipBytes_Skip	; F6FDC5  jr NZ,0xf6fdcd
	push	xix	; F6FDC7  push XIX
	call	T_DiskProgress_PrintDotForSmf	; F6FDC8  call 0xf42604
	pop	xix	; F6FDCC  pop XIX
Smf_SkipBytes_Skip:
	popw	de	; F6FDCD  pop DE
	pop	xhl	; F6FDCE  pop XHL
	popw	wa	; F6FDCF  pop WA
	sub	xix, 1024	; F6FDD0  sub XIX,0x00000400
	ld	(InputStream_Status:16), a	; F6FDD6  ld (0x124a),A
Smf_SkipBytes_Skip2:
	ld	(InputStream_Cursor:16), xix	; F6FDDA  ld (0x1088),XIX
	ld	(4664:16), 0	; F6FDDE  ld (0x1238),0x00
	ret	; F6FDE3  ret

; --------------------------------------------------------------------------
; Smf_ClearVlqBytes
; Called from: in-module: 0xF6FD7A
; Touches: nothing with an absolute address
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6FDE4 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_ClearVlqBytes: the two words at 0x1193 (the raw bytes) = 0.
Smf_ClearVlqBytes:
	xor	wa, wa	; F6FDE4  xor WA,WA
	ld	xix, Smf_VlqBytes	; F6FDE6  ld XIX,0x00001193
	ldw	bc, 2	; F6FDEB  ld BC,0x0002
	ld	(xix+), wa	; F6FDEE  ld (XIX+),WA
	djnz16	bc, -6	; F6FDF1  djnz BC,0xf6fdee
	ret	; F6FDF4  ret

; --------------------------------------------------------------------------
; Smf_ReadVlqBytes
; Called from: in-module: 0xF6FD7D
; Touches: (0x124A)
; Calls:   InputStream_GetByte
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6FDF5 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_ReadVlqBytes: reads input bytes (InputStream_GetByte) to 0x1193 while bit 7 is set -- an SMF variable-length quantity; IX = its length.
Smf_ReadVlqBytes:
	ld	xix, Smf_VlqBytes	; F6FDF5  ld XIX,0x00001193
Smf_ReadVlqBytes_Loop:
	push	xix	; F6FDFA  push XIX
	calr	InputStream_GetByte	; F6FDFB  calr 0xf7138f
	pop	xix	; F6FDFE  pop XIX
	ld	w, (InputStream_Status:16)	; F6FDFF  ld W,(0x124a)
	cp	w, 1:i3	; F6FE03  cp W,1
	jr	z, Smf_ReadVlqBytes_Skip	; F6FE05  jr Z,0xf6fe0c
	cp	w, 253	; F6FE07  cp W,0xfd
	jr	nz, Smf_ReadVlqBytes_Return	; F6FE0A  jr NZ,0xf6fe1a
Smf_ReadVlqBytes_Skip:
	ld	(xix+), a	; F6FE0C  ld (XIX+),A
	bit	7, a	; F6FE0F  bit 0x07,A
	jr	nz, Smf_ReadVlqBytes_Loop	; F6FE12  jr NZ,0xf6fdfa
	sub	xix, Smf_VlqBytes	; F6FE14  sub XIX,0x00001193
Smf_ReadVlqBytes_Return:
	ret	; F6FE1A  ret

; --------------------------------------------------------------------------
; Smf_DecodeVlq
; Called from: in-module: 0xF6F6CE 0xF6FD8D 0xF71C87
; Touches: (0x1193) (0x1194) (0x1195) (0x1198) (0x1199) (0x119A)
; Calls:   Smf_ClearVlqValue
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6FE1B is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_DecodeVlq: packs IX = 1, 2 or 3 raw bytes' low 7 bits, most significant first, into the 24-bit value at 0x1198..0x119A.
Smf_DecodeVlq:
	calr	Smf_ClearVlqValue	; F6FE1B  calr 0xf6fe96
	cp	ix, 1:i3	; F6FE1E  cp IX,1
	jr	z, Smf_DecodeVlq_Skip	; F6FE20  jr Z,0xf6fe28
	cp	ix, 2:i3	; F6FE22  cp IX,2
	jr	z, Smf_DecodeVlq_Skip2	; F6FE24  jr Z,0xf6fe35
	jr	Smf_DecodeVlq_Join	; F6FE26  jr T,0xf6fe5a
Smf_DecodeVlq_Skip:
	ld	a, (Smf_VlqBytes:16)	; F6FE28  ld A,(0x1193)
	and	a, 127	; F6FE2C  and A,0x7f
	ld	(Smf_VlqValue:16), a	; F6FE2F  ld (0x1198),A
	jr	Smf_DecodeVlq_Return	; F6FE33  jr T,0xf6fe95
Smf_DecodeVlq_Skip2:
	ld	a, (Smf_VlqBytes:16)	; F6FE35  ld A,(0x1193)
	and	a, 127	; F6FE39  and A,0x7f
	rrc	a	; F6FE3C  rrc 0x01,A
	ld	w, a	; F6FE3F  ld W,A
	and	a, 127	; F6FE41  and A,0x7f
	and	w, 128	; F6FE44  and W,0x80
	ld	l, (4500:16)	; F6FE47  ld L,(0x1194)
	and	l, 127	; F6FE4B  and L,0x7f
	or	l, w	; F6FE4E  or L,W
	ld	(4505:16), a	; F6FE50  ld (0x1199),A
	ld	(Smf_VlqValue:16), l	; F6FE54  ld (0x1198),L
	jr	Smf_DecodeVlq_Return	; F6FE58  jr T,0xf6fe95
Smf_DecodeVlq_Join:
	ld	a, (Smf_VlqBytes:16)	; F6FE5A  ld A,(0x1193)
	and	a, 127	; F6FE5E  and A,0x7f
	.byte 0xC9, 0xE9, 0x02	; F6FE61  rrc 0x02,A   [llvm-mc cannot encode this]
	ld	w, a	; F6FE64  ld W,A
	and	a, 63	; F6FE66  and A,0x3f
	and	w, 192	; F6FE69  and W,0xc0
	ld	l, (4500:16)	; F6FE6C  ld L,(0x1194)
	and	l, 127	; F6FE70  and L,0x7f
	rrc	l	; F6FE73  rrc 0x01,L
	ld	h, l	; F6FE76  ld H,L
	and	l, 127	; F6FE78  and L,0x7f
	and	h, 128	; F6FE7B  and H,0x80
	or	l, w	; F6FE7E  or L,W
	ld	c, (4501:16)	; F6FE80  ld C,(0x1195)
	and	c, 127	; F6FE84  and C,0x7f
	or	c, h	; F6FE87  or C,H
	ld	(4506:16), a	; F6FE89  ld (0x119a),A
	ld	(4505:16), l	; F6FE8D  ld (0x1199),L
	ld	(Smf_VlqValue:16), c	; F6FE91  ld (0x1198),C
Smf_DecodeVlq_Return:
	ret	; F6FE95  ret

; --------------------------------------------------------------------------
; Smf_ClearVlqValue
; Called from: in-module: 0xF6FE1B
; Touches: (0x1198) (0x119A)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6FE96 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_ClearVlqValue: the decoded value words (0x1198), (0x119A) = 0.
Smf_ClearVlqValue:
	xor	wa, wa	; F6FE96  xor WA,WA
	ld	(Smf_VlqValue:16), wa	; F6FE98  ld (0x1198),WA
	ld	(4506:16), wa	; F6FE9C  ld (0x119a),WA
	ret	; F6FEA0  ret

; --------------------------------------------------------------------------
; SmfEvent_ReadWithRunningStatus
; Called from: in-module: 0xF6F766 0xF71D30
; Touches: (0x1078) (0x107A) (0x10CC) (0x124A)
; Calls:   InputStream_GetByte SmfEvent_DispatchChannelMessage_MultiTrack SmfEvent_DispatchChannelMessage
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6FEA1 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_ReadWithRunningStatus: A is a data byte: the status is the running status (0x10CC); A and the remaining data bytes to 0x10D1..; then
;   SmfEvent_DispatchChannelMessage for a format-0 or one-track file, SmfEvent_DispatchChannelMessage_MultiTrack otherwise.
SmfEvent_ReadWithRunningStatus:
	ld	c, a	; F6FEA1  ld C,A
	ld	a, (Smf_RunningStatus:16)	; F6FEA3  ld A,(0x10cc)
	ld	l, a	; F6FEA7  ld L,A
	and	l, 240	; F6FEA9  and L,0xf0
	ld	xix, Smf_EventStatus	; F6FEAC  ld XIX,0x000010d0
	ld	(xix+), a	; F6FEB1  ld (XIX+),A
	xor	h, h	; F6FEB4  xor H,H
	ld	a, c	; F6FEB6  ld A,C
SmfEvent_ReadWithRunningStatus_Loop:
	ld	(xix+), a	; F6FEB8  ld (XIX+),A
	inc	1, h	; F6FEBB  inc 1,H
	ld	c, 1:opc	; F6FEBD  ld C,0x01
	cp	l, 208	; F6FEBF  cp L,0xd0
	jr	z, SmfEvent_ReadWithRunningStatus_Skip	; F6FEC2  jr Z,0xf6fec9
	cp	l, 192	; F6FEC4  cp L,0xc0
	jr	nz, SmfEvent_ReadWithRunningStatus_Skip2	; F6FEC7  jr NZ,0xf6fecb
SmfEvent_ReadWithRunningStatus_Skip:
	ld	c, 0:opc	; F6FEC9  ld C,0x00
SmfEvent_ReadWithRunningStatus_Skip2:
	cp	h, c	; F6FECB  cp H,C
	jr	ugt, SmfEvent_ReadWithRunningStatus_Skip3	; F6FECD  jr UGT,0xf6fee5
	pushw	hl	; F6FECF  push HL
	push	xix	; F6FED0  push XIX
	calr	InputStream_GetByte	; F6FED1  calr 0xf7138f
	pop	xix	; F6FED4  pop XIX
	popw	hl	; F6FED5  pop HL
	ld	w, (InputStream_Status:16)	; F6FED6  ld W,(0x124a)
	cp	w, 1:i3	; F6FEDA  cp W,1
	jr	z, SmfEvent_ReadWithRunningStatus_Loop	; F6FEDC  jr Z,0xf6feb8
	cp	w, 253	; F6FEDE  cp W,0xfd
	jr	nz, SmfEvent_ReadWithRunningStatus_Return	; F6FEE1  jr NZ,0xf6fefd
	jr	SmfEvent_ReadWithRunningStatus_Loop	; F6FEE3  jr T,0xf6feb8
SmfEvent_ReadWithRunningStatus_Skip3:
	cpw	(Smf_Format:16), 0x0000	; F6FEE5  cp (0x1078),0x0000
	jr	z, SmfEvent_ReadWithRunningStatus_Skip4	; F6FEEB  jr Z,0xf6fefa
	cpw	(Smf_TrackCount:16), 0x0001	; F6FEED  cp (0x107a),0x0001
	jr	z, SmfEvent_ReadWithRunningStatus_Skip4	; F6FEF3  jr Z,0xf6fefa
	calr	SmfEvent_DispatchChannelMessage_MultiTrack	; F6FEF5  calr 0xf71db7
	jr	SmfEvent_ReadWithRunningStatus_Return	; F6FEF8  jr T,0xf6fefd
SmfEvent_ReadWithRunningStatus_Skip4:
	calr	SmfEvent_DispatchChannelMessage	; F6FEFA  calr 0xf6ff44
SmfEvent_ReadWithRunningStatus_Return:
	ret	; F6FEFD  ret

; --------------------------------------------------------------------------
; SmfEvent_ReadWithNewStatus
; Called from: in-module: 0xF6F74C
; Touches: (0x10CC) (0x124A)
; Calls:   InputStream_GetByte SmfEvent_DispatchChannelMessage
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6FEFE is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_ReadWithNewStatus: A is a status byte: (0x10CC) = it (the running status), (0x10D0) = it, then one data byte for 0xCn / 0xDn and two
;   otherwise to 0x10D1..; then SmfEvent_DispatchChannelMessage.
SmfEvent_ReadWithNewStatus:
	ld	(Smf_RunningStatus:16), a	; F6FEFE  ld (0x10cc),A
	xor	bc, bc	; F6FF02  xor BC,BC
	ld	xix, Smf_EventStatus	; F6FF04  ld XIX,0x000010d0
	ld	(xix+), a	; F6FF09  ld (XIX+),A
	inc	1, c	; F6FF0C  inc 1,C
SmfEvent_ReadWithNewStatus_Loop:
	pushw	bc	; F6FF0E  push BC
	push	xix	; F6FF0F  push XIX
	calr	InputStream_GetByte	; F6FF10  calr 0xf7138f
	pop	xix	; F6FF13  pop XIX
	popw	bc	; F6FF14  pop BC
	ld	w, (InputStream_Status:16)	; F6FF15  ld W,(0x124a)
	cp	w, 1:i3	; F6FF19  cp W,1
	jr	z, SmfEvent_ReadWithNewStatus_Skip	; F6FF1B  jr Z,0xf6ff22
	cp	w, 253	; F6FF1D  cp W,0xfd
	jr	nz, SmfEvent_ReadWithNewStatus_Return	; F6FF20  jr NZ,0xf6ff43
SmfEvent_ReadWithNewStatus_Skip:
	ld	(xix+), a	; F6FF22  ld (XIX+),A
	inc	1, c	; F6FF25  inc 1,C
	ld	a, (Smf_RunningStatus:16)	; F6FF27  ld A,(0x10cc)
	and	a, 240	; F6FF2B  and A,0xf0
	ld	w, 2:opc	; F6FF2E  ld W,0x02
	cp	a, 208	; F6FF30  cp A,0xd0
	jr	z, SmfEvent_ReadWithNewStatus_Skip2	; F6FF33  jr Z,0xf6ff3a
	cp	a, 192	; F6FF35  cp A,0xc0
	jr	nz, SmfEvent_ReadWithNewStatus_Skip3	; F6FF38  jr NZ,0xf6ff3c
SmfEvent_ReadWithNewStatus_Skip2:
	ld	w, 1:opc	; F6FF3A  ld W,0x01
SmfEvent_ReadWithNewStatus_Skip3:
	cp	c, w	; F6FF3C  cp C,W
	jr	ule, SmfEvent_ReadWithNewStatus_Loop	; F6FF3E  jr ULE,0xf6ff0e
	calr	SmfEvent_DispatchChannelMessage	; F6FF40  calr 0xf6ff44
SmfEvent_ReadWithNewStatus_Return:
	ret	; F6FF43  ret

; --------------------------------------------------------------------------
; SmfEvent_DispatchChannelMessage
; Called from: in-module: 0xF6FEFA 0xF6FF40
; Touches: (0x10D0) (0x10D1)
; Calls:   SmfEvent_ChannelPressure SmfEvent_NoteOn SmfEvent_NoteOff SmfEvent_ControlChange SmfEvent_PitchBend SmfEvent_ProgramChange
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6FF44 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_DispatchChannelMessage: clamps both data bytes to 127 and dispatches on the status's high nibble: 0x90 with velocity > 0 SmfEvent_NoteOn,
;   0x80 or velocity 0 SmfEvent_NoteOff, 0xB0 _ControlChange, 0xE0 _PitchBend, 0xC0 _ProgramChange, 0xD0 _ChannelPressure;
;   0xA0 (polyphonic pressure) is dropped.
SmfEvent_DispatchChannelMessage:
	ld	xix, Smf_EventStatus	; F6FF44  ld XIX,0x000010d0
	ld	a, (Smf_EventStatus:16)	; F6FF49  ld A,(0x10d0)
	pushw	hl	; F6FF4D  push HL
	ld	hl, (4305:16)	; F6FF4E  ld HL,(0x10d1)
	cp	l, 127	; F6FF52  cp L,0x7f
	jr	ule, SmfEvent_DispatchChannelMessage_Skip	; F6FF55  jr ULE,0xf6ff59
	ld	l, 127:opc	; F6FF57  ld L,0x7f
SmfEvent_DispatchChannelMessage_Skip:
	cp	h, 127	; F6FF59  cp H,0x7f
	jr	ule, SmfEvent_DispatchChannelMessage_Skip2	; F6FF5C  jr ULE,0xf6ff60
	ld	h, 127:opc	; F6FF5E  ld H,0x7f
SmfEvent_DispatchChannelMessage_Skip2:
	ld	(4305:16), hl	; F6FF60  ld (0x10d1),HL
	popw	hl	; F6FF64  pop HL
	ld	w, a	; F6FF65  ld W,A
	and	w, 240	; F6FF67  and W,0xf0
	cp	w, 144	; F6FF6A  cp W,0x90
	jr	z, SmfEvent_DispatchChannelMessage_Skip4	; F6FF6D  jr Z,0xf6ff8f
	cp	w, 176	; F6FF6F  cp W,0xb0
	jr	z, SmfEvent_DispatchChannelMessage_Skip6	; F6FF72  jr Z,0xf6ffa0
	cp	w, 128	; F6FF74  cp W,0x80
	jr	z, SmfEvent_DispatchChannelMessage_Skip5	; F6FF77  jr Z,0xf6ff9b
	cp	w, 224	; F6FF79  cp W,0xe0
	jr	z, SmfEvent_DispatchChannelMessage_Skip7	; F6FF7C  jr Z,0xf6ffa5
	cp	w, 192	; F6FF7E  cp W,0xc0
	jr	z, SmfEvent_DispatchChannelMessage_Skip8	; F6FF81  jr Z,0xf6ffaa
	cp	w, 208	; F6FF83  cp W,0xd0
	jr	z, SmfEvent_DispatchChannelMessage_Skip3	; F6FF86  jr Z,0xf6ff8a
	jr	SmfEvent_DispatchChannelMessage_Return	; F6FF88  jr T,0xf6ffad
SmfEvent_DispatchChannelMessage_Skip3:
	calr	SmfEvent_ChannelPressure	; F6FF8A  calr 0xf6ffae
	jr	SmfEvent_DispatchChannelMessage_Return	; F6FF8D  jr T,0xf6ffad
SmfEvent_DispatchChannelMessage_Skip4:
	ld	w, (xix+2)	; F6FF8F  ld W,(XIX+0x02)
	cp	w, 0:i3	; F6FF92  cp W,0
	jr	z, SmfEvent_DispatchChannelMessage_Skip5	; F6FF94  jr Z,0xf6ff9b
	calr	SmfEvent_NoteOn	; F6FF96  calr 0xf70ed5
	jr	SmfEvent_DispatchChannelMessage_Return	; F6FF99  jr T,0xf6ffad
SmfEvent_DispatchChannelMessage_Skip5:
	calr	SmfEvent_NoteOff	; F6FF9B  calr 0xf71023
	jr	SmfEvent_DispatchChannelMessage_Return	; F6FF9E  jr T,0xf6ffad
SmfEvent_DispatchChannelMessage_Skip6:
	calr	SmfEvent_ControlChange	; F6FFA0  calr 0xf7039a
	jr	SmfEvent_DispatchChannelMessage_Return	; F6FFA3  jr T,0xf6ffad
SmfEvent_DispatchChannelMessage_Skip7:
	calr	SmfEvent_PitchBend	; F6FFA5  calr 0xf70330
	jr	SmfEvent_DispatchChannelMessage_Return	; F6FFA8  jr T,0xf6ffad
SmfEvent_DispatchChannelMessage_Skip8:
	calr	SmfEvent_ProgramChange	; F6FFAA  calr 0xf70008
SmfEvent_DispatchChannelMessage_Return:
	ret	; F6FFAD  ret

; --------------------------------------------------------------------------
; SmfEvent_ChannelPressure
; Called from: in-module: 0xF6FF8A
; Touches: (0x10D0) (0x10D1) (0x1238)
; Calls:   TrackCursor_Load BStore_PutByteAndAdvance Smf_TicksToPpq96 SmfEvent_MarkChannelUsed TrackCursor_Save
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF6FFAE is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_ChannelPressure: the arm for status 0xDn: to the channel's track (TrackCursor_Load) song code 0xD0, the delta time
;   (Smf_TicksToPpq96 of the track's word at 0x10D3) and the pressure; then TrackCursor_Save.
SmfEvent_ChannelPressure:
	ld	iy, (Smf_EventStatus:16)	; F6FFAE  ld IY,(0x10d0)
	and	iy, 15	; F6FFB2  and IY,0x000f
	extz	xiy	; F6FFB6  extz XIY
	push	xiy	; F6FFB8  push XIY
	calr	TrackCursor_Load	; F6FFB9  calr 0xf7124e
	ld	a, 208:opc	; F6FFBC  ld A,0xd0
	calr	BStore_PutByteAndAdvance	; F6FFBE  calr 0xf70fda
	pop	xiy	; F6FFC1  pop XIY
	cp	(0x1238:16), 0x00	; F6FFC2  cp (0x1238),0x00
	jr	nz, SmfEvent_ChannelPressure_Return	; F6FFC7  jr NZ,0xf70007
	sla	xiy, 1	; F6FFC9  sla 0x01,XIY
	push	xix	; F6FFCC  push XIX
	ld	xix, 4307	; F6FFCD  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F6FFD2  ld WA,(XIX+IY)
	pop	xix	; F6FFD7  pop XIX
	srl	xiy, 1	; F6FFD8  srl 0x01,XIY
	push	xiy	; F6FFDB  push XIY
	calr	Smf_TicksToPpq96	; F6FFDC  calr 0xf7122f
	pop	xiy	; F6FFDF  pop XIY
	push	xiy	; F6FFE0  push XIY
	calr	BStore_PutByteAndAdvance	; F6FFE1  calr 0xf70fda
	pop	xiy	; F6FFE4  pop XIY
	cp	(0x1238:16), 0x00	; F6FFE5  cp (0x1238),0x00
	jr	nz, SmfEvent_ChannelPressure_Return	; F6FFEA  jr NZ,0xf70007
	ld	a, (4305:16)	; F6FFEC  ld A,(0x10d1)
	push	xiy	; F6FFF0  push XIY
	calr	BStore_PutByteAndAdvance	; F6FFF1  calr 0xf70fda
	pop	xiy	; F6FFF4  pop XIY
	cp	(0x1238:16), 0x00	; F6FFF5  cp (0x1238),0x00
	jr	nz, SmfEvent_ChannelPressure_Return	; F6FFFA  jr NZ,0xf70007
	calr	SmfEvent_MarkChannelUsed	; F6FFFC  calr 0xf7129a
	calr	TrackCursor_Save	; F6FFFF  calr 0xf71275
	ld	(4664:16), 0	; F70002  ld (0x1238),0x00
SmfEvent_ChannelPressure_Return:
	ret	; F70007  ret

; --------------------------------------------------------------------------
; SmfEvent_ProgramChange
; Called from: in-module: 0xF6FFAA
; Touches: (0x10D0) (0x10D1) (0x11B1) (0x1238) (0x1239) (0x124B) (0x2732)
; Calls:   SmfPart_ResetAllRecords SmfPart_SetSoundFromProgramChange T_PartSound_FromProgramChange TrackCursor_Load BStore_PutByteAndAdvance Smf_TicksToPpq96
;          SmfEvent_MarkChannelUsed TrackCursor_Save
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF70008 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_ProgramChange: the arm for status 0xCn.
SmfEvent_ProgramChange:
	bit	0, (0x124b:16)	; F70008  bit 0,(0x124b)
	jr	nz, SmfEvent_ProgramChange_Skip2	; F7000C  jr NZ,0xf70027
	ld	(4665:16), 255	; F7000E  ld (0x1239),0xff
	cp	(0x2732:16), 0x00	; F70013  cp (0x2732),0x00
	jr	nz, SmfEvent_ProgramChange_Skip	; F70018  jr NZ,0xf7001f
	ld	(4665:16), 0	; F7001A  ld (0x1239),0x00
SmfEvent_ProgramChange_Skip:
	ld	(4683:16), 1	; F7001F  ld (0x124b),0x01
	calr	SmfPart_ResetAllRecords	; F70024  calr 0xf71417
SmfEvent_ProgramChange_Skip2:
	ld	iy, (Smf_EventStatus:16)	; F70027  ld IY,(0x10d0)
	and	iy, 15	; F7002B  and IY,0x000f
	extz	xiy	; F7002F  extz XIY
SmfEvent_ProgramChange_Loop:
	bit	0, (0x11b1:16)	; F70031  bit 0,(0x11b1)
	jr	nz, SmfEvent_ProgramChange_Skip3	; F70035  jr NZ,0xf7003f
	calr	SmfPart_SetSoundFromProgramChange	; F70037  calr 0xf701f1
	ld	(4664:16), 0	; F7003A  ld (0x1238),0x00
SmfEvent_ProgramChange_Skip3:
	cp	(0x1239:16), 0x00	; F7003F  cp (0x1239),0x00
	jrl	z, SmfEvent_ProgramChange_Skip4	; F70044  jrl Z,0xf7013f
	push	xix	; F70047  push XIX
	ld	xix, 4260	; F70048  ld XIX,0x000010a4
	ld	l, (xix+iy)	; F7004D  ld L,(XIX+IY)
	ld	(SoundConv_Arg0:24), l	; F70052  ld (0x60f010),L
	ld	xix, 4242	; F70057  ld XIX,0x00001092
	ld	l, (xix+iy)	; F7005C  ld L,(XIX+IY)
	ld	(SoundConv_Arg1:24), l	; F70061  ld (0x60f011),L
	ld	l, (4305:16)	; F70066  ld L,(0x10d1)
	ld	(SoundConv_Arg2:24), l	; F7006A  ld (0x60f012),L
	ld	xix, ByteMap_F70298 + 0x10	; F7006F  ld XIX,0x00f702a8
	ld	l, (xix+iy)	; F70074  ld L,(XIX+IY)
	ld	(SoundConv_Arg3:24), l	; F70079  ld (0x60f013),L
	pop	xix	; F7007E  pop XIX
	call	T_PartSound_FromProgramChange	; F7007F  call 0xf41004
	push	xiy	; F70083  push XIY
	push	xhl	; F70084  push XHL
	calr	TrackCursor_Load	; F70085  calr 0xf7124e
	pop	xhl	; F70088  pop XHL
	ld	a, 192:opc	; F70089  ld A,0xc0
	ld	w, (SoundConv_Result0:24)	; F7008B  ld W,(0x60f014)
	and	w, 128	; F70090  and W,0x80
	rlc	w	; F70093  rlc 0x01,W
	or	a, w	; F70096  or A,W
	ld	w, (SoundConv_Result1:24)	; F70098  ld W,(0x60f015)
	and	w, 128	; F7009D  and W,0x80
	.byte 0xC8, 0xE8, 0x02	; F700A0  rlc 0x02,W   [llvm-mc cannot encode this]
	or	a, w	; F700A3  or A,W
	push	xhl	; F700A5  push XHL
	calr	BStore_PutByteAndAdvance	; F700A6  calr 0xf70fda
	pop	xhl	; F700A9  pop XHL
	pop	xiy	; F700AA  pop XIY
	cp	(0x1238:16), 0x00	; F700AB  cp (0x1238),0x00
	jrl	nz, SmfEvent_ProgramChange_Return	; F700B0  jrl NZ,0xf701f0
	sla	xiy, 1	; F700B3  sla 0x01,XIY
	push	xix	; F700B6  push XIX
	ld	xix, 4307	; F700B7  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F700BC  ld WA,(XIX+IY)
	pop	xix	; F700C1  pop XIX
	srl	xiy, 1	; F700C2  srl 0x01,XIY
	push	xhl	; F700C5  push XHL
	push	xiy	; F700C6  push XIY
	calr	Smf_TicksToPpq96	; F700C7  calr 0xf7122f
	pop	xiy	; F700CA  pop XIY
	pop	xhl	; F700CB  pop XHL
	push	xhl	; F700CC  push XHL
	push	xiy	; F700CD  push XIY
	calr	BStore_PutByteAndAdvance	; F700CE  calr 0xf70fda
	pop	xiy	; F700D1  pop XIY
	pop	xhl	; F700D2  pop XHL
	cp	(0x1238:16), 0x00	; F700D3  cp (0x1238),0x00
	jrl	nz, SmfEvent_ProgramChange_Return	; F700D8  jrl NZ,0xf701f0
	push	xix	; F700DB  push XIX
	ld	xix, ByteMap_F70298 + 0x10	; F700DC  ld XIX,0x00f702a8
	ld	a, (xix+iy)	; F700E1  ld A,(XIX+IY)
	pop	xix	; F700E6  pop XIX
	push	xhl	; F700E7  push XHL
	push	xiy	; F700E8  push XIY
	calr	BStore_PutByteAndAdvance	; F700E9  calr 0xf70fda
	pop	xiy	; F700EC  pop XIY
	pop	xhl	; F700ED  pop XHL
	cp	(0x1238:16), 0x00	; F700EE  cp (0x1238),0x00
	jrl	nz, SmfEvent_ProgramChange_Return	; F700F3  jrl NZ,0xf701f0
	xor	a, a	; F700F6  xor A,A
	push	xhl	; F700F8  push XHL
	push	xiy	; F700F9  push XIY
	calr	BStore_PutByteAndAdvance	; F700FA  calr 0xf70fda
	pop	xiy	; F700FD  pop XIY
	pop	xhl	; F700FE  pop XHL
	cp	(0x1238:16), 0x00	; F700FF  cp (0x1238),0x00
	jrl	nz, SmfEvent_ProgramChange_Return	; F70104  jrl NZ,0xf701f0
	ld	a, (SoundConv_Result0:24)	; F70107  ld A,(0x60f014)
	and	a, 127	; F7010C  and A,0x7f
	push	xiy	; F7010F  push XIY
	calr	BStore_PutByteAndAdvance	; F70110  calr 0xf70fda
	pop	xiy	; F70113  pop XIY
	cp	(0x1238:16), 0x00	; F70114  cp (0x1238),0x00
	jrl	nz, SmfEvent_ProgramChange_Return	; F70119  jrl NZ,0xf701f0
	ld	a, (SoundConv_Result1:24)	; F7011C  ld A,(0x60f015)
	and	a, 127	; F70121  and A,0x7f
	push	xiy	; F70124  push XIY
	calr	BStore_PutByteAndAdvance	; F70125  calr 0xf70fda
	pop	xiy	; F70128  pop XIY
	cp	(0x1238:16), 0x00	; F70129  cp (0x1238),0x00
	jrl	nz, SmfEvent_ProgramChange_Return	; F7012E  jrl NZ,0xf701f0
	calr	SmfEvent_MarkChannelUsed	; F70131  calr 0xf7129a
	calr	TrackCursor_Save	; F70134  calr 0xf71275
	ld	(4664:16), 0	; F70137  ld (0x1238),0x00
	jrl	SmfEvent_ProgramChange_Return	; F7013C  jrl T,0xf701f0
SmfEvent_ProgramChange_Skip4:
	push	xiy	; F7013F  push XIY
	calr	TrackCursor_Load	; F70140  calr 0xf7124e
	ld	a, 192:opc	; F70143  ld A,0xc0
	pop	xiy	; F70145  pop XIY
	push	xiy	; F70146  push XIY
	calr	BStore_PutByteAndAdvance	; F70147  calr 0xf70fda
	pop	xiy	; F7014A  pop XIY
	cp	(0x1238:16), 0x00	; F7014B  cp (0x1238),0x00
	jrl	nz, SmfEvent_ProgramChange_Return	; F70150  jrl NZ,0xf701f0
	sla	xiy, 1	; F70153  sla 0x01,XIY
	push	xix	; F70156  push XIX
	ld	xix, 4307	; F70157  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F7015C  ld WA,(XIX+IY)
	pop	xix	; F70161  pop XIX
	srl	xiy, 1	; F70162  srl 0x01,XIY
	push	xiy	; F70165  push XIY
	calr	Smf_TicksToPpq96	; F70166  calr 0xf7122f
	pop	xiy	; F70169  pop XIY
	push	xiy	; F7016A  push XIY
	calr	BStore_PutByteAndAdvance	; F7016B  calr 0xf70fda
	pop	xiy	; F7016E  pop XIY
	cp	(0x1238:16), 0x00	; F7016F  cp (0x1238),0x00
	jr	nz, SmfEvent_ProgramChange_Return	; F70174  jr NZ,0xf701f0
	push	xix	; F70176  push XIX
	ld	xix, ByteMap_F70298	; F70177  ld XIX,0x00f70298
	ld	a, (xix+iy)	; F7017C  ld A,(XIX+IY)
	pop	xix	; F70181  pop XIX
	push	xiy	; F70182  push XIY
	calr	BStore_PutByteAndAdvance	; F70183  calr 0xf70fda
	pop	xiy	; F70186  pop XIY
	cp	(0x1238:16), 0x00	; F70187  cp (0x1238),0x00
	jr	nz, SmfEvent_ProgramChange_Return	; F7018C  jr NZ,0xf701f0
	ld	a, 0:opc	; F7018E  ld A,0x00
	push	xiy	; F70190  push XIY
	calr	BStore_PutByteAndAdvance	; F70191  calr 0xf70fda
	pop	xiy	; F70194  pop XIY
	cp	(0x1238:16), 0x00	; F70195  cp (0x1238),0x00
	jr	nz, SmfEvent_ProgramChange_Return	; F7019A  jr NZ,0xf701f0
	ld	a, (4305:16)	; F7019C  ld A,(0x10d1)
	push	xiy	; F701A0  push XIY
	calr	BStore_PutByteAndAdvance	; F701A1  calr 0xf70fda
	pop	xiy	; F701A4  pop XIY
	cp	(0x1238:16), 0x00	; F701A5  cp (0x1238),0x00
	jr	nz, SmfEvent_ProgramChange_Return	; F701AA  jr NZ,0xf701f0
	push	xix	; F701AC  push XIX
	ld	xix, 4260	; F701AD  ld XIX,0x000010a4
	ld	a, (xix+iy)	; F701B2  ld A,(XIX+IY)
	ld	xix, 4242	; F701B7  ld XIX,0x00001092
	ld	w, (xix+iy)	; F701BC  ld W,(XIX+IY)
	pop	xix	; F701C1  pop XIX
	and	a, 112	; F701C2  and A,0x70
	srl	a, 4	; F701C5  srl 0x04,A
	and	w, 7	; F701C8  and W,0x07
	sll	w, 3	; F701CB  sll 0x03,W
	or	a, w	; F701CE  or A,W
	call	BStore_PutByteAndAdvance	; F701D0  call 0xf70fda
	cp	(0x1238:16), 0x00	; F701D4  cp (0x1238),0x00
	jr	nz, SmfEvent_ProgramChange_Return	; F701D9  jr NZ,0xf701f0
	calr	SmfEvent_MarkChannelUsed	; F701DB  calr 0xf7129a
	calr	TrackCursor_Save	; F701DE  calr 0xf71275
	ld	(4664:16), 0	; F701E1  ld (0x1238),0x00
	jr	SmfEvent_ProgramChange_Return	; F701E6  jr T,0xf701f0

; --------------------------------------------------------------------------
; UNREACHED CODE, not data (was `Data_F701E8`), part of SmfEvent_ProgramChange:
;   `cp (0x1239),0xFF / jrl Z,0xF70031` -- the same shape as 0xF72074; 0xF70031 is an
;   instruction start of this source.
;   Nothing in prom_b branches to, calls or spells 0xF701E8 (code_islands.py searches every
;   jr/jrl/calr displacement and jp/call/24-bit operand); it is recorded as code because it
;   decodes as such and fits the code beside it, not because it runs.
; --------------------------------------------------------------------------
	cp	(0x1239:16), 0xff	; F701E8  cp (0x1239),0xff
	jrl	z, SmfEvent_ProgramChange_Loop	; F701ED  jrl Z,0xf70031

SmfEvent_ProgramChange_Return:
	ret	; F701F0  ret

; --------------------------------------------------------------------------
; SmfPart_SetSoundFromProgramChange
; Called from: in-module: 0xF70037 0xF71EC2
; Touches: (0x10D0) (0x10D1) (0x1239)
; Calls:   0xF702B8 T_PartSound_FromProgramChange
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF701F1 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfPart_SetSoundFromProgramChange: SMF import, program change on channel (Smf_EventStatus & 0x0F): XIY = the
;   channel's part record (SmfPart_GetRecordPtr). In GM mode ((0x1239) != 0) record +2/+3 :=
;   PartSound_FromProgramChange(bank LSB (0x10A4)[ch], bank MSB (0x1092)[ch], program (0x10D1), ByteMap_F702A8[ch]);
;   otherwise +2 := program and +3 := its bit 7 | (MSB & 7) << 3 | (LSB & 0x70) >> 4. First step of both
;   SmfEvent_ProgramChange variants. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave3_i.json)
SmfPart_SetSoundFromProgramChange:
	push	xiy	; F701F1  push XIY
	calr	SmfPart_GetRecordPtr	; F701F2  calr 0xf702b8
	cp	(0x1239:16), 0x00	; F701F5  cp (0x1239),0x00
	jr	z, SmfPart_SetSoundFromProgramChange_Skip	; F701FA  jr Z,0xf70257
	push	xix	; F701FC  push XIX
	push	xde	; F701FD  push XDE
	xor	de, de	; F701FE  xor DE,DE
	ld	e, (Smf_EventStatus:16)	; F70200  ld E,(0x10d0)
	and	e, 15	; F70204  and E,0x0f
	ld	xix, 4260	; F70207  ld XIX,0x000010a4
	ld	l, (xix+de)	; F7020C  ld L,(XIX+DE)
	ld	(SoundConv_Arg0:24), l	; F70211  ld (0x60f010),L
	ld	xix, 4242	; F70216  ld XIX,0x00001092
	ld	l, (xix+de)	; F7021B  ld L,(XIX+DE)
	ld	(SoundConv_Arg1:24), l	; F70220  ld (0x60f011),L
	ld	l, (4305:16)	; F70225  ld L,(0x10d1)
	ld	(SoundConv_Arg2:24), l	; F70229  ld (0x60f012),L
	ld	xix, ByteMap_F70298 + 0x10	; F7022E  ld XIX,0x00f702a8
	ld	l, (xix+de)	; F70233  ld L,(XIX+DE)
	ld	(SoundConv_Arg3:24), l	; F70238  ld (0x60f013),L
	pop	xde	; F7023D  pop XDE
	pop	xix	; F7023E  pop XIX
	push	xiy	; F7023F  push XIY
	call	T_PartSound_FromProgramChange	; F70240  call 0xf41004
	pop	xiy	; F70244  pop XIY
	ld	l, (SoundConv_Result0:24)	; F70245  ld L,(0x60f014)
	ld	h, (SoundConv_Result1:24)	; F7024A  ld H,(0x60f015)
	ld	(xiy+2), l	; F7024F  ld (XIY+0x02),L
	ld	(xiy+3), h	; F70252  ld (XIY+0x03),H
	jr	SmfPart_SetSoundFromProgramChange_Epilogue	; F70255  jr T,0xf70296
SmfPart_SetSoundFromProgramChange_Skip:
	ld	a, (4305:16)	; F70257  ld A,(0x10d1)
	ld	(xiy+2), a	; F7025B  ld (XIY+0x02),A
	xor	h, h	; F7025E  xor H,H
	ld	l, (Smf_EventStatus:16)	; F70260  ld L,(0x10d0)
	and	l, 15	; F70264  and L,0x0f
	push	xix	; F70267  push XIX
	ld	xix, 4260	; F70268  ld XIX,0x000010a4
	ld	c, (xix+hl)	; F7026D  ld C,(XIX+HL)
	ld	xix, 4242	; F70272  ld XIX,0x00001092
	ld	a, (xix+hl)	; F70277  ld A,(XIX+HL)
	pop	xix	; F7027C  pop XIX
	ld	l, (xiy+3)	; F7027D  ld L,(XIY+0x03)
	and	l, 128	; F70280  and L,0x80
	and	c, 112	; F70283  and C,0x70
	srl	c, 4	; F70286  srl 0x04,C
	and	a, 7	; F70289  and A,0x07
	sll	a, 3	; F7028C  sll 0x03,A
	or	c, a	; F7028F  or C,A
	or	l, c	; F70291  or L,C
	ld	(xiy+3), l	; F70293  ld (XIY+0x03),L
SmfPart_SetSoundFromProgramChange_Epilogue:
	pop	xiy	; F70296  pop XIY
	ret	; F70297  ret

; --------------------------------------------------------------------------
; ByteMap_F70298 -- 34 bytes: 2 BYTE MAPS end to end, 16 bytes at 0xF70298
;                   (0x00..0x0F), 18 bytes at 0xF702A8 (0x00..0xD6).  Each
;                   ascends STRICTLY on its own and the sequence RESTARTS at
;                   each boundary, so this is N maps of the same shape
;                   rather than one long one.  The name describes the
;                   CONTENT; what the index spaces are is not established
;                   here.
; Read by: 4 byte-scan hits: 4 instruction operands -- `ld XIX,0x00f70298`
;          at 0xF70177 (operand field 1 byte in); `ld XIX,0x00f70298` at
;          0xF706F4 (operand field 1 byte in); `ld XIX,0x00f70298` at
;          0xF70BB5 (operand field 1 byte in); `ld XIX,0x00f70298` at
;          0xF70E70 (operand field 1 byte in)
; Entry count: 34 bytes.  The run is trimmed of trailing 0xFF, so it claims
;              no padding it did not earn; the byte before it is 0x0E and
;              the LAST byte of it is 0xD6.
; Evidence: every non-0xFF byte is compared with its predecessor on every
;           emit, WITHIN EACH of the 2 maximal ascending runs the rule
;           returns, and the runs are asserted to tile this segment exactly.
;           The BYTEMAP rule fires ZERO times over the proven prom_b
;           instruction text at (16 bytes, 12 values) and also at (20,14),
;           (24,16) and (16,16) (`python3 notes/prom_b_f6d002_layout.py
;           --null-ptr`).
; Unknown: what the two index spaces ARE, and who reads it.
; --------------------------------------------------------------------------
ByteMap_F70298:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F70298  [0..15]
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F702A8  [16..31]
SmfPart_GetRecordPtr:
	xor	h, h	; F702B8  xor H,H
; ⚠ CORRECTED 2026-10-04: the block below was 118 bytes of `.byte` that no rule could split.  It is the rest of
;   SmfPart_GetRecordPtr (three `calr` reach 0xF702B8; unidasm decodes it to the `ret` at 0xF702EF) and then two
;   16-word tables.  Its old header, kept verbatim:


; --------------------------------------------------------------------------
; SmfPart_GetRecordPtr_ChannelIndex -- 118 bytes this block could not split.  No content rule
;                framed it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or
;                ASCII -- and the code walk never reached it from a thunk
;                slot, a proven call site, an opcode-anchored call or an
;                entry of a table the firmware transfers to.  So it is
;                emitted as bytes rather than guessed.
; ⚠ these bytes DO decode cleanly as instructions, but the decode does not
;   end in a `ret`/`reti`/unconditional transfer.  That is not evidence:
;   round 4's rule, which accepted a run on a clean decode alone, accepts
;   13.9% of record-aligned chunks of PROVEN display-list data as code
;   (`python3 notes/prom_b_f6d002_layout.py --null-accept`).
; Contains: printable bytes |...'.......9.?.f.<D........#\h.<D........#\E.6`
;           .....5...@.......@.....@.......@.........@.......@.....@.......@
;           .......|
; Read by: nothing in prom_a or prom_b spells this address as a 32-bit word,
;          so whatever reaches it computes the address
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; Unknown: everything about it except its bytes.
; --------------------------------------------------------------------------
SmfPart_GetRecordPtr_ChannelIndex:
	ld	l, (Smf_EventStatus:16)	; F702BA  ld L,(0x10d0)
	and	l, 15	; F702BE  and L,0x0f
	sla	hl, 1	; F702C1  sla 0x01,HL
	cp	(0x1239:16), 0xff	; F702C4  cp (0x1239),0xff
	jr	z, SmfPart_GetRecordPtr_Skip	; F702C9  jr Z,0xf702d9
	push	xix	; F702CB  push XIX
	ld	xix, SmfPart_RecordOffsets	; F702CC  ld XIX,0x00f702f0
	ld	hl, (xix+hl)	; F702D1  ld HL,(XIX+HL)
	pop	xix	; F702D6  pop XIX
	jr	SmfPart_GetRecordPtr_Join	; F702D7  jr T,0xf702e5
SmfPart_GetRecordPtr_Skip:
	push	xix	; F702D9  push XIX
	ld	xix, SmfPart_RecordOffsets_Alt	; F702DA  ld XIX,0x00f70310
	ld	hl, (xix+hl)	; F702DF  ld HL,(XIX+HL)
	pop	xix	; F702E4  pop XIX
SmfPart_GetRecordPtr_Join:
	ld	xiy, 6305440	; F702E5  ld XIY,0x006036a0
	lda	xiy, (xiy+hl)	; F702EA  lda XIY,XIY+HL
	ret	; F702EF  ret
; The byte offset of each MIDI channel's 64-byte part record from 0x6036A0.  Channels 8-15 skip offset 0x200, so they
; use records 9-16.  SmfPart_GetRecordPtr reads the second table when (0x1239) is 0xFF; the two are identical.
SmfPart_RecordOffsets:
	.short	0x0000, 0x0040, 0x0080, 0x00c0, 0x0100, 0x0140, 0x0180, 0x01c0	; F702F0
	.short	0x0240, 0x0280, 0x02c0, 0x0300, 0x0340, 0x0380, 0x03c0, 0x0400	; F70300
SmfPart_RecordOffsets_Alt:
	.short	0x0000, 0x0040, 0x0080, 0x00c0, 0x0100, 0x0140, 0x0180, 0x01c0	; F70310
	.short	0x0240, 0x0280, 0x02c0, 0x0300, 0x0340, 0x0380, 0x03c0, 0x0400	; F70320


; --------------------------------------------------------------------------
; SmfEvent_PitchBend
; Called from: in-module: 0xF6FFA5
; Touches: (0x10D0) (0x10D1) (0x10D2) (0x1238)
; Calls:   TrackCursor_Load BStore_PutByteAndAdvance Smf_TicksToPpq96 SmfEvent_MarkChannelUsed TrackCursor_Save
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF70330 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_PitchBend: the arm for status 0xEn; it writes song code 0xD2 to the channel's track.
SmfEvent_PitchBend:
	ld	iy, (Smf_EventStatus:16)	; F70330  ld IY,(0x10d0)
	and	iy, 15	; F70334  and IY,0x000f
	extz	xiy	; F70338  extz XIY
	push	xiy	; F7033A  push XIY
	calr	TrackCursor_Load	; F7033B  calr 0xf7124e
	ld	a, 210:opc	; F7033E  ld A,0xd2
	calr	BStore_PutByteAndAdvance	; F70340  calr 0xf70fda
	pop	xiy	; F70343  pop XIY
	cp	(0x1238:16), 0x00	; F70344  cp (0x1238),0x00
	jr	nz, SmfEvent_PitchBend_Return	; F70349  jr NZ,0xf70399
	sla	xiy, 1	; F7034B  sla 0x01,XIY
	push	xix	; F7034E  push XIX
	ld	xix, 4307	; F7034F  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F70354  ld WA,(XIX+IY)
	pop	xix	; F70359  pop XIX
	srl	xiy, 1	; F7035A  srl 0x01,XIY
	push	xiy	; F7035D  push XIY
	calr	Smf_TicksToPpq96	; F7035E  calr 0xf7122f
	pop	xiy	; F70361  pop XIY
	push	xiy	; F70362  push XIY
	calr	BStore_PutByteAndAdvance	; F70363  calr 0xf70fda
	pop	xiy	; F70366  pop XIY
	cp	(0x1238:16), 0x00	; F70367  cp (0x1238),0x00
	jr	nz, SmfEvent_PitchBend_Return	; F7036C  jr NZ,0xf70399
	ld	a, (4305:16)	; F7036E  ld A,(0x10d1)
	push	xiy	; F70372  push XIY
	calr	BStore_PutByteAndAdvance	; F70373  calr 0xf70fda
	pop	xiy	; F70376  pop XIY
	cp	(0x1238:16), 0x00	; F70377  cp (0x1238),0x00
	jr	nz, SmfEvent_PitchBend_Return	; F7037C  jr NZ,0xf70399
	ld	a, (4306:16)	; F7037E  ld A,(0x10d2)
	push	xiy	; F70382  push XIY
	calr	BStore_PutByteAndAdvance	; F70383  calr 0xf70fda
	pop	xiy	; F70386  pop XIY
	cp	(0x1238:16), 0x00	; F70387  cp (0x1238),0x00
	jr	nz, SmfEvent_PitchBend_Return	; F7038C  jr NZ,0xf70399
	calr	SmfEvent_MarkChannelUsed	; F7038E  calr 0xf7129a
	calr	TrackCursor_Save	; F70391  calr 0xf71275
	ld	(4664:16), 0	; F70394  ld (0x1238),0x00
SmfEvent_PitchBend_Return:
	ret	; F70399  ret

; --------------------------------------------------------------------------
; SmfEvent_ControlChange
; Called from: in-module: 0xF6FFA0
; Touches: (0x10D1) (0x1239) (0x124B) (0x2732)
; Calls:   SmfPart_ResetAllRecords SmfCC_GeneralPurpose1 SmfCC_GeneralPurpose2 SmfCC_GeneralPurpose3 SmfCC_GeneralPurpose4 SmfCC_BankSelectLsb
;          SmfCC_DataEntryLsb SmfCC_Sustain sub_F7039A_Nop2 SmfCC_PutSustainParamEvent_Nop SmfCC_Effect1Depth SmfCC_Effect3Depth
;          +6 more
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7039A is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_ControlChange: the arm for status 0xBn.
SmfEvent_ControlChange:
	bit	0, (0x124b:16)	; F7039A  bit 0,(0x124b)
	jr	nz, SmfEvent_ControlChange_Skip2	; F7039E  jr NZ,0xf703b9
	ld	(4665:16), 255	; F703A0  ld (0x1239),0xff
	cp	(0x2732:16), 0x00	; F703A5  cp (0x2732),0x00
	jr	nz, SmfEvent_ControlChange_Skip	; F703AA  jr NZ,0xf703b1
	ld	(4665:16), 0	; F703AC  ld (0x1239),0x00
SmfEvent_ControlChange_Skip:
	ld	(4683:16), 1	; F703B1  ld (0x124b),0x01
	calr	SmfPart_ResetAllRecords	; F703B6  calr 0xf71417
SmfEvent_ControlChange_Skip2:
	ld	a, (4305:16)	; F703B9  ld A,(0x10d1)
	cp	a, 16	; F703BD  cp A,0x10
	jr	c, SmfEvent_ControlChange_Skip3	; F703C0  jr C,0xf7041e
	cp	a, 16	; F703C2  cp A,0x10
	jr	z, SmfEvent_ControlChange_Skip4	; F703C5  jr Z,0xf70437
	cp	a, 17	; F703C7  cp A,0x11
	jr	z, SmfEvent_ControlChange_Skip5	; F703CA  jr Z,0xf7043c
	cp	a, 18	; F703CC  cp A,0x12
	jr	z, SmfEvent_ControlChange_Skip6	; F703CF  jr Z,0xf70441
	cp	a, 19	; F703D1  cp A,0x13
	jr	z, SmfEvent_ControlChange_Skip7	; F703D4  jr Z,0xf70446
	cp	a, 32	; F703D6  cp A,0x20
	jr	z, SmfEvent_ControlChange_Skip8	; F703D9  jr Z,0xf7044b
	cp	a, 38	; F703DB  cp A,0x26
	jr	z, SmfEvent_ControlChange_Skip9	; F703DE  jr Z,0xf70450
	cp	a, 64	; F703E0  cp A,0x40
	jr	z, SmfEvent_ControlChange_Skip10	; F703E3  jr Z,0xf70455
	cp	a, 66	; F703E5  cp A,0x42
	jr	z, SmfEvent_ControlChange_Skip11	; F703E8  jr Z,0xf7045a
	cp	a, 67	; F703EA  cp A,0x43
	jr	z, SmfEvent_ControlChange_Skip12	; F703ED  jr Z,0xf70460
	cp	a, 91	; F703EF  cp A,0x5b
	jr	z, SmfEvent_ControlChange_Skip13	; F703F2  jr Z,0xf70466
	cp	a, 93	; F703F4  cp A,0x5d
	jr	z, SmfEvent_ControlChange_Skip14	; F703F7  jr Z,0xf7046b
	cp	a, 94	; F703F9  cp A,0x5e
	jr	z, SmfEvent_ControlChange_Skip15	; F703FC  jr Z,0xf70470
	cp	a, 96	; F703FE  cp A,0x60
	jr	z, SmfEvent_ControlChange_Skip16	; F70401  jr Z,0xf70475
	cp	a, 97	; F70403  cp A,0x61
	jr	z, SmfEvent_ControlChange_Skip17	; F70406  jr Z,0xf7047a
	cp	a, 98	; F70408  cp A,0x62
	jr	z, SmfEvent_ControlChange_Skip18	; F7040B  jr Z,0xf7047f
	cp	a, 99	; F7040D  cp A,0x63
	jr	z, SmfEvent_ControlChange_Skip18	; F70410  jr Z,0xf7047f
	cp	a, 100	; F70412  cp A,0x64
	jr	z, SmfEvent_ControlChange_Skip20	; F70415  jr Z,0xf70489
	cp	a, 101	; F70417  cp A,0x65
	jr	z, SmfEvent_ControlChange_Skip19	; F7041A  jr Z,0xf70484
	jr	SmfEvent_ControlChange_Return	; F7041C  jr T,0xf7048c
SmfEvent_ControlChange_Skip3:
	ld	l, a	; F7041E  ld L,A
	xor	h, h	; F70420  xor H,H
	sla	l, 2	; F70422  sla 0x02,L
	extz	xhl	; F70425  extz XHL
	push	xix	; F70427  push XIX
	ld	xix, SmfCC_HandlersByNumber	; F70428  ld XIX,0x00f7048d
	ld	xhl, (xix+hl)	; F7042D  ld XHL,(XIX+HL)
	pop	xix	; F70432  pop XIX
	call	(xhl)	; F70433  call T,XHL
	jr	SmfEvent_ControlChange_Return	; F70435  jr T,0xf7048c
SmfEvent_ControlChange_Skip4:
	calr	SmfCC_GeneralPurpose1	; F70437  calr 0xf7193f
	jr	SmfEvent_ControlChange_Return	; F7043A  jr T,0xf7048c
SmfEvent_ControlChange_Skip5:
	calr	SmfCC_GeneralPurpose2	; F7043C  calr 0xf71978
	jr	SmfEvent_ControlChange_Return	; F7043F  jr T,0xf7048c
SmfEvent_ControlChange_Skip6:
	calr	SmfCC_GeneralPurpose3	; F70441  calr 0xf719b1
	jr	SmfEvent_ControlChange_Return	; F70444  jr T,0xf7048c
SmfEvent_ControlChange_Skip7:
	calr	SmfCC_GeneralPurpose4	; F70446  calr 0xf719ea
	jr	SmfEvent_ControlChange_Return	; F70449  jr T,0xf7048c
SmfEvent_ControlChange_Skip8:
	calr	SmfCC_BankSelectLsb	; F7044B  calr 0xf707ae
	jr	SmfEvent_ControlChange_Return	; F7044E  jr T,0xf7048c
SmfEvent_ControlChange_Skip9:
	calr	SmfCC_DataEntryLsb	; F70450  calr 0xf70599
	jr	SmfEvent_ControlChange_Return	; F70453  jr T,0xf7048c
SmfEvent_ControlChange_Skip10:
	calr	SmfCC_Sustain	; F70455  calr 0xf707e6
	jr	SmfEvent_ControlChange_Return	; F70458  jr T,0xf7048c
SmfEvent_ControlChange_Skip11:
	call	sub_F7039A_Nop2	; F7045A  call 0xf7095e
	jr	SmfEvent_ControlChange_Return	; F7045E  jr T,0xf7048c
SmfEvent_ControlChange_Skip12:
	call	SmfCC_PutSustainParamEvent_Nop	; F70460  call 0xf7091d
	jr	SmfEvent_ControlChange_Return	; F70464  jr T,0xf7048c
SmfEvent_ControlChange_Skip13:
	calr	SmfCC_Effect1Depth	; F70466  calr 0xf709ed
	jr	SmfEvent_ControlChange_Return	; F70469  jr T,0xf7048c
SmfEvent_ControlChange_Skip14:
	calr	SmfCC_Effect3Depth	; F7046B  calr 0xf70960
	jr	SmfEvent_ControlChange_Return	; F7046E  jr T,0xf7048c
SmfEvent_ControlChange_Skip15:
	calr	SmfCC_Effect4Depth	; F70470  calr 0xf709b6
	jr	SmfEvent_ControlChange_Return	; F70473  jr T,0xf7048c
SmfEvent_ControlChange_Skip16:
	calr	SmfCC_DataIncrement	; F70475  calr 0xf70a43
	jr	SmfEvent_ControlChange_Return	; F70478  jr T,0xf7048c
SmfEvent_ControlChange_Skip17:
	calr	SmfCC_DataDecrement	; F7047A  calr 0xf70a97
	jr	SmfEvent_ControlChange_Return	; F7047D  jr T,0xf7048c
SmfEvent_ControlChange_Skip18:
	calr	SmfCC_Nrpn	; F7047F  calr 0xf70c6f
	jr	SmfEvent_ControlChange_Return	; F70482  jr T,0xf7048c
SmfEvent_ControlChange_Skip19:
	calr	SmfCC_RpnMsb	; F70484  calr 0xf70cba
	jr	SmfEvent_ControlChange_Return	; F70487  jr T,0xf7048c
SmfEvent_ControlChange_Skip20:
	calr	SmfCC_RpnLsb	; F70489  calr 0xf70d42
SmfEvent_ControlChange_Return:
	ret	; F7048C  ret

; --------------------------------------------------------------------------
; SmfCC_HandlersByNumber -- 16 32-bit words, every one an address in
;                         0x00F00000-0x00F7FFFF, i.e. inside this image.  9
;                         distinct values.  notes/prom_b_f6d002_layout.py
;                         classes it TRANSFER.
; Why TRANSFER: the code that indexes it fetches an entry and then TRANSFERS
;               to it, so the entries are ENTRY POINTS and they seed this
;               block's code walk
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XIX,0x00f7048d` at
;          0xF70428 (operand field 1 byte in)
; Entry count: 16, and it is NOT a byte extent divided by four.  The chain
;              rule that finds it stops at the first word that is not an
;              0x00F0xxxx-0x00F7xxxx address; that word is at 0xF704CD.
;              Entry 15, the LAST, is 0x00F704CD.
; Evidence: every one of the 16 words is re-read and range-asserted on every
;           emit.  The PTRTAB rule at this window fires ZERO times over the
;           proven prom_b instruction text (`python3
;           notes/prom_b_f6d002_layout.py --null-ptr`), and the STRIDED rule
;           fires zero times over the proven dispatch tables of this image
;           (`--null-stride`).
; Unknown: what the handlers do.  Each is sub_XXXXXX.
; --------------------------------------------------------------------------
; SmfCC_HandlersByNumber: SmfEvent_ControlChange's handlers for MIDI controllers 0-15, indexed by the controller number
;   (notes/prom_ab_read_names_2026_10_04.py).
SmfCC_HandlersByNumber:
	.long	SmfCC_BankSelectMsb	; F7048D  [0] -> SmfCC_BankSelectMsb
	.long	SmfCC_Modulation	; F70491  [1] -> SmfCC_Modulation
	.long	SmfCC_Breath	; F70495  [2] -> SmfCC_Breath
	.long	SmfCC_Ignore	; F70499  [3] -> SmfCC_Ignore
	.long	SmfCC_Foot	; F7049D  [4] -> SmfCC_Foot
	.long	SmfCC_Ignore	; F704A1  [5] -> SmfCC_Ignore
	.long	SmfCC_DataEntryMsb	; F704A5  [6] -> SmfCC_DataEntryMsb
	.long	SmfCC_Volume	; F704A9  [7] -> SmfCC_Volume
	.long	SmfCC_Ignore	; F704AD  [8] -> SmfCC_Ignore
	.long	SmfCC_Ignore	; F704B1  [9] -> SmfCC_Ignore
	.long	SmfCC_Pan	; F704B5  [10] -> SmfCC_Pan
	.long	SmfCC_Expression	; F704B9  [11] -> SmfCC_Expression
	.long	SmfCC_Ignore	; F704BD  [12] -> SmfCC_Ignore
	.long	SmfCC_Ignore	; F704C1  [13] -> SmfCC_Ignore
	.long	SmfCC_Ignore	; F704C5  [14] -> SmfCC_Ignore
	.long	SmfCC_Ignore	; F704C9  [15] -> SmfCC_Ignore


; --------------------------------------------------------------------------
; SmfCC_Ignore
; Called from: no thunk slot and no in-module call or jp site -- reached
;              only by a branch from the routine above, or through a table
; Touches: nothing with an absolute address
; Evidence (TABLE): it is an entry of a pointer table the consumer rule
;                   classed TRANSFER: the code that indexes that table
;                   fetches the entry and then transfers to it.  This module
;                   has two such tables, both of 16 entries, at 0xF7048D and
;                   0xF72323.  0xF704CD is an instruction boundary of this
;                   transcription, re-asserted on every emit.  The name IS
;                   the address.
; Purpose: none -- the entry is a lone `ret`.  Named SmfCC_Ignore after what reaches it
;          (was sub_F704CD; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
SmfCC_Ignore:
	ret	; F704CD  ret

; --------------------------------------------------------------------------
; SmfCC_BankSelectMsb
; Called from: no thunk slot and no in-module call or jp site -- reached
;              only by a branch from the routine above, or through a table
; Touches: (0x10D0) (0x10D2)
; Evidence (TABLE): it is an entry of a pointer table the consumer rule
;                   classed TRANSFER: the code that indexes that table
;                   fetches the entry and then transfers to it.  This module
;                   has two such tables, both of 16 entries, at 0xF7048D and
;                   0xF72323.  0xF704CE is an instruction boundary of this
;                   transcription, re-asserted on every emit.  The name IS
;                   the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_BankSelectMsb: DispatchTable_F7048D[0]: SmfEvent_ControlChange's handler for MIDI controller 0.
SmfCC_BankSelectMsb:
	ld	iy, (Smf_EventStatus:16)	; F704CE  ld IY,(0x10d0)
	and	iy, 15	; F704D2  and IY,0x000f
	ld	a, (4306:16)	; F704D6  ld A,(0x10d2)
	push	xix	; F704DA  push XIX
	ld	xix, 4242	; F704DB  ld XIX,0x00001092
	ld	(xix+iy), a	; F704E0  ld (XIX+IY),A
	pop	xix	; F704E5  pop XIX
	ret	; F704E6  ret

; --------------------------------------------------------------------------
; SmfCC_Modulation
; Called from: no thunk slot and no in-module call or jp site -- reached
;              only by a branch from the routine above, or through a table
; Touches: (0x10D0) (0x10D2) (0x1238)
; Calls:   TrackCursor_Load BStore_PutByteAndAdvance Smf_TicksToPpq96 SmfEvent_MarkChannelUsed TrackCursor_Save
; Evidence (TABLE): it is an entry of a pointer table the consumer rule
;                   classed TRANSFER: the code that indexes that table
;                   fetches the entry and then transfers to it.  This module
;                   has two such tables, both of 16 entries, at 0xF7048D and
;                   0xF72323.  0xF704E7 is an instruction boundary of this
;                   transcription, re-asserted on every emit.  The name IS
;                   the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_Modulation: DispatchTable_F7048D[1]: SmfEvent_ControlChange's handler for MIDI controller 1.
SmfCC_Modulation:
	ld	iy, (Smf_EventStatus:16)	; F704E7  ld IY,(0x10d0)
	and	iy, 15	; F704EB  and IY,0x000f
	push	xiy	; F704EF  push XIY
	calr	TrackCursor_Load	; F704F0  calr 0xf7124e
	ld	a, 209:opc	; F704F3  ld A,0xd1
	calr	BStore_PutByteAndAdvance	; F704F5  calr 0xf70fda
	pop	xiy	; F704F8  pop XIY
	cp	(0x1238:16), 0x00	; F704F9  cp (0x1238),0x00
	jr	nz, SmfCC_Modulation_Return	; F704FE  jr NZ,0xf7053e
	sla	xiy, 1	; F70500  sla 0x01,XIY
	push	xix	; F70503  push XIX
	ld	xix, 4307	; F70504  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F70509  ld WA,(XIX+IY)
	pop	xix	; F7050E  pop XIX
	srl	xiy, 1	; F7050F  srl 0x01,XIY
	push	xiy	; F70512  push XIY
	calr	Smf_TicksToPpq96	; F70513  calr 0xf7122f
	pop	xiy	; F70516  pop XIY
	push	xiy	; F70517  push XIY
	calr	BStore_PutByteAndAdvance	; F70518  calr 0xf70fda
	pop	xiy	; F7051B  pop XIY
	cp	(0x1238:16), 0x00	; F7051C  cp (0x1238),0x00
	jr	nz, SmfCC_Modulation_Return	; F70521  jr NZ,0xf7053e
	ld	a, (4306:16)	; F70523  ld A,(0x10d2)
	push	xiy	; F70527  push XIY
	calr	BStore_PutByteAndAdvance	; F70528  calr 0xf70fda
	pop	xiy	; F7052B  pop XIY
	cp	(0x1238:16), 0x00	; F7052C  cp (0x1238),0x00
	jr	nz, SmfCC_Modulation_Return	; F70531  jr NZ,0xf7053e
	calr	SmfEvent_MarkChannelUsed	; F70533  calr 0xf7129a
	calr	TrackCursor_Save	; F70536  calr 0xf71275
	ld	(4664:16), 0	; F70539  ld (0x1238),0x00
SmfCC_Modulation_Return:
	ret	; F7053E  ret

; --------------------------------------------------------------------------
; SmfCC_DataEntryMsb
; Called from: no thunk slot and no in-module call or jp site -- reached
;              only by a branch from the routine above, or through a table
; Touches: (0x10D0) (0x10D2)
; Calls:   SmfCC_CombineFineTuneDataEntry SmfCC_PutSelectedRpnValueEvent
; Evidence (TABLE): it is an entry of a pointer table the consumer rule
;                   classed TRANSFER: the code that indexes that table
;                   fetches the entry and then transfers to it.  This module
;                   has two such tables, both of 16 entries, at 0xF7048D and
;                   0xF72323.  0xF7053F is an instruction boundary of this
;                   transcription, re-asserted on every emit.  The name IS
;                   the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_DataEntryMsb: DispatchTable_F7048D[6]: SmfEvent_ControlChange's handler for MIDI controller 6.
SmfCC_DataEntryMsb:
	ld	iy, (Smf_EventStatus:16)	; F7053F  ld IY,(0x10d0)
	and	iy, 15	; F70543  and IY,0x000f
	push	xix	; F70547  push XIX
	ld	xix, 4568	; F70548  ld XIX,0x000011d8
	ld	l, (xix+iy)	; F7054D  ld L,(XIX+IY)
	pop	xix	; F70552  pop XIX
	cp	l, 255	; F70553  cp L,0xff
	jr	z, SmfCC_DataEntryMsb_Return	; F70556  jr Z,0xf70598
	ld	c, l	; F70558  ld C,L
	xor	h, h	; F7055A  xor H,H
	sla	hl, 2	; F7055C  sla 0x02,HL
	push	xix	; F7055F  push XIX
	ld	xix, Data_F70AD7	; F70560  ld XIX,0x00f70ad7
	ld	xhl, (xix+hl)	; F70565  ld XHL,(XIX+HL)
	pop	xix	; F7056A  pop XIX
	ld	a, (4306:16)	; F7056B  ld A,(0x10d2)
	xor	b, b	; F7056F  xor B,B
	ld	ix, bc	; F70571  ld IX,BC
	push	xiy	; F70573  push XIY
	ld	xiy, Data_F70AD7 + 0xC	; F70574  ld XIY,0x00f70ae3
	ld	e, (xiy+ix)	; F70579  ld E,(XIY+IX)
	pop	xiy	; F7057E  pop XIY
	cp	a, e	; F7057F  cp A,E
	jr	ule, SmfCC_DataEntryMsb_Skip	; F70581  jr ULE,0xf70585
	ld	a, e	; F70583  ld A,E
SmfCC_DataEntryMsb_Skip:
	cp	c, 1:i3	; F70585  cp C,1
	jr	nz, SmfCC_DataEntryMsb_Skip2	; F70587  jr NZ,0xf70590
	push	xhl	; F70589  push XHL
	push	xiy	; F7058A  push XIY
	calr	SmfCC_CombineFineTuneDataEntry	; F7058B  calr 0xf705f7
	pop	xiy	; F7058E  pop XIY
	pop	xhl	; F7058F  pop XHL
SmfCC_DataEntryMsb_Skip2:
	ld	(xhl+iy), a	; F70590  ld (XHL+IY),A
	calr	SmfCC_PutSelectedRpnValueEvent	; F70595  calr 0xf70ae9
SmfCC_DataEntryMsb_Return:
	ret	; F70598  ret

; --------------------------------------------------------------------------
; SmfCC_DataEntryLsb
; Called from: in-module: 0xF70450
; Touches: (0x10D0) (0x10D2)
; Calls:   SmfCC_CombineFineTuneDataEntry SmfCC_PutSelectedRpnValueEvent
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF70599 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_DataEntryLsb: SmfEvent_ControlChange's arm for MIDI controller 38 (`cp a,38 / jr z`).
SmfCC_DataEntryLsb:
	ld	iy, (Smf_EventStatus:16)	; F70599  ld IY,(0x10d0)
	and	iy, 15	; F7059D  and IY,0x000f
	push	xix	; F705A1  push XIX
	ld	xix, 4568	; F705A2  ld XIX,0x000011d8
	ld	l, (xix+iy)	; F705A7  ld L,(XIX+IY)
	pop	xix	; F705AC  pop XIX
	cp	l, 255	; F705AD  cp L,0xff
	jr	z, SmfCC_DataEntryLsb_Return	; F705B0  jr Z,0xf705f6
	ld	c, l	; F705B2  ld C,L
	xor	h, h	; F705B4  xor H,H
	extz	xhl	; F705B6  extz XHL
	sla	hl, 2	; F705B8  sla 0x02,HL
	push	xix	; F705BB  push XIX
	ld	xix, Data_F70AD7	; F705BC  ld XIX,0x00f70ad7
	ld	xhl, (xix+hl)	; F705C1  ld XHL,(XIX+HL)
	pop	xix	; F705C6  pop XIX
	ld	a, (4306:16)	; F705C7  ld A,(0x10d2)
	xor	b, b	; F705CB  xor B,B
	ld	ix, bc	; F705CD  ld IX,BC
	extz	xix	; F705CF  extz XIX
	push	xiy	; F705D1  push XIY
	ld	xiy, Data_F70AD7 + 0xC	; F705D2  ld XIY,0x00f70ae3
	ld	e, (xiy+ix)	; F705D7  ld E,(XIY+IX)
	pop	xiy	; F705DC  pop XIY
	cp	a, e	; F705DD  cp A,E
	jr	ule, SmfCC_DataEntryLsb_Skip	; F705DF  jr ULE,0xf705e3
	ld	a, e	; F705E1  ld A,E
SmfCC_DataEntryLsb_Skip:
	cp	c, 1:i3	; F705E3  cp C,1
	jr	nz, SmfCC_DataEntryLsb_Return	; F705E5  jr NZ,0xf705f6
	push	xhl	; F705E7  push XHL
	push	xiy	; F705E8  push XIY
	calr	SmfCC_CombineFineTuneDataEntry	; F705E9  calr 0xf705f7
	pop	xiy	; F705EC  pop XIY
	pop	xhl	; F705ED  pop XHL
	ld	(xhl+iy), a	; F705EE  ld (XHL+IY),A
	calr	SmfCC_PutSelectedRpnValueEvent	; F705F3  calr 0xf70ae9
SmfCC_DataEntryLsb_Return:
	ret	; F705F6  ret

; --------------------------------------------------------------------------
; SmfCC_CombineFineTuneDataEntry
; Called from: in-module: 0xF7058B 0xF705E9 0xF7242D 0xF72487
; Touches: (0x10D1)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF705F7 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_CombineFineTuneDataEntry: For RPN 1 (fine tuning): stores the clamped data-entry byte A in the channel's (IY)
;   MSB cell 0x1218[ch] when the controller (Smf_EventStatus+1) is 6, else in its LSB cell 0x1228[ch], and returns A =
;   MSB*2 | bit 6 of LSB, the 8-bit value the caller stores in the RPN-1 array. Basis: callers + body -- called only
;   by the four Data Entry MSB/LSB handlers, only when the channel's selected RPN is 1. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_d.json)
SmfCC_CombineFineTuneDataEntry:
	cp	(0x10d1:16), 0x06	; F705F7  cp (0x10d1),0x06
	jr	z, SmfCC_CombineFineTuneDataEntry_Skip	; F705FC  jr Z,0xf7061a
	push	xix	; F705FE  push XIX
	ld	xix, 4648	; F705FF  ld XIX,0x00001228
	ld	(xix+iy), a	; F70604  ld (XIX+IY),A
	pop	xix	; F70609  pop XIX
	ld	l, a	; F7060A  ld L,A
	push	xix	; F7060C  push XIX
	ld	xix, 4632	; F7060D  ld XIX,0x00001218
	ld	a, (xix+iy)	; F70612  ld A,(XIX+IY)
	pop	xix	; F70617  pop XIX
	jr	sub_F705F7_Entry	; F70618  jr T,0xf70630
SmfCC_CombineFineTuneDataEntry_Skip:
	push	xix	; F7061A  push XIX
	ld	xix, 4632	; F7061B  ld XIX,0x00001218
	ld	(xix+iy), a	; F70620  ld (XIX+IY),A
	ld	xix, 4648	; F70625  ld XIX,0x00001228
	ld	l, (xix+iy)	; F7062A  ld L,(XIX+IY)
	pop	xix	; F7062F  pop XIX
sub_F705F7_Entry:
	.byte 0xCF, 0xE8, 0x02	; F70630  rlc 0x02,L   [llvm-mc cannot encode this]
	and	l, 1	; F70633  and L,0x01
	sla	a, 1	; F70636  sla 0x01,A
	or	a, l	; F70639  or A,L
	ret	; F7063B  ret

; --------------------------------------------------------------------------
; SmfCC_Volume
; Called from: no thunk slot and no in-module call or jp site -- reached
;              only by a branch from the routine above, or through a table
; Touches: (0x10D2) (0x11AE) (0x11AF) (0x11B0) (0x11B1) (0x1238) (0x1239)
;          (0x124B) (0x2732)
; Calls:   SmfPart_ResetAllRecords SmfPart_SetVolume SmfCC_PutParamEvent
; Evidence (TABLE): it is an entry of a pointer table the consumer rule
;                   classed TRANSFER: the code that indexes that table
;                   fetches the entry and then transfers to it.  This module
;                   has two such tables, both of 16 entries, at 0xF7048D and
;                   0xF72323.  0xF7063C is an instruction boundary of this
;                   transcription, re-asserted on every emit.  The name IS
;                   the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_Volume: DispatchTable_F7048D[7]: SmfEvent_ControlChange's handler for MIDI controller 7.
SmfCC_Volume:
	bit	0, (0x124b:16)	; F7063C  bit 0,(0x124b)
	jr	nz, SmfCC_Volume_Skip3	; F70640  jr NZ,0xf7065b
	ld	(4665:16), 255	; F70642  ld (0x1239),0xff
	cp	(0x2732:16), 0x00	; F70647  cp (0x2732),0x00
	jr	nz, SmfCC_Volume_Skip2	; F7064C  jr NZ,0xf70653
	ld	(4665:16), 0	; F7064E  ld (0x1239),0x00
SmfCC_Volume_Skip2:
	ld	(4683:16), 1	; F70653  ld (0x124b),0x01
	calr	SmfPart_ResetAllRecords	; F70658  calr 0xf71417
SmfCC_Volume_Skip3:
	bit	0, (0x11b1:16)	; F7065B  bit 0,(0x11b1)
	jr	nz, SmfCC_Volume_Skip4	; F7065F  jr NZ,0xf70669
	calr	SmfPart_SetVolume	; F70661  calr 0xf7067f
	ld	(4664:16), 0	; F70664  ld (0x1238),0x00
SmfCC_Volume_Skip4:
	ld	(4526:16), 3	; F70669  ld (0x11ae),0x03
	ld	a, (4306:16)	; F7066E  ld A,(0x10d2)
	ld	(4527:16), a	; F70672  ld (0x11af),A
	ld	(4528:16), 127	; F70676  ld (0x11b0),0x7f
	calr	SmfCC_PutParamEvent	; F7067B  calr 0xf70e1d
	ret	; F7067E  ret

; --------------------------------------------------------------------------
; SmfPart_SetVolume
; Called from: in-module: 0xF70661 0xF724AD
; Touches: (0x10D2)
; Calls:   0xF702B8
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7067F is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfPart_SetVolume: SmfPart_GetRecordPtr, then record +5 = data byte 2.  Called by SmfCC_Volume (and SmfCC_Volume_MultiTrack).
SmfPart_SetVolume:
	calr	SmfPart_GetRecordPtr	; F7067F  calr 0xf702b8
	ld	a, (4306:16)	; F70682  ld A,(0x10d2)
	ld	(xiy+5), a	; F70686  ld (XIY+0x05),A
	ret	; F70689  ret

; --------------------------------------------------------------------------
; SmfCC_Pan
; Called from: no thunk slot and no in-module call or jp site -- reached
;              only by a branch from the routine above, or through a table
; Touches: (0x10D0) (0x10D2) (0x1238) (0x1239) (0x124B) (0x2732)
; Calls:   SmfPart_ResetAllRecords TrackCursor_Load BStore_PutByteAndAdvance Smf_TicksToPpq96 SmfEvent_MarkChannelUsed TrackCursor_Save
; Evidence (TABLE): it is an entry of a pointer table the consumer rule
;                   classed TRANSFER: the code that indexes that table
;                   fetches the entry and then transfers to it.  This module
;                   has two such tables, both of 16 entries, at 0xF7048D and
;                   0xF72323.  0xF7068A is an instruction boundary of this
;                   transcription, re-asserted on every emit.  The name IS
;                   the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_Pan: DispatchTable_F7048D[10]: SmfEvent_ControlChange's handler for MIDI controller 10.
SmfCC_Pan:
	bit	0, (0x124b:16)	; F7068A  bit 0,(0x124b)
	jr	nz, SmfCC_Pan_Skip2	; F7068E  jr NZ,0xf706a9
	ld	(4665:16), 255	; F70690  ld (0x1239),0xff
	cp	(0x2732:16), 0x00	; F70695  cp (0x2732),0x00
	jr	nz, SmfCC_Pan_Skip	; F7069A  jr NZ,0xf706a1
	ld	(4665:16), 0	; F7069C  ld (0x1239),0x00
SmfCC_Pan_Skip:
	ld	(4683:16), 1	; F706A1  ld (0x124b),0x01
	calr	SmfPart_ResetAllRecords	; F706A6  calr 0xf71417
SmfCC_Pan_Skip2:
	ld	iy, (Smf_EventStatus:16)	; F706A9  ld IY,(0x10d0)
	and	iy, 15	; F706AD  and IY,0x000f
	extz	xiy	; F706B1  extz XIY
	calr	TrackCursor_Load	; F706B3  calr 0xf7124e
	push	xiy	; F706B6  push XIY
	ld	a, 176:opc	; F706B7  ld A,0xb0
	calr	BStore_PutByteAndAdvance	; F706B9  calr 0xf70fda
	pop	xiy	; F706BC  pop XIY
	cp	(0x1238:16), 0x00	; F706BD  cp (0x1238),0x00
	jrl	nz, SmfCC_Pan_Return	; F706C2  jrl NZ,0xf70753
	sla	xiy, 1	; F706C5  sla 0x01,XIY
	push	xix	; F706C8  push XIX
	ld	xix, 4307	; F706C9  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F706CE  ld WA,(XIX+IY)
	pop	xix	; F706D3  pop XIX
	srl	xiy, 1	; F706D4  srl 0x01,XIY
	push	xiy	; F706D7  push XIY
	calr	Smf_TicksToPpq96	; F706D8  calr 0xf7122f
	pop	xiy	; F706DB  pop XIY
	push	xiy	; F706DC  push XIY
	calr	BStore_PutByteAndAdvance	; F706DD  calr 0xf70fda
	pop	xiy	; F706E0  pop XIY
	cp	(0x1238:16), 0x00	; F706E1  cp (0x1238),0x00
	jr	nz, SmfCC_Pan_Return	; F706E6  jr NZ,0xf70753
	ld	l, (Smf_EventStatus:16)	; F706E8  ld L,(0x10d0)
	and	l, 15	; F706EC  and L,0x0f
	xor	h, h	; F706EF  xor H,H
	extz	xhl	; F706F1  extz XHL
	push	xix	; F706F3  push XIX
	ld	xix, ByteMap_F70298	; F706F4  ld XIX,0x00f70298
	ld	a, (xix+hl)	; F706F9  ld A,(XIX+HL)
	cp	(0x1239:16), 0x00	; F706FE  cp (0x1239),0x00
	jr	z, SmfCC_Pan_Skip3	; F70703  jr Z,0xf7070f
	ld	xix, ByteMap_F70298 + 0x10	; F70705  ld XIX,0x00f702a8
	ld	a, (xix+hl)	; F7070A  ld A,(XIX+HL)
SmfCC_Pan_Skip3:
	pop	xix	; F7070F  pop XIX
	push	xiy	; F70710  push XIY
	calr	BStore_PutByteAndAdvance	; F70711  calr 0xf70fda
	pop	xiy	; F70714  pop XIY
	cp	(0x1238:16), 0x00	; F70715  cp (0x1238),0x00
	jr	nz, SmfCC_Pan_Return	; F7071A  jr NZ,0xf70753
	ld	a, 8:opc	; F7071C  ld A,0x08
	push	xiy	; F7071E  push XIY
	calr	BStore_PutByteAndAdvance	; F7071F  calr 0xf70fda
	pop	xiy	; F70722  pop XIY
	cp	(0x1238:16), 0x00	; F70723  cp (0x1238),0x00
	jr	nz, SmfCC_Pan_Return	; F70728  jr NZ,0xf70753
	ld	a, (4306:16)	; F7072A  ld A,(0x10d2)
	push	xiy	; F7072E  push XIY
	calr	BStore_PutByteAndAdvance	; F7072F  calr 0xf70fda
	pop	xiy	; F70732  pop XIY
	cp	(0x1238:16), 0x00	; F70733  cp (0x1238),0x00
	jr	nz, SmfCC_Pan_Return	; F70738  jr NZ,0xf70753
	ld	a, 127:opc	; F7073A  ld A,0x7f
	push	xiy	; F7073C  push XIY
	calr	BStore_PutByteAndAdvance	; F7073D  calr 0xf70fda
	pop	xiy	; F70740  pop XIY
	cp	(0x1238:16), 0x00	; F70741  cp (0x1238),0x00
	jr	nz, SmfCC_Pan_Return	; F70746  jr NZ,0xf70753
	calr	SmfEvent_MarkChannelUsed	; F70748  calr 0xf7129a
	calr	TrackCursor_Save	; F7074B  calr 0xf71275
	ld	(4664:16), 0	; F7074E  ld (0x1238),0x00
SmfCC_Pan_Return:
	ret	; F70753  ret

; --------------------------------------------------------------------------
; SmfCC_Expression
; Called from: no thunk slot and no in-module call or jp site -- reached
;              only by a branch from the routine above, or through a table
; Touches: (0x10D0) (0x10D2) (0x1238)
; Calls:   TrackCursor_Load BStore_PutByteAndAdvance Smf_TicksToPpq96 SmfEvent_MarkChannelUsed TrackCursor_Save
; Evidence (TABLE): it is an entry of a pointer table the consumer rule
;                   classed TRANSFER: the code that indexes that table
;                   fetches the entry and then transfers to it.  This module
;                   has two such tables, both of 16 entries, at 0xF7048D and
;                   0xF72323.  0xF70754 is an instruction boundary of this
;                   transcription, re-asserted on every emit.  The name IS
;                   the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_Expression: DispatchTable_F7048D[11]: SmfEvent_ControlChange's handler for MIDI controller 11.
SmfCC_Expression:
	ld	iy, (Smf_EventStatus:16)	; F70754  ld IY,(0x10d0)
	and	iy, 15	; F70758  and IY,0x000f
	extz	xiy	; F7075C  extz XIY
	push	xiy	; F7075E  push XIY
	calr	TrackCursor_Load	; F7075F  calr 0xf7124e
	ld	a, 211:opc	; F70762  ld A,0xd3
	calr	BStore_PutByteAndAdvance	; F70764  calr 0xf70fda
	pop	xiy	; F70767  pop XIY
	cp	(0x1238:16), 0x00	; F70768  cp (0x1238),0x00
	jr	nz, SmfCC_Expression_Return2	; F7076D  jr NZ,0xf707ad
	sla	xiy, 1	; F7076F  sla 0x01,XIY
	push	xix	; F70772  push XIX
	ld	xix, 4307	; F70773  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F70778  ld WA,(XIX+IY)
	pop	xix	; F7077D  pop XIX
	srl	xiy, 1	; F7077E  srl 0x01,XIY
	push	xiy	; F70781  push XIY
	calr	Smf_TicksToPpq96	; F70782  calr 0xf7122f
	pop	xiy	; F70785  pop XIY
	push	xiy	; F70786  push XIY
	calr	BStore_PutByteAndAdvance	; F70787  calr 0xf70fda
	pop	xiy	; F7078A  pop XIY
	cp	(0x1238:16), 0x00	; F7078B  cp (0x1238),0x00
	jr	nz, SmfCC_Expression_Return2	; F70790  jr NZ,0xf707ad
	ld	a, (4306:16)	; F70792  ld A,(0x10d2)
	push	xiy	; F70796  push XIY
	calr	BStore_PutByteAndAdvance	; F70797  calr 0xf70fda
	pop	xiy	; F7079A  pop XIY
	cp	(0x1238:16), 0x00	; F7079B  cp (0x1238),0x00
	jr	nz, SmfCC_Expression_Return2	; F707A0  jr NZ,0xf707ad
	calr	SmfEvent_MarkChannelUsed	; F707A2  calr 0xf7129a
	calr	TrackCursor_Save	; F707A5  calr 0xf71275
	ld	(4664:16), 0	; F707A8  ld (0x1238),0x00
SmfCC_Expression_Return2:
	ret	; F707AD  ret

; --------------------------------------------------------------------------
; SmfCC_BankSelectLsb
; Called from: in-module: 0xF7044B
; Touches: (0x10D0) (0x10D2)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF707AE is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_BankSelectLsb: SmfEvent_ControlChange's arm for MIDI controller 32 (`cp a,32 / jr z`).
SmfCC_BankSelectLsb:
	ld	iy, (Smf_EventStatus:16)	; F707AE  ld IY,(0x10d0)
	and	iy, 15	; F707B2  and IY,0x000f
	extz	xiy	; F707B6  extz XIY
	ld	a, (4306:16)	; F707B8  ld A,(0x10d2)
	push	xix	; F707BC  push XIX
	ld	xix, 4260	; F707BD  ld XIX,0x000010a4
	ld	(xix+iy), a	; F707C2  ld (XIX+IY),A
	pop	xix	; F707C7  pop XIX
	ret	; F707C8  ret
	push	xix	; F707C9  push XIX
	ld	xix, 4242	; F707CA  ld XIX,0x00001092
	ld	w, (xix+iy)	; F707CF  ld W,(XIX+IY)
	pop	xix	; F707D4  pop XIX
	and	a, 127	; F707D5  and A,0x7f
	rrc	w	; F707D8  rrc 0x01,W
	ld	l, w	; F707DB  ld L,W
	and	l, 128	; F707DD  and L,0x80
	and	w, 127	; F707E0  and W,0x7f
	or	a, l	; F707E3  or A,L
	ret	; F707E5  ret

; --------------------------------------------------------------------------
; SmfCC_Sustain
; Called from: in-module: 0xF70455 0xF722E9
; Touches: (0x10D0) (0x10D2) (0x11AE) (0x11AF) (0x11B0) (0x1239) (0x124B)
;          (0x2732)
; Calls:   SmfPart_ResetAllRecords SmfCC_PutSustainParamEvent
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF707E6 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_Sustain: SmfEvent_ControlChange's arm for MIDI controller 64 (`cp a,64 / jr z`).
SmfCC_Sustain:
	bit	0, (0x124b:16)	; F707E6  bit 0,(0x124b)
	jr	nz, SmfCC_Sustain_Skip2	; F707EA  jr NZ,0xf70805
	ld	(4665:16), 255	; F707EC  ld (0x1239),0xff
	cp	(0x2732:16), 0x00	; F707F1  cp (0x2732),0x00
	jr	nz, SmfCC_Sustain_Skip	; F707F6  jr NZ,0xf707fd
	ld	(4665:16), 0	; F707F8  ld (0x1239),0x00
SmfCC_Sustain_Skip:
	ld	(4683:16), 1	; F707FD  ld (0x124b),0x01
	calr	SmfPart_ResetAllRecords	; F70802  calr 0xf71417
SmfCC_Sustain_Skip2:
	xor	h, h	; F70805  xor H,H
	ld	l, (Smf_EventStatus:16)	; F70807  ld L,(0x10d0)
	and	l, 15	; F7080B  and L,0x0f
	ld	xiy, ByteMap_F7091E	; F7080E  ld XIY,0x00f7091e
	cp	(0x1239:16), 0xff	; F70813  cp (0x1239),0xff
	jr	z, SmfCC_Sustain_Skip3	; F70818  jr Z,0xf7081f
	ld	xiy, ByteMap_F7091E + 0x20	; F7081A  ld XIY,0x00f7093e
SmfCC_Sustain_Skip3:
	ld	l, (xiy+hl)	; F7081F  ld L,(XIY+HL)
	ld	(4526:16), l	; F70824  ld (0x11ae),L
	ld	a, (4306:16)	; F70828  ld A,(0x10d2)
	ld	(4527:16), a	; F7082C  ld (0x11af),A
	ld	(4528:16), 127	; F70830  ld (0x11b0),0x7f
	calr	SmfCC_PutSustainParamEvent	; F70835  calr 0xf7083b
	ret	; F70838  ret
	ret	; F70839  ret

; --------------------------------------------------------------------------
; SmfCC_Sustain_Nop
; Called from: in-module: 0xF72615
; Touches: nothing with an absolute address
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7083A is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Purpose: none -- the entry is a lone `ret`.  Named SmfCC_Sustain_Nop after what reaches it
;          (was sub_F7083A; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
SmfCC_Sustain_Nop:
	ret	; F7083A  ret

; --------------------------------------------------------------------------
; SmfCC_PutSustainParamEvent
; Called from: in-module: 0xF70835
; Touches: (0x1078) (0x107A) (0x10D0) (0x11AE) (0x11AF) (0x11B0) (0x11B2)
;          (0x1238)
; Calls:   Smf_ClampTrackToSlot TrackCursor_Load BStore_PutByteAndAdvance Smf_TicksToPpq96 SmfEvent_MarkChannelUsed TrackCursor_Save
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7083B is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_PutSustainParamEvent: SmfCC_PutParamEventWithNumber with the number fixed at 0xB5: unless (0x11AE) = 0xFF,
;   stores {0xB4, tick (Smf_TicksToPpq96), 0x35, (0x11AE), (0x11AF)&0x7F, (0x11B0)} in the event channel's track
;   (multi-track: slot Smf_ClampTrackToSlot((0x11B2))), marks the channel and saves the cursor. Only SmfCC_Sustain (CC
;   64) calls it, with (0x11AE) = ByteMap_F7091E[ch], (0x11AF) = the pedal value, (0x11B0) = 0x7F. Basis: caller +
;   body + sibling. (notes/naming-pilot-2026-10-06/proposals_wave6_v.json)
SmfCC_PutSustainParamEvent:
	push	xiy	; F7083B  push XIY
	cp	(0x11ae:16), 0xff	; F7083C  cp (0x11ae),0xff
	jrl	z, SmfCC_PutSustainParamEvent_Epilogue	; F70841  jrl Z,0xf7091b
	ld	iy, (Smf_EventStatus:16)	; F70844  ld IY,(0x10d0)
	and	iy, 15	; F70848  and IY,0x000f
	cp	(Smf_Format:16), 0x00	; F7084C  cp (0x1078),0x00
	jr	z, SmfCC_PutSustainParamEvent_Skip	; F70851  jr Z,0xf70862
	cp	(Smf_TrackCount:16), 0x02	; F70853  cp (0x107a),0x02
	jr	lt, SmfCC_PutSustainParamEvent_Skip	; F70858  jr LT,0xf70862
	ld	iy, (4530:16)	; F7085A  ld IY,(0x11b2)
	call	Smf_ClampTrackToSlot	; F7085E  call 0xf70c3f
SmfCC_PutSustainParamEvent_Skip:
	push	xiy	; F70862  push XIY
	pushw	bc	; F70863  push BC
	call	TrackCursor_Load	; F70864  call 0xf7124e
	popw	bc	; F70868  pop BC
	pop	xiy	; F70869  pop XIY
	ld	a, 176:opc	; F7086A  ld A,0xb0
	or	a, 4	; F7086C  or A,0x04
	push	xiy	; F7086F  push XIY
	pushw	bc	; F70870  push BC
	call	BStore_PutByteAndAdvance	; F70871  call 0xf70fda
	popw	bc	; F70875  pop BC
	pop	xiy	; F70876  pop XIY
	cp	(0x1238:16), 0x00	; F70877  cp (0x1238),0x00
	jrl	nz, SmfCC_PutSustainParamEvent_Epilogue	; F7087C  jrl NZ,0xf7091b
	sla	iy, 1	; F7087F  sla 0x01,IY
	push	xde	; F70882  push XDE
	ld	xde, 4307	; F70883  ld XDE,0x000010d3
	ld	wa, (xde+iy)	; F70888  ld WA,(XDE+IY)
	pop	xde	; F7088D  pop XDE
	sra	iy, 1	; F7088E  sra 0x01,IY
	pushw	bc	; F70891  push BC
	push	xiy	; F70892  push XIY
	call	Smf_TicksToPpq96	; F70893  call 0xf7122f
	call	BStore_PutByteAndAdvance	; F70897  call 0xf70fda
	pop	xiy	; F7089B  pop XIY
	popw	bc	; F7089C  pop BC
	cp	(0x1238:16), 0x00	; F7089D  cp (0x1238),0x00
	jrl	nz, SmfCC_PutSustainParamEvent_Epilogue	; F708A2  jrl NZ,0xf7091b
	ld	a, 181:opc	; F708A5  ld A,0xb5
	and	a, 127	; F708A7  and A,0x7f
	push	xiy	; F708AA  push XIY
	call	BStore_PutByteAndAdvance	; F708AB  call 0xf70fda
	pop	xiy	; F708AF  pop XIY
	cp	(0x1238:16), 0x00	; F708B0  cp (0x1238),0x00
	jrl	nz, SmfCC_PutSustainParamEvent_Epilogue	; F708B5  jrl NZ,0xf7091b
	pop	xiy	; F708B8  pop XIY
	push	xiy	; F708B9  push XIY
	ld	a, (4526:16)	; F708BA  ld A,(0x11ae)
	push	xiy	; F708BE  push XIY
	call	BStore_PutByteAndAdvance	; F708BF  call 0xf70fda
	pop	xiy	; F708C3  pop XIY
	cp	(0x1238:16), 0x00	; F708C4  cp (0x1238),0x00
	jr	nz, SmfCC_PutSustainParamEvent_Epilogue	; F708C9  jr NZ,0xf7091b
	ld	a, (4527:16)	; F708CB  ld A,(0x11af)
	and	a, 127	; F708CF  and A,0x7f
	push	xiy	; F708D2  push XIY
	call	BStore_PutByteAndAdvance	; F708D3  call 0xf70fda
	pop	xiy	; F708D7  pop XIY
	cp	(0x1238:16), 0x00	; F708D8  cp (0x1238),0x00
	jr	nz, SmfCC_PutSustainParamEvent_Epilogue	; F708DD  jr NZ,0xf7091b
	ld	a, (4528:16)	; F708DF  ld A,(0x11b0)
	push	xiy	; F708E3  push XIY
	call	BStore_PutByteAndAdvance	; F708E4  call 0xf70fda
	pop	xiy	; F708E8  pop XIY
	cp	(0x1238:16), 0x00	; F708E9  cp (0x1238),0x00
	jr	nz, SmfCC_PutSustainParamEvent_Epilogue	; F708EE  jr NZ,0xf7091b
	call	SmfEvent_MarkChannelUsed	; F708F0  call 0xf7129a
	ld	iy, (Smf_EventStatus:16)	; F708F4  ld IY,(0x10d0)
	and	iy, 15	; F708F8  and IY,0x000f
	cp	(Smf_Format:16), 0x00	; F708FC  cp (0x1078),0x00
	jr	z, SmfCC_PutSustainParamEvent_Skip2	; F70901  jr Z,0xf70912
	cp	(Smf_TrackCount:16), 0x02	; F70903  cp (0x107a),0x02
	jr	lt, SmfCC_PutSustainParamEvent_Skip2	; F70908  jr LT,0xf70912
	ld	iy, (4530:16)	; F7090A  ld IY,(0x11b2)
	call	Smf_ClampTrackToSlot	; F7090E  call 0xf70c3f
SmfCC_PutSustainParamEvent_Skip2:
	call	TrackCursor_Save	; F70912  call 0xf71275
	ld	(4664:16), 0	; F70916  ld (0x1238),0x00
SmfCC_PutSustainParamEvent_Epilogue:
	pop	xiy	; F7091B  pop XIY
	ret	; F7091C  ret

; --------------------------------------------------------------------------
; SmfCC_PutSustainParamEvent_Nop
; Called from: in-module: 0xF70460 0xF722F5
; Touches: nothing with an absolute address
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF7091D is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.
; Purpose: none -- the entry is a lone `ret`.  Named SmfCC_PutSustainParamEvent_Nop after what reaches it
;          (was sub_F7091D; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
SmfCC_PutSustainParamEvent_Nop:
	ret	; F7091D  ret

; --------------------------------------------------------------------------
; ByteMap_F7091E -- 64 bytes: 2 BYTE MAPS end to end, 32 bytes at 0xF7091E
;                   (0x00..0x1F), 32 bytes at 0xF7093E (0x00..0x1F).  Each
;                   ascends STRICTLY on its own and the sequence RESTARTS at
;                   each boundary, so this is N maps of the same shape
;                   rather than one long one.  The name describes the
;                   CONTENT; what the index spaces are is not established
;                   here.
; Read by: 7 byte-scan hits: 7 instruction operands -- `ld XIY,0x00f7091e`
;          at 0xF7080E (operand field 1 byte in); `ld XIY,0x00f7091e` at
;          0xF71948 (operand field 1 byte in); `ld XIY,0x00f7091e` at
;          0xF71981 (operand field 1 byte in); `ld XIY,0x00f7091e` at
;          0xF719BA (operand field 1 byte in) +3 more
; Entry count: 64 bytes.  The run is trimmed of trailing 0xFF, so it claims
;              no padding it did not earn; the byte before it is 0x0E and
;              the LAST byte of it is 0x1F.
; Evidence: every non-0xFF byte is compared with its predecessor on every
;           emit, WITHIN EACH of the 2 maximal ascending runs the rule
;           returns, and the runs are asserted to tile this segment exactly.
;           The BYTEMAP rule fires ZERO times over the proven prom_b
;           instruction text at (16 bytes, 12 values) and also at (20,14),
;           (24,16) and (16,16) (`python3 notes/prom_b_f6d002_layout.py
;           --null-ptr`).
; Unknown: what the two index spaces ARE, and who reads it.
; --------------------------------------------------------------------------
ByteMap_F7091E:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F7091E  [0..15]
	.byte	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F	; F7092E  [16..31]
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F7093E  [32..47]
	.byte	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F	; F7094E  [48..63]


; --------------------------------------------------------------------------
; sub_F7039A_Nop2
; Called from: in-module: 0xF7045A 0xF722EF
; Touches: nothing with an absolute address
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF7095E is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.
; Purpose: none -- the entry is a lone `ret`.  Named sub_F7039A_Nop2 after what reaches it
;          (was sub_F7095E; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
sub_F7039A_Nop2:
	ret	; F7095E  ret
	ret	; F7095F  ret

; --------------------------------------------------------------------------
; SmfCC_Effect3Depth
; Called from: in-module: 0xF7046B
; Touches: (0x10D2) (0x11AE) (0x11AF) (0x11B0) (0x11B1) (0x1238) (0x1239)
;          (0x124B) (0x2732)
; Calls:   SmfPart_ResetAllRecords SmfPart_SetEffect3Depth SmfCC_PutParamEvent
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF70960 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_Effect3Depth: SmfEvent_ControlChange's arm for MIDI controller 93 (`cp a,93 / jr z`).
SmfCC_Effect3Depth:
	bit	0, (0x124b:16)	; F70960  bit 0,(0x124b)
	jr	nz, SmfCC_Effect3Depth_Skip2	; F70964  jr NZ,0xf7097f
	ld	(4665:16), 255	; F70966  ld (0x1239),0xff
	cp	(0x2732:16), 0x00	; F7096B  cp (0x2732),0x00
	jr	nz, SmfCC_Effect3Depth_Skip	; F70970  jr NZ,0xf70977
	ld	(4665:16), 0	; F70972  ld (0x1239),0x00
SmfCC_Effect3Depth_Skip:
	ld	(4683:16), 1	; F70977  ld (0x124b),0x01
	calr	SmfPart_ResetAllRecords	; F7097C  calr 0xf71417
SmfCC_Effect3Depth_Skip2:
	bit	0, (0x11b1:16)	; F7097F  bit 0,(0x11b1)
	jr	nz, SmfCC_Effect3Depth_Skip3	; F70983  jr NZ,0xf7098d
	calr	SmfPart_SetEffect3Depth	; F70985  calr 0xf709a3
	ld	(4664:16), 0	; F70988  ld (0x1238),0x00
SmfCC_Effect3Depth_Skip3:
	ld	(4526:16), 5	; F7098D  ld (0x11ae),0x05
	ld	a, (4306:16)	; F70992  ld A,(0x10d2)
	ld	(4527:16), a	; F70996  ld (0x11af),A
	ld	(4528:16), 127	; F7099A  ld (0x11b0),0x7f
	calr	SmfCC_PutParamEvent	; F7099F  calr 0xf70e1d
	ret	; F709A2  ret

; --------------------------------------------------------------------------
; SmfPart_SetEffect3Depth
; Called from: in-module: 0xF70985 0xF72684
; Touches: (0x10D2)
; Calls:   0xF702B8
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF709A3 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfPart_SetEffect3Depth: SmfPart_GetRecordPtr, then record +7 = data byte 2, keeping its bit 7.  Called by SmfCC_Effect3Depth.
SmfPart_SetEffect3Depth:
	calr	SmfPart_GetRecordPtr	; F709A3  calr 0xf702b8
	ld	a, (4306:16)	; F709A6  ld A,(0x10d2)
	ld	w, (xiy+7)	; F709AA  ld W,(XIY+0x07)
	and	w, 128	; F709AD  and W,0x80
	or	w, a	; F709B0  or W,A
	ld	(xiy+7), w	; F709B2  ld (XIY+0x07),W
	ret	; F709B5  ret

; --------------------------------------------------------------------------
; SmfCC_Effect4Depth
; Called from: in-module: 0xF70470
; Touches: (0x10D2) (0x11AE) (0x11AF) (0x11B0) (0x11B1) (0x1238)
; Calls:   SmfPart_SetEffect4Depth SmfCC_PutParamEvent
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF709B6 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_Effect4Depth: SmfEvent_ControlChange's arm for MIDI controller 94 (`cp a,94 / jr z`).
SmfCC_Effect4Depth:
	bit	0, (0x11b1:16)	; F709B6  bit 0,(0x11b1)
	jr	nz, SmfCC_Effect4Depth_Skip	; F709BA  jr NZ,0xf709c4
	calr	SmfPart_SetEffect4Depth	; F709BC  calr 0xf709da
	ld	(4664:16), 0	; F709BF  ld (0x1238),0x00
SmfCC_Effect4Depth_Skip:
	ld	(4526:16), 6	; F709C4  ld (0x11ae),0x06
	ld	a, (4306:16)	; F709C9  ld A,(0x10d2)
	ld	(4527:16), a	; F709CD  ld (0x11af),A
	ld	(4528:16), 127	; F709D1  ld (0x11b0),0x7f
	calr	SmfCC_PutParamEvent	; F709D6  calr 0xf70e1d
	ret	; F709D9  ret

; --------------------------------------------------------------------------
; SmfPart_SetEffect4Depth
; Called from: in-module: 0xF709BC 0xF726A8
; Touches: (0x10D2)
; Calls:   0xF702B8
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF709DA is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfPart_SetEffect4Depth: record +8 the same way.  Called by SmfCC_Effect4Depth.
SmfPart_SetEffect4Depth:
	calr	SmfPart_GetRecordPtr	; F709DA  calr 0xf702b8
	ld	a, (4306:16)	; F709DD  ld A,(0x10d2)
	ld	w, (xiy+8)	; F709E1  ld W,(XIY+0x08)
	and	w, 128	; F709E4  and W,0x80
	or	w, a	; F709E7  or W,A
	ld	(xiy+8), w	; F709E9  ld (XIY+0x08),W
	ret	; F709EC  ret

; --------------------------------------------------------------------------
; SmfCC_Effect1Depth
; Called from: in-module: 0xF70466
; Touches: (0x10D2) (0x11AE) (0x11AF) (0x11B0) (0x11B1) (0x1238) (0x1239)
;          (0x124B) (0x2732)
; Calls:   SmfPart_ResetAllRecords SmfPart_SetEffect1Depth SmfCC_PutParamEvent
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF709ED is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_Effect1Depth: SmfEvent_ControlChange's arm for MIDI controller 91 (`cp a,91 / jr z`).
SmfCC_Effect1Depth:
	bit	0, (0x124b:16)	; F709ED  bit 0,(0x124b)
	jr	nz, SmfCC_Effect1Depth_Skip2	; F709F1  jr NZ,0xf70a0c
	ld	(4665:16), 255	; F709F3  ld (0x1239),0xff
	cp	(0x2732:16), 0x00	; F709F8  cp (0x2732),0x00
	jr	nz, SmfCC_Effect1Depth_Skip	; F709FD  jr NZ,0xf70a04
	ld	(4665:16), 0	; F709FF  ld (0x1239),0x00
SmfCC_Effect1Depth_Skip:
	ld	(4683:16), 1	; F70A04  ld (0x124b),0x01
	calr	SmfPart_ResetAllRecords	; F70A09  calr 0xf71417
SmfCC_Effect1Depth_Skip2:
	bit	0, (0x11b1:16)	; F70A0C  bit 0,(0x11b1)
	jr	nz, SmfCC_Effect1Depth_Skip3	; F70A10  jr NZ,0xf70a1a
	calr	SmfPart_SetEffect1Depth	; F70A12  calr 0xf70a30
	ld	(4664:16), 0	; F70A15  ld (0x1238),0x00
SmfCC_Effect1Depth_Skip3:
	ld	(4526:16), 7	; F70A1A  ld (0x11ae),0x07
	ld	a, (4306:16)	; F70A1F  ld A,(0x10d2)
	ld	(4527:16), a	; F70A23  ld (0x11af),A
	ld	(4528:16), 127	; F70A27  ld (0x11b0),0x7f
	calr	SmfCC_PutParamEvent	; F70A2C  calr 0xf70e1d
	ret	; F70A2F  ret

; --------------------------------------------------------------------------
; SmfPart_SetEffect1Depth
; Called from: in-module: 0xF70A12 0xF72660
; Touches: (0x10D2)
; Calls:   0xF702B8
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF70A30 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfPart_SetEffect1Depth: record +9 the same way.  Called by SmfCC_Effect1Depth.
SmfPart_SetEffect1Depth:
	calr	SmfPart_GetRecordPtr	; F70A30  calr 0xf702b8
	ld	a, (4306:16)	; F70A33  ld A,(0x10d2)
	ld	w, (xiy+9)	; F70A37  ld W,(XIY+0x09)
	and	w, 128	; F70A3A  and W,0x80
	or	w, a	; F70A3D  or W,A
	ld	(xiy+9), w	; F70A3F  ld (XIY+0x09),W
	ret	; F70A42  ret

; --------------------------------------------------------------------------
; SmfCC_DataIncrement
; Called from: in-module: 0xF70475 0xF7230B
; Touches: (0x10D0)
; Calls:   SmfCC_PutSelectedRpnValueEvent
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF70A43 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_DataIncrement: SmfEvent_ControlChange's arm for MIDI controller 96 (`cp a,96 / jr z`).
SmfCC_DataIncrement:
	ld	iy, (Smf_EventStatus:16)	; F70A43  ld IY,(0x10d0)
	and	iy, 15	; F70A47  and IY,0x000f
	push	xix	; F70A4B  push XIX
	ld	xix, 4568	; F70A4C  ld XIX,0x000011d8
	ld	a, (xix+iy)	; F70A51  ld A,(XIX+IY)
	pop	xix	; F70A56  pop XIX
	cp	a, 255	; F70A57  cp A,0xff
	jr	z, SmfCC_DataIncrement_Return	; F70A5A  jr Z,0xf70a96
	exts	wa	; F70A5C  exts WA
	ld	hl, wa	; F70A5E  ld HL,WA
	extz	xhl	; F70A60  extz XHL
	sla	hl, 2	; F70A62  sla 0x02,HL
	push	xix	; F70A65  push XIX
	ld	xix, Data_F70AD7	; F70A66  ld XIX,0x00f70ad7
	ld	xhl, (xix+hl)	; F70A6B  ld XHL,(XIX+HL)
	pop	xix	; F70A70  pop XIX
	ld	a, (xhl+iy)	; F70A71  ld A,(XHL+IY)
	inc	1, a	; F70A76  inc 1,A
	xor	b, b	; F70A78  xor B,B
	ld	ix, bc	; F70A7A  ld IX,BC
	push	xiy	; F70A7C  push XIY
	ld	xiy, Data_F70AD7 + 0xC	; F70A7D  ld XIY,0x00f70ae3
	ld	e, (xiy+ix)	; F70A82  ld E,(XIY+IX)
	pop	xiy	; F70A87  pop XIY
	cp	a, e	; F70A88  cp A,E
	jr	ule, SmfCC_DataIncrement_Skip	; F70A8A  jr ULE,0xf70a8e
	ld	a, e	; F70A8C  ld A,E
SmfCC_DataIncrement_Skip:
	ld	(xhl+iy), a	; F70A8E  ld (XHL+IY),A
	calr	SmfCC_PutSelectedRpnValueEvent	; F70A93  calr 0xf70ae9
SmfCC_DataIncrement_Return:
	ret	; F70A96  ret

; --------------------------------------------------------------------------
; SmfCC_DataDecrement
; Called from: in-module: 0xF7047A 0xF72310
; Touches: (0x10D0)
; Calls:   SmfCC_PutSelectedRpnValueEvent
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF70A97 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_DataDecrement: SmfEvent_ControlChange's arm for MIDI controller 97 (`cp a,97 / jr z`).
SmfCC_DataDecrement:
	ld	iy, (Smf_EventStatus:16)	; F70A97  ld IY,(0x10d0)
	and	iy, 15	; F70A9B  and IY,0x000f
	push	xix	; F70A9F  push XIX
	ld	xix, 4568	; F70AA0  ld XIX,0x000011d8
	ld	a, (xix+iy)	; F70AA5  ld A,(XIX+IY)
	pop	xix	; F70AAA  pop XIX
	cp	a, 255	; F70AAB  cp A,0xff
	jr	z, SmfCC_DataDecrement_Return	; F70AAE  jr Z,0xf70ad6
	exts	wa	; F70AB0  exts WA
	ld	hl, wa	; F70AB2  ld HL,WA
	sla	hl, 2	; F70AB4  sla 0x02,HL
	push	xix	; F70AB7  push XIX
	ld	xix, Data_F70AD7	; F70AB8  ld XIX,0x00f70ad7
	ld	xhl, (xix+hl)	; F70ABD  ld XHL,(XIX+HL)
	pop	xix	; F70AC2  pop XIX
	ld	a, (xhl+iy)	; F70AC3  ld A,(XHL+IY)
	cp	a, 0:i3	; F70AC8  cp A,0
	jr	z, SmfCC_DataDecrement_Skip	; F70ACA  jr Z,0xf70ace
	dec	1, a	; F70ACC  dec 1,A
SmfCC_DataDecrement_Skip:
	ld	(xhl+iy), a	; F70ACE  ld (XHL+IY),A
	calr	SmfCC_PutSelectedRpnValueEvent	; F70AD3  calr 0xf70ae9
SmfCC_DataDecrement_Return:
	ret	; F70AD6  ret

; --------------------------------------------------------------------------
; Data_F70AD7 -- 18 bytes this block could not split.  No content rule
;                framed it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or
;                ASCII -- and the code walk never reached it from a thunk
;                slot, a proven call site, an opcode-anchored call or an
;                entry of a table the firmware transfers to.  So it is
;                emitted as bytes rather than guessed.
; Read by: 5 byte-scan hits: 5 instruction operands -- `ld XIX,0x00f70ad7`
;          at 0xF70560 (operand field 1 byte in); `ld XIX,0x00f70ad7` at
;          0xF705BC (operand field 1 byte in); `ld XIX,0x00f70ad7` at
;          0xF70A66 (operand field 1 byte in); `ld XIX,0x00f70ad7` at
;          0xF70AB8 (operand field 1 byte in) +1 more
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; Unknown: everything about it except its bytes.
; --------------------------------------------------------------------------
Data_F70AD7:
	.byte	0x08, 0x12, 0x00, 0x00, 0xE8, 0x11, 0x00, 0x00, 0xF8, 0x11, 0x00, 0x00, 0x0C, 0x7F, 0xFF, 0x00	; F70AD7  [0..15]
	.byte	0x00, 0x00	; F70AE7  [16..17]


; --------------------------------------------------------------------------
; SmfCC_PutSelectedRpnValueEvent
; Called from: in-module: 0xF70595 0xF705F3 0xF70A93 0xF70AD3 0xF72437
;              0xF72491
; Touches: (0x10D0) (0x11AF)
; Calls:   SmfCC_PutRpnParamEvent
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF70AE9 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_PutSelectedRpnValueEvent: If the event's channel has RPN 0, 1 or 2 selected ((0x11D8)[ch] != 0xFF, set by
;   SmfCC_RpnMsb/Lsb), copies that RPN's stored value for the channel (arrays 0x1208 / 0x11E8 / 0x11F8 via
;   Data_F70AD7) to (0x11AF) and calls SmfCC_PutRpnParamEvent, which stores it in the track as a 0xB0 parameter event of class
;   0x0B / 0x0A / 0x09. Shared tail of the data-entry, increment and decrement CC handlers. Basis: callers + body.
;   (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
SmfCC_PutSelectedRpnValueEvent:
	ld	iy, (Smf_EventStatus:16)	; F70AE9  ld IY,(0x10d0)
	and	iy, 15	; F70AED  and IY,0x000f
	push	xix	; F70AF1  push XIX
	ld	xix, 4568	; F70AF2  ld XIX,0x000011d8
	ld	l, (xix+iy)	; F70AF7  ld L,(XIX+IY)
	pop	xix	; F70AFC  pop XIX
	xor	h, h	; F70AFD  xor H,H
	cp	l, 255	; F70AFF  cp L,0xff
	jr	z, SmfCC_PutSelectedRpnValueEvent_Return	; F70B02  jr Z,0xf70b21
	ld	c, l	; F70B04  ld C,L
	sla	hl, 2	; F70B06  sla 0x02,HL
	push	xix	; F70B09  push XIX
	ld	xix, Data_F70AD7	; F70B0A  ld XIX,0x00f70ad7
	ld	xhl, (xix+hl)	; F70B0F  ld XHL,(XIX+HL)
	pop	xix	; F70B14  pop XIX
	ld	a, (xhl+iy)	; F70B15  ld A,(XHL+IY)
	ld	(4527:16), a	; F70B1A  ld (0x11af),A
	calr	SmfCC_PutRpnParamEvent	; F70B1E  calr 0xf70b22
SmfCC_PutSelectedRpnValueEvent_Return:
	ret	; F70B21  ret

; --------------------------------------------------------------------------
; SmfCC_PutRpnParamEvent
; Called from: in-module: 0xF70B1E
; Touches: (0x1078) (0x107A) (0x10D0) (0x11AF) (0x11B2) (0x1238) (0x1239)
; Calls:   Smf_ClampTrackToSlot TrackCursor_Load BStore_PutByteAndAdvance Smf_TicksToPpq96 SmfEvent_MarkChannelUsed TrackCursor_Save
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF70B22 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_PutRpnParamEvent: C = the selected RPN (0/1/2): stores {0xB0 (|2, |1 if (0x11AF) b7, for RPN 1 only), tick
;   (Smf_TicksToPpq96), the channel's part (ByteMap_F70298; raw channel for multi-track), class Data_F70C3C[C] = 0x0B
;   / 0x0A / 0x09, (0x11AF)&0x7F, 0x7F} in the channel's track, marks the channel and saves the cursor. Only
;   SmfCC_PutSelectedRpnValueEvent calls it, after loading the RPN's value into (0x11AF). Basis: caller + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave6_v.json)
SmfCC_PutRpnParamEvent:
	push	xiy	; F70B22  push XIY
	cpw	(Smf_Format:16), 0x0000	; F70B23  cp (0x1078),0x0000
	jr	z, SmfCC_PutRpnParamEvent_Skip	; F70B29  jr Z,0xf70b3c
	cpw	(Smf_TrackCount:16), 0x0002	; F70B2B  cp (0x107a),0x0002
	jr	c, SmfCC_PutRpnParamEvent_Skip	; F70B31  jr C,0xf70b3c
	ld	iy, (4530:16)	; F70B33  ld IY,(0x11b2)
	extz	xiy	; F70B37  extz XIY
	calr	Smf_ClampTrackToSlot	; F70B39  calr 0xf70c3f
SmfCC_PutRpnParamEvent_Skip:
	push	xiy	; F70B3C  push XIY
	pushw	bc	; F70B3D  push BC
	calr	TrackCursor_Load	; F70B3E  calr 0xf7124e
	popw	bc	; F70B41  pop BC
	pop	xiy	; F70B42  pop XIY
	ld	a, 176:opc	; F70B43  ld A,0xb0
	cp	c, 1:i3	; F70B45  cp C,1
	jr	nz, SmfCC_PutRpnParamEvent_Skip2	; F70B47  jr NZ,0xf70b55
	or	a, 2	; F70B49  or A,0x02
	bit	7, (0x11af:16)	; F70B4C  bit 7,(0x11af)
	jr	z, SmfCC_PutRpnParamEvent_Skip2	; F70B50  jr Z,0xf70b55
	or	a, 1	; F70B52  or A,0x01
SmfCC_PutRpnParamEvent_Skip2:
	push	xiy	; F70B55  push XIY
	pushw	bc	; F70B56  push BC
	calr	BStore_PutByteAndAdvance	; F70B57  calr 0xf70fda
	popw	bc	; F70B5A  pop BC
	pop	xiy	; F70B5B  pop XIY
	cp	(0x1238:16), 0x00	; F70B5C  cp (0x1238),0x00
	jrl	nz, SmfCC_PutRpnParamEvent_Epilogue	; F70B61  jrl NZ,0xf70c3a
	sla	xiy, 1	; F70B64  sla 0x01,XIY
	push	xix	; F70B67  push XIX
	ld	xix, 4307	; F70B68  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F70B6D  ld WA,(XIX+IY)
	pop	xix	; F70B72  pop XIX
	srl	xiy, 1	; F70B73  srl 0x01,XIY
	pushw	bc	; F70B76  push BC
	push	xiy	; F70B77  push XIY
	calr	Smf_TicksToPpq96	; F70B78  calr 0xf7122f
	calr	BStore_PutByteAndAdvance	; F70B7B  calr 0xf70fda
	pop	xiy	; F70B7E  pop XIY
	popw	bc	; F70B7F  pop BC
	cp	(0x1238:16), 0x00	; F70B80  cp (0x1238),0x00
	jrl	nz, SmfCC_PutRpnParamEvent_Epilogue	; F70B85  jrl NZ,0xf70c3a
	ld	l, c	; F70B88  ld L,C
	xor	h, h	; F70B8A  xor H,H
	ld	l, (Smf_EventStatus:16)	; F70B8C  ld L,(0x10d0)
	and	l, 15	; F70B90  and L,0x0f
	xor	h, h	; F70B93  xor H,H
	cpw	(Smf_Format:16), 0x0000	; F70B95  cp (0x1078),0x0000
	jr	z, SmfCC_PutRpnParamEvent_Skip3	; F70B9B  jr Z,0xf70ba9
	cpw	(Smf_TrackCount:16), 0x0002	; F70B9D  cp (0x107a),0x0002
	jr	c, SmfCC_PutRpnParamEvent_Skip3	; F70BA3  jr C,0xf70ba9
	ld	a, l	; F70BA5  ld A,L
	jr	SmfCC_PutRpnParamEvent_Join	; F70BA7  jr T,0xf70bbf
SmfCC_PutRpnParamEvent_Skip3:
	ld	xix, ByteMap_F70298 + 0x10	; F70BA9  ld XIX,0x00f702a8
	cp	(0x1239:16), 0xff	; F70BAE  cp (0x1239),0xff
	jr	z, SmfCC_PutRpnParamEvent_Skip4	; F70BB3  jr Z,0xf70bba
	ld	xix, ByteMap_F70298	; F70BB5  ld XIX,0x00f70298
SmfCC_PutRpnParamEvent_Skip4:
	ld	a, (xix+hl)	; F70BBA  ld A,(XIX+HL)
SmfCC_PutRpnParamEvent_Join:
	pushw	bc	; F70BBF  push BC
	push	xiy	; F70BC0  push XIY
	calr	BStore_PutByteAndAdvance	; F70BC1  calr 0xf70fda
	pop	xiy	; F70BC4  pop XIY
	popw	bc	; F70BC5  pop BC
	cp	(0x1238:16), 0x00	; F70BC6  cp (0x1238),0x00
	jrl	nz, SmfCC_PutRpnParamEvent_Epilogue	; F70BCB  jrl NZ,0xf70c3a
	pop	xiy	; F70BCE  pop XIY
	push	xiy	; F70BCF  push XIY
	push	xde	; F70BD0  push XDE
	ld	xde, Data_F70C3C	; F70BD1  ld XDE,0x00f70c3c
	ld	a, (xde+c)	; F70BD6  ld A,(XDE+C)
	pop	xde	; F70BDB  pop XDE
	push	xiy	; F70BDC  push XIY
	calr	BStore_PutByteAndAdvance	; F70BDD  calr 0xf70fda
	pop	xiy	; F70BE0  pop XIY
	cp	(0x1238:16), 0x00	; F70BE1  cp (0x1238),0x00
	jrl	nz, SmfCC_PutRpnParamEvent_Epilogue	; F70BE6  jrl NZ,0xf70c3a
	ld	a, (4527:16)	; F70BE9  ld A,(0x11af)
	and	a, 127	; F70BED  and A,0x7f
	push	xiy	; F70BF0  push XIY
	calr	BStore_PutByteAndAdvance	; F70BF1  calr 0xf70fda
	pop	xiy	; F70BF4  pop XIY
	cp	(0x1238:16), 0x00	; F70BF5  cp (0x1238),0x00
	jrl	nz, SmfCC_PutRpnParamEvent_Epilogue	; F70BFA  jrl NZ,0xf70c3a
	ld	a, 127:opc	; F70BFD  ld A,0x7f
	push	xiy	; F70BFF  push XIY
	calr	BStore_PutByteAndAdvance	; F70C00  calr 0xf70fda
	pop	xiy	; F70C03  pop XIY
	cp	(0x1238:16), 0x00	; F70C04  cp (0x1238),0x00
	jrl	nz, SmfCC_PutRpnParamEvent_Epilogue	; F70C09  jrl NZ,0xf70c3a
	calr	SmfEvent_MarkChannelUsed	; F70C0C  calr 0xf7129a
	ld	iy, (Smf_EventStatus:16)	; F70C0F  ld IY,(0x10d0)
	and	iy, 15	; F70C13  and IY,0x000f
	extz	xiy	; F70C17  extz XIY
	cpw	(Smf_Format:16), 0x0000	; F70C19  cp (0x1078),0x0000
	jr	z, SmfCC_PutRpnParamEvent_Skip5	; F70C1F  jr Z,0xf70c32
	cpw	(Smf_TrackCount:16), 0x0002	; F70C21  cp (0x107a),0x0002
	jr	c, SmfCC_PutRpnParamEvent_Skip5	; F70C27  jr C,0xf70c32
	ld	iy, (4530:16)	; F70C29  ld IY,(0x11b2)
	extz	xiy	; F70C2D  extz XIY
	calr	Smf_ClampTrackToSlot	; F70C2F  calr 0xf70c3f
SmfCC_PutRpnParamEvent_Skip5:
	calr	TrackCursor_Save	; F70C32  calr 0xf71275
	ld	(4664:16), 0	; F70C35  ld (0x1238),0x00
SmfCC_PutRpnParamEvent_Epilogue:
	pop	xiy	; F70C3A  pop XIY
	ret	; F70C3B  ret

; --------------------------------------------------------------------------
; Data_F70C3C -- 3 bytes this block could not split.  No content rule framed
;                it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or ASCII
;                -- and the code walk never reached it from a thunk slot, a
;                proven call site, an opcode-anchored call or an entry of a
;                table the firmware transfers to.  So it is emitted as bytes
;                rather than guessed.
; ⚠ these bytes DO decode cleanly as instructions, but the decode does not
;   end in a `ret`/`reti`/unconditional transfer.  That is not evidence:
;   round 4's rule, which accepted a run on a clean decode alone, accepts
;   13.9% of record-aligned chunks of PROVEN display-list data as code
;   (`python3 notes/prom_b_f6d002_layout.py --null-accept`).
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XDE,0x00f70c3c` at
;          0xF70BD1 (operand field 1 byte in)
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; Unknown: everything about it except its bytes.
; --------------------------------------------------------------------------
Data_F70C3C:
	.byte	0x0B, 0x0A, 0x09	; F70C3C  [0..2]


; --------------------------------------------------------------------------
; Smf_ClampTrackToSlot
; Called from: in-module: 0xF6FC9D 0xF6FCE5 0xF6FD48 0xF7085E 0xF7090E
;              0xF70B39 0xF70C2F 0xF71AB8 +1 more
; Touches: nothing with an absolute address
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF70C3F is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_ClampTrackToSlot: XIY := min(zero-extended IY, 1): SMF track 0 keeps cursor slot 0, every later track shares
;   slot 1 -- the same clamp as Smf_TrackToSlot, which the *_MultiTrack handlers use. The shared SMF event handlers
;   (SmfMeta_SetTempo, SmfCC_PutParamEventWithNumber, SmfCC_PutSustainParamEvent, SmfCC_PutRpnParamEvent) apply it to the track counter (0x11B2)
;   for format 1 with 2+ tracks before TrackCursor_Load. Basis: callers + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_j.json)
Smf_ClampTrackToSlot:
	extz	xiy	; F70C3F  extz XIY
	cp	xiy, 1	; F70C41  cp XIY,0x00000001
	jr	ule, Smf_ClampTrackToSlot_Return	; F70C47  jr ULE,0xf70c4e
	ld	xiy, 1	; F70C49  ld XIY,0x00000001
Smf_ClampTrackToSlot_Return:
	ret	; F70C4E  ret

; --------------------------------------------------------------------------
; ByteMap_F70C4F -- 0xF70C4F-0xF70C5E, 16 bytes: 0x00-0x08, 0x0F, 0x09-0x0E
;   -- the identity on 0..15 except that 0x0F is moved to entry 9 and
;   0x09-0x0E each move up one.  Converted 2026-09-25 (lane promb): the source
;   framed the bytes as instructions (`nop`, `normal`, `push SR`, `pop SR`,
;   `max`, `halt`, `ei 7`, `ld (0x0f),0x09`, `ld (0x0b),0x0d0c`, `ret`) after
;   the `ret` that ends Smf_ClampTrackToSlot; nothing branches into them.
; Unknown: the reader.  No 24- or 32-bit spelling of 0xF70C4F-0xF70C6E occurs
;   in prom_a or prom_b; the identity map ByteMap_F70C5F follows it directly,
;   the same shape as the flag-selected pairs ByteMap_F6F985/F6F996 that
;   Smf_ResetTrackAssignToIdentity copies -- a pattern, not a reader.
; --------------------------------------------------------------------------
ByteMap_F70C4F:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x0F, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E	; F70C4F  [0..15]

; --------------------------------------------------------------------------
; ByteMap_F70C5F -- 18 bytes: a BYTE MAP.  0 of them are 0xFF and the other
;                   18 ASCEND STRICTLY, 0x00 to 0xD0, with jumps.  The name
;                   describes the CONTENT; what the two index spaces are is
;                   not established here.
; Read by: nothing in prom_a or prom_b spells this address as a 32-bit word,
;          so whatever reaches it computes the address
; Entry count: 18 bytes.  The run is trimmed of trailing 0xFF, so it claims
;              no padding it did not earn; the byte before it is 0x0E and
;              the LAST byte of it is 0xD0.
; Evidence: every non-0xFF byte is compared with its predecessor on every
;           emit, WITHIN EACH of the 1 maximal ascending runs the rule
;           returns, and the runs are asserted to tile this segment exactly.
;           The BYTEMAP rule fires ZERO times over the proven prom_b
;           instruction text at (16 bytes, 12 values) and also at (20,14),
;           (24,16) and (16,16) (`python3 notes/prom_b_f6d002_layout.py
;           --null-ptr`).
; Unknown: what the two index spaces ARE, and who reads it.
; --------------------------------------------------------------------------
ByteMap_F70C5F:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F70C5F  [0..15]
; ⚠ CORRECTED 2026-09-25 (lane promb): the map is 16 bytes (0x00-0x0F), not
;   18.  Its last two "entries" (0xC1, 0xD0) are the first two bytes of
;   SmfCC_Nrpn's first instruction, `ld C,(0x10d0)`, which a `calr` at
;   0xF7047F reaches.


; --------------------------------------------------------------------------
; SmfCC_Nrpn -- 0xF70C6F-0xF70CB9 (converted 2026-09-25, lane promb; was the
;   last two bytes of ByteMap_F70C5F and `Data_F70C71`, 73 bytes filed as
;   "everything about it except its bytes" unknown).
; Called from: 0xF7047F (`calr`).
; Does:    C = (0x10D0) AND 0x0F; clears bit C of the words at (0x11B4) and
;          (0x11B6) (`rcf` then `stcf A,DE`, with A = C, bank-3 registers
;          RL3/QHL3 holding A and DE across it); then writes 0xFF to
;          (0x11D8 + C).  Its neighbour SmfCC_RpnMsb indexes (0x11B8) with the
;          same (0x10D0) AND 0x0F.
; Evidence: MAME unidasm and llvm-mc agree on every instruction, the one call
;          site lands on the first, and it ends with `ret` right where
;          SmfCC_RpnMsb, a routine two callers reach, begins.
; Unknown: what the nibble of (0x10D0) and the three tables it indexes are.
; --------------------------------------------------------------------------
; SmfCC_Nrpn: SmfEvent_ControlChange's arm for controllers 98 and 99 (NRPN LSB / MSB): it clears the channel's bit in the
;   mask at 0x11B4.
SmfCC_Nrpn:
	ld	c, (Smf_EventStatus:16)	; F70C6F  ld C,(0x10d0)
	and	c, 15	; F70C73  and C,0x0f
	ldfr_berp	a, 0x3c	; F70C76  ld RL3,A
	ldfr_werp	de, 0x3e	; F70C79  ld QHL3,DE
	ld	de, (4532:16)	; F70C7C  ld DE,(0x11b4)
	ld	a, c	; F70C80  ld A,C
	rcf	; F70C82  rcf
	stcf_a_16	de	; F70C83  stcf A,DE
	ldto_berp	a, 0x3c	; F70C85  ld A,RL3
	ld	(4532:16), de	; F70C88  ld (0x11b4),DE
	ldto_werp	de, 0x3e	; F70C8C  ld DE,QHL3
	ldfr_berp	a, 0x3c	; F70C8F  ld RL3,A
	ldfr_werp	de, 0x3e	; F70C92  ld QHL3,DE
	ld	de, (4534:16)	; F70C95  ld DE,(0x11b6)
	ld	a, c	; F70C99  ld A,C
	rcf	; F70C9B  rcf
	stcf_a_16	de	; F70C9C  stcf A,DE
	ldto_berp	a, 0x3c	; F70C9E  ld A,RL3
	ld	(4534:16), de	; F70CA1  ld (0x11b6),DE
	ldto_werp	de, 0x3e	; F70CA5  ld DE,QHL3
	xor	b, b	; F70CA8  xor B,B
	ld	iy, bc	; F70CAA  ld IY,BC
	push	xix	; F70CAC  push XIX
	ld	xix, 4568	; F70CAD  ld XIX,0x000011d8
	ld	(xix+iy), 0xff	; F70CB2  ld (XIX+IY),0xff
	pop	xix	; F70CB8  pop XIX
	ret	; F70CB9  ret


; --------------------------------------------------------------------------
; SmfCC_RpnMsb
; Called from: in-module: 0xF70484 0xF7231A
; Touches: (0x10D0) (0x10D2) (0x11B4) (0x11B6)
; Calls:   SmfCC_UpdateSelectedRpn
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF70CBA is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_RpnMsb: SmfEvent_ControlChange's arm for MIDI controller 101 (`cp a,101 / jr z`).
SmfCC_RpnMsb:
	ld	iy, (Smf_EventStatus:16)	; F70CBA  ld IY,(0x10d0)
	and	iy, 15	; F70CBE  and IY,0x000f
	ld	a, (4306:16)	; F70CC2  ld A,(0x10d2)
	push	xix	; F70CC6  push XIX
	ld	xix, 4536	; F70CC7  ld XIX,0x000011b8
	ld	(xix+iy), a	; F70CCC  ld (XIX+IY),A
	pop	xix	; F70CD1  pop XIX
	cp	a, 127	; F70CD2  cp A,0x7f
	jr	z, SmfCC_RpnMsb_Skip2	; F70CD5  jr Z,0xf70d13
	ld	c, (Smf_EventStatus:16)	; F70CD7  ld C,(0x10d0)
	and	c, 15	; F70CDB  and C,0x0f
	ld	wa, (4532:16)	; F70CDE  ld WA,(0x11b4)
	and	wa, (0x11b6:16)	; F70CE2  and WA,(0x11b6)
	ldfr_werp	wa, 0x3e	; F70CE6  ld QHL3,WA
	ld	a, c	; F70CE9  ld A,C
	scf	; F70CEB  scf
	xorcfw_erp	0x3e	; F70CEC  xorcf A,QHL3
	jr	nc, SmfCC_RpnMsb_Skip	; F70CEF  jr NC,0xf70d09
	ld	de, (4532:16)	; F70CF1  ld DE,(0x11b4)
	ld	a, c	; F70CF5  ld A,C
	scf	; F70CF7  scf
	stcf_a_16	de	; F70CF8  stcf A,DE
	ld	(4532:16), de	; F70CFA  ld (0x11b4),DE
	ld	de, (4534:16)	; F70CFE  ld DE,(0x11b6)
	ld	a, c	; F70D02  ld A,C
	scf	; F70D04  scf
	xorcf_a_16	de	; F70D05  xorcf A,DE
	jr	c, SmfCC_RpnMsb_Return	; F70D07  jr C,0xf70d41
SmfCC_RpnMsb_Skip:
	pushw	bc	; F70D09  push BC
	calr	SmfCC_UpdateSelectedRpn	; F70D0A  calr 0xf70dd6
	popw	bc	; F70D0D  pop BC
	cp	a, 255	; F70D0E  cp A,0xff
	jr	nz, SmfCC_RpnMsb_Return	; F70D11  jr NZ,0xf70d41
SmfCC_RpnMsb_Skip2:
	ld	c, (Smf_EventStatus:16)	; F70D13  ld C,(0x10d0)
	and	c, 15	; F70D17  and C,0x0f
	xor	b, b	; F70D1A  xor B,B
	ld	iy, bc	; F70D1C  ld IY,BC
	push	xix	; F70D1E  push XIX
	ld	xix, 4568	; F70D1F  ld XIX,0x000011d8
	ld	(xix+iy), 0xff	; F70D24  ld (XIX+IY),0xff
	xor	c, c	; F70D2A  xor C,C
	ld	xix, 4632	; F70D2C  ld XIX,0x00001218
	ld	(xix+iy), c	; F70D31  ld (XIX+IY),C
	ld	xix, 4648	; F70D36  ld XIX,0x00001228
	ld	(xix+iy), c	; F70D3B  ld (XIX+IY),C
	pop	xix	; F70D40  pop XIX
SmfCC_RpnMsb_Return:
	ret	; F70D41  ret

; --------------------------------------------------------------------------
; SmfCC_RpnLsb
; Called from: in-module: 0xF70489 0xF7231F
; Touches: (0x10D0) (0x10D2) (0x11B4) (0x11B6)
; Calls:   SmfCC_UpdateSelectedRpn
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF70D42 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_RpnLsb: SmfEvent_ControlChange's arm for MIDI controller 100 (`cp a,100 / jr z`).
SmfCC_RpnLsb:
	ld	iy, (Smf_EventStatus:16)	; F70D42  ld IY,(0x10d0)
	and	iy, 15	; F70D46  and IY,0x000f
	ld	a, (4306:16)	; F70D4A  ld A,(0x10d2)
	push	xix	; F70D4E  push XIX
	ld	xix, 4552	; F70D4F  ld XIX,0x000011c8
	ld	(xix+iy), a	; F70D54  ld (XIX+IY),A
	pop	xix	; F70D59  pop XIX
	cp	a, 127	; F70D5A  cp A,0x7f
	jr	z, SmfCC_RpnLsb_Skip2	; F70D5D  jr Z,0xf70da7
	ld	c, (Smf_EventStatus:16)	; F70D5F  ld C,(0x10d0)
	and	c, 15	; F70D63  and C,0x0f
	ld	wa, (4532:16)	; F70D66  ld WA,(0x11b4)
	and	wa, (0x11b6:16)	; F70D6A  and WA,(0x11b6)
	ldfr_werp	wa, 0x3e	; F70D6E  ld QHL3,WA
	ld	a, c	; F70D71  ld A,C
	scf	; F70D73  scf
	xorcfw_erp	0x3e	; F70D74  xorcf A,QHL3
	jr	nc, SmfCC_RpnLsb_Skip	; F70D77  jr NC,0xf70d9d
	ld	de, (4534:16)	; F70D79  ld DE,(0x11b6)
	ld	a, c	; F70D7D  ld A,C
	scf	; F70D7F  scf
	stcf_a_16	de	; F70D80  stcf A,DE
	ld	(4534:16), de	; F70D82  ld (0x11b6),DE
	ldfr_berp	a, 0x3c	; F70D86  ld RL3,A
	ldfr_werp	de, 0x3e	; F70D89  ld QHL3,DE
	ld	de, (4532:16)	; F70D8C  ld DE,(0x11b4)
	ld	a, c	; F70D90  ld A,C
	scf	; F70D92  scf
	xorcf_a_16	de	; F70D93  xorcf A,DE
	ldto_werp	de, 0x3e	; F70D95  ld DE,QHL3
	ldto_berp	a, 0x3c	; F70D98  ld A,RL3
	jr	c, SmfCC_RpnLsb_Return	; F70D9B  jr C,0xf70dd5
SmfCC_RpnLsb_Skip:
	pushw	bc	; F70D9D  push BC
	calr	SmfCC_UpdateSelectedRpn	; F70D9E  calr 0xf70dd6
	popw	bc	; F70DA1  pop BC
	cp	a, 255	; F70DA2  cp A,0xff
	jr	nz, SmfCC_RpnLsb_Return	; F70DA5  jr NZ,0xf70dd5
SmfCC_RpnLsb_Skip2:
	ld	c, (Smf_EventStatus:16)	; F70DA7  ld C,(0x10d0)
	and	c, 15	; F70DAB  and C,0x0f
	xor	b, b	; F70DAE  xor B,B
	ld	iy, bc	; F70DB0  ld IY,BC
	push	xix	; F70DB2  push XIX
	ld	xix, 4568	; F70DB3  ld XIX,0x000011d8
	ld	(xix+iy), 0xff	; F70DB8  ld (XIX+IY),0xff
	xor	c, c	; F70DBE  xor C,C
	ld	xix, 4632	; F70DC0  ld XIX,0x00001218
	ld	(xix+iy), c	; F70DC5  ld (XIX+IY),C
	ld	xix, 4648	; F70DCA  ld XIX,0x00001228
	ld	(xix+iy), c	; F70DCF  ld (XIX+IY),C
	pop	xix	; F70DD4  pop XIX
SmfCC_RpnLsb_Return:
	ret	; F70DD5  ret

; --------------------------------------------------------------------------
; SmfCC_UpdateSelectedRpn
; Called from: in-module: 0xF70D0A 0xF70D9E
; Touches: (0x10D0)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF70DD6 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_UpdateSelectedRpn: For the event's channel (Smf_EventStatus & 15): selected RPN (0x11D8)[ch] := the RPN LSB
;   (0x11C8)[ch] when the RPN MSB (0x11B8)[ch] is 0 and the LSB is 0..2, else 0xFF (none); returns it in A. The common
;   tail of SmfCC_RpnMsb (CC 101) and SmfCC_RpnLsb (CC 100); SmfCC_PutSelectedRpnValueEvent consumes (0x11D8). Basis:
;   callers + body. (notes/naming-pilot-2026-10-06/proposals_wave3_g.json)
SmfCC_UpdateSelectedRpn:
	ld	iy, (Smf_EventStatus:16)	; F70DD6  ld IY,(0x10d0)
	and	iy, 15	; F70DDA  and IY,0x000f
	push	xix	; F70DDE  push XIX
	ld	xix, 4536	; F70DDF  ld XIX,0x000011b8
	ld	a, (xix+iy)	; F70DE4  ld A,(XIX+IY)
	ld	xix, 4552	; F70DE9  ld XIX,0x000011c8
	ld	w, (xix+iy)	; F70DEE  ld W,(XIX+IY)
	pop	xix	; F70DF3  pop XIX
	cp	a, 0:i3	; F70DF4  cp A,0
	jr	nz, SmfCC_UpdateSelectedRpn_Skip	; F70DF6  jr NZ,0xf70e0e
	cp	w, 0:i3	; F70DF8  cp W,0
	jr	c, SmfCC_UpdateSelectedRpn_Skip	; F70DFA  jr C,0xf70e0e
	cp	w, 2:i3	; F70DFC  cp W,2
	jr	ugt, SmfCC_UpdateSelectedRpn_Skip	; F70DFE  jr UGT,0xf70e0e
	push	xix	; F70E00  push XIX
	ld	xix, 4568	; F70E01  ld XIX,0x000011d8
	ld	(xix+iy), w	; F70E06  ld (XIX+IY),W
	pop	xix	; F70E0B  pop XIX
	jr	SmfCC_UpdateSelectedRpn_Return	; F70E0C  jr T,0xf70e1c
SmfCC_UpdateSelectedRpn_Skip:
	ld	a, 255:opc	; F70E0E  ld A,0xff
	push	xix	; F70E10  push XIX
	ld	xix, 4568	; F70E11  ld XIX,0x000011d8
	ld	(xix+iy), a	; F70E16  ld (XIX+IY),A
	pop	xix	; F70E1B  pop XIX
SmfCC_UpdateSelectedRpn_Return:
	ret	; F70E1C  ret

; --------------------------------------------------------------------------
; SmfCC_PutParamEvent
; Called from: in-module: 0xF7067B 0xF7099F 0xF709D6 0xF70A2C
; Touches: (0x10D0) (0x11AE) (0x11AF) (0x11B0) (0x1238) (0x1239)
; Calls:   TrackCursor_Load BStore_PutByteAndAdvance Smf_TicksToPpq96 SmfEvent_MarkChannelUsed TrackCursor_Save
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF70E1D is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_PutParamEvent: Appends a 0xB0 parameter event to the SMF event's channel track: 0xB0 (|2 if (0x11B0) b7, |1 if
;   (0x11AF) b7 too), the delta via Smf_TicksToPpq96, the channel, class (0x11AE), (0x11AF)&0x7F, (0x11B0)&0x7F; stops
;   when (0x1238) flags a store failure. The volume / effect-depth CC handlers set class 3/5/6/7 first. Basis: callers
;   + body. (notes/naming-pilot-2026-10-06/proposals_wave2_e.json)
SmfCC_PutParamEvent:
	ld	iy, (Smf_EventStatus:16)	; F70E1D  ld IY,(0x10d0)
	and	iy, 15	; F70E21  and IY,0x000f
	extz	xiy	; F70E25  extz XIY
	push	xiy	; F70E27  push XIY
	calr	TrackCursor_Load	; F70E28  calr 0xf7124e
	ld	a, 176:opc	; F70E2B  ld A,0xb0
	bit	7, (0x11b0:16)	; F70E2D  bit 7,(0x11b0)
	jr	z, SmfCC_PutParamEvent_Skip	; F70E31  jr Z,0xf70e3f
	or	a, 2	; F70E33  or A,0x02
	bit	7, (0x11af:16)	; F70E36  bit 7,(0x11af)
	jr	z, SmfCC_PutParamEvent_Skip	; F70E3A  jr Z,0xf70e3f
	or	a, 1	; F70E3C  or A,0x01
SmfCC_PutParamEvent_Skip:
	calr	BStore_PutByteAndAdvance	; F70E3F  calr 0xf70fda
	pop	xiy	; F70E42  pop XIY
	cp	(0x1238:16), 0x00	; F70E43  cp (0x1238),0x00
	jrl	nz, SmfCC_PutParamEvent_Return	; F70E48  jrl NZ,0xf70ed4
	sla	xiy, 1	; F70E4B  sla 0x01,XIY
	push	xix	; F70E4E  push XIX
	ld	xix, 4307	; F70E4F  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F70E54  ld WA,(XIX+IY)
	pop	xix	; F70E59  pop XIX
	srl	xiy, 1	; F70E5A  srl 0x01,XIY
	push	xiy	; F70E5D  push XIY
	calr	Smf_TicksToPpq96	; F70E5E  calr 0xf7122f
	pop	xiy	; F70E61  pop XIY
	push	xiy	; F70E62  push XIY
	calr	BStore_PutByteAndAdvance	; F70E63  calr 0xf70fda
	pop	xiy	; F70E66  pop XIY
	cp	(0x1238:16), 0x00	; F70E67  cp (0x1238),0x00
	jrl	nz, SmfCC_PutParamEvent_Return	; F70E6C  jrl NZ,0xf70ed4
	push	xix	; F70E6F  push XIX
	ld	xix, ByteMap_F70298	; F70E70  ld XIX,0x00f70298
	cp	(0x1239:16), 0x00	; F70E75  cp (0x1239),0x00
	jr	z, SmfCC_PutParamEvent_Skip2	; F70E7A  jr Z,0xf70e81
	ld	xix, ByteMap_F70298 + 0x10	; F70E7C  ld XIX,0x00f702a8
SmfCC_PutParamEvent_Skip2:
	ld	a, (xix+iy)	; F70E81  ld A,(XIX+IY)
	pop	xix	; F70E86  pop XIX
	push	xiy	; F70E87  push XIY
	calr	BStore_PutByteAndAdvance	; F70E88  calr 0xf70fda
	pop	xiy	; F70E8B  pop XIY
	cp	(0x1238:16), 0x00	; F70E8C  cp (0x1238),0x00
	jr	nz, SmfCC_PutParamEvent_Return	; F70E91  jr NZ,0xf70ed4
	ld	a, (4526:16)	; F70E93  ld A,(0x11ae)
	push	xiy	; F70E97  push XIY
	calr	BStore_PutByteAndAdvance	; F70E98  calr 0xf70fda
	pop	xiy	; F70E9B  pop XIY
	cp	(0x1238:16), 0x00	; F70E9C  cp (0x1238),0x00
	jr	nz, SmfCC_PutParamEvent_Return	; F70EA1  jr NZ,0xf70ed4
	ld	a, (4527:16)	; F70EA3  ld A,(0x11af)
	and	a, 127	; F70EA7  and A,0x7f
	push	xiy	; F70EAA  push XIY
	calr	BStore_PutByteAndAdvance	; F70EAB  calr 0xf70fda
	pop	xiy	; F70EAE  pop XIY
	cp	(0x1238:16), 0x00	; F70EAF  cp (0x1238),0x00
	jr	nz, SmfCC_PutParamEvent_Return	; F70EB4  jr NZ,0xf70ed4
	ld	a, (4528:16)	; F70EB6  ld A,(0x11b0)
	and	a, 127	; F70EBA  and A,0x7f
	push	xiy	; F70EBD  push XIY
	calr	BStore_PutByteAndAdvance	; F70EBE  calr 0xf70fda
	pop	xiy	; F70EC1  pop XIY
	cp	(0x1238:16), 0x00	; F70EC2  cp (0x1238),0x00
	jr	nz, SmfCC_PutParamEvent_Return	; F70EC7  jr NZ,0xf70ed4
	calr	SmfEvent_MarkChannelUsed	; F70EC9  calr 0xf7129a
	calr	TrackCursor_Save	; F70ECC  calr 0xf71275
	ld	(4664:16), 0	; F70ECF  ld (0x1238),0x00
SmfCC_PutParamEvent_Return:
	ret	; F70ED4  ret

; --------------------------------------------------------------------------
; SmfEvent_NoteOn
; Called from: in-module: 0xF6FF96
; Touches: (0x10D0) (0x10D1) (0x10D2) (0x11B1) (0x1238) (0x1239) (0x124B)
;          (0x2732) (0x345C) (0x345E)
; Calls:   SmfPart_ResetAllRecords TrackCursor_Load BStore_PutByteAndAdvance Smf_TicksToPpq96 SmfEvent_MarkChannelUsed TrackCursor_Save
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF70ED5 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_NoteOn: SmfEvent_DispatchChannelMessage's arm for status 0x9n with a non-zero velocity.
SmfEvent_NoteOn:
	ld	xiy, 12378	; F70ED5  ld XIY,0x0000305a
SmfEvent_NoteOn_Loop:
	bit	7, (xiy)	; F70EDA  bit 7,(XIY)
	jr	nz, SmfEvent_NoteOn_Skip	; F70EDC  jr NZ,0xf70ee2
	ld	xix, xiy	; F70EDE  ld XIX,XIY
	jr	SmfEvent_NoteOn_Join	; F70EE0  jr T,0xf70ef8
SmfEvent_NoteOn_Skip:
	add	xiy, 7	; F70EE2  add XIY,0x00000007
	cp	xiy, 12602	; F70EE8  cp XIY,0x0000313a
	jr	ule, SmfEvent_NoteOn_Loop	; F70EEE  jr ULE,0xf70eda
	ld	(4664:16), 0	; F70EF0  ld (0x1238),0x00
	jrl	SmfEvent_NoteOn_Return	; F70EF5  jrl T,0xf70fd9
SmfEvent_NoteOn_Join:
	or	(0x11b1:16), 0x01	; F70EF8  or (0x11b1),0x01
	bit	0, (0x124b:16)	; F70EFD  bit 0,(0x124b)
	jr	nz, SmfEvent_NoteOn_Skip3	; F70F01  jr NZ,0xf70f1c
	ld	(4665:16), 255	; F70F03  ld (0x1239),0xff
	cp	(0x2732:16), 0x00	; F70F08  cp (0x2732),0x00
	jr	nz, SmfEvent_NoteOn_Skip2	; F70F0D  jr NZ,0xf70f14
	ld	(4665:16), 0	; F70F0F  ld (0x1239),0x00
SmfEvent_NoteOn_Skip2:
	ld	(4683:16), 1	; F70F14  ld (0x124b),0x01
	calr	SmfPart_ResetAllRecords	; F70F19  calr 0xf71417
SmfEvent_NoteOn_Skip3:
	ld	iy, (Smf_EventStatus:16)	; F70F1C  ld IY,(0x10d0)
	and	iy, 15	; F70F20  and IY,0x000f
	extz	xiy	; F70F24  extz XIY
	push	xiy	; F70F26  push XIY
	push	xix	; F70F27  push XIX
	calr	TrackCursor_Load	; F70F28  calr 0xf7124e
	pop	xix	; F70F2B  pop XIX
	ld	a, 144:opc	; F70F2C  ld A,0x90
	push	xix	; F70F2E  push XIX
	calr	BStore_PutByteAndAdvance	; F70F2F  calr 0xf70fda
	pop	xix	; F70F32  pop XIX
	pop	xiy	; F70F33  pop XIY
	cp	(0x1238:16), 0x00	; F70F34  cp (0x1238),0x00
	jrl	nz, SmfEvent_NoteOn_Return	; F70F39  jrl NZ,0xf70fd9
	sla	xiy, 1	; F70F3C  sla 0x01,XIY
	push	xix	; F70F3F  push XIX
	ld	xix, 4307	; F70F40  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F70F45  ld WA,(XIX+IY)
	pop	xix	; F70F4A  pop XIX
	srl	xiy, 1	; F70F4B  srl 0x01,XIY
	push	xiy	; F70F4E  push XIY
	calr	Smf_TicksToPpq96	; F70F4F  calr 0xf7122f
	pop	xiy	; F70F52  pop XIY
	push	xiy	; F70F53  push XIY
	push	xix	; F70F54  push XIX
	calr	BStore_PutByteAndAdvance	; F70F55  calr 0xf70fda
	pop	xix	; F70F58  pop XIX
	pop	xiy	; F70F59  pop XIY
	cp	(0x1238:16), 0x00	; F70F5A  cp (0x1238),0x00
	jrl	nz, SmfEvent_NoteOn_Return	; F70F5F  jrl NZ,0xf70fd9
	ld	a, (4305:16)	; F70F62  ld A,(0x10d1)
	push	xiy	; F70F66  push XIY
	push	xix	; F70F67  push XIX
	calr	BStore_PutByteAndAdvance	; F70F68  calr 0xf70fda
	pop	xix	; F70F6B  pop XIX
	pop	xiy	; F70F6C  pop XIY
	cp	(0x1238:16), 0x00	; F70F6D  cp (0x1238),0x00
	jr	nz, SmfEvent_NoteOn_Return	; F70F72  jr NZ,0xf70fd9
	ld	a, (4306:16)	; F70F74  ld A,(0x10d2)
	push	xiy	; F70F78  push XIY
	push	xix	; F70F79  push XIX
	calr	BStore_PutByteAndAdvance	; F70F7A  calr 0xf70fda
	pop	xix	; F70F7D  pop XIX
	pop	xiy	; F70F7E  pop XIY
	cp	(0x1238:16), 0x00	; F70F7F  cp (0x1238),0x00
	jr	nz, SmfEvent_NoteOn_Return	; F70F84  jr NZ,0xf70fd9
	ld	a, (BStore_CursorOffset:16)	; F70F86  ld A,(0x345e)
	ld	(xix+2), a	; F70F8A  ld (XIX+0x02),A
	ld	wa, (BStore_CursorBlock:16)	; F70F8D  ld WA,(0x345c)
	ld	(xix+3), wa	; F70F91  ld (XIX+0x03),WA
	xor	a, a	; F70F94  xor A,A
	push	xiy	; F70F96  push XIY
	push	xix	; F70F97  push XIX
	calr	BStore_PutByteAndAdvance	; F70F98  calr 0xf70fda
	pop	xix	; F70F9B  pop XIX
	pop	xiy	; F70F9C  pop XIY
	cp	(0x1238:16), 0x00	; F70F9D  cp (0x1238),0x00
	jr	nz, SmfEvent_NoteOn_Return	; F70FA2  jr NZ,0xf70fd9
	xor	a, a	; F70FA4  xor A,A
	push	xiy	; F70FA6  push XIY
	push	xix	; F70FA7  push XIX
	calr	BStore_PutByteAndAdvance	; F70FA8  calr 0xf70fda
	pop	xix	; F70FAB  pop XIX
	pop	xiy	; F70FAC  pop XIY
	cp	(0x1238:16), 0x00	; F70FAD  cp (0x1238),0x00
	jr	nz, SmfEvent_NoteOn_Return	; F70FB2  jr NZ,0xf70fd9
	calr	SmfEvent_MarkChannelUsed	; F70FB4  calr 0xf7129a
	push	xix	; F70FB7  push XIX
	calr	TrackCursor_Save	; F70FB8  calr 0xf71275
	pop	xix	; F70FBB  pop XIX
	ld	a, (Smf_EventStatus:16)	; F70FBC  ld A,(0x10d0)
	and	a, 15	; F70FC0  and A,0x0f
	or	a, 128	; F70FC3  or A,0x80
	ld	(xix), a	; F70FC6  ld (XIX),A
	ld	a, (4305:16)	; F70FC8  ld A,(0x10d1)
	ld	(xix+1), a	; F70FCC  ld (XIX+0x01),A
	xor	wa, wa	; F70FCF  xor WA,WA
	ld	(xix+5), wa	; F70FD1  ld (XIX+0x05),WA
	ld	(4664:16), 0	; F70FD4  ld (0x1238),0x00
SmfEvent_NoteOn_Return:
	ret	; F70FD9  ret

; --------------------------------------------------------------------------
; BStore_PutByteAndAdvance
; Called from: in-module: 0xF6FA8F 0xF6FCC0 0xF6FD03 0xF6FD13 0xF6FD22
;              0xF6FFBE 0xF6FFE1 0xF6FFF1 +99 more
; Touches: nothing with an absolute address
; Calls:   BStore_PutByteAtCursor BStore_AdvanceCursorForWrite
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF70FDA is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_PutByteAndAdvance: BStore_PutByteAtCursor then BStore_AdvanceCursorForWrite (107 call sites).
BStore_PutByteAndAdvance:
	calr	BStore_PutByteAtCursor	; F70FDA  calr 0xf70fe1
	calr	BStore_AdvanceCursorForWrite	; F70FDD  calr 0xf70ff8
	ret	; F70FE0  ret

; --------------------------------------------------------------------------
; BStore_PutByteAtCursor
; Called from: in-module: 0xF6FAD8 0xF70FDA 0xF728CD
; Touches: (0x126E) (0x345C) (0x345E)
; Calls:   SongStore_SeekBlock_Copy
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF70FE1 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_PutByteAtCursor: A to the block-store cursor: SongStore_SeekBlock_Copy(BStore_CursorBlock), then (BStore_CursorBlockAddr + BStore_CursorOffset) = A.
BStore_PutByteAtCursor:
	push	xhl	; F70FE1  push XHL
	ld	hl, (BStore_CursorBlock:16)	; F70FE2  ld HL,(0x345c)
	calr	SongStore_SeekBlock_Copy	; F70FE6  calr 0xf72f0a
	ld	xhl, (BStore_CursorBlockAddr:16)	; F70FE9  ld XHL,(0x126e)
	ld	iy, (BStore_CursorOffset:16)	; F70FED  ld IY,(0x345e)
	ld	(xhl+iy), a	; F70FF1  ld (XHL+IY),A
	pop	xhl	; F70FF6  pop XHL
	ret	; F70FF7  ret

; --------------------------------------------------------------------------
; BStore_AdvanceCursorForWrite
; Called from: in-module: 0xF70FDD
; Touches: (0x1238) (0x345E)
; Calls:   BStore_ExtendChainAtCursor
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF70FF8 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_AdvanceCursorForWrite: BStore_CursorOffset + 1; at offset 255: no free block (BStore_FreeCount 0) -> (0x1238) = 0xFF, else
;   BStore_ExtendChainAtCursor; (0x1238) = 0 on success.
BStore_AdvanceCursorForWrite:
	ld	wa, (BStore_CursorOffset:16)	; F70FF8  ld WA,(0x345e)
	cp	wa, 255	; F70FFC  cp WA,0x00ff
	jr	nz, BStore_AdvanceCursorForWrite_Skip2	; F71000  jr NZ,0xf71017
	cpw	(BStore_FreeCount:24), 0x0000	; F71002  cp (0x6034ba),0x0000
	jr	nz, BStore_AdvanceCursorForWrite_Skip	; F71009  jr NZ,0xf71012
	ld	(4664:16), 255	; F7100B  ld (0x1238),0xff
	jr	BStore_AdvanceCursorForWrite_Return	; F71010  jr T,0xf71022
BStore_AdvanceCursorForWrite_Skip:
	calr	BStore_ExtendChainAtCursor	; F71012  calr 0xf713e1
	jr	BStore_AdvanceCursorForWrite_Join	; F71015  jr T,0xf7101d
BStore_AdvanceCursorForWrite_Skip2:
	inc	1, wa	; F71017  inc 1,WA
	ld	(BStore_CursorOffset:16), wa	; F71019  ld (0x345e),WA
BStore_AdvanceCursorForWrite_Join:
	ld	(4664:16), 0	; F7101D  ld (0x1238),0x00
BStore_AdvanceCursorForWrite_Return:
	ret	; F71022  ret

; --------------------------------------------------------------------------
; SmfEvent_NoteOff
; Called from: in-module: 0xF6FF9B
; Touches: (0x10D0) (0x10D1) (0x126E) (0x345C) (0x345E)
; Calls:   SongStore_SeekBlock_Copy Smf_StepCursorOneByte
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF71023 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_NoteOff: the arm for status 0x8n, and for 0x9n with velocity 0.
SmfEvent_NoteOff:
	ld	xiy, 12378	; F71023  ld XIY,0x0000305a
SmfEvent_NoteOff_Loop:
	bit	7, (xiy)	; F71028  bit 7,(XIY)
	jrl	z, SmfEvent_NoteOff_Skip2	; F7102A  jrl Z,0xf710aa
	ld	a, (xiy)	; F7102D  ld A,(XIY)
	and	a, 15	; F7102F  and A,0x0f
	ld	l, (Smf_EventStatus:16)	; F71032  ld L,(0x10d0)
	and	l, 15	; F71036  and L,0x0f
	cp	a, l	; F71039  cp A,L
	jr	nz, SmfEvent_NoteOff_Skip2	; F7103B  jr NZ,0xf710aa
	ld	l, (4305:16)	; F7103D  ld L,(0x10d1)
	cp	(xiy+1), l	; F71041  cp (XIY+0x01),L
	jr	nz, SmfEvent_NoteOff_Skip2	; F71044  jr NZ,0xf710aa
	and	(xiy), 0x7f	; F71046  and (XIY),0x7f
	ld	ix, (xiy+2)	; F71049  ld IX,(XIY+0x02)
	ld	hl, (xiy+3)	; F7104C  ld HL,(XIY+0x03)
	and	xix, 255	; F7104F  and XIX,0x000000ff
	push	xhl	; F71055  push XHL
	push	xiy	; F71056  push XIY
	calr	SongStore_SeekBlock_Copy	; F71057  calr 0xf72f0a
	pop	xiy	; F7105A  pop XIY
	ld	wa, (xiy+5)	; F7105B  ld WA,(XIY+0x05)
	ld	l, 96:opc	; F7105E  ld L,0x60
	divs	wa, l	; F71060  divs WA,L
	cp	a, 0:i3	; F71062  cp A,0
	jr	nz, SmfEvent_NoteOff_Skip	; F71064  jr NZ,0xf7106c
	cp	w, 4:i3	; F71066  cp W,4
	jr	ugt, SmfEvent_NoteOff_Skip	; F71068  jr UGT,0xf7106c
	ld	w, 5:opc	; F7106A  ld W,0x05
SmfEvent_NoteOff_Skip:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7106C  ld XHL,(0x126e)
	ld	(xhl+ix), w	; F71070  ld (XHL+IX),W
	pop	xhl	; F71075  pop XHL
	pushw	(BStore_CursorBlock:16)	; F71076  pushw (0x345c)
	pushw	(BStore_CursorOffset:16)	; F7107A  pushw (0x345e)
	ld	(BStore_CursorBlock:16), hl	; F7107E  ld (0x345c),HL
	ld	(BStore_CursorOffset:16), ix	; F71082  ld (0x345e),IX
	pushw	wa	; F71086  push WA
	calr	Smf_StepCursorOneByte	; F71087  calr 0xf710ba
	popw	wa	; F7108A  pop WA
	push	xix	; F7108B  push XIX
	push	xiy	; F7108C  push XIY
	ld	xix, (BStore_CursorBlockAddr:16)	; F7108D  ld XIX,(0x126e)
	ld	iy, (BStore_CursorOffset:16)	; F71091  ld IY,(0x345e)
	and	iy, 255	; F71095  and IY,0x00ff
	ld	(xix+iy), a	; F71099  ld (XIX+IY),A
	pop	xiy	; F7109E  pop XIY
	pop	xix	; F7109F  pop XIX
	popw	(BStore_CursorOffset:16)	; F710A0  popw (0x345e)
	popw	(BStore_CursorBlock:16)	; F710A4  popw (0x345c)
	jr	SmfEvent_NoteOff_Return	; F710A8  jr T,0xf710b9
SmfEvent_NoteOff_Skip2:
	add	xiy, 7	; F710AA  add XIY,0x00000007
	cp	xiy, 12602	; F710B0  cp XIY,0x0000313a
	jrl	ule, SmfEvent_NoteOff_Loop	; F710B6  jrl ULE,0xf71028
SmfEvent_NoteOff_Return:
	ret	; F710B9  ret

; --------------------------------------------------------------------------
; Smf_StepCursorOneByte
; Called from: in-module: 0xF71087 0xF72204
; Touches: (0x126E) (0x345C) (0x345E)
; Calls:   SongStore_SeekBlock_Copy
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF710BA is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_StepCursorOneByte: Steps the saved cursor (BStore_CursorBlock, BStore_CursorOffset) one byte: offset + 1, or at
;   offset 255 the block's +3 link with offset 5 (seeking (0x126E) to it). Both SMF note-off arms use it to reach the
;   second duration byte of the pending note-on, which may sit in the next block. Basis: callers + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave3_h.json)
Smf_StepCursorOneByte:
	ld	wa, (BStore_CursorOffset:16)	; F710BA  ld WA,(0x345e)
	cp	wa, 255	; F710BE  cp WA,0x00ff
	jr	nz, Smf_StepCursorOneByte_Skip	; F710C2  jr NZ,0xf710e0
	ld	hl, (BStore_CursorBlock:16)	; F710C4  ld HL,(0x345c)
	calr	SongStore_SeekBlock_Copy	; F710C8  calr 0xf72f0a
	ld	xhl, (BStore_CursorBlockAddr:16)	; F710CB  ld XHL,(0x126e)
	ld	wa, (xhl+3)	; F710CF  ld WA,(XHL+0x03)
	ld	(BStore_CursorBlock:16), wa	; F710D2  ld (0x345c),WA
	ld	hl, wa	; F710D6  ld HL,WA
	calr	SongStore_SeekBlock_Copy	; F710D8  calr 0xf72f0a
	ldw	wa, 5	; F710DB  ld WA,0x0005
	jr	Smf_StepCursorOneByte_Join	; F710DE  jr T,0xf710e2
Smf_StepCursorOneByte_Skip:
	inc	1, wa	; F710E0  inc 1,WA
Smf_StepCursorOneByte_Join:
	ld	(BStore_CursorOffset:16), wa	; F710E2  ld (0x345e),WA
	ret	; F710E6  ret

; --------------------------------------------------------------------------
; Smf_ApplyDeltaTime
; Called from: in-module: 0xF6F6D4 0xF71C91
; Touches: (0x107C) (0x1086) (0x1198) (0x119A)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF710E7 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_ApplyDeltaTime: SMF import, after an event's delta time is decoded: adds Smf_VlqValue to slot IY's tick-within-
;   beat counter (0x10D3)[IY]; every whole Smf_Division (one quarter note) crossed is counted in (0x1086) and written
;   into the track as 0x81 beat markers (Smf_PutBeatMarks); the remainder stays in (0x10D3)[IY], which the event writers
;   scale to 96 ppq as the event's tick. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave3_i.json)
Smf_ApplyDeltaTime:
	ldw	(4230:16), 0	; F710E7  ld (0x1086),0x0000
	sla	iy, 1	; F710ED  sla 0x01,IY
	push	xix	; F710F0  push XIX
	ld	xix, 4307	; F710F1  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F710F6  ld WA,(XIX+IY)
	pop	xix	; F710FB  pop XIX
	srl	iy, 1	; F710FC  srl 0x01,IY
	ld	bc, (Smf_VlqValue:16)	; F710FF  ld BC,(0x1198)
	ld	e, (4506:16)	; F71103  ld E,(0x119a)
	xor	d, d	; F71107  xor D,D
	cp	de, 0:i3	; F71109  cp DE,0
	jrl	z, Smf_ApplyDeltaTime_Skip4	; F7110B  jrl Z,0xf711a1
	pushw	wa	; F7110E  push WA
	xor	wa, wa	; F7110F  xor WA,WA
	ld	hl, (Smf_Division:16)	; F71111  ld HL,(0x107c)
	ld	qwa, de	; F71115  ld QWA,DE
	div	xwa, hl	; F71118  div XWA,HL
	ld	de, qwa	; F7111A  ld DE,QWA
	add	(0x1086:16), wa	; F7111D  add (0x1086),WA
	popw	wa	; F71121  pop WA
	add	de, bc	; F71122  add DE,BC
	jr	nov, Smf_ApplyDeltaTime_Skip	; F71124  jr PO/NOV,0xf7113d

; --------------------------------------------------------------------------
; REACHED CODE, not data (was `Data_F71126`), part of Smf_ApplyDeltaTime:
;   the overflow arm of `jr nov` at 0xF71124: `push WA / ld WA,DE / ld DE,1 / ld HL,(0x107C) /
;   ld QWA,DE / div XWA,HL / ld DE,QWA / add (0x1086),WA / pop WA` -- the same
;   divide-and-accumulate the routine runs just above it.
; --------------------------------------------------------------------------
	pushw	wa	; F71126  push WA
	ld	wa, de	; F71127  ld WA,DE
	ldw	de, 1	; F71129  ld DE,0x0001
	ld	hl, (Smf_Division:16)	; F7112C  ld HL,(0x107c)
	ld	qwa, de	; F71130  ld QWA,DE
	div	xwa, hl	; F71133  div XWA,HL
	ld	de, qwa	; F71135  ld DE,QWA
	add	(4230:16), wa	; F71138  add (0x1086),WA
	popw	wa	; F7113C  pop WA

Smf_ApplyDeltaTime_Skip:
	add	wa, de	; F7113D  add WA,DE
	jr	nov, Smf_ApplyDeltaTime_Skip2	; F7113F  jr PO/NOV,0xf7116e
	ldw	de, 1	; F71141  ld DE,0x0001
	ld	qwa, de	; F71144  ld QWA,DE
	div	xwa, hl	; F71147  div XWA,HL
	ld	de, qwa	; F71149  ld DE,QWA
	add	(0x1086:16), wa	; F7114C  add (0x1086),WA
	pushw	wa	; F71150  push WA
	pushw	de	; F71151  push DE
	push	xiy	; F71152  push XIY
	calr	Smf_PutBeatMarks	; F71153  calr 0xf71203
	pop	xiy	; F71156  pop XIY
	popw	de	; F71157  pop DE
	popw	wa	; F71158  pop WA
	sla	xiy, 1	; F71159  sla 0x01,XIY
	push	xix	; F7115C  push XIX
	ld	xix, 4307	; F7115D  ld XIX,0x000010d3
	ld	(xix+iy), de	; F71162  ld (XIX+IY),DE
	pop	xix	; F71167  pop XIX
	srl	xiy, 1	; F71168  srl 0x01,XIY
	jrl	Smf_ApplyDeltaTime_Return	; F7116B  jrl T,0xf71202
Smf_ApplyDeltaTime_Skip2:
	cp	wa, (Smf_Division:16)	; F7116E  cp WA,(0x107c)
	jr	c, Smf_ApplyDeltaTime_Skip3	; F71172  jr C,0xf71184
	xor	de, de	; F71174  xor DE,DE
	ld	qwa, de	; F71176  ld QWA,DE
	div	xwa, hl	; F71179  div XWA,HL
	ld	de, qwa	; F7117B  ld DE,QWA
	add	(0x1086:16), wa	; F7117E  add (0x1086),WA
	ld	wa, de	; F71182  ld WA,DE
Smf_ApplyDeltaTime_Skip3:
	pushw	wa	; F71184  push WA
	pushw	de	; F71185  push DE
	push	xiy	; F71186  push XIY
	calr	Smf_PutBeatMarks	; F71187  calr 0xf71203
	pop	xiy	; F7118A  pop XIY
	popw	de	; F7118B  pop DE
	popw	wa	; F7118C  pop WA
	sla	xiy, 1	; F7118D  sla 0x01,XIY
	push	xix	; F71190  push XIX
	ld	xix, 4307	; F71191  ld XIX,0x000010d3
	ld	(xix+iy), wa	; F71196  ld (XIX+IY),WA
	pop	xix	; F7119B  pop XIX
	srl	xiy, 1	; F7119C  srl 0x01,XIY
	jr	Smf_ApplyDeltaTime_Return	; F7119F  jr T,0xf71202
Smf_ApplyDeltaTime_Skip4:
	add	wa, bc	; F711A1  add WA,BC
	jr	nov, Smf_ApplyDeltaTime_Skip5	; F711A3  jr PO/NOV,0xf711cf
	ldw	de, 1	; F711A5  ld DE,0x0001
	ld	hl, (Smf_Division:16)	; F711A8  ld HL,(0x107c)
	ld	qwa, de	; F711AC  ld QWA,DE
	div	xwa, hl	; F711AF  div XWA,HL
	ld	de, qwa	; F711B1  ld DE,QWA
	add	(0x1086:16), wa	; F711B4  add (0x1086),WA
	pushw	wa	; F711B8  push WA
	pushw	de	; F711B9  push DE
	push	xiy	; F711BA  push XIY
	calr	Smf_PutBeatMarks	; F711BB  calr 0xf71203
	pop	xiy	; F711BE  pop XIY
	popw	de	; F711BF  pop DE
	popw	wa	; F711C0  pop WA
	push	xix	; F711C1  push XIX
	ld	xix, 4307	; F711C2  ld XIX,0x000010d3
	ld	(xix+iy), de	; F711C7  ld (XIX+IY),DE
	pop	xix	; F711CC  pop XIX
	jr	Smf_ApplyDeltaTime_Return	; F711CD  jr T,0xf71202
Smf_ApplyDeltaTime_Skip5:
	ld	hl, (Smf_Division:16)	; F711CF  ld HL,(0x107c)
	cp	wa, hl	; F711D3  cp WA,HL
	jr	c, Smf_ApplyDeltaTime_Skip6	; F711D5  jr C,0xf711f0
	xor	de, de	; F711D7  xor DE,DE
	ld	qwa, de	; F711D9  ld QWA,DE
	div	xwa, hl	; F711DC  div XWA,HL
	ld	de, qwa	; F711DE  ld DE,QWA
	add	(0x1086:16), wa	; F711E1  add (0x1086),WA
	pushw	wa	; F711E5  push WA
	pushw	de	; F711E6  push DE
	push	xiy	; F711E7  push XIY
	calr	Smf_PutBeatMarks	; F711E8  calr 0xf71203
	pop	xiy	; F711EB  pop XIY
	popw	de	; F711EC  pop DE
	popw	wa	; F711ED  pop WA
	ld	wa, de	; F711EE  ld WA,DE
Smf_ApplyDeltaTime_Skip6:
	sla	iy, 1	; F711F0  sla 0x01,IY
	push	xix	; F711F3  push XIX
	ld	xix, 4307	; F711F4  ld XIX,0x000010d3
	ld	(xix+iy), wa	; F711F9  ld (XIX+IY),WA
	pop	xix	; F711FE  pop XIX
	srl	iy, 1	; F711FF  srl 0x01,IY
Smf_ApplyDeltaTime_Return:
	ret	; F71202  ret

; --------------------------------------------------------------------------
; Smf_PutBeatMarks
; Called from: in-module: 0xF71153 0xF71187 0xF711BB 0xF711E8
; Touches: (0x1086) (0x11B1) (0x1238)
; Calls:   TrackCursor_Load BStore_PutByteAndAdvance TrackCursor_Save
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF71203 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_PutBeatMarks: Writes (0x1086) 0x81 beat marks at track IY's cursor (TrackCursor_Load .. TrackCursor_Save),
;   stopping if a byte store fails ((0x1238)); then (0x11B1) |= 1 and (0x1238) := 0. Smf_ApplyDeltaTime calls it (4
;   sites) with (0x1086) = the whole quarter notes the event's delta crossed. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_v.json)
Smf_PutBeatMarks:
	push	xiy	; F71203  push XIY
	calr	TrackCursor_Load	; F71204  calr 0xf7124e
	pop	xiy	; F71207  pop XIY
	ld	bc, (4230:16)	; F71208  ld BC,(0x1086)
	ld	a, 129:opc	; F7120C  ld A,0x81
	ld	a, 129:opc	; F7120E  ld A,0x81
	pushw	bc	; F71210  push BC
	push	xiy	; F71211  push XIY
	calr	BStore_PutByteAndAdvance	; F71212  calr 0xf70fda
	pop	xiy	; F71215  pop XIY
	popw	bc	; F71216  pop BC
	cp	(0x1238:16), 0x00	; F71217  cp (0x1238),0x00
	jr	nz, Smf_PutBeatMarks_Return	; F7121C  jr NZ,0xf7122e
	djnz16	bc, -19	; F7121E  djnz BC,0xf7120e
	calr	TrackCursor_Save	; F71221  calr 0xf71275
	or	(0x11b1:16), 0x01	; F71224  or (0x11b1),0x01
	ld	(4664:16), 0	; F71229  ld (0x1238),0x00
Smf_PutBeatMarks_Return:
	ret	; F7122E  ret

; --------------------------------------------------------------------------
; Smf_TicksToPpq96
; Called from: in-module: 0xF6FCFC 0xF6FFDC 0xF700C7 0xF70166 0xF7035E
;              0xF70513 0xF706D8 0xF70782 +13 more
; Touches: (0x107C)
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF7122F is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_TicksToPpq96: unless Smf_Division is 96: XWA = XWA * 96 / Smf_Division -- a delta time in the file's ticks per quarter note
;   rescaled to the sequencer's 96 per beat (INTTR4_SequencerTick's resolution).
Smf_TicksToPpq96:
	ld	hl, (Smf_Division:16)	; F7122F  ld HL,(0x107c)
	cp	hl, 96	; F71233  cp HL,0x0060
	jr	z, Smf_TicksToPpq96_Return	; F71237  jr Z,0xf7124d
	ldw	hl, 96	; F71239  ld HL,0x0060
	mul	xwa, hl	; F7123C  mul XWA,HL
	ld	de, qwa	; F7123E  ld DE,QWA
	ld	hl, (Smf_Division:16)	; F71241  ld HL,(0x107c)
	ld	qwa, de	; F71245  ld QWA,DE
	div	xwa, hl	; F71248  div XWA,HL
	ld	de, qwa	; F7124A  ld DE,QWA
Smf_TicksToPpq96_Return:
	ret	; F7124D  ret

; --------------------------------------------------------------------------
; TrackCursor_Load
; Called from: in-module: 0xF6FA7D 0xF6FAD3 0xF6FCA1 0xF6FFB9 0xF70085
;              0xF70140 0xF7033B 0xF704F0 +8 more
; Touches: (0x345C) (0x345E)
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF7124E is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackCursor_Load: BStore_CursorBlock = word[IY] of the table at RAM 0x3460, BStore_CursorOffset = byte[IY] of the table at 0x3482:
;   the block-store cursor of track IY.
TrackCursor_Load:
	push	xde	; F7124E  push XDE
	sla	xiy, 1	; F7124F  sla 0x01,XIY
	ld	xde, 13408	; F71252  ld XDE,0x00003460
	ld	wa, (xde+iy)	; F71257  ld WA,(XDE+IY)
	ld	(BStore_CursorBlock:16), wa	; F7125C  ld (0x345c),WA
	srl	xiy, 1	; F71260  srl 0x01,XIY
	ld	xde, 13442	; F71263  ld XDE,0x00003482
	ld	a, (xde+iy)	; F71268  ld A,(XDE+IY)
	xor	w, w	; F7126D  xor W,W
	ld	(BStore_CursorOffset:16), wa	; F7126F  ld (0x345e),WA
	pop	xde	; F71273  pop XDE
	ret	; F71274  ret

; --------------------------------------------------------------------------
; TrackCursor_Save
; Called from: in-module: 0xF6FAA4 0xF6FD71 0xF6FFFF 0xF70134 0xF701DE
;              0xF70391 0xF70536 0xF7074B +7 more
; Touches: (0x345C) (0x345E)
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF71275 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackCursor_Save: the reverse: the BStore cursor into word[IY] at 0x3460 and byte[IY] at 0x3482.
TrackCursor_Save:
	push	xix	; F71275  push XIX
	ld	wa, (BStore_CursorBlock:16)	; F71276  ld WA,(0x345c)
	sla	iy, 1	; F7127A  sla 0x01,IY
	ld	xix, 13408	; F7127D  ld XIX,0x00003460
	ld	(xix+iy), wa	; F71282  ld (XIX+IY),WA
	ld	wa, (BStore_CursorOffset:16)	; F71287  ld WA,(0x345e)
	srl	iy, 1	; F7128B  srl 0x01,IY
	ld	xix, 13442	; F7128E  ld XIX,0x00003482
	ld	(xix+iy), a	; F71293  ld (XIX+IY),A
	pop	xix	; F71298  pop XIX
	ret	; F71299  ret

; --------------------------------------------------------------------------
; SmfEvent_MarkChannelUsed
; Called from: in-module: 0xF6FFFC 0xF70131 0xF701DB 0xF7038E 0xF70533
;              0xF70748 0xF707A2 0xF708F0 +12 more
; Touches: (0x10D0) (0x360C)
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF7129A is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_MarkChannelUsed: Sets bit (Smf_EventStatus & 0x0F) -- the event's MIDI channel -- in the 16-bit word
;   (0x360C); every SMF channel-event handler (single- and multi-track) calls it right after the event's bytes were
;   stored with (0x1238) still 0, and Smf_ReadMultiTrack zeroes (0x360C) before an import. Basis: callers + body.
;   (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
SmfEvent_MarkChannelUsed:
	pushw	bc	; F7129A  push BC
	ld	iy, (Smf_EventStatus:16)	; F7129B  ld IY,(0x10d0)
	and	iy, 15	; F7129F  and IY,0x000f
	ld	bc, iy	; F712A3  ld BC,IY
	xor	b, b	; F712A5  xor B,B
	ld	de, (13836:16)	; F712A7  ld DE,(0x360c)
	ld	a, c	; F712AB  ld A,C
	scf	; F712AD  scf
	stcf_a_16	de	; F712AE  stcf A,DE
	ld	(13836:16), de	; F712B0  ld (0x360c),DE
	popw	bc	; F712B4  pop BC
	ret	; F712B5  ret

; --------------------------------------------------------------------------
; Smf_AddDeltaToHeldNotes
; Called from: in-module: 0xF6F6E2 0xF71C94
; Touches: nothing with an absolute address
; Calls:   Smf_DeltaToPpq96
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF712B6 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_AddDeltaToHeldNotes: for each of the 33 seven-byte records at 0x305A whose bit 7 is set (a note still sounding), adds Smf_DeltaToPpq96 to
;   its word at +5, saturating at 0x2FFF -- the largest note length (EditField_Length's limit).
Smf_AddDeltaToHeldNotes:
	xor	xiy, xiy	; F712B6  xor XIY,XIY
Smf_AddDeltaToHeldNotes_Loop:
	push	xix	; F712B8  push XIX
	ld	xix, 12378	; F712B9  ld XIX,0x0000305a
	bit	7, (xix+iy)	; F712BE  bit 7,(XIX+IY)
	pop	xix	; F712C3  pop XIX
	jr	z, Smf_AddDeltaToHeldNotes_Skip2	; F712C4  jr Z,0xf712ec
	calr	Smf_DeltaToPpq96	; F712C6  calr 0xf712fb
	push	xix	; F712C9  push XIX
	ld	xix, 12378	; F712CA  ld XIX,0x0000305a
	add	xix, xiy	; F712CF  add XIX,XIY
	add	wa, (xix+5)	; F712D1  add WA,(XIX+0x05)
	pop	xix	; F712D4  pop XIX
	jr	ov, Smf_AddDeltaToHeldNotes_Skip	; F712D5  jr PE/OV,0xf712dd

; --------------------------------------------------------------------------
; REACHED CODE, not data (was `Data_F712D7`), part of Smf_AddDeltaToHeldNotes:
;   the no-overflow arm of `jr ov` at 0xF712D5: `cp WA,0x2FFF / jr ...`.
; --------------------------------------------------------------------------
	cp	wa, 12287	; F712D7  cp WA,0x2fff
	jr	c, Smf_AddDeltaToHeldNotes_Skip3	; F712DB  jr C,0xf712e0

Smf_AddDeltaToHeldNotes_Skip:
	ldw	wa, 12287	; F712DD  ld WA,0x2fff
Smf_AddDeltaToHeldNotes_Skip3:
	push	xix	; F712E0  push XIX
	ld	xix, 12378	; F712E1  ld XIX,0x0000305a
	add	xix, xiy	; F712E6  add XIX,XIY
	ld	(xix+5), wa	; F712E8  ld (XIX+0x05),WA
	pop	xix	; F712EB  pop XIX
Smf_AddDeltaToHeldNotes_Skip2:
	add	xiy, 7	; F712EC  add XIY,0x00000007
	cp	xiy, 224	; F712F2  cp XIY,0x000000e0
	jr	ule, Smf_AddDeltaToHeldNotes_Loop	; F712F8  jr ULE,0xf712b8
	ret	; F712FA  ret

; --------------------------------------------------------------------------
; Smf_DeltaToPpq96
; Called from: in-module: 0xF712C6
; Touches: (0x107C) (0x1198) (0x119A) (0x1250) (0x1252)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF712FB is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_DeltaToPpq96: the delta time in Smf_VlqValue (24 bits) rescaled to 96 per beat: * 96 / Smf_Division, unless the division is 96.
Smf_DeltaToPpq96:
	ld	wa, (Smf_Division:16)	; F712FB  ld WA,(0x107c)
	cp	wa, 96	; F712FF  cp WA,0x0060
	jr	z, Smf_DeltaToPpq96_Skip2	; F71303  jr Z,0xf7135e
	ld	e, (4506:16)	; F71305  ld E,(0x119a)
	ld	wa, (Smf_VlqValue:16)	; F71309  ld WA,(0x1198)
	cp	e, 0:i3	; F7130D  cp E,0
	jr	z, Smf_DeltaToPpq96_Skip	; F7130F  jr Z,0xf71344
	ldw	hl, 96	; F71311  ld HL,0x0060
	mul	xwa, hl	; F71314  mul XWA,HL
	ld	de, qwa	; F71316  ld DE,QWA
	ld	(4688:16), wa	; F71319  ld (0x1250),WA
	ld	(4690:16), de	; F7131D  ld (0x1252),DE
	xor	w, w	; F71321  xor W,W
	ld	a, (4506:16)	; F71323  ld A,(0x119a)
	mul	xwa, hl	; F71327  mul XWA,HL
	ld	de, qwa	; F71329  ld DE,QWA
	add	wa, (0x1252:16)	; F7132C  add WA,(0x1252)
	ld	de, wa	; F71330  ld DE,WA
	ld	wa, (4688:16)	; F71332  ld WA,(0x1250)
	ld	hl, (Smf_Division:16)	; F71336  ld HL,(0x107c)
	ld	qwa, de	; F7133A  ld QWA,DE
	div	xwa, hl	; F7133D  div XWA,HL
	ld	de, qwa	; F7133F  ld DE,QWA
	jr	Smf_DeltaToPpq96_Return	; F71342  jr T,0xf71368
Smf_DeltaToPpq96_Skip:
	ld	wa, (Smf_VlqValue:16)	; F71344  ld WA,(0x1198)
	ldw	hl, 96	; F71348  ld HL,0x0060
	mul	xwa, hl	; F7134B  mul XWA,HL
	ld	de, qwa	; F7134D  ld DE,QWA
	ld	hl, (Smf_Division:16)	; F71350  ld HL,(0x107c)
	ld	qwa, de	; F71354  ld QWA,DE
	div	xwa, hl	; F71357  div XWA,HL
	ld	de, qwa	; F71359  ld DE,QWA
	jr	Smf_DeltaToPpq96_Return	; F7135C  jr T,0xf71368
Smf_DeltaToPpq96_Skip2:
	xor	de, de	; F7135E  xor DE,DE
	ld	e, (4506:16)	; F71360  ld E,(0x119a)
	ld	wa, (Smf_VlqValue:16)	; F71364  ld WA,(0x1198)
Smf_DeltaToPpq96_Return:
	ret	; F71368  ret

; --------------------------------------------------------------------------
; Smf_ReadVlqBytes_Copy
; Called from: in-module: 0xF6F6BD 0xF71C6F
; Touches: (0x124A)
; Calls:   InputStream_GetByte
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF71369 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_ReadVlqBytes_Copy: the same twelve instructions as Smf_ReadVlqBytes.
Smf_ReadVlqBytes_Copy:
	ld	xix, Smf_VlqBytes	; F71369  ld XIX,0x00001193
Smf_ReadVlqBytes_Copy_Loop:
	push	xix	; F7136E  push XIX
	calr	InputStream_GetByte	; F7136F  calr 0xf7138f
	pop	xix	; F71372  pop XIX
	ld	w, (InputStream_Status:16)	; F71373  ld W,(0x124a)
	cp	w, 1:i3	; F71377  cp W,1
	jr	z, Smf_ReadVlqBytes_Copy_Skip	; F71379  jr Z,0xf71380
	cp	w, 253	; F7137B  cp W,0xfd
	jr	nz, Smf_ReadVlqBytes_Copy_Return	; F7137E  jr NZ,0xf7138e
Smf_ReadVlqBytes_Copy_Skip:
	ld	(xix+), a	; F71380  ld (XIX+),A
	bit	7, a	; F71383  bit 0x07,A
	jr	nz, Smf_ReadVlqBytes_Copy_Loop	; F71386  jr NZ,0xf7136e
	sub	xix, Smf_VlqBytes	; F71388  sub XIX,0x00001193
Smf_ReadVlqBytes_Copy_Return:
	ret	; F7138E  ret

; --------------------------------------------------------------------------
; InputStream_GetByte -- 0xF7138F
; Called from: in-module: 0xF6F5A2 0xF6F5D7 0xF6F5E2 0xF6F5E9 0xF6F5F0
;              0xF6F5F7 0xF6F604 0xF6F65F +33 more
; Touches: (0x1088) (0x1248) (0x124A)  |  0x60A700 0x60AAFF
; Calls:   InputStream_Refill T_DiskProgress_PrintDotForSmf
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7138F is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Name:    InputStream_GetByte -- named 2026-08-31 for what it does, NOT for the
;          file format it happens to serve.
; Evidence (INTERNAL): `ld XIX,(0x1088) / ld A,(XIX+)` -- one byte from the
;          32-bit cursor at RAM (0x1088), post-incremented -- then
;          `cp XIX,0x0060aaff / jr ULE`, and past that bound it calls
;          InputStream_Refill and re-reads.  Both the cursor address and the
;          window's top are immediates in this routine.  It also sets (0x124A)
;          to 1 on the fast path and to the refill's return code otherwise, so
;          (0x124A) is the fetch's STATUS byte; every caller tests it against 1
;          and 0xFD.
; Callers: 41 `calr` sites, all inside 0xF6F5A2-0xF7136F, which is the SMF
;          reader (notes/prom_b_smf_reader.py).  That is why the neighbours
;          carry an Smf prefix and this one does not: a byte fetch is not
;          evidence about a file format.
; ⚠ CORRECTED 2026-08-31: this header used to end `Unknown: what the routine is
;          FOR.  Left as sub_XXXXXX with the gap stated`.
; Unknown: what fills the window; the refill leaves prom_b through T_DiskApi_ReadFileToWindow_Entry.
; --------------------------------------------------------------------------
InputStream_GetByte:
	push	xix	; F7138F  push XIX
	ld	xix, (InputStream_Cursor:16)	; F71390  ld XIX,(0x1088)
	ld	a, (xix+)	; F71394  ld A,(XIX+)
	ld	(InputStream_Status:16), 1	; F71397  ld (0x124a),0x01
	cp	xix, 6335231	; F7139C  cp XIX,0x0060aaff
	jr	ule, InputStream_GetByte_Skip2	; F713A2  jr ULE,0xf713db
	ld	l, a	; F713A4  ld L,A
	pushw	hl	; F713A6  push HL
	calr	InputStream_Refill	; F713A7  calr 0xf765d4
	popw	hl	; F713AA  pop HL
	ld	(InputStream_Status:16), a	; F713AB  ld (0x124a),A
	ld	a, l	; F713AF  ld A,L
	incw	1, (4680:16)	; F713B1  incw 1,(0x1248)
	pushw	wa	; F713B5  push WA
	push	xhl	; F713B6  push XHL
	pushw	de	; F713B7  push DE
	ld	wa, (4680:16)	; F713B8  ld WA,(0x1248)
	xor	de, de	; F713BC  xor DE,DE
	ldw	hl, 4	; F713BE  ld HL,0x0004
	ld	qwa, de	; F713C1  ld QWA,DE
	div	xwa, hl	; F713C4  div XWA,HL
	ld	de, qwa	; F713C6  ld DE,QWA
	cp	de, 0:i3	; F713C9  cp DE,0
	jr	nz, InputStream_GetByte_Skip	; F713CB  jr NZ,0xf713d3
	push	xix	; F713CD  push XIX
	call	T_DiskProgress_PrintDotForSmf	; F713CE  call 0xf42604
	pop	xix	; F713D2  pop XIX
InputStream_GetByte_Skip:
	popw	de	; F713D3  pop DE
	pop	xhl	; F713D4  pop XHL
	popw	wa	; F713D5  pop WA
	ld	xix, 6334208	; F713D6  ld XIX,0x0060a700
InputStream_GetByte_Skip2:
	ld	(InputStream_Cursor:16), xix	; F713DB  ld (0x1088),XIX
	pop	xix	; F713DF  pop XIX
	ret	; F713E0  ret

; --------------------------------------------------------------------------
; BStore_ExtendChainAtCursor
; Called from: in-module: 0xF71012
; Touches: (0x126E) (0x345C) (0x345E)
; Calls:   T_BStore_AllocBlock_Veneer SongStore_SeekBlock_Copy
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF713E1 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ExtendChainAtCursor: IX = a new block from T_BStore_AllocBlock_Veneer; the cursor block's next link (+3) = it, its previous link (+1) = the cursor block,
;   its next = 0xFFFF; the cursor moves to it at offset 5 (the block header's length).
BStore_ExtendChainAtCursor:
	push	xix	; F713E1  push XIX
	call	T_BStore_AllocBlock_Veneer	; F713E2  call 0xf42884
	ld	wa, ix	; F713E6  ld WA,IX
	ld	hl, (BStore_CursorBlock:16)	; F713E8  ld HL,(0x345c)
	calr	SongStore_SeekBlock_Copy	; F713EC  calr 0xf72f0a
	ld	xhl, (BStore_CursorBlockAddr:16)	; F713EF  ld XHL,(0x126e)
	ld	(xhl+3), wa	; F713F3  ld (XHL+0x03),WA
	ld	hl, wa	; F713F6  ld HL,WA
	calr	SongStore_SeekBlock_Copy	; F713F8  calr 0xf72f0a
	ld	xhl, (BStore_CursorBlockAddr:16)	; F713FB  ld XHL,(0x126e)
	ld	bc, (BStore_CursorBlock:16)	; F713FF  ld BC,(0x345c)
	ld	(xhl+1), bc	; F71403  ld (XHL+0x01),BC
	ldw	(xhl+3), 0xffff	; F71406  ld (XHL+0x03),0xffff
	ld	(BStore_CursorBlock:16), wa	; F7140B  ld (0x345c),WA
	ldw	(BStore_CursorOffset:16), 5	; F7140F  ld (0x345e),0x0005
	pop	xix	; F71415  pop XIX
	ret	; F71416  ret

; --------------------------------------------------------------------------
; SmfPart_ResetAllRecords
; Called from: in-module: 0xF70024 0xF703B6 0xF70658 0xF706A6 0xF70802
;              0xF7097C 0xF70A09 0xF70F19 +6 more
; Touches: (0x1239)  |  0x6036A0
; Calls:   T_BStore_Workspace_StoreGmModeDefaults
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF71417 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfPart_ResetAllRecords: Calls T_BStore_Workspace_StoreGmModeDefaults with 1 when (0x1239)=0xFF (GM mode; prom_a then runs GmMode_ResetToDefaults)
;   else 0, then writes defaults into the 16 channels' 64-byte part records at 0x6036A0: +2/+3 sound = 0 (the drum
;   channel, ch 10 in GM / ch 16 otherwise, gets +3 = 0x20), +6 = 0x15, +7 = 0, +9 = 0x40, +10 = Data_F71512[ch], +11
;   = 0x40. Run by GM System On/Off SysEx and before an import's first channel event. Basis: callers + body.
;   (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
SmfPart_ResetAllRecords:
	push	xwa	; F71417  push XWA
	push	xhl	; F71418  push XHL
	push	xbc	; F71419  push XBC
	push	xde	; F7141A  push XDE
	push	xix	; F7141B  push XIX
	push	xiy	; F7141C  push XIY
	push	xiz	; F7141D  push XIZ
	cp	(0x1239:16), 0xff	; F7141E  cp (0x1239),0xff
	jr	z, SmfPart_ResetAllRecords_Skip	; F71423  jr Z,0xf7142a
	pushw	0	; F71425  push 0x0000
	jr	SmfPart_ResetAllRecords_Join	; F71428  jr T,0xf7142d
SmfPart_ResetAllRecords_Skip:
	pushw	1	; F7142A  push 0x0001
SmfPart_ResetAllRecords_Join:
	call	T_BStore_Workspace_StoreGmModeDefaults	; F7142D  call 0xf40908
	inc	2, xsp	; F71431  inc 2,XSP
	pop	xiz	; F71433  pop XIZ
	pop	xiy	; F71434  pop XIY
	pop	xix	; F71435  pop XIX
	pop	xde	; F71436  pop XDE
	pop	xbc	; F71437  pop XBC
	pop	xhl	; F71438  pop XHL
	pop	xwa	; F71439  pop XWA
	push	xwa	; F7143A  push XWA
	push	xhl	; F7143B  push XHL
	push	xbc	; F7143C  push XBC
	push	xde	; F7143D  push XDE
	push	xix	; F7143E  push XIX
	push	xiy	; F7143F  push XIY
	push	xiz	; F71440  push XIZ
	xor	hl, hl	; F71441  xor HL,HL
	xor	xiy, xiy	; F71443  xor XIY,XIY
SmfPart_ResetAllRecords_Loop:
	pushw	hl	; F71445  push HL
	ld	xix, 6305440	; F71446  ld XIX,0x006036a0
	ld	a, l	; F7144B  ld A,L
	cp	a, 8	; F7144D  cp A,0x08
	jr	lt, SmfPart_ResetAllRecords_Skip2	; F71450  jr LT,0xf71454
	inc	1, a	; F71452  inc 1,A
SmfPart_ResetAllRecords_Skip2:
	ld	w, 64:opc	; F71454  ld W,0x40
	muls	wa, w	; F71456  muls WA,W
	ld	hl, wa	; F71458  ld HL,WA
	ldw	wa, 1024	; F7145A  ld WA,0x0400
	cp	(0x1239:16), 0x00	; F7145D  cp (0x1239),0x00
	jr	z, SmfPart_ResetAllRecords_Skip3	; F71462  jr Z,0xf71467
	ldw	wa, 640	; F71464  ld WA,0x0280
SmfPart_ResetAllRecords_Skip3:
	cp	hl, wa	; F71467  cp HL,WA
	jr	z, sub_F71417_Entry	; F71469  jr Z,0xf7148b
	ldfr_lerp	xix, 0x38	; F7146B  ld XDE3,XIX
	lda	xix, (xix+hl)	; F7146E  lda XIX,XIX+HL
	ld	(xix+2), 0	; F71473  ld (XIX+0x02),0x00
	ldto_lerp	xix, 0x38	; F71477  ld XIX,XDE3
	ldfr_lerp	xix, 0x38	; F7147A  ld XDE3,XIX
	lda	xix, (xix+hl)	; F7147D  lda XIX,XIX+HL
	ld	(xix+3), 0	; F71482  ld (XIX+0x03),0x00
	ldto_lerp	xix, 0x38	; F71486  ld XIX,XDE3
	jr	sub_F71417_Entry2	; F71489  jr T,0xf714a9
sub_F71417_Entry:
	ldfr_lerp	xix, 0x38	; F7148B  ld XDE3,XIX
	lda	xix, (xix+hl)	; F7148E  lda XIX,XIX+HL
	ld	(xix+2), 0	; F71493  ld (XIX+0x02),0x00
	ldto_lerp	xix, 0x38	; F71497  ld XIX,XDE3
	ldfr_lerp	xix, 0x38	; F7149A  ld XDE3,XIX
	lda	xix, (xix+hl)	; F7149D  lda XIX,XIX+HL
	ld	(xix+3), 32	; F714A2  ld (XIX+0x03),0x20
	ldto_lerp	xix, 0x38	; F714A6  ld XIX,XDE3
sub_F71417_Entry2:
	ldfr_lerp	xix, 0x38	; F714A9  ld XDE3,XIX
	lda	xix, (xix+hl)	; F714AC  lda XIX,XIX+HL
	ld	(xix+6), 21	; F714B1  ld (XIX+0x06),0x15
	ldto_lerp	xix, 0x38	; F714B5  ld XIX,XDE3
	ldfr_lerp	xix, 0x38	; F714B8  ld XDE3,XIX
	lda	xix, (xix+hl)	; F714BB  lda XIX,XIX+HL
	ld	(xix+7), 0	; F714C0  ld (XIX+0x07),0x00
	ldto_lerp	xix, 0x38	; F714C4  ld XIX,XDE3
	ldfr_lerp	xix, 0x38	; F714C7  ld XDE3,XIX
	lda	xix, (xix+hl)	; F714CA  lda XIX,XIX+HL
	ld	(xix+9), 64	; F714CF  ld (XIX+0x09),0x40
	ldto_lerp	xix, 0x38	; F714D3  ld XIX,XDE3
	push	xde	; F714D6  push XDE
	ld	xde, Data_F71512	; F714D7  ld XDE,0x00f71512
	ld	a, (xde+iy)	; F714DC  ld A,(XDE+IY)
	pop	xde	; F714E1  pop XDE
	ldfr_lerp	xix, 0x38	; F714E2  ld XDE3,XIX
	lda	xix, (xix+hl)	; F714E5  lda XIX,XIX+HL
	ld	(xix+10), a	; F714EA  ld (XIX+0x0a),A
	ldto_lerp	xix, 0x38	; F714ED  ld XIX,XDE3
	ldfr_lerp	xix, 0x38	; F714F0  ld XDE3,XIX
	lda	xix, (xix+hl)	; F714F3  lda XIX,XIX+HL
	ld	(xix+11), 64	; F714F8  ld (XIX+0x0b),0x40
	ldto_lerp	xix, 0x38	; F714FC  ld XIX,XDE3
	popw	hl	; F714FF  pop HL
	inc	1, l	; F71500  inc 1,L
	inc	1, xiy	; F71502  inc 1,XIY
	cp	l, 15	; F71504  cp L,0x0f
	jrl	ule, SmfPart_ResetAllRecords_Loop	; F71507  jrl ULE,0xf71445
	pop	xiz	; F7150A  pop XIZ
	pop	xiy	; F7150B  pop XIY
	pop	xix	; F7150C  pop XIX
	pop	xde	; F7150D  pop XDE
	pop	xbc	; F7150E  pop XBC
	pop	xhl	; F7150F  pop XHL
	pop	xwa	; F71510  pop XWA
	ret	; F71511  ret

; --------------------------------------------------------------------------
; Data_F71512 -- 19 bytes this block could not split.  No content rule
;                framed it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or
;                ASCII -- and the code walk never reached it from a thunk
;                slot, a proven call site, an opcode-anchored call or an
;                entry of a table the firmware transfers to.  So it is
;                emitted as bytes rather than guessed.
; Contains: printable bytes |`@ @@@@ @`@@@@@@.n.|
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XDE,0x00f71512` at
;          0xF714D7 (operand field 1 byte in)
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; Unknown: everything about it except its bytes.
; --------------------------------------------------------------------------
Data_F71512:
	.byte	0x60, 0x40, 0x20, 0x40, 0x40, 0x40, 0x40, 0x20, 0x40, 0x60, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40	; F71512  [0..15]
	.byte	0x05, 0x6E, 0x00	; F71522  [16..18]


; --------------------------------------------------------------------------
; SmfEvent_SysEx
; Called from: in-module: 0xF6F733 0xF71CF1
; Touches: (0x1198) (0x11B1) (0x1239) (0x124A) (0x124B) (0x137B) (0x137C)
;          (0x137D) (0x137E)
; Calls:   Smf_ReadVlq InputStream_GetByte SmfPart_ResetAllRecords SmfSysEx_ApplyParamChange Smf_SkipBytes
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF71525 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; ⚠ ANSWERED 2026-09-25 (SmfEvent_SysEx, was a name that was the address): the
;   SMF reader's SysEx-event handler.  With (0x1198), the bytes left in the
;   event, = 5 it matches 7E 7F 09 01 / 02 -- GM System On / Off -- and
;   records it (bit 0 of (0x124B); (0x1239) = 0xFF / 0x00; SmfPart_ResetAllRecords).  With
;   (0x1198) = 16 it matches 50 2C 04 00 11 00, an address pair into
;   (0x137B)/(0x137C) (0x00:0x30-0x31, 0x01:0x04, or 0x11:<=0x75 -- `cp
;   A,0x75` at 0xF71637), 00 00 01, two data nibbles into (0x137E)/(0x137D),
;   and calls SmfSysEx_ApplyParamChange.
;   notes/promb-2026-09-25/smf_sysex_param_change.py.
; --------------------------------------------------------------------------
SmfEvent_SysEx:
	calr	Smf_ReadVlq	; F71525  calr 0xf6fd7a
	ld	w, (InputStream_Status:16)	; F71528  ld W,(0x124a)
	cp	w, 1:i3	; F7152C  cp W,1
	jr	z, SmfEvent_SysEx_Skip	; F7152E  jr Z,0xf71536
	cp	w, 253	; F71530  cp W,0xfd
	jrl	nz, SmfEvent_SysEx_Return	; F71533  jrl NZ,0xf71696
SmfEvent_SysEx_Skip:
	bit	0, (0x124b:16)	; F71536  bit 0,(0x124b)
	jrl	nz, SmfEvent_SysEx_Skip3	; F7153A  jrl NZ,0xf715ad
	bit	0, (0x11b1:16)	; F7153D  bit 0,(0x11b1)
	jrl	nz, SmfEvent_SysEx_Join2	; F71541  jrl NZ,0xf71693
	cpw	(Smf_VlqValue:16), 0x0005	; F71544  cp (0x1198),0x0005
	jrl	nz, SmfEvent_SysEx_Skip3	; F7154A  jrl NZ,0xf715ad
	ld	hl, (Smf_VlqValue:16)	; F7154D  ld HL,(0x1198)
	pushw	hl	; F71551  push HL
	calr	InputStream_GetByte	; F71552  calr 0xf7138f
	popw	hl	; F71555  pop HL
	dec	1, hl	; F71556  dec 1,HL
	cp	a, 126	; F71558  cp A,0x7e
	jrl	nz, SmfEvent_SysEx_Loop	; F7155B  jrl NZ,0xf715a6
	pushw	hl	; F7155E  push HL
	calr	InputStream_GetByte	; F7155F  calr 0xf7138f
	popw	hl	; F71562  pop HL
	dec	1, hl	; F71563  dec 1,HL
	cp	a, 127	; F71565  cp A,0x7f
	jrl	nz, SmfEvent_SysEx_Loop	; F71568  jrl NZ,0xf715a6
	pushw	hl	; F7156B  push HL
	calr	InputStream_GetByte	; F7156C  calr 0xf7138f
	popw	hl	; F7156F  pop HL
	dec	1, hl	; F71570  dec 1,HL
	cp	a, 9	; F71572  cp A,0x09
	jrl	nz, SmfEvent_SysEx_Loop	; F71575  jrl NZ,0xf715a6
	pushw	hl	; F71578  push HL
	calr	InputStream_GetByte	; F71579  calr 0xf7138f
	popw	hl	; F7157C  pop HL
	dec	1, hl	; F7157D  dec 1,HL
	cp	a, 1:i3	; F7157F  cp A,1
	jrl	nz, SmfEvent_SysEx_Skip2	; F71581  jrl NZ,0xf71594
	or	(0x124b:16), 0x01	; F71584  or (0x124b),0x01
	ld	(4665:16), 255	; F71589  ld (0x1239),0xff
	calr	SmfPart_ResetAllRecords	; F7158E  calr 0xf71417
	jrl	SmfEvent_SysEx_Loop	; F71591  jrl T,0xf715a6
SmfEvent_SysEx_Skip2:
	cp	a, 2:i3	; F71594  cp A,2
	jrl	nz, SmfEvent_SysEx_Loop	; F71596  jrl NZ,0xf715a6
	or	(0x124b:16), 0x01	; F71599  or (0x124b),0x01
	ld	(4665:16), 0	; F7159E  ld (0x1239),0x00
	calr	SmfPart_ResetAllRecords	; F715A3  calr 0xf71417
SmfEvent_SysEx_Loop:
	ld	(Smf_VlqValue:16), hl	; F715A6  ld (0x1198),HL
	jrl	SmfEvent_SysEx_Join2	; F715AA  jrl T,0xf71693
SmfEvent_SysEx_Skip3:
	cpw	(Smf_VlqValue:16), 0x0010	; F715AD  cp (0x1198),0x0010
	jrl	nz, SmfEvent_SysEx_Join2	; F715B3  jrl NZ,0xf71693
	ld	hl, (Smf_VlqValue:16)	; F715B6  ld HL,(0x1198)
	pushw	hl	; F715BA  push HL
	calr	InputStream_GetByte	; F715BB  calr 0xf7138f
	popw	hl	; F715BE  pop HL
	dec	1, hl	; F715BF  dec 1,HL
	cp	a, 80	; F715C1  cp A,0x50
	jrl	nz, SmfEvent_SysEx_Loop	; F715C4  jrl NZ,0xf715a6
	pushw	hl	; F715C7  push HL
	calr	InputStream_GetByte	; F715C8  calr 0xf7138f
	popw	hl	; F715CB  pop HL
	dec	1, hl	; F715CC  dec 1,HL
	cp	a, 44	; F715CE  cp A,0x2c
	jrl	nz, SmfEvent_SysEx_Loop	; F715D1  jrl NZ,0xf715a6
	pushw	hl	; F715D4  push HL
	calr	InputStream_GetByte	; F715D5  calr 0xf7138f
	popw	hl	; F715D8  pop HL
	dec	1, hl	; F715D9  dec 1,HL
	cp	a, 4:i3	; F715DB  cp A,4
	jrl	nz, SmfEvent_SysEx_Loop	; F715DD  jrl NZ,0xf715a6
	pushw	hl	; F715E0  push HL
	calr	InputStream_GetByte	; F715E1  calr 0xf7138f
	popw	hl	; F715E4  pop HL
	dec	1, hl	; F715E5  dec 1,HL
	cp	a, 0:i3	; F715E7  cp A,0
	jrl	nz, SmfEvent_SysEx_Loop	; F715E9  jrl NZ,0xf715a6
	pushw	hl	; F715EC  push HL
	calr	InputStream_GetByte	; F715ED  calr 0xf7138f
	popw	hl	; F715F0  pop HL
	dec	1, hl	; F715F1  dec 1,HL
	cp	a, 17	; F715F3  cp A,0x11
	jrl	nz, SmfEvent_SysEx_Loop	; F715F6  jrl NZ,0xf715a6
	pushw	hl	; F715F9  push HL
	calr	InputStream_GetByte	; F715FA  calr 0xf7138f
	popw	hl	; F715FD  pop HL
	dec	1, hl	; F715FE  dec 1,HL
	cp	a, 0:i3	; F71600  cp A,0
	jrl	nz, SmfEvent_SysEx_Loop	; F71602  jrl NZ,0xf715a6
	pushw	hl	; F71605  push HL
	calr	InputStream_GetByte	; F71606  calr 0xf7138f
	popw	hl	; F71609  pop HL
	dec	1, hl	; F7160A  dec 1,HL
	ld	(4987:16), a	; F7160C  ld (0x137b),A
	cp	a, 0:i3	; F71610  cp A,0
	jr	z, SmfEvent_SysEx_Skip4	; F71612  jr Z,0xf7161e
	cp	a, 1:i3	; F71614  cp A,1
	jr	z, SmfEvent_SysEx_Skip4	; F71616  jr Z,0xf7161e
	cp	a, 17	; F71618  cp A,0x11
	jrl	nz, SmfEvent_SysEx_Loop	; F7161B  jrl NZ,0xf715a6
SmfEvent_SysEx_Skip4:
	pushw	hl	; F7161E  push HL
	calr	InputStream_GetByte	; F7161F  calr 0xf7138f
	popw	hl	; F71622  pop HL
	dec	1, hl	; F71623  dec 1,HL
	ld	(4988:16), a	; F71625  ld (0x137c),A
	cp	(0x137b:16), 0x00	; F71629  cp (0x137b),0x00
	jr	z, SmfEvent_SysEx_Skip5	; F7162E  jr Z,0xf7163f
	cp	(0x137b:16), 0x01	; F71630  cp (0x137b),0x01
	jr	z, SmfEvent_SysEx_Skip6	; F71635  jr Z,0xf7164d
	cp	a, 117	; F71637  cp A,0x75
	jrl	ugt, SmfEvent_SysEx_Loop	; F7163A  jrl UGT,0xf715a6
	jr	SmfEvent_SysEx_Join	; F7163D  jr T,0xf71652
SmfEvent_SysEx_Skip5:
	cp	a, 48	; F7163F  cp A,0x30
	jrl	c, SmfEvent_SysEx_Loop	; F71642  jrl C,0xf715a6
	cp	a, 49	; F71645  cp A,0x31
	jrl	ugt, SmfEvent_SysEx_Loop	; F71648  jrl UGT,0xf715a6
	jr	SmfEvent_SysEx_Join	; F7164B  jr T,0xf71652
SmfEvent_SysEx_Skip6:
	cp	a, 4:i3	; F7164D  cp A,4
	jrl	nz, SmfEvent_SysEx_Loop	; F7164F  jrl NZ,0xf715a6
SmfEvent_SysEx_Join:
	pushw	hl	; F71652  push HL
	calr	InputStream_GetByte	; F71653  calr 0xf7138f
	popw	hl	; F71656  pop HL
	dec	1, hl	; F71657  dec 1,HL
	cp	a, 0:i3	; F71659  cp A,0
	jrl	nz, SmfEvent_SysEx_Loop	; F7165B  jrl NZ,0xf715a6
	pushw	hl	; F7165E  push HL
	calr	InputStream_GetByte	; F7165F  calr 0xf7138f
	popw	hl	; F71662  pop HL
	dec	1, hl	; F71663  dec 1,HL
	cp	a, 0:i3	; F71665  cp A,0
	jrl	nz, SmfEvent_SysEx_Loop	; F71667  jrl NZ,0xf715a6
	pushw	hl	; F7166A  push HL
	calr	InputStream_GetByte	; F7166B  calr 0xf7138f
	popw	hl	; F7166E  pop HL
	dec	1, hl	; F7166F  dec 1,HL
	cp	a, 1:i3	; F71671  cp A,1
	jrl	nz, SmfEvent_SysEx_Loop	; F71673  jrl NZ,0xf715a6
	pushw	hl	; F71676  push HL
	calr	InputStream_GetByte	; F71677  calr 0xf7138f
	popw	hl	; F7167A  pop HL
	dec	1, hl	; F7167B  dec 1,HL
	ld	(4990:16), a	; F7167D  ld (0x137e),A
	pushw	hl	; F71681  push HL
	calr	InputStream_GetByte	; F71682  calr 0xf7138f
	popw	hl	; F71685  pop HL
	dec	1, hl	; F71686  dec 1,HL
	ld	(4989:16), a	; F71688  ld (0x137d),A
	ld	(Smf_VlqValue:16), hl	; F7168C  ld (0x1198),HL
	calr	SmfSysEx_ApplyParamChange	; F71690  calr 0xf71697
SmfEvent_SysEx_Join2:
	calr	Smf_SkipBytes	; F71693  calr 0xf6fd91
SmfEvent_SysEx_Return:
	ret	; F71696  ret

; --------------------------------------------------------------------------
; SmfSysEx_ApplyParamChange
; Called from: in-module: 0xF71690
; Touches: (0x137B) (0x137F) (0x1380)
; Calls:   SmfSysEx_JoinNibbles SmfSysEx_WriteAddr11 SmfSysEx_WriteAddr00
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF71697 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; ⚠ ANSWERED 2026-09-25 (SmfSysEx_ApplyParamChange, was a name that was the
;   address): joins the nibbles (SmfSysEx_JoinNibbles) and stores the value by
;   address-hi (0x137B): 0x00 -> SmfSysEx_WriteAddr00, 0x01 -> (0x1380), else
;   (0x11) -> SmfSysEx_WriteAddr11.
;   notes/promb-2026-09-25/smf_sysex_param_change.py.
; --------------------------------------------------------------------------
SmfSysEx_ApplyParamChange:
	push	xwa	; F71697  push XWA
	push	xhl	; F71698  push XHL
	push	xbc	; F71699  push XBC
	push	xde	; F7169A  push XDE
	push	xix	; F7169B  push XIX
	push	xiy	; F7169C  push XIY
	push	xiz	; F7169D  push XIZ
	ld	a, (4987:16)	; F7169E  ld A,(0x137b)
	cp	a, 0:i3	; F716A2  cp A,0
	jr	z, SmfSysEx_ApplyParamChange_Skip	; F716A4  jr Z,0xf716b2
	cp	a, 1:i3	; F716A6  cp A,1
	jr	z, SmfSysEx_ApplyParamChange_Skip2	; F716A8  jr Z,0xf716ba
	calr	SmfSysEx_JoinNibbles	; F716AA  calr 0xf716cd
	calr	SmfSysEx_WriteAddr11	; F716AD  calr 0xf716e5
	jr	SmfSysEx_ApplyParamChange_Epilogue	; F716B0  jr T,0xf716c5
SmfSysEx_ApplyParamChange_Skip:
	calr	SmfSysEx_JoinNibbles	; F716B2  calr 0xf716cd
	calr	SmfSysEx_WriteAddr00	; F716B5  calr 0xf71730
	jr	SmfSysEx_ApplyParamChange_Epilogue	; F716B8  jr T,0xf716c5
SmfSysEx_ApplyParamChange_Skip2:
	calr	SmfSysEx_JoinNibbles	; F716BA  calr 0xf716cd
	ld	a, (4991:16)	; F716BD  ld A,(0x137f)
	ld	(4992:16), a	; F716C1  ld (0x1380),A
SmfSysEx_ApplyParamChange_Epilogue:
	pop	xiz	; F716C5  pop XIZ
	pop	xiy	; F716C6  pop XIY
	pop	xix	; F716C7  pop XIX
	pop	xde	; F716C8  pop XDE
	pop	xbc	; F716C9  pop XBC
	pop	xhl	; F716CA  pop XHL
	pop	xwa	; F716CB  pop XWA
	ret	; F716CC  ret

; --------------------------------------------------------------------------
; SmfSysEx_JoinNibbles
; Called from: in-module: 0xF716AA 0xF716B2 0xF716BA
; Touches: (0x137D) (0x137E) (0x137F)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF716CD is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; ⚠ ANSWERED 2026-09-25 (SmfSysEx_JoinNibbles, was a name that was the
;   address): (0x137F) = (0x137E & 0x0F) << 4 | (0x137D & 0x0F), the SysEx
;   value from its two data nibbles.
;   notes/promb-2026-09-25/smf_sysex_param_change.py.
; --------------------------------------------------------------------------
SmfSysEx_JoinNibbles:
	ld	a, (4989:16)	; F716CD  ld A,(0x137d)
	and	a, 15	; F716D1  and A,0x0f
	ld	w, (4990:16)	; F716D4  ld W,(0x137e)
	and	w, 15	; F716D8  and W,0x0f
	sla	w, 4	; F716DB  sla 0x04,W
	or	a, w	; F716DE  or A,W
	ld	(4991:16), a	; F716E0  ld (0x137f),A
	ret	; F716E4  ret

; --------------------------------------------------------------------------
; SmfSysEx_WriteAddr11
; Called from: in-module: 0xF716AD
; Touches: (0x137C) (0x137F)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF716E5 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; ⚠ ANSWERED 2026-09-25 (SmfSysEx_WriteAddr11, was a name that was the
;   address): writes the value to the RAM byte
;   SmfSysEx_Addr11_Targets[(0x137C)] names: lo 1 its low nibble, lo 2 its
;   high nibble (from the value's low nibble), any other lo the whole byte.  ⚠
;   `cp XDE,0xffffffff` (0xF716F8) runs before `ld XDE,(XDE)` (0xF71700), so
;   it tests the entry's ADDRESS and never matches: as the bytes stand, a
;   0xFFFFFFFF entry is written through.
;   notes/promb-2026-09-25/smf_sysex_param_change.py.
; --------------------------------------------------------------------------
SmfSysEx_WriteAddr11:
	xor	hl, hl	; F716E5  xor HL,HL
	ld	l, (4988:16)	; F716E7  ld L,(0x137c)
	sla	hl, 2	; F716EB  sla 0x02,HL
	ld	xde, SmfSysEx_Addr11_Targets	; F716EE  ld XDE,0x00f71767
	lda	xde, (xde+hl)	; F716F3  lda XDE,XDE+HL
	cp	xde, 4294967295	; F716F8  cp XDE,0xffffffff
	jr	z, SmfSysEx_WriteAddr11_Return	; F716FE  jr Z,0xf7172f
	ld	xde, (xde)	; F71700  ld XDE,(XDE)
	ld	a, (4991:16)	; F71702  ld A,(0x137f)
	cp	(0x137c:16), 0x01	; F71706  cp (0x137c),0x01
	jr	z, SmfSysEx_WriteAddr11_Skip	; F7170B  jr Z,0xf71723
	cp	(0x137c:16), 0x02	; F7170D  cp (0x137c),0x02
	jr	nz, SmfSysEx_WriteAddr11_Join	; F71712  jr NZ,0xf7172d
	ld	w, (xde)	; F71714  ld W,(XDE)
	and	w, 15	; F71716  and W,0x0f
	sla	a, 4	; F71719  sla 0x04,A
	and	a, 240	; F7171C  and A,0xf0
	or	a, w	; F7171F  or A,W
	jr	SmfSysEx_WriteAddr11_Join	; F71721  jr T,0xf7172d
SmfSysEx_WriteAddr11_Skip:
	ld	w, (xde)	; F71723  ld W,(XDE)
	and	w, 240	; F71725  and W,0xf0
	and	a, 15	; F71728  and A,0x0f
	or	a, w	; F7172B  or A,W
SmfSysEx_WriteAddr11_Join:
	ld	(xde), a	; F7172D  ld (XDE),A
SmfSysEx_WriteAddr11_Return:
	ret	; F7172F  ret

; --------------------------------------------------------------------------
; SmfSysEx_WriteAddr00
; Called from: in-module: 0xF716B5
; Touches: (0x137C) (0x137F)  |  0x603EE4
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF71730 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; ⚠ ANSWERED 2026-09-25 (SmfSysEx_WriteAddr00, was a name that was the
;   address): address 0x00:0x30 writes the value's low nibble into the low
;   nibble of the byte at 0x603EE4, 0x00:0x31 into its high nibble.
;   notes/promb-2026-09-25/smf_sysex_param_change.py.
; --------------------------------------------------------------------------
SmfSysEx_WriteAddr00:
	cp	(0x137c:16), 0x30	; F71730  cp (0x137c),0x30
	jr	z, SmfSysEx_WriteAddr00_Skip	; F71735  jr Z,0xf71751
	ld	xde, 6307556	; F71737  ld XDE,0x00603ee4
	ld	a, (xde)	; F7173C  ld A,(XDE)
	and	a, 15	; F7173E  and A,0x0f
	ld	w, (4991:16)	; F71741  ld W,(0x137f)
	sla	w, 4	; F71745  sla 0x04,W
	and	w, 240	; F71748  and W,0xf0
	or	a, w	; F7174B  or A,W
	ld	(xde), a	; F7174D  ld (XDE),A
	jr	SmfSysEx_WriteAddr00_Return	; F7174F  jr T,0xf71766
SmfSysEx_WriteAddr00_Skip:
	ld	xde, 6307556	; F71751  ld XDE,0x00603ee4
	ld	a, (xde)	; F71756  ld A,(XDE)
	and	a, 240	; F71758  and A,0xf0
	ld	w, (4991:16)	; F7175B  ld W,(0x137f)
	and	w, 15	; F7175F  and W,0x0f
	or	a, w	; F71762  or A,W
	ld	(xde), a	; F71764  ld (XDE),A
SmfSysEx_WriteAddr00_Return:
	ret	; F71766  ret

; --------------------------------------------------------------------------
; 0xF71767 -- 472 bytes this block could not split.  No content rule
;                framed it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or
;                ASCII -- and the code walk never reached it from a thunk
;                slot, a proven call site, an opcode-anchored call or an
;                entry of a table the firmware transfers to.  So it is
;                emitted as bytes rather than guessed.
; Contains: printable bytes |46`..8`..8`....................................
;           ................................................................
;           .................B6`.C6`.D6`.E6`.F6`.G6`.H6`.I6`.J6`.K6`.L6`.M6`
;           .N6`.O6`.P6`.Q6`.R6`.S6`.T6`.U6`.V6`.W6`.X6`....................
;           .................b6`.c6`.d6`.e6`.f6`.g6`.h6`.i6`.j6`.k6`.l6`.m6`
;           .n6`.o6`.p6`.q6`.r6`.s6`.t6`.u6`.v6`.w6`.x6`....................
;           ..................6`..6`..6`..6`..6`..6`..6`..6`..6`..6`..6`..6`
;           ..6`..6`..6`..6`..6`..6`..6`..6`..6`..6`.|
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XDE,0x00f71767` at
;          0xF716EE (operand field 1 byte in)
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; ⚠ ANSWERED 2026-09-25 (the "nothing but its bytes" verdict that stood here): the
;   header below says what it is; `SmfSysEx_Addr11_Targets` is retired.
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; SmfSysEx_Addr11_Targets -- 118 LE32 RAM addresses, one per SysEx address
;   `11 lo` (lo 0x00-0x75): the byte that the SMF SysEx message
;   `50 2C 04 00 11 00 11 lo 00 00 01 nh nl` sets (SmfEvent_SysEx parses it,
;   SmfSysEx_WriteAddr11 writes it: `ld XDE,this` at 0xF716EE, then
;   `lda XDE,XDE+4*lo`).  Entry count: SmfEvent_SysEx drops lo > 0x75
;   (`cp A,0x75 / jrl UGT` at 0xF71637), so 118 entries = 472 bytes, the whole
;   object.  0xFFFFFFFF = no target (lo 0x03-0x1F, 0x37-0x3F, 0x57-0x5F);
;   lo 1 and lo 2 both name 0x6038B7, whose low / high nibble they write.
; --------------------------------------------------------------------------
SmfSysEx_Addr11_Targets:
	.long	0x00603634	; F71767  [0x00]
	.long	0x006038B7	; F7176B  [0x01]
	.long	0x006038B7	; F7176F  [0x02]
	.long	0xFFFFFFFF	; F71773  [0x03]  no target
	.long	0xFFFFFFFF	; F71777  [0x04]  no target
	.long	0xFFFFFFFF	; F7177B  [0x05]  no target
	.long	0xFFFFFFFF	; F7177F  [0x06]  no target
	.long	0xFFFFFFFF	; F71783  [0x07]  no target
	.long	0xFFFFFFFF	; F71787  [0x08]  no target
	.long	0xFFFFFFFF	; F7178B  [0x09]  no target
	.long	0xFFFFFFFF	; F7178F  [0x0A]  no target
	.long	0xFFFFFFFF	; F71793  [0x0B]  no target
	.long	0xFFFFFFFF	; F71797  [0x0C]  no target
	.long	0xFFFFFFFF	; F7179B  [0x0D]  no target
	.long	0xFFFFFFFF	; F7179F  [0x0E]  no target
	.long	0xFFFFFFFF	; F717A3  [0x0F]  no target
	.long	0xFFFFFFFF	; F717A7  [0x10]  no target
	.long	0xFFFFFFFF	; F717AB  [0x11]  no target
	.long	0xFFFFFFFF	; F717AF  [0x12]  no target
	.long	0xFFFFFFFF	; F717B3  [0x13]  no target
	.long	0xFFFFFFFF	; F717B7  [0x14]  no target
	.long	0xFFFFFFFF	; F717BB  [0x15]  no target
	.long	0xFFFFFFFF	; F717BF  [0x16]  no target
	.long	0xFFFFFFFF	; F717C3  [0x17]  no target
	.long	0xFFFFFFFF	; F717C7  [0x18]  no target
	.long	0xFFFFFFFF	; F717CB  [0x19]  no target
	.long	0xFFFFFFFF	; F717CF  [0x1A]  no target
	.long	0xFFFFFFFF	; F717D3  [0x1B]  no target
	.long	0xFFFFFFFF	; F717D7  [0x1C]  no target
	.long	0xFFFFFFFF	; F717DB  [0x1D]  no target
	.long	0xFFFFFFFF	; F717DF  [0x1E]  no target
	.long	0xFFFFFFFF	; F717E3  [0x1F]  no target
	.long	0x00603642	; F717E7  [0x20]
	.long	0x00603643	; F717EB  [0x21]
	.long	0x00603644	; F717EF  [0x22]
	.long	0x00603645	; F717F3  [0x23]
	.long	0x00603646	; F717F7  [0x24]
	.long	0x00603647	; F717FB  [0x25]
	.long	0x00603648	; F717FF  [0x26]
	.long	0x00603649	; F71803  [0x27]
	.long	0x0060364A	; F71807  [0x28]
	.long	0x0060364B	; F7180B  [0x29]
	.long	0x0060364C	; F7180F  [0x2A]
	.long	0x0060364D	; F71813  [0x2B]
	.long	0x0060364E	; F71817  [0x2C]
	.long	0x0060364F	; F7181B  [0x2D]
	.long	0x00603650	; F7181F  [0x2E]
	.long	0x00603651	; F71823  [0x2F]
	.long	0x00603652	; F71827  [0x30]
	.long	0x00603653	; F7182B  [0x31]
	.long	0x00603654	; F7182F  [0x32]
	.long	0x00603655	; F71833  [0x33]
	.long	0x00603656	; F71837  [0x34]
	.long	0x00603657	; F7183B  [0x35]
	.long	0x00603658	; F7183F  [0x36]
	.long	0xFFFFFFFF	; F71843  [0x37]  no target
	.long	0xFFFFFFFF	; F71847  [0x38]  no target
	.long	0xFFFFFFFF	; F7184B  [0x39]  no target
	.long	0xFFFFFFFF	; F7184F  [0x3A]  no target
	.long	0xFFFFFFFF	; F71853  [0x3B]  no target
	.long	0xFFFFFFFF	; F71857  [0x3C]  no target
	.long	0xFFFFFFFF	; F7185B  [0x3D]  no target
	.long	0xFFFFFFFF	; F7185F  [0x3E]  no target
	.long	0xFFFFFFFF	; F71863  [0x3F]  no target
	.long	0x00603662	; F71867  [0x40]
	.long	0x00603663	; F7186B  [0x41]
	.long	0x00603664	; F7186F  [0x42]
	.long	0x00603665	; F71873  [0x43]
	.long	0x00603666	; F71877  [0x44]
	.long	0x00603667	; F7187B  [0x45]
	.long	0x00603668	; F7187F  [0x46]
	.long	0x00603669	; F71883  [0x47]
	.long	0x0060366A	; F71887  [0x48]
	.long	0x0060366B	; F7188B  [0x49]
	.long	0x0060366C	; F7188F  [0x4A]
	.long	0x0060366D	; F71893  [0x4B]
	.long	0x0060366E	; F71897  [0x4C]
	.long	0x0060366F	; F7189B  [0x4D]
	.long	0x00603670	; F7189F  [0x4E]
	.long	0x00603671	; F718A3  [0x4F]
	.long	0x00603672	; F718A7  [0x50]
	.long	0x00603673	; F718AB  [0x51]
	.long	0x00603674	; F718AF  [0x52]
	.long	0x00603675	; F718B3  [0x53]
	.long	0x00603676	; F718B7  [0x54]
	.long	0x00603677	; F718BB  [0x55]
	.long	0x00603678	; F718BF  [0x56]
	.long	0xFFFFFFFF	; F718C3  [0x57]  no target
	.long	0xFFFFFFFF	; F718C7  [0x58]  no target
	.long	0xFFFFFFFF	; F718CB  [0x59]  no target
	.long	0xFFFFFFFF	; F718CF  [0x5A]  no target
	.long	0xFFFFFFFF	; F718D3  [0x5B]  no target
	.long	0xFFFFFFFF	; F718D7  [0x5C]  no target
	.long	0xFFFFFFFF	; F718DB  [0x5D]  no target
	.long	0xFFFFFFFF	; F718DF  [0x5E]  no target
	.long	0xFFFFFFFF	; F718E3  [0x5F]  no target
	.long	0x00603682	; F718E7  [0x60]
	.long	0x00603683	; F718EB  [0x61]
	.long	0x00603684	; F718EF  [0x62]
	.long	0x00603685	; F718F3  [0x63]
	.long	0x00603686	; F718F7  [0x64]
	.long	0x00603687	; F718FB  [0x65]
	.long	0x00603688	; F718FF  [0x66]
	.long	0x00603689	; F71903  [0x67]
	.long	0x0060368A	; F71907  [0x68]
	.long	0x0060368B	; F7190B  [0x69]
	.long	0x0060368C	; F7190F  [0x6A]
	.long	0x0060368D	; F71913  [0x6B]
	.long	0x0060368E	; F71917  [0x6C]
	.long	0x0060368F	; F7191B  [0x6D]
	.long	0x00603690	; F7191F  [0x6E]
	.long	0x00603691	; F71923  [0x6F]
	.long	0x00603692	; F71927  [0x70]
	.long	0x00603693	; F7192B  [0x71]
	.long	0x00603694	; F7192F  [0x72]
	.long	0x00603695	; F71933  [0x73]
	.long	0x00603696	; F71937  [0x74]
	.long	0x00603698	; F7193B  [0x75]


; --------------------------------------------------------------------------
; SmfCC_GeneralPurpose1
; Called from: in-module: 0xF70437 0xF722CB
; Touches: (0x10D0) (0x10D2) (0x11AE) (0x11AF) (0x11B0) (0x1239) (0x1381)
; Calls:   SmfCC_PutParamEventWithNumber
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7193F is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_GeneralPurpose1: SmfEvent_ControlChange's arm for MIDI controller 16 (`cp a,16 / jr z`).
SmfCC_GeneralPurpose1:
	xor	h, h	; F7193F  xor H,H
	ld	l, (Smf_EventStatus:16)	; F71941  ld L,(0x10d0)
	and	l, 15	; F71945  and L,0x0f
	ld	xiy, ByteMap_F7091E	; F71948  ld XIY,0x00f7091e
	cp	(0x1239:16), 0xff	; F7194D  cp (0x1239),0xff
	jr	z, SmfCC_GeneralPurpose1_Skip	; F71952  jr Z,0xf71959
	ld	xiy, ByteMap_F7091E + 0x20	; F71954  ld XIY,0x00f7093e
SmfCC_GeneralPurpose1_Skip:
	ld	l, (xiy+hl)	; F71959  ld L,(XIY+HL)
	ld	(4526:16), l	; F7195E  ld (0x11ae),L
	ld	a, (4306:16)	; F71962  ld A,(0x10d2)
	ld	(4527:16), a	; F71966  ld (0x11af),A
	ld	(4528:16), 127	; F7196A  ld (0x11b0),0x7f
	ld	(4993:16), 184	; F7196F  ld (0x1381),0xb8
	calr	SmfCC_PutParamEventWithNumber	; F71974  calr 0xf71a95
	ret	; F71977  ret

; --------------------------------------------------------------------------
; SmfCC_GeneralPurpose2
; Called from: in-module: 0xF7043C 0xF722D0
; Touches: (0x10D0) (0x10D2) (0x11AE) (0x11AF) (0x11B0) (0x1239) (0x1381)
; Calls:   SmfCC_PutParamEventWithNumber
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF71978 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_GeneralPurpose2: SmfEvent_ControlChange's arm for MIDI controller 17 (`cp a,17 / jr z`).
SmfCC_GeneralPurpose2:
	xor	h, h	; F71978  xor H,H
	ld	l, (Smf_EventStatus:16)	; F7197A  ld L,(0x10d0)
	and	l, 15	; F7197E  and L,0x0f
	ld	xiy, ByteMap_F7091E	; F71981  ld XIY,0x00f7091e
	cp	(0x1239:16), 0xff	; F71986  cp (0x1239),0xff
	jr	z, SmfCC_GeneralPurpose2_Skip	; F7198B  jr Z,0xf71992
	ld	xiy, ByteMap_F7091E + 0x20	; F7198D  ld XIY,0x00f7093e
SmfCC_GeneralPurpose2_Skip:
	ld	l, (xiy+hl)	; F71992  ld L,(XIY+HL)
	ld	(4526:16), l	; F71997  ld (0x11ae),L
	ld	a, (4306:16)	; F7199B  ld A,(0x10d2)
	ld	(4527:16), a	; F7199F  ld (0x11af),A
	ld	(4528:16), 127	; F719A3  ld (0x11b0),0x7f
	ld	(4993:16), 185	; F719A8  ld (0x1381),0xb9
	calr	SmfCC_PutParamEventWithNumber	; F719AD  calr 0xf71a95
	ret	; F719B0  ret

; --------------------------------------------------------------------------
; SmfCC_GeneralPurpose3
; Called from: in-module: 0xF70441 0xF722D5
; Touches: (0x10D0) (0x10D2) (0x11AE) (0x11AF) (0x11B0) (0x1239) (0x1381)
; Calls:   SmfCC_PutParamEventWithNumber
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF719B1 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_GeneralPurpose3: SmfEvent_ControlChange's arm for MIDI controller 18 (`cp a,18 / jr z`).
SmfCC_GeneralPurpose3:
	xor	h, h	; F719B1  xor H,H
	ld	l, (Smf_EventStatus:16)	; F719B3  ld L,(0x10d0)
	and	l, 15	; F719B7  and L,0x0f
	ld	xiy, ByteMap_F7091E	; F719BA  ld XIY,0x00f7091e
	cp	(0x1239:16), 0xff	; F719BF  cp (0x1239),0xff
	jr	z, SmfCC_GeneralPurpose3_Skip	; F719C4  jr Z,0xf719cb
	ld	xiy, ByteMap_F7091E + 0x20	; F719C6  ld XIY,0x00f7093e
SmfCC_GeneralPurpose3_Skip:
	ld	l, (xiy+hl)	; F719CB  ld L,(XIY+HL)
	ld	(4526:16), l	; F719D0  ld (0x11ae),L
	ld	a, (4306:16)	; F719D4  ld A,(0x10d2)
	ld	(4527:16), a	; F719D8  ld (0x11af),A
	ld	(4528:16), 127	; F719DC  ld (0x11b0),0x7f
	ld	(4993:16), 186	; F719E1  ld (0x1381),0xba
	calr	SmfCC_PutParamEventWithNumber	; F719E6  calr 0xf71a95
	ret	; F719E9  ret

; --------------------------------------------------------------------------
; SmfCC_GeneralPurpose4
; Called from: in-module: 0xF70446 0xF722DA
; Touches: (0x10D0) (0x10D2) (0x11AE) (0x11AF) (0x11B0) (0x1239) (0x1381)
; Calls:   SmfCC_PutParamEventWithNumber
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF719EA is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_GeneralPurpose4: SmfEvent_ControlChange's arm for MIDI controller 19 (`cp a,19 / jr z`).
SmfCC_GeneralPurpose4:
	xor	h, h	; F719EA  xor H,H
	ld	l, (Smf_EventStatus:16)	; F719EC  ld L,(0x10d0)
	and	l, 15	; F719F0  and L,0x0f
	ld	xiy, ByteMap_F7091E	; F719F3  ld XIY,0x00f7091e
	cp	(0x1239:16), 0xff	; F719F8  cp (0x1239),0xff
	jr	z, SmfCC_GeneralPurpose4_Skip	; F719FD  jr Z,0xf71a04
	ld	xiy, ByteMap_F7091E + 0x20	; F719FF  ld XIY,0x00f7093e
SmfCC_GeneralPurpose4_Skip:
	ld	l, (xiy+hl)	; F71A04  ld L,(XIY+HL)
	ld	(4526:16), l	; F71A09  ld (0x11ae),L
	ld	a, (4306:16)	; F71A0D  ld A,(0x10d2)
	ld	(4527:16), a	; F71A11  ld (0x11af),A
	ld	(4528:16), 127	; F71A15  ld (0x11b0),0x7f
	ld	(4993:16), 187	; F71A1A  ld (0x1381),0xbb
	calr	SmfCC_PutParamEventWithNumber	; F71A1F  calr 0xf71a95
	ret	; F71A22  ret

; --------------------------------------------------------------------------
; SmfCC_Breath
; Called from: no thunk slot and no in-module call or jp site -- reached
;              only by a branch from the routine above, or through a table
; Touches: (0x10D0) (0x10D2) (0x11AE) (0x11AF) (0x11B0) (0x1239) (0x1381)
; Calls:   SmfCC_PutParamEventWithNumber
; Evidence (TABLE): it is an entry of a pointer table the consumer rule
;                   classed TRANSFER: the code that indexes that table
;                   fetches the entry and then transfers to it.  This module
;                   has two such tables, both of 16 entries, at 0xF7048D and
;                   0xF72323.  0xF71A23 is an instruction boundary of this
;                   transcription, re-asserted on every emit.  The name IS
;                   the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_Breath: DispatchTable_F7048D[2]: SmfEvent_ControlChange's handler for MIDI controller 2.
SmfCC_Breath:
	xor	h, h	; F71A23  xor H,H
	ld	l, (Smf_EventStatus:16)	; F71A25  ld L,(0x10d0)
	and	l, 15	; F71A29  and L,0x0f
	ld	xiy, ByteMap_F7091E	; F71A2C  ld XIY,0x00f7091e
	cp	(0x1239:16), 0xff	; F71A31  cp (0x1239),0xff
	jr	z, SmfCC_Breath_Skip2	; F71A36  jr Z,0xf71a3d
	ld	xiy, ByteMap_F7091E + 0x20	; F71A38  ld XIY,0x00f7093e
SmfCC_Breath_Skip2:
	ld	l, (xiy+hl)	; F71A3D  ld L,(XIY+HL)
	ld	(4526:16), l	; F71A42  ld (0x11ae),L
	ld	a, (4306:16)	; F71A46  ld A,(0x10d2)
	ld	(4527:16), a	; F71A4A  ld (0x11af),A
	ld	(4528:16), 127	; F71A4E  ld (0x11b0),0x7f
	ld	(4993:16), 188	; F71A53  ld (0x1381),0xbc
	calr	SmfCC_PutParamEventWithNumber	; F71A58  calr 0xf71a95
	ret	; F71A5B  ret

; --------------------------------------------------------------------------
; SmfCC_Foot
; Called from: no thunk slot and no in-module call or jp site -- reached
;              only by a branch from the routine above, or through a table
; Touches: (0x10D0) (0x10D2) (0x11AE) (0x11AF) (0x11B0) (0x1239) (0x1381)
; Calls:   SmfCC_PutParamEventWithNumber
; Evidence (TABLE): it is an entry of a pointer table the consumer rule
;                   classed TRANSFER: the code that indexes that table
;                   fetches the entry and then transfers to it.  This module
;                   has two such tables, both of 16 entries, at 0xF7048D and
;                   0xF72323.  0xF71A5C is an instruction boundary of this
;                   transcription, re-asserted on every emit.  The name IS
;                   the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_Foot: DispatchTable_F7048D[4]: SmfEvent_ControlChange's handler for MIDI controller 4.
SmfCC_Foot:
	xor	h, h	; F71A5C  xor H,H
	ld	l, (Smf_EventStatus:16)	; F71A5E  ld L,(0x10d0)
	and	l, 15	; F71A62  and L,0x0f
	ld	xiy, ByteMap_F7091E	; F71A65  ld XIY,0x00f7091e
	cp	(0x1239:16), 0xff	; F71A6A  cp (0x1239),0xff
	jr	z, SmfCC_Foot_Skip3	; F71A6F  jr Z,0xf71a76
	ld	xiy, ByteMap_F7091E + 0x20	; F71A71  ld XIY,0x00f7093e
SmfCC_Foot_Skip3:
	ld	l, (xiy+hl)	; F71A76  ld L,(XIY+HL)
	ld	(4526:16), l	; F71A7B  ld (0x11ae),L
	ld	a, (4306:16)	; F71A7F  ld A,(0x10d2)
	ld	(4527:16), a	; F71A83  ld (0x11af),A
	ld	(4528:16), 127	; F71A87  ld (0x11b0),0x7f
	ld	(4993:16), 189	; F71A8C  ld (0x1381),0xbd
	calr	SmfCC_PutParamEventWithNumber	; F71A91  calr 0xf71a95
	ret	; F71A94  ret

; --------------------------------------------------------------------------
; SmfCC_PutParamEventWithNumber
; Called from: in-module: 0xF71974 0xF719AD 0xF719E6 0xF71A1F 0xF71A58
;              0xF71A91
; Touches: (0x1078) (0x107A) (0x10D0) (0x11AE) (0x11AF) (0x11B0) (0x11B2)
;          (0x1238) (0x1381)
; Calls:   Smf_ClampTrackToSlot TrackCursor_Load BStore_PutByteAndAdvance Smf_TicksToPpq96 SmfEvent_MarkChannelUsed TrackCursor_Save
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF71A95 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_PutParamEventWithNumber: Unless (0x11AE)=0xFF, stores in the channel's track (multi-track: the slot of
;   (0x11B2)) the 0xB0 parameter event {0xB0 | (bit 7 of (0x1381))>>5, tick, (0x1381)&0x7F, (0x11AE), (0x11AF)&0x7F,
;   (0x11B0)} and marks the channel. The parameter number comes from (0x1381); its six callers (GP1-4, Breath, Foot)
;   set 0xB8..0xBD with class = the channel's part. Basis: callers + body. (wsa1/notes/naming-
;   pilot-2026-10-06/proposals_prom_b.json)
SmfCC_PutParamEventWithNumber:
	push	xiy	; F71A95  push XIY
	cp	(0x11ae:16), 0xff	; F71A96  cp (0x11ae),0xff
	jrl	z, SmfCC_PutParamEventWithNumber_Epilogue	; F71A9B  jrl Z,0xf71b80
	ld	iy, (Smf_EventStatus:16)	; F71A9E  ld IY,(0x10d0)
	and	iy, 15	; F71AA2  and IY,0x000f
	cp	(Smf_Format:16), 0x00	; F71AA6  cp (0x1078),0x00
	jr	z, SmfCC_PutParamEventWithNumber_Skip	; F71AAB  jr Z,0xf71abc
	cp	(Smf_TrackCount:16), 0x02	; F71AAD  cp (0x107a),0x02
	jr	lt, SmfCC_PutParamEventWithNumber_Skip	; F71AB2  jr LT,0xf71abc
	ld	iy, (4530:16)	; F71AB4  ld IY,(0x11b2)
	call	Smf_ClampTrackToSlot	; F71AB8  call 0xf70c3f
SmfCC_PutParamEventWithNumber_Skip:
	push	xiy	; F71ABC  push XIY
	pushw	bc	; F71ABD  push BC
	call	TrackCursor_Load	; F71ABE  call 0xf7124e
	popw	bc	; F71AC2  pop BC
	pop	xiy	; F71AC3  pop XIY
	ld	a, 176:opc	; F71AC4  ld A,0xb0
	ld	w, (4993:16)	; F71AC6  ld W,(0x1381)
	and	w, 128	; F71ACA  and W,0x80
	srl	w, 5	; F71ACD  srl 0x05,W
	or	a, w	; F71AD0  or A,W
	push	xiy	; F71AD2  push XIY
	pushw	bc	; F71AD3  push BC
	call	BStore_PutByteAndAdvance	; F71AD4  call 0xf70fda
	popw	bc	; F71AD8  pop BC
	pop	xiy	; F71AD9  pop XIY
	cp	(0x1238:16), 0x00	; F71ADA  cp (0x1238),0x00
	jrl	nz, SmfCC_PutParamEventWithNumber_Epilogue	; F71ADF  jrl NZ,0xf71b80
	sla	iy, 1	; F71AE2  sla 0x01,IY
	push	xde	; F71AE5  push XDE
	ld	xde, 4307	; F71AE6  ld XDE,0x000010d3
	ld	wa, (xde+iy)	; F71AEB  ld WA,(XDE+IY)
	pop	xde	; F71AF0  pop XDE
	sra	iy, 1	; F71AF1  sra 0x01,IY
	pushw	bc	; F71AF4  push BC
	push	xiy	; F71AF5  push XIY
	call	Smf_TicksToPpq96	; F71AF6  call 0xf7122f
	call	BStore_PutByteAndAdvance	; F71AFA  call 0xf70fda
	pop	xiy	; F71AFE  pop XIY
	popw	bc	; F71AFF  pop BC
	cp	(0x1238:16), 0x00	; F71B00  cp (0x1238),0x00
	jrl	nz, SmfCC_PutParamEventWithNumber_Epilogue	; F71B05  jrl NZ,0xf71b80
	ld	a, (4993:16)	; F71B08  ld A,(0x1381)
	and	a, 127	; F71B0C  and A,0x7f
	push	xiy	; F71B0F  push XIY
	call	BStore_PutByteAndAdvance	; F71B10  call 0xf70fda
	pop	xiy	; F71B14  pop XIY
	cp	(0x1238:16), 0x00	; F71B15  cp (0x1238),0x00
	jrl	nz, SmfCC_PutParamEventWithNumber_Epilogue	; F71B1A  jrl NZ,0xf71b80
	pop	xiy	; F71B1D  pop XIY
	push	xiy	; F71B1E  push XIY
	ld	a, (4526:16)	; F71B1F  ld A,(0x11ae)
	push	xiy	; F71B23  push XIY
	call	BStore_PutByteAndAdvance	; F71B24  call 0xf70fda
	pop	xiy	; F71B28  pop XIY
	cp	(0x1238:16), 0x00	; F71B29  cp (0x1238),0x00
	jr	nz, SmfCC_PutParamEventWithNumber_Epilogue	; F71B2E  jr NZ,0xf71b80
	ld	a, (4527:16)	; F71B30  ld A,(0x11af)
	and	a, 127	; F71B34  and A,0x7f
	push	xiy	; F71B37  push XIY
	call	BStore_PutByteAndAdvance	; F71B38  call 0xf70fda
	pop	xiy	; F71B3C  pop XIY
	cp	(0x1238:16), 0x00	; F71B3D  cp (0x1238),0x00
	jr	nz, SmfCC_PutParamEventWithNumber_Epilogue	; F71B42  jr NZ,0xf71b80
	ld	a, (4528:16)	; F71B44  ld A,(0x11b0)
	push	xiy	; F71B48  push XIY
	call	BStore_PutByteAndAdvance	; F71B49  call 0xf70fda
	pop	xiy	; F71B4D  pop XIY
	cp	(0x1238:16), 0x00	; F71B4E  cp (0x1238),0x00
	jr	nz, SmfCC_PutParamEventWithNumber_Epilogue	; F71B53  jr NZ,0xf71b80
	call	SmfEvent_MarkChannelUsed	; F71B55  call 0xf7129a
	ld	iy, (Smf_EventStatus:16)	; F71B59  ld IY,(0x10d0)
	and	iy, 15	; F71B5D  and IY,0x000f
	cp	(Smf_Format:16), 0x00	; F71B61  cp (0x1078),0x00
	jr	z, SmfCC_PutParamEventWithNumber_Skip2	; F71B66  jr Z,0xf71b77
	cp	(Smf_TrackCount:16), 0x02	; F71B68  cp (0x107a),0x02
	jr	lt, SmfCC_PutParamEventWithNumber_Skip2	; F71B6D  jr LT,0xf71b77
	ld	iy, (4530:16)	; F71B6F  ld IY,(0x11b2)
	call	Smf_ClampTrackToSlot	; F71B73  call 0xf70c3f
SmfCC_PutParamEventWithNumber_Skip2:
	call	TrackCursor_Save	; F71B77  call 0xf71275
	ld	(4664:16), 0	; F71B7B  ld (0x1238),0x00
SmfCC_PutParamEventWithNumber_Epilogue:
	pop	xiy	; F71B80  pop XIY
	ret	; F71B81  ret

; --------------------------------------------------------------------------
; Smf_ReadMultiTrack
; Called from: in-module: 0xF6F637
; Touches: (0x1010) (0x107A) (0x10CB) (0x11B2) (0x1239) (0x124B) (0x360C)
; Calls:   T_Seq_RequestRewind T_SongClear_ClearCurrentBank Smf_AllocFirstBlockForTrackSlot Smf_ClearPendingNoteSlots ClearRam10D3_34Bytes_Copy Smf_ClearChannelBankSelects
;          Smf_ReadTrackChunk InputStream_RefillDone Smf_MergeTrack2IntoTrack1 Smf_SplitTrack1ByChannel Smf_ResetTrackAssignToIdentity
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF71B82 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_ReadMultiTrack: Smf_ReadFile's branch for format 1 with more than one track (cp (Smf_Format),1 / cp (Smf_TrackCount),1 at 0xF6F626):
;     for track (0x11B2) = 0 .. Smf_TrackCount-1, Smf_ReadTrackChunk and Smf_MergeTrack2IntoTrack1; then Smf_SplitTrack1ByChannel.
Smf_ReadMultiTrack:
	xor	a, a	; F71B82  xor A,A
	ld	(4665:16), a	; F71B84  ld (0x1239),A
	ld	(4683:16), a	; F71B88  ld (0x124b),A
	call	T_Seq_RequestRewind	; F71B8C  call 0xf409e0
	call	T_SongClear_ClearCurrentBank	; F71B90  call 0xf42708
	xor	xwa, xwa	; F71B94  xor XWA,XWA
	ld	(6304798:24), xwa	; F71B96  ld (0x60341e),XWA
	ld	(13836:16), xwa	; F71B9B  ld (0x360c),XWA
	ld	(4530:16), wa	; F71B9F  ld (0x11b2),WA
Smf_ReadMultiTrack_Loop:
	ld	(4299:16), 0	; F71BA3  ld (0x10cb),0x00
	calr	Smf_AllocFirstBlockForTrackSlot	; F71BA8  calr 0xf72822
	calr	Smf_ClearPendingNoteSlots	; F71BAB  calr 0xf6fb38
	calr	ClearRam10D3_34Bytes_Copy	; F71BAE  calr 0xf71d4f
	call	Smf_ClearChannelBankSelects	; F71BB1  call 0xf6f929
	calr	Smf_ReadTrackChunk	; F71BB5  calr 0xf71bea
	cp	(0x1010:16), 0x00	; F71BB8  cp (0x1010),0x00
	jr	z, Smf_ReadMultiTrack_Skip	; F71BBD  jr Z,0xf71bc4
	calr	InputStream_RefillDone	; F71BBF  calr 0xf765de
	jr	Smf_ReadMultiTrack_Return	; F71BC2  jr T,0xf71be5
Smf_ReadMultiTrack_Skip:
	calr	Smf_MergeTrack2IntoTrack1	; F71BC4  calr 0xf729d9
	incw	1, (4530:16)	; F71BC7  incw 1,(0x11b2)
	ld	wa, (4530:16)	; F71BCB  ld WA,(0x11b2)
	cp	wa, (Smf_TrackCount:16)	; F71BCF  cp WA,(0x107a)
	jr	c, Smf_ReadMultiTrack_Loop	; F71BD3  jr C,0xf71ba3
	calr	InputStream_RefillDone	; F71BD5  calr 0xf765de
	cp	(0x1010:16), 0x00	; F71BD8  cp (0x1010),0x00
	jr	nz, Smf_ReadMultiTrack_Return	; F71BDD  jr NZ,0xf71be5
	calr	Smf_SplitTrack1ByChannel	; F71BDF  calr 0xf72f5c
	calr	Smf_ResetTrackAssignToIdentity	; F71BE2  calr 0xf6f94e
Smf_ReadMultiTrack_Return:
	ret	; F71BE5  ret

; --------------------------------------------------------------------------
; SmfTrackTag -- 4 bytes this block could not split.  No content rule framed
;                it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or ASCII
;                -- and the code walk never reached it from a thunk slot, a
;                proven call site, an opcode-anchored call or an entry of a
;                table the firmware transfers to.  So it is emitted as bytes
;                rather than guessed.
; Contains: printable bytes |MTrk|
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XIY,0x00f71be6` at
;          0xF71BED (operand field 1 byte in)
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; Unknown: everything about it except its bytes.
; --------------------------------------------------------------------------
; SmfTrackTag: "MTrk", the track-chunk tag Smf_ReadTrackChunk compares (the multi-track path's own copy of SmfChunkTags+4).
SmfTrackTag:
	.ascii	"MTrk"	; F71BE6  [0..3]


; --------------------------------------------------------------------------
; Smf_ReadTrackChunk
; Called from: in-module: 0xF71BB5
; Touches: (0x1010) (0x10CB) (0x11B1) (0x11B2) (0x1238) (0x124A) (0x2880)
; Calls:   InputStream_GetByte Smf_ReadVlqBytes_Copy Smf_DecodeVlq Smf_TrackToSlot Smf_ApplyDeltaTime Smf_AddDeltaToHeldNotes
;          SmfEvent_Meta Smf_TerminateTrackSlot SmfEvent_SysEx SmfEvent_ReadWithNewStatus_MultiTrack SmfEvent_ReadWithRunningStatus
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF71BEA is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_ReadTrackChunk: one MTrk chunk of the multi-track path: compares the 4 tag bytes at Data_F71BE6 (UI_StatusCode 49 on a mismatch), reads the
;     length into SmfOut_TrackLength, then loops delta (Smf_ReadVlqBytes_Copy / Smf_DecodeVlq) and event: 0xFF SmfEvent_Meta,
;     0xF0 / 0xF7 SmfEvent_SysEx, running status SmfEvent_ReadWithRunningStatus, new status SmfEvent_ReadWithNewStatus_MultiTrack.
Smf_ReadTrackChunk:
	ldw	bc, 4	; F71BEA  ld BC,0x0004
	ld	xiy, SmfTrackTag	; F71BED  ld XIY,0x00f71be6
	pushw	bc	; F71BF2  push BC
	push	xiy	; F71BF3  push XIY
	calr	InputStream_GetByte	; F71BF4  calr 0xf7138f
	pop	xiy	; F71BF7  pop XIY
	popw	bc	; F71BF8  pop BC
	ld	w, (InputStream_Status:16)	; F71BF9  ld W,(0x124a)
	cp	w, 1:i3	; F71BFD  cp W,1
	jr	z, Smf_ReadTrackChunk_Skip	; F71BFF  jr Z,0xf71c0e
	cp	w, 253	; F71C01  cp W,0xfd
	jr	z, Smf_ReadTrackChunk_Skip	; F71C04  jr Z,0xf71c0e
	ld	(4112:16), 255	; F71C06  ld (0x1010),0xff
	jrl	Smf_ReadTrackChunk_Return	; F71C0B  jrl T,0xf71d4e
Smf_ReadTrackChunk_Skip:
	cp	a, (xiy+)	; F71C0E  cp A,(XIY+)
	jr	z, Smf_ReadTrackChunk_Skip2	; F71C11  jr Z,0xf71c20
	ld	(4112:16), 255	; F71C13  ld (0x1010),0xff
	ld	(UI_StatusCode:16), 49	; F71C18  ld (0x2880),0x31
	jrl	Smf_ReadTrackChunk_Return	; F71C1D  jrl T,0xf71d4e
Smf_ReadTrackChunk_Skip2:
	djnz16	bc, -49	; F71C20  djnz BC,0xf71bf2
	ld	xix, SmfOut_TrackLength	; F71C23  ld XIX,0x000010c4
	ldw	bc, 4	; F71C28  ld BC,0x0004
	pushw	bc	; F71C2B  push BC
	push	xix	; F71C2C  push XIX
	calr	InputStream_GetByte	; F71C2D  calr 0xf7138f
	pop	xix	; F71C30  pop XIX
	popw	bc	; F71C31  pop BC
	ld	w, (InputStream_Status:16)	; F71C32  ld W,(0x124a)
	cp	w, 1:i3	; F71C36  cp W,1
	jr	z, Smf_ReadTrackChunk_Skip3	; F71C38  jr Z,0xf71c47
	cp	w, 253	; F71C3A  cp W,0xfd
	jr	z, Smf_ReadTrackChunk_Skip3	; F71C3D  jr Z,0xf71c47
	ld	(4112:16), 255	; F71C3F  ld (0x1010),0xff
	jrl	Smf_ReadTrackChunk_Return	; F71C44  jrl T,0xf71d4e
Smf_ReadTrackChunk_Skip3:
	ld	(xix+), a	; F71C47  ld (XIX+),A
	djnz16	bc, -34	; F71C4A  djnz BC,0xf71c2b
	ld	(4529:16), 0	; F71C4D  ld (0x11b1),0x00
Smf_ReadTrackChunk_Loop:
	cp	(0x1238:16), 0x00	; F71C52  cp (0x1238),0x00
	jrl	nz, Smf_ReadTrackChunk_Join	; F71C57  jrl NZ,0xf71d29
	ld	w, (InputStream_Status:16)	; F71C5A  ld W,(0x124a)
	cp	w, 1:i3	; F71C5E  cp W,1
	jr	z, Smf_ReadTrackChunk_Skip4	; F71C60  jr Z,0xf71c6f
	cp	w, 253	; F71C62  cp W,0xfd
	jr	z, Smf_ReadTrackChunk_Skip4	; F71C65  jr Z,0xf71c6f
	ld	(4112:16), 255	; F71C67  ld (0x1010),0xff
	jrl	Smf_ReadTrackChunk_Return	; F71C6C  jrl T,0xf71d4e
Smf_ReadTrackChunk_Skip4:
	calr	Smf_ReadVlqBytes_Copy	; F71C6F  calr 0xf71369
	ld	w, (InputStream_Status:16)	; F71C72  ld W,(0x124a)
	cp	w, 1:i3	; F71C76  cp W,1
	jr	z, Smf_ReadTrackChunk_Skip5	; F71C78  jr Z,0xf71c87
	cp	w, 253	; F71C7A  cp W,0xfd
	jr	z, Smf_ReadTrackChunk_Skip5	; F71C7D  jr Z,0xf71c87
	ld	(4112:16), 255	; F71C7F  ld (0x1010),0xff
	jrl	Smf_ReadTrackChunk_Return	; F71C84  jrl T,0xf71d4e
Smf_ReadTrackChunk_Skip5:
	calr	Smf_DecodeVlq	; F71C87  calr 0xf6fe1b
	ld	iy, (4530:16)	; F71C8A  ld IY,(0x11b2)
	calr	Smf_TrackToSlot	; F71C8E  calr 0xf728fe
	calr	Smf_ApplyDeltaTime	; F71C91  calr 0xf710e7
	calr	Smf_AddDeltaToHeldNotes	; F71C94  calr 0xf712b6
	calr	InputStream_GetByte	; F71C97  calr 0xf7138f
	ld	w, (InputStream_Status:16)	; F71C9A  ld W,(0x124a)
	cp	w, 1:i3	; F71C9E  cp W,1
	jr	z, Smf_ReadTrackChunk_Skip6	; F71CA0  jr Z,0xf71caf
	cp	w, 253	; F71CA2  cp W,0xfd
	jr	z, Smf_ReadTrackChunk_Skip6	; F71CA5  jr Z,0xf71caf
	ld	(4112:16), 255	; F71CA7  ld (0x1010),0xff
	jrl	Smf_ReadTrackChunk_Return	; F71CAC  jrl T,0xf71d4e
Smf_ReadTrackChunk_Skip6:
	cp	a, 255	; F71CAF  cp A,0xff
	jr	nz, Smf_ReadTrackChunk_Skip9	; F71CB2  jr NZ,0xf71ce7
	calr	SmfEvent_Meta	; F71CB4  calr 0xf6fb51
	ld	w, (InputStream_Status:16)	; F71CB7  ld W,(0x124a)
	cp	w, 1:i3	; F71CBB  cp W,1
	jr	z, Smf_ReadTrackChunk_Skip7	; F71CBD  jr Z,0xf71ccc
	cp	w, 253	; F71CBF  cp W,0xfd
	jr	z, Smf_ReadTrackChunk_Skip7	; F71CC2  jr Z,0xf71ccc
	ld	(4112:16), 255	; F71CC4  ld (0x1010),0xff
	jrl	Smf_ReadTrackChunk_Return	; F71CC9  jrl T,0xf71d4e
Smf_ReadTrackChunk_Skip7:
	cp	(0x10cb:16), 0xff	; F71CCC  cp (0x10cb),0xff
	jr	z, Smf_ReadTrackChunk_Skip8	; F71CD1  jr Z,0xf71ce2
	cp	(0x1238:16), 0x00	; F71CD3  cp (0x1238),0x00
	jrl	z, Smf_ReadTrackChunk_Loop	; F71CD8  jrl Z,0xf71c52
	ld	(4112:16), 255	; F71CDB  ld (0x1010),0xff
	jr	Smf_ReadTrackChunk_Join	; F71CE0  jr T,0xf71d29
Smf_ReadTrackChunk_Skip8:
	calr	Smf_TerminateTrackSlot	; F71CE2  calr 0xf728a3
	jr	Smf_ReadTrackChunk_Return	; F71CE5  jr T,0xf71d4e
Smf_ReadTrackChunk_Skip9:
	cp	a, 247	; F71CE7  cp A,0xf7
	jr	z, Smf_ReadTrackChunk_Skip10	; F71CEA  jr Z,0xf71cf1
	cp	a, 240	; F71CEC  cp A,0xf0
	jr	nz, Smf_ReadTrackChunk_Skip12	; F71CEF  jr NZ,0xf71d0b
Smf_ReadTrackChunk_Skip10:
	calr	SmfEvent_SysEx	; F71CF1  calr 0xf71525
	ld	w, (InputStream_Status:16)	; F71CF4  ld W,(0x124a)
	cp	w, 1:i3	; F71CF8  cp W,1
	jr	z, Smf_ReadTrackChunk_Skip11	; F71CFA  jr Z,0xf71d08
	cp	w, 253	; F71CFC  cp W,0xfd
	jr	z, Smf_ReadTrackChunk_Skip11	; F71CFF  jr Z,0xf71d08
	ld	(4112:16), 255	; F71D01  ld (0x1010),0xff
	jr	Smf_ReadTrackChunk_Return	; F71D06  jr T,0xf71d4e
Smf_ReadTrackChunk_Skip11:
	jrl	Smf_ReadTrackChunk_Loop	; F71D08  jrl T,0xf71c52
Smf_ReadTrackChunk_Skip12:
	bit	7, a	; F71D0B  bit 0x07,A
	jr	z, Smf_ReadTrackChunk_Skip13	; F71D0E  jr Z,0xf71d30
	calr	SmfEvent_ReadWithNewStatus_MultiTrack	; F71D10  calr 0xf71d71
	cp	(0x1238:16), 0x00	; F71D13  cp (0x1238),0x00
	jr	nz, Smf_ReadTrackChunk_Join	; F71D18  jr NZ,0xf71d29
	ld	w, (InputStream_Status:16)	; F71D1A  ld W,(0x124a)
	cp	w, 1:i3	; F71D1E  cp W,1
	jrl	z, Smf_ReadTrackChunk_Loop	; F71D20  jrl Z,0xf71c52
	cp	w, 253	; F71D23  cp W,0xfd
	jrl	z, Smf_ReadTrackChunk_Loop	; F71D26  jrl Z,0xf71c52
Smf_ReadTrackChunk_Join:
	ld	(4112:16), 255	; F71D29  ld (0x1010),0xff
	jr	Smf_ReadTrackChunk_Return	; F71D2E  jr T,0xf71d4e
Smf_ReadTrackChunk_Skip13:
	calr	SmfEvent_ReadWithRunningStatus	; F71D30  calr 0xf6fea1
	cp	(0x1238:16), 0x00	; F71D33  cp (0x1238),0x00
	jr	nz, Smf_ReadTrackChunk_Skip14	; F71D38  jr NZ,0xf71d49
	ld	w, (InputStream_Status:16)	; F71D3A  ld W,(0x124a)
	cp	w, 1:i3	; F71D3E  cp W,1
	jrl	z, Smf_ReadTrackChunk_Loop	; F71D40  jrl Z,0xf71c52
	cp	w, 253	; F71D43  cp W,0xfd
	jrl	z, Smf_ReadTrackChunk_Loop	; F71D46  jrl Z,0xf71c52
Smf_ReadTrackChunk_Skip14:
	ld	(4112:16), 255	; F71D49  ld (0x1010),0xff
Smf_ReadTrackChunk_Return:
	ret	; F71D4E  ret

; --------------------------------------------------------------------------
; ClearRam10D3_34Bytes_Copy
; Called from: in-module: 0xF71BAE
; Touches: (0x1198) (0x119A)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF71D4F is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClearRam10D3_34Bytes_Copy: an exact copy of ClearRam10D3_34Bytes (prom_b 0xF6F9C7) -- all 12 instructions equal, operands included,
;   but the targets of its jr / jrl / djnz (notes/wsa1_exact_copy_names.py).
ClearRam10D3_34Bytes_Copy:
	pushw	wa	; F71D4F  push WA
	pushw	bc	; F71D50  push BC
	push	xix	; F71D51  push XIX
	xor	wa, wa	; F71D52  xor WA,WA
	ldw	bc, 17	; F71D54  ld BC,0x0011
	ld	xix, 4307	; F71D57  ld XIX,0x000010d3
	ld	(xix+), wa	; F71D5C  ld (XIX+),WA
	djnz16	bc, -6	; F71D5F  djnz BC,0xf71d5c
	pop	xix	; F71D62  pop XIX
	popw	bc	; F71D63  pop BC
	popw	wa	; F71D64  pop WA
	ret	; F71D65  ret
	xor	wa, wa	; F71D66  xor WA,WA
	ld	(Smf_VlqValue:16), wa	; F71D68  ld (0x1198),WA
	ld	(4506:16), wa	; F71D6C  ld (0x119a),WA
	ret	; F71D70  ret

; --------------------------------------------------------------------------
; SmfEvent_ReadWithNewStatus_MultiTrack
; Called from: in-module: 0xF71D10
; Touches: (0x10CC) (0x124A)
; Calls:   InputStream_GetByte SmfEvent_DispatchChannelMessage_MultiTrack
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF71D71 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_ReadWithNewStatus_MultiTrack: the multi-track copy of SmfEvent_ReadWithNewStatus: Smf_RunningStatus = A, one data byte for 0xC0 / 0xD0 and two
;     otherwise, then SmfEvent_DispatchChannelMessage_MultiTrack.
SmfEvent_ReadWithNewStatus_MultiTrack:
	ld	(Smf_RunningStatus:16), a	; F71D71  ld (0x10cc),A
	xor	bc, bc	; F71D75  xor BC,BC
	ld	xix, Smf_EventStatus	; F71D77  ld XIX,0x000010d0
	ld	(xix+), a	; F71D7C  ld (XIX+),A
	inc	1, c	; F71D7F  inc 1,C
SmfEvent_ReadWithNewStatus_MultiTrack_Loop:
	pushw	bc	; F71D81  push BC
	push	xix	; F71D82  push XIX
	calr	InputStream_GetByte	; F71D83  calr 0xf7138f
	pop	xix	; F71D86  pop XIX
	popw	bc	; F71D87  pop BC
	ld	w, (InputStream_Status:16)	; F71D88  ld W,(0x124a)
	cp	w, 1:i3	; F71D8C  cp W,1
	jr	z, SmfEvent_ReadWithNewStatus_MultiTrack_Skip	; F71D8E  jr Z,0xf71d95
	cp	w, 253	; F71D90  cp W,0xfd
	jr	nz, SmfEvent_ReadWithNewStatus_MultiTrack_Return	; F71D93  jr NZ,0xf71db6
SmfEvent_ReadWithNewStatus_MultiTrack_Skip:
	ld	(xix+), a	; F71D95  ld (XIX+),A
	inc	1, c	; F71D98  inc 1,C
	ld	a, (Smf_RunningStatus:16)	; F71D9A  ld A,(0x10cc)
	and	a, 240	; F71D9E  and A,0xf0
	ld	w, 2:opc	; F71DA1  ld W,0x02
	cp	a, 208	; F71DA3  cp A,0xd0
	jr	z, SmfEvent_ReadWithNewStatus_MultiTrack_Skip2	; F71DA6  jr Z,0xf71dad
	cp	a, 192	; F71DA8  cp A,0xc0
	jr	nz, SmfEvent_ReadWithNewStatus_MultiTrack_Skip3	; F71DAB  jr NZ,0xf71daf
SmfEvent_ReadWithNewStatus_MultiTrack_Skip2:
	ld	w, 1:opc	; F71DAD  ld W,0x01
SmfEvent_ReadWithNewStatus_MultiTrack_Skip3:
	cp	c, w	; F71DAF  cp C,W
	jr	ule, SmfEvent_ReadWithNewStatus_MultiTrack_Loop	; F71DB1  jr ULE,0xf71d81
	calr	SmfEvent_DispatchChannelMessage_MultiTrack	; F71DB3  calr 0xf71db7
SmfEvent_ReadWithNewStatus_MultiTrack_Return:
	ret	; F71DB6  ret

; --------------------------------------------------------------------------
; SmfEvent_DispatchChannelMessage_MultiTrack
; Called from: in-module: 0xF6FEF5 0xF71DB3
; Touches: (0x10D0) (0x10D1)
; Calls:   SmfEvent_ChannelPressure_MultiTrack 0xF7208D SmfEvent_NoteOff_MultiTrack SmfEvent_ControlChange_MultiTrack SmfEvent_PitchBend_MultiTrack SmfEvent_ProgramChange_MultiTrack
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF71DB7 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_DispatchChannelMessage_MultiTrack: the multi-track copy of SmfEvent_DispatchChannelMessage: by status 0x90 (velocity 0 -> note off), 0x80, 0xB0,
;     0xE0, 0xC0, 0xD0 to the *_MultiTrack handlers.
SmfEvent_DispatchChannelMessage_MultiTrack:
	ld	xix, Smf_EventStatus	; F71DB7  ld XIX,0x000010d0
	ld	a, (Smf_EventStatus:16)	; F71DBC  ld A,(0x10d0)
	pushw	hl	; F71DC0  push HL
	ld	hl, (4305:16)	; F71DC1  ld HL,(0x10d1)
	cp	l, 127	; F71DC5  cp L,0x7f
	jr	ule, SmfEvent_DispatchChannelMessage_MultiTrack_Skip	; F71DC8  jr ULE,0xf71dcc
	ld	l, 127:opc	; F71DCA  ld L,0x7f
SmfEvent_DispatchChannelMessage_MultiTrack_Skip:
	cp	h, 127	; F71DCC  cp H,0x7f
	jr	ule, SmfEvent_DispatchChannelMessage_MultiTrack_Skip2	; F71DCF  jr ULE,0xf71dd3
	ld	h, 127:opc	; F71DD1  ld H,0x7f
SmfEvent_DispatchChannelMessage_MultiTrack_Skip2:
	ld	(4305:16), hl	; F71DD3  ld (0x10d1),HL
	popw	hl	; F71DD7  pop HL
	ld	w, a	; F71DD8  ld W,A
	and	w, 240	; F71DDA  and W,0xf0
	cp	w, 144	; F71DDD  cp W,0x90
	jr	z, SmfEvent_DispatchChannelMessage_MultiTrack_Skip4	; F71DE0  jr Z,0xf71e02
	cp	w, 176	; F71DE2  cp W,0xb0
	jr	z, SmfEvent_DispatchChannelMessage_MultiTrack_Skip6	; F71DE5  jr Z,0xf71e13
	cp	w, 128	; F71DE7  cp W,0x80
	jr	z, SmfEvent_DispatchChannelMessage_MultiTrack_Skip5	; F71DEA  jr Z,0xf71e0e
	cp	w, 224	; F71DEC  cp W,0xe0
	jr	z, SmfEvent_DispatchChannelMessage_MultiTrack_Skip7	; F71DEF  jr Z,0xf71e18
	cp	w, 192	; F71DF1  cp W,0xc0
	jr	z, SmfEvent_DispatchChannelMessage_MultiTrack_Skip8	; F71DF4  jr Z,0xf71e1d
	cp	w, 208	; F71DF6  cp W,0xd0
	jr	z, SmfEvent_DispatchChannelMessage_MultiTrack_Skip3	; F71DF9  jr Z,0xf71dfd
	jr	SmfEvent_DispatchChannelMessage_MultiTrack_Return	; F71DFB  jr T,0xf71e20
SmfEvent_DispatchChannelMessage_MultiTrack_Skip3:
	calr	SmfEvent_ChannelPressure_MultiTrack	; F71DFD  calr 0xf71e21
	jr	SmfEvent_DispatchChannelMessage_MultiTrack_Return	; F71E00  jr T,0xf71e20
SmfEvent_DispatchChannelMessage_MultiTrack_Skip4:
	ld	w, (xix+2)	; F71E02  ld W,(XIX+0x02)
	cp	w, 0:i3	; F71E05  cp W,0
	jr	z, SmfEvent_DispatchChannelMessage_MultiTrack_Skip5	; F71E07  jr Z,0xf71e0e
	calr	SmfEvent_NoteOn_MultiTrack	; F71E09  calr 0xf7208d
	jr	SmfEvent_DispatchChannelMessage_MultiTrack_Return	; F71E0C  jr T,0xf71e20
SmfEvent_DispatchChannelMessage_MultiTrack_Skip5:
	calr	SmfEvent_NoteOff_MultiTrack	; F71E0E  calr 0xf721a3
	jr	SmfEvent_DispatchChannelMessage_MultiTrack_Return	; F71E11  jr T,0xf71e20
SmfEvent_DispatchChannelMessage_MultiTrack_Skip6:
	calr	SmfEvent_ControlChange_MultiTrack	; F71E13  calr 0xf7222d
	jr	SmfEvent_DispatchChannelMessage_MultiTrack_Return	; F71E16  jr T,0xf71e20
SmfEvent_DispatchChannelMessage_MultiTrack_Skip7:
	calr	SmfEvent_PitchBend_MultiTrack	; F71E18  calr 0xf72754
	jr	SmfEvent_DispatchChannelMessage_MultiTrack_Return	; F71E1B  jr T,0xf71e20
SmfEvent_DispatchChannelMessage_MultiTrack_Skip8:
	calr	SmfEvent_ProgramChange_MultiTrack	; F71E1D  calr 0xf71e89
SmfEvent_DispatchChannelMessage_MultiTrack_Return:
	ret	; F71E20  ret

; --------------------------------------------------------------------------
; SmfEvent_ChannelPressure_MultiTrack
; Called from: in-module: 0xF71DFD
; Touches: (0x10D0) (0x10D1) (0x11B2) (0x1238)
; Calls:   Smf_TrackToSlot BStore_LoadTrackCursor BStore_PutByteAndAdvance Smf_TicksToPpq96 SmfEvent_MarkChannelUsed BStore_SaveTrackCursor
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF71E21 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_ChannelPressure_MultiTrack: SmfEvent_DispatchChannelMessage_MultiTrack's arm for status 0xD0; writes 0xA0 | channel, the time and the value into the block store.
SmfEvent_ChannelPressure_MultiTrack:
	ld	iy, (4530:16)	; F71E21  ld IY,(0x11b2)
	extz	xiy	; F71E25  extz XIY
	calr	Smf_TrackToSlot	; F71E27  calr 0xf728fe
	and	xiy, 15	; F71E2A  and XIY,0x0000000f
	push	xiy	; F71E30  push XIY
	calr	BStore_LoadTrackCursor	; F71E31  calr 0xf727c8
	ld	w, (Smf_EventStatus:16)	; F71E34  ld W,(0x10d0)
	and	w, 15	; F71E38  and W,0x0f
	ld	a, 160:opc	; F71E3B  ld A,0xa0
	or	a, w	; F71E3D  or A,W
	calr	BStore_PutByteAndAdvance	; F71E3F  calr 0xf70fda
	pop	xiy	; F71E42  pop XIY
	cp	(0x1238:16), 0x00	; F71E43  cp (0x1238),0x00
	jr	nz, SmfEvent_ChannelPressure_MultiTrack_Return	; F71E48  jr NZ,0xf71e88
	sla	xiy, 1	; F71E4A  sla 0x01,XIY
	push	xix	; F71E4D  push XIX
	ld	xix, 4307	; F71E4E  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F71E53  ld WA,(XIX+IY)
	pop	xix	; F71E58  pop XIX
	srl	xiy, 1	; F71E59  srl 0x01,XIY
	push	xiy	; F71E5C  push XIY
	calr	Smf_TicksToPpq96	; F71E5D  calr 0xf7122f
	pop	xiy	; F71E60  pop XIY
	push	xiy	; F71E61  push XIY
	calr	BStore_PutByteAndAdvance	; F71E62  calr 0xf70fda
	pop	xiy	; F71E65  pop XIY
	cp	(0x1238:16), 0x00	; F71E66  cp (0x1238),0x00
	jr	nz, SmfEvent_ChannelPressure_MultiTrack_Return	; F71E6B  jr NZ,0xf71e88
	ld	a, (4305:16)	; F71E6D  ld A,(0x10d1)
	push	xiy	; F71E71  push XIY
	calr	BStore_PutByteAndAdvance	; F71E72  calr 0xf70fda
	pop	xiy	; F71E75  pop XIY
	cp	(0x1238:16), 0x00	; F71E76  cp (0x1238),0x00
	jr	nz, SmfEvent_ChannelPressure_MultiTrack_Return	; F71E7B  jr NZ,0xf71e88
	calr	SmfEvent_MarkChannelUsed	; F71E7D  calr 0xf7129a
	calr	BStore_SaveTrackCursor	; F71E80  calr 0xf727f6
	ld	(4664:16), 0	; F71E83  ld (0x1238),0x00
SmfEvent_ChannelPressure_MultiTrack_Return:
	ret	; F71E88  ret

; --------------------------------------------------------------------------
; SmfEvent_ProgramChange_MultiTrack
; Called from: in-module: 0xF71E1D
; Touches: (0x10D0) (0x10D1) (0x11B1) (0x11B2) (0x1238) (0x1239) (0x124B)
;          (0x2732)
; Calls:   SmfPart_ResetAllRecords Smf_TrackToSlot SmfPart_SetSoundFromProgramChange T_PartSound_FromProgramChange BStore_LoadTrackCursor BStore_PutByteAndAdvance
;          Smf_TicksToPpq96 SmfEvent_MarkChannelUsed BStore_SaveTrackCursor
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF71E89 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_ProgramChange_MultiTrack: SmfEvent_DispatchChannelMessage_MultiTrack's arm for status 0xC0.
SmfEvent_ProgramChange_MultiTrack:
	bit	0, (0x124b:16)	; F71E89  bit 0,(0x124b)
	jr	nz, SmfEvent_ProgramChange_MultiTrack_Skip2	; F71E8D  jr NZ,0xf71ea9
	ld	(4665:16), 255	; F71E8F  ld (0x1239),0xff
	cp	(0x2732:16), 0x00	; F71E94  cp (0x2732),0x00
	jr	nz, SmfEvent_ProgramChange_MultiTrack_Skip	; F71E99  jr NZ,0xf71ea0
	ld	(4665:16), 0	; F71E9B  ld (0x1239),0x00
SmfEvent_ProgramChange_MultiTrack_Skip:
	ld	(4683:16), 1	; F71EA0  ld (0x124b),0x01
	call	SmfPart_ResetAllRecords	; F71EA5  call 0xf71417
SmfEvent_ProgramChange_MultiTrack_Skip2:
	ld	iy, (Smf_EventStatus:16)	; F71EA9  ld IY,(0x10d0)
	and	iy, 15	; F71EAD  and IY,0x000f
SmfEvent_ProgramChange_MultiTrack_Loop:
	ld	iy, (4530:16)	; F71EB1  ld IY,(0x11b2)
	calr	Smf_TrackToSlot	; F71EB5  calr 0xf728fe
	and	iy, 15	; F71EB8  and IY,0x000f
	bit	0, (0x11b1:16)	; F71EBC  bit 0,(0x11b1)
	jr	nz, SmfEvent_ProgramChange_MultiTrack_Skip3	; F71EC0  jr NZ,0xf71eca
	calr	SmfPart_SetSoundFromProgramChange	; F71EC2  calr 0xf701f1
	ld	(4664:16), 0	; F71EC5  ld (0x1238),0x00
SmfEvent_ProgramChange_MultiTrack_Skip3:
	cp	(0x1239:16), 0x00	; F71ECA  cp (0x1239),0x00
	jrl	z, SmfEvent_ProgramChange_MultiTrack_Skip4	; F71ECF  jrl Z,0xf71fd0
	push	xix	; F71ED2  push XIX
	push	xiy	; F71ED3  push XIY
	ld	iy, (Smf_EventStatus:16)	; F71ED4  ld IY,(0x10d0)
	and	iy, 15	; F71ED8  and IY,0x000f
	ld	xix, 4260	; F71EDC  ld XIX,0x000010a4
	ld	l, (xix+iy)	; F71EE1  ld L,(XIX+IY)
	ld	(SoundConv_Arg0:24), l	; F71EE6  ld (0x60f010),L
	ld	xix, 4242	; F71EEB  ld XIX,0x00001092
	ld	l, (xix+iy)	; F71EF0  ld L,(XIX+IY)
	ld	(SoundConv_Arg1:24), l	; F71EF5  ld (0x60f011),L
	ld	l, (4305:16)	; F71EFA  ld L,(0x10d1)
	ld	(SoundConv_Arg2:24), l	; F71EFE  ld (0x60f012),L
	ld	xix, ByteMap_F7207D	; F71F03  ld XIX,0x00f7207d
	ld	l, (xix+iy)	; F71F08  ld L,(XIX+IY)
	pop	xiy	; F71F0D  pop XIY
	pop	xix	; F71F0E  pop XIX
	ld	(SoundConv_Arg3:24), l	; F71F0F  ld (0x60f013),L
	call	T_PartSound_FromProgramChange	; F71F14  call 0xf41004
	push	xiy	; F71F18  push XIY
	push	xhl	; F71F19  push XHL
	calr	BStore_LoadTrackCursor	; F71F1A  calr 0xf727c8
	pop	xhl	; F71F1D  pop XHL
	ld	a, 192:opc	; F71F1E  ld A,0xc0
	ld	w, (SoundConv_Result0:24)	; F71F20  ld W,(0x60f014)
	and	w, 128	; F71F25  and W,0x80
	rlc	w	; F71F28  rlc 0x01,W
	or	a, w	; F71F2B  or A,W
	ld	w, (SoundConv_Result1:24)	; F71F2D  ld W,(0x60f015)
	and	w, 128	; F71F32  and W,0x80
	.byte 0xC8, 0xE8, 0x02	; F71F35  rlc 0x02,W   [llvm-mc cannot encode this]
	or	a, w	; F71F38  or A,W
	push	xhl	; F71F3A  push XHL
	calr	BStore_PutByteAndAdvance	; F71F3B  calr 0xf70fda
	pop	xhl	; F71F3E  pop XHL
	pop	xiy	; F71F3F  pop XIY
	cp	(0x1238:16), 0x00	; F71F40  cp (0x1238),0x00
	jrl	nz, SmfEvent_ProgramChange_MultiTrack_Return	; F71F45  jrl NZ,0xf7207c
	sla	iy, 1	; F71F48  sla 0x01,IY
	push	xix	; F71F4B  push XIX
	ld	xix, 4307	; F71F4C  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F71F51  ld WA,(XIX+IY)
	pop	xix	; F71F56  pop XIX
	srl	iy, 1	; F71F57  srl 0x01,IY
	push	xhl	; F71F5A  push XHL
	push	xiy	; F71F5B  push XIY
	calr	Smf_TicksToPpq96	; F71F5C  calr 0xf7122f
	pop	xiy	; F71F5F  pop XIY
	pop	xhl	; F71F60  pop XHL
	push	xhl	; F71F61  push XHL
	push	xiy	; F71F62  push XIY
	calr	BStore_PutByteAndAdvance	; F71F63  calr 0xf70fda
	pop	xiy	; F71F66  pop XIY
	pop	xhl	; F71F67  pop XHL
	cp	(0x1238:16), 0x00	; F71F68  cp (0x1238),0x00
	jrl	nz, SmfEvent_ProgramChange_MultiTrack_Return	; F71F6D  jrl NZ,0xf7207c
	ld	a, (Smf_EventStatus:16)	; F71F70  ld A,(0x10d0)
	and	a, 15	; F71F74  and A,0x0f
	push	xhl	; F71F77  push XHL
	push	xiy	; F71F78  push XIY
	calr	BStore_PutByteAndAdvance	; F71F79  calr 0xf70fda
	pop	xiy	; F71F7C  pop XIY
	pop	xhl	; F71F7D  pop XHL
	cp	(0x1238:16), 0x00	; F71F7E  cp (0x1238),0x00
	jrl	nz, SmfEvent_ProgramChange_MultiTrack_Return	; F71F83  jrl NZ,0xf7207c
	xor	a, a	; F71F86  xor A,A
	push	xhl	; F71F88  push XHL
	push	xiy	; F71F89  push XIY
	calr	BStore_PutByteAndAdvance	; F71F8A  calr 0xf70fda
	pop	xiy	; F71F8D  pop XIY
	pop	xhl	; F71F8E  pop XHL
	cp	(0x1238:16), 0x00	; F71F8F  cp (0x1238),0x00
	jrl	nz, SmfEvent_ProgramChange_MultiTrack_Return	; F71F94  jrl NZ,0xf7207c
	ld	a, (SoundConv_Result0:24)	; F71F97  ld A,(0x60f014)
	and	a, 127	; F71F9C  and A,0x7f
	push	xiy	; F71F9F  push XIY
	calr	BStore_PutByteAndAdvance	; F71FA0  calr 0xf70fda
	pop	xiy	; F71FA3  pop XIY
	cp	(0x1238:16), 0x00	; F71FA4  cp (0x1238),0x00
	jrl	nz, SmfEvent_ProgramChange_MultiTrack_Return	; F71FA9  jrl NZ,0xf7207c
	ld	a, (SoundConv_Result1:24)	; F71FAC  ld A,(0x60f015)
	and	a, 127	; F71FB1  and A,0x7f
	push	xiy	; F71FB4  push XIY
	call	BStore_PutByteAndAdvance	; F71FB5  call 0xf70fda
	pop	xiy	; F71FB9  pop XIY
	cp	(0x1238:16), 0x00	; F71FBA  cp (0x1238),0x00
	jrl	nz, SmfEvent_ProgramChange_MultiTrack_Return	; F71FBF  jrl NZ,0xf7207c
	calr	SmfEvent_MarkChannelUsed	; F71FC2  calr 0xf7129a
	calr	BStore_SaveTrackCursor	; F71FC5  calr 0xf727f6
	ld	(4664:16), 0	; F71FC8  ld (0x1238),0x00
	jrl	SmfEvent_ProgramChange_MultiTrack_Return	; F71FCD  jrl T,0xf7207c
SmfEvent_ProgramChange_MultiTrack_Skip4:
	push	xiy	; F71FD0  push XIY
	calr	BStore_LoadTrackCursor	; F71FD1  calr 0xf727c8
	ld	a, 192:opc	; F71FD4  ld A,0xc0
	pop	xiy	; F71FD6  pop XIY
	push	xiy	; F71FD7  push XIY
	calr	BStore_PutByteAndAdvance	; F71FD8  calr 0xf70fda
	pop	xiy	; F71FDB  pop XIY
	cp	(0x1238:16), 0x00	; F71FDC  cp (0x1238),0x00
	jrl	nz, SmfEvent_ProgramChange_MultiTrack_Return	; F71FE1  jrl NZ,0xf7207c
	sla	iy, 1	; F71FE4  sla 0x01,IY
	push	xix	; F71FE7  push XIX
	ld	xix, 4307	; F71FE8  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F71FED  ld WA,(XIX+IY)
	pop	xix	; F71FF2  pop XIX
	srl	iy, 1	; F71FF3  srl 0x01,IY
	push	xiy	; F71FF6  push XIY
	calr	Smf_TicksToPpq96	; F71FF7  calr 0xf7122f
	pop	xiy	; F71FFA  pop XIY
	push	xiy	; F71FFB  push XIY
	calr	BStore_PutByteAndAdvance	; F71FFC  calr 0xf70fda
	pop	xiy	; F71FFF  pop XIY
	cp	(0x1238:16), 0x00	; F72000  cp (0x1238),0x00
	jr	nz, SmfEvent_ProgramChange_MultiTrack_Return	; F72005  jr NZ,0xf7207c
	ld	a, (Smf_EventStatus:16)	; F72007  ld A,(0x10d0)
	and	a, 15	; F7200B  and A,0x0f
	push	xiy	; F7200E  push XIY
	calr	BStore_PutByteAndAdvance	; F7200F  calr 0xf70fda
	pop	xiy	; F72012  pop XIY
	cp	(0x1238:16), 0x00	; F72013  cp (0x1238),0x00
	jr	nz, SmfEvent_ProgramChange_MultiTrack_Return	; F72018  jr NZ,0xf7207c
	ld	a, 0:opc	; F7201A  ld A,0x00
	push	xiy	; F7201C  push XIY
	calr	BStore_PutByteAndAdvance	; F7201D  calr 0xf70fda
	pop	xiy	; F72020  pop XIY
	cp	(0x1238:16), 0x00	; F72021  cp (0x1238),0x00
	jr	nz, SmfEvent_ProgramChange_MultiTrack_Return	; F72026  jr NZ,0xf7207c
	ld	a, (4305:16)	; F72028  ld A,(0x10d1)
	push	xiy	; F7202C  push XIY
	calr	BStore_PutByteAndAdvance	; F7202D  calr 0xf70fda
	pop	xiy	; F72030  pop XIY
	cp	(0x1238:16), 0x00	; F72031  cp (0x1238),0x00
	jr	nz, SmfEvent_ProgramChange_MultiTrack_Return	; F72036  jr NZ,0xf7207c
	push	xix	; F72038  push XIX
	ld	xix, 4260	; F72039  ld XIX,0x000010a4
	ld	a, (xix+iy)	; F7203E  ld A,(XIX+IY)
	ld	xix, 4242	; F72043  ld XIX,0x00001092
	ld	w, (xix+iy)	; F72048  ld W,(XIX+IY)
	pop	xix	; F7204D  pop XIX
	and	a, 112	; F7204E  and A,0x70
	srl	a, 4	; F72051  srl 0x04,A
	and	w, 7	; F72054  and W,0x07
	sla	w, 3	; F72057  sla 0x03,W
	or	a, w	; F7205A  or A,W
	call	BStore_PutByteAndAdvance	; F7205C  call 0xf70fda
	cp	(0x1238:16), 0x00	; F72060  cp (0x1238),0x00
	jr	nz, SmfEvent_ProgramChange_MultiTrack_Return	; F72065  jr NZ,0xf7207c
	calr	SmfEvent_MarkChannelUsed	; F72067  calr 0xf7129a
	calr	BStore_SaveTrackCursor	; F7206A  calr 0xf727f6
	ld	(4664:16), 0	; F7206D  ld (0x1238),0x00
	jr	SmfEvent_ProgramChange_MultiTrack_Return	; F72072  jr T,0xf7207c

; --------------------------------------------------------------------------
; UNREACHED CODE, not data (was `Data_F72074`), part of SmfEvent_ProgramChange_MultiTrack:
;   `cp (0x1239),0xFF / jrl Z,0xF71EB1` -- the jrl lands on an instruction start of this source
;   (0xF71EB1), and the decode ends on the `ret` the jr above targets.
;   Nothing in prom_b branches to, calls or spells 0xF72074 (code_islands.py searches every
;   jr/jrl/calr displacement and jp/call/24-bit operand); it is recorded as code because it
;   decodes as such and fits the code beside it, not because it runs.
; --------------------------------------------------------------------------
	cp	(0x1239:16), 0xff	; F72074  cp (0x1239),0xff
	jrl	z, SmfEvent_ProgramChange_MultiTrack_Loop	; F72079  jrl Z,0xf71eb1

SmfEvent_ProgramChange_MultiTrack_Return:
	ret	; F7207C  ret

; --------------------------------------------------------------------------
; ByteMap_F7207D -- 18 bytes: a BYTE MAP.  0 of them are 0xFF and the other
;                   18 ASCEND STRICTLY, 0x00 to 0x5A, with jumps.  The name
;                   describes the CONTENT; what the two index spaces are is
;                   not established here.
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XIX,0x00f7207d` at
;          0xF71F03 (operand field 1 byte in)
; Entry count: 18 bytes.  The run is trimmed of trailing 0xFF, so it claims
;              no padding it did not earn; the byte before it is 0x0E and
;              the LAST byte of it is 0x5A.
; Evidence: every non-0xFF byte is compared with its predecessor on every
;           emit, WITHIN EACH of the 1 maximal ascending runs the rule
;           returns, and the runs are asserted to tile this segment exactly.
;           The BYTEMAP rule fires ZERO times over the proven prom_b
;           instruction text at (16 bytes, 12 values) and also at (20,14),
;           (24,16) and (16,16) (`python3 notes/prom_b_f6d002_layout.py
;           --null-ptr`).
; Unknown: what the two index spaces ARE, and who reads it.
; --------------------------------------------------------------------------
ByteMap_F7207D:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F7207D  [0..15]
; SmfEvent_NoteOn_MultiTrack: SmfEvent_DispatchChannelMessage_MultiTrack's arm for status 0x90 with a non-zero velocity.
SmfEvent_NoteOn_MultiTrack:
; `calr SmfEvent_NoteOn_MultiTrack` at 0xF71E09 lands on `ld XIY,0x0000305A` (45 5A 30 00 00); the source had
;   `.byte 0x45, 0x5A` and a `ld WA,0` framed from 0xF7208F, inside it.  The loop below walks
;   XIY from 0x305A in 7-byte steps to 0x313A.
	ld	xiy, 12378	; F7208D  ld XIY,0x0000305a
SmfEvent_NoteOn_MultiTrack_Loop:
	bit	7, (xiy)	; F72092  bit 7,(XIY)
	jr	nz, SmfEvent_NoteOn_MultiTrack_Skip	; F72094  jr NZ,0xf7209a
	ld	xix, xiy	; F72096  ld XIX,XIY
	jr	SmfEvent_NoteOn_MultiTrack_Join	; F72098  jr T,0xf720ab
SmfEvent_NoteOn_MultiTrack_Skip:
	add	xiy, 7	; F7209A  add XIY,0x00000007
	cp	xiy, 12602	; F720A0  cp XIY,0x0000313a
	jr	ule, SmfEvent_NoteOn_MultiTrack_Loop	; F720A6  jr ULE,0xf72092
	jrl	SmfEvent_NoteOn_MultiTrack_Return	; F720A8  jrl T,0xf721a2
SmfEvent_NoteOn_MultiTrack_Join:
	bit	0, (0x124b:16)	; F720AB  bit 0,(0x124b)
	jr	nz, SmfEvent_NoteOn_MultiTrack_Skip3	; F720AF  jr NZ,0xf720cb
	ld	(4665:16), 255	; F720B1  ld (0x1239),0xff
	cp	(0x2732:16), 0x00	; F720B6  cp (0x2732),0x00
	jr	nz, SmfEvent_NoteOn_MultiTrack_Skip2	; F720BB  jr NZ,0xf720c2
	ld	(4665:16), 0	; F720BD  ld (0x1239),0x00
SmfEvent_NoteOn_MultiTrack_Skip2:
	ld	(4683:16), 1	; F720C2  ld (0x124b),0x01
	call	SmfPart_ResetAllRecords	; F720C7  call 0xf71417
SmfEvent_NoteOn_MultiTrack_Skip3:
	or	(0x11b1:16), 0x01	; F720CB  or (0x11b1),0x01
	ld	iy, (4530:16)	; F720D0  ld IY,(0x11b2)
	extz	xiy	; F720D4  extz XIY
	calr	Smf_TrackToSlot	; F720D6  calr 0xf728fe
	and	iy, 15	; F720D9  and IY,0x000f
	push	xiy	; F720DD  push XIY
	push	xix	; F720DE  push XIX
	calr	BStore_LoadTrackCursor	; F720DF  calr 0xf727c8
	pop	xix	; F720E2  pop XIX
	ld	w, (Smf_EventStatus:16)	; F720E3  ld W,(0x10d0)
	and	w, 15	; F720E7  and W,0x0f
	ld	a, 144:opc	; F720EA  ld A,0x90
	or	a, w	; F720EC  or A,W
	push	xix	; F720EE  push XIX
	calr	BStore_PutByteAndAdvance	; F720EF  calr 0xf70fda
	pop	xix	; F720F2  pop XIX
	pop	xiy	; F720F3  pop XIY
	cp	(0x1238:16), 0x00	; F720F4  cp (0x1238),0x00
	jrl	nz, SmfEvent_NoteOn_MultiTrack_Return	; F720F9  jrl NZ,0xf721a2
	sla	xiy, 1	; F720FC  sla 0x01,XIY
	push	xix	; F720FF  push XIX
	ld	xix, 4307	; F72100  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F72105  ld WA,(XIX+IY)
	pop	xix	; F7210A  pop XIX
	srl	xiy, 1	; F7210B  srl 0x01,XIY
	push	xiy	; F7210E  push XIY
	push	xix	; F7210F  push XIX
	calr	Smf_TicksToPpq96	; F72110  calr 0xf7122f
	pop	xix	; F72113  pop XIX
	pop	xiy	; F72114  pop XIY
	push	xiy	; F72115  push XIY
	push	xix	; F72116  push XIX
	calr	BStore_PutByteAndAdvance	; F72117  calr 0xf70fda
	pop	xix	; F7211A  pop XIX
	pop	xiy	; F7211B  pop XIY
	cp	(0x1238:16), 0x00	; F7211C  cp (0x1238),0x00
	jrl	nz, SmfEvent_NoteOn_MultiTrack_Return	; F72121  jrl NZ,0xf721a2
	ld	a, (4305:16)	; F72124  ld A,(0x10d1)
	push	xiy	; F72128  push XIY
	push	xix	; F72129  push XIX
	calr	BStore_PutByteAndAdvance	; F7212A  calr 0xf70fda
	pop	xix	; F7212D  pop XIX
	pop	xiy	; F7212E  pop XIY
	cp	(0x1238:16), 0x00	; F7212F  cp (0x1238),0x00
	jr	nz, SmfEvent_NoteOn_MultiTrack_Return	; F72134  jr NZ,0xf721a2
	ld	a, (4306:16)	; F72136  ld A,(0x10d2)
	cp	a, 127	; F7213A  cp A,0x7f
	jr	ule, SmfEvent_NoteOn_MultiTrack_Skip4	; F7213D  jr ULE,0xf72141
	ld	a, 127:opc	; F7213F  ld A,0x7f
SmfEvent_NoteOn_MultiTrack_Skip4:
	push	xiy	; F72141  push XIY
	push	xix	; F72142  push XIX
	calr	BStore_PutByteAndAdvance	; F72143  calr 0xf70fda
	pop	xix	; F72146  pop XIX
	pop	xiy	; F72147  pop XIY
	cp	(0x1238:16), 0x00	; F72148  cp (0x1238),0x00
	jr	nz, SmfEvent_NoteOn_MultiTrack_Return	; F7214D  jr NZ,0xf721a2
	ld	a, (BStore_CursorOffset:16)	; F7214F  ld A,(0x345e)
	ld	(xix+2), a	; F72153  ld (XIX+0x02),A
	ld	wa, (BStore_CursorBlock:16)	; F72156  ld WA,(0x345c)
	ld	(xix+3), wa	; F7215A  ld (XIX+0x03),WA
	xor	a, a	; F7215D  xor A,A
	push	xiy	; F7215F  push XIY
	push	xix	; F72160  push XIX
	pushw	wa	; F72161  push WA
	calr	BStore_PutByteAndAdvance	; F72162  calr 0xf70fda
	popw	wa	; F72165  pop WA
	pop	xix	; F72166  pop XIX
	pop	xiy	; F72167  pop XIY
	cp	(0x1238:16), 0x00	; F72168  cp (0x1238),0x00
	jr	nz, SmfEvent_NoteOn_MultiTrack_Return	; F7216D  jr NZ,0xf721a2
	push	xiy	; F7216F  push XIY
	push	xix	; F72170  push XIX
	calr	BStore_PutByteAndAdvance	; F72171  calr 0xf70fda
	pop	xix	; F72174  pop XIX
	pop	xiy	; F72175  pop XIY
	cp	(0x1238:16), 0x00	; F72176  cp (0x1238),0x00
	jr	nz, SmfEvent_NoteOn_MultiTrack_Return	; F7217B  jr NZ,0xf721a2
	calr	SmfEvent_MarkChannelUsed	; F7217D  calr 0xf7129a
	push	xix	; F72180  push XIX
	calr	BStore_SaveTrackCursor	; F72181  calr 0xf727f6
	pop	xix	; F72184  pop XIX
	ld	a, (Smf_EventStatus:16)	; F72185  ld A,(0x10d0)
	and	a, 15	; F72189  and A,0x0f
	or	a, 128	; F7218C  or A,0x80
	ld	(xix), a	; F7218F  ld (XIX),A
	ld	a, (4305:16)	; F72191  ld A,(0x10d1)
	ld	(xix+1), a	; F72195  ld (XIX+0x01),A
	xor	wa, wa	; F72198  xor WA,WA
	ld	(xix+5), wa	; F7219A  ld (XIX+0x05),WA
	ld	(4664:16), 0	; F7219D  ld (0x1238),0x00
SmfEvent_NoteOn_MultiTrack_Return:
	ret	; F721A2  ret

; --------------------------------------------------------------------------
; SmfEvent_NoteOff_MultiTrack
; Called from: in-module: 0xF71E0E
; Touches: (0x10D0) (0x10D1) (0x126E) (0x345C) (0x345E)
; Calls:   SongStore_SeekBlock_Copy Smf_StepCursorOneByte
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF721A3 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_NoteOff_MultiTrack: SmfEvent_DispatchChannelMessage_MultiTrack's arm for status 0x80, and 0x90 with velocity 0.
SmfEvent_NoteOff_MultiTrack:
	ld	xiy, 12378	; F721A3  ld XIY,0x0000305a
SmfEvent_NoteOff_MultiTrack_Loop:
	bit	7, (xiy)	; F721A8  bit 7,(XIY)
	jr	z, SmfEvent_NoteOff_MultiTrack_Skip2	; F721AA  jr Z,0xf7221f
	ld	a, (xiy)	; F721AC  ld A,(XIY)
	and	a, 15	; F721AE  and A,0x0f
	ld	l, (Smf_EventStatus:16)	; F721B1  ld L,(0x10d0)
	and	l, 15	; F721B5  and L,0x0f
	cp	a, l	; F721B8  cp A,L
	jr	nz, SmfEvent_NoteOff_MultiTrack_Skip2	; F721BA  jr NZ,0xf7221f
	ld	l, (4305:16)	; F721BC  ld L,(0x10d1)
	cp	(xiy+1), l	; F721C0  cp (XIY+0x01),L
	jr	nz, SmfEvent_NoteOff_MultiTrack_Skip2	; F721C3  jr NZ,0xf7221f
	and	(xiy), 0x7f	; F721C5  and (XIY),0x7f
	ld	ix, (xiy+2)	; F721C8  ld IX,(XIY+0x02)
	ld	hl, (xiy+3)	; F721CB  ld HL,(XIY+0x03)
	and	ix, 255	; F721CE  and IX,0x00ff
	push	xhl	; F721D2  push XHL
	push	xiy	; F721D3  push XIY
	calr	SongStore_SeekBlock_Copy	; F721D4  calr 0xf72f0a
	pop	xiy	; F721D7  pop XIY
	ld	wa, (xiy+5)	; F721D8  ld WA,(XIY+0x05)
	ld	l, 96:opc	; F721DB  ld L,0x60
	divs	wa, l	; F721DD  divs WA,L
	cp	a, 0:i3	; F721DF  cp A,0
	jr	nz, SmfEvent_NoteOff_MultiTrack_Skip	; F721E1  jr NZ,0xf721e9
	cp	w, 4:i3	; F721E3  cp W,4
	jr	ugt, SmfEvent_NoteOff_MultiTrack_Skip	; F721E5  jr UGT,0xf721e9
	ld	w, 5:opc	; F721E7  ld W,0x05
SmfEvent_NoteOff_MultiTrack_Skip:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F721E9  ld XHL,(0x126e)
	ld	(xhl+ix), w	; F721ED  ld (XHL+IX),W
	pop	xhl	; F721F2  pop XHL
	pushw	(BStore_CursorBlock:16)	; F721F3  pushw (0x345c)
	pushw	(BStore_CursorOffset:16)	; F721F7  pushw (0x345e)
	ld	(BStore_CursorBlock:16), hl	; F721FB  ld (0x345c),HL
	ld	(BStore_CursorOffset:16), ix	; F721FF  ld (0x345e),IX
	pushw	wa	; F72203  push WA
	calr	Smf_StepCursorOneByte	; F72204  calr 0xf710ba
	popw	wa	; F72207  pop WA
	ld	ix, (BStore_CursorOffset:16)	; F72208  ld IX,(0x345e)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7220C  ld XHL,(0x126e)
	ld	(xhl+ix), a	; F72210  ld (XHL+IX),A
	popw	(BStore_CursorOffset:16)	; F72215  popw (0x345e)
	popw	(BStore_CursorBlock:16)	; F72219  popw (0x345c)
	jr	SmfEvent_NoteOff_MultiTrack_Return	; F7221D  jr T,0xf7222c
SmfEvent_NoteOff_MultiTrack_Skip2:
	add	iy, 7	; F7221F  add IY,0x0007
	cp	xiy, 12602	; F72223  cp XIY,0x0000313a
	jrl	ule, SmfEvent_NoteOff_MultiTrack_Loop	; F72229  jrl ULE,0xf721a8
SmfEvent_NoteOff_MultiTrack_Return:
	ret	; F7222C  ret

; --------------------------------------------------------------------------
; SmfEvent_ControlChange_MultiTrack
; Called from: in-module: 0xF71E13
; Touches: (0x10D1) (0x1239) (0x124B) (0x2732)
; Calls:   SmfPart_ResetAllRecords SmfCC_GeneralPurpose1 SmfCC_GeneralPurpose2 SmfCC_GeneralPurpose3 SmfCC_GeneralPurpose4 SmfCC_BankSelectLsb_MultiTrack
;          SmfCC_DataEntryLsb_MultiTrack SmfCC_Sustain sub_F7039A_Nop2 SmfCC_PutSustainParamEvent_Nop SmfCC_Effect1Depth_MultiTrack SmfCC_Effect3Depth_MultiTrack
;          +6 more
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7222D is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_ControlChange_MultiTrack: SmfEvent_DispatchChannelMessage_MultiTrack's arm for status 0xB0.
SmfEvent_ControlChange_MultiTrack:
	bit	0, (0x124b:16)	; F7222D  bit 0,(0x124b)
	jr	nz, SmfEvent_ControlChange_MultiTrack_Skip2	; F72231  jr NZ,0xf7224d
	ld	(4665:16), 255	; F72233  ld (0x1239),0xff
	cp	(0x2732:16), 0x00	; F72238  cp (0x2732),0x00
	jr	nz, SmfEvent_ControlChange_MultiTrack_Skip	; F7223D  jr NZ,0xf72244
	ld	(4665:16), 0	; F7223F  ld (0x1239),0x00
SmfEvent_ControlChange_MultiTrack_Skip:
	ld	(4683:16), 1	; F72244  ld (0x124b),0x01
	call	SmfPart_ResetAllRecords	; F72249  call 0xf71417
SmfEvent_ControlChange_MultiTrack_Skip2:
	ld	a, (4305:16)	; F7224D  ld A,(0x10d1)
	cp	a, 16	; F72251  cp A,0x10
	jr	c, SmfEvent_ControlChange_MultiTrack_Skip3	; F72254  jr C,0xf722b2
	cp	a, 16	; F72256  cp A,0x10
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip4	; F72259  jr Z,0xf722cb
	cp	a, 17	; F7225B  cp A,0x11
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip5	; F7225E  jr Z,0xf722d0
	cp	a, 18	; F72260  cp A,0x12
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip6	; F72263  jr Z,0xf722d5
	cp	a, 19	; F72265  cp A,0x13
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip7	; F72268  jr Z,0xf722da
	cp	a, 32	; F7226A  cp A,0x20
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip8	; F7226D  jr Z,0xf722df
	cp	a, 38	; F7226F  cp A,0x26
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip9	; F72272  jr Z,0xf722e4
	cp	a, 64	; F72274  cp A,0x40
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip10	; F72277  jr Z,0xf722e9
	cp	a, 66	; F72279  cp A,0x42
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip11	; F7227C  jr Z,0xf722ef
	cp	a, 67	; F7227E  cp A,0x43
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip12	; F72281  jr Z,0xf722f5
	cp	a, 91	; F72283  cp A,0x5b
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip13	; F72286  jr Z,0xf722fb
	cp	a, 93	; F72288  cp A,0x5d
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip14	; F7228B  jr Z,0xf72301
	cp	a, 94	; F7228D  cp A,0x5e
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip15	; F72290  jr Z,0xf72306
	cp	a, 96	; F72292  cp A,0x60
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip16	; F72295  jr Z,0xf7230b
	cp	a, 97	; F72297  cp A,0x61
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip17	; F7229A  jr Z,0xf72310
	cp	a, 98	; F7229C  cp A,0x62
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip18	; F7229F  jr Z,0xf72315
	cp	a, 99	; F722A1  cp A,0x63
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip18	; F722A4  jr Z,0xf72315
	cp	a, 100	; F722A6  cp A,0x64
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip20	; F722A9  jr Z,0xf7231f
	cp	a, 101	; F722AB  cp A,0x65
	jr	z, SmfEvent_ControlChange_MultiTrack_Skip19	; F722AE  jr Z,0xf7231a
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F722B0  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip3:
	ld	l, a	; F722B2  ld L,A
	xor	h, h	; F722B4  xor H,H
	sla	l, 2	; F722B6  sla 0x02,L
	extz	xhl	; F722B9  extz XHL
	push	xix	; F722BB  push XIX
	ld	xix, SmfCC_HandlersByNumber_MultiTrack	; F722BC  ld XIX,0x00f72323
	ld	xhl, (xix+hl)	; F722C1  ld XHL,(XIX+HL)
	pop	xix	; F722C6  pop XIX
	call	(xhl)	; F722C7  call T,XHL
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F722C9  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip4:
	calr	SmfCC_GeneralPurpose1	; F722CB  calr 0xf7193f
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F722CE  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip5:
	calr	SmfCC_GeneralPurpose2	; F722D0  calr 0xf71978
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F722D3  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip6:
	calr	SmfCC_GeneralPurpose3	; F722D5  calr 0xf719b1
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F722D8  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip7:
	calr	SmfCC_GeneralPurpose4	; F722DA  calr 0xf719ea
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F722DD  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip8:
	calr	SmfCC_BankSelectLsb_MultiTrack	; F722DF  calr 0xf725d9
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F722E2  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip9:
	calr	SmfCC_DataEntryLsb_MultiTrack	; F722E4  calr 0xf7243b
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F722E7  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip10:
	call	SmfCC_Sustain	; F722E9  call 0xf707e6
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F722ED  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip11:
	call	sub_F7039A_Nop2	; F722EF  call 0xf7095e
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F722F3  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip12:
	call	SmfCC_PutSustainParamEvent_Nop	; F722F5  call 0xf7091d
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F722F9  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip13:
	call	SmfCC_Effect1Depth_MultiTrack	; F722FB  call 0xf7263a
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F722FF  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip14:
	calr	SmfCC_Effect3Depth_MultiTrack	; F72301  calr 0xf7267e
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F72304  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip15:
	calr	SmfCC_Effect4Depth_MultiTrack	; F72306  calr 0xf726a2
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F72309  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip16:
	calr	SmfCC_DataIncrement	; F7230B  calr 0xf70a43
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F7230E  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip17:
	calr	SmfCC_DataDecrement	; F72310  calr 0xf70a97
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F72313  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip18:
	calr	SmfCC_Nrpn	; F72315  calr 0xf70c6f
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F72318  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip19:
	calr	SmfCC_RpnMsb	; F7231A  calr 0xf70cba
	jr	SmfEvent_ControlChange_MultiTrack_Return	; F7231D  jr T,0xf72322
SmfEvent_ControlChange_MultiTrack_Skip20:
	calr	SmfCC_RpnLsb	; F7231F  calr 0xf70d42
SmfEvent_ControlChange_MultiTrack_Return:
	ret	; F72322  ret

; --------------------------------------------------------------------------
; SmfCC_HandlersByNumber_MultiTrack -- 16 32-bit words, every one an address in
;                         0x00F00000-0x00F7FFFF, i.e. inside this image.  9
;                         distinct values.  notes/prom_b_f6d002_layout.py
;                         classes it TRANSFER.
; Why TRANSFER: the code that indexes it fetches an entry and then TRANSFERS
;               to it, so the entries are ENTRY POINTS and they seed this
;               block's code walk
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XIX,0x00f72323` at
;          0xF722BC (operand field 1 byte in)
; Entry count: 16, and it is NOT a byte extent divided by four.  The chain
;              rule that finds it stops at the first word that is not an
;              0x00F0xxxx-0x00F7xxxx address; that word is at 0xF72363.
;              Entry 15, the LAST, is 0x00F72363.
; Evidence: every one of the 16 words is re-read and range-asserted on every
;           emit.  The PTRTAB rule at this window fires ZERO times over the
;           proven prom_b instruction text (`python3
;           notes/prom_b_f6d002_layout.py --null-ptr`), and the STRIDED rule
;           fires zero times over the proven dispatch tables of this image
;           (`--null-stride`).
; Unknown: what the handlers do.  Each is sub_XXXXXX.
; --------------------------------------------------------------------------
; SmfCC_HandlersByNumber_MultiTrack: the multi-track path's CC 0..15 handlers, indexed by the CC number (entries 2 and 4 are the shared SmfCC_Breath / SmfCC_Foot).
SmfCC_HandlersByNumber_MultiTrack:
	.long	SmfCC_BankSelectMsb_MultiTrack	; F72323  [0] -> SmfCC_BankSelectMsb_MultiTrack
	.long	SmfCC_Modulation_MultiTrack	; F72327  [1] -> SmfCC_Modulation_MultiTrack
	.long	SmfCC_Breath	; F7232B  [2] -> SmfCC_Breath
	.long	SmfCC_HandlersByNumber_MultiTrack_Nop3	; F7232F  [3] -> SmfCC_HandlersByNumber_MultiTrack_Nop3
	.long	SmfCC_Foot	; F72333  [4] -> SmfCC_Foot
	.long	SmfCC_HandlersByNumber_MultiTrack_Nop3	; F72337  [5] -> SmfCC_HandlersByNumber_MultiTrack_Nop3
	.long	SmfCC_DataEntryMsb_MultiTrack	; F7233B  [6] -> SmfCC_DataEntryMsb_MultiTrack
	.long	SmfCC_Volume_MultiTrack	; F7233F  [7] -> SmfCC_Volume_MultiTrack
	.long	SmfCC_HandlersByNumber_MultiTrack_Nop3	; F72343  [8] -> SmfCC_HandlersByNumber_MultiTrack_Nop3
	.long	SmfCC_HandlersByNumber_MultiTrack_Nop3	; F72347  [9] -> SmfCC_HandlersByNumber_MultiTrack_Nop3
	.long	SmfCC_Pan_MultiTrack	; F7234B  [10] -> SmfCC_Pan_MultiTrack
	.long	SmfCC_Expression_MultiTrack	; F7234F  [11] -> 0xF72575
	.long	SmfCC_HandlersByNumber_MultiTrack_Nop3	; F72353  [12] -> SmfCC_HandlersByNumber_MultiTrack_Nop3
	.long	SmfCC_HandlersByNumber_MultiTrack_Nop3	; F72357  [13] -> SmfCC_HandlersByNumber_MultiTrack_Nop3
	.long	SmfCC_HandlersByNumber_MultiTrack_Nop3	; F7235B  [14] -> SmfCC_HandlersByNumber_MultiTrack_Nop3
	.long	SmfCC_HandlersByNumber_MultiTrack_Nop3	; F7235F  [15] -> SmfCC_HandlersByNumber_MultiTrack_Nop3


; --------------------------------------------------------------------------
; SmfCC_HandlersByNumber_MultiTrack_Nop3
; Called from: no thunk slot and no in-module call or jp site -- reached
;              only by a branch from the routine above, or through a table
; Touches: nothing with an absolute address
; Evidence (TABLE): it is an entry of a pointer table the consumer rule
;                   classed TRANSFER: the code that indexes that table
;                   fetches the entry and then transfers to it.  This module
;                   has two such tables, both of 16 entries, at 0xF7048D and
;                   0xF72323.  0xF72363 is an instruction boundary of this
;                   transcription, re-asserted on every emit.  The name IS
;                   the address.
; Purpose: none -- the entry is a lone `ret`.  Named SmfCC_HandlersByNumber_MultiTrack_Nop3 after what reaches it
;          (was sub_F72363; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
SmfCC_HandlersByNumber_MultiTrack_Nop3:
	ret	; F72363  ret

; --------------------------------------------------------------------------
; SmfCC_BankSelectMsb_MultiTrack
; Called from: no thunk slot and no in-module call or jp site -- reached
;              only by a branch from the routine above, or through a table
; Touches: (0x10D0) (0x10D2)
; Evidence (TABLE): it is an entry of a pointer table the consumer rule
;                   classed TRANSFER: the code that indexes that table
;                   fetches the entry and then transfers to it.  This module
;                   has two such tables, both of 16 entries, at 0xF7048D and
;                   0xF72323.  0xF72364 is an instruction boundary of this
;                   transcription, re-asserted on every emit.  The name IS
;                   the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_BankSelectMsb_MultiTrack: SmfEvent_ControlChange_MultiTrack's DispatchTable_F72323[0], CC 0 -- the multi-track copy of SmfCC_BankSelectMsb.
SmfCC_BankSelectMsb_MultiTrack:
	ld	iy, (Smf_EventStatus:16)	; F72364  ld IY,(0x10d0)
	and	iy, 15	; F72368  and IY,0x000f
	ld	a, (4306:16)	; F7236C  ld A,(0x10d2)
	push	xix	; F72370  push XIX
	ld	xix, 4242	; F72371  ld XIX,0x00001092
	ld	(xix+iy), a	; F72376  ld (XIX+IY),A
	pop	xix	; F7237B  pop XIX
	ret	; F7237C  ret

; --------------------------------------------------------------------------
; SmfCC_Modulation_MultiTrack
; Called from: no thunk slot and no in-module call or jp site -- reached
;              only by a branch from the routine above, or through a table
; Touches: (0x10D0) (0x10D2) (0x11B2) (0x1238)
; Calls:   Smf_TrackToSlot BStore_LoadTrackCursor BStore_PutByteAndAdvance Smf_TicksToPpq96 SmfEvent_MarkChannelUsed BStore_SaveTrackCursor
; Evidence (TABLE): it is an entry of a pointer table the consumer rule
;                   classed TRANSFER: the code that indexes that table
;                   fetches the entry and then transfers to it.  This module
;                   has two such tables, both of 16 entries, at 0xF7048D and
;                   0xF72323.  0xF7237D is an instruction boundary of this
;                   transcription, re-asserted on every emit.  The name IS
;                   the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_Modulation_MultiTrack: SmfEvent_ControlChange_MultiTrack's DispatchTable_F72323[1], CC 1 -- the multi-track copy of SmfCC_Modulation.
SmfCC_Modulation_MultiTrack:
	ld	iy, (4530:16)	; F7237D  ld IY,(0x11b2)
	calr	Smf_TrackToSlot	; F72381  calr 0xf728fe
	and	iy, 15	; F72384  and IY,0x000f
	push	xiy	; F72388  push XIY
	calr	BStore_LoadTrackCursor	; F72389  calr 0xf727c8
	ld	w, (Smf_EventStatus:16)	; F7238C  ld W,(0x10d0)
	and	w, 15	; F72390  and W,0x0f
	ld	a, 208:opc	; F72393  ld A,0xd0
	or	a, w	; F72395  or A,W
	calr	BStore_PutByteAndAdvance	; F72397  calr 0xf70fda
	pop	xiy	; F7239A  pop XIY
	cp	(0x1238:16), 0x00	; F7239B  cp (0x1238),0x00
	jr	nz, SmfCC_Modulation_MultiTrack_Return	; F723A0  jr NZ,0xf723e0
	sla	iy, 1	; F723A2  sla 0x01,IY
	push	xix	; F723A5  push XIX
	ld	xix, 4307	; F723A6  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F723AB  ld WA,(XIX+IY)
	pop	xix	; F723B0  pop XIX
	srl	iy, 1	; F723B1  srl 0x01,IY
	push	xiy	; F723B4  push XIY
	calr	Smf_TicksToPpq96	; F723B5  calr 0xf7122f
	pop	xiy	; F723B8  pop XIY
	push	xiy	; F723B9  push XIY
	calr	BStore_PutByteAndAdvance	; F723BA  calr 0xf70fda
	pop	xiy	; F723BD  pop XIY
	cp	(0x1238:16), 0x00	; F723BE  cp (0x1238),0x00
	jr	nz, SmfCC_Modulation_MultiTrack_Return	; F723C3  jr NZ,0xf723e0
	push	xiy	; F723C5  push XIY
	ld	a, (4306:16)	; F723C6  ld A,(0x10d2)
	calr	BStore_PutByteAndAdvance	; F723CA  calr 0xf70fda
	pop	xiy	; F723CD  pop XIY
	cp	(0x1238:16), 0x00	; F723CE  cp (0x1238),0x00
	jr	nz, SmfCC_Modulation_MultiTrack_Return	; F723D3  jr NZ,0xf723e0
	calr	SmfEvent_MarkChannelUsed	; F723D5  calr 0xf7129a
	calr	BStore_SaveTrackCursor	; F723D8  calr 0xf727f6
	ld	(4664:16), 0	; F723DB  ld (0x1238),0x00
SmfCC_Modulation_MultiTrack_Return:
	ret	; F723E0  ret

; --------------------------------------------------------------------------
; SmfCC_DataEntryMsb_MultiTrack
; Called from: no thunk slot and no in-module call or jp site -- reached
;              only by a branch from the routine above, or through a table
; Touches: (0x10D0) (0x10D2)
; Calls:   SmfCC_CombineFineTuneDataEntry SmfCC_PutSelectedRpnValueEvent
; Evidence (TABLE): it is an entry of a pointer table the consumer rule
;                   classed TRANSFER: the code that indexes that table
;                   fetches the entry and then transfers to it.  This module
;                   has two such tables, both of 16 entries, at 0xF7048D and
;                   0xF72323.  0xF723E1 is an instruction boundary of this
;                   transcription, re-asserted on every emit.  The name IS
;                   the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_DataEntryMsb_MultiTrack: SmfEvent_ControlChange_MultiTrack's DispatchTable_F72323[6], CC 6 -- the multi-track copy of SmfCC_DataEntryMsb.
SmfCC_DataEntryMsb_MultiTrack:
	ld	iy, (Smf_EventStatus:16)	; F723E1  ld IY,(0x10d0)
	and	iy, 15	; F723E5  and IY,0x000f
	push	xix	; F723E9  push XIX
	ld	xix, 4568	; F723EA  ld XIX,0x000011d8
	ld	l, (xix+iy)	; F723EF  ld L,(XIX+IY)
	pop	xix	; F723F4  pop XIX
	cp	l, 255	; F723F5  cp L,0xff
	jr	z, SmfCC_DataEntryMsb_MultiTrack_Return	; F723F8  jr Z,0xf7243a
	ld	c, l	; F723FA  ld C,L
	xor	h, h	; F723FC  xor H,H
	sla	hl, 2	; F723FE  sla 0x02,HL
	push	xix	; F72401  push XIX
	ld	xix, Data_F72495	; F72402  ld XIX,0x00f72495
	ld	xhl, (xix+hl)	; F72407  ld XHL,(XIX+HL)
	pop	xix	; F7240C  pop XIX
	ld	a, (4306:16)	; F7240D  ld A,(0x10d2)
	xor	b, b	; F72411  xor B,B
	ld	ix, bc	; F72413  ld IX,BC
	push	xiy	; F72415  push XIY
	ld	xiy, Data_F72495 + 0xC	; F72416  ld XIY,0x00f724a1
	ld	e, (xiy+ix)	; F7241B  ld E,(XIY+IX)
	pop	xiy	; F72420  pop XIY
	cp	a, e	; F72421  cp A,E
	jr	ule, SmfCC_DataEntryMsb_MultiTrack_Skip	; F72423  jr ULE,0xf72427
	ld	a, e	; F72425  ld A,E
SmfCC_DataEntryMsb_MultiTrack_Skip:
	cp	c, 1:i3	; F72427  cp C,1
	jr	nz, SmfCC_DataEntryMsb_MultiTrack_Skip2	; F72429  jr NZ,0xf72432
	push	xhl	; F7242B  push XHL
	pushw	iy	; F7242C  push IY
	calr	SmfCC_CombineFineTuneDataEntry	; F7242D  calr 0xf705f7
	popw	iy	; F72430  pop IY
	pop	xhl	; F72431  pop XHL
SmfCC_DataEntryMsb_MultiTrack_Skip2:
	ld	(xhl+iy), a	; F72432  ld (XHL+IY),A
	calr	SmfCC_PutSelectedRpnValueEvent	; F72437  calr 0xf70ae9
SmfCC_DataEntryMsb_MultiTrack_Return:
	ret	; F7243A  ret

; --------------------------------------------------------------------------
; SmfCC_DataEntryLsb_MultiTrack
; Called from: in-module: 0xF722E4
; Touches: (0x10D0) (0x10D2)
; Calls:   SmfCC_CombineFineTuneDataEntry SmfCC_PutSelectedRpnValueEvent
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7243B is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_DataEntryLsb_MultiTrack: SmfEvent_ControlChange_MultiTrack's `cp A,38` arm, CC 38 -- the multi-track copy of SmfCC_DataEntryLsb.
SmfCC_DataEntryLsb_MultiTrack:
	ld	iy, (Smf_EventStatus:16)	; F7243B  ld IY,(0x10d0)
	and	iy, 15	; F7243F  and IY,0x000f
	push	xix	; F72443  push XIX
	ld	xix, 4568	; F72444  ld XIX,0x000011d8
	ld	l, (xix+iy)	; F72449  ld L,(XIX+IY)
	pop	xix	; F7244E  pop XIX
	cp	l, 255	; F7244F  cp L,0xff
	jr	z, SmfCC_DataEntryLsb_MultiTrack_Return	; F72452  jr Z,0xf72494
	ld	c, l	; F72454  ld C,L
	xor	h, h	; F72456  xor H,H
	sla	hl, 2	; F72458  sla 0x02,HL
	push	xix	; F7245B  push XIX
	ld	xix, Data_F72495	; F7245C  ld XIX,0x00f72495
	ld	xhl, (xix+hl)	; F72461  ld XHL,(XIX+HL)
	pop	xix	; F72466  pop XIX
	ld	a, (4306:16)	; F72467  ld A,(0x10d2)
	xor	b, b	; F7246B  xor B,B
	ld	ix, bc	; F7246D  ld IX,BC
	push	xiy	; F7246F  push XIY
	ld	xiy, Data_F72495 + 0xC	; F72470  ld XIY,0x00f724a1
	ld	e, (xiy+ix)	; F72475  ld E,(XIY+IX)
	pop	xiy	; F7247A  pop XIY
	cp	a, e	; F7247B  cp A,E
	jr	ule, SmfCC_DataEntryLsb_MultiTrack_Skip	; F7247D  jr ULE,0xf72481
	ld	a, e	; F7247F  ld A,E
SmfCC_DataEntryLsb_MultiTrack_Skip:
	cp	c, 1:i3	; F72481  cp C,1
	jr	nz, SmfCC_DataEntryLsb_MultiTrack_Return	; F72483  jr NZ,0xf72494
	push	xhl	; F72485  push XHL
	push	xiy	; F72486  push XIY
	calr	SmfCC_CombineFineTuneDataEntry	; F72487  calr 0xf705f7
	pop	xiy	; F7248A  pop XIY
	pop	xhl	; F7248B  pop XHL
	ld	(xhl+iy), a	; F7248C  ld (XHL+IY),A
	calr	SmfCC_PutSelectedRpnValueEvent	; F72491  calr 0xf70ae9
SmfCC_DataEntryLsb_MultiTrack_Return:
	ret	; F72494  ret

; --------------------------------------------------------------------------
; Data_F72495 -- 18 bytes this block could not split.  No content rule
;                framed it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or
;                ASCII -- and the code walk never reached it from a thunk
;                slot, a proven call site, an opcode-anchored call or an
;                entry of a table the firmware transfers to.  So it is
;                emitted as bytes rather than guessed.
; Read by: 2 byte-scan hits: 2 instruction operands -- `ld XIX,0x00f72495`
;          at 0xF72402 (operand field 1 byte in); `ld XIX,0x00f72495` at
;          0xF7245C (operand field 1 byte in)
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; Unknown: everything about it except its bytes.
; --------------------------------------------------------------------------
Data_F72495:
	.byte	0x08, 0x12, 0x00, 0x00, 0xE8, 0x11, 0x00, 0x00, 0xF8, 0x11, 0x00, 0x00, 0x0C, 0x7F, 0xFF, 0x00	; F72495  [0..15]
	.byte	0x00, 0x00	; F724A5  [16..17]


; --------------------------------------------------------------------------
; SmfCC_Volume_MultiTrack
; Called from: no thunk slot and no in-module call or jp site -- reached
;              only by a branch from the routine above, or through a table
; Touches: (0x10D2) (0x11AE) (0x11AF) (0x11B0) (0x11B1) (0x1238)
; Calls:   SmfPart_SetVolume SmfCC_PutPartParamEvent_MultiTrack
; Evidence (TABLE): it is an entry of a pointer table the consumer rule
;                   classed TRANSFER: the code that indexes that table
;                   fetches the entry and then transfers to it.  This module
;                   has two such tables, both of 16 entries, at 0xF7048D and
;                   0xF72323.  0xF724A7 is an instruction boundary of this
;                   transcription, re-asserted on every emit.  The name IS
;                   the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_Volume_MultiTrack: SmfEvent_ControlChange_MultiTrack's DispatchTable_F72323[7], CC 7 -- the multi-track copy of SmfCC_Volume.
SmfCC_Volume_MultiTrack:
	bit	0, (0x11b1:16)	; F724A7  bit 0,(0x11b1)
	jr	nz, SmfCC_Volume_MultiTrack_Skip	; F724AB  jr NZ,0xf724b5
	calr	SmfPart_SetVolume	; F724AD  calr 0xf7067f
	ld	(4664:16), 0	; F724B0  ld (0x1238),0x00
SmfCC_Volume_MultiTrack_Skip:
	ld	(4526:16), 3	; F724B5  ld (0x11ae),0x03
	ld	a, (4306:16)	; F724BA  ld A,(0x10d2)
	ld	(4527:16), a	; F724BE  ld (0x11af),A
	ld	(4528:16), 127	; F724C2  ld (0x11b0),0x7f
	calr	SmfCC_PutPartParamEvent_MultiTrack	; F724C7  calr 0xf726c6
	ret	; F724CA  ret

; --------------------------------------------------------------------------
; SmfCC_Pan_MultiTrack
; Called from: no thunk slot and no in-module call or jp site -- reached
;              only by a branch from the routine above, or through a table
; Touches: (0x10D0) (0x10D2) (0x11B2) (0x1238)
; Calls:   Smf_TrackToSlot BStore_LoadTrackCursor BStore_PutByteAndAdvance Smf_TicksToPpq96 SmfEvent_MarkChannelUsed BStore_SaveTrackCursor
; Evidence (TABLE): it is an entry of a pointer table the consumer rule
;                   classed TRANSFER: the code that indexes that table
;                   fetches the entry and then transfers to it.  This module
;                   has two such tables, both of 16 entries, at 0xF7048D and
;                   0xF72323.  0xF724CB is an instruction boundary of this
;                   transcription, re-asserted on every emit.  The name IS
;                   the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_Pan_MultiTrack: SmfEvent_ControlChange_MultiTrack's DispatchTable_F72323[10], CC 10 -- the multi-track copy of SmfCC_Pan.
SmfCC_Pan_MultiTrack:
	ld	iy, (4530:16)	; F724CB  ld IY,(0x11b2)
	calr	Smf_TrackToSlot	; F724CF  calr 0xf728fe
	and	iy, 15	; F724D2  and IY,0x000f
	calr	BStore_LoadTrackCursor	; F724D6  calr 0xf727c8
	push	xiy	; F724D9  push XIY
	ld	a, 176:opc	; F724DA  ld A,0xb0
	calr	BStore_PutByteAndAdvance	; F724DC  calr 0xf70fda
	pop	xiy	; F724DF  pop XIY
	cp	(0x1238:16), 0x00	; F724E0  cp (0x1238),0x00
	jr	nz, SmfCC_Pan_MultiTrack_Return	; F724E5  jr NZ,0xf72554
	sla	iy, 1	; F724E7  sla 0x01,IY
	push	xix	; F724EA  push XIX
	ld	xix, 4307	; F724EB  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F724F0  ld WA,(XIX+IY)
	pop	xix	; F724F5  pop XIX
	srl	iy, 1	; F724F6  srl 0x01,IY
	push	xiy	; F724F9  push XIY
	calr	Smf_TicksToPpq96	; F724FA  calr 0xf7122f
	pop	xiy	; F724FD  pop XIY
	push	xiy	; F724FE  push XIY
	calr	BStore_PutByteAndAdvance	; F724FF  calr 0xf70fda
	pop	xiy	; F72502  pop XIY
	cp	(0x1238:16), 0x00	; F72503  cp (0x1238),0x00
	jr	nz, SmfCC_Pan_MultiTrack_Return	; F72508  jr NZ,0xf72554
	ld	a, (Smf_EventStatus:16)	; F7250A  ld A,(0x10d0)
	and	a, 15	; F7250E  and A,0x0f
	push	xiy	; F72511  push XIY
	calr	BStore_PutByteAndAdvance	; F72512  calr 0xf70fda
	pop	xiy	; F72515  pop XIY
	cp	(0x1238:16), 0x00	; F72516  cp (0x1238),0x00
	jr	nz, SmfCC_Pan_MultiTrack_Return	; F7251B  jr NZ,0xf72554
	ld	a, 8:opc	; F7251D  ld A,0x08
	push	xiy	; F7251F  push XIY
	calr	BStore_PutByteAndAdvance	; F72520  calr 0xf70fda
	pop	xiy	; F72523  pop XIY
	cp	(0x1238:16), 0x00	; F72524  cp (0x1238),0x00
	jr	nz, SmfCC_Pan_MultiTrack_Return	; F72529  jr NZ,0xf72554
	ld	a, (4306:16)	; F7252B  ld A,(0x10d2)
	push	xiy	; F7252F  push XIY
	calr	BStore_PutByteAndAdvance	; F72530  calr 0xf70fda
	pop	xiy	; F72533  pop XIY
	cp	(0x1238:16), 0x00	; F72534  cp (0x1238),0x00
	jr	nz, SmfCC_Pan_MultiTrack_Return	; F72539  jr NZ,0xf72554
	ld	a, 127:opc	; F7253B  ld A,0x7f
	push	xiy	; F7253D  push XIY
	calr	BStore_PutByteAndAdvance	; F7253E  calr 0xf70fda
	pop	xiy	; F72541  pop XIY
	cp	(0x1238:16), 0x00	; F72542  cp (0x1238),0x00
	jr	nz, SmfCC_Pan_MultiTrack_Return	; F72547  jr NZ,0xf72554
	calr	SmfEvent_MarkChannelUsed	; F72549  calr 0xf7129a
	calr	BStore_SaveTrackCursor	; F7254C  calr 0xf727f6
	ld	(4664:16), 0	; F7254F  ld (0x1238),0x00
SmfCC_Pan_MultiTrack_Return:
	ret	; F72554  ret

; --------------------------------------------------------------------------
; ByteMap_F72555 -- 33 bytes: 2 BYTE MAPS end to end, 16 bytes at 0xF72555
;                   (0x00..0x0F), 17 bytes at 0xF72565 (0x00..0xD1).  Each
;                   ascends STRICTLY on its own and the sequence RESTARTS at
;                   each boundary, so this is N maps of the same shape
;                   rather than one long one.  The name describes the
;                   CONTENT; what the index spaces are is not established
;                   here.
; Read by: nothing in prom_a or prom_b spells this address as a 32-bit word,
;          so whatever reaches it computes the address
; Entry count: 33 bytes.  The run is trimmed of trailing 0xFF, so it claims
;              no padding it did not earn; the byte before it is 0x0E and
;              the LAST byte of it is 0xD1.
; Evidence: every non-0xFF byte is compared with its predecessor on every
;           emit, WITHIN EACH of the 2 maximal ascending runs the rule
;           returns, and the runs are asserted to tile this segment exactly.
;           The BYTEMAP rule fires ZERO times over the proven prom_b
;           instruction text at (16 bytes, 12 values) and also at (20,14),
;           (24,16) and (16,16) (`python3 notes/prom_b_f6d002_layout.py
;           --null-ptr`).
; Unknown: what the two index spaces ARE, and who reads it.
; --------------------------------------------------------------------------
; ⚠ CORRECTED 2026-10-04: the 33rd byte below, 0xD1 at 0xF72575, is NOT part of this map.  It is the first byte of
;   SmfCC_Expression_MultiTrack (`d1 b2 11 25` = ld IY,(0x11B2)), which SmfCC_HandlersByNumber_MultiTrack[11] -- CC 11 --
;   names.  The map is the 32 bytes 0xF72555-0xF72574, two 0..15 runs; the routine is converted below.
ByteMap_F72555:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F72555  [0..15]
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F72565  [16..31]


; --------------------------------------------------------------------------
; Data_F72576 -- 99 bytes this block could not split.  No content rule
;                framed it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or
;                ASCII -- and the code walk never reached it from a thunk
;                slot, a proven call site, an opcode-anchored call or an
;                entry of a table the firmware transfers to.  So it is
;                emitted as bytes rather than guessed.
; Contains: printable bytes |..%.......=.D....
;           ...!....H.].8.?.n>...<D........
;           \...=...]=.%.].8.?.n....!=...].8.?.n.....#..8....|
; Read by: nothing in prom_a or prom_b spells this address as a 32-bit word,
;          so whatever reaches it computes the address
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; Unknown: everything about it except its bytes.
; --------------------------------------------------------------------------
; 2026-10-04: these 99 bytes, with the 0xD1 before them, are the routine SmfCC_Expression_MultiTrack (0xF72575-0xF725D8):
;   SmfCC_HandlersByNumber_MultiTrack[11] names its first byte, and unidasm decodes the span into 37 whole instructions ending
;   on the `ret` before SmfCC_BankSelectLsb_MultiTrack.  Its shape is SmfEvent_ChannelPressure_MultiTrack's: slot cursor, status
;   0xF0 | channel, the time (Smf_TicksToPpq96), the value (0x10D2), then BStore_SaveTrackCursor.
; SmfCC_Expression_MultiTrack: the multi-track copy of SmfCC_Expression (CC 11).
SmfCC_Expression_MultiTrack:
	ld	iy, (4530:16)	; F72575  ld IY,(0x11b2)
	calr	Smf_TrackToSlot	; F72579  calr 0xf728fe
	and	iy, 15	; F7257C  and IY,0x000f
	push	xiy	; F72580  push XIY
	calr	BStore_LoadTrackCursor	; F72581  calr 0xf727c8
	ld	w, (Smf_EventStatus:16)	; F72584  ld W,(0x10d0)
	and	w, 15	; F72588  and W,0x0f
	ld	a, 240:opc	; F7258B  ld A,0xf0
	or	a, w	; F7258D  or A,W
	calr	BStore_PutByteAndAdvance	; F7258F  calr 0xf70fda
	pop	xiy	; F72592  pop XIY
	cp	(0x1238:16), 0x00	; F72593  cp (0x1238),0x00
	jr	nz, SmfCC_Expression_MultiTrack_Return	; F72598  jr NZ,0xf725d8
	sla	xiy, 1	; F7259A  sla 0x01,XIY
	push	xix	; F7259D  push XIX
	ld	xix, 4307	; F7259E  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F725A3  ld WA,(XIX+IY)
	pop	xix	; F725A8  pop XIX
	srl	xiy, 1	; F725A9  srl 0x01,XIY
	push	xiy	; F725AC  push XIY
	calr	Smf_TicksToPpq96	; F725AD  calr 0xf7122f
	pop	xiy	; F725B0  pop XIY
	push	xiy	; F725B1  push XIY
	calr	BStore_PutByteAndAdvance	; F725B2  calr 0xf70fda
	pop	xiy	; F725B5  pop XIY
	cp	(0x1238:16), 0x00	; F725B6  cp (0x1238),0x00
	jr	nz, SmfCC_Expression_MultiTrack_Return	; F725BB  jr NZ,0xf725d8
	ld	a, (4306:16)	; F725BD  ld A,(0x10d2)
	push	xiy	; F725C1  push XIY
	calr	BStore_PutByteAndAdvance	; F725C2  calr 0xf70fda
	pop	xiy	; F725C5  pop XIY
	cp	(0x1238:16), 0x00	; F725C6  cp (0x1238),0x00
	jr	nz, SmfCC_Expression_MultiTrack_Return	; F725CB  jr NZ,0xf725d8
	calr	SmfEvent_MarkChannelUsed	; F725CD  calr 0xf7129a
	calr	BStore_SaveTrackCursor	; F725D0  calr 0xf727f6
	ld	(4664:16), 0	; F725D3  ld (0x1238),0x00
SmfCC_Expression_MultiTrack_Return:
	ret	; F725D8  ret


; --------------------------------------------------------------------------
; SmfCC_BankSelectLsb_MultiTrack
; Called from: in-module: 0xF722DF
; Touches: (0x10D0) (0x10D2) (0x11AE) (0x11AF) (0x11B0) (0x11B1) (0x1238)
; Calls:   SmfCC_Sustain_Nop SmfCC_PutPartParamEvent_MultiTrack
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF725D9 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_BankSelectLsb_MultiTrack: SmfEvent_ControlChange_MultiTrack's `cp A,32` arm, CC 32 -- the multi-track copy of SmfCC_BankSelectLsb.
SmfCC_BankSelectLsb_MultiTrack:
	ld	iy, (Smf_EventStatus:16)	; F725D9  ld IY,(0x10d0)
	and	iy, 15	; F725DD  and IY,0x000f
	ld	a, (4306:16)	; F725E1  ld A,(0x10d2)
	push	xde	; F725E5  push XDE
	ld	xde, 4260	; F725E6  ld XDE,0x000010a4
	ld	(xde+iy), a	; F725EB  ld (XDE+IY),A
	pop	xde	; F725F0  pop XDE
	ret	; F725F1  ret
	push	xix	; F725F2  push XIX
	ld	xix, 4242	; F725F3  ld XIX,0x00001092
	ld	w, (xix+iy)	; F725F8  ld W,(XIX+IY)
	pop	xix	; F725FD  pop XIX
	and	a, 127	; F725FE  and A,0x7f
	rrc	w	; F72601  rrc 0x01,W
	ld	l, w	; F72604  ld L,W
	and	l, 128	; F72606  and L,0x80
	and	w, 127	; F72609  and W,0x7f
	or	a, l	; F7260C  or A,L
	ret	; F7260E  ret
	bit	0, (0x11b1:16)	; F7260F  bit 0,(0x11b1)
	jr	nz, SmfCC_BankSelectLsb_MultiTrack_Skip	; F72613  jr NZ,0xf7261d
	calr	SmfCC_Sustain_Nop	; F72615  calr 0xf7083a
	ld	(4664:16), 0	; F72618  ld (0x1238),0x00
SmfCC_BankSelectLsb_MultiTrack_Skip:
	ld	(4526:16), 4	; F7261D  ld (0x11ae),0x04
	xor	a, a	; F72622  xor A,A
	cp	(0x10d2:16), 0x40	; F72624  cp (0x10d2),0x40
	jr	c, SmfCC_BankSelectLsb_MultiTrack_Skip2	; F72629  jr C,0xf7262d
	ld	a, 8:opc	; F7262B  ld A,0x08
SmfCC_BankSelectLsb_MultiTrack_Skip2:
	ld	(4527:16), a	; F7262D  ld (0x11af),A
	ld	(4528:16), 8	; F72631  ld (0x11b0),0x08
	calr	SmfCC_PutPartParamEvent_MultiTrack	; F72636  calr 0xf726c6
	ret	; F72639  ret

; --------------------------------------------------------------------------
; SmfCC_Effect1Depth_MultiTrack
; Called from: in-module: 0xF722FB
; Touches: (0x10D2) (0x11AE) (0x11AF) (0x11B0) (0x11B1) (0x1238) (0x1239)
;          (0x124B) (0x2732)
; Calls:   SmfPart_ResetAllRecords SmfPart_SetEffect1Depth SmfCC_PutPartParamEvent_MultiTrack
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF7263A is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_Effect1Depth_MultiTrack: SmfEvent_ControlChange_MultiTrack's `cp A,91` arm, CC 91 -- the multi-track copy of SmfCC_Effect1Depth.
SmfCC_Effect1Depth_MultiTrack:
	bit	0, (0x124b:16)	; F7263A  bit 0,(0x124b)
	jr	nz, SmfCC_Effect1Depth_MultiTrack_Skip2	; F7263E  jr NZ,0xf7265a
	ld	(4665:16), 255	; F72640  ld (0x1239),0xff
	cp	(0x2732:16), 0x00	; F72645  cp (0x2732),0x00
	jr	nz, SmfCC_Effect1Depth_MultiTrack_Skip	; F7264A  jr NZ,0xf72651
	ld	(4665:16), 0	; F7264C  ld (0x1239),0x00
SmfCC_Effect1Depth_MultiTrack_Skip:
	ld	(4683:16), 1	; F72651  ld (0x124b),0x01
	call	SmfPart_ResetAllRecords	; F72656  call 0xf71417
SmfCC_Effect1Depth_MultiTrack_Skip2:
	bit	0, (0x11b1:16)	; F7265A  bit 0,(0x11b1)
	jr	nz, SmfCC_Effect1Depth_MultiTrack_Skip3	; F7265E  jr NZ,0xf72668
	calr	SmfPart_SetEffect1Depth	; F72660  calr 0xf70a30
	ld	(4664:16), 0	; F72663  ld (0x1238),0x00
SmfCC_Effect1Depth_MultiTrack_Skip3:
	ld	(4526:16), 7	; F72668  ld (0x11ae),0x07
	ld	a, (4306:16)	; F7266D  ld A,(0x10d2)
	ld	(4527:16), a	; F72671  ld (0x11af),A
	ld	(4528:16), 127	; F72675  ld (0x11b0),0x7f
	calr	SmfCC_PutPartParamEvent_MultiTrack	; F7267A  calr 0xf726c6
	ret	; F7267D  ret

; --------------------------------------------------------------------------
; SmfCC_Effect3Depth_MultiTrack
; Called from: in-module: 0xF72301
; Touches: (0x10D2) (0x11AE) (0x11AF) (0x11B0) (0x11B1) (0x1238)
; Calls:   SmfPart_SetEffect3Depth SmfCC_PutPartParamEvent_MultiTrack
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7267E is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_Effect3Depth_MultiTrack: SmfEvent_ControlChange_MultiTrack's `cp A,93` arm, CC 93 -- the multi-track copy of SmfCC_Effect3Depth.
SmfCC_Effect3Depth_MultiTrack:
	bit	0, (0x11b1:16)	; F7267E  bit 0,(0x11b1)
	jr	nz, SmfCC_Effect3Depth_MultiTrack_Skip	; F72682  jr NZ,0xf7268c
	calr	SmfPart_SetEffect3Depth	; F72684  calr 0xf709a3
	ld	(4664:16), 0	; F72687  ld (0x1238),0x00
SmfCC_Effect3Depth_MultiTrack_Skip:
	ld	(4526:16), 5	; F7268C  ld (0x11ae),0x05
	ld	a, (4306:16)	; F72691  ld A,(0x10d2)
	ld	(4527:16), a	; F72695  ld (0x11af),A
	ld	(4528:16), 127	; F72699  ld (0x11b0),0x7f
	calr	SmfCC_PutPartParamEvent_MultiTrack	; F7269E  calr 0xf726c6
	ret	; F726A1  ret

; --------------------------------------------------------------------------
; SmfCC_Effect4Depth_MultiTrack
; Called from: in-module: 0xF72306
; Touches: (0x10D2) (0x11AE) (0x11AF) (0x11B0) (0x11B1) (0x1238)
; Calls:   SmfPart_SetEffect4Depth SmfCC_PutPartParamEvent_MultiTrack
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF726A2 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_Effect4Depth_MultiTrack: SmfEvent_ControlChange_MultiTrack's `cp A,94` arm, CC 94 -- the multi-track copy of SmfCC_Effect4Depth.
SmfCC_Effect4Depth_MultiTrack:
	bit	0, (0x11b1:16)	; F726A2  bit 0,(0x11b1)
	jr	nz, SmfCC_Effect4Depth_MultiTrack_Skip	; F726A6  jr NZ,0xf726b0
	calr	SmfPart_SetEffect4Depth	; F726A8  calr 0xf709da
	ld	(4664:16), 0	; F726AB  ld (0x1238),0x00
SmfCC_Effect4Depth_MultiTrack_Skip:
	ld	(4526:16), 6	; F726B0  ld (0x11ae),0x06
	ld	a, (4306:16)	; F726B5  ld A,(0x10d2)
	ld	(4527:16), a	; F726B9  ld (0x11af),A
	ld	(4528:16), 127	; F726BD  ld (0x11b0),0x7f
	calr	SmfCC_PutPartParamEvent_MultiTrack	; F726C2  calr 0xf726c6
	ret	; F726C5  ret

; --------------------------------------------------------------------------
; SmfCC_PutPartParamEvent_MultiTrack
; Called from: in-module: 0xF724C7 0xF72636 0xF7267A 0xF7269E 0xF726C2
; Touches: (0x10D0) (0x11AE) (0x11AF) (0x11B0) (0x11B2) (0x1238)
; Calls:   Smf_TrackToSlot BStore_LoadTrackCursor BStore_PutByteAndAdvance Smf_TicksToPpq96 SmfEvent_MarkChannelUsed BStore_SaveTrackCursor
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF726C6 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfCC_PutPartParamEvent_MultiTrack: Multi-track path: stores in slot Smf_TrackToSlot((0x11B2)) the 0xB0 parameter
;   event {0xB0, tick, channel, (0x11AE) class, (0x11AF) value, (0x11B0) mask}, then marks the channel and saves the
;   slot cursor; its callers set class 3 (SmfCC_Volume_MultiTrack), 7, 5, 6 (Effect1/3/4 depth) and 4 (value 0/8 by
;   data >= 0x40, mask 8). Basis: callers + body. (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
SmfCC_PutPartParamEvent_MultiTrack:
	ld	iy, (4530:16)	; F726C6  ld IY,(0x11b2)
	calr	Smf_TrackToSlot	; F726CA  calr 0xf728fe
	and	iy, 15	; F726CD  and IY,0x000f
	push	xiy	; F726D1  push XIY
	calr	BStore_LoadTrackCursor	; F726D2  calr 0xf727c8
	ld	a, 176:opc	; F726D5  ld A,0xb0
	calr	BStore_PutByteAndAdvance	; F726D7  calr 0xf70fda
	pop	xiy	; F726DA  pop XIY
	cp	(0x1238:16), 0x00	; F726DB  cp (0x1238),0x00
	jr	nz, SmfCC_PutPartParamEvent_MultiTrack_Return	; F726E0  jr NZ,0xf72753
	sla	iy, 1	; F726E2  sla 0x01,IY
	push	xix	; F726E5  push XIX
	ld	xix, 4307	; F726E6  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F726EB  ld WA,(XIX+IY)
	pop	xix	; F726F0  pop XIX
	srl	iy, 1	; F726F1  srl 0x01,IY
	push	xiy	; F726F4  push XIY
	calr	Smf_TicksToPpq96	; F726F5  calr 0xf7122f
	pop	xiy	; F726F8  pop XIY
	push	xiy	; F726F9  push XIY
	calr	BStore_PutByteAndAdvance	; F726FA  calr 0xf70fda
	pop	xiy	; F726FD  pop XIY
	cp	(0x1238:16), 0x00	; F726FE  cp (0x1238),0x00
	jr	nz, SmfCC_PutPartParamEvent_MultiTrack_Return	; F72703  jr NZ,0xf72753
	ld	a, (Smf_EventStatus:16)	; F72705  ld A,(0x10d0)
	and	a, 15	; F72709  and A,0x0f
	push	xiy	; F7270C  push XIY
	calr	BStore_PutByteAndAdvance	; F7270D  calr 0xf70fda
	pop	xiy	; F72710  pop XIY
	cp	(0x1238:16), 0x00	; F72711  cp (0x1238),0x00
	jr	nz, SmfCC_PutPartParamEvent_MultiTrack_Return	; F72716  jr NZ,0xf72753
	ld	a, (4526:16)	; F72718  ld A,(0x11ae)
	push	xiy	; F7271C  push XIY
	calr	BStore_PutByteAndAdvance	; F7271D  calr 0xf70fda
	pop	xiy	; F72720  pop XIY
	cp	(0x1238:16), 0x00	; F72721  cp (0x1238),0x00
	jr	nz, SmfCC_PutPartParamEvent_MultiTrack_Return	; F72726  jr NZ,0xf72753
	ld	a, (4527:16)	; F72728  ld A,(0x11af)
	push	xiy	; F7272C  push XIY
	calr	BStore_PutByteAndAdvance	; F7272D  calr 0xf70fda
	pop	xiy	; F72730  pop XIY
	cp	(0x1238:16), 0x00	; F72731  cp (0x1238),0x00
	jr	nz, SmfCC_PutPartParamEvent_MultiTrack_Return	; F72736  jr NZ,0xf72753
	ld	a, (4528:16)	; F72738  ld A,(0x11b0)
	push	xiy	; F7273C  push XIY
	calr	BStore_PutByteAndAdvance	; F7273D  calr 0xf70fda
	pop	xiy	; F72740  pop XIY
	cp	(0x1238:16), 0x00	; F72741  cp (0x1238),0x00
	jr	nz, SmfCC_PutPartParamEvent_MultiTrack_Return	; F72746  jr NZ,0xf72753
	calr	SmfEvent_MarkChannelUsed	; F72748  calr 0xf7129a
	calr	BStore_SaveTrackCursor	; F7274B  calr 0xf727f6
	ld	(4664:16), 0	; F7274E  ld (0x1238),0x00
SmfCC_PutPartParamEvent_MultiTrack_Return:
	ret	; F72753  ret

; --------------------------------------------------------------------------
; SmfEvent_PitchBend_MultiTrack
; Called from: in-module: 0xF71E18
; Touches: (0x10D0) (0x10D1) (0x10D2) (0x11B2) (0x1238)
; Calls:   Smf_TrackToSlot BStore_LoadTrackCursor BStore_PutByteAndAdvance Smf_TicksToPpq96 SmfEvent_MarkChannelUsed BStore_SaveTrackCursor
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72754 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfEvent_PitchBend_MultiTrack: SmfEvent_DispatchChannelMessage_MultiTrack's arm for status 0xE0.
SmfEvent_PitchBend_MultiTrack:
	ld	iy, (4530:16)	; F72754  ld IY,(0x11b2)
	calr	Smf_TrackToSlot	; F72758  calr 0xf728fe
	and	iy, 15	; F7275B  and IY,0x000f
	push	xiy	; F7275F  push XIY
	calr	BStore_LoadTrackCursor	; F72760  calr 0xf727c8
	ld	w, (Smf_EventStatus:16)	; F72763  ld W,(0x10d0)
	and	w, 15	; F72767  and W,0x0f
	ld	a, 224:opc	; F7276A  ld A,0xe0
	or	a, w	; F7276C  or A,W
	calr	BStore_PutByteAndAdvance	; F7276E  calr 0xf70fda
	pop	xiy	; F72771  pop XIY
	cp	(0x1238:16), 0x00	; F72772  cp (0x1238),0x00
	jr	nz, SmfEvent_PitchBend_MultiTrack_Return	; F72777  jr NZ,0xf727c7
	sla	xiy, 1	; F72779  sla 0x01,XIY
	push	xix	; F7277C  push XIX
	ld	xix, 4307	; F7277D  ld XIX,0x000010d3
	ld	wa, (xix+iy)	; F72782  ld WA,(XIX+IY)
	pop	xix	; F72787  pop XIX
	srl	xiy, 1	; F72788  srl 0x01,XIY
	push	xiy	; F7278B  push XIY
	calr	Smf_TicksToPpq96	; F7278C  calr 0xf7122f
	pop	xiy	; F7278F  pop XIY
	push	xiy	; F72790  push XIY
	calr	BStore_PutByteAndAdvance	; F72791  calr 0xf70fda
	pop	xiy	; F72794  pop XIY
	cp	(0x1238:16), 0x00	; F72795  cp (0x1238),0x00
	jr	nz, SmfEvent_PitchBend_MultiTrack_Return	; F7279A  jr NZ,0xf727c7
	push	xiy	; F7279C  push XIY
	ld	a, (4305:16)	; F7279D  ld A,(0x10d1)
	calr	BStore_PutByteAndAdvance	; F727A1  calr 0xf70fda
	pop	xiy	; F727A4  pop XIY
	cp	(0x1238:16), 0x00	; F727A5  cp (0x1238),0x00
	jr	nz, SmfEvent_PitchBend_MultiTrack_Return	; F727AA  jr NZ,0xf727c7
	push	xiy	; F727AC  push XIY
	ld	a, (4306:16)	; F727AD  ld A,(0x10d2)
	calr	BStore_PutByteAndAdvance	; F727B1  calr 0xf70fda
	pop	xiy	; F727B4  pop XIY
	cp	(0x1238:16), 0x00	; F727B5  cp (0x1238),0x00
	jr	nz, SmfEvent_PitchBend_MultiTrack_Return	; F727BA  jr NZ,0xf727c7
	calr	SmfEvent_MarkChannelUsed	; F727BC  calr 0xf7129a
	calr	BStore_SaveTrackCursor	; F727BF  calr 0xf727f6
	ld	(4664:16), 0	; F727C2  ld (0x1238),0x00
SmfEvent_PitchBend_MultiTrack_Return:
	ret	; F727C7  ret

; --------------------------------------------------------------------------
; BStore_LoadTrackCursor
; Called from: in-module: 0xF71E31 0xF71F1A 0xF71FD1 0xF720DF 0xF72389
;              0xF724D6 0xF726D2 0xF72760 +1 more
; Touches: (0x11B2) (0x345C) (0x345E)
; Calls:   Smf_TrackToSlot
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF727C8 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_LoadTrackCursor: BStore_CursorBlock / BStore_CursorOffset = the saved cursor of slot Smf_TrackToSlot((0x11B2)): word 0x3460[slot], byte
;     0x3482[slot].  Called before each multi-track event write; BStore_SaveTrackCursor after it.
BStore_LoadTrackCursor:
	push	xde	; F727C8  push XDE
	ld	iy, (4530:16)	; F727C9  ld IY,(0x11b2)
	calr	Smf_TrackToSlot	; F727CD  calr 0xf728fe
	sla	iy, 1	; F727D0  sla 0x01,IY
	ld	xde, 13408	; F727D3  ld XDE,0x00003460
	ld	wa, (xde+iy)	; F727D8  ld WA,(XDE+IY)
	ld	(BStore_CursorBlock:16), wa	; F727DD  ld (0x345c),WA
	srl	iy, 1	; F727E1  srl 0x01,IY
	ld	xde, 13442	; F727E4  ld XDE,0x00003482
	ld	a, (xde+iy)	; F727E9  ld A,(XDE+IY)
	xor	w, w	; F727EE  xor W,W
	ld	(BStore_CursorOffset:16), wa	; F727F0  ld (0x345e),WA
	pop	xde	; F727F4  pop XDE
	ret	; F727F5  ret

; --------------------------------------------------------------------------
; BStore_SaveTrackCursor
; Called from: in-module: 0xF71E80 0xF71FC5 0xF7206A 0xF72181 0xF723D8
;              0xF7254C 0xF7274B 0xF727BF
; Touches: (0x11B2) (0x345C) (0x345E)
; Calls:   Smf_TrackToSlot
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF727F6 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_SaveTrackCursor: stores BStore_CursorBlock / BStore_CursorOffset back into 0x3460[slot] / 0x3482[slot].
BStore_SaveTrackCursor:
	push	xde	; F727F6  push XDE
	ld	iy, (4530:16)	; F727F7  ld IY,(0x11b2)
	calr	Smf_TrackToSlot	; F727FB  calr 0xf728fe
	ld	wa, (BStore_CursorBlock:16)	; F727FE  ld WA,(0x345c)
	sla	xiy, 1	; F72802  sla 0x01,XIY
	ld	xde, 13408	; F72805  ld XDE,0x00003460
	ld	(xde+iy), wa	; F7280A  ld (XDE+IY),WA
	ld	wa, (BStore_CursorOffset:16)	; F7280F  ld WA,(0x345e)
	srl	xiy, 1	; F72813  srl 0x01,XIY
	ld	xde, 13442	; F72816  ld XDE,0x00003482
	ld	(xde+iy), a	; F7281B  ld (XDE+IY),A
	pop	xde	; F72820  pop XDE
	ret	; F72821  ret

; --------------------------------------------------------------------------
; Smf_AllocFirstBlockForTrackSlot
; Called from: in-module: 0xF71BA8
; Touches: (0x11B2) (0x126E) (0x3608)  |  0x603500
; Calls:   Smf_TrackToSlot T_BStore_AllocBlock_Veneer SongStore_SeekBlock_Copy
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72822 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_AllocFirstBlockForTrackSlot: Multi-track import: for slot Smf_TrackToSlot((0x11B2)), while at least 17 blocks
;   are free, allocates a block (T_BStore_AllocBlock_Veneer), marks it used with no links, sets the directory entry's
;   in-use bit and head, and points the slot's song position (0x3460 / 0x3482) at offset 5. Smf_ReadMultiTrack calls
;   it before each MTrk chunk; the per-slot form of Smf_AllocFirstBlockForAllTracks. Basis: caller + body + sibling.
;   (notes/naming-pilot-2026-10-06/proposals_wave6_v.json)
Smf_AllocFirstBlockForTrackSlot:
	ld	iy, (4530:16)	; F72822  ld IY,(0x11b2)
	calr	Smf_TrackToSlot	; F72826  calr 0xf728fe
	ld	ix, iy	; F72829  ld IX,IY
	cpw	(BStore_FreeCount:24), 0x0011	; F7282B  cp (0x6034ba),0x0011
	jr	c, Smf_AllocFirstBlockForTrackSlot_Return	; F72832  jr C,0xf728a2
	push	xiy	; F72834  push XIY
	push	xix	; F72835  push XIX
	call	T_BStore_AllocBlock_Veneer	; F72836  call 0xf42884
	ld	wa, ix	; F7283A  ld WA,IX
	pop	xix	; F7283C  pop XIX
	pop	xiy	; F7283D  pop XIY
	ld	bc, (BStore_BlockCount:16)	; F7283E  ld BC,(0x3608)
	cp	wa, bc	; F72842  cp WA,BC
	jr	ugt, Smf_AllocFirstBlockForTrackSlot_Return	; F72844  jr UGT,0xf728a2
	cp	wa, 0:i3	; F72846  cp WA,0
	jr	z, Smf_AllocFirstBlockForTrackSlot_Return	; F72848  jr Z,0xf728a2
	pushw	wa	; F7284A  push WA
	ld	hl, wa	; F7284B  ld HL,WA
	calr	SongStore_SeekBlock_Copy	; F7284D  calr 0xf72f0a
	ld	xhl, (BStore_CursorBlockAddr:16)	; F72850  ld XHL,(0x126e)
	or	(xhl), 0x80	; F72854  or (XHL),0x80
	ldw	(xhl+1), 0x0000	; F72857  ld (XHL+0x01),0x0000
	ldw	(xhl+3), 0xffff	; F7285C  ld (XHL+0x03),0xffff
	popw	wa	; F72861  pop WA
	ld	hl, iy	; F72862  ld HL,IY
	sla	iy, 1	; F72864  sla 0x01,IY
	add	iy, hl	; F72867  add IY,HL
	ld	xhl, 6305024	; F72869  ld XHL,0x00603500
	or	(xhl+iy), 0x80	; F7286E  or (XHL+IY),0x80
	ldfr_lerp	xhl, 0x38	; F72874  ld XDE3,XHL
	lda	xhl, (xhl+iy)	; F72877  lda XHL,XHL+IY
	ld	(xhl+1), wa	; F7287C  ld (XHL+0x01),WA
	ldto_lerp	xhl, 0x38	; F7287F  ld XHL,XDE3
	ld	xhl, 13408	; F72882  ld XHL,0x00003460
	sla	ix, 1	; F72887  sla 0x01,IX
	ld	(xhl+ix), wa	; F7288A  ld (XHL+IX),WA
	ld	xhl, 13442	; F7288F  ld XHL,0x00003482
	ld	iy, (4530:16)	; F72894  ld IY,(0x11b2)
	calr	Smf_TrackToSlot	; F72898  calr 0xf728fe
	ldw	(xhl+iy), 0x0005	; F7289B  ld (XHL+IY),0x0005
Smf_AllocFirstBlockForTrackSlot_Return:
	ret	; F728A2  ret

; --------------------------------------------------------------------------
; Smf_TerminateTrackSlot
; Called from: in-module: 0xF71CE2
; Touches: (0x11B2)  |  0x603500
; Calls:   Smf_TrackToSlot BStore_LoadTrackCursor BStore_PutByteAtCursor Smf_SaveSlotEndCursor
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF728A3 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_TerminateTrackSlot: Multi-track import: if slot Smf_TrackToSlot((0x11B2))'s directory entry is in use, writes
;   the 0x82 end tag at its cursor (BStore_LoadTrackCursor) and saves that position as the slot's end cursor 0x6034A0
;   / 0x60347E (Smf_SaveSlotEndCursor). Smf_ReadTrackChunk runs it at the chunk's End of Track ((0x10CB) = 0xFF); the per-slot
;   form of Smf_TerminateUsedTracks. Basis: caller + body + sibling. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_v.json)
Smf_TerminateTrackSlot:
	ld	hl, (4530:16)	; F728A3  ld HL,(0x11b2)
	ld	iy, hl	; F728A7  ld IY,HL
	calr	Smf_TrackToSlot	; F728A9  calr 0xf728fe
	ld	hl, iy	; F728AC  ld HL,IY
	sla	iy, 1	; F728AE  sla 0x01,IY
	add	iy, hl	; F728B1  add IY,HL
	push	xde	; F728B3  push XDE
	ld	xde, 6305024	; F728B4  ld XDE,0x00603500
	bit	7, (xde+iy)	; F728B9  bit 7,(XDE+IY)
	pop	xde	; F728BE  pop XDE
	jr	z, Smf_TerminateTrackSlot_Return	; F728BF  jr Z,0xf728d4
	ld	iy, (4530:16)	; F728C1  ld IY,(0x11b2)
	ld	hl, iy	; F728C5  ld HL,IY
	push	xhl	; F728C7  push XHL
	calr	BStore_LoadTrackCursor	; F728C8  calr 0xf727c8
	ld	a, 130:opc	; F728CB  ld A,0x82
	calr	BStore_PutByteAtCursor	; F728CD  calr 0xf70fe1
	calr	Smf_SaveSlotEndCursor	; F728D0  calr 0xf728d5
	pop	xhl	; F728D3  pop XHL
Smf_TerminateTrackSlot_Return:
	ret	; F728D4  ret

; --------------------------------------------------------------------------
; Smf_SaveSlotEndCursor
; Called from: in-module: 0xF728D0
; Touches: (0x345C) (0x345E)  |  0x60347E 0x6034A0
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF728D5 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_SaveSlotEndCursor: End cursor of slot min(HL, 1) := the BStore cursor: 0x6034A0[slot] := BStore_CursorOffset,
;   0x60347E[slot] := BStore_CursorBlock. Smf_TerminateTrackSlot runs it with HL = the track counter (0x11B2) after
;   writing the 0x82 end tag; the per-slot form of Smf_SaveTrackEndCursor. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_y.json)
Smf_SaveSlotEndCursor:
	push	xix	; F728D5  push XIX
	cp	hl, 1:i3	; F728D6  cp HL,1
	jr	ule, Smf_SaveSlotEndCursor_Skip	; F728D8  jr ULE,0xf728dd
	ldw	hl, 1	; F728DA  ld HL,0x0001
Smf_SaveSlotEndCursor_Skip:
	ld	wa, (BStore_CursorOffset:16)	; F728DD  ld WA,(0x345e)
	ld	xix, 6304928	; F728E1  ld XIX,0x006034a0
	ld	(xix+hl), a	; F728E6  ld (XIX+HL),A
	sla	hl, 1	; F728EB  sla 0x01,HL
	ld	wa, (BStore_CursorBlock:16)	; F728EE  ld WA,(0x345c)
	ld	xix, 6304894	; F728F2  ld XIX,0x0060347e
	ld	(xix+hl), wa	; F728F7  ld (XIX+HL),WA
	pop	xix	; F728FC  pop XIX
	ret	; F728FD  ret

; --------------------------------------------------------------------------
; Smf_TrackToSlot
; Called from: in-module: 0xF71C8E 0xF71E27 0xF71EB5 0xF720D6 0xF72381
;              0xF724CF 0xF726CA 0xF72758 +5 more
; Touches: nothing with an absolute address
; Calls:   SongStore_SeekBlock_Copy Smf_BusyDelay Smf_MergeTrack2IntoTrack1 Smf_ResultToStatusCode
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF728FE is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_TrackToSlot: IY = min(IY, 1), zero-extended: every source track above 1 shares slot 1.  Followed by four unreferenced one-call stubs.
Smf_TrackToSlot:
	cp	iy, 1:i3	; F728FE  cp IY,1
	jr	ule, Smf_TrackToSlot_Skip	; F72900  jr ULE,0xf72905
	ldw	iy, 1	; F72902  ld IY,0x0001
Smf_TrackToSlot_Skip:
	extz	xiy	; F72905  extz XIY
	ret	; F72907  ret
	calr	SongStore_SeekBlock_Copy	; F72908  calr 0xf72f0a
	ret	; F7290B  ret
	calr	Smf_BusyDelay	; F7290C  calr 0xf72f20
	ret	; F7290F  ret
	calr	Smf_MergeTrack2IntoTrack1	; F72910  calr 0xf729d9
	ret	; F72913  ret
	calr	Smf_ResultToStatusCode	; F72914  calr 0xf72f2d
	ret	; F72917  ret

; --------------------------------------------------------------------------
; SmfExport_MergeUsedTracksIntoFirst
; Called from: in-module: 0xF739C3
; Touches: (0x0C70) (0x0C71) (0x0C72) (0x360C) (0x360E)  |  0x603500
; Calls:   Smf_MergeTracks
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF72918 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfExport_MergeUsedTracksIntoFirst: Counts the used tracks (bit in (0x360C)/(0x360E) and directory entry in use);
;   with two or more, merges every later track whose mask bit is set into the first used one: (0x0C70) = first,
;   (0x0C71) = t, (0x0C72) = first, Smf_MergeTracks -- one track for the format-0 file. Smf_WriteFile runs it before
;   the sizing pass (SmfSize_Pass). Basis: caller + body + callee. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_v.json)
SmfExport_MergeUsedTracksIntoFirst:
	xor	xhl, xhl	; F72918  xor XHL,XHL
	xor	bc, bc	; F7291A  xor BC,BC
SmfExport_MergeUsedTracksIntoFirst_Loop:
	ld	de, (13836:16)	; F7291C  ld DE,(0x360c)
	ld	a, c	; F72920  ld A,C
	cp	a, 16	; F72922  cp A,0x10
	jr	lt, SmfExport_MergeUsedTracksIntoFirst_Skip	; F72925  jr LT,0xf7292e
	ld	de, (13838:16)	; F72927  ld DE,(0x360e)
	sub	a, 16	; F7292B  sub A,0x10
SmfExport_MergeUsedTracksIntoFirst_Skip:
	scf	; F7292E  scf
	xorcf_a_16	de	; F7292F  xorcf A,DE
	jr	c, SmfExport_MergeUsedTracksIntoFirst_Skip2	; F72931  jr C,0xf7294e
	xor	wa, wa	; F72933  xor WA,WA
	ld	a, c	; F72935  ld A,C
	sla	a, 1	; F72937  sla 0x01,A
	add	a, c	; F7293A  add A,C
	ld	iy, wa	; F7293C  ld IY,WA
	push	xde	; F7293E  push XDE
	ld	xde, 6305024	; F7293F  ld XDE,0x00603500
	bit	7, (xde+iy)	; F72944  bit 7,(XDE+IY)
	pop	xde	; F72949  pop XDE
	jr	z, SmfExport_MergeUsedTracksIntoFirst_Skip2	; F7294A  jr Z,0xf7294e
	inc	1, l	; F7294C  inc 1,L
SmfExport_MergeUsedTracksIntoFirst_Skip2:
	inc	1, c	; F7294E  inc 1,C
	cp	c, 16	; F72950  cp C,0x10
	jr	ule, SmfExport_MergeUsedTracksIntoFirst_Loop	; F72953  jr ULE,0xf7291c
	cp	l, 2:i3	; F72955  cp L,2
	jrl	c, SmfExport_MergeUsedTracksIntoFirst_Return	; F72957  jrl C,0xf729d8
	xor	bc, bc	; F7295A  xor BC,BC
SmfExport_MergeUsedTracksIntoFirst_Loop2:
	ld	de, (13836:16)	; F7295C  ld DE,(0x360c)
	ld	a, c	; F72960  ld A,C
	cp	a, 16	; F72962  cp A,0x10
	jr	lt, SmfExport_MergeUsedTracksIntoFirst_Skip3	; F72965  jr LT,0xf7296e
	ld	de, (13838:16)	; F72967  ld DE,(0x360e)
	sub	a, 16	; F7296B  sub A,0x10
SmfExport_MergeUsedTracksIntoFirst_Skip3:
	scf	; F7296E  scf
	xorcf_a_16	de	; F7296F  xorcf A,DE
	jr	nc, SmfExport_MergeUsedTracksIntoFirst_Skip4	; F72971  jr NC,0xf7297a
SmfExport_MergeUsedTracksIntoFirst_Loop3:
	inc	1, c	; F72973  inc 1,C
	cp	c, 16	; F72975  cp C,0x10
	jr	ule, SmfExport_MergeUsedTracksIntoFirst_Loop2	; F72978  jr ULE,0xf7295c
SmfExport_MergeUsedTracksIntoFirst_Skip4:
	ld	l, c	; F7297A  ld L,C
	sla	l, 1	; F7297C  sla 0x01,L
	add	l, c	; F7297F  add L,C
	xor	h, h	; F72981  xor H,H
	push	xix	; F72983  push XIX
	ld	xix, 6305024	; F72984  ld XIX,0x00603500
	bit	7, (xix+hl)	; F72989  bit 7,(XIX+HL)
	pop	xix	; F7298E  pop XIX
	jr	z, SmfExport_MergeUsedTracksIntoFirst_Loop3	; F7298F  jr Z,0xf72973
	xor	xhl, xhl	; F72991  xor XHL,XHL
	ld	l, c	; F72993  ld L,C
	inc	1, c	; F72995  inc 1,C
	ld	(3184:16), l	; F72997  ld (0x0c70),L
	inc	1, (3184:16)	; F7299B  inc 1,(0x0c70)
SmfExport_MergeUsedTracksIntoFirst_Loop4:
	ld	de, (13836:16)	; F7299F  ld DE,(0x360c)
	ld	a, c	; F729A3  ld A,C
	cp	a, 16	; F729A5  cp A,0x10
	jr	lt, SmfExport_MergeUsedTracksIntoFirst_Skip5	; F729A8  jr LT,0xf729b1
	ld	de, (13838:16)	; F729AA  ld DE,(0x360e)
	sub	a, 16	; F729AE  sub A,0x10
SmfExport_MergeUsedTracksIntoFirst_Skip5:
	scf	; F729B1  scf
	xorcf_a_16	de	; F729B2  xorcf A,DE
	jr	c, SmfExport_MergeUsedTracksIntoFirst_Skip6	; F729B4  jr C,0xf729d1
	xor	b, b	; F729B6  xor B,B
	ld	iz, bc	; F729B8  ld IZ,BC
	ld	(3185:16), c	; F729BA  ld (0x0c71),C
	inc	1, (3185:16)	; F729BE  inc 1,(0x0c71)
	ld	a, (3184:16)	; F729C2  ld A,(0x0c70)
	ld	(3186:16), a	; F729C6  ld (0x0c72),A
	push	xhl	; F729CA  push XHL
	pushw	bc	; F729CB  push BC
	calr	Smf_MergeTracks	; F729CC  calr 0xf72a2b
	popw	bc	; F729CF  pop BC
	pop	xhl	; F729D0  pop XHL
SmfExport_MergeUsedTracksIntoFirst_Skip6:
	inc	1, c	; F729D1  inc 1,C
	cp	c, 16	; F729D3  cp C,0x10
	jr	ule, SmfExport_MergeUsedTracksIntoFirst_Loop4	; F729D6  jr ULE,0xf7299f
SmfExport_MergeUsedTracksIntoFirst_Return:
	ret	; F729D8  ret

; --------------------------------------------------------------------------
; Smf_MergeTrack2IntoTrack1
; Called from: in-module: 0xF71BC4 0xF72910
; Touches: (0x0C70) (0x0C71) (0x0C72)
; Calls:   Smf_MergeTracks
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF729D9 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_MergeTrack2IntoTrack1: (0x0C70) := 1, (0x0C71) := 2, (0x0C72) := 1, then Smf_MergeTracks: the two-source / one-
;   destination track merge whose cells TRACK MERGE's OK key loads from its three fields before T_TrackMerge_Execute (TrackMerge_Execute,
;   same range checks). Smf_ReadMultiTrack runs it after each track chunk: tracks after the first are read into slot 1
;   (song track 2) and folded into track 1. Basis: callers + body + the TRACK MERGE twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_j.json)
Smf_MergeTrack2IntoTrack1:
	xor	a, a	; F729D9  xor A,A
	ldw	hl, 1	; F729DB  ld HL,0x0001
	ld	(3184:16), a	; F729DE  ld (0x0c70),A
	inc	1, (3184:16)	; F729E2  inc 1,(0x0c70)
	ld	(3185:16), l	; F729E6  ld (0x0c71),L
	inc	1, (3185:16)	; F729EA  inc 1,(0x0c71)
	ld	a, (3184:16)	; F729EE  ld A,(0x0c70)
	ld	(3186:16), a	; F729F2  ld (0x0c72),A
	pushw	wa	; F729F6  push WA
	push	xhl	; F729F7  push XHL
	calr	Smf_MergeTracks	; F729F8  calr 0xf72a2b
	pop	xhl	; F729FB  pop XHL
	popw	wa	; F729FC  pop WA
	ret	; F729FD  ret
	xor	a, a	; F729FE  xor A,A
	ldw	hl, 1	; F72A00  ld HL,0x0001
	ld	(3184:16), a	; F72A03  ld (0x0c70),A
	inc	1, (3184:16)	; F72A07  inc 1,(0x0c70)
Smf_MergeTrack2IntoTrack1_Loop:
	ld	(3185:16), l	; F72A0B  ld (0x0c71),L
	inc	1, (3185:16)	; F72A0F  inc 1,(0x0c71)
	ld	a, (3184:16)	; F72A13  ld A,(0x0c70)
	ld	(3186:16), a	; F72A17  ld (0x0c72),A
	pushw	wa	; F72A1B  push WA
	pushw	hl	; F72A1C  push HL
	calr	Smf_MergeTracks	; F72A1D  calr 0xf72a2b
	popw	hl	; F72A20  pop HL
	popw	wa	; F72A21  pop WA
	inc	1, hl	; F72A22  inc 1,HL
	cp	hl, 16	; F72A24  cp HL,0x0010
	jr	ule, Smf_MergeTrack2IntoTrack1_Loop	; F72A28  jr ULE,0xf72a0b
	ret	; F72A2A  ret

; --------------------------------------------------------------------------
; Smf_MergeTracks
; Called from: in-module: 0xF729CC 0xF729F8 0xF72A1D
; Touches: (0x0C70) (0x0C71) (0x0C72) (0x0C8A) (0x0C8B) (0x0CA2) (0x0CB6)
;          (0x0CF8) (0x0CFA) (0x0CFE) +7 more  |  0x603500 0x60A000 0x60A100
; Calls:   T_BStore_LoadGeometry_Call T_BStore_OpenChain_Call T_F40A04 SmfMerge_DetachSourceTrack SongStore_SeekBlock_Copy TrackMerge_LoadAndFreeBlock_Copy
;          T_BStore_AllocBlock_Veneer SmfMerge_FetchSource1Event SmfMerge_FetchSource2Event SmfMerge_CopySource1ToMark SmfMerge_EmitCommonMark SmfMerge_CopySource2ToMark
;          +2 more
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72A2B is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_MergeTracks: Merges source tracks (0x0C70) and (0x0C71) into destination (0x0C72): each 1..(0x0CA2) and the
;   sources distinct (else BStore_ErrorCode 3); opens both chains, clears the destination (BStore_ClearTrack via
;   T_F40A04) unless it is a source, gives it a new block and merges the two streams into it. The SMF module's copy of
;   TrackMerge_Execute without its part checks (error 9) and part assignment; called by Smf_MergeTrack2IntoTrack1,
;   SmfExport_MergeUsedTracksIntoFirst and an unreferenced loop at 0xF729FE. Basis: callers + body + twin.
;   (notes/naming-pilot-2026-10-06/proposals_wave6_v.json)
Smf_MergeTracks:
	ld	(3211:16), 0	; F72A2B  ld (0x0c8b),0x00
	call	T_BStore_LoadGeometry_Call	; F72A30  call 0xf427fc
	ld	a, (3184:16)	; F72A34  ld A,(0x0c70)
	cp	a, 1:i3	; F72A38  cp A,1
	jr	c, Smf_MergeTracks_Skip	; F72A3A  jr C,0xf72a64
	cp	a, (0x0ca2:16)	; F72A3C  cp A,(0x0ca2)
	jr	ugt, Smf_MergeTracks_Skip	; F72A40  jr UGT,0xf72a64
	cp	a, (0x0c71:16)	; F72A42  cp A,(0x0c71)
	jr	z, Smf_MergeTracks_Skip	; F72A46  jr Z,0xf72a64
	ld	a, (3185:16)	; F72A48  ld A,(0x0c71)
	cp	a, 1:i3	; F72A4C  cp A,1
	jr	c, Smf_MergeTracks_Skip	; F72A4E  jr C,0xf72a64
	cp	a, (0x0ca2:16)	; F72A50  cp A,(0x0ca2)
	jr	ugt, Smf_MergeTracks_Skip	; F72A54  jr UGT,0xf72a64
	ld	a, (3186:16)	; F72A56  ld A,(0x0c72)
	cp	a, 1:i3	; F72A5A  cp A,1
	jr	c, Smf_MergeTracks_Skip	; F72A5C  jr C,0xf72a64
	cp	a, (0x0ca2:16)	; F72A5E  cp A,(0x0ca2)
	jr	ule, Smf_MergeTracks_Skip2	; F72A62  jr ULE,0xf72a6c
Smf_MergeTracks_Skip:
	ld	(BStore_ErrorCode:16), 3	; F72A64  ld (0x0d4a),0x03
	jrl	Smf_MergeTracks_Return	; F72A69  jrl T,0xf72bb2
Smf_MergeTracks_Skip2:
	xor	hl, hl	; F72A6C  xor HL,HL
	ld	(BStore_ErrorCode:16), 0	; F72A6E  ld (0x0d4a),0x00
	and	(0x0c8a:16), 0xbf	; F72A73  and (0x0c8a),0xbf
	ld	a, (3184:16)	; F72A78  ld A,(0x0c70)
	call	T_BStore_OpenChain_Call	; F72A7C  call 0xf427f8
	cp	(BStore_ErrorCode:16), 0x00	; F72A80  cp (0x0d4a),0x00
	jr	z, Smf_MergeTracks_Skip3	; F72A85  jr Z,0xf72a8a
	jrl	Smf_MergeTracks_Return	; F72A87  jrl T,0xf72bb2
Smf_MergeTracks_Skip3:
	ld	wa, (BStore_CursorBlock:16)	; F72A8A  ld WA,(0x345c)
	ld	(3320:16), wa	; F72A8E  ld (0x0cf8),WA
	ld	a, (3185:16)	; F72A92  ld A,(0x0c71)
	call	T_BStore_OpenChain_Call	; F72A96  call 0xf427f8
	cp	(BStore_ErrorCode:16), 0x00	; F72A9A  cp (0x0d4a),0x00
	jrl	nz, Smf_MergeTracks_Return	; F72A9F  jrl NZ,0xf72bb2
	ld	wa, (BStore_CursorBlock:16)	; F72AA2  ld WA,(0x345c)
	ld	(3326:16), wa	; F72AA6  ld (0x0cfe),WA
	ld	a, (3186:16)	; F72AAA  ld A,(0x0c72)
	cp	a, (0x0c70:16)	; F72AAE  cp A,(0x0c70)
	jr	z, Smf_MergeTracks_Skip4	; F72AB2  jr Z,0xf72ad0
	cp	a, (0x0c71:16)	; F72AB4  cp A,(0x0c71)
	jr	z, Smf_MergeTracks_Skip4	; F72AB8  jr Z,0xf72ad0
	ld	a, (3184:16)	; F72ABA  ld A,(0x0c70)
	pushw	wa	; F72ABE  push WA
	ld	a, (3186:16)	; F72ABF  ld A,(0x0c72)
	ld	(3184:16), a	; F72AC3  ld (0x0c70),A
	call	T_F40A04	; F72AC7  call 0xf40a04
	popw	wa	; F72ACB  pop WA
	ld	(3184:16), a	; F72ACC  ld (0x0c70),A
Smf_MergeTracks_Skip4:
	xor	xhl, xhl	; F72AD0  xor XHL,XHL
	ld	l, (3184:16)	; F72AD2  ld L,(0x0c70)
	calr	SmfMerge_DetachSourceTrack	; F72AD6  calr 0xf72eba
	ld	xix, 6332416	; F72AD9  ld XIX,0x0060a000
	nop	; F72ADE  nop
	ld	wa, (3320:16)	; F72ADF  ld WA,(0x0cf8)
	ld	(BStore_CursorBlock:16), wa	; F72AE3  ld (0x345c),WA
	ld	hl, wa	; F72AE7  ld HL,WA
	calr	SongStore_SeekBlock_Copy	; F72AE9  calr 0xf72f0a
	calr	TrackMerge_LoadAndFreeBlock_Copy	; F72AEC  calr 0xf72e86
	ld	(3322:16), iy	; F72AEF  ld (0x0cfa),IY
	xor	xhl, xhl	; F72AF3  xor XHL,XHL
	ld	l, (3185:16)	; F72AF5  ld L,(0x0c71)
	calr	SmfMerge_DetachSourceTrack	; F72AF9  calr 0xf72eba
	ld	xix, 6332672	; F72AFC  ld XIX,0x0060a100
	nop	; F72B01  nop
	ld	wa, (3326:16)	; F72B02  ld WA,(0x0cfe)
	ld	(BStore_CursorBlock:16), wa	; F72B06  ld (0x345c),WA
	ld	hl, wa	; F72B0A  ld HL,WA
	calr	SongStore_SeekBlock_Copy	; F72B0C  calr 0xf72f0a
	calr	TrackMerge_LoadAndFreeBlock_Copy	; F72B0F  calr 0xf72e86
	ld	(3328:16), iy	; F72B12  ld (0x0d00),IY
	call	T_BStore_AllocBlock_Veneer	; F72B16  call 0xf42884
	xor	hl, hl	; F72B1A  xor HL,HL
	ld	l, (3186:16)	; F72B1C  ld L,(0x0c72)
	dec	1, hl	; F72B20  dec 1,HL
	muls	l, 3	; F72B22  muls L,0x03
	push	xiy	; F72B25  push XIY
	ld	xiy, 6305024	; F72B26  ld XIY,0x00603500
	or	(xiy+hl), 0x80	; F72B2B  or (XIY+HL),0x80
	inc	1, xhl	; F72B31  inc 1,XHL
	ld	(xiy+hl), ix	; F72B33  ld (XIY+HL),IX
	pop	xiy	; F72B38  pop XIY
	ld	(3332:16), ix	; F72B39  ld (0x0d04),IX
	ld	hl, ix	; F72B3D  ld HL,IX
	calr	SongStore_SeekBlock_Copy	; F72B3F  calr 0xf72f0a
	ld	xhl, (BStore_CursorBlockAddr:16)	; F72B42  ld XHL,(0x126e)
	ld	(3254:16), xhl	; F72B46  ld (0x0cb6),XHL
	ldw	ix, 5	; F72B4A  ld IX,0x0005
	ldw	(xhl+1), 0x0000	; F72B4D  ld (XHL+0x01),0x0000
	ldw	(xhl+3), 0xffff	; F72B52  ld (XHL+0x03),0xffff
	calr	SmfMerge_FetchSource1Event	; F72B57  calr 0xf72cbc
	calr	SmfMerge_FetchSource2Event	; F72B5A  calr 0xf72c74
Smf_MergeTracks_Join:
	cp	(0x0c8b:16), 0xff	; F72B5D  cp (0x0c8b),0xff
	jr	nz, Smf_MergeTracks_Skip5	; F72B62  jr NZ,0xf72b66
	jr	Smf_MergeTracks_Return	; F72B64  jr T,0xf72bb2
Smf_MergeTracks_Skip5:
	cp	(0x0c8b:16), 0x03	; F72B66  cp (0x0c8b),0x03
	jr	z, Smf_MergeTracks_Skip6	; F72B6B  jr Z,0xf72b6f
	jr	Smf_MergeTracks_Join2	; F72B6D  jr T,0xf72b86
Smf_MergeTracks_Skip6:
	cp	c, b	; F72B6F  cp C,B
	jr	c, Smf_MergeTracks_Skip7	; F72B71  jr C,0xf72b77
	jr	z, Smf_MergeTracks_Skip8	; F72B73  jr Z,0xf72b7c
	jr	ugt, Smf_MergeTracks_Skip9	; F72B75  jr UGT,0xf72b81
Smf_MergeTracks_Skip7:
	calr	SmfMerge_CopySource1ToMark	; F72B77  calr 0xf72bb3
	jr	Smf_MergeTracks_Join	; F72B7A  jr T,0xf72b5d
Smf_MergeTracks_Skip8:
	calr	SmfMerge_EmitCommonMark	; F72B7C  calr 0xf72bc7
	jr	Smf_MergeTracks_Join	; F72B7F  jr T,0xf72b5d
Smf_MergeTracks_Skip9:
	calr	SmfMerge_CopySource2ToMark	; F72B81  calr 0xf72bbd
	jr	Smf_MergeTracks_Join	; F72B84  jr T,0xf72b5d
Smf_MergeTracks_Join2:
	bit	0, (0x0c8b:16)	; F72B86  bit 0,(0x0c8b)
	jr	z, Smf_MergeTracks_Skip10	; F72B8A  jr Z,0xf72b91
	calr	SmfMerge_CopySource2ToMark	; F72B8C  calr 0xf72bbd
	jr	Smf_MergeTracks_Join	; F72B8F  jr T,0xf72b5d
Smf_MergeTracks_Skip10:
	bit	1, (0x0c8b:16)	; F72B91  bit 1,(0x0c8b)
	jr	z, Smf_MergeTracks_Skip11	; F72B95  jr Z,0xf72b9c
	calr	SmfMerge_CopySource1ToMark	; F72B97  calr 0xf72bb3
	jr	Smf_MergeTracks_Join	; F72B9A  jr T,0xf72b5d
Smf_MergeTracks_Skip11:
	ld	a, (3358:16)	; F72B9C  ld A,(0x0d1e)
	ld	w, (3359:16)	; F72BA0  ld W,(0x0d1f)
	cp	a, w	; F72BA4  cp A,W
	jr	le, Smf_MergeTracks_Skip12	; F72BA6  jr LE,0xf72bad
	calr	SmfMerge_CopySource2Event	; F72BA8  calr 0xf72d04
	jr	Smf_MergeTracks_Join	; F72BAB  jr T,0xf72b5d
Smf_MergeTracks_Skip12:
	calr	SmfMerge_CopySource1Event	; F72BAD  calr 0xf72d66
	jr	Smf_MergeTracks_Join	; F72BB0  jr T,0xf72b5d
Smf_MergeTracks_Return:
	ret	; F72BB2  ret

; --------------------------------------------------------------------------
; SmfMerge_CopySource1ToMark
; Called from: in-module: 0xF72B77 0xF72B97
; Touches: (0x0C8B)
; Calls:   SmfMerge_CopySource1Event
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72BB3 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfMerge_CopySource1ToMark: Repeats SmfMerge_CopySource1Event until (0x0C8B) bit 0 is set: copies source 1's events
;   into the merged track up to its next 0x81 beat mark or 0x82 end. Smf_MergeTracks runs it when source 2 waits at a
;   mark or both stand on marks with source 1's lower; twin of TrackMerge_CopySource1ToMark. Basis: caller + body +
;   twin. (notes/naming-pilot-2026-10-06/proposals_wave7_y.json)
SmfMerge_CopySource1ToMark:
	calr	SmfMerge_CopySource1Event	; F72BB3  calr 0xf72d66
	bit	0, (0x0c8b:16)	; F72BB6  bit 0,(0x0c8b)
	jr	z, SmfMerge_CopySource1ToMark	; F72BBA  jr Z,0xf72bb3
	ret	; F72BBC  ret

; --------------------------------------------------------------------------
; SmfMerge_CopySource2ToMark
; Called from: in-module: 0xF72B81 0xF72B8C
; Touches: (0x0C8B)
; Calls:   SmfMerge_CopySource2Event
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72BBD is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfMerge_CopySource2ToMark: Repeats SmfMerge_CopySource2Event until (0x0C8B) bit 1 is set: copies source 2's events
;   into the merged track up to its next 0x81 beat mark or 0x82 end. Smf_MergeTracks runs it when source 1 waits at a
;   mark or both stand on marks with source 2's lower; twin of TrackMerge_CopySource2ToMark. Basis: caller + body +
;   twin. (notes/naming-pilot-2026-10-06/proposals_wave7_y.json)
SmfMerge_CopySource2ToMark:
	calr	SmfMerge_CopySource2Event	; F72BBD  calr 0xf72d04
	bit	1, (0x0c8b:16)	; F72BC0  bit 1,(0x0c8b)
	jr	z, SmfMerge_CopySource2ToMark	; F72BC4  jr Z,0xf72bbd
	ret	; F72BC6  ret

; --------------------------------------------------------------------------
; SmfMerge_EmitCommonMark
; Called from: in-module: 0xF72B7C
; Touches: (0x0C57) (0x0C72) (0x0C8B) (0x0CFA) (0x0D00) (0x0D04) (0x0D1A)
;          (0x126E)  |  0x60A000 0x60A100
; Calls:   SmfMerge_SaveDestEndCursor SmfMerge_AdvanceWriteCursor SmfMerge_AdvanceReadCursor SmfMerge_FetchSource1Event SmfMerge_FetchSource2Event
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72BC7 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfMerge_EmitCommonMark: Both sources stand on the same mark (C == B): for 0x82 writes the end mark, (0x0C8B) :=
;   0xFF and saves the destination (0x0C72)'s end cursor (block (0x0D04), offset IX); for 0x81 writes one beat mark,
;   advances the write cursor and both read cursors and fetches both next events. Smf_MergeTracks' copy of
;   TrackMerge_EmitCommonMark (the end cursor is stored inline by SmfMerge_SaveDestEndCursor instead of T_BStore_SaveCursor). Basis:
;   caller + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave7_y.json)
SmfMerge_EmitCommonMark:
	cp	c, 130	; F72BC7  cp C,0x82
	jr	nz, SmfMerge_EmitCommonMark_Skip	; F72BCA  jr NZ,0xf72bf2
	ld	xhl, (BStore_CursorBlockAddr:16)	; F72BCC  ld XHL,(0x126e)
	ld	(xhl+ix), 0x82	; F72BD0  ld (XHL+IX),0x82
	ld	(3211:16), 255	; F72BD6  ld (0x0c8b),0xff
	ld	wa, (3332:16)	; F72BDB  ld WA,(0x0d04)
	ld	(3159:16), wa	; F72BDF  ld (0x0c57),WA
	xor	wa, wa	; F72BE3  xor WA,WA
	ld	a, (3186:16)	; F72BE5  ld A,(0x0c72)
	ld	(3354:16), wa	; F72BE9  ld (0x0d1a),WA
	calr	SmfMerge_SaveDestEndCursor	; F72BED  calr 0xf72c36
	jr	SmfMerge_EmitCommonMark_Return	; F72BF0  jr T,0xf72c35
SmfMerge_EmitCommonMark_Skip:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F72BF2  ld XHL,(0x126e)
	ld	(xhl+ix), 0x81	; F72BF6  ld (XHL+IX),0x81
	calr	SmfMerge_AdvanceWriteCursor	; F72BFC  calr 0xf72dc8
	ld	xhl, (BStore_CursorBlockAddr:16)	; F72BFF  ld XHL,(0x126e)
	push	xix	; F72C03  push XIX
	ld	xix, 6332416	; F72C04  ld XIX,0x0060a000
	nop	; F72C09  nop
	ld	iy, (3322:16)	; F72C0A  ld IY,(0x0cfa)
	calr	SmfMerge_AdvanceReadCursor	; F72C0E  calr 0xf72e27
	ld	(3322:16), iy	; F72C11  ld (0x0cfa),IY
	calr	SmfMerge_FetchSource1Event	; F72C15  calr 0xf72cbc
	ld	(3322:16), iy	; F72C18  ld (0x0cfa),IY
	ld	xix, 6332672	; F72C1C  ld XIX,0x0060a100
	nop	; F72C21  nop
	ld	iy, (3328:16)	; F72C22  ld IY,(0x0d00)
	calr	SmfMerge_AdvanceReadCursor	; F72C26  calr 0xf72e27
	ld	(3328:16), iy	; F72C29  ld (0x0d00),IY
	calr	SmfMerge_FetchSource2Event	; F72C2D  calr 0xf72c74
	ld	(3328:16), iy	; F72C30  ld (0x0d00),IY
	pop	xix	; F72C34  pop XIX
SmfMerge_EmitCommonMark_Return:
	ret	; F72C35  ret

; --------------------------------------------------------------------------
; SmfMerge_SaveDestEndCursor
; Called from: in-module: 0xF72BED
; Touches: (0x0C57) (0x0D1A) (0x126E)  |  0x60347E 0x6034A0
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72C36 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfMerge_SaveDestEndCursor: Entry (0x0D1A)'s end cursor := offset IX / block (0x0C57): 0x6034A0[n-1] := IX,
;   0x60347E[n-1] := (0x0C57) -- BStore_SaveCursor's first half without the bank copy at 0x610000; (0x126E) kept.
;   SmfMerge_EmitCommonMark runs it on the merged destination track (0x0C72) after writing the 0x82 end tag, where
;   TrackMerge_EmitCommonMark calls T_BStore_SaveCursor. Basis: caller + caller header + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_a8.json)
SmfMerge_SaveDestEndCursor:
	push	xiy	; F72C36  push XIY
	push	xiz	; F72C37  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F72C38  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F72C3C  ld XDE3,XIZ
	pop	xiz	; F72C3F  pop XIZ
	push_lerp	0x38	; F72C40  push XDE3
	ld	hl, (3354:16)	; F72C43  ld HL,(0x0d1a)
	dec	1, hl	; F72C47  dec 1,HL
	ld	wa, ix	; F72C49  ld WA,IX
	ld	xiy, 6304928	; F72C4B  ld XIY,0x006034a0
	ld	(xiy+hl), a	; F72C50  ld (XIY+HL),A
	sla	hl, 1	; F72C55  sla 0x01,HL
	ld	wa, (3159:16)	; F72C58  ld WA,(0x0c57)
	ld	xiy, 6304894	; F72C5C  ld XIY,0x0060347e
	ld	(xiy+hl), wa	; F72C61  ld (XIY+HL),WA
	pop_lerp	0x38	; F72C66  pop XDE3
	push	xiz	; F72C69  push XIZ
	ldto_lerp	xiz, 0x38	; F72C6A  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F72C6D  ld (0x126e),XIZ
	pop	xiz	; F72C71  pop XIZ
	pop	xiy	; F72C72  pop XIY
	ret	; F72C73  ret

; --------------------------------------------------------------------------
; SmfMerge_FetchSource2Event
; Called from: in-module: 0xF72B5A 0xF72C2D 0xF72D62
; Touches: (0x0C8B) (0x0D00) (0x0D1F)  |  0x60A100
; Calls:   SmfMerge_AdvanceReadCursor
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72C74 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfMerge_FetchSource2Event: Reads source 2's next item from its staging buffer 0x60A100 at (0x0D00): B = status; a
;   0x81 beat mark or 0x82 end sets (0x0C8B) bit 1 and stays put, otherwise the cursor steps past the status and
;   (0x0D1F) := the event's timing byte. Primed by Smf_MergeTracks and called after each source-2 copy; twin of
;   TrackMerge_FetchSource2Event. Basis: caller + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave7_y.json)
SmfMerge_FetchSource2Event:
	and	(0x0c8b:16), 0xfd	; F72C74  and (0x0c8b),0xfd
	ld	iy, (3328:16)	; F72C79  ld IY,(0x0d00)
	push	xix	; F72C7D  push XIX
	ld	xix, 6332672	; F72C7E  ld XIX,0x0060a100
	ld	b, (xix+iy)	; F72C83  ld B,(XIX+IY)
	pop	xix	; F72C88  pop XIX
	cp	b, 130	; F72C89  cp B,0x82
	jr	z, SmfMerge_FetchSource2Event_Skip	; F72C8C  jr Z,0xf72c93
	cp	b, 129	; F72C8E  cp B,0x81
	jr	nz, SmfMerge_FetchSource2Event_Skip2	; F72C91  jr NZ,0xf72c9a
SmfMerge_FetchSource2Event_Skip:
	or	(0x0c8b:16), 0x02	; F72C93  or (0x0c8b),0x02
	jr	SmfMerge_FetchSource2Event_Return	; F72C98  jr T,0xf72cbb
SmfMerge_FetchSource2Event_Skip2:
	pushw	bc	; F72C9A  push BC
	push	xix	; F72C9B  push XIX
	ld	xix, 6332672	; F72C9C  ld XIX,0x0060a100
	nop	; F72CA1  nop
	calr	SmfMerge_AdvanceReadCursor	; F72CA2  calr 0xf72e27
	pop	xix	; F72CA5  pop XIX
	popw	bc	; F72CA6  pop BC
	push	xix	; F72CA7  push XIX
	ld	xix, 6332672	; F72CA8  ld XIX,0x0060a100
	ld	a, (xix+iy)	; F72CAD  ld A,(XIX+IY)
	pop	xix	; F72CB2  pop XIX
	ld	(3359:16), a	; F72CB3  ld (0x0d1f),A
	ld	(3328:16), iy	; F72CB7  ld (0x0d00),IY
SmfMerge_FetchSource2Event_Return:
	ret	; F72CBB  ret

; --------------------------------------------------------------------------
; SmfMerge_FetchSource1Event
; Called from: in-module: 0xF72B57 0xF72C15 0xF72DC4
; Touches: (0x0C8B) (0x0CFA) (0x0D1E)  |  0x60A000
; Calls:   SmfMerge_AdvanceReadCursor
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72CBC is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfMerge_FetchSource1Event: Reads source 1's next item from its staging buffer 0x60A000 at (0x0CFA): C = status; a
;   0x81 beat mark or 0x82 end sets (0x0C8B) bit 0 and stays put, otherwise the cursor steps past the status and
;   (0x0D1E) := the event's timing byte. Primed by Smf_MergeTracks and called after each source-1 copy; twin of
;   TrackMerge_FetchSource1Event. Basis: caller + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave7_y.json)
SmfMerge_FetchSource1Event:
	and	(0x0c8b:16), 0xfe	; F72CBC  and (0x0c8b),0xfe
	ld	iy, (3322:16)	; F72CC1  ld IY,(0x0cfa)
	push	xix	; F72CC5  push XIX
	ld	xix, 6332416	; F72CC6  ld XIX,0x0060a000
	ld	c, (xix+iy)	; F72CCB  ld C,(XIX+IY)
	pop	xix	; F72CD0  pop XIX
	cp	c, 130	; F72CD1  cp C,0x82
	jr	z, SmfMerge_FetchSource1Event_Skip	; F72CD4  jr Z,0xf72cdb
	cp	c, 129	; F72CD6  cp C,0x81
	jr	nz, SmfMerge_FetchSource1Event_Skip2	; F72CD9  jr NZ,0xf72ce2
SmfMerge_FetchSource1Event_Skip:
	or	(0x0c8b:16), 0x01	; F72CDB  or (0x0c8b),0x01
	jr	SmfMerge_FetchSource1Event_Return	; F72CE0  jr T,0xf72d03
SmfMerge_FetchSource1Event_Skip2:
	pushw	bc	; F72CE2  push BC
	push	xix	; F72CE3  push XIX
	ld	xix, 6332416	; F72CE4  ld XIX,0x0060a000
	nop	; F72CE9  nop
	calr	SmfMerge_AdvanceReadCursor	; F72CEA  calr 0xf72e27
	pop	xix	; F72CED  pop XIX
	popw	bc	; F72CEE  pop BC
	push	xix	; F72CEF  push XIX
	ld	xix, 6332416	; F72CF0  ld XIX,0x0060a000
	ld	a, (xix+iy)	; F72CF5  ld A,(XIX+IY)
	pop	xix	; F72CFA  pop XIX
	ld	(3358:16), a	; F72CFB  ld (0x0d1e),A
	ld	(3322:16), iy	; F72CFF  ld (0x0cfa),IY
SmfMerge_FetchSource1Event_Return:
	ret	; F72D03  ret

; --------------------------------------------------------------------------
; SmfMerge_CopySource2Event
; Called from: in-module: 0xF72BA8 0xF72BBD
; Touches: (0x0C8B) (0x0D00) (0x0D1F) (0x126E)  |  0x60A100
; Calls:   SmfMerge_AdvanceWriteCursor SmfMerge_AdvanceReadCursor SmfMerge_FetchSource2Event
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72D04 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfMerge_CopySource2Event: Copies source 2's current item into the merged stream at the write cursor IX: the status
;   B, then (for an event) its timing (0x0D1F), then its data bytes up to the next status byte, advancing both
;   cursors; then SmfMerge_FetchSource2Event. Smf_MergeTracks runs it when source 2's event is earlier ((0x0D1E) >
;   (0x0D1F)); twin of TrackMerge_CopySource2Event. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_y.json)
SmfMerge_CopySource2Event:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F72D04  ld XHL,(0x126e)
	ld	(xhl+ix), b	; F72D08  ld (XHL+IX),B
	bit	1, (0x0c8b:16)	; F72D0D  bit 1,(0x0c8b)
	jr	nz, SmfMerge_CopySource2Event_Join	; F72D11  jr NZ,0xf72d23
	calr	SmfMerge_AdvanceWriteCursor	; F72D13  calr 0xf72dc8
	ld	xhl, (BStore_CursorBlockAddr:16)	; F72D16  ld XHL,(0x126e)
	ld	a, (3359:16)	; F72D1A  ld A,(0x0d1f)
	ld	(xhl+ix), a	; F72D1E  ld (XHL+IX),A
SmfMerge_CopySource2Event_Join:
	push	xix	; F72D23  push XIX
	ld	xix, 6332672	; F72D24  ld XIX,0x0060a100
	nop	; F72D29  nop
	ld	iy, (3328:16)	; F72D2A  ld IY,(0x0d00)
	calr	SmfMerge_AdvanceReadCursor	; F72D2E  calr 0xf72e27
	ld	(3328:16), iy	; F72D31  ld (0x0d00),IY
	pop	xix	; F72D35  pop XIX
	calr	SmfMerge_AdvanceWriteCursor	; F72D36  calr 0xf72dc8
	ld	xhl, (BStore_CursorBlockAddr:16)	; F72D39  ld XHL,(0x126e)
	push	xix	; F72D3D  push XIX
	ld	xix, 6332672	; F72D3E  ld XIX,0x0060a100
	bit	7, (xix+iy)	; F72D43  bit 7,(XIX+IY)
	pop	xix	; F72D48  pop XIX
	jr	nz, SmfMerge_CopySource2Event_Skip	; F72D49  jr NZ,0xf72d5e
	push	xix	; F72D4B  push XIX
	ld	xix, 6332672	; F72D4C  ld XIX,0x0060a100
	ld	a, (xix+iy)	; F72D51  ld A,(XIX+IY)
	pop	xix	; F72D56  pop XIX
	ld	(xhl+ix), a	; F72D57  ld (XHL+IX),A
	jr	SmfMerge_CopySource2Event_Join	; F72D5C  jr T,0xf72d23
SmfMerge_CopySource2Event_Skip:
	ld	(3328:16), iy	; F72D5E  ld (0x0d00),IY
	calr	SmfMerge_FetchSource2Event	; F72D62  calr 0xf72c74
	ret	; F72D65  ret

; --------------------------------------------------------------------------
; SmfMerge_CopySource1Event
; Called from: in-module: 0xF72BAD 0xF72BB3
; Touches: (0x0C8B) (0x0CFA) (0x0D1E) (0x126E)  |  0x60A000
; Calls:   SmfMerge_AdvanceWriteCursor SmfMerge_AdvanceReadCursor SmfMerge_FetchSource1Event
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72D66 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfMerge_CopySource1Event: Copies source 1's current item into the merged stream at the write cursor IX: the status
;   C, then (for an event) its timing (0x0D1E), then its data bytes up to the next status byte, advancing both
;   cursors; then SmfMerge_FetchSource1Event. Smf_MergeTracks runs it when source 1's event is not later than source
;   2's; twin of TrackMerge_CopySource1Event. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_y.json)
SmfMerge_CopySource1Event:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F72D66  ld XHL,(0x126e)
	ld	(xhl+ix), c	; F72D6A  ld (XHL+IX),C
	bit	0, (0x0c8b:16)	; F72D6F  bit 0,(0x0c8b)
	jr	nz, SmfMerge_CopySource1Event_Join	; F72D73  jr NZ,0xf72d85
	calr	SmfMerge_AdvanceWriteCursor	; F72D75  calr 0xf72dc8
	ld	xhl, (BStore_CursorBlockAddr:16)	; F72D78  ld XHL,(0x126e)
	ld	a, (3358:16)	; F72D7C  ld A,(0x0d1e)
	ld	(xhl+ix), a	; F72D80  ld (XHL+IX),A
SmfMerge_CopySource1Event_Join:
	push	xix	; F72D85  push XIX
	ld	xix, 6332416	; F72D86  ld XIX,0x0060a000
	nop	; F72D8B  nop
	ld	iy, (3322:16)	; F72D8C  ld IY,(0x0cfa)
	calr	SmfMerge_AdvanceReadCursor	; F72D90  calr 0xf72e27
	ld	(3322:16), iy	; F72D93  ld (0x0cfa),IY
	pop	xix	; F72D97  pop XIX
	calr	SmfMerge_AdvanceWriteCursor	; F72D98  calr 0xf72dc8
	ld	xhl, (BStore_CursorBlockAddr:16)	; F72D9B  ld XHL,(0x126e)
	push	xde	; F72D9F  push XDE
	ld	xde, 6332416	; F72DA0  ld XDE,0x0060a000
	bit	7, (xde+iy)	; F72DA5  bit 7,(XDE+IY)
	pop	xde	; F72DAA  pop XDE
	jr	nz, SmfMerge_CopySource1Event_Skip	; F72DAB  jr NZ,0xf72dc0
	push	xde	; F72DAD  push XDE
	ld	xde, 6332416	; F72DAE  ld XDE,0x0060a000
	ld	a, (xde+iy)	; F72DB3  ld A,(XDE+IY)
	pop	xde	; F72DB8  pop XDE
	ld	(xhl+ix), a	; F72DB9  ld (XHL+IX),A
	jr	SmfMerge_CopySource1Event_Join	; F72DBE  jr T,0xf72d85
SmfMerge_CopySource1Event_Skip:
	ld	(3322:16), iy	; F72DC0  ld (0x0cfa),IY
	calr	SmfMerge_FetchSource1Event	; F72DC4  calr 0xf72cbc
	ret	; F72DC7  ret

; --------------------------------------------------------------------------
; SmfMerge_AdvanceWriteCursor
; Called from: in-module: 0xF72BFC 0xF72D13 0xF72D36 0xF72D75 0xF72D98
; Touches: (0x0D04) (0x0D4A) (0x126E) (0x3608)
; Calls:   T_BStore_AllocBlock_Veneer SongStore_SeekBlock_Copy
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72DC8 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfMerge_AdvanceWriteCursor: Steps the SMF-merge write cursor IX one byte; past offset 0xFF allocates a block
;   (T_BStore_AllocBlock_Veneer; above BStore_BlockCount -> error 5), links it after the current write block (+3),
;   gives it +1 = (0x0D04) and +3 = 0xFFFF, makes it (0x0D04) and IX = 5. Smf_MergeTracks' copy of
;   TrackMerge_AdvanceWriteCursor. Basis: callers + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_a8.json)
SmfMerge_AdvanceWriteCursor:
	and	ix, 255	; F72DC8  and IX,0x00ff
	inc	1, ix	; F72DCC  inc 1,IX
	cp	ix, 255	; F72DCE  cp IX,0x00ff
	jr	ugt, SmfMerge_AdvanceWriteCursor_Skip	; F72DD2  jr UGT,0xf72dd6
	jr	SmfMerge_AdvanceWriteCursor_Return	; F72DD4  jr T,0xf72e26
SmfMerge_AdvanceWriteCursor_Skip:
	push	xiz	; F72DD6  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F72DD7  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F72DDB  ld XDE3,XIZ
	pop	xiz	; F72DDE  pop XIZ
	push_lerp	0x38	; F72DDF  push XDE3
	push	xiy	; F72DE2  push XIY
	pushw	bc	; F72DE3  push BC
	call	T_BStore_AllocBlock_Veneer	; F72DE4  call 0xf42884
	popw	bc	; F72DE8  pop BC
	pop	xiy	; F72DE9  pop XIY
	pop_lerp	0x38	; F72DEA  pop XDE3
	push	xiz	; F72DED  push XIZ
	ldto_lerp	xiz, 0x38	; F72DEE  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F72DF1  ld (0x126e),XIZ
	pop	xiz	; F72DF5  pop XIZ
	cp	ix, (BStore_BlockCount:16)	; F72DF6  cp IX,(0x3608)
	jr	ule, SmfMerge_AdvanceWriteCursor_Skip2	; F72DFA  jr ULE,0xf72e03
	ld	(BStore_ErrorCode:16), 5	; F72DFC  ld (0x0d4a),0x05
	jr	SmfMerge_AdvanceWriteCursor_Return	; F72E01  jr T,0xf72e26
SmfMerge_AdvanceWriteCursor_Skip2:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F72E03  ld XHL,(0x126e)
	ld	(xhl+3), ix	; F72E07  ld (XHL+0x03),IX
	ld	hl, ix	; F72E0A  ld HL,IX
	calr	SongStore_SeekBlock_Copy	; F72E0C  calr 0xf72f0a
	ld	wa, (3332:16)	; F72E0F  ld WA,(0x0d04)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F72E13  ld XHL,(0x126e)
	ld	(xhl+1), wa	; F72E17  ld (XHL+0x01),WA
	ldw	(xhl+3), 0xffff	; F72E1A  ld (XHL+0x03),0xffff
	ld	(3332:16), ix	; F72E1F  ld (0x0d04),IX
	ldw	ix, 5	; F72E23  ld IX,0x0005
SmfMerge_AdvanceWriteCursor_Return:
	ret	; F72E26  ret

; --------------------------------------------------------------------------
; SmfMerge_AdvanceReadCursor
; Called from: in-module: 0xF72C0E 0xF72C26 0xF72CA2 0xF72CEA 0xF72D2E
;              0xF72D90
; Touches: (0x0D4A) (0x126E) (0x345C) (0x3608)
; Calls:   SongStore_SeekBlock_Copy TrackMerge_LoadAndFreeBlock_Copy
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72E27 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfMerge_AdvanceReadCursor: Steps a SMF-merge source read cursor IY one byte in its staging buffer XIX (0x60A000 /
;   0x60A100); past offset 0xFF follows the staged block's +3 link (0xFFFF -> error 2, above BStore_BlockCount -> 10,
;   block not in use -> 11) and reloads the buffer (TrackMerge_LoadAndFreeBlock_Copy, IY = 5); (0x126E) kept.
;   Smf_MergeTracks' copy of TrackMerge_AdvanceReadCursor (adds `and IY,0xFF`, bounds on 0x3608 not 0x0CA4). Basis:
;   callers + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave8_a8.json)
SmfMerge_AdvanceReadCursor:
	push	xiz	; F72E27  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F72E28  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F72E2C  ld XDE3,XIZ
	pop	xiz	; F72E2F  pop XIZ
	push_lerp	0x38	; F72E30  push XDE3
	and	iy, 255	; F72E33  and IY,0x00ff
	inc	1, iy	; F72E37  inc 1,IY
	cp	iy, 255	; F72E39  cp IY,0x00ff
	jr	ugt, SmfMerge_AdvanceReadCursor_Skip	; F72E3D  jr UGT,0xf72e41
	jr	sub_F72E27_Entry	; F72E3F  jr T,0xf72e79
SmfMerge_AdvanceReadCursor_Skip:
	ld	wa, (xix+3)	; F72E41  ld WA,(XIX+0x03)
	cp	wa, 65535	; F72E44  cp WA,0xffff
	jr	nz, SmfMerge_AdvanceReadCursor_Skip2	; F72E48  jr NZ,0xf72e51
	ld	(BStore_ErrorCode:16), 2	; F72E4A  ld (0x0d4a),0x02
	jr	sub_F72E27_Entry	; F72E4F  jr T,0xf72e79
SmfMerge_AdvanceReadCursor_Skip2:
	cp	wa, (BStore_BlockCount:16)	; F72E51  cp WA,(0x3608)
	jr	ule, SmfMerge_AdvanceReadCursor_Skip3	; F72E55  jr ULE,0xf72e5e
	ld	(BStore_ErrorCode:16), 10	; F72E57  ld (0x0d4a),0x0a
	jr	sub_F72E27_Entry	; F72E5C  jr T,0xf72e79
SmfMerge_AdvanceReadCursor_Skip3:
	ld	(BStore_CursorBlock:16), wa	; F72E5E  ld (0x345c),WA
	ld	hl, wa	; F72E62  ld HL,WA
	calr	SongStore_SeekBlock_Copy	; F72E64  calr 0xf72f0a
	ld	xhl, (BStore_CursorBlockAddr:16)	; F72E67  ld XHL,(0x126e)
	bit	7, (xhl)	; F72E6B  bit 7,(XHL)
	jr	nz, SmfMerge_AdvanceReadCursor_Skip4	; F72E6D  jr NZ,0xf72e76
	ld	(BStore_ErrorCode:16), 11	; F72E6F  ld (0x0d4a),0x0b
	jr	sub_F72E27_Entry	; F72E74  jr T,0xf72e79
SmfMerge_AdvanceReadCursor_Skip4:
	calr	TrackMerge_LoadAndFreeBlock_Copy	; F72E76  calr 0xf72e86
sub_F72E27_Entry:
	pop_lerp	0x38	; F72E79  pop XDE3
	push	xiz	; F72E7C  push XIZ
	ldto_lerp	xiz, 0x38	; F72E7D  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F72E80  ld (0x126e),XIZ
	pop	xiz	; F72E84  pop XIZ
	ret	; F72E85  ret

; --------------------------------------------------------------------------
; TrackMerge_LoadAndFreeBlock_Copy
; Called from: in-module: 0xF72AEC 0xF72B0F 0xF72E76
; Touches: (0x126E) (0x345C)
; Calls:   T_BStore_FreeChain_Veneer
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72E86 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_LoadAndFreeBlock_Copy: an exact copy of TrackMerge_LoadAndFreeBlock (prom_b 0xF60514) -- all 22 instructions equal, operands included,
;   but the targets of its jr / jrl / djnz (notes/wsa1_exact_copy_names.py).
TrackMerge_LoadAndFreeBlock_Copy:
	pushw	bc	; F72E86  push BC
	push	xhl	; F72E87  push XHL
	push	xiz	; F72E88  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F72E89  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F72E8D  ld XDE3,XIZ
	pop	xiz	; F72E90  pop XIZ
	push_lerp	0x38	; F72E91  push XDE3
	ld	xiy, (BStore_CursorBlockAddr:16)	; F72E94  ld XIY,(0x126e)
	ldw	bc, 256	; F72E98  ld BC,0x0100
	ldir85	; F72E9B  ldir
	ld	iy, (BStore_CursorBlock:16)	; F72E9D  ld IY,(0x345c)
	ldw	wa, 1	; F72EA1  ld WA,0x0001
	call	T_BStore_FreeChain_Veneer	; F72EA4  call 0xf42888
	pop_lerp	0x38	; F72EA8  pop XDE3
	push	xiz	; F72EAB  push XIZ
	ldto_lerp	xiz, 0x38	; F72EAC  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F72EAF  ld (0x126e),XIZ
	pop	xiz	; F72EB3  pop XIZ
	pop	xhl	; F72EB4  pop XHL
	popw	bc	; F72EB5  pop BC
	ldw	iy, 5	; F72EB6  ld IY,0x0005
	ret	; F72EB9  ret

; --------------------------------------------------------------------------
; SmfMerge_DetachSourceTrack
; Called from: in-module: 0xF72AD6 0xF72AF9
; Touches:   |  0x60347E 0x6034A0 0x603500
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72EBA is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfMerge_DetachSourceTrack: For track HL (1-based): clears its directory entry's in-use bit, sets its head to 0xFFFF
;   and resets its song position and end cursor (0x3460/0x60347E := 0xFFFF, 0x3482/0x6034A0 := 5) without freeing its
;   blocks. Smf_MergeTracks runs it on both sources before consuming their chains block by block; twin of
;   TrackMerge_DetachSourceTrack (muls spelled on IYL). Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_y.json)
SmfMerge_DetachSourceTrack:
	dec	1, hl	; F72EBA  dec 1,HL
	ld	iy, hl	; F72EBC  ld IY,HL
	.byte 0xC7, 0xF4, 0x09, 0x03	; F72EBE  muls IYL,0x03   [llvm-mc cannot encode this]
	push	xix	; F72EC2  push XIX
	ld	xix, 6305024	; F72EC3  ld XIX,0x00603500
	and	(xix+iy), 0x7f	; F72EC8  and (XIX+IY),0x7f
	inc	1, iy	; F72ECE  inc 1,IY
	ldw	(xix+iy), 0xffff	; F72ED0  ld (XIX+IY),0xffff
	ld	xix, 13442	; F72ED7  ld XIX,0x00003482
	ld	(xix+hl), 0x05	; F72EDC  ld (XIX+HL),0x05
	ld	xix, 6304928	; F72EE2  ld XIX,0x006034a0
	ld	(xix+hl), 0x05	; F72EE7  ld (XIX+HL),0x05
	sla	hl, 1	; F72EED  sla 0x01,HL
	ld	xix, 13408	; F72EF0  ld XIX,0x00003460
	ldw	(xix+hl), 0xffff	; F72EF5  ld (XIX+HL),0xffff
	ld	xix, 6304894	; F72EFC  ld XIX,0x0060347e
	ldw	(xix+hl), 0xffff	; F72F01  ld (XIX+HL),0xffff
	pop	xix	; F72F08  pop XIX
	ret	; F72F09  ret

; --------------------------------------------------------------------------
; SongStore_SeekBlock_Copy
; Called from: in-module: 0xF6FA0A 0xF70FE6 0xF71057 0xF710C8 0xF710D8
;              0xF713EC 0xF713F8 0xF721D4 +18 more
; Touches: (0x126E) (0x3604)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72F0A is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongStore_SeekBlock_Copy: an exact copy of SongStore_SeekBlock (prom_a 0xF81AB5) -- all 10 instructions equal, operands included,
;   but the targets of its jr / jrl / djnz (notes/wsa1_exact_copy_names.py).
SongStore_SeekBlock_Copy:
	push	xiy	; F72F0A  push XIY
	ld	xiy, (BStore_HeapBase:16)	; F72F0B  ld XIY,(0x3604)
	extz	xhl	; F72F0F  extz XHL
	dec	1, xhl	; F72F11  dec 1,XHL
	sla	xhl, 8	; F72F13  sla 0x08,XHL
	add	xiy, xhl	; F72F16  add XIY,XHL
	ld	(BStore_CursorBlockAddr:16), xiy	; F72F18  ld (0x126e),XIY
	xor	xhl, xhl	; F72F1C  xor XHL,XHL
	pop	xiy	; F72F1E  pop XIY
	ret	; F72F1F  ret

; --------------------------------------------------------------------------
; Smf_BusyDelay
; Called from: in-module: 0xF6F7F3 0xF7290C 0xF74781
; Touches: nothing with an absolute address
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72F20 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_BusyDelay: 3072 x 960 empty djnz16 iterations.  Called by Smf_ReadFile and Smf_WriteFile.
Smf_BusyDelay:
	ldw	bc, 3072	; F72F20  ld BC,0x0c00
	ldw	hl, 960	; F72F23  ld HL,0x03c0
	djnz16	hl, -3	; F72F26  djnz HL,0xf72f26
	djnz16	bc, -9	; F72F29  djnz BC,0xf72f23
	ret	; F72F2C  ret

; --------------------------------------------------------------------------
; Smf_ResultToStatusCode
; Called from: in-module: 0xF6F7CE 0xF72914 0xF747E7
; Touches: nothing with an absolute address
; Calls:   Smf_SplitTrack1ByChannel
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72F2D is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_ResultToStatusCode: L := ByteMap_F72F3C[L]: maps an SMF read/write result code to the UI_StatusCode byte -- the
;   SMF counterpart of BStore_ErrorToStatusByte. Smf_ReadFile maps InputStream_Status, Smf_WriteFile maps (0x1238),
;   and both store L in UI_StatusCode. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave2_c.json)
Smf_ResultToStatusCode:
	xor	h, h	; F72F2D  xor H,H
	push	xix	; F72F2F  push XIX
	ld	xix, ByteMap_F72F3C	; F72F30  ld XIX,0x00f72f3c
	ld	l, (xix+hl)	; F72F35  ld L,(XIX+HL)
	pop	xix	; F72F3A  pop XIX
	ret	; F72F3B  ret
; --------------------------------------------------------------------------
; ByteMap_F72F3C -- 0xF72F3C-0xF72F5B, 32 bytes, applied to L by Smf_ResultToStatusCode.
;   Converted 2026-09-25 (lane promb): the source framed them as `swi 7`,
;   `ld C,0x23`, `normal`, `halt`, `reti`, `max`, `ld (0xff),0xff` ... and a
;   `calr 0xF72F5C` / `ret` pair made of the last four bytes.
; Read by: Smf_ResultToStatusCode (called from 0xF6F7CE, 0xF72914, 0xF747E7): H = 0,
;   `ld XIX,0x00F72F3C / ld L,(XIX+HL)`, `ret`.
; Entry count: 32 at most -- Smf_SplitTrack1ByChannel, called from 0xF71BDF, begins at the
;   next byte.  ⚠ Its header lists a caller at 0xF72F58: that `calr` was four
;   of THESE bytes (1E 01 00 0E) framed as code, and no longer exists.
; Unknown: what the byte in L is and what the mapped values (0x00-0x2B, 0xFF
;   = none, several 0x23) mean.
; --------------------------------------------------------------------------
ByteMap_F72F3C:
	.byte	0xFF, 0x23, 0x23, 0x23, 0x03, 0x01, 0x05, 0x07, 0x02, 0x25, 0x26, 0x27, 0x06, 0x04, 0x28, 0x23	; F72F3C  [0..15]
	.byte	0x00, 0x0B, 0x29, 0x09, 0x08, 0xFF, 0xFF, 0x0A, 0xFF, 0x23, 0xFF, 0x2B, 0x1E, 0x01, 0x00, 0x0E	; F72F4C  [16..31]

; --------------------------------------------------------------------------
; Smf_SplitTrack1ByChannel
; Called from: in-module: 0xF71BDF 0xF72F58
;          ⚠ CORRECTED 2026-09-25: 0xF72F58 was not a call -- those
;          bytes belong to ByteMap_F72F3C; the one caller is 0xF71BDF.
; Touches: (0x0CFA) (0x1010) (0x1198) (0x119A) (0x119B) (0x1238) (0x1239)
;          (0x34D4)
; Calls:   SmfSplit_LoadAndFreeSourceBlock SmfSplit_DetachTrack Smf_AllocFirstBlockForAllTracks_B Smf_PutDefaultTimeSigOnMasterTrack SmfSplit_FetchSourceEvent SmfSplit_PutMarkOnAllTracks
;          SmfSplit_LoadTrackCursor SmfSplit_SaveTrackEndCursor 0xF731FB SmfSplit_PutEventBytes SmfSplit_MarkTrackUsed SmfSplit_SaveTrackCursor
;          +1 more
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF72F5C is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_SplitTrack1ByChannel: Multi-track import, after every MTrk was merged into track 1: needs 17 free blocks (else
;   (0x1238) := 0xFF); copies track 1's blocks through the 0x60A000 window, resets all 17 entries (SmfSplit_DetachTrack), gives
;   each a fresh block (Smf_AllocFirstBlockForAllTracks_B), writes the master track's default time signature, then appends each event to
;   track = its MIDI channel, re-tagged (0xDn->0xD1, 0xEn->0xD2, 0xFn->0xD3 ...), beat marks and the end tag to all
;   17. Smf_ReadMultiTrack runs it before Smf_ResetTrackAssignToIdentity. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_v.json)
Smf_SplitTrack1ByChannel:
	cpw	(BStore_FreeCount:24), 0x0011	; F72F5C  cp (0x6034ba),0x0011
	jr	nc, Smf_SplitTrack1ByChannel_Skip15	; F72F63  jr NC,0xf72f6d
	ld	(4664:16), 255	; F72F65  ld (0x1238),0xff
	jrl	Smf_SplitTrack1ByChannel_Join3	; F72F6A  jrl T,0xf731a2
Smf_SplitTrack1ByChannel_Skip15:
	ld	de, (6305025:24)	; F72F6D  ld DE,(0x603501)
	ld	hl, de	; F72F72  ld HL,DE
	calr	SmfSplit_LoadAndFreeSourceBlock	; F72F74  calr 0xf7335a
	ld	(3322:16), iy	; F72F77  ld (0x0cfa),IY
	pushw	de	; F72F7B  push DE
	ldw	hl, 1	; F72F7C  ld HL,0x0001
Smf_SplitTrack1ByChannel_Loop:
	pushw	hl	; F72F7F  push HL
	calr	SmfSplit_DetachTrack	; F72F80  calr 0xf7330a
	popw	hl	; F72F83  pop HL
	inc	1, hl	; F72F84  inc 1,HL
	cp	hl, 17	; F72F86  cp HL,0x0011
	jr	ule, Smf_SplitTrack1ByChannel_Loop	; F72F8A  jr ULE,0xf72f7f
	popw	de	; F72F8C  pop DE
	calr	Smf_AllocFirstBlockForAllTracks_B	; F72F8D  calr 0xf73566
	cp	(0x1010:16), 0x00	; F72F90  cp (0x1010),0x00
	jrl	nz, Smf_SplitTrack1ByChannel_Return	; F72F95  jrl NZ,0xf731aa
	ld	(6332690:24), 0	; F72F98  ld (0x60a112),0x00
	call	Smf_PutDefaultTimeSigOnMasterTrack	; F72F9E  call 0xf6fa70
Smf_SplitTrack1ByChannel_Loop2:
	calr	SmfSplit_FetchSourceEvent	; F72FA2  calr 0xf7339c
	ld	a, (Smf_VlqValue:16)	; F72FA5  ld A,(0x1198)
	cp	a, 129	; F72FA9  cp A,0x81
	jr	z, Smf_SplitTrack1ByChannel_Skip	; F72FAC  jr Z,0xf72fe0
	cp	a, 130	; F72FAE  cp A,0x82
	jr	z, Smf_SplitTrack1ByChannel_Skip2	; F72FB1  jr Z,0xf72fe7
	and	a, 240	; F72FB3  and A,0xf0
	cp	a, 144	; F72FB6  cp A,0x90
	jr	z, Smf_SplitTrack1ByChannel_Skip3	; F72FB9  jr Z,0xf7300a
	cp	a, 160	; F72FBB  cp A,0xa0
	jr	z, Smf_SplitTrack1ByChannel_Skip4	; F72FBE  jr Z,0xf7302b
	cp	a, 176	; F72FC0  cp A,0xb0
	jrl	z, Smf_SplitTrack1ByChannel_Skip6	; F72FC3  jrl Z,0xf73074
	cp	a, 192	; F72FC6  cp A,0xc0
	jrl	z, Smf_SplitTrack1ByChannel_Skip10	; F72FC9  jrl Z,0xf73107
	cp	a, 208	; F72FCC  cp A,0xd0
	jrl	z, Smf_SplitTrack1ByChannel_Skip12	; F72FCF  jrl Z,0xf7313f
	cp	a, 224	; F72FD2  cp A,0xe0
	jrl	z, Smf_SplitTrack1ByChannel_Skip13	; F72FD5  jrl Z,0xf73160
	cp	a, 240	; F72FD8  cp A,0xf0
	jrl	z, Smf_SplitTrack1ByChannel_Skip14	; F72FDB  jrl Z,0xf73181
	jr	Smf_SplitTrack1ByChannel_Loop2	; F72FDE  jr T,0xf72fa2
Smf_SplitTrack1ByChannel_Skip:
	ld	a, 129:opc	; F72FE0  ld A,0x81
	calr	SmfSplit_PutMarkOnAllTracks	; F72FE2  calr 0xf7328f
	jr	Smf_SplitTrack1ByChannel_Loop2	; F72FE5  jr T,0xf72fa2
Smf_SplitTrack1ByChannel_Skip2:
	ld	a, 130:opc	; F72FE7  ld A,0x82
	calr	SmfSplit_PutMarkOnAllTracks	; F72FE9  calr 0xf7328f
	xor	hl, hl	; F72FEC  xor HL,HL
	xor	iy, iy	; F72FEE  xor IY,IY
Smf_SplitTrack1ByChannel_Loop3:
	pushw	hl	; F72FF0  push HL
	pushw	iy	; F72FF1  push IY
	calr	SmfSplit_LoadTrackCursor	; F72FF2  calr 0xf73440
	calr	SmfSplit_SaveTrackEndCursor	; F72FF5  calr 0xf734c6
	popw	iy	; F72FF8  pop IY
	popw	hl	; F72FF9  pop HL
	inc	1, iy	; F72FFA  inc 1,IY
	inc	1, hl	; F72FFC  inc 1,HL
	cp	iy, 16	; F72FFE  cp IY,0x0010
	jr	ule, Smf_SplitTrack1ByChannel_Loop3	; F73002  jr ULE,0xf72ff0
	calr	SmfSplit_ClearUnusedTracks	; F73004  calr 0xf731fb
	jrl	Smf_SplitTrack1ByChannel_Join3	; F73007  jrl T,0xf731a2
Smf_SplitTrack1ByChannel_Skip3:
	ld	iy, (Smf_VlqValue:16)	; F7300A  ld IY,(0x1198)
	and	iy, 15	; F7300E  and IY,0x000f
	and	(Smf_VlqValue:16), 0xf0	; F73012  and (0x1198),0xf0
	pushw	iy	; F73017  push IY
	calr	SmfSplit_LoadTrackCursor	; F73018  calr 0xf73440
	ldw	bc, 6	; F7301B  ld BC,0x0006
	calr	SmfSplit_PutEventBytes	; F7301E  calr 0xf73261
	popw	iy	; F73021  pop IY
	calr	SmfSplit_MarkTrackUsed	; F73022  calr 0xf73236
	calr	SmfSplit_SaveTrackCursor	; F73025  calr 0xf73469
	jrl	Smf_SplitTrack1ByChannel_Loop2	; F73028  jrl T,0xf72fa2
Smf_SplitTrack1ByChannel_Skip4:
	cp	hl, 3:i3	; F7302B  cp HL,3
	jr	z, Smf_SplitTrack1ByChannel_Skip5	; F7302D  jr Z,0xf73053
	ld	iy, (Smf_VlqValue:16)	; F7302F  ld IY,(0x1198)
	and	iy, 15	; F73033  and IY,0x000f
	ldw	iy, 16	; F73037  ld IY,0x0010
	ld	(Smf_VlqValue:16), 128	; F7303A  ld (0x1198),0x80
	pushw	iy	; F7303F  push IY
	calr	SmfSplit_LoadTrackCursor	; F73040  calr 0xf73440
	ldw	bc, 4	; F73043  ld BC,0x0004
	calr	SmfSplit_PutEventBytes	; F73046  calr 0xf73261
	popw	iy	; F73049  pop IY
	calr	SmfSplit_MarkTrackUsed	; F7304A  calr 0xf73236
	calr	SmfSplit_SaveTrackCursor	; F7304D  calr 0xf73469
	jrl	Smf_SplitTrack1ByChannel_Loop2	; F73050  jrl T,0xf72fa2
Smf_SplitTrack1ByChannel_Skip5:
	ld	iy, (Smf_VlqValue:16)	; F73053  ld IY,(0x1198)
	and	iy, 15	; F73057  and IY,0x000f
	ld	(Smf_VlqValue:16), 208	; F7305B  ld (0x1198),0xd0
	pushw	iy	; F73060  push IY
	calr	SmfSplit_LoadTrackCursor	; F73061  calr 0xf73440
	ldw	bc, 3	; F73064  ld BC,0x0003
	calr	SmfSplit_PutEventBytes	; F73067  calr 0xf73261
	popw	iy	; F7306A  pop IY
	calr	SmfSplit_MarkTrackUsed	; F7306B  calr 0xf73236
	calr	SmfSplit_SaveTrackCursor	; F7306E  calr 0xf73469
	jrl	Smf_SplitTrack1ByChannel_Loop2	; F73071  jrl T,0xf72fa2
Smf_SplitTrack1ByChannel_Skip6:
	xor	hl, hl	; F73074  xor HL,HL
	ld	l, (4506:16)	; F73076  ld L,(0x119a)
	cp	l, 127	; F7307A  cp L,0x7f
	jrl	z, Smf_SplitTrack1ByChannel_Loop2	; F7307D  jrl Z,0xf72fa2
	ld	h, (Smf_VlqValue:16)	; F73080  ld H,(0x1198)
	and	h, 4	; F73084  and H,0x04
	sla	h, 5	; F73087  sla 0x05,H
	or	l, h	; F7308A  or L,H
	cp	l, 181	; F7308C  cp L,0xb5
	jr	z, Smf_SplitTrack1ByChannel_Skip7	; F7308F  jr Z,0xf730b1
	cp	l, 188	; F73091  cp L,0xbc
	jr	z, Smf_SplitTrack1ByChannel_Skip7	; F73094  jr Z,0xf730b1
	cp	l, 189	; F73096  cp L,0xbd
	jr	z, Smf_SplitTrack1ByChannel_Skip7	; F73099  jr Z,0xf730b1
	cp	l, 184	; F7309B  cp L,0xb8
	jr	z, Smf_SplitTrack1ByChannel_Skip7	; F7309E  jr Z,0xf730b1
	cp	l, 185	; F730A0  cp L,0xb9
	jr	z, Smf_SplitTrack1ByChannel_Skip7	; F730A3  jr Z,0xf730b1
	cp	l, 186	; F730A5  cp L,0xba
	jr	z, Smf_SplitTrack1ByChannel_Skip7	; F730A8  jr Z,0xf730b1
	cp	l, 187	; F730AA  cp L,0xbb
	jr	z, Smf_SplitTrack1ByChannel_Skip7	; F730AD  jr Z,0xf730b1
	jr	Smf_SplitTrack1ByChannel_Join	; F730AF  jr T,0xf730d5
Smf_SplitTrack1ByChannel_Skip7:
	ld	l, (4507:16)	; F730B1  ld L,(0x119b)
	xor	h, h	; F730B5  xor H,H
	extz	xhl	; F730B7  extz XHL
	push	xix	; F730B9  push XIX
	ld	xix, ByteMap_F731AB	; F730BA  ld XIX,0x00f731ab
	cp	(0x1239:16), 0x00	; F730BF  cp (0x1239),0x00
	jr	z, Smf_SplitTrack1ByChannel_Skip8	; F730C4  jr Z,0xf730cb
	ld	xix, ByteMap_F731AB + 0x10	; F730C6  ld XIX,0x00f731bb
Smf_SplitTrack1ByChannel_Skip8:
	ld	a, (xix+hl)	; F730CB  ld A,(XIX+HL)
	pop	xix	; F730D0  pop XIX
	ld	l, a	; F730D1  ld L,A
	jr	Smf_SplitTrack1ByChannel_Join2	; F730D3  jr T,0xf730f1
Smf_SplitTrack1ByChannel_Join:
	push	xix	; F730D5  push XIX
	ld	xix, ByteMap_F731DB	; F730D6  ld XIX,0x00f731db
	cp	(0x1239:16), 0x00	; F730DB  cp (0x1239),0x00
	jr	z, Smf_SplitTrack1ByChannel_Skip9	; F730E0  jr Z,0xf730e7
	ld	xix, ByteMap_F731DB + 0x10	; F730E2  ld XIX,0x00f731eb
Smf_SplitTrack1ByChannel_Skip9:
	ld	a, (xix+hl)	; F730E7  ld A,(XIX+HL)
	pop	xix	; F730EC  pop XIX
	ld	(4506:16), a	; F730ED  ld (0x119a),A
Smf_SplitTrack1ByChannel_Join2:
	ld	iy, hl	; F730F1  ld IY,HL
	pushw	iy	; F730F3  push IY
	calr	SmfSplit_LoadTrackCursor	; F730F4  calr 0xf73440
	ldw	bc, 6	; F730F7  ld BC,0x0006
	calr	SmfSplit_PutEventBytes	; F730FA  calr 0xf73261
	popw	iy	; F730FD  pop IY
	calr	SmfSplit_MarkTrackUsed	; F730FE  calr 0xf73236
	calr	SmfSplit_SaveTrackCursor	; F73101  calr 0xf73469
	jrl	Smf_SplitTrack1ByChannel_Loop2	; F73104  jrl T,0xf72fa2
Smf_SplitTrack1ByChannel_Skip10:
	xor	hl, hl	; F73107  xor HL,HL
	ld	l, (4506:16)	; F73109  ld L,(0x119a)
	push	xix	; F7310D  push XIX
	ld	xix, ByteMap_F731DB	; F7310E  ld XIX,0x00f731db
	cp	(0x1239:16), 0x00	; F73113  cp (0x1239),0x00
	jr	z, Smf_SplitTrack1ByChannel_Skip11	; F73118  jr Z,0xf7311f
	ld	xix, ByteMap_F731DB + 0x10	; F7311A  ld XIX,0x00f731eb
Smf_SplitTrack1ByChannel_Skip11:
	ld	a, (xix+hl)	; F7311F  ld A,(XIX+HL)
	pop	xix	; F73124  pop XIX
	ld	(4506:16), a	; F73125  ld (0x119a),A
	ld	iy, hl	; F73129  ld IY,HL
	pushw	iy	; F7312B  push IY
	calr	SmfSplit_LoadTrackCursor	; F7312C  calr 0xf73440
	ldw	bc, 6	; F7312F  ld BC,0x0006
	calr	SmfSplit_PutEventBytes	; F73132  calr 0xf73261
	popw	iy	; F73135  pop IY
	calr	SmfSplit_MarkTrackUsed	; F73136  calr 0xf73236
	calr	SmfSplit_SaveTrackCursor	; F73139  calr 0xf73469
	jrl	Smf_SplitTrack1ByChannel_Loop2	; F7313C  jrl T,0xf72fa2
Smf_SplitTrack1ByChannel_Skip12:
	ld	iy, (Smf_VlqValue:16)	; F7313F  ld IY,(0x1198)
	and	iy, 15	; F73143  and IY,0x000f
	ld	(Smf_VlqValue:16), 209	; F73147  ld (0x1198),0xd1
	pushw	iy	; F7314C  push IY
	calr	SmfSplit_LoadTrackCursor	; F7314D  calr 0xf73440
	ldw	bc, 3	; F73150  ld BC,0x0003
	calr	SmfSplit_PutEventBytes	; F73153  calr 0xf73261
	popw	iy	; F73156  pop IY
	calr	SmfSplit_MarkTrackUsed	; F73157  calr 0xf73236
	calr	SmfSplit_SaveTrackCursor	; F7315A  calr 0xf73469
	jrl	Smf_SplitTrack1ByChannel_Loop2	; F7315D  jrl T,0xf72fa2
Smf_SplitTrack1ByChannel_Skip13:
	ld	iy, (Smf_VlqValue:16)	; F73160  ld IY,(0x1198)
	and	iy, 15	; F73164  and IY,0x000f
	ld	(Smf_VlqValue:16), 210	; F73168  ld (0x1198),0xd2
	pushw	iy	; F7316D  push IY
	calr	SmfSplit_LoadTrackCursor	; F7316E  calr 0xf73440
	ldw	bc, 4	; F73171  ld BC,0x0004
	calr	SmfSplit_PutEventBytes	; F73174  calr 0xf73261
	popw	iy	; F73177  pop IY
	calr	SmfSplit_MarkTrackUsed	; F73178  calr 0xf73236
	calr	SmfSplit_SaveTrackCursor	; F7317B  calr 0xf73469
	jrl	Smf_SplitTrack1ByChannel_Loop2	; F7317E  jrl T,0xf72fa2
Smf_SplitTrack1ByChannel_Skip14:
	ld	iy, (Smf_VlqValue:16)	; F73181  ld IY,(0x1198)
	and	iy, 15	; F73185  and IY,0x000f
	ld	(Smf_VlqValue:16), 211	; F73189  ld (0x1198),0xd3
	calr	SmfSplit_LoadTrackCursor	; F7318E  calr 0xf73440
	pushw	iy	; F73191  push IY
	ldw	bc, 3	; F73192  ld BC,0x0003
	calr	SmfSplit_PutEventBytes	; F73195  calr 0xf73261
	popw	iy	; F73198  pop IY
	calr	SmfSplit_MarkTrackUsed	; F73199  calr 0xf73236
	calr	SmfSplit_SaveTrackCursor	; F7319C  calr 0xf73469
	jrl	Smf_SplitTrack1ByChannel_Loop2	; F7319F  jrl T,0xf72fa2
Smf_SplitTrack1ByChannel_Join3:
	calr	SmfSplit_RewindUsedTracks	; F731A2  calr 0xf734fb
	or	(0x34d4:16), 0x10	; F731A5  or (0x34d4),0x10
Smf_SplitTrack1ByChannel_Return:
	ret	; F731AA  ret

; --------------------------------------------------------------------------
; ByteMap_F731AB -- 32 bytes: 2 BYTE MAPS end to end, 16 bytes at 0xF731AB
;                   (0x00..0x0F), 16 bytes at 0xF731BB (0x00..0x0F).  Each
;                   ascends STRICTLY on its own and the sequence RESTARTS at
;                   each boundary, so this is N maps of the same shape
;                   rather than one long one.  The name describes the
;                   CONTENT; what the index spaces are is not established
;                   here.
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XIX,0x00f731ab` at
;          0xF730BA (operand field 1 byte in)
; Entry count: 32 bytes.  The run is trimmed of trailing 0xFF, so it claims
;              no padding it did not earn; the byte before it is 0x0E and
;              the LAST byte of it is 0x0F.
; Evidence: every non-0xFF byte is compared with its predecessor on every
;           emit, WITHIN EACH of the 2 maximal ascending runs the rule
;           returns, and the runs are asserted to tile this segment exactly.
;           The BYTEMAP rule fires ZERO times over the proven prom_b
;           instruction text at (16 bytes, 12 values) and also at (20,14),
;           (24,16) and (16,16) (`python3 notes/prom_b_f6d002_layout.py
;           --null-ptr`).
; Unknown: what the two index spaces ARE, and who reads it.
; --------------------------------------------------------------------------
ByteMap_F731AB:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F731AB  [0..15]
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F731BB  [16..31]


; --------------------------------------------------------------------------
; IndexMap_F731CB -- 14 bytes at 0xF731CB counting 0x00..0x0D.  The name
;                    describes the CONTENT and claims nothing about the
;                    purpose.
; Read by: nothing in prom_a or prom_b spells this address as a 32-bit word,
;          so whatever reaches it computes the address
; Entry count: 14 bytes.  The byte before 0xF731CB is 0x0F and the byte at
;              0xF731D9 is 0x0F, so neither end extends.
; Evidence: every byte is compared with its predecessor + 1 on every emit.
;           The IDENT rule fires ZERO times over the proven prom_b
;           instruction text (`python3 notes/prom_b_f6d002_layout.py --null-
;           ptr`).
; Unknown: why an index map that returns its own index exists.  Recorded,
;          not explained.
; --------------------------------------------------------------------------
IndexMap_F731CB:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D	; F731CB  [0..13]


; --------------------------------------------------------------------------
; Data_F731D9 -- 2 bytes this block could not split.  No content rule framed
;                it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or ASCII
;                -- and the code walk never reached it from a thunk slot, a
;                proven call site, an opcode-anchored call or an entry of a
;                table the firmware transfers to.  So it is emitted as bytes
;                rather than guessed.
; Read by: nothing in prom_a or prom_b spells this address as a 32-bit word,
;          so whatever reaches it computes the address
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; Unknown: everything about it except its bytes.
; --------------------------------------------------------------------------
Data_F731D9:
	.byte	0x0F, 0x0E	; F731D9  [0..1]


; --------------------------------------------------------------------------
; ByteMap_F731DB -- 34 bytes: 2 BYTE MAPS end to end, 16 bytes at 0xF731DB
;                   (0x00..0x0F), 18 bytes at 0xF731EB (0x00..0xD3).  Each
;                   ascends STRICTLY on its own and the sequence RESTARTS at
;                   each boundary, so this is N maps of the same shape
;                   rather than one long one.  The name describes the
;                   CONTENT; what the index spaces are is not established
;                   here.
; Read by: 2 byte-scan hits: 2 instruction operands -- `ld XIX,0x00f731db`
;          at 0xF730D6 (operand field 1 byte in); `ld XIX,0x00f731db` at
;          0xF7310E (operand field 1 byte in)
; Entry count: 34 bytes.  The run is trimmed of trailing 0xFF, so it claims
;              no padding it did not earn; the byte before it is 0x0E and
;              the LAST byte of it is 0xD3.
; Evidence: every non-0xFF byte is compared with its predecessor on every
;           emit, WITHIN EACH of the 2 maximal ascending runs the rule
;           returns, and the runs are asserted to tile this segment exactly.
;           The BYTEMAP rule fires ZERO times over the proven prom_b
;           instruction text at (16 bytes, 12 values) and also at (20,14),
;           (24,16) and (16,16) (`python3 notes/prom_b_f6d002_layout.py
;           --null-ptr`).
; Unknown: what the two index spaces ARE, and who reads it.
; --------------------------------------------------------------------------
ByteMap_F731DB:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F731DB  [0..15]
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F731EB  [16..31]
; SmfSplit_ClearUnusedTracks: For tracks 1..17 whose bit in the used mask ((0x360C) bit t-1, (0x360E) bit t-17) is
;   clear: BStore_ClearTrack through T_F40A04 with (0x0C70) = t. Smf_SplitTrack1ByChannel runs it once the 0x82 end
;   tag is on all 17 tracks, so tracks no event reached are emptied; twin of Smf_ClearUnusedTracks. Basis: caller +
;   body + twin. (notes/naming-pilot-2026-10-06/proposals_wave7_y.json)
SmfSplit_ClearUnusedTracks:
; `calr SmfSplit_ClearUnusedTracks` at 0xF73004 lands on `xor C,C` (CB D3), which the source carried as `.byte`.
	xor	c, c	; F731FB  xor C,C

sub_F731FB_Entry:
	ldfr_berp	a, 0x3c	; F731FD  ld RL3,A
	ldfr_werp	de, 0x3e	; F73200  ld QHL3,DE
	ld	de, (13836:16)	; F73203  ld DE,(0x360c)
	ld	a, c	; F73207  ld A,C
	cp	a, 16	; F73209  cp A,0x10
	jr	lt, sub_F731FB_Skip	; F7320C  jr LT,0xf73215
	ld	de, (13838:16)	; F7320E  ld DE,(0x360e)
	sub	a, 16	; F73212  sub A,0x10
sub_F731FB_Skip:
	scf	; F73215  scf
	xorcf_a_16	de	; F73216  xorcf A,DE
	ldto_werp	de, 0x3e	; F73218  ld DE,QHL3
	ldto_berp	a, 0x3c	; F7321B  ld A,RL3
	jr	nc, sub_F731FB_Skip2	; F7321E  jr NC,0xf7322e
	ld	(3184:16), c	; F73220  ld (0x0c70),C
	inc	1, (3184:16)	; F73224  inc 1,(0x0c70)
	pushw	bc	; F73228  push BC
	call	T_F40A04	; F73229  call 0xf40a04
	popw	bc	; F7322D  pop BC
sub_F731FB_Skip2:
	inc	1, c	; F7322E  inc 1,C
	cp	c, 16	; F73230  cp C,0x10
	jr	ule, sub_F731FB_Entry	; F73233  jr ULE,0xf731fd
	ret	; F73235  ret

; --------------------------------------------------------------------------
; SmfSplit_MarkTrackUsed
; Called from: in-module: 0xF73022 0xF7304A 0xF7306B 0xF730FE 0xF73136
;              0xF73157 0xF73178 0xF73199
; Touches: (0x360C) (0x360E)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF73236 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSplit_MarkTrackUsed: Sets bit (IY & 31) of the used-track mask: (0x360C) bit IY for tracks 0..15, (0x360E) bit
;   IY-16 above. Smf_SplitTrack1ByChannel runs it after appending each channel event to track IY, so
;   SmfSplit_ClearUnusedTracks keeps that track. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_y.json)
SmfSplit_MarkTrackUsed:
	ld	bc, iy	; F73236  ld BC,IY
	and	bc, 31	; F73238  and BC,0x001f
	ld	de, (13836:16)	; F7323C  ld DE,(0x360c)
	ld	a, c	; F73240  ld A,C
	cp	a, 16	; F73242  cp A,0x10
	jr	lt, SmfSplit_MarkTrackUsed_Skip	; F73245  jr LT,0xf7324e
	ld	de, (13838:16)	; F73247  ld DE,(0x360e)
	sub	a, 16	; F7324B  sub A,0x10
SmfSplit_MarkTrackUsed_Skip:
	scf	; F7324E  scf
	stcf_a_16	de	; F7324F  stcf A,DE
	cp	c, 16	; F73251  cp C,0x10
	jr	lt, SmfSplit_MarkTrackUsed_Skip2	; F73254  jr LT,0xf7325c
	ld	(13838:16), de	; F73256  ld (0x360e),DE
	jr	SmfSplit_MarkTrackUsed_Return	; F7325A  jr T,0xf73260
SmfSplit_MarkTrackUsed_Skip2:
	ld	(13836:16), de	; F7325C  ld (0x360c),DE
SmfSplit_MarkTrackUsed_Return:
	ret	; F73260  ret

; --------------------------------------------------------------------------
; SmfSplit_PutEventBytes
; Called from: in-module: 0xF7301E 0xF73046 0xF73067 0xF730FA 0xF73132
;              0xF73153 0xF73174 0xF73195
; Touches: (0x1238) (0x345C)
; Calls:   SongStore_SeekBlock_Copy BStore_PutByteAtCursorNoSave SmfSplit_AdvanceWriteCursor
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF73261 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSplit_PutEventBytes: Writes the first BC bytes of the event buffer at Smf_VlqValue (0x1198..) at the BStore
;   cursor (re-seeking BStore_CursorBlock), stepping the cursor after each byte (a new linked block at offset 255) and
;   stopping when (0x1238) reports no free block. Smf_SplitTrack1ByChannel calls it with BC = the re-tagged event's
;   length (6, 4 or 3) between loading and saving the target track's cursor. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_y.json)
SmfSplit_PutEventBytes:
	ld	hl, (BStore_CursorBlock:16)	; F73261  ld HL,(0x345c)
	pushw	bc	; F73265  push BC
	calr	SongStore_SeekBlock_Copy	; F73266  calr 0xf72f0a
	popw	bc	; F73269  pop BC
	xor	ix, ix	; F7326A  xor IX,IX
	push	xde	; F7326C  push XDE
	ld	xde, Smf_VlqValue	; F7326D  ld XDE,0x00001198
	ld	a, (xde+ix)	; F73272  ld A,(XDE+IX)
	pop	xde	; F73277  pop XDE
	pushw	bc	; F73278  push BC
	push	xix	; F73279  push XIX
	calr	BStore_PutByteAtCursorNoSave	; F7327A  calr 0xf732c7
	calr	SmfSplit_AdvanceWriteCursor	; F7327D  calr 0xf732df
	pop	xix	; F73280  pop XIX
	popw	bc	; F73281  pop BC
	cp	(0x1238:16), 0x00	; F73282  cp (0x1238),0x00
	jr	nz, SmfSplit_PutEventBytes_Return	; F73287  jr NZ,0xf7328e
	inc	1, ix	; F73289  inc 1,IX
	djnz16	bc, -34	; F7328B  djnz BC,0xf7326c
SmfSplit_PutEventBytes_Return:
	ret	; F7328E  ret

; --------------------------------------------------------------------------
; SmfSplit_PutMarkOnAllTracks
; Called from: in-module: 0xF72FE2 0xF72FE9
; Touches: (0x1238)
; Calls:   SmfSplit_LoadTrackCursor BStore_PutByteAtCursorNoSave SmfSplit_AdvanceWriteCursor SmfSplit_SaveTrackCursor
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7328F is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSplit_PutMarkOnAllTracks: With A = 0x81 or 0x82: for tracks 0..16 loads the track's cursor, writes A there and
;   saves the cursor -- stepped past a 0x81 beat mark (giving up when (0x1238) reports no free block), left on a 0x82
;   end tag. Smf_SplitTrack1ByChannel runs it when track 1's stream yields a beat mark or its end. Basis: caller +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave7_y.json)
SmfSplit_PutMarkOnAllTracks:
	xor	iy, iy	; F7328F  xor IY,IY
SmfSplit_PutMarkOnAllTracks_Loop:
	pushw	wa	; F73291  push WA
	pushw	iy	; F73292  push IY
	calr	SmfSplit_LoadTrackCursor	; F73293  calr 0xf73440
	popw	iy	; F73296  pop IY
	popw	wa	; F73297  pop WA
	pushw	iy	; F73298  push IY
	pushw	wa	; F73299  push WA
	pushw	iy	; F7329A  push IY
	calr	BStore_PutByteAtCursorNoSave	; F7329B  calr 0xf732c7
	popw	iy	; F7329E  pop IY
	popw	wa	; F7329F  pop WA
	cp	a, 129	; F732A0  cp A,0x81
	jr	nz, SmfSplit_PutMarkOnAllTracks_Skip	; F732A3  jr NZ,0xf732b6
	pushw	wa	; F732A5  push WA
	pushw	iy	; F732A6  push IY
	calr	SmfSplit_AdvanceWriteCursor	; F732A7  calr 0xf732df
	popw	iy	; F732AA  pop IY
	popw	wa	; F732AB  pop WA
	cp	(0x1238:16), 0x00	; F732AC  cp (0x1238),0x00
	jr	z, SmfSplit_PutMarkOnAllTracks_Skip	; F732B1  jr Z,0xf732b6
	popw	iy	; F732B3  pop IY
	jr	SmfSplit_PutMarkOnAllTracks_Return	; F732B4  jr T,0xf732c6
SmfSplit_PutMarkOnAllTracks_Skip:
	popw	iy	; F732B6  pop IY
	pushw	wa	; F732B7  push WA
	pushw	iy	; F732B8  push IY
	calr	SmfSplit_SaveTrackCursor	; F732B9  calr 0xf73469
	popw	iy	; F732BC  pop IY
	popw	wa	; F732BD  pop WA
	inc	1, iy	; F732BE  inc 1,IY
	cp	iy, 16	; F732C0  cp IY,0x0010
	jr	ule, SmfSplit_PutMarkOnAllTracks_Loop	; F732C4  jr ULE,0xf73291
SmfSplit_PutMarkOnAllTracks_Return:
	ret	; F732C6  ret

; --------------------------------------------------------------------------
; BStore_PutByteAtCursorNoSave
; Called from: in-module: 0xF7327A 0xF7329B
; Touches: (0x126E) (0x345C) (0x345E)
; Calls:   SongStore_SeekBlock_Copy
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF732C7 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_PutByteAtCursorNoSave: BStore_PutByteAtCursor's work without saving XHL: SongStore_SeekBlock_Copy for BStore_CursorBlock, then A to
;   BStore_CursorBlockAddr + the low byte of BStore_CursorOffset; called from SmfSplit_PutEventBytes and SmfSplit_PutMarkOnAllTracks.
;   Basis: body, compared with BStore_PutByteAtCursor.
BStore_PutByteAtCursorNoSave:
	ld	hl, (BStore_CursorBlock:16)	; F732C7  ld HL,(0x345c)
	calr	SongStore_SeekBlock_Copy	; F732CB  calr 0xf72f0a
	ld	iy, (BStore_CursorOffset:16)	; F732CE  ld IY,(0x345e)
	and	iy, 255	; F732D2  and IY,0x00ff
	extz	xiy	; F732D6  extz XIY
	add	xiy, (BStore_CursorBlockAddr:16)	; F732D8  add XIY,(0x126e)
	ld	(xiy), a	; F732DC  ld (XIY),A
	ret	; F732DE  ret

; --------------------------------------------------------------------------
; SmfSplit_AdvanceWriteCursor
; Called from: in-module: 0xF7327D 0xF732A7
; Touches: (0x1238) (0x345E)
; Calls:   SmfSplit_ExtendChainAtCursor
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF732DF is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSplit_AdvanceWriteCursor: Steps the BStore cursor one byte: BStore_CursorOffset + 1, or at offset 0xFF with
;   blocks free allocates and links a new block (SmfSplit_ExtendChainAtCursor: +3 of the old, +1 back link, +3 = 0xFFFF; cursor = new
;   block, offset 5); (0x1238) := 0 on success, 0xFF when BStore_FreeCount is 0. SmfSplit_PutEventBytes and
;   SmfSplit_PutMarkOnAllTracks step after each byte they write. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_a8.json)
SmfSplit_AdvanceWriteCursor:
	ld	wa, (BStore_CursorOffset:16)	; F732DF  ld WA,(0x345e)
	cp	wa, 255	; F732E3  cp WA,0x00ff
	jr	nz, SmfSplit_AdvanceWriteCursor_Skip2	; F732E7  jr NZ,0xf732fe
	cpw	(BStore_FreeCount:24), 0x0000	; F732E9  cp (0x6034ba),0x0000
	jr	nz, SmfSplit_AdvanceWriteCursor_Skip	; F732F0  jr NZ,0xf732f9
	ld	(4664:16), 255	; F732F2  ld (0x1238),0xff
	jr	SmfSplit_AdvanceWriteCursor_Return	; F732F7  jr T,0xf73309
SmfSplit_AdvanceWriteCursor_Skip:
	calr	SmfSplit_ExtendChainAtCursor	; F732F9  calr 0xf7348e
	jr	SmfSplit_AdvanceWriteCursor_Join	; F732FC  jr T,0xf73304
SmfSplit_AdvanceWriteCursor_Skip2:
	inc	1, wa	; F732FE  inc 1,WA
	ld	(BStore_CursorOffset:16), wa	; F73300  ld (0x345e),WA
SmfSplit_AdvanceWriteCursor_Join:
	ld	(4664:16), 0	; F73304  ld (0x1238),0x00
SmfSplit_AdvanceWriteCursor_Return:
	ret	; F73309  ret

; --------------------------------------------------------------------------
; SmfSplit_DetachTrack
; Called from: in-module: 0xF72F80
; Touches:   |  0x60347E 0x6034A0 0x603500
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7330A is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSplit_DetachTrack: For track HL (1-based): clears its directory entry's in-use bit, sets its head to 0xFFFF and
;   resets its song position and end cursor (0x3460/0x60347E := 0xFFFF, 0x3482/0x6034A0 := 5), freeing nothing.
;   Smf_SplitTrack1ByChannel runs it on tracks 1..17 after taking track 1's head block into the staging buffer; twin
;   of TrackMerge_DetachSourceTrack (muls spelled on IYL). Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_y.json)
SmfSplit_DetachTrack:
	push	xix	; F7330A  push XIX
	dec	1, hl	; F7330B  dec 1,HL
	ld	iy, hl	; F7330D  ld IY,HL
	.byte 0xC7, 0xF4, 0x09, 0x03	; F7330F  muls IYL,0x03   [llvm-mc cannot encode this]
	ld	xix, 6305024	; F73313  ld XIX,0x00603500
	and	(xix+iy), 0x7f	; F73318  and (XIX+IY),0x7f
	inc	1, iy	; F7331E  inc 1,IY
	ldw	(xix+iy), 0xffff	; F73320  ld (XIX+IY),0xffff
	ld	xix, 13442	; F73327  ld XIX,0x00003482
	ld	(xix+hl), 0x05	; F7332C  ld (XIX+HL),0x05
	ld	xix, 6304928	; F73332  ld XIX,0x006034a0
	ld	(xix+hl), 0x05	; F73337  ld (XIX+HL),0x05
	sla	hl, 1	; F7333D  sla 0x01,HL
	ld	xix, 13408	; F73340  ld XIX,0x00003460
	ldw	(xix+hl), 0xffff	; F73345  ld (XIX+HL),0xffff
	ld	xix, 6304894	; F7334C  ld XIX,0x0060347e
	ldw	(xix+hl), 0xffff	; F73351  ld (XIX+HL),0xffff
	pop	xix	; F73358  pop XIX
	ret	; F73359  ret

; --------------------------------------------------------------------------
; SmfSplit_LoadAndFreeSourceBlock
; Called from: in-module: 0xF72F74 0xF73435
; Touches: (0x126E)  |  0x60A000
; Calls:   SongStore_SeekBlock_Copy T_BStore_FreeChain_Veneer
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7335A is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSplit_LoadAndFreeSourceBlock: Seeks block HL, copies its 256 bytes into the staging buffer 0x60A000, returns the
;   block to the free list (T_BStore_FreeChain_Veneer, IY = HL, WA = 1), restores (0x126E) and sets IY = 5.
;   Smf_SplitTrack1ByChannel loads track 1's head block (0x603501) with it and the source-cursor step each next block,
;   so track 1 is consumed as it is split; cf. TrackMerge_LoadAndFreeBlock. Basis: callers + body + twin.
;   (notes/naming-pilot-2026-10-06/proposals_wave7_y.json)
SmfSplit_LoadAndFreeSourceBlock:
	push	xiz	; F7335A  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F7335B  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F7335F  ld XDE3,XIZ
	pop	xiz	; F73362  pop XIZ
	push_lerp	0x38	; F73363  push XDE3
	pushw	bc	; F73366  push BC
	push	xhl	; F73367  push XHL
	calr	SongStore_SeekBlock_Copy	; F73368  calr 0xf72f0a
	xor	xiy, xiy	; F7336B  xor XIY,XIY
	ld	xiy, (BStore_CursorBlockAddr:16)	; F7336D  ld XIY,(0x126e)
	ld	xix, 6332416	; F73371  ld XIX,0x0060a000
	ldw	bc, 256	; F73376  ld BC,0x0100
	ldir85	; F73379  ldir
	pop	xhl	; F7337B  pop XHL
	popw	bc	; F7337C  pop BC
	ld	iy, hl	; F7337D  ld IY,HL
	ldw	wa, 1	; F7337F  ld WA,0x0001
	pushw	bc	; F73382  push BC
	push	xhl	; F73383  push XHL
	call	T_BStore_FreeChain_Veneer	; F73384  call 0xf42888
	pop	xhl	; F73388  pop XHL
	popw	bc	; F73389  pop BC
	pop_lerp	0x38	; F7338A  pop XDE3
	push	xiz	; F7338D  push XIZ
	ldto_lerp	xiz, 0x38	; F7338E  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F73391  ld (0x126e),XIZ
	pop	xiz	; F73395  pop XIZ
	xor	xiy, xiy	; F73396  xor XIY,XIY
	ldw	iy, 5	; F73398  ld IY,0x0005
	ret	; F7339B  ret

; --------------------------------------------------------------------------
; SmfSplit_FetchSourceEvent
; Called from: in-module: 0xF72FA2
; Touches: (0x0CFA)  |  0x60A000
; Calls:   SmfSplit_ClearEventBuffer SmfSplit_AdvanceReadCursor
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7339C is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSplit_FetchSourceEvent: Clears the buffer at Smf_VlqValue (0x1198..0x119E) and copies track 1's next item from
;   the staging buffer 0x60A000 at (0x0CFA) into it: a 0x82 end alone (not stepped past), otherwise the lead byte and
;   the bytes after it up to the next byte with bit 7 set, stepping the source cursor across blocks.
;   Smf_SplitTrack1ByChannel's loop reads every item with it and dispatches on the lead byte. Basis: caller + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave7_y.json)
SmfSplit_FetchSourceEvent:
	xor	hl, hl	; F7339C  xor HL,HL
	calr	SmfSplit_ClearEventBuffer	; F7339E  calr 0xf734e8
	ld	iy, (3322:16)	; F733A1  ld IY,(0x0cfa)
	push	xix	; F733A5  push XIX
	ld	xix, 6332416	; F733A6  ld XIX,0x0060a000
	ld	a, (xix+iy)	; F733AB  ld A,(XIX+IY)
	ld	xix, Smf_VlqValue	; F733B0  ld XIX,0x00001198
	ld	(xix+hl), a	; F733B5  ld (XIX+HL),A
	pop	xix	; F733BA  pop XIX
	cp	a, 130	; F733BB  cp A,0x82
	jr	z, SmfSplit_FetchSourceEvent_Return	; F733BE  jr Z,0xf733ea
SmfSplit_FetchSourceEvent_Join:
	inc	1, hl	; F733C0  inc 1,HL
	pushw	hl	; F733C2  push HL
	calr	SmfSplit_AdvanceReadCursor	; F733C3  calr 0xf733eb
	popw	hl	; F733C6  pop HL
	ld	iy, (3322:16)	; F733C7  ld IY,(0x0cfa)
	push	xix	; F733CB  push XIX
	ld	xix, 6332416	; F733CC  ld XIX,0x0060a000
	ld	a, (xix+iy)	; F733D1  ld A,(XIX+IY)
	pop	xix	; F733D6  pop XIX
	bit	7, a	; F733D7  bit 0x07,A
	jr	nz, SmfSplit_FetchSourceEvent_Return	; F733DA  jr NZ,0xf733ea
	push	xix	; F733DC  push XIX
	ld	xix, Smf_VlqValue	; F733DD  ld XIX,0x00001198
	ld	(xix+hl), a	; F733E2  ld (XIX+HL),A
	pop	xix	; F733E7  pop XIX
	jr	SmfSplit_FetchSourceEvent_Join	; F733E8  jr T,0xf733c0
SmfSplit_FetchSourceEvent_Return:
	ret	; F733EA  ret

; --------------------------------------------------------------------------
; SmfSplit_AdvanceReadCursor
; Called from: in-module: 0xF733C3
; Touches: (0x0CFA) (0x0D4A) (0x126E) (0x345C) (0x3608)  |  0x60A000
; Calls:   SongStore_SeekBlock_Copy SmfSplit_LoadAndFreeSourceBlock
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF733EB is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSplit_AdvanceReadCursor: Steps track 1's read cursor (0x0CFA) one byte in the staging buffer 0x60A000; past
;   offset 0xFF follows the staged block's +3 link (0xFFFF -> error 2, above BStore_BlockCount -> 10, not in use ->
;   11) and loads + frees that block (SmfSplit_LoadAndFreeSourceBlock, IY = 5). SmfSplit_FetchSourceEvent steps with
;   it after each byte it buffers; cf. SmfMerge_AdvanceReadCursor. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_a8.json)
SmfSplit_AdvanceReadCursor:
	ld	iy, (3322:16)	; F733EB  ld IY,(0x0cfa)
	ld	xix, 6332416	; F733EF  ld XIX,0x0060a000
	inc	1, iy	; F733F4  inc 1,IY
	cp	iy, 255	; F733F6  cp IY,0x00ff
	jr	ule, SmfSplit_AdvanceReadCursor_Join	; F733FA  jr ULE,0xf7343b
	ld	wa, (xix+3)	; F733FC  ld WA,(XIX+0x03)
	cp	wa, 65535	; F733FF  cp WA,0xffff
	jr	nz, SmfSplit_AdvanceReadCursor_Skip	; F73403  jr NZ,0xf7340c
	ld	(BStore_ErrorCode:16), 2	; F73405  ld (0x0d4a),0x02
	jr	SmfSplit_AdvanceReadCursor_Join	; F7340A  jr T,0xf7343b
SmfSplit_AdvanceReadCursor_Skip:
	cp	wa, (BStore_BlockCount:16)	; F7340C  cp WA,(0x3608)
	jr	ule, SmfSplit_AdvanceReadCursor_Skip2	; F73410  jr ULE,0xf73419
	ld	(BStore_ErrorCode:16), 10	; F73412  ld (0x0d4a),0x0a
	jr	SmfSplit_AdvanceReadCursor_Join	; F73417  jr T,0xf7343b
SmfSplit_AdvanceReadCursor_Skip2:
	ld	(BStore_CursorBlock:16), wa	; F73419  ld (0x345c),WA
	ld	hl, wa	; F7341D  ld HL,WA
	calr	SongStore_SeekBlock_Copy	; F7341F  calr 0xf72f0a
	ld	xhl, (BStore_CursorBlockAddr:16)	; F73422  ld XHL,(0x126e)
	bit	7, (xhl)	; F73426  bit 7,(XHL)
	jr	nz, SmfSplit_AdvanceReadCursor_Skip3	; F73428  jr NZ,0xf73431
	ld	(BStore_ErrorCode:16), 11	; F7342A  ld (0x0d4a),0x0b
	jr	SmfSplit_AdvanceReadCursor_Join	; F7342F  jr T,0xf7343b
SmfSplit_AdvanceReadCursor_Skip3:
	ld	hl, (BStore_CursorBlock:16)	; F73431  ld HL,(0x345c)
	calr	SmfSplit_LoadAndFreeSourceBlock	; F73435  calr 0xf7335a
	ldw	iy, 5	; F73438  ld IY,0x0005
SmfSplit_AdvanceReadCursor_Join:
	ld	(3322:16), iy	; F7343B  ld (0x0cfa),IY
	ret	; F7343F  ret

; --------------------------------------------------------------------------
; SmfSplit_LoadTrackCursor
; Called from: in-module: 0xF72FF2 0xF73018 0xF73040 0xF73061 0xF730F4
;              0xF7312C 0xF7314D 0xF7316E +2 more
; Touches: (0x345C) (0x345E)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF73440 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSplit_LoadTrackCursor: BStore_CursorBlock := word 0x3460[IY], BStore_CursorOffset := byte 0x3482[IY]: track IY's
;   song position into the BStore cursor (TrackCursor_Load with XIX for XDE). Smf_SplitTrack1ByChannel loads the
;   target track with it before each append, and SmfSplit_PutMarkOnAllTracks for every track. Basis: callers + body +
;   twin. (notes/naming-pilot-2026-10-06/proposals_wave7_y.json)
SmfSplit_LoadTrackCursor:
	sla	iy, 1	; F73440  sla 0x01,IY
	push	xix	; F73443  push XIX
	ld	xix, 13408	; F73444  ld XIX,0x00003460
	ld	wa, (xix+iy)	; F73449  ld WA,(XIX+IY)
	pop	xix	; F7344E  pop XIX
	ld	(BStore_CursorBlock:16), wa	; F7344F  ld (0x345c),WA
	srl	iy, 1	; F73453  srl 0x01,IY
	push	xix	; F73456  push XIX
	ld	xix, 13442	; F73457  ld XIX,0x00003482
	ld	a, (xix+iy)	; F7345C  ld A,(XIX+IY)
	pop	xix	; F73461  pop XIX
	xor	w, w	; F73462  xor W,W
	ld	(BStore_CursorOffset:16), wa	; F73464  ld (0x345e),WA
	ret	; F73468  ret

; --------------------------------------------------------------------------
; SmfSplit_SaveTrackCursor
; Called from: in-module: 0xF73025 0xF7304D 0xF7306E 0xF73101 0xF73139
;              0xF7315A 0xF7317B 0xF7319C +1 more
; Touches: (0x345C) (0x345E)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF73469 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSplit_SaveTrackCursor: Word 0x3460[IY] := BStore_CursorBlock, byte 0x3482[IY] := BStore_CursorOffset: the BStore
;   cursor back into track IY's song position (TrackCursor_Save's work). Smf_SplitTrack1ByChannel saves the target
;   track with it after each append, and SmfSplit_PutMarkOnAllTracks after each mark. Basis: callers + body + twin.
;   (notes/naming-pilot-2026-10-06/proposals_wave7_y.json)
SmfSplit_SaveTrackCursor:
	ld	wa, (BStore_CursorBlock:16)	; F73469  ld WA,(0x345c)
	sla	iy, 1	; F7346D  sla 0x01,IY
	push	xix	; F73470  push XIX
	ld	xix, 13408	; F73471  ld XIX,0x00003460
	ld	(xix+iy), wa	; F73476  ld (XIX+IY),WA
	ld	wa, (BStore_CursorOffset:16)	; F7347B  ld WA,(0x345e)
	srl	iy, 1	; F7347F  srl 0x01,IY
	ld	xix, 13442	; F73482  ld XIX,0x00003482
	ld	(xix+iy), a	; F73487  ld (XIX+IY),A
	pop	xix	; F7348C  pop XIX
	ret	; F7348D  ret

; --------------------------------------------------------------------------
; SmfSplit_ExtendChainAtCursor
; Called from: in-module: 0xF732F9
; Touches: (0x126E) (0x345C) (0x345E)
; Calls:   T_BStore_AllocBlock_Veneer SongStore_SeekBlock_Copy
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7348E is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSplit_ExtendChainAtCursor: Allocates a block (T_BStore_AllocBlock_Veneer), links it after the cursor block (old
;   +3 := new, new +1 := old, new +3 := 0xFFFF) and moves the cursor to it at offset 5. SmfSplit_AdvanceWriteCursor's
;   step at offset 0xFF; the SMF-split module's copy of BStore_ExtendChainAtCursor (through its own
;   SongStore_SeekBlock_Copy). Basis: caller + caller header + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_d9.json)
SmfSplit_ExtendChainAtCursor:
	push	xix	; F7348E  push XIX
	push	xiy	; F7348F  push XIY
	call	T_BStore_AllocBlock_Veneer	; F73490  call 0xf42884
	ld	wa, ix	; F73494  ld WA,IX
	ld	hl, (BStore_CursorBlock:16)	; F73496  ld HL,(0x345c)
	calr	SongStore_SeekBlock_Copy	; F7349A  calr 0xf72f0a
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7349D  ld XHL,(0x126e)
	ld	(xhl+3), wa	; F734A1  ld (XHL+0x03),WA
	ld	hl, wa	; F734A4  ld HL,WA
	calr	SongStore_SeekBlock_Copy	; F734A6  calr 0xf72f0a
	ld	xhl, (BStore_CursorBlockAddr:16)	; F734A9  ld XHL,(0x126e)
	ld	bc, (BStore_CursorBlock:16)	; F734AD  ld BC,(0x345c)
	ld	(xhl+1), bc	; F734B1  ld (XHL+0x01),BC
	ldw	(xhl+3), 0xffff	; F734B4  ld (XHL+0x03),0xffff
	ld	(BStore_CursorBlock:16), wa	; F734B9  ld (0x345c),WA
	ldw	(BStore_CursorOffset:16), 5	; F734BD  ld (0x345e),0x0005
	pop	xiy	; F734C3  pop XIY
	pop	xix	; F734C4  pop XIX
	ret	; F734C5  ret

; --------------------------------------------------------------------------
; SmfSplit_SaveTrackEndCursor
; Called from: in-module: 0xF72FF5
; Touches: (0x345C) (0x345E)  |  0x60347E 0x6034A0
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF734C6 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSplit_SaveTrackEndCursor: Track HL's (0-based) end cursor := the BStore cursor: 0x6034A0[HL] :=
;   BStore_CursorOffset, 0x60347E[HL] := BStore_CursorBlock. With the 0x82 end tag on all 17 tracks,
;   Smf_SplitTrack1ByChannel loads each track's cursor (left on the tag) and runs it; cf. Smf_SaveTrackEndCursor.
;   Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave7_y.json)
SmfSplit_SaveTrackEndCursor:
	push	xix	; F734C6  push XIX
	ld	xix, 6304928	; F734C7  ld XIX,0x006034a0
	ld	wa, (BStore_CursorOffset:16)	; F734CC  ld WA,(0x345e)
	ld	(xix+hl), a	; F734D0  ld (XIX+HL),A
	sla	hl, 1	; F734D5  sla 0x01,HL
	ld	wa, (BStore_CursorBlock:16)	; F734D8  ld WA,(0x345c)
	ld	xix, 6304894	; F734DC  ld XIX,0x0060347e
	ld	(xix+hl), wa	; F734E1  ld (XIX+HL),WA
	pop	xix	; F734E6  pop XIX
	ret	; F734E7  ret

; --------------------------------------------------------------------------
; SmfSplit_ClearEventBuffer
; Called from: in-module: 0xF7339E
; Touches: (0x1198) (0x119A) (0x119C) (0x119E)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF734E8 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSplit_ClearEventBuffer: Zeroes the 7-byte event buffer at Smf_VlqValue (0x1198..0x119E: three words and a byte).
;   SmfSplit_FetchSourceEvent calls it first, before copying track 1's next item into that buffer. Basis: caller +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave8_b8.json)
SmfSplit_ClearEventBuffer:
	xor	wa, wa	; F734E8  xor WA,WA
	ld	(Smf_VlqValue:16), wa	; F734EA  ld (0x1198),WA
	ld	(4506:16), wa	; F734EE  ld (0x119a),WA
	ld	(4508:16), wa	; F734F2  ld (0x119c),WA
	ld	(4510:16), a	; F734F6  ld (0x119e),A
	ret	; F734FA  ret

; --------------------------------------------------------------------------
; SmfSplit_RewindUsedTracks
; Called from: in-module: 0xF731A2
; Touches: (0x360C) (0x360E)  |  0x603500
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF734FB is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSplit_RewindUsedTracks: For tracks 0..16 whose used-mask bit ((0x360C)/(0x360E)) is set and whose directory entry
;   (0x603500 + 3t) is in use: song position 0x3460[t] := the entry's head block, 0x3482[t] := 5.
;   Smf_SplitTrack1ByChannel's exit step (both the normal and the not-enough-blocks path), before it sets (0x34D4) bit
;   4. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave7_y.json)
SmfSplit_RewindUsedTracks:
	push	xix	; F734FB  push XIX
	xor	hl, hl	; F734FC  xor HL,HL
	xor	bc, bc	; F734FE  xor BC,BC
sub_F734FB_Entry:
	ldfr_berp	a, 0x3c	; F73500  ld RL3,A
	ldfr_werp	de, 0x3e	; F73503  ld QHL3,DE
	ld	de, (13836:16)	; F73506  ld DE,(0x360c)
	ld	a, c	; F7350A  ld A,C
	cp	a, 16	; F7350C  cp A,0x10
	jr	lt, sub_F734FB_Skip	; F7350F  jr LT,0xf73518
	ld	de, (13838:16)	; F73511  ld DE,(0x360e)
	sub	a, 16	; F73515  sub A,0x10
sub_F734FB_Skip:
	scf	; F73518  scf
	xorcf_a_16	de	; F73519  xorcf A,DE
	ldto_werp	de, 0x3e	; F7351B  ld DE,QHL3
	ldto_berp	a, 0x3c	; F7351E  ld A,RL3
	jr	c, sub_F734FB_Skip2	; F73521  jr C,0xf73559
	ld	xix, 6305024	; F73523  ld XIX,0x00603500
	bit	7, (xix+hl)	; F73528  bit 7,(XIX+HL)
	jr	z, sub_F734FB_Skip2	; F7352D  jr Z,0xf73559
	ld	xix, 6305024	; F7352F  ld XIX,0x00603500
	lda	xix, (xix+hl)	; F73534  lda XIX,XIX+HL
	ld	wa, (xix+1)	; F73539  ld WA,(XIX+0x01)
	ld	iy, bc	; F7353C  ld IY,BC
	ld	xix, 13408	; F7353E  ld XIX,0x00003460
	sla	iy, 1	; F73543  sla 0x01,IY
	ld	(xix+iy), wa	; F73546  ld (XIX+IY),WA
	srl	iy, 1	; F7354B  srl 0x01,IY
	ld	xix, 13442	; F7354E  ld XIX,0x00003482
	ld	(xix+iy), 0x05	; F73553  ld (XIX+IY),0x05
sub_F734FB_Skip2:
	inc	1, c	; F73559  inc 1,C
	add	hl, 3	; F7355B  add HL,0x0003
	cp	c, 16	; F7355F  cp C,0x10
	jr	ule, sub_F734FB_Entry	; F73562  jr ULE,0xf73500
	pop	xix	; F73564  pop XIX
	ret	; F73565  ret

; --------------------------------------------------------------------------
; Smf_AllocFirstBlockForAllTracks_B
; Called from: in-module: 0xF72F8D
; Touches: (0x126E) (0x349F) (0x3608)  |  0x603500
; Calls:   T_BStore_AllocBlock_Veneer SongStore_SeekBlock_Copy
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF73566 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Smf_AllocFirstBlockForAllTracks_B: For directory entries 0..16 ((0x349F) counting), while at least 17 blocks are
;   free: allocates a block (T_BStore_AllocBlock_Veneer), marks it used with no links (+1 := 0, +3 := 0xFFFF), sets
;   the entry's in-use bit and head, and points its song position (0x3460 / 0x3482) at offset 5. Second copy of
;   Smf_AllocFirstBlockForAllTracks (only push widths and the head store differ); Smf_SplitTrack1ByChannel runs it
;   after resetting the 17 entries. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_z.json)
Smf_AllocFirstBlockForAllTracks_B:
	xor	iy, iy	; F73566  xor IY,IY
	xor	ix, ix	; F73568  xor IX,IX
	ld	(13471:16), 0	; F7356A  ld (0x349f),0x00
Smf_AllocFirstBlockForAllTracks_B_Loop:
	cpw	(BStore_FreeCount:24), 0x0011	; F7356F  cp (0x6034ba),0x0011
	jrl	c, Smf_AllocFirstBlockForAllTracks_B_Return	; F73576  jrl C,0xf735f6
	pushw	iy	; F73579  push IY
	pushw	ix	; F7357A  push IX
	call	T_BStore_AllocBlock_Veneer	; F7357B  call 0xf42884
	ld	wa, ix	; F7357F  ld WA,IX
	popw	ix	; F73581  pop IX
	popw	iy	; F73582  pop IY
	ld	bc, (BStore_BlockCount:16)	; F73583  ld BC,(0x3608)
	cp	wa, bc	; F73587  cp WA,BC
	jr	ugt, Smf_AllocFirstBlockForAllTracks_B_Return	; F73589  jr UGT,0xf735f6
	cp	wa, 0:i3	; F7358B  cp WA,0
	jr	z, Smf_AllocFirstBlockForAllTracks_B_Return	; F7358D  jr Z,0xf735f6
	pushw	wa	; F7358F  push WA
	ld	hl, wa	; F73590  ld HL,WA
	calr	SongStore_SeekBlock_Copy	; F73592  calr 0xf72f0a
	ld	xhl, (BStore_CursorBlockAddr:16)	; F73595  ld XHL,(0x126e)
	or	(xhl), 0x80	; F73599  or (XHL),0x80
	ldw	(xhl+1), 0x0000	; F7359C  ld (XHL+0x01),0x0000
	ldw	(xhl+3), 0xffff	; F735A1  ld (XHL+0x03),0xffff
	popw	wa	; F735A6  pop WA
	ld	xhl, 6305024	; F735A7  ld XHL,0x00603500
	or	(xhl+iy), 0x80	; F735AC  or (XHL+IY),0x80
	ldfr_lerp	xhl, 0x38	; F735B2  ld XDE3,XHL
	lda	xhl, (xhl+iy)	; F735B5  lda XHL,XHL+IY
	ld	(xhl+1), wa	; F735BA  ld (XHL+0x01),WA
	ldto_lerp	xhl, 0x38	; F735BD  ld XHL,XDE3
	ld	xhl, 13408	; F735C0  ld XHL,0x00003460
	ld	(xhl+ix), wa	; F735C5  ld (XHL+IX),WA
	ld	xhl, 13442	; F735CA  ld XHL,0x00003482
	xor	bc, bc	; F735CF  xor BC,BC
	ld	c, (13471:16)	; F735D1  ld C,(0x349f)
	pushw	iy	; F735D5  push IY
	ld	iy, bc	; F735D6  ld IY,BC
	ldw	(xhl+iy), 0x0005	; F735D8  ld (XHL+IY),0x0005
	popw	iy	; F735DF  pop IY
	add	iy, 3	; F735E0  add IY,0x0003
	add	ix, 2	; F735E4  add IX,0x0002
	inc	1, (13471:16)	; F735E8  inc 1,(0x349f)
	cp	(0x349f:16), 0x11	; F735EC  cp (0x349f),0x11
	jrl	c, Smf_AllocFirstBlockForAllTracks_B_Loop	; F735F1  jrl C,0xf7356f
	jr	Smf_AllocFirstBlockForAllTracks_B_Return	; F735F4  jr T,0xf735f6
Smf_AllocFirstBlockForAllTracks_B_Return:
	ret	; F735F6  ret

; --------------------------------------------------------------------------
; sub_F735F7
; Called from: in-module: 0xF739BF
; Touches: (0x0C70) (0x360C) (0x360E)  |  0x603422 0x603500
; Calls:   sub_F73664 T_F40A04
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF735F7 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F735F7:
	xor	xhl, xhl	; F735F7  xor XHL,XHL
	xor	bc, bc	; F735F9  xor BC,BC
sub_F735F7_Entry:
	ldfr_berp	a, 0x3c	; F735FB  ld RL3,A
	ldfr_werp	de, 0x3e	; F735FE  ld QHL3,DE
	ld	de, (13836:16)	; F73601  ld DE,(0x360c)
	ld	a, c	; F73605  ld A,C
	cp	a, 16	; F73607  cp A,0x10
	jr	lt, sub_F735F7_Skip	; F7360A  jr LT,0xf73613
	ld	de, (13838:16)	; F7360C  ld DE,(0x360e)
	sub	a, 16	; F73610  sub A,0x10
sub_F735F7_Skip:
	scf	; F73613  scf
	xorcf_a_16	de	; F73614  xorcf A,DE
	ldto_werp	de, 0x3e	; F73616  ld DE,QHL3
	ldto_berp	a, 0x3c	; F73619  ld A,RL3
	jr	c, sub_F735F7_Skip2	; F7361C  jr C,0xf73649
	push	xde	; F7361E  push XDE
	ld	xde, 6305024	; F7361F  ld XDE,0x00603500
	bit	7, (xde+hl)	; F73624  bit 7,(XDE+HL)
	pop	xde	; F73629  pop XDE
	jr	z, sub_F735F7_Skip2	; F7362A  jr Z,0xf73649
	xor	b, b	; F7362C  xor B,B
	ld	iy, bc	; F7362E  ld IY,BC
	push	xix	; F73630  push XIX
	ld	xix, BStore_TrackToPart	; F73631  ld XIX,0x00603422
	ld	a, (xix+iy)	; F73636  ld A,(XIX+IY)
	pop	xix	; F7363B  pop XIX
	ld	(3184:16), c	; F7363C  ld (0x0c70),C
	push	xhl	; F73640  push XHL
	pushw	bc	; F73641  push BC
	calr	sub_F73664	; F73642  calr 0xf73664
	popw	bc	; F73645  pop BC
	pop	xhl	; F73646  pop XHL
	jr	sub_F735F7_Join	; F73647  jr T,0xf73659
sub_F735F7_Skip2:
	ld	(3184:16), c	; F73649  ld (0x0c70),C
	inc	1, (3184:16)	; F7364D  inc 1,(0x0c70)
	push	xhl	; F73651  push XHL
	pushw	bc	; F73652  push BC
	call	T_F40A04	; F73653  call 0xf40a04
	popw	bc	; F73657  pop BC
	pop	xhl	; F73658  pop XHL
sub_F735F7_Join:
	add	l, 3	; F73659  add L,0x03
	inc	1, c	; F7365C  inc 1,C
	cp	c, 16	; F7365E  cp C,0x10
	jr	ule, sub_F735F7_Entry	; F73661  jr ULE,0xf735fb
	ret	; F73663  ret

; --------------------------------------------------------------------------
; sub_F73664
; Called from: in-module: 0xF73642
; Touches: (0x10CA) (0x1239) (0x124D) (0x1258) (0x125B) (0x345C) (0x345E)
;          (0x7F4D)  |  0x603500
; Calls:   SmfWrite_ReadSongByte BStore_WriteCursorByteNoSave sub_F73818 SmfWrite_AdvanceSongCursor
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF73664 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F73664:
	cp	c, 16	; F73664  cp C,0x10
	jr	nz, sub_F73664_Skip	; F73667  jr NZ,0xf7366b
	ld	c, 7:opc	; F73669  ld C,0x07
sub_F73664_Skip:
	ld	(4298:16), c	; F7366B  ld (0x10ca),C
	xor	b, b	; F7366F  xor B,B
	ld	iy, bc	; F73671  ld IY,BC
	and	(0x124d:16), 0xfe	; F73673  and (0x124d),0xfe
	ld	(4665:16), 0	; F73678  ld (0x1239),0x00
	bit	2, (0x7f4d:16)	; F7367D  bit 2,(0x7f4d)
	jr	z, sub_F73664_Skip2	; F73681  jr Z,0xf73688
	ld	(4665:16), 255	; F73683  ld (0x1239),0xff
sub_F73664_Skip2:
	inc	1, hl	; F73688  inc 1,HL
	push	xde	; F7368A  push XDE
	ld	xde, 6305024	; F7368B  ld XDE,0x00603500
	ld	hl, (xde+hl)	; F73690  ld HL,(XDE+HL)
	pop	xde	; F73695  pop XDE
	ld	(BStore_CursorBlock:16), hl	; F73696  ld (0x345c),HL
	ldw	(BStore_CursorOffset:16), 5	; F7369A  ld (0x345e),0x0005
	calr	SmfWrite_ReadSongByte	; F736A0  calr 0xf74e71
sub_F73664_Join:
	ld	(SongEvent_Byte0:16), a	; F736A3  ld (0x1258),A
	cp	a, 130	; F736A7  cp A,0x82
	jrl	z, sub_F73664_Return	; F736AA  jrl Z,0xf737ea
	cp	a, 132	; F736AD  cp A,0x84
	jr	z, sub_F73664_Skip3	; F736B0  jr Z,0xf736e1
	cp	a, 208	; F736B2  cp A,0xd0
	jr	z, sub_F73664_Skip4	; F736B5  jr Z,0xf736e9
	cp	a, 209	; F736B7  cp A,0xd1
	jr	z, sub_F73664_Skip5	; F736BA  jr Z,0xf736ed
	cp	a, 210	; F736BC  cp A,0xd2
	jr	z, sub_F73664_Skip6	; F736BF  jr Z,0xf736f1
	cp	a, 211	; F736C1  cp A,0xd3
	jr	z, sub_F73664_Skip7	; F736C4  jr Z,0xf736f5
	cp	a, 128	; F736C6  cp A,0x80
	jr	z, sub_F73664_Skip8	; F736C9  jr Z,0xf736f9
	and	a, 240	; F736CB  and A,0xf0
	cp	a, 144	; F736CE  cp A,0x90
	jr	z, sub_F73664_Skip9	; F736D1  jr Z,0xf736fd
	cp	a, 176	; F736D3  cp A,0xb0
	jrl	z, sub_F73664_Skip11	; F736D6  jrl Z,0xf7374c
	cp	a, 192	; F736D9  cp A,0xc0
	jr	z, sub_F73664_Skip10	; F736DC  jr Z,0xf73724
	jrl	sub_F73664_Loop2	; F736DE  jrl T,0xf737dc
sub_F73664_Skip3:
	ld	a, 130:opc	; F736E1  ld A,0x82
	calr	BStore_WriteCursorByteNoSave	; F736E3  calr 0xf73827
	jrl	sub_F73664_Return	; F736E6  jrl T,0xf737ea
sub_F73664_Skip4:
	ld	a, 160:opc	; F736E9  ld A,0xa0
	jr	sub_F73664_Join2	; F736EB  jr T,0xf736ff
sub_F73664_Skip5:
	ld	a, 208:opc	; F736ED  ld A,0xd0
	jr	sub_F73664_Join2	; F736EF  jr T,0xf736ff
sub_F73664_Skip6:
	ld	a, 224:opc	; F736F1  ld A,0xe0
	jr	sub_F73664_Join2	; F736F3  jr T,0xf736ff
sub_F73664_Skip7:
	ld	a, 240:opc	; F736F5  ld A,0xf0
	jr	sub_F73664_Join2	; F736F7  jr T,0xf736ff
sub_F73664_Skip8:
	ld	a, 160:opc	; F736F9  ld A,0xa0
	jr	sub_F73664_Join2	; F736FB  jr T,0xf736ff
sub_F73664_Skip9:
	ld	a, 144:opc	; F736FD  ld A,0x90
sub_F73664_Join2:
	or	a, (4298:16)	; F736FF  or A,(0x10ca)
	pushw	wa	; F73703  push WA
	calr	BStore_WriteCursorByteNoSave	; F73704  calr 0xf73827
	popw	wa	; F73707  pop WA
	and	a, 240	; F73708  and A,0xf0
	cp	a, 144	; F7370B  cp A,0x90
	jrl	nz, sub_F73664_Loop2	; F7370E  jrl NZ,0xf737dc
	cp	(0x1239:16), 0x00	; F73711  cp (0x1239),0x00
	jrl	z, sub_F73664_Loop2	; F73716  jrl Z,0xf737dc
	cp	(0x10ca:16), 0x09	; F73719  cp (0x10ca),0x09
	jrl	nz, sub_F73664_Loop2	; F7371E  jrl NZ,0xf737dc
	jrl	sub_F73664_Loop2	; F73721  jrl T,0xf737dc
sub_F73664_Skip10:
	calr	sub_F73818	; F73724  calr 0xf73818
	pushw	(BStore_CursorBlock:16)	; F73727  pushw (0x345c)
	pushw	(BStore_CursorOffset:16)	; F7372B  pushw (0x345e)
	calr	SmfWrite_AdvanceSongCursor	; F7372F  calr 0xf74e86
	calr	SmfWrite_ReadSongByte	; F73732  calr 0xf74e71
	popw	(BStore_CursorOffset:16)	; F73735  popw (0x345e)
	popw	(BStore_CursorBlock:16)	; F73739  popw (0x345c)
	cp	a, 0:i3	; F7373D  cp A,0
	jrl	nz, sub_F73664_Loop2	; F7373F  jrl NZ,0xf737dc
	ld	a, (4298:16)	; F73742  ld A,(0x10ca)
	calr	BStore_WriteCursorByteNoSave	; F73746  calr 0xf73827
	jrl	sub_F73664_Loop2	; F73749  jrl T,0xf737dc
sub_F73664_Skip11:
	calr	sub_F73818	; F7374C  calr 0xf73818
	pushw	(BStore_CursorBlock:16)	; F7374F  pushw (0x345c)
	pushw	(BStore_CursorOffset:16)	; F73753  pushw (0x345e)
	calr	SmfWrite_AdvanceSongCursor	; F73757  calr 0xf74e86
	calr	SmfWrite_ReadSongByte	; F7375A  calr 0xf74e71
	popw	(BStore_CursorOffset:16)	; F7375D  popw (0x345e)
	popw	(BStore_CursorBlock:16)	; F73761  popw (0x345c)
	ld	l, a	; F73765  ld L,A
	push	xhl	; F73767  push XHL
	calr	SmfWrite_ReadSongByte	; F73768  calr 0xf74e71
	pop	xhl	; F7376B  pop XHL
	ld	(4699:16), a	; F7376C  ld (0x125b),A
	ld	w, (SongEvent_Byte0:16)	; F73770  ld W,(0x1258)
	and	w, 4	; F73774  and W,0x04
	sla	w, 5	; F73777  sla 0x05,W
	or	a, w	; F7377A  or A,W
	ld	(4699:16), a	; F7377C  ld (0x125b),A
	cp	a, 181	; F73780  cp A,0xb5
	jr	z, sub_F73664_Skip12	; F73783  jr Z,0xf737a5
	cp	a, 188	; F73785  cp A,0xbc
	jr	z, sub_F73664_Skip12	; F73788  jr Z,0xf737a5
	cp	a, 189	; F7378A  cp A,0xbd
	jr	z, sub_F73664_Skip12	; F7378D  jr Z,0xf737a5
	cp	a, 184	; F7378F  cp A,0xb8
	jr	z, sub_F73664_Skip12	; F73792  jr Z,0xf737a5
	cp	a, 185	; F73794  cp A,0xb9
	jr	z, sub_F73664_Skip12	; F73797  jr Z,0xf737a5
	cp	a, 186	; F73799  cp A,0xba
	jr	z, sub_F73664_Skip12	; F7379C  jr Z,0xf737a5
	cp	a, 187	; F7379E  cp A,0xbb
	jr	z, sub_F73664_Skip12	; F737A1  jr Z,0xf737a5
	jr	sub_F73664_Join4	; F737A3  jr T,0xf737bd
sub_F73664_Skip12:
	push	xhl	; F737A5  push XHL
	calr	SmfWrite_AdvanceSongCursor	; F737A6  calr 0xf74e86
	calr	SmfWrite_ReadSongByte	; F737A9  calr 0xf74e71
	pop	xhl	; F737AC  pop XHL
	ld	c, (4298:16)	; F737AD  ld C,(0x10ca)
	ld	a, (4298:16)	; F737B1  ld A,(0x10ca)
	jr	sub_F73664_Join3	; F737B5  jr T,0xf737b7
sub_F73664_Join3:
	calr	BStore_WriteCursorByteNoSave	; F737B7  calr 0xf73827
	jrl	sub_F73664_Loop2	; F737BA  jrl T,0xf737dc
sub_F73664_Join4:
	cp	a, 0:i3	; F737BD  cp A,0
	jr	c, sub_F73664_Skip13	; F737BF  jr C,0xf737d1
	cp	a, 31	; F737C1  cp A,0x1f
	jr	ugt, sub_F73664_Skip13	; F737C4  jr UGT,0xf737d1
	cp	l, 3:i3	; F737C6  cp L,3
	jr	c, sub_F73664_Skip13	; F737C8  jr C,0xf737d1
	cp	l, 11	; F737CA  cp L,0x0b
	jr	ugt, sub_F73664_Skip13	; F737CD  jr UGT,0xf737d1
	jr	sub_F73664_Loop	; F737CF  jr T,0xf737d5
sub_F73664_Skip13:
	ld	a, 127:opc	; F737D1  ld A,0x7f
	jr	sub_F73664_Join5	; F737D3  jr T,0xf737d9
sub_F73664_Loop:
	ld	a, (4298:16)	; F737D5  ld A,(0x10ca)
sub_F73664_Join5:
	calr	BStore_WriteCursorByteNoSave	; F737D9  calr 0xf73827
sub_F73664_Loop2:
	calr	SmfWrite_AdvanceSongCursor	; F737DC  calr 0xf74e86
	calr	SmfWrite_ReadSongByte	; F737DF  calr 0xf74e71
	bit	7, a	; F737E2  bit 0x07,A
	jr	z, sub_F73664_Loop2	; F737E5  jr Z,0xf737dc
	jrl	sub_F73664_Join	; F737E7  jrl T,0xf736a3
sub_F73664_Return:
	ret	; F737EA  ret
	cp	a, 80	; F737EB  cp A,0x50
	jr	z, sub_F73664_Skip14	; F737EE  jr Z,0xf737f5
	cp	a, 81	; F737F0  cp A,0x51
	jr	nz, sub_F73664_Loop	; F737F3  jr NZ,0xf737d5
sub_F73664_Skip14:
	jr	sub_F73664_Loop2	; F737F5  jr T,0xf737dc

; --------------------------------------------------------------------------
; ByteMap_F737F7 -- 32 bytes: a BYTE MAP.  0 of them are 0xFF and the other
;                   32 ASCEND STRICTLY, 0x00 to 0x1F, with jumps.  The name
;                   describes the CONTENT; what the two index spaces are is
;                   not established here.
; Read by: nothing in prom_a or prom_b spells this address as a 32-bit word,
;          so whatever reaches it computes the address
; Entry count: 32 bytes.  The run is trimmed of trailing 0xFF, so it claims
;              no padding it did not earn; the byte before it is 0xE5 and
;              the LAST byte of it is 0x1F.
; Evidence: every non-0xFF byte is compared with its predecessor on every
;           emit, WITHIN EACH of the 1 maximal ascending runs the rule
;           returns, and the runs are asserted to tile this segment exactly.
;           The BYTEMAP rule fires ZERO times over the proven prom_b
;           instruction text at (16 bytes, 12 values) and also at (20,14),
;           (24,16) and (16,16) (`python3 notes/prom_b_f6d002_layout.py
;           --null-ptr`).
; Unknown: what the two index spaces ARE, and who reads it.
; --------------------------------------------------------------------------
ByteMap_F737F7:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F737F7  [0..15]
	.byte	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F	; F73807  [16..31]

	ret	; F73817  ret

; --------------------------------------------------------------------------
; sub_F73818
; Called from: in-module: 0xF73724 0xF7374C
; Touches: nothing with an absolute address
; Calls:   SmfWrite_AdvanceSongCursor SmfWrite_ReadSongByte
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF73818 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F73818:
	ldw	bc, 2	; F73818  ld BC,0x0002
	pushw	bc	; F7381B  push BC
	calr	SmfWrite_AdvanceSongCursor	; F7381C  calr 0xf74e86
	popw	bc	; F7381F  pop BC
	djnz16	bc, -8	; F73820  djnz BC,0xf7381b
	calr	SmfWrite_ReadSongByte	; F73823  calr 0xf74e71
	ret	; F73826  ret

; --------------------------------------------------------------------------
; BStore_WriteCursorByteNoSave
; Called from: in-module: 0xF736E3 0xF73704 0xF73746 0xF737B7 0xF737D9
; Touches: (0x345C) (0x345E) (0x3604)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF73827 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_WriteCursorByteNoSave: BStore_WriteCursorByte's work without saving XIX/WA: A to BStore_HeapBase + (BStore_CursorBlock - 1) * 0x100 +
;   BStore_CursorOffset; called from sub_F73664.  Basis: body, compared with BStore_WriteCursorByte.
BStore_WriteCursorByteNoSave:
	ld	hl, (BStore_CursorBlock:16)	; F73827  ld HL,(0x345c)
	extz	xhl	; F7382B  extz XHL
	dec	1, xhl	; F7382D  dec 1,XHL
	sla	xhl, 8	; F7382F  sla 0x08,XHL
	add	xhl, (BStore_HeapBase:16)	; F73832  add XHL,(0x3604)
	ld	iy, (BStore_CursorOffset:16)	; F73836  ld IY,(0x345e)
	ld	(xhl+iy), a	; F7383A  ld (XHL+IY),A
	ret	; F7383F  ret

; --------------------------------------------------------------------------
; Smf_WriteFile_Veneer
; Called from: in-module: 0xF6F465
; Touches: nothing with an absolute address
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF73840 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
Smf_WriteFile_Veneer:
	jp	Smf_WriteFile	; F73840  jp 0xf7385f

; --------------------------------------------------------------------------
; Data_F73844 -- 27 bytes this block could not split.  No content rule
;                framed it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or
;                ASCII -- and the code walk never reached it from a thunk
;                slot, a proven call site, an opcode-anchored call or an
;                entry of a table the firmware transfers to.  So it is
;                emitted as bytes rather than guessed.
; Contains: printable bytes |...~.......~...._ZZZZZZZSEQ|
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XIY,0x00f73844` at
;          0xF73AC9 (operand field 1 byte in)
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; Unknown: everything about it except its bytes.
; --------------------------------------------------------------------------
Data_F73844:
	.byte	0x00, 0xF0, 0x05, 0x7E, 0x7F, 0x09, 0x01, 0xF7, 0x00, 0xF0, 0x05, 0x7E, 0x7F, 0x09, 0x02, 0xF7	; F73844  [0..15]
	.byte	0x5F, 0x5A, 0x5A, 0x5A, 0x5A, 0x5A, 0x5A, 0x5A, 0x53, 0x45, 0x51	; F73854  [16..26]


; --------------------------------------------------------------------------
; Smf_WriteFile -- 0xF7385F
; Called from: in-module: 0xF73840
; Touches: (0x0C70) (0x107E) (0x1080) (0x1082) (0x1084) (0x1086) (0x1088)
;          (0x10C4) (0x10C6) (0x1193) +39 more  |  0x603422 0x603500
;          0x6036A0 0x60A480 0x60A700
; Calls:   MidiFileList_FindFileName MidiFileList_CheckSelectedEntryBlank T_MessageScreen_Paint T_Var2216_SetW145C_Call T_DiskProgress_PrintDotForSmf SmfWrite_SaveFileName
;          T_DiskSaveFile_Execute_Entry SmfWrite_RestoreFileName T_DiskApi_DeleteFile_Call sub_F735F7 SmfExport_MergeUsedTracksIntoFirst SmfWrite_ClearPendingNoteOffs +20
;          more
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF7385F is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.
; Name:    Smf_WriteFile -- named 2026-08-31.
; Extent:  0xF7385F-0xF74809, 4,011 bytes, ends `ret`.  Bracketed by the same
;          flag as Smf_ReadFile and by the OTHER of its only two brackets:
;          `or (0x21E8),0x80` at 0xF73875 and `and (0x21E8),0x7F` at 0xF747FA,
;          fifteen bytes before the `ret`, which is the last row before the next
;          label (RamPtrTable_F7480A).
; Evidence (FORMAT): it emits a Standard MIDI File out of the 32-byte template
;          SmfFileTemplate_F7493F -- `MThd`, length 6, format 0, one track,
;          division 96, `MTrk` -- copying the `MTrk` tag from template+0x0E at
;          0xF73A3A and the 11-byte track-name meta event `00 FF 03 0F WSA    `
;          from template+0x16 at 0xF73A5A, then EIGHT bytes from the filename
;          field at RAM (0x21C8) at 0xF73A64.  7 + 8 = 15 = the 0x0F the meta
;          event declares, so the two copies satisfy the ROM's own length byte.
; ⚠ CORRECTED 2026-08-31: this header used to end `Unknown: what the routine is
;          FOR.  Left as sub_XXXXXX with the gap stated`.
; Unknown: 4,011 bytes do much more than write a header.  The name claims the
;          FILE FORMAT it produces, not everything the routine does.
; --------------------------------------------------------------------------
Smf_WriteFile:
	ld	a, (Disk_ContentType:16)	; F7385F  ld A,(0x2725)
	pushw	wa	; F73863  push WA
	cpw	(BStore_Password:24), 0x0000	; F73864  cp (0x60341c),0x0000
	jr	z, Smf_WriteFile_Skip	; F7386B  jr Z,0xf73875
	ld	(UI_StatusCode:16), 9	; F7386D  ld (0x2880),0x09
	jrl	Smf_WriteFile_Join11	; F73872  jrl T,0xf747fa
Smf_WriteFile_Skip:
	or	(0x21e8:16), 0x80	; F73875  or (0x21e8),0x80
	xor	wa, wa	; F7387A  xor WA,WA
	ld	(4529:16), a	; F7387C  ld (0x11b1),A
	ld	(SmfOut_WindowsFlushed:16), wa	; F73880  ld (0x126c),WA
	ld	(4712:16), a	; F73884  ld (0x1268),A
	cpw	(0x360c:16), 0x0000	; F73888  cp (0x360c),0x0000
	jr	z, Smf_WriteFile_Skip4	; F7388E  jr Z,0xf738d8
	xor	c, c	; F73890  xor C,C
Smf_WriteFile_Loop:
	ld	de, (13836:16)	; F73892  ld DE,(0x360c)
	ld	a, c	; F73896  ld A,C
	cp	a, 16	; F73898  cp A,0x10
	jr	lt, Smf_WriteFile_Skip2	; F7389B  jr LT,0xf738a4
	ld	de, (13838:16)	; F7389D  ld DE,(0x360e)
	sub	a, 16	; F738A1  sub A,0x10
Smf_WriteFile_Skip2:
	scf	; F738A4  scf
	xorcf_a_16	de	; F738A5  xorcf A,DE
	jr	c, Smf_WriteFile_Skip3	; F738A7  jr C,0xf738d1
	ld	l, c	; F738A9  ld L,C
	xor	h, h	; F738AB  xor H,H
	push	xix	; F738AD  push XIX
	ld	xix, BStore_TrackToPart	; F738AE  ld XIX,0x00603422
	cp	(xix+hl), 0x20	; F738B3  cp (XIX+HL),0x20
	pop	xix	; F738B9  pop XIX
	jr	z, Smf_WriteFile_Skip3	; F738BA  jr Z,0xf738d1
	ld	a, l	; F738BC  ld A,L
	sla	l, 1	; F738BE  sla 0x01,L
	add	l, a	; F738C1  add L,A
	push	xde	; F738C3  push XDE
	ld	xde, 6305024	; F738C4  ld XDE,0x00603500
	bit	7, (xde+hl)	; F738C9  bit 7,(XDE+HL)
	pop	xde	; F738CE  pop XDE
	jr	nz, Smf_WriteFile_Skip5	; F738CF  jr NZ,0xf738e0
Smf_WriteFile_Skip3:
	inc	1, c	; F738D1  inc 1,C
	cp	c, 16	; F738D3  cp C,0x10
	jr	ule, Smf_WriteFile_Loop	; F738D6  jr ULE,0xf73892
Smf_WriteFile_Skip4:
	ld	(UI_StatusCode:16), 47	; F738D8  ld (0x2880),0x2f
	jrl	Smf_WriteFile_Join8	; F738DD  jrl T,0xf7478e
Smf_WriteFile_Skip5:
	cp	(UI_ScreenPage:16), 0x02	; F738E0  cp (0x2229),0x02
	jr	z, Smf_WriteFile_Join	; F738E5  jr Z,0xf738fa
	calr	MidiFileList_FindFileName	; F738E7  calr 0xf748ad
	cp	w, 0:i3	; F738EA  cp W,0
	jrl	nz, Smf_WriteFile_Skip58	; F738EC  jrl NZ,0xf747f5
	call	MidiFileList_CheckSelectedEntryBlank	; F738EF  call 0xf74885
	cp	a, 0:i3	; F738F3  cp A,0
	jrl	nz, Smf_WriteFile_Skip58	; F738F5  jrl NZ,0xf747f5
	jr	Smf_WriteFile_Join	; F738F8  jr T,0xf738fa
Smf_WriteFile_Join:
	ld	(UI_StatusCode:16), 39	; F738FA  ld (0x2880),0x27
	call	T_MessageScreen_Paint	; F738FF  call 0xf41600
	ldw	(4680:16), 1	; F73903  ld (0x1248),0x0001
	call	T_Var2216_SetW145C_Call	; F73909  call 0xf42600
	call	T_DiskProgress_PrintDotForSmf	; F7390D  call 0xf42604
	push	xix	; F73911  push XIX
	push	xiy	; F73912  push XIY
	push	xbc	; F73913  push XBC
	calr	SmfWrite_SaveFileName	; F73914  calr 0xf7492f
	pop	xbc	; F73917  pop XBC
	pop	xiy	; F73918  pop XIY
	pop	xix	; F73919  pop XIX
	ld	xiy, Data_F73844 + 0x10	; F7391A  ld XIY,0x00f73854
	ld	xix, Disk_FileName	; F7391F  ld XIX,0x000021c8
	ldw	bc, 11	; F73924  ld BC,0x000b
	ldir85	; F73927  ldir
	ld	(Disk_ContentType:16), 1	; F73929  ld (0x2725),0x01
	ld	l, (UI_ScreenPage:16)	; F7392E  ld L,(0x2229)
	pushw	hl	; F73932  push HL
	call	T_DiskSaveFile_Execute_Entry	; F73933  call 0xf425cc
	popw	hl	; F73937  pop HL
	ld	(UI_ScreenPage:16), l	; F73938  ld (0x2229),L
	calr	SmfWrite_RestoreFileName	; F7393C  calr 0xf7491f
	cp	(UI_StatusCode:16), 0x23	; F7393F  cp (0x2880),0x23
	jrl	nz, Smf_WriteFile_Join9	; F73944  jrl NZ,0xf74790
	ld	a, (Disk_SelectedEntry:16)	; F73947  ld A,(0x2724)
	exts	wa	; F7394B  exts WA
	cp	(UI_ScreenPage:16), 0x02	; F7394D  cp (0x2229),0x02
	jr	nz, Smf_WriteFile_Skip6	; F73952  jr NZ,0xf739a3
	ld	a, (Disk_SelectedEntry:16)	; F73954  ld A,(0x2724)
	exts	wa	; F73958  exts WA
	ld	xiy, 6333568	; F7395A  ld XIY,0x0060a480
	sla	wa, 3	; F7395F  sla 0x03,WA
	extz	xwa	; F73962  extz XWA
	add	xiy, xwa	; F73964  add XIY,XWA
	pushw	(Disk_FileName:16)	; F73966  pushw (0x21c8)
	pushw	(Disk_FileName+2:16)	; F7396A  pushw (0x21ca)
	pushw	(Disk_FileName+4:16)	; F7396E  pushw (0x21cc)
	pushw	(Disk_FileName+6:16)	; F73972  pushw (0x21ce)
	ld	xix, Disk_FileName	; F73976  ld XIX,0x000021c8
	ldw	bc, 4	; F7397B  ld BC,0x0004
	ldirw	; F7397E  ldirw
	ld	(Disk_FileName+8:16), 77	; F73980  ld (0x21d0),0x4d
	ld	(Disk_FileName+9:16), 73	; F73985  ld (0x21d1),0x49
	ld	(Disk_FileName+10:16), 68	; F7398A  ld (0x21d2),0x44
	call	T_DiskApi_DeleteFile_Call	; F7398F  call 0xf425b0
	popw	(Disk_FileName+6:16)	; F73993  popw (0x21ce)
	popw	(Disk_FileName+4:16)	; F73997  popw (0x21cc)
	popw	(Disk_FileName+2:16)	; F7399B  popw (0x21ca)
	popw	(Disk_FileName:16)	; F7399F  popw (0x21c8)
Smf_WriteFile_Skip6:
	ld	wa, (13836:16)	; F739A3  ld WA,(0x360c)
	ld	(4678:16), wa	; F739A7  ld (0x1246),WA
	ld	(4665:16), 255	; F739AB  ld (0x1239),0xff
	bit	2, (0x7f4d:16)	; F739B0  bit 2,(0x7f4d)
	jr	nz, Smf_WriteFile_Skip7	; F739B4  jr NZ,0xf739bb
	ld	(4665:16), 0	; F739B6  ld (0x1239),0x00
Smf_WriteFile_Skip7:
	call	T_DiskProgress_PrintDotForSmf	; F739BB  call 0xf42604
	call	sub_F735F7	; F739BF  call 0xf735f7
	call	SmfExport_MergeUsedTracksIntoFirst	; F739C3  call 0xf72918
	calr	SmfWrite_ClearPendingNoteOffs	; F739C7  calr 0xf74eae
	call	T_DiskProgress_PrintDotForSmf	; F739CA  call 0xf42604
	calr	SmfSize_Pass	; F739CE  calr 0xf75685
	calr	SmfWrite_ClearPendingNoteOffs	; F739D1  calr 0xf74eae
	xor	wa, wa	; F739D4  xor WA,WA
	ld	(SmfOut_WindowsFlushed:16), wa	; F739D6  ld (0x126c),WA
	ld	(4529:16), a	; F739DA  ld (0x11b1),A
	ld	(4712:16), a	; F739DE  ld (0x1268),A
	xor	hl, hl	; F739E2  xor HL,HL
	xor	bc, bc	; F739E4  xor BC,BC
Smf_WriteFile_Loop2:
	push	xde	; F739E6  push XDE
	ld	xde, 6305024	; F739E7  ld XDE,0x00603500
	bit	7, (xde+hl)	; F739EC  bit 7,(XDE+HL)
	pop	xde	; F739F1  pop XDE
	jr	nz, Smf_WriteFile_Skip8	; F739F2  jr NZ,0xf73a07
	add	hl, 3	; F739F4  add HL,0x0003
	inc	1, c	; F739F8  inc 1,C
	cp	c, 16	; F739FA  cp C,0x10
	jr	ule, Smf_WriteFile_Loop2	; F739FD  jr ULE,0xf739e6
	ld	(UI_StatusCode:16), 3	; F739FF  ld (0x2880),0x03
	jrl	Smf_WriteFile_Join9	; F73A04  jrl T,0xf74790
Smf_WriteFile_Skip8:
	ld	(3184:16), c	; F73A07  ld (0x0c70),C
	inc	1, hl	; F73A0B  inc 1,HL
	push	xde	; F73A0D  push XDE
	ld	xde, 6305024	; F73A0E  ld XDE,0x00603500
	ld	hl, (xde+hl)	; F73A13  ld HL,(XDE+HL)
	pop	xde	; F73A18  pop XDE
	ld	(BStore_CursorBlock:16), hl	; F73A19  ld (0x345c),HL
	ldw	(BStore_CursorOffset:16), 5	; F73A1D  ld (0x345e),0x0005
	ld	xiy, SmfFileTemplate_F7493F	; F73A23  ld XIY,0x00f7493f
	ld	xix, 6334208	; F73A28  ld XIX,0x0060a700
	ldw	bc, 7	; F73A2D  ld BC,0x0007
	ldirw	; F73A30  ldirw
	ld	xiy, SmfFileTemplate_F7493F + 0xE	; F73A32  ld XIY,0x00f7494d
	ldw	bc, 4	; F73A37  ld BC,0x0004
	ldir85	; F73A3A  ldir
	ld	wa, (SmfOut_TrackLength:16)	; F73A3C  ld WA,(0x10c4)
	ld	(xix+), wa	; F73A40  ld (XIX+),WA
	ld	wa, (SmfOut_TrackLength+2:16)	; F73A43  ld WA,(0x10c6)
	ld	(xix+), wa	; F73A47  ld (XIX+),WA
	ld	(InputStream_Cursor:16), xix	; F73A4A  ld (0x1088),XIX
	ld	xix, (InputStream_Cursor:16)	; F73A4E  ld XIX,(0x1088)
	ld	xiy, SmfFileTemplate_F7493F + 0x16	; F73A52  ld XIY,0x00f74955
	ldw	bc, 11	; F73A57  ld BC,0x000b
	ldir85	; F73A5A  ldir
	ld	xiy, Disk_FileName	; F73A5C  ld XIY,0x000021c8
	ldw	bc, 8	; F73A61  ld BC,0x0008
	ldir85	; F73A64  ldir
	ld	(InputStream_Cursor:16), xix	; F73A66  ld (0x1088),XIX
	ldw	(Smf_VlqBytes:16), 0	; F73A6A  ld (0x1193),0x0000
	ld	(4501:16), 0	; F73A70  ld (0x1195),0x00
	ld	xiy, Smf_VlqBytes	; F73A75  ld XIY,0x00001193
	ld	xix, (InputStream_Cursor:16)	; F73A7A  ld XIX,(0x1088)
Smf_WriteFile_Loop3:
	ld	a, (xiy+)	; F73A7E  ld A,(XIY+)
	ld	(xix+), a	; F73A81  ld (XIX+),A
	bit	7, a	; F73A84  bit 0x07,A
	jr	nz, Smf_WriteFile_Loop3	; F73A87  jr NZ,0xf73a7e
	ldw	wa, 22783	; F73A89  ld WA,0x58ff
	ld	(xix+), wa	; F73A8C  ld (XIX+),WA
	ld	a, 4:opc	; F73A8F  ld A,0x04
	ld	w, (6304983:24)	; F73A91  ld W,(0x6034d7)
	ld	(xix+), wa	; F73A96  ld (XIX+),WA
	ldw	wa, 6146	; F73A99  ld WA,0x1802
	ld	(xix+), wa	; F73A9C  ld (XIX+),WA
	ld	a, 8:opc	; F73A9F  ld A,0x08
	ld	(xix+), a	; F73AA1  ld (XIX+),A
	ld	(InputStream_Cursor:16), xix	; F73AA4  ld (0x1088),XIX
	ld	l, (32482:16)	; F73AA8  ld L,(0x7ee2)
	xor	h, h	; F73AAC  xor H,H
	pushw	bc	; F73AAE  push BC
	ld	b, (32483:16)	; F73AAF  ld B,(0x7ee3)
	and	b, 1	; F73AB3  and B,0x01
	xor	c, c	; F73AB6  xor C,C
	or	hl, bc	; F73AB8  or HL,BC
	popw	bc	; F73ABA  pop BC
	calr	SmfWrite_StageTempoFromBpm	; F73ABB  calr 0xf749a2
	calr	SmfWrite_WriteTempoEvent	; F73ABE  calr 0xf749c5
	cp	(0x1238:16), 0x03	; F73AC1  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73AC6  jrl NZ,0xf747dc
	ld	xiy, Data_F73844	; F73AC9  ld XIY,0x00f73844
	cp	(0x1239:16), 0x00	; F73ACE  cp (0x1239),0x00
	jr	nz, Smf_WriteFile_Skip9	; F73AD3  jr NZ,0xf73ada
	ld	xiy, Data_F73844 + 0x8	; F73AD5  ld XIY,0x00f7384c
Smf_WriteFile_Skip9:
	ld	xix, (InputStream_Cursor:16)	; F73ADA  ld XIX,(0x1088)
	ldw	bc, 8	; F73ADE  ld BC,0x0008
	ld	a, (xiy+)	; F73AE1  ld A,(XIY+)
	cp	bc, 8	; F73AE4  cp BC,0x0008
	jr	nz, Smf_WriteFile_Skip10	; F73AE8  jr NZ,0xf73af8
	bit	0, (0x133e:16)	; F73AEA  bit 0,(0x133e)
	jr	z, Smf_WriteFile_Skip10	; F73AEE  jr Z,0xf73af8
	bit	1, (0x133e:16)	; F73AF0  bit 1,(0x133e)
	jr	z, Smf_WriteFile_Skip10	; F73AF4  jr Z,0xf73af8
	ld	a, 32:opc	; F73AF6  ld A,0x20
Smf_WriteFile_Skip10:
	ld	(xix+), a	; F73AF8  ld (XIX+),A
	pushw	bc	; F73AFB  push BC
	push	xiy	; F73AFC  push XIY
	push	xix	; F73AFD  push XIX
	calr	SmfWrite_CommitOutputByte	; F73AFE  calr 0xf74b3a
	pop	xix	; F73B01  pop XIX
	pop	xiy	; F73B02  pop XIY
	popw	bc	; F73B03  pop BC
	ld	xix, (InputStream_Cursor:16)	; F73B04  ld XIX,(0x1088)
	cp	(0x1238:16), 0x03	; F73B08  cp (0x1238),0x03
	jr	z, Smf_WriteFile_Skip11	; F73B0D  jr Z,0xf73b12
	jrl	Smf_WriteFile_Join10	; F73B0F  jrl T,0xf747dc
Smf_WriteFile_Skip11:
	djnz16	bc, -52	; F73B12  djnz BC,0xf73ae1
	ld	(InputStream_Cursor:16), xix	; F73B15  ld (0x1088),XIX
	bit	0, (0x133e:16)	; F73B19  bit 0,(0x133e)
	jrl	z, Smf_WriteFile_Join4	; F73B1D  jrl Z,0xf73eb8
	call	T_BStore_Workspace_StoreParamImage	; F73B20  call 0xf42574
	calr	SmfExport_WriteParamSysEx	; F73B24  calr 0xf74ec5
	cp	(0x1238:16), 0x03	; F73B27  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73B2C  jrl NZ,0xf747dc
	ld	xix, (InputStream_Cursor:16)	; F73B2F  ld XIX,(0x1088)
	ld	(3184:16), 0	; F73B33  ld (0x0c70),0x00
Smf_WriteFile_Loop4:
	ld	xiy, 6305440	; F73B38  ld XIY,0x006036a0
	xor	xhl, xhl	; F73B3D  xor XHL,XHL
	ld	l, (3184:16)	; F73B3F  ld L,(0x0c70)
	ld	c, l	; F73B43  ld C,L
	ld	de, (4678:16)	; F73B45  ld DE,(0x1246)
	ld	a, c	; F73B49  ld A,C
	scf	; F73B4B  scf
	xorcf_a_16	de	; F73B4C  xorcf A,DE
	jrl	c, Smf_WriteFile_Skip13	; F73B4E  jrl C,0xf73eac
	push	xix	; F73B51  push XIX
	ld	xix, BStore_TrackToPart	; F73B52  ld XIX,0x00603422
	ld	l, (xix+hl)	; F73B57  ld L,(XIX+HL)
	pop	xix	; F73B5C  pop XIX
	ld	b, l	; F73B5D  ld B,L
	sla	l, 1	; F73B5F  sla 0x01,L
	push	xix	; F73B62  push XIX
	ld	xix, SmfPartOffsets_F74960	; F73B63  ld XIX,0x00f74960
	ld	hl, (xix+hl)	; F73B68  ld HL,(XIX+HL)
	pop	xix	; F73B6D  pop XIX
	cp	hl, 65535	; F73B6E  cp HL,0xffff
	jrl	z, Smf_WriteFile_Skip13	; F73B72  jrl Z,0xf73eac
	cp	c, 0:i3	; F73B75  cp C,0
	jr	z, Smf_WriteFile_Join2	; F73B77  jr Z,0xf73b87
	push	xhl	; F73B79  push XHL
	xor	hl, hl	; F73B7A  xor HL,HL
Smf_WriteFile_Loop5:
	pop	xhl	; F73B7C  pop XHL
	jr	Smf_WriteFile_Join2	; F73B7D  jr T,0xf73b87
	cp	l, c	; F73B7F  cp L,C
	jr	z, Smf_WriteFile_Loop5	; F73B81  jr Z,0xf73b7c
	pop	xhl	; F73B83  pop XHL
	jrl	Smf_WriteFile_Join4	; F73B84  jrl T,0xf73eb8
Smf_WriteFile_Join2:
	add	xiy, xhl	; F73B87  add XIY,XHL
	ld	c, (xiy+2)	; F73B89  ld C,(XIY+0x02)
	ld	d, (xiy+3)	; F73B8C  ld D,(XIY+0x03)
	ld	b, (xiy+5)	; F73B8F  ld B,(XIY+0x05)
	ld	e, (xiy+6)	; F73B92  ld E,(XIY+0x06)
	ld	a, (xiy+7)	; F73B95  ld A,(XIY+0x07)
	ld	(4763:16), a	; F73B98  ld (0x129b),A
	ld	a, (xiy+8)	; F73B9C  ld A,(XIY+0x08)
	ld	(4944:16), a	; F73B9F  ld (0x1350),A
	ld	a, (xiy+9)	; F73BA3  ld A,(XIY+0x09)
	ld	(4686:16), a	; F73BA6  ld (0x124e),A
	and	(0x0c70:16), 0x0f	; F73BAA  and (0x0c70),0x0f
	ld	l, (3184:16)	; F73BAF  ld L,(0x0c70)
	xor	h, h	; F73BB3  xor H,H
	push	xix	; F73BB5  push XIX
	ld	xix, BStore_TrackToPart	; F73BB6  ld XIX,0x00603422
	ld	l, (xix+hl)	; F73BBB  ld L,(XIX+HL)
	pop	xix	; F73BC0  pop XIX
	cp	(0x1239:16), 0xff	; F73BC1  cp (0x1239),0xff
	jr	nz, Smf_WriteFile_Skip12	; F73BC6  jr NZ,0xf73c3e
	ld	a, (3184:16)	; F73BC8  ld A,(0x0c70)
	ld	l, c	; F73BCC  ld L,C
	ld	(SoundConv_Arg0:24), l	; F73BCE  ld (0x60f010),L
	ld	(SoundConv_Arg1:24), d	; F73BD3  ld (0x60f011),D
	ld	l, (xiy)	; F73BD8  ld L,(XIY)
	ld	(SoundConv_Arg2:24), l	; F73BDA  ld (0x60f012),L
	pushw	bc	; F73BDF  push BC
	pushw	de	; F73BE0  push DE
	call	T_PartSound_ToProgramChange	; F73BE1  call 0xf41008
	popw	de	; F73BE5  pop DE
	popw	bc	; F73BE6  pop BC
	ld	a, (3184:16)	; F73BE7  ld A,(0x0c70)
	or	a, 176	; F73BEB  or A,0xb0
	xor	w, w	; F73BEE  xor W,W
	ld	l, (SoundConv_Result1:24)	; F73BF0  ld L,(0x60f015)
	pushw	wa	; F73BF5  push WA
	pushw	bc	; F73BF6  push BC
	pushw	de	; F73BF7  push DE
	call	SmfWrite_WriteChannelEvent	; F73BF8  call 0xf74ac5
	popw	de	; F73BFC  pop DE
	popw	bc	; F73BFD  pop BC
	popw	wa	; F73BFE  pop WA
	cp	(0x1238:16), 0x03	; F73BFF  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73C04  jrl NZ,0xf747dc
	ld	w, 32:opc	; F73C07  ld W,0x20
	ld	l, (SoundConv_Result0:24)	; F73C09  ld L,(0x60f014)
	pushw	bc	; F73C0E  push BC
	pushw	de	; F73C0F  push DE
	call	SmfWrite_WriteChannelEvent	; F73C10  call 0xf74ac5
	popw	de	; F73C14  pop DE
	popw	bc	; F73C15  pop BC
	cp	(0x1238:16), 0x03	; F73C16  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73C1B  jrl NZ,0xf747dc
	ld	a, (3184:16)	; F73C1E  ld A,(0x0c70)
	or	a, 192	; F73C22  or A,0xc0
	ld	w, (SoundConv_Result2:24)	; F73C25  ld W,(0x60f016)
	and	w, 127	; F73C2A  and W,0x7f
	pushw	bc	; F73C2D  push BC
	pushw	de	; F73C2E  push DE
	calr	SmfWrite_WriteChannelEvent	; F73C2F  calr 0xf74ac5
	popw	de	; F73C32  pop DE
	popw	bc	; F73C33  pop BC
	cp	(0x1238:16), 0x03	; F73C34  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73C39  jrl NZ,0xf747dc
	jr	Smf_WriteFile_Join3	; F73C3C  jr T,0xf73c99
Smf_WriteFile_Skip12:
	ld	a, (3184:16)	; F73C3E  ld A,(0x0c70)
	or	a, 176	; F73C42  or A,0xb0
	ld	w, 0:opc	; F73C45  ld W,0x00
	ld	l, d	; F73C47  ld L,D
	and	l, 56	; F73C49  and L,0x38
	srl	l, 3	; F73C4C  srl 0x03,L
	pushw	bc	; F73C4F  push BC
	pushw	de	; F73C50  push DE
	calr	SmfWrite_WriteChannelEvent	; F73C51  calr 0xf74ac5
	popw	de	; F73C54  pop DE
	popw	bc	; F73C55  pop BC
	cp	(0x1238:16), 0x03	; F73C56  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73C5B  jrl NZ,0xf747dc
	ld	a, (3184:16)	; F73C5E  ld A,(0x0c70)
	or	a, 176	; F73C62  or A,0xb0
	ld	w, 32:opc	; F73C65  ld W,0x20
	ld	l, d	; F73C67  ld L,D
	and	l, 7	; F73C69  and L,0x07
	sla	l, 4	; F73C6C  sla 0x04,L
	pushw	bc	; F73C6F  push BC
	pushw	de	; F73C70  push DE
	calr	SmfWrite_WriteChannelEvent	; F73C71  calr 0xf74ac5
	popw	de	; F73C74  pop DE
	popw	bc	; F73C75  pop BC
	cp	(0x1238:16), 0x03	; F73C76  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73C7B  jrl NZ,0xf747dc
	ld	a, (3184:16)	; F73C7E  ld A,(0x0c70)
	or	a, 192	; F73C82  or A,0xc0
	ld	w, c	; F73C85  ld W,C
	and	w, 127	; F73C87  and W,0x7f
	pushw	bc	; F73C8A  push BC
	pushw	de	; F73C8B  push DE
	calr	SmfWrite_WriteChannelEvent	; F73C8C  calr 0xf74ac5
	popw	de	; F73C8F  pop DE
	popw	bc	; F73C90  pop BC
	cp	(0x1238:16), 0x03	; F73C91  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73C96  jrl NZ,0xf747dc
Smf_WriteFile_Join3:
	ld	a, (3184:16)	; F73C99  ld A,(0x0c70)
	or	a, 176	; F73C9D  or A,0xb0
	ld	w, 7:opc	; F73CA0  ld W,0x07
	ld	l, b	; F73CA2  ld L,B
	pushw	wa	; F73CA4  push WA
	pushw	de	; F73CA5  push DE
	calr	SmfWrite_WriteChannelEvent	; F73CA6  calr 0xf74ac5
	popw	de	; F73CA9  pop DE
	popw	wa	; F73CAA  pop WA
	cp	(0x1238:16), 0x03	; F73CAB  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73CB0  jrl NZ,0xf747dc
	ld	w, 93:opc	; F73CB3  ld W,0x5d
	ld	l, (4763:16)	; F73CB5  ld L,(0x129b)
	pushw	wa	; F73CB9  push WA
	pushw	de	; F73CBA  push DE
	calr	SmfWrite_WriteChannelEvent	; F73CBB  calr 0xf74ac5
	popw	de	; F73CBE  pop DE
	popw	wa	; F73CBF  pop WA
	cp	(0x1238:16), 0x03	; F73CC0  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73CC5  jrl NZ,0xf747dc
	ld	w, 94:opc	; F73CC8  ld W,0x5e
	ld	l, (4944:16)	; F73CCA  ld L,(0x1350)
	pushw	wa	; F73CCE  push WA
	pushw	de	; F73CCF  push DE
	calr	SmfWrite_WriteChannelEvent	; F73CD0  calr 0xf74ac5
	popw	de	; F73CD3  pop DE
	popw	wa	; F73CD4  pop WA
	cp	(0x1238:16), 0x03	; F73CD5  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73CDA  jrl NZ,0xf747dc
	ld	w, 91:opc	; F73CDD  ld W,0x5b
	ld	l, (4686:16)	; F73CDF  ld L,(0x124e)
	and	l, 127	; F73CE3  and L,0x7f
	pushw	wa	; F73CE6  push WA
	calr	SmfWrite_WriteChannelEvent	; F73CE7  calr 0xf74ac5
	popw	wa	; F73CEA  pop WA
	cp	(0x1238:16), 0x03	; F73CEB  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73CF0  jrl NZ,0xf747dc
	ld	l, (3184:16)	; F73CF3  ld L,(0x0c70)
	xor	h, h	; F73CF7  xor H,H
	push	xix	; F73CF9  push XIX
	ld	xix, BStore_TrackToPart	; F73CFA  ld XIX,0x00603422
	ld	l, (xix+hl)	; F73CFF  ld L,(XIX+HL)
	pop	xix	; F73D04  pop XIX
	ld	b, l	; F73D05  ld B,L
	xor	h, h	; F73D07  xor H,H
	sla	l, 1	; F73D09  sla 0x01,L
	push	xix	; F73D0C  push XIX
	ld	xix, SmfPartOffsets_F74960	; F73D0D  ld XIX,0x00f74960
	ld	hl, (xix+hl)	; F73D12  ld HL,(XIX+HL)
	pop	xix	; F73D17  pop XIX
	cp	hl, 65535	; F73D18  cp HL,0xffff
	jrl	z, Smf_WriteFile_Skip13	; F73D1C  jrl Z,0xf73eac
	ld	a, (3184:16)	; F73D1F  ld A,(0x0c70)
	or	a, 176	; F73D23  or A,0xb0
	ld	c, l	; F73D26  ld C,L
	ld	xiy, 6305440	; F73D28  ld XIY,0x006036a0
	ldfr_lerp	xiy, 0x38	; F73D2D  ld XDE3,XIY
	lda	xiy, (xiy+hl)	; F73D30  lda XIY,XIY+HL
	ld	l, (xiy+10)	; F73D35  ld L,(XIY+0x0a)
	ldto_lerp	xiy, 0x38	; F73D38  ld XIY,XDE3
	ld	w, 10:opc	; F73D3B  ld W,0x0a
	pushw	wa	; F73D3D  push WA
	pushw	bc	; F73D3E  push BC
	calr	SmfWrite_WriteChannelEvent	; F73D3F  calr 0xf74ac5
	popw	bc	; F73D42  pop BC
	popw	wa	; F73D43  pop WA
	cp	(0x1238:16), 0x03	; F73D44  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73D49  jrl NZ,0xf747dc
	ld	w, 101:opc	; F73D4C  ld W,0x65
	ld	l, 0:opc	; F73D4E  ld L,0x00
	pushw	wa	; F73D50  push WA
	calr	SmfWrite_WriteChannelEvent	; F73D51  calr 0xf74ac5
	popw	wa	; F73D54  pop WA
	cp	(0x1238:16), 0x03	; F73D55  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73D5A  jrl NZ,0xf747dc
	ld	w, 100:opc	; F73D5D  ld W,0x64
	ld	l, 1:opc	; F73D5F  ld L,0x01
	pushw	wa	; F73D61  push WA
	calr	SmfWrite_WriteChannelEvent	; F73D62  calr 0xf74ac5
	popw	wa	; F73D65  pop WA
	cp	(0x1238:16), 0x03	; F73D66  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73D6B  jrl NZ,0xf747dc
	ld	l, (3184:16)	; F73D6E  ld L,(0x0c70)
	xor	h, h	; F73D72  xor H,H
	push	xix	; F73D74  push XIX
	ld	xix, BStore_TrackToPart	; F73D75  ld XIX,0x00603422
	ld	l, (xix+hl)	; F73D7A  ld L,(XIX+HL)
	sla	hl, 1	; F73D7F  sla 0x01,HL
	ld	xix, SmfPartOffsets_F74960	; F73D82  ld XIX,0x00f74960
	ld	hl, (xix+hl)	; F73D87  ld HL,(XIX+HL)
	pop	xix	; F73D8C  pop XIX
	ld	xiy, 6305440	; F73D8D  ld XIY,0x006036a0
	lda	xiy, (xiy+hl)	; F73D92  lda XIY,XIY+HL
	ld	l, (xiy+12)	; F73D97  ld L,(XIY+0x0c)
	ld	c, l	; F73D9A  ld C,L
	srl	l, 1	; F73D9C  srl 0x01,L
	and	l, 127	; F73D9F  and L,0x7f
	ld	w, 6:opc	; F73DA2  ld W,0x06
	pushw	wa	; F73DA4  push WA
	pushw	bc	; F73DA5  push BC
	calr	SmfWrite_WriteChannelEvent	; F73DA6  calr 0xf74ac5
	popw	bc	; F73DA9  pop BC
	popw	wa	; F73DAA  pop WA
	cp	(0x1238:16), 0x03	; F73DAB  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73DB0  jrl NZ,0xf747dc
	ld	l, c	; F73DB3  ld L,C
	and	l, 1	; F73DB5  and L,0x01
	.byte 0xCF, 0xE9, 0x02	; F73DB8  rrc 0x02,L   [llvm-mc cannot encode this]
	ld	w, 38:opc	; F73DBB  ld W,0x26
	pushw	wa	; F73DBD  push WA
	calr	SmfWrite_WriteChannelEvent	; F73DBE  calr 0xf74ac5
	popw	wa	; F73DC1  pop WA
	cp	(0x1238:16), 0x03	; F73DC2  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73DC7  jrl NZ,0xf747dc
	ld	w, 101:opc	; F73DCA  ld W,0x65
	ld	l, 0:opc	; F73DCC  ld L,0x00
	pushw	wa	; F73DCE  push WA
	calr	SmfWrite_WriteChannelEvent	; F73DCF  calr 0xf74ac5
	popw	wa	; F73DD2  pop WA
	cp	(0x1238:16), 0x03	; F73DD3  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73DD8  jrl NZ,0xf747dc
	ld	w, 100:opc	; F73DDB  ld W,0x64
	ld	l, 2:opc	; F73DDD  ld L,0x02
	pushw	wa	; F73DDF  push WA
	calr	SmfWrite_WriteChannelEvent	; F73DE0  calr 0xf74ac5
	popw	wa	; F73DE3  pop WA
	cp	(0x1238:16), 0x03	; F73DE4  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73DE9  jrl NZ,0xf747dc
	ld	l, (3184:16)	; F73DEC  ld L,(0x0c70)
	xor	h, h	; F73DF0  xor H,H
	push	xix	; F73DF2  push XIX
	ld	xix, BStore_TrackToPart	; F73DF3  ld XIX,0x00603422
	ld	l, (xix+hl)	; F73DF8  ld L,(XIX+HL)
	sla	l, 1	; F73DFD  sla 0x01,L
	ld	xix, SmfPartOffsets_F74960	; F73E00  ld XIX,0x00f74960
	ld	hl, (xix+hl)	; F73E05  ld HL,(XIX+HL)
	pop	xix	; F73E0A  pop XIX
	ld	xiy, 6305440	; F73E0B  ld XIY,0x006036a0
	ldfr_lerp	xiy, 0x38	; F73E10  ld XDE3,XIY
	lda	xiy, (xiy+hl)	; F73E13  lda XIY,XIY+HL
	ld	l, (xiy+11)	; F73E18  ld L,(XIY+0x0b)
	ldto_lerp	xiy, 0x38	; F73E1B  ld XIY,XDE3
	ld	w, 6:opc	; F73E1E  ld W,0x06
	pushw	wa	; F73E20  push WA
	calr	SmfWrite_WriteChannelEvent	; F73E21  calr 0xf74ac5
	popw	wa	; F73E24  pop WA
	cp	(0x1238:16), 0x03	; F73E25  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73E2A  jrl NZ,0xf747dc
	ld	w, 38:opc	; F73E2D  ld W,0x26
	xor	l, l	; F73E2F  xor L,L
	pushw	wa	; F73E31  push WA
	calr	SmfWrite_WriteChannelEvent	; F73E32  calr 0xf74ac5
	popw	wa	; F73E35  pop WA
	cp	(0x1238:16), 0x03	; F73E36  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73E3B  jrl NZ,0xf747dc
	ld	w, 101:opc	; F73E3E  ld W,0x65
	ld	l, 0:opc	; F73E40  ld L,0x00
	pushw	wa	; F73E42  push WA
	calr	SmfWrite_WriteChannelEvent	; F73E43  calr 0xf74ac5
	popw	wa	; F73E46  pop WA
	cp	(0x1238:16), 0x03	; F73E47  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73E4C  jrl NZ,0xf747dc
	ld	w, 100:opc	; F73E4F  ld W,0x64
	ld	l, 0:opc	; F73E51  ld L,0x00
	pushw	wa	; F73E53  push WA
	calr	SmfWrite_WriteChannelEvent	; F73E54  calr 0xf74ac5
	popw	wa	; F73E57  pop WA
	cp	(0x1238:16), 0x03	; F73E58  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73E5D  jrl NZ,0xf747dc
	ld	l, (3184:16)	; F73E60  ld L,(0x0c70)
	xor	h, h	; F73E64  xor H,H
	push	xix	; F73E66  push XIX
	ld	xix, BStore_TrackToPart	; F73E67  ld XIX,0x00603422
	ld	l, (xix+hl)	; F73E6C  ld L,(XIX+HL)
	sla	l, 1	; F73E71  sla 0x01,L
	ld	xix, SmfPartOffsets_F74960	; F73E74  ld XIX,0x00f74960
	ld	hl, (xix+hl)	; F73E79  ld HL,(XIX+HL)
	pop	xix	; F73E7E  pop XIX
	ld	xiy, 6305440	; F73E7F  ld XIY,0x006036a0
	lda	xiy, (xiy+hl)	; F73E84  lda XIY,XIY+HL
	ld	l, (xiy+13)	; F73E89  ld L,(XIY+0x0d)
	ld	w, 6:opc	; F73E8C  ld W,0x06
	pushw	wa	; F73E8E  push WA
	calr	SmfWrite_WriteChannelEvent	; F73E8F  calr 0xf74ac5
	popw	wa	; F73E92  pop WA
	cp	(0x1238:16), 0x03	; F73E93  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73E98  jrl NZ,0xf747dc
	ld	w, 38:opc	; F73E9B  ld W,0x26
	xor	l, l	; F73E9D  xor L,L
	pushw	wa	; F73E9F  push WA
	calr	SmfWrite_WriteChannelEvent	; F73EA0  calr 0xf74ac5
	popw	wa	; F73EA3  pop WA
	cp	(0x1238:16), 0x03	; F73EA4  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73EA9  jrl NZ,0xf747dc
Smf_WriteFile_Skip13:
	inc	1, (3184:16)	; F73EAC  inc 1,(0x0c70)
	cp	(0x0c70:16), 0x0f	; F73EB0  cp (0x0c70),0x0f
	jrl	ule, Smf_WriteFile_Loop4	; F73EB5  jrl ULE,0xf73b38
Smf_WriteFile_Join4:
	calr	Smf_WriteFile_Nop	; F73EB8  calr 0xf7486b
	xor	wa, wa	; F73EBB  xor WA,WA
	ld	(4226:16), wa	; F73EBD  ld (0x1082),WA
	ld	(4228:16), wa	; F73EC1  ld (0x1084),WA
	calr	SmfWrite_ReadSongByte	; F73EC5  calr 0xf74e71
	cp	a, 130	; F73EC8  cp A,0x82
	jr	z, Smf_WriteFile_Skip14	; F73ECB  jr Z,0xf73eec
	cp	a, 129	; F73ECD  cp A,0x81
	jr	z, Smf_WriteFile_Skip14	; F73ED0  jr Z,0xf73eec
	pushw	(BStore_CursorBlock:16)	; F73ED2  pushw (0x345c)
	pushw	(BStore_CursorOffset:16)	; F73ED6  pushw (0x345e)
	calr	SmfWrite_AdvanceSongCursor	; F73EDA  calr 0xf74e86
	calr	SmfWrite_ReadSongByte	; F73EDD  calr 0xf74e71
	popw	(BStore_CursorOffset:16)	; F73EE0  popw (0x345e)
	popw	(BStore_CursorBlock:16)	; F73EE4  popw (0x345c)
	ld	(4228:16), a	; F73EE8  ld (0x1084),A
Smf_WriteFile_Skip14:
	ldw	(4230:16), 0	; F73EEC  ld (0x1086),0x0000
	ldw	(4222:16), 0	; F73EF2  ld (0x107e),0x0000
	ldw	(4224:16), 0	; F73EF8  ld (0x1080),0x0000
Smf_WriteFile_Loop6:
	xor	xhl, xhl	; F73EFE  xor XHL,XHL
	push	xhl	; F73F00  push XHL
	calr	SmfWrite_ClearEventFields	; F73F01  calr 0xf74e60
	calr	SmfWrite_ReadSongByte	; F73F04  calr 0xf74e71
	pop	xhl	; F73F07  pop XHL
	cp	a, 130	; F73F08  cp A,0x82
	jrl	z, Smf_WriteFile_Skip55	; F73F0B  jrl Z,0xf7473a
Smf_WriteFile_Loop7:
	push	xde	; F73F0E  push XDE
	ld	xde, Smf_VlqValue	; F73F0F  ld XDE,0x00001198
	ld	(xde+hl), a	; F73F14  ld (XDE+HL),A
	pop	xde	; F73F19  pop XDE
	push	xhl	; F73F1A  push XHL
	calr	SmfWrite_AdvanceSongCursor	; F73F1B  calr 0xf74e86
	calr	SmfWrite_ReadSongByte	; F73F1E  calr 0xf74e71
	pop	xhl	; F73F21  pop XHL
	inc	1, hl	; F73F22  inc 1,HL
	bit	7, a	; F73F24  bit 0x07,A
	jr	z, Smf_WriteFile_Loop7	; F73F27  jr Z,0xf73f0e
	ld	a, (Smf_VlqValue:16)	; F73F29  ld A,(0x1198)
	cp	a, 130	; F73F2D  cp A,0x82
	jrl	z, Smf_WriteFile_Skip55	; F73F30  jrl Z,0xf7473a
	cp	a, 129	; F73F33  cp A,0x81
	jr	z, Smf_WriteFile_Skip15	; F73F36  jr Z,0xf73f6a
	ld	w, a	; F73F38  ld W,A
	and	w, 240	; F73F3A  and W,0xf0
	cp	w, 144	; F73F3D  cp W,0x90
	jrl	z, Smf_WriteFile_Skip22	; F73F40  jrl Z,0xf740ae
	cp	w, 176	; F73F43  cp W,0xb0
	jrl	z, Smf_WriteFile_Skip27	; F73F46  jrl Z,0xf7427b
	cp	w, 192	; F73F49  cp W,0xc0
	jrl	z, Smf_WriteFile_Skip24	; F73F4C  jrl Z,0xf74135
	cp	w, 208	; F73F4F  cp W,0xd0
	jrl	z, Smf_WriteFile_Skip19	; F73F52  jrl Z,0xf74012
	cp	w, 240	; F73F55  cp W,0xf0
	jrl	z, Smf_WriteFile_Skip21	; F73F58  jrl Z,0xf74074
	cp	w, 160	; F73F5B  cp W,0xa0
	jrl	z, Smf_WriteFile_Skip17	; F73F5E  jrl Z,0xf73f9c
	cp	w, 224	; F73F61  cp W,0xe0
	jrl	z, Smf_WriteFile_Skip20	; F73F64  jrl Z,0xf74045
	jrl	Smf_WriteFile_Loop6	; F73F67  jrl T,0xf73efe
Smf_WriteFile_Skip15:
	incw	1, (4230:16)	; F73F6A  incw 1,(0x1086)
Smf_WriteFile_Join5:
	calr	SmfWrite_ReadSongByte	; F73F6E  calr 0xf74e71
	cp	a, 129	; F73F71  cp A,0x81
	jr	nz, Smf_WriteFile_Skip16	; F73F74  jr NZ,0xf73f7f
	incw	1, (4230:16)	; F73F76  incw 1,(0x1086)
	calr	SmfWrite_AdvanceSongCursor	; F73F7A  calr 0xf74e86
	jr	Smf_WriteFile_Join5	; F73F7D  jr T,0xf73f6e
Smf_WriteFile_Skip16:
	ld	wa, (4230:16)	; F73F7F  ld WA,(0x1086)
	ldw	de, 96	; F73F83  ld DE,0x0060
	mul	xwa, de	; F73F86  mul XWA,DE
	ld	de, qwa	; F73F88  ld DE,QWA
	add	(0x107e:16), wa	; F73F8B  add (0x107e),WA
	ld	(4224:16), de	; F73F8F  ld (0x1080),DE
	ldw	(4230:16), 0	; F73F93  ld (0x1086),0x0000
	jrl	Smf_WriteFile_Loop6	; F73F99  jrl T,0xf73efe
Smf_WriteFile_Skip17:
	cp	hl, 3:i3	; F73F9C  cp HL,3
	jr	z, Smf_WriteFile_Skip18	; F73F9E  jr Z,0xf73fe4
	cp	hl, 4:i3	; F73FA0  cp HL,4
	jrl	nz, Smf_WriteFile_Loop6	; F73FA2  jrl NZ,0xf73efe
	ld	c, (4505:16)	; F73FA5  ld C,(0x1199)
	calr	SmfWrite_EncodeDeltaTime	; F73FA9  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F73FAC  calr 0xf74bf6
	cp	(0x1238:16), 0x03	; F73FAF  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73FB4  jrl NZ,0xf747dc
	ld	hl, (4506:16)	; F73FB7  ld HL,(0x119a)
	and	l, 127	; F73FBB  and L,0x7f
	and	h, 1	; F73FBE  and H,0x01
	rrc	h	; F73FC1  rrc 0x01,H
	and	h, 128	; F73FC4  and H,0x80
	or	l, h	; F73FC7  or L,H
	xor	h, h	; F73FC9  xor H,H
	pushw	wa	; F73FCB  push WA
	ld	w, (4507:16)	; F73FCC  ld W,(0x119b)
	and	w, 2	; F73FD0  and W,0x02
	srl	w, 1	; F73FD3  srl 0x01,W
	xor	a, a	; F73FD6  xor A,A
	or	hl, wa	; F73FD8  or HL,WA
	popw	wa	; F73FDA  pop WA
	calr	SmfWrite_StageTempoFromBpm	; F73FDB  calr 0xf749a2
	calr	SmfWrite_WriteTempoEvent	; F73FDE  calr 0xf749c5
	jrl	Smf_WriteFile_Loop6	; F73FE1  jrl T,0xf73efe
Smf_WriteFile_Skip18:
	ld	c, (4505:16)	; F73FE4  ld C,(0x1199)
	pushw	wa	; F73FE8  push WA
	calr	SmfWrite_EncodeDeltaTime	; F73FE9  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F73FEC  calr 0xf74bf6
	popw	wa	; F73FEF  pop WA
	cp	(0x1238:16), 0x03	; F73FF0  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F73FF5  jrl NZ,0xf747dc
	and	a, 15	; F73FF8  and A,0x0f
	or	a, 208	; F73FFB  or A,0xd0
	ld	w, (4506:16)	; F73FFE  ld W,(0x119a)
	xor	l, l	; F74002  xor L,L
	calr	SmfWrite_WriteChannelEvent	; F74004  calr 0xf74ac5
	cp	(0x1238:16), 0x03	; F74007  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F7400C  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F7400F  jrl T,0xf73efe
Smf_WriteFile_Skip19:
	cp	hl, 3:i3	; F74012  cp HL,3
	jrl	nz, Smf_WriteFile_Loop6	; F74014  jrl NZ,0xf73efe
	ld	c, (4505:16)	; F74017  ld C,(0x1199)
	pushw	wa	; F7401B  push WA
	calr	SmfWrite_EncodeDeltaTime	; F7401C  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F7401F  calr 0xf74bf6
	popw	wa	; F74022  pop WA
	cp	(0x1238:16), 0x03	; F74023  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74028  jrl NZ,0xf747dc
	and	a, 15	; F7402B  and A,0x0f
	or	a, 176	; F7402E  or A,0xb0
	ld	w, 1:opc	; F74031  ld W,0x01
	ld	l, (4506:16)	; F74033  ld L,(0x119a)
	calr	SmfWrite_WriteChannelEvent	; F74037  calr 0xf74ac5
	cp	(0x1238:16), 0x03	; F7403A  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F7403F  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F74042  jrl T,0xf73efe
Smf_WriteFile_Skip20:
	cp	hl, 4:i3	; F74045  cp HL,4
	jrl	nz, Smf_WriteFile_Loop6	; F74047  jrl NZ,0xf73efe
	ld	c, (4505:16)	; F7404A  ld C,(0x1199)
	pushw	wa	; F7404E  push WA
	calr	SmfWrite_EncodeDeltaTime	; F7404F  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F74052  calr 0xf74bf6
	popw	wa	; F74055  pop WA
	cp	(0x1238:16), 0x03	; F74056  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F7405B  jrl NZ,0xf747dc
	ld	w, (4506:16)	; F7405E  ld W,(0x119a)
	ld	l, (4507:16)	; F74062  ld L,(0x119b)
	calr	SmfWrite_WriteChannelEvent	; F74066  calr 0xf74ac5
	cp	(0x1238:16), 0x03	; F74069  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F7406E  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F74071  jrl T,0xf73efe
Smf_WriteFile_Skip21:
	cp	hl, 3:i3	; F74074  cp HL,3
	jrl	nz, Smf_WriteFile_Loop6	; F74076  jrl NZ,0xf73efe
	ld	l, a	; F74079  ld L,A
	and	l, 15	; F7407B  and L,0x0f
	xor	h, h	; F7407E  xor H,H
	ld	c, (4505:16)	; F74080  ld C,(0x1199)
	pushw	wa	; F74084  push WA
	calr	SmfWrite_EncodeDeltaTime	; F74085  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F74088  calr 0xf74bf6
	popw	wa	; F7408B  pop WA
	cp	(0x1238:16), 0x03	; F7408C  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74091  jrl NZ,0xf747dc
	and	a, 15	; F74094  and A,0x0f
	or	a, 176	; F74097  or A,0xb0
	ld	w, 11:opc	; F7409A  ld W,0x0b
	ld	l, (4506:16)	; F7409C  ld L,(0x119a)
	calr	SmfWrite_WriteChannelEvent	; F740A0  calr 0xf74ac5
	cp	(0x1238:16), 0x03	; F740A3  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F740A8  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F740AB  jrl T,0xf73efe
Smf_WriteFile_Skip22:
	cp	hl, 6:i3	; F740AE  cp HL,6
	jrl	nz, Smf_WriteFile_Loop6	; F740B0  jrl NZ,0xf73efe
	xor	xhl, xhl	; F740B3  xor XHL,XHL
Smf_WriteFile_Loop8:
	push	xde	; F740B5  push XDE
	ld	xde, 12378	; F740B6  ld XDE,0x0000305a
	bit	7, (xde+hl)	; F740BB  bit 7,(XDE+HL)
	pop	xde	; F740C0  pop XDE
	jr	z, Smf_WriteFile_Skip23	; F740C1  jr Z,0xf740d0
	add	hl, 5	; F740C3  add HL,0x0005
	cp	hl, 160	; F740C7  cp HL,0x00a0
	jr	ule, Smf_WriteFile_Loop8	; F740CB  jr ULE,0xf740b5
	jrl	Smf_WriteFile_Loop6	; F740CD  jrl T,0xf73efe
Smf_WriteFile_Skip23:
	or	(0x11b1:16), 0x01	; F740D0  or (0x11b1),0x01
	pushw	hl	; F740D5  push HL
	ld	c, (4505:16)	; F740D6  ld C,(0x1199)
	calr	SmfWrite_EncodeDeltaTime	; F740DA  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F740DD  calr 0xf74bf6
	popw	hl	; F740E0  pop HL
	cp	(0x1238:16), 0x03	; F740E1  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F740E6  jrl NZ,0xf747dc
	pushw	hl	; F740E9  push HL
	ld	a, (Smf_VlqValue:16)	; F740EA  ld A,(0x1198)
	ld	w, (4506:16)	; F740EE  ld W,(0x119a)
	ld	l, (4507:16)	; F740F2  ld L,(0x119b)
	calr	SmfWrite_WriteChannelEvent	; F740F6  calr 0xf74ac5
	popw	hl	; F740F9  pop HL
	cp	(0x1238:16), 0x03	; F740FA  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F740FF  jrl NZ,0xf747dc
	ld	xix, 12378	; F74102  ld XIX,0x0000305a
	lda	xix, (xix+hl)	; F74107  lda XIX,XIX+HL
	ld	a, 128:opc	; F7410C  ld A,0x80
	ld	(xix+), a	; F7410E  ld (XIX+),A
	ld	a, (Smf_VlqValue:16)	; F74111  ld A,(0x1198)
	ld	(xix+), a	; F74115  ld (XIX+),A
	ld	a, (4506:16)	; F74118  ld A,(0x119a)
	ld	(xix+), a	; F7411C  ld (XIX+),A
	ld	a, (4509:16)	; F7411F  ld A,(0x119d)
	ld	w, 96:opc	; F74123  ld W,0x60
	muls	wa, w	; F74125  muls WA,W
	xor	hl, hl	; F74127  xor HL,HL
	ld	l, (4508:16)	; F74129  ld L,(0x119c)
	add	wa, hl	; F7412D  add WA,HL
	ld	(xix+), wa	; F7412F  ld (XIX+),WA
	jrl	Smf_WriteFile_Loop6	; F74132  jrl T,0xf73efe
Smf_WriteFile_Skip24:
	cp	hl, 6:i3	; F74135  cp HL,6
	jrl	nz, Smf_WriteFile_Loop6	; F74137  jrl NZ,0xf73efe
	cp	(0x119a:16), 0x7f	; F7413A  cp (0x119a),0x7f
	jrl	z, Smf_WriteFile_Loop6	; F7413F  jrl Z,0xf73efe
	ld	a, (4507:16)	; F74142  ld A,(0x119b)
	cp	a, 0:i3	; F74146  cp A,0
	jrl	nz, Smf_WriteFile_Loop6	; F74148  jrl NZ,0xf73efe
	bit	0, (0x133e:16)	; F7414B  bit 0,(0x133e)
	jr	z, Smf_WriteFile_Skip25	; F7414F  jr Z,0xf74158
	bit	0, (0x11b1:16)	; F74151  bit 0,(0x11b1)
	jrl	z, Smf_WriteFile_Loop6	; F74155  jrl Z,0xf73efe
Smf_WriteFile_Skip25:
	ld	c, (4505:16)	; F74158  ld C,(0x1199)
	pushw	wa	; F7415C  push WA
	calr	SmfWrite_EncodeDeltaTime	; F7415D  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F74160  calr 0xf74bf6
	popw	wa	; F74163  pop WA
	cp	(0x1238:16), 0x03	; F74164  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74169  jrl NZ,0xf747dc
	cp	(0x1239:16), 0x00	; F7416C  cp (0x1239),0x00
	jrl	z, Smf_WriteFile_Skip26	; F74171  jrl Z,0xf74223
	ld	l, (Smf_VlqValue:16)	; F74174  ld L,(0x1198)
	ld	h, l	; F74178  ld H,L
	and	l, 1	; F7417A  and L,0x01
	rrc	l	; F7417D  rrc 0x01,L
	ld	a, (4508:16)	; F74180  ld A,(0x119c)
	or	l, a	; F74184  or L,A
	ld	(SoundConv_Arg0:24), l	; F74186  ld (0x60f010),L
	ld	l, (Smf_VlqValue:16)	; F7418B  ld L,(0x1198)
	and	l, 2	; F7418F  and L,0x02
	.byte 0xCF, 0xE9, 0x02	; F74192  rrc 0x02,L   [llvm-mc cannot encode this]
	ld	a, (4509:16)	; F74195  ld A,(0x119d)
	and	a, 127	; F74199  and A,0x7f
	or	a, l	; F7419C  or A,L
	ld	(SoundConv_Arg1:24), a	; F7419E  ld (0x60f011),A
	push	xix	; F741A3  push XIX
	xor	hl, hl	; F741A4  xor HL,HL
	ld	l, (4506:16)	; F741A6  ld L,(0x119a)
	ld	xix, BStore_TrackToPart	; F741AA  ld XIX,0x00603422
	ld	l, (xix+hl)	; F741AF  ld L,(XIX+HL)
	ld	xix, ByteMap_F7484A	; F741B4  ld XIX,0x00f7484a
	ld	l, (xix+hl)	; F741B9  ld L,(XIX+HL)
	ld	(SoundConv_Arg2:24), l	; F741BE  ld (0x60f012),L
	pop	xix	; F741C3  pop XIX
	call	T_PartSound_ToProgramChange	; F741C4  call 0xf41008
	ld	a, 176:opc	; F741C8  ld A,0xb0
	ld	w, (4506:16)	; F741CA  ld W,(0x119a)
	or	a, w	; F741CE  or A,W
	xor	w, w	; F741D0  xor W,W
	ld	l, (SoundConv_Result1:24)	; F741D2  ld L,(0x60f015)
	pushw	wa	; F741D7  push WA
	call	SmfWrite_WriteChannelEvent	; F741D8  call 0xf74ac5
	popw	wa	; F741DC  pop WA
	cp	(0x1238:16), 0x03	; F741DD  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F741E2  jrl NZ,0xf747dc
	ldw	(Smf_VlqBytes:16), 0	; F741E5  ld (0x1193),0x0000
	ld	(4501:16), 0	; F741EB  ld (0x1195),0x00
	ld	w, 32:opc	; F741F0  ld W,0x20
	ld	l, (SoundConv_Result0:24)	; F741F2  ld L,(0x60f014)
	call	SmfWrite_WriteChannelEvent	; F741F7  call 0xf74ac5
	cp	(0x1238:16), 0x03	; F741FB  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74200  jrl NZ,0xf747dc
	ld	a, 192:opc	; F74203  ld A,0xc0
	ld	w, (4506:16)	; F74205  ld W,(0x119a)
	and	w, 15	; F74209  and W,0x0f
	or	a, w	; F7420C  or A,W
	ld	w, (SoundConv_Result2:24)	; F7420E  ld W,(0x60f016)
	xor	l, l	; F74213  xor L,L
	calr	SmfWrite_WriteChannelEvent	; F74215  calr 0xf74ac5
	cp	(0x1238:16), 0x03	; F74218  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F7421D  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F74220  jrl T,0xf73efe
Smf_WriteFile_Skip26:
	ld	w, 0:opc	; F74223  ld W,0x00
	ld	l, (4509:16)	; F74225  ld L,(0x119d)
	and	l, 56	; F74229  and L,0x38
	srl	l, 3	; F7422C  srl 0x03,L
	calr	SmfWrite_WriteControlChange	; F7422F  calr 0xf74a66
	cp	(0x1238:16), 0x03	; F74232  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74237  jrl NZ,0xf747dc
	ldw	(Smf_VlqBytes:16), 0	; F7423A  ld (0x1193),0x0000
	ld	(4501:16), 0	; F74240  ld (0x1195),0x00
	ld	w, 32:opc	; F74245  ld W,0x20
	ld	l, (4509:16)	; F74247  ld L,(0x119d)
	and	l, 7	; F7424B  and L,0x07
	sla	l, 4	; F7424E  sla 0x04,L
	calr	SmfWrite_WriteControlChange	; F74251  calr 0xf74a66
	cp	(0x1238:16), 0x03	; F74254  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74259  jrl NZ,0xf747dc
	ld	a, 192:opc	; F7425C  ld A,0xc0
	ld	w, (4506:16)	; F7425E  ld W,(0x119a)
	and	w, 15	; F74262  and W,0x0f
	or	a, w	; F74265  or A,W
	ld	w, (4508:16)	; F74267  ld W,(0x119c)
	xor	l, l	; F7426B  xor L,L
	calr	SmfWrite_WriteChannelEvent	; F7426D  calr 0xf74ac5
	cp	(0x1238:16), 0x03	; F74270  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74275  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F74278  jrl T,0xf73efe
Smf_WriteFile_Skip27:
	cp	hl, 6:i3	; F7427B  cp HL,6
	jrl	nz, Smf_WriteFile_Loop6	; F7427D  jrl NZ,0xf73efe
	cp	(0x119a:16), 0x7f	; F74280  cp (0x119a),0x7f
	jrl	z, Smf_WriteFile_Skip54	; F74285  jrl Z,0xf74737
	ld	l, (4507:16)	; F74288  ld L,(0x119b)
	ld	a, (4506:16)	; F7428C  ld A,(0x119a)
	ld	w, (Smf_VlqValue:16)	; F74290  ld W,(0x1198)
	and	w, 4	; F74294  and W,0x04
	sla	w, 5	; F74297  sla 0x05,W
	or	a, w	; F7429A  or A,W
	cp	a, 181	; F7429C  cp A,0xb5
	jr	z, Smf_WriteFile_Skip28	; F7429F  jr Z,0xf742c2
	cp	a, 188	; F742A1  cp A,0xbc
	jr	z, Smf_WriteFile_Skip28	; F742A4  jr Z,0xf742c2
	cp	a, 189	; F742A6  cp A,0xbd
	jr	z, Smf_WriteFile_Skip28	; F742A9  jr Z,0xf742c2
	cp	a, 184	; F742AB  cp A,0xb8
	jr	z, Smf_WriteFile_Skip28	; F742AE  jr Z,0xf742c2
	cp	a, 185	; F742B0  cp A,0xb9
	jr	z, Smf_WriteFile_Skip28	; F742B3  jr Z,0xf742c2
	cp	a, 186	; F742B5  cp A,0xba
	jr	z, Smf_WriteFile_Skip28	; F742B8  jr Z,0xf742c2
	cp	a, 187	; F742BA  cp A,0xbb
	jr	z, Smf_WriteFile_Skip28	; F742BD  jr Z,0xf742c2
	jrl	Smf_WriteFile_Join6	; F742BF  jrl T,0xf7447c
Smf_WriteFile_Skip28:
	ld	l, (4507:16)	; F742C2  ld L,(0x119b)
	cp	l, 127	; F742C6  cp L,0x7f
	jrl	z, Smf_WriteFile_Skip54	; F742C9  jrl Z,0xf74737
	cp	a, 181	; F742CC  cp A,0xb5
	jrl	z, Smf_WriteFile_Skip29	; F742CF  jrl Z,0xf74310
	cp	a, 188	; F742D2  cp A,0xbc
	jrl	z, Smf_WriteFile_Skip30	; F742D5  jrl Z,0xf74344
	cp	a, 189	; F742D8  cp A,0xbd
	jrl	z, Smf_WriteFile_Skip31	; F742DB  jrl Z,0xf74378
	cp	a, 184	; F742DE  cp A,0xb8
	jrl	z, Smf_WriteFile_Skip32	; F742E1  jrl Z,0xf743ac
	cp	a, 185	; F742E4  cp A,0xb9
	jrl	z, Smf_WriteFile_Skip33	; F742E7  jrl Z,0xf743e0
	cp	a, 186	; F742EA  cp A,0xba
	jrl	z, Smf_WriteFile_Skip34	; F742ED  jrl Z,0xf74414
	cp	a, 187	; F742F0  cp A,0xbb
	jrl	z, Smf_WriteFile_Skip35	; F742F3  jrl Z,0xf74448
	cp	l, 0:i3	; F742F6  cp L,0
	jrl	c, Smf_WriteFile_Skip54	; F742F8  jrl C,0xf74737
	cp	l, 16	; F742FB  cp L,0x10
	jrl	ugt, Smf_WriteFile_Skip54	; F742FE  jrl UGT,0xf74737
	jrl	Smf_WriteFile_Loop6	; F74301  jrl T,0xf73efe
	jrl	Smf_WriteFile_Loop6	; F74304  jrl T,0xf73efe
	jrl	Smf_WriteFile_Loop6	; F74307  jrl T,0xf73efe
	jrl	Smf_WriteFile_Loop6	; F7430A  jrl T,0xf73efe
	jrl	Smf_WriteFile_Loop6	; F7430D  jrl T,0xf73efe
Smf_WriteFile_Skip29:
	ld	c, (4505:16)	; F74310  ld C,(0x1199)
	pushw	wa	; F74314  push WA
	pushw	hl	; F74315  push HL
	calr	SmfWrite_EncodeDeltaTime	; F74316  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F74319  calr 0xf74bf6
	popw	hl	; F7431C  pop HL
	popw	wa	; F7431D  pop WA
	cp	(0x1238:16), 0x03	; F7431E  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74323  jrl NZ,0xf747dc
	ld	a, 176:opc	; F74326  ld A,0xb0
	ld	w, l	; F74328  ld W,L
	and	w, 15	; F7432A  and W,0x0f
	or	a, w	; F7432D  or A,W
	ld	w, 64:opc	; F7432F  ld W,0x40
	ld	l, (4508:16)	; F74331  ld L,(0x119c)
	call	SmfWrite_WriteChannelEvent	; F74335  call 0xf74ac5
	cp	(0x1238:16), 0x03	; F74339  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F7433E  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F74341  jrl T,0xf73efe
Smf_WriteFile_Skip30:
	ld	c, (4505:16)	; F74344  ld C,(0x1199)
	pushw	wa	; F74348  push WA
	pushw	hl	; F74349  push HL
	calr	SmfWrite_EncodeDeltaTime	; F7434A  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F7434D  calr 0xf74bf6
	popw	hl	; F74350  pop HL
	popw	wa	; F74351  pop WA
	cp	(0x1238:16), 0x03	; F74352  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74357  jrl NZ,0xf747dc
	ld	a, 176:opc	; F7435A  ld A,0xb0
	ld	w, l	; F7435C  ld W,L
	and	w, 15	; F7435E  and W,0x0f
	or	a, w	; F74361  or A,W
	ld	w, 2:opc	; F74363  ld W,0x02
	ld	l, (4508:16)	; F74365  ld L,(0x119c)
	call	SmfWrite_WriteChannelEvent	; F74369  call 0xf74ac5
	cp	(0x1238:16), 0x03	; F7436D  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74372  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F74375  jrl T,0xf73efe
Smf_WriteFile_Skip31:
	ld	c, (4505:16)	; F74378  ld C,(0x1199)
	pushw	wa	; F7437C  push WA
	pushw	hl	; F7437D  push HL
	calr	SmfWrite_EncodeDeltaTime	; F7437E  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F74381  calr 0xf74bf6
	popw	hl	; F74384  pop HL
	popw	wa	; F74385  pop WA
	cp	(0x1238:16), 0x03	; F74386  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F7438B  jrl NZ,0xf747dc
	ld	a, 176:opc	; F7438E  ld A,0xb0
	ld	w, l	; F74390  ld W,L
	and	w, 15	; F74392  and W,0x0f
	or	a, w	; F74395  or A,W
	ld	w, 4:opc	; F74397  ld W,0x04
	ld	l, (4508:16)	; F74399  ld L,(0x119c)
	call	SmfWrite_WriteChannelEvent	; F7439D  call 0xf74ac5
	cp	(0x1238:16), 0x03	; F743A1  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F743A6  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F743A9  jrl T,0xf73efe
Smf_WriteFile_Skip32:
	ld	c, (4505:16)	; F743AC  ld C,(0x1199)
	pushw	wa	; F743B0  push WA
	pushw	hl	; F743B1  push HL
	calr	SmfWrite_EncodeDeltaTime	; F743B2  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F743B5  calr 0xf74bf6
	popw	hl	; F743B8  pop HL
	popw	wa	; F743B9  pop WA
	cp	(0x1238:16), 0x03	; F743BA  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F743BF  jrl NZ,0xf747dc
	ld	a, 176:opc	; F743C2  ld A,0xb0
	ld	w, l	; F743C4  ld W,L
	and	w, 15	; F743C6  and W,0x0f
	or	a, w	; F743C9  or A,W
	ld	w, 16:opc	; F743CB  ld W,0x10
	ld	l, (4508:16)	; F743CD  ld L,(0x119c)
	call	SmfWrite_WriteChannelEvent	; F743D1  call 0xf74ac5
	cp	(0x1238:16), 0x03	; F743D5  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F743DA  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F743DD  jrl T,0xf73efe
Smf_WriteFile_Skip33:
	ld	c, (4505:16)	; F743E0  ld C,(0x1199)
	pushw	wa	; F743E4  push WA
	pushw	hl	; F743E5  push HL
	calr	SmfWrite_EncodeDeltaTime	; F743E6  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F743E9  calr 0xf74bf6
	popw	hl	; F743EC  pop HL
	popw	wa	; F743ED  pop WA
	cp	(0x1238:16), 0x03	; F743EE  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F743F3  jrl NZ,0xf747dc
	ld	a, 176:opc	; F743F6  ld A,0xb0
	ld	w, l	; F743F8  ld W,L
	and	w, 15	; F743FA  and W,0x0f
	or	a, w	; F743FD  or A,W
	ld	w, 17:opc	; F743FF  ld W,0x11
	ld	l, (4508:16)	; F74401  ld L,(0x119c)
	call	SmfWrite_WriteChannelEvent	; F74405  call 0xf74ac5
	cp	(0x1238:16), 0x03	; F74409  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F7440E  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F74411  jrl T,0xf73efe
Smf_WriteFile_Skip34:
	ld	c, (4505:16)	; F74414  ld C,(0x1199)
	pushw	wa	; F74418  push WA
	pushw	hl	; F74419  push HL
	calr	SmfWrite_EncodeDeltaTime	; F7441A  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F7441D  calr 0xf74bf6
	popw	hl	; F74420  pop HL
	popw	wa	; F74421  pop WA
	cp	(0x1238:16), 0x03	; F74422  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74427  jrl NZ,0xf747dc
	ld	a, 176:opc	; F7442A  ld A,0xb0
	ld	w, l	; F7442C  ld W,L
	and	w, 15	; F7442E  and W,0x0f
	or	a, w	; F74431  or A,W
	ld	w, 18:opc	; F74433  ld W,0x12
	ld	l, (4508:16)	; F74435  ld L,(0x119c)
	call	SmfWrite_WriteChannelEvent	; F74439  call 0xf74ac5
	cp	(0x1238:16), 0x03	; F7443D  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74442  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F74445  jrl T,0xf73efe
Smf_WriteFile_Skip35:
	ld	c, (4505:16)	; F74448  ld C,(0x1199)
	pushw	wa	; F7444C  push WA
	pushw	hl	; F7444D  push HL
	calr	SmfWrite_EncodeDeltaTime	; F7444E  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F74451  calr 0xf74bf6
	popw	hl	; F74454  pop HL
	popw	wa	; F74455  pop WA
	cp	(0x1238:16), 0x03	; F74456  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F7445B  jrl NZ,0xf747dc
	ld	a, 176:opc	; F7445E  ld A,0xb0
	ld	w, l	; F74460  ld W,L
	and	w, 15	; F74462  and W,0x0f
	or	a, w	; F74465  or A,W
	ld	w, 19:opc	; F74467  ld W,0x13
	ld	l, (4508:16)	; F74469  ld L,(0x119c)
	call	SmfWrite_WriteChannelEvent	; F7446D  call 0xf74ac5
	cp	(0x1238:16), 0x03	; F74471  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74476  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F74479  jrl T,0xf73efe
Smf_WriteFile_Join6:
	cp	l, 3:i3	; F7447C  cp L,3
	jrl	c, Smf_WriteFile_Loop6	; F7447E  jrl C,0xf73efe
	cp	l, 11	; F74481  cp L,0x0b
	jrl	ugt, Smf_WriteFile_Loop6	; F74484  jrl UGT,0xf73efe
	ld	a, 176:opc	; F74487  ld A,0xb0
	ld	w, (4506:16)	; F74489  ld W,(0x119a)
	and	w, 15	; F7448D  and W,0x0f
	or	a, w	; F74490  or A,W
	ld	w, 7:opc	; F74492  ld W,0x07
	cp	l, 3:i3	; F74494  cp L,3
	jrl	z, Smf_WriteFile_Skip52	; F74496  jrl Z,0xf74702
	cp	l, 4:i3	; F74499  cp L,4
	jrl	z, Smf_WriteFile_Skip44	; F7449B  jrl Z,0xf74693
	cp	l, 5:i3	; F7449E  cp L,5
	jrl	z, Smf_WriteFile_Skip45	; F744A0  jrl Z,0xf7469a
	cp	l, 6:i3	; F744A3  cp L,6
	jrl	z, Smf_WriteFile_Skip47	; F744A5  jrl Z,0xf746af
	cp	l, 7:i3	; F744A8  cp L,7
	jrl	z, Smf_WriteFile_Skip50	; F744AA  jrl Z,0xf746e8
	cp	l, 8	; F744AD  cp L,0x08
	jrl	z, Smf_WriteFile_Skip42	; F744B0  jrl Z,0xf74651
	cp	l, 9	; F744B3  cp L,0x09
	jrl	z, Smf_WriteFile_Skip40	; F744B6  jrl Z,0xf745d6
	cp	l, 10	; F744B9  cp L,0x0a
	jr	z, Smf_WriteFile_Skip36	; F744BC  jr Z,0xf744c7
	cp	l, 11	; F744BE  cp L,0x0b
	jrl	z, Smf_WriteFile_Skip38	; F744C1  jrl Z,0xf7455b
	jrl	nz, Smf_WriteFile_Loop6	; F744C4  jrl NZ,0xf73efe
Smf_WriteFile_Skip36:
	bit	0, (0x133e:16)	; F744C7  bit 0,(0x133e)
	jrl	z, Smf_WriteFile_Skip37	; F744CB  jrl Z,0xf744d5
	bit	0, (0x11b1:16)	; F744CE  bit 0,(0x11b1)
	jrl	z, Smf_WriteFile_Loop6	; F744D2  jrl Z,0xf73efe
Smf_WriteFile_Skip37:
	ld	c, (4505:16)	; F744D5  ld C,(0x1199)
	pushw	wa	; F744D9  push WA
	push	xhl	; F744DA  push XHL
	calr	SmfWrite_EncodeDeltaTime	; F744DB  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F744DE  calr 0xf74bf6
	pop	xhl	; F744E1  pop XHL
	popw	wa	; F744E2  pop WA
	cp	(0x1238:16), 0x03	; F744E3  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F744E8  jrl NZ,0xf747dc
	ld	a, 176:opc	; F744EB  ld A,0xb0
	ld	w, (4506:16)	; F744ED  ld W,(0x119a)
	and	w, 15	; F744F1  and W,0x0f
	or	a, w	; F744F4  or A,W
	ld	w, 101:opc	; F744F6  ld W,0x65
	ld	l, 0:opc	; F744F8  ld L,0x00
	pushw	wa	; F744FA  push WA
	calr	SmfWrite_WriteChannelEvent	; F744FB  calr 0xf74ac5
	popw	wa	; F744FE  pop WA
	cp	(0x1238:16), 0x03	; F744FF  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74504  jrl NZ,0xf747dc
	ld	w, 100:opc	; F74507  ld W,0x64
	ld	l, 1:opc	; F74509  ld L,0x01
	ld	(Smf_VlqBytes:16), 0	; F7450B  ld (0x1193),0x00
	pushw	wa	; F74510  push WA
	calr	SmfWrite_WriteChannelEvent	; F74511  calr 0xf74ac5
	popw	wa	; F74514  pop WA
	cp	(0x1238:16), 0x03	; F74515  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F7451A  jrl NZ,0xf747dc
	ld	w, 6:opc	; F7451D  ld W,0x06
	ld	l, (4508:16)	; F7451F  ld L,(0x119c)
	ld	h, (Smf_VlqValue:16)	; F74523  ld H,(0x1198)
	and	h, 1	; F74527  and H,0x01
	.byte 0xCE, 0xE9, 0x02	; F7452A  rrc 0x02,H   [llvm-mc cannot encode this]
	srl	l, 1	; F7452D  srl 0x01,L
	or	l, h	; F74530  or L,H
	pushw	wa	; F74532  push WA
	calr	SmfWrite_WriteChannelEvent	; F74533  calr 0xf74ac5
	popw	wa	; F74536  pop WA
	cp	(0x1238:16), 0x03	; F74537  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F7453C  jrl NZ,0xf747dc
	ld	w, 38:opc	; F7453F  ld W,0x26
	ld	l, (4508:16)	; F74541  ld L,(0x119c)
	and	l, 1	; F74545  and L,0x01
	.byte 0xCF, 0xE9, 0x02	; F74548  rrc 0x02,L   [llvm-mc cannot encode this]
	pushw	wa	; F7454B  push WA
	calr	SmfWrite_WriteChannelEvent	; F7454C  calr 0xf74ac5
	popw	wa	; F7454F  pop WA
	cp	(0x1238:16), 0x03	; F74550  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74555  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F74558  jrl T,0xf73efe
Smf_WriteFile_Skip38:
	bit	0, (0x133e:16)	; F7455B  bit 0,(0x133e)
	jrl	z, Smf_WriteFile_Skip39	; F7455F  jrl Z,0xf74569
	bit	0, (0x11b1:16)	; F74562  bit 0,(0x11b1)
	jrl	z, Smf_WriteFile_Loop6	; F74566  jrl Z,0xf73efe
Smf_WriteFile_Skip39:
	ld	c, (4505:16)	; F74569  ld C,(0x1199)
	pushw	wa	; F7456D  push WA
	pushw	hl	; F7456E  push HL
	calr	SmfWrite_EncodeDeltaTime	; F7456F  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F74572  calr 0xf74bf6
	popw	hl	; F74575  pop HL
	popw	wa	; F74576  pop WA
	cp	(0x1238:16), 0x03	; F74577  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F7457C  jrl NZ,0xf747dc
	ld	a, 176:opc	; F7457F  ld A,0xb0
	ld	w, (4506:16)	; F74581  ld W,(0x119a)
	and	w, 15	; F74585  and W,0x0f
	or	a, w	; F74588  or A,W
	ld	w, 101:opc	; F7458A  ld W,0x65
	ld	l, 0:opc	; F7458C  ld L,0x00
	pushw	wa	; F7458E  push WA
	calr	SmfWrite_WriteChannelEvent	; F7458F  calr 0xf74ac5
	popw	wa	; F74592  pop WA
	cp	(0x1238:16), 0x03	; F74593  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74598  jrl NZ,0xf747dc
	ld	w, 100:opc	; F7459B  ld W,0x64
	ld	l, 0:opc	; F7459D  ld L,0x00
	ld	(Smf_VlqBytes:16), 0	; F7459F  ld (0x1193),0x00
	pushw	wa	; F745A4  push WA
	calr	SmfWrite_WriteChannelEvent	; F745A5  calr 0xf74ac5
	popw	wa	; F745A8  pop WA
	cp	(0x1238:16), 0x03	; F745A9  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F745AE  jrl NZ,0xf747dc
	ld	w, 6:opc	; F745B1  ld W,0x06
	ld	l, (4508:16)	; F745B3  ld L,(0x119c)
	pushw	wa	; F745B7  push WA
	calr	SmfWrite_WriteChannelEvent	; F745B8  calr 0xf74ac5
	popw	wa	; F745BB  pop WA
	cp	(0x1238:16), 0x03	; F745BC  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F745C1  jrl NZ,0xf747dc
	ld	w, 38:opc	; F745C4  ld W,0x26
	ld	l, 0:opc	; F745C6  ld L,0x00
	calr	SmfWrite_WriteChannelEvent	; F745C8  calr 0xf74ac5
	cp	(0x1238:16), 0x03	; F745CB  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F745D0  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F745D3  jrl T,0xf73efe
Smf_WriteFile_Skip40:
	bit	0, (0x133e:16)	; F745D6  bit 0,(0x133e)
	jrl	z, Smf_WriteFile_Skip41	; F745DA  jrl Z,0xf745e4
	bit	0, (0x11b1:16)	; F745DD  bit 0,(0x11b1)
	jrl	z, Smf_WriteFile_Loop6	; F745E1  jrl Z,0xf73efe
Smf_WriteFile_Skip41:
	ld	c, (4505:16)	; F745E4  ld C,(0x1199)
	pushw	wa	; F745E8  push WA
	push	xhl	; F745E9  push XHL
	calr	SmfWrite_EncodeDeltaTime	; F745EA  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F745ED  calr 0xf74bf6
	pop	xhl	; F745F0  pop XHL
	popw	wa	; F745F1  pop WA
	cp	(0x1238:16), 0x03	; F745F2  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F745F7  jrl NZ,0xf747dc
	ld	a, 176:opc	; F745FA  ld A,0xb0
	ld	w, (4506:16)	; F745FC  ld W,(0x119a)
	and	w, 15	; F74600  and W,0x0f
	or	a, w	; F74603  or A,W
	ld	w, 101:opc	; F74605  ld W,0x65
	ld	l, 0:opc	; F74607  ld L,0x00
	pushw	wa	; F74609  push WA
	calr	SmfWrite_WriteChannelEvent	; F7460A  calr 0xf74ac5
	popw	wa	; F7460D  pop WA
	cp	(0x1238:16), 0x03	; F7460E  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74613  jrl NZ,0xf747dc
	ld	w, 100:opc	; F74616  ld W,0x64
	ld	l, 2:opc	; F74618  ld L,0x02
	ld	(Smf_VlqBytes:16), 0	; F7461A  ld (0x1193),0x00
	pushw	wa	; F7461F  push WA
	calr	SmfWrite_WriteChannelEvent	; F74620  calr 0xf74ac5
	popw	wa	; F74623  pop WA
	cp	(0x1238:16), 0x03	; F74624  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74629  jrl NZ,0xf747dc
	ld	w, 6:opc	; F7462C  ld W,0x06
	ld	l, (4508:16)	; F7462E  ld L,(0x119c)
	pushw	wa	; F74632  push WA
	calr	SmfWrite_WriteChannelEvent	; F74633  calr 0xf74ac5
	popw	wa	; F74636  pop WA
	cp	(0x1238:16), 0x03	; F74637  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F7463C  jrl NZ,0xf747dc
	ld	w, 38:opc	; F7463F  ld W,0x26
	ld	l, 0:opc	; F74641  ld L,0x00
	calr	SmfWrite_WriteChannelEvent	; F74643  calr 0xf74ac5
	cp	(0x1238:16), 0x03	; F74646  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F7464B  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F7464E  jrl T,0xf73efe
Smf_WriteFile_Skip42:
	bit	0, (0x133e:16)	; F74651  bit 0,(0x133e)
	jr	z, Smf_WriteFile_Skip43	; F74655  jr Z,0xf7465e
	bit	0, (0x11b1:16)	; F74657  bit 0,(0x11b1)
	jrl	z, Smf_WriteFile_Loop6	; F7465B  jrl Z,0xf73efe
Smf_WriteFile_Skip43:
	ld	c, (4505:16)	; F7465E  ld C,(0x1199)
	pushw	wa	; F74662  push WA
	push	xhl	; F74663  push XHL
	calr	SmfWrite_EncodeDeltaTime	; F74664  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F74667  calr 0xf74bf6
	pop	xhl	; F7466A  pop XHL
	popw	wa	; F7466B  pop WA
	cp	(0x1238:16), 0x03	; F7466C  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74671  jrl NZ,0xf747dc
	ld	a, 176:opc	; F74674  ld A,0xb0
	ld	w, (4506:16)	; F74676  ld W,(0x119a)
	and	w, 15	; F7467A  and W,0x0f
	or	a, w	; F7467D  or A,W
	ld	w, 10:opc	; F7467F  ld W,0x0a
	ld	l, (4508:16)	; F74681  ld L,(0x119c)
	calr	SmfWrite_WriteChannelEvent	; F74685  calr 0xf74ac5
	cp	(0x1238:16), 0x03	; F74688  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F7468D  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F74690  jrl T,0xf73efe
Smf_WriteFile_Skip44:
	ld	bc, (4508:16)	; F74693  ld BC,(0x119c)
	jrl	Smf_WriteFile_Loop6	; F74697  jrl T,0xf73efe
Smf_WriteFile_Skip45:
	bit	0, (0x133e:16)	; F7469A  bit 0,(0x133e)
	jr	z, Smf_WriteFile_Skip46	; F7469E  jr Z,0xf746a7
	bit	0, (0x11b1:16)	; F746A0  bit 0,(0x11b1)
	jrl	z, Smf_WriteFile_Loop6	; F746A4  jrl Z,0xf73efe
Smf_WriteFile_Skip46:
	ld	w, 93:opc	; F746A7  ld W,0x5d
	ld	l, (4508:16)	; F746A9  ld L,(0x119c)
	jr	Smf_WriteFile_Join7	; F746AD  jr T,0xf74713
Smf_WriteFile_Skip47:
	bit	0, (0x133e:16)	; F746AF  bit 0,(0x133e)
	jr	z, Smf_WriteFile_Skip48	; F746B3  jr Z,0xf746bc
	bit	0, (0x11b1:16)	; F746B5  bit 0,(0x11b1)
	jrl	z, Smf_WriteFile_Loop6	; F746B9  jrl Z,0xf73efe
Smf_WriteFile_Skip48:
	ld	w, 94:opc	; F746BC  ld W,0x5e
	ld	l, (4508:16)	; F746BE  ld L,(0x119c)
	jr	Smf_WriteFile_Join7	; F746C2  jr T,0xf74713
	ld	bc, (4508:16)	; F746C4  ld BC,(0x119c)
	bit	3, b	; F746C8  bit 0x03,B
	jrl	z, Smf_WriteFile_Loop6	; F746CB  jrl Z,0xf73efe
	bit	0, (0x133e:16)	; F746CE  bit 0,(0x133e)
	jr	z, Smf_WriteFile_Skip49	; F746D2  jr Z,0xf746db
	bit	0, (0x11b1:16)	; F746D4  bit 0,(0x11b1)
	jrl	z, Smf_WriteFile_Loop6	; F746D8  jrl Z,0xf73efe
Smf_WriteFile_Skip49:
	ld	w, 64:opc	; F746DB  ld W,0x40
	ld	l, 0:opc	; F746DD  ld L,0x00
	bit	3, c	; F746DF  bit 0x03,C
	jr	z, Smf_WriteFile_Join7	; F746E2  jr Z,0xf74713
	ld	l, 127:opc	; F746E4  ld L,0x7f
	jr	Smf_WriteFile_Join7	; F746E6  jr T,0xf74713
Smf_WriteFile_Skip50:
	ld	w, 91:opc	; F746E8  ld W,0x5b
	ld	l, 0:opc	; F746EA  ld L,0x00
	bit	0, (0x133e:16)	; F746EC  bit 0,(0x133e)
	jr	z, Smf_WriteFile_Skip51	; F746F0  jr Z,0xf746f9
	bit	0, (0x11b1:16)	; F746F2  bit 0,(0x11b1)
	jrl	z, Smf_WriteFile_Loop6	; F746F6  jrl Z,0xf73efe
Smf_WriteFile_Skip51:
	ld	l, (4508:16)	; F746F9  ld L,(0x119c)
	and	l, 127	; F746FD  and L,0x7f
	jr	Smf_WriteFile_Join7	; F74700  jr T,0xf74713
Smf_WriteFile_Skip52:
	bit	0, (0x133e:16)	; F74702  bit 0,(0x133e)
	jr	z, Smf_WriteFile_Skip53	; F74706  jr Z,0xf7470f
	bit	0, (0x11b1:16)	; F74708  bit 0,(0x11b1)
	jrl	z, Smf_WriteFile_Loop6	; F7470C  jrl Z,0xf73efe
Smf_WriteFile_Skip53:
	ld	l, (4508:16)	; F7470F  ld L,(0x119c)
Smf_WriteFile_Join7:
	ld	c, (4505:16)	; F74713  ld C,(0x1199)
	pushw	wa	; F74717  push WA
	pushw	hl	; F74718  push HL
	calr	SmfWrite_EncodeDeltaTime	; F74719  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F7471C  calr 0xf74bf6
	popw	hl	; F7471F  pop HL
	popw	wa	; F74720  pop WA
	cp	(0x1238:16), 0x03	; F74721  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74726  jrl NZ,0xf747dc
	calr	SmfWrite_WriteChannelEvent	; F74729  calr 0xf74ac5
	cp	(0x1238:16), 0x03	; F7472C  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74731  jrl NZ,0xf747dc
	jrl	Smf_WriteFile_Loop6	; F74734  jrl T,0xf73efe
Smf_WriteFile_Skip54:
	jrl	Smf_WriteFile_Loop6	; F74737  jrl T,0xf73efe
Smf_WriteFile_Skip55:
	ld	c, 0:opc	; F7473A  ld C,0x00
	calr	SmfWrite_EncodeDeltaTime	; F7473C  calr 0xf74a74
	calr	SmfWrite_AgePendingNoteOffs	; F7473F  calr 0xf74bf6
	cp	(0x1238:16), 0x03	; F74742  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74747  jrl NZ,0xf747dc
	ld	a, 255:opc	; F7474A  ld A,0xff
	ld	w, 47:opc	; F7474C  ld W,0x2f
	ld	l, 0:opc	; F7474E  ld L,0x00
	calr	SmfWrite_WriteChannelEvent	; F74750  calr 0xf74ac5
	cp	(0x1238:16), 0x03	; F74753  cp (0x1238),0x03
	jrl	nz, Smf_WriteFile_Join10	; F74758  jrl NZ,0xf747dc
	cpw	(SmfOut_WindowsFlushed:16), 0x0000	; F7475B  cp (0x126c),0x0000
	jr	nz, Smf_WriteFile_Skip56	; F74761  jr NZ,0xf74772
	call	SmfWrite_CreateFileWithFirstWindow	; F74763  call 0xf765e6
	ld	w, a	; F74767  ld W,A
	ld	(4664:16), w	; F74769  ld (0x1238),W
	cp	w, 3:i3	; F7476D  cp W,3
	jrl	nz, Smf_WriteFile_Join10	; F7476F  jrl NZ,0xf747dc
Smf_WriteFile_Skip56:
	calr	SmfWrite_WriteLastWindowAndClose	; F74772  calr 0xf7666f
	calr	SmfWrite_RestoreSongFromTempFile	; F74775  calr 0xf748f0
	ld	(UI_StatusCode:16), 35	; F74778  ld (0x2880),0x23
	call	T_MessageScreen_Paint	; F7477D  call 0xf41600
	calr	Smf_BusyDelay	; F74781  calr 0xf72f20
	ld	(UI_ScreenPage:16), 0	; F74784  ld (0x2229),0x00
	or	(0x34d4:16), 0x10	; F74789  or (0x34d4),0x10
Smf_WriteFile_Join8:
	jr	Smf_WriteFile_Join11	; F7478E  jr T,0xf747fa
Smf_WriteFile_Join9:
	cp	(UI_StatusCode:16), 0x02	; F74790  cp (0x2880),0x02
	jr	z, Smf_WriteFile_Skip57	; F74795  jr Z,0xf747c3
	ld	xiy, Data_F73844 + 0x10	; F74797  ld XIY,0x00f73854
	ld	xix, Disk_FileName	; F7479C  ld XIX,0x000021c8
	ldw	bc, 8	; F747A1  ld BC,0x0008
	ldir85	; F747A4  ldir
	ld	(Disk_FileName+8:16), 63	; F747A6  ld (0x21d0),0x3f
	ld	(Disk_FileName+9:16), 63	; F747AB  ld (0x21d1),0x3f
	ld	(Disk_FileName+10:16), 63	; F747B0  ld (0x21d2),0x3f
	ld	l, (UI_StatusCode:16)	; F747B5  ld L,(0x2880)
	pushw	hl	; F747B9  push HL
	call	T_DiskApi_DeleteFile_Call	; F747BA  call 0xf425b0
	popw	hl	; F747BE  pop HL
	ld	(UI_StatusCode:16), l	; F747BF  ld (0x2880),L
Smf_WriteFile_Skip57:
	calr	SmfWrite_RestoreFileName	; F747C3  calr 0xf7491f
	ld	(UI_ScreenPage:16), 0	; F747C6  ld (0x2229),0x00
	jr	Smf_WriteFile_Join11	; F747CB  jr T,0xf747fa
Smf_WriteFile_Loop9:
	calr	SmfWrite_RestoreSongFromTempFile	; F747CD  calr 0xf748f0
	ld	(UI_StatusCode:16), 30	; F747D0  ld (0x2880),0x1e
	ld	(UI_ScreenPage:16), 0	; F747D5  ld (0x2229),0x00
	jr	Smf_WriteFile_Join11	; F747DA  jr T,0xf747fa
Smf_WriteFile_Join10:
	cp	(0x1238:16), 0x07	; F747DC  cp (0x1238),0x07
	jr	z, Smf_WriteFile_Loop9	; F747E1  jr Z,0xf747cd
	ld	l, (4664:16)	; F747E3  ld L,(0x1238)
	calr	Smf_ResultToStatusCode	; F747E7  calr 0xf72f2d
	pushw	hl	; F747EA  push HL
	calr	SmfWrite_RestoreSongFromTempFile	; F747EB  calr 0xf748f0
	popw	hl	; F747EE  pop HL
	ld	(UI_StatusCode:16), l	; F747EF  ld (0x2880),L
	jr	Smf_WriteFile_Join11	; F747F3  jr T,0xf747fa
Smf_WriteFile_Skip58:
	ld	(UI_ScreenPage:16), 2	; F747F5  ld (0x2229),0x02
Smf_WriteFile_Join11:
	and	(0x21e8:16), 0x7f	; F747FA  and (0x21e8),0x7f
	popw	wa	; F747FF  pop WA
	ld	(Disk_ContentType:16), a	; F74800  ld (0x2725),A
	and	(UI_Request_Hi:16), 0xfd	; F74804  and (0x2071),0xfd
	ret	; F74809  ret

; --------------------------------------------------------------------------
; RamPtrTable_F7480A -- 16 32-bit words, every one below 0x10000, i.e. a
;                       16-bit RAM address stored one per long word.  First
;                       0x76A2, LAST 0x7AA2; the step between neighbours
;                       takes 2 distinct values (0x40 0x80).
; Read by: nothing in prom_a or prom_b spells this address as a 32-bit word,
;          so whatever reaches it computes the address
; Entry count: 16.  The chain stops at the first word that is not below
;              0x10000, at 0xF7484A.
; Evidence: every word is re-read and range-asserted on every emit.  The
;           RAMTAB rule fires ZERO times over the proven prom_b instruction
;           text (`python3 notes/prom_b_f6d002_layout.py --null-ptr`).
; Unknown: what lives at those RAM addresses.  The name describes the
;          CONTENT of the table, not its purpose.
; --------------------------------------------------------------------------
RamPtrTable_F7480A:
	.long	0x000076A2	; F7480A  [0] -> RAM 0x76A2
	.long	0x000076E2	; F7480E  [1] -> RAM 0x76E2
	.long	0x00007722	; F74812  [2] -> RAM 0x7722
	.long	0x00007762	; F74816  [3] -> RAM 0x7762
	.long	0x000077A2	; F7481A  [4] -> RAM 0x77A2
	.long	0x000077E2	; F7481E  [5] -> RAM 0x77E2
	.long	0x00007822	; F74822  [6] -> RAM 0x7822
	.long	0x00007862	; F74826  [7] -> RAM 0x7862
	.long	0x000078E2	; F7482A  [8] -> RAM 0x78E2
	.long	0x00007922	; F7482E  [9] -> RAM 0x7922
	.long	0x00007962	; F74832  [10] -> RAM 0x7962
	.long	0x000079A2	; F74836  [11] -> RAM 0x79A2
	.long	0x000079E2	; F7483A  [12] -> RAM 0x79E2
	.long	0x00007A22	; F7483E  [13] -> RAM 0x7A22
	.long	0x00007A62	; F74842  [14] -> RAM 0x7A62
	.long	0x00007AA2	; F74846  [15] -> RAM 0x7AA2


; --------------------------------------------------------------------------
; ByteMap_F7484A -- 33 bytes: a BYTE MAP.  0 of them are 0xFF and the other
;                   33 ASCEND STRICTLY, 0x00 to 0x7F, with jumps.  The name
;                   describes the CONTENT; what the two index spaces are is
;                   not established here.
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XIX,0x00f7484a` at
;          0xF741B4 (operand field 1 byte in)
; Entry count: 33 bytes.  The run is trimmed of trailing 0xFF, so it claims
;              no padding it did not earn; the byte before it is 0x00 and
;              the LAST byte of it is 0x7F.
; Evidence: every non-0xFF byte is compared with its predecessor on every
;           emit, WITHIN EACH of the 1 maximal ascending runs the rule
;           returns, and the runs are asserted to tile this segment exactly.
;           The BYTEMAP rule fires ZERO times over the proven prom_b
;           instruction text at (16 bytes, 12 values) and also at (20,14),
;           (24,16) and (16,16) (`python3 notes/prom_b_f6d002_layout.py
;           --null-ptr`).
; Unknown: what the two index spaces ARE, and who reads it.
; --------------------------------------------------------------------------
ByteMap_F7484A:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F7484A  [0..15]
	.byte	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F	; F7485A  [16..31]
	.byte	0x7F	; F7486A  [32..32]


; --------------------------------------------------------------------------
; Smf_WriteFile_Nop
; Called from: in-module: 0xF73EB8
; Touches: nothing with an absolute address
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7486B is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Purpose: none -- the entry is a lone `ret`.  Named Smf_WriteFile_Nop after what reaches it
;          (was sub_F7486B; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
Smf_WriteFile_Nop:
	ret	; F7486B  ret

; --------------------------------------------------------------------------
; Data_F7486C -- 25 bytes this block could not split.  No content rule
;                framed it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or
;                ASCII -- and the code walk never reached it from a thunk
;                slot, a proven call site, an opcode-anchored call or an
;                entry of a table the firmware transfers to.  So it is
;                emitted as bytes rather than guessed.
; ⚠ these bytes DO decode cleanly as instructions, but the decode does not
;   end in a `ret`/`reti`/unconditional transfer.  That is not evidence:
;   round 4's rule, which accepted a run on a clean decode alone, accepts
;   13.9% of record-aligned chunks of PROVEN display-list data as code
;   (`python3 notes/prom_b_f6d002_layout.py --null-accept`).
; Contains: printable bytes |....<D}H......'\....@@``.|
; Read by: nothing in prom_a or prom_b spells this address as a 32-bit word,
;          so whatever reaches it computes the address
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; Unknown: everything about it except its bytes.
; --------------------------------------------------------------------------
Data_F7486C:
	.byte	0xCB, 0x8F, 0xCE, 0xD6, 0x3C, 0x44, 0x7D, 0x48, 0xF7, 0x00, 0xC3, 0x07, 0xF0, 0xEC, 0x27, 0x5C	; F7486C  [0..15]
	.byte	0x0E, 0x00, 0x00, 0x00, 0x40, 0x40, 0x60, 0x60, 0x7F	; F7487C  [16..24]


; --------------------------------------------------------------------------
; MidiFileList_CheckSelectedEntryBlank
; Called from: in-module: 0xF738EF
; Touches: (0x2724)  |  0x60A480
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF74885 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MidiFileList_CheckSelectedEntryBlank: A := 0 when the 8 name bytes of MIDI-file list entry Disk_SelectedEntry
;   (0x60A480 + 8*n) are all spaces (a free slot), else 0xFE. Smf_WriteFile calls it when the file name is not in the
;   list; non-zero sends the save to UI_ScreenPage 2, the pass that deletes the listed file before writing. Basis:
;   caller + body. (notes/naming-pilot-2026-10-06/proposals_wave6_v.json)
MidiFileList_CheckSelectedEntryBlank:
	push	xbc	; F74885  push XBC
	push	xix	; F74886  push XIX
	ld	xix, 6333568	; F74887  ld XIX,0x0060a480
	xor	xwa, xwa	; F7488C  xor XWA,XWA
	ld	a, (Disk_SelectedEntry:16)	; F7488E  ld A,(0x2724)
	sla	xwa, 3	; F74892  sla 0x03,XWA
	add	xix, xwa	; F74895  add XIX,XWA
	ld	c, 8:opc	; F74897  ld C,0x08
	ld	a, 0:opc	; F74899  ld A,0x00
	cp	(xix+), 32	; F7489B  cp (XIX+),0x20
	jr	nz, MidiFileList_CheckSelectedEntryBlank_Skip	; F7489F  jr NZ,0xf748a6
	djnz8	c, -9	; F748A1  djnz C,0xf7489b
	jr	MidiFileList_CheckSelectedEntryBlank_Epilogue	; F748A4  jr T,0xf748aa
MidiFileList_CheckSelectedEntryBlank_Skip:
	ld	a, 254:opc	; F748A6  ld A,0xfe
	jr	MidiFileList_CheckSelectedEntryBlank_Epilogue	; F748A8  jr T,0xf748aa
MidiFileList_CheckSelectedEntryBlank_Epilogue:
	pop	xix	; F748AA  pop XIX
	pop	xbc	; F748AB  pop XBC
	ret	; F748AC  ret

; --------------------------------------------------------------------------
; MidiFileList_FindFileName
; Called from: in-module: 0xF738E7
; Touches: (0x2724)  |  0x60A480
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF748AD is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MidiFileList_FindFileName: Searches the 100 eight-byte names of the MIDI-file list at 0x60A480 for Disk_FileName's
;   first 8 characters: found -> Disk_SelectedEntry := its index, W = 0xFF; else W = 0. Smf_WriteFile's first check on
;   a fresh save: a hit sends it to UI_ScreenPage 2, the pass that deletes that file before writing. Basis: caller +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave6_v.json)
MidiFileList_FindFileName:
	push	xhl	; F748AD  push XHL
	pushw	bc	; F748AE  push BC
	push	xiy	; F748AF  push XIY
	push	xix	; F748B0  push XIX
	xor	bc, bc	; F748B1  xor BC,BC
	xor	w, w	; F748B3  xor W,W
MidiFileList_FindFileName_Loop:
	ld	xix, 6333568	; F748B5  ld XIX,0x0060a480
	ld	hl, bc	; F748BA  ld HL,BC
	sla	hl, 3	; F748BC  sla 0x03,HL
	lda	xix, (xix+hl)	; F748BF  lda XIX,XIX+HL
	ld	xiy, Disk_FileName	; F748C4  ld XIY,0x000021c8
	xor	hl, hl	; F748C9  xor HL,HL
MidiFileList_FindFileName_Loop2:
	ld	a, (xiy+)	; F748CB  ld A,(XIY+)
	cp	a, (xix)	; F748CE  cp A,(XIX)
	jr	nz, MidiFileList_FindFileName_Skip	; F748D0  jr NZ,0xf748e2
	inc	1, xix	; F748D2  inc 1,XIX
	inc	1, l	; F748D4  inc 1,L
	cp	l, 7:i3	; F748D6  cp L,7
	jr	ule, MidiFileList_FindFileName_Loop2	; F748D8  jr ULE,0xf748cb
	ld	(Disk_SelectedEntry:16), c	; F748DA  ld (0x2724),C
	ld	w, 255:opc	; F748DE  ld W,0xff
	jr	MidiFileList_FindFileName_Epilogue	; F748E0  jr T,0xf748eb
MidiFileList_FindFileName_Skip:
	inc	1, c	; F748E2  inc 1,C
	cp	c, 99	; F748E4  cp C,0x63
	jr	ule, MidiFileList_FindFileName_Loop	; F748E7  jr ULE,0xf748b5
	xor	w, w	; F748E9  xor W,W
MidiFileList_FindFileName_Epilogue:
	pop	xix	; F748EB  pop XIX
	pop	xiy	; F748EC  pop XIY
	popw	bc	; F748ED  pop BC
	pop	xhl	; F748EE  pop XHL
	ret	; F748EF  ret

; --------------------------------------------------------------------------
; SmfWrite_RestoreSongFromTempFile
; Called from: in-module: 0xF74775 0xF747CD 0xF747EB
; Touches: (0x21D0) (0x21D1) (0x21D2) (0x2725)
; Calls:   T_DiskLoadFile_Execute T_DiskApi_DeleteFile_Call SmfWrite_RestoreFileName
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF748F0 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_RestoreSongFromTempFile: Disk_FileName := "_ZZZZZZZ" + "SEQ" (Data_F73844+0x10), Disk_ContentType := 1
;   (sequencer), T_DiskLoadFile_Execute (prom_a DiskLoadFile_Execute -> DiskLoadFile_SendSongSelectAndLoad -> DiskLoad_ByContentType) reloads the song Smf_WriteFile
;   saved there before its destructive track merge; then extension '???', T_DiskApi_DeleteFile_Call deletes the temp
;   file and SmfWrite_RestoreFileName restores the user's name. Smf_WriteFile runs it on success and on both error
;   exits. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
SmfWrite_RestoreSongFromTempFile:
	ld	xiy, Data_F73844 + 0x10	; F748F0  ld XIY,0x00f73854
	ld	xix, Disk_FileName	; F748F5  ld XIX,0x000021c8
	ldw	bc, 11	; F748FA  ld BC,0x000b
	ldir85	; F748FD  ldir
	ld	(Disk_ContentType:16), 1	; F748FF  ld (0x2725),0x01
	call	T_DiskLoadFile_Execute	; F74904  call 0xf425c8
	ld	(Disk_FileName+8:16), 63	; F74908  ld (0x21d0),0x3f
	ld	(Disk_FileName+9:16), 63	; F7490D  ld (0x21d1),0x3f
	ld	(Disk_FileName+10:16), 63	; F74912  ld (0x21d2),0x3f
	call	T_DiskApi_DeleteFile_Call	; F74917  call 0xf425b0
	calr	SmfWrite_RestoreFileName	; F7491B  calr 0xf7491f
	ret	; F7491E  ret

; --------------------------------------------------------------------------
; SmfWrite_RestoreFileName
; Called from: in-module: 0xF7393C 0xF747C3 0xF7491B 0xF74BEE
; Touches: nothing with an absolute address
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7491F is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_RestoreFileName: copy A of prom_b's SMF writer (Smf_WriteFile's writing pass), role RestoreFileName as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWrite_RestoreFileName:
	ld	xiy, 4666	; F7491F  ld XIY,0x0000123a
	ld	xix, Disk_FileName	; F74924  ld XIX,0x000021c8
	ldw	bc, 4	; F74929  ld BC,0x0004
	ldirw	; F7492C  ldirw
	ret	; F7492E  ret

; --------------------------------------------------------------------------
; SmfWrite_SaveFileName
; Called from: in-module: 0xF73914 0xF74BBB
; Touches: nothing with an absolute address
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7492F is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_SaveFileName: copy A of prom_b's SMF writer (Smf_WriteFile's writing pass), role SaveFileName as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWrite_SaveFileName:
	ld	xiy, Disk_FileName	; F7492F  ld XIY,0x000021c8
	ld	xix, 4666	; F74934  ld XIX,0x0000123a
	ldw	bc, 4	; F74939  ld BC,0x0004
	ldirw	; F7493C  ldirw
	ret	; F7493E  ret
; --------------------------------------------------------------------------
; SmfFileTemplate_F7493F -- the 33-byte STANDARD MIDI FILE header this
;          firmware copies into its output buffer before writing a track.
;          Named 2026-08-31 by notes/prom_b_apply_smf_names.py, on
;          notes/prom_b_smf_reader.py's 40 checks.
;          ⚠ NOT MUSIC: no note, no end-of-track.
; ⚠ CORRECTED 2026-09-02: that pass called the object 99 bytes and 32 of
;                         them the header. It is 33 bytes of header
;                         (14+8+11, the three block moves) and then a
;                         SEPARATE 66-byte word table -- see
;                         SmfPartOffsets_F74960 below, which retires this
;                         header's standing `Unknown: what the 0x40-strided
;                         bytes after offset 0x21 are`.
; Read by: `ld XIY,0x00F7493F` at 0xF73A23, and the image spells +0x0E and
;          +0x16 as well -- the three copy sources. 14+8+11 = 33 = 0x21,
;          which is where the table starts.
; Length:  the `00 00 00 00` at +0x12 is a PLACEHOLDER; 0xF7789A computes
;          the real value into (0x10C4)-(0x10C7), most significant byte
;          first. ★ Copy 0xF7493F PROVES it: at +0x0E it runs `ldir` with
;          BC=4 -- `MTrk` only -- and then writes (0x10C4) and (0x10C6) into
;          the file in the placeholder's place.
; Evidence: notes/gen_prom_b_smf_writer_module.py --selftest.
; --------------------------------------------------------------------------
SmfFileTemplate_F7493F:
	.ascii	"MThd"	; F7493F  header chunk tag
	.byte	0x00, 0x00, 0x00, 0x06	; F74943  chunk length 6, most significant byte first
	.byte	0x00, 0x00	; F74947  format 0 -- one multi-channel track
	.byte	0x00, 0x01	; F74949  ntrks 1
	.byte	0x00, 0x60	; F7494B  division 0x0060 = 96 ticks per quarter note
	.ascii	"MTrk"	; F7494D  track chunk tag
	.byte	0x00, 0x00, 0x00, 0x00	; F74951  track length PLACEHOLDER -- backfilled by 0xF7789A
	.byte	0x00	; F74955  delta time 0
	.byte	0xFF, 0x03	; F74956  meta event FF 03 -- sequence/track name
	.byte	0x0F	; F74958  ... declared length 15
	.ascii	"WSA    "	; F74959  name bytes 1-7; 8-15 come from RAM (0x21C8)

; --------------------------------------------------------------------------
; SmfPartOffsets_F74960 -- 32 little-endian 16-bit BYTE OFFSETS and a
;          0xFFFF terminator.  NOT MIDI, and not part of the file: it only
;          happens to sit 0x21 bytes after the template.
;          0x0000, 0x0040 ... 0x0800, step 0x40 -- one record per slot in the
;          0x40-strided array at RAM 0x006036A0.
; Read by: five instructions spell 0x00F74960: 0xF76FB9 is `ld XDE,<base>`
;          followed by `ld HL,(XDE+HL)` with HL = (byte from RAM 0x603422) *
;          2, and the result reaches `lda XIY,XIY+HL` on XIY = 0x006036A0.
; ⚠ Note:  the step is 0x40 everywhere EXCEPT between slots 7 and 8, where
;          it is 0x80: the record at 0x0200 is skipped. That is in the ROM
;          and identical in all four copies. What occupies the skipped slot
;          is NOT established.
; --------------------------------------------------------------------------
SmfPartOffsets_F74960:
	.short	0x0000, 0x0040, 0x0080, 0x00C0, 0x0100, 0x0140, 0x0180, 0x01C0	; F74960  slots  0- 7
	.short	0x0240, 0x0280, 0x02C0, 0x0300, 0x0340, 0x0380, 0x03C0, 0x0400	; F74970  slots  8-15
	.short	0x0440, 0x0480, 0x04C0, 0x0500, 0x0540, 0x0580, 0x05C0, 0x0600	; F74980  slots 16-23
	.short	0x0640, 0x0680, 0x06C0, 0x0700, 0x0740, 0x0780, 0x07C0, 0x0800	; F74990  slots 24-31
	.short	0xFFFF	; F749A0  terminator


; --------------------------------------------------------------------------
; SmfWrite_StageTempoFromBpm
; Called from: in-module: 0xF73ABB 0xF73FDB
; Touches: (0x108C) (0x108E)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF749A2 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_StageTempoFromBpm: copy A of prom_b's SMF writer (Smf_WriteFile's writing pass), role StageTempoFromBpm as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWrite_StageTempoFromBpm:
	ldw	de, 9	; F749A2  ld DE,0x0009
	ldw	wa, 10176	; F749A5  ld WA,0x27c0
	ld	qwa, de	; F749A8  ld QWA,DE
	div	xwa, hl	; F749AB  div XWA,HL
	ld	de, qwa	; F749AD  ld DE,QWA
	ldw	hl, 100	; F749B0  ld HL,0x0064
	xor	de, de	; F749B3  xor DE,DE
	extz	xwa	; F749B5  extz XWA
	muls	xwa, hl	; F749B7  muls XWA,HL
	ld	de, qwa	; F749B9  ld DE,QWA
	ld	(SmfOut_Tempo:16), wa	; F749BC  ld (0x108c),WA
	ld	(SmfOut_Tempo+2:16), de	; F749C0  ld (0x108e),DE
	ret	; F749C4  ret

; --------------------------------------------------------------------------
; SmfWrite_WriteTempoEvent
; Called from: in-module: 0xF73ABE 0xF73FDE
; Touches: (0x1088) (0x108C) (0x108D) (0x108E) (0x1238)
; Calls:   SmfWrite_CommitOutputByte
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF749C5 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_WriteTempoEvent: Writes an SMF Set Tempo event through SmfWrite_CommitOutputByte: the delta-time bytes in
;   Smf_VlqBytes (up to the first byte with bit 7 clear), then FF 51 03 and SmfOut_Tempo+2, +1, +0 (most significant
;   first); stops when (0x1238) is no longer 3. Copy A of SmfSize_WriteTempoEvent; Smf_WriteFile calls it after
;   SmfWrite_StageTempoFromBpm. Basis: caller + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
SmfWrite_WriteTempoEvent:
	ld	xiy, Smf_VlqBytes	; F749C5  ld XIY,0x00001193
	ld	xix, (InputStream_Cursor:16)	; F749CA  ld XIX,(0x1088)
SmfWrite_WriteTempoEvent_Loop:
	ld	a, (xiy+)	; F749CE  ld A,(XIY+)
	ld	(xix+), a	; F749D1  ld (XIX+),A
	pushw	wa	; F749D4  push WA
	push	xiy	; F749D5  push XIY
	calr	SmfWrite_CommitOutputByte	; F749D6  calr 0xf74b3a
	pop	xiy	; F749D9  pop XIY
	popw	wa	; F749DA  pop WA
	cp	(0x1238:16), 0x03	; F749DB  cp (0x1238),0x03
	jrl	nz, SmfWrite_WriteTempoEvent_Return	; F749E0  jrl NZ,0xf74a65
	ld	xix, (InputStream_Cursor:16)	; F749E3  ld XIX,(0x1088)
	bit	7, a	; F749E7  bit 0x07,A
	jr	nz, SmfWrite_WriteTempoEvent_Loop	; F749EA  jr NZ,0xf749ce
	ld	a, 255:opc	; F749EC  ld A,0xff
	ld	(xix+), a	; F749EE  ld (XIX+),A
	calr	SmfWrite_CommitOutputByte	; F749F1  calr 0xf74b3a
	cp	(0x1238:16), 0x03	; F749F4  cp (0x1238),0x03
	jrl	nz, SmfWrite_WriteTempoEvent_Return	; F749F9  jrl NZ,0xf74a65
	ld	xix, (InputStream_Cursor:16)	; F749FC  ld XIX,(0x1088)
	ld	a, 81:opc	; F74A00  ld A,0x51
	ld	(xix+), a	; F74A02  ld (XIX+),A
	calr	SmfWrite_CommitOutputByte	; F74A05  calr 0xf74b3a
	cp	(0x1238:16), 0x03	; F74A08  cp (0x1238),0x03
	jr	nz, SmfWrite_WriteTempoEvent_Return	; F74A0D  jr NZ,0xf74a65
	ld	xix, (InputStream_Cursor:16)	; F74A0F  ld XIX,(0x1088)
	ld	a, 3:opc	; F74A13  ld A,0x03
	ld	(xix+), a	; F74A15  ld (XIX+),A
	calr	SmfWrite_CommitOutputByte	; F74A18  calr 0xf74b3a
	cp	(0x1238:16), 0x03	; F74A1B  cp (0x1238),0x03
	jr	nz, SmfWrite_WriteTempoEvent_Return	; F74A20  jr NZ,0xf74a65
	ld	xix, (InputStream_Cursor:16)	; F74A22  ld XIX,(0x1088)
	ld	a, (SmfOut_Tempo+2:16)	; F74A26  ld A,(0x108e)
	ld	(xix+), a	; F74A2A  ld (XIX+),A
	calr	SmfWrite_CommitOutputByte	; F74A2D  calr 0xf74b3a
	cp	(0x1238:16), 0x03	; F74A30  cp (0x1238),0x03
	jr	nz, SmfWrite_WriteTempoEvent_Return	; F74A35  jr NZ,0xf74a65
	ld	xix, (InputStream_Cursor:16)	; F74A37  ld XIX,(0x1088)
	ld	a, (SmfOut_Tempo+1:16)	; F74A3B  ld A,(0x108d)
	ld	(xix+), a	; F74A3F  ld (XIX+),A
	calr	SmfWrite_CommitOutputByte	; F74A42  calr 0xf74b3a
	cp	(0x1238:16), 0x03	; F74A45  cp (0x1238),0x03
	jr	nz, SmfWrite_WriteTempoEvent_Return	; F74A4A  jr NZ,0xf74a65
	ld	xix, (InputStream_Cursor:16)	; F74A4C  ld XIX,(0x1088)
	ld	a, (SmfOut_Tempo:16)	; F74A50  ld A,(0x108c)
	ld	(xix+), a	; F74A54  ld (XIX+),A
	calr	SmfWrite_CommitOutputByte	; F74A57  calr 0xf74b3a
	cp	(0x1238:16), 0x03	; F74A5A  cp (0x1238),0x03
	jr	nz, SmfWrite_WriteTempoEvent_Return	; F74A5F  jr NZ,0xf74a65
	ld	xix, (InputStream_Cursor:16)	; F74A61  ld XIX,(0x1088)
SmfWrite_WriteTempoEvent_Return:
	ret	; F74A65  ret

; --------------------------------------------------------------------------
; SmfWrite_WriteControlChange
; Called from: in-module: 0xF7422F 0xF74251
; Touches: (0x119A)
; Calls:   SmfWrite_WriteChannelEvent
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF74A66 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_WriteControlChange: copy A of prom_b's SMF writer (Smf_WriteFile's writing pass), role WriteControlChange as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWrite_WriteControlChange:
	ld	a, (4506:16)	; F74A66  ld A,(0x119a)
	and	a, 15	; F74A6A  and A,0x0f
	or	a, 176	; F74A6D  or A,0xb0
	calr	SmfWrite_WriteChannelEvent	; F74A70  calr 0xf74ac5
	ret	; F74A73  ret

; --------------------------------------------------------------------------
; SmfWrite_EncodeDeltaTime
; Called from: in-module: 0xF73FA9 0xF73FE9 0xF7401C 0xF7404F 0xF74085
;              0xF740DA 0xF7415D 0xF74316 +12 more
; Touches: (0x107E) (0x1082) (0x1090) (0x11AA) (0x11AC) (0x1268) (0x133E)
; Calls:   SmfWrite_EncodeVlq
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF74A74 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_EncodeDeltaTime: copy A of prom_b's SMF writer (Smf_WriteFile's writing pass), role EncodeDeltaTime as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWrite_EncodeDeltaTime:
	pushw	wa	; F74A74  push WA
	push	xhl	; F74A75  push XHL
	pushw	de	; F74A76  push DE
	xor	wa, wa	; F74A77  xor WA,WA
	ld	(4522:16), wa	; F74A79  ld (0x11aa),WA
	ld	(4524:16), a	; F74A7D  ld (0x11ac),A
	ld	wa, (4222:16)	; F74A81  ld WA,(0x107e)
	xor	b, b	; F74A85  xor B,B
	add	wa, bc	; F74A87  add WA,BC
	ld	de, (4226:16)	; F74A89  ld DE,(0x1082)
	sub	wa, de	; F74A8D  sub WA,DE
	ld	(4522:16), wa	; F74A8F  ld (0x11aa),WA
	bit	0, (0x1268:16)	; F74A93  bit 0,(0x1268)
	jr	nz, SmfWrite_EncodeDeltaTime_Skip2	; F74A97  jr NZ,0xf74ab6
	bit	1, (0x133e:16)	; F74A99  bit 1,(0x133e)
	jr	z, SmfWrite_EncodeDeltaTime_Skip2	; F74A9D  jr Z,0xf74ab6
	addw	(0x11aa:16), 0x0180	; F74A9F  add (0x11aa),0x0180
	bit	0, (0x133e:16)	; F74AA5  bit 0,(0x133e)
	jr	z, SmfWrite_EncodeDeltaTime_Skip	; F74AA9  jr Z,0xf74ab1
	subw	(0x11aa:16), 0x0122	; F74AAB  sub (0x11aa),0x0122
SmfWrite_EncodeDeltaTime_Skip:
	ld	(4712:16), 1	; F74AB1  ld (0x1268),0x01
SmfWrite_EncodeDeltaTime_Skip2:
	ld	(4226:16), bc	; F74AB6  ld (0x1082),BC
	ld	(4240:16), de	; F74ABA  ld (0x1090),DE
	popw	de	; F74ABE  pop DE
	pop	xhl	; F74ABF  pop XHL
	popw	wa	; F74AC0  pop WA
	calr	SmfWrite_EncodeVlq	; F74AC1  calr 0xf74d99
	ret	; F74AC4  ret

; --------------------------------------------------------------------------
; SmfWrite_WriteChannelEvent
; Called from: in-module: 0xF73BF8 0xF73C10 0xF73C2F 0xF73C51 0xF73C71
;              0xF73C8C 0xF73CA6 0xF73CBB +48 more
; Touches: (0x1088) (0x1238)
; Calls:   SmfWrite_CommitOutputByte
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF74AC5 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_WriteChannelEvent: copy A of prom_b's SMF writer (Smf_WriteFile's writing pass), role WriteChannelEvent as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWrite_WriteChannelEvent:
	push	xiy	; F74AC5  push XIY
	ld	xix, (InputStream_Cursor:16)	; F74AC6  ld XIX,(0x1088)
	ld	xiy, Smf_VlqBytes	; F74ACA  ld XIY,0x00001193
	pushw	wa	; F74ACF  push WA
SmfWrite_WriteChannelEvent_Loop:
	ld	a, (xiy+)	; F74AD0  ld A,(XIY+)
	ld	(xix+), a	; F74AD3  ld (XIX+),A
	pushw	wa	; F74AD6  push WA
	pushw	hl	; F74AD7  push HL
	push	xiy	; F74AD8  push XIY
	calr	SmfWrite_CommitOutputByte	; F74AD9  calr 0xf74b3a
	pop	xiy	; F74ADC  pop XIY
	popw	hl	; F74ADD  pop HL
	popw	wa	; F74ADE  pop WA
	cp	(0x1238:16), 0x03	; F74ADF  cp (0x1238),0x03
	jr	z, SmfWrite_WriteChannelEvent_Skip	; F74AE4  jr Z,0xf74ae9
	popw	wa	; F74AE6  pop WA
	jr	SmfWrite_WriteChannelEvent_Join	; F74AE7  jr T,0xf74b34
SmfWrite_WriteChannelEvent_Skip:
	ld	xix, (InputStream_Cursor:16)	; F74AE9  ld XIX,(0x1088)
	bit	7, a	; F74AED  bit 0x07,A
	jr	nz, SmfWrite_WriteChannelEvent_Loop	; F74AF0  jr NZ,0xf74ad0
	popw	wa	; F74AF2  pop WA
	ld	h, a	; F74AF3  ld H,A
	ld	(xix+), a	; F74AF5  ld (XIX+),A
	pushw	wa	; F74AF8  push WA
	pushw	hl	; F74AF9  push HL
	calr	SmfWrite_CommitOutputByte	; F74AFA  calr 0xf74b3a
	popw	hl	; F74AFD  pop HL
	popw	wa	; F74AFE  pop WA
	cp	(0x1238:16), 0x03	; F74AFF  cp (0x1238),0x03
	jr	nz, SmfWrite_WriteChannelEvent_Join	; F74B04  jr NZ,0xf74b34
	ld	xix, (InputStream_Cursor:16)	; F74B06  ld XIX,(0x1088)
	ld	a, w	; F74B0A  ld A,W
	ld	(xix+), a	; F74B0C  ld (XIX+),A
	pushw	hl	; F74B0F  push HL
	calr	SmfWrite_CommitOutputByte	; F74B10  calr 0xf74b3a
	popw	hl	; F74B13  pop HL
	cp	(0x1238:16), 0x03	; F74B14  cp (0x1238),0x03
	jr	nz, SmfWrite_WriteChannelEvent_Join	; F74B19  jr NZ,0xf74b34
	ld	xix, (InputStream_Cursor:16)	; F74B1B  ld XIX,(0x1088)
	and	h, 240	; F74B1F  and H,0xf0
	cp	h, 192	; F74B22  cp H,0xc0
	jr	z, SmfWrite_WriteChannelEvent_Join	; F74B25  jr Z,0xf74b34
	cp	h, 208	; F74B27  cp H,0xd0
	jr	z, SmfWrite_WriteChannelEvent_Join	; F74B2A  jr Z,0xf74b34
	ld	a, l	; F74B2C  ld A,L
	ld	(xix+), a	; F74B2E  ld (XIX+),A
	calr	SmfWrite_CommitOutputByte	; F74B31  calr 0xf74b3a
SmfWrite_WriteChannelEvent_Join:
	pop	xiy	; F74B34  pop XIY
	ld	xix, (InputStream_Cursor:16)	; F74B35  ld XIX,(0x1088)
	ret	; F74B39  ret

; --------------------------------------------------------------------------
; SmfWrite_CommitOutputByte
; Called from: in-module: 0xF73AFE 0xF749D6 0xF749F1 0xF74A05 0xF74A18
;              0xF74A2D 0xF74A42 0xF74A57 +5 more
; Touches: (0x1088) (0x1238) (0x1248) (0x126C) (0x21D0) (0x21D1) (0x21D2)
;          (0x2724)  |  0x60A480 0x60A700 0x60AAFF
; Calls:   SmfWrite_CreateFileWithFirstWindow T_DiskProgress_PrintDotForSmf SmfWrite_WriteNextWindow SmfWrite_SaveFileName T_DiskApi_DeleteFile_Call SmfWrite_RestoreFileName
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF74B3A is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_CommitOutputByte: copy A of prom_b's SMF writer (Smf_WriteFile's writing pass), role CommitOutputByte as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWrite_CommitOutputByte:
	push	xhl	; F74B3A  push XHL
	pushw	bc	; F74B3B  push BC
	ld	(4664:16), 3	; F74B3C  ld (0x1238),0x03
	cp	xix, 6335231	; F74B41  cp XIX,0x0060aaff
	jr	ugt, SmfWrite_CommitOutputByte_Skip	; F74B47  jr UGT,0xf74b4f
	ld	(InputStream_Cursor:16), xix	; F74B49  ld (0x1088),XIX
	jr	SmfWrite_CommitOutputByte_Epilogue	; F74B4D  jr T,0xf74bb4
SmfWrite_CommitOutputByte_Skip:
	cpw	(SmfOut_WindowsFlushed:16), 0x0000	; F74B4F  cp (0x126c),0x0000
	jr	nz, SmfWrite_CommitOutputByte_Skip2	; F74B55  jr NZ,0xf74b6b
	ld	c, a	; F74B57  ld C,A
	pushw	bc	; F74B59  push BC
	call	SmfWrite_CreateFileWithFirstWindow	; F74B5A  call 0xf765e6
	popw	bc	; F74B5E  pop BC
	ld	w, a	; F74B5F  ld W,A
	ld	(4664:16), w	; F74B61  ld (0x1238),W
	cp	w, 3:i3	; F74B65  cp W,3
	jr	nz, SmfWrite_CommitOutputByte_Epilogue	; F74B67  jr NZ,0xf74bb4
	jr	SmfWrite_CommitOutputByte_Join	; F74B69  jr T,0xf74ba3
SmfWrite_CommitOutputByte_Skip2:
	ld	c, a	; F74B6B  ld C,A
	incw	1, (4680:16)	; F74B6D  incw 1,(0x1248)
	pushw	wa	; F74B71  push WA
	push	xhl	; F74B72  push XHL
	pushw	bc	; F74B73  push BC
	pushw	de	; F74B74  push DE
	ld	wa, (4680:16)	; F74B75  ld WA,(0x1248)
	xor	de, de	; F74B79  xor DE,DE
	ldw	hl, 4	; F74B7B  ld HL,0x0004
	ld	qwa, de	; F74B7E  ld QWA,DE
	div	xwa, hl	; F74B81  div XWA,HL
	ld	de, qwa	; F74B83  ld DE,QWA
	cp	de, 0:i3	; F74B86  cp DE,0
	jr	nz, SmfWrite_CommitOutputByte_Skip3	; F74B88  jr NZ,0xf74b90
	push	xix	; F74B8A  push XIX
	call	T_DiskProgress_PrintDotForSmf	; F74B8B  call 0xf42604
	pop	xix	; F74B8F  pop XIX
SmfWrite_CommitOutputByte_Skip3:
	popw	de	; F74B90  pop DE
	popw	bc	; F74B91  pop BC
	pop	xhl	; F74B92  pop XHL
	popw	wa	; F74B93  pop WA
	pushw	bc	; F74B94  push BC
	calr	SmfWrite_WriteNextWindow	; F74B95  calr 0xf76661
	popw	bc	; F74B98  pop BC
	ld	w, a	; F74B99  ld W,A
	ld	(4664:16), w	; F74B9B  ld (0x1238),W
	cp	w, 3:i3	; F74B9F  cp W,3
	jr	nz, SmfWrite_CommitOutputByte_Epilogue	; F74BA1  jr NZ,0xf74bb4
SmfWrite_CommitOutputByte_Join:
	incw	1, (SmfOut_WindowsFlushed:16)	; F74BA3  incw 1,(0x126c)
	ld	xwa, 6334208	; F74BA7  ld XWA,0x0060a700
	ld	(InputStream_Cursor:16), xwa	; F74BAC  ld (0x1088),XWA
	ld	xix, xwa	; F74BB0  ld XIX,XWA
	ld	a, c	; F74BB2  ld A,C
SmfWrite_CommitOutputByte_Epilogue:
	popw	bc	; F74BB4  pop BC
	pop	xhl	; F74BB5  pop XHL
	ret	; F74BB6  ret
	push	xix	; F74BB7  push XIX
	push	xiy	; F74BB8  push XIY
	push	xhl	; F74BB9  push XHL
	push	xbc	; F74BBA  push XBC
	calr	SmfWrite_SaveFileName	; F74BBB  calr 0xf7492f
	ld	xiy, 6333568	; F74BBE  ld XIY,0x0060a480
	ld	l, (Disk_SelectedEntry:16)	; F74BC3  ld L,(0x2724)
	xor	h, h	; F74BC7  xor H,H
	sla	hl, 3	; F74BC9  sla 0x03,HL
	lda	xiy, (xiy+hl)	; F74BCC  lda XIY,XIY+HL
	ld	xix, Disk_FileName	; F74BD1  ld XIX,0x000021c8
	ldw	bc, 4	; F74BD6  ld BC,0x0004
	ldirw	; F74BD9  ldirw
	ld	(Disk_FileName+8:16), 63	; F74BDB  ld (0x21d0),0x3f
	ld	(Disk_FileName+9:16), 63	; F74BE0  ld (0x21d1),0x3f
	ld	(Disk_FileName+10:16), 63	; F74BE5  ld (0x21d2),0x3f
	call	T_DiskApi_DeleteFile_Call	; F74BEA  call 0xf425b0
	calr	SmfWrite_RestoreFileName	; F74BEE  calr 0xf7491f
	pop	xbc	; F74BF1  pop XBC
	pop	xhl	; F74BF2  pop XHL
	pop	xiy	; F74BF3  pop XIY
	pop	xix	; F74BF4  pop XIX
	ret	; F74BF5  ret

; --------------------------------------------------------------------------
; SmfWrite_AgePendingNoteOffs
; Called from: in-module: 0xF73FAC 0xF73FEC 0xF7401F 0xF74052 0xF74088
;              0xF740DD 0xF74160 0xF74319 +12 more
; Touches: (0x107E) (0x1080) (0x11AA) (0x1238)
; Calls:   SmfWrite_ClearDueList SmfWrite_SortDueNoteOffs
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF74BF6 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_AgePendingNoteOffs: copy A of prom_b's SMF writer (Smf_WriteFile's writing pass), role AgePendingNoteOffs as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWrite_AgePendingNoteOffs:
	ld	(4664:16), 3	; F74BF6  ld (0x1238),0x03
	calr	SmfWrite_ClearDueList	; F74BFB  calr 0xf74e4c
	xor	hl, hl	; F74BFE  xor HL,HL
	xor	bc, bc	; F74C00  xor BC,BC
	xor	iy, iy	; F74C02  xor IY,IY
SmfWrite_AgePendingNoteOffs_Loop:
	push	xix	; F74C04  push XIX
	ld	xix, 12378	; F74C05  ld XIX,0x0000305a
	bit	7, (xix+hl)	; F74C0A  bit 7,(XIX+HL)
	pop	xix	; F74C0F  pop XIX
	jr	z, SmfWrite_AgePendingNoteOffs_Join	; F74C10  jr Z,0xf74c65
	push	xix	; F74C12  push XIX
	ld	xix, 12378	; F74C13  ld XIX,0x0000305a
	lda	xix, (xix+hl)	; F74C18  lda XIX,XIX+HL
	ld	wa, (xix+3)	; F74C1D  ld WA,(XIX+0x03)
	pop	xix	; F74C20  pop XIX
	cp	wa, (0x11aa:16)	; F74C21  cp WA,(0x11aa)
	jr	ule, SmfWrite_AgePendingNoteOffs_Skip	; F74C25  jr ULE,0xf74c3b
	sub	wa, (0x11aa:16)	; F74C27  sub WA,(0x11aa)
	push	xix	; F74C2B  push XIX
	ld	xix, 12378	; F74C2C  ld XIX,0x0000305a
	extz	xhl	; F74C31  extz XHL
	add	xix, xhl	; F74C33  add XIX,XHL
	ld	(xix+3), wa	; F74C35  ld (XIX+0x03),WA
	pop	xix	; F74C38  pop XIX
	jr	SmfWrite_AgePendingNoteOffs_Join	; F74C39  jr T,0xf74c65
SmfWrite_AgePendingNoteOffs_Skip:
	push	xde	; F74C3B  push XDE
	ld	xde, 4307	; F74C3C  ld XDE,0x000010d3
	ld	(xde+iy), c	; F74C41  ld (XDE+IY),C
	ld	xde, 12378	; F74C46  ld XDE,0x0000305a
	lda	xde, (xde+hl)	; F74C4B  lda XDE,XDE+HL
	ld	wa, (xde+3)	; F74C50  ld WA,(XDE+0x03)
	ld	xde, 4307	; F74C53  ld XDE,0x000010d3
	lda	xde, (xde+iy)	; F74C58  lda XDE,XDE+IY
	ld	(xde+1), wa	; F74C5D  ld (XDE+0x01),WA
	pop	xde	; F74C60  pop XDE
	add	iy, 3	; F74C61  add IY,0x0003
SmfWrite_AgePendingNoteOffs_Join:
	add	hl, 5	; F74C65  add HL,0x0005
	inc	1, bc	; F74C69  inc 1,BC
	cp	c, 32	; F74C6B  cp C,0x20
	jr	ule, SmfWrite_AgePendingNoteOffs_Loop	; F74C6E  jr ULE,0xf74c04
	srl	iy, 1	; F74C70  srl 0x01,IY
	cp	iy, 0:i3	; F74C73  cp IY,0
	jr	z, SmfWrite_AgePendingNoteOffs_Skip2	; F74C75  jr Z,0xf74c7a
	calr	SmfWrite_SortDueNoteOffs	; F74C77  calr 0xf74c87
SmfWrite_AgePendingNoteOffs_Skip2:
	ldw	(4222:16), 0	; F74C7A  ld (0x107e),0x0000
	ldw	(4224:16), 0	; F74C80  ld (0x1080),0x0000
	ret	; F74C86  ret

; --------------------------------------------------------------------------
; SmfWrite_SortDueNoteOffs
; Called from: in-module: 0xF74C77
; Touches: (0x10D3)
; Calls:   SmfWrite_WriteDueNoteOffs
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF74C87 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_SortDueNoteOffs: copy A of prom_b's SMF writer (Smf_WriteFile's writing pass), role SortDueNoteOffs as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWrite_SortDueNoteOffs:
	cp	iy, 0:i3	; F74C87  cp IY,0
	jr	z, SmfWrite_SortDueNoteOffs_Return	; F74C89  jr Z,0xf74cf1
	xor	de, de	; F74C8B  xor DE,DE
	cp	(0x10d3:16), 0xff	; F74C8D  cp (0x10d3),0xff
	jr	z, SmfWrite_SortDueNoteOffs_Return	; F74C92  jr Z,0xf74cf1
SmfWrite_SortDueNoteOffs_Loop:
	ld	xiy, 4307	; F74C94  ld XIY,0x000010d3
	ld	xix, 4310	; F74C99  ld XIX,0x000010d6
	lda	xiy, (xiy+de)	; F74C9E  lda XIY,XIY+DE
	lda	xix, (xix+de)	; F74CA3  lda XIX,XIX+DE
	cp	(xiy), 0xff	; F74CA8  cp (XIY),0xff
	jr	z, SmfWrite_SortDueNoteOffs_Skip3	; F74CAB  jr Z,0xf74cee
	ld	wa, (xiy+1)	; F74CAD  ld WA,(XIY+0x01)
SmfWrite_SortDueNoteOffs_Join:
	ld	l, (xix)	; F74CB0  ld L,(XIX)
	cp	l, 255	; F74CB2  cp L,0xff
	jr	z, SmfWrite_SortDueNoteOffs_Skip2	; F74CB5  jr Z,0xf74ce4
	cp	wa, (xix+1)	; F74CB7  cp WA,(XIX+0x01)
	jr	ugt, SmfWrite_SortDueNoteOffs_Skip	; F74CBA  jr UGT,0xf74ccc
	add	xix, 3	; F74CBC  add XIX,0x00000003
	cp	xix, 4400	; F74CC2  cp XIX,0x00001130
	jr	ugt, SmfWrite_SortDueNoteOffs_Skip2	; F74CC8  jr UGT,0xf74ce4
	jr	SmfWrite_SortDueNoteOffs_Join	; F74CCA  jr T,0xf74cb0
SmfWrite_SortDueNoteOffs_Skip:
	ld	a, (xiy)	; F74CCC  ld A,(XIY)
	ld	l, (xix)	; F74CCE  ld L,(XIX)
	ld	(xiy), l	; F74CD0  ld (XIY),L
	ld	(xix), a	; F74CD2  ld (XIX),A
	ld	wa, (xiy+1)	; F74CD4  ld WA,(XIY+0x01)
	ld	hl, (xix+1)	; F74CD7  ld HL,(XIX+0x01)
	ld	(xiy+1), hl	; F74CDA  ld (XIY+0x01),HL
	ld	(xix+1), wa	; F74CDD  ld (XIX+0x01),WA
	xor	de, de	; F74CE0  xor DE,DE
	jr	SmfWrite_SortDueNoteOffs_Loop	; F74CE2  jr T,0xf74c94
SmfWrite_SortDueNoteOffs_Skip2:
	add	de, 3	; F74CE4  add DE,0x0003
	cp	de, 96	; F74CE8  cp DE,0x0060
	jr	ule, SmfWrite_SortDueNoteOffs_Loop	; F74CEC  jr ULE,0xf74c94
SmfWrite_SortDueNoteOffs_Skip3:
	calr	SmfWrite_WriteDueNoteOffs	; F74CEE  calr 0xf74cf2
SmfWrite_SortDueNoteOffs_Return:
	ret	; F74CF1  ret

; --------------------------------------------------------------------------
; SmfWrite_WriteDueNoteOffs
; Called from: in-module: 0xF74CEE
; Touches: (0x107E) (0x1080) (0x1082) (0x1090) (0x11AA)
; Calls:   SmfWrite_EncodeVlq SmfWrite_WriteChannelEvent
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF74CF2 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_WriteDueNoteOffs: copy A of prom_b's SMF writer (Smf_WriteFile's writing pass), role WriteDueNoteOffs as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWrite_WriteDueNoteOffs:
	ld	bc, (4226:16)	; F74CF2  ld BC,(0x1082)
	ld	xiy, 4307	; F74CF6  ld XIY,0x000010d3
	xor	hl, hl	; F74CFB  xor HL,HL
SmfWrite_WriteDueNoteOffs_Join:
	ld	a, (xiy+hl)	; F74CFD  ld A,(XIY+HL)
	cp	a, 255	; F74D02  cp A,0xff
	jr	z, SmfWrite_WriteDueNoteOffs_Skip2	; F74D05  jr Z,0xf74d73
	xor	w, w	; F74D07  xor W,W
	ld	ix, wa	; F74D09  ld IX,WA
	extz	xix	; F74D0B  extz XIX
	sla	ix, 2	; F74D0D  sla 0x02,IX
	add	ix, wa	; F74D10  add IX,WA
	push	xde	; F74D12  push XDE
	ld	xde, 12378	; F74D13  ld XDE,0x0000305a
	add	xde, xix	; F74D18  add XDE,XIX
	ld	wa, (xde+3)	; F74D1A  ld WA,(XDE+0x03)
	pop	xde	; F74D1D  pop XDE
	cp	l, 0:i3	; F74D1E  cp L,0
	jr	nz, SmfWrite_WriteDueNoteOffs_Skip	; F74D20  jr NZ,0xf74d28
	ld	(4522:16), wa	; F74D22  ld (0x11aa),WA
	jr	SmfWrite_WriteDueNoteOffs_Join2	; F74D26  jr T,0xf74d32
SmfWrite_WriteDueNoteOffs_Skip:
	ld	de, wa	; F74D28  ld DE,WA
	sub	de, (0x1082:16)	; F74D2A  sub DE,(0x1082)
	ld	(4522:16), de	; F74D2E  ld (0x11aa),DE
SmfWrite_WriteDueNoteOffs_Join2:
	pushw	wa	; F74D32  push WA
	push	xhl	; F74D33  push XHL
	pushw	bc	; F74D34  push BC
	push	xix	; F74D35  push XIX
	calr	SmfWrite_EncodeVlq	; F74D36  calr 0xf74d99
	pop	xix	; F74D39  pop XIX
	popw	bc	; F74D3A  pop BC
	pop	xhl	; F74D3B  pop XHL
	popw	wa	; F74D3C  pop WA
	ld	(4226:16), wa	; F74D3D  ld (0x1082),WA
	push	xde	; F74D41  push XDE
	ld	xde, 12378	; F74D42  ld XDE,0x0000305a
	extz	xix	; F74D47  extz XIX
	add	xde, xix	; F74D49  add XDE,XIX
	ld	wa, (xde+1)	; F74D4B  ld WA,(XDE+0x01)
	pop	xde	; F74D4E  pop XDE
	push	xhl	; F74D4F  push XHL
	ld	l, 0:opc	; F74D50  ld L,0x00
	pushw	bc	; F74D52  push BC
	push	xix	; F74D53  push XIX
	calr	SmfWrite_WriteChannelEvent	; F74D54  calr 0xf74ac5
	pop	xix	; F74D57  pop XIX
	popw	bc	; F74D58  pop BC
	pop	xhl	; F74D59  pop XHL
	push	xde	; F74D5A  push XDE
	ld	xde, 12378	; F74D5B  ld XDE,0x0000305a
	and	(xde+ix), 0x3f	; F74D60  and (XDE+IX),0x3f
	pop	xde	; F74D66  pop XDE
	add	hl, 3	; F74D67  add HL,0x0003
	cp	hl, 96	; F74D6B  cp HL,0x0060
	jr	nc, SmfWrite_WriteDueNoteOffs_Skip2	; F74D6F  jr NC,0xf74d73
	jr	SmfWrite_WriteDueNoteOffs_Join	; F74D71  jr T,0xf74cfd
SmfWrite_WriteDueNoteOffs_Skip2:
	ld	wa, (4226:16)	; F74D73  ld WA,(0x1082)
	add	wa, (0x1090:16)	; F74D77  add WA,(0x1090)
	ld	(4226:16), bc	; F74D7B  ld (0x1082),BC
	add	bc, (0x107e:16)	; F74D7F  add BC,(0x107e)
	sub	bc, wa	; F74D83  sub BC,WA
	ld	(4522:16), bc	; F74D85  ld (0x11aa),BC
	calr	SmfWrite_EncodeVlq	; F74D89  calr 0xf74d99
	ldw	(4222:16), 0	; F74D8C  ld (0x107e),0x0000
	ldw	(4224:16), 0	; F74D92  ld (0x1080),0x0000
	ret	; F74D98  ret

; --------------------------------------------------------------------------
; SmfWrite_EncodeVlq
; Called from: in-module: 0xF74AC1 0xF74D36 0xF74D89
; Touches: (0x1193) (0x1194) (0x1195) (0x11AA) (0x11AB) (0x11AC)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF74D99 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_EncodeVlq: copy A of prom_b's SMF writer (Smf_WriteFile's writing pass), role EncodeVlq as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWrite_EncodeVlq:
	ldw	(Smf_VlqBytes:16), 0	; F74D99  ld (0x1193),0x0000
	ldw	(4501:16), 0	; F74D9F  ld (0x1195),0x0000
	cp	(0x11ac:16), 0x00	; F74DA5  cp (0x11ac),0x00
	jr	nz, SmfWrite_EncodeVlq_Skip	; F74DAA  jr NZ,0xf74dbd
	cpw	(0x11aa:16), 0x007f	; F74DAC  cp (0x11aa),0x007f
	jrl	ule, SmfWrite_EncodeVlq_Skip4	; F74DB2  jrl ULE,0xf74e3c
	cpw	(0x11aa:16), 0x3fff	; F74DB5  cp (0x11aa),0x3fff
	jr	ule, SmfWrite_EncodeVlq_Skip3	; F74DBB  jr ULE,0xf74e13
SmfWrite_EncodeVlq_Skip:
	cp	(0x11ac:16), 0x1f	; F74DBD  cp (0x11ac),0x1f
	jr	ule, SmfWrite_EncodeVlq_Skip2	; F74DC2  jr ULE,0xf74dd3
	ld	(4524:16), 31	; F74DC4  ld (0x11ac),0x1f
	ld	(4523:16), 255	; F74DC9  ld (0x11ab),0xff
	ld	(4522:16), 255	; F74DCE  ld (0x11aa),0xff
SmfWrite_EncodeVlq_Skip2:
	ld	a, (4522:16)	; F74DD3  ld A,(0x11aa)
	ld	w, a	; F74DD7  ld W,A
	and	w, 128	; F74DD9  and W,0x80
	and	a, 127	; F74DDC  and A,0x7f
	rlc	w	; F74DDF  rlc 0x01,W
	ld	l, (4523:16)	; F74DE2  ld L,(0x11ab)
	ld	h, l	; F74DE6  ld H,L
	and	h, 192	; F74DE8  and H,0xc0
	.byte 0xCE, 0xE8, 0x02	; F74DEB  rlc 0x02,H   [llvm-mc cannot encode this]
	sla	l, 1	; F74DEE  sla 0x01,L
	and	l, 1	; F74DF1  and L,0x01
	or	l, w	; F74DF4  or L,W
	or	l, 128	; F74DF6  or L,0x80
	ld	c, (4524:16)	; F74DF9  ld C,(0x11ac)
	sla	c, 2	; F74DFD  sla 0x02,C
	or	c, h	; F74E00  or C,H
	or	c, 128	; F74E02  or C,0x80
	ld	(Smf_VlqBytes:16), c	; F74E05  ld (0x1193),C
	ld	(4500:16), l	; F74E09  ld (0x1194),L
	ld	(4501:16), a	; F74E0D  ld (0x1195),A
	jr	SmfWrite_EncodeVlq_Return	; F74E11  jr T,0xf74e4b
SmfWrite_EncodeVlq_Skip3:
	ld	a, (4522:16)	; F74E13  ld A,(0x11aa)
	ld	w, a	; F74E17  ld W,A
	and	a, 127	; F74E19  and A,0x7f
	and	w, 128	; F74E1C  and W,0x80
	rlc	w	; F74E1F  rlc 0x01,W
	ld	l, (4523:16)	; F74E22  ld L,(0x11ab)
	ld	h, l	; F74E26  ld H,L
	sla	l, 1	; F74E28  sla 0x01,L
	or	l, w	; F74E2B  or L,W
	or	l, 128	; F74E2D  or L,0x80
	xor	c, c	; F74E30  xor C,C
	ld	(Smf_VlqBytes:16), l	; F74E32  ld (0x1193),L
	ld	(4500:16), a	; F74E36  ld (0x1194),A
	jr	SmfWrite_EncodeVlq_Return	; F74E3A  jr T,0xf74e4b
SmfWrite_EncodeVlq_Skip4:
	ld	a, (4522:16)	; F74E3C  ld A,(0x11aa)
	and	a, 127	; F74E40  and A,0x7f
	xor	l, l	; F74E43  xor L,L
	xor	c, c	; F74E45  xor C,C
	ld	(Smf_VlqBytes:16), a	; F74E47  ld (0x1193),A
SmfWrite_EncodeVlq_Return:
	ret	; F74E4B  ret

; --------------------------------------------------------------------------
; SmfWrite_ClearDueList
; Called from: in-module: 0xF74BFB
; Touches: nothing with an absolute address
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF74E4C is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_ClearDueList: copy A of prom_b's SMF writer (Smf_WriteFile's writing pass), role ClearDueList as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWrite_ClearDueList:
	push	xix	; F74E4C  push XIX
	ld	xix, 4307	; F74E4D  ld XIX,0x000010d3
	ldw	bc, 96	; F74E52  ld BC,0x0060
	ldw	wa, 255	; F74E55  ld WA,0x00ff
	ld	(xix+), a	; F74E58  ld (XIX+),A
	djnz16	bc, -6	; F74E5B  djnz BC,0xf74e58
	pop	xix	; F74E5E  pop XIX
	ret	; F74E5F  ret

; --------------------------------------------------------------------------
; SmfWrite_ClearEventFields
; Called from: in-module: 0xF73F01
; Touches: nothing with an absolute address
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF74E60 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_ClearEventFields: copy A of prom_b's SMF writer (Smf_WriteFile's writing pass), role ClearEventFields as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWrite_ClearEventFields:
	ld	xix, Smf_VlqValue	; F74E60  ld XIX,0x00001198
	xor	wa, wa	; F74E65  xor WA,WA
	ldw	bc, 4	; F74E67  ld BC,0x0004
	ld	(xix+), wa	; F74E6A  ld (XIX+),WA
	djnz16	bc, -6	; F74E6D  djnz BC,0xf74e6a
	ret	; F74E70  ret

; --------------------------------------------------------------------------
; SmfWrite_ReadSongByte
; Called from: in-module: 0xF736A0 0xF73732 0xF7375A 0xF73768 0xF737A9
;              0xF737DF 0xF73823 0xF73EC5 +4 more
; Touches: (0x126E) (0x345C) (0x345E)
; Calls:   SongStore_SeekBlock_Copy
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF74E71 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_ReadSongByte: A := the song byte at the block-store cursor: block BStore_CursorBlock (sought with
;   SongStore_SeekBlock_Copy), offset BStore_CursorOffset. Copy A of SmfSize_ReadSongByte; Smf_WriteFile reads each
;   event byte with it before SmfWrite_AdvanceSongCursor steps the cursor. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_z.json)
SmfWrite_ReadSongByte:
	ld	hl, (BStore_CursorBlock:16)	; F74E71  ld HL,(0x345c)
	calr	SongStore_SeekBlock_Copy	; F74E75  calr 0xf72f0a
	ld	xhl, (BStore_CursorBlockAddr:16)	; F74E78  ld XHL,(0x126e)
	ld	iy, (BStore_CursorOffset:16)	; F74E7C  ld IY,(0x345e)
	ld	a, (xhl+iy)	; F74E80  ld A,(XHL+IY)
	ret	; F74E85  ret

; --------------------------------------------------------------------------
; SmfWrite_AdvanceSongCursor
; Called from: in-module: 0xF7372F 0xF73757 0xF737A6 0xF737DC 0xF7381C
;              0xF73EDA 0xF73F1B 0xF73F7A
; Touches: (0x126E) (0x345C) (0x345E)
; Calls:   SongStore_SeekBlock_Copy
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF74E86 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_AdvanceSongCursor: copy A of prom_b's SMF writer (Smf_WriteFile's writing pass), role AdvanceSongCursor as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWrite_AdvanceSongCursor:
	ld	wa, (BStore_CursorOffset:16)	; F74E86  ld WA,(0x345e)
	cp	wa, 255	; F74E8A  cp WA,0x00ff
	jr	nz, SmfWrite_AdvanceSongCursor_Skip	; F74E8E  jr NZ,0xf74ea7
	ld	hl, (BStore_CursorBlock:16)	; F74E90  ld HL,(0x345c)
	calr	SongStore_SeekBlock_Copy	; F74E94  calr 0xf72f0a
	ld	xhl, (BStore_CursorBlockAddr:16)	; F74E97  ld XHL,(0x126e)
	ld	wa, (xhl+3)	; F74E9B  ld WA,(XHL+0x03)
	ld	(BStore_CursorBlock:16), wa	; F74E9E  ld (0x345c),WA
	ldw	wa, 5	; F74EA2  ld WA,0x0005
	jr	SmfWrite_AdvanceSongCursor_Join	; F74EA5  jr T,0xf74ea9
SmfWrite_AdvanceSongCursor_Skip:
	inc	1, wa	; F74EA7  inc 1,WA
SmfWrite_AdvanceSongCursor_Join:
	ld	(BStore_CursorOffset:16), wa	; F74EA9  ld (0x345e),WA
	ret	; F74EAD  ret

; --------------------------------------------------------------------------
; SmfWrite_ClearPendingNoteOffs
; Called from: in-module: 0xF739C7 0xF739D1
; Touches: nothing with an absolute address
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF74EAE is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_ClearPendingNoteOffs: copy A of prom_b's SMF writer (Smf_WriteFile's writing pass), role ClearPendingNoteOffs as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWrite_ClearPendingNoteOffs:
	pushw	wa	; F74EAE  push WA
	pushw	bc	; F74EAF  push BC
	push	xix	; F74EB0  push XIX
	xor	wa, wa	; F74EB1  xor WA,WA
	ld	xix, 12378	; F74EB3  ld XIX,0x0000305a
	ldw	bc, 256	; F74EB8  ld BC,0x0100
	ld	(xix+), wa	; F74EBB  ld (XIX+),WA
	djnz16	bc, -6	; F74EBE  djnz BC,0xf74ebb
	pop	xix	; F74EC1  pop XIX
	popw	bc	; F74EC2  pop BC
	popw	wa	; F74EC3  pop WA
	ret	; F74EC4  ret

; --------------------------------------------------------------------------
; SmfExport_WriteParamSysEx
; Called from: in-module: 0xF73B24
; Touches: (0x1088) (0x1238) (0x133E)
; Calls:   T_SysEx_Checksum SmfWrite_CommitOutputByte
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF74EC5 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; --------------------------------------------------------------------------
; Name:    SmfExport_WriteParamSysEx -- named 2026-09-25 (lane promb; was
;          sub_F74EC5, and the Unknown line above is superseded).  It writes
;          the 74 parameter-change SysEx events of SmfExport_ParamSysExTemplates
;          into the SMF being exported: per record, template -> RAM 0x1351 and
;          (body) 0x1365, value nibbles from RamPtrTable_F7554D, checksum via
;          T_SysEx_Checksum (prom_a SysEx_Checksum), then 19 bytes to the (0x1088) cursor
;          through SmfWrite_CommitOutputByte; it stops early when SmfWrite_CommitOutputByte leaves (0x1238)
;          != 3.  python3 notes/promb-2026-09-25/smf_param_sysex_probe.py
SmfExport_WriteParamSysEx:
	push	xwa	; F74EC5  push XWA
	push	xhl	; F74EC6  push XHL
	push	xbc	; F74EC7  push XBC
	push	xde	; F74EC8  push XDE
	push	xix	; F74EC9  push XIX
	push	xiy	; F74ECA  push XIY
	push	xiz	; F74ECB  push XIZ
	xor	bc, bc	; F74ECC  xor BC,BC
SmfExport_WriteParamSysEx_Loop:
	ld	xiz, 4945	; F74ECE  ld XIZ,0x00001351
	ld	xiy, 4965	; F74ED3  ld XIY,0x00001365
	ld	xde, Data_F74FCF	; F74ED8  ld XDE,0x00f74fcf
	ld	hl, bc	; F74EDD  ld HL,BC
	mul	l, 19	; F74EDF  mul L,0x13
	lda	xde, (xde+hl)	; F74EE2  lda XDE,XDE+HL
	xor	l, l	; F74EE7  xor L,L
SmfExport_WriteParamSysEx_Loop2:
	ld	a, (xde+)	; F74EE9  ld A,(XDE+)
	ld	(xiz+), a	; F74EEC  ld (XIZ+),A
	cp	l, 0:i3	; F74EEF  cp L,0
	jr	z, SmfExport_WriteParamSysEx_Skip	; F74EF1  jr Z,0xf74eff
	cp	l, 2:i3	; F74EF3  cp L,2
	jr	z, SmfExport_WriteParamSysEx_Skip	; F74EF5  jr Z,0xf74eff
	cp	l, 15	; F74EF7  cp L,0x0f
	jr	ugt, SmfExport_WriteParamSysEx_Skip	; F74EFA  jr UGT,0xf74eff
	ld	(xiy+), a	; F74EFC  ld (XIY+),A
SmfExport_WriteParamSysEx_Skip:
	inc	1, l	; F74EFF  inc 1,L
	cp	l, 19	; F74F01  cp L,0x13
	jr	c, SmfExport_WriteParamSysEx_Loop2	; F74F04  jr C,0xf74ee9
	xor	hl, hl	; F74F06  xor HL,HL
	ld	l, c	; F74F08  ld L,C
	sla	hl, 2	; F74F0A  sla 0x02,HL
	ld	xiz, RamPtrTable_F7554D	; F74F0D  ld XIZ,0x00f7554d
	lda	xiz, (xiz+hl)	; F74F12  lda XIZ,XIZ+HL
	ld	xiz, (xiz)	; F74F17  ld XIZ,(XIZ)
	ld	a, (xiz)	; F74F19  ld A,(XIZ)
	cp	c, 0:i3	; F74F1B  cp C,0
	jr	nz, SmfExport_WriteParamSysEx_Skip2	; F74F1D  jr NZ,0xf74f24
	and	a, 3	; F74F1F  and A,0x03
	jr	SmfExport_WriteParamSysEx_Join	; F74F22  jr T,0xf74f4e
SmfExport_WriteParamSysEx_Skip2:
	cp	c, 72	; F74F24  cp C,0x48
	jr	z, SmfExport_WriteParamSysEx_Skip5	; F74F27  jr Z,0xf74f4b
	cp	c, 73	; F74F29  cp C,0x49
	jr	z, SmfExport_WriteParamSysEx_Skip4	; F74F2C  jr Z,0xf74f43
	cp	c, 2:i3	; F74F2E  cp C,2
	jr	z, SmfExport_WriteParamSysEx_Skip3	; F74F30  jr Z,0xf74f3e
	cp	c, 3:i3	; F74F32  cp C,3
	jr	nz, SmfExport_WriteParamSysEx_Join	; F74F34  jr NZ,0xf74f4e
	and	a, 240	; F74F36  and A,0xf0
	srl	a, 4	; F74F39  srl 0x04,A
	jr	SmfExport_WriteParamSysEx_Join	; F74F3C  jr T,0xf74f4e
SmfExport_WriteParamSysEx_Skip3:
	and	a, 15	; F74F3E  and A,0x0f
	jr	SmfExport_WriteParamSysEx_Join	; F74F41  jr T,0xf74f4e
SmfExport_WriteParamSysEx_Skip4:
	and	a, 240	; F74F43  and A,0xf0
	srl	a, 4	; F74F46  srl 0x04,A
	jr	SmfExport_WriteParamSysEx_Join	; F74F49  jr T,0xf74f4e
SmfExport_WriteParamSysEx_Skip5:
	and	a, 15	; F74F4B  and A,0x0f
SmfExport_WriteParamSysEx_Join:
	ld	w, a	; F74F4E  ld W,A
	and	w, 240	; F74F50  and W,0xf0
	and	a, 15	; F74F53  and A,0x0f
	srl	w, 4	; F74F56  srl 0x04,W
	ld	xiz, 4945	; F74F59  ld XIZ,0x00001351
	ld	(xiz+14), w	; F74F5E  ld (XIZ+0x0e),W
	ld	(xiz+15), a	; F74F61  ld (XIZ+0x0f),A
	ld	xiz, 4965	; F74F64  ld XIZ,0x00001365
	ld	(xiz+12), w	; F74F69  ld (XIZ+0x0c),W
	ld	(xiz+13), a	; F74F6C  ld (XIZ+0x0d),A
	ld	xhl, 4965	; F74F6F  ld XHL,0x00001365
	push	xbc	; F74F74  push XBC
	push	xix	; F74F75  push XIX
	pushw	15	; F74F76  push 0x000f
	push	xhl	; F74F79  push XHL
	call	T_SysEx_Checksum	; F74F7A  call 0xf4090c
	inc	6, xsp	; F74F7E  inc 6,XSP
	pop	xix	; F74F80  pop XIX
	pop	xbc	; F74F81  pop XBC
	ld	xiz, 4945	; F74F82  ld XIZ,0x00001351
	ld	(xiz+17), a	; F74F87  ld (XIZ+0x11),A
	ld	xix, (InputStream_Cursor:16)	; F74F8A  ld XIX,(0x1088)
	ldw	hl, 19	; F74F8E  ld HL,0x0013
	ld	a, (xiz+)	; F74F91  ld A,(XIZ+)
	cp	hl, 19	; F74F94  cp HL,0x0013
	jr	nz, SmfExport_WriteParamSysEx_Skip6	; F74F98  jr NZ,0xf74fa2
	bit	1, (0x133e:16)	; F74F9A  bit 1,(0x133e)
	jr	nz, SmfExport_WriteParamSysEx_Skip6	; F74F9E  jr NZ,0xf74fa2
	ld	a, 0:opc	; F74FA0  ld A,0x00
SmfExport_WriteParamSysEx_Skip6:
	ld	(xix+), a	; F74FA2  ld (XIX+),A
	pushw	hl	; F74FA5  push HL
	pushw	bc	; F74FA6  push BC
	push	xix	; F74FA7  push XIX
	push	xiz	; F74FA8  push XIZ
	calr	SmfWrite_CommitOutputByte	; F74FA9  calr 0xf74b3a
	pop	xiz	; F74FAC  pop XIZ
	pop	xix	; F74FAD  pop XIX
	popw	bc	; F74FAE  pop BC
	popw	hl	; F74FAF  pop HL
	ld	xix, (InputStream_Cursor:16)	; F74FB0  ld XIX,(0x1088)
	cp	(0x1238:16), 0x03	; F74FB4  cp (0x1238),0x03
	jr	nz, SmfExport_WriteParamSysEx_Epilogue	; F74FB9  jr NZ,0xf74fc7
	djnz16	hl, -45	; F74FBB  djnz HL,0xf74f91
	inc	1, bc	; F74FBE  inc 1,BC
	cp	bc, 74	; F74FC0  cp BC,0x004a
	jrl	c, SmfExport_WriteParamSysEx_Loop	; F74FC4  jrl C,0xf74ece
SmfExport_WriteParamSysEx_Epilogue:
	pop	xiz	; F74FC7  pop XIZ
	pop	xiy	; F74FC8  pop XIY
	pop	xix	; F74FC9  pop XIX
	pop	xde	; F74FCA  pop XDE
	pop	xbc	; F74FCB  pop XBC
	pop	xhl	; F74FCC  pop XHL
	pop	xwa	; F74FCD  pop XWA
	ret	; F74FCE  ret

; --------------------------------------------------------------------------
; Data_F74FCF -- 1406 bytes this block could not split.  No content rule
;                framed it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or
;                ASCII -- and the code walk never reached it from a thunk
;                slot, a proven call site, an opcode-anchored call or an
;                entry of a table the firmware transfers to.  So it is
;                emitted as bytes rather than guessed.
; Contains: printable bytes |0..P,.................P,.................P,....
;           .............P,.................P,..... ...........P,.....!.....
;           ......P,....."...........P,.....#...........P,.....$...........P
;           ,.....%...........P,.....&...........P,.....'...........P,.....(
;           ...........P,.....)...........P,.....*...........P,.....+.......
;           ....P,.....,...........P,.....-
;           ...........P,.................P,...../...........P,.....0.......
;           ....P,.....1...........P,.....2...........P,.....3...........P,.
;           ....4...........P,.....5...........P,.....6...........P,.....@..
;           .........P,.....A...........P,.....B...........P,.....C.........
;           ..P,.....D...........P,.....E...........P,.....F...........P,...
;           ..G...........P,.....H...........P,.....I...........P,.....J....
;           .......P,.....K...........P,.....L...........P,.....M...........
;           P,.....N...........P,.....O...........P,.....P...........P,.....
;           Q...........P,.....R...........P,.....S...........P,.....T......
;           .....P,.....U...........P,.....V...........P,.....`...........P,
;           .....a...........P,.....b...........P,.....c...........P,.....d.
;           ..........P,.....e...........P,.....f...........P,.....g........
;           ...P,.....h...........P,.....i...........P,.....j...........P,..
;           ...k...........P,.....l...........P,.....m...........P,.....n...
;           ........P,.....o...........P,.....p...........P,.....q..........
;           .P,.....r...........P,.....s...........P,.....t...........P,....
;           .u...........P,.....0...........P,.....1........|
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XDE,0x00f74fcf` at
;          0xF74ED8 (operand field 1 byte in)
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; ⚠ CORRECTED 2026-09-25: this line used to record that nothing but the
;   bytes was known.  The reader and the record layout are now established;
;   see the ANSWERED paragraph and SmfExport_ParamSysExTemplates below.
; --------------------------------------------------------------------------
; ⚠ ANSWERED 2026-09-25 (lane promb) -- the header above is the old,
;   NEGATIVE classification and is kept as the record of it.  These 1406 bytes
;   are 74 records of 19, SmfExport_ParamSysExTemplates below; the reader is
;   SmfExport_WriteParamSysEx (was SmfExport_WriteParamSysEx).
Data_F74FCF:
; --------------------------------------------------------------------------
; SmfExport_ParamSysExTemplates -- 0xF74FCF-0xF7554C, 74 records of 19 bytes:
;   each is one Standard-MIDI-File track EVENT, a delta time followed by a
;   System Exclusive event, that the SMF writer copies into a file it is
;   exporting after filling in one parameter's current value.
; Read by: SmfExport_WriteParamSysEx (0xF74EC5): for BC = 0..73 it takes
;   `Data_F74FCF + 19*BC` (`mul L,0x13` / `lda XDE,XDE+HL`), copies the 19
;   bytes to RAM 0x1351, reads one byte through RamPtrTable_F7554D[BC] (the
;   RAM byte that parameter lives in), stores its high and low NIBBLES at
;   record +14 and +15, computes a checksum with prom_a SysEx_Checksum (slot
;   T_SysEx_Checksum: the negated 7-bit sum of the bytes after the first) into +17,
;   and writes all 19 bytes to the output cursor (0x1088) through SmfWrite_CommitOutputByte,
;   which flushes the 1 KiB window at 0x60A700 (notes/FINDINGS-prom_b-smf-
;   writer.md).  Record 0's delta is written as 0 unless bit 1 of (0x133E).
; Record layout (every field re-derived from the ROM by
;   python3 notes/promb-2026-09-25/smf_param_sysex_probe.py):
;   +0      delta time: 0x30 (record 0), 0x0F (every fifth from record 5),
;           else 0x00 -- one byte, so always < 0x80 as SMF requires
;   +1      0xF0, SMF SysEx event          +2   0x10, its length: 16 bytes
;   +3..+8  50 2C 04 00 11 00 -- constant in all 74
;   +9,+10  the parameter ADDRESS: 01 04 (record 0), 11 00..11 75 (records
;           1-71, 71 distinct), 00 30 and 00 31 (records 72, 73)
;   +11..+13 00 00 01 constant    +14,+15 value high / low nibble (filled)
;   +16     00                     +17 checksum (filled)    +18 0xF7
; Entry count: 74, from the reader's own bound (`cp BC,0x004a` / `jrl C`),
;   and 74 * 19 = 1406 ends exactly where RamPtrTable_F7554D -- the parallel
;   table the same loop indexes by 4*BC -- begins, with its 74 entries.
; Correspondence the probe checks: records 4..70 read RAM 0x7622 + their
;   parameter number (address 11 20 -> 0x7642, 11 40 -> 0x7662, 11 60 ->
;   0x7682); record 71 (11 75) reads 0x7698, one past.  That is the same
;   work-RAM parameter area prom_a's ParamNumber_RecordPtrs
;   (0xFACDEA) addresses.  Records 2 and 3 share one byte (0x78B7) and the
;   reader takes its low and high nibble; 72 and 73 are special-cased.
; Unknown: which PANEL PARAMETER each address is -- the SysEx address map of
;   this model is not in either image's text.
; ⚠ EIGHT `calr` in prom_b land INSIDE these records, never on a record
;   start: 0xF76E14, 0xF76E33, 0xF77CBB, 0xF77CDA -> 0xF75095 (record 10, +8);
;   0xF76732 -> 0xF750AB (11, +11); 0xF76798 -> 0xF750B8 (12, +5); 0xF77EA2,
;   0xF77EC1 -> 0xF752DF (41, +5; that address carried a label, sub_F752DF,
;   which split this object in two for the census).  Every one sits in code
;   that nothing in prom_a or prom_b can be shown to enter -- a byte scan at
;   every offset for `jp`/`call` nnn, `calr`/`jrl`, `jr` and 32-bit pointers
;   finds no reference to sub_F7669D, to 0xF76E10 (after 0xF76E0F's `ret`), to
;   0xF77E9E (after 0xF77E9D's `ret`), or to SmfSizeCopy_Pass, the run whose code is
;   the only caller of SmfSizeCopy_ReadSongByte / SmfSizeCopy_AdvanceSongCursor.  The pair `ld HL,(0x345c) /
;   calr X / ... ld A,(XHL+IY)` occurs three times, with X = 0xF75095 twice
;   and 0xF752DF once --
;   the same shape as SC1_DeadTail: code linked against another layout.
;   So they are not evidence that these bytes are instructions; the reader's
;   19-byte stride and the 74 x 19 = 1406 extent are.
; --------------------------------------------------------------------------
SmfExport_ParamSysExTemplates:
	.byte	0x30, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x01, 0x04, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F74FCF  [ 0] addr 01 04
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F74FE2  [ 1] addr 11 00
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F74FF5  [ 2] addr 11 01
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x02, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75008  [ 3] addr 11 02
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x20, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7501B  [ 4] addr 11 20
	.byte	0x0F, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x21, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7502E  [ 5] addr 11 21
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x22, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75041  [ 6] addr 11 22
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x23, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75054  [ 7] addr 11 23
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x24, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75067  [ 8] addr 11 24
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x25, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7507A  [ 9] addr 11 25
	.byte	0x0F, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x26, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7508D  [10] addr 11 26
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x27, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F750A0  [11] addr 11 27
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x28, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F750B3  [12] addr 11 28
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x29, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F750C6  [13] addr 11 29
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x2A, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F750D9  [14] addr 11 2A
	.byte	0x0F, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x2B, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F750EC  [15] addr 11 2B
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x2C, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F750FF  [16] addr 11 2C
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x2D, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75112  [17] addr 11 2D
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x2E, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75125  [18] addr 11 2E
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x2F, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75138  [19] addr 11 2F
	.byte	0x0F, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x30, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7514B  [20] addr 11 30
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x31, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7515E  [21] addr 11 31
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x32, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75171  [22] addr 11 32
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x33, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75184  [23] addr 11 33
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x34, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75197  [24] addr 11 34
	.byte	0x0F, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x35, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F751AA  [25] addr 11 35
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x36, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F751BD  [26] addr 11 36
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x40, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F751D0  [27] addr 11 40
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x41, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F751E3  [28] addr 11 41
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x42, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F751F6  [29] addr 11 42
	.byte	0x0F, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x43, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75209  [30] addr 11 43
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x44, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7521C  [31] addr 11 44
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x45, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7522F  [32] addr 11 45
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x46, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75242  [33] addr 11 46
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x47, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75255  [34] addr 11 47
	.byte	0x0F, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x48, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75268  [35] addr 11 48
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x49, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7527B  [36] addr 11 49
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x4A, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7528E  [37] addr 11 4A
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x4B, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F752A1  [38] addr 11 4B
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x4C, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F752B4  [39] addr 11 4C
	.byte	0x0F, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x4D, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F752C7  [40] addr 11 4D
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x4E, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F752DA  [41] addr 11 4E
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x4F, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F752ED  [42] addr 11 4F
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x50, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75300  [43] addr 11 50
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x51, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75313  [44] addr 11 51
	.byte	0x0F, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x52, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75326  [45] addr 11 52
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x53, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75339  [46] addr 11 53
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x54, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7534C  [47] addr 11 54
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x55, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7535F  [48] addr 11 55
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x56, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75372  [49] addr 11 56
	.byte	0x0F, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x60, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75385  [50] addr 11 60
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x61, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75398  [51] addr 11 61
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x62, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F753AB  [52] addr 11 62
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x63, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F753BE  [53] addr 11 63
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x64, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F753D1  [54] addr 11 64
	.byte	0x0F, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x65, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F753E4  [55] addr 11 65
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x66, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F753F7  [56] addr 11 66
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x67, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7540A  [57] addr 11 67
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x68, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7541D  [58] addr 11 68
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x69, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75430  [59] addr 11 69
	.byte	0x0F, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x6A, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75443  [60] addr 11 6A
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x6B, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75456  [61] addr 11 6B
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x6C, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75469  [62] addr 11 6C
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x6D, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7547C  [63] addr 11 6D
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x6E, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7548F  [64] addr 11 6E
	.byte	0x0F, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x6F, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F754A2  [65] addr 11 6F
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x70, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F754B5  [66] addr 11 70
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x71, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F754C8  [67] addr 11 71
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x72, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F754DB  [68] addr 11 72
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x73, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F754EE  [69] addr 11 73
	.byte	0x0F, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x74, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75501  [70] addr 11 74
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x11, 0x75, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75514  [71] addr 11 75
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x00, 0x30, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F75527  [72] addr 00 30
	.byte	0x00, 0xF0, 0x10, 0x50, 0x2C, 0x04, 0x00, 0x11, 0x00, 0x00, 0x31, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0xF7	; F7553A  [73] addr 00 31


; --------------------------------------------------------------------------
; RamPtrTable_F7554D -- 74 32-bit words, every one below 0x10000, i.e. a
;                       16-bit RAM address stored one per long word.  First
;                       0x7F32, LAST 0x7EE4; the step between neighbours
;                       takes 8 distinct values (0x-8FE 0x-275 0x0 0x1 0x2
;                       0xA 0x283 0x84C).
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XIZ,0x00f7554d` at
;          0xF74F0D (operand field 1 byte in)
; Entry count: 74.  The chain stops at the first word that is not below
;              0x10000, at 0xF75675.
; Evidence: every word is re-read and range-asserted on every emit.  The
;           RAMTAB rule fires ZERO times over the proven prom_b instruction
;           text (`python3 notes/prom_b_f6d002_layout.py --null-ptr`).
; Unknown: WHICH panel parameter lives at each of those RAM addresses (that
;          each is the value cell of one exported parameter is ANSWERED
;          below).  The name describes the CONTENT of the table, not its
;          purpose.
; --------------------------------------------------------------------------
; ⚠ ANSWERED 2026-09-25 (lane promb), and the name is KEPT because prom_a's
;          ParamNumber_RecordPtrs header cites it: entry k is the RAM byte
;          whose value SmfExport_WriteParamSysEx (0xF74EC5) writes into
;          record k of SmfExport_ParamSysExTemplates -- the loop indexes this
;          table by 4*BC and that one by 19*BC with the same BC, 0..73.  So
;          these are 74 panel-parameter cells in the work-RAM parameter area
;          (0x7622-0x7F5A in prom_a's ParamNumber_RecordPtrs), and the SysEx
;          address of each is at +9/+10 of the matching record.  WHICH
;          parameter each is stays unknown, as above.
RamPtrTable_F7554D:
	.long	0x00007F32	; F7554D  [0] -> RAM 0x7F32
	.long	0x00007634	; F75551  [1] -> RAM 0x7634
	.long	0x000078B7	; F75555  [2] -> RAM 0x78B7
	.long	0x000078B7	; F75559  [3] -> RAM 0x78B7
	.long	0x00007642	; F7555D  [4] -> RAM 0x7642
	.long	0x00007643	; F75561  [5] -> RAM 0x7643
	.long	0x00007644	; F75565  [6] -> RAM 0x7644
	.long	0x00007645	; F75569  [7] -> RAM 0x7645
	.long	0x00007646	; F7556D  [8] -> RAM 0x7646
	.long	0x00007647	; F75571  [9] -> RAM 0x7647
	.long	0x00007648	; F75575  [10] -> RAM 0x7648
	.long	0x00007649	; F75579  [11] -> RAM 0x7649
	.long	0x0000764A	; F7557D  [12] -> RAM 0x764A
	.long	0x0000764B	; F75581  [13] -> RAM 0x764B
	.long	0x0000764C	; F75585  [14] -> RAM 0x764C
	.long	0x0000764D	; F75589  [15] -> RAM 0x764D
	.long	0x0000764E	; F7558D  [16] -> RAM 0x764E
	.long	0x0000764F	; F75591  [17] -> RAM 0x764F
	.long	0x00007650	; F75595  [18] -> RAM 0x7650
	.long	0x00007651	; F75599  [19] -> RAM 0x7651
	.long	0x00007652	; F7559D  [20] -> RAM 0x7652
	.long	0x00007653	; F755A1  [21] -> RAM 0x7653
	.long	0x00007654	; F755A5  [22] -> RAM 0x7654
	.long	0x00007655	; F755A9  [23] -> RAM 0x7655
	.long	0x00007656	; F755AD  [24] -> RAM 0x7656
	.long	0x00007657	; F755B1  [25] -> RAM 0x7657
	.long	0x00007658	; F755B5  [26] -> RAM 0x7658
	.long	0x00007662	; F755B9  [27] -> RAM 0x7662
	.long	0x00007663	; F755BD  [28] -> RAM 0x7663
	.long	0x00007664	; F755C1  [29] -> RAM 0x7664
	.long	0x00007665	; F755C5  [30] -> RAM 0x7665
	.long	0x00007666	; F755C9  [31] -> RAM 0x7666
	.long	0x00007667	; F755CD  [32] -> RAM 0x7667
	.long	0x00007668	; F755D1  [33] -> RAM 0x7668
	.long	0x00007669	; F755D5  [34] -> RAM 0x7669
	.long	0x0000766A	; F755D9  [35] -> RAM 0x766A
	.long	0x0000766B	; F755DD  [36] -> RAM 0x766B
	.long	0x0000766C	; F755E1  [37] -> RAM 0x766C
	.long	0x0000766D	; F755E5  [38] -> RAM 0x766D
	.long	0x0000766E	; F755E9  [39] -> RAM 0x766E
	.long	0x0000766F	; F755ED  [40] -> RAM 0x766F
	.long	0x00007670	; F755F1  [41] -> RAM 0x7670
	.long	0x00007671	; F755F5  [42] -> RAM 0x7671
	.long	0x00007672	; F755F9  [43] -> RAM 0x7672
	.long	0x00007673	; F755FD  [44] -> RAM 0x7673
	.long	0x00007674	; F75601  [45] -> RAM 0x7674
	.long	0x00007675	; F75605  [46] -> RAM 0x7675
	.long	0x00007676	; F75609  [47] -> RAM 0x7676
	.long	0x00007677	; F7560D  [48] -> RAM 0x7677
	.long	0x00007678	; F75611  [49] -> RAM 0x7678
	.long	0x00007682	; F75615  [50] -> RAM 0x7682
	.long	0x00007683	; F75619  [51] -> RAM 0x7683
	.long	0x00007684	; F7561D  [52] -> RAM 0x7684
	.long	0x00007685	; F75621  [53] -> RAM 0x7685
	.long	0x00007686	; F75625  [54] -> RAM 0x7686
	.long	0x00007687	; F75629  [55] -> RAM 0x7687
	.long	0x00007688	; F7562D  [56] -> RAM 0x7688
	.long	0x00007689	; F75631  [57] -> RAM 0x7689
	.long	0x0000768A	; F75635  [58] -> RAM 0x768A
	.long	0x0000768B	; F75639  [59] -> RAM 0x768B
	.long	0x0000768C	; F7563D  [60] -> RAM 0x768C
	.long	0x0000768D	; F75641  [61] -> RAM 0x768D
	.long	0x0000768E	; F75645  [62] -> RAM 0x768E
	.long	0x0000768F	; F75649  [63] -> RAM 0x768F
	.long	0x00007690	; F7564D  [64] -> RAM 0x7690
	.long	0x00007691	; F75651  [65] -> RAM 0x7691
	.long	0x00007692	; F75655  [66] -> RAM 0x7692
	.long	0x00007693	; F75659  [67] -> RAM 0x7693
	.long	0x00007694	; F7565D  [68] -> RAM 0x7694
	.long	0x00007695	; F75661  [69] -> RAM 0x7695
	.long	0x00007696	; F75665  [70] -> RAM 0x7696
	.long	0x00007698	; F75669  [71] -> RAM 0x7698
	.long	0x00007EE4	; F7566D  [72] -> RAM 0x7EE4
	.long	0x00007EE4	; F75671  [73] -> RAM 0x7EE4


; --------------------------------------------------------------------------
; Data_F75675 -- 16 bytes this block could not split.  No content rule
;                framed it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or
;                ASCII -- and the code walk never reached it from a thunk
;                slot, a proven call site, an opcode-anchored call or an
;                entry of a table the firmware transfers to.  So it is
;                emitted as bytes rather than guessed.
; Contains: printable bytes |...~.......~....|
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XIY,0x00f75675` at
;          0xF7575B (operand field 1 byte in)
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; Unknown: everything about it except its bytes.
; --------------------------------------------------------------------------
Data_F75675:
	.byte	0x00, 0xF0, 0x05, 0x7E, 0x7F, 0x09, 0x01, 0xF7, 0x00, 0xF0, 0x05, 0x7E, 0x7F, 0x09, 0x02, 0xF7	; F75675  [0..15]


; --------------------------------------------------------------------------
; SmfSize_Pass
; Called from: in-module: 0xF739CE
; Touches: (0x0C70) (0x107E) (0x1080) (0x1082) (0x1084) (0x1086) (0x1088)
;          (0x1193) (0x1195) (0x1198) +18 more  |  0x603422 0x603500
;          0x6036A0 0x60A700 0x60AAFF
; Calls:   SmfSize_StageTempo SmfSize_WriteTempoEvent SmfSize_CommitOutputByte T_PartSound_ToProgramChange SmfSize_WriteChannelEvent sub_F75685_Nop
;          SmfSize_ReadSongByte SmfSize_AdvanceSongCursor SmfSize_ClearEventFields SmfSize_EncodeDeltaTime SmfSize_AgePendingNoteOffs SmfSize_WriteControlChange
;          +1 more
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF75685 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSize_Pass: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), the whole sizing pass over the song (its main; see the module note) -- notes/prom_b_smf_writer_names.py
SmfSize_Pass:
	xor	hl, hl	; F75685  xor HL,HL
	xor	bc, bc	; F75687  xor BC,BC
SmfSize_Pass_Join:
	push	xde	; F75689  push XDE
	ld	xde, 6305024	; F7568A  ld XDE,0x00603500
	bit	7, (xde+hl)	; F7568F  bit 7,(XDE+HL)
	pop	xde	; F75694  pop XDE
	jr	nz, SmfSize_Pass_Skip	; F75695  jr NZ,0xf756a5
	add	hl, 3	; F75697  add HL,0x0003
	inc	1, c	; F7569B  inc 1,C
	cp	c, 16	; F7569D  cp C,0x10
	jrl	ugt, SmfSize_Pass_Return	; F756A0  jrl UGT,0xf7609d
	jr	SmfSize_Pass_Join	; F756A3  jr T,0xf75689
SmfSize_Pass_Skip:
	ld	(3184:16), c	; F756A5  ld (0x0c70),C
	inc	1, hl	; F756A9  inc 1,HL
	push	xde	; F756AB  push XDE
	ld	xde, 6305024	; F756AC  ld XDE,0x00603500
	ld	hl, (xde+hl)	; F756B1  ld HL,(XDE+HL)
	pop	xde	; F756B6  pop XDE
	ld	(BStore_CursorBlock:16), hl	; F756B7  ld (0x345c),HL
	ldw	(BStore_CursorOffset:16), 5	; F756BB  ld (0x345e),0x0005
	ld	(4529:16), 0	; F756C1  ld (0x11b1),0x00
	ld	xiy, SmfFileTemplate_F760BF	; F756C6  ld XIY,0x00f760bf
	ld	xix, 6334208	; F756CB  ld XIX,0x0060a700
	ldw	bc, 7	; F756D0  ld BC,0x0007
	ldirw	; F756D3  ldirw
	ld	xiy, SmfFileTemplate_F760BF + 0xE	; F756D5  ld XIY,0x00f760cd
	ldw	bc, 4	; F756DA  ld BC,0x0004
	ldirw	; F756DD  ldirw
	ld	(InputStream_Cursor:16), xix	; F756DF  ld (0x1088),XIX
	ld	xix, (InputStream_Cursor:16)	; F756E3  ld XIX,(0x1088)
	ld	xiy, SmfFileTemplate_F760BF + 0x16	; F756E7  ld XIY,0x00f760d5
	ldw	bc, 11	; F756EC  ld BC,0x000b
	ldir85	; F756EF  ldir
	ld	xiy, Disk_FileName	; F756F1  ld XIY,0x000021c8
	ldw	bc, 8	; F756F6  ld BC,0x0008
	ldir85	; F756F9  ldir
	ld	(InputStream_Cursor:16), xix	; F756FB  ld (0x1088),XIX
	ldw	(Smf_VlqBytes:16), 0	; F756FF  ld (0x1193),0x0000
	ld	(4501:16), 0	; F75705  ld (0x1195),0x00
	ld	xiy, Smf_VlqBytes	; F7570A  ld XIY,0x00001193
	ld	xix, (InputStream_Cursor:16)	; F7570F  ld XIX,(0x1088)
SmfSize_Pass_Loop:
	ld	a, (xiy+)	; F75713  ld A,(XIY+)
	ld	(xix+), a	; F75716  ld (XIX+),A
	bit	7, a	; F75719  bit 0x07,A
	jr	nz, SmfSize_Pass_Loop	; F7571C  jr NZ,0xf75713
	ldw	wa, 22783	; F7571E  ld WA,0x58ff
	ld	(xix+), wa	; F75721  ld (XIX+),WA
	ld	a, 4:opc	; F75724  ld A,0x04
	ld	w, (6304983:24)	; F75726  ld W,(0x6034d7)
	ld	(xix+), wa	; F7572B  ld (XIX+),WA
	ldw	wa, 6146	; F7572E  ld WA,0x1802
	ld	(xix+), wa	; F75731  ld (XIX+),WA
	ld	a, 8:opc	; F75734  ld A,0x08
	ld	(xix+), a	; F75736  ld (XIX+),A
	ld	(InputStream_Cursor:16), xix	; F75739  ld (0x1088),XIX
	ld	l, (32482:16)	; F7573D  ld L,(0x7ee2)
	xor	h, h	; F75741  xor H,H
	pushw	bc	; F75743  push BC
	ld	b, (32483:16)	; F75744  ld B,(0x7ee3)
	and	b, 1	; F75748  and B,0x01
	xor	c, c	; F7574B  xor C,C
	or	hl, bc	; F7574D  or HL,BC
	popw	bc	; F7574F  pop BC
	calr	SmfSize_StageTempo	; F75750  calr 0xf7615b
	calr	SmfSize_WriteTempoEvent	; F75753  calr 0xf761a1
	ld	(4665:16), 255	; F75756  ld (0x1239),0xff
	ld	xiy, Data_F75675	; F7575B  ld XIY,0x00f75675
	bit	2, (0x7f4d:16)	; F75760  bit 2,(0x7f4d)
	jr	nz, SmfSize_Pass_Skip2	; F75764  jr NZ,0xf75770
	ld	xiy, Data_F75675 + 0x8	; F75766  ld XIY,0x00f7567d
	ld	(4665:16), 0	; F7576B  ld (0x1239),0x00
SmfSize_Pass_Skip2:
	ld	xix, (InputStream_Cursor:16)	; F75770  ld XIX,(0x1088)
	ldw	bc, 8	; F75774  ld BC,0x0008
	ld	a, (xiy+)	; F75777  ld A,(XIY+)
	cp	bc, 8	; F7577A  cp BC,0x0008
	jr	nz, SmfSize_Pass_Skip3	; F7577E  jr NZ,0xf7578e
	bit	0, (0x133e:16)	; F75780  bit 0,(0x133e)
	jr	z, SmfSize_Pass_Skip3	; F75784  jr Z,0xf7578e
	bit	1, (0x133e:16)	; F75786  bit 1,(0x133e)
	jr	z, SmfSize_Pass_Skip3	; F7578A  jr Z,0xf7578e
	ld	a, 32:opc	; F7578C  ld A,0x20
SmfSize_Pass_Skip3:
	ld	(xix+), a	; F7578E  ld (XIX+),A
	pushw	bc	; F75791  push BC
	push	xiy	; F75792  push XIY
	push	xix	; F75793  push XIX
	calr	SmfSize_CommitOutputByte	; F75794  calr 0xf762bd
	pop	xix	; F75797  pop XIX
	pop	xiy	; F75798  pop XIY
	popw	bc	; F75799  pop BC
	ld	xix, (InputStream_Cursor:16)	; F7579A  ld XIX,(0x1088)
	djnz16	bc, -42	; F7579E  djnz BC,0xf75777
	ld	(InputStream_Cursor:16), xix	; F757A1  ld (0x1088),XIX
	bit	0, (0x133e:16)	; F757A5  bit 0,(0x133e)
	jrl	z, SmfSize_Pass_Join5	; F757A9  jrl Z,0xf75a8c
	ld	xiy, 6305440	; F757AC  ld XIY,0x006036a0
	ld	(3184:16), 0	; F757B1  ld (0x0c70),0x00
SmfSize_Pass_Loop2:
	xor	xhl, xhl	; F757B6  xor XHL,XHL
	ld	l, (3184:16)	; F757B8  ld L,(0x0c70)
	ld	c, l	; F757BC  ld C,L
	ld	de, (4678:16)	; F757BE  ld DE,(0x1246)
	ld	a, c	; F757C2  ld A,C
	scf	; F757C4  scf
	xorcf_a_16	de	; F757C5  xorcf A,DE
	jrl	c, SmfSize_Pass_Skip5	; F757C7  jrl C,0xf75a5e
	push	xix	; F757CA  push XIX
	ld	xix, BStore_TrackToPart	; F757CB  ld XIX,0x00603422
	ld	l, (xix+hl)	; F757D0  ld L,(XIX+HL)
	pop	xix	; F757D5  pop XIX
	ld	b, l	; F757D6  ld B,L
	sla	l, 1	; F757D8  sla 0x01,L
	xor	h, h	; F757DB  xor H,H
	push	xde	; F757DD  push XDE
	ld	xde, SmfPartOffsets_F760E0	; F757DE  ld XDE,0x00f760e0
	ld	hl, (xde+hl)	; F757E3  ld HL,(XDE+HL)
	pop	xde	; F757E8  pop XDE
	cp	hl, 65535	; F757E9  cp HL,0xffff
	jrl	z, SmfSize_Pass_Skip5	; F757ED  jrl Z,0xf75a5e
	cp	c, 0:i3	; F757F0  cp C,0
	jr	z, SmfSize_Pass_Join2	; F757F2  jr Z,0xf75802
	push	xhl	; F757F4  push XHL
	xor	hl, hl	; F757F5  xor HL,HL
SmfSize_Pass_Loop3:
	pop	xhl	; F757F7  pop XHL
	jr	SmfSize_Pass_Join2	; F757F8  jr T,0xf75802
	cp	l, c	; F757FA  cp L,C
	jr	z, SmfSize_Pass_Loop3	; F757FC  jr Z,0xf757f7
	pop	xhl	; F757FE  pop XHL
	jrl	SmfSize_Pass_Join5	; F757FF  jrl T,0xf75a8c
SmfSize_Pass_Join2:
	lda	xiy, (xiy+hl)	; F75802  lda XIY,XIY+HL
	ld	c, (xiy+2)	; F75807  ld C,(XIY+0x02)
	ld	d, (xiy+3)	; F7580A  ld D,(XIY+0x03)
	ld	b, (xiy+5)	; F7580D  ld B,(XIY+0x05)
	ld	e, (xiy+6)	; F75810  ld E,(XIY+0x06)
	ld	a, (xiy+7)	; F75813  ld A,(XIY+0x07)
	ld	(4763:16), a	; F75816  ld (0x129b),A
	ld	a, (xiy+8)	; F7581A  ld A,(XIY+0x08)
	ld	(4944:16), a	; F7581D  ld (0x1350),A
	ld	a, (xiy+9)	; F75821  ld A,(XIY+0x09)
	ld	(4686:16), a	; F75824  ld (0x124e),A
	and	(0x0c70:16), 0x0f	; F75828  and (0x0c70),0x0f
	cp	(0x1239:16), 0xff	; F7582D  cp (0x1239),0xff
	jr	nz, SmfSize_Pass_Skip4	; F75832  jr NZ,0xf75895
	ld	a, (3184:16)	; F75834  ld A,(0x0c70)
	ld	l, c	; F75838  ld L,C
	ld	(SoundConv_Arg0:24), l	; F7583A  ld (0x60f010),L
	ld	h, d	; F7583F  ld H,D
	ld	(SoundConv_Arg1:24), h	; F75841  ld (0x60f011),H
	ld	l, (xiy)	; F75846  ld L,(XIY)
	ld	(SoundConv_Arg2:24), l	; F75848  ld (0x60f012),L
	pushw	bc	; F7584D  push BC
	pushw	de	; F7584E  push DE
	call	T_PartSound_ToProgramChange	; F7584F  call 0xf41008
	popw	de	; F75853  pop DE
	popw	bc	; F75854  pop BC
	ld	a, (3184:16)	; F75855  ld A,(0x0c70)
	or	a, 176	; F75859  or A,0xb0
	xor	w, w	; F7585C  xor W,W
	ld	l, (SoundConv_Result1:24)	; F7585E  ld L,(0x60f015)
	pushw	wa	; F75863  push WA
	pushw	bc	; F75864  push BC
	pushw	de	; F75865  push DE
	call	SmfSize_WriteChannelEvent	; F75866  call 0xf7626a
	popw	de	; F7586A  pop DE
	popw	bc	; F7586B  pop BC
	popw	wa	; F7586C  pop WA
	ld	w, 32:opc	; F7586D  ld W,0x20
	ld	l, (SoundConv_Result0:24)	; F7586F  ld L,(0x60f014)
	pushw	bc	; F75874  push BC
	pushw	de	; F75875  push DE
	call	SmfSize_WriteChannelEvent	; F75876  call 0xf7626a
	popw	de	; F7587A  pop DE
	popw	bc	; F7587B  pop BC
	ld	a, (3184:16)	; F7587C  ld A,(0x0c70)
	or	a, 192	; F75880  or A,0xc0
	ld	w, (SoundConv_Result2:24)	; F75883  ld W,(0x60f016)
	and	w, 127	; F75888  and W,0x7f
	pushw	bc	; F7588B  push BC
	pushw	de	; F7588C  push DE
	calr	SmfSize_WriteChannelEvent	; F7588D  calr 0xf7626a
	popw	de	; F75890  pop DE
	popw	bc	; F75891  pop BC
	jrl	SmfSize_Pass_Join3	; F75892  jrl T,0xf758d8
SmfSize_Pass_Skip4:
	ld	a, (3184:16)	; F75895  ld A,(0x0c70)
	or	a, 176	; F75899  or A,0xb0
	ld	w, 0:opc	; F7589C  ld W,0x00
	ld	l, d	; F7589E  ld L,D
	and	l, 56	; F758A0  and L,0x38
	srl	l, 3	; F758A3  srl 0x03,L
	pushw	bc	; F758A6  push BC
	pushw	de	; F758A7  push DE
	calr	SmfSize_WriteChannelEvent	; F758A8  calr 0xf7626a
	popw	de	; F758AB  pop DE
	popw	bc	; F758AC  pop BC
	ld	a, (3184:16)	; F758AD  ld A,(0x0c70)
	or	a, 176	; F758B1  or A,0xb0
	ld	w, 32:opc	; F758B4  ld W,0x20
	ld	l, d	; F758B6  ld L,D
	and	l, 7	; F758B8  and L,0x07
	sla	l, 4	; F758BB  sla 0x04,L
	pushw	bc	; F758BE  push BC
	pushw	de	; F758BF  push DE
	calr	SmfSize_WriteChannelEvent	; F758C0  calr 0xf7626a
	popw	de	; F758C3  pop DE
	popw	bc	; F758C4  pop BC
	ld	a, (3184:16)	; F758C5  ld A,(0x0c70)
	or	a, 192	; F758C9  or A,0xc0
	ld	w, c	; F758CC  ld W,C
	and	w, 127	; F758CE  and W,0x7f
	pushw	bc	; F758D1  push BC
	pushw	de	; F758D2  push DE
	calr	SmfSize_WriteChannelEvent	; F758D3  calr 0xf7626a
	popw	de	; F758D6  pop DE
	popw	bc	; F758D7  pop BC
SmfSize_Pass_Join3:
	ld	a, (3184:16)	; F758D8  ld A,(0x0c70)
	or	a, 176	; F758DC  or A,0xb0
	ld	w, 7:opc	; F758DF  ld W,0x07
	ld	l, b	; F758E1  ld L,B
	pushw	wa	; F758E3  push WA
	pushw	de	; F758E4  push DE
	calr	SmfSize_WriteChannelEvent	; F758E5  calr 0xf7626a
	popw	de	; F758E8  pop DE
	popw	wa	; F758E9  pop WA
	ld	w, 93:opc	; F758EA  ld W,0x5d
	ld	l, (4763:16)	; F758EC  ld L,(0x129b)
	pushw	wa	; F758F0  push WA
	pushw	de	; F758F1  push DE
	calr	SmfSize_WriteChannelEvent	; F758F2  calr 0xf7626a
	popw	de	; F758F5  pop DE
	popw	wa	; F758F6  pop WA
	ld	w, 94:opc	; F758F7  ld W,0x5e
	ld	l, (4944:16)	; F758F9  ld L,(0x1350)
	pushw	wa	; F758FD  push WA
	pushw	de	; F758FE  push DE
	calr	SmfSize_WriteChannelEvent	; F758FF  calr 0xf7626a
	popw	de	; F75902  pop DE
	popw	wa	; F75903  pop WA
	ld	w, 91:opc	; F75904  ld W,0x5b
	ld	l, (4686:16)	; F75906  ld L,(0x124e)
	pushw	wa	; F7590A  push WA
	calr	SmfSize_WriteChannelEvent	; F7590B  calr 0xf7626a
	popw	wa	; F7590E  pop WA
	ld	l, (3184:16)	; F7590F  ld L,(0x0c70)
	xor	h, h	; F75913  xor H,H
	push	xix	; F75915  push XIX
	ld	xix, BStore_TrackToPart	; F75916  ld XIX,0x00603422
	ld	l, (xix+hl)	; F7591B  ld L,(XIX+HL)
	pop	xix	; F75920  pop XIX
	ld	b, l	; F75921  ld B,L
	xor	h, h	; F75923  xor H,H
	sla	l, 1	; F75925  sla 0x01,L
	push	xde	; F75928  push XDE
	ld	xde, SmfPartOffsets_F760E0	; F75929  ld XDE,0x00f760e0
	ld	hl, (xde+hl)	; F7592E  ld HL,(XDE+HL)
	pop	xde	; F75933  pop XDE
	cp	hl, 65535	; F75934  cp HL,0xffff
	jrl	z, SmfSize_Pass_Skip5	; F75938  jrl Z,0xf75a5e
	ld	a, (3184:16)	; F7593B  ld A,(0x0c70)
	or	a, 176	; F7593F  or A,0xb0
	ld	c, l	; F75942  ld C,L
	ld	xiy, 6305440	; F75944  ld XIY,0x006036a0
	ldfr_lerp	xiy, 0x38	; F75949  ld XDE3,XIY
	lda	xiy, (xiy+hl)	; F7594C  lda XIY,XIY+HL
	ld	l, (xiy+10)	; F75951  ld L,(XIY+0x0a)
	ldto_lerp	xiy, 0x38	; F75954  ld XIY,XDE3
	ld	w, 10:opc	; F75957  ld W,0x0a
	pushw	wa	; F75959  push WA
	calr	SmfSize_WriteChannelEvent	; F7595A  calr 0xf7626a
	popw	wa	; F7595D  pop WA
	ld	w, 101:opc	; F7595E  ld W,0x65
	ld	l, 0:opc	; F75960  ld L,0x00
	pushw	wa	; F75962  push WA
	calr	SmfSize_WriteChannelEvent	; F75963  calr 0xf7626a
	popw	wa	; F75966  pop WA
	ld	w, 100:opc	; F75967  ld W,0x64
	ld	l, 1:opc	; F75969  ld L,0x01
	pushw	wa	; F7596B  push WA
	calr	SmfSize_WriteChannelEvent	; F7596C  calr 0xf7626a
	popw	wa	; F7596F  pop WA
	ld	l, (3184:16)	; F75970  ld L,(0x0c70)
	xor	h, h	; F75974  xor H,H
	push	xix	; F75976  push XIX
	ld	xix, BStore_TrackToPart	; F75977  ld XIX,0x00603422
	ld	l, (xix+hl)	; F7597C  ld L,(XIX+HL)
	sla	hl, 1	; F75981  sla 0x01,HL
	ld	xix, SmfPartOffsets_F760E0	; F75984  ld XIX,0x00f760e0
	ld	hl, (xix+hl)	; F75989  ld HL,(XIX+HL)
	pop	xix	; F7598E  pop XIX
	ld	xiy, 6305440	; F7598F  ld XIY,0x006036a0
	lda	xiy, (xiy+hl)	; F75994  lda XIY,XIY+HL
	ld	l, (xiy+12)	; F75999  ld L,(XIY+0x0c)
	ld	c, l	; F7599C  ld C,L
	srl	l, 1	; F7599E  srl 0x01,L
	and	l, 127	; F759A1  and L,0x7f
	ld	w, 6:opc	; F759A4  ld W,0x06
	pushw	wa	; F759A6  push WA
	pushw	bc	; F759A7  push BC
	calr	SmfSize_WriteChannelEvent	; F759A8  calr 0xf7626a
	popw	bc	; F759AB  pop BC
	popw	wa	; F759AC  pop WA
	ld	l, c	; F759AD  ld L,C
	rrc	l	; F759AF  rrc 0x01,L
	and	l, 127	; F759B2  and L,0x7f
	ld	w, 38:opc	; F759B5  ld W,0x26
	pushw	wa	; F759B7  push WA
	calr	SmfSize_WriteChannelEvent	; F759B8  calr 0xf7626a
	popw	wa	; F759BB  pop WA
	ld	w, 101:opc	; F759BC  ld W,0x65
	ld	l, 0:opc	; F759BE  ld L,0x00
	pushw	wa	; F759C0  push WA
	calr	SmfSize_WriteChannelEvent	; F759C1  calr 0xf7626a
	popw	wa	; F759C4  pop WA
	ld	w, 100:opc	; F759C5  ld W,0x64
	ld	l, 2:opc	; F759C7  ld L,0x02
	pushw	wa	; F759C9  push WA
	calr	SmfSize_WriteChannelEvent	; F759CA  calr 0xf7626a
	popw	wa	; F759CD  pop WA
	ld	l, (3184:16)	; F759CE  ld L,(0x0c70)
	xor	h, h	; F759D2  xor H,H
	push	xix	; F759D4  push XIX
	ld	xix, BStore_TrackToPart	; F759D5  ld XIX,0x00603422
	ld	l, (xix+hl)	; F759DA  ld L,(XIX+HL)
	sla	hl, 1	; F759DF  sla 0x01,HL
	ld	xix, SmfPartOffsets_F760E0	; F759E2  ld XIX,0x00f760e0
	ld	hl, (xix+hl)	; F759E7  ld HL,(XIX+HL)
	pop	xix	; F759EC  pop XIX
	ld	xiy, 6305440	; F759ED  ld XIY,0x006036a0
	ldfr_lerp	xiy, 0x38	; F759F2  ld XDE3,XIY
	lda	xiy, (xiy+hl)	; F759F5  lda XIY,XIY+HL
	ld	l, (xiy+11)	; F759FA  ld L,(XIY+0x0b)
	ldto_lerp	xiy, 0x38	; F759FD  ld XIY,XDE3
	ld	w, 6:opc	; F75A00  ld W,0x06
	pushw	wa	; F75A02  push WA
	calr	SmfSize_WriteChannelEvent	; F75A03  calr 0xf7626a
	popw	wa	; F75A06  pop WA
	ld	w, 38:opc	; F75A07  ld W,0x26
	xor	l, l	; F75A09  xor L,L
	pushw	wa	; F75A0B  push WA
	calr	SmfSize_WriteChannelEvent	; F75A0C  calr 0xf7626a
	popw	wa	; F75A0F  pop WA
	ld	w, 101:opc	; F75A10  ld W,0x65
	ld	l, 0:opc	; F75A12  ld L,0x00
	pushw	wa	; F75A14  push WA
	calr	SmfSize_WriteChannelEvent	; F75A15  calr 0xf7626a
	popw	wa	; F75A18  pop WA
	ld	w, 100:opc	; F75A19  ld W,0x64
	ld	l, 0:opc	; F75A1B  ld L,0x00
	pushw	wa	; F75A1D  push WA
	calr	SmfSize_WriteChannelEvent	; F75A1E  calr 0xf7626a
	popw	wa	; F75A21  pop WA
	ld	l, (3184:16)	; F75A22  ld L,(0x0c70)
	xor	h, h	; F75A26  xor H,H
	push	xix	; F75A28  push XIX
	ld	xix, BStore_TrackToPart	; F75A29  ld XIX,0x00603422
	ld	l, (xix+hl)	; F75A2E  ld L,(XIX+HL)
	sla	hl, 1	; F75A33  sla 0x01,HL
	ld	xix, SmfPartOffsets_F760E0	; F75A36  ld XIX,0x00f760e0
	ld	hl, (xix+hl)	; F75A3B  ld HL,(XIX+HL)
	pop	xix	; F75A40  pop XIX
	ld	xiy, 6305440	; F75A41  ld XIY,0x006036a0
	lda	xiy, (xiy+hl)	; F75A46  lda XIY,XIY+HL
	ld	l, (xiy+13)	; F75A4B  ld L,(XIY+0x0d)
	ld	w, 6:opc	; F75A4E  ld W,0x06
	pushw	wa	; F75A50  push WA
	calr	SmfSize_WriteChannelEvent	; F75A51  calr 0xf7626a
	popw	wa	; F75A54  pop WA
	ld	w, 6:opc	; F75A55  ld W,0x06
	xor	l, l	; F75A57  xor L,L
	pushw	wa	; F75A59  push WA
	calr	SmfSize_WriteChannelEvent	; F75A5A  calr 0xf7626a
	popw	wa	; F75A5D  pop WA
SmfSize_Pass_Skip5:
	inc	1, (3184:16)	; F75A5E  inc 1,(0x0c70)
	cp	(0x0c70:16), 0x0f	; F75A62  cp (0x0c70),0x0f
	jrl	ule, SmfSize_Pass_Loop2	; F75A67  jrl ULE,0xf757b6
	ld	xix, (InputStream_Cursor:16)	; F75A6A  ld XIX,(0x1088)
	add	xix, 1406	; F75A6E  add XIX,0x0000057e
SmfSize_Pass_Join4:
	cp	xix, 6335231	; F75A74  cp XIX,0x0060aaff
	jr	ule, SmfSize_Pass_Skip6	; F75A7A  jr ULE,0xf75a88
	incw	1, (SmfOut_WindowsFlushed:16)	; F75A7C  incw 1,(0x126c)
	sub	xix, 1024	; F75A80  sub XIX,0x00000400
	jr	SmfSize_Pass_Join4	; F75A86  jr T,0xf75a74
SmfSize_Pass_Skip6:
	ld	(InputStream_Cursor:16), xix	; F75A88  ld (0x1088),XIX
SmfSize_Pass_Join5:
	calr	sub_F75685_Nop	; F75A8C  calr 0xf76122
	xor	wa, wa	; F75A8F  xor WA,WA
	ld	(4226:16), wa	; F75A91  ld (0x1082),WA
	ld	(4228:16), wa	; F75A95  ld (0x1084),WA
	calr	SmfSize_ReadSongByte	; F75A99  calr 0xf76552
	cp	a, 130	; F75A9C  cp A,0x82
	jr	z, SmfSize_Pass_Skip7	; F75A9F  jr Z,0xf75ac0
	cp	a, 129	; F75AA1  cp A,0x81
	jr	z, SmfSize_Pass_Skip7	; F75AA4  jr Z,0xf75ac0
	pushw	(BStore_CursorBlock:16)	; F75AA6  pushw (0x345c)
	pushw	(BStore_CursorOffset:16)	; F75AAA  pushw (0x345e)
	calr	SmfSize_AdvanceSongCursor	; F75AAE  calr 0xf76567
	calr	SmfSize_ReadSongByte	; F75AB1  calr 0xf76552
	popw	(BStore_CursorOffset:16)	; F75AB4  popw (0x345e)
	popw	(BStore_CursorBlock:16)	; F75AB8  popw (0x345c)
	ld	(4228:16), a	; F75ABC  ld (0x1084),A
SmfSize_Pass_Skip7:
	ldw	(4230:16), 0	; F75AC0  ld (0x1086),0x0000
	ldw	(4222:16), 0	; F75AC6  ld (0x107e),0x0000
	ldw	(4224:16), 0	; F75ACC  ld (0x1080),0x0000
SmfSize_Pass_Loop4:
	xor	hl, hl	; F75AD2  xor HL,HL
	push	xhl	; F75AD4  push XHL
	calr	SmfSize_ClearEventFields	; F75AD5  calr 0xf76541
	calr	SmfSize_ReadSongByte	; F75AD8  calr 0xf76552
	pop	xhl	; F75ADB  pop XHL
	cp	a, 130	; F75ADC  cp A,0x82
	jrl	z, SmfSize_Pass_Skip42	; F75ADF  jrl Z,0xf76089
SmfSize_Pass_Loop5:
	push	xde	; F75AE2  push XDE
	ld	xde, Smf_VlqValue	; F75AE3  ld XDE,0x00001198
	ld	(xde+hl), a	; F75AE8  ld (XDE+HL),A
	pop	xde	; F75AED  pop XDE
	pushw	hl	; F75AEE  push HL
	calr	SmfSize_AdvanceSongCursor	; F75AEF  calr 0xf76567
	calr	SmfSize_ReadSongByte	; F75AF2  calr 0xf76552
	popw	hl	; F75AF5  pop HL
	inc	1, hl	; F75AF6  inc 1,HL
	bit	7, a	; F75AF8  bit 0x07,A
	jr	z, SmfSize_Pass_Loop5	; F75AFB  jr Z,0xf75ae2
	ld	a, (Smf_VlqValue:16)	; F75AFD  ld A,(0x1198)
	cp	a, 130	; F75B01  cp A,0x82
	jrl	z, SmfSize_Pass_Skip42	; F75B04  jrl Z,0xf76089
	cp	a, 129	; F75B07  cp A,0x81
	jrl	z, SmfSize_Pass_Skip8	; F75B0A  jrl Z,0xf75b3f
	ld	w, a	; F75B0D  ld W,A
	and	w, 240	; F75B0F  and W,0xf0
	cp	w, 144	; F75B12  cp W,0x90
	jrl	z, SmfSize_Pass_Skip15	; F75B15  jrl Z,0xf75c3d
	cp	w, 176	; F75B18  cp W,0xb0
	jrl	z, SmfSize_Pass_Skip20	; F75B1B  jrl Z,0xf75dc2
	cp	w, 192	; F75B1E  cp W,0xc0
	jrl	z, SmfSize_Pass_Skip17	; F75B21  jrl Z,0xf75cb2
	cp	w, 208	; F75B24  cp W,0xd0
	jrl	z, SmfSize_Pass_Skip12	; F75B27  jrl Z,0xf75bd1
	cp	w, 240	; F75B2A  cp W,0xf0
	jrl	z, SmfSize_Pass_Skip14	; F75B2D  jrl Z,0xf75c13
	cp	w, 160	; F75B30  cp W,0xa0
	jrl	z, SmfSize_Pass_Skip10	; F75B33  jrl Z,0xf75b73
	cp	w, 224	; F75B36  cp W,0xe0
	jrl	z, SmfSize_Pass_Skip13	; F75B39  jrl Z,0xf75bf4
	jrl	SmfSize_Pass_Loop4	; F75B3C  jrl T,0xf75ad2
SmfSize_Pass_Skip8:
	incw	1, (4230:16)	; F75B3F  incw 1,(0x1086)
SmfSize_Pass_Join6:
	calr	SmfSize_ReadSongByte	; F75B43  calr 0xf76552
	cp	a, 129	; F75B46  cp A,0x81
	jr	nz, SmfSize_Pass_Skip9	; F75B49  jr NZ,0xf75b54
	incw	1, (4230:16)	; F75B4B  incw 1,(0x1086)
	calr	SmfSize_AdvanceSongCursor	; F75B4F  calr 0xf76567
	jr	SmfSize_Pass_Join6	; F75B52  jr T,0xf75b43
SmfSize_Pass_Skip9:
	ld	wa, (4230:16)	; F75B54  ld WA,(0x1086)
	ldw	de, 96	; F75B58  ld DE,0x0060
	extz	xwa	; F75B5B  extz XWA
	muls	xwa, de	; F75B5D  muls XWA,DE
	ld	de, qwa	; F75B5F  ld DE,QWA
	add	(0x107e:16), wa	; F75B62  add (0x107e),WA
	ld	(4224:16), de	; F75B66  ld (0x1080),DE
	ldw	(4230:16), 0	; F75B6A  ld (0x1086),0x0000
	jrl	SmfSize_Pass_Loop4	; F75B70  jrl T,0xf75ad2
SmfSize_Pass_Skip10:
	cp	hl, 3:i3	; F75B73  cp HL,3
	jr	z, SmfSize_Pass_Skip11	; F75B75  jr Z,0xf75bb3
	cp	hl, 4:i3	; F75B77  cp HL,4
	jrl	nz, SmfSize_Pass_Loop4	; F75B79  jrl NZ,0xf75ad2
	ld	c, (4505:16)	; F75B7C  ld C,(0x1199)
	calr	SmfSize_EncodeDeltaTime	; F75B80  calr 0xf76219
	calr	SmfSize_AgePendingNoteOffs	; F75B83  calr 0xf762df
	ld	hl, (4506:16)	; F75B86  ld HL,(0x119a)
	and	l, 127	; F75B8A  and L,0x7f
	and	h, 1	; F75B8D  and H,0x01
	rrc	h	; F75B90  rrc 0x01,H
	and	h, 128	; F75B93  and H,0x80
	or	l, h	; F75B96  or L,H
	xor	h, h	; F75B98  xor H,H
	pushw	wa	; F75B9A  push WA
	ld	w, (4507:16)	; F75B9B  ld W,(0x119b)
	and	w, 2	; F75B9F  and W,0x02
	srl	w, 1	; F75BA2  srl 0x01,W
	xor	a, a	; F75BA5  xor A,A
	or	hl, wa	; F75BA7  or HL,WA
	popw	wa	; F75BA9  pop WA
	calr	SmfSize_StageTempo	; F75BAA  calr 0xf7615b
	calr	SmfSize_WriteTempoEvent	; F75BAD  calr 0xf761a1
	jrl	SmfSize_Pass_Loop4	; F75BB0  jrl T,0xf75ad2
SmfSize_Pass_Skip11:
	ld	c, (4505:16)	; F75BB3  ld C,(0x1199)
	pushw	wa	; F75BB7  push WA
	calr	SmfSize_EncodeDeltaTime	; F75BB8  calr 0xf76219
	calr	SmfSize_AgePendingNoteOffs	; F75BBB  calr 0xf762df
	popw	wa	; F75BBE  pop WA
	and	a, 15	; F75BBF  and A,0x0f
	or	a, 208	; F75BC2  or A,0xd0
	ld	w, (4506:16)	; F75BC5  ld W,(0x119a)
	xor	l, l	; F75BC9  xor L,L
	calr	SmfSize_WriteChannelEvent	; F75BCB  calr 0xf7626a
	jrl	SmfSize_Pass_Loop4	; F75BCE  jrl T,0xf75ad2
SmfSize_Pass_Skip12:
	cp	hl, 3:i3	; F75BD1  cp HL,3
	jrl	nz, SmfSize_Pass_Loop4	; F75BD3  jrl NZ,0xf75ad2
	ld	c, (4505:16)	; F75BD6  ld C,(0x1199)
	pushw	wa	; F75BDA  push WA
	calr	SmfSize_EncodeDeltaTime	; F75BDB  calr 0xf76219
	calr	SmfSize_AgePendingNoteOffs	; F75BDE  calr 0xf762df
	popw	wa	; F75BE1  pop WA
	and	a, 15	; F75BE2  and A,0x0f
	or	a, 176	; F75BE5  or A,0xb0
	ld	w, 1:opc	; F75BE8  ld W,0x01
	ld	l, (4506:16)	; F75BEA  ld L,(0x119a)
	calr	SmfSize_WriteChannelEvent	; F75BEE  calr 0xf7626a
	jrl	SmfSize_Pass_Loop4	; F75BF1  jrl T,0xf75ad2
SmfSize_Pass_Skip13:
	cp	hl, 4:i3	; F75BF4  cp HL,4
	jrl	nz, SmfSize_Pass_Loop4	; F75BF6  jrl NZ,0xf75ad2
	ld	c, (4505:16)	; F75BF9  ld C,(0x1199)
	pushw	wa	; F75BFD  push WA
	calr	SmfSize_EncodeDeltaTime	; F75BFE  calr 0xf76219
	calr	SmfSize_AgePendingNoteOffs	; F75C01  calr 0xf762df
	popw	wa	; F75C04  pop WA
	ld	w, (4506:16)	; F75C05  ld W,(0x119a)
	ld	l, (4507:16)	; F75C09  ld L,(0x119b)
	calr	SmfSize_WriteChannelEvent	; F75C0D  calr 0xf7626a
	jrl	SmfSize_Pass_Loop4	; F75C10  jrl T,0xf75ad2
SmfSize_Pass_Skip14:
	cp	hl, 3:i3	; F75C13  cp HL,3
	jrl	nz, SmfSize_Pass_Loop4	; F75C15  jrl NZ,0xf75ad2
	ld	l, a	; F75C18  ld L,A
	and	l, 15	; F75C1A  and L,0x0f
	xor	h, h	; F75C1D  xor H,H
	ld	c, (4505:16)	; F75C1F  ld C,(0x1199)
	pushw	wa	; F75C23  push WA
	calr	SmfSize_EncodeDeltaTime	; F75C24  calr 0xf76219
	calr	SmfSize_AgePendingNoteOffs	; F75C27  calr 0xf762df
	popw	wa	; F75C2A  pop WA
	and	a, 15	; F75C2B  and A,0x0f
	or	a, 176	; F75C2E  or A,0xb0
	ld	w, 11:opc	; F75C31  ld W,0x0b
	ld	l, (4506:16)	; F75C33  ld L,(0x119a)
	calr	SmfSize_WriteChannelEvent	; F75C37  calr 0xf7626a
	jrl	SmfSize_Pass_Loop4	; F75C3A  jrl T,0xf75ad2
SmfSize_Pass_Skip15:
	cp	hl, 6:i3	; F75C3D  cp HL,6
	jrl	nz, SmfSize_Pass_Loop4	; F75C3F  jrl NZ,0xf75ad2
	xor	hl, hl	; F75C42  xor HL,HL
SmfSize_Pass_Loop6:
	push	xde	; F75C44  push XDE
	ld	xde, 12378	; F75C45  ld XDE,0x0000305a
	bit	7, (xde+hl)	; F75C4A  bit 7,(XDE+HL)
	pop	xde	; F75C4F  pop XDE
	jr	z, SmfSize_Pass_Skip16	; F75C50  jr Z,0xf75c5f
	add	hl, 5	; F75C52  add HL,0x0005
	cp	hl, 160	; F75C56  cp HL,0x00a0
	jr	ule, SmfSize_Pass_Loop6	; F75C5A  jr ULE,0xf75c44
	jrl	SmfSize_Pass_Loop4	; F75C5C  jrl T,0xf75ad2
SmfSize_Pass_Skip16:
	or	(0x11b1:16), 0x01	; F75C5F  or (0x11b1),0x01
	pushw	hl	; F75C64  push HL
	ld	c, (4505:16)	; F75C65  ld C,(0x1199)
	calr	SmfSize_EncodeDeltaTime	; F75C69  calr 0xf76219
	calr	SmfSize_AgePendingNoteOffs	; F75C6C  calr 0xf762df
	ld	a, (Smf_VlqValue:16)	; F75C6F  ld A,(0x1198)
	ld	w, (4506:16)	; F75C73  ld W,(0x119a)
	ld	l, (4507:16)	; F75C77  ld L,(0x119b)
	calr	SmfSize_WriteChannelEvent	; F75C7B  calr 0xf7626a
	popw	hl	; F75C7E  pop HL
	ld	xix, 12378	; F75C7F  ld XIX,0x0000305a
	lda	xix, (xix+hl)	; F75C84  lda XIX,XIX+HL
	ld	a, 128:opc	; F75C89  ld A,0x80
	ld	(xix+), a	; F75C8B  ld (XIX+),A
	ld	a, (Smf_VlqValue:16)	; F75C8E  ld A,(0x1198)
	ld	(xix+), a	; F75C92  ld (XIX+),A
	ld	a, (4506:16)	; F75C95  ld A,(0x119a)
	ld	(xix+), a	; F75C99  ld (XIX+),A
	ld	a, (4509:16)	; F75C9C  ld A,(0x119d)
	ld	w, 96:opc	; F75CA0  ld W,0x60
	muls	wa, w	; F75CA2  muls WA,W
	xor	hl, hl	; F75CA4  xor HL,HL
	ld	l, (4508:16)	; F75CA6  ld L,(0x119c)
	add	wa, hl	; F75CAA  add WA,HL
	ld	(xix+), wa	; F75CAC  ld (XIX+),WA
	jrl	SmfSize_Pass_Loop4	; F75CAF  jrl T,0xf75ad2
SmfSize_Pass_Skip17:
	cp	hl, 6:i3	; F75CB2  cp HL,6
	jrl	nz, SmfSize_Pass_Loop4	; F75CB4  jrl NZ,0xf75ad2
	cp	(0x119a:16), 0x7f	; F75CB7  cp (0x119a),0x7f
	jrl	z, SmfSize_Pass_Loop4	; F75CBC  jrl Z,0xf75ad2
	ld	a, (4507:16)	; F75CBF  ld A,(0x119b)
	cp	a, 0:i3	; F75CC3  cp A,0
	jrl	nz, SmfSize_Pass_Loop4	; F75CC5  jrl NZ,0xf75ad2
	bit	0, (0x133e:16)	; F75CC8  bit 0,(0x133e)
	jr	z, SmfSize_Pass_Skip18	; F75CCC  jr Z,0xf75cd5
	bit	0, (0x11b1:16)	; F75CCE  bit 0,(0x11b1)
	jrl	z, SmfSize_Pass_Loop4	; F75CD2  jrl Z,0xf75ad2
SmfSize_Pass_Skip18:
	ld	c, (4505:16)	; F75CD5  ld C,(0x1199)
	pushw	wa	; F75CD9  push WA
	calr	SmfSize_EncodeDeltaTime	; F75CDA  calr 0xf76219
	calr	SmfSize_AgePendingNoteOffs	; F75CDD  calr 0xf762df
	popw	wa	; F75CE0  pop WA
	cp	(0x1239:16), 0x00	; F75CE1  cp (0x1239),0x00
	jrl	z, SmfSize_Pass_Skip19	; F75CE6  jrl Z,0xf75d7f
	ld	l, (Smf_VlqValue:16)	; F75CE9  ld L,(0x1198)
	ld	h, l	; F75CED  ld H,L
	and	l, 1	; F75CEF  and L,0x01
	rrc	l	; F75CF2  rrc 0x01,L
	ld	a, (4508:16)	; F75CF5  ld A,(0x119c)
	or	l, a	; F75CF9  or L,A
	ld	(SoundConv_Arg0:24), l	; F75CFB  ld (0x60f010),L
	and	h, 2	; F75D00  and H,0x02
	.byte 0xCE, 0xE9, 0x02	; F75D03  rrc 0x02,H   [llvm-mc cannot encode this]
	ld	a, (4509:16)	; F75D06  ld A,(0x119d)
	and	a, 127	; F75D0A  and A,0x7f
	or	h, a	; F75D0D  or H,A
	ld	(SoundConv_Arg1:24), h	; F75D0F  ld (0x60f011),H
	push	xix	; F75D14  push XIX
	xor	hl, hl	; F75D15  xor HL,HL
	ld	l, (4506:16)	; F75D17  ld L,(0x119a)
	ld	xix, BStore_TrackToPart	; F75D1B  ld XIX,0x00603422
	ld	l, (xix+hl)	; F75D20  ld L,(XIX+HL)
	ld	xix, ByteMap_F7609E	; F75D25  ld XIX,0x00f7609e
	ld	l, (xix+hl)	; F75D2A  ld L,(XIX+HL)
	ld	(SoundConv_Arg2:24), l	; F75D2F  ld (0x60f012),L
	pop	xix	; F75D34  pop XIX
	call	T_PartSound_ToProgramChange	; F75D35  call 0xf41008
	ld	a, 176:opc	; F75D39  ld A,0xb0
	ld	w, (4506:16)	; F75D3B  ld W,(0x119a)
	and	w, 15	; F75D3F  and W,0x0f
	or	a, w	; F75D42  or A,W
	xor	w, w	; F75D44  xor W,W
	ld	l, (SoundConv_Result1:24)	; F75D46  ld L,(0x60f015)
	pushw	wa	; F75D4B  push WA
	call	SmfSize_WriteChannelEvent	; F75D4C  call 0xf7626a
	popw	wa	; F75D50  pop WA
	ldw	(Smf_VlqBytes:16), 0	; F75D51  ld (0x1193),0x0000
	ld	(4501:16), 0	; F75D57  ld (0x1195),0x00
	ld	w, 32:opc	; F75D5C  ld W,0x20
	ld	l, (SoundConv_Result0:24)	; F75D5E  ld L,(0x60f014)
	call	SmfSize_WriteChannelEvent	; F75D63  call 0xf7626a
	ld	a, 192:opc	; F75D67  ld A,0xc0
	ld	w, (4506:16)	; F75D69  ld W,(0x119a)
	and	w, 15	; F75D6D  and W,0x0f
	or	a, w	; F75D70  or A,W
	ld	w, (SoundConv_Result2:24)	; F75D72  ld W,(0x60f016)
	xor	l, l	; F75D77  xor L,L
	calr	SmfSize_WriteChannelEvent	; F75D79  calr 0xf7626a
	jrl	SmfSize_Pass_Loop4	; F75D7C  jrl T,0xf75ad2
SmfSize_Pass_Skip19:
	ld	w, 0:opc	; F75D7F  ld W,0x00
	ld	l, (4509:16)	; F75D81  ld L,(0x119d)
	and	l, 56	; F75D85  and L,0x38
	srl	l, 3	; F75D88  srl 0x03,L
	calr	SmfSize_WriteControlChange	; F75D8B  calr 0xf7620b
	ldw	(Smf_VlqBytes:16), 0	; F75D8E  ld (0x1193),0x0000
	ld	(4501:16), 0	; F75D94  ld (0x1195),0x00
	ld	w, 32:opc	; F75D99  ld W,0x20
	ld	l, (4509:16)	; F75D9B  ld L,(0x119d)
	and	l, 7	; F75D9F  and L,0x07
	sla	l, 4	; F75DA2  sla 0x04,L
	and	l, 127	; F75DA5  and L,0x7f
	calr	SmfSize_WriteControlChange	; F75DA8  calr 0xf7620b
	ld	a, 192:opc	; F75DAB  ld A,0xc0
	ld	w, (4506:16)	; F75DAD  ld W,(0x119a)
	and	w, 15	; F75DB1  and W,0x0f
	or	a, w	; F75DB4  or A,W
	ld	w, (4508:16)	; F75DB6  ld W,(0x119c)
	xor	l, l	; F75DBA  xor L,L
	calr	SmfSize_WriteChannelEvent	; F75DBC  calr 0xf7626a
	jrl	SmfSize_Pass_Loop4	; F75DBF  jrl T,0xf75ad2
SmfSize_Pass_Skip20:
	cp	hl, 6:i3	; F75DC2  cp HL,6
	jrl	nz, SmfSize_Pass_Loop4	; F75DC4  jrl NZ,0xf75ad2
	cp	(0x119a:16), 0x7f	; F75DC7  cp (0x119a),0x7f
	jrl	z, SmfSize_Pass_Skip41	; F75DCC  jrl Z,0xf76086
	ld	l, (4507:16)	; F75DCF  ld L,(0x119b)
	ld	a, (4506:16)	; F75DD3  ld A,(0x119a)
	ld	w, (Smf_VlqValue:16)	; F75DD7  ld W,(0x1198)
	and	w, 4	; F75DDB  and W,0x04
	sla	w, 5	; F75DDE  sla 0x05,W
	or	a, w	; F75DE1  or A,W
	cp	a, 181	; F75DE3  cp A,0xb5
	jr	z, SmfSize_Pass_Skip21	; F75DE6  jr Z,0xf75e08
	cp	a, 188	; F75DE8  cp A,0xbc
	jr	z, SmfSize_Pass_Skip21	; F75DEB  jr Z,0xf75e08
	cp	a, 189	; F75DED  cp A,0xbd
	jr	z, SmfSize_Pass_Skip21	; F75DF0  jr Z,0xf75e08
	cp	a, 184	; F75DF2  cp A,0xb8
	jr	z, SmfSize_Pass_Skip21	; F75DF5  jr Z,0xf75e08
	cp	a, 185	; F75DF7  cp A,0xb9
	jr	z, SmfSize_Pass_Skip21	; F75DFA  jr Z,0xf75e08
	cp	a, 186	; F75DFC  cp A,0xba
	jr	z, SmfSize_Pass_Skip21	; F75DFF  jr Z,0xf75e08
	cp	a, 187	; F75E01  cp A,0xbb
	jr	z, SmfSize_Pass_Skip21	; F75E04  jr Z,0xf75e08
	jr	SmfSize_Pass_Join7	; F75E06  jr T,0xf75e7a
SmfSize_Pass_Skip21:
	ld	l, (4507:16)	; F75E08  ld L,(0x119b)
	cp	l, 127	; F75E0C  cp L,0x7f
	jrl	z, SmfSize_Pass_Skip41	; F75E0F  jrl Z,0xf76086
	cp	a, 181	; F75E12  cp A,0xb5
	jrl	z, SmfSize_Pass_Skip22	; F75E15  jrl Z,0xf75e56
	cp	a, 188	; F75E18  cp A,0xbc
	jrl	z, SmfSize_Pass_Skip22	; F75E1B  jrl Z,0xf75e56
	cp	a, 189	; F75E1E  cp A,0xbd
	jrl	z, SmfSize_Pass_Skip22	; F75E21  jrl Z,0xf75e56
	cp	a, 184	; F75E24  cp A,0xb8
	jrl	z, SmfSize_Pass_Skip22	; F75E27  jrl Z,0xf75e56
	cp	a, 185	; F75E2A  cp A,0xb9
	jrl	z, SmfSize_Pass_Skip22	; F75E2D  jrl Z,0xf75e56
	cp	a, 186	; F75E30  cp A,0xba
	jrl	z, SmfSize_Pass_Skip22	; F75E33  jrl Z,0xf75e56
	cp	a, 187	; F75E36  cp A,0xbb
	jrl	z, SmfSize_Pass_Skip22	; F75E39  jrl Z,0xf75e56
	cp	l, 0:i3	; F75E3C  cp L,0
	jrl	c, SmfSize_Pass_Skip41	; F75E3E  jrl C,0xf76086
	cp	l, 16	; F75E41  cp L,0x10
	jrl	ugt, SmfSize_Pass_Skip41	; F75E44  jrl UGT,0xf76086
	jrl	SmfSize_Pass_Loop4	; F75E47  jrl T,0xf75ad2
	jrl	SmfSize_Pass_Loop4	; F75E4A  jrl T,0xf75ad2
	jrl	SmfSize_Pass_Loop4	; F75E4D  jrl T,0xf75ad2
	jrl	SmfSize_Pass_Loop4	; F75E50  jrl T,0xf75ad2
	jrl	SmfSize_Pass_Loop4	; F75E53  jrl T,0xf75ad2
SmfSize_Pass_Skip22:
	ld	c, (4505:16)	; F75E56  ld C,(0x1199)
	pushw	wa	; F75E5A  push WA
	pushw	hl	; F75E5B  push HL
	calr	SmfSize_EncodeDeltaTime	; F75E5C  calr 0xf76219
	calr	SmfSize_AgePendingNoteOffs	; F75E5F  calr 0xf762df
	popw	hl	; F75E62  pop HL
	popw	wa	; F75E63  pop WA
	ld	a, 176:opc	; F75E64  ld A,0xb0
	ld	w, l	; F75E66  ld W,L
	and	w, 15	; F75E68  and W,0x0f
	or	a, w	; F75E6B  or A,W
	ld	w, 64:opc	; F75E6D  ld W,0x40
	ld	l, (4508:16)	; F75E6F  ld L,(0x119c)
	call	SmfSize_WriteChannelEvent	; F75E73  call 0xf7626a
	jrl	SmfSize_Pass_Loop4	; F75E77  jrl T,0xf75ad2
SmfSize_Pass_Join7:
	cp	l, 3:i3	; F75E7A  cp L,3
	jrl	c, SmfSize_Pass_Loop4	; F75E7C  jrl C,0xf75ad2
	cp	l, 11	; F75E7F  cp L,0x0b
	jrl	ugt, SmfSize_Pass_Loop4	; F75E82  jrl UGT,0xf75ad2
	ld	a, 176:opc	; F75E85  ld A,0xb0
	ld	w, (4506:16)	; F75E87  ld W,(0x119a)
	and	w, 15	; F75E8B  and W,0x0f
	or	a, w	; F75E8E  or A,W
	ld	w, 7:opc	; F75E90  ld W,0x07
	cp	l, 3:i3	; F75E92  cp L,3
	jrl	z, SmfSize_Pass_Skip39	; F75E94  jrl Z,0xf76061
	cp	l, 4:i3	; F75E97  cp L,4
	jrl	z, SmfSize_Pass_Skip31	; F75E99  jrl Z,0xf76005
	cp	l, 5:i3	; F75E9C  cp L,5
	jrl	z, SmfSize_Pass_Skip32	; F75E9E  jrl Z,0xf7600c
	cp	l, 6:i3	; F75EA1  cp L,6
	jrl	z, SmfSize_Pass_Skip34	; F75EA3  jrl Z,0xf76021
	cp	l, 7:i3	; F75EA6  cp L,7
	jrl	z, SmfSize_Pass_Skip37	; F75EA8  jrl Z,0xf76047
	cp	l, 8	; F75EAB  cp L,0x08
	jrl	z, SmfSize_Pass_Skip29	; F75EAE  jrl Z,0xf75fd3
	cp	l, 9	; F75EB1  cp L,0x09
	jrl	z, SmfSize_Pass_Skip27	; F75EB4  jrl Z,0xf75f83
	cp	l, 10	; F75EB7  cp L,0x0a
	jr	z, SmfSize_Pass_Skip23	; F75EBA  jr Z,0xf75ec4
	cp	l, 11	; F75EBC  cp L,0x0b
	jr	z, SmfSize_Pass_Skip25	; F75EBF  jr Z,0xf75f30
	jrl	nz, SmfSize_Pass_Loop4	; F75EC1  jrl NZ,0xf75ad2
SmfSize_Pass_Skip23:
	bit	0, (0x133e:16)	; F75EC4  bit 0,(0x133e)
	jrl	z, SmfSize_Pass_Skip24	; F75EC8  jrl Z,0xf75ed2
	bit	0, (0x11b1:16)	; F75ECB  bit 0,(0x11b1)
	jrl	z, SmfSize_Pass_Loop4	; F75ECF  jrl Z,0xf75ad2
SmfSize_Pass_Skip24:
	ld	c, (4505:16)	; F75ED2  ld C,(0x1199)
	pushw	wa	; F75ED6  push WA
	push	xhl	; F75ED7  push XHL
	calr	SmfSize_EncodeDeltaTime	; F75ED8  calr 0xf76219
	calr	SmfSize_AgePendingNoteOffs	; F75EDB  calr 0xf762df
	pop	xhl	; F75EDE  pop XHL
	popw	wa	; F75EDF  pop WA
	ld	a, 176:opc	; F75EE0  ld A,0xb0
	ld	w, (4506:16)	; F75EE2  ld W,(0x119a)
	and	w, 15	; F75EE6  and W,0x0f
	or	a, w	; F75EE9  or A,W
	ld	w, 101:opc	; F75EEB  ld W,0x65
	ld	l, 0:opc	; F75EED  ld L,0x00
	pushw	wa	; F75EEF  push WA
	calr	SmfSize_WriteChannelEvent	; F75EF0  calr 0xf7626a
	popw	wa	; F75EF3  pop WA
	ld	w, 100:opc	; F75EF4  ld W,0x64
	ld	l, 1:opc	; F75EF6  ld L,0x01
	ld	(Smf_VlqBytes:16), 0	; F75EF8  ld (0x1193),0x00
	pushw	wa	; F75EFD  push WA
	calr	SmfSize_WriteChannelEvent	; F75EFE  calr 0xf7626a
	popw	wa	; F75F01  pop WA
	ld	w, 6:opc	; F75F02  ld W,0x06
	ld	l, (4508:16)	; F75F04  ld L,(0x119c)
	ld	h, (Smf_VlqValue:16)	; F75F08  ld H,(0x1198)
	and	h, 1	; F75F0C  and H,0x01
	.byte 0xCE, 0xE9, 0x02	; F75F0F  rrc 0x02,H   [llvm-mc cannot encode this]
	srl	l, 1	; F75F12  srl 0x01,L
	or	l, h	; F75F15  or L,H
	pushw	wa	; F75F17  push WA
	calr	SmfSize_WriteChannelEvent	; F75F18  calr 0xf7626a
	popw	wa	; F75F1B  pop WA
	ld	w, 38:opc	; F75F1C  ld W,0x26
	ld	l, (4508:16)	; F75F1E  ld L,(0x119c)
	and	l, 1	; F75F22  and L,0x01
	.byte 0xCF, 0xE9, 0x02	; F75F25  rrc 0x02,L   [llvm-mc cannot encode this]
	pushw	wa	; F75F28  push WA
	calr	SmfSize_WriteChannelEvent	; F75F29  calr 0xf7626a
	popw	wa	; F75F2C  pop WA
	jrl	SmfSize_Pass_Loop4	; F75F2D  jrl T,0xf75ad2
SmfSize_Pass_Skip25:
	bit	0, (0x133e:16)	; F75F30  bit 0,(0x133e)
	jrl	z, SmfSize_Pass_Skip26	; F75F34  jrl Z,0xf75f3e
	bit	0, (0x11b1:16)	; F75F37  bit 0,(0x11b1)
	jrl	z, SmfSize_Pass_Loop4	; F75F3B  jrl Z,0xf75ad2
SmfSize_Pass_Skip26:
	ld	c, (4505:16)	; F75F3E  ld C,(0x1199)
	pushw	wa	; F75F42  push WA
	pushw	hl	; F75F43  push HL
	calr	SmfSize_EncodeDeltaTime	; F75F44  calr 0xf76219
	calr	SmfSize_AgePendingNoteOffs	; F75F47  calr 0xf762df
	popw	hl	; F75F4A  pop HL
	popw	wa	; F75F4B  pop WA
	ld	a, 176:opc	; F75F4C  ld A,0xb0
	ld	w, (4506:16)	; F75F4E  ld W,(0x119a)
	and	w, 15	; F75F52  and W,0x0f
	or	a, w	; F75F55  or A,W
	ld	w, 101:opc	; F75F57  ld W,0x65
	ld	l, 0:opc	; F75F59  ld L,0x00
	pushw	wa	; F75F5B  push WA
	calr	SmfSize_WriteChannelEvent	; F75F5C  calr 0xf7626a
	popw	wa	; F75F5F  pop WA
	ld	w, 100:opc	; F75F60  ld W,0x64
	ld	l, 0:opc	; F75F62  ld L,0x00
	ld	(Smf_VlqBytes:16), 0	; F75F64  ld (0x1193),0x00
	pushw	wa	; F75F69  push WA
	calr	SmfSize_WriteChannelEvent	; F75F6A  calr 0xf7626a
	popw	wa	; F75F6D  pop WA
	ld	w, 6:opc	; F75F6E  ld W,0x06
	ld	l, (4508:16)	; F75F70  ld L,(0x119c)
	pushw	wa	; F75F74  push WA
	calr	SmfSize_WriteChannelEvent	; F75F75  calr 0xf7626a
	popw	wa	; F75F78  pop WA
	ld	w, 38:opc	; F75F79  ld W,0x26
	ld	l, 0:opc	; F75F7B  ld L,0x00
	calr	SmfSize_WriteChannelEvent	; F75F7D  calr 0xf7626a
	jrl	SmfSize_Pass_Loop4	; F75F80  jrl T,0xf75ad2
SmfSize_Pass_Skip27:
	bit	0, (0x133e:16)	; F75F83  bit 0,(0x133e)
	jr	z, SmfSize_Pass_Skip28	; F75F87  jr Z,0xf75f90
	bit	0, (0x11b1:16)	; F75F89  bit 0,(0x11b1)
	jrl	z, SmfSize_Pass_Loop4	; F75F8D  jrl Z,0xf75ad2
SmfSize_Pass_Skip28:
	ld	c, (4505:16)	; F75F90  ld C,(0x1199)
	pushw	wa	; F75F94  push WA
	pushw	hl	; F75F95  push HL
	calr	SmfSize_EncodeDeltaTime	; F75F96  calr 0xf76219
	calr	SmfSize_AgePendingNoteOffs	; F75F99  calr 0xf762df
	popw	hl	; F75F9C  pop HL
	popw	wa	; F75F9D  pop WA
	ld	a, 176:opc	; F75F9E  ld A,0xb0
	ld	w, l	; F75FA0  ld W,L
	and	w, 15	; F75FA2  and W,0x0f
	or	a, w	; F75FA5  or A,W
	ld	w, 101:opc	; F75FA7  ld W,0x65
	ld	l, 0:opc	; F75FA9  ld L,0x00
	pushw	wa	; F75FAB  push WA
	calr	SmfSize_WriteChannelEvent	; F75FAC  calr 0xf7626a
	popw	wa	; F75FAF  pop WA
	ld	w, 100:opc	; F75FB0  ld W,0x64
	ld	l, 2:opc	; F75FB2  ld L,0x02
	ld	(Smf_VlqBytes:16), 0	; F75FB4  ld (0x1193),0x00
	pushw	wa	; F75FB9  push WA
	calr	SmfSize_WriteChannelEvent	; F75FBA  calr 0xf7626a
	popw	wa	; F75FBD  pop WA
	ld	w, 6:opc	; F75FBE  ld W,0x06
	ld	l, (4508:16)	; F75FC0  ld L,(0x119c)
	pushw	wa	; F75FC4  push WA
	calr	SmfSize_WriteChannelEvent	; F75FC5  calr 0xf7626a
	popw	wa	; F75FC8  pop WA
	ld	w, 38:opc	; F75FC9  ld W,0x26
	ld	l, 0:opc	; F75FCB  ld L,0x00
	calr	SmfSize_WriteChannelEvent	; F75FCD  calr 0xf7626a
	jrl	SmfSize_Pass_Loop4	; F75FD0  jrl T,0xf75ad2
SmfSize_Pass_Skip29:
	bit	0, (0x133e:16)	; F75FD3  bit 0,(0x133e)
	jr	z, SmfSize_Pass_Skip30	; F75FD7  jr Z,0xf75fe0
	bit	0, (0x11b1:16)	; F75FD9  bit 0,(0x11b1)
	jrl	z, SmfSize_Pass_Loop4	; F75FDD  jrl Z,0xf75ad2
SmfSize_Pass_Skip30:
	ld	c, (4505:16)	; F75FE0  ld C,(0x1199)
	pushw	wa	; F75FE4  push WA
	pushw	hl	; F75FE5  push HL
	calr	SmfSize_EncodeDeltaTime	; F75FE6  calr 0xf76219
	calr	SmfSize_AgePendingNoteOffs	; F75FE9  calr 0xf762df
	popw	hl	; F75FEC  pop HL
	popw	wa	; F75FED  pop WA
	ld	a, 176:opc	; F75FEE  ld A,0xb0
	ld	w, (4507:16)	; F75FF0  ld W,(0x119b)
	and	w, 15	; F75FF4  and W,0x0f
	or	a, w	; F75FF7  or A,W
	ld	w, 10:opc	; F75FF9  ld W,0x0a
	ld	l, (4508:16)	; F75FFB  ld L,(0x119c)
	calr	SmfSize_WriteChannelEvent	; F75FFF  calr 0xf7626a
	jrl	SmfSize_Pass_Loop4	; F76002  jrl T,0xf75ad2
SmfSize_Pass_Skip31:
	ld	bc, (4508:16)	; F76005  ld BC,(0x119c)
	jrl	SmfSize_Pass_Loop4	; F76009  jrl T,0xf75ad2
SmfSize_Pass_Skip32:
	bit	0, (0x133e:16)	; F7600C  bit 0,(0x133e)
	jr	z, SmfSize_Pass_Skip33	; F76010  jr Z,0xf76019
	bit	0, (0x11b1:16)	; F76012  bit 0,(0x11b1)
	jrl	z, SmfSize_Pass_Loop4	; F76016  jrl Z,0xf75ad2
SmfSize_Pass_Skip33:
	ld	w, 93:opc	; F76019  ld W,0x5d
	ld	l, (4508:16)	; F7601B  ld L,(0x119c)
	jr	SmfSize_Pass_Join8	; F7601F  jr T,0xf76072
SmfSize_Pass_Skip34:
	bit	0, (0x133e:16)	; F76021  bit 0,(0x133e)
	jr	z, SmfSize_Pass_Skip35	; F76025  jr Z,0xf7602e
	bit	0, (0x11b1:16)	; F76027  bit 0,(0x11b1)
	jrl	z, SmfSize_Pass_Loop4	; F7602B  jrl Z,0xf75ad2
SmfSize_Pass_Skip35:
	ld	w, 93:opc	; F7602E  ld W,0x5d
	ld	l, (4508:16)	; F76030  ld L,(0x119c)
	jr	SmfSize_Pass_Join8	; F76034  jr T,0xf76072
	bit	0, (0x133e:16)	; F76036  bit 0,(0x133e)
	jr	z, SmfSize_Pass_Skip36	; F7603A  jr Z,0xf76043
	bit	0, (0x11b1:16)	; F7603C  bit 0,(0x11b1)
	jrl	z, SmfSize_Pass_Loop4	; F76040  jrl Z,0xf75ad2
SmfSize_Pass_Skip36:
	ld	w, 64:opc	; F76043  ld W,0x40
	jr	SmfSize_Pass_Join8	; F76045  jr T,0xf76072
SmfSize_Pass_Skip37:
	ld	w, 91:opc	; F76047  ld W,0x5b
	ld	l, 0:opc	; F76049  ld L,0x00
	bit	0, (0x133e:16)	; F7604B  bit 0,(0x133e)
	jr	z, SmfSize_Pass_Skip38	; F7604F  jr Z,0xf76058
	bit	0, (0x11b1:16)	; F76051  bit 0,(0x11b1)
	jrl	z, SmfSize_Pass_Loop4	; F76055  jrl Z,0xf75ad2
SmfSize_Pass_Skip38:
	ld	l, (4508:16)	; F76058  ld L,(0x119c)
	and	l, 127	; F7605C  and L,0x7f
	jr	SmfSize_Pass_Join8	; F7605F  jr T,0xf76072
SmfSize_Pass_Skip39:
	bit	0, (0x133e:16)	; F76061  bit 0,(0x133e)
	jr	z, SmfSize_Pass_Skip40	; F76065  jr Z,0xf7606e
	bit	0, (0x11b1:16)	; F76067  bit 0,(0x11b1)
	jrl	z, SmfSize_Pass_Loop4	; F7606B  jrl Z,0xf75ad2
SmfSize_Pass_Skip40:
	ld	l, (4508:16)	; F7606E  ld L,(0x119c)
SmfSize_Pass_Join8:
	ld	c, (4505:16)	; F76072  ld C,(0x1199)
	pushw	wa	; F76076  push WA
	pushw	hl	; F76077  push HL
	calr	SmfSize_EncodeDeltaTime	; F76078  calr 0xf76219
	calr	SmfSize_AgePendingNoteOffs	; F7607B  calr 0xf762df
	popw	hl	; F7607E  pop HL
	popw	wa	; F7607F  pop WA
	calr	SmfSize_WriteChannelEvent	; F76080  calr 0xf7626a
	jrl	SmfSize_Pass_Loop4	; F76083  jrl T,0xf75ad2
SmfSize_Pass_Skip41:
	jrl	SmfSize_Pass_Loop4	; F76086  jrl T,0xf75ad2
SmfSize_Pass_Skip42:
	ld	c, 0:opc	; F76089  ld C,0x00
	calr	SmfSize_EncodeDeltaTime	; F7608B  calr 0xf76219
	calr	SmfSize_AgePendingNoteOffs	; F7608E  calr 0xf762df
	ld	a, 255:opc	; F76091  ld A,0xff
	ld	w, 47:opc	; F76093  ld W,0x2f
	ld	l, 0:opc	; F76095  ld L,0x00
	calr	SmfSize_WriteChannelEvent	; F76097  calr 0xf7626a
	calr	SmfSize_StoreTrackLength	; F7609A  calr 0xf76123
SmfSize_Pass_Return:
	ret	; F7609D  ret

; --------------------------------------------------------------------------
; ByteMap_F7609E -- 33 bytes: a BYTE MAP.  0 of them are 0xFF and the other
;                   33 ASCEND STRICTLY, 0x00 to 0x7F, with jumps.  The name
;                   describes the CONTENT; what the two index spaces are is
;                   not established here.
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XIX,0x00f7609e` at
;          0xF75D25 (operand field 1 byte in)
; Entry count: 33 bytes.  The run is trimmed of trailing 0xFF, so it claims
;              no padding it did not earn; the byte before it is 0x0E and
;              the LAST byte of it is 0x7F.
; Evidence: every non-0xFF byte is compared with its predecessor on every
;           emit, WITHIN EACH of the 1 maximal ascending runs the rule
;           returns, and the runs are asserted to tile this segment exactly.
;           The BYTEMAP rule fires ZERO times over the proven prom_b
;           instruction text at (16 bytes, 12 values) and also at (20,14),
;           (24,16) and (16,16) (`python3 notes/prom_b_f6d002_layout.py
;           --null-ptr`).
; Unknown: what the two index spaces ARE, and who reads it.
; --------------------------------------------------------------------------
ByteMap_F7609E:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F7609E  [0..15]
	.byte	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F	; F760AE  [16..31]
	.byte	0x7F	; F760BE  [32..32]
; --------------------------------------------------------------------------
; SmfFileTemplate_F760BF -- the 33-byte STANDARD MIDI FILE header this
;          firmware copies into its output buffer before writing a track.
;          Named 2026-08-31 by notes/prom_b_apply_smf_names.py, on
;          notes/prom_b_smf_reader.py's 40 checks.
;          ⚠ NOT MUSIC: no note, no end-of-track.
; ⚠ CORRECTED 2026-09-02: that pass called the object 99 bytes and 32 of
;                         them the header. It is 33 bytes of header
;                         (14+8+11, the three block moves) and then a
;                         SEPARATE 66-byte word table -- see
;                         SmfPartOffsets_F760E0 below, which retires this
;                         header's standing `Unknown: what the 0x40-strided
;                         bytes after offset 0x21 are`.
; Read by: `ld XIY,0x00F760BF` at 0xF756C6, and the image spells +0x0E and
;          +0x16 as well -- the three copy sources. 14+8+11 = 33 = 0x21,
;          which is where the table starts.
; Length:  the `00 00 00 00` at +0x12 is a PLACEHOLDER; 0xF7789A computes
;          the real value into (0x10C4)-(0x10C7), most significant byte
;          first. ★ Copy 0xF7493F PROVES it: at +0x0E it runs `ldir` with
;          BC=4 -- `MTrk` only -- and then writes (0x10C4) and (0x10C6) into
;          the file in the placeholder's place.
; Evidence: notes/gen_prom_b_smf_writer_module.py --selftest.
; --------------------------------------------------------------------------
SmfFileTemplate_F760BF:
	.ascii	"MThd"	; F760BF  header chunk tag
	.byte	0x00, 0x00, 0x00, 0x06	; F760C3  chunk length 6, most significant byte first
	.byte	0x00, 0x00	; F760C7  format 0 -- one multi-channel track
	.byte	0x00, 0x01	; F760C9  ntrks 1
	.byte	0x00, 0x60	; F760CB  division 0x0060 = 96 ticks per quarter note
	.ascii	"MTrk"	; F760CD  track chunk tag
	.byte	0x00, 0x00, 0x00, 0x00	; F760D1  track length PLACEHOLDER -- backfilled by 0xF7789A
	.byte	0x00	; F760D5  delta time 0
	.byte	0xFF, 0x03	; F760D6  meta event FF 03 -- sequence/track name
	.byte	0x0F	; F760D8  ... declared length 15
	.ascii	"WSA    "	; F760D9  name bytes 1-7; 8-15 come from RAM (0x21C8)

; --------------------------------------------------------------------------
; SmfPartOffsets_F760E0 -- 32 little-endian 16-bit BYTE OFFSETS and a
;          0xFFFF terminator.  NOT MIDI, and not part of the file: it only
;          happens to sit 0x21 bytes after the template.
;          0x0000, 0x0040 ... 0x0800, step 0x40 -- one record per slot in the
;          0x40-strided array at RAM 0x006036A0.
; Read by: five instructions spell 0x00F760E0: 0xF76FB9 is `ld XDE,<base>`
;          followed by `ld HL,(XDE+HL)` with HL = (byte from RAM 0x603422) *
;          2, and the result reaches `lda XIY,XIY+HL` on XIY = 0x006036A0.
; ⚠ Note:  the step is 0x40 everywhere EXCEPT between slots 7 and 8, where
;          it is 0x80: the record at 0x0200 is skipped. That is in the ROM
;          and identical in all four copies. What occupies the skipped slot
;          is NOT established.
; --------------------------------------------------------------------------
SmfPartOffsets_F760E0:
	.short	0x0000, 0x0040, 0x0080, 0x00C0, 0x0100, 0x0140, 0x0180, 0x01C0	; F760E0  slots  0- 7
	.short	0x0240, 0x0280, 0x02C0, 0x0300, 0x0340, 0x0380, 0x03C0, 0x0400	; F760F0  slots  8-15
	.short	0x0440, 0x0480, 0x04C0, 0x0500, 0x0540, 0x0580, 0x05C0, 0x0600	; F76100  slots 16-23
	.short	0x0640, 0x0680, 0x06C0, 0x0700, 0x0740, 0x0780, 0x07C0, 0x0800	; F76110  slots 24-31
	.short	0xFFFF	; F76120  terminator


; --------------------------------------------------------------------------
; sub_F75685_Nop
; Called from: in-module: 0xF75A8C
; Touches: nothing with an absolute address
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF76122 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Purpose: none -- the entry is a lone `ret`.  Named sub_F75685_Nop after what reaches it
;          (was sub_F76122; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
sub_F75685_Nop:
	ret	; F76122  ret

; --------------------------------------------------------------------------
; SmfSize_StoreTrackLength
; Called from: in-module: 0xF7609A
; Touches: (0x1088) (0x10C4) (0x10C5) (0x10C6) (0x10C7) (0x126C)  |
;          0x60A700
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF76123 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSize_StoreTrackLength: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role StoreTrackLength as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_StoreTrackLength:
	xor	wa, wa	; F76123  xor WA,WA
	ld	(SmfOut_TrackLength:16), wa	; F76125  ld (0x10c4),WA
	ld	(SmfOut_TrackLength+2:16), wa	; F76129  ld (0x10c6),WA
	ld	wa, (SmfOut_WindowsFlushed:16)	; F7612D  ld WA,(0x126c)
	mul	wa, 1024	; F76131  mul WA,0x0400
	ld	xhl, (InputStream_Cursor:16)	; F76135  ld XHL,(0x1088)
	sub	xhl, 6334208	; F76139  sub XHL,0x0060a700
	add	xwa, xhl	; F7613F  add XWA,XHL
	sub	xwa, 22	; F76141  sub XWA,0x00000016
	ld	de, qwa	; F76147  ld DE,QWA
	ld	(SmfOut_TrackLength:16), d	; F7614A  ld (0x10c4),D
	ld	(SmfOut_TrackLength+1:16), e	; F7614E  ld (0x10c5),E
	ld	(SmfOut_TrackLength+2:16), w	; F76152  ld (0x10c6),W
	ld	(SmfOut_TrackLength+3:16), a	; F76156  ld (0x10c7),A
	ret	; F7615A  ret

; --------------------------------------------------------------------------
; SmfSize_StageTempo
; Called from: in-module: 0xF75750 0xF75BAA
; Touches: (0x108C) (0x108E)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7615B is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSize_StageTempo: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role StageTempo as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_StageTempo:
	ldw	wa, 60000	; F7615B  ld WA,0xea60
	extz	xwa	; F7615E  extz XWA
	mul	xwa, hl	; F76160  mul XWA,HL
	ld	de, qwa	; F76162  ld DE,QWA
	ld	(SmfOut_Tempo:16), wa	; F76165  ld (0x108c),WA
	ld	(SmfOut_Tempo+2:16), de	; F76169  ld (0x108e),DE
	ldw	wa, 40000	; F7616D  ld WA,0x9c40
	extz	xwa	; F76170  extz XWA
	mul	xwa, hl	; F76172  mul XWA,HL
	ld	de, qwa	; F76174  ld DE,QWA
	add	wa, (SmfOut_Tempo:16)	; F76177  add WA,(0x108c)
	adc	de, (SmfOut_Tempo+2:16)	; F7617B  adc DE,(0x108e)
	ldw	hl, 24000	; F7617F  ld HL,0x5dc0
	ld	qwa, de	; F76182  ld QWA,DE
	div	xwa, hl	; F76185  div XWA,HL
	ld	de, qwa	; F76187  ld DE,QWA
	cp	de, 0:i3	; F7618A  cp DE,0
	jr	z, SmfSize_StageTempo_Skip	; F7618C  jr Z,0xf76190
	inc	1, wa	; F7618E  inc 1,WA
SmfSize_StageTempo_Skip:
	ldw	hl, 1000	; F76190  ld HL,0x03e8
	mul	xwa, hl	; F76193  mul XWA,HL
	ld	de, qwa	; F76195  ld DE,QWA
	ld	(SmfOut_Tempo:16), wa	; F76198  ld (0x108c),WA
	ld	(SmfOut_Tempo+2:16), de	; F7619C  ld (0x108e),DE
	ret	; F761A0  ret

; --------------------------------------------------------------------------
; SmfSize_WriteTempoEvent
; Called from: in-module: 0xF75753 0xF75BAD
; Touches: (0x1088) (0x108C) (0x108D) (0x108E)
; Calls:   SmfSize_CommitOutputByte
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF761A1 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSize_WriteTempoEvent: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role WriteTempoEvent as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_WriteTempoEvent:
	ld	xiy, Smf_VlqBytes	; F761A1  ld XIY,0x00001193
	ld	xix, (InputStream_Cursor:16)	; F761A6  ld XIX,(0x1088)
SmfSize_WriteTempoEvent_Loop:
	ld	a, (xiy+)	; F761AA  ld A,(XIY+)
	ld	(xix+), a	; F761AD  ld (XIX+),A
	calr	SmfSize_CommitOutputByte	; F761B0  calr 0xf762bd
	ld	xix, (InputStream_Cursor:16)	; F761B3  ld XIX,(0x1088)
	bit	7, a	; F761B7  bit 0x07,A
	jr	nz, SmfSize_WriteTempoEvent_Loop	; F761BA  jr NZ,0xf761aa
	ld	a, 255:opc	; F761BC  ld A,0xff
	ld	(xix+), a	; F761BE  ld (XIX+),A
	calr	SmfSize_CommitOutputByte	; F761C1  calr 0xf762bd
	ld	xix, (InputStream_Cursor:16)	; F761C4  ld XIX,(0x1088)
	ld	a, 81:opc	; F761C8  ld A,0x51
	ld	(xix+), a	; F761CA  ld (XIX+),A
	calr	SmfSize_CommitOutputByte	; F761CD  calr 0xf762bd
	ld	xix, (InputStream_Cursor:16)	; F761D0  ld XIX,(0x1088)
	ld	a, 3:opc	; F761D4  ld A,0x03
	ld	(xix+), a	; F761D6  ld (XIX+),A
	calr	SmfSize_CommitOutputByte	; F761D9  calr 0xf762bd
	ld	xix, (InputStream_Cursor:16)	; F761DC  ld XIX,(0x1088)
	ld	a, (SmfOut_Tempo+2:16)	; F761E0  ld A,(0x108e)
	ld	(xix+), a	; F761E4  ld (XIX+),A
	calr	SmfSize_CommitOutputByte	; F761E7  calr 0xf762bd
	ld	xix, (InputStream_Cursor:16)	; F761EA  ld XIX,(0x1088)
	ld	a, (SmfOut_Tempo+1:16)	; F761EE  ld A,(0x108d)
	ld	(xix+), a	; F761F2  ld (XIX+),A
	calr	SmfSize_CommitOutputByte	; F761F5  calr 0xf762bd
	ld	xix, (InputStream_Cursor:16)	; F761F8  ld XIX,(0x1088)
	ld	a, (SmfOut_Tempo:16)	; F761FC  ld A,(0x108c)
	ld	(xix+), a	; F76200  ld (XIX+),A
	calr	SmfSize_CommitOutputByte	; F76203  calr 0xf762bd
	ld	xix, (InputStream_Cursor:16)	; F76206  ld XIX,(0x1088)
	ret	; F7620A  ret

; --------------------------------------------------------------------------
; SmfSize_WriteControlChange
; Called from: in-module: 0xF75D8B 0xF75DA8
; Touches: (0x119A)
; Calls:   SmfSize_WriteChannelEvent
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7620B is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSize_WriteControlChange: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role WriteControlChange as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_WriteControlChange:
	ld	a, (4506:16)	; F7620B  ld A,(0x119a)
	and	a, 15	; F7620F  and A,0x0f
	or	a, 176	; F76212  or A,0xb0
	calr	SmfSize_WriteChannelEvent	; F76215  calr 0xf7626a
	ret	; F76218  ret

; --------------------------------------------------------------------------
; SmfSize_EncodeDeltaTime
; Called from: in-module: 0xF75B80 0xF75BB8 0xF75BDB 0xF75BFE 0xF75C24
;              0xF75C69 0xF75CDA 0xF75E5C +6 more
; Touches: (0x107E) (0x1082) (0x1090) (0x11AA) (0x11AC) (0x1268) (0x133E)
; Calls:   SmfSize_EncodeVlq
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF76219 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSize_EncodeDeltaTime: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role EncodeDeltaTime as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_EncodeDeltaTime:
	pushw	wa	; F76219  push WA
	push	xhl	; F7621A  push XHL
	pushw	de	; F7621B  push DE
	xor	wa, wa	; F7621C  xor WA,WA
	ld	(4522:16), wa	; F7621E  ld (0x11aa),WA
	ld	(4524:16), a	; F76222  ld (0x11ac),A
	ld	wa, (4222:16)	; F76226  ld WA,(0x107e)
	xor	b, b	; F7622A  xor B,B
	add	wa, bc	; F7622C  add WA,BC
	ld	de, (4226:16)	; F7622E  ld DE,(0x1082)
	sub	wa, de	; F76232  sub WA,DE
	ld	(4522:16), wa	; F76234  ld (0x11aa),WA
	bit	0, (0x1268:16)	; F76238  bit 0,(0x1268)
	jr	nz, SmfSize_EncodeDeltaTime_Skip2	; F7623C  jr NZ,0xf7625b
	bit	1, (0x133e:16)	; F7623E  bit 1,(0x133e)
	jr	z, SmfSize_EncodeDeltaTime_Skip2	; F76242  jr Z,0xf7625b
	addw	(0x11aa:16), 0x0180	; F76244  add (0x11aa),0x0180
	bit	0, (0x133e:16)	; F7624A  bit 0,(0x133e)
	jr	z, SmfSize_EncodeDeltaTime_Skip	; F7624E  jr Z,0xf76256
	subw	(0x11aa:16), 0x0122	; F76250  sub (0x11aa),0x0122
SmfSize_EncodeDeltaTime_Skip:
	ld	(4712:16), 1	; F76256  ld (0x1268),0x01
SmfSize_EncodeDeltaTime_Skip2:
	ld	(4226:16), bc	; F7625B  ld (0x1082),BC
	ld	(4240:16), de	; F7625F  ld (0x1090),DE
	popw	de	; F76263  pop DE
	pop	xhl	; F76264  pop XHL
	popw	wa	; F76265  pop WA
	calr	SmfSize_EncodeVlq	; F76266  calr 0xf7647a
	ret	; F76269  ret

; --------------------------------------------------------------------------
; SmfSize_WriteChannelEvent
; Called from: in-module: 0xF75866 0xF75876 0xF7588D 0xF758A8 0xF758C0
;              0xF758D3 0xF758E5 0xF758F2 +42 more
; Touches: (0x1088)
; Calls:   SmfSize_CommitOutputByte
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF7626A is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSize_WriteChannelEvent: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role WriteChannelEvent as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_WriteChannelEvent:
	push	xiy	; F7626A  push XIY
	ld	xix, (InputStream_Cursor:16)	; F7626B  ld XIX,(0x1088)
	ld	xiy, Smf_VlqBytes	; F7626F  ld XIY,0x00001193
	pushw	wa	; F76274  push WA
SmfSize_WriteChannelEvent_Loop:
	ld	a, (xiy+)	; F76275  ld A,(XIY+)
	ld	(xix+), a	; F76278  ld (XIX+),A
	pushw	wa	; F7627B  push WA
	calr	SmfSize_CommitOutputByte	; F7627C  calr 0xf762bd
	popw	wa	; F7627F  pop WA
	ld	xix, (InputStream_Cursor:16)	; F76280  ld XIX,(0x1088)
	bit	7, a	; F76284  bit 0x07,A
	jr	nz, SmfSize_WriteChannelEvent_Loop	; F76287  jr NZ,0xf76275
	popw	wa	; F76289  pop WA
	ld	h, a	; F7628A  ld H,A
	ld	(xix+), a	; F7628C  ld (XIX+),A
	calr	SmfSize_CommitOutputByte	; F7628F  calr 0xf762bd
	ld	xix, (InputStream_Cursor:16)	; F76292  ld XIX,(0x1088)
	ld	a, w	; F76296  ld A,W
	ld	(xix+), a	; F76298  ld (XIX+),A
	calr	SmfSize_CommitOutputByte	; F7629B  calr 0xf762bd
	ld	xix, (InputStream_Cursor:16)	; F7629E  ld XIX,(0x1088)
	and	h, 240	; F762A2  and H,0xf0
	cp	h, 192	; F762A5  cp H,0xc0
	jr	z, SmfSize_WriteChannelEvent_Epilogue	; F762A8  jr Z,0xf762bb
	cp	h, 208	; F762AA  cp H,0xd0
	jr	z, SmfSize_WriteChannelEvent_Epilogue	; F762AD  jr Z,0xf762bb
	ld	a, l	; F762AF  ld A,L
	ld	(xix+), a	; F762B1  ld (XIX+),A
	calr	SmfSize_CommitOutputByte	; F762B4  calr 0xf762bd
	ld	xix, (InputStream_Cursor:16)	; F762B7  ld XIX,(0x1088)
SmfSize_WriteChannelEvent_Epilogue:
	pop	xiy	; F762BB  pop XIY
	ret	; F762BC  ret

; --------------------------------------------------------------------------
; SmfSize_CommitOutputByte
; Called from: in-module: 0xF75794 0xF761B0 0xF761C1 0xF761CD 0xF761D9
;              0xF761E7 0xF761F5 0xF76203 +4 more
; Touches: (0x1088) (0x126C)  |  0x60A700 0x60AAFF
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF762BD is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSize_CommitOutputByte: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role CommitOutputByte as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_CommitOutputByte:
	push	xhl	; F762BD  push XHL
	pushw	bc	; F762BE  push BC
	cp	xix, 6335231	; F762BF  cp XIX,0x0060aaff
	jr	ule, SmfSize_CommitOutputByte_Skip	; F762C5  jr ULE,0xf762d8
	incw	1, (SmfOut_WindowsFlushed:16)	; F762C7  incw 1,(0x126c)
	ld	xwa, 6334208	; F762CB  ld XWA,0x0060a700
	ld	(InputStream_Cursor:16), xwa	; F762D0  ld (0x1088),XWA
	ld	xix, xwa	; F762D4  ld XIX,XWA
	ld	a, c	; F762D6  ld A,C
SmfSize_CommitOutputByte_Skip:
	ld	(InputStream_Cursor:16), xix	; F762D8  ld (0x1088),XIX
	popw	bc	; F762DC  pop BC
	pop	xhl	; F762DD  pop XHL
	ret	; F762DE  ret

; --------------------------------------------------------------------------
; SmfSize_AgePendingNoteOffs
; Called from: in-module: 0xF75B83 0xF75BBB 0xF75BDE 0xF75C01 0xF75C27
;              0xF75C6C 0xF75CDD 0xF75E5F +6 more
; Touches: (0x107E) (0x1080) (0x11AA)
; Calls:   SmfSize_ClearDueList SmfSize_SortDueNoteOffs
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF762DF is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSize_AgePendingNoteOffs: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role AgePendingNoteOffs as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_AgePendingNoteOffs:
	calr	SmfSize_ClearDueList	; F762DF  calr 0xf7652d
	xor	hl, hl	; F762E2  xor HL,HL
	xor	bc, bc	; F762E4  xor BC,BC
	xor	iy, iy	; F762E6  xor IY,IY
SmfSize_AgePendingNoteOffs_Loop:
	push	xde	; F762E8  push XDE
	ld	xde, 12378	; F762E9  ld XDE,0x0000305a
	bit	7, (xde+hl)	; F762EE  bit 7,(XDE+HL)
	pop	xde	; F762F3  pop XDE
	jr	z, SmfSize_AgePendingNoteOffs_Join	; F762F4  jr Z,0xf7634a
	push	xde	; F762F6  push XDE
	ld	xde, 12378	; F762F7  ld XDE,0x0000305a
	lda	xde, (xde+hl)	; F762FC  lda XDE,XDE+HL
	ld	wa, (xde+3)	; F76301  ld WA,(XDE+0x03)
	pop	xde	; F76304  pop XDE
	cp	wa, (0x11aa:16)	; F76305  cp WA,(0x11aa)
	jr	ule, SmfSize_AgePendingNoteOffs_Skip	; F76309  jr ULE,0xf76320
	sub	wa, (0x11aa:16)	; F7630B  sub WA,(0x11aa)
	push	xde	; F7630F  push XDE
	ld	xde, 12378	; F76310  ld XDE,0x0000305a
	lda	xde, (xde+hl)	; F76315  lda XDE,XDE+HL
	ld	(xde+3), wa	; F7631A  ld (XDE+0x03),WA
	pop	xde	; F7631D  pop XDE
	jr	SmfSize_AgePendingNoteOffs_Join	; F7631E  jr T,0xf7634a
SmfSize_AgePendingNoteOffs_Skip:
	push	xde	; F76320  push XDE
	ld	xde, 4307	; F76321  ld XDE,0x000010d3
	ld	(xde+iy), c	; F76326  ld (XDE+IY),C
	ld	xde, 12378	; F7632B  ld XDE,0x0000305a
	lda	xde, (xde+hl)	; F76330  lda XDE,XDE+HL
	ld	wa, (xde+3)	; F76335  ld WA,(XDE+0x03)
	ld	xde, 4307	; F76338  ld XDE,0x000010d3
	lda	xde, (xde+iy)	; F7633D  lda XDE,XDE+IY
	ld	(xde+1), wa	; F76342  ld (XDE+0x01),WA
	pop	xde	; F76345  pop XDE
	add	iy, 3	; F76346  add IY,0x0003
SmfSize_AgePendingNoteOffs_Join:
	add	hl, 5	; F7634A  add HL,0x0005
	inc	1, bc	; F7634E  inc 1,BC
	cp	c, 32	; F76350  cp C,0x20
	jr	ule, SmfSize_AgePendingNoteOffs_Loop	; F76353  jr ULE,0xf762e8
	srl	iy, 1	; F76355  srl 0x01,IY
	cp	iy, 0:i3	; F76358  cp IY,0
	jr	z, SmfSize_AgePendingNoteOffs_Skip2	; F7635A  jr Z,0xf7635f
	calr	SmfSize_SortDueNoteOffs	; F7635C  calr 0xf7636c
SmfSize_AgePendingNoteOffs_Skip2:
	ldw	(4222:16), 0	; F7635F  ld (0x107e),0x0000
	ldw	(4224:16), 0	; F76365  ld (0x1080),0x0000
	ret	; F7636B  ret

; --------------------------------------------------------------------------
; SmfSize_SortDueNoteOffs
; Called from: in-module: 0xF7635C
; Touches: (0x10D3)
; Calls:   SmfSize_WriteDueNoteOffs
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7636C is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSize_SortDueNoteOffs: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role SortDueNoteOffs as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_SortDueNoteOffs:
	cp	iy, 0:i3	; F7636C  cp IY,0
	jr	z, SmfSize_SortDueNoteOffs_Return	; F7636E  jr Z,0xf763d6
	xor	de, de	; F76370  xor DE,DE
	cp	(0x10d3:16), 0xff	; F76372  cp (0x10d3),0xff
	jr	z, SmfSize_SortDueNoteOffs_Return	; F76377  jr Z,0xf763d6
SmfSize_SortDueNoteOffs_Loop:
	ld	xiy, 4307	; F76379  ld XIY,0x000010d3
	ld	xix, 4310	; F7637E  ld XIX,0x000010d6
	lda	xiy, (xiy+de)	; F76383  lda XIY,XIY+DE
	lda	xix, (xix+de)	; F76388  lda XIX,XIX+DE
	cp	(xiy), 0xff	; F7638D  cp (XIY),0xff
	jr	z, SmfSize_SortDueNoteOffs_Skip3	; F76390  jr Z,0xf763d3
	ld	wa, (xiy+1)	; F76392  ld WA,(XIY+0x01)
SmfSize_SortDueNoteOffs_Join:
	ld	l, (xix)	; F76395  ld L,(XIX)
	cp	l, 255	; F76397  cp L,0xff
	jr	z, SmfSize_SortDueNoteOffs_Skip2	; F7639A  jr Z,0xf763c9
	cp	wa, (xix+1)	; F7639C  cp WA,(XIX+0x01)
	jr	ugt, SmfSize_SortDueNoteOffs_Skip	; F7639F  jr UGT,0xf763b1
	add	xix, 3	; F763A1  add XIX,0x00000003
	cp	xix, 4400	; F763A7  cp XIX,0x00001130
	jr	ugt, SmfSize_SortDueNoteOffs_Skip2	; F763AD  jr UGT,0xf763c9
	jr	SmfSize_SortDueNoteOffs_Join	; F763AF  jr T,0xf76395
SmfSize_SortDueNoteOffs_Skip:
	ld	a, (xiy)	; F763B1  ld A,(XIY)
	ld	l, (xix)	; F763B3  ld L,(XIX)
	ld	(xiy), l	; F763B5  ld (XIY),L
	ld	(xix), a	; F763B7  ld (XIX),A
	ld	wa, (xiy+1)	; F763B9  ld WA,(XIY+0x01)
	ld	hl, (xix+1)	; F763BC  ld HL,(XIX+0x01)
	ld	(xiy+1), hl	; F763BF  ld (XIY+0x01),HL
	ld	(xix+1), wa	; F763C2  ld (XIX+0x01),WA
	xor	de, de	; F763C5  xor DE,DE
	jr	SmfSize_SortDueNoteOffs_Loop	; F763C7  jr T,0xf76379
SmfSize_SortDueNoteOffs_Skip2:
	add	de, 3	; F763C9  add DE,0x0003
	cp	de, 96	; F763CD  cp DE,0x0060
	jr	ule, SmfSize_SortDueNoteOffs_Loop	; F763D1  jr ULE,0xf76379
SmfSize_SortDueNoteOffs_Skip3:
	calr	SmfSize_WriteDueNoteOffs	; F763D3  calr 0xf763d7
SmfSize_SortDueNoteOffs_Return:
	ret	; F763D6  ret

; --------------------------------------------------------------------------
; SmfSize_WriteDueNoteOffs
; Called from: in-module: 0xF763D3
; Touches: (0x107E) (0x1080) (0x1082) (0x1090) (0x11AA)
; Calls:   SmfSize_EncodeVlq SmfSize_WriteChannelEvent
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF763D7 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSize_WriteDueNoteOffs: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role WriteDueNoteOffs as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_WriteDueNoteOffs:
	ld	bc, (4226:16)	; F763D7  ld BC,(0x1082)
	ld	xiy, 4307	; F763DB  ld XIY,0x000010d3
	xor	hl, hl	; F763E0  xor HL,HL
SmfSize_WriteDueNoteOffs_Join:
	ld	a, (xiy+hl)	; F763E2  ld A,(XIY+HL)
	cp	a, 255	; F763E7  cp A,0xff
	jr	z, SmfSize_WriteDueNoteOffs_Skip2	; F763EA  jr Z,0xf76454
	xor	w, w	; F763EC  xor W,W
	ld	ix, wa	; F763EE  ld IX,WA
	sla	ix, 2	; F763F0  sla 0x02,IX
	add	ix, wa	; F763F3  add IX,WA
	extz	xix	; F763F5  extz XIX
	push	xde	; F763F7  push XDE
	ld	xde, 12378	; F763F8  ld XDE,0x0000305a
	add	xde, xix	; F763FD  add XDE,XIX
	ld	wa, (xde+3)	; F763FF  ld WA,(XDE+0x03)
	pop	xde	; F76402  pop XDE
	cp	l, 0:i3	; F76403  cp L,0
	jr	nz, SmfSize_WriteDueNoteOffs_Skip	; F76405  jr NZ,0xf7640d
	ld	(4522:16), wa	; F76407  ld (0x11aa),WA
	jr	SmfSize_WriteDueNoteOffs_Join2	; F7640B  jr T,0xf76417
SmfSize_WriteDueNoteOffs_Skip:
	ld	de, wa	; F7640D  ld DE,WA
	sub	de, (0x1082:16)	; F7640F  sub DE,(0x1082)
	ld	(4522:16), de	; F76413  ld (0x11aa),DE
SmfSize_WriteDueNoteOffs_Join2:
	pushw	wa	; F76417  push WA
	push	xhl	; F76418  push XHL
	pushw	bc	; F76419  push BC
	push	xix	; F7641A  push XIX
	calr	SmfSize_EncodeVlq	; F7641B  calr 0xf7647a
	pop	xix	; F7641E  pop XIX
	popw	bc	; F7641F  pop BC
	pop	xhl	; F76420  pop XHL
	popw	wa	; F76421  pop WA
	ld	(4226:16), wa	; F76422  ld (0x1082),WA
	push	xde	; F76426  push XDE
	ld	xde, 12378	; F76427  ld XDE,0x0000305a
	add	xde, xix	; F7642C  add XDE,XIX
	ld	wa, (xde+1)	; F7642E  ld WA,(XDE+0x01)
	push	xhl	; F76431  push XHL
	ld	l, 0:opc	; F76432  ld L,0x00
	pushw	bc	; F76434  push BC
	push	xix	; F76435  push XIX
	calr	SmfSize_WriteChannelEvent	; F76436  calr 0xf7626a
	pop	xix	; F76439  pop XIX
	popw	bc	; F7643A  pop BC
	pop	xhl	; F7643B  pop XHL
	ld	xde, 12378	; F7643C  ld XDE,0x0000305a
	and	(xde+ix), 0x3f	; F76441  and (XDE+IX),0x3f
	pop	xde	; F76447  pop XDE
	add	hl, 3	; F76448  add HL,0x0003
	cp	hl, 96	; F7644C  cp HL,0x0060
	jr	nc, SmfSize_WriteDueNoteOffs_Skip2	; F76450  jr NC,0xf76454
	jr	SmfSize_WriteDueNoteOffs_Join	; F76452  jr T,0xf763e2
SmfSize_WriteDueNoteOffs_Skip2:
	ld	wa, (4226:16)	; F76454  ld WA,(0x1082)
	add	wa, (0x1090:16)	; F76458  add WA,(0x1090)
	ld	(4226:16), bc	; F7645C  ld (0x1082),BC
	add	bc, (0x107e:16)	; F76460  add BC,(0x107e)
	sub	bc, wa	; F76464  sub BC,WA
	ld	(4522:16), bc	; F76466  ld (0x11aa),BC
	calr	SmfSize_EncodeVlq	; F7646A  calr 0xf7647a
	ldw	(4222:16), 0	; F7646D  ld (0x107e),0x0000
	ldw	(4224:16), 0	; F76473  ld (0x1080),0x0000
	ret	; F76479  ret

; --------------------------------------------------------------------------
; SmfSize_EncodeVlq
; Called from: in-module: 0xF76266 0xF7641B 0xF7646A
; Touches: (0x1193) (0x1194) (0x1195) (0x11AA) (0x11AB) (0x11AC)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7647A is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSize_EncodeVlq: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role EncodeVlq as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_EncodeVlq:
	ldw	(Smf_VlqBytes:16), 0	; F7647A  ld (0x1193),0x0000
	ldw	(4501:16), 0	; F76480  ld (0x1195),0x0000
	cp	(0x11ac:16), 0x00	; F76486  cp (0x11ac),0x00
	jr	nz, SmfSize_EncodeVlq_Skip	; F7648B  jr NZ,0xf7649e
	cpw	(0x11aa:16), 0x007f	; F7648D  cp (0x11aa),0x007f
	jrl	ule, SmfSize_EncodeVlq_Skip4	; F76493  jrl ULE,0xf7651d
	cpw	(0x11aa:16), 0x3fff	; F76496  cp (0x11aa),0x3fff
	jr	ule, SmfSize_EncodeVlq_Skip3	; F7649C  jr ULE,0xf764f4
SmfSize_EncodeVlq_Skip:
	cp	(0x11ac:16), 0x1f	; F7649E  cp (0x11ac),0x1f
	jr	ule, SmfSize_EncodeVlq_Skip2	; F764A3  jr ULE,0xf764b4
	ld	(4524:16), 31	; F764A5  ld (0x11ac),0x1f
	ld	(4523:16), 255	; F764AA  ld (0x11ab),0xff
	ld	(4522:16), 255	; F764AF  ld (0x11aa),0xff
SmfSize_EncodeVlq_Skip2:
	ld	a, (4522:16)	; F764B4  ld A,(0x11aa)
	ld	w, a	; F764B8  ld W,A
	and	w, 128	; F764BA  and W,0x80
	and	a, 127	; F764BD  and A,0x7f
	rlc	w	; F764C0  rlc 0x01,W
	ld	l, (4523:16)	; F764C3  ld L,(0x11ab)
	ld	h, l	; F764C7  ld H,L
	and	h, 192	; F764C9  and H,0xc0
	.byte 0xCE, 0xE8, 0x02	; F764CC  rlc 0x02,H   [llvm-mc cannot encode this]
	sla	l, 1	; F764CF  sla 0x01,L
	and	l, 1	; F764D2  and L,0x01
	or	l, w	; F764D5  or L,W
	or	l, 128	; F764D7  or L,0x80
	ld	c, (4524:16)	; F764DA  ld C,(0x11ac)
	sla	c, 2	; F764DE  sla 0x02,C
	or	c, h	; F764E1  or C,H
	or	c, 128	; F764E3  or C,0x80
	ld	(Smf_VlqBytes:16), c	; F764E6  ld (0x1193),C
	ld	(4500:16), l	; F764EA  ld (0x1194),L
	ld	(4501:16), a	; F764EE  ld (0x1195),A
	jr	SmfSize_EncodeVlq_Return	; F764F2  jr T,0xf7652c
SmfSize_EncodeVlq_Skip3:
	ld	a, (4522:16)	; F764F4  ld A,(0x11aa)
	ld	w, a	; F764F8  ld W,A
	and	a, 127	; F764FA  and A,0x7f
	and	w, 128	; F764FD  and W,0x80
	rlc	w	; F76500  rlc 0x01,W
	ld	l, (4523:16)	; F76503  ld L,(0x11ab)
	ld	h, l	; F76507  ld H,L
	sla	l, 1	; F76509  sla 0x01,L
	or	l, w	; F7650C  or L,W
	or	l, 128	; F7650E  or L,0x80
	xor	c, c	; F76511  xor C,C
	ld	(Smf_VlqBytes:16), l	; F76513  ld (0x1193),L
	ld	(4500:16), a	; F76517  ld (0x1194),A
	jr	SmfSize_EncodeVlq_Return	; F7651B  jr T,0xf7652c
SmfSize_EncodeVlq_Skip4:
	ld	a, (4522:16)	; F7651D  ld A,(0x11aa)
	and	a, 127	; F76521  and A,0x7f
	xor	l, l	; F76524  xor L,L
	xor	c, c	; F76526  xor C,C
	ld	(Smf_VlqBytes:16), a	; F76528  ld (0x1193),A
SmfSize_EncodeVlq_Return:
	ret	; F7652C  ret

; --------------------------------------------------------------------------
; SmfSize_ClearDueList
; Called from: in-module: 0xF762DF
; Touches: nothing with an absolute address
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7652D is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSize_ClearDueList: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role ClearDueList as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_ClearDueList:
	push	xix	; F7652D  push XIX
	ld	xix, 4307	; F7652E  ld XIX,0x000010d3
	ldw	bc, 96	; F76533  ld BC,0x0060
	ldw	wa, 255	; F76536  ld WA,0x00ff
	ld	(xix+), a	; F76539  ld (XIX+),A
	djnz16	bc, -6	; F7653C  djnz BC,0xf76539
	pop	xix	; F7653F  pop XIX
	ret	; F76540  ret

; --------------------------------------------------------------------------
; SmfSize_ClearEventFields
; Called from: in-module: 0xF75AD5
; Touches: nothing with an absolute address
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF76541 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSize_ClearEventFields: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role ClearEventFields as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_ClearEventFields:
	ld	xix, Smf_VlqValue	; F76541  ld XIX,0x00001198
	xor	wa, wa	; F76546  xor WA,WA
	ldw	bc, 4	; F76548  ld BC,0x0004
	ld	(xix+), wa	; F7654B  ld (XIX+),WA
	djnz16	bc, -6	; F7654E  djnz BC,0xf7654b
	ret	; F76551  ret

; --------------------------------------------------------------------------
; SmfSize_ReadSongByte
; Called from: in-module: 0xF75A99 0xF75AB1 0xF75AD8 0xF75AF2 0xF75B43
; Touches: (0x126E) (0x345C) (0x345E)
; Calls:   SongStore_SeekBlock_Copy
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF76552 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSize_ReadSongByte: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role ReadSongByte as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_ReadSongByte:
	ld	hl, (BStore_CursorBlock:16)	; F76552  ld HL,(0x345c)
	calr	SongStore_SeekBlock_Copy	; F76556  calr 0xf72f0a
	ld	iy, (BStore_CursorOffset:16)	; F76559  ld IY,(0x345e)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F7655D  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F76561  ld A,(XHL+IY)
	ret	; F76566  ret

; --------------------------------------------------------------------------
; SmfSize_AdvanceSongCursor
; Called from: in-module: 0xF75AAE 0xF75AEF 0xF75B4F
; Touches: (0x126E) (0x345C) (0x345E)
; Calls:   SongStore_SeekBlock_Copy InputStream_OpenAndReadFirstBlock InputStream_Refill InputStream_RefillDone
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF76567 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSize_AdvanceSongCursor: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role AdvanceSongCursor as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_AdvanceSongCursor:
	ld	wa, (BStore_CursorOffset:16)	; F76567  ld WA,(0x345e)
	cp	wa, 255	; F7656B  cp WA,0x00ff
	jr	nz, SmfSize_AdvanceSongCursor_Skip	; F7656F  jr NZ,0xf76588
	ld	hl, (BStore_CursorBlock:16)	; F76571  ld HL,(0x345c)
	calr	SongStore_SeekBlock_Copy	; F76575  calr 0xf72f0a
	ld	xhl, (BStore_CursorBlockAddr:16)	; F76578  ld XHL,(0x126e)
	ld	wa, (xhl+3)	; F7657C  ld WA,(XHL+0x03)
	ld	(BStore_CursorBlock:16), wa	; F7657F  ld (0x345c),WA
	ldw	wa, 5	; F76583  ld WA,0x0005
	jr	SmfSize_AdvanceSongCursor_Join	; F76586  jr T,0xf7658a
SmfSize_AdvanceSongCursor_Skip:
	inc	1, wa	; F76588  inc 1,WA
SmfSize_AdvanceSongCursor_Join:
	ld	(BStore_CursorOffset:16), wa	; F7658A  ld (0x345e),WA
	ret	; F7658E  ret
	calr	InputStream_OpenAndReadFirstBlock	; F7658F  calr 0xf7659b
	ret	; F76592  ret
	calr	InputStream_Refill	; F76593  calr 0xf765d4
	ret	; F76596  ret
	calr	InputStream_RefillDone	; F76597  calr 0xf765de
	ret	; F7659A  ret

; --------------------------------------------------------------------------
; InputStream_OpenAndReadFirstBlock
; Called from: in-module: 0xF6F55F 0xF7658F
; Touches: (0x21D0) (0x21D1) (0x21D2) (0x21D3) (0x21D7) (0x21E7)  |
;          0x60A700 0x60AB00
; Calls:   T_DiskApi_ReadFileToWindow_Entry
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7659B is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; InputStream_OpenAndReadFirstBlock: Disk_Flags |= 0x80; unless L = 1 the file extension := 'MID'; window :=
;   0x60A700-0x60AB00 (the input-stream window) and DiskApi_ReadFileToWindow with Disk_Flags bit 5 (one block) set
;   around it; A = its status. Smf_ReadFile's first read (L = 0), whose status it then tests. Basis: caller + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave3_g.json)
InputStream_OpenAndReadFirstBlock:
	or	(Disk_Flags:16), 0x80	; F7659B  or (0x21e7),0x80
	cp	l, 1:i3	; F765A0  cp L,1
	jr	z, InputStream_OpenAndReadFirstBlock_Skip	; F765A2  jr Z,0xf765b3
	ld	(Disk_FileName+8:16), 77	; F765A4  ld (0x21d0),0x4d
	ld	(Disk_FileName+9:16), 73	; F765A9  ld (0x21d1),0x49
	ld	(Disk_FileName+10:16), 68	; F765AE  ld (0x21d2),0x44
InputStream_OpenAndReadFirstBlock_Skip:
	ld	xwa, 6334208	; F765B3  ld XWA,0x0060a700
	ld	(Disk_WindowStart:16), xwa	; F765B8  ld (0x21d3),XWA
	ld	xwa, 6335232	; F765BC  ld XWA,0x0060ab00
	ld	(Disk_WindowEnd:16), xwa	; F765C1  ld (0x21d7),XWA
	or	(Disk_Flags:16), 0x20	; F765C5  or (0x21e7),0x20
	call	T_DiskApi_ReadFileToWindow_Entry	; F765CA  call 0xf425a8
	and	(Disk_Flags:16), 0xdf	; F765CE  and (0x21e7),0xdf
	ret	; F765D3  ret

; --------------------------------------------------------------------------
; InputStream_Refill -- 0xF765D4
; Called from: in-module: 0xF6FDA7 0xF713A7 0xF76593
; Touches: (0x21E7)
; Calls:   T_DiskApi_ReadFileToWindow_Entry
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF765D4 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Name:    InputStream_Refill -- named 2026-08-31.
; Evidence (INTERNAL): the whole routine is `or (0x21E7),0x02` then
;          `call 0xf425a8` then `ret`.  It is what InputStream_GetByte calls at
;          0xF713A7 when its cursor passes the top of the 0x60A700-0x60AAFF
;          window, and InputStream_RefillDone (0xF765DE) is its exact inverse on
;          the same bit.  The name claims the bit and the hand-off and nothing
;          about where the bytes come from.
; ⚠ CORRECTED 2026-08-31: this header used to end `Unknown: what the routine is
;          FOR.  Left as sub_XXXXXX with the gap stated`.
; Unknown: what prom_a 0xFE1C3A, behind slot T_DiskApi_ReadFileToWindow_Entry, reads from.
; --------------------------------------------------------------------------
InputStream_Refill:
	or	(Disk_Flags:16), 0x02	; F765D4  or (0x21e7),0x02
	call	T_DiskApi_ReadFileToWindow_Entry	; F765D9  call 0xf425a8
	ret	; F765DD  ret

; --------------------------------------------------------------------------
; InputStream_RefillDone -- 0xF765DE
; Called from: in-module: 0xF6F723 0xF6F780 0xF6F7AD 0xF6F7DD 0xF71BBF
;              0xF71BD5 0xF76597
; Touches: (0x21E7)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF765DE is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Name:    InputStream_RefillDone -- named 2026-08-31.
; Evidence (INTERNAL): `and (0x21E7),0xFD / ld W,0x01 / ret` -- it clears exactly
;          the bit InputStream_Refill (0xF765D4) sets, and returns 1, which is
;          the value InputStream_GetByte stores in its status byte (0x124A) for
;          a good fetch.  ⚠ Bit 1 of (0x21E7) is NOT unique to this pair: prom_b
;          sets or clears it at ten addresses, in five set/clear pairs of the
;          same shape (0xF765D4/DE, 0xF76661, 0xF76677/80, 0xF77D39/43,
;          0xF77DC6/0xF77DE5, 0xF77F20/2A, 0xF77FAD/0xF77FCC).  The name claims
;          this pair, not ownership of the bit.
; ⚠ CORRECTED 2026-08-31: this header used to end `Unknown: what the routine is
;          FOR.  Left as sub_XXXXXX with the gap stated`.
; Unknown: nothing about the bit; who calls it, and when, is listed above.
; --------------------------------------------------------------------------
InputStream_RefillDone:
	and	(Disk_Flags:16), 0xfd	; F765DE  and (0x21e7),0xfd
	ld	w, 1:opc	; F765E3  ld W,0x01
	ret	; F765E5  ret

; --------------------------------------------------------------------------
; SmfWrite_CreateFileWithFirstWindow
; Called from: in-module: 0xF74763 0xF74B5A
; Touches: (0x10C5) (0x10C6) (0x10C7)
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF765E6 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_CreateFileWithFirstWindow: Checks free space for the file (SmfOut_TrackLength + 22, >> 4) through T_DiskSave_CheckFreeSpace
;   / DiskApi_CheckFreeSpace; if OK sets extension 'MID', deletes any old file of that name, sets Disk_Flags bit 7,
;   points the window at 0x60A700-0x60AB00 and writes it (Disk_Flags bit 5). Returns the disk result in A. Called for
;   the first 1,024-byte window only (SmfOut_WindowsFlushed == 0). Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_h.json)
SmfWrite_CreateFileWithFirstWindow:
	xor	de, de	; F765E6  xor DE,DE
	ld	d, (SmfOut_TrackLength+1:16)	; F765E8  ld D,(0x10c5)
	ld	w, (SmfOut_TrackLength+2:16)	; F765EC  ld W,(0x10c6)
	ld	a, (SmfOut_TrackLength+3:16)	; F765F0  ld A,(0x10c7)
	add	wa, 22	; F765F4  add WA,0x0016
	jr	nov, SmfWrite_CreateFileWithFirstWindow_Skip	; F765F8  jr PO/NOV,0xf765fc

; --------------------------------------------------------------------------
; REACHED CODE, not data (was `Data_F765FA`), part of SmfWrite_CreateFileWithFirstWindow:
;   the overflow arm of `jr nov` at 0xF765F8.
; --------------------------------------------------------------------------
	inc	1, d	; F765FA  inc 1,D

SmfWrite_CreateFileWithFirstWindow_Skip:
	srl	wa, 4	; F765FC  srl 0x04,WA
	sla	de, 4	; F765FF  sla 0x04,DE
	and	de, 61440	; F76602  and DE,0xf000
	and	wa, 4095	; F76606  and WA,0x0fff
	or	wa, de	; F7660A  or WA,DE
	ld	bc, wa	; F7660C  ld BC,WA
	ld	(8773:16), bc	; F7660E  ld (0x2245),BC
	call	T_DiskSave_CheckFreeSpace	; F76612  call 0xf425e8
	ld	w, (Disk_LastError:16)	; F76616  ld W,(0x2243)
	cp	w, 0:i3	; F7661A  cp W,0
	jr	nz, SmfWrite_CreateFileWithFirstWindow_Return	; F7661C  jr NZ,0xf7664d
	ld	(Disk_FileName+8:16), 77	; F7661E  ld (0x21d0),0x4d
	ld	(Disk_FileName+9:16), 73	; F76623  ld (0x21d1),0x49
	ld	(Disk_FileName+10:16), 68	; F76628  ld (0x21d2),0x44
	call	T_DiskApi_DeleteFile_Call	; F7662D  call 0xf425b0
	or	(Disk_Flags:16), 0x80	; F76631  or (0x21e7),0x80
	ld	(Disk_FileName+8:16), 77	; F76636  ld (0x21d0),0x4d
	ld	(Disk_FileName+9:16), 73	; F7663B  ld (0x21d1),0x49
	ld	(Disk_FileName+10:16), 68	; F76640  ld (0x21d2),0x44
	call	SmfWrite_SetOutputWindow	; F76645  call 0xf7668a
	call	SmfWrite_WriteFirstWindow	; F76649  call 0xf7664e
SmfWrite_CreateFileWithFirstWindow_Return:
	ret	; F7664D  ret

; --------------------------------------------------------------------------
; SmfWrite_WriteFirstWindow
; Called from: in-module: 0xF76649
; Touches: (0x21E7) (0x2243)
; Calls:   T_DiskApi_WriteFileFromWindow_Entry
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF7664E is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_WriteFirstWindow: Disk_Flags |= 0x20, T_DiskApi_WriteFileFromWindow_Entry, A := Disk_LastError, the flag
;   cleared again -- the first 1,024-byte window of the .MID file. SmfWrite_CreateFileWithFirstWindow runs it last,
;   after the free-space check, the delete and SmfWrite_SetOutputWindow; its copies are SmfWriteCopy_WriteFirstWindow (copy D) and SmfWrite_WriteFirstWindow_Copy2 (copy E). Basis:
;   caller + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
SmfWrite_WriteFirstWindow:
	or	(Disk_Flags:16), 0x20	; F7664E  or (0x21e7),0x20
	call	T_DiskApi_WriteFileFromWindow_Entry	; F76653  call 0xf425ac
	ld	a, (Disk_LastError:16)	; F76657  ld A,(0x2243)
	and	(Disk_Flags:16), 0xdf	; F7665B  and (0x21e7),0xdf
	ret	; F76660  ret

; --------------------------------------------------------------------------
; SmfWrite_WriteNextWindow
; Called from: in-module: 0xF74B95
; Touches: (0x21E7) (0x2243)
; Calls:   T_DiskApi_WriteFileFromWindow_Entry
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF76661 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_WriteNextWindow: Disk_Flags |= 0x02, T_DiskApi_WriteFileFromWindow_Entry, A := Disk_LastError -- writes a
;   further 1,024-byte window of the .MID file (bit 1 left set). SmfWrite_CommitOutputByte calls it when the cursor
;   passes 0x60AAFF and a window was already written, then counts the window and rewinds the cursor to 0x60A700.
;   Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
SmfWrite_WriteNextWindow:
	or	(Disk_Flags:16), 0x02	; F76661  or (0x21e7),0x02
	call	T_DiskApi_WriteFileFromWindow_Entry	; F76666  call 0xf425ac
	ld	a, (Disk_LastError:16)	; F7666A  ld A,(0x2243)
	ret	; F7666E  ret

; --------------------------------------------------------------------------
; SmfWrite_WriteLastWindowAndClose
; Called from: in-module: 0xF74772
; Touches: (0x126C) (0x21E7)
; Calls:   T_DiskApi_WriteFileFromWindow_Entry T_DiskApi_CloseFile_Call
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF7666F is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_WriteLastWindowAndClose: When SmfOut_WindowsFlushed is non-zero writes the partly filled window (Disk_Flags
;   bit 1, T_DiskApi_WriteFileFromWindow_Entry); then clears bit 1 and closes the file (T_DiskApi_CloseFile_Call).
;   Smf_WriteFile's success path after the end-of-track event; copy A of SmfOut_WriteLastWindowAndClose. Basis: caller
;   + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
SmfWrite_WriteLastWindowAndClose:
	cpw	(SmfOut_WindowsFlushed:16), 0x0000	; F7666F  cp (0x126c),0x0000
	jr	z, SmfWrite_WriteLastWindowAndClose_Skip	; F76675  jr Z,0xf76680
	or	(Disk_Flags:16), 0x02	; F76677  or (0x21e7),0x02
	call	T_DiskApi_WriteFileFromWindow_Entry	; F7667C  call 0xf425ac
SmfWrite_WriteLastWindowAndClose_Skip:
	and	(Disk_Flags:16), 0xfd	; F76680  and (0x21e7),0xfd
	call	T_DiskApi_CloseFile_Call	; F76685  call 0xf425e4
	ret	; F76689  ret

; --------------------------------------------------------------------------
; SmfWrite_SetOutputWindow
; Called from: in-module: 0xF76645
; Touches: (0x21D3) (0x21D7)  |  0x60A700 0x60AB00
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF7668A is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWrite_SetOutputWindow: Disk_WindowStart := 0x60A700, Disk_WindowEnd := 0x60AB00 -- the 1,024-byte output window
;   the SMF writer fills. SmfWrite_CreateFileWithFirstWindow sets it just before SmfWrite_WriteFirstWindow. Basis:
;   caller + body. (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
SmfWrite_SetOutputWindow:
	ld	xwa, 6334208	; F7668A  ld XWA,0x0060a700
	ld	(Disk_WindowStart:16), xwa	; F7668F  ld (0x21d3),XWA
	ld	xwa, 6335232	; F76693  ld XWA,0x0060ab00
	ld	(Disk_WindowEnd:16), xwa	; F76698  ld (0x21d7),XWA
	ret	; F7669C  ret
; --------------------------------------------------------------------------
; sub_F7669D
; Called from: no call site is known.  The label marks where a
;              converted run STARTS, so that a tool walking this file
;              by label does not attribute the run to its neighbour.
; Evidence: 0xF7669D is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
sub_F7669D:
	bit	0, (0x133e:16)	; F7669D  bit 0,(0x133e)
	jr	z, sub_F7669D_Code_Skip	; F766A1  jr Z,0xf766aa
	bit	0, (0x11b1:16)	; F766A3  bit 0,(0x11b1)
	jrl	z, -1665	; F766A7  jrl Z,0xf76029
sub_F7669D_Code_Skip:
	ld	l, (4508:16)	; F766AA  ld L,(0x119c)
	and	l, 127	; F766AE  and L,0x7f
	jr	sub_F7669D_Code_Join	; F766B1  jr T,0xf766c4
	bit	0, (0x133e:16)	; F766B3  bit 0,(0x133e)
	jr	z, sub_F7669D_Code_Skip2	; F766B7  jr Z,0xf766c0
	bit	0, (0x11b1:16)	; F766B9  bit 0,(0x11b1)
	jrl	z, -1687	; F766BD  jrl Z,0xf76029
sub_F7669D_Code_Skip2:
	ld	l, (4508:16)	; F766C0  ld L,(0x119c)
sub_F7669D_Code_Join:
	ld	c, (4505:16)	; F766C4  ld C,(0x1199)
	pushw	wa	; F766C8  push WA
	pushw	hl	; F766C9  push HL
	calr	SmfWriteCopy_EncodeDeltaTime	; F766CA  calr 0xf76a25
	calr	SmfWriteCopy_AgePendingNoteOffs	; F766CD  calr 0xf76b9b
	popw	hl	; F766D0  pop HL
	popw	wa	; F766D1  pop WA
	cp	(0x1238:16), 3	; F766D2  cp (0x1238),0x03
	jrl	nz, sub_F7669D_Code_Entry	; F766D7  jrl NZ,0xf7678d
	calr	SmfWriteCopy_WriteChannelEvent	; F766DA  calr 0xf76a6a
	cp	(0x1238:16), 3	; F766DD  cp (0x1238),0x03
	jrl	nz, sub_F7669D_Code_Entry	; F766E2  jrl NZ,0xf7678d
	jrl	-1727	; F766E5  jrl T,0xf76029
	jrl	-1730	; F766E8  jrl T,0xf76029
	ld	c, 0:opc	; F766EB  ld C,0x00
	calr	SmfWriteCopy_EncodeDeltaTime	; F766ED  calr 0xf76a25
	calr	SmfWriteCopy_AgePendingNoteOffs	; F766F0  calr 0xf76b9b
	cp	(0x1238:16), 3	; F766F3  cp (0x1238),0x03
	jrl	nz, sub_F7669D_Code_Entry	; F766F8  jrl NZ,0xf7678d
	ld	a, 255:opc	; F766FB  ld A,0xff
	ld	w, 47:opc	; F766FD  ld W,0x2f
	ld	l, 0:opc	; F766FF  ld L,0x00
	calr	SmfWriteCopy_WriteChannelEvent	; F76701  calr 0xf76a6a
	cp	(0x1238:16), 3	; F76704  cp (0x1238),0x03
	jrl	nz, sub_F7669D_Code_Entry	; F76709  jrl NZ,0xf7678d
	cpw	(SmfOut_WindowsFlushed:16), 0	; F7670C  cp (0x126c),0x0000
	jr	nz, sub_F7669D_Code_Skip3	; F76712  jr NZ,0xf76723
	call	SmfOut_CreateFileWithFirstWindow	; F76714  call 0xf77d4b
	ld	w, a	; F76718  ld W,A
	ld	(4664:16), w	; F7671A  ld (0x1238),W
	cp	w, 3:i3	; F7671E  cp W,3
	jrl	nz, sub_F7669D_Code_Entry	; F76720  jrl NZ,0xf7678d
sub_F7669D_Code_Skip3:
	calr	SmfOut_WriteLastWindowAndClose	; F76723  calr 0xf77dd4
	calr	SmfSize_RestoreSongFromTempFile	; F76726  calr 0xf768a1
	ld	(UI_StatusCode:16), 35	; F76729  ld (0x2880),0x23
	call	T_MessageScreen_Paint	; F7672E  call 0xf41600
	calr	SmfExport_ParamSysExTemplates + 0xDC	; F76732  calr 0xf750ab  (lands inside record 11 at +11; see SmfExport_ParamSysExTemplates)
	ld	(UI_ScreenPage:16), 0	; F76735  ld (0x2229),0x00
	or	(0x34d4:16), 16	; F7673A  or (0x34d4),0x10
	jr	sub_F7669D_Code_Entry2	; F7673F  jr T,0xf767ab
	cp	(UI_StatusCode:16), 2	; F76741  cp (0x2880),0x02
	jr	z, sub_F7669D_Code_Skip4	; F76746  jr Z,0xf76774
	ld	xiy, 16210338	; F76748  ld XIY,0x00f759a2
	ld	xix, Disk_FileName	; F7674D  ld XIX,0x000021c8
	ldw	bc, 8	; F76752  ld BC,0x0008
	.byte 0x85, 0x11	; F76755  ldir   [llvm-mc cannot encode this]
	ld	(Disk_FileName+8:16), 63	; F76757  ld (0x21d0),0x3f
	ld	(Disk_FileName+9:16), 63	; F7675C  ld (0x21d1),0x3f
	ld	(Disk_FileName+10:16), 63	; F76761  ld (0x21d2),0x3f
	ld	l, (UI_StatusCode:16)	; F76766  ld L,(0x2880)
	pushw	hl	; F7676A  push HL
	call	T_DiskApi_DeleteFile_Call	; F7676B  call 0xf425b0
	popw	hl	; F7676F  pop HL
	ld	(UI_StatusCode:16), l	; F76770  ld (0x2880),L
sub_F7669D_Code_Skip4:
	calr	SmfSize_RestoreFileName	; F76774  calr 0xf768d0
	ld	(UI_ScreenPage:16), 0	; F76777  ld (0x2229),0x00
	jr	sub_F7669D_Code_Entry2	; F7677C  jr T,0xf767ab
sub_F7669D_Code_Loop:
	calr	SmfSize_RestoreSongFromTempFile	; F7677E  calr 0xf768a1
	ld	(UI_StatusCode:16), 30	; F76781  ld (0x2880),0x1e
	ld	(UI_ScreenPage:16), 0	; F76786  ld (0x2229),0x00
	jr	sub_F7669D_Code_Entry2	; F7678B  jr T,0xf767ab
sub_F7669D_Code_Entry:
	cp	(0x1238:16), 7	; F7678D  cp (0x1238),0x07
	jr	z, sub_F7669D_Code_Loop	; F76792  jr Z,0xf7677e
	ld	l, (4664:16)	; F76794  ld L,(0x1238)
	calr	SmfExport_ParamSysExTemplates + 0xE9	; F76798  calr 0xf750b8  (lands inside record 12 at +5; see SmfExport_ParamSysExTemplates)
	pushw	hl	; F7679B  push HL
	calr	SmfSize_RestoreSongFromTempFile	; F7679C  calr 0xf768a1
	popw	hl	; F7679F  pop HL
	ld	(UI_StatusCode:16), l	; F767A0  ld (0x2880),L
	jr	sub_F7669D_Code_Entry2	; F767A4  jr T,0xf767ab
	ld	(UI_ScreenPage:16), 2	; F767A6  ld (0x2229),0x02
sub_F7669D_Code_Entry2:
	and	(0x21e8:16), 127	; F767AB  and (0x21e8),0x7f
	popw	wa	; F767B0  pop WA
	ld	(Disk_ContentType:16), a	; F767B1  ld (0x2725),A
	and	(UI_Request_Hi:16), 253	; F767B5  and (0x2071),0xfd
	ret	; F767BA  ret


; --------------------------------------------------------------------------
; RamPtrTable_F767BB -- 16 32-bit words, every one below 0x10000, i.e. a
;                       16-bit RAM address stored one per long word.  First
;                       0x76A2, LAST 0x7AA2; the step between neighbours
;                       takes 2 distinct values (0x40 0x80).
; Read by: nothing in prom_a or prom_b spells this address as a 32-bit word,
;          so whatever reaches it computes the address
; Entry count: 16.  The chain stops at the first word that is not below
;              0x10000, at 0xF767FB.
; Evidence: every word is re-read and range-asserted on every emit.  The
;           RAMTAB rule fires ZERO times over the proven prom_b instruction
;           text (`python3 notes/prom_b_f6d002_layout.py --null-ptr`).
; Unknown: what lives at those RAM addresses.  The name describes the
;          CONTENT of the table, not its purpose.
; --------------------------------------------------------------------------
RamPtrTable_F767BB:
	.long	0x000076A2	; F767BB  [0] -> RAM 0x76A2
	.long	0x000076E2	; F767BF  [1] -> RAM 0x76E2
	.long	0x00007722	; F767C3  [2] -> RAM 0x7722
	.long	0x00007762	; F767C7  [3] -> RAM 0x7762
	.long	0x000077A2	; F767CB  [4] -> RAM 0x77A2
	.long	0x000077E2	; F767CF  [5] -> RAM 0x77E2
	.long	0x00007822	; F767D3  [6] -> RAM 0x7822
	.long	0x00007862	; F767D7  [7] -> RAM 0x7862
	.long	0x000078E2	; F767DB  [8] -> RAM 0x78E2
	.long	0x00007922	; F767DF  [9] -> RAM 0x7922
	.long	0x00007962	; F767E3  [10] -> RAM 0x7962
	.long	0x000079A2	; F767E7  [11] -> RAM 0x79A2
	.long	0x000079E2	; F767EB  [12] -> RAM 0x79E2
	.long	0x00007A22	; F767EF  [13] -> RAM 0x7A22
	.long	0x00007A62	; F767F3  [14] -> RAM 0x7A62
	.long	0x00007AA2	; F767F7  [15] -> RAM 0x7AA2


; --------------------------------------------------------------------------
; ByteMap_F767FB -- 33 bytes: a BYTE MAP.  0 of them are 0xFF and the other
;                   33 ASCEND STRICTLY, 0x00 to 0x7F, with jumps.  The name
;                   describes the CONTENT; what the two index spaces are is
;                   not established here.
; Read by: nothing in prom_a or prom_b spells this address as a 32-bit word,
;          so whatever reaches it computes the address
; Entry count: 33 bytes.  The run is trimmed of trailing 0xFF, so it claims
;              no padding it did not earn; the byte before it is 0x00 and
;              the LAST byte of it is 0x7F.
; Evidence: every non-0xFF byte is compared with its predecessor on every
;           emit, WITHIN EACH of the 1 maximal ascending runs the rule
;           returns, and the runs are asserted to tile this segment exactly.
;           The BYTEMAP rule fires ZERO times over the proven prom_b
;           instruction text at (16 bytes, 12 values) and also at (20,14),
;           (24,16) and (16,16) (`python3 notes/prom_b_f6d002_layout.py
;           --null-ptr`).
; Unknown: what the two index spaces ARE, and who reads it.
; --------------------------------------------------------------------------
ByteMap_F767FB:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F767FB  [0..15]
	.byte	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F	; F7680B  [16..31]
	.byte	0x7F	; F7681B  [32..32]
; --------------------------------------------------------------------------
; sub_F7681C
; Called from: no call site is known.  The label marks where a
;              converted run STARTS, so that a tool walking this file
;              by label does not attribute the run to its neighbour.
; Evidence: 0xF7681C is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
sub_F7681C:
	ret	; F7681C  ret
	ld	l, c	; F7681D  ld L,C
	xor	h, h	; F7681F  xor H,H
	push	xix	; F76821  push XIX
	ld	xix, Table_F7682E	; F76822  ld XIX,0x00f7682e
	ld	l, (xix+hl)	; F76827  ld L,(XIX+HL)
	pop	xix	; F7682C  pop XIX
	ret	; F7682D  ret

; --------------------------------------------------------------------------
; Table_F7682E -- an 8-entry BYTE lookup table: 0x00, 0x00, 0x00, 0x40, 0x40, 0x60, 0x60, 0x7F.
;          Non-decreasing, 0x00 to 0x7F.  What the index and the value MEAN
;          is not established here.
; Read by: 0xF76822 `ld XIX,0x00F7682E` followed by `ld L,(XIX+HL)` at
;          0xF76827, with HL = C zero-extended -- the whole of the
;          three-instruction routine at 0xF7681D.
; ⚠ Why:   the linear decode frames the first five bytes as three `nop`s and
;          an `ld XWA,0x7f606040`. They are DATA; the byte gate cannot tell,
;          the operand can.
; --------------------------------------------------------------------------
Table_F7682E:
	.byte	0x00, 0x00, 0x00, 0x40, 0x40, 0x60, 0x60, 0x7F	; F7682E  entries 0-7


; --------------------------------------------------------------------------
; MidiFileList_CheckSelectedEntryBlank_Copy
; Called from: no call site is known.  The label marks where a
;              converted run STARTS, so that a tool walking this file
;              by label does not attribute the run to its neighbour.
; Evidence: 0xF76836 is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; MidiFileList_CheckSelectedEntryBlank_Copy: an exact copy of MidiFileList_CheckSelectedEntryBlank (prom_b 0xF74885) -- all 18 instructions equal, operands included,
;   but the targets of its jr / jrl / djnz (notes/wsa1_exact_copy_names.py).
MidiFileList_CheckSelectedEntryBlank_Copy:
	push	xbc	; F76836  push XBC
	push	xix	; F76837  push XIX
	ld	xix, 6333568	; F76838  ld XIX,0x0060a480
	xor	xwa, xwa	; F7683D  xor XWA,XWA
	ld	a, (Disk_SelectedEntry:16)	; F7683F  ld A,(0x2724)
	sla	xwa, 3	; F76843  sla 0x03,XWA
	add	xix, xwa	; F76846  add XIX,XWA
	ld	c, 8:opc	; F76848  ld C,0x08
	ld	a, 0:opc	; F7684A  ld A,0x00
	cp	(xix+), 32	; F7684C  cp (XIX+),0x20
	jr	nz, MidiFileList_CheckSelectedEntryBlank_Copy_Skip	; F76850  jr NZ,0xf76857
	djnz8	c, -9	; F76852  djnz C,0xf7684c
	jr	MidiFileList_CheckSelectedEntryBlank_Copy_Epilogue	; F76855  jr T,0xf7685b
MidiFileList_CheckSelectedEntryBlank_Copy_Skip:
	ld	a, 254:opc	; F76857  ld A,0xfe
	jr	MidiFileList_CheckSelectedEntryBlank_Copy_Epilogue	; F76859  jr T,0xf7685b
MidiFileList_CheckSelectedEntryBlank_Copy_Epilogue:
	pop	xix	; F7685B  pop XIX
	pop	xbc	; F7685C  pop XBC
	ret	; F7685D  ret
	push	xhl	; F7685E  push XHL
	pushw	bc	; F7685F  push BC
	push	xiy	; F76860  push XIY
	push	xix	; F76861  push XIX
	xor	bc, bc	; F76862  xor BC,BC
	xor	w, w	; F76864  xor W,W
MidiFileList_CheckSelectedEntryBlank_Copy_Loop:
	ld	xix, 6333568	; F76866  ld XIX,0x0060a480
	ld	hl, bc	; F7686B  ld HL,BC
	sla	hl, 3	; F7686D  sla 0x03,HL
	lda	xix, (xix+hl)	; F76870  lda XIX,XIX+HL
	ld	xiy, Disk_FileName	; F76875  ld XIY,0x000021c8
	xor	hl, hl	; F7687A  xor HL,HL
MidiFileList_CheckSelectedEntryBlank_Copy_Loop2:
	ld	a, (xiy+)	; F7687C  ld A,(XIY+)
	cp	a, (xix)	; F7687F  cp A,(XIX)
	jr	nz, MidiFileList_CheckSelectedEntryBlank_Copy_Skip2	; F76881  jr NZ,0xf76893
	inc	1, xix	; F76883  inc 1,XIX
	inc	1, l	; F76885  inc 1,L
	cp	l, 7:i3	; F76887  cp L,7
	jr	ule, MidiFileList_CheckSelectedEntryBlank_Copy_Loop2	; F76889  jr ULE,0xf7687c
	ld	(Disk_SelectedEntry:16), c	; F7688B  ld (0x2724),C
	ld	w, 255:opc	; F7688F  ld W,0xff
	jr	MidiFileList_CheckSelectedEntryBlank_Copy_Epilogue2	; F76891  jr T,0xf7689c
MidiFileList_CheckSelectedEntryBlank_Copy_Skip2:
	inc	1, c	; F76893  inc 1,C
	cp	c, 99	; F76895  cp C,0x63
	jr	ule, MidiFileList_CheckSelectedEntryBlank_Copy_Loop	; F76898  jr ULE,0xf76866
	xor	w, w	; F7689A  xor W,W
MidiFileList_CheckSelectedEntryBlank_Copy_Epilogue2:
	pop	xix	; F7689C  pop XIX
	pop	xiy	; F7689D  pop XIY
	popw	bc	; F7689E  pop BC
	pop	xhl	; F7689F  pop XHL
	ret	; F768A0  ret

; --------------------------------------------------------------------------
; SmfSize_RestoreSongFromTempFile
; Called from: 0xF76726, 0xF7677E, 0xF7679C -- all three inside sub_F7669D, which nothing
;              references, so this is dead too; its 0x00F759A2 is inside an instruction (0xF759A1)
; Evidence: 0xF768A1 is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfSize_RestoreSongFromTempFile: Copy B's SmfWrite_RestoreSongFromTempFile: 11 bytes into Disk_FileName,
;   Disk_ContentType := 1, T_DiskLoadFile_Execute, extension '???', T_DiskApi_DeleteFile_Call,
;   SmfSize_RestoreFileName. Dead here: its callers are inside unreferenced sub_F7669D, and its name source 0xF759A2
;   is mid-instruction in this build. Basis: body + named twin + callee. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_d9.json)
SmfSize_RestoreSongFromTempFile:
	ld	xiy, 16210338	; F768A1  ld XIY,0x00f759a2
	ld	xix, Disk_FileName	; F768A6  ld XIX,0x000021c8
	ldw	bc, 11	; F768AB  ld BC,0x000b
	.byte 0x85, 0x11	; F768AE  ldir   [llvm-mc cannot encode this]
	ld	(Disk_ContentType:16), 1	; F768B0  ld (0x2725),0x01
	call	T_DiskLoadFile_Execute	; F768B5  call 0xf425c8
	ld	(Disk_FileName+8:16), 63	; F768B9  ld (0x21d0),0x3f
	ld	(Disk_FileName+9:16), 63	; F768BE  ld (0x21d1),0x3f
	ld	(Disk_FileName+10:16), 63	; F768C3  ld (0x21d2),0x3f
	call	T_DiskApi_DeleteFile_Call	; F768C8  call 0xf425b0
	calr	SmfSize_RestoreFileName	; F768CC  calr 0xf768d0
	ret	; F768CF  ret

; --------------------------------------------------------------------------
; SmfSize_RestoreFileName
; Called from: 0xF76774, 0xF768CC, 0xF76B93
; Evidence: 0xF768D0 is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfSize_RestoreFileName: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role RestoreFileName as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_RestoreFileName:
	ld	xiy, 4666	; F768D0  ld XIY,0x0000123a
	ld	xix, Disk_FileName	; F768D5  ld XIX,0x000021c8
	ldw	bc, 4	; F768DA  ld BC,0x0004
	ldirw	; F768DD  ldirw
	ret	; F768DF  ret

; --------------------------------------------------------------------------
; SmfSize_SaveFileName
; Called from: 0xF76B60
; Evidence: 0xF768E0 is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfSize_SaveFileName: copy B of prom_b's SMF writer (the sizing pass Smf_WriteFile runs first), role SaveFileName as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSize_SaveFileName:
	ld	xiy, Disk_FileName	; F768E0  ld XIY,0x000021c8
	ld	xix, 4666	; F768E5  ld XIX,0x0000123a
	ldw	bc, 4	; F768EA  ld BC,0x0004
	ldirw	; F768ED  ldirw
	ret	; F768EF  ret

; --------------------------------------------------------------------------
; SmfFileTemplate_F768F0 -- the 33-byte STANDARD MIDI FILE header this
;          firmware copies into its output buffer before writing a track.
;          Format 0, one track, division 96 ticks per quarter note.
;          ⚠ NOT MUSIC: no note, no end-of-track.  The events are written
;          at run time by the code below; this is only the file's opening.
; Read by: NOTHING. Not one 32-bit word in any of the four images holds an
;          address in [0xF768F0, 0xF76953) -- while each of the three live
;          copies is spelled at four interior offsets. This copy is an
;          ORPHAN. ⚠ A computed address cannot be excluded by a scan; the
;          claim is about the scan.
; Length:  the `00 00 00 00` at +0x12 is a PLACEHOLDER. 0xF7789A computes
;          (0x126C)*1024 + (cursor - 0x60A700) - 22 and stores it most
;          significant byte first into (0x10C4)-(0x10C7). 22 = `MThd` + its
;          6 payload bytes + `MTrk`. That is why every chunk walker that
;          trusts the field steps nowhere.
; Evidence: notes/gen_prom_b_smf_writer_module.py --selftest re-derives every
;           byte and every reader from the ROM.
; --------------------------------------------------------------------------
SmfFileTemplate_F768F0:
	.ascii	"MThd"	; F768F0  header chunk tag
	.byte	0x00, 0x00, 0x00, 0x06	; F768F4  chunk length 6, most significant byte first
	.byte	0x00, 0x00	; F768F8  format 0 -- one multi-channel track
	.byte	0x00, 0x01	; F768FA  ntrks 1
	.byte	0x00, 0x60	; F768FC  division 0x0060 = 96 ticks per quarter note
	.ascii	"MTrk"	; F768FE  track chunk tag
	.byte	0x00, 0x00, 0x00, 0x00	; F76902  track length PLACEHOLDER -- backfilled by 0xF7789A
	.byte	0x00	; F76906  delta time 0
	.byte	0xFF, 0x03	; F76907  meta event FF 03 -- sequence/track name
	.byte	0x0F	; F76909  ... declared length 15
	.ascii	"WSA    "	; F7690A  name bytes 1-7; 8-15 come from RAM (0x21C8)

; --------------------------------------------------------------------------
; SmfPartOffsets_F76911 -- 32 little-endian 16-bit BYTE OFFSETS and a
;          0xFFFF terminator.  NOT MIDI, and not part of the file: it only
;          happens to sit 0x21 bytes after the template.
;          0x0000, 0x0040 ... 0x0800, step 0x40 -- one record per slot in the
;          0x40-strided array at RAM 0x006036A0.
; Read by: nothing -- this copy is the orphan's.
; ⚠ Note:  the step is 0x40 everywhere EXCEPT between slots 7 and 8, where
;          it is 0x80: the record at 0x0200 is skipped. That is in the ROM
;          and identical in all four copies. What occupies the skipped slot
;          is NOT established.
; --------------------------------------------------------------------------
SmfPartOffsets_F76911:
	.short	0x0000, 0x0040, 0x0080, 0x00C0, 0x0100, 0x0140, 0x0180, 0x01C0	; F76911  slots  0- 7
	.short	0x0240, 0x0280, 0x02C0, 0x0300, 0x0340, 0x0380, 0x03C0, 0x0400	; F76921  slots  8-15
	.short	0x0440, 0x0480, 0x04C0, 0x0500, 0x0540, 0x0580, 0x05C0, 0x0600	; F76931  slots 16-23
	.short	0x0640, 0x0680, 0x06C0, 0x0700, 0x0740, 0x0780, 0x07C0, 0x0800	; F76941  slots 24-31
	.short	0xFFFF	; F76951  terminator

; --------------------------------------------------------------------------
; SmfWriteCopy_StageTempoFromBpm
; Called from: no call site is known.  The label marks where a
;              converted run STARTS, so that a tool walking this file
;              by label does not attribute the run to its neighbour.
; Evidence: 0xF76953 is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfWriteCopy_StageTempoFromBpm: copy C of prom_b's SMF writer (an unreferenced copy of A), role StageTempoFromBpm as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWriteCopy_StageTempoFromBpm:
	ldw	de, 9	; F76953  ld DE,0x0009
	ldw	wa, 10176	; F76956  ld WA,0x27c0
	ld	qwa, de	; F76959  ld QWA,DE
	div	xwa, hl	; F7695C  div XWA,HL
	ld	de, qwa	; F7695E  ld DE,QWA
	ldw	hl, 100	; F76961  ld HL,0x0064
	xor	de, de	; F76964  xor DE,DE
	extz	xwa	; F76966  extz XWA
	muls	xwa, hl	; F76968  muls XWA,HL
	ld	de, qwa	; F7696A  ld DE,QWA
	ld	(SmfOut_Tempo:16), wa	; F7696D  ld (0x108c),WA
	ld	(SmfOut_Tempo+2:16), de	; F76971  ld (0x108e),DE
	ret	; F76975  ret
	ld	xiy, Smf_VlqBytes	; F76976  ld XIY,0x00001193
	ld	xix, (InputStream_Cursor:16)	; F7697B  ld XIX,(0x1088)
SmfWriteCopy_StageTempoFromBpm_Loop:
	ld	a, (xiy+)	; F7697F  ld A,(XIY+)
	ld	(xix+), a	; F76982  ld (XIX+),A
	pushw	wa	; F76985  push WA
	push	xiy	; F76986  push XIY
	calr	SmfWriteCopy_CommitOutputByte	; F76987  calr 0xf76adf
	pop	xiy	; F7698A  pop XIY
	popw	wa	; F7698B  pop WA
	cp	(0x1238:16), 3	; F7698C  cp (0x1238),0x03
	jrl	nz, SmfWriteCopy_StageTempoFromBpm_Return	; F76991  jrl NZ,0xf76a16
	ld	xix, (InputStream_Cursor:16)	; F76994  ld XIX,(0x1088)
	bit	7, a	; F76998  bit 0x07,A
	jr	nz, SmfWriteCopy_StageTempoFromBpm_Loop	; F7699B  jr NZ,0xf7697f
	ld	a, 255:opc	; F7699D  ld A,0xff
	ld	(xix+), a	; F7699F  ld (XIX+),A
	calr	SmfWriteCopy_CommitOutputByte	; F769A2  calr 0xf76adf
	cp	(0x1238:16), 3	; F769A5  cp (0x1238),0x03
	jrl	nz, SmfWriteCopy_StageTempoFromBpm_Return	; F769AA  jrl NZ,0xf76a16
	ld	xix, (InputStream_Cursor:16)	; F769AD  ld XIX,(0x1088)
	ld	a, 81:opc	; F769B1  ld A,0x51
	ld	(xix+), a	; F769B3  ld (XIX+),A
	calr	SmfWriteCopy_CommitOutputByte	; F769B6  calr 0xf76adf
	cp	(0x1238:16), 3	; F769B9  cp (0x1238),0x03
	jr	nz, SmfWriteCopy_StageTempoFromBpm_Return	; F769BE  jr NZ,0xf76a16
	ld	xix, (InputStream_Cursor:16)	; F769C0  ld XIX,(0x1088)
	ld	a, 3:opc	; F769C4  ld A,0x03
	ld	(xix+), a	; F769C6  ld (XIX+),A
	calr	SmfWriteCopy_CommitOutputByte	; F769C9  calr 0xf76adf
	cp	(0x1238:16), 3	; F769CC  cp (0x1238),0x03
	jr	nz, SmfWriteCopy_StageTempoFromBpm_Return	; F769D1  jr NZ,0xf76a16
	ld	xix, (InputStream_Cursor:16)	; F769D3  ld XIX,(0x1088)
	ld	a, (SmfOut_Tempo+2:16)	; F769D7  ld A,(0x108e)
	ld	(xix+), a	; F769DB  ld (XIX+),A
	calr	SmfWriteCopy_CommitOutputByte	; F769DE  calr 0xf76adf
	cp	(0x1238:16), 3	; F769E1  cp (0x1238),0x03
	jr	nz, SmfWriteCopy_StageTempoFromBpm_Return	; F769E6  jr NZ,0xf76a16
	ld	xix, (InputStream_Cursor:16)	; F769E8  ld XIX,(0x1088)
	ld	a, (SmfOut_Tempo+1:16)	; F769EC  ld A,(0x108d)
	ld	(xix+), a	; F769F0  ld (XIX+),A
	calr	SmfWriteCopy_CommitOutputByte	; F769F3  calr 0xf76adf
	cp	(0x1238:16), 3	; F769F6  cp (0x1238),0x03
	jr	nz, SmfWriteCopy_StageTempoFromBpm_Return	; F769FB  jr NZ,0xf76a16
	ld	xix, (InputStream_Cursor:16)	; F769FD  ld XIX,(0x1088)
	ld	a, (SmfOut_Tempo:16)	; F76A01  ld A,(0x108c)
	ld	(xix+), a	; F76A05  ld (XIX+),A
	calr	SmfWriteCopy_CommitOutputByte	; F76A08  calr 0xf76adf
	cp	(0x1238:16), 3	; F76A0B  cp (0x1238),0x03
	jr	nz, SmfWriteCopy_StageTempoFromBpm_Return	; F76A10  jr NZ,0xf76a16
	ld	xix, (InputStream_Cursor:16)	; F76A12  ld XIX,(0x1088)
SmfWriteCopy_StageTempoFromBpm_Return:
	ret	; F76A16  ret
	ld	a, (4506:16)	; F76A17  ld A,(0x119a)
	and	a, 15	; F76A1B  and A,0x0f
	or	a, 176	; F76A1E  or A,0xb0
	calr	SmfWriteCopy_WriteChannelEvent	; F76A21  calr 0xf76a6a
	ret	; F76A24  ret

; --------------------------------------------------------------------------
; SmfWriteCopy_EncodeDeltaTime
; Called from: 0xF766CA, 0xF766ED
; Evidence: 0xF76A25 is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfWriteCopy_EncodeDeltaTime: copy C of prom_b's SMF writer (an unreferenced copy of A), role EncodeDeltaTime as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWriteCopy_EncodeDeltaTime:
	pushw	wa	; F76A25  push WA
	push	xhl	; F76A26  push XHL
	pushw	de	; F76A27  push DE
	xor	wa, wa	; F76A28  xor WA,WA
	ld	(4522:16), wa	; F76A2A  ld (0x11aa),WA
	ld	(4524:16), a	; F76A2E  ld (0x11ac),A
	ld	wa, (4222:16)	; F76A32  ld WA,(0x107e)
	xor	b, b	; F76A36  xor B,B
	add	wa, bc	; F76A38  add WA,BC
	ld	de, (4226:16)	; F76A3A  ld DE,(0x1082)
	sub	wa, de	; F76A3E  sub WA,DE
	ld	(4522:16), wa	; F76A40  ld (0x11aa),WA
	bit	0, (0x1268:16)	; F76A44  bit 0,(0x1268)
	jr	nz, SmfWriteCopy_EncodeDeltaTime_Skip	; F76A48  jr NZ,0xf76a5b
	bit	1, (0x133e:16)	; F76A4A  bit 1,(0x133e)
	jr	z, SmfWriteCopy_EncodeDeltaTime_Skip	; F76A4E  jr Z,0xf76a5b
	addw	(0x11aa:16), 384	; F76A50  add (0x11aa),0x0180
	ld	(4712:16), 1	; F76A56  ld (0x1268),0x01
SmfWriteCopy_EncodeDeltaTime_Skip:
	ld	(4226:16), bc	; F76A5B  ld (0x1082),BC
	ld	(4240:16), de	; F76A5F  ld (0x1090),DE
	popw	de	; F76A63  pop DE
	pop	xhl	; F76A64  pop XHL
	popw	wa	; F76A65  pop WA
	calr	SmfWriteCopy_EncodeVlq	; F76A66  calr 0xf76d38
	ret	; F76A69  ret

; --------------------------------------------------------------------------
; SmfWriteCopy_WriteChannelEvent
; Called from: 0xF766DA, 0xF76701, 0xF76A21, 0xF76CF9
; Evidence: 0xF76A6A is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfWriteCopy_WriteChannelEvent: copy C of prom_b's SMF writer (an unreferenced copy of A), role WriteChannelEvent as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWriteCopy_WriteChannelEvent:
	push	xiy	; F76A6A  push XIY
	ld	xix, (InputStream_Cursor:16)	; F76A6B  ld XIX,(0x1088)
	ld	xiy, Smf_VlqBytes	; F76A6F  ld XIY,0x00001193
	pushw	wa	; F76A74  push WA
SmfWriteCopy_WriteChannelEvent_Loop:
	ld	a, (xiy+)	; F76A75  ld A,(XIY+)
	ld	(xix+), a	; F76A78  ld (XIX+),A
	pushw	wa	; F76A7B  push WA
	pushw	hl	; F76A7C  push HL
	push	xiy	; F76A7D  push XIY
	calr	SmfWriteCopy_CommitOutputByte	; F76A7E  calr 0xf76adf
	pop	xiy	; F76A81  pop XIY
	popw	hl	; F76A82  pop HL
	popw	wa	; F76A83  pop WA
	cp	(0x1238:16), 3	; F76A84  cp (0x1238),0x03
	jr	z, SmfWriteCopy_WriteChannelEvent_Skip	; F76A89  jr Z,0xf76a8e
	popw	wa	; F76A8B  pop WA
	jr	SmfWriteCopy_WriteChannelEvent_Join	; F76A8C  jr T,0xf76ad9
SmfWriteCopy_WriteChannelEvent_Skip:
	ld	xix, (InputStream_Cursor:16)	; F76A8E  ld XIX,(0x1088)
	bit	7, a	; F76A92  bit 0x07,A
	jr	nz, SmfWriteCopy_WriteChannelEvent_Loop	; F76A95  jr NZ,0xf76a75
	popw	wa	; F76A97  pop WA
	ld	h, a	; F76A98  ld H,A
	ld	(xix+), a	; F76A9A  ld (XIX+),A
	pushw	wa	; F76A9D  push WA
	pushw	hl	; F76A9E  push HL
	calr	SmfWriteCopy_CommitOutputByte	; F76A9F  calr 0xf76adf
	popw	hl	; F76AA2  pop HL
	popw	wa	; F76AA3  pop WA
	cp	(0x1238:16), 3	; F76AA4  cp (0x1238),0x03
	jr	nz, SmfWriteCopy_WriteChannelEvent_Join	; F76AA9  jr NZ,0xf76ad9
	ld	xix, (InputStream_Cursor:16)	; F76AAB  ld XIX,(0x1088)
	ld	a, w	; F76AAF  ld A,W
	ld	(xix+), a	; F76AB1  ld (XIX+),A
	pushw	hl	; F76AB4  push HL
	calr	SmfWriteCopy_CommitOutputByte	; F76AB5  calr 0xf76adf
	popw	hl	; F76AB8  pop HL
	cp	(0x1238:16), 3	; F76AB9  cp (0x1238),0x03
	jr	nz, SmfWriteCopy_WriteChannelEvent_Join	; F76ABE  jr NZ,0xf76ad9
	ld	xix, (InputStream_Cursor:16)	; F76AC0  ld XIX,(0x1088)
	and	h, 240	; F76AC4  and H,0xf0
	cp	h, 192	; F76AC7  cp H,0xc0
	jr	z, SmfWriteCopy_WriteChannelEvent_Join	; F76ACA  jr Z,0xf76ad9
	cp	h, 208	; F76ACC  cp H,0xd0
	jr	z, SmfWriteCopy_WriteChannelEvent_Join	; F76ACF  jr Z,0xf76ad9
	ld	a, l	; F76AD1  ld A,L
	ld	(xix+), a	; F76AD3  ld (XIX+),A
	calr	SmfWriteCopy_CommitOutputByte	; F76AD6  calr 0xf76adf
SmfWriteCopy_WriteChannelEvent_Join:
	pop	xiy	; F76AD9  pop XIY
	ld	xix, (InputStream_Cursor:16)	; F76ADA  ld XIX,(0x1088)
	ret	; F76ADE  ret

; --------------------------------------------------------------------------
; SmfWriteCopy_CommitOutputByte
; Called from: 0xF76987, 0xF769A2, 0xF769B6, 0xF769C9, 0xF769DE, 0xF769F3,
;              0xF76A08, 0xF76A7E, 0xF76A9F, 0xF76AB5, 0xF76AD6
; Evidence: 0xF76ADF is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfWriteCopy_CommitOutputByte: copy C of prom_b's SMF writer (an unreferenced copy of A), role CommitOutputByte as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWriteCopy_CommitOutputByte:
	push	xhl	; F76ADF  push XHL
	pushw	bc	; F76AE0  push BC
	ld	(4664:16), 3	; F76AE1  ld (0x1238),0x03
	cp	xix, 6335231	; F76AE6  cp XIX,0x0060aaff
	jr	ugt, sub_F76ADF_Entry	; F76AEC  jr UGT,0xf76af4
	ld	(InputStream_Cursor:16), xix	; F76AEE  ld (0x1088),XIX
	jr	sub_F76ADF_Epilogue	; F76AF2  jr T,0xf76b59
sub_F76ADF_Entry:
	cpw	(SmfOut_WindowsFlushed:16), 0	; F76AF4  cp (0x126c),0x0000
	jr	nz, sub_F76ADF_Skip	; F76AFA  jr NZ,0xf76b10
	ld	c, a	; F76AFC  ld C,A
	pushw	bc	; F76AFE  push BC
	call	SmfOut_CreateFileWithFirstWindow	; F76AFF  call 0xf77d4b
	popw	bc	; F76B03  pop BC
	ld	w, a	; F76B04  ld W,A
	ld	(4664:16), w	; F76B06  ld (0x1238),W
	cp	w, 3:i3	; F76B0A  cp W,3
	jr	nz, sub_F76ADF_Epilogue	; F76B0C  jr NZ,0xf76b59
	jr	sub_F76ADF_Join	; F76B0E  jr T,0xf76b48
sub_F76ADF_Skip:
	ld	c, a	; F76B10  ld C,A
	incw	1, (4680:16)	; F76B12  incw 1,(0x1248)
	pushw	wa	; F76B16  push WA
	push	xhl	; F76B17  push XHL
	pushw	bc	; F76B18  push BC
	pushw	de	; F76B19  push DE
	ld	wa, (4680:16)	; F76B1A  ld WA,(0x1248)
	xor	de, de	; F76B1E  xor DE,DE
	ldw	hl, 4	; F76B20  ld HL,0x0004
	ld	qwa, de	; F76B23  ld QWA,DE
	div	xwa, hl	; F76B26  div XWA,HL
	ld	de, qwa	; F76B28  ld DE,QWA
	cp	de, 0:i3	; F76B2B  cp DE,0
	jr	nz, sub_F76ADF_Skip2	; F76B2D  jr NZ,0xf76b35
	push	xix	; F76B2F  push XIX
	call	T_DiskProgress_PrintDotForSmf	; F76B30  call 0xf42604
	pop	xix	; F76B34  pop XIX
sub_F76ADF_Skip2:
	popw	de	; F76B35  pop DE
	popw	bc	; F76B36  pop BC
	pop	xhl	; F76B37  pop XHL
	popw	wa	; F76B38  pop WA
	pushw	bc	; F76B39  push BC
	calr	SmfOut_WriteNextWindow	; F76B3A  calr 0xf77dc6
	popw	bc	; F76B3D  pop BC
	ld	w, a	; F76B3E  ld W,A
	ld	(4664:16), w	; F76B40  ld (0x1238),W
	cp	w, 3:i3	; F76B44  cp W,3
	jr	nz, sub_F76ADF_Epilogue	; F76B46  jr NZ,0xf76b59
sub_F76ADF_Join:
	incw	1, (SmfOut_WindowsFlushed:16)	; F76B48  incw 1,(0x126c)
	ld	xwa, 6334208	; F76B4C  ld XWA,0x0060a700
	ld	(InputStream_Cursor:16), xwa	; F76B51  ld (0x1088),XWA
	ld	xix, xwa	; F76B55  ld XIX,XWA
	ld	a, c	; F76B57  ld A,C
sub_F76ADF_Epilogue:
	popw	bc	; F76B59  pop BC
	pop	xhl	; F76B5A  pop XHL
	ret	; F76B5B  ret
	push	xix	; F76B5C  push XIX
	push	xiy	; F76B5D  push XIY
	push	xhl	; F76B5E  push XHL
	push	xbc	; F76B5F  push XBC
	calr	SmfSize_SaveFileName	; F76B60  calr 0xf768e0
	ld	xiy, 6333568	; F76B63  ld XIY,0x0060a480
	ld	l, (Disk_SelectedEntry:16)	; F76B68  ld L,(0x2724)
	xor	h, h	; F76B6C  xor H,H
	sla	hl, 3	; F76B6E  sla 0x03,HL
	lda	xiy, (xiy+hl)	; F76B71  lda XIY,XIY+HL
	ld	xix, Disk_FileName	; F76B76  ld XIX,0x000021c8
	ldw	bc, 4	; F76B7B  ld BC,0x0004
	ldirw	; F76B7E  ldirw
	ld	(Disk_FileName+8:16), 63	; F76B80  ld (0x21d0),0x3f
	ld	(Disk_FileName+9:16), 63	; F76B85  ld (0x21d1),0x3f
	ld	(Disk_FileName+10:16), 63	; F76B8A  ld (0x21d2),0x3f
	call	T_DiskApi_DeleteFile_Call	; F76B8F  call 0xf425b0
	calr	SmfSize_RestoreFileName	; F76B93  calr 0xf768d0
	pop	xbc	; F76B96  pop XBC
	pop	xhl	; F76B97  pop XHL
	pop	xiy	; F76B98  pop XIY
	pop	xix	; F76B99  pop XIX
	ret	; F76B9A  ret

; --------------------------------------------------------------------------
; SmfWriteCopy_AgePendingNoteOffs
; Called from: 0xF766CD, 0xF766F0
; Evidence: 0xF76B9B is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfWriteCopy_AgePendingNoteOffs: copy C of prom_b's SMF writer (an unreferenced copy of A), role AgePendingNoteOffs as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWriteCopy_AgePendingNoteOffs:
	ld	(4664:16), 3	; F76B9B  ld (0x1238),0x03
	calr	SmfWriteCopy_ClearDueList	; F76BA0  calr 0xf76deb
	xor	hl, hl	; F76BA3  xor HL,HL
	xor	bc, bc	; F76BA5  xor BC,BC
	xor	iy, iy	; F76BA7  xor IY,IY
SmfWriteCopy_AgePendingNoteOffs_Loop:
	push	xix	; F76BA9  push XIX
	ld	xix, 12378	; F76BAA  ld XIX,0x0000305a
	.byte 0xF3, 0x07, 0xF0, 0xEC, 0xCF	; F76BAF  bit 7,(XIX+HL)   [llvm-mc cannot encode this]
	pop	xix	; F76BB4  pop XIX
	jr	z, SmfWriteCopy_AgePendingNoteOffs_Join	; F76BB5  jr Z,0xf76c0a
	push	xix	; F76BB7  push XIX
	ld	xix, 12378	; F76BB8  ld XIX,0x0000305a
	lda	xix, (xix+hl)	; F76BBD  lda XIX,XIX+HL
	ld	wa, (xix+3)	; F76BC2  ld WA,(XIX+0x03)
	pop	xix	; F76BC5  pop XIX
	cp	wa, (4522:16)	; F76BC6  cp WA,(0x11aa)
	jr	ule, SmfWriteCopy_AgePendingNoteOffs_Skip	; F76BCA  jr ULE,0xf76be0
	sub	wa, (4522:16)	; F76BCC  sub WA,(0x11aa)
	push	xix	; F76BD0  push XIX
	ld	xix, 12378	; F76BD1  ld XIX,0x0000305a
	extz	xhl	; F76BD6  extz XHL
	add	xix, xhl	; F76BD8  add XIX,XHL
	ld	(xix+3), wa	; F76BDA  ld (XIX+0x03),WA
	pop	xix	; F76BDD  pop XIX
	jr	SmfWriteCopy_AgePendingNoteOffs_Join	; F76BDE  jr T,0xf76c0a
SmfWriteCopy_AgePendingNoteOffs_Skip:
	push	xde	; F76BE0  push XDE
	ld	xde, 4307	; F76BE1  ld XDE,0x000010d3
	ld	(xde+iy), c	; F76BE6  ld (XDE+IY),C
	ld	xde, 12378	; F76BEB  ld XDE,0x0000305a
	lda	xde, (xde+hl)	; F76BF0  lda XDE,XDE+HL
	ld	wa, (xde+3)	; F76BF5  ld WA,(XDE+0x03)
	ld	xde, 4307	; F76BF8  ld XDE,0x000010d3
	lda	xde, (xde+iy)	; F76BFD  lda XDE,XDE+IY
	ld	(xde+1), wa	; F76C02  ld (XDE+0x01),WA
	pop	xde	; F76C05  pop XDE
	add	iy, 3	; F76C06  add IY,0x0003
SmfWriteCopy_AgePendingNoteOffs_Join:
	add	hl, 5	; F76C0A  add HL,0x0005
	inc	1, bc	; F76C0E  inc 1,BC
	cp	c, 32	; F76C10  cp C,0x20
	jr	ule, SmfWriteCopy_AgePendingNoteOffs_Loop	; F76C13  jr ULE,0xf76ba9
	srl	iy, 1	; F76C15  srl 0x01,IY
	cp	iy, 0:i3	; F76C18  cp IY,0
	jr	z, SmfWriteCopy_AgePendingNoteOffs_Skip2	; F76C1A  jr Z,0xf76c1f
	calr	SmfWriteCopy_SortDueNoteOffs	; F76C1C  calr 0xf76c2c
SmfWriteCopy_AgePendingNoteOffs_Skip2:
	ldw	(4222:16), 0	; F76C1F  ld (0x107e),0x0000
	ldw	(4224:16), 0	; F76C25  ld (0x1080),0x0000
	ret	; F76C2B  ret

; --------------------------------------------------------------------------
; SmfWriteCopy_SortDueNoteOffs
; Called from: 0xF76C1C
; Evidence: 0xF76C2C is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfWriteCopy_SortDueNoteOffs: copy C of prom_b's SMF writer (an unreferenced copy of A), role SortDueNoteOffs as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWriteCopy_SortDueNoteOffs:
	cp	iy, 0:i3	; F76C2C  cp IY,0
	jr	z, SmfWriteCopy_SortDueNoteOffs_Return	; F76C2E  jr Z,0xf76c96
	xor	de, de	; F76C30  xor DE,DE
	cp	(0x10d3:16), 255	; F76C32  cp (0x10d3),0xff
	jr	z, SmfWriteCopy_SortDueNoteOffs_Return	; F76C37  jr Z,0xf76c96
SmfWriteCopy_SortDueNoteOffs_Loop:
	ld	xiy, 4307	; F76C39  ld XIY,0x000010d3
	ld	xix, 4310	; F76C3E  ld XIX,0x000010d6
	lda	xiy, (xiy+de)	; F76C43  lda XIY,XIY+DE
	lda	xix, (xix+de)	; F76C48  lda XIX,XIX+DE
	cp	(xiy), 255	; F76C4D  cp (XIY),0xff
	jr	z, SmfWriteCopy_SortDueNoteOffs_Skip3	; F76C50  jr Z,0xf76c93
	ld	wa, (xiy+1)	; F76C52  ld WA,(XIY+0x01)
SmfWriteCopy_SortDueNoteOffs_Join:
	ld	l, (xix)	; F76C55  ld L,(XIX)
	cp	l, 255	; F76C57  cp L,0xff
	jr	z, SmfWriteCopy_SortDueNoteOffs_Skip2	; F76C5A  jr Z,0xf76c89
	cp	wa, (xix+1)	; F76C5C  cp WA,(XIX+0x01)
	jr	ugt, SmfWriteCopy_SortDueNoteOffs_Skip	; F76C5F  jr UGT,0xf76c71
	add	xix, 3	; F76C61  add XIX,0x00000003
	cp	xix, 4496	; F76C67  cp XIX,0x00001190
	jr	ugt, SmfWriteCopy_SortDueNoteOffs_Skip2	; F76C6D  jr UGT,0xf76c89
	jr	SmfWriteCopy_SortDueNoteOffs_Join	; F76C6F  jr T,0xf76c55
SmfWriteCopy_SortDueNoteOffs_Skip:
	ld	a, (xiy)	; F76C71  ld A,(XIY)
	ld	l, (xix)	; F76C73  ld L,(XIX)
	ld	(xiy), l	; F76C75  ld (XIY),L
	ld	(xix), a	; F76C77  ld (XIX),A
	ld	wa, (xiy+1)	; F76C79  ld WA,(XIY+0x01)
	ld	hl, (xix+1)	; F76C7C  ld HL,(XIX+0x01)
	ld	(xiy+1), hl	; F76C7F  ld (XIY+0x01),HL
	ld	(xix+1), wa	; F76C82  ld (XIX+0x01),WA
	xor	de, de	; F76C85  xor DE,DE
	jr	SmfWriteCopy_SortDueNoteOffs_Loop	; F76C87  jr T,0xf76c39
SmfWriteCopy_SortDueNoteOffs_Skip2:
	add	de, 3	; F76C89  add DE,0x0003
	cp	de, 96	; F76C8D  cp DE,0x0060
	jr	ule, SmfWriteCopy_SortDueNoteOffs_Loop	; F76C91  jr ULE,0xf76c39
SmfWriteCopy_SortDueNoteOffs_Skip3:
	calr	SmfWriteCopy_WriteDueNoteOffs	; F76C93  calr 0xf76c97
SmfWriteCopy_SortDueNoteOffs_Return:
	ret	; F76C96  ret

; --------------------------------------------------------------------------
; SmfWriteCopy_WriteDueNoteOffs
; Called from: 0xF76C93
; Evidence: 0xF76C97 is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfWriteCopy_WriteDueNoteOffs: copy C of prom_b's SMF writer (an unreferenced copy of A), role WriteDueNoteOffs as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWriteCopy_WriteDueNoteOffs:
	ld	bc, (4226:16)	; F76C97  ld BC,(0x1082)
	ld	xiy, 4307	; F76C9B  ld XIY,0x000010d3
	xor	hl, hl	; F76CA0  xor HL,HL
SmfWriteCopy_WriteDueNoteOffs_Join:
	ld	a, (xiy+hl)	; F76CA2  ld A,(XIY+HL)
	cp	a, 255	; F76CA7  cp A,0xff
	jr	z, SmfWriteCopy_WriteDueNoteOffs_Skip2	; F76CAA  jr Z,0xf76d12
	xor	w, w	; F76CAC  xor W,W
	ld	ix, wa	; F76CAE  ld IX,WA
	extz	xix	; F76CB0  extz XIX
	sla	ix, 2	; F76CB2  sla 0x02,IX
	add	ix, wa	; F76CB5  add IX,WA
	push	xde	; F76CB7  push XDE
	ld	xde, 12378	; F76CB8  ld XDE,0x0000305a
	add	xde, xix	; F76CBD  add XDE,XIX
	ld	wa, (xde+3)	; F76CBF  ld WA,(XDE+0x03)
	pop	xde	; F76CC2  pop XDE
	cp	l, 0:i3	; F76CC3  cp L,0
	jr	nz, SmfWriteCopy_WriteDueNoteOffs_Skip	; F76CC5  jr NZ,0xf76ccd
	ld	(4522:16), wa	; F76CC7  ld (0x11aa),WA
	jr	SmfWriteCopy_WriteDueNoteOffs_Join2	; F76CCB  jr T,0xf76cd7
SmfWriteCopy_WriteDueNoteOffs_Skip:
	ld	de, wa	; F76CCD  ld DE,WA
	sub	de, (4226:16)	; F76CCF  sub DE,(0x1082)
	ld	(4522:16), de	; F76CD3  ld (0x11aa),DE
SmfWriteCopy_WriteDueNoteOffs_Join2:
	pushw	wa	; F76CD7  push WA
	push	xhl	; F76CD8  push XHL
	pushw	bc	; F76CD9  push BC
	push	xix	; F76CDA  push XIX
	calr	SmfWriteCopy_EncodeVlq	; F76CDB  calr 0xf76d38
	pop	xix	; F76CDE  pop XIX
	popw	bc	; F76CDF  pop BC
	pop	xhl	; F76CE0  pop XHL
	popw	wa	; F76CE1  pop WA
	ld	(4226:16), wa	; F76CE2  ld (0x1082),WA
	push	xde	; F76CE6  push XDE
	ld	xde, 12378	; F76CE7  ld XDE,0x0000305a
	extz	xix	; F76CEC  extz XIX
	add	xde, xix	; F76CEE  add XDE,XIX
	ld	wa, (xde+1)	; F76CF0  ld WA,(XDE+0x01)
	pop	xde	; F76CF3  pop XDE
	push	xhl	; F76CF4  push XHL
	ld	l, 0:opc	; F76CF5  ld L,0x00
	pushw	bc	; F76CF7  push BC
	push	xix	; F76CF8  push XIX
	calr	SmfWriteCopy_WriteChannelEvent	; F76CF9  calr 0xf76a6a
	pop	xix	; F76CFC  pop XIX
	popw	bc	; F76CFD  pop BC
	pop	xhl	; F76CFE  pop XHL
	push	xde	; F76CFF  push XDE
	ld	xde, 12378	; F76D00  ld XDE,0x0000305a
	.byte 0xC3, 0x07, 0xE8, 0xF0, 0x3C, 0x3F	; F76D05  and (XDE+IX),0x3f   [llvm-mc cannot encode this]
	pop	xde	; F76D0B  pop XDE
	add	hl, 3	; F76D0C  add HL,0x0003
	jr	SmfWriteCopy_WriteDueNoteOffs_Join	; F76D10  jr T,0xf76ca2
SmfWriteCopy_WriteDueNoteOffs_Skip2:
	ld	wa, (4226:16)	; F76D12  ld WA,(0x1082)
	add	wa, (4240:16)	; F76D16  add WA,(0x1090)
	ld	(4226:16), bc	; F76D1A  ld (0x1082),BC
	add	bc, (4222:16)	; F76D1E  add BC,(0x107e)
	sub	bc, wa	; F76D22  sub BC,WA
	ld	(4522:16), bc	; F76D24  ld (0x11aa),BC
	calr	SmfWriteCopy_EncodeVlq	; F76D28  calr 0xf76d38
	ldw	(4222:16), 0	; F76D2B  ld (0x107e),0x0000
	ldw	(4224:16), 0	; F76D31  ld (0x1080),0x0000
	ret	; F76D37  ret

; --------------------------------------------------------------------------
; SmfWriteCopy_EncodeVlq
; Called from: 0xF76A66, 0xF76CDB, 0xF76D28
; Evidence: 0xF76D38 is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfWriteCopy_EncodeVlq: copy C of prom_b's SMF writer (an unreferenced copy of A), role EncodeVlq as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWriteCopy_EncodeVlq:
	ldw	(Smf_VlqBytes:16), 0	; F76D38  ld (0x1193),0x0000
	ldw	(4501:16), 0	; F76D3E  ld (0x1195),0x0000
	cp	(0x11ac:16), 0	; F76D44  cp (0x11ac),0x00
	jr	nz, sub_F76D38_Entry	; F76D49  jr NZ,0xf76d5c
	cpw	(0x11aa:16), 127	; F76D4B  cp (0x11aa),0x007f
	jrl	ule, sub_F76D38_Skip3	; F76D51  jrl ULE,0xf76ddb
	cpw	(0x11aa:16), 16383	; F76D54  cp (0x11aa),0x3fff
	jr	ule, sub_F76D38_Skip2	; F76D5A  jr ULE,0xf76db2
sub_F76D38_Entry:
	cp	(0x11ac:16), 31	; F76D5C  cp (0x11ac),0x1f
	jr	ule, sub_F76D38_Skip	; F76D61  jr ULE,0xf76d72
	ld	(4524:16), 31	; F76D63  ld (0x11ac),0x1f
	ld	(4523:16), 255	; F76D68  ld (0x11ab),0xff
	ld	(4522:16), 255	; F76D6D  ld (0x11aa),0xff
sub_F76D38_Skip:
	ld	a, (4522:16)	; F76D72  ld A,(0x11aa)
	ld	w, a	; F76D76  ld W,A
	and	w, 128	; F76D78  and W,0x80
	and	a, 127	; F76D7B  and A,0x7f
	rlc	w	; F76D7E  rlc 0x01,W
	ld	l, (4523:16)	; F76D81  ld L,(0x11ab)
	ld	h, l	; F76D85  ld H,L
	and	h, 192	; F76D87  and H,0xc0
	.byte 0xCE, 0xE8, 0x02	; F76D8A  rlc 0x02,H   [llvm-mc cannot encode this]
	sla	l, 1	; F76D8D  sla 0x01,L
	and	l, 1	; F76D90  and L,0x01
	or	l, w	; F76D93  or L,W
	or	l, 128	; F76D95  or L,0x80
	ld	c, (4524:16)	; F76D98  ld C,(0x11ac)
	sla	c, 2	; F76D9C  sla 0x02,C
	or	c, h	; F76D9F  or C,H
	or	c, 128	; F76DA1  or C,0x80
	ld	(Smf_VlqBytes:16), c	; F76DA4  ld (0x1193),C
	ld	(4500:16), l	; F76DA8  ld (0x1194),L
	ld	(4501:16), a	; F76DAC  ld (0x1195),A
	jr	sub_F76D38_Return	; F76DB0  jr T,0xf76dea
sub_F76D38_Skip2:
	ld	a, (4522:16)	; F76DB2  ld A,(0x11aa)
	ld	w, a	; F76DB6  ld W,A
	and	a, 127	; F76DB8  and A,0x7f
	and	w, 128	; F76DBB  and W,0x80
	rlc	w	; F76DBE  rlc 0x01,W
	ld	l, (4523:16)	; F76DC1  ld L,(0x11ab)
	ld	h, l	; F76DC5  ld H,L
	sla	l, 1	; F76DC7  sla 0x01,L
	or	l, w	; F76DCA  or L,W
	or	l, 128	; F76DCC  or L,0x80
	xor	c, c	; F76DCF  xor C,C
	ld	(Smf_VlqBytes:16), l	; F76DD1  ld (0x1193),L
	ld	(4500:16), a	; F76DD5  ld (0x1194),A
	jr	sub_F76D38_Return	; F76DD9  jr T,0xf76dea
sub_F76D38_Skip3:
	ld	a, (4522:16)	; F76DDB  ld A,(0x11aa)
	and	a, 127	; F76DDF  and A,0x7f
	xor	l, l	; F76DE2  xor L,L
	xor	c, c	; F76DE4  xor C,C
	ld	(Smf_VlqBytes:16), a	; F76DE6  ld (0x1193),A
sub_F76D38_Return:
	ret	; F76DEA  ret

; --------------------------------------------------------------------------
; SmfWriteCopy_ClearDueList
; Called from: 0xF76BA0
; Evidence: 0xF76DEB is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfWriteCopy_ClearDueList: copy C of prom_b's SMF writer (an unreferenced copy of A), role ClearDueList as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfWriteCopy_ClearDueList:
	push	xix	; F76DEB  push XIX
	ld	xix, 4307	; F76DEC  ld XIX,0x000010d3
	ldw	bc, 96	; F76DF1  ld BC,0x0060
	ldw	wa, 255	; F76DF4  ld WA,0x00ff
	ld	(xix+), a	; F76DF7  ld (XIX+),A
	djnz16	bc, -6	; F76DFA  djnz BC,0xf76df7
	pop	xix	; F76DFD  pop XIX
	ret	; F76DFE  ret
	ld	xix, Smf_VlqValue	; F76DFF  ld XIX,0x00001198
	xor	wa, wa	; F76E04  xor WA,WA
	ldw	bc, 4	; F76E06  ld BC,0x0004
	ld	(xix+), wa	; F76E09  ld (XIX+),WA
	djnz16	bc, -6	; F76E0C  djnz BC,0xf76e09
	ret	; F76E0F  ret
	ld	hl, (BStore_CursorBlock:16)	; F76E10  ld HL,(0x345c)
	calr	SmfExport_ParamSysExTemplates + 0xC6	; F76E14  calr 0xf75095  (lands inside record 10 at +8; see SmfExport_ParamSysExTemplates)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F76E17  ld XHL,(0x126e)
	ld	iy, (BStore_CursorOffset:16)	; F76E1B  ld IY,(0x345e)
	ld	a, (xhl+iy)	; F76E1F  ld A,(XHL+IY)
	ret	; F76E24  ret
	ld	wa, (BStore_CursorOffset:16)	; F76E25  ld WA,(0x345e)
	cp	wa, 255	; F76E29  cp WA,0x00ff
	jr	nz, SmfWriteCopy_ClearDueList_Skip	; F76E2D  jr NZ,0xf76e46
	ld	hl, (BStore_CursorBlock:16)	; F76E2F  ld HL,(0x345c)
	calr	SmfExport_ParamSysExTemplates + 0xC6	; F76E33  calr 0xf75095  (lands inside record 10 at +8; see SmfExport_ParamSysExTemplates)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F76E36  ld XHL,(0x126e)
	ld	wa, (xhl+3)	; F76E3A  ld WA,(XHL+0x03)
	ld	(BStore_CursorBlock:16), wa	; F76E3D  ld (0x345c),WA
	ldw	wa, 5	; F76E41  ld WA,0x0005
	jr	SmfWriteCopy_ClearDueList_Join	; F76E44  jr T,0xf76e48
SmfWriteCopy_ClearDueList_Skip:
	inc	1, wa	; F76E46  inc 1,WA
SmfWriteCopy_ClearDueList_Join:
	ld	(BStore_CursorOffset:16), wa	; F76E48  ld (0x345e),WA
	ret	; F76E4C  ret
	pushw	wa	; F76E4D  push WA
	pushw	bc	; F76E4E  push BC
	push	xix	; F76E4F  push XIX
	xor	wa, wa	; F76E50  xor WA,WA
	ld	xix, 12378	; F76E52  ld XIX,0x0000305a
	ldw	bc, 256	; F76E57  ld BC,0x0100
	ld	(xix+), wa	; F76E5A  ld (XIX+),WA
	djnz16	bc, -6	; F76E5D  djnz BC,0xf76e5a
	pop	xix	; F76E60  pop XIX
	popw	bc	; F76E61  pop BC
	popw	wa	; F76E62  pop WA
	ret	; F76E63  ret

; --------------------------------------------------------------------------
; GmSystemSysEx_F76E64 -- TWO 8-byte STANDARD MIDI FILE SysEx EVENTS, one
;          of which the writer copies into the output as the track's first
;          event.  `00 F0 05 7E 7F 09 01 F7` is delta 0 + a 5-byte SysEx =
;          universal non-real-time, all devices, General MIDI, GM System On;
;          the second differs in ONE byte, 0x02 = GM System Off.
; Read by: 0xF76F4A `ld XIY,0x00F76E64`, then `bit 2,(0x7f4d)` and `jr NZ`
;          past 0xF76F55 `ld XIY,0x00F76E6C`; the chosen record is written a
;          byte at a time by the loop at 0xF76F66 with `ld BC,0x0008`. Set
;          -> On, clear -> Off.
; ⚠ Why:   the linear decode frames these 16 bytes as `nop`, an unencodable
;          `db` and `ldx`. They are DATA, and the byte gate cannot tell the
;          difference -- the two `ld XIY` operands can.
; --------------------------------------------------------------------------
GmSystemSysEx_F76E64:
	.byte	0x00	; F76E64  delta time 0
	.byte	0xF0, 0x05	; F76E65  SysEx event, 5 bytes follow
	.byte	0x7E, 0x7F	; F76E67  universal NON-real-time, device 0x7F = all
	.byte	0x09, 0x01	; F76E69  sub-ID 09 = General MIDI, 0x01 = GM System On
	.byte	0xF7	; F76E6B  end of exclusive

	.byte	0x00	; F76E6C  delta time 0
	.byte	0xF0, 0x05	; F76E6D  SysEx event, 5 bytes follow
	.byte	0x7E, 0x7F	; F76E6F  universal NON-real-time, device 0x7F = all
	.byte	0x09, 0x02	; F76E71  sub-ID 09 = General MIDI, 0x02 = GM System Off
	.byte	0xF7	; F76E73  end of exclusive


; --------------------------------------------------------------------------
; SmfSizeCopy_Pass
; Called from: no call site is known.  The label marks where a
;              converted run STARTS, so that a tool walking this file
;              by label does not attribute the run to its neighbour.
; Evidence: 0xF76E74 is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfSizeCopy_Pass: copy D of prom_b's SMF writer (an unreferenced copy of B), the whole sizing pass over the song (its main; see the module note) -- notes/prom_b_smf_writer_names.py
SmfSizeCopy_Pass:
	xor	hl, hl	; F76E74  xor HL,HL
	xor	bc, bc	; F76E76  xor BC,BC
SmfSizeCopy_Pass_Join:
	push	xde	; F76E78  push XDE
	ld	xde, 6305024	; F76E79  ld XDE,0x00603500
	.byte 0xF3, 0x07, 0xE8, 0xEC, 0xCF	; F76E7E  bit 7,(XDE+HL)   [llvm-mc cannot encode this]
	pop	xde	; F76E83  pop XDE
	jr	nz, SmfSizeCopy_Pass_Skip	; F76E84  jr NZ,0xf76e94
	add	hl, 3	; F76E86  add HL,0x0003
	inc	1, c	; F76E8A  inc 1,C
	cp	c, 16	; F76E8C  cp C,0x10
	jrl	ugt, sub_F76E74_Return	; F76E8F  jrl UGT,0xf77814
	jr	SmfSizeCopy_Pass_Join	; F76E92  jr T,0xf76e78
SmfSizeCopy_Pass_Skip:
	ld	(3184:16), c	; F76E94  ld (0x0c70),C
	inc	1, hl	; F76E98  inc 1,HL
	push	xde	; F76E9A  push XDE
	ld	xde, 6305024	; F76E9B  ld XDE,0x00603500
	ld	hl, (xde+hl)	; F76EA0  ld HL,(XDE+HL)
	pop	xde	; F76EA5  pop XDE
	ld	(BStore_CursorBlock:16), hl	; F76EA6  ld (0x345c),HL
	ldw	(BStore_CursorOffset:16), 5	; F76EAA  ld (0x345e),0x0005
	ld	(4529:16), 0	; F76EB0  ld (0x11b1),0x00
	ld	xiy, SmfFileTemplate_F77836	; F76EB5  ld XIY,0x00f77836
	ld	xix, 6334208	; F76EBA  ld XIX,0x0060a700
	ldw	bc, 7	; F76EBF  ld BC,0x0007
	ldirw	; F76EC2  ldirw
	ld	xiy, SmfFileTemplate_F77836 + 0xE	; F76EC4  ld XIY,0x00f77844
	ldw	bc, 4	; F76EC9  ld BC,0x0004
	ldirw	; F76ECC  ldirw
	ld	(InputStream_Cursor:16), xix	; F76ECE  ld (0x1088),XIX
	ld	xix, (InputStream_Cursor:16)	; F76ED2  ld XIX,(0x1088)
	ld	xiy, SmfFileTemplate_F77836 + 0x16	; F76ED6  ld XIY,0x00f7784c
	ldw	bc, 11	; F76EDB  ld BC,0x000b
	.byte 0x85, 0x11	; F76EDE  ldir   [llvm-mc cannot encode this]
	ld	xiy, Disk_FileName	; F76EE0  ld XIY,0x000021c8
	ldw	bc, 8	; F76EE5  ld BC,0x0008
	.byte 0x85, 0x11	; F76EE8  ldir   [llvm-mc cannot encode this]
	ld	(InputStream_Cursor:16), xix	; F76EEA  ld (0x1088),XIX
	ldw	(Smf_VlqBytes:16), 0	; F76EEE  ld (0x1193),0x0000
	ld	(4501:16), 0	; F76EF4  ld (0x1195),0x00
	ld	xiy, Smf_VlqBytes	; F76EF9  ld XIY,0x00001193
	ld	xix, (InputStream_Cursor:16)	; F76EFE  ld XIX,(0x1088)
SmfSizeCopy_Pass_Loop:
	ld	a, (xiy+)	; F76F02  ld A,(XIY+)
	ld	(xix+), a	; F76F05  ld (XIX+),A
	bit	7, a	; F76F08  bit 0x07,A
	jr	nz, SmfSizeCopy_Pass_Loop	; F76F0B  jr NZ,0xf76f02
	ldw	wa, 22783	; F76F0D  ld WA,0x58ff
	ld	(xix+), wa	; F76F10  ld (XIX+),WA
	ld	a, 4:opc	; F76F13  ld A,0x04
	ld	w, (6304983:24)	; F76F15  ld W,(0x6034d7)
	ld	(xix+), wa	; F76F1A  ld (XIX+),WA
	ldw	wa, 6146	; F76F1D  ld WA,0x1802
	ld	(xix+), wa	; F76F20  ld (XIX+),WA
	ld	a, 8:opc	; F76F23  ld A,0x08
	ld	(xix+), a	; F76F25  ld (XIX+),A
	ld	(InputStream_Cursor:16), xix	; F76F28  ld (0x1088),XIX
	ld	l, (32482:16)	; F76F2C  ld L,(0x7ee2)
	xor	h, h	; F76F30  xor H,H
	pushw	bc	; F76F32  push BC
	ld	b, (32483:16)	; F76F33  ld B,(0x7ee3)
	and	b, 1	; F76F37  and B,0x01
	xor	c, c	; F76F3A  xor C,C
	or	hl, bc	; F76F3C  or HL,BC
	popw	bc	; F76F3E  pop BC
	calr	SmfSizeCopy_StageTempo	; F76F3F  calr 0xf778d2
	calr	SmfSizeCopy_WriteTempoEvent	; F76F42  calr 0xf77918
	ld	(4665:16), 255	; F76F45  ld (0x1239),0xff
	ld	xiy, GmSystemSysEx_F76E64	; F76F4A  ld XIY,0x00f76e64
	bit	2, (0x7f4d:16)	; F76F4F  bit 2,(0x7f4d)
	jr	nz, SmfSizeCopy_Pass_Skip2	; F76F53  jr NZ,0xf76f5f
	ld	xiy, GmSystemSysEx_F76E64 + 0x8	; F76F55  ld XIY,0x00f76e6c
	ld	(4665:16), 0	; F76F5A  ld (0x1239),0x00
SmfSizeCopy_Pass_Skip2:
	ld	xix, (InputStream_Cursor:16)	; F76F5F  ld XIX,(0x1088)
	ldw	bc, 8	; F76F63  ld BC,0x0008
	ld	a, (xiy+)	; F76F66  ld A,(XIY+)
	ld	(xix+), a	; F76F69  ld (XIX+),A
	pushw	bc	; F76F6C  push BC
	push	xiy	; F76F6D  push XIY
	push	xix	; F76F6E  push XIX
	calr	SmfSizeCopy_CommitOutputByte	; F76F6F  calr 0xf77a28
	pop	xix	; F76F72  pop XIX
	pop	xiy	; F76F73  pop XIY
	popw	bc	; F76F74  pop BC
	ld	xix, (InputStream_Cursor:16)	; F76F75  ld XIX,(0x1088)
	djnz16	bc, -22	; F76F79  djnz BC,0xf76f66
	ld	(InputStream_Cursor:16), xix	; F76F7C  ld (0x1088),XIX
	bit	0, (0x133e:16)	; F76F80  bit 0,(0x133e)
	jrl	z, SmfSizeCopy_Pass_Join4	; F76F84  jrl Z,0xf77245
	ld	xiy, 6305440	; F76F87  ld XIY,0x006036a0
	ld	(3184:16), 0	; F76F8C  ld (0x0c70),0x00
SmfSizeCopy_Pass_Loop2:
	xor	xhl, xhl	; F76F91  xor XHL,XHL
	ld	l, (3184:16)	; F76F93  ld L,(0x0c70)
	ld	c, l	; F76F97  ld C,L
	ld	de, (4678:16)	; F76F99  ld DE,(0x1246)
	ld	a, c	; F76F9D  ld A,C
	scf	; F76F9F  scf
	.byte 0xDA, 0x2A	; F76FA0  xorcf A,DE   [llvm-mc cannot encode this]
	jrl	c, SmfSizeCopy_Pass_Skip4	; F76FA2  jrl C,0xf77239
	push	xix	; F76FA5  push XIX
	ld	xix, BStore_TrackToPart	; F76FA6  ld XIX,0x00603422
	ld	l, (xix+hl)	; F76FAB  ld L,(XIX+HL)
	pop	xix	; F76FB0  pop XIX
	ld	b, l	; F76FB1  ld B,L
	sla	l, 1	; F76FB3  sla 0x01,L
	xor	h, h	; F76FB6  xor H,H
	push	xde	; F76FB8  push XDE
	ld	xde, SmfPartOffsets_F77857	; F76FB9  ld XDE,0x00f77857
	ld	hl, (xde+hl)	; F76FBE  ld HL,(XDE+HL)
	pop	xde	; F76FC3  pop XDE
	cp	hl, 65535	; F76FC4  cp HL,0xffff
	jrl	z, SmfSizeCopy_Pass_Skip4	; F76FC8  jrl Z,0xf77239
	cp	c, 0:i3	; F76FCB  cp C,0
	jr	z, SmfSizeCopy_Pass_Join2	; F76FCD  jr Z,0xf76fdd
	push	xhl	; F76FCF  push XHL
	xor	hl, hl	; F76FD0  xor HL,HL
SmfSizeCopy_Pass_Loop3:
	pop	xhl	; F76FD2  pop XHL
	jr	SmfSizeCopy_Pass_Join2	; F76FD3  jr T,0xf76fdd
	cp	l, c	; F76FD5  cp L,C
	jr	z, SmfSizeCopy_Pass_Loop3	; F76FD7  jr Z,0xf76fd2
	pop	xhl	; F76FD9  pop XHL
	jrl	SmfSizeCopy_Pass_Join4	; F76FDA  jrl T,0xf77245
SmfSizeCopy_Pass_Join2:
	lda	xiy, (xiy+hl)	; F76FDD  lda XIY,XIY+HL
	ld	c, (xiy+2)	; F76FE2  ld C,(XIY+0x02)
	ld	d, (xiy+3)	; F76FE5  ld D,(XIY+0x03)
	ld	b, (xiy+5)	; F76FE8  ld B,(XIY+0x05)
	ld	e, (xiy+6)	; F76FEB  ld E,(XIY+0x06)
	ld	a, (xiy+7)	; F76FEE  ld A,(XIY+0x07)
	ld	(4763:16), a	; F76FF1  ld (0x129b),A
	ld	a, (xiy+8)	; F76FF5  ld A,(XIY+0x08)
	ld	(4944:16), a	; F76FF8  ld (0x1350),A
	ld	a, (xiy+9)	; F76FFC  ld A,(XIY+0x09)
	ld	(4686:16), a	; F76FFF  ld (0x124e),A
	and	(0xc70:16), 15	; F77003  and (0x0c70),0x0f
	cp	(0x1239:16), 255	; F77008  cp (0x1239),0xff
	jr	nz, SmfSizeCopy_Pass_Skip3	; F7700D  jr NZ,0xf77070
	ld	a, (3184:16)	; F7700F  ld A,(0x0c70)
	ld	l, c	; F77013  ld L,C
	ld	(SoundConv_Arg0:24), l	; F77015  ld (0x60f010),L
	ld	h, d	; F7701A  ld H,D
	ld	(SoundConv_Arg1:24), h	; F7701C  ld (0x60f011),H
	ld	l, (xiy)	; F77021  ld L,(XIY)
	ld	(SoundConv_Arg2:24), l	; F77023  ld (0x60f012),L
	pushw	bc	; F77028  push BC
	pushw	de	; F77029  push DE
	call	T_PartSound_ToProgramChange	; F7702A  call 0xf41008
	popw	de	; F7702E  pop DE
	popw	bc	; F7702F  pop BC
	ld	a, (3184:16)	; F77030  ld A,(0x0c70)
	or	a, 176	; F77034  or A,0xb0
	xor	w, w	; F77037  xor W,W
	ld	l, (SoundConv_Result1:24)	; F77039  ld L,(0x60f015)
	pushw	wa	; F7703E  push WA
	pushw	bc	; F7703F  push BC
	pushw	de	; F77040  push DE
	call	SmfSizeCopy_WriteChannelEvent	; F77041  call 0xf779d5
	popw	de	; F77045  pop DE
	popw	bc	; F77046  pop BC
	popw	wa	; F77047  pop WA
	ld	w, 32:opc	; F77048  ld W,0x20
	ld	l, (SoundConv_Result0:24)	; F7704A  ld L,(0x60f014)
	pushw	bc	; F7704F  push BC
	pushw	de	; F77050  push DE
	call	SmfSizeCopy_WriteChannelEvent	; F77051  call 0xf779d5
	popw	de	; F77055  pop DE
	popw	bc	; F77056  pop BC
	ld	a, (3184:16)	; F77057  ld A,(0x0c70)
	or	a, 192	; F7705B  or A,0xc0
	ld	w, (SoundConv_Result2:24)	; F7705E  ld W,(0x60f016)
	and	w, 127	; F77063  and W,0x7f
	pushw	bc	; F77066  push BC
	pushw	de	; F77067  push DE
	calr	SmfSizeCopy_WriteChannelEvent	; F77068  calr 0xf779d5
	popw	de	; F7706B  pop DE
	popw	bc	; F7706C  pop BC
	jrl	SmfSizeCopy_Pass_Join3	; F7706D  jrl T,0xf770b3
SmfSizeCopy_Pass_Skip3:
	ld	a, (3184:16)	; F77070  ld A,(0x0c70)
	or	a, 176	; F77074  or A,0xb0
	ld	w, 0:opc	; F77077  ld W,0x00
	ld	l, d	; F77079  ld L,D
	and	l, 56	; F7707B  and L,0x38
	srl	l, 3	; F7707E  srl 0x03,L
	pushw	bc	; F77081  push BC
	pushw	de	; F77082  push DE
	calr	SmfSizeCopy_WriteChannelEvent	; F77083  calr 0xf779d5
	popw	de	; F77086  pop DE
	popw	bc	; F77087  pop BC
	ld	a, (3184:16)	; F77088  ld A,(0x0c70)
	or	a, 176	; F7708C  or A,0xb0
	ld	w, 32:opc	; F7708F  ld W,0x20
	ld	l, d	; F77091  ld L,D
	and	l, 7	; F77093  and L,0x07
	sla	l, 4	; F77096  sla 0x04,L
	pushw	bc	; F77099  push BC
	pushw	de	; F7709A  push DE
	calr	SmfSizeCopy_WriteChannelEvent	; F7709B  calr 0xf779d5
	popw	de	; F7709E  pop DE
	popw	bc	; F7709F  pop BC
	ld	a, (3184:16)	; F770A0  ld A,(0x0c70)
	or	a, 192	; F770A4  or A,0xc0
	ld	w, c	; F770A7  ld W,C
	and	w, 127	; F770A9  and W,0x7f
	pushw	bc	; F770AC  push BC
	pushw	de	; F770AD  push DE
	calr	SmfSizeCopy_WriteChannelEvent	; F770AE  calr 0xf779d5
	popw	de	; F770B1  pop DE
	popw	bc	; F770B2  pop BC
SmfSizeCopy_Pass_Join3:
	ld	a, (3184:16)	; F770B3  ld A,(0x0c70)
	or	a, 176	; F770B7  or A,0xb0
	ld	w, 7:opc	; F770BA  ld W,0x07
	ld	l, b	; F770BC  ld L,B
	pushw	wa	; F770BE  push WA
	pushw	de	; F770BF  push DE
	calr	SmfSizeCopy_WriteChannelEvent	; F770C0  calr 0xf779d5
	popw	de	; F770C3  pop DE
	popw	wa	; F770C4  pop WA
	ld	w, 93:opc	; F770C5  ld W,0x5d
	ld	l, (4763:16)	; F770C7  ld L,(0x129b)
	pushw	wa	; F770CB  push WA
	pushw	de	; F770CC  push DE
	calr	SmfSizeCopy_WriteChannelEvent	; F770CD  calr 0xf779d5
	popw	de	; F770D0  pop DE
	popw	wa	; F770D1  pop WA
	ld	w, 94:opc	; F770D2  ld W,0x5e
	ld	l, (4944:16)	; F770D4  ld L,(0x1350)
	pushw	wa	; F770D8  push WA
	pushw	de	; F770D9  push DE
	calr	SmfSizeCopy_WriteChannelEvent	; F770DA  calr 0xf779d5
	popw	de	; F770DD  pop DE
	popw	wa	; F770DE  pop WA
	ld	w, 91:opc	; F770DF  ld W,0x5b
	ld	l, (4686:16)	; F770E1  ld L,(0x124e)
	pushw	wa	; F770E5  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F770E6  calr 0xf779d5
	popw	wa	; F770E9  pop WA
	ld	l, (3184:16)	; F770EA  ld L,(0x0c70)
	xor	h, h	; F770EE  xor H,H
	push	xix	; F770F0  push XIX
	ld	xix, BStore_TrackToPart	; F770F1  ld XIX,0x00603422
	ld	l, (xix+hl)	; F770F6  ld L,(XIX+HL)
	pop	xix	; F770FB  pop XIX
	ld	b, l	; F770FC  ld B,L
	xor	h, h	; F770FE  xor H,H
	sla	l, 1	; F77100  sla 0x01,L
	push	xde	; F77103  push XDE
	ld	xde, SmfPartOffsets_F77857	; F77104  ld XDE,0x00f77857
	ld	hl, (xde+hl)	; F77109  ld HL,(XDE+HL)
	pop	xde	; F7710E  pop XDE
	cp	hl, 65535	; F7710F  cp HL,0xffff
	jrl	z, SmfSizeCopy_Pass_Skip4	; F77113  jrl Z,0xf77239
	ld	a, (3184:16)	; F77116  ld A,(0x0c70)
	or	a, 176	; F7711A  or A,0xb0
	ld	c, l	; F7711D  ld C,L
	ld	xiy, 6305440	; F7711F  ld XIY,0x006036a0
	ldfr_lerp	xiy, 56	; F77124  ld XDE3,XIY
	lda	xiy, (xiy+hl)	; F77127  lda XIY,XIY+HL
	ld	l, (xiy+10)	; F7712C  ld L,(XIY+0x0a)
	ldto_lerp	xiy, 56	; F7712F  ld XIY,XDE3
	ld	w, 10:opc	; F77132  ld W,0x0a
	pushw	wa	; F77134  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F77135  calr 0xf779d5
	popw	wa	; F77138  pop WA
	ld	w, 101:opc	; F77139  ld W,0x65
	ld	l, 0:opc	; F7713B  ld L,0x00
	pushw	wa	; F7713D  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F7713E  calr 0xf779d5
	popw	wa	; F77141  pop WA
	ld	w, 100:opc	; F77142  ld W,0x64
	ld	l, 1:opc	; F77144  ld L,0x01
	pushw	wa	; F77146  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F77147  calr 0xf779d5
	popw	wa	; F7714A  pop WA
	ld	l, (3184:16)	; F7714B  ld L,(0x0c70)
	xor	h, h	; F7714F  xor H,H
	push	xix	; F77151  push XIX
	ld	xix, BStore_TrackToPart	; F77152  ld XIX,0x00603422
	ld	l, (xix+hl)	; F77157  ld L,(XIX+HL)
	sla	hl, 1	; F7715C  sla 0x01,HL
	ld	xix, SmfPartOffsets_F77857	; F7715F  ld XIX,0x00f77857
	ld	hl, (xix+hl)	; F77164  ld HL,(XIX+HL)
	pop	xix	; F77169  pop XIX
	ld	xiy, 6305440	; F7716A  ld XIY,0x006036a0
	lda	xiy, (xiy+hl)	; F7716F  lda XIY,XIY+HL
	ld	l, (xiy+12)	; F77174  ld L,(XIY+0x0c)
	ld	c, l	; F77177  ld C,L
	srl	l, 1	; F77179  srl 0x01,L
	and	l, 127	; F7717C  and L,0x7f
	ld	w, 6:opc	; F7717F  ld W,0x06
	pushw	wa	; F77181  push WA
	pushw	bc	; F77182  push BC
	calr	SmfSizeCopy_WriteChannelEvent	; F77183  calr 0xf779d5
	popw	bc	; F77186  pop BC
	popw	wa	; F77187  pop WA
	ld	l, c	; F77188  ld L,C
	rrc	l	; F7718A  rrc 0x01,L
	and	l, 127	; F7718D  and L,0x7f
	ld	w, 38:opc	; F77190  ld W,0x26
	pushw	wa	; F77192  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F77193  calr 0xf779d5
	popw	wa	; F77196  pop WA
	ld	w, 101:opc	; F77197  ld W,0x65
	ld	l, 0:opc	; F77199  ld L,0x00
	pushw	wa	; F7719B  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F7719C  calr 0xf779d5
	popw	wa	; F7719F  pop WA
	ld	w, 100:opc	; F771A0  ld W,0x64
	ld	l, 2:opc	; F771A2  ld L,0x02
	pushw	wa	; F771A4  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F771A5  calr 0xf779d5
	popw	wa	; F771A8  pop WA
	ld	l, (3184:16)	; F771A9  ld L,(0x0c70)
	xor	h, h	; F771AD  xor H,H
	push	xix	; F771AF  push XIX
	ld	xix, BStore_TrackToPart	; F771B0  ld XIX,0x00603422
	ld	l, (xix+hl)	; F771B5  ld L,(XIX+HL)
	sla	hl, 1	; F771BA  sla 0x01,HL
	ld	xix, SmfPartOffsets_F77857	; F771BD  ld XIX,0x00f77857
	ld	hl, (xix+hl)	; F771C2  ld HL,(XIX+HL)
	pop	xix	; F771C7  pop XIX
	ld	xiy, 6305440	; F771C8  ld XIY,0x006036a0
	ldfr_lerp	xiy, 56	; F771CD  ld XDE3,XIY
	lda	xiy, (xiy+hl)	; F771D0  lda XIY,XIY+HL
	ld	l, (xiy+11)	; F771D5  ld L,(XIY+0x0b)
	ldto_lerp	xiy, 56	; F771D8  ld XIY,XDE3
	ld	w, 6:opc	; F771DB  ld W,0x06
	pushw	wa	; F771DD  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F771DE  calr 0xf779d5
	popw	wa	; F771E1  pop WA
	ld	w, 38:opc	; F771E2  ld W,0x26
	xor	l, l	; F771E4  xor L,L
	pushw	wa	; F771E6  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F771E7  calr 0xf779d5
	popw	wa	; F771EA  pop WA
	ld	w, 101:opc	; F771EB  ld W,0x65
	ld	l, 0:opc	; F771ED  ld L,0x00
	pushw	wa	; F771EF  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F771F0  calr 0xf779d5
	popw	wa	; F771F3  pop WA
	ld	w, 100:opc	; F771F4  ld W,0x64
	ld	l, 0:opc	; F771F6  ld L,0x00
	pushw	wa	; F771F8  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F771F9  calr 0xf779d5
	popw	wa	; F771FC  pop WA
	ld	l, (3184:16)	; F771FD  ld L,(0x0c70)
	xor	h, h	; F77201  xor H,H
	push	xix	; F77203  push XIX
	ld	xix, BStore_TrackToPart	; F77204  ld XIX,0x00603422
	ld	l, (xix+hl)	; F77209  ld L,(XIX+HL)
	sla	hl, 1	; F7720E  sla 0x01,HL
	ld	xix, SmfPartOffsets_F77857	; F77211  ld XIX,0x00f77857
	ld	hl, (xix+hl)	; F77216  ld HL,(XIX+HL)
	pop	xix	; F7721B  pop XIX
	ld	xiy, 6305440	; F7721C  ld XIY,0x006036a0
	lda	xiy, (xiy+hl)	; F77221  lda XIY,XIY+HL
	ld	l, (xiy+13)	; F77226  ld L,(XIY+0x0d)
	ld	w, 6:opc	; F77229  ld W,0x06
	pushw	wa	; F7722B  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F7722C  calr 0xf779d5
	popw	wa	; F7722F  pop WA
	ld	w, 6:opc	; F77230  ld W,0x06
	xor	l, l	; F77232  xor L,L
	pushw	wa	; F77234  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F77235  calr 0xf779d5
	popw	wa	; F77238  pop WA
SmfSizeCopy_Pass_Skip4:
	inc	1, (3184:16)	; F77239  inc 1,(0x0c70)
	cp	(0xc70:16), 15	; F7723D  cp (0x0c70),0x0f
	jrl	ule, SmfSizeCopy_Pass_Loop2	; F77242  jrl ULE,0xf76f91
SmfSizeCopy_Pass_Join4:
	calr	sub_F76E74_Nop	; F77245  calr 0xf77899
	xor	wa, wa	; F77248  xor WA,WA
	ld	(4226:16), wa	; F7724A  ld (0x1082),WA
	ld	(4228:16), wa	; F7724E  ld (0x1084),WA
	calr	SmfSizeCopy_ReadSongByte	; F77252  calr 0xf77cb7
	cp	a, 130	; F77255  cp A,0x82
	jr	z, SmfSizeCopy_Pass_Skip5	; F77258  jr Z,0xf77279
	cp	a, 129	; F7725A  cp A,0x81
	jr	z, SmfSizeCopy_Pass_Skip5	; F7725D  jr Z,0xf77279
	pushw	(BStore_CursorBlock:16)	; F7725F  pushw (0x345c)
	pushw	(BStore_CursorOffset:16)	; F77263  pushw (0x345e)
	calr	SmfSizeCopy_AdvanceSongCursor	; F77267  calr 0xf77ccc
	calr	SmfSizeCopy_ReadSongByte	; F7726A  calr 0xf77cb7
	popw	(BStore_CursorOffset:16)	; F7726D  popw (0x345e)
	popw	(BStore_CursorBlock:16)	; F77271  popw (0x345c)
	ld	(4228:16), a	; F77275  ld (0x1084),A
SmfSizeCopy_Pass_Skip5:
	ldw	(4230:16), 0	; F77279  ld (0x1086),0x0000
	ldw	(4222:16), 0	; F7727F  ld (0x107e),0x0000
	ldw	(4224:16), 0	; F77285  ld (0x1080),0x0000
SmfSizeCopy_Pass_Loop4:
	xor	hl, hl	; F7728B  xor HL,HL
	push	xhl	; F7728D  push XHL
	calr	SmfSizeCopy_ClearEventFields	; F7728E  calr 0xf77ca6
	calr	SmfSizeCopy_ReadSongByte	; F77291  calr 0xf77cb7
	pop	xhl	; F77294  pop XHL
	cp	a, 130	; F77295  cp A,0x82
	jrl	z, sub_F76E74_Skip32	; F77298  jrl Z,0xf77800
SmfSizeCopy_Pass_Loop5:
	push	xde	; F7729B  push XDE
	ld	xde, Smf_VlqValue	; F7729C  ld XDE,0x00001198
	ld	(xde+hl), a	; F772A1  ld (XDE+HL),A
	pop	xde	; F772A6  pop XDE
	pushw	hl	; F772A7  push HL
	calr	SmfSizeCopy_AdvanceSongCursor	; F772A8  calr 0xf77ccc
	calr	SmfSizeCopy_ReadSongByte	; F772AB  calr 0xf77cb7
	popw	hl	; F772AE  pop HL
	inc	1, hl	; F772AF  inc 1,HL
	bit	7, a	; F772B1  bit 0x07,A
	jr	z, SmfSizeCopy_Pass_Loop5	; F772B4  jr Z,0xf7729b
	ld	a, (Smf_VlqValue:16)	; F772B6  ld A,(0x1198)
	cp	a, 130	; F772BA  cp A,0x82
	jrl	z, sub_F76E74_Skip32	; F772BD  jrl Z,0xf77800
	cp	a, 129	; F772C0  cp A,0x81
	jrl	z, SmfSizeCopy_Pass_Skip6	; F772C3  jrl Z,0xf772f8
	ld	w, a	; F772C6  ld W,A
	and	w, 240	; F772C8  and W,0xf0
	cp	w, 144	; F772CB  cp W,0x90
	jrl	z, SmfSizeCopy_Pass_Skip13	; F772CE  jrl Z,0xf773f6
	cp	w, 176	; F772D1  cp W,0xb0
	jrl	z, sub_F76E74_Skip17	; F772D4  jrl Z,0xf7757b
	cp	w, 192	; F772D7  cp W,0xc0
	jrl	z, sub_F76E74_Skip14	; F772DA  jrl Z,0xf7746b
	cp	w, 208	; F772DD  cp W,0xd0
	jrl	z, SmfSizeCopy_Pass_Skip10	; F772E0  jrl Z,0xf7738a
	cp	w, 240	; F772E3  cp W,0xf0
	jrl	z, SmfSizeCopy_Pass_Skip12	; F772E6  jrl Z,0xf773cc
	cp	w, 160	; F772E9  cp W,0xa0
	jrl	z, SmfSizeCopy_Pass_Skip8	; F772EC  jrl Z,0xf7732c
	cp	w, 224	; F772EF  cp W,0xe0
	jrl	z, SmfSizeCopy_Pass_Skip11	; F772F2  jrl Z,0xf773ad
	jrl	SmfSizeCopy_Pass_Loop4	; F772F5  jrl T,0xf7728b
SmfSizeCopy_Pass_Skip6:
	incw	1, (4230:16)	; F772F8  incw 1,(0x1086)
SmfSizeCopy_Pass_Join5:
	calr	SmfSizeCopy_ReadSongByte	; F772FC  calr 0xf77cb7
	cp	a, 129	; F772FF  cp A,0x81
	jr	nz, SmfSizeCopy_Pass_Skip7	; F77302  jr NZ,0xf7730d
	incw	1, (4230:16)	; F77304  incw 1,(0x1086)
	calr	SmfSizeCopy_AdvanceSongCursor	; F77308  calr 0xf77ccc
	jr	SmfSizeCopy_Pass_Join5	; F7730B  jr T,0xf772fc
SmfSizeCopy_Pass_Skip7:
	ld	wa, (4230:16)	; F7730D  ld WA,(0x1086)
	ldw	de, 96	; F77311  ld DE,0x0060
	extz	xwa	; F77314  extz XWA
	muls	xwa, de	; F77316  muls XWA,DE
	ld	de, qwa	; F77318  ld DE,QWA
	add	(4222:16), wa	; F7731B  add (0x107e),WA
	ld	(4224:16), de	; F7731F  ld (0x1080),DE
	ldw	(4230:16), 0	; F77323  ld (0x1086),0x0000
	jrl	SmfSizeCopy_Pass_Loop4	; F77329  jrl T,0xf7728b
SmfSizeCopy_Pass_Skip8:
	cp	hl, 3:i3	; F7732C  cp HL,3
	jr	z, SmfSizeCopy_Pass_Skip9	; F7732E  jr Z,0xf7736c
	cp	hl, 4:i3	; F77330  cp HL,4
	jrl	nz, SmfSizeCopy_Pass_Loop4	; F77332  jrl NZ,0xf7728b
	ld	c, (4505:16)	; F77335  ld C,(0x1199)
	calr	SmfSizeCopy_EncodeDeltaTime	; F77339  calr 0xf77990
	calr	SmfSizeCopy_AgePendingNoteOffs	; F7733C  calr 0xf77a4a
	ld	hl, (4506:16)	; F7733F  ld HL,(0x119a)
	and	l, 127	; F77343  and L,0x7f
	and	h, 1	; F77346  and H,0x01
	rrc	h	; F77349  rrc 0x01,H
	and	h, 128	; F7734C  and H,0x80
	or	l, h	; F7734F  or L,H
	xor	h, h	; F77351  xor H,H
	pushw	wa	; F77353  push WA
	ld	w, (4507:16)	; F77354  ld W,(0x119b)
	and	w, 2	; F77358  and W,0x02
	srl	w, 1	; F7735B  srl 0x01,W
	xor	a, a	; F7735E  xor A,A
	or	hl, wa	; F77360  or HL,WA
	popw	wa	; F77362  pop WA
	calr	SmfSizeCopy_StageTempo	; F77363  calr 0xf778d2
	calr	SmfSizeCopy_WriteTempoEvent	; F77366  calr 0xf77918
	jrl	SmfSizeCopy_Pass_Loop4	; F77369  jrl T,0xf7728b
SmfSizeCopy_Pass_Skip9:
	ld	c, (4505:16)	; F7736C  ld C,(0x1199)
	pushw	wa	; F77370  push WA
	calr	SmfSizeCopy_EncodeDeltaTime	; F77371  calr 0xf77990
	calr	SmfSizeCopy_AgePendingNoteOffs	; F77374  calr 0xf77a4a
	popw	wa	; F77377  pop WA
	and	a, 15	; F77378  and A,0x0f
	or	a, 208	; F7737B  or A,0xd0
	ld	w, (4506:16)	; F7737E  ld W,(0x119a)
	xor	l, l	; F77382  xor L,L
	calr	SmfSizeCopy_WriteChannelEvent	; F77384  calr 0xf779d5
	jrl	SmfSizeCopy_Pass_Loop4	; F77387  jrl T,0xf7728b
SmfSizeCopy_Pass_Skip10:
	cp	hl, 3:i3	; F7738A  cp HL,3
	jrl	nz, SmfSizeCopy_Pass_Loop4	; F7738C  jrl NZ,0xf7728b
	ld	c, (4505:16)	; F7738F  ld C,(0x1199)
	pushw	wa	; F77393  push WA
	calr	SmfSizeCopy_EncodeDeltaTime	; F77394  calr 0xf77990
	calr	SmfSizeCopy_AgePendingNoteOffs	; F77397  calr 0xf77a4a
	popw	wa	; F7739A  pop WA
	and	a, 15	; F7739B  and A,0x0f
	or	a, 176	; F7739E  or A,0xb0
	ld	w, 1:opc	; F773A1  ld W,0x01
	ld	l, (4506:16)	; F773A3  ld L,(0x119a)
	calr	SmfSizeCopy_WriteChannelEvent	; F773A7  calr 0xf779d5
	jrl	SmfSizeCopy_Pass_Loop4	; F773AA  jrl T,0xf7728b
SmfSizeCopy_Pass_Skip11:
	cp	hl, 4:i3	; F773AD  cp HL,4
	jrl	nz, SmfSizeCopy_Pass_Loop4	; F773AF  jrl NZ,0xf7728b
	ld	c, (4505:16)	; F773B2  ld C,(0x1199)
	pushw	wa	; F773B6  push WA
	calr	SmfSizeCopy_EncodeDeltaTime	; F773B7  calr 0xf77990
	calr	SmfSizeCopy_AgePendingNoteOffs	; F773BA  calr 0xf77a4a
	popw	wa	; F773BD  pop WA
	ld	w, (4506:16)	; F773BE  ld W,(0x119a)
	ld	l, (4507:16)	; F773C2  ld L,(0x119b)
	calr	SmfSizeCopy_WriteChannelEvent	; F773C6  calr 0xf779d5
	jrl	SmfSizeCopy_Pass_Loop4	; F773C9  jrl T,0xf7728b
SmfSizeCopy_Pass_Skip12:
	cp	hl, 3:i3	; F773CC  cp HL,3
	jrl	nz, SmfSizeCopy_Pass_Loop4	; F773CE  jrl NZ,0xf7728b
	ld	l, a	; F773D1  ld L,A
	and	l, 15	; F773D3  and L,0x0f
	xor	h, h	; F773D6  xor H,H
	ld	c, (4505:16)	; F773D8  ld C,(0x1199)
	pushw	wa	; F773DC  push WA
	calr	SmfSizeCopy_EncodeDeltaTime	; F773DD  calr 0xf77990
	calr	SmfSizeCopy_AgePendingNoteOffs	; F773E0  calr 0xf77a4a
	popw	wa	; F773E3  pop WA
	and	a, 15	; F773E4  and A,0x0f
	or	a, 176	; F773E7  or A,0xb0
	ld	w, 11:opc	; F773EA  ld W,0x0b
	ld	l, (4506:16)	; F773EC  ld L,(0x119a)
	calr	SmfSizeCopy_WriteChannelEvent	; F773F0  calr 0xf779d5
	jrl	SmfSizeCopy_Pass_Loop4	; F773F3  jrl T,0xf7728b
SmfSizeCopy_Pass_Skip13:
	cp	hl, 6:i3	; F773F6  cp HL,6
	jrl	nz, SmfSizeCopy_Pass_Loop4	; F773F8  jrl NZ,0xf7728b
	xor	hl, hl	; F773FB  xor HL,HL
SmfSizeCopy_Pass_Loop6:
	push	xde	; F773FD  push XDE
	ld	xde, 12378	; F773FE  ld XDE,0x0000305a
	.byte 0xF3, 0x07, 0xE8, 0xEC, 0xCF	; F77403  bit 7,(XDE+HL)   [llvm-mc cannot encode this]
	pop	xde	; F77408  pop XDE
	jr	z, sub_F76E74_Entry	; F77409  jr Z,0xf77418
	add	hl, 5	; F7740B  add HL,0x0005
	cp	hl, 160	; F7740F  cp HL,0x00a0
	jr	ule, SmfSizeCopy_Pass_Loop6	; F77413  jr ULE,0xf773fd
	jrl	SmfSizeCopy_Pass_Loop4	; F77415  jrl T,0xf7728b
sub_F76E74_Entry:
	or	(0x11b1:16), 1	; F77418  or (0x11b1),0x01
	pushw	hl	; F7741D  push HL
	ld	c, (4505:16)	; F7741E  ld C,(0x1199)
	calr	SmfSizeCopy_EncodeDeltaTime	; F77422  calr 0xf77990
	calr	SmfSizeCopy_AgePendingNoteOffs	; F77425  calr 0xf77a4a
	ld	a, (Smf_VlqValue:16)	; F77428  ld A,(0x1198)
	ld	w, (4506:16)	; F7742C  ld W,(0x119a)
	ld	l, (4507:16)	; F77430  ld L,(0x119b)
	calr	SmfSizeCopy_WriteChannelEvent	; F77434  calr 0xf779d5
	popw	hl	; F77437  pop HL
	ld	xix, 12378	; F77438  ld XIX,0x0000305a
	lda	xix, (xix+hl)	; F7743D  lda XIX,XIX+HL
	ld	a, 128:opc	; F77442  ld A,0x80
	ld	(xix+), a	; F77444  ld (XIX+),A
	ld	a, (Smf_VlqValue:16)	; F77447  ld A,(0x1198)
	ld	(xix+), a	; F7744B  ld (XIX+),A
	ld	a, (4506:16)	; F7744E  ld A,(0x119a)
	ld	(xix+), a	; F77452  ld (XIX+),A
	ld	a, (4509:16)	; F77455  ld A,(0x119d)
	ld	w, 96:opc	; F77459  ld W,0x60
	muls	wa, w	; F7745B  muls WA,W
	xor	hl, hl	; F7745D  xor HL,HL
	ld	l, (4508:16)	; F7745F  ld L,(0x119c)
	add	wa, hl	; F77463  add WA,HL
	ld	(xix+), wa	; F77465  ld (XIX+),WA
	jrl	SmfSizeCopy_Pass_Loop4	; F77468  jrl T,0xf7728b
sub_F76E74_Skip14:
	cp	hl, 6:i3	; F7746B  cp HL,6
	jrl	nz, SmfSizeCopy_Pass_Loop4	; F7746D  jrl NZ,0xf7728b
	cp	(0x119a:16), 127	; F77470  cp (0x119a),0x7f
	jrl	z, SmfSizeCopy_Pass_Loop4	; F77475  jrl Z,0xf7728b
	ld	a, (4507:16)	; F77478  ld A,(0x119b)
	cp	a, 0:i3	; F7747C  cp A,0
	jrl	nz, SmfSizeCopy_Pass_Loop4	; F7747E  jrl NZ,0xf7728b
	bit	0, (0x133e:16)	; F77481  bit 0,(0x133e)
	jr	z, sub_F76E74_Skip15	; F77485  jr Z,0xf7748e
	bit	0, (0x11b1:16)	; F77487  bit 0,(0x11b1)
	jrl	z, SmfSizeCopy_Pass_Loop4	; F7748B  jrl Z,0xf7728b
sub_F76E74_Skip15:
	ld	c, (4505:16)	; F7748E  ld C,(0x1199)
	pushw	wa	; F77492  push WA
	calr	SmfSizeCopy_EncodeDeltaTime	; F77493  calr 0xf77990
	calr	SmfSizeCopy_AgePendingNoteOffs	; F77496  calr 0xf77a4a
	popw	wa	; F77499  pop WA
	cp	(0x1239:16), 0	; F7749A  cp (0x1239),0x00
	jrl	z, sub_F76E74_Skip16	; F7749F  jrl Z,0xf77538
	ld	l, (Smf_VlqValue:16)	; F774A2  ld L,(0x1198)
	ld	h, l	; F774A6  ld H,L
	and	l, 1	; F774A8  and L,0x01
	rrc	l	; F774AB  rrc 0x01,L
	ld	a, (4508:16)	; F774AE  ld A,(0x119c)
	or	l, a	; F774B2  or L,A
	ld	(SoundConv_Arg0:24), l	; F774B4  ld (0x60f010),L
	and	h, 2	; F774B9  and H,0x02
	.byte 0xCE, 0xE9, 0x02	; F774BC  rrc 0x02,H   [llvm-mc cannot encode this]
	ld	a, (4509:16)	; F774BF  ld A,(0x119d)
	and	a, 127	; F774C3  and A,0x7f
	or	h, a	; F774C6  or H,A
	ld	(SoundConv_Arg1:24), h	; F774C8  ld (0x60f011),H
	push	xix	; F774CD  push XIX
	xor	hl, hl	; F774CE  xor HL,HL
	ld	l, (4506:16)	; F774D0  ld L,(0x119a)
	ld	xix, BStore_TrackToPart	; F774D4  ld XIX,0x00603422
	ld	l, (xix+hl)	; F774D9  ld L,(XIX+HL)
	ld	xix, ByteMap_F77815	; F774DE  ld XIX,0x00f77815
	ld	l, (xix+hl)	; F774E3  ld L,(XIX+HL)
	ld	(SoundConv_Arg2:24), l	; F774E8  ld (0x60f012),L
	pop	xix	; F774ED  pop XIX
	call	T_PartSound_ToProgramChange	; F774EE  call 0xf41008
	ld	a, 176:opc	; F774F2  ld A,0xb0
	ld	w, (4506:16)	; F774F4  ld W,(0x119a)
	and	w, 15	; F774F8  and W,0x0f
	or	a, w	; F774FB  or A,W
	xor	w, w	; F774FD  xor W,W
	ld	l, (SoundConv_Result1:24)	; F774FF  ld L,(0x60f015)
	pushw	wa	; F77504  push WA
	call	SmfSizeCopy_WriteChannelEvent	; F77505  call 0xf779d5
	popw	wa	; F77509  pop WA
	ldw	(Smf_VlqBytes:16), 0	; F7750A  ld (0x1193),0x0000
	ld	(4501:16), 0	; F77510  ld (0x1195),0x00
	ld	w, 32:opc	; F77515  ld W,0x20
	ld	l, (SoundConv_Result0:24)	; F77517  ld L,(0x60f014)
	call	SmfSizeCopy_WriteChannelEvent	; F7751C  call 0xf779d5
	ld	a, 192:opc	; F77520  ld A,0xc0
	ld	w, (4506:16)	; F77522  ld W,(0x119a)
	and	w, 15	; F77526  and W,0x0f
	or	a, w	; F77529  or A,W
	ld	w, (SoundConv_Result2:24)	; F7752B  ld W,(0x60f016)
	xor	l, l	; F77530  xor L,L
	calr	SmfSizeCopy_WriteChannelEvent	; F77532  calr 0xf779d5
	jrl	SmfSizeCopy_Pass_Loop4	; F77535  jrl T,0xf7728b
sub_F76E74_Skip16:
	ld	w, 0:opc	; F77538  ld W,0x00
	ld	l, (4509:16)	; F7753A  ld L,(0x119d)
	and	l, 56	; F7753E  and L,0x38
	srl	l, 3	; F77541  srl 0x03,L
	calr	SmfSizeCopy_WriteControlChange	; F77544  calr 0xf77982
	ldw	(Smf_VlqBytes:16), 0	; F77547  ld (0x1193),0x0000
	ld	(4501:16), 0	; F7754D  ld (0x1195),0x00
	ld	w, 32:opc	; F77552  ld W,0x20
	ld	l, (4509:16)	; F77554  ld L,(0x119d)
	and	l, 7	; F77558  and L,0x07
	sla	l, 4	; F7755B  sla 0x04,L
	and	l, 127	; F7755E  and L,0x7f
	calr	SmfSizeCopy_WriteControlChange	; F77561  calr 0xf77982
	ld	a, 192:opc	; F77564  ld A,0xc0
	ld	w, (4506:16)	; F77566  ld W,(0x119a)
	and	w, 15	; F7756A  and W,0x0f
	or	a, w	; F7756D  or A,W
	ld	w, (4508:16)	; F7756F  ld W,(0x119c)
	xor	l, l	; F77573  xor L,L
	calr	SmfSizeCopy_WriteChannelEvent	; F77575  calr 0xf779d5
	jrl	SmfSizeCopy_Pass_Loop4	; F77578  jrl T,0xf7728b
sub_F76E74_Skip17:
	cp	hl, 6:i3	; F7757B  cp HL,6
	jrl	nz, SmfSizeCopy_Pass_Loop4	; F7757D  jrl NZ,0xf7728b
	cp	(0x119a:16), 127	; F77580  cp (0x119a),0x7f
	jrl	z, sub_F76E74_Skip31	; F77585  jrl Z,0xf777fd
	ld	l, (4507:16)	; F77588  ld L,(0x119b)
	ld	a, (4506:16)	; F7758C  ld A,(0x119a)
	ld	w, (Smf_VlqValue:16)	; F77590  ld W,(0x1198)
	and	w, 4	; F77594  and W,0x04
	sla	w, 5	; F77597  sla 0x05,W
	or	a, w	; F7759A  or A,W
	cp	a, 181	; F7759C  cp A,0xb5
	jr	z, sub_F76E74_Skip18	; F7759F  jr Z,0xf775a3
	jr	sub_F76E74_Join6	; F775A1  jr T,0xf775f1
sub_F76E74_Skip18:
	ld	l, (4507:16)	; F775A3  ld L,(0x119b)
	cp	l, 127	; F775A7  cp L,0x7f
	jrl	z, sub_F76E74_Skip31	; F775AA  jrl Z,0xf777fd
	cp	a, 181	; F775AD  cp A,0xb5
	jrl	z, sub_F76E74_Skip19	; F775B0  jrl Z,0xf775cd
	cp	l, 0:i3	; F775B3  cp L,0
	jrl	c, sub_F76E74_Skip31	; F775B5  jrl C,0xf777fd
	cp	l, 16	; F775B8  cp L,0x10
	jrl	ugt, sub_F76E74_Skip31	; F775BB  jrl UGT,0xf777fd
	jrl	SmfSizeCopy_Pass_Loop4	; F775BE  jrl T,0xf7728b
	jrl	SmfSizeCopy_Pass_Loop4	; F775C1  jrl T,0xf7728b
	jrl	SmfSizeCopy_Pass_Loop4	; F775C4  jrl T,0xf7728b
	jrl	SmfSizeCopy_Pass_Loop4	; F775C7  jrl T,0xf7728b
	jrl	SmfSizeCopy_Pass_Loop4	; F775CA  jrl T,0xf7728b
sub_F76E74_Skip19:
	ld	c, (4505:16)	; F775CD  ld C,(0x1199)
	pushw	wa	; F775D1  push WA
	pushw	hl	; F775D2  push HL
	calr	SmfSizeCopy_EncodeDeltaTime	; F775D3  calr 0xf77990
	calr	SmfSizeCopy_AgePendingNoteOffs	; F775D6  calr 0xf77a4a
	popw	hl	; F775D9  pop HL
	popw	wa	; F775DA  pop WA
	ld	a, 176:opc	; F775DB  ld A,0xb0
	ld	w, l	; F775DD  ld W,L
	and	w, 15	; F775DF  and W,0x0f
	or	a, w	; F775E2  or A,W
	ld	w, 64:opc	; F775E4  ld W,0x40
	ld	l, (4508:16)	; F775E6  ld L,(0x119c)
	call	SmfSizeCopy_WriteChannelEvent	; F775EA  call 0xf779d5
	jrl	SmfSizeCopy_Pass_Loop4	; F775EE  jrl T,0xf7728b
sub_F76E74_Join6:
	cp	l, 3:i3	; F775F1  cp L,3
	jrl	c, SmfSizeCopy_Pass_Loop4	; F775F3  jrl C,0xf7728b
	cp	l, 11	; F775F6  cp L,0x0b
	jrl	ugt, SmfSizeCopy_Pass_Loop4	; F775F9  jrl UGT,0xf7728b
	ld	a, 176:opc	; F775FC  ld A,0xb0
	ld	w, (4506:16)	; F775FE  ld W,(0x119a)
	and	w, 15	; F77602  and W,0x0f
	or	a, w	; F77605  or A,W
	ld	w, 7:opc	; F77607  ld W,0x07
	cp	l, 3:i3	; F77609  cp L,3
	jrl	z, sub_F76E74_Entry8	; F7760B  jrl Z,0xf777d8
	cp	l, 4:i3	; F7760E  cp L,4
	jrl	z, sub_F76E74_Skip24	; F77610  jrl Z,0xf7777c
	cp	l, 5:i3	; F77613  cp L,5
	jrl	z, sub_F76E74_Entry6	; F77615  jrl Z,0xf77783
	cp	l, 6:i3	; F77618  cp L,6
	jrl	z, sub_F76E74_Entry7	; F7761A  jrl Z,0xf77798
	cp	l, 7:i3	; F7761D  cp L,7
	jrl	z, sub_F76E74_Skip28	; F7761F  jrl Z,0xf777be
	cp	l, 8	; F77622  cp L,0x08
	jrl	z, sub_F76E74_Entry5	; F77625  jrl Z,0xf7774a
	cp	l, 9	; F77628  cp L,0x09
	jrl	z, sub_F76E74_Entry4	; F7762B  jrl Z,0xf776fa
	cp	l, 10	; F7762E  cp L,0x0a
	jr	z, sub_F76E74_Entry2	; F77631  jr Z,0xf7763b
	cp	l, 11	; F77633  cp L,0x0b
	jr	z, sub_F76E74_Entry3	; F77636  jr Z,0xf776a7
	jrl	nz, SmfSizeCopy_Pass_Loop4	; F77638  jrl NZ,0xf7728b
sub_F76E74_Entry2:
	bit	0, (0x133e:16)	; F7763B  bit 0,(0x133e)
	jrl	z, sub_F76E74_Skip20	; F7763F  jrl Z,0xf77649
	bit	0, (0x11b1:16)	; F77642  bit 0,(0x11b1)
	jrl	z, SmfSizeCopy_Pass_Loop4	; F77646  jrl Z,0xf7728b
sub_F76E74_Skip20:
	ld	c, (4505:16)	; F77649  ld C,(0x1199)
	pushw	wa	; F7764D  push WA
	push	xhl	; F7764E  push XHL
	calr	SmfSizeCopy_EncodeDeltaTime	; F7764F  calr 0xf77990
	calr	SmfSizeCopy_AgePendingNoteOffs	; F77652  calr 0xf77a4a
	pop	xhl	; F77655  pop XHL
	popw	wa	; F77656  pop WA
	ld	a, 176:opc	; F77657  ld A,0xb0
	ld	w, (4506:16)	; F77659  ld W,(0x119a)
	and	w, 15	; F7765D  and W,0x0f
	or	a, w	; F77660  or A,W
	ld	w, 101:opc	; F77662  ld W,0x65
	ld	l, 0:opc	; F77664  ld L,0x00
	pushw	wa	; F77666  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F77667  calr 0xf779d5
	popw	wa	; F7766A  pop WA
	ld	w, 100:opc	; F7766B  ld W,0x64
	ld	l, 1:opc	; F7766D  ld L,0x01
	ld	(Smf_VlqBytes:16), 0	; F7766F  ld (0x1193),0x00
	pushw	wa	; F77674  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F77675  calr 0xf779d5
	popw	wa	; F77678  pop WA
	ld	w, 6:opc	; F77679  ld W,0x06
	ld	l, (4508:16)	; F7767B  ld L,(0x119c)
	ld	h, (Smf_VlqValue:16)	; F7767F  ld H,(0x1198)
	and	h, 1	; F77683  and H,0x01
	.byte 0xCE, 0xE9, 0x02	; F77686  rrc 0x02,H   [llvm-mc cannot encode this]
	srl	l, 1	; F77689  srl 0x01,L
	or	l, h	; F7768C  or L,H
	pushw	wa	; F7768E  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F7768F  calr 0xf779d5
	popw	wa	; F77692  pop WA
	ld	w, 38:opc	; F77693  ld W,0x26
	ld	l, (4508:16)	; F77695  ld L,(0x119c)
	and	l, 1	; F77699  and L,0x01
	.byte 0xCF, 0xE9, 0x02	; F7769C  rrc 0x02,L   [llvm-mc cannot encode this]
	pushw	wa	; F7769F  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F776A0  calr 0xf779d5
	popw	wa	; F776A3  pop WA
	jrl	SmfSizeCopy_Pass_Loop4	; F776A4  jrl T,0xf7728b
sub_F76E74_Entry3:
	bit	0, (0x133e:16)	; F776A7  bit 0,(0x133e)
	jrl	z, sub_F76E74_Skip21	; F776AB  jrl Z,0xf776b5
	bit	0, (0x11b1:16)	; F776AE  bit 0,(0x11b1)
	jrl	z, SmfSizeCopy_Pass_Loop4	; F776B2  jrl Z,0xf7728b
sub_F76E74_Skip21:
	ld	c, (4505:16)	; F776B5  ld C,(0x1199)
	pushw	wa	; F776B9  push WA
	pushw	hl	; F776BA  push HL
	calr	SmfSizeCopy_EncodeDeltaTime	; F776BB  calr 0xf77990
	calr	SmfSizeCopy_AgePendingNoteOffs	; F776BE  calr 0xf77a4a
	popw	hl	; F776C1  pop HL
	popw	wa	; F776C2  pop WA
	ld	a, 176:opc	; F776C3  ld A,0xb0
	ld	w, (4506:16)	; F776C5  ld W,(0x119a)
	and	w, 15	; F776C9  and W,0x0f
	or	a, w	; F776CC  or A,W
	ld	w, 101:opc	; F776CE  ld W,0x65
	ld	l, 0:opc	; F776D0  ld L,0x00
	pushw	wa	; F776D2  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F776D3  calr 0xf779d5
	popw	wa	; F776D6  pop WA
	ld	w, 100:opc	; F776D7  ld W,0x64
	ld	l, 0:opc	; F776D9  ld L,0x00
	ld	(Smf_VlqBytes:16), 0	; F776DB  ld (0x1193),0x00
	pushw	wa	; F776E0  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F776E1  calr 0xf779d5
	popw	wa	; F776E4  pop WA
	ld	w, 6:opc	; F776E5  ld W,0x06
	ld	l, (4508:16)	; F776E7  ld L,(0x119c)
	pushw	wa	; F776EB  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F776EC  calr 0xf779d5
	popw	wa	; F776EF  pop WA
	ld	w, 38:opc	; F776F0  ld W,0x26
	ld	l, 0:opc	; F776F2  ld L,0x00
	calr	SmfSizeCopy_WriteChannelEvent	; F776F4  calr 0xf779d5
	jrl	SmfSizeCopy_Pass_Loop4	; F776F7  jrl T,0xf7728b
sub_F76E74_Entry4:
	bit	0, (0x133e:16)	; F776FA  bit 0,(0x133e)
	jr	z, sub_F76E74_Skip22	; F776FE  jr Z,0xf77707
	bit	0, (0x11b1:16)	; F77700  bit 0,(0x11b1)
	jrl	z, SmfSizeCopy_Pass_Loop4	; F77704  jrl Z,0xf7728b
sub_F76E74_Skip22:
	ld	c, (4505:16)	; F77707  ld C,(0x1199)
	pushw	wa	; F7770B  push WA
	pushw	hl	; F7770C  push HL
	calr	SmfSizeCopy_EncodeDeltaTime	; F7770D  calr 0xf77990
	calr	SmfSizeCopy_AgePendingNoteOffs	; F77710  calr 0xf77a4a
	popw	hl	; F77713  pop HL
	popw	wa	; F77714  pop WA
	ld	a, 176:opc	; F77715  ld A,0xb0
	ld	w, l	; F77717  ld W,L
	and	w, 15	; F77719  and W,0x0f
	or	a, w	; F7771C  or A,W
	ld	w, 101:opc	; F7771E  ld W,0x65
	ld	l, 0:opc	; F77720  ld L,0x00
	pushw	wa	; F77722  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F77723  calr 0xf779d5
	popw	wa	; F77726  pop WA
	ld	w, 100:opc	; F77727  ld W,0x64
	ld	l, 2:opc	; F77729  ld L,0x02
	ld	(Smf_VlqBytes:16), 0	; F7772B  ld (0x1193),0x00
	pushw	wa	; F77730  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F77731  calr 0xf779d5
	popw	wa	; F77734  pop WA
	ld	w, 6:opc	; F77735  ld W,0x06
	ld	l, (4508:16)	; F77737  ld L,(0x119c)
	pushw	wa	; F7773B  push WA
	calr	SmfSizeCopy_WriteChannelEvent	; F7773C  calr 0xf779d5
	popw	wa	; F7773F  pop WA
	ld	w, 38:opc	; F77740  ld W,0x26
	ld	l, 0:opc	; F77742  ld L,0x00
	calr	SmfSizeCopy_WriteChannelEvent	; F77744  calr 0xf779d5
	jrl	SmfSizeCopy_Pass_Loop4	; F77747  jrl T,0xf7728b
sub_F76E74_Entry5:
	bit	0, (0x133e:16)	; F7774A  bit 0,(0x133e)
	jr	z, sub_F76E74_Skip23	; F7774E  jr Z,0xf77757
	bit	0, (0x11b1:16)	; F77750  bit 0,(0x11b1)
	jrl	z, SmfSizeCopy_Pass_Loop4	; F77754  jrl Z,0xf7728b
sub_F76E74_Skip23:
	ld	c, (4505:16)	; F77757  ld C,(0x1199)
	pushw	wa	; F7775B  push WA
	pushw	hl	; F7775C  push HL
	calr	SmfSizeCopy_EncodeDeltaTime	; F7775D  calr 0xf77990
	calr	SmfSizeCopy_AgePendingNoteOffs	; F77760  calr 0xf77a4a
	popw	hl	; F77763  pop HL
	popw	wa	; F77764  pop WA
	ld	a, 176:opc	; F77765  ld A,0xb0
	ld	w, (4507:16)	; F77767  ld W,(0x119b)
	and	w, 15	; F7776B  and W,0x0f
	or	a, w	; F7776E  or A,W
	ld	w, 10:opc	; F77770  ld W,0x0a
	ld	l, (4508:16)	; F77772  ld L,(0x119c)
	calr	SmfSizeCopy_WriteChannelEvent	; F77776  calr 0xf779d5
	jrl	SmfSizeCopy_Pass_Loop4	; F77779  jrl T,0xf7728b
sub_F76E74_Skip24:
	ld	bc, (4508:16)	; F7777C  ld BC,(0x119c)
	jrl	SmfSizeCopy_Pass_Loop4	; F77780  jrl T,0xf7728b
sub_F76E74_Entry6:
	bit	0, (0x133e:16)	; F77783  bit 0,(0x133e)
	jr	z, sub_F76E74_Skip25	; F77787  jr Z,0xf77790
	bit	0, (0x11b1:16)	; F77789  bit 0,(0x11b1)
	jrl	z, SmfSizeCopy_Pass_Loop4	; F7778D  jrl Z,0xf7728b
sub_F76E74_Skip25:
	ld	w, 93:opc	; F77790  ld W,0x5d
	ld	l, (4508:16)	; F77792  ld L,(0x119c)
	jr	sub_F76E74_Join7	; F77796  jr T,0xf777e9
sub_F76E74_Entry7:
	bit	0, (0x133e:16)	; F77798  bit 0,(0x133e)
	jr	z, sub_F76E74_Skip26	; F7779C  jr Z,0xf777a5
	bit	0, (0x11b1:16)	; F7779E  bit 0,(0x11b1)
	jrl	z, SmfSizeCopy_Pass_Loop4	; F777A2  jrl Z,0xf7728b
sub_F76E74_Skip26:
	ld	w, 93:opc	; F777A5  ld W,0x5d
	ld	l, (4508:16)	; F777A7  ld L,(0x119c)
	jr	sub_F76E74_Join7	; F777AB  jr T,0xf777e9
	bit	0, (0x133e:16)	; F777AD  bit 0,(0x133e)
	jr	z, sub_F76E74_Skip27	; F777B1  jr Z,0xf777ba
	bit	0, (0x11b1:16)	; F777B3  bit 0,(0x11b1)
	jrl	z, SmfSizeCopy_Pass_Loop4	; F777B7  jrl Z,0xf7728b
sub_F76E74_Skip27:
	ld	w, 64:opc	; F777BA  ld W,0x40
	jr	sub_F76E74_Join7	; F777BC  jr T,0xf777e9
sub_F76E74_Skip28:
	ld	w, 91:opc	; F777BE  ld W,0x5b
	ld	l, 0:opc	; F777C0  ld L,0x00
	bit	0, (0x133e:16)	; F777C2  bit 0,(0x133e)
	jr	z, sub_F76E74_Skip29	; F777C6  jr Z,0xf777cf
	bit	0, (0x11b1:16)	; F777C8  bit 0,(0x11b1)
	jrl	z, SmfSizeCopy_Pass_Loop4	; F777CC  jrl Z,0xf7728b
sub_F76E74_Skip29:
	ld	l, (4508:16)	; F777CF  ld L,(0x119c)
	and	l, 127	; F777D3  and L,0x7f
	jr	sub_F76E74_Join7	; F777D6  jr T,0xf777e9
sub_F76E74_Entry8:
	bit	0, (0x133e:16)	; F777D8  bit 0,(0x133e)
	jr	z, sub_F76E74_Skip30	; F777DC  jr Z,0xf777e5
	bit	0, (0x11b1:16)	; F777DE  bit 0,(0x11b1)
	jrl	z, SmfSizeCopy_Pass_Loop4	; F777E2  jrl Z,0xf7728b
sub_F76E74_Skip30:
	ld	l, (4508:16)	; F777E5  ld L,(0x119c)
sub_F76E74_Join7:
	ld	c, (4505:16)	; F777E9  ld C,(0x1199)
	pushw	wa	; F777ED  push WA
	pushw	hl	; F777EE  push HL
	calr	SmfSizeCopy_EncodeDeltaTime	; F777EF  calr 0xf77990
	calr	SmfSizeCopy_AgePendingNoteOffs	; F777F2  calr 0xf77a4a
	popw	hl	; F777F5  pop HL
	popw	wa	; F777F6  pop WA
	calr	SmfSizeCopy_WriteChannelEvent	; F777F7  calr 0xf779d5
	jrl	SmfSizeCopy_Pass_Loop4	; F777FA  jrl T,0xf7728b
sub_F76E74_Skip31:
	jrl	SmfSizeCopy_Pass_Loop4	; F777FD  jrl T,0xf7728b
sub_F76E74_Skip32:
	ld	c, 0:opc	; F77800  ld C,0x00
	calr	SmfSizeCopy_EncodeDeltaTime	; F77802  calr 0xf77990
	calr	SmfSizeCopy_AgePendingNoteOffs	; F77805  calr 0xf77a4a
	ld	a, 255:opc	; F77808  ld A,0xff
	ld	w, 47:opc	; F7780A  ld W,0x2f
	ld	l, 0:opc	; F7780C  ld L,0x00
	calr	SmfSizeCopy_WriteChannelEvent	; F7780E  calr 0xf779d5
	calr	SmfSizeCopy_StoreTrackLength	; F77811  calr 0xf7789a
sub_F76E74_Return:
	ret	; F77814  ret


; --------------------------------------------------------------------------
; ByteMap_F77815 -- 33 bytes: a BYTE MAP.  0 of them are 0xFF and the other
;                   33 ASCEND STRICTLY, 0x00 to 0x7F, with jumps.  The name
;                   describes the CONTENT; what the two index spaces are is
;                   not established here.
; Read by: 1 byte-scan hit: 1 instruction operand -- `ld XIX,0x00f77815` at
;          0xF774DE (operand field 1 byte in) -- inside Data_F7681C, a run
;          this block emits as bytes, so it has no instruction line here
; Entry count: 33 bytes.  The run is trimmed of trailing 0xFF, so it claims
;              no padding it did not earn; the byte before it is 0x0E and
;              the LAST byte of it is 0x7F.
; Evidence: every non-0xFF byte is compared with its predecessor on every
;           emit, WITHIN EACH of the 1 maximal ascending runs the rule
;           returns, and the runs are asserted to tile this segment exactly.
;           The BYTEMAP rule fires ZERO times over the proven prom_b
;           instruction text at (16 bytes, 12 values) and also at (20,14),
;           (24,16) and (16,16) (`python3 notes/prom_b_f6d002_layout.py
;           --null-ptr`).
; Unknown: what the two index spaces ARE, and who reads it.
; --------------------------------------------------------------------------
ByteMap_F77815:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F77815  [0..15]
	.byte	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F	; F77825  [16..31]
	.byte	0x7F	; F77835  [32..32]
; --------------------------------------------------------------------------
; SmfFileTemplate_F77836 -- the 33-byte STANDARD MIDI FILE header this
;          firmware copies into its output buffer before writing a track.
;          Format 0, one track, division 96 ticks per quarter note.
;          ⚠ NOT MUSIC: no note, no end-of-track.  The events are written
;          at run time by the code below; this is only the file's opening.
; Read by: three `ld XIY,imm32` copy sources -- +0x00 with `ld
;          BC,0x0007`/`ldirw` (14 bytes), +0x0E with `ld BC,0x0004`/`ldirw`
;          (8), +0x16 with `ld BC,0x000B`/`ldir` (11). 14+8+11 = 33, which
;          is why this object ends here and the word table below begins at
;          +0x21.
; Then:    `ld XIY,0x21C8` / `ld BC,0x0008` / `ldir` appends eight RAM
;          bytes, so the meta event's declared length of 15 is 7 from ROM +
;          8 from RAM.
; Length:  the `00 00 00 00` at +0x12 is a PLACEHOLDER. 0xF7789A computes
;          (0x126C)*1024 + (cursor - 0x60A700) - 22 and stores it most
;          significant byte first into (0x10C4)-(0x10C7). 22 = `MThd` + its
;          6 payload bytes + `MTrk`. That is why every chunk walker that
;          trusts the field steps nowhere.
; Evidence: notes/gen_prom_b_smf_writer_module.py --selftest re-derives every
;           byte and every reader from the ROM.
; --------------------------------------------------------------------------
SmfFileTemplate_F77836:
	.ascii	"MThd"	; F77836  header chunk tag
	.byte	0x00, 0x00, 0x00, 0x06	; F7783A  chunk length 6, most significant byte first
	.byte	0x00, 0x00	; F7783E  format 0 -- one multi-channel track
	.byte	0x00, 0x01	; F77840  ntrks 1
	.byte	0x00, 0x60	; F77842  division 0x0060 = 96 ticks per quarter note
	.ascii	"MTrk"	; F77844  track chunk tag
	.byte	0x00, 0x00, 0x00, 0x00	; F77848  track length PLACEHOLDER -- backfilled by 0xF7789A
	.byte	0x00	; F7784C  delta time 0
	.byte	0xFF, 0x03	; F7784D  meta event FF 03 -- sequence/track name
	.byte	0x0F	; F7784F  ... declared length 15
	.ascii	"WSA    "	; F77850  name bytes 1-7; 8-15 come from RAM (0x21C8)

; --------------------------------------------------------------------------
; SmfPartOffsets_F77857 -- 32 little-endian 16-bit BYTE OFFSETS and a
;          0xFFFF terminator.  NOT MIDI, and not part of the file: it only
;          happens to sit 0x21 bytes after the template.
;          0x0000, 0x0040 ... 0x0800, step 0x40 -- one record per slot in the
;          0x40-strided array at RAM 0x006036A0.
; Read by: five instructions spell 0x00F77857: 0xF76FB9 is `ld XDE,<base>`
;          followed by `ld HL,(XDE+HL)` with HL = (byte from RAM 0x603422) *
;          2, and the result reaches `lda XIY,XIY+HL` on XIY = 0x006036A0.
; ⚠ Note:  the step is 0x40 everywhere EXCEPT between slots 7 and 8, where
;          it is 0x80: the record at 0x0200 is skipped. That is in the ROM
;          and identical in all four copies. What occupies the skipped slot
;          is NOT established.
; --------------------------------------------------------------------------
SmfPartOffsets_F77857:
	.short	0x0000, 0x0040, 0x0080, 0x00C0, 0x0100, 0x0140, 0x0180, 0x01C0	; F77857  slots  0- 7
	.short	0x0240, 0x0280, 0x02C0, 0x0300, 0x0340, 0x0380, 0x03C0, 0x0400	; F77867  slots  8-15
	.short	0x0440, 0x0480, 0x04C0, 0x0500, 0x0540, 0x0580, 0x05C0, 0x0600	; F77877  slots 16-23
	.short	0x0640, 0x0680, 0x06C0, 0x0700, 0x0740, 0x0780, 0x07C0, 0x0800	; F77887  slots 24-31
	.short	0xFFFF	; F77897  terminator

; --------------------------------------------------------------------------
; sub_F76E74_Nop
; Called from: 0xF77245
; Evidence: 0xF77899 is an instruction boundary of this transcription,
;           re-asserted on every emit.
; Purpose: none -- the entry is a lone `ret`.  Named sub_F76E74_Nop after what reaches it
;          (was sub_F77899; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
sub_F76E74_Nop:
	ret	; F77899  ret

; --------------------------------------------------------------------------
; SmfSizeCopy_StoreTrackLength
; Called from: 0xF77811
; Evidence: 0xF7789A is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfSizeCopy_StoreTrackLength: copy D of prom_b's SMF writer (an unreferenced copy of B), role StoreTrackLength as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSizeCopy_StoreTrackLength:
	xor	wa, wa	; F7789A  xor WA,WA
	ld	(SmfOut_TrackLength:16), wa	; F7789C  ld (0x10c4),WA
	ld	(SmfOut_TrackLength+2:16), wa	; F778A0  ld (0x10c6),WA
	ld	wa, (SmfOut_WindowsFlushed:16)	; F778A4  ld WA,(0x126c)
	mul	wa, 1024	; F778A8  mul WA,0x0400
	ld	xhl, (InputStream_Cursor:16)	; F778AC  ld XHL,(0x1088)
	sub	xhl, 6334208	; F778B0  sub XHL,0x0060a700
	add	xwa, xhl	; F778B6  add XWA,XHL
	sub	xwa, 22	; F778B8  sub XWA,0x00000016
	ld	de, qwa	; F778BE  ld DE,QWA
	ld	(SmfOut_TrackLength:16), d	; F778C1  ld (0x10c4),D
	ld	(SmfOut_TrackLength+1:16), e	; F778C5  ld (0x10c5),E
	ld	(SmfOut_TrackLength+2:16), w	; F778C9  ld (0x10c6),W
	ld	(SmfOut_TrackLength+3:16), a	; F778CD  ld (0x10c7),A
	ret	; F778D1  ret

; --------------------------------------------------------------------------
; SmfSizeCopy_StageTempo
; Called from: 0xF76F3F, 0xF77363
; Evidence: 0xF778D2 is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfSizeCopy_StageTempo: copy D of prom_b's SMF writer (an unreferenced copy of B), role StageTempo as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSizeCopy_StageTempo:
	ldw	wa, 60000	; F778D2  ld WA,0xea60
	extz	xwa	; F778D5  extz XWA
	mul	xwa, hl	; F778D7  mul XWA,HL
	ld	de, qwa	; F778D9  ld DE,QWA
	ld	(SmfOut_Tempo:16), wa	; F778DC  ld (0x108c),WA
	ld	(SmfOut_Tempo+2:16), de	; F778E0  ld (0x108e),DE
	ldw	wa, 40000	; F778E4  ld WA,0x9c40
	extz	xwa	; F778E7  extz XWA
	mul	xwa, hl	; F778E9  mul XWA,HL
	ld	de, qwa	; F778EB  ld DE,QWA
	add	wa, (SmfOut_Tempo:16)	; F778EE  add WA,(0x108c)
	adc	de, (SmfOut_Tempo+2:16)	; F778F2  adc DE,(0x108e)
	ldw	hl, 24000	; F778F6  ld HL,0x5dc0
	ld	qwa, de	; F778F9  ld QWA,DE
	div	xwa, hl	; F778FC  div XWA,HL
	ld	de, qwa	; F778FE  ld DE,QWA
	cp	de, 0:i3	; F77901  cp DE,0
	jr	z, SmfSizeCopy_StageTempo_Skip	; F77903  jr Z,0xf77907
	inc	1, wa	; F77905  inc 1,WA
SmfSizeCopy_StageTempo_Skip:
	ldw	hl, 1000	; F77907  ld HL,0x03e8
	mul	xwa, hl	; F7790A  mul XWA,HL
	ld	de, qwa	; F7790C  ld DE,QWA
	ld	(SmfOut_Tempo:16), wa	; F7790F  ld (0x108c),WA
	ld	(SmfOut_Tempo+2:16), de	; F77913  ld (0x108e),DE
	ret	; F77917  ret

; --------------------------------------------------------------------------
; SmfSizeCopy_WriteTempoEvent
; Called from: 0xF76F42, 0xF77366
; Evidence: 0xF77918 is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfSizeCopy_WriteTempoEvent: copy D of prom_b's SMF writer (an unreferenced copy of B), role WriteTempoEvent as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSizeCopy_WriteTempoEvent:
	ld	xiy, Smf_VlqBytes	; F77918  ld XIY,0x00001193
	ld	xix, (InputStream_Cursor:16)	; F7791D  ld XIX,(0x1088)
SmfSizeCopy_WriteTempoEvent_Loop:
	ld	a, (xiy+)	; F77921  ld A,(XIY+)
	ld	(xix+), a	; F77924  ld (XIX+),A
	calr	SmfSizeCopy_CommitOutputByte	; F77927  calr 0xf77a28
	ld	xix, (InputStream_Cursor:16)	; F7792A  ld XIX,(0x1088)
	bit	7, a	; F7792E  bit 0x07,A
	jr	nz, SmfSizeCopy_WriteTempoEvent_Loop	; F77931  jr NZ,0xf77921
	ld	a, 255:opc	; F77933  ld A,0xff
	ld	(xix+), a	; F77935  ld (XIX+),A
	calr	SmfSizeCopy_CommitOutputByte	; F77938  calr 0xf77a28
	ld	xix, (InputStream_Cursor:16)	; F7793B  ld XIX,(0x1088)
	ld	a, 81:opc	; F7793F  ld A,0x51
	ld	(xix+), a	; F77941  ld (XIX+),A
	calr	SmfSizeCopy_CommitOutputByte	; F77944  calr 0xf77a28
	ld	xix, (InputStream_Cursor:16)	; F77947  ld XIX,(0x1088)
	ld	a, 3:opc	; F7794B  ld A,0x03
	ld	(xix+), a	; F7794D  ld (XIX+),A
	calr	SmfSizeCopy_CommitOutputByte	; F77950  calr 0xf77a28
	ld	xix, (InputStream_Cursor:16)	; F77953  ld XIX,(0x1088)
	ld	a, (SmfOut_Tempo+2:16)	; F77957  ld A,(0x108e)
	ld	(xix+), a	; F7795B  ld (XIX+),A
	calr	SmfSizeCopy_CommitOutputByte	; F7795E  calr 0xf77a28
	ld	xix, (InputStream_Cursor:16)	; F77961  ld XIX,(0x1088)
	ld	a, (SmfOut_Tempo+1:16)	; F77965  ld A,(0x108d)
	ld	(xix+), a	; F77969  ld (XIX+),A
	calr	SmfSizeCopy_CommitOutputByte	; F7796C  calr 0xf77a28
	ld	xix, (InputStream_Cursor:16)	; F7796F  ld XIX,(0x1088)
	ld	a, (SmfOut_Tempo:16)	; F77973  ld A,(0x108c)
	ld	(xix+), a	; F77977  ld (XIX+),A
	calr	SmfSizeCopy_CommitOutputByte	; F7797A  calr 0xf77a28
	ld	xix, (InputStream_Cursor:16)	; F7797D  ld XIX,(0x1088)
	ret	; F77981  ret

; --------------------------------------------------------------------------
; SmfSizeCopy_WriteControlChange
; Called from: 0xF77544, 0xF77561
; Evidence: 0xF77982 is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfSizeCopy_WriteControlChange: copy D of prom_b's SMF writer (an unreferenced copy of B), role WriteControlChange as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSizeCopy_WriteControlChange:
	ld	a, (4506:16)	; F77982  ld A,(0x119a)
	and	a, 15	; F77986  and A,0x0f
	or	a, 176	; F77989  or A,0xb0
	calr	SmfSizeCopy_WriteChannelEvent	; F7798C  calr 0xf779d5
	ret	; F7798F  ret

; --------------------------------------------------------------------------
; SmfSizeCopy_EncodeDeltaTime
; Called from: 0xF77339, 0xF77371, 0xF77394, 0xF773B7, 0xF773DD, 0xF77422,
;              0xF77493, 0xF775D3, 0xF7764F, 0xF776BB, 0xF7770D, 0xF7775D,
;              0xF777EF, 0xF77802
; Evidence: 0xF77990 is an instruction boundary of this transcription,
;           re-asserted on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap
;          stated, per this tree's rule that a stated gap beats a guess.
; --------------------------------------------------------------------------
; SmfSizeCopy_EncodeDeltaTime: copy D of prom_b's SMF writer (an unreferenced copy of B), role EncodeDeltaTime as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSizeCopy_EncodeDeltaTime:
	pushw	wa	; F77990  push WA
	push	xhl	; F77991  push XHL
	pushw	de	; F77992  push DE
	xor	wa, wa	; F77993  xor WA,WA
	ld	(4522:16), wa	; F77995  ld (0x11aa),WA
	ld	(4524:16), a	; F77999  ld (0x11ac),A
	ld	wa, (4222:16)	; F7799D  ld WA,(0x107e)
	xor	b, b	; F779A1  xor B,B
	add	wa, bc	; F779A3  add WA,BC
	ld	de, (4226:16)	; F779A5  ld DE,(0x1082)
	sub	wa, de	; F779A9  sub WA,DE
	ld	(4522:16), wa	; F779AB  ld (0x11aa),WA
	bit	0, (0x1268:16)	; F779AF  bit 0,(0x1268)
	jr	nz, SmfSizeCopy_EncodeDeltaTime_Skip	; F779B3  jr NZ,0xf779c6
	bit	1, (0x133e:16)	; F779B5  bit 1,(0x133e)
	jr	z, SmfSizeCopy_EncodeDeltaTime_Skip	; F779B9  jr Z,0xf779c6
	addw	(0x11aa:16), 384	; F779BB  add (0x11aa),0x0180
	ld	(4712:16), 1	; F779C1  ld (0x1268),0x01
SmfSizeCopy_EncodeDeltaTime_Skip:
	ld	(4226:16), bc	; F779C6  ld (0x1082),BC
	ld	(4240:16), de	; F779CA  ld (0x1090),DE
	popw	de	; F779CE  pop DE
	pop	xhl	; F779CF  pop XHL
	popw	wa	; F779D0  pop WA
	calr	SmfSizeCopy_EncodeVlq	; F779D1  calr 0xf77bdf
	ret	; F779D4  ret


; --------------------------------------------------------------------------
; SmfSizeCopy_WriteChannelEvent
; Called from: in-module: 0xF77BA1
; Touches: (0x1088)
; Calls:   SmfSizeCopy_CommitOutputByte
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF779D5 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSizeCopy_WriteChannelEvent: copy D of prom_b's SMF writer (an unreferenced copy of B), role WriteChannelEvent as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSizeCopy_WriteChannelEvent:
	push	xiy	; F779D5  push XIY
	ld	xix, (InputStream_Cursor:16)	; F779D6  ld XIX,(0x1088)
	ld	xiy, Smf_VlqBytes	; F779DA  ld XIY,0x00001193
	pushw	wa	; F779DF  push WA
SmfSizeCopy_WriteChannelEvent_Loop:
	ld	a, (xiy+)	; F779E0  ld A,(XIY+)
	ld	(xix+), a	; F779E3  ld (XIX+),A
	pushw	wa	; F779E6  push WA
	calr	SmfSizeCopy_CommitOutputByte	; F779E7  calr 0xf77a28
	popw	wa	; F779EA  pop WA
	ld	xix, (InputStream_Cursor:16)	; F779EB  ld XIX,(0x1088)
	bit	7, a	; F779EF  bit 0x07,A
	jr	nz, SmfSizeCopy_WriteChannelEvent_Loop	; F779F2  jr NZ,0xf779e0
	popw	wa	; F779F4  pop WA
	ld	h, a	; F779F5  ld H,A
	ld	(xix+), a	; F779F7  ld (XIX+),A
	calr	SmfSizeCopy_CommitOutputByte	; F779FA  calr 0xf77a28
	ld	xix, (InputStream_Cursor:16)	; F779FD  ld XIX,(0x1088)
	ld	a, w	; F77A01  ld A,W
	ld	(xix+), a	; F77A03  ld (XIX+),A
	calr	SmfSizeCopy_CommitOutputByte	; F77A06  calr 0xf77a28
	ld	xix, (InputStream_Cursor:16)	; F77A09  ld XIX,(0x1088)
	and	h, 240	; F77A0D  and H,0xf0
	cp	h, 192	; F77A10  cp H,0xc0
	jr	z, SmfSizeCopy_WriteChannelEvent_Epilogue	; F77A13  jr Z,0xf77a26
	cp	h, 208	; F77A15  cp H,0xd0
	jr	z, SmfSizeCopy_WriteChannelEvent_Epilogue	; F77A18  jr Z,0xf77a26
	ld	a, l	; F77A1A  ld A,L
	ld	(xix+), a	; F77A1C  ld (XIX+),A
	calr	SmfSizeCopy_CommitOutputByte	; F77A1F  calr 0xf77a28
	ld	xix, (InputStream_Cursor:16)	; F77A22  ld XIX,(0x1088)
SmfSizeCopy_WriteChannelEvent_Epilogue:
	pop	xiy	; F77A26  pop XIY
	ret	; F77A27  ret

; --------------------------------------------------------------------------
; SmfSizeCopy_CommitOutputByte
; Called from: in-module: 0xF779E7 0xF779FA 0xF77A06 0xF77A1F
; Touches: (0x107E) (0x1080) (0x1088) (0x11AA) (0x126C)  |  0x60A700
;          0x60AAFF
; Calls:   SmfSizeCopy_ClearDueList SmfSizeCopy_SortDueNoteOffs
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF77A28 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSizeCopy_CommitOutputByte: copy D of prom_b's SMF writer (an unreferenced copy of B), role CommitOutputByte as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSizeCopy_CommitOutputByte:
	push	xhl	; F77A28  push XHL
	pushw	bc	; F77A29  push BC
	cp	xix, 6335231	; F77A2A  cp XIX,0x0060aaff
	jr	ule, SmfSizeCopy_CommitOutputByte_Skip	; F77A30  jr ULE,0xf77a43
	incw	1, (SmfOut_WindowsFlushed:16)	; F77A32  incw 1,(0x126c)
	ld	xwa, 6334208	; F77A36  ld XWA,0x0060a700
	ld	(InputStream_Cursor:16), xwa	; F77A3B  ld (0x1088),XWA
	ld	xix, xwa	; F77A3F  ld XIX,XWA
	ld	a, c	; F77A41  ld A,C
SmfSizeCopy_CommitOutputByte_Skip:
	ld	(InputStream_Cursor:16), xix	; F77A43  ld (0x1088),XIX
	popw	bc	; F77A47  pop BC
	pop	xhl	; F77A48  pop XHL
	ret	; F77A49  ret
; SmfSizeCopy_AgePendingNoteOffs: copy D of prom_b's SMF writer (an unreferenced copy of B), role AgePendingNoteOffs as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSizeCopy_AgePendingNoteOffs:
	calr	SmfSizeCopy_ClearDueList	; F77A4A  calr 0xf77c92
	xor	hl, hl	; F77A4D  xor HL,HL
	xor	bc, bc	; F77A4F  xor BC,BC
	xor	iy, iy	; F77A51  xor IY,IY
SmfSizeCopy_AgePendingNoteOffs_Loop:
	push	xde	; F77A53  push XDE
	ld	xde, 12378	; F77A54  ld XDE,0x0000305a
	bit	7, (xde+hl)	; F77A59  bit 7,(XDE+HL)
	pop	xde	; F77A5E  pop XDE
	jr	z, SmfSizeCopy_AgePendingNoteOffs_Join	; F77A5F  jr Z,0xf77ab5
	push	xde	; F77A61  push XDE
	ld	xde, 12378	; F77A62  ld XDE,0x0000305a
	lda	xde, (xde+hl)	; F77A67  lda XDE,XDE+HL
	ld	wa, (xde+3)	; F77A6C  ld WA,(XDE+0x03)
	pop	xde	; F77A6F  pop XDE
	cp	wa, (0x11aa:16)	; F77A70  cp WA,(0x11aa)
	jr	ule, SmfSizeCopy_AgePendingNoteOffs_Skip2	; F77A74  jr ULE,0xf77a8b
	sub	wa, (0x11aa:16)	; F77A76  sub WA,(0x11aa)
	push	xde	; F77A7A  push XDE
	ld	xde, 12378	; F77A7B  ld XDE,0x0000305a
	lda	xde, (xde+hl)	; F77A80  lda XDE,XDE+HL
	ld	(xde+3), wa	; F77A85  ld (XDE+0x03),WA
	pop	xde	; F77A88  pop XDE
	jr	SmfSizeCopy_AgePendingNoteOffs_Join	; F77A89  jr T,0xf77ab5
SmfSizeCopy_AgePendingNoteOffs_Skip2:
	push	xde	; F77A8B  push XDE
	ld	xde, 4307	; F77A8C  ld XDE,0x000010d3
	ld	(xde+iy), c	; F77A91  ld (XDE+IY),C
	ld	xde, 12378	; F77A96  ld XDE,0x0000305a
	lda	xde, (xde+hl)	; F77A9B  lda XDE,XDE+HL
	ld	wa, (xde+3)	; F77AA0  ld WA,(XDE+0x03)
	ld	xde, 4307	; F77AA3  ld XDE,0x000010d3
	lda	xde, (xde+iy)	; F77AA8  lda XDE,XDE+IY
	ld	(xde+1), wa	; F77AAD  ld (XDE+0x01),WA
	pop	xde	; F77AB0  pop XDE
	add	iy, 3	; F77AB1  add IY,0x0003
SmfSizeCopy_AgePendingNoteOffs_Join:
	add	hl, 5	; F77AB5  add HL,0x0005
	inc	1, bc	; F77AB9  inc 1,BC
	cp	c, 32	; F77ABB  cp C,0x20
	jr	ule, SmfSizeCopy_AgePendingNoteOffs_Loop	; F77ABE  jr ULE,0xf77a53
	srl	iy, 1	; F77AC0  srl 0x01,IY
	cp	iy, 0:i3	; F77AC3  cp IY,0
	jr	z, SmfSizeCopy_AgePendingNoteOffs_Skip3	; F77AC5  jr Z,0xf77aca
	calr	SmfSizeCopy_SortDueNoteOffs	; F77AC7  calr 0xf77ad7
SmfSizeCopy_AgePendingNoteOffs_Skip3:
	ldw	(4222:16), 0	; F77ACA  ld (0x107e),0x0000
	ldw	(4224:16), 0	; F77AD0  ld (0x1080),0x0000
	ret	; F77AD6  ret

; --------------------------------------------------------------------------
; SmfSizeCopy_SortDueNoteOffs
; Called from: in-module: 0xF77AC7
; Touches: (0x10D3)
; Calls:   SmfSizeCopy_WriteDueNoteOffs
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF77AD7 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSizeCopy_SortDueNoteOffs: copy D of prom_b's SMF writer (an unreferenced copy of B), role SortDueNoteOffs as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSizeCopy_SortDueNoteOffs:
	cp	iy, 0:i3	; F77AD7  cp IY,0
	jr	z, SmfSizeCopy_SortDueNoteOffs_Return	; F77AD9  jr Z,0xf77b41
	xor	de, de	; F77ADB  xor DE,DE
	cp	(0x10d3:16), 0xff	; F77ADD  cp (0x10d3),0xff
	jr	z, SmfSizeCopy_SortDueNoteOffs_Return	; F77AE2  jr Z,0xf77b41
SmfSizeCopy_SortDueNoteOffs_Loop:
	ld	xiy, 4307	; F77AE4  ld XIY,0x000010d3
	ld	xix, 4310	; F77AE9  ld XIX,0x000010d6
	lda	xiy, (xiy+de)	; F77AEE  lda XIY,XIY+DE
	lda	xix, (xix+de)	; F77AF3  lda XIX,XIX+DE
	cp	(xiy), 0xff	; F77AF8  cp (XIY),0xff
	jr	z, SmfSizeCopy_SortDueNoteOffs_Skip3	; F77AFB  jr Z,0xf77b3e
	ld	wa, (xiy+1)	; F77AFD  ld WA,(XIY+0x01)
SmfSizeCopy_SortDueNoteOffs_Join:
	ld	l, (xix)	; F77B00  ld L,(XIX)
	cp	l, 255	; F77B02  cp L,0xff
	jr	z, SmfSizeCopy_SortDueNoteOffs_Skip2	; F77B05  jr Z,0xf77b34
	cp	wa, (xix+1)	; F77B07  cp WA,(XIX+0x01)
	jr	ugt, SmfSizeCopy_SortDueNoteOffs_Skip	; F77B0A  jr UGT,0xf77b1c
	add	xix, 3	; F77B0C  add XIX,0x00000003
	cp	xix, 4496	; F77B12  cp XIX,0x00001190
	jr	ugt, SmfSizeCopy_SortDueNoteOffs_Skip2	; F77B18  jr UGT,0xf77b34
	jr	SmfSizeCopy_SortDueNoteOffs_Join	; F77B1A  jr T,0xf77b00
SmfSizeCopy_SortDueNoteOffs_Skip:
	ld	a, (xiy)	; F77B1C  ld A,(XIY)
	ld	l, (xix)	; F77B1E  ld L,(XIX)
	ld	(xiy), l	; F77B20  ld (XIY),L
	ld	(xix), a	; F77B22  ld (XIX),A
	ld	wa, (xiy+1)	; F77B24  ld WA,(XIY+0x01)
	ld	hl, (xix+1)	; F77B27  ld HL,(XIX+0x01)
	ld	(xiy+1), hl	; F77B2A  ld (XIY+0x01),HL
	ld	(xix+1), wa	; F77B2D  ld (XIX+0x01),WA
	xor	de, de	; F77B30  xor DE,DE
	jr	SmfSizeCopy_SortDueNoteOffs_Loop	; F77B32  jr T,0xf77ae4
SmfSizeCopy_SortDueNoteOffs_Skip2:
	add	de, 3	; F77B34  add DE,0x0003
	cp	de, 96	; F77B38  cp DE,0x0060
	jr	ule, SmfSizeCopy_SortDueNoteOffs_Loop	; F77B3C  jr ULE,0xf77ae4
SmfSizeCopy_SortDueNoteOffs_Skip3:
	calr	SmfSizeCopy_WriteDueNoteOffs	; F77B3E  calr 0xf77b42
SmfSizeCopy_SortDueNoteOffs_Return:
	ret	; F77B41  ret

; --------------------------------------------------------------------------
; SmfSizeCopy_WriteDueNoteOffs
; Called from: in-module: 0xF77B3E
; Touches: (0x107E) (0x1080) (0x1082) (0x1090) (0x11AA)
; Calls:   SmfSizeCopy_EncodeVlq SmfSizeCopy_WriteChannelEvent
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF77B42 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSizeCopy_WriteDueNoteOffs: copy D of prom_b's SMF writer (an unreferenced copy of B), role WriteDueNoteOffs as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSizeCopy_WriteDueNoteOffs:
	ld	bc, (4226:16)	; F77B42  ld BC,(0x1082)
	ld	xiy, 4307	; F77B46  ld XIY,0x000010d3
	xor	hl, hl	; F77B4B  xor HL,HL
SmfSizeCopy_WriteDueNoteOffs_Join:
	ld	a, (xiy+hl)	; F77B4D  ld A,(XIY+HL)
	cp	a, 255	; F77B52  cp A,0xff
	jr	z, SmfSizeCopy_WriteDueNoteOffs_Skip2	; F77B55  jr Z,0xf77bb9
	xor	w, w	; F77B57  xor W,W
	ld	ix, wa	; F77B59  ld IX,WA
	sla	ix, 2	; F77B5B  sla 0x02,IX
	add	ix, wa	; F77B5E  add IX,WA
	extz	xix	; F77B60  extz XIX
	push	xde	; F77B62  push XDE
	ld	xde, 12378	; F77B63  ld XDE,0x0000305a
	add	xde, xix	; F77B68  add XDE,XIX
	ld	wa, (xde+3)	; F77B6A  ld WA,(XDE+0x03)
	pop	xde	; F77B6D  pop XDE
	cp	l, 0:i3	; F77B6E  cp L,0
	jr	nz, SmfSizeCopy_WriteDueNoteOffs_Skip	; F77B70  jr NZ,0xf77b78
	ld	(4522:16), wa	; F77B72  ld (0x11aa),WA
	jr	SmfSizeCopy_WriteDueNoteOffs_Join2	; F77B76  jr T,0xf77b82
SmfSizeCopy_WriteDueNoteOffs_Skip:
	ld	de, wa	; F77B78  ld DE,WA
	sub	de, (0x1082:16)	; F77B7A  sub DE,(0x1082)
	ld	(4522:16), de	; F77B7E  ld (0x11aa),DE
SmfSizeCopy_WriteDueNoteOffs_Join2:
	pushw	wa	; F77B82  push WA
	push	xhl	; F77B83  push XHL
	pushw	bc	; F77B84  push BC
	push	xix	; F77B85  push XIX
	calr	SmfSizeCopy_EncodeVlq	; F77B86  calr 0xf77bdf
	pop	xix	; F77B89  pop XIX
	popw	bc	; F77B8A  pop BC
	pop	xhl	; F77B8B  pop XHL
	popw	wa	; F77B8C  pop WA
	ld	(4226:16), wa	; F77B8D  ld (0x1082),WA
	push	xde	; F77B91  push XDE
	ld	xde, 12378	; F77B92  ld XDE,0x0000305a
	add	xde, xix	; F77B97  add XDE,XIX
	ld	wa, (xde+1)	; F77B99  ld WA,(XDE+0x01)
	push	xhl	; F77B9C  push XHL
	ld	l, 0:opc	; F77B9D  ld L,0x00
	pushw	bc	; F77B9F  push BC
	push	xix	; F77BA0  push XIX
	calr	SmfSizeCopy_WriteChannelEvent	; F77BA1  calr 0xf779d5
	pop	xix	; F77BA4  pop XIX
	popw	bc	; F77BA5  pop BC
	pop	xhl	; F77BA6  pop XHL
	ld	xde, 12378	; F77BA7  ld XDE,0x0000305a
	and	(xde+ix), 0x3f	; F77BAC  and (XDE+IX),0x3f
	pop	xde	; F77BB2  pop XDE
	add	hl, 3	; F77BB3  add HL,0x0003
	jr	SmfSizeCopy_WriteDueNoteOffs_Join	; F77BB7  jr T,0xf77b4d
SmfSizeCopy_WriteDueNoteOffs_Skip2:
	ld	wa, (4226:16)	; F77BB9  ld WA,(0x1082)
	add	wa, (0x1090:16)	; F77BBD  add WA,(0x1090)
	ld	(4226:16), bc	; F77BC1  ld (0x1082),BC
	add	bc, (0x107e:16)	; F77BC5  add BC,(0x107e)
	sub	bc, wa	; F77BC9  sub BC,WA
	ld	(4522:16), bc	; F77BCB  ld (0x11aa),BC
	calr	SmfSizeCopy_EncodeVlq	; F77BCF  calr 0xf77bdf
	ldw	(4222:16), 0	; F77BD2  ld (0x107e),0x0000
	ldw	(4224:16), 0	; F77BD8  ld (0x1080),0x0000
	ret	; F77BDE  ret

; --------------------------------------------------------------------------
; SmfSizeCopy_EncodeVlq
; Called from: in-module: 0xF77B86 0xF77BCF
; Touches: (0x1193) (0x1194) (0x1195) (0x11AA) (0x11AB) (0x11AC)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF77BDF is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSizeCopy_EncodeVlq: copy D of prom_b's SMF writer (an unreferenced copy of B), role EncodeVlq as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSizeCopy_EncodeVlq:
	ldw	(Smf_VlqBytes:16), 0	; F77BDF  ld (0x1193),0x0000
	ldw	(4501:16), 0	; F77BE5  ld (0x1195),0x0000
	cp	(0x11ac:16), 0x00	; F77BEB  cp (0x11ac),0x00
	jr	nz, SmfSizeCopy_EncodeVlq_Skip	; F77BF0  jr NZ,0xf77c03
	cpw	(0x11aa:16), 0x007f	; F77BF2  cp (0x11aa),0x007f
	jrl	ule, SmfSizeCopy_EncodeVlq_Skip4	; F77BF8  jrl ULE,0xf77c82
	cpw	(0x11aa:16), 0x3fff	; F77BFB  cp (0x11aa),0x3fff
	jr	ule, SmfSizeCopy_EncodeVlq_Skip3	; F77C01  jr ULE,0xf77c59
SmfSizeCopy_EncodeVlq_Skip:
	cp	(0x11ac:16), 0x1f	; F77C03  cp (0x11ac),0x1f
	jr	ule, SmfSizeCopy_EncodeVlq_Skip2	; F77C08  jr ULE,0xf77c19
	ld	(4524:16), 31	; F77C0A  ld (0x11ac),0x1f
	ld	(4523:16), 255	; F77C0F  ld (0x11ab),0xff
	ld	(4522:16), 255	; F77C14  ld (0x11aa),0xff
SmfSizeCopy_EncodeVlq_Skip2:
	ld	a, (4522:16)	; F77C19  ld A,(0x11aa)
	ld	w, a	; F77C1D  ld W,A
	and	w, 128	; F77C1F  and W,0x80
	and	a, 127	; F77C22  and A,0x7f
	rlc	w	; F77C25  rlc 0x01,W
	ld	l, (4523:16)	; F77C28  ld L,(0x11ab)
	ld	h, l	; F77C2C  ld H,L
	and	h, 192	; F77C2E  and H,0xc0
	.byte 0xCE, 0xE8, 0x02	; F77C31  rlc 0x02,H   [llvm-mc cannot encode this]
	sla	l, 1	; F77C34  sla 0x01,L
	and	l, 1	; F77C37  and L,0x01
	or	l, w	; F77C3A  or L,W
	or	l, 128	; F77C3C  or L,0x80
	ld	c, (4524:16)	; F77C3F  ld C,(0x11ac)
	sla	c, 2	; F77C43  sla 0x02,C
	or	c, h	; F77C46  or C,H
	or	c, 128	; F77C48  or C,0x80
	ld	(Smf_VlqBytes:16), c	; F77C4B  ld (0x1193),C
	ld	(4500:16), l	; F77C4F  ld (0x1194),L
	ld	(4501:16), a	; F77C53  ld (0x1195),A
	jr	SmfSizeCopy_EncodeVlq_Return	; F77C57  jr T,0xf77c91
SmfSizeCopy_EncodeVlq_Skip3:
	ld	a, (4522:16)	; F77C59  ld A,(0x11aa)
	ld	w, a	; F77C5D  ld W,A
	and	a, 127	; F77C5F  and A,0x7f
	and	w, 128	; F77C62  and W,0x80
	rlc	w	; F77C65  rlc 0x01,W
	ld	l, (4523:16)	; F77C68  ld L,(0x11ab)
	ld	h, l	; F77C6C  ld H,L
	sla	l, 1	; F77C6E  sla 0x01,L
	or	l, w	; F77C71  or L,W
	or	l, 128	; F77C73  or L,0x80
	xor	c, c	; F77C76  xor C,C
	ld	(Smf_VlqBytes:16), l	; F77C78  ld (0x1193),L
	ld	(4500:16), a	; F77C7C  ld (0x1194),A
	jr	SmfSizeCopy_EncodeVlq_Return	; F77C80  jr T,0xf77c91
SmfSizeCopy_EncodeVlq_Skip4:
	ld	a, (4522:16)	; F77C82  ld A,(0x11aa)
	and	a, 127	; F77C86  and A,0x7f
	xor	l, l	; F77C89  xor L,L
	xor	c, c	; F77C8B  xor C,C
	ld	(Smf_VlqBytes:16), a	; F77C8D  ld (0x1193),A
SmfSizeCopy_EncodeVlq_Return:
	ret	; F77C91  ret

; --------------------------------------------------------------------------
; SmfSizeCopy_ClearDueList
; Called from: in-module: 0xF77A4A
; Touches: (0x126E) (0x345C) (0x345E)
; Calls:   0xF75095 InputStream_OpenAndReadFirstBlock_Copy InputStream_Refill_Copy InputStream_RefillDone_Copy
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF77C92 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfSizeCopy_ClearDueList: copy D of prom_b's SMF writer (an unreferenced copy of B), role ClearDueList as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSizeCopy_ClearDueList:
	push	xix	; F77C92  push XIX
	ld	xix, 4307	; F77C93  ld XIX,0x000010d3
	ldw	bc, 96	; F77C98  ld BC,0x0060
	ldw	wa, 255	; F77C9B  ld WA,0x00ff
	ld	(xix+), a	; F77C9E  ld (XIX+),A
	djnz16	bc, -6	; F77CA1  djnz BC,0xf77c9e
	pop	xix	; F77CA4  pop XIX
	ret	; F77CA5  ret
; SmfSizeCopy_ClearEventFields: copy D of prom_b's SMF writer (an unreferenced copy of B), role ClearEventFields as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSizeCopy_ClearEventFields:
	ld	xix, Smf_VlqValue	; F77CA6  ld XIX,0x00001198
	xor	wa, wa	; F77CAB  xor WA,WA
	ldw	bc, 4	; F77CAD  ld BC,0x0004
	ld	(xix+), wa	; F77CB0  ld (XIX+),WA
	djnz16	bc, -6	; F77CB3  djnz BC,0xf77cb0
	ret	; F77CB6  ret
; SmfSizeCopy_ReadSongByte: copy D of prom_b's SMF writer (an unreferenced copy of B), role ReadSongByte as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSizeCopy_ReadSongByte:
	ld	hl, (BStore_CursorBlock:16)	; F77CB7  ld HL,(0x345c)
	calr	SmfExport_ParamSysExTemplates + 0xC6	; F77CBB  calr 0xf75095  (lands inside record 10 at +8; see SmfExport_ParamSysExTemplates)
	ld	iy, (BStore_CursorOffset:16)	; F77CBE  ld IY,(0x345e)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F77CC2  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F77CC6  ld A,(XHL+IY)
	ret	; F77CCB  ret
; SmfSizeCopy_AdvanceSongCursor: copy D of prom_b's SMF writer (an unreferenced copy of B), role AdvanceSongCursor as its docstring reads it from the body -- notes/prom_b_smf_writer_names.py
SmfSizeCopy_AdvanceSongCursor:
	ld	wa, (BStore_CursorOffset:16)	; F77CCC  ld WA,(0x345e)
	cp	wa, 255	; F77CD0  cp WA,0x00ff
	jr	nz, SmfSizeCopy_AdvanceSongCursor_Skip	; F77CD4  jr NZ,0xf77ced
	ld	hl, (BStore_CursorBlock:16)	; F77CD6  ld HL,(0x345c)
	calr	SmfExport_ParamSysExTemplates + 0xC6	; F77CDA  calr 0xf75095  (lands inside record 10 at +8; see SmfExport_ParamSysExTemplates)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F77CDD  ld XHL,(0x126e)
	ld	wa, (xhl+3)	; F77CE1  ld WA,(XHL+0x03)
	ld	(BStore_CursorBlock:16), wa	; F77CE4  ld (0x345c),WA
	ldw	wa, 5	; F77CE8  ld WA,0x0005
	jr	SmfSizeCopy_AdvanceSongCursor_Join	; F77CEB  jr T,0xf77cef
SmfSizeCopy_AdvanceSongCursor_Skip:
	inc	1, wa	; F77CED  inc 1,WA
SmfSizeCopy_AdvanceSongCursor_Join:
	ld	(BStore_CursorOffset:16), wa	; F77CEF  ld (0x345e),WA
	ret	; F77CF3  ret
	calr	InputStream_OpenAndReadFirstBlock_Copy	; F77CF4  calr 0xf77d00
	ret	; F77CF7  ret
	calr	InputStream_Refill_Copy	; F77CF8  calr 0xf77d39
	ret	; F77CFB  ret
	calr	InputStream_RefillDone_Copy	; F77CFC  calr 0xf77d43
	ret	; F77CFF  ret

; --------------------------------------------------------------------------
; InputStream_OpenAndReadFirstBlock_Copy
; Called from: in-module: 0xF77CF4
; Touches: (0x21D0) (0x21D1) (0x21D2) (0x21D3) (0x21D7) (0x21E7)  |
;          0x60A700 0x60AB00
; Calls:   T_DiskApi_ReadFileToWindow_Entry
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF77D00 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; InputStream_OpenAndReadFirstBlock_Copy: an exact copy of InputStream_OpenAndReadFirstBlock (prom_b 0xF7659B) -- all 14 instructions equal, operands included,
;   but the targets of its jr / jrl / djnz (notes/wsa1_exact_copy_names.py).
InputStream_OpenAndReadFirstBlock_Copy:
	or	(Disk_Flags:16), 0x80	; F77D00  or (0x21e7),0x80
	cp	l, 1:i3	; F77D05  cp L,1
	jr	z, InputStream_OpenAndReadFirstBlock_Copy_Skip	; F77D07  jr Z,0xf77d18
	ld	(Disk_FileName+8:16), 77	; F77D09  ld (0x21d0),0x4d
	ld	(Disk_FileName+9:16), 73	; F77D0E  ld (0x21d1),0x49
	ld	(Disk_FileName+10:16), 68	; F77D13  ld (0x21d2),0x44
InputStream_OpenAndReadFirstBlock_Copy_Skip:
	ld	xwa, 6334208	; F77D18  ld XWA,0x0060a700
	ld	(Disk_WindowStart:16), xwa	; F77D1D  ld (0x21d3),XWA
	ld	xwa, 6335232	; F77D21  ld XWA,0x0060ab00
	ld	(Disk_WindowEnd:16), xwa	; F77D26  ld (0x21d7),XWA
	or	(Disk_Flags:16), 0x20	; F77D2A  or (0x21e7),0x20
	call	T_DiskApi_ReadFileToWindow_Entry	; F77D2F  call 0xf425a8
	and	(Disk_Flags:16), 0xdf	; F77D33  and (0x21e7),0xdf
	ret	; F77D38  ret

; --------------------------------------------------------------------------
; InputStream_Refill_Copy
; Called from: in-module: 0xF77CF8
; Touches: (0x21E7)
; Calls:   T_DiskApi_ReadFileToWindow_Entry
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF77D39 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; InputStream_Refill_Copy: Disk_Flags |= 0x02 then T_DiskApi_ReadFileToWindow_Entry -- an exact copy of
;   InputStream_Refill in the unreferenced SMF writer copy D, reached only through the veneer `calr / ret` at 0xF77CF8
;   that sits where copy B's veneer to InputStream_Refill sits. Basis: veneer position + body (exact copy).
;   (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
InputStream_Refill_Copy:
	or	(Disk_Flags:16), 0x02	; F77D39  or (0x21e7),0x02
	call	T_DiskApi_ReadFileToWindow_Entry	; F77D3E  call 0xf425a8
	ret	; F77D42  ret

; --------------------------------------------------------------------------
; InputStream_RefillDone_Copy
; Called from: in-module: 0xF77CFC
; Touches: (0x10C5) (0x10C6) (0x10C7) (0x21E7)
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF77D43 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; InputStream_RefillDone_Copy: Clears Disk_Flags bit 1 and returns W = 1 -- an exact copy of InputStream_RefillDone in
;   the unreferenced SMF writer copy D, reached only through the veneer `calr / ret` at 0xF77CFC that sits where copy
;   B's veneer to InputStream_RefillDone sits. Basis: veneer position + body (exact copy). (notes/naming-
;   pilot-2026-10-06/proposals_wave7_z.json)
InputStream_RefillDone_Copy:
	and	(Disk_Flags:16), 0xfd	; F77D43  and (0x21e7),0xfd
	ld	w, 1:opc	; F77D48  ld W,0x01
	ret	; F77D4A  ret
; SmfOut_CreateFileWithFirstWindow: Copy of SmfWrite_CreateFileWithFirstWindow: checks free space for
;   SmfOut_TrackLength + 22 (>> 4, T_DiskSave_CheckFreeSpace); if OK sets extension 'MID', deletes the old file, sets
;   Disk_Flags bit 7, then SmfWriteCopy_SetOutputWindow (window set-up) and SmfWriteCopy_WriteFirstWindow (first-window write); A = the disk result.
;   SmfWriteCopy_CommitOutputByte calls it for the first window. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_d9.json)
SmfOut_CreateFileWithFirstWindow:
	xor	de, de	; F77D4B  xor DE,DE
	ld	d, (SmfOut_TrackLength+1:16)	; F77D4D  ld D,(0x10c5)
	ld	w, (SmfOut_TrackLength+2:16)	; F77D51  ld W,(0x10c6)
	ld	a, (SmfOut_TrackLength+3:16)	; F77D55  ld A,(0x10c7)
	add	wa, 22	; F77D59  add WA,0x0016
	jr	nov, SmfOut_CreateFileWithFirstWindow_Skip	; F77D5D  jr PO/NOV,0xf77d61

; --------------------------------------------------------------------------
; REACHED CODE, not data (was `Data_F77D5F`), part of SmfOut_CreateFileWithFirstWindow:
;   the overflow arm of `jr nov` at 0xF77D5D; the same two bytes as 0xF765FA.
; --------------------------------------------------------------------------
	inc	1, d	; F77D5F  inc 1,D

SmfOut_CreateFileWithFirstWindow_Skip:
	srl	wa, 4	; F77D61  srl 0x04,WA
	sla	de, 4	; F77D64  sla 0x04,DE
	and	de, 61440	; F77D67  and DE,0xf000
	and	wa, 4095	; F77D6B  and WA,0x0fff
	or	wa, de	; F77D6F  or WA,DE
	ld	bc, wa	; F77D71  ld BC,WA
	ld	(8773:16), bc	; F77D73  ld (0x2245),BC
	call	T_DiskSave_CheckFreeSpace	; F77D77  call 0xf425e8
	ld	w, (Disk_LastError:16)	; F77D7B  ld W,(0x2243)
	cp	w, 0:i3	; F77D7F  cp W,0
	jr	nz, SmfOut_CreateFileWithFirstWindow_Return	; F77D81  jr NZ,0xf77db2
	ld	(Disk_FileName+8:16), 77	; F77D83  ld (0x21d0),0x4d
	ld	(Disk_FileName+9:16), 73	; F77D88  ld (0x21d1),0x49
	ld	(Disk_FileName+10:16), 68	; F77D8D  ld (0x21d2),0x44
	call	T_DiskApi_DeleteFile_Call	; F77D92  call 0xf425b0
	or	(Disk_Flags:16), 0x80	; F77D96  or (0x21e7),0x80
	ld	(Disk_FileName+8:16), 77	; F77D9B  ld (0x21d0),0x4d
	ld	(Disk_FileName+9:16), 73	; F77DA0  ld (0x21d1),0x49
	ld	(Disk_FileName+10:16), 68	; F77DA5  ld (0x21d2),0x44
	call	SmfWriteCopy_SetOutputWindow	; F77DAA  call 0xf77def
	call	SmfWriteCopy_WriteFirstWindow	; F77DAE  call 0xf77db3
SmfOut_CreateFileWithFirstWindow_Return:
	ret	; F77DB2  ret

; --------------------------------------------------------------------------
; SmfWriteCopy_WriteFirstWindow
; Called from: in-module: 0xF77DAE
; Touches: (0x126C) (0x21E7) (0x2243)
; Calls:   T_DiskApi_WriteFileFromWindow_Entry T_DiskApi_CloseFile_Call
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF77DB3 is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWriteCopy_WriteFirstWindow: Disk_Flags |= 0x20, T_DiskApi_WriteFileFromWindow_Entry, A := Disk_LastError, the
;   flag cleared again: writes the first 1,024-byte window of the .MID file; byte-identical to copy A's
;   SmfWrite_WriteFirstWindow. SmfOut_CreateFileWithFirstWindow, reached only from copy C (SmfWriteCopy_*), runs it
;   last. SmfWrite_WriteFirstWindow_Copy2 (0xF77F9A) is a third identical copy, in the unreached copy E. Basis: caller + body +
;   twin. (notes/naming-pilot-2026-10-06/proposals_wave10_b10.json)
SmfWriteCopy_WriteFirstWindow:
	or	(Disk_Flags:16), 0x20	; F77DB3  or (0x21e7),0x20
	call	T_DiskApi_WriteFileFromWindow_Entry	; F77DB8  call 0xf425ac
	ld	a, (Disk_LastError:16)	; F77DBC  ld A,(0x2243)
	and	(Disk_Flags:16), 0xdf	; F77DC0  and (0x21e7),0xdf
	ret	; F77DC5  ret
; SmfOut_WriteNextWindow: Copy of SmfWrite_WriteNextWindow: Disk_Flags |= 0x02, T_DiskApi_WriteFileFromWindow_Entry, A
;   := Disk_LastError -- writes a further 1,024-byte window of the .MID file. SmfWriteCopy_CommitOutputByte calls it
;   once a window was already flushed. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_d9.json)
SmfOut_WriteNextWindow:
	or	(Disk_Flags:16), 0x02	; F77DC6  or (0x21e7),0x02
	call	T_DiskApi_WriteFileFromWindow_Entry	; F77DCB  call 0xf425ac
	ld	a, (Disk_LastError:16)	; F77DCF  ld A,(0x2243)
	ret	; F77DD3  ret
; SmfOut_WriteLastWindowAndClose: when SmfOut_WindowsFlushed is non-zero: Disk_Flags bit 1 set, T_DiskApi_WriteFileFromWindow_Entry; then Disk_Flags
;   bit 1 cleared and T_DiskApi_CloseFile_Call; called from sub_F7669D.  Basis: body.
SmfOut_WriteLastWindowAndClose:
	cpw	(SmfOut_WindowsFlushed:16), 0x0000	; F77DD4  cp (0x126c),0x0000
	jr	z, SmfOut_WriteLastWindowAndClose_Skip	; F77DDA  jr Z,0xf77de5
	or	(Disk_Flags:16), 0x02	; F77DDC  or (0x21e7),0x02
	call	T_DiskApi_WriteFileFromWindow_Entry	; F77DE1  call 0xf425ac
SmfOut_WriteLastWindowAndClose_Skip:
	and	(Disk_Flags:16), 0xfd	; F77DE5  and (0x21e7),0xfd
	call	T_DiskApi_CloseFile_Call	; F77DEA  call 0xf425e4
	ret	; F77DEE  ret

; --------------------------------------------------------------------------
; SmfWriteCopy_SetOutputWindow
; Called from: in-module: 0xF77DAA
; Touches: (0x1193) (0x1194) (0x1195) (0x11AA) (0x11AB) (0x11AC) (0x126E)
;          (0x21D3) (0x21D7) (0x345C) +1 more  |  0x60A700 0x60AB00
; Calls:   0xF752DF InputStream_OpenAndReadFirstBlock_Copy2 InputStream_Refill_Copy2 InputStream_RefillDone_Copy2
; Evidence (CALL): an opcode-anchored `call`/`jp addr24` in prom_a or prom_b
;                  targets it.  The scan is at every byte offset, so a hit
;                  is an upper bound on the CALL COUNT -- but a hit that
;                  decodes is still a real instruction.  0xF77DEF is an
;                  instruction boundary of this transcription, re-asserted
;                  on every emit.  The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SmfWriteCopy_SetOutputWindow: Disk_WindowStart := 0x60A700, Disk_WindowEnd := 0x60AB00 -- the 1,024-byte output
;   window; byte-identical to copy A's SmfWrite_SetOutputWindow. SmfOut_CreateFileWithFirstWindow sets it just before
;   SmfWriteCopy_WriteFirstWindow. The bytes after its `ret` (0xF77E02-0xF77E78) are a separate unreached fragment.
;   Basis: caller + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave10_b10.json)
SmfWriteCopy_SetOutputWindow:
	ld	xwa, 6334208	; F77DEF  ld XWA,0x0060a700
	ld	(Disk_WindowStart:16), xwa	; F77DF4  ld (0x21d3),XWA
	ld	xwa, 6335232	; F77DF8  ld XWA,0x0060ab00
	ld	(Disk_WindowEnd:16), xwa	; F77DFD  ld (0x21d7),XWA
	ret	; F77E01  ret
	scf	; F77E02  scf
	ld	a, 201:opc	; F77E03  ld A,0xc9
	and	(xwa-56), d	; F77E05  and (XWA+0xc8),D
	and	(xwa), a	; F77E08  and (XWA),A
	scc	nc, d	; F77E0A  scc NC,D
	rlc	w	; F77E0C  rlc 0x01,W
	ld	l, (4523:16)	; F77E0F  ld L,(0x11ab)
	ld	h, l	; F77E13  ld H,L
	and	h, 192	; F77E15  and H,0xc0
	.byte 0xCE, 0xE8, 0x02	; F77E18  rlc 0x02,H   [llvm-mc cannot encode this]
	sla	l, 1	; F77E1B  sla 0x01,L
	and	l, 1	; F77E1E  and L,0x01
	or	l, w	; F77E21  or L,W
	or	l, 128	; F77E23  or L,0x80
	ld	c, (4524:16)	; F77E26  ld C,(0x11ac)
	sla	c, 2	; F77E2A  sla 0x02,C
	or	c, h	; F77E2D  or C,H
	or	c, 128	; F77E2F  or C,0x80
	ld	(Smf_VlqBytes:16), c	; F77E32  ld (0x1193),C
	ld	(4500:16), l	; F77E36  ld (0x1194),L
	ld	(4501:16), a	; F77E3A  ld (0x1195),A
	jr	SmfWriteCopy_SetOutputWindow_Return	; F77E3E  jr T,0xf77e78
	ld	a, (4522:16)	; F77E40  ld A,(0x11aa)
	ld	w, a	; F77E44  ld W,A
	and	a, 127	; F77E46  and A,0x7f
	and	w, 128	; F77E49  and W,0x80
	rlc	w	; F77E4C  rlc 0x01,W
	ld	l, (4523:16)	; F77E4F  ld L,(0x11ab)
	ld	h, l	; F77E53  ld H,L
	sla	l, 1	; F77E55  sla 0x01,L
	or	l, w	; F77E58  or L,W
	or	l, 128	; F77E5A  or L,0x80
	xor	c, c	; F77E5D  xor C,C
	ld	(Smf_VlqBytes:16), l	; F77E5F  ld (0x1193),L
	ld	(4500:16), a	; F77E63  ld (0x1194),A
	jr	SmfWriteCopy_SetOutputWindow_Return	; F77E67  jr T,0xf77e78
	ld	a, (4522:16)	; F77E69  ld A,(0x11aa)
	and	a, 127	; F77E6D  and A,0x7f
	xor	l, l	; F77E70  xor L,L
	xor	c, c	; F77E72  xor C,C
	ld	(Smf_VlqBytes:16), a	; F77E74  ld (0x1193),A
SmfWriteCopy_SetOutputWindow_Return:
	ret	; F77E78  ret
	push	xix	; F77E79  push XIX
	ld	xix, 4307	; F77E7A  ld XIX,0x000010d3
	ldw	bc, 96	; F77E7F  ld BC,0x0060
	ldw	wa, 255	; F77E82  ld WA,0x00ff
	ld	(xix+), a	; F77E85  ld (XIX+),A
	djnz16	bc, -6	; F77E88  djnz BC,0xf77e85
	pop	xix	; F77E8B  pop XIX
	ret	; F77E8C  ret
	ld	xix, Smf_VlqValue	; F77E8D  ld XIX,0x00001198
	xor	wa, wa	; F77E92  xor WA,WA
	ldw	bc, 4	; F77E94  ld BC,0x0004
	ld	(xix+), wa	; F77E97  ld (XIX+),WA
	djnz16	bc, -6	; F77E9A  djnz BC,0xf77e97
	ret	; F77E9D  ret
	ld	hl, (BStore_CursorBlock:16)	; F77E9E  ld HL,(0x345c)
	calr	SmfExport_ParamSysExTemplates + 0x310	; F77EA2  calr 0xf752df  (lands inside record 41 at +5; see SmfExport_ParamSysExTemplates)
	ld	iy, (BStore_CursorOffset:16)	; F77EA5  ld IY,(0x345e)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F77EA9  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F77EAD  ld A,(XHL+IY)
	ret	; F77EB2  ret
	ld	wa, (BStore_CursorOffset:16)	; F77EB3  ld WA,(0x345e)
	cp	wa, 255	; F77EB7  cp WA,0x00ff
	jr	nz, SmfWriteCopy_SetOutputWindow_Skip	; F77EBB  jr NZ,0xf77ed4
	ld	hl, (BStore_CursorBlock:16)	; F77EBD  ld HL,(0x345c)
	calr	SmfExport_ParamSysExTemplates + 0x310	; F77EC1  calr 0xf752df  (lands inside record 41 at +5; see SmfExport_ParamSysExTemplates)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F77EC4  ld XHL,(0x126e)
	ld	wa, (xhl+3)	; F77EC8  ld WA,(XHL+0x03)
	ld	(BStore_CursorBlock:16), wa	; F77ECB  ld (0x345c),WA
	ldw	wa, 5	; F77ECF  ld WA,0x0005
	jr	SmfWriteCopy_SetOutputWindow_Join	; F77ED2  jr T,0xf77ed6
SmfWriteCopy_SetOutputWindow_Skip:
	inc	1, wa	; F77ED4  inc 1,WA
SmfWriteCopy_SetOutputWindow_Join:
	ld	(BStore_CursorOffset:16), wa	; F77ED6  ld (0x345e),WA
	ret	; F77EDA  ret
	calr	InputStream_OpenAndReadFirstBlock_Copy2	; F77EDB  calr 0xf77ee7
	ret	; F77EDE  ret
	calr	InputStream_Refill_Copy2	; F77EDF  calr 0xf77f20
	ret	; F77EE2  ret
	calr	InputStream_RefillDone_Copy2	; F77EE3  calr 0xf77f2a
	ret	; F77EE6  ret

; --------------------------------------------------------------------------
; InputStream_OpenAndReadFirstBlock_Copy2
; Called from: in-module: 0xF77EDB
; Touches: (0x21D0) (0x21D1) (0x21D2) (0x21D3) (0x21D7) (0x21E7)  |
;          0x60A700 0x60AB00
; Calls:   T_DiskApi_ReadFileToWindow_Entry
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF77EE7 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; InputStream_OpenAndReadFirstBlock_Copy2: an exact copy of InputStream_OpenAndReadFirstBlock (prom_b 0xF7659B) -- all 14 instructions equal, operands included,
;   but the targets of its jr / jrl / djnz (notes/wsa1_exact_copy_names.py).
InputStream_OpenAndReadFirstBlock_Copy2:
	or	(Disk_Flags:16), 0x80	; F77EE7  or (0x21e7),0x80
	cp	l, 1:i3	; F77EEC  cp L,1
	jr	z, InputStream_OpenAndReadFirstBlock_Copy2_Skip	; F77EEE  jr Z,0xf77eff
	ld	(Disk_FileName+8:16), 77	; F77EF0  ld (0x21d0),0x4d
	ld	(Disk_FileName+9:16), 73	; F77EF5  ld (0x21d1),0x49
	ld	(Disk_FileName+10:16), 68	; F77EFA  ld (0x21d2),0x44
InputStream_OpenAndReadFirstBlock_Copy2_Skip:
	ld	xwa, 6334208	; F77EFF  ld XWA,0x0060a700
	ld	(Disk_WindowStart:16), xwa	; F77F04  ld (0x21d3),XWA
	ld	xwa, 6335232	; F77F08  ld XWA,0x0060ab00
	ld	(Disk_WindowEnd:16), xwa	; F77F0D  ld (0x21d7),XWA
	or	(Disk_Flags:16), 0x20	; F77F11  or (0x21e7),0x20
	call	T_DiskApi_ReadFileToWindow_Entry	; F77F16  call 0xf425a8
	and	(Disk_Flags:16), 0xdf	; F77F1A  and (0x21e7),0xdf
	ret	; F77F1F  ret

; --------------------------------------------------------------------------
; InputStream_Refill_Copy2
; Called from: in-module: 0xF77EDF
; Touches: (0x21E7)
; Calls:   T_DiskApi_ReadFileToWindow_Entry
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF77F20 is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; InputStream_Refill_Copy2: Disk_Flags |= 0x02 then T_DiskApi_ReadFileToWindow_Entry -- an exact copy of
;   InputStream_Refill in the unreferenced SMF writer copy after SmfWriteCopy_SetOutputWindow, reached only through
;   the veneer `calr / ret` at 0xF77EDF, which sits where copy D's veneer to InputStream_Refill_Copy sits (0xF77CF8).
;   Basis: veneer position + body (exact copy) + twin. (notes/naming-pilot-2026-10-06/proposals_wave11_a11.json)
InputStream_Refill_Copy2:
	or	(Disk_Flags:16), 0x02	; F77F20  or (0x21e7),0x02
	call	T_DiskApi_ReadFileToWindow_Entry	; F77F25  call 0xf425a8
	ret	; F77F29  ret

; --------------------------------------------------------------------------
; InputStream_RefillDone_Copy2
; Called from: in-module: 0xF77EE3
; Touches: (0x10C5) (0x10C6) (0x10C7) (0x21D0) (0x21D1) (0x21D2) (0x21E7)
;          (0x2243) (0x2245)
; Calls:   T_DiskSave_CheckFreeSpace T_DiskApi_DeleteFile_Call SmfWrite_SetOutputWindow_Copy2 SmfWrite_WriteFirstWindow_Copy2
; Evidence (BRANCH): a branch decoded inside this block targets it, and the
;                    block's own code is reached from the grades above.
;                    0xF77F2A is an instruction boundary of this
;                    transcription, re-asserted on every emit.  The name IS
;                    the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; InputStream_RefillDone_Copy2: Clears Disk_Flags bit 1 and returns W = 1 -- an exact copy of InputStream_RefillDone,
;   reached only through the veneer at 0xF77EE3 (copy D's twin veneer at 0xF77CFC calls InputStream_RefillDone_Copy).
;   The bytes after its ret (0xF77F32-0xF77F99) are SmfWrite_CreateFileWithFirstWindow_Copy2, a separate unreached
;   copy of SmfOut_CreateFileWithFirstWindow. Basis: veneer position + body (exact copy) + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_a11.json)
InputStream_RefillDone_Copy2:
	and	(Disk_Flags:16), 0xfd	; F77F2A  and (0x21e7),0xfd
	ld	w, 1:opc	; F77F2F  ld W,0x01
	ret	; F77F31  ret
; SmfWrite_CreateFileWithFirstWindow_Copy2: copy E's SmfWrite_CreateFileWithFirstWindow -- instruction for instruction
;   SmfOut_CreateFileWithFirstWindow (copy D), except that it calls copy E's own SmfWrite_SetOutputWindow_Copy2 and
;   SmfWrite_WriteFirstWindow_Copy2.  Free-space check for SmfOut_TrackLength + 22, extension 'MID', delete, Disk_Flags
;   bit 7, window, first window.  Was unlabelled after InputStream_RefillDone_Copy2 (kn5000-wxn).
;   COPY E: 0xF77EE7-0xF77FE8 is a third copy of the SMF writer's file layer -- copy A InputStream_OpenAndReadFirstBlock
;   (0xF7659B) .. SmfWrite_SetOutputWindow, copy D InputStream_OpenAndReadFirstBlock_Copy (0xF77D00) .., every routine at
;   the same offset (+0x00 / +0x39 / +0x43 / +0x4B / +0xB3 / +0xC6 / +0xD4 / +0xEF).  Nothing outside it reaches it:
;   its only callers are its own internal calls and the three veneers at 0xF77EDB / 0xF77EDF / 0xF77EE3, which nothing
;   calls (no call, calr, jp, jr or 24-bit operand in prom_a or prom_b; notes/open6-kn5000-d/wsa1/probes/wsa1_wxn_refs.py).
SmfWrite_CreateFileWithFirstWindow_Copy2:
	xor	de, de	; F77F32  xor DE,DE
	ld	d, (SmfOut_TrackLength+1:16)	; F77F34  ld D,(0x10c5)
	ld	w, (SmfOut_TrackLength+2:16)	; F77F38  ld W,(0x10c6)
	ld	a, (SmfOut_TrackLength+3:16)	; F77F3C  ld A,(0x10c7)
	add	wa, 22	; F77F40  add WA,0x0016
	jr	nov, SmfWrite_CreateFileWithFirstWindow_Copy2_Skip	; F77F44  jr PO/NOV,0xf77f48
	inc	1, d	; F77F46  inc 1,D
SmfWrite_CreateFileWithFirstWindow_Copy2_Skip:
	srl	wa, 4	; F77F48  srl 0x04,WA
	sla	de, 4	; F77F4B  sla 0x04,DE
	and	de, 61440	; F77F4E  and DE,0xf000
	and	wa, 4095	; F77F52  and WA,0x0fff
	or	wa, de	; F77F56  or WA,DE
	ld	bc, wa	; F77F58  ld BC,WA
	ld	(8773:16), bc	; F77F5A  ld (0x2245),BC
	call	T_DiskSave_CheckFreeSpace	; F77F5E  call 0xf425e8
	ld	w, (Disk_LastError:16)	; F77F62  ld W,(0x2243)
	cp	w, 0:i3	; F77F66  cp W,0
	jr	nz, SmfWrite_CreateFileWithFirstWindow_Copy2_Return	; F77F68  jr NZ,0xf77f99
	ld	(Disk_FileName+8:16), 77	; F77F6A  ld (0x21d0),0x4d
	ld	(Disk_FileName+9:16), 73	; F77F6F  ld (0x21d1),0x49
	ld	(Disk_FileName+10:16), 68	; F77F74  ld (0x21d2),0x44
	call	T_DiskApi_DeleteFile_Call	; F77F79  call 0xf425b0
	or	(Disk_Flags:16), 0x80	; F77F7D  or (0x21e7),0x80
	ld	(Disk_FileName+8:16), 77	; F77F82  ld (0x21d0),0x4d
	ld	(Disk_FileName+9:16), 73	; F77F87  ld (0x21d1),0x49
	ld	(Disk_FileName+10:16), 68	; F77F8C  ld (0x21d2),0x44
	call	SmfWrite_SetOutputWindow_Copy2	; F77F91  call 0xf77fd6
	call	SmfWrite_WriteFirstWindow_Copy2	; F77F95  call 0xf77f9a
SmfWrite_CreateFileWithFirstWindow_Copy2_Return:
	ret	; F77F99  ret

; SmfWrite_WriteFirstWindow_Copy2: copy E's SmfWrite_WriteFirstWindow, byte-identical to it and to copy D's
;   SmfWriteCopy_WriteFirstWindow: Disk_Flags |= 0x20, T_DiskApi_WriteFileFromWindow_Entry, A := Disk_LastError, the
;   flag cleared again.  Called only by SmfWrite_CreateFileWithFirstWindow_Copy2.  Was SmfOut_WriteFirstWindow, a name
;   that read as the live writer's (kn5000-wxn).
;   COPY E: 0xF77EE7-0xF77FE8 is a third copy of the SMF writer's file layer -- copy A InputStream_OpenAndReadFirstBlock
;   (0xF7659B) .. SmfWrite_SetOutputWindow, copy D InputStream_OpenAndReadFirstBlock_Copy (0xF77D00) .., every routine at
;   the same offset (+0x00 / +0x39 / +0x43 / +0x4B / +0xB3 / +0xC6 / +0xD4 / +0xEF).  Nothing outside it reaches it:
;   its only callers are its own internal calls and the three veneers at 0xF77EDB / 0xF77EDF / 0xF77EE3, which nothing
;   calls (no call, calr, jp, jr or 24-bit operand in prom_a or prom_b; notes/open6-kn5000-d/wsa1/probes/wsa1_wxn_refs.py).
SmfWrite_WriteFirstWindow_Copy2:
	or	(Disk_Flags:16), 0x20	; F77F9A  or (0x21e7),0x20
	call	T_DiskApi_WriteFileFromWindow_Entry	; F77F9F  call 0xf425ac
	ld	a, (Disk_LastError:16)	; F77FA3  ld A,(0x2243)
	and	(Disk_Flags:16), 0xdf	; F77FA7  and (0x21e7),0xdf
	ret	; F77FAC  ret
; SmfWrite_WriteNextWindow_Copy2: copy E's SmfWrite_WriteNextWindow (byte-identical; copy D's is
;   SmfOut_WriteNextWindow): Disk_Flags |= 0x02, T_DiskApi_WriteFileFromWindow_Entry, A := Disk_LastError.  Unreached
;   (copy E, see SmfWrite_CreateFileWithFirstWindow_Copy2).  Was unlabelled (kn5000-wxn).
SmfWrite_WriteNextWindow_Copy2:
	or	(Disk_Flags:16), 0x02	; F77FAD  or (0x21e7),0x02
	call	T_DiskApi_WriteFileFromWindow_Entry	; F77FB2  call 0xf425ac
	ld	a, (Disk_LastError:16)	; F77FB6  ld A,(0x2243)
	ret	; F77FBA  ret
; SmfWrite_WriteLastWindowAndClose_Copy2: copy E's SmfWrite_WriteLastWindowAndClose (byte-identical;
;   copy D's is SmfOut_WriteLastWindowAndClose): flush the last window when SmfOut_WindowsFlushed is non-zero, clear
;   Disk_Flags bit 1, T_DiskApi_CloseFile_Call.  Unreached (copy E).  Was unlabelled (kn5000-wxn).
SmfWrite_WriteLastWindowAndClose_Copy2:
	cpw	(SmfOut_WindowsFlushed:16), 0x0000	; F77FBB  cp (0x126c),0x0000
	jr	z, SmfWrite_WriteLastWindowAndClose_Copy2_Skip	; F77FC1  jr Z,0xf77fcc
	or	(Disk_Flags:16), 0x02	; F77FC3  or (0x21e7),0x02
	call	T_DiskApi_WriteFileFromWindow_Entry	; F77FC8  call 0xf425ac
SmfWrite_WriteLastWindowAndClose_Copy2_Skip:
	and	(Disk_Flags:16), 0xfd	; F77FCC  and (0x21e7),0xfd
	call	T_DiskApi_CloseFile_Call	; F77FD1  call 0xf425e4
	ret	; F77FD5  ret

; SmfWrite_SetOutputWindow_Copy2: copy E's SmfWrite_SetOutputWindow, byte-identical: Disk_WindowStart := 0x60A700,
;   Disk_WindowEnd := 0x60AB00, the 1,024-byte output window.  Called only by SmfWrite_CreateFileWithFirstWindow_Copy2.
;   Was sub_F77FD6 (kn5000-wxn).
SmfWrite_SetOutputWindow_Copy2:
	ld	xwa, 6334208	; F77FD6  ld XWA,0x0060a700
	ld	(Disk_WindowStart:16), xwa	; F77FDB  ld (0x21d3),XWA
	ld	xwa, 6335232	; F77FDF  ld XWA,0x0060ab00
	ld	(Disk_WindowEnd:16), xwa	; F77FE4  ld (0x21d7),XWA
	ret	; F77FE8  ret

; --------------------------------------------------------------------------
; Data_F77FE9 -- 23 bytes this block could not split.  No content rule
;                framed it -- not PTRTAB, RAMTAB, BITTAB, IDENT, BYTEMAP or
;                ASCII -- and the code walk never reached it from a thunk
;                slot, a proven call site, an opcode-anchored call or an
;                entry of a table the firmware transfers to.  So it is
;                emitted as bytes rather than guessed.
; Contains: printable bytes |..!<...%..@..`...!`@..`|
; Read by: nothing in prom_a or prom_b spells this address as a 32-bit word,
;          so whatever reaches it computes the address
; Evidence: the bytes are re-read on every emit; the classification is
;           NEGATIVE (no rule matched, no walk arrived) and is stated as
;           such.
; Unknown: everything about it except its bytes.
; --------------------------------------------------------------------------
Data_F77FE9:
	.byte	0x0E, 0xE7, 0x21, 0x3C, 0xFD, 0x1D, 0xE4, 0x25, 0xF4, 0x0E, 0x40, 0x00, 0xA7, 0x60, 0x00, 0xF1	; F77FE9  [0..15]
	.byte	0xD3, 0x21, 0x60, 0x40, 0x00, 0xAB, 0x60	; F77FF9  [16..22]

; ------------------------------------------------------------------
; DLB_RecordTemplate_Op02 / DLB_RecordTemplate_Op07 -- the two interpreter-B
; display-list records the field-blink engine copies to the stack and patches
;
; Read by:  prom_b 0xF0E933 (`lda XIY,0xf78000`, then `ldir` BC = 0x0F) and
;           prom_b 0xF0E985 (`lda XIY,0xf7800f`, then `ldir` BC = 0x11).
;           Nothing else in prom_a or prom_b loads either address.
; Layout:   interpreter B's record, the same layout the static op-02 records
;           above carry (+0 opcode, +1 total length, +2..3 source variable,
;           +4 AND mask, +5 shift, +6 swi 7 function, +7 32-bit table pointer,
;           +0x0B bytes per entry, +0x0D word; op 07 adds a second word at +0x0F).
; Extent:   15 and 17 bytes, from the `ldir` counts the copier uses (0x0F at
;           0xF0E930, 0x11 at 0xF0E982) and from the fields interpreter B's own
;           handlers touch (0xF31B21 -> 15, 0xF31B39 -> 17; the per-handler
;           table is in notes/prom_b_dl_length_audit.py's docstring).
;           15 + 17 = 32, so the pair ends exactly on DLB_BlankField_8.
;
; ⚠ THE SECOND TEMPLATE'S OWN LENGTH BYTE DISAGREES, AND IT DOES NOT MATTER.
;           0xF78010 is 0x0F = 15, not the 17 the record actually occupies.  A
;           first draft of this header claimed "three ways agree" and wrote 0x11
;           there; the build gate rejected it, which is the only reason the
;           claim is not still sitting here looking plausible.
;           Why it is harmless: these records are never FRAMED.  The copier
;           calls DisplayListB_RunOne_Stack (0xF3183D), which sets the end
;           pointer to XIY + 1, so interpreter B's `cp XIX,XIY / jr ULE` lets
;           exactly one record run and then exits.  The length byte is used only
;           to advance XIY past the record, and any value >= 1 ends the loop.
;           Nothing walks from this record to a next one, so nothing reads it.
;           This is also NOT a counterexample to "494 interpreter-B records, 0
;           disagree": that audit walks records reachable from
;           `ld XIY,imm32 / ld XIX,imm32 / call 0xF417F0|0xF417F4` call sites,
;           and these two are reached by neither -- they are copied, not run in
;           place.
; Note:     fields +2, +4 and +5 are zero and the copier never patches them, so
;           the extracted index is always 0 and the record renders entry 0.
; ------------------------------------------------------------------
DLB_RecordTemplate_Op02:
	.byte 0x02, 0x0F	; +0 opcode 0x02 -> DLB_Handler_StringTable ; +1 len 15
	.short 0x0000		; +0x02 source variable, 16-bit address (never patched)
	.byte 0x00		; +0x04 AND mask (never patched)
	.byte 0x00		; +0x05 right shift, low 3 bits (never patched)
	.byte 0x20		; +0x06 swi 7 function -- patched from (0x28C9)
	.long 0x000028C0	; +0x07 -> XIY: the text.  Replaced with
				;          DLB_BlankField_8 when the argument is 0
	.short 0x0003		; +0x0B -> BC: bytes per entry -- patched from (0x28D0)
	.short 0x0000		; +0x0D -> IX -- patched from (0x28CA)

DLB_RecordTemplate_Op07:
	.byte 0x07, 0x0F	; +0 opcode 0x07 -> DLB_Handler_StringTable2
				; +1 length 15 -- WRONG for a 17-byte record; see
				;    the header.  Never read: run-one framing.
	; NOTE the two `.byte 0x02, 0x0F` / `0x07, 0x0F` pairs are NOT a typo
	; repeated: op 02 really is 15 bytes long, op 07 really is 17.
	.short 0x0000		; +0x02 source variable, 16-bit address (never patched)
	.byte 0x00		; +0x04 AND mask (never patched)
	.byte 0x00		; +0x05 right shift, low 3 bits (never patched)
	.byte 0x20		; +0x06 swi 7 function -- patched from (0x28C9)
	.long 0x000028C0	; +0x07 -> XIY: the text, as above
	.short 0x0003		; +0x0B -> BC: bytes per entry -- patched from (0x28D0)
	.short 0x0000		; +0x0D -> IX -- patched from (0x28CC)
	.short 0x0000		; +0x0F -> the second word -- patched from (0x28CE)

; ------------------------------------------------------------------
; DLB_BlankField_8 -- the eight spaces the blink engine draws to erase the field
; Read by:  prom_b 0xF0E961 and 0xF0E9B8 (`lda XBC,0xf78020`), each guarded by
;           `cp (XIZ+0x08),0x00 / jr NZ` -- i.e. taken only when the caller
;           asked for the BLANK half of the blink.  The address is then stored
;           into the copied record's +7 field, replacing the text pointer.
; Extent:   the run of 0x20 bytes starts at 0xF78020 and ends at 0xF78027; the
;           byte at 0xF78028 is 0x00 -- and it is the FIRST byte of the icon sheet
;           emitted below, not part of this object.  ⚠ That is a measurement of the RUN, not
;           of the object: how many of these bytes are actually drawn is set at
;           run time by the record's +0x0B field, which the copier patches from
;           (0x28D0), and this tree cannot read (0x28D0) statically.  Eight is
;           therefore an upper bound on the blank width, not the width.
; ------------------------------------------------------------------
DLB_BlankField_8:
	.ascii "        "	; 0xF78020-0xF78027, eight ASCII spaces

; ==============================================================================
; 0xF78028-0xF7A19F -- THE UI ICON SHEET: 119 CELLS OF 24x24, 72 BYTES EACH
; ==============================================================================
;
; 8,568 bytes.  DATA: no instruction in any of the four ROM images calls or
; jumps into it, and the 0xF40000 routine directory has 0 slots pointing here.
;
; ★ THE GRID IS THE HANDLER'S OWN ARITHMETIC, not a stride read off the data.
;   DLHandler_Glyph24x24 (display-list opcode 0x23, prom_b 0xF31ACE) is
;
;       ld A,(XIY+0x02) / extz WA / mul WA,0x0048 / ld XIY,0x00F78028
;       add XIY,XWA / ldw BC,0x0003 / ldw HL,0x0018 / ldb A,0x03 / swi 7
;
;   0x48 = 72 = 3 * 24, so the stride equals the blit size: 3 columns of 8
;   pixels by 24 rows.  Scanning all four images for the 24-bit immediate
;   0xF78028 returns EXACTLY ONE hit -- that `ld XIY` -- so this is the only
;   code in the machine that names the array at all.
;
; ★ AND THE ARRAY ENDS EXACTLY ON THAT GRID.  The 0x0E (`ret`) padding below
;   begins at 0xF7A1A0, and 0xF7A1A0 - 0xF78028 = 8568 = 119 * 72 with no
;   remainder; the highest index any op-0x23 record in the tree carries is 118,
;   i.e. 119 cells.  The end of the data and the largest index the UI asks for
;   are different measurements and they give the same count.
;
; PIXEL FORMAT (LCD_Svc_03_BlitColumns, prom_a 0xF8EDB4): COLUMN-MAJOR, one
; byte = 8 horizontal pixels, MSB leftmost:
;       pixel (x, y) = bit (7 - x%8) of byte (x//8) * 24 + y
; so each `.byte` line below is ONE 8-pixel-wide column, top row first.
; Every cell is also a PNG under prom_b/images/; `make images-check` asserts
; these rows and those PNGs are the same pixels.
;
; ⚠ WHAT THIS BLOCK REPLACES, AND WHY.  Until now these bytes carried 110
;   `Bitmap_F78*` labels whose extents came from the pointer table at
;   0xF003F9.  That framing is REFUTED: of the 121 targets that table has in
;   this span exactly ONE is a multiple of 72 from 0xF78028, against 1.7
;   expected by chance, so the targets carry no information about the grid;
;   the same table fails identically in its other target region (3 of its 24
;   targets in prom_a's DisplayList_FC4000 land on a record boundary, against
;   1.8 by chance); and no immediate in any of the four images equals
;   0xF003F9.  See the header on PtrTable_F003F9 and
;   notes/gen_prom_b_f78028_icon_sheet.py --evidence.
;
; Re-derive all of it, and this text, with
;     python3 notes/gen_prom_b_f78028_icon_sheet.py --evidence --selftest
; ==============================================================================

; ---------------------------------------------------------------------
; DLGlyph_000_F78028 -- icon sheet cell 0.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 0 * 0x48;
;           named by 1 op-0x23 display-list record.
; Image:    prom_b/images/DLGlyph_000_F78028.png
; ---------------------------------------------------------------------
DLGlyph_000_F78028:
	.incbin	"images/DLGlyph_000_F78028.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_001_F78070 -- icon sheet cell 1.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 1 * 0x48;
;           named by 5 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_001_F78070.png
; ---------------------------------------------------------------------
DLGlyph_001_F78070:
	.incbin	"images/DLGlyph_001_F78070.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_002_F780B8 -- icon sheet cell 2.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 2 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_002_F780B8.png
; ---------------------------------------------------------------------
DLGlyph_002_F780B8:
	.incbin	"images/DLGlyph_002_F780B8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_003_F78100 -- icon sheet cell 3.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 3 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_003_F78100.png
; ---------------------------------------------------------------------
DLGlyph_003_F78100:
	.incbin	"images/DLGlyph_003_F78100.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_004_F78148 -- icon sheet cell 4.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 4 * 0x48;
;           named by 5 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_004_F78148.png
; ---------------------------------------------------------------------
DLGlyph_004_F78148:
	.incbin	"images/DLGlyph_004_F78148.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_005_F78190 -- icon sheet cell 5.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 5 * 0x48;
;           named by 3 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_005_F78190.png
; ---------------------------------------------------------------------
DLGlyph_005_F78190:
	.incbin	"images/DLGlyph_005_F78190.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_006_F781D8 -- icon sheet cell 6.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 6 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_006_F781D8.png
; ---------------------------------------------------------------------
DLGlyph_006_F781D8:
	.incbin	"images/DLGlyph_006_F781D8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_007_F78220 -- icon sheet cell 7.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 7 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_007_F78220.png
; ---------------------------------------------------------------------
DLGlyph_007_F78220:
	.incbin	"images/DLGlyph_007_F78220.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_008_F78268 -- icon sheet cell 8.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 8 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_008_F78268.png
; ---------------------------------------------------------------------
DLGlyph_008_F78268:
	.incbin	"images/DLGlyph_008_F78268.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_009_F782B0 -- icon sheet cell 9.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 9 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_009_F782B0.png
; ---------------------------------------------------------------------
DLGlyph_009_F782B0:
	.incbin	"images/DLGlyph_009_F782B0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_010_F782F8 -- icon sheet cell 10.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 10 * 0x48;
;           named by 9 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_010_F782F8.png
; ---------------------------------------------------------------------
DLGlyph_010_F782F8:
	.incbin	"images/DLGlyph_010_F782F8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_011_F78340 -- icon sheet cell 11.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 11 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_011_F78340.png
; ---------------------------------------------------------------------
DLGlyph_011_F78340:
	.incbin	"images/DLGlyph_011_F78340.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_012_F78388 -- icon sheet cell 12.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 12 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_012_F78388.png
; ---------------------------------------------------------------------
DLGlyph_012_F78388:
	.incbin	"images/DLGlyph_012_F78388.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_013_F783D0 -- icon sheet cell 13.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 13 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_013_F783D0.png
; ---------------------------------------------------------------------
DLGlyph_013_F783D0:
	.incbin	"images/DLGlyph_013_F783D0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_014_F78418 -- icon sheet cell 14.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 14 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_014_F78418.png
; ---------------------------------------------------------------------
DLGlyph_014_F78418:
	.incbin	"images/DLGlyph_014_F78418.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_015_F78460 -- icon sheet cell 15.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 15 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_015_F78460.png
; ---------------------------------------------------------------------
DLGlyph_015_F78460:
	.incbin	"images/DLGlyph_015_F78460.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_016_F784A8 -- icon sheet cell 16.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 16 * 0x48;
;           named by 5 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_016_F784A8.png
; ---------------------------------------------------------------------
DLGlyph_016_F784A8:
	.incbin	"images/DLGlyph_016_F784A8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_017_F784F0 -- icon sheet cell 17.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 17 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_017_F784F0.png
; ---------------------------------------------------------------------
DLGlyph_017_F784F0:
	.incbin	"images/DLGlyph_017_F784F0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_018_F78538 -- icon sheet cell 18.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 18 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_018_F78538.png
; ---------------------------------------------------------------------
DLGlyph_018_F78538:
	.incbin	"images/DLGlyph_018_F78538.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_019_F78580 -- icon sheet cell 19.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 19 * 0x48;
;           named by 3 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_019_F78580.png
; ---------------------------------------------------------------------
DLGlyph_019_F78580:
	.incbin	"images/DLGlyph_019_F78580.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_020_F785C8 -- icon sheet cell 20.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 20 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_020_F785C8.png
; ---------------------------------------------------------------------
DLGlyph_020_F785C8:
	.incbin	"images/DLGlyph_020_F785C8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_021_F78610 -- icon sheet cell 21.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 21 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_021_F78610.png
; ---------------------------------------------------------------------
DLGlyph_021_F78610:
	.incbin	"images/DLGlyph_021_F78610.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_022_F78658 -- icon sheet cell 22.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 22 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_022_F78658.png
; ---------------------------------------------------------------------
DLGlyph_022_F78658:
	.incbin	"images/DLGlyph_022_F78658.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_023_F786A0 -- icon sheet cell 23.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 23 * 0x48;
;           named by 1 op-0x23 display-list record.
; Image:    prom_b/images/DLGlyph_023_F786A0.png
; ---------------------------------------------------------------------
DLGlyph_023_F786A0:
	.incbin	"images/DLGlyph_023_F786A0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_024_F786E8 -- icon sheet cell 24.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 24 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_024_F786E8.png
; ---------------------------------------------------------------------
DLGlyph_024_F786E8:
	.incbin	"images/DLGlyph_024_F786E8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_025_F78730 -- icon sheet cell 25.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 25 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_025_F78730.png
; ---------------------------------------------------------------------
DLGlyph_025_F78730:
	.incbin	"images/DLGlyph_025_F78730.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_026_F78778 -- icon sheet cell 26.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 26 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_026_F78778.png
; ---------------------------------------------------------------------
DLGlyph_026_F78778:
	.incbin	"images/DLGlyph_026_F78778.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_027_F787C0 -- icon sheet cell 27.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 27 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_027_F787C0.png
; ---------------------------------------------------------------------
DLGlyph_027_F787C0:
	.incbin	"images/DLGlyph_027_F787C0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_028_F78808 -- icon sheet cell 28.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 28 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_028_F78808.png
; ---------------------------------------------------------------------
DLGlyph_028_F78808:
	.incbin	"images/DLGlyph_028_F78808.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_029_F78850 -- icon sheet cell 29.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 29 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_029_F78850.png
; ---------------------------------------------------------------------
DLGlyph_029_F78850:
	.incbin	"images/DLGlyph_029_F78850.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_030_F78898 -- icon sheet cell 30.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 30 * 0x48;
;           named by 4 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_030_F78898.png
; ---------------------------------------------------------------------
DLGlyph_030_F78898:
	.incbin	"images/DLGlyph_030_F78898.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_031_F788E0 -- icon sheet cell 31.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 31 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_031_F788E0.png
; ---------------------------------------------------------------------
DLGlyph_031_F788E0:
	.incbin	"images/DLGlyph_031_F788E0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_032_F78928 -- icon sheet cell 32.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 32 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_032_F78928.png
; ---------------------------------------------------------------------
DLGlyph_032_F78928:
	.incbin	"images/DLGlyph_032_F78928.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_033_F78970 -- icon sheet cell 33.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 33 * 0x48;
;           named by 3 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_033_F78970.png
; ---------------------------------------------------------------------
DLGlyph_033_F78970:
	.incbin	"images/DLGlyph_033_F78970.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_034_F789B8 -- icon sheet cell 34.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 34 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_034_F789B8.png
; ---------------------------------------------------------------------
DLGlyph_034_F789B8:
	.incbin	"images/DLGlyph_034_F789B8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_035_F78A00 -- icon sheet cell 35.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 35 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_035_F78A00.png
; ---------------------------------------------------------------------
DLGlyph_035_F78A00:
	.incbin	"images/DLGlyph_035_F78A00.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_036_F78A48 -- icon sheet cell 36.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 36 * 0x48;
;           named by 8 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_036_F78A48.png
; ---------------------------------------------------------------------
DLGlyph_036_F78A48:
	.incbin	"images/DLGlyph_036_F78A48.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_037_F78A90 -- icon sheet cell 37.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 37 * 0x48;
;           named by 4 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_037_F78A90.png
; ---------------------------------------------------------------------
DLGlyph_037_F78A90:
	.incbin	"images/DLGlyph_037_F78A90.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_038_F78AD8 -- icon sheet cell 38.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 38 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_038_F78AD8.png
; ---------------------------------------------------------------------
DLGlyph_038_F78AD8:
	.incbin	"images/DLGlyph_038_F78AD8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_039_F78B20 -- icon sheet cell 39.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 39 * 0x48;
;           named by 1 op-0x23 display-list record.
; Image:    prom_b/images/DLGlyph_039_F78B20.png
; ---------------------------------------------------------------------
DLGlyph_039_F78B20:
	.incbin	"images/DLGlyph_039_F78B20.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_040_F78B68 -- icon sheet cell 40.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 40 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_040_F78B68.png
; ---------------------------------------------------------------------
DLGlyph_040_F78B68:
	.incbin	"images/DLGlyph_040_F78B68.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_041_F78BB0 -- icon sheet cell 41.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 41 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_041_F78BB0.png
; ---------------------------------------------------------------------
DLGlyph_041_F78BB0:
	.incbin	"images/DLGlyph_041_F78BB0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_042_F78BF8 -- icon sheet cell 42.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 42 * 0x48;
;           named by 1 op-0x23 display-list record.
; Image:    prom_b/images/DLGlyph_042_F78BF8.png
; ---------------------------------------------------------------------
DLGlyph_042_F78BF8:
	.incbin	"images/DLGlyph_042_F78BF8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_043_F78C40 -- icon sheet cell 43.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 43 * 0x48;
;           named by 1 op-0x23 display-list record.
; Image:    prom_b/images/DLGlyph_043_F78C40.png
; ---------------------------------------------------------------------
DLGlyph_043_F78C40:
	.incbin	"images/DLGlyph_043_F78C40.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_044_F78C88 -- icon sheet cell 44.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 44 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_044_F78C88.png
; ---------------------------------------------------------------------
DLGlyph_044_F78C88:
	.incbin	"images/DLGlyph_044_F78C88.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_045_F78CD0 -- icon sheet cell 45.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 45 * 0x48;
;           named by 1 op-0x23 display-list record.
; Image:    prom_b/images/DLGlyph_045_F78CD0.png
; ---------------------------------------------------------------------
DLGlyph_045_F78CD0:
	.incbin	"images/DLGlyph_045_F78CD0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_046_F78D18 -- icon sheet cell 46.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 46 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_046_F78D18.png
; ---------------------------------------------------------------------
DLGlyph_046_F78D18:
	.incbin	"images/DLGlyph_046_F78D18.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_047_F78D60 -- icon sheet cell 47.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 47 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_047_F78D60.png
; ---------------------------------------------------------------------
DLGlyph_047_F78D60:
	.incbin	"images/DLGlyph_047_F78D60.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_048_F78DA8 -- icon sheet cell 48.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 48 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_048_F78DA8.png
; ---------------------------------------------------------------------
DLGlyph_048_F78DA8:
	.incbin	"images/DLGlyph_048_F78DA8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_049_F78DF0 -- icon sheet cell 49.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 49 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_049_F78DF0.png
; ---------------------------------------------------------------------
DLGlyph_049_F78DF0:
	.incbin	"images/DLGlyph_049_F78DF0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_050_F78E38 -- icon sheet cell 50.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 50 * 0x48;
;           named by 3 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_050_F78E38.png
; ---------------------------------------------------------------------
DLGlyph_050_F78E38:
	.incbin	"images/DLGlyph_050_F78E38.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_051_F78E80 -- icon sheet cell 51.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 51 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_051_F78E80.png
; ---------------------------------------------------------------------
DLGlyph_051_F78E80:
	.incbin	"images/DLGlyph_051_F78E80.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_052_F78EC8 -- icon sheet cell 52.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 52 * 0x48;
;           named by 3 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_052_F78EC8.png
; ---------------------------------------------------------------------
DLGlyph_052_F78EC8:
	.incbin	"images/DLGlyph_052_F78EC8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_053_F78F10 -- icon sheet cell 53.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 53 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_053_F78F10.png
; ---------------------------------------------------------------------
DLGlyph_053_F78F10:
	.incbin	"images/DLGlyph_053_F78F10.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_054_F78F58 -- icon sheet cell 54.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 54 * 0x48;
;           named by 1 op-0x23 display-list record.
; Image:    prom_b/images/DLGlyph_054_F78F58.png
; ---------------------------------------------------------------------
DLGlyph_054_F78F58:
	.incbin	"images/DLGlyph_054_F78F58.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_055_F78FA0 -- icon sheet cell 55.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 55 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_055_F78FA0.png
; ---------------------------------------------------------------------
DLGlyph_055_F78FA0:
	.incbin	"images/DLGlyph_055_F78FA0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_056_F78FE8 -- icon sheet cell 56.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 56 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_056_F78FE8.png
; ---------------------------------------------------------------------
DLGlyph_056_F78FE8:
	.incbin	"images/DLGlyph_056_F78FE8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_057_F79030 -- icon sheet cell 57.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 57 * 0x48;
;           named by 3 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_057_F79030.png
; ---------------------------------------------------------------------
DLGlyph_057_F79030:
	.incbin	"images/DLGlyph_057_F79030.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_058_F79078 -- icon sheet cell 58.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 58 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_058_F79078.png
; ---------------------------------------------------------------------
DLGlyph_058_F79078:
	.incbin	"images/DLGlyph_058_F79078.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_059_F790C0 -- icon sheet cell 59.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 59 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_059_F790C0.png
; ---------------------------------------------------------------------
DLGlyph_059_F790C0:
	.incbin	"images/DLGlyph_059_F790C0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_060_F79108 -- icon sheet cell 60.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 60 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_060_F79108.png
; ---------------------------------------------------------------------
DLGlyph_060_F79108:
	.incbin	"images/DLGlyph_060_F79108.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_061_F79150 -- icon sheet cell 61.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 61 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_061_F79150.png
; ---------------------------------------------------------------------
DLGlyph_061_F79150:
	.incbin	"images/DLGlyph_061_F79150.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_062_F79198 -- icon sheet cell 62.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 62 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_062_F79198.png
; ---------------------------------------------------------------------
DLGlyph_062_F79198:
	.incbin	"images/DLGlyph_062_F79198.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_063_F791E0 -- icon sheet cell 63.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 63 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_063_F791E0.png
; ---------------------------------------------------------------------
DLGlyph_063_F791E0:
	.incbin	"images/DLGlyph_063_F791E0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_064_F79228 -- icon sheet cell 64.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 64 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_064_F79228.png
; ---------------------------------------------------------------------
DLGlyph_064_F79228:
	.incbin	"images/DLGlyph_064_F79228.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_065_F79270 -- icon sheet cell 65.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 65 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_065_F79270.png
; ---------------------------------------------------------------------
DLGlyph_065_F79270:
	.incbin	"images/DLGlyph_065_F79270.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_066_F792B8 -- icon sheet cell 66.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 66 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_066_F792B8.png
; ---------------------------------------------------------------------
DLGlyph_066_F792B8:
	.incbin	"images/DLGlyph_066_F792B8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_067_F79300 -- icon sheet cell 67.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 67 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_067_F79300.png
; ---------------------------------------------------------------------
DLGlyph_067_F79300:
	.incbin	"images/DLGlyph_067_F79300.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_068_F79348 -- icon sheet cell 68.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 68 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_068_F79348.png
; ---------------------------------------------------------------------
DLGlyph_068_F79348:
	.incbin	"images/DLGlyph_068_F79348.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_069_F79390 -- icon sheet cell 69.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 69 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_069_F79390.png
; ---------------------------------------------------------------------
DLGlyph_069_F79390:
	.incbin	"images/DLGlyph_069_F79390.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_070_F793D8 -- icon sheet cell 70.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 70 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_070_F793D8.png
; ---------------------------------------------------------------------
DLGlyph_070_F793D8:
	.incbin	"images/DLGlyph_070_F793D8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_071_F79420 -- icon sheet cell 71.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 71 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_071_F79420.png
; ---------------------------------------------------------------------
DLGlyph_071_F79420:
	.incbin	"images/DLGlyph_071_F79420.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_072_F79468 -- icon sheet cell 72.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 72 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_072_F79468.png
; ---------------------------------------------------------------------
DLGlyph_072_F79468:
	.incbin	"images/DLGlyph_072_F79468.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_073_F794B0 -- icon sheet cell 73.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 73 * 0x48;
;           named by 3 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_073_F794B0.png
; ---------------------------------------------------------------------
DLGlyph_073_F794B0:
	.incbin	"images/DLGlyph_073_F794B0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_074_F794F8 -- icon sheet cell 74.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 74 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_074_F794F8.png
; ---------------------------------------------------------------------
DLGlyph_074_F794F8:
	.incbin	"images/DLGlyph_074_F794F8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_075_F79540 -- icon sheet cell 75.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 75 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_075_F79540.png
; ---------------------------------------------------------------------
DLGlyph_075_F79540:
	.incbin	"images/DLGlyph_075_F79540.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_076_F79588 -- icon sheet cell 76.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 76 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_076_F79588.png
; ---------------------------------------------------------------------
DLGlyph_076_F79588:
	.incbin	"images/DLGlyph_076_F79588.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_077_F795D0 -- icon sheet cell 77.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 77 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_077_F795D0.png
; ---------------------------------------------------------------------
DLGlyph_077_F795D0:
	.incbin	"images/DLGlyph_077_F795D0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_078_F79618 -- icon sheet cell 78.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 78 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_078_F79618.png
; ---------------------------------------------------------------------
DLGlyph_078_F79618:
	.incbin	"images/DLGlyph_078_F79618.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_079_F79660 -- icon sheet cell 79.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 79 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_079_F79660.png
; ---------------------------------------------------------------------
DLGlyph_079_F79660:
	.incbin	"images/DLGlyph_079_F79660.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_080_F796A8 -- icon sheet cell 80.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 80 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_080_F796A8.png
; ---------------------------------------------------------------------
DLGlyph_080_F796A8:
	.incbin	"images/DLGlyph_080_F796A8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_081_F796F0 -- icon sheet cell 81.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 81 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_081_F796F0.png
; ---------------------------------------------------------------------
DLGlyph_081_F796F0:
	.incbin	"images/DLGlyph_081_F796F0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_082_F79738 -- icon sheet cell 82.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 82 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_082_F79738.png
; ---------------------------------------------------------------------
DLGlyph_082_F79738:
	.incbin	"images/DLGlyph_082_F79738.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_083_F79780 -- icon sheet cell 83.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 83 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_083_F79780.png
; ---------------------------------------------------------------------
DLGlyph_083_F79780:
	.incbin	"images/DLGlyph_083_F79780.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_084_F797C8 -- icon sheet cell 84.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 84 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_084_F797C8.png
; ---------------------------------------------------------------------
DLGlyph_084_F797C8:
	.incbin	"images/DLGlyph_084_F797C8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_085_F79810 -- icon sheet cell 85.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 85 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_085_F79810.png
; ---------------------------------------------------------------------
DLGlyph_085_F79810:
	.incbin	"images/DLGlyph_085_F79810.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_086_F79858 -- icon sheet cell 86.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 86 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_086_F79858.png
; ---------------------------------------------------------------------
DLGlyph_086_F79858:
	.incbin	"images/DLGlyph_086_F79858.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_087_F798A0 -- icon sheet cell 87.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 87 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_087_F798A0.png
; ---------------------------------------------------------------------
DLGlyph_087_F798A0:
	.incbin	"images/DLGlyph_087_F798A0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_088_F798E8 -- icon sheet cell 88.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 88 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_088_F798E8.png
; ---------------------------------------------------------------------
DLGlyph_088_F798E8:
	.incbin	"images/DLGlyph_088_F798E8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_089_F79930 -- icon sheet cell 89.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 89 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_089_F79930.png
; ---------------------------------------------------------------------
DLGlyph_089_F79930:
	.incbin	"images/DLGlyph_089_F79930.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_090_F79978 -- icon sheet cell 90.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 90 * 0x48;
;           named by 3 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_090_F79978.png
; ---------------------------------------------------------------------
DLGlyph_090_F79978:
	.incbin	"images/DLGlyph_090_F79978.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_091_F799C0 -- icon sheet cell 91.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 91 * 0x48;
;           named by 1 op-0x23 display-list record.
; Image:    prom_b/images/DLGlyph_091_F799C0.png
; ---------------------------------------------------------------------
DLGlyph_091_F799C0:
	.incbin	"images/DLGlyph_091_F799C0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_092_F79A08 -- icon sheet cell 92.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 92 * 0x48;
;           named by 1 op-0x23 display-list record.
; Image:    prom_b/images/DLGlyph_092_F79A08.png
; ---------------------------------------------------------------------
DLGlyph_092_F79A08:
	.incbin	"images/DLGlyph_092_F79A08.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_093_F79A50 -- icon sheet cell 93.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 93 * 0x48;
;           named by 1 op-0x23 display-list record.
; Image:    prom_b/images/DLGlyph_093_F79A50.png
; ---------------------------------------------------------------------
DLGlyph_093_F79A50:
	.incbin	"images/DLGlyph_093_F79A50.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_094_F79A98 -- icon sheet cell 94.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 94 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_094_F79A98.png
; ---------------------------------------------------------------------
DLGlyph_094_F79A98:
	.incbin	"images/DLGlyph_094_F79A98.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_095_F79AE0 -- icon sheet cell 95.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 95 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_095_F79AE0.png
; ---------------------------------------------------------------------
DLGlyph_095_F79AE0:
	.incbin	"images/DLGlyph_095_F79AE0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_096_F79B28 -- icon sheet cell 96.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 96 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_096_F79B28.png
; ---------------------------------------------------------------------
DLGlyph_096_F79B28:
	.incbin	"images/DLGlyph_096_F79B28.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_097_F79B70 -- icon sheet cell 97.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 97 * 0x48;
;           named by 1 op-0x23 display-list record.
; Image:    prom_b/images/DLGlyph_097_F79B70.png
; ---------------------------------------------------------------------
DLGlyph_097_F79B70:
	.incbin	"images/DLGlyph_097_F79B70.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_098_F79BB8 -- icon sheet cell 98.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 98 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_098_F79BB8.png
; ---------------------------------------------------------------------
DLGlyph_098_F79BB8:
	.incbin	"images/DLGlyph_098_F79BB8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_099_F79C00 -- icon sheet cell 99.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 99 * 0x48;
;           named by 3 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_099_F79C00.png
; ---------------------------------------------------------------------
DLGlyph_099_F79C00:
	.incbin	"images/DLGlyph_099_F79C00.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_100_F79C48 -- icon sheet cell 100.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 100 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_100_F79C48.png
; ---------------------------------------------------------------------
DLGlyph_100_F79C48:
	.incbin	"images/DLGlyph_100_F79C48.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_101_F79C90 -- icon sheet cell 101.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 101 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_101_F79C90.png
; ---------------------------------------------------------------------
DLGlyph_101_F79C90:
	.incbin	"images/DLGlyph_101_F79C90.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_102_F79CD8 -- icon sheet cell 102.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 102 * 0x48;
;           named by 3 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_102_F79CD8.png
; ---------------------------------------------------------------------
DLGlyph_102_F79CD8:
	.incbin	"images/DLGlyph_102_F79CD8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_103_F79D20 -- icon sheet cell 103.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 103 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_103_F79D20.png
; ---------------------------------------------------------------------
DLGlyph_103_F79D20:
	.incbin	"images/DLGlyph_103_F79D20.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_104_F79D68 -- icon sheet cell 104.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 104 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_104_F79D68.png
; ---------------------------------------------------------------------
DLGlyph_104_F79D68:
	.incbin	"images/DLGlyph_104_F79D68.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_105_F79DB0 -- icon sheet cell 105.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 105 * 0x48;
;           named by 3 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_105_F79DB0.png
; ---------------------------------------------------------------------
DLGlyph_105_F79DB0:
	.incbin	"images/DLGlyph_105_F79DB0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_106_F79DF8 -- icon sheet cell 106.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 106 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_106_F79DF8.png
; ---------------------------------------------------------------------
DLGlyph_106_F79DF8:
	.incbin	"images/DLGlyph_106_F79DF8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_107_F79E40 -- icon sheet cell 107.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 107 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_107_F79E40.png
; ---------------------------------------------------------------------
DLGlyph_107_F79E40:
	.incbin	"images/DLGlyph_107_F79E40.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_108_F79E88 -- icon sheet cell 108.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 108 * 0x48;
;           no op-0x23 record in the four images carries this index.
; Image:    prom_b/images/DLGlyph_108_F79E88.png
; ---------------------------------------------------------------------
DLGlyph_108_F79E88:
	.incbin	"images/DLGlyph_108_F79E88.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_109_F79ED0 -- icon sheet cell 109.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 109 * 0x48;
;           named by 1 op-0x23 display-list record.
; Image:    prom_b/images/DLGlyph_109_F79ED0.png
; ---------------------------------------------------------------------
DLGlyph_109_F79ED0:
	.incbin	"images/DLGlyph_109_F79ED0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_110_F79F18 -- icon sheet cell 110.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 110 * 0x48;
;           named by 7 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_110_F79F18.png
; ---------------------------------------------------------------------
DLGlyph_110_F79F18:
	.incbin	"images/DLGlyph_110_F79F18.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_111_F79F60 -- icon sheet cell 111.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 111 * 0x48;
;           named by 3 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_111_F79F60.png
; ---------------------------------------------------------------------
DLGlyph_111_F79F60:
	.incbin	"images/DLGlyph_111_F79F60.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_112_F79FA8 -- icon sheet cell 112.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 112 * 0x48;
;           named by 2 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_112_F79FA8.png
; ---------------------------------------------------------------------
DLGlyph_112_F79FA8:
	.incbin	"images/DLGlyph_112_F79FA8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_113_F79FF0 -- icon sheet cell 113.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 113 * 0x48;
;           named by 1 op-0x23 display-list record.
; Image:    prom_b/images/DLGlyph_113_F79FF0.png
; ---------------------------------------------------------------------
DLGlyph_113_F79FF0:
	.incbin	"images/DLGlyph_113_F79FF0.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_114_F7A038 -- icon sheet cell 114.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 114 * 0x48;
;           named by 1 op-0x23 display-list record.
; Image:    prom_b/images/DLGlyph_114_F7A038.png
; ---------------------------------------------------------------------
DLGlyph_114_F7A038:
	.incbin	"images/DLGlyph_114_F7A038.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_115_F7A080 -- icon sheet cell 115.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 115 * 0x48;
;           named by 1 op-0x23 display-list record.
; Image:    prom_b/images/DLGlyph_115_F7A080.png
; ---------------------------------------------------------------------
DLGlyph_115_F7A080:
	.incbin	"images/DLGlyph_115_F7A080.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_116_F7A0C8 -- icon sheet cell 116.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 116 * 0x48;
;           named by 4 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_116_F7A0C8.png
; ---------------------------------------------------------------------
DLGlyph_116_F7A0C8:
	.incbin	"images/DLGlyph_116_F7A0C8.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_117_F7A110 -- icon sheet cell 117.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 117 * 0x48;
;           named by 4 op-0x23 display-list records.
; Image:    prom_b/images/DLGlyph_117_F7A110.png
; ---------------------------------------------------------------------
DLGlyph_117_F7A110:
	.incbin	"images/DLGlyph_117_F7A110.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

; ---------------------------------------------------------------------
; DLGlyph_118_F7A158 -- icon sheet cell 118.  24x24, 72 bytes, column-major.
; Evidence: DLHandler_Glyph24x24 (0xF31ACE) computes 0xF78028 + 118 * 0x48;
;           named by 1 op-0x23 display-list record.
; Image:    prom_b/images/DLGlyph_118_F7A158.png
; ---------------------------------------------------------------------
DLGlyph_118_F7A158:
	.incbin	"images/DLGlyph_118_F7A158.bin", 0, 72	; census: generated -- scripts/build/wsa1_bitmaps.py, from the .png beside it

	.fill	608, 1, 0x0E	; F7A1A0-F7A3FF  `ret` padding (asserted pure 0x0E)
