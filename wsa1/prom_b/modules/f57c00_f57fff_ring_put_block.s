

; --------------------------------------------------------------------------
; RingPutBlock_EntryThunks
; Called from: T_RingPutBlock_EntryThunks (0xF40ED0, x0)
; Touches: nothing with an absolute address
; Evidence: prom_b's thunk table reaches this address through a POINTER slot,
;           not a `jp` slot: the slot at 0xF40ED0 holds the 32-bit value
;           0x00F57C00.  The eight 4-byte slots here are `jp` instructions --
;           slot 0 to 0xF57C21 and slots 1..7 all to the bare `ret` at
;           0xF57C20 -- which is the six-thunk-group shape notes/FINDINGS-
;           prom_b-thunk-table.md records for the 26 pointer slots, here eight
;           slots wide.  Only entry 0 does anything.
; Unknown: what the group is FOR.  Seven of its eight entries return
;          immediately, and nothing decoded here says what the other seven
;          were meant to be.
; --------------------------------------------------------------------------
RingPutBlock_EntryThunks:		; <- T_RingPutBlock_EntryThunks
	jp	RingPutBlock_InitRing601850	; F57C00  jp 0xf57c21
	jp	Nop_Ret_F57C20	; F57C04  jp 0xf57c20
	jp	Nop_Ret_F57C20	; F57C08  jp 0xf57c20
	jp	Nop_Ret_F57C20	; F57C0C  jp 0xf57c20
	jp	Nop_Ret_F57C20	; F57C10  jp 0xf57c20
	jp	Nop_Ret_F57C20	; F57C14  jp 0xf57c20
	jp	Nop_Ret_F57C20	; F57C18  jp 0xf57c20
	jp	Nop_Ret_F57C20	; F57C1C  jp 0xf57c20

; --------------------------------------------------------------------------
; Nop_Ret_F57C20
; Called from: in-module: 0xF57C04 0xF57C08 0xF57C0C 0xF57C10 0xF57C14
;              0xF57C18 0xF57C1C
; Touches: nothing with an absolute address
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF57C20 is an instruction boundary.
; Shape:   the whole body is one byte, 0x0E = RET (mame dasm900.cpp:1267).
;          The routine does nothing, and the table slots that point at it are
;          selectors with no handler.
; Unknown: what the routine is FOR.  The name states what it DOES, which is
;          why it keeps an address and grades FRAMED, not content: the thing
;          that would distinguish it from its siblings is a bare index into
;          something nobody has named.
; --------------------------------------------------------------------------
Nop_Ret_F57C20:
	ret	; F57C20  ret

; --------------------------------------------------------------------------
; RingPutBlock_InitRing601850
; Called from: in-module: 0xF57C00
; Touches: nothing with an absolute address
; Calls:   0xF57D1E T_Ring601850_Init 0xF8E001
; Evidence: `calr 0xF57D1E` (the INTT2 handler block immediately below this
;           span), then `call 0xF41E6C` = T_Ring601850_Init, then `call
;           0xF8E001`, then `ret`.  The name says which ring the one live
;           entry of the group above initialises, and nothing more.
; Unknown: what `call 0xF8E001` in prom_a does, and why the ring init is
;          bracketed the way it is.
; --------------------------------------------------------------------------
RingPutBlock_InitRing601850:
	calr	Clear_600780_98	; F57C21  calr 0xf57d1e
	call	T_Ring601850_Init	; F57C24  call 0xf41e6c
	call	Link_Init_DmaAndTimer	; F57C28  call 0xf8e001
	ret	; F57C2C  ret

; --------------------------------------------------------------------------
; Ring608A0A_PutBlock_Ldir
; Called from: no thunk slot, no arm-table entry and no in-module branch that
;              this census sees -- reached only by falling through from the
;              code above, or by a computed transfer nothing here decodes
; Touches:   |  0x608A0A
; Evidence: `ld XHL,0x00608A0A / ld WA,0x0400` and a jump into
;           Ring_PutBlockWrapped: the ring's data base and its capacity, side
;           by side.  0x608A0A's capacity is 0x400 in notes/FINDINGS-prom_a-
;           ring-buffers.md's table, which was derived independently in prom_a
;           from the nine veneers of that ring's group agreeing on one class
;           routine.  All six veneers here match that table.  ⚠ This is NOT
;           prom_a's Ring608A0A_PutBlock: that one is a byte-at-a-time `djnz`
;           loop calling Ring_Put_0400, this one is a bounded `ldir`.  The
;           `_Ldir` suffix is the difference.
; Unknown: what this ring carries.  The name states the ring and the
;          operation, which is all the bytes here say.
; --------------------------------------------------------------------------
Ring608A0A_PutBlock_Ldir:
	ld	c, (xsp+4)	; F57C2D  ld C,(XSP+0x04)
	ld	xiy, (xsp+6)	; F57C30  ld XIY,(XSP+0x06)
	push	xhl	; F57C33  push XHL
	ld	xhl, 6326794	; F57C34  ld XHL,0x00608a0a
	ldw	wa, 1024	; F57C39  ld WA,0x0400
	jrl	Ring_PutBlockWrapped	; F57C3C  jrl T,0xf57ccd

; --------------------------------------------------------------------------
; Ring60480A_PutBlock_Ldir
; Called from: no thunk slot, no arm-table entry and no in-module branch that
;              this census sees -- reached only by falling through from the
;              code above, or by a computed transfer nothing here decodes
; Touches:   |  0x60480A
; Evidence: `ld XHL,0x0060480A / ld WA,0x0100` and a jump into
;           Ring_PutBlockWrapped: the ring's data base and its capacity, side
;           by side.  0x60480A's capacity is 0x100 in notes/FINDINGS-prom_a-
;           ring-buffers.md's table, which was derived independently in prom_a
;           from the nine veneers of that ring's group agreeing on one class
;           routine.  All six veneers here match that table.  ⚠ This is NOT
;           prom_a's Ring60480A_PutBlock: that one is a byte-at-a-time `djnz`
;           loop calling Ring_Put_0400, this one is a bounded `ldir`.  The
;           `_Ldir` suffix is the difference.
; Unknown: what this ring carries.  The name states the ring and the
;          operation, which is all the bytes here say.
; --------------------------------------------------------------------------
Ring60480A_PutBlock_Ldir:
	ld	c, (xsp+4)	; F57C3F  ld C,(XSP+0x04)
	ld	xiy, (xsp+6)	; F57C42  ld XIY,(XSP+0x06)
	push	xhl	; F57C45  push XHL
	ld	xhl, 6309898	; F57C46  ld XHL,0x0060480a
	ldw	wa, 256	; F57C4B  ld WA,0x0100
	jr	Ring_PutBlockWrapped	; F57C4E  jr T,0xf57ccd

; --------------------------------------------------------------------------
; Ring601B64_PutBlock_Ldir
; Called from: no thunk slot, no arm-table entry and no in-module branch that
;              this census sees -- reached only by falling through from the
;              code above, or by a computed transfer nothing here decodes
; Touches:   |  0x601B64
; Evidence: `ld XHL,0x00601B64 / ld WA,0x0100` and a jump into
;           Ring_PutBlockWrapped: the ring's data base and its capacity, side
;           by side.  0x601B64's capacity is 0x100 in notes/FINDINGS-prom_a-
;           ring-buffers.md's table, which was derived independently in prom_a
;           from the nine veneers of that ring's group agreeing on one class
;           routine.  All six veneers here match that table.  ⚠ This is NOT
;           prom_a's Ring601B64_PutBlock: that one is a byte-at-a-time `djnz`
;           loop calling Ring_Put_0400, this one is a bounded `ldir`.  The
;           `_Ldir` suffix is the difference.
; Unknown: what this ring carries.  The name states the ring and the
;          operation, which is all the bytes here say.
; --------------------------------------------------------------------------
Ring601B64_PutBlock_Ldir:
	ld	c, (xsp+4)	; F57C50  ld C,(XSP+0x04)
	ld	xiy, (xsp+6)	; F57C53  ld XIY,(XSP+0x06)
	push	xhl	; F57C56  push XHL
	ld	xhl, 6298468	; F57C57  ld XHL,0x00601b64
	ldw	wa, 256	; F57C5C  ld WA,0x0100
	jr	Ring_PutBlockWrapped	; F57C5F  jr T,0xf57ccd

; --------------------------------------------------------------------------
; Ring60000C_PutBlock_Ldir
; Called from: no thunk slot, no arm-table entry and no in-module branch that
;              this census sees -- reached only by falling through from the
;              code above, or by a computed transfer nothing here decodes
; Touches:   |  0x60000C
; Evidence: `ld XHL,0x0060000C / ld WA,0x0400` and a jump into
;           Ring_PutBlockWrapped: the ring's data base and its capacity, side
;           by side.  0x60000C's capacity is 0x400 in notes/FINDINGS-prom_a-
;           ring-buffers.md's table, which was derived independently in prom_a
;           from the nine veneers of that ring's group agreeing on one class
;           routine.  All six veneers here match that table.  ⚠ This is NOT
;           prom_a's Ring60000C_PutBlock: that one is a byte-at-a-time `djnz`
;           loop calling Ring_Put_0400, this one is a bounded `ldir`.  The
;           `_Ldir` suffix is the difference.
; Unknown: what this ring carries.  The name states the ring and the
;          operation, which is all the bytes here say.
; --------------------------------------------------------------------------
Ring60000C_PutBlock_Ldir:
	ld	c, (xsp+4)	; F57C61  ld C,(XSP+0x04)
	ld	xiy, (xsp+6)	; F57C64  ld XIY,(XSP+0x06)
	push	xhl	; F57C67  push XHL
	ld	xhl, 6291468	; F57C68  ld XHL,0x0060000c
	ldw	wa, 1024	; F57C6D  ld WA,0x0400
	jr	Ring_PutBlockWrapped	; F57C70  jr T,0xf57ccd

; --------------------------------------------------------------------------
; Ring60195A_PutBlock_Ldir
; Called from: no thunk slot, no arm-table entry and no in-module branch that
;              this census sees -- reached only by falling through from the
;              code above, or by a computed transfer nothing here decodes
; Touches:   |  0x60195A
; Evidence: `ld XHL,0x0060195A / ld WA,0x0200` and a jump into
;           Ring_PutBlockWrapped: the ring's data base and its capacity, side
;           by side.  0x60195A's capacity is 0x200 in notes/FINDINGS-prom_a-
;           ring-buffers.md's table, which was derived independently in prom_a
;           from the nine veneers of that ring's group agreeing on one class
;           routine.  All six veneers here match that table.  ⚠ This is NOT
;           prom_a's Ring60195A_PutBlock: that one is a byte-at-a-time `djnz`
;           loop calling Ring_Put_0400, this one is a bounded `ldir`.  The
;           `_Ldir` suffix is the difference.
; Unknown: what this ring carries.  The name states the ring and the
;          operation, which is all the bytes here say.
; --------------------------------------------------------------------------
Ring60195A_PutBlock_Ldir:
	ld	c, (xsp+4)	; F57C72  ld C,(XSP+0x04)
	ld	xiy, (xsp+6)	; F57C75  ld XIY,(XSP+0x06)
	push	xhl	; F57C78  push XHL
	ld	xhl, 6297946	; F57C79  ld XHL,0x0060195a
	ldw	wa, 512	; F57C7E  ld WA,0x0200
	jr	Ring_PutBlockWrapped	; F57C81  jr T,0xf57ccd
Ring601850_PutBlock_LeadB0_StoreNext:
	inc	1, xiy	; F57C83  inc 1,XIY
	ld	a, (xiy)	; F57C85  ld A,(XIY)
	ld	(6291456:24), a	; F57C87  ld (0x600000),A
	ret	; F57C8C  ret
Ring601850_PutBlock_LeadB1_StoreNext:
	inc	1, xiy	; F57C8D  inc 1,XIY
	ld	a, (xiy)	; F57C8F  ld A,(XIY)
	ld	(6291457:24), a	; F57C91  ld (0x600001),A
	ret	; F57C96  ret

; --------------------------------------------------------------------------
; Ring601850_PutBlock_Drop1In3
; Called from: no thunk slot, no arm-table entry and no in-module branch that
;              this census sees -- reached only by falling through from the
;              code above, or by a computed transfer nothing here decodes
; Touches:   |  0x601850
; Evidence: the loop at 0xF57CAF is `inc 1,XIY / ld WA,(XIY+) / ld (XHL+),WA`,
;           so the source advances THREE bytes and the destination TWO on
;           every iteration, and the counters agree -- `inc 3,D` against `inc
;           2,E`, with D compared to the caller's byte count C.  It rewrites
;           the buffer in place, dropping the first byte of every three, and
;           then falls into Ring_PutBlockWrapped with XHL = 0x00601850 and WA
;           = 0x0100 -- ring 0x601850, whose capacity in notes/FINDINGS-
;           prom_a-ring-buffers.md is 0x100.  Two lead bytes never reach the
;           ring: `cp A,0xb0` and `cp A,0xb1` divert to single stores at
;           (0x600000) and (0x600001).
; Unknown: what the three-byte records ARE.  0xB0/0xB1 are the MIDI status
;          bytes for Control Change on channels 1 and 2, which is SUGGESTIVE
;          and is NOT asserted: nothing decoded here says the buffer is MIDI,
;          and the routine treats every other lead byte identically.
; --------------------------------------------------------------------------
Ring601850_PutBlock_Drop1In3:
	ld	c, (xsp+4)	; F57C97  ld C,(XSP+0x04)
	ld	xiy, (xsp+6)	; F57C9A  ld XIY,(XSP+0x06)
	ld	a, (xiy)	; F57C9D  ld A,(XIY)
	cp	a, 176	; F57C9F  cp A,0xb0
	jr	z, Ring601850_PutBlock_LeadB0_StoreNext	; F57CA2  jr Z,0xf57c83
	cp	a, 177	; F57CA4  cp A,0xb1
	jr	z, Ring601850_PutBlock_LeadB1_StoreNext	; F57CA7  jr Z,0xf57c8d
	push	xhl	; F57CA9  push XHL
	pushw	de	; F57CAA  push DE
	ld	xhl, xiy	; F57CAB  ld XHL,XIY
	xor	de, de	; F57CAD  xor DE,DE
Ring601850_PutBlock_Drop1In3_Loop:
	inc	1, xiy	; F57CAF  inc 1,XIY
	ld	wa, (xiy+)	; F57CB1  ld WA,(XIY+)
	ld	(xhl+), wa	; F57CB4  ld (XHL+),WA
	inc	3, d	; F57CB7  inc 3,D
	inc	2, e	; F57CB9  inc 2,E
	cp	d, c	; F57CBB  cp D,C
	jr	nz, Ring601850_PutBlock_Drop1In3_Loop	; F57CBD  jr NZ,0xf57caf
	ld	c, e	; F57CBF  ld C,E
	ld	xiy, (xsp+12)	; F57CC1  ld XIY,(XSP+0x0c)
	ld	xhl, 6297680	; F57CC4  ld XHL,0x00601850
	ldw	wa, 256	; F57CC9  ld WA,0x0100
	popw	de	; F57CCC  pop DE

; --------------------------------------------------------------------------
; Ring_PutBlockWrapped
; Called from: no thunk slot, no arm-table entry and no in-module branch that
;              this census sees -- reached only by falling through from the
;              code above, or by a computed transfer nothing here decodes
; Touches: nothing with an absolute address
; Evidence: the shared tail of the six veneers above it, and it is prom_a's
;           RING CONTROL BLOCK read by a different implementation.  XHL is a
;           ring's data base, WA its capacity, C a byte count, XIY the source.
;           `cp (XIX+0xfe),BC / jr C` drops the whole block if the FREE COUNT
;           at base-2 is smaller than the count -- all or nothing; `ld
;           DE,(XIX+0xfc)` takes the WRITE INDEX at base-4; `sub
;           (XIX+0xfe),BC` spends the free count; `sub WA,DE` gives the bytes
;           left before the end of the buffer and is compared with the count,
;           so a block that would run past the end is copied in TWO `ldir`s
;           with the index wrapped to 0 in between.  base-4 and base-2 are
;           exactly the two words prom_a's `Ring_Put_0400` uses at
;           0xF84225-0xF84237.
; --------------------------------------------------------------------------
Ring_PutBlockWrapped:
	push	xix	; F57CCD  push XIX
	pushw	de	; F57CCE  push DE
	or	c, c	; F57CCF  or C,C
	jr	z, Ring_PutBlockWrapped_Done	; F57CD1  jr Z,0xf57d1a
	extz	bc	; F57CD3  extz BC
	ld	xix, xhl	; F57CD5  ld XIX,XHL
	cp	(xix-2), bc	; F57CD7  cp (XIX+0xfe),BC
	jr	c, Ring_PutBlockWrapped_Done	; F57CDA  jr C,0xf57d1a
	ld	de, (xix-4)	; F57CDC  ld DE,(XIX+0xfc)
	sub	(xix-2), bc	; F57CDF  sub (XIX+0xfe),BC
	sub	wa, de	; F57CE2  sub WA,DE
	cp	wa, bc	; F57CE4  cp WA,BC
	jr	c, Ring_PutBlockWrapped_TwoCopies	; F57CE6  jr C,0xf57d04
	jr	z, Ring_PutBlockWrapped_EndsAtTop	; F57CE8  jr Z,0xf57cf6
	add	(xix-4), bc	; F57CEA  add (XIX+0xfc),BC
	lda	xix, (xix+de)	; F57CED  lda XIX,XIX+DE
	ldir85	; F57CF2  ldir
	jr	Ring_PutBlockWrapped_Done	; F57CF4  jr T,0xf57d1a
Ring_PutBlockWrapped_EndsAtTop:
	ldw	(xix-4), 0x0000	; F57CF6  ld (XIX+0xfc),0x0000
	lda	xix, (xix+de)	; F57CFB  lda XIX,XIX+DE
	ldir85	; F57D00  ldir
	jr	Ring_PutBlockWrapped_Done	; F57D02  jr T,0xf57d1a
Ring_PutBlockWrapped_TwoCopies:
	lda	xix, (xix+de)	; F57D04  lda XIX,XIX+DE
	ld	de, bc	; F57D09  ld DE,BC
	ld	bc, wa	; F57D0B  ld BC,WA
	sub	de, wa	; F57D0D  sub DE,WA
	ldir85	; F57D0F  ldir
	ld	bc, de	; F57D11  ld BC,DE
	ld	xix, xhl	; F57D13  ld XIX,XHL
	ld	(xix-4), de	; F57D15  ld (XIX+0xfc),DE
	ldir85	; F57D18  ldir
Ring_PutBlockWrapped_Done:
	popw	de	; F57D1A  pop DE
	pop	xix	; F57D1B  pop XIX
	pop	xhl	; F57D1C  pop XHL
	ret	; F57D1D  ret
; ==============================================================================
; 0xF57D1E-0xF57D4E -- INTT2's HANDLER, AND THE ROUTINE IT IS WEDGED INTO
; ==============================================================================
;
; This closes the last of the four CPU-1 interrupt vectors that
; notes/FINDINGS-interrupt-vectors.md listed as "in prom_b -- not this lane".
; ------------------------------------------------------------------------------

; ---------------------------------------------------------------------
; Clear_600780_98 -- zero 0x600780-0x6007E1 in two steps that abut exactly
;
; Called from: prom_b 0xF57C21, by `calr`.  Scanning both images at every byte
;          offset for the three call/jump shapes that can name this address --
;          `1D`/`1B` with a 24-bit operand and `1E` with a 16-bit displacement
;          that resolves here -- finds that one site and no other.
; Inputs:  none
; Outputs: 0x600780-0x6007E1 (98 bytes) set to zero.  XIY, XIX, XBC and WA are
;          clobbered.
; Evidence: the `ldir` copies NINE bytes from 0xF57D46, and the nine bytes at
;          0xF57D46 are all 0x00 -- so the copy is a memset with a ROM-resident
;          zero constant.  The store loop before it clears 0x59 = 89 bytes from
;          0x600780, and 0x600780 + 89 = 0x6007D9, exactly where the `ldir`
;          starts.  Two mechanisms, one contiguous 98-byte region.
; Unknown: what lives at 0x600780.  Nothing else converted in this tree names
;          that address.
; ---------------------------------------------------------------------
Clear_600780_98:
	lda	xiy, (Zero9:24)	; F57D1E  lda XIY,0xf57d46
	lda	xix, (Link_TxBurstsLeft:24)	; F57D23  lda XIX,0x6007d9
	ld	xbc, 9	; F57D28  ld XBC,0x00000009
	ldir85	; F57D2D  ldir
	ld	xbc, 89	; F57D2F  ld XBC,0x00000059
	lda	xix, (Link_RxCommand:24)	; F57D34  lda XIX,0x600780
	xor	wa, wa	; F57D39  xor WA,WA
Clear_600780_98_Loop:
	ld	(xix+), a	; F57D3B  ld (XIX+),A
	sub	bc, 1	; F57D3E  sub BC,0x0001
	jr	nz, Clear_600780_98_Loop	; F57D42  jr NZ,0xf57d3b
	ret	; F57D44  ret

; ---------------------------------------------------------------------
; INTT2_Reti -- 8-bit timer 2 interrupt: acknowledge and return, one byte
;
; Called from: vector slot 0x48.  prom_a file 0x7FF48 reads `E0 0E F4 00`, i.e.
;          0xFFFF48 holds 0x00F40EE0; prom_b file 0x40EE0 reads `1B 45 7D F5`,
;          i.e. thunk T_INTT2_Reti is `jp 0xF57D45`; and prom_b file 0x57D45 is the
;          single byte 0x07, RETI.  Every link re-read from the images here.
; Inputs:  none
; Outputs: none
; Evidence: one byte.  There is nothing else to say about the code -- what is
;          worth saying is where it SITS: between the `ret` that ends
;          Clear_600780_98 and the nine zero bytes that routine copies from.
;          The handler is a byte of slack in another routine's data, which is
;          why a linear read of this area does not look like a handler at all.
; Notes:   notes/FINDINGS-interrupt-vectors.md reads this as timer 2 existing
;          only to pace micro-DMA channel 2, which absorbs the interrupt.  This
;          conversion neither confirms nor refutes that; it establishes only
;          that the vector is a bare RETI.
; ---------------------------------------------------------------------
INTT2_Reti:
	reti	; F57D45  reti

; ---------------------------------------------------------------------
; Zero9 -- the nine-byte zero source the `ldir` above copies from
;
; Called from: nothing CALLS it; it is read as data by the `ldir` at 0xF57D2D.
; Inputs:  none        Outputs: none
; Evidence: 0xF57D1E `lda XIY,0xf57d46` / 0xF57D23 `lda XIX,0x6007d9` /
;          0xF57D28 `ld XBC,0x00000009` / 0xF57D2D `ldir`.  The count is the
;          LITERAL 9, so the extent is forced, not inferred from where the
;          zeros stop -- though they do stop there too: 0xF57D4F is 0x3F.
;          They are DATA, not the nine NOPs a linear disassembly shows.
; Why the name of the routine says 98: the loop right after this one
;          (0xF57D2F-0xF57D44) clears 0x59 = 89 bytes at 0x600780, and this
;          `ldir` writes 9 more at 0x600780 + 0x59 = 0x6007D9.  89 + 9 = 98,
;          and the two runs abut, so the pair clears 0x600780..0x6007E1.
; Unknown: what the 98-byte block at 0x600780 holds.  Nothing here says.
; ---------------------------------------------------------------------
Zero9:
	.fill	9, 1, 0x00	; F57D46-F57D4E  ldir source for Clear_600780_98


; ==============================================================================
; 0xF57D4F-0xF5A7FF -- THE DISK AND FILE MENU MODULE
; ==============================================================================
;
; 10,929 bytes: the link's selector-1 table, 657 bytes of 0x0E pad, the 7,259-byte
; module itself, and 2,981 bytes of 0x00 pad up to the SC1 module below.
;
; ★ WHY IT WAS STILL `.incbin` AFTER SIX ROUNDS OF DISPLAY-LIST WORK, AND WHAT
;   FOUND IT.  `scripts/analysis/prom_b_display_lists.py` finds a display list by
;   one instruction shape -- `ld XIY,<start> / ld XIX,<end> / call 0xF417F0`.
;   NOT ONE list in this module is entered that way; the count of register-form
;   sites into 0xF58000-0xF59C5A is ZERO.  Every entry here is a STACK VENEER:
;
;       pushw <flag>                        ; interpreter A only; -> (0x2540)
;       lda XBC,<end>   / push XBC
;       lda XWA,<start> / push XWA          ; last push = lowest slot = (XIZ+8)
;       call 0xFF75D3                       ; or `push <ret> / jp (XIX)`
;
;   and prom_a 0xFF75D3 reloads exactly those two slots into XIY and XIX, writes
;   the flag byte to (0x2540) -- the same variable the register form sets with
;   `ld (0x2540),0x00` -- and calls 0xF417F0.  Its sibling 0xFF75EF does the same
;   into 0xF417F4, interpreter B.  109 confirmed sites name 61 (start, end)
;   pairs, and ALL 61 FRAME: the record length bytes walk from start to end
;   exactly, no opcode above the owning interpreter's bound, and no record is
;   claimed by both interpreters.
;   Census, veneer decode and 21 checks: `python3 notes/prom_b_dl_stack_sites.py`.
;
; ★ IT ALSO ANSWERS `DisplayList_Run_Stack`'s OWN HEADER, which said "Called
;   from: through the thunk table; not yet traced to a specific caller".  It is
;   called 38 times from prom_a through `lda XIX,T_DisplayList_Run_Stack` + `jp (XIX)`, and
;   `DisplayListB_Run_Stack` 19 times the same way.
;
; WHAT IS IN IT -- and this is the answer gap V of
; kn7000_mame/notes/WSA1-EMULATION-DISASM-GAPS.md asked for:
;
;   0xF58000  the DISK menu itself: `DISK`, `DISK L0AD`, `DISK SAVE`,
;             `MIDI FILE`, `DIRECT PLAY`, `FL0PPY DISK`, `F0RMAT`
;   0xF580B0 / 0xF58127 / 0xF58162  the three display lists prom_a 0xFF42EE
;             chooses between on the model-variant strap (0x0000C4)
;   0xF585AD  the ten SAVE/LOAD CONTENT names: ALL, SEQUENCER, COMBINATION,
;             SOUND, PANEL, MIDI SETTING, SOUND RE-MAP, COMBI RE-MAP, DRUM MAP
;   0xF58625  ...and their FILE EXTENSIONS: .ALL .SEQ .CMB .SND .PNL .MDS .SRM
;             .CRM .DRM, appended at offset 6 of a six-character name by prom_a
;             0xFF76DA.  0xF59857 holds a tenth, `.MID`.
;   0xF587B2  the 37-character name-entry alphabet `_A-Z0-9`
;   0xF58947  the DISK SAVE PASSWORD screen
;   0xF58A41  MIDI FILE SAVE : FILE SELECTION
;   0xF59128  USER 1 / USER 2 / USER1 DRUM / USER2 DRUM
;   0xF595CD  100 numbered slot labels ` 01:` ... `100:`
;   0xF59904  COMPOSER LOAD
;
; ⚠ `L0AD`, `FL0PPY` and `F0RMAT` are not typos in this comment: those labels
;   spell capital O with character code 0x30, the digit zero.  The module uses
;   BOTH codes -- 67 occurrences of 0x30 and 71 of 0x4F inside its printable runs
;   -- and the SAME PHRASE appears both ways: `MIDI FILE SAVE : FILE SELECTION`
;   at 0xF58A66 and `MIDI FILE SAVE : FILE SELECTI0N` at 0xF59226.  It makes no
;   difference on screen, because Font_Svc06_8x14 cell 0x30 and cell 0x4F are the
;   SAME fourteen bytes.  Recorded because a reader who greps this file for
;   `LOAD`, `SOUND` or `SELECTION` will miss half of them.
;
; HOW THE NON-LIST BYTES ARE GRADED.  18 tables are emitted as N rows of W bytes.
; W always comes from the handler of the record that points at the table (8 for
; 0xF31B57, 6 for 0xF31B86, the +0x0B word for 0xF31B21/0xF31B39); N ALWAYS comes
; from the EXTENT and never from the record's AND mask.  ⚠ In this module the
; mask usually does NOT match: the record at 0xF58798 allows 64 entries and its
; table at 0xF5881F holds 37; 0xF5953B allows 16 and 0xF5975D holds 30; 0xF593F3
; allows 4 and 0xF59414 holds 7.  Measured over all eighteen, the mask disagrees
; TEN times, agrees six, and twice there is no naming record at all -- 0xF58625,
; proven by its prom_a reader, and 0xF595CD, whose hundredth row reads `100:`.
; 118 bytes in three objects are emitted as `.byte` with the structure NOT
; claimed, and each says so at its label.
;
; Regenerate and re-check: `python3 notes/gen_prom_b_f58000_module.py --selftest`
; (73 checks, including that the emitted directives reassemble to the ROM's own
; 10,929 bytes).  Findings: notes/FINDINGS-prom_b-disk-and-file-menus.md
; ==============================================================================

; --------------------------------------------------------------------------
; LinkSelector1_Table -- 0xF57D4F-0xF57D6E, 8 x 32-bit
;   eight 32-bit little-endian addresses. The interprocessor link's
;    selector-1 dispatch table: prom_a's INT0 path indexes it with the
;    command's top three bits (notes/FINDINGS-interprocessor-link.md
;    sec.1; re-derived by notes/prom_a_byte_checks.py).
; --------------------------------------------------------------------------
LinkSelector1_Table:
	.long	Ring60480A_PutBlock_Ldir	; [0] -> 0xF57C3F
	.long	Ring608A0A_PutBlock_Ldir	; [1] -> 0xF57C2D
	.long	LinkSelector1_NoAction	; [2] -> 0xF8E000
	.long	Ring601B64_PutBlock_Ldir	; [3] -> 0xF57C50
	.long	Ring60000C_PutBlock_Ldir	; [4] -> 0xF57C61
	.long	Ring601850_PutBlock_Drop1In3	; [5] -> 0xF57C97
	.long	Ring60195A_PutBlock_Ldir	; [6] -> 0xF57C72
	.long	LinkSelector1_NoAction	; [7] -> 0xF8E000

; --- 0xF57D6F-0xF57FFF: 657 bytes of 0x0E pad ---
	.fill	657, 1, 0x0E
