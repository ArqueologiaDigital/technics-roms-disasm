

; ==============================================================================
; 0xF4F000-0xF54FFF -- THE NINE-DRAWBAR ORGAN REGISTRATION SCREEN,
;                      AND THE TWO TABLE MODULES IN FRONT OF IT
; ==============================================================================
;
; 24,576 bytes, the largest `.incbin` that was left in prom_b.  43 segments:
; ascii 54, bytemap 129, code 5376, data 5978, dl 972, fill 4903, link 4692,
; ptrtab 28, romtab 2444.
;
; THE SCREEN.  Nine drawbars with Hammond-style footages 16' 5 1/3' 8' 4' 2
; 2/3' 2' 1 3/5' 1 1/3' 1', drawn at screen columns 3, 7, 11, 15, 19, 23, 27,
; 31, 35.  Each has a routine that steps one RAM nibble toward a target
; nibble, re-arms itself on a timer and redraws its own column; the five
; integer footages use one sprite and the four fractional ones the other, with
; no exception.  Below them are four parameters -- `PERCUSSIVE T0NE DECAY`,
; `PERCUSSIVE T0NE LEVEL`, `DRAWBAR ATTACK TIME` and `DRAWBAR RELEASE TIME` --
; whose values are the four nibbles of (0x2640)/(0x2641), each printed 25
; cells after the start of its own caption.
;
; ⚠ `T0NE` IS SPELT WITH A ZERO IN THE ROM, in both captions and in the header
;   strip.  It is reproduced exactly, not silently corrected: the machine
;   really shows it, and prom_b does the same in `S0NG`, `REC0RD` and
;   `C0MBINATI0N M0DE`.
;
; THE TWO MODULES IN FRONT.  0xF4F000-0xF5220D is table-heavy and is reached
; from prom_a: 81 distinct addresses inside the span are spelled by 134
; instructions in prom_a's PROVEN text and by none in prom_b's.  Its objects
; are 8 pointer tables, a 782-record link table whose 779 non-zero `next`
; pointers all land on its own record boundaries, a 110-record variable-length
; array framed by a 225-entry index, and a 129-byte code-to-index map.
;
; NAMING.  118 labels: 76 carry a semantic name and 42 stay `sub_XXXXXX` with
; the gap stated.  Of the semantic ones 71 state a MECHANISM and 5 are
; placeholders (Paint_DrawbarScreenLayout_DL2 Paint_DrawbarScreenLayout_DL1 Paint_DrawbarScreenLayout_Unchanged_DL2 Paint_DrawbarScreenLayout_Unchanged_DL1 Table_F542A4).  Every
; header carries an Evidence: line.
;
; ⚠ FIVE CORRECTIONS to notes/prom_b_f4f000_layout.py's committed HOLES text
;   are recorded in the headers below and re-derived by this emitter's
;   --selftest: C1 eight named points in 0xF4FA7A, not nine; C2 29 named
;   addresses in 0xF4FE38, not 31; C3 the trailing 0x00 at 0xF542D0 is entry 8
;   of DrawbarRowOffsets; C4 0xF542E1 is call-site proven; C5
;   RecordArray_F511DD IS framed, by RecordIndex_F51E8A.  No segment boundary
;   moves.
;
; REGENERATE:  python3 notes/gen_prom_b_f4f000_module.py
; CHECKS:      python3 notes/gen_prom_b_f4f000_module.py --selftest   (104
; checks)
; ==============================================================================

; --------------------------------------------------------------------------
; LCD_BlitValueBar_StackArgs -- the same veneer shape as DrawValueGlyph_Veneer, for a
; routine that has no name yet
; Called from: prom_a 0xFBE85C `call 0xf4f000`
; Evidence: `ld IX,(XIZ+0x08) / ld A,(XIZ+0x0a) / call 0xf415b4`; slot
;           T_LCD_BlitValueBar holds `jp 0x00F9458C`, which is `LCD_BlitValueBar` in
;           prom_a/wsa1_prom_a.s.
; Unknown: what the callee does.  Its target is unnamed, so naming the
;          veneer would be inventing a meaning the tree does not have.
; --------------------------------------------------------------------------
; LCD_BlitValueBar_StackArgs: frame-pointer wrapper: IX = stack argument 1 (zero-extended), A = argument 2, T_LCD_BlitValueBar, every register
;   it touches restored; called from CombiEditMixer_DrawVolume.  Basis: body.
LCD_BlitValueBar_StackArgs:
	push	xiz	; F4F000  push XIZ
	ld	xiz, xsp	; F4F001  ld XIZ,XSP
	push	xix	; F4F003  push XIX
	push	xhl	; F4F004  push XHL
	push	xde	; F4F005  push XDE
	ld	ix, (xiz+8)	; F4F006  ld IX,(XIZ+0x08)
	extz	xix	; F4F009  extz XIX
	ld	a, (xiz+10)	; F4F00B  ld A,(XIZ+0x0a)
	call	T_LCD_BlitValueBar	; F4F00E  call 0xf415b4
	pop	xde	; F4F012  pop XDE
	pop	xhl	; F4F013  pop XHL
	pop	xix	; F4F014  pop XIX
	pop	xiz	; F4F015  pop XIZ
	ret	; F4F016  ret

; --------------------------------------------------------------------------
; DrawValueGlyph_Veneer -- stack veneer for DrawValueGlyph_24x24
; Called from: prom_a 0xFBE7D4 `call 0xf4f017`; prom_a 0xFBE8E4 `call 0xf4f017`; prom_a 0xFBE96C `call 0xf4f017`
; Inputs:  (XIZ+8) = position -> IX, (XIZ+10) = value -> L
; Evidence: the body is `ld IX,(XIZ+0x08) / extz XIX / ld L,(XIZ+0x0a) /
;           call 0xf41834`, and thunk slot T_DrawValueGlyph_24x24 holds `jp 0x00F31873`.
;           0xF31873 is DrawValueGlyph_24x24 in this file, whose stated
;           inputs are exactly `L = value; IX = position`.  Both halves of
;           the name come from a label the tree already carries.
; --------------------------------------------------------------------------
DrawValueGlyph_Veneer:
	push	xiz	; F4F017  push XIZ
	ld	xiz, xsp	; F4F018  ld XIZ,XSP
	push	xix	; F4F01A  push XIX
	push	xhl	; F4F01B  push XHL
	push	xde	; F4F01C  push XDE
	ld	ix, (xiz+8)	; F4F01D  ld IX,(XIZ+0x08)
	extz	xix	; F4F020  extz XIX
	ld	l, (xiz+10)	; F4F022  ld L,(XIZ+0x0a)
	call	T_DrawValueGlyph_24x24	; F4F025  call 0xf41834
	pop	xde	; F4F029  pop XDE
	pop	xhl	; F4F02A  pop XHL
	pop	xix	; F4F02B  pop XIX
	pop	xiz	; F4F02C  pop XIZ
	ret	; F4F02D  ret

; --------------------------------------------------------------------------
; PartSound_StepBankGroupMember
; Called from: prom_a 0xFBBA9B `call 0xf4f02e`
; Touches: (0x60f018), (0x002760), (0x28b0), (0x60f01d), (0x002761),
;          (0x002762), (0x002763), (0x002764), (0x08e8), (0x08ec)
; Evidence: the call site above; 0xF4F02E is an instruction boundary of this
;           transcription, re-asserted on every emit.
; Unknown: what the routine is FOR.  A stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; PartSound_StepBankGroupMember: loads part E's sound from its record -- +0x3D bank, +0x3B group, +0x3C member, SoundGroup_LoadSelectionFromPart's
;   offsets -- into 0x2761 / 0x2762 / 0x2763 and steps it like an odometer, one step in the direction of
;   PanelEvent_Flags bit 0 (set = down).  The member steps first (PartSound_StepIndexClamped, bounded by
;   SoundGroup_MaxMemberIndex_Get); when it cannot move, the group; when that cannot move, the bank, through
;   PartSound_BankOrder.  The levels below the one that moved restart at 0 when stepping up and at their
;   maximum when stepping down (`bit 7,W` arms, 0xF4F155 / 0xF4F1DF).
;   The result is posted for part E as two List2030_AppendRegs records, (bank, bank) and (group, member).
;   Called by PartParam_StepSound.
PartSound_StepBankGroupMember:
	push	xiz	; F4F02E  push XIZ
	ld	xiz, xsp	; F4F02F  ld XIZ,XSP
	push	xix	; F4F031  push XIX
	push	xhl	; F4F032  push XHL
	push	xde	; F4F033  push XDE
	ld	xiy, (IndexedTable_Base:24)	; F4F034  ld XIY,(0x60f018)
	ld	l, (xiz+8)	; F4F039  ld L,(XIZ+0x08)
	extz	hl	; F4F03C  extz HL
	sla	hl, 2	; F4F03E  sla 0x02,HL
	ld	xiy, (xiy+hl)	; F4F041  ld XIY,(XIY+HL)
	ld	a, (xiz+8)	; F4F046  ld A,(XIZ+0x08)
	ld	(10080:24), a	; F4F049  ld (0x002760),A
	ld	w, (PanelEvent_Flags:16)	; F4F04E  ld W,(0x28b0)
	and	w, 1	; F4F052  and W,0x01
	sll	w, 7	; F4F055  sll 0x07,W
	or	w, 1	; F4F058  or W,0x01
	and	w, 129	; F4F05B  and W,0x81
	push	w	; F4F05E  push W
	ld	h, (xiy+1)	; F4F060  ld H,(XIY+0x01)
	and	h, 127	; F4F063  and H,0x7f
	ld	l, (xiy+0:8)	; F4F066  ld L,(XIY+0x00)
	and	l, 127	; F4F069  and L,0x7f
	ld	a, (10080:24)	; F4F06C  ld A,(0x002760)
	ld	(6352925:24), a	; F4F071  ld (0x60f01d),A
	ld	w, (xiy+61)	; F4F076  ld W,(XIY+0x3d)
	ld	l, (xiy+59)	; F4F079  ld L,(XIY+0x3b)
	ld	h, (xiy+60)	; F4F07C  ld H,(XIY+0x3c)
	ld	(10081:24), w	; F4F07F  ld (0x002761),W
	ld	(10082:24), l	; F4F084  ld (0x002762),L
	ld	(10083:24), h	; F4F089  ld (0x002763),H
	ld	a, l	; F4F08E  ld A,L
	ld	b, (10080:24)	; F4F090  ld B,(0x002760)
	call	T_SoundGroup_MaxMemberIndex_Get	; F4F095  call 0xf4101c
	ld	(10084:24), a	; F4F099  ld (0x002764),A
	extz	wa	; F4F09E  extz WA
	ld	ix, wa	; F4F0A0  ld IX,WA
	ldw	iy, 0	; F4F0A2  ld IY,0x0000
	pop	w	; F4F0A5  pop W
	ld	l, (10083:24)	; F4F0A7  ld L,(0x002763)
	extz	hl	; F4F0AC  extz HL
	ld	de, hl	; F4F0AE  ld DE,HL
	push	w	; F4F0B0  push W
	pushw	hl	; F4F0B2  push HL
	call	PartSound_StepIndexClamped	; F4F0B3  call 0xf4f27e
	popw	hl	; F4F0B7  pop HL
	pop	w	; F4F0B8  pop W
	cp	de, hl	; F4F0BA  cp DE,HL
	jrl	nz, PartSound_StepBankGroupMember_Skip13	; F4F0BC  jrl NZ,0xf4f23f
	cp	(0x002761:24), 0x10	; F4F0BF  cp (0x002761),0x10
	jr	nz, PartSound_StepBankGroupMember_Skip	; F4F0C5  jr NZ,0xf4f0d3
	ld	c, (2280:16)	; F4F0C7  ld C,(0x08e8)
	dec	1, c	; F4F0CB  dec 1,C
	xor	b, b	; F4F0CD  xor B,B
	ld	ix, bc	; F4F0CF  ld IX,BC
	jr	PartSound_StepBankGroupMember_Join	; F4F0D1  jr T,0xf4f0f3
PartSound_StepBankGroupMember_Skip:
	bit	4, (0x002761:24)	; F4F0D3  bit 4,(0x002761)
	jr	nz, PartSound_StepBankGroupMember_Skip2	; F4F0D8  jr NZ,0xf4f0f0
	bit	5, (0x002761:24)	; F4F0DA  bit 5,(0x002761)
	jr	z, PartSound_StepBankGroupMember_Skip2	; F4F0DF  jr Z,0xf4f0f0
	ldw	ix, 1	; F4F0E1  ld IX,0x0001
	bit	3, (0x002761:24)	; F4F0E4  bit 3,(0x002761)
	jr	z, PartSound_StepBankGroupMember_Join	; F4F0E9  jr Z,0xf4f0f3
	ldw	ix, 0	; F4F0EB  ld IX,0x0000
	jr	PartSound_StepBankGroupMember_Join	; F4F0EE  jr T,0xf4f0f3
PartSound_StepBankGroupMember_Skip2:
	ldw	ix, 15	; F4F0F0  ld IX,0x000f
PartSound_StepBankGroupMember_Join:
	ldw	iy, 0	; F4F0F3  ld IY,0x0000
	ld	e, (10082:24)	; F4F0F6  ld E,(0x002762)
	extz	de	; F4F0FB  extz DE
	ld	hl, de	; F4F0FD  ld HL,DE
	push	w	; F4F0FF  push W
	pushw	hl	; F4F101  push HL
	call	PartSound_StepIndexClamped	; F4F102  call 0xf4f27e
	popw	hl	; F4F106  pop HL
	pop	w	; F4F107  pop W
	cp	de, hl	; F4F109  cp DE,HL
	jrl	nz, PartSound_StepBankGroupMember_Skip8	; F4F10B  jrl NZ,0xf4f1da
	ld	xix, PartSound_BankOrder	; F4F10E  ld XIX,0x00f4f273
	ld	l, (10081:24)	; F4F113  ld L,(0x002761)
	xor	de, de	; F4F118  xor DE,DE
PartSound_StepBankGroupMember_Join2:
	cp	l, (xix+de)	; F4F11A  cp L,(XIX+DE)
	jr	z, PartSound_StepBankGroupMember_Loop	; F4F11F  jr Z,0xf4f125
	inc	1, de	; F4F121  inc 1,DE
	jr	PartSound_StepBankGroupMember_Join2	; F4F123  jr T,0xf4f11a
PartSound_StepBankGroupMember_Loop:
	ld	hl, de	; F4F125  ld HL,DE
	ldw	ix, 10	; F4F127  ld IX,0x000a
	ldw	iy, 0	; F4F12A  ld IY,0x0000
	push	w	; F4F12D  push W
	pushw	hl	; F4F12F  push HL
	call	PartSound_StepIndexClamped	; F4F130  call 0xf4f27e
	popw	hl	; F4F134  pop HL
	pop	w	; F4F135  pop W
	cp	de, hl	; F4F137  cp DE,HL
	jrl	z, PartSound_StepBankGroupMember_Epilogue	; F4F139  jrl Z,0xf4f26e
	bit	0, (0x08ec:16)	; F4F13C  bit 0,(0x08ec)
	jr	nz, PartSound_StepBankGroupMember_Skip3	; F4F140  jr NZ,0xf4f146
	cp	e, 4:i3	; F4F142  cp E,4
	jr	z, PartSound_StepBankGroupMember_Loop	; F4F144  jr Z,0xf4f125
PartSound_StepBankGroupMember_Skip3:
	ld	xix, PartSound_BankOrder	; F4F146  ld XIX,0x00f4f273
	ld	a, (xix+de)	; F4F14B  ld A,(XIX+DE)
	ld	(10081:24), a	; F4F150  ld (0x002761),A
	bit	7, w	; F4F155  bit 0x07,W
	jr	z, PartSound_StepBankGroupMember_Skip7	; F4F158  jr Z,0xf4f1cc
	cp	(0x002761:24), 0x10	; F4F15A  cp (0x002761),0x10
	jr	nz, PartSound_StepBankGroupMember_Skip4	; F4F160  jr NZ,0xf4f189
	push	w	; F4F162  push W
	ld	c, (2280:16)	; F4F164  ld C,(0x08e8)
	dec	1, c	; F4F168  dec 1,C
	ld	(10082:24), c	; F4F16A  ld (0x002762),C
	ld	a, c	; F4F16F  ld A,C
	ld	w, (10081:24)	; F4F171  ld W,(0x002761)
	ld	b, (10080:24)	; F4F176  ld B,(0x002760)
	call	T_SoundGroup_MaxMemberIndex_Get	; F4F17B  call 0xf4101c
	pop	w	; F4F17F  pop W
	ld	(10083:24), a	; F4F181  ld (0x002763),A
	jrl	PartSound_StepBankGroupMember_Join3	; F4F186  jrl T,0xf4f244
PartSound_StepBankGroupMember_Skip4:
	bit	4, (0x002761:24)	; F4F189  bit 4,(0x002761)
	jr	nz, PartSound_StepBankGroupMember_Skip6	; F4F18E  jr NZ,0xf4f1be
	bit	5, (0x002761:24)	; F4F190  bit 5,(0x002761)
	jr	z, PartSound_StepBankGroupMember_Skip6	; F4F195  jr Z,0xf4f1be
	ld	(10082:24), 1	; F4F197  ld (0x002762),0x01
	bit	3, (0x002761:24)	; F4F19D  bit 3,(0x002761)
	jr	z, PartSound_StepBankGroupMember_Skip5	; F4F1A2  jr Z,0xf4f1b4
	ld	(10082:24), 0	; F4F1A4  ld (0x002762),0x00
	ld	(10083:24), 1	; F4F1AA  ld (0x002763),0x01
	jp	PartSound_StepBankGroupMember_Join3	; F4F1B0  jp 0xf4f244
PartSound_StepBankGroupMember_Skip5:
	ld	(10083:24), 7	; F4F1B4  ld (0x002763),0x07
	jp	PartSound_StepBankGroupMember_Join3	; F4F1BA  jp 0xf4f244
PartSound_StepBankGroupMember_Skip6:
	ld	(10083:24), 7	; F4F1BE  ld (0x002763),0x07
	ld	(10082:24), 15	; F4F1C4  ld (0x002762),0x0f
	jr	PartSound_StepBankGroupMember_Join3	; F4F1CA  jr T,0xf4f244
PartSound_StepBankGroupMember_Skip7:
	ld	(10082:24), 0	; F4F1CC  ld (0x002762),0x00
	ld	(10083:24), 0	; F4F1D2  ld (0x002763),0x00
	jr	PartSound_StepBankGroupMember_Join3	; F4F1D8  jr T,0xf4f244
PartSound_StepBankGroupMember_Skip8:
	ld	(10082:24), e	; F4F1DA  ld (0x002762),E
	bit	7, w	; F4F1DF  bit 0x07,W
	jr	z, PartSound_StepBankGroupMember_Skip12	; F4F1E2  jr Z,0xf4f237
	cp	(0x002761:24), 0x10	; F4F1E4  cp (0x002761),0x10
	jr	nz, PartSound_StepBankGroupMember_Skip9	; F4F1EA  jr NZ,0xf4f20a
	push	w	; F4F1EC  push W
	ld	a, (10082:24)	; F4F1EE  ld A,(0x002762)
	ld	w, (10081:24)	; F4F1F3  ld W,(0x002761)
	ld	b, (10080:24)	; F4F1F8  ld B,(0x002760)
	call	T_SoundGroup_MaxMemberIndex_Get	; F4F1FD  call 0xf4101c
	pop	w	; F4F201  pop W
	ld	(10083:24), a	; F4F203  ld (0x002763),A
	jr	PartSound_StepBankGroupMember_Join3	; F4F208  jr T,0xf4f244
PartSound_StepBankGroupMember_Skip9:
	bit	4, (0x002761:24)	; F4F20A  bit 4,(0x002761)
	jr	nz, PartSound_StepBankGroupMember_Skip11	; F4F20F  jr NZ,0xf4f22f
	bit	5, (0x002761:24)	; F4F211  bit 5,(0x002761)
	jr	z, PartSound_StepBankGroupMember_Skip11	; F4F216  jr Z,0xf4f22f
	bit	3, (0x002761:24)	; F4F218  bit 3,(0x002761)
	jr	z, PartSound_StepBankGroupMember_Skip10	; F4F21D  jr Z,0xf4f227
	ld	(10083:24), 1	; F4F21F  ld (0x002763),0x01
	jr	PartSound_StepBankGroupMember_Join3	; F4F225  jr T,0xf4f244
PartSound_StepBankGroupMember_Skip10:
	ld	(10083:24), 7	; F4F227  ld (0x002763),0x07
	jr	PartSound_StepBankGroupMember_Join3	; F4F22D  jr T,0xf4f244
PartSound_StepBankGroupMember_Skip11:
	ld	(10083:24), 7	; F4F22F  ld (0x002763),0x07
	jr	PartSound_StepBankGroupMember_Join3	; F4F235  jr T,0xf4f244
PartSound_StepBankGroupMember_Skip12:
	ld	(10083:24), 0	; F4F237  ld (0x002763),0x00
	jr	PartSound_StepBankGroupMember_Join3	; F4F23D  jr T,0xf4f244
PartSound_StepBankGroupMember_Skip13:
	ld	(10083:24), e	; F4F23F  ld (0x002763),E
PartSound_StepBankGroupMember_Join3:
	ld	e, (10080:24)	; F4F244  ld E,(0x002760)
	ld	d, 0:opc	; F4F249  ld D,0x00
	ld	a, (10081:24)	; F4F24B  ld A,(0x002761)
	ld	w, (10081:24)	; F4F250  ld W,(0x002761)
	call	T_List2030_AppendRegs	; F4F255  call 0xf40f40
	ld	e, (10080:24)	; F4F259  ld E,(0x002760)
	ld	d, 0:opc	; F4F25E  ld D,0x00
	ld	a, (10082:24)	; F4F260  ld A,(0x002762)
	ld	w, (10083:24)	; F4F265  ld W,(0x002763)
	call	T_List2030_AppendRegs	; F4F26A  call 0xf40f40
PartSound_StepBankGroupMember_Epilogue:
	pop	xde	; F4F26E  pop XDE
	pop	xhl	; F4F26F  pop XHL
	pop	xix	; F4F270  pop XIX
	pop	xiz	; F4F271  pop XIZ
	ret	; F4F272  ret

; --- 0xF4F273-0xF4F27D  data (11 bytes) ---
; PartSound_BankOrder: the 11 bank codes in the order PartSound_StepBankGroupMember steps them: R1 0x00, R2 0x01, U1 0x08, U2 0x09,
;   E1 0x10, RD 0x20, UD1 0x28, UD2 0x29, then the RE-MAP banks 0x18-0x1A (SoundSel_Bank's codes).  The stepper
;   finds the current bank's index by a linear search of this table (0xF4F11A).
PartSound_BankOrder:
	.byte 0x00, 0x01, 0x08, 0x09, 0x10, 0x20, 0x28, 0x29, 0x18, 0x19, 0x1a   ; F4F273  ..... ()...

; --------------------------------------------------------------------------
; PartSound_StepIndexClamped
; Called from: call from 0xF4F0B3, 0xF4F102, 0xF4F130
; Evidence: 0xF4F27E is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; PartSound_StepIndexClamped: DE += PartSound_SignedStepTable[W'], where W' = W bits 0-2 (the size) plus W bit 7 moved to bit 3 (the sign;
;   entries 8-15 are 0, -1 .. -7).  A result that goes negative becomes 0.  It is then clamped to IY..IX.
;   Called three times by PartSound_StepBankGroupMember, which compares DE before and after to see whether the
;   level could move.
PartSound_StepIndexClamped:
	ld	l, w	; F4F27E  ld L,W
	and	l, 7	; F4F280  and L,0x07
	and	w, 128	; F4F283  and W,0x80
	srl	w, 4	; F4F286  srl 0x04,W
	or	w, l	; F4F289  or W,L
	ld	xhl, PartSound_SignedStepTable	; F4F28B  ld XHL,0x00f4f2b2
	ld	l, (xhl+w)	; F4F290  ld L,(XHL+W)
	exts	hl	; F4F295  exts HL
	add	de, hl	; F4F297  add DE,HL
	bit	15, de	; F4F299  bit 0x0f,DE
	jr	z, PartSound_StepIndexClamped_Skip	; F4F29C  jr Z,0xf4f2a5
	bit	15, hl	; F4F29E  bit 0x0f,HL
	jr	z, PartSound_StepIndexClamped_Skip2	; F4F2A1  jr Z,0xf4f2ab
	xor	de, de	; F4F2A3  xor DE,DE
PartSound_StepIndexClamped_Skip:
	cp	de, iy	; F4F2A5  cp DE,IY
	jr	nc, PartSound_StepIndexClamped_Skip2	; F4F2A7  jr NC,0xf4f2ab
	ld	de, iy	; F4F2A9  ld DE,IY
PartSound_StepIndexClamped_Skip2:
	cp	de, ix	; F4F2AB  cp DE,IX
	jr	ule, PartSound_StepIndexClamped_Return	; F4F2AD  jr ULE,0xf4f2b1
	ld	de, ix	; F4F2AF  ld DE,IX
PartSound_StepIndexClamped_Return:
	ret	; F4F2B1  ret

; --- 0xF4F2B2-0xF4F2C1  data (16 bytes) ---
; PartSound_SignedStepTable: 16 signed steps 0..7, then 0, -1 .. -7, indexed by PartSound_StepIndexClamped's W'.
PartSound_SignedStepTable:
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x00, 0xff, 0xfe, 0xfd, 0xfc, 0xfb, 0xfa, 0xf9   ; F4F2B2  ................
	jp	PartSound_SignedStepTable_Join	; F4F2C2  jp 0xf4f2da
	ret	; F4F2C6  ret
	nop	; F4F2C7  nop
	nop	; F4F2C8  nop
	nop	; F4F2C9  nop
	ret	; F4F2CA  ret
	nop	; F4F2CB  nop
	nop	; F4F2CC  nop
	nop	; F4F2CD  nop
	ret	; F4F2CE  ret
	nop	; F4F2CF  nop
	nop	; F4F2D0  nop
	nop	; F4F2D1  nop
	ret	; F4F2D2  ret
	nop	; F4F2D3  nop
	nop	; F4F2D4  nop
	nop	; F4F2D5  nop
	ret	; F4F2D6  ret
	nop	; F4F2D7  nop
	nop	; F4F2D8  nop
	nop	; F4F2D9  nop
PartSound_SignedStepTable_Join:
	calr	PartSound_InitRam	; F4F2DA  calr 0xf4f2de
	ret	; F4F2DD  ret

; --------------------------------------------------------------------------
; PartSound_InitRam
; Called from: call from 0xF4F2DA
; Evidence: 0xF4F2DE is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; PartSound_InitRam: The PartSound module's RAM init, shaped like NoteRouting_InitRam: an empty data copy (count 0),
;   then the 32 bytes at 0x2760 zeroed -- the RAM PartSound_StepBankGroupMember uses. Reached from slot 0 of the phase
;   vector at 0xF4F2C2 (`jp` -> `calr PartSound_InitRam / ret`), which no directory slot or pointer in either ROM names (byte
;   scan). Basis: phase-vector layout + body + RAM owner. (notes/naming-pilot-2026-10-06/proposals_wave4_n.json)
PartSound_InitRam:
	ld	xbc, 0	; F4F2DE  ld XBC,0x00000000
	and	xbc, xbc	; F4F2E3  and XBC,XBC
	jr	z, PartSound_InitRam_Skip	; F4F2E5  jr Z,0xf4f2f3
	lda	xiy, (PartSound_InitRam + 0x2F:24)	; F4F2E7  lda XIY,0xf4f30d
	lda	xix, (0:24)	; F4F2EC  lda XIX,0x000000
	ldir85	; F4F2F1  ldir
PartSound_InitRam_Skip:
	ld	xbc, 32	; F4F2F3  ld XBC,0x00000020
	and	xbc, xbc	; F4F2F8  and XBC,XBC
	jr	z, PartSound_InitRam_Return	; F4F2FA  jr Z,0xf4f30c
	lda	xix, (10080:24)	; F4F2FC  lda XIX,0x002760
	xor	wa, wa	; F4F301  xor WA,WA
PartSound_InitRam_Loop:
	ld	(xix+), a	; F4F303  ld (XIX+),A
	sub	bc, 1	; F4F306  sub BC,0x0001
	jr	nz, PartSound_InitRam_Loop	; F4F30A  jr NZ,0xf4f303

; PartSound_InitRam's own `ret`: the first byte of the 0x0E run, the target of its `jr z` at 0xF4F2FA
PartSound_InitRam_Return:
	ret	; F4F30C  ret
; --- 0xF4F30D-0xF4F7FF  fill (1267 bytes) ---
	.fill	1267, 1, 0x0E	; asserted a single value
