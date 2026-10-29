wsa1_prom_b:
; === COVER-R1 0xF00000-0xF01800 ===
; 0xF00000-0xF017FF, coverage round 1: 1757 of this span's 6144 bytes are
; reachable -- 1495 as CODE (an entry point in the routine directory, or a
; branch prom_b's own converted instructions decode) in 12 runs, and 262 as
; DATA (only a `.long` or a 32-bit immediate names it) in 2 runs.  Everything
; else here is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice
;
; ⚠ AMENDED 2026-09-02 (lane promB2).  "Everything else here is NOT reachable
; and stays `.incbin`" is TWO claims, and only the first still holds.  NOT
; REACHABLE stands, and was re-checked independently: 0 `call nnn` / `jp nnn`
; operands in all four ROM images land in 0xF0033F-0xF007FF, and 0 routine-
; directory slots point in.  STAYS `.incbin` does NOT stand, and is withdrawn:
; reachability decides whether a span is CODE, not whether it can be TYPED, and
; 0xF0033F-0xF007FF is four runs of 4-byte pointer slots that other parts of the
; firmware read.  It is converted below.
;
; ⚠⚠ AND THAT MAKES A RE-RUN OF `gen_prom_b_cover_round1.py --splice` DESTRUCTIVE
; HERE.  That tool replaces a whole `; === COVER-R1 ... ===` block with its own
; emission, and its "nothing was touched" guard collects the converted lines
; OUTSIDE the markers -- so work spliced INSIDE one is invisible to it and would
; be silently reverted to `.incbin`, with the byte gate still green.  A guard
; was added to its splice() (it now refuses when a block holds labels its own
; emission does not); if you are reading this because that guard fired, the
; block is right and the tool's span record is stale.
; ------------------------------------------------------------------
; ⚠ AMENDED 2026-09-02, and the sentence above is KEPT because it is still
; true: 0xF00C4D-0xF017FF really is unreachable from every seed round 1 had.
; What it does not follow from is "and therefore stays `.incbin`".  Those
; 2,995 bytes -- the largest `.incbin` this image had left, 28% of prom_b's
; whole verbatim debt -- are now converted, as two pointer arrays and 828
; instructions, on evidence that does not use reachability at all: an exact
; unidasm tiling with no `db`, internal branches landing on boundaries, a
; unique byte phase for each array, and 26 pointers from 0xF0033C -- outside
; the span -- landing on instruction starts.  Unreachable is a fact about the
; call graph; it was never a fact about the bytes.
;   ★ AND WHY IT IS UNREACHABLE IS NOW ON THE RECORD TOO: the cluster is a
;     closed loop that calls a prom_a which is not the prom_a next to it.
;     notes/gen_prom_b_f00c4d_module.py, section ANOMALY; the reference
;     census with its positive controls is notes/prom_b_f00c4d_xrefs.py.
;   ⚠ THE NEW BLOCK SITS INSIDE THESE MARKERS.  gen_prom_b_cover_round1.py's
;     preservation check only guards lines OUTSIDE them, so re-running its
;     --splice would silently replace it.  If that happens, put it back with
;     `python3 notes/gen_prom_b_f00c4d_module.py --apply`.

; --- 0xF00000-0xF00019, 26 B, converted by lane promB6 (CODE).
;     five `jp 0x00F00014` slots -- the image's own entry-vector block --
;     followed by the two routines they name.  Every jump target is inside the
;     span.
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	jp	wsa1_prom_b_Return	; F00000  jp 0xf00014
	jp	wsa1_prom_b_Return	; F00004  jp 0xf00014
	jp	wsa1_prom_b_Return	; F00008  jp 0xf00014
	jp	wsa1_prom_b_Join	; F0000C  jp 0xf00015
	jp	wsa1_prom_b_Return	; F00010  jp 0xf00014
wsa1_prom_b_Return:
	ret	; F00014  ret
wsa1_prom_b_Join:
	call	T_TransportA_ResetCountersAndPattern	; F00015  call 0xf40984
	ret	; F00019  ret

; --------------------------------------------------------------------------
; T_F409B0_Nop
; Reached from: routine-directory slot T_F409B0, each holding `jp 0x00F0001A`
;               (the slots are re-read from the ROM on every emit).
; Extent:  32 bytes, 12 instructions, ends `ret`.  The walk marks exactly
;          0xF0001A-0xF00039.  5 bytes (16%) sit in spellings llvm-mc cannot
;          encode and stay `.byte` with the MAME text in the comment.
; Purpose: none -- the entry is a lone `ret`.  Named T_F409B0_Nop after what reaches it
;          (was sub_F0001A; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
T_F409B0_Nop:
	ret	; F0001A  ret
wsa1_prom_b_Join2:
	bit	0, (0x60501b:24)	; F0001B  bit 0,(0x60501b)
	jr	nz, wsa1_prom_b_Return2	; F00020  jr NZ,0xf00039
	ld	a, (UiEvent_Byte1:16)	; F00022  ld A,(0x20b8)
	cp	a, 17	; F00026  cp A,0x11
	jr	nz, wsa1_prom_b_Return2	; F00029  jr NZ,0xf00039
	ld	a, (UiEvent_Byte3:16)	; F0002B  ld A,(0x20ba)
	cp	a, 255	; F0002F  cp A,0xff
	jr	nz, wsa1_prom_b_Skip	; F00032  jr NZ,0xf00036
	xor	a, a	; F00034  xor A,A
wsa1_prom_b_Skip:
	calr	sub_F0003C	; F00036  calr 0xf0003c
wsa1_prom_b_Return2:
	ret	; F00039  ret

; --- 0xF0003A-0xF0003B, 2 B, converted by lane promB6 (TRAILER).
;     after T_F409B0_Nop's `ret`, before sub_F0003C
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x00, 0x00	; F0003A  routine trailer

; --------------------------------------------------------------------------
; sub_F0003C
; Reached from: a branch decoded inside this block -- the walk enters 0xF0003C
;               from code it had already reached, not from any table.
; Extent:  91 bytes, 36 instructions, ends `ret`.  The walk marks exactly
;          0xF0003C-0xF00096.  9 bytes (10%) sit in spellings llvm-mc cannot
;          encode and stay `.byte` with the MAME text in the comment.
; Unknown: what the routine is for.  ★ COVERAGE ROUND: this pass converts
;          reachable bytes and defers every semantic question, so the label
;          stays sub_XXXXXX with the gap stated.
; --------------------------------------------------------------------------
sub_F0003C:
	cp	(UiEvent_Byte1:16), 0x11	; F0003C  cp (0x20b8),0x11
	jrl	nz, sub_F0003C_Return	; F00041  jrl NZ,0xf00096
	ld	a, (UiEvent_Byte2:16)	; F00044  ld A,(0x20b9)
	and	a, (UiEvent_Byte3:16)	; F00048  and A,(0x20ba)
	bit	0, a	; F0004C  bit 0x00,A
	jr	nz, sub_F0003C_Skip	; F0004F  jr NZ,0xf00053
	jr	sub_F0003C_Return	; F00051  jr T,0xf00096
sub_F0003C_Skip:
	bit	2, (0x34bb:16)	; F00053  bit 2,(0x34bb)
	jr	z, sub_F0003C_Skip2	; F00057  jr Z,0xf0005e
	calr	Transport_StopAllRunning	; F00059  calr 0xf000b9
	jr	sub_F0003C_Return	; F0005C  jr T,0xf00096
sub_F0003C_Skip2:
	bit	7, (TransportA_State:8)	; F0005E  bit 7,(0x94)
	jr	z, sub_F0003C_Skip3	; F00061  jr Z,0xf0006a
	bit	2, (TransportB_State:8)	; F00063  bit 2,(0x96)
	jr	nz, sub_F0003C_Skip3	; F00066  jr NZ,0xf0006a
	jr	sub_F0003C_Return	; F00068  jr T,0xf00096
sub_F0003C_Skip3:
	pushw	wa	; F0006A  push WA
	calr	sub_F00099	; F0006B  calr 0xf00099
	cp	a, 1:i3	; F0006E  cp A,1
	popw	wa	; F00070  pop WA
	jr	z, sub_F0003C_Return	; F00071  jr Z,0xf00096
	ei	6	; F00073  ei 0x06
	ld	a, (TransportC_State:8)	; F00075  ld A,(0x95)
	bit	2, a	; F00078  bit 0x02,A
	jr	nz, sub_F0003C_Skip4	; F0007B  jr NZ,0xf00091
	bit	0, a	; F0007D  bit 0x00,A
	jr	z, sub_F0003C_Skip4	; F00080  jr Z,0xf00091
	xor	a, a	; F00082  xor A,A
	ld	(TransportC_State:8), a	; F00084  ld (0x95),A
	ld	(TransportA_State:8), a	; F00087  ld (0x94),A
	ld	(TransportB_State:8), a	; F0008A  ld (0x96),A
	ei	0	; F0008D  ei 0x00
	jr	sub_F0003C_Return	; F0008F  jr T,0xf00096
sub_F0003C_Skip4:
	ei	0	; F00091  ei 0x00
	calr	sub_F00108	; F00093  calr 0xf00108
sub_F0003C_Return:
	ret	; F00096  ret

; --- 0xF00097-0xF00098, 2 B, converted by lane promB6 (TRAILER).
;     after sub_F0003C's `ret`, before sub_F00099
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x00, 0x00	; F00097  routine trailer

; --------------------------------------------------------------------------
; sub_F00099
; Reached from: a branch decoded inside this block -- the walk enters 0xF00099
;               from code it had already reached, not from any table.
; Extent:  74 bytes, 29 instructions, ends `ret`.  The walk marks exactly
;          0xF00099-0xF000E2.  15 bytes (20%) sit in spellings llvm-mc cannot
;          encode and stay `.byte` with the MAME text in the comment.
; Unknown: what the routine is for.  ★ COVERAGE ROUND: this pass converts
;          reachable bytes and defers every semantic question, so the label
;          stays sub_XXXXXX with the gap stated.
; --------------------------------------------------------------------------
sub_F00099:
	cp	(UI_ScreenLatch:16), 0x45	; F00099  cp (0x207a),0x45
	jr	z, sub_F00099_Join2	; F0009E  jr Z,0xf000b6
	cp	(PanelMode:16), 0x0d	; F000A0  cp (0x2078),0x0d
	jr	z, sub_F00099_Join2	; F000A5  jr Z,0xf000b6
	cp	(UI_ScreenLatch:16), 0x13	; F000A7  cp (0x207a),0x13
	jr	z, sub_F00099_Skip	; F000AC  jr Z,0xf000b0
	jr	sub_F00099_Join	; F000AE  jr T,0xf000b2
sub_F00099_Skip:
	jr	sub_F00099_Join2	; F000B0  jr T,0xf000b6
sub_F00099_Join:
	ld	a, 0:opc	; F000B2  ld A,0x00
	jr	sub_F00099_Return	; F000B4  jr T,0xf000b8
sub_F00099_Join2:
	ld	a, 1:opc	; F000B6  ld A,0x01
sub_F00099_Return:
	ret	; F000B8  ret
; Transport_StopAllRunning: with interrupts at level 6, builds a mask of which transports run (A bit 2 -> 4, B -> 8, C -> 0x10) and calls
;   Transport_StopByRunningMask[mask]; every handler there writes 0x0C to exactly the running transports' states.
Transport_StopAllRunning:
	xor	xhl, xhl	; F000B9  xor XHL,XHL
	ei	6	; F000BB  ei 0x06
	bit	2, (TransportA_State:8)	; F000BD  bit 2,(0x94)
	jr	z, sub_F00099_Skip2	; F000C0  jr Z,0xf000c5
	or	l, 4	; F000C2  or L,0x04
sub_F00099_Skip2:
	bit	2, (TransportB_State:8)	; F000C5  bit 2,(0x96)
	jr	z, sub_F00099_Skip3	; F000C8  jr Z,0xf000cd
	or	l, 8	; F000CA  or L,0x08
sub_F00099_Skip3:
	bit	2, (TransportC_State:8)	; F000CD  bit 2,(0x95)
	jr	z, sub_F00099_Skip4	; F000D0  jr Z,0xf000d5
	or	l, 16	; F000D2  or L,0x10
sub_F00099_Skip4:
	ld	xwa, Transport_StopByRunningMask	; F000D5  ld XWA,0x00f000e5
	add	xhl, xwa	; F000DA  add XHL,XWA
	ld	xwa, (xhl)	; F000DC  ld XWA,(XHL)
	call	(xwa)	; F000DE  call T,XWA
	ei	0	; F000E0  ei 0x00
	ret	; F000E2  ret

; --- 0xF000E3-0xF000E4, 2 B, converted by lane promB6 (TRAILER).
;     after sub_F00099's `ret`, before Transport_StopByRunningMask
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x00, 0x00	; F000E3  routine trailer

; --------------------------------------------------------------------------
; Transport_StopByRunningMask -- 1 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F000E5 appears as a 32-bit word at 0xF000D6.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 0% printable ASCII; a linear decode runs 1 instructions and ends
;           `halt`, with 0% of the bytes in spellings llvm-mc will not encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; Transport_StopByRunningMask: Transport_StopAllRunning's eight handlers, indexed by the running mask (A 4, B 8, C 0x10); each writes
;   0x0C (stop request) to the running transports' states -- entry 0 is a bare ret (notes/prom_ab_read_names_2026_10_04.py).
Transport_StopByRunningMask:
	.byte	0x05	; F000E5  |.|

; --- 0xF000E6-0xF00107, 34 B, converted by lane promB6 (PTRTAB4).
;     the rest of the 8-entry CALL-DISPATCH array Transport_StopByRunningMask.  sub_F00099
;     ends `ld XWA,0x00F000E5` / `add XHL,XWA` / `ld XWA,(XHL)` / `call XWA`
;     at 0xF000D5-0xF000DE, so the object is a table of routine pointers
;     reached by an index.  Its eight targets are 0x00F00105 0x00F0028D
;     0x00F002C9 0x00F002EB 0x00F002B9 0x00F00280 0x00F002B6 0x00F002B3 -- and
;     ALL EIGHT land on an instruction boundary in the code this lane
;     converted at 0xF00280/0xF0029D/0xF002CD.  That mutual check is what
;     makes both the table and those spans safe.  The 3 bytes after the array
;     are 0xF00105 (a bare 0x0E `ret`, the array's entry 0) and a `00 00`
;     trailer.
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x01, 0xF0, 0x00	; F000E6  top 3 bytes of the entry at F000E5 = 0x00F00105
	.long	sub_F001C9_Arm	; F000E9  entry 1
	.long	TransportB_Stop	; F000ED  entry 2
	.long	sub_F002C9_Arm	; F000F1  entry 3
	.long	sub_F00293_Arm	; F000F5  entry 4
	.long	Transport_StopCAndA	; F000F9  entry 5
	.long	sub_F00293_Arm2	; F000FD  entry 6
	.long	sub_F00293_Arm3	; F00101  entry 7
	.byte	0x0E, 0x00, 0x00	; F00105  past the array: 0x0E (`ret`) and the routine trailer

; --------------------------------------------------------------------------
; sub_F00108
; Reached from: a branch decoded inside this block -- the walk enters 0xF00108
;               from code it had already reached, not from any table.
; Extent:  115 bytes, 34 instructions, ends `ret`.  The walk marks exactly
;          0xF00108-0xF0017A.  4 bytes (3%) sit in spellings llvm-mc cannot
;          encode and stay `.byte` with the MAME text in the comment.
; Unknown: what the routine is for.  ★ COVERAGE ROUND: this pass converts
;          reachable bytes and defers every semantic question, so the label
;          stays sub_XXXXXX with the gap stated.
; --------------------------------------------------------------------------
sub_F00108:
	bit	1, (0x360b:16)	; F00108  bit 1,(0x360b)
	jr	z, sub_F00108_Skip3	; F0010C  jr Z,0xf00145
	ld	xwa, (12288:16)	; F0010E  ld XWA,(0x3000)
	cp	xwa, 0	; F00112  cp XWA,0x00000000
	jr	z, sub_F00108_Skip2	; F00118  jr Z,0xf00131
	ld	xwa, (6304798:24)	; F0011A  ld XWA,(0x60341e)
	cp	xwa, 0	; F0011F  cp XWA,0x00000000
	jr	z, sub_F00108_Skip	; F00125  jr Z,0xf0012c
	calr	Transport_StartStopContinue	; F00127  calr 0xf0020b
	jr	sub_F00108_Join	; F0012A  jr T,0xf00143
sub_F00108_Skip:
	calr	Transport_StartStopContinue_Call	; F0012C  calr 0xf0023c
	jr	sub_F00108_Join	; F0012F  jr T,0xf00143
sub_F00108_Skip2:
	ld	xwa, (6304798:24)	; F00131  ld XWA,(0x60341e)
	cp	xwa, 0	; F00136  cp XWA,0x00000000
	jr	z, sub_F00108_Join	; F0013C  jr Z,0xf00143
	calr	Transport_ToggleCAndB_Call	; F0013E  calr 0xf00240
	jr	sub_F00108_Join	; F00141  jr T,0xf00143
sub_F00108_Join:
	jr	sub_F00108_Return	; F00143  jr T,0xf0017a
sub_F00108_Skip3:
	ld	xwa, (12288:16)	; F00145  ld XWA,(0x3000)
	cp	xwa, 0	; F00149  cp XWA,0x00000000
	jr	z, sub_F00108_Skip5	; F0014F  jr Z,0xf00168
	ld	xwa, (6304798:24)	; F00151  ld XWA,(0x60341e)
	cp	xwa, 0	; F00156  cp XWA,0x00000000
	jr	z, sub_F00108_Skip4	; F0015C  jr Z,0xf00163
	calr	Transport_StartStopFromZero	; F0015E  calr 0xf0017d
	jr	sub_F00108_Return	; F00161  jr T,0xf0017a
sub_F00108_Skip4:
	calr	Transport_StartStopFromZero_Call	; F00163  calr 0xf001b0
	jr	sub_F00108_Return	; F00166  jr T,0xf0017a
sub_F00108_Skip5:
	ld	xwa, (6304798:24)	; F00168  ld XWA,(0x60341e)
	cp	xwa, 0	; F0016D  cp XWA,0x00000000
	jr	z, sub_F00108_Return	; F00173  jr Z,0xf0017a
	calr	Transport_ToggleCAndB	; F00175  calr 0xf001b5
	jr	sub_F00108_Return	; F00178  jr T,0xf0017a
sub_F00108_Return:
	ret	; F0017A  ret

; --- 0xF0017B-0xF0017C, 2 B, converted by lane promB6 (TRAILER).
;     after sub_F00108's `ret`, before Transport_StartStopFromZero
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x00, 0x00	; F0017B  routine trailer

; --------------------------------------------------------------------------
; Transport_StartStopFromZero
; Reached from: a branch decoded inside this block -- the walk enters 0xF0017D
;               from code it had already reached, not from any table.
; Extent:  49 bytes, 15 instructions, ends `ret`.  The walk marks exactly
;          0xF0017D-0xF001AD.  12 bytes (24%) sit in spellings llvm-mc cannot
;          encode and stay `.byte` with the MAME text in the comment.
; Unknown: what the routine is for.  ★ COVERAGE ROUND: this pass converts
;          reachable bytes and defers every semantic question, so the label
;          stays sub_XXXXXX with the gap stated.
; --------------------------------------------------------------------------
; Transport_StartStopFromZero: if C does not run, Transport_StartAllFromZero; if B runs and (0x3000) is non-zero, T_Transport_StopWhileRecording with (0x60501B) bit 0
;   set around it; otherwise Transport_StopAllRunning.
Transport_StartStopFromZero:
	bit	2, (TransportC_State:8)	; F0017D  bit 2,(0x95)
	jr	nz, Transport_StartStopFromZero_Skip	; F00180  jr NZ,0xf00187
	calr	Transport_StartAllFromZero	; F00182  calr 0xf001c9
	jr	Transport_StartStopFromZero_Return	; F00185  jr T,0xf001ad
Transport_StartStopFromZero_Skip:
	bit	2, (TransportB_State:8)	; F00187  bit 2,(0x96)
	jr	z, Transport_StartStopFromZero_Skip2	; F0018A  jr Z,0xf001aa
	ld	xwa, (12288:16)	; F0018C  ld XWA,(0x3000)
	cp	xwa, 0	; F00190  cp XWA,0x00000000
	jr	z, Transport_StartStopFromZero_Skip2	; F00196  jr Z,0xf001aa
	or	(0x60501b:24), 0x01	; F00198  or (0x60501b),0x01
	call	T_Transport_StopWhileRecording	; F0019E  call 0xf40e18
	and	(0x60501b:24), 0xfe	; F001A2  and (0x60501b),0xfe
	jr	Transport_StartStopFromZero_Return	; F001A8  jr T,0xf001ad
Transport_StartStopFromZero_Skip2:
	calr	Transport_StopAllRunning	; F001AA  calr 0xf000b9
Transport_StartStopFromZero_Return:
	ret	; F001AD  ret

; --- 0xF001AE-0xF001AF, 2 B, converted by lane promB6 (TRAILER).
;     after Transport_StartStopFromZero's `ret`, before Transport_StartStopFromZero_Call
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x00, 0x00	; F001AE  routine trailer

; --------------------------------------------------------------------------
; Transport_StartStopFromZero_Call
; Reached from: a branch decoded inside this block -- the walk enters 0xF001B0
;               from code it had already reached, not from any table.
; Extent:  4 bytes, 2 instructions, ends `ret`.  The walk marks exactly
;          0xF001B0-0xF001B3.  0 bytes (0%) sit in spellings llvm-mc cannot
;          encode and stay `.byte` with the MAME text in the comment.
; Unknown: what the routine is for.  ★ COVERAGE ROUND: this pass converts
;          reachable bytes and defers every semantic question, so the label
;          stays sub_XXXXXX with the gap stated.
; --------------------------------------------------------------------------
; Transport_StartStopFromZero_Call: calls Transport_StartStopFromZero and returns (notes/prom_ab_wrapper_names.py; DERIVATIVE)
Transport_StartStopFromZero_Call:
	calr	Transport_StartStopFromZero	; F001B0  calr 0xf0017d
	ret	; F001B3  ret

; --- 0xF001B4-0xF001B4, 1 B, converted by lane promB6 (TRAILER).
;     one 0x0E byte after Transport_StartStopFromZero_Call's `ret`: the 0x0E (`ret`) pad this build
;     uses, already asserted as `.fill ..., 0x0E` in eight other places in
;     this file
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x0E	; F001B4  routine trailer

; --------------------------------------------------------------------------
; Transport_ToggleCAndB
; Reached from: a branch decoded inside this block -- the walk enters 0xF001B5
;               from code it had already reached, not from any table.
; Extent:  18 bytes, 8 instructions, ends `ret`.  The walk marks exactly
;          0xF001B5-0xF001C6.  0 bytes (0%) sit in spellings llvm-mc cannot
;          encode and stay `.byte` with the MAME text in the comment.
; Unknown: what the routine is for.  ★ COVERAGE ROUND: this pass converts
;          reachable bytes and defers every semantic question, so the label
;          stays sub_XXXXXX with the gap stated.
; --------------------------------------------------------------------------
; Transport_ToggleCAndB: if transport C runs, Transport_StopAllRunning; else Transport_StartCAndB at interrupt level 6.
Transport_ToggleCAndB:
	bit	2, (TransportC_State:8)	; F001B5  bit 2,(0x95)
	jr	nz, Transport_ToggleCAndB_Skip	; F001B8  jr NZ,0xf001c3
	ei	6	; F001BA  ei 0x06
	calr	Transport_StartCAndB	; F001BC  calr 0xf00293
	ei	0	; F001BF  ei 0x00
	jr	Transport_ToggleCAndB_Return	; F001C1  jr T,0xf001c6
Transport_ToggleCAndB_Skip:
	calr	Transport_StopAllRunning	; F001C3  calr 0xf000b9
Transport_ToggleCAndB_Return:
	ret	; F001C6  ret

; --- 0xF001C7-0xF001C8, 2 B, converted by lane promB6 (TRAILER).
;     after Transport_ToggleCAndB's `ret`, before Transport_StartAllFromZero
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x00, 0x00	; F001C7  routine trailer

; --------------------------------------------------------------------------
; Transport_StartAllFromZero
; Reached from: routine-directory slot T_Transport_StartAllFromZero, each holding `jp 0x00F001C9`
;               (the slots are re-read from the ROM on every emit).
; Extent:  183 bytes, 61 instructions, ends `ret`.  The walk marks exactly
;          0xF001C9-0xF0027F.  38 bytes (21%) sit in spellings llvm-mc cannot
;          encode and stay `.byte` with the MAME text in the comment.
; Unknown: what the routine is for.  ★ COVERAGE ROUND: this pass converts
;          reachable bytes and defers every semantic question, so the label
;          stays sub_XXXXXX with the gap stated.
; --------------------------------------------------------------------------
; Transport_StartAllFromZero: unless C is starting or running: either a count-in (TransportA_State = 0x80, (0x34D9) |= 4, when (0x34D9) bit 1
;   is set and bit 2 clear) or TransportC_State = 1 with TransportC_ResetCounters and the MIDI start; then
;   TransportB_State = 1 + TransportB_ResetCounters and TransportA_State = 1 + TransportA_ResetCounters.
Transport_StartAllFromZero:
	bit	0, (TransportC_State:8)	; F001C9  bit 0,(0x95)
	jr	nz, Transport_StartAllFromZero_Skip2	; F001CC  jr NZ,0xf001fa
	bit	2, (TransportC_State:8)	; F001CE  bit 2,(0x95)
	jr	nz, Transport_StartAllFromZero_Skip2	; F001D1  jr NZ,0xf001fa
	bit	2, (0x34d9:16)	; F001D3  bit 2,(0x34d9)
	jr	nz, Transport_StartAllFromZero_Skip	; F001D7  jr NZ,0xf001f1
	bit	1, (0x34d9:16)	; F001D9  bit 1,(0x34d9)
	jr	z, Transport_StartAllFromZero_Skip	; F001DD  jr Z,0xf001f1
	call	T_CountIn_SetMeasureToFirstBar	; F001DF  call 0xf40a40
	call	T_TransportA_ResetCountersAndPattern	; F001E3  call 0xf40984
	ld	(TransportA_State:8), 128:io	; F001E7  ld (0x94),0x80
	or	(0x34d9:16), 0x04	; F001EA  or (0x34d9),0x04
	jr	Transport_StartAllFromZero_Return	; F001EF  jr T,0xf0020a
Transport_StartAllFromZero_Skip:
	ld	(TransportC_State:8), 1:io	; F001F1  ld (0x95),0x01
	calr	TransportC_ResetCounters	; F001F4  calr 0xf002f4
	calr	Transport_QueueMidiStartOrContinue	; F001F7  calr 0xf00320
Transport_StartAllFromZero_Skip2:
	call	T_TransportA_ResetCountersAndPattern	; F001FA  call 0xf40984
	ld	(TransportB_State:8), 1:io	; F001FE  ld (0x96),0x01
	calr	TransportB_ResetCounters	; F00201  calr 0xf00313
	ld	(TransportA_State:8), 1:io	; F00204  ld (0x94),0x01
	calr	TransportA_ResetCounters	; F00207  calr 0xf00301
Transport_StartAllFromZero_Return:
	ret	; F0020A  ret
; Transport_StartStopContinue: the same with Transport_StartAllContinue for the start.
Transport_StartStopContinue:
	bit	2, (TransportC_State:8)	; F0020B  bit 2,(0x95)
	jr	nz, Transport_StartStopContinue_Skip3	; F0020E  jr NZ,0xf00215
	calr	Transport_StartAllContinue	; F00210  calr 0xf00244
	jr	Transport_StartStopContinue_Return2	; F00213  jr T,0xf0023b
Transport_StartStopContinue_Skip3:
	bit	2, (TransportB_State:8)	; F00215  bit 2,(0x96)
	jr	z, Transport_StartStopContinue_Skip4	; F00218  jr Z,0xf00238
	ld	xwa, (12288:16)	; F0021A  ld XWA,(0x3000)
	cp	xwa, 0	; F0021E  cp XWA,0x00000000
	jr	z, Transport_StartStopContinue_Skip4	; F00224  jr Z,0xf00238
	or	(0x60501b:24), 0x01	; F00226  or (0x60501b),0x01
	call	T_Transport_StopWhileRecording	; F0022C  call 0xf40e18
	and	(0x60501b:24), 0xfe	; F00230  and (0x60501b),0xfe
	jr	Transport_StartStopContinue_Return2	; F00236  jr T,0xf0023b
Transport_StartStopContinue_Skip4:
	calr	Transport_StopAllRunning	; F00238  calr 0xf000b9
Transport_StartStopContinue_Return2:
	ret	; F0023B  ret
; Transport_StartStopContinue_Call: calls Transport_StartStopContinue and returns -- `calr Transport_StartStopContinue / ret`.
Transport_StartStopContinue_Call:
	calr	Transport_StartStopContinue	; F0023C  calr 0xf0020b
	ret	; F0023F  ret
; Transport_ToggleCAndB_Call: calls Transport_ToggleCAndB and returns -- `calr Transport_ToggleCAndB / ret`.
Transport_ToggleCAndB_Call:
	calr	Transport_ToggleCAndB	; F00240  calr 0xf001b5
	ret	; F00243  ret
; Transport_StartAllContinue: the same start without resetting C's or B's counters (only TransportA_ResetCounters).
Transport_StartAllContinue:
	bit	0, (TransportC_State:8)	; F00244  bit 0,(0x95)
	jr	nz, Transport_StartAllContinue_Skip6	; F00247  jr NZ,0xf00272
	bit	2, (TransportC_State:8)	; F00249  bit 2,(0x95)
	jr	nz, Transport_StartAllContinue_Skip6	; F0024C  jr NZ,0xf00272
	bit	2, (0x34d9:16)	; F0024E  bit 2,(0x34d9)
	jr	nz, Transport_StartAllContinue_Skip5	; F00252  jr NZ,0xf0026c
	bit	1, (0x34d9:16)	; F00254  bit 1,(0x34d9)
	jr	z, Transport_StartAllContinue_Skip5	; F00258  jr Z,0xf0026c
	call	T_CountIn_SetMeasureToFirstBar	; F0025A  call 0xf40a40
	call	T_TransportA_ResetCountersAndPattern	; F0025E  call 0xf40984
	ld	(TransportA_State:8), 128:io	; F00262  ld (0x94),0x80
	or	(0x34d9:16), 0x04	; F00265  or (0x34d9),0x04
	jr	Transport_StartAllContinue_Return3	; F0026A  jr T,0xf0027f
Transport_StartAllContinue_Skip5:
	ld	(TransportC_State:8), 1:io	; F0026C  ld (0x95),0x01
	calr	Transport_QueueMidiStartOrContinue	; F0026F  calr 0xf00320
Transport_StartAllContinue_Skip6:
	call	T_TransportA_ResetCountersAndPattern	; F00272  call 0xf40984
	ld	(TransportB_State:8), 1:io	; F00276  ld (0x96),0x01
	ld	(TransportA_State:8), 1:io	; F00279  ld (0x94),0x01
	calr	TransportA_ResetCounters	; F0027C  calr 0xf00301
Transport_StartAllContinue_Return3:
	ret	; F0027F  ret

; --- 0xF00280-0xF00292, 19 B, converted by lane promB6 (CODE).
;     entry 0x00F00280 (and 0x00F0028D) of the array Transport_StopByRunningMask
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
; Transport_StopCAndA: TransportC_State = 0x0C if C runs and has no stop pending (bit 3), then TransportA_State = 0x0C.  Entry 5 (A and C).
Transport_StopCAndA:
	bit	3, (TransportC_State:8)	; F00280  bit 3,(0x95)
	jr	nz, sub_F001C9_Arm	; F00283  jr NZ,0xf0028d
	bit	2, (TransportC_State:8)	; F00285  bit 2,(0x95)
	jr	z, sub_F001C9_Arm	; F00288  jr Z,0xf0028d
	ld	(TransportC_State:8), 12:io	; F0028A  ld (0x95),0x0c
sub_F001C9_Arm:
	ld	(TransportA_State:8), 12:io	; F0028D  ld (0x94),0x0c
	ret	; F00290  ret
	nop	; F00291  nop
	nop	; F00292  nop

; --------------------------------------------------------------------------
; Transport_StartCAndB
; Reached from: routine-directory slot T_Transport_StartCAndB, each holding `jp 0x00F00293`
;               (the slots are re-read from the ROM on every emit).
; Extent:  10 bytes, 4 instructions, ends `ret`.  The walk marks exactly
;          0xF00293-0xF0029C.  0 bytes (0%) sit in spellings llvm-mc cannot
;          encode and stay `.byte` with the MAME text in the comment.
; Unknown: what the routine is for.  ★ COVERAGE ROUND: this pass converts
;          reachable bytes and defers every semantic question, so the label
;          stays sub_XXXXXX with the gap stated.
; --------------------------------------------------------------------------
; Transport_StartCAndB: TransportC_State = 1, Transport_QueueMidiStartOrContinue, TransportB_State = 1.
Transport_StartCAndB:
	ld	(TransportC_State:8), 1:io	; F00293  ld (0x95),0x01
	calr	Transport_QueueMidiStartOrContinue	; F00296  calr 0xf00320
	ld	(TransportB_State:8), 1:io	; F00299  ld (0x96),0x01
	ret	; F0029C  ret

; --- 0xF0029D-0xF002C8, 44 B, converted by lane promB6 (CODE).
;     entries 0x00F002B9 0x00F002B6 0x00F002B3 of Transport_StopByRunningMask
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	bit	0, (TransportC_State:8)	; F0029D  bit 0,(0x95)
	jr	nz, Transport_StartCAndB_Return	; F002A0  jr NZ,0xf002b0
	bit	2, (TransportC_State:8)	; F002A2  bit 2,(0x95)
	jr	nz, Transport_StartCAndB_Return	; F002A5  jr NZ,0xf002b0
	ld	(TransportC_State:8), 1:io	; F002A7  ld (0x95),0x01
	calr	TransportC_ResetCounters	; F002AA  calr 0xf002f4
	calr	Transport_QueueMidiStartOrContinue	; F002AD  calr 0xf00320
Transport_StartCAndB_Return:
	ret	; F002B0  ret
	nop	; F002B1  nop
	nop	; F002B2  nop
sub_F00293_Arm3:
	ld	(TransportA_State:8), 12:io	; F002B3  ld (0x94),0x0c
sub_F00293_Arm2:
	ld	(TransportB_State:8), 12:io	; F002B6  ld (0x96),0x0c
sub_F00293_Arm:
	bit	3, (TransportC_State:8)	; F002B9  bit 3,(0x95)
	jr	nz, sub_F00293_Arm_Return	; F002BC  jr NZ,0xf002c6
	bit	2, (TransportC_State:8)	; F002BE  bit 2,(0x95)
	jr	z, sub_F00293_Arm_Return	; F002C1  jr Z,0xf002c6
	ld	(TransportC_State:8), 12:io	; F002C3  ld (0x95),0x0c
sub_F00293_Arm_Return:
	ret	; F002C6  ret
	nop	; F002C7  nop
	nop	; F002C8  nop

; --------------------------------------------------------------------------
; TransportB_Stop
; Reached from: routine-directory slot T_TransportB_Stop, each holding `jp 0x00F002C9`
;               (the slots are re-read from the ROM on every emit).
; Extent:  4 bytes, 2 instructions, ends `ret`.  The walk marks exactly
;          0xF002C9-0xF002CC.  0 bytes (0%) sit in spellings llvm-mc cannot
;          encode and stay `.byte` with the MAME text in the comment.
; Unknown: what the routine is for.  ★ COVERAGE ROUND: this pass converts
;          reachable bytes and defers every semantic question, so the label
;          stays sub_XXXXXX with the gap stated.
; --------------------------------------------------------------------------
; TransportB_Stop: TransportB_State = 0x0C.  Transport_StopByRunningMask's entry 2 (only B runs).
TransportB_Stop:
	ld	(TransportB_State:8), 12:io	; F002C9  ld (0x96),0x0c
	ret	; F002CC  ret

; --- 0xF002CD-0xF002F3, 39 B, converted by lane promB6 (CODE).
;     entry 0x00F002EB of Transport_StopByRunningMask
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	nop	; F002CD  nop
	nop	; F002CE  nop
	ld	(TransportA_State:8), 1:io	; F002CF  ld (0x94),0x01
	calr	TransportA_ResetCounters	; F002D2  calr 0xf00301
	bit	0, (TransportC_State:8)	; F002D5  bit 0,(0x95)
	jr	nz, TransportB_Stop_Return	; F002D8  jr NZ,0xf002e8
	bit	2, (TransportC_State:8)	; F002DA  bit 2,(0x95)
	jr	nz, TransportB_Stop_Return	; F002DD  jr NZ,0xf002e8
	ld	(TransportC_State:8), 1:io	; F002DF  ld (0x95),0x01
	calr	TransportC_ResetCounters	; F002E2  calr 0xf002f4
	calr	Transport_QueueMidiStartOrContinue	; F002E5  calr 0xf00320
TransportB_Stop_Return:
	ret	; F002E8  ret
	nop	; F002E9  nop
	nop	; F002EA  nop
sub_F002C9_Arm:
	ld	(TransportB_State:8), 12:io	; F002EB  ld (0x96),0x0c
	ld	(TransportA_State:8), 12:io	; F002EE  ld (0x94),0x0c
	ret	; F002F1  ret
	nop	; F002F2  nop
	nop	; F002F3  nop

; --------------------------------------------------------------------------
; TransportC_ResetCounters
; Reached from: a branch decoded inside this block -- the walk enters 0xF002F4
;               from code it had already reached, not from any table.
; Extent:  75 bytes, 30 instructions, ends `ret`.  The walk marks exactly
;          0xF002F4-0xF0033E.  16 bytes (21%) sit in spellings llvm-mc cannot
;          encode and stay `.byte` with the MAME text in the comment.
; Unknown: what the routine is for.  ★ COVERAGE ROUND: this pass converts
;          reachable bytes and defers every semantic question, so the label
;          stays sub_XXXXXX with the gap stated.
; --------------------------------------------------------------------------
; TransportC_ResetCounters: TransportC_Tick = 0, TransportC_Beat = 0, at interrupt level 6.
TransportC_ResetCounters:
	xor	wa, wa	; F002F4  xor WA,WA
	ei	6	; F002F6  ei 0x06
	ld	(TransportC_Tick:8), a	; F002F8  ld (0x8d),A
	ld	(TransportC_Beat:8), wa	; F002FB  ld (0x8e),WA
	ei	0	; F002FE  ei 0x00
	ret	; F00300  ret
; TransportA_ResetCounters: TransportA_Tick, TransportA_Beat and TransportA_Bar = 0, at interrupt level 6.
TransportA_ResetCounters:
	xor	wa, wa	; F00301  xor WA,WA
	ei	6	; F00303  ei 0x06
	ld	(TransportA_Tick:8), a	; F00305  ld (0x8b),A
	ld	(TransportA_Beat:8), a	; F00308  ld (0x8c),A
	ld	(TransportA_Bar:24), a	; F0030B  ld (0x605002),A
	ei	0	; F00310  ei 0x00
	ret	; F00312  ret
; TransportB_ResetCounters: TransportB_Beat = 0, Seq_BeatTick (B's tick) = 0, at interrupt level 6.
TransportB_ResetCounters:
	xor	wa, wa	; F00313  xor WA,WA
	ei	6	; F00315  ei 0x06
	ld	(TransportB_Beat:8), wa	; F00317  ld (0x91),WA
	ld	(Seq_BeatTick:8), a	; F0031A  ld (0x93),A
	ei	0	; F0031D  ei 0x00
	ret	; F0031F  ret
; Transport_QueueMidiStartOrContinue: when MIDI setting (0x7F34) bit 2 is set: MidiTx_RealtimePending bit 2 (FB CONTINUE) if (0x34BB) bit 3, else bit 1
;   (FA START), then T_MIDI_PostSendWork.
Transport_QueueMidiStartOrContinue:
	bit	2, (0x7f34:16)	; F00320  bit 2,(0x7f34)
	jr	z, sub_F002F4_Return	; F00324  jr Z,0xf0033e
	ei	6	; F00326  ei 0x06
	bit	3, (0x34bb:16)	; F00328  bit 3,(0x34bb)
	jr	z, Transport_QueueMidiStartOrContinue_Skip	; F0032C  jr Z,0xf00334
	or	(MidiTx_RealtimePending:8), 0x04	; F0032E  or (0xa0),0x04
	jr	Transport_QueueMidiStartOrContinue_Join	; F00332  jr T,0xf00338
Transport_QueueMidiStartOrContinue_Skip:
	or	(MidiTx_RealtimePending:8), 0x02	; F00334  or (0xa0),0x02
Transport_QueueMidiStartOrContinue_Join:
	call	T_MIDI_PostSendWork	; F00338  call 0xf40724
sub_F00D24_Code:
	ei	0	; F0033C  ei 0x00
sub_F002F4_Return:
	ret	; F0033E  ret

; --- BEGIN gen_prom_b_f0033f_f0199e 0xF0033F-0xF00800 ---
; ============================================================================
; 0xF0033F-0xF007FF -- FOUR TABLES OF 4-BYTE LITTLE-ENDIAN POINTERS,
; AND THE THREE SHORT BYTE OBJECTS BETWEEN THEM
; ============================================================================
;
; 1,217 bytes.  DATA: 0 `call nnn` / `jp nnn` operands in any of the four
; ROM images land in this span, and 0 routine-directory slots point in.
;
; ⚠ THE COVER-R1 BANNER ABOVE STILL APPLIES AND IS NOT WITHDRAWN: nothing
; the round-1 walk decoded reaches here, so the span is not CODE.  What is
; withdrawn is `unreachable, therefore leave it verbatim'.  Data is typed
; from what REFERENCES it, and every object below is bounded that way.
;
; 290 4-byte little-endian words are each 0x00000000, the repeated sentinel
; 0x00FDB10E, or an address in the 1 MiB CS2 window 0xF00000-0xFFFFFF, out
; of a 16 MiB address space.  At BYTE level they form three uninterrupted
; runs of 35, 216 and 39 slots; the 216-slot run is labelled below as two
; tables, 181 + 35, on a cut that comes from the TARGETS and not the bytes.
;
; ⚠ THE PHASE IS NOT CONSTANT ACROSS THE SPAN, which is why one alignment
; never fit it: scored across the whole span the four byte phases give 222,
; 51, 42 and 6 of ~303.  These are FOUR runs at THREE phases, because the
; byte objects at 0xF003CC (45 B) and 0xF00759 (9 B) are both odd-length.
;
; 0x00FDB10E means ABSENT.  It fills 82 of the 290 slots and is NOT an
; instruction boundary in prom_a: it lands inside `lda xbc,(xiz-12)` at
; 0xFDB10C (be f4 31).  It cannot be entered and cannot start an object.
;
; Re-derive all of it with
;     python3 notes/gen_prom_b_f0033f_f0199e.py --evidence
; ============================================================================

	.byte 0x00	; F0033F  pad: the byte after the `ret` at 0xF0033E,
			;          aligning the table below to a 4-byte boundary

; --------------------------------------------------------------------------
; PtrTable_F00340 -- 35 slots, A ROUTINE VECTOR TABLE
; Evidence: 25 of the 26 distinct targets begin with the byte pair `EE 0C` --
;           `link XIZ,0x0000`, the stack-frame prologue prom_a's transcription
;           spells that way over a hundred times.  Null: that pair occurs at 28
;           of the 744 byte positions in 0xF01200-0xF014E8 (3.8%), so 25 of 26
;           is not chance.  The odd one out is slot [0], 0xF01200, which begins
;           `C9 D8`.
; ⚠ Its target block 0xF01200-0xF014E8 is STILL `.incbin` (the span at file
;   0x000C4D+0x000BB3).  These are 25 proven entry points for whoever converts
;   it; this file converts the TABLE, not the routines.
; Unknown: what the routines do, and what selects a slot.  No reader for this
;          table base has been found -- 0x00F00340 is not a 32-bit word anywhere
;          in the four images -- because the reader indexes from SLOT 17:
;          sub_F00D65 (0xF00D92) does `add xbc, PtrTable_F00340 + 0x44` on
;          XBC = 4*n, then `ld xbc, (xbc)` (claims_lint.py unread-claims,
;          2026-10-02).  A 32-bit 0x00F00380 (slot 16) also sits at 0xF513FB,
;          inside RecordArray_F511DD's records.
; --------------------------------------------------------------------------
; census: stale -- read only inside the orphaned older-build PITCH module (sub_F00D65); its 0xFDB10E slots are that build's prom_a stub, mid-instruction here (notes/FINDINGS-prom_b-f00c4d-orphan-cluster.md).
PtrTable_F00340:
	.long sub_F01200	; F00340  [  0]
	.long OldCopy_SoftKeyCol3_SoundEditPitchEnvelope2	; F00344  [  1]
	.long OldCopy_SoftKeyCol4_SoundEditPitchEnvelope2	; F00348  [  2]
	.long OldCopy_SoftKeyCol5_SoundEditPitchEnvelope2	; F0034C  [  3]
	.long 0x00FDB10E	; F00350  [  4]  absent (sentinel)
	.long OldCopy_SoftKeyCol7_SoundEditPitchEnvelope2	; F00354  [  5]
	.long OldCopy_SoftKeyCol8_SoundEditPitchEnvelope2	; F00358  [  6]
	.long OldCopy_LcdKeyRow1_SoundEditPitchEnvelope2	; F0035C  [  7]
	.long OldCopy_LcdKeyRow2_SoundEditPitchEnvelope2	; F00360  [  8]
	.long OldCopy_LcdKeyRow3_SoundEditPitchEnvelope2	; F00364  [  9]
	.long OldCopy_LcdKeyRow4_SoundEditPitchEnvelope2	; F00368  [ 10]
	.long OldCopy_LcdKeyRow5_SoundEditPitchEnvelope2	; F0036C  [ 11]
	.long 0x00FDB10E	; F00370  [ 12]  absent (sentinel)
	.long 0x00FDB10E	; F00374  [ 13]  absent (sentinel)
	.long OldCopy_ExitKey_SoundEditPitchEnvelope2	; F00378  [ 14]
	.long OldCopy_PageKey_SoundEditPitchEnvelope2	; F0037C  [ 15]
	.long 0x00000000	; F00380  [ 16]  empty
	.long 0x00FDB10E	; F00384  [ 17]  absent (sentinel)
	.long OldCopy_SoftKeyCol2_SoundEditPitchLfo	; F00388  [ 18]
	.long OldCopy_SoftKeyCol3_SoundEditPitchLfo	; F0038C  [ 19]
	.long OldCopy_SoftKeyCol4_SoundEditPitchLfo	; F00390  [ 20]
	.long OldCopy_SoftKeyCol5_SoundEditPitchLfo	; F00394  [ 21]
	.long OldCopy_SoftKeyCol6_SoundEditPitchLfo	; F00398  [ 22]
	.long OldCopy_SoftKeyCol7_SoundEditPitchLfo	; F0039C  [ 23]
	.long OldCopy_SoftKeyCol8_SoundEditPitchLfo	; F003A0  [ 24]
	.long OldCopy_LcdKeyRow1_SoundEditPitchLfo	; F003A4  [ 25]
	.long OldCopy_LcdKeyRow2_SoundEditPitchLfo	; F003A8  [ 26]
	.long OldCopy_LcdKeyRow3_SoundEditPitchLfo	; F003AC  [ 27]
	.long OldCopy_LcdKeyRow4_SoundEditPitchLfo	; F003B0  [ 28]
	.long OldCopy_LcdKeyRow5_SoundEditPitchLfo	; F003B4  [ 29]
	.long 0x00FDB10E	; F003B8  [ 30]  absent (sentinel)
	.long 0x00FDB10E	; F003BC  [ 31]  absent (sentinel)
	.long OldCopy_ExitKey_SoundEditPitchLfo	; F003C0  [ 32]
	.long 0x00FDB10E	; F003C4  [ 33]  absent (sentinel)
	.long 0x00000000	; F003C8  [ 34]  empty

; --------------------------------------------------------------------------
; Data_F003CC -- 45 bytes, EMITTED AS DATA.  ⚠ SHAPE NOT ESTABLISHED.
; Evidence: it is bounded on both sides -- the pointer run above ends at
;           0xF003CB and the one below begins at 0xF003F9 -- and its own
;           content is small ascending indices, not addresses.  Nothing
;           names it and no consumer has been found.
; Measured: three groups separated by zero padding, printed one per line
;           below.  The line breaks are a READING and are not proven; the
;           bytes are the ROM's.  The third group is 13 bytes, not the 16
;           the first two are, so `three 16-byte rows' is WRONG and is not
;           claimed.
; --------------------------------------------------------------------------
Data_F003CC:
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F003CC  00-05, then zero padding
	.byte 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F003DC  06-0C, then zero padding
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16	; F003EC  00-05 then 10-16

; --------------------------------------------------------------------------
; PtrTable_F003F9 -- 181 slots: ROWS 0-9 (AND ROW 10's FIRST SLOT) OF AN
;                    18-COLUMN TABLE THAT NOTHING IN THE MACHINE READS
;
; ⚠ THIS HEADER REPLACES ONE THAT CALLED THIS TABLE "THE INDEX OF THE
;   0xF78029 BITMAP SHEET".  It is not that.  The sheet at 0xF78028 is 119
;   cells of 24x24 on the 72-byte grid DLHandler_Glyph24x24 (0xF31ACE)
;   computes, and:
;     * exactly 1 of this table's 121 targets in the sheet is a multiple of 72
;       from 0xF78028, against 1.7 expected by chance -- the targets carry NO
;       information about the grid;
;     * the sheet ends exactly on that grid (0xF7A1A0 - 0xF78028 = 8568 =
;       119 * 72, remainder 0) and the highest index any op-0x23 display-list
;       record carries is 118, i.e. 119 cells.
;   The 110 `Bitmap_F78*` labels these targets used to bound are gone; see the
;   banner at 0xF78028 and notes/gen_prom_b_f78028_icon_sheet.py --evidence.
;
; WHAT IT IS, as far as it can honestly be taken.  216 consecutive 4-byte LE
; slots run 0xF003F9-0xF00758, and they are shaped 18 COLUMNS x 12 ROWS:
;     * column 17 is 0x00000000 in every one of the 12 rows;
;     * columns 13 and 14 are the 0x00FDB10E filler in every row;
;     * columns 15 and 16 are always in DESCENDING address order;
;     * the delta between consecutive targets is near-constant DOWN a column
;       (column 15 is 52 bytes in six successive rows, then 32 in three).
;   Rows 0-9 point into the icon sheet; rows 10-11 point into prom_a's
;   DisplayList_FC4000 and carry the same column pattern.  ⚠ The label
;   boundary at 0xF006CD below is a LEGACY CUT, not a structural one -- row 10
;   begins one slot earlier, at 0xF006C9.  The `rNNcNN` in each slot comment is
;   that row and column.
;
; ⚠ AND IT RESOLVES TO NOTHING IN EITHER REGION IT POINTS AT.  For the prom_a
;   half see PtrTable_F006CD's header (3 of 24 targets on a proven record
;   boundary, against 1.8 by chance).  No immediate in any of the four ROM
;   images equals 0xF003F9 or 0xF006CD, so no reader has been found either.
;   THE CONTROL, which says this instrument can still recognise a live table:
;   the table 185 bytes earlier at 0xF00340 IS dispatched (`add XBC,0x00F0033C`
;   at 0xF00D51 and `add XBC,0x00F00384` at 0xF00D92) and 25 of its 26 distinct
;   targets begin `EE 0C` = `link XIZ,0x0000`, a function prologue.
;
; Open research target, sharper than the one it replaces: not "what is in the
; icon sheet" (119 icons) but WHAT THESE 216 SLOTS INDEXED, given that in this
; build they land at chance level in both regions they name and the 0x00FDB10E
; filler is not even an instruction boundary (it is the second byte of
; `lda XBC,(XIZ-12)` at prom_a 0xFDB10C).  A vestigial index left by the
; authoring tool after the resources were relaid out is the obvious hypothesis
; and there is no second build of this firmware to test it against.
; --------------------------------------------------------------------------
PtrTable_F003F9:
	.long DLGlyph_008_F78268 + 0x22	; F003F9  [  0]  r0c0
	.long DLGlyph_011_F78340 + 0x6	; F003FD  [  1]  r0c1
	.long DLGlyph_013_F783D0 + 0x32	; F00401  [  2]  r0c2
	.long DLGlyph_016_F784A8 + 0xA	; F00405  [  3]  r0c3
	.long 0x00FDB10E	; F00409  [  4]  absent (sentinel)  r0c4
	.long DLGlyph_018_F78538 + 0x2A	; F0040D  [  5]  r0c5
	.long DLGlyph_020_F785C8 + 0x34	; F00411  [  6]  r0c6
	.long DLGlyph_022_F78658 + 0x3F	; F00415  [  7]  r0c7
	.long DLGlyph_025_F78730 + 0x2	; F00419  [  8]  r0c8
	.long DLGlyph_025_F78730 + 0x2F	; F0041D  [  9]  r0c9
	.long DLGlyph_026_F78778 + 0xB	; F00421  [ 10]  r0c10
	.long DLGlyph_026_F78778 + 0x46	; F00425  [ 11]  r0c11
	.long DLGlyph_028_F78808 + 0x10	; F00429  [ 12]  r0c12
	.long 0x00FDB10E	; F0042D  [ 13]  absent (sentinel)  r0c13
	.long 0x00FDB10E	; F00431  [ 14]  absent (sentinel)  r0c14
	.long DLGlyph_029_F78850 + 0x22	; F00435  [ 15]  r0c15
	.long DLGlyph_028_F78808 + 0x43	; F00439  [ 16]  r0c16
	.long 0x00000000	; F0043D  [ 17]  empty  r0c17
	.long DLGlyph_030_F78898 + 0xE	; F00441  [ 18]  r1c0
	.long DLGlyph_030_F78898 + 0x32	; F00445  [ 19]  r1c1
	.long DLGlyph_031_F788E0 + 0xE	; F00449  [ 20]  r1c2
	.long DLGlyph_031_F788E0 + 0x26	; F0044D  [ 21]  r1c3
	.long 0x00FDB10E	; F00451  [ 22]  absent (sentinel)  r1c4
	.long DLGlyph_031_F788E0 + 0x3E	; F00455  [ 23]  r1c5
	.long DLGlyph_032_F78928 + 0x7	; F00459  [ 24]  r1c6
	.long DLGlyph_032_F78928 + 0x18	; F0045D  [ 25]  r1c7
	.long DLGlyph_032_F78928 + 0x29	; F00461  [ 26]  r1c8
	.long DLGlyph_032_F78928 + 0x3A	; F00465  [ 27]  r1c9
	.long DLGlyph_033_F78970 + 0x3	; F00469  [ 28]  r1c10
	.long DLGlyph_033_F78970 + 0x14	; F0046D  [ 29]  r1c11
	.long DLGlyph_034_F789B8 + 0x26	; F00471  [ 30]  r1c12
	.long 0x00FDB10E	; F00475  [ 31]  absent (sentinel)  r1c13
	.long 0x00FDB10E	; F00479  [ 32]  absent (sentinel)  r1c14
	.long DLGlyph_035_F78A00 + 0x16	; F0047D  [ 33]  r1c15
	.long DLGlyph_034_F789B8 + 0x37	; F00481  [ 34]  r1c16
	.long 0x00000000	; F00485  [ 35]  empty  r1c17
	.long 0x00FDB10E	; F00489  [ 36]  absent (sentinel)  r2c0
	.long 0x00FDB10E	; F0048D  [ 37]  absent (sentinel)  r2c1
	.long DLGlyph_036_F78A48 + 0x2	; F00491  [ 38]  r2c2
	.long DLGlyph_036_F78A48 + 0x26	; F00495  [ 39]  r2c3
	.long DLGlyph_037_F78A90 + 0x2	; F00499  [ 40]  r2c4
	.long DLGlyph_037_F78A90 + 0x1A	; F0049D  [ 41]  r2c5
	.long 0x00FDB10E	; F004A1  [ 42]  absent (sentinel)  r2c6
	.long 0x00FDB10E	; F004A5  [ 43]  absent (sentinel)  r2c7
	.long DLGlyph_037_F78A90 + 0x32	; F004A9  [ 44]  r2c8
	.long DLGlyph_038_F78AD8 + 0x17	; F004AD  [ 45]  r2c9
	.long DLGlyph_038_F78AD8 + 0x3B	; F004B1  [ 46]  r2c10
	.long DLGlyph_039_F78B20 + 0x2E	; F004B5  [ 47]  r2c11
	.long DLGlyph_040_F78B68 + 0x40	; F004B9  [ 48]  r2c12
	.long 0x00FDB10E	; F004BD  [ 49]  absent (sentinel)  r2c13
	.long 0x00FDB10E	; F004C1  [ 50]  absent (sentinel)  r2c14
	.long DLGlyph_042_F78BF8 + 0xA	; F004C5  [ 51]  r2c15
	.long DLGlyph_041_F78BB0 + 0x2B	; F004C9  [ 52]  r2c16
	.long 0x00000000	; F004CD  [ 53]  empty  r2c17
	.long 0x00FDB10E	; F004D1  [ 54]  absent (sentinel)  r3c0
	.long 0x00FDB10E	; F004D5  [ 55]  absent (sentinel)  r3c1
	.long DLGlyph_042_F78BF8 + 0x3E	; F004D9  [ 56]  r3c2
	.long DLGlyph_043_F78C40 + 0x1A	; F004DD  [ 57]  r3c3
	.long DLGlyph_043_F78C40 + 0x3E	; F004E1  [ 58]  r3c4
	.long DLGlyph_044_F78C88 + 0xE	; F004E5  [ 59]  r3c5
	.long 0x00FDB10E	; F004E9  [ 60]  absent (sentinel)  r3c6
	.long 0x00FDB10E	; F004ED  [ 61]  absent (sentinel)  r3c7
	.long DLGlyph_044_F78C88 + 0x26	; F004F1  [ 62]  r3c8
	.long DLGlyph_044_F78C88 + 0x37	; F004F5  [ 63]  r3c9
	.long DLGlyph_045_F78CD0	; F004F9  [ 64]  r3c10
	.long DLGlyph_045_F78CD0 + 0x11	; F004FD  [ 65]  r3c11
	.long DLGlyph_046_F78D18 + 0x23	; F00501  [ 66]  r3c12
	.long 0x00FDB10E	; F00505  [ 67]  absent (sentinel)  r3c13
	.long 0x00FDB10E	; F00509  [ 68]  absent (sentinel)  r3c14
	.long DLGlyph_047_F78D60 + 0x13	; F0050D  [ 69]  r3c15
	.long DLGlyph_046_F78D18 + 0x34	; F00511  [ 70]  r3c16
	.long 0x00000000	; F00515  [ 71]  empty  r3c17
	.long 0x00FDB10E	; F00519  [ 72]  absent (sentinel)  r4c0
	.long DLGlyph_047_F78D60 + 0x47	; F0051D  [ 73]  r4c1
	.long DLGlyph_050_F78E38 + 0x14	; F00521  [ 74]  r4c2
	.long DLGlyph_050_F78E38 + 0x30	; F00525  [ 75]  r4c3
	.long DLGlyph_052_F78EC8 + 0x41	; F00529  [ 76]  r4c4
	.long DLGlyph_054_F78F58 + 0x43	; F0052D  [ 77]  r4c5
	.long DLGlyph_055_F78FA0 + 0x13	; F00531  [ 78]  r4c6
	.long 0x00FDB10E	; F00535  [ 79]  absent (sentinel)  r4c7
	.long DLGlyph_055_F78FA0 + 0x2B	; F00539  [ 80]  r4c8
	.long DLGlyph_056_F78FE8 + 0x10	; F0053D  [ 81]  r4c9
	.long DLGlyph_056_F78FE8 + 0x34	; F00541  [ 82]  r4c10
	.long DLGlyph_057_F79030 + 0x27	; F00545  [ 83]  r4c11
	.long DLGlyph_058_F79078 + 0x2F	; F00549  [ 84]  r4c12
	.long 0x00FDB10E	; F0054D  [ 85]  absent (sentinel)  r4c13
	.long 0x00FDB10E	; F00551  [ 86]  absent (sentinel)  r4c14
	.long DLGlyph_059_F790C0 + 0x41	; F00555  [ 87]  r4c15
	.long DLGlyph_059_F790C0 + 0x1A	; F00559  [ 88]  r4c16
	.long 0x00000000	; F0055D  [ 89]  empty  r4c17
	.long 0x00FDB10E	; F00561  [ 90]  absent (sentinel)  r5c0
	.long 0x00FDB10E	; F00565  [ 91]  absent (sentinel)  r5c1
	.long 0x00FDB10E	; F00569  [ 92]  absent (sentinel)  r5c2
	.long 0x00FDB10E	; F0056D  [ 93]  absent (sentinel)  r5c3
	.long 0x00FDB10E	; F00571  [ 94]  absent (sentinel)  r5c4
	.long 0x00FDB10E	; F00575  [ 95]  absent (sentinel)  r5c5
	.long 0x00FDB10E	; F00579  [ 96]  absent (sentinel)  r5c6
	.long 0x00FDB10E	; F0057D  [ 97]  absent (sentinel)  r5c7
	.long DLGlyph_060_F79108 + 0x2D	; F00581  [ 98]  r5c8
	.long DLGlyph_061_F79150 + 0x12	; F00585  [ 99]  r5c9
	.long DLGlyph_061_F79150 + 0x36	; F00589  [100]  r5c10
	.long DLGlyph_062_F79198 + 0x29	; F0058D  [101]  r5c11
	.long DLGlyph_063_F791E0 + 0x3B	; F00591  [102]  r5c12
	.long 0x00FDB10E	; F00595  [103]  absent (sentinel)  r5c13
	.long 0x00FDB10E	; F00599  [104]  absent (sentinel)  r5c14
	.long DLGlyph_065_F79270 + 0x5	; F0059D  [105]  r5c15
	.long DLGlyph_064_F79228 + 0x26	; F005A1  [106]  r5c16
	.long 0x00000000	; F005A5  [107]  empty  r5c17
	.long 0x00FDB10E	; F005A9  [108]  absent (sentinel)  r6c0
	.long 0x00FDB10E	; F005AD  [109]  absent (sentinel)  r6c1
	.long DLGlyph_065_F79270 + 0x39	; F005B1  [110]  r6c2
	.long DLGlyph_067_F79300 + 0x34	; F005B5  [111]  r6c3
	.long DLGlyph_069_F79390 + 0x1F	; F005B9  [112]  r6c4
	.long DLGlyph_071_F79420 + 0x2F	; F005BD  [113]  r6c5
	.long 0x00FDB10E	; F005C1  [114]  absent (sentinel)  r6c6
	.long 0x00FDB10E	; F005C5  [115]  absent (sentinel)  r6c7
	.long DLGlyph_073_F794B0 + 0x1A	; F005C9  [116]  r6c8
	.long DLGlyph_073_F794B0 + 0x38	; F005CD  [117]  r6c9
	.long DLGlyph_074_F794F8 + 0x14	; F005D1  [118]  r6c10
	.long DLGlyph_074_F794F8 + 0x40	; F005D5  [119]  r6c11
	.long DLGlyph_075_F79540 + 0x1C	; F005D9  [120]  r6c12
	.long 0x00FDB10E	; F005DD  [121]  absent (sentinel)  r6c13
	.long 0x00FDB10E	; F005E1  [122]  absent (sentinel)  r6c14
	.long DLGlyph_076_F79588 + 0x10	; F005E5  [123]  r6c15
	.long DLGlyph_075_F79540 + 0x40	; F005E9  [124]  r6c16
	.long 0x00000000	; F005ED  [125]  empty  r6c17
	.long DLGlyph_076_F79588 + 0x30	; F005F1  [126]  r7c0
	.long DLGlyph_077_F795D0 + 0x1	; F005F5  [127]  r7c1
	.long DLGlyph_077_F795D0 + 0x1A	; F005F9  [128]  r7c2
	.long DLGlyph_077_F795D0 + 0x33	; F005FD  [129]  r7c3
	.long DLGlyph_078_F79618 + 0x4	; F00601  [130]  r7c4
	.long DLGlyph_078_F79618 + 0x1D	; F00605  [131]  r7c5
	.long DLGlyph_078_F79618 + 0x36	; F00609  [132]  r7c6
	.long 0x00FDB10E	; F0060D  [133]  absent (sentinel)  r7c7
	.long DLGlyph_079_F79660 + 0x7	; F00611  [134]  r7c8
	.long DLGlyph_079_F79660 + 0x18	; F00615  [135]  r7c9
	.long DLGlyph_079_F79660 + 0x44	; F00619  [136]  r7c10
	.long DLGlyph_080_F796A8 + 0x28	; F0061D  [137]  r7c11
	.long DLGlyph_081_F796F0 + 0xE	; F00621  [138]  r7c12
	.long 0x00FDB10E	; F00625  [139]  absent (sentinel)  r7c13
	.long 0x00FDB10E	; F00629  [140]  absent (sentinel)  r7c14
	.long DLGlyph_082_F79738 + 0xC	; F0062D  [141]  r7c15
	.long DLGlyph_081_F796F0 + 0x3C	; F00631  [142]  r7c16
	.long 0x00000000	; F00635  [143]  empty  r7c17
	.long 0x00FDB10E	; F00639  [144]  absent (sentinel)  r8c0
	.long DLGlyph_082_F79738 + 0x2C	; F0063D  [145]  r8c1
	.long DLGlyph_082_F79738 + 0x41	; F00641  [146]  r8c2
	.long DLGlyph_083_F79780 + 0xE	; F00645  [147]  r8c3
	.long DLGlyph_083_F79780 + 0x23	; F00649  [148]  r8c4
	.long 0x00FDB10E	; F0064D  [149]  absent (sentinel)  r8c5
	.long DLGlyph_083_F79780 + 0x38	; F00651  [150]  r8c6
	.long DLGlyph_084_F797C8 + 0x5	; F00655  [151]  r8c7
	.long DLGlyph_084_F797C8 + 0x1A	; F00659  [152]  r8c8
	.long DLGlyph_084_F797C8 + 0x2B	; F0065D  [153]  r8c9
	.long DLGlyph_085_F79810 + 0xF	; F00661  [154]  r8c10
	.long DLGlyph_085_F79810 + 0x3B	; F00665  [155]  r8c11
	.long DLGlyph_086_F79858 + 0x17	; F00669  [156]  r8c12
	.long 0x00FDB10E	; F0066D  [157]  absent (sentinel)  r8c13
	.long 0x00FDB10E	; F00671  [158]  absent (sentinel)  r8c14
	.long DLGlyph_087_F798A0 + 0xB	; F00675  [159]  r8c15
	.long DLGlyph_086_F79858 + 0x3B	; F00679  [160]  r8c16
	.long 0x00000000	; F0067D  [161]  empty  r8c17
	.long 0x00FDB10E	; F00681  [162]  absent (sentinel)  r9c0
	.long DLGlyph_087_F798A0 + 0x2B	; F00685  [163]  r9c1
	.long DLGlyph_087_F798A0 + 0x40	; F00689  [164]  r9c2
	.long DLGlyph_088_F798E8 + 0xD	; F0068D  [165]  r9c3
	.long DLGlyph_088_F798E8 + 0x22	; F00691  [166]  r9c4
	.long DLGlyph_088_F798E8 + 0x37	; F00695  [167]  r9c5
	.long DLGlyph_089_F79930 + 0x4	; F00699  [168]  r9c6
	.long DLGlyph_089_F79930 + 0x19	; F0069D  [169]  r9c7
	.long DLGlyph_089_F79930 + 0x2E	; F006A1  [170]  r9c8
	.long DLGlyph_090_F79978 + 0x4	; F006A5  [171]  r9c9
	.long DLGlyph_090_F79978 + 0x28	; F006A9  [172]  r9c10
	.long DLGlyph_090_F79978 + 0x40	; F006AD  [173]  r9c11
	.long DLGlyph_091_F799C0 + 0x10	; F006B1  [174]  r9c12
	.long 0x00FDB10E	; F006B5  [175]  absent (sentinel)  r9c13
	.long 0x00FDB10E	; F006B9  [176]  absent (sentinel)  r9c14
	.long DLGlyph_091_F799C0 + 0x28	; F006BD  [177]  r9c15
	.long 0x00FDB10E	; F006C1  [178]  absent (sentinel)  r9c16
	.long 0x00000000	; F006C5  [179]  empty  r9c17
	.long 0x00FDB10E	; F006C9  [180]  absent (sentinel)  r10c0

; --------------------------------------------------------------------------
; PtrTable_F006CD -- 35 slots: the rest of rows 10-11 of the 18-column table
;                    that starts at PtrTable_F003F9 (row 10 begins one slot
;                    earlier, at 0xF006C9; this label boundary is a legacy cut)
; Evidence: 24 distinct targets, all in 0xFC4082-0xFC4454, which prom_a's
;           source already carries as DisplayList_FC4000 (2,095 bytes of
;           DSP-effect / SOUND EDIT label text).  9 slots are the sentinel and
;           2 are zero.
; ⚠ THE TARGETS ARE NOT OBJECT STARTS THERE.  prom_a's framing of that region
;   IS proven -- a strict op/len walk from 0xFC4000 reaches 0xFC482F with zero
;   resyncs, 155 records -- and only 3 of these 24 targets land on a record
;   boundary, against 1.8 expected by chance (155 boundaries in 2,095 bytes).
;   So this table indexes neither the display list here nor the 0xF78028 icon
;   sheet its sibling half points at; see PtrTable_F003F9's header for the
;   sheet half, the 18x12 shape, and the control that shows the test can still
;   recognise a live table.
;   (The header this replaces said "0 of the 24 is an instruction boundary
;   there -- correct, since prom_a frames it as data too".  That is true and
;   beside the point: the question for a data region is whether they are RECORD
;   boundaries, and they are not.)
; Unknown: what selects a slot.  No reader found -- no immediate in any of the
;          four ROM images equals 0xF003F9 or 0xF006CD.
; --------------------------------------------------------------------------
PtrTable_F006CD:
	.long 0x00FC4082	; F006CD  [  0]  r10c1
	.long 0x00FDB10E	; F006D1  [  1]  absent (sentinel)  r10c2
	.long 0x00FC4097	; F006D5  [  2]  r10c3
	.long 0x00FC40A9	; F006D9  [  3]  r10c4
	.long 0x00FC40BE	; F006DD  [  4]  r10c5
	.long 0x00FC40D3	; F006E1  [  5]  r10c6
	.long 0x00FC40F7	; F006E5  [  6]  r10c7
	.long 0x00FDB10E	; F006E9  [  7]  absent (sentinel)  r10c8
	.long 0x00FC411B	; F006ED  [  8]  r10c9
	.long 0x00FC415C	; F006F1  [  9]  r10c10
	.long 0x00FC419D	; F006F5  [ 10]  r10c11
	.long 0x00FDB10E	; F006F9  [ 11]  absent (sentinel)  r10c12
	.long 0x00FDB10E	; F006FD  [ 12]  absent (sentinel)  r10c13
	.long 0x00FDB10E	; F00701  [ 13]  absent (sentinel)  r10c14
	.long 0x00FC423D	; F00705  [ 14]  r10c15
	.long 0x00FC4225	; F00709  [ 15]  r10c16
	.long 0x00000000	; F0070D  [ 16]  empty  r10c17
	.long 0x00FDB10E	; F00711  [ 17]  absent (sentinel)  r11c0
	.long 0x00FC4269	; F00715  [ 18]  r11c1
	.long 0x00FDB10E	; F00719  [ 19]  absent (sentinel)  r11c2
	.long 0x00FC427E	; F0071D  [ 20]  r11c3
	.long 0x00FC4290	; F00721  [ 21]  r11c4
	.long 0x00FC42A5	; F00725  [ 22]  r11c5
	.long 0x00FC42BA	; F00729  [ 23]  r11c6
	.long 0x00FC42DE	; F0072D  [ 24]  r11c7
	.long 0x00FC4302	; F00731  [ 25]  r11c8
	.long 0x00FC4338	; F00735  [ 26]  r11c9
	.long 0x00FC4379	; F00739  [ 27]  r11c10
	.long 0x00FC43BA	; F0073D  [ 28]  r11c11
	.long 0x00FC43FB	; F00741  [ 29]  r11c12
	.long 0x00FDB10E	; F00745  [ 30]  absent (sentinel)  r11c13
	.long 0x00FDB10E	; F00749  [ 31]  absent (sentinel)  r11c14
	.long 0x00FC4454	; F0074D  [ 32]  r11c15
	.long 0x00FC443C	; F00751  [ 33]  r11c16
	.long 0x00000000	; F00755  [ 34]  empty  r11c17

; --------------------------------------------------------------------------
; Data_F00759 -- 9 bytes: the eight powers of two, then one 0x00
; Evidence: bounded by the pointer runs on either side.  The values are
;           0x01 0x02 0x04 0x08 0x10 0x20 0x40 0x80 -- a single-bit mask
;           per index, the shape a bit-numbered lookup has.  The trailing
;           0x00 is what restores the 4-byte phase for the run below.
; Unknown: what indexes it.  No reader found.
; --------------------------------------------------------------------------
Data_F00759:
	.byte 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80	; F00759  1 << 0 .. 1 << 7
	.byte 0x00	; F00761  phase pad

; --------------------------------------------------------------------------
; PtrTable_F00762 -- 39 slots -> prom_a 0xFE28B2-0xFE2F8C
; Evidence: 21 distinct targets, all inside a 1,755-byte prom_a window; 16
;           slots are the sentinel and 2 are zero.  The SLOTS are pointers
;           on the same 290-word test as the rest of the span.
; ⚠ WHAT THE TARGETS ARE IS NOT ESTABLISHED.  prom_a's current transcription
;   frames 0xFE28B2-0xFE2F8C as CODE, but only 6 of the 21 targets land on an
;   instruction boundary there -- against 35.7% of ALL addresses in that range,
;   i.e. BELOW chance.  So this table lends prom_a's framing no support, and no
;   claim is made here about whether that region is code or data.  A prom_a
;   lane should look: 21 pointers into a span is what an object index looks
;   like, and 6/21 is what a misframe looks like.
;   ⚠ AND IT IS THE THIRD TABLE IN THIS SPAN TO FAIL THAT WAY.  PtrTable_F003F9
;   misses the 0xF78028 icon sheet's grid (1 of 121 on it, chance 1.7) and
;   PtrTable_F006CD misses DisplayList_FC4000's record boundaries (3 of 24,
;   chance 1.8).  Three of the four tables in 0xF0033F-0xF007FF point at
;   nothing that any proven framing recognises, and only the first -- the
;   dispatch table at 0xF00340 -- has a consumer at all.  Whatever that says
;   about this span, it is a property of the SPAN and not of one table, and
;   whoever picks it up should treat all three together.
; --------------------------------------------------------------------------
; census: stale -- nothing in the image reads it; its sentinel 0xFDB10E is the older build's stub (PtrTable_F00340), and 6 of its 21 distinct targets land on instruction starts, chance level.
PtrTable_F00762:
	.long 0x00FDB10E	; F00762  [  0]  absent (sentinel)
	.long 0x00FE28B2	; F00766  [  1]
	.long 0x00FE2947	; F0076A  [  2]
	.long 0x00FDB10E	; F0076E  [  3]  absent (sentinel)
	.long 0x00FE29BB	; F00772  [  4]
	.long 0x00FE2A43	; F00776  [  5]
	.long 0x00FE2AB1	; F0077A  [  6]
	.long 0x00FDB10E	; F0077E  [  7]  absent (sentinel)
	.long 0x00FE2B23	; F00782  [  8]
	.long 0x00FE2B34	; F00786  [  9]
	.long 0x00FE2B5D	; F0078A  [ 10]
	.long 0x00FE2B86	; F0078E  [ 11]
	.long 0x00FE2BAF	; F00792  [ 12]
	.long 0x00FDB10E	; F00796  [ 13]  absent (sentinel)
	.long 0x00FDB10E	; F0079A  [ 14]  absent (sentinel)
	.long 0x00FE2BCB	; F0079E  [ 15]
	.long 0x00FDB10E	; F007A2  [ 16]  absent (sentinel)
	.long 0x00000000	; F007A6  [ 17]  empty
	.long 0x00FDB10E	; F007AA  [ 18]  absent (sentinel)
	.long 0x00FE2BE3	; F007AE  [ 19]
	.long 0x00FE2D92	; F007B2  [ 20]
	.long 0x00FE2D14	; F007B6  [ 21]
	.long 0x00FDB10E	; F007BA  [ 22]  absent (sentinel)
	.long 0x00FDB10E	; F007BE  [ 23]  absent (sentinel)
	.long 0x00FDB10E	; F007C2  [ 24]  absent (sentinel)
	.long 0x00FDB10E	; F007C6  [ 25]  absent (sentinel)
	.long 0x00FE2E6E	; F007CA  [ 26]
	.long 0x00FE2EAA	; F007CE  [ 27]
	.long 0x00FE2ED3	; F007D2  [ 28]
	.long 0x00FE2EFC	; F007D6  [ 29]
	.long 0x00FE2F43	; F007DA  [ 30]
	.long 0x00FDB10E	; F007DE  [ 31]  absent (sentinel)
	.long 0x00FDB10E	; F007E2  [ 32]  absent (sentinel)
	.long 0x00FE2F6C	; F007E6  [ 33]
	.long 0x00FDB10E	; F007EA  [ 34]  absent (sentinel)
	.long 0x00000000	; F007EE  [ 35]  empty
	.long 0x00FDB10E	; F007F2  [ 36]  absent (sentinel)
	.long 0x00FDB10E	; F007F6  [ 37]  absent (sentinel)
	.long 0x00FE2F8C	; F007FA  [ 38]

; --------------------------------------------------------------------------
; Data_F007FE -- 2 bytes.  ⚠ NOT IDENTIFIED.
; Evidence: they complete no 4-byte slot (the run above ends at 0xF007FD)
;           and they are not a plausible slot themselves.  They sit
;           immediately below sub_F00800, which starts on the 0x800
;           boundary, so `padding to the module boundary' fits -- but the
;           image's filler byte is 0x0E and only the first of the two is,
;           so that is a guess and is not asserted.
; --------------------------------------------------------------------------
Data_F007FE:
	.byte 0x0E, 0x30	; F007FE  purpose unknown
; --- END gen_prom_b_f0033f_f0199e 0xF0033F-0xF00800 ---


; --------------------------------------------------------------------------
; sub_F00800
; Reached from: routine-directory slots T_F40970 T_F40974 T_F40978 T_F4097C
;               T_F40980, each holding `jp 0x00F00800` (the slots are re-read
;               from the ROM on every emit).
; Extent:  840 bytes, 272 instructions, ends `ret`.  The walk marks exactly
;          0xF00800-0xF00B47.  125 bytes (15%) sit in spellings llvm-mc cannot
;          encode and stay `.byte` with the MAME text in the comment.
; Unknown: what the routine is for.  ★ COVERAGE ROUND: this pass converts
;          reachable bytes and defers every semantic question, so the label
;          stays sub_XXXXXX with the gap stated.
; --------------------------------------------------------------------------
sub_F00800:
	ei	6	; F00800  ei 0x06
	ld	a, (TransportB_State:8)	; F00802  ld A,(0x96)
	ei	0	; F00805  ei 0x00
	ld	w, (6311962:24)	; F00807  ld W,(0x60501a)
	ld	(6311962:24), a	; F0080C  ld (0x60501a),A
	and	a, 4	; F00811  and A,0x04
	and	w, 4	; F00814  and W,0x04
	cp	w, a	; F00817  cp W,A
	jr	z, sub_F00800_Skip	; F00819  jr Z,0xf00822
	cp	a, 0:i3	; F0081B  cp A,0
	jr	nz, sub_F00800_Skip	; F0081D  jr NZ,0xf00822
	calr	Var20D4_ClearBitsC0	; F0081F  calr 0xf009a8
sub_F00800_Skip:
	bit	2, (TransportB_State:8)	; F00822  bit 2,(0x96)
	jr	z, sub_F00800_Skip2	; F00825  jr Z,0xf0082a
	calr	sub_F00895	; F00827  calr 0xf00895
sub_F00800_Skip2:
	calr	sub_F0082E	; F0082A  calr 0xf0082e
	ret	; F0082D  ret
sub_F0082E:
	bit	2, (TransportA_State:8)	; F0082E  bit 2,(0x94)
	jr	z, sub_F0082E_Return	; F00831  jr Z,0xf00894
	ld	xwa, (12288:16)	; F00833  ld XWA,(0x3000)
	cp	xwa, 0	; F00837  cp XWA,0x00000000
	jr	z, sub_F0082E_Return	; F0083D  jr Z,0xf00894
	ei	6	; F0083F  ei 0x06
	ld	a, (TransportA_Bar:24)	; F00841  ld A,(0x605002)
	ld	(6311953:24), a	; F00846  ld (0x605011),A
	ld	a, (TransportA_Beat:8)	; F0084B  ld A,(0x8c)
	ld	(6311954:24), a	; F0084E  ld (0x605012),A
	ld	a, (TransportA_Tick:8)	; F00853  ld A,(0x8b)
	ld	(6311955:24), a	; F00856  ld (0x605013),A
	ld	a, (TransportA_State:8)	; F0085B  ld A,(0x94)
	ld	(6311959:24), a	; F0085E  ld (0x605017),A
	ei	0	; F00863  ei 0x00
sub_F0082E_Join:
	calr	sub_F009AE	; F00865  calr 0xf009ae
	calr	sub_F00A31	; F00868  calr 0xf00a31
	cp	a, 1:i3	; F0086B  cp A,1
	jr	nz, sub_F0082E_Skip	; F0086D  jr NZ,0xf00879
	inc	1, (6311961:24)	; F0086F  inc 1,(0x605019)
	calr	sub_F00AA5	; F00874  calr 0xf00aa5
	jr	sub_F0082E_Join	; F00877  jr T,0xf00865
sub_F0082E_Skip:
	bit	2, (0x605017:24)	; F00879  bit 2,(0x605017)
	jr	nz, sub_F0082E_Skip2	; F0087E  jr NZ,0xf0088a
	bit	2, (0x605018:24)	; F00880  bit 2,(0x605018)
	jr	z, sub_F0082E_Skip2	; F00885  jr Z,0xf0088a
	calr	sub_F00ADD	; F00887  calr 0xf00add
sub_F0082E_Skip2:
	ld	a, (6311959:24)	; F0088A  ld A,(0x605017)
	ld	(6311960:24), a	; F0088F  ld (0x605018),A
sub_F0082E_Return:
	ret	; F00894  ret
sub_F00895:
	ld	wa, (13650:16)	; F00895  ld WA,(0x3552)
	ld	bc, (TransportB_Beat:8)	; F00899  ld BC,(0x91)
	ld	e, (Seq_BeatTick:8)	; F0089C  ld E,(0x93)
	cp	wa, (0x60501c:24)	; F0089F  cp WA,(0x60501c)
	jr	z, sub_F00895_Skip	; F008A4  jr Z,0xf008ab
	calr	sub_F00984	; F008A6  calr 0xf00984
	jr	sub_F00895_Join2	; F008A9  jr T,0xf008f3
sub_F00895_Skip:
	cp	wa, 1:i3	; F008AB  cp WA,1
	jr	nz, sub_F00895_Skip2	; F008AD  jr NZ,0xf008bb
	cp	bc, 0:i3	; F008AF  cp BC,0
	jr	nz, sub_F00895_Skip2	; F008B1  jr NZ,0xf008bb
	cp	e, 32	; F008B3  cp E,0x20
	jr	nc, sub_F00895_Skip2	; F008B6  jr NC,0xf008bb
	calr	sub_F00984	; F008B8  calr 0xf00984
sub_F00895_Skip2:
	calr	sub_F00903	; F008BB  calr 0xf00903
	cp	d, 1:i3	; F008BE  cp D,1
	jr	nz, sub_F00895_Join	; F008C0  jr NZ,0xf008d8
	calr	sub_F0095D	; F008C2  calr 0xf0095d
	cp	d, 1:i3	; F008C5  cp D,1
	jr	nz, sub_F00895_Join	; F008C7  jr NZ,0xf008d8
	cp	e, 32	; F008C9  cp E,0x20
	jr	nc, sub_F00895_Skip3	; F008CC  jr NC,0xf008d3
	calr	sub_F00984	; F008CE  calr 0xf00984
	jr	sub_F00895_Join	; F008D1  jr T,0xf008d8
sub_F00895_Skip3:
	calr	Var20D4_ClearBitsC0	; F008D3  calr 0xf009a8
	jr	sub_F00895_Join	; F008D6  jr T,0xf008d8
sub_F00895_Join:
	cp	bc, (0x60501e:24)	; F008D8  cp BC,(0x60501e)
	jr	z, sub_F00895_Skip4	; F008DD  jr Z,0xf008e4
	calr	sub_F00995	; F008DF  calr 0xf00995
	jr	sub_F00895_Join2	; F008E2  jr T,0xf008f3
sub_F00895_Skip4:
	cp	e, (0x605020:24)	; F008E4  cp E,(0x605020)
	jr	z, sub_F00895_Join2	; F008E9  jr Z,0xf008f3
	cp	e, 32	; F008EB  cp E,0x20
	jr	c, sub_F00895_Join2	; F008EE  jr C,0xf008f3
	calr	Var20D4_ClearBitsC0	; F008F0  calr 0xf009a8
sub_F00895_Join2:
	ld	(6311964:24), wa	; F008F3  ld (0x60501c),WA
	ld	(6311966:24), bc	; F008F8  ld (0x60501e),BC
	ld	(6311968:24), e	; F008FD  ld (0x605020),E
	ret	; F00902  ret
sub_F00903:
	pushw	wa	; F00903  push WA
	pushw	bc	; F00904  push BC
	push	e	; F00905  push E
	ld	d, 0:opc	; F00907  ld D,0x00
	ld	a, (UI_ScreenLatch:16)	; F00909  ld A,(0x207a)
	cp	a, 18	; F0090D  cp A,0x12
	jr	z, sub_F00903_Skip	; F00910  jr Z,0xf00923
	cp	a, 20	; F00912  cp A,0x14
	jr	z, sub_F00903_Skip	; F00915  jr Z,0xf00923
	cp	a, 38	; F00917  cp A,0x26
	jr	z, sub_F00903_Skip	; F0091A  jr Z,0xf00923
	cp	a, 41	; F0091C  cp A,0x29
	jr	z, sub_F00903_Skip	; F0091F  jr Z,0xf00923
	jr	sub_F00903_Join2	; F00921  jr T,0xf00939
sub_F00903_Skip:
	bit	0, (0x360b:16)	; F00923  bit 0,(0x360b)
	jr	z, sub_F00903_Join	; F00927  jr Z,0xf00937
	ld	wa, (13854:16)	; F00929  ld WA,(0x361e)
	cp	wa, (0x3620:16)	; F0092D  cp WA,(0x3620)
	jr	nz, sub_F00903_Join	; F00931  jr NZ,0xf00937
	ld	d, 1:opc	; F00933  ld D,0x01
	jr	sub_F00903_Join	; F00935  jr T,0xf00937
sub_F00903_Join:
	jr	sub_F00903_Epilogue	; F00937  jr T,0xf00958
sub_F00903_Join2:
	cp	a, 6:i3	; F00939  cp A,6
	jr	z, sub_F00903_Skip2	; F0093B  jr Z,0xf00944
	cp	a, 8	; F0093D  cp A,0x08
	jr	z, sub_F00903_Skip2	; F00940  jr Z,0xf00944
	jr	sub_F00903_Epilogue	; F00942  jr T,0xf00958
sub_F00903_Skip2:
	bit	1, (0x360b:16)	; F00944  bit 1,(0x360b)
	jr	z, sub_F00903_Epilogue	; F00948  jr Z,0xf00958
	ld	wa, (13858:16)	; F0094A  ld WA,(0x3622)
	cp	wa, (0x3624:16)	; F0094E  cp WA,(0x3624)
	jr	nz, sub_F00903_Epilogue	; F00952  jr NZ,0xf00958
	ld	d, 1:opc	; F00954  ld D,0x01
	jr	sub_F00903_Epilogue	; F00956  jr T,0xf00958
sub_F00903_Epilogue:
	pop	e	; F00958  pop E
	popw	bc	; F0095A  pop BC
	popw	wa	; F0095B  pop WA
	ret	; F0095C  ret
sub_F0095D:
	pushw	wa	; F0095D  push WA
	pushw	bc	; F0095E  push BC
	push	e	; F0095F  push E
	ld	d, 0:opc	; F00961  ld D,0x00
	ld	xwa, 0	; F00963  ld XWA,0x00000000
	ld	wa, bc	; F00968  ld WA,BC
	ld	xbc, 0	; F0096A  ld XBC,0x00000000
	ld	c, (TransportA_BeatsPerBar:24)	; F0096F  ld C,(0x605000)
	div	xwa, bc	; F00974  div XWA,BC
	srl	xwa, 16	; F00976  srl 0x00,XWA
	cp	wa, 0:i3	; F00979  cp WA,0
	jr	nz, sub_F0095D_Epilogue	; F0097B  jr NZ,0xf0097f
	ld	d, 1:opc	; F0097D  ld D,0x01
sub_F0095D_Epilogue:
	pop	e	; F0097F  pop E
	popw	bc	; F00981  pop BC
	popw	wa	; F00982  pop WA
	ret	; F00983  ret
sub_F00984:
	or	(PanelLed_Shadow+4:16), 0x40	; F00984  or (0x20d4),0x40
	bit	7, (PanelLed_Shadow+4:16)	; F00989  bit 7,(0x20d4)
	jr	z, sub_F00984_Return	; F0098D  jr Z,0xf00994
	and	(PanelLed_Shadow+4:16), 0x7f	; F0098F  and (0x20d4),0x7f
sub_F00984_Return:
	ret	; F00994  ret
sub_F00995:
	bit	6, (PanelLed_Shadow+4:16)	; F00995  bit 6,(0x20d4)
	jr	nz, sub_F00995_Skip	; F00999  jr NZ,0xf009a2
	or	(PanelLed_Shadow+4:16), 0x80	; F0099B  or (0x20d4),0x80
	jr	sub_F00995_Return	; F009A0  jr T,0xf009a7
sub_F00995_Skip:
	and	(PanelLed_Shadow+4:16), 0x7f	; F009A2  and (0x20d4),0x7f
sub_F00995_Return:
	ret	; F009A7  ret
; Var20D4_ClearBitsC0: m_and_mi8 MB16, PanelLed_Shadow+4, 0x3f (single-cell template; the cell's meaning is not established unless it is named)
Var20D4_ClearBitsC0:
	and	(PanelLed_Shadow+4:16), 0x3f	; F009A8  and (0x20d4),0x3f
	ret	; F009AD  ret
sub_F009AE:
	ld	xix, (6311941:24)	; F009AE  ld XIX,(0x605005)
	ld	a, (xix+0:8)	; F009B3  ld A,(XIX+0x00)
	cp	a, 144	; F009B6  cp A,0x90
	jr	nz, sub_F009AE_Skip	; F009B9  jr NZ,0xf009c5
	ld	a, (xix+1)	; F009BB  ld A,(XIX+0x01)
	ld	(6311958:24), a	; F009BE  ld (0x605016),A
	jr	sub_F009AE_Return	; F009C3  jr T,0xf00a2a
sub_F009AE_Skip:
	cp	a, 129	; F009C5  cp A,0x81
	jr	nz, sub_F009AE_Skip4	; F009C8  jr NZ,0xf00a0d
	cp	(0x605015:24), 0x00	; F009CA  cp (0x605015),0x00
	jr	nz, sub_F009AE_Skip2	; F009D0  jr NZ,0xf009dc
	ld	a, (TransportA_BeatsPerBar:24)	; F009D2  ld A,(0x605000)
	ld	(6311937:24), a	; F009D7  ld (0x605001),A
sub_F009AE_Skip2:
	ld	a, (6311937:24)	; F009DC  ld A,(0x605001)
	sub	a, 1	; F009E1  sub A,0x01
	cp	a, (0x605015:24)	; F009E4  cp A,(0x605015)
	jr	ule, sub_F009AE_Skip3	; F009E9  jr ULE,0xf009f8
	add	(0x605015:24), 0x01	; F009EB  add (0x605015),0x01
	inc	1, (6311941:24)	; F009F1  inc 1,(0x605005)
	jr	sub_F009AE_Join	; F009F6  jr T,0xf00a0b
sub_F009AE_Skip3:
	ld	(6311957:24), 0	; F009F8  ld (0x605015),0x00
	calr	sub_F00A2B	; F009FE  calr 0xf00a2b
	ld	xiz, Data_F00B48	; F00A01  ld XIZ,0x00f00b48
	ld	(6311941:24), xiz	; F00A06  ld (0x605005),XIZ
sub_F009AE_Join:
	jr	sub_F009AE_Join2	; F00A0B  jr T,0xf00a28
sub_F009AE_Skip4:
	cp	a, 131	; F00A0D  cp A,0x83
	jr	nz, sub_F009AE_Skip5	; F00A10  jr NZ,0xf00a1e
	ld	xiz, Data_F00B48	; F00A12  ld XIZ,0x00f00b48
	ld	(6311941:24), xiz	; F00A17  ld (0x605005),XIZ
	jr	sub_F009AE_Join2	; F00A1C  jr T,0xf00a28
sub_F009AE_Skip5:
	ld	xiz, Data_F00B48	; F00A1E  ld XIZ,0x00f00b48
	ld	(6311941:24), xiz	; F00A23  ld (0x605005),XIZ
sub_F009AE_Join2:
	jr	sub_F009AE	; F00A28  jr T,0xf009ae
sub_F009AE_Return:
	ret	; F00A2A  ret
sub_F00A2B:
	inc	1, (6311956:24)	; F00A2B  inc 1,(0x605014)
	ret	; F00A30  ret
sub_F00A31:
	ld	a, 0:opc	; F00A31  ld A,0x00
	ld	c, (6311956:24)	; F00A33  ld C,(0x605014)
	cp	(6311953:24), c	; F00A38  cp (0x605011),C
	jr	z, sub_F00A31_Skip4	; F00A3D  jr Z,0xf00a74
	cp	(6311953:24), c	; F00A3F  cp (0x605011),C
	jr	ugt, sub_F00A31_Skip2	; F00A44  jr UGT,0xf00a5a
	cp	(0x605014:24), 0xff	; F00A46  cp (0x605014),0xff
	jr	nz, sub_F00A31_Skip	; F00A4C  jr NZ,0xf00a58
	cp	(0x605011:24), 0x00	; F00A4E  cp (0x605011),0x00
	jr	nz, sub_F00A31_Skip	; F00A54  jr NZ,0xf00a58
	ld	a, 1:opc	; F00A56  ld A,0x01
sub_F00A31_Skip:
	jr	sub_F00A31_Join2	; F00A58  jr T,0xf00a72
sub_F00A31_Skip2:
	cp	(0x605011:24), 0xff	; F00A5A  cp (0x605011),0xff
	jr	z, sub_F00A31_Skip3	; F00A60  jr Z,0xf00a66
	ld	a, 1:opc	; F00A62  ld A,0x01
	jr	sub_F00A31_Join	; F00A64  jr T,0xf00a70
sub_F00A31_Skip3:
	cp	(0x605014:24), 0x00	; F00A66  cp (0x605014),0x00
	jr	z, sub_F00A31_Join	; F00A6C  jr Z,0xf00a70
	ld	a, 1:opc	; F00A6E  ld A,0x01
sub_F00A31_Join:
	jr	sub_F00A31_Join2	; F00A70  jr T,0xf00a72
sub_F00A31_Join2:
	jr	sub_F00A31_Return	; F00A72  jr T,0xf00aa4
sub_F00A31_Skip4:
	ld	c, (6311957:24)	; F00A74  ld C,(0x605015)
	cp	(6311954:24), c	; F00A79  cp (0x605012),C
	jr	z, sub_F00A31_Skip6	; F00A7E  jr Z,0xf00a8b
	cp	(6311954:24), c	; F00A80  cp (0x605012),C
	jr	c, sub_F00A31_Skip5	; F00A85  jr C,0xf00a89
	ld	a, 1:opc	; F00A87  ld A,0x01
sub_F00A31_Skip5:
	jr	sub_F00A31_Return	; F00A89  jr T,0xf00aa4
sub_F00A31_Skip6:
	ld	c, (6311958:24)	; F00A8B  ld C,(0x605016)
	cp	(6311955:24), c	; F00A90  cp (0x605013),C
	jr	z, sub_F00A31_Skip8	; F00A95  jr Z,0xf00aa2
	cp	(6311955:24), c	; F00A97  cp (0x605013),C
	jr	c, sub_F00A31_Skip7	; F00A9C  jr C,0xf00aa0
	ld	a, 1:opc	; F00A9E  ld A,0x01
sub_F00A31_Skip7:
	jr	sub_F00A31_Return	; F00AA0  jr T,0xf00aa4
sub_F00A31_Skip8:
	ld	a, 1:opc	; F00AA2  ld A,0x01
sub_F00A31_Return:
	ret	; F00AA4  ret
sub_F00AA5:
	ld	xiy, (6311941:24)	; F00AA5  ld XIY,(0x605005)
	ld	w, (xiy+2)	; F00AAA  ld W,(XIY+0x02)
	ld	a, (xiy+3)	; F00AAD  ld A,(XIY+0x03)
	inc	4, xiy	; F00AB0  inc 4,XIY
	ld	(6311941:24), xiy	; F00AB2  ld (0x605005),XIY
	bit	0, (0x34d9:16)	; F00AB7  bit 0,(0x34d9)
	jr	z, sub_F00AA5_Return	; F00ABB  jr Z,0xf00adc
	ld	xiy, 6311945	; F00ABD  ld XIY,0x00605009
	ld	(xiy), 144	; F00AC2  ld (XIY),0x90
	ld	(xiy+1), 32	; F00AC5  ld (XIY+0x01),0x20
	ld	(xiy+2), w	; F00AC9  ld (XIY+0x02),W
	ld	(xiy+3), a	; F00ACC  ld (XIY+0x03),A
	push	xiy	; F00ACF  push XIY
	pushw	4	; F00AD0  push 0x0004
	pushw	0	; F00AD3  push 0x0000
	call	T_Link_SendBlockIn32ByteChunks	; F00AD6  call 0xf40ed4
	inc	8, xsp	; F00ADA  inc 0,XSP
sub_F00AA5_Return:
	ret	; F00ADC  ret
sub_F00ADD:
	ld	xiy, 6311945	; F00ADD  ld XIY,0x00605009
	ld	(xiy), 176	; F00AE2  ld (XIY),0xb0
	ld	(xiy+1), 32	; F00AE5  ld (XIY+0x01),0x20
	ld	(xiy+2), 123	; F00AE9  ld (XIY+0x02),0x7b
	ld	(xiy+3), 0	; F00AED  ld (XIY+0x03),0x00
	push	xiy	; F00AF1  push XIY
	pushw	4	; F00AF2  push 0x0004
	pushw	0	; F00AF5  push 0x0000
	call	T_Link_SendBlockIn32ByteChunks	; F00AF8  call 0xf40ed4
	inc	8, xsp	; F00AFC  inc 0,XSP
	ret	; F00AFE  ret
; TransportA_ResetCountersAndPattern: Zeroes 0x605011-0x605016, points (0x605005) at the event list Data_F00B48,
;   copies TransportA_BeatsPerBar to (0x605001) and zeroes transport A's bar/beat/tick (at interrupt level 6).
;   Transport_StartAllFromZero / _StartAllContinue call it just before starting transport A; sub_F009AE/sub_F00AA5
;   play that list as 0x90 0x20 note messages. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_f.json)
TransportA_ResetCountersAndPattern:
	ld	(6311953:24), 0	; F00AFF  ld (0x605011),0x00
	ld	(6311954:24), 0	; F00B05  ld (0x605012),0x00
	ld	(6311955:24), 0	; F00B0B  ld (0x605013),0x00
	ld	(6311956:24), 0	; F00B11  ld (0x605014),0x00
	ld	(6311957:24), 0	; F00B17  ld (0x605015),0x00
	ld	(6311958:24), 0	; F00B1D  ld (0x605016),0x00
	ld	xiz, Data_F00B48	; F00B23  ld XIZ,0x00f00b48
	ld	(6311941:24), xiz	; F00B28  ld (0x605005),XIZ
	ei	6	; F00B2D  ei 0x06
	ld	a, (TransportA_BeatsPerBar:24)	; F00B2F  ld A,(0x605000)
	ld	(6311937:24), a	; F00B34  ld (0x605001),A
	ld	(TransportA_Bar:24), 0	; F00B39  ld (0x605002),0x00
	ld	(TransportA_Beat:8), 0:io	; F00B3F  ld (0x8c),0x00
	ld	(TransportA_Tick:8), 0:io	; F00B42  ld (0x8b),0x00
	ei	0	; F00B45  ei 0x00
	ret	; F00B47  ret

; --------------------------------------------------------------------------
; Data_F00B48 -- 261 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F00B48 appears as a 32-bit word at 0xF00A02 0xF00A13
;               0xF00A1F 0xF00B24.  No routine-directory slot and no branch
;               decoded in converted code names it.
; Measured: 44% printable ASCII; a linear decode runs 130 instructions and
;           ends `swi 4`, with 15% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F00B48:
	.byte	0x90, 0x00, 0x7E, 0x54, 0x90, 0x10, 0x7E, 0x00, 0x81, 0x90, 0x00, 0x7D, 0x38, 0x90, 0x10, 0x7D	; F00B48  |..~T..~....}8..}|
	.byte	0x00, 0x81, 0x90, 0x00, 0x7D, 0x38, 0x90, 0x10, 0x7D, 0x00, 0x81, 0x90, 0x00, 0x7D, 0x38, 0x90	; F00B58  |....}8..}....}8.|
	.byte	0x10, 0x7D, 0x00, 0x81, 0x90, 0x00, 0x7D, 0x38, 0x90, 0x10, 0x7D, 0x00, 0x81, 0x90, 0x00, 0x7D	; F00B68  |.}....}8..}....}|
	.byte	0x38, 0x90, 0x10, 0x7D, 0x00, 0x81, 0x90, 0x00, 0x7D, 0x38, 0x90, 0x10, 0x7D, 0x00, 0x81, 0x90	; F00B78  |8..}....}8..}...|
	.byte	0x00, 0x7D, 0x38, 0x90, 0x10, 0x7D, 0x00, 0x81, 0x83, 0x00, 0x00, 0x7D, 0x54, 0x2F, 0x00, 0x7D	; F00B88  |.}8..}.....}T/.}|
	.byte	0x00, 0x00, 0x01, 0x7D, 0x54, 0x2F, 0x01, 0x7D, 0x00, 0xFF, 0x00, 0x00, 0x7E, 0x54, 0x00, 0x01	; F00B98  |...}T/.}....~T..|
	.byte	0x7D, 0x38, 0x2F, 0x01, 0x7D, 0x00, 0x2F, 0x01, 0x7E, 0x00, 0xFF, 0x00, 0x00, 0x7E, 0x54, 0x00	; F00BA8  |}8/.}./.~....~T.|
	.byte	0x01, 0x7D, 0x54, 0x2F, 0x01, 0x7D, 0x00, 0x00, 0x02, 0x7D, 0x38, 0x2F, 0x02, 0x7D, 0x00, 0x2F	; F00BB8  |.}T/.}...}8/.}./|
	.byte	0x02, 0x7E, 0x00, 0xFF, 0x00, 0x00, 0x7E, 0x54, 0x00, 0x01, 0x7D, 0x54, 0x2F, 0x01, 0x7D, 0x00	; F00BC8  |.~....~T..}T/.}.|
	.byte	0x00, 0x02, 0x7D, 0x54, 0x2F, 0x02, 0x7D, 0x00, 0x00, 0x03, 0x7D, 0x38, 0x2F, 0x03, 0x7D, 0x00	; F00BD8  |..}T/.}...}8/.}.|
	.byte	0x2F, 0x03, 0x7E, 0x00, 0xFF, 0x00, 0x00, 0x7E, 0x54, 0x00, 0x01, 0x7D, 0x54, 0x2F, 0x01, 0x7D	; F00BE8  |/.~....~T..}T/.}|
	.byte	0x00, 0x00, 0x02, 0x7D, 0x54, 0x2F, 0x02, 0x7D, 0x00, 0x00, 0x03, 0x7D, 0x54, 0x2F, 0x03, 0x7D	; F00BF8  |...}T/.}...}T/.}|
	.byte	0x00, 0x00, 0x04, 0x7D, 0x38, 0x2F, 0x04, 0x7D, 0x00, 0x2F, 0x04, 0x7E, 0x00, 0xFF, 0x00, 0x00	; F00C08  |...}8/.}./.~....|
	.byte	0x7E, 0x54, 0x30, 0x00, 0x7D, 0x54, 0x47, 0x00, 0x7D, 0x00, 0x00, 0x01, 0x7D, 0x54, 0x17, 0x01	; F00C18  |~T0.}TG.}...}T..|
	.byte	0x7D, 0x00, 0x30, 0x01, 0x7D, 0x54, 0x47, 0x01, 0x7D, 0x00, 0x00, 0x02, 0x7D, 0x54, 0x17, 0x02	; F00C28  |}.0.}TG.}...}T..|
	.byte	0x7D, 0x00, 0x2F, 0x02, 0x7E, 0x00, 0x30, 0x02, 0x7D, 0x38, 0x47, 0x02, 0x7D, 0x00, 0xFF, 0x93	; F00C38  |}./.~.0.}8G.}...|
	.byte	0xFD, 0x00, 0x80, 0x44, 0xFC	; F00C48  |...D.|

; === MODULE F00C4D 0xF00C4D-0xF017FF ===
; 0xF00C4D-0xF017FF, 2,995 bytes -- the largest `.incbin` this image had
; left.  THREE OBJECTS AND A REMAINDER, not one thing:
;   0xF00C4D-0xF00CA1    85 B  tail of the pointer array that starts at
;                              0xF00C46, 7 bytes before this span
;   0xF00CA2-0xF014ED  2124 B  code, 828 instructions
;   0xF014EE-0xF017FD   784 B  a 196-entry pointer array, 18-slot records
;                              (10 whole and a partial 11th of 16)
;   0xF017FE-0xF017FF     2 B  REFUSED, reason at the site
; The evidence for every boundary, the five code checks and the ANOMALY
; (nothing in the image reaches this cluster, and its prom_a call targets
; are not prom_a entry points) are in notes/gen_prom_b_f00c4d_module.py.
; Regenerate: python3 notes/gen_prom_b_f00c4d_module.py --apply

; --------------------------------------------------------------------------
; PtrArray_F00C46 (tail) -- 4-byte pointers into prom_a's window.
; The array starts at 0xF00C46, inside Data_F00B48 above, so this span opens
; ONE BYTE INTO the entry that begins at 0xF00C4A.  It ends at 0xF00CA1, the
; byte before the `link XIZ` prologue below; the word below the array's own
; start is 0x007D0247, out of window.
; ⚠ WHAT the slots select is NOT decoded -- see the ANOMALY in the
;   generator before reading any meaning into a target address.
; --------------------------------------------------------------------------
; census: stale -- the orphaned older-build module's array: its targets are that build's prom_a (notes/FINDINGS-prom_b-f00c4d-orphan-cluster.md, N2).
	.byte	0x00	; F00C4D  high byte of the pointer at 0xF00C4A
PtrArray_F00C4E:
	.long	0x00FD8E21	; F00C4E
	.long	0x00FD8F66	; F00C52
	.long	0x00FD9CAA	; F00C56
	.long	0x00FD9ABB	; F00C5A
	.long	0x00FD9BDA	; F00C5E
	.long	0x00FD9D2F	; F00C62
	.long	0x00FD9F0C	; F00C66
	.long	0x00FD9F0D	; F00C6A
	.long	0x00FD9F0E	; F00C6E
	.long	0x00FD9FDB	; F00C72
	.long	0x00FDA062	; F00C76
	.long	0x00FDA1EA	; F00C7A
	.long	0x00FDA2FB	; F00C7E
	.long	0x00FDA40D	; F00C82
	.long	0x00FC4480	; F00C86
	.long	0x00FD9D2C	; F00C8A
	.long	0x00FD9D2D	; F00C8E
	.long	0x00FD9D2E	; F00C92
	.long	0x00FD8CD5	; F00C96
	.long	0x00FC4480	; F00C9A
	.long	0x00FC4480	; F00C9E

; --------------------------------------------------------------------------
; CODE -- 0xF00CA2-0xF014ED, 828 instructions, 2124 bytes.
; The decode tiles the region exactly and stops on the array below; there is
; no `db` in it; every internal branch lands on an instruction start; and
; 26 pointers in 0xF0033C-0xF003C7, outside this span, name addresses in it that
; all land on instruction starts too.
; ★ COVERAGE ROUND: labels are bare sub_XXXXXX and nothing is named.  ⚠ Do
;   NOT name a routine here after what its call target does in prom_a --
;   the targets are not prom_a entry points (the ANOMALY, N2).
; --------------------------------------------------------------------------
sub_F00CA2:
	link XIZ,0xfffc	; F00CA2  link XIZ,0xfffc
	lda	xbc, (xiz-2)	; F00CA6  lda XBC,XIZ+0xfe
	push	xbc	; F00CA9  push XBC
	lda	xwa, (xiz-4)	; F00CAA  lda XWA,XIZ+0xfc
	push	xwa	; F00CAD  push XWA
	pushw	(xiz+10)	; F00CAE  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F00CB1  pushw (XIZ+0x08)
	call	16629032	; F00CB4  call 0xfdbd28
	inc	8, xsp	; F00CB8  inc 0,XSP
	inc	4, xsp	; F00CBA  inc 4,XSP
	cp	wa, 65535	; F00CBC  cp WA,0xffff
	jr	z, sub_F00CA2_Skip	; F00CC0  jr Z,0xf00ce0
	ld	bc, (xiz-2)	; F00CC2  ld BC,(XIZ+0xfe)
	extz	bc	; F00CC5  extz BC
	pushw	bc	; F00CC7  push BC
	ld	c, 4:opc	; F00CC8  ld C,0x04
	mul	bc, (xiz-4)	; F00CCA  mul BC,(XIZ+0xfc)
	extz	xbc	; F00CCD  extz XBC
	add	xbc, 15729324	; F00CCF  add XBC,0x00f002ac
	ld	xbc, (xbc)	; F00CD5  ld XBC,(XBC)
	lda	xiy, (sub_F00CA2_Resume:24)	; F00CD7  lda XIY,0xf00cdf
	push	xiy	; F00CDC  push XIY
	jp	(xbc)	; F00CDD  jp T,XBC
sub_F00CA2_Resume:
	popw	bc	; F00CDF  pop BC
sub_F00CA2_Skip:
	unlk XIZ	; F00CE0  unlk XIZ
	ret	; F00CE2  ret
sub_F00CE3:
	link XIZ,0xfffc	; F00CE3  link XIZ,0xfffc
	lda	xbc, (xiz-2)	; F00CE7  lda XBC,XIZ+0xfe
	push	xbc	; F00CEA  push XBC
	lda	xwa, (xiz-4)	; F00CEB  lda XWA,XIZ+0xfc
	push	xwa	; F00CEE  push XWA
	pushw	(xiz+10)	; F00CEF  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F00CF2  pushw (XIZ+0x08)
	call	16629032	; F00CF5  call 0xfdbd28
	inc	8, xsp	; F00CF9  inc 0,XSP
	inc	4, xsp	; F00CFB  inc 4,XSP
	cp	wa, 65535	; F00CFD  cp WA,0xffff
	jr	z, sub_F00CE3_Skip	; F00D01  jr Z,0xf00d21
	ld	bc, (xiz-2)	; F00D03  ld BC,(XIZ+0xfe)
	extz	bc	; F00D06  extz BC
	pushw	bc	; F00D08  push BC
	ld	c, 4:opc	; F00D09  ld C,0x04
	mul	bc, (xiz-4)	; F00D0B  mul BC,(XIZ+0xfc)
	extz	xbc	; F00D0E  extz XBC
	add	xbc, TransportC_ResetCounters	; F00D10  add XBC,0x00f002f4
	ld	xbc, (xbc)	; F00D16  ld XBC,(XBC)
	lda	xiy, (sub_F00CE3_Resume:24)	; F00D18  lda XIY,0xf00d20
	push	xiy	; F00D1D  push XIY
	jp	(xbc)	; F00D1E  jp T,XBC
sub_F00CE3_Resume:
	popw	bc	; F00D20  pop BC
sub_F00CE3_Skip:
	unlk XIZ	; F00D21  unlk XIZ
	ret	; F00D23  ret
sub_F00D24:
	link XIZ,0xfffc	; F00D24  link XIZ,0xfffc
	lda	xbc, (xiz-2)	; F00D28  lda XBC,XIZ+0xfe
	push	xbc	; F00D2B  push XBC
	lda	xwa, (xiz-4)	; F00D2C  lda XWA,XIZ+0xfc
	push	xwa	; F00D2F  push XWA
	pushw	(xiz+10)	; F00D30  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F00D33  pushw (XIZ+0x08)
	call	16629032	; F00D36  call 0xfdbd28
	inc	8, xsp	; F00D3A  inc 0,XSP
	inc	4, xsp	; F00D3C  inc 4,XSP
	cp	wa, 65535	; F00D3E  cp WA,0xffff
	jr	z, sub_F00D24_Skip	; F00D42  jr Z,0xf00d62
	ld	bc, (xiz-2)	; F00D44  ld BC,(XIZ+0xfe)
	extz	bc	; F00D47  extz BC
	pushw	bc	; F00D49  push BC
	ld	c, 4:opc	; F00D4A  ld C,0x04
	mul	bc, (xiz-4)	; F00D4C  mul BC,(XIZ+0xfc)
	extz	xbc	; F00D4F  extz XBC
	add	xbc, sub_F00D24_Code	; F00D51  add XBC,0x00f0033c
	ld	xbc, (xbc)	; F00D57  ld XBC,(XBC)
	lda	xiy, (sub_F00D24_Resume:24)	; F00D59  lda XIY,0xf00d61
	push	xiy	; F00D5E  push XIY
	jp	(xbc)	; F00D5F  jp T,XBC
sub_F00D24_Resume:
	popw	bc	; F00D61  pop BC
sub_F00D24_Skip:
	unlk XIZ	; F00D62  unlk XIZ
	ret	; F00D64  ret
sub_F00D65:
	link XIZ,0xfffc	; F00D65  link XIZ,0xfffc
	lda	xbc, (xiz-2)	; F00D69  lda XBC,XIZ+0xfe
	push	xbc	; F00D6C  push XBC
	lda	xwa, (xiz-4)	; F00D6D  lda XWA,XIZ+0xfc
	push	xwa	; F00D70  push XWA
	pushw	(xiz+10)	; F00D71  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F00D74  pushw (XIZ+0x08)
	call	16629032	; F00D77  call 0xfdbd28
	inc	8, xsp	; F00D7B  inc 0,XSP
	inc	4, xsp	; F00D7D  inc 4,XSP
	cp	wa, 65535	; F00D7F  cp WA,0xffff
	jr	z, sub_F00D65_Skip	; F00D83  jr Z,0xf00da3
	ld	bc, (xiz-2)	; F00D85  ld BC,(XIZ+0xfe)
	extz	bc	; F00D88  extz BC
	pushw	bc	; F00D8A  push BC
	ld	c, 4:opc	; F00D8B  ld C,0x04
	mul	bc, (xiz-4)	; F00D8D  mul BC,(XIZ+0xfc)
	extz	xbc	; F00D90  extz XBC
	add	xbc, PtrTable_F00340 + 0x44	; F00D92  add XBC,0x00f00384
	ld	xbc, (xbc)	; F00D98  ld XBC,(XBC)
	lda	xiy, (sub_F00D65_Resume:24)	; F00D9A  lda XIY,0xf00da2
	push	xiy	; F00D9F  push XIY
	jp	(xbc)	; F00DA0  jp T,XBC
sub_F00D65_Resume:
	popw	bc	; F00DA2  pop BC
sub_F00D65_Skip:
	unlk XIZ	; F00DA3  unlk XIZ
	ret	; F00DA5  ret
; OldCopy_SoftKeyCol2_SoundEditPitchTune: the older build's copy of SoftKeyCol2_SoundEditPitchTune (0xF0A162 = this + 0x93BC), equal to it in all 45
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol2_SoundEditPitchTune:
	link XIZ,0xfff2	; F00DA6  link XIZ,0xfff2
	pushw	hl	; F00DAA  push HL
	pushw	de	; F00DAB  push DE
	push	xix	; F00DAC  push XIX
	lda	xix, (xiz-14)	; F00DAD  lda XIX,XIZ+0xf2
	lda	xbc, (xiz-2)	; F00DB0  lda XBC,XIZ+0xfe
	push	xbc	; F00DB3  push XBC
	call	16625608	; F00DB4  call 0xfdafc8
	ld	c, 3:opc	; F00DB8  ld C,0x03
	mul	bc, (xiz-2)	; F00DBA  mul BC,(XIZ+0xfe)
	ld	h, c	; F00DBD  ld H,C
	dec	2, h	; F00DBF  dec 2,H
	push	xix	; F00DC1  push XIX
	ld	c, h	; F00DC2  ld C,H
	extz	bc	; F00DC4  extz BC
	ld	de, bc	; F00DC6  ld DE,BC
	pushw	bc	; F00DC8  push BC
	call	16625910	; F00DC9  call 0xfdb0f6
	ld	(xix+6), 255	; F00DCD  ld (XIX+0x06),0xff
	ld	(xix+7), 0	; F00DD1  ld (XIX+0x07),0x00
	ld	(xix+8), 24	; F00DD5  ld (XIX+0x08),0x18
	ld	(xix+9), 232	; F00DD9  ld (XIX+0x09),0xe8
	ld	xbc, xix	; F00DDD  ld XBC,XIX
	add	xbc, 10	; F00DDF  add XBC,0x0000000a
	push	xbc	; F00DE5  push XBC
	ld	bc, (xiz+8)	; F00DE6  ld BC,(XIZ+0x08)
	extz	bc	; F00DE9  extz BC
	pushw	bc	; F00DEB  push BC
	call	16629557	; F00DEC  call 0xfdbf35
	push	xix	; F00DF0  push XIX
	pushw	4	; F00DF1  push 0x0004
	ld	bc, (xiz-2)	; F00DF4  ld BC,(XIZ+0xfe)
	extz	bc	; F00DF7  extz BC
	pushw	bc	; F00DF9  push BC
	pushw	de	; F00DFA  push DE
	pushw	135	; F00DFB  push 0x0087
	call	sub_FDB858	; F00DFE  call 0xfdb858
	pushw	2	; F00E02  push 0x0002
	call	16629513	; F00E05  call 0xfdbf09
	add	xsp, 30	; F00E09  add XSP,0x0000001e
	pop	xix	; F00E0F  pop XIX
	popw	de	; F00E10  pop DE
	popw	hl	; F00E11  pop HL
	unlk XIZ	; F00E12  unlk XIZ
	ret	; F00E14  ret
sub_F00E15:
	link XIZ,0xfff2	; F00E15  link XIZ,0xfff2
	pushw	hl	; F00E19  push HL
	pushw	de	; F00E1A  push DE
	push	xix	; F00E1B  push XIX
	lda	xix, (xiz-14)	; F00E1C  lda XIX,XIZ+0xf2
	lda	xbc, (xiz-2)	; F00E1F  lda XBC,XIZ+0xfe
	push	xbc	; F00E22  push XBC
	call	16625608	; F00E23  call 0xfdafc8
	ld	c, 3:opc	; F00E27  ld C,0x03
	mul	bc, (xiz-2)	; F00E29  mul BC,(XIZ+0xfe)
	ld	h, c	; F00E2C  ld H,C
	dec	1, h	; F00E2E  dec 1,H
	push	xix	; F00E30  push XIX
	ld	c, h	; F00E31  ld C,H
	extz	bc	; F00E33  extz BC
	ld	de, bc	; F00E35  ld DE,BC
	pushw	bc	; F00E37  push BC
	call	16625910	; F00E38  call 0xfdb0f6
	ld	(xix+6), 255	; F00E3C  ld (XIX+0x06),0xff
	ld	(xix+7), 0	; F00E40  ld (XIX+0x07),0x00
	ld	(xix+8), 127	; F00E44  ld (XIX+0x08),0x7f
	ld	(xix+9), 129	; F00E48  ld (XIX+0x09),0x81
	ld	xbc, xix	; F00E4C  ld XBC,XIX
	add	xbc, 10	; F00E4E  add XBC,0x0000000a
	push	xbc	; F00E54  push XBC
	ld	bc, (xiz+8)	; F00E55  ld BC,(XIZ+0x08)
	extz	bc	; F00E58  extz BC
	pushw	bc	; F00E5A  push BC
	call	16629557	; F00E5B  call 0xfdbf35
	push	xix	; F00E5F  push XIX
	pushw	5	; F00E60  push 0x0005
	ld	bc, (xiz-2)	; F00E63  ld BC,(XIZ+0xfe)
	extz	bc	; F00E66  extz BC
	pushw	bc	; F00E68  push BC
	pushw	de	; F00E69  push DE
	pushw	135	; F00E6A  push 0x0087
	call	sub_FDB858	; F00E6D  call 0xfdb858
	pushw	3	; F00E71  push 0x0003
	call	16629513	; F00E74  call 0xfdbf09
	add	xsp, 30	; F00E78  add XSP,0x0000001e
	pop	xix	; F00E7E  pop XIX
	popw	de	; F00E7F  pop DE
	popw	hl	; F00E80  pop HL
	unlk XIZ	; F00E81  unlk XIZ
	ret	; F00E83  ret
; OldCopy_SoftKeyCol4_SoundEditPitchTune: the older build's copy of SoftKeyCol4_SoundEditPitchTune (0xF0A240 = this + 0x93BC), equal to it in all 43
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol4_SoundEditPitchTune:
	link XIZ,0xfff2	; F00E84  link XIZ,0xfff2
	pushw	hl	; F00E88  push HL
	pushw	de	; F00E89  push DE
	push	xix	; F00E8A  push XIX
	lda	xix, (xiz-14)	; F00E8B  lda XIX,XIZ+0xf2
	lda	xbc, (xiz-2)	; F00E8E  lda XBC,XIZ+0xfe
	push	xbc	; F00E91  push XBC
	call	16625608	; F00E92  call 0xfdafc8
	ld	c, 3:opc	; F00E96  ld C,0x03
	mul	bc, (xiz-2)	; F00E98  mul BC,(XIZ+0xfe)
	ld	h, c	; F00E9B  ld H,C
	push	xix	; F00E9D  push XIX
	extz	bc	; F00E9E  extz BC
	ld	de, bc	; F00EA0  ld DE,BC
	pushw	bc	; F00EA2  push BC
	call	16625910	; F00EA3  call 0xfdb0f6
	ld	(xix+6), 7	; F00EA7  ld (XIX+0x06),0x07
	ld	(xix+7), 0	; F00EAB  ld (XIX+0x07),0x00
	ld	(xix+8), 7	; F00EAF  ld (XIX+0x08),0x07
	ld	(xix+9), 0	; F00EB3  ld (XIX+0x09),0x00
	ld	xbc, xix	; F00EB7  ld XBC,XIX
	add	xbc, 10	; F00EB9  add XBC,0x0000000a
	push	xbc	; F00EBF  push XBC
	ld	bc, (xiz+8)	; F00EC0  ld BC,(XIZ+0x08)
	extz	bc	; F00EC3  extz BC
	pushw	bc	; F00EC5  push BC
	call	16629557	; F00EC6  call 0xfdbf35
	push	xix	; F00ECA  push XIX
	pushw	6	; F00ECB  push 0x0006
	ld	bc, (xiz-2)	; F00ECE  ld BC,(XIZ+0xfe)
	extz	bc	; F00ED1  extz BC
	pushw	bc	; F00ED3  push BC
	pushw	de	; F00ED4  push DE
	pushw	135	; F00ED5  push 0x0087
	call	sub_FDB858	; F00ED8  call 0xfdb858
	pushw	4	; F00EDC  push 0x0004
	call	16629513	; F00EDF  call 0xfdbf09
	add	xsp, 30	; F00EE3  add XSP,0x0000001e
	pop	xix	; F00EE9  pop XIX
	popw	de	; F00EEA  pop DE
	popw	hl	; F00EEB  pop HL
	unlk XIZ	; F00EEC  unlk XIZ
	ret	; F00EEE  ret
sub_F00EEF:
	link XIZ,0xfff2	; F00EEF  link XIZ,0xfff2
	pushw	hl	; F00EF3  push HL
	push	xix	; F00EF4  push XIX
	lda	xix, (xiz-14)	; F00EF5  lda XIX,XIZ+0xf2
	lda	xbc, (xiz-2)	; F00EF8  lda XBC,XIZ+0xfe
	push	xbc	; F00EFB  push XBC
	pushw	13	; F00EFC  push 0x000d
	call	16625910	; F00EFF  call 0xfdb0f6
	inc	6, xsp	; F00F03  inc 6,XSP
	cp	(xiz-2), 0x01	; F00F05  cp (XIZ+0xfe),0x01
	jr	nz, sub_F00EEF_Skip	; F00F09  jr NZ,0xf00f29
	ld	l, 14:opc	; F00F0B  ld L,0x0e
	ld	h, 19:opc	; F00F0D  ld H,0x13
	push	xix	; F00F0F  push XIX
	pushw	14	; F00F10  push 0x000e
	call	16625910	; F00F13  call 0xfdb0f6
	ld	(xix+6), 15	; F00F17  ld (XIX+0x06),0x0f
	ld	(xix+7), 4	; F00F1B  ld (XIX+0x07),0x04
	ld	(xix+8), 15	; F00F1F  ld (XIX+0x08),0x0f
	ld	(xix+9), 0	; F00F23  ld (XIX+0x09),0x00
	jr	sub_F00EEF_Join	; F00F27  jr T,0xf00f45
sub_F00EEF_Skip:
	ld	l, 15:opc	; F00F29  ld L,0x0f
	ld	h, 85:opc	; F00F2B  ld H,0x55
	push	xix	; F00F2D  push XIX
	pushw	15	; F00F2E  push 0x000f
	call	16625910	; F00F31  call 0xfdb0f6
	ld	(xix+6), 15	; F00F35  ld (XIX+0x06),0x0f
	ld	(xix+7), 0	; F00F39  ld (XIX+0x07),0x00
	ld	(xix+8), 10	; F00F3D  ld (XIX+0x08),0x0a
	ld	(xix+9), 6	; F00F41  ld (XIX+0x09),0x06
sub_F00EEF_Join:
	inc	6, xsp	; F00F45  inc 6,XSP
	ld	xbc, xix	; F00F47  ld XBC,XIX
	add	xbc, 10	; F00F49  add XBC,0x0000000a
	push	xbc	; F00F4F  push XBC
	ld	bc, (xiz+8)	; F00F50  ld BC,(XIZ+0x08)
	extz	bc	; F00F53  extz BC
	pushw	bc	; F00F55  push BC
	call	16629557	; F00F56  call 0xfdbf35
	push	xix	; F00F5A  push XIX
	ld	c, h	; F00F5B  ld C,H
	extz	bc	; F00F5D  extz BC
	pushw	bc	; F00F5F  push BC
	pushw	0	; F00F60  push 0x0000
	ld	c, l	; F00F63  ld C,L
	extz	bc	; F00F65  extz BC
	pushw	bc	; F00F67  push BC
	pushw	135	; F00F68  push 0x0087
	call	sub_FDB858	; F00F6B  call 0xfdb858
	pushw	6	; F00F6F  push 0x0006
	call	16629513	; F00F72  call 0xfdbf09
	add	xsp, 20	; F00F76  add XSP,0x00000014
	pop	xix	; F00F7C  pop XIX
	popw	hl	; F00F7D  pop HL
	unlk XIZ	; F00F7E  unlk XIZ
	ret	; F00F80  ret
; OldCopy_LcdKeyRow1_SoundEditPitchTune: the older build's copy of LcdKeyRow1_SoundEditPitchTune (0xF0A3A1 = this + 0x9420), equal to it in all 11
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow1_SoundEditPitchTune:
	link XIZ,0x0000	; F00F81  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F00F85  cp (XIZ+0x08),0x00
	jr	nz, OldCopy_LcdKeyRow1_SoundEditPitchTune_Skip	; F00F89  jr NZ,0xf00f98
	pushw	0	; F00F8B  push 0x0000
	pushw	136	; F00F8E  push 0x0088
	call	sub_FDA6FC	; F00F91  call 0xfda6fc
	pop	xiy	; F00F95  pop XIY
	jr	OldCopy_LcdKeyRow1_SoundEditPitchTune_Join	; F00F96  jr T,0xf00f9c
OldCopy_LcdKeyRow1_SoundEditPitchTune_Skip:
	call	sub_FDB30B	; F00F98  call 0xfdb30b
OldCopy_LcdKeyRow1_SoundEditPitchTune_Join:
	unlk XIZ	; F00F9C  unlk XIZ
	ret	; F00F9E  ret
; OldCopy_LcdKeyRow2_SoundEditPitchTune: the older build's copy of LcdKeyRow2_SoundEditPitchTune (0xF0A3BF = this + 0x9420), equal to it in all 10
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow2_SoundEditPitchTune:
	link XIZ,0x0000	; F00F9F  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F00FA3  cp (XIZ+0x08),0x00
	jr	z, OldCopy_LcdKeyRow2_SoundEditPitchTune_Skip	; F00FA7  jr Z,0xf00fb8
	pushw	1	; F00FA9  push 0x0001
	pushw	1	; F00FAC  push 0x0001
	pushw	135	; F00FAF  push 0x0087
	call	16636539	; F00FB2  call 0xfdda7b
	inc	6, xsp	; F00FB6  inc 6,XSP
OldCopy_LcdKeyRow2_SoundEditPitchTune_Skip:
	unlk XIZ	; F00FB8  unlk XIZ
	ret	; F00FBA  ret
; OldCopy_LcdKeyRow3_SoundEditPitchTune: the older build's copy of LcdKeyRow3_SoundEditPitchTune (0xF0A3DB = this + 0x9420), equal to it in all 15
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow3_SoundEditPitchTune:
	link XIZ,0x0000	; F00FBB  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F00FBF  cp (XIZ+0x08),0x00
	jr	nz, OldCopy_LcdKeyRow3_SoundEditPitchTune_Skip	; F00FC3  jr NZ,0xf00fd2
	pushw	0	; F00FC5  push 0x0000
	pushw	138	; F00FC8  push 0x008a
	call	sub_FDA6FC	; F00FCB  call 0xfda6fc
	pop	xiy	; F00FCF  pop XIY
	jr	OldCopy_LcdKeyRow3_SoundEditPitchTune_Skip2	; F00FD0  jr T,0xf00fe1
OldCopy_LcdKeyRow3_SoundEditPitchTune_Skip:
	pushw	1	; F00FD2  push 0x0001
	pushw	2	; F00FD5  push 0x0002
	pushw	135	; F00FD8  push 0x0087
	call	16636539	; F00FDB  call 0xfdda7b
	inc	6, xsp	; F00FDF  inc 6,XSP
OldCopy_LcdKeyRow3_SoundEditPitchTune_Skip2:
	unlk XIZ	; F00FE1  unlk XIZ
	ret	; F00FE3  ret
; OldCopy_LcdKeyRow4_SoundEditPitchTune: the older build's copy of LcdKeyRow4_SoundEditPitchTune (0xF0A404 = this + 0x9420), equal to it in all 28
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow4_SoundEditPitchTune:
	link XIZ,0xfffe	; F00FE4  link XIZ,0xfffe
	cp	(xiz+8), 0x00	; F00FE8  cp (XIZ+0x08),0x00
	jr	nz, OldCopy_LcdKeyRow4_SoundEditPitchTune_Skip	; F00FEC  jr NZ,0xf0101f
	lda	xbc, (xiz-2)	; F00FEE  lda XBC,XIZ+0xfe
	push	xbc	; F00FF1  push XBC
	pushw	13	; F00FF2  push 0x000d
	call	16625910	; F00FF5  call 0xfdb0f6
	inc	6, xsp	; F00FF9  inc 6,XSP
	cp	(xiz-2), 0x01	; F00FFB  cp (XIZ+0xfe),0x01
	jr	ule, OldCopy_LcdKeyRow4_SoundEditPitchTune_Join	; F00FFF  jr ULE,0xf0102e
	decm8	1, (xiz-2)	; F01001  dec 1,(XIZ+0xfe)
	ld	bc, (xiz-2)	; F01004  ld BC,(XIZ+0xfe)
	extz	bc	; F01007  extz BC
	pushw	bc	; F01009  push BC
	pushw	13	; F0100A  push 0x000d
	call	16625888	; F0100D  call 0xfdb0e0
	pushw	13	; F01011  push 0x000d
	pushw	135	; F01014  push 0x0087
	call	T_Dispatch_Code80	; F01017  call 0xf41ed4
	inc	8, xsp	; F0101B  inc 0,XSP
	jr	OldCopy_LcdKeyRow4_SoundEditPitchTune_Join	; F0101D  jr T,0xf0102e
OldCopy_LcdKeyRow4_SoundEditPitchTune_Skip:
	pushw	1	; F0101F  push 0x0001
	pushw	3	; F01022  push 0x0003
	pushw	135	; F01025  push 0x0087
	call	16636539	; F01028  call 0xfdda7b
	inc	6, xsp	; F0102C  inc 6,XSP
OldCopy_LcdKeyRow4_SoundEditPitchTune_Join:
	unlk XIZ	; F0102E  unlk XIZ
	ret	; F01030  ret
; OldCopy_LcdKeyRow5_SoundEditPitchTune: the older build's copy of LcdKeyRow5_SoundEditPitchTune (0xF0A451 = this + 0x9420), equal to it in all 28
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow5_SoundEditPitchTune:
	link XIZ,0xfffe	; F01031  link XIZ,0xfffe
	cp	(xiz+8), 0x00	; F01035  cp (XIZ+0x08),0x00
	jr	nz, OldCopy_LcdKeyRow5_SoundEditPitchTune_Skip	; F01039  jr NZ,0xf0106c
	lda	xbc, (xiz-2)	; F0103B  lda XBC,XIZ+0xfe
	push	xbc	; F0103E  push XBC
	pushw	13	; F0103F  push 0x000d
	call	16625910	; F01042  call 0xfdb0f6
	inc	6, xsp	; F01046  inc 6,XSP
	cp	(xiz-2), 0x02	; F01048  cp (XIZ+0xfe),0x02
	jr	nc, OldCopy_LcdKeyRow5_SoundEditPitchTune_Join	; F0104C  jr NC,0xf0107b
	incm8	1, (xiz-2)	; F0104E  inc 1,(XIZ+0xfe)
	ld	bc, (xiz-2)	; F01051  ld BC,(XIZ+0xfe)
	extz	bc	; F01054  extz BC
	pushw	bc	; F01056  push BC
	pushw	13	; F01057  push 0x000d
	call	16625888	; F0105A  call 0xfdb0e0
	pushw	13	; F0105E  push 0x000d
	pushw	135	; F01061  push 0x0087
	call	T_Dispatch_Code80	; F01064  call 0xf41ed4
	inc	8, xsp	; F01068  inc 0,XSP
	jr	OldCopy_LcdKeyRow5_SoundEditPitchTune_Join	; F0106A  jr T,0xf0107b
OldCopy_LcdKeyRow5_SoundEditPitchTune_Skip:
	pushw	1	; F0106C  push 0x0001
	pushw	4	; F0106F  push 0x0004
	pushw	135	; F01072  push 0x0087
	call	16636539	; F01075  call 0xfdda7b
	inc	6, xsp	; F01079  inc 6,XSP
OldCopy_LcdKeyRow5_SoundEditPitchTune_Join:
	unlk XIZ	; F0107B  unlk XIZ
	ret	; F0107D  ret
; OldCopy_ExitKey_SoundEditPitchTune: the older build's copy of ExitKey_SoundEditPitchTune (0xF0A49E = this + 0x9420), equal to it in all 11
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_ExitKey_SoundEditPitchTune:
	link XIZ,0x0000	; F0107E  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F01082  cp (XIZ+0x08),0x00
	jr	nz, OldCopy_ExitKey_SoundEditPitchTune_Skip	; F01086  jr NZ,0xf0109b
	pushw	0	; F01088  push 0x0000
	call	16625258	; F0108B  call 0xfdae6a
	pushw	0	; F0108F  push 0x0000
	pushw	128	; F01092  push 0x0080
	call	sub_FDA6FC	; F01095  call 0xfda6fc
	inc	6, xsp	; F01099  inc 6,XSP
OldCopy_ExitKey_SoundEditPitchTune_Skip:
	unlk XIZ	; F0109B  unlk XIZ
	ret	; F0109D  ret
; OldCopy_SoftKeyCol1_SoundEditPitchEnvelope1: the older build's copy of SoftKeyCol1_SoundEditPitchEnvelope1 (0xF0A4BE = this + 0x9420), equal to it in all 10
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol1_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0109E  link XIZ,0x0000
	pushw	0	; F010A2  push 0x0000
	pushw	9	; F010A5  push 0x0009
	ld	bc, (xiz+8)	; F010A8  ld BC,(XIZ+0x08)
	extz	bc	; F010AB  extz BC
	pushw	bc	; F010AD  push BC
	call	sub_FDC438	; F010AE  call 0xfdc438
	inc	6, xsp	; F010B2  inc 6,XSP
	unlk XIZ	; F010B4  unlk XIZ
	ret	; F010B6  ret
; OldCopy_SoftKeyCol2_SoundEditPitchEnvelope1: the older build's copy of SoftKeyCol2_SoundEditPitchEnvelope1 (0xF0A4D7 = this + 0x9420), equal to it in all 10
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol2_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F010B7  link XIZ,0x0000
	pushw	0	; F010BB  push 0x0000
	pushw	10	; F010BE  push 0x000a
	ld	bc, (xiz+8)	; F010C1  ld BC,(XIZ+0x08)
	extz	bc	; F010C4  extz BC
	pushw	bc	; F010C6  push BC
	call	16630955	; F010C7  call 0xfdc4ab
	inc	6, xsp	; F010CB  inc 6,XSP
	unlk XIZ	; F010CD  unlk XIZ
	ret	; F010CF  ret
; OldCopy_SoftKeyCol3_SoundEditPitchEnvelope1: the older build's copy of SoftKeyCol3_SoundEditPitchEnvelope1 (0xF0A4F0 = this + 0x9420), equal to it in all 10
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol3_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F010D0  link XIZ,0x0000
	pushw	11	; F010D4  push 0x000b
	pushw	8	; F010D7  push 0x0008
	ld	bc, (xiz+8)	; F010DA  ld BC,(XIZ+0x08)
	extz	bc	; F010DD  extz BC
	pushw	bc	; F010DF  push BC
	call	16631070	; F010E0  call 0xfdc51e
	inc	6, xsp	; F010E4  inc 6,XSP
	unlk XIZ	; F010E6  unlk XIZ
	ret	; F010E8  ret
; OldCopy_SoftKeyCol4_SoundEditPitchEnvelope1: the older build's copy of SoftKeyCol4_SoundEditPitchEnvelope1 (0xF0A509 = this + 0x9420), equal to it in all 10
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol4_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F010E9  link XIZ,0x0000
	pushw	0	; F010ED  push 0x0000
	pushw	12	; F010F0  push 0x000c
	ld	bc, (xiz+8)	; F010F3  ld BC,(XIZ+0x08)
	extz	bc	; F010F6  extz BC
	pushw	bc	; F010F8  push BC
	call	sub_FDC5BB	; F010F9  call 0xfdc5bb
	inc	6, xsp	; F010FD  inc 6,XSP
	unlk XIZ	; F010FF  unlk XIZ
	ret	; F01101  ret
; OldCopy_SoftKeyCol5_SoundEditPitchEnvelope1: the older build's copy of SoftKeyCol5_SoundEditPitchEnvelope1 (0xF0A522 = this + 0x9420), equal to it in all 10
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol5_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F01102  link XIZ,0x0000
	pushw	13	; F01106  push 0x000d
	pushw	16	; F01109  push 0x0010
	ld	bc, (xiz+8)	; F0110C  ld BC,(XIZ+0x08)
	extz	bc	; F0110F  extz BC
	pushw	bc	; F01111  push BC
	call	sub_FDC62E	; F01112  call 0xfdc62e
	inc	6, xsp	; F01116  inc 6,XSP
	unlk XIZ	; F01118  unlk XIZ
	ret	; F0111A  ret
; OldCopy_SoftKeyCol6_SoundEditPitchEnvelope1: the older build's copy of SoftKeyCol6_SoundEditPitchEnvelope1 (0xF0A53B = this + 0x9420), equal to it in all 10
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol6_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0111B  link XIZ,0x0000
	pushw	0	; F0111F  push 0x0000
	pushw	14	; F01122  push 0x000e
	ld	bc, (xiz+8)	; F01125  ld BC,(XIZ+0x08)
	extz	bc	; F01128  extz BC
	pushw	bc	; F0112A  push BC
	call	sub_FDC6CB	; F0112B  call 0xfdc6cb
	inc	6, xsp	; F0112F  inc 6,XSP
	unlk XIZ	; F01131  unlk XIZ
	ret	; F01133  ret
; OldCopy_SoftKeyCol7_SoundEditPitchEnvelope1: the older build's copy of SoftKeyCol7_SoundEditPitchEnvelope1 (0xF0A554 = this + 0x9420), equal to it in all 10
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol7_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F01134  link XIZ,0x0000
	pushw	15	; F01138  push 0x000f
	pushw	7	; F0113B  push 0x0007
	ld	bc, (xiz+8)	; F0113E  ld BC,(XIZ+0x08)
	extz	bc	; F01141  extz BC
	pushw	bc	; F01143  push BC
	call	16631614	; F01144  call 0xfdc73e
	inc	6, xsp	; F01148  inc 6,XSP
	unlk XIZ	; F0114A  unlk XIZ
	ret	; F0114C  ret
; OldCopy_LcdKeyRow1_SoundEditPitchEnvelope1: the older build's copy of LcdKeyRow1_SoundEditPitchEnvelope1 (0xF0A56D = this + 0x9420), equal to it in all 6
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow1_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0114D  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F01151  cp (XIZ+0x08),0x00
	jr	z, OldCopy_LcdKeyRow1_SoundEditPitchEnvelope1_Skip	; F01155  jr Z,0xf0115b
	call	sub_FDB30B	; F01157  call 0xfdb30b
OldCopy_LcdKeyRow1_SoundEditPitchEnvelope1_Skip:
	unlk XIZ	; F0115B  unlk XIZ
	ret	; F0115D  ret
; OldCopy_LcdKeyRow2_SoundEditPitchEnvelope1: the older build's copy of LcdKeyRow2_SoundEditPitchEnvelope1 (0xF0A57E = this + 0x9420), equal to it in all 17
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow2_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0115E  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F01162  cp (XIZ+0x08),0x00
	jr	nz, OldCopy_LcdKeyRow2_SoundEditPitchEnvelope1_Skip	; F01166  jr NZ,0xf01170
	pushw	0	; F01168  push 0x0000
	pushw	135	; F0116B  push 0x0087
	jr	OldCopy_LcdKeyRow2_SoundEditPitchEnvelope1_Join	; F0116E  jr T,0xf01182
OldCopy_LcdKeyRow2_SoundEditPitchEnvelope1_Skip:
	pushw	1	; F01170  push 0x0001
	call	sub_FDB8D1	; F01173  call 0xfdb8d1
	popw	bc	; F01177  pop BC
	cp	a, 0:i3	; F01178  cp A,0
	jr	z, OldCopy_LcdKeyRow2_SoundEditPitchEnvelope1_Skip2	; F0117A  jr Z,0xf01187
	pushw	1	; F0117C  push 0x0001
	pushw	136	; F0117F  push 0x0088
OldCopy_LcdKeyRow2_SoundEditPitchEnvelope1_Join:
	call	sub_FDA6FC	; F01182  call 0xfda6fc
	pop	xiy	; F01186  pop XIY
OldCopy_LcdKeyRow2_SoundEditPitchEnvelope1_Skip2:
	unlk XIZ	; F01187  unlk XIZ
	ret	; F01189  ret
; OldCopy_LcdKeyRow3_SoundEditPitchEnvelope1: the older build's copy of LcdKeyRow3_SoundEditPitchEnvelope1 (0xF0A5AA = this + 0x9420), equal to it in all 17
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow3_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0118A  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0118E  cp (XIZ+0x08),0x00
	jr	nz, OldCopy_LcdKeyRow3_SoundEditPitchEnvelope1_Skip	; F01192  jr NZ,0xf0119c
	pushw	0	; F01194  push 0x0000
	pushw	138	; F01197  push 0x008a
	jr	OldCopy_LcdKeyRow3_SoundEditPitchEnvelope1_Join	; F0119A  jr T,0xf011ae
OldCopy_LcdKeyRow3_SoundEditPitchEnvelope1_Skip:
	pushw	2	; F0119C  push 0x0002
	call	sub_FDB8D1	; F0119F  call 0xfdb8d1
	popw	bc	; F011A3  pop BC
	cp	a, 0:i3	; F011A4  cp A,0
	jr	z, OldCopy_LcdKeyRow3_SoundEditPitchEnvelope1_Skip2	; F011A6  jr Z,0xf011b3
	pushw	1	; F011A8  push 0x0001
	pushw	136	; F011AB  push 0x0088
OldCopy_LcdKeyRow3_SoundEditPitchEnvelope1_Join:
	call	sub_FDA6FC	; F011AE  call 0xfda6fc
	pop	xiy	; F011B2  pop XIY
OldCopy_LcdKeyRow3_SoundEditPitchEnvelope1_Skip2:
	unlk XIZ	; F011B3  unlk XIZ
	ret	; F011B5  ret
; OldCopy_LcdKeyRow4_SoundEditPitchEnvelope1: the older build's copy of LcdKeyRow4_SoundEditPitchEnvelope1 (0xF0A5D6 = this + 0x9420), equal to it in all 18
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow4_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F011B6  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F011BA  cp (XIZ+0x08),0x00
	jr	nz, OldCopy_LcdKeyRow4_SoundEditPitchEnvelope1_Skip	; F011BE  jr NZ,0xf011ca
	pushw	0	; F011C0  push 0x0000
	call	sub_FDC3F9	; F011C3  call 0xfdc3f9
	popw	bc	; F011C7  pop BC
	jr	OldCopy_LcdKeyRow4_SoundEditPitchEnvelope1_Join	; F011C8  jr T,0xf011e1
OldCopy_LcdKeyRow4_SoundEditPitchEnvelope1_Skip:
	pushw	3	; F011CA  push 0x0003
	call	sub_FDB8D1	; F011CD  call 0xfdb8d1
	popw	bc	; F011D1  pop BC
	cp	a, 0:i3	; F011D2  cp A,0
	jr	z, OldCopy_LcdKeyRow4_SoundEditPitchEnvelope1_Join	; F011D4  jr Z,0xf011e1
	pushw	1	; F011D6  push 0x0001
	pushw	136	; F011D9  push 0x0088
	call	sub_FDA6FC	; F011DC  call 0xfda6fc
	pop	xiy	; F011E0  pop XIY
OldCopy_LcdKeyRow4_SoundEditPitchEnvelope1_Join:
	unlk XIZ	; F011E1  unlk XIZ
	ret	; F011E3  ret
; OldCopy_LcdKeyRow5_SoundEditPitchEnvelope1: the older build's copy of LcdKeyRow5_SoundEditPitchEnvelope1 (0xF0A604 = this + 0x9420), equal to it in all 18
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow5_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F011E4  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F011E8  cp (XIZ+0x08),0x00
	jr	nz, OldCopy_LcdKeyRow5_SoundEditPitchEnvelope1_Skip	; F011EC  jr NZ,0xf011f8
	pushw	1	; F011EE  push 0x0001
	call	sub_FDC3F9	; F011F1  call 0xfdc3f9
	popw	bc	; F011F5  pop BC
	jr	sub_F01200_Join	; F011F6  jr T,0xf0120f
OldCopy_LcdKeyRow5_SoundEditPitchEnvelope1_Skip:
	pushw	4	; F011F8  push 0x0004
	call	sub_FDB8D1	; F011FB  call 0xfdb8d1
	popw	bc	; F011FF  pop BC
sub_F01200:
	cp	a, 0:i3	; F01200  cp A,0
	jr	z, sub_F01200_Join	; F01202  jr Z,0xf0120f
	pushw	1	; F01204  push 0x0001
	pushw	136	; F01207  push 0x0088
	call	sub_FDA6FC	; F0120A  call 0xfda6fc
	pop	xiy	; F0120E  pop XIY
sub_F01200_Join:
	unlk XIZ	; F0120F  unlk XIZ
	ret	; F01211  ret
; OldCopy_PageKey_SoundEditPitchEnvelope1: the older build's copy of PageKey_SoundEditPitchEnvelope1 (0xF0A632 = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_PageKey_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F01212  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F01216  cp (XIZ+0x08),0x00
	jr	nz, sub_F01200_Skip	; F0121A  jr NZ,0xf01227
	pushw	0	; F0121C  push 0x0000
	pushw	137	; F0121F  push 0x0089
	call	sub_FDA6FC	; F01222  call 0xfda6fc
	pop	xiy	; F01226  pop XIY
sub_F01200_Skip:
	unlk XIZ	; F01227  unlk XIZ
	ret	; F01229  ret
; OldCopy_ExitKey_SoundEditPitchEnvelope1: the older build's copy of ExitKey_SoundEditPitchEnvelope1 (0xF0A64A = this + 0x9420), equal to it in all 11
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_ExitKey_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0122A  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0122E  cp (XIZ+0x08),0x00
	jr	nz, OldCopy_ExitKey_SoundEditPitchEnvelope1_Skip	; F01232  jr NZ,0xf01247
	pushw	0	; F01234  push 0x0000
	call	16625258	; F01237  call 0xfdae6a
	pushw	0	; F0123B  push 0x0000
	pushw	128	; F0123E  push 0x0080
	call	sub_FDA6FC	; F01241  call 0xfda6fc
	inc	6, xsp	; F01245  inc 6,XSP
OldCopy_ExitKey_SoundEditPitchEnvelope1_Skip:
	unlk XIZ	; F01247  unlk XIZ
	ret	; F01249  ret
; OldCopy_SoftKeyCol2_SoundEditPitchEnvelope2: the older build's copy of SoftKeyCol2_SoundEditPitchEnvelope2 (0xF0A66A = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol2_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F0124A  link XIZ,0x0000
	pushw	20	; F0124E  push 0x0014
	ld	bc, (xiz+8)	; F01251  ld BC,(XIZ+0x08)
	extz	bc	; F01254  extz BC
	pushw	bc	; F01256  push BC
	call	16631771	; F01257  call 0xfdc7db
	pop	xbc	; F0125B  pop XBC
	unlk XIZ	; F0125C  unlk XIZ
	ret	; F0125E  ret
; OldCopy_SoftKeyCol3_SoundEditPitchEnvelope2: the older build's copy of SoftKeyCol3_SoundEditPitchEnvelope2 (0xF0A67F = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol3_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F0125F  link XIZ,0x0000
	pushw	21	; F01263  push 0x0015
	ld	bc, (xiz+8)	; F01266  ld BC,(XIZ+0x08)
	extz	bc	; F01269  extz BC
	pushw	bc	; F0126B  push BC
	call	sub_FDC87E	; F0126C  call 0xfdc87e
	pop	xbc	; F01270  pop XBC
	unlk XIZ	; F01271  unlk XIZ
	ret	; F01273  ret
; OldCopy_SoftKeyCol4_SoundEditPitchEnvelope2: the older build's copy of SoftKeyCol4_SoundEditPitchEnvelope2 (0xF0A694 = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol4_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F01274  link XIZ,0x0000
	pushw	22	; F01278  push 0x0016
	ld	bc, (xiz+8)	; F0127B  ld BC,(XIZ+0x08)
	extz	bc	; F0127E  extz BC
	pushw	bc	; F01280  push BC
	call	16632097	; F01281  call 0xfdc921
	pop	xbc	; F01285  pop XBC
	unlk XIZ	; F01286  unlk XIZ
	ret	; F01288  ret
; OldCopy_SoftKeyCol5_SoundEditPitchEnvelope2: the older build's copy of SoftKeyCol5_SoundEditPitchEnvelope2 (0xF0A6A9 = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol5_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F01289  link XIZ,0x0000
	pushw	19	; F0128D  push 0x0013
	ld	bc, (xiz+8)	; F01290  ld BC,(XIZ+0x08)
	extz	bc	; F01293  extz BC
	pushw	bc	; F01295  push BC
	call	sub_FDC9C4	; F01296  call 0xfdc9c4
	pop	xbc	; F0129A  pop XBC
	unlk XIZ	; F0129B  unlk XIZ
	ret	; F0129D  ret
; OldCopy_SoftKeyCol7_SoundEditPitchEnvelope2: the older build's copy of SoftKeyCol7_SoundEditPitchEnvelope2 (0xF0A6BE = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol7_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F0129E  link XIZ,0x0000
	pushw	17	; F012A2  push 0x0011
	ld	bc, (xiz+8)	; F012A5  ld BC,(XIZ+0x08)
	extz	bc	; F012A8  extz BC
	pushw	bc	; F012AA  push BC
	call	16632362	; F012AB  call 0xfdca2a
	pop	xbc	; F012AF  pop XBC
	unlk XIZ	; F012B0  unlk XIZ
	ret	; F012B2  ret
; OldCopy_SoftKeyCol8_SoundEditPitchEnvelope2: the older build's copy of SoftKeyCol8_SoundEditPitchEnvelope2 (0xF0A6D3 = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol8_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F012B3  link XIZ,0x0000
	pushw	18	; F012B7  push 0x0012
	ld	bc, (xiz+8)	; F012BA  ld BC,(XIZ+0x08)
	extz	bc	; F012BD  extz BC
	pushw	bc	; F012BF  push BC
	call	16632456	; F012C0  call 0xfdca88
	pop	xbc	; F012C4  pop XBC
	unlk XIZ	; F012C5  unlk XIZ
	ret	; F012C7  ret
; OldCopy_LcdKeyRow1_SoundEditPitchEnvelope2: the older build's copy of LcdKeyRow1_SoundEditPitchEnvelope2 (0xF0A6E8 = this + 0x9420), equal to it in all 6
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow1_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F012C8  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F012CC  cp (XIZ+0x08),0x00
	jr	z, OldCopy_LcdKeyRow1_SoundEditPitchEnvelope2_Skip	; F012D0  jr Z,0xf012d6
	call	sub_FDB30B	; F012D2  call 0xfdb30b
OldCopy_LcdKeyRow1_SoundEditPitchEnvelope2_Skip:
	unlk XIZ	; F012D6  unlk XIZ
	ret	; F012D8  ret
; OldCopy_LcdKeyRow2_SoundEditPitchEnvelope2: the older build's copy of LcdKeyRow2_SoundEditPitchEnvelope2 (0xF0A6F9 = this + 0x9420), equal to it in all 17
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow2_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F012D9  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F012DD  cp (XIZ+0x08),0x00
	jr	nz, OldCopy_LcdKeyRow2_SoundEditPitchEnvelope2_Skip	; F012E1  jr NZ,0xf012eb
	pushw	0	; F012E3  push 0x0000
	pushw	135	; F012E6  push 0x0087
	jr	OldCopy_LcdKeyRow2_SoundEditPitchEnvelope2_Join	; F012E9  jr T,0xf012fd
OldCopy_LcdKeyRow2_SoundEditPitchEnvelope2_Skip:
	pushw	1	; F012EB  push 0x0001
	call	sub_FDB8D1	; F012EE  call 0xfdb8d1
	popw	bc	; F012F2  pop BC
	cp	a, 0:i3	; F012F3  cp A,0
	jr	z, OldCopy_LcdKeyRow2_SoundEditPitchEnvelope2_Skip2	; F012F5  jr Z,0xf01302
	pushw	1	; F012F7  push 0x0001
	pushw	137	; F012FA  push 0x0089
OldCopy_LcdKeyRow2_SoundEditPitchEnvelope2_Join:
	call	sub_FDA6FC	; F012FD  call 0xfda6fc
	pop	xiy	; F01301  pop XIY
OldCopy_LcdKeyRow2_SoundEditPitchEnvelope2_Skip2:
	unlk XIZ	; F01302  unlk XIZ
	ret	; F01304  ret
; OldCopy_LcdKeyRow3_SoundEditPitchEnvelope2: the older build's copy of LcdKeyRow3_SoundEditPitchEnvelope2 (0xF0A725 = this + 0x9420), equal to it in all 17
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow3_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F01305  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F01309  cp (XIZ+0x08),0x00
	jr	nz, OldCopy_LcdKeyRow3_SoundEditPitchEnvelope2_Skip	; F0130D  jr NZ,0xf01317
	pushw	0	; F0130F  push 0x0000
	pushw	138	; F01312  push 0x008a
	jr	OldCopy_LcdKeyRow3_SoundEditPitchEnvelope2_Join	; F01315  jr T,0xf01329
OldCopy_LcdKeyRow3_SoundEditPitchEnvelope2_Skip:
	pushw	2	; F01317  push 0x0002
	call	sub_FDB8D1	; F0131A  call 0xfdb8d1
	popw	bc	; F0131E  pop BC
	cp	a, 0:i3	; F0131F  cp A,0
	jr	z, OldCopy_LcdKeyRow3_SoundEditPitchEnvelope2_Skip2	; F01321  jr Z,0xf0132e
	pushw	1	; F01323  push 0x0001
	pushw	137	; F01326  push 0x0089
OldCopy_LcdKeyRow3_SoundEditPitchEnvelope2_Join:
	call	sub_FDA6FC	; F01329  call 0xfda6fc
	pop	xiy	; F0132D  pop XIY
OldCopy_LcdKeyRow3_SoundEditPitchEnvelope2_Skip2:
	unlk XIZ	; F0132E  unlk XIZ
	ret	; F01330  ret
; OldCopy_LcdKeyRow4_SoundEditPitchEnvelope2: the older build's copy of LcdKeyRow4_SoundEditPitchEnvelope2 (0xF0A751 = this + 0x9420), equal to it in all 14
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow4_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F01331  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F01335  cp (XIZ+0x08),0x00
	jr	z, OldCopy_LcdKeyRow4_SoundEditPitchEnvelope2_Skip	; F01339  jr Z,0xf01352
	pushw	3	; F0133B  push 0x0003
	call	sub_FDB8D1	; F0133E  call 0xfdb8d1
	popw	bc	; F01342  pop BC
	cp	a, 0:i3	; F01343  cp A,0
	jr	z, OldCopy_LcdKeyRow4_SoundEditPitchEnvelope2_Skip	; F01345  jr Z,0xf01352
	pushw	1	; F01347  push 0x0001
	pushw	137	; F0134A  push 0x0089
	call	sub_FDA6FC	; F0134D  call 0xfda6fc
	pop	xiy	; F01351  pop XIY
OldCopy_LcdKeyRow4_SoundEditPitchEnvelope2_Skip:
	unlk XIZ	; F01352  unlk XIZ
	ret	; F01354  ret
; OldCopy_LcdKeyRow5_SoundEditPitchEnvelope2: the older build's copy of LcdKeyRow5_SoundEditPitchEnvelope2 (0xF0A775 = this + 0x9420), equal to it in all 14
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow5_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F01355  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F01359  cp (XIZ+0x08),0x00
	jr	z, OldCopy_LcdKeyRow5_SoundEditPitchEnvelope2_Skip	; F0135D  jr Z,0xf01376
	pushw	4	; F0135F  push 0x0004
	call	sub_FDB8D1	; F01362  call 0xfdb8d1
	popw	bc	; F01366  pop BC
	cp	a, 0:i3	; F01367  cp A,0
	jr	z, OldCopy_LcdKeyRow5_SoundEditPitchEnvelope2_Skip	; F01369  jr Z,0xf01376
	pushw	1	; F0136B  push 0x0001
	pushw	137	; F0136E  push 0x0089
	call	sub_FDA6FC	; F01371  call 0xfda6fc
	pop	xiy	; F01375  pop XIY
OldCopy_LcdKeyRow5_SoundEditPitchEnvelope2_Skip:
	unlk XIZ	; F01376  unlk XIZ
	ret	; F01378  ret
; OldCopy_PageKey_SoundEditPitchEnvelope2: the older build's copy of PageKey_SoundEditPitchEnvelope2 (0xF0A799 = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_PageKey_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F01379  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0137D  cp (XIZ+0x08),0x00
	jr	z, OldCopy_PageKey_SoundEditPitchEnvelope2_Skip	; F01381  jr Z,0xf0138e
	pushw	0	; F01383  push 0x0000
	pushw	136	; F01386  push 0x0088
	call	sub_FDA6FC	; F01389  call 0xfda6fc
	pop	xiy	; F0138D  pop XIY
OldCopy_PageKey_SoundEditPitchEnvelope2_Skip:
	unlk XIZ	; F0138E  unlk XIZ
	ret	; F01390  ret
; OldCopy_ExitKey_SoundEditPitchEnvelope2: the older build's copy of ExitKey_SoundEditPitchEnvelope2 (0xF0A7B1 = this + 0x9420), equal to it in all 11
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_ExitKey_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F01391  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F01395  cp (XIZ+0x08),0x00
	jr	nz, OldCopy_ExitKey_SoundEditPitchEnvelope2_Skip	; F01399  jr NZ,0xf013ae
	pushw	0	; F0139B  push 0x0000
	call	16625258	; F0139E  call 0xfdae6a
	pushw	0	; F013A2  push 0x0000
	pushw	128	; F013A5  push 0x0080
	call	sub_FDA6FC	; F013A8  call 0xfda6fc
	inc	6, xsp	; F013AC  inc 6,XSP
OldCopy_ExitKey_SoundEditPitchEnvelope2_Skip:
	unlk XIZ	; F013AE  unlk XIZ
	ret	; F013B0  ret
; OldCopy_SoftKeyCol2_SoundEditPitchLfo: the older build's copy of SoftKeyCol2_SoundEditPitchLfo (0xF0A7D1 = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol2_SoundEditPitchLfo:
	link XIZ,0x0000	; F013B1  link XIZ,0x0000
	pushw	1	; F013B5  push 0x0001
	ld	bc, (xiz+8)	; F013B8  ld BC,(XIZ+0x08)
	extz	bc	; F013BB  extz BC
	pushw	bc	; F013BD  push BC
	call	sub_FDC0FD	; F013BE  call 0xfdc0fd
	pop	xbc	; F013C2  pop XBC
	unlk XIZ	; F013C3  unlk XIZ
	ret	; F013C5  ret
; OldCopy_SoftKeyCol3_SoundEditPitchLfo: the older build's copy of SoftKeyCol3_SoundEditPitchLfo (0xF0A7E6 = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol3_SoundEditPitchLfo:
	link XIZ,0x0000	; F013C6  link XIZ,0x0000
	pushw	1	; F013CA  push 0x0001
	ld	bc, (xiz+8)	; F013CD  ld BC,(XIZ+0x08)
	extz	bc	; F013D0  extz BC
	pushw	bc	; F013D2  push BC
	call	16630089	; F013D3  call 0xfdc149
	pop	xbc	; F013D7  pop XBC
	unlk XIZ	; F013D8  unlk XIZ
	ret	; F013DA  ret
; OldCopy_SoftKeyCol4_SoundEditPitchLfo: the older build's copy of SoftKeyCol4_SoundEditPitchLfo (0xF0A7FB = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol4_SoundEditPitchLfo:
	link XIZ,0x0000	; F013DB  link XIZ,0x0000
	pushw	1	; F013DF  push 0x0001
	ld	bc, (xiz+8)	; F013E2  ld BC,(XIZ+0x08)
	extz	bc	; F013E5  extz BC
	pushw	bc	; F013E7  push BC
	call	16630204	; F013E8  call 0xfdc1bc
	pop	xbc	; F013EC  pop XBC
	unlk XIZ	; F013ED  unlk XIZ
	ret	; F013EF  ret
; OldCopy_SoftKeyCol5_SoundEditPitchLfo: the older build's copy of SoftKeyCol5_SoundEditPitchLfo (0xF0A810 = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol5_SoundEditPitchLfo:
	link XIZ,0x0000	; F013F0  link XIZ,0x0000
	pushw	1	; F013F4  push 0x0001
	ld	bc, (xiz+8)	; F013F7  ld BC,(XIZ+0x08)
	extz	bc	; F013FA  extz BC
	pushw	bc	; F013FC  push BC
	call	sub_FDC22F	; F013FD  call 0xfdc22f
	pop	xbc	; F01401  pop XBC
	unlk XIZ	; F01402  unlk XIZ
	ret	; F01404  ret
; OldCopy_SoftKeyCol6_SoundEditPitchLfo: the older build's copy of SoftKeyCol6_SoundEditPitchLfo (0xF0A825 = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol6_SoundEditPitchLfo:
	link XIZ,0x0000	; F01405  link XIZ,0x0000
	pushw	1	; F01409  push 0x0001
	ld	bc, (xiz+8)	; F0140C  ld BC,(XIZ+0x08)
	extz	bc	; F0140F  extz BC
	pushw	bc	; F01411  push BC
	call	sub_FDC2A2	; F01412  call 0xfdc2a2
	pop	xbc	; F01416  pop XBC
	unlk XIZ	; F01417  unlk XIZ
	ret	; F01419  ret
; OldCopy_SoftKeyCol7_SoundEditPitchLfo: the older build's copy of SoftKeyCol7_SoundEditPitchLfo (0xF0A83A = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol7_SoundEditPitchLfo:
	link XIZ,0x0000	; F0141A  link XIZ,0x0000
	pushw	1	; F0141E  push 0x0001
	ld	bc, (xiz+8)	; F01421  ld BC,(XIZ+0x08)
	extz	bc	; F01424  extz BC
	pushw	bc	; F01426  push BC
	call	16630547	; F01427  call 0xfdc313
	pop	xbc	; F0142B  pop XBC
	unlk XIZ	; F0142C  unlk XIZ
	ret	; F0142E  ret
; OldCopy_SoftKeyCol8_SoundEditPitchLfo: the older build's copy of SoftKeyCol8_SoundEditPitchLfo (0xF0A84F = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_SoftKeyCol8_SoundEditPitchLfo:
	link XIZ,0x0000	; F0142F  link XIZ,0x0000
	pushw	1	; F01433  push 0x0001
	ld	bc, (xiz+8)	; F01436  ld BC,(XIZ+0x08)
	extz	bc	; F01439  extz BC
	pushw	bc	; F0143B  push BC
	call	16630662	; F0143C  call 0xfdc386
	pop	xbc	; F01440  pop XBC
	unlk XIZ	; F01441  unlk XIZ
	ret	; F01443  ret
; OldCopy_LcdKeyRow1_SoundEditPitchLfo: the older build's copy of LcdKeyRow1_SoundEditPitchLfo (0xF0A864 = this + 0x9420), equal to it in all 11
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow1_SoundEditPitchLfo:
	link XIZ,0x0000	; F01444  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F01448  cp (XIZ+0x08),0x00
	jr	nz, OldCopy_LcdKeyRow1_SoundEditPitchLfo_Skip	; F0144C  jr NZ,0xf0145b
	pushw	0	; F0144E  push 0x0000
	pushw	136	; F01451  push 0x0088
	call	sub_FDA6FC	; F01454  call 0xfda6fc
	pop	xiy	; F01458  pop XIY
	jr	OldCopy_LcdKeyRow1_SoundEditPitchLfo_Join	; F01459  jr T,0xf0145f
OldCopy_LcdKeyRow1_SoundEditPitchLfo_Skip:
	call	sub_FDB30B	; F0145B  call 0xfdb30b
OldCopy_LcdKeyRow1_SoundEditPitchLfo_Join:
	unlk XIZ	; F0145F  unlk XIZ
	ret	; F01461  ret
; OldCopy_LcdKeyRow2_SoundEditPitchLfo: the older build's copy of LcdKeyRow2_SoundEditPitchLfo (0xF0A882 = this + 0x9420), equal to it in all 13
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow2_SoundEditPitchLfo:
	link XIZ,0x0000	; F01462  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F01466  cp (XIZ+0x08),0x00
	jr	nz, OldCopy_LcdKeyRow2_SoundEditPitchLfo_Skip	; F0146A  jr NZ,0xf01478
	pushw	0	; F0146C  push 0x0000
	pushw	135	; F0146F  push 0x0087
	call	sub_FDA6FC	; F01472  call 0xfda6fc
	jr	OldCopy_LcdKeyRow2_SoundEditPitchLfo_Skip2	; F01476  jr T,0xf01482
OldCopy_LcdKeyRow2_SoundEditPitchLfo_Skip:
	pushw	1	; F01478  push 0x0001
	pushw	1	; F0147B  push 0x0001
	call	16627971	; F0147E  call 0xfdb903
OldCopy_LcdKeyRow2_SoundEditPitchLfo_Skip2:
	pop	xiy	; F01482  pop XIY
	unlk XIZ	; F01483  unlk XIZ
	ret	; F01485  ret
; OldCopy_LcdKeyRow3_SoundEditPitchLfo: the older build's copy of LcdKeyRow3_SoundEditPitchLfo (0xF0A8A6 = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow3_SoundEditPitchLfo:
	link XIZ,0x0000	; F01486  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0148A  cp (XIZ+0x08),0x00
	jr	z, OldCopy_LcdKeyRow3_SoundEditPitchLfo_Skip	; F0148E  jr Z,0xf0149b
	pushw	2	; F01490  push 0x0002
	pushw	1	; F01493  push 0x0001
	call	16627971	; F01496  call 0xfdb903
	pop	xiy	; F0149A  pop XIY
OldCopy_LcdKeyRow3_SoundEditPitchLfo_Skip:
	unlk XIZ	; F0149B  unlk XIZ
	ret	; F0149D  ret
; OldCopy_LcdKeyRow4_SoundEditPitchLfo: the older build's copy of LcdKeyRow4_SoundEditPitchLfo (0xF0A8BE = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow4_SoundEditPitchLfo:
	link XIZ,0x0000	; F0149E  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F014A2  cp (XIZ+0x08),0x00
	jr	z, OldCopy_LcdKeyRow4_SoundEditPitchLfo_Skip	; F014A6  jr Z,0xf014b3
	pushw	3	; F014A8  push 0x0003
	pushw	1	; F014AB  push 0x0001
	call	16627971	; F014AE  call 0xfdb903
	pop	xiy	; F014B2  pop XIY
OldCopy_LcdKeyRow4_SoundEditPitchLfo_Skip:
	unlk XIZ	; F014B3  unlk XIZ
	ret	; F014B5  ret
; OldCopy_LcdKeyRow5_SoundEditPitchLfo: the older build's copy of LcdKeyRow5_SoundEditPitchLfo (0xF0A8D6 = this + 0x9420), equal to it in all 9
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_LcdKeyRow5_SoundEditPitchLfo:
	link XIZ,0x0000	; F014B6  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F014BA  cp (XIZ+0x08),0x00
	jr	z, OldCopy_LcdKeyRow5_SoundEditPitchLfo_Skip	; F014BE  jr Z,0xf014cb
	pushw	4	; F014C0  push 0x0004
	pushw	1	; F014C3  push 0x0001
	call	16627971	; F014C6  call 0xfdb903
	pop	xiy	; F014CA  pop XIY
OldCopy_LcdKeyRow5_SoundEditPitchLfo_Skip:
	unlk XIZ	; F014CB  unlk XIZ
	ret	; F014CD  ret
; OldCopy_ExitKey_SoundEditPitchLfo: the older build's copy of ExitKey_SoundEditPitchLfo (0xF0A8EE = this + 0x9420), equal to it in all 11
;   instructions but the targets of its branches and calls, which land on that older build's prom_a
;   (FINDINGS-prom_b-f00c4d-orphan-cluster.md N2; notes/prom_b_f00c4d_oldcopy_names.py).
OldCopy_ExitKey_SoundEditPitchLfo:
	link XIZ,0x0000	; F014CE  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F014D2  cp (XIZ+0x08),0x00
	jr	nz, OldCopy_ExitKey_SoundEditPitchLfo_Skip	; F014D6  jr NZ,0xf014eb
	pushw	0	; F014D8  push 0x0000
	call	16625258	; F014DB  call 0xfdae6a
	pushw	0	; F014DF  push 0x0000
	pushw	128	; F014E2  push 0x0080
	call	sub_FDA6FC	; F014E5  call 0xfda6fc
	inc	6, xsp	; F014E9  inc 6,XSP
OldCopy_ExitKey_SoundEditPitchLfo_Skip:
	unlk XIZ	; F014EB  unlk XIZ
	ret	; F014ED  ret

; --------------------------------------------------------------------------
; PtrArray_F014EE -- 196 4-byte pointers: 10 whole records of 18 slots and a
; partial 11th of 16.
; Slot 9 of every record is 0x00000000 and slots 5, 6 and 10 hold the same
; value the way an unfilled slot holds a common stub.  At the other three
; byte phases 0 of 196 words are in prom_a's window; at this one, 185 are.
; ⚠ Emitted as `.long` because the SHAPE is established.  The slots' meaning
;   is deferred -- and see the ANOMALY (N2) before assuming a target is a
;   routine in the prom_a next door.
; --------------------------------------------------------------------------
; census: stale -- the same module's 196-slot array; its targets are that build's prom_a (FINDINGS N2: 58 of 155 on an instruction start, and no constant offset fixes it).
PtrArray_F014EE:
	.long	0x00FDD45D	; F014EE	record 0
	.long	0x00FDD46E	; F014F2
	.long	0x00FDD49C	; F014F6
	.long	0x00FDD4CA	; F014FA
	.long	0x00FDD4F0	; F014FE
	.long	0x00FDA7CE	; F01502
	.long	0x00FDA7CE	; F01506
	.long	0x00FDD52F	; F0150A
	.long	0x00FDD516	; F0150E
	.long	0x00000000	; F01512
	.long	0x00FDA7CE	; F01516
	.long	0x00FDD53C	; F0151A
	.long	0x00FDD584	; F0151E
	.long	0x00FDD61E	; F01522
	.long	0x00FDD6B8	; F01526
	.long	0x00FDD72B	; F0152A
	.long	0x00FDD7C5	; F0152E
	.long	0x00FDD871	; F01532
	.long	0x00FDD90B	; F01536	record 1
	.long	0x00FDD91C	; F0153A
	.long	0x00FDD94A	; F0153E
	.long	0x00FDD978	; F01542
	.long	0x00FDD99E	; F01546
	.long	0x00FDA7CE	; F0154A
	.long	0x00FDA7CE	; F0154E
	.long	0x00FDD9DD	; F01552
	.long	0x00FDD9C4	; F01556
	.long	0x00000000	; F0155A
	.long	0x00FDA7CE	; F0155E
	.long	0x00FDD9EA	; F01562
	.long	0x00FDD9FF	; F01566
	.long	0x00FDDA14	; F0156A
	.long	0x00FDDA29	; F0156E
	.long	0x00FDDA3E	; F01572
	.long	0x00FDDA53	; F01576
	.long	0x00FDDA68	; F0157A
	.long	0x00FDDA7D	; F0157E	record 2
	.long	0x00FDDA9C	; F01582
	.long	0x00FDDAC3	; F01586
	.long	0x00FDDADC	; F0158A
	.long	0x00FDDAF5	; F0158E
	.long	0x00FDA7CE	; F01592
	.long	0x00FDA7CE	; F01596
	.long	0x00FDDB0E	; F0159A
	.long	0x00FDA7CE	; F0159E
	.long	0x00000000	; F015A2
	.long	0x00FDA7CE	; F015A6
	.long	0x00FDDC2B	; F015AA
	.long	0x00FDA7CE	; F015AE
	.long	0x00FDDC92	; F015B2
	.long	0x00FDDCFB	; F015B6
	.long	0x00FDA7CE	; F015BA
	.long	0x00FDDD64	; F015BE
	.long	0x00FDA7CE	; F015C2
	.long	0x00FDDDB6	; F015C6	record 3
	.long	0x00FDDDD5	; F015CA
	.long	0x00FDDE1E	; F015CE
	.long	0x00FDDE75	; F015D2
	.long	0x00FDDEBE	; F015D6
	.long	0x00FDA7CE	; F015DA
	.long	0x00FDA7CE	; F015DE
	.long	0x00FDDF07	; F015E2
	.long	0x00FDA7CE	; F015E6
	.long	0x00000000	; F015EA
	.long	0x00FDA7CE	; F015EE
	.long	0x00FDDF14	; F015F2
	.long	0x00FDDF2C	; F015F6
	.long	0x00FDDF44	; F015FA
	.long	0x00FDDF5C	; F015FE
	.long	0x00FDDF74	; F01602
	.long	0x00FDDF8C	; F01606
	.long	0x00FDDFA4	; F0160A
	.long	0x00FDDFBC	; F0160E	record 4
	.long	0x00FDDFCD	; F01612
	.long	0x00FDDFFB	; F01616
	.long	0x00FDE029	; F0161A
	.long	0x00FDE04F	; F0161E
	.long	0x00FDA7CE	; F01622
	.long	0x00FDA7CE	; F01626
	.long	0x00FDE08E	; F0162A
	.long	0x00FDE075	; F0162E
	.long	0x00000000	; F01632
	.long	0x00FDA7CE	; F01636
	.long	0x00FDE09B	; F0163A
	.long	0x00FDE0B0	; F0163E
	.long	0x00FDE0C5	; F01642
	.long	0x00FDE0DA	; F01646
	.long	0x00FDA7CE	; F0164A
	.long	0x00FDE0EF	; F0164E
	.long	0x00FDE104	; F01652
	.long	0x00FDE119	; F01656	record 5
	.long	0x00FDE12A	; F0165A
	.long	0x00FDE158	; F0165E
	.long	0x00FDE186	; F01662
	.long	0x00FDE1AC	; F01666
	.long	0x00FDA7CE	; F0166A
	.long	0x00FDA7CE	; F0166E
	.long	T_F42098_Nop	; F01672
	.long	0x00FDE1D2	; F01676
	.long	0x00000000	; F0167A
	.long	0x00FDA7CE	; F0167E
	.long	0x00FDE1F8	; F01682
	.long	0x00FDE20D	; F01686
	.long	0x00FDE222	; F0168A
	.long	0x00FDE237	; F0168E
	.long	0x00FDE24C	; F01692
	.long	0x00FDE261	; F01696
	.long	0x00FDE276	; F0169A
	.long	0x00FDE28B	; F0169E	record 6
	.long	0x00FDE2AA	; F016A2
	.long	0x00FDE2D1	; F016A6
	.long	0x00FDE2EA	; F016AA
	.long	0x00FDE303	; F016AE
	.long	0x00FDA7CE	; F016B2
	.long	0x00FDA7CE	; F016B6
	.long	0x00FDE31C	; F016BA
	.long	0x00FDA7CE	; F016BE
	.long	0x00000000	; F016C2
	.long	0x00FDE58E	; F016C6
	.long	0x00FDA7CE	; F016CA
	.long	0x00FDE5D2	; F016CE
	.long	0x00FDE630	; F016D2
	.long	0x00FDA7CE	; F016D6
	.long	0x00FDE68E	; F016DA
	.long	0x00FDE6F0	; F016DE
	.long	0x00FDE74E	; F016E2
	.long	0x00FDE7AC	; F016E6	record 7
	.long	0x00FDE7CB	; F016EA
	.long	0x00FDE7F1	; F016EE
	.long	0x00FDE81F	; F016F2
	.long	0x00FDE845	; F016F6
	.long	0x00FDA7CE	; F016FA
	.long	0x00FDA7CE	; F016FE
	.long	0x00FDE884	; F01702
	.long	0x00FDE86B	; F01706
	.long	0x00000000	; F0170A
	.long	0x00FDE891	; F0170E
	.long	0x00FDA7CE	; F01712
	.long	0x00FDE8D9	; F01716
	.long	0x00FDE8EA	; F0171A
	.long	0x00FDA7CE	; F0171E
	.long	0x00FDE8FB	; F01722
	.long	0x00FDE90C	; F01726
	.long	0x00FDE91D	; F0172A
	.long	0x00FDE92E	; F0172E	record 8
	.long	0x00FDE93F	; F01732
	.long	0x00FDE950	; F01736
	.long	0x00FDE961	; F0173A
	.long	0x00FDE972	; F0173E
	.long	0x00FDA7CE	; F01742
	.long	0x00FDA7CE	; F01746
	.long	0x00FDE99C	; F0174A
	.long	0x00FDE983	; F0174E
	.long	0x00000000	; F01752
	.long	0x00FDE9A9	; F01756
	.long	0x00FDA7CE	; F0175A
	.long	0x00FDA7CE	; F0175E
	.long	0x00FDE9F1	; F01762
	.long	0x00FDEA4F	; F01766
	.long	0x00FDA7CE	; F0176A
	.long	0x00FDA7CE	; F0176E
	.long	0x00FDA7CE	; F01772
	.long	0x00FDEAAD	; F01776	record 9
	.long	0x00FDEACC	; F0177A
	.long	0x00FDEAF2	; F0177E
	.long	0x00FDEB20	; F01782
	.long	0x00FDEB46	; F01786
	.long	0x00FDA7CE	; F0178A
	.long	0x00FDA7CE	; F0178E
	.long	0x00FDEB85	; F01792
	.long	0x00FDEB6C	; F01796
	.long	0x00000000	; F0179A
	.long	0x00FDEB92	; F0179E
	.long	0x00FDA7CE	; F017A2
	.long	0x00FDA7CE	; F017A6
	.long	0x00FDEBDA	; F017AA
	.long	0x00FDEBEB	; F017AE
	.long	0x00FDA7CE	; F017B2
	.long	0x00FDA7CE	; F017B6
	.long	0x00FDA7CE	; F017BA
	.long	0x00FDEBFC	; F017BE	record 10
	.long	0x00FDEC0D	; F017C2
	.long	0x00FDEC1E	; F017C6
	.long	0x00FDEC2F	; F017CA
	.long	0x00FDEC40	; F017CE
	.long	0x00FDA7CE	; F017D2
	.long	0x00FDA7CE	; F017D6
	.long	0x00FDEC6A	; F017DA
	.long	0x00FDEC51	; F017DE
	.long	0x00000000	; F017E2
	.long	0x00FDEC77	; F017E6
	.long	0x00FDA7CE	; F017EA
	.long	0x00FDA7CE	; F017EE
	.long	0x00FDECBB	; F017F2
	.long	0x00FDED19	; F017F6
	.long	0x00FDED77	; F017FA

; --------------------------------------------------------------------------
; 0xF017FE-0xF017FF -- REFUSED, 2 bytes, deliberately still `.byte`.
; The three entries above run 0x00FDECBB, 0x00FDED19, 0x00FDED77: a +0x5E progression
; whose next term, 0x00FDEDD5, has exactly these two bytes as its low half.
; Completing it would need 0xF01800-0xF01801, and those belong to the
; display list at 0xF01800 -- `1C 10` is op 0x1C, length 16, and 6 header
; bytes + the 10 characters of "SOUND EDIT" is exactly 16.  Starting that
; list two bytes later instead gives `6E 00`, a record of length 0, which
; never terminates.  So the entry cannot be completed and is not invented.
; --------------------------------------------------------------------------
	.byte	0xD5, 0xED	; F017FE  low half of a 4-byte entry that has no room

; === END MODULE F00C4D 0xF00C4D-0xF017FF ===

; === END COVER-R1 0xF00000-0xF01800 ===

; ==============================================================================
; 0xF01800-0xF3E15B -- UI DISPLAY LISTS  (129 spans, 4011 records, 39329 bytes)
; ==============================================================================
;
; The WSA1 has no string table.  Every string it shows -- "SOUND EDIT",
; "TONE LAYER", "DSP EFFECT", "CONTROLLER", "AMPLITUDE" -- lives inside a
; byte-coded DISPLAY LIST, executed by one of TWO interpreters, both converted
; below in 0xF31800-0xF32708.
;
; RECORD:   +0  opcode
;           +1  length of the WHOLE record in bytes; the loop advances by it
;           +2  operands, and for interpreter A's text opcodes a run of characters
;
;   interpreter A  0xF31A09, opcode bound 0x24, handler table 0xF31D21 (36 slots)
;                  draws what the RECORD says: fixed text, boxes, bitmaps.
;   interpreter B  0xF31AF0, opcode bound 0x0F, handler table 0xF31DB1 (15 slots)
;                  draws what a VARIABLE says: every one of its handlers opens by
;                  extracting a bit-field from a 16-bit RAM address named in the
;                  record (+2 address, +4 mask, +5 shift).
;
; The two share the (opcode, length) header and NOTHING else -- not the opcode
; space, not the handler table, not the field layout.  A record is attributed to
; an interpreter by the call site that reaches it: `ld XIY,<start>` /
; `ld XIX,<end>` / `call 0xF417F0` (A) or `call 0xF417F4` (B).  Each record below
; is rendered with THAT interpreter's field layout, and B records are marked
; `B op NN` in their header comment.
;
; ⚠ CORRECTED 2026-08-24.  Until this pass every record here was rendered with
; interpreter A's layout, including the 494 that only interpreter B ever runs.
; That is exactly where the "341 records violate the length rule" figure came
; from: judged by A's layout, 353 of B's 494 records disagree -- because they are
; not A's records.  Judged by the OWNING interpreter, the exception count is
; ZERO on both sides: 3,603 A records and 494 B records, first and last of each
; class tested.  Reproduce with
;     python3 notes/prom_b_dl_length_audit.py --edges
; Its implied lengths are read off each handler's own instructions, one line per
; handler, in that script's docstring.
;
; FRAMING, per call site and UN-MERGED: 243 of 244 interpreter-A sites and 158 of
; 162 interpreter-B sites walk their length bytes exactly onto the end address
; the caller passes.  The five that do not are all genuine instruction sequences,
; not artefacts of the byte-level call-site scan; they are dissected in
; notes/FINDINGS-ui-display-list-interpreter-b.md.
;
; ⚠ The span list below is the MERGED one, which is why it holds 4,011 records
; and the un-merged walk finds 4,097.  Merging joins a good site to a bad one at
; 0xF286F9-0xF28750, and the four good records at 0xF286F9 are lost with it; they
; are still .incbin.
;
; `DL_<addr>` labels mark the addresses call sites actually pass as a list start.
; Generated by notes/gen_prom_b_display_lists_v2.py.
;

; ------------------------------------------------------------------
; 0xF01800-0xF01919 -- 35 display-list records, 282 bytes -- interpreter A
;   entered at: 0xF01800, 0xF01873
;   ends used:  0xF01873, 0xF0191A
; ------------------------------------------------------------------
; DL_SoundEditWriteCopy -- the display list at 0xF01800.  Its own text records
;                          read: "SOUND EDIT"; "WRITE"; "COPY".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_SoundEditWriteCopy:
	dl_text16x16_packed	x=110, y=5, text="SOUND EDIT"
	dl_text8x14	x=0, y=36, text="\020 WRITE"
	dl_text8x14	x=0, y=77, text="\020"
	dl_text8x14	x=312, y=35, text="\021"
	dl_text8x10	x=272, y=36, text="COPY"
	dl_text8x14	x=312, y=75, text="\021"
	dl_text8x14	x=0, y=115, text="\020"
	dl_text8x14	x=312, y=114, text="\021"
	dl_text8x14	x=312, y=151, text="\021"
	dl_text8x14	x=0, y=155, text="\020"
	dl_box	x0=12, y0=31, x1=60, y1=50
	dl_box	x0=14, y0=33, x1=58, y1=48
	dl_box	x0=266, y0=30, x1=309, y1=51
	dl_box	x0=268, y0=32, x1=307, y1=49
	dl_value_glyph	glyph=16, x=80, y=1
; DL_ToneLayerDspEffectPitchDigital -- the display list at 0xF01873.  Its own
;                                      text records read: "TONE LAYER"; "DSP
;                                      EFFECT"; "PITCH"; "DIGITAL"; "EFFECT";
;                                      "FILTER"; "CONTROLLER"; "AMPLITUDE" +1
;                                      more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_ToneLayerDspEffectPitchDigital:
	dl_text8x14	x=176, y=82, text="TONE LAYER"
	dl_text8x14	x=176, y=156, text="DSP EFFECT"
	dl_text8x14	x=56, y=156, text="PITCH"
	dl_text8x14	x=176, y=112, text="DIGITAL"
	dl_text8x14	x=216, y=125, text="EFFECT"
	dl_text8x14	x=0, y=194, text="\020"
	dl_text8x14	x=56, y=195, text="FILTER"
	dl_text8x14	x=176, y=195, text="CONTROLLER"
	dl_text8x14	x=312, y=191, text="\021"
	dl_text8x14	x=56, y=118, text="AMPLITUDE"
	dl_text8x14	x=56, y=82, text="MODELING"
	dl_box	x0=15, y0=65, x1=305, y1=217
	dl_value_glyph	glyph=7, x=24, y=150
	dl_value_glyph	glyph=33, x=24, y=188
	dl_value_glyph	glyph=100, x=272, y=74
	dl_value_glyph	glyph=118, x=272, y=112
	dl_value_glyph	glyph=10, x=272, y=150
	dl_value_glyph	glyph=36, x=272, y=188
	dl_value_glyph	glyph=90, x=24, y=74
	dl_value_glyph	glyph=99, x=24, y=112

; === COVER-R1 0xF0191A-0xF01E72 ===
; 0xF0191A-0xF01E71, coverage round 1: 132 of this span's 1368 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 132 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice
;
; ⚠ AMENDED 2026-09-02 (lane promB2).  As at 0xF00000 above: NOT REACHABLE
; stands (0 `call`/`jp` operands in four images land in 0xF0199E-0xF01E71, 0
; routine-directory slots point in), STAYS `.incbin` is withdrawn.  The rest of
; this span is two 12x16 icon cells and six 200-byte bitmaps, and is converted
; below.  ⚠⚠ A re-run of gen_prom_b_cover_round1.py --splice would silently
; revert it -- see the longer note under the 0xF00000 marker.

; --------------------------------------------------------------------------
; Data_F0191A -- 132 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F0191A appears as a 32-bit word at 0xF02F6C 0xF03A23
;               0xF03ADB 0xF03C2B 0xF32836 +1 more; converted code at 0xF5BF46
;               loads it as a 32-bit immediate.  No routine-directory slot and
;               no branch decoded in converted code names it.
; Measured: 53% printable ASCII; a linear decode runs 82 instructions and ends
;           `reti`, with 11% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; ⚠ AMENDED 2026-09-02 (lane promB2): the warning above was right, and the
;   object grid is now known.  0x00F019AA is named as a 32-bit word ten times
;   in the display-list region and 0x00F0191A six times; their difference is
;   144 = 6 * 24, and the first 200-byte bitmap below starts at 0xF019C2 =
;   0xF0191A + 7 * 24.  So this region is SEVEN 24-byte cells, each a 12x16
;   icon (12 columns * 2 pages of 8 rows), and these 132 bytes are 5.5 of them:
;   the cell at 0xF01992 has its upper page here and its lower page in
;   Bitmap_F0199E below.  This block is NOT re-cut here -- doing so is a
;   separate change and this lane owned only the `.incbin` spans.  Evidence:
;   python3 notes/gen_prom_b_f0033f_f0199e.py --evidence --render
; --------------------------------------------------------------------------
Data_F0191A:
	.byte	0x08, 0x10, 0x28, 0x10, 0x08, 0x10, 0x08, 0x10, 0x28, 0x14, 0x00, 0x00, 0x2A, 0x55, 0x20, 0x54	; F0191A  |..(.....(...*U T|
	.byte	0x2A, 0x01, 0x2A, 0x54, 0x08, 0x10, 0x2A, 0x54, 0x08, 0x10, 0x08, 0x10, 0x08, 0x04, 0x2A, 0x55	; F0192A  |*.*T..*T......*U|
	.byte	0x22, 0x01, 0x02, 0x04, 0x08, 0x10, 0x2A, 0x55, 0x00, 0x00, 0x2A, 0x55, 0x22, 0x41, 0x22, 0x41	; F0193A  |".....*U..*U"A"A|
	.byte	0x22, 0x41, 0x02, 0x01, 0x02, 0x15, 0x2A, 0x41, 0x22, 0x41, 0x2A, 0x15, 0x2A, 0x55, 0x22, 0x01	; F0194A  |"A....*A"A*.*U".|
	.byte	0x0A, 0x04, 0x02, 0x41, 0x2A, 0x14, 0x00, 0x00, 0x2A, 0x55, 0x20, 0x40, 0x20, 0x40, 0x20, 0x40	; F0195A  |...A*...*U @ @ @|
	.byte	0x02, 0x01, 0x02, 0x15, 0x2A, 0x41, 0x22, 0x41, 0x2A, 0x15, 0x04, 0x0A, 0x14, 0x0A, 0x14, 0x22	; F0196A  |....*A"A*......"|
	.byte	0x55, 0x2A, 0x04, 0x02, 0x10, 0x08, 0x54, 0x2A, 0x10, 0x08, 0x10, 0x08, 0x14, 0x08, 0x40, 0x20	; F0197A  |U*....T*......@ |
	.byte	0x40, 0x2A, 0x55, 0x22, 0x41, 0x22, 0x41, 0x22, 0x07, 0x18, 0x20, 0x27, 0x4F, 0x4F, 0x4F, 0x4F	; F0198A  |@*U"A"A".. 'OOOO|
	.byte	0x27, 0x20, 0x18, 0x07	; F0199A  |' ..|

; --- BEGIN gen_prom_b_f0033f_f0199e 0xF0199E-0xF01E72 ---
; ============================================================================
; 0xF0199E-0xF01E71 -- ONE ICON PAGE, ONE WHOLE 12x16 ICON, AND SIX 40x40
; BITMAPS THE 0xF5BECE BLITTER DRAWS
; ============================================================================
;
; 1,236 bytes.  DATA: 0 `call nnn` / `jp nnn` operands in any of the four
; ROM images land in this span, and 0 routine-directory slots point in.
;
; ★★ THE SIX 200-BYTE OBJECTS ARE PINNED BY CONVERTED CODE IN THIS FILE.
; 0xF5BECE-0xF5BEFA reads, in this transcription:
;
;       ld XIZ,0x00f5befb      ; the selector table's base
;       xor W,W / sll 0x02,WA  ; index * 4
;       ld XIY,(XIZ+WA)        ; XIY = table[index] -- the source bitmap
;       ld WA,(0x2350) / div A,0x08 / ld HL,(0x2352) / mul L,0x28
;       add HL,WA / ld IX,HL   ; destination = y*40 + x/8
;       ld BC,0x0005           ; 5 pages
;       ld HL,0x0028           ; 40 columns
;       ld A,0x03 / swi 7      ; blit
;
; 5 * 40 = 200, which is exactly the stride between the seven selector
; entries' six distinct targets, and the six objects tile 0xF019C2-0xF01E71
; with no gap and no remainder.  Rendered as 5 pages of 40 columns (a byte
; is one column, MSB the top row of its page) each is a framed 40x40 box
; holding one monotone rising curve -- see below, and `--render`.
;
; ⚠ THE SELECTOR TABLE AT 0xF5BEFB IS ITSELF STILL MIS-FRAMED AS CODE in
;   this file (`cp XWA,(XDE+0x1d)`, `nop`, and four rows marked `[llvm-mc
;   cannot encode this]`).  It is 28 bytes = 7 * 4 and every word is one of
;   the six addresses below.  It is OUTSIDE this span and is deliberately
;   NOT touched here.
;   ⚠ UPDATED 2026-09-25 (lane promb): it is now framed, as
;   CurveBitmapSelector -- seven `.long`s naming these six bitmaps.
;
; ★ THE 24-BYTE ICON GRID IS PINNED BY TEN EXTERNAL REFERENCES.  0x00F019AA
; appears as a 32-bit word ten times in the display-list region, and
; 0x00F0191A -- Data_F0191A above -- six times.  Their difference is 144 =
; 6 * 24, and 0xF019C2 is 0xF0191A + 7 * 24, so the grid ends exactly where
; the curves begin.  A 24-byte cell rendered as 12 columns * 2 pages is a
; 12x16 icon; the last two cells are a filled and a hollow circle.
;
; ⚠ Data_F0191A above is 132 bytes = 5.5 cells, because its extent is the
; round-1 REACHABILITY walk's and not an object's -- its own header says so.
; The icon starting at 0xF01992 therefore has its upper page inside
; Data_F0191A and its lower page here.  Data_F0191A is NOT re-cut by this
; pass: it is not part of any `.incbin` span and re-cutting it is a
; separate change with its own evidence.
;
; Re-derive all of it with
;     python3 notes/gen_prom_b_f0033f_f0199e.py --evidence --render
;
; ⚠⚠ CORRECTED 2026-09-02, lane IMAGE -- THE TWO READINGS ABOVE ARE TRANSPOSED,
;   AND THE 24-BYTE GRID IS WRONG.
;   1. "5 pages of 40 columns (a byte is one column, MSB the top row of its
;      page)": service 3 stores 5 COLUMNS of 40 bytes, one byte = 8 HORIZONTAL
;      pixels -- still 40 x 40, but byte c*40+r, not the transpose.  The same
;      formula applied to prom_a 0xFFCB00 renders the word `Technics`, which is
;      the calibration this reading has and the other does not.
;   2. "A 24-byte cell rendered as 12 columns * 2 pages is a 12x16 icon": the
;      TEN op-03 records that name 0xF019AA all carry BC=2, HL=12, so the cell
;      is 16 x 12.  Both readings draw a circle, because a circle is nearly
;      symmetric under transposition -- which is exactly why the eye cannot
;      settle it and the record must.
;   3. "SEVEN 24-byte cells" is refuted by those same records: 0xF0191A,
;      0xF01938, 0xF01956 and 0xF01974 are each BC=3 HL=10 = 30 BYTES, and only
;      0xF01992 and 0xF019AA are 24.  4*30 + 2*24 = 168 = 7*24, so the total is
;      the same and the BOUNDARIES are not.  Bitmap_F0199E below is therefore
;      byte-column 1 of the 16 x 12 cell at 0xF01992, not its "lower page".
;   All of them are committed as PNGs -- images/Curve_F019C2.png .. (six
;   response-curve thumbnails), images/Bitmap_F0191A.png .., images/
;   Bitmap_F019AA.png.  Evidence: notes/FINDINGS-image-files.md sections 1-2,
;   and `python3 scripts/build/wsa1_bitmaps.py census`.
; ============================================================================

; --------------------------------------------------------------------------
; Bitmap_F0199E -- 12 bytes: the LOWER page of the 12x16 icon at 0xF01992,
;                  whose upper page is the last 12 bytes of Data_F0191A.
; Evidence: the 24-byte grid above; 0xF01992 = 0xF0191A + 5 * 24.
; Rendered (12 columns, this page only -- rows 8-15 of the icon):
;     #..######..#
;     .#..####..#.
;     .#........#.
;     ..##....##..
;     ....####....
;     ............
;     ............
;     ............
; --------------------------------------------------------------------------
Bitmap_F0199E:
	.byte 0x80, 0x60, 0x10, 0x90, 0xC8, 0xC8, 0xC8, 0xC8, 0x90, 0x10, 0x60, 0x80	; F0199E  page 1 of the icon at 0xF01992

; --------------------------------------------------------------------------
; Bitmap_F019AA -- 24 bytes, one whole 12x16 icon (12 columns, 2 pages)
; Evidence: 0x00F019AA is named as a 32-bit word ten times in the display-
;           list region (0xF03ACF 0xF03AE7 0xF03AFF 0xF03B17 0xF03B81
;           0xF03B96 0xF03C1F 0xF03C37 0xF03C4F 0xF03C67), which is what
;           pins the grid.  The next object, 0xF019C2, bounds it.
; Rendered:
;     ............
;     ....####....
;     ..##....##..
;     .#........#.
;     .#........#.
;     #..........#
;     #..........#
;     #..........#
;     #..........#
;     .#........#.
;     .#........#.
;     ..##....##..
;     ....####....
;     ............
;     ............
;     ............
; --------------------------------------------------------------------------
Bitmap_F019AA:
	.byte 0x07, 0x18, 0x20, 0x20, 0x40, 0x40, 0x40, 0x40, 0x20, 0x20, 0x18, 0x07	; F019AA  page 0 (rows 0-7)
	.byte 0x80, 0x60, 0x10, 0x10, 0x08, 0x08, 0x08, 0x08, 0x10, 0x10, 0x60, 0x80	; F019B6  page 1 (rows 8-15)

; --------------------------------------------------------------------------
; Bitmap_F019C2 -- 200 bytes, 40 columns * 5 pages = 40x40
; Evidence: selector slots [3], [6] at 0xF5BEFB name it; the blitter at
;           0xF5BEF1 is handed BC=5 pages, HL=40 columns.
; Rendered:
;     #######################################.
;     #...........................#########.##
;     #....................#######..........##
;     #.................###.................##
;     #...............##....................##
;     #.............##......................##
;     #............#........................##
;     #..........##.........................##
;     #.........##..........................##
;     #........##...........................##
;     #.......##............................##
;     #......##.............................##
;     #......#..............................##
;     #.....#...............................##
;     #....#................................##
;     #....#................................##
;     #...#.................................##
;     #...#.................................##
;     #..#..................................##
;     #..#..................................##
;     #..#..................................##
;     #.#...................................##
;     #.#...................................##
;     #.#...................................##
;     #.#...................................##
;     #.#...................................##
;     #.#...................................##
;     #.#...................................##
;     ##....................................##
;     ##....................................##
;     ##....................................##
;     ##....................................##
;     ##....................................##
;     ##....................................##
;     ##....................................##
;     ##....................................##
;     ##....................................##
;     #.....................................##
;     ########################################
;     ..######################################
; --------------------------------------------------------------------------
Bitmap_F019C2:
	.byte 0xFF, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x81, 0x81, 0x82, 0x84, 0x84, 0x88, 0x88, 0x90, 0x90	; F019C2  page 0, columns 0-19
	.byte 0x90, 0xA0, 0xA0, 0xA0, 0xA0, 0xA0, 0xA0, 0xA0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0x80, 0xFF, 0x7F	; F019D6  page 0, columns 20-39
	.byte 0xFF, 0x00, 0x00, 0x00, 0x00, 0x03, 0x04, 0x18, 0x30, 0x60, 0xC0, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F019EA  page 1, columns 0-19
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF	; F019FE  page 1, columns 20-39
	.byte 0xFF, 0x00, 0x07, 0x38, 0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F01A12  page 2, columns 0-19
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF	; F01A26  page 2, columns 20-39
	.byte 0xFF, 0x0F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F01A3A  page 3, columns 0-19
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF	; F01A4E  page 3, columns 20-39
	.byte 0xFE, 0xFA, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03	; F01A62  page 4, columns 0-19
	.byte 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0xFF, 0xFF	; F01A76  page 4, columns 20-39

; --------------------------------------------------------------------------
; Bitmap_F01A8A -- 200 bytes, 40 columns * 5 pages = 40x40
; Evidence: selector slot [5] at 0xF5BEFB names it; the blitter at
;           0xF5BEF1 is handed BC=5 pages, HL=40 columns.
; Rendered:
;     #######################################.
;     #................................#######
;     #............................####.....##
;     #.........................###.........##
;     #.......................##............##
;     #.....................##..............##
;     #...................##................##
;     #.................##..................##
;     #................#....................##
;     #..............##.....................##
;     #.............#.......................##
;     #............#........................##
;     #...........#.........................##
;     #..........#..........................##
;     #.........#...........................##
;     #........#............................##
;     #.......#.............................##
;     #.......#.............................##
;     #......#..............................##
;     #.....#...............................##
;     #....#................................##
;     #....#................................##
;     #...#.................................##
;     #...#.................................##
;     #...#.................................##
;     #..#..................................##
;     #..#..................................##
;     #..#..................................##
;     #.#...................................##
;     #.#...................................##
;     #.#...................................##
;     ##....................................##
;     ##....................................##
;     ##....................................##
;     ##....................................##
;     ##....................................##
;     ##....................................##
;     ##....................................##
;     ########################################
;     ..######################################
; --------------------------------------------------------------------------
Bitmap_F01A8A:
	.byte 0xFF, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x81, 0x81	; F01A8A  page 0, columns 0-19
	.byte 0x82, 0x82, 0x84, 0x84, 0x88, 0x88, 0x90, 0x90, 0x90, 0xA0, 0xA0, 0xA0, 0xA0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xFF, 0x7F	; F01A9E  page 0, columns 20-39
	.byte 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x40, 0x80, 0x00, 0x00	; F01AB2  page 1, columns 0-19
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF	; F01AC6  page 1, columns 20-39
	.byte 0xFF, 0x00, 0x00, 0x00, 0x03, 0x0C, 0x10, 0x20, 0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F01ADA  page 2, columns 0-19
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF	; F01AEE  page 2, columns 20-39
	.byte 0xFF, 0x01, 0x0E, 0x70, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F01B02  page 3, columns 0-19
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF	; F01B16  page 3, columns 20-39
	.byte 0xFE, 0xFE, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03	; F01B2A  page 4, columns 0-19
	.byte 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0xFF, 0xFF	; F01B3E  page 4, columns 20-39

; --------------------------------------------------------------------------
; Bitmap_F01B52 -- 200 bytes, 40 columns * 5 pages = 40x40
; Evidence: selector slot [4] at 0xF5BEFB names it; the blitter at
;           0xF5BEF1 is handed BC=5 pages, HL=40 columns.
; Rendered:
;     #######################################.
;     #....................................###
;     #.................................###.##
;     #...............................##....##
;     #.............................##......##
;     #..........................###........##
;     #.........................##..........##
;     #........................##...........##
;     #......................###............##
;     #.....................##..............##
;     #....................##...............##
;     #...................##................##
;     #.................###.................##
;     #................##...................##
;     #...............##....................##
;     #..............##.....................##
;     #.............##......................##
;     #............##.......................##
;     #...........##........................##
;     #...........#.........................##
;     #..........##.........................##
;     #.........##..........................##
;     #........##...........................##
;     #.......##............................##
;     #.......#.............................##
;     #......##.............................##
;     #.....##..............................##
;     #....##...............................##
;     #....#................................##
;     #....#................................##
;     #...#.................................##
;     #...#.................................##
;     #..#..................................##
;     #..#..................................##
;     #.#...................................##
;     #.#...................................##
;     #.#...................................##
;     ##....................................##
;     ########################################
;     ..######################################
; --------------------------------------------------------------------------
Bitmap_F01B52:
	.byte 0xFF, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80	; F01B52  page 0, columns 0-19
	.byte 0x80, 0x80, 0x80, 0x80, 0x80, 0x81, 0x83, 0x86, 0x84, 0x84, 0x88, 0x88, 0x90, 0x90, 0xA0, 0xA0, 0xA0, 0xC0, 0xFF, 0x7F	; F01B66  page 0, columns 20-39
	.byte 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x03, 0x06, 0x0C, 0x08	; F01B7A  page 1, columns 0-19
	.byte 0x18, 0x30, 0x60, 0xC0, 0x80, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF	; F01B8E  page 1, columns 20-39
	.byte 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x03, 0x06, 0x0C, 0x38, 0x60, 0xC0, 0x80, 0x00, 0x00, 0x00, 0x00	; F01BA2  page 2, columns 0-19
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF	; F01BB6  page 2, columns 20-39
	.byte 0xFF, 0x00, 0x00, 0x00, 0x03, 0x1C, 0x30, 0x60, 0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F01BCA  page 3, columns 0-19
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF	; F01BDE  page 3, columns 20-39
	.byte 0xFE, 0x06, 0x3B, 0xC3, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03	; F01BF2  page 4, columns 0-19
	.byte 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0xFF, 0xFF	; F01C06  page 4, columns 20-39

; --------------------------------------------------------------------------
; Bitmap_F01C1A -- 200 bytes, 40 columns * 5 pages = 40x40
; Evidence: selector slot [2] at 0xF5BEFB names it; the blitter at
;           0xF5BEF1 is handed BC=5 pages, HL=40 columns.
; Rendered:
;     #######################################.
;     #....................................###
;     #...................................#.##
;     #...................................#.##
;     #...................................#.##
;     #..................................#..##
;     #..................................#..##
;     #.................................#...##
;     #.................................#...##
;     #................................#....##
;     #................................#....##
;     #...............................##....##
;     #..............................##.....##
;     #.............................##......##
;     #.............................#.......##
;     #............................##.......##
;     #...........................##........##
;     #..........................##.........##
;     #.........................##..........##
;     #.........................#...........##
;     #........................##...........##
;     #.......................##............##
;     #......................##.............##
;     #.....................##..............##
;     #....................##...............##
;     #...................##................##
;     #.................###.................##
;     #................##...................##
;     #...............##....................##
;     #..............##.....................##
;     #............###......................##
;     #...........##........................##
;     #..........##.........................##
;     #........###..........................##
;     #......##.............................##
;     #....##...............................##
;     #.###.................................##
;     ##....................................##
;     ########################################
;     ..######################################
; --------------------------------------------------------------------------
Bitmap_F01C1A:
	.byte 0xFF, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80	; F01C1A  page 0, columns 0-19
	.byte 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x81, 0x86, 0xB8, 0xC0, 0xFF, 0x7F	; F01C2E  page 0, columns 20-39
	.byte 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F01C42  page 1, columns 0-19
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x07, 0x0C, 0x18, 0x70, 0x80, 0x00, 0x00, 0x00, 0xFF, 0xFF	; F01C56  page 1, columns 20-39
	.byte 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F01C6A  page 2, columns 0-19
	.byte 0x00, 0x00, 0x01, 0x03, 0x06, 0x0C, 0x38, 0x60, 0xC0, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF	; F01C7E  page 2, columns 20-39
	.byte 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x03, 0x02, 0x06, 0x0C, 0x18, 0x30, 0x20	; F01C92  page 3, columns 0-19
	.byte 0x60, 0xC0, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF	; F01CA6  page 3, columns 20-39
	.byte 0xFE, 0x06, 0x0B, 0x0B, 0x0B, 0x13, 0x13, 0x23, 0x23, 0x43, 0x43, 0xC3, 0x83, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03	; F01CBA  page 4, columns 0-19
	.byte 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0xFF, 0xFF	; F01CCE  page 4, columns 20-39

; --------------------------------------------------------------------------
; Bitmap_F01CE2 -- 200 bytes, 40 columns * 5 pages = 40x40
; Evidence: selector slot [1] at 0xF5BEFB names it; the blitter at
;           0xF5BEF1 is handed BC=5 pages, HL=40 columns.
; Rendered:
;     #######################################.
;     #....................................###
;     #....................................###
;     #....................................###
;     #....................................###
;     #....................................###
;     #....................................###
;     #....................................###
;     #...................................#.##
;     #...................................#.##
;     #...................................#.##
;     #..................................#..##
;     #..................................#..##
;     #..................................#..##
;     #.................................#...##
;     #.................................#...##
;     #.................................#...##
;     #................................#....##
;     #................................#....##
;     #...............................#.....##
;     #..............................#......##
;     #.............................#.......##
;     #.............................#.......##
;     #............................#........##
;     #...........................#.........##
;     #..........................#..........##
;     #.........................#...........##
;     #........................#............##
;     #.......................#.............##
;     #.....................##..............##
;     #....................#................##
;     #..................##.................##
;     #................##...................##
;     #..............##.....................##
;     #............##.......................##
;     #.........###.........................##
;     #.....####............................##
;     ######................................##
;     ########################################
;     ..######################################
; --------------------------------------------------------------------------
Bitmap_F01CE2:
	.byte 0xFF, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80	; F01CE2  page 0, columns 0-19
	.byte 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0xFF, 0xFF, 0x7F	; F01CF6  page 0, columns 20-39
	.byte 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F01D0A  page 1, columns 0-19
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x1C, 0xE0, 0x00, 0xFF, 0xFF	; F01D1E  page 1, columns 20-39
	.byte 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F01D32  page 2, columns 0-19
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x06, 0x08, 0x10, 0x60, 0x80, 0x00, 0x00, 0x00, 0xFF, 0xFF	; F01D46  page 2, columns 20-39
	.byte 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01	; F01D5A  page 3, columns 0-19
	.byte 0x01, 0x02, 0x04, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF	; F01D6E  page 3, columns 20-39
	.byte 0xFE, 0x06, 0x07, 0x07, 0x07, 0x07, 0x0B, 0x0B, 0x0B, 0x0B, 0x13, 0x13, 0x13, 0x23, 0x23, 0x43, 0x43, 0x83, 0x83, 0x03	; F01D82  page 4, columns 0-19
	.byte 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0xFF, 0xFF	; F01D96  page 4, columns 20-39

; --------------------------------------------------------------------------
; Bitmap_F01DAA -- 200 bytes, 40 columns * 5 pages = 40x40
; Evidence: selector slot [0] at 0xF5BEFB names it; the blitter at
;           0xF5BEF1 is handed BC=5 pages, HL=40 columns.
; Rendered:
;     #######################################.
;     #.....................................##
;     #....................................###
;     #....................................###
;     #....................................###
;     #....................................###
;     #....................................###
;     #....................................###
;     #....................................###
;     #....................................###
;     #....................................###
;     #...................................#.##
;     #...................................#.##
;     #...................................#.##
;     #...................................#.##
;     #...................................#.##
;     #...................................#.##
;     #...................................#.##
;     #..................................#..##
;     #..................................#..##
;     #..................................#..##
;     #.................................#...##
;     #.................................#...##
;     #................................#....##
;     #................................#....##
;     #...............................#.....##
;     #..............................#......##
;     #.............................##......##
;     #............................##.......##
;     #...........................##........##
;     #..........................##.........##
;     #.........................##..........##
;     #........................#............##
;     #......................##.............##
;     #....................##...............##
;     #.................###.................##
;     #..........#######....................##
;     #.#########...........................##
;     ########################################
;     ..######################################
; --------------------------------------------------------------------------
Bitmap_F01DAA:
	.byte 0xFF, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80	; F01DAA  page 0, columns 0-19
	.byte 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0xBF, 0xFF, 0x7F	; F01DBE  page 0, columns 20-39
	.byte 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F01DD2  page 1, columns 0-19
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1F, 0xE0, 0xFF, 0xFF	; F01DE6  page 1, columns 20-39
	.byte 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F01DFA  page 2, columns 0-19
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x06, 0x38, 0xC0, 0x00, 0xFF, 0xFF	; F01E0E  page 2, columns 20-39
	.byte 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F01E22  page 3, columns 0-19
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x03, 0x06, 0x0C, 0x18, 0x30, 0x40, 0x80, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF	; F01E36  page 3, columns 20-39
	.byte 0xFE, 0x02, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x0B, 0x13, 0x13	; F01E4A  page 4, columns 0-19
	.byte 0x13, 0x23, 0x23, 0x43, 0x43, 0x83, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0xFF, 0xFF	; F01E5E  page 4, columns 20-39
; --- END gen_prom_b_f0033f_f0199e 0xF0199E-0xF01E72 ---


; === END COVER-R1 0xF0191A-0xF01E72 ===

; ------------------------------------------------------------------
; 0xF01E72-0xF02294 -- 111 display-list records, 1059 bytes -- interpreter A
;   entered at: 0xF01E72, 0xF01F96, 0xF02064, 0xF020AA, 0xF021E4
;   ends used:  0xF01F96, 0xF0203E, 0xF02064, 0xF020AA, 0xF021E4, 0xF02295
; ------------------------------------------------------------------
; DL_EffectSendOutputDspEffect -- the display list at 0xF01E72.  Its own text
;                                 records read: "EFFECT SEND"; "& OUTPUT";
;                                 "DSP EFFECT"; "KIT PARAMETER"; "FILTER";
;                                 "CONTROLLER"; "DRUM SOUND NAMING"; "NOTE" +3
;                                 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_EffectSendOutputDspEffect:
	dl_text8x10	x=176, y=71, text="EFFECT SEND"
	dl_text8x10	x=200, y=84, text="& OUTPUT"
	dl_text8x10	x=176, y=116, text="DSP EFFECT"
	dl_text8x8_packed	x=136, y=136, text="KIT PARAMETER"
	dl_text8x10	x=56, y=154, text="FILTER"
	dl_text8x10	x=176, y=155, text="CONTROLLER"
	dl_text8x8_packed	x=207, y=186, text="DRUM SOUND NAMING"
	dl_text8x14	x=312, y=186, text="\021"
	dl_text8x8_packed	x=37, y=200, text="NOTE"
	dl_text8x8_packed	x=112, y=200, text="DRUM SOUND SELECT"
	dl_text16x16_packed	x=100, y=214, text=":"
	dl_text8x16	x=48, y=232, text="\022"
	dl_text8x16	x=88, y=232, text="\022"
	dl_text8x16	x=136, y=232, text="\022"
	dl_text8x14	x=56, y=116, text="AMPLITUDE"
	dl_text8x14	x=56, y=75, text="MODELING"
	dl_box	x0=15, y0=58, x1=305, y1=177
	dl_hline	x0=169, y0=121, x1=173, y1=121
	dl_hline	x0=169, y0=159, x1=173, y1=159
	dl_vline	x0=169, y0=121, x1=169, y1=132
	dl_vline	x0=169, y0=147, x1=169, y1=159
	dl_value_glyph	glyph=33, x=24, y=148
	dl_value_glyph	glyph=112, x=272, y=70
	dl_value_glyph	glyph=10, x=272, y=110
	dl_value_glyph	glyph=36, x=272, y=148
	dl_value_glyph	glyph=90, x=24, y=67
	dl_value_glyph	glyph=99, x=24, y=110
	dl_fill_rect	x0=30, y0=209, x1=71, y1=232
	dl_fill_rect	x0=83, y0=209, x1=260, y1=232
; DL_M0delingSoundEditToneDriver -- the display list at 0xF01F96.  Its own
;                                   text records read: "M0DELING"; "SOUND
;                                   EDIT"; "TONE"; "DRIVER"; "CONNEC"; "TION";
;                                   "RESO"; "NATOR".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_M0delingSoundEditToneDriver:
	dl_text16x16_packed	x=130, y=5, text="M0DELING"
	dl_text8x8_packed	x=6, y=7, text="SOUND EDIT"
	dl_text8x10	x=272, y=36, text="TONE"
	dl_text16x16_packed	x=309, y=33, text="\021"
	dl_text16x16_packed	x=309, y=71, text="\021"
	dl_text8x8_packed	x=271, y=76, text="DRIVER"
	dl_text8x16	x=288, y=100, text="\022"
	dl_text16x16_packed	x=309, y=110, text="\021"
	dl_text8x8_packed	x=271, y=112, text="CONNEC"
	dl_text8x8_packed	x=283, y=121, text="TION"
	dl_text8x16	x=288, y=137, text="\022"
	dl_box	x0=4, y0=4, x1=68, y1=16
	dl_box	x0=268, y0=29, x1=310, y1=52
	dl_box	x0=268, y0=72, x1=310, y1=86
	dl_box	x0=268, y0=108, x1=310, y1=131
	dl_box	x0=291, y0=86, x1=292, y1=102
	dl_box	x0=291, y0=131, x1=292, y1=139
	dl_value_glyph	glyph=90, x=104, y=1
	dl_text8x8_packed	x=271, y=149, text="RESO"
	dl_text16x16_packed	x=309, y=150, text="\021"
	dl_text8x8_packed	x=277, y=158, text="NATOR"
	dl_box	x0=268, y0=145, x1=310, y1=168
ToneEditPage_A0_Paint_DL1:
; ; drawn (start operand) by ToneEditPage_A0_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x10	x=64, y=148, text=":"
	dl_text8x10	x=64, y=185, text=":"
	dl_box	x0=185, y0=137, x1=250, y1=168
	dl_box	x0=52, y0=142, x1=181, y1=163
	dl_box	x0=185, y0=174, x1=250, y1=205
	dl_box	x0=52, y0=179, x1=181, y1=200
	dl_box	x0=181, y0=152, x1=185, y1=153
	dl_box	x0=181, y0=189, x1=185, y1=190
; DL_ResonatorDriverOnOffGroup -- the display list at 0xF020AA.  Its own text
;                                 records read: "RESONATOR"; "DRIVER";
;                                 "ON/OFF"; "GROUP"; "DRIVER"; "RESONATOR";
;                                 "INTERACTION".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_ResonatorDriverOnOffGroup:
	dl_text8x8_packed	x=191, y=54, text="RESONATOR"
	dl_text8x8_packed	x=56, y=59, text="DRIVER"
	dl_text8x10	x=64, y=74, text=":"
	dl_text8x10	x=64, y=111, text=":"
	dl_text8x8_packed	x=2, y=209, text="ON/OFF"
	dl_text8x8_packed	x=46, y=209, text="GROUP"
	dl_text8x8_packed	x=82, y=209, text="DRIVER"
	dl_text8x8_packed	x=186, y=209, text="RESONATOR"
	dl_text8x8_packed	x=244, y=209, text="INTERACTION"
	dl_text8x14	x=16, y=216, text="\215"
	dl_text8x14	x=56, y=216, text="\215"
	dl_text8x14	x=96, y=216, text="\215"
	dl_text8x14	x=216, y=216, text="\215"
	dl_text8x14	x=264, y=217, text="\215"
	dl_text8x14	x=16, y=227, text="\216"
	dl_text8x14	x=56, y=227, text="\216"
	dl_text8x14	x=96, y=227, text="\216"
	dl_text8x14	x=216, y=227, text="\216"
	dl_text8x14	x=264, y=228, text="\216"
	dl_box	x0=185, y0=63, x1=250, y1=94
	dl_box	x0=52, y0=68, x1=181, y1=89
	dl_box	x0=185, y0=100, x1=250, y1=131
	dl_box	x0=52, y0=105, x1=181, y1=126
	dl_box_shadow1	x0=9, y0=218, x1=30, y1=238
	dl_box_shadow1	x0=49, y0=218, x1=70, y1=238
	dl_box_shadow1	x0=89, y0=218, x1=110, y1=238
	dl_box_shadow1	x0=209, y0=218, x1=230, y1=238
	dl_box_shadow1	x0=257, y0=218, x1=278, y1=238
	dl_box	x0=181, y0=78, x1=185, y1=79
	dl_box	x0=181, y0=115, x1=185, y1=116
	dl_hline	x0=9, y0=228, x1=30, y1=228
	dl_hline	x0=49, y0=228, x1=70, y1=228
	dl_hline	x0=89, y0=228, x1=110, y1=228
	dl_hline	x0=209, y0=228, x1=230, y1=228
	dl_hline	x0=257, y0=228, x1=278, y1=228
; DL_ToneDriverResonator -- the display list at 0xF021E4.  Its own text
;                           records read: "TONE"; "DRIVER"; "RESONATOR".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_ToneDriverResonator:
	dl_text8x8_packed	x=132, y=26, text="TONE"
	dl_text8x8_packed	x=84, y=41, text="DRIVER"
	dl_text8x8_packed	x=148, y=41, text="RESONATOR"
	dl_box	x0=81, y0=37, x1=123, y1=51
	dl_box	x0=145, y0=37, x1=206, y1=51
	dl_box	x0=132, y0=42, x1=135, y1=45
	dl_hline	x0=81, y0=29, x1=130, y1=29
	dl_hline	x0=158, y0=29, x1=206, y1=29
	dl_box	x0=123, y0=43, x1=132, y1=44
	dl_box	x0=135, y0=43, x1=145, y1=44
	dl_box	x0=206, y0=43, x1=232, y1=44
	dl_hline	x0=229, y0=44, x1=232, y1=44
	dl_vline	x0=81, y0=29, x1=81, y1=32
	dl_vline	x0=206, y0=29, x1=206, y1=32
	dl_vline	x0=229, y0=40, x1=229, y1=47
	dl_vline	x0=230, y0=41, x1=230, y1=46
	dl_vline	x0=231, y0=42, x1=231, y1=45


; ------------------------------------------------------------------
; 0xF02295-0xF022F6 -- 11 display-list records, 98 bytes -- interpreter A
; Formerly Data_F02295 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round2_module.py
; ------------------------------------------------------------------
DL_F02295:
	dl_text8x8_packed	x=250, y=76, text="\020"
	dl_text8x8_packed	x=250, y=112, text="\020"
	dl_text8x8_packed	x=250, y=149, text="\020"
	dl_text8x8_packed	x=250, y=185, text="\020"
	dl_hline	x0=255, y0=79, x1=261, y1=79
	dl_hline	x0=255, y0=115, x1=261, y1=115
	dl_hline	x0=255, y0=152, x1=261, y1=152
	dl_hline	x0=255, y0=188, x1=261, y1=188
	dl_vline	x0=261, y0=80, x1=261, y1=114
	dl_vline	x0=261, y0=116, x1=261, y1=151
	dl_vline	x0=261, y0=153, x1=261, y1=187

; ------------------------------------------------------------------
; 0xF022F7-0xF02F35 -- 335 display-list records, 3135 bytes -- interpreter A
;   entered at: 0xF022F7, 0xF02329, 0xF0245F, 0xF02469, 0xF02671, 0xF027AF, 0xF02942, 0xF02A46, 0xF02B47, 0xF02D08, 0xF02DFB, 0xF02EF9, 0xF02F22
;   ends used:  0xF02329, 0xF0245F, 0xF02469, 0xF02671, 0xF027AF, 0xF02942, 0xF02A46, 0xF02B47, 0xF02D08, 0xF02DFB, 0xF02F22, 0xF02F2C, 0xF02F36
; ------------------------------------------------------------------
Draw_ToneTemplateLevelKeyTune_DL2:
; ; drawn (start operand) by Draw_ToneTemplateLevelKeyTune -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x10	x=56, y=149, text=":"
	dl_text8x10	x=56, y=181, text=":"
	dl_box_shadow1	x0=11, y0=138, x1=264, y1=202
	dl_hline	x0=11, y0=170, x1=264, y1=170
	dl_vline	x0=44, y0=138, x1=44, y1=202
	dl_vline	x0=172, y0=138, x1=172, y1=202
; DL_ToneTemplateLevelKeyTune -- the display list at 0xF02329.  Its own text
;                                records read: "TONE TEMPLATE"; "LEVEL KEY
;                                TUNE"; "GROUP"; "TONE"; "LEVEL"; "KEY";
;                                "TUNE".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_ToneTemplateLevelKeyTune:
	dl_text8x8_packed	x=68, y=63, text="TONE TEMPLATE"
	dl_text8x8_packed	x=176, y=63, text="LEVEL KEY TUNE"
	dl_text8x10	x=56, y=85, text=":"
	dl_text8x10	x=56, y=117, text=":"
	dl_text8x8_packed	x=45, y=209, text="GROUP"
	dl_text8x8_packed	x=88, y=209, text="TONE"
	dl_text8x8_packed	x=164, y=209, text="LEVEL"
	dl_text8x8_packed	x=210, y=209, text="KEY"
	dl_text8x8_packed	x=247, y=209, text="TUNE"
	dl_text8x14	x=56, y=217, text="\215"
	dl_text8x14	x=96, y=217, text="\215"
	dl_text8x14	x=176, y=217, text="\215"
	dl_text8x14	x=216, y=217, text="\215"
	dl_text8x14	x=256, y=217, text="\215"
	dl_text8x14	x=56, y=227, text="\216"
	dl_text8x14	x=96, y=227, text="\216"
	dl_text8x14	x=176, y=227, text="\216"
	dl_text8x14	x=216, y=227, text="\216"
	dl_text8x14	x=256, y=227, text="\216"
	dl_box_shadow1	x0=11, y0=57, x1=264, y1=138
	dl_box_shadow1	x0=49, y0=218, x1=70, y1=238
	dl_box_shadow1	x0=89, y0=218, x1=110, y1=238
	dl_box_shadow1	x0=169, y0=218, x1=190, y1=238
	dl_box_shadow1	x0=209, y0=218, x1=230, y1=238
	dl_box_shadow1	x0=249, y0=218, x1=270, y1=238
	dl_hline	x0=11, y0=74, x1=264, y1=74
	dl_hline	x0=11, y0=106, x1=264, y1=106
	dl_hline	x0=49, y0=228, x1=70, y1=228
	dl_hline	x0=89, y0=228, x1=110, y1=228
	dl_hline	x0=169, y0=228, x1=190, y1=228
	dl_hline	x0=209, y0=228, x1=230, y1=228
	dl_hline	x0=249, y0=228, x1=270, y1=228
	dl_vline	x0=44, y0=57, x1=44, y1=138
	dl_vline	x0=172, y0=57, x1=172, y1=138
	dl_fill_rect	x0=270, y0=31, x1=308, y1=50
Draw_ToneTemplateLevelKeyTune_DL1:
; ; drawn (start operand) by Draw_ToneTemplateLevelKeyTune -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=11, y0=139, x1=265, y1=139
; DL_DriverDriverWaveformReso -- the display list at 0xF02469.  Its own text
;                                records read: "DRIVER"; "DRIVER WAVEFORM";
;                                "RESO"; "NATOR"; "DRIVER WAVEFORM";
;                                "VELOCITY"; "DRIVER"; "CURS0R" +3 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_DriverDriverWaveformReso:
	dl_box	x0=73, y0=58, x1=169, y1=72
	dl_erase_rect	x0=71, y0=54, x1=167, y1=68
	dl_box	x0=71, y0=54, x1=167, y1=68
	dl_erase_rect	x0=69, y0=50, x1=165, y1=64
	dl_box	x0=69, y0=50, x1=165, y1=64
	dl_erase_rect	x0=67, y0=46, x1=163, y1=60
	dl_box	x0=67, y0=46, x1=163, y1=60
	dl_text8x8_packed	x=96, y=34, text="DRIVER"
	dl_text8x8_packed	x=70, y=50, text="DRIVER WAVEFORM"
	dl_text8x8_packed	x=196, y=50, text="RESO"
	dl_text8x8_packed	x=202, y=59, text="NATOR"
	dl_text8x8_packed	x=78, y=103, text="DRIVER WAVEFORM"
	dl_text8x8_packed	x=195, y=103, text="VELOCITY"
	dl_text8x8_packed	x=82, y=200, text="DRIVER"
	dl_text8x10	x=272, y=205, text="CURS0R"
	dl_text8x8_packed	x=36, y=209, text="GROUP"
	dl_text8x8_packed	x=76, y=209, text="WAVEFORM"
	dl_text8x8_packed	x=196, y=209, text="VELOCITY"
	dl_text8x14	x=48, y=216, text="\215"
	dl_text8x14	x=96, y=217, text="\215"
	dl_text8x14	x=216, y=217, text="\215"
	dl_text8x14	x=296, y=217, text="\215"
	dl_text8x14	x=48, y=226, text="\216"
	dl_text8x14	x=96, y=227, text="\216"
	dl_text8x14	x=216, y=227, text="\216"
	dl_text8x14	x=296, y=227, text="\216"
	dl_box_shadow1	x0=193, y0=46, x1=235, y1=69
	dl_box	x0=184, y0=56, x1=187, y1=59
	dl_box_shadow1	x0=60, y0=97, x1=253, y1=183
	dl_box_shadow1	x0=41, y0=218, x1=62, y1=236
	dl_box_shadow1	x0=89, y0=218, x1=110, y1=238
	dl_box_shadow1	x0=209, y0=218, x1=230, y1=238
	dl_box_shadow1	x0=285, y0=218, x1=314, y1=238
	dl_hline	x0=57, y0=38, x1=93, y1=38
	dl_hline	x0=136, y0=38, x1=179, y1=38
	dl_box	x0=179, y0=57, x1=184, y1=58
	dl_box	x0=187, y0=57, x1=193, y1=58
	dl_box	x0=235, y0=57, x1=250, y1=58
	dl_hline	x0=247, y0=58, x1=250, y1=58
	dl_hline	x0=57, y0=81, x1=179, y1=81
	dl_hline	x0=60, y0=114, x1=253, y1=114
	dl_hline	x0=41, y0=227, x1=62, y1=227
	dl_hline	x0=89, y0=228, x1=110, y1=228
	dl_hline	x0=209, y0=228, x1=230, y1=228
	dl_hline	x0=285, y0=228, x1=314, y1=228
	dl_vline	x0=57, y0=38, x1=57, y1=81
	dl_vline	x0=179, y0=38, x1=179, y1=81
	dl_vline	x0=189, y0=97, x1=189, y1=183
	dl_vline	x0=247, y0=54, x1=247, y1=61
	dl_vline	x0=248, y0=55, x1=248, y1=60
	dl_vline	x0=249, y0=56, x1=249, y1=59
	dl_fill_rect	x0=270, y0=74, x1=308, y1=84
; DL_Page12P0siti0nParameterP0siti0n -- the display list at 0xF02671.  Its own
;                                       text records read: "PAGE1/2";
;                                       "P0SITI0N PARAMETER"; "P0SITI0N  :";
;                                       "DEPTH     :"; "FORMANT   :";
;                                       "INTERACTION"; "GAIN      :";
;                                       "POSITION DEPTH FORMANT" +2 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Page12P0siti0nParameterP0siti0n:
	dl_text8x10	x=256, y=5, text="PAGE1/2"
	dl_text8x10	x=72, y=101, text="P0SITI0N PARAMETER"
	dl_text8x10	x=88, y=116, text="P0SITI0N  :"
	dl_text8x10	x=192, y=116, text="."
	dl_text8x10	x=88, y=131, text="DEPTH     :"
	dl_text8x10	x=88, y=146, text="FORMANT   :"
	dl_text8x10	x=72, y=164, text="INTERACTION"
	dl_text8x10	x=88, y=179, text="GAIN      :"
	dl_text8x8_packed	x=28, y=209, text="POSITION DEPTH FORMANT"
	dl_text8x8_packed	x=191, y=201, text="INTERACTION"
	dl_text8x8_packed	x=209, y=209, text="GAIN"
	dl_text8x14	x=56, y=217, text="\215"
	dl_text8x14	x=96, y=217, text="\215"
	dl_text8x14	x=136, y=217, text="\215"
	dl_text8x14	x=216, y=217, text="\215"
	dl_text8x14	x=56, y=227, text="\216"
	dl_text8x14	x=96, y=227, text="\216"
	dl_text8x14	x=136, y=227, text="\216"
	dl_text8x14	x=216, y=227, text="\216"
	dl_box_shadow1	x0=65, y0=94, x1=223, y1=192
	dl_box_shadow1	x0=49, y0=218, x1=70, y1=238
	dl_box_shadow1	x0=89, y0=218, x1=110, y1=238
	dl_box_shadow1	x0=129, y0=218, x1=150, y1=238
	dl_box_shadow1	x0=209, y0=218, x1=230, y1=238
	dl_hline	x0=65, y0=159, x1=223, y1=159
	dl_hline	x0=49, y0=228, x1=70, y1=228
	dl_hline	x0=89, y0=228, x1=110, y1=228
	dl_hline	x0=129, y0=228, x1=150, y1=228
	dl_hline	x0=209, y0=228, x1=230, y1=228
	dl_fill_rect	x0=270, y0=110, x1=308, y1=129
; DL_ResoDriverNatorPositionMovement -- the display list at 0xF027AF.  Its own
;                                       text records read: "RESO"; "DRIVER";
;                                       "NATOR"; "POSITION"; "MOVEMENT";
;                                       "INTERACTION".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_ResoDriverNatorPositionMovement:
	dl_text8x8_packed	x=123, y=37, text="\177"
	dl_text8x8_packed	x=143, y=37, text="~"
	dl_text8x8_packed	x=133, y=41, text="\022"
	dl_text8x8_packed	x=198, y=43, text="RESO"
	dl_text8x8_packed	x=123, y=46, text="\215"
	dl_text8x8_packed	x=165, y=46, text="\215"
	dl_text8x8_packed	x=58, y=48, text="DRIVER"
	dl_text8x8_packed	x=204, y=52, text="NATOR"
	dl_text8x8_packed	x=123, y=55, text="POSITION"
	dl_text8x8_packed	x=123, y=79, text="MOVEMENT"
	dl_text8x8_packed	x=187, y=79, text="INTERACTION"
	dl_box	x0=119, y0=35, x1=174, y1=65
	dl_box	x0=195, y0=39, x1=237, y1=62
	dl_box	x0=55, y0=44, x1=97, y1=58
	dl_line	x0=136, y0=39, x1=136, y1=41
	dl_hline	x0=129, y0=40, x1=133, y1=40
	dl_hline	x0=139, y0=40, x1=143, y1=40
	dl_hline	x0=124, y0=47, x1=170, y1=47
	dl_box	x0=97, y0=50, x1=119, y1=51
	dl_box	x0=174, y0=50, x1=195, y1=51
	dl_box	x0=237, y0=50, x1=248, y1=51
	dl_hline	x0=124, y0=51, x1=128, y1=51
	dl_hline	x0=166, y0=51, x1=170, y1=51
	dl_box	x0=146, y0=70, x1=147, y1=76
	dl_box	x0=216, y0=67, x1=217, y1=76
	dl_hline	x0=249, y0=50, x1=252, y1=50
	dl_hline	x0=249, y0=51, x1=252, y1=51
	dl_hline	x0=215, y0=64, x1=218, y1=64
	dl_hline	x0=214, y0=65, x1=219, y1=65
	dl_hline	x0=213, y0=66, x1=220, y1=66
	dl_hline	x0=145, y0=67, x1=148, y1=67
	dl_hline	x0=144, y0=68, x1=149, y1=68
	dl_hline	x0=143, y0=69, x1=150, y1=69
	dl_vline	x0=146, y0=66, x1=146, y1=69
	dl_vline	x0=147, y0=66, x1=147, y1=69
	dl_vline	x0=216, y0=63, x1=216, y1=66
	dl_vline	x0=217, y0=63, x1=217, y1=66
	dl_vline	x0=249, y0=47, x1=249, y1=54
	dl_vline	x0=250, y0=48, x1=250, y1=53
	dl_vline	x0=251, y0=49, x1=251, y1=52
; DL_Page22P0siti0nM0vementWidth -- the display list at 0xF02942.  Its own
;                                   text records read: "PAGE2/2"; "P0SITI0N
;                                   M0VEMENT"; "WIDTH :"; "SPEED :"; "TOUCH
;                                   :"; "WIDTH  SPEED  S/H"; "TOUCH".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Page22P0siti0nM0vementWidth:
	dl_text8x10	x=256, y=5, text="PAGE2/2"
	dl_text8x10	x=80, y=99, text="P0SITI0N M0VEMENT"
	dl_text8x10	x=104, y=112, text="WIDTH :"
	dl_text8x10	x=104, y=125, text="SPEED :"
	dl_text8x10	x=104, y=139, text="S/H   :"
	dl_text8x10	x=104, y=157, text="TOUCH :"
	dl_text8x8_packed	x=44, y=209, text="WIDTH  SPEED  S/H"
	dl_text8x8_packed	x=206, y=209, text="TOUCH"
	dl_text8x14	x=56, y=217, text="\215"
	dl_text8x14	x=96, y=217, text="\215"
	dl_text8x14	x=136, y=217, text="\215"
	dl_text8x14	x=216, y=217, text="\215"
	dl_text8x14	x=56, y=227, text="\216"
	dl_text8x14	x=96, y=227, text="\216"
	dl_text8x14	x=136, y=227, text="\216"
	dl_text8x14	x=216, y=227, text="\216"
	dl_box_shadow1	x0=73, y0=94, x1=221, y1=174
	dl_box_shadow1	x0=49, y0=218, x1=70, y1=238
	dl_box_shadow1	x0=89, y0=218, x1=110, y1=238
	dl_box_shadow1	x0=129, y0=218, x1=150, y1=238
	dl_box_shadow1	x0=209, y0=218, x1=230, y1=238
	dl_hline	x0=73, y0=152, x1=221, y1=152
	dl_hline	x0=49, y0=228, x1=70, y1=228
	dl_hline	x0=89, y0=228, x1=110, y1=228
	dl_hline	x0=129, y0=228, x1=150, y1=228
	dl_hline	x0=209, y0=228, x1=230, y1=228
	dl_fill_rect	x0=270, y0=110, x1=308, y1=129
; DL_Page13FitMutKeyDeResoTing -- the display list at 0xF02A46.  Its own text
;                                 records read: "PAGE1/3"; "FIT"; "MUT";
;                                 "KEY"; "DE"; "RESO"; "TING"; "ING" +3 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Page13FitMutKeyDeResoTing:
	dl_text8x10	x=256, y=6, text="PAGE1/3"
	dl_text8x8_packed	x=49, y=125, text="FIT"
	dl_text8x8_packed	x=86, y=125, text="MUT"
	dl_text8x8_packed	x=129, y=125, text="KEY"
	dl_text8x8_packed	x=168, y=125, text="DE"
	dl_text8x8_packed	x=210, y=125, text="RESO"
	dl_text8x8_packed	x=55, y=135, text="TING"
	dl_text8x8_packed	x=92, y=135, text="ING"
	dl_text8x8_packed	x=129, y=135, text="SHIFT"
	dl_text8x8_packed	x=168, y=135, text="TUNE"
	dl_text8x8_packed	x=210, y=135, text="SCALE"
	dl_text8x16	x=96, y=208, text="\022"
	dl_text8x16	x=136, y=208, text="\022"
	dl_text8x16	x=176, y=208, text="\022"
	dl_text8x16	x=216, y=208, text="\022"
	dl_text8x14	x=96, y=217, text="\215"
	dl_text8x14	x=136, y=217, text="\215"
	dl_text8x14	x=176, y=217, text="\215"
	dl_text8x14	x=216, y=217, text="\215"
	dl_text8x14	x=96, y=227, text="\216"
	dl_text8x14	x=136, y=227, text="\216"
	dl_text8x14	x=176, y=227, text="\216"
	dl_text8x14	x=216, y=227, text="\216"
	dl_box_shadow1	x0=89, y0=218, x1=110, y1=238
	dl_box_shadow1	x0=129, y0=218, x1=150, y1=238
	dl_box_shadow1	x0=169, y0=218, x1=190, y1=238
	dl_box_shadow1	x0=39, y0=145, x1=309, y1=207
	dl_box_shadow1	x0=209, y0=218, x1=230, y1=238
	dl_hline	x0=89, y0=228, x1=110, y1=228
	dl_hline	x0=129, y0=228, x1=150, y1=228
	dl_hline	x0=169, y0=228, x1=190, y1=228
	dl_hline	x0=209, y0=228, x1=230, y1=228
; DL_MainDriverResonatorSubResonator -- the display list at 0xF02B47.  Its own
;                                       text records read: "MAIN"; "DRIVER";
;                                       "RESONATOR"; "SUB"; "RESONATOR";
;                                       "SUB"; "GAIN"; "MAIN&SUB" +4 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_MainDriverResonatorSubResonator:
	dl_text8x8_packed	x=130, y=48, text="MAIN"
	dl_text8x8_packed	x=58, y=53, text="DRIVER"
	dl_text8x8_packed	x=130, y=57, text="RESONATOR"
	dl_text8x8_packed	x=130, y=79, text="SUB"
	dl_text8x8_packed	x=130, y=88, text="RESONATOR"
	dl_text8x8_packed	x=209, y=92, text="SUB"
	dl_text8x8_packed	x=209, y=102, text="GAIN"
	dl_bitmap	bitmap=Bitmap_F05CE0, x=192, y=80, w=16, h=12
	dl_text8x8_packed	x=255, y=220, text="MAIN&SUB"
	dl_text8x16	x=264, y=231, text="\022"
	dl_text8x8_packed	x=263, y=152, text="MAIN"
	dl_text8x8_packed	x=251, y=164, text="RESONATOR"
	dl_text8x8_packed	x=267, y=183, text="SUB"
	dl_text8x8_packed	x=251, y=195, text="RESONATOR"
	dl_text16x16_packed	x=309, y=150, text="\021"
	dl_text16x16_packed	x=309, y=188, text="\021"
	dl_text8x16	x=56, y=208, text="\022"
	dl_text8x14	x=56, y=217, text="\215"
	dl_text8x14	x=56, y=227, text="\216"
	dl_box	x0=127, y0=44, x1=187, y1=67
	dl_box	x0=55, y0=49, x1=97, y1=63
	dl_box	x0=103, y0=54, x1=106, y1=57
	dl_box	x0=127, y0=75, x1=187, y1=98
	dl_box	x0=250, y0=215, x1=308, y1=231
	dl_box	x0=252, y0=217, x1=306, y1=229
	dl_box_shadow1	x0=49, y0=218, x1=70, y1=238
	dl_box	x0=39, y0=121, x1=246, y1=207
	dl_box	x0=97, y0=55, x1=103, y1=56
	dl_box	x0=106, y0=55, x1=127, y1=56
	dl_box	x0=187, y0=55, x1=236, y1=56
	dl_hline	x0=233, y0=56, x1=236, y1=56
	dl_hline	x0=217, y0=58, x1=220, y1=58
	dl_hline	x0=216, y0=59, x1=221, y1=59
	dl_hline	x0=215, y0=60, x1=222, y1=60
	dl_box	x0=113, y0=85, x1=127, y1=86
	dl_box	x0=187, y0=85, x1=191, y1=86
	dl_box	x0=205, y0=85, x1=219, y1=86
	dl_box	x0=111, y0=57, x1=112, y1=86
	dl_box	x0=218, y0=57, x1=219, y1=85
	dl_vline	x0=219, y0=57, x1=219, y1=60
	dl_vline	x0=233, y0=52, x1=233, y1=59
	dl_vline	x0=234, y0=53, x1=234, y1=58
	dl_vline	x0=235, y0=54, x1=235, y1=57
	dl_hline	x0=39, y0=176, x1=309, y1=176
	dl_hline	x0=49, y0=228, x1=70, y1=228
; DL_Page23TouchDepthSubFittingMutingSubGain -- the display list at 0xF02D08.
;                                               Its own text records read:
;                                               "PAGE2/3"; "TOUCH DEPTH";
;                                               "SUB"; "FITTING MUTING SUB-
;                                               GAIN"; "GAIN".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Page23TouchDepthSubFittingMutingSubGain:
	dl_text8x10	x=256, y=6, text="PAGE2/3"
	dl_text8x8_packed	x=82, y=125, text="TOUCH DEPTH"
	dl_text8x8_packed	x=208, y=125, text="SUB"
	dl_text8x8_packed	x=46, y=135, text="FITTING MUTING SUB-GAIN"
	dl_text8x8_packed	x=208, y=135, text="GAIN"
	dl_text8x16	x=104, y=208, text="\022"
	dl_text8x16	x=168, y=208, text="\022"
	dl_text8x16	x=216, y=208, text="\022"
	dl_text8x14	x=104, y=217, text="\215"
	dl_text8x14	x=168, y=217, text="\215"
	dl_text8x14	x=216, y=217, text="\215"
	dl_text8x14	x=104, y=227, text="\216"
	dl_text8x14	x=168, y=227, text="\216"
	dl_text8x14	x=216, y=227, text="\216"
	dl_text8x14	x=160, y=156, text="--"
	dl_text8x14	x=216, y=156, text="--"
	dl_box_shadow1	x0=97, y0=218, x1=118, y1=238
	dl_box_shadow1	x0=161, y0=218, x1=182, y1=238
	dl_box_shadow1	x0=209, y0=218, x1=230, y1=238
	dl_box_shadow1	x0=39, y0=145, x1=309, y1=207
	dl_hline	x0=64, y0=128, x1=80, y1=128
	dl_hline	x0=151, y0=128, x1=166, y1=128
	dl_hline	x0=97, y0=228, x1=118, y1=228
	dl_hline	x0=161, y0=228, x1=182, y1=228
	dl_hline	x0=209, y0=228, x1=230, y1=228
	dl_vline	x0=64, y0=128, x1=64, y1=133
	dl_vline	x0=166, y0=128, x1=166, y1=132
; DL_MutingKeyFollowSlopeRange -- the display list at 0xF02DFB.  Its own text
;                                 records read: "MUTING"; "KEY FOLLOW";
;                                 "SLOPE"; "RANGE".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_MutingKeyFollowSlopeRange:
	dl_text8x8_packed	x=100, y=125, text="MUTING"
	dl_text8x8_packed	x=141, y=125, text="KEY FOLLOW"
	dl_text8x8_packed	x=88, y=135, text="SLOPE"
	dl_text8x8_packed	x=165, y=135, text="RANGE"
	dl_text8x16	x=152, y=150, text="__"
	dl_text8x16	x=192, y=150, text="__"
	dl_text8x16	x=152, y=181, text="__"
	dl_text8x16	x=192, y=181, text="__"
	dl_text8x16	x=96, y=208, text="\022"
	dl_text8x16	x=136, y=208, text="\022"
	dl_text8x16	x=176, y=208, text="\022"
	dl_text8x16	x=216, y=208, text="\022"
	dl_text8x14	x=96, y=217, text="\215"
	dl_text8x14	x=136, y=217, text="\215"
	dl_text8x14	x=176, y=217, text="\215"
	dl_text8x14	x=216, y=217, text="\215"
	dl_text8x14	x=96, y=227, text="\216"
	dl_text8x14	x=136, y=227, text="\216"
	dl_text8x14	x=176, y=227, text="\216"
	dl_text8x14	x=216, y=227, text="\216"
	dl_vline	x0=140, y0=138, x1=140, y1=143
	dl_vline	x0=221, y0=138, x1=221, y1=142
	dl_hline	x0=140, y0=138, x1=163, y1=138
	dl_hline	x0=197, y0=138, x1=221, y1=138
	dl_box_shadow1	x0=89, y0=218, x1=110, y1=238
	dl_box_shadow1	x0=129, y0=218, x1=150, y1=238
	dl_box_shadow1	x0=169, y0=218, x1=190, y1=238
	dl_box_shadow1	x0=209, y0=218, x1=230, y1=238
	dl_hline	x0=89, y0=228, x1=110, y1=228
	dl_hline	x0=129, y0=228, x1=150, y1=228
	dl_hline	x0=169, y0=228, x1=190, y1=228
	dl_hline	x0=209, y0=228, x1=230, y1=228
; DL_Page33ResoMode -- the display list at 0xF02EF9.  Its own text records
;                      read: "PAGE3/3"; "RESO"; "MODE".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Page33ResoMode:
	dl_text8x10	x=256, y=6, text="PAGE3/3"
	dl_text8x8_packed	x=48, y=125, text="RESO"
	dl_text8x8_packed	x=48, y=135, text="MODE"
	dl_box_shadow1	x0=39, y0=145, x1=309, y1=207
UiPaint_Ordinals_DL1:
; ; drawn (start operand) by UiPaint_Ordinals -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x14	x=0, y=74, text="\020"
	dl_text8x14	x=0, y=111, text="\020"
	dl_text8x14	x=0, y=149, text="\020"
	dl_text8x14	x=0, y=186, text="\020"

; === COVER-R1 0xF02F36-0xF02FB2 ===
; 0xF02F36-0xF02FB1, coverage round 1: 76 of this span's 124 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 76 as DATA (only
; a `.long` or a 32-bit immediate names it) in 3 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice


; ------------------------------------------------------------------
; 0xF02F36-0xF02F51 -- 4 display-list records, 28 bytes -- interpreter A
; Formerly Data_F02F36 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round4_module.py
; ------------------------------------------------------------------
DL_F02F36:
	dl_text8x10	x=8, y=74, text="1st"
	dl_text8x10	x=8, y=111, text="2nd"
	dl_text8x10	x=8, y=149, text="3rd"
	dl_text8x10	x=8, y=186, text="4th"

; --------------------------------------------------------------------------
; 0xF02F52-0xF02F61 -- 24 bytes, EMITTED AS DATA (not promoted to code).
; SHRUNK 2026-09-02 from a declared 29 B: the trailing 5 declared bytes
; plus the 7 B .incbin that followed it were really the first record of
; the display list right after this object -- see
; notes/gen_prom_b_f02f52_fix_module.py.
; Reached from: 0x00F02F52 appears as a 32-bit word at 0xF02F66 0xF5BB73;
;               converted code at 0xF5BB72 loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 41% printable ASCII; a linear decode runs 14 instructions and ends
;           `jp 0xf019`, with 41% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the readers below fix what the object is (notes/promb-2026-09-25/
;   dl_pointer_tables.py).  The rest of this span is unreachable and stays
;   `.incbin`.  Why this is data and not code: THE PROVENANCE SPLIT in
;   notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLRecordPtrs_F02F52 -- 0xF02F52-0xF02F61, 4 32-bit pointers, each to the
;   first byte of a display-list record (op 06 len 5, op 20 len 7).  Read by:
;   `ld XIZ,this / ld XIY,(XIZ+BC) / add BC,4 / ld XIX,(XIZ+BC) / call
;   T_DisplayList_Run` at 0xF5BB72: entries k and k+1 bound list k.  Entry
;   count: the object's extent over 4; every word is a record start
;   (notes/promb-2026-09-25/dl_pointer_tables.py).
; --------------------------------------------------------------------------
DLRecordPtrs_F02F52:
	.long	UiPaint_Ordinals_DL1	; F02F52  [0]
	.long	DL_F02F36	; F02F56  [1]
	.long	DL_F02F36 + 0x7	; F02F5A  [2]
	.long	DL_F02F36 + 0xE	; F02F5E  [3]
	.byte	0x4B, 0x2F, 0xF0, 0x00, 0x52, 0x2F, 0xF0, 0x00	; F02F62

; ------------------------------------------------------------------
; 0xF02F6A-0xF02F99 -- 4 display-list records, 48 bytes -- interpreter A.
; The FIRST record (0xF02F6A-0xF02F76, 12 B) was recovered from
; DLRecordPtrs_F02F52's oversized declaration (see notes/gen_prom_b_f02f52_fix_module.py);
; the other 3 (0xF02F76-0xF02F99) are as follows.
; NOT reached by any known call shape (reachability.py: prom_b has 0
; bytes with start evidence) and not named by any converted record's
; own table field either -- found because a plain op/len walk, starting
; 7 bytes into this span, lands with ZERO DRIFT exactly on the span's
; declared end, and every record's length satisfies ITS OWN handler's
; implied-length rule (notes/prom_b_dl_length_audit.py), not merely
; `op < bound`.  Regenerate: python3 notes/gen_prom_b_untouched_pool_module.py
; --splice
; ------------------------------------------------------------------
	dl_bitmap	bitmap=Data_F0191A, x=8, y=74, w=24, h=10
	dl_bitmap	bitmap=Data_F0191A + 0x1E, x=8, y=111, w=24, h=10
	dl_bitmap	bitmap=Data_F0191A + 0x3C, x=8, y=149, w=24, h=10
	dl_bitmap	bitmap=Data_F0191A + 0x5A, x=8, y=186, w=24, h=10

; --------------------------------------------------------------------------
; 0xF02F9A-0xF02FB1 -- 24 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F02F9A appears as a 32-bit word at 0xF02FAE 0xF5BB51;
;               converted code at 0xF5BB50 loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 38% printable ASCII; a linear decode runs 12 instructions and ends
;           `ld (0x00),0x00`, with 58% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the readers below fix what the object is (notes/promb-2026-09-25/
;   dl_pointer_tables.py).  The rest of this span is unreachable and stays
;   `.incbin`.  Why this is data and not code: THE PROVENANCE SPLIT in
;   notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLRecordPtrs_F02F9A -- 0xF02F9A-0xF02FB1, 6 32-bit pointers, each to the
;   first byte of a display-list record (op 03 len 12).  Read by: `ld XIZ,this
;   / ld XIY,(XIZ+BC) / add BC,4 / ld XIX,(XIZ+BC) / call T_DisplayList_Run`
;   at 0xF5BB50: entries k and k+1 bound list k.  Entry count: the object's
;   extent over 4; every word is a record start
;   (notes/promb-2026-09-25/dl_pointer_tables.py).  The last entry, 0xF02F9A,
;   is only the END of the last list -- this table's own address.
; --------------------------------------------------------------------------
DLRecordPtrs_F02F9A:
	.long	DLRecordPtrs_F02F52 + 0x18	; F02F9A  [0]
	.long	DLRecordPtrs_F02F52 + 0x18	; F02F9E  [1]
	.long	DLRecordPtrs_F02F52 + 0x24	; F02FA2  [2]
	.long	DLRecordPtrs_F02F52 + 0x30	; F02FA6  [3]
	.long	DLRecordPtrs_F02F52 + 0x3C	; F02FAA  [4]
	.long	DLRecordPtrs_F02F9A	; F02FAE  [5]

; === END COVER-R1 0xF02F36-0xF02FB2 ===

; ------------------------------------------------------------------
; 0xF02FB2-0xF02FD8 -- 4 display-list records, 39 bytes -- interpreter A
;   entered at: 0xF02FB2
;   ends used:  0xF02FD9
; ------------------------------------------------------------------
; DL_Solo -- the display list at 0xF02FB2.  Its own text records read: "SOLO".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Solo:
	dl_text8x14	x=0, y=34, text="\020SOLO"
	dl_box	x0=5, y0=30, x1=43, y1=47
	dl_box	x0=7, y0=32, x1=41, y1=45
	dl_erase_rect	x0=6, y0=31, x1=6, y1=46

; ------------------------------------------------------------------
; 0xF02FD9-0xF02FE2 -- 1 display-list record, 10 bytes -- interpreter A
;   entered at: 0xF02FD9   ends used: 0xF02FE3
;
; This was listed above only as an END ("ends used: 0xF02FD9" for DL_Solo).
; It is also a START.
; Evidence: UiPaint_Solo loads `ld XIY,0x00F02FD9` at 0xF5BAD9 and
;   `ld XIX,0x00F02FE3` at 0xF5BADE, then calls DisplayList_Run through thunk
;   T_DisplayList_Run at 0xF5BAF4 -- exactly the (start, end) pair this block spans.  So
;   the entry point is READ OFF THE CODE, not inferred from the byte pattern,
;   and the record's own length byte (0x0A at 0xF02FDA) closes it on 0xF02FE3.
;   Both facts are asserted by `python3 notes/prom_b_f5b800_checks.py`.
;
; ★ It is the DRAW half of a draw/erase pair.  Its four operand words --
;   0x0008, 0x0021, 0x0028, 0x002C -- are BYTE-FOR-BYTE the same four words as
;   UiPaint_Solo_DL2's op-0x1B record ten bytes further on, and UiPaint_Solo runs
;   exactly one of the two: op 0x05 on layer 0 when (0x27A2) is non-zero, op
;   0x1B on layer 1 when it is zero.  Same rectangle, two different ops, two
;   different layers.
; ------------------------------------------------------------------
UiPaint_Solo_DL1:
; ; drawn (start operand) by UiPaint_Solo -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_fill_rect	x0=8, y0=33, x1=40, y1=44

; ------------------------------------------------------------------
; 0xF02FE3-0xF02FF6 -- 2 display-list records, 20 bytes -- interpreter A
;   entered at: 0xF02FE3, 0xF02FED
;   ends used:  0xF02FED, 0xF02FF7
; ------------------------------------------------------------------
UiPaint_Solo_DL2:
; ; drawn (start operand) by UiPaint_Solo -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=8, y0=33, x1=40, y1=44
UiPaint_Ordinals_DL2:
; ; drawn (start operand) by UiPaint_Ordinals -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=8, y0=73, x1=34, y1=197

; === COVER-R1 0xF02FF7-0xF0302A ===
; ⚠ AMENDED 2026-09-02 (lane res02f, notes/gen_res02f_spans.py).  The 44 B
; this band left `.incbin` are now typed data: four of them are the +0x07
; POINTER FIELD of the record round 1 typed as Data_F02FF7, and the other 40
; are the 5 x 8-byte operand array that pointer names.  Round 1 reached the
; record's first byte and stopped 4 bytes short of its end; the handler that
; consumes the pointer, 0xF31B57, fixes both the record's length and the
; array's entry size.  This band is now at ZERO `.incbin` bytes.
; 0xF02FF7-0xF03029, coverage round 1: 7 of this span's 51 bytes are reachable
; -- 0 as CODE (an entry point in the routine directory, or a branch prom_b's
; own converted instructions decode) in 0 runs, and 7 as DATA (only a `.long`
; or a 32-bit immediate names it) in 1 run.  Everything else here is NOT
; reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice


; ==== round-1 header, KEPT VERBATIM and SUPERSEDED below (lane res02f, 2026-09-02) ====
; | ; --------------------------------------------------------------------------
; | ; Data_F02FF7 -- 7 bytes, EMITTED AS DATA (not promoted to code).
; | ; Reached from: 0x00F02FF7 appears as a 32-bit word at 0xF5BB99 0xF5BBA2;
; | ;               converted code at 0xF5BB98 0xF5BBA1 loads it as a 32-bit
; | ;               immediate.  No routine-directory slot and no branch decoded in
; | ;               converted code names it.
; | ; Measured: 14% printable ASCII; a linear decode runs 3 instructions and ends
; | ;           `retd 0x0500`, with 0% of the bytes in spellings llvm-mc will not
; | ;           encode.
; | ; ⚠ The extent is the reachability walk's, not the object's; the rest of
; | ;   this span is unreachable and stays `.incbin`.  Why this is data and
; | ;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; | ; --------------------------------------------------------------------------
; | Data_F02FF7:
; | 	.byte	0x03, 0x0B, 0xA3, 0x27, 0x0F, 0x00, 0x05	; F02FF7  |...'...|
; ==== end of the superseded round-1 header ====

; ------------------------------------------------------------------
; UiPaint_Ordinals_DL3 -- ONE interpreter-B display-list record, 11 bytes, and the
; 40-byte operand array it names.  Together they tile 0xF02FF7-0xF03029 and
; end on 0xF0302A, the first byte of the interpreter-B display list below.
;
; ⚠ SUPERSEDES the round-1 header kept above, which gave this object 7
;   bytes and said "the extent is the reachability walk's, not the
;   object's".  The extent IS the object's.  Round 1 stopped at +0x07 --
;   the record's own pointer FIELD -- so four bytes of the record went
;   into the `.incbin` with the array behind it.  Its "a linear decode
;   runs 3 instructions and ends `retd 0x0500`" was a decode of a record
;   header; nothing calls or branches here.
;   (lane res02f, 2026-09-02, notes/gen_res02f_spans.py)
;
; HOW THIS RECORD IS RUN.  0xF5BB93-0xF5BBA9 in UiPaint_Ordinals is
;     ld XIY,0x00F02FED / ld XIX,0x00F02FF7 / call 0xF417F0  <- interpreter A
;     ld XIY,0x00F02FF7 / call 0xF4181C                      <- THIS record
; and T_DLB_Handler_Array8 is `jp 0xF31B57`, a jump straight into the op-0x03 handler,
; so the record is handed to its handler with no opcode dispatch at all.
; That also answers what UiPaint_Ordinals' own header records as open:
; "what thunk T_DLB_Handler_Array8 does with 0xF02FF7 after the last paint".
; ------------------------------------------------------------------
UiPaint_Ordinals_DL3:		; renamed from Data_F02FF7 -- nothing referenced that label
; ; drawn (start operand) by UiPaint_Ordinals -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_rect_entry	var=0x27a3, mask=0x0f, shift=0, svc=LCDSVC_FillRect, table=DLTable_F03002

; ------------------------------------------------------------------
; DLTable_F03002 -- 5 entries of 8 bytes (40 bytes).
; Referenced by the display-list record 0xF02FF7 directly above, whose +0x07
; pointer lands here and whose handler fixes the entry size: 0xF31B57 does
; `sla 0x03,HL` on the extracted bit-field before `add XIX,XHL`, so the
; entries are 8 bytes.  5 entries is the EXTENT (40 / 8); the record's
; (mask >> shift) + 1 = 16 is only an upper bound on the index.
; The four words of the selected entry go to (0x2530), (0x2532), (0x2534),
; (0x2536) = X0, Y0, X1, Y1 -- those four addresses are established in
; notes/FINDINGS-display-controller.md by the clamp constants 319 and 239 --
; and then `swi 7` runs with A = the record's +0x06 = 0x05.
; So X0 and X1 are the constant columns and Y0/Y1 are the stepping ones:
; five extents 26 wide and 13 tall, 37 rows apart, all in the SAME x range
; 8..34 that UiPaint_Ordinals_DL2 (op 0x1B = LCD_Svc_1B_EraseRect, named in prom_a --
; notes/FINDINGS-prom_b-graphics-veneers.md) clears over the whole y range
; 0x49..0xC5 immediately before this record runs.  ⚠ What service 0x05
; itself draws into that extent is NOT asserted here; the tree records it
; as "a rectangle is the obvious reading and is not asserted"
; (notes/FINDINGS-ui-display-list.md).  Entries [0] and [1] are identical,
; exactly as in the sibling 5 x 8 arrays DLTable_F031C9/F031F1/F03219,
; which three byte-identical op-0x03 records name from the list at
; 0xF030E6.
; ------------------------------------------------------------------
DLTable_F03002:
	.short 0x0008, 0x0049, 0x0022, 0x0056	; [0] X0=8 Y0=73 X1=34 Y1=86
	.short 0x0008, 0x0049, 0x0022, 0x0056	; [1] X0=8 Y0=73 X1=34 Y1=86
	.short 0x0008, 0x006E, 0x0022, 0x007B	; [2] X0=8 Y0=110 X1=34 Y1=123
	.short 0x0008, 0x0093, 0x0022, 0x00A0	; [3] X0=8 Y0=147 X1=34 Y1=160
	.short 0x0008, 0x00B8, 0x0022, 0x00C5	; [4] X0=8 Y0=184 X1=34 Y1=197

; === END COVER-R1 0xF02FF7-0xF0302A ===

; ------------------------------------------------------------------
; 0xF0302A-0xF03106 -- 15 display-list records, 221 bytes -- interpreter B
;   entered at: 0xF0302A, 0xF0306E, 0xF030E6
;   ends used:  0xF0304C, 0xF030AA, 0xF03107
; ------------------------------------------------------------------
; DL_OriginalStringCylinderCone -- the display list at 0xF0302A, named by
;                                  mechanism M2 of
;                                  notes/prom_b_dl_screens_round5.py.
;                                  DLTable_OriginalStringCylinder: "ORIGINAL", "STRING",
;                                  "CYLINDER", "CONE", "FLARE", "PLATE L"
; Evidence: this list has no text of its own.  Its interpreter-B records name
;           the table below by a 32-bit operand, and that table holds the
;           NAMES the drawn value indexes, so those names are what the list
;           puts on the screen -- one of them at a time.  Generated by
;           notes/prom_b_dl_screens_round5.py --apply.
DL_OriginalStringCylinderCone:
	dlb_string_xy	var=0x2808, mask=0x3f, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLTable_OriginalStringCylinder, width=8, x=193, y=84
	dlb_string_xy	var=0x2809, mask=0x3f, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLTable_OriginalStringCylinder, width=8, x=193, y=121
	dlb_string_xy	var=0x280a, mask=0x3f, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLTable_OriginalStringCylinder, width=8, x=193, y=158
	dlb_string_xy	var=0x280b, mask=0x3f, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLTable_OriginalStringCylinder, width=8, x=193, y=195
ToneEditPage_A0_Paint_DL2:
; ; drawn (start operand) by ToneEditPage_A0_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=ModelingPage_Fields+8, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x14, table=DLTable_ABCDEFGHIJKLMNOPQRSU, width=1, x=56, y=74
	dlb_string	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText8x14, table=DiskSave_PasswordEntry, width=13, x=72, y=74
	dlb_string	var=ModelingPage_Fields+9, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x14, table=DLTable_ABCDEFGHIJKLMNOPQRSU, width=1, x=56, y=111
	dlb_string	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText8x14, table=0x00002300, width=13, x=72, y=111
	dlb_string	var=ModelingPage_Fields+10, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x14, table=DLTable_ABCDEFGHIJKLMNOPQRSU, width=1, x=56, y=148
	dlb_string	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText8x14, table=0x00002310, width=13, x=72, y=148
	dlb_string	var=ModelingPage_Fields+11, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x14, table=DLTable_ABCDEFGHIJKLMNOPQRSU, width=1, x=56, y=185
	dlb_string	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText8x14, table=0x00002320, width=13, x=72, y=185
DL_F030E6:
	dlb_rect_entry	var=0x27a3, mask=0x0f, shift=0, svc=LCDSVC_FillRect, table=DLTable_F031C9
	dlb_rect_entry	var=0x27a3, mask=0x0f, shift=0, svc=LCDSVC_FillRect, table=DLTable_F031F1
	dlb_rect_entry	var=0x27a3, mask=0x0f, shift=0, svc=LCDSVC_FillRect, table=DLTable_F03219

; === COVER-R1 0xF03107-0xF03169 ===
; 0xF03107-0xF03168, coverage round 1: 13 of this span's 98 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 13 as DATA (only
; a `.long` or a 32-bit immediate names it) in 3 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice


; ------------------------------------------------------------------
; 0xF03107-0xF03132 -- 5 display-list records, 44 bytes -- interpreter A
; Formerly Data_F03107 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round4_module.py
; ------------------------------------------------------------------
ToneEditPage_A0_PaintGroupBrackets_DL2:
; drawn (start operand) by ToneEditPage_A0_PaintGroupBrackets -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x8_packed	x=250, y=76, text="\020"
	dl_text8x8_packed	x=250, y=112, text="\020"
	dl_hline	x0=255, y0=79, x1=261, y1=79
	dl_hline	x0=255, y0=115, x1=261, y1=115
	dl_vline	x0=261, y0=80, x1=261, y1=114


; ------------------------------------------------------------------
; 0xF03133-0xF0315E -- 5 display-list records, 44 bytes -- interpreter A
; Formerly Data_F03133 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round4_module.py
; ------------------------------------------------------------------
ToneEditPage_A0_PaintGroupBrackets_DL3:
; drawn (start operand) by ToneEditPage_A0_PaintGroupBrackets -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x8_packed	x=250, y=149, text="\020"
	dl_text8x8_packed	x=250, y=185, text="\020"
	dl_hline	x0=255, y0=152, x1=261, y1=152
	dl_hline	x0=255, y0=188, x1=261, y1=188
	dl_vline	x0=261, y0=153, x1=261, y1=187

; --------------------------------------------------------------------------
; Data_F0315F -- 7 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F0315F appears as a 32-bit word at 0xF5CC1E 0xF5CC2A;
;               converted code at 0xF5CC1D 0xF5CC29 loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 14% printable ASCII; a linear decode runs 4 instructions and ends
;           `halt`, with 0% of the bytes in spellings llvm-mc will not encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; ABSORBED 2026-09-02 -- see notes/gen_prom_b_tiny_records_batch.py: this object plus
; the .incbin that followed it is ONE interpreter-A record (verified against
; the ROM's own handler table, exactly one interpreter's implied-length rule fits).
Data_F0315F:
	.byte 0x02, 0x0A, 0x05, 0x01, 0x74, 0x00, 0x05, 0x01, 0x97, 0x00	; A op 02, 10 bytes -> handler HTBL_A[2]

; === END COVER-R1 0xF03107-0xF03169 ===

; ------------------------------------------------------------------
; 0xF03169-0xF03172 -- 1 display-list records, 10 bytes -- interpreter A
;   entered at: 0xF03169
;   ends used:  0xF03173
; ------------------------------------------------------------------
ToneEditPage_A0_PaintGroupBrackets_DL1:
; drawn (start operand) by ToneEditPage_A0_PaintGroupBrackets -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=245, y0=72, x1=265, y1=195

; === COVER-R1 0xF03173-0xF031BF ===
; 0xF03173-0xF031BE, coverage round 1: 76 of this span's 76 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 76 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF03173-0xF031BE -- 76 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F03173 appears as a 32-bit word at 0xF5CB35 0xF5CBD0
;               0xF5CBE4; converted code at 0xF5CB34 0xF5CBCF 0xF5CBE3 loads
;               it as a 32-bit immediate.  No routine-directory slot and no
;               branch decoded in converted code names it.
; Measured: 34% printable ASCII; a linear decode runs 36 instructions and ends
;           `ld WA,0x00f0`, with 28% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the readers below fix what the object is (notes/promb-2026-09-25/
;   dl_pointer_tables.py).  The rest of this span is unreachable and stays
;   `.incbin`.  Why this is data and not code: THE PROVENANCE SPLIT in
;   notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLRecordPtrs_F03173 -- 0xF03173-0xF031BE, 19 32-bit pointers, each to the
;   first byte of a display-list record (op 02 len 15, op 03 len 11, op 07 len
;   17).  Read by: `ld XIY,this / sla 2,WA / add XIY,XWA / ld XIZ,XIY / ld
;   XIY,(XIZ) / ld XIX,(XIZ+4)` then T_DisplayListB_Run at 0xF5CB34: XIY =
;   entry A, XIX = entry A+1; `ld XIY,this / call
;   RunDisplayListBFromPointerArray` at 0xF5CBCF: ONE interpreter-B record
;   from entry A.  Its address is also used as a list end: `ld XIY,0xF03169 /
;   ld XIX,this / call T_DisplayList_Run` at 0xF5CBE3: the END of the list
;   that starts at 0xF03169.  Entry count: the object's extent over 4; every
;   word is a record start (notes/promb-2026-09-25/dl_pointer_tables.py).  The
;   callers' index ranges reach past the table: the pairing site takes A =
;   8..19 (`cp A,0x14 / jr NC` at 0xF5CB2A, `cp A,8 / jr C` at 0xF5CB2F), so A
;   = 18 and 19 read entry 19 / 20; the one-record site takes A + 13 for A =
;   2..5 and 7 (`add A,0x0d` at 0xF5CB5E), so A = 7 reads entry 20.  Entries
;   19 and 20 would be the first bytes of ToneEditPage_A0_RepaintField_DL, which the same routine
;   runs as a list at 0xF5CB68 -- so either those values of A do not occur or
;   the reads are garbage; entries 0..7 are read by neither site.
; --------------------------------------------------------------------------
DLRecordPtrs_F03173:
	.long	DL_F030E6	; F03173  [0]
	.long	DL_F030E6	; F03177  [1]
	.long	DL_F030E6	; F0317B  [2]
	.long	DL_F030E6	; F0317F  [3]
	.long	DL_F030E6	; F03183  [4]
	.long	DL_F030E6	; F03187  [5]
	.long	ToneEditPage_A0_Paint_DL2	; F0318B  [6]
	.long	ToneEditPage_A0_Paint_DL2	; F0318F  [7]
	.long	ToneEditPage_A0_Paint_DL2	; F03193  [8]
	.long	ToneEditPage_A0_Paint_DL2 + 0x1E	; F03197  [9]
	.long	ToneEditPage_A0_Paint_DL2 + 0x3C	; F0319B  [10]
	.long	ToneEditPage_A0_Paint_DL2 + 0x5A	; F0319F  [11]
	.long	DL_F030E6	; F031A3  [12]
	.long	DL_F030E6	; F031A7  [13]
	.long	DL_F030E6	; F031AB  [14]
	.long	DL_OriginalStringCylinderCone	; F031AF  [15]
	.long	DL_OriginalStringCylinderCone + 0x11	; F031B3  [16]
	.long	DL_OriginalStringCylinderCone + 0x22	; F031B7  [17]
	.long	DL_OriginalStringCylinderCone + 0x33	; F031BB  [18]

; === END COVER-R1 0xF03173-0xF031BF ===

; ------------------------------------------------------------------
; 0xF031BF-0xF031C8 -- 1 display-list records, 10 bytes -- interpreter A
;   entered at: 0xF031BF
;   ends used:  0xF031C9
; ------------------------------------------------------------------
ToneEditPage_A0_RepaintField_DL:
; ; drawn (start operand) by ToneEditPage_A0_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=14, y0=62, x1=251, y1=206

; ==================================================================
; 0xF031C9-0xF03440 -- display-list OPERAND TABLES (632 bytes, 4 objects)
; ==================================================================
;
; Every object here is named by a display-list record that points at it, and
; its SIZE is proven by tiling: the objects start at the first byte of this
; gap, each extent is a whole number of entries, and the last object's
; handler-implied size ends exactly on the first byte of the next display
; list.  Reproduce with `python3 notes/prom_b_dl_operand_tables.py --exact`.
;
; ------------------------------------------------------------------
; DLTable_F031C9 -- 5 entries of 8 bytes
; Referenced by: display-list record 0xF030E6
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           5 entries is the EXTENT (40 bytes / 8), not the (mask >> shift) + 1
;           = 16 the record would allow.
; ------------------------------------------------------------------
DLTable_F031C9:
	.short 0x000F, 0x0048, 0x0029, 0x0055	; [0]
	.short 0x000F, 0x0048, 0x0029, 0x0055	; [1]
	.short 0x000F, 0x006D, 0x0029, 0x007A	; [2]
	.short 0x000F, 0x0092, 0x0029, 0x009F	; [3]
	.short 0x000F, 0x00B7, 0x0029, 0x00C4	; [4]
; ------------------------------------------------------------------
; DLTable_F031F1 -- 5 entries of 8 bytes
; Referenced by: display-list record 0xF030F1
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           5 entries is the EXTENT (40 bytes / 8), not the (mask >> shift) + 1
;           = 16 the record would allow.
; ------------------------------------------------------------------
DLTable_F031F1:
	.short 0x0036, 0x0046, 0x00B3, 0x0057	; [0]
	.short 0x0036, 0x0046, 0x00B3, 0x0057	; [1]
	.short 0x0036, 0x006B, 0x00B3, 0x007C	; [2]
	.short 0x0036, 0x0090, 0x00B3, 0x00A1	; [3]
	.short 0x0036, 0x00B5, 0x00B3, 0x00C6	; [4]
; ------------------------------------------------------------------
; DLTable_F03219 -- 5 entries of 8 bytes
; Referenced by: display-list record 0xF030FC
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           5 entries is the EXTENT (40 bytes / 8), not the (mask >> shift) + 1
;           = 16 the record would allow.
; ------------------------------------------------------------------
DLTable_F03219:
	.short 0x00BB, 0x0041, 0x00F8, 0x005C	; [0]
	.short 0x00BB, 0x0041, 0x00F8, 0x005C	; [1]
	.short 0x00BB, 0x0066, 0x00F8, 0x0081	; [2]
	.short 0x00BB, 0x008B, 0x00F8, 0x00A6	; [3]
	.short 0x00BB, 0x00B0, 0x00F8, 0x00CB	; [4]
; ------------------------------------------------------------------
; DLTable_OriginalStringCylinder -- 64 entries of 8 characters
; Referenced by: display-list records 0xF0302A, 0xF0303B, 0xF0304C, 0xF0305D
; Evidence: the record's +7 pointer lands here and its +0x0B word is 8, so the
;           entries are 8 bytes wide (handler 0xF31B21/0xF31B39 loads the
;           extracted bit-field into HL as the index).
;           64 entries is the EXTENT (512 bytes / 8), not the (mask >> shift) + 1
;           = 64 the record would allow.
; ------------------------------------------------------------------
; DLTable_OriginalStringCylinder -- renamed from DLTable_F03241: the object's
;                                   own entries are "ORIGINAL"; "STRING";
;                                   "CYLINDER"; "CONE"; "FLARE"; "PLATE L";
;                                   "PLATE H"; "MEMB L". +56 more
; Evidence: the text printed below this label IS the object's whole content;
;           the name is CamelCase of its first entries and claims only what
;           the object HOLDS -- not what indexes it, and not what the words
;           mean.  The KIND is the one the tree already established and is
;           kept; only the address is replaced.  Generated by
;           notes/prom_b_dl_screens_round5.py --tables --apply.
DLTable_OriginalStringCylinder:
	.ascii "ORIGINAL"	; [0]
	.ascii " STRING "	; [1]
	.ascii "CYLINDER"	; [2]
	.ascii "  CONE  "	; [3]
	.ascii " FLARE  "	; [4]
	.ascii "PLATE L "	; [5]
	.ascii "PLATE H "	; [6]
	.ascii " MEMB L "	; [7]
	.ascii " MEMB H "	; [8]
	.ascii "THROUGH "	; [9]
	.ascii " MELLOW "	; [10]
	.ascii "  MUTE  "	; [11]
	.ascii " BRIGHT "	; [12]
	.ascii "  MOVE  "	; [13]
	.ascii " RANDOM "	; [14]
	.ascii " OCTAVE "	; [15]
	.ascii "HARMONIC"	; [16]
	.ascii " METAL  "	; [17]
	.ascii " BOTTLE "	; [18]
	.ascii " MELLOW "	; [19]
	.ascii "  MUTE  "	; [20]
	.ascii " BRIGHT "	; [21]
	.ascii "  MOVE  "	; [22]
	.ascii " RANDOM "	; [23]
	.ascii " OCTAVE "	; [24]
	.ascii "  SOFT  "	; [25]
	.ascii " MELLOW "	; [26]
	.ascii "  MUTE  "	; [27]
	.ascii " BRIGHT "	; [28]
	.ascii "  MOVE  "	; [29]
	.ascii " RANDOM "	; [30]
	.ascii " OCTAVE "	; [31]
	.ascii " MELLOW "	; [32]
	.ascii "  MUTE  "	; [33]
	.ascii " BRIGHT "	; [34]
	.ascii "  MOVE  "	; [35]
	.ascii " RANDOM "	; [36]
	.ascii " OCTAVE "	; [37]
	.ascii " WOOD L "	; [38]
	.ascii " WOOD H "	; [39]
	.ascii "METAL L "	; [40]
	.ascii "METAL H "	; [41]
	.ascii " MUTE L "	; [42]
	.ascii " MUTE H "	; [43]
	.ascii "BRIGHT L"	; [44]
	.ascii "BRIGHT H"	; [45]
	.ascii " MOVE L "	; [46]
	.ascii " MOVE H "	; [47]
	.ascii "RANDOM L"	; [48]
	.ascii "RANDOM H"	; [49]
	.ascii "SMALL L "	; [50]
	.ascii "SMALL H "	; [51]
	.ascii "LARGE L "	; [52]
	.ascii "LARGE H "	; [53]
	.ascii " MUTE L "	; [54]
	.ascii " MUTE H "	; [55]
	.ascii " SLAP L "	; [56]
	.ascii " SLAP H "	; [57]
	.ascii " MOVE L "	; [58]
	.ascii " MOVE H "	; [59]
	.ascii "RANDOM L"	; [60]
	.ascii "RANDOM H"	; [61]
	.ascii "SPECIAL1"	; [62]
	.ascii "SPECIAL2"	; [63]

; ------------------------------------------------------------------
; 0xF03441-0xF03477 -- 5 display-list records, 55 bytes -- interpreter B
;   entered at: 0xF03441, 0xF03455
;   ends used:  0xF0346E, 0xF03478
; ------------------------------------------------------------------
; DL_P0siti0n -- the display list at 0xF03441, named by mechanism M3 of
;                notes/prom_b_dl_screens_round5.py.  "P0SITI0N  :" ends at
;                0x1236
; Evidence: this list has no text of its own.  Each of its interpreter-B
;           records prints at a screen position that is EXACTLY where a
;           caption of another list on the same screen stops writing (caption
;           `+2` word plus `length - 4` characters), so the value goes in that
;           caption's field.  The captions are quoted above with the position
;           they end on; the screen is the set of lists run by the SAME
;           routine, per notes/prom_b_dl_call_shapes.py.  Generated by
;           notes/prom_b_dl_screens_round5.py --apply.
DL_P0siti0n:
	dlb_number	var=ModelingPage_Fields+4, mask=0x3f, shift=0, svc=LCDSVC_DrawText8x10, x=176, y=116, digits=2
	dlb_number	var=ModelingPage_Fields+5, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x10, x=200, y=116, digits=1
ToneEditPage_A3_RepaintField_DL:
; ; drawn (start operand) by ToneEditPage_A3_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=ModelingPage_Fields+1, mask=0x80, shift=7, svc=LCDSVC_DrawText8x10, table=DLText_FixMove, width=4, x=176, y=146
	dlb_number	var=ModelingPage_Fields+1, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=176, y=131, digits=3
	dlb_number	var=ModelingPage_Fields+2, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=176, y=179, digits=3

; === COVER-R1 0xF03478-0xF03498 ===
; 0xF03478-0xF03497, coverage round 1: 32 of this span's 32 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 32 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF03478-0xF03497 -- 32 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F03478 appears as a 32-bit word at 0xF0345C 0xF5C0CB;
;               converted code at 0xF5C0CA loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 62% printable ASCII; a linear decode runs 11 instructions and ends
;           `ld IX,0x00f0`, with 16% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLText_FixMove -- 0xF03478-0xF0347F, 2 entries of 4 bytes, text drawn by
;   LCD_Svc_20_DrawText8x10.  Read by the interpreter-B op-0x02 record at
;   0xF03455 ((0x27A7) AND 0x80 >> 7) -- value = (byte at the +2 address)
;   AND mask >> shift -- whose +0x07 names this address;
;   DLB_Handler_StringTable draws entry [value] with +0x0B = 4 as the width.
;   Entry count: the 2 values the readers' masks admit (the bytes after that
;   are not indexed by them).  This address is also the END of a display
;   list: `ld XIY,0xF03441 / ld XIX,this / call T_DisplayListB_Run` at
;   0xF5C0CA.
; --------------------------------------------------------------------------
DLText_FixMove:
	.ascii	"FIX "	; F03478  [0]
	.ascii	"MOVE"	; F0347C  [1]
; --------------------------------------------------------------------------
; DLBRecordPtrs_F03480 -- 0xF03480-0xF03497, 6 32-bit pointers, each to the
;   first byte of an interpreter-B record.  Read by
;   RunDisplayListBFromPointerArray (0xF09AE1: `sla 2,WA / add XIY,XWA / ld
;   XIY,(XIY)`, then ONE record is run) with XIY = this address at 0xF5CD14.
;   Entry count: the distance to the object's end over 4 -- the reader
;   indexes by A and does not bound it.
; --------------------------------------------------------------------------
DLBRecordPtrs_F03480:
	.long	DL_P0siti0n	; F03480  [0]
	.long	ToneEditPage_A3_RepaintField_DL	; F03484  [1]
	.long	ToneEditPage_A3_RepaintField_DL + 0x19	; F03488  [2]
	.long	ToneEditPage_A3_RepaintField_DL + 0x19	; F0348C  [3]
	.long	DL_P0siti0n	; F03490  [4]
	.long	DL_P0siti0n + 0xA	; F03494  [5]

; === END COVER-R1 0xF03478-0xF03498 ===

; ------------------------------------------------------------------
; 0xF03498-0xF034C5 -- 4 display-list records, 46 bytes -- interpreter B
;   entered at: 0xF03498, 0xF034AD
;   ends used:  0xF034C6
; ------------------------------------------------------------------
ToneEditPage_A4_Paint_DL:
; ; drawn (start operand) by ToneEditPage_A4_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number_signed	var=ModelingPage_Fields, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=168, y=157, digits=2, signflag=0x00
	dlb_number	var=ModelingPage_Fields+1, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=176, y=112, digits=2
ToneEditPage_A4_RepaintField_DL:
; ; drawn (start operand) by ToneEditPage_A4_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number	var=ModelingPage_Fields+2, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=176, y=125, digits=2
	dlb_string	var=ModelingPage_Fields+2, mask=0x80, shift=7, svc=LCDSVC_DrawText8x10, table=DLText_OffOn, width=3, x=168, y=139

; === COVER-R1 0xF034C6-0xF034DE ===
; 0xF034C6-0xF034DD, coverage round 1: 24 of this span's 24 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 24 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF034C6-0xF034DD -- 24 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F034C6 appears as a 32-bit word at 0xF5C101 0xF5CD2D
;               0xF5CD3D; converted code at 0xF5C100 0xF5CD2C 0xF5CD3C loads
;               it as a 32-bit immediate.  No routine-directory slot and no
;               branch decoded in converted code names it.
; Measured: 62% printable ASCII; a linear decode runs 9 instructions and ends
;           `ld XIZ,0x204e4f46`, with 21% of the bytes in spellings llvm-mc
;           will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBRecordPtrs_F034C6 -- 0xF034C6-0xF034D1, 3 32-bit pointers, each to the
;   first byte of an interpreter-B record.  Read by
;   RunDisplayListBFromPointerArray (0xF09AE1: `sla 2,WA / add XIY,XWA / ld
;   XIY,(XIY)`, then ONE record is run) with XIY = this address at 0xF5CD3C.
;   Entry count: the distance to the first table over 4 -- the reader
;   indexes by A and does not bound it.  This address is also the END of a
;   display list: `ld XIY,0xF03498 / ld XIX,this / call T_DisplayListB_Run`
;   at 0xF5C100; `ld XIY,0xF034AD / ld XIX,this / call T_DisplayListB_Run`
;   at 0xF5CD2C.
; --------------------------------------------------------------------------
DLBRecordPtrs_F034C6:
	.long	ToneEditPage_A4_Paint_DL	; F034C6  [0]
	.long	ToneEditPage_A4_Paint_DL + 0xB	; F034CA  [1]
	.long	ToneEditPage_A4_RepaintField_DL	; F034CE  [2]
; --------------------------------------------------------------------------
; DLText_OffOn -- 0xF034D2-0xF034D7, 2 entries of 3 bytes, text drawn by
;   LCD_Svc_20_DrawText8x10.  Read by the interpreter-B op-0x02 records at
;   0xF034B7 ((0x27A8) AND 0x80 >> 7), 0xF053ED ((0x27A9) AND 0x80 >> 7),
;   0xF33858 ((0x27A6) AND 0x20 >> 5) -- value = (byte at the +2 address)
;   AND mask >> shift -- whose +0x07 names this address;
;   DLB_Handler_StringTable draws entry [value] with +0x0B = 3 as the width.
;   Entry count: the distance to the next table over the width; the masks
;   admit 2.
; --------------------------------------------------------------------------
DLText_OffOn:
	.ascii	"OFF"	; F034D2  [0]
	.ascii	" ON"	; F034D5  [1]
; --------------------------------------------------------------------------
; DLText_OffOn_F034D8 -- 0xF034D8-0xF034DD, 2 entries of 3 bytes, text drawn
;   by LCD_Svc_20_DrawText8x10.  Read by the interpreter-B op-0x02 records
;   at 0xF034F3 ((0x27A8) AND 0x80 >> 7), 0xF0352D ((0x27AC) AND 0x80 >> 7),
;   0xF06508 ((0x27A8) AND 0x0F >> 0), 0xF06535 ((0x27AB) AND 0x0F >> 0) and
;   1 more -- value = (byte at the +2 address) AND mask >> shift -- whose
;   +0x07 names this address; DLB_Handler_StringTable draws entry [value]
;   with +0x0B = 3 as the width.  Entry count: the distance to the object's
;   end over the width; the masks admit 16.
; --------------------------------------------------------------------------
DLText_OffOn_F034D8:
	.ascii	"OFF"	; F034D8  [0]
	.ascii	"ON "	; F034DB  [1]

; === END COVER-R1 0xF034C6-0xF034DE ===

; ------------------------------------------------------------------
; 0xF034DE-0xF0355C -- 11 display-list records, 127 bytes -- interpreter B
;   entered at: 0xF034DE, 0xF034E8, 0xF03522
;   ends used:  0xF03502, 0xF0353C, 0xF0355D
; ------------------------------------------------------------------
ToneEditPage_A5_Paint_DL:
; ; drawn (start operand) by ToneEditPage_A5_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number	var=ModelingPage_Fields+1, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=48, y=156, digits=3
ToneEditPage_A5_RepaintField_DL1:
; ; drawn (start operand) by ToneEditPage_A5_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number_signed	var=ModelingPage_Fields+10, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=88, y=156, digits=3, signflag=0x00
	dlb_string	var=ModelingPage_Fields+2, mask=0x80, shift=7, svc=LCDSVC_DrawText8x10, table=DLText_OffOn_F034D8, width=3, x=208, y=156
	dlb_number_signed	var=ModelingPage_Fields+3, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=128, y=156, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=160, y=156, digits=3, signflag=0x00
	dlb_number	var=ModelingPage_Fields+5, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=48, y=187, digits=3
ToneEditPage_A5_RepaintField_DL2:
; ; drawn (start operand) by ToneEditPage_A5_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number_signed	var=ModelingPage_Fields+11, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=88, y=187, digits=3, signflag=0x00
	dlb_string	var=ModelingPage_Fields+6, mask=0x80, shift=7, svc=LCDSVC_DrawText8x10, table=DLText_OffOn_F034D8, width=3, x=208, y=187
	dlb_number_signed	var=ModelingPage_Fields+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=128, y=187, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=160, y=187, digits=3, signflag=0x00
	dlb_rect_entry	var=ModelingPage_Fields, mask=0x01, shift=0, svc=LCDSVC_FillRect, table=DLTable_F035AA

; === COVER-R1 0xF0355D-0xF03581 ===
; 0xF0355D-0xF03580, coverage round 1: 36 of this span's 36 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 36 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF0355D-0xF03580 -- 36 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F0355D appears as a 32-bit word at 0xF5C137 0xF5CD9F;
;               converted code at 0xF5C136 0xF5CD9E loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 36% printable ASCII; a linear decode runs 15 instructions and ends
;           `ld XSP,0x0000f035`, with 36% of the bytes in spellings llvm-mc
;           will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the readers below fix what the object is (notes/promb-2026-09-25/
;   dl_pointer_tables.py).  The rest of this span is unreachable and stays
;   `.incbin`.  Why this is data and not code: THE PROVENANCE SPLIT in
;   notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLRecordPtrs_F0355D -- 0xF0355D-0xF03580, 9 32-bit pointers, each to the
;   first byte of a display-list record (op 00 len 10, op 03 len 11, op 05 len
;   11).  Read by: `ld XIY,this / call RunDisplayListBFromPointerArray` at
;   0xF5CD9E: ONE interpreter-B record from entry A.  Its address is also used
;   as a list end: `ld XIY,0xF034DE / ld XIX,this / call T_DisplayListB_Run`
;   at 0xF5C136: the END of the list that starts at 0xF034DE.  Entry count:
;   the object's extent over 4; every word is a record start
;   (notes/promb-2026-09-25/dl_pointer_tables.py).
; --------------------------------------------------------------------------
DLRecordPtrs_F0355D:
	.long	ToneEditPage_A5_RepaintField_DL2 + 0x30	; F0355D  [0]
	.long	ToneEditPage_A5_Paint_DL	; F03561  [1]
	.long	ToneEditPage_A5_RepaintField_DL1	; F03565  [2]
	.long	ToneEditPage_A5_RepaintField_DL1 + 0x1A	; F03569  [3]
	.long	ToneEditPage_A5_RepaintField_DL1 + 0x25	; F0356D  [4]
	.long	ToneEditPage_A5_RepaintField_DL1 + 0x30	; F03571  [5]
	.long	ToneEditPage_A5_RepaintField_DL2	; F03575  [6]
	.long	ToneEditPage_A5_RepaintField_DL2 + 0x1A	; F03579  [7]
	.long	ToneEditPage_A5_RepaintField_DL2 + 0x25	; F0357D  [8]

; === END COVER-R1 0xF0355D-0xF03581 ===

; ------------------------------------------------------------------
; 0xF03581-0xF035A9 -- 4 display-list records, 41 bytes -- interpreter A (3 records) and B (1)
;   entered at: 0xF03581, 0xF03595, 0xF0359F
;   ends used:  0xF03595, 0xF0359F, 0xF035AA
; ------------------------------------------------------------------
DL_F03581:
	dl_erase_rect	x0=41, y0=147, x1=307, y1=205
	dl_erase_rect	x0=253, y0=218, x1=305, y1=228
ToneEditPage_PaintMainAndSubFocus_DL1:
; drawn (start operand) by ToneEditPage_PaintMainAndSubFocus -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_fill_rect	x0=253, y0=218, x1=305, y1=228
ToneEditPage_PaintMainAndSubFocus_DL2:
; drawn (start operand) by ToneEditPage_PaintMainAndSubFocus -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_rect_entry	var=ModelingPage_Fields, mask=0x01, shift=0, svc=LCDSVC_FillRect, table=DLTable_F035BA

; ==================================================================
; 0xF035AA-0xF035C9 -- display-list OPERAND TABLES (32 bytes, 2 objects)
; ==================================================================
;
; Every object here is named by a display-list record that points at it, and
; its SIZE is proven by tiling: the objects start at the first byte of this
; gap, each extent is a whole number of entries, and the last object's
; handler-implied size ends exactly on the first byte of the next display
; list.  Reproduce with `python3 notes/prom_b_dl_operand_tables.py --exact`.
;
; ------------------------------------------------------------------
; DLTable_F035AA -- 2 entries of 8 bytes
; Referenced by: display-list records 0xF03552, 0xF0360C, 0xF036B7
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F035AA:
	.short 0x0029, 0x0093, 0x0133, 0x00AE	; [0]
	.short 0x0029, 0x00B2, 0x0133, 0x00CD	; [1]
; ------------------------------------------------------------------
; DLTable_F035BA -- 2 entries of 8 bytes
; Referenced by: display-list record 0xF0359F
; Evidence: the record's +7 pointer lands here and its handler scales the
;           extracted bit-field by 8 before adding it (0xF31B57 `sla 3,HL`,
;           0xF31B86 `mul HL,6`).
;           2 entries is the EXTENT (16 bytes / 8), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
DLTable_F035BA:
	.short 0x0029, 0x00B2, 0x0133, 0x00CD	; [0]
	.short 0x0029, 0x0093, 0x0133, 0x00AE	; [1]

; ------------------------------------------------------------------
; 0xF035CA-0xF03616 -- 7 display-list records, 77 bytes -- interpreter B
;   entered at: 0xF035CA
;   ends used:  0xF03617
; ------------------------------------------------------------------
ToneEditPage_A6_Paint_DL:
; ; drawn (start operand) by ToneEditPage_A6_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number_signed	var=ModelingPage_Fields+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=48, y=156, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=96, y=156, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+3, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=200, y=187, digits=3, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=48, y=187, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=96, y=187, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+6, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=152, y=187, digits=2, signflag=0x00
	dlb_rect_entry	var=ModelingPage_Fields, mask=0x01, shift=0, svc=LCDSVC_FillRect, table=DLTable_F035AA

; === COVER-R1 0xF03617-0xF03633 ===
; 0xF03617-0xF03632, coverage round 1: 9 of this span's 28 bytes are reachable
; -- 0 as CODE (an entry point in the routine directory, or a branch prom_b's
; own converted instructions decode) in 0 runs, and 9 as DATA (only a `.long`
; or a 32-bit immediate names it) in 1 run.  Everything else here is NOT
; reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F03617 -- 9 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F03617 appears as a 32-bit word at 0xF5C19F 0xF5CDCB;
;               converted code at 0xF5C19E 0xF5CDCA loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 22% printable ASCII; a linear decode runs 4 instructions and ends
;           `jp M/MI,0x00`, with 22% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F03617:
	.byte	0x0C, 0x36, 0xF0, 0x00, 0xCA, 0x35, 0xF0, 0x00, 0xD5	; F03617  |.6...5...|

; --- 0xF03620-0xF03632, 19 B, converted by lane promB6 (PTRTAB4).
;     7-entry pointer array
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x35, 0xF0, 0x00	; F03620  top 3 bytes of the entry at F0361F = 0x00F035D5
	.long	ToneEditPage_A6_Paint_DL + 0x16	; F03623  entry 3
	.long	ToneEditPage_A6_Paint_DL + 0x21	; F03627  entry 4
	.long	ToneEditPage_A6_Paint_DL + 0x2C	; F0362B  entry 5
	.long	ToneEditPage_A6_Paint_DL + 0x37	; F0362F  entry 6

; === END COVER-R1 0xF03617-0xF03633 ===

; ------------------------------------------------------------------
; 0xF03633-0xF036C1 -- 11 display-list records, 143 bytes -- interpreter B
;   entered at: 0xF03633, 0xF036A3
;   ends used:  0xF036C2
; ------------------------------------------------------------------
ToneEditPage_A7_Paint_DL1:
; ; drawn (start operand) by ToneEditPage_A7_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number_signed	var=ModelingPage_Fields+6, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=88, y=156, digits=2, signflag=0x00
	dlb_string	var=ModelingPage_Fields+4, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_NoteNamesCm2ToG8, width=3, x=128, y=156
	dlb_string	var=ModelingPage_Fields+3, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_NoteNamesCm2ToG8, width=3, x=168, y=156
	dlb_string	var=ModelingPage_Fields+5, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_NoteNamesCm2ToG8, width=3, x=208, y=156
	dlb_number_signed	var=ModelingPage_Fields+10, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=88, y=187, digits=2, signflag=0x00
	dlb_string	var=ModelingPage_Fields+8, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_NoteNamesCm2ToG8, width=3, x=128, y=187
	dlb_string	var=ModelingPage_Fields+7, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_NoteNamesCm2ToG8, width=3, x=168, y=187
	dlb_string	var=ModelingPage_Fields+9, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_NoteNamesCm2ToG8, width=3, x=208, y=187
ToneEditPage_A7_Paint_DL2:
; ; drawn (start operand) by ToneEditPage_A7_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number	var=ModelingPage_Fields+1, mask=0x80, shift=7, svc=LCDSVC_DrawText8x10, x=56, y=156, digits=1
	dlb_number	var=ModelingPage_Fields+2, mask=0x80, shift=7, svc=LCDSVC_DrawText8x10, x=56, y=187, digits=1
	dlb_rect_entry	var=ModelingPage_Fields, mask=0x01, shift=0, svc=LCDSVC_FillRect, table=DLTable_F035AA

; === COVER-R1 0xF036C2-0xF03892 ===
; 0xF036C2-0xF03891, coverage round 1: 127 of this span's 464 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 127 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF036C2-0xF036ED -- 44 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F036C2 appears as a 32-bit word at 0xF5C1D4 0xF5C1F7
;               0xF5CDF7; converted code at 0xF5C1D3 0xF5C1F6 0xF5CDF6 loads
;               it as a 32-bit immediate.  No routine-directory slot and no
;               branch decoded in converted code names it.
; Measured: 46% printable ASCII; a linear decode runs 62 instructions and ends
;           `swi 0`, with 24% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the readers below fix what the object is (notes/promb-2026-09-25/
;   dl_pointer_tables.py).  The rest of this span is unreachable and stays
;   `.incbin`.  Why this is data and not code: THE PROVENANCE SPLIT in
;   notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLRecordPtrs_F036C2 -- 0xF036C2-0xF036ED, 11 32-bit pointers, each to the
;   first byte of a display-list record (op 00 len 10, op 02 len 15, op 03 len
;   11, op 05 len 11).  Read by: `ld XIY,this / call
;   RunDisplayListBFromPointerArray` at 0xF5CDF6: ONE interpreter-B record
;   from entry A.  Its address is also used as a list end: `ld XIY,0xF03633 /
;   ld XIX,this / call T_DisplayListB_Run` at 0xF5C1D3: the END of the list
;   that starts at 0xF03633; `ld XIY,0xF036A3 / ld XIX,this / call
;   T_DisplayListB_Run` at 0xF5C1F6: the END of the list that starts at
;   0xF036A3.  Entry count: the object's extent over 4; every word is a record
;   start (notes/promb-2026-09-25/dl_pointer_tables.py).
; --------------------------------------------------------------------------
DLRecordPtrs_F036C2:
	.long	ToneEditPage_A7_Paint_DL2 + 0x14	; F036C2  [0]
	.long	ToneEditPage_A7_Paint_DL2	; F036C6  [1]
	.long	ToneEditPage_A7_Paint_DL2 + 0xA	; F036CA  [2]
	.long	ToneEditPage_A7_Paint_DL1 + 0x1A	; F036CE  [3]
	.long	ToneEditPage_A7_Paint_DL1 + 0xB	; F036D2  [4]
	.long	ToneEditPage_A7_Paint_DL1 + 0x29	; F036D6  [5]
	.long	ToneEditPage_A7_Paint_DL1	; F036DA  [6]
	.long	ToneEditPage_A7_Paint_DL1 + 0x52	; F036DE  [7]
	.long	ToneEditPage_A7_Paint_DL1 + 0x43	; F036E2  [8]
	.long	ToneEditPage_A7_Paint_DL1 + 0x61	; F036E6  [9]
	.long	ToneEditPage_A7_Paint_DL1 + 0x38	; F036EA  [10]


; ------------------------------------------------------------------
; 0xF036EE-0xF03891 -- 51 display-list records, 420 bytes -- interpreter A
; The 83 bytes here had been folded into DLRecordPtrs_F036C2 above (now
; shrunk to its real 44-byte, 11-entry pointer-table extent);
; walking from here lands with ZERO DRIFT on the ALREADY call-
; verified DL_T0neLayerSoundEditTrigGer ("entered at: 0xF03892"),
; a few lines below.  notes/gen_prom_b_f036c2_module.py
; ------------------------------------------------------------------
DL_F036EE:
	dl_text8x14	x=256, y=6, text="PAGE1/2"
	dl_text8x8_packed	x=84, y=60, text="TONE"
	dl_text8x8_packed	x=114, y=60, text="SELECT"
	dl_text8x8_packed	x=199, y=60, text="LEVEL"
	dl_text8x8_packed	x=241, y=60, text="KEY"
	dl_text8x8_packed	x=265, y=60, text="DETUNE"
	dl_text8x14	x=0, y=78, text="\020"
	dl_text8x14	x=72, y=82, text=":"
	dl_text8x14	x=72, y=114, text=":"
	dl_text8x14	x=0, y=115, text="\020"
	dl_text8x14	x=72, y=146, text=":"
	dl_text8x14	x=0, y=150, text="\020"
	dl_text8x14	x=72, y=178, text=":"
	dl_text8x14	x=0, y=187, text="\020"
	dl_text8x8_packed	x=2, y=209, text="ON/OFF"
	dl_text8x8_packed	x=85, y=209, text="GROUP"
	dl_text8x8_packed	x=128, y=209, text="TONE"
	dl_text8x8_packed	x=204, y=209, text="LEVEL"
	dl_text8x8_packed	x=250, y=209, text="KEY"
	dl_text8x8_packed	x=281, y=209, text="DETUNE"
	dl_text8x14	x=16, y=217, text="\215"
	dl_text8x14	x=96, y=217, text="\215"
	dl_text8x14	x=136, y=217, text="\215"
	dl_text8x14	x=216, y=217, text="\215"
	dl_text8x14	x=256, y=217, text="\215"
	dl_text8x14	x=296, y=217, text="\215"
	dl_text8x14	x=16, y=227, text="\216"
	dl_text8x14	x=96, y=227, text="\216"
	dl_text8x14	x=136, y=227, text="\216"
	dl_text8x14	x=216, y=227, text="\216"
	dl_text8x14	x=256, y=227, text="\216"
	dl_text8x14	x=296, y=227, text="\216"
	dl_box_shadow1	x0=11, y0=54, x1=309, y1=199
	dl_box_shadow1	x0=9, y0=218, x1=30, y1=238
	dl_box_shadow1	x0=89, y0=218, x1=110, y1=238
	dl_box_shadow1	x0=129, y0=218, x1=150, y1=238
	dl_box_shadow1	x0=209, y0=218, x1=230, y1=238
	dl_box_shadow1	x0=249, y0=218, x1=270, y1=238
	dl_box_shadow1	x0=289, y0=218, x1=310, y1=238
	dl_hline	x0=11, y0=71, x1=309, y1=71
	dl_hline	x0=11, y0=103, x1=309, y1=103
	dl_hline	x0=11, y0=135, x1=309, y1=135
	dl_hline	x0=11, y0=167, x1=309, y1=167
	dl_hline	x0=9, y0=228, x1=30, y1=228
	dl_hline	x0=89, y0=228, x1=110, y1=228
	dl_hline	x0=129, y0=228, x1=150, y1=228
	dl_hline	x0=209, y0=228, x1=230, y1=228
	dl_hline	x0=249, y0=228, x1=270, y1=228
	dl_hline	x0=289, y0=228, x1=310, y1=228
	dl_vline	x0=60, y0=54, x1=60, y1=199
	dl_vline	x0=188, y0=54, x1=188, y1=199

; === END COVER-R1 0xF036C2-0xF03892 ===

; ------------------------------------------------------------------
; 0xF03892-0xF039EC -- 41 display-list records, 347 bytes -- interpreter A
;   entered at: 0xF03892, 0xF039A9, 0xF039D9
;   ends used:  0xF03943, 0xF039A9, 0xF039D9, 0xF039E3, 0xF039ED
; ------------------------------------------------------------------
; DL_T0neLayerSoundEditTrigGer -- the display list at 0xF03892.  Its own text
;                                 records read: "T0NE LAYER"; "SOUND EDIT";
;                                 "TRIG"; "GER"; "KEY"; "LAYER"; "VEL";
;                                 "LAYER" +4 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_T0neLayerSoundEditTrigGer:
	dl_text16x16_packed	x=115, y=5, text="T0NE LAYER"
	dl_text8x8_packed	x=6, y=7, text="SOUND EDIT"
	dl_text8x10	x=264, y=30, text="TRIG"
	dl_text16x16_packed	x=308, y=33, text="\021"
	dl_text8x10	x=280, y=43, text="GER"
	dl_text8x10	x=264, y=70, text="KEY"
	dl_text16x16_packed	x=308, y=72, text="\021"
	dl_text8x10	x=264, y=83, text="LAYER"
	dl_text8x10	x=264, y=108, text="VEL"
	dl_text16x16_packed	x=308, y=110, text="\021"
	dl_text8x10	x=264, y=121, text="LAYER"
	dl_text16x16_packed	x=308, y=149, text="\021"
	dl_text8x10	x=264, y=147, text="PAN"
	dl_text8x10	x=272, y=160, text="NING"
	dl_box	x0=4, y0=4, x1=68, y1=16
	dl_box	x0=260, y0=26, x1=308, y1=56
	dl_box	x0=260, y0=66, x1=308, y1=96
	dl_box	x0=260, y0=104, x1=308, y1=134
	dl_box	x0=260, y0=143, x1=308, y1=173
	dl_value_glyph	glyph=100, x=88, y=1
	dl_text8x16	x=80, y=201, text="_"
	dl_text8x16	x=208, y=201, text="_"
	dl_text8x14	x=72, y=207, text="L"
	dl_text8x14	x=88, y=207, text="FADE LOW HIGH H"
	dl_text8x14	x=216, y=207, text="FADE"
	dl_text8x16	x=88, y=232, text="\022"
	dl_text8x16	x=136, y=232, text="\022"
	dl_text8x16	x=176, y=232, text="\022"
	dl_text8x16	x=216, y=232, text="\022"
	dl_box	x0=69, y0=204, x1=251, y1=233
	dl_hline	x0=69, y0=219, x1=251, y1=219
	dl_vline	x0=156, y0=204, x1=156, y1=233
	dl_fill_rect	x0=70, y0=220, x1=250, y1=232
; DL_T0neSelectSoundEdit -- the display list at 0xF039A9.  Its own text
;                           records read: "T0NE SELECT"; "SOUND EDIT".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_T0neSelectSoundEdit:
	dl_text16x16_packed	x=114, y=5, text="T0NE SELECT"
	dl_text8x8_packed	x=6, y=7, text="SOUND EDIT"
	dl_box	x0=4, y0=4, x1=68, y1=16
	dl_value_glyph	glyph=97, x=88, y=3
SoundEdit_PaintSlotOrdinals_DL:
; drawn (start operand) by SoundEdit_PaintSlotOrdinals -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x14	x=0, y=78, text="\020"
	dl_text8x14	x=0, y=115, text="\020"
	dl_text8x14	x=0, y=150, text="\020"
	dl_text8x14	x=0, y=187, text="\020"

; === COVER-R1 0xF039ED-0xF03C95 ===
; 0xF039ED-0xF03C94, coverage round 1: 359 of this span's 680 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 359 as DATA (only
; a `.long` or a 32-bit immediate names it) in 6 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice
;
; ⚠⚠ SUPERSEDED 2026-09-02 BY LANE res03a -- AND THE HEADLINE IS THE OPPOSITE
;    OF THE SENTENCE ABOVE.  "Everything else here is NOT reachable and stays
;    `.incbin`" is withdrawn: 0 of these 680 bytes are `.incbin` now, and none
;    of them is code.
;
; WHAT THIS REGION IS.  Eight instances of one object:
;
;        <list 1><list 2>...<list N><selector table of N+2 LE32 entries>
;
;    table[0] == table[1] == list 1's first byte    (entry 0 is padding)
;    table[i] == list i's first byte                (i = 1..N)
;    table[N+1] == the table's OWN address          (one past the last list)
;
;    A list is an ordinary interpreter-A display list: `(opcode, length)`
;    records run by DisplayList_Run (0xF31A09, thunk 0xF417F0).  The table is
;    what the firmware indexes, in a loop that is identical at every reader:
;
;        push C                    ; C = 4 or 2, counted DOWN by djnz
;        xor  B,B
;        sla  0x02,BC              ; BC = index*4
;        ld   XIZ,<table>
;        ld   XIY,(XIZ+BC)         ; start = table[i]
;        add  BC,0x0004
;        ld   XIX,(XIZ+BC)         ; end   = table[i+1]
;        call 0xf417f0             ; -> DisplayList_Run
;        pop  C
;        djnz C,<top>
;
;    `djnz` runs C down from 4 (or 2) to 1, so entries 1..N+1 are used and
;    entry 0 never is -- which is why entry 0 duplicates entry 1, and why the
;    C=2 blocks carry four entries where the C=4 blocks carry six.
;
; ⚠ WHY THIS MATTERS MORE THAN THE BYTE COUNT.  Four `.incbin` spans here
;   (0xF03A26+7, 0xF03ADE+21, 0xF03AF8+77, 0xF03BE6+5, 110 bytes) each began
;   and ended MID-RECORD, and so did five of the six `Data_*` extents around
;   them.  Any stride read off those bytes would have framed fake records and
;   rebuilt the ROM perfectly, because ANY framing of the right bytes does.
;   The boundaries below are not read off the bytes: they come from the
;   `ld XIZ` sites in already-converted code listed per block.
;
;   The four span markers this replaces, kept verbatim -- each said exactly
;   what was true, that the bytes decode as neither interpreter's records,
;   because each span STARTS in the middle of one:
;
; | ; --- 0xF03A26-0xF03A2C: not converted -- decodes as neither interpreter's records and is not a uniform fill ---
; | ; --- 0xF03ADE-0xF03AF2: not converted -- decodes as neither interpreter's records and is not a uniform fill ---
; | ; --- 0xF03AF8-0xF03B44: not converted -- decodes as neither interpreter's records and is not a uniform fill ---
; | ; --- 0xF03BE6-0xF03BEA: not converted -- decodes as neither interpreter's records and is not a uniform fill ---
;
;   0xF03A26 is bytes 6..12 of the op-03 record at 0xF03A21; 0xF03ADE bytes
;   6..12 of the record at 0xF03AD9 plus the whole record at 0xF03AE5 plus the
;   header of the one at 0xF03AF1; 0xF03AF8 the tail of that record, two more
;   lists and block 3's whole selector table; 0xF03BE6 bytes 8..12 of the
;   op-03 record at 0xF03BDF.
;
; ⚠ TWO OF THE EIGHT TABLES HAVE NO READER.  0xF03AB5 and 0xF03B2D are named
;   by nothing outside themselves anywhere in the four ROM images.  Their
;   framing rests on the chain -- each starts where the previous
;   reader-proven table ends, ends on its own self-referential last entry,
;   and 0xF03B2D's block ends exactly where the reader-proven table at
;   0xF03B6F says its own block begins.  Pinned at both ends, but say so.
;
; Regenerate / re-check:
;   python3 notes/gen_prom_b_f039ed_selector_blocks.py --check
;   python3 notes/gen_prom_b_f039ed_selector_blocks.py --evidence

; ------------------------------------------------------------------
; SELECTOR BLOCK 0 -- 0xF039ED-0xF03A20, 52 bytes: 4 display lists
; then a 6-entry selector table at 0xF03A09.
; Boundary evidence: the table is read by 0xF5C407 (`ld XIZ,0x00F03A09`, djnz from C=4).
; ------------------------------------------------------------------

; --------------------------------------------------------------------------
; Data_F039ED -- 57 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F039ED appears as a 32-bit word at 0xF03A09 0xF03A0D
;               0xF5C3C5; converted code at 0xF5C3C4 loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 46% printable ASCII; a linear decode runs 28 instructions and ends
;           `jp 0xf019`, with 30% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; ⚠ OVERTURNED 2026-09-02 (lane res03a).  "57 bytes" and "the rest of this
;   span is unreachable and stays `.incbin`" are both withdrawn.  The extent
;   was the walk's: it ran 4 text records + a 24-byte selector table + the
;   first 5 bytes of the record at 0xF03A21.  What survives unchanged is the
;   verdict DATA, and the "Reached from" line -- 0xF5C3C4 does load
;   0x00F039ED, as the END operand of a display-list call, and 0xF03A09 and
;   0xF03A0D are entries 0 and 1 of this block's own selector table.
; --------------------------------------------------------------------------
; list 1 of block 0 -- 0xF039ED-0xF039F3, 1 record, 7 bytes
Data_F039ED:
	dl_text8x10	x=16, y=79, text="1st"
; list 2 of block 0 -- 0xF039F4-0xF039FA, 1 record, 7 bytes
	dl_text8x10	x=16, y=111, text="2nd"
; list 3 of block 0 -- 0xF039FB-0xF03A01, 1 record, 7 bytes
	dl_text8x10	x=16, y=143, text="3rd"
; list 4 of block 0 -- 0xF03A02-0xF03A08, 1 record, 7 bytes
	dl_text8x10	x=16, y=175, text="4th"

; selector table of block 0 -- 0xF03A09-0xF03A20, 6 LE32 entries
	.long	Data_F039ED	; F03A09  [0] padding: never indexed (djnz runs C down to 1)
	.long	Data_F039ED	; F03A0D  [1] start of list 1
	.long	Data_F039ED + 0x7	; F03A11  [2] end of list 1 / start of list 2
	.long	Data_F039ED + 0xE	; F03A15  [3] end of list 2 / start of list 3
	.long	Data_F039ED + 0x15	; F03A19  [4] end of list 3 / start of list 4
	.long	Data_F039ED + 0x1C	; F03A1D  [5] end of list 4 == this table's own address

; ------------------------------------------------------------------
; SELECTOR BLOCK 1 -- 0xF03A21-0xF03A68, 72 bytes: 4 display lists
; then a 6-entry selector table at 0xF03A51.
; Boundary evidence: the table is read by 0xF5C3E5 (`ld XIZ,0x00F03A51`, djnz from C=4).
; ------------------------------------------------------------------
; list 1 of block 1 -- 0xF03A21-0xF03A2C, 1 record, 12 bytes
	dl_bitmap	bitmap=Data_F0191A, x=16, y=79, w=24, h=10

; ------------------------------------------------------------------
; 0xF03A2D-0xF03A50 -- 3 display-list records, 36 bytes -- interpreter A
; NOT reached by any known call shape (reachability.py: prom_b has 0
; bytes with start evidence) and not named by any converted record's
; own table field either -- found because a plain op/len walk, starting
; 7 bytes into this span, lands with ZERO DRIFT exactly on the span's
; declared end, and every record's length satisfies ITS OWN handler's
; implied-length rule (notes/prom_b_dl_length_audit.py), not merely
; `op < bound`.  Regenerate: python3 notes/gen_prom_b_untouched_pool_module.py
; --splice
; ⚠ 2026-09-02 (lane res03a): these records are UNCHANGED -- that lane's
;   framing was right.  What is withdrawn is the span it measured
;   itself against: the `.incbin` supplying the "7 bytes into this
;   span" offset is converted, and this run is simply a list of the
;   selector block above, named by that block's own table.
; ------------------------------------------------------------------
; list 2 of block 1 -- 0xF03A2D-0xF03A38, 1 record, 12 bytes
	dl_bitmap	bitmap=Data_F0191A + 0x1E, x=16, y=111, w=24, h=10
; list 3 of block 1 -- 0xF03A39-0xF03A44, 1 record, 12 bytes
	dl_bitmap	bitmap=Data_F0191A + 0x3C, x=16, y=143, w=24, h=10
; list 4 of block 1 -- 0xF03A45-0xF03A50, 1 record, 12 bytes
	dl_bitmap	bitmap=Data_F0191A + 0x5A, x=16, y=175, w=24, h=10

; --------------------------------------------------------------------------
; Data_F03A51 -- 141 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F03A51 appears as a 32-bit word at 0xF03A65 0xF5C3E6;
;               converted code at 0xF5C3E5 loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 26% printable ASCII; a linear decode runs 61 instructions and ends
;           `jp 0xf019`, with 59% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; ⚠ CORRECTED 2026-09-02 (lane res03a).  "141 bytes" is withdrawn -- the walk
;   ran from this table's first byte straight through two more blocks and
;   stopped mid-record at 0xF03ADD.  The label itself lands EXACTLY right:
;   0xF03A51 is block 1's 24-byte selector table, and 0xF5C3E5 is the
;   `ld XIZ` that indexes it.  0xF03A65 is its own entry 5, the
;   self-referential terminator.
; --------------------------------------------------------------------------
; selector table of block 1 -- 0xF03A51-0xF03A68, 6 LE32 entries
Data_F03A51:
	.long	Data_F039ED + 0x34	; F03A51  [0] padding: never indexed (djnz runs C down to 1)
	.long	Data_F039ED + 0x34	; F03A55  [1] start of list 1
	.long	Data_F039ED + 0x40	; F03A59  [2] end of list 1 / start of list 2
	.long	Data_F039ED + 0x4C	; F03A5D  [3] end of list 2 / start of list 3
	.long	Data_F039ED + 0x58	; F03A61  [4] end of list 3 / start of list 4
	.long	Data_F03A51	; F03A65  [5] end of list 4 == this table's own address

; ------------------------------------------------------------------
; SELECTOR BLOCK 2 -- 0xF03A69-0xF03ACC, 100 bytes: 4 display lists
; then a 6-entry selector table at 0xF03AB5.
; Boundary evidence: the table is named by NO INSTRUCTION anywhere in the four images; framed by the chain (see the region header).
; ------------------------------------------------------------------
; list 1 of block 2 -- 0xF03A69-0xF03A7B, 2 records, 19 bytes
	dl_bitmap	bitmap=Data_F0191A + 0x78, x=16, y=82, w=16, h=12
	dl_text8x10	x=32, y=82, text="1st"
; list 2 of block 2 -- 0xF03A7C-0xF03A8E, 2 records, 19 bytes
	dl_bitmap	bitmap=Data_F0191A + 0x78, x=16, y=114, w=16, h=12
	dl_text8x10	x=32, y=114, text="2nd"
; list 3 of block 2 -- 0xF03A8F-0xF03AA1, 2 records, 19 bytes
	dl_bitmap	bitmap=Data_F0191A + 0x78, x=16, y=146, w=16, h=12
	dl_text8x10	x=32, y=146, text="3rd"
; list 4 of block 2 -- 0xF03AA2-0xF03AB4, 2 records, 19 bytes
	dl_bitmap	bitmap=Data_F0191A + 0x78, x=16, y=178, w=16, h=12
	dl_text8x10	x=32, y=178, text="4th"

; selector table of block 2 -- 0xF03AB5-0xF03ACC, 6 LE32 entries
	.long	Data_F03A51 + 0x18	; F03AB5  [0] padding: never indexed (djnz runs C down to 1)
	.long	Data_F03A51 + 0x18	; F03AB9  [1] start of list 1
	.long	Data_F03A51 + 0x2B	; F03ABD  [2] end of list 1 / start of list 2
	.long	Data_F03A51 + 0x3E	; F03AC1  [3] end of list 2 / start of list 3
	.long	Data_F03A51 + 0x51	; F03AC5  [4] end of list 3 / start of list 4
	.long	Data_F03A51 + 0x64	; F03AC9  [5] end of list 4 == this table's own address

; ------------------------------------------------------------------
; SELECTOR BLOCK 3 -- 0xF03ACD-0xF03B44, 120 bytes: 4 display lists
; then a 6-entry selector table at 0xF03B2D.
; Boundary evidence: the table is named by NO INSTRUCTION anywhere in the four images; framed by the chain (see the region header).
; ------------------------------------------------------------------
; list 1 of block 3 -- 0xF03ACD-0xF03AE4, 2 records, 24 bytes
	dl_bitmap	bitmap=Bitmap_F019AA, x=16, y=82, w=16, h=12
	dl_bitmap	bitmap=Data_F0191A, x=32, y=82, w=24, h=10
; list 2 of block 3 -- 0xF03AE5-0xF03AFC, 2 records, 24 bytes
	dl_bitmap	bitmap=Bitmap_F019AA, x=16, y=114, w=16, h=12
; --------------------------------------------------------------------------
; ⚠ THE ONE LABEL THIS CONVERSION RETIRES, WITH ITS HEADER KEPT VERBATIM.
;   `Data_F03AF3` named bytes 3..7 of the 12-byte op-03 record that starts at
;   0xF03AF1, so it cannot stand on an object boundary and the label is gone.
;   Its own header already said as much -- "nothing aligned holds this
;   address; the walk fell through into it" -- and that sentence is the most
;   accurate thing anyone wrote about this region before now:
;
; | ; --------------------------------------------------------------------------
; | ; Data_F03AF3 -- 5 bytes, EMITTED AS DATA (not promoted to code).
; | ; Reached from: nothing aligned holds this address; the walk fell through into
; | ;               it.  No routine-directory slot and no branch decoded in
; | ;               converted code names it.
; | ; Measured: 20% printable ASCII; a linear decode runs 3 instructions and ends
; | ;           `jp PE/OV,0x00`, with 0% of the bytes in spellings llvm-mc will
; | ;           not encode.
; | ; ⚠ The extent is the reachability walk's, not the object's; the rest of
; | ;   this span is unreachable and stays `.incbin`.  Why this is data and
; | ;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; | ; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
	dl_bitmap	bitmap=Data_F0191A + 0x1E, x=32, y=114, w=24, h=10
; list 3 of block 3 -- 0xF03AFD-0xF03B14, 2 records, 24 bytes
	dl_bitmap	bitmap=Bitmap_F019AA, x=16, y=146, w=16, h=12
	dl_bitmap	bitmap=Data_F0191A + 0x3C, x=32, y=146, w=24, h=10
; list 4 of block 3 -- 0xF03B15-0xF03B2C, 2 records, 24 bytes
	dl_bitmap	bitmap=Bitmap_F019AA, x=16, y=178, w=16, h=12
	dl_bitmap	bitmap=Data_F0191A + 0x5A, x=32, y=178, w=24, h=10

; selector table of block 3 -- 0xF03B2D-0xF03B44, 6 LE32 entries
	.long	Data_F03A51 + 0x7C	; F03B2D  [0] padding: never indexed (djnz runs C down to 1)
	.long	Data_F03A51 + 0x7C	; F03B31  [1] start of list 1
	.long	Data_F03A51 + 0x94	; F03B35  [2] end of list 1 / start of list 2
	.long	Data_F03A51 + 0xAC	; F03B39  [3] end of list 2 / start of list 3
	.long	Data_F03A51 + 0xC4	; F03B3D  [4] end of list 3 / start of list 4
	.long	Data_F03A51 + 0xDC	; F03B41  [5] end of list 4 == this table's own address

; ------------------------------------------------------------------
; SELECTOR BLOCK 4 -- 0xF03B45-0xF03B7E, 58 bytes: 2 display lists
; then a 4-entry selector table at 0xF03B6F.
; Boundary evidence: the table is read by 0xF09DD0 0xF09E35 (`ld XIZ,0x00F03B6F`, djnz from C=2).
; ------------------------------------------------------------------

; ------------------------------------------------------------------
; 0xF03B45-0xF03B6E -- 4 display-list records, 42 bytes -- interpreter A
; NOT reached by any known call shape (reachability.py: prom_b has 0
; bytes with start evidence) and not named by any converted record's
; own table field either -- found because a plain op/len walk, starting
; 77 bytes into this span, lands with ZERO DRIFT exactly on the span's
; declared end, and every record's length satisfies ITS OWN handler's
; implied-length rule (notes/prom_b_dl_length_audit.py), not merely
; `op < bound`.  Regenerate: python3 notes/gen_prom_b_untouched_pool_module.py
; --splice
; ⚠ 2026-09-02 (lane res03a): these records are UNCHANGED -- that lane's
;   framing was right.  What is withdrawn is the span it measured
;   itself against: the `.incbin` supplying the "77 bytes into this
;   span" offset is converted, and this run is simply a list of the
;   selector block above, named by that block's own table.
; ------------------------------------------------------------------
; list 1 of block 4 -- 0xF03B45-0xF03B59, 2 records, 21 bytes
	dl_bitmap	bitmap=Data_F0191A + 0x78, x=16, y=119, w=16, h=12
	dl_text8x8_packed	x=33, y=122, text="1st"
; list 2 of block 4 -- 0xF03B5A-0xF03B6E, 2 records, 21 bytes
	dl_bitmap	bitmap=Data_F0191A + 0x78, x=16, y=149, w=16, h=12
	dl_text8x8_packed	x=33, y=152, text="2nd"

; --------------------------------------------------------------------------
; Data_F03B6F -- 119 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F03B6F appears as a 32-bit word at 0xF03B7B 0xF09DD1
;               0xF09E36; converted code at 0xF09DD0 0xF09E35 loads it as a
;               32-bit immediate.  No routine-directory slot and no branch
;               decoded in converted code names it.
; Measured: 28% printable ASCII; a linear decode runs 63 instructions and ends
;           `swi 0`, with 40% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; ⚠ CORRECTED 2026-09-02 (lane res03a).  "119 bytes" is withdrawn; the walk
;   ran through block 5 and stopped mid-record at 0xF03BE5.  The label is on
;   a real boundary: block 4's selector table, FOUR entries not six, because
;   both its readers (0xF09DD0, 0xF09E35) start their djnz loop at C=2.
; --------------------------------------------------------------------------
; selector table of block 4 -- 0xF03B6F-0xF03B7E, 4 LE32 entries
Data_F03B6F:
	.long	Data_F03A51 + 0xF4	; F03B6F  [0] padding: never indexed (djnz runs C down to 1)
	.long	Data_F03A51 + 0xF4	; F03B73  [1] start of list 1
	.long	Data_F03A51 + 0x109	; F03B77  [2] end of list 1 / start of list 2
	.long	Data_F03B6F	; F03B7B  [3] end of list 2 == this table's own address

; ------------------------------------------------------------------
; SELECTOR BLOCK 5 -- 0xF03B7F-0xF03BB8, 58 bytes: 2 display lists
; then a 4-entry selector table at 0xF03BA9.
; Boundary evidence: the table is read by 0xF09DAE (`ld XIZ,0x00F03BA9`, djnz from C=2).
; ------------------------------------------------------------------
; list 1 of block 5 -- 0xF03B7F-0xF03B93, 2 records, 21 bytes
	dl_bitmap	bitmap=Bitmap_F019AA, x=16, y=119, w=16, h=12
	dl_text8x8_packed	x=33, y=122, text="1st"
; list 2 of block 5 -- 0xF03B94-0xF03BA8, 2 records, 21 bytes
	dl_bitmap	bitmap=Bitmap_F019AA, x=16, y=149, w=16, h=12
	dl_text8x8_packed	x=33, y=152, text="2nd"

; selector table of block 5 -- 0xF03BA9-0xF03BB8, 4 LE32 entries
	.long	Data_F03B6F + 0x10	; F03BA9  [0] padding: never indexed (djnz runs C down to 1)
	.long	Data_F03B6F + 0x10	; F03BAD  [1] start of list 1
	.long	Data_F03B6F + 0x25	; F03BB1  [2] end of list 1 / start of list 2
	.long	Data_F03B6F + 0x3A	; F03BB5  [3] end of list 2 == this table's own address

; ------------------------------------------------------------------
; SELECTOR BLOCK 6 -- 0xF03BB9-0xF03C1C, 100 bytes: 4 display lists
; then a 6-entry selector table at 0xF03C05.
; Boundary evidence: the table is read by 0xF5C46E (`ld XIZ,0x00F03C05`, djnz from C=4).
; ------------------------------------------------------------------
; list 1 of block 6 -- 0xF03BB9-0xF03BCB, 2 records, 19 bytes
	dl_bitmap	bitmap=Data_F0191A + 0x78, x=0, y=73, w=16, h=12
	dl_text8x10	x=16, y=74, text="1st"
; list 2 of block 6 -- 0xF03BCC-0xF03BDE, 2 records, 19 bytes
	dl_bitmap	bitmap=Data_F0191A + 0x78, x=0, y=110, w=16, h=12
	dl_text8x10	x=16, y=111, text="2nd"
; list 3 of block 6 -- 0xF03BDF-0xF03BF1, 2 records, 19 bytes
	dl_bitmap	bitmap=Data_F0191A + 0x78, x=0, y=147, w=16, h=12

; ------------------------------------------------------------------
; 0xF03BEB-0xF03C04 -- 3 display-list records, 26 bytes -- interpreter A
; NOT reached by any known call shape (reachability.py: prom_b has 0
; bytes with start evidence) and not named by any converted record's
; own table field either -- found because a plain op/len walk, starting
; 5 bytes into this span, lands with ZERO DRIFT exactly on the span's
; declared end, and every record's length satisfies ITS OWN handler's
; implied-length rule (notes/prom_b_dl_length_audit.py), not merely
; `op < bound`.  Regenerate: python3 notes/gen_prom_b_untouched_pool_module.py
; --splice
; ⚠ 2026-09-02 (lane res03a): these records are UNCHANGED -- that lane's
;   framing was right.  What is withdrawn is the span it measured
;   itself against: the `.incbin` supplying the "5 bytes into this
;   span" offset is converted, and this run is simply a list of the
;   selector block above, named by that block's own table.
; ------------------------------------------------------------------
	dl_text8x10	x=16, y=148, text="3rd"
; list 4 of block 6 -- 0xF03BF2-0xF03C04, 2 records, 19 bytes
	dl_bitmap	bitmap=Data_F0191A + 0x78, x=0, y=184, w=16, h=12
	dl_text8x10	x=16, y=185, text="4th"

; --------------------------------------------------------------------------
; Data_F03C05 -- 13 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F03C05 appears as a 32-bit word at 0xF03C19 0xF5C46F;
;               converted code at 0xF5C46E loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 23% printable ASCII; a linear decode runs 6 instructions and ends
;           `jp NC,0x00`, with 62% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; ⚠ CORRECTED 2026-09-02 (lane res03a).  "13 bytes" is withdrawn: the object
;   is a 24-byte, 6-entry selector table, and the walk stopped 11 bytes into
;   it.  Lane promB6 had already spotted the tail from the far side and
;   emitted 0xF03C12-0xF03C1C as "6-entry pointer array"; its three loose
;   bytes were the top of entry 3.  Both halves are now one table.
; --------------------------------------------------------------------------
; selector table of block 6 -- 0xF03C05-0xF03C1C, 6 LE32 entries
Data_F03C05:
	.long	Data_F03B6F + 0x4A	; F03C05  [0] padding: never indexed (djnz runs C down to 1)
	.long	Data_F03B6F + 0x4A	; F03C09  [1] start of list 1
	.long	Data_F03B6F + 0x5D	; F03C0D  [2] end of list 1 / start of list 2
; | ; --- 0xF03C12-0xF03C1C: not converted -- decodes as neither interpreter's records and is not a uniform fill ---
; | ; --- 0xF03C12-0xF03C1C, 11 B, converted by lane promB6 (PTRTAB4).
; | ;     6-entry pointer array
; | ;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
; | 	.byte	0x3B, 0xF0, 0x00	; F03C12  top 3 bytes of the entry at F03C11 = 0x00F03BDF
; | 	.long	0x00F03BF2	; F03C15  entry 4
; | 	.long	0x00F03C05	; F03C19  entry 5
; ⚠ 2026-09-02 (lane res03a): that lane had the object RIGHT -- a 6-entry
;   pointer array -- and could only see its last 11 bytes because the
;   reachability walk had cut the first 13 into `Data_F03C05`.  Its three
;   loose leading bytes really were the top of entry 3.  The two halves are
;   one table again, above; the note is kept because it named the object
;   correctly from a fragment.
	.long	Data_F03B6F + 0x70	; F03C11  [3] end of list 2 / start of list 3
	.long	Data_F03B6F + 0x83	; F03C15  [4] end of list 3 / start of list 4
	.long	Data_F03C05	; F03C19  [5] end of list 4 == this table's own address

; ------------------------------------------------------------------
; SELECTOR BLOCK 7 -- 0xF03C1D-0xF03C94, 120 bytes: 4 display lists
; then a 6-entry selector table at 0xF03C7D.
; Boundary evidence: the table is read by 0xF5C44C (`ld XIZ,0x00F03C7D`, djnz from C=4).
; ------------------------------------------------------------------

; ------------------------------------------------------------------
; 0xF03C1D-0xF03C7C -- 8 display-list records, 96 bytes -- interpreter A
; NOT reached by any known call shape (reachability.py: prom_b has 0
; bytes with start evidence) and not named by any converted record's
; own table field either -- found because a plain op/len walk, starting
; 11 bytes into this span, lands with ZERO DRIFT exactly on the span's
; declared end, and every record's length satisfies ITS OWN handler's
; implied-length rule (notes/prom_b_dl_length_audit.py), not merely
; `op < bound`.  Regenerate: python3 notes/gen_prom_b_untouched_pool_module.py
; --splice
; ⚠ 2026-09-02 (lane res03a): these records are UNCHANGED -- that lane's
;   framing was right.  What is withdrawn is the span it measured
;   itself against: the `.incbin` supplying the "11 bytes into this
;   span" offset is converted, and this run is simply a list of the
;   selector block above, named by that block's own table.
; ------------------------------------------------------------------
; list 1 of block 7 -- 0xF03C1D-0xF03C34, 2 records, 24 bytes
	dl_bitmap	bitmap=Bitmap_F019AA, x=0, y=73, w=16, h=12
	dl_bitmap	bitmap=Data_F0191A, x=16, y=74, w=24, h=10
; list 2 of block 7 -- 0xF03C35-0xF03C4C, 2 records, 24 bytes
	dl_bitmap	bitmap=Bitmap_F019AA, x=0, y=110, w=16, h=12
	dl_bitmap	bitmap=Data_F0191A + 0x1E, x=16, y=111, w=24, h=10
; list 3 of block 7 -- 0xF03C4D-0xF03C64, 2 records, 24 bytes
	dl_bitmap	bitmap=Bitmap_F019AA, x=0, y=147, w=16, h=12
	dl_bitmap	bitmap=Data_F0191A + 0x3C, x=16, y=148, w=24, h=10
; list 4 of block 7 -- 0xF03C65-0xF03C7C, 2 records, 24 bytes
	dl_bitmap	bitmap=Bitmap_F019AA, x=0, y=184, w=16, h=12
	dl_bitmap	bitmap=Data_F0191A + 0x5A, x=16, y=185, w=24, h=10

; --------------------------------------------------------------------------
; Data_F03C7D -- 24 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F03C7D appears as a 32-bit word at 0xF03C91 0xF5C44D;
;               converted code at 0xF5C44C loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 42% printable ASCII; a linear decode runs 11 instructions and ends
;           `ld (0x00),0x00`, with 21% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; ⚠ CONFIRMED 2026-09-02 (lane res03a).  This one the walk got exactly right:
;   24 bytes IS the object -- block 7's 6-entry selector table, read by
;   0xF5C44C.  Only the "stays `.incbin`" sentence is withdrawn.
; --------------------------------------------------------------------------
; selector table of block 7 -- 0xF03C7D-0xF03C94, 6 LE32 entries
Data_F03C7D:
	.long	Data_F03C05 + 0x18	; F03C7D  [0] padding: never indexed (djnz runs C down to 1)
	.long	Data_F03C05 + 0x18	; F03C81  [1] start of list 1
	.long	Data_F03C05 + 0x30	; F03C85  [2] end of list 1 / start of list 2
	.long	Data_F03C05 + 0x48	; F03C89  [3] end of list 2 / start of list 3
	.long	Data_F03C05 + 0x60	; F03C8D  [4] end of list 3 / start of list 4
	.long	Data_F03C7D	; F03C91  [5] end of list 4 == this table's own address

; === END COVER-R1 0xF039ED-0xF03C95 ===

; ------------------------------------------------------------------
; 0xF03C95-0xF03D49 -- 18 display-list records, 181 bytes -- interpreter A
;   entered at: 0xF03C95
;   ends used:  0xF03D4A
; ------------------------------------------------------------------
; DL_PitchSoundEditEnvPitchLf0 -- the display list at 0xF03C95.  Its own text
;                                 records read: "PITCH"; "SOUND EDIT"; "ENV";
;                                 "PITCH"; "LF0".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_PitchSoundEditEnvPitchLf0:
	dl_text16x16_packed	x=140, y=5, text="PITCH"
	dl_text8x8_packed	x=6, y=7, text="SOUND EDIT"
	dl_text8x14	x=280, y=41, text="ENV \021"
	dl_text8x14	x=264, y=75, text="PITCH \021"
	dl_text8x14	x=280, y=109, text="LF0 \021"
	dl_box	x0=4, y0=4, x1=68, y1=16
	dl_box	x0=276, y0=37, x1=308, y1=54
	dl_box	x0=260, y0=65, x1=308, y1=94
	dl_box	x0=276, y0=105, x1=308, y1=122
	dl_hline	x0=288, y0=61, x1=295, y1=61
	dl_hline	x0=289, y0=62, x1=294, y1=62
	dl_hline	x0=290, y0=63, x1=293, y1=63
	dl_hline	x0=290, y0=96, x1=293, y1=96
	dl_hline	x0=289, y0=97, x1=294, y1=97
	dl_hline	x0=288, y0=98, x1=295, y1=98
	dl_box	x0=291, y0=54, x1=292, y1=65
	dl_box	x0=291, y0=94, x1=292, y1=105
	dl_value_glyph	glyph=7, x=112, y=1


; ------------------------------------------------------------------
; 0xF03D4A-0xF03D67 -- 3 display-list records, 30 bytes -- interpreter A
; Formerly Data_F03D4A -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round4_module.py
; ------------------------------------------------------------------
DL_F03D4A:
	dl_fill_rect	x0=278, y0=39, x1=306, y1=52
	dl_fill_rect	x0=270, y0=67, x1=306, y1=92
	dl_fill_rect	x0=278, y0=107, x1=306, y1=120

; ------------------------------------------------------------------
; 0xF03D68-0xF03F76 -- 58 display-list records, 527 bytes -- interpreter A
;   entered at: 0xF03D68, 0xF03F31
;   ends used:  0xF03F31, 0xF03F77
; ------------------------------------------------------------------
; DL_KeyDeToneKeyScalingShift -- the display list at 0xF03D68.  Its own text
;                                records read: "KEY"; "DE-"; "TONE"; "KEY
;                                SCALING"; "SHIFT"; "TUNE"; "SCALE"; "OCT-
;                                SHIFT" +5 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_KeyDeToneKeyScalingShift:
	dl_text8x8_packed	x=49, y=55, text="KEY"
	dl_text8x8_packed	x=91, y=55, text="DE-"
	dl_text8x8_packed	x=132, y=55, text="TONE"
	dl_text8x8_packed	x=182, y=137, text="KEY SCALING"
	dl_text8x8_packed	x=49, y=64, text="SHIFT"
	dl_text8x8_packed	x=91, y=64, text="TUNE"
	dl_text8x8_packed	x=132, y=64, text="SCALE"
	dl_text8x14	x=0, y=78, text="\020"
	dl_text8x8_packed	x=187, y=175, text="OCT-SHIFT"
	dl_text8x14	x=0, y=115, text="\020"
	dl_text8x14	x=288, y=149, text="\215"
	dl_text8x14	x=0, y=150, text="\020"
	dl_text8x14	x=312, y=150, text="\251"
	dl_text8x8_packed	x=275, y=172, text="CURSOR"
	dl_text8x14	x=0, y=187, text="\020"
	dl_text8x14	x=288, y=189, text="\216"
	dl_text8x14	x=312, y=189, text="\251"
	dl_text8x8_packed	x=51, y=209, text="KEY"
	dl_text8x8_packed	x=82, y=209, text="DETUNE"
	dl_text8x8_packed	x=125, y=209, text="SCALE"
	dl_text8x8_packed	x=205, y=209, text="VALUE"
	dl_text8x14	x=56, y=217, text="\215"
	dl_text8x14	x=96, y=217, text="\215"
	dl_text8x14	x=136, y=217, text="\215"
	dl_text8x14	x=216, y=217, text="\215"
	dl_text8x14	x=56, y=227, text="\216"
	dl_text8x14	x=96, y=227, text="\216"
	dl_text8x14	x=136, y=227, text="\216"
	dl_text8x14	x=216, y=227, text="\216"
	dl_box_shadow1	x0=11, y0=51, x1=168, y1=202
	dl_box_shadow1	x0=179, y0=131, x1=251, y1=162
	dl_box	x0=279, y0=148, x1=304, y1=163
	dl_box	x0=281, y0=150, x1=302, y1=161
	dl_box_shadow1	x0=179, y0=171, x1=251, y1=202
	dl_box	x0=279, y0=187, x1=304, y1=202
	dl_box	x0=281, y0=189, x1=302, y1=200
	dl_box_shadow1	x0=49, y0=218, x1=70, y1=238
	dl_box_shadow1	x0=89, y0=218, x1=110, y1=238
	dl_box_shadow1	x0=129, y0=218, x1=150, y1=238
	dl_box_shadow1	x0=209, y0=218, x1=230, y1=238
	dl_hline	x0=11, y0=74, x1=168, y1=74
	dl_hline	x0=11, y0=106, x1=168, y1=106
	dl_hline	x0=11, y0=138, x1=168, y1=138
	dl_hline	x0=179, y0=145, x1=251, y1=145
	dl_hline	x0=11, y0=170, x1=168, y1=170
	dl_hline	x0=179, y0=185, x1=251, y1=185
	dl_hline	x0=49, y0=228, x1=70, y1=228
	dl_hline	x0=89, y0=228, x1=110, y1=228
	dl_hline	x0=129, y0=228, x1=150, y1=228
	dl_hline	x0=209, y0=228, x1=230, y1=228
	dl_vline	x0=44, y0=51, x1=44, y1=202
	dl_fill_rect	x0=262, y0=67, x1=306, y1=92
; DL_StartPitchStopPitchTotal -- the display list at 0xF03F31.  Its own text
;                                records read: "START PITCH"; "STOP"; "PITCH";
;                                "TOTAL"; "DEPTH".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_StartPitchStopPitchTotal:
	dl_text8x8_packed	x=67, y=178, text="START PITCH"
	dl_text8x8_packed	x=146, y=178, text="STOP"
	dl_text8x8_packed	x=173, y=178, text="PITCH"
	dl_text8x8_packed	x=216, y=178, text="TOTAL"
	dl_text8x8_packed	x=252, y=178, text="DEPTH"
	dl_vline	x0=213, y0=174, x1=213, y1=203

; === COVER-R1 0xF03F77-0xF0402E ===
; 0xF03F77-0xF0402D, coverage round 1: 137 of this span's 183 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 137 as DATA (only
; a `.long` or a 32-bit immediate names it) in 2 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice
; ⚠ CORRECTED 2026-09-02 (lane res05x): the sentence above is no
;   longer true of this span -- 183 of 183 bytes are real source now, and no
;   `.incbin` remains between these markers.  What round 1 measured was
;   REACHABILITY, which finds an object's first byte and never its last;
;   the extents below come from the code that RUNS these records.

; ------------------------------------------------------------------
; 0xF03F77-0xF0402D -- 18 display-list records, 183 bytes -- interpreter A
;   entered at: 0xF03F77
;   ends used:  0xF03FF3, 0xF0402E
; Formerly Data_F03F77 + a 46-byte `.incbin` + Data_F03FAF -- the head,
; the middle and the tail of ONE list, cut in two places by the round-1
; reachability walk.  THE READER NAMES BOTH EDGES: SoundEditAmp_PaintHeader does
;   F5C72C  ld XIY,0x00F03F77   /  F5C738 ld XIX,0x00F0402E
;   F5C73F  ld XIX,0x00F03FF3   /  F5C744 call 0xF417F0
; so the list starts at 0xF03F77 and ends at 0xF03FF3 or 0xF0402E; the
; op/len chain below lands on BOTH.  Evidence, with the rejected
; alternatives: python3 notes/prom_b_res05x_spans.py --selftest
;
; Provenance kept from the superseded framing:
;   Data_F03F77 -- reached from: 0x00F03F77 appears as a 32-bit word at
;     0xF5C72D 0xF5D569; converted code at 0xF5C72C 0xF5D568 loads it as
;     a 32-bit immediate.  No routine-directory slot and no branch
;     decoded in converted code names it.
;   Data_F03FAF -- reached from: nothing aligned holds this address; the
;     walk fell through into it.
;   Both blocks carried the warning "The extent is the reachability
;   walk's, not the object's".  They were right, and this is the
;   correction they asked for.
; ------------------------------------------------------------------
SoundEditAmp_PaintHeader_DL:
; drawn (start operand) by SoundEditAmp_PaintHeader -- derivative name (notes/wsa1_display_list_drawer_names.py)
Data_F03F77:
	dl_value_glyph	glyph=99, x=96, y=1
	dl_text16x16_packed	x=122, y=5, text="AMPLITUDE"
	dl_text8x8_packed	x=6, y=7, text="SOUND EDIT"
	dl_text8x14	x=280, y=41, text="ENV \021"
	dl_text8x14	x=280, y=75, text="AMP \021"
	dl_box	x0=4, y0=4, x1=68, y1=16
	dl_box	x0=276, y0=37, x1=308, y1=54
	dl_box	x0=276, y0=65, x1=308, y1=94
	dl_hline	x0=288, y0=61, x1=295, y1=61
	dl_hline	x0=289, y0=62, x1=294, y1=62
	dl_hline	x0=290, y0=63, x1=293, y1=63
	dl_box	x0=291, y0=54, x1=292, y1=65
DL_F03FF3:	; the reader's other list end
	dl_text8x14	x=280, y=109, text="LF0 \021"
	dl_hline	x0=290, y0=96, x1=293, y1=96
	dl_hline	x0=289, y0=97, x1=294, y1=97
	dl_hline	x0=288, y0=98, x1=295, y1=98
	dl_box	x0=291, y0=94, x1=292, y1=105
	dl_box	x0=276, y0=105, x1=308, y1=122

; === END COVER-R1 0xF03F77-0xF0402E ===

; ------------------------------------------------------------------
; 0xF0402E-0xF04041 -- 2 display-list records, 20 bytes -- interpreter A
;   entered at: 0xF0402E, 0xF04038
;   ends used:  0xF04038, 0xF04042
; ------------------------------------------------------------------
TouchCurve_DrawCurrentSlot_DL2:
; ; drawn (start operand) by TouchCurve_DrawCurrentSlot -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=214, y0=70, x1=263, y1=225
TouchCurve_DrawCurrentSlot_DL1:
; ; drawn (start operand) by TouchCurve_DrawCurrentSlot -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=214, y0=70, x1=266, y1=161

; === COVER-R1 0xF04042-0xF0417E ===
; 0xF04042-0xF0417D, coverage round 1: 316 of this span's 316 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 316 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF04042-0xF0417D -- 316 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F04042 appears as a 32-bit word at 0xF0413E 0xF04142
;               0xF5BDCD; converted code at 0xF5BDCC loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 32% printable ASCII; a linear decode runs 132 instructions and
;           ends `nop`, with 46% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   its readers split it into the six lists and four tables below
;   (notes/promb-2026-09-25/touch_curve_lists.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DL_TouchCurve_0..5 -- 0xF04042-0xF0413D, six interpreter-A lists of 42 bytes
;   (4 records each): the captions TOUCH and CURVE (op 0x17), a box (op 0x22)
;   and a line (op 0x01), the same picture at six places.  Run one at a time
;   by TouchCurve_DrawCurrentSlot through TouchCurve_ListPtrs / TouchCurve_ListPtrs3 (`ld
;   XIY,(XIZ) / ld XIX,XIY / add XIX,42 / call T_DisplayList_Run` at
;   0xF5BE4B-0xF5BE55).  0xF04042 is also the END of the list before it (`ld
;   XIX,0x00F04042` at 0xF5BDCC).
;   notes/promb-2026-09-25/touch_curve_lists.py.
; --------------------------------------------------------------------------
DL_TouchCurve_0:
	dl_text8x8_packed	x=226, y=114, text="TOUCH"
	dl_text8x8_packed	x=232, y=123, text="CURVE"
	dl_box_shadow1	x0=224, y0=70, x1=262, y1=108
	dl_hline	x0=214, y0=90, x1=224, y1=90
DL_TouchCurve_1:
	dl_text8x8_packed	x=226, y=146, text="TOUCH"
	dl_text8x8_packed	x=232, y=155, text="CURVE"
	dl_box_shadow1	x0=224, y0=102, x1=262, y1=140
	dl_hline	x0=214, y0=122, x1=224, y1=122
DL_TouchCurve_2:
	dl_text8x8_packed	x=226, y=178, text="TOUCH"
	dl_text8x8_packed	x=232, y=187, text="CURVE"
	dl_box_shadow1	x0=224, y0=134, x1=262, y1=172
	dl_hline	x0=214, y0=154, x1=224, y1=154
DL_TouchCurve_3:
	dl_text8x8_packed	x=226, y=210, text="TOUCH"
	dl_text8x8_packed	x=232, y=219, text="CURVE"
	dl_box_shadow1	x0=224, y0=166, x1=262, y1=204
	dl_hline	x0=214, y0=186, x1=224, y1=186
DL_TouchCurve_4:
	dl_text8x8_packed	x=226, y=114, text="TOUCH"
	dl_text8x8_packed	x=232, y=123, text="CURVE"
	dl_box_shadow1	x0=224, y0=70, x1=262, y1=108
	dl_hline	x0=214, y0=90, x1=224, y1=90
DL_TouchCurve_5:
	dl_text8x8_packed	x=226, y=146, text="TOUCH"
	dl_text8x8_packed	x=232, y=155, text="CURVE"
	dl_box_shadow1	x0=224, y0=102, x1=262, y1=140
	dl_hline	x0=214, y0=122, x1=224, y1=122
; TouchCurve_ListPtrs -- 0xF0413E: 5 pointers to DL_TouchCurve_*, entry
;   (0x27A3) when (0x27F5) != 1: `ld XIZ,this` at 0xF5BE44, then `add XIZ,XWA
;   / ld XIY,(XIZ)`, XWA = 4 * (0x27A3).  5 = the distance to
;   TouchCurve_ListPtrs3 over 4.
TouchCurve_ListPtrs:
	.long	DL_TouchCurve_0	; F0413E  [0] -> DL_TouchCurve_0
	.long	DL_TouchCurve_0	; F04142  [1] -> DL_TouchCurve_0
	.long	DL_TouchCurve_1	; F04146  [2] -> DL_TouchCurve_1
	.long	DL_TouchCurve_2	; F0414A  [3] -> DL_TouchCurve_2
	.long	DL_TouchCurve_3	; F0414E  [4] -> DL_TouchCurve_3
; TouchCurve_ListPtrs3 -- 0xF04152: 3 pointers, the same when (0x27F5) == 1
;   (`cp (0x27f5),1` at 0xF5BE36, `ld XIZ,this` at 0xF5BE3D).  3 = the
;   distance to TouchCurve_BoxOrigins over 4.
TouchCurve_ListPtrs3:
	.long	DL_TouchCurve_4	; F04152  [0] -> DL_TouchCurve_4
	.long	DL_TouchCurve_4	; F04156  [1] -> DL_TouchCurve_4
	.long	DL_TouchCurve_5	; F0415A  [2] -> DL_TouchCurve_5
; TouchCurve_BoxOrigins -- 0xF0415E: 5 (x, y) word pairs, entry (0x27A3) when
;   (0x27F5) != 1 -> (0x2350), (0x2352): `ld XIZ,this` at 0xF5BE01, then `add
;   XIZ,XWA / ld WA,(XIZ) / ld (0x2350),WA / ld WA,(XIZ+2) / ld (0x2352),WA`.
;   Entry k is the top-left corner of the box the list TouchCurve_ListPtrs[k]
;   draws.  5 = the distance to TouchCurve_BoxOrigins3 over 4.
TouchCurve_BoxOrigins:
	.short	224, 70	; F0415E  [0]
	.short	224, 70	; F04162  [1]
	.short	224, 102	; F04166  [2]
	.short	224, 134	; F0416A  [3]
	.short	224, 166	; F0416E  [4]
; TouchCurve_BoxOrigins3 -- 0xF04172: 3 pairs, the same when (0x27F5) == 1
;   (`ld XIZ,this` at 0xF5BDFA), matching TouchCurve_ListPtrs3 -- except entry
;   0, x = 0xA8 where its list's box starts at x = 0xE0; they end the object
;   at 0xF0417D.
TouchCurve_BoxOrigins3:
	.short	168, 70	; F04172  [0]
	.short	224, 70	; F04176  [1]
	.short	224, 102	; F0417A  [2]

; === END COVER-R1 0xF04042-0xF0417E ===

; ------------------------------------------------------------------
; 0xF0417E-0xF04573 -- 115 display-list records, 1014 bytes -- interpreter A
;   entered at: 0xF0417E, 0xF0426B, 0xF04344, 0xF04358, 0xF04415, 0xF04560
;   ends used:  0xF0426B, 0xF04323, 0xF04344, 0xF04358, 0xF04370, 0xF04415, 0xF04560, 0xF04574
; ------------------------------------------------------------------
; DL_Page12LevelTouchCurveLevel -- the display list at 0xF0417E.  Its own text
;                                  records read: "PAGE1/2"; "LEVEL"; "TOUCH";
;                                  "CURVE"; "LEVEL"; "TOUCH"; "CURVE".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Page12LevelTouchCurveLevel:
	dl_text8x14	x=256, y=6, text="PAGE1/2"
	dl_text8x8_packed	x=67, y=62, text="LEVEL"
	dl_text8x8_packed	x=115, y=62, text="TOUCH"
	dl_text8x8_packed	x=163, y=62, text="CURVE"
	dl_text8x8_packed	x=78, y=209, text="LEVEL"
	dl_text8x8_packed	x=124, y=209, text="TOUCH"
	dl_text8x8_packed	x=165, y=209, text="CURVE"
	dl_text8x14	x=88, y=217, text="\215"
	dl_text8x14	x=136, y=217, text="\215"
	dl_text8x14	x=176, y=217, text="\215"
	dl_text8x14	x=88, y=227, text="\216"
	dl_text8x14	x=136, y=227, text="\216"
	dl_text8x14	x=176, y=227, text="\216"
	dl_box_shadow1	x0=11, y0=53, x1=212, y1=202
	dl_box_shadow1	x0=81, y0=218, x1=102, y1=238
	dl_box_shadow1	x0=129, y0=218, x1=150, y1=238
	dl_box_shadow1	x0=169, y0=218, x1=190, y1=238
	dl_hline	x0=11, y0=74, x1=212, y1=74
	dl_hline	x0=11, y0=106, x1=212, y1=106
	dl_hline	x0=11, y0=138, x1=212, y1=138
	dl_hline	x0=11, y0=170, x1=212, y1=170
	dl_hline	x0=81, y0=228, x1=102, y1=228
	dl_hline	x0=129, y0=228, x1=150, y1=228
	dl_hline	x0=169, y0=228, x1=190, y1=228
	dl_vline	x0=46, y0=53, x1=46, y1=202
	dl_fill_rect	x0=278, y0=67, x1=306, y1=92
; DL_Page22KeyFollowSlopeRange -- the display list at 0xF0426B.  Its own text
;                                 records read: "PAGE2/2"; "KEY FOLLOW";
;                                 "SLOPE"; "RANGE"; "LEVEL"; "LEVEL KEY
;                                 FOLLOW".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Page22KeyFollowSlopeRange:
	dl_text8x14	x=256, y=6, text="PAGE2/2"
	dl_text8x8_packed	x=118, y=62, text="KEY FOLLOW"
	dl_text8x8_packed	x=66, y=130, text="0"
	dl_text8x8_packed	x=93, y=130, text="1"
	dl_text8x8_packed	x=122, y=130, text="2"
	dl_text8x8_packed	x=150, y=130, text="3"
	dl_text8x8_packed	x=178, y=130, text="4"
	dl_text8x8_packed	x=206, y=130, text="5"
	dl_text8x8_packed	x=234, y=130, text="6"
	dl_text8x8_packed	x=86, y=209, text="SLOPE"
	dl_text8x8_packed	x=161, y=209, text="RANGE"
	dl_text8x16	x=152, y=215, text="_"
	dl_text8x16	x=192, y=215, text="__"
	dl_text8x14	x=160, y=217, text="_"
	dl_text8x16	x=96, y=232, text="\022"
	dl_text8x16	x=136, y=232, text="\022"
	dl_text8x16	x=176, y=232, text="\022"
	dl_text8x16	x=216, y=232, text="\022"
	dl_box_shadow1	x0=47, y0=72, x1=255, y1=122
	dl_hline	x0=82, y0=219, x1=235, y1=219
	dl_vline	x0=119, y0=205, x1=119, y1=233
	dl_fill_rect	x0=278, y0=67, x1=306, y1=92
	dl_fill_rect	x0=83, y0=220, x1=234, y1=232
	dl_text8x8_packed	x=14, y=95, text="LEVEL"
	dl_text8x8_packed	x=109, y=195, text="LEVEL KEY FOLLOW"
DL_F04344:
	dl_hline	x0=47, y0=97, x1=255, y1=97
	dl_box	x0=82, y0=205, x1=235, y1=233
; DL_EnvelopeKeyoffAtkPeakDecay1 -- the display list at 0xF04358.  Its own
;                                   text records read: "ENVELOPE"; "KEYOFF";
;                                   "ATK"; "PEAK"; "DECAY1"; "SUST1";
;                                   "DECAY2"; "SUST2" +1 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_EnvelopeKeyoffAtkPeakDecay1:
	dl_text8x8_packed	x=127, y=48, text="ENVELOPE"
	dl_box_shadow1	x0=50, y0=58, x1=257, y1=145
	dl_text8x8_packed	x=195, y=151, text="KEYOFF"
	dl_text8x8_packed	x=11, y=207, text="ATK"
	dl_text8x8_packed	x=41, y=207, text="PEAK"
	dl_text8x8_packed	x=71, y=207, text="DECAY1"
	dl_text8x8_packed	x=113, y=207, text="SUST1"
	dl_text8x8_packed	x=155, y=207, text="DECAY2"
	dl_text8x8_packed	x=197, y=207, text="SUST2"
	dl_text8x8_packed	x=239, y=207, text="RELEASE"
	dl_text8x16	x=16, y=231, text="\022"
	dl_text8x16	x=56, y=231, text="\022"
	dl_text8x16	x=96, y=231, text="\022"
	dl_text8x16	x=136, y=231, text="\022"
	dl_text8x16	x=176, y=231, text="\022"
	dl_text8x16	x=216, y=231, text="\022"
	dl_text8x16	x=264, y=231, text="\022"
	dl_box	x0=3, y0=203, x1=285, y1=232
	dl_hline	x0=3, y0=217, x1=285, y1=217
	dl_fill_rect	x0=4, y0=218, x1=284, y1=231
	dl_fill_rect	x0=278, y0=39, x1=306, y1=52
; DL_Page22KeyFollowEnvelopeKeyFollowTouchAtk -- the display list at 0xF04415,
;                                                named by mechanism M1 of note
;                                                s/prom_b_dl_screens_round5.py
;                                                .  "PAGE2/2"  "KEY FOLLOW ("
;                                                "ENVELOPE"  "KEY"  "FOLLOW"
;                                                "TOUCH"  "ATK"  "DECAY"
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim.  Round 4 stopped its CamelCase at
;           24 characters and this list collided; the name is the SAME
;           literals read further, and says what the list PUTS ON THE SCREEN
;           and nothing more.  Generated by notes/prom_b_dl_screens_round5.py
;           --apply.
DL_Page22KeyFollowEnvelopeKeyFollowTouchAtk:
	dl_text8x14	x=256, y=6, text="PAGE2/2"
	dl_text8x8_packed	x=85, y=62, text="KEY FOLLOW ("
	dl_text8x8_packed	x=66, y=130, text="0"
	dl_text8x8_packed	x=93, y=130, text="1"
	dl_text8x8_packed	x=122, y=130, text="2"
	dl_text8x8_packed	x=150, y=130, text="3"
	dl_text8x8_packed	x=178, y=130, text="4"
	dl_text8x8_packed	x=206, y=130, text="5"
	dl_text8x8_packed	x=234, y=130, text="6"
	dl_text8x8_packed	x=61, y=195, text="ENVELOPE"
	dl_text8x8_packed	x=115, y=195, text="KEY"
	dl_text8x8_packed	x=139, y=195, text="FOLLOW"
	dl_text8x8_packed	x=256, y=195, text="TOUCH"
	dl_text8x8_packed	x=7, y=209, text="ATK"
	dl_text8x8_packed	x=37, y=209, text="DECAY"
	dl_text8x8_packed	x=73, y=209, text="RELEASE"
	dl_text8x8_packed	x=158, y=209, text="RANGE"
	dl_text8x8_packed	x=241, y=209, text="ATTACK"
	dl_text8x8_packed	x=283, y=209, text="DECAY"
	dl_text8x16	x=144, y=215, text="_"
	dl_text8x16	x=192, y=215, text="_"
	dl_text8x14	x=152, y=217, text="_"
	dl_text8x14	x=184, y=217, text="_"
	dl_text8x16	x=16, y=232, text="\022"
	dl_text8x16	x=56, y=232, text="\022"
	dl_text8x16	x=96, y=232, text="\022"
	dl_text8x16	x=136, y=232, text="\022"
	dl_text8x16	x=176, y=232, text="\022"
	dl_text8x16	x=216, y=232, text="\022"
	dl_text8x16	x=256, y=232, text="\022"
	dl_text8x16	x=304, y=232, text="\022"
	dl_box_shadow1	x0=47, y0=72, x1=255, y1=122
	dl_box	x0=237, y0=205, x1=317, y1=233
	dl_hline	x0=3, y0=218, x1=230, y1=218
	dl_hline	x0=237, y0=218, x1=317, y1=218
	dl_vline	x0=117, y0=205, x1=117, y1=233
	dl_fill_rect	x0=278, y0=39, x1=306, y1=52
	dl_fill_rect	x0=4, y0=219, x1=229, y1=232
	dl_fill_rect	x0=238, y0=219, x1=316, y1=232
Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk_DL1:
; ; drawn (start operand) by Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_hline	x0=47, y0=97, x1=255, y1=97
	dl_box	x0=3, y0=205, x1=230, y1=233

; === COVER-R1 0xF04574-0xF04672 ===
; 0xF04574-0xF04671, coverage round 1: 41 of this span's 254 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 41 as DATA (only
; a `.long` or a 32-bit immediate names it) in 5 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice


; ------------------------------------------------------------------
; 0xF04574-0xF0459E -- 4 display-list records, 43 bytes -- interpreter A
; Formerly Data_F04574 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round4_module.py
; ------------------------------------------------------------------
SoundEditFilter_PaintHeader_DL:
; drawn (start operand) by SoundEditFilter_PaintHeader -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text16x16_packed	x=140, y=5, text="FILTER"
	dl_text8x8_packed	x=6, y=7, text="SOUND EDIT"
	dl_box	x0=4, y0=4, x1=68, y1=16
	dl_value_glyph	glyph=33, x=112, y=1


; ------------------------------------------------------------------
; 0xF0459F-0xF04631 -- 16 display-list records, 147 bytes -- interpreter A
; Formerly Data_F0459F -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round2_module.py
; ------------------------------------------------------------------
DL_F0459F:
	dl_text8x14	x=280, y=41, text="ENV \021"
	dl_text8x14	x=272, y=69, text="FIL"
	dl_text8x14	x=312, y=75, text="\021"
	dl_text8x14	x=280, y=81, text="TER"
	dl_text8x14	x=280, y=109, text="LF0 \021"
	dl_box	x0=276, y0=37, x1=308, y1=54
	dl_box	x0=268, y0=65, x1=308, y1=94
	dl_box	x0=276, y0=105, x1=308, y1=122
	dl_hline	x0=288, y0=61, x1=295, y1=61
	dl_hline	x0=289, y0=62, x1=294, y1=62
	dl_hline	x0=290, y0=63, x1=293, y1=63
	dl_hline	x0=290, y0=96, x1=293, y1=96
	dl_hline	x0=289, y0=97, x1=294, y1=97
	dl_hline	x0=288, y0=98, x1=295, y1=98
	dl_box	x0=291, y0=54, x1=292, y1=65
	dl_box	x0=291, y0=94, x1=292, y1=105


; ------------------------------------------------------------------
; 0xF04632-0xF0464F -- 3 display-list records, 30 bytes -- interpreter A
; Formerly Data_F04632 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round4_module.py
; ------------------------------------------------------------------
DL_F04632:
	dl_fill_rect	x0=278, y0=39, x1=306, y1=52
	dl_fill_rect	x0=270, y0=67, x1=306, y1=92
	dl_fill_rect	x0=278, y0=107, x1=306, y1=120


; ------------------------------------------------------------------
; 0xF04650-0xF04667 -- 3 display-list records, 24 bytes -- interpreter A
; Formerly Data_F04650 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round4_module.py
; ------------------------------------------------------------------
SoundEditFilter_PaintModeField_DL1:
; drawn (start operand) by SoundEditFilter_PaintModeField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x14	x=256, y=137, text="M0DE"
	dl_text8x14	x=304, y=153, text=" \021"
	dl_fill_rect	x0=252, y0=149, x1=308, y1=166

; --------------------------------------------------------------------------
; Data_F04668 -- 1 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F04668 appears as a 32-bit word at 0xF5C96C; converted
;               code at 0xF5C96B loads it as a 32-bit immediate.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 0% printable ASCII; a linear decode runs 1 instructions and ends
;           `halt`, with 0% of the bytes in spellings llvm-mc will not encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; ABSORBED 2026-09-02 -- see notes/gen_prom_b_tiny_records_batch.py: this object plus
; the .incbin that followed it is ONE interpreter-A record (verified against
; the ROM's own handler table, exactly one interpreter's implied-length rule fits).
Data_F04668:
	.byte 0x05, 0x0A, 0x0E, 0x01, 0x43, 0x00, 0x32, 0x01, 0x5C, 0x00	; A op 05, 10 bytes -> handler HTBL_A[5]

; === END COVER-R1 0xF04574-0xF04672 ===

; ------------------------------------------------------------------
; 0xF04672-0xF04CBC -- 172 display-list records, 1611 bytes -- interpreter A
;   entered at: 0xF04672, 0xF0467D, 0xF047CA, 0xF047DF, 0xF047F3, 0xF04889, 0xF0489D, 0xF048B2, 0xF049BC, 0xF049D3, 0xF049DD, 0xF049F3, 0xF049FD, 0xF04B1F, 0xF04B6C, 0xF04CA9
;   ends used:  0xF0467D, 0xF047CA, 0xF047DF, 0xF047F3, 0xF04889, 0xF0489D, 0xF048B2, 0xF049BC, 0xF049D3, 0xF049E7, 0xF049F3, 0xF049FD, 0xF04B1F, 0xF04B6C, 0xF04CA9, 0xF04CBD
; ------------------------------------------------------------------
SoundEdit_PaintPage12Label_DL:
; drawn (start operand) by SoundEdit_PaintPage12Label -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x14	x=256, y=6, text="PAGE1/2"
; DL_FilterCutoffEqualizerFreq -- the display list at 0xF0467D.  Its own text
;                                 records read: "FILTER:"; "CUTOFF";
;                                 "EQUALIZER"; "FREQ"; "FILTER"; "EQUALI";
;                                 "ER"; "CUTOFF" +8 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_FilterCutoffEqualizerFreq:
	dl_text8x8_packed	x=67, y=30, text="FILTER:"
	dl_text8x8_packed	x=213, y=98, text="CUTOFF"
	dl_text8x8_packed	x=67, y=108, text="EQUALIZER"
	dl_text8x8_packed	x=221, y=176, text="FREQ"
	dl_text8x14	x=56, y=193, text="FILTER"
	dl_text8x14	x=216, y=193, text="EQUALI"
	dl_text8x10	x=264, y=193, text="Z"
	dl_text8x14	x=272, y=193, text="ER"
	dl_text8x8_packed	x=6, y=209, text="CUTOFF"
	dl_text8x8_packed	x=52, y=209, text="RESO"
	dl_text8x8_packed	x=89, y=209, text="TOUCH"
	dl_text8x8_packed	x=125, y=209, text="CURVE"
	dl_text8x8_packed	x=202, y=209, text="RANGE"
	dl_text8x8_packed	x=244, y=209, text="FREQ"
	dl_text8x8_packed	x=280, y=209, text="GAIN"
	dl_text8x14	x=32, y=221, text="K"
	dl_text8x14	x=264, y=221, text="K"
	dl_text8x14	x=72, y=221, text="dB"
	dl_text8x14	x=296, y=221, text="dB"
	dl_text8x16	x=16, y=232, text="\022"
	dl_text8x16	x=56, y=232, text="\022"
	dl_text8x16	x=96, y=232, text="\022"
	dl_text8x16	x=136, y=232, text="\022"
	dl_text8x16	x=216, y=232, text="\022"
	dl_text8x16	x=256, y=232, text="\022"
	dl_text8x16	x=296, y=232, text="\022"
	dl_box_shadow1	x0=66, y0=39, x1=233, y1=94
	dl_box_shadow1	x0=66, y0=117, x1=233, y1=172
	dl_box	x0=2, y0=205, x1=160, y1=233
	dl_box	x0=187, y0=205, x1=316, y1=233
	dl_hline	x0=146, y0=113, x1=153, y1=113
	dl_hline	x0=147, y0=114, x1=152, y1=114
	dl_hline	x0=148, y0=115, x1=151, y1=115
	dl_hline	x0=2, y0=219, x1=160, y1=219
	dl_hline	x0=187, y0=219, x1=316, y1=219
	dl_box	x0=149, y0=96, x1=150, y1=117
	dl_fill_rect	x0=3, y0=220, x1=159, y1=232
	dl_fill_rect	x0=188, y0=220, x1=315, y1=232
; DL_HighPass12db -- the display list at 0xF047CA.  Its own text records read:
;                    "HIGH PASS -12dB".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_HighPass12db:
	dl_text8x8_packed	x=109, y=30, text="HIGH PASS -12dB"
; DL_LowPass12db -- the display list at 0xF047DF.  Its own text records read:
;                   "LOW PASS -12dB".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_LowPass12db:
	dl_text8x8_packed	x=109, y=30, text="LOW PASS -12dB"
; DL_FilterCutoffFilterCutoff -- the display list at 0xF047F3.  Its own text
;                                records read: "FILTER:"; "CUTOFF"; "FILTER";
;                                "CUTOFF"; "RESO"; "TOUCH"; "CURVE"; "dB".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_FilterCutoffFilterCutoff:
	dl_text8x8_packed	x=67, y=67, text="FILTER:"
	dl_text8x8_packed	x=211, y=135, text="CUTOFF"
	dl_text8x14	x=136, y=193, text="FILTER"
	dl_text8x8_packed	x=86, y=209, text="CUTOFF"
	dl_text8x8_packed	x=132, y=209, text="RESO"
	dl_text8x8_packed	x=169, y=209, text="TOUCH"
	dl_text8x8_packed	x=205, y=209, text="CURVE"
	dl_text8x14	x=112, y=221, text="K"
	dl_text8x14	x=152, y=221, text="dB"
	dl_text8x16	x=96, y=232, text="\022"
	dl_text8x16	x=136, y=232, text="\022"
	dl_text8x16	x=176, y=232, text="\022"
	dl_text8x16	x=216, y=232, text="\022"
	dl_box_shadow1	x0=66, y0=76, x1=233, y1=131
	dl_box	x0=77, y0=205, x1=240, y1=233
	dl_hline	x0=77, y0=219, x1=240, y1=219
	dl_fill_rect	x0=78, y0=220, x1=239, y1=232
; DL_LowPass24db -- the display list at 0xF04889.  Its own text records read:
;                   "LOW PASS -24dB".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_LowPass24db:
	dl_text8x8_packed	x=109, y=67, text="LOW PASS -24dB"
; DL_HighPass24db -- the display list at 0xF0489D.  Its own text records read:
;                    "HIGH PASS -24dB".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_HighPass24db:
	dl_text8x8_packed	x=109, y=67, text="HIGH PASS -24dB"
; DL_FilterBandPassLowHighCutoff -- the display list at 0xF048B2.  Its own
;                                   text records read: "FILTER:"; "BAND PASS";
;                                   "LOW"; "HIGH ~"; "CUTOFF"; "LOW"; "HIGH";
;                                   "CUTOFF" +7 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_FilterBandPassLowHighCutoff:
	dl_text8x8_packed	x=67, y=67, text="FILTER:"
	dl_text8x8_packed	x=109, y=67, text="BAND PASS"
	dl_text8x8_packed	x=85, y=135, text="\177 LOW"
	dl_text8x8_packed	x=169, y=135, text="HIGH ~"
	dl_text8x8_packed	x=212, y=135, text="CUTOFF"
	dl_text8x14	x=64, y=193, text="LOW"
	dl_text8x14	x=184, y=193, text="HIGH"
	dl_text8x8_packed	x=38, y=209, text="CUTOFF"
	dl_text8x8_packed	x=84, y=209, text="RESO"
	dl_text8x8_packed	x=126, y=209, text="CUTOFF"
	dl_text8x8_packed	x=172, y=209, text="RESO"
	dl_text8x8_packed	x=209, y=209, text="TOUCH"
	dl_text8x8_packed	x=245, y=209, text="CURVE"
	dl_text8x14	x=56, y=221, text="K"
	dl_text8x14	x=96, y=221, text="dB"
	dl_text8x14	x=152, y=221, text="K"
	dl_text8x14	x=192, y=221, text="dB"
	dl_text8x16	x=48, y=232, text="\022"
	dl_text8x16	x=88, y=232, text="\022"
	dl_text8x16	x=136, y=232, text="\022"
	dl_text8x16	x=176, y=232, text="\022"
	dl_text8x16	x=216, y=232, text="\022"
	dl_text8x16	x=256, y=232, text="\022"
	dl_box_shadow1	x0=66, y0=76, x1=233, y1=131
	dl_box	x0=29, y0=205, x1=117, y1=233
	dl_box	x0=122, y0=205, x1=280, y1=233
	dl_hline	x0=29, y0=219, x1=117, y1=219
	dl_hline	x0=122, y0=219, x1=280, y1=219
	dl_fill_rect	x0=30, y0=220, x1=116, y1=232
	dl_fill_rect	x0=123, y0=220, x1=279, y1=232
; DL_Through -- the display list at 0xF049BC.  Its own text records read:
;               "THROUGH".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Through:
	dl_text16x16_packed	x=112, y=96, text="THROUGH"
	dl_box_shadow1	x0=66, y0=76, x1=233, y1=131
Draw_Page12EnvelopeKeyoffCurSor_DL1:
; ; drawn (start operand) by Draw_Page12EnvelopeKeyoffCurSor -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_hline_dither	x0=50, y0=102, x1=257, y1=102
; DL_Keyoff -- the display list at 0xF049DD.  Its own text records read:
;              "KEYOFF".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Keyoff:
	dl_vline_dashed	x0=213, y0=58, x1=213, y1=145
	dl_text8x8_packed	x=195, y=151, text="KEYOFF"
Draw_Keyoff_DL3:
; ; drawn (start operand) by Draw_Keyoff -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=195, y0=58, x1=231, y1=157
; DL_Page12EnvelopeKeyoffCurSor -- the display list at 0xF049FD.  Its own text
;                                  records read: "PAGE1/2"; "ENVELOPE";
;                                  "KEYOFF"; "CUR"; "SOR"; "ATK"; "PEAK";
;                                  "DECAY1" +4 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Page12EnvelopeKeyoffCurSor:
	dl_text8x14	x=256, y=6, text="PAGE1/2"
	dl_text8x8_packed	x=127, y=48, text="ENVELOPE"
	dl_text8x8_packed	x=195, y=151, text="KEYOFF"
	dl_text8x14	x=304, y=151, text="\215 "
	dl_text8x8_packed	x=294, y=170, text="CUR"
	dl_text8x8_packed	x=300, y=179, text="SOR"
	dl_text8x14	x=304, y=191, text="\216 "
	dl_text8x8_packed	x=11, y=207, text="ATK"
	dl_text8x8_packed	x=41, y=207, text="PEAK"
	dl_text8x8_packed	x=71, y=207, text="DECAY1"
	dl_text8x8_packed	x=113, y=207, text="SUST1"
	dl_text8x8_packed	x=155, y=207, text="DECAY2"
	dl_text8x8_packed	x=197, y=207, text="SUST2"
	dl_text8x8_packed	x=239, y=207, text="RELEASE"
	dl_text8x16	x=16, y=231, text="\022"
	dl_text8x16	x=56, y=231, text="\022"
	dl_text8x16	x=96, y=231, text="\022"
	dl_text8x16	x=136, y=231, text="\022"
	dl_text8x16	x=176, y=231, text="\022"
	dl_text8x16	x=216, y=231, text="\022"
	dl_text8x16	x=264, y=231, text="\022"
	dl_box_shadow1	x0=50, y0=58, x1=257, y1=145
	dl_box	x0=294, y0=150, x1=319, y1=165
	dl_box	x0=296, y0=152, x1=317, y1=163
	dl_box	x0=60, y0=174, x1=285, y1=203
	dl_box	x0=294, y0=189, x1=319, y1=204
	dl_box	x0=296, y0=191, x1=317, y1=202
	dl_hline	x0=60, y0=188, x1=285, y1=188
	dl_vline	x0=138, y0=174, x1=138, y1=203
	dl_box	x0=3, y0=203, x1=285, y1=232
	dl_hline	x0=3, y0=217, x1=285, y1=217
	dl_fill_rect	x0=278, y0=39, x1=306, y1=52
; DL_StartPointStopPointCutoff -- the display list at 0xF04B1F.  Its own text
;                                 records read: "START"; "POINT"; "STOP";
;                                 "POINT"; "CUTOFF"; "ADJUST".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_StartPointStopPointCutoff:
	dl_text8x8_packed	x=65, y=178, text="START"
	dl_text8x8_packed	x=99, y=178, text="POINT"
	dl_text8x8_packed	x=142, y=178, text="STOP"
	dl_text8x8_packed	x=169, y=178, text="POINT"
	dl_text8x8_packed	x=204, y=178, text="CUTOFF"
	dl_text8x8_packed	x=246, y=178, text="ADJUST"
	dl_vline	x0=202, y0=174, x1=202, y1=203
; DL_Page22KeyFollowEnvelopeKeyFollowTouchAttack -- the display list at
;                                                   0xF04B6C, named by
;                                                   mechanism M1 of notes/prom
;                                                   _b_dl_screens_round5.py.
;                                                   "PAGE2/2"  "KEY"  "FOLLOW"
;                                                   "ENVELOPE"  "KEY"
;                                                   "FOLLOW"  "TOUCH"
;                                                   "ATTACK"
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim.  Round 4 stopped its CamelCase at
;           24 characters and this list collided; the name is the SAME
;           literals read further, and says what the list PUTS ON THE SCREEN
;           and nothing more.  Generated by notes/prom_b_dl_screens_round5.py
;           --apply.
DL_Page22KeyFollowEnvelopeKeyFollowTouchAttack:
	dl_text8x14	x=256, y=6, text="PAGE2/2"
	dl_text8x8_packed	x=85, y=62, text="KEY"
	dl_text8x8_packed	x=109, y=62, text="FOLLOW"
	dl_text8x8_packed	x=151, y=62, text="("
	dl_text8x8_packed	x=66, y=130, text="0"
	dl_text8x8_packed	x=93, y=130, text="1"
	dl_text8x8_packed	x=122, y=130, text="2"
	dl_text8x8_packed	x=150, y=130, text="3"
	dl_text8x8_packed	x=178, y=130, text="4"
	dl_text8x8_packed	x=206, y=130, text="5"
	dl_text8x8_packed	x=234, y=130, text="6"
	dl_text8x8_packed	x=61, y=195, text="ENVELOPE"
	dl_text8x8_packed	x=115, y=195, text="KEY"
	dl_text8x8_packed	x=139, y=195, text="FOLLOW"
	dl_text8x8_packed	x=256, y=195, text="TOUCH"
	dl_text8x8_packed	x=34, y=209, text="ATTACK"
	dl_text8x8_packed	x=76, y=209, text="DECAY"
	dl_text8x8_packed	x=112, y=209, text="RELEASE"
	dl_text8x8_packed	x=164, y=209, text="CENTER"
	dl_text8x8_packed	x=230, y=209, text="ADR-TIME"
	dl_text8x8_packed	x=284, y=209, text="DEPTH"
	dl_text8x16	x=56, y=232, text="\022"
	dl_text8x16	x=96, y=232, text="\022"
	dl_text8x16	x=136, y=232, text="\022"
	dl_text8x16	x=176, y=232, text="\022"
	dl_text8x16	x=256, y=232, text="\022"
	dl_text8x16	x=304, y=232, text="\022"
	dl_box_shadow1	x0=47, y0=72, x1=255, y1=122
	dl_box	x0=228, y0=205, x1=317, y1=233
	dl_hline	x0=30, y0=218, x1=206, y1=218
	dl_hline	x0=228, y0=218, x1=317, y1=218
	dl_vline	x0=158, y0=205, x1=158, y1=233
	dl_fill_rect	x0=31, y0=219, x1=205, y1=232
	dl_fill_rect	x0=229, y0=219, x1=316, y1=232
	dl_fill_rect	x0=278, y0=39, x1=306, y1=52
Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack_DL1:
; ; drawn (start operand) by Draw_Page22KeyFollowEnvelopeKeyFollowTouchAttack -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_hline	x0=47, y0=97, x1=255, y1=97
	dl_box	x0=30, y0=205, x1=206, y1=233

; ==================================================================
; 0xF04CBD-0xF04CDD -- display-list OPERAND TABLES (33 bytes, 2 objects)
; ==================================================================
;
; Every object here is named by a display-list record that points at it, and
; its SIZE is proven by tiling: the objects start at the first byte of this
; gap, each extent is a whole number of entries, and the last object's
; handler-implied size ends exactly on the first byte of the next display
; list.  Reproduce with `python3 notes/prom_b_dl_operand_tables.py --exact`.
;
; ------------------------------------------------------------------
; DLTable_ABCDEFGHIJKLMNOPQRSU -- 25 entries of 1 characters
; Referenced by: display-list records 0xF0306E, 0xF0308C, 0xF030AA, 0xF030C8, 0xF33549, 0xF33B09, 0xF33B27, 0xF33B45, 0xF33B63
; Evidence: the record's +7 pointer lands here and its +0x0B word is 1, so the
;           entries are 1 bytes wide (handler 0xF31B21/0xF31B39 loads the
;           extracted bit-field into HL as the index).
;           25 entries is the EXTENT (25 bytes / 1), not the (mask >> shift) + 1
;           = 128 the record would allow.
; ------------------------------------------------------------------
; DLTable_ABCDEFGHIJKLMNOPQRSU -- renamed from DLTable_F04CBD: the object's
;                                 own entries are "A"; "B"; "C"; "D"; "E";
;                                 "F"; "G"; "H". +17 more
; Evidence: the text printed below this label IS the object's whole content;
;           the name is CamelCase of its first entries and claims only what
;           the object HOLDS -- not what indexes it, and not what the words
;           mean.  The KIND is the one the tree already established and is
;           kept; only the address is replaced.  Generated by
;           notes/prom_b_dl_screens_round5.py --tables --apply.
DLTable_ABCDEFGHIJKLMNOPQRSU:
	.ascii "A"	; [0]
	.ascii "B"	; [1]
	.ascii "C"	; [2]
	.ascii "D"	; [3]
	.ascii "E"	; [4]
	.ascii "F"	; [5]
	.ascii "G"	; [6]
	.ascii "H"	; [7]
	.ascii "I"	; [8]
	.ascii "J"	; [9]
	.ascii "K"	; [10]
	.ascii "L"	; [11]
	.ascii "M"	; [12]
	.ascii "N"	; [13]
	.ascii "O"	; [14]
	.ascii "P"	; [15]
	.ascii "Q"	; [16]
	.ascii "R"	; [17]
	.ascii "S"	; [18]
	.ascii "U"	; [19]
	.ascii "V"	; [20]
	.ascii "W"	; [21]
	.ascii "X"	; [22]
	.ascii "Y"	; [23]
	.ascii "Z"	; [24]
; ------------------------------------------------------------------
; DLTable_LowHigh -- 2 entries of 4 characters
; Referenced by: display-list record 0xF04D85
; Evidence: the record's +7 pointer lands here and its +0x0B word is 4, so the
;           entries are 4 bytes wide (handler 0xF31B21/0xF31B39 loads the
;           extracted bit-field into HL as the index).
;           2 entries is the EXTENT (8 bytes / 4), not the (mask >> shift) + 1
;           = 2 the record would allow.
; ------------------------------------------------------------------
; DLTable_LowHigh -- renamed from DLTable_F04CD6: the object's own entries are
;                    "LOW"; "HIGH".
; Evidence: the text printed below this label IS the object's whole content;
;           the name is CamelCase of its first entries and claims only what
;           the object HOLDS -- not what indexes it, and not what the words
;           mean.  The KIND is the one the tree already established and is
;           kept; only the address is replaced.  Generated by
;           notes/prom_b_dl_screens_round5.py --tables --apply.
DLTable_LowHigh:
	.ascii "LOW "	; [0]
	.ascii "HIGH"	; [1]

; ------------------------------------------------------------------
; 0xF04CDE-0xF04CE7 -- 1 display-list records, 10 bytes -- interpreter A
;   entered at: 0xF04CDE
;   ends used:  0xF04CE8
; ------------------------------------------------------------------
SoundEditModelingToneTemplate_RepaintField_DL:
; ; drawn (start operand) by SoundEditModelingToneTemplate_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=11, y0=74, x1=264, y1=202

; === COVER-R1 0xF04CE8-0xF04D43 ===
; 0xF04CE8-0xF04D42, coverage round 1: 76 of this span's 91 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 76 as DATA (only
; a `.long` or a 32-bit immediate names it) in 2 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice
; ⚠ CORRECTED 2026-09-02 (lane res05x): the sentence above is no
;   longer true of this span -- 91 of 91 bytes are real source now, and no
;   `.incbin` remains between these markers.  What round 1 measured was
;   REACHABILITY, which finds an object's first byte and never its last;
;   the extents below come from the code that RUNS these records.

; ------------------------------------------------------------------
; 0xF04CE8-0xF04D42 -- a 5x8 rectangle array, one display-list record,
; and the 6-byte string table that record points at.  91 bytes, tiled
; end to end between two addresses the READER names:
;   0xF5CE93  ld XIY,0x00F04CDE ; ld XIX,0x00F04CE8  -> list ends here
;   0xF5C979  ld XIY,0x00F04D10 ; call 0xF41830      -> record starts here
;   0xF5C907  ld XIY,0x00F04D43                      -> next list
; 5*8 + 15 + 6*6 = 91 = 0xF04D43 - 0xF04CE8, with no slack.
; Evidence: python3 notes/prom_b_res05x_spans.py --selftest
;
; Provenance kept from the superseded framing:
;   Data_F04CE8 -- reached from: 0x00F04CE8 appears as a 32-bit word at
;     0xF33B88 0xF5CE99; converted code at 0xF5CE98 loads it as a 32-bit
;     immediate.  (0xF33B81 is the interpreter-B op-03 record whose
;     +0x07 operand that is -- "array of 8-byte entries".)
;   Data_F04D23 -- reached from: nothing aligned holds this address; the
;     walk fell through into it.  ITS START WAS MID-ENTRY: 0xF04D23 is
;     +4 inside the first 6-byte table entry, which is why the label is
;     not reproduced here.  The table's real head is 0xF04D1F, named by
;     the record at 0xF04D10.
; ------------------------------------------------------------------
DLTable_F04CE8:	; 5 entries of 8 bytes -- highlight rectangles (x1,y1,x2,y2)
;   Referenced by: display-list record 0xF33B81 (interpreter B op 03,
;   handler 0xF31B57, which does `sla 3,HL` -> 8-byte entries).
;   5 entries is the EXTENT (40 bytes / 8), not the (mask >> shift) + 1
;   = 16 the record would allow.  [0] == [1] is this ROM's idiom for a
;   4-item list whose selector is 1-based.
	.short 0x000D, 0x004C, 0x0106, 0x0068	; [0]
	.short 0x000D, 0x004C, 0x0106, 0x0068	; [1]
	.short 0x000D, 0x006C, 0x0106, 0x0088	; [2]
	.short 0x000D, 0x008C, 0x0106, 0x00A8	; [3]
	.short 0x000D, 0x00AC, 0x0106, 0x00C8	; [4]
SoundEditFilter_PaintModeField_DL2:
; drawn (start operand) by SoundEditFilter_PaintModeField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=0x27be, mask=0x07, shift=0, svc=LCDSVC_DrawText8x10, table=DLTable_F04D1F, width=6, x=256, y=153
DLTable_F04D1F:	; 6 entries of 6 bytes -- the filter-mode names
;   Referenced by: the record at 0xF04D10, whose +0x0B says 6 bytes per
;   entry.  6 entries is the EXTENT (36 bytes / 6); the mask 0x07 at
;   +0x04 would allow 8.
	.ascii "LPF+EQ"	; [0]
	.ascii "HPF+EQ"	; [1]
	.ascii "LPF24 "	; [2]
	.ascii "HPF24 "	; [3]
	.ascii " BPF  "	; [4]
	.ascii " THRU "	; [5]

; === END COVER-R1 0xF04CE8-0xF04D43 ===

; ------------------------------------------------------------------
; 0xF04D43-0xF04DA2 -- 7 display-list records, 96 bytes -- interpreter B
;   entered at: 0xF04D43, 0xF04D85
;   ends used:  0xF04DA3
; ------------------------------------------------------------------
DL_F04D43:
	dlb_number_signed	var=ModelingPage_Fields, mask=0xe0, shift=5, svc=LCDSVC_DrawText8x10, x=128, y=221, digits=1, signflag=0x03
	dlb_number	var=ModelingPage_Fields+1, mask=0x3f, shift=0, svc=LCDSVC_DrawText8x10, x=96, y=221, digits=2
	dlb_string	var=ModelingPage_Fields+2, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_Frequencies65HzTo48K, width=5, x=8, y=221
	dlb_string	var=ModelingPage_Fields+3, mask=0x07, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_Minus6ToPlus9By3, width=2, x=56, y=221
	dlb_string	var=ModelingPage_Fields+4, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_Frequencies65HzTo48K, width=5, x=232, y=221
; DL_LowHigh -- the display list at 0xF04D85, named by mechanism M2 of
;               notes/prom_b_dl_screens_round5.py.  DLTable_LowHigh: "LOW",
;               "HIGH"
; Evidence: this list has no text of its own.  Its interpreter-B records name
;           the table below by a 32-bit operand, and that table holds the
;           NAMES the drawn value indexes, so those names are what the list
;           puts on the screen -- one of them at a time.  Generated by
;           notes/prom_b_dl_screens_round5.py --apply.
DL_LowHigh:
	dlb_string	var=ModelingPage_Fields+5, mask=0x80, shift=7, svc=LCDSVC_DrawText8x10, table=DLTable_LowHigh, width=4, x=192, y=221
	dlb_string	var=ModelingPage_Fields+5, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_DashesMinus6ToPlus6, width=3, x=272, y=221

; === COVER-R1 0xF04DA3-0xF04DFF ===
; 0xF04DA3-0xF04DFE, coverage round 1: 92 of this span's 92 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 92 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF04DA3-0xF04DFE -- 92 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F04DA3 appears as a 32-bit word at 0xF5C90D 0xF5C9C5
;               0xF5D0B8 0xF5D0C8 0xF5D0E0 +1 more; converted code at 0xF5C90C
;               0xF5C9C4 0xF5D0B7 0xF5D0C7 loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 89% printable ASCII; a linear decode runs 39 instructions and ends
;           `ld IZ,0x0000`, with 11% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBRecordPtrs_F04DA3 -- 0xF04DA3-0xF04DB6, 5 32-bit pointers, each to the
;   first byte of an interpreter-B record.  Read by
;   RunDisplayListBFromPointerArray (0xF09AE1: `sla 2,WA / add XIY,XWA / ld
;   XIY,(XIY)`, then ONE record is run) with XIY = this address at 0xF5D0C7,
;   0xF5D0EF.  Entry count: the distance to the first table over 4 -- the
;   reader indexes by A and does not bound it.  This address is also the END
;   of a display list: `ld XIY,0xF04D43 / ld XIX,this / call
;   T_DisplayListB_Run` at 0xF5C90C; `ld XIY,0xF04D43 / ld XIX,this / call
;   T_DisplayListB_Run` at 0xF5C9C4; `ld XIY,0xF04D85 / ld XIX,this / call
;   T_DisplayListB_Run` at 0xF5D0B7; `ld XIY,0xF04D85 / ld XIX,this / call
;   T_DisplayListB_Run` at 0xF5D0DF.
; --------------------------------------------------------------------------
DLBRecordPtrs_F04DA3:
	.long	DL_F04D43	; F04DA3  [0]
	.long	DL_F04D43 + 0xB	; F04DA7  [1]
	.long	DL_F04D43 + 0x15	; F04DAB  [2]
	.long	DL_F04D43 + 0x24	; F04DAF  [3]
	.long	DL_F04D43 + 0x33	; F04DB3  [4]
; --------------------------------------------------------------------------
; DLText_Minus6ToPlus9By3 -- 0xF04DB7-0xF04DC2, 6 entries of 2 bytes, text
;   drawn by LCD_Svc_20_DrawText8x10.  Read by the interpreter-B op-0x02
;   records at 0xF04D67 ((0x27A9) AND 0x07 >> 0), 0xF04E66 ((0x27A9) AND
;   0x07 >> 0), 0xF04E84 ((0x27AB) AND 0x07 >> 0) -- value = (byte at the +2
;   address) AND mask >> shift -- whose +0x07 names this address;
;   DLB_Handler_StringTable draws entry [value] with +0x0B = 2 as the width.
;   Entry count: the distance to the next table over the width; the masks
;   admit 8.
; --------------------------------------------------------------------------
DLText_Minus6ToPlus9By3:
	.ascii	"-6"	; F04DB7  [0]
	.ascii	"-3"	; F04DB9  [1]
	.ascii	" 0"	; F04DBB  [2]
	.ascii	"+3"	; F04DBD  [3]
	.ascii	"+6"	; F04DBF  [4]
	.ascii	"+9"	; F04DC1  [5]
; --------------------------------------------------------------------------
; DLText_Minus12ToPlus18By6 -- 0xF04DC3-0xF04DD4, 6 entries of 3 bytes, text
;   drawn by LCD_Svc_20_DrawText8x10.  Read by the interpreter-B op-0x02
;   record at 0xF04E23 ((0x27A9) AND 0x07 >> 0) -- value = (byte at the +2
;   address) AND mask >> shift -- whose +0x07 names this address;
;   DLB_Handler_StringTable draws entry [value] with +0x0B = 3 as the width.
;   Entry count: the distance to the next table over the width; the masks
;   admit 8.
; --------------------------------------------------------------------------
DLText_Minus12ToPlus18By6:
	.ascii	"-12"	; F04DC3  [0]
	.ascii	"- 6"	; F04DC6  [1]
	.ascii	"  0"	; F04DC9  [2]
	.ascii	"+ 6"	; F04DCC  [3]
	.ascii	"+12"	; F04DCF  [4]
	.ascii	"+18"	; F04DD2  [5]
; --------------------------------------------------------------------------
; DLText_DashesMinus6ToPlus6 -- 0xF04DD5-0xF04DFE, 14 entries of 3 bytes,
;   text drawn by LCD_Svc_20_DrawText8x10.  Read by the interpreter-B
;   op-0x02 record at 0xF04D94 ((0x27AB) AND 0x7F >> 0) -- value = (byte at
;   the +2 address) AND mask >> shift -- whose +0x07 names this address;
;   DLB_Handler_StringTable draws entry [value] with +0x0B = 3 as the width.
;   Entry count: the distance to the object's end over the width; the masks
;   admit 128.
; --------------------------------------------------------------------------
DLText_DashesMinus6ToPlus6:
	.ascii	" --"	; F04DD5  [0]
	.ascii	" -6"	; F04DD8  [1]
	.ascii	" -5"	; F04DDB  [2]
	.ascii	" -4"	; F04DDE  [3]
	.ascii	" -3"	; F04DE1  [4]
	.ascii	" -2"	; F04DE4  [5]
	.ascii	" -1"	; F04DE7  [6]
	.ascii	"  0"	; F04DEA  [7]
	.ascii	" +1"	; F04DED  [8]
	.ascii	" +2"	; F04DF0  [9]
	.ascii	" +3"	; F04DF3  [10]
	.ascii	" +4"	; F04DF6  [11]
	.ascii	" +5"	; F04DF9  [12]
	.ascii	" +6"	; F04DFC  [13]

; === END COVER-R1 0xF04DA3-0xF04DFF ===

; ------------------------------------------------------------------
; 0xF04DFF-0xF04E31 -- 4 display-list records, 51 bytes -- interpreter B
;   entered at: 0xF04DFF
;   ends used:  0xF04E32
; ------------------------------------------------------------------
DL_F04DFF:
	dlb_number_signed	var=ModelingPage_Fields, mask=0xe0, shift=5, svc=LCDSVC_DrawText8x10, x=208, y=221, digits=1, signflag=0x03
	dlb_number	var=ModelingPage_Fields+1, mask=0x3f, shift=0, svc=LCDSVC_DrawText8x10, x=176, y=221, digits=2
	dlb_string	var=ModelingPage_Fields+2, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_Frequencies65HzTo48K, width=5, x=80, y=221
	dlb_string	var=ModelingPage_Fields+3, mask=0x07, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_Minus12ToPlus18By6, width=3, x=128, y=221

; === COVER-R1 0xF04E32-0xF04E42 ===
; 0xF04E32-0xF04E41, coverage round 1: 1 of this span's 16 bytes are reachable
; -- 0 as CODE (an entry point in the routine directory, or a branch prom_b's
; own converted instructions decode) in 0 runs, and 1 as DATA (only a `.long`
; or a 32-bit immediate names it) in 1 run.  Everything else here is NOT
; reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F04E32 -- 1 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F04E32 appears as a 32-bit word at 0xF5CA10 0xF5CA5B
;               0xF5D0FF 0xF5D10E; converted code at 0xF5CA0F 0xF5CA5A
;               0xF5D0FE 0xF5D10D loads it as a 32-bit immediate.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 0% printable ASCII; a linear decode runs 1 instructions and ends
;           `swi 7`, with 0% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F04E32:
	.byte	0xFF	; F04E32  |.|

; --- 0xF04E33-0xF04E41, 15 B, converted by lane promB6 (PTRTAB4).
;     4-entry pointer array
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x4D, 0xF0, 0x00	; F04E33  top 3 bytes of the entry at F04E32 = 0x00F04DFF
	.long	DL_F04DFF + 0xB	; F04E36  entry 1
	.long	DL_F04DFF + 0x15	; F04E3A  entry 2
	.long	DL_F04DFF + 0x24	; F04E3E  entry 3

; === END COVER-R1 0xF04E32-0xF04E42 ===

; ------------------------------------------------------------------
; 0xF04E42-0xF04E92 -- 6 display-list records, 81 bytes -- interpreter B
;   entered at: 0xF04E42
;   ends used:  0xF04E93
; ------------------------------------------------------------------
Draw_FilterBandPassLowHighCutoff_DL:
; ; drawn (start operand) by Draw_FilterBandPassLowHighCutoff -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number_signed	var=ModelingPage_Fields, mask=0xe0, shift=5, svc=LCDSVC_DrawText8x10, x=248, y=221, digits=1, signflag=0x03
	dlb_number	var=ModelingPage_Fields+1, mask=0x3f, shift=0, svc=LCDSVC_DrawText8x10, x=216, y=221, digits=2
	dlb_string	var=ModelingPage_Fields+2, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_Frequencies65HzTo48K, width=5, x=32, y=221
	dlb_string	var=ModelingPage_Fields+3, mask=0x07, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_Minus6ToPlus9By3, width=2, x=80, y=221
	dlb_string	var=ModelingPage_Fields+4, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_Frequencies65HzTo48K, width=5, x=128, y=221
	dlb_string	var=ModelingPage_Fields+5, mask=0x07, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_Minus6ToPlus9By3, width=2, x=176, y=221

; === COVER-R1 0xF04E93-0xF04EAB ===
; 0xF04E93-0xF04EAA, coverage round 1: 24 of this span's 24 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 24 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF04E93-0xF04EAA -- 24 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F04E93 appears as a 32-bit word at 0xF5CA98 0xF5D11D;
;               converted code at 0xF5CA97 0xF5D11C loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 46% printable ASCII; a linear decode runs 11 instructions and ends
;           `ld (0x00),0x00`, with 46% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the readers below fix what the object is (notes/promb-2026-09-25/
;   dl_pointer_tables.py).  The rest of this span is unreachable and stays
;   `.incbin`.  Why this is data and not code: THE PROVENANCE SPLIT in
;   notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLRecordPtrs_F04E93 -- 0xF04E93-0xF04EAA, 6 32-bit pointers, each to the
;   first byte of a display-list record (op 00 len 10, op 02 len 15, op 05 len
;   11).  Read by: `ld XIY,this / call RunDisplayListBFromPointerArray` at
;   0xF5D11C: ONE interpreter-B record from entry A.  Its address is also used
;   as a list end: `ld XIY,0xF04E42 / ld XIX,this / call T_DisplayListB_Run`
;   at 0xF5CA97: the END of the list that starts at 0xF04E42.  Entry count:
;   the object's extent over 4; every word is a record start
;   (notes/promb-2026-09-25/dl_pointer_tables.py).
; --------------------------------------------------------------------------
DLRecordPtrs_F04E93:
	.long	Draw_FilterBandPassLowHighCutoff_DL	; F04E93  [0]
	.long	Draw_FilterBandPassLowHighCutoff_DL + 0xB	; F04E97  [1]
	.long	Draw_FilterBandPassLowHighCutoff_DL + 0x15	; F04E9B  [2]
	.long	Draw_FilterBandPassLowHighCutoff_DL + 0x24	; F04E9F  [3]
	.long	Draw_FilterBandPassLowHighCutoff_DL + 0x33	; F04EA3  [4]
	.long	Draw_FilterBandPassLowHighCutoff_DL + 0x42	; F04EA7  [5]

; === END COVER-R1 0xF04E93-0xF04EAB ===

; ------------------------------------------------------------------
; 0xF04EAB-0xF04F1F -- 11 display-list records, 117 bytes -- interpreter B
;   entered at: 0xF04EAB
;   ends used:  0xF04F20
; ------------------------------------------------------------------
Draw_Page12EnvelopeKeyoffCurSor_DL2:
; ; drawn (start operand) by Draw_Page12EnvelopeKeyoffCurSor -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number_signed	var=ModelingPage_Fields+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=80, y=191, digits=3, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+10, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=160, y=191, digits=3, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=248, y=191, digits=3, signflag=0x00
	dlb_number	var=ModelingPage_Fields+3, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=8, y=220, digits=3
	dlb_number_signed	var=ModelingPage_Fields+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=40, y=220, digits=3, signflag=0x00
	dlb_number	var=ModelingPage_Fields+5, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=80, y=220, digits=3
	dlb_number_signed	var=ModelingPage_Fields+6, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=120, y=220, digits=3, signflag=0x00
	dlb_number	var=ModelingPage_Fields+7, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=160, y=220, digits=3
	dlb_number_signed	var=ModelingPage_Fields+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=200, y=220, digits=3, signflag=0x00
	dlb_number	var=ModelingPage_Fields+9, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=248, y=220, digits=3
	dlb_rect_entry	var=ModelingPage_Fields, mask=0x01, shift=0, svc=LCDSVC_FillRect, table=DLBoxes_F04F22

; === COVER-R1 0xF04F20-0xF04F32 ===
; 0xF04F20-0xF04F31, coverage round 1: 18 of this span's 18 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 18 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF04F20-0xF04F31 -- 18 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F04F20 appears as a 32-bit word at 0xF5CB15; converted
;               code at 0xF5CB14 loads it as a 32-bit immediate.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 17% printable ASCII; a linear decode runs 12 instructions and ends
;           `nop`, with 67% of the bytes in spellings llvm-mc will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; Data_F04F20 -- 0xF04F20-0xF04F21, 2 bytes in front of the tables below.
;   No interpreter-B record's +0x07 and no pointer-array run names them;
;   purpose not established.  This address is also the END of a display
;   list: `ld XIY,0xF04EAB / ld XIX,this / call T_DisplayListB_Run` at
;   0xF5CB14.
; --------------------------------------------------------------------------
Data_F04F20:
	.byte	0x2B, 0x2D	; F04F20
; --------------------------------------------------------------------------
; DLBoxes_F04F22 -- 0xF04F22-0xF04F31, 2 entries of four words, left / top /
;   right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF04F15 ((0x27A6)
;   AND 0x01 >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`).  Entry count: the distance to the
;   object's end over the width; the masks admit 2.
; --------------------------------------------------------------------------
DLBoxes_F04F22:
	.short	61, 189, 284, 202	; F04F22  [0]
	.short	4, 218, 284, 231	; F04F2A  [1]

; === END COVER-R1 0xF04F20-0xF04F32 ===

; ------------------------------------------------------------------
; 0xF04F32-0xF04F45 -- 2 display-list records, 20 bytes -- interpreter A
;   entered at: 0xF04F32
;   ends used:  0xF04F46
; ------------------------------------------------------------------
SoundEditEnvelope1_RepaintField_DL:
; ; drawn (start operand) by SoundEditEnvelope1_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=61, y0=189, x1=284, y1=202
	dl_erase_rect	x0=4, y0=218, x1=284, y1=231

; === COVER-R1 0xF04F46-0xF04F72 ===
; 0xF04F46-0xF04F71, coverage round 1: 17 of this span's 44 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 17 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F04F46 -- 17 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F04F46 appears as a 32-bit word at 0xF5D135 0xF5D145;
;               converted code at 0xF5D134 0xF5D144 loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 24% printable ASCII; a linear decode runs 9 instructions and ends
;           `jp Z,0x00`, with 0% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F04F46:
	.byte	0x15, 0x4F, 0xF0, 0x00, 0xC1, 0x4E, 0xF0, 0x00, 0xAB, 0x4E, 0xF0, 0x00, 0xCC, 0x4E, 0xF0, 0x00	; F04F46  |.O...N...N...N..|
	.byte	0xD6	; F04F56  |.|

; --- 0xF04F57-0xF04F71, 27 B, converted by lane promB6 (PTRTAB4).
;     11-entry pointer array
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x4E, 0xF0, 0x00	; F04F57  top 3 bytes of the entry at F04F56 = 0x00F04ED6
	.long	Draw_Page12EnvelopeKeyoffCurSor_DL2 + 0x36	; F04F5A  entry 5
	.long	Draw_Page12EnvelopeKeyoffCurSor_DL2 + 0x40	; F04F5E  entry 6
	.long	Draw_Page12EnvelopeKeyoffCurSor_DL2 + 0x4B	; F04F62  entry 7
	.long	Draw_Page12EnvelopeKeyoffCurSor_DL2 + 0x55	; F04F66  entry 8
	.long	Draw_Page12EnvelopeKeyoffCurSor_DL2 + 0x60	; F04F6A  entry 9
	.long	Draw_Page12EnvelopeKeyoffCurSor_DL2 + 0xB	; F04F6E  entry 10

; === END COVER-R1 0xF04F46-0xF04F72 ===

; ------------------------------------------------------------------
; 0xF04F72-0xF04FFC -- 13 display-list records, 139 bytes -- interpreter B
;   entered at: 0xF04F72
;   ends used:  0xF04FFD
; ------------------------------------------------------------------
Draw_Page12LevelTouchCurveLevel_DL:
; ; drawn (start operand) by Draw_Page12LevelTouchCurveLevel -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number	var=ModelingPage_Fields+1, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=72, y=85, digits=3
	dlb_number	var=ModelingPage_Fields+2, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=72, y=117, digits=3
	dlb_number	var=ModelingPage_Fields+3, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=72, y=150, digits=3
	dlb_number	var=ModelingPage_Fields+4, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=72, y=182, digits=3
	dlb_number_signed	var=ModelingPage_Fields+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=120, y=85, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+6, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=120, y=117, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=120, y=150, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=120, y=182, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+9, mask=0xe0, shift=5, svc=LCDSVC_DrawText8x10, x=168, y=85, digits=2, signflag=0x03
	dlb_number_signed	var=ModelingPage_Fields+10, mask=0xe0, shift=5, svc=LCDSVC_DrawText8x10, x=168, y=117, digits=2, signflag=0x03
	dlb_number_signed	var=ModelingPage_Fields+11, mask=0xe0, shift=5, svc=LCDSVC_DrawText8x10, x=168, y=150, digits=2, signflag=0x03
	dlb_number_signed	var=ModelingPage_Fields+12, mask=0xe0, shift=5, svc=LCDSVC_DrawText8x10, x=168, y=182, digits=2, signflag=0x03
	dlb_rect_entry	var=0x27a3, mask=0x0f, shift=0, svc=LCDSVC_FillRect, table=DLBoxes_F0503B

; === COVER-R1 0xF04FFD-0xF05063 ===
; 0xF04FFD-0xF05062, coverage round 1: 85 of this span's 102 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 85 as DATA (only
; a `.long` or a 32-bit immediate names it) in 3 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F04FFD -- 41 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F04FFD appears as a 32-bit word at 0xF5C709 0xF5D037;
;               converted code at 0xF5C708 0xF5D036 loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 29% printable ASCII; a linear decode runs 19 instructions and ends
;           `jp LT,0x00`, with 34% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F04FFD:
	.byte	0xF2, 0x4F, 0xF0, 0x00, 0x72, 0x4F, 0xF0, 0x00, 0x7C, 0x4F, 0xF0, 0x00, 0x86, 0x4F, 0xF0, 0x00	; F04FFD  |.O..rO..|O...O..|
	.byte	0x90, 0x4F, 0xF0, 0x00, 0x9A, 0x4F, 0xF0, 0x00, 0xA5, 0x4F, 0xF0, 0x00, 0xB0, 0x4F, 0xF0, 0x00	; F0500D  |.O...O...O...O..|
	.byte	0xBB, 0x4F, 0xF0, 0x00, 0xC6, 0x4F, 0xF0, 0x00, 0xD1	; F0501D  |.O...O...|

; --- 0xF05026-0xF05030, 11 B, converted by lane promB6 (PTRTAB4).
;     13-entry pointer array
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x4F, 0xF0, 0x00	; F05026  top 3 bytes of the entry at F05025 = 0x00F04FD1
	.long	Draw_Page12LevelTouchCurveLevel_DL + 0x6A	; F05029  entry 11
	.long	Draw_Page12LevelTouchCurveLevel_DL + 0x75	; F0502D  entry 12

; --------------------------------------------------------------------------
; Data_F05031 -- 4 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F05031 appears as a 32-bit word at 0xF5D00A; converted
;               code at 0xF5D009 loads it as a 32-bit immediate.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 0% printable ASCII; a linear decode runs 1 instructions and ends
;           `jp 0x000d0a`, with 0% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; ABSORBED 2026-09-02 -- see notes/gen_prom_b_tiny_records_batch.py: this object plus
; the .incbin that followed it is ONE interpreter-A record (verified against
; the ROM's own handler table, exactly one interpreter's implied-length rule fits).
Data_F05031:
	.byte 0x1B, 0x0A, 0x0D, 0x00, 0x4C, 0x00, 0xD2, 0x00, 0xC8, 0x00	; A op 1B, 10 bytes -> handler HTBL_A[0x1B]

; --------------------------------------------------------------------------
; 0xF0503B-0xF05062 -- 40 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F0503B appears as a 32-bit word at 0xF04FF9 0xF5D00F;
;               converted code at 0xF5D00E loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 12% printable ASCII; a linear decode runs 20 instructions and ends
;           `db`, with 65% of the bytes in spellings llvm-mc will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBoxes_F0503B -- 0xF0503B-0xF05062, 5 entries of four words, left / top /
;   right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF04FF2 ((0x27A3)
;   AND 0x0F >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`).  Entry count: the distance to the
;   object's end over the width; the masks admit 16.
; --------------------------------------------------------------------------
DLBoxes_F0503B:
	.short	13, 76, 210, 104	; F0503B  [0]
	.short	13, 76, 210, 104	; F05043  [1]
	.short	13, 108, 210, 136	; F0504B  [2]
	.short	13, 140, 210, 168	; F05053  [3]
	.short	13, 172, 210, 200	; F0505B  [4]

; === END COVER-R1 0xF04FFD-0xF05063 ===

; ------------------------------------------------------------------
; 0xF05063-0xF0509A -- 4 display-list records, 56 bytes -- interpreter B
;   entered at: 0xF05063
;   ends used:  0xF0509B
; ------------------------------------------------------------------
SoundEditFilterKeyFollow_PaintKeyboardAndValues_DL:
; drawn (start operand) by SoundEditFilterKeyFollow_PaintKeyboardAndValues -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number_signed	var=ModelingPage_Fields+3, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=88, y=221, digits=2, signflag=0x00
	dlb_string	var=ModelingPage_Fields+1, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_NoteNamesCm2ToG8, width=3, x=128, y=221
	dlb_string	var=ModelingPage_Fields, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_NoteNamesCm2ToG8, width=3, x=168, y=221
	dlb_string	var=ModelingPage_Fields+2, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_NoteNamesCm2ToG8, width=3, x=208, y=221

; === COVER-R1 0xF0509B-0xF050AB ===
; 0xF0509B-0xF050AA, coverage round 1: 16 of this span's 16 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 16 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF0509B-0xF050AA -- 16 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F0509B appears as a 32-bit word at 0xF5C795 0xF5D061;
;               converted code at 0xF5C794 0xF5D060 loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 44% printable ASCII; a linear decode runs 8 instructions and ends
;           `ld (0x00),0x00`, with 44% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the readers below fix what the object is (notes/promb-2026-09-25/
;   dl_pointer_tables.py).  The rest of this span is unreachable and stays
;   `.incbin`.  Why this is data and not code: THE PROVENANCE SPLIT in
;   notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLRecordPtrs_F0509B -- 0xF0509B-0xF050AA, 4 32-bit pointers, each to the
;   first byte of a display-list record (op 02 len 15, op 05 len 11).  Read
;   by: `ld XIY,this / call RunDisplayListBFromPointerArray` at 0xF5D060: ONE
;   interpreter-B record from entry A.  Its address is also used as a list
;   end: `ld XIY,0xF05063 / ld XIX,this / call T_DisplayListB_Run` at
;   0xF5C794: the END of the list that starts at 0xF05063.  Entry count: the
;   object's extent over 4; every word is a record start
;   (notes/promb-2026-09-25/dl_pointer_tables.py).
; --------------------------------------------------------------------------
DLRecordPtrs_F0509B:
	.long	SoundEditFilterKeyFollow_PaintKeyboardAndValues_DL + 0x1A	; F0509B  [0]
	.long	SoundEditFilterKeyFollow_PaintKeyboardAndValues_DL + 0xB	; F0509F  [1]
	.long	SoundEditFilterKeyFollow_PaintKeyboardAndValues_DL + 0x29	; F050A3  [2]
	.long	SoundEditFilterKeyFollow_PaintKeyboardAndValues_DL	; F050A7  [3]

; === END COVER-R1 0xF0509B-0xF050AB ===

; ------------------------------------------------------------------
; 0xF050AB-0xF050F0 -- 7 display-list records, 70 bytes -- interpreter B
;   entered at: 0xF050AB
;   ends used:  0xF050F1
; ------------------------------------------------------------------
SoundEditAmpEnvelope1_Paint_DL1:
; ; drawn (start operand) by SoundEditAmpEnvelope1_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number	var=ModelingPage_Fields, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=8, y=220, digits=3
	dlb_number	var=ModelingPage_Fields+1, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=40, y=220, digits=3
	dlb_number	var=ModelingPage_Fields+2, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=80, y=220, digits=3
	dlb_number	var=ModelingPage_Fields+3, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=120, y=220, digits=3
	dlb_number	var=ModelingPage_Fields+4, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=160, y=220, digits=3
	dlb_number	var=ModelingPage_Fields+5, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=200, y=220, digits=3
	dlb_number	var=ModelingPage_Fields+6, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=248, y=220, digits=3

; === COVER-R1 0xF050F1-0xF0510D ===
; 0xF050F1-0xF0510C, coverage round 1: 17 of this span's 28 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 17 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F050F1 -- 17 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F050F1 appears as a 32-bit word at 0xF5C806 0xF5D072;
;               converted code at 0xF5C805 0xF5D071 loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 24% printable ASCII; a linear decode runs 8 instructions and ends
;           `jp ULE,0x00`, with 29% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F050F1:
	.byte	0xAB, 0x50, 0xF0, 0x00, 0xB5, 0x50, 0xF0, 0x00, 0xBF, 0x50, 0xF0, 0x00, 0xC9, 0x50, 0xF0, 0x00	; F050F1  |.P...P...P...P..|
	.byte	0xD3	; F05101  |.|

; --- 0xF05102-0xF0510C, 11 B, converted by lane promB6 (PTRTAB4).
;     7-entry pointer array
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x50, 0xF0, 0x00	; F05102  top 3 bytes of the entry at F05101 = 0x00F050D3
	.long	SoundEditAmpEnvelope1_Paint_DL1 + 0x32	; F05105  entry 5
	.long	SoundEditAmpEnvelope1_Paint_DL1 + 0x3C	; F05109  entry 6

; === END COVER-R1 0xF050F1-0xF0510D ===

; ------------------------------------------------------------------
; 0xF0510D-0xF05181 -- 9 display-list records, 117 bytes -- interpreter B
;   entered at: 0xF0510D
;   ends used:  0xF05182
; ------------------------------------------------------------------
Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk_DL2:
; ; drawn (start operand) by Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number_signed	var=ModelingPage_Fields, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=240, y=221, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=288, y=221, digits=2, signflag=0x00
	dlb_string	var=ModelingPage_Fields+2, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_NoteNamesCm2ToG8, width=3, x=160, y=221
	dlb_string	var=ModelingPage_Fields+3, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_NoteNamesCm2ToG8, width=3, x=120, y=221
	dlb_string	var=ModelingPage_Fields+4, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_NoteNamesCm2ToG8, width=3, x=200, y=221
	dlb_number_signed	var=ModelingPage_Fields+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=8, y=221, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+6, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=48, y=221, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=80, y=221, digits=2, signflag=0x00
	dlb_string_xy	var=ModelingPage_Fields+9, mask=0x03, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_AttackDecayRelease, width=8, x=157, y=62

; === COVER-R1 0xF05182-0xF051C2 ===
; 0xF05182-0xF051C1, coverage round 1: 64 of this span's 64 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 64 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF05182-0xF051C1 -- 64 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F05182 appears as a 32-bit word at 0xF05178 0xF32BF8
;               0xF5C8C2; converted code at 0xF5C8C1 loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 66% printable ASCII; a linear decode runs 29 instructions and ends
;           `ld (0x00),0x00`, with 38% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLText_AttackDecayRelease -- 0xF05182-0xF05199, 3 entries of 8 bytes, text
;   drawn by LCD_Svc_17_DrawText8x8Packed.  Read by the interpreter-B
;   op-0x07 records at 0xF05171 ((0x27AF) AND 0x03 >> 0), 0xF32BF1 ((0x27AF)
;   AND 0x03 >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_StringTable2 draws entry
;   [value] with +0x0B = 8 as the width.  Entry count: the text: entry 3
;   would hold 0x00 bytes, as does every slot after it; the masks admit 4.
;   This address is also the END of a display list: `ld XIY,0xF0510D / ld
;   XIX,this / call T_DisplayListB_Run` at 0xF5C8C1.
; --------------------------------------------------------------------------
DLText_AttackDecayRelease:
	.ascii	"ATTACK) "	; F05182  [0]
	.ascii	"DECAY)  "	; F0518A  [1]
	.ascii	"RELEASE)"	; F05192  [2]
; --------------------------------------------------------------------------
; DLBRecordPtrs_F0519A -- 0xF0519A-0xF051C1, 10 32-bit pointers, each to the
;   first byte of an interpreter-B record.  Read by
;   RunDisplayListBFromPointerArray (0xF09AE1: `sla 2,WA / add XIY,XWA / ld
;   XIY,(XIY)`, then ONE record is run) with XIY = this address at 0xF5D0A4.
;   Entry count: the distance to the object's end over 4 -- the reader
;   indexes by A and does not bound it.
; --------------------------------------------------------------------------
DLBRecordPtrs_F0519A:
	.long	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk_DL2	; F0519A  [0]
	.long	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk_DL2 + 0xB	; F0519E  [1]
	.long	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk_DL2 + 0x16	; F051A2  [2]
	.long	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk_DL2 + 0x25	; F051A6  [3]
	.long	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk_DL2 + 0x34	; F051AA  [4]
	.long	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk_DL2 + 0x43	; F051AE  [5]
	.long	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk_DL2 + 0x4E	; F051B2  [6]
	.long	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk_DL2 + 0x59	; F051B6  [7]
	.long	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk_DL2 + 0x64	; F051BA  [8]
	.long	Draw_Page22KeyFollowEnvelopeKeyFollowTouchAtk_DL2 + 0x64	; F051BE  [9]

; === END COVER-R1 0xF05182-0xF051C2 ===

; ------------------------------------------------------------------
; 0xF051C2-0xF05285 -- 16 display-list records, 196 bytes -- interpreter B
;   entered at: 0xF051C2
;   ends used:  0xF05286
; ------------------------------------------------------------------
Draw_KeyDeToneKeyScalingShift_DL:
; ; drawn (start operand) by Draw_KeyDeToneKeyScalingShift -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number_signed	var=ModelingPage_Fields+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=48, y=85, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+2, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=80, y=85, digits=3, signflag=0x00
	dlb_string	var=ModelingPage_Fields+3, mask=0x07, shift=0, svc=LCDSVC_DrawText8x10, table=Data_F05286 + 0x78, width=4, x=128, y=85
	dlb_number_signed	var=ModelingPage_Fields+4, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=48, y=117, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+5, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=80, y=117, digits=3, signflag=0x00
	dlb_string	var=ModelingPage_Fields+6, mask=0x07, shift=0, svc=LCDSVC_DrawText8x10, table=Data_F05286 + 0x78, width=4, x=128, y=117
	dlb_number_signed	var=ModelingPage_Fields+7, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=48, y=149, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+8, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=80, y=149, digits=3, signflag=0x00
	dlb_string	var=ModelingPage_Fields+9, mask=0x07, shift=0, svc=LCDSVC_DrawText8x10, table=Data_F05286 + 0x78, width=4, x=128, y=149
	dlb_number_signed	var=ModelingPage_Fields+10, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=48, y=181, digits=2, signflag=0x00
	dlb_number_signed	var=ModelingPage_Fields+11, mask=0xff, shift=0, svc=LCDSVC_DrawText8x10, x=80, y=181, digits=3, signflag=0x00
	dlb_string	var=ModelingPage_Fields+12, mask=0x07, shift=0, svc=LCDSVC_DrawText8x10, table=Data_F05286 + 0x78, width=4, x=128, y=181
	dlb_string	var=ModelingPage_Fields+16, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x10, table=Data_F05286, width=8, x=184, y=149
	dlb_number_signed	var=ModelingPage_Fields+15, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x10, x=208, y=189, digits=1, signflag=0x08
	dlb_rect_entry	var=ModelingPage_Fields, mask=0x07, shift=0, svc=LCDSVC_FillRect, table=Data_F05286 + 0x98
	dlb_rect_entry	var=ModelingPage_Fields+13, mask=0x0f, shift=0, svc=LCDSVC_FillRect, table=Data_F05286 + 0xC0

; === COVER-R1 0xF05286-0xF0535E ===
; 0xF05286-0xF0535D, coverage round 1: 197 of this span's 216 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 197 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F05286 -- 197 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F05286 appears as a 32-bit word at 0xF0525D 0xF5C4F6;
;               converted code at 0xF5C4F5 loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 80% printable ASCII; a linear decode runs 92 instructions and ends
;           `swi 1`, with 18% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F05286:
	.byte	0x4F, 0x46, 0x46, 0x20, 0x20, 0x20, 0x20, 0x20, 0x52, 0x41, 0x4E, 0x44, 0x4F, 0x4D, 0x20, 0x20	; F05286  |OFF     RANDOM  |
	.byte	0x50, 0x49, 0x41, 0x4E, 0x4F, 0x20, 0x20, 0x20, 0x4F, 0x52, 0x43, 0x48, 0x45, 0x53, 0x54, 0x52	; F05296  |PIANO   ORCHESTR|
	.byte	0x50, 0x48, 0x59, 0x54, 0x48, 0x41, 0x47, 0x4F, 0x57, 0x45, 0x52, 0x43, 0x4B, 0x4D, 0x45, 0x49	; F052A6  |PHYTHAGOWERCKMEI|
	.byte	0x4B, 0x49, 0x52, 0x4E, 0x42, 0x45, 0x52, 0x47, 0x41, 0x52, 0x41, 0x42, 0x49, 0x43, 0x31, 0x20	; F052B6  |KIRNBERGARABIC1 |
	.byte	0x41, 0x52, 0x41, 0x42, 0x49, 0x43, 0x32, 0x20, 0x41, 0x52, 0x41, 0x42, 0x49, 0x43, 0x33, 0x20	; F052C6  |ARABIC2 ARABIC3 |
	.byte	0x41, 0x52, 0x41, 0x42, 0x49, 0x43, 0x34, 0x20, 0x41, 0x52, 0x41, 0x42, 0x49, 0x43, 0x35, 0x20	; F052D6  |ARABIC4 ARABIC5 |
	.byte	0x53, 0x4C, 0x45, 0x4E, 0x44, 0x52, 0x4F, 0x20, 0x50, 0x45, 0x4C, 0x4F, 0x47, 0x20, 0x20, 0x20	; F052E6  |SLENDRO PELOG   |
	.byte	0x55, 0x53, 0x45, 0x52, 0x20, 0x20, 0x20, 0x20, 0x4E, 0x4F, 0x52, 0x4D, 0x20, 0x31, 0x2F, 0x32	; F052F6  |USER    NORM 1/2|
	.byte	0x20, 0x31, 0x2F, 0x34, 0x20, 0x31, 0x2F, 0x38, 0x31, 0x2F, 0x31, 0x36, 0x31, 0x2F, 0x33, 0x32	; F05306  | 1/4 1/81/161/32|
	.byte	0x31, 0x2F, 0x36, 0x34, 0x20, 0x46, 0x49, 0x58, 0x0D, 0x00, 0x4C, 0x00, 0xA6, 0x00, 0x68, 0x00	; F05316  |1/64 FIX..L...h.|
	.byte	0x0D, 0x00, 0x4C, 0x00, 0xA6, 0x00, 0x68, 0x00, 0x0D, 0x00, 0x6C, 0x00, 0xA6, 0x00, 0x88, 0x00	; F05326  |..L...h...l.....|
	.byte	0x0D, 0x00, 0x8C, 0x00, 0xA6, 0x00, 0xA8, 0x00, 0x0D, 0x00, 0xAC, 0x00, 0xA6, 0x00, 0xC8, 0x00	; F05336  |................|
	.byte	0xB5, 0x00, 0x43, 0x00, 0xF9	; F05346  |..C..|

; --- 0xF0534B-0xF0535D, 19 B, converted by lane promB6 (SHORTARR8).
;     the array 0xF0531E declared by a display-list record's `+0x07 -> XIX`
;     field
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x00, 0x50, 0x00	; F0534B  rest of the 8-byte entry at F05346
	.short	0x00B5, 0x0093, 0x00F9, 0x00A0	; F0534E  entry 6
	.short	0x00B5, 0x00BB, 0x00F9, 0x00C8	; F05356  entry 7

; === END COVER-R1 0xF05286-0xF0535E ===

; ------------------------------------------------------------------
; 0xF0535E-0xF05371 -- 2 display-list records, 20 bytes -- interpreter A
;   entered at: 0xF0535E, 0xF05368
;   ends used:  0xF05368, 0xF05372
; ------------------------------------------------------------------
SoundEditPitchTune_RepaintField_DL1:
; ; drawn (start operand) by SoundEditPitchTune_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=13, y0=76, x1=166, y1=200
SoundEditPitchTune_RepaintField_DL2:
; ; drawn (start operand) by SoundEditPitchTune_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=181, y0=67, x1=249, y1=200

; === COVER-R1 0xF05372-0xF053B6 ===
; 0xF05372-0xF053B5, coverage round 1: 13 of this span's 68 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 13 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F05372 -- 13 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F05372 appears as a 32-bit word at 0xF5CEDD 0xF5CEED;
;               converted code at 0xF5CEDC 0xF5CEEC loads it as a 32-bit
;               immediate.  No routine-directory slot and no branch decoded in
;               converted code names it.
; Measured: 31% printable ASCII; a linear decode runs 5 instructions and ends
;           `jp T,0x00`, with 8% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F05372:
	.byte	0x70, 0x52, 0xF0, 0x00, 0xC2, 0x51, 0xF0, 0x00, 0xCD, 0x51, 0xF0, 0x00, 0xD8	; F05372  |pR...Q...Q...|

; --- 0xF0537F-0xF053B5, 55 B, converted by lane promB6 (PTRTAB4).
;     17-entry pointer array
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x51, 0xF0, 0x00	; F0537F  top 3 bytes of the entry at F0537E = 0x00F051D8
	.long	Draw_KeyDeToneKeyScalingShift_DL + 0x25	; F05382  entry 4
	.long	Draw_KeyDeToneKeyScalingShift_DL + 0x30	; F05386  entry 5
	.long	Draw_KeyDeToneKeyScalingShift_DL + 0x3B	; F0538A  entry 6
	.long	Draw_KeyDeToneKeyScalingShift_DL + 0x4A	; F0538E  entry 7
	.long	Draw_KeyDeToneKeyScalingShift_DL + 0x55	; F05392  entry 8
	.long	Draw_KeyDeToneKeyScalingShift_DL + 0x60	; F05396  entry 9
	.long	Draw_KeyDeToneKeyScalingShift_DL + 0x6F	; F0539A  entry 10
	.long	Draw_KeyDeToneKeyScalingShift_DL + 0x7A	; F0539E  entry 11
	.long	Draw_KeyDeToneKeyScalingShift_DL + 0x85	; F053A2  entry 12
	.long	Draw_KeyDeToneKeyScalingShift_DL + 0xB9	; F053A6  entry 13
	.long	Draw_KeyDeToneKeyScalingShift_DL + 0x94	; F053AA  entry 14
	.long	Draw_KeyDeToneKeyScalingShift_DL + 0xA3	; F053AE  entry 15
	.long	Draw_KeyDeToneKeyScalingShift_DL + 0x94	; F053B2  entry 16

; === END COVER-R1 0xF05372-0xF053B6 ===

; ------------------------------------------------------------------
; 0xF053B6-0xF05406 -- 7 display-list records, 81 bytes -- interpreter B
;   entered at: 0xF053B6, 0xF053E3
;   ends used:  0xF053CF, 0xF053FC, 0xF05407
; ------------------------------------------------------------------
DL_F053B6:
	dlb_string	var=ModelingPage_Fields+4, mask=0xc0, shift=6, svc=LCDSVC_DrawText8x10, table=DLText_SinTriSqrSaw, width=3, x=96, y=221
	dlb_number	var=ModelingPage_Fields+4, mask=0x1f, shift=0, svc=LCDSVC_DrawText8x10, x=128, y=221, digits=3
	dlb_number	var=ModelingPage_Fields+2, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=168, y=221, digits=3
	dlb_number	var=ModelingPage_Fields+1, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=200, y=221, digits=3
SoundEditLfo_RepaintField_DL2:
; ; drawn (start operand) by SoundEditLfo_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number	var=ModelingPage_Fields+3, mask=0x3f, shift=0, svc=LCDSVC_DrawText8x10, x=240, y=221, digits=2
	dlb_string	var=ModelingPage_Fields+3, mask=0x80, shift=7, svc=LCDSVC_DrawText8x10, table=DLText_OffOn, width=3, x=280, y=221
	dlb_rect_entry	var=ModelingPage_Fields, mask=0x07, shift=0, svc=LCDSVC_FillRect, table=DLBoxes_F05475

; === COVER-R1 0xF05407-0xF0549D ===
; 0xF05407-0xF0549C, coverage round 1: 58 of this span's 150 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 58 as DATA (only
; a `.long` or a 32-bit immediate names it) in 4 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice
; ⚠ CORRECTED 2026-09-02 (lane res05x): the sentence above is no
;   longer true of this span -- 150 of 150 bytes are real source now, and no
;   `.incbin` remains between these markers.  What round 1 measured was
;   REACHABILITY, which finds an object's first byte and never its last;
;   the extents below come from the code that RUNS these records.

; ------------------------------------------------------------------
; 0xF05407-0xF05444 -- four interpreter-B op-02 records of 15 bytes and
; the 2-entry string table all four of them point at.
; THE RECORD STARTS ARE WRITTEN DOWN 79 BYTES LATER: the 4-entry pointer
; array at 0xF0545A holds 0x00F05407 0x00F05416 0x00F05425 0x00F05434.
; The reader at 0xF5C53A/0xF5CF85 runs the list 0xF053B6..0xF05407, so
; 0xF05407 is also the first byte after a display list; and the last
; record's own +0x07 pointer, 0x00F05443, names the first byte after
; itself.  Evidence: python3 notes/prom_b_res05x_spans.py --selftest
;
; Provenance kept from the superseded framing:
;   Data_F05407 -- reached from: 0x00F05407 appears as a 32-bit word at
;     0xF05459 0xF5C540 0xF5CF8B; converted code at 0xF5C53F 0xF5CF8A
;     loads it as a 32-bit immediate.  It was emitted as 4 bytes; those
;     4 bytes were the head of the first record.
; ------------------------------------------------------------------
DL_F05407:
Data_F05407:
	dlb_string	var=ModelingPage_Fields+5, mask=0x10, shift=4, svc=LCDSVC_DrawText8x10, table=DLTable_F05443, width=1, x=80, y=65
DL_F05416:
	dlb_string	var=ModelingPage_Fields+6, mask=0x10, shift=4, svc=LCDSVC_DrawText8x10, table=DLTable_F05443, width=1, x=80, y=96
DL_F05425:
	dlb_string	var=ModelingPage_Fields+7, mask=0x10, shift=4, svc=LCDSVC_DrawText8x10, table=DLTable_F05443, width=1, x=80, y=127
DL_F05434:
	dlb_string	var=ModelingPage_Fields+8, mask=0x10, shift=4, svc=LCDSVC_DrawText8x10, table=DLTable_F05443, width=1, x=80, y=158
DLTable_F05443:	; 2 entries of 1 byte -- the sign shown for the value
;   Referenced by: all four records above (+0x07 = 0x00F05443, +0x0B = 1).
;   Exactly two entries: mask 0x10 at +0x04 with shift 4 at +0x05 can
;   only ever produce index 0 or 1.
	.ascii "+"	; [0]
	.ascii "-"	; [1]

; --------------------------------------------------------------------------
; Data_F05445 -- 1 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F05445 appears as a 32-bit word at 0xF5CF9B; converted
;               code at 0xF5CF9A loads it as a 32-bit immediate.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 0% printable ASCII; a linear decode runs 1 instructions and ends
;           `swi 4`, with 0% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F05445:
	.byte	0xFC	; F05445  |.|

; --- 0xF05446-0xF05458, 19 B, converted by lane promB6 (PTRTAB4).
;     5-entry pointer array
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x53, 0xF0, 0x00	; F05446  top 3 bytes of the entry at F05445 = 0x00F053FC
	.long	DL_F053B6 + 0x23	; F05449  entry 1
	.long	DL_F053B6 + 0x19	; F0544D  entry 2
	.long	SoundEditLfo_RepaintField_DL2	; F05451  entry 3
	.long	DL_F053B6	; F05455  entry 4

; --------------------------------------------------------------------------
; Data_F05459 -- 1 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F05459 appears as a 32-bit word at 0xF5C67F; converted
;               code at 0xF5C67E loads it as a 32-bit immediate.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 0% printable ASCII; a linear decode runs 1 instructions and ends
;           `reti`, with 0% of the bytes in spellings llvm-mc will not encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F05459:
	.byte	0x07	; F05459  |.|

; --- 0xF0545A-0xF05468, 15 B, converted by lane promB6 (PTRTAB4).
;     4-entry pointer array
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x54, 0xF0, 0x00	; F0545A  top 3 bytes of the entry at F05459 = 0x00F05407
	.long	DL_F05416	; F0545D  entry 1
	.long	DL_F05425	; F05461  entry 2
	.long	DL_F05434	; F05465  entry 3

; --------------------------------------------------------------------------
; 0xF05469-0xF0549C -- 52 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F05469 appears as a 32-bit word at 0xF053BD.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 37% printable ASCII; a linear decode runs 32 instructions and ends
;           `db`, with 44% of the bytes in spellings llvm-mc will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLText_SinTriSqrSaw -- 0xF05469-0xF05474, 4 entries of 3 bytes, text drawn
;   by LCD_Svc_20_DrawText8x10.  Read by the interpreter-B op-0x02 record at
;   0xF053B6 ((0x27AA) AND 0xC0 >> 6) -- value = (byte at the +2 address)
;   AND mask >> shift -- whose +0x07 names this address;
;   DLB_Handler_StringTable draws entry [value] with +0x0B = 3 as the width.
;   Entry count: the distance to the next table over the width; the masks
;   admit 4.
; --------------------------------------------------------------------------
DLText_SinTriSqrSaw:
	.ascii	"SIN"	; F05469  [0]
	.ascii	"TRI"	; F0546C  [1]
	.ascii	"SQR"	; F0546F  [2]
	.ascii	"SAW"	; F05472  [3]
; --------------------------------------------------------------------------
; DLBoxes_F05475 -- 0xF05475-0xF0549C, 5 entries of four words, left / top /
;   right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 record at 0xF053FC ((0x27A6)
;   AND 0x07 >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`).  Entry count: the distance to the
;   object's end over the width; the masks admit 8.
; --------------------------------------------------------------------------
DLBoxes_F05475:
	.short	182, 62, 218, 75	; F05475  [0]
	.short	182, 62, 218, 75	; F0547D  [1]
	.short	182, 94, 218, 107	; F05485  [2]
	.short	182, 124, 218, 137	; F0548D  [3]
	.short	182, 156, 218, 169	; F05495  [4]

; === END COVER-R1 0xF05407-0xF0549D ===

; ------------------------------------------------------------------
; 0xF0549D-0xF054B0 -- 2 display-list records, 20 bytes -- interpreter A
;   entered at: 0xF0549D, 0xF054A7
;   ends used:  0xF054A7, 0xF054B1
; ------------------------------------------------------------------
SoundEditLfo_RepaintField_DL1:
; ; drawn (start operand) by SoundEditLfo_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=182, y0=62, x1=218, y1=169
SoundEditLfo_DrawRowLinks_DL1:
; drawn (start operand) by SoundEditLfo_DrawRowLinks -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=46, y0=62, x1=74, y1=169

; === COVER-R1 0xF054B1-0xF054ED ===
; 0xF054B1-0xF054EC, coverage round 1: 18 of this span's 60 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 18 as DATA (only
; a `.long` or a 32-bit immediate names it) in 2 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice


; ------------------------------------------------------------------
; 0xF054B1-0xF054D8 -- 4 display-list records, 40 bytes -- interpreter A
; Formerly Data_F054B1 -- that was the LEADING BYTES of this list, not a
; separate object.  Zero-drift walk, notes/gen_prom_b_oversized_round4_module.py
; ------------------------------------------------------------------
DL_F054B1:
	dl_fill_rect	x0=46, y0=62, x1=74, y1=75
	dl_fill_rect	x0=46, y0=93, x1=74, y1=106
	dl_fill_rect	x0=46, y0=124, x1=74, y1=137
	dl_fill_rect	x0=46, y0=156, x1=74, y1=169

; --------------------------------------------------------------------------
; Data_F054D9 -- 17 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F054D9 appears as a 32-bit word at 0xF054E9 0xF5C60C;
;               converted code at 0xF5C60B loads it as a 32-bit immediate.  No
;               routine-directory slot and no branch decoded in converted code
;               names it.
; Measured: 24% printable ASCII; a linear decode runs 8 instructions and ends
;           `jp GE,0x00`, with 18% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F054D9:
	.byte	0xB1, 0x54, 0xF0, 0x00, 0xBB, 0x54, 0xF0, 0x00, 0xC5, 0x54, 0xF0, 0x00, 0xCF, 0x54, 0xF0, 0x00	; F054D9  |.T...T...T...T..|
	.byte	0xD9	; F054E9  |.|

; --- 0xF054EA-0xF054EC, 3 B, converted by lane promB6 (PTRTAB4).
;     5-entry pointer array
;     Evidence checked by scripts/analysis/prom_b_small_span_convert.py --check
	.byte	0x54, 0xF0, 0x00	; F054EA  top 3 bytes of the entry at F054E9 = 0x00F054D9

; === END COVER-R1 0xF054B1-0xF054ED ===

; ------------------------------------------------------------------
; 0xF054ED-0xF0550A -- 3 display-list records, 30 bytes -- interpreter A
;   entered at: 0xF054ED, 0xF054F7, 0xF05501
;   ends used:  0xF054F7, 0xF05501, 0xF0550B
; ------------------------------------------------------------------
SoundEditLfo_DrawField0RowLine_DL:
; drawn (start operand) by SoundEditLfo_DrawField0RowLine -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=221, y0=68, x1=237, y1=203
SoundEditLfo_DrawRowLinks_DL2:
; drawn (start operand) by SoundEditLfo_DrawRowLinks -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=89, y0=67, x1=179, y1=166
SoundEditLfo_DrawRowLinks_DL3:
; drawn (start operand) by SoundEditLfo_DrawRowLinks -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=77, y0=65, x1=88, y1=167

; === COVER-R1 0xF0550B-0xF0564B ===
; 0xF0550B-0xF0564A, coverage round 1: 294 of this span's 320 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 294 as DATA (only
; a `.long` or a 32-bit immediate names it) in 2 runs.  Everything else here
; is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F0550B -- 276 bytes, EMITTED AS DATA (not promoted to code).
; ⚠ CORRECTED: was declared 278 bytes, 2 bytes too many -- see
; notes/gen_prom_b_f05621_fix_module.py.  Those 2 bytes (0x17, 0x07) were
; the op/len header of the display-list record run that starts at 0xF0561F,
; below, exposed by DLRecordPtrs_F0563B's own pointer array naming that address.
; Reached from: 0x00F0550B appears as a 32-bit word at 0xF0555B 0xF0555F
;               0xF5C5D1 0xF5C5E4; converted code at 0xF5C5D0 0xF5C5E3 loads
;               it as a 32-bit immediate.  No routine-directory slot and no
;               branch decoded in converted code names it.
; --------------------------------------------------------------------------
Data_F0550B:
	.byte	0x11, 0x0A, 0xDE, 0x00, 0x44, 0x00, 0xED, 0x00, 0x44, 0x00, 0x12, 0x0A, 0xED, 0x00, 0x44, 0x00	; F0550B  |....D...D.....D.|
	.byte	0xED, 0x00, 0xCB, 0x00, 0x11, 0x0A, 0xDE, 0x00, 0x64, 0x00, 0xED, 0x00, 0x64, 0x00, 0x12, 0x0A	; F0551B  |........d...d...|
	.byte	0xED, 0x00, 0x64, 0x00, 0xED, 0x00, 0xCB, 0x00, 0x11, 0x0A, 0xDE, 0x00, 0x82, 0x00, 0xED, 0x00	; F0552B  |..d.............|
	.byte	0x82, 0x00, 0x12, 0x0A, 0xED, 0x00, 0x82, 0x00, 0xED, 0x00, 0xCB, 0x00, 0x11, 0x0A, 0xDE, 0x00	; F0553B  |................|
	.byte	0xA2, 0x00, 0xED, 0x00, 0xA2, 0x00, 0x12, 0x0A, 0xED, 0x00, 0xA2, 0x00, 0xED, 0x00, 0xCB, 0x00	; F0554B  |................|
	.byte	0x0B, 0x55, 0xF0, 0x00, 0x0B, 0x55, 0xF0, 0x00, 0x1F, 0x55, 0xF0, 0x00, 0x33, 0x55, 0xF0, 0x00	; F0555B  |.U...U...U..3U..|
	.byte	0x47, 0x55, 0xF0, 0x00, 0x01, 0x0A, 0x5D, 0x00, 0x46, 0x00, 0xB4, 0x00, 0x46, 0x00, 0x00, 0x0A	; F0556B  |GU....].F...F...|
	.byte	0x5D, 0x00, 0x46, 0x00, 0xB4, 0x00, 0x65, 0x00, 0x00, 0x0A, 0x5D, 0x00, 0x46, 0x00, 0xB4, 0x00	; F0557B  |].F...e...].F...|
	.byte	0x84, 0x00, 0x00, 0x0A, 0x5D, 0x00, 0x46, 0x00, 0xB4, 0x00, 0xA3, 0x00, 0x00, 0x0A, 0x5D, 0x00	; F0558B  |....].F.......].|
	.byte	0x65, 0x00, 0xB4, 0x00, 0x46, 0x00, 0x01, 0x0A, 0x5D, 0x00, 0x65, 0x00, 0xB4, 0x00, 0x65, 0x00	; F0559B  |e...F...].e...e.|
	.byte	0x00, 0x0A, 0x5D, 0x00, 0x65, 0x00, 0xB4, 0x00, 0x84, 0x00, 0x00, 0x0A, 0x5D, 0x00, 0x65, 0x00	; F055AB  |..].e.......].e.|
	.byte	0xB4, 0x00, 0xA3, 0x00, 0x00, 0x0A, 0x5D, 0x00, 0x84, 0x00, 0xB4, 0x00, 0x46, 0x00, 0x00, 0x0A	; F055BB  |......].....F...|
	.byte	0x5D, 0x00, 0x84, 0x00, 0xB4, 0x00, 0x65, 0x00, 0x01, 0x0A, 0x5D, 0x00, 0x84, 0x00, 0xB4, 0x00	; F055CB  |].....e...].....|
	.byte	0x84, 0x00, 0x00, 0x0A, 0x5D, 0x00, 0x84, 0x00, 0xB4, 0x00, 0xA3, 0x00, 0x00, 0x0A, 0x5D, 0x00	; F055DB  |....].........].|
	.byte	0xA3, 0x00, 0xB4, 0x00, 0x46, 0x00, 0x00, 0x0A, 0x5D, 0x00, 0xA3, 0x00, 0xB4, 0x00, 0x65, 0x00	; F055EB  |....F...].....e.|
	.byte	0x00, 0x0A, 0x5D, 0x00, 0xA3, 0x00, 0xB4, 0x00, 0x84, 0x00, 0x01, 0x0A, 0x5D, 0x00, 0xA3, 0x00	; F055FB  |..].........]...|
	.byte	0xB4, 0x00, 0xA3, 0x00, 0x6F, 0x55, 0xF0, 0x00, 0x97, 0x55, 0xF0, 0x00, 0xBF, 0x55, 0xF0, 0x00	; F0560B  |....oU...U...U..|
	.byte	0xE7, 0x55, 0xF0, 0x00	; F0561B  |.U..|

; ------------------------------------------------------------------
; 0xF0561F-0xF0563A -- 4 display-list records, 28 bytes -- interpreter A
; The 4th of DLRecordPtrs_F0563B's own 4 pointers names 0xF0561F exactly; the other
; 3 are the record starts this lane's untouched-pool round already found.
; Formerly the last 2 bytes of Data_F0550B plus a 5-byte unexplained
; fragment.  Regenerate: python3 notes/gen_prom_b_f05621_fix_module.py
; --splice
; ------------------------------------------------------------------
	dl_text8x8_packed	x=88, y=67, text="\020"
	dl_text8x8_packed	x=88, y=98, text="\020"
	dl_text8x8_packed	x=88, y=129, text="\020"
	dl_text8x8_packed	x=88, y=160, text="\020"

; --------------------------------------------------------------------------
; 0xF0563B-0xF0564A -- 16 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F0563B appears as a 32-bit word at 0xF5C632; converted
;               code at 0xF5C631 loads it as a 32-bit immediate.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 44% printable ASCII; a linear decode runs 9 instructions and ends
;           `ld (0x00),0x00`, with 81% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the readers below fix what the object is (notes/promb-2026-09-25/
;   dl_pointer_tables.py).  The rest of this span is unreachable and stays
;   `.incbin`.  Why this is data and not code: THE PROVENANCE SPLIT in
;   notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLRecordPtrs_F0563B -- 0xF0563B-0xF0564A, 4 32-bit pointers, each to the
;   first byte of a display-list record (op 17 len 7).  Read by: `ld XIZ,this
;   / ld XIY,(XIZ+DE) / ld XIX,XIY / add XIX,7` then T_DisplayList_Run at
;   0xF5C631: entry k is ONE 7-byte list.  Entry count: the object's extent
;   over 4; every word is a record start
;   (notes/promb-2026-09-25/dl_pointer_tables.py).
; --------------------------------------------------------------------------
DLRecordPtrs_F0563B:
	.long	Data_F0550B + 0x114	; F0563B  [0]
	.long	Data_F0550B + 0x11B	; F0563F  [1]
	.long	Data_F0550B + 0x122	; F05643  [2]
	.long	Data_F0550B + 0x129	; F05647  [3]

; === END COVER-R1 0xF0550B-0xF0564B ===

; ------------------------------------------------------------------
; 0xF0564B-0xF0574C -- 28 display-list records, 258 bytes -- interpreter A
;   entered at: 0xF0564B
;   ends used:  0xF05740, 0xF0574D
; ------------------------------------------------------------------
; DL_Mem0ryWriteSoundEditName -- the display list at 0xF0564B.  Its own text
;                                records read: "MEM0RY WRITE"; "SOUND EDIT";
;                                "NAME:"; "MEMORY BANK:"; "SOUND NAMING";
;                                "USER".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Mem0ryWriteSoundEditName:
	dl_text16x16_packed	x=99, y=5, text="MEM0RY WRITE"
	dl_text8x8_packed	x=6, y=7, text="SOUND EDIT"
	dl_text8x16	x=0, y=34, text="\020"
	dl_text8x10	x=16, y=35, text="0K"
	dl_text8x16	x=56, y=73, text="NAME:"
	dl_text8x8_packed	x=310, y=109, text="\221"
	dl_text8x16	x=288, y=111, text="\215"
	dl_text8x16	x=312, y=113, text="\251"
	dl_text8x16	x=56, y=124, text="MEMORY BANK:"
	dl_text8x8_packed	x=310, y=148, text="\221"
	dl_text8x16	x=288, y=151, text="\216"
	dl_text8x16	x=312, y=152, text="\251"
	dl_text8x16	x=312, y=190, text="\021"
	dl_text8x16	x=192, y=191, text="SOUND NAMING"
	dl_box	x0=4, y0=4, x1=68, y1=16
	dl_box	x0=11, y0=30, x1=37, y1=49
	dl_box	x0=13, y0=32, x1=35, y1=47
	dl_box_shadow1	x0=41, y0=60, x1=238, y1=172
	dl_box	x0=274, y0=108, x1=309, y1=127
	dl_box	x0=276, y0=110, x1=307, y1=125
	dl_box	x0=274, y0=147, x1=309, y1=166
	dl_box	x0=276, y0=149, x1=307, y1=164
	dl_box_shadow1	x0=177, y0=179, x1=304, y1=214
	dl_box	x0=247, y0=137, x1=266, y1=138
	dl_box	x0=266, y0=117, x1=267, y1=158
	dl_hline	x0=41, y0=114, x1=238, y1=114
	dl_text8x16	x=152, y=124, text="USER"
	dl_text8x16	x=192, y=124, text="-"

; === COVER-R1 0xF0574D-0xF057C0 ===
; 0xF0574D-0xF057BF, coverage round 1: 69 of this span's 115 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 69 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice
; ⚠ CORRECTED 2026-09-02 (lane res05x): the sentence above is no
;   longer true of this span -- 115 of 115 bytes are real source now, and no
;   `.incbin` remains between these markers.  What round 1 measured was
;   REACHABILITY, which finds an object's first byte and never its last;
;   the extents below come from the code that RUNS these records.

; ------------------------------------------------------------------
; 0xF0574D-0xF057BF -- two string tables, one display-list record and a
; 5x8 rectangle array.  115 bytes, tiled end to end between two
; addresses the READER names:
;   0xF5D15A  ld XIY,0x00F0564B ; ld XIX,0x00F0574D -> list ends here
;   0xF5D168  ld XIY,0x00F057C0                     -> next list starts
; 25*2 + 5*3 + 10 + 5*8 = 115 = 0xF057C0 - 0xF0574D, with no slack.
;
; THIS IS THE WEAKEST OF THIS LANE'S FIVE REGIONS and the comment says so
; on purpose: NOTHING in any of the four WSA1R ROMs holds 0xF0577F,
; 0xF0578E, 0xF05790 or 0xF05798 as a 32-bit word, so the three interior
; splits rest on tiling plus three agreements, not on a pointer:
;   * a 26th 2-byte letter slot would be "1s", splitting a word;
;   * the op-1B record's four words ARE the bounding box of the five
;     rectangles that follow it;
;   * five entries with [0] == [1] is what all three externally-sized
;     rectangle arrays in this ROM look like (0xF04CE8, 0xF05475,
;     DLTable_F031C9), and the ordinal table beside it is also five
;     entries with [0] == [1].
; The competing framing -- six rectangles from 0xF05790 -- also tiles,
; and is rejected because it makes [0] the bounding box and [1] == [2].
; Evidence and both framings: notes/prom_b_res05x_spans.py --selftest
;
; Provenance kept from the superseded framing:
;   Data_F0574D -- reached from: 0x00F0574D appears as a 32-bit word at
;     0xF338FD 0xF33925 0xF33957 0xF33989 0xF5D160; converted code at
;     0xF5D15F loads it as a 32-bit immediate.  (0xF338F6 is the
;     interpreter-B op-02 record whose +0x07 operand that is, with
;     +0x0B = 2 bytes per entry.)  It was emitted as 69 bytes, four more
;     than the table has: the extra four were the head of the 0xF0578E
;     record.
; ------------------------------------------------------------------
DLTable_F0574D:	; 25 entries of 2 bytes -- letter labels, T absent
;   Referenced by: display-list record 0xF338F6 (+0x0B = 2).  25 entries
;   is the EXTENT, not the (mask 0x3F >> 0) + 1 = 64 the record allows.
	.ascii "A:"	; [0]
	.ascii "B:"	; [1]
	.ascii "C:"	; [2]
	.ascii "D:"	; [3]
	.ascii "E:"	; [4]
	.ascii "F:"	; [5]
	.ascii "G:"	; [6]
	.ascii "H:"	; [7]
	.ascii "I:"	; [8]
	.ascii "J:"	; [9]
	.ascii "K:"	; [10]
	.ascii "L:"	; [11]
	.ascii "M:"	; [12]
	.ascii "N:"	; [13]
	.ascii "O:"	; [14]
	.ascii "P:"	; [15]
	.ascii "Q:"	; [16]
	.ascii "R:"	; [17]
	.ascii "S:"	; [18]
	.ascii "U:"	; [19]
	.ascii "V:"	; [20]
	.ascii "W:"	; [21]
	.ascii "X:"	; [22]
	.ascii "Y:"	; [23]
	.ascii "Z:"	; [24]
DLTable_F0577F:	; 5 entries of 3 bytes -- ordinals, [0] == [1]
;   Not named by any pointer in the four ROMs; framed by the tiling and
;   by being the parallel array of DLTable_F05798 below.
	.ascii "1st"	; [0]
	.ascii "1st"	; [1]
	.ascii "2nd"	; [2]
	.ascii "3rd"	; [3]
	.ascii "4th"	; [4]
DL_F0578E:	; one record, not named by any pointer in the four ROMs;
;   its four words are the bounding box of the five rectangles below.
	dl_erase_rect	x0=14, y0=77, x1=256, y1=201
DLTable_F05798:	; 5 entries of 8 bytes -- highlight rectangles (x1,y1,x2,y2)
;   Same shape as DLTable_F04CE8 one pixel over: x1/x2 constant, y
;   stepping 0x20, [0] == [1].
	.short 0x000E, 0x004D, 0x0100, 0x0069	; [0]
	.short 0x000E, 0x004D, 0x0100, 0x0069	; [1]
	.short 0x000E, 0x006D, 0x0100, 0x0089	; [2]
	.short 0x000E, 0x008D, 0x0100, 0x00A9	; [3]
	.short 0x000E, 0x00AD, 0x0100, 0x00C9	; [4]

; === END COVER-R1 0xF0574D-0xF057C0 ===

; ------------------------------------------------------------------
; 0xF057C0-0xF05800 -- 5 display-list records, 65 bytes -- interpreter B
;   entered at: 0xF057C0, 0xF057E3
;   ends used:  0xF057E3, 0xF05801
; ------------------------------------------------------------------
DL_F057C0:
	dlb_number	var=ModelingPage_Fields, mask=0x03, shift=0, svc=LCDSVC_DrawText8x16, x=184, y=124, digits=1
	dlb_number	var=ModelingPage_Fields+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, x=200, y=124, digits=3
	dlb_string	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, table=DiskSave_PasswordEntry, width=16, x=72, y=92
; DL_MemoryBank -- the display list at 0xF057E3, named by mechanism M3 of
;                  notes/prom_b_dl_screens_round5.py.  "MEMORY BANK:" ends at
;                  0x1373
; Evidence: this list has no text of its own.  Each of its interpreter-B
;           records prints at a screen position that is EXACTLY where a
;           caption of another list on the same screen stops writing (caption
;           `+2` word plus `length - 4` characters), so the value goes in that
;           caption's field.  The captions are quoted above with the position
;           they end on; the screen is the set of lists run by the SAME
;           routine, per notes/prom_b_dl_call_shapes.py.  Generated by
;           notes/prom_b_dl_screens_round5.py --apply.
DL_MemoryBank:
	dlb_string	var=ModelingPage_Fields+1, mask=0xff, shift=0, svc=LCDSVC_DrawText8x16, table=DLText_UserDrumKits, width=9, x=152, y=124
	dlb_string	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText8x16, table=DiskSave_PasswordEntry, width=16, x=72, y=92

; === COVER-R1 0xF05801-0xF0582E ===
; 0xF05801-0xF0582D, coverage round 1: 45 of this span's 45 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 45 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF05801-0xF0582D -- 45 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F05801 appears as a 32-bit word at 0xF057EA 0xF5D18C
;               0xF5D306; converted code at 0xF5D18B 0xF5D305 loads it as a
;               32-bit immediate.  No routine-directory slot and no branch
;               decoded in converted code names it.
; Measured: 100% printable ASCII; a linear decode runs 27 instructions and
;           ends `ld DE,0x0000`, with 18% of the bytes in spellings llvm-mc
;           will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLText_UserDrumKits -- 0xF05801-0xF0582D, 5 entries of 9 bytes, text drawn
;   by LCD_Svc_07_DrawText8x16.  Read by the interpreter-B op-0x02 record at
;   0xF057E3 ((0x27A7) AND 0xFF >> 0) -- value = (byte at the +2 address)
;   AND mask >> shift -- whose +0x07 names this address;
;   DLB_Handler_StringTable draws entry [value] with +0x0B = 9 as the width.
;   Entry count: the distance to the object's end over the width; the masks
;   admit 256.  This address is also the END of a display list: `ld
;   XIY,0xF057E3 / ld XIX,this / call T_DisplayListB_Run` at 0xF5D18B; `ld
;   XIY,0xF057E3 / ld XIX,this / call T_DisplayListB_Run` at 0xF5D305.
; --------------------------------------------------------------------------
DLText_UserDrumKits:
	.ascii	"USR1DRM-1"	; F05801  [0]
	.ascii	"USR1DRM-1"	; F0580A  [1]
	.ascii	"USR1DRM-2"	; F05813  [2]
	.ascii	"USR2DRM-1"	; F0581C  [3]
	.ascii	"USR2DRM-2"	; F05825  [4]

; === END COVER-R1 0xF05801-0xF0582E ===

; ------------------------------------------------------------------
; 0xF0582E-0xF05AB3 -- 51 display-list records, 646 bytes -- interpreter A (45 records) and B (6)
;   entered at: 0xF0582E, 0xF05850, 0xF0587C, 0xF05A2E, 0xF05A38, 0xF05A42, 0xF05A4C, 0xF05A68, 0xF05A84, 0xF05AA0, 0xF05AAA
;   ends used:  0xF05850, 0xF05A2E, 0xF05A38, 0xF05A42, 0xF05A4C, 0xF05A68, 0xF05A84, 0xF05AA0, 0xF05AB4
; ------------------------------------------------------------------
; DL_Write -- the display list at 0xF0582E.  Its own text records read:
;             "WRITE".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Write:
	dl_text8x16	x=0, y=34, text="\020"
	dl_text8x14	x=16, y=35, text="WRITE"
	dl_box	x0=12, y0=30, x1=60, y1=49
	dl_box	x0=14, y0=32, x1=58, y1=47
; DL_SoundEditS0undNaming -- the display list at 0xF05850.  Its own text
;                            records read: "SOUND EDIT"; "S0UND NAMING".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_SoundEditS0undNaming:
	dl_text8x8_packed	x=6, y=7, text="SOUND EDIT"
	dl_text16x16_packed	x=102, y=5, text="S0UND NAMING"
	dl_box	x0=4, y0=4, x1=68, y1=16
; DL_ClrP0siti0nAbcInsDelAA -- the display list at 0xF0587C.  Its own text
;                              records read: "CLR"; "P0SITI0N"; "ABC"; "INS
;                              DEL  A/a".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_ClrP0siti0nAbcInsDelAA:
	dl_text8x14	x=48, y=104, text="A B C D E F G H I J K L M N O"
	dl_text8x14	x=32, y=119, text="P Q R S T U V W X Y Z a b c d e"
	dl_text8x14	x=32, y=134, text="f g h i j k l m n o p q r s t u"
	dl_text8x14	x=32, y=149, text="v w x y z 0 1 2 3 4 5 6 7 8 9 !"
	dl_text8x14	x=32, y=164, text="\" # $ % & ' ( ) + - * / = , . @"
	dl_text8x14	x=32, y=179, text=": ; ? \\ ^ _ ` | ~ \177 < > [ ] { }"
	dl_text8x14	x=280, y=35, text="CLR"
	dl_text8x16	x=312, y=35, text="\021"
	dl_text8x16	x=280, y=73, text="~"
	dl_text8x16	x=296, y=73, text="\177"
	dl_text8x16	x=312, y=73, text="\021"
	dl_text8x16	x=256, y=195, text=".."
	dl_text8x14	x=8, y=197, text="P0SITI0N"
	dl_text8x14	x=232, y=197, text="ABC"
	dl_text8x14	x=272, y=197, text="]{}"
	dl_text8x14	x=256, y=210, text="\215"
	dl_text8x14	x=16, y=218, text="<    >"
	dl_text8x14	x=88, y=218, text="INS  DEL  A/a"
	dl_text8x14	x=216, y=218, text="<"
	dl_text8x14	x=296, y=218, text=">"
	dl_text8x14	x=256, y=222, text="\216"
	dl_box_shadow2	x0=277, y0=28, x1=306, y1=52
	dl_box_shadow2	x0=277, y0=66, x1=306, y1=90
	dl_box_patterned	x0=15, y0=98, x1=300, y1=194
	dl_box_shadow2	x0=5, y0=210, x1=34, y1=234
	dl_box_shadow2	x0=45, y0=210, x1=74, y1=234
	dl_box_shadow2	x0=85, y0=210, x1=114, y1=234
	dl_box_shadow2	x0=125, y0=210, x1=154, y1=234
	dl_box_shadow2	x0=165, y0=210, x1=194, y1=234
	dl_box_shadow2	x0=205, y0=210, x1=234, y1=234
	dl_box_shadow2	x0=245, y0=210, x1=274, y1=234
	dl_box_shadow2	x0=285, y0=210, x1=314, y1=234
	dl_hline	x0=245, y0=222, x1=274, y1=222
Draw_Write_DL2:
; ; drawn (start operand) by Draw_Write -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_box_shadow2	x0=77, y0=59, x1=261, y1=81
Draw_Write_DL1:
; ; drawn (start operand) by Draw_Write -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_box_shadow2	x0=77, y0=59, x1=229, y1=81
Draw_Write_DL3:
; ; drawn (start operand) by Draw_Write -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_box_shadow2	x0=77, y0=59, x1=108, y1=81
DL_F05A4C:
	dlb_string_xy	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText16x16Packed, table=DiskSave_PasswordEntry, width=16, x=81, y=63
	dlb_rect_entry	var=ModelingPage_Fields, mask=0x0f, shift=0, svc=LCDSVC_FillRect, table=DLBoxes_F05AB4
DL_F05A68:
	dlb_string_xy	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText16x16Packed, table=DiskSave_PasswordEntry, width=13, x=81, y=63
	dlb_rect_entry	var=ModelingPage_Fields, mask=0x0f, shift=0, svc=LCDSVC_FillRect, table=DLBoxes_F05AB4
DL_F05A84:
	dlb_string_xy	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText16x16Packed, table=DiskSave_PasswordEntry, width=2, x=81, y=63
	dlb_rect_entry	var=ModelingPage_Fields, mask=0x0f, shift=0, svc=LCDSVC_FillRect, table=DLBoxes_F05AB4
SoundEditNaming_RepaintField_DL2:
; ; drawn (start operand) by SoundEditNaming_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=81, y0=62, x1=257, y1=79
SoundEditNaming_RepaintField_DL1:
; ; drawn (start operand) by SoundEditNaming_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=32, y0=103, x1=280, y1=192

; === COVER-R1 0xF05AB4-0xF05F78 ===
; 0xF05AB4-0xF05F77, coverage round 1: 1208 of this span's 1220 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 1208 as DATA
; (only a `.long` or a 32-bit immediate names it) in 2 runs.  Everything else
; here is NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice
; ⚠ CORRECTED 2026-09-02 (lane res05x): the sentence above is no
;   longer true of this span -- 1220 of 1220 bytes are real source now, and no
;   `.incbin` remains between these markers.  What round 1 measured was
;   REACHABILITY, which finds an object's first byte and never its last;
;   the extents below come from the code that RUNS these records.

; --------------------------------------------------------------------------
; 0xF05AB4 -- 568 bytes, EMITTED AS DATA (not promoted to code).
; ⚠ SUPERSEDED 2026-09-02 (lane res05x): 568 was the reachability walk's
;   extent and it is 12 bytes TOO LONG.  Its last 12 bytes are the first
;   byte-column of the 2x12 bitmap at 0xF05CE0, whose size three op-03
;   records state (2 bytes x 12 rows = 24) and which now stands on its
;   own below.  So: 556 bytes, 0xF05AB4-0xF05CDF, and the `stays
;   `.incbin`` sentence below no longer holds for the span that followed.
; Reached from: 0x00F05AB4 appears as a 32-bit word at 0xF05A64 0xF05A80
;               0xF05A9C 0xF5D32A 0xF5D36D +1 more; converted code at 0xF5D329
;               0xF5D36C 0xF5D38E loads it as a 32-bit immediate.  No routine-
;               directory slot and no branch decoded in converted code names
;               it.
; Measured: 66% printable ASCII; a linear decode runs 250 instructions and
;           ends `reti`, with 40% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLBoxes_F05AB4 -- 0xF05AB4-0xF05B33, 16 entries of four words, left / top
;   / right / bottom of the inclusive pixel box LCD_Svc_05_FillRect fills or
;   erases.  Read by the interpreter-B op-0x03 records at 0xF05A5D ((0x27A6)
;   AND 0x0F >> 0), 0xF05A79 ((0x27A6) AND 0x0F >> 0), 0xF05A95 ((0x27A6)
;   AND 0x0F >> 0) -- value = (byte at the +2 address) AND mask >> shift --
;   whose +0x07 names this address; DLB_Handler_Array8 copies entry [value]
;   to (0x2530)..(0x2536) (`sla 3,HL`).  Entry count: the 16 values the
;   readers' masks admit (the bytes after that are not indexed by them).
;   This address is also the END of a display list: `ld XIY,0xF05AAA / ld
;   XIX,this / call T_DisplayList_Run` at 0xF5D329; `ld XIY,0xF05AA0 / ld
;   XIX,this / call T_DisplayList_Run` at 0xF5D36C; `ld XIY,0xF05AA0 / ld
;   XIX,this / call T_DisplayList_Run` at 0xF5D38E.
; --------------------------------------------------------------------------
DLBoxes_F05AB4:
	.short	81, 62, 92, 79	; F05AB4  [0]
	.short	92, 62, 103, 79	; F05ABC  [1]
	.short	103, 62, 114, 79	; F05AC4  [2]
	.short	114, 62, 125, 79	; F05ACC  [3]
	.short	125, 62, 136, 79	; F05AD4  [4]
	.short	136, 62, 147, 79	; F05ADC  [5]
	.short	147, 62, 158, 79	; F05AE4  [6]
	.short	158, 62, 169, 79	; F05AEC  [7]
	.short	169, 62, 180, 79	; F05AF4  [8]
	.short	180, 62, 191, 79	; F05AFC  [9]
	.short	191, 62, 202, 79	; F05B04  [10]
	.short	202, 62, 213, 79	; F05B0C  [11]
	.short	213, 62, 224, 79	; F05B14  [12]
	.short	224, 62, 235, 79	; F05B1C  [13]
	.short	235, 62, 246, 79	; F05B24  [14]
	.short	246, 62, 257, 79	; F05B2C  [15]
; --------------------------------------------------------------------------
; Data_F05B34 -- 0xF05B34-0xF05B5F, 44 bytes after the last entry
;   DLBoxes_F05AB4's readers index.  No interpreter-B record's +0x07 and no
;   pointer-array run names them (a 32-bit immediate does: `ld XIZ,this` at
;   0xF5D3CF); purpose not established.
; --------------------------------------------------------------------------
Data_F05B34:
	.byte	0x20, 0x00, 0x30, 0x00, 0x40, 0x00, 0x50, 0x00, 0x60, 0x00, 0x70, 0x00, 0x80, 0x00, 0x90, 0x00	; F05B34
	.byte	0xA0, 0x00, 0xB0, 0x00, 0xC0, 0x00, 0xD0, 0x00, 0xE0, 0x00, 0xF0, 0x00, 0x00, 0x01, 0x10, 0x01	; F05B44
	.byte	0x67, 0x00, 0x76, 0x00, 0x85, 0x00, 0x94, 0x00, 0xA3, 0x00, 0xB2, 0x00	; F05B54
; --------------------------------------------------------------------------
; DLText_NoteNamesCm2ToG8 -- 0xF05B60-0xF05CDF, 128 entries of 3 bytes, text
;   drawn by LCD_Svc_06_DrawText8x14 / LCD_Svc_1C_DrawText16x16Packed.  Read
;   by the interpreter-B op-0x02/0x07 records at 0xF0363E ((0x27AA) AND 0x7F
;   >> 0), 0xF0364D ((0x27A9) AND 0x7F >> 0), 0xF0365C ((0x27AB) AND 0x7F >>
;   0), 0xF03676 ((0x27AE) AND 0x7F >> 0) and 14 more -- value = (byte at
;   the +2 address) AND mask >> shift -- whose +0x07 names this address;
;   DLB_Handler_StringTable/StringTable2 draws entry [value] with +0x0B = 3
;   as the width.  Entry count: the distance to the object's end over the
;   width; the masks admit 128.
; --------------------------------------------------------------------------
DLText_NoteNamesCm2ToG8:
	.byte	0x43, 0x2D, 0x32	; F05B60  [0]
	.byte	0x44, 0x88, 0xBC	; F05B63  [1]
	.byte	0x44, 0x2D, 0x32	; F05B66  [2]
	.byte	0x45, 0x88, 0xBC	; F05B69  [3]
	.byte	0x45, 0x2D, 0x32	; F05B6C  [4]
	.byte	0x46, 0x2D, 0x32	; F05B6F  [5]
	.byte	0x46, 0x8C, 0xBC	; F05B72  [6]
	.byte	0x47, 0x2D, 0x32	; F05B75  [7]
	.byte	0x41, 0x88, 0xBC	; F05B78  [8]
	.byte	0x41, 0x2D, 0x32	; F05B7B  [9]
	.byte	0x42, 0x88, 0xBC	; F05B7E  [10]
	.byte	0x42, 0x2D, 0x32	; F05B81  [11]
	.byte	0x43, 0x2D, 0x31	; F05B84  [12]
	.byte	0x44, 0x88, 0xB0	; F05B87  [13]
	.byte	0x44, 0x2D, 0x31	; F05B8A  [14]
	.byte	0x45, 0x88, 0xB0	; F05B8D  [15]
	.byte	0x45, 0x2D, 0x31	; F05B90  [16]
	.byte	0x46, 0x2D, 0x31	; F05B93  [17]
	.byte	0x46, 0x8C, 0xB0	; F05B96  [18]
	.byte	0x47, 0x2D, 0x31	; F05B99  [19]
	.byte	0x41, 0x88, 0xB0	; F05B9C  [20]
	.byte	0x41, 0x2D, 0x31	; F05B9F  [21]
	.byte	0x42, 0x88, 0xB0	; F05BA2  [22]
	.byte	0x42, 0x2D, 0x31	; F05BA5  [23]
	.byte	0x43, 0x30, 0x20	; F05BA8  [24]
	.byte	0x44, 0x88, 0x30	; F05BAB  [25]
	.byte	0x44, 0x30, 0x20	; F05BAE  [26]
	.byte	0x45, 0x88, 0x30	; F05BB1  [27]
	.byte	0x45, 0x30, 0x20	; F05BB4  [28]
	.byte	0x46, 0x30, 0x20	; F05BB7  [29]
	.byte	0x46, 0x8C, 0x30	; F05BBA  [30]
	.byte	0x47, 0x30, 0x20	; F05BBD  [31]
	.byte	0x41, 0x88, 0x30	; F05BC0  [32]
	.byte	0x41, 0x30, 0x20	; F05BC3  [33]
	.byte	0x42, 0x88, 0x30	; F05BC6  [34]
	.byte	0x42, 0x30, 0x20	; F05BC9  [35]
	.byte	0x43, 0x31, 0x20	; F05BCC  [36]
	.byte	0x44, 0x88, 0x31	; F05BCF  [37]
	.byte	0x44, 0x31, 0x20	; F05BD2  [38]
	.byte	0x45, 0x88, 0x31	; F05BD5  [39]
	.byte	0x45, 0x31, 0x20	; F05BD8  [40]
	.byte	0x46, 0x31, 0x20	; F05BDB  [41]
	.byte	0x46, 0x8C, 0x31	; F05BDE  [42]
	.byte	0x47, 0x31, 0x20	; F05BE1  [43]
	.byte	0x41, 0x88, 0x31	; F05BE4  [44]
	.byte	0x41, 0x31, 0x20	; F05BE7  [45]
	.byte	0x42, 0x88, 0x31	; F05BEA  [46]
	.byte	0x42, 0x31, 0x20	; F05BED  [47]
	.byte	0x43, 0x32, 0x20	; F05BF0  [48]
	.byte	0x44, 0x88, 0x32	; F05BF3  [49]
	.byte	0x44, 0x32, 0x20	; F05BF6  [50]
	.byte	0x45, 0x88, 0x32	; F05BF9  [51]
	.byte	0x45, 0x32, 0x20	; F05BFC  [52]
	.byte	0x46, 0x32, 0x20	; F05BFF  [53]
	.byte	0x46, 0x8C, 0x32	; F05C02  [54]
	.byte	0x47, 0x32, 0x20	; F05C05  [55]
	.byte	0x41, 0x88, 0x32	; F05C08  [56]
	.byte	0x41, 0x32, 0x20	; F05C0B  [57]
	.byte	0x42, 0x88, 0x32	; F05C0E  [58]
	.byte	0x42, 0x32, 0x20	; F05C11  [59]
	.byte	0x43, 0x33, 0x20	; F05C14  [60]
	.byte	0x44, 0x88, 0x33	; F05C17  [61]
	.byte	0x44, 0x33, 0x20	; F05C1A  [62]
	.byte	0x45, 0x88, 0x33	; F05C1D  [63]
	.byte	0x45, 0x33, 0x20	; F05C20  [64]
	.byte	0x46, 0x33, 0x20	; F05C23  [65]
	.byte	0x46, 0x8C, 0x33	; F05C26  [66]
	.byte	0x47, 0x33, 0x20	; F05C29  [67]
	.byte	0x41, 0x88, 0x33	; F05C2C  [68]
	.byte	0x41, 0x33, 0x20	; F05C2F  [69]
	.byte	0x42, 0x88, 0x33	; F05C32  [70]
	.byte	0x42, 0x33, 0x20	; F05C35  [71]
	.byte	0x43, 0x34, 0x20	; F05C38  [72]
	.byte	0x44, 0x88, 0x34	; F05C3B  [73]
	.byte	0x44, 0x34, 0x20	; F05C3E  [74]
	.byte	0x45, 0x88, 0x34	; F05C41  [75]
	.byte	0x45, 0x34, 0x20	; F05C44  [76]
	.byte	0x46, 0x34, 0x20	; F05C47  [77]
	.byte	0x46, 0x8C, 0x34	; F05C4A  [78]
	.byte	0x47, 0x34, 0x20	; F05C4D  [79]
	.byte	0x41, 0x88, 0x34	; F05C50  [80]
	.byte	0x41, 0x34, 0x20	; F05C53  [81]
	.byte	0x42, 0x88, 0x34	; F05C56  [82]
	.byte	0x42, 0x34, 0x20	; F05C59  [83]
	.byte	0x43, 0x35, 0x20	; F05C5C  [84]
	.byte	0x44, 0x88, 0x35	; F05C5F  [85]
	.byte	0x44, 0x35, 0x20	; F05C62  [86]
	.byte	0x45, 0x88, 0x35	; F05C65  [87]
	.byte	0x45, 0x35, 0x20	; F05C68  [88]
	.byte	0x46, 0x35, 0x20	; F05C6B  [89]
	.byte	0x46, 0x8C, 0x35	; F05C6E  [90]
	.byte	0x47, 0x35, 0x20	; F05C71  [91]
	.byte	0x41, 0x88, 0x35	; F05C74  [92]
	.byte	0x41, 0x35, 0x20	; F05C77  [93]
	.byte	0x42, 0x88, 0x35	; F05C7A  [94]
	.byte	0x42, 0x35, 0x20	; F05C7D  [95]
	.byte	0x43, 0x36, 0x20	; F05C80  [96]
	.byte	0x44, 0x88, 0x36	; F05C83  [97]
	.byte	0x44, 0x36, 0x20	; F05C86  [98]
	.byte	0x45, 0x88, 0x36	; F05C89  [99]
	.byte	0x45, 0x36, 0x20	; F05C8C  [100]
	.byte	0x46, 0x36, 0x20	; F05C8F  [101]
	.byte	0x46, 0x8C, 0x36	; F05C92  [102]
	.byte	0x47, 0x36, 0x20	; F05C95  [103]
	.byte	0x41, 0x88, 0x36	; F05C98  [104]
	.byte	0x41, 0x36, 0x20	; F05C9B  [105]
	.byte	0x42, 0x88, 0x36	; F05C9E  [106]
	.byte	0x42, 0x36, 0x20	; F05CA1  [107]
	.byte	0x43, 0x37, 0x20	; F05CA4  [108]
	.byte	0x44, 0x88, 0x37	; F05CA7  [109]
	.byte	0x44, 0x37, 0x20	; F05CAA  [110]
	.byte	0x45, 0x88, 0x37	; F05CAD  [111]
	.byte	0x45, 0x37, 0x20	; F05CB0  [112]
	.byte	0x46, 0x37, 0x20	; F05CB3  [113]
	.byte	0x46, 0x8C, 0x37	; F05CB6  [114]
	.byte	0x47, 0x37, 0x20	; F05CB9  [115]
	.byte	0x41, 0x88, 0x37	; F05CBC  [116]
	.byte	0x41, 0x37, 0x20	; F05CBF  [117]
	.byte	0x42, 0x88, 0x37	; F05CC2  [118]
	.byte	0x42, 0x37, 0x20	; F05CC5  [119]
	.byte	0x43, 0x38, 0x20	; F05CC8  [120]
	.byte	0x44, 0x88, 0x38	; F05CCB  [121]
	.byte	0x44, 0x38, 0x20	; F05CCE  [122]
	.byte	0x45, 0x88, 0x38	; F05CD1  [123]
	.byte	0x45, 0x38, 0x20	; F05CD4  [124]
	.byte	0x46, 0x38, 0x20	; F05CD7  [125]
	.byte	0x46, 0x8C, 0x38	; F05CDA  [126]
	.byte	0x47, 0x38, 0x20	; F05CDD  [127]

; ------------------------------------------------------------------
; Bitmap_F05CE0 -- 24 bytes, 2 bytes wide x 12 rows.
; ⚠ "2 bytes wide x 12 rows" names the SIZE correctly and the LAYOUT wrongly:
;   service 3 stores COLUMN-MAJOR, so this is 2 byte-columns of 12 bytes = a
;   16 x 12 picture, byte c*12+r.  Committed as images/Bitmap_F05CE0.png; see
;   notes/FINDINGS-image-files.md section 1.
; Referenced by: three interpreter-A op-03 records, at 0xF02B97,
; 0xF06307 and 0xF0631D.  Each is `.long 0x00F05CE0`, a VRAM address,
; `.short 0x0002` (width in BYTES) and `.short 0x000C` (rows); handler
; 0xF31ABE issues swi 7 service 3 with BC = width and HL = rows, so the
; size is 2 * 12 = 24 -- and 0xF05CE0 + 24 = 0xF05CF8, the head of the
; note-frequency table.  Both edges and the length come from outside the
; span.  The first 12 bytes used to be the tail of Data_F05AB4, the last
; 12 were the `.incbin` at file offset 0x005CEC.
; (Data_F05AB4 is now DLBoxes_F05AB4, Data_F05B34 and
; DLText_NoteNamesCm2ToG8 -- notes/promb-2026-09-25/dlb_table_splitter.py.)
; Evidence: python3 notes/prom_b_res05x_spans.py --selftest, and
; notes/prom_b_dl_operand_tables.py, which reports it independently as
; `0xF05CE0 + 24  A bitmap, 2 bytes x 12 rows`.
; ------------------------------------------------------------------
Bitmap_F05CE0:
; Drawn as two byte-COLUMNS (bytes 0-11 = column 0, 12-23 = column 1)
; these 24 bytes are a closed 16x12 ring with an interior diagonal.
; Drawn row-major (2 bytes per row) they are not a closed shape.  The
; blitter's actual pixel order is NOT established here -- only the
; EXTENT is, and the extent is all this conversion rests on.
; row  0  .....####.......
; row  1  ...##....##.....
; row  2  ..#.......##....
; row  3  ..#......#.#....
; row  4  .#......#...#...
; row  5  ##.....#....####
; row  6  ##..........#...
; row  7  .#..........#...
; row  8  ..#........#....
; row  9  ..#........#....
; row 10  ...##....##.....
; row 11  .....####.......
	.byte	0x07, 0x18, 0x20, 0x20, 0x40, 0xC1, 0xC0, 0x40, 0x20, 0x20, 0x18, 0x07	; F05CE0  byte-column 0, rows 0-11
	.byte	0x80, 0x60, 0x30, 0x50, 0x88, 0x0F, 0x08, 0x08, 0x10, 0x10, 0x60, 0x80	; F05CEC  byte-column 1, rows 0-11

; --------------------------------------------------------------------------
; 0xF05CF8-0xF05F77 -- 640 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F05CF8 appears as a 32-bit word at 0xF04D5F 0xF04D7D
;               0xF04E1B 0xF04E5E 0xF04E7C.  No routine-directory slot and no
;               branch decoded in converted code names it.
; Measured: 100% printable ASCII; a linear decode runs 284 instructions and
;           ends `ld IX,0x4b38`, with 8% of the bytes in spellings llvm-mc
;           will not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLText_Frequencies65HzTo48K -- 0xF05CF8-0xF05F77, 128 entries of 5 bytes,
;   text drawn by LCD_Svc_20_DrawText8x10.  Read by the interpreter-B
;   op-0x02 records at 0xF04D58 ((0x27A8) AND 0x7F >> 0), 0xF04D76 ((0x27AA)
;   AND 0x7F >> 0), 0xF04E14 ((0x27A8) AND 0x7F >> 0), 0xF04E57 ((0x27A8)
;   AND 0x7F >> 0) and 1 more -- value = (byte at the +2 address) AND mask
;   >> shift -- whose +0x07 names this address; DLB_Handler_StringTable
;   draws entry [value] with +0x0B = 5 as the width.  Entry count: the
;   distance to the object's end over the width; the masks admit 128.
; --------------------------------------------------------------------------
DLText_Frequencies65HzTo48K:
	.ascii	" 65.4"	; F05CF8  [0]
	.ascii	" 69.3"	; F05CFD  [1]
	.ascii	" 73.4"	; F05D02  [2]
	.ascii	" 77.8"	; F05D07  [3]
	.ascii	" 82.4"	; F05D0C  [4]
	.ascii	" 87.3"	; F05D11  [5]
	.ascii	" 92.5"	; F05D16  [6]
	.ascii	" 98.0"	; F05D1B  [7]
	.ascii	"103.8"	; F05D20  [8]
	.ascii	"110.0"	; F05D25  [9]
	.ascii	"116.5"	; F05D2A  [10]
	.ascii	"123.5"	; F05D2F  [11]
	.ascii	"130.8"	; F05D34  [12]
	.ascii	"138.6"	; F05D39  [13]
	.ascii	"146.8"	; F05D3E  [14]
	.ascii	"155.6"	; F05D43  [15]
	.ascii	"164.8"	; F05D48  [16]
	.ascii	"174.6"	; F05D4D  [17]
	.ascii	"185.0"	; F05D52  [18]
	.ascii	"196.0"	; F05D57  [19]
	.ascii	"207.6"	; F05D5C  [20]
	.ascii	"220.0"	; F05D61  [21]
	.ascii	"233.1"	; F05D66  [22]
	.ascii	"246.9"	; F05D6B  [23]
	.ascii	"261.6"	; F05D70  [24]
	.ascii	"277.2"	; F05D75  [25]
	.ascii	"293.6"	; F05D7A  [26]
	.ascii	"311.1"	; F05D7F  [27]
	.ascii	"329.6"	; F05D84  [28]
	.ascii	"349.2"	; F05D89  [29]
	.ascii	"370.0"	; F05D8E  [30]
	.ascii	"392.0"	; F05D93  [31]
	.ascii	"415.3"	; F05D98  [32]
	.ascii	"440.0"	; F05D9D  [33]
	.ascii	"466.1"	; F05DA2  [34]
	.ascii	"493.8"	; F05DA7  [35]
	.ascii	"523.2"	; F05DAC  [36]
	.ascii	"554.3"	; F05DB1  [37]
	.ascii	"587.3"	; F05DB6  [38]
	.ascii	"622.2"	; F05DBB  [39]
	.ascii	"659.2"	; F05DC0  [40]
	.ascii	"698.4"	; F05DC5  [41]
	.ascii	"739.9"	; F05DCA  [42]
	.ascii	"783.9"	; F05DCF  [43]
	.ascii	"830.5"	; F05DD4  [44]
	.ascii	"879.9"	; F05DD9  [45]
	.ascii	"932.2"	; F05DDE  [46]
	.ascii	"987.7"	; F05DE3  [47]
	.ascii	"1.05K"	; F05DE8  [48]
	.ascii	"1.11K"	; F05DED  [49]
	.ascii	"1.17K"	; F05DF2  [50]
	.ascii	"1.24K"	; F05DF7  [51]
	.ascii	"1.32K"	; F05DFC  [52]
	.ascii	"1.40K"	; F05E01  [53]
	.ascii	"1.48K"	; F05E06  [54]
	.ascii	"1.57K"	; F05E0B  [55]
	.ascii	"1.66K"	; F05E10  [56]
	.ascii	"1.76K"	; F05E15  [57]
	.ascii	"1.86K"	; F05E1A  [58]
	.ascii	"1.98K"	; F05E1F  [59]
	.ascii	"2.09K"	; F05E24  [60]
	.ascii	"2.22K"	; F05E29  [61]
	.ascii	"2.35K"	; F05E2E  [62]
	.ascii	"2.49K"	; F05E33  [63]
	.ascii	"2.64K"	; F05E38  [64]
	.ascii	"2.79K"	; F05E3D  [65]
	.ascii	"2.96K"	; F05E42  [66]
	.ascii	"3.14K"	; F05E47  [67]
	.ascii	"3.32K"	; F05E4C  [68]
	.ascii	"3.52K"	; F05E51  [69]
	.ascii	"3.73K"	; F05E56  [70]
	.ascii	"3.95K"	; F05E5B  [71]
	.ascii	"4.19K"	; F05E60  [72]
	.ascii	"4.43K"	; F05E65  [73]
	.ascii	"4.70K"	; F05E6A  [74]
	.ascii	"4.98K"	; F05E6F  [75]
	.ascii	"5.27K"	; F05E74  [76]
	.ascii	"5.59K"	; F05E79  [77]
	.ascii	"5.92K"	; F05E7E  [78]
	.ascii	"6.27K"	; F05E83  [79]
	.ascii	"6.64K"	; F05E88  [80]
	.ascii	"7.04K"	; F05E8D  [81]
	.ascii	"7.46K"	; F05E92  [82]
	.ascii	"7.90K"	; F05E97  [83]
	.ascii	"8.37K"	; F05E9C  [84]
	.ascii	"8.87K"	; F05EA1  [85]
	.ascii	"9.40K"	; F05EA6  [86]
	.ascii	"9.96K"	; F05EAB  [87]
	.ascii	"10.5K"	; F05EB0  [88]
	.ascii	"11.2K"	; F05EB5  [89]
	.ascii	"11.8K"	; F05EBA  [90]
	.ascii	"12.5K"	; F05EBF  [91]
	.ascii	"13.3K"	; F05EC4  [92]
	.ascii	"14.1K"	; F05EC9  [93]
	.ascii	"14.9K"	; F05ECE  [94]
	.ascii	"15.8K"	; F05ED3  [95]
	.ascii	"16.7K"	; F05ED8  [96]
	.ascii	"17.7K"	; F05EDD  [97]
	.ascii	"18.8K"	; F05EE2  [98]
	.ascii	"19.9K"	; F05EE7  [99]
	.ascii	"21.1K"	; F05EEC  [100]
	.ascii	"  22K"	; F05EF1  [101]
	.ascii	"  23K"	; F05EF6  [102]
	.ascii	"  24K"	; F05EFB  [103]
	.ascii	"  25K"	; F05F00  [104]
	.ascii	"  26K"	; F05F05  [105]
	.ascii	"  27K"	; F05F0A  [106]
	.ascii	"  28K"	; F05F0F  [107]
	.ascii	"  29K"	; F05F14  [108]
	.ascii	"  30K"	; F05F19  [109]
	.ascii	"  31K"	; F05F1E  [110]
	.ascii	"  32K"	; F05F23  [111]
	.ascii	"  33K"	; F05F28  [112]
	.ascii	"  34K"	; F05F2D  [113]
	.ascii	"  35K"	; F05F32  [114]
	.ascii	"  36K"	; F05F37  [115]
	.ascii	"  37K"	; F05F3C  [116]
	.ascii	"  38K"	; F05F41  [117]
	.ascii	"  39K"	; F05F46  [118]
	.ascii	"  40K"	; F05F4B  [119]
	.ascii	"  41K"	; F05F50  [120]
	.ascii	"  42K"	; F05F55  [121]
	.ascii	"  43K"	; F05F5A  [122]
	.ascii	"  44K"	; F05F5F  [123]
	.ascii	"  45K"	; F05F64  [124]
	.ascii	"  46K"	; F05F69  [125]
	.ascii	"  47K"	; F05F6E  [126]
	.ascii	"  48K"	; F05F73  [127]

; === END COVER-R1 0xF05AB4-0xF05F78 ===

; ------------------------------------------------------------------
; 0xF05F78-0xF06561 -- 156 display-list records, 1514 bytes -- interpreter A (147 records) and B (9)
;   entered at: 0xF05F78, 0xF06048, 0xF060DA, 0xF060E4, 0xF06154, 0xF06224, 0xF06481, 0xF06495, 0xF064A9, 0xF064C6, 0xF064E5, 0xF064F9, 0xF06517, 0xF06544
;   ends used:  0xF06048, 0xF060DA, 0xF060E4, 0xF06154, 0xF06224, 0xF06481, 0xF06495, 0xF064A9, 0xF064C6, 0xF064E5, 0xF06517, 0xF06535, 0xF06562
; ------------------------------------------------------------------
; DL_TriggerDelayTriggerDelay -- the display list at 0xF05F78.  Its own text
;                                records read: "TRIGGER"; "DELAY"; "TRIGGER";
;                                "DELAY".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_TriggerDelayTriggerDelay:
	dl_text8x8_packed	x=57, y=62, text="TRIGGER"
	dl_text8x8_packed	x=134, y=62, text="DELAY"
	dl_text8x14	x=0, y=78, text="\020"
	dl_text8x14	x=0, y=115, text="\020"
	dl_text8x14	x=0, y=150, text="\020"
	dl_text8x14	x=0, y=187, text="\020"
	dl_text8x8_packed	x=39, y=209, text="TRIGGER"
	dl_text8x8_packed	x=124, y=209, text="DELAY"
	dl_text8x14	x=56, y=217, text="\215"
	dl_text8x14	x=136, y=217, text="\215"
	dl_text8x14	x=56, y=227, text="\216"
	dl_text8x14	x=136, y=227, text="\216"
	dl_box_shadow1	x0=11, y0=56, x1=174, y1=202
	dl_box_shadow1	x0=49, y0=218, x1=70, y1=238
	dl_box_shadow1	x0=129, y0=218, x1=150, y1=238
	dl_hline	x0=11, y0=74, x1=174, y1=74
	dl_hline	x0=11, y0=106, x1=174, y1=106
	dl_hline	x0=11, y0=138, x1=174, y1=138
	dl_hline	x0=11, y0=170, x1=174, y1=170
	dl_hline	x0=49, y0=228, x1=70, y1=228
	dl_hline	x0=129, y0=228, x1=150, y1=228
	dl_vline	x0=44, y0=56, x1=44, y1=202
	dl_vline	x0=124, y0=56, x1=124, y1=202
	dl_fill_rect	x0=262, y0=28, x1=306, y1=54
; DL_PanningPanning -- the display list at 0xF06048.  Its own text records
;                      read: "PANNING"; "PANNING".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_PanningPanning:
	dl_text8x8_packed	x=69, y=62, text="PANNING"
	dl_text8x14	x=0, y=78, text="\020"
	dl_text8x14	x=0, y=115, text="\020"
	dl_text8x14	x=0, y=150, text="\020"
	dl_text8x14	x=0, y=187, text="\020"
	dl_text8x8_packed	x=70, y=209, text="PANNING"
	dl_text8x14	x=88, y=217, text="\215"
	dl_text8x14	x=88, y=227, text="\216"
	dl_box_shadow1	x0=11, y0=56, x1=134, y1=202
	dl_box_shadow1	x0=81, y0=218, x1=102, y1=238
	dl_hline	x0=11, y0=74, x1=134, y1=74
	dl_hline	x0=11, y0=106, x1=134, y1=106
	dl_hline	x0=11, y0=138, x1=134, y1=138
	dl_hline	x0=11, y0=170, x1=134, y1=170
	dl_hline	x0=81, y0=228, x1=102, y1=228
	dl_vline	x0=44, y0=56, x1=44, y1=202
	dl_fill_rect	x0=262, y0=145, x1=306, y1=171
DL_F060DA:
	dl_box	x0=69, y0=204, x1=251, y1=233
SoundEditToneLayerKeyLayer_Paint_DL1:
; ; drawn (start operand) by SoundEditToneLayerKeyLayer_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x14	x=104, y=30, text="KEY LAYER"
	dl_text8x8_packed	x=57, y=42, text="0"
	dl_text8x8_packed	x=84, y=42, text="1"
	dl_text8x8_packed	x=113, y=42, text="2"
	dl_text8x8_packed	x=141, y=42, text="3"
	dl_text8x8_packed	x=169, y=42, text="4"
	dl_text8x8_packed	x=197, y=42, text="5"
	dl_text8x8_packed	x=225, y=42, text="6"
	dl_box	x0=39, y0=98, x1=246, y1=99
	dl_box	x0=39, y0=129, x1=246, y1=130
	dl_box	x0=39, y0=160, x1=246, y1=161
	dl_box	x0=39, y0=191, x1=246, y1=192
	dl_fill_rect	x0=262, y0=68, x1=306, y1=94
SoundEditToneLayerVelocityLayer_Paint_DL1:
; ; drawn (start operand) by SoundEditToneLayerVelocityLayer_Paint -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_text8x14	x=88, y=34, text="VELOCITY LAYER"
	dl_text8x8_packed	x=45, y=50, text="0"
	dl_text8x8_packed	x=91, y=50, text="32"
	dl_text8x8_packed	x=138, y=50, text="64"
	dl_text8x8_packed	x=186, y=50, text="96"
	dl_text8x8_packed	x=228, y=51, text="127"
	dl_hline_dither	x0=48, y0=61, x1=240, y1=61
	dl_box	x0=48, y0=98, x1=240, y1=99
	dl_box	x0=48, y0=129, x1=240, y1=130
	dl_box	x0=48, y0=160, x1=240, y1=161
	dl_box	x0=48, y0=191, x1=240, y1=192
	dl_vline	x0=48, y0=60, x1=48, y1=62
	dl_vline	x0=72, y0=60, x1=72, y1=62
	dl_vline	x0=96, y0=60, x1=96, y1=62
	dl_vline	x0=120, y0=60, x1=120, y1=62
	dl_vline	x0=144, y0=60, x1=144, y1=62
	dl_vline	x0=168, y0=60, x1=168, y1=62
	dl_vline	x0=192, y0=60, x1=192, y1=62
	dl_vline	x0=216, y0=60, x1=216, y1=62
	dl_vline	x0=240, y0=60, x1=240, y1=62
	dl_fill_rect	x0=262, y0=106, x1=306, y1=132
; DL_EffectBlockEff1Eff2RevMain -- the display list at 0xF06224.  Its own text
;                                  records read: "EFFECT"; "BLOCK"; "EFF1";
;                                  "EFF2"; "REV"; "MAIN"; "DIRECT MAIN OUT";
;                                  "DIRECT SUB OUT" +12 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_EffectBlockEff1Eff2RevMain:
	dl_text8x8_packed	x=107, y=37, text="EFFECT"
	dl_text8x8_packed	x=149, y=37, text="BLOCK"
	dl_text8x10	x=112, y=66, text="EFF1"
	dl_text8x8_packed	x=181, y=68, text="\021"
	dl_text8x10	x=112, y=91, text="EFF2"
	dl_text8x10	x=120, y=116, text="REV"
	dl_text8x8_packed	x=181, y=118, text="\021"
	dl_text8x8_packed	x=183, y=143, text="\021"
	dl_text8x8_packed	x=190, y=118, text="MAIN"
	dl_text8x8_packed	x=75, y=151, text="DIRECT MAIN OUT"
	dl_text8x8_packed	x=183, y=166, text="\021"
	dl_text8x8_packed	x=75, y=174, text="DIRECT SUB OUT"
	dl_text8x10	x=48, y=192, text="EFFECT SEND"
	dl_text8x10	x=160, y=192, text="DIRECT OUT"
	dl_text8x8_packed	x=43, y=209, text="EFF1"
	dl_text8x8_packed	x=85, y=209, text="EFF2"
	dl_text8x8_packed	x=127, y=209, text="REV"
	dl_text8x8_packed	x=167, y=209, text="MAIN"
	dl_text8x8_packed	x=214, y=209, text="SUB"
	dl_text8x16	x=56, y=232, text="\022"
	dl_text8x16	x=96, y=232, text="\022"
	dl_text8x16	x=136, y=232, text="\022"
	dl_text8x16	x=176, y=232, text="\022"
	dl_text8x16	x=224, y=232, text="\022"
	dl_bitmap	bitmap=Bitmap_F05CE0, x=72, y=66, w=16, h=12
	dl_erase_rect	x0=71, y0=72, x1=72, y1=73
	dl_bitmap	bitmap=Bitmap_F05CE0, x=72, y=116, w=16, h=12
	dl_erase_rect	x0=71, y0=122, x1=72, y1=123
	dl_box	x0=72, y0=95, x1=74, y1=97
	dl_box	x0=82, y0=95, x1=84, y1=97
	dl_text8x16	x=112, y=5, text="EFFECT SEND & OUTPUT"
	dl_text8x8_packed	x=6, y=7, text="SOUND EDIT"
	dl_text8x10	x=256, y=192, text="PANNING"
	dl_text8x8_packed	x=258, y=208, text="1st"
	dl_text8x8_packed	x=288, y=208, text="2nd"
	dl_text8x16	x=264, y=232, text="\022"
	dl_text8x16	x=304, y=232, text="\022"
	dl_value_glyph	glyph=112, x=80, y=0
	dl_box	x0=94, y0=48, x1=227, y1=136
	dl_box	x0=109, y0=62, x1=148, y1=79
	dl_box	x0=109, y0=87, x1=148, y1=104
	dl_box	x0=115, y0=112, x1=148, y1=129
	dl_box	x0=36, y0=205, x1=245, y1=233
	dl_box	x0=4, y0=4, x1=68, y1=16
	dl_box	x0=249, y0=205, x1=318, y1=233
	dl_hline	x0=51, y0=71, x1=71, y1=71
	dl_hline	x0=84, y0=71, x1=109, y1=71
	dl_hline	x0=148, y0=71, x1=181, y1=71
	dl_hline	x0=51, y0=96, x1=71, y1=96
	dl_hline	x0=85, y0=96, x1=109, y1=96
	dl_hline	x0=51, y0=121, x1=71, y1=121
	dl_hline	x0=84, y0=121, x1=115, y1=121
	dl_hline	x0=148, y0=121, x1=181, y1=121
	dl_hline	x0=51, y0=146, x1=183, y1=146
	dl_hline	x0=32, y0=169, x1=183, y1=169
	dl_hline	x0=36, y0=218, x1=245, y1=218
	dl_vline	x0=51, y0=71, x1=51, y1=169
	dl_vline	x0=153, y0=205, x1=153, y1=233
	dl_hline	x0=249, y0=218, x1=318, y1=218
	dl_fill_rect	x0=250, y0=219, x1=317, y1=232
	dl_fill_rect	x0=37, y0=219, x1=244, y1=232
ToneEditPage_A8_PaintField5Switch_DL1:
; drawn (start operand) by ToneEditPage_A8_PaintField5Switch -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=75, y0=91, x1=84, y1=94
	dl_line	x0=75, y0=94, x1=84, y1=91
ToneEditPage_A8_PaintField5Switch_DL2:
; drawn (start operand) by ToneEditPage_A8_PaintField5Switch -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dl_erase_rect	x0=75, y0=91, x1=84, y1=94
	dl_hline	x0=75, y0=94, x1=84, y1=94
; DL_Serial -- the display list at 0xF064A9.  Its own text records read:
;              "SERIAL".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Serial:
	dl_text8x8_packed	x=157, y=54, text="SERIAL"
	dl_text8x8_packed	x=125, y=78, text="\215"
	dl_vline	x0=128, y0=82, x1=128, y1=86
; DL_Parallel -- the display list at 0xF064C6.  Its own text records read:
;                "PARALLEL".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Parallel:
	dl_text8x8_packed	x=155, y=54, text="PARALLEL"
	dl_text8x8_packed	x=181, y=93, text="\021"
	dl_hline	x0=149, y0=96, x1=181, y1=96
Draw_Serial_DL2:
; ; drawn (start operand) by Draw_Serial -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_number	var=ModelingPage_Fields, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=40, y=221, digits=3
	dlb_number	var=ModelingPage_Fields+1, mask=0x7f, shift=0, svc=LCDSVC_DrawText8x10, x=120, y=221, digits=3
ToneEditPage_A8_RepaintField_DL1:
; ; drawn (start operand) by ToneEditPage_A8_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=ModelingPage_Fields+2, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_OffMainSub1To3, width=4, x=192, y=142
	dlb_string	var=ModelingPage_Fields+2, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_OffOn_F034D8, width=3, x=168, y=221
ToneEditPage_A8_RepaintField_DL2:
; ; drawn (start operand) by ToneEditPage_A8_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=ModelingPage_Fields+3, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x14, table=DLText_OffMainSub1To3, width=4, x=192, y=164
	dlb_string	var=ModelingPage_Fields+3, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_OffMainSub1To3, width=4, x=208, y=221
	dlb_string	var=ModelingPage_Fields+5, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_OffOn_F034D8, width=3, x=80, y=221
ToneEditPage_A8_RepaintField_DL3:
; ; drawn (start operand) by ToneEditPage_A8_RepaintField -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string	var=ModelingPage_Fields+10, mask=0x03, shift=0, svc=LCDSVC_DrawText8x10, table=DLText_CtrLRRdm, width=3, x=256, y=221
	dlb_string	var=ModelingPage_Fields+10, mask=0x0c, shift=2, svc=LCDSVC_DrawText8x10, table=DLText_CtrLRRdm, width=3, x=288, y=221

; === COVER-R1 0xF06562-0xF06576 ===
; 0xF06562-0xF06575, coverage round 1: 20 of this span's 20 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 20 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; Data_F06562 -- 20 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F06562 appears as a 32-bit word at 0xF065D8 0xF5C26C
;               0xF5CE44; converted code at 0xF5C26B 0xF5CE43 loads it as a
;               32-bit immediate.  No routine-directory slot and no branch
;               decoded in converted code names it.
; Measured: 30% printable ASCII; a linear decode runs 10 instructions and ends
;           `ld B,0x02`, with 0% of the bytes in spellings llvm-mc will not
;           encode.
; ⚠ The extent is the reachability walk's, not the object's; the rest of
;   this span is unreachable and stays `.incbin`.  Why this is data and
;   not code: THE PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
Data_F06562:
	.byte	0x00, 0x0A, 0xB1, 0x27, 0x7F, 0x00, 0x20, 0xA9, 0x22, 0x02, 0x00, 0x0A, 0xB2, 0x27, 0x7F, 0x00	; F06562  |...'.. ."....'..|
	.byte	0x20, 0xAD, 0x22, 0x02	; F06572  | .".|

; === END COVER-R1 0xF06562-0xF06576 ===

; ------------------------------------------------------------------
; 0xF06576-0xF06597 -- 2 display-list records, 34 bytes -- interpreter B
;   entered at: 0xF06576
;   ends used:  0xF06587, 0xF06598
; ------------------------------------------------------------------
Draw_Serial_DL1:
; ; drawn (start operand) by Draw_Serial -- derivative name (notes/wsa1_display_list_drawer_names.py)
	dlb_string_xy	var=ModelingPage_Fields+6, mask=0x0f, shift=0, svc=LCDSVC_DrawText8x8Packed, table=DLText_OffMainSub1To3, width=4, x=190, y=68
	dlb_string_xy	var=ModelingPage_Fields+6, mask=0xf0, shift=4, svc=LCDSVC_DrawText8x8Packed, table=DLText_OffMainSub1To3, width=4, x=190, y=93

; === COVER-R1 0xF06598-0xF065E0 ===
; 0xF06598-0xF065DF, coverage round 1: 72 of this span's 72 bytes are
; reachable -- 0 as CODE (an entry point in the routine directory, or a branch
; prom_b's own converted instructions decode) in 0 runs, and 72 as DATA (only
; a `.long` or a 32-bit immediate names it) in 1 run.  Everything else here is
; NOT reachable and stays `.incbin`.  Regenerate: python3
; notes/gen_prom_b_cover_round1.py --splice

; --------------------------------------------------------------------------
; 0xF06598-0xF065DF -- 72 bytes, EMITTED AS DATA (not promoted to code).
; Reached from: 0x00F06598 appears as a 32-bit word at 0xF06500 0xF0651E
;               0xF0652D 0xF0657D 0xF0658E +1 more; converted code at 0xF5C24A
;               loads it as a 32-bit immediate.  No routine-directory slot and
;               no branch decoded in converted code names it.
; Measured: 58% printable ASCII; a linear decode runs 33 instructions and ends
;           `ld (0x00),0x00`, with 12% of the bytes in spellings llvm-mc will
;           not encode.
; ⚠ CORRECTED: that extent came from the coverage walk, not from the object;
;   the display-list records that read these bytes now fix the pieces below
;   (notes/promb-2026-09-25/dlb_table_splitter.py).  The rest of this span
;   is unreachable and stays `.incbin`.  Why this is data and not code: THE
;   PROVENANCE SPLIT in notes/gen_prom_b_cover_round1.py.
; --------------------------------------------------------------------------
; DLText_OffMainSub1To3 -- 0xF06598-0xF065AB, 5 entries of 4 bytes, text
;   drawn by LCD_Svc_06_DrawText8x14 / LCD_Svc_17_DrawText8x8Packed /
;   LCD_Svc_20_DrawText8x10.  Read by the interpreter-B op-0x02/0x07 records
;   at 0xF064F9 ((0x27A8) AND 0x0F >> 0), 0xF06517 ((0x27A9) AND 0x0F >> 0),
;   0xF06526 ((0x27A9) AND 0x0F >> 0), 0xF06576 ((0x27AC) AND 0x0F >> 0) and
;   1 more -- value = (byte at the +2 address) AND mask >> shift -- whose
;   +0x07 names this address; DLB_Handler_StringTable/StringTable2 draws
;   entry [value] with +0x0B = 4 as the width.  Entry count: the text: entry
;   5 would hold 0x00 bytes, as does every slot after it; the masks admit
;   16.  This address is also the END of a display list: `ld XIY,0xF06576 /
;   ld XIX,this / call T_DisplayListB_Run` at 0xF5C24A.
; --------------------------------------------------------------------------
DLText_OffMainSub1To3:
	.ascii	"OFF "	; F06598  [0]
	.ascii	"MAIN"	; F0659C  [1]
	.ascii	"SUB1"	; F065A0  [2]
	.ascii	"SUB2"	; F065A4  [3]
	.ascii	"SUB3"	; F065A8  [4]
; --------------------------------------------------------------------------
; DLBRecordPtrs_F065AC -- 0xF065AC-0xF065DF, 13 32-bit pointers, each to the
;   first byte of an interpreter-B record.  Read by
;   RunDisplayListBFromPointerArray (0xF09AE1: `sla 2,WA / add XIY,XWA / ld
;   XIY,(XIY)`, then ONE record is run) with XIY = this address at 0xF5BFAE,
;   0xF5CE57.  Entry count: the distance to the object's end over 4 -- the
;   reader indexes by A and does not bound it.
; --------------------------------------------------------------------------
DLBRecordPtrs_F065AC:
	.long	Draw_Serial_DL2	; F065AC  [0]
	.long	Draw_Serial_DL2 + 0xA	; F065B0  [1]
	.long	ToneEditPage_A8_RepaintField_DL1	; F065B4  [2]
	.long	ToneEditPage_A8_RepaintField_DL2	; F065B8  [3]
	.long	ToneEditPage_A8_RepaintField_DL2 + 0x1E	; F065BC  [4]
	.long	ToneEditPage_A8_RepaintField_DL2 + 0x1E	; F065C0  [5]
	.long	ToneEditPage_A8_RepaintField_DL2 + 0x1E	; F065C4  [6]
	.long	ToneEditPage_A8_RepaintField_DL2 + 0x1E	; F065C8  [7]
	.long	ToneEditPage_A8_RepaintField_DL2 + 0x1E	; F065CC  [8]
	.long	ToneEditPage_A8_RepaintField_DL2 + 0x1E	; F065D0  [9]
	.long	ToneEditPage_A8_RepaintField_DL3	; F065D4  [10]
	.long	Data_F06562	; F065D8  [11]
	.long	Data_F06562 + 0xA	; F065DC  [12]

; === END COVER-R1 0xF06598-0xF065E0 ===

; ------------------------------------------------------------------
; 0xF065E0-0xF067A5 -- 50 display-list records, 454 bytes -- interpreter A
;   entered at: 0xF065E0, 0xF06601
;   ends used:  0xF06601, 0xF067A6
; ------------------------------------------------------------------
; DL_FilterKeyFollow -- the display list at 0xF065E0.  Its own text records
;                       read: "FILTER KEY FOLLOW".
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_FilterKeyFollow:
	dl_text8x8_packed	x=106, y=195, text="FILTER KEY FOLLOW"
	dl_fill_rect	x0=270, y0=67, x1=306, y1=92
; DL_Lf01Lf02Lf03Lf04Lf0WaveDelay -- the display list at 0xF06601.  Its own
;                                    text records read: "LF01"; "LF02";
;                                    "LF03"; "LF04"; "LF0"; "WAVE"; "DELAY";
;                                    "SPEED" +4 more.
; Evidence: the `.ascii` literals printed below this label, which the display-
;           list interpreter draws verbatim; the name is CamelCase of the
;           first of them and says what the list PUTS ON THE SCREEN and
;           nothing more.  Generated by notes/gen_prom_b_f067a6_module.py
;           --dl-names.
DL_Lf01Lf02Lf03Lf04Lf0WaveDelay:
	dl_text8x14	x=184, y=64, text="LF01"
	dl_text8x14	x=0, y=75, text="\020"
	dl_text8x14	x=184, y=96, text="LF02"
	dl_text8x14	x=0, y=113, text="\020"
	dl_text8x14	x=184, y=126, text="LF03"
	dl_text8x14	x=0, y=152, text="\020"
	dl_text8x14	x=184, y=158, text="LF04"
	dl_text8x14	x=0, y=190, text="\020"
	dl_text8x14	x=32, y=208, text="LF0"
	dl_text8x8_packed	x=96, y=208, text="WAVE"
	dl_text8x8_packed	x=126, y=208, text="DELAY"
	dl_text8x8_packed	x=162, y=208, text="SPEED"
	dl_text8x8_packed	x=198, y=208, text="DEPTH"
	dl_text8x8_packed	x=234, y=208, text="TOUCH"
	dl_text8x8_packed	x=270, y=208, text="KEYSYNC"
	dl_text8x14	x=32, y=220, text="SELECT"
	dl_text8x16	x=56, y=232, text="\022"
	dl_text8x16	x=96, y=232, text="\022"
	dl_text8x16	x=136, y=232, text="\022"
	dl_text8x16	x=176, y=232, text="\022"
	dl_text8x16	x=216, y=232, text="\022"
	dl_text8x16	x=256, y=232, text="\022"
	dl_text8x16	x=296, y=232, text="\022"
	dl_box	x0=44, y0=60, x1=76, y1=77
	dl_box	x0=180, y0=60, x1=220, y1=77
	dl_box	x0=44, y0=91, x1=76, y1=108
	dl_box	x0=180, y0=92, x1=220, y1=109
	dl_box	x0=44, y0=122, x1=76, y1=139
	dl_box	x0=180, y0=122, x1=220, y1=139
	dl_box	x0=44, y0=154, x1=76, y1=171
	dl_box	x0=180, y0=154, x1=220, y1=171
	dl_box	x0=89, y0=204, x1=317, y1=233
	dl_box_shadow1	x0=29, y0=205, x1=82, y1=232
	dl_hline_dither	x0=24, y0=68, x1=44, y1=68
	dl_hline_dither	x0=8, y0=79, x1=24, y1=79
	dl_hline_dither	x0=24, y0=100, x1=44, y1=100
	dl_hline_dither	x0=8, y0=117, x1=24, y1=117
	dl_hline_dither	x0=24, y0=130, x1=44, y1=130
	dl_hline_dither	x0=8, y0=156, x1=24, y1=156
	dl_hline_dither	x0=31, y0=162, x1=44, y1=162
	dl_hline_dither	x0=8, y0=194, x1=31, y1=194
	dl_vline_dashed	x0=24, y0=68, x1=24, y1=79
	dl_vline_dashed	x0=24, y0=100, x1=24, y1=117
	dl_vline_dashed	x0=24, y0=130, x1=24, y1=156
	dl_vline_dashed	x0=31, y0=162, x1=31, y1=194
	dl_hline	x0=89, y0=219, x1=317, y1=219
	dl_fill_rect	x0=278, y0=107, x1=306, y1=120
	dl_fill_rect	x0=90, y0=220, x1=316, y1=232
; ==============================================================================
; 0xF067A6-0xF0C734 -- THE SOUND EDIT SCREEN DATA BLOCK AND THE TWO SCREEN
;   MODULES ABOVE IT.  24,463 bytes; the largest `.incbin` left in the tree.
; ==============================================================================
;
; TWO THINGS WITH A 2,856-BYTE `ret` MOAT BETWEEN THEM.
;
;   0xF067A6-0xF097FF is DATA and not one byte of it is reached by any code
;   walk: the scale-tuning table, the 96 tone-GROUP names, three max-member
;   maps, three (group, member) tables, and one directory-plus-record-pool pair
;   that NOTHING in either image addresses.  Nine of the eleven objects have a
;   located reader in prom_a 0xFC0D70-0xFC25A1; ⚠ TWO DO NOT, and round 1's
;   dossier said eleven -- CORRECTION C1, applied.  The whole span's RAM state
;   is the same handful of cells the painters use: the array at 0x27A6
;   (prom_a Arr27A6_Get / Arr27A6_Set), the flag at 0x27F5 (prom_a Var27F5_Get)
;   and the group/member pair at 0x60F010/0x60F011.
;
;   0xF09800-0xF0C734 is CODE: handlers of the two PARALLEL 48-entry selector
;   tables Dispatch_Code80_PaintTable / Dispatch_Code80_RepaintFieldTable, of prom_a's two
;   computed-call tables at 0xFCF21B (377 entries, 50 in this span) and
;   0xFCF80C (305 entries, 43 in this span), and of eight small `jp (XBC)`
;   tables inside the block itself.
;
; ⚠ WHERE THE BOUNDARIES COME FROM.  notes/prom_b_f067a6_layout.py, re-derived
; on EVERY run of this file and compared segment for segment (27 segments).  Not
; from a linear decode -- notes/prom_a_linear_decode_check.py records why one
; pins nothing.  Content rules run FIRST and become barriers the code walk may
; not enter; the descent is seeded from thunk slots, from every already-proven
; call site, from opcode-anchored far sites whose SITE is not proven data, and
; from the entries of pointer tables whose reader transfers.  Each rule's false
; positives are measured against proven instruction text and proven display-list
; DATA, and the layout's own `--null-*` modes print them.
;
; ⚠ THE FOUR ROUND-1 CORRECTIONS, ALL APPLIED AND ALL PINNED BY --selftest.
;   C1  nine of eleven data objects have a reader, not eleven.  PtrTable_F08134
;       and RecordArray_F08334 have none and keep FRAMED names.
;   C2  22 display-list call sites lie below the first code segment's end, not
;       24; the other 14 are in the SECOND code segment at 0xF09BA0-0xF09D69.
;   C3  0xF09E85-0xF09FFB holds THIRTEEN `link XIZ` routines, not twelve.
;   C4  the 160x3 array at 0xF08334 was quoted on a frame SHIFTED BY 2.
;
; ⚠ AND ONE THING THAT IS NOT THIS SPAN'S.  T_F41F54-T_F421A8 is a 150-slot
; SHARED thunk run that also appears in the prom_a frontier; only FIVE of its
; slots point in here.  It is not described as this block's table.
;
; LAYOUT.  27 segments: 10 code (11298 bytes), 9 pointer tables (848 bytes),
; 5 `.byte` data runs (7835 bytes), 1 string table (1536 bytes) and 2 runs of
; 0x0E `ret` padding (2946 bytes).  Substantive: 21517 of 24463.
;
; LABELS.  176, of which 32 carry a name derived from something and 144 are
; sub_XXXXXX with the gap stated.  The 9733 bytes of code from 0xF0A000 up, in
; 8 segments, are reached only through prom_a's two computed-call tables, and
; nothing decoded here says what their indices enumerate, so nothing there is
; named.
;
; WHAT THE BLOCK TOUCHES, measured over the transcription itself.
; Heaviest 16-bit RAM words: (0x2540) x45 (0x27F5) x7 (0x27B6) x7 (0x27B5) x2 (0x27A6) x1 (0x27B0) x1.
; Heaviest absolute operands: 0xF32FC8 x6 0xFC52B4 x6 0xF32FA0 x5 0xF32FE6 x4 0xF32F43 x3.
; That is a measurement of what the code ADDRESSES, not a claim about what it
; IS, and no routine is named on the strength of it.
;
; REGENERATE:  python3 notes/gen_prom_b_f067a6_module.py
; CHECKS:      python3 notes/gen_prom_b_f067a6_module.py --checks
; NAMES:       python3 notes/gen_prom_b_f067a6_module.py --names
; ==============================================================================

	.fill	90, 1, 0x0E	; F067A6-F067FF  `ret` padding (asserted pure 0x0E)
