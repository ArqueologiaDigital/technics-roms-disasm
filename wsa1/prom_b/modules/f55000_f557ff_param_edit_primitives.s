
; ==============================================================================
; 0xF55000-0xF5535A -- PARAMETER-EDIT PRIMITIVES AND TWO TABLE ACCESSORS
; ==============================================================================
;
; A linker section: 65 bytes of 0x0E (`ret`) fill end at 0xF54FFF, then 25 bytes
; of 4-byte `0E 00 00 00` slot fill, then nine routines, the last of which ends
; on a `ret` at 0xF5535A with the next `link XIZ` at 0xF5535B.
;
; Four of the nine are named by thunk slots that the census ranks near the top of
; the whole table (`python3 scripts/analysis/prom_b_thunk_table.py --census`):
;   T_IndexedTable_GetByte -> 0xF5533C  119 opcode-anchored references
;   T_EditValue_StepBitField -> 0xF550A6   77
;   T_IndexedTable_GetPtr -> 0xF55321   45
;   T_TableDefault_Ret -> 0xF55018  never called, but its 4-byte slot ADDRESS (`70 2C F4
;                         00`) occurs 397 times in prom_a+prom_b, 222 of them in
;                         one run at prom_a 0x216B4.  This block settles what it
;                         is: 0xF55018 is a single byte 0x0E -- a bare `ret`.
;                         The pointer table it fills is filled with a NO-OP.
;
; ⚠ The subsystem these belong to is NOT established.  Each header below says
; what its routine does to memory and nothing more.
; ==============================================================================

; --- 0xF55000-0xF55018: fill.  Six 4-byte slots of `0E 00 00 00` and one more
;     `0E`, the same `ret`-in-every-slot convention the thunk table uses. -----
	.byte 0x0E, 0x00, 0x00, 0x00
	.byte 0x0E, 0x00, 0x00, 0x00
	.byte 0x0E, 0x00, 0x00, 0x00
	.byte 0x0E, 0x00, 0x00, 0x00
	.byte 0x0E, 0x00, 0x00, 0x00
	.byte 0x0E, 0x00, 0x00, 0x00
; ---------------------------------------------------------------------
; Stub_Ret_F55018 -- the do-nothing entry the thunk table's most-spelled slot
;                    points at
; Called from: thunk T_TableDefault_Ret (0xF42C70).  That slot is never the operand of a
;              call or jp; its 32-bit ADDRESS appears 397 times as data.
; Inputs:  none.  Outputs: none.
; Evidence: the byte at 0xF55018 is 0x0E, which is RET
;           (mame/src/devices/cpu/tlcs900/dasm900.cpp:1267, M_RET at opcode 0x0E).
; Unknown:  which table those 397 words belong to.
; ---------------------------------------------------------------------
Stub_Ret_F55018:
	ret	; F55018  ret

; ---------------------------------------------------------------------
; PanelCode_ToSlotAndFlags -- normalise a selector index and rebuild the flag byte (0x28B0)
; Called from: thunk T_PanelCode_ToSlotAndFlags (0xF42C74), which four screen-module
;              dispatchers call before `mul A,4 / add XWA,<their table>`:
;              ScreenButtonBody_DspEffect (0xF0F194), ScreenButtonBody_MainOutEqualizer (0xF12347), ScreenButton_CreatorSelectController and
;              DrawbarScreen_Dispatch (0xF5303D).  prom_a's Screen_*_Button
;              methods reach it the same way.
; Inputs:  (XIZ+8) = 16-bit index, (XIZ+0x0A) = 16-bit flags
; Outputs: A = the adjusted index; (0x28B1) = the original index;
;          (0x28B0) = a freshly built flag byte
; Evidence: `cp HL,0x1F / jrl UGT` rejects an index above 0x1F without touching
;           anything; then (0x28B0) is cleared and set bit by bit --
;             bit 0 <- bit 7 of the second argument
;             bit 1 <- (0x208C) AND the 32-bit word at 0xF55755 + 4*(0x28B1)
;             bit 2 <- index in 0x11..0x19, and the index has 0x11 subtracted
;             bit 5 <- index == 0x1B and (0x2267) == 0x0F
;           an index >= 0x1A additionally has 9 subtracted.
; ★ WHAT THE INDEX ENUMERATES, answered round 11: it is the PANEL BUTTON
;           CODE, the five bits prom_a PanelButton_Route masks out at 0xF861AE.
;           This routine is the far end of the panel chain, and each flag bit
;           says which link the event came down:
;             bit 0 = the PAIR POSITION -- bit 7 of the code byte, which selects
;                     which member of a two-switch pair moved;
;             bit 2 = the event was REWRITTEN by the action handlers 0xF8AE68/
;                     0xF8AEDB (`add (XIX-1),0x11`), and the fold that sets it
;                     is the exact inverse of that rewrite;
;             bit 5 = the number-pad code 0x1B with (0x2267) == 0x0F, the same
;                     two constants the five number-pad handlers in the 0xF7E2D8
;                     span open with (`ld A,(0x2267) / cp A,0x0f`).
;           So 0..22 is a SLOT, not a code: the 23-entry dispatch tables are not
;           indexed by the raw event code.
;           notes/prom_b_panel_names_round11.py --selftest;
;           notes/wave7_panel_event_index.py; notes/wave7_panel_button_codes.py.
; Unknown:  what 0x208C and 0x2267 hold.
; ⚠ CORRECTED 2026-08-30.  This paragraph used to end "...and what the 32-bit
;           mask table at 0xF55755 is.  That table is NOT converted here:
;           nothing bounds its length."  BOTH halves are now wrong.  The table
;           IS converted, as Bit32MaskTable at 0xF55755, and its word i is
;           EXACTLY 1 << i for i = 0..31 -- so it is a power-of-two mask indexed
;           by the selector, and `and XBC,(0x208c)` at 0xF55055 is a membership
;           test against a 32-bit set.  And its length WAS bounded, by this very
;           routine: the `cp HL,0x001f / jrl UGT,0xF550A1` at 0xF55026 rejects a
;           selector above 31 before anything is read, so the index space is
;           0..31 and the table is 32 words = 128 bytes.  Measured and emitted by
;           notes/gen_prom_b_f5553f_module.py (--selftest re-reads all 32 words).
; ---------------------------------------------------------------------
PanelCode_ToSlotAndFlags:
	link XIZ,0x0000	; F55019  link XIZ,0x0000
	pushw	hl	; F5501D  push HL
	push	xix	; F5501E  push XIX
	lda	xix, (PanelEvent_Flags:16)	; F5501F  lda XIX,0x28b0
	ld	hl, (xiz+8)	; F55023  ld HL,(XIZ+0x08)
	cp	hl, 31	; F55026  cp HL,0x001f
	jrl	ugt, PanelCode_ToSlotAndFlags_Skip6	; F5502A  jrl UGT,0xf550a1
	ld	(PanelEvent_ButtonCode:16), l	; F5502D  ld (0x28b1),L
	ld	(xix), 0	; F55031  ld (XIX),0x00
	ld	bc, (xiz+10)	; F55034  ld BC,(XIZ+0x0a)
	and	bc, 128	; F55037  and BC,0x0080
	jr	z, PanelCode_ToSlotAndFlags_Skip	; F5503B  jr Z,0xf55042
	ld	(xix), 1	; F5503D  ld (XIX),0x01
	jr	PanelCode_ToSlotAndFlags_Join	; F55040  jr T,0xf55045
PanelCode_ToSlotAndFlags_Skip:
	ld	(xix), 0	; F55042  ld (XIX),0x00
PanelCode_ToSlotAndFlags_Join:
	ld	c, 4:opc	; F55045  ld C,0x04
	mul	bc, (PanelEvent_ButtonCode:16)	; F55047  mul BC,(0x28b1)
	extz	xbc	; F5504B  extz XBC
	add	xbc, Bit32MaskTable	; F5504D  add XBC,0x00f55755
	ld	xbc, (xbc)	; F55053  ld XBC,(XBC)
	and	xbc, (0x208c:16)	; F55055  and XBC,(0x208c)
	jr	z, PanelCode_ToSlotAndFlags_Skip2	; F55059  jr Z,0xf5505e
	or	(xix), 0x02	; F5505B  or (XIX),0x02
PanelCode_ToSlotAndFlags_Skip2:
	cp	(PanelEvent_ButtonCode:16), 0x11	; F5505E  cp (0x28b1),0x11
	jr	c, PanelCode_ToSlotAndFlags_Skip3	; F55063  jr C,0xf5507a
	cp	(PanelEvent_ButtonCode:16), 0x19	; F55065  cp (0x28b1),0x19
	jr	ugt, PanelCode_ToSlotAndFlags_Skip3	; F5506A  jr UGT,0xf5507a
	or	(xix), 0x04	; F5506C  or (XIX),0x04
	ld	hl, (PanelEvent_ButtonCode:16)	; F5506F  ld HL,(0x28b1)
	extz	hl	; F55073  extz HL
	ldw	bc, 17	; F55075  ld BC,0x0011
	sub	hl, bc	; F55078  sub HL,BC
PanelCode_ToSlotAndFlags_Skip3:
	cp	(PanelEvent_ButtonCode:16), 0x1a	; F5507A  cp (0x28b1),0x1a
	jr	c, PanelCode_ToSlotAndFlags_Skip4	; F5507F  jr C,0xf5508c
	ld	hl, (PanelEvent_ButtonCode:16)	; F55081  ld HL,(0x28b1)
	extz	hl	; F55085  extz HL
	ldw	bc, 9	; F55087  ld BC,0x0009
	sub	hl, bc	; F5508A  sub HL,BC
PanelCode_ToSlotAndFlags_Skip4:
	cp	(PanelEvent_ButtonCode:16), 0x1b	; F5508C  cp (0x28b1),0x1b
	jr	nz, PanelCode_ToSlotAndFlags_Skip5	; F55091  jr NZ,0xf5509d
	cp	(0x2267:16), 0x0f	; F55093  cp (0x2267),0x0f
	jr	nz, PanelCode_ToSlotAndFlags_Skip5	; F55098  jr NZ,0xf5509d
	or	(xix), 0x20	; F5509A  or (XIX),0x20
PanelCode_ToSlotAndFlags_Skip5:
	ld	c, l	; F5509D  ld C,L
	ld	a, c	; F5509F  ld A,C
PanelCode_ToSlotAndFlags_Skip6:
	pop	xix	; F550A1  pop XIX
	popw	hl	; F550A2  pop HL
	unlk XIZ	; F550A3  unlk XIZ
	ret	; F550A5  ret

; ---------------------------------------------------------------------
; EditValue_StepBitField -- read a bit-field through an 8-byte descriptor and range-check it
; Called from: thunk T_EditValue_StepBitField (0xF42C78), 77 opcode-anchored references
; Inputs:  (XIZ+8) = 32-bit pointer to the source byte,
;          (XIZ+0x0C) = 32-bit pointer to an 8-byte descriptor
; Outputs: register results; (0x28B0) is XORed with descriptor byte +7 and bit 3
;          of (0x2075) is set
; Evidence: `ld E,(XBC)` reads the source byte, `and D,E` masks it with
;           descriptor +1, then a loop shifts D right and counts in L until L
;           reaches descriptor +2 -- i.e. it normalises the field.  Descriptor
;           +3/+4 are the clamp bounds, +5/+6 are alternative step values chosen
;           by bits of (0x2075) and (0x28B0), +7 is the flag XOR mask.
;           The routine does not only READ: after the adjust it writes the field
;           back (`and (XBC),H / or A,D / ld (XBC),A` at 0xF55161) and returns
;           A = 1, or returns A = 0 unchanged when `cp H,D` at 0xF5513D finds
;           the value did not move.
; ⚠ CORRECTED 2026-08-25.  This header used to end "0xF5535B, just past this
;           block, is the same routine with the two pointer arguments swapped."
;           Both halves are wrong.  0xF5535B's first argument is an INDEX, not a
;           pointer -- it resolves the target through IndexedTable_GetPtr and
;           then adds descriptor +0 -- and it journals every change to
;           List2030_Append4 or Queue2C00_Append4, which this routine does not
;           do at all.  What the two really share is the 100-byte ADJUST CORE,
;           identical in 99 of 100 bytes (the one difference is a frame
;           displacement).  Measured by notes/prom_b_param_edit_pair.py; the
;           converted routine is IndexedParam_AdjustField below.
; Unknown:  what the descriptor describes.
; ---------------------------------------------------------------------
; EditValue_StepBitField: steps a bit-field of the byte at the first argument through the field record XIX: +1 mask, +2 shift, +3 maximum,
;   +4 minimum, +5 / +6 step sizes (chosen by PanelEvent_Flags bit 2 / UI_RequestBits bit 2), +7 PanelEvent_Flags XOR;
;   up when PanelEvent_Flags bit 0, else down, clamped, written back under the mask (77 call sites).
;   CORRECTED 2026-10-04: the other way round.  After the +7 XOR, bit 0 SET steps DOWN (`sub H,A`, bounded
;   by +4, 0xF55116) and CLEAR steps UP (`add H,C`, bounded by +3, 0xF55136) -- the sense IndexedParam_SetBit's
;   header gives (notes/prom_ab_read_names_2026_10_04.py, PartSound_StepIndexClamped).
EditValue_StepBitField:
	link XIZ,0xfffe	; F550A6  link XIZ,0xfffe
	pushw	hl	; F550AA  push HL
	pushw	de	; F550AB  push DE
	push	xix	; F550AC  push XIX
	ld	xix, (xiz+12)	; F550AD  ld XIX,(XIZ+0x0c)
	ld	c, (xix+7)	; F550B0  ld C,(XIX+0x07)
	xor	(PanelEvent_Flags:16), c	; F550B3  xor (0x28b0),C
	set	3, (UI_RequestBits:16)	; F550B7  set 3,(0x2075)
	ld	xbc, (xiz+8)	; F550BB  ld XBC,(XIZ+0x08)
	ld	e, (xbc)	; F550BE  ld E,(XBC)
	ld	a, (xix+1)	; F550C0  ld A,(XIX+0x01)
	ld	d, a	; F550C3  ld D,A
	and	d, e	; F550C5  and D,E
	ld	l, 0:opc	; F550C7  ld L,0x00
	ld	h, (xix+2)	; F550C9  ld H,(XIX+0x02)
EditValue_StepBitField_Join:
	cp	l, h	; F550CC  cp L,H
	jr	nc, EditValue_StepBitField_Skip	; F550CE  jr NC,0xf550db
	ld	c, d	; F550D0  ld C,D
	srl	c, 1	; F550D2  srl 0x01,C
	ld	d, c	; F550D5  ld D,C
	inc	1, l	; F550D7  inc 1,L
	jr	EditValue_StepBitField_Join	; F550D9  jr T,0xf550cc
EditValue_StepBitField_Skip:
	ld	h, d	; F550DB  ld H,D
	ld	c, (PanelEvent_Flags:16)	; F550DD  ld C,(0x28b0)
	and	c, 4	; F550E1  and C,0x04
	jr	z, EditValue_StepBitField_Skip2	; F550E4  jr Z,0xf550eb
	ld	l, (xix+6)	; F550E6  ld L,(XIX+0x06)
	jr	EditValue_StepBitField_Join2	; F550E9  jr T,0xf550f9
EditValue_StepBitField_Skip2:
	ld	l, 1:opc	; F550EB  ld L,0x01
	ld	c, (UI_RequestBits:16)	; F550ED  ld C,(0x2075)
	and	c, 4	; F550F1  and C,0x04
	jr	z, EditValue_StepBitField_Join2	; F550F4  jr Z,0xf550f9
	ld	l, (xix+5)	; F550F6  ld L,(XIX+0x05)
EditValue_StepBitField_Join2:
	ld	c, (PanelEvent_Flags:16)	; F550F9  ld C,(0x28b0)
	and	c, 1	; F550FD  and C,0x01
	jr	z, EditValue_StepBitField_Skip4	; F55100  jr Z,0xf5511f
	ld	e, (xix+4)	; F55102  ld E,(XIX+0x04)
	ld	c, e	; F55105  ld C,E
	add	c, l	; F55107  add C,L
	ld	(xiz-2), c	; F55109  ld (XIZ+0xfe),C
	cp	h, c	; F5510C  cp H,C
	jr	c, EditValue_StepBitField_Skip3	; F5510E  jr C,0xf5511a
	cp	c, e	; F55110  cp C,E
	jr	ule, EditValue_StepBitField_Skip3	; F55112  jr ULE,0xf5511a
	ld	a, l	; F55114  ld A,L
	sub	h, a	; F55116  sub H,A
	jr	EditValue_StepBitField_Join3	; F55118  jr T,0xf5513d
EditValue_StepBitField_Skip3:
	ld	h, (xix+4)	; F5511A  ld H,(XIX+0x04)
	jr	EditValue_StepBitField_Join3	; F5511D  jr T,0xf5513d
EditValue_StepBitField_Skip4:
	ld	c, (xix+3)	; F5511F  ld C,(XIX+0x03)
	ld	(xiz-1), c	; F55122  ld (XIZ+0xff),C
	ld	e, c	; F55125  ld E,C
	sub	c, l	; F55127  sub C,L
	ld	e, c	; F55129  ld E,C
	cp	h, c	; F5512B  cp H,C
	jr	ugt, EditValue_StepBitField_Skip5	; F5512D  jr UGT,0xf5513a
	cp	c, (xiz-1)	; F5512F  cp C,(XIZ+0xff)
	jr	nc, EditValue_StepBitField_Skip5	; F55132  jr NC,0xf5513a
	ld	c, l	; F55134  ld C,L
	add	h, c	; F55136  add H,C
	jr	EditValue_StepBitField_Join3	; F55138  jr T,0xf5513d
EditValue_StepBitField_Skip5:
	ld	h, (xix+3)	; F5513A  ld H,(XIX+0x03)
EditValue_StepBitField_Join3:
	cp	h, d	; F5513D  cp H,D
	jr	z, EditValue_StepBitField_Skip7	; F5513F  jr Z,0xf55173
	ld	l, 0:opc	; F55141  ld L,0x00
	ld	d, (xix+2)	; F55143  ld D,(XIX+0x02)
EditValue_StepBitField_Join4:
	cp	l, d	; F55146  cp L,D
	jr	nc, EditValue_StepBitField_Skip6	; F55148  jr NC,0xf55154
	ld	c, h	; F5514A  ld C,H
	add	c, h	; F5514C  add C,H
	ld	h, c	; F5514E  ld H,C
	inc	1, l	; F55150  inc 1,L
	jr	EditValue_StepBitField_Join4	; F55152  jr T,0xf55146
EditValue_StepBitField_Skip6:
	ld	l, (xix+1)	; F55154  ld L,(XIX+0x01)
	ld	d, l	; F55157  ld D,L
	and	d, h	; F55159  and D,H
	ld	c, l	; F5515B  ld C,L
	cpl	c	; F5515D  cpl C
	ld	h, c	; F5515F  ld H,C
	ld	xbc, (xiz+8)	; F55161  ld XBC,(XIZ+0x08)
	and	(xbc), h	; F55164  and (XBC),H
	ld	xbc, (xiz+8)	; F55166  ld XBC,(XIZ+0x08)
	ld	a, (xbc)	; F55169  ld A,(XBC)
	or	a, d	; F5516B  or A,D
	ld	(xbc), a	; F5516D  ld (XBC),A
	ld	a, 1:opc	; F5516F  ld A,0x01
	jr	EditValue_StepBitField_Join5	; F55171  jr T,0xf55175
EditValue_StepBitField_Skip7:
	sub	a, a	; F55173  sub A,A
EditValue_StepBitField_Join5:
	pop	xix	; F55175  pop XIX
	popw	de	; F55176  pop DE
	popw	hl	; F55177  pop HL
	unlk XIZ	; F55178  unlk XIZ
	ret	; F5517A  ret

; ---------------------------------------------------------------------
; EditValue_SetBit -- set, clear or toggle a masked bit group in one byte
; Called from: not yet traced to a specific caller
; Inputs:  (XIZ+8) = 32-bit pointer to the target byte,
;          (XIZ+0x0C) = 32-bit pointer to a descriptor whose +1 is the mask and
;          whose +2 is XORed into (0x28B0) first
; Outputs: A = 1 if the byte changed, 0 if it did not; the byte is updated
; Evidence: after the XOR into (0x28B0), bit 0 of (0x28B0) selects between two
;           edits of L = (XIX): with the bit set, `and A,L` then `cpl A / and
;           L,A` clears the mask; with it clear, `or L,A` sets it.  The result is
;           compared with the original `cp H,L` and only written back on a
;           difference, which is also what the 1/0 return reports.
; Unknown:  what the byte is.
; ---------------------------------------------------------------------
; EditValue_SetBit: Pointer form of IndexedParam_SetBit: XORs descriptor +2 into PanelEvent_Flags, then bit 0 set
;   clears, clear sets, the descriptor's +1 mask in the byte at (XIZ+8); writes back and returns A = 1 only if the
;   byte changed. MEMORY PROTECT / CONTROLLER ASSIGN soft keys use it (3-byte descriptors) beside
;   T_EditValue_StepBitField and repaint on A = 1. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_f.json)
EditValue_SetBit:
	link XIZ,0x0000	; F5517B  link XIZ,0x0000
	pushw	hl	; F5517F  push HL
	pushw	de	; F55180  push DE
	push	xix	; F55181  push XIX
	ld	xix, (xiz+8)	; F55182  ld XIX,(XIZ+0x08)
	ld	xbc, (xiz+12)	; F55185  ld XBC,(XIZ+0x0c)
	ld	a, (xbc+2)	; F55188  ld A,(XBC+0x02)
	xor	(PanelEvent_Flags:16), a	; F5518B  xor (0x28b0),A
	ld	l, (xix)	; F5518F  ld L,(XIX)
	ld	a, (PanelEvent_Flags:16)	; F55191  ld A,(0x28b0)
	and	a, 1	; F55195  and A,0x01
	jr	z, EditValue_SetBit_Skip	; F55198  jr Z,0xf551ab
	ld	h, (xbc+1)	; F5519A  ld H,(XBC+0x01)
	ld	a, h	; F5519D  ld A,H
	and	a, l	; F5519F  and A,L
	jr	z, EditValue_SetBit_Join	; F551A1  jr Z,0xf551bb
	ld	a, h	; F551A3  ld A,H
	cpl	a	; F551A5  cpl A
	and	l, a	; F551A7  and L,A
	jr	EditValue_SetBit_Join	; F551A9  jr T,0xf551bb
EditValue_SetBit_Skip:
	ld	xbc, (xiz+12)	; F551AB  ld XBC,(XIZ+0x0c)
	ld	h, (xbc+1)	; F551AE  ld H,(XBC+0x01)
	ld	a, h	; F551B1  ld A,H
	and	a, l	; F551B3  and A,L
	jr	nz, EditValue_SetBit_Join	; F551B5  jr NZ,0xf551bb
	ld	a, h	; F551B7  ld A,H
	or	l, a	; F551B9  or L,A
EditValue_SetBit_Join:
	ld	h, (xix)	; F551BB  ld H,(XIX)
	cp	h, l	; F551BD  cp H,L
	jr	z, EditValue_SetBit_Skip2	; F551BF  jr Z,0xf551df
	ld	xbc, (xiz+12)	; F551C1  ld XBC,(XIZ+0x0c)
	ld	d, (xbc+1)	; F551C4  ld D,(XBC+0x01)
	ld	e, d	; F551C7  ld E,D
	and	e, l	; F551C9  and E,L
	ld	c, d	; F551CB  ld C,D
	cpl	c	; F551CD  cpl C
	ld	l, c	; F551CF  ld L,C
	and	l, h	; F551D1  and L,H
	ld	(xix), l	; F551D3  ld (XIX),L
	ld	c, e	; F551D5  ld C,E
	or	c, l	; F551D7  or C,L
	ld	(xix), c	; F551D9  ld (XIX),C
	ld	a, 1:opc	; F551DB  ld A,0x01
	jr	EditValue_SetBit_Join2	; F551DD  jr T,0xf551e1
EditValue_SetBit_Skip2:
	sub	a, a	; F551DF  sub A,A
EditValue_SetBit_Join2:
	pop	xix	; F551E1  pop XIX
	popw	de	; F551E2  pop DE
	popw	hl	; F551E3  pop HL
	unlk XIZ	; F551E4  unlk XIZ
	ret	; F551E6  ret

; ---------------------------------------------------------------------
; sub_F551E7 -- clamp a 16-bit value to a descriptor's two bounds
; Called from: not yet traced to a specific caller
; Inputs:  (XIZ+8) = 32-bit pointer to the 16-bit value,
;          (XIZ+0x0C) = 32-bit pointer to a descriptor; +3 and +4 are the bounds,
;          +7 is XORed into (0x28B0) first
; Outputs: A = 1 if the value was already inside the bounds, 0 if it was clamped
;          and written back
; Evidence: `ld IX,(XWA)` reads the value, `cp IX,WA / jr NC` against descriptor
;           +4 and `cp DE,WA / jr ULE` against descriptor +3 each replace DE with
;           the bound; `cp DE,IX` then decides between writing DE back and
;           returning 1.
; Unknown:  what the value is.
; ---------------------------------------------------------------------
sub_F551E7:
	link XIZ,0x0000	; F551E7  link XIZ,0x0000
	pushw	hl	; F551EB  push HL
	pushw	de	; F551EC  push DE
	pushw	ix	; F551ED  push IX
	ld	xbc, (xiz+12)	; F551EE  ld XBC,(XIZ+0x0c)
	ld	a, (xbc+7)	; F551F1  ld A,(XBC+0x07)
	xor	(PanelEvent_Flags:16), a	; F551F4  xor (0x28b0),A
	ld	xwa, (xiz+8)	; F551F8  ld XWA,(XIZ+0x08)
	ld	ix, (xwa)	; F551FB  ld IX,(XWA)
	ld	de, ix	; F551FD  ld DE,IX
	ld	a, (xbc+4)	; F551FF  ld A,(XBC+0x04)
	extz	wa	; F55202  extz WA
	ld	hl, wa	; F55204  ld HL,WA
	cp	ix, wa	; F55206  cp IX,WA
	jr	nc, sub_F551E7_Skip	; F55208  jr NC,0xf5520c
	ld	de, wa	; F5520A  ld DE,WA
sub_F551E7_Skip:
	ld	xbc, (xiz+12)	; F5520C  ld XBC,(XIZ+0x0c)
	ld	a, (xbc+3)	; F5520F  ld A,(XBC+0x03)
	extz	wa	; F55212  extz WA
	ld	hl, wa	; F55214  ld HL,WA
	cp	de, wa	; F55216  cp DE,WA
	jr	ule, sub_F551E7_Skip2	; F55218  jr ULE,0xf5521c
	ld	de, wa	; F5521A  ld DE,WA
sub_F551E7_Skip2:
	cp	de, ix	; F5521C  cp DE,IX
	jr	z, sub_F551E7_Skip3	; F5521E  jr Z,0xf55229
	ld	xbc, (xiz+8)	; F55220  ld XBC,(XIZ+0x08)
	ld	(xbc), de	; F55223  ld (XBC),DE
	sub	a, a	; F55225  sub A,A
	jr	sub_F551E7_Join	; F55227  jr T,0xf5522b
sub_F551E7_Skip3:
	ld	a, 1:opc	; F55229  ld A,0x01
sub_F551E7_Join:
	popw	ix	; F5522B  pop IX
	popw	de	; F5522C  pop DE
	popw	hl	; F5522D  pop HL
	unlk XIZ	; F5522E  unlk XIZ
	ret	; F55230  ret

; ---------------------------------------------------------------------
; Queue2C00_Append4 -- append a 4-byte record to the queue at 0x2C00
; Called from: not yet traced to a specific caller
; Inputs:  four bytes, one per 16-bit stack slot: (XIZ+8), (XIZ+0x0A),
;          (XIZ+0x0C), (XIZ+0x0E)
; Outputs: the record is stored at 0x2C00 + (0x60F000), 0xFF is written one byte
;          past it, and (0x60F000) is advanced by 4.  Nothing happens once
;          (0x60F000) reaches 0x01FC.
; Evidence: `lda XIX,0x60F000 / ld BC,(XIX) / cp BC,0x01FC / jr NC,<exit>`, then
;           `ld BC,0x2C00 / add BC,HL` forms the write address, four
;           `ld (XBC+n),A` stores, `ld (XBC+4),0xFF`, `incw 4,(XIX)`.
;           0x01FC / 4 = 127 records.
; Unknown:  what reads the queue, and what the four bytes mean.
; ---------------------------------------------------------------------
Queue2C00_Append4:
	link XIZ,0xfffc	; F55231  link XIZ,0xfffc
	pushw	hl	; F55235  push HL
	push	xix	; F55236  push XIX
	lda	xix, (6352896:24)	; F55237  lda XIX,0x60f000
	ld	bc, (xix)	; F5523C  ld BC,(XIX)
	cp	bc, 508	; F5523E  cp BC,0x01fc
	jr	nc, Queue2C00_Append4_Skip	; F55242  jr NC,0xf55279
	ld	hl, (xix)	; F55244  ld HL,(XIX)
	ldw	bc, 11264	; F55246  ld BC,0x2c00
	add	bc, hl	; F55249  add BC,HL
	extz	xbc	; F5524B  extz XBC
	ld	(xiz-4), xbc	; F5524D  ld (XIZ+0xfc),XBC
	ld	a, (xiz+8)	; F55250  ld A,(XIZ+0x08)
	ld	(xbc), a	; F55253  ld (XBC),A
	ld	xbc, (xiz-4)	; F55255  ld XBC,(XIZ+0xfc)
	ld	a, (xiz+10)	; F55258  ld A,(XIZ+0x0a)
	ld	(xbc+1), a	; F5525B  ld (XBC+0x01),A
	ld	xbc, (xiz-4)	; F5525E  ld XBC,(XIZ+0xfc)
	ld	a, (xiz+12)	; F55261  ld A,(XIZ+0x0c)
	ld	(xbc+2), a	; F55264  ld (XBC+0x02),A
	ld	xbc, (xiz-4)	; F55267  ld XBC,(XIZ+0xfc)
	ld	a, (xiz+14)	; F5526A  ld A,(XIZ+0x0e)
	ld	(xbc+3), a	; F5526D  ld (XBC+0x03),A
	ld	xbc, (xiz-4)	; F55270  ld XBC,(XIZ+0xfc)
	ld	(xbc+4), 255	; F55273  ld (XBC+0x04),0xff
	incw	4, (xix)	; F55277  incw 4,(XIX)
Queue2C00_Append4_Skip:
	pop	xix	; F55279  pop XIX
	popw	hl	; F5527A  pop HL
	unlk XIZ	; F5527B  unlk XIZ
	ret	; F5527D  ret

; ---------------------------------------------------------------------
; Queue2E00_Append4 -- the same, for the queue at 0x2E00, gated on the first
; Called from: not yet traced to a specific caller
; Inputs:  as Queue2C00_Append4
; Outputs: record at 0x2E00 + (0x60F004), 0xFF one past, (0x60F004) += 4
; Evidence: byte for byte the same routine with 0x2C00 -> 0x2E00 and 0x60F000 ->
;           0x60F004, EXCEPT that the capacity test is still on (0x60F000):
;           `cp (0x60F000),0x00FC / jr NC,<exit>`.  So this queue is only written
;           while the FIRST queue is less than 0xFC (63 records) deep.
; Unknown:  why the two queues are coupled this way.
; ---------------------------------------------------------------------
Queue2E00_Append4:
	link XIZ,0xfffc	; F5527E  link XIZ,0xfffc
	pushw	hl	; F55282  push HL
	push	xix	; F55283  push XIX
	cpw	(0x60f000:24), 0x00fc	; F55284  cp (0x60f000),0x00fc
	jr	nc, Queue2C00_Append4_Skip2	; F5528B  jr NC,0xf552c7
	lda	xix, (6352900:24)	; F5528D  lda XIX,0x60f004
	ld	hl, (xix)	; F55292  ld HL,(XIX)
	ldw	bc, 11776	; F55294  ld BC,0x2e00
	add	bc, hl	; F55297  add BC,HL
	extz	xbc	; F55299  extz XBC
	ld	(xiz-4), xbc	; F5529B  ld (XIZ+0xfc),XBC
	ld	a, (xiz+8)	; F5529E  ld A,(XIZ+0x08)
	ld	(xbc), a	; F552A1  ld (XBC),A
	ld	xbc, (xiz-4)	; F552A3  ld XBC,(XIZ+0xfc)
	ld	a, (xiz+10)	; F552A6  ld A,(XIZ+0x0a)
	ld	(xbc+1), a	; F552A9  ld (XBC+0x01),A
	ld	xbc, (xiz-4)	; F552AC  ld XBC,(XIZ+0xfc)
	ld	a, (xiz+12)	; F552AF  ld A,(XIZ+0x0c)
	ld	(xbc+2), a	; F552B2  ld (XBC+0x02),A
	ld	xbc, (xiz-4)	; F552B5  ld XBC,(XIZ+0xfc)
	ld	a, (xiz+14)	; F552B8  ld A,(XIZ+0x0e)
	ld	(xbc+3), a	; F552BB  ld (XBC+0x03),A
	ld	xbc, (xiz-4)	; F552BE  ld XBC,(XIZ+0xfc)
	ld	(xbc+4), 255	; F552C1  ld (XBC+0x04),0xff
	incw	4, (xix)	; F552C5  incw 4,(XIX)
Queue2C00_Append4_Skip2:
	pop	xix	; F552C7  pop XIX
	popw	hl	; F552C8  pop HL
	unlk XIZ	; F552C9  unlk XIZ
	ret	; F552CB  ret

; ---------------------------------------------------------------------
; List2030_Append4 -- append a 4-byte record to the 0xFF-terminated list at
;                     0x2030, which ends at 0x206C
; Called from: not yet traced to a specific caller
; Inputs:  four bytes in (XIZ+8), (XIZ+0x0A), (XIZ+0x0C), (XIZ+0x0E)
; Outputs: the record replaces the 0xFF terminator, and a new 0xFF follows it
; Evidence: `lda XIX,0x2030 / lda XBC,0x206C`, then a scan `ld C,(XIX) /
;           cp C,0xFF / jr Z / inc 4,XIX` walks the list in 4-byte steps to its
;           terminator; `cp XWA,XBC / jr NC,<exit>` refuses to write at or past
;           0x206C.  (0x206C - 0x2030) / 4 = 15 slots.
; Unknown:  what the list is for.
; ---------------------------------------------------------------------
List2030_Append4:
	link XIZ,0xfff8	; F552CC  link XIZ,0xfff8
	push	xix	; F552D0  push XIX
	lda	xix, (8240:16)	; F552D1  lda XIX,0x2030
	lda	xbc, (8300:16)	; F552D5  lda XBC,0x206c
	ld	(xiz-4), xbc	; F552D9  ld (XIZ+0xfc),XBC
List2030_Append4_Join:
	ld	c, (xix)	; F552DC  ld C,(XIX)
	cp	c, 255	; F552DE  cp C,0xff
	jr	z, List2030_Append4_Skip	; F552E1  jr Z,0xf552e7
	inc	4, xix	; F552E3  inc 4,XIX
	jr	List2030_Append4_Join	; F552E5  jr T,0xf552dc
List2030_Append4_Skip:
	ld	xbc, (xiz-4)	; F552E7  ld XBC,(XIZ+0xfc)
	ld	(xiz-8), xbc	; F552EA  ld (XIZ+0xf8),XBC
	ld	xwa, xix	; F552ED  ld XWA,XIX
	cp	xwa, xbc	; F552EF  cp XWA,XBC
	jr	nc, List2030_Append4_Skip2	; F552F1  jr NC,0xf5531d
	ld	c, (xiz+8)	; F552F3  ld C,(XIZ+0x08)
	ld	(xix), c	; F552F6  ld (XIX),C
	ld	xbc, xix	; F552F8  ld XBC,XIX
	inc	1, xbc	; F552FA  inc 1,XBC
	ld	(xiz-8), xbc	; F552FC  ld (XIZ+0xf8),XBC
	ld	a, (xiz+10)	; F552FF  ld A,(XIZ+0x0a)
	ld	(xbc), a	; F55302  ld (XBC),A
	ld	xbc, (xiz-8)	; F55304  ld XBC,(XIZ+0xf8)
	ld	a, (xiz+12)	; F55307  ld A,(XIZ+0x0c)
	ld	(xbc+1), a	; F5530A  ld (XBC+0x01),A
	ld	xbc, (xiz-8)	; F5530D  ld XBC,(XIZ+0xf8)
	ld	a, (xiz+14)	; F55310  ld A,(XIZ+0x0e)
	ld	(xbc+2), a	; F55313  ld (XBC+0x02),A
	ld	xbc, (xiz-8)	; F55316  ld XBC,(XIZ+0xf8)
	ld	(xbc+3), 255	; F55319  ld (XBC+0x03),0xff
List2030_Append4_Skip2:
	pop	xix	; F5531D  pop XIX
	unlk XIZ	; F5531E  unlk XIZ
	ret	; F55320  ret

; ------------------------------------------------------------------------------
; 0xF55321-0xF5533B -- IndexedTable_GetPtr
;
; ★ MOVED to maincpu/shared/indexed_table.s, ONE SOURCE included at BOTH of its
; sites: here and prom_a 0xFB77D8.  The two copies are byte-identical,
; every reference binds to the nearer of them, and the header that used to sit
; here is in that file, verbatim, under a banner saying it came from this one.
; Why the duplication exists at all -- and why the obvious explanation is wrong
; -- is measured by `python3 notes/maincpu_join_probe.py --callers --nearest`.
; ------------------------------------------------------------------------------
	.include "maincpu/shared/indexed_table.s"

; ---------------------------------------------------------------------
; IndexedTable_GetByte -- byte m of pointer n of the same table
; Called from: thunk T_IndexedTable_GetByte (0xF42C90), 119 opcode-anchored references -- the
;              third-busiest prom_b-resident slot in the thunk table
; Inputs:  (XIZ+8) = table index, (XIZ+0x0A) = byte offset
; Outputs: A = the byte; XIX = the entry pointer; XIY = the byte's address
; Evidence: it pushes a 32-bit argument built as `push 0x00 / push (XIZ+8)`,
;           calls IndexedTable_GetPtr, then `ld BC,(XIZ+0x0A) / extz / add
;           XIY,XBC / ld A,(XIY)`.
; Unknown:  as above.
; ---------------------------------------------------------------------
IndexedTable_GetByte:
	link XIZ,0x0000	; F5533C  link XIZ,0x0000
	push	xix	; F55340  push XIX
	push	0	; F55341  push 0x00
	push	(xiz+8)	; F55343  push (XIZ+0x08)
	calr	IndexedTable_GetPtr	; F55346  calr 0xf55321
	ld	xix, xiy	; F55349  ld XIX,XIY
	ld	bc, (xiz+10)	; F5534B  ld BC,(XIZ+0x0a)
	extz	bc	; F5534E  extz BC
	extz	xbc	; F55350  extz XBC
	add	xiy, xbc	; F55352  add XIY,XBC
	ld	a, (xiy)	; F55354  ld A,(XIY)
	popw	bc	; F55356  pop BC
	pop	xix	; F55357  pop XIX
	unlk XIZ	; F55358  unlk XIZ
	ret	; F5535A  ret


; ---------------------------------------------------------------------
; IndexedParam_AdjustField -- step one packed parameter field up or down,
;                             clamp it, write it back and journal the change
; Called from: thunk T_IndexedParam_AdjustField (0xF42C94), 23 opcode-anchored references
;          (an upper bound that ranks slots; not a call count)
; Inputs:  (XIZ+0x08) = a 16-bit INDEX -- not a pointer;
;          (XIZ+0x0A) = 32-bit pointer to the 8-byte descriptor already
;          documented on EditValue_StepBitField above:
;              +0 byte offset into the object   +1 field mask
;              +2 right-shift count             +3 upper bound
;              +4 lower bound                   +5 step when (0x2075) bit 2
;              +6 step when (0x28B0) bit 2      +7 XORed into (0x28B0) on entry
;          plus (0x28B0) bits 0/2/3/4 and (0x2075) bit 2.
; Outputs: the field in the target byte is replaced; a 4-byte record is appended
;          to one of the two journals; bit 3 of (0x2075) is set; (0x28B0) is
;          XORed with descriptor +7.  Nothing is written if the value did not
;          change (`cp H,D / jr Z` at 0xF55413 jumps straight to the epilogue).
; Evidence: the object is resolved, not passed: `push 0x00 / push (XIZ+0x08) /
;          calr 0xF55321` is IndexedTable_GetPtr, and descriptor +0 is then
;          added to the pointer it returns (`ld C,(XIX) / extz / add XIY,XBC`).
;          The adjust core is BYTE-IDENTICAL to EditValue_StepBitField's: 0xF553B1..0xF55414
;          equals 0xF550DB..0xF5513E in 99 of 100 bytes, the single difference
;          being a frame displacement at 0xF553E0 (0xF9 = -7) versus 0xF5510A
;          (0xFE = -2), which is just the two routines' different frame sizes.
;          (Measured by notes/prom_b_param_edit_pair.py.)
;          The journals are the already-converted appenders: 0xF552CC =
;          List2030_Append4 when bit 3 of (0x28B0) is set, otherwise the
;          in-place write-back followed by 0xF55231 = Queue2C00_Append4.
;          Both are handed the same four-slot frame those routines read --
;          index, descriptor +0, the NEW field value, descriptor +1 -- eight
;          bytes, released by the `inc 0,XSP`.  An immediate of 0 there means
;          EIGHT, not zero: MAME's op_INCLIR is
;          `*m_p2_reg32 += m_imm1.b.l ? m_imm1.b.l : 8`
;          (mame/src/devices/cpu/tlcs900/900tbl.hxx).  Counting the pushes
;          confirms it -- 2+1+1+2+1+1 = 8 bytes.
; Notes:   bit 0 of (0x28B0) picks the direction: clear takes the +3 bound and
;          `add H,C`, set takes the +4 bound and `sub H,A`.  Each branch has two
;          guards, one against crossing the bound and one against the bound
;          arithmetic itself wrapping, and both land on `ld H,(XIX+3 or +4)`.
;          Bit 4 of (0x28B0) adds 0x20 to the index before the lookup.
; Unknown:  what the objects in the 0x60F018 table are, so what parameter this
;          edits; what (0x28B0)'s bits are called; why bit 3 substitutes the
;          0x2030 list for the write-back instead of doing both.
; ---------------------------------------------------------------------
IndexedParam_AdjustField:
	link XIZ,0xfff5	; F5535B  link XIZ,0xfff5
	pushw	hl	; F5535F  push HL
	pushw	de	; F55360  push DE
	push	xix	; F55361  push XIX
	ld	xix, (xiz+10)	; F55362  ld XIX,(XIZ+0x0a)
	set	3, (UI_RequestBits:16)	; F55365  set 3,(0x2075)
	ld	c, (xix+7)	; F55369  ld C,(XIX+0x07)
	xor	(PanelEvent_Flags:16), c	; F5536C  xor (0x28b0),C
	ld	c, (PanelEvent_Flags:16)	; F55370  ld C,(0x28b0)
	and	c, 16	; F55374  and C,0x10
	jr	z, IndexedTable_GetByte_Skip	; F55377  jr Z,0xf5537d
	add	(xiz+8), 0x20	; F55379  add (XIZ+0x08),0x20
IndexedTable_GetByte_Skip:
	push	0	; F5537D  push 0x00
	push	(xiz+8)	; F5537F  push (XIZ+0x08)
	calr	IndexedTable_GetPtr	; F55382  calr 0xf55321
	ld	(xiz-11), xiy	; F55385  ld (XIZ+0xf5),XIY
	ld	c, (xix)	; F55388  ld C,(XIX)
	extz	bc	; F5538A  extz BC
	extz	xbc	; F5538C  extz XBC
	add	xiy, xbc	; F5538E  add XIY,XBC
	ld	(xiz-6), xiy	; F55390  ld (XIZ+0xfa),XIY
	ld	e, (xiy)	; F55393  ld E,(XIY)
	ld	c, (xix+1)	; F55395  ld C,(XIX+0x01)
	ld	d, c	; F55398  ld D,C
	and	d, e	; F5539A  and D,E
	ld	l, 0:opc	; F5539C  ld L,0x00
	ld	h, (xix+2)	; F5539E  ld H,(XIX+0x02)
	popw	bc	; F553A1  pop BC
IndexedTable_GetByte_Join:
	cp	l, h	; F553A2  cp L,H
	jr	nc, IndexedTable_GetByte_Skip2	; F553A4  jr NC,0xf553b1
	ld	c, d	; F553A6  ld C,D
	srl	c, 1	; F553A8  srl 0x01,C
	ld	d, c	; F553AB  ld D,C
	inc	1, l	; F553AD  inc 1,L
	jr	IndexedTable_GetByte_Join	; F553AF  jr T,0xf553a2
IndexedTable_GetByte_Skip2:
	ld	h, d	; F553B1  ld H,D
	ld	c, (PanelEvent_Flags:16)	; F553B3  ld C,(0x28b0)
	and	c, 4	; F553B7  and C,0x04
	jr	z, IndexedTable_GetByte_Skip3	; F553BA  jr Z,0xf553c1
	ld	l, (xix+6)	; F553BC  ld L,(XIX+0x06)
	jr	IndexedTable_GetByte_Join2	; F553BF  jr T,0xf553cf
IndexedTable_GetByte_Skip3:
	ld	l, 1:opc	; F553C1  ld L,0x01
	ld	c, (UI_RequestBits:16)	; F553C3  ld C,(0x2075)
	and	c, 4	; F553C7  and C,0x04
	jr	z, IndexedTable_GetByte_Join2	; F553CA  jr Z,0xf553cf
	ld	l, (xix+5)	; F553CC  ld L,(XIX+0x05)
IndexedTable_GetByte_Join2:
	ld	c, (PanelEvent_Flags:16)	; F553CF  ld C,(0x28b0)
	and	c, 1	; F553D3  and C,0x01
	jr	z, IndexedTable_GetByte_Skip5	; F553D6  jr Z,0xf553f5
	ld	e, (xix+4)	; F553D8  ld E,(XIX+0x04)
	ld	c, e	; F553DB  ld C,E
	add	c, l	; F553DD  add C,L
	ld	(xiz-7), c	; F553DF  ld (XIZ+0xf9),C
	cp	h, c	; F553E2  cp H,C
	jr	c, IndexedTable_GetByte_Skip4	; F553E4  jr C,0xf553f0
	cp	c, e	; F553E6  cp C,E
	jr	ule, IndexedTable_GetByte_Skip4	; F553E8  jr ULE,0xf553f0
	ld	a, l	; F553EA  ld A,L
	sub	h, a	; F553EC  sub H,A
	jr	IndexedTable_GetByte_Join3	; F553EE  jr T,0xf55413
IndexedTable_GetByte_Skip4:
	ld	h, (xix+4)	; F553F0  ld H,(XIX+0x04)
	jr	IndexedTable_GetByte_Join3	; F553F3  jr T,0xf55413
IndexedTable_GetByte_Skip5:
	ld	c, (xix+3)	; F553F5  ld C,(XIX+0x03)
	ld	(xiz-1), c	; F553F8  ld (XIZ+0xff),C
	ld	e, c	; F553FB  ld E,C
	sub	c, l	; F553FD  sub C,L
	ld	e, c	; F553FF  ld E,C
	cp	h, c	; F55401  cp H,C
	jr	ugt, IndexedTable_GetByte_Skip6	; F55403  jr UGT,0xf55410
	cp	c, (xiz-1)	; F55405  cp C,(XIZ+0xff)
	jr	nc, IndexedTable_GetByte_Skip6	; F55408  jr NC,0xf55410
	ld	c, l	; F5540A  ld C,L
	add	h, c	; F5540C  add H,C
	jr	IndexedTable_GetByte_Join3	; F5540E  jr T,0xf55413
IndexedTable_GetByte_Skip6:
	ld	h, (xix+3)	; F55410  ld H,(XIX+0x03)
IndexedTable_GetByte_Join3:
	cp	h, d	; F55413  cp H,D
	jr	z, IndexedTable_GetByte_Skip9	; F55415  jr Z,0xf55475
	ld	l, 0:opc	; F55417  ld L,0x00
	ld	d, (xix+2)	; F55419  ld D,(XIX+0x02)
IndexedTable_GetByte_Join4:
	cp	l, d	; F5541C  cp L,D
	jr	nc, IndexedTable_GetByte_Skip7	; F5541E  jr NC,0xf5542a
	ld	c, h	; F55420  ld C,H
	add	c, h	; F55422  add C,H
	ld	h, c	; F55424  ld H,C
	inc	1, l	; F55426  inc 1,L
	jr	IndexedTable_GetByte_Join4	; F55428  jr T,0xf5541c
IndexedTable_GetByte_Skip7:
	ld	l, (xix+1)	; F5542A  ld L,(XIX+0x01)
	ld	c, l	; F5542D  ld C,L
	and	h, c	; F5542F  and H,C
	ld	a, (PanelEvent_Flags:16)	; F55431  ld A,(0x28b0)
	and	a, 8	; F55435  and A,0x08
	jr	z, IndexedTable_GetByte_Skip8	; F55438  jr Z,0xf5544c
	pushw	bc	; F5543A  push BC
	push	0	; F5543B  push 0x00
	push	h	; F5543D  push H
	ld	c, (xix)	; F5543F  ld C,(XIX)
	pushw	bc	; F55441  push BC
	push	0	; F55442  push 0x00
	push	(xiz+8)	; F55444  push (XIZ+0x08)
	calr	List2030_Append4	; F55447  calr 0xf552cc
	jr	IndexedTable_GetByte_Join5	; F5544A  jr T,0xf55473
IndexedTable_GetByte_Skip8:
	ld	c, l	; F5544C  ld C,L
	cpl	c	; F5544E  cpl C
	ld	l, c	; F55450  ld L,C
	ld	xbc, (xiz-6)	; F55452  ld XBC,(XIZ+0xfa)
	and	(xbc), l	; F55455  and (XBC),L
	ld	xbc, (xiz-6)	; F55457  ld XBC,(XIZ+0xfa)
	ld	a, (xbc)	; F5545A  ld A,(XBC)
	or	a, h	; F5545C  or A,H
	ld	(xbc), a	; F5545E  ld (XBC),A
	ld	c, (xix+1)	; F55460  ld C,(XIX+0x01)
	pushw	bc	; F55463  push BC
	push	0	; F55464  push 0x00
	push	h	; F55466  push H
	ld	c, (xix)	; F55468  ld C,(XIX)
	pushw	bc	; F5546A  push BC
	push	0	; F5546B  push 0x00
	push	(xiz+8)	; F5546D  push (XIZ+0x08)
	calr	Queue2C00_Append4	; F55470  calr 0xf55231
IndexedTable_GetByte_Join5:
	inc	8, xsp	; F55473  inc 0,XSP
IndexedTable_GetByte_Skip9:
	pop	xix	; F55475  pop XIX
	popw	de	; F55476  pop DE
	popw	hl	; F55477  pop HL
	unlk XIZ	; F55478  unlk XIZ
	ret	; F5547A  ret

; ---------------------------------------------------------------------
; IndexedParam_SetBit -- set or clear one flag field of an indexed object and
;                        journal the change
; Called from: thunk T_IndexedParam_SetBit (0xF42C98), 35 opcode-anchored references -- the
;          busiest of this group
; Inputs:  (XIZ+0x08) = the 16-bit index; (XIZ+0x0A) = the 8-byte descriptor.
;          Only +0 (byte offset), +1 (mask) and +2 (XORed into (0x28B0)) are
;          used -- there is no shift, no bound and no step, because there is no
;          arithmetic.
; Outputs: the masked bits of the target byte are forced on or off; a journal
;          record is appended; nothing happens if the byte did not change
;          (`ld L,(XBC) / cp L,D / jr Z` at 0xF554DA).
; Evidence: the same `calr 0xF55321` + descriptor-+0 resolution as
;          IndexedParam_AdjustField, then two mirrored arms selected by bit 0 of
;          (0x28B0): the set arm tests `and C,D / jr NZ` and `or D,C`, the clear
;          arm tests `and C,D / jr Z` and `cpl C / and D,C`.  Each arm first
;          checks whether the bits are already in the wanted state, which is why
;          this is "force to a state", not "toggle".
;          The POLARITY matches IndexedParam_AdjustField's: bit 0 of (0x28B0)
;          CLEAR reaches the arm at 0xF554CA that SETS the bits, and bit 0 SET
;          reaches 0xF554B9, which clears them -- the same sense in which bit 0
;          clear means "up" and set means "down" for the numeric editor.
;          ⚠ Note the descriptor byte XORed into (0x28B0) here is +2
;          (`ld C,(XIX+0x02)` at 0xF55488), NOT the +7 that EditValue_StepBitField and
;          IndexedParam_AdjustField use.  Read from the bytes, not assumed.
; Notes:   the bit-3 (0x28B0) path calls List2030_Append4 TWICE, once with the
;          value D and once with 0x0000, and releases 16 bytes with two
;          `inc 0,XSP`.  The other path writes the byte and appends one
;          Queue2C00_Append4 record.  Some argument slots carry register residue
;          in their high byte (e.g. (0x28B0)&8 rides along in W at 0xF554F0);
;          that is harmless because the appenders read only the low byte of each
;          16-bit slot, as their own headers record.
; Unknown:  the same three gaps as the routine above.
; ---------------------------------------------------------------------
IndexedParam_SetBit:
	link XIZ,0xfff8	; F5547B  link XIZ,0xfff8
	pushw	hl	; F5547F  push HL
	pushw	de	; F55480  push DE
	push	xix	; F55481  push XIX
	ld	xix, (xiz+10)	; F55482  ld XIX,(XIZ+0x0a)
	ld	e, (xiz+8)	; F55485  ld E,(XIZ+0x08)
	ld	c, (xix+2)	; F55488  ld C,(XIX+0x02)
	xor	(PanelEvent_Flags:16), c	; F5548B  xor (0x28b0),C
	ld	c, (PanelEvent_Flags:16)	; F5548F  ld C,(0x28b0)
	and	c, 16	; F55493  and C,0x10
	jr	z, IndexedTable_GetByte_Skip10	; F55496  jr Z,0xf5549b
	add	e, 32	; F55498  add E,0x20
IndexedTable_GetByte_Skip10:
	pushw	de	; F5549B  push DE
	calr	IndexedTable_GetPtr	; F5549C  calr 0xf55321
	ld	(xiz-8), xiy	; F5549F  ld (XIZ+0xf8),XIY
	ld	c, (xix)	; F554A2  ld C,(XIX)
	extz	bc	; F554A4  extz BC
	extz	xbc	; F554A6  extz XBC
	add	xiy, xbc	; F554A8  add XIY,XBC
	ld	(xiz-4), xiy	; F554AA  ld (XIZ+0xfc),XIY
	ld	d, (xiy)	; F554AD  ld D,(XIY)
	ld	c, (PanelEvent_Flags:16)	; F554AF  ld C,(0x28b0)
	and	c, 1	; F554B3  and C,0x01
	popw	wa	; F554B6  pop WA
	jr	z, IndexedTable_GetByte_Skip11	; F554B7  jr Z,0xf554ca
	ld	h, (xix+1)	; F554B9  ld H,(XIX+0x01)
	ld	c, h	; F554BC  ld C,H
	and	c, d	; F554BE  and C,D
	jr	z, IndexedTable_GetByte_Join6	; F554C0  jr Z,0xf554d7
	ld	c, h	; F554C2  ld C,H
	cpl	c	; F554C4  cpl C
	and	d, c	; F554C6  and D,C
	jr	IndexedTable_GetByte_Join6	; F554C8  jr T,0xf554d7
IndexedTable_GetByte_Skip11:
	ld	h, (xix+1)	; F554CA  ld H,(XIX+0x01)
	ld	c, h	; F554CD  ld C,H
	and	c, d	; F554CF  and C,D
	jr	nz, IndexedTable_GetByte_Join6	; F554D1  jr NZ,0xf554d7
	ld	c, h	; F554D3  ld C,H
	or	d, c	; F554D5  or D,C
IndexedTable_GetByte_Join6:
	ld	xbc, (xiz-4)	; F554D7  ld XBC,(XIZ+0xfc)
	ld	l, (xbc)	; F554DA  ld L,(XBC)
	cp	l, d	; F554DC  cp L,D
	jr	z, IndexedTable_GetByte_Join7	; F554DE  jr Z,0xf55539
	ld	h, (xix+1)	; F554E0  ld H,(XIX+0x01)
	ld	a, h	; F554E3  ld A,H
	and	d, a	; F554E5  and D,A
	ld	w, (PanelEvent_Flags:16)	; F554E7  ld W,(0x28b0)
	and	w, 8	; F554EB  and W,0x08
	jr	z, IndexedTable_GetByte_Skip12	; F554EE  jr Z,0xf55510
	pushw	wa	; F554F0  push WA
	push	0	; F554F1  push 0x00
	push	d	; F554F3  push D
	ld	a, (xix)	; F554F5  ld A,(XIX)
	pushw	wa	; F554F7  push WA
	pushw	de	; F554F8  push DE
	calr	List2030_Append4	; F554F9  calr 0xf552cc
	ld	c, (xix+1)	; F554FC  ld C,(XIX+0x01)
	pushw	bc	; F554FF  push BC
	pushw	0	; F55500  push 0x0000
	ld	c, (xix)	; F55503  ld C,(XIX)
	pushw	bc	; F55505  push BC
	pushw	de	; F55506  push DE
	calr	List2030_Append4	; F55507  calr 0xf552cc
	inc	8, xsp	; F5550A  inc 0,XSP
	inc	8, xsp	; F5550C  inc 0,XSP
	jr	IndexedTable_GetByte_Join7	; F5550E  jr T,0xf55539
IndexedTable_GetByte_Skip12:
	ld	c, h	; F55510  ld C,H
	cpl	c	; F55512  cpl C
	ld	h, c	; F55514  ld H,C
	and	h, l	; F55516  and H,L
	ld	xbc, (xiz-4)	; F55518  ld XBC,(XIZ+0xfc)
	ld	(xbc), h	; F5551B  ld (XBC),H
	ld	c, d	; F5551D  ld C,D
	or	c, h	; F5551F  or C,H
	ld	h, c	; F55521  ld H,C
	ld	xbc, (xiz-4)	; F55523  ld XBC,(XIZ+0xfc)
	ld	(xbc), h	; F55526  ld (XBC),H
	ld	c, (xix+1)	; F55528  ld C,(XIX+0x01)
	pushw	bc	; F5552B  push BC
	push	0	; F5552C  push 0x00
	push	d	; F5552E  push D
	ld	c, (xix)	; F55530  ld C,(XIX)
	pushw	bc	; F55532  push BC
	pushw	de	; F55533  push DE
	calr	Queue2C00_Append4	; F55534  calr 0xf55231
	inc	8, xsp	; F55537  inc 0,XSP
IndexedTable_GetByte_Join7:
	pop	xix	; F55539  pop XIX
	popw	de	; F5553A  pop DE
	popw	hl	; F5553B  pop HL
	unlk XIZ	; F5553C  unlk XIZ
	ret	; F5553E  ret
; ==============================================================================
; 0xF5553F-0xF57D1D -- THE 32-SELECTOR ROUTINE BANK, THE PARAMETER-FIELD WRITER
;   ABOVE IT, AND SIX RING-BUFFER BLOCK PUTS BELOW IT.  10,207 bytes, of which
;   1721 are 0x0E padding.
; ==============================================================================
;
; ⚠ THE BANK.  0xF55800-0xF558AD is a veneer block of 35 stubs, one per thunk
; slot in the run T_F40D90-T_F40E18, and 0xF558AE-0xF55C2D is SEVEN tables of 32
; 32-bit routine pointers.  Seven of the stubs are `ld XIX,<table> / call
; 0xF41B08 / ret`; the rest are `calr <routine> / ret` one-line forwarders.
; T_PanelButton_CallTableEntry is `jp 0x00F8BDC5`, and prom_a 0xF8BDC5 is
;     cp HL,0x1F / jr UGT,<ret> / ... / and L,0x1F / sla 2,L /
;     ld XIX,(XIX+L) / call XIX
; -- a bounds-checked call of entry HL of the table in XIX.  32 entries, 4 bytes
; each, 128 bytes per table.  ★ THIS IS THE SAME SHAPE AS 0xF7D000, already
; converted in this file, and the same three independent counts fix the number
; of tables at seven: the veneers hold exactly seven `ld XIX,imm32` naming these
; seven bases; the first seven 128-byte blocks are entirely ROM-range words and
; the eighth (0xF55C2E) is not; and 0xF55BAE + 0x80 = 0xF55C2E, where code
; resumes.
;
; ⚠ Bit32MaskTable (0xF55755) IS SETTLED, AND IT CLOSES AN OPEN QUESTION.  Word
; i is exactly 1 << i for i = 0..31.  The block above this span, converted
; earlier, reads it at 0xF55047 and its header says "That table is NOT converted
; here: nothing bounds its length."  The bound was in the reader all along:
; `cp HL,0x001f / jrl UGT` at 0xF55026 admits 0..31, so the table is 32 words =
; 128 bytes, which is exactly the segment the content rules found.
;
; ⚠ SIX RING-BUFFER BLOCK PUTS (0xF57C2D-0xF57D1D).  Each veneer loads a ring's
; DATA BASE into XHL and that ring's CAPACITY into WA and falls into one shared
; tail, Ring_PutBlockWrapped, which copies C bytes from XIY with an explicit wrap
; split.  All six base/capacity pairs match notes/FINDINGS-prom_a-ring-buffers.md
; ring for ring, and the tail reads prom_a's own control block -- the write index
; at base-4 and the free count at base-2, the two words prom_a's Ring_Put_0400
; uses at 0xF84225.  ⚠ NOT a copy of prom_a's PutBlock: that one is a
; byte-at-a-time `djnz` loop, this one a bounded `ldir`.
;
; ⚠ WHAT IS NOT KNOWN.  What the 32 selectors are; what the STATE BYTES that
; index the four 5-entry dispatch tables enumerate -- (0x36CE) for two of them
; and (0x3627) for the other two, which is not the same byte; what the 8-byte
; descriptor the routines at 0xF5553F use describes.  So the seven tables and the
; four dispatch tables keep FRAMED names, no table entry is named, and 96 of the
; 202 labels are sub_XXXXXX with the gap stated.
;
; ⚠ WHERE THE BOUNDARIES COME FROM.  notes/prom_b_f067a6_layout.py, re-derived
; on EVERY run of this file with LO/HI moved to this span and its `seeds()`
; replaced (its defaults were bound to the other span at import time).  17
; segments, 0 conflicts between the barrier rules and the code walk.  Not from a
; linear decode -- notes/prom_a_linear_decode_check.py records why one pins
; nothing.
;
; ⚠ ONE RUN LEFT UNCLAIMED.  0xF57453-0xF57571 decodes as code, but no 32-bit
; spelling of any address inside it occurs anywhere in prom_a or prom_b, at any
; byte offset, so it is emitted as `.byte` with the decode stated rather than
; promoted to code.  Same rule as 0xF38C4F in the 0xF353AB block and 0xF09E85 in
; the 0xF067A6 block.
;
; ⚠ CORRECTED 2026-09-25 (lane promb): the run IS referenced -- by five
; PC-relative `calr` in this block, which a 32-bit-spelling census cannot see --
; and is now five routines, SeqPlayScreen_StageValues .. CycleRecordScreen_
; StageValues.  See the header at 0xF57453.  So the LAYOUT line below is one
; tree state old: its "unclaimed run (287 bytes)" is code now.
;
; LAYOUT.  17 segments: 8 code (7095 bytes), 5 pointer tables (976 bytes),
; 1 bit table (128 bytes), 1 unclaimed run (287 bytes) and 2 runs of 0x0E `ret`
; padding (1721 bytes).  Substantive: 8486 of 10207.
;
; LABELS.  202, of which 106 carry a name derived from something and 96 are
; sub_XXXXXX with the gap stated.
;
; WHAT THE BLOCK TOUCHES, measured over the transcription itself.
; Heaviest 16-bit RAM words: (0x3628) x46 (0x3602) x32 (0x2540) x28 (0x360B) x25 (0x3627) x24 (0x3629) x20.
; That is a measurement of what the code ADDRESSES, not a claim about what it IS.
;
; REGENERATE:  python3 notes/gen_prom_b_f5553f_module.py
; CHECKS:      python3 notes/gen_prom_b_f5553f_module.py --selftest
; ==============================================================================


; --------------------------------------------------------------------------
; IndexedParam_SetFieldFromAsciiEntry
; Called from: T_IndexedParam_SetFieldFromAsciiEntry (0xF42CA8, x15)
; Touches: (0x2824) (0x2826) (0x28B0)
; Calls:   T_Blink_SetEnable T_AsciiField_ToSignedValue T_AsciiDigits3_ToValue
;          0xF552CC 0xF55321 0xF55231
; Evidence: the third member of the descriptor family the block above this
;           span converted, and it is the ENTRY-FIELD one.  It takes the same
;           two arguments as IndexedParam_AdjustField -- (XIZ+0x08) a 16-bit
;           INDEX, (XIZ+0x0A) a pointer to the 8-byte descriptor (+0 byte
;           offset, +1 field mask, +2 shift, +3 upper bound, +4 lower bound,
;           +7 XORed into (0x28B0)) -- and the same bit-4 rule (`add
;           (XIZ+0x08),0x20` at 0xF55580 when (0x28B0) bit 4 is set).  What is
;           new is where the VALUE comes from: descriptor +8 is split into two
;           nibbles, the low one stored to (0x2826) and the high one selecting
;           a bias into (0x2824) -- 0x10 -> 0x0040, 0x20 -> 0x0080, 0x30 ->
;           0x0018, anything else -> 0x0000 -- and then `call 0xF432F4` =
;           T_AsciiField_ToSignedValue reads the 0x2820-0x2826 ASCII ENTRY
;           FIELD, or `call 0xF432F0` = T_AsciiDigits3_ToValue when the high
;           nibble is zero.  prom_a's headers for those two say (0x2826) is
;           the live-cell count and (0x2824) the bias, which is exactly what
;           this routine writes into them.  The value is then masked into the
;           field through IndexedTable_GetPtr + descriptor +0 (`and (XIY),A /
;           or A,H`) and the change is journalled to List2030_Append4 when
;           (0x28B0) bit 3 is set and to Queue2C00_Append4 otherwise -- the
;           same two journals, chosen by the same bit, as
;           IndexedParam_AdjustField.  It returns A = 1.
; Unknown: what the descriptor describes, and so which parameter is being set.
;          The already-converted EditValue_StepBitField and IndexedParam_AdjustField say
;          the same and this file does not improve on them.  Also unknown:
;          what bit 6 of (0x28B0) selects -- when it is set the routine
;          instead pushes 0 or 1 and calls T_Blink_SetEnable, clears the bit
;          and returns.
; --------------------------------------------------------------------------
IndexedParam_SetFieldFromAsciiEntry:		; <- T_IndexedParam_SetFieldFromAsciiEntry
	link XIZ,0xfffc	; F5553F  link XIZ,0xfffc
	pushw	hl	; F55543  push HL
	pushw	de	; F55544  push DE
	push	xix	; F55545  push XIX
	ld	c, (PanelEvent_Flags:16)	; F55546  ld C,(0x28b0)
	and	c, 64	; F5554A  and C,0x40
	jr	z, IndexedTable_GetByte_Skip14	; F5554D  jr Z,0xf5556d
	ld	xbc, (xiz+10)	; F5554F  ld XBC,(XIZ+0x0a)
	ld	a, (xbc+8)	; F55552  ld A,(XBC+0x08)
	cp	a, 0:i3	; F55555  cp A,0
	jr	z, IndexedTable_GetByte_Skip13	; F55557  jr Z,0xf5555e
	pushw	1	; F55559  push 0x0001
	jr	IndexedTable_GetByte_Join8	; F5555C  jr T,0xf55561
IndexedTable_GetByte_Skip13:
	pushw	0	; F5555E  push 0x0000
IndexedTable_GetByte_Join8:
	call	T_Blink_SetEnable	; F55561  call 0xf42e28
	res	6, (PanelEvent_Flags:16)	; F55565  res 6,(0x28b0)
	popw	bc	; F55569  pop BC
	jrl	IndexedTable_GetByte_Loop	; F5556A  jrl T,0xf555e1
IndexedTable_GetByte_Skip14:
	ld	xbc, (xiz+10)	; F5556D  ld XBC,(XIZ+0x0a)
	ld	a, (xbc+7)	; F55570  ld A,(XBC+0x07)
	xor	(PanelEvent_Flags:16), a	; F55573  xor (0x28b0),A
	ld	a, (PanelEvent_Flags:16)	; F55577  ld A,(0x28b0)
	and	a, 16	; F5557B  and A,0x10
	jr	z, IndexedTable_GetByte_Skip15	; F5557E  jr Z,0xf55584
	add	(xiz+8), 0x20	; F55580  add (XIZ+0x08),0x20
IndexedTable_GetByte_Skip15:
	ld	xbc, (xiz+10)	; F55584  ld XBC,(XIZ+0x0a)
	ld	h, (xbc+8)	; F55587  ld H,(XBC+0x08)
	and	h, 15	; F5558A  and H,0x0f
	jr	z, IndexedTable_GetByte_Loop	; F5558D  jr Z,0xf555e1
	ld	(10278:16), h	; F5558F  ld (0x2826),H
	ld	h, (xbc+8)	; F55593  ld H,(XBC+0x08)
	and	h, 240	; F55596  and H,0xf0
	jr	z, IndexedTable_GetByte_Skip19	; F55599  jr Z,0xf555d9
	ld	a, h	; F5559B  ld A,H
	extz	wa	; F5559D  extz WA
	cp	wa, 16	; F5559F  cp WA,0x0010
	jr	z, IndexedTable_GetByte_Skip16	; F555A3  jr Z,0xf555b3
	cp	wa, 32	; F555A5  cp WA,0x0020
	jr	z, IndexedTable_GetByte_Skip17	; F555A9  jr Z,0xf555bb
	cp	wa, 48	; F555AB  cp WA,0x0030
	jr	z, IndexedTable_GetByte_Skip18	; F555AF  jr Z,0xf555c3
	jr	IndexedTable_GetByte_Join9	; F555B1  jr T,0xf555cb
IndexedTable_GetByte_Skip16:
	ldw	(10276:16), 64	; F555B3  ld (0x2824),0x0040
	jr	IndexedTable_GetByte_Join10	; F555B9  jr T,0xf555d1
IndexedTable_GetByte_Skip17:
	ldw	(10276:16), 128	; F555BB  ld (0x2824),0x0080
	jr	IndexedTable_GetByte_Join10	; F555C1  jr T,0xf555d1
IndexedTable_GetByte_Skip18:
	ldw	(10276:16), 24	; F555C3  ld (0x2824),0x0018
	jr	IndexedTable_GetByte_Join10	; F555C9  jr T,0xf555d1
IndexedTable_GetByte_Join9:
	ldw	(10276:16), 0	; F555CB  ld (0x2824),0x0000
IndexedTable_GetByte_Join10:
	call	T_AsciiField_ToSignedValue	; F555D1  call 0xf432f4
	ld	hl, wa	; F555D5  ld HL,WA
	jr	IndexedTable_GetByte_Join11	; F555D7  jr T,0xf555e6
IndexedTable_GetByte_Skip19:
	call	T_AsciiDigits3_ToValue	; F555D9  call 0xf432f0
	ld	hl, wa	; F555DD  ld HL,WA
	jr	IndexedTable_GetByte_Join11	; F555DF  jr T,0xf555e6
IndexedTable_GetByte_Loop:
	sub	a, a	; F555E1  sub A,A
	jrl	IndexedTable_GetByte_Join16	; F555E3  jrl T,0xf556cc
IndexedTable_GetByte_Join11:
	ld	c, (PanelEvent_Flags:16)	; F555E6  ld C,(0x28b0)
	and	c, 128	; F555EA  and C,0x80
	jr	z, IndexedTable_GetByte_Skip20	; F555ED  jr Z,0xf555f1
	dec	1, hl	; F555EF  dec 1,HL
IndexedTable_GetByte_Skip20:
	ld	ix, hl	; F555F1  ld IX,HL
	ld	h, 0:opc	; F555F3  ld H,0x00
	ld	xbc, (xiz+10)	; F555F5  ld XBC,(XIZ+0x0a)
	ld	l, (xbc+2)	; F555F8  ld L,(XBC+0x02)
IndexedTable_GetByte_Join12:
	cp	h, l	; F555FB  cp H,L
	jr	nc, IndexedTable_GetByte_Skip21	; F555FD  jr NC,0xf5560a
	ld	bc, ix	; F555FF  ld BC,IX
	srl	bc, 1	; F55601  srl 0x01,BC
	ld	ix, bc	; F55604  ld IX,BC
	inc	1, h	; F55606  inc 1,H
	jr	IndexedTable_GetByte_Join12	; F55608  jr T,0xf555fb
IndexedTable_GetByte_Skip21:
	ld	de, ix	; F5560A  ld DE,IX
	ld	xbc, (xiz+10)	; F5560C  ld XBC,(XIZ+0x0a)
	ld	a, (xbc+4)	; F5560F  ld A,(XBC+0x04)
	extz	wa	; F55612  extz WA
	ld	hl, wa	; F55614  ld HL,WA
	cp	ix, wa	; F55616  cp IX,WA
	jr	nc, IndexedTable_GetByte_Skip22	; F55618  jr NC,0xf5561c
	ld	de, wa	; F5561A  ld DE,WA
IndexedTable_GetByte_Skip22:
	ld	xbc, (xiz+10)	; F5561C  ld XBC,(XIZ+0x0a)
	ld	a, (xbc+3)	; F5561F  ld A,(XBC+0x03)
	extz	wa	; F55622  extz WA
	ld	hl, wa	; F55624  ld HL,WA
	cp	de, wa	; F55626  cp DE,WA
	jr	ule, IndexedTable_GetByte_Skip23	; F55628  jr ULE,0xf5562c
	ld	de, wa	; F5562A  ld DE,WA
IndexedTable_GetByte_Skip23:
	cp	de, ix	; F5562C  cp DE,IX
	jr	z, IndexedTable_GetByte_Skip24	; F5562E  jr Z,0xf55646
	ld	h, 0:opc	; F55630  ld H,0x00
	ld	xbc, (xiz+10)	; F55632  ld XBC,(XIZ+0x0a)
	ld	l, (xbc+2)	; F55635  ld L,(XBC+0x02)
IndexedTable_GetByte_Join13:
	cp	h, l	; F55638  cp H,L
	jr	nc, IndexedTable_GetByte_Loop	; F5563A  jr NC,0xf555e1
	ld	bc, de	; F5563C  ld BC,DE
	add	bc, de	; F5563E  add BC,DE
	ld	de, bc	; F55640  ld DE,BC
	inc	1, h	; F55642  inc 1,H
	jr	IndexedTable_GetByte_Join13	; F55644  jr T,0xf55638
IndexedTable_GetByte_Skip24:
	ld	h, 0:opc	; F55646  ld H,0x00
	ld	xbc, (xiz+10)	; F55648  ld XBC,(XIZ+0x0a)
	ld	l, (xbc+2)	; F5564B  ld L,(XBC+0x02)
IndexedTable_GetByte_Join14:
	cp	h, l	; F5564E  cp H,L
	jr	nc, IndexedTable_GetByte_Skip25	; F55650  jr NC,0xf5565c
	ld	bc, de	; F55652  ld BC,DE
	add	bc, de	; F55654  add BC,DE
	ld	de, bc	; F55656  ld DE,BC
	inc	1, h	; F55658  inc 1,H
	jr	IndexedTable_GetByte_Join14	; F5565A  jr T,0xf5564e
IndexedTable_GetByte_Skip25:
	ld	xbc, (xiz+10)	; F5565C  ld XBC,(XIZ+0x0a)
	ld	h, (xbc+1)	; F5565F  ld H,(XBC+0x01)
	ld	a, h	; F55662  ld A,H
	extz	wa	; F55664  extz WA
	and	de, wa	; F55666  and DE,WA
	ld	a, (PanelEvent_Flags:16)	; F55668  ld A,(0x28b0)
	and	a, 8	; F5566C  and A,0x08
	jr	z, IndexedTable_GetByte_Skip26	; F5566F  jr Z,0xf55687
	push	0	; F55671  push 0x00
	push	h	; F55673  push H
	ld	a, e	; F55675  ld A,E
	pushw	wa	; F55677  push WA
	ld	a, (xbc)	; F55678  ld A,(XBC)
	pushw	wa	; F5567A  push WA
	push	0	; F5567B  push 0x00
	push	(xiz+8)	; F5567D  push (XIZ+0x08)
	calr	List2030_Append4	; F55680  calr 0xf552cc
	inc	8, xsp	; F55683  inc 0,XSP
	jr	IndexedTable_GetByte_Join15	; F55685  jr T,0xf556ca
IndexedTable_GetByte_Skip26:
	push	0	; F55687  push 0x00
	push	(xiz+8)	; F55689  push (XIZ+0x08)
	calr	IndexedTable_GetPtr	; F5568C  calr 0xf55321
	ld	xix, xiy	; F5568F  ld XIX,XIY
	ld	xbc, (xiz+10)	; F55691  ld XBC,(XIZ+0x0a)
	ld	a, (xbc)	; F55694  ld A,(XBC)
	extz	wa	; F55696  extz WA
	extz	xwa	; F55698  extz XWA
	add	xiy, xwa	; F5569A  add XIY,XWA
	ld	(xiz-4), xiy	; F5569C  ld (XIZ+0xfc),XIY
	ld	a, (xbc+1)	; F5569F  ld A,(XBC+0x01)
	cpl	a	; F556A2  cpl A
	and	(xiy), a	; F556A4  and (XIY),A
	ld	xbc, (xiz-4)	; F556A6  ld XBC,(XIZ+0xfc)
	ld	h, (xbc)	; F556A9  ld H,(XBC)
	ld	l, e	; F556AB  ld L,E
	ld	a, l	; F556AD  ld A,L
	or	a, h	; F556AF  or A,H
	ld	(xbc), a	; F556B1  ld (XBC),A
	ld	xbc, (xiz+10)	; F556B3  ld XBC,(XIZ+0x0a)
	ld	a, (xbc+1)	; F556B6  ld A,(XBC+0x01)
	pushw	wa	; F556B9  push WA
	pushw	hl	; F556BA  push HL
	ld	a, (xbc)	; F556BB  ld A,(XBC)
	pushw	wa	; F556BD  push WA
	push	0	; F556BE  push 0x00
	push	(xiz+8)	; F556C0  push (XIZ+0x08)
	calr	Queue2C00_Append4	; F556C3  calr 0xf55231
	inc	8, xsp	; F556C6  inc 0,XSP
	inc	2, xsp	; F556C8  inc 2,XSP
IndexedTable_GetByte_Join15:
	ld	a, 1:opc	; F556CA  ld A,0x01
IndexedTable_GetByte_Join16:
	pop	xix	; F556CC  pop XIX
	popw	de	; F556CD  pop DE
	popw	hl	; F556CE  pop HL
	unlk XIZ	; F556CF  unlk XIZ
	ret	; F556D1  ret

; --------------------------------------------------------------------------
; PartIndex_PostChangeEvent
; Called from: T_PartIndex_PostChangeEvent (0xF42C9C, x13)
; Touches: (0x2250)
; Calls:   0xF55231 T_NoteRouting_Rebuild
; Evidence: thunk slot T_PartIndex_PostChangeEvent holds `jp 0x00F556D2`, and 0xF556D2 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; PartIndex_PostChangeEvent: Posts the UI event {class 0x90, code 0x10, value UI_PartIndex, mask 0xFF} to the 0x2C00
;   queue (Queue2C00_Append4), then T_NoteRouting_Rebuild; the COMBINATION EDIT part keys and screens call it right
;   after changing UI_PartIndex. Class 0x90 code 0x10 is what PanelLed_OnClass90Event and UiEvent_SyncSoundSelection
;   react to. Basis: callers + body + event-list handlers. (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
PartIndex_PostChangeEvent:		; <- T_PartIndex_PostChangeEvent
	pushw	255	; F556D2  push 0x00ff
	ld	c, (UI_PartIndex:16)	; F556D5  ld C,(0x2250)
	pushw	bc	; F556D9  push BC
	pushw	16	; F556DA  push 0x0010
	pushw	144	; F556DD  push 0x0090
	calr	Queue2C00_Append4	; F556E0  calr 0xf55231
	call	T_NoteRouting_Rebuild	; F556E3  call 0xf411bc
	inc	8, xsp	; F556E7  inc 0,XSP
	ret	; F556E9  ret

; --------------------------------------------------------------------------
; PartSound_CopyNameToDrawScratch
; Called from: T_PartSound_CopyNameToDrawScratch (0xF42CA0, x5)
; Touches: (0x2640) (0x2641) (0x2642)
; Calls:   0xF5533C T_SoundName_Lookup
; Evidence: thunk slot T_PartSound_CopyNameToDrawScratch holds `jp 0x00F556EA`, and 0xF556EA is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; PartSound_CopyNameToDrawScratch: (part L): bank = byte 1 and number = byte 0 of IndexedTable record L (the part
;   record), SoundName_Lookup asks CPU 2 for the name, 16 bytes copied to UI_DrawScratch. The combination editors call
;   it (T_PartSound_CopyNameToDrawScratch) and then draw UI_DrawScratch as the part's sound name. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_c.json)
PartSound_CopyNameToDrawScratch:		; <- T_PartSound_CopyNameToDrawScratch
	link XIZ,0xfffc	; F556EA  link XIZ,0xfffc
	pushw	hl	; F556EE  push HL
	push	xix	; F556EF  push XIX
	ld	l, (xiz+8)	; F556F0  ld L,(XIZ+0x08)
	pushw	1	; F556F3  push 0x0001
	pushw	hl	; F556F6  push HL
	calr	IndexedTable_GetByte	; F556F7  calr 0xf5533c
	ld	(UI_DrawScratch:16), a	; F556FA  ld (0x2640),A
	pushw	0	; F556FE  push 0x0000
	pushw	hl	; F55701  push HL
	calr	IndexedTable_GetByte	; F55702  calr 0xf5533c
	ld	(UI_DrawScratch+1:16), a	; F55705  ld (0x2641),A
	ld	(UI_DrawScratch+2:16), l	; F55709  ld (0x2642),L
	inc	8, xsp	; F5570D  inc 0,XSP
	push	xde	; F5570F  push XDE
	push	xhl	; F55710  push XHL
	push	xix	; F55711  push XIX
	push	xiz	; F55712  push XIZ
	ld	w, (UI_DrawScratch:16)	; F55713  ld W,(0x2640)
	ld	a, (UI_DrawScratch+1:16)	; F55717  ld A,(0x2641)
	ld	b, (UI_DrawScratch+2:16)	; F5571B  ld B,(0x2642)
	call	T_SoundName_Lookup	; F5571F  call 0xf41010
	ld	(UI_DrawScratch:16), xiy	; F55723  ld (0x2640),XIY
	pop	xiz	; F55727  pop XIZ
	pop	xix	; F55728  pop XIX
	pop	xhl	; F55729  pop XHL
	pop	xde	; F5572A  pop XDE
	lda	xbc, (UI_DrawScratch:16)	; F5572B  lda XBC,0x2640
	ld	(xiz-4), xbc	; F5572F  ld (XIZ+0xfc),XBC
	ld	xwa, (UI_DrawScratch:16)	; F55732  ld XWA,(0x2640)
	ld	xix, xwa	; F55736  ld XIX,XWA
	ld	h, 4:opc	; F55738  ld H,0x04
IndexedTable_GetByte_Loop2:
	ld	xbc, (xix)	; F5573A  ld XBC,(XIX)
	ld	xwa, (xiz-4)	; F5573C  ld XWA,(XIZ+0xfc)
	ld	(xwa), xbc	; F5573F  ld (XWA),XBC
	inc	4, xix	; F55741  inc 4,XIX
	sub	xbc, xbc	; F55743  sub XBC,XBC
	inc	4, xbc	; F55745  inc 4,XBC
	add	(xiz-4), xbc	; F55747  add (XIZ+0xfc),XBC
	dec	1, h	; F5574A  dec 1,H
	cp	h, 0:i3	; F5574C  cp H,0
	jr	nz, IndexedTable_GetByte_Loop2	; F5574E  jr NZ,0xf5573a
	pop	xix	; F55750  pop XIX
	popw	hl	; F55751  pop HL
	unlk XIZ	; F55752  unlk XIZ
	ret	; F55754  ret

; --------------------------------------------------------------------------
; Bit32MaskTable -- 32 32-bit words, and word i is EXACTLY 1 << i.  A power-
;                   of-two mask indexed by a 5-bit selector.
; Read by: PanelCode_ToSlotAndFlags at 0xF55047, in the already-converted block above this
;          span: `ld C,0x04 / mul BC,(0x28b1) / extz XBC / add XBC,0x00F55755
;          / ld XBC,(XBC) / and XBC,(0x208c)` -- word (0x28B1) of this table
;          is AND-ed with the 32-bit word at (0x208C) and the result sets bit
;          1 of the flag byte (0x28B0).  So (0x208C) is a 32-bit SET and this
;          table turns the selector into its membership mask.
; Evidence: THE EXTENT IS PROVED BY THE READER'S OWN BOUND, not by the
;           segment: `cp HL,0x001f / jrl UGT,0xF550A1` at 0xF55026 rejects a
;           selector above 31 before anything is read, so the index space is
;           0..31, four bytes each, 128 bytes -- exactly this segment.  And
;           every word is re-read on each emit and asserted equal to 1 << i.
;           ⚠ The block above this span says of this table "nothing bounds its
;           length"; that is now wrong, and the bound was in its reader.
; Unknown: what the 32 selectors ARE, and what the 32-bit set at (0x208C)
;          means.  The table is named for what it CONTAINS, which is all that
;          is established.
; --------------------------------------------------------------------------
Bit32MaskTable:
	.long	0x00000001	; F55755  [ 0]  1 << 0
	.long	0x00000002	; F55759  [ 1]  1 << 1
	.long	0x00000004	; F5575D  [ 2]  1 << 2
	.long	0x00000008	; F55761  [ 3]  1 << 3
	.long	0x00000010	; F55765  [ 4]  1 << 4
	.long	0x00000020	; F55769  [ 5]  1 << 5
	.long	0x00000040	; F5576D  [ 6]  1 << 6
	.long	0x00000080	; F55771  [ 7]  1 << 7
	.long	0x00000100	; F55775  [ 8]  1 << 8
	.long	0x00000200	; F55779  [ 9]  1 << 9
	.long	0x00000400	; F5577D  [10]  1 << 10
	.long	0x00000800	; F55781  [11]  1 << 11
	.long	0x00001000	; F55785  [12]  1 << 12
	.long	0x00002000	; F55789  [13]  1 << 13
	.long	0x00004000	; F5578D  [14]  1 << 14
	.long	0x00008000	; F55791  [15]  1 << 15
	.long	0x00010000	; F55795  [16]  1 << 16
	.long	0x00020000	; F55799  [17]  1 << 17
	.long	0x00040000	; F5579D  [18]  1 << 18
	.long	0x00080000	; F557A1  [19]  1 << 19
	.long	0x00100000	; F557A5  [20]  1 << 20
	.long	0x00200000	; F557A9  [21]  1 << 21
	.long	0x00400000	; F557AD  [22]  1 << 22
	.long	0x00800000	; F557B1  [23]  1 << 23
	.long	0x01000000	; F557B5  [24]  1 << 24
	.long	0x02000000	; F557B9  [25]  1 << 25
	.long	0x04000000	; F557BD  [26]  1 << 26
	.long	0x08000000	; F557C1  [27]  1 << 27
	.long	0x10000000	; F557C5  [28]  1 << 28
	.long	0x20000000	; F557C9  [29]  1 << 29
	.long	0x40000000	; F557CD  [30]  1 << 30
	.long	0x80000000	; F557D1  [31]  1 << 31

	.fill	43, 1, 0x0E	; F557D5-F557FF  `ret` padding (asserted pure 0x0E)
