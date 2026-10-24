

; ==============================================================================
; 0xF5B800-0xF5B8B5 -- FOUR STACK-ARGUMENT VENEERS: ONE TEXT COPY, ONE QUEUE
;                      PUSH, AND THE TWO LINE-DRAW WRAPPERS
; ==============================================================================
;
; 182 bytes, four thunk entry points, sitting immediately below the selector
; dispatchers at 0xF5B8B6 and immediately above the SC1 module's 0x0E padding.
; Every one of the four takes its arguments off the CALLER'S STACK through the
; `push XIZ / ld XIZ,XSP` frame the rest of prom_b uses, so (XIZ+0x08) is the
; first 16-bit argument, (XIZ+0x0A) the second, and so on.
;
; The four, and their opcode-anchored reference upper bounds:
;   0xF5B800  T_UiText_CopyLabel13_To_22F0  x8   copy a 13-byte label into the RAM text buffer
;   0xF5B81C  T_List2030_PostSoundSelection  x1   push two records onto the list at 0x2030
;   0xF5B84C  T_Gfx_DrawLine_Solid  x23  SWI7 service 0x00 -- draw a solid line
;   0xF5B881  T_Gfx_DrawLine_Dashed  x9   SWI7 service 0x15 -- draw a dashed line
; ⚠ Those counts are BYTE-SCAN UPPER BOUNDS on `1D`/`1B` + slot address across
; prom_a+prom_b, not instruction-anchored call counts.  They rank; they do not
; prove.  That is the same caveat notes/prom_b_call_graph.py states.  What IS
; exact: the four counts total 41, of which 39 are in prom_a and 2 in prom_b
; (both prom_b ones are on T_UiText_CopyLabel13_To_22F0), and the two line wrappers account for 32
; of the 41 on their own.  Emitted by `python3 notes/prom_b_f5b800_checks.py`.
;
; ★ THIS BLOCK ANSWERS AN OPEN QUESTION RECORDED IN prom_a.
; prom_a/wsa1_prom_a.s's header on SWI7 service 0x00 says, verbatim:
;     "⚠ NOT ESTABLISHED: who calls service 0x00 and how it sets
;      (0x2530)-(0x2536)"
; 0xF5B84C is the answer to both halves: it is a C-callable veneer that copies
; four 16-bit stack arguments into (0x2530), (0x2532), (0x2534) and (0x2536) --
; in that order, so X0, Y0, X1, Y1 as prom_a's own analysis assigns them --
; forces the layer byte (0x2540) to 0, and issues the service.  0xF5B881 is the
; same veneer for the dashed variant.  (prom_a is another lane's file and is not
; edited from here; its header still carries the question.)
; ==============================================================================

; ---------------------------------------------------------------------
; UiText_CopyLabel13_To_22F0 -- copy one 13-byte label into the RAM text buffer
;
; Called from: thunk slot T_UiText_CopyLabel13_To_22F0; 8 opcode-anchored references, 6 in prom_a
;          and 2 in prom_b.  UPPER BOUND, not a call count.
; Inputs:  A = label index.  Only bits 0-5 are used.
; Outputs: 13 bytes at 0x000022F0 overwritten; XIY, XIX, BC clobbered.
; Evidence: `extz XWA / extz WA / and A,0x3F / mul A,0x0D /
;          ld XIY,0x00F33022 / add XIY,XWA / ld XIX,0x000022F0 /
;          ld BC,0x000D / ldir`.  The stride and the copy length are the SAME
;          literal 13, and the base is the 32-bit literal 0xF33022.
;
; ★ THE `and A,0x3F` IS AN INDEPENDENT BOUND ON A TABLE THIS TREE HAD ONLY
;   BOUNDED BY ABUTMENT.  notes/FINDINGS-prom_b-ui-variable-index.md records
;   0xF33022 as a 13-byte-wide table of 64 entries, with the count established
;   by "0xF33022 + 64*13 = 0xF33362, where a well-formed interpreter-A record
;   starts".  That is abutment.  This routine masks the index to 0..0x3F before
;   multiplying, so the CODE cannot address a 65th entry -- a second,
;   independent reason for 64, from a different image region.  The two agree.
;   Checked here: 0xF33022 + 64*13 = 0xF33362 exactly; entry 0 is
;   '-------------', entry 49 is 'REV DYNAMIC  ' and entry 63 -- the LAST -- is
;   the right-aligned '           63', all three re-read from the ROM.
;
; ★ AND THE DESTINATION IS ONE OF THE 13 RAM TABLES THE VARIABLE INDEX FOUND.
;   0x0022F0 appears in `python3 notes/prom_b_var_screens.py --tables` at three
;   entry widths, and one of them is w13 -- the same 13.  So this is the writer
;   of a buffer that display-list interpreter B reads back at that width.
;   Which record reads it is NOT traced here.
; Unknown: who chooses the index, and whether the two other widths at 0x22F0
;          (w2 and w16) mean the buffer is shared or the index is coarse.
; ---------------------------------------------------------------------
UiText_CopyLabel13_To_22F0:		; <- T_UiText_CopyLabel13_To_22F0
	extz	xwa	; F5B800  extz XWA
	extz	wa	; F5B802  extz WA
	and	a, 63	; F5B804  and A,0x3f
	mul	a, 13	; F5B807  mul A,0x0d
	ld	xiy, ControllerDestinationNames	; F5B80A  ld XIY,0x00f33022
	add	xiy, xwa	; F5B80F  add XIY,XWA
	ld	xix, DiskSave_PasswordEntry	; F5B811  ld XIX,0x000022f0
	ldw	bc, 13	; F5B816  ld BC,0x000d
	ldir85	; F5B819  ldir
	ret	; F5B81B  ret
; ---------------------------------------------------------------------
; List2030_PostSoundSelection -- push TWO records onto the list at 0x2030, via thunk T_List2030_AppendRegs
;
; NAMED sub_XXXXXX ON PURPOSE.  What the records MEAN is not established, and
; the tree's rule is that a stated gap beats a plausible guess.  The mechanism
; below is measured; the meaning is not.
;
; Called from: thunk slot T_List2030_PostSoundSelection; ONE opcode-anchored reference, in prom_a.
; Inputs:  three 16-bit stack arguments -- (XIZ+0x08), (XIZ+0x0A), (XIZ+0x0C).
; Outputs: two calls to T_List2030_AppendRegs, each with XDE = 0 and a packed XWA:
;            call 1:  W = 0x3F              A = low byte of (XIZ+0x08)
;            call 2:  W = L of (XIZ+0x0C)   A = low byte of (XIZ+0x0A)
;          All registers restored.
; Evidence: `ld E,0 / ld D,0` before each call is the DE=0; `ld WA,(XIZ+0x08) /
;          ld W,0x3F` loads the 16-bit argument and then OVERWRITES its high
;          half, which is what makes W a separate field rather than the
;          argument's top byte; the second call does the same with
;          `ld HL,(XIZ+0x0C) / ld W,L`.  The `push XIZ / call / pop XIZ` around
;          the first call and not the second says the callee clobbers XIZ.
; What T_List2030_AppendRegs is: it jumps to prom_a 0xF86AC7, which is in prom_a's
;          `.incbin` -- UNCONVERTED, another lane's territory.  Disassembled
;          from the thunk target (so the instruction boundary is certain, not
;          guessed), it walks 0x2030 in steps of 4 looking for a 0xFF marker,
;          refuses the write when the pointer passes 0x206B, and otherwise
;          stores `ld (XHL),DE`, `ld (XHL+0x02),WA`, `ld (XHL+0x04),0xFF`.
;          So: a 4-byte record {DE, WA}, appended to a 0xFF-terminated list of
;          at most fifteen slots, 0x2030-0x206B.
; ⚠ That last paragraph is read out of ANOTHER IMAGE'S UNCONVERTED BYTES.  It
;          is evidence for the shape of the call, not a conversion of 0xF86AC7,
;          and it must be re-checked when prom_a's lane reaches that address.
; Unknown: everything about meaning -- what the list at 0x2030 is consumed by,
;          why 0x3F is a constant field in the first record, and why the only
;          caller is a single site in prom_a.
; ---------------------------------------------------------------------
; List2030_PostSoundSelection: From three word arguments (bank, group, member) appends {0, 0, bank, 0x3F} and {0, 0,
;   group, member} to the 0x2030 event list (T_List2030_AppendRegs) -- the bank / group-member record pair
;   GroupSoundDisplayHold_PickSound posts with the part as class. SoundEditMemoryWrite_PostWrittenSoundSel posts the
;   sound just written through slot T_List2030_PostSoundSelection. Basis: caller + body + twin poster. (notes/naming-
;   pilot-2026-10-06/proposals_wave10_b10.json)
List2030_PostSoundSelection:		; <- T_List2030_PostSoundSelection
	push	xiz	; F5B81C  push XIZ
	ld	xiz, xsp	; F5B81D  ld XIZ,XSP
	push	xwa	; F5B81F  push XWA
	push	xbc	; F5B820  push XBC
	push	xde	; F5B821  push XDE
	push	xhl	; F5B822  push XHL
	push	xix	; F5B823  push XIX
	push	xiy	; F5B824  push XIY
	ld	e, 0:opc	; F5B825  ld E,0x00
	ld	d, 0:opc	; F5B827  ld D,0x00
	ld	wa, (xiz+8)	; F5B829  ld WA,(XIZ+0x08)
	ld	w, 63:opc	; F5B82C  ld W,0x3f
	push	xiz	; F5B82E  push XIZ
	call	T_List2030_AppendRegs	; F5B82F  call 0xf40f40
	pop	xiz	; F5B833  pop XIZ
	ld	e, 0:opc	; F5B834  ld E,0x00
	ld	d, 0:opc	; F5B836  ld D,0x00
	ld	wa, (xiz+10)	; F5B838  ld WA,(XIZ+0x0a)
	ld	hl, (xiz+12)	; F5B83B  ld HL,(XIZ+0x0c)
	ld	w, l	; F5B83E  ld W,L
	call	T_List2030_AppendRegs	; F5B840  call 0xf40f40
	pop	xiy	; F5B844  pop XIY
	pop	xix	; F5B845  pop XIX
	pop	xhl	; F5B846  pop XHL
	pop	xde	; F5B847  pop XDE
	pop	xbc	; F5B848  pop XBC
	pop	xwa	; F5B849  pop XWA
	pop	xiz	; F5B84A  pop XIZ
	ret	; F5B84B  ret
; ---------------------------------------------------------------------
; Gfx_DrawLine_Solid -- SWI7 service 0x00 with its four coordinates
;
; Called from: thunk slot T_Gfx_DrawLine_Solid; 23 opcode-anchored references, ALL of them
;          in prom_a, none in prom_b.  Upper bound, not a call count -- but it
;          is the largest count of the four routines in this block.
; Inputs:  four 16-bit stack arguments: (XIZ+0x08), (XIZ+0x0A), (XIZ+0x0C),
;          (XIZ+0x0E).
; Outputs: (0x2530) (0x2532) (0x2534) (0x2536) = those four, in order;
;          (0x2540) = 0 as a BYTE; then `ld A,0x00 / swi 7`.  All registers
;          restored.
; Evidence: the four `ld WA,(XIZ+n) / ld (0x25xx),WA` pairs, then the 5-byte
;          `ld (0x2540),0x00` (opcode 0x00, an 8-bit immediate store -- NOT a
;          16-bit one, despite the two 0x00 bytes in `F1 40 25 00 00`), then
;          A = 0 and the trap.
; What service 0x00 is: prom_a's SWI7_ServiceTable slot 0x00 holds 0x00F8EAC7,
;          which prom_a converts and documents as the LINE DRAW, and prom_a's
;          own header assigns (0x2530)/(0x2534) as X and (0x2532)/(0x2536) as Y
;          from the dx/dy subtraction inside the service.  So the argument order
;          here is X0, Y0, X1, Y1.  Reproduce the slot lookup with
;          `python3 notes/swi7_service_table.py`.
; ★ This closes prom_a's "NOT ESTABLISHED: who calls service 0x00 and how it
;          sets (0x2530)-(0x2536)".  See the block banner above.
; Unknown: what (0x2540) selects.  prom_a's header reads it as the layer; this
;          veneer only ever writes 0, so nothing HERE distinguishes "layer 0"
;          from "the field this caller does not use".
; ---------------------------------------------------------------------
Gfx_DrawLine_Solid:		; <- T_Gfx_DrawLine_Solid
	push	xiz	; F5B84C  push XIZ
	ld	xiz, xsp	; F5B84D  ld XIZ,XSP
	push	xwa	; F5B84F  push XWA
	push	xbc	; F5B850  push XBC
	push	xde	; F5B851  push XDE
	push	xhl	; F5B852  push XHL
	push	xix	; F5B853  push XIX
	push	xiy	; F5B854  push XIY
	ld	wa, (xiz+8)	; F5B855  ld WA,(XIZ+0x08)
	ld	(LCD_X0:16), wa	; F5B858  ld (0x2530),WA
	ld	wa, (xiz+10)	; F5B85C  ld WA,(XIZ+0x0a)
	ld	(LCD_Y0:16), wa	; F5B85F  ld (0x2532),WA
	ld	wa, (xiz+12)	; F5B863  ld WA,(XIZ+0x0c)
	ld	(LCD_X1:16), wa	; F5B866  ld (0x2534),WA
	ld	wa, (xiz+14)	; F5B86A  ld WA,(XIZ+0x0e)
	ld	(LCD_Y1:16), wa	; F5B86D  ld (0x2536),WA
	ld	(LCD_CurrentLayer:16), 0	; F5B871  ld (0x2540),0x00
	ld	a, 0:opc	; F5B876  ld A,0x00
	swi	7	; F5B878  swi 7
	pop	xiy	; F5B879  pop XIY
	pop	xix	; F5B87A  pop XIX
	pop	xhl	; F5B87B  pop XHL
	pop	xde	; F5B87C  pop XDE
	pop	xbc	; F5B87D  pop XBC
	pop	xwa	; F5B87E  pop XWA
	pop	xiz	; F5B87F  pop XIZ
	ret	; F5B880  ret
; ---------------------------------------------------------------------
; Gfx_DrawLine_Dashed -- the same veneer, for SWI7 service 0x15
;
; Called from: thunk slot T_Gfx_DrawLine_Dashed; 9 opcode-anchored references, all in prom_a.
; Inputs / Outputs: identical to Gfx_DrawLine_Solid above.
; Evidence, and it is a BYTE DIFF rather than a reading: 0xF5B84C and 0xF5B881
;          are 53 bytes each and differ in EXACTLY ONE byte -- offset 43, the
;          service number, 0x00 against 0x15.  52 of 53 identical.  So this is
;          not "similar to" the solid veneer, it IS the solid veneer with a
;          different service number, and every claim made about the argument
;          layout there carries over unchanged.
; What service 0x15 is: prom_a's SWI7_ServiceTable slot 0x15 holds 0x00F900B0,
;          which prom_a converts as `LCD_Svc_15_DrawLineDashed` -- "the line
;          draw, two pixels on, two off".  That is where the name comes from;
;          nothing in prom_b says "dashed".
; Unknown: the same (0x2540) question as above.
; ---------------------------------------------------------------------
Gfx_DrawLine_Dashed:		; <- T_Gfx_DrawLine_Dashed
	push	xiz	; F5B881  push XIZ
	ld	xiz, xsp	; F5B882  ld XIZ,XSP
	push	xwa	; F5B884  push XWA
	push	xbc	; F5B885  push XBC
	push	xde	; F5B886  push XDE
	push	xhl	; F5B887  push XHL
	push	xix	; F5B888  push XIX
	push	xiy	; F5B889  push XIY
	ld	wa, (xiz+8)	; F5B88A  ld WA,(XIZ+0x08)
	ld	(LCD_X0:16), wa	; F5B88D  ld (0x2530),WA
	ld	wa, (xiz+10)	; F5B891  ld WA,(XIZ+0x0a)
	ld	(LCD_Y0:16), wa	; F5B894  ld (0x2532),WA
	ld	wa, (xiz+12)	; F5B898  ld WA,(XIZ+0x0c)
	ld	(LCD_X1:16), wa	; F5B89B  ld (0x2534),WA
	ld	wa, (xiz+14)	; F5B89F  ld WA,(XIZ+0x0e)
	ld	(LCD_Y1:16), wa	; F5B8A2  ld (0x2536),WA
	ld	(LCD_CurrentLayer:16), 0	; F5B8A6  ld (0x2540),0x00
	ld	a, 21:opc	; F5B8AB  ld A,0x15
	swi	7	; F5B8AD  swi 7
	pop	xiy	; F5B8AE  pop XIY
	pop	xix	; F5B8AF  pop XIX
	pop	xhl	; F5B8B0  pop XHL
	pop	xde	; F5B8B1  pop XDE
	pop	xbc	; F5B8B2  pop XBC
	pop	xwa	; F5B8B3  pop XWA
	pop	xiz	; F5B8B4  pop XIZ
	ret	; F5B8B5  ret


; ==============================================================================
; 0xF5B8B6-0xF5BAB7 -- TWO SELECTOR DISPATCHERS AND THEIR 48-ENTRY TABLES
; ==============================================================================
;
; Both are reached through the thunk table and are among the busiest slots in it:
; T_Dispatch_Code80_Bracketed -> 0xF5B8B6 (opcode-anchored upper bound 39 references) and
; T_Dispatch_Code80 -> 0xF5B9B8 (109), ranked by
; `python3 scripts/analysis/prom_b_thunk_table.py --census`.
;
; Both take a 16-bit selector on the stack and index a table of 32-bit routine
; pointers with it:
;
;     code = (XIZ+8)
;     if code >= 0xC0:  entry = table_hi[code - 0xC0]
;     else:             entry = table_lo[code - 0x80]
;     call entry
;
; and `table_hi` is `table_lo + 0x80`, so codes 0xC0.. land on the SAME entries as
; codes 0xA0.., 16 of them, before running off the end of the table.
;
; TABLE SIZE IS PROVEN BY ABUTMENT, not by the 0xC0 bound:
;   0xF5B8F8 + 48*4 = 0xF5B9B8, exactly the `push XIZ` that starts the second
;                     dispatcher;
;   0xF5B9F8 + 48*4 = 0xF5BAB8, exactly a `push XWA/XBC/XDE/XHL/XIX/XIY/XIZ`
;                     register-save prologue.
;   All 96 entries are 0x00F00000-0x00FFFFFF; the first word past each table is
;   not (0x3B3A3938 and 0x5B5C5D5E -- both are push/pop opcode runs).
; Reproduce every line of that with
;     python3 notes/prom_b_dispatch_tables.py
;
; 0xF5BF17 is a bare `ret` (byte 0x0E): it is the DEFAULT entry, and it fills 6
; slots of the first table and 7 of the second.  41 of the first table's 48
; entries and 35 of the second's are distinct.
;
; ⚠ WHAT THE SELECTOR MEANS IS NOT ESTABLISHED.  It is a 16-bit value >= 0x80
; passed by the caller; nothing here says whether it is a screen id, a panel
; event or a message opcode.  The name below describes the mechanism only.
; ==============================================================================

; ---------------------------------------------------------------------
; Dispatch_Code80_Bracketed -- run selector table entry, bracketed by two
;                              display service calls
; Called from: thunk T_Dispatch_Code80_Bracketed (0xF41ED0), 39 opcode-anchored references
; Inputs:  (XIZ+8) = 16-bit selector, >= 0x80
; Outputs: whatever the selected routine does; all registers restored
; Evidence: the `sub HL,0xC0 / ld XIY,0x00F5B978` and `sub HL,0x80 /
;           ld XIY,0x00F5B8F8` pair, then `sla 2,HL`, `ld XIY,(XIY+HL)`,
;           `call XIY`.  The bracket is `call 0xF5BF18` before and
;           `call 0xF5BF21` after; 0xF5BF18 is `ld C,0 / ld A,0x0C / swi 7 /
;           ld A,0x10 / swi 7` and 0xF5BF21 is `ld C,7 / ld A,0x0C / swi 7` --
;           the same services 0x0C (argument in C, 0 or 7 seen) and 0x10 that
;           LCD_BlankThenSetPanel3Layer_Copy and LCD_ShowAllLayers_StackFrame_Copy in the interpreter block issue.
; Unknown:  what the selector enumerates; what services 0x0C and 0x10 do.
; ---------------------------------------------------------------------
Dispatch_Code80_Bracketed:
	push	xiz	; F5B8B6  push XIZ
	ld	xiz, xsp	; F5B8B7  ld XIZ,XSP
	push	xwa	; F5B8B9  push XWA
	push	xbc	; F5B8BA  push XBC
	push	xde	; F5B8BB  push XDE
	push	xhl	; F5B8BC  push XHL
	push	xix	; F5B8BD  push XIX
	push	xiy	; F5B8BE  push XIY
	ld	hl, (xiz+8)	; F5B8BF  ld HL,(XIZ+0x08)
	cp	hl, 192	; F5B8C2  cp HL,0x00c0
	jr	c, SC1_Entry_F40F24_Body_Ret_Skip	; F5B8C6  jr C,0xf5b8d3
	sub	hl, 192	; F5B8C8  sub HL,0x00c0
	ld	xiy, Dispatch_Code80_PaintTable + 0x80	; F5B8CC  ld XIY,0x00f5b978
	jr	SC1_Entry_F40F24_Body_Ret_Join	; F5B8D1  jr T,0xf5b8dc
SC1_Entry_F40F24_Body_Ret_Skip:
	sub	hl, 128	; F5B8D3  sub HL,0x0080
	ld	xiy, Dispatch_Code80_PaintTable	; F5B8D7  ld XIY,0x00f5b8f8
SC1_Entry_F40F24_Body_Ret_Join:
	sla	hl, 2	; F5B8DC  sla 0x02,HL
	ld	xiy, (xiy+hl)	; F5B8DF  ld XIY,(XIY+HL)
	push	xiy	; F5B8E4  push XIY
	call	LCD_BlankThenSetPanel3Layer_Copy2	; F5B8E5  call 0xf5bf18
	pop	xiy	; F5B8E9  pop XIY
	call	(xiy)	; F5B8EA  call T,XIY
	call	LCD_ShowAllLayers_Copy2	; F5B8EC  call 0xf5bf21
	pop	xiy	; F5B8F0  pop XIY
	pop	xix	; F5B8F1  pop XIX
	pop	xhl	; F5B8F2  pop XHL
	pop	xde	; F5B8F3  pop XDE
	pop	xbc	; F5B8F4  pop XBC
	pop	xwa	; F5B8F5  pop XWA
	pop	xiz	; F5B8F6  pop XIZ
	ret	; F5B8F7  ret

; --- 0xF5B8F8: 48 entries, one per selector 0x80..0xAF.  Ends exactly on the
;     next routine's first byte.  Entries for 0xC0.. re-use 0xA0.. ------------
; Dispatch_Code80_PaintTable: Dispatch_Code80_Bracketed's table: the FULL paint of each screen code 0x80..0xAF (codes
;   0xC0.. read entry code - 0x40), run between LCD blank and show. Basis: table index (screen code) + its named
;   entries (notes/prom_b_repaint_table_names.py). (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
Dispatch_Code80_PaintTable:
	.long SoundEditMenu_Paint	; [0x80]
	.long TouchCurve_DrawThumbnail + 0xBD	; [0x81]   (default `ret`)
	.long Draw_ToneTemplateLevelKeyTune	; [0x82]
	.long SoundEditToneLayerPanning_Paint	; [0x83]
	.long SoundEditToneLayerKeyLayer_Paint	; [0x84]
	.long SoundEditToneLayerVelocityLayer_Paint	; [0x85]
	.long Draw_DriverDriverWaveformReso	; [0x86]
	.long Draw_KeyDeToneKeyScalingShift	; [0x87]
	.long Draw_StartPitchStopPitchTotal	; [0x88]
	.long SoundEditPitchEnvelope2_Paint	; [0x89]
	.long SoundEditPitchLfo_Paint	; [0x8A]
	.long Draw_Page12LevelTouchCurveLevel	; [0x8B]
	.long Draw_Page22KeyFollowSlopeRange	; [0x8C]
	.long SoundEditAmpEnvelope1_Paint	; [0x8D]
	.long Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk	; [0x8E]
	.long SoundEditAmpLfo_Paint	; [0x8F]
	.long SoundEditFilterLpf12_Paint	; [0x90]
	.long SoundEditFilterHpf12_Paint	; [0x91]
	.long SoundEditFilterLpf24_Paint	; [0x92]
	.long SoundEditFilterHpf24_Paint	; [0x93]
	.long Draw_FilterBandPassLowHighCutoff	; [0x94]
	.long Draw_Through	; [0x95]
	.long SoundEditFilterKeyFollow_Paint	; [0x96]
	.long Draw_StartPointStopPointCutoff	; [0x97]
	.long SoundEditFilterEnvelope2_Paint	; [0x98]
	.long SoundEditFilterLfo_Paint	; [0x99]
	.long SoundEditDigitalEffect_Paint	; [0x9A]
	.long SoundEditController_PaintPage2	; [0x9B]
	.long TouchCurve_DrawThumbnail + 0xBD	; [0x9C]   (default `ret`)
	.long SoundEditCopy_Paint	; [0x9D]
	.long Draw_Mem0ryWriteSoundEditName	; [0x9E]
	.long Draw_Write	; [0x9F]
	.long ToneEditPage_A0_Paint	; [0xA0]  <- also selector 0xC0
	.long Draw_ToneTemplateLevelKeyTune	; [0xA1]  <- also selector 0xC1
	.long Draw_DriverDriverWaveformReso	; [0xA2]  <- also selector 0xC2
	.long ToneEditPage_A3_Paint	; [0xA3]  <- also selector 0xC3
	.long ToneEditPage_A4_Paint	; [0xA4]  <- also selector 0xC4
	.long ToneEditPage_A5_Paint	; [0xA5]  <- also selector 0xC5
	.long ToneEditPage_A6_Paint	; [0xA6]  <- also selector 0xC6
	.long ToneEditPage_A7_Paint	; [0xA7]  <- also selector 0xC7
	.long Draw_Serial	; [0xA8]  <- also selector 0xC8
	.long TouchCurve_DrawThumbnail + 0xBD	; [0xA9]   (default `ret`)  <- also selector 0xC9
	.long Dispatch_Code80_PaintNoAction	; [0xAA]  <- also selector 0xCA
	.long SoundEditDrumMenu_Paint	; [0xAB]  <- also selector 0xCB
	.long TouchCurve_DrawThumbnail + 0xBD	; [0xAC]   (default `ret`)  <- also selector 0xCC
	.long SoundEditController_PaintPage1	; [0xAD]  <- also selector 0xCD
	.long TouchCurve_DrawThumbnail + 0xBD	; [0xAE]   (default `ret`)  <- also selector 0xCE
	.long TouchCurve_DrawThumbnail + 0xBD	; [0xAF]   (default `ret`)  <- also selector 0xCF

; ---------------------------------------------------------------------
; Dispatch_Code80 -- the same selector table mechanism, no display bracket
; Called from: thunk T_Dispatch_Code80 (0xF41ED4), 109 opcode-anchored references -- the
;              busiest prom_b-resident slot in the thunk table after the two
;              display-list interpreters
; Inputs:  (XIZ+8) = 16-bit selector >= 0x80; (XIZ+0x0A) = a byte loaded into A
;          and left there for the selected routine
; Outputs: sets bit 3 of (0x2075) after the call; all registers restored
; Evidence: identical index arithmetic against 0xF5B9F8 / 0xF5BA78; the extra
;           `ld A,(XIZ+0x0A)` at 0xF5B9C4 is the only argument difference, and
;           `or (0x2075),0x08` at 0xF5B9EB is the only side effect.
; Unknown:  what the selector enumerates; what bit 3 of 0x2075 means.
; ---------------------------------------------------------------------
Dispatch_Code80:
	push	xiz	; F5B9B8  push XIZ
	ld	xiz, xsp	; F5B9B9  ld XIZ,XSP
	push	xwa	; F5B9BB  push XWA
	push	xbc	; F5B9BC  push XBC
	push	xde	; F5B9BD  push XDE
	push	xhl	; F5B9BE  push XHL
	push	xix	; F5B9BF  push XIX
	push	xiy	; F5B9C0  push XIY
	ld	hl, (xiz+8)	; F5B9C1  ld HL,(XIZ+0x08)
	ld	a, (xiz+10)	; F5B9C4  ld A,(XIZ+0x0a)
	cp	hl, 192	; F5B9C7  cp HL,0x00c0
	jr	c, Dispatch_Code80_Skip	; F5B9CB  jr C,0xf5b9d8
	sub	hl, 192	; F5B9CD  sub HL,0x00c0
	ld	xiy, Dispatch_Code80_RepaintFieldTable + 0x80	; F5B9D1  ld XIY,0x00f5ba78
	jr	Dispatch_Code80_Join	; F5B9D6  jr T,0xf5b9e1
Dispatch_Code80_Skip:
	sub	hl, 128	; F5B9D8  sub HL,0x0080
	ld	xiy, Dispatch_Code80_RepaintFieldTable	; F5B9DC  ld XIY,0x00f5b9f8
Dispatch_Code80_Join:
	sla	hl, 2	; F5B9E1  sla 0x02,HL
	ld	xiy, (xiy+hl)	; F5B9E4  ld XIY,(XIY+HL)
	call	(xiy)	; F5B9E9  call T,XIY
	or	(UI_RequestBits:16), 0x08	; F5B9EB  or (0x2075),0x08
	pop	xiy	; F5B9F0  pop XIY
	pop	xix	; F5B9F1  pop XIX
	pop	xhl	; F5B9F2  pop XHL
	pop	xde	; F5B9F3  pop XDE
	pop	xbc	; F5B9F4  pop XBC
	pop	xwa	; F5B9F5  pop XWA
	pop	xiz	; F5B9F6  pop XIZ
	ret	; F5B9F7  ret

; --- 0xF5B9F8: 48 entries, one per selector 0x80..0xAF ---------------------
; Dispatch_Code80_RepaintFieldTable: Dispatch_Code80's table: the PARTIAL (field) repaint of each screen code
;   0x80..0xAF (0xC0.. read entry code - 0x40). Basis: table index (screen code) + its named entries
;   (notes/prom_b_repaint_table_names.py). (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
Dispatch_Code80_RepaintFieldTable:
	.long SoundEditMenu_RepaintField	; [0x80]
	.long TouchCurve_DrawThumbnail + 0xBD	; [0x81]   (default `ret`)
	.long SoundEditModelingToneTemplate_RepaintField	; [0x82]
	.long SoundEditToneLayerPanning_RepaintField	; [0x83]
	.long SoundEditToneLayerKeyLayer_RepaintField	; [0x84]
	.long SoundEditToneLayerVelocityLayer_RepaintField	; [0x85]
	.long SoundEditModelingDriverWaveform_RepaintField	; [0x86]
	.long SoundEditPitchTune_RepaintField	; [0x87]
	.long SoundEditEnvelope1_RepaintField	; [0x88]
	.long SoundEditEnvelope2_RepaintField	; [0x89]
	.long SoundEditLfo_RepaintField	; [0x8A]
	.long SoundEditAmpLevel1_RepaintField	; [0x8B]
	.long SoundEditKeyFollow_RepaintField	; [0x8C]
	.long SoundEditAmpEnvelope1_RepaintField	; [0x8D]
	.long SoundEditAmpEnvelope2_RepaintField	; [0x8E]
	.long SoundEditLfo_RepaintField	; [0x8F]
	.long Draw_LowHigh	; [0x90]
	.long Draw_LowHigh_2	; [0x91]
	.long SoundEditFilterLpf24_RepaintField	; [0x92]
	.long SoundEditFilterHpf24_RepaintField	; [0x93]
	.long SoundEditFilterBpf_RepaintField	; [0x94]
	.long TouchCurve_DrawThumbnail + 0xBD	; [0x95]   (default `ret`)
	.long SoundEditKeyFollow_RepaintField	; [0x96]
	.long SoundEditEnvelope1_RepaintField	; [0x97]
	.long SoundEditEnvelope2_RepaintField	; [0x98]
	.long SoundEditLfo_RepaintField	; [0x99]
	.long SoundEditDigitalEffect_RepaintField	; [0x9A]
	.long SoundEditController_RepaintFieldPage2	; [0x9B]
	.long TouchCurve_DrawThumbnail + 0xBD	; [0x9C]   (default `ret`)
	.long SoundEditCopy_RepaintField	; [0x9D]
	.long SoundEditMemoryWrite_RepaintField	; [0x9E]
	.long SoundEditNaming_RepaintField	; [0x9F]
	.long ToneEditPage_A0_RepaintField	; [0xA0]  <- also selector 0xC0
	.long SoundEditModelingToneTemplate_RepaintField	; [0xA1]  <- also selector 0xC1
	.long SoundEditModelingDriverWaveform_RepaintField	; [0xA2]  <- also selector 0xC2
	.long ToneEditPage_A3_RepaintField	; [0xA3]  <- also selector 0xC3
	.long ToneEditPage_A4_RepaintField	; [0xA4]  <- also selector 0xC4
	.long ToneEditPage_A5_RepaintField	; [0xA5]  <- also selector 0xC5
	.long ToneEditPage_A6_RepaintField	; [0xA6]  <- also selector 0xC6
	.long ToneEditPage_A7_RepaintField	; [0xA7]  <- also selector 0xC7
	.long ToneEditPage_A8_RepaintField	; [0xA8]  <- also selector 0xC8
	.long TouchCurve_DrawThumbnail + 0xBD	; [0xA9]   (default `ret`)  <- also selector 0xC9
	.long Dispatch_Code80_RepaintFieldNoAction	; [0xAA]  <- also selector 0xCA
	.long SoundEditDrumMenu_RepaintField	; [0xAB]  <- also selector 0xCB
	.long TouchCurve_DrawThumbnail + 0xBD	; [0xAC]   (default `ret`)  <- also selector 0xCC
	.long SoundEditController_RepaintFieldPage1	; [0xAD]  <- also selector 0xCD
	.long TouchCurve_DrawThumbnail + 0xBD	; [0xAE]   (default `ret`)  <- also selector 0xCE
	.long TouchCurve_DrawThumbnail + 0xBD	; [0xAF]   (default `ret`)  <- also selector 0xCF

; --- 0xF5BAB8-0xF62BFF: not converted ---

; ==============================================================================
; 0xF5BAB8-0xF5BBE6 -- TWO SCREEN PAINTERS AND A THIRD SWI7 VENEER
; ==============================================================================
;
; 303 bytes, three thunk entry points, continuing straight on from the selector
; dispatchers above.  The first two are UI painters: they set the layer byte
; (0x2540) and hand (start, end) pairs to DisplayList_Run through thunk
; T_DisplayList_Run, which carries the HIGHEST reference count of any annotated slot in
; the table -- 392, rank 1 of the 818 slots that carry a count -- and is
; labelled `THE UI ENGINE` where it is defined.  (Ranked by re-reading the
; counts already written into this file's own thunk-table listing.  ⚠ Watch the
; regex when you redo it: `0x31A09` on that same line contains a literal `x31`,
; so a naive `x(\d+)` scan reads THAT as the count and produces a completely
; different -- and wrong -- ranking.  It is the LAST `x<digits>` token on the
; line.  I made exactly that mistake once while checking this sentence.)
; The third is the
; same 53-byte SWI7 veneer already converted twice at 0xF5B84C and 0xF5B881.
;
; Reference upper bounds (byte scan of `1D`/`1B` + slot, so a RANK not a count):
;   0xF5BAB8  T_UiPaint_Solo  x1   prom_a
;   0xF5BB00  T_UiPaint_Ordinals  x0   -- NO reference in either image; see its header
;   0xF5BBB2  T_Gfx_EraseRect  x7   prom_a
;
; ★ (0x2540) IS A LAYER SELECTOR, AND THIS BLOCK IS WHERE THAT BECOMES VISIBLE
; IN prom_b.  The three veneers converted above only ever write 0 to it, so
; nothing there could distinguish "the layer field" from "a field this caller
; does not use" -- their headers say exactly that.  The painters here write
; BOTH 0 and 1 (`ld (0x2540),0x00` at 0xF5BABF, 0xF5BB0E, 0xF5BB25 and
; `ld (0x2540),0x01` at 0xF5BAE5, 0xF5BB8E), and they switch value between two
; display lists that draw at the SAME coordinates.  That is a second, prom_b
; -side reason for prom_a's reading of (0x2540) as the layer, arrived at
; independently of prom_a's own.
; ⚠ Still not established: how many layers there are, or which one is on top.
; Only the values 0 and 1 are ever written anywhere in this block.
; ==============================================================================

; ---------------------------------------------------------------------
; UiPaint_Solo -- paint the "SOLO" panel, then one of two state overlays
;
; Called from: thunk slot T_UiPaint_Solo; ONE opcode-anchored reference, in prom_a.
; Inputs:  (0x27A2), a byte, tested against 0.  No register arguments -- this
;          routine takes none off the stack (it never builds an XIZ frame).
; Outputs: two display lists painted; (0x2540) left at 0 or 1; all seven
;          register pairs restored.
; What it does, in order:
;   1. (0x2540) = 0, then DisplayList_Run(0xF02FB2, 0xF02FD9) -- that is
;      DL_Solo, converted above, whose first record is `op 06` with the
;      literal `.ascii "SOLO"` in it, followed by three coordinate records.
;   2. if (0x27A2) != 0:  DisplayList_Run(0xF02FD9, 0xF02FE3), still layer 0.
;      if (0x27A2) == 0:  (0x2540) = 1, then
;                         DisplayList_Run(0xF02FE3, 0xF02FED).
; Evidence: every one of those six addresses is a 32-bit literal in the
;          instruction stream (`ld XIY,0x00F02FB2` at 0xF5BAC4 and so on), and
;          each pair is (start, end) because that is the argument convention of
;          DisplayList_Run, which slot 0xF417F0 names.  The branch is
;          `cp (0x27A2),0x00 / jr Z,0xF5BAE5`.
; ★ The two overlays draw the SAME RECTANGLE with different ops on different
;          layers: UiPaint_Solo_DL1 is `op 05` with operands 0x0008, 0x0021, 0x0028,
;          0x002C, and UiPaint_Solo_DL2 is `op 1B` with those four words byte for
;          byte.  So the (0x27A2) branch is a two-state indicator, not two
;          unrelated drawings.
; Why the name: the only human-readable thing this routine paints
;          unconditionally is the string "SOLO" inside DL_Solo.  The name is
;          taken from that literal and from nothing else.
; Unknown: what (0x27A2) holds -- nothing in this block writes it.  What ops
;          0x05 and 0x1B do differs by interpreter-A handler, both 0xF31A75.
; ---------------------------------------------------------------------
UiPaint_Solo:		; <- T_UiPaint_Solo
	push	xwa	; F5BAB8  push XWA
	push	xbc	; F5BAB9  push XBC
	push	xde	; F5BABA  push XDE
	push	xhl	; F5BABB  push XHL
	push	xix	; F5BABC  push XIX
	push	xiy	; F5BABD  push XIY
	push	xiz	; F5BABE  push XIZ
	ld	(LCD_CurrentLayer:16), 0	; F5BABF  ld (0x2540),0x00
	ld	xiy, DL_Solo	; F5BAC4  ld XIY,0x00f02fb2
	ld	xix, UiPaint_Solo_DL1	; F5BAC9  ld XIX,0x00f02fd9
	call	T_DisplayList_Run	; F5BACE  call 0xf417f0
	cp	(0x27a2:16), 0x00	; F5BAD2  cp (0x27a2),0x00
	jr	z, UiPaint_Solo_Skip	; F5BAD7  jr Z,0xf5bae5
	ld	xiy, UiPaint_Solo_DL1	; F5BAD9  ld XIY,0x00f02fd9
	ld	xix, UiPaint_Solo_DL2	; F5BADE  ld XIX,0x00f02fe3
	jr	UiPaint_Solo_Join	; F5BAE3  jr T,0xf5baf4
UiPaint_Solo_Skip:
	ld	(LCD_CurrentLayer:16), 1	; F5BAE5  ld (0x2540),0x01
	ld	xiy, UiPaint_Solo_DL2	; F5BAEA  ld XIY,0x00f02fe3
	ld	xix, UiPaint_Ordinals_DL2	; F5BAEF  ld XIX,0x00f02fed
UiPaint_Solo_Join:
	call	T_DisplayList_Run	; F5BAF4  call 0xf417f0
	pop	xiz	; F5BAF8  pop XIZ
	pop	xiy	; F5BAF9  pop XIY
	pop	xix	; F5BAFA  pop XIX
	pop	xhl	; F5BAFB  pop XHL
	pop	xde	; F5BAFC  pop XDE
	pop	xbc	; F5BAFD  pop XBC
	pop	xwa	; F5BAFE  pop XWA
	ret	; F5BAFF  ret
; ---------------------------------------------------------------------
; UiPaint_Ordinals -- paint two or four list rows, each from one of two tables
;
; Called from: thunk slot T_UiPaint_Ordinals -- and NOTHING references that slot.  The
;          byte scan for `1D`/`1B` + 0xF41EDC finds 0 hits in prom_a and 0 in
;          prom_b.  Since that scan runs at every byte offset and can only
;          OVER-count, zero is a real zero: nothing this tree can see calls it.
;          It is still reachable in principle -- the thunk table has 26 POINTER
;          slots whose consumers read groups of slots by address rather than by
;          name (notes/FINDINGS-prom_b-thunk-table.md) -- so this is "no
;          reference found", not "dead".  Do not upgrade that without evidence.
; Inputs:  (0x27F5), a byte, tested against 1; (0x27A4), a byte used as a BIT
;          MASK, one bit per row.
; Outputs: a header list, two or four row lists, and a footer list painted.
; What it does:
;   1. if (0x27F5) == 1: (0x2540)=0, DisplayList_Run(0xF02F22, 0xF02F2C), C=2
;      else:             (0x2540)=0, DisplayList_Run(0xF02F22, 0xF02F36), C=4
;      -- the same start, a different end, so the second form runs a LONGER
;      prefix of the same record stream.
;   2. loop C times, C counting DOWN via `djnz C`:
;        W = (0x27A4);  A = C*2 - 1;  srl A,W
;        carry SET  -> table at 0xF02F52   carry CLEAR -> table at 0xF02F9A
;        BC = C * 4;  XIY = table[BC];  BC += 4;  XIX = table[BC]
;        DisplayList_Run(XIY, XIX)
;   3. (0x2540) = 1, DisplayList_Run(0xF02FED, 0xF02FF7), then a second call
;      through thunk T_DLB_Handler_Array8 with XIY = 0xF02FF7.
; Evidence for the bit tested: `ld W,(0x27A4)` / `ld A,C` / `sla 0x01,A` /
;          `dec 1,A` / `srl A,W` at 0xF5BB3A-0xF5BB45.  In MAME's model
;          `{ M_SRL, O_A, O_R }` (../mame/src/devices/cpu/tlcs900/dasm900.cpp:843)
;          makes A the COUNT and W the value, and `srl8` (900tbl.hxx:1085-1090)
;          sets CF from bit 0 before each of `count` shifts, so the surviving
;          CF is bit (count-1) of the ORIGINAL W.  count = 2C-1, so the bit
;          tested is bit 2C-2: rows C = 1, 2, 3, 4 test bits 0, 2, 4 and 6.
;          ⚠ That is MAME's model of the part, not a databook. The odd bits of
;          (0x27A4) are never tested here, which is a consequence of the
;          reading and is offered as a check on it, not as separate evidence.
;
; ★ THE TWO TABLES ARE 6-ENTRY ARRAYS OF 32-BIT DISPLAY-LIST POINTERS AND THEY
;   TERMINATE THEMSELVES.  Read out of the ROM:
;     0xF02F52: F02F22 F02F36 F02F3D F02F44 F02F4B F02F52
;     0xF02F9A: F02F6A F02F6A F02F76 F02F82 F02F8E F02F9A
;   Each LAST entry is the table's OWN base address, which is also the byte
;   after the final list -- so entry k and entry k+1 bracket list k, and the
;   sixth entry closes the fifth without needing a count.  The loop only ever
;   uses indices 1..5: BC = C*4 with C counting DOWN from 4 (or from 2), so the
;   STARTS are entries 1..4 and the ENDS are entries 2..5.  Entry 0 is not used
;   at all -- not as a start and not as an end.  That is why 0xF02F9A's entries
;   0 and 1 can both hold 0xF02F6A without ambiguity.
;   Both tables are 24 bytes and sit at 0xF02F52-0xF02F69 and
;   0xF02F9A-0xF02FB1, both still `.incbin` -- they are NOT converted by this
;   change and the addresses above are read from the image, not from a label.
; ★ The 0xF02F52 table's four rows are the literal strings "1st", "2nd", "3rd"
;   and "4th": 0xF02F36 is `20 07 91 0B 31 73 74`, i.e. op 0x20, 7 bytes, one
;   operand word 0x0B91, then the ASCII. The other three are the same shape.
;   That is where the name comes from. The 0xF02F9A table's four rows are
;   `03 0C` records carrying a 32-bit POINTER each (0xF0191A, 0xF01938,
;   0xF01956, 0xF01974) -- a different, indirect form of the same row.
; Unknown: what (0x27F5) and (0x27A4) mean; what the 0xF019xx targets are; and
;          what thunk T_DLB_Handler_Array8 does with 0xF02FF7 after the last paint.
; ---------------------------------------------------------------------
UiPaint_Ordinals:		; <- T_UiPaint_Ordinals
	push	xwa	; F5BB00  push XWA
	push	xbc	; F5BB01  push XBC
	push	xde	; F5BB02  push XDE
	push	xhl	; F5BB03  push XHL
	push	xix	; F5BB04  push XIX
	push	xiy	; F5BB05  push XIY
	push	xiz	; F5BB06  push XIZ
	cp	(0x27f5:16), 0x01	; F5BB07  cp (0x27f5),0x01
	jr	nz, UiPaint_Ordinals_Skip	; F5BB0C  jr NZ,0xf5bb25
	ld	(LCD_CurrentLayer:16), 0	; F5BB0E  ld (0x2540),0x00
	ld	xiy, UiPaint_Ordinals_DL1	; F5BB13  ld XIY,0x00f02f22
	ld	xix, UiPaint_Ordinals_DL1 + 0xA	; F5BB18  ld XIX,0x00f02f2c
	call	T_DisplayList_Run	; F5BB1D  call 0xf417f0
	ld	c, 2:opc	; F5BB21  ld C,0x02
	jr	UiPaint_Ordinals_Join	; F5BB23  jr T,0xf5bb3a
UiPaint_Ordinals_Skip:
	ld	(LCD_CurrentLayer:16), 0	; F5BB25  ld (0x2540),0x00
	ld	xiy, UiPaint_Ordinals_DL1	; F5BB2A  ld XIY,0x00f02f22
	ld	xix, DL_F02F36	; F5BB2F  ld XIX,0x00f02f36
	call	T_DisplayList_Run	; F5BB34  call 0xf417f0
	ld	c, 4:opc	; F5BB38  ld C,0x04
UiPaint_Ordinals_Join:
	ld	w, (10148:16)	; F5BB3A  ld W,(0x27a4)
	ld	a, c	; F5BB3E  ld A,C
	sla	a, 1	; F5BB40  sla 0x01,A
	dec	1, a	; F5BB43  dec 1,A
	.byte 0xC8, 0xFF	; F5BB45  srl A,W   [llvm-mc cannot encode this]
	jr	c, UiPaint_Ordinals_Skip2	; F5BB47  jr C,0xf5bb6b
	push	c	; F5BB49  push C
	xor	b, b	; F5BB4B  xor B,B
	sla	bc, 2	; F5BB4D  sla 0x02,BC
	ld	xiz, DLRecordPtrs_F02F9A	; F5BB50  ld XIZ,0x00f02f9a
	ld	xiy, (xiz+bc)	; F5BB55  ld XIY,(XIZ+BC)
	add	bc, 4	; F5BB5A  add BC,0x0004
	ld	xix, (xiz+bc)	; F5BB5E  ld XIX,(XIZ+BC)
	call	T_DisplayList_Run	; F5BB63  call 0xf417f0
	pop	c	; F5BB67  pop C
	jr	UiPaint_Ordinals_Join2	; F5BB69  jr T,0xf5bb8b
UiPaint_Ordinals_Skip2:
	push	c	; F5BB6B  push C
	xor	b, b	; F5BB6D  xor B,B
	sla	bc, 2	; F5BB6F  sla 0x02,BC
	ld	xiz, DLRecordPtrs_F02F52	; F5BB72  ld XIZ,0x00f02f52
	ld	xiy, (xiz+bc)	; F5BB77  ld XIY,(XIZ+BC)
	add	bc, 4	; F5BB7C  add BC,0x0004
	ld	xix, (xiz+bc)	; F5BB80  ld XIX,(XIZ+BC)
	call	T_DisplayList_Run	; F5BB85  call 0xf417f0
	pop	c	; F5BB89  pop C
UiPaint_Ordinals_Join2:
	djnz8	c, -84	; F5BB8B  djnz C,0xf5bb3a
	ld	(LCD_CurrentLayer:16), 1	; F5BB8E  ld (0x2540),0x01
	ld	xiy, UiPaint_Ordinals_DL2	; F5BB93  ld XIY,0x00f02fed
	ld	xix, UiPaint_Ordinals_DL3	; F5BB98  ld XIX,0x00f02ff7
	call	T_DisplayList_Run	; F5BB9D  call 0xf417f0
	ld	xiy, UiPaint_Ordinals_DL3	; F5BBA1  ld XIY,0x00f02ff7
	call	T_DLB_Handler_Array8	; F5BBA6  call 0xf4181c
	pop	xiz	; F5BBAA  pop XIZ
	pop	xiy	; F5BBAB  pop XIY
	pop	xix	; F5BBAC  pop XIX
	pop	xhl	; F5BBAD  pop XHL
	pop	xde	; F5BBAE  pop XDE
	pop	xbc	; F5BBAF  pop XBC
	pop	xwa	; F5BBB0  pop XWA
	ret	; F5BBB1  ret
; ---------------------------------------------------------------------
; Gfx_EraseRect -- SWI7 service 0x1B with its four coordinates
;
; Called from: thunk slot T_Gfx_EraseRect; 7 opcode-anchored references, all in prom_a.
; Inputs:  four 16-bit stack arguments at (XIZ+0x08), (XIZ+0x0A), (XIZ+0x0C),
;          (XIZ+0x0E) -- X0, Y0, X1, Y1.
; Outputs: (0x2530) (0x2532) (0x2534) (0x2536) = those four; (0x2540) = 0;
;          `ld A,0x1B / swi 7`.  All registers restored.
; Evidence, as a BYTE DIFF rather than a reading: this routine and
;          Gfx_DrawLine_Solid at 0xF5B84C are 53 bytes each and differ in
;          EXACTLY ONE byte -- offset 43, the service number, 0x00 against
;          0x1B.  52 of 53 identical.  So it is the same veneer with a
;          different service, and the argument layout established there
;          carries over unchanged.  Counted by
;          `python3 notes/prom_b_f5b800_checks.py`.
; What service 0x1B is: prom_a's SWI7_ServiceTable slot 0x1B holds 0x00F8F8BD,
;          which prom_a converts as `LCD_Svc_1B_EraseRect` -- "clear the box
;          between (X0,Y0) and (X1,Y1)".  That is where the name comes from;
;          nothing in prom_b says "erase".
; Unknown: nothing beyond what prom_a's own service header leaves open.
; ---------------------------------------------------------------------
Gfx_EraseRect:		; <- T_Gfx_EraseRect
	push	xiz	; F5BBB2  push XIZ
	ld	xiz, xsp	; F5BBB3  ld XIZ,XSP
	push	xwa	; F5BBB5  push XWA
	push	xbc	; F5BBB6  push XBC
	push	xde	; F5BBB7  push XDE
	push	xhl	; F5BBB8  push XHL
	push	xix	; F5BBB9  push XIX
	push	xiy	; F5BBBA  push XIY
	ld	wa, (xiz+8)	; F5BBBB  ld WA,(XIZ+0x08)
	ld	(LCD_X0:16), wa	; F5BBBE  ld (0x2530),WA
	ld	wa, (xiz+10)	; F5BBC2  ld WA,(XIZ+0x0a)
	ld	(LCD_Y0:16), wa	; F5BBC5  ld (0x2532),WA
	ld	wa, (xiz+12)	; F5BBC9  ld WA,(XIZ+0x0c)
	ld	(LCD_X1:16), wa	; F5BBCC  ld (0x2534),WA
	ld	wa, (xiz+14)	; F5BBD0  ld WA,(XIZ+0x0e)
	ld	(LCD_Y1:16), wa	; F5BBD3  ld (0x2536),WA
	ld	(LCD_CurrentLayer:16), 0	; F5BBD7  ld (0x2540),0x00
	ld	a, 27:opc	; F5BBDC  ld A,0x1b
	swi	7	; F5BBDE  swi 7
	pop	xiy	; F5BBDF  pop XIY
	pop	xix	; F5BBE0  pop XIX
	pop	xhl	; F5BBE1  pop XHL
	pop	xde	; F5BBE2  pop XDE
	pop	xbc	; F5BBE3  pop XBC
	pop	xwa	; F5BBE4  pop XWA
	pop	xiz	; F5BBE5  pop XIZ
	ret	; F5BBE6  ret

; ==============================================================================
; 0xF5BBE7-0xF62BFF -- THE 96-STEP ROUNDING MAPS AND THE CODE THAT USES THEM
;   the last unconverted `.incbin` span between the selector dispatchers at
;   0xF5B8B6 and the block store at 0xF62C00, converted whole
; ==============================================================================
;
; WHY THIS BLOCK.  notes/prom_b_module_frontier.py ranks thunk runs by CONTIGUOUS
; unconverted target extent.  T_F426E0-T_F42720 is 17 slots over 16,244 bytes,
; all inside ONE `.incbin` span, with the highest summed reference upper bound of
; any run in the image (62); it owns 0xF5EBD0, which notes/prom_b_call_graph.py
; ranks the SECOND most-referenced unconverted target in prom_b (x25, through
; T_BStore_ReadCursorAdvance_Call).  Those 17 slots are the ONLY thunk slots pointing anywhere into the
; span, so the run and the span are the same boundary seen twice, and converting
; the span closes it entirely.
;
; ⚠ WHERE THE START COMES FROM.  notes/prom_a_linear_decode_check.py's warning
; applies: a TLCS-900 linear decode resynchronises within a couple of
; instructions, so "it decodes cleanly" does not pin where a span BEGINS.  What
; pins this one is the converted code above it -- this file already transcribes
; through 0xF5BBE6, and that byte is a `ret`.  0xF5BBE7 is the next byte after a
; proven instruction.  The end is the `.incbin`'s own end.
;
; EXTENT.  Code and data run 0xF5BBE7-0xF5D7EE and 0xF5D802-0xF622D5;
; 0xF5D7EF-0xF5D801 (19 bytes) and 0xF622D6-0xF62BFF (2,346 bytes) are 0x0E
; (`ret`) padding, re-asserted pure on every emit.
;
; THE DATA, AND WHAT IT IS
;
;   0xF5D802  SEVEN 96-ENTRY ROUNDING MAPS.  Each is 96 bytes and each entry k is
;             `g * round(k / g)` for that map's own g -- the index rounded to the
;             nearest multiple of g -- except that the value 96, which is off the
;             end of the index range, is written as 0x7F.  The seven g are
;             96, 48, 24, 12, 32, 16, 8: the divisions of 96 into halves and into
;             thirds.  The grid is DERIVED from each map's own distinct values,
;             and the whole 96-entry table is then compared with the formula byte
;             for byte on every emit.
;             ⚠ ONE ANOMALY, recorded and not corrected: RoundMap_12's entries
;             66..77 read 73 where the formula gives 72.  Twelve bytes, one whole
;             step, all off by the same +1.
;
;   0xF5DBB4  RoundMap_Table, the seven pointers, selected by (0x0C7F).  Its
;             entry count comes from the `jr T,0xF5DBD0` at 0xF5DBB2 that jumps
;             OVER it: 28 bytes / 4.
;
;   0xF5EE75  IdentityMap_0_31 -- 32 bytes, entry k = k.  Read by three sites,
;             and its length is fixed by the two `calr 0xF5EE95` that step past
;             it.  Why an identity map exists is NOT established, and the name
;             deliberately describes the content instead of guessing a purpose.
;
;   0xF621B9  RoundMap_Bounds_A and _B -- 36 bytes each: the seven maps' step
;             BOUNDARIES concatenated in RoundMap_Table order, group sizes
;             1+2+4+8+3+6+12, _B being _A with each group rotated right by one.
;             The group sizes are derived from the maps' grids; the twelve sites
;             that address the island then land, all twelve, exactly on group
;             starts.  The agreement is a check, not a fit -- the sizes were
;             derived before the addresses were looked at.
;
; ⚠ WHAT IS NOT ESTABLISHED.  What the 96 steps COUNT.  Nothing decoded here says
; it; the module's own code only ever selects a map with (0x0C7F) and indexes it
; with a byte read out of the buffer at (0x126E).  Neither is what selects
; (0x0C7F).  The routines are `sub_XXXXXX` with a computed header claiming only
; the entry point, per this tree's rule that a stated gap beats a plausible
; guess.
;
; REGENERATE:  python3 notes/gen_prom_b_f5bbe7_module.py
; CHECKS:      python3 notes/gen_prom_b_f5bbe7_module.py --checks
; ==============================================================================


; --------------------------------------------------------------------------
; KeyboardIcon_Draw
; Called from: in-module: 0xF5C77E 0xF5C8AB 0xF5D4F9 0xF5D5F9
; Touches: (0x2350) (0x2352) (0x2530) (0x2532) (0x2534) (0x2536) (0x2540)
; Calls:   OctaveIcon_Draw
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5BBE7 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; KeyboardIcon_Draw: seven OctaveIcon_Draw from (IconOrigin_X, IconOrigin_Y), IX + 28 each, then the closing key at +196..+200
;   and two marks.  Called after IconOrigin_X/Y = (47, 51) by SoundEditToneLayerKeyLayer_Paint, (56, 139) by the KEY FOLLOW painters.
KeyboardIcon_Draw:
	ld	(LCD_CurrentLayer:16), 0	; F5BBE7  ld (0x2540),0x00
	ld	c, 7:opc	; F5BBEC  ld C,0x07
	ld	ix, (IconOrigin_X:16)	; F5BBEE  ld IX,(0x2350)
	ld	iy, (IconOrigin_Y:16)	; F5BBF2  ld IY,(0x2352)
KeyboardIcon_Draw_Loop:
	pushw	ix	; F5BBF6  push IX
	pushw	iy	; F5BBF7  push IY
	push	c	; F5BBF8  push C
	call	OctaveIcon_Draw	; F5BBFA  call 0xf5bce8
	pop	c	; F5BBFE  pop C
	popw	iy	; F5BC00  pop IY
	popw	ix	; F5BC01  pop IX
	add	ix, 28	; F5BC02  add IX,0x001c
	dec	1, c	; F5BC06  dec 1,C
	jr	nz, KeyboardIcon_Draw_Loop	; F5BC08  jr NZ,0xf5bbf6
	ld	ix, (IconOrigin_X:16)	; F5BC0A  ld IX,(0x2350)
	ld	iy, (IconOrigin_Y:16)	; F5BC0E  ld IY,(0x2352)
	ld	(LCD_X0:16), ix	; F5BC12  ld (0x2530),IX
	addw	(LCD_X0:16), 0x00c4	; F5BC16  add (0x2530),0x00c4
	ld	(LCD_X1:16), ix	; F5BC1C  ld (0x2534),IX
	addw	(LCD_X1:16), 0x00c8	; F5BC20  add (0x2534),0x00c8
	ld	(LCD_Y0:16), iy	; F5BC26  ld (0x2532),IY
	ld	(LCD_Y1:16), iy	; F5BC2A  ld (0x2536),IY
	addw	(LCD_Y1:16), 0x000c	; F5BC2E  add (0x2536),0x000c
	ld	a, 9:opc	; F5BC34  ld A,0x09
	swi	7	; F5BC36  swi 7
	ld	ix, (IconOrigin_X:16)	; F5BC37  ld IX,(0x2350)
	ld	iy, (IconOrigin_Y:16)	; F5BC3B  ld IY,(0x2352)
	add	ix, 196	; F5BC3F  add IX,0x00c4
	ld	(LCD_X0:16), ix	; F5BC43  ld (0x2530),IX
	ld	(LCD_X1:16), ix	; F5BC47  ld (0x2534),IX
	ld	(LCD_Y0:16), iy	; F5BC4B  ld (0x2532),IY
	subw	(LCD_Y0:16), 0x0005	; F5BC4F  sub (0x2532),0x0005
	ld	(LCD_Y1:16), iy	; F5BC55  ld (0x2536),IY
	subw	(LCD_Y1:16), 0x0001	; F5BC59  sub (0x2536),0x0001
	ld	a, 9:opc	; F5BC5F  ld A,0x09
	swi	7	; F5BC61  swi 7
	ld	ix, (IconOrigin_X:16)	; F5BC62  ld IX,(0x2350)
	ld	iy, (IconOrigin_Y:16)	; F5BC66  ld IY,(0x2352)
	ld	(LCD_X0:16), ix	; F5BC6A  ld (0x2530),IX
	subw	(LCD_X0:16), 0x0008	; F5BC6E  sub (0x2530),0x0008
	ld	(LCD_X1:16), ix	; F5BC74  ld (0x2534),IX
	ld	(LCD_Y0:16), iy	; F5BC78  ld (0x2532),IY
	ld	(LCD_Y1:16), iy	; F5BC7C  ld (0x2536),IY
	addw	(LCD_Y1:16), 0x000c	; F5BC80  add (0x2536),0x000c
	ld	a, 9:opc	; F5BC86  ld A,0x09
	swi	7	; F5BC88  swi 7
	ld	ix, (IconOrigin_X:16)	; F5BC89  ld IX,(0x2350)
	ld	iy, (IconOrigin_Y:16)	; F5BC8D  ld IY,(0x2352)
	ld	(LCD_X0:16), ix	; F5BC91  ld (0x2530),IX
	subw	(LCD_X0:16), 0x0005	; F5BC95  sub (0x2530),0x0005
	ld	(LCD_X1:16), ix	; F5BC9B  ld (0x2534),IX
	subw	(LCD_X1:16), 0x0003	; F5BC9F  sub (0x2534),0x0003
	ld	(LCD_Y0:16), iy	; F5BCA5  ld (0x2532),IY
	addw	(LCD_Y0:16), 0x0001	; F5BCA9  add (0x2532),0x0001
	ld	(LCD_Y1:16), iy	; F5BCAF  ld (0x2536),IY
	addw	(LCD_Y1:16), 0x0007	; F5BCB3  add (0x2536),0x0007
	ld	a, 9:opc	; F5BCB9  ld A,0x09
	swi	7	; F5BCBB  swi 7
	ld	ix, (IconOrigin_X:16)	; F5BCBC  ld IX,(0x2350)
	ld	iy, (IconOrigin_Y:16)	; F5BCC0  ld IY,(0x2352)
	sub	ix, 4	; F5BCC4  sub IX,0x0004
	ld	(LCD_X0:16), ix	; F5BCC8  ld (0x2530),IX
	ld	(LCD_X1:16), ix	; F5BCCC  ld (0x2534),IX
	ld	(LCD_Y0:16), iy	; F5BCD0  ld (0x2532),IY
	addw	(LCD_Y0:16), 0x0001	; F5BCD4  add (0x2532),0x0001
	ld	(LCD_Y1:16), iy	; F5BCDA  ld (0x2536),IY
	addw	(LCD_Y1:16), 0x000b	; F5BCDE  add (0x2536),0x000b
	ld	a, 2:opc	; F5BCE4  ld A,0x02
	swi	7	; F5BCE6  swi 7
	ret	; F5BCE7  ret

; --------------------------------------------------------------------------
; OctaveIcon_Draw
; Called from: in-module: 0xF5BBFA
; Touches: (0x2530) (0x2532) (0x2534) (0x2536)  |  0x000004
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5BCE8 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; OctaveIcon_Draw: at (IX, IY): one 28-pixel octave -- a service-0x09 box 28 x 12, six VLines (service 0x02) and the five
;   OctaveIcon_BlackKeyX boxes.  Called seven times by KeyboardIcon_Draw.
OctaveIcon_Draw:
	ld	(LCD_X0:16), ix	; F5BCE8  ld (0x2530),IX
	ld	(LCD_X1:16), ix	; F5BCEC  ld (0x2534),IX
	ld	(LCD_Y0:16), iy	; F5BCF0  ld (0x2532),IY
	subw	(LCD_Y0:16), 0x0005	; F5BCF4  sub (0x2532),0x0005
	ld	(LCD_Y1:16), iy	; F5BCFA  ld (0x2536),IY
	subw	(LCD_Y1:16), 0x0001	; F5BCFE  sub (0x2536),0x0001
	ld	a, 2:opc	; F5BD04  ld A,0x02
	pushw	ix	; F5BD06  push IX
	pushw	iy	; F5BD07  push IY
	swi	7	; F5BD08  swi 7
	popw	iy	; F5BD09  pop IY
	popw	ix	; F5BD0A  pop IX
	ld	(LCD_X0:16), ix	; F5BD0B  ld (0x2530),IX
	ld	(LCD_Y0:16), iy	; F5BD0F  ld (0x2532),IY
	ld	(LCD_X1:16), ix	; F5BD13  ld (0x2534),IX
	addw	(LCD_X1:16), 0x001c	; F5BD17  add (0x2534),0x001c
	ld	(LCD_Y1:16), iy	; F5BD1D  ld (0x2536),IY
	addw	(LCD_Y1:16), 0x000c	; F5BD21  add (0x2536),0x000c
	ld	a, 9:opc	; F5BD27  ld A,0x09
	pushw	ix	; F5BD29  push IX
	pushw	iy	; F5BD2A  push IY
	swi	7	; F5BD2B  swi 7
	popw	iy	; F5BD2C  pop IY
	popw	ix	; F5BD2D  pop IX
	ld	c, 5:opc	; F5BD2E  ld C,0x05
	ld	xiz, OctaveIcon_BlackKeyX	; F5BD30  ld XIZ,0x00f5bda7
OctaveIcon_Draw_Loop:
	ld	hl, (xiz)	; F5BD35  ld HL,(XIZ)
	ld	de, (xiz+2)	; F5BD37  ld DE,(XIZ+0x02)
	add	xiz, 4	; F5BD3A  add XIZ,0x00000004
	ld	(LCD_X0:16), ix	; F5BD40  ld (0x2530),IX
	add	(LCD_X0:16), hl	; F5BD44  add (0x2530),HL
	ld	(LCD_X1:16), ix	; F5BD48  ld (0x2534),IX
	add	(LCD_X1:16), de	; F5BD4C  add (0x2534),DE
	ld	(LCD_Y0:16), iy	; F5BD50  ld (0x2532),IY
	addw	(LCD_Y0:16), 0x0001	; F5BD54  add (0x2532),0x0001
	ld	(LCD_Y1:16), iy	; F5BD5A  ld (0x2536),IY
	addw	(LCD_Y1:16), 0x0007	; F5BD5E  add (0x2536),0x0007
	ld	a, 9:opc	; F5BD64  ld A,0x09
	push	c	; F5BD66  push C
	push	xiz	; F5BD68  push XIZ
	pushw	ix	; F5BD69  push IX
	pushw	iy	; F5BD6A  push IY
	swi	7	; F5BD6B  swi 7
	popw	iy	; F5BD6C  pop IY
	popw	ix	; F5BD6D  pop IX
	pop	xiz	; F5BD6E  pop XIZ
	pop	c	; F5BD6F  pop C
	dec	1, c	; F5BD71  dec 1,C
	jr	nz, OctaveIcon_Draw_Loop	; F5BD73  jr NZ,0xf5bd35
	ld	c, 6:opc	; F5BD75  ld C,0x06
OctaveIcon_Draw_Loop2:
	add	ix, 4	; F5BD77  add IX,0x0004
	ld	(LCD_X0:16), ix	; F5BD7B  ld (0x2530),IX
	ld	(LCD_X1:16), ix	; F5BD7F  ld (0x2534),IX
	ld	(LCD_Y0:16), iy	; F5BD83  ld (0x2532),IY
	addw	(LCD_Y0:16), 0x0001	; F5BD87  add (0x2532),0x0001
	ld	(LCD_Y1:16), iy	; F5BD8D  ld (0x2536),IY
	addw	(LCD_Y1:16), 0x000b	; F5BD91  add (0x2536),0x000b
	ld	a, 2:opc	; F5BD97  ld A,0x02
	push	c	; F5BD99  push C
	pushw	ix	; F5BD9B  push IX
	pushw	iy	; F5BD9C  push IY
	swi	7	; F5BD9D  swi 7
	popw	iy	; F5BD9E  pop IY
	popw	ix	; F5BD9F  pop IX
	pop	c	; F5BDA0  pop C
	dec	1, c	; F5BDA2  dec 1,C
	jr	nz, OctaveIcon_Draw_Loop2	; F5BDA4  jr NZ,0xf5bd77
	ret	; F5BDA6  ret
; --------------------------------------------------------------------------
; OctaveIcon_BlackKeyX -- 0xF5BDA7-0xF5BDBA, 5 records of two 16-bit words:
;   the left and right X offsets of the five BLACK KEYS of a one-octave
;   keyboard picture.  Converted 2026-09-25 (lane promb): the source framed
;   the 20 bytes as `pop SR`, `halt`, `reti`, `retd 0x1100`, `ldf` ...
; Read by: OctaveIcon_Draw (0xF5BCE8), the routine that draws the picture: its loop
;   (`ld C,0x05`, `ld XIZ,0x00F5BDA7`, `ld HL,(XIZ)` / `ld DE,(XIZ+2)` /
;   `add XIZ,4`) sets X0 = IX + first word, X1 = IX + second word, Y0 = IY+1,
;   Y1 = IY+7 and calls SWI7 service 0x09, prom_a LCD_Svc_09_DrawBox.
; Why "keyboard": the same routine first draws a 28-pixel-wide outline (X1 =
;   IX + 0x1C) and afterwards six vertical lines (service 0x02,
;   LCD_Svc_02_DrawVLine) at IX + 4, 8, 12, 16, 20, 24 -- seven 4-pixel white
;   keys.  The five boxes span 3-5, 7-9, 15-17, 19-21, 23-25: centred on the
;   dividers at 4, 8, 16, 20 and 24 and on none at 12, which is the C-D-E /
;   F-G-A-B pattern of black keys.
; --------------------------------------------------------------------------
OctaveIcon_BlackKeyX:
	.short	3, 5	; F5BDA7  [0]
	.short	7, 9	; F5BDAB  [1]
	.short	15, 17	; F5BDAF  [2]
	.short	19, 21	; F5BDB3  [3]
	.short	23, 25	; F5BDB7  [4]

; --------------------------------------------------------------------------
; TouchCurve_DrawCurrentSlot
; Called from: in-module: 0xF5C6F3 0xF5CFEE 0xF5CFF9
; Touches: (0x2350) (0x2352) (0x2540) (0x27A3) (0x27F5)  |  0x00002A
;          0x0027AB 0x0027AE 0xF0402E 0xF04038 0xF04042 +4 more
; Calls:   T_DisplayList_Run TouchCurve_DrawThumbnail
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5BDBB is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TouchCurve_DrawCurrentSlot: IconOrigin = TouchCurve_BoxOrigins[(0x27A3)] (BoxOrigins3 when (0x27F5) is 1), TouchCurve_DrawThumbnail on
;   ModelingPage_Fields+5 / +8 + (0x27A3), then the slot's TouchCurve_ListPtrs list.  Called by
;   Draw_Page12LevelTouchCurveLevel and SoundEditAmpLevel1_RepaintField.
TouchCurve_DrawCurrentSlot:
	cp	(0x27f5:16), 0x01	; F5BDBB  cp (0x27f5),0x01
	jr	nz, TouchCurve_DrawCurrentSlot_Skip4	; F5BDC0  jr NZ,0xf5bdd7
	ld	(LCD_CurrentLayer:16), 0	; F5BDC2  ld (0x2540),0x00
	ld	xiy, TouchCurve_DrawCurrentSlot_DL1	; F5BDC7  ld XIY,0x00f04038
	ld	xix, DL_TouchCurve_0	; F5BDCC  ld XIX,0x00f04042
	call	T_DisplayList_Run	; F5BDD1  call 0xf417f0
	jr	TouchCurve_DrawCurrentSlot_Join	; F5BDD5  jr T,0xf5bdea
TouchCurve_DrawCurrentSlot_Skip4:
	ld	(LCD_CurrentLayer:16), 0	; F5BDD7  ld (0x2540),0x00
	ld	xiy, TouchCurve_DrawCurrentSlot_DL2	; F5BDDC  ld XIY,0x00f0402e
	ld	xix, TouchCurve_DrawCurrentSlot_DL1	; F5BDE1  ld XIX,0x00f04038
	call	T_DisplayList_Run	; F5BDE6  call 0xf417f0
TouchCurve_DrawCurrentSlot_Join:
	xor	xwa, xwa	; F5BDEA  xor XWA,XWA
	ld	a, (10147:16)	; F5BDEC  ld A,(0x27a3)
	sla	wa, 2	; F5BDF0  sla 0x02,WA
	cp	(0x27f5:16), 0x01	; F5BDF3  cp (0x27f5),0x01
	jr	nz, TouchCurve_DrawCurrentSlot_Skip	; F5BDF8  jr NZ,0xf5be01
	ld	xiz, TouchCurve_BoxOrigins3	; F5BDFA  ld XIZ,0x00f04172
	jr	TouchCurve_DrawCurrentSlot_Join2	; F5BDFF  jr T,0xf5be06
TouchCurve_DrawCurrentSlot_Skip:
	ld	xiz, TouchCurve_BoxOrigins	; F5BE01  ld XIZ,0x00f0415e
TouchCurve_DrawCurrentSlot_Join2:
	push	xwa	; F5BE06  push XWA
	add	xiz, xwa	; F5BE07  add XIZ,XWA
	ld	wa, (xiz)	; F5BE09  ld WA,(XIZ)
	ld	(IconOrigin_X:16), wa	; F5BE0B  ld (0x2350),WA
	ld	wa, (xiz+2)	; F5BE0F  ld WA,(XIZ+0x02)
	ld	(IconOrigin_Y:16), wa	; F5BE12  ld (0x2352),WA
	cp	(0x27f5:16), 0x01	; F5BE16  cp (0x27f5),0x01
	jr	nz, TouchCurve_DrawCurrentSlot_Skip2	; F5BE1B  jr NZ,0xf5be24
	ld	xiz, ModelingPage_Fields+5	; F5BE1D  ld XIZ,0x000027ab
	jr	TouchCurve_DrawCurrentSlot_Join3	; F5BE22  jr T,0xf5be29
TouchCurve_DrawCurrentSlot_Skip2:
	ld	xiz, ModelingPage_Fields+8	; F5BE24  ld XIZ,0x000027ae
TouchCurve_DrawCurrentSlot_Join3:
	xor	xwa, xwa	; F5BE29  xor XWA,XWA
	ld	a, (10147:16)	; F5BE2B  ld A,(0x27a3)
	add	xiz, xwa	; F5BE2F  add XIZ,XWA
	call	TouchCurve_DrawThumbnail	; F5BE31  call 0xf5be5a
	pop	xwa	; F5BE35  pop XWA
	cp	(0x27f5:16), 0x01	; F5BE36  cp (0x27f5),0x01
	jr	nz, TouchCurve_DrawCurrentSlot_Skip3	; F5BE3B  jr NZ,0xf5be44
	ld	xiz, TouchCurve_ListPtrs3	; F5BE3D  ld XIZ,0x00f04152
	jr	TouchCurve_DrawCurrentSlot_Join4	; F5BE42  jr T,0xf5be49
TouchCurve_DrawCurrentSlot_Skip3:
	ld	xiz, TouchCurve_ListPtrs	; F5BE44  ld XIZ,0x00f0413e
TouchCurve_DrawCurrentSlot_Join4:
	add	xiz, xwa	; F5BE49  add XIZ,XWA
	ld	xiy, (xiz)	; F5BE4B  ld XIY,(XIZ)
	ld	xix, xiy	; F5BE4D  ld XIX,XIY
	add	xix, 42	; F5BE4F  add XIX,0x0000002a
	call	T_DisplayList_Run	; F5BE55  call 0xf417f0
	ret	; F5BE59  ret

; --------------------------------------------------------------------------
; TouchCurve_DrawThumbnail
; Called from: in-module: 0xF5BE31
; Touches: (0x2350) (0x2352) (0x2530) (0x2532) (0x2534) (0x2536) (0x2540)
;          (0x27F5)  |  0xF01800 0xF01873 0xF0191A 0xF33BD8 0xF33F01
;          0xFC517E +1 more
; Calls:   T_DisplayList_Run 0xF09D91 T_DisplayListB_Run 0xF09DED
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5BE5A is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TouchCurve_DrawThumbnail: curve = (XIZ) >> 5: 3 erases the box at IconOrigin + 1 (service 0x1B) and draws the diagonal (service 0x00,
;   DrawLine); otherwise blits CurveBitmapSelector[curve], 40 x 40, at IconOrigin (service 0x03).  Also the filler
;   entry of Dispatch_Code80_PaintTable / F5B9F8 at the selectors with no page.
TouchCurve_DrawThumbnail:
	ld	a, (xiz)	; F5BE5A  ld A,(XIZ)
	and	a, 224	; F5BE5C  and A,0xe0
	srl	a, 5	; F5BE5F  srl 0x05,A
	cp	a, 3:i3	; F5BE62  cp A,3
	jr	nz, TouchCurve_DrawThumbnail_Skip	; F5BE64  jr NZ,0xf5bece
	ld	ix, (IconOrigin_X:16)	; F5BE66  ld IX,(0x2350)
	ld	iy, (IconOrigin_Y:16)	; F5BE6A  ld IY,(0x2352)
	ld	(LCD_X0:16), ix	; F5BE6E  ld (0x2530),IX
	addw	(LCD_X0:16), 0x0001	; F5BE72  add (0x2530),0x0001
	ld	(LCD_X1:16), ix	; F5BE78  ld (0x2534),IX
	addw	(LCD_X1:16), 0x0025	; F5BE7C  add (0x2534),0x0025
	ld	(LCD_Y0:16), iy	; F5BE82  ld (0x2532),IY
	addw	(LCD_Y0:16), 0x0001	; F5BE86  add (0x2532),0x0001
	ld	(LCD_Y1:16), iy	; F5BE8C  ld (0x2536),IY
	addw	(LCD_Y1:16), 0x0025	; F5BE90  add (0x2536),0x0025
	ld	a, 27:opc	; F5BE96  ld A,0x1b
	swi	7	; F5BE98  swi 7
	ld	ix, (IconOrigin_X:16)	; F5BE99  ld IX,(0x2350)
	ld	iy, (IconOrigin_Y:16)	; F5BE9D  ld IY,(0x2352)
	ld	(LCD_X0:16), ix	; F5BEA1  ld (0x2530),IX
	addw	(LCD_X0:16), 0x0001	; F5BEA5  add (0x2530),0x0001
	ld	(LCD_X1:16), ix	; F5BEAB  ld (0x2534),IX
	addw	(LCD_X1:16), 0x0026	; F5BEAF  add (0x2534),0x0026
	ld	(LCD_Y0:16), iy	; F5BEB5  ld (0x2532),IY
	addw	(LCD_Y0:16), 0x0026	; F5BEB9  add (0x2532),0x0026
	ld	(LCD_Y1:16), iy	; F5BEBF  ld (0x2536),IY
	addw	(LCD_Y1:16), 0x0001	; F5BEC3  add (0x2536),0x0001
	ld	a, 0:opc	; F5BEC9  ld A,0x00
	swi	7	; F5BECB  swi 7
	jr	TouchCurve_DrawThumbnail_Return	; F5BECC  jr T,0xf5befa
TouchCurve_DrawThumbnail_Skip:
	ld	xiz, CurveBitmapSelector	; F5BECE  ld XIZ,0x00f5befb
	xor	w, w	; F5BED3  xor W,W
	sll	wa, 2	; F5BED5  sll 0x02,WA
	ld	xiy, (xiz+wa)	; F5BED8  ld XIY,(XIZ+WA)
	ld	wa, (IconOrigin_X:16)	; F5BEDD  ld WA,(0x2350)
	div	a, 8	; F5BEE1  div A,0x08
	xor	w, w	; F5BEE4  xor W,W
	ld	hl, (IconOrigin_Y:16)	; F5BEE6  ld HL,(0x2352)
	mul	l, 40	; F5BEEA  mul L,0x28
	add	hl, wa	; F5BEED  add HL,WA
	ld	ix, hl	; F5BEEF  ld IX,HL
	ldw	bc, 5	; F5BEF1  ld BC,0x0005
	ldw	hl, 40	; F5BEF4  ld HL,0x0028
	ld	a, 3:opc	; F5BEF7  ld A,0x03
	swi	7	; F5BEF9  swi 7
TouchCurve_DrawThumbnail_Return:
	ret	; F5BEFA  ret
; --------------------------------------------------------------------------
; CurveBitmapSelector -- 0xF5BEFB-0xF5BF16, 7 pointers to the six 40 x 40
;   response-curve thumbnails at 0xF019C2-0xF01E71 (entries 3 and 6 are the
;   same bitmap).  Converted 2026-09-25 (lane promb): the source framed the
;   28 bytes as `cp XWA,(XDE+0x1d)`, `nop`, `jp 0x8a00f0` and four `.byte`
;   rows of "instructions" -- the mis-framing the 0xF01800 block's banner
;   records ("THE SELECTOR TABLE AT 0xF5BEFB IS ITSELF STILL MIS-FRAMED AS
;   CODE ... deliberately NOT touched here").
; Read by: TouchCurve_DrawThumbnail at 0xF5BECE -- `ld XIZ,0x00F5BEFB`, index * 4,
;   `ld XIY,(XIZ+WA)`, destination y*40 + x/8 from (0x2350)/(0x2352), BC = 5,
;   HL = 40, SWI7 service 0x03 (a 5-column x 40-row blit).
; Entry count: 7 -- 28 bytes, and every word is one of the six bitmaps; the
;   byte after the table is 0x0E and LCD_BlankThenSetPanel3Layer_Copy2 begins after that.
; --------------------------------------------------------------------------
CurveBitmapSelector:
	.long	Bitmap_F01DAA	; F5BEFB  [0]
	.long	Bitmap_F01CE2	; F5BEFF  [1]
	.long	Bitmap_F01C1A	; F5BF03  [2]
	.long	Bitmap_F019C2	; F5BF07  [3]
	.long	Bitmap_F01B52	; F5BF0B  [4]
	.long	Bitmap_F01A8A	; F5BF0F  [5]
	.long	Bitmap_F019C2	; F5BF13  [6]
	.byte	0x0E	; F5BF17  a lone 0x0E (`ret`) that nothing reaches
; LCD_BlankThenSetPanel3Layer_Copy2: C = 0, `swi 7` service 0x0C (LCD_Svc_0C_SetLayersOn: all layers off), then service 0x10 (LCD_Svc_10_SetPanel3Layer):
;   prom_a's LCD_BlankThenSetPanel3Layer sequence (prom_b also holds LCD_BlankThenSetPanel3Layer_Copy at 0xF31852); called from Dispatch_Code80_Bracketed.  Basis: body + SWI7 service
;   table (FINDINGS-display-controller.md).
LCD_BlankThenSetPanel3Layer_Copy2:
	ld	c, 0:opc	; F5BF18  ld C,0x00
	ld	a, 12:opc	; F5BF1A  ld A,0x0c
	swi	7	; F5BF1C  swi 7
	ld	a, 16:opc	; F5BF1D  ld A,0x10
	swi	7	; F5BF1F  swi 7
	ret	; F5BF20  ret
; LCD_ShowAllLayers_Copy2: the same as LCD_ShowAllLayers_Copy; called from Dispatch_Code80_Bracketed.  Basis: body + SWI7 table.
LCD_ShowAllLayers_Copy2:
	ld	c, 7:opc	; F5BF21  ld C,0x07
	ld	a, 12:opc	; F5BF23  ld A,0x0c
	swi	7	; F5BF25  swi 7
	ret	; F5BF26  ret
; SoundEditMenu_Paint: Dispatch_Code80_PaintTable[code 0x80] -- Dispatch_Code80_Bracketed, the full paint.
SoundEditMenu_Paint:
	cp	(0x27f5:16), 0x01	; F5BF27  cp (0x27f5),0x01
	jr	z, SoundEditMenu_Paint_Skip2	; F5BF2C  jr Z,0xf5bf51
	ld	(LCD_CurrentLayer:16), 0	; F5BF2E  ld (0x2540),0x00
	ld	xiy, DL_SoundEditWriteCopy	; F5BF33  ld XIY,0x00f01800
	ld	xix, DL_ToneLayerDspEffectPitchDigital	; F5BF38  ld XIX,0x00f01873
	call	T_DisplayList_Run	; F5BF3D  call 0xf417f0
	ld	xiy, DL_ToneLayerDspEffectPitchDigital	; F5BF41  ld XIY,0x00f01873
	ld	xix, Data_F0191A	; F5BF46  ld XIX,0x00f0191a
	call	T_DisplayList_Run	; F5BF4B  call 0xf417f0
	jr	SoundEditMenu_Paint_Return2	; F5BF4F  jr T,0xf5bf89
SoundEditMenu_Paint_Skip2:
	ld	(LCD_CurrentLayer:16), 0	; F5BF51  ld (0x2540),0x00
	ld	xiy, DL_UserKitSoundEditSoundToneSelect	; F5BF56  ld XIY,0x00f33bd8
	ld	xix, DL_UserKitSoundEditSoundToneSelect + 0x329	; F5BF5B  ld XIX,0x00f33f01
	call	T_DisplayList_Run	; F5BF60  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F5BF64  ld (0x2540),0x00
	call	SoundEditMenu_PaintOrdinals	; F5BF69  call 0xf09d91
	ld	xiy, DisplayList_FC517E	; F5BF6D  ld XIY,0x00fc517e
	ld	xix, DisplayList_FC517E_End	; F5BF72  ld XIX,0x00fc527a
	call	T_DisplayListB_Run	; F5BF77  call 0xf417f4
	ld	(LCD_CurrentLayer:16), 0	; F5BF7B  ld (0x2540),0x00
	call	SoundEditMenu_PaintPanAmounts	; F5BF80  call 0xf09ded
	ld	(LCD_CurrentLayer:16), 0	; F5BF84  ld (0x2540),0x00
SoundEditMenu_Paint_Return2:
	ret	; F5BF89  ret

; --------------------------------------------------------------------------
; ModelingPage_PaintFields11And12
; Called from: in-module: 0xF5C278 0xF5CE4C
; Touches: (0x2540)
; Calls:   ModelingPage_PaintFieldReadout
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5BF8A is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ModelingPage_PaintFields11And12: Layer 0; for A = 11, 12: when ModelingPage_Fields[A] != 0, runs record A of
;   DLBRecordPtrs_F065AC -- a 2-digit readout of that field at 0x22A9 / 0x22AD. On page A8 those land in the blanks of
;   the 'L '/'R ' labels field 10 selects (CTR/L/R/RDM). Called by page A8's full paint and its field>=11 repaint, and
;   SoundEditMenu_RepaintField. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave2_c.json)
ModelingPage_PaintFields11And12:
	ld	(LCD_CurrentLayer:16), 0	; F5BF8A  ld (0x2540),0x00
	ld	a, 11:opc	; F5BF8F  ld A,0x0b
ModelingPage_PaintFields11And12_Loop:
	push_a	; F5BF91  push A
	call	ModelingPage_PaintFieldReadout	; F5BF92  call 0xf5bf9f
	pop_a	; F5BF96  pop A
	inc	1, a	; F5BF97  inc 1,A
	cp	a, 13	; F5BF99  cp A,0x0d
	jr	c, ModelingPage_PaintFields11And12_Loop	; F5BF9C  jr C,0xf5bf91
	ret	; F5BF9E  ret

; --------------------------------------------------------------------------
; ModelingPage_PaintFieldReadout
; Called from: in-module: 0xF5BF92
; Touches: (0x2540)  |  0xF065AC
; Calls:   0xF09AE1
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5BF9F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ModelingPage_PaintFieldReadout: For field A: when ModelingPage_Fields[A] is non-zero, runs record A of
;   DLBRecordPtrs_F065AC on layer 0 (RunDisplayListBFromPointerArray) -- the 2-digit readout of that field.
;   ModelingPage_PaintFields11And12 calls it for A = 11 and 12; the same shape as SoundEditMenu_PaintPanAmountField.
;   Basis: caller + caller header + body. (notes/naming-pilot-2026-10-06/proposals_wave4_m.json)
ModelingPage_PaintFieldReadout:
	xor	xbc, xbc	; F5BF9F  xor XBC,XBC
	xor	w, w	; F5BFA1  xor W,W
	ldw	bc, ModelingPage_Fields	; F5BFA3  ld BC,0x27a6
	add	bc, wa	; F5BFA6  add BC,WA
	ld	d, (xbc)	; F5BFA8  ld D,(XBC)
	cp	d, 0:i3	; F5BFAA  cp D,0
	jr	z, ModelingPage_PaintFieldReadout_Return	; F5BFAC  jr Z,0xf5bfbc
	ld	xiy, DLBRecordPtrs_F065AC	; F5BFAE  ld XIY,0x00f065ac
	ld	(LCD_CurrentLayer:16), 0	; F5BFB3  ld (0x2540),0x00
	call	RunDisplayListBFromPointerArray	; F5BFB8  call 0xf09ae1
ModelingPage_PaintFieldReadout_Return:
	ret	; F5BFBC  ret

; --------------------------------------------------------------------------
; SoundEdit_PaintPageLabelBackdrop
; Called from: in-module: 0xF5C0B4 0xF5C0EA 0xF5C120 0xF5C188 0xF5C1FF
;              0xF5C6C9 0xF5C74D 0xF5C89B +5 more
; Touches: (0x2540) (0x27F5)  |  0xF02064 0xF020AA 0xF021E4 0xF02469
;          0xF02671 0xF027AF +17 more
; Calls:   T_UiPaint_PageLabelBackdrop Draw_M0delingSoundEditToneDriver Draw_ToneDriverResonator T_DisplayList_Run T_DisplayListB_Run 0xF09AF1
;          0xF5BAB8 ToneEditPage_A0_PaintSlotOrdinals ToneEditPage_A0_PaintGroupBrackets 0xF5BB00 SoundEditModelingDriverWaveform_PaintRows DisplayList_Run_ResoDriverNatorPositionMovement_Page22P0siti0nM0vementWidth +4
;          more
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5BFBD is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEdit_PaintPageLabelBackdrop: LCD_CurrentLayer := 0, then T_UiPaint_PageLabelBackdrop (UiPaint_PageLabelBackdrop, the rounded backdrop behind the
;   'PAGEn/m' legend), which restores the layer it saved -- so the caller carries on drawing in layer 0. Basis:
;   callers + body -- called only by the sound-edit / modeling tone-edit page painters of Dispatch_Code80_PaintTable next to
;   the list that prints their 'PAGEn/m'. (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
SoundEdit_PaintPageLabelBackdrop:
	ld	(LCD_CurrentLayer:16), 0	; F5BFBD  ld (0x2540),0x00
	call	T_UiPaint_PageLabelBackdrop	; F5BFC2  call 0xf42e18
	ret	; F5BFC6  ret
; ToneEditPage_A0_Paint: Dispatch_Code80_PaintTable[code 0xA0] -- Dispatch_Code80_Bracketed, the full paint.
ToneEditPage_A0_Paint:
	call	Draw_M0delingSoundEditToneDriver	; F5BFC7  call 0xf5c338
	call	Draw_ToneDriverResonator	; F5BFCB  call 0xf5c360
	cp	(0x27f5:16), 0x01	; F5BFCF  cp (0x27f5),0x01
	jr	z, ToneEditPage_A0_Paint_Skip	; F5BFD4  jr Z,0xf5bfe4
	ld	xiy, ToneEditPage_A0_Paint_DL1	; F5BFD6  ld XIY,0x00f02064
	ld	xix, DL_ResonatorDriverOnOffGroup	; F5BFDB  ld XIX,0x00f020aa
	call	T_DisplayList_Run	; F5BFE0  call 0xf417f0
ToneEditPage_A0_Paint_Skip:
	ld	xiy, DL_ResonatorDriverOnOffGroup	; F5BFE4  ld XIY,0x00f020aa
	ld	xix, DL_ToneDriverResonator	; F5BFE9  ld XIX,0x00f021e4
	call	T_DisplayList_Run	; F5BFEE  call 0xf417f0
	cp	(0x27f5:16), 0x01	; F5BFF2  cp (0x27f5),0x01
	jr	z, ToneEditPage_A0_Paint_Skip2	; F5BFF7  jr Z,0xf5c01f
	ld	(LCD_CurrentLayer:16), 0	; F5BFF9  ld (0x2540),0x00
	ld	xiy, DL_OriginalStringCylinderCone	; F5BFFE  ld XIY,0x00f0302a
	ld	xix, ToneEditPage_A0_PaintGroupBrackets_DL2	; F5C003  ld XIX,0x00f03107
	call	T_DisplayListB_Run	; F5C008  call 0xf417f4
	ld	c, 4:opc	; F5C00C  ld C,0x04
	ld	a, 4:opc	; F5C00E  ld A,0x04
	sub	a, c	; F5C010  sub A,C
	push	c	; F5C012  push C
	call	ToneEditPage_A0_PaintResonatorIcon	; F5C014  call 0xf09af1
	pop	c	; F5C018  pop C
	djnz8	c, -15	; F5C01A  djnz C,0xf5c00e
	jr	ToneEditPage_A0_Paint_Join	; F5C01D  jr T,0xf5c05f
ToneEditPage_A0_Paint_Skip2:
	ld	(LCD_CurrentLayer:16), 0	; F5C01F  ld (0x2540),0x00
	ld	xiy, DL_OriginalStringCylinderCone	; F5C024  ld XIY,0x00f0302a
	ld	xix, DL_OriginalStringCylinderCone + 0x22	; F5C029  ld XIX,0x00f0304c
	call	T_DisplayListB_Run	; F5C02E  call 0xf417f4
	ld	xiy, ToneEditPage_A0_Paint_DL2	; F5C032  ld XIY,0x00f0306e
	ld	xix, ToneEditPage_A0_Paint_DL2 + 0x3C	; F5C037  ld XIX,0x00f030aa
	call	T_DisplayListB_Run	; F5C03C  call 0xf417f4
	ld	xiy, DL_F030E6	; F5C040  ld XIY,0x00f030e6
	ld	xix, ToneEditPage_A0_PaintGroupBrackets_DL2	; F5C045  ld XIX,0x00f03107
	call	T_DisplayListB_Run	; F5C04A  call 0xf417f4
	ld	c, 2:opc	; F5C04E  ld C,0x02
	ld	a, 2:opc	; F5C050  ld A,0x02
	sub	a, c	; F5C052  sub A,C
	push	c	; F5C054  push C
	call	ToneEditPage_A0_PaintResonatorIcon	; F5C056  call 0xf09af1
	pop	c	; F5C05A  pop C
	djnz8	c, -15	; F5C05C  djnz C,0xf5c050
ToneEditPage_A0_Paint_Join:
	call	UiPaint_Solo	; F5C05F  call 0xf5bab8
	call	ToneEditPage_A0_PaintSlotOrdinals	; F5C063  call 0xf5c424
	call	ToneEditPage_A0_PaintGroupBrackets	; F5C067  call 0xf5cbd9
	ret	; F5C06B  ret
Draw_DriverDriverWaveformReso:
	call	Draw_M0delingSoundEditToneDriver	; F5C06C  call 0xf5c338
	ld	xiy, DL_DriverDriverWaveformReso	; F5C070  ld XIY,0x00f02469
	ld	xix, DL_Page12P0siti0nParameterP0siti0n	; F5C075  ld XIX,0x00f02671
	call	T_DisplayList_Run	; F5C07A  call 0xf417f0
	call	UiPaint_Solo	; F5C07E  call 0xf5bab8
	call	UiPaint_Ordinals	; F5C082  call 0xf5bb00
	ld	(LCD_CurrentLayer:16), 0	; F5C086  ld (0x2540),0x00
	ld	xiy, DL_F338EB	; F5C08B  ld XIY,0x00f338eb
	ld	xix, SoundEditModelingDriverWaveform_PaintRows_DL2	; F5C090  ld XIX,0x00f338f6
	call	T_DisplayListB_Run	; F5C095  call 0xf417f4
	call	SoundEditModelingDriverWaveform_PaintRows	; F5C099  call 0xf5cc64
	ret	; F5C09D  ret
; ToneEditPage_A3_Paint: Dispatch_Code80_PaintTable[code 0xA3] -- Dispatch_Code80_Bracketed, the full paint.
ToneEditPage_A3_Paint:
	call	Draw_M0delingSoundEditToneDriver	; F5C09E  call 0xf5c338
	call	DisplayList_Run_ResoDriverNatorPositionMovement_Page22P0siti0nM0vementWidth	; F5C0A2  call 0xf5c374
	ld	xiy, DL_Page12P0siti0nParameterP0siti0n	; F5C0A6  ld XIY,0x00f02671
	ld	xix, DL_ResoDriverNatorPositionMovement	; F5C0AB  ld XIX,0x00f027af
	call	T_DisplayList_Run	; F5C0B0  call 0xf417f0
	call	SoundEdit_PaintPageLabelBackdrop	; F5C0B4  call 0xf5bfbd
	call	UiPaint_Solo	; F5C0B8  call 0xf5bab8
	call	UiPaint_Ordinals	; F5C0BC  call 0xf5bb00
	ld	(LCD_CurrentLayer:16), 0	; F5C0C0  ld (0x2540),0x00
	ld	xiy, DL_P0siti0n	; F5C0C5  ld XIY,0x00f03441
	ld	xix, DLText_FixMove	; F5C0CA  ld XIX,0x00f03478
	call	T_DisplayListB_Run	; F5C0CF  call 0xf417f4
	ret	; F5C0D3  ret
; ToneEditPage_A4_Paint: Dispatch_Code80_PaintTable[code 0xA4] -- Dispatch_Code80_Bracketed, the full paint.
ToneEditPage_A4_Paint:
	call	Draw_M0delingSoundEditToneDriver	; F5C0D4  call 0xf5c338
	call	DisplayList_Run_ResoDriverNatorPositionMovement_Page22P0siti0nM0vementWidth	; F5C0D8  call 0xf5c374
	ld	xiy, DL_Page22P0siti0nM0vementWidth	; F5C0DC  ld XIY,0x00f02942
	ld	xix, DL_Page13FitMutKeyDeResoTing	; F5C0E1  ld XIX,0x00f02a46
	call	T_DisplayList_Run	; F5C0E6  call 0xf417f0
	call	SoundEdit_PaintPageLabelBackdrop	; F5C0EA  call 0xf5bfbd
	call	UiPaint_Solo	; F5C0EE  call 0xf5bab8
	call	UiPaint_Ordinals	; F5C0F2  call 0xf5bb00
	ld	(LCD_CurrentLayer:16), 0	; F5C0F6  ld (0x2540),0x00
	ld	xiy, ToneEditPage_A4_Paint_DL	; F5C0FB  ld XIY,0x00f03498
	ld	xix, DLBRecordPtrs_F034C6	; F5C100  ld XIX,0x00f034c6
	call	T_DisplayListB_Run	; F5C105  call 0xf417f4
	ret	; F5C109  ret
; ToneEditPage_A5_Paint: Dispatch_Code80_PaintTable[code 0xA5] -- Dispatch_Code80_Bracketed, the full paint.
ToneEditPage_A5_Paint:
	call	DisplayList_Run_M0delingSoundEditToneDriver	; F5C10A  call 0xf5c34c
	call	DisplayList_Run_MainDriverResonatorSubResonator_Page23TouchDepthSubFittingMutingSubGain	; F5C10E  call 0xf5c388
	ld	xiy, DL_Page13FitMutKeyDeResoTing	; F5C112  ld XIY,0x00f02a46
	ld	xix, DL_MainDriverResonatorSubResonator	; F5C117  ld XIX,0x00f02b47
	call	T_DisplayList_Run	; F5C11C  call 0xf417f0
	call	SoundEdit_PaintPageLabelBackdrop	; F5C120  call 0xf5bfbd
	call	UiPaint_Solo	; F5C124  call 0xf5bab8
	call	UiPaint_Ordinals	; F5C128  call 0xf5bb00
	ld	(LCD_CurrentLayer:16), 0	; F5C12C  ld (0x2540),0x00
	ld	xiy, ToneEditPage_A5_Paint_DL	; F5C131  ld XIY,0x00f034de
	ld	xix, DLRecordPtrs_F0355D	; F5C136  ld XIX,0x00f0355d
	call	T_DisplayListB_Run	; F5C13B  call 0xf417f4
	call	ToneEditPage_PaintMainAndSubFocus	; F5C13F  call 0xf5c144
	ret	; F5C143  ret

; --------------------------------------------------------------------------
; ToneEditPage_PaintMainAndSubFocus
; Called from: in-module: 0xF5C13F 0xF5C1A7 0xF5C20B 0xF5CD67 0xF5CDBF
;              0xF5CDEB
; Touches: (0x2540) (0x27B5) (0x27F5)  |  0xF02D08 0xF02DFB 0xF02EF9
;          0xF02F22 0xF03595 0xF0359F +15 more
; Calls:   T_DisplayList_Run T_DisplayListB_Run DisplayList_Run_M0delingSoundEditToneDriver DisplayList_Run_MainDriverResonatorSubResonator_Page23TouchDepthSubFittingMutingSubGain SoundEdit_PaintPageLabelBackdrop 0xF5BAB8
;          0xF5BB00 ToneEditPage_PaintMainAndSubFocus ToneEditPage_A8_PaintField5Switch ModelingPage_PaintFields11And12
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C144 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ToneEditPage_PaintMainAndSubFocus: Unless ModelingPage_Fields[15] == 1 (a single row has focus), fills in layer 1
;   the 'MAIN&SUB' legend box (253,218)-(305,228) and the OTHER resonator row's box, DLTable_F035BA[Fields[0]&1] --
;   the mirror of DLTable_F035AA, which the page lists use for the focused row -- so both rows show as selected.
;   Basis: callers + body -- called by the A5/A6/A7 (PAGE1/3..3/3) paint and field-0 repaint routines;
;   ToneEditPage_ToggleRowFocus flips Fields[15]. (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
ToneEditPage_PaintMainAndSubFocus:
	cp	(ModelingPage_Fields+15:16), 0x01	; F5C144  cp (0x27b5),0x01
	jr	z, ToneEditPage_PaintMainAndSubFocus_Return	; F5C149  jr Z,0xf5c171
	ld	(LCD_CurrentLayer:16), 1	; F5C14B  ld (0x2540),0x01
	ld	xiy, ToneEditPage_PaintMainAndSubFocus_DL1	; F5C150  ld XIY,0x00f03595
	ld	xix, ToneEditPage_PaintMainAndSubFocus_DL2	; F5C155  ld XIX,0x00f0359f
	call	T_DisplayList_Run	; F5C15A  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 1	; F5C15E  ld (0x2540),0x01
	ld	xiy, ToneEditPage_PaintMainAndSubFocus_DL2	; F5C163  ld XIY,0x00f0359f
	ld	xix, DLTable_F035AA	; F5C168  ld XIX,0x00f035aa
	call	T_DisplayListB_Run	; F5C16D  call 0xf417f4
ToneEditPage_PaintMainAndSubFocus_Return:
	ret	; F5C171  ret
; ToneEditPage_A6_Paint: Dispatch_Code80_PaintTable[code 0xA6] -- Dispatch_Code80_Bracketed, the full paint.
ToneEditPage_A6_Paint:
	call	DisplayList_Run_M0delingSoundEditToneDriver	; F5C172  call 0xf5c34c
	call	DisplayList_Run_MainDriverResonatorSubResonator_Page23TouchDepthSubFittingMutingSubGain	; F5C176  call 0xf5c388
	ld	xiy, DL_Page23TouchDepthSubFittingMutingSubGain	; F5C17A  ld XIY,0x00f02d08
	ld	xix, DL_MutingKeyFollowSlopeRange	; F5C17F  ld XIX,0x00f02dfb
	call	T_DisplayList_Run	; F5C184  call 0xf417f0
	call	SoundEdit_PaintPageLabelBackdrop	; F5C188  call 0xf5bfbd
	call	UiPaint_Solo	; F5C18C  call 0xf5bab8
	call	UiPaint_Ordinals	; F5C190  call 0xf5bb00
	ld	(LCD_CurrentLayer:16), 0	; F5C194  ld (0x2540),0x00
	ld	xiy, ToneEditPage_A6_Paint_DL	; F5C199  ld XIY,0x00f035ca
	ld	xix, Data_F03617	; F5C19E  ld XIX,0x00f03617
	call	T_DisplayListB_Run	; F5C1A3  call 0xf417f4
	call	ToneEditPage_PaintMainAndSubFocus	; F5C1A7  call 0xf5c144
	ret	; F5C1AB  ret
; ToneEditPage_A7_Paint: Dispatch_Code80_PaintTable[code 0xA7] -- Dispatch_Code80_Bracketed, the full paint.
ToneEditPage_A7_Paint:
	call	DisplayList_Run_M0delingSoundEditToneDriver	; F5C1AC  call 0xf5c34c
	call	DisplayList_Run_MainDriverResonatorSubResonator_Page23TouchDepthSubFittingMutingSubGain	; F5C1B0  call 0xf5c388
	cp	(0x27f5:16), 0x01	; F5C1B4  cp (0x27f5),0x01
	jr	z, ToneEditPage_A7_Paint_Skip	; F5C1B9  jr Z,0xf5c1de
	ld	xiy, DL_MutingKeyFollowSlopeRange	; F5C1BB  ld XIY,0x00f02dfb
	ld	xix, UiPaint_Ordinals_DL1	; F5C1C0  ld XIX,0x00f02f22
	call	T_DisplayList_Run	; F5C1C5  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F5C1C9  ld (0x2540),0x00
	ld	xiy, ToneEditPage_A7_Paint_DL1	; F5C1CE  ld XIY,0x00f03633
	ld	xix, DLRecordPtrs_F036C2	; F5C1D3  ld XIX,0x00f036c2
	call	T_DisplayListB_Run	; F5C1D8  call 0xf417f4
	jr	ToneEditPage_A7_Paint_Join	; F5C1DC  jr T,0xf5c1ff
ToneEditPage_A7_Paint_Skip:
	ld	xiy, DL_Page33ResoMode	; F5C1DE  ld XIY,0x00f02ef9
	ld	xix, UiPaint_Ordinals_DL1	; F5C1E3  ld XIX,0x00f02f22
	call	T_DisplayList_Run	; F5C1E8  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F5C1EC  ld (0x2540),0x00
	ld	xiy, ToneEditPage_A7_Paint_DL2	; F5C1F1  ld XIY,0x00f036a3
	ld	xix, DLRecordPtrs_F036C2	; F5C1F6  ld XIX,0x00f036c2
	call	T_DisplayListB_Run	; F5C1FB  call 0xf417f4
ToneEditPage_A7_Paint_Join:
	call	SoundEdit_PaintPageLabelBackdrop	; F5C1FF  call 0xf5bfbd
	call	UiPaint_Solo	; F5C203  call 0xf5bab8
	call	UiPaint_Ordinals	; F5C207  call 0xf5bb00
	call	ToneEditPage_PaintMainAndSubFocus	; F5C20B  call 0xf5c144
	ret	; F5C20F  ret
Draw_Serial:
	ldw	bc, ModelingPage_Fields+4	; F5C210  ld BC,0x27aa
	ld	d, (xbc)	; F5C213  ld D,(XBC)
	cp	d, 0:i3	; F5C215  cp D,0
	jr	z, Draw_Serial_Skip2	; F5C217  jr Z,0xf5c237
	ld	xiy, DL_Serial	; F5C219  ld XIY,0x00f064a9
	ld	xix, DL_Parallel	; F5C21E  ld XIX,0x00f064c6
	call	T_DisplayList_Run	; F5C223  call 0xf417f0
	ld	xiy, Draw_Serial_DL1	; F5C227  ld XIY,0x00f06576
	ld	xix, Draw_Serial_DL1 + 0x11	; F5C22C  ld XIX,0x00f06587
	call	T_DisplayListB_Run	; F5C231  call 0xf417f4
	jr	Draw_Serial_Join2	; F5C235  jr T,0xf5c253
Draw_Serial_Skip2:
	ld	xiy, DL_Parallel	; F5C237  ld XIY,0x00f064c6
	ld	xix, Draw_Serial_DL2	; F5C23C  ld XIX,0x00f064e5
	call	T_DisplayList_Run	; F5C241  call 0xf417f0
	ld	xiy, Draw_Serial_DL1	; F5C245  ld XIY,0x00f06576
	ld	xix, DLText_OffMainSub1To3	; F5C24A  ld XIX,0x00f06598
	call	T_DisplayListB_Run	; F5C24F  call 0xf417f4
Draw_Serial_Join2:
	ld	(LCD_CurrentLayer:16), 0	; F5C253  ld (0x2540),0x00
	ld	xiy, DL_EffectBlockEff1Eff2RevMain	; F5C258  ld XIY,0x00f06224
	ld	xix, ToneEditPage_A8_PaintField5Switch_DL1	; F5C25D  ld XIX,0x00f06481
	call	T_DisplayList_Run	; F5C262  call 0xf417f0
	ld	xiy, Draw_Serial_DL2	; F5C266  ld XIY,0x00f064e5
	ld	xix, Data_F06562	; F5C26B  ld XIX,0x00f06562
	call	T_DisplayListB_Run	; F5C270  call 0xf417f4
	call	ToneEditPage_A8_PaintField5Switch	; F5C274  call 0xf5c27d
	call	ModelingPage_PaintFields11And12	; F5C278  call 0xf5bf8a
	ret	; F5C27C  ret

; --------------------------------------------------------------------------
; ToneEditPage_A8_PaintField5Switch
; Called from: in-module: 0xF5C274 0xF5CE60
; Touches: (0x2540) (0x27AB) (0x27F5)  |  0xF022F7 0xF02329 0xF0245F
;          0xF02469 0xF06481 0xF06495 +7 more
; Calls:   T_DisplayList_Run Draw_M0delingSoundEditToneDriver Draw_ToneDriverResonator 0xF5BAB8 SoundEdit_PaintSlotOrdinals T_DisplayListB_Run
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C27D is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ToneEditPage_A8_PaintField5Switch: Layer 0: erases the 10x4 box at (0x4B,0x5B) and draws a horizontal stroke (closed
;   switch) when ModelingPage_Fields+5 = 1, else a diagonal one (open switch). Page A8's full paint (Draw_Serial) and
;   its field repaint for fields below 11 call it. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_c.json)
ToneEditPage_A8_PaintField5Switch:
	ld	(LCD_CurrentLayer:16), 0	; F5C27D  ld (0x2540),0x00
	cp	(ModelingPage_Fields+5:16), 0x01	; F5C282  cp (0x27ab),0x01
	jr	z, ToneEditPage_A8_PaintField5Switch_Skip	; F5C287  jr Z,0xf5c299
	ld	xiy, ToneEditPage_A8_PaintField5Switch_DL1	; F5C289  ld XIY,0x00f06481
	ld	xix, ToneEditPage_A8_PaintField5Switch_DL2	; F5C28E  ld XIX,0x00f06495
	call	T_DisplayList_Run	; F5C293  call 0xf417f0
	jr	ToneEditPage_A8_PaintField5Switch_Return	; F5C297  jr T,0xf5c2a7
ToneEditPage_A8_PaintField5Switch_Skip:
	ld	xiy, ToneEditPage_A8_PaintField5Switch_DL2	; F5C299  ld XIY,0x00f06495
	ld	xix, DL_Serial	; F5C29E  ld XIX,0x00f064a9
	call	T_DisplayList_Run	; F5C2A3  call 0xf417f0
ToneEditPage_A8_PaintField5Switch_Return:
	ret	; F5C2A7  ret
Draw_ToneTemplateLevelKeyTune:
	call	Draw_M0delingSoundEditToneDriver	; F5C2A8  call 0xf5c338
	call	Draw_ToneDriverResonator	; F5C2AC  call 0xf5c360
	ld	xiy, DL_ToneTemplateLevelKeyTune	; F5C2B0  ld XIY,0x00f02329
	ld	xix, Draw_ToneTemplateLevelKeyTune_DL1	; F5C2B5  ld XIX,0x00f0245f
	call	T_DisplayList_Run	; F5C2BA  call 0xf417f0
	cp	(0x27f5:16), 0x01	; F5C2BE  cp (0x27f5),0x01
	jr	z, Draw_ToneTemplateLevelKeyTune_Skip2	; F5C2C3  jr Z,0xf5c2e6
	ld	(LCD_CurrentLayer:16), 0	; F5C2C5  ld (0x2540),0x00
	ld	xiy, Draw_ToneTemplateLevelKeyTune_DL1	; F5C2CA  ld XIY,0x00f0245f
	ld	xix, DL_DriverDriverWaveformReso	; F5C2CF  ld XIX,0x00f02469
	call	T_DisplayList_Run	; F5C2D4  call 0xf417f0
	ld	xiy, Draw_ToneTemplateLevelKeyTune_DL2	; F5C2D8  ld XIY,0x00f022f7
	ld	xix, DL_ToneTemplateLevelKeyTune	; F5C2DD  ld XIX,0x00f02329
	call	T_DisplayList_Run	; F5C2E2  call 0xf417f0
Draw_ToneTemplateLevelKeyTune_Skip2:
	call	UiPaint_Solo	; F5C2E6  call 0xf5bab8
	call	SoundEdit_PaintSlotOrdinals	; F5C2EA  call 0xf5c39c
	cp	(0x27f5:16), 0x01	; F5C2EE  cp (0x27f5),0x01
	jr	z, Draw_ToneTemplateLevelKeyTune_Skip3	; F5C2F3  jr Z,0xf5c308
	ld	(LCD_CurrentLayer:16), 0	; F5C2F5  ld (0x2540),0x00
	ld	xiy, Draw_ToneTemplateLevelKeyTune_DL3	; F5C2FA  ld XIY,0x00f33a71
	ld	xix, Data_F33B8C	; F5C2FF  ld XIX,0x00f33b8c
	call	T_DisplayListB_Run	; F5C304  call 0xf417f4
Draw_ToneTemplateLevelKeyTune_Skip3:
	ld	(LCD_CurrentLayer:16), 0	; F5C308  ld (0x2540),0x00
	ld	xiy, Draw_ToneTemplateLevelKeyTune_DL3	; F5C30D  ld XIY,0x00f33a71
	ld	xix, Draw_ToneTemplateLevelKeyTune_DL3 + 0x4C	; F5C312  ld XIX,0x00f33abd
	call	T_DisplayListB_Run	; F5C317  call 0xf417f4
	ld	xiy, Draw_ToneTemplateLevelKeyTune_DL4	; F5C31B  ld XIY,0x00f33b09
	ld	xix, Draw_ToneTemplateLevelKeyTune_DL4 + 0x3C	; F5C320  ld XIX,0x00f33b45
	call	T_DisplayListB_Run	; F5C325  call 0xf417f4
	ld	xiy, Draw_ToneTemplateLevelKeyTune_DL5	; F5C329  ld XIY,0x00f33b81
	ld	xix, Data_F33B8C	; F5C32E  ld XIX,0x00f33b8c
	call	T_DisplayListB_Run	; F5C333  call 0xf417f4
	ret	; F5C337  ret

; --------------------------------------------------------------------------
; Draw_M0delingSoundEditToneDriver
; Called from: in-module: 0xF5BFC7 0xF5C06C 0xF5C09E 0xF5C0D4 0xF5C2A8
; Touches: (0x2540)  |  0xF01F96 0xF02064
; Calls:   T_DisplayList_Run
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C338 is an instruction boundary.
; Name:    from the one text-named display list it STARTS, DL_M0delingSoundEditToneDriver (the
;          interpreter's XIY or last-pushed operand); it claims that list, not
;          a screen or a purpose (scripts/renaming/rename_wsa1_dl_drawers.py).
; Unknown: what the routine is FOR.
; --------------------------------------------------------------------------
Draw_M0delingSoundEditToneDriver:
	ld	(LCD_CurrentLayer:16), 0	; F5C338  ld (0x2540),0x00
	ld	xiy, DL_M0delingSoundEditToneDriver	; F5C33D  ld XIY,0x00f01f96
	ld	xix, ToneEditPage_A0_Paint_DL1	; F5C342  ld XIX,0x00f02064
	call	T_DisplayList_Run	; F5C347  call 0xf417f0
	ret	; F5C34B  ret

; --------------------------------------------------------------------------
; DisplayList_Run_M0delingSoundEditToneDriver
; Called from: in-module: 0xF5C10A 0xF5C172 0xF5C1AC
; Touches: (0x2540)  |  0xF01F96 0xF0203E
; Calls:   T_DisplayList_Run
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C34C is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
DisplayList_Run_M0delingSoundEditToneDriver:
	ld	(LCD_CurrentLayer:16), 0	; F5C34C  ld (0x2540),0x00
	ld	xiy, DL_M0delingSoundEditToneDriver	; F5C351  ld XIY,0x00f01f96
	ld	xix, DL_M0delingSoundEditToneDriver + 0xA8	; F5C356  ld XIX,0x00f0203e
	call	T_DisplayList_Run	; F5C35B  call 0xf417f0
	ret	; F5C35F  ret

; --------------------------------------------------------------------------
; Draw_ToneDriverResonator
; Called from: in-module: 0xF5BFCB 0xF5C2AC
; Touches: (0x2540)  |  0xF021E4 0xF02295
; Calls:   T_DisplayList_Run
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C360 is an instruction boundary.
; Name:    from the one text-named display list it STARTS, DL_ToneDriverResonator (the
;          interpreter's XIY or last-pushed operand); it claims that list, not
;          a screen or a purpose (scripts/renaming/rename_wsa1_dl_drawers.py).
; Unknown: what the routine is FOR.
; --------------------------------------------------------------------------
Draw_ToneDriverResonator:
	ld	(LCD_CurrentLayer:16), 0	; F5C360  ld (0x2540),0x00
	ld	xiy, DL_ToneDriverResonator	; F5C365  ld XIY,0x00f021e4
	ld	xix, DL_F02295	; F5C36A  ld XIX,0x00f02295
	call	T_DisplayList_Run	; F5C36F  call 0xf417f0
	ret	; F5C373  ret

; --------------------------------------------------------------------------
; DisplayList_Run_ResoDriverNatorPositionMovement_Page22P0siti0nM0vementWidth
; Called from: in-module: 0xF5C0A2 0xF5C0D8
; Touches: (0x2540)  |  0xF027AF 0xF02942
; Calls:   T_DisplayList_Run
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C374 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
DisplayList_Run_ResoDriverNatorPositionMovement_Page22P0siti0nM0vementWidth:
	ld	(LCD_CurrentLayer:16), 0	; F5C374  ld (0x2540),0x00
	ld	xiy, DL_ResoDriverNatorPositionMovement	; F5C379  ld XIY,0x00f027af
	ld	xix, DL_Page22P0siti0nM0vementWidth	; F5C37E  ld XIX,0x00f02942
	call	T_DisplayList_Run	; F5C383  call 0xf417f0
	ret	; F5C387  ret

; --------------------------------------------------------------------------
; DisplayList_Run_MainDriverResonatorSubResonator_Page23TouchDepthSubFittingMutingSubGain
; Called from: in-module: 0xF5C10E 0xF5C176 0xF5C1B0
; Touches: (0x2540)  |  0xF02B47 0xF02D08
; Calls:   T_DisplayList_Run
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C388 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
DisplayList_Run_MainDriverResonatorSubResonator_Page23TouchDepthSubFittingMutingSubGain:
	ld	(LCD_CurrentLayer:16), 0	; F5C388  ld (0x2540),0x00
	ld	xiy, DL_MainDriverResonatorSubResonator	; F5C38D  ld XIY,0x00f02b47
	ld	xix, DL_Page23TouchDepthSubFittingMutingSubGain	; F5C392  ld XIX,0x00f02d08
	call	T_DisplayList_Run	; F5C397  call 0xf417f0
	ret	; F5C39B  ret

; --------------------------------------------------------------------------
; SoundEdit_PaintSlotOrdinals
; Called from: in-module: 0xF5C2EA 0xF5C4E7 0xF5C6EF 0xF5D466
; Touches: (0x2540) (0x27A4) (0x27F5)  |  0xF039D9 0xF039E3 0xF039ED
;          0xF03A09 0xF03A51
; Calls:   T_DisplayList_Run
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C39C is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEdit_PaintSlotOrdinals: Layer 0: runs 2 (when (0x27F5) == 1, drum kit) or 4 marker records of SoundEdit_PaintSlotOrdinals_DL, then
;   for each slot C = 4..1 (or 2..1) draws its '1st'..'4th' ordinal from selector block 0 (plain text) when bit 2C-2
;   of (0x27A4) is set (Var27A4_SlotEnabled), else from block 1 (Data_F0191A 24x10 dithered bitmaps). Basis: callers +
;   body -- the last step of four SOUND EDIT page painters; same loop as UiPaint_Ordinals. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_d.json)
SoundEdit_PaintSlotOrdinals:
	cp	(0x27f5:16), 0x01	; F5C39C  cp (0x27f5),0x01
	jr	nz, SoundEdit_PaintSlotOrdinals_Skip	; F5C3A1  jr NZ,0xf5c3ba
	ld	(LCD_CurrentLayer:16), 0	; F5C3A3  ld (0x2540),0x00
	ld	xiy, SoundEdit_PaintSlotOrdinals_DL	; F5C3A8  ld XIY,0x00f039d9
	ld	xix, SoundEdit_PaintSlotOrdinals_DL + 0xA	; F5C3AD  ld XIX,0x00f039e3
	call	T_DisplayList_Run	; F5C3B2  call 0xf417f0
	ld	c, 2:opc	; F5C3B6  ld C,0x02
	jr	SoundEdit_PaintSlotOrdinals_Join	; F5C3B8  jr T,0xf5c3cf
SoundEdit_PaintSlotOrdinals_Skip:
	ld	(LCD_CurrentLayer:16), 0	; F5C3BA  ld (0x2540),0x00
	ld	xiy, SoundEdit_PaintSlotOrdinals_DL	; F5C3BF  ld XIY,0x00f039d9
	ld	xix, Data_F039ED	; F5C3C4  ld XIX,0x00f039ed
	call	T_DisplayList_Run	; F5C3C9  call 0xf417f0
	ld	c, 4:opc	; F5C3CD  ld C,0x04
SoundEdit_PaintSlotOrdinals_Join:
	ld	w, (10148:16)	; F5C3CF  ld W,(0x27a4)
	ld	a, c	; F5C3D3  ld A,C
	sla	a, 1	; F5C3D5  sla 0x01,A
	dec	1, a	; F5C3D8  dec 1,A
	.byte 0xC8, 0xFF	; F5C3DA  srl A,W   [llvm-mc cannot encode this]
	jr	c, SoundEdit_PaintSlotOrdinals_Skip2	; F5C3DC  jr C,0xf5c400
	push	c	; F5C3DE  push C
	xor	b, b	; F5C3E0  xor B,B
	sla	bc, 2	; F5C3E2  sla 0x02,BC
	ld	xiz, Data_F03A51	; F5C3E5  ld XIZ,0x00f03a51
	ld	xiy, (xiz+bc)	; F5C3EA  ld XIY,(XIZ+BC)
	add	bc, 4	; F5C3EF  add BC,0x0004
	ld	xix, (xiz+bc)	; F5C3F3  ld XIX,(XIZ+BC)
	call	T_DisplayList_Run	; F5C3F8  call 0xf417f0
	pop	c	; F5C3FC  pop C
	jr	SoundEdit_PaintSlotOrdinals_Join2	; F5C3FE  jr T,0xf5c420
SoundEdit_PaintSlotOrdinals_Skip2:
	push	c	; F5C400  push C
	xor	b, b	; F5C402  xor B,B
	sla	bc, 2	; F5C404  sla 0x02,BC
	ld	xiz, Data_F039ED + 0x1C	; F5C407  ld XIZ,0x00f03a09
	ld	xiy, (xiz+bc)	; F5C40C  ld XIY,(XIZ+BC)
	add	bc, 4	; F5C411  add BC,0x0004
	ld	xix, (xiz+bc)	; F5C415  ld XIX,(XIZ+BC)
	call	T_DisplayList_Run	; F5C41A  call 0xf417f0
	pop	c	; F5C41E  pop C
SoundEdit_PaintSlotOrdinals_Join2:
	djnz8	c, -84	; F5C420  djnz C,0xf5c3cf
	ret	; F5C423  ret

; --------------------------------------------------------------------------
; ToneEditPage_A0_PaintSlotOrdinals
; Called from: in-module: 0xF5C063 0xF5CB8B
; Touches: (0x2540) (0x27A4) (0x27F5)  |  0xF039A9 0xF039D9 0xF03C05
;          0xF03C7D
; Calls:   T_DisplayList_Run
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C424 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ToneEditPage_A0_PaintSlotOrdinals: Layer 0: for slot C = 4..1 (2..1 when (0x27F5) == 1) draws the slot's column head
;   from selector block 6 (icon + '1st'..'4th' text) when bit 2C-2 of (0x27A4) is set (Var27A4_SlotEnabled), else from
;   block 7 (the other icon and the dithered Data_F0191A ordinal). Basis: callers + body -- the ToneEditPage_A0
;   painter and repaint; the same loop as SoundEdit_PaintSlotOrdinals over another layout. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_d.json)
ToneEditPage_A0_PaintSlotOrdinals:
	ld	(LCD_CurrentLayer:16), 0	; F5C424  ld (0x2540),0x00
	cp	(0x27f5:16), 0x01	; F5C429  cp (0x27f5),0x01
	jr	nz, ToneEditPage_A0_PaintSlotOrdinals_Skip	; F5C42E  jr NZ,0xf5c434
	ld	c, 2:opc	; F5C430  ld C,0x02
	jr	ToneEditPage_A0_PaintSlotOrdinals_Join	; F5C432  jr T,0xf5c436
ToneEditPage_A0_PaintSlotOrdinals_Skip:
	ld	c, 4:opc	; F5C434  ld C,0x04
ToneEditPage_A0_PaintSlotOrdinals_Join:
	ld	w, (10148:16)	; F5C436  ld W,(0x27a4)
	ld	a, c	; F5C43A  ld A,C
	sla	a, 1	; F5C43C  sla 0x01,A
	dec	1, a	; F5C43F  dec 1,A
	.byte 0xC8, 0xFF	; F5C441  srl A,W   [llvm-mc cannot encode this]
	jr	c, ToneEditPage_A0_PaintSlotOrdinals_Skip2	; F5C443  jr C,0xf5c467
	push	c	; F5C445  push C
	xor	b, b	; F5C447  xor B,B
	sla	bc, 2	; F5C449  sla 0x02,BC
	ld	xiz, Data_F03C7D	; F5C44C  ld XIZ,0x00f03c7d
	ld	xiy, (xiz+bc)	; F5C451  ld XIY,(XIZ+BC)
	add	bc, 4	; F5C456  add BC,0x0004
	ld	xix, (xiz+bc)	; F5C45A  ld XIX,(XIZ+BC)
	call	T_DisplayList_Run	; F5C45F  call 0xf417f0
	pop	c	; F5C463  pop C
	jr	ToneEditPage_A0_PaintSlotOrdinals_Join2	; F5C465  jr T,0xf5c487
ToneEditPage_A0_PaintSlotOrdinals_Skip2:
	push	c	; F5C467  push C
	xor	b, b	; F5C469  xor B,B
	sla	bc, 2	; F5C46B  sla 0x02,BC
	ld	xiz, Data_F03C05	; F5C46E  ld XIZ,0x00f03c05
	ld	xiy, (xiz+bc)	; F5C473  ld XIY,(XIZ+BC)
	add	bc, 4	; F5C478  add BC,0x0004
	ld	xix, (xiz+bc)	; F5C47C  ld XIX,(XIZ+BC)
	call	T_DisplayList_Run	; F5C481  call 0xf417f0
	pop	c	; F5C485  pop C
ToneEditPage_A0_PaintSlotOrdinals_Join2:
	djnz8	c, -84	; F5C487  djnz C,0xf5c436
	ret	; F5C48A  ret
	ld	(LCD_CurrentLayer:16), 0	; F5C48B  ld (0x2540),0x00
	ld	xiy, DL_T0neSelectSoundEdit	; F5C490  ld XIY,0x00f039a9
	ld	xix, SoundEdit_PaintSlotOrdinals_DL	; F5C495  ld XIX,0x00f039d9
	call	T_DisplayList_Run	; F5C49A  call 0xf417f0
	ret	; F5C49E  ret

; --------------------------------------------------------------------------
; DisplayList_Run_T0neLayerSoundEditTrigGer
; Called from: in-module: 0xF5D40E
; Touches: (0x2540)  |  0xF03892 0xF03943
; Calls:   T_DisplayList_Run
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C49F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
DisplayList_Run_T0neLayerSoundEditTrigGer:
	ld	(LCD_CurrentLayer:16), 0	; F5C49F  ld (0x2540),0x00
	ld	xiy, DL_T0neLayerSoundEditTrigGer	; F5C4A4  ld XIY,0x00f03892
	ld	xix, DL_T0neLayerSoundEditTrigGer + 0xB1	; F5C4A9  ld XIX,0x00f03943
	call	T_DisplayList_Run	; F5C4AE  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F5C4B2  ld (0x2540),0x00
	ret	; F5C4B7  ret

; --------------------------------------------------------------------------
; DisplayList_Run_T0neLayerSoundEditTrigGer_T0neSelectSoundEdit
; Called from: in-module: 0xF5D4C3 0xF5D519
; Touches: (0x2540)  |  0xF03892 0xF039A9 0xF03D68 0xF03F31 0xF051C2
;          0xF05286
; Calls:   T_DisplayList_Run Draw_PitchSoundEditEnvPitchLf0 0xF5BAB8 SoundEdit_PaintSlotOrdinals T_DisplayListB_Run
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C4B8 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
DisplayList_Run_T0neLayerSoundEditTrigGer_T0neSelectSoundEdit:
	ld	(LCD_CurrentLayer:16), 0	; F5C4B8  ld (0x2540),0x00
	ld	xiy, DL_T0neLayerSoundEditTrigGer	; F5C4BD  ld XIY,0x00f03892
	ld	xix, DL_T0neSelectSoundEdit	; F5C4C2  ld XIX,0x00f039a9
	call	T_DisplayList_Run	; F5C4C7  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F5C4CB  ld (0x2540),0x00
	ret	; F5C4D0  ret
Draw_KeyDeToneKeyScalingShift:
	call	Draw_PitchSoundEditEnvPitchLf0	; F5C4D1  call 0xf5c4ff
	ld	xiy, DL_KeyDeToneKeyScalingShift	; F5C4D5  ld XIY,0x00f03d68
	ld	xix, DL_StartPitchStopPitchTotal	; F5C4DA  ld XIX,0x00f03f31
	call	T_DisplayList_Run	; F5C4DF  call 0xf417f0
	call	UiPaint_Solo	; F5C4E3  call 0xf5bab8
	call	SoundEdit_PaintSlotOrdinals	; F5C4E7  call 0xf5c39c
	ld	(LCD_CurrentLayer:16), 0	; F5C4EB  ld (0x2540),0x00
	ld	xiy, Draw_KeyDeToneKeyScalingShift_DL	; F5C4F0  ld XIY,0x00f051c2
	ld	xix, Data_F05286	; F5C4F5  ld XIX,0x00f05286
	call	T_DisplayListB_Run	; F5C4FA  call 0xf417f4
	ret	; F5C4FE  ret

; --------------------------------------------------------------------------
; Draw_PitchSoundEditEnvPitchLf0
; Called from: in-module: 0xF5C4D1 0xF5C513 0xF5D55F 0xF5D57A
; Touches: (0x2540)  |  0xF03C95 0xF03D4A
; Calls:   T_DisplayList_Run Draw_PitchSoundEditEnvPitchLf0
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C4FF is an instruction boundary.
; Name:    from the one text-named display list it STARTS, DL_PitchSoundEditEnvPitchLf0 (the
;          interpreter's XIY or last-pushed operand); it claims that list, not
;          a screen or a purpose (scripts/renaming/rename_wsa1_dl_drawers.py).
; Unknown: what the routine is FOR.
; --------------------------------------------------------------------------
Draw_PitchSoundEditEnvPitchLf0:
	ld	(LCD_CurrentLayer:16), 0	; F5C4FF  ld (0x2540),0x00
	ld	xiy, DL_PitchSoundEditEnvPitchLf0	; F5C504  ld XIY,0x00f03c95
	ld	xix, DL_F03D4A	; F5C509  ld XIX,0x00f03d4a
	call	T_DisplayList_Run	; F5C50E  call 0xf417f0
	ret	; F5C512  ret
; SoundEditPitchLfo_Paint: Dispatch_Code80_PaintTable[code 0x8A] -- Dispatch_Code80_Bracketed, the full paint.
SoundEditPitchLfo_Paint:
	call	Draw_PitchSoundEditEnvPitchLf0	; F5C513  call 0xf5c4ff

; --------------------------------------------------------------------------
; Draw_Lf01Lf02Lf03Lf04Lf0WaveDelay
; Called from: in-module: 0xF5D61D 0xF5D626
; Touches: (0x2540)  |  0xF053B6 0xF05407 0xF06601 0xF067A6
; Calls:   T_DisplayList_Run SoundEditLfo_PaintOrdinals 0xF5BAB8 SoundEditLfo_DrawRowLinks SoundEditLfo_DrawField0RowLine T_DisplayListB_Run
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C517 is an instruction boundary.
; Name:    from the one text-named display list it STARTS, DL_Lf01Lf02Lf03Lf04Lf0WaveDelay (the
;          interpreter's XIY or last-pushed operand); it claims that list, not
;          a screen or a purpose (scripts/renaming/rename_wsa1_dl_drawers.py).
; Unknown: what the routine is FOR.
; --------------------------------------------------------------------------
Draw_Lf01Lf02Lf03Lf04Lf0WaveDelay:
	ld	xiy, DL_Lf01Lf02Lf03Lf04Lf0WaveDelay	; F5C517  ld XIY,0x00f06601
	ld	xix, DL_Lf01Lf02Lf03Lf04Lf0WaveDelay + 0x1A5	; F5C51C  ld XIX,0x00f067a6
	call	T_DisplayList_Run	; F5C521  call 0xf417f0
	call	SoundEditLfo_PaintOrdinals	; F5C525  call 0xf5c549
	call	UiPaint_Solo	; F5C529  call 0xf5bab8
	call	SoundEditLfo_DrawRowLinks	; F5C52D  call 0xf5c5a5
	call	SoundEditLfo_DrawField0RowLine	; F5C531  call 0xf5cfa4
	ld	(LCD_CurrentLayer:16), 0	; F5C535  ld (0x2540),0x00
	ld	xiy, DL_F053B6	; F5C53A  ld XIY,0x00f053b6
	ld	xix, DL_F05407	; F5C53F  ld XIX,0x00f05407
	call	T_DisplayListB_Run	; F5C544  call 0xf417f4
	ret	; F5C548  ret

; --------------------------------------------------------------------------
; SoundEditLfo_PaintOrdinals
; Called from: in-module: 0xF5C525 0xF5CF70
; Touches: (0x2540) (0x27A4)  |  0xF3281C 0xF32864
; Calls:   T_DisplayList_Run
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C549 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditLfo_PaintOrdinals: Paints the four ordinal rows of the LFO page on layer 0: slot n's bit 2n-2 of (0x27A4)
;   set -> the text record '1st'..'4th' (DLRecordPtrs_F3281C), clear -> bitmap form (Data_F32864 lists of
;   Data_F0191A). Four-row form of UiPaint_Ordinals; called by the LFO page painter and SoundEditLfo_RepaintField's
;   whole-page case. Basis: callers + body + sibling. (notes/naming-pilot-2026-10-06/proposals_wave2_e.json)
SoundEditLfo_PaintOrdinals:
	ld	(LCD_CurrentLayer:16), 0	; F5C549  ld (0x2540),0x00
	ld	c, 4:opc	; F5C54E  ld C,0x04
	ld	w, (10148:16)	; F5C550  ld W,(0x27a4)
	ld	a, c	; F5C554  ld A,C
	sla	a, 1	; F5C556  sla 0x01,A
	dec	1, a	; F5C559  dec 1,A
	.byte 0xC8, 0xFF	; F5C55B  srl A,W   [llvm-mc cannot encode this]
	jr	c, SoundEditLfo_PaintOrdinals_Skip	; F5C55D  jr C,0xf5c581
	push	c	; F5C55F  push C
	xor	b, b	; F5C561  xor B,B
	sla	bc, 2	; F5C563  sla 0x02,BC
	ld	xiz, Data_F32864	; F5C566  ld XIZ,0x00f32864
	ld	xiy, (xiz+bc)	; F5C56B  ld XIY,(XIZ+BC)
	add	bc, 4	; F5C570  add BC,0x0004
	ld	xix, (xiz+bc)	; F5C574  ld XIX,(XIZ+BC)
	call	T_DisplayList_Run	; F5C579  call 0xf417f0
	pop	c	; F5C57D  pop C
	jr	SoundEditLfo_PaintOrdinals_Join	; F5C57F  jr T,0xf5c5a1
SoundEditLfo_PaintOrdinals_Skip:
	push	c	; F5C581  push C
	xor	b, b	; F5C583  xor B,B
	sla	bc, 2	; F5C585  sla 0x02,BC
	ld	xiz, DLRecordPtrs_F3281C	; F5C588  ld XIZ,0x00f3281c
	ld	xiy, (xiz+bc)	; F5C58D  ld XIY,(XIZ+BC)
	add	bc, 4	; F5C592  add BC,0x0004
	ld	xix, (xiz+bc)	; F5C596  ld XIX,(XIZ+BC)
	call	T_DisplayList_Run	; F5C59B  call 0xf417f0
	pop	c	; F5C59F  pop C
SoundEditLfo_PaintOrdinals_Join:
	djnz8	c, -84	; F5C5A1  djnz C,0xf5c550
	ret	; F5C5A4  ret

; --------------------------------------------------------------------------
; SoundEditLfo_DrawRowLinks
; Called from: in-module: 0xF5C52D 0xF5CF52 0xF5CF78
; Touches: (0x2540) (0x27F5)  |  0x000001 0x000007 0x00000A 0x000014
;          0x0027AB 0xF0417E +17 more
; Calls:   T_DisplayList_Run T_DisplayListB_RunOne SoundEditAmp_PaintHeader SoundEdit_PaintPageLabelBackdrop 0xF5BAB8 SoundEdit_PaintSlotOrdinals
;          TouchCurve_DrawCurrentSlot T_DisplayListB_Run
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C5A5 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditLfo_DrawRowLinks: LFO page: erases the link area (EraseRect on layers 1/0/2), then for each LF01-LF04 row
;   whose ModelingPage_Fields[row+5] has bit 5 set draws its box, glyph and readouts and the line from the row to the
;   LFO in bits 7-6 (SoundEditLfo_CycleLfoState stores selected LFO - 1 there with bit 5). Basis: callers + body +
;   writer. (notes/naming-pilot-2026-10-06/proposals_wave2_f.json)
SoundEditLfo_DrawRowLinks:
	ld	(LCD_CurrentLayer:16), 1	; F5C5A5  ld (0x2540),0x01
	ld	xiy, SoundEditLfo_DrawRowLinks_DL1	; F5C5AA  ld XIY,0x00f054a7
	ld	xix, DL_F054B1	; F5C5AF  ld XIX,0x00f054b1
	call	T_DisplayList_Run	; F5C5B4  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F5C5B8  ld (0x2540),0x00
	ld	xiy, SoundEditLfo_DrawRowLinks_DL2	; F5C5BD  ld XIY,0x00f054f7
	ld	xix, SoundEditLfo_DrawRowLinks_DL3	; F5C5C2  ld XIX,0x00f05501
	call	T_DisplayList_Run	; F5C5C7  call 0xf417f0
	ld	xiy, SoundEditLfo_DrawRowLinks_DL3	; F5C5CB  ld XIY,0x00f05501
	ld	xix, Data_F0550B	; F5C5D0  ld XIX,0x00f0550b
	call	T_DisplayList_Run	; F5C5D5  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 2	; F5C5D9  ld (0x2540),0x02
	ld	xiy, SoundEditLfo_DrawRowLinks_DL3	; F5C5DE  ld XIY,0x00f05501
	ld	xix, Data_F0550B	; F5C5E3  ld XIX,0x00f0550b
	call	T_DisplayList_Run	; F5C5E8  call 0xf417f0
	ld	c, 4:opc	; F5C5EC  ld C,0x04
	ld	xiy, ModelingPage_Fields+5	; F5C5EE  ld XIY,0x000027ab
SoundEditLfo_DrawRowLinks_Loop:
	ld	w, (xiy)	; F5C5F3  ld W,(XIY)
	and	w, 32	; F5C5F5  and W,0x20
	jrl	z, SoundEditLfo_DrawRowLinks_Skip	; F5C5F8  jrl Z,0xf5c6b2
	push	w	; F5C5FB  push W
	push	c	; F5C5FD  push C
	push	xiy	; F5C5FF  push XIY
	ld	d, 4:opc	; F5C600  ld D,0x04
	sub	d, c	; F5C602  sub D,C
	ld	e, d	; F5C604  ld E,D
	xor	d, d	; F5C606  xor D,D
	sla	de, 2	; F5C608  sla 0x02,DE
	ld	xiz, Data_F054D9	; F5C60B  ld XIZ,0x00f054d9
	ld	xiy, (xiz+de)	; F5C610  ld XIY,(XIZ+DE)
	pushw	de	; F5C615  push DE
	add	de, 4	; F5C616  add DE,0x0004
	ld	xix, (xiz+de)	; F5C61A  ld XIX,(XIZ+DE)
	call	T_DisplayList_Run	; F5C61F  call 0xf417f0
	popw	de	; F5C623  pop DE
	pop	xiy	; F5C624  pop XIY
	pop	c	; F5C625  pop C
	pop	w	; F5C627  pop W
	ld	(LCD_CurrentLayer:16), 0	; F5C629  ld (0x2540),0x00
	push	c	; F5C62E  push C
	push	xiy	; F5C630  push XIY
	ld	xiz, DLRecordPtrs_F0563B	; F5C631  ld XIZ,0x00f0563b
	ld	xiy, (xiz+de)	; F5C636  ld XIY,(XIZ+DE)
	ld	xix, xiy	; F5C63B  ld XIX,XIY
	add	xix, 7	; F5C63D  add XIX,0x00000007
	pushw	de	; F5C643  push DE
	call	T_DisplayList_Run	; F5C644  call 0xf417f0
	popw	de	; F5C648  pop DE
	pop	xiy	; F5C649  pop XIY
	pop	c	; F5C64A  pop C
	push	c	; F5C64C  push C
	push	xiy	; F5C64E  push XIY
	ld	a, (xiy)	; F5C64F  ld A,(XIY)
	and	a, 192	; F5C651  and A,0xc0
	srl	a, 6	; F5C654  srl 0x06,A
	xor	w, w	; F5C657  xor W,W
	mul	a, 10	; F5C659  mul A,0x0a
	ld	xiz, Data_F0550B + 0x104	; F5C65C  ld XIZ,0x00f0560f
	ld	xiy, (xiz+de)	; F5C661  ld XIY,(XIZ+DE)
	extz	xwa	; F5C666  extz XWA
	add	xiy, xwa	; F5C668  add XIY,XWA
	ld	xix, xiy	; F5C66A  ld XIX,XIY
	add	xix, 10	; F5C66C  add XIX,0x0000000a
	pushw	de	; F5C672  push DE
	call	T_DisplayList_Run	; F5C673  call 0xf417f0
	popw	de	; F5C677  pop DE
	pop	xiy	; F5C678  pop XIY
	pop	c	; F5C679  pop C
	push	c	; F5C67B  push C
	push	xiy	; F5C67D  push XIY
	ld	xiz, Data_F05459	; F5C67E  ld XIZ,0x00f05459
	ld	xiy, (xiz+de)	; F5C683  ld XIY,(XIZ+DE)
	pushw	de	; F5C688  push DE
	call	T_DisplayListB_RunOne	; F5C689  call 0xf41830
	popw	de	; F5C68D  pop DE
	pop	xiy	; F5C68E  pop XIY
	pop	c	; F5C68F  pop C
	ld	(LCD_CurrentLayer:16), 2	; F5C691  ld (0x2540),0x02
	push	c	; F5C696  push C
	push	xiy	; F5C698  push XIY
	ld	xiz, Data_F32864 + 0x18	; F5C699  ld XIZ,0x00f3287c
	ld	xiy, (xiz+de)	; F5C69E  ld XIY,(XIZ+DE)
	ld	xix, xiy	; F5C6A3  ld XIX,XIY
	add	xix, 20	; F5C6A5  add XIX,0x00000014
	call	T_DisplayList_Run	; F5C6AB  call 0xf417f0
	pop	xiy	; F5C6AF  pop XIY
	pop	c	; F5C6B0  pop C
SoundEditLfo_DrawRowLinks_Skip:
	add	xiy, 1	; F5C6B2  add XIY,0x00000001
	dec	1, c	; F5C6B8  dec 1,C
	jrl	nz, SoundEditLfo_DrawRowLinks_Loop	; F5C6BA  jrl NZ,0xf5c5f3
	ret	; F5C6BD  ret
Draw_Page12LevelTouchCurveLevel:
	call	SoundEditAmp_PaintHeader	; F5C6BE  call 0xf5c727
	cp	(0x27f5:16), 0x01	; F5C6C2  cp (0x27f5),0x01
	jr	z, Draw_Page12LevelTouchCurveLevel_Skip2	; F5C6C7  jr Z,0xf5c6dd
	call	SoundEdit_PaintPageLabelBackdrop	; F5C6C9  call 0xf5bfbd
	ld	xiy, DL_Page12LevelTouchCurveLevel	; F5C6CD  ld XIY,0x00f0417e
	ld	xix, DL_Page22KeyFollowSlopeRange	; F5C6D2  ld XIX,0x00f0426b
	call	T_DisplayList_Run	; F5C6D7  call 0xf417f0
	jr	Draw_Page12LevelTouchCurveLevel_Join	; F5C6DB  jr T,0xf5c6eb
Draw_Page12LevelTouchCurveLevel_Skip2:
	ld	xiy, DL_DelayLevelTouchCurveGroupDump	; F5C6DD  ld XIY,0x00f33573
	ld	xix, DL_KeyOffModeTouchAtkDecay1Sust1Decay2Sust2	; F5C6E2  ld XIX,0x00f336ce
	call	T_DisplayList_Run	; F5C6E7  call 0xf417f0
Draw_Page12LevelTouchCurveLevel_Join:
	call	UiPaint_Solo	; F5C6EB  call 0xf5bab8
	call	SoundEdit_PaintSlotOrdinals	; F5C6EF  call 0xf5c39c
	call	TouchCurve_DrawCurrentSlot	; F5C6F3  call 0xf5bdbb
	cp	(0x27f5:16), 0x01	; F5C6F7  cp (0x27f5),0x01
	jr	z, Draw_Page12LevelTouchCurveLevel_Skip3	; F5C6FC  jr Z,0xf5c713
	ld	(LCD_CurrentLayer:16), 0	; F5C6FE  ld (0x2540),0x00
	ld	xiy, Draw_Page12LevelTouchCurveLevel_DL	; F5C703  ld XIY,0x00f04f72
	ld	xix, Data_F04FFD	; F5C708  ld XIX,0x00f04ffd
	call	T_DisplayListB_Run	; F5C70D  call 0xf417f4
	jr	Draw_Page12LevelTouchCurveLevel_Return	; F5C711  jr T,0xf5c726
Draw_Page12LevelTouchCurveLevel_Skip3:
	ld	(LCD_CurrentLayer:16), 0	; F5C713  ld (0x2540),0x00
	ld	xiy, DL_F33796	; F5C718  ld XIY,0x00f33796
	ld	xix, DLRecordPtrs_F3380E	; F5C71D  ld XIX,0x00f3380e
	call	T_DisplayListB_Run	; F5C722  call 0xf417f4
Draw_Page12LevelTouchCurveLevel_Return:
	ret	; F5C726  ret

; --------------------------------------------------------------------------
; SoundEditAmp_PaintHeader
; Called from: in-module: 0xF5C6BE 0xF5C749 0xF5C79E 0xF5C876 0xF5D622
; Touches: (0x2540) (0x27F5)  |  0xF03F77 0xF03FF3 0xF0402E 0xF0426B
;          0xF04344 0xF04358
; Calls:   T_DisplayList_Run SoundEditAmp_PaintHeader SoundEdit_PaintPageLabelBackdrop
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C727 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditAmp_PaintHeader: Layer 0: runs SoundEditAmp_PaintHeader_DL ('AMPLITUDE' title, 'SOUND EDIT' box, 'ENV' and 'AMP' side tabs)
;   and, unless (0x27F5) == 1, on through DL_F03FF3 (the 'LFO' tab, its box and arrow). Basis: callers + body --
;   called first by all five AMP page painters (Dispatch_Code80_PaintTable codes 0x8B-0x8F); same shape as
;   SoundEditController_PaintHeader. (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
SoundEditAmp_PaintHeader:
	ld	(LCD_CurrentLayer:16), 0	; F5C727  ld (0x2540),0x00
	ld	xiy, SoundEditAmp_PaintHeader_DL	; F5C72C  ld XIY,0x00f03f77
	cp	(0x27f5:16), 0x01	; F5C731  cp (0x27f5),0x01
	jr	z, SoundEditAmp_PaintHeader_Skip	; F5C736  jr Z,0xf5c73f
	ld	xix, TouchCurve_DrawCurrentSlot_DL2	; F5C738  ld XIX,0x00f0402e
	jr	SoundEditAmp_PaintHeader_Join	; F5C73D  jr T,0xf5c744
SoundEditAmp_PaintHeader_Skip:
	ld	xix, DL_F03FF3	; F5C73F  ld XIX,0x00f03ff3
SoundEditAmp_PaintHeader_Join:
	call	T_DisplayList_Run	; F5C744  call 0xf417f0
	ret	; F5C748  ret
Draw_Page22KeyFollowSlopeRange:
	call	SoundEditAmp_PaintHeader	; F5C749  call 0xf5c727
	call	SoundEdit_PaintPageLabelBackdrop	; F5C74D  call 0xf5bfbd
	ld	xiy, DL_Page22KeyFollowSlopeRange	; F5C751  ld XIY,0x00f0426b
	ld	xix, DL_F04344	; F5C756  ld XIX,0x00f04344
	call	T_DisplayList_Run	; F5C75B  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 2	; F5C75F  ld (0x2540),0x02
	ld	xiy, DL_F04344	; F5C764  ld XIY,0x00f04344
	ld	xix, DL_EnvelopeKeyoffAtkPeakDecay1	; F5C769  ld XIX,0x00f04358
	call	T_DisplayList_Run	; F5C76E  call 0xf417f0

; --------------------------------------------------------------------------
; SoundEditFilterKeyFollow_PaintKeyboardAndValues
; Called from: in-module: 0xF5D5BF
; Touches: (0x2350) (0x2352) (0x2540) (0x27F5)  |  0xF04358 0xF04370
;          0xF04415 0xF049DD 0xF049E7 0xF05063 +7 more
; Calls:   KeyboardIcon_Draw 0xF5BAB8 0xF5BB00 T_DisplayListB_Run SoundEditAmp_PaintHeader T_DisplayList_Run
;          SoundEdit_PaintPage12Label Draw_Keyoff
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C772 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditFilterKeyFollow_PaintKeyboardAndValues: Keyboard icon at (56, 139), UiPaint_Solo, UiPaint_Ordinals, then on
;   layer 0 interpreter B over SoundEditFilterKeyFollow_PaintKeyboardAndValues_DL (signed readout of ModelingPage_Fields+3, three note-name readouts of fields
;   +1, +0, +2). The last step of SoundEditFilterKeyFollow_Paint (code 0x96), its only caller. Basis: caller + body +
;   display list. (notes/naming-pilot-2026-10-06/proposals_wave4_n.json)
SoundEditFilterKeyFollow_PaintKeyboardAndValues:
	ldw	(IconOrigin_X:16), 56	; F5C772  ld (0x2350),0x0038
	ldw	(IconOrigin_Y:16), 139	; F5C778  ld (0x2352),0x008b
	call	KeyboardIcon_Draw	; F5C77E  call 0xf5bbe7
	call	UiPaint_Solo	; F5C782  call 0xf5bab8
	call	UiPaint_Ordinals	; F5C786  call 0xf5bb00
	ld	(LCD_CurrentLayer:16), 0	; F5C78A  ld (0x2540),0x00
	ld	xiy, SoundEditFilterKeyFollow_PaintKeyboardAndValues_DL	; F5C78F  ld XIY,0x00f05063
	ld	xix, DLRecordPtrs_F0509B	; F5C794  ld XIX,0x00f0509b
	call	T_DisplayListB_Run	; F5C799  call 0xf417f4
	ret	; F5C79D  ret
; SoundEditAmpEnvelope1_Paint: Dispatch_Code80_PaintTable[code 0x8D] -- Dispatch_Code80_Bracketed, the full paint.
SoundEditAmpEnvelope1_Paint:
	call	SoundEditAmp_PaintHeader	; F5C79E  call 0xf5c727
	cp	(0x27f5:16), 0x01	; F5C7A2  cp (0x27f5),0x01
	jr	z, SoundEditAmpEnvelope1_Paint_Skip	; F5C7A7  jr Z,0xf5c7d0
	ld	xiy, DL_EnvelopeKeyoffAtkPeakDecay1	; F5C7A9  ld XIY,0x00f04358
	ld	xix, DL_Page22KeyFollowEnvelopeKeyFollowTouchAtk	; F5C7AE  ld XIX,0x00f04415
	call	T_DisplayList_Run	; F5C7B3  call 0xf417f0
	call	SoundEdit_PaintPage12Label	; F5C7B7  call 0xf5c916
	ld	(LCD_CurrentLayer:16), 2	; F5C7BB  ld (0x2540),0x02
	ld	xiy, DL_Keyoff	; F5C7C0  ld XIY,0x00f049dd
	ld	xix, DL_Keyoff + 0xA	; F5C7C5  ld XIX,0x00f049e7
	call	T_DisplayList_Run	; F5C7CA  call 0xf417f0
	jr	SoundEditAmpEnvelope1_Paint_Join	; F5C7CE  jr T,0xf5c7ec
SoundEditAmpEnvelope1_Paint_Skip:
	ld	xiy, DL_EnvelopeKeyoffAtkPeakDecay1	; F5C7D0  ld XIY,0x00f04358
	ld	xix, DL_EnvelopeKeyoffAtkPeakDecay1 + 0x18	; F5C7D5  ld XIX,0x00f04370
	call	T_DisplayList_Run	; F5C7DA  call 0xf417f0
	ld	xiy, DL_KeyOffModeTouchAtkDecay1Sust1Decay2Sust2	; F5C7DE  ld XIY,0x00f336ce
	ld	xix, DL_F33796	; F5C7E3  ld XIX,0x00f33796
	call	T_DisplayList_Run	; F5C7E8  call 0xf417f0
SoundEditAmpEnvelope1_Paint_Join:
	call	UiPaint_Solo	; F5C7EC  call 0xf5bab8
	call	UiPaint_Ordinals	; F5C7F0  call 0xf5bb00
	ld	(LCD_CurrentLayer:16), 0	; F5C7F4  ld (0x2540),0x00
	cp	(0x27f5:16), 0x01	; F5C7F9  cp (0x27f5),0x01
	jr	z, SoundEditAmpEnvelope1_Paint_Skip2	; F5C7FE  jr Z,0xf5c810
	ld	xiy, SoundEditAmpEnvelope1_Paint_DL1	; F5C800  ld XIY,0x00f050ab
	ld	xix, Data_F050F1	; F5C805  ld XIX,0x00f050f1
	call	T_DisplayListB_Run	; F5C80A  call 0xf417f4
	jr	SoundEditAmpEnvelope1_Paint_Return	; F5C80E  jr T,0xf5c822
SoundEditAmpEnvelope1_Paint_Skip2:
	ld	xiy, SoundEditAmpEnvelope1_Paint_DL2	; F5C810  ld XIY,0x00f33858
	ld	xix, Data_F338A5	; F5C815  ld XIX,0x00f338a5
	call	T_DisplayListB_Run	; F5C81A  call 0xf417f4
	call	Draw_Keyoff	; F5C81E  call 0xf5c823
SoundEditAmpEnvelope1_Paint_Return:
	ret	; F5C822  ret

; --------------------------------------------------------------------------
; Draw_Keyoff
; Called from: in-module: 0xF5C81E 0xF5D08A
; Touches: (0x2350) (0x2352) (0x2540) (0x27A6) (0x27F5)  |  0xF04415
;          0xF04560 0xF04574 0xF0467D 0xF047CA 0xF047DF +11 more
; Calls:   T_DisplayListB_Run T_DisplayList_Run SoundEditAmp_PaintHeader SoundEdit_PaintPageLabelBackdrop KeyboardIcon_Draw 0xF5BAB8
;          0xF5BB00 SoundEditFilter_PaintHeader SoundEdit_PaintPage12Label SoundEditFilter_PaintModeField
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C823 is an instruction boundary.
; Name:    from the one text-named display list it STARTS, DL_Keyoff (the
;          interpreter's XIY or last-pushed operand); it claims that list, not
;          a screen or a purpose (scripts/renaming/rename_wsa1_dl_drawers.py).
; Unknown: what the routine is FOR.
; --------------------------------------------------------------------------
Draw_Keyoff:
	ld	(LCD_CurrentLayer:16), 0	; F5C823  ld (0x2540),0x00
	ld	a, (ModelingPage_Fields:16)	; F5C828  ld A,(0x27a6)
	and	a, 32	; F5C82C  and A,0x20
	jr	z, Draw_Keyoff_Skip	; F5C82F  jr Z,0xf5c854
	ld	xiy, Draw_Keyoff_DL1	; F5C831  ld XIY,0x00f338c9
	ld	xix, Draw_Keyoff_DL2	; F5C836  ld XIX,0x00f338dd
	call	T_DisplayListB_Run	; F5C83B  call 0xf417f4
	ld	(LCD_CurrentLayer:16), 2	; F5C83F  ld (0x2540),0x02
	ld	xiy, DL_Keyoff	; F5C844  ld XIY,0x00f049dd
	ld	xix, Draw_Keyoff_DL3	; F5C849  ld XIX,0x00f049f3
	call	T_DisplayList_Run	; F5C84E  call 0xf417f0
	jr	Draw_Keyoff_Return	; F5C852  jr T,0xf5c875
Draw_Keyoff_Skip:
	ld	xiy, Draw_Keyoff_DL2	; F5C854  ld XIY,0x00f338dd
	ld	xix, DL_F338EB	; F5C859  ld XIX,0x00f338eb
	call	T_DisplayList_Run	; F5C85E  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 2	; F5C862  ld (0x2540),0x02
	ld	xiy, Draw_Keyoff_DL3	; F5C867  ld XIY,0x00f049f3
	ld	xix, DL_Page12EnvelopeKeyoffCurSor	; F5C86C  ld XIX,0x00f049fd
	call	T_DisplayList_Run	; F5C871  call 0xf417f0
Draw_Keyoff_Return:
	ret	; F5C875  ret
Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk:
	call	SoundEditAmp_PaintHeader	; F5C876  call 0xf5c727
	ld	xiy, DL_Page22KeyFollowEnvelopeKeyFollowTouchAtk	; F5C87A  ld XIY,0x00f04415
	ld	xix, Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk_DL1	; F5C87F  ld XIX,0x00f04560
	call	T_DisplayList_Run	; F5C884  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 2	; F5C888  ld (0x2540),0x02
	ld	xiy, Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk_DL1	; F5C88D  ld XIY,0x00f04560
	ld	xix, SoundEditFilter_PaintHeader_DL	; F5C892  ld XIX,0x00f04574
	call	T_DisplayList_Run	; F5C897  call 0xf417f0
	call	SoundEdit_PaintPageLabelBackdrop	; F5C89B  call 0xf5bfbd
	ldw	(IconOrigin_X:16), 56	; F5C89F  ld (0x2350),0x0038
	ldw	(IconOrigin_Y:16), 139	; F5C8A5  ld (0x2352),0x008b
	call	KeyboardIcon_Draw	; F5C8AB  call 0xf5bbe7
	call	UiPaint_Solo	; F5C8AF  call 0xf5bab8
	call	UiPaint_Ordinals	; F5C8B3  call 0xf5bb00
	ld	(LCD_CurrentLayer:16), 0	; F5C8B7  ld (0x2540),0x00
	ld	xiy, Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk_DL2	; F5C8BC  ld XIY,0x00f0510d
	ld	xix, DLText_AttackDecayRelease	; F5C8C1  ld XIX,0x00f05182
	call	T_DisplayListB_Run	; F5C8C6  call 0xf417f4
	ret	; F5C8CA  ret
; SoundEditFilterLpf12_Paint: Dispatch_Code80_PaintTable[code 0x90] -- Dispatch_Code80_Bracketed, the full paint.
SoundEditFilterLpf12_Paint:
	call	SoundEditFilter_PaintHeader	; F5C8CB  call 0xf5c929
	ld	xiy, DL_FilterCutoffEqualizerFreq	; F5C8CF  ld XIY,0x00f0467d
	ld	xix, DL_HighPass12db	; F5C8D4  ld XIX,0x00f047ca
	call	T_DisplayList_Run	; F5C8D9  call 0xf417f0
	ld	xiy, DL_LowPass12db	; F5C8DD  ld XIY,0x00f047df
	ld	xix, DL_FilterCutoffFilterCutoff	; F5C8E2  ld XIX,0x00f047f3
	call	T_DisplayList_Run	; F5C8E7  call 0xf417f0
	cp	(0x27f5:16), 0x01	; F5C8EB  cp (0x27f5),0x01
	jr	z, Draw_Keyoff_Skip2	; F5C8F0  jr Z,0xf5c8f6
	call	SoundEdit_PaintPage12Label	; F5C8F2  call 0xf5c916
Draw_Keyoff_Skip2:
	call	UiPaint_Solo	; F5C8F6  call 0xf5bab8
	call	UiPaint_Ordinals	; F5C8FA  call 0xf5bb00
	call	SoundEditFilter_PaintModeField	; F5C8FE  call 0xf5c94b
	ld	(LCD_CurrentLayer:16), 0	; F5C902  ld (0x2540),0x00
	ld	xiy, DL_F04D43	; F5C907  ld XIY,0x00f04d43
	ld	xix, DLBRecordPtrs_F04DA3	; F5C90C  ld XIX,0x00f04da3
	call	T_DisplayListB_Run	; F5C911  call 0xf417f4
	ret	; F5C915  ret

; --------------------------------------------------------------------------
; SoundEdit_PaintPage12Label
; Called from: in-module: 0xF5C7B7 0xF5C8F2 0xF5C9AA 0xF5C9F5 0xF5CA40
;              0xF5CA7D 0xF5CABA
; Touches:   |  0xF04672 0xF0467D
; Calls:   T_DisplayList_Run SoundEdit_PaintPageLabelBackdrop
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C916 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEdit_PaintPage12Label: Prints the 'PAGE1/2' legend (SoundEdit_PaintPage12Label_DL, one text record at layer offset 0x0110) and its
;   rounded backdrop (SoundEdit_PaintPageLabelBackdrop). Basis: callers + body -- called by the AMP ENVELOPE1 and six filter-type page
;   painters, each only when (0x27F5) != 1. (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
SoundEdit_PaintPage12Label:
	ld	xiy, SoundEdit_PaintPage12Label_DL	; F5C916  ld XIY,0x00f04672
	ld	xix, DL_FilterCutoffEqualizerFreq	; F5C91B  ld XIX,0x00f0467d
	call	T_DisplayList_Run	; F5C920  call 0xf417f0
	call	SoundEdit_PaintPageLabelBackdrop	; F5C924  call 0xf5bfbd
	ret	; F5C928  ret

; --------------------------------------------------------------------------
; SoundEditFilter_PaintHeader
; Called from: in-module: 0xF5C8CB 0xF5C983 0xF5C9CE 0xF5CA19 0xF5CA64
;              0xF5CAA1 0xF5CACB 0xF5D583 +2 more
; Touches: (0x2540) (0x27F5)  |  0xF04574 0xF0459F 0xF04632
; Calls:   T_DisplayList_Run
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C929 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditFilter_PaintHeader: Layer 0: runs SoundEditFilter_PaintHeader_DL ('FILTER' title, 'SOUND EDIT' box) and, unless (0x27F5) == 1,
;   on through DL_F0459F (the 'ENV', 'FILTER', 'LFO' side tabs with their boxes and arrows). Basis: callers + body --
;   called first by all ten FILTER page painters (Dispatch_Code80_PaintTable codes 0x90-0x99); same shape as
;   SoundEditController_PaintHeader. (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
SoundEditFilter_PaintHeader:
	ld	(LCD_CurrentLayer:16), 0	; F5C929  ld (0x2540),0x00
	cp	(0x27f5:16), 0x01	; F5C92E  cp (0x27f5),0x01
	jr	z, SoundEditFilter_PaintHeader_Skip	; F5C933  jr Z,0xf5c93c
	ld	xix, DL_F04632	; F5C935  ld XIX,0x00f04632
	jr	SoundEditFilter_PaintHeader_Join	; F5C93A  jr T,0xf5c941
SoundEditFilter_PaintHeader_Skip:
	ld	xix, DL_F0459F	; F5C93C  ld XIX,0x00f0459f
SoundEditFilter_PaintHeader_Join:
	ld	xiy, SoundEditFilter_PaintHeader_DL	; F5C941  ld XIY,0x00f04574
	call	T_DisplayList_Run	; F5C946  call 0xf417f0
	ret	; F5C94A  ret

; --------------------------------------------------------------------------
; SoundEditFilter_PaintModeField
; Called from: in-module: 0xF5C8FE 0xF5C9B6 0xF5CA01 0xF5CA4C 0xF5CA89
;              0xF5CAC6
; Touches: (0x207A) (0x2540) (0x27BE) (0x27F5)  |  0xF04650 0xF04668
;          0xF04672 0xF0467D 0xF047CA 0xF047DF +15 more
; Calls:   T_DisplayList_Run T_DisplayListB_RunOne SoundEditFilter_PaintHeader SoundEdit_PaintPage12Label 0xF5BAB8 0xF5BB00
;          SoundEditFilter_PaintModeField T_DisplayListB_Run
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5C94B is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditFilter_PaintModeField: (0x27BE) := UI_ScreenLatch; layer 2: the 'M0DE' label, arrow and box
;   (252,149)-(308,166) (+ the fill at (270,67)-(306,92) over the FILTER side tab when (0x27F5) != 1); layer 0: prints
;   DLTable_F04D1F[(0x27BE) & 7] into the box. Basis: callers + table + body -- called only by the six filter-type
;   painters, codes 0x90-0x95, and the table's six names LPF+EQ/HPF+EQ/LPF24/HPF24/BPF/THRU are those pages in the
;   same order. (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
SoundEditFilter_PaintModeField:
	ld	a, (UI_ScreenLatch:16)	; F5C94B  ld A,(0x207a)
	ld	(10174:16), a	; F5C94F  ld (0x27be),A
	ld	(LCD_CurrentLayer:16), 2	; F5C953  ld (0x2540),0x02
	ld	xiy, SoundEditFilter_PaintModeField_DL1	; F5C958  ld XIY,0x00f04650
	cp	(0x27f5:16), 0x01	; F5C95D  cp (0x27f5),0x01
	jr	z, SoundEditFilter_PaintModeField_Skip	; F5C962  jr Z,0xf5c96b
	ld	xix, SoundEdit_PaintPage12Label_DL	; F5C964  ld XIX,0x00f04672
	jr	SoundEditFilter_PaintModeField_Join	; F5C969  jr T,0xf5c970
SoundEditFilter_PaintModeField_Skip:
	ld	xix, Data_F04668	; F5C96B  ld XIX,0x00f04668
SoundEditFilter_PaintModeField_Join:
	call	T_DisplayList_Run	; F5C970  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F5C974  ld (0x2540),0x00
	ld	xiy, SoundEditFilter_PaintModeField_DL2	; F5C979  ld XIY,0x00f04d10
	call	T_DisplayListB_RunOne	; F5C97E  call 0xf41830
	ret	; F5C982  ret
; SoundEditFilterHpf12_Paint: Dispatch_Code80_PaintTable[code 0x91] -- Dispatch_Code80_Bracketed, the full paint.
SoundEditFilterHpf12_Paint:
	call	SoundEditFilter_PaintHeader	; F5C983  call 0xf5c929
	ld	xiy, DL_FilterCutoffEqualizerFreq	; F5C987  ld XIY,0x00f0467d
	ld	xix, DL_HighPass12db	; F5C98C  ld XIX,0x00f047ca
	call	T_DisplayList_Run	; F5C991  call 0xf417f0
	ld	xiy, DL_HighPass12db	; F5C995  ld XIY,0x00f047ca
	ld	xix, DL_LowPass12db	; F5C99A  ld XIX,0x00f047df
	call	T_DisplayList_Run	; F5C99F  call 0xf417f0
	cp	(0x27f5:16), 0x01	; F5C9A3  cp (0x27f5),0x01
	jr	z, SoundEditFilterHpf12_Paint_Skip2	; F5C9A8  jr Z,0xf5c9ae
	call	SoundEdit_PaintPage12Label	; F5C9AA  call 0xf5c916
SoundEditFilterHpf12_Paint_Skip2:
	call	UiPaint_Solo	; F5C9AE  call 0xf5bab8
	call	UiPaint_Ordinals	; F5C9B2  call 0xf5bb00
	call	SoundEditFilter_PaintModeField	; F5C9B6  call 0xf5c94b
	ld	(LCD_CurrentLayer:16), 0	; F5C9BA  ld (0x2540),0x00
	ld	xiy, DL_F04D43	; F5C9BF  ld XIY,0x00f04d43
	ld	xix, DLBRecordPtrs_F04DA3	; F5C9C4  ld XIX,0x00f04da3
	call	T_DisplayListB_Run	; F5C9C9  call 0xf417f4
	ret	; F5C9CD  ret
; SoundEditFilterLpf24_Paint: Dispatch_Code80_PaintTable[code 0x92] -- Dispatch_Code80_Bracketed, the full paint.
SoundEditFilterLpf24_Paint:
	call	SoundEditFilter_PaintHeader	; F5C9CE  call 0xf5c929
	ld	xiy, DL_FilterCutoffFilterCutoff	; F5C9D2  ld XIY,0x00f047f3
	ld	xix, DL_LowPass24db	; F5C9D7  ld XIX,0x00f04889
	call	T_DisplayList_Run	; F5C9DC  call 0xf417f0
	ld	xiy, DL_LowPass24db	; F5C9E0  ld XIY,0x00f04889
	ld	xix, DL_HighPass24db	; F5C9E5  ld XIX,0x00f0489d
	call	T_DisplayList_Run	; F5C9EA  call 0xf417f0
	cp	(0x27f5:16), 0x01	; F5C9EE  cp (0x27f5),0x01
	jr	z, SoundEditFilterLpf24_Paint_Skip3	; F5C9F3  jr Z,0xf5c9f9
	call	SoundEdit_PaintPage12Label	; F5C9F5  call 0xf5c916
SoundEditFilterLpf24_Paint_Skip3:
	call	UiPaint_Solo	; F5C9F9  call 0xf5bab8
	call	UiPaint_Ordinals	; F5C9FD  call 0xf5bb00
	call	SoundEditFilter_PaintModeField	; F5CA01  call 0xf5c94b
	ld	(LCD_CurrentLayer:16), 0	; F5CA05  ld (0x2540),0x00
	ld	xiy, DL_F04DFF	; F5CA0A  ld XIY,0x00f04dff
	ld	xix, Data_F04E32	; F5CA0F  ld XIX,0x00f04e32
	call	T_DisplayListB_Run	; F5CA14  call 0xf417f4
	ret	; F5CA18  ret
; SoundEditFilterHpf24_Paint: Dispatch_Code80_PaintTable[code 0x93] -- Dispatch_Code80_Bracketed, the full paint.
SoundEditFilterHpf24_Paint:
	call	SoundEditFilter_PaintHeader	; F5CA19  call 0xf5c929
	ld	xiy, DL_FilterCutoffFilterCutoff	; F5CA1D  ld XIY,0x00f047f3
	ld	xix, DL_LowPass24db	; F5CA22  ld XIX,0x00f04889
	call	T_DisplayList_Run	; F5CA27  call 0xf417f0
	ld	xiy, DL_HighPass24db	; F5CA2B  ld XIY,0x00f0489d
	ld	xix, DL_FilterBandPassLowHighCutoff	; F5CA30  ld XIX,0x00f048b2
	call	T_DisplayList_Run	; F5CA35  call 0xf417f0
	cp	(0x27f5:16), 0x01	; F5CA39  cp (0x27f5),0x01
	jr	z, SoundEditFilterHpf24_Paint_Skip4	; F5CA3E  jr Z,0xf5ca44
	call	SoundEdit_PaintPage12Label	; F5CA40  call 0xf5c916
SoundEditFilterHpf24_Paint_Skip4:
	call	UiPaint_Solo	; F5CA44  call 0xf5bab8
	call	UiPaint_Ordinals	; F5CA48  call 0xf5bb00
	call	SoundEditFilter_PaintModeField	; F5CA4C  call 0xf5c94b
	ld	(LCD_CurrentLayer:16), 0	; F5CA50  ld (0x2540),0x00
	ld	xiy, DL_F04DFF	; F5CA55  ld XIY,0x00f04dff
	ld	xix, Data_F04E32	; F5CA5A  ld XIX,0x00f04e32
	call	T_DisplayListB_Run	; F5CA5F  call 0xf417f4
	ret	; F5CA63  ret
Draw_FilterBandPassLowHighCutoff:
	call	SoundEditFilter_PaintHeader	; F5CA64  call 0xf5c929
	ld	xiy, DL_FilterBandPassLowHighCutoff	; F5CA68  ld XIY,0x00f048b2
	ld	xix, DL_Through	; F5CA6D  ld XIX,0x00f049bc
	call	T_DisplayList_Run	; F5CA72  call 0xf417f0
	cp	(0x27f5:16), 0x01	; F5CA76  cp (0x27f5),0x01
	jr	z, Draw_FilterBandPassLowHighCutoff_Skip5	; F5CA7B  jr Z,0xf5ca81
	call	SoundEdit_PaintPage12Label	; F5CA7D  call 0xf5c916
Draw_FilterBandPassLowHighCutoff_Skip5:
	call	UiPaint_Solo	; F5CA81  call 0xf5bab8
	call	UiPaint_Ordinals	; F5CA85  call 0xf5bb00
	call	SoundEditFilter_PaintModeField	; F5CA89  call 0xf5c94b
	ld	(LCD_CurrentLayer:16), 0	; F5CA8D  ld (0x2540),0x00
	ld	xiy, Draw_FilterBandPassLowHighCutoff_DL	; F5CA92  ld XIY,0x00f04e42
	ld	xix, DLRecordPtrs_F04E93	; F5CA97  ld XIX,0x00f04e93
	call	T_DisplayListB_Run	; F5CA9C  call 0xf417f4
	ret	; F5CAA0  ret
Draw_Through:
	call	SoundEditFilter_PaintHeader	; F5CAA1  call 0xf5c929
	ld	xiy, DL_Through	; F5CAA5  ld XIY,0x00f049bc
	ld	xix, Draw_Page12EnvelopeKeyoffCurSor_DL1	; F5CAAA  ld XIX,0x00f049d3
	call	T_DisplayList_Run	; F5CAAF  call 0xf417f0
	cp	(0x27f5:16), 0x01	; F5CAB3  cp (0x27f5),0x01
	jr	z, Draw_Through_Skip6	; F5CAB8  jr Z,0xf5cabe
	call	SoundEdit_PaintPage12Label	; F5CABA  call 0xf5c916
Draw_Through_Skip6:
	call	UiPaint_Solo	; F5CABE  call 0xf5bab8
	call	UiPaint_Ordinals	; F5CAC2  call 0xf5bb00
	call	SoundEditFilter_PaintModeField	; F5CAC6  call 0xf5c94b
	ret	; F5CACA  ret
Draw_StartPointStopPointCutoff:
	call	SoundEditFilter_PaintHeader	; F5CACB  call 0xf5c929
	ld	xiy, DL_StartPointStopPointCutoff	; F5CACF  ld XIY,0x00f04b1f
	ld	xix, DL_Page22KeyFollowEnvelopeKeyFollowTouchAttack	; F5CAD4  ld XIX,0x00f04b6c
	call	T_DisplayList_Run	; F5CAD9  call 0xf417f0

; --------------------------------------------------------------------------
; Draw_Page12EnvelopeKeyoffCurSor
; Called from: in-module: 0xF5D575
; Touches: (0x2540)  |  0x0027D6 0xF030E6 0xF03107 0xF03173 0xF031BF
;          0xF031C9 +7 more
; Calls:   T_DisplayList_Run SoundEdit_PaintPageLabelBackdrop 0xF5BAB8 0xF5BB00 T_DisplayListB_Run 0xF09AF1
;          ToneEditPage_A0_PaintSlotOrdinals ToneEditPage_A0_PaintGroupBrackets 0xF09AE1
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5CADD is an instruction boundary.
; Name:    from the one text-named display list it STARTS, DL_Page12EnvelopeKeyoffCurSor (the
;          interpreter's XIY or last-pushed operand); it claims that list, not
;          a screen or a purpose (scripts/renaming/rename_wsa1_dl_drawers.py).
; Unknown: what the routine is FOR.
; --------------------------------------------------------------------------
Draw_Page12EnvelopeKeyoffCurSor:
	ld	xiy, DL_Page12EnvelopeKeyoffCurSor	; F5CADD  ld XIY,0x00f049fd
	ld	xix, DL_StartPointStopPointCutoff	; F5CAE2  ld XIX,0x00f04b1f
	call	T_DisplayList_Run	; F5CAE7  call 0xf417f0
	call	SoundEdit_PaintPageLabelBackdrop	; F5CAEB  call 0xf5bfbd
	ld	(LCD_CurrentLayer:16), 2	; F5CAEF  ld (0x2540),0x02
	ld	xiy, Draw_Page12EnvelopeKeyoffCurSor_DL1	; F5CAF4  ld XIY,0x00f049d3
	ld	xix, DL_Keyoff + 0xA	; F5CAF9  ld XIX,0x00f049e7
	call	T_DisplayList_Run	; F5CAFE  call 0xf417f0
	call	UiPaint_Solo	; F5CB02  call 0xf5bab8
	call	UiPaint_Ordinals	; F5CB06  call 0xf5bb00
	ld	(LCD_CurrentLayer:16), 0	; F5CB0A  ld (0x2540),0x00
	ld	xiy, Draw_Page12EnvelopeKeyoffCurSor_DL2	; F5CB0F  ld XIY,0x00f04eab
	ld	xix, Data_F04F20	; F5CB14  ld XIX,0x00f04f20
	call	T_DisplayListB_Run	; F5CB19  call 0xf417f4
	ret	; F5CB1D  ret
; ToneEditPage_A0_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0xA0] -- Dispatch_Code80, the partial repaint.
ToneEditPage_A0_RepaintField:
	cp	a, 0:i3	; F5CB1E  cp A,0
	jr	z, Draw_Page12EnvelopeKeyoffCurSor_Skip2	; F5CB20  jr Z,0xf5cb63
	cp	a, 1:i3	; F5CB22  cp A,1
	jr	z, Draw_Page12EnvelopeKeyoffCurSor_Skip3	; F5CB24  jr Z,0xf5cb8b
	cp	a, 6:i3	; F5CB26  cp A,6
	jr	z, Draw_Page12EnvelopeKeyoffCurSor_Skip4	; F5CB28  jr Z,0xf5cb91
	cp	a, 20	; F5CB2A  cp A,0x14
	jr	nc, Draw_Page12EnvelopeKeyoffCurSor_Skip5	; F5CB2D  jr NC,0xf5cb97
	cp	a, 8	; F5CB2F  cp A,0x08
	jr	c, Draw_Page12EnvelopeKeyoffCurSor_Skip	; F5CB32  jr C,0xf5cb55
	ld	xiy, DLRecordPtrs_F03173	; F5CB34  ld XIY,0x00f03173
	extz	xwa	; F5CB39  extz XWA
	xor	w, w	; F5CB3B  xor W,W
	sla	wa, 2	; F5CB3D  sla 0x02,WA
	add	xiy, xwa	; F5CB40  add XIY,XWA
	ld	xiz, xiy	; F5CB42  ld XIZ,XIY
	ld	xiy, (xiz)	; F5CB44  ld XIY,(XIZ)
	ld	xix, (xiz+4)	; F5CB46  ld XIX,(XIZ+0x04)
	ld	(LCD_CurrentLayer:16), 0	; F5CB49  ld (0x2540),0x00
	call	T_DisplayListB_Run	; F5CB4E  call 0xf417f4
	jrl	Draw_Page12EnvelopeKeyoffCurSor_Return	; F5CB52  jrl T,0xf5cbd8
Draw_Page12EnvelopeKeyoffCurSor_Skip:
	push_a	; F5CB55  push A
	sub	a, 2	; F5CB56  sub A,0x02
	call	ToneEditPage_A0_PaintResonatorIcon	; F5CB59  call 0xf09af1
	pop_a	; F5CB5D  pop A
	add	a, 13	; F5CB5E  add A,0x0d
	jr	Draw_Page12EnvelopeKeyoffCurSor_Join	; F5CB61  jr T,0xf5cbca
Draw_Page12EnvelopeKeyoffCurSor_Skip2:
	ld	(LCD_CurrentLayer:16), 1	; F5CB63  ld (0x2540),0x01
	ld	xiy, ToneEditPage_A0_RepaintField_DL	; F5CB68  ld XIY,0x00f031bf
	ld	xix, DLTable_F031C9	; F5CB6D  ld XIX,0x00f031c9
	call	T_DisplayList_Run	; F5CB72  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 1	; F5CB76  ld (0x2540),0x01
	ld	xiy, DL_F030E6	; F5CB7B  ld XIY,0x00f030e6
	ld	xix, ToneEditPage_A0_PaintGroupBrackets_DL2	; F5CB80  ld XIX,0x00f03107
	call	T_DisplayListB_Run	; F5CB85  call 0xf417f4
	jr	Draw_Page12EnvelopeKeyoffCurSor_Return	; F5CB89  jr T,0xf5cbd8
Draw_Page12EnvelopeKeyoffCurSor_Skip3:
	call	ToneEditPage_A0_PaintSlotOrdinals	; F5CB8B  call 0xf5c424
	jr	Draw_Page12EnvelopeKeyoffCurSor_Return	; F5CB8F  jr T,0xf5cbd8
Draw_Page12EnvelopeKeyoffCurSor_Skip4:
	call	ToneEditPage_A0_PaintGroupBrackets	; F5CB91  call 0xf5cbd9
	jr	Draw_Page12EnvelopeKeyoffCurSor_Return	; F5CB95  jr T,0xf5cbd8
Draw_Page12EnvelopeKeyoffCurSor_Skip5:
	sub	a, 20	; F5CB97  sub A,0x14
	ld	xix, 10198	; F5CB9A  ld XIX,0x000027d6
	ld	b, (xix+a)	; F5CB9F  ld B,(XIX+A)
	cp	b, 0:i3	; F5CBA4  cp B,0
	jr	z, Draw_Page12EnvelopeKeyoffCurSor_Return	; F5CBA6  jr Z,0xf5cbd8
	ld	(LCD_CurrentLayer:16), 0	; F5CBA8  ld (0x2540),0x00
	ld	xix, DisplayList_FC5110_End	; F5CBAD  ld XIX,0x00fc512e
	sla	a, 2	; F5CBB2  sla 0x02,A
	ld	xiz, (xix+a)	; F5CBB5  ld XIZ,(XIX+A)
	ld	xiy, (xiz)	; F5CBBA  ld XIY,(XIZ)
	sla	b, 2	; F5CBBC  sla 0x02,B
	ld	xix, (xiz+b)	; F5CBBF  ld XIX,(XIZ+B)
	call	T_DisplayList_Run	; F5CBC4  call 0xf417f0
	jr	Draw_Page12EnvelopeKeyoffCurSor_Return	; F5CBC8  jr T,0xf5cbd8
Draw_Page12EnvelopeKeyoffCurSor_Join:
	ld	(LCD_CurrentLayer:16), 0	; F5CBCA  ld (0x2540),0x00
	ld	xiy, DLRecordPtrs_F03173	; F5CBCF  ld XIY,0x00f03173
	call	RunDisplayListBFromPointerArray	; F5CBD4  call 0xf09ae1
Draw_Page12EnvelopeKeyoffCurSor_Return:
	ret	; F5CBD8  ret

; --------------------------------------------------------------------------
; ToneEditPage_A0_PaintGroupBrackets
; Called from: in-module: 0xF5C067 0xF5CB91
; Touches: (0x2540) (0x27AC)  |  0xF03107 0xF03133 0xF0315F 0xF03169
;          0xF03173 0xF338EB +2 more
; Calls:   T_DisplayList_Run SoundEditModelingDriverWaveform_PaintRows T_DisplayListB_RunOne
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5CBD9 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ToneEditPage_A0_PaintGroupBrackets: Layer 2: erases the bracket column (0xF5,0x48)-(0x109,0xC3), then by
;   ModelingPage_Fields+6: 0 none, 1 joins slots 1-2, 2 joins 3-4, 3 both pairs, else both pairs plus the link between
;   them. Page A0 ('RESONATOR / DRIVER / ON/OFF / GROUP') paint and repaint call it. Basis: callers + body + display
;   lists. (notes/naming-pilot-2026-10-06/proposals_wave2_c.json)
ToneEditPage_A0_PaintGroupBrackets:
	ld	(LCD_CurrentLayer:16), 2	; F5CBD9  ld (0x2540),0x02
	ld	xiy, ToneEditPage_A0_PaintGroupBrackets_DL1	; F5CBDE  ld XIY,0x00f03169
	ld	xix, DLRecordPtrs_F03173	; F5CBE3  ld XIX,0x00f03173
	call	T_DisplayList_Run	; F5CBE8  call 0xf417f0
	ld	a, (ModelingPage_Fields+6:16)	; F5CBEC  ld A,(0x27ac)
	cp	a, 0:i3	; F5CBF0  cp A,0
	jr	z, ToneEditPage_A0_PaintGroupBrackets_Return	; F5CBF2  jr Z,0xf5cc3c
	cp	a, 1:i3	; F5CBF4  cp A,1
	jr	z, ToneEditPage_A0_PaintGroupBrackets_Skip	; F5CBF6  jr Z,0xf5cc0c
	cp	a, 2:i3	; F5CBF8  cp A,2
	jr	z, ToneEditPage_A0_PaintGroupBrackets_Skip2	; F5CBFA  jr Z,0xf5cc18
	cp	a, 3:i3	; F5CBFC  cp A,3
	jr	z, ToneEditPage_A0_PaintGroupBrackets_Skip3	; F5CBFE  jr Z,0xf5cc24
	ld	xiy, ToneEditPage_A0_PaintGroupBrackets_DL2	; F5CC00  ld XIY,0x00f03107
	ld	xix, ToneEditPage_A0_PaintGroupBrackets_DL1	; F5CC05  ld XIX,0x00f03169
	jr	ToneEditPage_A0_PaintGroupBrackets_Join	; F5CC0A  jr T,0xf5cc2e
ToneEditPage_A0_PaintGroupBrackets_Skip:
	ld	xiy, ToneEditPage_A0_PaintGroupBrackets_DL2	; F5CC0C  ld XIY,0x00f03107
	ld	xix, ToneEditPage_A0_PaintGroupBrackets_DL3	; F5CC11  ld XIX,0x00f03133
	jr	ToneEditPage_A0_PaintGroupBrackets_Join	; F5CC16  jr T,0xf5cc2e
ToneEditPage_A0_PaintGroupBrackets_Skip2:
	ld	xiy, ToneEditPage_A0_PaintGroupBrackets_DL3	; F5CC18  ld XIY,0x00f03133
	ld	xix, Data_F0315F	; F5CC1D  ld XIX,0x00f0315f
	jr	ToneEditPage_A0_PaintGroupBrackets_Join	; F5CC22  jr T,0xf5cc2e
ToneEditPage_A0_PaintGroupBrackets_Skip3:
	ld	xiy, ToneEditPage_A0_PaintGroupBrackets_DL2	; F5CC24  ld XIY,0x00f03107
	ld	xix, Data_F0315F	; F5CC29  ld XIX,0x00f0315f
ToneEditPage_A0_PaintGroupBrackets_Join:
	ld	(LCD_CurrentLayer:16), 2	; F5CC2E  ld (0x2540),0x02
	call	T_DisplayList_Run	; F5CC33  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F5CC37  ld (0x2540),0x00
ToneEditPage_A0_PaintGroupBrackets_Return:
	ret	; F5CC3C  ret
; SoundEditModelingDriverWaveform_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x86] (also codes 0xA2) -- Dispatch_Code80, the partial repaint.
SoundEditModelingDriverWaveform_RepaintField:
	cp	a, 0:i3	; F5CC3D  cp A,0
	jr	z, SoundEditModelingDriverWaveform_RepaintField_Skip4	; F5CC3F  jr Z,0xf5cc47
	call	SoundEditModelingDriverWaveform_PaintRows	; F5CC41  call 0xf5cc64
	jr	SoundEditModelingDriverWaveform_RepaintField_Return2	; F5CC45  jr T,0xf5cc63
SoundEditModelingDriverWaveform_RepaintField_Skip4:
	ld	(LCD_CurrentLayer:16), 1	; F5CC47  ld (0x2540),0x01
	ld	xiy, SoundEditModelingDriverWaveform_RepaintField_DL	; F5CC4C  ld XIY,0x00f33a3f
	ld	xix, Data_F33A49	; F5CC51  ld XIX,0x00f33a49
	call	T_DisplayList_Run	; F5CC56  call 0xf417f0
	ld	xiy, DL_F338EB	; F5CC5A  ld XIY,0x00f338eb
	call	T_DisplayListB_RunOne	; F5CC5F  call 0xf41830
SoundEditModelingDriverWaveform_RepaintField_Return2:
	ret	; F5CC63  ret

; --------------------------------------------------------------------------
; SoundEditModelingDriverWaveform_PaintRows
; Called from: in-module: 0xF5C099 0xF5CC41
; Touches: (0x2540)  |  0x000001 0x000005 0x000014 0x000032 0x0027AA
;          0xF03455 +40 more
; Calls:   T_DisplayList_Run T_DisplayListB_Run 0xF09AE1 ToneEditPage_PaintMainAndSubFocus ModelingPage_PaintFields11And12 ToneEditPage_A8_PaintField5Switch
;          SoundEditLfo_DrawField0RowLine SoundEditLfo_DrawRowLinks SoundEditLfo_PaintOrdinals 0xF5BAB8
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5CC64 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditModelingDriverWaveform_PaintRows: DRIVER WAVEFORM page: draws the ' 0-' head (SoundEditModelingDriverWaveform_PaintRows_DL1..DL_F339BC), the B
;   readouts SoundEditModelingDriverWaveform_PaintRows_DL2..DL_F3391E, then for rows c = 0..2: when ModelingPage_Fields[4+c] is non-zero runs the row's
;   readout list (Data_F33A1B[c], 50 bytes) and its '-' record (Data_F33A1B[6+c]), else the row's erase list
;   (Data_F33A1B[3+c], two EraseRect records). Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_d.json)
SoundEditModelingDriverWaveform_PaintRows:
	ld	(LCD_CurrentLayer:16), 0	; F5CC64  ld (0x2540),0x00
	ld	xiy, SoundEditModelingDriverWaveform_PaintRows_DL1	; F5CC69  ld XIY,0x00f339b4
	ld	xix, DL_F339BC	; F5CC6E  ld XIX,0x00f339bc
	call	T_DisplayList_Run	; F5CC73  call 0xf417f0
	ld	xiy, SoundEditModelingDriverWaveform_PaintRows_DL2	; F5CC77  ld XIY,0x00f338f6
	ld	xix, DL_F3391E	; F5CC7C  ld XIX,0x00f3391e
	call	T_DisplayListB_Run	; F5CC81  call 0xf417f4
	ld	c, 0:opc	; F5CC85  ld C,0x00
	ld	xiz, ModelingPage_Fields+4	; F5CC87  ld XIZ,0x000027aa
SoundEditModelingDriverWaveform_PaintRows_Loop:
	push	c	; F5CC8C  push C
	push	xiz	; F5CC8E  push XIZ
	cp	(xiz), 0x00	; F5CC8F  cp (XIZ),0x00
	jr	z, SoundEditModelingDriverWaveform_PaintRows_Skip	; F5CC92  jr Z,0xf5ccc9
	ld	xiy, Data_F33A1B	; F5CC94  ld XIY,0x00f33a1b
	extz	xbc	; F5CC99  extz XBC
	xor	b, b	; F5CC9B  xor B,B
	sla	bc, 2	; F5CC9D  sla 0x02,BC
	add	xiy, xbc	; F5CCA0  add XIY,XBC
	ld	xiy, (xiy)	; F5CCA2  ld XIY,(XIY)
	ld	xix, xiy	; F5CCA4  ld XIX,XIY
	add	xix, 50	; F5CCA6  add XIX,0x00000032
	push	xbc	; F5CCAC  push XBC
	call	T_DisplayListB_Run	; F5CCAD  call 0xf417f4
	pop	xbc	; F5CCB1  pop XBC
	ld	xiy, Data_F33A1B + 0x18	; F5CCB2  ld XIY,0x00f33a33
	add	xiy, xbc	; F5CCB7  add XIY,XBC
	ld	xiy, (xiy)	; F5CCB9  ld XIY,(XIY)
	ld	xix, xiy	; F5CCBB  ld XIX,XIY
	add	xix, 5	; F5CCBD  add XIX,0x00000005
	call	T_DisplayList_Run	; F5CCC3  call 0xf417f0
	jr	SoundEditModelingDriverWaveform_PaintRows_Join	; F5CCC7  jr T,0xf5cce5
SoundEditModelingDriverWaveform_PaintRows_Skip:
	ld	xiy, Data_F33A1B + 0xC	; F5CCC9  ld XIY,0x00f33a27
	extz	xbc	; F5CCCE  extz XBC
	xor	b, b	; F5CCD0  xor B,B
	sla	bc, 2	; F5CCD2  sla 0x02,BC
	add	xiy, xbc	; F5CCD5  add XIY,XBC
	ld	xiy, (xiy)	; F5CCD7  ld XIY,(XIY)
	ld	xix, xiy	; F5CCD9  ld XIX,XIY
	add	xix, 20	; F5CCDB  add XIX,0x00000014
	call	T_DisplayList_Run	; F5CCE1  call 0xf417f0
SoundEditModelingDriverWaveform_PaintRows_Join:
	pop	xiz	; F5CCE5  pop XIZ
	pop	c	; F5CCE6  pop C
	add	c, 1	; F5CCE8  add C,0x01
	add	xiz, 1	; F5CCEB  add XIZ,0x00000001
	cp	c, 3:i3	; F5CCF1  cp C,3
	jr	nz, SoundEditModelingDriverWaveform_PaintRows_Loop	; F5CCF3  jr NZ,0xf5cc8c
	ret	; F5CCF5  ret
; ToneEditPage_A3_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0xA3] -- Dispatch_Code80, the partial repaint.
ToneEditPage_A3_RepaintField:
	cp	a, 1:i3	; F5CCF6  cp A,1
	jr	nz, ToneEditPage_A3_RepaintField_Skip2	; F5CCF8  jr NZ,0xf5cd0f
	ld	(LCD_CurrentLayer:16), 0	; F5CCFA  ld (0x2540),0x00
	ld	xiy, ToneEditPage_A3_RepaintField_DL	; F5CCFF  ld XIY,0x00f03455
	ld	xix, ToneEditPage_A3_RepaintField_DL + 0x19	; F5CD04  ld XIX,0x00f0346e
	call	T_DisplayListB_Run	; F5CD09  call 0xf417f4
	jr	ToneEditPage_A3_RepaintField_Return	; F5CD0D  jr T,0xf5cd1d
ToneEditPage_A3_RepaintField_Skip2:
	ld	(LCD_CurrentLayer:16), 0	; F5CD0F  ld (0x2540),0x00
	ld	xiy, DLBRecordPtrs_F03480	; F5CD14  ld XIY,0x00f03480
	call	RunDisplayListBFromPointerArray	; F5CD19  call 0xf09ae1
ToneEditPage_A3_RepaintField_Return:
	ret	; F5CD1D  ret
; ToneEditPage_A4_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0xA4] -- Dispatch_Code80, the partial repaint.
ToneEditPage_A4_RepaintField:
	cp	a, 2:i3	; F5CD1E  cp A,2
	jr	nz, ToneEditPage_A4_RepaintField_Skip3	; F5CD20  jr NZ,0xf5cd37
	ld	(LCD_CurrentLayer:16), 0	; F5CD22  ld (0x2540),0x00
	ld	xiy, ToneEditPage_A4_RepaintField_DL	; F5CD27  ld XIY,0x00f034ad
	ld	xix, DLBRecordPtrs_F034C6	; F5CD2C  ld XIX,0x00f034c6
	call	T_DisplayListB_Run	; F5CD31  call 0xf417f4
	jr	ToneEditPage_A4_RepaintField_Return2	; F5CD35  jr T,0xf5cd45
ToneEditPage_A4_RepaintField_Skip3:
	ld	(LCD_CurrentLayer:16), 0	; F5CD37  ld (0x2540),0x00
	ld	xiy, DLBRecordPtrs_F034C6	; F5CD3C  ld XIY,0x00f034c6
	call	RunDisplayListBFromPointerArray	; F5CD41  call 0xf09ae1
ToneEditPage_A4_RepaintField_Return2:
	ret	; F5CD45  ret
; ToneEditPage_A5_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0xA5] -- Dispatch_Code80, the partial repaint.
ToneEditPage_A5_RepaintField:
	cp	a, 0:i3	; F5CD46  cp A,0
	jr	z, ToneEditPage_A5_RepaintField_Skip4	; F5CD48  jr Z,0xf5cd54
	cp	a, 2:i3	; F5CD4A  cp A,2
	jr	z, ToneEditPage_A5_RepaintField_Skip5	; F5CD4C  jr Z,0xf5cd6f
	cp	a, 6:i3	; F5CD4E  cp A,6
	jr	z, ToneEditPage_A5_RepaintField_Skip6	; F5CD50  jr Z,0xf5cd84
	jr	ToneEditPage_A5_RepaintField_Join2	; F5CD52  jr T,0xf5cd99
ToneEditPage_A5_RepaintField_Skip4:
	ld	(LCD_CurrentLayer:16), 1	; F5CD54  ld (0x2540),0x01
	ld	xiy, DL_F03581	; F5CD59  ld XIY,0x00f03581
	ld	xix, ToneEditPage_PaintMainAndSubFocus_DL1	; F5CD5E  ld XIX,0x00f03595
	call	T_DisplayList_Run	; F5CD63  call 0xf417f0
	call	ToneEditPage_PaintMainAndSubFocus	; F5CD67  call 0xf5c144
	ld	a, 0:opc	; F5CD6B  ld A,0x00
	jr	ToneEditPage_A5_RepaintField_Join2	; F5CD6D  jr T,0xf5cd99
ToneEditPage_A5_RepaintField_Skip5:
	ld	(LCD_CurrentLayer:16), 0	; F5CD6F  ld (0x2540),0x00
	ld	xiy, ToneEditPage_A5_RepaintField_DL1	; F5CD74  ld XIY,0x00f034e8
	ld	xix, ToneEditPage_A5_RepaintField_DL1 + 0x1A	; F5CD79  ld XIX,0x00f03502
	call	T_DisplayListB_Run	; F5CD7E  call 0xf417f4
	jr	ToneEditPage_A5_RepaintField_Return3	; F5CD82  jr T,0xf5cda7
ToneEditPage_A5_RepaintField_Skip6:
	ld	(LCD_CurrentLayer:16), 0	; F5CD84  ld (0x2540),0x00
	ld	xiy, ToneEditPage_A5_RepaintField_DL2	; F5CD89  ld XIY,0x00f03522
	ld	xix, ToneEditPage_A5_RepaintField_DL2 + 0x1A	; F5CD8E  ld XIX,0x00f0353c
	call	T_DisplayListB_Run	; F5CD93  call 0xf417f4
	jr	ToneEditPage_A5_RepaintField_Return3	; F5CD97  jr T,0xf5cda7
ToneEditPage_A5_RepaintField_Join2:
	ld	(LCD_CurrentLayer:16), 0	; F5CD99  ld (0x2540),0x00
	ld	xiy, DLRecordPtrs_F0355D	; F5CD9E  ld XIY,0x00f0355d
	call	RunDisplayListBFromPointerArray	; F5CDA3  call 0xf09ae1
ToneEditPage_A5_RepaintField_Return3:
	ret	; F5CDA7  ret
; ToneEditPage_A6_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0xA6] -- Dispatch_Code80, the partial repaint.
ToneEditPage_A6_RepaintField:
	cp	a, 0:i3	; F5CDA8  cp A,0
	jr	nz, ToneEditPage_A6_RepaintField_Skip7	; F5CDAA  jr NZ,0xf5cdc5
	ld	(LCD_CurrentLayer:16), 1	; F5CDAC  ld (0x2540),0x01
	ld	xiy, DL_F03581	; F5CDB1  ld XIY,0x00f03581
	ld	xix, ToneEditPage_PaintMainAndSubFocus_DL1	; F5CDB6  ld XIX,0x00f03595
	call	T_DisplayList_Run	; F5CDBB  call 0xf417f0
	call	ToneEditPage_PaintMainAndSubFocus	; F5CDBF  call 0xf5c144
	ld	a, 0:opc	; F5CDC3  ld A,0x00
ToneEditPage_A6_RepaintField_Skip7:
	ld	(LCD_CurrentLayer:16), 0	; F5CDC5  ld (0x2540),0x00
	ld	xiy, Data_F03617	; F5CDCA  ld XIY,0x00f03617
	call	RunDisplayListBFromPointerArray	; F5CDCF  call 0xf09ae1
	ret	; F5CDD3  ret
; ToneEditPage_A7_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0xA7] -- Dispatch_Code80, the partial repaint.
ToneEditPage_A7_RepaintField:
	cp	a, 0:i3	; F5CDD4  cp A,0
	jr	nz, ToneEditPage_A7_RepaintField_Skip8	; F5CDD6  jr NZ,0xf5cdf1
	ld	(LCD_CurrentLayer:16), 1	; F5CDD8  ld (0x2540),0x01
	ld	xiy, DL_F03581	; F5CDDD  ld XIY,0x00f03581
	ld	xix, ToneEditPage_PaintMainAndSubFocus_DL1	; F5CDE2  ld XIX,0x00f03595
	call	T_DisplayList_Run	; F5CDE7  call 0xf417f0
	call	ToneEditPage_PaintMainAndSubFocus	; F5CDEB  call 0xf5c144
	ld	a, 0:opc	; F5CDEF  ld A,0x00
ToneEditPage_A7_RepaintField_Skip8:
	ld	(LCD_CurrentLayer:16), 0	; F5CDF1  ld (0x2540),0x00
	ld	xiy, DLRecordPtrs_F036C2	; F5CDF6  ld XIY,0x00f036c2
	call	RunDisplayListBFromPointerArray	; F5CDFB  call 0xf09ae1
	ret	; F5CDFF  ret
; ToneEditPage_A8_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0xA8] -- Dispatch_Code80, the partial repaint.
ToneEditPage_A8_RepaintField:
	cp	a, 3:i3	; F5CE00  cp A,3
	jr	z, ToneEditPage_A8_RepaintField_Skip10	; F5CE02  jr Z,0xf5ce24
	cp	a, 2:i3	; F5CE04  cp A,2
	jr	z, ToneEditPage_A8_RepaintField_Skip9	; F5CE06  jr Z,0xf5ce0f
	cp	a, 11	; F5CE08  cp A,0x0b
	jr	c, ToneEditPage_A8_RepaintField_Skip11	; F5CE0B  jr C,0xf5ce52
	jr	ToneEditPage_A8_RepaintField_Join3	; F5CE0D  jr T,0xf5ce39
ToneEditPage_A8_RepaintField_Skip9:
	ld	(LCD_CurrentLayer:16), 0	; F5CE0F  ld (0x2540),0x00
	ld	xiy, ToneEditPage_A8_RepaintField_DL1	; F5CE14  ld XIY,0x00f064f9
	ld	xix, ToneEditPage_A8_RepaintField_DL2	; F5CE19  ld XIX,0x00f06517
	call	T_DisplayListB_Run	; F5CE1E  call 0xf417f4
	jr	ToneEditPage_A8_RepaintField_Return4	; F5CE22  jr T,0xf5ce64
ToneEditPage_A8_RepaintField_Skip10:
	ld	(LCD_CurrentLayer:16), 0	; F5CE24  ld (0x2540),0x00
	ld	xiy, ToneEditPage_A8_RepaintField_DL2	; F5CE29  ld XIY,0x00f06517
	ld	xix, ToneEditPage_A8_RepaintField_DL2 + 0x1E	; F5CE2E  ld XIX,0x00f06535
	call	T_DisplayListB_Run	; F5CE33  call 0xf417f4
	jr	ToneEditPage_A8_RepaintField_Return4	; F5CE37  jr T,0xf5ce64
ToneEditPage_A8_RepaintField_Join3:
	ld	(LCD_CurrentLayer:16), 0	; F5CE39  ld (0x2540),0x00
	ld	xiy, ToneEditPage_A8_RepaintField_DL3	; F5CE3E  ld XIY,0x00f06544
	ld	xix, Data_F06562	; F5CE43  ld XIX,0x00f06562
	call	T_DisplayListB_Run	; F5CE48  call 0xf417f4
	call	ModelingPage_PaintFields11And12	; F5CE4C  call 0xf5bf8a
	jr	ToneEditPage_A8_RepaintField_Return4	; F5CE50  jr T,0xf5ce64
ToneEditPage_A8_RepaintField_Skip11:
	ld	(LCD_CurrentLayer:16), 0	; F5CE52  ld (0x2540),0x00
	ld	xiy, DLBRecordPtrs_F065AC	; F5CE57  ld XIY,0x00f065ac
	call	RunDisplayListBFromPointerArray	; F5CE5C  call 0xf09ae1
	call	ToneEditPage_A8_PaintField5Switch	; F5CE60  call 0xf5c27d
ToneEditPage_A8_RepaintField_Return4:
	ret	; F5CE64  ret
; SoundEditModelingToneTemplate_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x82] (also codes 0xA1) -- Dispatch_Code80, the partial repaint.
SoundEditModelingToneTemplate_RepaintField:
	cp	a, 0:i3	; F5CE65  cp A,0
	jr	z, SoundEditModelingToneTemplate_RepaintField_Skip12	; F5CE67  jr Z,0xf5ce8e
	cp	a, 14	; F5CE69  cp A,0x0e
	jr	c, SoundEditModelingToneTemplate_RepaintField_Skip13	; F5CE6C  jr C,0xf5cea3
	ld	xiy, Data_F33B8C	; F5CE6E  ld XIY,0x00f33b8c
	extz	xwa	; F5CE73  extz XWA
	xor	w, w	; F5CE75  xor W,W
	sla	wa, 2	; F5CE77  sla 0x02,WA
	add	xiy, xwa	; F5CE7A  add XIY,XWA
	ld	xiz, xiy	; F5CE7C  ld XIZ,XIY
	ld	xiy, (xiz)	; F5CE7E  ld XIY,(XIZ)
	ld	xix, (xiz+4)	; F5CE80  ld XIX,(XIZ+0x04)
	ld	(LCD_CurrentLayer:16), 0	; F5CE83  ld (0x2540),0x00
	call	T_DisplayListB_Run	; F5CE88  call 0xf417f4
	jr	SoundEditModelingToneTemplate_RepaintField_Return5	; F5CE8C  jr T,0xf5ceb1
SoundEditModelingToneTemplate_RepaintField_Skip12:
	ld	(LCD_CurrentLayer:16), 1	; F5CE8E  ld (0x2540),0x01
	ld	xiy, SoundEditModelingToneTemplate_RepaintField_DL	; F5CE93  ld XIY,0x00f04cde
	ld	xix, DLTable_F04CE8	; F5CE98  ld XIX,0x00f04ce8
	call	T_DisplayList_Run	; F5CE9D  call 0xf417f0
	ld	a, 0:opc	; F5CEA1  ld A,0x00
SoundEditModelingToneTemplate_RepaintField_Skip13:
	ld	xiy, Data_F33B8C	; F5CEA3  ld XIY,0x00f33b8c
	ld	(LCD_CurrentLayer:16), 0	; F5CEA8  ld (0x2540),0x00
	call	RunDisplayListBFromPointerArray	; F5CEAD  call 0xf09ae1
SoundEditModelingToneTemplate_RepaintField_Return5:
	ret	; F5CEB1  ret
; SoundEditPitchTune_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x87] -- Dispatch_Code80, the partial repaint.
SoundEditPitchTune_RepaintField:
	cp	a, 13	; F5CEB2  cp A,0x0d
	jr	z, SoundEditPitchTune_RepaintField_Skip14	; F5CEB5  jr Z,0xf5ced2
	cp	a, 0:i3	; F5CEB7  cp A,0
	jr	nz, SoundEditPitchTune_RepaintField_Join4	; F5CEB9  jr NZ,0xf5cee7
	ld	(LCD_CurrentLayer:16), 1	; F5CEBB  ld (0x2540),0x01
	ld	xiy, SoundEditPitchTune_RepaintField_DL1	; F5CEC0  ld XIY,0x00f0535e
	ld	xix, SoundEditPitchTune_RepaintField_DL2	; F5CEC5  ld XIX,0x00f05368
	call	T_DisplayList_Run	; F5CECA  call 0xf417f0
	ld	a, 0:opc	; F5CECE  ld A,0x00
	jr	SoundEditPitchTune_RepaintField_Join4	; F5CED0  jr T,0xf5cee7
SoundEditPitchTune_RepaintField_Skip14:
	ld	(LCD_CurrentLayer:16), 1	; F5CED2  ld (0x2540),0x01
	ld	xiy, SoundEditPitchTune_RepaintField_DL2	; F5CED7  ld XIY,0x00f05368
	ld	xix, Data_F05372	; F5CEDC  ld XIX,0x00f05372
	call	T_DisplayList_Run	; F5CEE1  call 0xf417f0
	ld	a, 13:opc	; F5CEE5  ld A,0x0d
SoundEditPitchTune_RepaintField_Join4:
	ld	(LCD_CurrentLayer:16), 0	; F5CEE7  ld (0x2540),0x00
	ld	xiy, Data_F05372	; F5CEEC  ld XIY,0x00f05372
	call	RunDisplayListBFromPointerArray	; F5CEF1  call 0xf09ae1
	ret	; F5CEF5  ret
; SoundEditLfo_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x8A] (also codes 0x8F, 0x99) -- Dispatch_Code80, the partial repaint.
SoundEditLfo_RepaintField:
	cp	a, 0:i3	; F5CEF6  cp A,0
	jr	z, SoundEditLfo_RepaintField_Skip15	; F5CEF8  jr Z,0xf5cf0e
	cp	a, 3:i3	; F5CEFA  cp A,3
	jr	z, SoundEditLfo_RepaintField_Skip16	; F5CEFC  jr Z,0xf5cf28
	cp	a, 4:i3	; F5CEFE  cp A,4
	jr	z, SoundEditLfo_RepaintField_Skip17	; F5CF00  jr Z,0xf5cf3d
	cp	a, 50	; F5CF02  cp A,0x32
	jr	z, SoundEditLfo_RepaintField_Skip19	; F5CF05  jr Z,0xf5cf58
	cp	a, 5:i3	; F5CF07  cp A,5
	jr	nc, SoundEditLfo_RepaintField_Skip18	; F5CF09  jr NC,0xf5cf52
	jrl	SoundEditLfo_RepaintField_Join5	; F5CF0B  jrl T,0xf5cf95
SoundEditLfo_RepaintField_Skip15:
	ld	(LCD_CurrentLayer:16), 1	; F5CF0E  ld (0x2540),0x01
	ld	xiy, SoundEditLfo_RepaintField_DL1	; F5CF13  ld XIY,0x00f0549d
	ld	xix, SoundEditLfo_DrawRowLinks_DL1	; F5CF18  ld XIX,0x00f054a7
	call	T_DisplayList_Run	; F5CF1D  call 0xf417f0
	call	SoundEditLfo_DrawField0RowLine	; F5CF21  call 0xf5cfa4
	jrl	SoundEditLfo_RepaintField_Return6	; F5CF25  jrl T,0xf5cfa3
SoundEditLfo_RepaintField_Skip16:
	ld	(LCD_CurrentLayer:16), 0	; F5CF28  ld (0x2540),0x00
	ld	xiy, SoundEditLfo_RepaintField_DL2	; F5CF2D  ld XIY,0x00f053e3
	ld	xix, SoundEditLfo_RepaintField_DL2 + 0x19	; F5CF32  ld XIX,0x00f053fc
	call	T_DisplayListB_Run	; F5CF37  call 0xf417f4
	jr	SoundEditLfo_RepaintField_Return6	; F5CF3B  jr T,0xf5cfa3
SoundEditLfo_RepaintField_Skip17:
	ld	(LCD_CurrentLayer:16), 0	; F5CF3D  ld (0x2540),0x00
	ld	xiy, DL_F053B6	; F5CF42  ld XIY,0x00f053b6
	ld	xix, DL_F053B6 + 0x19	; F5CF47  ld XIX,0x00f053cf
	call	T_DisplayListB_Run	; F5CF4C  call 0xf417f4
	jr	SoundEditLfo_RepaintField_Return6	; F5CF50  jr T,0xf5cfa3
SoundEditLfo_RepaintField_Skip18:
	call	SoundEditLfo_DrawRowLinks	; F5CF52  call 0xf5c5a5
	jr	SoundEditLfo_RepaintField_Return6	; F5CF56  jr T,0xf5cfa3
SoundEditLfo_RepaintField_Skip19:
	ld	(LCD_CurrentLayer:16), 1	; F5CF58  ld (0x2540),0x01
	ld	xiy, SoundEditLfo_RepaintField_DL1	; F5CF5D  ld XIY,0x00f0549d
	ld	xix, SoundEditLfo_DrawRowLinks_DL1	; F5CF62  ld XIX,0x00f054a7
	call	T_DisplayList_Run	; F5CF67  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F5CF6B  ld (0x2540),0x00
	call	SoundEditLfo_PaintOrdinals	; F5CF70  call 0xf5c549
	call	UiPaint_Solo	; F5CF74  call 0xf5bab8
	call	SoundEditLfo_DrawRowLinks	; F5CF78  call 0xf5c5a5
	call	SoundEditLfo_DrawField0RowLine	; F5CF7C  call 0xf5cfa4
	ld	(LCD_CurrentLayer:16), 0	; F5CF80  ld (0x2540),0x00
	ld	xiy, DL_F053B6	; F5CF85  ld XIY,0x00f053b6
	ld	xix, DL_F05407	; F5CF8A  ld XIX,0x00f05407
	call	T_DisplayListB_Run	; F5CF8F  call 0xf417f4
	jr	SoundEditLfo_RepaintField_Return6	; F5CF93  jr T,0xf5cfa3
SoundEditLfo_RepaintField_Join5:
	ld	(LCD_CurrentLayer:16), 0	; F5CF95  ld (0x2540),0x00
	ld	xiy, Data_F05445	; F5CF9A  ld XIY,0x00f05445
	call	RunDisplayListBFromPointerArray	; F5CF9F  call 0xf09ae1
SoundEditLfo_RepaintField_Return6:
	ret	; F5CFA3  ret

; --------------------------------------------------------------------------
; SoundEditLfo_DrawField0RowLine
; Called from: in-module: 0xF5C531 0xF5CF21 0xF5CF7C
; Touches: (0x2540) (0x27A6) (0x27F5)  |  0x000014 0xF04D85 0xF04DA3
;          0xF04E32 0xF04E93 0xF04F32 +22 more
; Calls:   T_DisplayList_Run TouchCurve_DrawCurrentSlot T_DisplayListB_Run 0xF09AE1 Draw_Keyoff SoundEditMemoryWrite_DrawSlotSoundName
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5CFA4 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditLfo_DrawField0RowLine: Erases (op 1B) the box (0xDD,0x44)-(0xED,0xCB), then draws a line from the LF0n row
;   given by page field 0 (rows y 0x44/0x64/0x82/0xA2; 0 counts as 1) right to x 0xED and down to y 0xCB, above the
;   TOUCH caption. Called by the LFO page painter and by SoundEditLfo_RepaintField for field 0 and the whole page.
;   Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave2_e.json)
SoundEditLfo_DrawField0RowLine:
	ld	(LCD_CurrentLayer:16), 0	; F5CFA4  ld (0x2540),0x00
	ld	xiy, SoundEditLfo_DrawField0RowLine_DL	; F5CFA9  ld XIY,0x00f054ed
	ld	xix, SoundEditLfo_DrawRowLinks_DL2	; F5CFAE  ld XIX,0x00f054f7
	call	T_DisplayList_Run	; F5CFB3  call 0xf417f0
	ld	c, (ModelingPage_Fields:16)	; F5CFB7  ld C,(0x27a6)
	xor	b, b	; F5CFBB  xor B,B
	sla	bc, 2	; F5CFBD  sla 0x02,BC
	ld	xiz, Data_F0550B + 0x50	; F5CFC0  ld XIZ,0x00f0555b
	ld	xiy, (xiz+bc)	; F5CFC5  ld XIY,(XIZ+BC)
	ld	xix, xiy	; F5CFCA  ld XIX,XIY
	add	xix, 20	; F5CFCC  add XIX,0x00000014
	call	T_DisplayList_Run	; F5CFD2  call 0xf417f0
	ret	; F5CFD6  ret
; SoundEditAmpLevel1_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x8B] -- Dispatch_Code80, the partial repaint.
SoundEditAmpLevel1_RepaintField:
	cp	(0x27f5:16), 0x01	; F5CFD7  cp (0x27f5),0x01
	jr	nz, SoundEditAmpLevel1_RepaintField_Skip	; F5CFDC  jr NZ,0xf5cfe8
	cp	a, 6:i3	; F5CFDE  cp A,6
	jr	z, SoundEditAmpLevel1_RepaintField_Skip2	; F5CFE0  jr Z,0xf5cfed
	cp	a, 7:i3	; F5CFE2  cp A,7
	jr	z, SoundEditAmpLevel1_RepaintField_Skip2	; F5CFE4  jr Z,0xf5cfed
	jr	SoundEditAmpLevel1_RepaintField_Join	; F5CFE6  jr T,0xf5cff5
SoundEditAmpLevel1_RepaintField_Skip:
	cp	a, 9	; F5CFE8  cp A,0x09
	jr	c, SoundEditAmpLevel1_RepaintField_Join	; F5CFEB  jr C,0xf5cff5
SoundEditAmpLevel1_RepaintField_Skip2:
	push_a	; F5CFED  push A
	call	TouchCurve_DrawCurrentSlot	; F5CFEE  call 0xf5bdbb
	pop_a	; F5CFF2  pop A
	jr	SoundEditAmpLevel1_RepaintField_Join3	; F5CFF3  jr T,0xf5d02a
SoundEditAmpLevel1_RepaintField_Join:
	cp	a, 0:i3	; F5CFF5  cp A,0
	jr	nz, SoundEditAmpLevel1_RepaintField_Join3	; F5CFF7  jr NZ,0xf5d02a
	call	TouchCurve_DrawCurrentSlot	; F5CFF9  call 0xf5bdbb
	cp	(0x27f5:16), 0x01	; F5CFFD  cp (0x27f5),0x01
	jr	z, SoundEditAmpLevel1_RepaintField_Skip3	; F5D002  jr Z,0xf5d015
	ld	(LCD_CurrentLayer:16), 1	; F5D004  ld (0x2540),0x01
	ld	xiy, Data_F05031	; F5D009  ld XIY,0x00f05031
	ld	xix, DLBoxes_F0503B	; F5D00E  ld XIX,0x00f0503b
	jr	SoundEditAmpLevel1_RepaintField_Join2	; F5D013  jr T,0xf5d024
SoundEditAmpLevel1_RepaintField_Skip3:
	ld	(LCD_CurrentLayer:16), 1	; F5D015  ld (0x2540),0x01
	ld	xiy, SoundEditAmpLevel1_RepaintField_DL	; F5D01A  ld XIY,0x00f33836
	ld	xix, DLBoxes_F33840	; F5D01F  ld XIX,0x00f33840
SoundEditAmpLevel1_RepaintField_Join2:
	call	T_DisplayList_Run	; F5D024  call 0xf417f0
	ld	a, 0:opc	; F5D028  ld A,0x00
SoundEditAmpLevel1_RepaintField_Join3:
	ld	(LCD_CurrentLayer:16), 0	; F5D02A  ld (0x2540),0x00
	cp	(0x27f5:16), 0x01	; F5D02F  cp (0x27f5),0x01
	jr	z, SoundEditAmpLevel1_RepaintField_Skip4	; F5D034  jr Z,0xf5d03d
	ld	xiy, Data_F04FFD	; F5D036  ld XIY,0x00f04ffd
	jr	SoundEditAmpLevel1_RepaintField_Join4	; F5D03B  jr T,0xf5d056
SoundEditAmpLevel1_RepaintField_Skip4:
	cp	a, 1:i3	; F5D03D  cp A,1
	jr	nz, SoundEditAmpLevel1_RepaintField_Skip5	; F5D03F  jr NZ,0xf5d051
	ld	xiy, DL_F33796	; F5D041  ld XIY,0x00f33796
	ld	xix, DL_F33796 + 0x59	; F5D046  ld XIX,0x00f337ef
	call	T_DisplayListB_Run	; F5D04B  call 0xf417f4
	jr	SoundEditAmpLevel1_RepaintField_Return	; F5D04F  jr T,0xf5d05a
SoundEditAmpLevel1_RepaintField_Skip5:
	ld	xiy, DLRecordPtrs_F3380E	; F5D051  ld XIY,0x00f3380e
SoundEditAmpLevel1_RepaintField_Join4:
	call	RunDisplayListBFromPointerArray	; F5D056  call 0xf09ae1
SoundEditAmpLevel1_RepaintField_Return:
	ret	; F5D05A  ret
; SoundEditKeyFollow_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x8C] (also codes 0x96) -- Dispatch_Code80, the partial repaint.
SoundEditKeyFollow_RepaintField:
	ld	(LCD_CurrentLayer:16), 0	; F5D05B  ld (0x2540),0x00
	ld	xiy, DLRecordPtrs_F0509B	; F5D060  ld XIY,0x00f0509b
	call	RunDisplayListBFromPointerArray	; F5D065  call 0xf09ae1
	ret	; F5D069  ret
; SoundEditAmpEnvelope1_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x8D] -- Dispatch_Code80, the partial repaint.
SoundEditAmpEnvelope1_RepaintField:
	cp	(0x27f5:16), 0x01	; F5D06A  cp (0x27f5),0x01
	jr	z, SoundEditAmpEnvelope1_RepaintField_Skip6	; F5D06F  jr Z,0xf5d078
	ld	xiy, Data_F050F1	; F5D071  ld XIY,0x00f050f1
	jr	SoundEditAmpEnvelope1_RepaintField_Join5	; F5D076  jr T,0xf5d095
SoundEditAmpEnvelope1_RepaintField_Skip6:
	cp	a, 0:i3	; F5D078  cp A,0
	jr	nz, SoundEditAmpEnvelope1_RepaintField_Skip7	; F5D07A  jr NZ,0xf5d090
	ld	(LCD_CurrentLayer:16), 0	; F5D07C  ld (0x2540),0x00
	ld	xiy, Data_F338A5	; F5D081  ld XIY,0x00f338a5
	call	RunDisplayListBFromPointerArray	; F5D086  call 0xf09ae1
	call	Draw_Keyoff	; F5D08A  call 0xf5c823
	jr	SoundEditAmpEnvelope1_RepaintField_Return2	; F5D08E  jr T,0xf5d09e
SoundEditAmpEnvelope1_RepaintField_Skip7:
	ld	xiy, Data_F338A5	; F5D090  ld XIY,0x00f338a5
SoundEditAmpEnvelope1_RepaintField_Join5:
	ld	(LCD_CurrentLayer:16), 0	; F5D095  ld (0x2540),0x00
	call	RunDisplayListBFromPointerArray	; F5D09A  call 0xf09ae1
SoundEditAmpEnvelope1_RepaintField_Return2:
	ret	; F5D09E  ret
; SoundEditAmpEnvelope2_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x8E] -- Dispatch_Code80, the partial repaint.
SoundEditAmpEnvelope2_RepaintField:
	ld	(LCD_CurrentLayer:16), 0	; F5D09F  ld (0x2540),0x00
	ld	xiy, DLBRecordPtrs_F0519A	; F5D0A4  ld XIY,0x00f0519a
	call	RunDisplayListBFromPointerArray	; F5D0A9  call 0xf09ae1
	ret	; F5D0AD  ret
Draw_LowHigh:
	cp	a, 5:i3	; F5D0AE  cp A,5
	jr	nz, Draw_LowHigh_Skip8	; F5D0B0  jr NZ,0xf5d0c2
	ld	xiy, DL_LowHigh	; F5D0B2  ld XIY,0x00f04d85
	ld	xix, DLBRecordPtrs_F04DA3	; F5D0B7  ld XIX,0x00f04da3
	call	T_DisplayListB_Run	; F5D0BC  call 0xf417f4
	jr	Draw_LowHigh_Return3	; F5D0C0  jr T,0xf5d0d0
Draw_LowHigh_Skip8:
	ld	(LCD_CurrentLayer:16), 0	; F5D0C2  ld (0x2540),0x00
	ld	xiy, DLBRecordPtrs_F04DA3	; F5D0C7  ld XIY,0x00f04da3
	call	RunDisplayListBFromPointerArray	; F5D0CC  call 0xf09ae1
Draw_LowHigh_Return3:
	ret	; F5D0D0  ret
Draw_LowHigh_2:
	cp	a, 5:i3	; F5D0D1  cp A,5
	jr	nz, Draw_LowHigh_2_Skip9	; F5D0D3  jr NZ,0xf5d0ea
	ld	(LCD_CurrentLayer:16), 0	; F5D0D5  ld (0x2540),0x00
	ld	xiy, DL_LowHigh	; F5D0DA  ld XIY,0x00f04d85
	ld	xix, DLBRecordPtrs_F04DA3	; F5D0DF  ld XIX,0x00f04da3
	call	T_DisplayListB_Run	; F5D0E4  call 0xf417f4
	jr	Draw_LowHigh_2_Return4	; F5D0E8  jr T,0xf5d0f8
Draw_LowHigh_2_Skip9:
	ld	(LCD_CurrentLayer:16), 0	; F5D0EA  ld (0x2540),0x00
	ld	xiy, DLBRecordPtrs_F04DA3	; F5D0EF  ld XIY,0x00f04da3
	call	RunDisplayListBFromPointerArray	; F5D0F4  call 0xf09ae1
Draw_LowHigh_2_Return4:
	ret	; F5D0F8  ret
; SoundEditFilterLpf24_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x92] -- Dispatch_Code80, the partial repaint.
SoundEditFilterLpf24_RepaintField:
	ld	(LCD_CurrentLayer:16), 0	; F5D0F9  ld (0x2540),0x00
	ld	xiy, Data_F04E32	; F5D0FE  ld XIY,0x00f04e32
	call	RunDisplayListBFromPointerArray	; F5D103  call 0xf09ae1
	ret	; F5D107  ret
; SoundEditFilterHpf24_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x93] -- Dispatch_Code80, the partial repaint.
SoundEditFilterHpf24_RepaintField:
	ld	(LCD_CurrentLayer:16), 0	; F5D108  ld (0x2540),0x00
	ld	xiy, Data_F04E32	; F5D10D  ld XIY,0x00f04e32
	call	RunDisplayListBFromPointerArray	; F5D112  call 0xf09ae1
	ret	; F5D116  ret
; SoundEditFilterBpf_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x94] -- Dispatch_Code80, the partial repaint.
SoundEditFilterBpf_RepaintField:
	ld	(LCD_CurrentLayer:16), 0	; F5D117  ld (0x2540),0x00
	ld	xiy, DLRecordPtrs_F04E93	; F5D11C  ld XIY,0x00f04e93
	call	RunDisplayListBFromPointerArray	; F5D121  call 0xf09ae1
	ret	; F5D125  ret
; SoundEditEnvelope1_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x88] (also codes 0x97) -- Dispatch_Code80, the partial repaint.
SoundEditEnvelope1_RepaintField:
	cp	a, 0:i3	; F5D126  cp A,0
	jr	nz, SoundEditEnvelope1_RepaintField_Skip10	; F5D128  jr NZ,0xf5d13f
	ld	(LCD_CurrentLayer:16), 1	; F5D12A  ld (0x2540),0x01
	ld	xiy, SoundEditEnvelope1_RepaintField_DL	; F5D12F  ld XIY,0x00f04f32
	ld	xix, Data_F04F46	; F5D134  ld XIX,0x00f04f46
	call	T_DisplayList_Run	; F5D139  call 0xf417f0
	ld	a, 0:opc	; F5D13D  ld A,0x00
SoundEditEnvelope1_RepaintField_Skip10:
	ld	(LCD_CurrentLayer:16), 0	; F5D13F  ld (0x2540),0x00
	ld	xiy, Data_F04F46	; F5D144  ld XIY,0x00f04f46
	call	RunDisplayListBFromPointerArray	; F5D149  call 0xf09ae1
	ret	; F5D14D  ret
Draw_Mem0ryWriteSoundEditName:
	ld	(LCD_CurrentLayer:16), 0	; F5D14E  ld (0x2540),0x00
	cp	(0x27f5:16), 0x01	; F5D153  cp (0x27f5),0x01
	jr	z, Draw_Mem0ryWriteSoundEditName_Skip11	; F5D158  jr Z,0xf5d178
	ld	xiy, DL_Mem0ryWriteSoundEditName	; F5D15A  ld XIY,0x00f0564b
	ld	xix, DLTable_F0574D	; F5D15F  ld XIX,0x00f0574d
	call	T_DisplayList_Run	; F5D164  call 0xf417f0
	ld	xiy, DL_F057C0	; F5D168  ld XIY,0x00f057c0
	ld	xix, DL_MemoryBank	; F5D16D  ld XIX,0x00f057e3
	call	T_DisplayListB_Run	; F5D172  call 0xf417f4
	jr	Draw_Mem0ryWriteSoundEditName_Join6	; F5D176  jr T,0xf5d194
Draw_Mem0ryWriteSoundEditName_Skip11:
	ld	xiy, DL_Mem0ryWriteSoundEditName	; F5D178  ld XIY,0x00f0564b
	ld	xix, DL_Mem0ryWriteSoundEditName + 0xF5	; F5D17D  ld XIX,0x00f05740
	call	T_DisplayList_Run	; F5D182  call 0xf417f0
	ld	xiy, DL_MemoryBank	; F5D186  ld XIY,0x00f057e3
	ld	xix, DLText_UserDrumKits	; F5D18B  ld XIX,0x00f05801
	call	T_DisplayListB_Run	; F5D190  call 0xf417f4
Draw_Mem0ryWriteSoundEditName_Join6:
	call	SoundEditMemoryWrite_DrawSlotSoundName	; F5D194  call 0xf5d199
	ret	; F5D198  ret

; --------------------------------------------------------------------------
; SoundEditMemoryWrite_DrawSlotSoundName
; Called from: in-module: 0xF5D194 0xF5D30E
; Touches: (0x207A) (0x2540) (0x27A6) (0x27A7) (0x27A8) (0x27F5) (0x27F6)  |
;          0xF01800 0xF01873 0xF01E72 0xF01F96 0xF057C0 0xF057E3 +16 more
; Calls:   T_SoundName_Lookup T_DisplayList_Run T_DisplayListB_Run SoundEditNaming_HighlightPaletteChar SoundEditMemoryWrite_DrawSlotSoundName T_DLB_Handler_StringTable
;          T_DisplayListB_RunOne
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5D199 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditMemoryWrite_DrawSlotSoundName: SOUND EDIT MEMORY WRITE: looks up the name of the sound at the selected
;   bank/number -- W = (0x27A6) + 7, A = (0x27A7) - 1; drum kits ((0x27F5) = 1) W = 0x28/0x29 -- with SoundName_Lookup
;   and draws its 16 characters at 0x1701 (swi 7 service 7, 8x16 font). Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_f.json)
SoundEditMemoryWrite_DrawSlotSoundName:
	cp	(0x27f5:16), 0x01	; F5D199  cp (0x27f5),0x01
	jr	z, SoundEditMemoryWrite_DrawSlotSoundName_Skip	; F5D19E  jr Z,0xf5d1b2
	ld	l, (ModelingPage_Fields:16)	; F5D1A0  ld L,(0x27a6)
	inc	7, l	; F5D1A4  inc 7,L
	ld	w, l	; F5D1A6  ld W,L
	ld	h, (ModelingPage_Fields+1:16)	; F5D1A8  ld H,(0x27a7)
	dec	1, h	; F5D1AC  dec 1,H
	ld	a, h	; F5D1AE  ld A,H
	jr	SoundEditMemoryWrite_DrawSlotSoundName_Join	; F5D1B0  jr T,0xf5d1d6
SoundEditMemoryWrite_DrawSlotSoundName_Skip:
	cp	(ModelingPage_Fields+1:16), 0x03	; F5D1B2  cp (0x27a7),0x03
	jr	z, SoundEditMemoryWrite_DrawSlotSoundName_Skip2	; F5D1B7  jr Z,0xf5d1cc
	cp	(ModelingPage_Fields+1:16), 0x04	; F5D1B9  cp (0x27a7),0x04
	jr	z, SoundEditMemoryWrite_DrawSlotSoundName_Skip2	; F5D1BE  jr Z,0xf5d1cc
	ld	w, 40:opc	; F5D1C0  ld W,0x28
	ld	h, (ModelingPage_Fields+1:16)	; F5D1C2  ld H,(0x27a7)
	dec	1, h	; F5D1C6  dec 1,H
	ld	a, h	; F5D1C8  ld A,H
	jr	SoundEditMemoryWrite_DrawSlotSoundName_Join	; F5D1CA  jr T,0xf5d1d6
SoundEditMemoryWrite_DrawSlotSoundName_Skip2:
	ld	w, 41:opc	; F5D1CC  ld W,0x29
	ld	h, (ModelingPage_Fields+1:16)	; F5D1CE  ld H,(0x27a7)
	dec	3, h	; F5D1D2  dec 3,H
	ld	a, h	; F5D1D4  ld A,H
SoundEditMemoryWrite_DrawSlotSoundName_Join:
	ld	b, 0:opc	; F5D1D6  ld B,0x00
	call	T_SoundName_Lookup	; F5D1D8  call 0xf41010
	ldw	bc, 16	; F5D1DC  ld BC,0x0010
	xor	hl, hl	; F5D1DF  xor HL,HL
	ldw	ix, 5889	; F5D1E1  ld IX,0x1701
	ld	a, 7:opc	; F5D1E4  ld A,0x07
	swi	7	; F5D1E6  swi 7
	ret	; F5D1E7  ret
Draw_Write:
	ld	(LCD_CurrentLayer:16), 0	; F5D1E8  ld (0x2540),0x00
	cp	(UI_ScreenLatch:16), 0x9f	; F5D1ED  cp (0x207a),0x9f
	jr	nz, Draw_Write_Skip4	; F5D1F2  jr NZ,0xf5d219
	cp	(0x27f6:16), 0x02	; F5D1F4  cp (0x27f6),0x02
	jr	z, Draw_Write_Skip3	; F5D1F9  jr Z,0xf5d209
	ld	xiy, DL_Write	; F5D1FB  ld XIY,0x00f0582e
	ld	xix, DL_SoundEditS0undNaming	; F5D200  ld XIX,0x00f05850
	call	T_DisplayList_Run	; F5D205  call 0xf417f0
Draw_Write_Skip3:
	ld	xiy, DL_SoundEditS0undNaming	; F5D209  ld XIY,0x00f05850
	ld	xix, Draw_Write_DL2	; F5D20E  ld XIX,0x00f05a2e
	call	T_DisplayList_Run	; F5D213  call 0xf417f0
	jr	Draw_Write_Join2	; F5D217  jr T,0xf5d227
Draw_Write_Skip4:
	ld	xiy, DL_ClrP0siti0nAbcInsDelAA	; F5D219  ld XIY,0x00f0587c
	ld	xix, Draw_Write_DL2	; F5D21E  ld XIX,0x00f05a2e
	call	T_DisplayList_Run	; F5D223  call 0xf417f0
Draw_Write_Join2:
	cp	(ModelingPage_Fields+2:16), 0x10	; F5D227  cp (0x27a8),0x10
	jr	z, Draw_Write_Skip5	; F5D22C  jr Z,0xf5d257
	cp	(ModelingPage_Fields+2:16), 0x02	; F5D22E  cp (0x27a8),0x02
	jr	z, Draw_Write_Skip6	; F5D233  jr Z,0xf5d279
	ld	xiy, Draw_Write_DL1	; F5D235  ld XIY,0x00f05a38
	ld	xix, Draw_Write_DL3	; F5D23A  ld XIX,0x00f05a42
	call	T_DisplayList_Run	; F5D23F  call 0xf417f0
	ld	xiy, DL_F05A68	; F5D243  ld XIY,0x00f05a68
	ld	xix, DL_F05A84	; F5D248  ld XIX,0x00f05a84
	call	T_DisplayListB_Run	; F5D24D  call 0xf417f4
	call	SoundEditNaming_HighlightPaletteChar	; F5D251  call 0xf5d3c6
	jr	Draw_Write_Return	; F5D255  jr T,0xf5d299
Draw_Write_Skip5:
	ld	xiy, Draw_Write_DL2	; F5D257  ld XIY,0x00f05a2e
	ld	xix, Draw_Write_DL1	; F5D25C  ld XIX,0x00f05a38
	call	T_DisplayList_Run	; F5D261  call 0xf417f0
	ld	xiy, DL_F05A4C	; F5D265  ld XIY,0x00f05a4c
	ld	xix, DL_F05A68	; F5D26A  ld XIX,0x00f05a68
	call	T_DisplayListB_Run	; F5D26F  call 0xf417f4
	call	SoundEditNaming_HighlightPaletteChar	; F5D273  call 0xf5d3c6
	jr	Draw_Write_Return	; F5D277  jr T,0xf5d299
Draw_Write_Skip6:
	ld	xiy, Draw_Write_DL3	; F5D279  ld XIY,0x00f05a42
	ld	xix, DL_F05A4C	; F5D27E  ld XIX,0x00f05a4c
	call	T_DisplayList_Run	; F5D283  call 0xf417f0
	ld	xiy, DL_F05A84	; F5D287  ld XIY,0x00f05a84
	ld	xix, SoundEditNaming_RepaintField_DL2	; F5D28C  ld XIX,0x00f05aa0
	call	T_DisplayListB_Run	; F5D291  call 0xf417f4
	call	SoundEditNaming_HighlightPaletteChar	; F5D295  call 0xf5d3c6
Draw_Write_Return:
	ret	; F5D299  ret
; Dispatch_Code80_PaintNoAction: Dispatch_Code80_PaintTable[0x2A]: a lone `ret` for screen codes 0xAA (power-on
;   splash) and 0xCA (SOUND EDIT DSP EFFECT, which paints from its ENTER). Basis: table index + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
Dispatch_Code80_PaintNoAction:
	ret	; F5D29A  ret
; SoundEditDrumMenu_Paint: Dispatch_Code80_PaintTable[code 0xAB] -- Dispatch_Code80_Bracketed, the full paint.
SoundEditDrumMenu_Paint:
	ld	(LCD_CurrentLayer:16), 0	; F5D29B  ld (0x2540),0x00
	ld	xiy, DL_SoundEditWriteCopy	; F5D2A0  ld XIY,0x00f01800
	ld	xix, DL_ToneLayerDspEffectPitchDigital	; F5D2A5  ld XIX,0x00f01873
	call	T_DisplayList_Run	; F5D2AA  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F5D2AE  ld (0x2540),0x00
	ld	xiy, DL_EffectSendOutputDspEffect	; F5D2B3  ld XIY,0x00f01e72
	ld	xix, DL_M0delingSoundEditToneDriver	; F5D2B8  ld XIX,0x00f01f96
	call	T_DisplayList_Run	; F5D2BD  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F5D2C1  ld (0x2540),0x00
	ld	xiy, DL_F33538	; F5D2C6  ld XIY,0x00f33538
	ld	xix, Data_F3356B	; F5D2CB  ld XIX,0x00f3356b
	call	T_DisplayListB_Run	; F5D2D0  call 0xf417f4
	ret	; F5D2D4  ret
; SoundEditDrumMenu_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0xAB] -- Dispatch_Code80, the partial repaint.
SoundEditDrumMenu_RepaintField:
	ld	(LCD_CurrentLayer:16), 0	; F5D2D5  ld (0x2540),0x00
	ld	xiy, DL_F33538	; F5D2DA  ld XIY,0x00f33538
	ld	xix, Data_F3356B	; F5D2DF  ld XIX,0x00f3356b
	call	T_DisplayListB_Run	; F5D2E4  call 0xf417f4
	ret	; F5D2E8  ret
; SoundEditMemoryWrite_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x9E] -- Dispatch_Code80, the partial repaint.
SoundEditMemoryWrite_RepaintField:
	cp	(0x27f5:16), 0x01	; F5D2E9  cp (0x27f5),0x01
	jr	z, SoundEditMemoryWrite_RepaintField_Skip7	; F5D2EE  jr Z,0xf5d300
	ld	xiy, DL_F057C0	; F5D2F0  ld XIY,0x00f057c0
	ld	xix, DL_MemoryBank	; F5D2F5  ld XIX,0x00f057e3
	call	T_DisplayListB_Run	; F5D2FA  call 0xf417f4
	jr	SoundEditMemoryWrite_RepaintField_Join3	; F5D2FE  jr T,0xf5d30e
SoundEditMemoryWrite_RepaintField_Skip7:
	ld	xiy, DL_MemoryBank	; F5D300  ld XIY,0x00f057e3
	ld	xix, DLText_UserDrumKits	; F5D305  ld XIX,0x00f05801
	call	T_DisplayListB_Run	; F5D30A  call 0xf417f4
SoundEditMemoryWrite_RepaintField_Join3:
	call	SoundEditMemoryWrite_DrawSlotSoundName	; F5D30E  call 0xf5d199
	ret	; F5D312  ret
; SoundEditNaming_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x9F] -- Dispatch_Code80, the partial repaint.
SoundEditNaming_RepaintField:
	cp	a, 0:i3	; F5D313  cp A,0
	jr	z, SoundEditNaming_RepaintField_Skip11	; F5D315  jr Z,0xf5d362
	cp	a, 1:i3	; F5D317  cp A,1
	jr	z, SoundEditNaming_RepaintField_Skip8	; F5D319  jr Z,0xf5d31f
	cp	a, 2:i3	; F5D31B  cp A,2
	jr	z, SoundEditNaming_RepaintField_Skip12	; F5D31D  jr Z,0xf5d384
SoundEditNaming_RepaintField_Skip8:
	ld	(LCD_CurrentLayer:16), 1	; F5D31F  ld (0x2540),0x01
	ld	xiy, SoundEditNaming_RepaintField_DL1	; F5D324  ld XIY,0x00f05aaa
	ld	xix, DLBoxes_F05AB4	; F5D329  ld XIX,0x00f05ab4
	call	T_DisplayList_Run	; F5D32E  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F5D332  ld (0x2540),0x00
	cp	(ModelingPage_Fields+2:16), 0x0d	; F5D337  cp (0x27a8),0x0d
	jr	z, SoundEditNaming_RepaintField_Skip9	; F5D33C  jr Z,0xf5d34c
	cp	(ModelingPage_Fields+2:16), 0x02	; F5D33E  cp (0x27a8),0x02
	jr	z, SoundEditNaming_RepaintField_Skip10	; F5D343  jr Z,0xf5d353
	ld	xiy, DL_F05A4C	; F5D345  ld XIY,0x00f05a4c
	jr	SoundEditNaming_RepaintField_Join4	; F5D34A  jr T,0xf5d358
SoundEditNaming_RepaintField_Skip9:
	ld	xiy, DL_F05A68	; F5D34C  ld XIY,0x00f05a68
	jr	SoundEditNaming_RepaintField_Join4	; F5D351  jr T,0xf5d358
SoundEditNaming_RepaintField_Skip10:
	ld	xiy, DL_F05A84	; F5D353  ld XIY,0x00f05a84
SoundEditNaming_RepaintField_Join4:
	call	T_DLB_Handler_StringTable	; F5D358  call 0xf417f8
	call	SoundEditNaming_HighlightPaletteChar	; F5D35C  call 0xf5d3c6
	jr	SoundEditNaming_RepaintField_Return2	; F5D360  jr T,0xf5d3c5
SoundEditNaming_RepaintField_Skip11:
	ld	(LCD_CurrentLayer:16), 1	; F5D362  ld (0x2540),0x01
	ld	xiy, SoundEditNaming_RepaintField_DL2	; F5D367  ld XIY,0x00f05aa0
	ld	xix, DLBoxes_F05AB4	; F5D36C  ld XIX,0x00f05ab4
	call	T_DisplayList_Run	; F5D371  call 0xf417f0
	ld	xiy, DL_F05A4C + 0x11	; F5D375  ld XIY,0x00f05a5d
	call	T_DisplayListB_RunOne	; F5D37A  call 0xf41830
	call	SoundEditNaming_HighlightPaletteChar	; F5D37E  call 0xf5d3c6
	jr	SoundEditNaming_RepaintField_Return2	; F5D382  jr T,0xf5d3c5
SoundEditNaming_RepaintField_Skip12:
	ld	(LCD_CurrentLayer:16), 1	; F5D384  ld (0x2540),0x01
	ld	xiy, SoundEditNaming_RepaintField_DL2	; F5D389  ld XIY,0x00f05aa0
	ld	xix, DLBoxes_F05AB4	; F5D38E  ld XIX,0x00f05ab4
	call	T_DisplayList_Run	; F5D393  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F5D397  ld (0x2540),0x00
	cp	(ModelingPage_Fields+2:16), 0x0d	; F5D39C  cp (0x27a8),0x0d
	jr	z, SoundEditNaming_RepaintField_Skip13	; F5D3A1  jr Z,0xf5d3b3
	ld	xiy, DL_F05A4C	; F5D3A3  ld XIY,0x00f05a4c
	ld	xix, DL_F05A68	; F5D3A8  ld XIX,0x00f05a68
	call	T_DisplayListB_Run	; F5D3AD  call 0xf417f4
	jr	SoundEditNaming_RepaintField_Join5	; F5D3B1  jr T,0xf5d3c1
SoundEditNaming_RepaintField_Skip13:
	ld	xiy, DL_F05A68	; F5D3B3  ld XIY,0x00f05a68
	ld	xix, DL_F05A84	; F5D3B8  ld XIX,0x00f05a84
	call	T_DisplayListB_Run	; F5D3BD  call 0xf417f4
SoundEditNaming_RepaintField_Join5:
	call	SoundEditNaming_HighlightPaletteChar	; F5D3C1  call 0xf5d3c6
SoundEditNaming_RepaintField_Return2:
	ret	; F5D3C5  ret

; --------------------------------------------------------------------------
; SoundEditNaming_HighlightPaletteChar
; Called from: in-module: 0xF5D251 0xF5D273 0xF5D295 0xF5D35C 0xF5D37E
;              0xF5D3C1
; Touches: (0x2530) (0x2532) (0x2534) (0x2536) (0x2540) (0x27A7)  |
;          0xF05B34 0xF05B54 0xF05F78 0xF06048 0xF060DA 0xF328DC +2 more
; Calls:   DisplayList_Run_T0neLayerSoundEditTrigGer T_DisplayList_Run T_DisplayListB_Run SoundEditToneLayerPanning_PaintPanAmounts SoundEditToneLayerPanning_DrawChordTriggers 0xF5BAB8
;          SoundEdit_PaintSlotOrdinals
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5D3C6 is an instruction boundary.
;           The name IS the address.
; Purpose: none -- the entry is a lone `ret`.  Named Dispatch_Code80_RepaintFieldNoAction after what reaches it
;          (was sub_F5D40D; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
; SoundEditNaming_HighlightPaletteChar: ModelingPage_Fields+1 = v: fills (SWI7 service 5) the 8x14 cell at column v %
;   16, row v / 16 of a 16 x 6 grid (x 0x20 + 16k, y 0x67 + 15k) -- the character cursor. The SOUND NAMING page's
;   paint (Draw_Write) and field repaint call it. Basis: callers + body + cell tables. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_c.json)
SoundEditNaming_HighlightPaletteChar:
	xor	wa, wa	; F5D3C6  xor WA,WA
	ld	a, (ModelingPage_Fields+1:16)	; F5D3C8  ld A,(0x27a7)
	div	a, 16	; F5D3CC  div A,0x10
	ld	xiz, Data_F05B34	; F5D3CF  ld XIZ,0x00f05b34
	xor	hl, hl	; F5D3D4  xor HL,HL
	ld	l, w	; F5D3D6  ld L,W
	sla	hl, 1	; F5D3D8  sla 0x01,HL
	ld	ix, (xiz+hl)	; F5D3DB  ld IX,(XIZ+HL)
	ld	(LCD_X0:16), ix	; F5D3E0  ld (0x2530),IX
	add	ix, 8	; F5D3E4  add IX,0x0008
	ld	(LCD_X1:16), ix	; F5D3E8  ld (0x2534),IX
	ld	xiz, Data_F05B34 + 0x20	; F5D3EC  ld XIZ,0x00f05b54
	xor	hl, hl	; F5D3F1  xor HL,HL
	ld	l, a	; F5D3F3  ld L,A
	sla	hl, 1	; F5D3F5  sla 0x01,HL
	ld	ix, (xiz+hl)	; F5D3F8  ld IX,(XIZ+HL)
	ld	(LCD_Y0:16), ix	; F5D3FD  ld (0x2532),IX
	add	ix, 14	; F5D401  add IX,0x000e
	ld	(LCD_Y1:16), ix	; F5D405  ld (0x2536),IX
	ld	a, 5:opc	; F5D409  ld A,0x05
	swi	7	; F5D40B  swi 7
	ret	; F5D40C  ret
; Dispatch_Code80_RepaintFieldNoAction: Dispatch_Code80_RepaintFieldTable[0x2A]: a lone `ret` for screen codes 0xAA
;   (power-on splash) and 0xCA (SOUND EDIT DSP EFFECT). Basis: table index + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
Dispatch_Code80_RepaintFieldNoAction:
	ret	; F5D40D  ret
; SoundEditToneLayerPanning_Paint: Dispatch_Code80_PaintTable[code 0x83] -- Dispatch_Code80_Bracketed, the full paint.
SoundEditToneLayerPanning_Paint:
	call	DisplayList_Run_T0neLayerSoundEditTrigGer	; F5D40E  call 0xf5c49f
	ldw	bc, ModelingPage_Fields+16	; F5D412  ld BC,0x27b6
	ld	d, (xbc)	; F5D415  ld D,(XBC)
	cp	d, 0:i3	; F5D417  cp D,0
	jr	z, SoundEditToneLayerPanning_Paint_Skip	; F5D419  jr Z,0xf5d43d
	ld	xiy, DL_PanningPanning	; F5D41B  ld XIY,0x00f06048
	ld	xix, DL_F060DA	; F5D420  ld XIX,0x00f060da
	call	T_DisplayList_Run	; F5D425  call 0xf417f0
	ld	xiy, DL_F3294B	; F5D429  ld XIY,0x00f3294b
	ld	xix, Data_F32992	; F5D42E  ld XIX,0x00f32992
	call	T_DisplayListB_Run	; F5D433  call 0xf417f4
	call	SoundEditToneLayerPanning_PaintPanAmounts	; F5D437  call 0xf5d497
	jr	SoundEditToneLayerPanning_Paint_Join	; F5D43B  jr T,0xf5d45d
SoundEditToneLayerPanning_Paint_Skip:
	ld	xiy, DL_TriggerDelayTriggerDelay	; F5D43D  ld XIY,0x00f05f78
	ld	xix, DL_PanningPanning	; F5D442  ld XIX,0x00f06048
	call	T_DisplayList_Run	; F5D447  call 0xf417f0
	ld	xiy, DL_F328DC	; F5D44B  ld XIY,0x00f328dc
	ld	xix, DL_F3294B	; F5D450  ld XIX,0x00f3294b
	call	T_DisplayListB_Run	; F5D455  call 0xf417f4
	call	SoundEditToneLayerPanning_DrawChordTriggers	; F5D459  call 0xf5d46b
SoundEditToneLayerPanning_Paint_Join:
	ld	(LCD_CurrentLayer:16), 0	; F5D45D  ld (0x2540),0x00
	call	UiPaint_Solo	; F5D462  call 0xf5bab8
	call	SoundEdit_PaintSlotOrdinals	; F5D466  call 0xf5c39c
	ret	; F5D46A  ret

; --------------------------------------------------------------------------
; SoundEditToneLayerPanning_DrawChordTriggers
; Called from: in-module: 0xF5D459 0xF5D664
; Touches: nothing with an absolute address
; Calls:   SoundEditToneLayerPanning_DrawFieldChordTrigger
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5D46B is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditToneLayerPanning_DrawChordTriggers: TONE LAYER page, TRIGGER/DELAY view: for each tone field 2..5
;   (ModelingPage_Fields) whose bit 7 is set, draws entry 1 of DLText_NonLegChord ('CHORD ') over that tone's TRIGGER
;   cell (DL_F329FA + 15k, same positions as the KEY ON/KEY OFF/LEGATO text). Basis: callers + body + data.
;   (notes/naming-pilot-2026-10-06/proposals_wave2_d.json)
SoundEditToneLayerPanning_DrawChordTriggers:
	ld	a, 2:opc	; F5D46B  ld A,0x02
SoundEditToneLayerPanning_DrawChordTriggers_Loop:
	push_a	; F5D46D  push A
	call	SoundEditToneLayerPanning_DrawFieldChordTrigger	; F5D46E  call 0xf5d47a
	pop_a	; F5D472  pop A
	inc	1, a	; F5D473  inc 1,A
	cp	a, 6:i3	; F5D475  cp A,6
	jr	c, SoundEditToneLayerPanning_DrawChordTriggers_Loop	; F5D477  jr C,0xf5d46d
	ret	; F5D479  ret

; --------------------------------------------------------------------------
; SoundEditToneLayerPanning_DrawFieldChordTrigger
; Called from: in-module: 0xF5D46E
; Touches: (0x2540)  |  0xF32A36
; Calls:   0xF09AE1
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5D47A is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditToneLayerPanning_DrawFieldChordTrigger: For tone field A (2..5): when ModelingPage_Fields[A] bit 7 is set,
;   runs record [A] of the pointer array Data_F32A36 (DL_F329FA + 15k, the tone's TRIGGER cell) on layer 0 through
;   RunDisplayListBFromPointerArray -- the 'CHORD' mark. SoundEditToneLayerPanning_DrawChordTriggers calls it for A =
;   2..5. Basis: caller + body + pointer array. (notes/naming-pilot-2026-10-06/proposals_wave4_k.json)
SoundEditToneLayerPanning_DrawFieldChordTrigger:
	xor	w, w	; F5D47A  xor W,W
	ldw	bc, ModelingPage_Fields	; F5D47C  ld BC,0x27a6
	add	bc, wa	; F5D47F  add BC,WA
	ld	d, (xbc)	; F5D481  ld D,(XBC)
	and	d, 128	; F5D483  and D,0x80
	jr	z, SoundEditToneLayerPanning_DrawFieldChordTrigger_Return	; F5D486  jr Z,0xf5d496
	ld	xiy, Data_F32A36	; F5D488  ld XIY,0x00f32a36
	ld	(LCD_CurrentLayer:16), 0	; F5D48D  ld (0x2540),0x00
	call	RunDisplayListBFromPointerArray	; F5D492  call 0xf09ae1
SoundEditToneLayerPanning_DrawFieldChordTrigger_Return:
	ret	; F5D496  ret

; --------------------------------------------------------------------------
; SoundEditToneLayerPanning_PaintPanAmounts
; Called from: in-module: 0xF5D437 0xF5D64B
; Touches: nothing with an absolute address
; Calls:   SoundEditToneLayerPanning_PaintPanAmountField
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5D497 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditToneLayerPanning_PaintPanAmounts: For fields 12..15 of the TONE LAYER PANNING page (layers 1..4's pan
;   amount) runs record [n] of Data_F32992+0x28 -- a decimal readout of ModelingPage_Fields+n -- skipping zero amounts
;   (centre). prom_a's ToneLayerPan_SplitSideAndAmount (ToneLayerPan_SplitSideAndAmount) writes these fields. Called by the page's Paint
;   and RepaintField. Basis: callers + body + writer. (notes/naming-pilot-2026-10-06/proposals_wave2_e.json)
SoundEditToneLayerPanning_PaintPanAmounts:
	ld	a, 12:opc	; F5D497  ld A,0x0c
SoundEditToneLayerPanning_PaintPanAmounts_Loop:
	push_a	; F5D499  push A
	call	SoundEditToneLayerPanning_PaintPanAmountField	; F5D49A  call 0xf5d4a7
	pop_a	; F5D49E  pop A
	inc	1, a	; F5D49F  inc 1,A
	cp	a, 16	; F5D4A1  cp A,0x10
	jr	c, SoundEditToneLayerPanning_PaintPanAmounts_Loop	; F5D4A4  jr C,0xf5d499
	ret	; F5D4A6  ret

; --------------------------------------------------------------------------
; SoundEditToneLayerPanning_PaintPanAmountField
; Called from: in-module: 0xF5D49A
; Touches: (0x2350) (0x2352) (0x2540)  |  0xF03F31 0xF03F77 0xF0426B
;          0xF04323 0xF04344 0xF04358 +11 more
; Calls:   0xF09AE1 DisplayList_Run_T0neLayerSoundEditTrigGer_T0neSelectSoundEdit T_DisplayList_Run KeyboardIcon_Draw 0xF5BAB8 0xF5BB00
;          T_DisplayListB_Run Draw_PitchSoundEditEnvPitchLf0 SoundEdit_PaintPageLabelBackdrop Draw_Page12EnvelopeKeyoffCurSor Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack SoundEditFilter_PaintHeader
;          +1 more
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5D4A7 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditToneLayerPanning_PaintPanAmountField: For field A (12..15, layer 1..4's pan amount): when
;   ModelingPage_Fields[A] is non-zero (zero = centre) runs record [A] of the pointer array Data_F32992+0x28 on layer
;   0 (RunDisplayListBFromPointerArray). SoundEditToneLayerPanning_PaintPanAmounts calls it for A = 12..15. Basis:
;   caller + body. (notes/naming-pilot-2026-10-06/proposals_wave4_l.json)
SoundEditToneLayerPanning_PaintPanAmountField:
	xor	w, w	; F5D4A7  xor W,W
	ldw	bc, ModelingPage_Fields	; F5D4A9  ld BC,0x27a6
	add	bc, wa	; F5D4AC  add BC,WA
	ld	d, (xbc)	; F5D4AE  ld D,(XBC)
	cp	d, 0:i3	; F5D4B0  cp D,0
	jr	z, SoundEditToneLayerPanning_PaintPanAmountField_Return	; F5D4B2  jr Z,0xf5d4c2
	ld	xiy, Data_F32992 + 0x28	; F5D4B4  ld XIY,0x00f329ba
	ld	(LCD_CurrentLayer:16), 0	; F5D4B9  ld (0x2540),0x00
	call	RunDisplayListBFromPointerArray	; F5D4BE  call 0xf09ae1
SoundEditToneLayerPanning_PaintPanAmountField_Return:
	ret	; F5D4C2  ret
; SoundEditToneLayerKeyLayer_Paint: Dispatch_Code80_PaintTable[code 0x84] -- Dispatch_Code80_Bracketed, the full paint.
SoundEditToneLayerKeyLayer_Paint:
	call	DisplayList_Run_T0neLayerSoundEditTrigGer_T0neSelectSoundEdit	; F5D4C3  call 0xf5c4b8
	ld	(LCD_CurrentLayer:16), 0	; F5D4C7  ld (0x2540),0x00
	ld	xiy, SoundEditToneLayerKeyLayer_Paint_DL1	; F5D4CC  ld XIY,0x00f060e4
	ld	xix, SoundEditToneLayerVelocityLayer_Paint_DL1	; F5D4D1  ld XIX,0x00f06154
	call	T_DisplayList_Run	; F5D4D6  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 2	; F5D4DA  ld (0x2540),0x02
	ld	xiy, DL_F060DA	; F5D4DF  ld XIY,0x00f060da
	ld	xix, SoundEditToneLayerKeyLayer_Paint_DL1	; F5D4E4  ld XIX,0x00f060e4
	call	T_DisplayList_Run	; F5D4E9  call 0xf417f0
	ldw	(IconOrigin_X:16), 47	; F5D4ED  ld (0x2350),0x002f
	ldw	(IconOrigin_Y:16), 51	; F5D4F3  ld (0x2352),0x0033
	call	KeyboardIcon_Draw	; F5D4F9  call 0xf5bbe7
	call	UiPaint_Solo	; F5D4FD  call 0xf5bab8
	call	UiPaint_Ordinals	; F5D501  call 0xf5bb00
	ld	(LCD_CurrentLayer:16), 0	; F5D505  ld (0x2540),0x00
	ld	xiy, SoundEditToneLayerKeyLayer_Paint_DL2	; F5D50A  ld XIY,0x00f32ad7
	ld	xix, Data_F32B1E	; F5D50F  ld XIX,0x00f32b1e
	call	T_DisplayListB_Run	; F5D514  call 0xf417f4
	ret	; F5D518  ret
; SoundEditToneLayerVelocityLayer_Paint: Dispatch_Code80_PaintTable[code 0x85] -- Dispatch_Code80_Bracketed, the full paint.
SoundEditToneLayerVelocityLayer_Paint:
	call	DisplayList_Run_T0neLayerSoundEditTrigGer_T0neSelectSoundEdit	; F5D519  call 0xf5c4b8
	ld	(LCD_CurrentLayer:16), 0	; F5D51D  ld (0x2540),0x00
	ld	xiy, SoundEditToneLayerVelocityLayer_Paint_DL1	; F5D522  ld XIY,0x00f06154
	ld	xix, DL_EffectBlockEff1Eff2RevMain	; F5D527  ld XIX,0x00f06224
	call	T_DisplayList_Run	; F5D52C  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 2	; F5D530  ld (0x2540),0x02
	ld	xiy, DL_F060DA	; F5D535  ld XIY,0x00f060da
	ld	xix, SoundEditToneLayerKeyLayer_Paint_DL1	; F5D53A  ld XIX,0x00f060e4
	call	T_DisplayList_Run	; F5D53F  call 0xf417f0
	call	UiPaint_Solo	; F5D543  call 0xf5bab8
	call	UiPaint_Ordinals	; F5D547  call 0xf5bb00
	ld	(LCD_CurrentLayer:16), 0	; F5D54B  ld (0x2540),0x00
	ld	xiy, SoundEditToneLayerVelocityLayer_Paint_DL2	; F5D550  ld XIY,0x00f32b64
	ld	xix, DLRecordPtrs_F32B97	; F5D555  ld XIX,0x00f32b97
	call	T_DisplayListB_Run	; F5D55A  call 0xf417f4
	ret	; F5D55E  ret
Draw_StartPitchStopPitchTotal:
	call	Draw_PitchSoundEditEnvPitchLf0	; F5D55F  call 0xf5c4ff
	ld	xiy, DL_StartPitchStopPitchTotal	; F5D563  ld XIY,0x00f03f31
	ld	xix, SoundEditAmp_PaintHeader_DL	; F5D568  ld XIX,0x00f03f77
	call	T_DisplayList_Run	; F5D56D  call 0xf417f0
	call	SoundEdit_PaintPageLabelBackdrop	; F5D571  call 0xf5bfbd
	call	Draw_Page12EnvelopeKeyoffCurSor	; F5D575  call 0xf5cadd
	ret	; F5D579  ret
; SoundEditPitchEnvelope2_Paint: Dispatch_Code80_PaintTable[code 0x89] -- Dispatch_Code80_Bracketed, the full paint.
SoundEditPitchEnvelope2_Paint:
	call	Draw_PitchSoundEditEnvPitchLf0	; F5D57A  call 0xf5c4ff
	call	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack	; F5D57E  call 0xf5d5c8
	ret	; F5D582  ret
; SoundEditFilterKeyFollow_Paint: Dispatch_Code80_PaintTable[code 0x96] -- Dispatch_Code80_Bracketed, the full paint.
SoundEditFilterKeyFollow_Paint:
	call	SoundEditFilter_PaintHeader	; F5D583  call 0xf5c929
	ld	xiy, DL_Page22KeyFollowSlopeRange	; F5D587  ld XIY,0x00f0426b
	ld	xix, DL_Page22KeyFollowSlopeRange + 0xB8	; F5D58C  ld XIX,0x00f04323
	call	T_DisplayList_Run	; F5D591  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 2	; F5D595  ld (0x2540),0x02
	ld	xiy, DL_F04344	; F5D59A  ld XIY,0x00f04344
	ld	xix, DL_EnvelopeKeyoffAtkPeakDecay1	; F5D59F  ld XIX,0x00f04358
	call	T_DisplayList_Run	; F5D5A4  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F5D5A8  ld (0x2540),0x00
	ld	xiy, DL_FilterKeyFollow	; F5D5AD  ld XIY,0x00f065e0
	ld	xix, DL_Lf01Lf02Lf03Lf04Lf0WaveDelay	; F5D5B2  ld XIX,0x00f06601
	call	T_DisplayList_Run	; F5D5B7  call 0xf417f0
	call	SoundEdit_PaintPageLabelBackdrop	; F5D5BB  call 0xf5bfbd
	call	SoundEditFilterKeyFollow_PaintKeyboardAndValues	; F5D5BF  call 0xf5c772
	ret	; F5D5C3  ret
; SoundEditFilterEnvelope2_Paint: Dispatch_Code80_PaintTable[code 0x98] -- Dispatch_Code80_Bracketed, the full paint.
SoundEditFilterEnvelope2_Paint:
	call	SoundEditFilter_PaintHeader	; F5D5C4  call 0xf5c929

; --------------------------------------------------------------------------
; Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack
; Called from: in-module: 0xF5D57E
; Touches: (0x2350) (0x2352) (0x2540) (0x27F5)  |  0xF04B6C 0xF04CA9
;          0xF04CBD 0xF328DC 0xF32918 0xF3294B +18 more
; Calls:   T_DisplayList_Run SoundEdit_PaintPageLabelBackdrop KeyboardIcon_Draw 0xF5BAB8 0xF5BB00 T_DisplayListB_Run
;          SoundEditFilter_PaintHeader Draw_Lf01Lf02Lf03Lf04Lf0WaveDelay SoundEditAmp_PaintHeader SoundEditToneLayerPanning_PaintPanAmounts SoundEditToneLayerPanning_DrawChordTriggers 0xF09AE1
;          +2 more
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5D5C8 is an instruction boundary.
; Name:    from the one text-named display list it STARTS, DL_Page22KeyFollowEnvelopeKeyFollowTouchAttack (the
;          interpreter's XIY or last-pushed operand); it claims that list, not
;          a screen or a purpose (scripts/renaming/rename_wsa1_dl_drawers.py).
; Unknown: what the routine is FOR.
; --------------------------------------------------------------------------
Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack:
	ld	xiy, DL_Page22KeyFollowEnvelopeKeyFollowTouchAttack	; F5D5C8  ld XIY,0x00f04b6c
	ld	xix, Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_DL1	; F5D5CD  ld XIX,0x00f04ca9
	call	T_DisplayList_Run	; F5D5D2  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 2	; F5D5D6  ld (0x2540),0x02
	ld	xiy, Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_DL1	; F5D5DB  ld XIY,0x00f04ca9
	ld	xix, DLTable_ABCDEFGHIJKLMNOPQRSU	; F5D5E0  ld XIX,0x00f04cbd
	call	T_DisplayList_Run	; F5D5E5  call 0xf417f0
	call	SoundEdit_PaintPageLabelBackdrop	; F5D5E9  call 0xf5bfbd
	ldw	(IconOrigin_X:16), 56	; F5D5ED  ld (0x2350),0x0038
	ldw	(IconOrigin_Y:16), 139	; F5D5F3  ld (0x2352),0x008b
	call	KeyboardIcon_Draw	; F5D5F9  call 0xf5bbe7
	call	UiPaint_Solo	; F5D5FD  call 0xf5bab8
	call	UiPaint_Ordinals	; F5D601  call 0xf5bb00
	ld	(LCD_CurrentLayer:16), 0	; F5D605  ld (0x2540),0x00
	ld	xiy, Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_DL2	; F5D60A  ld XIY,0x00f32bab
	ld	xix, Data_F32C02	; F5D60F  ld XIX,0x00f32c02
	call	T_DisplayListB_Run	; F5D614  call 0xf417f4
	ret	; F5D618  ret
; SoundEditFilterLfo_Paint: Dispatch_Code80_PaintTable[code 0x99] -- Dispatch_Code80_Bracketed, the full paint.
SoundEditFilterLfo_Paint:
	call	SoundEditFilter_PaintHeader	; F5D619  call 0xf5c929
	call	Draw_Lf01Lf02Lf03Lf04Lf0WaveDelay	; F5D61D  call 0xf5c517
	ret	; F5D621  ret
; SoundEditAmpLfo_Paint: Dispatch_Code80_PaintTable[code 0x8F] -- Dispatch_Code80_Bracketed, the full paint.
SoundEditAmpLfo_Paint:
	call	SoundEditAmp_PaintHeader	; F5D622  call 0xf5c727
	call	Draw_Lf01Lf02Lf03Lf04Lf0WaveDelay	; F5D626  call 0xf5c517
	ret	; F5D62A  ret
; SoundEditToneLayerPanning_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x83] -- Dispatch_Code80, the partial repaint.
SoundEditToneLayerPanning_RepaintField:
	cp	a, 0:i3	; F5D62B  cp A,0
	jr	z, Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Skip2	; F5D62D  jr Z,0xf5d66a
	cp	a, 1:i3	; F5D62F  cp A,1
	jr	z, Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Skip	; F5D631  jr Z,0xf5d651
	cp	a, 11	; F5D633  cp A,0x0b
	jr	c, Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Skip3	; F5D636  jr C,0xf5d69d
	ld	(LCD_CurrentLayer:16), 0	; F5D638  ld (0x2540),0x00
	ld	xiy, DL_F3294B	; F5D63D  ld XIY,0x00f3294b
	ld	xix, SoundEditToneLayerPanning_RepaintField_DL2	; F5D642  ld XIX,0x00f32987
	call	T_DisplayListB_Run	; F5D647  call 0xf417f4
	call	SoundEditToneLayerPanning_PaintPanAmounts	; F5D64B  call 0xf5d497
	jr	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Return	; F5D64F  jr T,0xf5d6ab
Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Skip:
	ld	(LCD_CurrentLayer:16), 0	; F5D651  ld (0x2540),0x00
	ld	xiy, DL_F328DC	; F5D656  ld XIY,0x00f328dc
	ld	xix, DL_F328DC + 0x3C	; F5D65B  ld XIX,0x00f32918
	call	T_DisplayListB_Run	; F5D660  call 0xf417f4
	call	SoundEditToneLayerPanning_DrawChordTriggers	; F5D664  call 0xf5d46b
	jr	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Return	; F5D668  jr T,0xf5d6ab
Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Skip2:
	ld	(LCD_CurrentLayer:16), 1	; F5D66A  ld (0x2540),0x01
	ld	xiy, SoundEditToneLayerPanning_RepaintField_DL1	; F5D66F  ld XIY,0x00f32a7d
	ld	xix, DLBoxes_F32A87	; F5D674  ld XIX,0x00f32a87
	call	T_DisplayList_Run	; F5D679  call 0xf417f0
	ld	a, 0:opc	; F5D67D  ld A,0x00
	ldw	bc, ModelingPage_Fields+16	; F5D67F  ld BC,0x27b6
	ld	d, (xbc)	; F5D682  ld D,(XBC)
	cp	d, 0:i3	; F5D684  cp D,0
	jr	z, Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Skip3	; F5D686  jr Z,0xf5d69d
	ld	(LCD_CurrentLayer:16), 0	; F5D688  ld (0x2540),0x00
	ld	xiy, SoundEditToneLayerPanning_RepaintField_DL2	; F5D68D  ld XIY,0x00f32987
	ld	xix, Data_F32992	; F5D692  ld XIX,0x00f32992
	call	T_DisplayListB_Run	; F5D697  call 0xf417f4
	jr	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Return	; F5D69B  jr T,0xf5d6ab
Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Skip3:
	ld	xiy, Data_F32992 + 0x28	; F5D69D  ld XIY,0x00f329ba
	ld	(LCD_CurrentLayer:16), 0	; F5D6A2  ld (0x2540),0x00
	call	RunDisplayListBFromPointerArray	; F5D6A7  call 0xf09ae1
Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Return:
	ret	; F5D6AB  ret
; SoundEditToneLayerKeyLayer_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x84] -- Dispatch_Code80, the partial repaint.
SoundEditToneLayerKeyLayer_RepaintField:
	cp	a, 0:i3	; F5D6AC  cp A,0
	jr	nz, Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Skip4	; F5D6AE  jr NZ,0xf5d6c5
	ld	(LCD_CurrentLayer:16), 1	; F5D6B0  ld (0x2540),0x01
	ld	xiy, DL_F32B32	; F5D6B5  ld XIY,0x00f32b32
	ld	xix, Data_F32B3C	; F5D6BA  ld XIX,0x00f32b3c
	call	T_DisplayList_Run	; F5D6BF  call 0xf417f0
	ld	a, 0:opc	; F5D6C3  ld A,0x00
Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Skip4:
	ld	(LCD_CurrentLayer:16), 0	; F5D6C5  ld (0x2540),0x00
	ld	xiy, Data_F32B1E	; F5D6CA  ld XIY,0x00f32b1e
	call	RunDisplayListBFromPointerArray	; F5D6CF  call 0xf09ae1
	ret	; F5D6D3  ret
; SoundEditToneLayerVelocityLayer_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x85] -- Dispatch_Code80, the partial repaint.
SoundEditToneLayerVelocityLayer_RepaintField:
	cp	a, 0:i3	; F5D6D4  cp A,0
	jr	nz, Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Skip5	; F5D6D6  jr NZ,0xf5d6ed
	ld	(LCD_CurrentLayer:16), 1	; F5D6D8  ld (0x2540),0x01
	ld	xiy, DL_F32B32	; F5D6DD  ld XIY,0x00f32b32
	ld	xix, Data_F32B3C	; F5D6E2  ld XIX,0x00f32b3c
	call	T_DisplayList_Run	; F5D6E7  call 0xf417f0
	ld	a, 0:opc	; F5D6EB  ld A,0x00
Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Skip5:
	ld	(LCD_CurrentLayer:16), 0	; F5D6ED  ld (0x2540),0x00
	ld	xiy, DLRecordPtrs_F32B97	; F5D6F2  ld XIY,0x00f32b97
	call	RunDisplayListBFromPointerArray	; F5D6F7  call 0xf09ae1
	ret	; F5D6FB  ret
; SoundEditEnvelope2_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x89] (also codes 0x98) -- Dispatch_Code80, the partial repaint.
SoundEditEnvelope2_RepaintField:
	ld	(LCD_CurrentLayer:16), 0	; F5D6FC  ld (0x2540),0x00
	ld	xiy, Data_F32C02	; F5D701  ld XIY,0x00f32c02
	call	RunDisplayListBFromPointerArray	; F5D706  call 0xf09ae1
	ret	; F5D70A  ret
	call	T_DisplayListB_Run	; F5D70B  call 0xf417f4
	ld	(LCD_CurrentLayer:16), 0	; F5D70F  ld (0x2540),0x00
	ld	xiy, DL_F32FA0	; F5D714  ld XIY,0x00f32fa0
	ld	xix, DL_F32FC8	; F5D719  ld XIX,0x00f32fc8
	call	T_DisplayListB_Run	; F5D71E  call 0xf417f4
	ret	; F5D722  ret
	call	SoundEditController_PaintHeader_Copy	; F5D723  call 0xf5d77f
	call	T_UiPaint_PageLabelBackdrop	; F5D727  call 0xf42e18
	ld	(LCD_CurrentLayer:16), 0	; F5D72B  ld (0x2540),0x00
	ld	xiy, DL_Page22AfterTouchCtrlPedal	; F5D730  ld XIY,0x00f32e71
	ld	xix, DL_F32F43	; F5D735  ld XIX,0x00f32f43
	call	T_DisplayList_Run	; F5D73A  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F5D73E  ld (0x2540),0x00
	ld	xiy, DL_F3341C	; F5D743  ld XIY,0x00f3341c
	ld	xix, DLBoxes_F334AE	; F5D748  ld XIX,0x00f334ae
	call	T_DisplayListB_Run	; F5D74D  call 0xf417f4
	cp	(0x27f5:16), 0x01	; F5D751  cp (0x27f5),0x01
	jr	z, Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Skip6	; F5D756  jr Z,0xf5d76b
	ld	(LCD_CurrentLayer:16), 0	; F5D758  ld (0x2540),0x00
	ld	xiy, DL_F32FC8	; F5D75D  ld XIY,0x00f32fc8
	ld	xix, SoundEditController_HeaderRecords	; F5D762  ld XIX,0x00f32fe6
	call	T_DisplayListB_Run	; F5D767  call 0xf417f4
Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_Skip6:
	ld	(LCD_CurrentLayer:16), 0	; F5D76B  ld (0x2540),0x00
	ld	xiy, DL_F32FA0	; F5D770  ld XIY,0x00f32fa0
	ld	xix, DL_F32FC8	; F5D775  ld XIX,0x00f32fc8
	call	T_DisplayListB_Run	; F5D77A  call 0xf417f4
	ret	; F5D77E  ret

; --------------------------------------------------------------------------
; SoundEditController_PaintHeader_Copy
; Called from: in-module: 0xF5D723
; Touches: (0x2540) (0x27F5)  |  0xF32C2A 0xF32CC8 0xF32D03 0xF32D2C
;          0xF32FA0 0xF32FC8 +1 more
; Calls:   T_DisplayList_Run T_DisplayListB_Run
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5D77F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditController_PaintHeader_Copy: an exact copy of SoundEditController_PaintHeader (prom_b 0xF098B8) -- all 16 instructions equal, operands included,
;   but the targets of its jr / jrl / djnz (notes/wsa1_exact_copy_names.py).
SoundEditController_PaintHeader_Copy:
	cp	(0x27f5:16), 0x01	; F5D77F  cp (0x27f5),0x01
	jr	z, SoundEditController_PaintHeader_Copy_Skip	; F5D784  jr Z,0xf5d79b
	ld	(LCD_CurrentLayer:16), 0	; F5D786  ld (0x2540),0x00
	ld	xiy, DL_C0ntr0llerSoundEditDepth	; F5D78B  ld XIY,0x00f32c2a
	ld	xix, DL_1st2nd	; F5D790  ld XIX,0x00f32d03
	call	T_DisplayList_Run	; F5D795  call 0xf417f0
	jr	SoundEditController_PaintHeader_Copy_Return	; F5D799  jr T,0xf5d7c1
SoundEditController_PaintHeader_Copy_Skip:
	ld	(LCD_CurrentLayer:16), 0	; F5D79B  ld (0x2540),0x00
	ld	xiy, DL_C0ntr0llerSoundEditDepth	; F5D7A0  ld XIY,0x00f32c2a
	ld	xix, DL_C0ntr0llerSoundEditDepth + 0x9E	; F5D7A5  ld XIX,0x00f32cc8
	call	T_DisplayList_Run	; F5D7AA  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F5D7AE  ld (0x2540),0x00
	ld	xiy, DL_1st2nd	; F5D7B3  ld XIY,0x00f32d03
	ld	xix, SoundEditController_PaintPage1_DL	; F5D7B8  ld XIX,0x00f32d2c
	call	T_DisplayList_Run	; F5D7BD  call 0xf417f0
SoundEditController_PaintHeader_Copy_Return:
	ret	; F5D7C1  ret
	.byte 0xF5, 0x27, 0x3F	; F5D7C2  db   [llvm-mc cannot encode this]
	normal	; F5D7C5  normal
	jr	z, SoundEditController_PaintHeader_Copy_Skip2	; F5D7C6  jr Z,0xf5d7db
	ld	(LCD_CurrentLayer:16), 0	; F5D7C8  ld (0x2540),0x00
	ld	xiy, DL_F32FC8	; F5D7CD  ld XIY,0x00f32fc8
	ld	xix, SoundEditController_HeaderRecords	; F5D7D2  ld XIX,0x00f32fe6
	call	T_DisplayListB_Run	; F5D7D7  call 0xf417f4
SoundEditController_PaintHeader_Copy_Skip2:
	ld	(LCD_CurrentLayer:16), 0	; F5D7DB  ld (0x2540),0x00
	ld	xiy, DL_F32FA0	; F5D7E0  ld XIY,0x00f32fa0
	ld	xix, DL_F32FC8	; F5D7E5  ld XIX,0x00f32fc8
	call	T_DisplayListB_Run	; F5D7EA  call 0xf417f4
	ret	; F5D7EE  ret
	.fill	19, 1, 0x0E	; F5D7EF-F5D801  `ret` padding (asserted pure 0x0E)


; --------------------------------------------------------------------------
; RoundMap_96 -- 96 bytes, one per index.  Entry k = 96 * round(k / 96),
;                i.e. the index rounded to the nearest multiple of 96; the
;                value 96, which is off the end of the index range, is
;                written as 0x7F instead.  Steps: 0, then 0x7F.
; Entry count: 96, and it is not the byte extent divided by anything -- the
;              seven maps TILE 0xF5D802-0xF5DAA1 (672 bytes) at 96 bytes
;              each, the first address is RoundMap_Table[0] and the last
;              map's last byte abuts 0xF5DAA2, which is thunk target
;              T_Quantize_Execute.  96 x 7 = 672 = the extent, and 95 or 97 does not
;              tile it.
; Read by: `ld XHL,(0x0E12) / ld A,(XHL+IX)` at 0xF5DC65-0xF5DC69, with IX
;          the zero-extended byte the routine has just read from the buffer
;          at (0x126E) and stored to (0x0E25); the result goes to (0x0E26).
;          (0x0E12) is loaded from RoundMap_Table by the sequence at
;          0xF5DB97-0xF5DBAE.
; Evidence: the grid g is read off this map's OWN distinct values, not
;           typed, and all 96 entries are then compared with `g * round(k /
;           g)` byte for byte on every emit -- all 96 agree.  The address
;           comes from RoundMap_Table[0], also read from the ROM.
; Unknown: what the 96 steps count.  The maps are selected by (0x0C7F),
;          which this module tests only against even values, and the seven
;          grids are 96, 48, 24, 12, 32, 16 and 8 -- the divisions of 96
;          into halves and into thirds.  Nothing here says what a step IS.
; --------------------------------------------------------------------------
RoundMap_96:
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F5D802  [0..15]
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F5D812  [16..31]
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F5D822  [32..47]
	.byte	0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F	; F5D832  [48..63]
	.byte	0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F	; F5D842  [64..79]
	.byte	0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F	; F5D852  [80..95]

; --------------------------------------------------------------------------
; RoundMap_48 -- 96 bytes, one per index.  Entry k = 48 * round(k / 48),
;                i.e. the index rounded to the nearest multiple of 48; the
;                value 96, which is off the end of the index range, is
;                written as 0x7F instead.  Steps: 0, 48, then 0x7F.
; Entry count: 96, and it is not the byte extent divided by anything -- the
;              seven maps TILE 0xF5D802-0xF5DAA1 (672 bytes) at 96 bytes
;              each, the first address is RoundMap_Table[0] and the last
;              map's last byte abuts 0xF5DAA2, which is thunk target
;              T_Quantize_Execute.  96 x 7 = 672 = the extent, and 95 or 97 does not
;              tile it.
; Read by: `ld XHL,(0x0E12) / ld A,(XHL+IX)` at 0xF5DC65-0xF5DC69, with IX
;          the zero-extended byte the routine has just read from the buffer
;          at (0x126E) and stored to (0x0E25); the result goes to (0x0E26).
;          (0x0E12) is loaded from RoundMap_Table by the sequence at
;          0xF5DB97-0xF5DBAE.
; Evidence: the grid g is read off this map's OWN distinct values, not
;           typed, and all 96 entries are then compared with `g * round(k /
;           g)` byte for byte on every emit -- all 96 agree.  The address
;           comes from RoundMap_Table[1], also read from the ROM.
; Unknown: what the 96 steps count.  The maps are selected by (0x0C7F),
;          which this module tests only against even values, and the seven
;          grids are 96, 48, 24, 12, 32, 16 and 8 -- the divisions of 96
;          into halves and into thirds.  Nothing here says what a step IS.
; --------------------------------------------------------------------------
RoundMap_48:
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F5D862  [0..15]
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30	; F5D872  [16..31]
	.byte	0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30	; F5D882  [32..47]
	.byte	0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30	; F5D892  [48..63]
	.byte	0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F	; F5D8A2  [64..79]
	.byte	0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F	; F5D8B2  [80..95]

; --------------------------------------------------------------------------
; RoundMap_24 -- 96 bytes, one per index.  Entry k = 24 * round(k / 24),
;                i.e. the index rounded to the nearest multiple of 24; the
;                value 96, which is off the end of the index range, is
;                written as 0x7F instead.  Steps: 0, 24, 48, 72, then 0x7F.
; Entry count: 96, and it is not the byte extent divided by anything -- the
;              seven maps TILE 0xF5D802-0xF5DAA1 (672 bytes) at 96 bytes
;              each, the first address is RoundMap_Table[0] and the last
;              map's last byte abuts 0xF5DAA2, which is thunk target
;              T_Quantize_Execute.  96 x 7 = 672 = the extent, and 95 or 97 does not
;              tile it.
; Read by: `ld XHL,(0x0E12) / ld A,(XHL+IX)` at 0xF5DC65-0xF5DC69, with IX
;          the zero-extended byte the routine has just read from the buffer
;          at (0x126E) and stored to (0x0E25); the result goes to (0x0E26).
;          (0x0E12) is loaded from RoundMap_Table by the sequence at
;          0xF5DB97-0xF5DBAE.
; Evidence: the grid g is read off this map's OWN distinct values, not
;           typed, and all 96 entries are then compared with `g * round(k /
;           g)` byte for byte on every emit -- all 96 agree.  The address
;           comes from RoundMap_Table[2], also read from the ROM.
; Unknown: what the 96 steps count.  The maps are selected by (0x0C7F),
;          which this module tests only against even values, and the seven
;          grids are 96, 48, 24, 12, 32, 16 and 8 -- the divisions of 96
;          into halves and into thirds.  Nothing here says what a step IS.
; --------------------------------------------------------------------------
RoundMap_24:
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x18, 0x18, 0x18	; F5D8C2  [0..15]
	.byte	0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18	; F5D8D2  [16..31]
	.byte	0x18, 0x18, 0x18, 0x18, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30	; F5D8E2  [32..47]
	.byte	0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x48, 0x48, 0x48, 0x48	; F5D8F2  [48..63]
	.byte	0x48, 0x48, 0x48, 0x48, 0x48, 0x48, 0x48, 0x48, 0x48, 0x48, 0x48, 0x48, 0x48, 0x48, 0x48, 0x48	; F5D902  [64..79]
	.byte	0x48, 0x48, 0x48, 0x48, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F	; F5D912  [80..95]

; --------------------------------------------------------------------------
; RoundMap_12 -- 96 bytes, one per index.  Entry k = 12 * round(k / 12),
;                i.e. the index rounded to the nearest multiple of 12; the
;                value 96, which is off the end of the index range, is
;                written as 0x7F instead.  Steps: 0, 12, 24, 36, 48, 60, 73,
;                84, then 0x7F.
; Entry count: 96, and it is not the byte extent divided by anything -- the
;              seven maps TILE 0xF5D802-0xF5DAA1 (672 bytes) at 96 bytes
;              each, the first address is RoundMap_Table[0] and the last
;              map's last byte abuts 0xF5DAA2, which is thunk target
;              T_Quantize_Execute.  96 x 7 = 672 = the extent, and 95 or 97 does not
;              tile it.
; Read by: `ld XHL,(0x0E12) / ld A,(XHL+IX)` at 0xF5DC65-0xF5DC69, with IX
;          the zero-extended byte the routine has just read from the buffer
;          at (0x126E) and stored to (0x0E25); the result goes to (0x0E26).
;          (0x0E12) is loaded from RoundMap_Table by the sequence at
;          0xF5DB97-0xF5DBAE.
; Evidence: the grid g is read off this map's OWN distinct values, not
;           typed, and all 96 entries are then compared with `g * round(k /
;           g)` byte for byte on every emit -- 12 of the 96 disagree, and
;           they are listed on the ANOMALY line below.  The address comes
;           from RoundMap_Table[3], also read from the ROM.
; ⚠ ANOMALY: 12 of the 96 entries do NOT match that formula: [66]=73
;            (formula 72), [67]=73 (formula 72), [68]=73 (formula 72) ...
;            and 9 more, all the same step.  They are one greater than the
;            arithmetic gives.  Recorded, not corrected -- these are the
;            ROM's bytes.
; Unknown: what the 96 steps count.  The maps are selected by (0x0C7F),
;          which this module tests only against even values, and the seven
;          grids are 96, 48, 24, 12, 32, 16 and 8 -- the divisions of 96
;          into halves and into thirds.  Nothing here says what a step IS.
; --------------------------------------------------------------------------
RoundMap_12:
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C	; F5D922  [0..15]
	.byte	0x0C, 0x0C, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x24, 0x24	; F5D932  [16..31]
	.byte	0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30	; F5D942  [32..47]
	.byte	0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C	; F5D952  [48..63]
	.byte	0x3C, 0x3C, 0x49, 0x49, 0x49, 0x49, 0x49, 0x49, 0x49, 0x49, 0x49, 0x49, 0x49, 0x49, 0x54, 0x54	; F5D962  [64..79]
	.byte	0x54, 0x54, 0x54, 0x54, 0x54, 0x54, 0x54, 0x54, 0x54, 0x54, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F	; F5D972  [80..95]

; --------------------------------------------------------------------------
; RoundMap_32 -- 96 bytes, one per index.  Entry k = 32 * round(k / 32),
;                i.e. the index rounded to the nearest multiple of 32; the
;                value 96, which is off the end of the index range, is
;                written as 0x7F instead.  Steps: 0, 32, 64, then 0x7F.
; Entry count: 96, and it is not the byte extent divided by anything -- the
;              seven maps TILE 0xF5D802-0xF5DAA1 (672 bytes) at 96 bytes
;              each, the first address is RoundMap_Table[0] and the last
;              map's last byte abuts 0xF5DAA2, which is thunk target
;              T_Quantize_Execute.  96 x 7 = 672 = the extent, and 95 or 97 does not
;              tile it.
; Read by: `ld XHL,(0x0E12) / ld A,(XHL+IX)` at 0xF5DC65-0xF5DC69, with IX
;          the zero-extended byte the routine has just read from the buffer
;          at (0x126E) and stored to (0x0E25); the result goes to (0x0E26).
;          (0x0E12) is loaded from RoundMap_Table by the sequence at
;          0xF5DB97-0xF5DBAE.
; Evidence: the grid g is read off this map's OWN distinct values, not
;           typed, and all 96 entries are then compared with `g * round(k /
;           g)` byte for byte on every emit -- all 96 agree.  The address
;           comes from RoundMap_Table[4], also read from the ROM.
; Unknown: what the 96 steps count.  The maps are selected by (0x0C7F),
;          which this module tests only against even values, and the seven
;          grids are 96, 48, 24, 12, 32, 16 and 8 -- the divisions of 96
;          into halves and into thirds.  Nothing here says what a step IS.
; --------------------------------------------------------------------------
RoundMap_32:
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F5D982  [0..15]
	.byte	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20	; F5D992  [16..31]
	.byte	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20	; F5D9A2  [32..47]
	.byte	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40	; F5D9B2  [48..63]
	.byte	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40	; F5D9C2  [64..79]
	.byte	0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F	; F5D9D2  [80..95]

; --------------------------------------------------------------------------
; RoundMap_16 -- 96 bytes, one per index.  Entry k = 16 * round(k / 16),
;                i.e. the index rounded to the nearest multiple of 16; the
;                value 96, which is off the end of the index range, is
;                written as 0x7F instead.  Steps: 0, 16, 32, 48, 64, 80,
;                then 0x7F.
; Entry count: 96, and it is not the byte extent divided by anything -- the
;              seven maps TILE 0xF5D802-0xF5DAA1 (672 bytes) at 96 bytes
;              each, the first address is RoundMap_Table[0] and the last
;              map's last byte abuts 0xF5DAA2, which is thunk target
;              T_Quantize_Execute.  96 x 7 = 672 = the extent, and 95 or 97 does not
;              tile it.
; Read by: `ld XHL,(0x0E12) / ld A,(XHL+IX)` at 0xF5DC65-0xF5DC69, with IX
;          the zero-extended byte the routine has just read from the buffer
;          at (0x126E) and stored to (0x0E25); the result goes to (0x0E26).
;          (0x0E12) is loaded from RoundMap_Table by the sequence at
;          0xF5DB97-0xF5DBAE.
; Evidence: the grid g is read off this map's OWN distinct values, not
;           typed, and all 96 entries are then compared with `g * round(k /
;           g)` byte for byte on every emit -- all 96 agree.  The address
;           comes from RoundMap_Table[5], also read from the ROM.
; Unknown: what the 96 steps count.  The maps are selected by (0x0C7F),
;          which this module tests only against even values, and the seven
;          grids are 96, 48, 24, 12, 32, 16 and 8 -- the divisions of 96
;          into halves and into thirds.  Nothing here says what a step IS.
; --------------------------------------------------------------------------
RoundMap_16:
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10	; F5D9E2  [0..15]
	.byte	0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20	; F5D9F2  [16..31]
	.byte	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30	; F5DA02  [32..47]
	.byte	0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40	; F5DA12  [48..63]
	.byte	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50	; F5DA22  [64..79]
	.byte	0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F	; F5DA32  [80..95]

; --------------------------------------------------------------------------
; RoundMap_8 -- 96 bytes, one per index.  Entry k = 8 * round(k / 8), i.e.
;               the index rounded to the nearest multiple of 8; the value
;               96, which is off the end of the index range, is written as
;               0x7F instead.  Steps: 0, 8, 16, 24, 32, 40, 48, 56, 64, 72,
;               80, 88, then 0x7F.
; Entry count: 96, and it is not the byte extent divided by anything -- the
;              seven maps TILE 0xF5D802-0xF5DAA1 (672 bytes) at 96 bytes
;              each, the first address is RoundMap_Table[0] and the last
;              map's last byte abuts 0xF5DAA2, which is thunk target
;              T_Quantize_Execute.  96 x 7 = 672 = the extent, and 95 or 97 does not
;              tile it.
; Read by: `ld XHL,(0x0E12) / ld A,(XHL+IX)` at 0xF5DC65-0xF5DC69, with IX
;          the zero-extended byte the routine has just read from the buffer
;          at (0x126E) and stored to (0x0E25); the result goes to (0x0E26).
;          (0x0E12) is loaded from RoundMap_Table by the sequence at
;          0xF5DB97-0xF5DBAE.
; Evidence: the grid g is read off this map's OWN distinct values, not
;           typed, and all 96 entries are then compared with `g * round(k /
;           g)` byte for byte on every emit -- all 96 agree.  The address
;           comes from RoundMap_Table[6], also read from the ROM.
; Unknown: what the 96 steps count.  The maps are selected by (0x0C7F),
;          which this module tests only against even values, and the seven
;          grids are 96, 48, 24, 12, 32, 16 and 8 -- the divisions of 96
;          into halves and into thirds.  Nothing here says what a step IS.
; --------------------------------------------------------------------------
RoundMap_8:
	.byte	0x00, 0x00, 0x00, 0x00, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x10, 0x10, 0x10, 0x10	; F5DA42  [0..15]
	.byte	0x10, 0x10, 0x10, 0x10, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x20, 0x20, 0x20, 0x20	; F5DA52  [16..31]
	.byte	0x20, 0x20, 0x20, 0x20, 0x28, 0x28, 0x28, 0x28, 0x28, 0x28, 0x28, 0x28, 0x30, 0x30, 0x30, 0x30	; F5DA62  [32..47]
	.byte	0x30, 0x30, 0x30, 0x30, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x40, 0x40, 0x40, 0x40	; F5DA72  [48..63]
	.byte	0x40, 0x40, 0x40, 0x40, 0x48, 0x48, 0x48, 0x48, 0x48, 0x48, 0x48, 0x48, 0x50, 0x50, 0x50, 0x50	; F5DA82  [64..79]
	.byte	0x50, 0x50, 0x50, 0x50, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x7F, 0x7F, 0x7F, 0x7F	; F5DA92  [80..95]


; --------------------------------------------------------------------------
; Quantize_Execute
; Called from: T_Quantize_Execute (x1)
; Touches: (0x0C70) (0x0C73) (0x0C77) (0x0C7F) (0x0C8A) (0x0C8E) (0x0CA2)
;          (0x0CA3) (0x0D18) (0x0D4A)  |  0x603422
; Calls:   T_BStore_LoadGeometry Quantize_Track
; Evidence: thunk slot T_Quantize_Execute holds `jp 0x00F5DAA2`, and 0xF5DAA2 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_Execute: Runs QUANTIZE on the job cells Quantize_LcdKeyRow3 fills: track (0x0C70) 1..(0x0CA2) or 0x7F =
;   all, measures (0x0C73) / (0x0C77) 1..999, resolution (0x0C7F) even 0..12 (else BStore_ErrorCode 3); quantizes that
;   track (Quantize_Track: round map RoundMap_Table[(0x0C7F)]) -- the master track's part 0x20 gives error 9 -- or every
;   track but the master's, keeping the first error. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_m.json)
Quantize_Execute:		; <- T_Quantize_Execute
	call	T_BStore_LoadGeometry	; F5DAA2  call 0xf427c4
	ld	a, (3184:16)	; F5DAA6  ld A,(0x0c70)
	cp	a, 1:i3	; F5DAAA  cp A,1
	jr	c, Quantize_Execute_Skip2	; F5DAAC  jr C,0xf5daf8
	cp	a, 127	; F5DAAE  cp A,0x7f
	jr	z, Quantize_Execute_Skip	; F5DAB1  jr Z,0xf5dab9
	cp	a, (0x0ca2:16)	; F5DAB3  cp A,(0x0ca2)
	jr	ugt, Quantize_Execute_Skip2	; F5DAB7  jr UGT,0xf5daf8
Quantize_Execute_Skip:
	ld	wa, (3187:16)	; F5DAB9  ld WA,(0x0c73)
	cp	wa, 1:i3	; F5DABD  cp WA,1
	jr	c, Quantize_Execute_Skip2	; F5DABF  jr C,0xf5daf8
	cp	wa, 999	; F5DAC1  cp WA,0x03e7
	jr	ugt, Quantize_Execute_Skip2	; F5DAC5  jr UGT,0xf5daf8
	ld	wa, (3191:16)	; F5DAC7  ld WA,(0x0c77)
	cp	wa, 1:i3	; F5DACB  cp WA,1
	jr	c, Quantize_Execute_Skip2	; F5DACD  jr C,0xf5daf8
	cp	wa, 999	; F5DACF  cp WA,0x03e7
	jr	ugt, Quantize_Execute_Skip2	; F5DAD3  jr UGT,0xf5daf8
	ld	a, (3199:16)	; F5DAD5  ld A,(0x0c7f)
	cp	a, 0:i3	; F5DAD9  cp A,0
	jr	z, Quantize_Execute_Skip3	; F5DADB  jr Z,0xf5db00
	cp	a, 2:i3	; F5DADD  cp A,2
	jr	z, Quantize_Execute_Skip3	; F5DADF  jr Z,0xf5db00
	cp	a, 4:i3	; F5DAE1  cp A,4
	jr	z, Quantize_Execute_Skip3	; F5DAE3  jr Z,0xf5db00
	cp	a, 6:i3	; F5DAE5  cp A,6
	jr	z, Quantize_Execute_Skip3	; F5DAE7  jr Z,0xf5db00
	cp	a, 8	; F5DAE9  cp A,0x08
	jr	z, Quantize_Execute_Skip3	; F5DAEC  jr Z,0xf5db00
	cp	a, 10	; F5DAEE  cp A,0x0a
	jr	z, Quantize_Execute_Skip3	; F5DAF1  jr Z,0xf5db00
	cp	a, 12	; F5DAF3  cp A,0x0c
	jr	z, Quantize_Execute_Skip3	; F5DAF6  jr Z,0xf5db00
Quantize_Execute_Skip2:
	ld	(BStore_ErrorCode:16), 3	; F5DAF8  ld (0x0d4a),0x03
	jrl	Quantize_ApplyRoundMapToTrack_Join6	; F5DAFD  jrl T,0xf5dda9
Quantize_Execute_Skip3:
	ld	(BStore_ErrorCode:16), 0	; F5DB00  ld (0x0d4a),0x00
	and	(0x0c8a:16), 0xbf	; F5DB05  and (0x0c8a),0xbf
	cp	(0x0c70:16), 0x7f	; F5DB0A  cp (0x0c70),0x7f
	jr	z, Quantize_Execute_Skip5	; F5DB0F  jr Z,0xf5db40
	xor	hl, hl	; F5DB11  xor HL,HL
	ld	l, (3184:16)	; F5DB13  ld L,(0x0c70)
	dec	1, l	; F5DB17  dec 1,L
	push	xix	; F5DB19  push XIX
	ld	xix, BStore_TrackToPart	; F5DB1A  ld XIX,0x00603422
	ld	a, (xix+hl)	; F5DB1F  ld A,(XIX+HL)
	pop	xix	; F5DB24  pop XIX
	cp	a, 32	; F5DB25  cp A,0x20
	jr	z, Quantize_Execute_Skip4	; F5DB28  jr Z,0xf5db38
	ld	a, (3184:16)	; F5DB2A  ld A,(0x0c70)
	ld	(3214:16), a	; F5DB2E  ld (0x0c8e),A
	calr	Quantize_Track	; F5DB32  calr 0xf5db97
	jrl	Quantize_ApplyRoundMapToTrack_Join6	; F5DB35  jrl T,0xf5dda9
Quantize_Execute_Skip4:
	ld	(BStore_ErrorCode:16), 9	; F5DB38  ld (0x0d4a),0x09
	jrl	Quantize_ApplyRoundMapToTrack_Join6	; F5DB3D  jrl T,0xf5dda9
Quantize_Execute_Skip5:
	xor	xhl, xhl	; F5DB40  xor XHL,XHL
Quantize_Execute_Join:
	cp	l, (0x0ca3:16)	; F5DB42  cp L,(0x0ca3)
	jr	ugt, Quantize_Execute_Skip8	; F5DB46  jr UGT,0xf5db8c
	ld	h, l	; F5DB48  ld H,L
	inc	1, h	; F5DB4A  inc 1,H
	ld	(3214:16), h	; F5DB4C  ld (0x0c8e),H
	push	xhl	; F5DB50  push XHL
	push	xix	; F5DB51  push XIX
	xor	h, h	; F5DB52  xor H,H
	ld	xix, BStore_TrackToPart	; F5DB54  ld XIX,0x00603422
	ld	a, (xix+hl)	; F5DB59  ld A,(XIX+HL)
	pop	xix	; F5DB5E  pop XIX
	pop	xhl	; F5DB5F  pop XHL
	cp	a, 32	; F5DB60  cp A,0x20
	jr	z, Quantize_Execute_Skip6	; F5DB63  jr Z,0xf5db6b
	push	xhl	; F5DB65  push XHL
	call	Quantize_Track	; F5DB66  call 0xf5db97
	pop	xhl	; F5DB6A  pop XHL
Quantize_Execute_Skip6:
	cp	(BStore_ErrorCode:16), 0x00	; F5DB6B  cp (0x0d4a),0x00
	jr	z, Quantize_Execute_Skip7	; F5DB70  jr Z,0xf5db88
	cp	(BStore_ErrorCode:16), 0x01	; F5DB72  cp (0x0d4a),0x01
	jr	z, Quantize_Execute_Skip7	; F5DB77  jr Z,0xf5db88
	cp	(0x0d18:16), 0x00	; F5DB79  cp (0x0d18),0x00
	jr	nz, Quantize_Execute_Skip7	; F5DB7E  jr NZ,0xf5db88
	ld	a, (BStore_ErrorCode:16)	; F5DB80  ld A,(0x0d4a)
	ld	(3352:16), a	; F5DB84  ld (0x0d18),A
Quantize_Execute_Skip7:
	inc	1, hl	; F5DB88  inc 1,HL
	jr	Quantize_Execute_Join	; F5DB8A  jr T,0xf5db42
Quantize_Execute_Skip8:
	ld	a, (3352:16)	; F5DB8C  ld A,(0x0d18)
	ld	(BStore_ErrorCode:16), a	; F5DB90  ld (0x0d4a),A
	jrl	Quantize_ApplyRoundMapToTrack_Join6	; F5DB94  jrl T,0xf5dda9

; --------------------------------------------------------------------------
; Quantize_Track
; Called from: in-module: 0xF5DB32 0xF5DB66
; Touches: (0x0C7F) (0x0E12)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5DB97 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_Track: QUANTIZE on one track: (0x0E12) := RoundMap_Table[(0x0C7F)/2] (the VALUE field's round map), then
;   falls (jr) into Quantize_ApplyRoundMapToTrack, which walks track (0x0C8E) from measure (0x0C73) for (0x0C77) measures and pulls the
;   timing byte (+1) of each 0x9n event toward the map by STRENGTH (0x0E04) % inside WINDOW (0x0E05). Basis: caller +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
Quantize_Track:
	xor	wa, wa	; F5DB97  xor WA,WA
	xor	xhl, xhl	; F5DB99  xor XHL,XHL
	ld	l, (3199:16)	; F5DB9B  ld L,(0x0c7f)
	sla	xhl, 1	; F5DB9F  sla 0x01,XHL
	push	xde	; F5DBA2  push XDE
	ld	xde, RoundMap_Table	; F5DBA3  ld XDE,0x00f5dbb4
	ld	xiy, (xde+hl)	; F5DBA8  ld XIY,(XDE+HL)
	pop	xde	; F5DBAD  pop XDE
	ld	(3602:16), xiy	; F5DBAE  ld (0x0e12),XIY
	jr	Quantize_ApplyRoundMapToTrack	; F5DBB2  jr T,0xf5dbd0

; --------------------------------------------------------------------------
; RoundMap_Table -- 7 pointers, one per round-map, selected by (0x0C7F).
; Entry count: 7, from the `jr T,0xF5DBD0` at 0xF5DBB2 that jumps OVER the
;              table: the distance from the table to that target is 28 bytes
;              and every entry is 4.  Not from the byte extent of anything
;              else.
; Read by: one site: `ld XDE,0x00F5DBB4` at 0xF5DBA3 (a byte scan for the
;          address reports 0xF5DBA4, that instruction's OPERAND field, one
;          byte in), then `ld XIY,(XDE+HL)` at 0xF5DBA8 with HL = (0x0C7F)
;          shifted left once at 0xF5DB9F.  The result is stored to (0x0E12)
;          at 0xF5DBAE.
; Why the index is doubled: (0x0C7F) is only ever tested against EVEN values
;                           in this module (`cp A,0` / `cp A,2` / `cp A,4` /
;                           `cp A,6` / `cp A,0x08` / `cp A,0x0a` at
;                           0xF5DAD5-0xF5DAF3), so `sla 0x01,XHL` turns 0,
;                           2, 4 ... into the 4-byte offsets 0, 4, 8 ...  ⚠
;                           that the selector's highest legal value is 0x0C
;                           is NOT established here; 7 entries is
;                           established, by the jump-over above.
; Evidence: the seven pointers read out of the ROM, each of which is the
;           start of one 96-byte map, and the maps tile 0xF5D802-0xF5DAA1
;           exactly.
; Unknown: what selects (0x0C7F).
; --------------------------------------------------------------------------
RoundMap_Table:
	.long	RoundMap_96	; [0] -> RoundMap_96
	.long	RoundMap_48	; [1] -> RoundMap_48
	.long	RoundMap_24	; [2] -> RoundMap_24
	.long	RoundMap_12	; [3] -> RoundMap_12
	.long	RoundMap_32	; [4] -> RoundMap_32
	.long	RoundMap_16	; [5] -> RoundMap_16
	.long	RoundMap_8	; [6] -> RoundMap_8


; --------------------------------------------------------------------------
; Quantize_ApplyRoundMapToTrack
; Called from: no thunk slot and no in-module call site -- reached only by a
;              branch from the routine above, or by a computed transfer
; Touches: (0x0C73) (0x0C77) (0x0C8A) (0x0C8E) (0x0C90) (0x0D0A) (0x0D14)
;          (0x0D1C) (0x0D4A) (0x0E04) +7 more
; Calls:   T_Seq_FindMasterTrack T_BStore_SeekMeasure T_BStore_CursorAdvance Quantize_ComputeWindowBounds SongEdit_SortBeatEventsByTiming Quantize_CarryRoundedUpEventsToNextBeat
;          T_F427A8 T_BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_12 T_F40A1C
; Evidence: the label is here because it is the target of `jr T,0xF5DBD0` at
;           0xF5DBB2, the jump that steps over the 28 bytes of
;           RoundMap_Table; the address is an instruction boundary of this
;           transcription (re-asserted on every emit)
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_ApplyRoundMapToTrack: QUANTIZE's walk, entered by Quantize_Track's jr with the round map in (0x0E12):
;   nothing if STRENGTH (0x0E04) or WINDOW (0x0E05) is 0; seeks measure (0x0C73) of track (0x0C8E) and, for (0x0C77)
;   measures, moves the timing byte (+1) of each 0x9n event toward map[timing] by STRENGTH % (mul / div 100) when it
;   lies inside the window. Basis: caller + caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_t.json)
Quantize_ApplyRoundMapToTrack:
	cp	(0x0e04:16), 0x00	; F5DBD0  cp (0x0e04),0x00
	jrl	z, Quantize_ApplyRoundMapToTrack_Return	; F5DBD5  jrl Z,0xf5dda8
	cp	(0x0e05:16), 0x00	; F5DBD8  cp (0x0e05),0x00
	jrl	z, Quantize_ApplyRoundMapToTrack_Return	; F5DBDD  jrl Z,0xf5dda8
	call	T_Seq_FindMasterTrack	; F5DBE0  call 0xf427a0
	ld	a, (3214:16)	; F5DBE4  ld A,(0x0c8e)
	ld	de, (3187:16)	; F5DBE8  ld DE,(0x0c73)
	ld	(3216:16), de	; F5DBEC  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F5DBF0  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F5DBF4  cp (0x0d4a),0x00
	jrl	nz, Quantize_ApplyRoundMapToTrack_Return	; F5DBF9  jrl NZ,0xf5dda8
	xor	de, de	; F5DBFC  xor DE,DE
Quantize_ApplyRoundMapToTrack_Loop:
	cp	de, (0x0c77:16)	; F5DBFE  cp DE,(0x0c77)
	jrl	z, Quantize_ApplyRoundMapToTrack_Return	; F5DC02  jrl Z,0xf5dda8
	xor	bc, bc	; F5DC05  xor BC,BC
Quantize_ApplyRoundMapToTrack_Join:
	xor	wa, wa	; F5DC07  xor WA,WA
	and	(0x0c8a:16), 0xfe	; F5DC09  and (0x0c8a),0xfe
	ld	(3338:16), iy	; F5DC0E  ld (0x0d0a),IY
	push	xhl	; F5DC12  push XHL
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5DC13  ld XHL,(0x126e)
	ld	(3348:16), xhl	; F5DC17  ld (0x0d14),XHL
	pop	xhl	; F5DC1B  pop XHL
	cp	c, (0x0d1c:16)	; F5DC1C  cp C,(0x0d1c)
	jrl	z, Quantize_ApplyRoundMapToTrack_Skip14	; F5DC20  jrl Z,0xf5dd7a
Quantize_ApplyRoundMapToTrack_Join2:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5DC23  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F5DC27  ld A,(XHL+IY)
	cp	a, 130	; F5DC2C  cp A,0x82
	jrl	z, Quantize_ApplyRoundMapToTrack_Return	; F5DC2F  jrl Z,0xf5dda8
	cp	a, 129	; F5DC32  cp A,0x81
	jrl	z, Quantize_ApplyRoundMapToTrack_Skip13	; F5DC35  jrl Z,0xf5dd5f
	bit	7, a	; F5DC38  bit 0x07,A
	jrl	z, Quantize_ApplyRoundMapToTrack_Skip12	; F5DC3B  jrl Z,0xf5dd51
	and	a, 240	; F5DC3E  and A,0xf0
	cp	a, 144	; F5DC41  cp A,0x90
	jrl	nz, Quantize_ApplyRoundMapToTrack_Skip12	; F5DC44  jrl NZ,0xf5dd51
	call	T_BStore_CursorAdvance	; F5DC47  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F5DC4B  cp (0x0d4a),0x00
	jrl	nz, Quantize_ApplyRoundMapToTrack_Return	; F5DC50  jrl NZ,0xf5dda8
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5DC53  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F5DC57  ld A,(XHL+IY)
	xor	w, w	; F5DC5C  xor W,W
	ld	ix, wa	; F5DC5E  ld IX,WA
	ld	(3621:16), a	; F5DC60  ld (0x0e25),A
	push	xhl	; F5DC64  push XHL
	ld	xhl, (3602:16)	; F5DC65  ld XHL,(0x0e12)
	ld	a, (xhl+ix)	; F5DC69  ld A,(XHL+IX)
	ld	(3622:16), a	; F5DC6E  ld (0x0e26),A
	pop	xhl	; F5DC72  pop XHL
	cp	(0x0e05:16), 0x64	; F5DC73  cp (0x0e05),0x64
	jr	z, Quantize_ApplyRoundMapToTrack_Join3	; F5DC78  jr Z,0xf5dcea
	cp	(0x0e05:16), 0x9c	; F5DC7A  cp (0x0e05),0x9c
	jr	z, Quantize_ApplyRoundMapToTrack_Join3	; F5DC7F  jr Z,0xf5dcea
	call	Quantize_ComputeWindowBounds	; F5DC81  call 0xf5ddb2
	ld	a, (3621:16)	; F5DC85  ld A,(0x0e25)
	bit	7, (0x0e05:16)	; F5DC89  bit 7,(0x0e05)
	jr	nz, Quantize_ApplyRoundMapToTrack_Skip3	; F5DC8D  jr NZ,0xf5dcbf
	cp	(0x0e26:16), 0x00	; F5DC8F  cp (0x0e26),0x00
	jr	z, Quantize_ApplyRoundMapToTrack_Skip	; F5DC94  jr Z,0xf5dca6
	cp	(0x0e26:16), 0x7f	; F5DC96  cp (0x0e26),0x7f
	jr	nz, Quantize_ApplyRoundMapToTrack_Skip2	; F5DC9B  jr NZ,0xf5dcaf
	cp	a, (0x0e27:16)	; F5DC9D  cp A,(0x0e27)
	jrl	lt, Quantize_ApplyRoundMapToTrack_Skip12	; F5DCA1  jrl LT,0xf5dd51
	jr	Quantize_ApplyRoundMapToTrack_Join3	; F5DCA4  jr T,0xf5dcea
Quantize_ApplyRoundMapToTrack_Skip:
	cp	a, (0x0e28:16)	; F5DCA6  cp A,(0x0e28)
	jrl	gt, Quantize_ApplyRoundMapToTrack_Skip12	; F5DCAA  jrl GT,0xf5dd51
	jr	Quantize_ApplyRoundMapToTrack_Join3	; F5DCAD  jr T,0xf5dcea
Quantize_ApplyRoundMapToTrack_Skip2:
	cp	a, (0x0e27:16)	; F5DCAF  cp A,(0x0e27)
	jrl	lt, Quantize_ApplyRoundMapToTrack_Skip12	; F5DCB3  jrl LT,0xf5dd51
	cp	a, (0x0e28:16)	; F5DCB6  cp A,(0x0e28)
	jrl	gt, Quantize_ApplyRoundMapToTrack_Skip12	; F5DCBA  jrl GT,0xf5dd51
	jr	Quantize_ApplyRoundMapToTrack_Join3	; F5DCBD  jr T,0xf5dcea
Quantize_ApplyRoundMapToTrack_Skip3:
	cp	(0x0e26:16), 0x00	; F5DCBF  cp (0x0e26),0x00
	jr	z, Quantize_ApplyRoundMapToTrack_Skip4	; F5DCC4  jr Z,0xf5dcd6
	cp	(0x0e26:16), 0x7f	; F5DCC6  cp (0x0e26),0x7f
	jr	nz, Quantize_ApplyRoundMapToTrack_Skip5	; F5DCCB  jr NZ,0xf5dcde
	cp	a, (0x0e27:16)	; F5DCCD  cp A,(0x0e27)
	jrl	gt, Quantize_ApplyRoundMapToTrack_Skip12	; F5DCD1  jrl GT,0xf5dd51
	jr	Quantize_ApplyRoundMapToTrack_Join3	; F5DCD4  jr T,0xf5dcea
Quantize_ApplyRoundMapToTrack_Skip4:
	cp	a, (0x0e28:16)	; F5DCD6  cp A,(0x0e28)
	jr	lt, Quantize_ApplyRoundMapToTrack_Skip12	; F5DCDA  jr LT,0xf5dd51
	jr	Quantize_ApplyRoundMapToTrack_Join3	; F5DCDC  jr T,0xf5dcea
Quantize_ApplyRoundMapToTrack_Skip5:
	cp	a, (0x0e27:16)	; F5DCDE  cp A,(0x0e27)
	jr	le, Quantize_ApplyRoundMapToTrack_Join3	; F5DCE2  jr LE,0xf5dcea
	cp	a, (0x0e28:16)	; F5DCE4  cp A,(0x0e28)
	jr	lt, Quantize_ApplyRoundMapToTrack_Skip12	; F5DCE8  jr LT,0xf5dd51
Quantize_ApplyRoundMapToTrack_Join3:
	ld	l, (3622:16)	; F5DCEA  ld L,(0x0e26)
	cp	(0x0e04:16), 0x64	; F5DCEE  cp (0x0e04),0x64
	jr	z, Quantize_ApplyRoundMapToTrack_Skip10	; F5DCF3  jr Z,0xf5dd3c
	cp	l, 127	; F5DCF5  cp L,0x7f
	jr	nz, Quantize_ApplyRoundMapToTrack_Skip6	; F5DCF8  jr NZ,0xf5dcfc
	ld	l, 96:opc	; F5DCFA  ld L,0x60
Quantize_ApplyRoundMapToTrack_Skip6:
	ld	a, (3621:16)	; F5DCFC  ld A,(0x0e25)
	cp	a, l	; F5DD00  cp A,L
	jr	lt, Quantize_ApplyRoundMapToTrack_Skip7	; F5DD02  jr LT,0xf5dd08
	sub	a, l	; F5DD04  sub A,L
	jr	Quantize_ApplyRoundMapToTrack_Join4	; F5DD06  jr T,0xf5dd0c
Quantize_ApplyRoundMapToTrack_Skip7:
	sub	l, a	; F5DD08  sub L,A
	ld	a, l	; F5DD0A  ld A,L
Quantize_ApplyRoundMapToTrack_Join4:
	xor	w, w	; F5DD0C  xor W,W
	ld	l, (3588:16)	; F5DD0E  ld L,(0x0e04)
	mul	wa, l	; F5DD12  mul WA,L
	ld	l, 100:opc	; F5DD14  ld L,0x64
	div	wa, l	; F5DD16  div WA,L
	ld	l, (3621:16)	; F5DD18  ld L,(0x0e25)
	ld	h, (3622:16)	; F5DD1C  ld H,(0x0e26)
	cp	h, 127	; F5DD20  cp H,0x7f
	jr	nz, Quantize_ApplyRoundMapToTrack_Skip8	; F5DD23  jr NZ,0xf5dd27
	ld	h, 96:opc	; F5DD25  ld H,0x60
Quantize_ApplyRoundMapToTrack_Skip8:
	cp	l, h	; F5DD27  cp L,H
	jr	lt, Quantize_ApplyRoundMapToTrack_Skip9	; F5DD29  jr LT,0xf5dd2f
	sub	l, a	; F5DD2B  sub L,A
	jr	Quantize_ApplyRoundMapToTrack_Join5	; F5DD2D  jr T,0xf5dd33
Quantize_ApplyRoundMapToTrack_Skip9:
	add	l, a	; F5DD2F  add L,A
	ld	a, l	; F5DD31  ld A,L
Quantize_ApplyRoundMapToTrack_Join5:
	cp	a, 96	; F5DD33  cp A,0x60
	jr	c, Quantize_ApplyRoundMapToTrack_Skip10	; F5DD36  jr C,0xf5dd3c
	ld	a, 127:opc	; F5DD38  ld A,0x7f
	ld	l, a	; F5DD3A  ld L,A
Quantize_ApplyRoundMapToTrack_Skip10:
	cp	l, 127	; F5DD3C  cp L,0x7f
	jr	nz, Quantize_ApplyRoundMapToTrack_Skip11	; F5DD3F  jr NZ,0xf5dd46
	or	(0x0c8a:16), 0x01	; F5DD41  or (0x0c8a),0x01
Quantize_ApplyRoundMapToTrack_Skip11:
	push	xix	; F5DD46  push XIX
	ld	xix, (BStore_CursorBlockAddr:16)	; F5DD47  ld XIX,(0x126e)
	ld	(xix+iy), l	; F5DD4B  ld (XIX+IY),L
	pop	xix	; F5DD50  pop XIX
Quantize_ApplyRoundMapToTrack_Skip12:
	call	T_BStore_CursorAdvance	; F5DD51  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F5DD55  cp (0x0d4a),0x00
	jr	nz, Quantize_ApplyRoundMapToTrack_Return	; F5DD5A  jr NZ,0xf5dda8
	jrl	Quantize_ApplyRoundMapToTrack_Join2	; F5DD5C  jrl T,0xf5dc23
Quantize_ApplyRoundMapToTrack_Skip13:
	pushw	bc	; F5DD5F  push BC
	pushw	de	; F5DD60  push DE
	calr	SongEdit_SortBeatEventsByTiming	; F5DD61  calr 0xf5e0bd
	call	Quantize_CarryRoundedUpEventsToNextBeat	; F5DD64  call 0xf5e01d
	popw	de	; F5DD68  pop DE
	popw	bc	; F5DD69  pop BC
	cp	(BStore_ErrorCode:16), 0x00	; F5DD6A  cp (0x0d4a),0x00
	jr	nz, Quantize_ApplyRoundMapToTrack_Return	; F5DD6F  jr NZ,0xf5dda8
	inc	1, c	; F5DD71  inc 1,C
	call	T_BStore_CursorAdvance	; F5DD73  call 0xf4279c
	jrl	Quantize_ApplyRoundMapToTrack_Join	; F5DD77  jrl T,0xf5dc07
Quantize_ApplyRoundMapToTrack_Skip14:
	inc	1, de	; F5DD7A  inc 1,DE
	push	xiz	; F5DD7C  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F5DD7D  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F5DD81  ld XDE3,XIZ
	pop	xiz	; F5DD84  pop XIZ
	push_lerp	0x38	; F5DD85  push XDE3
	push	xhl	; F5DD88  push XHL
	pushw	de	; F5DD89  push DE
	push	xiy	; F5DD8A  push XIY
	push	xix	; F5DD8B  push XIX
	call	T_F427A8	; F5DD8C  call 0xf427a8
	pop	xix	; F5DD90  pop XIX
	pop	xiy	; F5DD91  pop XIY
	popw	de	; F5DD92  pop DE
	pop	xhl	; F5DD93  pop XHL
	pop_lerp	0x38	; F5DD94  pop XDE3
	push	xiz	; F5DD97  push XIZ
	ldto_lerp	xiz, 0x38	; F5DD98  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F5DD9B  ld (0x126e),XIZ
	pop	xiz	; F5DD9F  pop XIZ
	cp	(BStore_ErrorCode:16), 0x00	; F5DDA0  cp (0x0d4a),0x00
	jrl	z, Quantize_ApplyRoundMapToTrack_Loop	; F5DDA5  jrl Z,0xf5dbfe
Quantize_ApplyRoundMapToTrack_Return:
	ret	; F5DDA8  ret
Quantize_ApplyRoundMapToTrack_Join6:
	call	T_BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_12	; F5DDA9  call 0xf42810
	call	T_F40A1C	; F5DDAD  call 0xf40a1c
	ret	; F5DDB1  ret

; --------------------------------------------------------------------------
; Quantize_ComputeWindowBounds
; Called from: in-module: 0xF5DC81
; Touches: (0x0C7F) (0x0E05) (0x0E25) (0x0E26) (0x0E27) (0x0E28) (0x0E29)
;          (0x0E2A)
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5DDB2 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_ComputeWindowBounds: QUANTIZE window for the event timing (0x0E25) and its grid point (0x0E26): picks the
;   half-grid boundary for resolution (0x0C7F) from RoundMap_Bounds_A / _B ((0x0E29) / (0x0E2A)), scales boundary -
;   grid point by WINDOW (0x0E05) % and stores (0x0E28) = grid point + that, (0x0E27) = grid point (0 or 0x7F read as
;   96) - that. Quantize_ApplyRoundMapToTrack leaves timings outside that range alone. Basis: caller + caller header +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
Quantize_ComputeWindowBounds:
	push	xwa	; F5DDB2  push XWA
	push	xhl	; F5DDB3  push XHL
	push	xbc	; F5DDB4  push XBC
	push	xde	; F5DDB5  push XDE
	push	xix	; F5DDB6  push XIX
	ld	a, (3199:16)	; F5DDB7  ld A,(0x0c7f)
	cp	a, 0:i3	; F5DDBB  cp A,0
	jr	z, Quantize_ComputeWindowBounds_Skip	; F5DDBD  jr Z,0xf5dddb
	cp	a, 2:i3	; F5DDBF  cp A,2
	jr	z, Quantize_ComputeWindowBounds_Skip2	; F5DDC1  jr Z,0xf5dde8
	cp	a, 4:i3	; F5DDC3  cp A,4
	jr	z, Quantize_ComputeWindowBounds_Skip4	; F5DDC5  jr Z,0xf5de1b
	cp	a, 6:i3	; F5DDC7  cp A,6
	jrl	z, Quantize_ComputeWindowBounds_Skip6	; F5DDC9  jrl Z,0xf5de5c
	cp	a, 8	; F5DDCC  cp A,0x08
	jrl	z, Quantize_ComputeWindowBounds_Skip8	; F5DDCF  jrl Z,0xf5deb8
	cp	a, 10	; F5DDD2  cp A,0x0a
	jrl	z, Quantize_ComputeWindowBounds_Skip10	; F5DDD5  jrl Z,0xf5def2
	jrl	Quantize_ComputeWindowBounds_Join	; F5DDD8  jrl T,0xf5df40
Quantize_ComputeWindowBounds_Skip:
	ld	(3625:16), 48	; F5DDDB  ld (0x0e29),0x30
	ld	(3626:16), 48	; F5DDE0  ld (0x0e2a),0x30
	jrl	Quantize_ComputeWindowBounds_Join2	; F5DDE5  jrl T,0xf5dfb5
Quantize_ComputeWindowBounds_Skip2:
	xor	de, de	; F5DDE8  xor DE,DE
	ld	a, (3621:16)	; F5DDEA  ld A,(0x0e25)
	cp	a, 24	; F5DDEE  cp A,0x18
	jr	lt, Quantize_ComputeWindowBounds_Skip3	; F5DDF1  jr LT,0xf5ddfc
	ld	e, 1:opc	; F5DDF3  ld E,0x01
	cp	a, 72	; F5DDF5  cp A,0x48
	jr	lt, Quantize_ComputeWindowBounds_Skip3	; F5DDF8  jr LT,0xf5ddfc
	xor	de, de	; F5DDFA  xor DE,DE
Quantize_ComputeWindowBounds_Skip3:
	ld	xix, RoundMap_Bounds_A + 0x1	; F5DDFC  ld XIX,0x00f621ba
	ld	a, (xix+de)	; F5DE01  ld A,(XIX+DE)
	ld	(3625:16), a	; F5DE06  ld (0x0e29),A
	ld	xix, RoundMap_Bounds_B + 0x1	; F5DE0A  ld XIX,0x00f621de
	ld	a, (xix+de)	; F5DE0F  ld A,(XIX+DE)
	ld	(3626:16), a	; F5DE14  ld (0x0e2a),A
	jrl	Quantize_ComputeWindowBounds_Join2	; F5DE18  jrl T,0xf5dfb5
Quantize_ComputeWindowBounds_Skip4:
	xor	de, de	; F5DE1B  xor DE,DE
	ld	a, (3621:16)	; F5DE1D  ld A,(0x0e25)
	cp	a, 12	; F5DE21  cp A,0x0c
	jr	lt, Quantize_ComputeWindowBounds_Skip5	; F5DE24  jr LT,0xf5de3d
	ld	e, 1:opc	; F5DE26  ld E,0x01
	cp	a, 36	; F5DE28  cp A,0x24
	jr	lt, Quantize_ComputeWindowBounds_Skip5	; F5DE2B  jr LT,0xf5de3d
	ld	e, 2:opc	; F5DE2D  ld E,0x02
	cp	a, 60	; F5DE2F  cp A,0x3c
	jr	lt, Quantize_ComputeWindowBounds_Skip5	; F5DE32  jr LT,0xf5de3d
	ld	e, 3:opc	; F5DE34  ld E,0x03
	cp	a, 84	; F5DE36  cp A,0x54
	jr	lt, Quantize_ComputeWindowBounds_Skip5	; F5DE39  jr LT,0xf5de3d
	xor	de, de	; F5DE3B  xor DE,DE
Quantize_ComputeWindowBounds_Skip5:
	ld	xix, RoundMap_Bounds_A + 0x3	; F5DE3D  ld XIX,0x00f621bc
	ld	a, (xix+de)	; F5DE42  ld A,(XIX+DE)
	ld	(3625:16), a	; F5DE47  ld (0x0e29),A
	ld	xix, RoundMap_Bounds_B + 0x3	; F5DE4B  ld XIX,0x00f621e0
	ld	a, (xix+de)	; F5DE50  ld A,(XIX+DE)
	ld	(3626:16), a	; F5DE55  ld (0x0e2a),A
	jrl	Quantize_ComputeWindowBounds_Join2	; F5DE59  jrl T,0xf5dfb5
Quantize_ComputeWindowBounds_Skip6:
	xor	de, de	; F5DE5C  xor DE,DE
	ld	a, (3621:16)	; F5DE5E  ld A,(0x0e25)
	cp	a, 6:i3	; F5DE62  cp A,6
	jr	lt, Quantize_ComputeWindowBounds_Skip7	; F5DE64  jr LT,0xf5de99
	ld	e, 1:opc	; F5DE66  ld E,0x01
	cp	a, 18	; F5DE68  cp A,0x12
	jr	lt, Quantize_ComputeWindowBounds_Skip7	; F5DE6B  jr LT,0xf5de99
	ld	e, 2:opc	; F5DE6D  ld E,0x02
	cp	a, 30	; F5DE6F  cp A,0x1e
	jr	lt, Quantize_ComputeWindowBounds_Skip7	; F5DE72  jr LT,0xf5de99
	ld	e, 3:opc	; F5DE74  ld E,0x03
	cp	a, 42	; F5DE76  cp A,0x2a
	jr	lt, Quantize_ComputeWindowBounds_Skip7	; F5DE79  jr LT,0xf5de99
	ld	e, 4:opc	; F5DE7B  ld E,0x04
	cp	a, 54	; F5DE7D  cp A,0x36
	jr	lt, Quantize_ComputeWindowBounds_Skip7	; F5DE80  jr LT,0xf5de99
	ld	e, 5:opc	; F5DE82  ld E,0x05
	cp	a, 66	; F5DE84  cp A,0x42
	jr	lt, Quantize_ComputeWindowBounds_Skip7	; F5DE87  jr LT,0xf5de99
	ld	e, 6:opc	; F5DE89  ld E,0x06
	cp	a, 78	; F5DE8B  cp A,0x4e
	jr	lt, Quantize_ComputeWindowBounds_Skip7	; F5DE8E  jr LT,0xf5de99
	ld	e, 7:opc	; F5DE90  ld E,0x07
	cp	a, 90	; F5DE92  cp A,0x5a
	jr	lt, Quantize_ComputeWindowBounds_Skip7	; F5DE95  jr LT,0xf5de99
	xor	de, de	; F5DE97  xor DE,DE
Quantize_ComputeWindowBounds_Skip7:
	ld	xix, RoundMap_Bounds_A + 0x7	; F5DE99  ld XIX,0x00f621c0
	ld	a, (xix+de)	; F5DE9E  ld A,(XIX+DE)
	ld	(3625:16), a	; F5DEA3  ld (0x0e29),A
	ld	xix, RoundMap_Bounds_B + 0x7	; F5DEA7  ld XIX,0x00f621e4
	ld	a, (xix+de)	; F5DEAC  ld A,(XIX+DE)
	ld	(3626:16), a	; F5DEB1  ld (0x0e2a),A
	jrl	Quantize_ComputeWindowBounds_Join2	; F5DEB5  jrl T,0xf5dfb5
Quantize_ComputeWindowBounds_Skip8:
	xor	de, de	; F5DEB8  xor DE,DE
	ld	a, (3621:16)	; F5DEBA  ld A,(0x0e25)
	cp	a, 16	; F5DEBE  cp A,0x10
	jr	lt, Quantize_ComputeWindowBounds_Skip9	; F5DEC1  jr LT,0xf5ded3
	ld	e, 1:opc	; F5DEC3  ld E,0x01
	cp	a, 48	; F5DEC5  cp A,0x30
	jr	lt, Quantize_ComputeWindowBounds_Skip9	; F5DEC8  jr LT,0xf5ded3
	ld	e, 2:opc	; F5DECA  ld E,0x02
	cp	a, 80	; F5DECC  cp A,0x50
	jr	lt, Quantize_ComputeWindowBounds_Skip9	; F5DECF  jr LT,0xf5ded3
	xor	de, de	; F5DED1  xor DE,DE
Quantize_ComputeWindowBounds_Skip9:
	ld	xix, RoundMap_Bounds_A + 0xF	; F5DED3  ld XIX,0x00f621c8
	ld	a, (xix+de)	; F5DED8  ld A,(XIX+DE)
	ld	(3625:16), a	; F5DEDD  ld (0x0e29),A
	ld	xix, RoundMap_Bounds_B + 0xF	; F5DEE1  ld XIX,0x00f621ec
	ld	a, (xix+de)	; F5DEE6  ld A,(XIX+DE)
	ld	(3626:16), a	; F5DEEB  ld (0x0e2a),A
	jrl	Quantize_ComputeWindowBounds_Join2	; F5DEEF  jrl T,0xf5dfb5
Quantize_ComputeWindowBounds_Skip10:
	xor	de, de	; F5DEF2  xor DE,DE
	ld	a, (3621:16)	; F5DEF4  ld A,(0x0e25)
	cp	a, 8	; F5DEF8  cp A,0x08
	jr	lt, Quantize_ComputeWindowBounds_Skip11	; F5DEFB  jr LT,0xf5df22
	ld	e, 1:opc	; F5DEFD  ld E,0x01
	cp	a, 24	; F5DEFF  cp A,0x18
	jr	lt, Quantize_ComputeWindowBounds_Skip11	; F5DF02  jr LT,0xf5df22
	ld	e, 2:opc	; F5DF04  ld E,0x02
	cp	a, 40	; F5DF06  cp A,0x28
	jr	lt, Quantize_ComputeWindowBounds_Skip11	; F5DF09  jr LT,0xf5df22
	ld	e, 3:opc	; F5DF0B  ld E,0x03
	cp	a, 56	; F5DF0D  cp A,0x38
	jr	lt, Quantize_ComputeWindowBounds_Skip11	; F5DF10  jr LT,0xf5df22
	ld	e, 4:opc	; F5DF12  ld E,0x04
	cp	a, 72	; F5DF14  cp A,0x48
	jr	lt, Quantize_ComputeWindowBounds_Skip11	; F5DF17  jr LT,0xf5df22
	ld	e, 5:opc	; F5DF19  ld E,0x05
	cp	a, 88	; F5DF1B  cp A,0x58
	jr	lt, Quantize_ComputeWindowBounds_Skip11	; F5DF1E  jr LT,0xf5df22
	xor	de, de	; F5DF20  xor DE,DE
Quantize_ComputeWindowBounds_Skip11:
	ld	xix, RoundMap_Bounds_A + 0x12	; F5DF22  ld XIX,0x00f621cb
	ld	a, (xix+de)	; F5DF27  ld A,(XIX+DE)
	ld	(3625:16), a	; F5DF2C  ld (0x0e29),A
	ld	xix, RoundMap_Bounds_B + 0x12	; F5DF30  ld XIX,0x00f621ef
	ld	a, (xix+de)	; F5DF35  ld A,(XIX+DE)
	ld	(3626:16), a	; F5DF3A  ld (0x0e2a),A
	jr	Quantize_ComputeWindowBounds_Join2	; F5DF3E  jr T,0xf5dfb5
Quantize_ComputeWindowBounds_Join:
	xor	de, de	; F5DF40  xor DE,DE
	ld	a, (3621:16)	; F5DF42  ld A,(0x0e25)
	cp	a, 4:i3	; F5DF46  cp A,4
	jr	lt, Quantize_ComputeWindowBounds_Skip12	; F5DF48  jr LT,0xf5df99
	ld	e, 1:opc	; F5DF4A  ld E,0x01
	cp	a, 12	; F5DF4C  cp A,0x0c
	jr	lt, Quantize_ComputeWindowBounds_Skip12	; F5DF4F  jr LT,0xf5df99
	ld	e, 2:opc	; F5DF51  ld E,0x02
	cp	a, 20	; F5DF53  cp A,0x14
	jr	lt, Quantize_ComputeWindowBounds_Skip12	; F5DF56  jr LT,0xf5df99
	ld	e, 3:opc	; F5DF58  ld E,0x03
	cp	a, 28	; F5DF5A  cp A,0x1c
	jr	lt, Quantize_ComputeWindowBounds_Skip12	; F5DF5D  jr LT,0xf5df99
	ld	e, 4:opc	; F5DF5F  ld E,0x04
	cp	a, 36	; F5DF61  cp A,0x24
	jr	lt, Quantize_ComputeWindowBounds_Skip12	; F5DF64  jr LT,0xf5df99
	ld	e, 5:opc	; F5DF66  ld E,0x05
	cp	a, 44	; F5DF68  cp A,0x2c
	jr	lt, Quantize_ComputeWindowBounds_Skip12	; F5DF6B  jr LT,0xf5df99
	ld	e, 6:opc	; F5DF6D  ld E,0x06
	cp	a, 52	; F5DF6F  cp A,0x34
	jr	lt, Quantize_ComputeWindowBounds_Skip12	; F5DF72  jr LT,0xf5df99
	ld	e, 7:opc	; F5DF74  ld E,0x07
	cp	a, 60	; F5DF76  cp A,0x3c
	jr	lt, Quantize_ComputeWindowBounds_Skip12	; F5DF79  jr LT,0xf5df99
	ld	e, 8:opc	; F5DF7B  ld E,0x08
	cp	a, 68	; F5DF7D  cp A,0x44
	jr	lt, Quantize_ComputeWindowBounds_Skip12	; F5DF80  jr LT,0xf5df99
	ld	e, 9:opc	; F5DF82  ld E,0x09
	cp	a, 76	; F5DF84  cp A,0x4c
	jr	lt, Quantize_ComputeWindowBounds_Skip12	; F5DF87  jr LT,0xf5df99
	ld	e, 10:opc	; F5DF89  ld E,0x0a
	cp	a, 84	; F5DF8B  cp A,0x54
	jr	lt, Quantize_ComputeWindowBounds_Skip12	; F5DF8E  jr LT,0xf5df99
	ld	e, 11:opc	; F5DF90  ld E,0x0b
	cp	a, 92	; F5DF92  cp A,0x5c
	jr	lt, Quantize_ComputeWindowBounds_Skip12	; F5DF95  jr LT,0xf5df99
	xor	de, de	; F5DF97  xor DE,DE
Quantize_ComputeWindowBounds_Skip12:
	ld	xix, RoundMap_Bounds_A + 0x18	; F5DF99  ld XIX,0x00f621d1
	ld	a, (xix+de)	; F5DF9E  ld A,(XIX+DE)
	ld	(3625:16), a	; F5DFA3  ld (0x0e29),A
	ld	xix, RoundMap_Bounds_B + 0x18	; F5DFA7  ld XIX,0x00f621f5
	ld	a, (xix+de)	; F5DFAC  ld A,(XIX+DE)
	ld	(3626:16), a	; F5DFB1  ld (0x0e2a),A
Quantize_ComputeWindowBounds_Join2:
	xor	w, w	; F5DFB5  xor W,W
	ld	a, (3625:16)	; F5DFB7  ld A,(0x0e29)
	ld	w, (3622:16)	; F5DFBB  ld W,(0x0e26)
	cp	w, 127	; F5DFBF  cp W,0x7f
	jr	nz, Quantize_ComputeWindowBounds_Skip13	; F5DFC2  jr NZ,0xf5dfc6
	xor	w, w	; F5DFC4  xor W,W
Quantize_ComputeWindowBounds_Skip13:
	sub	a, w	; F5DFC6  sub A,W
	xor	w, w	; F5DFC8  xor W,W
	ld	l, (3589:16)	; F5DFCA  ld L,(0x0e05)
	bit	7, l	; F5DFCE  bit 0x07,L
	jr	z, Quantize_ComputeWindowBounds_Skip15	; F5DFD1  jr Z,0xf5dfed
	xor	h, h	; F5DFD3  xor H,H
	ldw	de, 256	; F5DFD5  ld DE,0x0100
	sub	de, hl	; F5DFD8  sub DE,HL
	ld	l, 100:opc	; F5DFDA  ld L,0x64
	sub	l, e	; F5DFDC  sub L,E
	ld	w, (3622:16)	; F5DFDE  ld W,(0x0e26)
	cp	w, 127	; F5DFE2  cp W,0x7f
	jr	nz, Quantize_ComputeWindowBounds_Skip14	; F5DFE5  jr NZ,0xf5dfe9
	xor	w, w	; F5DFE7  xor W,W
Quantize_ComputeWindowBounds_Skip14:
	sub	a, w	; F5DFE9  sub A,W
	xor	w, w	; F5DFEB  xor W,W
Quantize_ComputeWindowBounds_Skip15:
	mul	wa, l	; F5DFED  mul WA,L
	ld	l, 100:opc	; F5DFEF  ld L,0x64
	div	wa, l	; F5DFF1  div WA,L
	ld	l, (3622:16)	; F5DFF3  ld L,(0x0e26)
	ld	h, l	; F5DFF7  ld H,L
	cp	l, 127	; F5DFF9  cp L,0x7f
	jr	nz, Quantize_ComputeWindowBounds_Skip16	; F5DFFC  jr NZ,0xf5e000
	ld	l, 0:opc	; F5DFFE  ld L,0x00
Quantize_ComputeWindowBounds_Skip16:
	add	l, a	; F5E000  add L,A
	ld	(3624:16), l	; F5E002  ld (0x0e28),L
	cp	h, 0:i3	; F5E006  cp H,0
	jr	z, Quantize_ComputeWindowBounds_Skip17	; F5E008  jr Z,0xf5e00f
	cp	h, 127	; F5E00A  cp H,0x7f
	jr	nz, Quantize_ComputeWindowBounds_Skip18	; F5E00D  jr NZ,0xf5e011
Quantize_ComputeWindowBounds_Skip17:
	ld	h, 96:opc	; F5E00F  ld H,0x60
Quantize_ComputeWindowBounds_Skip18:
	sub	h, a	; F5E011  sub H,A
	ld	(3623:16), h	; F5E013  ld (0x0e27),H
	pop	xix	; F5E017  pop XIX
	pop	xde	; F5E018  pop XDE
	pop	xbc	; F5E019  pop XBC
	pop	xhl	; F5E01A  pop XHL
	pop	xwa	; F5E01B  pop XWA
	ret	; F5E01C  ret

; --------------------------------------------------------------------------
; Quantize_CarryRoundedUpEventsToNextBeat
; Called from: in-module: 0xF5DD64
; Touches: (0x0C8A) (0x0D0A) (0x0D14) (0x0D4A) (0x126E)
; Calls:   T_BStore_CursorAdvance
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5E01D is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Quantize_CarryRoundedUpEventsToNextBeat: At a beat's 0x81 mark, when QUANTIZE rounded an event of that beat up to
;   0x7F (the map's 96, (0x0C8A) bit 0): from the beat start (0x0D14)/(0x0D0A) finds the first event whose timing is
;   0x7F, writes 0x81 at its status byte and shifts the bytes after it up to the old 0x81 one place on, setting the
;   shifted events' timing bytes to 0 -- they move into the next beat at tick 0. (0x126E) preserved. Basis: caller +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
Quantize_CarryRoundedUpEventsToNextBeat:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E01D  ld XHL,(0x126e)
	push	xhl	; F5E021  push XHL
	bit	0, (0x0c8a:16)	; F5E022  bit 0,(0x0c8a)
	jrl	z, Quantize_CarryRoundedUpEventsToNextBeat_Skip4	; F5E026  jrl Z,0xf5e0b7
	xor	hl, hl	; F5E029  xor HL,HL
	ld	iy, (3338:16)	; F5E02B  ld IY,(0x0d0a)
	push	xhl	; F5E02F  push XHL
	ld	xhl, (3348:16)	; F5E030  ld XHL,(0x0d14)
	ld	(BStore_CursorBlockAddr:16), xhl	; F5E034  ld (0x126e),XHL
	pop	xhl	; F5E038  pop XHL
Quantize_CarryRoundedUpEventsToNextBeat_Join:
	call	T_BStore_CursorAdvance	; F5E039  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F5E03D  cp (0x0d4a),0x00
	jrl	nz, Quantize_CarryRoundedUpEventsToNextBeat_Skip4	; F5E042  jrl NZ,0xf5e0b7
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E045  ld XHL,(0x126e)
	cp	(xhl+iy), 0x7f	; F5E049  cp (XHL+IY),0x7f
	jr	z, Quantize_CarryRoundedUpEventsToNextBeat_Skip	; F5E04F  jr Z,0xf5e077
Quantize_CarryRoundedUpEventsToNextBeat_Loop:
	call	T_BStore_CursorAdvance	; F5E051  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F5E055  cp (0x0d4a),0x00
	jr	nz, Quantize_CarryRoundedUpEventsToNextBeat_Skip4	; F5E05A  jr NZ,0xf5e0b7
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E05C  ld XHL,(0x126e)
	bit	7, (xhl+iy)	; F5E060  bit 7,(XHL+IY)
	jr	z, Quantize_CarryRoundedUpEventsToNextBeat_Loop	; F5E065  jr Z,0xf5e051
	ld	(3338:16), iy	; F5E067  ld (0x0d0a),IY
	push	xwa	; F5E06B  push XWA
	ld	xwa, (BStore_CursorBlockAddr:16)	; F5E06C  ld XWA,(0x126e)
	ld	(3348:16), xwa	; F5E070  ld (0x0d14),XWA
	pop	xwa	; F5E074  pop XWA
	jr	Quantize_CarryRoundedUpEventsToNextBeat_Join	; F5E075  jr T,0xf5e039
Quantize_CarryRoundedUpEventsToNextBeat_Skip:
	pushw	de	; F5E077  push DE
	pushw	bc	; F5E078  push BC
	ld	iy, (3338:16)	; F5E079  ld IY,(0x0d0a)
	ld	xhl, (3348:16)	; F5E07D  ld XHL,(0x0d14)
	ld	(BStore_CursorBlockAddr:16), xhl	; F5E081  ld (0x126e),XHL
	ld	d, (xhl+iy)	; F5E085  ld D,(XHL+IY)
	ld	(xhl+iy), 0x81	; F5E08A  ld (XHL+IY),0x81
Quantize_CarryRoundedUpEventsToNextBeat_Join2:
	cp	d, 129	; F5E090  cp D,0x81
	jr	z, Quantize_CarryRoundedUpEventsToNextBeat_Skip3	; F5E093  jr Z,0xf5e0b5
	call	T_BStore_CursorAdvance	; F5E095  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F5E099  cp (0x0d4a),0x00
	jr	nz, Quantize_CarryRoundedUpEventsToNextBeat_Skip3	; F5E09E  jr NZ,0xf5e0b5
	ld	e, d	; F5E0A0  ld E,D
	ld	d, (xhl+iy)	; F5E0A2  ld D,(XHL+IY)
	ld	(xhl+iy), e	; F5E0A7  ld (XHL+IY),E
	bit	7, e	; F5E0AC  bit 0x07,E
	jr	z, Quantize_CarryRoundedUpEventsToNextBeat_Skip2	; F5E0AF  jr Z,0xf5e0b3
	ld	d, 0:opc	; F5E0B1  ld D,0x00
Quantize_CarryRoundedUpEventsToNextBeat_Skip2:
	jr	Quantize_CarryRoundedUpEventsToNextBeat_Join2	; F5E0B3  jr T,0xf5e090
Quantize_CarryRoundedUpEventsToNextBeat_Skip3:
	popw	bc	; F5E0B5  pop BC
	popw	de	; F5E0B6  pop DE
Quantize_CarryRoundedUpEventsToNextBeat_Skip4:
	pop	xhl	; F5E0B7  pop XHL
	ld	(BStore_CursorBlockAddr:16), xhl	; F5E0B8  ld (0x126e),XHL
	ret	; F5E0BC  ret

; --------------------------------------------------------------------------
; SongEdit_SortBeatEventsByTiming
; Called from: in-module: 0xF5DD61 0xF62003 0xF620AA
; Touches: (0x0D0A) (0x0D14) (0x0D20) (0x0D21) (0x0D22) (0x0D24) (0x0D28)
;          (0x0D2A) (0x0D4A) (0x126E)
; Calls:   T_BStore_CursorAdvance SongEdit_SortBeatAdvanceScan SongEdit_SortBeatMoveEventToAnchor SongEdit_SortBeatAdvanceAnchor
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5E0BD is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_SortBeatEventsByTiming: Sorts the events of one beat, from (0x0D14)/(0x0D0A) to the next 0x81 / 0x82, into
;   ascending timing-byte order: for each anchor event (0x0D22)/(0x0D24) it scans the later ones (SongEdit_SortBeatAdvanceScan) and
;   moves any with a smaller timing in front of the anchor (SongEdit_SortBeatMoveEventToAnchor: data bytes buffered at 0x0D36,
;   T_BStore_CopyRangeBackward opens the gap). Run after QUANTIZE and ADVANCE/DELAY rewrite timings. Basis: callers +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
SongEdit_SortBeatEventsByTiming:
	ld	iy, (3338:16)	; F5E0BD  ld IY,(0x0d0a)
	ld	(3362:16), iy	; F5E0C1  ld (0x0d22),IY
	ld	xhl, (3348:16)	; F5E0C5  ld XHL,(0x0d14)
	ld	(BStore_CursorBlockAddr:16), xhl	; F5E0C9  ld (0x126e),XHL
	ld	(3364:16), xhl	; F5E0CD  ld (0x0d24),XHL
	cp	(xhl+iy), 0x82	; F5E0D1  cp (XHL+IY),0x82
	jr	z, SongEdit_SortBeatEventsByTiming_Skip	; F5E0D7  jr Z,0xf5e0e1
	cp	(xhl+iy), 0x81	; F5E0D9  cp (XHL+IY),0x81
	jr	nz, SongEdit_SortBeatEventsByTiming_Skip2	; F5E0DF  jr NZ,0xf5e0e4
SongEdit_SortBeatEventsByTiming_Skip:
	jrl	SongEdit_SortBeatEventsByTiming_Return	; F5E0E1  jrl T,0xf5e1a0
SongEdit_SortBeatEventsByTiming_Skip2:
	call	T_BStore_CursorAdvance	; F5E0E4  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F5E0E8  cp (0x0d4a),0x00
	jrl	nz, SongEdit_SortBeatEventsByTiming_Return	; F5E0ED  jrl NZ,0xf5e1a0
	ld	a, (xhl+iy)	; F5E0F0  ld A,(XHL+IY)
	ld	(3360:16), a	; F5E0F5  ld (0x0d20),A
	ld	(3368:16), iy	; F5E0F9  ld (0x0d28),IY
	push	xwa	; F5E0FD  push XWA
	ld	xwa, (BStore_CursorBlockAddr:16)	; F5E0FE  ld XWA,(0x126e)
	ld	(3370:16), xwa	; F5E102  ld (0x0d2a),XWA
	pop	xwa	; F5E106  pop XWA
	calr	SongEdit_SortBeatAdvanceScan	; F5E107  calr 0xf5e370
	cp	(BStore_ErrorCode:16), 0x00	; F5E10A  cp (0x0d4a),0x00
	jr	z, SongEdit_SortBeatEventsByTiming_Skip3	; F5E10F  jr Z,0xf5e114
	jrl	SongEdit_SortBeatEventsByTiming_Return	; F5E111  jrl T,0xf5e1a0
SongEdit_SortBeatEventsByTiming_Skip3:
	cp	(xhl+iy), 0x82	; F5E114  cp (XHL+IY),0x82
	jrl	z, SongEdit_SortBeatEventsByTiming_Return	; F5E11A  jrl Z,0xf5e1a0
	cp	(xhl+iy), 0x81	; F5E11D  cp (XHL+IY),0x81
	jrl	z, SongEdit_SortBeatEventsByTiming_Return	; F5E123  jrl Z,0xf5e1a0
SongEdit_SortBeatEventsByTiming_Loop:
	ld	a, (3361:16)	; F5E126  ld A,(0x0d21)
	cp	(3360:16), a	; F5E12A  cp (0x0d20),A
	jr	ule, SongEdit_SortBeatEventsByTiming_Skip4	; F5E12E  jr ULE,0xf5e142
	calr	SongEdit_SortBeatMoveEventToAnchor	; F5E130  calr 0xf5e1a1
	cp	(BStore_ErrorCode:16), 0x00	; F5E133  cp (0x0d4a),0x00
	jr	nz, SongEdit_SortBeatEventsByTiming_Return	; F5E138  jr NZ,0xf5e1a0
	ld	a, (3361:16)	; F5E13A  ld A,(0x0d21)
	ld	(3360:16), a	; F5E13E  ld (0x0d20),A
SongEdit_SortBeatEventsByTiming_Skip4:
	calr	SongEdit_SortBeatAdvanceScan	; F5E142  calr 0xf5e370
	cp	(BStore_ErrorCode:16), 0x00	; F5E145  cp (0x0d4a),0x00
	jr	nz, SongEdit_SortBeatEventsByTiming_Return	; F5E14A  jr NZ,0xf5e1a0
	cp	(xhl+iy), 0x82	; F5E14C  cp (XHL+IY),0x82
	jr	z, SongEdit_SortBeatEventsByTiming_Skip5	; F5E152  jr Z,0xf5e15e
	cp	(xhl+iy), 0x81	; F5E154  cp (XHL+IY),0x81
	jr	z, SongEdit_SortBeatEventsByTiming_Skip5	; F5E15A  jr Z,0xf5e15e
	jr	SongEdit_SortBeatEventsByTiming_Loop	; F5E15C  jr T,0xf5e126
SongEdit_SortBeatEventsByTiming_Skip5:
	calr	SongEdit_SortBeatAdvanceAnchor	; F5E15E  calr 0xf5e306
	cp	(BStore_ErrorCode:16), 0x00	; F5E161  cp (0x0d4a),0x00
	jr	nz, SongEdit_SortBeatEventsByTiming_Return	; F5E166  jr NZ,0xf5e1a0
	cp	(xhl+iy), 0x82	; F5E168  cp (XHL+IY),0x82
	jr	z, SongEdit_SortBeatEventsByTiming_Return	; F5E16E  jr Z,0xf5e1a0
	cp	(xhl+iy), 0x81	; F5E170  cp (XHL+IY),0x81
	jr	z, SongEdit_SortBeatEventsByTiming_Return	; F5E176  jr Z,0xf5e1a0
	ld	(3368:16), iy	; F5E178  ld (0x0d28),IY
	push	xhl	; F5E17C  push XHL
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E17D  ld XHL,(0x126e)
	ld	(3370:16), xhl	; F5E181  ld (0x0d2a),XHL
	pop	xhl	; F5E185  pop XHL
	calr	SongEdit_SortBeatAdvanceScan	; F5E186  calr 0xf5e370
	cp	(BStore_ErrorCode:16), 0x00	; F5E189  cp (0x0d4a),0x00
	jr	nz, SongEdit_SortBeatEventsByTiming_Return	; F5E18E  jr NZ,0xf5e1a0
	cp	(xhl+iy), 0x82	; F5E190  cp (XHL+IY),0x82
	jr	z, SongEdit_SortBeatEventsByTiming_Return	; F5E196  jr Z,0xf5e1a0
	cp	(xhl+iy), 0x81	; F5E198  cp (XHL+IY),0x81
	jr	nz, SongEdit_SortBeatEventsByTiming_Loop	; F5E19E  jr NZ,0xf5e126
SongEdit_SortBeatEventsByTiming_Return:
	ret	; F5E1A0  ret

; --------------------------------------------------------------------------
; SongEdit_SortBeatMoveEventToAnchor
; Called from: in-module: 0xF5E130
; Touches: (0x0C57) (0x0C59) (0x0C5D) (0x0C61) (0x0C67) (0x0C6B) (0x0D21)
;          (0x0D22) (0x0D24) (0x0D28) +6 more  |  0x000D36
; Calls:   T_BStore_CursorAdvance BStore_CursorStepBack BStore_CursorBlockAddrToNumber T_BStore_CopyRangeBackward T_BStore_SeekBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5E1A1 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_SortBeatMoveEventToAnchor: Moves the scanned event ((0x0D28)/(0x0D2A): status (0x0D34), timing (0x0D21),
;   data bytes buffered at 0x0D36) in front of the anchor event ((0x0D22)/(0x0D24)): T_BStore_CopyRangeBackward shifts
;   anchor..scan up by the event's length, then the event is written at the anchor. SongEdit_SortBeatEventsByTiming's
;   move step when the scanned timing is smaller. Basis: caller + caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_a8.json)
SongEdit_SortBeatMoveEventToAnchor:
	ld	xix, 3382	; F5E1A1  ld XIX,0x00000d36
	call	T_BStore_CursorAdvance	; F5E1A6  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F5E1AA  cp (0x0d4a),0x00
	jrl	nz, SongEdit_SortBeatMoveEventToAnchor_Return	; F5E1AF  jrl NZ,0xf5e2b8
SongEdit_SortBeatMoveEventToAnchor_Loop:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E1B2  ld XHL,(0x126e)
	bit	7, (xhl+iy)	; F5E1B6  bit 7,(XHL+IY)
	jr	nz, SongEdit_SortBeatMoveEventToAnchor_Skip	; F5E1BB  jr NZ,0xf5e1d4
	ld	a, (xhl+iy)	; F5E1BD  ld A,(XHL+IY)
	ld	(xix), a	; F5E1C2  ld (XIX),A
	inc	1, xix	; F5E1C4  inc 1,XIX
	call	T_BStore_CursorAdvance	; F5E1C6  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F5E1CA  cp (0x0d4a),0x00
	jr	z, SongEdit_SortBeatMoveEventToAnchor_Loop	; F5E1CF  jr Z,0xf5e1b2
	jrl	SongEdit_SortBeatMoveEventToAnchor_Return	; F5E1D1  jrl T,0xf5e2b8
SongEdit_SortBeatMoveEventToAnchor_Skip:
	ld	(3376:16), xix	; F5E1D4  ld (0x0d30),XIX
	calr	BStore_CursorStepBack	; F5E1D8  calr 0xf5e2b9
	cp	(BStore_ErrorCode:16), 0x00	; F5E1DB  cp (0x0d4a),0x00
	jrl	nz, SongEdit_SortBeatMoveEventToAnchor_Return	; F5E1E0  jrl NZ,0xf5e2b8
	calr	BStore_CursorBlockAddrToNumber	; F5E1E3  calr 0xf5e2f0
	ld	(3165:16), iy	; F5E1E6  ld (0x0c5d),IY
	ld	wa, (3374:16)	; F5E1EA  ld WA,(0x0d2e)
	ld	(3159:16), wa	; F5E1EE  ld (0x0c57),WA
	ld	iy, (3368:16)	; F5E1F2  ld IY,(0x0d28)
	ld	xhl, (3370:16)	; F5E1F6  ld XHL,(0x0d2a)
	ld	(BStore_CursorBlockAddr:16), xhl	; F5E1FA  ld (0x126e),XHL
	ld	a, (xhl+iy)	; F5E1FE  ld A,(XHL+IY)
	ld	(3380:16), a	; F5E203  ld (0x0d34),A
	calr	BStore_CursorStepBack	; F5E207  calr 0xf5e2b9
	cp	(BStore_ErrorCode:16), 0x00	; F5E20A  cp (0x0d4a),0x00
	jrl	nz, SongEdit_SortBeatMoveEventToAnchor_Return	; F5E20F  jrl NZ,0xf5e2b8
	calr	BStore_CursorBlockAddrToNumber	; F5E212  calr 0xf5e2f0
	ld	(3175:16), iy	; F5E215  ld (0x0c67),IY
	ld	wa, (3374:16)	; F5E219  ld WA,(0x0d2e)
	ld	(3169:16), wa	; F5E21D  ld (0x0c61),WA
	push	xhl	; F5E221  push XHL
	ld	xhl, (3364:16)	; F5E222  ld XHL,(0x0d24)
	ld	(BStore_CursorBlockAddr:16), xhl	; F5E226  ld (0x126e),XHL
	pop	xhl	; F5E22A  pop XHL
	calr	BStore_CursorBlockAddrToNumber	; F5E22B  calr 0xf5e2f0
	ld	de, (3374:16)	; F5E22E  ld DE,(0x0d2e)
	ld	iy, (3362:16)	; F5E232  ld IY,(0x0d22)
	ld	(3179:16), iy	; F5E236  ld (0x0c6b),IY
	call	T_BStore_CopyRangeBackward	; F5E23A  call 0xf4277c
	cp	(BStore_ErrorCode:16), 0x00	; F5E23E  cp (0x0d4a),0x00
	jrl	nz, SongEdit_SortBeatMoveEventToAnchor_Return	; F5E243  jrl NZ,0xf5e2b8
	ld	xhl, (BStore_CopyDestAddr:16)	; F5E246  ld XHL,(0x0c59)
	ld	(BStore_CursorBlockAddr:16), xhl	; F5E24A  ld (0x126e),XHL
	ld	iy, ix	; F5E24E  ld IY,IX
	cp	iy, 5:i3	; F5E250  cp IY,5
	jr	nc, SongEdit_SortBeatMoveEventToAnchor_Skip3	; F5E252  jr NC,0xf5e26f
	xor	iy, iy	; F5E254  xor IY,IY
	ld	hl, (xhl+1)	; F5E256  ld HL,(XHL+0x01)
	call	T_BStore_SeekBlock	; F5E259  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E25D  ld XHL,(0x126e)
	bit	7, (xhl)	; F5E261  bit 7,(XHL)
	jr	nz, SongEdit_SortBeatMoveEventToAnchor_Skip2	; F5E263  jr NZ,0xf5e26c
	ld	(BStore_ErrorCode:16), 11	; F5E265  ld (0x0d4a),0x0b
	jr	SongEdit_SortBeatMoveEventToAnchor_Return	; F5E26A  jr T,0xf5e2b8
SongEdit_SortBeatMoveEventToAnchor_Skip2:
	ldw	iy, 255	; F5E26C  ld IY,0x00ff
SongEdit_SortBeatMoveEventToAnchor_Skip3:
	ld	xix, (3376:16)	; F5E26F  ld XIX,(0x0d30)
SongEdit_SortBeatMoveEventToAnchor_Loop2:
	cp	xix, 3382	; F5E273  cp XIX,0x00000d36
	jr	z, SongEdit_SortBeatMoveEventToAnchor_Skip4	; F5E279  jr Z,0xf5e294
	dec	1, xix	; F5E27B  dec 1,XIX
	ld	a, (xix)	; F5E27D  ld A,(XIX)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E27F  ld XHL,(0x126e)
	ld	(xhl+iy), a	; F5E283  ld (XHL+IY),A
	calr	BStore_CursorStepBack	; F5E288  calr 0xf5e2b9
	cp	(BStore_ErrorCode:16), 0x00	; F5E28B  cp (0x0d4a),0x00
	jr	z, SongEdit_SortBeatMoveEventToAnchor_Loop2	; F5E290  jr Z,0xf5e273
	jr	SongEdit_SortBeatMoveEventToAnchor_Return	; F5E292  jr T,0xf5e2b8
SongEdit_SortBeatMoveEventToAnchor_Skip4:
	ld	a, (3361:16)	; F5E294  ld A,(0x0d21)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E298  ld XHL,(0x126e)
	ld	(xhl+iy), a	; F5E29C  ld (XHL+IY),A
	calr	BStore_CursorStepBack	; F5E2A1  calr 0xf5e2b9
	cp	(BStore_ErrorCode:16), 0x00	; F5E2A4  cp (0x0d4a),0x00
	jr	nz, SongEdit_SortBeatMoveEventToAnchor_Return	; F5E2A9  jr NZ,0xf5e2b8
	ld	a, (3380:16)	; F5E2AB  ld A,(0x0d34)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E2AF  ld XHL,(0x126e)
	ld	(xhl+iy), a	; F5E2B3  ld (XHL+IY),A
SongEdit_SortBeatMoveEventToAnchor_Return:
	ret	; F5E2B8  ret

; --------------------------------------------------------------------------
; BStore_CursorStepBack
; Called from: in-module: 0xF5E1D8 0xF5E207 0xF5E288 0xF5E2A1 0xF61D88
; Touches: (0x0CA4) (0x0D4A) (0x126E)
; Calls:   T_BStore_SeekBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5E2B9 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_CursorStepBack: Steps the cursor (block address (0x126E), offset IY) back one byte: IY - 1, or below offset 5
;   the block's +1 previous link at offset 0xFF (BStore_ErrorCode 10 for link 0 or above BStore_BlockLimit, 11 for a
;   free block). The backward twin of BStore_CursorAdvance; SongEdit_SortBeatMoveEventToAnchor writes an event back to
;   front with it. Basis: caller + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave9_d9.json)
BStore_CursorStepBack:
	dec	1, iy	; F5E2B9  dec 1,IY
	cp	iy, 5:i3	; F5E2BB  cp IY,5
	jr	nc, BStore_CursorStepBack_Return	; F5E2BD  jr NC,0xf5e2ef
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E2BF  ld XHL,(0x126e)
	ld	wa, (xhl+1)	; F5E2C3  ld WA,(XHL+0x01)
	cp	wa, 0:i3	; F5E2C6  cp WA,0
	jr	z, BStore_CursorStepBack_Skip	; F5E2C8  jr Z,0xf5e2d0
	cp	wa, (BStore_BlockLimit:16)	; F5E2CA  cp WA,(0x0ca4)
	jr	ule, BStore_CursorStepBack_Skip2	; F5E2CE  jr ULE,0xf5e2d7
BStore_CursorStepBack_Skip:
	ld	(BStore_ErrorCode:16), 10	; F5E2D0  ld (0x0d4a),0x0a
	jr	BStore_CursorStepBack_Return	; F5E2D5  jr T,0xf5e2ef
BStore_CursorStepBack_Skip2:
	ld	hl, wa	; F5E2D7  ld HL,WA
	call	T_BStore_SeekBlock	; F5E2D9  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E2DD  ld XHL,(0x126e)
	bit	7, (xhl)	; F5E2E1  bit 7,(XHL)
	jr	nz, BStore_CursorStepBack_Skip3	; F5E2E3  jr NZ,0xf5e2ec
	ld	(BStore_ErrorCode:16), 11	; F5E2E5  ld (0x0d4a),0x0b
	jr	BStore_CursorStepBack_Return	; F5E2EA  jr T,0xf5e2ef
BStore_CursorStepBack_Skip3:
	ldw	iy, 255	; F5E2EC  ld IY,0x00ff
BStore_CursorStepBack_Return:
	ret	; F5E2EF  ret

; --------------------------------------------------------------------------
; BStore_CursorBlockAddrToNumber
; Called from: in-module: 0xF5E1E3 0xF5E212 0xF5E22B
; Touches: (0x0D2E) (0x126E)  |  0x617800
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5E2F0 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_CursorBlockAddrToNumber: (0x0D2E) = (BStore_CursorBlockAddr - 0x617800) / 256 + 1, the inverse of BStore_SetCursorBlockAddr; XHL = 0.
BStore_CursorBlockAddrToNumber:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E2F0  ld XHL,(0x126e)
	sub	xhl, 6387712	; F5E2F4  sub XHL,0x00617800
	srl	xhl, 8	; F5E2FA  srl 0x08,XHL
	inc	1, hl	; F5E2FD  inc 1,HL
	ld	(3374:16), hl	; F5E2FF  ld (0x0d2e),HL
	xor	xhl, xhl	; F5E303  xor XHL,XHL
	ret	; F5E305  ret

; --------------------------------------------------------------------------
; SongEdit_SortBeatAdvanceAnchor
; Called from: in-module: 0xF5E15E
; Touches: (0x0D20) (0x0D22) (0x0D24) (0x0D4A) (0x126E)
; Calls:   T_BStore_CursorAdvance
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5E306 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_SortBeatAdvanceAnchor: Moves the sort anchor ((0x0D22) offset / (0x0D24) block) past its event to the next
;   lead byte; on an event (not 0x81 / 0x82) stores the new anchor and (0x0D20) := its timing byte, at a mark leaves
;   the anchor. SongEdit_SortBeatEventsByTiming's step once a scan pass reaches the beat's end. Basis: caller + caller
;   header + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave8_a8.json)
SongEdit_SortBeatAdvanceAnchor:
	ld	iy, (3362:16)	; F5E306  ld IY,(0x0d22)
	push	xhl	; F5E30A  push XHL
	ld	xhl, (3364:16)	; F5E30B  ld XHL,(0x0d24)
	ld	(BStore_CursorBlockAddr:16), xhl	; F5E30F  ld (0x126e),XHL
	pop	xhl	; F5E313  pop XHL
	call	T_BStore_CursorAdvance	; F5E314  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F5E318  cp (0x0d4a),0x00
	jr	z, SongEdit_SortBeatAdvanceAnchor_Loop	; F5E31D  jr Z,0xf5e321
	jr	SongEdit_SortBeatAdvanceAnchor_Return	; F5E31F  jr T,0xf5e36f
SongEdit_SortBeatAdvanceAnchor_Loop:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E321  ld XHL,(0x126e)
	bit	7, (xhl+iy)	; F5E325  bit 7,(XHL+IY)
	jr	nz, SongEdit_SortBeatAdvanceAnchor_Skip	; F5E32A  jr NZ,0xf5e339
	call	T_BStore_CursorAdvance	; F5E32C  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F5E330  cp (0x0d4a),0x00
	jr	z, SongEdit_SortBeatAdvanceAnchor_Loop	; F5E335  jr Z,0xf5e321
	jr	SongEdit_SortBeatAdvanceAnchor_Return	; F5E337  jr T,0xf5e36f
SongEdit_SortBeatAdvanceAnchor_Skip:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E339  ld XHL,(0x126e)
	cp	(xhl+iy), 0x82	; F5E33D  cp (XHL+IY),0x82
	jr	z, SongEdit_SortBeatAdvanceAnchor_Return	; F5E343  jr Z,0xf5e36f
	cp	(xhl+iy), 0x81	; F5E345  cp (XHL+IY),0x81
	jr	z, SongEdit_SortBeatAdvanceAnchor_Return	; F5E34B  jr Z,0xf5e36f
	ld	(3362:16), iy	; F5E34D  ld (0x0d22),IY
	ld	(3364:16), xhl	; F5E351  ld (0x0d24),XHL
	call	T_BStore_CursorAdvance	; F5E355  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F5E359  cp (0x0d4a),0x00
	jr	z, SongEdit_SortBeatAdvanceAnchor_Skip2	; F5E35E  jr Z,0xf5e362
	jr	SongEdit_SortBeatAdvanceAnchor_Return	; F5E360  jr T,0xf5e36f
SongEdit_SortBeatAdvanceAnchor_Skip2:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E362  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F5E366  ld A,(XHL+IY)
	ld	(3360:16), a	; F5E36B  ld (0x0d20),A
SongEdit_SortBeatAdvanceAnchor_Return:
	ret	; F5E36F  ret

; --------------------------------------------------------------------------
; SongEdit_SortBeatAdvanceScan
; Called from: in-module: 0xF5E107 0xF5E142 0xF5E186
; Touches: (0x0D21) (0x0D28) (0x0D2A) (0x0D4A) (0x126E)
; Calls:   T_BStore_CursorAdvance
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5E370 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_SortBeatAdvanceScan: Moves the sort scan position ((0x0D28) offset / (0x0D2A) block) past its event to the
;   next lead byte; on an event (not 0x81 / 0x82) stores the new position and (0x0D21) := its timing byte, at a mark
;   leaves it. SongEdit_SortBeatEventsByTiming's scan over the later events of the beat. Basis: caller + caller header
;   + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave8_a8.json)
SongEdit_SortBeatAdvanceScan:
	ld	iy, (3368:16)	; F5E370  ld IY,(0x0d28)
	push	xhl	; F5E374  push XHL
	ld	xhl, (3370:16)	; F5E375  ld XHL,(0x0d2a)
	ld	(BStore_CursorBlockAddr:16), xhl	; F5E379  ld (0x126e),XHL
	pop	xhl	; F5E37D  pop XHL
	call	T_BStore_CursorAdvance	; F5E37E  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F5E382  cp (0x0d4a),0x00
	jr	z, SongEdit_SortBeatAdvanceScan_Loop	; F5E387  jr Z,0xf5e38b
	jr	SongEdit_SortBeatAdvanceScan_Return	; F5E389  jr T,0xf5e3d9
SongEdit_SortBeatAdvanceScan_Loop:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E38B  ld XHL,(0x126e)
	bit	7, (xhl+iy)	; F5E38F  bit 7,(XHL+IY)
	jr	nz, SongEdit_SortBeatAdvanceScan_Skip	; F5E394  jr NZ,0xf5e3a3
	call	T_BStore_CursorAdvance	; F5E396  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F5E39A  cp (0x0d4a),0x00
	jr	z, SongEdit_SortBeatAdvanceScan_Loop	; F5E39F  jr Z,0xf5e38b
	jr	SongEdit_SortBeatAdvanceAnchor_Return	; F5E3A1  jr T,0xf5e36f
SongEdit_SortBeatAdvanceScan_Skip:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E3A3  ld XHL,(0x126e)
	cp	(xhl+iy), 0x82	; F5E3A7  cp (XHL+IY),0x82
	jr	z, SongEdit_SortBeatAdvanceScan_Return	; F5E3AD  jr Z,0xf5e3d9
	cp	(xhl+iy), 0x81	; F5E3AF  cp (XHL+IY),0x81
	jr	z, SongEdit_SortBeatAdvanceScan_Return	; F5E3B5  jr Z,0xf5e3d9
	ld	(3368:16), iy	; F5E3B7  ld (0x0d28),IY
	ld	(3370:16), xhl	; F5E3BB  ld (0x0d2a),XHL
	call	T_BStore_CursorAdvance	; F5E3BF  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F5E3C3  cp (0x0d4a),0x00
	jr	z, SongEdit_SortBeatAdvanceScan_Skip2	; F5E3C8  jr Z,0xf5e3cc
	jr	SongEdit_SortBeatAdvanceScan_Return	; F5E3CA  jr T,0xf5e3d9
SongEdit_SortBeatAdvanceScan_Skip2:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E3CC  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F5E3D0  ld A,(XHL+IY)
	ld	(3361:16), a	; F5E3D5  ld (0x0d21),A
SongEdit_SortBeatAdvanceScan_Return:
	ret	; F5E3D9  ret

; --------------------------------------------------------------------------
; SongEdit_DeleteMeasures
; Called from: T_SongEdit_DeleteMeasures (x1)
; Touches: (0x0C70) (0x0C73) (0x0C77) (0x0C8A) (0x0C8E) (0x0CA2) (0x0CA3)
;          (0x0D18) (0x0D1D) (0x0D4A)  |  0x603422
; Calls:   T_BStore_LoadGeometry T_BStore_OpenChainAtSavedCursor T_SongEdit_SaveTimeSigOfDeletedMeasures SongEdit_DeleteMeasuresFromTrack T_SongEdit_ReinsertTimeSigAfterDelete T_SongEdit_CheckAllTracksToStartMeasure T_BStore_ErrorToStatusByte
;          T_F40A1C
; Evidence: thunk slot T_SongEdit_DeleteMeasures holds `jp 0x00F5E3DA`, and 0xF5E3DA is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_DeleteMeasures: The MEASURE DELETE job: track (0x0C70) (1..(0x0CA2), or 0x7F for every track), first
;   measure (0x0C73) and count (0x0C77), both 1..999, else error 3; per track SongEdit_DeleteMeasuresFromTrack removes the measures (with
;   the master-track handling via T_SongEdit_SaveTimeSigOfDeletedMeasures/T_SongEdit_ReinsertTimeSigAfterDelete); BStore_ErrorToStatusByte reports. Run by
;   MeasureDelete_LcdKeyRow3, which stages those fields. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_n.json)
SongEdit_DeleteMeasures:		; <- T_SongEdit_DeleteMeasures
	call	T_BStore_LoadGeometry	; F5E3DA  call 0xf427c4
	ld	a, (3184:16)	; F5E3DE  ld A,(0x0c70)
	cp	a, 1:i3	; F5E3E2  cp A,1
	jr	c, SongEdit_DeleteMeasures_Skip4	; F5E3E4  jr C,0xf5e40d
	cp	a, 127	; F5E3E6  cp A,0x7f
	jr	z, SongEdit_DeleteMeasures_Skip3	; F5E3E9  jr Z,0xf5e3f1
	cp	a, (0x0ca2:16)	; F5E3EB  cp A,(0x0ca2)
	jr	ugt, SongEdit_DeleteMeasures_Skip4	; F5E3EF  jr UGT,0xf5e40d
SongEdit_DeleteMeasures_Skip3:
	ld	wa, (3187:16)	; F5E3F1  ld WA,(0x0c73)
	cp	wa, 1:i3	; F5E3F5  cp WA,1
	jr	c, SongEdit_DeleteMeasures_Skip4	; F5E3F7  jr C,0xf5e40d
	cp	wa, 999	; F5E3F9  cp WA,0x03e7
	jr	ugt, SongEdit_DeleteMeasures_Skip4	; F5E3FD  jr UGT,0xf5e40d
	ld	wa, (3191:16)	; F5E3FF  ld WA,(0x0c77)
	cp	wa, 1:i3	; F5E403  cp WA,1
	jr	c, SongEdit_DeleteMeasures_Skip4	; F5E405  jr C,0xf5e40d
	cp	wa, 999	; F5E407  cp WA,0x03e7
	jr	ule, SongEdit_DeleteMeasures_Skip5	; F5E40B  jr ULE,0xf5e415
SongEdit_DeleteMeasures_Skip4:
	ld	(BStore_ErrorCode:16), 3	; F5E40D  ld (0x0d4a),0x03
	jrl	SongEdit_DeleteMeasures_Join4	; F5E412  jrl T,0xf5e567
SongEdit_DeleteMeasures_Skip5:
	ld	(BStore_ErrorCode:16), 0	; F5E415  ld (0x0d4a),0x00
	and	(0x0c8a:16), 0xbf	; F5E41A  and (0x0c8a),0xbf
	cp	(0x0c70:16), 0x7f	; F5E41F  cp (0x0c70),0x7f
	jr	nz, SongEdit_DeleteMeasures_Skip6	; F5E424  jr NZ,0xf5e429
	jrl	SongEdit_DeleteMeasures_Join	; F5E426  jrl T,0xf5e49d
SongEdit_DeleteMeasures_Skip6:
	xor	hl, hl	; F5E429  xor HL,HL
	ld	l, (3184:16)	; F5E42B  ld L,(0x0c70)
	dec	1, l	; F5E42F  dec 1,L
	push	xix	; F5E431  push XIX
	ld	xix, BStore_TrackToPart	; F5E432  ld XIX,0x00603422
	ld	a, (xix+hl)	; F5E437  ld A,(XIX+HL)
	pop	xix	; F5E43C  pop XIX
	cp	a, 32	; F5E43D  cp A,0x20
	jr	nz, SongEdit_DeleteMeasures_Skip7	; F5E440  jr NZ,0xf5e459
	or	(0x0c8a:16), 0x40	; F5E442  or (0x0c8a),0x40
	ld	a, (3184:16)	; F5E447  ld A,(0x0c70)
	call	T_BStore_OpenChainAtSavedCursor	; F5E44B  call 0xf42790
	cp	(BStore_ErrorCode:16), 0x00	; F5E44F  cp (0x0d4a),0x00
	jr	z, SongEdit_DeleteMeasures_Skip7	; F5E454  jr Z,0xf5e459
	jrl	SongEdit_DeleteMeasures_Join4	; F5E456  jrl T,0xf5e567
SongEdit_DeleteMeasures_Skip7:
	ld	a, (3184:16)	; F5E459  ld A,(0x0c70)
	ld	(3214:16), a	; F5E45D  ld (0x0c8e),A
	bit	6, (0x0c8a:16)	; F5E461  bit 6,(0x0c8a)
	jr	z, SongEdit_DeleteMeasures_Skip8	; F5E465  jr Z,0xf5e480
	xor	hl, hl	; F5E467  xor HL,HL
	ld	l, a	; F5E469  ld L,A
	dec	1, hl	; F5E46B  dec 1,HL
	push	xix	; F5E46D  push XIX
	ld	xix, BStore_TrackToPart	; F5E46E  ld XIX,0x00603422
	cp	(xix+hl), 0x20	; F5E473  cp (XIX+HL),0x20
	pop	xix	; F5E479  pop XIX
	jr	nz, SongEdit_DeleteMeasures_Skip8	; F5E47A  jr NZ,0xf5e480
	call	T_SongEdit_SaveTimeSigOfDeletedMeasures	; F5E47C  call 0xf432c0
SongEdit_DeleteMeasures_Skip8:
	calr	SongEdit_DeleteMeasuresFromTrack	; F5E480  calr 0xf5e570
	cp	(BStore_ErrorCode:16), 0x00	; F5E483  cp (0x0d4a),0x00
	jrl	nz, SongEdit_DeleteMeasures_Join4	; F5E488  jrl NZ,0xf5e567
	ld	a, (3214:16)	; F5E48B  ld A,(0x0c8e)
	cp	a, (0x0d1d:16)	; F5E48F  cp A,(0x0d1d)
	jrl	nz, SongEdit_DeleteMeasures_Join4	; F5E493  jrl NZ,0xf5e567
	call	T_SongEdit_ReinsertTimeSigAfterDelete	; F5E496  call 0xf432cc
	jrl	SongEdit_DeleteMeasures_Join4	; F5E49A  jrl T,0xf5e567
SongEdit_DeleteMeasures_Join:
	xor	xhl, xhl	; F5E49D  xor XHL,XHL
SongEdit_DeleteMeasures_Join2:
	cp	l, (0x0ca3:16)	; F5E49F  cp L,(0x0ca3)
	jr	ugt, SongEdit_DeleteMeasures_Skip10	; F5E4A3  jr UGT,0xf5e4d3
	push	xix	; F5E4A5  push XIX
	ld	xix, BStore_TrackToPart	; F5E4A6  ld XIX,0x00603422
	ld	a, (xix+hl)	; F5E4AB  ld A,(XIX+HL)
	pop	xix	; F5E4B0  pop XIX
	cp	a, 32	; F5E4B1  cp A,0x20
	jr	nz, SongEdit_DeleteMeasures_Skip9	; F5E4B4  jr NZ,0xf5e4cf
	or	(0x0c8a:16), 0x40	; F5E4B6  or (0x0c8a),0x40
	push	xhl	; F5E4BB  push XHL
	ld	wa, hl	; F5E4BC  ld WA,HL
	inc	1, wa	; F5E4BE  inc 1,WA
	call	T_BStore_OpenChainAtSavedCursor	; F5E4C0  call 0xf42790
	pop	xhl	; F5E4C4  pop XHL
	cp	(BStore_ErrorCode:16), 0x00	; F5E4C5  cp (0x0d4a),0x00
	jr	z, SongEdit_DeleteMeasures_Skip9	; F5E4CA  jr Z,0xf5e4cf
	jrl	SongEdit_DeleteMeasures_Join4	; F5E4CC  jrl T,0xf5e567
SongEdit_DeleteMeasures_Skip9:
	inc	1, hl	; F5E4CF  inc 1,HL
	jr	SongEdit_DeleteMeasures_Join2	; F5E4D1  jr T,0xf5e49f
SongEdit_DeleteMeasures_Skip10:
	call	T_SongEdit_CheckAllTracksToStartMeasure	; F5E4D3  call 0xf427d0
	cp	(BStore_ErrorCode:16), 0x00	; F5E4D7  cp (0x0d4a),0x00
	jr	z, SongEdit_DeleteMeasures_Skip11	; F5E4DC  jr Z,0xf5e4e1
	jrl	SongEdit_DeleteMeasures_Join4	; F5E4DE  jrl T,0xf5e567
SongEdit_DeleteMeasures_Skip11:
	ld	a, 1:opc	; F5E4E1  ld A,0x01
	ld	(3352:16), 0	; F5E4E3  ld (0x0d18),0x00
SongEdit_DeleteMeasures_Join3:
	cp	a, (0x0ca2:16)	; F5E4E8  cp A,(0x0ca2)
	jrl	ugt, SongEdit_DeleteMeasures_Skip15	; F5E4EC  jrl UGT,0xf5e55f
	ld	(3214:16), a	; F5E4EF  ld (0x0c8e),A
	bit	6, (0x0c8a:16)	; F5E4F3  bit 6,(0x0c8a)
	jr	z, SongEdit_DeleteMeasures_Skip12	; F5E4F7  jr Z,0xf5e519
	xor	hl, hl	; F5E4F9  xor HL,HL
	ld	l, a	; F5E4FB  ld L,A
	dec	1, hl	; F5E4FD  dec 1,HL
	push	xix	; F5E4FF  push XIX
	ld	xix, BStore_TrackToPart	; F5E500  ld XIX,0x00603422
	cp	(xix+hl), 0x20	; F5E505  cp (XIX+HL),0x20
	pop	xix	; F5E50B  pop XIX
	jr	nz, SongEdit_DeleteMeasures_Skip12	; F5E50C  jr NZ,0xf5e519
	pushw	wa	; F5E50E  push WA
	ld	(BStore_ErrorCode:16), 0	; F5E50F  ld (0x0d4a),0x00
	call	T_SongEdit_SaveTimeSigOfDeletedMeasures	; F5E514  call 0xf432c0
	popw	wa	; F5E518  pop WA
SongEdit_DeleteMeasures_Skip12:
	pushw	wa	; F5E519  push WA
	calr	SongEdit_DeleteMeasuresFromTrack	; F5E51A  calr 0xf5e570
	popw	wa	; F5E51D  pop WA
	cp	(BStore_ErrorCode:16), 0x00	; F5E51E  cp (0x0d4a),0x00
	jr	nz, SongEdit_DeleteMeasures_Skip13	; F5E523  jr NZ,0xf5e53e
	bit	6, (0x0c8a:16)	; F5E525  bit 6,(0x0c8a)
	jr	z, SongEdit_DeleteMeasures_Skip14	; F5E529  jr Z,0xf5e55b
	cp	a, (0x0d1d:16)	; F5E52B  cp A,(0x0d1d)
	jr	nz, SongEdit_DeleteMeasures_Skip14	; F5E52F  jr NZ,0xf5e55b
	pushw	wa	; F5E531  push WA
	call	T_SongEdit_ReinsertTimeSigAfterDelete	; F5E532  call 0xf432cc
	popw	wa	; F5E536  pop WA
	cp	(BStore_ErrorCode:16), 0x00	; F5E537  cp (0x0d4a),0x00
	jr	z, SongEdit_DeleteMeasures_Skip14	; F5E53C  jr Z,0xf5e55b
SongEdit_DeleteMeasures_Skip13:
	cp	(BStore_ErrorCode:16), 0x01	; F5E53E  cp (0x0d4a),0x01
	jr	z, SongEdit_DeleteMeasures_Skip14	; F5E543  jr Z,0xf5e55b
	cp	(BStore_ErrorCode:16), 0x08	; F5E545  cp (0x0d4a),0x08
	jr	z, SongEdit_DeleteMeasures_Skip14	; F5E54A  jr Z,0xf5e55b
	cp	(0x0d18:16), 0x00	; F5E54C  cp (0x0d18),0x00
	jr	nz, SongEdit_DeleteMeasures_Skip14	; F5E551  jr NZ,0xf5e55b
	ld	l, (BStore_ErrorCode:16)	; F5E553  ld L,(0x0d4a)
	ld	(3352:16), l	; F5E557  ld (0x0d18),L
SongEdit_DeleteMeasures_Skip14:
	inc	1, a	; F5E55B  inc 1,A
	jr	SongEdit_DeleteMeasures_Join3	; F5E55D  jr T,0xf5e4e8
SongEdit_DeleteMeasures_Skip15:
	ld	a, (3352:16)	; F5E55F  ld A,(0x0d18)
	ld	(BStore_ErrorCode:16), a	; F5E563  ld (0x0d4a),A
SongEdit_DeleteMeasures_Join4:
	call	T_BStore_ErrorToStatusByte	; F5E567  call 0xf4278c
	call	T_F40A1C	; F5E56B  call 0xf40a1c
	ret	; F5E56F  ret

; --------------------------------------------------------------------------
; SongEdit_DeleteMeasuresFromTrack
; Called from: in-module: 0xF5E480 0xF5E51A
; Touches: (0x0C57) (0x0C5D) (0x0C61) (0x0C67) (0x0C6B) (0x0C70) (0x0C73)
;          (0x0C77) (0x0C8E) (0x0C90) +13 more
; Calls:   T_BStore_ValidateSavedCursor T_Seq_FindMasterTrack T_BStore_SeekMeasure SongEdit_ClearTrack T_F42798 T_BStore_CursorAdvance T_F42778
;          T_BStore_SeekBlock T_BStore_SaveCursor T_BStore_TruncateChainAfterBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5E570 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_DeleteMeasuresFromTrack: MEASURE DELETE on track (0x0C8E): seeks measure (0x0C73) and measure
;   (0x0C73)+(0x0C77), moves the rest of the chain down over the gap (T_F42778, sub_F62DC9), saves the cursor and
;   truncates the chain; deleting from measure 1 to the end instead clears the whole track (SongEdit_ClearTrack) and its bit in
;   (0x360C)/(0x360E). Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
SongEdit_DeleteMeasuresFromTrack:
	ld	(BStore_ErrorCode:16), 0	; F5E570  ld (0x0d4a),0x00
	xor	wa, wa	; F5E575  xor WA,WA
	ld	a, (3214:16)	; F5E577  ld A,(0x0c8e)
	ld	(3354:16), wa	; F5E57B  ld (0x0d1a),WA
	call	T_BStore_ValidateSavedCursor	; F5E57F  call 0xf42770
	cp	(BStore_ErrorCode:16), 0x00	; F5E583  cp (0x0d4a),0x00
	jr	z, SongEdit_DeleteMeasuresFromTrack_Skip	; F5E588  jr Z,0xf5e58d
	jrl	sub_F5E570_Return	; F5E58A  jrl T,0xf5e707
SongEdit_DeleteMeasuresFromTrack_Skip:
	ld	(3278:16), iy	; F5E58D  ld (0x0cce),IY
	ld	wa, (BStore_CursorBlock:16)	; F5E591  ld WA,(0x345c)
	ld	(3276:16), wa	; F5E595  ld (0x0ccc),WA
	call	T_Seq_FindMasterTrack	; F5E599  call 0xf427a0
	ld	a, (3214:16)	; F5E59D  ld A,(0x0c8e)
	ld	de, (3187:16)	; F5E5A1  ld DE,(0x0c73)
	ld	(3216:16), de	; F5E5A5  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F5E5A9  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F5E5AD  cp (0x0d4a),0x00
	jr	z, SongEdit_DeleteMeasuresFromTrack_Skip2	; F5E5B2  jr Z,0xf5e5b7
	jrl	sub_F5E570_Return	; F5E5B4  jrl T,0xf5e707
SongEdit_DeleteMeasuresFromTrack_Skip2:
	ld	(3258:16), iy	; F5E5B7  ld (0x0cba),IY
	ld	wa, (BStore_CursorBlock:16)	; F5E5BB  ld WA,(0x345c)
	ld	(3252:16), wa	; F5E5BF  ld (0x0cb4),WA
	ld	wa, (3187:16)	; F5E5C3  ld WA,(0x0c73)
	cp	wa, 1:i3	; F5E5C7  cp WA,1
	jr	nz, sub_F5E570_Join	; F5E5C9  jr NZ,0xf5e645
	add	wa, (0x0c77:16)	; F5E5CB  add WA,(0x0c77)
	ld	(3216:16), wa	; F5E5CF  ld (0x0c90),WA
	ld	a, (3214:16)	; F5E5D3  ld A,(0x0c8e)
	ld	w, (3357:16)	; F5E5D7  ld W,(0x0d1d)
	call	T_BStore_SeekMeasure	; F5E5DB  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F5E5DF  cp (0x0d4a),0x00
	jr	nz, SongEdit_DeleteMeasuresFromTrack_Skip3	; F5E5E4  jr NZ,0xf5e5f4
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E5E6  ld XHL,(0x126e)
	cp	(xhl+iy), 0x82	; F5E5EA  cp (XHL+IY),0x82
	jr	z, SongEdit_DeleteMeasuresFromTrack_Skip4	; F5E5F0  jr Z,0xf5e601
	jr	sub_F5E570_Join	; F5E5F2  jr T,0xf5e645
SongEdit_DeleteMeasuresFromTrack_Skip3:
	cp	(BStore_ErrorCode:16), 0x08	; F5E5F4  cp (0x0d4a),0x08
	jrl	nz, sub_F5E570_Return	; F5E5F9  jrl NZ,0xf5e707
	ld	(BStore_ErrorCode:16), 0	; F5E5FC  ld (0x0d4a),0x00
SongEdit_DeleteMeasuresFromTrack_Skip4:
	ld	a, (3214:16)	; F5E601  ld A,(0x0c8e)
	ld	(3184:16), a	; F5E605  ld (0x0c70),A
	calr	SongEdit_ClearTrack	; F5E609  calr 0xf6079e
	ld	c, (3184:16)	; F5E60C  ld C,(0x0c70)
	dec	1, c	; F5E610  dec 1,C
	ldfr_berp	a, 0x3c	; F5E612  ld RL3,A
	ldfr_werp	de, 0x3e	; F5E615  ld QHL3,DE
	ld	de, (13836:16)	; F5E618  ld DE,(0x360c)
	ld	a, c	; F5E61C  ld A,C
	cp	a, 16	; F5E61E  cp A,0x10
	jr	lt, SongEdit_DeleteMeasuresFromTrack_Skip5	; F5E621  jr LT,0xf5e62a
	ld	de, (13838:16)	; F5E623  ld DE,(0x360e)
	sub	a, 16	; F5E627  sub A,0x10
SongEdit_DeleteMeasuresFromTrack_Skip5:
	rcf	; F5E62A  rcf
	stcf_a_16	de	; F5E62B  stcf A,DE
	ldto_berp	a, 0x3c	; F5E62D  ld A,RL3
	cp	c, 16	; F5E630  cp C,0x10
	jr	lt, SongEdit_DeleteMeasuresFromTrack_Skip6	; F5E633  jr LT,0xf5e63b
	ld	(13838:16), de	; F5E635  ld (0x360e),DE
	jr	sub_F5E570_Entry	; F5E639  jr T,0xf5e63f
SongEdit_DeleteMeasuresFromTrack_Skip6:
	ld	(13836:16), de	; F5E63B  ld (0x360c),DE
sub_F5E570_Entry:
	ldto_werp	de, 0x3e	; F5E63F  ld DE,QHL3
	jrl	sub_F5E570_Return	; F5E642  jrl T,0xf5e707
sub_F5E570_Join:
	ld	w, (3357:16)	; F5E645  ld W,(0x0d1d)
	ld	a, (3214:16)	; F5E649  ld A,(0x0c8e)
	ld	de, (3187:16)	; F5E64D  ld DE,(0x0c73)
	ld	(3216:16), de	; F5E651  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F5E655  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F5E659  cp (0x0d4a),0x00
	jr	z, sub_F5E570_Skip7	; F5E65E  jr Z,0xf5e663
	jrl	sub_F5E570_Return	; F5E660  jrl T,0xf5e707
sub_F5E570_Skip7:
	ld	wa, (3252:16)	; F5E663  ld WA,(0x0cb4)
	ld	hl, wa	; F5E667  ld HL,WA
	ld	iy, (3258:16)	; F5E669  ld IY,(0x0cba)
	call	T_F42798	; F5E66D  call 0xf42798
	cp	(BStore_ErrorCode:16), 0x00	; F5E671  cp (0x0d4a),0x00
	jr	z, sub_F5E570_Skip8	; F5E676  jr Z,0xf5e682
	cp	(BStore_ErrorCode:16), 0x07	; F5E678  cp (0x0d4a),0x07
	jr	z, sub_F5E570_Skip9	; F5E67D  jr Z,0xf5e690
	jrl	sub_F5E570_Return	; F5E67F  jrl T,0xf5e707
sub_F5E570_Skip8:
	call	T_BStore_CursorAdvance	; F5E682  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F5E686  cp (0x0d4a),0x00
	jr	z, sub_F5E570_Skip9	; F5E68B  jr Z,0xf5e690
	jrl	sub_F5E570_Return	; F5E68D  jrl T,0xf5e707
sub_F5E570_Skip9:
	ld	(BStore_ErrorCode:16), 0	; F5E690  ld (0x0d4a),0x00
	ld	(3262:16), iy	; F5E695  ld (0x0cbe),IY
	ld	wa, (BStore_CursorBlock:16)	; F5E699  ld WA,(0x345c)
	ld	(3260:16), wa	; F5E69D  ld (0x0cbc),WA
	ld	wa, (3260:16)	; F5E6A1  ld WA,(0x0cbc)
	ld	(3169:16), wa	; F5E6A5  ld (0x0c61),WA
	ld	wa, (3262:16)	; F5E6A9  ld WA,(0x0cbe)
	ld	(3175:16), wa	; F5E6AD  ld (0x0c67),WA
	ld	wa, (3252:16)	; F5E6B1  ld WA,(0x0cb4)
	ld	(3159:16), wa	; F5E6B5  ld (0x0c57),WA
	ld	wa, (3258:16)	; F5E6B9  ld WA,(0x0cba)
	ld	(3165:16), wa	; F5E6BD  ld (0x0c5d),WA
	ld	de, (3276:16)	; F5E6C1  ld DE,(0x0ccc)
	ld	wa, (3278:16)	; F5E6C5  ld WA,(0x0cce)
	ld	(3179:16), wa	; F5E6C9  ld (0x0c6b),WA
	call	T_F42778	; F5E6CD  call 0xf42778
	cp	(BStore_ErrorCode:16), 0x00	; F5E6D1  cp (0x0d4a),0x00
	jr	nz, sub_F5E570_Return	; F5E6D6  jr NZ,0xf5e707
	cp	ix, 5:i3	; F5E6D8  cp IX,5
	jr	nz, sub_F5E570_Skip10	; F5E6DA  jr NZ,0xf5e6f8
	ld	hl, (3159:16)	; F5E6DC  ld HL,(0x0c57)
	call	T_BStore_SeekBlock	; F5E6E0  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E6E4  ld XHL,(0x126e)
	ld	hl, (xhl+1)	; F5E6E8  ld HL,(XHL+0x01)
	cp	hl, 0:i3	; F5E6EB  cp HL,0
	jr	z, sub_F5E570_Return	; F5E6ED  jr Z,0xf5e707
	ld	(3159:16), hl	; F5E6EF  ld (0x0c57),HL
	ldw	ix, 255	; F5E6F3  ld IX,0x00ff
	jr	sub_F5E570_Join2	; F5E6F6  jr T,0xf5e6fa
sub_F5E570_Skip10:
	dec	1, ix	; F5E6F8  dec 1,IX
sub_F5E570_Join2:
	call	T_BStore_SaveCursor	; F5E6FA  call 0xf427b0
	call	T_BStore_TruncateChainAfterBlock	; F5E6FE  call 0xf42794
	cp	(BStore_ErrorCode:16), 0x00	; F5E702  cp (0x0d4a),0x00
sub_F5E570_Return:
	ret	; F5E707  ret

; --------------------------------------------------------------------------
; MeasureErase_Execute
; Called from: T_MeasureErase_Execute (x1)
; Touches: (0x0C70) (0x0C73) (0x0C77) (0x0C79) (0x0C8A) (0x0C8E) (0x0CA2)
;          (0x0CA3) (0x0D18) (0x0D4A)  |  0x603422
; Calls:   T_BStore_LoadGeometry T_BStore_OpenChainAtSavedCursor MeasureErase_EraseTrack T_SongEdit_CheckAllTracksToStartMeasure T_BStore_ErrorToStatusByte T_F40A1C
; Evidence: thunk slot T_MeasureErase_Execute holds `jp 0x00F5E708`, and 0xF5E708 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureErase_Execute: Runs MEASURE ERASE with the fields MeasureErase_LcdKeyRow2 staged: track (0x0C70) 1..(0x0CA2)
;   or 0x7F = all, first measure (0x0C73) and count (0x0C77) 1..999, erase data (0x0C79) 0..2 -- else error 3; then
;   the per-track erase MeasureErase_EraseTrack for that track or for every track (the master track's chain, BStore_TrackToPart
;   0x20, opened at its saved cursor), keeping the first error in (0x0D18); ends with T_BStore_ErrorToStatusByte (the
;   UI status the caller tests) and T_F40A1C. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_k.json)
MeasureErase_Execute:		; <- T_MeasureErase_Execute
	call	T_BStore_LoadGeometry	; F5E708  call 0xf427c4
	ld	a, (3184:16)	; F5E70C  ld A,(0x0c70)
	cp	a, 1:i3	; F5E710  cp A,1
	jr	c, MeasureErase_Execute_Skip12	; F5E712  jr C,0xf5e74b
	cp	a, 127	; F5E714  cp A,0x7f
	jr	z, MeasureErase_Execute_Skip11	; F5E717  jr Z,0xf5e71f
	cp	a, (0x0ca2:16)	; F5E719  cp A,(0x0ca2)
	jr	ugt, MeasureErase_Execute_Skip12	; F5E71D  jr UGT,0xf5e74b
MeasureErase_Execute_Skip11:
	ld	wa, (3187:16)	; F5E71F  ld WA,(0x0c73)
	cp	wa, 1:i3	; F5E723  cp WA,1
	jr	c, MeasureErase_Execute_Skip12	; F5E725  jr C,0xf5e74b
	cp	wa, 999	; F5E727  cp WA,0x03e7
	jr	ugt, MeasureErase_Execute_Skip12	; F5E72B  jr UGT,0xf5e74b
	ld	wa, (3191:16)	; F5E72D  ld WA,(0x0c77)
	cp	wa, 1:i3	; F5E731  cp WA,1
	jr	c, MeasureErase_Execute_Skip12	; F5E733  jr C,0xf5e74b
	cp	wa, 999	; F5E735  cp WA,0x03e7
	jr	ugt, MeasureErase_Execute_Skip12	; F5E739  jr UGT,0xf5e74b
	ld	a, (3193:16)	; F5E73B  ld A,(0x0c79)
	cp	a, 0:i3	; F5E73F  cp A,0
	jr	z, MeasureErase_Execute_Skip13	; F5E741  jr Z,0xf5e753
	cp	a, 1:i3	; F5E743  cp A,1
	jr	z, MeasureErase_Execute_Skip13	; F5E745  jr Z,0xf5e753
	cp	a, 2:i3	; F5E747  cp A,2
	jr	z, MeasureErase_Execute_Skip13	; F5E749  jr Z,0xf5e753
MeasureErase_Execute_Skip12:
	ld	(BStore_ErrorCode:16), 3	; F5E74B  ld (0x0d4a),0x03
	jrl	MeasureErase_Execute_Join6	; F5E750  jrl T,0xf5e831
MeasureErase_Execute_Skip13:
	ld	(BStore_ErrorCode:16), 0	; F5E753  ld (0x0d4a),0x00
	and	(0x0c8a:16), 0xbf	; F5E758  and (0x0c8a),0xbf
	cp	(0x0c70:16), 0x7f	; F5E75D  cp (0x0c70),0x7f
	jr	nz, MeasureErase_Execute_Skip14	; F5E762  jr NZ,0xf5e766
	jr	MeasureErase_Execute_Join3	; F5E764  jr T,0xf5e7a9
MeasureErase_Execute_Skip14:
	xor	xhl, xhl	; F5E766  xor XHL,XHL
	ld	l, (3184:16)	; F5E768  ld L,(0x0c70)
	dec	1, l	; F5E76C  dec 1,L
	push	xix	; F5E76E  push XIX
	ld	xix, BStore_TrackToPart	; F5E76F  ld XIX,0x00603422
	ld	a, (xix+hl)	; F5E774  ld A,(XIX+HL)
	pop	xix	; F5E779  pop XIX
	cp	a, 32	; F5E77A  cp A,0x20
	jr	nz, MeasureErase_Execute_Skip15	; F5E77D  jr NZ,0xf5e796
	or	(0x0c8a:16), 0x40	; F5E77F  or (0x0c8a),0x40
	ld	a, (3184:16)	; F5E784  ld A,(0x0c70)
	call	T_BStore_OpenChainAtSavedCursor	; F5E788  call 0xf42790
	cp	(BStore_ErrorCode:16), 0x00	; F5E78C  cp (0x0d4a),0x00
	jr	z, MeasureErase_Execute_Skip15	; F5E791  jr Z,0xf5e796
	jrl	MeasureErase_Execute_Join6	; F5E793  jrl T,0xf5e831
MeasureErase_Execute_Skip15:
	ld	a, (3184:16)	; F5E796  ld A,(0x0c70)
	ld	(3214:16), a	; F5E79A  ld (0x0c8e),A
	calr	MeasureErase_EraseTrack	; F5E79E  calr 0xf5e83a
	cp	(BStore_ErrorCode:16), 0x00	; F5E7A1  cp (0x0d4a),0x00
	jrl	MeasureErase_Execute_Join6	; F5E7A6  jrl T,0xf5e831
MeasureErase_Execute_Join3:
	xor	hl, hl	; F5E7A9  xor HL,HL
MeasureErase_Execute_Join4:
	cp	l, (0x0ca3:16)	; F5E7AB  cp L,(0x0ca3)
	jr	ugt, MeasureErase_Execute_Skip17	; F5E7AF  jr UGT,0xf5e7de
	push	xix	; F5E7B1  push XIX
	ld	xix, BStore_TrackToPart	; F5E7B2  ld XIX,0x00603422
	ld	a, (xix+hl)	; F5E7B7  ld A,(XIX+HL)
	pop	xix	; F5E7BC  pop XIX
	cp	a, 32	; F5E7BD  cp A,0x20
	jr	nz, MeasureErase_Execute_Skip16	; F5E7C0  jr NZ,0xf5e7da
	or	(0x0c8a:16), 0x40	; F5E7C2  or (0x0c8a),0x40
	pushw	hl	; F5E7C7  push HL
	ld	wa, hl	; F5E7C8  ld WA,HL
	inc	1, wa	; F5E7CA  inc 1,WA
	call	T_BStore_OpenChainAtSavedCursor	; F5E7CC  call 0xf42790
	popw	hl	; F5E7D0  pop HL
	cp	(BStore_ErrorCode:16), 0x00	; F5E7D1  cp (0x0d4a),0x00
	jr	z, MeasureErase_Execute_Skip16	; F5E7D6  jr Z,0xf5e7da
	jr	MeasureErase_Execute_Join6	; F5E7D8  jr T,0xf5e831
MeasureErase_Execute_Skip16:
	inc	1, hl	; F5E7DA  inc 1,HL
	jr	MeasureErase_Execute_Join4	; F5E7DC  jr T,0xf5e7ab
MeasureErase_Execute_Skip17:
	call	T_SongEdit_CheckAllTracksToStartMeasure	; F5E7DE  call 0xf427d0
	cp	(BStore_ErrorCode:16), 0x00	; F5E7E2  cp (0x0d4a),0x00
	jr	z, MeasureErase_Execute_Skip18	; F5E7E7  jr Z,0xf5e7eb
	jr	MeasureErase_Execute_Join6	; F5E7E9  jr T,0xf5e831
MeasureErase_Execute_Skip18:
	ld	(3352:16), 0	; F5E7EB  ld (0x0d18),0x00
	ld	a, 1:opc	; F5E7F0  ld A,0x01
MeasureErase_Execute_Join5:
	cp	a, (0x0ca2:16)	; F5E7F2  cp A,(0x0ca2)
	jr	ugt, MeasureErase_Execute_Skip20	; F5E7F6  jr UGT,0xf5e829
	ld	(3214:16), a	; F5E7F8  ld (0x0c8e),A
	pushw	wa	; F5E7FC  push WA
	calr	MeasureErase_EraseTrack	; F5E7FD  calr 0xf5e83a
	popw	wa	; F5E800  pop WA
	cp	(BStore_ErrorCode:16), 0x00	; F5E801  cp (0x0d4a),0x00
	jr	z, MeasureErase_Execute_Skip19	; F5E806  jr Z,0xf5e825
	cp	(BStore_ErrorCode:16), 0x01	; F5E808  cp (0x0d4a),0x01
	jr	z, MeasureErase_Execute_Skip19	; F5E80D  jr Z,0xf5e825
	cp	(BStore_ErrorCode:16), 0x08	; F5E80F  cp (0x0d4a),0x08
	jr	z, MeasureErase_Execute_Skip19	; F5E814  jr Z,0xf5e825
	cp	(0x0d18:16), 0x00	; F5E816  cp (0x0d18),0x00
	jr	nz, MeasureErase_Execute_Skip19	; F5E81B  jr NZ,0xf5e825
	ld	l, (BStore_ErrorCode:16)	; F5E81D  ld L,(0x0d4a)
	ld	(3352:16), l	; F5E821  ld (0x0d18),L
MeasureErase_Execute_Skip19:
	inc	1, a	; F5E825  inc 1,A
	jr	MeasureErase_Execute_Join5	; F5E827  jr T,0xf5e7f2
MeasureErase_Execute_Skip20:
	ld	a, (3352:16)	; F5E829  ld A,(0x0d18)
	ld	(BStore_ErrorCode:16), a	; F5E82D  ld (0x0d4a),A
MeasureErase_Execute_Join6:
	call	T_BStore_ErrorToStatusByte	; F5E831  call 0xf4278c
	call	T_F40A1C	; F5E835  call 0xf40a1c
	ret	; F5E839  ret

; --------------------------------------------------------------------------
; MeasureErase_EraseTrack
; Called from: in-module: 0xF5E79E 0xF5E7FD
; Touches: (0x0C57) (0x0C5D) (0x0C61) (0x0C67) (0x0C6B) (0x0C73) (0x0C77)
;          (0x0C79) (0x0C8E) (0x0C90) +13 more
; Calls:   T_BStore_ValidateSavedCursor T_Seq_FindMasterTrack T_BStore_SeekMeasure BStore_WriteCursorAdvance BStore_ReadCursorAdvance T_F427A8
;          T_F42778 T_BStore_SeekBlock T_BStore_SaveCursor T_BStore_TruncateChainAfterBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5E83A is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureErase_EraseTrack: MEASURE ERASE on track (0x0C8E): compacts measures (0x0C73)..+(0x0C77) in place keeping the
;   0x81 beat marks; ERASE DATA (0x0C79) 0 drops every other event, 1 drops only 0x9n events, 2 keeps only 0x9n events
;   (the master track also keeps its 0x87 records in 0 and 2); then closes the gap (T_F42778), saves the cursor and
;   truncates. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
MeasureErase_EraseTrack:
	ld	(BStore_ErrorCode:16), 0	; F5E83A  ld (0x0d4a),0x00
	xor	wa, wa	; F5E83F  xor WA,WA
	ld	a, (3214:16)	; F5E841  ld A,(0x0c8e)
	ld	(3354:16), wa	; F5E845  ld (0x0d1a),WA
	call	T_BStore_ValidateSavedCursor	; F5E849  call 0xf42770
	cp	(BStore_ErrorCode:16), 0x00	; F5E84D  cp (0x0d4a),0x00
	jr	z, MeasureErase_EraseTrack_Skip	; F5E852  jr Z,0xf5e857
	jrl	MeasureErase_EraseTrack_Return	; F5E854  jrl T,0xf5eb9b
MeasureErase_EraseTrack_Skip:
	ld	(3278:16), iy	; F5E857  ld (0x0cce),IY
	ld	wa, (BStore_CursorBlock:16)	; F5E85B  ld WA,(0x345c)
	ld	(3276:16), wa	; F5E85F  ld (0x0ccc),WA
	call	T_Seq_FindMasterTrack	; F5E863  call 0xf427a0
	ld	a, (3214:16)	; F5E867  ld A,(0x0c8e)
	ld	de, (3187:16)	; F5E86B  ld DE,(0x0c73)
	ld	(3216:16), de	; F5E86F  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F5E873  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F5E877  cp (0x0d4a),0x00
	jr	z, MeasureErase_EraseTrack_Skip2	; F5E87C  jr Z,0xf5e881
	jrl	MeasureErase_EraseTrack_Return	; F5E87E  jrl T,0xf5eb9b
MeasureErase_EraseTrack_Skip2:
	push	xhl	; F5E881  push XHL
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E882  ld XHL,(0x126e)
	ld	(3254:16), xhl	; F5E886  ld (0x0cb6),XHL
	pop	xhl	; F5E88A  pop XHL
	ld	(3258:16), iy	; F5E88B  ld (0x0cba),IY
	ld	wa, (BStore_CursorBlock:16)	; F5E88F  ld WA,(0x345c)
	ld	(3252:16), wa	; F5E893  ld (0x0cb4),WA
	ld	(3262:16), iy	; F5E897  ld (0x0cbe),IY
	ld	(3260:16), wa	; F5E89B  ld (0x0cbc),WA
	ld	ix, iy	; F5E89F  ld IX,IY
	cp	(0x0c79:16), 0x00	; F5E8A1  cp (0x0c79),0x00
	jr	nz, MeasureErase_EraseTrack_Skip3	; F5E8A6  jr NZ,0xf5e8aa
	jr	MeasureErase_EraseTrack_Join	; F5E8A8  jr T,0xf5e8b7
MeasureErase_EraseTrack_Skip3:
	cp	(0x0c79:16), 0x01	; F5E8AA  cp (0x0c79),0x01
	jr	nz, MeasureErase_EraseTrack_Skip4	; F5E8AF  jr NZ,0xf5e8b4
	jrl	MeasureErase_EraseTrack_Join6	; F5E8B1  jrl T,0xf5e985
MeasureErase_EraseTrack_Skip4:
	jrl	MeasureErase_EraseTrack_Join11	; F5E8B4  jrl T,0xf5ea4c
MeasureErase_EraseTrack_Join:
	xor	de, de	; F5E8B7  xor DE,DE
MeasureErase_EraseTrack_Join2:
	cp	de, (0x0c77:16)	; F5E8B9  cp DE,(0x0c77)
	jr	nz, MeasureErase_EraseTrack_Skip5	; F5E8BD  jr NZ,0xf5e8c2
	jrl	MeasureErase_EraseTrack_Join16	; F5E8BF  jrl T,0xf5eb2d
MeasureErase_EraseTrack_Skip5:
	xor	c, c	; F5E8C2  xor C,C
MeasureErase_EraseTrack_Join3:
	cp	c, (0x0d1c:16)	; F5E8C4  cp C,(0x0d1c)
	jr	nz, MeasureErase_EraseTrack_Loop	; F5E8C8  jr NZ,0xf5e8cd
	jrl	MeasureErase_EraseTrack_Join5	; F5E8CA  jrl T,0xf5e95c
MeasureErase_EraseTrack_Loop:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E8CD  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F5E8D1  ld A,(XHL+IY)
	cp	a, 130	; F5E8D6  cp A,0x82
	jr	nz, MeasureErase_EraseTrack_Skip6	; F5E8D9  jr NZ,0xf5e8de
	jrl	MeasureErase_EraseTrack_Join16	; F5E8DB  jrl T,0xf5eb2d
MeasureErase_EraseTrack_Skip6:
	cp	a, 129	; F5E8DE  cp A,0x81
	jr	z, MeasureErase_EraseTrack_Skip8	; F5E8E1  jr Z,0xf5e934
	ld	l, (3214:16)	; F5E8E3  ld L,(0x0c8e)
	cp	l, (0x0d1d:16)	; F5E8E7  cp L,(0x0d1d)
	jr	nz, MeasureErase_EraseTrack_Skip7	; F5E8EB  jr NZ,0xf5e927
	cp	a, 135	; F5E8ED  cp A,0x87
	jr	nz, MeasureErase_EraseTrack_Skip7	; F5E8F0  jr NZ,0xf5e927
MeasureErase_EraseTrack_Join4:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E8F2  ld XHL,(0x126e)
	ld	(3254:16), xhl	; F5E8F6  ld (0x0cb6),XHL
	ld	(xhl+ix), a	; F5E8FA  ld (XHL+IX),A
	calr	BStore_WriteCursorAdvance	; F5E8FF  calr 0xf5ebd4
	cp	(BStore_ErrorCode:16), 0x00	; F5E902  cp (0x0d4a),0x00
	jrl	nz, MeasureErase_EraseTrack_Return	; F5E907  jrl NZ,0xf5eb9b
	calr	BStore_ReadCursorAdvance	; F5E90A  calr 0xf5eb9c
	cp	(BStore_ErrorCode:16), 0x00	; F5E90D  cp (0x0d4a),0x00
	jrl	nz, MeasureErase_EraseTrack_Return	; F5E912  jrl NZ,0xf5eb9b
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E915  ld XHL,(0x126e)
	bit	7, (xhl+iy)	; F5E919  bit 7,(XHL+IY)
	jr	nz, MeasureErase_EraseTrack_Loop	; F5E91E  jr NZ,0xf5e8cd
	ld	a, (xhl+iy)	; F5E920  ld A,(XHL+IY)
	jr	MeasureErase_EraseTrack_Join4	; F5E925  jr T,0xf5e8f2
MeasureErase_EraseTrack_Skip7:
	calr	BStore_ReadCursorAdvance	; F5E927  calr 0xf5eb9c
	cp	(BStore_ErrorCode:16), 0x00	; F5E92A  cp (0x0d4a),0x00
	jr	z, MeasureErase_EraseTrack_Loop	; F5E92F  jr Z,0xf5e8cd
	jrl	MeasureErase_EraseTrack_Return	; F5E931  jrl T,0xf5eb9b
MeasureErase_EraseTrack_Skip8:
	ld	xhl, (3254:16)	; F5E934  ld XHL,(0x0cb6)
	ld	(xhl+ix), a	; F5E938  ld (XHL+IX),A
	calr	BStore_WriteCursorAdvance	; F5E93D  calr 0xf5ebd4
	cp	(BStore_ErrorCode:16), 0x00	; F5E940  cp (0x0d4a),0x00
	jr	z, MeasureErase_EraseTrack_Skip9	; F5E945  jr Z,0xf5e94a
	jrl	MeasureErase_EraseTrack_Return	; F5E947  jrl T,0xf5eb9b
MeasureErase_EraseTrack_Skip9:
	calr	BStore_ReadCursorAdvance	; F5E94A  calr 0xf5eb9c
	cp	(BStore_ErrorCode:16), 0x00	; F5E94D  cp (0x0d4a),0x00
	jr	z, MeasureErase_EraseTrack_Skip10	; F5E952  jr Z,0xf5e957
	jrl	MeasureErase_EraseTrack_Return	; F5E954  jrl T,0xf5eb9b
MeasureErase_EraseTrack_Skip10:
	inc	1, c	; F5E957  inc 1,C
	jrl	MeasureErase_EraseTrack_Join3	; F5E959  jrl T,0xf5e8c4
MeasureErase_EraseTrack_Join5:
	inc	1, de	; F5E95C  inc 1,DE
	push	xiz	; F5E95E  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F5E95F  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F5E963  ld XDE3,XIZ
	pop	xiz	; F5E966  pop XIZ
	push_lerp	0x38	; F5E967  push XDE3
	push	xhl	; F5E96A  push XHL
	push	xde	; F5E96B  push XDE
	push	xiy	; F5E96C  push XIY
	push	xix	; F5E96D  push XIX
	call	T_F427A8	; F5E96E  call 0xf427a8
	pop	xix	; F5E972  pop XIX
	pop	xiy	; F5E973  pop XIY
	pop	xde	; F5E974  pop XDE
	pop	xhl	; F5E975  pop XHL
	pop_lerp	0x38	; F5E976  pop XDE3
	push	xiz	; F5E979  push XIZ
	ldto_lerp	xiz, 0x38	; F5E97A  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F5E97D  ld (0x126e),XIZ
	pop	xiz	; F5E981  pop XIZ
	jrl	MeasureErase_EraseTrack_Join2	; F5E982  jrl T,0xf5e8b9
MeasureErase_EraseTrack_Join6:
	xor	de, de	; F5E985  xor DE,DE
MeasureErase_EraseTrack_Join7:
	cp	de, (0x0c77:16)	; F5E987  cp DE,(0x0c77)
	jr	nz, MeasureErase_EraseTrack_Skip11	; F5E98B  jr NZ,0xf5e990
	jrl	MeasureErase_EraseTrack_Join16	; F5E98D  jrl T,0xf5eb2d
MeasureErase_EraseTrack_Skip11:
	xor	c, c	; F5E990  xor C,C
MeasureErase_EraseTrack_Join8:
	cp	c, (0x0d1c:16)	; F5E992  cp C,(0x0d1c)
	jr	nz, MeasureErase_EraseTrack_Loop2	; F5E996  jr NZ,0xf5e99b
	jrl	MeasureErase_EraseTrack_Join10	; F5E998  jrl T,0xf5ea23
MeasureErase_EraseTrack_Loop2:
	push	xhl	; F5E99B  push XHL
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5E99C  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F5E9A0  ld A,(XHL+IY)
	pop	xhl	; F5E9A5  pop XHL
	cp	a, 130	; F5E9A6  cp A,0x82
	jr	nz, MeasureErase_EraseTrack_Skip12	; F5E9A9  jr NZ,0xf5e9ae
	jrl	MeasureErase_EraseTrack_Join16	; F5E9AB  jrl T,0xf5eb2d
MeasureErase_EraseTrack_Skip12:
	cp	a, 129	; F5E9AE  cp A,0x81
	jr	z, MeasureErase_EraseTrack_Skip16	; F5E9B1  jr Z,0xf5e9fb
	ld	w, 240:opc	; F5E9B3  ld W,0xf0
	and	w, a	; F5E9B5  and W,A
	cp	w, 144	; F5E9B7  cp W,0x90
	jr	nz, MeasureErase_EraseTrack_Skip14	; F5E9BA  jr NZ,0xf5e9d8
MeasureErase_EraseTrack_Join9:
	calr	BStore_ReadCursorAdvance	; F5E9BC  calr 0xf5eb9c
	cp	(BStore_ErrorCode:16), 0x00	; F5E9BF  cp (0x0d4a),0x00
	jr	z, MeasureErase_EraseTrack_Skip13	; F5E9C4  jr Z,0xf5e9c9
	jrl	MeasureErase_EraseTrack_Return	; F5E9C6  jrl T,0xf5eb9b
MeasureErase_EraseTrack_Skip13:
	push	xde	; F5E9C9  push XDE
	ld	xde, (BStore_CursorBlockAddr:16)	; F5E9CA  ld XDE,(0x126e)
	bit	7, (xde+iy)	; F5E9CE  bit 7,(XDE+IY)
	pop	xde	; F5E9D3  pop XDE
	jr	nz, MeasureErase_EraseTrack_Loop2	; F5E9D4  jr NZ,0xf5e99b
	jr	MeasureErase_EraseTrack_Join9	; F5E9D6  jr T,0xf5e9bc
MeasureErase_EraseTrack_Skip14:
	ld	xhl, (3254:16)	; F5E9D8  ld XHL,(0x0cb6)
	ld	(xhl+ix), a	; F5E9DC  ld (XHL+IX),A
	calr	BStore_WriteCursorAdvance	; F5E9E1  calr 0xf5ebd4
	cp	(BStore_ErrorCode:16), 0x00	; F5E9E4  cp (0x0d4a),0x00
	jr	z, MeasureErase_EraseTrack_Skip15	; F5E9E9  jr Z,0xf5e9ee
	jrl	MeasureErase_EraseTrack_Return	; F5E9EB  jrl T,0xf5eb9b
MeasureErase_EraseTrack_Skip15:
	calr	BStore_ReadCursorAdvance	; F5E9EE  calr 0xf5eb9c
	cp	(BStore_ErrorCode:16), 0x00	; F5E9F1  cp (0x0d4a),0x00
	jr	z, MeasureErase_EraseTrack_Loop2	; F5E9F6  jr Z,0xf5e99b
	jrl	MeasureErase_EraseTrack_Return	; F5E9F8  jrl T,0xf5eb9b
MeasureErase_EraseTrack_Skip16:
	ld	xhl, (3254:16)	; F5E9FB  ld XHL,(0x0cb6)
	ld	(xhl+ix), a	; F5E9FF  ld (XHL+IX),A
	calr	BStore_WriteCursorAdvance	; F5EA04  calr 0xf5ebd4
	cp	(BStore_ErrorCode:16), 0x00	; F5EA07  cp (0x0d4a),0x00
	jr	z, MeasureErase_EraseTrack_Skip17	; F5EA0C  jr Z,0xf5ea11
	jrl	MeasureErase_EraseTrack_Return	; F5EA0E  jrl T,0xf5eb9b
MeasureErase_EraseTrack_Skip17:
	calr	BStore_ReadCursorAdvance	; F5EA11  calr 0xf5eb9c
	cp	(BStore_ErrorCode:16), 0x00	; F5EA14  cp (0x0d4a),0x00
	jr	z, MeasureErase_EraseTrack_Skip18	; F5EA19  jr Z,0xf5ea1e
	jrl	MeasureErase_EraseTrack_Return	; F5EA1B  jrl T,0xf5eb9b
MeasureErase_EraseTrack_Skip18:
	inc	1, c	; F5EA1E  inc 1,C
	jrl	MeasureErase_EraseTrack_Join8	; F5EA20  jrl T,0xf5e992
MeasureErase_EraseTrack_Join10:
	inc	1, de	; F5EA23  inc 1,DE
	push	xiz	; F5EA25  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F5EA26  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F5EA2A  ld XDE3,XIZ
	pop	xiz	; F5EA2D  pop XIZ
	push_lerp	0x38	; F5EA2E  push XDE3
	push	xhl	; F5EA31  push XHL
	push	xde	; F5EA32  push XDE
	push	xiy	; F5EA33  push XIY
	push	xix	; F5EA34  push XIX
	call	T_F427A8	; F5EA35  call 0xf427a8
	pop	xix	; F5EA39  pop XIX
	pop	xiy	; F5EA3A  pop XIY
	pop	xde	; F5EA3B  pop XDE
	pop	xhl	; F5EA3C  pop XHL
	pop_lerp	0x38	; F5EA3D  pop XDE3
	push	xiz	; F5EA40  push XIZ
	ldto_lerp	xiz, 0x38	; F5EA41  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F5EA44  ld (0x126e),XIZ
	pop	xiz	; F5EA48  pop XIZ
	jrl	MeasureErase_EraseTrack_Join7	; F5EA49  jrl T,0xf5e987
MeasureErase_EraseTrack_Join11:
	xor	de, de	; F5EA4C  xor DE,DE
MeasureErase_EraseTrack_Join12:
	cp	de, (0x0c77:16)	; F5EA4E  cp DE,(0x0c77)
	jr	nz, MeasureErase_EraseTrack_Skip19	; F5EA52  jr NZ,0xf5ea57
	jrl	MeasureErase_EraseTrack_Join16	; F5EA54  jrl T,0xf5eb2d
MeasureErase_EraseTrack_Skip19:
	xor	c, c	; F5EA57  xor C,C
MeasureErase_EraseTrack_Join13:
	cp	c, (0x0d1c:16)	; F5EA59  cp C,(0x0d1c)
	jr	nz, MeasureErase_EraseTrack_Loop3	; F5EA5D  jr NZ,0xf5ea62
	jrl	MeasureErase_EraseTrack_Join15	; F5EA5F  jrl T,0xf5eb04
MeasureErase_EraseTrack_Loop3:
	push	xhl	; F5EA62  push XHL
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5EA63  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F5EA67  ld A,(XHL+IY)
	pop	xhl	; F5EA6C  pop XHL
	cp	a, 130	; F5EA6D  cp A,0x82
	jr	nz, MeasureErase_EraseTrack_Skip20	; F5EA70  jr NZ,0xf5ea75
	jrl	MeasureErase_EraseTrack_Join16	; F5EA72  jrl T,0xf5eb2d
MeasureErase_EraseTrack_Skip20:
	cp	a, 129	; F5EA75  cp A,0x81
	jr	z, MeasureErase_EraseTrack_Skip24	; F5EA78  jr Z,0xf5eadc
	ld	w, 240:opc	; F5EA7A  ld W,0xf0
	and	w, a	; F5EA7C  and W,A
	cp	w, 144	; F5EA7E  cp W,0x90
	jr	z, MeasureErase_EraseTrack_Join14	; F5EA81  jr Z,0xf5ea9f
	ld	l, (3214:16)	; F5EA83  ld L,(0x0c8e)
	cp	l, (0x0d1d:16)	; F5EA87  cp L,(0x0d1d)
	jr	nz, MeasureErase_EraseTrack_Skip21	; F5EA8B  jr NZ,0xf5ea92
	cp	a, 135	; F5EA8D  cp A,0x87
	jr	z, MeasureErase_EraseTrack_Join14	; F5EA90  jr Z,0xf5ea9f
MeasureErase_EraseTrack_Skip21:
	calr	BStore_ReadCursorAdvance	; F5EA92  calr 0xf5eb9c
	cp	(BStore_ErrorCode:16), 0x00	; F5EA95  cp (0x0d4a),0x00
	jr	z, MeasureErase_EraseTrack_Loop3	; F5EA9A  jr Z,0xf5ea62
	jrl	MeasureErase_EraseTrack_Return	; F5EA9C  jrl T,0xf5eb9b
MeasureErase_EraseTrack_Join14:
	ld	xhl, (3254:16)	; F5EA9F  ld XHL,(0x0cb6)
	ld	(xhl+ix), a	; F5EAA3  ld (XHL+IX),A
	calr	BStore_WriteCursorAdvance	; F5EAA8  calr 0xf5ebd4
	cp	(BStore_ErrorCode:16), 0x00	; F5EAAB  cp (0x0d4a),0x00
	jr	z, MeasureErase_EraseTrack_Skip22	; F5EAB0  jr Z,0xf5eab5
	jrl	MeasureErase_EraseTrack_Return	; F5EAB2  jrl T,0xf5eb9b
MeasureErase_EraseTrack_Skip22:
	calr	BStore_ReadCursorAdvance	; F5EAB5  calr 0xf5eb9c
	cp	(BStore_ErrorCode:16), 0x00	; F5EAB8  cp (0x0d4a),0x00
	jr	z, MeasureErase_EraseTrack_Skip23	; F5EABD  jr Z,0xf5eac2
	jrl	MeasureErase_EraseTrack_Return	; F5EABF  jrl T,0xf5eb9b
MeasureErase_EraseTrack_Skip23:
	push	xhl	; F5EAC2  push XHL
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5EAC3  ld XHL,(0x126e)
	bit	7, (xhl+iy)	; F5EAC7  bit 7,(XHL+IY)
	pop	xhl	; F5EACC  pop XHL
	jr	nz, MeasureErase_EraseTrack_Loop3	; F5EACD  jr NZ,0xf5ea62
	push	xhl	; F5EACF  push XHL
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5EAD0  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F5EAD4  ld A,(XHL+IY)
	pop	xhl	; F5EAD9  pop XHL
	jr	MeasureErase_EraseTrack_Join14	; F5EADA  jr T,0xf5ea9f
MeasureErase_EraseTrack_Skip24:
	ld	xhl, (3254:16)	; F5EADC  ld XHL,(0x0cb6)
	ld	(xhl+ix), a	; F5EAE0  ld (XHL+IX),A
	calr	BStore_WriteCursorAdvance	; F5EAE5  calr 0xf5ebd4
	cp	(BStore_ErrorCode:16), 0x00	; F5EAE8  cp (0x0d4a),0x00
	jr	z, MeasureErase_EraseTrack_Skip25	; F5EAED  jr Z,0xf5eaf2
	jrl	MeasureErase_EraseTrack_Return	; F5EAEF  jrl T,0xf5eb9b
MeasureErase_EraseTrack_Skip25:
	calr	BStore_ReadCursorAdvance	; F5EAF2  calr 0xf5eb9c
	cp	(BStore_ErrorCode:16), 0x00	; F5EAF5  cp (0x0d4a),0x00
	jr	z, MeasureErase_EraseTrack_Skip26	; F5EAFA  jr Z,0xf5eaff
	jrl	MeasureErase_EraseTrack_Return	; F5EAFC  jrl T,0xf5eb9b
MeasureErase_EraseTrack_Skip26:
	inc	1, c	; F5EAFF  inc 1,C
	jrl	MeasureErase_EraseTrack_Join13	; F5EB01  jrl T,0xf5ea59
MeasureErase_EraseTrack_Join15:
	inc	1, de	; F5EB04  inc 1,DE
	push	xiz	; F5EB06  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F5EB07  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F5EB0B  ld XDE3,XIZ
	pop	xiz	; F5EB0E  pop XIZ
	push_lerp	0x38	; F5EB0F  push XDE3
	push	xhl	; F5EB12  push XHL
	push	xde	; F5EB13  push XDE
	push	xiy	; F5EB14  push XIY
	push	xix	; F5EB15  push XIX
	call	T_F427A8	; F5EB16  call 0xf427a8
	pop	xix	; F5EB1A  pop XIX
	pop	xiy	; F5EB1B  pop XIY
	pop	xde	; F5EB1C  pop XDE
	pop	xhl	; F5EB1D  pop XHL
	pop_lerp	0x38	; F5EB1E  pop XDE3
	push	xiz	; F5EB21  push XIZ
	ldto_lerp	xiz, 0x38	; F5EB22  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F5EB25  ld (0x126e),XIZ
	pop	xiz	; F5EB29  pop XIZ
	jrl	MeasureErase_EraseTrack_Join12	; F5EB2A  jrl T,0xf5ea4e
MeasureErase_EraseTrack_Join16:
	ld	(3262:16), iy	; F5EB2D  ld (0x0cbe),IY
	ld	(3258:16), ix	; F5EB31  ld (0x0cba),IX
	ld	wa, (3260:16)	; F5EB35  ld WA,(0x0cbc)
	ld	(3169:16), wa	; F5EB39  ld (0x0c61),WA
	ld	wa, (3262:16)	; F5EB3D  ld WA,(0x0cbe)
	ld	(3175:16), wa	; F5EB41  ld (0x0c67),WA
	ld	wa, (3252:16)	; F5EB45  ld WA,(0x0cb4)
	ld	(3159:16), wa	; F5EB49  ld (0x0c57),WA
	ld	wa, (3258:16)	; F5EB4D  ld WA,(0x0cba)
	ld	(3165:16), wa	; F5EB51  ld (0x0c5d),WA
	ld	de, (3276:16)	; F5EB55  ld DE,(0x0ccc)
	ld	wa, (3278:16)	; F5EB59  ld WA,(0x0cce)
	ld	(3179:16), wa	; F5EB5D  ld (0x0c6b),WA
	call	T_F42778	; F5EB61  call 0xf42778
	cp	(BStore_ErrorCode:16), 0x00	; F5EB65  cp (0x0d4a),0x00
	jr	nz, MeasureErase_EraseTrack_Return	; F5EB6A  jr NZ,0xf5eb9b
	cp	ix, 5:i3	; F5EB6C  cp IX,5
	jr	nz, MeasureErase_EraseTrack_Skip27	; F5EB6E  jr NZ,0xf5eb8c
	ld	hl, (3159:16)	; F5EB70  ld HL,(0x0c57)
	call	T_BStore_SeekBlock	; F5EB74  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5EB78  ld XHL,(0x126e)
	ld	hl, (xhl+1)	; F5EB7C  ld HL,(XHL+0x01)
	cp	hl, 0:i3	; F5EB7F  cp HL,0
	jr	z, MeasureErase_EraseTrack_Return	; F5EB81  jr Z,0xf5eb9b
	ld	(3159:16), hl	; F5EB83  ld (0x0c57),HL
	ldw	ix, 255	; F5EB87  ld IX,0x00ff
	jr	MeasureErase_EraseTrack_Join17	; F5EB8A  jr T,0xf5eb8e
MeasureErase_EraseTrack_Skip27:
	dec	1, ix	; F5EB8C  dec 1,IX
MeasureErase_EraseTrack_Join17:
	call	T_BStore_SaveCursor	; F5EB8E  call 0xf427b0
	call	T_BStore_TruncateChainAfterBlock	; F5EB92  call 0xf42794
	cp	(BStore_ErrorCode:16), 0x00	; F5EB96  cp (0x0d4a),0x00
MeasureErase_EraseTrack_Return:
	ret	; F5EB9B  ret

; --------------------------------------------------------------------------
; BStore_ReadCursorAdvance
; Called from: in-module: 0xF5E90A 0xF5E927 0xF5E94A 0xF5E9BC 0xF5E9EE
;              0xF5EA11 0xF5EA92 0xF5EAB5 +2 more
; Touches: (0x0CBC) (0x0D4A) (0x126E)
; Calls:   T_BStore_SeekBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5EB9C is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ReadCursorAdvance: Steps the read cursor (block at (0x126E), offset IY) one byte; past 0xFF it follows the +3
;   next link of block (0x0CBC), keeps the new number in (0x0CBC), BStore_ErrorCode := 2 if that block is not
;   allocated, else IY := 5. The body of BStore_ReadCursorAdvance_Call (whose header already describes it);
;   MeasureErase_EraseTrack's copy loops call it nine times. Basis: callers + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_l.json)
BStore_ReadCursorAdvance:
	inc	1, iy	; F5EB9C  inc 1,IY
	cp	iy, 255	; F5EB9E  cp IY,0x00ff
	jr	ule, BStore_ReadCursorAdvance_Return	; F5EBA2  jr ULE,0xf5ebcf
	ld	hl, (3260:16)	; F5EBA4  ld HL,(0x0cbc)
	call	T_BStore_SeekBlock	; F5EBA8  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5EBAC  ld XHL,(0x126e)
	ld	wa, (xhl+3)	; F5EBB0  ld WA,(XHL+0x03)
	ld	(3260:16), wa	; F5EBB3  ld (0x0cbc),WA
	ld	hl, wa	; F5EBB7  ld HL,WA
	call	T_BStore_SeekBlock	; F5EBB9  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5EBBD  ld XHL,(0x126e)
	bit	7, (xhl)	; F5EBC1  bit 7,(XHL)
	jr	nz, BStore_ReadCursorAdvance_Skip	; F5EBC3  jr NZ,0xf5ebcc
	ld	(BStore_ErrorCode:16), 2	; F5EBC5  ld (0x0d4a),0x02
	jr	BStore_ReadCursorAdvance_Return	; F5EBCA  jr T,0xf5ebcf
BStore_ReadCursorAdvance_Skip:
	ldw	iy, 5	; F5EBCC  ld IY,0x0005
BStore_ReadCursorAdvance_Return:
	ret	; F5EBCF  ret

; --------------------------------------------------------------------------
; BStore_ReadCursorAdvance_Call
; Called from: T_BStore_ReadCursorAdvance_Call (x25)
; Touches: nothing with an absolute address
; Calls:   BStore_ReadCursorAdvance
; Evidence: thunk slot T_BStore_ReadCursorAdvance_Call holds `jp 0x00F5EBD0`, and 0xF5EBD0 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_ReadCursorAdvance_Call: Thunk-exposed `calr BStore_ReadCursorAdvance / ret`: steps the read cursor (block at (0x126E),
;   offset IY) one byte; past 0xFF it follows the +3 NEXT link of block (0x0CBC), keeps the new number in (0x0CBC),
;   errors 2 if that block is not allocated, else IY = 5. BStore_CursorAdvance's twin for the two-cursor copy loops.
;   Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave2_f.json)
BStore_ReadCursorAdvance_Call:		; <- T_BStore_ReadCursorAdvance_Call
	calr	BStore_ReadCursorAdvance	; F5EBD0  calr 0xf5eb9c
	ret	; F5EBD3  ret

; --------------------------------------------------------------------------
; BStore_WriteCursorAdvance
; Called from: in-module: 0xF5E8FF 0xF5E93D 0xF5E9E1 0xF5EA04 0xF5EAA8
;              0xF5EAE5 0xF5EC0E
; Touches: (0x0CB4) (0x0CB6) (0x0D4A) (0x126E)
; Calls:   T_BStore_SeekBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5EBD4 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_WriteCursorAdvance: Steps the write cursor (block address (0x0CB6), block number (0x0CB4), offset IX) one
;   byte; past 0xFF it follows the +3 NEXT link of (0x0CB6), errors 2 if that block is not allocated, else (0x0CB6) :=
;   it and IX = 5; (0x126E) is preserved. BStore_ReadCursorAdvance's write-side twin: MeasureErase_EraseTrack calls it
;   after each byte it keeps (ld (XHL+IX),A); BStore_RewriteTrackForPart via T_BStore_WriteCursorAdvance_Call. Basis: callers + body + twin.
;   (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
BStore_WriteCursorAdvance:
	ld	xwa, (BStore_CursorBlockAddr:16)	; F5EBD4  ld XWA,(0x126e)
	push	xwa	; F5EBD8  push XWA
	inc	1, ix	; F5EBD9  inc 1,IX
	cp	ix, 255	; F5EBDB  cp IX,0x00ff
	jr	ule, BStore_WriteCursorAdvance_Join	; F5EBDF  jr ULE,0xf5ec08
	ld	xhl, (3254:16)	; F5EBE1  ld XHL,(0x0cb6)
	ld	wa, (xhl+3)	; F5EBE5  ld WA,(XHL+0x03)
	ld	(3252:16), wa	; F5EBE8  ld (0x0cb4),WA
	ld	hl, wa	; F5EBEC  ld HL,WA
	call	T_BStore_SeekBlock	; F5EBEE  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5EBF2  ld XHL,(0x126e)
	bit	7, (xhl)	; F5EBF6  bit 7,(XHL)
	jr	nz, BStore_WriteCursorAdvance_Skip	; F5EBF8  jr NZ,0xf5ec01
	ld	(BStore_ErrorCode:16), 2	; F5EBFA  ld (0x0d4a),0x02
	jr	BStore_WriteCursorAdvance_Join	; F5EBFF  jr T,0xf5ec08
BStore_WriteCursorAdvance_Skip:
	ld	(3254:16), xhl	; F5EC01  ld (0x0cb6),XHL
	ldw	ix, 5	; F5EC05  ld IX,0x0005
BStore_WriteCursorAdvance_Join:
	pop	xwa	; F5EC08  pop XWA
	ld	(BStore_CursorBlockAddr:16), xwa	; F5EC09  ld (0x126e),XWA
	ret	; F5EC0D  ret

; --------------------------------------------------------------------------
; BStore_WriteCursorAdvance_Call
; Called from: T_BStore_WriteCursorAdvance_Call (x7)
; Touches: nothing with an absolute address
; Calls:   BStore_WriteCursorAdvance
; Evidence: thunk slot T_BStore_WriteCursorAdvance_Call holds `jp 0x00F5EC0E`, and 0xF5EC0E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_WriteCursorAdvance_Call: calls BStore_WriteCursorAdvance and returns (notes/prom_ab_wrapper_names.py; DERIVATIVE)
BStore_WriteCursorAdvance_Call:		; <- T_BStore_WriteCursorAdvance_Call
	calr	BStore_WriteCursorAdvance	; F5EC0E  calr 0xf5ebd4
	ret	; F5EC11  ret

; --------------------------------------------------------------------------
; MeasureInsert_Execute
; Called from: T_MeasureInsert_Execute (x2)
; Touches: (0x0C70) (0x0C71) (0x0C73) (0x0C75) (0x0C77) (0x0C83) (0x0C8A)
;          (0x0C8E) (0x0C8F) (0x0CA2) +8 more  |  0x603422
; Calls:   T_BStore_LoadGeometry T_BStore_OpenChainAtSavedCursor MeasureInsert_InsertToTrack sub_F5EE95 T_SongEdit_InsertTimeSigsForMeasureInsert MeasureInsert_InsertWithinTrack
;          T_SongEdit_CheckFreeBlocksForInsert T_BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_24 T_F40A1C
; Evidence: thunk slot T_MeasureInsert_Execute holds `jp 0x00F5EC12`, and 0xF5EC12 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_Execute: Runs MEASURE INSERT on the job cells MeasureInsert_LcdKeyRow1 fills: tracks (0x0C70) (0x7F =
;   all) and (0x0C71) 1..(0x0CA2), measures (0x0C73) / (0x0C75) / (0x0C77) 1..999 (else BStore_ErrorCode 3; a master-
;   track part 0x20 gives 9). Called by MeasureInsert_LcdKeyRow1 and by its repeat loop MeasureInsert_RepeatInsert ((0x0E17) more
;   times, advancing (0x0C75)), both through slot T_MeasureInsert_Execute. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_m.json)
MeasureInsert_Execute:		; <- T_MeasureInsert_Execute
	and	(0x0d45:16), 0xfc	; F5EC12  and (0x0d45),0xfc
	and	(0x0d46:16), 0xfa	; F5EC17  and (0x0d46),0xfa
	call	T_BStore_LoadGeometry	; F5EC1C  call 0xf427c4
	ld	a, (3184:16)	; F5EC20  ld A,(0x0c70)
	cp	a, 1:i3	; F5EC24  cp A,1
	jr	c, MeasureInsert_Execute_Skip3	; F5EC26  jr C,0xf5ec6b
	cp	a, 127	; F5EC28  cp A,0x7f
	jr	z, MeasureInsert_Execute_Skip2	; F5EC2B  jr Z,0xf5ec41
	cp	a, (0x0ca2:16)	; F5EC2D  cp A,(0x0ca2)
	jr	ugt, MeasureInsert_Execute_Skip3	; F5EC31  jr UGT,0xf5ec6b
	ld	a, (3185:16)	; F5EC33  ld A,(0x0c71)
	cp	a, 1:i3	; F5EC37  cp A,1
	jr	c, MeasureInsert_Execute_Skip3	; F5EC39  jr C,0xf5ec6b
	cp	a, (0x0ca2:16)	; F5EC3B  cp A,(0x0ca2)
	jr	ugt, MeasureInsert_Execute_Skip3	; F5EC3F  jr UGT,0xf5ec6b
MeasureInsert_Execute_Skip2:
	ld	wa, (3187:16)	; F5EC41  ld WA,(0x0c73)
	cp	wa, 1:i3	; F5EC45  cp WA,1
	jr	c, MeasureInsert_Execute_Skip3	; F5EC47  jr C,0xf5ec6b
	cp	wa, 999	; F5EC49  cp WA,0x03e7
	jr	ugt, MeasureInsert_Execute_Skip3	; F5EC4D  jr UGT,0xf5ec6b
	ld	wa, (3191:16)	; F5EC4F  ld WA,(0x0c77)
	cp	wa, 1:i3	; F5EC53  cp WA,1
	jr	c, MeasureInsert_Execute_Skip3	; F5EC55  jr C,0xf5ec6b
	cp	wa, 999	; F5EC57  cp WA,0x03e7
	jr	ugt, MeasureInsert_Execute_Skip3	; F5EC5B  jr UGT,0xf5ec6b
	ld	wa, (3189:16)	; F5EC5D  ld WA,(0x0c75)
	cp	wa, 1:i3	; F5EC61  cp WA,1
	jr	c, MeasureInsert_Execute_Skip3	; F5EC63  jr C,0xf5ec6b
	cp	wa, 999	; F5EC65  cp WA,0x03e7
	jr	ule, MeasureInsert_Execute_Skip4	; F5EC69  jr ULE,0xf5ec73
MeasureInsert_Execute_Skip3:
	ld	(BStore_ErrorCode:16), 3	; F5EC6B  ld (0x0d4a),0x03
	jrl	MeasureInsert_Execute_Join6	; F5EC70  jrl T,0xf5ee62
MeasureInsert_Execute_Skip4:
	ld	(BStore_ErrorCode:16), 0	; F5EC73  ld (0x0d4a),0x00
	and	(0x0c8a:16), 0xbf	; F5EC78  and (0x0c8a),0xbf
	cp	(0x0c70:16), 0x7f	; F5EC7D  cp (0x0c70),0x7f
	jrl	z, MeasureInsert_Execute_Skip10	; F5EC82  jrl Z,0xf5eda7
	xor	hl, hl	; F5EC85  xor HL,HL
	ld	l, (3184:16)	; F5EC87  ld L,(0x0c70)
	cp	l, (0x0c71:16)	; F5EC8B  cp L,(0x0c71)
	jr	z, MeasureInsert_Execute_Skip6	; F5EC8F  jr Z,0xf5eccb
	xor	hl, hl	; F5EC91  xor HL,HL
	ld	l, (3184:16)	; F5EC93  ld L,(0x0c70)
	dec	1, l	; F5EC97  dec 1,L
	push	xix	; F5EC99  push XIX
	ld	xix, BStore_TrackToPart	; F5EC9A  ld XIX,0x00603422
	ld	a, (xix+hl)	; F5EC9F  ld A,(XIX+HL)
	pop	xix	; F5ECA4  pop XIX
	cp	a, 32	; F5ECA5  cp A,0x20
	jr	z, MeasureInsert_Execute_Skip5	; F5ECA8  jr Z,0xf5ecc3
	ld	l, (3185:16)	; F5ECAA  ld L,(0x0c71)
	dec	1, l	; F5ECAE  dec 1,L
	push	xix	; F5ECB0  push XIX
	ld	xix, BStore_TrackToPart	; F5ECB1  ld XIX,0x00603422
	ld	a, (xix+hl)	; F5ECB6  ld A,(XIX+HL)
	pop	xix	; F5ECBB  pop XIX
	cp	a, 32	; F5ECBC  cp A,0x20
	jr	z, MeasureInsert_Execute_Skip5	; F5ECBF  jr Z,0xf5ecc3
	jr	MeasureInsert_Execute_Join2	; F5ECC1  jr T,0xf5ecf9
MeasureInsert_Execute_Skip5:
	ld	(BStore_ErrorCode:16), 9	; F5ECC3  ld (0x0d4a),0x09
	jrl	MeasureInsert_Execute_Join6	; F5ECC8  jrl T,0xf5ee62
MeasureInsert_Execute_Skip6:
	dec	1, l	; F5ECCB  dec 1,L
	push	xix	; F5ECCD  push XIX
	ld	xix, BStore_TrackToPart	; F5ECCE  ld XIX,0x00603422
	ld	a, (xix+hl)	; F5ECD3  ld A,(XIX+HL)
	pop	xix	; F5ECD8  pop XIX
	cp	a, 32	; F5ECD9  cp A,0x20
	jr	nz, MeasureInsert_Execute_Skip7	; F5ECDC  jr NZ,0xf5ecf7
	or	(0x0c8a:16), 0x40	; F5ECDE  or (0x0c8a),0x40
	xor	wa, wa	; F5ECE3  xor WA,WA
	ld	a, (3184:16)	; F5ECE5  ld A,(0x0c70)
	call	T_BStore_OpenChainAtSavedCursor	; F5ECE9  call 0xf42790
	cp	(BStore_ErrorCode:16), 0x00	; F5ECED  cp (0x0d4a),0x00
	jr	z, MeasureInsert_Execute_Skip7	; F5ECF2  jr Z,0xf5ecf7
	jrl	MeasureInsert_Execute_Join6	; F5ECF4  jrl T,0xf5ee62
MeasureInsert_Execute_Skip7:
	jr	MeasureInsert_Execute_Join3	; F5ECF7  jr T,0xf5ed69
MeasureInsert_Execute_Join2:
	ld	a, (3184:16)	; F5ECF9  ld A,(0x0c70)
	ld	(3214:16), a	; F5ECFD  ld (0x0c8e),A
	ld	a, (3185:16)	; F5ED01  ld A,(0x0c71)
	ld	(3215:16), a	; F5ED05  ld (0x0c8f),A
	calr	MeasureInsert_InsertToTrack	; F5ED09  calr 0xf5ee9a
	cp	(BStore_ErrorCode:16), 0x00	; F5ED0C  cp (0x0d4a),0x00
	jr	nz, MeasureInsert_Execute_Skip8	; F5ED11  jr NZ,0xf5ed66
	xor	hl, hl	; F5ED13  xor HL,HL
	ld	l, (3184:16)	; F5ED15  ld L,(0x0c70)
	dec	1, hl	; F5ED19  dec 1,HL
	push	xix	; F5ED1B  push XIX
	ld	xix, BStore_TrackToPart	; F5ED1C  ld XIX,0x00603422
	ld	a, (xix+hl)	; F5ED21  ld A,(XIX+HL)
	pop	xix	; F5ED26  pop XIX
	ld	l, (3185:16)	; F5ED27  ld L,(0x0c71)
	dec	1, hl	; F5ED2B  dec 1,HL
	push	xix	; F5ED2D  push XIX
	ld	xix, BStore_TrackToPart	; F5ED2E  ld XIX,0x00603422
	cp	a, (xix+hl)	; F5ED33  cp A,(XIX+HL)
	pop	xix	; F5ED38  pop XIX
	jr	z, MeasureInsert_Execute_Skip8	; F5ED39  jr Z,0xf5ed66
	ld	(3203:16), l	; F5ED3B  ld (0x0c83),L
	push	xix	; F5ED3F  push XIX
	ld	xix, BStore_TrackToPart	; F5ED40  ld XIX,0x00603422
	ld	l, (xix+hl)	; F5ED45  ld L,(XIX+HL)
	ld	(3535:16), l	; F5ED4A  ld (0x0dcf),L
	pop	xix	; F5ED4E  pop XIX
	push	xix	; F5ED4F  push XIX
	ld	xix, IdentityMap_0_31	; F5ED50  ld XIX,0x00f5ee75
	ld	l, (xix+hl)	; F5ED55  ld L,(XIX+HL)
	ld	(3396:16), l	; F5ED5A  ld (0x0d44),L
	pop	xix	; F5ED5E  pop XIX
	ld	(3508:16), a	; F5ED5F  ld (0x0db4),A
	calr	sub_F5EE95	; F5ED63  calr 0xf5ee95
MeasureInsert_Execute_Skip8:
	jrl	MeasureInsert_Execute_Join6	; F5ED66  jrl T,0xf5ee62
MeasureInsert_Execute_Join3:
	ld	a, (3184:16)	; F5ED69  ld A,(0x0c70)
	ld	(3214:16), a	; F5ED6D  ld (0x0c8e),A
	ld	(3215:16), a	; F5ED71  ld (0x0c8f),A
	bit	6, (0x0c8a:16)	; F5ED75  bit 6,(0x0c8a)
	jr	z, MeasureInsert_Execute_Skip9	; F5ED79  jr Z,0xf5ed9c
	xor	hl, hl	; F5ED7B  xor HL,HL
	ld	l, a	; F5ED7D  ld L,A
	dec	1, hl	; F5ED7F  dec 1,HL
	push	xix	; F5ED81  push XIX
	ld	xix, BStore_TrackToPart	; F5ED82  ld XIX,0x00603422
	cp	(xix+hl), 0x20	; F5ED87  cp (XIX+HL),0x20
	pop	xix	; F5ED8D  pop XIX
	jr	nz, MeasureInsert_Execute_Skip9	; F5ED8E  jr NZ,0xf5ed9c
	call	T_SongEdit_InsertTimeSigsForMeasureInsert	; F5ED90  call 0xf432c4
	cp	(BStore_ErrorCode:16), 0x00	; F5ED94  cp (0x0d4a),0x00
	jrl	nz, MeasureInsert_Execute_Join6	; F5ED99  jrl NZ,0xf5ee62
MeasureInsert_Execute_Skip9:
	calr	MeasureInsert_InsertWithinTrack	; F5ED9C  calr 0xf5f02c
	cp	(BStore_ErrorCode:16), 0x00	; F5ED9F  cp (0x0d4a),0x00
	jrl	MeasureInsert_Execute_Join6	; F5EDA4  jrl T,0xf5ee62
MeasureInsert_Execute_Skip10:
	xor	hl, hl	; F5EDA7  xor HL,HL
MeasureInsert_Execute_Join4:
	cp	l, (0x0ca3:16)	; F5EDA9  cp L,(0x0ca3)
	jr	ugt, MeasureInsert_Execute_Skip12	; F5EDAD  jr UGT,0xf5eddd
	push	xix	; F5EDAF  push XIX
	ld	xix, BStore_TrackToPart	; F5EDB0  ld XIX,0x00603422
	ld	a, (xix+hl)	; F5EDB5  ld A,(XIX+HL)
	pop	xix	; F5EDBA  pop XIX
	cp	a, 32	; F5EDBB  cp A,0x20
	jr	nz, MeasureInsert_Execute_Skip11	; F5EDBE  jr NZ,0xf5edd9
	or	(0x0c8a:16), 0x40	; F5EDC0  or (0x0c8a),0x40
	pushw	hl	; F5EDC5  push HL
	ld	wa, hl	; F5EDC6  ld WA,HL
	inc	1, wa	; F5EDC8  inc 1,WA
	call	T_BStore_OpenChainAtSavedCursor	; F5EDCA  call 0xf42790
	popw	hl	; F5EDCE  pop HL
	cp	(BStore_ErrorCode:16), 0x00	; F5EDCF  cp (0x0d4a),0x00
	jr	z, MeasureInsert_Execute_Skip11	; F5EDD4  jr Z,0xf5edd9
	jrl	MeasureInsert_Execute_Join6	; F5EDD6  jrl T,0xf5ee62
MeasureInsert_Execute_Skip11:
	inc	1, hl	; F5EDD9  inc 1,HL
	jr	MeasureInsert_Execute_Join4	; F5EDDB  jr T,0xf5eda9
MeasureInsert_Execute_Skip12:
	call	T_SongEdit_CheckFreeBlocksForInsert	; F5EDDD  call 0xf427d4
	cp	(BStore_ErrorCode:16), 0x00	; F5EDE1  cp (0x0d4a),0x00
	jr	z, MeasureInsert_Execute_Skip13	; F5EDE6  jr Z,0xf5edeb
	jrl	MeasureInsert_Execute_Join6	; F5EDE8  jrl T,0xf5ee62
MeasureInsert_Execute_Skip13:
	ld	(3352:16), 0	; F5EDEB  ld (0x0d18),0x00
	ld	a, 1:opc	; F5EDF0  ld A,0x01
MeasureInsert_Execute_Join5:
	cp	a, (0x0ca2:16)	; F5EDF2  cp A,(0x0ca2)
	jr	ugt, MeasureInsert_Execute_Skip17	; F5EDF6  jr UGT,0xf5ee5a
	ld	(3214:16), a	; F5EDF8  ld (0x0c8e),A
	ld	(3215:16), a	; F5EDFC  ld (0x0c8f),A
	bit	6, (0x0c8a:16)	; F5EE00  bit 6,(0x0c8a)
	jr	z, MeasureInsert_Execute_Skip14	; F5EE04  jr Z,0xf5ee2d
	xor	hl, hl	; F5EE06  xor HL,HL
	ld	l, a	; F5EE08  ld L,A
	dec	1, hl	; F5EE0A  dec 1,HL
	push	xix	; F5EE0C  push XIX
	ld	xix, BStore_TrackToPart	; F5EE0D  ld XIX,0x00603422
	cp	(xix+hl), 0x20	; F5EE12  cp (XIX+HL),0x20
	pop	xix	; F5EE18  pop XIX
	jr	nz, MeasureInsert_Execute_Skip14	; F5EE19  jr NZ,0xf5ee2d
	pushw	wa	; F5EE1B  push WA
	ld	(BStore_ErrorCode:16), 0	; F5EE1C  ld (0x0d4a),0x00
	call	T_SongEdit_InsertTimeSigsForMeasureInsert	; F5EE21  call 0xf432c4
	popw	wa	; F5EE25  pop WA
	cp	(BStore_ErrorCode:16), 0x00	; F5EE26  cp (0x0d4a),0x00
	jr	nz, MeasureInsert_Execute_Skip15	; F5EE2B  jr NZ,0xf5ee32
MeasureInsert_Execute_Skip14:
	pushw	wa	; F5EE2D  push WA
	calr	MeasureInsert_InsertWithinTrack	; F5EE2E  calr 0xf5f02c
	popw	wa	; F5EE31  pop WA
MeasureInsert_Execute_Skip15:
	cp	(BStore_ErrorCode:16), 0x00	; F5EE32  cp (0x0d4a),0x00
	jr	z, MeasureInsert_Execute_Skip16	; F5EE37  jr Z,0xf5ee56
	cp	(BStore_ErrorCode:16), 0x01	; F5EE39  cp (0x0d4a),0x01
	jr	z, MeasureInsert_Execute_Skip16	; F5EE3E  jr Z,0xf5ee56
	cp	(BStore_ErrorCode:16), 0x08	; F5EE40  cp (0x0d4a),0x08
	jr	z, MeasureInsert_Execute_Skip16	; F5EE45  jr Z,0xf5ee56
	cp	(0x0d18:16), 0x00	; F5EE47  cp (0x0d18),0x00
	jr	nz, MeasureInsert_Execute_Skip16	; F5EE4C  jr NZ,0xf5ee56
	ld	l, (BStore_ErrorCode:16)	; F5EE4E  ld L,(0x0d4a)
	ld	(3352:16), l	; F5EE52  ld (0x0d18),L
MeasureInsert_Execute_Skip16:
	inc	1, a	; F5EE56  inc 1,A
	jr	MeasureInsert_Execute_Join5	; F5EE58  jr T,0xf5edf2
MeasureInsert_Execute_Skip17:
	ld	a, (3352:16)	; F5EE5A  ld A,(0x0d18)
	ld	(BStore_ErrorCode:16), a	; F5EE5E  ld (0x0d4a),A
MeasureInsert_Execute_Join6:
	call	T_BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_24	; F5EE62  call 0xf42814
	call	T_F40A1C	; F5EE66  call 0xf40a1c
	and	(0x0d45:16), 0xfc	; F5EE6A  and (0x0d45),0xfc
	and	(0x0d46:16), 0xfa	; F5EE6F  and (0x0d46),0xfa
	ret	; F5EE74  ret

; --------------------------------------------------------------------------
; IdentityMap_0_31 -- 32 bytes, and entry k = k for every k.  The name
;                     describes the CONTENT and claims nothing about the
;                     purpose.
; Entry count: 32, fixed by the two `calr 0x00F5EE95` sites at 0xF5ED63 and
;              0xF5F373: 0xF5EE95 - 0xF5EE75 = 32, and both of those calls
;              are decoded instructions of this transcription, not
;              resynchronised guesses.
; Read by: three sites, each `ld XIX,0x00F5EE75` followed by `ld
;          L,(XIX+HL)`: the instructions at 0xF5ED50, 0xF5F360 and 0xF600DD.
;          (A byte scan for the address reports 0xF5ED51, 0xF5F361 and
;          0xF600DE -- those are the OPERAND fields, one byte into each
;          instruction.)  All three store the result to (0x0D44).
; Evidence: all 32 bytes are re-read and compared with 0..31 on every emit,
;           and the 32 comes from the two `calr 0x00F5EE95` above -- both of
;           them decoded instructions of this transcription, so the length
;           is a transfer target and not a place where a linear decode
;           happened to resynchronise.
; Unknown: why an identity map exists at all.  A table that returns its own
;          index changes nothing at run time, so either it is a hook a later
;          build was meant to fill in, or the index has a meaning the map
;          documents rather than alters.  Nothing here decides which, and
;          the name deliberately does not.
; --------------------------------------------------------------------------
IdentityMap_0_31:
	.byte	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F	; F5EE75  [0..15]
	.byte	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F	; F5EE85  [16..31]


; --------------------------------------------------------------------------
; sub_F5EE95
; Called from: in-module: 0xF5ED63 0xF5F373
; Touches: nothing with an absolute address
; Calls:   T_F42804
; Evidence: the label is here because it is the target of `calr 0xF5EE95` at
;           0xF5ED63 and at 0xF5F373, the two calls that step past the 32
;           bytes of IdentityMap_0_31; the address is an instruction
;           boundary of this transcription (re-asserted on every emit)
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F5EE95:
	call	T_F42804	; F5EE95  call 0xf42804
	ret	; F5EE99  ret

; --------------------------------------------------------------------------
; MeasureInsert_InsertToTrack
; Called from: in-module: 0xF5ED09 0xF5F038
; Touches: (0x0C57) (0x0C5D) (0x0C61) (0x0C67) (0x0C6B) (0x0C73) (0x0C75)
;          (0x0C8A) (0x0C8E) (0x0C8F) +21 more
; Calls:   T_BStore_ValidateSavedCursor T_Seq_FindMasterTrack T_BStore_SeekMeasure T_F42798 T_BStore_AllocChain T_BStore_SaveCursor T_BStore_CopyRangeBackward
;          T_BStore_SeekBlock T_BStore_TruncateChainAfterBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5EE9A is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_InsertToTrack: MEASURE INSERT core: inserts measures (0x0C73)..+(0x0C77) of track (0x0C8E) into track
;   (0x0C8F) before measure (0x0C75): sizes the range (T_F42798), extends the destination chain (T_BStore_AllocChain),
;   opens the gap by moving its tail up (BStore_CopyRangeBackward) and copies the source range into it
;   (BStore_CopyRangeBackward again). Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
MeasureInsert_InsertToTrack:
	and	(0x0c8a:16), 0xf7	; F5EE9A  and (0x0c8a),0xf7
	ld	(BStore_ErrorCode:16), 0	; F5EE9F  ld (0x0d4a),0x00
	xor	wa, wa	; F5EEA4  xor WA,WA
	ld	a, (3215:16)	; F5EEA6  ld A,(0x0c8f)
	ld	(3354:16), wa	; F5EEAA  ld (0x0d1a),WA
	call	T_BStore_ValidateSavedCursor	; F5EEAE  call 0xf42770
	cp	(BStore_ErrorCode:16), 0x00	; F5EEB2  cp (0x0d4a),0x00
	jrl	nz, MeasureInsert_InsertToTrack_Return	; F5EEB7  jrl NZ,0xf5f02b
	ld	(3278:16), iy	; F5EEBA  ld (0x0cce),IY
	ld	wa, (BStore_CursorBlock:16)	; F5EEBE  ld WA,(0x345c)
	ld	(3276:16), wa	; F5EEC2  ld (0x0ccc),WA
	call	T_Seq_FindMasterTrack	; F5EEC6  call 0xf427a0
	ld	a, (3215:16)	; F5EECA  ld A,(0x0c8f)
	ld	de, (3189:16)	; F5EECE  ld DE,(0x0c75)
	ld	(3216:16), de	; F5EED2  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F5EED6  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F5EEDA  cp (0x0d4a),0x00
	jrl	nz, MeasureInsert_InsertToTrack_Return	; F5EEDF  jrl NZ,0xf5f02b
	ld	(3258:16), iy	; F5EEE2  ld (0x0cba),IY
	ld	wa, (BStore_CursorBlock:16)	; F5EEE6  ld WA,(0x345c)
	ld	(3252:16), wa	; F5EEEA  ld (0x0cb4),WA
	ld	w, (3357:16)	; F5EEEE  ld W,(0x0d1d)
	ld	a, (3214:16)	; F5EEF2  ld A,(0x0c8e)
	ld	de, (3187:16)	; F5EEF6  ld DE,(0x0c73)
	ld	(3216:16), de	; F5EEFA  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F5EEFE  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F5EF02  cp (0x0d4a),0x00
	jrl	nz, MeasureInsert_InsertToTrack_Return	; F5EF07  jrl NZ,0xf5f02b
	ld	(3294:16), iy	; F5EF0A  ld (0x0cde),IY
	ld	wa, (BStore_CursorBlock:16)	; F5EF0E  ld WA,(0x345c)
	ld	(3292:16), wa	; F5EF12  ld (0x0cdc),WA
	ld	hl, wa	; F5EF16  ld HL,WA
	ld	iy, (3294:16)	; F5EF18  ld IY,(0x0cde)
	call	T_F42798	; F5EF1C  call 0xf42798
	cp	(BStore_ErrorCode:16), 0x00	; F5EF20  cp (0x0d4a),0x00
	jr	z, MeasureInsert_InsertToTrack_Skip	; F5EF25  jr Z,0xf5ef39
	cp	(BStore_ErrorCode:16), 0x07	; F5EF27  cp (0x0d4a),0x07
	jrl	nz, MeasureInsert_InsertToTrack_Return	; F5EF2C  jrl NZ,0xf5f02b
	or	(0x0c8a:16), 0x08	; F5EF2F  or (0x0c8a),0x08
	ld	(BStore_ErrorCode:16), 0	; F5EF34  ld (0x0d4a),0x00
MeasureInsert_InsertToTrack_Skip:
	ld	(3282:16), iy	; F5EF39  ld (0x0cd2),IY
	ld	wa, (BStore_CursorBlock:16)	; F5EF3D  ld WA,(0x345c)
	ld	(3280:16), wa	; F5EF41  ld (0x0cd0),WA
	ld	wa, (3276:16)	; F5EF45  ld WA,(0x0ccc)
	ld	(BStore_LinkBlock:16), wa	; F5EF49  ld (0x0cc0),WA
	ld	wa, (3278:16)	; F5EF4D  ld WA,(0x0cce)
	ld	(BStore_LastBlockUsed:16), wa	; F5EF51  ld (0x0cc6),WA
	call	T_BStore_AllocChain	; F5EF55  call 0xf427b4
	cp	(BStore_ErrorCode:16), 0x00	; F5EF59  cp (0x0d4a),0x00
	jrl	nz, MeasureInsert_InsertToTrack_Return	; F5EF5E  jrl NZ,0xf5f02b
	ld	(3300:16), de	; F5EF61  ld (0x0ce4),DE
	ld	wa, (BStore_LastBlockFree:16)	; F5EF65  ld WA,(0x0d08)
	ld	(3302:16), wa	; F5EF69  ld (0x0ce6),WA
	ld	ix, wa	; F5EF6D  ld IX,WA
	ld	wa, (3300:16)	; F5EF6F  ld WA,(0x0ce4)
	ld	(3159:16), wa	; F5EF73  ld (0x0c57),WA
	call	T_BStore_SaveCursor	; F5EF77  call 0xf427b0
	ld	wa, (3276:16)	; F5EF7B  ld WA,(0x0ccc)
	ld	(3169:16), wa	; F5EF7F  ld (0x0c61),WA
	ld	wa, (3278:16)	; F5EF83  ld WA,(0x0cce)
	ld	(3175:16), wa	; F5EF87  ld (0x0c67),WA
	ld	wa, (3300:16)	; F5EF8B  ld WA,(0x0ce4)
	ld	(3159:16), wa	; F5EF8F  ld (0x0c57),WA
	ld	wa, (3302:16)	; F5EF93  ld WA,(0x0ce6)
	ld	(3165:16), wa	; F5EF97  ld (0x0c5d),WA
	ld	de, (3252:16)	; F5EF9B  ld DE,(0x0cb4)
	ld	wa, (3258:16)	; F5EF9F  ld WA,(0x0cba)
	ld	(3179:16), wa	; F5EFA3  ld (0x0c6b),WA
	call	T_BStore_CopyRangeBackward	; F5EFA7  call 0xf4277c
	cp	(BStore_ErrorCode:16), 0x00	; F5EFAB  cp (0x0d4a),0x00
	jrl	nz, MeasureInsert_InsertToTrack_Return	; F5EFB0  jrl NZ,0xf5f02b
	ld	wa, (3280:16)	; F5EFB3  ld WA,(0x0cd0)
	ld	(3169:16), wa	; F5EFB7  ld (0x0c61),WA
	ld	wa, (3282:16)	; F5EFBB  ld WA,(0x0cd2)
	ld	(3175:16), wa	; F5EFBF  ld (0x0c67),WA
	ld	(3165:16), ix	; F5EFC3  ld (0x0c5d),IX
	cp	ix, 5:i3	; F5EFC7  cp IX,5
	jr	nc, MeasureInsert_InsertToTrack_Skip2	; F5EFC9  jr NC,0xf5efde
	ld	hl, (3159:16)	; F5EFCB  ld HL,(0x0c57)
	call	T_BStore_SeekBlock	; F5EFCF  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5EFD3  ld XHL,(0x126e)
	ld	wa, (xhl+1)	; F5EFD7  ld WA,(XHL+0x01)
	ld	(3159:16), wa	; F5EFDA  ld (0x0c57),WA
MeasureInsert_InsertToTrack_Skip2:
	ld	wa, (3159:16)	; F5EFDE  ld WA,(0x0c57)
	ld	(3272:16), wa	; F5EFE2  ld (0x0cc8),WA
	ld	wa, (3165:16)	; F5EFE6  ld WA,(0x0c5d)
	ld	(3274:16), wa	; F5EFEA  ld (0x0cca),WA
	ld	de, (3292:16)	; F5EFEE  ld DE,(0x0cdc)
	ld	wa, (3294:16)	; F5EFF2  ld WA,(0x0cde)
	ld	(3179:16), wa	; F5EFF6  ld (0x0c6b),WA
	call	T_BStore_CopyRangeBackward	; F5EFFA  call 0xf4277c
	cp	(BStore_ErrorCode:16), 0x00	; F5EFFE  cp (0x0d4a),0x00
	jr	z, MeasureInsert_InsertToTrack_Skip3	; F5F003  jr Z,0xf5f007
	jr	MeasureInsert_InsertToTrack_Return	; F5F005  jr T,0xf5f02b
MeasureInsert_InsertToTrack_Skip3:
	bit	3, (0x0c8a:16)	; F5F007  bit 3,(0x0c8a)
	jr	nz, MeasureInsert_InsertToTrack_Skip4	; F5F00B  jr NZ,0xf5f00f
	jr	MeasureInsert_InsertToTrack_Return	; F5F00D  jr T,0xf5f02b
MeasureInsert_InsertToTrack_Skip4:
	ld	ix, (3274:16)	; F5F00F  ld IX,(0x0cca)
	ld	wa, (3272:16)	; F5F013  ld WA,(0x0cc8)
	ld	(3159:16), wa	; F5F017  ld (0x0c57),WA
	call	T_BStore_SaveCursor	; F5F01B  call 0xf427b0
	call	T_BStore_TruncateChainAfterBlock	; F5F01F  call 0xf42794
	cp	(BStore_ErrorCode:16), 0x00	; F5F023  cp (0x0d4a),0x00
	nop	; F5F028  nop
	nop	; F5F029  nop
	nop	; F5F02A  nop
MeasureInsert_InsertToTrack_Return:
	ret	; F5F02B  ret

; --------------------------------------------------------------------------
; MeasureInsert_InsertWithinTrack
; Called from: in-module: 0xF5ED9C 0xF5EE2E
; Touches: (0x0C57) (0x0C5D) (0x0C61) (0x0C67) (0x0C6B) (0x0C73) (0x0C75)
;          (0x0C8A) (0x0C8E) (0x0C8F) +21 more
; Calls:   MeasureInsert_InsertToTrack T_BStore_ValidateSavedCursor T_Seq_FindMasterTrack T_BStore_SeekMeasure T_F42798 T_BStore_AllocChain T_BStore_SaveCursor
;          T_BStore_CopyRangeBackward T_BStore_MovePosForward T_F42778 T_BStore_SeekBlock T_BStore_TruncateChainAfterBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5F02C is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; MeasureInsert_InsertWithinTrack: MEASURE INSERT when source and destination are the same track (or ALL): if the
;   source starts at or before the insert point it is MeasureInsert_InsertToTrack; otherwise it opens the gap first,
;   moves both source positions up by the inserted length (BStore_MovePosForward twice) and copies the shifted source
;   forward into the gap (T_F42778). Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
MeasureInsert_InsertWithinTrack:
	xor	wa, wa	; F5F02C  xor WA,WA
	ld	wa, (3187:16)	; F5F02E  ld WA,(0x0c73)
	cp	wa, (0x0c75:16)	; F5F032  cp WA,(0x0c75)
	jr	ugt, MeasureInsert_InsertWithinTrack_Skip19	; F5F036  jr UGT,0xf5f03e
	calr	MeasureInsert_InsertToTrack	; F5F038  calr 0xf5ee9a
	jrl	MeasureInsert_InsertWithinTrack_Return	; F5F03B  jrl T,0xf5f220
MeasureInsert_InsertWithinTrack_Skip19:
	and	(0x0c8a:16), 0xf7	; F5F03E  and (0x0c8a),0xf7
	ld	(BStore_ErrorCode:16), 0	; F5F043  ld (0x0d4a),0x00
	xor	wa, wa	; F5F048  xor WA,WA
	ld	a, (3215:16)	; F5F04A  ld A,(0x0c8f)
	ld	(3354:16), wa	; F5F04E  ld (0x0d1a),WA
	call	T_BStore_ValidateSavedCursor	; F5F052  call 0xf42770
	cp	(BStore_ErrorCode:16), 0x00	; F5F056  cp (0x0d4a),0x00
	jrl	nz, MeasureInsert_InsertWithinTrack_Return	; F5F05B  jrl NZ,0xf5f220
	ld	(3278:16), iy	; F5F05E  ld (0x0cce),IY
	ld	wa, (BStore_CursorBlock:16)	; F5F062  ld WA,(0x345c)
	ld	(3276:16), wa	; F5F066  ld (0x0ccc),WA
	call	T_Seq_FindMasterTrack	; F5F06A  call 0xf427a0
	ld	a, (3215:16)	; F5F06E  ld A,(0x0c8f)
	ld	de, (3189:16)	; F5F072  ld DE,(0x0c75)
	ld	(3216:16), de	; F5F076  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F5F07A  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F5F07E  cp (0x0d4a),0x00
	jrl	nz, MeasureInsert_InsertWithinTrack_Return	; F5F083  jrl NZ,0xf5f220
	ld	(3258:16), iy	; F5F086  ld (0x0cba),IY
	ld	wa, (BStore_CursorBlock:16)	; F5F08A  ld WA,(0x345c)
	ld	(3252:16), wa	; F5F08E  ld (0x0cb4),WA
	ld	w, (3357:16)	; F5F092  ld W,(0x0d1d)
	ld	a, (3214:16)	; F5F096  ld A,(0x0c8e)
	ld	de, (3187:16)	; F5F09A  ld DE,(0x0c73)
	ld	(3216:16), de	; F5F09E  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F5F0A2  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F5F0A6  cp (0x0d4a),0x00
	jrl	nz, MeasureInsert_InsertWithinTrack_Return	; F5F0AB  jrl NZ,0xf5f220
	ld	(3294:16), iy	; F5F0AE  ld (0x0cde),IY
	ld	wa, (BStore_CursorBlock:16)	; F5F0B2  ld WA,(0x345c)
	ld	(3292:16), wa	; F5F0B6  ld (0x0cdc),WA
	ld	hl, wa	; F5F0BA  ld HL,WA
	ld	iy, (3294:16)	; F5F0BC  ld IY,(0x0cde)
	call	T_F42798	; F5F0C0  call 0xf42798
	cp	(BStore_ErrorCode:16), 0x00	; F5F0C4  cp (0x0d4a),0x00
	jr	z, MeasureInsert_InsertWithinTrack_Skip	; F5F0C9  jr Z,0xf5f0dd
	cp	(BStore_ErrorCode:16), 0x07	; F5F0CB  cp (0x0d4a),0x07
	jrl	nz, MeasureInsert_InsertWithinTrack_Return	; F5F0D0  jrl NZ,0xf5f220
	or	(0x0c8a:16), 0x08	; F5F0D3  or (0x0c8a),0x08
	ld	(BStore_ErrorCode:16), 0	; F5F0D8  ld (0x0d4a),0x00
MeasureInsert_InsertWithinTrack_Skip:
	ld	(3282:16), iy	; F5F0DD  ld (0x0cd2),IY
	ld	wa, (BStore_CursorBlock:16)	; F5F0E1  ld WA,(0x345c)
	ld	(3280:16), wa	; F5F0E5  ld (0x0cd0),WA
	ld	wa, (3276:16)	; F5F0E9  ld WA,(0x0ccc)
	ld	(BStore_LinkBlock:16), wa	; F5F0ED  ld (0x0cc0),WA
	ld	wa, (3278:16)	; F5F0F1  ld WA,(0x0cce)
	ld	(BStore_LastBlockUsed:16), wa	; F5F0F5  ld (0x0cc6),WA
	call	T_BStore_AllocChain	; F5F0F9  call 0xf427b4
	cp	(BStore_ErrorCode:16), 0x00	; F5F0FD  cp (0x0d4a),0x00
	jrl	nz, MeasureInsert_InsertWithinTrack_Return	; F5F102  jrl NZ,0xf5f220
	ld	(3300:16), de	; F5F105  ld (0x0ce4),DE
	ld	wa, (BStore_LastBlockFree:16)	; F5F109  ld WA,(0x0d08)
	ld	(3302:16), wa	; F5F10D  ld (0x0ce6),WA
	ld	ix, wa	; F5F111  ld IX,WA
	ld	wa, (3300:16)	; F5F113  ld WA,(0x0ce4)
	ld	(3159:16), wa	; F5F117  ld (0x0c57),WA
	call	T_BStore_SaveCursor	; F5F11B  call 0xf427b0
	ld	wa, (3276:16)	; F5F11F  ld WA,(0x0ccc)
	ld	(3169:16), wa	; F5F123  ld (0x0c61),WA
	ld	wa, (3278:16)	; F5F127  ld WA,(0x0cce)
	ld	(3175:16), wa	; F5F12B  ld (0x0c67),WA
	ld	wa, (3300:16)	; F5F12F  ld WA,(0x0ce4)
	ld	(3159:16), wa	; F5F133  ld (0x0c57),WA
	ld	wa, (3302:16)	; F5F137  ld WA,(0x0ce6)
	ld	(3165:16), wa	; F5F13B  ld (0x0c5d),WA
	ld	de, (3252:16)	; F5F13F  ld DE,(0x0cb4)
	ld	wa, (3258:16)	; F5F143  ld WA,(0x0cba)
	ld	(3179:16), wa	; F5F147  ld (0x0c6b),WA
	call	T_BStore_CopyRangeBackward	; F5F14B  call 0xf4277c
	cp	(BStore_ErrorCode:16), 0x00	; F5F14F  cp (0x0d4a),0x00
	jrl	nz, MeasureInsert_InsertWithinTrack_Return	; F5F154  jrl NZ,0xf5f220
	ld	wa, (3292:16)	; F5F157  ld WA,(0x0cdc)
	ld	(3304:16), wa	; F5F15B  ld (0x0ce8),WA
	ld	wa, (3294:16)	; F5F15F  ld WA,(0x0cde)
	ld	(3306:16), wa	; F5F163  ld (0x0cea),WA
	call	T_BStore_MovePosForward	; F5F167  call 0xf42780
	cp	(BStore_ErrorCode:16), 0x00	; F5F16B  cp (0x0d4a),0x00
	jrl	nz, MeasureInsert_InsertWithinTrack_Return	; F5F170  jrl NZ,0xf5f220
	ld	wa, (3306:16)	; F5F173  ld WA,(0x0cea)
	ld	(3294:16), wa	; F5F177  ld (0x0cde),WA
	ld	wa, (3304:16)	; F5F17B  ld WA,(0x0ce8)
	ld	(3292:16), wa	; F5F17F  ld (0x0cdc),WA
	ld	wa, (3280:16)	; F5F183  ld WA,(0x0cd0)
	ld	(3304:16), wa	; F5F187  ld (0x0ce8),WA
	ld	wa, (3282:16)	; F5F18B  ld WA,(0x0cd2)
	ld	(3306:16), wa	; F5F18F  ld (0x0cea),WA
	call	T_BStore_MovePosForward	; F5F193  call 0xf42780
	cp	(BStore_ErrorCode:16), 0x00	; F5F197  cp (0x0d4a),0x00
	jrl	nz, MeasureInsert_InsertWithinTrack_Return	; F5F19C  jrl NZ,0xf5f220
	ld	wa, (3306:16)	; F5F19F  ld WA,(0x0cea)
	ld	(3282:16), wa	; F5F1A3  ld (0x0cd2),WA
	ld	wa, (3304:16)	; F5F1A7  ld WA,(0x0ce8)
	ld	(3280:16), wa	; F5F1AB  ld (0x0cd0),WA
	ld	wa, (3292:16)	; F5F1AF  ld WA,(0x0cdc)
	ld	(3169:16), wa	; F5F1B3  ld (0x0c61),WA
	ld	wa, (3294:16)	; F5F1B7  ld WA,(0x0cde)
	ld	(3175:16), wa	; F5F1BB  ld (0x0c67),WA
	ld	wa, (3252:16)	; F5F1BF  ld WA,(0x0cb4)
	ld	(3159:16), wa	; F5F1C3  ld (0x0c57),WA
	ld	wa, (3258:16)	; F5F1C7  ld WA,(0x0cba)
	ld	(3165:16), wa	; F5F1CB  ld (0x0c5d),WA
	ld	de, (3280:16)	; F5F1CF  ld DE,(0x0cd0)
	ld	wa, (3282:16)	; F5F1D3  ld WA,(0x0cd2)
	ld	(3179:16), wa	; F5F1D7  ld (0x0c6b),WA
	call	T_F42778	; F5F1DB  call 0xf42778
	cp	(BStore_ErrorCode:16), 0x00	; F5F1DF  cp (0x0d4a),0x00
	jr	nz, MeasureInsert_InsertWithinTrack_Return	; F5F1E4  jr NZ,0xf5f220
	bit	3, (0x0c8a:16)	; F5F1E6  bit 3,(0x0c8a)
	jr	nz, MeasureInsert_InsertWithinTrack_Skip2	; F5F1EA  jr NZ,0xf5f1ee
	jr	MeasureInsert_InsertWithinTrack_Return	; F5F1EC  jr T,0xf5f220
MeasureInsert_InsertWithinTrack_Skip2:
	cp	ix, 5:i3	; F5F1EE  cp IX,5
	jr	nz, MeasureInsert_InsertWithinTrack_Skip3	; F5F1F0  jr NZ,0xf5f20e
	ld	hl, (3159:16)	; F5F1F2  ld HL,(0x0c57)
	call	T_BStore_SeekBlock	; F5F1F6  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5F1FA  ld XHL,(0x126e)
	ld	hl, (xhl+1)	; F5F1FE  ld HL,(XHL+0x01)
	cp	hl, 0:i3	; F5F201  cp HL,0
	jr	z, MeasureInsert_InsertWithinTrack_Return	; F5F203  jr Z,0xf5f220
	ld	(3159:16), hl	; F5F205  ld (0x0c57),HL
	ldw	ix, 255	; F5F209  ld IX,0x00ff
	jr	MeasureInsert_InsertWithinTrack_Join8	; F5F20C  jr T,0xf5f210
MeasureInsert_InsertWithinTrack_Skip3:
	dec	1, ix	; F5F20E  dec 1,IX
MeasureInsert_InsertWithinTrack_Join8:
	call	T_BStore_SaveCursor	; F5F210  call 0xf427b0
	call	T_BStore_TruncateChainAfterBlock	; F5F214  call 0xf42794
	cp	(BStore_ErrorCode:16), 0x00	; F5F218  cp (0x0d4a),0x00
	nop	; F5F21D  nop
	nop	; F5F21E  nop
	nop	; F5F21F  nop
MeasureInsert_InsertWithinTrack_Return:
	ret	; F5F220  ret

; --------------------------------------------------------------------------
; SongEdit_CopyMeasures
; Called from: T_SongEdit_CopyMeasures (x2)
; Touches: (0x0C70) (0x0C71) (0x0C73) (0x0C75) (0x0C77) (0x0C83) (0x0C8A)
;          (0x0C8E) (0x0C8F) (0x0CA2) +8 more  |  0x603422
; Calls:   T_BStore_LoadGeometry T_BStore_OpenChainAtSavedCursor SongEdit_CopyMeasuresToTrack sub_F5EE95 T_SongEdit_InsertTimeSigsForMeasureCopy SongEdit_CopyMeasuresWithinTrack
;          T_SongEdit_CheckFreeBlocksForCopy T_BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_36 T_F40A1C
; Evidence: thunk slot T_SongEdit_CopyMeasures holds `jp 0x00F5F221`, and 0xF5F221 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_CopyMeasures: The MEASURE COPY job: source track (0x0C70) (or 0x7F, all tracks), destination track
;   (0x0C71), source measure (0x0C73), destination measure (0x0C75), count (0x0C77), all range-checked (error 3);
;   error 9 when only one side is the master track (part 0x20); per track SongEdit_CopyMeasuresToTrack copies. Run by
;   MeasureC0py_LcdKeyRow1, which stages the fields, and by MeasureC0py_RepeatCopy. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_n.json)
SongEdit_CopyMeasures:		; <- T_SongEdit_CopyMeasures
	and	(0x0d45:16), 0xfc	; F5F221  and (0x0d45),0xfc
	and	(0x0d46:16), 0xfa	; F5F226  and (0x0d46),0xfa
	call	T_BStore_LoadGeometry	; F5F22B  call 0xf427c4
	ld	a, (3184:16)	; F5F22F  ld A,(0x0c70)
	cp	a, 1:i3	; F5F233  cp A,1
	jr	c, SongEdit_CopyMeasures_Skip4	; F5F235  jr C,0xf5f27a
	cp	a, 127	; F5F237  cp A,0x7f
	jr	z, SongEdit_CopyMeasures_Skip20	; F5F23A  jr Z,0xf5f250
	cp	a, (0x0ca2:16)	; F5F23C  cp A,(0x0ca2)
	jr	ugt, SongEdit_CopyMeasures_Skip4	; F5F240  jr UGT,0xf5f27a
	ld	a, (3185:16)	; F5F242  ld A,(0x0c71)
	cp	a, 1:i3	; F5F246  cp A,1
	jr	c, SongEdit_CopyMeasures_Skip4	; F5F248  jr C,0xf5f27a
	cp	a, (0x0ca2:16)	; F5F24A  cp A,(0x0ca2)
	jr	ugt, SongEdit_CopyMeasures_Skip4	; F5F24E  jr UGT,0xf5f27a
SongEdit_CopyMeasures_Skip20:
	ld	wa, (3187:16)	; F5F250  ld WA,(0x0c73)
	cp	wa, 1:i3	; F5F254  cp WA,1
	jr	c, SongEdit_CopyMeasures_Skip4	; F5F256  jr C,0xf5f27a
	cp	wa, 999	; F5F258  cp WA,0x03e7
	jr	ugt, SongEdit_CopyMeasures_Skip4	; F5F25C  jr UGT,0xf5f27a
	ld	wa, (3191:16)	; F5F25E  ld WA,(0x0c77)
	cp	wa, 1:i3	; F5F262  cp WA,1
	jr	c, SongEdit_CopyMeasures_Skip4	; F5F264  jr C,0xf5f27a
	cp	wa, 999	; F5F266  cp WA,0x03e7
	jr	ugt, SongEdit_CopyMeasures_Skip4	; F5F26A  jr UGT,0xf5f27a
	ld	wa, (3189:16)	; F5F26C  ld WA,(0x0c75)
	cp	wa, 1:i3	; F5F270  cp WA,1
	jr	c, SongEdit_CopyMeasures_Skip4	; F5F272  jr C,0xf5f27a
	cp	wa, 999	; F5F274  cp WA,0x03e7
	jr	ule, SongEdit_CopyMeasures_Skip5	; F5F278  jr ULE,0xf5f282
SongEdit_CopyMeasures_Skip4:
	ld	(BStore_ErrorCode:16), 3	; F5F27A  ld (0x0d4a),0x03
	jrl	SongEdit_CopyMeasures_Join7	; F5F27F  jrl T,0xf5f46d
SongEdit_CopyMeasures_Skip5:
	ld	(BStore_ErrorCode:16), 0	; F5F282  ld (0x0d4a),0x00
	and	(0x0c8a:16), 0xbf	; F5F287  and (0x0c8a),0xbf
	cp	(0x0c70:16), 0x7f	; F5F28C  cp (0x0c70),0x7f
	jr	nz, SongEdit_CopyMeasures_Skip6	; F5F291  jr NZ,0xf5f296
	jrl	SongEdit_CopyMeasures_Join4	; F5F293  jrl T,0xf5f3b2
SongEdit_CopyMeasures_Skip6:
	xor	hl, hl	; F5F296  xor HL,HL
	ld	l, (3184:16)	; F5F298  ld L,(0x0c70)
	ld	a, (3185:16)	; F5F29C  ld A,(0x0c71)
	cp	l, a	; F5F2A0  cp L,A
	jr	z, SongEdit_CopyMeasures_Skip7	; F5F2A2  jr Z,0xf5f2a6
	jr	SongEdit_CopyMeasures_Join	; F5F2A4  jr T,0xf5f2d3
SongEdit_CopyMeasures_Skip7:
	dec	1, l	; F5F2A6  dec 1,L
	push	xix	; F5F2A8  push XIX
	ld	xix, BStore_TrackToPart	; F5F2A9  ld XIX,0x00603422
	ld	a, (xix+hl)	; F5F2AE  ld A,(XIX+HL)
	pop	xix	; F5F2B3  pop XIX
	cp	a, 32	; F5F2B4  cp A,0x20
	jr	nz, SongEdit_CopyMeasures_Skip8	; F5F2B7  jr NZ,0xf5f2d0
	or	(0x0c8a:16), 0x40	; F5F2B9  or (0x0c8a),0x40
	xor	wa, wa	; F5F2BE  xor WA,WA
	ld	a, (3184:16)	; F5F2C0  ld A,(0x0c70)
	call	T_BStore_OpenChainAtSavedCursor	; F5F2C4  call 0xf42790
	cp	(BStore_ErrorCode:16), 0x00	; F5F2C8  cp (0x0d4a),0x00
	jrl	nz, SongEdit_CopyMeasures_Join7	; F5F2CD  jrl NZ,0xf5f46d
SongEdit_CopyMeasures_Skip8:
	jrl	SongEdit_CopyMeasures_Join3	; F5F2D0  jrl T,0xf5f379
SongEdit_CopyMeasures_Join:
	xor	hl, hl	; F5F2D3  xor HL,HL
	ld	l, (3184:16)	; F5F2D5  ld L,(0x0c70)
	dec	1, l	; F5F2D9  dec 1,L
	push	xix	; F5F2DB  push XIX
	ld	xix, BStore_TrackToPart	; F5F2DC  ld XIX,0x00603422
	ld	l, (xix+hl)	; F5F2E1  ld L,(XIX+HL)
	pop	xix	; F5F2E6  pop XIX
	cp	l, 32	; F5F2E7  cp L,0x20
	jr	z, SongEdit_CopyMeasures_Skip9	; F5F2EA  jr Z,0xf5f305
	ld	l, (3185:16)	; F5F2EC  ld L,(0x0c71)
	dec	1, l	; F5F2F0  dec 1,L
	push	xix	; F5F2F2  push XIX
	ld	xix, BStore_TrackToPart	; F5F2F3  ld XIX,0x00603422
	ld	l, (xix+hl)	; F5F2F8  ld L,(XIX+HL)
	pop	xix	; F5F2FD  pop XIX
	cp	l, 32	; F5F2FE  cp L,0x20
	jr	z, SongEdit_CopyMeasures_Skip9	; F5F301  jr Z,0xf5f305
	jr	SongEdit_CopyMeasures_Join2	; F5F303  jr T,0xf5f30d
SongEdit_CopyMeasures_Skip9:
	ld	(BStore_ErrorCode:16), 9	; F5F305  ld (0x0d4a),0x09
	jrl	SongEdit_CopyMeasures_Join7	; F5F30A  jrl T,0xf5f46d
SongEdit_CopyMeasures_Join2:
	ld	a, (3184:16)	; F5F30D  ld A,(0x0c70)
	ld	(3214:16), a	; F5F311  ld (0x0c8e),A
	ld	a, (3185:16)	; F5F315  ld A,(0x0c71)
	ld	(3215:16), a	; F5F319  ld (0x0c8f),A
	calr	SongEdit_CopyMeasuresToTrack	; F5F31D  calr 0xf5f476
	cp	(BStore_ErrorCode:16), 0x00	; F5F320  cp (0x0d4a),0x00
	jr	nz, SongEdit_CopyMeasures_Skip10	; F5F325  jr NZ,0xf5f376
	xor	hl, hl	; F5F327  xor HL,HL
	ld	l, (3184:16)	; F5F329  ld L,(0x0c70)
	dec	1, hl	; F5F32D  dec 1,HL
	push	xix	; F5F32F  push XIX
	ld	xix, BStore_TrackToPart	; F5F330  ld XIX,0x00603422
	ld	a, (xix+hl)	; F5F335  ld A,(XIX+HL)
	ld	l, (3185:16)	; F5F33A  ld L,(0x0c71)
	dec	1, hl	; F5F33E  dec 1,HL
	ld	xix, BStore_TrackToPart	; F5F340  ld XIX,0x00603422
	cp	a, (xix+hl)	; F5F345  cp A,(XIX+HL)
	pop	xix	; F5F34A  pop XIX
	jr	z, SongEdit_CopyMeasures_Skip10	; F5F34B  jr Z,0xf5f376
	ld	(3203:16), l	; F5F34D  ld (0x0c83),L
	push	xix	; F5F351  push XIX
	ld	xix, BStore_TrackToPart	; F5F352  ld XIX,0x00603422
	ld	l, (xix+hl)	; F5F357  ld L,(XIX+HL)
	ld	(3535:16), l	; F5F35C  ld (0x0dcf),L
	ld	xix, IdentityMap_0_31	; F5F360  ld XIX,0x00f5ee75
	ld	l, (xix+hl)	; F5F365  ld L,(XIX+HL)
	ld	(3396:16), l	; F5F36A  ld (0x0d44),L
	pop	xix	; F5F36E  pop XIX
	ld	(3508:16), a	; F5F36F  ld (0x0db4),A
	calr	sub_F5EE95	; F5F373  calr 0xf5ee95
SongEdit_CopyMeasures_Skip10:
	jrl	SongEdit_CopyMeasures_Join7	; F5F376  jrl T,0xf5f46d
SongEdit_CopyMeasures_Join3:
	ld	a, (3184:16)	; F5F379  ld A,(0x0c70)
	ld	(3214:16), a	; F5F37D  ld (0x0c8e),A
	ld	(3215:16), a	; F5F381  ld (0x0c8f),A
	bit	6, (0x0c8a:16)	; F5F385  bit 6,(0x0c8a)
	jr	z, SongEdit_CopyMeasures_Skip11	; F5F389  jr Z,0xf5f3ac
	xor	hl, hl	; F5F38B  xor HL,HL
	ld	l, a	; F5F38D  ld L,A
	dec	1, hl	; F5F38F  dec 1,HL
	push	xix	; F5F391  push XIX
	ld	xix, BStore_TrackToPart	; F5F392  ld XIX,0x00603422
	cp	(xix+hl), 0x20	; F5F397  cp (XIX+HL),0x20
	pop	xix	; F5F39D  pop XIX
	jr	nz, SongEdit_CopyMeasures_Skip11	; F5F39E  jr NZ,0xf5f3ac
	call	T_SongEdit_InsertTimeSigsForMeasureCopy	; F5F3A0  call 0xf432c8
	cp	(BStore_ErrorCode:16), 0x00	; F5F3A4  cp (0x0d4a),0x00
	jrl	nz, SongEdit_CopyMeasures_Join7	; F5F3A9  jrl NZ,0xf5f46d
SongEdit_CopyMeasures_Skip11:
	calr	SongEdit_CopyMeasuresWithinTrack	; F5F3AC  calr 0xf5fb04
	jrl	SongEdit_CopyMeasures_Join7	; F5F3AF  jrl T,0xf5f46d
SongEdit_CopyMeasures_Join4:
	xor	hl, hl	; F5F3B2  xor HL,HL
SongEdit_CopyMeasures_Join5:
	cp	l, (0x0ca3:16)	; F5F3B4  cp L,(0x0ca3)
	jr	ugt, SongEdit_CopyMeasures_Skip13	; F5F3B8  jr UGT,0xf5f3e8
	push	xix	; F5F3BA  push XIX
	ld	xix, BStore_TrackToPart	; F5F3BB  ld XIX,0x00603422
	ld	a, (xix+hl)	; F5F3C0  ld A,(XIX+HL)
	pop	xix	; F5F3C5  pop XIX
	cp	a, 32	; F5F3C6  cp A,0x20
	jr	nz, SongEdit_CopyMeasures_Skip12	; F5F3C9  jr NZ,0xf5f3e4
	or	(0x0c8a:16), 0x40	; F5F3CB  or (0x0c8a),0x40
	pushw	hl	; F5F3D0  push HL
	ld	wa, hl	; F5F3D1  ld WA,HL
	inc	1, wa	; F5F3D3  inc 1,WA
	call	T_BStore_OpenChainAtSavedCursor	; F5F3D5  call 0xf42790
	popw	hl	; F5F3D9  pop HL
	cp	(BStore_ErrorCode:16), 0x00	; F5F3DA  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasures_Skip12	; F5F3DF  jr Z,0xf5f3e4
	jrl	SongEdit_CopyMeasures_Join7	; F5F3E1  jrl T,0xf5f46d
SongEdit_CopyMeasures_Skip12:
	inc	1, hl	; F5F3E4  inc 1,HL
	jr	SongEdit_CopyMeasures_Join5	; F5F3E6  jr T,0xf5f3b4
SongEdit_CopyMeasures_Skip13:
	call	T_SongEdit_CheckFreeBlocksForCopy	; F5F3E8  call 0xf427d8
	cp	(BStore_ErrorCode:16), 0x00	; F5F3EC  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasures_Skip14	; F5F3F1  jr Z,0xf5f3f6
	jrl	SongEdit_CopyMeasures_Join7	; F5F3F3  jrl T,0xf5f46d
SongEdit_CopyMeasures_Skip14:
	ld	(3352:16), 0	; F5F3F6  ld (0x0d18),0x00
	ld	a, 1:opc	; F5F3FB  ld A,0x01
SongEdit_CopyMeasures_Join6:
	cp	a, (0x0ca2:16)	; F5F3FD  cp A,(0x0ca2)
	jr	ugt, SongEdit_CopyMeasures_Skip18	; F5F401  jr UGT,0xf5f465
	ld	(3214:16), a	; F5F403  ld (0x0c8e),A
	ld	(3215:16), a	; F5F407  ld (0x0c8f),A
	bit	6, (0x0c8a:16)	; F5F40B  bit 6,(0x0c8a)
	jr	z, SongEdit_CopyMeasures_Skip15	; F5F40F  jr Z,0xf5f438
	xor	hl, hl	; F5F411  xor HL,HL
	ld	l, a	; F5F413  ld L,A
	dec	1, hl	; F5F415  dec 1,HL
	push	xix	; F5F417  push XIX
	ld	xix, BStore_TrackToPart	; F5F418  ld XIX,0x00603422
	cp	(xix+hl), 0x20	; F5F41D  cp (XIX+HL),0x20
	pop	xix	; F5F423  pop XIX
	jr	nz, SongEdit_CopyMeasures_Skip15	; F5F424  jr NZ,0xf5f438
	pushw	wa	; F5F426  push WA
	ld	(BStore_ErrorCode:16), 0	; F5F427  ld (0x0d4a),0x00
	call	T_SongEdit_InsertTimeSigsForMeasureCopy	; F5F42C  call 0xf432c8
	popw	wa	; F5F430  pop WA
	cp	(BStore_ErrorCode:16), 0x00	; F5F431  cp (0x0d4a),0x00
	jr	nz, SongEdit_CopyMeasures_Skip16	; F5F436  jr NZ,0xf5f43d
SongEdit_CopyMeasures_Skip15:
	pushw	wa	; F5F438  push WA
	calr	SongEdit_CopyMeasuresWithinTrack	; F5F439  calr 0xf5fb04
	popw	wa	; F5F43C  pop WA
SongEdit_CopyMeasures_Skip16:
	cp	(BStore_ErrorCode:16), 0x00	; F5F43D  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasures_Skip17	; F5F442  jr Z,0xf5f461
	cp	(BStore_ErrorCode:16), 0x01	; F5F444  cp (0x0d4a),0x01
	jr	z, SongEdit_CopyMeasures_Skip17	; F5F449  jr Z,0xf5f461
	cp	(BStore_ErrorCode:16), 0x08	; F5F44B  cp (0x0d4a),0x08
	jr	z, SongEdit_CopyMeasures_Skip17	; F5F450  jr Z,0xf5f461
	cp	(0x0d18:16), 0x00	; F5F452  cp (0x0d18),0x00
	jr	nz, SongEdit_CopyMeasures_Skip17	; F5F457  jr NZ,0xf5f461
	ld	l, (BStore_ErrorCode:16)	; F5F459  ld L,(0x0d4a)
	ld	(3352:16), l	; F5F45D  ld (0x0d18),L
SongEdit_CopyMeasures_Skip17:
	inc	1, a	; F5F461  inc 1,A
	jr	SongEdit_CopyMeasures_Join6	; F5F463  jr T,0xf5f3fd
SongEdit_CopyMeasures_Skip18:
	ld	a, (3352:16)	; F5F465  ld A,(0x0d18)
	ld	(BStore_ErrorCode:16), a	; F5F469  ld (0x0d4a),A
SongEdit_CopyMeasures_Join7:
	call	T_BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_36	; F5F46D  call 0xf42818
	call	T_F40A1C	; F5F471  call 0xf40a1c
	ret	; F5F475  ret

; --------------------------------------------------------------------------
; SongEdit_CopyMeasuresToTrack
; Called from: in-module: 0xF5F31D 0xF5FB16
; Touches: (0x0C57) (0x0C5D) (0x0C61) (0x0C67) (0x0C6B) (0x0C70) (0x0C71)
;          (0x0C73) (0x0C75) (0x0C8A) +32 more  |  0x000D50 0x000D70
;          0x60347E 0x6034A0 0x603500
; Calls:   T_BStore_OpenChain T_BStore_AllocBlock_Veneer T_BStore_SeekBlock T_BStore_ValidateSavedCursor T_Seq_FindMasterTrack T_BStore_SeekMeasure T_F42798
;          T_SongEdit_PadDestTrackToMeasure SongEdit_RestoreDestTrackEnd T_BStore_AllocChain T_BStore_SaveCursor T_BStore_CopyRangeBackward +4 more
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5F476 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_CopyMeasuresToTrack: MEASURE COPY core: copies measures (0x0C73)..+(0x0C77) of track (0x0C8E) over the same
;   number of measures of track (0x0C8F) from (0x0C75), creating the destination chain if it is empty and growing
;   (AllocChain + BStore_CopyRangeBackward) or shrinking (T_F42778) the destination range to the source's byte length;
;   a failure on a new chain clears it (SongEdit_ClearTrack). Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_q.json)
SongEdit_CopyMeasuresToTrack:
	and	(0x0c8a:16), 0xf7	; F5F476  and (0x0c8a),0xf7
	and	(0x0c8a:16), 0xef	; F5F47B  and (0x0c8a),0xef
	and	(0x0c8a:16), 0x7f	; F5F480  and (0x0c8a),0x7f
	ld	(BStore_ErrorCode:16), 0	; F5F485  ld (0x0d4a),0x00
	xor	wa, wa	; F5F48A  xor WA,WA
	ld	a, (3215:16)	; F5F48C  ld A,(0x0c8f)
	cp	a, (0x0c8e:16)	; F5F490  cp A,(0x0c8e)
	jrl	z, SongEdit_CopyMeasuresToTrack_Skip3	; F5F494  jrl Z,0xf5f51c
	call	T_BStore_OpenChain	; F5F497  call 0xf427ac
	cp	(BStore_ErrorCode:16), 0x00	; F5F49B  cp (0x0d4a),0x00
	jrl	z, SongEdit_CopyMeasuresToTrack_Skip3	; F5F4A0  jrl Z,0xf5f51c
	cp	(BStore_ErrorCode:16), 0x01	; F5F4A3  cp (0x0d4a),0x01
	jr	z, SongEdit_CopyMeasuresToTrack_Skip	; F5F4A8  jr Z,0xf5f4ad
	jrl	SongEdit_CopyMeasuresToTrack_Join9	; F5F4AA  jrl T,0xf5f9a6
SongEdit_CopyMeasuresToTrack_Skip:
	ld	(BStore_ErrorCode:16), 0	; F5F4AD  ld (0x0d4a),0x00
	cpw	(BStore_FreeCount:24), 0x0001	; F5F4B2  cp (0x6034ba),0x0001
	jr	nc, SongEdit_CopyMeasuresToTrack_Skip2	; F5F4B9  jr NC,0xf5f4c3
	ld	(BStore_ErrorCode:16), 5	; F5F4BB  ld (0x0d4a),0x05
	jrl	SongEdit_CopyMeasuresToTrack_Join9	; F5F4C0  jrl T,0xf5f9a6
SongEdit_CopyMeasuresToTrack_Skip2:
	call	T_BStore_AllocBlock_Veneer	; F5F4C3  call 0xf42884
	xor	hl, hl	; F5F4C7  xor HL,HL
	ld	l, (3215:16)	; F5F4C9  ld L,(0x0c8f)
	dec	1, hl	; F5F4CD  dec 1,HL
	ld	wa, hl	; F5F4CF  ld WA,HL
	push	xde	; F5F4D1  push XDE
	ld	xde, 6304928	; F5F4D2  ld XDE,0x006034a0
	ld	(xde+hl), 0x05	; F5F4D7  ld (XDE+HL),0x05
	sla	hl, 1	; F5F4DD  sla 0x01,HL
	ld	xde, 6304894	; F5F4E0  ld XDE,0x0060347e
	ld	(xde+hl), ix	; F5F4E5  ld (XDE+HL),IX
	ld	hl, wa	; F5F4EA  ld HL,WA
	muls	hl, 3	; F5F4EC  muls HL,0x0003
	ld	xde, 6305024	; F5F4F0  ld XDE,0x00603500
	or	(xde+hl), 0x80	; F5F4F5  or (XDE+HL),0x80
	inc	1, hl	; F5F4FB  inc 1,HL
	ld	(xde+hl), ix	; F5F4FD  ld (XDE+HL),IX
	pop	xde	; F5F502  pop XDE
	ld	hl, ix	; F5F503  ld HL,IX
	call	T_BStore_SeekBlock	; F5F505  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5F509  ld XHL,(0x126e)
	ldw	(xhl+1), 0x0000	; F5F50D  ld (XHL+0x01),0x0000
	ldw	(xhl+3), 0xffff	; F5F512  ld (XHL+0x03),0xffff
	or	(0x0c8a:16), 0x80	; F5F517  or (0x0c8a),0x80
SongEdit_CopyMeasuresToTrack_Skip3:
	xor	hl, hl	; F5F51C  xor HL,HL
	xor	wa, wa	; F5F51E  xor WA,WA
	ld	a, (3215:16)	; F5F520  ld A,(0x0c8f)
	ld	(3354:16), wa	; F5F524  ld (0x0d1a),WA
	call	T_BStore_ValidateSavedCursor	; F5F528  call 0xf42770
	cp	(BStore_ErrorCode:16), 0x00	; F5F52C  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresToTrack_Skip4	; F5F531  jr Z,0xf5f536
	jrl	SongEdit_CopyMeasuresToTrack_Join9	; F5F533  jrl T,0xf5f9a6
SongEdit_CopyMeasuresToTrack_Skip4:
	xor	hl, hl	; F5F536  xor HL,HL
	ld	l, (3215:16)	; F5F538  ld L,(0x0c8f)
	dec	1, hl	; F5F53C  dec 1,HL
	sla	hl, 1	; F5F53E  sla 0x01,HL
	ld	(3278:16), iy	; F5F541  ld (0x0cce),IY
	push	xix	; F5F545  push XIX
	ld	xix, 3440	; F5F546  ld XIX,0x00000d70
	ld	(xix+hl), iy	; F5F54B  ld (XIX+HL),IY
	ld	wa, (BStore_CursorBlock:16)	; F5F550  ld WA,(0x345c)
	ld	(3276:16), wa	; F5F554  ld (0x0ccc),WA
	ld	xix, 3408	; F5F558  ld XIX,0x00000d50
	ld	(xix+hl), wa	; F5F55D  ld (XIX+HL),WA
	pop	xix	; F5F562  pop XIX
	call	T_Seq_FindMasterTrack	; F5F563  call 0xf427a0
	ld	a, (3214:16)	; F5F567  ld A,(0x0c8e)
	ld	de, (3187:16)	; F5F56B  ld DE,(0x0c73)
	ld	(3216:16), de	; F5F56F  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F5F573  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F5F577  cp (0x0d4a),0x00
	jrl	nz, SongEdit_CopyMeasuresToTrack_Join9	; F5F57C  jrl NZ,0xf5f9a6
	ld	(3294:16), iy	; F5F57F  ld (0x0cde),IY
	ld	wa, (BStore_CursorBlock:16)	; F5F583  ld WA,(0x345c)
	ld	(3292:16), wa	; F5F587  ld (0x0cdc),WA
	ld	hl, wa	; F5F58B  ld HL,WA
	ld	iy, (3294:16)	; F5F58D  ld IY,(0x0cde)
	call	T_F42798	; F5F591  call 0xf42798
	cp	(BStore_ErrorCode:16), 0x00	; F5F595  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresToTrack_Skip5	; F5F59A  jr Z,0xf5f5ae
	cp	(BStore_ErrorCode:16), 0x07	; F5F59C  cp (0x0d4a),0x07
	jrl	nz, SongEdit_CopyMeasuresToTrack_Join9	; F5F5A1  jrl NZ,0xf5f9a6
	or	(0x0c8a:16), 0x08	; F5F5A4  or (0x0c8a),0x08
	ld	(BStore_ErrorCode:16), 0	; F5F5A9  ld (0x0d4a),0x00
SongEdit_CopyMeasuresToTrack_Skip5:
	ld	(3282:16), iy	; F5F5AE  ld (0x0cd2),IY
	ld	wa, (BStore_CursorBlock:16)	; F5F5B2  ld WA,(0x345c)
	ld	(3280:16), wa	; F5F5B6  ld (0x0cd0),WA
	ld	wa, (BStore_AllocBytesWanted:16)	; F5F5BA  ld WA,(0x0cae)
	ld	(3406:16), wa	; F5F5BE  ld (0x0d4e),WA
	and	(0x0d90:16), 0xfe	; F5F5C2  and (0x0d90),0xfe
	ld	w, (3357:16)	; F5F5C7  ld W,(0x0d1d)
	ld	a, (3215:16)	; F5F5CB  ld A,(0x0c8f)
	ld	de, (3189:16)	; F5F5CF  ld DE,(0x0c75)
	ld	(3216:16), de	; F5F5D3  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F5F5D7  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F5F5DB  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresToTrack_Skip7	; F5F5E0  jr Z,0xf5f633
	cp	(BStore_ErrorCode:16), 0x08	; F5F5E2  cp (0x0d4a),0x08
	jrl	nz, SongEdit_CopyMeasuresToTrack_Join9	; F5F5E7  jrl NZ,0xf5f9a6
	call	T_SongEdit_PadDestTrackToMeasure	; F5F5EA  call 0xf42808
	cp	(BStore_ErrorCode:16), 0x00	; F5F5EE  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresToTrack_Skip6	; F5F5F3  jr Z,0xf5f5fb
	calr	SongEdit_RestoreDestTrackEnd	; F5F5F5  calr 0xf5f9c1
	jrl	SongEdit_CopyMeasuresToTrack_Join9	; F5F5F8  jrl T,0xf5f9a6
SongEdit_CopyMeasuresToTrack_Skip6:
	ld	wa, (3260:16)	; F5F5FB  ld WA,(0x0cbc)
	ld	(BStore_CursorBlock:16), wa	; F5F5FF  ld (0x345c),WA
	or	(0x0d90:16), 0x01	; F5F603  or (0x0d90),0x01
	xor	hl, hl	; F5F608  xor HL,HL
	ld	l, (3215:16)	; F5F60A  ld L,(0x0c8f)
	dec	1, hl	; F5F60E  dec 1,HL
	xor	wa, wa	; F5F610  xor WA,WA
	push	xix	; F5F612  push XIX
	ld	xix, 6304928	; F5F613  ld XIX,0x006034a0
	ld	a, (xix+hl)	; F5F618  ld A,(XIX+HL)
	ld	(3278:16), wa	; F5F61D  ld (0x0cce),WA
	sla	hl, 1	; F5F621  sla 0x01,HL
	ld	xix, 6304894	; F5F624  ld XIX,0x0060347e
	ld	hl, (xix+hl)	; F5F629  ld HL,(XIX+HL)
	ld	(3276:16), hl	; F5F62E  ld (0x0ccc),HL
	pop	xix	; F5F632  pop XIX
SongEdit_CopyMeasuresToTrack_Skip7:
	ld	(3258:16), iy	; F5F633  ld (0x0cba),IY
	ld	wa, (BStore_CursorBlock:16)	; F5F637  ld WA,(0x345c)
	ld	(3252:16), wa	; F5F63B  ld (0x0cb4),WA
	ld	hl, wa	; F5F63F  ld HL,WA
	ld	iy, (3258:16)	; F5F641  ld IY,(0x0cba)
	call	T_F42798	; F5F645  call 0xf42798
	cp	(BStore_ErrorCode:16), 0x00	; F5F649  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresToTrack_Skip8	; F5F64E  jr Z,0xf5f662
	cp	(BStore_ErrorCode:16), 0x07	; F5F650  cp (0x0d4a),0x07
	jrl	nz, SongEdit_CopyMeasuresToTrack_Join9	; F5F655  jrl NZ,0xf5f9a6
	or	(0x0c8a:16), 0x10	; F5F658  or (0x0c8a),0x10
	ld	(BStore_ErrorCode:16), 0	; F5F65D  ld (0x0d4a),0x00
SongEdit_CopyMeasuresToTrack_Skip8:
	ld	(3286:16), iy	; F5F662  ld (0x0cd6),IY
	ld	wa, (BStore_CursorBlock:16)	; F5F666  ld WA,(0x345c)
	ld	(3284:16), wa	; F5F66A  ld (0x0cd4),WA
	ld	wa, (BStore_AllocBytesWanted:16)	; F5F66E  ld WA,(0x0cae)
	ld	(3248:16), wa	; F5F672  ld (0x0cb0),WA
	ld	wa, (3406:16)	; F5F676  ld WA,(0x0d4e)
	ld	(BStore_AllocBytesWanted:16), wa	; F5F67A  ld (0x0cae),WA
	ld	wa, (3248:16)	; F5F67E  ld WA,(0x0cb0)
	cp	wa, (BStore_AllocBytesWanted:16)	; F5F682  cp WA,(0x0cae)
	jr	c, SongEdit_CopyMeasuresToTrack_Skip9	; F5F686  jr C,0xf5f68c
	jr	z, SongEdit_CopyMeasuresToTrack_Skip10	; F5F688  jr Z,0xf5f68e
	jr	ugt, SongEdit_CopyMeasuresToTrack_Skip11	; F5F68A  jr UGT,0xf5f691
SongEdit_CopyMeasuresToTrack_Skip9:
	jr	SongEdit_CopyMeasuresToTrack_Join	; F5F68C  jr T,0xf5f694
SongEdit_CopyMeasuresToTrack_Skip10:
	jrl	SongEdit_CopyMeasuresToTrack_Join6	; F5F68E  jrl T,0xf5f91d
SongEdit_CopyMeasuresToTrack_Skip11:
	jrl	SongEdit_CopyMeasuresToTrack_Join4	; F5F691  jrl T,0xf5f804
SongEdit_CopyMeasuresToTrack_Join:
	sub	(BStore_AllocBytesWanted:16), wa	; F5F694  sub (0x0cae),WA
	ld	wa, (3276:16)	; F5F698  ld WA,(0x0ccc)
	ld	(BStore_LinkBlock:16), wa	; F5F69C  ld (0x0cc0),WA
	ld	wa, (3278:16)	; F5F6A0  ld WA,(0x0cce)
	ld	(BStore_LastBlockUsed:16), wa	; F5F6A4  ld (0x0cc6),WA
	bit	4, (0x0c8a:16)	; F5F6A8  bit 4,(0x0c8a)
	jr	z, SongEdit_CopyMeasuresToTrack_Skip12	; F5F6AC  jr Z,0xf5f6b8
	bit	3, (0x0c8a:16)	; F5F6AE  bit 3,(0x0c8a)
	jr	nz, SongEdit_CopyMeasuresToTrack_Skip12	; F5F6B2  jr NZ,0xf5f6b8
	incw	1, (BStore_AllocBytesWanted:16)	; F5F6B4  incw 1,(0x0cae)
SongEdit_CopyMeasuresToTrack_Skip12:
	call	T_BStore_AllocChain	; F5F6B8  call 0xf427b4
	cp	(BStore_ErrorCode:16), 0x00	; F5F6BC  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresToTrack_Skip14	; F5F6C1  jr Z,0xf5f6cf
	bit	0, (0x0d90:16)	; F5F6C3  bit 0,(0x0d90)
	jr	z, SongEdit_CopyMeasuresToTrack_Skip13	; F5F6C7  jr Z,0xf5f6cc
	calr	SongEdit_RestoreDestTrackEnd	; F5F6C9  calr 0xf5f9c1
SongEdit_CopyMeasuresToTrack_Skip13:
	jrl	SongEdit_CopyMeasuresToTrack_Join9	; F5F6CC  jrl T,0xf5f9a6
SongEdit_CopyMeasuresToTrack_Skip14:
	ld	(3300:16), de	; F5F6CF  ld (0x0ce4),DE
	ld	wa, (BStore_LastBlockFree:16)	; F5F6D3  ld WA,(0x0d08)
	ld	(3302:16), wa	; F5F6D7  ld (0x0ce6),WA
	ld	ix, wa	; F5F6DB  ld IX,WA
	ld	wa, (3300:16)	; F5F6DD  ld WA,(0x0ce4)
	ld	(3159:16), wa	; F5F6E1  ld (0x0c57),WA
	call	T_BStore_SaveCursor	; F5F6E5  call 0xf427b0
	ld	wa, (3276:16)	; F5F6E9  ld WA,(0x0ccc)
	ld	(3169:16), wa	; F5F6ED  ld (0x0c61),WA
	ld	wa, (3278:16)	; F5F6F1  ld WA,(0x0cce)
	ld	(3175:16), wa	; F5F6F5  ld (0x0c67),WA
	ld	wa, (3300:16)	; F5F6F9  ld WA,(0x0ce4)
	ld	(3159:16), wa	; F5F6FD  ld (0x0c57),WA
	ld	wa, (3302:16)	; F5F701  ld WA,(0x0ce6)
	ld	(3165:16), wa	; F5F705  ld (0x0c5d),WA
	ld	de, (3284:16)	; F5F709  ld DE,(0x0cd4)
	ld	wa, (3286:16)	; F5F70D  ld WA,(0x0cd6)
	ld	(3179:16), wa	; F5F711  ld (0x0c6b),WA
	call	T_BStore_CopyRangeBackward	; F5F715  call 0xf4277c
	cp	(BStore_ErrorCode:16), 0x00	; F5F719  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresToTrack_Skip15	; F5F71E  jr Z,0xf5f723
	jrl	SongEdit_CopyMeasuresToTrack_Join9	; F5F720  jrl T,0xf5f9a6
SongEdit_CopyMeasuresToTrack_Skip15:
	ld	wa, (3159:16)	; F5F723  ld WA,(0x0c57)
	ld	(3288:16), wa	; F5F727  ld (0x0cd8),WA
	sub	ix, hl	; F5F72B  sub IX,HL
	inc	1, ix	; F5F72D  inc 1,IX
	ld	(3290:16), ix	; F5F72F  ld (0x0cda),IX
	bit	4, (0x0c8a:16)	; F5F733  bit 4,(0x0c8a)
	jrl	z, SongEdit_CopyMeasuresToTrack_Join3	; F5F737  jrl Z,0xf5f801
	bit	3, (0x0c8a:16)	; F5F73A  bit 3,(0x0c8a)
	jr	nz, SongEdit_CopyMeasuresToTrack_Skip18	; F5F73E  jr NZ,0xf5f787
	dec	1, ix	; F5F740  dec 1,IX
	cp	ix, 4:i3	; F5F742  cp IX,4
	jr	ugt, SongEdit_CopyMeasuresToTrack_Skip17	; F5F744  jr UGT,0xf5f780
	push	xiz	; F5F746  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F5F747  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F5F74B  ld XDE3,XIZ
	pop	xiz	; F5F74E  pop XIZ
	push_lerp	0x38	; F5F74F  push XDE3
	ld	hl, (3288:16)	; F5F752  ld HL,(0x0cd8)
	call	T_BStore_SeekBlock	; F5F756  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5F75A  ld XHL,(0x126e)
	ld	hl, (xhl+1)	; F5F75E  ld HL,(XHL+0x01)
	pop_lerp	0x38	; F5F761  pop XDE3
	push	xiz	; F5F764  push XIZ
	ldto_lerp	xiz, 0x38	; F5F765  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F5F768  ld (0x126e),XIZ
	pop	xiz	; F5F76C  pop XIZ
	cp	hl, 0:i3	; F5F76D  cp HL,0
	jr	nz, SongEdit_CopyMeasuresToTrack_Skip16	; F5F76F  jr NZ,0xf5f779
	ld	(BStore_ErrorCode:16), 11	; F5F771  ld (0x0d4a),0x0b
	jrl	SongEdit_CopyMeasures_Join7	; F5F776  jrl T,0xf5f46d
SongEdit_CopyMeasuresToTrack_Skip16:
	ld	(3288:16), hl	; F5F779  ld (0x0cd8),HL
	ldw	ix, 255	; F5F77D  ld IX,0x00ff
SongEdit_CopyMeasuresToTrack_Skip17:
	ld	(3290:16), ix	; F5F780  ld (0x0cda),IX
	jrl	SongEdit_CopyMeasuresToTrack_Join3	; F5F784  jrl T,0xf5f801
SongEdit_CopyMeasuresToTrack_Skip18:
	ld	a, (3184:16)	; F5F787  ld A,(0x0c70)
	cp	a, 127	; F5F78B  cp A,0x7f
	jr	z, SongEdit_CopyMeasuresToTrack_Skip19	; F5F78E  jr Z,0xf5f796
	cp	a, (0x0c71:16)	; F5F790  cp A,(0x0c71)
	jr	nz, SongEdit_CopyMeasuresToTrack_Join3	; F5F794  jr NZ,0xf5f801
SongEdit_CopyMeasuresToTrack_Skip19:
	bit	0, (0x0d90:16)	; F5F796  bit 0,(0x0d90)
	jrl	z, SongEdit_CopyMeasuresToTrack_Join3	; F5F79A  jrl Z,0xf5f801
	bit	3, (0x0c8a:16)	; F5F79D  bit 3,(0x0c8a)
	jr	z, SongEdit_CopyMeasuresToTrack_Join3	; F5F7A1  jr Z,0xf5f801
	dec	1, ix	; F5F7A3  dec 1,IX
	cp	ix, 4:i3	; F5F7A5  cp IX,4
	jr	ugt, SongEdit_CopyMeasuresToTrack_Skip21	; F5F7A7  jr UGT,0xf5f7cb
	ld	hl, (3288:16)	; F5F7A9  ld HL,(0x0cd8)
	call	T_BStore_SeekBlock	; F5F7AD  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5F7B1  ld XHL,(0x126e)
	ld	hl, (xhl+1)	; F5F7B5  ld HL,(XHL+0x01)
	cp	hl, 0:i3	; F5F7B8  cp HL,0
	jr	nz, SongEdit_CopyMeasuresToTrack_Skip20	; F5F7BA  jr NZ,0xf5f7c4
	ld	(BStore_ErrorCode:16), 11	; F5F7BC  ld (0x0d4a),0x0b
	jrl	SongEdit_CopyMeasures_Join7	; F5F7C1  jrl T,0xf5f46d
SongEdit_CopyMeasuresToTrack_Skip20:
	ld	(3288:16), hl	; F5F7C4  ld (0x0cd8),HL
	ldw	ix, 255	; F5F7C8  ld IX,0x00ff
SongEdit_CopyMeasuresToTrack_Skip21:
	ld	(3290:16), ix	; F5F7CB  ld (0x0cda),IX
	ld	wa, (3282:16)	; F5F7CF  ld WA,(0x0cd2)
	dec	1, wa	; F5F7D3  dec 1,WA
	cp	wa, 4:i3	; F5F7D5  cp WA,4
	jr	ugt, SongEdit_CopyMeasuresToTrack_Join2	; F5F7D7  jr UGT,0xf5f7fd
	ld	hl, (3280:16)	; F5F7D9  ld HL,(0x0cd0)
	call	T_BStore_SeekBlock	; F5F7DD  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5F7E1  ld XHL,(0x126e)
	ld	hl, (xhl+1)	; F5F7E5  ld HL,(XHL+0x01)
	cp	hl, 0:i3	; F5F7E8  cp HL,0
	jr	z, SongEdit_CopyMeasuresToTrack_Skip22	; F5F7EA  jr Z,0xf5f7f5
	ld	(3280:16), hl	; F5F7EC  ld (0x0cd0),HL
	ldw	wa, 255	; F5F7F0  ld WA,0x00ff
	jr	SongEdit_CopyMeasuresToTrack_Join2	; F5F7F3  jr T,0xf5f7fd
SongEdit_CopyMeasuresToTrack_Skip22:
	ld	(BStore_ErrorCode:16), 11	; F5F7F5  ld (0x0d4a),0x0b
	jrl	SongEdit_CopyMeasuresToTrack_Join9	; F5F7FA  jrl T,0xf5f9a6
SongEdit_CopyMeasuresToTrack_Join2:
	ld	(3282:16), wa	; F5F7FD  ld (0x0cd2),WA
SongEdit_CopyMeasuresToTrack_Join3:
	jrl	SongEdit_CopyMeasuresToTrack_Join8	; F5F801  jrl T,0xf5f971
SongEdit_CopyMeasuresToTrack_Join4:
	sub	wa, (BStore_AllocBytesWanted:16)	; F5F804  sub WA,(0x0cae)
	bit	4, (0x0c8a:16)	; F5F808  bit 4,(0x0c8a)
	jr	z, SongEdit_CopyMeasuresToTrack_Skip23	; F5F80C  jr Z,0xf5f816
	bit	3, (0x0c8a:16)	; F5F80E  bit 3,(0x0c8a)
	jr	nz, SongEdit_CopyMeasuresToTrack_Skip23	; F5F812  jr NZ,0xf5f816
	dec	1, wa	; F5F814  dec 1,WA
SongEdit_CopyMeasuresToTrack_Skip23:
	ld	(BStore_AllocBytesWanted:16), wa	; F5F816  ld (0x0cae),WA
	ld	wa, (3284:16)	; F5F81A  ld WA,(0x0cd4)
	ld	(3304:16), wa	; F5F81E  ld (0x0ce8),WA
	ld	wa, (3286:16)	; F5F822  ld WA,(0x0cd6)
	ld	(3306:16), wa	; F5F826  ld (0x0cea),WA
	call	T_BStore_MovePosBackward	; F5F82A  call 0xf42784
	cp	(BStore_ErrorCode:16), 0x00	; F5F82E  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresToTrack_Skip24	; F5F833  jr Z,0xf5f838
	jrl	SongEdit_CopyMeasuresToTrack_Join9	; F5F835  jrl T,0xf5f9a6
SongEdit_CopyMeasuresToTrack_Skip24:
	ld	wa, (3306:16)	; F5F838  ld WA,(0x0cea)
	ld	(3290:16), wa	; F5F83C  ld (0x0cda),WA
	ld	wa, (3304:16)	; F5F840  ld WA,(0x0ce8)
	ld	(3288:16), wa	; F5F844  ld (0x0cd8),WA
	ld	wa, (3284:16)	; F5F848  ld WA,(0x0cd4)
	ld	(3169:16), wa	; F5F84C  ld (0x0c61),WA
	ld	wa, (3286:16)	; F5F850  ld WA,(0x0cd6)
	ld	(3175:16), wa	; F5F854  ld (0x0c67),WA
	ld	wa, (3288:16)	; F5F858  ld WA,(0x0cd8)
	ld	(3159:16), wa	; F5F85C  ld (0x0c57),WA
	ld	wa, (3290:16)	; F5F860  ld WA,(0x0cda)
	ld	(3165:16), wa	; F5F864  ld (0x0c5d),WA
	ld	de, (3276:16)	; F5F868  ld DE,(0x0ccc)
	ld	wa, (3278:16)	; F5F86C  ld WA,(0x0cce)
	ld	(3179:16), wa	; F5F870  ld (0x0c6b),WA
	call	T_F42778	; F5F874  call 0xf42778
	cp	(BStore_ErrorCode:16), 0x00	; F5F878  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresToTrack_Skip25	; F5F87D  jr Z,0xf5f882
	jrl	SongEdit_CopyMeasuresToTrack_Join9	; F5F87F  jrl T,0xf5f9a6
SongEdit_CopyMeasuresToTrack_Skip25:
	cp	ix, 5:i3	; F5F882  cp IX,5
	jr	nz, SongEdit_CopyMeasuresToTrack_Skip26	; F5F884  jr NZ,0xf5f8a3
	ld	hl, (3159:16)	; F5F886  ld HL,(0x0c57)
	call	T_BStore_SeekBlock	; F5F88A  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5F88E  ld XHL,(0x126e)
	ld	hl, (xhl+1)	; F5F892  ld HL,(XHL+0x01)
	cp	hl, 0:i3	; F5F895  cp HL,0
	jrl	z, SongEdit_CopyMeasuresToTrack_Join9	; F5F897  jrl Z,0xf5f9a6
	ld	(3159:16), hl	; F5F89A  ld (0x0c57),HL
	ldw	ix, 255	; F5F89E  ld IX,0x00ff
	jr	SongEdit_CopyMeasuresToTrack_Join5	; F5F8A1  jr T,0xf5f8a5
SongEdit_CopyMeasuresToTrack_Skip26:
	dec	1, ix	; F5F8A3  dec 1,IX
SongEdit_CopyMeasuresToTrack_Join5:
	bit	3, (0x0c8a:16)	; F5F8A5  bit 3,(0x0c8a)
	jr	z, SongEdit_CopyMeasuresToTrack_Skip27	; F5F8A9  jr Z,0xf5f8b7
	ld	ix, (3290:16)	; F5F8AB  ld IX,(0x0cda)
	ld	wa, (3288:16)	; F5F8AF  ld WA,(0x0cd8)
	ld	(3159:16), wa	; F5F8B3  ld (0x0c57),WA
SongEdit_CopyMeasuresToTrack_Skip27:
	call	T_BStore_SaveCursor	; F5F8B7  call 0xf427b0
	call	T_BStore_TruncateChainAfterBlock	; F5F8BB  call 0xf42794
	cp	(BStore_ErrorCode:16), 0x00	; F5F8BF  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresToTrack_Skip28	; F5F8C4  jr Z,0xf5f8c9
	jrl	SongEdit_CopyMeasuresToTrack_Join9	; F5F8C6  jrl T,0xf5f9a6
SongEdit_CopyMeasuresToTrack_Skip28:
	bit	4, (0x0c8a:16)	; F5F8C9  bit 4,(0x0c8a)
	jr	z, SongEdit_CopyMeasuresToTrack_Skip32	; F5F8CD  jr Z,0xf5f91b
	bit	3, (0x0c8a:16)	; F5F8CF  bit 3,(0x0c8a)
	jr	nz, SongEdit_CopyMeasuresToTrack_Skip32	; F5F8D3  jr NZ,0xf5f91b
	ld	ix, (3290:16)	; F5F8D5  ld IX,(0x0cda)
	dec	1, ix	; F5F8D9  dec 1,IX
	cp	ix, 5:i3	; F5F8DB  cp IX,5
	jr	nc, SongEdit_CopyMeasuresToTrack_Skip31	; F5F8DD  jr NC,0xf5f917
	ld	hl, (3288:16)	; F5F8DF  ld HL,(0x0cd8)
	call	T_BStore_SeekBlock	; F5F8E3  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5F8E7  ld XHL,(0x126e)
	ld	wa, (xhl+1)	; F5F8EB  ld WA,(XHL+0x01)
	cp	wa, 0:i3	; F5F8EE  cp WA,0
	jr	nz, SongEdit_CopyMeasuresToTrack_Skip29	; F5F8F0  jr NZ,0xf5f8fa
	ld	(BStore_ErrorCode:16), 10	; F5F8F2  ld (0x0d4a),0x0a
	jrl	SongEdit_CopyMeasuresToTrack_Join9	; F5F8F7  jrl T,0xf5f9a6
SongEdit_CopyMeasuresToTrack_Skip29:
	ld	hl, wa	; F5F8FA  ld HL,WA
	call	T_BStore_SeekBlock	; F5F8FC  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5F900  ld XHL,(0x126e)
	bit	7, (xhl)	; F5F904  bit 7,(XHL)
	jr	nz, SongEdit_CopyMeasuresToTrack_Skip30	; F5F906  jr NZ,0xf5f910
	ld	(BStore_ErrorCode:16), 11	; F5F908  ld (0x0d4a),0x0b
	jrl	SongEdit_CopyMeasuresToTrack_Join9	; F5F90D  jrl T,0xf5f9a6
SongEdit_CopyMeasuresToTrack_Skip30:
	ld	(3288:16), wa	; F5F910  ld (0x0cd8),WA
	ldw	ix, 255	; F5F914  ld IX,0x00ff
SongEdit_CopyMeasuresToTrack_Skip31:
	ld	(3290:16), ix	; F5F917  ld (0x0cda),IX
SongEdit_CopyMeasuresToTrack_Skip32:
	jr	SongEdit_CopyMeasuresToTrack_Join8	; F5F91B  jr T,0xf5f971
SongEdit_CopyMeasuresToTrack_Join6:
	ld	wa, (3286:16)	; F5F91D  ld WA,(0x0cd6)
	ld	l, (3184:16)	; F5F921  ld L,(0x0c70)
	cp	l, 127	; F5F925  cp L,0x7f
	jr	z, SongEdit_CopyMeasuresToTrack_Skip33	; F5F928  jr Z,0xf5f930
	cp	l, (0x0c71:16)	; F5F92A  cp L,(0x0c71)
	jr	nz, SongEdit_CopyMeasuresToTrack_Join7	; F5F92E  jr NZ,0xf5f965
SongEdit_CopyMeasuresToTrack_Skip33:
	bit	0, (0x0d90:16)	; F5F930  bit 0,(0x0d90)
	jr	z, SongEdit_CopyMeasuresToTrack_Join7	; F5F934  jr Z,0xf5f965
	bit	3, (0x0c8a:16)	; F5F936  bit 3,(0x0c8a)
	jr	z, SongEdit_CopyMeasuresToTrack_Join7	; F5F93A  jr Z,0xf5f965
	dec	1, wa	; F5F93C  dec 1,WA
	cp	wa, 4:i3	; F5F93E  cp WA,4
	jr	ugt, SongEdit_CopyMeasuresToTrack_Join7	; F5F940  jr UGT,0xf5f965
	ld	hl, (3284:16)	; F5F942  ld HL,(0x0cd4)
	call	T_BStore_SeekBlock	; F5F946  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5F94A  ld XHL,(0x126e)
	ld	hl, (xhl+1)	; F5F94E  ld HL,(XHL+0x01)
	cp	hl, 0:i3	; F5F951  cp HL,0
	jr	z, SongEdit_CopyMeasuresToTrack_Skip34	; F5F953  jr Z,0xf5f95e
	ld	(3284:16), hl	; F5F955  ld (0x0cd4),HL
	ldw	wa, 255	; F5F959  ld WA,0x00ff
	jr	SongEdit_CopyMeasuresToTrack_Join7	; F5F95C  jr T,0xf5f965
SongEdit_CopyMeasuresToTrack_Skip34:
	ld	(BStore_ErrorCode:16), 11	; F5F95E  ld (0x0d4a),0x0b
	jr	SongEdit_CopyMeasuresToTrack_Join9	; F5F963  jr T,0xf5f9a6
SongEdit_CopyMeasuresToTrack_Join7:
	ld	(3290:16), wa	; F5F965  ld (0x0cda),WA
	ld	wa, (3284:16)	; F5F969  ld WA,(0x0cd4)
	ld	(3288:16), wa	; F5F96D  ld (0x0cd8),WA
SongEdit_CopyMeasuresToTrack_Join8:
	ld	wa, (3280:16)	; F5F971  ld WA,(0x0cd0)
	ld	(3169:16), wa	; F5F975  ld (0x0c61),WA
	ld	wa, (3282:16)	; F5F979  ld WA,(0x0cd2)
	ld	(3175:16), wa	; F5F97D  ld (0x0c67),WA
	ld	wa, (3288:16)	; F5F981  ld WA,(0x0cd8)
	ld	(3159:16), wa	; F5F985  ld (0x0c57),WA
	ld	wa, (3290:16)	; F5F989  ld WA,(0x0cda)
	ld	(3165:16), wa	; F5F98D  ld (0x0c5d),WA
	ld	de, (3292:16)	; F5F991  ld DE,(0x0cdc)
	ld	wa, (3294:16)	; F5F995  ld WA,(0x0cde)
	ld	(3179:16), wa	; F5F999  ld (0x0c6b),WA
	call	T_BStore_CopyRangeBackward	; F5F99D  call 0xf4277c
	cp	(BStore_ErrorCode:16), 0x00	; F5F9A1  cp (0x0d4a),0x00
SongEdit_CopyMeasuresToTrack_Join9:
	bit	7, (0x0c8a:16)	; F5F9A6  bit 7,(0x0c8a)
	jr	z, SongEdit_CopyMeasuresToTrack_Return	; F5F9AA  jr Z,0xf5f9c0
	cp	(BStore_ErrorCode:16), 0x00	; F5F9AC  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresToTrack_Return	; F5F9B1  jr Z,0xf5f9c0
	xor	wa, wa	; F5F9B3  xor WA,WA
	ld	a, (3215:16)	; F5F9B5  ld A,(0x0c8f)
	ld	(3184:16), a	; F5F9B9  ld (0x0c70),A
	calr	SongEdit_ClearTrack	; F5F9BD  calr 0xf6079e
SongEdit_CopyMeasuresToTrack_Return:
	ret	; F5F9C0  ret

; --------------------------------------------------------------------------
; SongEdit_RestoreDestTrackEnd
; Called from: in-module: 0xF5F5F5 0xF5F6C9
; Touches: (0x0C57) (0x0C70) (0x0C8F) (0x0CCC) (0x0CCE) (0x0D1A) (0x126E)  |
;          0x000D50 0x000D70 0x603500
; Calls:   T_BStore_SeekBlock T_BStore_SaveCursor T_BStore_TruncateChainAfterBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5F9C1 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_RestoreDestTrackEnd: Rolls MEASURE COPY's destination track (0x0C8F) back to its end on entry (block
;   (0x0D50)[n-1], offset (0x0D70)[n-1], recorded by SongEdit_CopyMeasuresToTrack): if in use, writes 0x82 there,
;   saves that end cursor and truncates the chain after it. Run when padding the destination
;   (SongEdit_PadDestTrackToMeasure) or the AllocChain that grows it fails. Basis: caller + body (an unlabelled ALL-
;   tracks variant follows at 0xF5FA5C). (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
SongEdit_RestoreDestTrackEnd:
	pushw	bc	; F5F9C1  push BC
	push	xiy	; F5F9C2  push XIY
	xor	bc, bc	; F5F9C3  xor BC,BC
	ld	c, (3215:16)	; F5F9C5  ld C,(0x0c8f)
	dec	1, bc	; F5F9C9  dec 1,BC
	ld	hl, bc	; F5F9CB  ld HL,BC
	muls	hl, 3	; F5F9CD  muls HL,0x0003
	push	xde	; F5F9D1  push XDE
	ld	xde, 6305024	; F5F9D2  ld XDE,0x00603500
	bit	7, (xde+hl)	; F5F9D7  bit 7,(XDE+HL)
	pop	xde	; F5F9DC  pop XDE
	jr	z, SongEdit_RestoreDestTrackEnd_Loop	; F5F9DD  jr Z,0xf5fa59
	ld	hl, bc	; F5F9DF  ld HL,BC
	sla	hl, 1	; F5F9E1  sla 0x01,HL
	push	xix	; F5F9E4  push XIX
	ld	xix, 3408	; F5F9E5  ld XIX,0x00000d50
	ld	hl, (xix+hl)	; F5F9EA  ld HL,(XIX+HL)
	pop	xix	; F5F9EF  pop XIX
	call	T_BStore_SeekBlock	; F5F9F0  call 0xf427bc
	ld	hl, bc	; F5F9F4  ld HL,BC
	sla	hl, 1	; F5F9F6  sla 0x01,HL
	push	xix	; F5F9F9  push XIX
	ld	xix, 3440	; F5F9FA  ld XIX,0x00000d70
	ld	iy, (xix+hl)	; F5F9FF  ld IY,(XIX+HL)
	pop	xix	; F5FA04  pop XIX
	ld	(3278:16), iy	; F5FA05  ld (0x0cce),IY
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5FA09  ld XHL,(0x126e)
	ld	(xhl+iy), 0x82	; F5FA0D  ld (XHL+IY),0x82
	ld	wa, bc	; F5FA13  ld WA,BC
	inc	1, wa	; F5FA15  inc 1,WA
	ld	(3354:16), wa	; F5FA17  ld (0x0d1a),WA
	ld	hl, bc	; F5FA1B  ld HL,BC
	sla	hl, 1	; F5FA1D  sla 0x01,HL
	push	xiy	; F5FA20  push XIY
	ld	xiy, 3408	; F5FA21  ld XIY,0x00000d50
	ld	wa, (xiy+hl)	; F5FA26  ld WA,(XIY+HL)
	ld	(3276:16), wa	; F5FA2B  ld (0x0ccc),WA
	ld	(3159:16), wa	; F5FA2F  ld (0x0c57),WA
	ld	xiy, 3440	; F5FA33  ld XIY,0x00000d70
	ld	ix, (xiy+hl)	; F5FA38  ld IX,(XIY+HL)
	pop	xiy	; F5FA3D  pop XIY
	pushw	bc	; F5FA3E  push BC
	call	T_BStore_SaveCursor	; F5FA3F  call 0xf427b0
	popw	bc	; F5FA43  pop BC
	ld	hl, bc	; F5FA44  ld HL,BC
	sla	hl, 1	; F5FA46  sla 0x01,HL
	push	xix	; F5FA49  push XIX
	ld	xix, 3408	; F5FA4A  ld XIX,0x00000d50
	ld	wa, (xix+hl)	; F5FA4F  ld WA,(XIX+HL)
	pop	xix	; F5FA54  pop XIX
	call	T_BStore_TruncateChainAfterBlock	; F5FA55  call 0xf42794
SongEdit_RestoreDestTrackEnd_Loop:
	pop	xiy	; F5FA59  pop XIY
	popw	bc	; F5FA5A  pop BC
	ret	; F5FA5B  ret
	pushw	bc	; F5FA5C  push BC
	push	xiy	; F5FA5D  push XIY
	cp	(0x0c70:16), 0x7f	; F5FA5E  cp (0x0c70),0x7f
	jr	nz, SongEdit_RestoreDestTrackEnd_Loop	; F5FA63  jr NZ,0xf5fa59
	xor	bc, bc	; F5FA65  xor BC,BC
SongEdit_RestoreDestTrackEnd_Join:
	cp	c, 16	; F5FA67  cp C,0x10
	jrl	ugt, SongEdit_RestoreDestTrackEnd_Epilogue	; F5FA6A  jrl UGT,0xf5fb01
	ld	hl, bc	; F5FA6D  ld HL,BC
	muls	hl, 3	; F5FA6F  muls HL,0x0003
	push	xix	; F5FA73  push XIX
	ld	xix, 6305024	; F5FA74  ld XIX,0x00603500
	bit	7, (xix+hl)	; F5FA79  bit 7,(XIX+HL)
	pop	xix	; F5FA7E  pop XIX
	jr	z, SongEdit_RestoreDestTrackEnd_Skip	; F5FA7F  jr Z,0xf5fafc
	ld	hl, bc	; F5FA81  ld HL,BC
	sla	hl, 1	; F5FA83  sla 0x01,HL
	push	xix	; F5FA86  push XIX
	ld	xix, 3408	; F5FA87  ld XIX,0x00000d50
	ld	hl, (xix+hl)	; F5FA8C  ld HL,(XIX+HL)
	pop	xix	; F5FA91  pop XIX
	cp	hl, 0:i3	; F5FA92  cp HL,0
	jr	z, SongEdit_RestoreDestTrackEnd_Skip	; F5FA94  jr Z,0xf5fafc
	pushw	bc	; F5FA96  push BC
	call	T_BStore_SeekBlock	; F5FA97  call 0xf427bc
	popw	bc	; F5FA9B  pop BC
	ld	hl, bc	; F5FA9C  ld HL,BC
	sla	hl, 1	; F5FA9E  sla 0x01,HL
	push	xix	; F5FAA1  push XIX
	ld	xix, 3440	; F5FAA2  ld XIX,0x00000d70
	ld	iy, (xix+hl)	; F5FAA7  ld IY,(XIX+HL)
	pop	xix	; F5FAAC  pop XIX
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5FAAD  ld XHL,(0x126e)
	ld	(xhl+iy), 0x82	; F5FAB1  ld (XHL+IY),0x82
	xor	wa, wa	; F5FAB7  xor WA,WA
	ld	wa, bc	; F5FAB9  ld WA,BC
	inc	1, wa	; F5FABB  inc 1,WA
	ld	(3354:16), wa	; F5FABD  ld (0x0d1a),WA
	push	xiy	; F5FAC1  push XIY
	ld	xiy, 3408	; F5FAC2  ld XIY,0x00000d50
	ld	wa, (xiy+hl)	; F5FAC7  ld WA,(XIY+HL)
	ld	(3276:16), wa	; F5FACC  ld (0x0ccc),WA
	ld	(3159:16), wa	; F5FAD0  ld (0x0c57),WA
	ld	xiy, 3440	; F5FAD4  ld XIY,0x00000d70
	ld	ix, (xiy+hl)	; F5FAD9  ld IX,(XIY+HL)
	pop	xiy	; F5FADE  pop XIY
	pushw	bc	; F5FADF  push BC
	call	T_BStore_SaveCursor	; F5FAE0  call 0xf427b0
	popw	bc	; F5FAE4  pop BC
	ld	hl, bc	; F5FAE5  ld HL,BC
	sla	hl, 1	; F5FAE7  sla 0x01,HL
	push	xix	; F5FAEA  push XIX
	ld	xix, 3408	; F5FAEB  ld XIX,0x00000d50
	ld	wa, (xix+hl)	; F5FAF0  ld WA,(XIX+HL)
	pop	xix	; F5FAF5  pop XIX
	pushw	bc	; F5FAF6  push BC
	call	T_BStore_TruncateChainAfterBlock	; F5FAF7  call 0xf42794
	popw	bc	; F5FAFB  pop BC
SongEdit_RestoreDestTrackEnd_Skip:
	inc	1, c	; F5FAFC  inc 1,C
	jrl	SongEdit_RestoreDestTrackEnd_Join	; F5FAFE  jrl T,0xf5fa67
SongEdit_RestoreDestTrackEnd_Epilogue:
	pop	xiy	; F5FB01  pop XIY
	popw	bc	; F5FB02  pop BC
	ret	; F5FB03  ret

; --------------------------------------------------------------------------
; SongEdit_CopyMeasuresWithinTrack
; Called from: in-module: 0xF5F3AC 0xF5F439
; Touches: (0x0C57) (0x0C5D) (0x0C61) (0x0C67) (0x0C6B) (0x0C73) (0x0C75)
;          (0x0C77) (0x0C8A) (0x0C8E) +31 more  |  0x603500
; Calls:   SongEdit_CopyMeasuresToTrack T_Seq_FindMasterTrack T_BStore_SeekMeasure T_BStore_ValidateSavedCursor T_F42798 T_BStore_AllocChain T_BStore_SaveCursor
;          T_BStore_CopyRangeBackward T_BStore_MovePosForward T_BStore_MovePosBackward T_F42778 T_BStore_SeekBlock +1 more
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF5FB04 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_CopyMeasuresWithinTrack: MEASURE COPY when source and destination are the same track (or ALL): source
;   before destination -> SongEdit_CopyMeasuresToTrack; same measure -> only checks the entry is in use; source after
;   destination -> resizes the destination range itself, re-basing the source positions with BStore_MovePosForward /
;   BStore_MovePosBackward before copying. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_q.json)
SongEdit_CopyMeasuresWithinTrack:
	xor	wa, wa	; F5FB04  xor WA,WA
	ld	wa, (3187:16)	; F5FB06  ld WA,(0x0c73)
	cp	wa, (0x0c75:16)	; F5FB0A  cp WA,(0x0c75)
	jr	ugt, SongEdit_CopyMeasuresWithinTrack_Skip	; F5FB0E  jr UGT,0xf5fb14
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip2	; F5FB10  jr Z,0xf5fb1c
	jr	SongEdit_CopyMeasuresWithinTrack_Join	; F5FB12  jr T,0xf5fb16
SongEdit_CopyMeasuresWithinTrack_Skip:
	jr	SongEdit_CopyMeasuresWithinTrack_Join2	; F5FB14  jr T,0xf5fb54
SongEdit_CopyMeasuresWithinTrack_Join:
	calr	SongEdit_CopyMeasuresToTrack	; F5FB16  calr 0xf5f476
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FB19  jrl T,0xf60011
SongEdit_CopyMeasuresWithinTrack_Skip2:
	xor	hl, hl	; F5FB1C  xor HL,HL
	ld	l, (3215:16)	; F5FB1E  ld L,(0x0c8f)
	dec	1, hl	; F5FB22  dec 1,HL
	muls	l, 3	; F5FB24  muls L,0x03
	push	xix	; F5FB27  push XIX
	ld	xix, 6305024	; F5FB28  ld XIX,0x00603500
	bit	7, (xix+hl)	; F5FB2D  bit 7,(XIX+HL)
	pop	xix	; F5FB32  pop XIX
	jr	nz, SongEdit_CopyMeasuresWithinTrack_Skip3	; F5FB33  jr NZ,0xf5fb3d
	ld	(BStore_ErrorCode:16), 1	; F5FB35  ld (0x0d4a),0x01
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FB3A  jrl T,0xf60011
SongEdit_CopyMeasuresWithinTrack_Skip3:
	call	T_Seq_FindMasterTrack	; F5FB3D  call 0xf427a0
	ld	a, (3214:16)	; F5FB41  ld A,(0x0c8e)
	ld	de, (3187:16)	; F5FB45  ld DE,(0x0c73)
	ld	(3216:16), de	; F5FB49  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F5FB4D  call 0xf42774
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FB51  jrl T,0xf60011
SongEdit_CopyMeasuresWithinTrack_Join2:
	and	(0x0c8a:16), 0xf7	; F5FB54  and (0x0c8a),0xf7
	and	(0x0c8a:16), 0xef	; F5FB59  and (0x0c8a),0xef
	and	(0x0c8a:16), 0x7f	; F5FB5E  and (0x0c8a),0x7f
	ld	(BStore_ErrorCode:16), 0	; F5FB63  ld (0x0d4a),0x00
	xor	wa, wa	; F5FB68  xor WA,WA
	ld	a, (3215:16)	; F5FB6A  ld A,(0x0c8f)
	ld	(3354:16), wa	; F5FB6E  ld (0x0d1a),WA
	call	T_BStore_ValidateSavedCursor	; F5FB72  call 0xf42770
	cp	(BStore_ErrorCode:16), 0x00	; F5FB76  cp (0x0d4a),0x00
	jrl	nz, SongEdit_CopyMeasuresWithinTrack_Return	; F5FB7B  jrl NZ,0xf60011
	ld	(3278:16), iy	; F5FB7E  ld (0x0cce),IY
	ld	wa, (BStore_CursorBlock:16)	; F5FB82  ld WA,(0x345c)
	ld	(3276:16), wa	; F5FB86  ld (0x0ccc),WA
	call	T_Seq_FindMasterTrack	; F5FB8A  call 0xf427a0
	ld	a, (3214:16)	; F5FB8E  ld A,(0x0c8e)
	ld	de, (3187:16)	; F5FB92  ld DE,(0x0c73)
	ld	(3216:16), de	; F5FB96  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F5FB9A  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F5FB9E  cp (0x0d4a),0x00
	jrl	nz, SongEdit_CopyMeasuresWithinTrack_Return	; F5FBA3  jrl NZ,0xf60011
	ld	(3294:16), iy	; F5FBA6  ld (0x0cde),IY
	ld	wa, (BStore_CursorBlock:16)	; F5FBAA  ld WA,(0x345c)
	ld	(3292:16), wa	; F5FBAE  ld (0x0cdc),WA
	ld	hl, wa	; F5FBB2  ld HL,WA
	ld	iy, (3294:16)	; F5FBB4  ld IY,(0x0cde)
	call	T_F42798	; F5FBB8  call 0xf42798
	cp	(BStore_ErrorCode:16), 0x00	; F5FBBC  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip4	; F5FBC1  jr Z,0xf5fbd5
	cp	(BStore_ErrorCode:16), 0x07	; F5FBC3  cp (0x0d4a),0x07
	jrl	nz, SongEdit_CopyMeasuresWithinTrack_Return	; F5FBC8  jrl NZ,0xf60011
	or	(0x0c8a:16), 0x08	; F5FBCB  or (0x0c8a),0x08
	ld	(BStore_ErrorCode:16), 0	; F5FBD0  ld (0x0d4a),0x00
SongEdit_CopyMeasuresWithinTrack_Skip4:
	ld	(3282:16), iy	; F5FBD5  ld (0x0cd2),IY
	ld	wa, (BStore_CursorBlock:16)	; F5FBD9  ld WA,(0x345c)
	ld	(3280:16), wa	; F5FBDD  ld (0x0cd0),WA
	ld	wa, (BStore_AllocBytesWanted:16)	; F5FBE1  ld WA,(0x0cae)
	ld	(3406:16), wa	; F5FBE5  ld (0x0d4e),WA
	ld	w, (3357:16)	; F5FBE9  ld W,(0x0d1d)
	ld	a, (3215:16)	; F5FBED  ld A,(0x0c8f)
	ld	de, (3189:16)	; F5FBF1  ld DE,(0x0c75)
	ld	(3216:16), de	; F5FBF5  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F5FBF9  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F5FBFD  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip5	; F5FC02  jr Z,0xf5fc07
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FC04  jrl T,0xf60011
SongEdit_CopyMeasuresWithinTrack_Skip5:
	ld	(3258:16), iy	; F5FC07  ld (0x0cba),IY
	ld	wa, (BStore_CursorBlock:16)	; F5FC0B  ld WA,(0x345c)
	ld	(3252:16), wa	; F5FC0F  ld (0x0cb4),WA
	ld	hl, wa	; F5FC13  ld HL,WA
	ld	iy, (3258:16)	; F5FC15  ld IY,(0x0cba)
	call	T_F42798	; F5FC19  call 0xf42798
	cp	(BStore_ErrorCode:16), 0x00	; F5FC1D  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip6	; F5FC22  jr Z,0xf5fc36
	cp	(BStore_ErrorCode:16), 0x07	; F5FC24  cp (0x0d4a),0x07
	jrl	nz, SongEdit_CopyMeasuresWithinTrack_Return	; F5FC29  jrl NZ,0xf60011
	or	(0x0c8a:16), 0x10	; F5FC2C  or (0x0c8a),0x10
	ld	(BStore_ErrorCode:16), 0	; F5FC31  ld (0x0d4a),0x00
SongEdit_CopyMeasuresWithinTrack_Skip6:
	ld	(3286:16), iy	; F5FC36  ld (0x0cd6),IY
	ld	wa, (BStore_CursorBlock:16)	; F5FC3A  ld WA,(0x345c)
	ld	(3284:16), wa	; F5FC3E  ld (0x0cd4),WA
	ld	wa, (BStore_AllocBytesWanted:16)	; F5FC42  ld WA,(0x0cae)
	ld	(3248:16), wa	; F5FC46  ld (0x0cb0),WA
	ld	wa, (3406:16)	; F5FC4A  ld WA,(0x0d4e)
	ld	(BStore_AllocBytesWanted:16), wa	; F5FC4E  ld (0x0cae),WA
	bit	3, (0x0c8a:16)	; F5FC52  bit 3,(0x0c8a)
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip7	; F5FC56  jr Z,0xf5fc5b
	jrl	SongEdit_CopyMeasuresWithinTrack_Join10	; F5FC58  jrl T,0xf5ffa8
SongEdit_CopyMeasuresWithinTrack_Skip7:
	ld	wa, (3248:16)	; F5FC5B  ld WA,(0x0cb0)
	cp	wa, (BStore_AllocBytesWanted:16)	; F5FC5F  cp WA,(0x0cae)
	jr	c, SongEdit_CopyMeasuresWithinTrack_Skip8	; F5FC63  jr C,0xf5fc69
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip9	; F5FC65  jr Z,0xf5fc6b
	jr	ugt, SongEdit_CopyMeasuresWithinTrack_Skip10	; F5FC67  jr UGT,0xf5fc6e
SongEdit_CopyMeasuresWithinTrack_Skip8:
	jr	SongEdit_CopyMeasuresWithinTrack_Join3	; F5FC69  jr T,0xf5fc71
SongEdit_CopyMeasuresWithinTrack_Skip9:
	jrl	SongEdit_CopyMeasuresWithinTrack_Join9	; F5FC6B  jrl T,0xf5ff6a
SongEdit_CopyMeasuresWithinTrack_Skip10:
	jrl	SongEdit_CopyMeasuresWithinTrack_Join5	; F5FC6E  jrl T,0xf5fd7e
SongEdit_CopyMeasuresWithinTrack_Join3:
	sub	(BStore_AllocBytesWanted:16), wa	; F5FC71  sub (0x0cae),WA
	ld	wa, (3276:16)	; F5FC75  ld WA,(0x0ccc)
	ld	(BStore_LinkBlock:16), wa	; F5FC79  ld (0x0cc0),WA
	ld	wa, (3278:16)	; F5FC7D  ld WA,(0x0cce)
	ld	(BStore_LastBlockUsed:16), wa	; F5FC81  ld (0x0cc6),WA
	call	T_BStore_AllocChain	; F5FC85  call 0xf427b4
	cp	(BStore_ErrorCode:16), 0x00	; F5FC89  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip11	; F5FC8E  jr Z,0xf5fc93
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FC90  jrl T,0xf60011
SongEdit_CopyMeasuresWithinTrack_Skip11:
	ld	(3300:16), de	; F5FC93  ld (0x0ce4),DE
	ld	wa, (BStore_LastBlockFree:16)	; F5FC97  ld WA,(0x0d08)
	ld	(3302:16), wa	; F5FC9B  ld (0x0ce6),WA
	ld	ix, wa	; F5FC9F  ld IX,WA
	ld	wa, (3300:16)	; F5FCA1  ld WA,(0x0ce4)
	ld	(3159:16), wa	; F5FCA5  ld (0x0c57),WA
	call	T_BStore_SaveCursor	; F5FCA9  call 0xf427b0
	ld	wa, (3276:16)	; F5FCAD  ld WA,(0x0ccc)
	ld	(3169:16), wa	; F5FCB1  ld (0x0c61),WA
	ld	wa, (3278:16)	; F5FCB5  ld WA,(0x0cce)
	ld	(3175:16), wa	; F5FCB9  ld (0x0c67),WA
	ld	wa, (3300:16)	; F5FCBD  ld WA,(0x0ce4)
	ld	(3159:16), wa	; F5FCC1  ld (0x0c57),WA
	ld	wa, (3302:16)	; F5FCC5  ld WA,(0x0ce6)
	ld	(3165:16), wa	; F5FCC9  ld (0x0c5d),WA
	ld	wa, (3189:16)	; F5FCCD  ld WA,(0x0c75)
	add	wa, (0x0c77:16)	; F5FCD1  add WA,(0x0c77)
	cp	wa, (0x0c73:16)	; F5FCD5  cp WA,(0x0c73)
	jr	ugt, SongEdit_CopyMeasuresWithinTrack_Skip14	; F5FCD9  jr UGT,0xf5fd25
	ld	de, (3284:16)	; F5FCDB  ld DE,(0x0cd4)
	ld	wa, (3286:16)	; F5FCDF  ld WA,(0x0cd6)
	ld	(3179:16), wa	; F5FCE3  ld (0x0c6b),WA
	call	T_BStore_CopyRangeBackward	; F5FCE7  call 0xf4277c
	cp	(BStore_ErrorCode:16), 0x00	; F5FCEB  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip12	; F5FCF0  jr Z,0xf5fcf5
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FCF2  jrl T,0xf60011
SongEdit_CopyMeasuresWithinTrack_Skip12:
	ld	wa, (3292:16)	; F5FCF5  ld WA,(0x0cdc)
	ld	(3304:16), wa	; F5FCF9  ld (0x0ce8),WA
	ld	wa, (3294:16)	; F5FCFD  ld WA,(0x0cde)
	ld	(3306:16), wa	; F5FD01  ld (0x0cea),WA
	call	T_BStore_MovePosForward	; F5FD05  call 0xf42780
	cp	(BStore_ErrorCode:16), 0x00	; F5FD09  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip13	; F5FD0E  jr Z,0xf5fd13
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FD10  jrl T,0xf60011
SongEdit_CopyMeasuresWithinTrack_Skip13:
	ld	wa, (3306:16)	; F5FD13  ld WA,(0x0cea)
	ld	(3294:16), wa	; F5FD17  ld (0x0cde),WA
	ld	wa, (3304:16)	; F5FD1B  ld WA,(0x0ce8)
	ld	(3292:16), wa	; F5FD1F  ld (0x0cdc),WA
	jr	SongEdit_CopyMeasuresWithinTrack_Join4	; F5FD23  jr T,0xf5fd4d
SongEdit_CopyMeasuresWithinTrack_Skip14:
	ld	de, (3292:16)	; F5FD25  ld DE,(0x0cdc)
	ld	wa, (3294:16)	; F5FD29  ld WA,(0x0cde)
	ld	(3179:16), wa	; F5FD2D  ld (0x0c6b),WA
	call	T_BStore_CopyRangeBackward	; F5FD31  call 0xf4277c
	cp	(BStore_ErrorCode:16), 0x00	; F5FD35  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip15	; F5FD3A  jr Z,0xf5fd3f
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FD3C  jrl T,0xf60011
SongEdit_CopyMeasuresWithinTrack_Skip15:
	inc	1, ix	; F5FD3F  inc 1,IX
	ld	(3294:16), ix	; F5FD41  ld (0x0cde),IX
	ld	wa, (3159:16)	; F5FD45  ld WA,(0x0c57)
	ld	(3292:16), wa	; F5FD49  ld (0x0cdc),WA
SongEdit_CopyMeasuresWithinTrack_Join4:
	ld	wa, (3280:16)	; F5FD4D  ld WA,(0x0cd0)
	ld	(3304:16), wa	; F5FD51  ld (0x0ce8),WA
	ld	wa, (3282:16)	; F5FD55  ld WA,(0x0cd2)
	ld	(3306:16), wa	; F5FD59  ld (0x0cea),WA
	call	T_BStore_MovePosForward	; F5FD5D  call 0xf42780
	cp	(BStore_ErrorCode:16), 0x00	; F5FD61  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip16	; F5FD66  jr Z,0xf5fd6b
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FD68  jrl T,0xf60011
SongEdit_CopyMeasuresWithinTrack_Skip16:
	ld	wa, (3306:16)	; F5FD6B  ld WA,(0x0cea)
	ld	(3282:16), wa	; F5FD6F  ld (0x0cd2),WA
	ld	wa, (3304:16)	; F5FD73  ld WA,(0x0ce8)
	ld	(3280:16), wa	; F5FD77  ld (0x0cd0),WA
	jrl	SongEdit_CopyMeasuresWithinTrack_Join9	; F5FD7B  jrl T,0xf5ff6a
SongEdit_CopyMeasuresWithinTrack_Join5:
	sub	wa, (BStore_AllocBytesWanted:16)	; F5FD7E  sub WA,(0x0cae)
	ld	(BStore_AllocBytesWanted:16), wa	; F5FD82  ld (0x0cae),WA
	ld	wa, (3189:16)	; F5FD86  ld WA,(0x0c75)
	add	wa, (0x0c77:16)	; F5FD8A  add WA,(0x0c77)
	cp	wa, (0x0c73:16)	; F5FD8E  cp WA,(0x0c73)
	jr	ule, SongEdit_CopyMeasuresWithinTrack_Skip17	; F5FD92  jr ULE,0xf5fd97
	jrl	SongEdit_CopyMeasuresWithinTrack_Join7	; F5FD94  jrl T,0xf5fe93
SongEdit_CopyMeasuresWithinTrack_Skip17:
	ld	wa, (3292:16)	; F5FD97  ld WA,(0x0cdc)
	ld	(3304:16), wa	; F5FD9B  ld (0x0ce8),WA
	ld	wa, (3294:16)	; F5FD9F  ld WA,(0x0cde)
	ld	(3306:16), wa	; F5FDA3  ld (0x0cea),WA
	call	T_BStore_MovePosBackward	; F5FDA7  call 0xf42784
	cp	(BStore_ErrorCode:16), 0x00	; F5FDAB  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip18	; F5FDB0  jr Z,0xf5fdb5
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FDB2  jrl T,0xf60011
SongEdit_CopyMeasuresWithinTrack_Skip18:
	ld	wa, (3306:16)	; F5FDB5  ld WA,(0x0cea)
	ld	(3294:16), wa	; F5FDB9  ld (0x0cde),WA
	ld	wa, (3304:16)	; F5FDBD  ld WA,(0x0ce8)
	ld	(3292:16), wa	; F5FDC1  ld (0x0cdc),WA
	ld	wa, (3280:16)	; F5FDC5  ld WA,(0x0cd0)
	ld	(3304:16), wa	; F5FDC9  ld (0x0ce8),WA
	ld	wa, (3282:16)	; F5FDCD  ld WA,(0x0cd2)
	ld	(3306:16), wa	; F5FDD1  ld (0x0cea),WA
	call	T_BStore_MovePosBackward	; F5FDD5  call 0xf42784
	cp	(BStore_ErrorCode:16), 0x00	; F5FDD9  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip19	; F5FDDE  jr Z,0xf5fde3
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FDE0  jrl T,0xf60011
SongEdit_CopyMeasuresWithinTrack_Skip19:
	ld	wa, (3306:16)	; F5FDE3  ld WA,(0x0cea)
	ld	(3282:16), wa	; F5FDE7  ld (0x0cd2),WA
	ld	wa, (3304:16)	; F5FDEB  ld WA,(0x0ce8)
	ld	(3280:16), wa	; F5FDEF  ld (0x0cd0),WA
	ld	wa, (3284:16)	; F5FDF3  ld WA,(0x0cd4)
	ld	(3304:16), wa	; F5FDF7  ld (0x0ce8),WA
	ld	wa, (3286:16)	; F5FDFB  ld WA,(0x0cd6)
	ld	(3306:16), wa	; F5FDFF  ld (0x0cea),WA
	call	T_BStore_MovePosBackward	; F5FE03  call 0xf42784
	cp	(BStore_ErrorCode:16), 0x00	; F5FE07  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip20	; F5FE0C  jr Z,0xf5fe11
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FE0E  jrl T,0xf60011
SongEdit_CopyMeasuresWithinTrack_Skip20:
	ld	wa, (3306:16)	; F5FE11  ld WA,(0x0cea)
	ld	(3290:16), wa	; F5FE15  ld (0x0cda),WA
	ld	wa, (3304:16)	; F5FE19  ld WA,(0x0ce8)
	ld	(3288:16), wa	; F5FE1D  ld (0x0cd8),WA
	ld	wa, (3284:16)	; F5FE21  ld WA,(0x0cd4)
	ld	(3169:16), wa	; F5FE25  ld (0x0c61),WA
	ld	wa, (3286:16)	; F5FE29  ld WA,(0x0cd6)
	ld	(3175:16), wa	; F5FE2D  ld (0x0c67),WA
	ld	wa, (3288:16)	; F5FE31  ld WA,(0x0cd8)
	ld	(3159:16), wa	; F5FE35  ld (0x0c57),WA
	ld	wa, (3290:16)	; F5FE39  ld WA,(0x0cda)
	ld	(3165:16), wa	; F5FE3D  ld (0x0c5d),WA
	ld	de, (3276:16)	; F5FE41  ld DE,(0x0ccc)
	ld	wa, (3278:16)	; F5FE45  ld WA,(0x0cce)
	ld	(3179:16), wa	; F5FE49  ld (0x0c6b),WA
	call	T_F42778	; F5FE4D  call 0xf42778
	cp	(BStore_ErrorCode:16), 0x00	; F5FE51  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip21	; F5FE56  jr Z,0xf5fe5b
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FE58  jrl T,0xf60011
SongEdit_CopyMeasuresWithinTrack_Skip21:
	cp	ix, 5:i3	; F5FE5B  cp IX,5
	jr	nz, SongEdit_CopyMeasuresWithinTrack_Join6	; F5FE5D  jr NZ,0xf5fe7c
	ld	hl, (3159:16)	; F5FE5F  ld HL,(0x0c57)
	call	T_BStore_SeekBlock	; F5FE63  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5FE67  ld XHL,(0x126e)
	ld	hl, (xhl+1)	; F5FE6B  ld HL,(XHL+0x01)
	cp	hl, 0:i3	; F5FE6E  cp HL,0
	jrl	z, SongEdit_CopyMeasuresWithinTrack_Return	; F5FE70  jrl Z,0xf60011
	ld	(3159:16), hl	; F5FE73  ld (0x0c57),HL
	ldw	ix, 255	; F5FE77  ld IX,0x00ff
	jr	SongEdit_CopyMeasuresWithinTrack_Join6	; F5FE7A  jr T,0xf5fe7c
SongEdit_CopyMeasuresWithinTrack_Join6:
	dec	1, ix	; F5FE7C  dec 1,IX
	call	T_BStore_SaveCursor	; F5FE7E  call 0xf427b0
	call	T_BStore_TruncateChainAfterBlock	; F5FE82  call 0xf42794
	cp	(BStore_ErrorCode:16), 0x00	; F5FE86  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip22	; F5FE8B  jr Z,0xf5fe90
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FE8D  jrl T,0xf60011
SongEdit_CopyMeasuresWithinTrack_Skip22:
	jrl	SongEdit_CopyMeasuresWithinTrack_Join9	; F5FE90  jrl T,0xf5ff6a
SongEdit_CopyMeasuresWithinTrack_Join7:
	ld	wa, (3280:16)	; F5FE93  ld WA,(0x0cd0)
	ld	(3304:16), wa	; F5FE97  ld (0x0ce8),WA
	ld	wa, (3282:16)	; F5FE9B  ld WA,(0x0cd2)
	ld	(3306:16), wa	; F5FE9F  ld (0x0cea),WA
	call	T_BStore_MovePosBackward	; F5FEA3  call 0xf42784
	cp	(BStore_ErrorCode:16), 0x00	; F5FEA7  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip23	; F5FEAC  jr Z,0xf5feb1
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FEAE  jrl T,0xf60011
SongEdit_CopyMeasuresWithinTrack_Skip23:
	ld	wa, (3306:16)	; F5FEB1  ld WA,(0x0cea)
	ld	(3282:16), wa	; F5FEB5  ld (0x0cd2),WA
	ld	wa, (3304:16)	; F5FEB9  ld WA,(0x0ce8)
	ld	(3280:16), wa	; F5FEBD  ld (0x0cd0),WA
	ld	wa, (3292:16)	; F5FEC1  ld WA,(0x0cdc)
	ld	(3304:16), wa	; F5FEC5  ld (0x0ce8),WA
	ld	wa, (3294:16)	; F5FEC9  ld WA,(0x0cde)
	ld	(3306:16), wa	; F5FECD  ld (0x0cea),WA
	call	T_BStore_MovePosBackward	; F5FED1  call 0xf42784
	cp	(BStore_ErrorCode:16), 0x00	; F5FED5  cp (0x0d4a),0x00
	jrl	nz, SongEdit_CopyMeasuresWithinTrack_Return	; F5FEDA  jrl NZ,0xf60011
	ld	wa, (3306:16)	; F5FEDD  ld WA,(0x0cea)
	ld	(3298:16), wa	; F5FEE1  ld (0x0ce2),WA
	ld	wa, (3304:16)	; F5FEE5  ld WA,(0x0ce8)
	ld	(3296:16), wa	; F5FEE9  ld (0x0ce0),WA
	ld	wa, (3292:16)	; F5FEED  ld WA,(0x0cdc)
	ld	(3169:16), wa	; F5FEF1  ld (0x0c61),WA
	ld	wa, (3294:16)	; F5FEF5  ld WA,(0x0cde)
	ld	(3175:16), wa	; F5FEF9  ld (0x0c67),WA
	ld	wa, (3296:16)	; F5FEFD  ld WA,(0x0ce0)
	ld	(3159:16), wa	; F5FF01  ld (0x0c57),WA
	ld	wa, (3298:16)	; F5FF05  ld WA,(0x0ce2)
	ld	(3165:16), wa	; F5FF09  ld (0x0c5d),WA
	ld	de, (3276:16)	; F5FF0D  ld DE,(0x0ccc)
	ld	wa, (3278:16)	; F5FF11  ld WA,(0x0cce)
	ld	(3179:16), wa	; F5FF15  ld (0x0c6b),WA
	call	T_F42778	; F5FF19  call 0xf42778
	cp	(BStore_ErrorCode:16), 0x00	; F5FF1D  cp (0x0d4a),0x00
	jrl	nz, SongEdit_CopyMeasuresWithinTrack_Return	; F5FF22  jrl NZ,0xf60011
	cp	ix, 5:i3	; F5FF25  cp IX,5
	jr	nz, SongEdit_CopyMeasuresWithinTrack_Skip24	; F5FF27  jr NZ,0xf5ff46
	ld	hl, (3159:16)	; F5FF29  ld HL,(0x0c57)
	call	T_BStore_SeekBlock	; F5FF2D  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5FF31  ld XHL,(0x126e)
	ld	hl, (xhl+1)	; F5FF35  ld HL,(XHL+0x01)
	cp	hl, 0:i3	; F5FF38  cp HL,0
	jrl	z, SongEdit_CopyMeasuresWithinTrack_Return	; F5FF3A  jrl Z,0xf60011
	ld	(3159:16), hl	; F5FF3D  ld (0x0c57),HL
	ldw	ix, 255	; F5FF41  ld IX,0x00ff
	jr	SongEdit_CopyMeasuresWithinTrack_Join8	; F5FF44  jr T,0xf5ff48
SongEdit_CopyMeasuresWithinTrack_Skip24:
	dec	1, ix	; F5FF46  dec 1,IX
SongEdit_CopyMeasuresWithinTrack_Join8:
	call	T_BStore_SaveCursor	; F5FF48  call 0xf427b0
	call	T_BStore_TruncateChainAfterBlock	; F5FF4C  call 0xf42794
	cp	(BStore_ErrorCode:16), 0x00	; F5FF50  cp (0x0d4a),0x00
	jr	z, SongEdit_CopyMeasuresWithinTrack_Skip25	; F5FF55  jr Z,0xf5ff5a
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FF57  jrl T,0xf60011
SongEdit_CopyMeasuresWithinTrack_Skip25:
	ld	wa, (3296:16)	; F5FF5A  ld WA,(0x0ce0)
	ld	(3292:16), wa	; F5FF5E  ld (0x0cdc),WA
	ld	wa, (3298:16)	; F5FF62  ld WA,(0x0ce2)
	ld	(3294:16), wa	; F5FF66  ld (0x0cde),WA
SongEdit_CopyMeasuresWithinTrack_Join9:
	ld	wa, (3292:16)	; F5FF6A  ld WA,(0x0cdc)
	ld	(3169:16), wa	; F5FF6E  ld (0x0c61),WA
	ld	wa, (3294:16)	; F5FF72  ld WA,(0x0cde)
	ld	(3175:16), wa	; F5FF76  ld (0x0c67),WA
	ld	wa, (3252:16)	; F5FF7A  ld WA,(0x0cb4)
	ld	(3159:16), wa	; F5FF7E  ld (0x0c57),WA
	ld	wa, (3258:16)	; F5FF82  ld WA,(0x0cba)
	ld	(3165:16), wa	; F5FF86  ld (0x0c5d),WA
	ld	de, (3280:16)	; F5FF8A  ld DE,(0x0cd0)
	ld	wa, (3282:16)	; F5FF8E  ld WA,(0x0cd2)
	ld	(3179:16), wa	; F5FF92  ld (0x0c6b),WA
	call	T_F42778	; F5FF96  call 0xf42778
	cp	(BStore_ErrorCode:16), 0x00	; F5FF9A  cp (0x0d4a),0x00
	jrl	z, SongEdit_CopyMeasuresWithinTrack_Return	; F5FF9F  jrl Z,0xf60011
	jrl	SongEdit_CopyMeasuresWithinTrack_Return	; F5FFA2  jrl T,0xf60011
	nop	; F5FFA5  nop
	nop	; F5FFA6  nop
	nop	; F5FFA7  nop
SongEdit_CopyMeasuresWithinTrack_Join10:
	ld	wa, (3292:16)	; F5FFA8  ld WA,(0x0cdc)
	ld	(3169:16), wa	; F5FFAC  ld (0x0c61),WA
	ld	wa, (3294:16)	; F5FFB0  ld WA,(0x0cde)
	ld	(3175:16), wa	; F5FFB4  ld (0x0c67),WA
	ld	wa, (3252:16)	; F5FFB8  ld WA,(0x0cb4)
	ld	(3159:16), wa	; F5FFBC  ld (0x0c57),WA
	ld	wa, (3258:16)	; F5FFC0  ld WA,(0x0cba)
	ld	(3165:16), wa	; F5FFC4  ld (0x0c5d),WA
	ld	de, (3276:16)	; F5FFC8  ld DE,(0x0ccc)
	ld	wa, (3278:16)	; F5FFCC  ld WA,(0x0cce)
	ld	(3179:16), wa	; F5FFD0  ld (0x0c6b),WA
	call	T_F42778	; F5FFD4  call 0xf42778
	cp	(BStore_ErrorCode:16), 0x00	; F5FFD8  cp (0x0d4a),0x00
	jr	nz, SongEdit_CopyMeasuresWithinTrack_Return	; F5FFDD  jr NZ,0xf60011
	cp	ix, 5:i3	; F5FFDF  cp IX,5
	jr	nz, SongEdit_CopyMeasuresWithinTrack_Skip26	; F5FFE1  jr NZ,0xf5ffff
	ld	hl, (3159:16)	; F5FFE3  ld HL,(0x0c57)
	call	T_BStore_SeekBlock	; F5FFE7  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F5FFEB  ld XHL,(0x126e)
	ld	hl, (xhl+1)	; F5FFEF  ld HL,(XHL+0x01)
	cp	hl, 0:i3	; F5FFF2  cp HL,0
	jr	z, SongEdit_CopyMeasuresWithinTrack_Return	; F5FFF4  jr Z,0xf60011
	ld	(3159:16), hl	; F5FFF6  ld (0x0c57),HL
	ldw	ix, 255	; F5FFFA  ld IX,0x00ff
	jr	SongEdit_CopyMeasuresWithinTrack_Join15	; F5FFFD  jr T,0xf60001
SongEdit_CopyMeasuresWithinTrack_Skip26:
	dec	1, ix	; F5FFFF  dec 1,IX
SongEdit_CopyMeasuresWithinTrack_Join15:
	call	T_BStore_SaveCursor	; F60001  call 0xf427b0
	call	T_BStore_TruncateChainAfterBlock	; F60005  call 0xf42794
	cp	(BStore_ErrorCode:16), 0x00	; F60009  cp (0x0d4a),0x00
	nop	; F6000E  nop
	nop	; F6000F  nop
	nop	; F60010  nop
SongEdit_CopyMeasuresWithinTrack_Return:
	ret	; F60011  ret

; --------------------------------------------------------------------------
; TrackMerge_Execute
; Called from: T_TrackMerge_Execute (x1)
; Touches: (0x0C06) (0x0C70) (0x0C71) (0x0C72) (0x0C83) (0x0C8A) (0x0C8B)
;          (0x0C94) (0x0CA2) (0x0CB6) +11 more  |  0x603422 0x603500
;          0x60A000 0x60A100
; Calls:   T_BStore_LoadGeometry T_TrackMerge_RewriteSource2ForPart T_BStore_OpenChain SongEdit_ClearTrack TrackMerge_DetachSourceTrack T_BStore_SeekBlock
;          TrackMerge_LoadAndFreeBlock T_BStore_AllocBlock_Veneer TrackMerge_FetchSource1Event TrackMerge_FetchSource2Event TrackMerge_CopySource1ToMark TrackMerge_EmitCommonMark
;          +5 more
; Evidence: thunk slot T_TrackMerge_Execute holds `jp 0x00F60012`, and 0xF60012 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_Execute: The TRACK MERGE job (TrackMerge_LcdKeyRow2 stages its three fields into
;   (0x0C70)/(0x0C71)/(0x0C72) and calls T_TrackMerge_Execute): sources (0x0C70) != (0x0C71) and destination (0x0C72) 1..(0x0CA2)
;   (error 3), no master part 0x20 (error 9); clears the destination unless it is a source (SongEdit_ClearTrack), gives it
;   source 1's part and a new chain, and merges both streams into it. Twin of Smf_MergeTrack2IntoTrack1's Smf_MergeTracks.
;   Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
TrackMerge_Execute:		; <- T_TrackMerge_Execute
	call	T_BStore_LoadGeometry	; F60012  call 0xf427c4
	ld	a, (3184:16)	; F60016  ld A,(0x0c70)
	cp	a, 1:i3	; F6001A  cp A,1
	jr	c, TrackMerge_Execute_Skip27	; F6001C  jr C,0xf60046
	cp	a, (0x0ca2:16)	; F6001E  cp A,(0x0ca2)
	jr	ugt, TrackMerge_Execute_Skip27	; F60022  jr UGT,0xf60046
	cp	a, (0x0c71:16)	; F60024  cp A,(0x0c71)
	jr	z, TrackMerge_Execute_Skip27	; F60028  jr Z,0xf60046
	ld	a, (3185:16)	; F6002A  ld A,(0x0c71)
	cp	a, 1:i3	; F6002E  cp A,1
	jr	c, TrackMerge_Execute_Skip27	; F60030  jr C,0xf60046
	cp	a, (0x0ca2:16)	; F60032  cp A,(0x0ca2)
	jr	ugt, TrackMerge_Execute_Skip27	; F60036  jr UGT,0xf60046
	ld	a, (3186:16)	; F60038  ld A,(0x0c72)
	cp	a, 1:i3	; F6003C  cp A,1
	jr	c, TrackMerge_Execute_Skip27	; F6003E  jr C,0xf60046
	cp	a, (0x0ca2:16)	; F60040  cp A,(0x0ca2)
	jr	ule, TrackMerge_Execute_Skip28	; F60044  jr ULE,0xf6004e
TrackMerge_Execute_Skip27:
	ld	(BStore_ErrorCode:16), 3	; F60046  ld (0x0d4a),0x03
	jrl	TrackMerge_Execute_Join14	; F6004B  jrl T,0xf6025e
TrackMerge_Execute_Skip28:
	xor	hl, hl	; F6004E  xor HL,HL
	ld	(BStore_ErrorCode:16), 0	; F60050  ld (0x0d4a),0x00
	and	(0x0c8a:16), 0xbf	; F60055  and (0x0c8a),0xbf
	ld	l, (3184:16)	; F6005A  ld L,(0x0c70)
	dec	1, hl	; F6005E  dec 1,HL
	push	xix	; F60060  push XIX
	ld	xix, BStore_TrackToPart	; F60061  ld XIX,0x00603422
	ld	a, (xix+hl)	; F60066  ld A,(XIX+HL)
	pop	xix	; F6006B  pop XIX
	cp	a, 32	; F6006C  cp A,0x20
	jr	z, TrackMerge_Execute_Skip29	; F6006F  jr Z,0xf6008e
	ld	(3220:16), a	; F60071  ld (0x0c94),A
	xor	hl, hl	; F60075  xor HL,HL
	ld	l, (3185:16)	; F60077  ld L,(0x0c71)
	dec	1, hl	; F6007B  dec 1,HL
	push	xix	; F6007D  push XIX
	ld	xix, BStore_TrackToPart	; F6007E  ld XIX,0x00603422
	ld	a, (xix+hl)	; F60083  ld A,(XIX+HL)
	pop	xix	; F60088  pop XIX
	cp	a, 32	; F60089  cp A,0x20
	jr	nz, TrackMerge_Execute_Skip30	; F6008C  jr NZ,0xf60096
TrackMerge_Execute_Skip29:
	ld	(BStore_ErrorCode:16), 9	; F6008E  ld (0x0d4a),0x09
	jrl	TrackMerge_Execute_Join14	; F60093  jrl T,0xf6025e
TrackMerge_Execute_Skip30:
	ld	(3211:16), 0	; F60096  ld (0x0c8b),0x00
	xor	hl, hl	; F6009B  xor HL,HL
	ld	l, (3184:16)	; F6009D  ld L,(0x0c70)
	dec	1, hl	; F600A1  dec 1,HL
	push	xix	; F600A3  push XIX
	ld	xix, BStore_TrackToPart	; F600A4  ld XIX,0x00603422
	ld	a, (xix+hl)	; F600A9  ld A,(XIX+HL)
	ld	l, (3185:16)	; F600AE  ld L,(0x0c71)
	dec	1, hl	; F600B2  dec 1,HL
	cp	a, (xix+hl)	; F600B4  cp A,(XIX+HL)
	pop	xix	; F600B9  pop XIX
	jr	z, TrackMerge_Execute_Skip31	; F600BA  jr Z,0xf600fa
	ld	(3203:16), l	; F600BC  ld (0x0c83),L
	xor	hl, hl	; F600C0  xor HL,HL
	ld	l, (3185:16)	; F600C2  ld L,(0x0c71)
	dec	1, l	; F600C6  dec 1,L
	push	xix	; F600C8  push XIX
	ld	xix, BStore_TrackToPart	; F600C9  ld XIX,0x00603422
	ld	l, (xix+hl)	; F600CE  ld L,(XIX+HL)
	ld	(3078:16), l	; F600D3  ld (0x0c06),L
	pop	xix	; F600D7  pop XIX
	xor	hl, hl	; F600D8  xor HL,HL
	ld	l, a	; F600DA  ld L,A
	push	xix	; F600DC  push XIX
	ld	xix, IdentityMap_0_31	; F600DD  ld XIX,0x00f5ee75
	ld	l, (xix+hl)	; F600E2  ld L,(XIX+HL)
	ld	(3396:16), l	; F600E7  ld (0x0d44),L
	pop	xix	; F600EB  pop XIX
	call	T_TrackMerge_RewriteSource2ForPart	; F600EC  call 0xf4280c
	cp	(BStore_ErrorCode:16), 0x00	; F600F0  cp (0x0d4a),0x00
	jr	z, TrackMerge_Execute_Skip31	; F600F5  jr Z,0xf600fa
	jrl	TrackMerge_Execute_Join14	; F600F7  jrl T,0xf6025e
TrackMerge_Execute_Skip31:
	ld	a, (3184:16)	; F600FA  ld A,(0x0c70)
	call	T_BStore_OpenChain	; F600FE  call 0xf427ac
	cp	(BStore_ErrorCode:16), 0x00	; F60102  cp (0x0d4a),0x00
	jr	z, TrackMerge_Execute_Skip32	; F60107  jr Z,0xf6010c
	jrl	TrackMerge_Execute_Join14	; F60109  jrl T,0xf6025e
TrackMerge_Execute_Skip32:
	ld	wa, (BStore_CursorBlock:16)	; F6010C  ld WA,(0x345c)
	ld	(3320:16), wa	; F60110  ld (0x0cf8),WA
	ld	a, (3185:16)	; F60114  ld A,(0x0c71)
	call	T_BStore_OpenChain	; F60118  call 0xf427ac
	cp	(BStore_ErrorCode:16), 0x00	; F6011C  cp (0x0d4a),0x00
	jr	z, TrackMerge_Execute_Skip33	; F60121  jr Z,0xf60126
	jrl	TrackMerge_Execute_Join14	; F60123  jrl T,0xf6025e
TrackMerge_Execute_Skip33:
	ld	wa, (BStore_CursorBlock:16)	; F60126  ld WA,(0x345c)
	ld	(3326:16), wa	; F6012A  ld (0x0cfe),WA
	ld	a, (3186:16)	; F6012E  ld A,(0x0c72)
	cp	a, (0x0c70:16)	; F60132  cp A,(0x0c70)
	jr	nz, TrackMerge_Execute_Skip34	; F60136  jr NZ,0xf6013a
	jr	TrackMerge_Execute_Join11	; F60138  jr T,0xf60157
TrackMerge_Execute_Skip34:
	cp	a, (0x0c71:16)	; F6013A  cp A,(0x0c71)
	jr	nz, TrackMerge_Execute_Skip35	; F6013E  jr NZ,0xf60142
	jr	TrackMerge_Execute_Join11	; F60140  jr T,0xf60157
TrackMerge_Execute_Skip35:
	ld	a, (3184:16)	; F60142  ld A,(0x0c70)
	pushw	wa	; F60146  push WA
	ld	a, (3186:16)	; F60147  ld A,(0x0c72)
	ld	(3184:16), a	; F6014B  ld (0x0c70),A
	calr	SongEdit_ClearTrack	; F6014F  calr 0xf6079e
	popw	wa	; F60152  pop WA
	ld	(3184:16), a	; F60153  ld (0x0c70),A
TrackMerge_Execute_Join11:
	xor	hl, hl	; F60157  xor HL,HL
	ld	l, (3184:16)	; F60159  ld L,(0x0c70)
	call	TrackMerge_DetachSourceTrack	; F6015D  call 0xf60548
	ld	xix, 6332416	; F60161  ld XIX,0x0060a000
	nop	; F60166  nop
	ld	wa, (3320:16)	; F60167  ld WA,(0x0cf8)
	ld	(BStore_CursorBlock:16), wa	; F6016B  ld (0x345c),WA
	ld	hl, wa	; F6016F  ld HL,WA
	call	T_BStore_SeekBlock	; F60171  call 0xf427bc
	calr	TrackMerge_LoadAndFreeBlock	; F60175  calr 0xf60514
	ld	(3322:16), iy	; F60178  ld (0x0cfa),IY
	xor	hl, hl	; F6017C  xor HL,HL
	ld	l, (3185:16)	; F6017E  ld L,(0x0c71)
	call	TrackMerge_DetachSourceTrack	; F60182  call 0xf60548
	ld	xix, 6332672	; F60186  ld XIX,0x0060a100
	nop	; F6018B  nop
	ld	wa, (3326:16)	; F6018C  ld WA,(0x0cfe)
	ld	(BStore_CursorBlock:16), wa	; F60190  ld (0x345c),WA
	ld	hl, wa	; F60194  ld HL,WA
	call	T_BStore_SeekBlock	; F60196  call 0xf427bc
	call	TrackMerge_LoadAndFreeBlock	; F6019A  call 0xf60514
	ld	(3328:16), iy	; F6019E  ld (0x0d00),IY
	call	T_BStore_AllocBlock_Veneer	; F601A2  call 0xf42884
	xor	hl, hl	; F601A6  xor HL,HL
	ld	l, (3186:16)	; F601A8  ld L,(0x0c72)
	dec	1, hl	; F601AC  dec 1,HL
	ld	a, (3220:16)	; F601AE  ld A,(0x0c94)
	push	xix	; F601B2  push XIX
	ld	xix, BStore_TrackToPart	; F601B3  ld XIX,0x00603422
	ld	(xix+hl), a	; F601B8  ld (XIX+HL),A
	pop	xix	; F601BD  pop XIX
	muls	hl, 3	; F601BE  muls HL,0x0003
	push	xiy	; F601C2  push XIY
	ld	xiy, 6305024	; F601C3  ld XIY,0x00603500
	or	(xiy+hl), 0x80	; F601C8  or (XIY+HL),0x80
	inc	1, hl	; F601CE  inc 1,HL
	ld	(xiy+hl), ix	; F601D0  ld (XIY+HL),IX
	pop	xiy	; F601D5  pop XIY
	ld	(3332:16), ix	; F601D6  ld (0x0d04),IX
	ld	hl, ix	; F601DA  ld HL,IX
	call	T_BStore_SeekBlock	; F601DC  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F601E0  ld XHL,(0x126e)
	ld	(3254:16), xhl	; F601E4  ld (0x0cb6),XHL
	ldw	ix, 5	; F601E8  ld IX,0x0005
	ld	xhl, (BStore_CursorBlockAddr:16)	; F601EB  ld XHL,(0x126e)
	ldw	(xhl+1), 0x0000	; F601EF  ld (XHL+0x01),0x0000
	ldw	(xhl+3), 0xffff	; F601F4  ld (XHL+0x03),0xffff
	call	TrackMerge_FetchSource1Event	; F601F9  call 0xf60338
	call	TrackMerge_FetchSource2Event	; F601FD  call 0xf602f0
TrackMerge_Execute_Join12:
	cp	(0x0c8b:16), 0xff	; F60201  cp (0x0c8b),0xff
	jr	nz, TrackMerge_Execute_Skip36	; F60206  jr NZ,0xf6020b
	jrl	TrackMerge_Execute_Join14	; F60208  jrl T,0xf6025e
TrackMerge_Execute_Skip36:
	cp	(0x0c8b:16), 0x03	; F6020B  cp (0x0c8b),0x03
	jr	z, TrackMerge_Execute_Skip37	; F60210  jr Z,0xf60214
	jr	TrackMerge_Execute_Join13	; F60212  jr T,0xf6022e
TrackMerge_Execute_Skip37:
	cp	c, b	; F60214  cp C,B
	jr	c, TrackMerge_Execute_Skip38	; F60216  jr C,0xf6021c
	jr	z, TrackMerge_Execute_Skip39	; F60218  jr Z,0xf60222
	jr	ugt, TrackMerge_Execute_Skip40	; F6021A  jr UGT,0xf60228
TrackMerge_Execute_Skip38:
	call	TrackMerge_CopySource1ToMark	; F6021C  call 0xf60267
	jr	TrackMerge_Execute_Join12	; F60220  jr T,0xf60201
TrackMerge_Execute_Skip39:
	call	TrackMerge_EmitCommonMark	; F60222  call 0xf6027d
	jr	TrackMerge_Execute_Join12	; F60226  jr T,0xf60201
TrackMerge_Execute_Skip40:
	call	TrackMerge_CopySource2ToMark	; F60228  call 0xf60272
	jr	TrackMerge_Execute_Join12	; F6022C  jr T,0xf60201
TrackMerge_Execute_Join13:
	bit	0, (0x0c8b:16)	; F6022E  bit 0,(0x0c8b)
	jr	z, TrackMerge_Execute_Skip41	; F60232  jr Z,0xf6023a
	call	TrackMerge_CopySource2ToMark	; F60234  call 0xf60272
	jr	TrackMerge_Execute_Join12	; F60238  jr T,0xf60201
TrackMerge_Execute_Skip41:
	bit	1, (0x0c8b:16)	; F6023A  bit 1,(0x0c8b)
	jr	z, TrackMerge_Execute_Skip42	; F6023E  jr Z,0xf60246
	call	TrackMerge_CopySource1ToMark	; F60240  call 0xf60267
	jr	TrackMerge_Execute_Join12	; F60244  jr T,0xf60201
TrackMerge_Execute_Skip42:
	ld	a, (3358:16)	; F60246  ld A,(0x0d1e)
	ld	w, (3359:16)	; F6024A  ld W,(0x0d1f)
	cp	a, w	; F6024E  cp A,W
	jr	le, TrackMerge_Execute_Skip43	; F60250  jr LE,0xf60258
	call	TrackMerge_CopySource2Event	; F60252  call 0xf60380
	jr	TrackMerge_Execute_Join12	; F60256  jr T,0xf60201
TrackMerge_Execute_Skip43:
	call	TrackMerge_CopySource1Event	; F60258  call 0xf603e9
	jr	TrackMerge_Execute_Join12	; F6025C  jr T,0xf60201
TrackMerge_Execute_Join14:
	call	T_BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_48	; F6025E  call 0xf4281c
	call	T_F40A1C	; F60262  call 0xf40a1c
	ret	; F60266  ret

; --------------------------------------------------------------------------
; TrackMerge_CopySource1ToMark
; Called from: in-module: 0xF6021C 0xF60240
; Touches: (0x0C8B)
; Calls:   TrackMerge_CopySource1Event
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF60267 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_CopySource1ToMark: Repeats TrackMerge_CopySource1Event until TrackMerge_FetchSource1Event sets (0x0C8B)
;   bit 0, i.e. copies source 1's events into the merged track up to its next 0x81 beat mark or 0x82 end.
;   TrackMerge_Execute runs it when source 2 already waits at a mark (bit 1) or ended while source 1 still has a beat.
;   Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
TrackMerge_CopySource1ToMark:
	call	TrackMerge_CopySource1Event	; F60267  call 0xf603e9
	bit	0, (0x0c8b:16)	; F6026B  bit 0,(0x0c8b)
	jr	z, TrackMerge_CopySource1ToMark	; F6026F  jr Z,0xf60267
	ret	; F60271  ret

; --------------------------------------------------------------------------
; TrackMerge_CopySource2ToMark
; Called from: in-module: 0xF60228 0xF60234
; Touches: (0x0C8B)
; Calls:   TrackMerge_CopySource2Event
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF60272 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_CopySource2ToMark: Repeats TrackMerge_CopySource2Event until TrackMerge_FetchSource2Event sets (0x0C8B)
;   bit 1: copies source 2's events into the merged track up to its next 0x81 beat mark or 0x82 end. Twin of
;   TrackMerge_CopySource1ToMark. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
TrackMerge_CopySource2ToMark:
	call	TrackMerge_CopySource2Event	; F60272  call 0xf60380
	bit	1, (0x0c8b:16)	; F60276  bit 1,(0x0c8b)
	jr	z, TrackMerge_CopySource2ToMark	; F6027A  jr Z,0xf60272
	ret	; F6027C  ret

; --------------------------------------------------------------------------
; TrackMerge_EmitCommonMark
; Called from: in-module: 0xF60222
; Touches: (0x0C57) (0x0C72) (0x0C8B) (0x0CFA) (0x0D00) (0x0D04) (0x0D1A)
;          (0x126E)  |  0x60A000 0x60A100
; Calls:   T_BStore_SaveCursor TrackMerge_AdvanceWriteCursor TrackMerge_AdvanceReadCursor TrackMerge_FetchSource1Event TrackMerge_FetchSource2Event
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF6027D is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_EmitCommonMark: Both TRACK MERGE sources stand on the same mark (C == B): for 0x82 writes the end mark,
;   sets (0x0C8B) = 0xFF (done) and saves the destination (0x0C72)'s end cursor at block (0x0D04) / offset IX; for
;   0x81 writes one beat mark, advances the write cursor and both source read cursors and fetches both next events.
;   Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
TrackMerge_EmitCommonMark:
	cp	c, 130	; F6027D  cp C,0x82
	jr	nz, TrackMerge_EmitCommonMark_Skip	; F60280  jr NZ,0xf602a9
	ld	xhl, (BStore_CursorBlockAddr:16)	; F60282  ld XHL,(0x126e)
	ld	(xhl+ix), 0x82	; F60286  ld (XHL+IX),0x82
	ld	(3211:16), 255	; F6028C  ld (0x0c8b),0xff
	ld	wa, (3332:16)	; F60291  ld WA,(0x0d04)
	ld	(3159:16), wa	; F60295  ld (0x0c57),WA
	xor	wa, wa	; F60299  xor WA,WA
	ld	a, (3186:16)	; F6029B  ld A,(0x0c72)
	ld	(3354:16), wa	; F6029F  ld (0x0d1a),WA
	call	T_BStore_SaveCursor	; F602A3  call 0xf427b0
	jr	TrackMerge_EmitCommonMark_Return	; F602A7  jr T,0xf602ef
TrackMerge_EmitCommonMark_Skip:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F602A9  ld XHL,(0x126e)
	ld	(xhl+ix), 0x81	; F602AD  ld (XHL+IX),0x81
	call	TrackMerge_AdvanceWriteCursor	; F602B3  call 0xf60457
	ld	xhl, (BStore_CursorBlockAddr:16)	; F602B7  ld XHL,(0x126e)
	push	xix	; F602BB  push XIX
	ld	xix, 6332416	; F602BC  ld XIX,0x0060a000
	nop	; F602C1  nop
	ld	iy, (3322:16)	; F602C2  ld IY,(0x0cfa)
	calr	TrackMerge_AdvanceReadCursor	; F602C6  calr 0xf604b7
	ld	(3322:16), iy	; F602C9  ld (0x0cfa),IY
	call	TrackMerge_FetchSource1Event	; F602CD  call 0xf60338
	ld	(3322:16), iy	; F602D1  ld (0x0cfa),IY
	ld	xix, 6332672	; F602D5  ld XIX,0x0060a100
	nop	; F602DA  nop
	ld	iy, (3328:16)	; F602DB  ld IY,(0x0d00)
	calr	TrackMerge_AdvanceReadCursor	; F602DF  calr 0xf604b7
	ld	(3328:16), iy	; F602E2  ld (0x0d00),IY
	call	TrackMerge_FetchSource2Event	; F602E6  call 0xf602f0
	ld	(3328:16), iy	; F602EA  ld (0x0d00),IY
	pop	xix	; F602EE  pop XIX
TrackMerge_EmitCommonMark_Return:
	ret	; F602EF  ret

; --------------------------------------------------------------------------
; TrackMerge_FetchSource2Event
; Called from: in-module: 0xF601FD 0xF602E6 0xF603E4
; Touches: (0x0C8B) (0x0D00) (0x0D1F)  |  0x60A100
; Calls:   TrackMerge_AdvanceReadCursor
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF602F0 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_FetchSource2Event: Reads source 2's next item from its staging buffer 0x60A100 at (0x0D00): B = status; a
;   0x81 beat mark or 0x82 end sets (0x0C8B) bit 1 and stays put, otherwise the cursor steps past the status and
;   (0x0D1F) := the event's timing byte. TrackMerge_Execute primes it after loading source 2's first block; the copy
;   routines call it after each event. Twin of TrackMerge_FetchSource1Event. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_t.json)
TrackMerge_FetchSource2Event:
	and	(0x0c8b:16), 0xfd	; F602F0  and (0x0c8b),0xfd
	ld	iy, (3328:16)	; F602F5  ld IY,(0x0d00)
	push	xix	; F602F9  push XIX
	ld	xix, 6332672	; F602FA  ld XIX,0x0060a100
	ld	b, (xix+iy)	; F602FF  ld B,(XIX+IY)
	pop	xix	; F60304  pop XIX
	cp	b, 130	; F60305  cp B,0x82
	jr	z, TrackMerge_FetchSource2Event_Skip	; F60308  jr Z,0xf6030f
	cp	b, 129	; F6030A  cp B,0x81
	jr	nz, TrackMerge_FetchSource2Event_Skip2	; F6030D  jr NZ,0xf60316
TrackMerge_FetchSource2Event_Skip:
	or	(0x0c8b:16), 0x02	; F6030F  or (0x0c8b),0x02
	jr	TrackMerge_FetchSource2Event_Return	; F60314  jr T,0xf60337
TrackMerge_FetchSource2Event_Skip2:
	pushw	bc	; F60316  push BC
	push	xix	; F60317  push XIX
	ld	xix, 6332672	; F60318  ld XIX,0x0060a100
	nop	; F6031D  nop
	calr	TrackMerge_AdvanceReadCursor	; F6031E  calr 0xf604b7
	pop	xix	; F60321  pop XIX
	popw	bc	; F60322  pop BC
	push	xix	; F60323  push XIX
	ld	xix, 6332672	; F60324  ld XIX,0x0060a100
	ld	a, (xix+iy)	; F60329  ld A,(XIX+IY)
	ld	(3359:16), a	; F6032E  ld (0x0d1f),A
	pop	xix	; F60332  pop XIX
	ld	(3328:16), iy	; F60333  ld (0x0d00),IY
TrackMerge_FetchSource2Event_Return:
	ret	; F60337  ret

; --------------------------------------------------------------------------
; TrackMerge_FetchSource1Event
; Called from: in-module: 0xF601F9 0xF602CD 0xF60452
; Touches: (0x0C8B) (0x0CFA) (0x0D1E)  |  0x60A000
; Calls:   TrackMerge_AdvanceReadCursor
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF60338 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_FetchSource1Event: Reads source 1's next item from its staging buffer 0x60A000 at (0x0CFA): C = status; a
;   0x81 beat mark or 0x82 end sets (0x0C8B) bit 0 and stays put, otherwise the cursor steps past the status and
;   (0x0D1E) := the event's timing byte. Primed by TrackMerge_Execute; TrackMerge_Execute's loop merges by comparing
;   (0x0D1E) with (0x0D1F). Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
TrackMerge_FetchSource1Event:
	and	(0x0c8b:16), 0xfe	; F60338  and (0x0c8b),0xfe
	ld	iy, (3322:16)	; F6033D  ld IY,(0x0cfa)
	push	xix	; F60341  push XIX
	ld	xix, 6332416	; F60342  ld XIX,0x0060a000
	ld	c, (xix+iy)	; F60347  ld C,(XIX+IY)
	pop	xix	; F6034C  pop XIX
	cp	c, 130	; F6034D  cp C,0x82
	jr	z, TrackMerge_FetchSource1Event_Skip	; F60350  jr Z,0xf60357
	cp	c, 129	; F60352  cp C,0x81
	jr	nz, TrackMerge_FetchSource1Event_Skip2	; F60355  jr NZ,0xf6035e
TrackMerge_FetchSource1Event_Skip:
	or	(0x0c8b:16), 0x01	; F60357  or (0x0c8b),0x01
	jr	TrackMerge_FetchSource1Event_Return	; F6035C  jr T,0xf6037f
TrackMerge_FetchSource1Event_Skip2:
	pushw	bc	; F6035E  push BC
	push	xix	; F6035F  push XIX
	ld	xix, 6332416	; F60360  ld XIX,0x0060a000
	nop	; F60365  nop
	calr	TrackMerge_AdvanceReadCursor	; F60366  calr 0xf604b7
	pop	xix	; F60369  pop XIX
	popw	bc	; F6036A  pop BC
	push	xix	; F6036B  push XIX
	ld	xix, 6332416	; F6036C  ld XIX,0x0060a000
	ld	a, (xix+iy)	; F60371  ld A,(XIX+IY)
	ld	(3358:16), a	; F60376  ld (0x0d1e),A
	pop	xix	; F6037A  pop XIX
	ld	(3322:16), iy	; F6037B  ld (0x0cfa),IY
TrackMerge_FetchSource1Event_Return:
	ret	; F6037F  ret

; --------------------------------------------------------------------------
; TrackMerge_CopySource2Event
; Called from: in-module: 0xF60252 0xF60272
; Touches: (0x0C8B) (0x0D00) (0x0D1F) (0x126E)  |  0x60A100
; Calls:   TrackMerge_AdvanceWriteCursor TrackMerge_AdvanceReadCursor TrackMerge_FetchSource2Event
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF60380 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_CopySource2Event: Copies source 2's current item into the merged stream at the write cursor IX: the
;   status B, then (for an event) its timing (0x0D1F), then its data bytes up to the next status byte, advancing both
;   cursors; then TrackMerge_FetchSource2Event. TrackMerge_Execute runs it when source 2's event is earlier ((0x0D1E)
;   > (0x0D1F)). Twin of TrackMerge_CopySource1Event. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_t.json)
TrackMerge_CopySource2Event:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F60380  ld XHL,(0x126e)
	ld	(xhl+ix), b	; F60384  ld (XHL+IX),B
	bit	1, (0x0c8b:16)	; F60389  bit 1,(0x0c8b)
	jr	nz, TrackMerge_CopySource2Event_Join	; F6038D  jr NZ,0xf603a0
	call	TrackMerge_AdvanceWriteCursor	; F6038F  call 0xf60457
	ld	a, (3359:16)	; F60393  ld A,(0x0d1f)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F60397  ld XHL,(0x126e)
	ld	(xhl+ix), a	; F6039B  ld (XHL+IX),A
TrackMerge_CopySource2Event_Join:
	push	xix	; F603A0  push XIX
	ld	xix, 6332672	; F603A1  ld XIX,0x0060a100
	nop	; F603A6  nop
	ld	iy, (3328:16)	; F603A7  ld IY,(0x0d00)
	calr	TrackMerge_AdvanceReadCursor	; F603AB  calr 0xf604b7
	ld	(3328:16), iy	; F603AE  ld (0x0d00),IY
	pop	xix	; F603B2  pop XIX
	call	TrackMerge_AdvanceWriteCursor	; F603B3  call 0xf60457
	ld	xhl, (BStore_CursorBlockAddr:16)	; F603B7  ld XHL,(0x126e)
	push	xix	; F603BB  push XIX
	ld	xix, 6332672	; F603BC  ld XIX,0x0060a100
	bit	7, (xix+iy)	; F603C1  bit 7,(XIX+IY)
	pop	xix	; F603C6  pop XIX
	jr	nz, TrackMerge_CopySource2Event_Skip	; F603C7  jr NZ,0xf603e0
	push	xix	; F603C9  push XIX
	ld	xix, 6332672	; F603CA  ld XIX,0x0060a100
	ld	a, (xix+iy)	; F603CF  ld A,(XIX+IY)
	pop	xix	; F603D4  pop XIX
	ld	xhl, (BStore_CursorBlockAddr:16)	; F603D5  ld XHL,(0x126e)
	ld	(xhl+ix), a	; F603D9  ld (XHL+IX),A
	jr	TrackMerge_CopySource2Event_Join	; F603DE  jr T,0xf603a0
TrackMerge_CopySource2Event_Skip:
	ld	(3328:16), iy	; F603E0  ld (0x0d00),IY
	call	TrackMerge_FetchSource2Event	; F603E4  call 0xf602f0
	ret	; F603E8  ret

; --------------------------------------------------------------------------
; TrackMerge_CopySource1Event
; Called from: in-module: 0xF60258 0xF60267
; Touches: (0x0C8B) (0x0CFA) (0x0D1E) (0x126E)  |  0x60A000
; Calls:   TrackMerge_AdvanceWriteCursor TrackMerge_AdvanceReadCursor TrackMerge_FetchSource1Event
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF603E9 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_CopySource1Event: Copies source 1's current item into the merged stream at the write cursor IX: the
;   status C, then (for an event) its timing (0x0D1E), then its data bytes up to the next status byte, advancing both
;   cursors; then TrackMerge_FetchSource1Event. TrackMerge_Execute runs it when source 1's event is not later than
;   source 2's. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
TrackMerge_CopySource1Event:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F603E9  ld XHL,(0x126e)
	ld	(xhl+ix), c	; F603ED  ld (XHL+IX),C
	bit	0, (0x0c8b:16)	; F603F2  bit 0,(0x0c8b)
	jr	nz, TrackMerge_CopySource1Event_Join	; F603F6  jr NZ,0xf6040d
	call	TrackMerge_AdvanceWriteCursor	; F603F8  call 0xf60457
	ld	xhl, (BStore_CursorBlockAddr:16)	; F603FC  ld XHL,(0x126e)
	ld	a, (3358:16)	; F60400  ld A,(0x0d1e)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F60404  ld XHL,(0x126e)
	ld	(xhl+ix), a	; F60408  ld (XHL+IX),A
TrackMerge_CopySource1Event_Join:
	push	xix	; F6040D  push XIX
	ld	xix, 6332416	; F6040E  ld XIX,0x0060a000
	nop	; F60413  nop
	ld	iy, (3322:16)	; F60414  ld IY,(0x0cfa)
	call	TrackMerge_AdvanceReadCursor	; F60418  call 0xf604b7
	ld	(3322:16), iy	; F6041C  ld (0x0cfa),IY
	pop	xix	; F60420  pop XIX
	call	TrackMerge_AdvanceWriteCursor	; F60421  call 0xf60457
	ld	xhl, (BStore_CursorBlockAddr:16)	; F60425  ld XHL,(0x126e)
	push	xix	; F60429  push XIX
	ld	xix, 6332416	; F6042A  ld XIX,0x0060a000
	bit	7, (xix+iy)	; F6042F  bit 7,(XIX+IY)
	pop	xix	; F60434  pop XIX
	jr	nz, TrackMerge_CopySource1Event_Skip	; F60435  jr NZ,0xf6044e
	push	xix	; F60437  push XIX
	ld	xix, 6332416	; F60438  ld XIX,0x0060a000
	ld	a, (xix+iy)	; F6043D  ld A,(XIX+IY)
	pop	xix	; F60442  pop XIX
	ld	xhl, (BStore_CursorBlockAddr:16)	; F60443  ld XHL,(0x126e)
	ld	(xhl+ix), a	; F60447  ld (XHL+IX),A
	jr	TrackMerge_CopySource1Event_Join	; F6044C  jr T,0xf6040d
TrackMerge_CopySource1Event_Skip:
	ld	(3322:16), iy	; F6044E  ld (0x0cfa),IY
	call	TrackMerge_FetchSource1Event	; F60452  call 0xf60338
	ret	; F60456  ret

; --------------------------------------------------------------------------
; TrackMerge_AdvanceWriteCursor
; Called from: in-module: 0xF602B3 0xF6038F 0xF603B3 0xF603F8 0xF60421
; Touches: (0x0CA4) (0x0D04) (0x0D4A) (0x126E)
; Calls:   T_BStore_AllocBlock_Veneer T_BStore_SeekBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF60457 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_AdvanceWriteCursor: Steps the TRACK MERGE write cursor IX one byte; past offset 0xFF it allocates a block
;   (T_BStore_AllocBlock_Veneer; above BStore_BlockLimit -> error 5), links it after the current write block (+3) with
;   +1 = (0x0D04), +3 = 0xFFFF, makes it (0x0D04) and IX = 5. The merged chain grows as TrackMerge_CopySource1Event /
;   CopySource2Event / EmitCommonMark write. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_w.json)
TrackMerge_AdvanceWriteCursor:
	and	ix, 255	; F60457  and IX,0x00ff
	inc	1, ix	; F6045B  inc 1,IX
	cp	ix, 255	; F6045D  cp IX,0x00ff
	jr	ugt, TrackMerge_AdvanceWriteCursor_Skip	; F60461  jr UGT,0xf60465
	jr	TrackMerge_AdvanceWriteCursor_Return	; F60463  jr T,0xf604b6
TrackMerge_AdvanceWriteCursor_Skip:
	push	xiz	; F60465  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F60466  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F6046A  ld XDE3,XIZ
	pop	xiz	; F6046D  pop XIZ
	push_lerp	0x38	; F6046E  push XDE3
	push	xiy	; F60471  push XIY
	pushw	bc	; F60472  push BC
	call	T_BStore_AllocBlock_Veneer	; F60473  call 0xf42884
	popw	bc	; F60477  pop BC
	pop	xiy	; F60478  pop XIY
	pop_lerp	0x38	; F60479  pop XDE3
	push	xiz	; F6047C  push XIZ
	ldto_lerp	xiz, 0x38	; F6047D  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F60480  ld (0x126e),XIZ
	pop	xiz	; F60484  pop XIZ
	cp	ix, (BStore_BlockLimit:16)	; F60485  cp IX,(0x0ca4)
	jr	ule, TrackMerge_AdvanceWriteCursor_Skip2	; F60489  jr ULE,0xf60492
	ld	(BStore_ErrorCode:16), 5	; F6048B  ld (0x0d4a),0x05
	jr	TrackMerge_AdvanceWriteCursor_Return	; F60490  jr T,0xf604b6
TrackMerge_AdvanceWriteCursor_Skip2:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F60492  ld XHL,(0x126e)
	ld	(xhl+3), ix	; F60496  ld (XHL+0x03),IX
	ld	hl, ix	; F60499  ld HL,IX
	call	T_BStore_SeekBlock	; F6049B  call 0xf427bc
	ld	wa, (3332:16)	; F6049F  ld WA,(0x0d04)
	ld	xhl, (BStore_CursorBlockAddr:16)	; F604A3  ld XHL,(0x126e)
	ld	(xhl+1), wa	; F604A7  ld (XHL+0x01),WA
	ldw	(xhl+3), 0xffff	; F604AA  ld (XHL+0x03),0xffff
	ld	(3332:16), ix	; F604AF  ld (0x0d04),IX
	ldw	ix, 5	; F604B3  ld IX,0x0005
TrackMerge_AdvanceWriteCursor_Return:
	ret	; F604B6  ret

; --------------------------------------------------------------------------
; TrackMerge_AdvanceReadCursor
; Called from: in-module: 0xF602C6 0xF602DF 0xF6031E 0xF60366 0xF603AB
;              0xF60418
; Touches: (0x0CA4) (0x0D4A) (0x126E) (0x345C)
; Calls:   T_BStore_SeekBlock TrackMerge_LoadAndFreeBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF604B7 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_AdvanceReadCursor: Steps a TRACK MERGE source read cursor IY one byte in its staging buffer XIX (0x60A000
;   / 0x60A100); past offset 0xFF it follows the staged block's +3 next link (0xFFFF -> error 2, above
;   BStore_BlockLimit -> 10, block not in use -> 11) and reloads the buffer with TrackMerge_LoadAndFreeBlock (IY = 5).
;   (0x126E) is preserved. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
TrackMerge_AdvanceReadCursor:
	push	xiz	; F604B7  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F604B8  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F604BC  ld XDE3,XIZ
	pop	xiz	; F604BF  pop XIZ
	push_lerp	0x38	; F604C0  push XDE3
	inc	1, iy	; F604C3  inc 1,IY
	cp	iy, 255	; F604C5  cp IY,0x00ff
	jr	ugt, TrackMerge_AdvanceReadCursor_Skip	; F604C9  jr UGT,0xf604cd
	jr	sub_F604B7_Entry	; F604CB  jr T,0xf60507
TrackMerge_AdvanceReadCursor_Skip:
	ld	wa, (xix+3)	; F604CD  ld WA,(XIX+0x03)
	cp	wa, 65535	; F604D0  cp WA,0xffff
	jr	nz, TrackMerge_AdvanceReadCursor_Skip2	; F604D4  jr NZ,0xf604dd
	ld	(BStore_ErrorCode:16), 2	; F604D6  ld (0x0d4a),0x02
	jr	sub_F604B7_Entry	; F604DB  jr T,0xf60507
TrackMerge_AdvanceReadCursor_Skip2:
	cp	wa, (BStore_BlockLimit:16)	; F604DD  cp WA,(0x0ca4)
	jr	ule, TrackMerge_AdvanceReadCursor_Skip3	; F604E1  jr ULE,0xf604ea
	ld	(BStore_ErrorCode:16), 10	; F604E3  ld (0x0d4a),0x0a
	jr	sub_F604B7_Entry	; F604E8  jr T,0xf60507
TrackMerge_AdvanceReadCursor_Skip3:
	ld	(BStore_CursorBlock:16), wa	; F604EA  ld (0x345c),WA
	ld	hl, wa	; F604EE  ld HL,WA
	call	T_BStore_SeekBlock	; F604F0  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F604F4  ld XHL,(0x126e)
	bit	7, (xhl)	; F604F8  bit 7,(XHL)
	jr	nz, TrackMerge_AdvanceReadCursor_Skip4	; F604FA  jr NZ,0xf60503
	ld	(BStore_ErrorCode:16), 11	; F604FC  ld (0x0d4a),0x0b
	jr	sub_F604B7_Entry	; F60501  jr T,0xf60507
TrackMerge_AdvanceReadCursor_Skip4:
	call	TrackMerge_LoadAndFreeBlock	; F60503  call 0xf60514
sub_F604B7_Entry:
	pop_lerp	0x38	; F60507  pop XDE3
	push	xiz	; F6050A  push XIZ
	ldto_lerp	xiz, 0x38	; F6050B  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F6050E  ld (0x126e),XIZ
	pop	xiz	; F60512  pop XIZ
	ret	; F60513  ret

; --------------------------------------------------------------------------
; TrackMerge_LoadAndFreeBlock
; Called from: in-module: 0xF60175 0xF6019A 0xF60503
; Touches: (0x126E) (0x345C)
; Calls:   T_BStore_FreeChain_Veneer
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF60514 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_LoadAndFreeBlock: Copies the 256-byte block at the cursor (0x126E) into the TRACK MERGE staging buffer
;   XIX (0x60A000 for source 1, 0x60A100 for source 2; ldir), returns that block to the free list (T_BStore_FreeChain_Veneer ->
;   BStore_FreeChain with IY = (0x345C) block, WA = 1), restores (0x126E) and sets IY = 5. So the merge frees each
;   source block as it consumes it while it allocates the merged chain. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_t.json)
TrackMerge_LoadAndFreeBlock:
	pushw	bc	; F60514  push BC
	push	xhl	; F60515  push XHL
	push	xiz	; F60516  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F60517  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F6051B  ld XDE3,XIZ
	pop	xiz	; F6051E  pop XIZ
	push_lerp	0x38	; F6051F  push XDE3
	ld	xiy, (BStore_CursorBlockAddr:16)	; F60522  ld XIY,(0x126e)
	ldw	bc, 256	; F60526  ld BC,0x0100
	ldir85	; F60529  ldir
	ld	iy, (BStore_CursorBlock:16)	; F6052B  ld IY,(0x345c)
	ldw	wa, 1	; F6052F  ld WA,0x0001
	call	T_BStore_FreeChain_Veneer	; F60532  call 0xf42888
	pop_lerp	0x38	; F60536  pop XDE3
	push	xiz	; F60539  push XIZ
	ldto_lerp	xiz, 0x38	; F6053A  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F6053D  ld (0x126e),XIZ
	pop	xiz	; F60541  pop XIZ
	pop	xhl	; F60542  pop XHL
	popw	bc	; F60543  pop BC
	ldw	iy, 5	; F60544  ld IY,0x0005
	ret	; F60547  ret

; --------------------------------------------------------------------------
; TrackMerge_DetachSourceTrack
; Called from: in-module: 0xF6015D 0xF60182
; Touches:   |  0x003460 0x003482 0x60347E 0x6034A0 0x603500
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF60548 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; TrackMerge_DetachSourceTrack: For track HL (1-based): clears its directory entry's in-use bit, sets its head to
;   0xFFFF and resets its saved cursors (0x3460/0x60347E[n-1] := 0xFFFF, 0x3482/0x6034A0[n-1] := 5) without freeing
;   its blocks. TrackMerge_Execute runs it on both sources after noting their head blocks, before
;   TrackMerge_LoadAndFreeBlock consumes the chains block by block. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_t.json)
TrackMerge_DetachSourceTrack:
	dec	1, hl	; F60548  dec 1,HL
	ld	iy, hl	; F6054A  ld IY,HL
	muls	iy, 3	; F6054C  muls IY,0x0003
	push	xix	; F60550  push XIX
	ld	xix, 6305024	; F60551  ld XIX,0x00603500
	and	(xix+iy), 0x7f	; F60556  and (XIX+IY),0x7f
	inc	1, iy	; F6055C  inc 1,IY
	ldw	(xix+iy), 0xffff	; F6055E  ld (XIX+IY),0xffff
	ld	xix, 13442	; F60565  ld XIX,0x00003482
	ld	(xix+hl), 0x05	; F6056A  ld (XIX+HL),0x05
	ld	xix, 6304928	; F60570  ld XIX,0x006034a0
	ld	(xix+hl), 0x05	; F60575  ld (XIX+HL),0x05
	sla	hl, 1	; F6057B  sla 0x01,HL
	ld	xix, 13408	; F6057E  ld XIX,0x00003460
	ldw	(xix+hl), 0xffff	; F60583  ld (XIX+HL),0xffff
	ld	xix, 6304894	; F6058A  ld XIX,0x0060347e
	ldw	(xix+hl), 0xffff	; F6058F  ld (XIX+HL),0xffff
	pop	xix	; F60596  pop XIX
	ret	; F60597  ret

; --------------------------------------------------------------------------
; Vel0cityChange_Execute
; Called from: T_Vel0cityChange_Execute (x1)
; Touches: (0x0C70) (0x0C73) (0x0C77) (0x0C7A) (0x0C7B) (0x0C8A) (0x0C8E)
;          (0x0CA2) (0x0CA3) (0x0D18) +1 more  |  0x603422
; Calls:   T_BStore_LoadGeometry Vel0cityChange_ApplyToTrack
; Evidence: thunk slot T_Vel0cityChange_Execute holds `jp 0x00F60598`, and 0xF60598 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_Execute: The VEL0CITY CHANGE job (Vel0cityChange_LcdKeyRow2, through T_Vel0cityChange_Execute): track (0x0C70)
;   1..(0x0CA2) or 0x7F = all, measures (0x0C73)/(0x0C77) 1..999, mode (0x0C7A) 0 = add the signed value (0x0C7B) (not
;   0x80), 1 = set it (0..127), else error 3; per track Vel0cityChange_ApplyToTrack rewrites the velocity byte (+3) of each 0x9n event,
;   clamped 0..127. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
Vel0cityChange_Execute:		; <- T_Vel0cityChange_Execute
	call	T_BStore_LoadGeometry	; F60598  call 0xf427c4
	ld	a, (3184:16)	; F6059C  ld A,(0x0c70)
	cp	a, 1:i3	; F605A0  cp A,1
	jr	c, Vel0cityChange_Execute_Skip3	; F605A2  jr C,0xf605ed
	cp	a, 127	; F605A4  cp A,0x7f
	jr	z, Vel0cityChange_Execute_Skip	; F605A7  jr Z,0xf605af
	cp	a, (0x0ca2:16)	; F605A9  cp A,(0x0ca2)
	jr	ugt, Vel0cityChange_Execute_Skip3	; F605AD  jr UGT,0xf605ed
Vel0cityChange_Execute_Skip:
	ld	wa, (3187:16)	; F605AF  ld WA,(0x0c73)
	cp	wa, 1:i3	; F605B3  cp WA,1
	jr	c, Vel0cityChange_Execute_Skip3	; F605B5  jr C,0xf605ed
	cp	wa, 999	; F605B7  cp WA,0x03e7
	jr	ugt, Vel0cityChange_Execute_Skip3	; F605BB  jr UGT,0xf605ed
	ld	wa, (3191:16)	; F605BD  ld WA,(0x0c77)
	cp	wa, 1:i3	; F605C1  cp WA,1
	jr	c, Vel0cityChange_Execute_Skip3	; F605C3  jr C,0xf605ed
	cp	wa, 999	; F605C5  cp WA,0x03e7
	jr	ugt, Vel0cityChange_Execute_Skip3	; F605C9  jr UGT,0xf605ed
	ld	a, (3194:16)	; F605CB  ld A,(0x0c7a)
	cp	a, 0:i3	; F605CF  cp A,0
	jr	nz, Vel0cityChange_Execute_Skip2	; F605D1  jr NZ,0xf605de
	ld	a, (3195:16)	; F605D3  ld A,(0x0c7b)
	cp	a, 128	; F605D7  cp A,0x80
	jr	z, Vel0cityChange_Execute_Skip3	; F605DA  jr Z,0xf605ed
	jr	Vel0cityChange_Execute_Join	; F605DC  jr T,0xf605f5
Vel0cityChange_Execute_Skip2:
	cp	a, 1:i3	; F605DE  cp A,1
	jr	nz, Vel0cityChange_Execute_Skip3	; F605E0  jr NZ,0xf605ed
	ld	a, (3195:16)	; F605E2  ld A,(0x0c7b)
	bit	7, a	; F605E6  bit 0x07,A
	jr	nz, Vel0cityChange_Execute_Skip3	; F605E9  jr NZ,0xf605ed
	jr	Vel0cityChange_Execute_Join	; F605EB  jr T,0xf605f5
Vel0cityChange_Execute_Skip3:
	ld	(BStore_ErrorCode:16), 3	; F605ED  ld (0x0d4a),0x03
	jrl	Vel0cityChange_ApplyToTrack_Join7	; F605F2  jrl T,0xf60791
Vel0cityChange_Execute_Join:
	ld	(BStore_ErrorCode:16), 0	; F605F5  ld (0x0d4a),0x00
	and	(0x0c8a:16), 0xbf	; F605FA  and (0x0c8a),0xbf
	cp	(0x0c70:16), 0x7f	; F605FF  cp (0x0c70),0x7f
	jr	nz, Vel0cityChange_Execute_Skip4	; F60604  jr NZ,0xf60608
	jr	Vel0cityChange_Execute_Join2	; F60606  jr T,0xf60637
Vel0cityChange_Execute_Skip4:
	xor	hl, hl	; F60608  xor HL,HL
	ld	l, (3184:16)	; F6060A  ld L,(0x0c70)
	dec	1, l	; F6060E  dec 1,L
	push	xix	; F60610  push XIX
	ld	xix, BStore_TrackToPart	; F60611  ld XIX,0x00603422
	ld	a, (xix+hl)	; F60616  ld A,(XIX+HL)
	pop	xix	; F6061B  pop XIX
	cp	a, 32	; F6061C  cp A,0x20
	jr	z, Vel0cityChange_Execute_Skip5	; F6061F  jr Z,0xf6062f
	ld	a, (3184:16)	; F60621  ld A,(0x0c70)
	ld	(3214:16), a	; F60625  ld (0x0c8e),A
	calr	Vel0cityChange_ApplyToTrack	; F60629  calr 0xf6068d
	jrl	Vel0cityChange_ApplyToTrack_Join7	; F6062C  jrl T,0xf60791
Vel0cityChange_Execute_Skip5:
	ld	(BStore_ErrorCode:16), 9	; F6062F  ld (0x0d4a),0x09
	jrl	Vel0cityChange_ApplyToTrack_Join7	; F60634  jrl T,0xf60791
Vel0cityChange_Execute_Join2:
	xor	hl, hl	; F60637  xor HL,HL
Vel0cityChange_Execute_Join3:
	cp	l, (0x0ca3:16)	; F60639  cp L,(0x0ca3)
	jr	ugt, Vel0cityChange_Execute_Skip8	; F6063D  jr UGT,0xf60682
	ld	h, l	; F6063F  ld H,L
	inc	1, h	; F60641  inc 1,H
	ld	(3214:16), h	; F60643  ld (0x0c8e),H
	pushw	hl	; F60647  push HL
	push	xix	; F60648  push XIX
	xor	h, h	; F60649  xor H,H
	ld	xix, BStore_TrackToPart	; F6064B  ld XIX,0x00603422
	ld	a, (xix+hl)	; F60650  ld A,(XIX+HL)
	pop	xix	; F60655  pop XIX
	popw	hl	; F60656  pop HL
	cp	a, 32	; F60657  cp A,0x20
	jr	z, Vel0cityChange_Execute_Skip6	; F6065A  jr Z,0xf60661
	pushw	hl	; F6065C  push HL
	calr	Vel0cityChange_ApplyToTrack	; F6065D  calr 0xf6068d
	popw	hl	; F60660  pop HL
Vel0cityChange_Execute_Skip6:
	cp	(BStore_ErrorCode:16), 0x00	; F60661  cp (0x0d4a),0x00
	jr	z, Vel0cityChange_Execute_Skip7	; F60666  jr Z,0xf6067e
	cp	(BStore_ErrorCode:16), 0x01	; F60668  cp (0x0d4a),0x01
	jr	z, Vel0cityChange_Execute_Skip7	; F6066D  jr Z,0xf6067e
	cp	(0x0d18:16), 0x00	; F6066F  cp (0x0d18),0x00
	jr	nz, Vel0cityChange_Execute_Skip7	; F60674  jr NZ,0xf6067e
	ld	a, (BStore_ErrorCode:16)	; F60676  ld A,(0x0d4a)
	ld	(3352:16), a	; F6067A  ld (0x0d18),A
Vel0cityChange_Execute_Skip7:
	inc	1, hl	; F6067E  inc 1,HL
	jr	Vel0cityChange_Execute_Join3	; F60680  jr T,0xf60639
Vel0cityChange_Execute_Skip8:
	ld	a, (3352:16)	; F60682  ld A,(0x0d18)
	ld	(BStore_ErrorCode:16), a	; F60686  ld (0x0d4a),A
	jrl	Vel0cityChange_ApplyToTrack_Join7	; F6068A  jrl T,0xf60791

; --------------------------------------------------------------------------
; Vel0cityChange_ApplyToTrack
; Called from: in-module: 0xF60629 0xF6065D
; Touches: (0x0C73) (0x0C77) (0x0C7A) (0x0C7B) (0x0C8E) (0x0C90) (0x0D1C)
;          (0x0D4A) (0x126E)
; Calls:   T_Seq_FindMasterTrack T_BStore_SeekMeasure T_BStore_CursorAdvance T_F427A8 T_BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_60 T_F40A1C
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF6068D is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Vel0cityChange_ApplyToTrack: VEL0CITY CHANGE on track (0x0C8E): seeks measure (0x0C73) and, for (0x0C77) measures,
;   sets the velocity byte (+3) of each 0x9n event to (0x0C7B) (mode (0x0C7A) = 1) or adds the signed (0x0C7B) clamped
;   to 0..127. Vel0cityChange_Execute calls it for one track or for each track of ALL. Basis: caller + caller header +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
Vel0cityChange_ApplyToTrack:
	call	T_Seq_FindMasterTrack	; F6068D  call 0xf427a0
	ld	a, (3214:16)	; F60691  ld A,(0x0c8e)
	ld	de, (3187:16)	; F60695  ld DE,(0x0c73)
	ld	(3216:16), de	; F60699  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F6069D  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F606A1  cp (0x0d4a),0x00
	jrl	nz, Vel0cityChange_ApplyToTrack_Return	; F606A6  jrl NZ,0xf60790
	xor	de, de	; F606A9  xor DE,DE
Vel0cityChange_ApplyToTrack_Join:
	cp	de, (0x0c77:16)	; F606AB  cp DE,(0x0c77)
	jr	nz, Vel0cityChange_ApplyToTrack_Skip	; F606AF  jr NZ,0xf606b4
	jrl	Vel0cityChange_ApplyToTrack_Return	; F606B1  jrl T,0xf60790
Vel0cityChange_ApplyToTrack_Skip:
	xor	bc, bc	; F606B4  xor BC,BC
Vel0cityChange_ApplyToTrack_Join2:
	cp	c, (0x0d1c:16)	; F606B6  cp C,(0x0d1c)
	jr	nz, Vel0cityChange_ApplyToTrack_Join3	; F606BA  jr NZ,0xf606bf
	jrl	Vel0cityChange_ApplyToTrack_Join6	; F606BC  jrl T,0xf60760
Vel0cityChange_ApplyToTrack_Join3:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F606BF  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F606C3  ld A,(XHL+IY)
	cp	a, 130	; F606C8  cp A,0x82
	jr	nz, Vel0cityChange_ApplyToTrack_Skip2	; F606CB  jr NZ,0xf606d0
	jrl	Vel0cityChange_ApplyToTrack_Return	; F606CD  jrl T,0xf60790
Vel0cityChange_ApplyToTrack_Skip2:
	cp	a, 129	; F606D0  cp A,0x81
	jrl	z, Vel0cityChange_ApplyToTrack_Skip9	; F606D3  jrl Z,0xf60757
	and	a, 240	; F606D6  and A,0xf0
	cp	a, 144	; F606D9  cp A,0x90
	jr	nz, Vel0cityChange_ApplyToTrack_Join5	; F606DC  jr NZ,0xf60747
	call	T_BStore_CursorAdvance	; F606DE  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F606E2  cp (0x0d4a),0x00
	jr	z, Vel0cityChange_ApplyToTrack_Skip3	; F606E7  jr Z,0xf606ec
	jrl	Vel0cityChange_ApplyToTrack_Return	; F606E9  jrl T,0xf60790
Vel0cityChange_ApplyToTrack_Skip3:
	call	T_BStore_CursorAdvance	; F606EC  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F606F0  cp (0x0d4a),0x00
	jr	z, Vel0cityChange_ApplyToTrack_Skip4	; F606F5  jr Z,0xf606fa
	jrl	Vel0cityChange_ApplyToTrack_Return	; F606F7  jrl T,0xf60790
Vel0cityChange_ApplyToTrack_Skip4:
	call	T_BStore_CursorAdvance	; F606FA  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F606FE  cp (0x0d4a),0x00
	jr	z, Vel0cityChange_ApplyToTrack_Skip5	; F60703  jr Z,0xf60708
	jrl	Vel0cityChange_ApplyToTrack_Return	; F60705  jrl T,0xf60790
Vel0cityChange_ApplyToTrack_Skip5:
	xor	wa, wa	; F60708  xor WA,WA
	ld	a, (3195:16)	; F6070A  ld A,(0x0c7b)
	cp	(0x0c7a:16), 0x01	; F6070E  cp (0x0c7a),0x01
	jr	nz, Vel0cityChange_ApplyToTrack_Skip6	; F60713  jr NZ,0xf60720
	ld	xhl, (BStore_CursorBlockAddr:16)	; F60715  ld XHL,(0x126e)
	ld	(xhl+iy), a	; F60719  ld (XHL+IY),A
	jr	Vel0cityChange_ApplyToTrack_Join5	; F6071E  jr T,0xf60747
Vel0cityChange_ApplyToTrack_Skip6:
	exts	wa	; F60720  exts WA
	ld	ix, wa	; F60722  ld IX,WA
	xor	w, w	; F60724  xor W,W
	ld	xhl, (BStore_CursorBlockAddr:16)	; F60726  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F6072A  ld A,(XHL+IY)
	add	wa, ix	; F6072F  add WA,IX
	jr	pl, Vel0cityChange_ApplyToTrack_Skip7	; F60731  jr P/PL,0xf60737
	xor	a, a	; F60733  xor A,A
	jr	Vel0cityChange_ApplyToTrack_Join4	; F60735  jr T,0xf6073e
Vel0cityChange_ApplyToTrack_Skip7:
	cp	a, 127	; F60737  cp A,0x7f
	jr	ule, Vel0cityChange_ApplyToTrack_Join4	; F6073A  jr ULE,0xf6073e
	ld	a, 127:opc	; F6073C  ld A,0x7f
Vel0cityChange_ApplyToTrack_Join4:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F6073E  ld XHL,(0x126e)
	ld	(xhl+iy), a	; F60742  ld (XHL+IY),A
Vel0cityChange_ApplyToTrack_Join5:
	call	T_BStore_CursorAdvance	; F60747  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F6074B  cp (0x0d4a),0x00
	jr	z, Vel0cityChange_ApplyToTrack_Skip8	; F60750  jr Z,0xf60754
	jr	Vel0cityChange_ApplyToTrack_Return	; F60752  jr T,0xf60790
Vel0cityChange_ApplyToTrack_Skip8:
	jrl	Vel0cityChange_ApplyToTrack_Join3	; F60754  jrl T,0xf606bf
Vel0cityChange_ApplyToTrack_Skip9:
	inc	1, c	; F60757  inc 1,C
	call	T_BStore_CursorAdvance	; F60759  call 0xf4279c
	jrl	Vel0cityChange_ApplyToTrack_Join2	; F6075D  jrl T,0xf606b6
Vel0cityChange_ApplyToTrack_Join6:
	inc	1, de	; F60760  inc 1,DE
	push	xiz	; F60762  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F60763  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x38	; F60767  ld XDE3,XIZ
	pop	xiz	; F6076A  pop XIZ
	push_lerp	0x38	; F6076B  push XDE3
	push	xhl	; F6076E  push XHL
	pushw	de	; F6076F  push DE
	push	xiy	; F60770  push XIY
	push	xix	; F60771  push XIX
	call	T_F427A8	; F60772  call 0xf427a8
	pop	xix	; F60776  pop XIX
	pop	xiy	; F60777  pop XIY
	popw	de	; F60778  pop DE
	pop	xhl	; F60779  pop XHL
	pop_lerp	0x38	; F6077A  pop XDE3
	push	xiz	; F6077D  push XIZ
	ldto_lerp	xiz, 0x38	; F6077E  ld XIZ,XDE3
	ld	(BStore_CursorBlockAddr:16), xiz	; F60781  ld (0x126e),XIZ
	pop	xiz	; F60785  pop XIZ
	cp	(BStore_ErrorCode:16), 0x00	; F60786  cp (0x0d4a),0x00
	jr	nz, Vel0cityChange_ApplyToTrack_Return	; F6078B  jr NZ,0xf60790
	jrl	Vel0cityChange_ApplyToTrack_Join	; F6078D  jrl T,0xf606ab
Vel0cityChange_ApplyToTrack_Return:
	ret	; F60790  ret
Vel0cityChange_ApplyToTrack_Join7:
	call	T_BStore_ErrorToStatusByte_Sub_BStore_ErrorStatusTable_60	; F60791  call 0xf42820
	call	T_F40A1C	; F60795  call 0xf40a1c
	ret	; F60799  ret

; --------------------------------------------------------------------------
; SongEdit_ClearTrack_Call
; Called from: T_SongEdit_ClearTrack_Call (x2)
; Touches: nothing with an absolute address
; Calls:   SongEdit_ClearTrack
; Evidence: thunk slot T_SongEdit_ClearTrack_Call holds `jp 0x00F6079A`, and 0xF6079A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_ClearTrack_Call: `calr SongEdit_ClearTrack / ret` behind T_SongEdit_ClearTrack_Call; TrackClear_LcdKeyRow2 calls it once per
;   track selected in (0x0DBE). Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
SongEdit_ClearTrack_Call:		; <- T_SongEdit_ClearTrack_Call
	calr	SongEdit_ClearTrack	; F6079A  calr 0xf6079e
	ret	; F6079D  ret

; --------------------------------------------------------------------------
; SongEdit_ClearTrack
; Called from: in-module: 0xF5E609 0xF5F9BD 0xF6014F 0xF6079A
; Touches: (0x0C70) (0x0CA2) (0x0CA4) (0x0D4A) (0x360A)  |  0x00007E
;          0x0000A0 0x000100 0x000D50 0x000D70 0x003460 +5 more
; Calls:   T_BStore_LoadGeometry T_BStore_FreeChain_Veneer T_F40A1C
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF6079E is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_ClearTrack: Empties track (0x0C70): frees its chain (BStore_FreeChain via T_BStore_FreeChain_Veneer), marks its directory
;   entry empty and resets its saved cursors in the workspace and in the current bank's copy (0x610000 +
;   BStore_CurrentBank*0xC00). Called by TRACK CLEAR (SongEdit_ClearTrack_Call), SongEdit_DeleteMeasuresFromTrack,
;   SongEdit_CopyMeasuresToTrack and TrackMerge_Execute; twin of the block store's BStore_ClearTrack. Basis: callers +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave5_review.json)
SongEdit_ClearTrack:
	call	T_BStore_LoadGeometry	; F6079E  call 0xf427c4
	ld	a, (3184:16)	; F607A2  ld A,(0x0c70)
	cp	a, 1:i3	; F607A6  cp A,1
	jr	c, SongEdit_ClearTrack_Skip	; F607A8  jr C,0xf607b0
	cp	a, (0x0ca2:16)	; F607AA  cp A,(0x0ca2)
	jr	ule, SongEdit_ClearTrack_Skip2	; F607AE  jr ULE,0xf607b8
SongEdit_ClearTrack_Skip:
	ld	(BStore_ErrorCode:16), 3	; F607B0  ld (0x0d4a),0x03
	jrl	SongEdit_ClearTrack_Join	; F607B5  jrl T,0xf6083b
SongEdit_ClearTrack_Skip2:
	xor	wa, wa	; F607B8  xor WA,WA
	ld	a, (3184:16)	; F607BA  ld A,(0x0c70)
	dec	1, a	; F607BE  dec 1,A
	push	xix	; F607C0  push XIX
	ld	iy, wa	; F607C1  ld IY,WA
	ld	xix, 6304928	; F607C3  ld XIX,0x006034a0
	ld	(xix+iy), 0x05	; F607C8  ld (XIX+IY),0x05
	ld	xix, 13442	; F607CE  ld XIX,0x00003482
	ld	(xix+iy), 0x05	; F607D3  ld (XIX+IY),0x05
	sla	iy, 1	; F607D9  sla 0x01,IY
	ld	xix, 6304894	; F607DC  ld XIX,0x0060347e
	ldw	(xix+iy), 0xffff	; F607E1  ld (XIX+IY),0xffff
	ld	xix, 13408	; F607E8  ld XIX,0x00003460
	ldw	(xix+iy), 0xffff	; F607ED  ld (XIX+IY),0xffff
	pop	xix	; F607F4  pop XIX
	muls	wa, 3	; F607F5  muls WA,0x0003
	ld	iy, wa	; F607F9  ld IY,WA
	push	xde	; F607FB  push XDE
	ld	xde, 6305024	; F607FC  ld XDE,0x00603500
	bit	7, (xde+iy)	; F60801  bit 7,(XDE+IY)
	pop	xde	; F60806  pop XDE
	jr	z, SongEdit_ClearTrack_Join	; F60807  jr Z,0xf6083b
	push	xde	; F60809  push XDE
	ld	xde, 6305024	; F6080A  ld XDE,0x00603500
	and	(xde+iy), 0x7f	; F6080F  and (XDE+IY),0x7f
	inc	1, iy	; F60815  inc 1,IY
	ld	wa, (xde+iy)	; F60817  ld WA,(XDE+IY)
	pop	xde	; F6081C  pop XDE
	cp	wa, 65535	; F6081D  cp WA,0xffff
	jr	z, SongEdit_ClearTrack_Join	; F60821  jr Z,0xf6083b
	push	xde	; F60823  push XDE
	ld	xde, 6305024	; F60824  ld XDE,0x00603500
	ldw	(xde+iy), 0xffff	; F60829  ld (XDE+IY),0xffff
	pop	xde	; F60830  pop XDE
	ld	iy, wa	; F60831  ld IY,WA
	ld	wa, (BStore_BlockLimit:16)	; F60833  ld WA,(0x0ca4)
	call	T_BStore_FreeChain_Veneer	; F60837  call 0xf42888
SongEdit_ClearTrack_Join:
	xor	hl, hl	; F6083B  xor HL,HL
	ld	l, (3184:16)	; F6083D  ld L,(0x0c70)
	dec	1, hl	; F60841  dec 1,HL
	sla	hl, 1	; F60843  sla 0x01,HL
	push	xix	; F60846  push XIX
	ld	xix, 3408	; F60847  ld XIX,0x00000d50
	ldw	(xix+hl), 0x0000	; F6084C  ld (XIX+HL),0x0000
	ld	xix, 3440	; F60853  ld XIX,0x00000d70
	ldw	(xix+hl), 0x0000	; F60858  ld (XIX+HL),0x0000
	pop	xix	; F6085F  pop XIX
	call	T_F40A1C	; F60860  call 0xf40a1c
	push	xix	; F60864  push XIX
	push	xde	; F60865  push XDE
	ld	xix, 6356992	; F60866  ld XIX,0x00610000
	xor	xwa, xwa	; F6086B  xor XWA,XWA
	xor	xde, xde	; F6086D  xor XDE,XDE
	ld	a, (BStore_CurrentBank:16)	; F6086F  ld A,(0x360a)
	ld	e, a	; F60873  ld E,A
	sla	xwa, 11	; F60875  sla 0x0b,XWA
	sla	xde, 10	; F60878  sla 0x0a,XDE
	add	xwa, xde	; F6087B  add XWA,XDE
	add	xix, xwa	; F6087D  add XIX,XWA
	ld	xde, 256	; F6087F  ld XDE,0x00000100
	add	xde, xix	; F60884  add XDE,XIX
	ld	a, (3184:16)	; F60886  ld A,(0x0c70)
	dec	1, a	; F6088A  dec 1,A
	ld	w, a	; F6088C  ld W,A
	sla	a, 1	; F6088E  sla 0x01,A
	add	a, w	; F60891  add A,W
	xor	w, w	; F60893  xor W,W
	and	(xde+wa), 0x7f	; F60895  and (XDE+WA),0x7f
	inc	1, wa	; F6089B  inc 1,WA
	ldw	(xde+wa), 0xffff	; F6089D  ld (XDE+WA),0xffff
	ld	xde, 126	; F608A4  ld XDE,0x0000007e
	add	xde, xix	; F608A9  add XDE,XIX
	xor	wa, wa	; F608AB  xor WA,WA
	ld	a, (3184:16)	; F608AD  ld A,(0x0c70)
	dec	1, a	; F608B1  dec 1,A
	sla	wa, 1	; F608B3  sla 0x01,WA
	ldw	(xde+wa), 0xffff	; F608B6  ld (XDE+WA),0xffff
	sra	wa, 1	; F608BD  sra 0x01,WA
	ld	xde, 160	; F608C0  ld XDE,0x000000a0
	add	xde, xix	; F608C5  add XDE,XIX
	ld	(xde+wa), 0x05	; F608C7  ld (XDE+WA),0x05
	pop	xde	; F608CD  pop XDE
	pop	xix	; F608CE  pop XIX
	ret	; F608CF  ret

; --------------------------------------------------------------------------
; SongClear_ClearBank
; Called from: T_SongClear_ClearBank (x3); in-module: 0xF60B19
; Touches: (0x0CA2) (0x0E02) (0x360A)  |  0x00001C 0x000100 0x000D50
;          0x000D70 0x603500 0x610000
; Calls:   T_BStore_LoadGeometry SongClear_ResetAllBanks BStore_EmptyBank T_BStore_FreeList_Init_Veneer SongEdit_ResetJobFields_Copy T_F40A1C
; Evidence: thunk slot T_SongClear_ClearBank holds `jp 0x00F608D0`, and 0xF608D0 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongClear_ClearBank: the SONG CLEAR job's action (SongClear_LcdKeyRow4, through T_SongClear_ClearBank) on bank (0x0E02), 10 = all of them
;   (SongClear_ResetAllBanks): BStore_EmptyBank, then in the bank copy the password word +0x1C = 0 and every directory entry's bit
;   7 cleared and start block 0xFFFF.
SongClear_ClearBank:		; <- T_SongClear_ClearBank
	call	T_BStore_LoadGeometry	; F608D0  call 0xf427c4
	cp	(0x0e02:16), 0x0a	; F608D4  cp (0x0e02),0x0a
	jr	nz, SongClear_ClearBank_Skip	; F608D9  jr NZ,0xf608e2
	call	SongClear_ResetAllBanks	; F608DB  call 0xf610e3
	jrl	SongClear_ClearBank_Join2	; F608DF  jrl T,0xf609a1
SongClear_ClearBank_Skip:
	call	BStore_EmptyBank	; F608E2  call 0xf60f4f
	xor	xde, xde	; F608E6  xor XDE,XDE
	xor	xwa, xwa	; F608E8  xor XWA,XWA
	ld	a, (3586:16)	; F608EA  ld A,(0x0e02)
	ld	e, a	; F608EE  ld E,A
	sla	xwa, 11	; F608F0  sla 0x0b,XWA
	sla	xde, 10	; F608F3  sla 0x0a,XDE
	add	xwa, xde	; F608F6  add XWA,XDE
	ld	xiy, 6356992	; F608F8  ld XIY,0x00610000
	ld	xde, 28	; F608FD  ld XDE,0x0000001c
	add	xde, xwa	; F60902  add XDE,XWA
	add	xde, xiy	; F60904  add XDE,XIY
	ldw	(xde), 0x0000	; F60906  ld (XDE),0x0000
	xor	hl, hl	; F6090A  xor HL,HL
	xor	ix, ix	; F6090C  xor IX,IX
	ld	xde, 256	; F6090E  ld XDE,0x00000100
SongClear_ClearBank_Loop:
	ld	xiy, 6356992	; F60913  ld XIY,0x00610000
	add	xiy, xwa	; F60918  add XIY,XWA
	add	xiy, xde	; F6091A  add XIY,XDE
	and	(xiy+ix), 0x7f	; F6091C  and (XIY+IX),0x7f
	inc	1, ix	; F60922  inc 1,IX
	ldfr_lerp	xiy, 0x38	; F60924  ld XDE3,XIY
	lda	xiy, (xiy+ix)	; F60927  lda XIY,XIY+IX
	ldw	(xiy), 0xffff	; F6092C  ld (XIY),0xffff
	ldto_lerp	xiy, 0x38	; F60930  ld XIY,XDE3
	add	ix, 2	; F60933  add IX,0x0002
	inc	1, hl	; F60937  inc 1,HL
	cp	hl, 16	; F60939  cp HL,0x0010
	jr	c, SongClear_ClearBank_Loop	; F6093D  jr C,0xf60913
	ld	a, (BStore_CurrentBank:16)	; F6093F  ld A,(0x360a)
	cp	a, (0x0e02:16)	; F60943  cp A,(0x0e02)
	jr	nz, SongClear_ClearBank_Skip2	; F60947  jr NZ,0xf6099b
	ldw	(BStore_Password:24), 0	; F60949  ld (0x60341c),0x0000
	xor	iy, iy	; F60950  xor IY,IY
	xor	wa, wa	; F60952  xor WA,WA
	xor	hl, hl	; F60954  xor HL,HL
SongClear_ClearBank_Join:
	inc	1, a	; F60956  inc 1,A
	cp	a, (0x0ca2:16)	; F60958  cp A,(0x0ca2)
	jrl	ugt, SongClear_ClearBank_Skip2	; F6095C  jrl UGT,0xf6099b
	push	xde	; F6095F  push XDE
	ld	xde, 6305024	; F60960  ld XDE,0x00603500
	and	(xde+iy), 0x7f	; F60965  and (XDE+IY),0x7f
	inc	1, iy	; F6096B  inc 1,IY
	ldw	(xde+iy), 0xffff	; F6096D  ld (XDE+IY),0xffff
	pop	xde	; F60974  pop XDE
	inc	2, iy	; F60975  inc 2,IY
	ld	hl, wa	; F60977  ld HL,WA
	dec	1, hl	; F60979  dec 1,HL
	sla	hl, 1	; F6097B  sla 0x01,HL
	push	xde	; F6097E  push XDE
	ld	xde, 3408	; F6097F  ld XDE,0x00000d50
	ldw	(xde+hl), 0x0000	; F60984  ld (XDE+HL),0x0000
	ld	xde, 3440	; F6098B  ld XDE,0x00000d70
	ldw	(xde+hl), 0x0000	; F60990  ld (XDE+HL),0x0000
	pop	xde	; F60997  pop XDE
	jrl	SongClear_ClearBank_Join	; F60998  jrl T,0xf60956
SongClear_ClearBank_Skip2:
	call	BStore_EmptyBank	; F6099B  call 0xf60f4f
	jr	SongClear_ClearBank_Join3	; F6099F  jr T,0xf609ac
SongClear_ClearBank_Join2:
	ldw	(BStore_Password:24), 0	; F609A1  ld (0x60341c),0x0000
	call	T_BStore_FreeList_Init_Veneer	; F609A8  call 0xf42880
SongClear_ClearBank_Join3:
	call	SongEdit_ResetJobFields_Copy	; F609AC  call 0xf609b6
	call	T_F40A1C	; F609B0  call 0xf40a1c
	ret	; F609B4  ret
	ret	; F609B5  ret

; --------------------------------------------------------------------------
; SongEdit_ResetJobFields_Copy
; Called from: in-module: 0xF609AC
; Touches: (0x0C35) (0x0DBE) (0x0DE6) (0x0DE8) (0x0DEA) (0x0DEC) (0x0DEE)
;          (0x0DF0) (0x0DF2) (0x0DF4) +12 more
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF609B6 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongEdit_ResetJobFields_Copy: an exact copy of SongEdit_ResetJobFields (prom_b 0xF63A59) -- all 68 instructions equal, operands included,
;   but the targets of its jr / jrl / djnz (notes/wsa1_exact_copy_names.py).
SongEdit_ResetJobFields_Copy:
	ld	(6304856:24), 0	; F609B6  ld (0x603458),0x00
	ldw	(3518:16), 0	; F609BC  ld (0x0dbe),0x0000
	ld	(6304857:24), 1	; F609C2  ld (0x603459),0x01
	ld	(6304858:24), 2	; F609C8  ld (0x60345a),0x02
	ld	(6304859:24), 3	; F609CE  ld (0x60345b),0x03
	ld	(6304860:24), 1	; F609D4  ld (0x60345c),0x01
	ldw	(6304861:24), 1	; F609DA  ld (0x60345d),0x0001
	ldw	(6304863:24), 1	; F609E1  ld (0x60345f),0x0001
	ld	(6304865:24), 1	; F609E8  ld (0x603461),0x01
	ldw	(6304866:24), 1	; F609EE  ld (0x603462),0x0001
	ldw	(6304868:24), 1	; F609F5  ld (0x603464),0x0001
	ld	(6304870:24), 0	; F609FC  ld (0x603466),0x00
	ld	(6304871:24), 1	; F60A02  ld (0x603467),0x01
	ldw	(6304872:24), 1	; F60A08  ld (0x603468),0x0001
	ldw	(6304874:24), 1	; F60A0F  ld (0x60346a),0x0001
	ld	(6304876:24), 1	; F60A16  ld (0x60346c),0x01
	ldw	(6304877:24), 1	; F60A1C  ld (0x60346d),0x0001
	ld	(3607:16), 0	; F60A23  ld (0x0e17),0x00
	ld	(6304879:24), 1	; F60A28  ld (0x60346f),0x01
	ldw	(6304880:24), 1	; F60A2E  ld (0x603470),0x0001
	ldw	(6304882:24), 1	; F60A35  ld (0x603472),0x0001
	ld	(6304884:24), 1	; F60A3C  ld (0x603474),0x01
	ldw	(6304885:24), 1	; F60A42  ld (0x603475),0x0001
	ld	(3606:16), 0	; F60A49  ld (0x0e16),0x00
	ld	(6304945:24), 1	; F60A4E  ld (0x6034b1),0x01
	ldw	(6304946:24), 1	; F60A54  ld (0x6034b2),0x0001
	ldw	(6304948:24), 1	; F60A5B  ld (0x6034b4),0x0001
	ld	(6304950:24), 0	; F60A62  ld (0x6034b6),0x00
	ld	(6304951:24), 0	; F60A68  ld (0x6034b7),0x00
	ld	(6304956:24), 0	; F60A6E  ld (0x6034bc),0x00
	ld	(6304957:24), 0	; F60A74  ld (0x6034bd),0x00
	ld	(6304887:24), 0	; F60A7A  ld (0x603477),0x00
	ldw	(6304888:24), 1	; F60A80  ld (0x603478),0x0001
	ldw	(6304890:24), 1	; F60A87  ld (0x60347a),0x0001
	ld	(6304892:24), 2	; F60A8E  ld (0x60347c),0x02
	ld	(3125:16), 0	; F60A94  ld (0x0c35),0x00
	ld	(3588:16), 100	; F60A99  ld (0x0e04),0x64
	ld	(3589:16), 100	; F60A9E  ld (0x0e05),0x64
	ldw	wa, 1	; F60AA3  ld WA,0x0001
	ld	(3566:16), a	; F60AA6  ld (0x0dee),A
	ld	(N0teChange_FromMeasure:16), wa	; F60AAA  ld (0x0df0),WA
	ld	(N0teChange_ToMeasure:16), wa	; F60AAE  ld (0x0df2),WA
	ld	(3584:16), wa	; F60AB2  ld (0x0e00),WA
	xor	a, a	; F60AB6  xor A,A
	ld	(N0teChange_FromNote:16), a	; F60AB8  ld (0x0df4),A
	ld	(N0teChange_ToNote:16), a	; F60ABC  ld (0x0df5),A
	ld	wa, (N0teChange_ToMeasure:16)	; F60AC0  ld WA,(0x0df2)
	sub	wa, (N0teChange_FromMeasure:16)	; F60AC4  sub WA,(0x0df0)
	inc	1, wa	; F60AC8  inc 1,WA
	ld	(4766:16), wa	; F60ACA  ld (0x129e),WA
	ldw	wa, 1	; F60ACE  ld WA,0x0001
	ld	(3575:16), a	; F60AD1  ld (0x0df7),A
	ld	(3576:16), wa	; F60AD5  ld (0x0df8),WA
	ld	(3578:16), wa	; F60AD9  ld (0x0dfa),WA
	xor	a, a	; F60ADD  xor A,A
	ld	(3580:16), a	; F60ADF  ld (0x0dfc),A
	ld	wa, (3578:16)	; F60AE3  ld WA,(0x0dfa)
	sub	wa, (0x0df8:16)	; F60AE7  sub WA,(0x0df8)
	inc	1, wa	; F60AEB  inc 1,WA
	ld	(3584:16), wa	; F60AED  ld (0x0e00),WA
	ldw	wa, 1	; F60AF1  ld WA,0x0001
	ld	(3558:16), a	; F60AF4  ld (0x0de6),A
	ld	(3560:16), wa	; F60AF8  ld (0x0de8),WA
	ld	(3562:16), wa	; F60AFC  ld (0x0dea),WA
	ld	(3590:16), wa	; F60B00  ld (0x0e06),WA
	xor	a, a	; F60B04  xor A,A
	ld	(3564:16), a	; F60B06  ld (0x0dec),A
	ret	; F60B0A  ret
	ret	; F60B0B  ret

; --------------------------------------------------------------------------
; SongClear_ClearCurrentBank
; Called from: T_SongClear_ClearCurrentBank (x6)
; Touches: (0x0E02) (0x360A)
; Calls:   SongClear_ClearBank
; Evidence: thunk slot T_SongClear_ClearCurrentBank holds `jp 0x00F60B0C`, and 0xF60B0C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongClear_ClearCurrentBank: SongClear_ClearBank with (0x0E02) = BStore_CurrentBank, the old value restored.  Thunk T_SongClear_ClearCurrentBank, called by
;   BStore_ClearPasswordProtectedBanks and by SeqFile_Load on its target bank.
SongClear_ClearCurrentBank:		; <- T_SongClear_ClearCurrentBank
	ld	a, (3586:16)	; F60B0C  ld A,(0x0e02)
	pushw	wa	; F60B10  push WA
	ld	a, (BStore_CurrentBank:16)	; F60B11  ld A,(0x360a)
	ld	(3586:16), a	; F60B15  ld (0x0e02),A
	calr	SongClear_ClearBank	; F60B19  calr 0xf608d0
	popw	wa	; F60B1C  pop WA
	ld	(3586:16), a	; F60B1D  ld (0x0e02),A
	ret	; F60B21  ret

; --------------------------------------------------------------------------
; Seq_LoadTimeSigAtCurrentMeasure
; Called from: T_Seq_LoadTimeSigAtCurrentMeasure (x6)
; Touches: (0x0C90) (0x0D1C) (0x0D4A) (0x0DE3) (0x3552)
; Calls:   T_Seq_FindMasterTrack T_BStore_SeekMeasure
; Evidence: thunk slot T_Seq_LoadTimeSigAtCurrentMeasure holds `jp 0x00F60B22`, and 0xF60B22 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Seq_LoadTimeSigAtCurrentMeasure: (0x0DE3), the value of the sequencer screens' "TIME SIG.=" field, := the beats per
;   bar in force at the current measure (0x3552), looked up in the song through T_Seq_FindMasterTrack / T_BStore_SeekMeasure; the song's own
;   beats per bar (0x6034D7) when there is no lookup or it fails. Basis: callers + body. (wsa1/notes/naming-
;   pilot-2026-10-06/proposals_prom_b.json)
Seq_LoadTimeSigAtCurrentMeasure:		; <- T_Seq_LoadTimeSigAtCurrentMeasure
	call	T_Seq_FindMasterTrack	; F60B22  call 0xf427a0
	ld	a, w	; F60B26  ld A,W
	cp	w, 0:i3	; F60B28  cp W,0
	jr	z, Seq_LoadTimeSigAtCurrentMeasure_Skip	; F60B2A  jr Z,0xf60b44
	ld	hl, (13650:16)	; F60B2C  ld HL,(0x3552)
	ld	(3216:16), hl	; F60B30  ld (0x0c90),HL
	call	T_BStore_SeekMeasure	; F60B34  call 0xf42774
	ld	a, (3356:16)	; F60B38  ld A,(0x0d1c)
	cp	(BStore_ErrorCode:16), 0x00	; F60B3C  cp (0x0d4a),0x00
	jrl	z, Seq_LoadTimeSigAtCurrentMeasure_Skip2	; F60B41  jrl Z,0xf60b49
Seq_LoadTimeSigAtCurrentMeasure_Skip:
	ld	a, (6304983:24)	; F60B44  ld A,(0x6034d7)
Seq_LoadTimeSigAtCurrentMeasure_Skip2:
	ld	(3555:16), a	; F60B49  ld (0x0de3),A
	ret	; F60B4D  ret

; --------------------------------------------------------------------------
; Transp0se_Execute
; Called from: T_Transp0se_Execute (x1)
; Touches: (0x0C70) (0x0C73) (0x0C77) (0x0C8E) (0x0CA3) (0x0D18) (0x0D4A)  |
;          0x603422
; Calls:   T_BStore_LoadGeometry Transp0se_ApplyToTrack T_BStore_ErrorToStatusByte T_F40A1C
; Evidence: thunk slot T_Transp0se_Execute holds `jp 0x00F60B4E`, and 0xF60B4E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Transp0se_Execute: The TRANSP0SE job (Transp0se_LcdKeyRow2 stages track (0x0DF7), measure (0x0DF8), count (0x0E00)
;   and calls T_Transp0se_Execute): track 1..(0x0CA3) or 17 = all, measures 1..999 (error 3), master part 0x20 error 9; per track
;   Transp0se_ApplyToTrack adds the signed (0x0DFC) to the note byte (+2) of each 0x9n event, clamped 0..127. Basis: caller +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
Transp0se_Execute:		; <- T_Transp0se_Execute
	call	T_BStore_LoadGeometry	; F60B4E  call 0xf427c4
	ld	a, (3184:16)	; F60B52  ld A,(0x0c70)
	cp	a, 1:i3	; F60B56  cp A,1
	jr	c, Transp0se_Execute_Skip4	; F60B58  jr C,0xf60b83
	cp	a, 17	; F60B5A  cp A,0x11
	jr	z, Transp0se_Execute_Skip3	; F60B5D  jr Z,0xf60b65
	cp	a, (0x0ca3:16)	; F60B5F  cp A,(0x0ca3)
	jr	ugt, Transp0se_Execute_Skip4	; F60B63  jr UGT,0xf60b83
Transp0se_Execute_Skip3:
	ld	wa, (3187:16)	; F60B65  ld WA,(0x0c73)
	cp	wa, 1:i3	; F60B69  cp WA,1
	jr	c, Transp0se_Execute_Skip4	; F60B6B  jr C,0xf60b83
	cp	wa, 999	; F60B6D  cp WA,0x03e7
	jr	ugt, Transp0se_Execute_Skip4	; F60B71  jr UGT,0xf60b83
	ld	wa, (3191:16)	; F60B73  ld WA,(0x0c77)
	cp	wa, 1:i3	; F60B77  cp WA,1
	jr	c, Transp0se_Execute_Skip4	; F60B79  jr C,0xf60b83
	cp	wa, 999	; F60B7B  cp WA,0x03e7
	jr	ugt, Transp0se_Execute_Skip4	; F60B7F  jr UGT,0xf60b83
	jr	Transp0se_Execute_Join	; F60B81  jr T,0xf60b8b
Transp0se_Execute_Skip4:
	ld	(BStore_ErrorCode:16), 3	; F60B83  ld (0x0d4a),0x03
	jrl	Transp0se_Execute_Join4	; F60B88  jrl T,0xf60c23
Transp0se_Execute_Join:
	cp	(0x0c70:16), 0x11	; F60B8B  cp (0x0c70),0x11
	jr	z, Transp0se_Execute_Skip6	; F60B90  jr Z,0xf60bc8
	xor	xhl, xhl	; F60B92  xor XHL,XHL
	ld	l, (3184:16)	; F60B94  ld L,(0x0c70)
	dec	1, hl	; F60B98  dec 1,HL
	push	xix	; F60B9A  push XIX
	ld	xix, BStore_TrackToPart	; F60B9B  ld XIX,0x00603422
	ld	a, (xix+hl)	; F60BA0  ld A,(XIX+HL)
	pop	xix	; F60BA5  pop XIX
	cp	a, 32	; F60BA6  cp A,0x20
	jr	z, Transp0se_Execute_Skip5	; F60BA9  jr Z,0xf60bad
	jr	Transp0se_Execute_Join2	; F60BAB  jr T,0xf60bb5
Transp0se_Execute_Skip5:
	ld	(BStore_ErrorCode:16), 9	; F60BAD  ld (0x0d4a),0x09
	jrl	Transp0se_Execute_Join4	; F60BB2  jrl T,0xf60c23
Transp0se_Execute_Join2:
	ld	a, (3184:16)	; F60BB5  ld A,(0x0c70)
	ld	(3214:16), a	; F60BB9  ld (0x0c8e),A
	ld	(BStore_ErrorCode:16), 0	; F60BBD  ld (0x0d4a),0x00
	call	Transp0se_ApplyToTrack	; F60BC2  call 0xf60c2c
	jr	Transp0se_Execute_Join4	; F60BC6  jr T,0xf60c23
Transp0se_Execute_Skip6:
	xor	xhl, xhl	; F60BC8  xor XHL,XHL
Transp0se_Execute_Join3:
	cp	l, 16	; F60BCA  cp L,0x10
	jrl	ugt, Transp0se_Execute_Skip9	; F60BCD  jrl UGT,0xf60c1b
	ld	a, l	; F60BD0  ld A,L
	inc	1, a	; F60BD2  inc 1,A
	ld	(3214:16), a	; F60BD4  ld (0x0c8e),A
	xor	h, h	; F60BD8  xor H,H
	push	xhl	; F60BDA  push XHL
	push	xix	; F60BDB  push XIX
	ld	xix, BStore_TrackToPart	; F60BDC  ld XIX,0x00603422
	ld	a, (xix+hl)	; F60BE1  ld A,(XIX+HL)
	pop	xix	; F60BE6  pop XIX
	pop	xhl	; F60BE7  pop XHL
	cp	a, 32	; F60BE8  cp A,0x20
	jr	z, Transp0se_Execute_Skip7	; F60BEB  jr Z,0xf60bf3
	push	xhl	; F60BED  push XHL
	call	Transp0se_ApplyToTrack	; F60BEE  call 0xf60c2c
	pop	xhl	; F60BF2  pop XHL
Transp0se_Execute_Skip7:
	cp	(BStore_ErrorCode:16), 0x00	; F60BF3  cp (0x0d4a),0x00
	jr	z, Transp0se_Execute_Skip8	; F60BF8  jr Z,0xf60c17
	cp	(BStore_ErrorCode:16), 0x01	; F60BFA  cp (0x0d4a),0x01
	jr	z, Transp0se_Execute_Skip8	; F60BFF  jr Z,0xf60c17
	cp	(BStore_ErrorCode:16), 0x08	; F60C01  cp (0x0d4a),0x08
	jr	z, Transp0se_Execute_Skip8	; F60C06  jr Z,0xf60c17
	cp	(0x0d18:16), 0x00	; F60C08  cp (0x0d18),0x00
	jr	nz, Transp0se_Execute_Skip8	; F60C0D  jr NZ,0xf60c17
	ld	a, (BStore_ErrorCode:16)	; F60C0F  ld A,(0x0d4a)
	ld	(3352:16), a	; F60C13  ld (0x0d18),A
Transp0se_Execute_Skip8:
	inc	1, l	; F60C17  inc 1,L
	jr	Transp0se_Execute_Join3	; F60C19  jr T,0xf60bca
Transp0se_Execute_Skip9:
	ld	a, (3352:16)	; F60C1B  ld A,(0x0d18)
	ld	(BStore_ErrorCode:16), a	; F60C1F  ld (0x0d4a),A
Transp0se_Execute_Join4:
	call	T_BStore_ErrorToStatusByte	; F60C23  call 0xf4278c
	call	T_F40A1C	; F60C27  call 0xf40a1c
	ret	; F60C2B  ret

; --------------------------------------------------------------------------
; Transp0se_ApplyToTrack
; Called from: in-module: 0xF60BC2 0xF60BEE
; Touches: (0x0C73) (0x0C77) (0x0C8E) (0x0C90) (0x0CB4) (0x0CBA) (0x0CBC)
;          (0x0CBE) (0x0CCC) (0x0CCE) +6 more
; Calls:   T_BStore_ValidateSavedCursor T_Seq_FindMasterTrack T_BStore_SeekMeasure T_BStore_CursorAdvance T_F427A8
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF60C2C is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Transp0se_ApplyToTrack: TRANSP0SE on track (0x0C8E): nothing when the amount (0x0DFC) is 0; seeks measure (0x0C73)
;   and, for (0x0C77) measures, adds the signed (0x0DFC) to the note byte (+2) of each 0x9n event, clamped to 0..127.
;   Transp0se_Execute calls it for one track or each non-master track of ALL. Basis: caller + caller header + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
Transp0se_ApplyToTrack:
	ld	(BStore_ErrorCode:16), 0	; F60C2C  ld (0x0d4a),0x00
	xor	wa, wa	; F60C31  xor WA,WA
	cp	(0x0dfc:16), 0x00	; F60C33  cp (0x0dfc),0x00
	jrl	z, Transp0se_ApplyToTrack_Return	; F60C38  jrl Z,0xf60d3d
	ld	a, (3214:16)	; F60C3B  ld A,(0x0c8e)
	ld	(3354:16), a	; F60C3F  ld (0x0d1a),A
	call	T_BStore_ValidateSavedCursor	; F60C43  call 0xf42770
	cp	(BStore_ErrorCode:16), 0x00	; F60C47  cp (0x0d4a),0x00
	jrl	nz, Transp0se_ApplyToTrack_Return	; F60C4C  jrl NZ,0xf60d3d
	ld	(3278:16), iy	; F60C4F  ld (0x0cce),IY
	ld	wa, (BStore_CursorBlock:16)	; F60C53  ld WA,(0x345c)
	ld	(3276:16), wa	; F60C57  ld (0x0ccc),WA
	call	T_Seq_FindMasterTrack	; F60C5B  call 0xf427a0
	ld	a, (3214:16)	; F60C5F  ld A,(0x0c8e)
	ld	de, (3187:16)	; F60C63  ld DE,(0x0c73)
	ld	(3216:16), de	; F60C67  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F60C6B  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F60C6F  cp (0x0d4a),0x00
	jrl	nz, Transp0se_ApplyToTrack_Return	; F60C74  jrl NZ,0xf60d3d
	ld	(3258:16), iy	; F60C77  ld (0x0cba),IY
	ld	wa, (BStore_CursorBlock:16)	; F60C7B  ld WA,(0x345c)
	ld	(3252:16), wa	; F60C7F  ld (0x0cb4),WA
	ld	(3262:16), iy	; F60C83  ld (0x0cbe),IY
	ld	(3260:16), wa	; F60C87  ld (0x0cbc),WA
	ld	ix, iy	; F60C8B  ld IX,IY
	xor	de, de	; F60C8D  xor DE,DE
Transp0se_ApplyToTrack_Join:
	cp	de, (0x0c77:16)	; F60C8F  cp DE,(0x0c77)
	jrl	z, Transp0se_ApplyToTrack_Return	; F60C93  jrl Z,0xf60d3d
	xor	c, c	; F60C96  xor C,C
Transp0se_ApplyToTrack_Join2:
	cp	c, (0x0d1c:16)	; F60C98  cp C,(0x0d1c)
	jrl	z, Transp0se_ApplyToTrack_Skip4	; F60C9C  jrl Z,0xf60d1d
Transp0se_ApplyToTrack_Join3:
	push	xhl	; F60C9F  push XHL
	ld	xhl, (BStore_CursorBlockAddr:16)	; F60CA0  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F60CA4  ld A,(XHL+IY)
	pop	xhl	; F60CA9  pop XHL
	cp	a, 130	; F60CAA  cp A,0x82
	jrl	z, Transp0se_ApplyToTrack_Return	; F60CAD  jrl Z,0xf60d3d
	cp	a, 129	; F60CB0  cp A,0x81
	jr	z, Transp0se_ApplyToTrack_Skip3	; F60CB3  jr Z,0xf60d0d
	ld	w, 240:opc	; F60CB5  ld W,0xf0
	and	w, a	; F60CB7  and W,A
	cp	w, 144	; F60CB9  cp W,0x90
	jr	nz, Transp0se_ApplyToTrack_Skip2	; F60CBC  jr NZ,0xf60cff
	call	T_BStore_CursorAdvance	; F60CBE  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F60CC2  cp (0x0d4a),0x00
	jrl	nz, Transp0se_ApplyToTrack_Return	; F60CC7  jrl NZ,0xf60d3d
	call	T_BStore_CursorAdvance	; F60CCA  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F60CCE  cp (0x0d4a),0x00
	jrl	nz, Transp0se_ApplyToTrack_Return	; F60CD3  jrl NZ,0xf60d3d
	ld	xhl, (BStore_CursorBlockAddr:16)	; F60CD6  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F60CDA  ld A,(XHL+IY)
	xor	w, w	; F60CDF  xor W,W
	ld	l, (3580:16)	; F60CE1  ld L,(0x0dfc)
	exts	hl	; F60CE5  exts HL
	add	wa, hl	; F60CE7  add WA,HL
	jr	pl, Transp0se_ApplyToTrack_Skip	; F60CE9  jr P/PL,0xf60cef
	xor	a, a	; F60CEB  xor A,A
	jr	Transp0se_ApplyToTrack_Join4	; F60CED  jr T,0xf60cf6
Transp0se_ApplyToTrack_Skip:
	cp	a, 127	; F60CEF  cp A,0x7f
	jr	ule, Transp0se_ApplyToTrack_Join4	; F60CF2  jr ULE,0xf60cf6
	ld	a, 127:opc	; F60CF4  ld A,0x7f
Transp0se_ApplyToTrack_Join4:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F60CF6  ld XHL,(0x126e)
	ld	(xhl+iy), a	; F60CFA  ld (XHL+IY),A
Transp0se_ApplyToTrack_Skip2:
	call	T_BStore_CursorAdvance	; F60CFF  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F60D03  cp (0x0d4a),0x00
	jrl	nz, Transp0se_ApplyToTrack_Return	; F60D08  jrl NZ,0xf60d3d
	jr	Transp0se_ApplyToTrack_Join3	; F60D0B  jr T,0xf60c9f
Transp0se_ApplyToTrack_Skip3:
	call	T_BStore_CursorAdvance	; F60D0D  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F60D11  cp (0x0d4a),0x00
	jr	nz, Transp0se_ApplyToTrack_Return	; F60D16  jr NZ,0xf60d3d
	inc	1, c	; F60D18  inc 1,C
	jrl	Transp0se_ApplyToTrack_Join2	; F60D1A  jrl T,0xf60c98
Transp0se_ApplyToTrack_Skip4:
	inc	1, de	; F60D1D  inc 1,DE
	ld	xhl, (BStore_CursorBlockAddr:16)	; F60D1F  ld XHL,(0x126e)
	push	xhl	; F60D23  push XHL
	push	xde	; F60D24  push XDE
	push	xix	; F60D25  push XIX
	push	xiy	; F60D26  push XIY
	call	T_F427A8	; F60D27  call 0xf427a8
	pop	xiy	; F60D2B  pop XIY
	pop	xix	; F60D2C  pop XIX
	pop	xde	; F60D2D  pop XDE
	pop	xhl	; F60D2E  pop XHL
	ld	(BStore_CursorBlockAddr:16), xhl	; F60D2F  ld (0x126e),XHL
	cp	(BStore_ErrorCode:16), 0x00	; F60D33  cp (0x0d4a),0x00
	jr	nz, Transp0se_ApplyToTrack_Return	; F60D38  jr NZ,0xf60d3d
	jrl	Transp0se_ApplyToTrack_Join	; F60D3A  jrl T,0xf60c8f
Transp0se_ApplyToTrack_Return:
	ret	; F60D3D  ret

; --------------------------------------------------------------------------
; N0teChange_Execute
; Called from: T_N0teChange_Execute (x1)
; Touches: (0x0C70) (0x0C73) (0x0C77) (0x0C8E) (0x0CA3) (0x0D18) (0x0D4A)
;          (0x0DF4) (0x0DF5)  |  0x603422
; Calls:   T_BStore_LoadGeometry N0teChange_ApplyToTrack T_BStore_ErrorToStatusByte T_F40A1C
; Evidence: thunk slot T_N0teChange_Execute holds `jp 0x00F60D3E`, and 0xF60D3E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; N0teChange_Execute: The N0TE CHANGE job (N0teChange_LcdKeyRow4, through T_N0teChange_Execute): track 1..(0x0CA3) or 17 = all,
;   measures 1..999, N0teChange_FromNote / N0teChange_ToNote 0..127 (error 3), nothing when they are equal; per track
;   N0teChange_ApplyToTrack rewrites every 0x9n event whose note byte is FromNote to ToNote. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_q.json)
N0teChange_Execute:		; <- T_N0teChange_Execute
	call	T_BStore_LoadGeometry	; F60D3E  call 0xf427c4
	ld	a, (3184:16)	; F60D42  ld A,(0x0c70)
	cp	a, 1:i3	; F60D46  cp A,1
	jr	c, N0teChange_Execute_Skip6	; F60D48  jr C,0xf60d8b
	cp	a, 17	; F60D4A  cp A,0x11
	jr	z, N0teChange_Execute_Skip5	; F60D4D  jr Z,0xf60d55
	cp	a, (0x0ca3:16)	; F60D4F  cp A,(0x0ca3)
	jr	ugt, N0teChange_Execute_Skip6	; F60D53  jr UGT,0xf60d8b
N0teChange_Execute_Skip5:
	ld	wa, (3187:16)	; F60D55  ld WA,(0x0c73)
	cp	wa, 1:i3	; F60D59  cp WA,1
	jr	c, N0teChange_Execute_Skip6	; F60D5B  jr C,0xf60d8b
	cp	wa, 999	; F60D5D  cp WA,0x03e7
	jr	ugt, N0teChange_Execute_Skip6	; F60D61  jr UGT,0xf60d8b
	ld	wa, (3191:16)	; F60D63  ld WA,(0x0c77)
	cp	wa, 1:i3	; F60D67  cp WA,1
	jr	c, N0teChange_Execute_Skip6	; F60D69  jr C,0xf60d8b
	cp	wa, 999	; F60D6B  cp WA,0x03e7
	jr	ugt, N0teChange_Execute_Skip6	; F60D6F  jr UGT,0xf60d8b
	ld	a, (N0teChange_FromNote:16)	; F60D71  ld A,(0x0df4)
	cp	a, 0:i3	; F60D75  cp A,0
	jr	c, N0teChange_Execute_Skip6	; F60D77  jr C,0xf60d8b
	cp	a, 127	; F60D79  cp A,0x7f
	jr	ugt, N0teChange_Execute_Skip6	; F60D7C  jr UGT,0xf60d8b
	ld	a, (N0teChange_ToNote:16)	; F60D7E  ld A,(0x0df5)
	cp	a, 0:i3	; F60D82  cp A,0
	jr	c, N0teChange_Execute_Skip6	; F60D84  jr C,0xf60d8b
	cp	a, 127	; F60D86  cp A,0x7f
	jr	ule, N0teChange_Execute_Skip7	; F60D89  jr ULE,0xf60d93
N0teChange_Execute_Skip6:
	ld	(BStore_ErrorCode:16), 3	; F60D8B  ld (0x0d4a),0x03
	jrl	N0teChange_Execute_Join7	; F60D90  jrl T,0xf60e37
N0teChange_Execute_Skip7:
	ld	a, (N0teChange_FromNote:16)	; F60D93  ld A,(0x0df4)
	cp	a, (N0teChange_ToNote:16)	; F60D97  cp A,(0x0df5)
	jrl	z, N0teChange_Execute_Join7	; F60D9B  jrl Z,0xf60e37
	cp	(0x0c70:16), 0x11	; F60D9E  cp (0x0c70),0x11
	jr	z, N0teChange_Execute_Skip9	; F60DA3  jr Z,0xf60ddc
	xor	xhl, xhl	; F60DA5  xor XHL,XHL
	ld	l, (3184:16)	; F60DA7  ld L,(0x0c70)
	dec	1, hl	; F60DAB  dec 1,HL
	push	xix	; F60DAD  push XIX
	ld	xix, BStore_TrackToPart	; F60DAE  ld XIX,0x00603422
	ld	a, (xix+hl)	; F60DB3  ld A,(XIX+HL)
	pop	xix	; F60DB8  pop XIX
	cp	a, 32	; F60DB9  cp A,0x20
	jr	z, N0teChange_Execute_Skip8	; F60DBC  jr Z,0xf60dc0
	jr	N0teChange_Execute_Join5	; F60DBE  jr T,0xf60dc8
N0teChange_Execute_Skip8:
	ld	(BStore_ErrorCode:16), 9	; F60DC0  ld (0x0d4a),0x09
	jrl	N0teChange_Execute_Join7	; F60DC5  jrl T,0xf60e37
N0teChange_Execute_Join5:
	ld	a, (3184:16)	; F60DC8  ld A,(0x0c70)
	ld	(3214:16), a	; F60DCC  ld (0x0c8e),A
	ld	(BStore_ErrorCode:16), 0	; F60DD0  ld (0x0d4a),0x00
	call	N0teChange_ApplyToTrack	; F60DD5  call 0xf60e40
	jrl	N0teChange_Execute_Join7	; F60DD9  jrl T,0xf60e37
N0teChange_Execute_Skip9:
	xor	xhl, xhl	; F60DDC  xor XHL,XHL
N0teChange_Execute_Join6:
	cp	l, 16	; F60DDE  cp L,0x10
	jrl	ugt, N0teChange_Execute_Skip12	; F60DE1  jrl UGT,0xf60e2f
	ld	a, l	; F60DE4  ld A,L
	inc	1, a	; F60DE6  inc 1,A
	ld	(3214:16), a	; F60DE8  ld (0x0c8e),A
	xor	h, h	; F60DEC  xor H,H
	push	xhl	; F60DEE  push XHL
	push	xix	; F60DEF  push XIX
	ld	xix, BStore_TrackToPart	; F60DF0  ld XIX,0x00603422
	ld	a, (xix+hl)	; F60DF5  ld A,(XIX+HL)
	pop	xix	; F60DFA  pop XIX
	pop	xhl	; F60DFB  pop XHL
	cp	a, 32	; F60DFC  cp A,0x20
	jr	z, N0teChange_Execute_Skip10	; F60DFF  jr Z,0xf60e07
	push	xhl	; F60E01  push XHL
	call	N0teChange_ApplyToTrack	; F60E02  call 0xf60e40
	pop	xhl	; F60E06  pop XHL
N0teChange_Execute_Skip10:
	cp	(BStore_ErrorCode:16), 0x00	; F60E07  cp (0x0d4a),0x00
	jr	z, N0teChange_Execute_Skip11	; F60E0C  jr Z,0xf60e2b
	cp	(BStore_ErrorCode:16), 0x01	; F60E0E  cp (0x0d4a),0x01
	jr	z, N0teChange_Execute_Skip11	; F60E13  jr Z,0xf60e2b
	cp	(BStore_ErrorCode:16), 0x08	; F60E15  cp (0x0d4a),0x08
	jr	z, N0teChange_Execute_Skip11	; F60E1A  jr Z,0xf60e2b
	cp	(0x0d18:16), 0x00	; F60E1C  cp (0x0d18),0x00
	jr	nz, N0teChange_Execute_Skip11	; F60E21  jr NZ,0xf60e2b
	ld	a, (BStore_ErrorCode:16)	; F60E23  ld A,(0x0d4a)
	ld	(3352:16), a	; F60E27  ld (0x0d18),A
N0teChange_Execute_Skip11:
	inc	1, l	; F60E2B  inc 1,L
	jr	N0teChange_Execute_Join6	; F60E2D  jr T,0xf60dde
N0teChange_Execute_Skip12:
	ld	a, (3352:16)	; F60E2F  ld A,(0x0d18)
	ld	(BStore_ErrorCode:16), a	; F60E33  ld (0x0d4a),A
N0teChange_Execute_Join7:
	call	T_BStore_ErrorToStatusByte	; F60E37  call 0xf4278c
	call	T_F40A1C	; F60E3B  call 0xf40a1c
	ret	; F60E3F  ret

; --------------------------------------------------------------------------
; N0teChange_ApplyToTrack
; Called from: in-module: 0xF60DD5 0xF60E02
; Touches: (0x0C73) (0x0C77) (0x0C8E) (0x0C90) (0x0CB4) (0x0CBA) (0x0CBC)
;          (0x0CBE) (0x0CCC) (0x0CCE) +9 more
; Calls:   T_BStore_ValidateSavedCursor T_Seq_FindMasterTrack T_BStore_SeekMeasure T_BStore_CursorAdvance T_F427A8 BStore_EmptyBank
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF60E40 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; N0teChange_ApplyToTrack: N0TE CHANGE on track (0x0C8E): nothing when N0teChange_FromNote = N0teChange_ToNote; seeks
;   measure (0x0C73) and, for (0x0C77) measures, rewrites the note byte (+2) of each 0x9n event that equals FromNote
;   to ToNote. N0teChange_Execute calls it for one track or each track of ALL. Basis: caller + caller header + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
N0teChange_ApplyToTrack:
	ld	(BStore_ErrorCode:16), 0	; F60E40  ld (0x0d4a),0x00
	ld	a, (N0teChange_FromNote:16)	; F60E45  ld A,(0x0df4)
	cp	a, (N0teChange_ToNote:16)	; F60E49  cp A,(0x0df5)
	jrl	z, N0teChange_ApplyToTrack_Return	; F60E4D  jrl Z,0xf60f37
	xor	wa, wa	; F60E50  xor WA,WA
	ld	a, (3214:16)	; F60E52  ld A,(0x0c8e)
	ld	(3354:16), a	; F60E56  ld (0x0d1a),A
	call	T_BStore_ValidateSavedCursor	; F60E5A  call 0xf42770
	cp	(BStore_ErrorCode:16), 0x00	; F60E5E  cp (0x0d4a),0x00
	jrl	nz, N0teChange_ApplyToTrack_Return	; F60E63  jrl NZ,0xf60f37
	ld	(3278:16), iy	; F60E66  ld (0x0cce),IY
	ld	wa, (BStore_CursorBlock:16)	; F60E6A  ld WA,(0x345c)
	ld	(3276:16), wa	; F60E6E  ld (0x0ccc),WA
	call	T_Seq_FindMasterTrack	; F60E72  call 0xf427a0
	ld	a, (3214:16)	; F60E76  ld A,(0x0c8e)
	ld	de, (3187:16)	; F60E7A  ld DE,(0x0c73)
	ld	(3216:16), de	; F60E7E  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F60E82  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F60E86  cp (0x0d4a),0x00
	jrl	nz, N0teChange_ApplyToTrack_Return	; F60E8B  jrl NZ,0xf60f37
	ld	(3258:16), iy	; F60E8E  ld (0x0cba),IY
	ld	wa, (BStore_CursorBlock:16)	; F60E92  ld WA,(0x345c)
	ld	(3252:16), wa	; F60E96  ld (0x0cb4),WA
	ld	(3262:16), iy	; F60E9A  ld (0x0cbe),IY
	ld	(3260:16), wa	; F60E9E  ld (0x0cbc),WA
	ld	ix, iy	; F60EA2  ld IX,IY
	xor	de, de	; F60EA4  xor DE,DE
N0teChange_ApplyToTrack_Join:
	cp	de, (0x0c77:16)	; F60EA6  cp DE,(0x0c77)
	jrl	z, N0teChange_ApplyToTrack_Return	; F60EAA  jrl Z,0xf60f37
	xor	c, c	; F60EAD  xor C,C
N0teChange_ApplyToTrack_Join2:
	cp	c, (0x0d1c:16)	; F60EAF  cp C,(0x0d1c)
	jr	z, N0teChange_ApplyToTrack_Skip3	; F60EB3  jr Z,0xf60f1e
N0teChange_ApplyToTrack_Join3:
	push	xhl	; F60EB5  push XHL
	ld	xhl, (BStore_CursorBlockAddr:16)	; F60EB6  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F60EBA  ld A,(XHL+IY)
	pop	xhl	; F60EBF  pop XHL
	cp	a, 130	; F60EC0  cp A,0x82
	jr	z, N0teChange_ApplyToTrack_Return	; F60EC3  jr Z,0xf60f37
	cp	a, 129	; F60EC5  cp A,0x81
	jr	z, N0teChange_ApplyToTrack_Skip2	; F60EC8  jr Z,0xf60f0e
	ld	w, 240:opc	; F60ECA  ld W,0xf0
	and	w, a	; F60ECC  and W,A
	cp	w, 144	; F60ECE  cp W,0x90
	jr	nz, N0teChange_ApplyToTrack_Skip	; F60ED1  jr NZ,0xf60f01
	call	T_BStore_CursorAdvance	; F60ED3  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F60ED7  cp (0x0d4a),0x00
	jr	nz, N0teChange_ApplyToTrack_Return	; F60EDC  jr NZ,0xf60f37
	call	T_BStore_CursorAdvance	; F60EDE  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F60EE2  cp (0x0d4a),0x00
	jr	nz, N0teChange_ApplyToTrack_Return	; F60EE7  jr NZ,0xf60f37
	ld	xhl, (BStore_CursorBlockAddr:16)	; F60EE9  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F60EED  ld A,(XHL+IY)
	cp	a, (N0teChange_FromNote:16)	; F60EF2  cp A,(0x0df4)
	jr	nz, N0teChange_ApplyToTrack_Skip	; F60EF6  jr NZ,0xf60f01
	ld	a, (N0teChange_ToNote:16)	; F60EF8  ld A,(0x0df5)
	ld	(xhl+iy), a	; F60EFC  ld (XHL+IY),A
N0teChange_ApplyToTrack_Skip:
	call	T_BStore_CursorAdvance	; F60F01  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F60F05  cp (0x0d4a),0x00
	jr	nz, N0teChange_ApplyToTrack_Return	; F60F0A  jr NZ,0xf60f37
	jr	N0teChange_ApplyToTrack_Join3	; F60F0C  jr T,0xf60eb5
N0teChange_ApplyToTrack_Skip2:
	call	T_BStore_CursorAdvance	; F60F0E  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F60F12  cp (0x0d4a),0x00
	jr	nz, N0teChange_ApplyToTrack_Return	; F60F17  jr NZ,0xf60f37
	inc	1, c	; F60F19  inc 1,C
	jrl	N0teChange_ApplyToTrack_Join2	; F60F1B  jrl T,0xf60eaf
N0teChange_ApplyToTrack_Skip3:
	inc	1, de	; F60F1E  inc 1,DE
	ld	xhl, (BStore_CursorBlockAddr:16)	; F60F20  ld XHL,(0x126e)
	push	xhl	; F60F24  push XHL
	push	xde	; F60F25  push XDE
	push	xix	; F60F26  push XIX
	push	xiy	; F60F27  push XIY
	call	T_F427A8	; F60F28  call 0xf427a8
	pop	xiy	; F60F2C  pop XIY
	pop	xix	; F60F2D  pop XIX
	pop	xde	; F60F2E  pop XDE
	pop	xhl	; F60F2F  pop XHL
	ld	(BStore_CursorBlockAddr:16), xhl	; F60F30  ld (0x126e),XHL
	jrl	N0teChange_ApplyToTrack_Join	; F60F34  jrl T,0xf60ea6
N0teChange_ApplyToTrack_Return:
	ret	; F60F37  ret
	ld	a, (3586:16)	; F60F38  ld A,(0x0e02)
	pushw	wa	; F60F3C  push WA
	ld	a, (3635:16)	; F60F3D  ld A,(0x0e33)
	ld	(3586:16), a	; F60F41  ld (0x0e02),A
	call	BStore_EmptyBank	; F60F45  call 0xf60f4f
	popw	wa	; F60F49  pop WA
	ld	(3586:16), a	; F60F4A  ld (0x0e02),A
	ret	; F60F4E  ret

; --------------------------------------------------------------------------
; BStore_EmptyBank
; Called from: in-module: 0xF608E2 0xF6099B 0xF60F45 0xF611C0 0xF61871
; Touches: (0x0C70) (0x0CA4) (0x0E02) (0x360A) (0x360C) (0x3752)  |
;          0x00001C 0x00001E 0x00007E 0x0000A0 0x000100 0x000D50 +7 more
; Calls:   T_BStore_LoadGeometry T_BStore_FreeChain_Veneer
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF60F4F is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; BStore_EmptyBank: Empties song bank (0x0E02): frees the chains of tracks 1..16 (live directory when it is
;   BStore_CurrentBank, else the bank copy 0x610000+bank*0xC00+0x100), then resets that copy's 17 directory entries,
;   saved cursors (+0x7E 0xFFFF, +0xA0 5), +0x1E dword and password word +0x1C; on the current bank also the live
;   copies. Run by SongClear_ClearBank and by S0ngC0py_Execute for an ALL copy. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_q.json)
BStore_EmptyBank:
	call	T_BStore_LoadGeometry	; F60F4F  call 0xf427c4
	ld	l, (3184:16)	; F60F53  ld L,(0x0c70)
	pushw	hl	; F60F57  push HL
	ld	(3184:16), 1	; F60F58  ld (0x0c70),0x01
BStore_EmptyBank_Loop:
	xor	wa, wa	; F60F5D  xor WA,WA
	ld	a, (3184:16)	; F60F5F  ld A,(0x0c70)
	dec	1, a	; F60F63  dec 1,A
	ld	xde, 6356992	; F60F65  ld XDE,0x00610000
	push	xbc	; F60F6A  push XBC
	xor	xbc, xbc	; F60F6B  xor XBC,XBC
	xor	xwa, xwa	; F60F6D  xor XWA,XWA
	ld	a, (3586:16)	; F60F6F  ld A,(0x0e02)
	ld	c, a	; F60F73  ld C,A
	sla	xwa, 11	; F60F75  sla 0x0b,XWA
	sla	xbc, 10	; F60F78  sla 0x0a,XBC
	add	xwa, xbc	; F60F7B  add XWA,XBC
	pop	xbc	; F60F7D  pop XBC
	add	xde, xwa	; F60F7E  add XDE,XWA
	xor	xwa, xwa	; F60F80  xor XWA,XWA
	ld	a, (3184:16)	; F60F82  ld A,(0x0c70)
	dec	1, a	; F60F86  dec 1,A
	mul	wa, 3	; F60F88  mul WA,0x0003
	ld	iy, wa	; F60F8C  ld IY,WA
	ld	xix, 256	; F60F8E  ld XIX,0x00000100
	add	xix, xde	; F60F93  add XIX,XDE
	ld	a, (3586:16)	; F60F95  ld A,(0x0e02)
	cp	a, (BStore_CurrentBank:16)	; F60F99  cp A,(0x360a)
	jr	nz, BStore_EmptyBank_Skip	; F60F9D  jr NZ,0xf60fa4
	ld	xix, 6305024	; F60F9F  ld XIX,0x00603500
BStore_EmptyBank_Skip:
	bit	7, (xix+iy)	; F60FA4  bit 7,(XIX+IY)
	jr	z, BStore_EmptyBank_Skip2	; F60FA9  jr Z,0xf60fc2
	inc	1, iy	; F60FAB  inc 1,IY
	ld	wa, (xix+iy)	; F60FAD  ld WA,(XIX+IY)
	cp	wa, 65535	; F60FB2  cp WA,0xffff
	jr	z, BStore_EmptyBank_Skip2	; F60FB6  jr Z,0xf60fc2
	ld	iy, wa	; F60FB8  ld IY,WA
	ld	wa, (BStore_BlockLimit:16)	; F60FBA  ld WA,(0x0ca4)
	call	T_BStore_FreeChain_Veneer	; F60FBE  call 0xf42888
BStore_EmptyBank_Skip2:
	inc	1, (3184:16)	; F60FC2  inc 1,(0x0c70)
	cp	(0x0c70:16), 0x11	; F60FC6  cp (0x0c70),0x11
	jr	c, BStore_EmptyBank_Loop	; F60FCB  jr C,0xf60f5d
	ld	xde, 6356992	; F60FCD  ld XDE,0x00610000
	push	xbc	; F60FD2  push XBC
	xor	xbc, xbc	; F60FD3  xor XBC,XBC
	xor	xhl, xhl	; F60FD5  xor XHL,XHL
	ld	l, (3586:16)	; F60FD7  ld L,(0x0e02)
	ld	c, l	; F60FDB  ld C,L
	sla	xhl, 11	; F60FDD  sla 0x0b,XHL
	sla	xbc, 10	; F60FE0  sla 0x0a,XBC
	add	xhl, xbc	; F60FE3  add XHL,XBC
	pop	xbc	; F60FE5  pop XBC
	add	xde, xhl	; F60FE6  add XDE,XHL
	ld	xix, 126	; F60FE8  ld XIX,0x0000007e
	add	xix, xde	; F60FED  add XIX,XDE
	ldw	wa, 65535	; F60FEF  ld WA,0xffff
	ld	c, 17:opc	; F60FF2  ld C,0x11
	ld	(xix+), wa	; F60FF4  ld (XIX+),WA
	djnz8	c, -6	; F60FF7  djnz C,0xf60ff4
	ld	xix, 160	; F60FFA  ld XIX,0x000000a0
	add	xix, xde	; F60FFF  add XIX,XDE
	ld	a, 5:opc	; F61001  ld A,0x05
	ld	c, 17:opc	; F61003  ld C,0x11
	ld	(xix+), a	; F61005  ld (XIX+),A
	djnz8	c, -6	; F61008  djnz C,0xf61005
	ld	xhl, 256	; F6100B  ld XHL,0x00000100
	add	xhl, xde	; F61010  add XHL,XDE
	xor	wa, wa	; F61012  xor WA,WA
BStore_EmptyBank_Loop2:
	ld	(xhl+wa), 0x00	; F61014  ld (XHL+WA),0x00
	inc	1, wa	; F6101A  inc 1,WA
	ldw	(xhl+wa), 0xffff	; F6101C  ld (XHL+WA),0xffff
	inc	2, wa	; F61023  inc 2,WA
	cp	wa, 51	; F61025  cp WA,0x0033
	jr	c, BStore_EmptyBank_Loop2	; F61029  jr C,0xf61014
	ld	xix, 30	; F6102B  ld XIX,0x0000001e
	add	xix, xde	; F61030  add XIX,XDE
	xor	xwa, xwa	; F61032  xor XWA,XWA
	ld	(xix), xwa	; F61034  ld (XIX),XWA
	ld	xix, 28	; F61036  ld XIX,0x0000001c
	add	xix, xde	; F6103B  add XIX,XDE
	ldw	(xix), 0x0000	; F6103D  ld (XIX),0x0000
	ld	a, (3586:16)	; F61041  ld A,(0x0e02)
	cp	a, (BStore_CurrentBank:16)	; F61045  cp A,(0x360a)
	jrl	nz, BStore_EmptyBank_Skip3	; F61049  jrl NZ,0xf610dd
	ld	(14162:16), 0	; F6104C  ld (0x3752),0x00
	xor	xwa, xwa	; F61051  xor XWA,XWA
	ld	(6304798:24), xwa	; F61053  ld (0x60341e),XWA
	ld	(13836:16), xwa	; F61058  ld (0x360c),XWA
	ld	(BStore_Password:24), wa	; F6105C  ld (0x60341c),WA
	ld	xix, 6304894	; F61061  ld XIX,0x0060347e
	ldw	wa, 65535	; F61066  ld WA,0xffff
	ld	c, 17:opc	; F61069  ld C,0x11
	ld	(xix+), wa	; F6106B  ld (XIX+),WA
	djnz8	c, -6	; F6106E  djnz C,0xf6106b
	ld	xix, 6304928	; F61071  ld XIX,0x006034a0
	ld	a, 5:opc	; F61076  ld A,0x05
	ld	c, 17:opc	; F61078  ld C,0x11
	ld	(xix+), a	; F6107A  ld (XIX+),A
	djnz8	c, -6	; F6107D  djnz C,0xf6107a
	ld	xix, 13408	; F61080  ld XIX,0x00003460
	ldw	wa, 65535	; F61085  ld WA,0xffff
	ld	c, 17:opc	; F61088  ld C,0x11
	ld	(xix+), wa	; F6108A  ld (XIX+),WA
	djnz8	c, -6	; F6108D  djnz C,0xf6108a
	ld	xix, 13442	; F61090  ld XIX,0x00003482
	ld	a, 5:opc	; F61095  ld A,0x05
	ld	c, 17:opc	; F61097  ld C,0x11
	ld	(xix+), a	; F61099  ld (XIX+),A
	djnz8	c, -6	; F6109C  djnz C,0xf61099
	ld	xix, 6305024	; F6109F  ld XIX,0x00603500
	xor	hl, hl	; F610A4  xor HL,HL
BStore_EmptyBank_Loop3:
	ld	(xix+hl), 0x00	; F610A6  ld (XIX+HL),0x00
	inc	1, hl	; F610AC  inc 1,HL
	ldw	(xix+hl), 0xffff	; F610AE  ld (XIX+HL),0xffff
	inc	2, hl	; F610B5  inc 2,HL
	cp	hl, 51	; F610B7  cp HL,0x0033
	jr	c, BStore_EmptyBank_Loop3	; F610BB  jr C,0xf610a6
	push	xix	; F610BD  push XIX
	ld	xix, 3440	; F610BE  ld XIX,0x00000d70
	xor	a, a	; F610C3  xor A,A
	ld	c, 16:opc	; F610C5  ld C,0x10
	ld	(xix+), a	; F610C7  ld (XIX+),A
	djnz8	c, -6	; F610CA  djnz C,0xf610c7
	ld	xix, 3408	; F610CD  ld XIX,0x00000d50
	xor	wa, wa	; F610D2  xor WA,WA
	ld	c, 16:opc	; F610D4  ld C,0x10
	ld	(xix+), wa	; F610D6  ld (XIX+),WA
	djnz8	c, -6	; F610D9  djnz C,0xf610d6
	pop	xix	; F610DC  pop XIX
BStore_EmptyBank_Skip3:
	popw	hl	; F610DD  pop HL
	ld	(3184:16), l	; F610DE  ld (0x0c70),L
	ret	; F610E2  ret

; --------------------------------------------------------------------------
; SongClear_ResetAllBanks
; Called from: in-module: 0xF608DB
; Touches: (0x3010) (0x360C) (0x3752)  |  0x00001C 0x00001E 0x00007E
;          0x0000A0 0x000100 0x000D50 +2 more
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF610E3 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SongClear_ResetAllBanks: SONG CLEAR of all songs ((0x0E02) = 10): for each of the ten bank copies resets the
;   password word +0x1C, the 17 directory entries, the saved cursors and +0x1E, then zeroes (0x60341E), (0x360C),
;   (0x3010), the 0x0D50 words and (0x3752). It frees no chain: SongClear_ClearBank follows it with T_BStore_FreeList_Init_Veneer =
;   BStore_FreeList_Init. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
SongClear_ResetAllBanks:
	xor	bc, bc	; F610E3  xor BC,BC
SongClear_ResetAllBanks_Loop:
	pushw	bc	; F610E5  push BC
	ld	xde, 6356992	; F610E6  ld XDE,0x00610000
	push	xhl	; F610EB  push XHL
	xor	xhl, xhl	; F610EC  xor XHL,XHL
	xor	xwa, xwa	; F610EE  xor XWA,XWA
	ld	wa, bc	; F610F0  ld WA,BC
	ld	hl, wa	; F610F2  ld HL,WA
	sla	xwa, 11	; F610F4  sla 0x0b,XWA
	sla	xhl, 10	; F610F7  sla 0x0a,XHL
	add	xwa, xhl	; F610FA  add XWA,XHL
	pop	xhl	; F610FC  pop XHL
	add	xde, xwa	; F610FD  add XDE,XWA
	ld	xwa, 28	; F610FF  ld XWA,0x0000001c
	add	xwa, xde	; F61104  add XWA,XDE
	ldw	(xwa), 0x0000	; F61106  ld (XWA),0x0000
	ld	xwa, 256	; F6110A  ld XWA,0x00000100
	add	xwa, xde	; F6110F  add XWA,XDE
	xor	iy, iy	; F61111  xor IY,IY
SongClear_ResetAllBanks_Loop2:
	ld	(xwa+iy), 0x00	; F61113  ld (XWA+IY),0x00
	inc	1, iy	; F61119  inc 1,IY
	ldw	(xwa+iy), 0xffff	; F6111B  ld (XWA+IY),0xffff
	inc	2, iy	; F61122  inc 2,IY
	cp	iy, 51	; F61124  cp IY,0x0033
	jr	c, SongClear_ResetAllBanks_Loop2	; F61128  jr C,0xf61113
	ld	xwa, 126	; F6112A  ld XWA,0x0000007e
	add	xwa, xde	; F6112F  add XWA,XDE
	ldw	iy, 65535	; F61131  ld IY,0xffff
	ld	c, 17:opc	; F61134  ld C,0x11
	ld	(xwa+), iy	; F61136  ld (XWA+),IY
	djnz8	c, -6	; F61139  djnz C,0xf61136
	ld	xwa, 160	; F6113C  ld XWA,0x000000a0
	add	xwa, xde	; F61141  add XWA,XDE
	ld	b, 5:opc	; F61143  ld B,0x05
	ld	c, 17:opc	; F61145  ld C,0x11
	ld	(xwa+), b	; F61147  ld (XWA+),B
	djnz8	c, -6	; F6114A  djnz C,0xf61147
	ld	xwa, 30	; F6114D  ld XWA,0x0000001e
	add	xwa, xde	; F61152  add XWA,XDE
	push	xhl	; F61154  push XHL
	xor	xhl, xhl	; F61155  xor XHL,XHL
	ld	(xwa), xhl	; F61157  ld (XWA),XHL
	pop	xhl	; F61159  pop XHL
	popw	bc	; F6115A  pop BC
	inc	1, bc	; F6115B  inc 1,BC
	cp	bc, 10	; F6115D  cp BC,0x000a
	jrl	c, SongClear_ResetAllBanks_Loop	; F61161  jrl C,0xf610e5
	xor	xwa, xwa	; F61164  xor XWA,XWA
	ld	(6304798:24), xwa	; F61166  ld (0x60341e),XWA
	ld	(13836:16), xwa	; F6116B  ld (0x360c),XWA
	ld	xix, 3408	; F6116F  ld XIX,0x00000d50
	xor	wa, wa	; F61174  xor WA,WA
	ld	c, 16:opc	; F61176  ld C,0x10
	ld	(xix+), wa	; F61178  ld (XIX+),WA
	djnz8	c, -6	; F6117B  djnz C,0xf61178
	ld	xix, 3440	; F6117E  ld XIX,0x00000d70
	ld	c, 16:opc	; F61183  ld C,0x10
	ld	(xix), a	; F61185  ld (XIX),A
	djnz8	b, -5	; F61187  djnz B,0xf61185
	xor	xwa, xwa	; F6118A  xor XWA,XWA
	ld	(12304:16), xwa	; F6118C  ld (0x3010),XWA
	ld	(13836:16), xwa	; F61190  ld (0x360c),XWA
	ld	(14162:16), 0	; F61194  ld (0x3752),0x00
	ret	; F61199  ret

; --------------------------------------------------------------------------
; S0ngC0py_Execute
; Called from: T_S0ngC0py_Execute (x1)
; Touches: (0x0C70) (0x0E02) (0x0E0C) (0x0E0D) (0x0E0E) (0x0E0F) (0x0E10)
;          (0x0E19) (0x126E) (0x134C) +8 more  |  0x000005 0x00001E 0x000022
;          0x00007E 0x0000A0 0x000100 +5 more
; Calls:   BStore_EmptyBank S0ngC0py_CopyAllTracks S0ngC0py_ClearDestTrack S0ngC0py_AllocDestHeadBlock T_BStore_SeekBlock T_BStore_AllocBlock_Veneer
; Evidence: thunk slot T_S0ngC0py_Execute holds `jp 0x00F6119A`, and 0xF6119A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; S0ngC0py_Execute: The SONG COPY job (S0ngC0py_LcdKeyRow2's confirm press, T_S0ngC0py_Execute): ALL (S0ngC0py_FromTrack 0x12)
;   empties bank ToSong-1 (BStore_EmptyBank) and copies the song (S0ngC0py_CopyAllTracks); otherwise copies track FromTrack of
;   FromSong onto ToTrack of ToSong: status 29 when only one side is track 0x11 or master part 0x20, clears the
;   destination (S0ngC0py_ClearDestTrack), duplicates the chain block by block, status 15 when blocks run out. Basis:
;   caller + body. (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
S0ngC0py_Execute:		; <- T_S0ngC0py_Execute
	ld	(UI_StatusCode:16), 35	; F6119A  ld (0x2880),0x23
	cp	(S0ngC0py_FromTrack:16), 0x12	; F6119F  cp (0x0e0e),0x12
	jr	nz, S0ngC0py_Execute_Skip	; F611A4  jr NZ,0xf611d0
	ld	a, (S0ngC0py_ToSong:16)	; F611A6  ld A,(0x0e0d)
	cp	a, (S0ngC0py_FromSong:16)	; F611AA  cp A,(0x0e0c)
	jrl	z, sub_F610E3_Return	; F611AE  jrl Z,0xf615c1
	ld	a, (3586:16)	; F611B1  ld A,(0x0e02)
	pushw	wa	; F611B5  push WA
	ld	a, (S0ngC0py_ToSong:16)	; F611B6  ld A,(0x0e0d)
	dec	1, a	; F611BA  dec 1,A
	ld	(3586:16), a	; F611BC  ld (0x0e02),A
	call	BStore_EmptyBank	; F611C0  call 0xf60f4f
	popw	wa	; F611C4  pop WA
	ld	(3586:16), a	; F611C5  ld (0x0e02),A
	call	S0ngC0py_CopyAllTracks	; F611C9  call 0xf615c2
	jrl	sub_F610E3_Return	; F611CD  jrl T,0xf615c1
S0ngC0py_Execute_Skip:
	cp	(S0ngC0py_FromTrack:16), 0x11	; F611D0  cp (0x0e0e),0x11
	jr	nz, S0ngC0py_Execute_Skip2	; F611D5  jr NZ,0xf611e0
	cp	(S0ngC0py_ToTrack:16), 0x11	; F611D7  cp (0x0e0f),0x11
	jr	nz, S0ngC0py_Execute_Skip3	; F611DC  jr NZ,0xf611e7
	jr	S0ngC0py_Execute_Join	; F611DE  jr T,0xf611f5
S0ngC0py_Execute_Skip2:
	cp	(S0ngC0py_ToTrack:16), 0x11	; F611E0  cp (0x0e0f),0x11
	jr	nz, S0ngC0py_Execute_Join	; F611E5  jr NZ,0xf611f5
S0ngC0py_Execute_Skip3:
	ld	(UI_StatusCode:16), 29	; F611E7  ld (0x2880),0x1d
	ldw	(UI_Request:16), 16555	; F611EC  ld (0x2070),0x40ab
	jrl	sub_F610E3_Return	; F611F2  jrl T,0xf615c1
S0ngC0py_Execute_Join:
	ld	a, (S0ngC0py_FromSong:16)	; F611F5  ld A,(0x0e0c)
	cp	a, (S0ngC0py_ToSong:16)	; F611F9  cp A,(0x0e0d)
	jr	nz, S0ngC0py_Execute_Skip4	; F611FD  jr NZ,0xf6120a
	ld	a, (S0ngC0py_FromTrack:16)	; F611FF  ld A,(0x0e0e)
	cp	a, (S0ngC0py_ToTrack:16)	; F61203  cp A,(0x0e0f)
	jrl	z, sub_F610E3_Return	; F61207  jrl Z,0xf615c1
S0ngC0py_Execute_Skip4:
	ld	xde, 6356992	; F6120A  ld XDE,0x00610000
	push	xbc	; F6120F  push XBC
	xor	xbc, xbc	; F61210  xor XBC,XBC
	xor	xhl, xhl	; F61212  xor XHL,XHL
	ld	l, (S0ngC0py_FromSong:16)	; F61214  ld L,(0x0e0c)
	dec	1, l	; F61218  dec 1,L
	ld	c, l	; F6121A  ld C,L
	sla	xhl, 11	; F6121C  sla 0x0b,XHL
	sla	xbc, 10	; F6121F  sla 0x0a,XBC
	add	xhl, xbc	; F61222  add XHL,XBC
	pop	xbc	; F61224  pop XBC
	add	xde, xhl	; F61225  add XDE,XHL
	ld	xhl, 34	; F61227  ld XHL,0x00000022
	add	xhl, xde	; F6122C  add XHL,XDE
	ld	c, (S0ngC0py_FromSong:16)	; F6122E  ld C,(0x0e0c)
	dec	1, c	; F61232  dec 1,C
	cp	c, (BStore_CurrentBank:16)	; F61234  cp C,(0x360a)
	jr	nz, S0ngC0py_Execute_Skip5	; F61238  jr NZ,0xf6123f
	ld	xhl, BStore_TrackToPart	; F6123A  ld XHL,0x00603422
S0ngC0py_Execute_Skip5:
	xor	bc, bc	; F6123F  xor BC,BC
	ld	c, (S0ngC0py_FromTrack:16)	; F61241  ld C,(0x0e0e)
	dec	1, c	; F61245  dec 1,C
	ld	a, (xhl+bc)	; F61247  ld A,(XHL+BC)
	ld	(4940:16), a	; F6124C  ld (0x134c),A
	.byte 0xE7, 0x38, 0x03, 0x00, 0x00, 0x61, 0x00	; F61250  ld XDE3,0x00610000   [llvm-mc cannot encode this]
	push	xbc	; F61257  push XBC
	xor	xbc, xbc	; F61258  xor XBC,XBC
	xor	xhl, xhl	; F6125A  xor XHL,XHL
	ld	l, (S0ngC0py_ToSong:16)	; F6125C  ld L,(0x0e0d)
	dec	1, l	; F61260  dec 1,L
	ld	c, l	; F61262  ld C,L
	sla	xhl, 11	; F61264  sla 0x0b,XHL
	sla	xbc, 10	; F61267  sla 0x0a,XBC
	add	xhl, xbc	; F6126A  add XHL,XBC
	pop	xbc	; F6126C  pop XBC
	m_rd_add_rrx RLX, 0x38, r3	; F6126D  add XHL,XDE3
	ldfr_lerp	xhl, 0x38	; F61270  ld XDE3,XHL
	ld	xhl, 34	; F61273  ld XHL,0x00000022
	m_rd_add_rrx RLX, 0x38, r3	; F61278  add XHL,XDE3
	ld	a, (S0ngC0py_ToSong:16)	; F6127B  ld A,(0x0e0d)
	dec	1, a	; F6127F  dec 1,A
	cp	a, (BStore_CurrentBank:16)	; F61281  cp A,(0x360a)
	jr	nz, S0ngC0py_Execute_Skip6	; F61285  jr NZ,0xf6128c
	ld	xhl, BStore_TrackToPart	; F61287  ld XHL,0x00603422
S0ngC0py_Execute_Skip6:
	xor	wa, wa	; F6128C  xor WA,WA
	ld	a, (S0ngC0py_ToTrack:16)	; F6128E  ld A,(0x0e0f)
	dec	1, a	; F61292  dec 1,A
	ld	a, (xhl+wa)	; F61294  ld A,(XHL+WA)
	ld	(4941:16), a	; F61299  ld (0x134d),A
	cp	a, 32	; F6129D  cp A,0x20
	jr	z, S0ngC0py_Execute_Skip7	; F612A0  jr Z,0xf612ab
	cp	(0x134c:16), 0x20	; F612A2  cp (0x134c),0x20
	jr	z, S0ngC0py_Execute_Skip8	; F612A7  jr Z,0xf612b2
	jr	S0ngC0py_Execute_Join2	; F612A9  jr T,0xf612c0
S0ngC0py_Execute_Skip7:
	cp	(0x134c:16), 0x20	; F612AB  cp (0x134c),0x20
	jr	z, S0ngC0py_Execute_Join2	; F612B0  jr Z,0xf612c0
S0ngC0py_Execute_Skip8:
	ld	(UI_StatusCode:16), 29	; F612B2  ld (0x2880),0x1d
	ldw	(UI_Request:16), 16555	; F612B7  ld (0x2070),0x40ab
	jrl	sub_F610E3_Return	; F612BD  jrl T,0xf615c1
S0ngC0py_Execute_Join2:
	ld	xhl, 34	; F612C0  ld XHL,0x00000022
	m_rd_add_rrx RLX, 0x38, r3	; F612C5  add XHL,XDE3
	ldfr_lerp	xhl, 0x38	; F612C8  ld XDE3,XHL
	ld	l, (S0ngC0py_ToSong:16)	; F612CB  ld L,(0x0e0d)
	dec	1, l	; F612CF  dec 1,L
	cp	l, (BStore_CurrentBank:16)	; F612D1  cp L,(0x360a)
	jr	nz, S0ngC0py_Execute_Skip9	; F612D5  jr NZ,0xf612de
	.byte 0xE7, 0x38, 0x03, 0x22, 0x34, 0x60, 0x00	; F612D7  ld XDE3,0x00603422   [llvm-mc cannot encode this]
S0ngC0py_Execute_Skip9:
	cpw	(BStore_FreeCount:24), 0x0000	; F612DE  cp (0x6034ba),0x0000
	jrl	z, sub_F610E3_Skip20	; F612E5  jrl Z,0xf615a4
	ld	l, (S0ngC0py_ToSong:16)	; F612E8  ld L,(0x0e0d)
	dec	1, l	; F612EC  dec 1,L
	ld	(3600:16), l	; F612EE  ld (0x0e10),L
	ld	l, (S0ngC0py_ToTrack:16)	; F612F2  ld L,(0x0e0f)
	dec	1, l	; F612F6  dec 1,L
	ld	(3609:16), l	; F612F8  ld (0x0e19),L
	call	S0ngC0py_ClearDestTrack	; F612FC  call 0xf61907
	ld	xde, 6356992	; F61300  ld XDE,0x00610000
	push	xbc	; F61305  push XBC
	xor	xbc, xbc	; F61306  xor XBC,XBC
	xor	xhl, xhl	; F61308  xor XHL,XHL
	ld	l, (S0ngC0py_FromSong:16)	; F6130A  ld L,(0x0e0c)
	dec	1, l	; F6130E  dec 1,L
	ld	c, l	; F61310  ld C,L
	sla	xhl, 11	; F61312  sla 0x0b,XHL
	sla	xbc, 10	; F61315  sla 0x0a,XBC
	add	xhl, xbc	; F61318  add XHL,XBC
	pop	xbc	; F6131A  pop XBC
	add	xde, xhl	; F6131B  add XDE,XHL
	ld	xhl, 256	; F6131D  ld XHL,0x00000100
	add	xhl, xde	; F61322  add XHL,XDE
	ld	c, (S0ngC0py_FromSong:16)	; F61324  ld C,(0x0e0c)
	dec	1, c	; F61328  dec 1,C
	cp	c, (BStore_CurrentBank:16)	; F6132A  cp C,(0x360a)
	jr	nz, S0ngC0py_Execute_Skip10	; F6132E  jr NZ,0xf61335
	ld	xhl, 6305024	; F61330  ld XHL,0x00603500
S0ngC0py_Execute_Skip10:
	ld	c, (S0ngC0py_FromTrack:16)	; F61335  ld C,(0x0e0e)
	dec	1, c	; F61339  dec 1,C
	ld	b, c	; F6133B  ld B,C
	sla	b, 1	; F6133D  sla 0x01,B
	add	c, b	; F61340  add C,B
	xor	b, b	; F61342  xor B,B
	bit	7, (xhl+bc)	; F61344  bit 7,(XHL+BC)
	jrl	z, sub_F610E3_Entry	; F61349  jrl Z,0xf614a3
	inc	1, bc	; F6134C  inc 1,BC
	ld	hl, (xhl+bc)	; F6134E  ld HL,(XHL+BC)
	cp	hl, 0:i3	; F61353  cp HL,0
	jrl	z, sub_F610E3_Entry	; F61355  jrl Z,0xf614a3
	cp	hl, 65535	; F61358  cp HL,0xffff
	jrl	z, sub_F610E3_Entry	; F6135C  jrl Z,0xf614a3
	ld	a, (S0ngC0py_ToTrack:16)	; F6135F  ld A,(0x0e0f)
	dec	1, a	; F61363  dec 1,A
	ld	(3184:16), a	; F61365  ld (0x0c70),A
	push	xhl	; F61369  push XHL
	push	xbc	; F6136A  push XBC
	push	xde	; F6136B  push XDE
	call	S0ngC0py_AllocDestHeadBlock	; F6136C  call 0xf61880
	pop	xde	; F61370  pop XDE
	pop	xbc	; F61371  pop XBC
	pop	xhl	; F61372  pop XHL
	ld	xix, (BStore_CursorBlockAddr:16)	; F61373  ld XIX,(0x126e)
	call	T_BStore_SeekBlock	; F61377  call 0xf427bc
	ld	xiy, (BStore_CursorBlockAddr:16)	; F6137B  ld XIY,(0x126e)
	ldw	bc, 251	; F6137F  ld BC,0x00fb
	inc	5, xix	; F61382  inc 5,XIX
	inc	5, xiy	; F61384  inc 5,XIY
	ldir85	; F61386  ldir
S0ngC0py_Execute_Join3:
	sub	xiy, 256	; F61388  sub XIY,0x00000100
	ld	hl, (xiy+3)	; F6138E  ld HL,(XIY+0x03)
	cp	hl, 65535	; F61391  cp HL,0xffff
	jr	z, S0ngC0py_Execute_Skip11	; F61395  jr Z,0xf613f0
	call	T_BStore_SeekBlock	; F61397  call 0xf427bc
	ld	xiy, (BStore_CursorBlockAddr:16)	; F6139B  ld XIY,(0x126e)
	cpw	(BStore_FreeCount:24), 0x0000	; F6139F  cp (0x6034ba),0x0000
	jrl	z, sub_F610E3_Skip20	; F613A6  jrl Z,0xf615a4
	push	xiy	; F613A9  push XIY
	call	T_BStore_AllocBlock_Veneer	; F613AA  call 0xf42884
	pop	xiy	; F613AE  pop XIY
	ld	hl, (BStore_CursorBlock:16)	; F613AF  ld HL,(0x345c)
	call	T_BStore_SeekBlock	; F613B3  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F613B7  ld XHL,(0x126e)
	ld	(xhl+3), ix	; F613BB  ld (XHL+0x03),IX
	ld	hl, ix	; F613BE  ld HL,IX
	call	T_BStore_SeekBlock	; F613C0  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F613C4  ld XHL,(0x126e)
	or	(xhl), 0x80	; F613C8  or (XHL),0x80
	ld	wa, (BStore_CursorBlock:16)	; F613CB  ld WA,(0x345c)
	ld	(xhl+1), wa	; F613CF  ld (XHL+0x01),WA
	ldw	(xhl+3), 0xffff	; F613D2  ld (XHL+0x03),0xffff
	ld	(BStore_CursorBlock:16), ix	; F613D7  ld (0x345c),IX
	ld	xix, xhl	; F613DB  ld XIX,XHL
	add	xix, 5	; F613DD  add XIX,0x00000005
	add	xiy, 5	; F613E3  add XIY,0x00000005
	ldw	bc, 251	; F613E9  ld BC,0x00fb
	ldir85	; F613EC  ldir
	jr	S0ngC0py_Execute_Join3	; F613EE  jr T,0xf61388
S0ngC0py_Execute_Skip11:
	ld	xde, 6356992	; F613F0  ld XDE,0x00610000
	push	xbc	; F613F5  push XBC
	xor	xbc, xbc	; F613F6  xor XBC,XBC
	xor	xwa, xwa	; F613F8  xor XWA,XWA
	ld	a, (S0ngC0py_ToSong:16)	; F613FA  ld A,(0x0e0d)
	dec	1, a	; F613FE  dec 1,A
	ld	c, a	; F61400  ld C,A
	sla	xwa, 11	; F61402  sla 0x0b,XWA
	sla	xbc, 10	; F61405  sla 0x0a,XBC
	add	xwa, xbc	; F61408  add XWA,XBC
	pop	xbc	; F6140A  pop XBC
	add	xde, xwa	; F6140B  add XDE,XWA
	ld	xhl, 126	; F6140D  ld XHL,0x0000007e
	add	xhl, xde	; F61412  add XHL,XDE
	xor	wa, wa	; F61414  xor WA,WA
	ld	a, (3184:16)	; F61416  ld A,(0x0c70)
	sla	a, 1	; F6141A  sla 0x01,A
	ld	ix, (BStore_CursorBlock:16)	; F6141D  ld IX,(0x345c)
	ld	(xhl+wa), ix	; F61421  ld (XHL+WA),IX
	ld	b, (S0ngC0py_ToSong:16)	; F61426  ld B,(0x0e0d)
	dec	1, b	; F6142A  dec 1,B
	cp	b, (BStore_CurrentBank:16)	; F6142C  cp B,(0x360a)
	jr	nz, S0ngC0py_Execute_Skip12	; F61430  jr NZ,0xf6143c
	ld	xhl, 6304894	; F61432  ld XHL,0x0060347e
	ld	(xhl+wa), ix	; F61437  ld (XHL+WA),IX
S0ngC0py_Execute_Skip12:
	ld	xhl, 6356992	; F6143C  ld XHL,0x00610000
	push	xwa	; F61441  push XWA
	xor	xwa, xwa	; F61442  xor XWA,XWA
	xor	xbc, xbc	; F61444  xor XBC,XBC
	ld	c, (S0ngC0py_FromSong:16)	; F61446  ld C,(0x0e0c)
	dec	1, c	; F6144A  dec 1,C
	ld	a, c	; F6144C  ld A,C
	sla	xbc, 11	; F6144E  sla 0x0b,XBC
	sla	xwa, 10	; F61451  sla 0x0a,XWA
	add	xbc, xwa	; F61454  add XBC,XWA
	pop	xwa	; F61456  pop XWA
	add	xhl, xbc	; F61457  add XHL,XBC
	ld	xbc, 160	; F61459  ld XBC,0x000000a0
	add	xhl, xbc	; F6145E  add XHL,XBC
	ld	c, (S0ngC0py_FromSong:16)	; F61460  ld C,(0x0e0c)
	dec	1, c	; F61464  dec 1,C
	cp	c, (BStore_CurrentBank:16)	; F61466  cp C,(0x360a)
	jr	nz, S0ngC0py_Execute_Skip13	; F6146A  jr NZ,0xf61471
	ld	xhl, 6304928	; F6146C  ld XHL,0x006034a0
S0ngC0py_Execute_Skip13:
	ld	c, (S0ngC0py_FromTrack:16)	; F61471  ld C,(0x0e0e)
	dec	1, c	; F61475  dec 1,C
	xor	b, b	; F61477  xor B,B
	ld	c, (xhl+bc)	; F61479  ld C,(XHL+BC)
	ld	xhl, 160	; F6147E  ld XHL,0x000000a0
	add	xhl, xde	; F61483  add XHL,XDE
	sra	wa, 1	; F61485  sra 0x01,WA
	ld	(xhl+wa), c	; F61488  ld (XHL+WA),C
	ld	b, (S0ngC0py_ToSong:16)	; F6148D  ld B,(0x0e0d)
	dec	1, b	; F61491  dec 1,B
	cp	b, (BStore_CurrentBank:16)	; F61493  cp B,(0x360a)
	jr	nz, sub_F610E3_Entry	; F61497  jr NZ,0xf614a3
	ld	xhl, 6304928	; F61499  ld XHL,0x006034a0
	ld	(xhl+wa), c	; F6149E  ld (XHL+WA),C
sub_F610E3_Entry:
	.byte 0xE7, 0x38, 0x03, 0x00, 0x00, 0x61, 0x00	; F614A3  ld XDE3,0x00610000   [llvm-mc cannot encode this]
	xor	xbc, xbc	; F614AA  xor XBC,XBC
	xor	xhl, xhl	; F614AC  xor XHL,XHL
	ld	l, (S0ngC0py_ToSong:16)	; F614AE  ld L,(0x0e0d)
	dec	1, l	; F614B2  dec 1,L
	ld	c, l	; F614B4  ld C,L
	sla	xhl, 11	; F614B6  sla 0x0b,XHL
	sla	xbc, 10	; F614B9  sla 0x0a,XBC
	add	xhl, xbc	; F614BC  add XHL,XBC
	m_rd_add_rrx RLX, 0x38, r3	; F614BE  add XHL,XDE3
	ld	xbc, 34	; F614C1  ld XBC,0x00000022
	add	xhl, xbc	; F614C6  add XHL,XBC
	ld	c, (S0ngC0py_ToSong:16)	; F614C8  ld C,(0x0e0d)
	dec	1, c	; F614CC  dec 1,C
	cp	c, (BStore_CurrentBank:16)	; F614CE  cp C,(0x360a)
	jr	nz, sub_F610E3_Skip14	; F614D2  jr NZ,0xf614d9
	ld	xhl, BStore_TrackToPart	; F614D4  ld XHL,0x00603422
sub_F610E3_Skip14:
	ld	c, (S0ngC0py_ToTrack:16)	; F614D9  ld C,(0x0e0f)
	dec	1, c	; F614DD  dec 1,C
	xor	b, b	; F614DF  xor B,B
	xor	xix, xix	; F614E1  xor XIX,XIX
	xor	xwa, xwa	; F614E3  xor XWA,XWA
	ld	a, (S0ngC0py_FromSong:16)	; F614E5  ld A,(0x0e0c)
	dec	1, a	; F614E9  dec 1,A
	ld	xix, xwa	; F614EB  ld XIX,XWA
	sla	xwa, 11	; F614ED  sla 0x0b,XWA
	sla	xix, 10	; F614F0  sla 0x0a,XIX
	add	xwa, xix	; F614F3  add XWA,XIX
	m_rd_add_rrx RLX, 0x38, r0	; F614F5  add XWA,XDE3
	ld	xix, 34	; F614F8  ld XIX,0x00000022
	add	xix, xwa	; F614FD  add XIX,XWA
	ld	a, (S0ngC0py_FromTrack:16)	; F614FF  ld A,(0x0e0e)
	dec	1, a	; F61503  dec 1,A
	xor	w, w	; F61505  xor W,W
	ld	a, (xix+wa)	; F61507  ld A,(XIX+WA)
	ld	(xhl+bc), a	; F6150C  ld (XHL+BC),A
	ld	w, (S0ngC0py_ToSong:16)	; F61511  ld W,(0x0e0d)
	dec	1, w	; F61515  dec 1,W
	cp	w, (BStore_CurrentBank:16)	; F61517  cp W,(0x360a)
	jrl	nz, sub_F610E3_Skip15	; F6151B  jrl NZ,0xf61528
	ld	xhl, BStore_TrackToPart	; F6151E  ld XHL,0x00603422
	ld	(xhl+bc), a	; F61523  ld (XHL+BC),A
sub_F610E3_Skip15:
	ld	xde, 6356992	; F61528  ld XDE,0x00610000
	xor	xwa, xwa	; F6152D  xor XWA,XWA
	xor	xix, xix	; F6152F  xor XIX,XIX
	ld	a, (S0ngC0py_ToSong:16)	; F61531  ld A,(0x0e0d)
	dec	1, a	; F61535  dec 1,A
	ld	xix, xwa	; F61537  ld XIX,XWA
	sla	xwa, 11	; F61539  sla 0x0b,XWA
	sla	xix, 10	; F6153C  sla 0x0a,XIX
	add	xwa, xix	; F6153F  add XWA,XIX
	add	xde, xwa	; F61541  add XDE,XWA
	add	xde, 30	; F61543  add XDE,0x0000001e
	ld	c, (S0ngC0py_ToTrack:16)	; F61549  ld C,(0x0e0f)
	dec	1, c	; F6154D  dec 1,C
	ld	a, c	; F6154F  ld A,C
	ld	hl, (xde)	; F61551  ld HL,(XDE)
	cp	a, 16	; F61553  cp A,0x10
	jr	lt, sub_F610E3_Skip16	; F61556  jr LT,0xf6155e
	ld	hl, (xde+2)	; F61558  ld HL,(XDE+0x02)
	sub	a, 16	; F6155B  sub A,0x10
sub_F610E3_Skip16:
	scf	; F6155E  scf
	stcf_a_16	hl	; F6155F  stcf A,HL
	cp	c, 16	; F61561  cp C,0x10
	jr	lt, sub_F610E3_Skip17	; F61564  jr LT,0xf6156b
	ld	(xde+2), hl	; F61566  ld (XDE+0x02),HL
	jr	sub_F610E3_Join4	; F61569  jr T,0xf6156d
sub_F610E3_Skip17:
	ld	(xde), hl	; F6156B  ld (XDE),HL
sub_F610E3_Join4:
	ld	a, (S0ngC0py_ToSong:16)	; F6156D  ld A,(0x0e0d)
	dec	1, a	; F61571  dec 1,A
	cp	a, (BStore_CurrentBank:16)	; F61573  cp A,(0x360a)
	jr	nz, sub_F610E3_Return	; F61577  jr NZ,0xf615c1
	ld	a, c	; F61579  ld A,C
	ld	hl, (13836:16)	; F6157B  ld HL,(0x360c)
	cp	a, 16	; F6157F  cp A,0x10
	jr	lt, sub_F610E3_Skip18	; F61582  jr LT,0xf6158b
	ld	hl, (13838:16)	; F61584  ld HL,(0x360e)
	sub	a, 16	; F61588  sub A,0x10
sub_F610E3_Skip18:
	scf	; F6158B  scf
	stcf_a_16	hl	; F6158C  stcf A,HL
	cp	c, 16	; F6158E  cp C,0x10
	jr	lt, sub_F610E3_Skip19	; F61591  jr LT,0xf6159e
	ld	(13838:16), hl	; F61593  ld (0x360e),HL
	ld	(14162:16), 1	; F61597  ld (0x3752),0x01
	jr	sub_F610E3_Join5	; F6159C  jr T,0xf615a2
sub_F610E3_Skip19:
	ld	(13836:16), hl	; F6159E  ld (0x360c),HL
sub_F610E3_Join5:
	jr	sub_F610E3_Return	; F615A2  jr T,0xf615c1
sub_F610E3_Skip20:
	ld	a, (S0ngC0py_ToSong:16)	; F615A4  ld A,(0x0e0d)
	dec	1, a	; F615A8  dec 1,A
	ld	(3600:16), a	; F615AA  ld (0x0e10),A
	ld	a, (S0ngC0py_ToTrack:16)	; F615AE  ld A,(0x0e0f)
	dec	1, a	; F615B2  dec 1,A
	ld	(3609:16), a	; F615B4  ld (0x0e19),A
	call	S0ngC0py_ClearDestTrack	; F615B8  call 0xf61907
	ld	(UI_StatusCode:16), 15	; F615BC  ld (0x2880),0x0f
sub_F610E3_Return:
	ret	; F615C1  ret

; --------------------------------------------------------------------------
; S0ngC0py_CopyAllTracks
; Called from: in-module: 0xF611C9
; Touches: (0x0C70) (0x0E02) (0x0E0C) (0x0E0D) (0x126E) (0x2880) (0x345C)
;          (0x360A) (0x360C) (0x360E) +1 more  |  0x000005 0x000011 0x00001E
;          0x000022 0x00007E 0x0000A0 +7 more
; Calls:   S0ngC0py_AllocDestHeadBlock T_BStore_SeekBlock T_BStore_AllocBlock_Veneer BStore_EmptyBank
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF615C2 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; S0ngC0py_CopyAllTracks: SONG COPY with ALL: for each of the 17 tracks in use in FromSong (live directory if current
;   bank, else bank copy +0x100), starts the ToSong chain (S0ngC0py_AllocDestHeadBlock), duplicates it block by block
;   (251 bytes each) and stores its end cursor (+0x7E/+0xA0); then copies the track-to-part map (+0x22) and the +0x1E
;   long. Out of blocks: empties ToSong (BStore_EmptyBank) and UI_StatusCode = 15. Basis: caller + caller header +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave6_t.json)
S0ngC0py_CopyAllTracks:
	xor	a, a	; F615C2  xor A,A
	ld	(3184:16), a	; F615C4  ld (0x0c70),A
S0ngC0py_CopyAllTracks_Loop:
	cpw	(BStore_FreeCount:24), 0x0000	; F615C8  cp (0x6034ba),0x0000
	jrl	z, S0ngC0py_CopyAllTracks_Skip10	; F615CF  jrl Z,0xf61862
	ld	xde, 6356992	; F615D2  ld XDE,0x00610000
	push	xbc	; F615D7  push XBC
	xor	xbc, xbc	; F615D8  xor XBC,XBC
	xor	xwa, xwa	; F615DA  xor XWA,XWA
	ld	a, (S0ngC0py_FromSong:16)	; F615DC  ld A,(0x0e0c)
	dec	1, a	; F615E0  dec 1,A
	ld	c, a	; F615E2  ld C,A
	sla	xwa, 11	; F615E4  sla 0x0b,XWA
	sla	xbc, 10	; F615E7  sla 0x0a,XBC
	add	xwa, xbc	; F615EA  add XWA,XBC
	pop	xbc	; F615EC  pop XBC
	add	xde, xwa	; F615ED  add XDE,XWA
	ld	xwa, 256	; F615EF  ld XWA,0x00000100
	add	xde, xwa	; F615F4  add XDE,XWA
	ld	a, (S0ngC0py_FromSong:16)	; F615F6  ld A,(0x0e0c)
	dec	1, a	; F615FA  dec 1,A
	cp	a, (BStore_CurrentBank:16)	; F615FC  cp A,(0x360a)
	jr	nz, S0ngC0py_CopyAllTracks_Skip	; F61600  jr NZ,0xf61607
	ld	xde, 6305024	; F61602  ld XDE,0x00603500
S0ngC0py_CopyAllTracks_Skip:
	xor	xwa, xwa	; F61607  xor XWA,XWA
	ld	a, (3184:16)	; F61609  ld A,(0x0c70)
	ld	w, a	; F6160D  ld W,A
	sla	w, 1	; F6160F  sla 0x01,W
	add	a, w	; F61612  add A,W
	xor	w, w	; F61614  xor W,W
	bit	7, (xde+wa)	; F61616  bit 7,(XDE+WA)
	jrl	z, S0ngC0py_CopyAllTracks_Skip5	; F6161B  jrl Z,0xf6175f
	inc	1, wa	; F6161E  inc 1,WA
	ld	hl, (xde+wa)	; F61620  ld HL,(XDE+WA)
	cp	hl, 0:i3	; F61625  cp HL,0
	jrl	z, S0ngC0py_CopyAllTracks_Skip5	; F61627  jrl Z,0xf6175f
	cp	hl, 65535	; F6162A  cp HL,0xffff
	jrl	z, S0ngC0py_CopyAllTracks_Skip5	; F6162E  jrl Z,0xf6175f
	pushw	hl	; F61631  push HL
	call	S0ngC0py_AllocDestHeadBlock	; F61632  call 0xf61880
	ld	xix, (BStore_CursorBlockAddr:16)	; F61636  ld XIX,(0x126e)
	popw	hl	; F6163A  pop HL
	call	T_BStore_SeekBlock	; F6163B  call 0xf427bc
	ld	xiy, (BStore_CursorBlockAddr:16)	; F6163F  ld XIY,(0x126e)
	ldw	bc, 251	; F61643  ld BC,0x00fb
	inc	5, xix	; F61646  inc 5,XIX
	inc	5, xiy	; F61648  inc 5,XIY
	ldir85	; F6164A  ldir
S0ngC0py_CopyAllTracks_Join:
	sub	xiy, 256	; F6164C  sub XIY,0x00000100
	ld	hl, (xiy+3)	; F61652  ld HL,(XIY+0x03)
	cp	hl, 65535	; F61655  cp HL,0xffff
	jr	z, S0ngC0py_CopyAllTracks_Skip2	; F61659  jr Z,0xf616b4
	call	T_BStore_SeekBlock	; F6165B  call 0xf427bc
	ld	xiy, (BStore_CursorBlockAddr:16)	; F6165F  ld XIY,(0x126e)
	cpw	(BStore_FreeCount:24), 0x0000	; F61663  cp (0x6034ba),0x0000
	jrl	z, S0ngC0py_CopyAllTracks_Skip10	; F6166A  jrl Z,0xf61862
	push	xiy	; F6166D  push XIY
	call	T_BStore_AllocBlock_Veneer	; F6166E  call 0xf42884
	pop	xiy	; F61672  pop XIY
	ld	hl, (BStore_CursorBlock:16)	; F61673  ld HL,(0x345c)
	call	T_BStore_SeekBlock	; F61677  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F6167B  ld XHL,(0x126e)
	ld	(xhl+3), ix	; F6167F  ld (XHL+0x03),IX
	ld	hl, ix	; F61682  ld HL,IX
	call	T_BStore_SeekBlock	; F61684  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F61688  ld XHL,(0x126e)
	or	(xhl), 0x80	; F6168C  or (XHL),0x80
	ld	wa, (BStore_CursorBlock:16)	; F6168F  ld WA,(0x345c)
	ld	(xhl+1), wa	; F61693  ld (XHL+0x01),WA
	ldw	(xhl+3), 0xffff	; F61696  ld (XHL+0x03),0xffff
	ld	(BStore_CursorBlock:16), ix	; F6169B  ld (0x345c),IX
	ld	xix, xhl	; F6169F  ld XIX,XHL
	add	xix, 5	; F616A1  add XIX,0x00000005
	add	xiy, 5	; F616A7  add XIY,0x00000005
	ldw	bc, 251	; F616AD  ld BC,0x00fb
	ldir85	; F616B0  ldir
	jr	S0ngC0py_CopyAllTracks_Join	; F616B2  jr T,0xf6164c
S0ngC0py_CopyAllTracks_Skip2:
	ld	xde, 6356992	; F616B4  ld XDE,0x00610000
	push	xbc	; F616B9  push XBC
	xor	xbc, xbc	; F616BA  xor XBC,XBC
	xor	xwa, xwa	; F616BC  xor XWA,XWA
	ld	a, (S0ngC0py_ToSong:16)	; F616BE  ld A,(0x0e0d)
	dec	1, a	; F616C2  dec 1,A
	ld	c, a	; F616C4  ld C,A
	sla	xwa, 11	; F616C6  sla 0x0b,XWA
	sla	xbc, 10	; F616C9  sla 0x0a,XBC
	add	xwa, xbc	; F616CC  add XWA,XBC
	pop	xbc	; F616CE  pop XBC
	add	xde, xwa	; F616CF  add XDE,XWA
	ld	xhl, 126	; F616D1  ld XHL,0x0000007e
	add	xhl, xde	; F616D6  add XHL,XDE
	xor	wa, wa	; F616D8  xor WA,WA
	ld	a, (3184:16)	; F616DA  ld A,(0x0c70)
	sla	a, 1	; F616DE  sla 0x01,A
	ld	ix, (BStore_CursorBlock:16)	; F616E1  ld IX,(0x345c)
	ld	(xhl+wa), ix	; F616E5  ld (XHL+WA),IX
	ld	b, (S0ngC0py_ToSong:16)	; F616EA  ld B,(0x0e0d)
	dec	1, b	; F616EE  dec 1,B
	cp	b, (BStore_CurrentBank:16)	; F616F0  cp B,(0x360a)
	jr	nz, S0ngC0py_CopyAllTracks_Skip3	; F616F4  jr NZ,0xf61700
	ld	xhl, 6304894	; F616F6  ld XHL,0x0060347e
	ld	(xhl+wa), ix	; F616FB  ld (XHL+WA),IX
S0ngC0py_CopyAllTracks_Skip3:
	ld	xhl, 6356992	; F61700  ld XHL,0x00610000
	push	xwa	; F61705  push XWA
	xor	xwa, xwa	; F61706  xor XWA,XWA
	xor	xbc, xbc	; F61708  xor XBC,XBC
	ld	c, (S0ngC0py_FromSong:16)	; F6170A  ld C,(0x0e0c)
	dec	1, c	; F6170E  dec 1,C
	ld	a, c	; F61710  ld A,C
	sla	xbc, 11	; F61712  sla 0x0b,XBC
	sla	xwa, 10	; F61715  sla 0x0a,XWA
	add	xbc, xwa	; F61718  add XBC,XWA
	pop	xwa	; F6171A  pop XWA
	add	xhl, xbc	; F6171B  add XHL,XBC
	ld	xbc, 160	; F6171D  ld XBC,0x000000a0
	add	xhl, xbc	; F61722  add XHL,XBC
	ld	c, (S0ngC0py_FromSong:16)	; F61724  ld C,(0x0e0c)
	dec	1, c	; F61728  dec 1,C
	cp	c, (BStore_CurrentBank:16)	; F6172A  cp C,(0x360a)
	jr	nz, S0ngC0py_CopyAllTracks_Skip4	; F6172E  jr NZ,0xf61735
	ld	xhl, 6304928	; F61730  ld XHL,0x006034a0
S0ngC0py_CopyAllTracks_Skip4:
	sra	a, 1	; F61735  sra 0x01,A
	ld	c, (xhl+wa)	; F61738  ld C,(XHL+WA)
	ld	xhl, 160	; F6173D  ld XHL,0x000000a0
	add	xhl, xde	; F61742  add XHL,XDE
	ld	(xhl+wa), c	; F61744  ld (XHL+WA),C
	ld	b, (S0ngC0py_ToSong:16)	; F61749  ld B,(0x0e0d)
	dec	1, b	; F6174D  dec 1,B
	cp	b, (BStore_CurrentBank:16)	; F6174F  cp B,(0x360a)
	jr	nz, S0ngC0py_CopyAllTracks_Skip5	; F61753  jr NZ,0xf6175f
	ld	xhl, 6304928	; F61755  ld XHL,0x006034a0
	ld	(xhl+wa), c	; F6175A  ld (XHL+WA),C
S0ngC0py_CopyAllTracks_Skip5:
	inc	1, (3184:16)	; F6175F  inc 1,(0x0c70)
	cp	(0x0c70:16), 0x11	; F61763  cp (0x0c70),0x11
	jrl	c, S0ngC0py_CopyAllTracks_Loop	; F61768  jrl C,0xf615c8
	ld	xde, 6356992	; F6176B  ld XDE,0x00610000
	push	xbc	; F61770  push XBC
	xor	xbc, xbc	; F61771  xor XBC,XBC
	xor	xwa, xwa	; F61773  xor XWA,XWA
	ld	a, (S0ngC0py_FromSong:16)	; F61775  ld A,(0x0e0c)
	dec	1, a	; F61779  dec 1,A
	ld	xiy, xwa	; F6177B  ld XIY,XWA
	ld	c, a	; F6177D  ld C,A
	sla	xiy, 11	; F6177F  sla 0x0b,XIY
	sla	xbc, 10	; F61782  sla 0x0a,XBC
	add	xiy, xbc	; F61785  add XIY,XBC
	pop	xbc	; F61787  pop XBC
	add	xiy, xde	; F61788  add XIY,XDE
	add	xiy, 34	; F6178A  add XIY,0x00000022
	ld	a, (S0ngC0py_FromSong:16)	; F61790  ld A,(0x0e0c)
	dec	1, a	; F61794  dec 1,A
	cp	a, (BStore_CurrentBank:16)	; F61796  cp A,(0x360a)
	jr	nz, S0ngC0py_CopyAllTracks_Skip6	; F6179A  jr NZ,0xf617a1
	ld	xiy, BStore_TrackToPart	; F6179C  ld XIY,0x00603422
S0ngC0py_CopyAllTracks_Skip6:
	push	xbc	; F617A1  push XBC
	xor	xbc, xbc	; F617A2  xor XBC,XBC
	xor	xwa, xwa	; F617A4  xor XWA,XWA
	ld	a, (S0ngC0py_ToSong:16)	; F617A6  ld A,(0x0e0d)
	dec	1, a	; F617AA  dec 1,A
	ld	xix, xwa	; F617AC  ld XIX,XWA
	ld	c, a	; F617AE  ld C,A
	sla	xix, 11	; F617B0  sla 0x0b,XIX
	sla	xbc, 10	; F617B3  sla 0x0a,XBC
	add	xix, xbc	; F617B6  add XIX,XBC
	pop	xbc	; F617B8  pop XBC
	add	xix, xde	; F617B9  add XIX,XDE
	add	xix, 34	; F617BB  add XIX,0x00000022
	ldw	bc, 17	; F617C1  ld BC,0x0011
	ldir85	; F617C4  ldir
	ld	a, (S0ngC0py_ToSong:16)	; F617C6  ld A,(0x0e0d)
	dec	1, a	; F617CA  dec 1,A
	cp	a, (BStore_CurrentBank:16)	; F617CC  cp A,(0x360a)
	jr	nz, S0ngC0py_CopyAllTracks_Skip7	; F617D0  jr NZ,0xf617e2
	sub	xiy, 17	; F617D2  sub XIY,0x00000011
	ld	xix, BStore_TrackToPart	; F617D8  ld XIX,0x00603422
	ldw	bc, 17	; F617DD  ld BC,0x0011
	ldir85	; F617E0  ldir
S0ngC0py_CopyAllTracks_Skip7:
	ld	xde, 6356992	; F617E2  ld XDE,0x00610000
	push	xbc	; F617E7  push XBC
	xor	xbc, xbc	; F617E8  xor XBC,XBC
	xor	xwa, xwa	; F617EA  xor XWA,XWA
	ld	a, (S0ngC0py_FromSong:16)	; F617EC  ld A,(0x0e0c)
	dec	1, a	; F617F0  dec 1,A
	ld	xiy, xwa	; F617F2  ld XIY,XWA
	ld	c, a	; F617F4  ld C,A
	sla	xiy, 11	; F617F6  sla 0x0b,XIY
	sla	xbc, 10	; F617F9  sla 0x0a,XBC
	add	xiy, xbc	; F617FC  add XIY,XBC
	pop	xbc	; F617FE  pop XBC
	add	xiy, xde	; F617FF  add XIY,XDE
	add	xiy, 30	; F61801  add XIY,0x0000001e
	ld	c, (S0ngC0py_FromSong:16)	; F61807  ld C,(0x0e0c)
	dec	1, c	; F6180B  dec 1,C
	cp	c, (BStore_CurrentBank:16)	; F6180D  cp C,(0x360a)
	jr	nz, S0ngC0py_CopyAllTracks_Skip8	; F61811  jr NZ,0xf61818
	ld	xiy, 13836	; F61813  ld XIY,0x0000360c
S0ngC0py_CopyAllTracks_Skip8:
	ld	c, (S0ngC0py_ToSong:16)	; F61818  ld C,(0x0e0d)
	dec	1, c	; F6181C  dec 1,C
	cp	c, (BStore_CurrentBank:16)	; F6181E  cp C,(0x360a)
	jr	nz, S0ngC0py_CopyAllTracks_Skip9	; F61822  jr NZ,0xf6183c
	ld	xwa, (xiy)	; F61824  ld XWA,(XIY)
	ld	(13836:16), xwa	; F61826  ld (0x360c),XWA
	ld	(14162:16), 0	; F6182A  ld (0x3752),0x00
	bit	0, (0x360e:16)	; F6182F  bit 0,(0x360e)
	jr	z, S0ngC0py_CopyAllTracks_Return	; F61833  jr Z,0xf6187f
	ld	(14162:16), 1	; F61835  ld (0x3752),0x01
	jr	S0ngC0py_CopyAllTracks_Return	; F6183A  jr T,0xf6187f
S0ngC0py_CopyAllTracks_Skip9:
	push	xbc	; F6183C  push XBC
	xor	xbc, xbc	; F6183D  xor XBC,XBC
	xor	xwa, xwa	; F6183F  xor XWA,XWA
	ld	a, (S0ngC0py_ToSong:16)	; F61841  ld A,(0x0e0d)
	dec	1, a	; F61845  dec 1,A
	ld	xix, xwa	; F61847  ld XIX,XWA
	ld	c, a	; F61849  ld C,A
	sla	xix, 11	; F6184B  sla 0x0b,XIX
	sla	xbc, 10	; F6184E  sla 0x0a,XBC
	add	xix, xbc	; F61851  add XIX,XBC
	pop	xbc	; F61853  pop XBC
	add	xix, xde	; F61854  add XIX,XDE
	add	xix, 30	; F61856  add XIX,0x0000001e
	ld	xwa, (xiy)	; F6185C  ld XWA,(XIY)
	ld	(xix), xwa	; F6185E  ld (XIX),XWA
	jr	S0ngC0py_CopyAllTracks_Return	; F61860  jr T,0xf6187f
S0ngC0py_CopyAllTracks_Skip10:
	ld	a, (3586:16)	; F61862  ld A,(0x0e02)
	pushw	wa	; F61866  push WA
	ld	a, (S0ngC0py_ToSong:16)	; F61867  ld A,(0x0e0d)
	dec	1, a	; F6186B  dec 1,A
	ld	(3586:16), a	; F6186D  ld (0x0e02),A
	call	BStore_EmptyBank	; F61871  call 0xf60f4f
	popw	wa	; F61875  pop WA
	ld	(3586:16), a	; F61876  ld (0x0e02),A
	ld	(UI_StatusCode:16), 15	; F6187A  ld (0x2880),0x0f
S0ngC0py_CopyAllTracks_Return:
	ret	; F6187F  ret

; --------------------------------------------------------------------------
; S0ngC0py_AllocDestHeadBlock
; Called from: in-module: 0xF6136C 0xF61632
; Touches: (0x0C70) (0x0E0D) (0x126E) (0x345C) (0x360A)  |  0x000100
;          0x603500 0x610000
; Calls:   T_BStore_AllocBlock_Veneer T_BStore_SeekBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF61880 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; S0ngC0py_AllocDestHeadBlock: When a block is free: allocates one (BStore_AllocBlock), marks it in use with PREVIOUS
;   0 and NEXT 0xFFFF, (0x345C) := it, and makes it the head of directory entry (0x0C70) (0-based) in ToSong's bank
;   copy, and in the live directory when ToSong is the current bank. S0ngC0py_Execute (single track, (0x0C70) =
;   ToTrack-1) and S0ngC0py_CopyAllTracks call it before duplicating a chain. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_t.json)
S0ngC0py_AllocDestHeadBlock:
	cpw	(BStore_FreeCount:24), 0x0000	; F61880  cp (0x6034ba),0x0000
	jr	z, S0ngC0py_AllocDestHeadBlock_Return	; F61887  jr Z,0xf61906
	call	T_BStore_AllocBlock_Veneer	; F61889  call 0xf42884
	ld	(BStore_CursorBlock:16), ix	; F6188D  ld (0x345c),IX
	ld	hl, ix	; F61891  ld HL,IX
	call	T_BStore_SeekBlock	; F61893  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F61897  ld XHL,(0x126e)
	or	(xhl), 0x80	; F6189B  or (XHL),0x80
	ldw	(xhl+1), 0x0000	; F6189E  ld (XHL+0x01),0x0000
	ldw	(xhl+3), 0xffff	; F618A3  ld (XHL+0x03),0xffff
	ld	xde, 6356992	; F618A8  ld XDE,0x00610000
	push	xbc	; F618AD  push XBC
	xor	xbc, xbc	; F618AE  xor XBC,XBC
	xor	xwa, xwa	; F618B0  xor XWA,XWA
	ld	a, (S0ngC0py_ToSong:16)	; F618B2  ld A,(0x0e0d)
	dec	1, a	; F618B6  dec 1,A
	ld	c, a	; F618B8  ld C,A
	sla	xwa, 11	; F618BA  sla 0x0b,XWA
	sla	xbc, 10	; F618BD  sla 0x0a,XBC
	add	xwa, xbc	; F618C0  add XWA,XBC
	pop	xbc	; F618C2  pop XBC
	add	xde, xwa	; F618C3  add XDE,XWA
	ld	xwa, 256	; F618C5  ld XWA,0x00000100
	add	xde, xwa	; F618CA  add XDE,XWA
	xor	xwa, xwa	; F618CC  xor XWA,XWA
	ld	a, (3184:16)	; F618CE  ld A,(0x0c70)
	ld	w, a	; F618D2  ld W,A
	sla	w, 1	; F618D4  sla 0x01,W
	add	a, w	; F618D7  add A,W
	xor	w, w	; F618D9  xor W,W
	or	(xde+wa), 0x80	; F618DB  or (XDE+WA),0x80
	inc	1, wa	; F618E1  inc 1,WA
	ld	(xde+wa), ix	; F618E3  ld (XDE+WA),IX
	ld	c, (S0ngC0py_ToSong:16)	; F618E8  ld C,(0x0e0d)
	dec	1, c	; F618EC  dec 1,C
	cp	c, (BStore_CurrentBank:16)	; F618EE  cp C,(0x360a)
	jr	nz, S0ngC0py_AllocDestHeadBlock_Return	; F618F2  jr NZ,0xf61906
	ld	xde, 6305024	; F618F4  ld XDE,0x00603500
	ld	(xde+wa), ix	; F618F9  ld (XDE+WA),IX
	dec	1, wa	; F618FE  dec 1,WA
	or	(xde+wa), 0x80	; F61900  or (XDE+WA),0x80
S0ngC0py_AllocDestHeadBlock_Return:
	ret	; F61906  ret

; --------------------------------------------------------------------------
; S0ngC0py_ClearDestTrack
; Called from: in-module: 0xF612FC 0xF615B8
; Touches: (0x0CA4) (0x0E10) (0x0E19) (0x360A)  |  0x000022 0x00007E
;          0x000100 0x003460 0x60347E 0x603500 +1 more
; Calls:   T_BStore_FreeChain_Veneer
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF61907 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; S0ngC0py_ClearDestTrack: Clears track (0x0E19)+1 of song bank (0x0E10): frees its chain (BStore_FreeChain) and
;   empties its directory entry (the live one for BStore_CurrentBank, else the bank copy's), resets its saved cursor
;   in the bank copy (and live). S0ngC0py_Execute's two callers set (0x0E10) := ToSong-1, (0x0E19) := ToTrack-1:
;   before a track copy and after running out of blocks. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_q.json)
S0ngC0py_ClearDestTrack:
	push	xwa	; F61907  push XWA
	push	xhl	; F61908  push XHL
	push	xbc	; F61909  push XBC
	push	xde	; F6190A  push XDE
	push	xiy	; F6190B  push XIY
	ld	xde, 6356992	; F6190C  ld XDE,0x00610000
	push	xbc	; F61911  push XBC
	xor	xbc, xbc	; F61912  xor XBC,XBC
	xor	xhl, xhl	; F61914  xor XHL,XHL
	ld	l, (3600:16)	; F61916  ld L,(0x0e10)
	ld	c, l	; F6191A  ld C,L
	sla	xhl, 11	; F6191C  sla 0x0b,XHL
	sla	xbc, 10	; F6191F  sla 0x0a,XBC
	add	xhl, xbc	; F61922  add XHL,XBC
	pop	xbc	; F61924  pop XBC
	add	xde, xhl	; F61925  add XDE,XHL
	ld	xhl, 256	; F61927  ld XHL,0x00000100
	add	xhl, xde	; F6192C  add XHL,XDE
	ld	c, (3600:16)	; F6192E  ld C,(0x0e10)
	cp	c, (BStore_CurrentBank:16)	; F61932  cp C,(0x360a)
	jr	nz, S0ngC0py_ClearDestTrack_Skip	; F61936  jr NZ,0xf6193d
	ld	xhl, 6305024	; F61938  ld XHL,0x00603500
S0ngC0py_ClearDestTrack_Skip:
	ld	c, (3609:16)	; F6193D  ld C,(0x0e19)
	ld	b, c	; F61941  ld B,C
	sla	b, 1	; F61943  sla 0x01,B
	add	c, b	; F61946  add C,B
	xor	b, b	; F61948  xor B,B
	bit	7, (xhl+bc)	; F6194A  bit 7,(XHL+BC)
	jrl	z, S0ngC0py_ClearDestTrack_Epilogue	; F6194F  jrl Z,0xf61a10
	inc	1, bc	; F61952  inc 1,BC
	ld	wa, (xhl+bc)	; F61954  ld WA,(XHL+BC)
	cp	wa, 0:i3	; F61959  cp WA,0
	jrl	z, S0ngC0py_ClearDestTrack_Epilogue	; F6195B  jrl Z,0xf61a10
	cp	wa, 65535	; F6195E  cp WA,0xffff
	jrl	z, S0ngC0py_ClearDestTrack_Epilogue	; F61962  jrl Z,0xf61a10
	ld	iy, wa	; F61965  ld IY,WA
	ld	wa, (BStore_BlockLimit:16)	; F61967  ld WA,(0x0ca4)
	push	xhl	; F6196B  push XHL
	push	xbc	; F6196C  push XBC
	push	xde	; F6196D  push XDE
	call	T_BStore_FreeChain_Veneer	; F6196E  call 0xf42888
	pop	xde	; F61972  pop XDE
	pop	xbc	; F61973  pop XBC
	pop	xhl	; F61974  pop XHL
	ldw	(xhl+bc), 0xffff	; F61975  ld (XHL+BC),0xffff
	dec	1, bc	; F6197C  dec 1,BC
	ld	(xhl+bc), 0x00	; F6197E  ld (XHL+BC),0x00
	ld	a, (3600:16)	; F61984  ld A,(0x0e10)
	cp	a, (BStore_CurrentBank:16)	; F61988  cp A,(0x360a)
	jr	nz, S0ngC0py_ClearDestTrack_Skip2	; F6198C  jr NZ,0xf619a2
	ld	xhl, 6305024	; F6198E  ld XHL,0x00603500
	ld	(xhl+bc), 0x00	; F61993  ld (XHL+BC),0x00
	inc	1, bc	; F61999  inc 1,BC
	ldw	(xhl+bc), 0xffff	; F6199B  ld (XHL+BC),0xffff
S0ngC0py_ClearDestTrack_Skip2:
	ld	xhl, 126	; F619A2  ld XHL,0x0000007e
	add	xhl, xde	; F619A7  add XHL,XDE
	xor	bc, bc	; F619A9  xor BC,BC
	ld	c, (3609:16)	; F619AB  ld C,(0x0e19)
	sla	bc, 1	; F619AF  sla 0x01,BC
	ldw	(xhl+bc), 0xffff	; F619B2  ld (XHL+BC),0xffff
	sra	bc, 1	; F619B9  sra 0x01,BC
	add	xhl, 34	; F619BC  add XHL,0x00000022
	ld	(xhl+bc), 0x05	; F619C2  ld (XHL+BC),0x05
	cp	a, (BStore_CurrentBank:16)	; F619C8  cp A,(0x360a)
	jr	nz, S0ngC0py_ClearDestTrack_Skip3	; F619CC  jr NZ,0xf619ec
	ld	xhl, 6304894	; F619CE  ld XHL,0x0060347e
	sla	bc, 1	; F619D3  sla 0x01,BC
	ldw	(xhl+bc), 0xffff	; F619D6  ld (XHL+BC),0xffff
	sra	bc, 1	; F619DD  sra 0x01,BC
	add	xhl, 34	; F619E0  add XHL,0x00000022
	ld	(xhl+bc), 0x05	; F619E6  ld (XHL+BC),0x05
S0ngC0py_ClearDestTrack_Skip3:
	cp	a, (BStore_CurrentBank:16)	; F619EC  cp A,(0x360a)
	jr	nz, S0ngC0py_ClearDestTrack_Epilogue	; F619F0  jr NZ,0xf61a10
	ld	xhl, 13408	; F619F2  ld XHL,0x00003460
	sla	bc, 1	; F619F7  sla 0x01,BC
	ldw	(xhl+bc), 0xffff	; F619FA  ld (XHL+BC),0xffff
	sra	bc, 1	; F61A01  sra 0x01,BC
	add	xhl, 34	; F61A04  add XHL,0x00000022
	ld	(xhl+bc), 0x05	; F61A0A  ld (XHL+BC),0x05
S0ngC0py_ClearDestTrack_Epilogue:
	pop	xiy	; F61A10  pop XIY
	pop	xde	; F61A11  pop XDE
	pop	xbc	; F61A12  pop XBC
	pop	xhl	; F61A13  pop XHL
	pop	xwa	; F61A14  pop XWA
	ret	; F61A15  ret

; --------------------------------------------------------------------------
; AdvanceDelay_Execute
; Called from: T_AdvanceDelay_Execute (x1)
; Touches: (0x0C70) (0x0C73) (0x0C77) (0x0C8A) (0x0C8E) (0x0CA3) (0x0D18)
;          (0x0D4A)  |  0x603422
; Calls:   T_BStore_LoadGeometry AdvanceDelay_ApplyToTrack T_BStore_ErrorToStatusByte T_F40A1C
; Evidence: thunk slot T_AdvanceDelay_Execute holds `jp 0x00F61A16`, and 0xF61A16 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; AdvanceDelay_Execute: The ADVANCE/DELAY job (AdvanceDelay_LcdKeyRow3 stages track (0x0DE6), measure (0x0DE8), count
;   (0x0E06) and calls T_AdvanceDelay_Execute): track 1..(0x0CA3) or 17 = all, measures 1..999 (error 3), master part 0x20 error 9;
;   per track AdvanceDelay_ApplyToTrack adds the signed tick offset (0x0DEC) to each event's timing byte. Ends with
;   BStore_ErrorToStatusByte. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave5_q.json)
AdvanceDelay_Execute:		; <- T_AdvanceDelay_Execute
	call	T_BStore_LoadGeometry	; F61A16  call 0xf427c4
	ld	(BStore_ErrorCode:16), 0	; F61A1A  ld (0x0d4a),0x00
	ld	a, (3184:16)	; F61A1F  ld A,(0x0c70)
	cp	a, 1:i3	; F61A23  cp A,1
	jr	c, AdvanceDelay_Execute_Skip5	; F61A25  jr C,0xf61a50
	cp	a, 17	; F61A27  cp A,0x11
	jr	z, AdvanceDelay_Execute_Skip4	; F61A2A  jr Z,0xf61a32
	cp	a, (0x0ca3:16)	; F61A2C  cp A,(0x0ca3)
	jr	ugt, AdvanceDelay_Execute_Skip5	; F61A30  jr UGT,0xf61a50
AdvanceDelay_Execute_Skip4:
	ld	wa, (3187:16)	; F61A32  ld WA,(0x0c73)
	cp	wa, 1:i3	; F61A36  cp WA,1
	jr	c, AdvanceDelay_Execute_Skip5	; F61A38  jr C,0xf61a50
	cp	wa, 999	; F61A3A  cp WA,0x03e7
	jr	ugt, AdvanceDelay_Execute_Skip5	; F61A3E  jr UGT,0xf61a50
	ld	wa, (3191:16)	; F61A40  ld WA,(0x0c77)
	cp	wa, 1:i3	; F61A44  cp WA,1
	jr	c, AdvanceDelay_Execute_Skip5	; F61A46  jr C,0xf61a50
	cp	wa, 999	; F61A48  cp WA,0x03e7
	jr	ugt, AdvanceDelay_Execute_Skip5	; F61A4C  jr UGT,0xf61a50
	jr	AdvanceDelay_Execute_Join	; F61A4E  jr T,0xf61a58
AdvanceDelay_Execute_Skip5:
	ld	(BStore_ErrorCode:16), 3	; F61A50  ld (0x0d4a),0x03
	jrl	AdvanceDelay_Execute_Join3	; F61A55  jrl T,0xf61aee
AdvanceDelay_Execute_Join:
	ld	(BStore_ErrorCode:16), 0	; F61A58  ld (0x0d4a),0x00
	and	(0x0c8a:16), 0xbf	; F61A5D  and (0x0c8a),0xbf
	cp	(0x0c70:16), 0x11	; F61A62  cp (0x0c70),0x11
	jr	z, AdvanceDelay_Execute_Skip7	; F61A67  jr Z,0xf61a99
	xor	hl, hl	; F61A69  xor HL,HL
	ld	l, (3184:16)	; F61A6B  ld L,(0x0c70)
	dec	1, l	; F61A6F  dec 1,L
	push	xix	; F61A71  push XIX
	ld	xix, BStore_TrackToPart	; F61A72  ld XIX,0x00603422
	ld	a, (xix+hl)	; F61A77  ld A,(XIX+HL)
	pop	xix	; F61A7C  pop XIX
	cp	a, 32	; F61A7D  cp A,0x20
	jr	z, AdvanceDelay_Execute_Skip6	; F61A80  jr Z,0xf61a91
	ld	a, (3184:16)	; F61A82  ld A,(0x0c70)
	ld	(3214:16), a	; F61A86  ld (0x0c8e),A
	call	AdvanceDelay_ApplyToTrack	; F61A8A  call 0xf61af7
	jrl	AdvanceDelay_Execute_Join3	; F61A8E  jrl T,0xf61aee
AdvanceDelay_Execute_Skip6:
	ld	(BStore_ErrorCode:16), 9	; F61A91  ld (0x0d4a),0x09
	jrl	AdvanceDelay_Execute_Join3	; F61A96  jrl T,0xf61aee
AdvanceDelay_Execute_Skip7:
	xor	xhl, xhl	; F61A99  xor XHL,XHL
AdvanceDelay_Execute_Join2:
	cp	l, (0x0ca3:16)	; F61A9B  cp L,(0x0ca3)
	jrl	ugt, AdvanceDelay_Execute_Skip10	; F61A9F  jrl UGT,0xf61ae6
	ld	h, l	; F61AA2  ld H,L
	inc	1, h	; F61AA4  inc 1,H
	ld	(3214:16), h	; F61AA6  ld (0x0c8e),H
	push	xhl	; F61AAA  push XHL
	push	xix	; F61AAB  push XIX
	xor	h, h	; F61AAC  xor H,H
	ld	xix, BStore_TrackToPart	; F61AAE  ld XIX,0x00603422
	ld	a, (xix+hl)	; F61AB3  ld A,(XIX+HL)
	pop	xix	; F61AB8  pop XIX
	pop	xhl	; F61AB9  pop XHL
	cp	a, 32	; F61ABA  cp A,0x20
	jr	z, AdvanceDelay_Execute_Skip8	; F61ABD  jr Z,0xf61ac5
	push	xhl	; F61ABF  push XHL
	call	AdvanceDelay_ApplyToTrack	; F61AC0  call 0xf61af7
	pop	xhl	; F61AC4  pop XHL
AdvanceDelay_Execute_Skip8:
	cp	(BStore_ErrorCode:16), 0x00	; F61AC5  cp (0x0d4a),0x00
	jr	z, AdvanceDelay_Execute_Skip9	; F61ACA  jr Z,0xf61ae2
	cp	(BStore_ErrorCode:16), 0x01	; F61ACC  cp (0x0d4a),0x01
	jr	z, AdvanceDelay_Execute_Skip9	; F61AD1  jr Z,0xf61ae2
	cp	(0x0d18:16), 0x00	; F61AD3  cp (0x0d18),0x00
	jr	nz, AdvanceDelay_Execute_Skip9	; F61AD8  jr NZ,0xf61ae2
	ld	a, (BStore_ErrorCode:16)	; F61ADA  ld A,(0x0d4a)
	ld	(3352:16), a	; F61ADE  ld (0x0d18),A
AdvanceDelay_Execute_Skip9:
	inc	1, l	; F61AE2  inc 1,L
	jr	AdvanceDelay_Execute_Join2	; F61AE4  jr T,0xf61a9b
AdvanceDelay_Execute_Skip10:
	ld	a, (3352:16)	; F61AE6  ld A,(0x0d18)
	ld	(BStore_ErrorCode:16), a	; F61AEA  ld (0x0d4a),A
AdvanceDelay_Execute_Join3:
	call	T_BStore_ErrorToStatusByte	; F61AEE  call 0xf4278c
	call	T_F40A1C	; F61AF2  call 0xf40a1c
	ret	; F61AF6  ret

; --------------------------------------------------------------------------
; AdvanceDelay_ApplyToTrack
; Called from: in-module: 0xF61A8A 0xF61AC0
; Touches: (0x0C73) (0x0C77) (0x0C8A) (0x0C8E) (0x0C90) (0x0D0A) (0x0D14)
;          (0x0D1C) (0x0D4A) (0x0DEC) +3 more
; Calls:   T_Seq_FindMasterTrack T_BStore_SeekMeasure AdvanceDelay_ClampTimingsAtTrackEnd T_BStore_CursorAdvance sub_F61C0C T_F427A8
;          sub_F62089 sub_F61FBA
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF61AF7 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; AdvanceDelay_ApplyToTrack: ADVANCE/DELAY on track (0x0C8E): seeks measure (0x0C73) and, for (0x0C77) measures, adds
;   the signed tick offset (0x0DEC) to the timing byte (+1) of every event (status bit 7, not 0x81/0x82), setting
;   (0x0C8A) bit 0 when a result leaves 0..0x5F; sub_F61C0C runs at each 0x81 beat mark and sub_F62089 / sub_F61FBA
;   (offset sign) at the end (not read here). Basis: caller + caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave6_t.json)
AdvanceDelay_ApplyToTrack:
	xor	wa, wa	; F61AF7  xor WA,WA
	xor	xhl, xhl	; F61AF9  xor XHL,XHL
	call	T_Seq_FindMasterTrack	; F61AFB  call 0xf427a0
	ld	a, (3214:16)	; F61AFF  ld A,(0x0c8e)
	ld	de, (3187:16)	; F61B03  ld DE,(0x0c73)
	ld	(3216:16), de	; F61B07  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F61B0B  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F61B0F  cp (0x0d4a),0x00
	jrl	nz, sub_F61AF7_Join3	; F61B14  jrl NZ,0xf61bf4
	xor	de, de	; F61B17  xor DE,DE
AdvanceDelay_ApplyToTrack_Loop:
	cp	de, (0x0c77:16)	; F61B19  cp DE,(0x0c77)
	jrl	z, sub_F61AF7_Join3	; F61B1D  jrl Z,0xf61bf4
	xor	bc, bc	; F61B20  xor BC,BC
AdvanceDelay_ApplyToTrack_Join:
	xor	wa, wa	; F61B22  xor WA,WA
	ld	(3611:16), a	; F61B24  ld (0x0e1b),A
	ld	(3613:16), a	; F61B28  ld (0x0e1d),A
	and	(0x0c8a:16), 0xfe	; F61B2C  and (0x0c8a),0xfe
	ld	(3338:16), iy	; F61B31  ld (0x0d0a),IY
	push	xhl	; F61B35  push XHL
	ld	xhl, (BStore_CursorBlockAddr:16)	; F61B36  ld XHL,(0x126e)
	ld	(3348:16), xhl	; F61B3A  ld (0x0d14),XHL
	pop	xhl	; F61B3E  pop XHL
	cp	c, (0x0d1c:16)	; F61B3F  cp C,(0x0d1c)
	jrl	z, sub_F61AF7_Skip4	; F61B43  jrl Z,0xf61bc6
AdvanceDelay_ApplyToTrack_Join2:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F61B46  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F61B4A  ld A,(XHL+IY)
	cp	a, 130	; F61B4F  cp A,0x82
	jr	nz, AdvanceDelay_ApplyToTrack_Skip	; F61B52  jr NZ,0xf61b5a
	calr	AdvanceDelay_ClampTimingsAtTrackEnd	; F61B54  calr 0xf620af
	jrl	sub_F61AF7_Join3	; F61B57  jrl T,0xf61bf4
AdvanceDelay_ApplyToTrack_Skip:
	cp	a, 129	; F61B5A  cp A,0x81
	jr	z, sub_F61AF7_Entry	; F61B5D  jr Z,0xf61ba6
	bit	7, a	; F61B5F  bit 0x07,A
	jr	z, AdvanceDelay_ApplyToTrack_Skip3	; F61B62  jr Z,0xf61b99
	call	T_BStore_CursorAdvance	; F61B64  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F61B68  cp (0x0d4a),0x00
	jrl	nz, sub_F61AF7_Join3	; F61B6D  jrl NZ,0xf61bf4
	ld	xhl, (BStore_CursorBlockAddr:16)	; F61B70  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F61B74  ld A,(XHL+IY)
	xor	w, w	; F61B79  xor W,W
	ld	l, (3564:16)	; F61B7B  ld L,(0x0dec)
	add	a, l	; F61B7F  add A,L
	ld	xhl, (BStore_CursorBlockAddr:16)	; F61B81  ld XHL,(0x126e)
	ld	(xhl+iy), a	; F61B85  ld (XHL+IY),A
	bit	7, a	; F61B8A  bit 0x07,A
	jr	nz, AdvanceDelay_ApplyToTrack_Skip2	; F61B8D  jr NZ,0xf61b94
	cp	a, 96	; F61B8F  cp A,0x60
	jr	c, AdvanceDelay_ApplyToTrack_Skip3	; F61B92  jr C,0xf61b99
AdvanceDelay_ApplyToTrack_Skip2:
	or	(0x0c8a:16), 0x01	; F61B94  or (0x0c8a),0x01
AdvanceDelay_ApplyToTrack_Skip3:
	call	T_BStore_CursorAdvance	; F61B99  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F61B9D  cp (0x0d4a),0x00
	jr	nz, sub_F61AF7_Join3	; F61BA2  jr NZ,0xf61bf4
	jr	AdvanceDelay_ApplyToTrack_Join2	; F61BA4  jr T,0xf61b46
sub_F61AF7_Entry:
	ldfr_werp	bc, 0x34	; F61BA6  ld RBC3,BC
	ldfr_werp	de, 0x38	; F61BA9  ld RDE3,DE
	push	xiy	; F61BAC  push XIY
	pushw	bc	; F61BAD  push BC
	pushw	de	; F61BAE  push DE
	call	sub_F61C0C	; F61BAF  call 0xf61c0c
	popw	de	; F61BB3  pop DE
	popw	bc	; F61BB4  pop BC
	pop	xiy	; F61BB5  pop XIY
	cp	(BStore_ErrorCode:16), 0x00	; F61BB6  cp (0x0d4a),0x00
	jr	nz, sub_F61AF7_Join3	; F61BBB  jr NZ,0xf61bf4
	inc	1, c	; F61BBD  inc 1,C
	call	T_BStore_CursorAdvance	; F61BBF  call 0xf4279c
	jrl	AdvanceDelay_ApplyToTrack_Join	; F61BC3  jrl T,0xf61b22
sub_F61AF7_Skip4:
	inc	1, de	; F61BC6  inc 1,DE
	push	xiz	; F61BC8  push XIZ
	ld	xiz, (BStore_CursorBlockAddr:16)	; F61BC9  ld XIZ,(0x126e)
	ldfr_lerp	xiz, 0x3c	; F61BCD  ld XHL3,XIZ
	pop	xiz	; F61BD0  pop XIZ
	push_lerp	0x3c	; F61BD1  push XHL3
	push	xhl	; F61BD4  push XHL
	pushw	de	; F61BD5  push DE
	push	xiy	; F61BD6  push XIY
	push	xix	; F61BD7  push XIX
	call	T_F427A8	; F61BD8  call 0xf427a8
	pop	xix	; F61BDC  pop XIX
	pop	xiy	; F61BDD  pop XIY
	popw	de	; F61BDE  pop DE
	pop	xhl	; F61BDF  pop XHL
	pop_lerp	0x3c	; F61BE0  pop XHL3
	push	xiz	; F61BE3  push XIZ
	ldto_lerp	xiz, 0x3c	; F61BE4  ld XIZ,XHL3
	ld	(BStore_CursorBlockAddr:16), xiz	; F61BE7  ld (0x126e),XIZ
	pop	xiz	; F61BEB  pop XIZ
	cp	(BStore_ErrorCode:16), 0x00	; F61BEC  cp (0x0d4a),0x00
	jrl	z, AdvanceDelay_ApplyToTrack_Loop	; F61BF1  jrl Z,0xf61b19
sub_F61AF7_Join3:
	cp	(BStore_ErrorCode:16), 0x00	; F61BF4  cp (0x0d4a),0x00
	jr	nz, sub_F61AF7_Return	; F61BF9  jr NZ,0xf61c0b
	bit	7, (0x0dec:16)	; F61BFB  bit 7,(0x0dec)
	jr	nz, sub_F61AF7_Skip5	; F61BFF  jr NZ,0xf61c07
	call	sub_F62089	; F61C01  call 0xf62089
	jr	sub_F61AF7_Return	; F61C05  jr T,0xf61c0b
sub_F61AF7_Skip5:
	call	sub_F61FBA	; F61C07  call 0xf61fba
sub_F61AF7_Return:
	ret	; F61C0B  ret

; --------------------------------------------------------------------------
; sub_F61C0C
; Called from: in-module: 0xF61BAF
; Touches: (0x0C8A) (0x0DEC)
; Calls:   sub_F61C24 sub_F61D65
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF61C0C is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F61C0C:
	bit	0, (0x0c8a:16)	; F61C0C  bit 0,(0x0c8a)
	jrl	z, sub_F61C0C_Return	; F61C10  jrl Z,0xf61c23
	bit	7, (0x0dec:16)	; F61C13  bit 7,(0x0dec)
	jr	nz, sub_F61C0C_Skip	; F61C17  jr NZ,0xf61c1f
	call	sub_F61C24	; F61C19  call 0xf61c24
	jr	sub_F61C0C_Return	; F61C1D  jr T,0xf61c23
sub_F61C0C_Skip:
	call	sub_F61D65	; F61C1F  call 0xf61d65
sub_F61C0C_Return:
	ret	; F61C23  ret

; --------------------------------------------------------------------------
; sub_F61C24
; Called from: in-module: 0xF61C19
; Touches: (0x0C8A) (0x0D0A) (0x0D14) (0x0D4A) (0x0E1A) (0x0E1B) (0x0E1F)
;          (0x126E)
; Calls:   T_BStore_CursorAdvance
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF61C24 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F61C24:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F61C24  ld XHL,(0x126e)
	push	xhl	; F61C28  push XHL
	pushw	bc	; F61C29  push BC
	pushw	de	; F61C2A  push DE
	bit	0, (0x0c8a:16)	; F61C2B  bit 0,(0x0c8a)
	jrl	z, sub_F61C24_Loop2	; F61C2F  jrl Z,0xf61d5d
sub_F61C24_Join:
	xor	hl, hl	; F61C32  xor HL,HL
	ld	iy, (3338:16)	; F61C34  ld IY,(0x0d0a)
	push	xhl	; F61C38  push XHL
	ld	xhl, (3348:16)	; F61C39  ld XHL,(0x0d14)
	ld	(BStore_CursorBlockAddr:16), xhl	; F61C3D  ld (0x126e),XHL
	ld	a, (xhl+iy)	; F61C41  ld A,(XHL+IY)
	pop	xhl	; F61C46  pop XHL
	cp	a, 129	; F61C47  cp A,0x81
	jrl	z, sub_F61C24_Skip6	; F61C4A  jrl Z,0xf61d1b
	cp	a, 130	; F61C4D  cp A,0x82
	jrl	z, sub_F61C24_Loop2	; F61C50  jrl Z,0xf61d5d
	cp	a, 208	; F61C53  cp A,0xd0
	jr	z, sub_F61C24_Skip	; F61C56  jr Z,0xf61c81
	cp	a, 209	; F61C58  cp A,0xd1
	jr	z, sub_F61C24_Skip	; F61C5B  jr Z,0xf61c81
	cp	a, 210	; F61C5D  cp A,0xd2
	jr	z, sub_F61C24_Skip8	; F61C60  jr Z,0xf61c89
	cp	a, 211	; F61C62  cp A,0xd3
	jr	z, sub_F61C24_Skip	; F61C65  jr Z,0xf61c81
	cp	a, 128	; F61C67  cp A,0x80
	jr	z, sub_F61C24_Skip8	; F61C6A  jr Z,0xf61c89
	and	a, 240	; F61C6C  and A,0xf0
	cp	a, 144	; F61C6F  cp A,0x90
	jr	z, sub_F61C24_Skip7	; F61C72  jr Z,0xf61c79
	cp	a, 176	; F61C74  cp A,0xb0
	jr	z, sub_F61C24_Skip7	; F61C77  jr Z,0xf61c79
sub_F61C24_Skip7:
	ld	w, 5:opc	; F61C79  ld W,0x05
	jr	sub_F61C24_Join3	; F61C7B  jr T,0xf61c8b
	ld	w, 0:opc	; F61C7D  ld W,0x00
	jr	sub_F61C24_Join3	; F61C7F  jr T,0xf61c8b
sub_F61C24_Skip:
	ld	w, 2:opc	; F61C81  ld W,0x02
	jr	sub_F61C24_Join3	; F61C83  jr T,0xf61c8b
	ld	w, 1:opc	; F61C85  ld W,0x01
	jr	sub_F61C24_Join3	; F61C87  jr T,0xf61c8b
sub_F61C24_Skip8:
	ld	w, 3:opc	; F61C89  ld W,0x03
sub_F61C24_Join3:
	xor	c, c	; F61C8B  xor C,C
sub_F61C24_Loop:
	pushw	wa	; F61C8D  push WA
	pushw	bc	; F61C8E  push BC
	call	T_BStore_CursorAdvance	; F61C8F  call 0xf4279c
	popw	bc	; F61C93  pop BC
	popw	wa	; F61C94  pop WA
	cp	(BStore_ErrorCode:16), 0x00	; F61C95  cp (0x0d4a),0x00
	jrl	nz, sub_F61C24_Loop2	; F61C9A  jrl NZ,0xf61d5d
	inc	1, c	; F61C9D  inc 1,C
	cp	w, c	; F61C9F  cp W,C
	jr	z, sub_F61C24_Skip5	; F61CA1  jr Z,0xf61d06
sub_F61C24_Join2:
	cp	c, 1:i3	; F61CA3  cp C,1
	jr	nz, sub_F61C24_Skip2	; F61CA5  jr NZ,0xf61cb7
	ld	xhl, (BStore_CursorBlockAddr:16)	; F61CA7  ld XHL,(0x126e)
	cp	(xhl+iy), 0x5f	; F61CAB  cp (XHL+IY),0x5f
	jr	ugt, sub_F61C24_Skip3	; F61CB1  jr UGT,0xf61ccf
	cp	c, w	; F61CB3  cp C,W
	jr	z, sub_F61C24_Skip5	; F61CB5  jr Z,0xf61d06
sub_F61C24_Skip2:
	pushw	wa	; F61CB7  push WA
	pushw	bc	; F61CB8  push BC
	call	T_BStore_CursorAdvance	; F61CB9  call 0xf4279c
	popw	bc	; F61CBD  pop BC
	popw	wa	; F61CBE  pop WA
	cp	(BStore_ErrorCode:16), 0x00	; F61CBF  cp (0x0d4a),0x00
	jrl	nz, sub_F61C24_Loop2	; F61CC4  jrl NZ,0xf61d5d
	inc	1, c	; F61CC7  inc 1,C
	cp	c, w	; F61CC9  cp C,W
	jr	z, sub_F61C24_Skip5	; F61CCB  jr Z,0xf61d06
	jr	sub_F61C24_Join2	; F61CCD  jr T,0xf61ca3
sub_F61C24_Skip3:
	bit	0, (0x0e1b:16)	; F61CCF  bit 0,(0x0e1b)
	jr	nz, sub_F61C24_Skip4	; F61CD3  jr NZ,0xf61cf0
	push	xwa	; F61CD5  push XWA
	ld	wa, (3338:16)	; F61CD6  ld WA,(0x0d0a)
	and	wa, 255	; F61CDA  and WA,0x00ff
	ld	(3610:16), wa	; F61CDE  ld (0x0e1a),WA
	ld	xwa, (3348:16)	; F61CE2  ld XWA,(0x0d14)
	ld	(3615:16), xwa	; F61CE6  ld (0x0e1f),XWA
	pop	xwa	; F61CEA  pop XWA
	or	(0x0e1b:16), 0x01	; F61CEB  or (0x0e1b),0x01
sub_F61C24_Skip4:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F61CF0  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F61CF4  ld A,(XHL+IY)
	sub	a, 96	; F61CF9  sub A,0x60
	ld	(xhl+iy), a	; F61CFC  ld (XHL+IY),A
	cp	c, w	; F61D01  cp C,W
	jrl	nz, sub_F61C24_Loop	; F61D03  jrl NZ,0xf61c8d
sub_F61C24_Skip5:
	call	T_BStore_CursorAdvance	; F61D06  call 0xf4279c
	push	xwa	; F61D0A  push XWA
	ld	xwa, (BStore_CursorBlockAddr:16)	; F61D0B  ld XWA,(0x126e)
	ld	(3348:16), xwa	; F61D0F  ld (0x0d14),XWA
	pop	xwa	; F61D13  pop XWA
	ld	(3338:16), iy	; F61D14  ld (0x0d0a),IY
	jrl	sub_F61C24_Join	; F61D18  jrl T,0xf61c32
sub_F61C24_Skip6:
	pushw	de	; F61D1B  push DE
	pushw	bc	; F61D1C  push BC
	ld	iy, (3610:16)	; F61D1D  ld IY,(0x0e1a)
	and	iy, 255	; F61D21  and IY,0x00ff
	ld	xhl, (3615:16)	; F61D25  ld XHL,(0x0e1f)
	ld	(BStore_CursorBlockAddr:16), xhl	; F61D29  ld (0x126e),XHL
	ld	d, (xhl+iy)	; F61D2D  ld D,(XHL+IY)
	ld	(xhl+iy), 0x81	; F61D32  ld (XHL+IY),0x81
sub_F61C24_Join4:
	cp	d, 129	; F61D38  cp D,0x81
	jr	z, sub_F61C24_Skip10	; F61D3B  jr Z,0xf61d5b
	call	T_BStore_CursorAdvance	; F61D3D  call 0xf4279c
	cp	(BStore_ErrorCode:16), 0x00	; F61D41  cp (0x0d4a),0x00
	jr	nz, sub_F61C24_Skip10	; F61D46  jr NZ,0xf61d5b
	ld	e, d	; F61D48  ld E,D
	ld	d, (xhl+iy)	; F61D4A  ld D,(XHL+IY)
	ld	(xhl+iy), e	; F61D4F  ld (XHL+IY),E
	bit	7, e	; F61D54  bit 0x07,E
	jr	z, sub_F61C24_Skip9	; F61D57  jr Z,0xf61d59
sub_F61C24_Skip9:
	jr	sub_F61C24_Join4	; F61D59  jr T,0xf61d38
sub_F61C24_Skip10:
	popw	bc	; F61D5B  pop BC
	popw	de	; F61D5C  pop DE
sub_F61C24_Loop2:
	popw	de	; F61D5D  pop DE
	popw	bc	; F61D5E  pop BC
	pop	xhl	; F61D5F  pop XHL
	ld	(BStore_CursorBlockAddr:16), xhl	; F61D60  ld (0x126e),XHL
	ret	; F61D64  ret

; --------------------------------------------------------------------------
; sub_F61D65
; Called from: in-module: 0xF61C1F
; Touches: (0x0C57) (0x0C59) (0x0C5D) (0x0C61) (0x0C67) (0x0C6B) (0x0C73)
;          (0x0C8A) (0x0D0A) (0x0D14) +10 more  |  0x617800
; Calls:   BStore_CursorStepBack T_BStore_CursorAdvance sub_F61F7B T_BStore_CopyRangeForward_Call
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF61D65 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F61D65:
	ld	(3612:16), 0	; F61D65  ld (0x0e1c),0x00
	ld	xhl, (BStore_CursorBlockAddr:16)	; F61D6A  ld XHL,(0x126e)
	push	xhl	; F61D6E  push XHL
	pushw	bc	; F61D6F  push BC
	pushw	de	; F61D70  push DE
	ld	xwa, (3348:16)	; F61D71  ld XWA,(0x0d14)
	ld	iy, (3338:16)	; F61D75  ld IY,(0x0d0a)
	ld	hl, (BStore_CursorBlock:16)	; F61D79  ld HL,(0x345c)
	push	xwa	; F61D7D  push XWA
	pushw	hl	; F61D7E  push HL
	pushw	iy	; F61D7F  push IY
	ld	xwa, (3348:16)	; F61D80  ld XWA,(0x0d14)
	ld	(BStore_CursorBlockAddr:16), xwa	; F61D84  ld (0x126e),XWA
	call	BStore_CursorStepBack	; F61D88  call 0xf5e2b9
	ld	(3165:16), iy	; F61D8C  ld (0x0c5d),IY
	ld	xwa, (BStore_CursorBlockAddr:16)	; F61D90  ld XWA,(0x126e)
	sub	xwa, 6387712	; F61D94  sub XWA,0x00617800
	sra	xwa, 8	; F61D9A  sra 0x08,XWA
	inc	1, xwa	; F61D9D  inc 1,XWA
	ld	(3159:16), wa	; F61D9F  ld (0x0c57),WA
	popw	iy	; F61DA3  pop IY
	popw	hl	; F61DA4  pop HL
	pop	xwa	; F61DA5  pop XWA
	ld	(3348:16), xwa	; F61DA6  ld (0x0d14),XWA
	ld	(BStore_CursorBlockAddr:16), xwa	; F61DAA  ld (0x126e),XWA
	ld	(BStore_CursorBlock:16), hl	; F61DAE  ld (0x345c),HL
	ld	(3338:16), iy	; F61DB2  ld (0x0d0a),IY
	ld	a, (BStore_ErrorCode:16)	; F61DB6  ld A,(0x0d4a)
	cp	a, 0:i3	; F61DBA  cp A,0
	jr	z, sub_F61D65_Skip	; F61DBC  jr Z,0xf61de0
	cp	a, 10	; F61DBE  cp A,0x0a
	jrl	nz, sub_F61D65_Skip14	; F61DC1  jrl NZ,0xf61f73
	ld	(BStore_ErrorCode:16), 0	; F61DC4  ld (0x0d4a),0x00
	cpw	(0x0c73:16), 0x0001	; F61DC9  cp (0x0c73),0x0001
	jr	nz, sub_F61D65_Skip	; F61DCF  jr NZ,0xf61de0
	.byte 0xD7, 0x38, 0xD8	; F61DD1  cp RDE3,0   [llvm-mc cannot encode this]
	jr	nz, sub_F61D65_Skip	; F61DD4  jr NZ,0xf61de0
	.byte 0xD7, 0x34, 0xD8	; F61DD6  cp RBC3,0   [llvm-mc cannot encode this]
	jr	nz, sub_F61D65_Skip	; F61DD9  jr NZ,0xf61de0
	ld	(3612:16), 1	; F61DDB  ld (0x0e1c),0x01
sub_F61D65_Skip:
	ld	(3611:16), 0	; F61DE0  ld (0x0e1b),0x00
	ld	(3613:16), 0	; F61DE5  ld (0x0e1d),0x00
	bit	0, (0x0c8a:16)	; F61DEA  bit 0,(0x0c8a)
	jrl	z, sub_F61D65_Skip14	; F61DEE  jrl Z,0xf61f73
sub_F61D65_Join:
	xor	hl, hl	; F61DF1  xor HL,HL
	ld	iy, (3338:16)	; F61DF3  ld IY,(0x0d0a)
	push	xhl	; F61DF7  push XHL
	ld	xhl, (3348:16)	; F61DF8  ld XHL,(0x0d14)
	ld	(BStore_CursorBlockAddr:16), xhl	; F61DFC  ld (0x126e),XHL
	ld	a, (xhl+iy)	; F61E00  ld A,(XHL+IY)
	pop	xhl	; F61E05  pop XHL
	cp	a, 129	; F61E06  cp A,0x81
	jrl	z, sub_F61D65_Skip10	; F61E09  jrl Z,0xf61ef8
	cp	a, 130	; F61E0C  cp A,0x82
	jrl	z, sub_F61D65_Skip14	; F61E0F  jrl Z,0xf61f73
	jr	z, sub_F61D65_Skip3	; F61E12  jr Z,0xf61e46
	cp	a, 208	; F61E14  cp A,0xd0
	jr	z, sub_F61D65_Skip2	; F61E17  jr Z,0xf61e42
	cp	a, 209	; F61E19  cp A,0xd1
	jr	z, sub_F61D65_Skip2	; F61E1C  jr Z,0xf61e42
	cp	a, 210	; F61E1E  cp A,0xd2
	jr	z, sub_F61D65_Skip16	; F61E21  jr Z,0xf61e4a
	cp	a, 211	; F61E23  cp A,0xd3
	jr	z, sub_F61D65_Skip2	; F61E26  jr Z,0xf61e42
	cp	a, 128	; F61E28  cp A,0x80
	jr	z, sub_F61D65_Skip16	; F61E2B  jr Z,0xf61e4a
	and	a, 240	; F61E2D  and A,0xf0
	cp	a, 144	; F61E30  cp A,0x90
	jr	z, sub_F61D65_Skip15	; F61E33  jr Z,0xf61e3a
	cp	a, 176	; F61E35  cp A,0xb0
	jr	z, sub_F61D65_Skip15	; F61E38  jr Z,0xf61e3a
sub_F61D65_Skip15:
	ld	w, 5:opc	; F61E3A  ld W,0x05
	jr	sub_F61D65_Join3	; F61E3C  jr T,0xf61e4c
	ld	w, 0:opc	; F61E3E  ld W,0x00
	jr	sub_F61D65_Join3	; F61E40  jr T,0xf61e4c
sub_F61D65_Skip2:
	ld	w, 2:opc	; F61E42  ld W,0x02
	jr	sub_F61D65_Join3	; F61E44  jr T,0xf61e4c
sub_F61D65_Skip3:
	ld	w, 1:opc	; F61E46  ld W,0x01
	jr	sub_F61D65_Join3	; F61E48  jr T,0xf61e4c
sub_F61D65_Skip16:
	ld	w, 3:opc	; F61E4A  ld W,0x03
sub_F61D65_Join3:
	xor	c, c	; F61E4C  xor C,C
sub_F61D65_Loop:
	pushw	wa	; F61E4E  push WA
	pushw	bc	; F61E4F  push BC
	call	T_BStore_CursorAdvance	; F61E50  call 0xf4279c
	popw	bc	; F61E54  pop BC
	popw	wa	; F61E55  pop WA
	cp	(BStore_ErrorCode:16), 0x00	; F61E56  cp (0x0d4a),0x00
	jrl	nz, sub_F61D65_Skip14	; F61E5B  jrl NZ,0xf61f73
	inc	1, c	; F61E5E  inc 1,C
	cp	w, c	; F61E60  cp W,C
	jr	z, sub_F61D65_Skip9	; F61E62  jr Z,0xf61ee3
sub_F61D65_Join2:
	cp	c, 1:i3	; F61E64  cp C,1
	jr	nz, sub_F61D65_Skip5	; F61E66  jr NZ,0xf61e8f
	ld	xhl, (BStore_CursorBlockAddr:16)	; F61E68  ld XHL,(0x126e)
	bit	7, (xhl+iy)	; F61E6C  bit 7,(XHL+IY)
	jr	nz, sub_F61D65_Skip6	; F61E71  jr NZ,0xf61ea8
	cp	(xhl+iy), 0x5f	; F61E73  cp (XHL+IY),0x5f
	jr	gt, sub_F61D65_Skip6	; F61E79  jr GT,0xf61ea8
	bit	0, (0x0e1b:16)	; F61E7B  bit 0,(0x0e1b)
	jr	z, sub_F61D65_Skip4	; F61E7F  jr Z,0xf61e8b
	bit	0, (0x0e1d:16)	; F61E81  bit 0,(0x0e1d)
	jr	nz, sub_F61D65_Skip4	; F61E85  jr NZ,0xf61e8b
	call	sub_F61F7B	; F61E87  call 0xf61f7b
sub_F61D65_Skip4:
	cp	c, w	; F61E8B  cp C,W
	jr	z, sub_F61D65_Skip9	; F61E8D  jr Z,0xf61ee3
sub_F61D65_Skip5:
	pushw	wa	; F61E8F  push WA
	pushw	bc	; F61E90  push BC
	call	T_BStore_CursorAdvance	; F61E91  call 0xf4279c
	popw	bc	; F61E95  pop BC
	popw	wa	; F61E96  pop WA
	cp	(BStore_ErrorCode:16), 0x00	; F61E97  cp (0x0d4a),0x00
	jrl	nz, sub_F61D65_Skip14	; F61E9C  jrl NZ,0xf61f73
	inc	1, c	; F61E9F  inc 1,C
	cp	c, w	; F61EA1  cp C,W
	jr	z, sub_F61D65_Skip9	; F61EA3  jr Z,0xf61ee3
	jrl	sub_F61D65_Join2	; F61EA5  jrl T,0xf61e64
sub_F61D65_Skip6:
	bit	0, (0x0e1b:16)	; F61EA8  bit 0,(0x0e1b)
	jr	nz, sub_F61D65_Skip7	; F61EAC  jr NZ,0xf61ec5
	push	xwa	; F61EAE  push XWA
	ld	wa, (3338:16)	; F61EAF  ld WA,(0x0d0a)
	ld	(3610:16), wa	; F61EB3  ld (0x0e1a),WA
	ld	xwa, (3348:16)	; F61EB7  ld XWA,(0x0d14)
	ld	(3615:16), xwa	; F61EBB  ld (0x0e1f),XWA
	pop	xwa	; F61EBF  pop XWA
	or	(0x0e1b:16), 0x01	; F61EC0  or (0x0e1b),0x01
sub_F61D65_Skip7:
	xor	a, a	; F61EC5  xor A,A
	bit	0, (0x0e1c:16)	; F61EC7  bit 0,(0x0e1c)
	jr	nz, sub_F61D65_Skip8	; F61ECB  jr NZ,0xf61ed9
	ld	xhl, (BStore_CursorBlockAddr:16)	; F61ECD  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F61ED1  ld A,(XHL+IY)
	add	a, 96	; F61ED6  add A,0x60
sub_F61D65_Skip8:
	ld	(xhl+iy), a	; F61ED9  ld (XHL+IY),A
	cp	c, w	; F61EDE  cp C,W
	jrl	nz, sub_F61D65_Loop	; F61EE0  jrl NZ,0xf61e4e
sub_F61D65_Skip9:
	call	T_BStore_CursorAdvance	; F61EE3  call 0xf4279c
	push	xwa	; F61EE7  push XWA
	ld	xwa, (BStore_CursorBlockAddr:16)	; F61EE8  ld XWA,(0x126e)
	ld	(3348:16), xwa	; F61EEC  ld (0x0d14),XWA
	pop	xwa	; F61EF0  pop XWA
	ld	(3338:16), iy	; F61EF1  ld (0x0d0a),IY
	jrl	sub_F61D65_Join	; F61EF5  jrl T,0xf61df1
sub_F61D65_Skip10:
	pushw	de	; F61EF8  push DE
	pushw	bc	; F61EF9  push BC
	bit	0, (0x0e1c:16)	; F61EFA  bit 0,(0x0e1c)
	jr	nz, sub_F61D65_Skip13	; F61EFE  jr NZ,0xf61f71
	bit	0, (0x0e1b:16)	; F61F00  bit 0,(0x0e1b)
	jr	z, sub_F61D65_Skip11	; F61F04  jr Z,0xf61f10
	bit	0, (0x0e1d:16)	; F61F06  bit 0,(0x0e1d)
	jr	nz, sub_F61D65_Skip11	; F61F0A  jr NZ,0xf61f10
	call	sub_F61F7B	; F61F0C  call 0xf61f7b
sub_F61D65_Skip11:
	ld	iy, (3610:16)	; F61F10  ld IY,(0x0e1a)
	and	iy, 255	; F61F14  and IY,0x00ff
	ld	(3175:16), iy	; F61F18  ld (0x0c67),IY
	ld	xhl, (3615:16)	; F61F1C  ld XHL,(0x0e1f)
	ld	(BStore_CursorBlockAddr:16), xhl	; F61F20  ld (0x126e),XHL
	sub	xhl, 6387712	; F61F24  sub XHL,0x00617800
	sra	xhl, 8	; F61F2A  sra 0x08,XHL
	inc	1, hl	; F61F2D  inc 1,HL
	ld	(3169:16), hl	; F61F2F  ld (0x0c61),HL
	ld	ix, (3614:16)	; F61F33  ld IX,(0x0e1e)
	and	ix, 255	; F61F37  and IX,0x00ff
	ld	(3179:16), ix	; F61F3B  ld (0x0c6b),IX
	ld	de, (3619:16)	; F61F3F  ld DE,(0x0e23)
	call	T_BStore_CopyRangeForward_Call	; F61F43  call 0xf427e8
	ld	xhl, (BStore_CopyDestAddr:16)	; F61F47  ld XHL,(0x0c59)
	cp	ix, 255	; F61F4B  cp IX,0x00ff
	jr	ule, sub_F61D65_Skip12	; F61F4F  jr ULE,0xf61f6b
	ld	hl, (xhl+3)	; F61F51  ld HL,(XHL+0x03)
	dec	1, hl	; F61F54  dec 1,HL
	extz	xhl	; F61F56  extz XHL
	sla	xhl, 8	; F61F58  sla 0x08,XHL
	add	xhl, 6387712	; F61F5B  add XHL,0x00617800
	ld	(BStore_CursorBlockAddr:16), xhl	; F61F61  ld (0x126e),XHL
	sub	ix, 256	; F61F65  sub IX,0x0100
	inc	5, ix	; F61F69  inc 5,IX
sub_F61D65_Skip12:
	ld	(xhl+ix), 0x81	; F61F6B  ld (XHL+IX),0x81
sub_F61D65_Skip13:
	popw	bc	; F61F71  pop BC
	popw	de	; F61F72  pop DE
sub_F61D65_Skip14:
	popw	de	; F61F73  pop DE
	popw	bc	; F61F74  pop BC
	pop	xhl	; F61F75  pop XHL
	ld	(BStore_CursorBlockAddr:16), xhl	; F61F76  ld (0x126e),XHL
	ret	; F61F7A  ret

; --------------------------------------------------------------------------
; sub_F61F7B
; Called from: in-module: 0xF61E87 0xF61F0C
; Touches: (0x0D0A) (0x0D14) (0x0E1D) (0x0E1E) (0x0E23)  |  0x617800
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF61F7B is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F61F7B:
	push	xix	; F61F7B  push XIX
	ld	ix, (3338:16)	; F61F7C  ld IX,(0x0d0a)
	cp	ix, 5:i3	; F61F80  cp IX,5
	jr	z, sub_F61F7B_Skip	; F61F82  jr Z,0xf61f9f
	dec	1, ix	; F61F84  dec 1,IX
	ld	(3614:16), ix	; F61F86  ld (0x0e1e),IX
	ld	xix, (3348:16)	; F61F8A  ld XIX,(0x0d14)
	sub	xix, 6387712	; F61F8E  sub XIX,0x00617800
	sra	xix, 8	; F61F94  sra 0x08,XIX
	inc	1, xix	; F61F97  inc 1,XIX
	ld	(3619:16), ix	; F61F99  ld (0x0e23),IX
	jr	sub_F61F7B_Join	; F61F9D  jr T,0xf61fb3
sub_F61F7B_Skip:
	ld	xix, (3348:16)	; F61F9F  ld XIX,(0x0d14)
	ld	ix, (xix+1)	; F61FA3  ld IX,(XIX+0x01)
	cp	ix, 0:i3	; F61FA6  cp IX,0
	jr	z, sub_F61F7B_Epilogue	; F61FA8  jr Z,0xf61fb8
	ld	(3619:16), ix	; F61FAA  ld (0x0e23),IX
	ld	(3614:16), 255	; F61FAE  ld (0x0e1e),0xff
sub_F61F7B_Join:
	ld	(3613:16), 1	; F61FB3  ld (0x0e1d),0x01
sub_F61F7B_Epilogue:
	pop	xix	; F61FB8  pop XIX
	ret	; F61FB9  ret

; --------------------------------------------------------------------------
; sub_F61FBA
; Called from: in-module: 0xF61C07
; Touches: (0x0C73) (0x0C8E) (0x0C90) (0x0D0A) (0x0D14) (0x0D4A) (0x0FD4)
;          (0x0FD6) (0x126E) (0x345C)
; Calls:   T_BStore_SeekMeasure sub_F62008 T_BStore_CursorAdvance SongEdit_SortBeatEventsByTiming
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF61FBA is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F61FBA:
	cpw	(0x0c73:16), 0x0001	; F61FBA  cp (0x0c73),0x0001
	jr	z, sub_F61FBA_Return	; F61FC0  jr Z,0xf62007
	ld	a, (3214:16)	; F61FC2  ld A,(0x0c8e)
	ld	de, (3187:16)	; F61FC6  ld DE,(0x0c73)
	ld	(3216:16), de	; F61FCA  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F61FCE  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F61FD2  cp (0x0d4a),0x00
	jr	nz, sub_F61FBA_Return	; F61FD7  jr NZ,0xf62007
	call	sub_F62008	; F61FD9  call 0xf62008
	cp	w, 0:i3	; F61FDD  cp W,0
	jr	nz, sub_F61FBA_Skip	; F61FDF  jr NZ,0xf61ff7
	ld	hl, (4052:16)	; F61FE1  ld HL,(0x0fd4)
	ld	(BStore_CursorBlock:16), wa	; F61FE5  ld (0x345c),WA
	ld	hl, (4054:16)	; F61FE9  ld HL,(0x0fd6)
	ld	iy, hl	; F61FED  ld IY,HL
	and	iy, 255	; F61FEF  and IY,0x00ff
	call	T_BStore_CursorAdvance	; F61FF3  call 0xf4279c
sub_F61FBA_Skip:
	ld	(3338:16), iy	; F61FF7  ld (0x0d0a),IY
	ld	xhl, (BStore_CursorBlockAddr:16)	; F61FFB  ld XHL,(0x126e)
	ld	(3348:16), xhl	; F61FFF  ld (0x0d14),XHL
	call	SongEdit_SortBeatEventsByTiming	; F62003  call 0xf5e0bd
sub_F61FBA_Return:
	ret	; F62007  ret

; --------------------------------------------------------------------------
; sub_F62008
; Called from: in-module: 0xF61FD9
; Touches: (0x0FD4) (0x0FD6) (0x345C)
; Calls:   sub_F62030
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF62008 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F62008:
	xor	c, c	; F62008  xor C,C
	and	iy, 255	; F6200A  and IY,0x00ff
	ld	(4054:16), iy	; F6200E  ld (0x0fd6),IY
	ld	wa, (BStore_CursorBlock:16)	; F62012  ld WA,(0x345c)
	ld	(4052:16), wa	; F62016  ld (0x0fd4),WA
sub_F62008_Loop:
	pushw	bc	; F6201A  push BC
	call	sub_F62030	; F6201B  call 0xf62030
	popw	bc	; F6201F  pop BC
	cp	w, 0:i3	; F62020  cp W,0
	jr	nz, sub_F62008_Return	; F62022  jr NZ,0xf6202f
	cp	a, 129	; F62024  cp A,0x81
	jr	nz, sub_F62008_Loop	; F62027  jr NZ,0xf6201a
	inc	1, c	; F62029  inc 1,C
	cp	c, 2:i3	; F6202B  cp C,2
	jr	nz, sub_F62008_Loop	; F6202D  jr NZ,0xf6201a
sub_F62008_Return:
	ret	; F6202F  ret

; --------------------------------------------------------------------------
; sub_F62030
; Called from: in-module: 0xF6201B
; Touches: nothing with an absolute address
; Calls:   sub_F62042 sub_F62073
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF62030 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F62030:
	call	sub_F62042	; F62030  call 0xf62042
	cp	w, 0:i3	; F62034  cp W,0
	jr	nz, sub_F62030_Return	; F62036  jr NZ,0xf62041
	call	sub_F62073	; F62038  call 0xf62073
	bit	7, a	; F6203C  bit 0x07,A
	jr	z, sub_F62030	; F6203F  jr Z,0xf62030
sub_F62030_Return:
	ret	; F62041  ret

; --------------------------------------------------------------------------
; sub_F62042
; Called from: in-module: 0xF62030
; Touches: (0x0FD4) (0x0FD6) (0x126E)
; Calls:   T_BStore_SeekBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF62042 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F62042:
	ld	iy, (4054:16)	; F62042  ld IY,(0x0fd6)
	cp	iy, 5:i3	; F62046  cp IY,5
	jr	nz, sub_F62042_Skip	; F62048  jr NZ,0xf62066
	ld	hl, (4052:16)	; F6204A  ld HL,(0x0fd4)
	call	T_BStore_SeekBlock	; F6204E  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F62052  ld XHL,(0x126e)
	ld	hl, (xhl+1)	; F62056  ld HL,(XHL+0x01)
	cp	hl, 0:i3	; F62059  cp HL,0
	jr	z, sub_F62042_Skip2	; F6205B  jr Z,0xf6206f
	ld	(4052:16), hl	; F6205D  ld (0x0fd4),HL
	ldw	iy, 255	; F62061  ld IY,0x00ff
	jr	sub_F62042_Join	; F62064  jr T,0xf62068
sub_F62042_Skip:
	dec	1, iy	; F62066  dec 1,IY
sub_F62042_Join:
	ld	(4054:16), iy	; F62068  ld (0x0fd6),IY
	xor	w, w	; F6206C  xor W,W
sub_F62042_Return:
	ret	; F6206E  ret
sub_F62042_Skip2:
	ld	w, 255:opc	; F6206F  ld W,0xff
	jr	sub_F62042_Return	; F62071  jr T,0xf6206e

; --------------------------------------------------------------------------
; sub_F62073
; Called from: in-module: 0xF62038
; Touches: (0x0FD4) (0x0FD6) (0x126E)
; Calls:   T_BStore_SeekBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF62073 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F62073:
	ld	hl, (4052:16)	; F62073  ld HL,(0x0fd4)
	call	T_BStore_SeekBlock	; F62077  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F6207B  ld XHL,(0x126e)
	ld	iy, (4054:16)	; F6207F  ld IY,(0x0fd6)
	ld	a, (xhl+iy)	; F62083  ld A,(XHL+IY)
	ret	; F62088  ret

; --------------------------------------------------------------------------
; sub_F62089
; Called from: in-module: 0xF61C01
; Touches: (0x0C8E) (0x0C90) (0x0D0A) (0x0D14) (0x0D4A) (0x126E)
; Calls:   T_BStore_SeekMeasure SongEdit_SortBeatEventsByTiming
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF62089 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F62089:
	ld	a, (3214:16)	; F62089  ld A,(0x0c8e)
	inc	1, de	; F6208D  inc 1,DE
	ld	(3216:16), de	; F6208F  ld (0x0c90),DE
	call	T_BStore_SeekMeasure	; F62093  call 0xf42774
	cp	(BStore_ErrorCode:16), 0x00	; F62097  cp (0x0d4a),0x00
	jr	nz, sub_F62089_Return	; F6209C  jr NZ,0xf620ae
	ld	xwa, (BStore_CursorBlockAddr:16)	; F6209E  ld XWA,(0x126e)
	ld	(3348:16), xwa	; F620A2  ld (0x0d14),XWA
	ld	(3338:16), iy	; F620A6  ld (0x0d0a),IY
	call	SongEdit_SortBeatEventsByTiming	; F620AA  call 0xf5e0bd
sub_F62089_Return:
	ret	; F620AE  ret

; --------------------------------------------------------------------------
; AdvanceDelay_ClampTimingsAtTrackEnd
; Called from: in-module: 0xF61B54
; Touches: (0x0C8A) (0x0D0A) (0x0D14) (0x0D4A) (0x0DEC) (0x0E1A) (0x0E1B)
;          (0x0E1F) (0x126E)
; Calls:   T_BStore_CursorAdvance AdvanceDelay_EnsureBeatMarkBeforeEndTag
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF620AF is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; AdvanceDelay_ClampTimingsAtTrackEnd: AdvanceDelay_ApplyToTrack's step at the 0x82 track end: nothing for an advance
;   (offset (0x0DEC) negative); for a delay that pushed a timing out of 0..0x5F ((0x0C8A) bit 0) walks the last beat's
;   events from (0x0D14)/(0x0D0A) and clamps each timing above 0x5F to 0x5F (first clamped position kept in
;   (0x0E1A)/(0x0E1F), (0x0E1B) bit 0); then AdvanceDelay_EnsureBeatMarkBeforeEndTag writes 0x81 before the 0x82 when the byte before is not 0x81.
;   Basis: caller + caller header + body. (notes/naming-pilot-2026-10-06/proposals_wave7_w.json)
AdvanceDelay_ClampTimingsAtTrackEnd:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F620AF  ld XHL,(0x126e)
	push	xhl	; F620B3  push XHL
	pushw	bc	; F620B4  push BC
	pushw	de	; F620B5  push DE
	bit	7, (0x0dec:16)	; F620B6  bit 7,(0x0dec)
	jrl	nz, AdvanceDelay_ClampTimingsAtTrackEnd_Join3	; F620BA  jrl NZ,0xf621b1
	bit	0, (0x0c8a:16)	; F620BD  bit 0,(0x0c8a)
	jrl	z, AdvanceDelay_ClampTimingsAtTrackEnd_Skip7	; F620C1  jrl Z,0xf621ae
AdvanceDelay_ClampTimingsAtTrackEnd_Join:
	xor	hl, hl	; F620C4  xor HL,HL
	ld	iy, (3338:16)	; F620C6  ld IY,(0x0d0a)
	push	xhl	; F620CA  push XHL
	ld	xhl, (3348:16)	; F620CB  ld XHL,(0x0d14)
	ld	(BStore_CursorBlockAddr:16), xhl	; F620CF  ld (0x126e),XHL
	ld	a, (xhl+iy)	; F620D3  ld A,(XHL+IY)
	pop	xhl	; F620D8  pop XHL
	cp	a, 129	; F620D9  cp A,0x81
	jrl	z, AdvanceDelay_ClampTimingsAtTrackEnd_Skip6	; F620DC  jrl Z,0xf621ac
	cp	a, 130	; F620DF  cp A,0x82
	jrl	z, AdvanceDelay_ClampTimingsAtTrackEnd_Skip7	; F620E2  jrl Z,0xf621ae
	cp	a, 208	; F620E5  cp A,0xd0
	jr	z, AdvanceDelay_ClampTimingsAtTrackEnd_Skip	; F620E8  jr Z,0xf62113
	cp	a, 209	; F620EA  cp A,0xd1
	jr	z, AdvanceDelay_ClampTimingsAtTrackEnd_Skip	; F620ED  jr Z,0xf62113
	cp	a, 210	; F620EF  cp A,0xd2
	jr	z, AdvanceDelay_ClampTimingsAtTrackEnd_Skip9	; F620F2  jr Z,0xf6211b
	cp	a, 211	; F620F4  cp A,0xd3
	jr	z, AdvanceDelay_ClampTimingsAtTrackEnd_Skip	; F620F7  jr Z,0xf62113
	cp	a, 128	; F620F9  cp A,0x80
	jr	z, AdvanceDelay_ClampTimingsAtTrackEnd_Skip9	; F620FC  jr Z,0xf6211b
	and	a, 240	; F620FE  and A,0xf0
	cp	a, 144	; F62101  cp A,0x90
	jr	z, AdvanceDelay_ClampTimingsAtTrackEnd_Skip8	; F62104  jr Z,0xf6210b
	cp	a, 176	; F62106  cp A,0xb0
	jr	z, AdvanceDelay_ClampTimingsAtTrackEnd_Skip8	; F62109  jr Z,0xf6210b
AdvanceDelay_ClampTimingsAtTrackEnd_Skip8:
	ld	w, 5:opc	; F6210B  ld W,0x05
	jr	AdvanceDelay_ClampTimingsAtTrackEnd_Join4	; F6210D  jr T,0xf6211d
	ld	w, 0:opc	; F6210F  ld W,0x00
	jr	AdvanceDelay_ClampTimingsAtTrackEnd_Join4	; F62111  jr T,0xf6211d
AdvanceDelay_ClampTimingsAtTrackEnd_Skip:
	ld	w, 2:opc	; F62113  ld W,0x02
	jr	AdvanceDelay_ClampTimingsAtTrackEnd_Join4	; F62115  jr T,0xf6211d
	ld	w, 1:opc	; F62117  ld W,0x01
	jr	AdvanceDelay_ClampTimingsAtTrackEnd_Join4	; F62119  jr T,0xf6211d
AdvanceDelay_ClampTimingsAtTrackEnd_Skip9:
	ld	w, 3:opc	; F6211B  ld W,0x03
AdvanceDelay_ClampTimingsAtTrackEnd_Join4:
	xor	c, c	; F6211D  xor C,C
AdvanceDelay_ClampTimingsAtTrackEnd_Loop:
	pushw	wa	; F6211F  push WA
	pushw	bc	; F62120  push BC
	call	T_BStore_CursorAdvance	; F62121  call 0xf4279c
	popw	bc	; F62125  pop BC
	popw	wa	; F62126  pop WA
	cp	(BStore_ErrorCode:16), 0x00	; F62127  cp (0x0d4a),0x00
	jrl	nz, sub_F61C24_Loop2	; F6212C  jrl NZ,0xf61d5d
	inc	1, c	; F6212F  inc 1,C
	cp	w, c	; F62131  cp W,C
	jr	z, AdvanceDelay_ClampTimingsAtTrackEnd_Skip5	; F62133  jr Z,0xf62197
AdvanceDelay_ClampTimingsAtTrackEnd_Join2:
	cp	c, 1:i3	; F62135  cp C,1
	jr	nz, AdvanceDelay_ClampTimingsAtTrackEnd_Skip2	; F62137  jr NZ,0xf62149
	ld	xhl, (BStore_CursorBlockAddr:16)	; F62139  ld XHL,(0x126e)
	cp	(xhl+iy), 0x5f	; F6213D  cp (XHL+IY),0x5f
	jr	ugt, AdvanceDelay_ClampTimingsAtTrackEnd_Skip3	; F62143  jr UGT,0xf62161
	cp	c, w	; F62145  cp C,W
	jr	z, AdvanceDelay_ClampTimingsAtTrackEnd_Skip5	; F62147  jr Z,0xf62197
AdvanceDelay_ClampTimingsAtTrackEnd_Skip2:
	pushw	wa	; F62149  push WA
	pushw	bc	; F6214A  push BC
	call	T_BStore_CursorAdvance	; F6214B  call 0xf4279c
	popw	bc	; F6214F  pop BC
	popw	wa	; F62150  pop WA
	cp	(BStore_ErrorCode:16), 0x00	; F62151  cp (0x0d4a),0x00
	jrl	nz, sub_F61C24_Loop2	; F62156  jrl NZ,0xf61d5d
	inc	1, c	; F62159  inc 1,C
	cp	c, w	; F6215B  cp C,W
	jr	z, AdvanceDelay_ClampTimingsAtTrackEnd_Skip5	; F6215D  jr Z,0xf62197
	jr	AdvanceDelay_ClampTimingsAtTrackEnd_Join2	; F6215F  jr T,0xf62135
AdvanceDelay_ClampTimingsAtTrackEnd_Skip3:
	bit	0, (0x0e1b:16)	; F62161  bit 0,(0x0e1b)
	jr	nz, AdvanceDelay_ClampTimingsAtTrackEnd_Skip4	; F62165  jr NZ,0xf62182
	push	xwa	; F62167  push XWA
	ld	wa, (3338:16)	; F62168  ld WA,(0x0d0a)
	and	wa, 255	; F6216C  and WA,0x00ff
	ld	(3610:16), wa	; F62170  ld (0x0e1a),WA
	ld	xwa, (3348:16)	; F62174  ld XWA,(0x0d14)
	ld	(3615:16), xwa	; F62178  ld (0x0e1f),XWA
	pop	xwa	; F6217C  pop XWA
	or	(0x0e1b:16), 0x01	; F6217D  or (0x0e1b),0x01
AdvanceDelay_ClampTimingsAtTrackEnd_Skip4:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F62182  ld XHL,(0x126e)
	ld	a, (xhl+iy)	; F62186  ld A,(XHL+IY)
	ld	a, 95:opc	; F6218B  ld A,0x5f
	ld	(xhl+iy), a	; F6218D  ld (XHL+IY),A
	cp	c, w	; F62192  cp C,W
	jrl	nz, AdvanceDelay_ClampTimingsAtTrackEnd_Loop	; F62194  jrl NZ,0xf6211f
AdvanceDelay_ClampTimingsAtTrackEnd_Skip5:
	call	T_BStore_CursorAdvance	; F62197  call 0xf4279c
	push	xwa	; F6219B  push XWA
	ld	xwa, (BStore_CursorBlockAddr:16)	; F6219C  ld XWA,(0x126e)
	ld	(3348:16), xwa	; F621A0  ld (0x0d14),XWA
	pop	xwa	; F621A4  pop XWA
	ld	(3338:16), iy	; F621A5  ld (0x0d0a),IY
	jrl	AdvanceDelay_ClampTimingsAtTrackEnd_Join	; F621A9  jrl T,0xf620c4
AdvanceDelay_ClampTimingsAtTrackEnd_Skip6:
	jr	AdvanceDelay_ClampTimingsAtTrackEnd_Join3	; F621AC  jr T,0xf621b1
AdvanceDelay_ClampTimingsAtTrackEnd_Skip7:
	calr	AdvanceDelay_EnsureBeatMarkBeforeEndTag	; F621AE  calr 0xf62201
AdvanceDelay_ClampTimingsAtTrackEnd_Join3:
	popw	de	; F621B1  pop DE
	popw	bc	; F621B2  pop BC
	pop	xhl	; F621B3  pop XHL
	ld	(BStore_CursorBlockAddr:16), xhl	; F621B4  ld (0x126e),XHL
	ret	; F621B8  ret

; --------------------------------------------------------------------------
; RoundMap_Bounds_A -- 36 bytes: the seven round-maps' STEP BOUNDARIES,
;                      concatenated in RoundMap_Table order, in ascending
;                      order.
; Layout: seven groups, one per map, of 1+2+4+8+3+6+12 entries -- that is
;         96/g rounded to the boundaries below 96, i.e. exactly the number
;         of half-grid step edges map g has.  1+2+4+8+3+6+12 = 36.
;   +0x00  [0] g=96  48
;   +0x01  [1] g=48  24 72
;   +0x03  [2] g=24  12 36 60 84
;   +0x07  [3] g=12  6 18 30 42 54 66 78 90
;   +0x0F  [4] g=32  16 48 80
;   +0x12  [5] g=16  8 24 40 56 72 88
;   +0x18  [6] g=8   4 12 20 28 36 44 52 60 68 76 84 92
; Entry count: 36, and it is DERIVED, not measured off the island: the group
;              sizes come from the seven maps' own grids, and the
;              concatenation is compared byte for byte with the ROM on every
;              emit.  The two lists together are the island's whole 72
;              bytes.
; Evidence: twelve sites in prom_b spell an address inside this island as a
;           32-bit word, and every one of the twelve is exactly a GROUP
;           START -- six in _A and six in _B, groups 1..6 of each (group 0
;           has a single entry and is not addressed).  The group sizes were
;           derived from the maps before those addresses were looked at, so
;           the agreement is a check and not a fit.
; Unknown: which list is used for what.  _B is _A rotated, which is the
;          shape of a 'previous boundary' table beside a 'next boundary'
;          one, but nothing decoded here says which way round.
; --------------------------------------------------------------------------
RoundMap_Bounds_A:
	.byte	0x30	; [0] g=96
	.byte	0x18, 0x48	; [1] g=48
	.byte	0x0C, 0x24, 0x3C, 0x54	; [2] g=24
	.byte	0x06, 0x12, 0x1E, 0x2A, 0x36, 0x42, 0x4E, 0x5A	; [3] g=12
	.byte	0x10, 0x30, 0x50	; [4] g=32
	.byte	0x08, 0x18, 0x28, 0x38, 0x48, 0x58	; [5] g=16
	.byte	0x04, 0x0C, 0x14, 0x1C, 0x24, 0x2C, 0x34, 0x3C, 0x44, 0x4C, 0x54, 0x5C	; [6] g=8

; --------------------------------------------------------------------------
; RoundMap_Bounds_B -- 36 bytes: the seven round-maps' STEP BOUNDARIES,
;                      concatenated in RoundMap_Table order, each map's list
;                      rotated right by one (the last boundary moved to the
;                      front).
; Layout: seven groups, one per map, of 1+2+4+8+3+6+12 entries -- that is
;         96/g rounded to the boundaries below 96, i.e. exactly the number
;         of half-grid step edges map g has.  1+2+4+8+3+6+12 = 36.
;   +0x00  [0] g=96  48
;   +0x01  [1] g=48  72 24
;   +0x03  [2] g=24  84 12 36 60
;   +0x07  [3] g=12  90 6 18 30 42 54 66 78
;   +0x0F  [4] g=32  80 16 48
;   +0x12  [5] g=16  88 8 24 40 56 72
;   +0x18  [6] g=8   92 4 12 20 28 36 44 52 60 68 76 84
; Entry count: 36, and it is DERIVED, not measured off the island: the group
;              sizes come from the seven maps' own grids, and the
;              concatenation is compared byte for byte with the ROM on every
;              emit.  The two lists together are the island's whole 72
;              bytes.
; Evidence: twelve sites in prom_b spell an address inside this island as a
;           32-bit word, and every one of the twelve is exactly a GROUP
;           START -- six in _A and six in _B, groups 1..6 of each (group 0
;           has a single entry and is not addressed).  The group sizes were
;           derived from the maps before those addresses were looked at, so
;           the agreement is a check and not a fit.
; Unknown: which list is used for what.  _B is _A rotated, which is the
;          shape of a 'previous boundary' table beside a 'next boundary'
;          one, but nothing decoded here says which way round.
; --------------------------------------------------------------------------
RoundMap_Bounds_B:
	.byte	0x30	; [0] g=96
	.byte	0x48, 0x18	; [1] g=48
	.byte	0x54, 0x0C, 0x24, 0x3C	; [2] g=24
	.byte	0x5A, 0x06, 0x12, 0x1E, 0x2A, 0x36, 0x42, 0x4E	; [3] g=12
	.byte	0x50, 0x10, 0x30	; [4] g=32
	.byte	0x58, 0x08, 0x18, 0x28, 0x38, 0x48	; [5] g=16
	.byte	0x5C, 0x04, 0x0C, 0x14, 0x1C, 0x24, 0x2C, 0x34, 0x3C, 0x44, 0x4C, 0x54	; [6] g=8


; --------------------------------------------------------------------------
; AdvanceDelay_EnsureBeatMarkBeforeEndTag
; Called from: in-module: 0xF621AE
; Touches: nothing with an absolute address
; Calls:   AdvanceDelay_ReadByteBeforeCursor AdvanceDelay_InsertBeatMarkBeforeEndTag
; Evidence: the label is here because it is the target of `calr 0xF62201` at
;           0xF621AE, the call that steps past the 72 bytes of
;           RoundMap_Bounds_A and _B; the address is an instruction boundary
;           of this transcription (re-asserted on every emit)
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; AdvanceDelay_EnsureBeatMarkBeforeEndTag: At the track's 0x82 end tag: unless the byte before it is already a 0x81
;   (AdvanceDelay_ReadByteBeforeCursor reads it, following the +1 link at offset 5), AdvanceDelay_InsertBeatMarkBeforeEndTag writes 0x81 over the 0x82 and a new 0x82
;   after it (allocating and linking a block at offset 0xFF) and moves track (0x0C8E)'s end cursor onto it.
;   AdvanceDelay_ClampTimingsAtTrackEnd's last step. Basis: caller + caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_a8.json)
AdvanceDelay_EnsureBeatMarkBeforeEndTag:
	calr	AdvanceDelay_ReadByteBeforeCursor	; F62201  calr 0xf622aa
	cp	a, 129	; F62204  cp A,0x81
	jr	z, AdvanceDelay_EnsureBeatMarkBeforeEndTag_Return	; F62207  jr Z,0xf6220c
	calr	AdvanceDelay_InsertBeatMarkBeforeEndTag	; F62209  calr 0xf6220d
AdvanceDelay_EnsureBeatMarkBeforeEndTag_Return:
	ret	; F6220C  ret

; --------------------------------------------------------------------------
; AdvanceDelay_InsertBeatMarkBeforeEndTag
; Called from: in-module: 0xF62209
; Touches: (0x0C8E) (0x126E)  |  0x60347E 0x6034A0 0x617800
; Calls:   T_BStore_AllocBlock_Veneer T_BStore_SeekBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF6220D is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; AdvanceDelay_InsertBeatMarkBeforeEndTag: At the cursor (block (0x126E), offset IY) on the track's 0x82 end tag:
;   writes 0x81 over it and a new 0x82 after it, moving track (0x0C8E)'s saved end offset (0x6034A0) on; at offset
;   0xFF it allocates and links a block (0x82 at +5, end cursor := it, 5), or does nothing when no block is free.
;   AdvanceDelay_EnsureBeatMarkBeforeEndTag's write step. Basis: caller + caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_d9.json)
AdvanceDelay_InsertBeatMarkBeforeEndTag:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F6220D  ld XHL,(0x126e)
	push	xhl	; F62211  push XHL
	push	xde	; F62212  push XDE
	push	xix	; F62213  push XIX
	push	xiy	; F62214  push XIY
	cp	iy, 255	; F62215  cp IY,0x00ff
	jr	z, AdvanceDelay_InsertBeatMarkBeforeEndTag_Skip	; F62219  jr Z,0xf6223f
	ld	(xhl+iy), 0x81	; F6221B  ld (XHL+IY),0x81
	inc	1, iy	; F62221  inc 1,IY
	ld	(xhl+iy), 0x82	; F62223  ld (XHL+IY),0x82
	ld	de, iy	; F62229  ld DE,IY
	ld	xix, 6304928	; F6222B  ld XIX,0x006034a0
	xor	bc, bc	; F62230  xor BC,BC
	ld	c, (3214:16)	; F62232  ld C,(0x0c8e)
	dec	1, c	; F62236  dec 1,C
	ld	(xix+bc), e	; F62238  ld (XIX+BC),E
	jr	AdvanceDelay_InsertBeatMarkBeforeEndTag_Join	; F6223D  jr T,0xf622a1
AdvanceDelay_InsertBeatMarkBeforeEndTag_Skip:
	cpw	(BStore_FreeCount:24), 0x0000	; F6223F  cp (0x6034ba),0x0000
	jr	z, AdvanceDelay_InsertBeatMarkBeforeEndTag_Join	; F62246  jr Z,0xf622a1
	ld	(xhl+iy), 0x81	; F62248  ld (XHL+IY),0x81
	push	xhl	; F6224E  push XHL
	call	T_BStore_AllocBlock_Veneer	; F6224F  call 0xf42884
	pop	xhl	; F62253  pop XHL
	ld	(xhl+3), ix	; F62254  ld (XHL+0x03),IX
	sub	xhl, 6387712	; F62257  sub XHL,0x00617800
	srl	xhl, 8	; F6225D  srl 0x08,XHL
	inc	1, hl	; F62260  inc 1,HL
	ld	bc, hl	; F62262  ld BC,HL
	ld	hl, ix	; F62264  ld HL,IX
	push	xbc	; F62266  push XBC
	push	xix	; F62267  push XIX
	call	T_BStore_SeekBlock	; F62268  call 0xf427bc
	pop	xix	; F6226C  pop XIX
	pop	xbc	; F6226D  pop XBC
	ld	xhl, (BStore_CursorBlockAddr:16)	; F6226E  ld XHL,(0x126e)
	ld	(xhl+1), bc	; F62272  ld (XHL+0x01),BC
	ldw	(xhl+3), 0xffff	; F62275  ld (XHL+0x03),0xffff
	ld	(xhl+5), 130	; F6227A  ld (XHL+0x05),0x82
	ld	xhl, 6304894	; F6227E  ld XHL,0x0060347e
	xor	bc, bc	; F62283  xor BC,BC
	ld	c, (3214:16)	; F62285  ld C,(0x0c8e)
	dec	1, c	; F62289  dec 1,C
	sla	bc, 1	; F6228B  sla 0x01,BC
	ld	(xhl+bc), ix	; F6228E  ld (XHL+BC),IX
	ld	xhl, 6304928	; F62293  ld XHL,0x006034a0
	srl	bc, 1	; F62298  srl 0x01,BC
	ld	(xhl+bc), 0x05	; F6229B  ld (XHL+BC),0x05
AdvanceDelay_InsertBeatMarkBeforeEndTag_Join:
	pop	xiy	; F622A1  pop XIY
	pop	xix	; F622A2  pop XIX
	pop	xde	; F622A3  pop XDE
	pop	xhl	; F622A4  pop XHL
	ld	(BStore_CursorBlockAddr:16), xhl	; F622A5  ld (0x126e),XHL
	ret	; F622A9  ret

; --------------------------------------------------------------------------
; AdvanceDelay_ReadByteBeforeCursor
; Called from: in-module: 0xF62201
; Touches: (0x0FD6) (0x126E)
; Calls:   T_BStore_SeekBlock
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF622AA is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; AdvanceDelay_ReadByteBeforeCursor: A = the byte before the cursor (block (0x126E), offset IY): offset - 1, or at
;   offset 5 the last byte (0xFF) of the +1 previous block; cursor block address and IY preserved, (0x0FD6) := IY.
;   AdvanceDelay_EnsureBeatMarkBeforeEndTag tests it for 0x81. Basis: caller + caller header + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave9_d9.json)
AdvanceDelay_ReadByteBeforeCursor:
	ld	xhl, (BStore_CursorBlockAddr:16)	; F622AA  ld XHL,(0x126e)
	push	xhl	; F622AE  push XHL
	push	xiy	; F622AF  push XIY
	ld	(4054:16), iy	; F622B0  ld (0x0fd6),IY
	cp	iy, 5:i3	; F622B4  cp IY,5
	jr	nz, AdvanceDelay_ReadByteBeforeCursor_Skip	; F622B6  jr NZ,0xf622c8
	ld	hl, (xhl+1)	; F622B8  ld HL,(XHL+0x01)
	call	T_BStore_SeekBlock	; F622BB  call 0xf427bc
	ld	xhl, (BStore_CursorBlockAddr:16)	; F622BF  ld XHL,(0x126e)
	ldw	iy, 255	; F622C3  ld IY,0x00ff
	jr	AdvanceDelay_ReadByteBeforeCursor_Join	; F622C6  jr T,0xf622ca
AdvanceDelay_ReadByteBeforeCursor_Skip:
	dec	1, iy	; F622C8  dec 1,IY
AdvanceDelay_ReadByteBeforeCursor_Join:
	ld	a, (xhl+iy)	; F622CA  ld A,(XHL+IY)
	pop	xiy	; F622CF  pop XIY
	pop	xhl	; F622D0  pop XHL
	ld	(BStore_CursorBlockAddr:16), xhl	; F622D1  ld (0x126e),XHL
	ret	; F622D5  ret
	.fill	2346, 1, 0x0E	; F622D6-F62BFF  `ret` padding (asserted pure 0x0E)
