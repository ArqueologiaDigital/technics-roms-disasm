
; ==============================================================================
; 0xF7D000-0xF7E2D7 -- A STUB BLOCK AND 32 TABLES OF 32 ROUTINE POINTERS
; ==============================================================================
;
; 728 bytes of stubs, then 4,096 bytes that are exactly 32 tables of 32 32-bit
; routine pointers.  Two of the thunk table's busier slots name entries 0 and 2
; of the veneer table: T_F431B0 -> 0xF7D000 (53 opcode-anchored references) and
; T_F431B4 -> 0xF7D006 (57).  So the WSA1's routine directory reaches prom_a
; 0xF81ACB and 0xF81C15 through TWO levels of veneer.
;
; ★★ WHAT THE BLOCK IS, established in round 7: the 104 entry points the routine
; directory names here are the METHODS OF 25 PANEL-SCREEN OBJECTS, plus the
; 8-entry veneer table.  prom_a's PanelScreen_VtableTable (0xF86EC1, already
; documented there) holds 25 pointers into the directory run 0xF43040-0xF431AF,
; in four-word runs, and its readers take +0 Enter, +4 Leave, +8 Button.  Each
; run's four stubs occupy one contiguous byte extent of this block.  Every label
; below carries the screen object it belongs to.  Re-derive all of it with
;     python3 notes/prom_b_entrypoints_round7.py --runs --selftest
;
; THE STUBS come in FOUR shapes.  ⚠ THIS PARAGRAPH USED TO SAY THREE "and
; nothing else", and it omitted the commonest one; the census is
; `--blockshapes`, which counts entry points, not lines:
;   * 0xF7D000-0xF7D017: eight `jrl T,nnn` long-branch veneers, 3 bytes each,
;     every one into prom_a 0xF81ACB-0xF81E7E.  A linker branch island.
;   * `calr`/`call <routine>` followed by `ret` -- a one-line forwarder (48).
;   * `ld XIX,<one of the 32 tables>` (sometimes choosing between two on
;     `cp (0x207E),0x00` or `cp (0x0C10),0x00`), then `call 0xF41B08`, then `ret`
;     (18, and every one of them is a screen object's +8 Button word).
;   * a NO-OP: a bare `ret`, or `calr <an address holding one ret>` then `ret`
;     (27).  All 23 of the runs' fourth words are of this shape, and no reader
;     of +0x0C exists -- prom_a's four vtable readers apply only +0, +4 and +8.
;
; WHY THE TABLES ARE 32 ENTRIES.  T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5, which is
;     cp HL,0x1F / jr UGT,<ret> / ... / and L,0x1F / sla 2,L /
;     ld XIX,(XIX+L) / call XIX
; -- a bounds-checked call of entry HL of the table in XIX, with the index masked
; to 5 bits.  32 entries, 4 bytes each, 128 bytes per table.
;
; WHY THERE ARE EXACTLY 32 TABLES.  Three independent counts agree:
;   * scanning 0xF7D2D8 upward in 128-byte blocks, the first 32 blocks are
;     entirely 0x00F00000-0x00FFFFFF words and the 33rd (0xF7E2D8) is not --
;     its first word is 0x2100230E, and the bytes there disassemble as code;
;   * the stub block contains exactly 32 `ld XIX,imm32` instructions, and their
;     32 immediates are exactly the 32 table bases, each named once;
;   * the highest of those immediates is 0xF7E258 = 0xF7D2D8 + 31*0x80, the last
;     table, and 0xF7E258 + 0x80 = 0xF7E2D8 is where the block ends.
;
; ★ WHAT THE 32 TABLES ENUMERATE, established in round 7: PANEL BUTTONS, and the
; index HL is the button number.  Every `ld XIX,<table>` stub is the +8 word of a
; PanelScreen_VtableTable entry; prom_a's PanelButton_Route is the only reader of
; +8 and masks the button index with `and L,0x1f` at 0xF861AE; the stub's callee
; T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the SAME five bits.  Two independent 5-bit
; masks and a 128-byte table: 32 buttons, one table per screen (two where the
; screen has an alternate map).
; (0x207E) is UI_ScreenStage (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md):
; on the job screens 0 is the parameter page and 1 the "Are You Sure ?" page that
; the first press of the execute key opens; it picks the button map (_StageZero /
; _StageNonZero) and the title lists.
; ⚠ STILL NOT ESTABLISHED: what (0x0C10) MEANS -- which of a screen's two
; button maps it picks, and when.
; ==============================================================================

; ---------------------------------------------------------------------
; StubBlock_F7D000 -- long-branch veneers and one-line forwarders
; Called from: thunks T_F431B0 (0xF7D000, x53) and T_F431B4 (0xF7D006, x57);
;              the rest not yet traced to a specific caller
; Inputs:  pass-through; the table stubs additionally expect HL = the index that
;          prom_a 0xF8BDC5 bounds-checks against 0x1F
; Outputs: pass-through
; Evidence: every instruction in these 728 bytes is one of `jrl`, `calr`, `call`,
;           `ret`, `ld XIX,imm32`, `cp (mem),0x00`, `jr Z`, one `bit` and THREE
;           `ld BC,HL` (0xF7D1AE, 0xF7D2BE, 0xF7D2D0).  ⚠ This line used to say
;           "one `ld BC,HL`"; the count is `--blockshapes`, which also prints the
;           full mnemonic census: ret 96, call 63, ld 38, jr 20, calr 17, cp 17,
;           jrl 8, bit 1.
;           Round-tripped through llvm-mc by notes/llvm_roundtrip_force.py:
;           260 instructions, 246 encoded, 14 left as .byte.
; Unknown:  what any individual stub selects.  This label now covers only the
;           8 `jrl` veneers; the other 96 entry points carry their own labels.
;           The veneers are written `jrl Target - next_pc`: llvm-mc takes a relative operand to a
;           symbol of the other image (an absolute `.set`) only as a constant displacement.
; ---------------------------------------------------------------------
StubBlock_F7D000:
	jrl	Paint_StepRecord - 0xF7D003	; F7D000  jrl T,0xf81acb
; Evidence: a 3-byte `jrl` long-branch veneer, slot of the 0xF7D000 veneer table;
;           destination prom_a 0xF81BD4.  Named for the destination only.  [round7-entrypoints]
Veneer_Paint_StepRecordTrackClrMeas:
	jrl	Paint_StepRecordTrackClrMeas - 0xF7D006	; F7D003  jrl T,0xf81bd4
; Evidence: a 3-byte `jrl` long-branch veneer, slot of the 0xF7D000 veneer table;
;           destination prom_a 0xF81C15.  Named for the destination only.  [round7-entrypoints]
Veneer_F81C15:
	jrl	sub_F81C15 - 0xF7D009	; F7D006  jrl T,0xf81c15
; Evidence: a 3-byte `jrl` long-branch veneer, slot of the 0xF7D000 veneer table;
;           destination prom_a 0xF81E7C.  Named for the destination only.  [round7-entrypoints]
Veneer_F81E7C:
	jrl	LCD_ClearLayer2_32Cols10Rows_Nop - 0xF7D00C	; F7D009  jrl T,0xf81e7c
; Evidence: a 3-byte `jrl` long-branch veneer, slot of the 0xF7D000 veneer table;
;           destination prom_a 0xF81D41.  Named for the destination only.  [round7-entrypoints]
Veneer_F81D41:
	jrl	sub_F81D41 - 0xF7D00F	; F7D00C  jrl T,0xf81d41
; Evidence: a 3-byte `jrl` long-branch veneer, slot of the 0xF7D000 veneer table;
;           destination prom_a 0xF81C33.  Named for the destination only.  [round7-entrypoints]
Veneer_F81C33:
	jrl	sub_F81C33 - 0xF7D012	; F7D00F  jrl T,0xf81c33
; Evidence: a 3-byte `jrl` long-branch veneer, slot of the 0xF7D000 veneer table;
;           destination prom_a 0xF81C90.  Named for the destination only.  [round7-entrypoints]
Veneer_F81C90:
	jrl	sub_F81C90 - 0xF7D015	; F7D012  jrl T,0xf81c90
; Evidence: a 3-byte `jrl` long-branch veneer, slot of the 0xF7D000 veneer table;
;           destination prom_a 0xF81E7E.  Named for the destination only.  [round7-entrypoints]
Veneer_F81E7E:
	jrl	sub_F81E7E - 0xF7D018	; F7D015  jrl T,0xf81e7e
; Evidence: the +0 word of screen object F43040, which prom_a's PanelScreen_VtableTable
;           names at 0xF86EDD.  ⚠ NO NAME: its body reaches no display list, so nothing says which screen this is.  [round7-entrypoints]
; ModeEnter_Edit: the +0 ENTER of panel mode 7 (T_ModeEnter_Edit); PanelMode_ToScreenIdMap[7] = 0x1A, ScreenEnter_Edit's screen.
ModeEnter_Edit:
	calr	ModeEnterBody_Edit	; F7D018  calr 0xf7e971
	ret	; F7D01B  ret
; Evidence: the +4 word of screen object F43040 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF7E97C` then `ret`.  [round7-entrypoints]
sub_F7D01C:
	calr	sub_F7E97C	; F7D01C  calr 0xf7e97c
	ret	; F7D01F  ret
; Evidence: the +0 word of screen object F43048, which prom_a's PanelScreen_VtableTable
;           names at 0xF86ED9.  ⚠ NO NAME: its body reaches no display list, so nothing says which screen this is.  [round7-entrypoints]
; ModeEnter_StepRecord: the +0 ENTER of panel mode 6 (T_ModeEnter_StepRecord); PanelMode_ToScreenIdMap[6] = 0x0F, StepRecordPartSelect.
ModeEnter_StepRecord:
	call	ModeEnterBody_StepRecord	; F7D020  call 0xf80f3a
	ret	; F7D024  ret
; Evidence: the +4 word of screen object F43048 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF80F4F` then `ret`.  [round7-entrypoints]
sub_F7D025:
	call	sub_F80F4F	; F7D025  call 0xf80f4f
	ret	; F7D029  ret

; ---------------------------------------------------------------------
; Screen object F43050 -- the panel screen whose own title text reads "EDIT"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF43050 at 0xF86FA9, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF7E987` -- prom_b, still inside the 0xF7E2D8 .incbin.
;        That routine draws display list 0xF39D3E, whose leading
;        op-0x1C records spell
;        "EDIT" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        one of two 32-entry tables, 0xF7D2D8 and 0xF7D358, chosen
;        on (0x0C10).
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F39D3E` immediate inside 0xF7E987, decoded from
;           the ROM -- NOT visible here, that routine is still .incbin;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Unknown:  what (0x0C10) MEANS -- which of this screen's two button
;           maps it picks, and when.
;           Also unknown: what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_Edit:
	calr	Paint_Edit	; F7D02A  calr 0xf7e987
	ret	; F7D02D  ret
; Evidence: the +4 word of screen object F43050 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  [round7-entrypoints]
ScreenLeave_Edit:
	calr	ButtonTable_Edit_0C10Zero_Nop0	; F7D02E  calr 0xf7e9c7
	ret	; F7D031  ret
; Evidence: the +8 word of screen object F43050 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button tables at 0xF7D2D8 / 0xF7D358 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_Edit:
	ld	xix, ButtonTable_Edit_0C10Zero	; F7D032  ld XIX,0x00f7d2d8
	cp	(0x0c10:16), 0x00	; F7D037  cp (0x0c10),0x00
	jr	z, ScreenButton_Edit_Skip2	; F7D03C  jr Z,0xf7d043
	ld	xix, ButtonTable_Edit_0C10NonZero	; F7D03E  ld XIX,0x00f7d358
ScreenButton_Edit_Skip2:
	call	T_PanelButton_CallTableEntry	; F7D043  call 0xf41b08
	ret	; F7D047  ret
; Evidence: the +0x0C word of screen object F43050 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_Edit:
	calr	ScreenNull_Edit_Nop	; F7D048  calr 0xf7ea55
	ret	; F7D04B  ret

; ---------------------------------------------------------------------
; Screen object F43060 -- the panel screen whose own title text reads "SONG CLEAR"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF43060 at 0xF86FAD, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF7EAD0` -- prom_b, still inside the 0xF7E2D8 .incbin.
;        That routine draws display list 0xF399D5, whose leading
;        op-0x1C records spell
;        "SONG CLEAR" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        the 32-entry table 0xF7D3D8.
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F399D5` immediate inside 0xF7EAD0, decoded from
;           the ROM -- NOT visible here, that routine is still .incbin;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Unknown:  nothing selects between maps here: this screen has ONE
;           button table, 0xF7D3D8.
;           Also unknown: what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_SongClear:
	calr	Paint_SongClear	; F7D04C  calr 0xf7ead0
	ret	; F7D04F  ret
; Evidence: the +4 word of screen object F43060 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF7EBD8` then `ret`.  [round7-entrypoints]
ScreenLeave_SongClear:
	calr	ScreenLeaveBody_SongClear	; F7D050  calr 0xf7ebd8
	ret	; F7D053  ret
; Evidence: the +8 word of screen object F43060 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button table at 0xF7D3D8 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_SongClear:
	ld	xix, ButtonTable_SongClear	; F7D054  ld XIX,0x00f7d3d8
	call	T_PanelButton_CallTableEntry	; F7D059  call 0xf41b08
	ret	; F7D05D  ret
; Evidence: the +0x0C word of screen object F43060 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_SongClear:
	calr	ScreenNull_SongClear_Nop	; F7D05E  calr 0xf7ec70
	ret	; F7D061  ret

; ---------------------------------------------------------------------
; Screen object F43070 -- the panel screen whose own title text reads "TRACK CLEAR"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF43070 at 0xF86FB1, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF7EC71` -- prom_b, still inside the 0xF7E2D8 .incbin.
;        That routine draws display list 0xF39F8A, whose leading
;        op-0x1C records spell
;        "TRACK CLEAR" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        one of two 32-entry tables, 0xF7D458 and 0xF7D4D8, chosen
;        on (0x207E).
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F39F8A` immediate inside 0xF7EC71, decoded from
;           the ROM -- NOT visible here, that routine is still .incbin;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Map:      (0x207E) = UI_ScreenStage picks the button map: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page.
; Unknown:  what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_TrackClear:
	calr	Paint_TrackClear	; F7D062  calr 0xf7ec71
	ret	; F7D065  ret
; Evidence: the +4 word of screen object F43070 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF7ECFA` then `ret`.  [round7-entrypoints]
ScreenLeave_TrackClear:
	calr	ScreenLeaveBody_TrackClear	; F7D066  calr 0xf7ecfa
	ret	; F7D069  ret
; Evidence: the +8 word of screen object F43070 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button tables at 0xF7D458 / 0xF7D4D8 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_TrackClear:
	ld	xix, ButtonTable_TrackClear_StageZero	; F7D06A  ld XIX,0x00f7d458
	cp	(UI_ScreenStage:16), 0x00	; F7D06F  cp (0x207e),0x00
	jr	z, ScreenButton_TrackClear_Skip3	; F7D074  jr Z,0xf7d07b
	ld	xix, ButtonTable_TrackClear_StageNonZero	; F7D076  ld XIX,0x00f7d4d8
ScreenButton_TrackClear_Skip3:
	call	T_PanelButton_CallTableEntry	; F7D07B  call 0xf41b08
	ret	; F7D07F  ret
; Evidence: the +0x0C word of screen object F43070 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_TrackClear:
	calr	ButtonTable_TrackClear_StageNonZero_Nop16	; F7D080  calr 0xf7ee07
	ret	; F7D083  ret

; ---------------------------------------------------------------------
; Screen object F43140 -- the panel screen whose own title text reads "TRACK ASSIGN"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF43140 at 0xF86F81, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF7E440` -- prom_b, still inside the 0xF7E2D8 .incbin.
;        That routine draws display list 0xF3B3DA, whose leading
;        op-0x1C records spell
;        "TRACK ASSIGN" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        one of two 32-entry tables, 0xF7D558 and 0xF7D5D8, chosen
;        on (0x207E).
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3B3DA` immediate inside 0xF7E440, decoded from
;           the ROM -- NOT visible here, that routine is still .incbin;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Map:      (0x207E) = UI_ScreenStage picks the button map: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page.
; Unknown:  what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_TrackAssign:
	calr	Paint_TrackAssign	; F7D084  calr 0xf7e440
	ret	; F7D087  ret
; Evidence: the +4 word of screen object F43140 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF7E4F9` then `ret`.  [round7-entrypoints]
ScreenLeave_TrackAssign:
	calr	ScreenLeaveBody_TrackAssign	; F7D088  calr 0xf7e4f9
	ret	; F7D08B  ret
; Evidence: the +8 word of screen object F43140 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button tables at 0xF7D558 / 0xF7D5D8 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_TrackAssign:
	ld	xix, ButtonTable_TrackAssign_StageZero	; F7D08C  ld XIX,0x00f7d558
	cp	(UI_ScreenStage:16), 0x00	; F7D091  cp (0x207e),0x00
	jr	z, ScreenButton_TrackAssign_Skip4	; F7D096  jr Z,0xf7d09d
	ld	xix, ButtonTable_TrackAssign_StageNonZero	; F7D098  ld XIX,0x00f7d5d8
ScreenButton_TrackAssign_Skip4:
	call	T_PanelButton_CallTableEntry	; F7D09D  call 0xf41b08
	ret	; F7D0A1  ret
; Evidence: the +0x0C word of screen object F43140 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_TrackAssign:
	calr	ScreenNull_TrackAssign_Nop	; F7D0A2  calr 0xf7e600
	ret	; F7D0A5  ret

; ---------------------------------------------------------------------
; Screen object F43190 -- the panel screen whose own title text reads "TRACK ASSIGN PRESETS"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF43190 at 0xF86F85, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF7E601` -- prom_b, still inside the 0xF7E2D8 .incbin.
;        That routine draws display list 0xF3A2BF, whose leading
;        op-0x1C records spell
;        "TRACK ASSIGN PRESETS" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        the 32-entry table 0xF7D658.
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3A2BF` immediate inside 0xF7E601, decoded from
;           the ROM -- NOT visible here, that routine is still .incbin;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Unknown:  nothing selects between maps here: this screen has ONE
;           button table, 0xF7D658.
;           Also unknown: what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_TrackAssignPresets:
	calr	Paint_TrackAssignPresets	; F7D0A6  calr 0xf7e601
	ret	; F7D0A9  ret
; Evidence: the +4 word of screen object F43190 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF7E67A` then `ret`.  [round7-entrypoints]
ScreenLeave_TrackAssignPresets:
	calr	ScreenLeaveBody_TrackAssignPresets	; F7D0AA  calr 0xf7e67a
	ret	; F7D0AD  ret
; Evidence: the +8 word of screen object F43190 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button table at 0xF7D658 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_TrackAssignPresets:
	ld	xix, ButtonTable_TrackAssignPresets	; F7D0AE  ld XIX,0x00f7d658
	call	T_PanelButton_CallTableEntry	; F7D0B3  call 0xf41b08
	ret	; F7D0B7  ret
; Evidence: the +0x0C word of screen object F43190 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_TrackAssignPresets:
	calr	ScreenNull_TrackAssignPresets_Nop	; F7D0B8  calr 0xf7e76f
	ret	; F7D0BB  ret

; ---------------------------------------------------------------------
; Screen object F430A0 -- the panel screen whose own title text reads "TRACK MERGE"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF430A0 at 0xF86FBD, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF7EE08` -- prom_b, still inside the 0xF7E2D8 .incbin.
;        That routine draws display list 0xF3A47F, whose leading
;        op-0x1C records spell
;        "TRACK MERGE" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        one of two 32-entry tables, 0xF7D6D8 and 0xF7D758, chosen
;        on (0x207E).
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3A47F` immediate inside 0xF7EE08, decoded from
;           the ROM -- NOT visible here, that routine is still .incbin;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Map:      (0x207E) = UI_ScreenStage picks the button map: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page.
; Unknown:  what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_TrackMerge:
	call	Paint_TrackMerge	; F7D0BC  call 0xf7ee08
	ret	; F7D0C0  ret
; Evidence: the +4 word of screen object F430A0 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF7EE96` then `ret`.  [round7-entrypoints]
ScreenLeave_TrackMerge:
	call	ScreenLeaveBody_TrackMerge	; F7D0C1  call 0xf7ee96
	ret	; F7D0C5  ret
; Evidence: the +8 word of screen object F430A0 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button tables at 0xF7D6D8 / 0xF7D758 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_TrackMerge:
	ld	xix, ButtonTable_TrackMerge_StageZero	; F7D0C6  ld XIX,0x00f7d6d8
	cp	(UI_ScreenStage:16), 0x00	; F7D0CB  cp (0x207e),0x00
	jr	z, ScreenButton_TrackMerge_Skip5	; F7D0D0  jr Z,0xf7d0d7
	ld	xix, ButtonTable_TrackMerge_StageNonZero	; F7D0D2  ld XIX,0x00f7d758
ScreenButton_TrackMerge_Skip5:
	call	T_PanelButton_CallTableEntry	; F7D0D7  call 0xf41b08
	ret	; F7D0DB  ret
; Evidence: the +0x0C word of screen object F430A0 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_TrackMerge:
	ret	; F7D0DC  ret

; ---------------------------------------------------------------------
; Screen object F430E0 -- the panel screen whose own title text reads "MEASURE DELETE"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF430E0 at 0xF86FCD, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF7EF7C` -- prom_b, still inside the 0xF7E2D8 .incbin.
;        That routine draws display list 0xF3A5E9, whose leading
;        op-0x1C records spell
;        "MEASURE DELETE" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        one of two 32-entry tables, 0xF7D7D8 and 0xF7D858, chosen
;        on (0x207E).
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3A5E9` immediate inside 0xF7EF7C, decoded from
;           the ROM -- NOT visible here, that routine is still .incbin;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Map:      (0x207E) = UI_ScreenStage picks the button map: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page.
; Unknown:  what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_MeasureDelete:
	call	Paint_MeasureDelete	; F7D0DD  call 0xf7ef7c
	ret	; F7D0E1  ret
; Evidence: the +4 word of screen object F430E0 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF7F031` then `ret`.  [round7-entrypoints]
ScreenLeave_MeasureDelete:
	call	ScreenLeaveBody_MeasureDelete	; F7D0E2  call 0xf7f031
	ret	; F7D0E6  ret
; Evidence: the +8 word of screen object F430E0 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button tables at 0xF7D7D8 / 0xF7D858 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_MeasureDelete:
	ld	xix, ButtonTable_MeasureDelete_StageZero	; F7D0E7  ld XIX,0x00f7d7d8
	cp	(UI_ScreenStage:16), 0x00	; F7D0EC  cp (0x207e),0x00
	jr	z, ScreenButton_MeasureDelete_Skip6	; F7D0F1  jr Z,0xf7d0f8
	ld	xix, ButtonTable_MeasureDelete_StageNonZero	; F7D0F3  ld XIX,0x00f7d858
ScreenButton_MeasureDelete_Skip6:
	call	T_PanelButton_CallTableEntry	; F7D0F8  call 0xf41b08
	ret	; F7D0FC  ret
; Evidence: the +0x0C word of screen object F430E0 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_MeasureDelete:
	ret	; F7D0FD  ret

; ---------------------------------------------------------------------
; Screen object F430B0 -- the panel screen whose own title text reads "MEASURE ERASE"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF430B0 at 0xF86FC1, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF7F254` -- prom_b, still inside the 0xF7E2D8 .incbin.
;        That routine draws display list 0xF3A8F5, whose leading
;        op-0x1C records spell
;        "MEASURE ERASE" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        one of two 32-entry tables, 0xF7D8D8 and 0xF7D958, chosen
;        on (0x207E).
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3A8F5` immediate inside 0xF7F254, decoded from
;           the ROM -- NOT visible here, that routine is still .incbin;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Map:      (0x207E) = UI_ScreenStage picks the button map: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page.
; Unknown:  what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_MeasureErase:
	call	Paint_MeasureErase	; F7D0FE  call 0xf7f254
	ret	; F7D102  ret
; Evidence: the +4 word of screen object F430B0 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF7F2D5` then `ret`.  [round7-entrypoints]
ScreenLeave_MeasureErase:
	call	ScreenLeaveBody_MeasureErase	; F7D103  call 0xf7f2d5
	ret	; F7D107  ret
; Evidence: the +8 word of screen object F430B0 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button tables at 0xF7D8D8 / 0xF7D958 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_MeasureErase:
	ld	xix, ButtonTable_MeasureErase_StageZero	; F7D108  ld XIX,0x00f7d8d8
	cp	(UI_ScreenStage:16), 0x00	; F7D10D  cp (0x207e),0x00
	jr	z, ScreenButton_MeasureErase_Skip7	; F7D112  jr Z,0xf7d119
	ld	xix, ButtonTable_MeasureErase_StageNonZero	; F7D114  ld XIX,0x00f7d958
ScreenButton_MeasureErase_Skip7:
	call	T_PanelButton_CallTableEntry	; F7D119  call 0xf41b08
	ret	; F7D11D  ret
; Evidence: the +0x0C word of screen object F430B0 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_MeasureErase:
	ret	; F7D11E  ret

; ---------------------------------------------------------------------
; Screen object F43130 -- the panel screen whose own title text reads "PANEL WRITE"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF43130 at 0xF86FF9, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF7F536` -- prom_b, still inside the 0xF7E2D8 .incbin.
;        That routine draws display list 0xF3AD88, whose leading
;        op-0x1C records spell
;        "PANEL WRITE" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3AD88` immediate inside 0xF7F536, decoded from
;           the ROM -- NOT visible here, that routine is still .incbin;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Unknown:  this screen's +8 word is NOT a table dispatch -- its stub
;           is transcribed below, and what it dispatches on is unread.
;           Also unknown: what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_PanelWrite:
	call	Paint_PanelWrite	; F7D11F  call 0xf7f536
	ret	; F7D123  ret
; Evidence: the +4 word of screen object F43130 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  [round7-entrypoints]
ScreenLeave_PanelWrite:
	call	ScreenLeave_PanelWrite_Nop	; F7D124  call 0xf7f558
	ret	; F7D128  ret
; Evidence: the +8 word of screen object F43130 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF7F559` then `ret`.  [round7-entrypoints]
ScreenButton_PanelWrite:
	call	ScreenButtonBody_PanelWrite	; F7D129  call 0xf7f559
	ret	; F7D12D  ret
; Evidence: the +0x0C word of screen object F43130 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_PanelWrite:
	ret	; F7D12E  ret

; ---------------------------------------------------------------------
; Screen object F43090 -- the panel screen whose own title text reads "QUANTIZE"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF43090 at 0xF86FB9, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF7F582` -- prom_b, still inside the 0xF7E2D8 .incbin.
;        That routine draws display list 0xF3ABDB, whose leading
;        op-0x1C records spell
;        "QUANTIZE" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        one of two 32-entry tables, 0xF7D9D8 and 0xF7DA58, chosen
;        on (0x207E).
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3ABDB` immediate inside 0xF7F582, decoded from
;           the ROM -- NOT visible here, that routine is still .incbin;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Map:      (0x207E) = UI_ScreenStage picks the button map: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page.
; Unknown:  what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_Quantize:
	call	Paint_Quantize	; F7D12F  call 0xf7f582
	ret	; F7D133  ret
; Evidence: the +4 word of screen object F43090 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF7F603` then `ret`.  [round7-entrypoints]
ScreenLeave_Quantize:
	call	ScreenLeaveBody_Quantize	; F7D134  call 0xf7f603
	ret	; F7D138  ret
; Evidence: the +8 word of screen object F43090 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button tables at 0xF7D9D8 / 0xF7DA58 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_Quantize:
	ld	xix, ButtonTable_Quantize_StageZero	; F7D139  ld XIX,0x00f7d9d8
	cp	(UI_ScreenStage:16), 0x00	; F7D13E  cp (0x207e),0x00
	jr	z, ScreenButton_Quantize_Skip8	; F7D143  jr Z,0xf7d14a
	ld	xix, ButtonTable_Quantize_StageNonZero	; F7D145  ld XIX,0x00f7da58
ScreenButton_Quantize_Skip8:
	call	T_PanelButton_CallTableEntry	; F7D14A  call 0xf41b08
	ret	; F7D14E  ret
; Evidence: the +0x0C word of screen object F43090 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_Quantize:
	ret	; F7D14F  ret

; ---------------------------------------------------------------------
; Screen object F43080 -- the panel screen whose own title text reads "VEL0CITY CHANGE"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF43080 at 0xF86FB5, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF7F8A9` -- prom_b, still inside the 0xF7E2D8 .incbin.
;        That routine draws display list 0xF3AA54, whose leading
;        op-0x1C records spell
;        "VEL0CITY CHANGE" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        one of two 32-entry tables, 0xF7DAD8 and 0xF7DB58, chosen
;        on (0x207E).
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3AA54` immediate inside 0xF7F8A9, decoded from
;           the ROM -- NOT visible here, that routine is still .incbin;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Map:      (0x207E) = UI_ScreenStage picks the button map: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page.
; Unknown:  what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_Vel0cityChange:
	call	Paint_Vel0cityChange	; F7D150  call 0xf7f8a9
	ret	; F7D154  ret
; Evidence: the +4 word of screen object F43080 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF7F94F` then `ret`.  [round7-entrypoints]
ScreenLeave_Vel0cityChange:
	call	ScreenLeaveBody_Vel0cityChange	; F7D155  call 0xf7f94f
	ret	; F7D159  ret
; Evidence: the +8 word of screen object F43080 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button tables at 0xF7DAD8 / 0xF7DB58 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_Vel0cityChange:
	ld	xix, ButtonTable_Vel0cityChange_StageZero	; F7D15A  ld XIX,0x00f7dad8
	cp	(UI_ScreenStage:16), 0x00	; F7D15F  cp (0x207e),0x00
	jr	z, ScreenButton_Vel0cityChange_Skip9	; F7D164  jr Z,0xf7d16b
	ld	xix, ButtonTable_Vel0cityChange_StageNonZero	; F7D166  ld XIX,0x00f7db58
ScreenButton_Vel0cityChange_Skip9:
	call	T_PanelButton_CallTableEntry	; F7D16B  call 0xf41b08
	ret	; F7D16F  ret
; Evidence: the +0x0C word of screen object F43080 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_Vel0cityChange:
	ret	; F7D170  ret

; ---------------------------------------------------------------------
; Screen object F43100 -- the panel screen whose own title text reads "TRANSP0SE"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF43100 at 0xF86FED, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF7FBF8` -- prom_b, still inside the 0xF7E2D8 .incbin.
;        That routine draws display list 0xF3B102, whose leading
;        op-0x1C records spell
;        "TRANSP0SE" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        one of two 32-entry tables, 0xF7DBD8 and 0xF7DC58, chosen
;        on (0x207E).
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3B102` immediate inside 0xF7FBF8, decoded from
;           the ROM -- NOT visible here, that routine is still .incbin;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Map:      (0x207E) = UI_ScreenStage picks the button map: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page.
; Unknown:  what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_Transp0se:
	call	Paint_Transp0se	; F7D171  call 0xf7fbf8
	ret	; F7D175  ret
; Evidence: the +4 word of screen object F43100 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF7FC99` then `ret`.  [round7-entrypoints]
ScreenLeave_Transp0se:
	call	ScreenLeaveBody_Transp0se	; F7D176  call 0xf7fc99
	ret	; F7D17A  ret
; Evidence: the +8 word of screen object F43100 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button tables at 0xF7DBD8 / 0xF7DC58 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_Transp0se:
	ld	xix, ButtonTable_Transp0se_StageZero	; F7D17B  ld XIX,0x00f7dbd8
	cp	(UI_ScreenStage:16), 0x00	; F7D180  cp (0x207e),0x00
	jr	z, ScreenButton_Transp0se_Skip10	; F7D185  jr Z,0xf7d18c
	ld	xix, ButtonTable_Transp0se_StageNonZero	; F7D187  ld XIX,0x00f7dc58
ScreenButton_Transp0se_Skip10:
	call	T_PanelButton_CallTableEntry	; F7D18C  call 0xf41b08
	ret	; F7D190  ret
; Evidence: the +0x0C word of screen object F43100 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_Transp0se:
	ret	; F7D191  ret

; ---------------------------------------------------------------------
; Screen object F43180 -- the panel screen whose own title text reads "AFTER T0UCH SETTING"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF43180 at 0xF86F6D, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF7E3F5` -- prom_b, still inside the 0xF7E2D8 .incbin.
;        That routine draws display list 0xF3BAB9, whose leading
;        op-0x1C records spell
;        "AFTER T0UCH SETTING" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3BAB9` immediate inside 0xF7E3F5, decoded from
;           the ROM -- NOT visible here, that routine is still .incbin;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Unknown:  this screen's +8 word is NOT a table dispatch -- its stub
;           is transcribed below, and what it dispatches on is unread.
;           Also unknown: what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_AfterT0uchSetting:
	call	Paint_AfterT0uchSetting	; F7D192  call 0xf7e3f5
	ret	; F7D196  ret
; Evidence: the +4 word of screen object F43180 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  [round7-entrypoints]
ScreenLeave_AfterT0uchSetting:
	call	ScreenLeave_AfterT0uchSetting_Nop	; F7D197  call 0xf7e43f
	ret	; F7D19B  ret
; Evidence: the +8 word of screen object F43180 (prom_a's PanelScreen_VtableTable);
;           its body is transcribed below.  [round7-entrypoints]
ScreenButton_AfterT0uchSetting:
	cp	hl, 15	; F7D19C  cp HL,0x000f
	jr	z, ScreenButton_AfterT0uchSetting_Skip12	; F7D1A0  jr Z,0xf7d1c6
	cp	hl, 10	; F7D1A2  cp HL,0x000a
	jr	z, ScreenButton_AfterT0uchSetting_Skip11	; F7D1A6  jr Z,0xf7d1ae
	cp	hl, 11	; F7D1A8  cp HL,0x000b
	jr	nz, ScreenButton_AfterT0uchSetting_Return2	; F7D1AC  jr NZ,0xf7d1d3
ScreenButton_AfterT0uchSetting_Skip11:
	ld	bc, hl	; F7D1AE  ld BC,HL
	call	T_AfterT0uchSetting_SetRecordEnable	; F7D1B0  call 0xf42bec
	call	AfterT0uchSetting_EraseRecordValue	; F7D1B4  call 0xf7e430
	ld	a, (32706:16)	; F7D1B8  ld A,(0x7fc2)
	ld	(DisplayListB_Stage:16), a	; F7D1BC  ld (0x12f6),A
	call	Draw_AfterTouchRecord	; F7D1C0  call 0xf7e421
	jr	ScreenButton_AfterT0uchSetting_Return2	; F7D1C4  jr T,0xf7d1d3
ScreenButton_AfterT0uchSetting_Skip12:
	bit	7, w	; F7D1C6  bit 0x07,W
	jr	nz, ScreenButton_AfterT0uchSetting_Return2	; F7D1C9  jr NZ,0xf7d1d3
	ldw	(UI_Request:16), 32772	; F7D1CB  ld (0x2070),0x8004
	jr	ScreenButton_AfterT0uchSetting_Return2	; F7D1D1  jr T,0xf7d1d3
ScreenButton_AfterT0uchSetting_Return2:
	ret	; F7D1D3  ret
; Evidence: the +0x0C word of screen object F43180 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_AfterT0uchSetting:
	ret	; F7D1D4  ret

; ---------------------------------------------------------------------
; Screen object F43110 -- the panel screen whose own title text reads "ADVANCE/DELAY"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF43110 at 0xF86FF1, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF7FF27` -- prom_b, still inside the 0xF7E2D8 .incbin.
;        That routine draws display list 0xF3B294, whose leading
;        op-0x1C records spell
;        "ADVANCE/DELAY" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        one of two 32-entry tables, 0xF7DCD8 and 0xF7DD58, chosen
;        on (0x207E).
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3B294` immediate inside 0xF7FF27, decoded from
;           the ROM -- NOT visible here, that routine is still .incbin;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Map:      (0x207E) = UI_ScreenStage picks the button map: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page.
; Unknown:  what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_AdvanceDelay:
	call	Paint_AdvanceDelay	; F7D1D5  call 0xf7ff27
	ret	; F7D1D9  ret
; Evidence: the +4 word of screen object F43110 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF7FFC8` then `ret`.  [round7-entrypoints]
ScreenLeave_AdvanceDelay:
	call	ScreenLeaveBody_AdvanceDelay	; F7D1DA  call 0xf7ffc8
	ret	; F7D1DE  ret
; Evidence: the +8 word of screen object F43110 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button tables at 0xF7DCD8 / 0xF7DD58 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_AdvanceDelay:
	ld	xix, ButtonTable_AdvanceDelay_StageZero	; F7D1DF  ld XIX,0x00f7dcd8
	cp	(UI_ScreenStage:16), 0x00	; F7D1E4  cp (0x207e),0x00
	jr	z, ScreenButton_AdvanceDelay_Skip13	; F7D1E9  jr Z,0xf7d1f0
	ld	xix, ButtonTable_AdvanceDelay_StageNonZero	; F7D1EB  ld XIX,0x00f7dd58
ScreenButton_AdvanceDelay_Skip13:
	call	T_PanelButton_CallTableEntry	; F7D1F0  call 0xf41b08
	ret	; F7D1F4  ret
; Evidence: the +0x0C word of screen object F43110 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_AdvanceDelay:
	ret	; F7D1F5  ret

; ---------------------------------------------------------------------
; Screen object F430F0 -- the panel screen whose own title text reads "S0NG C0PY"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF430F0 at 0xF86FE9, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF80261` -- Paint_S0ngC0py.
;        That routine draws display list 0xF3BF80, whose leading
;        op-0x1C records spell
;        "S0NG C0PY" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        one of two 32-entry tables, 0xF7DDD8 and 0xF7DE58, chosen
;        on (0x207E).
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3BF80` immediate inside 0xF80261, decoded from
;           the ROM -- visible in this file;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Map:      (0x207E) = UI_ScreenStage picks the button map: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page.
; Unknown:  what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_S0ngC0py:
	call	Paint_S0ngC0py	; F7D1F6  call 0xf80261
	ret	; F7D1FA  ret
; Evidence: the +4 word of screen object F430F0 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  [round7-entrypoints]
ScreenLeave_S0ngC0py:
	call	ScreenLeave_S0ngC0py_Nop	; F7D1FB  call 0xf803c8
	ret	; F7D1FF  ret
; Evidence: the +8 word of screen object F430F0 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button tables at 0xF7DDD8 / 0xF7DE58 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_S0ngC0py:
	ld	xix, ButtonTable_S0ngC0py_StageZero	; F7D200  ld XIX,0x00f7ddd8
	cp	(UI_ScreenStage:16), 0x00	; F7D205  cp (0x207e),0x00
	jr	z, ScreenButton_S0ngC0py_Skip14	; F7D20A  jr Z,0xf7d211
	ld	xix, ButtonTable_S0ngC0py_StageNonZero	; F7D20C  ld XIX,0x00f7de58
ScreenButton_S0ngC0py_Skip14:
	call	T_PanelButton_CallTableEntry	; F7D211  call 0xf41b08
	ret	; F7D215  ret
; Evidence: the +0x0C word of screen object F430F0 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_S0ngC0py:
	ret	; F7D216  ret

; ---------------------------------------------------------------------
; Screen object F43120 -- the panel screen whose own title text reads "N0TE CHANGE"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF43120 at 0xF86FF5, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF80439` -- Paint_N0teChange.
;        That routine draws display list 0xF3AEAF, whose leading
;        op-0x1C records spell
;        "N0TE CHANGE" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        one of two 32-entry tables, 0xF7DED8 and 0xF7DF58, chosen
;        on (0x207E).
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3AEAF` immediate inside 0xF80439, decoded from
;           the ROM -- visible in this file;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Map:      (0x207E) = UI_ScreenStage picks the button map: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page.
; Unknown:  what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_N0teChange:
	call	Paint_N0teChange	; F7D217  call 0xf80439
	ret	; F7D21B  ret
; Evidence: the +4 word of screen object F43120 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF804EC` then `ret`.  [round7-entrypoints]
ScreenLeave_N0teChange:
	call	ScreenLeaveBody_N0teChange	; F7D21C  call 0xf804ec
	ret	; F7D220  ret
; Evidence: the +8 word of screen object F43120 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button tables at 0xF7DED8 / 0xF7DF58 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_N0teChange:
	ld	xix, ButtonTable_N0teChange_StageZero	; F7D221  ld XIX,0x00f7ded8
	cp	(UI_ScreenStage:16), 0x00	; F7D226  cp (0x207e),0x00
	jr	z, ScreenButton_N0teChange_Skip15	; F7D22B  jr Z,0xf7d232
	ld	xix, ButtonTable_N0teChange_StageNonZero	; F7D22D  ld XIX,0x00f7df58
ScreenButton_N0teChange_Skip15:
	call	T_PanelButton_CallTableEntry	; F7D232  call 0xf41b08
	ret	; F7D236  ret
; Evidence: the +0x0C word of screen object F43120 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_N0teChange:
	ret	; F7D237  ret

; ---------------------------------------------------------------------
; Screen object F430C0 -- the panel screen whose own title text reads "MEASURE C0PY"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF430C0 at 0xF86FC5, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF8076C` -- Paint_MeasureC0py.
;        That routine draws display list 0xF3BBA5, whose leading
;        op-0x1C records spell
;        "MEASURE C0PY" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        one of two 32-entry tables, 0xF7DFD8 and 0xF7E058, chosen
;        on (0x207E).
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3BBA5` immediate inside 0xF8076C, decoded from
;           the ROM -- visible in this file;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Map:      (0x207E) = UI_ScreenStage picks the button map: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page.
; Unknown:  what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_MeasureC0py:
	call	Paint_MeasureC0py	; F7D238  call 0xf8076c
	ret	; F7D23C  ret
; Evidence: the +4 word of screen object F430C0 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF80809` then `ret`.  [round7-entrypoints]
ScreenLeave_MeasureC0py:
	call	ScreenLeaveBody_MeasureC0py	; F7D23D  call 0xf80809
	ret	; F7D241  ret
; Evidence: the +8 word of screen object F430C0 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button tables at 0xF7DFD8 / 0xF7E058 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_MeasureC0py:
	ld	xix, ButtonTable_MeasureC0py_StageZero	; F7D242  ld XIX,0x00f7dfd8
	cp	(UI_ScreenStage:16), 0x00	; F7D247  cp (0x207e),0x00
	jr	z, ScreenButton_MeasureC0py_Skip16	; F7D24C  jr Z,0xf7d253
	ld	xix, ButtonTable_MeasureC0py_StageNonZero	; F7D24E  ld XIX,0x00f7e058
ScreenButton_MeasureC0py_Skip16:
	call	T_PanelButton_CallTableEntry	; F7D253  call 0xf41b08
	ret	; F7D257  ret
; Evidence: the +0x0C word of screen object F430C0 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_MeasureC0py:
	ret	; F7D258  ret

; ---------------------------------------------------------------------
; Screen object F430D0 -- the panel screen whose own title text reads "MEASURE INSERT"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF430D0 at 0xF86FC9, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF80AC9` -- Paint_MeasureInsert.
;        That routine draws display list 0xF3BDCF, whose leading
;        op-0x1C records spell
;        "MEASURE INSERT" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        one of two 32-entry tables, 0xF7E0D8 and 0xF7E158, chosen
;        on (0x207E).
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3BDCF` immediate inside 0xF80AC9, decoded from
;           the ROM -- visible in this file;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Map:      (0x207E) = UI_ScreenStage picks the button map: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page.
; Unknown:  what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_MeasureInsert:
	call	Paint_MeasureInsert	; F7D259  call 0xf80ac9
	ret	; F7D25D  ret
; Evidence: the +4 word of screen object F430D0 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF80B66` then `ret`.  [round7-entrypoints]
ScreenLeave_MeasureInsert:
	call	ScreenLeaveBody_MeasureInsert	; F7D25E  call 0xf80b66
	ret	; F7D262  ret
; Evidence: the +8 word of screen object F430D0 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button tables at 0xF7E0D8 / 0xF7E158 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_MeasureInsert:
	ld	xix, ButtonTable_MeasureInsert_StageZero	; F7D263  ld XIX,0x00f7e0d8
	cp	(UI_ScreenStage:16), 0x00	; F7D268  cp (0x207e),0x00
	jr	z, ScreenButton_MeasureInsert_Skip17	; F7D26D  jr Z,0xf7d274
	ld	xix, ButtonTable_MeasureInsert_StageNonZero	; F7D26F  ld XIX,0x00f7e158
ScreenButton_MeasureInsert_Skip17:
	call	T_PanelButton_CallTableEntry	; F7D274  call 0xf41b08
	ret	; F7D278  ret
; Evidence: the +0x0C word of screen object F430D0 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_MeasureInsert:
	ret	; F7D279  ret

; ---------------------------------------------------------------------
; Screen object F431A0 -- the panel screen whose own title text reads "S0NG SELECT & NAME"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF431A0 at 0xF86F75, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF80E2E` -- Paint_S0ngSelectName.
;        That routine draws display list 0xF3C1AD, whose leading
;        op-0x1C records spell
;        "S0NG SELECT & NAME" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3C1AD` immediate inside 0xF80E2E, decoded from
;           the ROM -- visible in this file;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Unknown:  this screen's +8 word is NOT a table dispatch -- its stub
;           is transcribed below, and what it dispatches on is unread.
;           Also unknown: what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_S0ngSelectName:
	call	Paint_S0ngSelectName	; F7D27A  call 0xf80e2e
	ret	; F7D27E  ret
; Evidence: the +4 word of screen object F431A0 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF80EAF` then `ret`.  [round7-entrypoints]
ScreenLeave_S0ngSelectName:
	call	ScreenLeaveBody_S0ngSelectName	; F7D27F  call 0xf80eaf
	ret	; F7D283  ret
; Evidence: the +8 word of screen object F431A0 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF80EB4` then `ret`.  [round7-entrypoints]
ScreenButton_S0ngSelectName:
	call	ScreenButtonBody_S0ngSelectName	; F7D284  call 0xf80eb4
	ret	; F7D288  ret
; Evidence: the +0x0C word of screen object F431A0 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_S0ngSelectName:
	ret	; F7D289  ret

; ---------------------------------------------------------------------
; Screen object F43170 -- the panel screen whose own title text reads "STEP RECORD"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF43170 at 0xF86F7D, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF80F5A` -- Paint_StepRecordPartSelect.
;        That routine draws display list 0xF3C8A7, whose leading
;        op-0x1C records spell
;        "STEP RECORD" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        the 32-entry table 0xF7E1D8.
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3C8A7` immediate inside 0xF80F5A, decoded from
;           the ROM -- visible in this file;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Unknown:  nothing selects between maps here: this screen has ONE
;           button table, 0xF7E1D8.
;           Also unknown: what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_StepRecordPartSelect:
	call	Paint_StepRecordPartSelect	; F7D28A  call 0xf80f5a
	ret	; F7D28E  ret
; Evidence: the +4 word of screen object F43170 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF80FC0` then `ret`.  [round7-entrypoints]
ScreenLeave_StepRecordPartSelect:
	call	ScreenLeaveBody_StepRecordPartSelect	; F7D28F  call 0xf80fc0
	ret	; F7D293  ret
; Evidence: the +8 word of screen object F43170 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button table at 0xF7E1D8 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_StepRecordPartSelect:
	ld	xix, ButtonTable_StepRecordPartSelect	; F7D294  ld XIX,0x00f7e1d8
	call	T_PanelButton_CallTableEntry	; F7D299  call 0xf41b08
	ret	; F7D29D  ret
; Evidence: the +0x0C word of screen object F43170 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_StepRecordPartSelect:
	ret	; F7D29E  ret

; ---------------------------------------------------------------------
; Screen object F43150 -- the panel screen whose own title text reads "SEQUENCER MEDLEY"
; Reached by: prom_a PanelScreen_VtableTable holds 0xF43150 at 0xF86F8D, and its
;             three readers take +0 Enter, +4 Leave, +8 Button.
; Enter is `call 0xF81048` -- Paint_SequencerMedley.
;        That routine draws display list 0xF3C562, whose leading
;        op-0x1C records spell
;        "SEQUENCER MEDLEY" -- that text is where this name comes from and it is
;        the ROM's own spelling, zeros for O's included.
; Button dispatches on the panel button index through
;        the 32-entry table 0xF7E258.
;        T_PanelButton_CallTableEntry -> prom_a 0xF8BDC5 masks the index to 5 bits, and
;        so does prom_a's PanelButton_Route (`and L,0x1f`, 0xF861AE).
; Evidence: the vtable pointer above (prom_a ROM bytes, not its .s text);
;           the `ld XIY,0x00F3C562` immediate inside 0xF81048, decoded from
;           the ROM -- visible in this file;
;           and the record walk of that list.  All three:
;           notes/prom_b_entrypoints_round7.py
; Unknown:  nothing selects between maps here: this screen has ONE
;           button table, 0xF7E258.
;           Also unknown: what the run's fourth word is for.  Nothing
;           reads +0x0C and its stub is a no-op, in all 23 runs that
;           have one.
;           [round7-entrypoints]
; ---------------------------------------------------------------------
ScreenEnter_SequencerMedley:
	call	Paint_SequencerMedley	; F7D29F  call 0xf81048
	ret	; F7D2A3  ret
; Evidence: the +4 word of screen object F43150 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF810F0` then `ret`.  [round7-entrypoints]
ScreenLeave_SequencerMedley:
	call	ScreenLeaveBody_SequencerMedley	; F7D2A4  call 0xf810f0
	ret	; F7D2A8  ret
; Evidence: the +8 word of screen object F43150 (prom_a's PanelScreen_VtableTable);
;           its body loads the 32-word button table at 0xF7E258 and calls T_F41B08.  [round7-entrypoints]
ScreenButton_SequencerMedley:
	ld	xix, ButtonTable_SequencerMedley	; F7D2A9  ld XIX,0x00f7e258
	call	T_PanelButton_CallTableEntry	; F7D2AE  call 0xf41b08
	ret	; F7D2B2  ret
; Evidence: the +0x0C word of screen object F43150 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
ScreenNull_SequencerMedley:
	ret	; F7D2B3  ret
; Evidence: the +0 word of screen object F43160, which prom_a's PanelScreen_VtableTable
;           names at 0xF86F79.  ⚠ NO NAME: its body reaches no display list, so nothing says which screen this is.  [round7-entrypoints]
; ScreenEnter_StepRecord: the +0 ENTER method of the screen object for screen id 0x0E -- PanelScreen_VtableTable entry 0x2E
;   (ViewB entry 0x0E) points at the thunk triple starting at T_ScreenEnter_StepRecord, and slot T_ScreenEnter_StepRecord jumps here.
ScreenEnter_StepRecord:
	call	ScreenEnterBody_StepRecord	; F7D2B4  call 0xf8101e
	ret	; F7D2B8  ret
; Evidence: the +4 word of screen object F43160 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF81039` then `ret`.  [round7-entrypoints]
; ScreenLeave_StepRecord: the +4 LEAVE method of the screen object for screen id 0x0E -- PanelScreen_VtableTable entry 0x2E
;   (ViewB entry 0x0E) points at the thunk triple starting at T_ScreenEnter_StepRecord, and slot T_ScreenLeave_StepRecord jumps here.
ScreenLeave_StepRecord:
	call	ScreenLeaveBody_StepRecord	; F7D2B9  call 0xf81039
	ret	; F7D2BD  ret
; Evidence: the +8 word of screen object F43160 (prom_a's PanelScreen_VtableTable);
;           its body is transcribed below.  [round7-entrypoints]
; ScreenButton_StepRecord: the +8 BUTTON method of the screen object for screen id 0x0E -- PanelScreen_VtableTable entry 0x2E
;   (ViewB entry 0x0E) points at the thunk triple starting at T_ScreenEnter_StepRecord, and slot T_ScreenButton_StepRecord jumps here.
ScreenButton_StepRecord:
	ld	bc, hl	; F7D2BE  ld BC,HL
	call	T_StepRecord_ButtonByTrackKind	; F7D2C0  call 0xf42ec8
	ret	; F7D2C4  ret
; Evidence: the +0x0C word of screen object F43160 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
T_F4316C_Nop:
	ret	; F7D2C5  ret
; Evidence: the +0 word of screen object F431D0, which prom_a's PanelScreen_VtableTable
;           names at 0xF86F95.  ⚠ NO NAME: its body reaches no display list, so nothing says which screen this is.  [round7-entrypoints]
; ScreenCode15_Handler: the +0 ENTER method of the screen object for screen id 0x15 -- PanelScreen_VtableTable entry 0x35
;   (ViewB entry 0x15) points at the thunk triple starting at T_ScreenCode15_Handler, and slot T_ScreenCode15_Handler jumps here.
ScreenCode15_Handler:
	call	ScreenEnterBody_StepRecord	; F7D2C6  call 0xf8101e
	ret	; F7D2CA  ret
; Evidence: the +4 word of screen object F431D0 (prom_a's PanelScreen_VtableTable);
;           its body is `call 0xF81039` then `ret`.  [round7-entrypoints]
; ScreenLeave_Code15: the +4 LEAVE method of the screen object for screen id 0x15 -- PanelScreen_VtableTable entry 0x35
;   (ViewB entry 0x15) points at the thunk triple starting at T_ScreenCode15_Handler, and slot T_ScreenLeave_Code15 jumps here.
ScreenLeave_Code15:
	call	ScreenLeaveBody_StepRecord	; F7D2CB  call 0xf81039
	ret	; F7D2CF  ret
; Evidence: the +8 word of screen object F431D0 (prom_a's PanelScreen_VtableTable);
;           its body is transcribed below.  [round7-entrypoints]
; ScreenButton_Code15: the +8 BUTTON method of the screen object for screen id 0x15 -- PanelScreen_VtableTable entry 0x35
;   (ViewB entry 0x15) points at the thunk triple starting at T_ScreenCode15_Handler, and slot T_ScreenButton_Code15 jumps here.
ScreenButton_Code15:
	ld	bc, hl	; F7D2D0  ld BC,HL
	call	T_StepRecord_ButtonByTrackKind	; F7D2D2  call 0xf42ec8
	ret	; F7D2D6  ret
; Evidence: the +0x0C word of screen object F431D0 (prom_a's PanelScreen_VtableTable);
;           its body is a no-op (`ret`, or `calr` to a `ret` then `ret`).  NO READER of +0x0C exists in either image.  [round7-entrypoints]
T_F431DC_Nop:
	ret	; F7D2D7  ret

; ==================================================================
; 0xF7D2D8-0xF7E2D7 -- the 32 tables, 32 entries each
; ==================================================================
; Reproduce all three counts with
;     python3 notes/prom_b_f7d_tables.py
;
; ★★ WHAT THE SLOT INDEX IS -- established round 10, and the slot occupancy of
; these very tables is the check.
;
; The index is the CODE byte of a class-0xA9 UI event, and that code is not a
; switch number: it is byte +1 of a 4-byte template {class, code, shift, bit
; mask} in a per-group table in prom_a.  A panel switch closing travels
;   CP1 -> prom_b SC1_RxOp0_ThreeByte (0xF5B0D5), which queues
;          [wire][new value][change mask] at 0x2B40
;       -> prom_a sub_F8A088, the queue's ONLY consumer, which maps the wire to
;          a GROUP through PanelWireGroupMap_Variant1/2
;       -> prom_a 0xF8A3B2, which appends {group, value, mask} to RAM 0x2000
;       -> prom_a 0xF8A824, which reads the group's template list through one of
;          two 27-entry pointer tables (0xF8B446 when the (0xC4) strap is 1,
;          else 0xF8B4B2), copies the template's class and code straight into
;          the 0x2030 event list, masks the value and the change mask with the
;          template's +3 byte and shifts both by its +2 byte
;       -> prom_a UiEvent_RouteByCode, which sends code < 0x20 to
;          PanelButton_Accept -- and PanelButton_Route's `and L,0x1f` is the
;          index into a table here.
; ★ The template's +2 SHIFT is why 32 codes serve 58 switches: it slides the
; masked bits down, so ONE code carries up to eight switches in its payload.
;
; ★ THE CHECK, on these tables' own bytes: all sixteen slots 0x00-0x0F are
; filled by at least one screen, and fifteen of those sixteen codes are emitted
; by a prom_a template.  Slot 0x0F is the only one all 32 screens handle.
; ⚠ AND THE HOLE, not smoothed over: slots 0x0E and 0x11-0x19 are filled by a
; screen and NO template emits them, and code 0x1E is emitted and no screen
; handles it.  The obvious explanation -- PanelButton_Accept's substitution of
; (0x209B)/(0x209C) for code 0x0D -- is REFUTED by census: every literal ever
; written to that pair masks to 0x00-0x0C.  The producer of those nine codes is
; unfound; class 0xA8 is where to look.
; ⚠ AND WHY THE 124 BUTTON HANDLERS BELOW STILL HAVE NO NAME: a code does not
; name a switch.  Variant 1's template table gives GROUPS 3 AND 4 byte-identical
; record lists, and 5 and 6 likewise, so the same bit in either half of a pair
; makes the same four event bytes -- 16 switch bits sharing 8 distinguishable
; (code, payload bit) positions.  Round 9's physical map puts eight fitted
; switches in each of segments 3, 4 and 5 with group == segment; 24 switches do
; not fit in 16 positions, so one of those readings is wrong and this pass does
; not choose between them.
; Evidence: python3 notes/prom_b_screens_round8.py --layer2   (and --selftest,
;           which pins every number above, including the LAST slot and the LAST
;           template list).

; --- table  0 of 32: 10 distinct targets; named by the `ld XIX` at 0xF7D032
; ButtonTable_Edit_0C10Zero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D032 loads it when (0x0C10) is zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_Edit_0C10Zero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_Edit_0C10Zero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_Edit_0C10Zero_Nop0
	on_key	KEY_SoftKeyCol3,	ButtonTable_Edit_0C10Zero_Nop0
	on_key	KEY_SoftKeyCol4,	ButtonTable_Edit_0C10Zero_Nop0
	on_key	KEY_SoftKeyCol5,	ButtonTable_Edit_0C10Zero_Nop0
	on_key	KEY_SoftKeyCol6,	ButtonTable_Edit_0C10Zero_Nop0
	on_key	KEY_SoftKeyCol7,	ButtonTable_Edit_0C10Zero_Nop0
	on_key	KEY_SoftKeyCol8,	ButtonTable_Edit_0C10Zero_Nop0
	on_key	KEY_LcdRow1,		LcdKeyRow1_Edit_0C10Zero
	on_key	KEY_LcdRow2,		LcdKeyRow2_Edit_0C10Zero
	on_key	KEY_LcdRow3,		LcdKeyRow3_Edit_0C10Zero
	on_key	KEY_LcdRow4,		LcdKeyRow4_Edit_0C10Zero
	on_key	KEY_LcdRow5,		LcdKeyRow5_Edit_0C10Zero
	on_key	KEY_MinusPlus,		ButtonTable_Edit_0C10Zero_Nop13
	on_key	KEY_Code0E,		ButtonTable_Edit_0C10Zero_Nop13
	on_key	KEY_Exit,		ExitKey_Edit_0C10Zero
	on_key	KEY_Page,		PageKey_Edit_0C10Zero
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_Edit_0C10Zero_Nop17
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_Edit_0C10Zero_Nop17
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_Edit_0C10Zero_Nop17
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_Edit_0C10Zero_Nop17
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_Edit_0C10Zero_Nop17
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_Edit_0C10Zero_Nop17
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_Edit_0C10Zero_Nop17
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_Edit_0C10Zero_Nop17
	on_key	KEY_PageAlt,		PageKey_Edit_0C10Zero
	on_key	KEY_Code1A,		ButtonTable_Edit_0C10Zero_Nop17
	on_key	KEY_NumberPad,		ButtonTable_Edit_0C10Zero_Nop17
	on_key	KEY_Code1C,		ButtonTable_Edit_0C10Zero_Nop17
	on_key	KEY_Code1D,		ButtonTable_Edit_0C10Zero_Nop17
	on_key	KEY_Compare,		ButtonTable_Edit_0C10Zero_Nop17
	on_key	KEY_Code1F,		ButtonTable_Edit_0C10Zero_Nop17
	keymap_end

; --- table  1 of 32: 10 distinct targets; named by the `ld XIX` at 0xF7D03E
; ButtonTable_Edit_0C10NonZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D032 loads it when (0x0C10) is non-zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_Edit_0C10NonZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_Edit_0C10NonZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_Edit_0C10NonZero_Nop0
	on_key	KEY_SoftKeyCol3,	ButtonTable_Edit_0C10NonZero_Nop0
	on_key	KEY_SoftKeyCol4,	ButtonTable_Edit_0C10NonZero_Nop0
	on_key	KEY_SoftKeyCol5,	ButtonTable_Edit_0C10NonZero_Nop0
	on_key	KEY_SoftKeyCol6,	ButtonTable_Edit_0C10NonZero_Nop0
	on_key	KEY_SoftKeyCol7,	ButtonTable_Edit_0C10NonZero_Nop0
	on_key	KEY_SoftKeyCol8,	ButtonTable_Edit_0C10NonZero_Nop0
	on_key	KEY_LcdRow1,		LcdKeyRow1_Edit_0C10NonZero
	on_key	KEY_LcdRow2,		LcdKeyRow2_Edit_0C10NonZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_Edit_0C10NonZero
	on_key	KEY_LcdRow4,		LcdKeyRow4_Edit_0C10NonZero
	on_key	KEY_LcdRow5,		LcdKeyRow5_Edit_0C10NonZero
	on_key	KEY_MinusPlus,		ButtonTable_Edit_0C10NonZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_Edit_0C10NonZero_Nop13
	on_key	KEY_Exit,		ExitKey_Edit_0C10NonZero
	on_key	KEY_Page,		PageKey_Edit_0C10NonZero
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_Edit_0C10NonZero_Nop17
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_Edit_0C10NonZero_Nop17
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_Edit_0C10NonZero_Nop17
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_Edit_0C10NonZero_Nop17
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_Edit_0C10NonZero_Nop17
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_Edit_0C10NonZero_Nop17
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_Edit_0C10NonZero_Nop17
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_Edit_0C10NonZero_Nop17
	on_key	KEY_PageAlt,		PageKey_Edit_0C10NonZero
	on_key	KEY_Code1A,		ButtonTable_Edit_0C10NonZero_Nop17
	on_key	KEY_NumberPad,		ButtonTable_Edit_0C10NonZero_Nop17
	on_key	KEY_Code1C,		ButtonTable_Edit_0C10NonZero_Nop17
	on_key	KEY_Code1D,		ButtonTable_Edit_0C10NonZero_Nop17
	on_key	KEY_Compare,		ButtonTable_Edit_0C10NonZero_Nop17
	on_key	KEY_Code1F,		ButtonTable_Edit_0C10NonZero_Nop17
	keymap_end

; --- table  2 of 32: 9 distinct targets; named by the `ld XIX` at 0xF7D054
; ButtonTable_SongClear -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D054 loads it with a single `ld XIX,0x00F7D3D8`.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_SongClear:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_SongClear_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_SongClear_Nop0
	on_key	KEY_SoftKeyCol3,	SoftKeyCol3_SongClear
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_SongClear
	on_key	KEY_SoftKeyCol5,	ButtonTable_SongClear_Nop4
	on_key	KEY_SoftKeyCol6,	ButtonTable_SongClear_Nop4
	on_key	KEY_SoftKeyCol7,	ButtonTable_SongClear_Nop4
	on_key	KEY_SoftKeyCol8,	ButtonTable_SongClear_Nop4
	on_key	KEY_LcdRow1,		ButtonTable_SongClear_Nop4
	on_key	KEY_LcdRow2,		ButtonTable_SongClear_Nop4
	on_key	KEY_LcdRow3,		ButtonTable_SongClear_Nop4
	on_key	KEY_LcdRow4,		LcdKeyRow4_SongClear
	on_key	KEY_LcdRow5,		LcdKeyRow5_SongClear
	on_key	KEY_MinusPlus,		ButtonTable_SongClear_Nop13
	on_key	KEY_Code0E,		ButtonTable_SongClear_Nop13
	on_key	KEY_Exit,		ExitKey_SongClear
	on_key	KEY_Page,		ButtonTable_SongClear_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_SongClear_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_SongClear_Nop16
	on_key	KEY_SoftKeyCol3Alt,	SoftKeyCol3_SongClear
	on_key	KEY_SoftKeyCol4Alt,	SoftKeyCol4_SongClear
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_SongClear_Nop16
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_SongClear_Nop16
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_SongClear_Nop16
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_SongClear_Nop16
	on_key	KEY_PageAlt,		ButtonTable_SongClear_Nop16
	on_key	KEY_Code1A,		ButtonTable_SongClear_Nop16
	on_key	KEY_NumberPad,		ButtonTable_SongClear_Nop16
	on_key	KEY_Code1C,		ButtonTable_SongClear_Nop16
	on_key	KEY_Code1D,		ButtonTable_SongClear_Nop16
	on_key	KEY_Compare,		ButtonTable_SongClear_Nop16
	on_key	KEY_Code1F,		ButtonTable_SongClear_Nop16
	keymap_end

; --- table  3 of 32: 13 distinct targets; named by the `ld XIX` at 0xF7D06A
; ButtonTable_TrackClear_StageZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D06A loads it when (0x207E) is zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_TrackClear_StageZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_TrackClear_StageZero
	on_key	KEY_SoftKeyCol2,	SoftKeyCol2_TrackClear_StageZero
	on_key	KEY_SoftKeyCol3,	SoftKeyCol3_TrackClear_StageZero
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_TrackClear_StageZero
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_TrackClear_StageZero
	on_key	KEY_SoftKeyCol6,	SoftKeyCol6_TrackClear_StageZero
	on_key	KEY_SoftKeyCol7,	SoftKeyCol7_TrackClear_StageZero
	on_key	KEY_SoftKeyCol8,	SoftKeyCol8_TrackClear_StageZero
	on_key	KEY_LcdRow1,		ButtonTable_TrackClear_StageZero_Nop8
	on_key	KEY_LcdRow2,		LcdKeyRow2_TrackClear_StageZero
	on_key	KEY_LcdRow3,		ButtonTable_TrackClear_StageZero_Nop10
	on_key	KEY_LcdRow4,		ButtonTable_TrackClear_StageZero_Nop10
	on_key	KEY_LcdRow5,		ButtonTable_TrackClear_StageZero_Nop10
	on_key	KEY_MinusPlus,		ButtonTable_TrackClear_StageZero_Nop10
	on_key	KEY_Code0E,		ButtonTable_TrackClear_StageZero_Nop10
	on_key	KEY_Exit,		ExitKey_TrackClear_StageZero
	on_key	KEY_Page,		ButtonTable_TrackClear_StageZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	SoftKeyCol1_TrackClear_StageZero
	on_key	KEY_SoftKeyCol2Alt,	SoftKeyCol2_TrackClear_StageZero
	on_key	KEY_SoftKeyCol3Alt,	SoftKeyCol3_TrackClear_StageZero
	on_key	KEY_SoftKeyCol4Alt,	SoftKeyCol4_TrackClear_StageZero
	on_key	KEY_SoftKeyCol5Alt,	SoftKeyCol5_TrackClear_StageZero
	on_key	KEY_SoftKeyCol6Alt,	SoftKeyCol6_TrackClear_StageZero
	on_key	KEY_SoftKeyCol7Alt,	SoftKeyCol7_TrackClear_StageZero
	on_key	KEY_SoftKeyCol8Alt,	SoftKeyCol8_TrackClear_StageZero
	on_key	KEY_PageAlt,		ButtonTable_TrackClear_StageZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_TrackClear_StageZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_TrackClear_StageZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_TrackClear_StageZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_TrackClear_StageZero_Nop16
	on_key	KEY_Compare,		ButtonTable_TrackClear_StageZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_TrackClear_StageZero_Nop16
	keymap_end

; --- table  4 of 32: 6 distinct targets; named by the `ld XIX` at 0xF7D076
; ButtonTable_TrackClear_StageNonZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D06A loads it when (0x207E) is non-zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_TrackClear_StageNonZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_TrackClear_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_TrackClear_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol3,	ButtonTable_TrackClear_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol4,	ButtonTable_TrackClear_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol5,	ButtonTable_TrackClear_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol6,	ButtonTable_TrackClear_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol7,	ButtonTable_TrackClear_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol8,	ButtonTable_TrackClear_StageNonZero_Nop0
	on_key	KEY_LcdRow1,		ButtonTable_TrackClear_StageNonZero_Nop0
	on_key	KEY_LcdRow2,		LcdKeyRow2_TrackClear_StageNonZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_TrackClear_StageNonZero
	on_key	KEY_LcdRow4,		ButtonTable_TrackClear_StageNonZero_Nop11
	on_key	KEY_LcdRow5,		ButtonTable_TrackClear_StageNonZero_Nop11
	on_key	KEY_MinusPlus,		ButtonTable_TrackClear_StageNonZero_Nop11
	on_key	KEY_Code0E,		ButtonTable_TrackClear_StageNonZero_Nop11
	on_key	KEY_Exit,		ExitKey_TrackClear_StageNonZero
	on_key	KEY_Page,		ButtonTable_TrackClear_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_TrackClear_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_TrackClear_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_TrackClear_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_TrackClear_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_TrackClear_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_TrackClear_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_TrackClear_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_TrackClear_StageNonZero_Nop16
	on_key	KEY_PageAlt,		ButtonTable_TrackClear_StageNonZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_TrackClear_StageNonZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_TrackClear_StageNonZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_TrackClear_StageNonZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_TrackClear_StageNonZero_Nop16
	on_key	KEY_Compare,		ButtonTable_TrackClear_StageNonZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_TrackClear_StageNonZero_Nop16
	keymap_end

; --- table  5 of 32: 15 distinct targets; named by the `ld XIX` at 0xF7D08C
; ButtonTable_TrackAssign_StageZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D08C loads it when (0x207E) is zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_TrackAssign_StageZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_TrackAssign_StageZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_TrackAssign_StageZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_TrackAssign_StageZero_Nop1
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_TrackAssign_StageZero
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_TrackAssign_StageZero
	on_key	KEY_SoftKeyCol6,	ButtonTable_TrackAssign_StageZero_Nop5
	on_key	KEY_SoftKeyCol7,	SoftKeyCol7_TrackAssign_StageZero
	on_key	KEY_SoftKeyCol8,	ButtonTable_TrackAssign_StageZero_Nop7
	on_key	KEY_LcdRow1,		LcdKeyRow1_TrackAssign_StageZero
	on_key	KEY_LcdRow2,		LcdKeyRow2_TrackAssign_StageZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_TrackAssign_StageZero
	on_key	KEY_LcdRow4,		LcdKeyRow4_TrackAssign_StageZero
	on_key	KEY_LcdRow5,		LcdKeyRow5_TrackAssign_StageZero
	on_key	KEY_MinusPlus,		ButtonTable_TrackAssign_StageZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_TrackAssign_StageZero_Nop13
	on_key	KEY_Exit,		ExitKey_TrackAssign_StageZero
	on_key	KEY_Page,		ButtonTable_TrackAssign_StageZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_TrackAssign_StageZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_TrackAssign_StageZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_TrackAssign_StageZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	SoftKeyCol4_TrackAssign_StageZero
	on_key	KEY_SoftKeyCol5Alt,	SoftKeyCol5_TrackAssign_StageZero
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_TrackAssign_StageZero_Nop5
	on_key	KEY_SoftKeyCol7Alt,	SoftKeyCol7_TrackAssign_StageZero
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_TrackAssign_StageZero_Nop16
	on_key	KEY_PageAlt,		ButtonTable_TrackAssign_StageZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_TrackAssign_StageZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_TrackAssign_StageZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_TrackAssign_StageZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_TrackAssign_StageZero_Nop16
	on_key	KEY_Compare,		ButtonTable_TrackAssign_StageZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_TrackAssign_StageZero_Nop16
	keymap_end

; --- table  6 of 32: 6 distinct targets; named by the `ld XIX` at 0xF7D098
; ButtonTable_TrackAssign_StageNonZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D08C loads it when (0x207E) is non-zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_TrackAssign_StageNonZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_TrackAssign_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_TrackAssign_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol3,	ButtonTable_TrackAssign_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol4,	ButtonTable_TrackAssign_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol5,	ButtonTable_TrackAssign_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol6,	ButtonTable_TrackAssign_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol7,	ButtonTable_TrackAssign_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol8,	ButtonTable_TrackAssign_StageNonZero_Nop0
	on_key	KEY_LcdRow1,		ButtonTable_TrackAssign_StageNonZero_Nop0
	on_key	KEY_LcdRow2,		LcdKeyRow2_TrackAssign_StageNonZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_TrackAssign_StageNonZero
	on_key	KEY_LcdRow4,		ButtonTable_TrackAssign_StageNonZero_Nop11
	on_key	KEY_LcdRow5,		ButtonTable_TrackAssign_StageNonZero_Nop11
	on_key	KEY_MinusPlus,		ButtonTable_TrackAssign_StageNonZero_Nop11
	on_key	KEY_Code0E,		ButtonTable_TrackAssign_StageNonZero_Nop11
	on_key	KEY_Exit,		ExitKey_TrackAssign_StageNonZero
	on_key	KEY_Page,		ButtonTable_TrackAssign_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_TrackAssign_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_TrackAssign_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_TrackAssign_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_TrackAssign_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_TrackAssign_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_TrackAssign_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_TrackAssign_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_TrackAssign_StageNonZero_Nop16
	on_key	KEY_PageAlt,		ButtonTable_TrackAssign_StageNonZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_TrackAssign_StageNonZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_TrackAssign_StageNonZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_TrackAssign_StageNonZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_TrackAssign_StageNonZero_Nop16
	on_key	KEY_Compare,		ButtonTable_TrackAssign_StageNonZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_TrackAssign_StageNonZero_Nop16
	keymap_end

; --- table  7 of 32: 17 distinct targets; named by the `ld XIX` at 0xF7D0AE
; ButtonTable_TrackAssignPresets -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D0AE loads it with a single `ld XIX,0x00F7D658`.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_TrackAssignPresets:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_TrackAssignPresets
	on_key	KEY_SoftKeyCol2,	SoftKeyCol2_TrackAssignPresets
	on_key	KEY_SoftKeyCol3,	SoftKeyCol3_TrackAssignPresets
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_TrackAssignPresets
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_TrackAssignPresets
	on_key	KEY_SoftKeyCol6,	SoftKeyCol6_TrackAssignPresets
	on_key	KEY_SoftKeyCol7,	SoftKeyCol7_TrackAssignPresets
	on_key	KEY_SoftKeyCol8,	SoftKeyCol8_TrackAssignPresets
	on_key	KEY_LcdRow1,		LcdKeyRow1_TrackAssignPresets
	on_key	KEY_LcdRow2,		LcdKeyRow2_TrackAssignPresets
	on_key	KEY_LcdRow3,		LcdKeyRow3_TrackAssignPresets
	on_key	KEY_LcdRow4,		LcdKeyRow4_TrackAssignPresets
	on_key	KEY_LcdRow5,		LcdKeyRow5_TrackAssignPresets
	on_key	KEY_MinusPlus,		sub_F7E750
	on_key	KEY_Code0E,		sub_F7E758
	on_key	KEY_Exit,		ExitKey_TrackAssignPresets
	on_key	KEY_Page,		ButtonTable_TrackAssignPresets_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_TrackAssignPresets_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_TrackAssignPresets_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_TrackAssignPresets_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_TrackAssignPresets_Nop16
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_TrackAssignPresets_Nop16
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_TrackAssignPresets_Nop16
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_TrackAssignPresets_Nop16
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_TrackAssignPresets_Nop16
	on_key	KEY_PageAlt,		ButtonTable_TrackAssignPresets_Nop16
	on_key	KEY_Code1A,		ButtonTable_TrackAssignPresets_Nop16
	on_key	KEY_NumberPad,		ButtonTable_TrackAssignPresets_Nop16
	on_key	KEY_Code1C,		ButtonTable_TrackAssignPresets_Nop16
	on_key	KEY_Code1D,		ButtonTable_TrackAssignPresets_Nop16
	on_key	KEY_Compare,		ButtonTable_TrackAssignPresets_Nop16
	on_key	KEY_Code1F,		ButtonTable_TrackAssignPresets_Nop16
	keymap_end

; --- table  8 of 32: 16 distinct targets; named by the `ld XIX` at 0xF7D0C6
; ButtonTable_TrackMerge_StageZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D0C6 loads it when (0x207E) is zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_TrackMerge_StageZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_TrackMerge_StageZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_TrackMerge_StageZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_TrackMerge_StageZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_TrackMerge_StageZero_Nop3
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_TrackMerge_StageZero
	on_key	KEY_SoftKeyCol6,	ButtonTable_TrackMerge_StageZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_TrackMerge_StageZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_TrackMerge_StageZero_Nop7
	on_key	KEY_LcdRow1,		ButtonTable_TrackMerge_StageZero_Nop7
	on_key	KEY_LcdRow2,		LcdKeyRow2_TrackMerge_StageZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_TrackMerge_StageZero
	on_key	KEY_LcdRow4,		LcdKeyRow4_TrackMerge_StageZero
	on_key	KEY_LcdRow5,		ButtonTable_TrackMerge_StageZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_TrackMerge_StageZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_TrackMerge_StageZero_Nop14
	on_key	KEY_Exit,		ExitKey_TrackMerge_StageZero
	on_key	KEY_Page,		ButtonTable_TrackMerge_StageZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_TrackMerge_StageZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_TrackMerge_StageZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_TrackMerge_StageZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_TrackMerge_StageZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_TrackMerge_StageZero_Nop16
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_TrackMerge_StageZero_Nop16
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_TrackMerge_StageZero_Nop16
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_TrackMerge_StageZero_Nop16
	on_key	KEY_PageAlt,		ButtonTable_TrackMerge_StageZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_TrackMerge_StageZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_TrackMerge_StageZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_TrackMerge_StageZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_TrackMerge_StageZero_Nop16
	on_key	KEY_Compare,		ButtonTable_TrackMerge_StageZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_TrackMerge_StageZero_Nop16
	keymap_end

; --- table  9 of 32: 16 distinct targets; named by the `ld XIX` at 0xF7D0D2
; ButtonTable_TrackMerge_StageNonZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D0C6 loads it when (0x207E) is non-zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_TrackMerge_StageNonZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_TrackMerge_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_TrackMerge_StageNonZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_TrackMerge_StageNonZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_TrackMerge_StageNonZero_Nop3
	on_key	KEY_SoftKeyCol5,	ButtonTable_TrackMerge_StageNonZero_Nop4
	on_key	KEY_SoftKeyCol6,	ButtonTable_TrackMerge_StageNonZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_TrackMerge_StageNonZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_TrackMerge_StageNonZero_Nop7
	on_key	KEY_LcdRow1,		ButtonTable_TrackMerge_StageNonZero_Nop7
	on_key	KEY_LcdRow2,		LcdKeyRow2_TrackMerge_StageNonZero
	on_key	KEY_LcdRow3,		ButtonTable_TrackMerge_StageNonZero_Nop10
	on_key	KEY_LcdRow4,		LcdKeyRow4_TrackMerge_StageNonZero
	on_key	KEY_LcdRow5,		ButtonTable_TrackMerge_StageNonZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_TrackMerge_StageNonZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_TrackMerge_StageNonZero_Nop14
	on_key	KEY_Exit,		ExitKey_TrackMerge_StageNonZero
	on_key	KEY_Page,		ButtonTable_TrackMerge_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_TrackMerge_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_TrackMerge_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_TrackMerge_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_TrackMerge_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_TrackMerge_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_TrackMerge_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_TrackMerge_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_TrackMerge_StageNonZero_Nop16
	on_key	KEY_PageAlt,		ButtonTable_TrackMerge_StageNonZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_TrackMerge_StageNonZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_TrackMerge_StageNonZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_TrackMerge_StageNonZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_TrackMerge_StageNonZero_Nop16
	on_key	KEY_Compare,		ButtonTable_TrackMerge_StageNonZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_TrackMerge_StageNonZero_Nop16
	keymap_end

; --- table 10 of 32: 20 distinct targets; named by the `ld XIX` at 0xF7D0E7
; ButtonTable_MeasureDelete_StageZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D0E7 loads it when (0x207E) is zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_MeasureDelete_StageZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_MeasureDelete_StageZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_MeasureDelete_StageZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_MeasureDelete_StageZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_MeasureDelete_StageZero_Nop3
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_MeasureDelete_StageZero
	on_key	KEY_SoftKeyCol6,	ButtonTable_MeasureDelete_StageZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_MeasureDelete_StageZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_MeasureDelete_StageZero_Nop7
	on_key	KEY_LcdRow1,		ButtonTable_MeasureDelete_StageZero_Nop7
	on_key	KEY_LcdRow2,		LcdKeyRow2_MeasureDelete_StageZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_MeasureDelete_StageZero
	on_key	KEY_LcdRow4,		LcdKeyRow4_MeasureDelete_StageZero
	on_key	KEY_LcdRow5,		ButtonTable_MeasureDelete_StageZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_MeasureDelete_StageZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_MeasureDelete_StageZero_Nop14
	on_key	KEY_Exit,		ExitKey_MeasureDelete_StageZero
	on_key	KEY_Page,		ButtonTable_MeasureDelete_StageZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_MeasureDelete_StageZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_MeasureDelete_StageZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_MeasureDelete_StageZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_MeasureDelete_StageZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	MeasureDelete_StageZero_Button21
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_MeasureDelete_StageZero_Nop22
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_MeasureDelete_StageZero_Nop22
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_MeasureDelete_StageZero_Nop22
	on_key	KEY_PageAlt,		ButtonTable_MeasureDelete_StageZero_Nop22
	on_key	KEY_Code1A,		ButtonTable_MeasureDelete_StageZero_Nop22
	on_key	KEY_NumberPad,		NumberPadKey_MeasureDelete_StageZero
	on_key	KEY_Code1C,		ButtonTable_MeasureDelete_StageZero_Nop28
	on_key	KEY_Code1D,		ButtonTable_MeasureDelete_StageZero_Nop28
	on_key	KEY_Compare,		ButtonTable_MeasureDelete_StageZero_Nop28
	on_key	KEY_Code1F,		ButtonTable_MeasureDelete_StageZero_Nop28
	keymap_end

; --- table 11 of 32: 16 distinct targets; named by the `ld XIX` at 0xF7D0F3
; ButtonTable_MeasureDelete_StageNonZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D0E7 loads it when (0x207E) is non-zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_MeasureDelete_StageNonZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_MeasureDelete_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_MeasureDelete_StageNonZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_MeasureDelete_StageNonZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_MeasureDelete_StageNonZero_Nop3
	on_key	KEY_SoftKeyCol5,	ButtonTable_MeasureDelete_StageNonZero_Nop4
	on_key	KEY_SoftKeyCol6,	ButtonTable_MeasureDelete_StageNonZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_MeasureDelete_StageNonZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_MeasureDelete_StageNonZero_Nop7
	on_key	KEY_LcdRow1,		ButtonTable_MeasureDelete_StageNonZero_Nop8
	on_key	KEY_LcdRow2,		ButtonTable_MeasureDelete_StageNonZero_Nop8
	on_key	KEY_LcdRow3,		LcdKeyRow3_MeasureDelete_StageNonZero
	on_key	KEY_LcdRow4,		LcdKeyRow4_MeasureDelete_StageNonZero
	on_key	KEY_LcdRow5,		ButtonTable_MeasureDelete_StageNonZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_MeasureDelete_StageNonZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_MeasureDelete_StageNonZero_Nop14
	on_key	KEY_Exit,		ExitKey_MeasureDelete_StageNonZero
	on_key	KEY_Page,		ButtonTable_MeasureDelete_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_MeasureDelete_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_MeasureDelete_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_MeasureDelete_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_MeasureDelete_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_MeasureDelete_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_MeasureDelete_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_MeasureDelete_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_MeasureDelete_StageNonZero_Nop16
	on_key	KEY_PageAlt,		ButtonTable_MeasureDelete_StageNonZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_MeasureDelete_StageNonZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_MeasureDelete_StageNonZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_MeasureDelete_StageNonZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_MeasureDelete_StageNonZero_Nop16
	on_key	KEY_Compare,		ButtonTable_MeasureDelete_StageNonZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_MeasureDelete_StageNonZero_Nop16
	keymap_end

; --- table 12 of 32: 21 distinct targets; named by the `ld XIX` at 0xF7D108
; ButtonTable_MeasureErase_StageZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D108 loads it when (0x207E) is zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_MeasureErase_StageZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_MeasureErase_StageZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_MeasureErase_StageZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_MeasureErase_StageZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_MeasureErase_StageZero_Nop3
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_MeasureErase_StageZero
	on_key	KEY_SoftKeyCol6,	ButtonTable_MeasureErase_StageZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_MeasureErase_StageZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_MeasureErase_StageZero_Nop7
	on_key	KEY_LcdRow1,		LcdKeyRow1_MeasureErase_StageZero
	on_key	KEY_LcdRow2,		LcdKeyRow2_MeasureErase_StageZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_MeasureErase_StageZero
	on_key	KEY_LcdRow4,		LcdKeyRow4_MeasureErase_StageZero
	on_key	KEY_LcdRow5,		ButtonTable_MeasureErase_StageZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_MeasureErase_StageZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_MeasureErase_StageZero_Nop14
	on_key	KEY_Exit,		ExitKey_MeasureErase_StageZero
	on_key	KEY_Page,		ButtonTable_MeasureErase_StageZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_MeasureErase_StageZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_MeasureErase_StageZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_MeasureErase_StageZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_MeasureErase_StageZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	MeasureErase_StageZero_Button21
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_MeasureErase_StageZero_Nop22
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_MeasureErase_StageZero_Nop22
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_MeasureErase_StageZero_Nop22
	on_key	KEY_PageAlt,		ButtonTable_MeasureErase_StageZero_Nop22
	on_key	KEY_Code1A,		ButtonTable_MeasureErase_StageZero_Nop22
	on_key	KEY_NumberPad,		NumberPadKey_MeasureErase_StageZero
	on_key	KEY_Code1C,		ButtonTable_MeasureErase_StageZero_Nop28
	on_key	KEY_Code1D,		ButtonTable_MeasureErase_StageZero_Nop28
	on_key	KEY_Compare,		ButtonTable_MeasureErase_StageZero_Nop28
	on_key	KEY_Code1F,		ButtonTable_MeasureErase_StageZero_Nop28
	keymap_end

; --- table 13 of 32: 17 distinct targets; named by the `ld XIX` at 0xF7D114
; ButtonTable_MeasureErase_StageNonZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D108 loads it when (0x207E) is non-zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_MeasureErase_StageNonZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_MeasureErase_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_MeasureErase_StageNonZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_MeasureErase_StageNonZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_MeasureErase_StageNonZero_Nop3
	on_key	KEY_SoftKeyCol5,	ButtonTable_MeasureErase_StageNonZero_Nop4
	on_key	KEY_SoftKeyCol6,	ButtonTable_MeasureErase_StageNonZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_MeasureErase_StageNonZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_MeasureErase_StageNonZero_Nop7
	on_key	KEY_LcdRow1,		ButtonTable_MeasureErase_StageNonZero_Nop8
	on_key	KEY_LcdRow2,		LcdKeyRow2_MeasureErase_StageNonZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_MeasureErase_StageNonZero
	on_key	KEY_LcdRow4,		ButtonTable_MeasureErase_StageNonZero_Nop11
	on_key	KEY_LcdRow5,		ButtonTable_MeasureErase_StageNonZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_MeasureErase_StageNonZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_MeasureErase_StageNonZero_Nop14
	on_key	KEY_Exit,		ExitKey_MeasureErase_StageNonZero
	on_key	KEY_Page,		ButtonTable_MeasureErase_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_MeasureErase_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_MeasureErase_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_MeasureErase_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_MeasureErase_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_MeasureErase_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_MeasureErase_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_MeasureErase_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_MeasureErase_StageNonZero_Nop16
	on_key	KEY_PageAlt,		ButtonTable_MeasureErase_StageNonZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_MeasureErase_StageNonZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_MeasureErase_StageNonZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_MeasureErase_StageNonZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_MeasureErase_StageNonZero_Nop16
	on_key	KEY_Compare,		ButtonTable_MeasureErase_StageNonZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_MeasureErase_StageNonZero_Nop16
	keymap_end

; --- table 14 of 32: 21 distinct targets; named by the `ld XIX` at 0xF7D139
; ButtonTable_Quantize_StageZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D139 loads it when (0x207E) is zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_Quantize_StageZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_Quantize_StageZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_Quantize_StageZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_Quantize_StageZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_Quantize_StageZero_Nop3
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_Quantize_StageZero
	on_key	KEY_SoftKeyCol6,	ButtonTable_Quantize_StageZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_Quantize_StageZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_Quantize_StageZero_Nop7
	on_key	KEY_LcdRow1,		LcdKeyRow1_Quantize_StageZero
	on_key	KEY_LcdRow2,		LcdKeyRow2_Quantize_StageZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_Quantize_StageZero
	on_key	KEY_LcdRow4,		LcdKeyRow4_Quantize_StageZero
	on_key	KEY_LcdRow5,		ButtonTable_Quantize_StageZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_Quantize_StageZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_Quantize_StageZero_Nop14
	on_key	KEY_Exit,		ExitKey_Quantize_StageZero
	on_key	KEY_Page,		ButtonTable_Quantize_StageZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_Quantize_StageZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_Quantize_StageZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_Quantize_StageZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_Quantize_StageZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	Quantize_StageZero_Button21
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_Quantize_StageZero_Nop22
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_Quantize_StageZero_Nop22
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_Quantize_StageZero_Nop22
	on_key	KEY_PageAlt,		ButtonTable_Quantize_StageZero_Nop22
	on_key	KEY_Code1A,		ButtonTable_Quantize_StageZero_Nop22
	on_key	KEY_NumberPad,		NumberPadKey_Quantize_StageZero
	on_key	KEY_Code1C,		ButtonTable_Quantize_StageZero_Nop28
	on_key	KEY_Code1D,		ButtonTable_Quantize_StageZero_Nop28
	on_key	KEY_Compare,		ButtonTable_Quantize_StageZero_Nop28
	on_key	KEY_Code1F,		ButtonTable_Quantize_StageZero_Nop28
	keymap_end

; --- table 15 of 32: 16 distinct targets; named by the `ld XIX` at 0xF7D145
; ButtonTable_Quantize_StageNonZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D139 loads it when (0x207E) is non-zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_Quantize_StageNonZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_Quantize_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_Quantize_StageNonZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_Quantize_StageNonZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_Quantize_StageNonZero_Nop3
	on_key	KEY_SoftKeyCol5,	ButtonTable_Quantize_StageNonZero_Nop4
	on_key	KEY_SoftKeyCol6,	ButtonTable_Quantize_StageNonZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_Quantize_StageNonZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_Quantize_StageNonZero_Nop7
	on_key	KEY_LcdRow1,		ButtonTable_Quantize_StageNonZero_Nop8
	on_key	KEY_LcdRow2,		ButtonTable_Quantize_StageNonZero_Nop8
	on_key	KEY_LcdRow3,		LcdKeyRow3_Quantize_StageNonZero
	on_key	KEY_LcdRow4,		LcdKeyRow4_Quantize_StageNonZero
	on_key	KEY_LcdRow5,		ButtonTable_Quantize_StageNonZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_Quantize_StageNonZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_Quantize_StageNonZero_Nop14
	on_key	KEY_Exit,		ExitKey_Quantize_StageNonZero
	on_key	KEY_Page,		ButtonTable_Quantize_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_Quantize_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_Quantize_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_Quantize_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_Quantize_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_Quantize_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_Quantize_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_Quantize_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_Quantize_StageNonZero_Nop16
	on_key	KEY_PageAlt,		ButtonTable_Quantize_StageNonZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_Quantize_StageNonZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_Quantize_StageNonZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_Quantize_StageNonZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_Quantize_StageNonZero_Nop16
	on_key	KEY_Compare,		ButtonTable_Quantize_StageNonZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_Quantize_StageNonZero_Nop16
	keymap_end

; --- table 16 of 32: 21 distinct targets; named by the `ld XIX` at 0xF7D15A
; ButtonTable_Vel0cityChange_StageZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D15A loads it when (0x207E) is zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_Vel0cityChange_StageZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_Vel0cityChange_StageZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_Vel0cityChange_StageZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_Vel0cityChange_StageZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_Vel0cityChange_StageZero_Nop3
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_Vel0cityChange_StageZero
	on_key	KEY_SoftKeyCol6,	ButtonTable_Vel0cityChange_StageZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_Vel0cityChange_StageZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_Vel0cityChange_StageZero_Nop7
	on_key	KEY_LcdRow1,		LcdKeyRow1_Vel0cityChange_StageZero
	on_key	KEY_LcdRow2,		LcdKeyRow2_Vel0cityChange_StageZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_Vel0cityChange_StageZero
	on_key	KEY_LcdRow4,		LcdKeyRow4_Vel0cityChange_StageZero
	on_key	KEY_LcdRow5,		ButtonTable_Vel0cityChange_StageZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_Vel0cityChange_StageZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_Vel0cityChange_StageZero_Nop14
	on_key	KEY_Exit,		ExitKey_Vel0cityChange_StageZero
	on_key	KEY_Page,		ButtonTable_Vel0cityChange_StageZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_Vel0cityChange_StageZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_Vel0cityChange_StageZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_Vel0cityChange_StageZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_Vel0cityChange_StageZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	Vel0cityChange_StageZero_Button21
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_Vel0cityChange_StageZero_Nop22
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_Vel0cityChange_StageZero_Nop22
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_Vel0cityChange_StageZero_Nop22
	on_key	KEY_PageAlt,		ButtonTable_Vel0cityChange_StageZero_Nop22
	on_key	KEY_Code1A,		ButtonTable_Vel0cityChange_StageZero_Nop22
	on_key	KEY_NumberPad,		NumberPadKey_Vel0cityChange_StageZero
	on_key	KEY_Code1C,		ButtonTable_Vel0cityChange_StageZero_Nop28
	on_key	KEY_Code1D,		ButtonTable_Vel0cityChange_StageZero_Nop28
	on_key	KEY_Compare,		ButtonTable_Vel0cityChange_StageZero_Nop28
	on_key	KEY_Code1F,		ButtonTable_Vel0cityChange_StageZero_Nop28
	keymap_end

; --- table 17 of 32: 17 distinct targets; named by the `ld XIX` at 0xF7D166
; ButtonTable_Vel0cityChange_StageNonZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D15A loads it when (0x207E) is non-zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_Vel0cityChange_StageNonZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_Vel0cityChange_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_Vel0cityChange_StageNonZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_Vel0cityChange_StageNonZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_Vel0cityChange_StageNonZero_Nop3
	on_key	KEY_SoftKeyCol5,	ButtonTable_Vel0cityChange_StageNonZero_Nop4
	on_key	KEY_SoftKeyCol6,	ButtonTable_Vel0cityChange_StageNonZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_Vel0cityChange_StageNonZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_Vel0cityChange_StageNonZero_Nop7
	on_key	KEY_LcdRow1,		ButtonTable_Vel0cityChange_StageNonZero_Nop8
	on_key	KEY_LcdRow2,		LcdKeyRow2_Vel0cityChange_StageNonZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_Vel0cityChange_StageNonZero
	on_key	KEY_LcdRow4,		ButtonTable_Vel0cityChange_StageNonZero_Nop11
	on_key	KEY_LcdRow5,		ButtonTable_Vel0cityChange_StageNonZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_Vel0cityChange_StageNonZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_Vel0cityChange_StageNonZero_Nop14
	on_key	KEY_Exit,		ExitKey_Vel0cityChange_StageNonZero
	on_key	KEY_Page,		ButtonTable_Vel0cityChange_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_Vel0cityChange_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_Vel0cityChange_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_Vel0cityChange_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_Vel0cityChange_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_Vel0cityChange_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_Vel0cityChange_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_Vel0cityChange_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_Vel0cityChange_StageNonZero_Nop16
	on_key	KEY_PageAlt,		ButtonTable_Vel0cityChange_StageNonZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_Vel0cityChange_StageNonZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_Vel0cityChange_StageNonZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_Vel0cityChange_StageNonZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_Vel0cityChange_StageNonZero_Nop16
	on_key	KEY_Compare,		ButtonTable_Vel0cityChange_StageNonZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_Vel0cityChange_StageNonZero_Nop16
	keymap_end

; --- table 18 of 32: 21 distinct targets; named by the `ld XIX` at 0xF7D17B
; ButtonTable_Transp0se_StageZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D17B loads it when (0x207E) is zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_Transp0se_StageZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_Transp0se_StageZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_Transp0se_StageZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_Transp0se_StageZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_Transp0se_StageZero_Nop3
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_Transp0se_StageZero
	on_key	KEY_SoftKeyCol6,	ButtonTable_Transp0se_StageZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_Transp0se_StageZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_Transp0se_StageZero_Nop7
	on_key	KEY_LcdRow1,		LcdKeyRow1_Transp0se_StageZero
	on_key	KEY_LcdRow2,		LcdKeyRow2_Transp0se_StageZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_Transp0se_StageZero
	on_key	KEY_LcdRow4,		LcdKeyRow4_Transp0se_StageZero
	on_key	KEY_LcdRow5,		ButtonTable_Transp0se_StageZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_Transp0se_StageZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_Transp0se_StageZero_Nop14
	on_key	KEY_Exit,		ExitKey_Transp0se_StageZero
	on_key	KEY_Page,		ButtonTable_Transp0se_StageZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_Transp0se_StageZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_Transp0se_StageZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_Transp0se_StageZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_Transp0se_StageZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	Transp0se_StageZero_Button21
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_Transp0se_StageZero_Nop22
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_Transp0se_StageZero_Nop22
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_Transp0se_StageZero_Nop22
	on_key	KEY_PageAlt,		ButtonTable_Transp0se_StageZero_Nop22
	on_key	KEY_Code1A,		ButtonTable_Transp0se_StageZero_Nop22
	on_key	KEY_NumberPad,		NumberPadKey_Transp0se_StageZero
	on_key	KEY_Code1C,		ButtonTable_Transp0se_StageZero_Nop28
	on_key	KEY_Code1D,		ButtonTable_Transp0se_StageZero_Nop28
	on_key	KEY_Compare,		ButtonTable_Transp0se_StageZero_Nop28
	on_key	KEY_Code1F,		ButtonTable_Transp0se_StageZero_Nop28
	keymap_end

; --- table 19 of 32: 17 distinct targets; named by the `ld XIX` at 0xF7D187
; ButtonTable_Transp0se_StageNonZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D17B loads it when (0x207E) is non-zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_Transp0se_StageNonZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_Transp0se_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_Transp0se_StageNonZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_Transp0se_StageNonZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_Transp0se_StageNonZero_Nop3
	on_key	KEY_SoftKeyCol5,	ButtonTable_Transp0se_StageNonZero_Nop4
	on_key	KEY_SoftKeyCol6,	ButtonTable_Transp0se_StageNonZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_Transp0se_StageNonZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_Transp0se_StageNonZero_Nop7
	on_key	KEY_LcdRow1,		ButtonTable_Transp0se_StageNonZero_Nop8
	on_key	KEY_LcdRow2,		LcdKeyRow2_Transp0se_StageNonZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_Transp0se_StageNonZero
	on_key	KEY_LcdRow4,		ButtonTable_Transp0se_StageNonZero_Nop11
	on_key	KEY_LcdRow5,		ButtonTable_Transp0se_StageNonZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_Transp0se_StageNonZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_Transp0se_StageNonZero_Nop14
	on_key	KEY_Exit,		ExitKey_Transp0se_StageNonZero
	on_key	KEY_Page,		ButtonTable_Transp0se_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_Transp0se_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_Transp0se_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_Transp0se_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_Transp0se_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_Transp0se_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_Transp0se_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_Transp0se_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_Transp0se_StageNonZero_Nop16
	on_key	KEY_PageAlt,		ButtonTable_Transp0se_StageNonZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_Transp0se_StageNonZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_Transp0se_StageNonZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_Transp0se_StageNonZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_Transp0se_StageNonZero_Nop16
	on_key	KEY_Compare,		ButtonTable_Transp0se_StageNonZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_Transp0se_StageNonZero_Nop16
	keymap_end

; --- table 20 of 32: 21 distinct targets; named by the `ld XIX` at 0xF7D1DF
; ButtonTable_AdvanceDelay_StageZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D1DF loads it when (0x207E) is zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_AdvanceDelay_StageZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_AdvanceDelay_StageZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_AdvanceDelay_StageZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_AdvanceDelay_StageZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_AdvanceDelay_StageZero_Nop3
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_AdvanceDelay_StageZero
	on_key	KEY_SoftKeyCol6,	ButtonTable_AdvanceDelay_StageZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_AdvanceDelay_StageZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_AdvanceDelay_StageZero_Nop7
	on_key	KEY_LcdRow1,		LcdKeyRow1_AdvanceDelay_StageZero
	on_key	KEY_LcdRow2,		LcdKeyRow2_AdvanceDelay_StageZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_AdvanceDelay_StageZero
	on_key	KEY_LcdRow4,		LcdKeyRow4_AdvanceDelay_StageZero
	on_key	KEY_LcdRow5,		ButtonTable_AdvanceDelay_StageZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_AdvanceDelay_StageZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_AdvanceDelay_StageZero_Nop14
	on_key	KEY_Exit,		ExitKey_AdvanceDelay_StageZero
	on_key	KEY_Page,		ButtonTable_AdvanceDelay_StageZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_AdvanceDelay_StageZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_AdvanceDelay_StageZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_AdvanceDelay_StageZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_AdvanceDelay_StageZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	AdvanceDelay_StageZero_Button21
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_AdvanceDelay_StageZero_Nop22
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_AdvanceDelay_StageZero_Nop22
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_AdvanceDelay_StageZero_Nop22
	on_key	KEY_PageAlt,		ButtonTable_AdvanceDelay_StageZero_Nop22
	on_key	KEY_Code1A,		ButtonTable_AdvanceDelay_StageZero_Nop22
	on_key	KEY_NumberPad,		NumberPadKey_AdvanceDelay_StageZero
	on_key	KEY_Code1C,		ButtonTable_AdvanceDelay_StageZero_Nop28
	on_key	KEY_Code1D,		ButtonTable_AdvanceDelay_StageZero_Nop28
	on_key	KEY_Compare,		ButtonTable_AdvanceDelay_StageZero_Nop28
	on_key	KEY_Code1F,		ButtonTable_AdvanceDelay_StageZero_Nop28
	keymap_end

; --- table 21 of 32: 17 distinct targets; named by the `ld XIX` at 0xF7D1EB
; ButtonTable_AdvanceDelay_StageNonZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D1DF loads it when (0x207E) is non-zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_AdvanceDelay_StageNonZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_AdvanceDelay_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_AdvanceDelay_StageNonZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_AdvanceDelay_StageNonZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_AdvanceDelay_StageNonZero_Nop3
	on_key	KEY_SoftKeyCol5,	ButtonTable_AdvanceDelay_StageNonZero_Nop4
	on_key	KEY_SoftKeyCol6,	ButtonTable_AdvanceDelay_StageNonZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_AdvanceDelay_StageNonZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_AdvanceDelay_StageNonZero_Nop7
	on_key	KEY_LcdRow1,		ButtonTable_AdvanceDelay_StageNonZero_Nop8
	on_key	KEY_LcdRow2,		ButtonTable_AdvanceDelay_StageNonZero_Nop9
	on_key	KEY_LcdRow3,		LcdKeyRow3_AdvanceDelay_StageNonZero
	on_key	KEY_LcdRow4,		LcdKeyRow4_AdvanceDelay_StageNonZero
	on_key	KEY_LcdRow5,		ButtonTable_AdvanceDelay_StageNonZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_AdvanceDelay_StageNonZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_AdvanceDelay_StageNonZero_Nop14
	on_key	KEY_Exit,		ExitKey_AdvanceDelay_StageNonZero
	on_key	KEY_Page,		ButtonTable_AdvanceDelay_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_AdvanceDelay_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_AdvanceDelay_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_AdvanceDelay_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_AdvanceDelay_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_AdvanceDelay_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_AdvanceDelay_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_AdvanceDelay_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_AdvanceDelay_StageNonZero_Nop16
	on_key	KEY_PageAlt,		ButtonTable_AdvanceDelay_StageNonZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_AdvanceDelay_StageNonZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_AdvanceDelay_StageNonZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_AdvanceDelay_StageNonZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_AdvanceDelay_StageNonZero_Nop16
	on_key	KEY_Compare,		ButtonTable_AdvanceDelay_StageNonZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_AdvanceDelay_StageNonZero_Nop16
	keymap_end

; --- table 22 of 32: 13 distinct targets; named by the `ld XIX` at 0xF7D200
; ButtonTable_S0ngC0py_StageZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D200 loads it when (0x207E) is zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_S0ngC0py_StageZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_S0ngC0py_StageZero
	on_key	KEY_SoftKeyCol2,	SoftKeyCol2_S0ngC0py_StageZero
	on_key	KEY_SoftKeyCol3,	SoftKeyCol3_S0ngC0py_StageZero
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_S0ngC0py_StageZero
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_S0ngC0py_StageZero
	on_key	KEY_SoftKeyCol6,	SoftKeyCol6_S0ngC0py_StageZero
	on_key	KEY_SoftKeyCol7,	SoftKeyCol7_S0ngC0py_StageZero
	on_key	KEY_SoftKeyCol8,	SoftKeyCol8_S0ngC0py_StageZero
	on_key	KEY_LcdRow1,		ButtonTable_S0ngC0py_StageZero_Nop8
	on_key	KEY_LcdRow2,		LcdKeyRow2_S0ngC0py_StageZero
	on_key	KEY_LcdRow3,		ButtonTable_S0ngC0py_StageZero_Nop10
	on_key	KEY_LcdRow4,		ButtonTable_S0ngC0py_StageZero_Nop10
	on_key	KEY_LcdRow5,		ButtonTable_S0ngC0py_StageZero_Nop10
	on_key	KEY_MinusPlus,		ButtonTable_S0ngC0py_StageZero_Nop10
	on_key	KEY_Code0E,		ButtonTable_S0ngC0py_StageZero_Nop10
	on_key	KEY_Exit,		ExitKey_S0ngC0py_StageZero
	on_key	KEY_Page,		ButtonTable_S0ngC0py_StageZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	SoftKeyCol1_S0ngC0py_StageZero
	on_key	KEY_SoftKeyCol2Alt,	SoftKeyCol2_S0ngC0py_StageZero
	on_key	KEY_SoftKeyCol3Alt,	SoftKeyCol3_S0ngC0py_StageZero
	on_key	KEY_SoftKeyCol4Alt,	SoftKeyCol4_S0ngC0py_StageZero
	on_key	KEY_SoftKeyCol5Alt,	SoftKeyCol5_S0ngC0py_StageZero
	on_key	KEY_SoftKeyCol6Alt,	SoftKeyCol6_S0ngC0py_StageZero
	on_key	KEY_SoftKeyCol7Alt,	SoftKeyCol7_S0ngC0py_StageZero
	on_key	KEY_SoftKeyCol8Alt,	SoftKeyCol8_S0ngC0py_StageZero
	on_key	KEY_PageAlt,		ButtonTable_S0ngC0py_StageZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_S0ngC0py_StageZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_S0ngC0py_StageZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_S0ngC0py_StageZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_S0ngC0py_StageZero_Nop16
	on_key	KEY_Compare,		ButtonTable_S0ngC0py_StageZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_S0ngC0py_StageZero_Nop16
	keymap_end

; --- table 23 of 32: 6 distinct targets; named by the `ld XIX` at 0xF7D20C
; ButtonTable_S0ngC0py_StageNonZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D200 loads it when (0x207E) is non-zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_S0ngC0py_StageNonZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_S0ngC0py_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_S0ngC0py_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol3,	ButtonTable_S0ngC0py_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol4,	ButtonTable_S0ngC0py_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol5,	ButtonTable_S0ngC0py_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol6,	ButtonTable_S0ngC0py_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol7,	ButtonTable_S0ngC0py_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol8,	ButtonTable_S0ngC0py_StageNonZero_Nop0
	on_key	KEY_LcdRow1,		ButtonTable_S0ngC0py_StageNonZero_Nop0
	on_key	KEY_LcdRow2,		LcdKeyRow2_S0ngC0py_StageNonZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_S0ngC0py_StageNonZero
	on_key	KEY_LcdRow4,		ButtonTable_S0ngC0py_StageNonZero_Nop11
	on_key	KEY_LcdRow5,		ButtonTable_S0ngC0py_StageNonZero_Nop11
	on_key	KEY_MinusPlus,		ButtonTable_S0ngC0py_StageNonZero_Nop11
	on_key	KEY_Code0E,		ButtonTable_S0ngC0py_StageNonZero_Nop11
	on_key	KEY_Exit,		ExitKey_S0ngC0py_StageNonZero
	on_key	KEY_Page,		ButtonTable_S0ngC0py_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_S0ngC0py_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_S0ngC0py_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_S0ngC0py_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_S0ngC0py_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_S0ngC0py_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_S0ngC0py_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_S0ngC0py_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_S0ngC0py_StageNonZero_Nop16
	on_key	KEY_PageAlt,		ButtonTable_S0ngC0py_StageNonZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_S0ngC0py_StageNonZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_S0ngC0py_StageNonZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_S0ngC0py_StageNonZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_S0ngC0py_StageNonZero_Nop16
	on_key	KEY_Compare,		ButtonTable_S0ngC0py_StageNonZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_S0ngC0py_StageNonZero_Nop16
	keymap_end

; --- table 24 of 32: 20 distinct targets; named by the `ld XIX` at 0xF7D221
; ButtonTable_N0teChange_StageZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D221 loads it when (0x207E) is zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_N0teChange_StageZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_N0teChange_StageZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_N0teChange_StageZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_N0teChange_StageZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_N0teChange_StageZero_Nop3
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_N0teChange_StageZero
	on_key	KEY_SoftKeyCol6,	ButtonTable_N0teChange_StageZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_N0teChange_StageZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_N0teChange_StageZero_Nop7
	on_key	KEY_LcdRow1,		ButtonTable_N0teChange_StageZero_Nop7
	on_key	KEY_LcdRow2,		LcdKeyRow2_N0teChange_StageZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_N0teChange_StageZero
	on_key	KEY_LcdRow4,		LcdKeyRow4_N0teChange_StageZero
	on_key	KEY_LcdRow5,		ButtonTable_N0teChange_StageZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_N0teChange_StageZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_N0teChange_StageZero_Nop14
	on_key	KEY_Exit,		ExitKey_N0teChange_StageZero
	on_key	KEY_Page,		ButtonTable_N0teChange_StageZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_N0teChange_StageZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_N0teChange_StageZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_N0teChange_StageZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_N0teChange_StageZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	N0teChange_StageZero_Button21
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_N0teChange_StageZero_Nop22
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_N0teChange_StageZero_Nop22
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_N0teChange_StageZero_Nop22
	on_key	KEY_PageAlt,		ButtonTable_N0teChange_StageZero_Nop22
	on_key	KEY_Code1A,		ButtonTable_N0teChange_StageZero_Nop22
	on_key	KEY_NumberPad,		NumberPadKey_N0teChange_StageZero
	on_key	KEY_Code1C,		ButtonTable_N0teChange_StageZero_Nop28
	on_key	KEY_Code1D,		ButtonTable_N0teChange_StageZero_Nop28
	on_key	KEY_Compare,		ButtonTable_N0teChange_StageZero_Nop28
	on_key	KEY_Code1F,		ButtonTable_N0teChange_StageZero_Nop28
	keymap_end

; --- table 25 of 32: 6 distinct targets; named by the `ld XIX` at 0xF7D22D
; ButtonTable_N0teChange_StageNonZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D221 loads it when (0x207E) is non-zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_N0teChange_StageNonZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_N0teChange_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_N0teChange_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol3,	ButtonTable_N0teChange_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol4,	ButtonTable_N0teChange_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol5,	ButtonTable_N0teChange_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol6,	ButtonTable_N0teChange_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol7,	ButtonTable_N0teChange_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol8,	ButtonTable_N0teChange_StageNonZero_Nop0
	on_key	KEY_LcdRow1,		ButtonTable_N0teChange_StageNonZero_Nop0
	on_key	KEY_LcdRow2,		ButtonTable_N0teChange_StageNonZero_Nop0
	on_key	KEY_LcdRow3,		ButtonTable_N0teChange_StageNonZero_Nop0
	on_key	KEY_LcdRow4,		LcdKeyRow4_N0teChange_StageNonZero
	on_key	KEY_LcdRow5,		LcdKeyRow5_N0teChange_StageNonZero
	on_key	KEY_MinusPlus,		ButtonTable_N0teChange_StageNonZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_N0teChange_StageNonZero_Nop13
	on_key	KEY_Exit,		ExitKey_N0teChange_StageNonZero
	on_key	KEY_Page,		ButtonTable_N0teChange_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_N0teChange_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_N0teChange_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_N0teChange_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_N0teChange_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_N0teChange_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_N0teChange_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_N0teChange_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_N0teChange_StageNonZero_Nop16
	on_key	KEY_PageAlt,		ButtonTable_N0teChange_StageNonZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_N0teChange_StageNonZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_N0teChange_StageNonZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_N0teChange_StageNonZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_N0teChange_StageNonZero_Nop16
	on_key	KEY_Compare,		ButtonTable_N0teChange_StageNonZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_N0teChange_StageNonZero_Nop16
	keymap_end

; --- table 26 of 32: 21 distinct targets; named by the `ld XIX` at 0xF7D242
; ButtonTable_MeasureC0py_StageZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D242 loads it when (0x207E) is zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_MeasureC0py_StageZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_MeasureC0py_StageZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_MeasureC0py_StageZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_MeasureC0py_StageZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_MeasureC0py_StageZero_Nop3
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_MeasureC0py_StageZero
	on_key	KEY_SoftKeyCol6,	ButtonTable_MeasureC0py_StageZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_MeasureC0py_StageZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_MeasureC0py_StageZero_Nop7
	on_key	KEY_LcdRow1,		LcdKeyRow1_MeasureC0py_StageZero
	on_key	KEY_LcdRow2,		LcdKeyRow2_MeasureC0py_StageZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_MeasureC0py_StageZero
	on_key	KEY_LcdRow4,		LcdKeyRow4_MeasureC0py_StageZero
	on_key	KEY_LcdRow5,		ButtonTable_MeasureC0py_StageZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_MeasureC0py_StageZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_MeasureC0py_StageZero_Nop14
	on_key	KEY_Exit,		ExitKey_MeasureC0py_StageZero
	on_key	KEY_Page,		ButtonTable_MeasureC0py_StageZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_MeasureC0py_StageZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_MeasureC0py_StageZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_MeasureC0py_StageZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_MeasureC0py_StageZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	MeasureC0py_StageZero_Button21
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_MeasureC0py_StageZero_Nop22
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_MeasureC0py_StageZero_Nop22
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_MeasureC0py_StageZero_Nop22
	on_key	KEY_PageAlt,		ButtonTable_MeasureC0py_StageZero_Nop22
	on_key	KEY_Code1A,		ButtonTable_MeasureC0py_StageZero_Nop22
	on_key	KEY_NumberPad,		NumberPadKey_MeasureC0py_StageZero
	on_key	KEY_Code1C,		ButtonTable_MeasureC0py_StageZero_Nop28
	on_key	KEY_Code1D,		ButtonTable_MeasureC0py_StageZero_Nop28
	on_key	KEY_Compare,		ButtonTable_MeasureC0py_StageZero_Nop28
	on_key	KEY_Code1F,		ButtonTable_MeasureC0py_StageZero_Nop28
	keymap_end

; --- table 27 of 32: 16 distinct targets; named by the `ld XIX` at 0xF7D24E
; ButtonTable_MeasureC0py_StageNonZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D242 loads it when (0x207E) is non-zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_MeasureC0py_StageNonZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_MeasureC0py_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_MeasureC0py_StageNonZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_MeasureC0py_StageNonZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_MeasureC0py_StageNonZero_Nop3
	on_key	KEY_SoftKeyCol5,	ButtonTable_MeasureC0py_StageNonZero_Nop4
	on_key	KEY_SoftKeyCol6,	ButtonTable_MeasureC0py_StageNonZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_MeasureC0py_StageNonZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_MeasureC0py_StageNonZero_Nop7
	on_key	KEY_LcdRow1,		LcdKeyRow1_MeasureC0py_StageNonZero
	on_key	KEY_LcdRow2,		ButtonTable_MeasureC0py_StageNonZero_Nop9
	on_key	KEY_LcdRow3,		ButtonTable_MeasureC0py_StageNonZero_Nop10
	on_key	KEY_LcdRow4,		ButtonTable_MeasureC0py_StageNonZero_Nop10
	on_key	KEY_LcdRow5,		LcdKeyRow5_MeasureC0py_StageNonZero
	on_key	KEY_MinusPlus,		ButtonTable_MeasureC0py_StageNonZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_MeasureC0py_StageNonZero_Nop14
	on_key	KEY_Exit,		ExitKey_MeasureC0py_StageNonZero
	on_key	KEY_Page,		ButtonTable_MeasureC0py_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_MeasureC0py_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_MeasureC0py_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_MeasureC0py_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_MeasureC0py_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_MeasureC0py_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_MeasureC0py_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_MeasureC0py_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_MeasureC0py_StageNonZero_Nop16
	on_key	KEY_PageAlt,		ButtonTable_MeasureC0py_StageNonZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_MeasureC0py_StageNonZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_MeasureC0py_StageNonZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_MeasureC0py_StageNonZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_MeasureC0py_StageNonZero_Nop16
	on_key	KEY_Compare,		ButtonTable_MeasureC0py_StageNonZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_MeasureC0py_StageNonZero_Nop16
	keymap_end

; --- table 28 of 32: 21 distinct targets; named by the `ld XIX` at 0xF7D263
; ButtonTable_MeasureInsert_StageZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D263 loads it when (0x207E) is zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_MeasureInsert_StageZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_MeasureInsert_StageZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_MeasureInsert_StageZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_MeasureInsert_StageZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_MeasureInsert_StageZero_Nop3
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_MeasureInsert_StageZero
	on_key	KEY_SoftKeyCol6,	ButtonTable_MeasureInsert_StageZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_MeasureInsert_StageZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_MeasureInsert_StageZero_Nop7
	on_key	KEY_LcdRow1,		LcdKeyRow1_MeasureInsert_StageZero
	on_key	KEY_LcdRow2,		LcdKeyRow2_MeasureInsert_StageZero
	on_key	KEY_LcdRow3,		LcdKeyRow3_MeasureInsert_StageZero
	on_key	KEY_LcdRow4,		LcdKeyRow4_MeasureInsert_StageZero
	on_key	KEY_LcdRow5,		ButtonTable_MeasureInsert_StageZero_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_MeasureInsert_StageZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_MeasureInsert_StageZero_Nop14
	on_key	KEY_Exit,		ExitKey_MeasureInsert_StageZero
	on_key	KEY_Page,		ButtonTable_MeasureInsert_StageZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_MeasureInsert_StageZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_MeasureInsert_StageZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_MeasureInsert_StageZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_MeasureInsert_StageZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	MeasureInsert_StageZero_Button21
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_MeasureInsert_StageZero_Nop22
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_MeasureInsert_StageZero_Nop22
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_MeasureInsert_StageZero_Nop22
	on_key	KEY_PageAlt,		ButtonTable_MeasureInsert_StageZero_Nop22
	on_key	KEY_Code1A,		ButtonTable_MeasureInsert_StageZero_Nop22
	on_key	KEY_NumberPad,		NumberPadKey_MeasureInsert_StageZero
	on_key	KEY_Code1C,		ButtonTable_MeasureInsert_StageZero_Nop28
	on_key	KEY_Code1D,		ButtonTable_MeasureInsert_StageZero_Nop28
	on_key	KEY_Compare,		ButtonTable_MeasureInsert_StageZero_Nop28
	on_key	KEY_Code1F,		ButtonTable_MeasureInsert_StageZero_Nop28
	keymap_end

; --- table 29 of 32: 17 distinct targets; named by the `ld XIX` at 0xF7D26F
; ButtonTable_MeasureInsert_StageNonZero -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D263 loads it when (0x207E) is non-zero.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_MeasureInsert_StageNonZero:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_MeasureInsert_StageNonZero_Nop0
	on_key	KEY_SoftKeyCol2,	ButtonTable_MeasureInsert_StageNonZero_Nop1
	on_key	KEY_SoftKeyCol3,	ButtonTable_MeasureInsert_StageNonZero_Nop2
	on_key	KEY_SoftKeyCol4,	ButtonTable_MeasureInsert_StageNonZero_Nop3
	on_key	KEY_SoftKeyCol5,	ButtonTable_MeasureInsert_StageNonZero_Nop4
	on_key	KEY_SoftKeyCol6,	ButtonTable_MeasureInsert_StageNonZero_Nop5
	on_key	KEY_SoftKeyCol7,	ButtonTable_MeasureInsert_StageNonZero_Nop6
	on_key	KEY_SoftKeyCol8,	ButtonTable_MeasureInsert_StageNonZero_Nop7
	on_key	KEY_LcdRow1,		LcdKeyRow1_MeasureInsert_StageNonZero
	on_key	KEY_LcdRow2,		ButtonTable_MeasureInsert_StageNonZero_Nop9
	on_key	KEY_LcdRow3,		ButtonTable_MeasureInsert_StageNonZero_Nop10
	on_key	KEY_LcdRow4,		ButtonTable_MeasureInsert_StageNonZero_Nop11
	on_key	KEY_LcdRow5,		LcdKeyRow5_MeasureInsert_StageNonZero
	on_key	KEY_MinusPlus,		ButtonTable_MeasureInsert_StageNonZero_Nop13
	on_key	KEY_Code0E,		ButtonTable_MeasureInsert_StageNonZero_Nop14
	on_key	KEY_Exit,		ExitKey_MeasureInsert_StageNonZero
	on_key	KEY_Page,		ButtonTable_MeasureInsert_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_MeasureInsert_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol2Alt,	ButtonTable_MeasureInsert_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol3Alt,	ButtonTable_MeasureInsert_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_MeasureInsert_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol5Alt,	ButtonTable_MeasureInsert_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_MeasureInsert_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol7Alt,	ButtonTable_MeasureInsert_StageNonZero_Nop16
	on_key	KEY_SoftKeyCol8Alt,	ButtonTable_MeasureInsert_StageNonZero_Nop16
	on_key	KEY_PageAlt,		ButtonTable_MeasureInsert_StageNonZero_Nop16
	on_key	KEY_Code1A,		ButtonTable_MeasureInsert_StageNonZero_Nop16
	on_key	KEY_NumberPad,		ButtonTable_MeasureInsert_StageNonZero_Nop16
	on_key	KEY_Code1C,		ButtonTable_MeasureInsert_StageNonZero_Nop16
	on_key	KEY_Code1D,		ButtonTable_MeasureInsert_StageNonZero_Nop16
	on_key	KEY_Compare,		ButtonTable_MeasureInsert_StageNonZero_Nop16
	on_key	KEY_Code1F,		ButtonTable_MeasureInsert_StageNonZero_Nop16
	keymap_end

; --- table 30 of 32: 12 distinct targets; named by the `ld XIX` at 0xF7D294
; ButtonTable_StepRecordPartSelect -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D294 loads it with a single `ld XIX,0x00F7E1D8`.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_StepRecordPartSelect:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_StepRecordPartSelect
	on_key	KEY_SoftKeyCol2,	SoftKeyCol2_StepRecordPartSelect
	on_key	KEY_SoftKeyCol3,	SoftKeyCol3_StepRecordPartSelect
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_StepRecordPartSelect
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_StepRecordPartSelect
	on_key	KEY_SoftKeyCol6,	SoftKeyCol6_StepRecordPartSelect
	on_key	KEY_SoftKeyCol7,	SoftKeyCol7_StepRecordPartSelect
	on_key	KEY_SoftKeyCol8,	SoftKeyCol8_StepRecordPartSelect
	on_key	KEY_LcdRow1,		ButtonTable_StepRecordPartSelect_Nop8
	on_key	KEY_LcdRow2,		ButtonTable_StepRecordPartSelect_Nop9
	on_key	KEY_LcdRow3,		ButtonTable_StepRecordPartSelect_Nop9
	on_key	KEY_LcdRow4,		ButtonTable_StepRecordPartSelect_Nop9
	on_key	KEY_LcdRow5,		ButtonTable_StepRecordPartSelect_Nop9
	on_key	KEY_MinusPlus,		ButtonTable_StepRecordPartSelect_Nop9
	on_key	KEY_Code0E,		ButtonTable_StepRecordPartSelect_Nop9
	on_key	KEY_Exit,		ExitKey_StepRecordPartSelect
	on_key	KEY_Page,		ButtonTable_StepRecordPartSelect_Nop16
	on_key	KEY_SoftKeyCol1Alt,	SoftKeyCol1_StepRecordPartSelect
	on_key	KEY_SoftKeyCol2Alt,	SoftKeyCol2_StepRecordPartSelect
	on_key	KEY_SoftKeyCol3Alt,	SoftKeyCol3_StepRecordPartSelect
	on_key	KEY_SoftKeyCol4Alt,	SoftKeyCol4_StepRecordPartSelect
	on_key	KEY_SoftKeyCol5Alt,	SoftKeyCol5_StepRecordPartSelect
	on_key	KEY_SoftKeyCol6Alt,	SoftKeyCol6_StepRecordPartSelect
	on_key	KEY_SoftKeyCol7Alt,	SoftKeyCol7_StepRecordPartSelect
	on_key	KEY_SoftKeyCol8Alt,	SoftKeyCol8_StepRecordPartSelect
	on_key	KEY_PageAlt,		ButtonTable_StepRecordPartSelect_Nop16
	on_key	KEY_Code1A,		ButtonTable_StepRecordPartSelect_Nop16
	on_key	KEY_NumberPad,		ButtonTable_StepRecordPartSelect_Nop16
	on_key	KEY_Code1C,		ButtonTable_StepRecordPartSelect_Nop16
	on_key	KEY_Code1D,		ButtonTable_StepRecordPartSelect_Nop16
	on_key	KEY_Compare,		ButtonTable_StepRecordPartSelect_Nop16
	on_key	KEY_Code1F,		ButtonTable_StepRecordPartSelect_Nop16
	keymap_end

; --- table 31 of 32: 16 distinct targets; named by the `ld XIX` at 0xF7D2A9
; ButtonTable_SequencerMedley -- the 32 panel-button handlers of this screen
; Evidence: the +8 Button stub at 0xF7D2A9 loads it with a single `ld XIX,0x00F7E258`.
;           Round 7 established that the 32 tables are indexed
;           by the panel BUTTON NUMBER (two independent 5-bit masks
;           over a 128-byte table), so what the object needs is the
;           SCREEN that owns the map -- which is this name.
;           (0x207E) is UI_ScreenStage: 0 = the parameter page,
;           non-zero = the "Are You Sure ?" page
;           (wsa1/notes/FINDINGS-prom_ab-screen-stage-and-flags.md).
;           Promoted from the framed `Table_<address>` spelling by
;           notes/prom_b_screens_round8.py --promote --apply
ButtonTable_SequencerMedley:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ButtonTable_SequencerMedley_Nop0
	on_key	KEY_SoftKeyCol2,	SoftKeyCol2_SequencerMedley
	on_key	KEY_SoftKeyCol3,	SoftKeyCol3_SequencerMedley
	on_key	KEY_SoftKeyCol4,	ButtonTable_SequencerMedley_Nop3
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_SequencerMedley
	on_key	KEY_SoftKeyCol6,	ButtonTable_SequencerMedley_Nop5
	on_key	KEY_SoftKeyCol7,	SoftKeyCol7_SequencerMedley
	on_key	KEY_SoftKeyCol8,	SoftKeyCol8_SequencerMedley
	on_key	KEY_LcdRow1,		ButtonTable_SequencerMedley_Nop8
	on_key	KEY_LcdRow2,		LcdKeyRow2_SequencerMedley
	on_key	KEY_LcdRow3,		LcdKeyRow3_SequencerMedley
	on_key	KEY_LcdRow4,		LcdKeyRow4_SequencerMedley
	on_key	KEY_LcdRow5,		ButtonTable_SequencerMedley_Nop12
	on_key	KEY_MinusPlus,		ButtonTable_SequencerMedley_Nop12
	on_key	KEY_Code0E,		ButtonTable_SequencerMedley_Nop12
	on_key	KEY_Exit,		ExitKey_SequencerMedley
	on_key	KEY_Page,		ButtonTable_SequencerMedley_Nop12
	on_key	KEY_SoftKeyCol1Alt,	ButtonTable_SequencerMedley_Nop12
	on_key	KEY_SoftKeyCol2Alt,	SoftKeyCol2_SequencerMedley
	on_key	KEY_SoftKeyCol3Alt,	SoftKeyCol3_SequencerMedley
	on_key	KEY_SoftKeyCol4Alt,	ButtonTable_SequencerMedley_Nop3
	on_key	KEY_SoftKeyCol5Alt,	SoftKeyCol5_SequencerMedley
	on_key	KEY_SoftKeyCol6Alt,	ButtonTable_SequencerMedley_Nop12
	on_key	KEY_SoftKeyCol7Alt,	SoftKeyCol7_SequencerMedley
	on_key	KEY_SoftKeyCol8Alt,	SoftKeyCol8_SequencerMedley
	on_key	KEY_PageAlt,		ButtonTable_SequencerMedley_Nop12
	on_key	KEY_Code1A,		ButtonTable_SequencerMedley_Nop12
	on_key	KEY_NumberPad,		NumberPadKey_SequencerMedley
	on_key	KEY_Code1C,		ButtonTable_SequencerMedley_Nop28
	on_key	KEY_Code1D,		ButtonTable_SequencerMedley_Nop28
	on_key	KEY_Compare,		ButtonTable_SequencerMedley_Nop28
	on_key	KEY_Code1F,		ButtonTable_SequencerMedley_Nop28
	keymap_end

; ==============================================================================
; 0xF7E2D8-0xF7FFFF -- THE PANEL-SCREEN METHOD BLOCK: 15 Enter bodies, 15 Leave
; targets (three of them a bare `ret`), one Button body, 124 button handlers,
; and five blink-template pointer tables
; ==============================================================================
;
; 7464 bytes.  This is the other half of the block above it: 0xF7D000-0xF7E2D7
; holds the 25 screens' four-word method STUBS and their 32 button tables,
; and every stub is a one-line forwarder into the bytes below.
;
; ★ THE NAMES.  A screen's Enter body draws the screen, and the leading run
; of op-0x1C records in the display list it hands the interpreter spells the
; screen's own title.  That is round 7's rule and it is CALIBRATED, not
; asserted: seven screens whose Enter body is in prom_a carry names prom_a
; derived independently months earlier, and the rule reproduces all seven as
; a prefix and six exactly.  Re-run it with
;     python3 notes/prom_b_screens_round8.py --calibrate
; 14 routines here draw a titled list and are named Paint_<Title>, keeping
; the ROM's own spelling -- VEL0CITY, TRANSP0SE, zeros for O's included.
;
; ★ TWO ROUTINES ARE prom_a ROUTINES.  0xF7E2D9 is byte-identical to prom_a's
; LCD_ScreenRedraw_Begin (0xF999F0) over both whole extents -- 14 bytes, 0
; differing -- and 0xF7E2E7 to LCD_ScreenRedraw_End (0xF999FE), 6 bytes, 0
; differing.  They keep prom_a's spelling so the pair reads as one object.
;
; ★★ ROUND 11: THE BUTTON NUMBER NOW HAS A VOCABULARY, AND IT NAMES 26 OF
; THE 124 HANDLERS -- NOT 124.  The chain is SW -> wire -> group ->
; event-list record -> 5-bit code -> table slot -> handler, and every link is
; read from the ROM by notes/prom_b_panel_names_round11.py.
;
; ★ WHICH WIRE MAP BELONGS TO THIS PANEL, measured, not assumed.  prom_a picks
; between two maps at 0xF8A851 (`cp (0xC4),0x01`; variant 1 on equal, variant 2
; otherwise).  Over the matrix wires 0xC0-0xCF, variant 2's event lists claim
; 58 matrix bits and the set of switches they name is EQUAL to the 58 the
; service manual's two diode lists fit -- a bijection.  Variant 1 claims 87,
; of which 29 sit at positions with no switch (all of segment 6, and a segment
; 10 the manual's numbering never reaches), and it has three pairs of
; byte-identical group lists where variant 2 has none.
; ⚠ That does NOT prove variant 1 is never selected -- nothing here reads
; (0xC4).  It licences something narrower: for the codes named below the
; FITTED producers are identical under both maps, because every extra producer
; variant 1 adds for them has no switch behind it.
;
; ★ THE FOUR CODES THAT SURVIVE EVERY REFUSAL
;   0x0F  EXIT (SW32).  Slot 0x0F is the ONLY one of the 32 slots that holds a
;         real routine in ALL 32 tables, and its 32 handlers are 32 DISTINCT
;         routines -- every screen must handle EXIT.  (In the 23-entry
;         dispatch family its slot 15 is also filled in all four tables, but
;         so are slots 1, 2, 4 and 5, so that family proves nothing extra.)
;   0x1B  the NUMBER PAD (SW9-SW20), delivered as whole fields.
;   0x0D  the -1/+1 pair (SW30, SW31).  ⚠ NOT the rotary DATA dial: that is
;         code 0x21 on wire 0xD7, split off before any table lookup.  The
;         paragraph this replaces called 0x0D "the data dial" and was wrong.
;   0x10  PAGE (SW21, SW22) -- named only in the 23-entry dispatch family,
;         because in THIS family its two handlers also sit at slot 0x19.
;
; ⚠ AND THE 98 REFUSALS, each stated in its own header rather than left blank:
;   * 62 are the LCD SIDE KEYS (codes 0x08-0x0C).  The class is solid and the
;     five siblings differ only by ROW -- a bare number, which is the shape
;     round 6 refused (Write3602_Index5).
;   * 22 are codes 0x04-0x07 and their base+0x11 twins -- round 10's
;     COLLISION.  Under variant 1 two byte-identical group lists send an
;     LCD-RIGHT key and a SOFT KEY to one code, and both switches are fitted,
;     so the collision is not a variant artefact.
;   * 11 are codes 0x00-0x03 and their twins: SOFT KEYS under both maps,
;     but variant 1 puts code 0x00 on column 5 and variant 2 on column 1, and
;     the column is the only thing that would separate four sibling names.
;   * 1 is code 0x0E, WHICH NO WIRE PRODUCES in either map.  Of the 1,024
;     slots here it is the only slot-0x0E entry that is not a bare `ret`, and
;     both its branches reach the same `ret`.
;   * 2 are the {0x10, 0x19} pair -- one routine serving PAGE and also
;     the code the action handlers write over a held soft-key base.
;
; ★ A CONFIRMATION ROUND 10 COULD NOT MAKE.  It read `add (XIX-1),0x11` at
; 0xF8AE7E and predicted an alternate code set; it never checked a consumer.
; Here, 13 routines are installed at exactly two slots and those two are
; exactly {n, n+0x11}; no routine is installed at two slots in any other
; relation except the {0x10, 0x19} pair.
;
; The service screen that would be the natural place for a switch list,
; Paint_PanelSwLedCheck, draws "Please push a any button." and no per-switch
; text; the vocabulary came from the service manual's page 32 instead.
;
; ⚠ 190 ADDRESSES IN HERE ARE ENTRY POINTS AND CARRY NO LABEL, ON PURPOSE.
; 510 of the 649 button-table slots that land in this span (78.6%) point at a
; single `ret` BYTE -- an unused button on that screen, pointed at whatever
; `ret` happens to end the routine above it.  They are annotated where they
; fall, as a trailing comment on the `ret` line, because 190 framed labels
; saying one thing 190 times is not documentation.
;
; ★ THE FIVE POINTER TABLES ARE FOUND BY THEIR OWN READERS.  Each is the
; immediate of an `ld XIY,imm32` inside this span, followed by
; `ld XIY,(XIY+WA)`, `push XIY` and `call 0xF42E20` = T_Blink_Command ->
; prom_b 0xF0E9CF (notes/FINDINGS-prom_b-field-blink.md).  Same shape, same
; callee and the same two leading NULL entries as prom_a's BlinkArgPtrs_F8024D.
; ⚠ NOTHING BOUNDS THE INDEX, so the entry counts below are 'words that fit
; before the code resumes' -- the same claim prom_a's header makes -- and the
; tables keep FRAMED names.
;
; ★ THE FOUR SCREENS ROUND 7 LEFT UNNAMED STAY UNNAMED, and now the reason is
; exact: 0xF43040's Enter (0xF7E971, three instructions, here) draws no display
; list at all; 0xF43048's is prom_a ModeEnterBody_StepRecord and draws none; and 0xF43160
; and 0xF431D0 SHARE ONE ENTER METHOD, prom_a ScreenEnterBody_StepRecord -- so a rule that
; names a screen after what its Enter draws cannot separate those two even in
; principle.  `--screens4` prints it from the ROM.
;
; Re-derive all of it, and the naming cost, with
;     python3 notes/prom_b_screens_round8.py --selftest --buttons --cost
;     python3 notes/gen_prom_b_f7e2d8_module.py --selftest --cost
; ==============================================================================

ButtonTable_SequencerMedley_Nop:
	ret	; F7E2D8  ret

; ------------------------------------------------------------------------------
; 0xF7E2D9-0xF7E2EC -- LCD_ScreenRedraw_Begin and LCD_ScreenRedraw_End
;
; ★ MOVED to maincpu/shared/lcd_screen_redraw.s, ONE SOURCE included at BOTH of its
; sites: here and prom_a 0xF999F0.  The two copies are byte-identical,
; every reference binds to the nearer of them, and the header that used to sit
; here is in that file, verbatim, under a banner saying it came from this one.
; Why the duplication exists at all -- and why the obvious explanation is wrong
; -- is measured by `python3 notes/maincpu_join_probe.py --callers --nearest`.
; ------------------------------------------------------------------------------
	.include "maincpu/shared/lcd_screen_redraw.s"

; Evidence: reached from call from prom_b 0xF7EEF4, and from nothing else
;           the scans see.
; LCD_ClearCurrentLayer: Runs DL_F39551, a single op-0E record (IY 0, BC 0x28, HL 0xF0) = SWI7 service 0x0E
;   LCD_Svc_0E_ClearColumns over 40 byte-columns x 240 rows: zeroes the WHOLE layer (0x2540) selects. Every caller
;   stores LCD_CurrentLayer first: Paint_StepRecord (layers 0, 1, 2), Paint_StepRecordTrackClrMeas, sub_F81C90,
;   TrackMerge_DrawFieldHighlight (layer 1). Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_g.json)
LCD_ClearCurrentLayer:
	ld	xiy, DL_F39551	; F7E2ED  ld XIY,0x00f39551
	ld	xix, Data_F39559	; F7E2F2  ld XIX,0x00f39559
	call	T_DisplayList_Run	; F7E2F7  call 0xf417f0
	ret	; F7E2FB  ret

; Evidence: reached from call from prom_b 0xF7E57C; calr from prom_b
;           0xF7E4A4, and from nothing else the scans see.
; TrackAssign_DrawSelectedPart: TRACK ASSIGN: draws, on layer 0, the part being chosen (0x0C06) as 'PART n' in the
;   selected track's cell -- record (0x0C03) of TrackAssign_DrawSelectedPart_DL -- then one of two lists by (0x0DC0) bit 0.
;   Paint_TrackAssign and the track/part keys call it after they change (0x0C03)/(0x0C06). Basis: callers + body.
;   (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
TrackAssign_DrawSelectedPart:
	or	(0xc6:8), 0x01	; F7E2FC  or (0xc6),0x01
	or	(UI_RequestBits:16), 0x08	; F7E300  or (0x2075),0x08
	ld	(LCD_CurrentLayer:16), 0	; F7E305  ld (0x2540),0x00
	ld	a, (3078:16)	; F7E30A  ld A,(0x0c06)
	ld	(DisplayListB_Stage+5:16), a	; F7E30E  ld (0x12fb),A
	ld	xiy, TrackAssign_DrawSelectedPart_DL	; F7E312  ld XIY,0x00f39737
	ld	l, (3075:16)	; F7E317  ld L,(0x0c03)
	xor	h, h	; F7E31B  xor H,H
	muls	hl, 15	; F7E31D  muls HL,0x000f
	add	xiy, xhl	; F7E321  add XIY,XHL
	call	T_DLB_Handler_StringTable	; F7E323  call 0xf417f8
	ld	(LCD_CurrentLayer:16), 0	; F7E327  ld (0x2540),0x00
	ld	a, (3520:16)	; F7E32C  ld A,(0x0dc0)
	and	a, 1	; F7E330  and A,0x01
	jr	z, TrackAssign_DrawSelectedPart_Skip	; F7E333  jr Z,0xf7e345
	ld	xiy, DL_F39854	; F7E335  ld XIY,0x00f39854
	ld	xix, DL_F39870	; F7E33A  ld XIX,0x00f39870
	call	T_DisplayList_Run	; F7E33F  call 0xf417f0
	jr	TrackAssign_DrawSelectedPart_Return	; F7E343  jr T,0xf7e353
TrackAssign_DrawSelectedPart_Skip:
	ld	xiy, DL_F39870	; F7E345  ld XIY,0x00f39870
	ld	xix, DL_F3987A	; F7E34A  ld XIX,0x00f3987a
	call	T_DisplayList_Run	; F7E34F  call 0xf417f0
TrackAssign_DrawSelectedPart_Return:
	ret	; F7E353  ret

; Evidence: reached from call from prom_b 0xF7EC9C; call from prom_b
;           0xF7ECD5, and from nothing else the scans see.
; TrackGrid_DrawPartLabels: Copies the 16 BStore_TrackToPart bytes to DisplayListB_Stage (part 13 drawn as 14 except
;   on screens 0x0F, 0x12, 0x1C) and runs TrackGrid_DrawPartLabels_DL, 16 string-table readouts of 'P 1'..'P32' (Data_F39559 + 0x49, 3
;   bytes each). The track-grid layout of SeqScreen_DrawTrackPartLabels; called by the TRACK CLEAR and STEP RECORD
;   PART SELECT painters. Basis: callers + body + twin. (notes/naming-pilot-2026-10-06/proposals_wave3_j.json)
TrackGrid_DrawPartLabels:
	ld	xiy, BStore_TrackToPart	; F7E354  ld XIY,0x00603422
	ld	xix, DisplayListB_Stage	; F7E359  ld XIX,0x000012f6
	ld	c, 16:opc	; F7E35E  ld C,0x10
TrackGrid_DrawPartLabels_Join:
	ld	a, (xiy)	; F7E360  ld A,(XIY)
	ld	e, (UI_ScreenId:16)	; F7E362  ld E,(0x207c)
	cp	e, 18	; F7E366  cp E,0x12
	jr	z, TrackGrid_DrawPartLabels_Join2	; F7E369  jr Z,0xf7e37e
	cp	e, 28	; F7E36B  cp E,0x1c
	jr	z, TrackGrid_DrawPartLabels_Join2	; F7E36E  jr Z,0xf7e37e
	cp	e, 15	; F7E370  cp E,0x0f
	jr	nz, TrackGrid_DrawPartLabels_Skip	; F7E373  jr NZ,0xf7e377
	jr	TrackGrid_DrawPartLabels_Join2	; F7E375  jr T,0xf7e37e
TrackGrid_DrawPartLabels_Skip:
	cp	a, 13	; F7E377  cp A,0x0d
	jr	nz, TrackGrid_DrawPartLabels_Join2	; F7E37A  jr NZ,0xf7e37e
	inc	1, a	; F7E37C  inc 1,A
TrackGrid_DrawPartLabels_Join2:
	ld	(xix), a	; F7E37E  ld (XIX),A
	dec	1, c	; F7E380  dec 1,C
	jr	z, TrackGrid_DrawPartLabels_Skip2	; F7E382  jr Z,0xf7e38a
	inc	1, xiy	; F7E384  inc 1,XIY
	inc	1, xix	; F7E386  inc 1,XIX
	jr	TrackGrid_DrawPartLabels_Join	; F7E388  jr T,0xf7e360
TrackGrid_DrawPartLabels_Skip2:
	ld	xiy, TrackGrid_DrawPartLabels_DL	; F7E38A  ld XIY,0x00f3a1cf
	ld	xix, DL_TrackAssignPresetsTechnicsSetUp1116	; F7E38F  ld XIX,0x00f3a2bf
	call	T_DisplayListB_Run	; F7E394  call 0xf417f4
	and	(0xc6:8), 0xfe	; F7E398  and (0xc6),0xfe
	ret	; F7E39C  ret
	ret	; F7E39D  ret
	ret	; F7E39E  ret

; Evidence: reached from call from prom_b 0xF7ECF0; calr from prom_b
;           0xF7ECB7, and from nothing else the scans see.
; TrackClear_DrawTrackSelection: HL = the TRACK CLEAR selection mask (0x0DBE): on layer 1 runs DL_F3A0D1 (an op-0E
;   clear), then for tracks 0..15 sets DisplayListB_Stage = the track and draws record Data_F3A0D9
;   (T_DLB_Handler_Array8) when its bit is set, Data_F3A0E4 (T_DLB_Handler_Array6) when clear; nothing per track when
;   HL = 0. Paint_TrackClear calls it on both of its paths. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave7_z.json)
TrackClear_DrawTrackSelection:
	ld	(LCD_CurrentLayer:16), 1	; F7E39F  ld (0x2540),0x01
	ld	xiy, DL_F3A0D1	; F7E3A4  ld XIY,0x00f3a0d1
	ld	xix, Data_F3A0D9	; F7E3A9  ld XIX,0x00f3a0d9
	pushw	hl	; F7E3AE  push HL
	call	T_DisplayList_Run	; F7E3AF  call 0xf417f0
	popw	hl	; F7E3B3  pop HL
	cp	hl, 0:i3	; F7E3B4  cp HL,0
	jr	nz, TrackClear_DrawTrackSelection_Skip	; F7E3B6  jr NZ,0xf7e3ba
	jr	TrackClear_DrawTrackSelection_Return	; F7E3B8  jr T,0xf7e3f3
TrackClear_DrawTrackSelection_Skip:
	ldw	wa, 1	; F7E3BA  ld WA,0x0001
	xor	c, c	; F7E3BD  xor C,C
TrackClear_DrawTrackSelection_Loop:
	pushw	wa	; F7E3BF  push WA
	calr	ButtonTable_SequencerMedley_Nop	; F7E3C0  calr 0xf7e2d8
	popw	wa	; F7E3C3  pop WA
	ld	(DisplayListB_Stage:16), c	; F7E3C4  ld (0x12f6),C
	pushw	wa	; F7E3C8  push WA
	pushw	hl	; F7E3C9  push HL
	pushw	bc	; F7E3CA  push BC
	ldfr_werp	hl, 0x3c	; F7E3CB  ld RHL3,HL
	and	hl, wa	; F7E3CE  and HL,WA
	ldto_werp	hl, 0x3c	; F7E3D0  ld HL,RHL3
	jr	z, TrackClear_DrawTrackSelection_Skip2	; F7E3D3  jr Z,0xf7e3e0
	ld	xiy, Data_F3A0D9	; F7E3D5  ld XIY,0x00f3a0d9
	call	T_DLB_Handler_Array8	; F7E3DA  call 0xf4181c
	jr	TrackClear_DrawTrackSelection_Join	; F7E3DE  jr T,0xf7e3e9
TrackClear_DrawTrackSelection_Skip2:
	ld	xiy, Data_F3A0E4	; F7E3E0  ld XIY,0x00f3a0e4
	call	T_DLB_Handler_Array6	; F7E3E5  call 0xf41824
TrackClear_DrawTrackSelection_Join:
	popw	bc	; F7E3E9  pop BC
	popw	hl	; F7E3EA  pop HL
	popw	wa	; F7E3EB  pop WA
	inc	1, c	; F7E3EC  inc 1,C
	sla	wa, 1	; F7E3EE  sla 0x01,WA
	jr	nc, TrackClear_DrawTrackSelection_Loop	; F7E3F1  jr NC,0xf7e3bf
TrackClear_DrawTrackSelection_Return:
	ret	; F7E3F3  ret
	ret	; F7E3F4  ret

; ---------------------------------------------------------------------
; Paint_AfterT0uchSetting -- paints the panel screen whose own title text
;                            reads "AFTER T0UCH SETTING"
;
; Reached by: the +0 method stub of screen object 0xF43180, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D192
; Evidence: the routine loads XIY = 0xF3BAB9 and calls the display-list
;           interpreter; the leading run of op-0x1C records in that list
;           spells "AFTER T0UCH SETTING", and the name is that text
;           CamelCased, with the ROM's own spelling kept (zeros for O's
;           included). The rule is round 7's, calibrated on seven screens
;           prom_a had named independently: notes/prom_b_screens_round8.py
;           --calibrate.
; ---------------------------------------------------------------------
Paint_AfterT0uchSetting:
	call	T_CallbackQueue_ResetAndRestartTask2	; F7E3F5  call 0xf42e80
	call	LCD_ScreenRedraw_Begin	; F7E3F9  call 0xf7e2d9
	ld	(LCD_CurrentLayer:16), 0	; F7E3FD  ld (0x2540),0x00
	ld	xiy, DL_AfterT0uchSettingSelectWhetherOrNotAfter	; F7E402  ld XIY,0x00f3bab9
	ld	xix, DL_AfterTouchRecord	; F7E407  ld XIX,0x00f3bb7e
	call	T_DisplayList_Run	; F7E40C  call 0xf417f0
	ld	a, (32706:16)	; F7E410  ld A,(0x7fc2)
	ld	(DisplayListB_Stage:16), a	; F7E414  ld (0x12f6),A
	call	Draw_AfterTouchRecord	; F7E418  call 0xf7e421
	call	LCD_ScreenRedraw_End	; F7E41C  call 0xf7e2e7
	ret	; F7E420  ret

; Evidence: reached from call from prom_b 0xF7D1C0; call from prom_b
;           0xF7E418, and from nothing else the scans see.
Draw_AfterTouchRecord:
	ld	xiy, DL_AfterTouchRecord	; F7E421  ld XIY,0x00f3bb7e
	ld	xix, AfterT0uchSetting_EraseRecordValue_DL	; F7E426  ld XIX,0x00f3bb8d
	call	T_DisplayListB_Run	; F7E42B  call 0xf417f4
	ret	; F7E42F  ret

; Evidence: reached from call from prom_b 0xF7D1B4, and from nothing else
;           the scans see.
; AfterT0uchSetting_EraseRecordValue: Runs AfterT0uchSetting_EraseRecordValue_DL, one op-0x1B record = SWI7 LCD_Svc_1B_EraseRect over
;   (184,130)-(248,138): erases the AFTER TOUCH RECORD value cell. ScreenButton_AfterT0uchSetting calls it for codes
;   10/11 after T_AfterT0uchSetting_SetRecordEnable and before Draw_AfterTouchRecord redraws DISABLE / ENABLE. Basis:
;   caller + body. (notes/naming-pilot-2026-10-06/proposals_wave7_z.json)
AfterT0uchSetting_EraseRecordValue:
	ld	xiy, AfterT0uchSetting_EraseRecordValue_DL	; F7E430  ld XIY,0x00f3bb8d
	ld	xix, DLTable_DisableEnable	; F7E435  ld XIX,0x00f3bb97
	call	T_DisplayList_Run	; F7E43A  call 0xf417f0
	ret	; F7E43E  ret
ScreenLeave_AfterT0uchSetting_Nop:
	ret	; F7E43F  ret

; ---------------------------------------------------------------------
; Paint_TrackAssign -- paints the panel screen whose own title text reads
;                      "TRACK ASSIGN"
;
; Reached by: the +0 method stub of screen object 0xF43140, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: calr from prom_b 0xF7D084
; Evidence: the routine loads XIY = 0xF3B3DA and calls the display-list
;           interpreter; the leading run of op-0x1C records in that list
;           spells "TRACK ASSIGN", and the name is that text CamelCased,
;           with the ROM's own spelling kept (zeros for O's included). The
;           rule is round 7's, calibrated on seven screens prom_a had named
;           independently: notes/prom_b_screens_round8.py --calibrate.
; ---------------------------------------------------------------------
Paint_TrackAssign:
	ld	a, (UI_ScreenLatch:16)	; F7E440  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F7E444  cp A,(0x207b)
	jr	z, Paint_TrackAssign_Skip	; F7E448  jr Z,0xf7e44f
	ld	(3075:16), 0	; F7E44A  ld (0x0c03),0x00
Paint_TrackAssign_Skip:
	call	T_CallbackQueue_ResetAndRestartTask2	; F7E44F  call 0xf42e80
	cp	(UI_ScreenStage:16), 0x00	; F7E453  cp (0x207e),0x00
	jr	nz, Paint_TrackAssign_Skip2	; F7E458  jr NZ,0xf7e47b
	call	T_F42BE4	; F7E45A  call 0xf42be4
	or	(UI_RequestBits:16), 0x01	; F7E45E  or (0x2075),0x01
	ldw	(PanelDial_DownButton:16), 35208	; F7E463  ld (0x209b),0x8988  <- arms prom_a PanelButton_Accept's substitution for panel button code 0x0D (0xF86615); see the 0xF7D2D8 banner
	ldw	(9830:16), 65535	; F7E469  ld (0x2666),0xffff
	ldw	(9834:16), 65535	; F7E46F  ld (0x266a),0xffff
	bit	4, (UI_ScreenFlags:16)	; F7E475  bit 4,(0x2095)
	jr	nz, Paint_TrackAssign_Skip3	; F7E479  jr NZ,0xf7e4a1
Paint_TrackAssign_Skip2:
	calr	LCD_ScreenRedraw_Begin	; F7E47B  calr 0xf7e2d9
	cp	(UI_ScreenStage:16), 0x00	; F7E47E  cp (0x207e),0x00
	jr	nz, Paint_TrackAssign_Skip4	; F7E483  jr NZ,0xf7e4ac
	ld	xiy, Paint_TrackAssign_DL1	; F7E485  ld XIY,0x00f3b3da
	ld	xix, Paint_TrackAssign_DL2	; F7E48A  ld XIX,0x00f3b5a9
	call	T_DisplayList_Run	; F7E48F  call 0xf417f0
	ld	xiy, Paint_TrackAssign_DL2	; F7E493  ld XIY,0x00f3b5a9
	ld	xix, Paint_TrackLabels1To8_DL	; F7E498  ld XIX,0x00f3b5d1
	call	T_DisplayList_Run	; F7E49D  call 0xf417f0
Paint_TrackAssign_Skip3:
	calr	TrackAssign_PaintTrackGroup	; F7E4A1  calr 0xf7e788
	calr	TrackAssign_DrawSelectedPart	; F7E4A4  calr 0xf7e2fc
	calr	LCD_ScreenRedraw_End	; F7E4A7  calr 0xf7e2e7
	jr	Paint_TrackAssign_Return	; F7E4AA  jr T,0xf7e4f8
Paint_TrackAssign_Skip4:
	ld	(LCD_CurrentLayer:16), 0	; F7E4AC  ld (0x2540),0x00
	ld	xiy, DL_TrackAssignChangeAttention	; F7E4B1  ld XIY,0x00f3b99d
	ld	xix, Paint_TrackAssign_DL3	; F7E4B6  ld XIX,0x00f3ba91
	call	T_DisplayList_Run	; F7E4BB  call 0xf417f0
	ld	a, (3075:16)	; F7E4BF  ld A,(0x0c03)
	ld	(DisplayListB_Stage:16), a	; F7E4C3  ld (0x12f6),A
	push	xix	; F7E4C7  push XIX
	pushw	hl	; F7E4C8  push HL
	ld	xix, BStore_TrackToPart	; F7E4C9  ld XIX,0x00603422
	xor	hl, hl	; F7E4CE  xor HL,HL
	ld	l, (3075:16)	; F7E4D0  ld L,(0x0c03)
	ld	a, (xix+hl)	; F7E4D4  ld A,(XIX+HL)
	ld	(DisplayListB_Stage+1:16), a	; F7E4D9  ld (0x12f7),A
	popw	hl	; F7E4DD  pop HL
	pop	xix	; F7E4DE  pop XIX
	ld	a, (3078:16)	; F7E4DF  ld A,(0x0c06)
	ld	(DisplayListB_Stage+2:16), a	; F7E4E3  ld (0x12f8),A
	ld	xiy, Paint_TrackAssign_DL3	; F7E4E7  ld XIY,0x00f3ba91
	ld	xix, DL_AfterT0uchSettingSelectWhetherOrNotAfter	; F7E4EC  ld XIX,0x00f3bab9
	call	T_DisplayListB_Run	; F7E4F1  call 0xf417f4
	calr	LCD_ScreenRedraw_End	; F7E4F5  calr 0xf7e2e7
Paint_TrackAssign_Return:
	ret	; F7E4F8  ret

; ---------------------------------------------------------------------
; ScreenLeaveBody_TrackAssign -- the whole body of the TrackAssign screen's
;                                Leave method
;
; Reached by: the +4 method stub of screen object 0xF43140, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: calr from prom_b 0xF7D088
; Evidence: the whole body of screen object 0xF43140's +4 method. prom_a's
;           PanelScreen_VtableTable names that object, and its readers take
;           +0 Enter, +4 Leave, +8 Button; the stub at 0xF7D088 is `call
;           0xF7E4F9` then `ret` and nothing else calls this address. The
;           screen's own name is round 7's, from its title text.
; ---------------------------------------------------------------------
ScreenLeaveBody_TrackAssign:
	ld	(UI_ScreenStage:16), 0	; F7E4F9  ld (0x207e),0x00
	and	(0x0dc0:16), 0xfe	; F7E4FE  and (0x0dc0),0xfe
	call	T_TrackAssign_OnLeave	; F7E503  call 0xf42be8
	ret	; F7E507  ret
ButtonTable_TrackAssign_StageZero_Nop0:
	ret	; F7E508  ret   <- button table 0xF7D558 entry 0 (TRACK ASSIGN)
ButtonTable_TrackAssign_StageZero_Nop1:
	ret	; F7E509  ret   <- button table 0xF7D558 entry 1 (TRACK ASSIGN) and 1 more slot(s)

; ---------------------------------------------------------------------
; SoftKeyCol4_TrackAssign_StageZero -- the 4th of the eight SOFT KEYS in the
;           row under the LCD, on the TrackAssign_StageZero screen
; Reached by: SW39 "SOFT KEY col 4 lower" (matrix segment 4 bit 6, wire 0xC4)
;           -> PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record
;           0xF8B6DB {class 0xA9, code 0x03} -> delivered code 0x83; SW40
;           "SOFT KEY col 4 upper" (matrix segment 4 bit 7, wire 0xC4) ->
;           PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record 0xF8B6DF
;           {class 0xA9, code 0x03} -> delivered code 0x03. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x03 of ButtonTable_TrackAssign_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Note:     Also registered at slot 0x14, the VARIANT-1 already-held rewrite
;           of base code 0x03 (`add (XIX-1),0x11` at prom_a
;           0xF8AE7E/0xF8AEF1), so on the SX-WSA1 one routine serves the press
;           and the auto-repeat; on the SX-WSA1R that slot is never delivered.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW47 SOFT KEY col
;           8 lower (segment 5 bit 6, fitted); SW48 SOFT KEY col 8 upper
;           (segment 5 bit 7, fitted); SW55 [no legend: matrix position
;           outside every diode list] (segment 6 bit 6, NOT fitted on this
;           panel); SW56 [no legend: matrix position outside every diode list]
;           (segment 6 bit 7, NOT fitted on this panel). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW39/SW40 are the two switches of its 4th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW39, so "col 4" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol4_TrackAssign_StageZero:
	bit	7, w	; F7E50A  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssign_Skip	; F7E50D  jr NZ,0xf7e518
	cp	(0x0c06:16), 0x1f	; F7E50F  cp (0x0c06),0x1f
	jr	z, ScreenLeaveBody_TrackAssign_Return	; F7E514  jr Z,0xf7e529
	jr	ScreenLeaveBody_TrackAssign_Join	; F7E516  jr T,0xf7e51f
ScreenLeaveBody_TrackAssign_Skip:
	cp	(0x0c06:16), 0x00	; F7E518  cp (0x0c06),0x00
	jr	z, ScreenLeaveBody_TrackAssign_Return	; F7E51D  jr Z,0xf7e529
ScreenLeaveBody_TrackAssign_Join:
	call	T_TrackAssign_StageZero_SoftKeyCol4	; F7E51F  call 0xf42ba0
	calr	TrackAssign_PaintTrackGroup	; F7E523  calr 0xf7e788
	calr	TrackAssign_DrawSelectedPart	; F7E526  calr 0xf7e2fc
ScreenLeaveBody_TrackAssign_Return:
	ret	; F7E529  ret

; ---------------------------------------------------------------------
; SoftKeyCol5_TrackAssign_StageZero -- the 5th of the eight SOFT KEYS in the
;           row under the LCD, on the TrackAssign_StageZero screen
; Reached by: SW41 "SOFT KEY col 5 lower" (matrix segment 5 bit 0, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6E4 {class 0xA9, code 0x04} -> delivered code 0x84; SW42
;           "SOFT KEY col 5 upper" (matrix segment 5 bit 1, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6E8
;           {class 0xA9, code 0x04} -> delivered code 0x04. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x04 of ButtonTable_TrackAssign_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Note:     Also registered at slot 0x15, the VARIANT-1 already-held rewrite
;           of base code 0x04 (`add (XIX-1),0x11` at prom_a
;           0xF8AE7E/0xF8AEF1), so on the SX-WSA1 one routine serves the press
;           and the auto-repeat; on the SX-WSA1R that slot is never delivered.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW25 LCD RIGHT 1
;           (top) (segment 3 bit 0, fitted); SW26 LCD RIGHT 2 (segment 3 bit
;           1, fitted); SW33 SOFT KEY col 1 lower (segment 4 bit 0, fitted);
;           SW34 SOFT KEY col 1 upper (segment 4 bit 1, fitted). The model
;           strap is the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW41/SW42 are the two switches of its 5th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW41, so "col 5" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol5_TrackAssign_StageZero:
	call	T_TrackAssign_StageZero_SoftKeyCol5	; F7E52A  call 0xf42ba8
	calr	TrackAssign_PaintTrackGroup	; F7E52E  calr 0xf7e788
	calr	TrackAssign_DrawSelectedPart	; F7E531  calr 0xf7e2fc
	ret	; F7E534  ret
ButtonTable_TrackAssign_StageZero_Nop5:
	ret	; F7E535  ret   <- button table 0xF7D558 entry 5 (TRACK ASSIGN) and 1 more slot(s)

; ---------------------------------------------------------------------
; SoftKeyCol7_TrackAssign_StageZero -- the 7th of the eight SOFT KEYS in the
;           row under the LCD, on the TrackAssign_StageZero screen
; Reached by: SW45 "SOFT KEY col 7 lower" (matrix segment 5 bit 4, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6F4 {class 0xA9, code 0x06} -> delivered code 0x86; SW46
;           "SOFT KEY col 7 upper" (matrix segment 5 bit 5, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6F8
;           {class 0xA9, code 0x06} -> delivered code 0x06. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x06 of ButtonTable_TrackAssign_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Note:     Also registered at slot 0x17, the VARIANT-1 already-held rewrite
;           of base code 0x06 (`add (XIX-1),0x11` at prom_a
;           0xF8AE7E/0xF8AEF1), so on the SX-WSA1 one routine serves the press
;           and the auto-repeat; on the SX-WSA1R that slot is never delivered.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW29 LCD RIGHT 5
;           (bottom) (segment 3 bit 4, fitted); SW30 -1 (segment 3 bit 5,
;           fitted); SW37 SOFT KEY col 3 lower (segment 4 bit 4, fitted); SW38
;           SOFT KEY col 3 upper (segment 4 bit 5, fitted). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW45/SW46 are the two switches of its 7th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW45, so "col 7" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol7_TrackAssign_StageZero:
	or	(UI_RequestBits:16), 0x08	; F7E536  or (0x2075),0x08
	call	T_TrackAssign_StageZero_SoftKeyCol7	; F7E53B  call 0xf42bac
	calr	TrackAssign_PaintTrackGroup	; F7E53F  calr 0xf7e788
	calr	TrackAssign_DrawSelectedPart	; F7E542  calr 0xf7e2fc
	ret	; F7E545  ret
ButtonTable_TrackAssign_StageZero_Nop7:
	ret	; F7E546  ret   <- button table 0xF7D558 entry 7 (TRACK ASSIGN)

; ---------------------------------------------------------------------
; LcdKeyRow1_TrackAssign_StageZero -- row 1 of the five key pairs flanking the
;           LCD, on the TrackAssign_StageZero screen
; Reached by: SW25 "LCD RIGHT 1 (top)" (matrix segment 3 bit 0, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A2
;           {class 0xA9, code 0x08} -> delivered code 0x08; SW73 "LCD LEFT 1
;           (top)" (matrix segment 9 bit 0, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B71F
;           {class 0xA9, code 0x08} -> delivered code 0x88. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x08 of ButtonTable_TrackAssign_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW73 LCD LEFT 1
;           (top) (segment 9 bit 0, fitted); SW81 [no legend: matrix position
;           outside every diode list] (segment 10 bit 0, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW25 is row 1 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow1_TrackAssign_StageZero:
	bit	7, w	; F7E547  bit 0x07,W
	jr	z, ScreenLeaveBody_TrackAssign_Return2	; F7E54A  jr Z,0xf7e562
	cp	(0x0c03:16), 0x00	; F7E54C  cp (0x0c03),0x00
	jr	z, ScreenLeaveBody_TrackAssign_Skip2	; F7E551  jr Z,0xf7e55f
	or	(UI_RequestBits:16), 0x09	; F7E553  or (0x2075),0x09
	call	T_TrackAssign_StageZero_LcdKeyRow1	; F7E558  call 0xf42b90
	calr	TrackAssign_PaintTrackGroup	; F7E55C  calr 0xf7e788
ScreenLeaveBody_TrackAssign_Skip2:
	calr	TrackAssign_DrawSelectedPart	; F7E55F  calr 0xf7e2fc
ScreenLeaveBody_TrackAssign_Return2:
	ret	; F7E562  ret

; ---------------------------------------------------------------------
; LcdKeyRow2_TrackAssign_StageZero -- row 2 of the five key pairs flanking the
;           LCD, on the TrackAssign_StageZero screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_TrackAssign_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_TrackAssign_StageZero:
	bit	7, w	; F7E563  bit 0x07,W
	jr	z, ScreenLeaveBody_TrackAssign_Return3	; F7E566  jr Z,0xf7e580
	cp	(0x0c03:16), 0x0f	; F7E568  cp (0x0c03),0x0f
	jr	z, ScreenLeaveBody_TrackAssign_Return3	; F7E56D  jr Z,0xf7e580
	or	(UI_RequestBits:16), 0x09	; F7E56F  or (0x2075),0x09
	call	T_TrackAssign_StageZero_LcdKeyRow2	; F7E574  call 0xf42b8c
	call	TrackAssign_PaintTrackGroup	; F7E578  call 0xf7e788
	call	TrackAssign_DrawSelectedPart	; F7E57C  call 0xf7e2fc
ScreenLeaveBody_TrackAssign_Return3:
	ret	; F7E580  ret

; ---------------------------------------------------------------------
; LcdKeyRow3_TrackAssign_StageZero -- row 3 of the five key pairs flanking the
;           LCD, on the TrackAssign_StageZero screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_TrackAssign_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_TrackAssign_StageZero:
	bit	7, w	; F7E581  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssign_Skip3	; F7E584  jr NZ,0xf7e595
	ld	l, (3520:16)	; F7E586  ld L,(0x0dc0)
	and	l, 1	; F7E58A  and L,0x01
	jr	z, ScreenLeaveBody_TrackAssign_Return4	; F7E58D  jr Z,0xf7e5a4
	call	T_TrackAssign_StageZero_LcdKeyRow3	; F7E58F  call 0xf42ba4
	jr	ScreenLeaveBody_TrackAssign_Return4	; F7E593  jr T,0xf7e5a4
ScreenLeaveBody_TrackAssign_Skip3:
	cp	(0x0c03:16), 0x07	; F7E595  cp (0x0c03),0x07
	jr	ule, ScreenLeaveBody_TrackAssign_Return4	; F7E59A  jr ULE,0xf7e5a4
	call	T_TrackAssign_SelectTrackGroup	; F7E59C  call 0xf42b94
	call	TrackAssign_PaintTrackGroup	; F7E5A0  call 0xf7e788
ScreenLeaveBody_TrackAssign_Return4:
	ret	; F7E5A4  ret

; ---------------------------------------------------------------------
; LcdKeyRow4_TrackAssign_StageZero -- row 4 of the five key pairs flanking the
;           LCD, on the TrackAssign_StageZero screen
; Reached by: SW28 "LCD RIGHT 4" (matrix segment 3 bit 3, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AE
;           {class 0xA9, code 0x0B} -> delivered code 0x0B; SW76 "LCD LEFT 4"
;           (matrix segment 9 bit 3, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72B
;           {class 0xA9, code 0x0B} -> delivered code 0x8B. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0B of ButtonTable_TrackAssign_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW76 LCD LEFT 4
;           (segment 9 bit 3, fitted); SW84 [no legend: matrix position
;           outside every diode list] (segment 10 bit 3, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW28 is row 4 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow4_TrackAssign_StageZero:
	bit	7, w	; F7E5A5  bit 0x07,W
	jr	z, ScreenLeaveBody_TrackAssign_Return5	; F7E5A8  jr Z,0xf7e5b9
	cp	(0x0c03:16), 0x07	; F7E5AA  cp (0x0c03),0x07
	jr	ugt, ScreenLeaveBody_TrackAssign_Return5	; F7E5AF  jr UGT,0xf7e5b9
	call	T_TrackAssign_SelectTrackGroup	; F7E5B1  call 0xf42b94
	call	TrackAssign_PaintTrackGroup	; F7E5B5  call 0xf7e788
ScreenLeaveBody_TrackAssign_Return5:
	ret	; F7E5B9  ret

; ---------------------------------------------------------------------
; LcdKeyRow5_TrackAssign_StageZero -- row 5 of the five key pairs flanking the
;           LCD, on the TrackAssign_StageZero screen
; Reached by: SW29 "LCD RIGHT 5 (bottom)" (matrix segment 3 bit 4, wire 0xC3)
;           -> PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record
;           0xF8B6B2 {class 0xA9, code 0x0C} -> delivered code 0x0C; SW77 "LCD
;           LEFT 5 (bottom)" (matrix segment 9 bit 4, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72F
;           {class 0xA9, code 0x0C} -> delivered code 0x8C. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0C of ButtonTable_TrackAssign_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW77 LCD LEFT 5
;           (bottom) (segment 9 bit 4, fitted); SW85 [no legend: matrix
;           position outside every diode list] (segment 10 bit 4, NOT fitted
;           on this panel). The model strap is the RAM byte (0x00C4), latched
;           from PB bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2
;           is the SX-WSA1R (notes/wave7_panel_names_round11.py --variant,
;           three independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: page
;           I-4/I-5 draws a COLUMN OF FIVE keys down each side of the display
;           and SW29 is the bottom one. ⚠ GRADE POSITION in
;           notes/wave7_panel_button_codes.py --physical -- row 5 is the one
;           row of the column the Outsel check does NOT annotate, so unlike
;           rows 1-4 it rests on the silkscreen position alone. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow5_TrackAssign_StageZero:
	bit	7, w	; F7E5BA  bit 0x07,W
	jr	z, ScreenLeaveBody_TrackAssign_Return6	; F7E5BD  jr Z,0xf7e5c3
	call	T_TrackAssign_StageZero_LcdKeyRow5	; F7E5BF  call 0xf42bf4
ScreenLeaveBody_TrackAssign_Return6:
	ret	; F7E5C3  ret
ButtonTable_TrackAssign_StageZero_Nop13:
	ret	; F7E5C4  ret   <- button table 0xF7D558 entry 13 (TRACK ASSIGN) and 1 more slot(s)

; ---------------------------------------------------------------------
; ExitKey_TrackAssign_StageZero -- the EXIT key on the TrackAssign_StageZero
;           screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_TrackAssign_StageZero:
	bit	7, w	; F7E5C5  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssign_Return7	; F7E5C8  jr NZ,0xf7e5d2
	ldw	(UI_Request:16), 32772	; F7E5CA  ld (0x2070),0x8004
	jr	ScreenLeaveBody_TrackAssign_Return7	; F7E5D0  jr T,0xf7e5d2
ScreenLeaveBody_TrackAssign_Return7:
	ret	; F7E5D2  ret
ButtonTable_TrackAssign_StageZero_Nop16:
	ret	; F7E5D3  ret   <- button table 0xF7D558 entry 16 (TRACK ASSIGN) and 11 more slot(s)
ButtonTable_TrackAssign_StageNonZero_Nop0:
	ret	; F7E5D4  ret   <- button table 0xF7D5D8 entry 0 (TRACK ASSIGN) and 8 more slot(s)

; ---------------------------------------------------------------------
; LcdKeyRow2_TrackAssign_StageNonZero -- row 2 of the five key pairs flanking
;           the LCD, on the TrackAssign_StageNonZero screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_TrackAssign_StageNonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_TrackAssign_StageNonZero:
	bit	7, w	; F7E5D5  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssign_Return8	; F7E5D8  jr NZ,0xf7e5e5
	and	(UI_RequestBits:16), 0x6f	; F7E5DA  and (0x2075),0x6f
	call	T_TrackAssign_StageNonZero_LcdKeyRow2	; F7E5DF  call 0xf42bb0
	jr	ScreenLeaveBody_TrackAssign_Return8	; F7E5E3  jr T,0xf7e5e5
ScreenLeaveBody_TrackAssign_Return8:
	ret	; F7E5E5  ret

; ---------------------------------------------------------------------
; LcdKeyRow3_TrackAssign_StageNonZero -- row 3 of the five key pairs flanking
;           the LCD, on the TrackAssign_StageNonZero screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_TrackAssign_StageNonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_TrackAssign_StageNonZero:
	bit	7, w	; F7E5E6  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssign_Return9	; F7E5E9  jr NZ,0xf7e5f1
	call	T_TrackAssign_ReturnToStageZero	; F7E5EB  call 0xf42bc0
	jr	ScreenLeaveBody_TrackAssign_Return9	; F7E5EF  jr T,0xf7e5f1
ScreenLeaveBody_TrackAssign_Return9:
	ret	; F7E5F1  ret
ButtonTable_TrackAssign_StageNonZero_Nop11:
	ret	; F7E5F2  ret   <- button table 0xF7D5D8 entry 11 (TRACK ASSIGN) and 3 more slot(s)

; ---------------------------------------------------------------------
; ExitKey_TrackAssign_StageNonZero -- the EXIT key on the
;           TrackAssign_StageNonZero screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_TrackAssign_StageNonZero:
	bit	7, w	; F7E5F3  bit 0x07,W
	jr	nz, ExitKey_TrackAssign_StageNonZero_Return	; F7E5F6  jr NZ,0xf7e5fe
	call	T_TrackAssign_ReturnToStageZero	; F7E5F8  call 0xf42bc0
	jr	ExitKey_TrackAssign_StageNonZero_Return	; F7E5FC  jr T,0xf7e5fe
ExitKey_TrackAssign_StageNonZero_Return:
	ret	; F7E5FE  ret
ButtonTable_TrackAssign_StageNonZero_Nop16:
	ret	; F7E5FF  ret   <- button table 0xF7D5D8 entry 16 (TRACK ASSIGN) and 15 more slot(s)
ScreenNull_TrackAssign_Nop:
	ret	; F7E600  ret

; ---------------------------------------------------------------------
; Paint_TrackAssignPresets -- paints the panel screen whose own title text
;                             reads "TRACK ASSIGN PRESETS"
;
; Reached by: the +0 method stub of screen object 0xF43190, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: calr from prom_b 0xF7D0A6
; Evidence: the routine loads XIY = 0xF3A2BF and calls the display-list
;           interpreter; the leading run of op-0x1C records in that list
;           spells "TRACK ASSIGN PRESETS", and the name is that text
;           CamelCased, with the ROM's own spelling kept (zeros for O's
;           included). The rule is round 7's, calibrated on seven screens
;           prom_a had named independently: notes/prom_b_screens_round8.py
;           --calibrate.
; ---------------------------------------------------------------------
Paint_TrackAssignPresets:
	call	T_CallbackQueue_ResetAndRestartTask2	; F7E601  call 0xf42e80
	ld	a, (UI_ScreenLatch:16)	; F7E605  ld A,(0x207a)
	cp	a, (UI_ScreenLatch_Previous:16)	; F7E609  cp A,(0x207b)
	jr	z, Paint_TrackAssignPresets_Skip	; F7E60D  jr Z,0xf7e60f
Paint_TrackAssignPresets_Skip:
	call	T_TrackAssignPresets_InitFromCurrentBank	; F7E60F  call 0xf42bf8
	bit	4, (UI_ScreenFlags:16)	; F7E613  bit 4,(0x2095)
	jr	nz, Paint_TrackAssignPresets_Skip2	; F7E617  jr NZ,0xf7e62b
	call	LCD_ScreenRedraw_Begin	; F7E619  call 0xf7e2d9
	ld	xiy, DL_TrackAssignPresetsTechnicsSetUp1116	; F7E61D  ld XIY,0x00f3a2bf
	ld	xix, Paint_TrackAssignPresets_DL2	; F7E622  ld XIX,0x00f3a40d
	call	T_DisplayList_Run	; F7E627  call 0xf417f0
Paint_TrackAssignPresets_Skip2:
	ld	(LCD_CurrentLayer:16), 0	; F7E62B  ld (0x2540),0x00
	cp	(0x0dfe:16), 0x0a	; F7E630  cp (0x0dfe),0x0a
	jr	nz, Paint_TrackAssignPresets_Skip3	; F7E635  jr NZ,0xf7e647
	ld	xiy, DL_All	; F7E637  ld XIY,0x00f3a41f
	ld	xix, Paint_TrackAssignPresets_DL1	; F7E63C  ld XIX,0x00f3a429
	call	T_DisplayList_Run	; F7E641  call 0xf417f0
	jr	Paint_TrackAssignPresets_Join	; F7E645  jr T,0xf7e663
Paint_TrackAssignPresets_Skip3:
	ld	xiy, Paint_TrackAssignPresets_DL1	; F7E647  ld XIY,0x00f3a429
	ld	xix, Data_F3A433	; F7E64C  ld XIX,0x00f3a433
	call	T_DisplayListB_Run	; F7E651  call 0xf417f4
	ld	xiy, DL_S0ng	; F7E655  ld XIY,0x00f3a417
	ld	xix, DL_All	; F7E65A  ld XIX,0x00f3a41f
	call	T_DisplayList_Run	; F7E65F  call 0xf417f0
Paint_TrackAssignPresets_Join:
	ld	xiy, Paint_TrackAssignPresets_DL2	; F7E663  ld XIY,0x00f3a40d
	ld	xix, DL_S0ng	; F7E668  ld XIX,0x00f3a417
	call	T_DisplayList_Run	; F7E66D  call 0xf417f0
	call	TrackAssignPresets_MoveFieldHighlight	; F7E671  call 0xf7e770
	call	LCD_ScreenRedraw_End	; F7E675  call 0xf7e2e7
	ret	; F7E679  ret

; ---------------------------------------------------------------------
; ScreenLeaveBody_TrackAssignPresets -- the whole body of the
;                                       TrackAssignPresets screen's Leave
;                                       method
;
; Reached by: the +4 method stub of screen object 0xF43190, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: calr from prom_b 0xF7D0AA
; Evidence: the whole body of screen object 0xF43190's +4 method. prom_a's
;           PanelScreen_VtableTable names that object, and its readers take
;           +0 Enter, +4 Leave, +8 Button; the stub at 0xF7D0AA is `call
;           0xF7E67A` then `ret` and nothing else calls this address. The
;           screen's own name is round 7's, from its title text.
; ---------------------------------------------------------------------
ScreenLeaveBody_TrackAssignPresets:
	cp	(UI_ScreenLatch:16), 0x11	; F7E67A  cp (0x207a),0x11
	jr	z, ScreenLeaveBody_TrackAssignPresets_Return	; F7E67F  jr Z,0xf7e686
	and	(0x34bb:16), 0xfb	; F7E681  and (0x34bb),0xfb
ScreenLeaveBody_TrackAssignPresets_Return:
	ret	; F7E686  ret

; ---------------------------------------------------------------------
; SoftKeyCol1_TrackAssignPresets -- the 1st of the eight SOFT KEYS in the row
;           under the LCD, on the TrackAssignPresets screen
; Reached by: SW33 "SOFT KEY col 1 lower" (matrix segment 4 bit 0, wire 0xC4)
;           -> PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record
;           0xF8B6C3 {class 0xA9, code 0x00} -> delivered code 0x80; SW34
;           "SOFT KEY col 1 upper" (matrix segment 4 bit 1, wire 0xC4) ->
;           PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record 0xF8B6C7
;           {class 0xA9, code 0x00} -> delivered code 0x00. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x00 of ButtonTable_TrackAssignPresets.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW41 SOFT KEY col
;           5 lower (segment 5 bit 0, fitted); SW42 SOFT KEY col 5 upper
;           (segment 5 bit 1, fitted); SW49 [no legend: matrix position
;           outside every diode list] (segment 6 bit 0, NOT fitted on this
;           panel); SW50 [no legend: matrix position outside every diode list]
;           (segment 6 bit 1, NOT fitted on this panel). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW33/SW34 are the two switches of its 1st column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW33, so "col 1" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol1_TrackAssignPresets:
	bit	7, w	; F7E687  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssignPresets_Return2	; F7E68A  jr NZ,0xf7e68e
	jr	ScreenLeaveBody_TrackAssignPresets_Return2	; F7E68C  jr T,0xf7e68e
ScreenLeaveBody_TrackAssignPresets_Return2:
	ret	; F7E68E  ret

; ---------------------------------------------------------------------
; SoftKeyCol2_TrackAssignPresets -- the 2nd of the eight SOFT KEYS in the row
;           under the LCD, on the TrackAssignPresets screen
; Reached by: SW35 "SOFT KEY col 2 lower" (matrix segment 4 bit 2, wire 0xC4)
;           -> PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record
;           0xF8B6CB {class 0xA9, code 0x01} -> delivered code 0x81; SW36
;           "SOFT KEY col 2 upper" (matrix segment 4 bit 3, wire 0xC4) ->
;           PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record 0xF8B6CF
;           {class 0xA9, code 0x01} -> delivered code 0x01. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x01 of ButtonTable_TrackAssignPresets.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW43 SOFT KEY col
;           6 lower (segment 5 bit 2, fitted); SW44 SOFT KEY col 6 upper
;           (segment 5 bit 3, fitted); SW51 [no legend: matrix position
;           outside every diode list] (segment 6 bit 2, NOT fitted on this
;           panel); SW52 [no legend: matrix position outside every diode list]
;           (segment 6 bit 3, NOT fitted on this panel). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW35/SW36 are the two switches of its 2nd column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW35, so "col 2" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol2_TrackAssignPresets:
	bit	7, w	; F7E68F  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssignPresets_Join	; F7E692  jr NZ,0xf7e696
	jr	ScreenLeaveBody_TrackAssignPresets_Join	; F7E694  jr T,0xf7e696
ScreenLeaveBody_TrackAssignPresets_Join:
	call	T_TrackAssignPresets_BankDown	; F7E696  call 0xf42c10
	or	(UI_ScreenFlags:16), 0x10	; F7E69A  or (0x2095),0x10
	ret	; F7E69F  ret

; ---------------------------------------------------------------------
; SoftKeyCol3_TrackAssignPresets -- the 3rd of the eight SOFT KEYS in the row
;           under the LCD, on the TrackAssignPresets screen
; Reached by: SW37 "SOFT KEY col 3 lower" (matrix segment 4 bit 4, wire 0xC4)
;           -> PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record
;           0xF8B6D3 {class 0xA9, code 0x02} -> delivered code 0x82; SW38
;           "SOFT KEY col 3 upper" (matrix segment 4 bit 5, wire 0xC4) ->
;           PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record 0xF8B6D7
;           {class 0xA9, code 0x02} -> delivered code 0x02. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x02 of ButtonTable_TrackAssignPresets.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW45 SOFT KEY col
;           7 lower (segment 5 bit 4, fitted); SW46 SOFT KEY col 7 upper
;           (segment 5 bit 5, fitted); SW53 [no legend: matrix position
;           outside every diode list] (segment 6 bit 4, NOT fitted on this
;           panel); SW54 [no legend: matrix position outside every diode list]
;           (segment 6 bit 5, NOT fitted on this panel). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW37/SW38 are the two switches of its 3rd column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW37, so "col 3" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol3_TrackAssignPresets:
	bit	7, w	; F7E6A0  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssignPresets_Join2	; F7E6A3  jr NZ,0xf7e6a7
	jr	ScreenLeaveBody_TrackAssignPresets_Join2	; F7E6A5  jr T,0xf7e6a7
ScreenLeaveBody_TrackAssignPresets_Join2:
	call	T_TrackAssignPresets_BankUp	; F7E6A7  call 0xf42c0c
	or	(UI_ScreenFlags:16), 0x10	; F7E6AB  or (0x2095),0x10
	ret	; F7E6B0  ret

; ---------------------------------------------------------------------
; SoftKeyCol4_TrackAssignPresets -- the 4th of the eight SOFT KEYS in the row
;           under the LCD, on the TrackAssignPresets screen
; Reached by: SW39 "SOFT KEY col 4 lower" (matrix segment 4 bit 6, wire 0xC4)
;           -> PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record
;           0xF8B6DB {class 0xA9, code 0x03} -> delivered code 0x83; SW40
;           "SOFT KEY col 4 upper" (matrix segment 4 bit 7, wire 0xC4) ->
;           PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record 0xF8B6DF
;           {class 0xA9, code 0x03} -> delivered code 0x03. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x03 of ButtonTable_TrackAssignPresets.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW47 SOFT KEY col
;           8 lower (segment 5 bit 6, fitted); SW48 SOFT KEY col 8 upper
;           (segment 5 bit 7, fitted); SW55 [no legend: matrix position
;           outside every diode list] (segment 6 bit 6, NOT fitted on this
;           panel); SW56 [no legend: matrix position outside every diode list]
;           (segment 6 bit 7, NOT fitted on this panel). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW39/SW40 are the two switches of its 4th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW39, so "col 4" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol4_TrackAssignPresets:
	bit	7, w	; F7E6B1  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssignPresets_Return3	; F7E6B4  jr NZ,0xf7e6b8
	jr	ScreenLeaveBody_TrackAssignPresets_Return3	; F7E6B6  jr T,0xf7e6b8
ScreenLeaveBody_TrackAssignPresets_Return3:
	ret	; F7E6B8  ret

; ---------------------------------------------------------------------
; SoftKeyCol5_TrackAssignPresets -- the 5th of the eight SOFT KEYS in the row
;           under the LCD, on the TrackAssignPresets screen
; Reached by: SW41 "SOFT KEY col 5 lower" (matrix segment 5 bit 0, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6E4 {class 0xA9, code 0x04} -> delivered code 0x84; SW42
;           "SOFT KEY col 5 upper" (matrix segment 5 bit 1, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6E8
;           {class 0xA9, code 0x04} -> delivered code 0x04. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x04 of ButtonTable_TrackAssignPresets.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW25 LCD RIGHT 1
;           (top) (segment 3 bit 0, fitted); SW26 LCD RIGHT 2 (segment 3 bit
;           1, fitted); SW33 SOFT KEY col 1 lower (segment 4 bit 0, fitted);
;           SW34 SOFT KEY col 1 upper (segment 4 bit 1, fitted). The model
;           strap is the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW41/SW42 are the two switches of its 5th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW41, so "col 5" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol5_TrackAssignPresets:
	bit	7, w	; F7E6B9  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssignPresets_Return4	; F7E6BC  jr NZ,0xf7e6c0
	jr	ScreenLeaveBody_TrackAssignPresets_Return4	; F7E6BE  jr T,0xf7e6c0
ScreenLeaveBody_TrackAssignPresets_Return4:
	ret	; F7E6C0  ret

; ---------------------------------------------------------------------
; SoftKeyCol6_TrackAssignPresets -- the 6th of the eight SOFT KEYS in the row
;           under the LCD, on the TrackAssignPresets screen
; Reached by: SW43 "SOFT KEY col 6 lower" (matrix segment 5 bit 2, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6EC {class 0xA9, code 0x05} -> delivered code 0x85; SW44
;           "SOFT KEY col 6 upper" (matrix segment 5 bit 3, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6F0
;           {class 0xA9, code 0x05} -> delivered code 0x05. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x05 of ButtonTable_TrackAssignPresets.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW27 LCD RIGHT 3
;           (segment 3 bit 2, fitted); SW28 LCD RIGHT 4 (segment 3 bit 3,
;           fitted); SW35 SOFT KEY col 2 lower (segment 4 bit 2, fitted); SW36
;           SOFT KEY col 2 upper (segment 4 bit 3, fitted). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW43/SW44 are the two switches of its 6th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW43, so "col 6" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol6_TrackAssignPresets:
	bit	7, w	; F7E6C1  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssignPresets_Join3	; F7E6C4  jr NZ,0xf7e6c8
	jr	ScreenLeaveBody_TrackAssignPresets_Join3	; F7E6C6  jr T,0xf7e6c8
ScreenLeaveBody_TrackAssignPresets_Join3:
	call	T_TrackAssignPresets_SoftKeyCol6	; F7E6C8  call 0xf42c14
	ret	; F7E6CC  ret

; ---------------------------------------------------------------------
; SoftKeyCol7_TrackAssignPresets -- the 7th of the eight SOFT KEYS in the row
;           under the LCD, on the TrackAssignPresets screen
; Reached by: SW45 "SOFT KEY col 7 lower" (matrix segment 5 bit 4, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6F4 {class 0xA9, code 0x06} -> delivered code 0x86; SW46
;           "SOFT KEY col 7 upper" (matrix segment 5 bit 5, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6F8
;           {class 0xA9, code 0x06} -> delivered code 0x06. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x06 of ButtonTable_TrackAssignPresets.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW29 LCD RIGHT 5
;           (bottom) (segment 3 bit 4, fitted); SW30 -1 (segment 3 bit 5,
;           fitted); SW37 SOFT KEY col 3 lower (segment 4 bit 4, fitted); SW38
;           SOFT KEY col 3 upper (segment 4 bit 5, fitted). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW45/SW46 are the two switches of its 7th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW45, so "col 7" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol7_TrackAssignPresets:
	bit	7, w	; F7E6CD  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssignPresets_Return5	; F7E6D0  jr NZ,0xf7e6d4
	jr	ScreenLeaveBody_TrackAssignPresets_Return5	; F7E6D2  jr T,0xf7e6d4
ScreenLeaveBody_TrackAssignPresets_Return5:
	ret	; F7E6D4  ret

; ---------------------------------------------------------------------
; SoftKeyCol8_TrackAssignPresets -- the 8th of the eight SOFT KEYS in the row
;           under the LCD, on the TrackAssignPresets screen
; Reached by: SW47 "SOFT KEY col 8 lower" (matrix segment 5 bit 6, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6FC {class 0xA9, code 0x07} -> delivered code 0x87; SW48
;           "SOFT KEY col 8 upper" (matrix segment 5 bit 7, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B700
;           {class 0xA9, code 0x07} -> delivered code 0x07. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x07 of ButtonTable_TrackAssignPresets.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW31 +1 (segment
;           3 bit 6, fitted); SW32 EXIT (segment 3 bit 7, fitted); SW39 SOFT
;           KEY col 4 lower (segment 4 bit 6, fitted); SW40 SOFT KEY col 4
;           upper (segment 4 bit 7, fitted). The model strap is the RAM byte
;           (0x00C4), latched from PB bit 0 by prom_a Variant_SetFromPB0 at
;           0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW47/SW48 are the two switches of its 8th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW47, so "col 8" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol8_TrackAssignPresets:
	bit	7, w	; F7E6D5  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssignPresets_Return6	; F7E6D8  jr NZ,0xf7e6dc
	jr	ScreenLeaveBody_TrackAssignPresets_Return6	; F7E6DA  jr T,0xf7e6dc
ScreenLeaveBody_TrackAssignPresets_Return6:
	ret	; F7E6DC  ret

; ---------------------------------------------------------------------
; LcdKeyRow1_TrackAssignPresets -- row 1 of the five key pairs flanking the
;           LCD, on the TrackAssignPresets screen
; Reached by: SW25 "LCD RIGHT 1 (top)" (matrix segment 3 bit 0, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A2
;           {class 0xA9, code 0x08} -> delivered code 0x08; SW73 "LCD LEFT 1
;           (top)" (matrix segment 9 bit 0, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B71F
;           {class 0xA9, code 0x08} -> delivered code 0x88. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x08 of ButtonTable_TrackAssignPresets.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW73 LCD LEFT 1
;           (top) (segment 9 bit 0, fitted); SW81 [no legend: matrix position
;           outside every diode list] (segment 10 bit 0, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW25 is row 1 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow1_TrackAssignPresets:
	bit	7, w	; F7E6DD  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssignPresets_Skip	; F7E6E0  jr NZ,0xf7e6e4
	jr	ScreenLeaveBody_TrackAssignPresets_Return7	; F7E6E2  jr T,0xf7e6fd
ScreenLeaveBody_TrackAssignPresets_Skip:
	cp	(0x0dfd:16), 0x01	; F7E6E4  cp (0x0dfd),0x01
	jr	z, ScreenLeaveBody_TrackAssignPresets_Return7	; F7E6E9  jr Z,0xf7e6fd
	ld	a, (3581:16)	; F7E6EB  ld A,(0x0dfd)
	dec	1, a	; F7E6EF  dec 1,A
	ld	(DisplayListB_Stage+2:16), a	; F7E6F1  ld (0x12f8),A
	call	T_TrackAssignPresets_SelectField1	; F7E6F5  call 0xf42c00
	call	TrackAssignPresets_MoveFieldHighlight	; F7E6F9  call 0xf7e770
ScreenLeaveBody_TrackAssignPresets_Return7:
	ret	; F7E6FD  ret

; ---------------------------------------------------------------------
; LcdKeyRow2_TrackAssignPresets -- row 2 of the five key pairs flanking the
;           LCD, on the TrackAssignPresets screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_TrackAssignPresets.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_TrackAssignPresets:
	bit	7, w	; F7E6FE  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssignPresets_Skip2	; F7E701  jr NZ,0xf7e705
	jr	ScreenLeaveBody_TrackAssignPresets_Return8	; F7E703  jr T,0xf7e71e
ScreenLeaveBody_TrackAssignPresets_Skip2:
	cp	(0x0dfd:16), 0x02	; F7E705  cp (0x0dfd),0x02
	jr	z, ScreenLeaveBody_TrackAssignPresets_Return8	; F7E70A  jr Z,0xf7e71e
	ld	a, (3581:16)	; F7E70C  ld A,(0x0dfd)
	dec	1, a	; F7E710  dec 1,A
	ld	(DisplayListB_Stage+2:16), a	; F7E712  ld (0x12f8),A
	call	T_TrackAssignPresets_SelectField2	; F7E716  call 0xf42c04
	call	TrackAssignPresets_MoveFieldHighlight	; F7E71A  call 0xf7e770
ScreenLeaveBody_TrackAssignPresets_Return8:
	ret	; F7E71E  ret

; ---------------------------------------------------------------------
; LcdKeyRow3_TrackAssignPresets -- row 3 of the five key pairs flanking the
;           LCD, on the TrackAssignPresets screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_TrackAssignPresets.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_TrackAssignPresets:
	bit	7, w	; F7E71F  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssignPresets_Skip3	; F7E722  jr NZ,0xf7e726
	jr	ScreenLeaveBody_TrackAssignPresets_Return9	; F7E724  jr T,0xf7e73f
ScreenLeaveBody_TrackAssignPresets_Skip3:
	cp	(0x0dfd:16), 0x03	; F7E726  cp (0x0dfd),0x03
	jr	z, ScreenLeaveBody_TrackAssignPresets_Return9	; F7E72B  jr Z,0xf7e73f
	ld	a, (3581:16)	; F7E72D  ld A,(0x0dfd)
	dec	1, a	; F7E731  dec 1,A
	ld	(DisplayListB_Stage+2:16), a	; F7E733  ld (0x12f8),A
	call	T_TrackAssignPresets_SelectField3	; F7E737  call 0xf42c08
	call	TrackAssignPresets_MoveFieldHighlight	; F7E73B  call 0xf7e770
ScreenLeaveBody_TrackAssignPresets_Return9:
	ret	; F7E73F  ret

; ---------------------------------------------------------------------
; LcdKeyRow4_TrackAssignPresets -- row 4 of the five key pairs flanking the
;           LCD, on the TrackAssignPresets screen
; Reached by: SW28 "LCD RIGHT 4" (matrix segment 3 bit 3, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AE
;           {class 0xA9, code 0x0B} -> delivered code 0x0B; SW76 "LCD LEFT 4"
;           (matrix segment 9 bit 3, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72B
;           {class 0xA9, code 0x0B} -> delivered code 0x8B. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0B of ButtonTable_TrackAssignPresets.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW76 LCD LEFT 4
;           (segment 9 bit 3, fitted); SW84 [no legend: matrix position
;           outside every diode list] (segment 10 bit 3, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW28 is row 4 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow4_TrackAssignPresets:
	bit	7, w	; F7E740  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssignPresets_Return10	; F7E743  jr NZ,0xf7e747
	jr	ScreenLeaveBody_TrackAssignPresets_Return10	; F7E745  jr T,0xf7e747
ScreenLeaveBody_TrackAssignPresets_Return10:
	ret	; F7E747  ret

; ---------------------------------------------------------------------
; LcdKeyRow5_TrackAssignPresets -- row 5 of the five key pairs flanking the
;           LCD, on the TrackAssignPresets screen
; Reached by: SW29 "LCD RIGHT 5 (bottom)" (matrix segment 3 bit 4, wire 0xC3)
;           -> PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record
;           0xF8B6B2 {class 0xA9, code 0x0C} -> delivered code 0x0C; SW77 "LCD
;           LEFT 5 (bottom)" (matrix segment 9 bit 4, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72F
;           {class 0xA9, code 0x0C} -> delivered code 0x8C. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0C of ButtonTable_TrackAssignPresets.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW77 LCD LEFT 5
;           (bottom) (segment 9 bit 4, fitted); SW85 [no legend: matrix
;           position outside every diode list] (segment 10 bit 4, NOT fitted
;           on this panel). The model strap is the RAM byte (0x00C4), latched
;           from PB bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2
;           is the SX-WSA1R (notes/wave7_panel_names_round11.py --variant,
;           three independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: page
;           I-4/I-5 draws a COLUMN OF FIVE keys down each side of the display
;           and SW29 is the bottom one. ⚠ GRADE POSITION in
;           notes/wave7_panel_button_codes.py --physical -- row 5 is the one
;           row of the column the Outsel check does NOT annotate, so unlike
;           rows 1-4 it rests on the silkscreen position alone. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow5_TrackAssignPresets:
	bit	7, w	; F7E748  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssignPresets_Return11	; F7E74B  jr NZ,0xf7e74f
	jr	ScreenLeaveBody_TrackAssignPresets_Return11	; F7E74D  jr T,0xf7e74f
ScreenLeaveBody_TrackAssignPresets_Return11:
	ret	; F7E74F  ret

; ---------------------------------------------------------------------
; sub_F7E750 -- panel button slot 0x0D of TrackAssignPresets, NOT NAMED
; Unknown:  NO NAME. Slot 0x0D cannot be reached by a single press: prom_a
;           PanelButton_Route tests `bit 0,(0x2075)` at 0xF861C6 and, when it
;           is CLEAR, takes the dial arm at 0xF861CC and returns without
;           reaching the screen dispatch at 0xF86205; when it is SET, prom_a
;           PanelButton_Accept has already substituted the code from
;           (0x209B)/(0x209C) at 0xF86610-0xF86629, and every literal any
;           image stores there masks to 0x00-0x0C. ⚠ THE REMAINING PATH, which
;           round 11's refusal text does not mention: prom_a
;           PanelButton_SweepHeld (0xF8615C) routes every bit set in (0x2088),
;           and bit 0x0D of (0x2088) IS set by PanelButton_Accept (`or
;           (0x2088),XWA` at 0xF866B3) when 0x0D is accepted with bit 0 of
;           (0x2075) clear. So this routine runs if that bit is clear at
;           accept time and set at repeat time. NO SITE HAS BEEN SHOWN TO
;           PRODUCE THAT TRANSITION, so the -1/+1 keys are NOT claimed as this
;           routine's caller -- the name MinusPlusKey_TrackAssignPresets,
;           applied in round 11, is withdrawn here.
; Evidence: the table slot and the screen are re-read from the ROM, and the
;           reachability argument above is reproduced by
;           notes/prom_b_panel_names_round12.py --0x0d (slot 0x0D) and --plan
;           (the rest).
; ---------------------------------------------------------------------
sub_F7E750:
	bit	7, w	; F7E750  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssignPresets_Return12	; F7E753  jr NZ,0xf7e757
	jr	ScreenLeaveBody_TrackAssignPresets_Return12	; F7E755  jr T,0xf7e757
ScreenLeaveBody_TrackAssignPresets_Return12:
	ret	; F7E757  ret

; ---------------------------------------------------------------------
; sub_F7E758 -- panel button slot 0x0E of TrackAssignPresets, NOT NAMED
; Unknown:  NO NAME, for want of a PRODUCER. No template record in either
;           variant's group lists carries code 0x0E, the variant-1 +0x11
;           rewrite cannot reach it (its minimum base 0x00 gives 0x11), the
;           (0x209B)/(0x209C) substitution tops out at 0x0C, and no `ld
;           DE,0x??A9` immediate exists in any of the four images. prom_a
;           PanelButton_Route does have an 0x0E arm (0xF861BC), but it fires
;           only with bit 5 of (0x2075) CLEAR and it never reaches a screen
;           table. This is the only slot-0x0E entry in all 1,024 that is not a
;           bare `ret`, and both of its branches fall into the same `ret`.
; Evidence: the table slot and the screen are re-read from the ROM, and the
;           reachability argument above is reproduced by
;           notes/prom_b_panel_names_round12.py --0x0d (slot 0x0D) and --plan
;           (the rest).
; ---------------------------------------------------------------------
sub_F7E758:
	bit	7, w	; F7E758  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssignPresets_Return13	; F7E75B  jr NZ,0xf7e75f
	jr	ScreenLeaveBody_TrackAssignPresets_Return13	; F7E75D  jr T,0xf7e75f
ScreenLeaveBody_TrackAssignPresets_Return13:
	ret	; F7E75F  ret

; ---------------------------------------------------------------------
; ExitKey_TrackAssignPresets -- the EXIT key on the TrackAssignPresets screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_TrackAssignPresets:
	bit	7, w	; F7E760  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackAssignPresets_Return14	; F7E763  jr NZ,0xf7e76d
	ldw	(UI_Request:16), 32784	; F7E765  ld (0x2070),0x8010
	jr	ScreenLeaveBody_TrackAssignPresets_Return14	; F7E76B  jr T,0xf7e76d
ScreenLeaveBody_TrackAssignPresets_Return14:
	ret	; F7E76D  ret
ButtonTable_TrackAssignPresets_Nop16:
	ret	; F7E76E  ret   <- button table 0xF7D658 entry 16 (TRACK ASSIGN PRESETS) and 15 more slot(s)
ScreenNull_TrackAssignPresets_Nop:
	ret	; F7E76F  ret

; Evidence: reached from call from prom_b 0xF7E671; call from prom_b
;           0xF7E6F9, and from nothing else the scans see.
; TrackAssignPresets_MoveFieldHighlight: Layer 1: erases (svc 0x1B) the box DLTable_F3A449[(0x12F8)] of the previously
;   selected field and fills (svc 0x05) the box DLTable_F3A449[DisplayListB_Stage] of the field just selected (three
;   rows, (19,33)-(239,55) etc.). Basis: callers + body -- each LcdKeyRow1..3 handler stores the old field-1 in
;   (0x12F8), calls TrackAssignPresets_SelectFieldN (which sets DisplayListB_Stage = N-1), then this;
;   Paint_TrackAssignPresets calls it last. (notes/naming-pilot-2026-10-06/proposals_wave2_d.json)
TrackAssignPresets_MoveFieldHighlight:
	ld	(LCD_CurrentLayer:16), 1	; F7E770  ld (0x2540),0x01
	ld	xiy, TrackAssignPresets_MoveFieldHighlight_DL	; F7E775  ld XIY,0x00f3a43e
	call	T_DLB_Handler_Array8_2	; F7E77A  call 0xf41820
	ld	xiy, Data_F3A433	; F7E77E  ld XIY,0x00f3a433
	call	T_DLB_Handler_Array8	; F7E783  call 0xf4181c
	ret	; F7E787  ret

; Evidence: reached from call from prom_b 0xF7E578; call from prom_b
;           0xF7E5A0, and from nothing else the scans see.
; TrackAssign_PaintTrackGroup: TRACK ASSIGN: repaints the table for the shown group of eight tracks -- bank number,
;   cursor row, group indicator, then for (0x0C07) bit 0 = 0 the TR 1-8 labels, parts (BStore_TrackToPart), per-track
;   bits of (0x603454) and MIDI channels (0x603433), or the TR 9-16 equivalents. Basis: callers + body.
;   (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
TrackAssign_PaintTrackGroup:
	or	(0xc6:8), 0x01	; F7E788  or (0xc6),0x01
	calr	ButtonTable_SequencerMedley_Nop	; F7E78C  calr 0xf7e2d8
	ld	a, (BStore_CurrentBank:16)	; F7E78F  ld A,(0x360a)
	inc	1, a	; F7E793  inc 1,A
	ld	(UI_DrawScratch:16), a	; F7E795  ld (0x2640),A
	ld	xiy, TrackAssign_PaintTrackGroup_DL	; F7E799  ld XIY,0x00f3b651
	ld	xix, DL_F3B65B	; F7E79E  ld XIX,0x00f3b65b
	call	T_DisplayListB_Run	; F7E7A3  call 0xf417f4
	calr	TrackAssign_DrawTrackRowHighlight	; F7E7A7  calr 0xf7e941
	calr	TrackAssign_DrawTrackGroupHighlight	; F7E7AA  calr 0xf7e919
	ld	(LCD_CurrentLayer:16), 0	; F7E7AD  ld (0x2540),0x00
	bit	0, (0x0c07:16)	; F7E7B2  bit 0,(0x0c07)
	jr	nz, TrackAssign_PaintTrackGroup_Skip	; F7E7B6  jr NZ,0xf7e7d4
	calr	Paint_TrackLabels1To8	; F7E7B8  calr 0xf7e89f
	calr	TrackAssign_DrawParts1To8	; F7E7BB  calr 0xf7e8cd
	ld	l, (6304852:24)	; F7E7BE  ld L,(0x603454)
	xor	a, a	; F7E7C3  xor A,A
	calr	TrackAssign_DrawLocalControlColumn	; F7E7C5  calr 0xf7e852
	ld	xhl, 6304819	; F7E7C8  ld XHL,0x00603433
	xor	a, a	; F7E7CD  xor A,A
	calr	TrackAssign_DrawOutChannelColumn	; F7E7CF  calr 0xf7e81f
	jr	TrackAssign_PaintTrackGroup_Join	; F7E7D2  jr T,0xf7e7ee
TrackAssign_PaintTrackGroup_Skip:
	calr	Paint_TrackLabels9To16	; F7E7D4  calr 0xf7e8b6
	calr	TrackAssign_DrawParts9To16	; F7E7D7  calr 0xf7e8f3
	ld	l, (6304853:24)	; F7E7DA  ld L,(0x603455)
	ld	a, 8:opc	; F7E7DF  ld A,0x08
	calr	TrackAssign_DrawLocalControlColumn	; F7E7E1  calr 0xf7e852
	ld	xhl, 6304827	; F7E7E4  ld XHL,0x0060343b
	ld	a, 8:opc	; F7E7E9  ld A,0x08
	calr	TrackAssign_DrawOutChannelColumn	; F7E7EB  calr 0xf7e81f
TrackAssign_PaintTrackGroup_Join:
	ld	(LCD_CurrentLayer:16), 2	; F7E7EE  ld (0x2540),0x02
	ld	a, (3520:16)	; F7E7F3  ld A,(0x0dc0)
	and	a, 1	; F7E7F7  and A,0x01
	jr	z, TrackAssign_PaintTrackGroup_Skip2	; F7E7FA  jr Z,0xf7e80c
	ld	xiy, DL_F39854	; F7E7FC  ld XIY,0x00f39854
	ld	xix, DL_F39870	; F7E801  ld XIX,0x00f39870
	call	T_DisplayList_Run	; F7E806  call 0xf417f0
	jr	TrackAssign_PaintTrackGroup_Join2	; F7E80A  jr T,0xf7e81a
TrackAssign_PaintTrackGroup_Skip2:
	ld	xiy, DL_F39870	; F7E80C  ld XIY,0x00f39870
	ld	xix, DL_F3987A	; F7E811  ld XIX,0x00f3987a
	call	T_DisplayList_Run	; F7E816  call 0xf417f0
TrackAssign_PaintTrackGroup_Join2:
	and	(0xc6:8), 0xfe	; F7E81A  and (0xc6),0xfe
	ret	; F7E81E  ret

; Evidence: reached from calr from prom_b 0xF7E7CF; calr from prom_b
;           0xF7E7EB, and from nothing else the scans see.
; TrackAssign_DrawOutChannelColumn: TRACK ASSIGN, MIDI OUT CH column: for the eight tracks of the shown group (A =
;   first track, XHL = their bytes: 0x603433.. for 1-8, 0x60343B.. for 9-16) stages each byte in DisplayListB_Stage
;   and draws the matching TrackAssign_DrawOutChannelColumn_DL record through DLB_Handler_StringTable, whose table is Table_F3B7D4+0xF4 ('1-
;   1CH'..'2-16CH', index 0x20 = ' OFF '). Basis: caller + body + display list. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_b8.json)
TrackAssign_DrawOutChannelColumn:
	ld	xiy, TrackAssign_DrawOutChannelColumn_DL	; F7E81F  ld XIY,0x00f3b74b
	xor	bc, bc	; F7E824  xor BC,BC
TrackAssign_DrawOutChannelColumn_Loop:
	pushw	wa	; F7E826  push WA
	push	xhl	; F7E827  push XHL
	push	xiy	; F7E828  push XIY
	call	T_TrackAssign_IsLocalControlDashed_Copy	; F7E829  call 0xf42b98
	pop	xiy	; F7E82D  pop XIY
	pop	xhl	; F7E82E  pop XHL
	ld	b, (xhl)	; F7E82F  ld B,(XHL)
	ld	(DisplayListB_Stage:16), b	; F7E831  ld (0x12f6),B
	push	xiy	; F7E835  push XIY
	push	xhl	; F7E836  push XHL
	pushw	bc	; F7E837  push BC
	call	T_DLB_Handler_StringTable	; F7E838  call 0xf417f8
	popw	bc	; F7E83C  pop BC
	pop	xhl	; F7E83D  pop XHL
	pop	xiy	; F7E83E  pop XIY
	popw	wa	; F7E83F  pop WA
	add	xiy, 15	; F7E840  add XIY,0x0000000f
	inc	1, a	; F7E846  inc 1,A
	inc	1, xhl	; F7E848  inc 1,XHL
	inc	1, c	; F7E84A  inc 1,C
	cp	c, 8	; F7E84C  cp C,0x08
	jr	c, TrackAssign_DrawOutChannelColumn_Loop	; F7E84F  jr C,0xf7e826
	ret	; F7E851  ret

; Evidence: reached from calr from prom_b 0xF7E7C5; calr from prom_b
;           0xF7E7E1, and from nothing else the scans see.
; TrackAssign_DrawLocalControlColumn: TRACK ASSIGN, LOCAL CONTROL column: for bits 0..7 of L (the per-track bits of
;   the word 0x603454 -- low byte for tracks 1-8, high byte for 9-16) draws TrackAssign_DrawLocalControlColumn_DL's eight records with
;   DisplayListB_Stage = 0 ('OFF') or 1 ('ON '); 2 ('-- ') only if T_TrackAssign_IsLocalControlDashed returned 0x55, which it never does (it
;   always returns 0xAA). TrackAssign_StageZero_SoftKeyCol5 toggles the same bits. Basis: caller + body + display
;   list. (notes/naming-pilot-2026-10-06/proposals_wave8_b8.json)
TrackAssign_DrawLocalControlColumn:
	ld	xiy, TrackAssign_DrawLocalControlColumn_DL	; F7E852  ld XIY,0x00f3b6d3
	ld	c, 1:opc	; F7E857  ld C,0x01
TrackAssign_DrawLocalControlColumn_Loop:
	pushw	wa	; F7E859  push WA
	push	xhl	; F7E85A  push XHL
	push	xiy	; F7E85B  push XIY
	call	T_TrackAssign_IsLocalControlDashed	; F7E85C  call 0xf42b9c
	cp	a, 85	; F7E860  cp A,0x55
	pop	xiy	; F7E863  pop XIY
	pop	xhl	; F7E864  pop XHL
	popw	wa	; F7E865  pop WA
	jr	nz, sub_F7E852_Entry	; F7E866  jr NZ,0xf7e86f
	ld	(DisplayListB_Stage:16), 2	; F7E868  ld (0x12f6),0x02
	jr	sub_F7E852_Join	; F7E86D  jr T,0xf7e885
sub_F7E852_Entry:
	ldfr_berp	l, 0x3c	; F7E86F  ld RL3,L
	and	l, c	; F7E872  and L,C
	ldto_berp	l, 0x3c	; F7E874  ld L,RL3
	jr	nz, sub_F7E852_Skip	; F7E877  jr NZ,0xf7e880
	ld	(DisplayListB_Stage:16), 0	; F7E879  ld (0x12f6),0x00
	jr	sub_F7E852_Join	; F7E87E  jr T,0xf7e885
sub_F7E852_Skip:
	ld	(DisplayListB_Stage:16), 1	; F7E880  ld (0x12f6),0x01
sub_F7E852_Join:
	push	xiy	; F7E885  push XIY
	pushw	wa	; F7E886  push WA
	push	xhl	; F7E887  push XHL
	pushw	bc	; F7E888  push BC
	call	T_DLB_Handler_StringTable	; F7E889  call 0xf417f8
	popw	bc	; F7E88D  pop BC
	pop	xhl	; F7E88E  pop XHL
	popw	wa	; F7E88F  pop WA
	pop	xiy	; F7E890  pop XIY
	add	xiy, 15	; F7E891  add XIY,0x0000000f
	inc	1, a	; F7E897  inc 1,A
	sla	c, 1	; F7E899  sla 0x01,C
	jr	nc, TrackAssign_DrawLocalControlColumn_Loop	; F7E89C  jr NC,0xf7e859
	ret	; F7E89E  ret

; ---------------------------------------------------------------------
; Paint_TrackLabels1To8 -- draws the eight track labels its own list spells
;
; Called from: calr from prom_b 0xF7E7B8
; Evidence: the routine's one display list, 0xF3B5D1, holds eight op-0x06
;           records -- LCD_Svc_06_DrawText8x14 -- and their text bytes spell
;           "TR 1" through "TR 8", read from the ROM. The name is that text;
;           TR is the ROM own abbreviation for a sequencer track, and the
;           screen that reaches this row is the one whose title spells TRACK
;           ASSIGN.
; ---------------------------------------------------------------------
Paint_TrackLabels1To8:
	ld	(LCD_CurrentLayer:16), 0	; F7E89F  ld (0x2540),0x00
	calr	ButtonTable_SequencerMedley_Nop	; F7E8A4  calr 0xf7e2d8
	ld	xiy, Paint_TrackLabels1To8_DL	; F7E8A7  ld XIY,0x00f3b5d1
	ld	xix, Paint_TrackLabels9To16_DL	; F7E8AC  ld XIX,0x00f3b611
	call	T_DisplayList_Run	; F7E8B1  call 0xf417f0
	ret	; F7E8B5  ret

; ---------------------------------------------------------------------
; Paint_TrackLabels9To16 -- draws the eight track labels its own list spells
;
; Called from: calr from prom_b 0xF7E7D4
; Evidence: the routine's one display list, 0xF3B611, holds eight op-0x06
;           records -- LCD_Svc_06_DrawText8x14 -- and their text bytes spell
;           "TR 9" through "TR16", read from the ROM. The name is that text;
;           TR is the ROM own abbreviation for a sequencer track, and the
;           screen that reaches this row is the one whose title spells TRACK
;           ASSIGN.
; ---------------------------------------------------------------------
Paint_TrackLabels9To16:
	ld	(LCD_CurrentLayer:16), 0	; F7E8B6  ld (0x2540),0x00
	calr	ButtonTable_SequencerMedley_Nop	; F7E8BB  calr 0xf7e2d8
	ld	xiy, Paint_TrackLabels9To16_DL	; F7E8BE  ld XIY,0x00f3b611
	ld	xix, TrackAssign_PaintTrackGroup_DL	; F7E8C3  ld XIX,0x00f3b651
	call	T_DisplayList_Run	; F7E8C8  call 0xf417f0
	ret	; F7E8CC  ret

; Evidence: reached from calr from prom_b 0xF7E7BB, and from nothing else
;           the scans see.
; TrackAssign_DrawParts1To8: TRACK ASSIGN, TRACK ASSIGN column for tracks 1-8: copies BStore_TrackToPart[0..7] to
;   UI_DrawScratch+1..+8 and runs DL_F3B65B through interpreter B on layer 0 -- eight string-table readouts of 'PART
;   n' (Table_F3B7D4+0x14). Paired with Paint_TrackLabels1To8 in TrackAssign_PaintTrackGroup. Basis: caller + body +
;   display list. (notes/naming-pilot-2026-10-06/proposals_wave8_b8.json)
TrackAssign_DrawParts1To8:
	ld	(LCD_CurrentLayer:16), 0	; F7E8CD  ld (0x2540),0x00
	calr	ButtonTable_SequencerMedley_Nop	; F7E8D2  calr 0xf7e2d8
	ld	xiy, BStore_TrackToPart	; F7E8D5  ld XIY,0x00603422
	ld	xix, UI_DrawScratch+1	; F7E8DA  ld XIX,0x00002641
	ldw	bc, 8	; F7E8DF  ld BC,0x0008
	ldir85	; F7E8E2  ldir
	ld	xiy, DL_F3B65B	; F7E8E4  ld XIY,0x00f3b65b
	ld	xix, TrackAssign_DrawLocalControlColumn_DL	; F7E8E9  ld XIX,0x00f3b6d3
	call	T_DisplayListB_Run	; F7E8EE  call 0xf417f4
	ret	; F7E8F2  ret

; Evidence: reached from calr from prom_b 0xF7E7D7, and from nothing else
;           the scans see.
; TrackAssign_DrawParts9To16: TRACK ASSIGN, TRACK ASSIGN column for tracks 9-16: as TrackAssign_DrawParts1To8 with
;   BStore_TrackToPart[8..15] (0x60342A) -- copies them to UI_DrawScratch+1..+8 and runs DL_F3B65B ('PART n'
;   readouts). Paired with Paint_TrackLabels9To16. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_b8.json)
TrackAssign_DrawParts9To16:
	ld	(LCD_CurrentLayer:16), 0	; F7E8F3  ld (0x2540),0x00
	calr	ButtonTable_SequencerMedley_Nop	; F7E8F8  calr 0xf7e2d8
	ld	xiy, 6304810	; F7E8FB  ld XIY,0x0060342a
	ld	xix, UI_DrawScratch+1	; F7E900  ld XIX,0x00002641
	ldw	bc, 8	; F7E905  ld BC,0x0008
	ldir85	; F7E908  ldir
	ld	xiy, DL_F3B65B	; F7E90A  ld XIY,0x00f3b65b
	ld	xix, TrackAssign_DrawLocalControlColumn_DL	; F7E90F  ld XIX,0x00f3b6d3
	call	T_DisplayListB_Run	; F7E914  call 0xf417f4
	ret	; F7E918  ret

; Evidence: reached from calr from prom_b 0xF7E7AA, and from nothing else
;           the scans see.
; TrackAssign_DrawTrackGroupHighlight: TRACK ASSIGN: on layer 1 erases (op 0x1B) the box (12,111)-(49,165) of
;   TrackAssign_DrawTrackGroupHighlight_DL and fills (svc 0x05) one of two boxes indexed by (0x0C07) & 1 -- (12,111)-(43,126) around the '1_8'
;   legend or (12,150)-(49,165) around '9_16' -- marking the shown track group. Basis: caller + body + display list.
;   (notes/naming-pilot-2026-10-06/proposals_wave8_b8.json)
TrackAssign_DrawTrackGroupHighlight:
	ld	(LCD_CurrentLayer:16), 1	; F7E919  ld (0x2540),0x01
	calr	ButtonTable_SequencerMedley_Nop	; F7E91E  calr 0xf7e2d8
	ld	xiy, TrackAssign_DrawTrackGroupHighlight_DL	; F7E921  ld XIY,0x00f3b7c3
	ld	xix, Data_F3B7CD	; F7E926  ld XIX,0x00f3b7cd
	call	T_DisplayList_Run	; F7E92B  call 0xf417f0
	ld	a, (3079:16)	; F7E92F  ld A,(0x0c07)
	ld	(DisplayListB_Stage+4:16), a	; F7E933  ld (0x12fa),A
	ld	xiy, Data_F3B7CD	; F7E937  ld XIY,0x00f3b7cd
	call	T_DLB_Handler_Array8	; F7E93C  call 0xf4181c
	ret	; F7E940  ret

; Evidence: reached from calr from prom_b 0xF7E7A7, and from nothing else
;           the scans see.
; TrackAssign_DrawTrackRowHighlight: TRACK ASSIGN: on layer 1 erases (op 0x1B) the eight-row table area TrackAssign_DrawTrackRowHighlight_DL
;   (56,62)-(279,181) and fills (svc 0x05) row box DLTable_F396ED[(0x0C03) mod 8] -- the row of the selected track
;   (0x0C03), 0..15. Basis: caller + body + display list. (notes/naming-pilot-2026-10-06/proposals_wave8_b8.json)
TrackAssign_DrawTrackRowHighlight:
	ld	(LCD_CurrentLayer:16), 1	; F7E941  ld (0x2540),0x01
	calr	ButtonTable_SequencerMedley_Nop	; F7E946  calr 0xf7e2d8
	ld	xiy, TrackAssign_DrawTrackRowHighlight_DL	; F7E949  ld XIY,0x00f3972d
	ld	xix, TrackAssign_DrawSelectedPart_DL	; F7E94E  ld XIX,0x00f39737
	call	T_DisplayList_Run	; F7E953  call 0xf417f0
	ld	a, (3075:16)	; F7E957  ld A,(0x0c03)
	cp	a, 8	; F7E95B  cp A,0x08
	jr	c, TrackAssign_DrawTrackRowHighlight_Skip	; F7E95E  jr C,0xf7e963
	sub	a, 8	; F7E960  sub A,0x08
TrackAssign_DrawTrackRowHighlight_Skip:
	ld	(UI_DrawScratch:16), a	; F7E963  ld (0x2640),A
	ld	xiy, Data_F396E2	; F7E967  ld XIY,0x00f396e2
	call	T_DLB_Handler_Array8	; F7E96C  call 0xf4181c
	ret	; F7E970  ret

; Evidence: screen 0xF43040's Enter method body; that screen's Enter draws
;           no titled list, so it has no name.
; ModeEnterBody_Edit: The whole body of ModeEnter_Edit (+0 ENTER of panel mode 7, EDIT): `or (0x2134),2` (the mode-
;   change bit ModeEnter_Sound/_Combination set), then via its veneer Seq_SaveTrackMaskAndStopAll, UI_ScreenStage :=
;   0, (0x215E) := 0, (0x212E) |= 0x100, (0x34BB) |= 4. Its LEAVE twin (0xF7E97C, behind sub_F7D01C) restores the mask
;   and clears (0x34BB) bit 2. Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave8_b8.json)
ModeEnterBody_Edit:
	orw	(0x2134:16), 0x0002	; F7E971  or (0x2134),0x0002
	call	T_BStore_AppendBytes_Join3_Veneer	; F7E977  call 0xf428b0
	ret	; F7E97B  ret

; Evidence: screen 0xF43040's Leave method body; that screen's Enter draws
;           no titled list, so it has no name.
sub_F7E97C:
	orw	(0x2134:16), 0x0002	; F7E97C  or (0x2134),0x0002
	call	T_BStore_AppendBytes_Join4_Veneer	; F7E982  call 0xf428b4
	ret	; F7E986  ret

; ---------------------------------------------------------------------
; Paint_Edit -- paints the panel screen whose own title text reads "EDIT"
;
; Reached by: the +0 method stub of screen object 0xF43050, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: calr from prom_b 0xF7D02A
; Evidence: the routine loads XIY = 0xF39D3E and calls the display-list
;           interpreter; the leading run of op-0x1C records in that list
;           spells "EDIT", and the name is that text CamelCased, with the
;           ROM's own spelling kept (zeros for O's included). The rule is
;           round 7's, calibrated on seven screens prom_a had named
;           independently: notes/prom_b_screens_round8.py --calibrate.
; ---------------------------------------------------------------------
Paint_Edit:
	cp	(UI_ScreenLatch_Previous:16), 0x1a	; F7E987  cp (0x207b),0x1a
	jr	z, Paint_Edit_Skip	; F7E98C  jr Z,0xf7e993
	ld	(3088:16), 0	; F7E98E  ld (0x0c10),0x00
Paint_Edit_Skip:
	call	T_CallbackQueue_ResetAndRestartTask2	; F7E993  call 0xf42e80
	calr	LCD_ScreenRedraw_Begin	; F7E997  calr 0xf7e2d9
	cp	(0x0c10:16), 0x00	; F7E99A  cp (0x0c10),0x00
	jr	nz, Paint_Edit_Skip2	; F7E99F  jr NZ,0xf7e9b1
	ld	xiy, DL_EditSeqN0teEditS0ngClear	; F7E9A1  ld XIY,0x00f39d3e
	ld	xix, DL_EditSeqSongCopyCopyErase	; F7E9A6  ld XIX,0x00f39e87
	call	T_DisplayList_Run	; F7E9AB  call 0xf417f0
	jr	Paint_Edit_Join	; F7E9AF  jr T,0xf7e9bf
Paint_Edit_Skip2:
	ld	xiy, DL_EditSeqSongCopyCopyErase	; F7E9B1  ld XIY,0x00f39e87
	ld	xix, DL_TrackClearPressTheUpDown	; F7E9B6  ld XIX,0x00f39f8a
	call	T_DisplayList_Run	; F7E9BB  call 0xf417f0
Paint_Edit_Join:
	call	T_F42E1C	; F7E9BF  call 0xf42e1c
	calr	LCD_ScreenRedraw_End	; F7E9C3  calr 0xf7e2e7
	ret	; F7E9C6  ret
ButtonTable_Edit_0C10Zero_Nop0:
	ret	; F7E9C7  ret   <- button table 0xF7D2D8 entry 0 (EDIT) and 7 more slot(s)

; ---------------------------------------------------------------------
; LcdKeyRow1_Edit_0C10Zero -- row 1 of the five key pairs flanking the LCD, on
;           the Edit_0C10Zero screen
; Reached by: SW25 "LCD RIGHT 1 (top)" (matrix segment 3 bit 0, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A2
;           {class 0xA9, code 0x08} -> delivered code 0x08; SW73 "LCD LEFT 1
;           (top)" (matrix segment 9 bit 0, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B71F
;           {class 0xA9, code 0x08} -> delivered code 0x88. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x08 of ButtonTable_Edit_0C10Zero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW73 LCD LEFT 1
;           (top) (segment 9 bit 0, fitted); SW81 [no legend: matrix position
;           outside every diode list] (segment 10 bit 0, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW25 is row 1 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow1_Edit_0C10Zero:
	bit	7, w	; F7E9C8  bit 0x07,W
	jr	nz, Paint_Edit_Skip3	; F7E9CB  jr NZ,0xf7e9d5
	ldw	(UI_Request:16), 32795	; F7E9CD  ld (0x2070),0x801b
	jr	Paint_Edit_Return	; F7E9D3  jr T,0xf7e9db
Paint_Edit_Skip3:
	ldw	(UI_Request:16), 32804	; F7E9D5  ld (0x2070),0x8024
Paint_Edit_Return:
	ret	; F7E9DB  ret

; ---------------------------------------------------------------------
; LcdKeyRow2_Edit_0C10Zero -- row 2 of the five key pairs flanking the LCD, on
;           the Edit_0C10Zero screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_Edit_0C10Zero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_Edit_0C10Zero:
	bit	7, w	; F7E9DC  bit 0x07,W
	jr	nz, Paint_Edit_Skip4	; F7E9DF  jr NZ,0xf7e9e9
	ldw	(UI_Request:16), 32796	; F7E9E1  ld (0x2070),0x801c
	jr	Paint_Edit_Return2	; F7E9E7  jr T,0xf7e9ef
Paint_Edit_Skip4:
	ldw	(UI_Request:16), 32807	; F7E9E9  ld (0x2070),0x8027
Paint_Edit_Return2:
	ret	; F7E9EF  ret

; ---------------------------------------------------------------------
; LcdKeyRow3_Edit_0C10Zero -- row 3 of the five key pairs flanking the LCD, on
;           the Edit_0C10Zero screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_Edit_0C10Zero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_Edit_0C10Zero:
	bit	7, w	; F7E9F0  bit 0x07,W
	jr	nz, Paint_Edit_Skip5	; F7E9F3  jr NZ,0xf7e9fd
	ldw	(UI_Request:16), 32813	; F7E9F5  ld (0x2070),0x802d
	jr	Paint_Edit_Return3	; F7E9FB  jr T,0xf7ea03
Paint_Edit_Skip5:
	ldw	(UI_Request:16), 32798	; F7E9FD  ld (0x2070),0x801e
Paint_Edit_Return3:
	ret	; F7EA03  ret

; ---------------------------------------------------------------------
; LcdKeyRow4_Edit_0C10Zero -- row 4 of the five key pairs flanking the LCD, on
;           the Edit_0C10Zero screen
; Reached by: SW28 "LCD RIGHT 4" (matrix segment 3 bit 3, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AE
;           {class 0xA9, code 0x0B} -> delivered code 0x0B; SW76 "LCD LEFT 4"
;           (matrix segment 9 bit 3, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72B
;           {class 0xA9, code 0x0B} -> delivered code 0x8B. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0B of ButtonTable_Edit_0C10Zero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW76 LCD LEFT 4
;           (segment 9 bit 3, fitted); SW84 [no legend: matrix position
;           outside every diode list] (segment 10 bit 3, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW28 is row 4 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow4_Edit_0C10Zero:
	bit	7, w	; F7EA04  bit 0x07,W
	jr	nz, Paint_Edit_Skip6	; F7EA07  jr NZ,0xf7ea11
	ldw	(UI_Request:16), 32812	; F7EA09  ld (0x2070),0x802c
	jr	Paint_Edit_Return4	; F7EA0F  jr T,0xf7ea17
Paint_Edit_Skip6:
	ldw	(UI_Request:16), 32811	; F7EA11  ld (0x2070),0x802b
Paint_Edit_Return4:
	ret	; F7EA17  ret

; ---------------------------------------------------------------------
; LcdKeyRow5_Edit_0C10Zero -- row 5 of the five key pairs flanking the LCD, on
;           the Edit_0C10Zero screen
; Reached by: SW29 "LCD RIGHT 5 (bottom)" (matrix segment 3 bit 4, wire 0xC3)
;           -> PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record
;           0xF8B6B2 {class 0xA9, code 0x0C} -> delivered code 0x0C; SW77 "LCD
;           LEFT 5 (bottom)" (matrix segment 9 bit 4, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72F
;           {class 0xA9, code 0x0C} -> delivered code 0x8C. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0C of ButtonTable_Edit_0C10Zero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW77 LCD LEFT 5
;           (bottom) (segment 9 bit 4, fitted); SW85 [no legend: matrix
;           position outside every diode list] (segment 10 bit 4, NOT fitted
;           on this panel). The model strap is the RAM byte (0x00C4), latched
;           from PB bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2
;           is the SX-WSA1R (notes/wave7_panel_names_round11.py --variant,
;           three independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: page
;           I-4/I-5 draws a COLUMN OF FIVE keys down each side of the display
;           and SW29 is the bottom one. ⚠ GRADE POSITION in
;           notes/wave7_panel_button_codes.py --physical -- row 5 is the one
;           row of the column the Outsel check does NOT annotate, so unlike
;           rows 1-4 it rests on the silkscreen position alone. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow5_Edit_0C10Zero:
	bit	7, w	; F7EA18  bit 0x07,W
	jr	nz, Paint_Edit_Skip7	; F7EA1B  jr NZ,0xf7ea25
	ldw	(UI_Request:16), 32814	; F7EA1D  ld (0x2070),0x802e
	jr	Paint_Edit_Return5	; F7EA23  jr T,0xf7ea2b
Paint_Edit_Skip7:
	ldw	(UI_Request:16), 32797	; F7EA25  ld (0x2070),0x801d
Paint_Edit_Return5:
	ret	; F7EA2B  ret
ButtonTable_Edit_0C10Zero_Nop13:
	ret	; F7EA2C  ret   <- button table 0xF7D2D8 entry 13 (EDIT) and 1 more slot(s)

; ---------------------------------------------------------------------
; ExitKey_Edit_0C10Zero -- the EXIT key on the Edit_0C10Zero screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_Edit_0C10Zero:
	bit	7, w	; F7EA2D  bit 0x07,W
	jr	nz, Paint_Edit_Return6	; F7EA30  jr NZ,0xf7ea3a
	ldw	(UI_Request:16), 515	; F7EA32  ld (0x2070),0x0203
	jr	Paint_Edit_Return6	; F7EA38  jr T,0xf7ea3a
Paint_Edit_Return6:
	ret	; F7EA3A  ret

; ---------------------------------------------------------------------
; PageKey_Edit_0C10Zero -- the PAGE ^ / PAGE v pair, on the Edit_0C10Zero
;           screen
; Reached by: SW21 "PAGE v" (matrix segment 2 bit 4, wire 0xC2) ->
;           PanelWireGroupMap_Variant2[0x62] = group 0x02 -> record 0xF8B695
;           {class 0xA9, code 0x10} -> delivered code 0x90; SW22 "PAGE ^"
;           (matrix segment 2 bit 5, wire 0xC2) ->
;           PanelWireGroupMap_Variant2[0x62] = group 0x02 -> record 0xF8B699
;           {class 0xA9, code 0x10} -> delivered code 0x10. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x10 of ButtonTable_Edit_0C10Zero.
; Note:     bit 7 of the delivered code picks the DIRECTION: set = SW21 PAGE
;           v, clear = SW22 PAGE ^.
; Note:     Also registered at slot 0x19, which is the CLAMP arm of the
;           variant-1 rewriters 0xF8AE68/0xF8AEDB and fires only for a base
;           above 0x0E; the only bases those two handlers ever see are
;           0x00-0x07, so the 0x19 registration is dead in BOTH variants and
;           this control is the routine's only caller.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW79 [no legend:
;           matrix position outside every diode list] (segment 9 bit 6, NOT
;           fitted on this panel); SW80 [no legend: matrix position outside
;           every diode list] (segment 9 bit 7, NOT fitted on this panel). The
;           model strap is the RAM byte (0x00C4), latched from PB bit 0 by
;           prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: GRADE LEGEND in notes/wave7_panel_button_codes.py --physical: the
;           manual PRINTS "PAGE" beside SW21/SW22 on the CP1 silkscreen (page
;           II-27/28), so this name borrows a word from the instrument. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
PageKey_Edit_0C10Zero:
	bit	7, w	; F7EA3B  bit 0x07,W
	jr	nz, Paint_Edit_Join2	; F7EA3E  jr NZ,0xf7ea42
	jr	Paint_Edit_Join2	; F7EA40  jr T,0xf7ea42
Paint_Edit_Join2:
	cp	(0x0c10:16), 0x01	; F7EA42  cp (0x0c10),0x01
	jr	z, Paint_Edit_Return7	; F7EA47  jr Z,0xf7ea53
	ld	(3088:16), 1	; F7EA49  ld (0x0c10),0x01
	or	(UI_Request_Hi:16), 0x10	; F7EA4E  or (0x2071),0x10
Paint_Edit_Return7:
	ret	; F7EA53  ret
ButtonTable_Edit_0C10Zero_Nop17:
	ret	; F7EA54  ret   <- button table 0xF7D2D8 entry 17 (EDIT) and 13 more slot(s)
ScreenNull_Edit_Nop:
	ret	; F7EA55  ret
ButtonTable_Edit_0C10NonZero_Nop0:
	ret	; F7EA56  ret   <- button table 0xF7D358 entry 0 (EDIT) and 7 more slot(s)

; ---------------------------------------------------------------------
; LcdKeyRow1_Edit_0C10NonZero -- row 1 of the five key pairs flanking the LCD,
;           on the Edit_0C10NonZero screen
; Reached by: SW25 "LCD RIGHT 1 (top)" (matrix segment 3 bit 0, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A2
;           {class 0xA9, code 0x08} -> delivered code 0x08; SW73 "LCD LEFT 1
;           (top)" (matrix segment 9 bit 0, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B71F
;           {class 0xA9, code 0x08} -> delivered code 0x88. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x08 of ButtonTable_Edit_0C10NonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW73 LCD LEFT 1
;           (top) (segment 9 bit 0, fitted); SW81 [no legend: matrix position
;           outside every diode list] (segment 10 bit 0, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW25 is row 1 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow1_Edit_0C10NonZero:
	bit	7, w	; F7EA57  bit 0x07,W
	jr	nz, Paint_Edit_Skip8	; F7EA5A  jr NZ,0xf7ea64
	ldw	(UI_Request:16), 32801	; F7EA5C  ld (0x2070),0x8021
	jr	Paint_Edit_Return8	; F7EA62  jr T,0xf7ea6a
Paint_Edit_Skip8:
	ldw	(UI_Request:16), 32810	; F7EA64  ld (0x2070),0x802a
Paint_Edit_Return8:
	ret	; F7EA6A  ret

; ---------------------------------------------------------------------
; LcdKeyRow2_Edit_0C10NonZero -- row 2 of the five key pairs flanking the LCD,
;           on the Edit_0C10NonZero screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_Edit_0C10NonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_Edit_0C10NonZero:
	bit	7, w	; F7EA6B  bit 0x07,W
	jr	nz, Paint_Edit_Return9	; F7EA6E  jr NZ,0xf7ea78
	ldw	(UI_Request:16), 32800	; F7EA70  ld (0x2070),0x8020
	jr	Paint_Edit_Return9	; F7EA76  jr T,0xf7ea78
Paint_Edit_Return9:
	ret	; F7EA78  ret

; ---------------------------------------------------------------------
; LcdKeyRow3_Edit_0C10NonZero -- row 3 of the five key pairs flanking the LCD,
;           on the Edit_0C10NonZero screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_Edit_0C10NonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_Edit_0C10NonZero:
	bit	7, w	; F7EA79  bit 0x07,W
	jr	nz, Paint_Edit_Skip9	; F7EA7C  jr NZ,0xf7ea86
	ldw	(UI_Request:16), 32803	; F7EA7E  ld (0x2070),0x8023
	jr	Paint_Edit_Return10	; F7EA84  jr T,0xf7ea8c
Paint_Edit_Skip9:
	ldw	(UI_Request:16), 32799	; F7EA86  ld (0x2070),0x801f
Paint_Edit_Return10:
	ret	; F7EA8C  ret

; ---------------------------------------------------------------------
; LcdKeyRow4_Edit_0C10NonZero -- row 4 of the five key pairs flanking the LCD,
;           on the Edit_0C10NonZero screen
; Reached by: SW28 "LCD RIGHT 4" (matrix segment 3 bit 3, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AE
;           {class 0xA9, code 0x0B} -> delivered code 0x0B; SW76 "LCD LEFT 4"
;           (matrix segment 9 bit 3, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72B
;           {class 0xA9, code 0x0B} -> delivered code 0x8B. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0B of ButtonTable_Edit_0C10NonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW76 LCD LEFT 4
;           (segment 9 bit 3, fitted); SW84 [no legend: matrix position
;           outside every diode list] (segment 10 bit 3, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW28 is row 4 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow4_Edit_0C10NonZero:
	bit	7, w	; F7EA8D  bit 0x07,W
	jr	nz, Paint_Edit_Return11	; F7EA90  jr NZ,0xf7ea9a
	ldw	(UI_Request:16), 32802	; F7EA92  ld (0x2070),0x8022
	jr	Paint_Edit_Return11	; F7EA98  jr T,0xf7ea9a
Paint_Edit_Return11:
	ret	; F7EA9A  ret

; ---------------------------------------------------------------------
; LcdKeyRow5_Edit_0C10NonZero -- row 5 of the five key pairs flanking the LCD,
;           on the Edit_0C10NonZero screen
; Reached by: SW29 "LCD RIGHT 5 (bottom)" (matrix segment 3 bit 4, wire 0xC3)
;           -> PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record
;           0xF8B6B2 {class 0xA9, code 0x0C} -> delivered code 0x0C; SW77 "LCD
;           LEFT 5 (bottom)" (matrix segment 9 bit 4, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72F
;           {class 0xA9, code 0x0C} -> delivered code 0x8C. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0C of ButtonTable_Edit_0C10NonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW77 LCD LEFT 5
;           (bottom) (segment 9 bit 4, fitted); SW85 [no legend: matrix
;           position outside every diode list] (segment 10 bit 4, NOT fitted
;           on this panel). The model strap is the RAM byte (0x00C4), latched
;           from PB bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2
;           is the SX-WSA1R (notes/wave7_panel_names_round11.py --variant,
;           three independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: page
;           I-4/I-5 draws a COLUMN OF FIVE keys down each side of the display
;           and SW29 is the bottom one. ⚠ GRADE POSITION in
;           notes/wave7_panel_button_codes.py --physical -- row 5 is the one
;           row of the column the Outsel check does NOT annotate, so unlike
;           rows 1-4 it rests on the silkscreen position alone. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow5_Edit_0C10NonZero:
	bit	7, w	; F7EA9B  bit 0x07,W
	jr	nz, Paint_Edit_Return12	; F7EA9E  jr NZ,0xf7eaa2
	jr	Paint_Edit_Return12	; F7EAA0  jr T,0xf7eaa2
Paint_Edit_Return12:
	ret	; F7EAA2  ret
ButtonTable_Edit_0C10NonZero_Nop13:
	ret	; F7EAA3  ret   <- button table 0xF7D358 entry 13 (EDIT) and 1 more slot(s)

; ---------------------------------------------------------------------
; ExitKey_Edit_0C10NonZero -- the EXIT key on the Edit_0C10NonZero screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_Edit_0C10NonZero:
	bit	7, w	; F7EAA4  bit 0x07,W
	jr	nz, Paint_Edit_Return13	; F7EAA7  jr NZ,0xf7eab5
	ld	(3088:16), 0	; F7EAA9  ld (0x0c10),0x00
	ld	(UI_Request_Hi:16), 16	; F7EAAE  ld (0x2071),0x10
	jr	Paint_Edit_Return13	; F7EAB3  jr T,0xf7eab5
Paint_Edit_Return13:
	ret	; F7EAB5  ret

; ---------------------------------------------------------------------
; PageKey_Edit_0C10NonZero -- the PAGE ^ / PAGE v pair, on the
;           Edit_0C10NonZero screen
; Reached by: SW21 "PAGE v" (matrix segment 2 bit 4, wire 0xC2) ->
;           PanelWireGroupMap_Variant2[0x62] = group 0x02 -> record 0xF8B695
;           {class 0xA9, code 0x10} -> delivered code 0x90; SW22 "PAGE ^"
;           (matrix segment 2 bit 5, wire 0xC2) ->
;           PanelWireGroupMap_Variant2[0x62] = group 0x02 -> record 0xF8B699
;           {class 0xA9, code 0x10} -> delivered code 0x10. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x10 of ButtonTable_Edit_0C10NonZero.
; Note:     bit 7 of the delivered code picks the DIRECTION: set = SW21 PAGE
;           v, clear = SW22 PAGE ^.
; Note:     Also registered at slot 0x19, which is the CLAMP arm of the
;           variant-1 rewriters 0xF8AE68/0xF8AEDB and fires only for a base
;           above 0x0E; the only bases those two handlers ever see are
;           0x00-0x07, so the 0x19 registration is dead in BOTH variants and
;           this control is the routine's only caller.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW79 [no legend:
;           matrix position outside every diode list] (segment 9 bit 6, NOT
;           fitted on this panel); SW80 [no legend: matrix position outside
;           every diode list] (segment 9 bit 7, NOT fitted on this panel). The
;           model strap is the RAM byte (0x00C4), latched from PB bit 0 by
;           prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: GRADE LEGEND in notes/wave7_panel_button_codes.py --physical: the
;           manual PRINTS "PAGE" beside SW21/SW22 on the CP1 silkscreen (page
;           II-27/28), so this name borrows a word from the instrument. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
PageKey_Edit_0C10NonZero:
	bit	7, w	; F7EAB6  bit 0x07,W
	jr	nz, Paint_Edit_Join3	; F7EAB9  jr NZ,0xf7eabd
	jr	Paint_Edit_Join3	; F7EABB  jr T,0xf7eabd
Paint_Edit_Join3:
	cp	(0x0c10:16), 0x00	; F7EABD  cp (0x0c10),0x00
	jr	z, Paint_Edit_Return14	; F7EAC2  jr Z,0xf7eace
	ld	(3088:16), 0	; F7EAC4  ld (0x0c10),0x00
	or	(UI_Request_Hi:16), 0x10	; F7EAC9  or (0x2071),0x10
Paint_Edit_Return14:
	ret	; F7EACE  ret
ButtonTable_Edit_0C10NonZero_Nop17:
	ret	; F7EACF  ret   <- button table 0xF7D358 entry 17 (EDIT) and 13 more slot(s)

; ---------------------------------------------------------------------
; Paint_SongClear -- paints the panel screen whose own title text reads
;                    "SONG CLEAR"
;
; Reached by: the +0 method stub of screen object 0xF43060, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: calr from prom_b 0xF7D04C
; Evidence: the routine loads XIY = 0xF399D5 and calls the display-list
;           interpreter; the leading run of op-0x1C records in that list
;           spells "SONG CLEAR", and the name is that text CamelCased, with
;           the ROM's own spelling kept (zeros for O's included). The rule
;           is round 7's, calibrated on seven screens prom_a had named
;           independently: notes/prom_b_screens_round8.py --calibrate.
; ---------------------------------------------------------------------
Paint_SongClear:
	call	T_CallbackQueue_ResetAndRestartTask2	; F7EAD0  call 0xf42e80
	call	T_SongClear_InitFields	; F7EAD4  call 0xf428b8
	cp	(UI_StatusCode:16), 0x23	; F7EAD8  cp (0x2880),0x23
	jrl	z, Paint_SongClear_Join	; F7EADD  jrl Z,0xf7ebcf
	bit	4, (UI_ScreenFlags:16)	; F7EAE0  bit 4,(0x2095)
	jr	nz, Paint_SongClear_Skip	; F7EAE4  jr NZ,0xf7eb16
	calr	LCD_ScreenRedraw_Begin	; F7EAE6  calr 0xf7e2d9
	cp	(UI_ScreenStage:16), 0x00	; F7EAE9  cp (0x207e),0x00
	jrl	nz, Paint_SongClear_Skip4	; F7EAEE  jrl NZ,0xf7eb7a
	or	(UI_RequestBits:16), 0x09	; F7EAF1  or (0x2075),0x09
	ldw	(PanelDial_DownButton:16), 770	; F7EAF6  ld (0x209b),0x0302  <- arms prom_a PanelButton_Accept's substitution for panel button code 0x0D (0xF86615); see the 0xF7D2D8 banner
	ldw	(9830:16), 65535	; F7EAFC  ld (0x2666),0xffff
	ldw	(9834:16), 65535	; F7EB02  ld (0x266a),0xffff
	ld	xiy, DL_SongClearKbSongS0ngAll	; F7EB08  ld XIY,0x00f399d5
	ld	xix, Paint_SongClear_DL1	; F7EB0D  ld XIX,0x00f39a73
	call	T_DisplayList_Run	; F7EB12  call 0xf417f0
Paint_SongClear_Skip:
	ld	a, (3586:16)	; F7EB16  ld A,(0x0e02)
	cp	a, 10	; F7EB1A  cp A,0x0a
	jr	z, Paint_SongClear_Skip2	; F7EB1D  jr Z,0xf7eb37
	ld	(3634:16), a	; F7EB1F  ld (0x0e32),A
	call	SongStore_MeasureSongSize	; F7EB23  call 0xf819e9
	ld	wa, (3631:16)	; F7EB27  ld WA,(0x0e2f)
	ld	(DisplayListB_Stage+8:16), wa	; F7EB2B  ld (0x12fe),WA
	ld	a, (3633:16)	; F7EB2F  ld A,(0x0e31)
	ld	(DisplayListB_Stage+7:16), a	; F7EB33  ld (0x12fd),A
Paint_SongClear_Skip2:
	ld	xiy, Paint_SongClear_DL1	; F7EB37  ld XIY,0x00f39a73
	ld	xix, DL_SongClearKbSongAttenti0n	; F7EB3C  ld XIX,0x00f39a7d
	call	T_DisplayList_Run	; F7EB41  call 0xf417f0
	cp	(0x0e02:16), 0x0a	; F7EB45  cp (0x0e02),0x0a
	jr	nz, Paint_SongClear_Skip3	; F7EB4A  jr NZ,0xf7eb5c
	ld	xiy, Paint_SongClear_DL2	; F7EB4C  ld XIY,0x00f3b244
	ld	xix, Paint_SongClear_DL5	; F7EB51  ld XIX,0x00f3b26c
	call	T_DisplayList_Run	; F7EB56  call 0xf417f0
	jr	Paint_SongClear_Join	; F7EB5A  jr T,0xf7ebcf
Paint_SongClear_Skip3:
	ld	xiy, DL_SongClearKbSongS0ngAll	; F7EB5C  ld XIY,0x00f399d5
	ld	xix, Paint_SongClear_DL1	; F7EB61  ld XIX,0x00f39a73
	call	T_DisplayList_Run	; F7EB66  call 0xf417f0
	ld	xiy, Paint_SongClear_DL3	; F7EB6A  ld XIY,0x00f3998e
	ld	xix, Data_F399C1	; F7EB6F  ld XIX,0x00f399c1
	call	T_DisplayListB_Run	; F7EB74  call 0xf417f4
	jr	Paint_SongClear_Join	; F7EB78  jr T,0xf7ebcf
Paint_SongClear_Skip4:
	bit	4, (UI_ScreenFlags:16)	; F7EB7A  bit 4,(0x2095)
	jr	nz, Paint_SongClear_Skip5	; F7EB7E  jr NZ,0xf7eb8e
	ld	xiy, DL_SongClearKbSongAttenti0n	; F7EB80  ld XIY,0x00f39a7d
	ld	xix, Paint_SongClear_DL4	; F7EB85  ld XIX,0x00f39bf8
	call	T_DisplayList_Run	; F7EB8A  call 0xf417f0
Paint_SongClear_Skip5:
	ld	xiy, Paint_SongClear_DL4	; F7EB8E  ld XIY,0x00f39bf8
	ld	xix, Paint_SongClear_DL6	; F7EB93  ld XIX,0x00f39c02
	call	T_DisplayList_Run	; F7EB98  call 0xf417f0
	cp	(0x0e02:16), 0x0a	; F7EB9C  cp (0x0e02),0x0a
	jr	nz, Paint_SongClear_Skip6	; F7EBA1  jr NZ,0xf7ebb3
	ld	xiy, Paint_SongClear_DL5	; F7EBA3  ld XIY,0x00f3b26c
	ld	xix, DL_AdvanceDelayTrackFirstMeasure	; F7EBA8  ld XIX,0x00f3b294
	call	T_DisplayList_Run	; F7EBAD  call 0xf417f0
	jr	Paint_SongClear_Join	; F7EBB1  jr T,0xf7ebcf
Paint_SongClear_Skip6:
	ld	xiy, DL_SongClearKbSongAttenti0n	; F7EBB3  ld XIY,0x00f39a7d
	ld	xix, Paint_SongClear_DL4	; F7EBB8  ld XIX,0x00f39bf8
	call	T_DisplayList_Run	; F7EBBD  call 0xf417f0
	ld	xiy, Paint_SongClear_DL6	; F7EBC1  ld XIY,0x00f39c02
	ld	xix, DL_TrackClearAttenti0nUsing	; F7EBC6  ld XIX,0x00f39c35
	call	T_DisplayListB_Run	; F7EBCB  call 0xf417f4
Paint_SongClear_Join:
	calr	LCD_ScreenRedraw_End	; F7EBCF  calr 0xf7e2e7
	ld	(UI_StatusCode:16), 255	; F7EBD2  ld (0x2880),0xff
	ret	; F7EBD7  ret

; ---------------------------------------------------------------------
; ScreenLeaveBody_SongClear -- the whole body of the SongClear screen's
;                              Leave method
;
; Reached by: the +4 method stub of screen object 0xF43060, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: calr from prom_b 0xF7D050
; Evidence: the whole body of screen object 0xF43060's +4 method. prom_a's
;           PanelScreen_VtableTable names that object, and its readers take
;           +0 Enter, +4 Leave, +8 Button; the stub at 0xF7D050 is `call
;           0xF7EBD8` then `ret` and nothing else calls this address. The
;           screen's own name is round 7's, from its title text.
; ---------------------------------------------------------------------
ScreenLeaveBody_SongClear:
	call	T_F428BC	; F7EBD8  call 0xf428bc
	ret	; F7EBDC  ret
ButtonTable_SongClear_Nop0:
	ret	; F7EBDD  ret   <- button table 0xF7D3D8 entry 0 (SONG CLEAR) and 1 more slot(s)

; ---------------------------------------------------------------------
; SoftKeyCol3_SongClear -- the 3rd of the eight SOFT KEYS in the row under the
;           LCD, on the SongClear screen
; Reached by: SW37 "SOFT KEY col 3 lower" (matrix segment 4 bit 4, wire 0xC4)
;           -> PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record
;           0xF8B6D3 {class 0xA9, code 0x02} -> delivered code 0x82; SW38
;           "SOFT KEY col 3 upper" (matrix segment 4 bit 5, wire 0xC4) ->
;           PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record 0xF8B6D7
;           {class 0xA9, code 0x02} -> delivered code 0x02. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x02 of ButtonTable_SongClear.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Note:     Also registered at slot 0x13, the VARIANT-1 already-held rewrite
;           of base code 0x02 (`add (XIX-1),0x11` at prom_a
;           0xF8AE7E/0xF8AEF1), so on the SX-WSA1 one routine serves the press
;           and the auto-repeat; on the SX-WSA1R that slot is never delivered.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW45 SOFT KEY col
;           7 lower (segment 5 bit 4, fitted); SW46 SOFT KEY col 7 upper
;           (segment 5 bit 5, fitted); SW53 [no legend: matrix position
;           outside every diode list] (segment 6 bit 4, NOT fitted on this
;           panel); SW54 [no legend: matrix position outside every diode list]
;           (segment 6 bit 5, NOT fitted on this panel). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW37/SW38 are the two switches of its 3rd column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW37, so "col 3" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol3_SongClear:
	cp	(UI_ScreenStage:16), 0x00	; F7EBDE  cp (0x207e),0x00
	jr	nz, SoftKeyCol3_SongClear_Return	; F7EBE3  jr NZ,0xf7ec0f
	call	T_SongClear_SoftKeyCol3	; F7EBE5  call 0xf428c4
	ld	a, (3586:16)	; F7EBE9  ld A,(0x0e02)
	cp	a, 10	; F7EBED  cp A,0x0a
	jr	z, SoftKeyCol3_SongClear_Skip	; F7EBF0  jr Z,0xf7ec0a
	ld	(3634:16), a	; F7EBF2  ld (0x0e32),A
	call	SongStore_MeasureSongSize	; F7EBF6  call 0xf819e9
	ld	wa, (3631:16)	; F7EBFA  ld WA,(0x0e2f)
	ld	(DisplayListB_Stage+8:16), wa	; F7EBFE  ld (0x12fe),WA
	ld	a, (3633:16)	; F7EC02  ld A,(0x0e31)
	ld	(DisplayListB_Stage+7:16), a	; F7EC06  ld (0x12fd),A
SoftKeyCol3_SongClear_Skip:
	or	(UI_ScreenFlags:16), 0x10	; F7EC0A  or (0x2095),0x10
SoftKeyCol3_SongClear_Return:
	ret	; F7EC0F  ret

; ---------------------------------------------------------------------
; SoftKeyCol4_SongClear -- the 4th of the eight SOFT KEYS in the row under the
;           LCD, on the SongClear screen
; Reached by: SW39 "SOFT KEY col 4 lower" (matrix segment 4 bit 6, wire 0xC4)
;           -> PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record
;           0xF8B6DB {class 0xA9, code 0x03} -> delivered code 0x83; SW40
;           "SOFT KEY col 4 upper" (matrix segment 4 bit 7, wire 0xC4) ->
;           PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record 0xF8B6DF
;           {class 0xA9, code 0x03} -> delivered code 0x03. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x03 of ButtonTable_SongClear.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Note:     Also registered at slot 0x14, the VARIANT-1 already-held rewrite
;           of base code 0x03 (`add (XIX-1),0x11` at prom_a
;           0xF8AE7E/0xF8AEF1), so on the SX-WSA1 one routine serves the press
;           and the auto-repeat; on the SX-WSA1R that slot is never delivered.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW47 SOFT KEY col
;           8 lower (segment 5 bit 6, fitted); SW48 SOFT KEY col 8 upper
;           (segment 5 bit 7, fitted); SW55 [no legend: matrix position
;           outside every diode list] (segment 6 bit 6, NOT fitted on this
;           panel); SW56 [no legend: matrix position outside every diode list]
;           (segment 6 bit 7, NOT fitted on this panel). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW39/SW40 are the two switches of its 4th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW39, so "col 4" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol4_SongClear:
	cp	(UI_ScreenStage:16), 0x00	; F7EC10  cp (0x207e),0x00
	jr	nz, SoftKeyCol4_SongClear_Return	; F7EC15  jr NZ,0xf7ec41
	call	T_SongClear_SoftKeyCol4	; F7EC17  call 0xf428c0
	ld	a, (3586:16)	; F7EC1B  ld A,(0x0e02)
	cp	a, 10	; F7EC1F  cp A,0x0a
	jr	z, SoftKeyCol4_SongClear_Skip	; F7EC22  jr Z,0xf7ec3c
	ld	(3634:16), a	; F7EC24  ld (0x0e32),A
	call	SongStore_MeasureSongSize	; F7EC28  call 0xf819e9
	ld	wa, (3631:16)	; F7EC2C  ld WA,(0x0e2f)
	ld	(DisplayListB_Stage+8:16), wa	; F7EC30  ld (0x12fe),WA
	ld	a, (3633:16)	; F7EC34  ld A,(0x0e31)
	ld	(DisplayListB_Stage+7:16), a	; F7EC38  ld (0x12fd),A
SoftKeyCol4_SongClear_Skip:
	or	(UI_ScreenFlags:16), 0x10	; F7EC3C  or (0x2095),0x10
SoftKeyCol4_SongClear_Return:
	ret	; F7EC41  ret
ButtonTable_SongClear_Nop4:
	ret	; F7EC42  ret   <- button table 0xF7D3D8 entry 4 (SONG CLEAR) and 6 more slot(s)

; ---------------------------------------------------------------------
; LcdKeyRow4_SongClear -- row 4 of the five key pairs flanking the LCD, on the
;           SongClear screen
; Reached by: SW28 "LCD RIGHT 4" (matrix segment 3 bit 3, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AE
;           {class 0xA9, code 0x0B} -> delivered code 0x0B; SW76 "LCD LEFT 4"
;           (matrix segment 9 bit 3, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72B
;           {class 0xA9, code 0x0B} -> delivered code 0x8B. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0B of ButtonTable_SongClear.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW76 LCD LEFT 4
;           (segment 9 bit 3, fitted); SW84 [no legend: matrix position
;           outside every diode list] (segment 10 bit 3, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW28 is row 4 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow4_SongClear:
	bit	7, w	; F7EC43  bit 0x07,W
	jr	nz, ScreenLeaveBody_SongClear_Return	; F7EC46  jr NZ,0xf7ec53
	and	(UI_RequestBits:16), 0x6f	; F7EC48  and (0x2075),0x6f
	call	T_SongClear_LcdKeyRow4	; F7EC4D  call 0xf428cc
	jr	ScreenLeaveBody_SongClear_Return	; F7EC51  jr T,0xf7ec53
ScreenLeaveBody_SongClear_Return:
	ret	; F7EC53  ret

; ---------------------------------------------------------------------
; LcdKeyRow5_SongClear -- row 5 of the five key pairs flanking the LCD, on the
;           SongClear screen
; Reached by: SW29 "LCD RIGHT 5 (bottom)" (matrix segment 3 bit 4, wire 0xC3)
;           -> PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record
;           0xF8B6B2 {class 0xA9, code 0x0C} -> delivered code 0x0C; SW77 "LCD
;           LEFT 5 (bottom)" (matrix segment 9 bit 4, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72F
;           {class 0xA9, code 0x0C} -> delivered code 0x8C. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0C of ButtonTable_SongClear.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW77 LCD LEFT 5
;           (bottom) (segment 9 bit 4, fitted); SW85 [no legend: matrix
;           position outside every diode list] (segment 10 bit 4, NOT fitted
;           on this panel). The model strap is the RAM byte (0x00C4), latched
;           from PB bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2
;           is the SX-WSA1R (notes/wave7_panel_names_round11.py --variant,
;           three independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: page
;           I-4/I-5 draws a COLUMN OF FIVE keys down each side of the display
;           and SW29 is the bottom one. ⚠ GRADE POSITION in
;           notes/wave7_panel_button_codes.py --physical -- row 5 is the one
;           row of the column the Outsel check does NOT annotate, so unlike
;           rows 1-4 it rests on the silkscreen position alone. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow5_SongClear:
	bit	7, w	; F7EC54  bit 0x07,W
	jr	nz, ScreenLeaveBody_SongClear_Return2	; F7EC57  jr NZ,0xf7ec5f
	call	T_SongClear_LcdKeyRow5	; F7EC59  call 0xf428c8
	jr	ScreenLeaveBody_SongClear_Return2	; F7EC5D  jr T,0xf7ec5f
ScreenLeaveBody_SongClear_Return2:
	ret	; F7EC5F  ret
ButtonTable_SongClear_Nop13:
	ret	; F7EC60  ret   <- button table 0xF7D3D8 entry 13 (SONG CLEAR) and 1 more slot(s)

; ---------------------------------------------------------------------
; ExitKey_SongClear -- the EXIT key on the SongClear screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_SongClear:
	bit	7, w	; F7EC61  bit 0x07,W
	jr	nz, ScreenLeaveBody_SongClear_Return3	; F7EC64  jr NZ,0xf7ec6e
	ldw	(UI_Request:16), 32794	; F7EC66  ld (0x2070),0x801a
	jr	ScreenLeaveBody_SongClear_Return3	; F7EC6C  jr T,0xf7ec6e
ScreenLeaveBody_SongClear_Return3:
	ret	; F7EC6E  ret
ButtonTable_SongClear_Nop16:
	ret	; F7EC6F  ret   <- button table 0xF7D3D8 entry 16 (SONG CLEAR) and 13 more slot(s)
ScreenNull_SongClear_Nop:
	ret	; F7EC70  ret

; ---------------------------------------------------------------------
; Paint_TrackClear -- paints the panel screen whose own title text reads
;                     "TRACK CLEAR"
;
; Reached by: the +0 method stub of screen object 0xF43070, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: calr from prom_b 0xF7D062
; Evidence: the routine loads XIY = 0xF39F8A and calls the display-list
;           interpreter; the leading run of op-0x1C records in that list
;           spells "TRACK CLEAR", and the name is that text CamelCased, with
;           the ROM's own spelling kept (zeros for O's included). The rule
;           is round 7's, calibrated on seven screens prom_a had named
;           independently: notes/prom_b_screens_round8.py --calibrate.
; ---------------------------------------------------------------------
Paint_TrackClear:
	call	T_CallbackQueue_ResetAndRestartTask2	; F7EC71  call 0xf42e80
	bit	4, (UI_ScreenFlags:16)	; F7EC75  bit 4,(0x2095)
	jr	nz, Paint_TrackClear_Skip	; F7EC79  jr NZ,0xf7ecb3
	cp	(UI_ScreenStage:16), 0x00	; F7EC7B  cp (0x207e),0x00
	jr	nz, Paint_TrackClear_Skip2	; F7EC80  jr NZ,0xf7ecbf
	call	T_TrackClear_ResetSelectionOnEntry	; F7EC82  call 0xf428d0
	calr	LCD_ScreenRedraw_Begin	; F7EC86  calr 0xf7e2d9
	ld	(LCD_CurrentLayer:16), 2	; F7EC89  ld (0x2540),0x02
	ld	xiy, DL_TrackClearPressTheUpDown	; F7EC8E  ld XIY,0x00f39f8a
	ld	xix, Data_F3A0A5	; F7EC93  ld XIX,0x00f3a0a5
	call	T_DisplayList_Run	; F7EC98  call 0xf417f0
	call	TrackGrid_DrawPartLabels	; F7EC9C  call 0xf7e354
	ld	(LCD_CurrentLayer:16), 0	; F7ECA0  ld (0x2540),0x00
	ld	xiy, DL_F3934C	; F7ECA5  ld XIY,0x00f3934c
	ld	xix, DL_F394E3	; F7ECAA  ld XIX,0x00f394e3
	call	T_DisplayList_Run	; F7ECAF  call 0xf417f0
Paint_TrackClear_Skip:
	ld	hl, (3518:16)	; F7ECB3  ld HL,(0x0dbe)
	calr	TrackClear_DrawTrackSelection	; F7ECB7  calr 0xf7e39f
	calr	LCD_ScreenRedraw_End	; F7ECBA  calr 0xf7e2e7
	jr	Paint_TrackClear_Return	; F7ECBD  jr T,0xf7ecf9
Paint_TrackClear_Skip2:
	calr	LCD_ScreenRedraw_Begin	; F7ECBF  calr 0xf7e2d9
	ld	(LCD_CurrentLayer:16), 2	; F7ECC2  ld (0x2540),0x02
	ld	xiy, DL_TrackClearAttenti0nUsing	; F7ECC7  ld XIY,0x00f39c35
	ld	xix, DL_EditSeqN0teEditS0ngClear	; F7ECCC  ld XIX,0x00f39d3e
	call	T_DisplayList_Run	; F7ECD1  call 0xf417f0
	call	TrackGrid_DrawPartLabels	; F7ECD5  call 0xf7e354
	ld	(LCD_CurrentLayer:16), 0	; F7ECD9  ld (0x2540),0x00
	ld	xiy, DL_F3934C	; F7ECDE  ld XIY,0x00f3934c
	ld	xix, DL_F394E3	; F7ECE3  ld XIX,0x00f394e3
	call	T_DisplayList_Run	; F7ECE8  call 0xf417f0
	ld	hl, (3518:16)	; F7ECEC  ld HL,(0x0dbe)
	call	TrackClear_DrawTrackSelection	; F7ECF0  call 0xf7e39f
	jr	Paint_TrackClear_Join	; F7ECF4  jr T,0xf7ecf6
Paint_TrackClear_Join:
	calr	LCD_ScreenRedraw_End	; F7ECF6  calr 0xf7e2e7
Paint_TrackClear_Return:
	ret	; F7ECF9  ret

; ---------------------------------------------------------------------
; ScreenLeaveBody_TrackClear -- the whole body of the TrackClear screen's
;                               Leave method
;
; Reached by: the +4 method stub of screen object 0xF43070, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: calr from prom_b 0xF7D066
; Evidence: the whole body of screen object 0xF43070's +4 method. prom_a's
;           PanelScreen_VtableTable names that object, and its readers take
;           +0 Enter, +4 Leave, +8 Button; the stub at 0xF7D066 is `call
;           0xF7ECFA` then `ret` and nothing else calls this address. The
;           screen's own name is round 7's, from its title text.
; ---------------------------------------------------------------------
ScreenLeaveBody_TrackClear:
	call	T_TrackClear_OnLeave	; F7ECFA  call 0xf428d4
	ret	; F7ECFE  ret

; ---------------------------------------------------------------------
; SoftKeyCol1_TrackClear_StageZero -- the 1st of the eight SOFT KEYS in the row
;           under the LCD, on the TrackClear_StageZero screen
; Reached by: SW33 "SOFT KEY col 1 lower" (matrix segment 4 bit 0, wire 0xC4)
;           -> PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record
;           0xF8B6C3 {class 0xA9, code 0x00} -> delivered code 0x80; SW34
;           "SOFT KEY col 1 upper" (matrix segment 4 bit 1, wire 0xC4) ->
;           PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record 0xF8B6C7
;           {class 0xA9, code 0x00} -> delivered code 0x00. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x00 of ButtonTable_TrackClear_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Note:     Also registered at slot 0x11, the VARIANT-1 already-held rewrite
;           of base code 0x00 (`add (XIX-1),0x11` at prom_a
;           0xF8AE7E/0xF8AEF1), so on the SX-WSA1 one routine serves the press
;           and the auto-repeat; on the SX-WSA1R that slot is never delivered.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW41 SOFT KEY col
;           5 lower (segment 5 bit 0, fitted); SW42 SOFT KEY col 5 upper
;           (segment 5 bit 1, fitted); SW49 [no legend: matrix position
;           outside every diode list] (segment 6 bit 0, NOT fitted on this
;           panel); SW50 [no legend: matrix position outside every diode list]
;           (segment 6 bit 1, NOT fitted on this panel). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW33/SW34 are the two switches of its 1st column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW33, so "col 1" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol1_TrackClear_StageZero:
	bit	7, w	; F7ECFF  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackClear_Skip	; F7ED02  jr NZ,0xf7ed0b
	ld	(13826:16), 0	; F7ED04  ld (0x3602),0x00
	jr	ScreenLeaveBody_TrackClear_Join	; F7ED09  jr T,0xf7ed13
ScreenLeaveBody_TrackClear_Skip:
	add	c, 8	; F7ED0B  add C,0x08
	ld	(13826:16), 8	; F7ED0E  ld (0x3602),0x08
ScreenLeaveBody_TrackClear_Join:
	call	T_SeqTrackKey_Press	; F7ED13  call 0xf40cc4
	ret	; F7ED17  ret

; ---------------------------------------------------------------------
; SoftKeyCol2_TrackClear_StageZero -- the 2nd of the eight SOFT KEYS in the row
;           under the LCD, on the TrackClear_StageZero screen
; Reached by: SW35 "SOFT KEY col 2 lower" (matrix segment 4 bit 2, wire 0xC4)
;           -> PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record
;           0xF8B6CB {class 0xA9, code 0x01} -> delivered code 0x81; SW36
;           "SOFT KEY col 2 upper" (matrix segment 4 bit 3, wire 0xC4) ->
;           PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record 0xF8B6CF
;           {class 0xA9, code 0x01} -> delivered code 0x01. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x01 of ButtonTable_TrackClear_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Note:     Also registered at slot 0x12, the VARIANT-1 already-held rewrite
;           of base code 0x01 (`add (XIX-1),0x11` at prom_a
;           0xF8AE7E/0xF8AEF1), so on the SX-WSA1 one routine serves the press
;           and the auto-repeat; on the SX-WSA1R that slot is never delivered.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW43 SOFT KEY col
;           6 lower (segment 5 bit 2, fitted); SW44 SOFT KEY col 6 upper
;           (segment 5 bit 3, fitted); SW51 [no legend: matrix position
;           outside every diode list] (segment 6 bit 2, NOT fitted on this
;           panel); SW52 [no legend: matrix position outside every diode list]
;           (segment 6 bit 3, NOT fitted on this panel). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW35/SW36 are the two switches of its 2nd column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW35, so "col 2" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol2_TrackClear_StageZero:
	bit	7, w	; F7ED18  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackClear_Skip2	; F7ED1B  jr NZ,0xf7ed24
	ld	(13826:16), 1	; F7ED1D  ld (0x3602),0x01
	jr	ScreenLeaveBody_TrackClear_Join2	; F7ED22  jr T,0xf7ed2c
ScreenLeaveBody_TrackClear_Skip2:
	add	c, 8	; F7ED24  add C,0x08
	ld	(13826:16), 9	; F7ED27  ld (0x3602),0x09
ScreenLeaveBody_TrackClear_Join2:
	call	T_SeqTrackKey_Press	; F7ED2C  call 0xf40cc4
	ret	; F7ED30  ret

; ---------------------------------------------------------------------
; SoftKeyCol3_TrackClear_StageZero -- the 3rd of the eight SOFT KEYS in the row
;           under the LCD, on the TrackClear_StageZero screen
; Reached by: SW37 "SOFT KEY col 3 lower" (matrix segment 4 bit 4, wire 0xC4)
;           -> PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record
;           0xF8B6D3 {class 0xA9, code 0x02} -> delivered code 0x82; SW38
;           "SOFT KEY col 3 upper" (matrix segment 4 bit 5, wire 0xC4) ->
;           PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record 0xF8B6D7
;           {class 0xA9, code 0x02} -> delivered code 0x02. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x02 of ButtonTable_TrackClear_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Note:     Also registered at slot 0x13, the VARIANT-1 already-held rewrite
;           of base code 0x02 (`add (XIX-1),0x11` at prom_a
;           0xF8AE7E/0xF8AEF1), so on the SX-WSA1 one routine serves the press
;           and the auto-repeat; on the SX-WSA1R that slot is never delivered.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW45 SOFT KEY col
;           7 lower (segment 5 bit 4, fitted); SW46 SOFT KEY col 7 upper
;           (segment 5 bit 5, fitted); SW53 [no legend: matrix position
;           outside every diode list] (segment 6 bit 4, NOT fitted on this
;           panel); SW54 [no legend: matrix position outside every diode list]
;           (segment 6 bit 5, NOT fitted on this panel). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW37/SW38 are the two switches of its 3rd column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW37, so "col 3" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol3_TrackClear_StageZero:
	bit	7, w	; F7ED31  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackClear_Skip3	; F7ED34  jr NZ,0xf7ed3d
	ld	(13826:16), 2	; F7ED36  ld (0x3602),0x02
	jr	ScreenLeaveBody_TrackClear_Join3	; F7ED3B  jr T,0xf7ed45
ScreenLeaveBody_TrackClear_Skip3:
	add	c, 8	; F7ED3D  add C,0x08
	ld	(13826:16), 10	; F7ED40  ld (0x3602),0x0a
ScreenLeaveBody_TrackClear_Join3:
	call	T_SeqTrackKey_Press	; F7ED45  call 0xf40cc4
	ret	; F7ED49  ret

; ---------------------------------------------------------------------
; SoftKeyCol4_TrackClear_StageZero -- the 4th of the eight SOFT KEYS in the row
;           under the LCD, on the TrackClear_StageZero screen
; Reached by: SW39 "SOFT KEY col 4 lower" (matrix segment 4 bit 6, wire 0xC4)
;           -> PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record
;           0xF8B6DB {class 0xA9, code 0x03} -> delivered code 0x83; SW40
;           "SOFT KEY col 4 upper" (matrix segment 4 bit 7, wire 0xC4) ->
;           PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record 0xF8B6DF
;           {class 0xA9, code 0x03} -> delivered code 0x03. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x03 of ButtonTable_TrackClear_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Note:     Also registered at slot 0x14, the VARIANT-1 already-held rewrite
;           of base code 0x03 (`add (XIX-1),0x11` at prom_a
;           0xF8AE7E/0xF8AEF1), so on the SX-WSA1 one routine serves the press
;           and the auto-repeat; on the SX-WSA1R that slot is never delivered.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW47 SOFT KEY col
;           8 lower (segment 5 bit 6, fitted); SW48 SOFT KEY col 8 upper
;           (segment 5 bit 7, fitted); SW55 [no legend: matrix position
;           outside every diode list] (segment 6 bit 6, NOT fitted on this
;           panel); SW56 [no legend: matrix position outside every diode list]
;           (segment 6 bit 7, NOT fitted on this panel). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW39/SW40 are the two switches of its 4th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW39, so "col 4" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol4_TrackClear_StageZero:
	bit	7, w	; F7ED4A  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackClear_Skip4	; F7ED4D  jr NZ,0xf7ed56
	ld	(13826:16), 3	; F7ED4F  ld (0x3602),0x03
	jr	ScreenLeaveBody_TrackClear_Join4	; F7ED54  jr T,0xf7ed5e
ScreenLeaveBody_TrackClear_Skip4:
	add	c, 8	; F7ED56  add C,0x08
	ld	(13826:16), 11	; F7ED59  ld (0x3602),0x0b
ScreenLeaveBody_TrackClear_Join4:
	call	T_SeqTrackKey_Press	; F7ED5E  call 0xf40cc4
	ret	; F7ED62  ret

; ---------------------------------------------------------------------
; SoftKeyCol5_TrackClear_StageZero -- the 5th of the eight SOFT KEYS in the row
;           under the LCD, on the TrackClear_StageZero screen
; Reached by: SW41 "SOFT KEY col 5 lower" (matrix segment 5 bit 0, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6E4 {class 0xA9, code 0x04} -> delivered code 0x84; SW42
;           "SOFT KEY col 5 upper" (matrix segment 5 bit 1, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6E8
;           {class 0xA9, code 0x04} -> delivered code 0x04. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x04 of ButtonTable_TrackClear_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Note:     Also registered at slot 0x15, the VARIANT-1 already-held rewrite
;           of base code 0x04 (`add (XIX-1),0x11` at prom_a
;           0xF8AE7E/0xF8AEF1), so on the SX-WSA1 one routine serves the press
;           and the auto-repeat; on the SX-WSA1R that slot is never delivered.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW25 LCD RIGHT 1
;           (top) (segment 3 bit 0, fitted); SW26 LCD RIGHT 2 (segment 3 bit
;           1, fitted); SW33 SOFT KEY col 1 lower (segment 4 bit 0, fitted);
;           SW34 SOFT KEY col 1 upper (segment 4 bit 1, fitted). The model
;           strap is the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW41/SW42 are the two switches of its 5th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW41, so "col 5" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol5_TrackClear_StageZero:
	bit	7, w	; F7ED63  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackClear_Skip5	; F7ED66  jr NZ,0xf7ed6f
	ld	(13826:16), 4	; F7ED68  ld (0x3602),0x04
	jr	ScreenLeaveBody_TrackClear_Join5	; F7ED6D  jr T,0xf7ed77
ScreenLeaveBody_TrackClear_Skip5:
	add	c, 8	; F7ED6F  add C,0x08
	ld	(13826:16), 12	; F7ED72  ld (0x3602),0x0c
ScreenLeaveBody_TrackClear_Join5:
	call	T_SeqTrackKey_Press	; F7ED77  call 0xf40cc4
	ret	; F7ED7B  ret

; ---------------------------------------------------------------------
; SoftKeyCol6_TrackClear_StageZero -- the 6th of the eight SOFT KEYS in the row
;           under the LCD, on the TrackClear_StageZero screen
; Reached by: SW43 "SOFT KEY col 6 lower" (matrix segment 5 bit 2, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6EC {class 0xA9, code 0x05} -> delivered code 0x85; SW44
;           "SOFT KEY col 6 upper" (matrix segment 5 bit 3, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6F0
;           {class 0xA9, code 0x05} -> delivered code 0x05. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x05 of ButtonTable_TrackClear_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Note:     Also registered at slot 0x16, the VARIANT-1 already-held rewrite
;           of base code 0x05 (`add (XIX-1),0x11` at prom_a
;           0xF8AE7E/0xF8AEF1), so on the SX-WSA1 one routine serves the press
;           and the auto-repeat; on the SX-WSA1R that slot is never delivered.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW27 LCD RIGHT 3
;           (segment 3 bit 2, fitted); SW28 LCD RIGHT 4 (segment 3 bit 3,
;           fitted); SW35 SOFT KEY col 2 lower (segment 4 bit 2, fitted); SW36
;           SOFT KEY col 2 upper (segment 4 bit 3, fitted). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW43/SW44 are the two switches of its 6th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW43, so "col 6" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol6_TrackClear_StageZero:
	bit	7, w	; F7ED7C  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackClear_Skip6	; F7ED7F  jr NZ,0xf7ed88
	ld	(13826:16), 5	; F7ED81  ld (0x3602),0x05
	jr	ScreenLeaveBody_TrackClear_Join6	; F7ED86  jr T,0xf7ed90
ScreenLeaveBody_TrackClear_Skip6:
	add	c, 8	; F7ED88  add C,0x08
	ld	(13826:16), 13	; F7ED8B  ld (0x3602),0x0d
ScreenLeaveBody_TrackClear_Join6:
	call	T_SeqTrackKey_Press	; F7ED90  call 0xf40cc4
	ret	; F7ED94  ret

; ---------------------------------------------------------------------
; SoftKeyCol7_TrackClear_StageZero -- the 7th of the eight SOFT KEYS in the row
;           under the LCD, on the TrackClear_StageZero screen
; Reached by: SW45 "SOFT KEY col 7 lower" (matrix segment 5 bit 4, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6F4 {class 0xA9, code 0x06} -> delivered code 0x86; SW46
;           "SOFT KEY col 7 upper" (matrix segment 5 bit 5, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6F8
;           {class 0xA9, code 0x06} -> delivered code 0x06. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x06 of ButtonTable_TrackClear_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Note:     Also registered at slot 0x17, the VARIANT-1 already-held rewrite
;           of base code 0x06 (`add (XIX-1),0x11` at prom_a
;           0xF8AE7E/0xF8AEF1), so on the SX-WSA1 one routine serves the press
;           and the auto-repeat; on the SX-WSA1R that slot is never delivered.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW29 LCD RIGHT 5
;           (bottom) (segment 3 bit 4, fitted); SW30 -1 (segment 3 bit 5,
;           fitted); SW37 SOFT KEY col 3 lower (segment 4 bit 4, fitted); SW38
;           SOFT KEY col 3 upper (segment 4 bit 5, fitted). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW45/SW46 are the two switches of its 7th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW45, so "col 7" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol7_TrackClear_StageZero:
	bit	7, w	; F7ED95  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackClear_Skip7	; F7ED98  jr NZ,0xf7eda1
	ld	(13826:16), 6	; F7ED9A  ld (0x3602),0x06
	jr	ScreenLeaveBody_TrackClear_Join7	; F7ED9F  jr T,0xf7eda9
ScreenLeaveBody_TrackClear_Skip7:
	add	c, 8	; F7EDA1  add C,0x08
	ld	(13826:16), 14	; F7EDA4  ld (0x3602),0x0e
ScreenLeaveBody_TrackClear_Join7:
	call	T_SeqTrackKey_Press	; F7EDA9  call 0xf40cc4
	ret	; F7EDAD  ret

; ---------------------------------------------------------------------
; SoftKeyCol8_TrackClear_StageZero -- the 8th of the eight SOFT KEYS in the row
;           under the LCD, on the TrackClear_StageZero screen
; Reached by: SW47 "SOFT KEY col 8 lower" (matrix segment 5 bit 6, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6FC {class 0xA9, code 0x07} -> delivered code 0x87; SW48
;           "SOFT KEY col 8 upper" (matrix segment 5 bit 7, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B700
;           {class 0xA9, code 0x07} -> delivered code 0x07. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x07 of ButtonTable_TrackClear_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Note:     Also registered at slot 0x18, the VARIANT-1 already-held rewrite
;           of base code 0x07 (`add (XIX-1),0x11` at prom_a
;           0xF8AE7E/0xF8AEF1), so on the SX-WSA1 one routine serves the press
;           and the auto-repeat; on the SX-WSA1R that slot is never delivered.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW31 +1 (segment
;           3 bit 6, fitted); SW32 EXIT (segment 3 bit 7, fitted); SW39 SOFT
;           KEY col 4 lower (segment 4 bit 6, fitted); SW40 SOFT KEY col 4
;           upper (segment 4 bit 7, fitted). The model strap is the RAM byte
;           (0x00C4), latched from PB bit 0 by prom_a Variant_SetFromPB0 at
;           0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW47/SW48 are the two switches of its 8th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW47, so "col 8" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol8_TrackClear_StageZero:
	bit	7, w	; F7EDAE  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackClear_Skip8	; F7EDB1  jr NZ,0xf7edba
	ld	(13826:16), 7	; F7EDB3  ld (0x3602),0x07
	jr	ScreenLeaveBody_TrackClear_Join8	; F7EDB8  jr T,0xf7edc2
ScreenLeaveBody_TrackClear_Skip8:
	add	c, 8	; F7EDBA  add C,0x08
	ld	(13826:16), 15	; F7EDBD  ld (0x3602),0x0f
ScreenLeaveBody_TrackClear_Join8:
	call	T_SeqTrackKey_Press	; F7EDC2  call 0xf40cc4
	ret	; F7EDC6  ret
ButtonTable_TrackClear_StageZero_Nop8:
	ret	; F7EDC7  ret   <- button table 0xF7D458 entry 8 (TRACK CLEAR)

; ---------------------------------------------------------------------
; LcdKeyRow2_TrackClear_StageZero -- row 2 of the five key pairs flanking the
;           LCD, on the TrackClear_StageZero screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_TrackClear_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_TrackClear_StageZero:
	bit	7, w	; F7EDC8  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackClear_Return	; F7EDCB  jr NZ,0xf7edd1
	call	T_TrackClear_LcdKeyRow2	; F7EDCD  call 0xf428dc
ScreenLeaveBody_TrackClear_Return:
	ret	; F7EDD1  ret
ButtonTable_TrackClear_StageZero_Nop10:
	ret	; F7EDD2  ret   <- button table 0xF7D458 entry 10 (TRACK CLEAR) and 4 more slot(s)

; ---------------------------------------------------------------------
; ExitKey_TrackClear_StageZero -- the EXIT key on the TrackClear_StageZero
;           screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_TrackClear_StageZero:
	bit	7, w	; F7EDD3  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackClear_Return2	; F7EDD6  jr NZ,0xf7ede0
	ldw	(UI_Request:16), 32794	; F7EDD8  ld (0x2070),0x801a
	jr	ScreenLeaveBody_TrackClear_Return2	; F7EDDE  jr T,0xf7ede0
ScreenLeaveBody_TrackClear_Return2:
	ret	; F7EDE0  ret
ButtonTable_TrackClear_StageZero_Nop16:
	ret	; F7EDE1  ret   <- button table 0xF7D458 entry 16 (TRACK CLEAR) and 7 more slot(s)
ButtonTable_TrackClear_StageNonZero_Nop0:
	ret	; F7EDE2  ret   <- button table 0xF7D4D8 entry 0 (TRACK CLEAR) and 8 more slot(s)

; ---------------------------------------------------------------------
; LcdKeyRow2_TrackClear_StageNonZero -- row 2 of the five key pairs flanking
;           the LCD, on the TrackClear_StageNonZero screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_TrackClear_StageNonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_TrackClear_StageNonZero:
	bit	7, w	; F7EDE3  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackClear_Return3	; F7EDE6  jr NZ,0xf7edf1
	and	(UI_RequestBits:16), 0x6f	; F7EDE8  and (0x2075),0x6f
	call	T_TrackClear_LcdKeyRow2	; F7EDED  call 0xf428dc
ScreenLeaveBody_TrackClear_Return3:
	ret	; F7EDF1  ret

; ---------------------------------------------------------------------
; LcdKeyRow3_TrackClear_StageNonZero -- row 3 of the five key pairs flanking
;           the LCD, on the TrackClear_StageNonZero screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_TrackClear_StageNonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_TrackClear_StageNonZero:
	bit	7, w	; F7EDF2  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackClear_Return4	; F7EDF5  jr NZ,0xf7edfb
	call	T_TrackClear_ReturnToStageZero	; F7EDF7  call 0xf428d8
ScreenLeaveBody_TrackClear_Return4:
	ret	; F7EDFB  ret
ButtonTable_TrackClear_StageNonZero_Nop11:
	ret	; F7EDFC  ret   <- button table 0xF7D4D8 entry 11 (TRACK CLEAR) and 3 more slot(s)

; ---------------------------------------------------------------------
; ExitKey_TrackClear_StageNonZero -- the EXIT key on the TrackClear_StageNonZero
;           screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_TrackClear_StageNonZero:
	bit	7, w	; F7EDFD  bit 0x07,W
	jr	nz, ScreenLeaveBody_TrackClear_Return5	; F7EE00  jr NZ,0xf7ee06
	call	T_TrackClear_ReturnToStageZero	; F7EE02  call 0xf428d8
ScreenLeaveBody_TrackClear_Return5:
	ret	; F7EE06  ret
ButtonTable_TrackClear_StageNonZero_Nop16:
	ret	; F7EE07  ret   <- button table 0xF7D4D8 entry 16 (TRACK CLEAR) and 15 more slot(s)

; ---------------------------------------------------------------------
; Paint_TrackMerge -- paints the panel screen whose own title text reads
;                     "TRACK MERGE"
;
; Reached by: the +0 method stub of screen object 0xF430A0, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D0BC
; Evidence: the routine loads XIY = 0xF3A47F and calls the display-list
;           interpreter; the leading run of op-0x1C records in that list
;           spells "TRACK MERGE", and the name is that text CamelCased, with
;           the ROM's own spelling kept (zeros for O's included). The rule
;           is round 7's, calibrated on seven screens prom_a had named
;           independently: notes/prom_b_screens_round8.py --calibrate.
; ---------------------------------------------------------------------
Paint_TrackMerge:
	call	T_CallbackQueue_ResetAndRestartTask2	; F7EE08  call 0xf42e80
	cp	(UI_ScreenStage:16), 0x00	; F7EE0C  cp (0x207e),0x00
	jr	nz, Paint_TrackMerge_Skip	; F7EE11  jr NZ,0xf7ee36
	or	(UI_RequestBits:16), 0x09	; F7EE13  or (0x2075),0x09
	ldw	(PanelDial_DownButton:16), 1156	; F7EE18  ld (0x209b),0x0484  <- arms prom_a PanelButton_Accept's substitution for panel button code 0x0D (0xF86615); see the 0xF7D2D8 banner
	ldw	(9830:16), 65535	; F7EE1E  ld (0x2666),0xffff
	ldw	(9834:16), 65535	; F7EE24  ld (0x266a),0xffff
	call	T_TrackMerge_InitFields	; F7EE2A  call 0xf42938
	ld	a, (3514:16)	; F7EE2E  ld A,(0x0dba)
	ld	(DisplayListB_Stage+3:16), a	; F7EE32  ld (0x12f9),A
Paint_TrackMerge_Skip:
	calr	LCD_ScreenRedraw_Begin	; F7EE36  calr 0xf7e2d9
	ld	(LCD_CurrentLayer:16), 0	; F7EE39  ld (0x2540),0x00
	ld	xiy, DL_TrackMergeOkTrackTrackTrack	; F7EE3E  ld XIY,0x00f3a47f
	ld	xix, DL_Track	; F7EE43  ld XIX,0x00f3a526
	call	T_DisplayList_Run	; F7EE48  call 0xf417f0
	cp	(UI_ScreenStage:16), 0x00	; F7EE4C  cp (0x207e),0x00
	jr	nz, Paint_TrackMerge_Skip2	; F7EE51  jr NZ,0xf7ee63
	ld	xiy, DL_Track	; F7EE53  ld XIY,0x00f3a526
	ld	xix, DL_F3A561	; F7EE58  ld XIX,0x00f3a561
	call	T_DisplayList_Run	; F7EE5D  call 0xf417f0
	jr	Paint_TrackMerge_Join	; F7EE61  jr T,0xf7ee7f
Paint_TrackMerge_Skip2:
	ld	xiy, Paint_TrackMerge_DL	; F7EE63  ld XIY,0x00f3a5aa
	ld	xix, DL_MeasureDeleteTrackFirstMeasure	; F7EE68  ld XIX,0x00f3a5e9
	call	T_DisplayList_Run	; F7EE6D  call 0xf417f0
	ld	xiy, DL_AreYouSure	; F7EE71  ld XIY,0x00f3a461
	ld	xix, DL_TrackMergeOkTrackTrackTrack	; F7EE76  ld XIX,0x00f3a47f
	call	T_DisplayList_Run	; F7EE7B  call 0xf417f0
Paint_TrackMerge_Join:
	ld	(LCD_CurrentLayer:16), 0	; F7EE7F  ld (0x2540),0x00
	ld	xiy, DL_F3A561	; F7EE84  ld XIY,0x00f3a561
	ld	xix, DLTable_F3A58A	; F7EE89  ld XIX,0x00f3a58a
	call	T_DisplayListB_Run	; F7EE8E  call 0xf417f4
	calr	LCD_ScreenRedraw_End	; F7EE92  calr 0xf7e2e7
	ret	; F7EE95  ret

; ---------------------------------------------------------------------
; ScreenLeaveBody_TrackMerge -- the whole body of the TrackMerge screen's
;                               Leave method
;
; Reached by: the +4 method stub of screen object 0xF430A0, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D0C1
; Evidence: the whole body of screen object 0xF430A0's +4 method. prom_a's
;           PanelScreen_VtableTable names that object, and its readers take
;           +0 Enter, +4 Leave, +8 Button; the stub at 0xF7D0C1 is `call
;           0xF7EE96` then `ret` and nothing else calls this address. The
;           screen's own name is round 7's, from its title text.
; ---------------------------------------------------------------------
ScreenLeaveBody_TrackMerge:
	call	T_TrackMerge_OnLeave	; F7EE96  call 0xf4293c
	ret	; F7EE9A  ret
ButtonTable_TrackMerge_StageZero_Nop0:
	ret	; F7EE9B  ret   <- button table 0xF7D6D8 entry 0 (TRACK MERGE)
ButtonTable_TrackMerge_StageZero_Nop1:
	ret	; F7EE9C  ret   <- button table 0xF7D6D8 entry 1 (TRACK MERGE)
ButtonTable_TrackMerge_StageZero_Nop2:
	ret	; F7EE9D  ret   <- button table 0xF7D6D8 entry 2 (TRACK MERGE)
ButtonTable_TrackMerge_StageZero_Nop3:
	ret	; F7EE9E  ret   <- button table 0xF7D6D8 entry 3 (TRACK MERGE)

; ---------------------------------------------------------------------
; SoftKeyCol5_TrackMerge_StageZero -- the 5th of the eight SOFT KEYS in the row
;           under the LCD, on the TrackMerge_StageZero screen
; Reached by: SW41 "SOFT KEY col 5 lower" (matrix segment 5 bit 0, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6E4 {class 0xA9, code 0x04} -> delivered code 0x84; SW42
;           "SOFT KEY col 5 upper" (matrix segment 5 bit 1, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6E8
;           {class 0xA9, code 0x04} -> delivered code 0x04. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x04 of ButtonTable_TrackMerge_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW25 LCD RIGHT 1
;           (top) (segment 3 bit 0, fitted); SW26 LCD RIGHT 2 (segment 3 bit
;           1, fitted); SW33 SOFT KEY col 1 lower (segment 4 bit 0, fitted);
;           SW34 SOFT KEY col 1 upper (segment 4 bit 1, fitted). The model
;           strap is the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW41/SW42 are the two switches of its 5th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW41, so "col 5" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol5_TrackMerge_StageZero:
	or	(UI_RequestBits:16), 0x08	; F7EE9F  or (0x2075),0x08
	bit	7, w	; F7EEA4  bit 0x07,W
	jr	z, ScreenLeaveBody_TrackMerge_Skip	; F7EEA7  jr Z,0xf7eeaf
	call	T_TrackMerge_StageZero_SoftKeyCol5	; F7EEA9  call 0xf42950
	jr	ScreenLeaveBody_TrackMerge_Join	; F7EEAD  jr T,0xf7eeb3
ScreenLeaveBody_TrackMerge_Skip:
	call	T_TrackMerge_StepSelectedFieldUp	; F7EEAF  call 0xf4294c
ScreenLeaveBody_TrackMerge_Join:
	ld	(LCD_CurrentLayer:16), 0	; F7EEB3  ld (0x2540),0x00
	calr	ButtonTable_SequencerMedley_Nop	; F7EEB8  calr 0xf7e2d8
	ld	xiy, DL_F3A561	; F7EEBB  ld XIY,0x00f3a561
	ld	xix, DL_F3A561 + 0x1E	; F7EEC0  ld XIX,0x00f3a57f
	call	T_DisplayListB_Run	; F7EEC5  call 0xf417f4
	ret	; F7EEC9  ret
ButtonTable_TrackMerge_StageZero_Nop5:
	ret	; F7EECA  ret   <- button table 0xF7D6D8 entry 5 (TRACK MERGE)
ButtonTable_TrackMerge_StageZero_Nop6:
	ret	; F7EECB  ret   <- button table 0xF7D6D8 entry 6 (TRACK MERGE)
ButtonTable_TrackMerge_StageZero_Nop7:
	ret	; F7EECC  ret   <- button table 0xF7D6D8 entry 7 (TRACK MERGE) and 1 more slot(s)

; ---------------------------------------------------------------------
; LcdKeyRow2_TrackMerge_StageZero -- row 2 of the five key pairs flanking the
;           LCD, on the TrackMerge_StageZero screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_TrackMerge_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_TrackMerge_StageZero:
	bit	7, w	; F7EECD  bit 0x07,W
	jr	z, ScreenLeaveBody_TrackMerge_Skip2	; F7EED0  jr Z,0xf7eeea
	cp	(0x0dba:16), 0x01	; F7EED2  cp (0x0dba),0x01
	jr	z, ScreenLeaveBody_TrackMerge_Return	; F7EED7  jr Z,0xf7eeee
	call	T_TrackMerge_SelectField1	; F7EED9  call 0xf42940
	ld	a, (3514:16)	; F7EEDD  ld A,(0x0dba)
	ld	(DisplayListB_Stage+3:16), a	; F7EEE1  ld (0x12f9),A
	calr	TrackMerge_DrawFieldHighlight	; F7EEE5  calr 0xf7eeef
	jr	ScreenLeaveBody_TrackMerge_Return	; F7EEE8  jr T,0xf7eeee
ScreenLeaveBody_TrackMerge_Skip2:
	call	T_TrackMerge_LcdKeyRow2	; F7EEEA  call 0xf42958
ScreenLeaveBody_TrackMerge_Return:
	ret	; F7EEEE  ret

; Evidence: reached from calr from prom_b 0xF7EEE5; calr from prom_b
;           0xF7EF1A, and from nothing else the scans see.
; TrackMerge_DrawFieldHighlight: Layer 1: clears the field area (DL_F39551, op 0x0E -> LCD_Svc_0E_ClearColumns) and
;   fills (svc 0x05) box DLTable_F3A58A[(0x12F9) & 3] of the TRACK MERGE field just selected. Basis: callers + body --
;   each LcdKeyRow2..4_TrackMerge_StageZero handler calls T_TrackMerge_SelectFieldN, copies the field (0x0DBA) to
;   (0x12F9), then this. (notes/naming-pilot-2026-10-06/proposals_wave2_d.json)
TrackMerge_DrawFieldHighlight:
	ld	(LCD_CurrentLayer:16), 1	; F7EEEF  ld (0x2540),0x01
	call	LCD_ClearCurrentLayer	; F7EEF4  call 0xf7e2ed
	ld	xiy, DL_F3A561 + 0x1E	; F7EEF8  ld XIY,0x00f3a57f
	call	T_DLB_Handler_Array8	; F7EEFD  call 0xf4181c
	ret	; F7EF01  ret

; ---------------------------------------------------------------------
; LcdKeyRow3_TrackMerge_StageZero -- row 3 of the five key pairs flanking the
;           LCD, on the TrackMerge_StageZero screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_TrackMerge_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_TrackMerge_StageZero:
	bit	7, w	; F7EF02  bit 0x07,W
	jr	nz, LcdKeyRow3_TrackMerge_StageZero_Return	; F7EF05  jr NZ,0xf7ef1d
	cp	(0x0dba:16), 0x03	; F7EF07  cp (0x0dba),0x03
	jr	z, LcdKeyRow3_TrackMerge_StageZero_Return	; F7EF0C  jr Z,0xf7ef1d
	call	T_TrackMerge_SelectField3	; F7EF0E  call 0xf42948
	ld	a, (3514:16)	; F7EF12  ld A,(0x0dba)
	ld	(DisplayListB_Stage+3:16), a	; F7EF16  ld (0x12f9),A
	calr	TrackMerge_DrawFieldHighlight	; F7EF1A  calr 0xf7eeef
LcdKeyRow3_TrackMerge_StageZero_Return:
	ret	; F7EF1D  ret

; ---------------------------------------------------------------------
; LcdKeyRow4_TrackMerge_StageZero -- row 4 of the five key pairs flanking the
;           LCD, on the TrackMerge_StageZero screen
; Reached by: SW28 "LCD RIGHT 4" (matrix segment 3 bit 3, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AE
;           {class 0xA9, code 0x0B} -> delivered code 0x0B; SW76 "LCD LEFT 4"
;           (matrix segment 9 bit 3, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72B
;           {class 0xA9, code 0x0B} -> delivered code 0x8B. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0B of ButtonTable_TrackMerge_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW76 LCD LEFT 4
;           (segment 9 bit 3, fitted); SW84 [no legend: matrix position
;           outside every diode list] (segment 10 bit 3, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW28 is row 4 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow4_TrackMerge_StageZero:
	bit	7, w	; F7EF1E  bit 0x07,W
	jr	z, LcdKeyRow4_TrackMerge_StageZero_Return2	; F7EF21  jr Z,0xf7ef39
	cp	(0x0dba:16), 0x02	; F7EF23  cp (0x0dba),0x02
	jr	z, LcdKeyRow4_TrackMerge_StageZero_Return2	; F7EF28  jr Z,0xf7ef39
	call	T_TrackMerge_SelectField2	; F7EF2A  call 0xf42944
	ld	a, (3514:16)	; F7EF2E  ld A,(0x0dba)
	ld	(DisplayListB_Stage+3:16), a	; F7EF32  ld (0x12f9),A
	calr	TrackMerge_DrawFieldHighlight	; F7EF36  calr 0xf7eeef
LcdKeyRow4_TrackMerge_StageZero_Return2:
	ret	; F7EF39  ret
ButtonTable_TrackMerge_StageZero_Nop12:
	ret	; F7EF3A  ret   <- button table 0xF7D6D8 entry 12 (TRACK MERGE)
ButtonTable_TrackMerge_StageZero_Nop13:
	ret	; F7EF3B  ret   <- button table 0xF7D6D8 entry 13 (TRACK MERGE)
ButtonTable_TrackMerge_StageZero_Nop14:
	ret	; F7EF3C  ret   <- button table 0xF7D6D8 entry 14 (TRACK MERGE)

; ---------------------------------------------------------------------
; ExitKey_TrackMerge_StageZero -- the EXIT key on the TrackMerge_StageZero
;           screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_TrackMerge_StageZero:
	bit	7, w	; F7EF3D  bit 0x07,W
	jr	z, ExitKey_TrackMerge_StageZero_Skip	; F7EF40  jr Z,0xf7ef44
	jr	ExitKey_TrackMerge_StageZero_Return3	; F7EF42  jr T,0xf7ef4a
ExitKey_TrackMerge_StageZero_Skip:
	ldw	(UI_Request:16), 32794	; F7EF44  ld (0x2070),0x801a
ExitKey_TrackMerge_StageZero_Return3:
	ret	; F7EF4A  ret
ButtonTable_TrackMerge_StageZero_Nop16:
	ret	; F7EF4B  ret   <- button table 0xF7D6D8 entry 16 (TRACK MERGE) and 15 more slot(s)
ButtonTable_TrackMerge_StageNonZero_Nop0:
	ret	; F7EF4C  ret   <- button table 0xF7D758 entry 0 (TRACK MERGE)
ButtonTable_TrackMerge_StageNonZero_Nop1:
	ret	; F7EF4D  ret   <- button table 0xF7D758 entry 1 (TRACK MERGE)
ButtonTable_TrackMerge_StageNonZero_Nop2:
	ret	; F7EF4E  ret   <- button table 0xF7D758 entry 2 (TRACK MERGE)
ButtonTable_TrackMerge_StageNonZero_Nop3:
	ret	; F7EF4F  ret   <- button table 0xF7D758 entry 3 (TRACK MERGE)
ButtonTable_TrackMerge_StageNonZero_Nop4:
	ret	; F7EF50  ret   <- button table 0xF7D758 entry 4 (TRACK MERGE)
ButtonTable_TrackMerge_StageNonZero_Nop5:
	ret	; F7EF51  ret   <- button table 0xF7D758 entry 5 (TRACK MERGE)
ButtonTable_TrackMerge_StageNonZero_Nop6:
	ret	; F7EF52  ret   <- button table 0xF7D758 entry 6 (TRACK MERGE)
ButtonTable_TrackMerge_StageNonZero_Nop7:
	ret	; F7EF53  ret   <- button table 0xF7D758 entry 7 (TRACK MERGE) and 1 more slot(s)

; ---------------------------------------------------------------------
; LcdKeyRow2_TrackMerge_StageNonZero -- row 2 of the five key pairs flanking
;           the LCD, on the TrackMerge_StageNonZero screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_TrackMerge_StageNonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_TrackMerge_StageNonZero:
	bit	7, w	; F7EF54  bit 0x07,W
	jr	nz, LcdKeyRow2_TrackMerge_StageNonZero_Return4	; F7EF57  jr NZ,0xf7ef62
	and	(UI_RequestBits:16), 0x6f	; F7EF59  and (0x2075),0x6f
	call	T_TrackMerge_LcdKeyRow2	; F7EF5E  call 0xf42958
LcdKeyRow2_TrackMerge_StageNonZero_Return4:
	ret	; F7EF62  ret
ButtonTable_TrackMerge_StageNonZero_Nop10:
	ret	; F7EF63  ret   <- button table 0xF7D758 entry 10 (TRACK MERGE)

; ---------------------------------------------------------------------
; LcdKeyRow4_TrackMerge_StageNonZero -- row 4 of the five key pairs flanking
;           the LCD, on the TrackMerge_StageNonZero screen
; Reached by: SW28 "LCD RIGHT 4" (matrix segment 3 bit 3, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AE
;           {class 0xA9, code 0x0B} -> delivered code 0x0B; SW76 "LCD LEFT 4"
;           (matrix segment 9 bit 3, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72B
;           {class 0xA9, code 0x0B} -> delivered code 0x8B. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0B of ButtonTable_TrackMerge_StageNonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW76 LCD LEFT 4
;           (segment 9 bit 3, fitted); SW84 [no legend: matrix position
;           outside every diode list] (segment 10 bit 3, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW28 is row 4 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow4_TrackMerge_StageNonZero:
	bit	7, w	; F7EF64  bit 0x07,W
	jr	nz, LcdKeyRow4_TrackMerge_StageNonZero_Return5	; F7EF67  jr NZ,0xf7ef6d
	call	T_TrackMerge_ReturnToStageZero	; F7EF69  call 0xf42954
LcdKeyRow4_TrackMerge_StageNonZero_Return5:
	ret	; F7EF6D  ret
ButtonTable_TrackMerge_StageNonZero_Nop12:
	ret	; F7EF6E  ret   <- button table 0xF7D758 entry 12 (TRACK MERGE)
ButtonTable_TrackMerge_StageNonZero_Nop13:
	ret	; F7EF6F  ret   <- button table 0xF7D758 entry 13 (TRACK MERGE)
ButtonTable_TrackMerge_StageNonZero_Nop14:
	ret	; F7EF70  ret   <- button table 0xF7D758 entry 14 (TRACK MERGE)

; ---------------------------------------------------------------------
; ExitKey_TrackMerge_StageNonZero -- the EXIT key on the TrackMerge_StageNonZero
;           screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_TrackMerge_StageNonZero:
	bit	7, w	; F7EF71  bit 0x07,W
	jr	nz, ExitKey_TrackMerge_StageNonZero_Return6	; F7EF74  jr NZ,0xf7ef7a
	call	T_TrackMerge_ReturnToStageZero	; F7EF76  call 0xf42954
ExitKey_TrackMerge_StageNonZero_Return6:
	ret	; F7EF7A  ret
ButtonTable_TrackMerge_StageNonZero_Nop16:
	ret	; F7EF7B  ret   <- button table 0xF7D758 entry 16 (TRACK MERGE) and 15 more slot(s)

; ---------------------------------------------------------------------
; Paint_MeasureDelete -- paints the panel screen whose own title text reads
;                        "MEASURE DELETE"
;
; Reached by: the +0 method stub of screen object 0xF430E0, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D0DD
; Evidence: the routine loads XIY = 0xF3A5E9 and calls the display-list
;           interpreter; the leading run of op-0x1C records in that list
;           spells "MEASURE DELETE", and the name is that text CamelCased,
;           with the ROM's own spelling kept (zeros for O's included). The
;           rule is round 7's, calibrated on seven screens prom_a had named
;           independently: notes/prom_b_screens_round8.py --calibrate.
; ---------------------------------------------------------------------
Paint_MeasureDelete:
	call	T_CallbackQueue_ResetAndRestartTask2	; F7EF7C  call 0xf42e80
	cp	(UI_ScreenStage:16), 0x00	; F7EF80  cp (0x207e),0x00
	jr	nz, Paint_MeasureDelete_Skip	; F7EF85  jr NZ,0xf7efa2
	call	T_MeasureDelete_InitFields	; F7EF87  call 0xf4295c
	or	(UI_RequestBits:16), 0x09	; F7EF8B  or (0x2075),0x09
	ldw	(PanelDial_DownButton:16), 1156	; F7EF90  ld (0x209b),0x0484  <- arms prom_a PanelButton_Accept's substitution for panel button code 0x0D (0xF86615); see the 0xF7D2D8 banner
	ldw	(9830:16), 65535	; F7EF96  ld (0x2666),0xffff
	ldw	(9834:16), 65535	; F7EF9C  ld (0x266a),0xffff
Paint_MeasureDelete_Skip:
	calr	LCD_ScreenRedraw_Begin	; F7EFA2  calr 0xf7e2d9
	ld	xiy, DL_MeasureDeleteTrackFirstMeasure	; F7EFA5  ld XIY,0x00f3a5e9
	ld	xix, Paint_MeasureDelete_DL	; F7EFAA  ld XIX,0x00f3a66e
	call	T_DisplayList_Run	; F7EFAF  call 0xf417f0
	cp	(UI_ScreenStage:16), 0x00	; F7EFB3  cp (0x207e),0x00
	jr	nz, Paint_MeasureDelete_Skip2	; F7EFB8  jr NZ,0xf7efcc
	ld	xiy, Paint_MeasureDelete_DL	; F7EFBA  ld XIY,0x00f3a66e
	ld	xix, DL_LastMeasure	; F7EFBF  ld XIX,0x00f3a6ab
	call	T_DisplayList_Run	; F7EFC4  call 0xf417f0
	jr	Paint_MeasureDelete_Join	; F7EFC8  jr T,0xf7efe8
	jr	Paint_MeasureDelete_Join	; F7EFCA  jr T,0xf7efe8
Paint_MeasureDelete_Skip2:
	ld	xiy, DL_F3A7DA	; F7EFCC  ld XIY,0x00f3a7da
	ld	xix, DL_MeasureEraseTrackFirstMeasure	; F7EFD1  ld XIX,0x00f3a8f5
	call	T_DisplayList_Run	; F7EFD6  call 0xf417f0
	ld	xiy, DL_AreYouSure	; F7EFDA  ld XIY,0x00f3a461
	ld	xix, DL_TrackMergeOkTrackTrackTrack	; F7EFDF  ld XIX,0x00f3a47f
	call	T_DisplayList_Run	; F7EFE4  call 0xf417f0
Paint_MeasureDelete_Join:
	ld	xiy, DL_LastMeasure	; F7EFE8  ld XIY,0x00f3a6ab
	ld	xix, DLBoxes_F3A6D9	; F7EFED  ld XIX,0x00f3a6d9
	call	T_DisplayListB_Run	; F7EFF2  call 0xf417f4
	calr	LCD_ScreenRedraw_End	; F7EFF6  calr 0xf7e2e7
	ret	; F7EFF9  ret

; Evidence: reached from calr from prom_b 0xF7F082; calr from prom_b
;           0xF7F0A6, and from nothing else the scans see.
; MeasureDelete_RedrawFields: clears the value area (DL_F39551) and redraws the page's fields with
;   T_DLB_Handler_Array8 -- ld xiy, DL_LastMeasure + 0x23 (notes/prom_ab_stage_zero_names.py).
MeasureDelete_RedrawFields:
	calr	ButtonTable_SequencerMedley_Nop	; F7EFFA  calr 0xf7e2d8
	ld	(LCD_CurrentLayer:16), 1	; F7EFFD  ld (0x2540),0x01
	ld	xiy, DL_F39551	; F7F002  ld XIY,0x00f39551
	ld	xix, Data_F39559	; F7F007  ld XIX,0x00f39559
	call	T_DisplayList_Run	; F7F00C  call 0xf417f0
	ld	xiy, DL_LastMeasure + 0x23	; F7F010  ld XIY,0x00f3a6ce
	call	T_DLB_Handler_Array8	; F7F015  call 0xf4181c
	ret	; F7F019  ret

; Evidence: reached from calr from prom_b 0xF7F05D; calr from prom_b
;           0xF7F07F, and from nothing else the scans see.
Draw_LastMeasure:
	calr	ButtonTable_SequencerMedley_Nop	; F7F01A  calr 0xf7e2d8
	ld	(LCD_CurrentLayer:16), 0	; F7F01D  ld (0x2540),0x00
	ld	xiy, DL_LastMeasure	; F7F022  ld XIY,0x00f3a6ab
	ld	xix, DL_LastMeasure + 0x23	; F7F027  ld XIX,0x00f3a6ce
	call	T_DisplayListB_Run	; F7F02C  call 0xf417f4
	ret	; F7F030  ret

; ---------------------------------------------------------------------
; ScreenLeaveBody_MeasureDelete -- the whole body of the MeasureDelete
;                                  screen's Leave method
;
; Reached by: the +4 method stub of screen object 0xF430E0, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D0E2
; Evidence: the whole body of screen object 0xF430E0's +4 method. prom_a's
;           PanelScreen_VtableTable names that object, and its readers take
;           +0 Enter, +4 Leave, +8 Button; the stub at 0xF7D0E2 is `call
;           0xF7F031` then `ret` and nothing else calls this address. The
;           screen's own name is round 7's, from its title text.
; ---------------------------------------------------------------------
ScreenLeaveBody_MeasureDelete:
	call	T_MeasureDelete_OnLeave	; F7F031  call 0xf42960
	ret	; F7F035  ret
ButtonTable_MeasureDelete_StageZero_Nop0:
	ret	; F7F036  ret   <- button table 0xF7D7D8 entry 0 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageZero_Nop1:
	ret	; F7F037  ret   <- button table 0xF7D7D8 entry 1 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageZero_Nop2:
	ret	; F7F038  ret   <- button table 0xF7D7D8 entry 2 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageZero_Nop3:
	ret	; F7F039  ret   <- button table 0xF7D7D8 entry 3 (MEASURE DELETE)

; ---------------------------------------------------------------------
; SoftKeyCol5_MeasureDelete_StageZero -- the 5th of the eight SOFT KEYS in the
;           row under the LCD, on the MeasureDelete_StageZero screen
; Reached by: SW41 "SOFT KEY col 5 lower" (matrix segment 5 bit 0, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6E4 {class 0xA9, code 0x04} -> delivered code 0x84; SW42
;           "SOFT KEY col 5 upper" (matrix segment 5 bit 1, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6E8
;           {class 0xA9, code 0x04} -> delivered code 0x04. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x04 of ButtonTable_MeasureDelete_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW25 LCD RIGHT 1
;           (top) (segment 3 bit 0, fitted); SW26 LCD RIGHT 2 (segment 3 bit
;           1, fitted); SW33 SOFT KEY col 1 lower (segment 4 bit 0, fitted);
;           SW34 SOFT KEY col 1 upper (segment 4 bit 1, fitted). The model
;           strap is the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW41/SW42 are the two switches of its 5th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW41, so "col 5" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol5_MeasureDelete_StageZero:
	bit	1, (UI_RequestBits:16)	; F7F03A  bit 1,(0x2075)
	jr	z, ScreenLeaveBody_MeasureDelete_Skip	; F7F03E  jr Z,0xf7f044
	call	T_Blink_Stop	; F7F040  call 0xf42e24
ScreenLeaveBody_MeasureDelete_Skip:
	or	(UI_RequestBits:16), 0x08	; F7F044  or (0x2075),0x08
	ld	(3608:16), 1	; F7F049  ld (0x0e18),0x01
	bit	7, w	; F7F04E  bit 0x07,W
	jr	z, ScreenLeaveBody_MeasureDelete_Skip2	; F7F051  jr Z,0xf7f059
	call	T_MeasureDelete_StepFieldDown	; F7F053  call 0xf42974
	jr	ScreenLeaveBody_MeasureDelete_Join	; F7F057  jr T,0xf7f05d
ScreenLeaveBody_MeasureDelete_Skip2:
	call	T_MeasureDelete_StepFieldUp	; F7F059  call 0xf42970
ScreenLeaveBody_MeasureDelete_Join:
	calr	Draw_LastMeasure	; F7F05D  calr 0xf7f01a
	ret	; F7F060  ret
ButtonTable_MeasureDelete_StageZero_Nop5:
	ret	; F7F061  ret   <- button table 0xF7D7D8 entry 5 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageZero_Nop6:
	ret	; F7F062  ret   <- button table 0xF7D7D8 entry 6 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageZero_Nop7:
	ret	; F7F063  ret   <- button table 0xF7D7D8 entry 7 (MEASURE DELETE) and 1 more slot(s)

; ---------------------------------------------------------------------
; LcdKeyRow2_MeasureDelete_StageZero -- row 2 of the five key pairs flanking
;           the LCD, on the MeasureDelete_StageZero screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_MeasureDelete_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_MeasureDelete_StageZero:
	bit	7, w	; F7F064  bit 0x07,W
	jr	z, ScreenLeaveBody_MeasureDelete_Return	; F7F067  jr Z,0xf7f087
	cp	(0x0dd4:16), 0x01	; F7F069  cp (0x0dd4),0x01
	jr	z, ScreenLeaveBody_MeasureDelete_Return	; F7F06E  jr Z,0xf7f087
	calr	Blink_DisableThenStop	; F7F070  calr 0xf7f245
	call	T_MeasureDelete_SelectField1	; F7F073  call 0xf42964
	ld	a, (3540:16)	; F7F077  ld A,(0x0dd4)
	ld	(DisplayListB_Stage+5:16), a	; F7F07B  ld (0x12fb),A
	calr	Draw_LastMeasure	; F7F07F  calr 0xf7f01a
	calr	MeasureDelete_RedrawFields	; F7F082  calr 0xf7effa
	jr	ScreenLeaveBody_MeasureDelete_Return	; F7F085  jr T,0xf7f087
ScreenLeaveBody_MeasureDelete_Return:
	ret	; F7F087  ret

; ---------------------------------------------------------------------
; LcdKeyRow3_MeasureDelete_StageZero -- row 3 of the five key pairs flanking
;           the LCD, on the MeasureDelete_StageZero screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_MeasureDelete_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_MeasureDelete_StageZero:
	bit	7, w	; F7F088  bit 0x07,W
	jr	z, ScreenLeaveBody_MeasureDelete_Skip3	; F7F08B  jr Z,0xf7f0ab
	cp	(0x0dd4:16), 0x02	; F7F08D  cp (0x0dd4),0x02
	jr	z, ScreenLeaveBody_MeasureDelete_Return2	; F7F092  jr Z,0xf7f0b2
	calr	Blink_EnableThenStop_Copy	; F7F094  calr 0xf7f237
	call	T_MeasureDelete_SelectField2	; F7F097  call 0xf42968
	ld	a, (3540:16)	; F7F09B  ld A,(0x0dd4)
	ld	(DisplayListB_Stage+5:16), a	; F7F09F  ld (0x12fb),A
	calr	Draw_LastMeasure	; F7F0A3  calr 0xf7f01a
	calr	MeasureDelete_RedrawFields	; F7F0A6  calr 0xf7effa
	jr	ScreenLeaveBody_MeasureDelete_Return2	; F7F0A9  jr T,0xf7f0b2
ScreenLeaveBody_MeasureDelete_Skip3:
	calr	Blink_DisableThenStop	; F7F0AB  calr 0xf7f245
	call	T_MeasureDelete_LcdKeyRow3	; F7F0AE  call 0xf42978
ScreenLeaveBody_MeasureDelete_Return2:
	ret	; F7F0B2  ret

; ---------------------------------------------------------------------
; LcdKeyRow4_MeasureDelete_StageZero -- row 4 of the five key pairs flanking
;           the LCD, on the MeasureDelete_StageZero screen
; Reached by: SW28 "LCD RIGHT 4" (matrix segment 3 bit 3, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AE
;           {class 0xA9, code 0x0B} -> delivered code 0x0B; SW76 "LCD LEFT 4"
;           (matrix segment 9 bit 3, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72B
;           {class 0xA9, code 0x0B} -> delivered code 0x8B. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0B of ButtonTable_MeasureDelete_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW76 LCD LEFT 4
;           (segment 9 bit 3, fitted); SW84 [no legend: matrix position
;           outside every diode list] (segment 10 bit 3, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW28 is row 4 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow4_MeasureDelete_StageZero:
	bit	7, w	; F7F0B3  bit 0x07,W
	jr	z, ScreenLeaveBody_MeasureDelete_Return3	; F7F0B6  jr Z,0xf7f0d4
	cp	(0x0dd4:16), 0x03	; F7F0B8  cp (0x0dd4),0x03
	jr	z, ScreenLeaveBody_MeasureDelete_Return3	; F7F0BD  jr Z,0xf7f0d4
	calr	Blink_EnableThenStop_Copy	; F7F0BF  calr 0xf7f237
	call	T_MeasureDelete_SelectField3	; F7F0C2  call 0xf4296c
	ld	a, (3540:16)	; F7F0C6  ld A,(0x0dd4)
	ld	(DisplayListB_Stage+5:16), a	; F7F0CA  ld (0x12fb),A
	calr	Draw_LastMeasure	; F7F0CE  calr 0xf7f01a
	calr	MeasureDelete_RedrawFields	; F7F0D1  calr 0xf7effa
ScreenLeaveBody_MeasureDelete_Return3:
	ret	; F7F0D4  ret
ButtonTable_MeasureDelete_StageZero_Nop12:
	ret	; F7F0D5  ret   <- button table 0xF7D7D8 entry 12 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageZero_Nop13:
	ret	; F7F0D6  ret   <- button table 0xF7D7D8 entry 13 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageZero_Nop14:
	ret	; F7F0D7  ret   <- button table 0xF7D7D8 entry 14 (MEASURE DELETE)

; ---------------------------------------------------------------------
; ExitKey_MeasureDelete_StageZero -- the EXIT key on the MeasureDelete_StageZero
;           screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_MeasureDelete_StageZero:
	bit	7, w	; F7F0D8  bit 0x07,W
	jr	z, ScreenLeaveBody_MeasureDelete_Skip4	; F7F0DB  jr Z,0xf7f0df
	jr	ScreenLeaveBody_MeasureDelete_Return4	; F7F0DD  jr T,0xf7f0e5
ScreenLeaveBody_MeasureDelete_Skip4:
	ldw	(UI_Request:16), 32794	; F7F0DF  ld (0x2070),0x801a
ScreenLeaveBody_MeasureDelete_Return4:
	ret	; F7F0E5  ret
ButtonTable_MeasureDelete_StageZero_Nop16:
	ret	; F7F0E6  ret   <- button table 0xF7D7D8 entry 16 (MEASURE DELETE) and 4 more slot(s)

; ---------------------------------------------------------------------
; MeasureDelete_StageZero_Button21 -- panel button slot 0x15 of
;           MeasureDelete_StageZero, NOT NAMED
; Unknown:  NO NAME. This routine is registered ONLY at slot 0x15, which is
;           the VARIANT-1 already-held rewrite of base code 0x04 (`add
;           (XIX-1),0x11` at prom_a 0xF8AE7E/0xF8AEF1). The SX-WSA1R is
;           VARIANT 2 (notes/wave7_panel_names_round11.py --variant), and the
;           two rewriting action handlers are variant-1 handlers, so ON THIS
;           MACHINE THE SLOT IS NEVER DELIVERED and the routine is
;           unreachable. On the SX-WSA1, where it can fire, its base 0x04 is
;           the code variant 1 produces from TWO byte-identical group lists --
;           SW25/SW26 (LCD RIGHT) and SW33/SW34 (SOFT KEY col 1), both fitted
;           -- so even there the wire is ambiguous.
; Evidence: the table slot and the screen are re-read from the ROM, and the
;           reachability argument above is reproduced by
;           notes/prom_b_panel_names_round12.py --0x0d (slot 0x0D) and --plan
;           (the rest).
; ---------------------------------------------------------------------
MeasureDelete_StageZero_Button21:
	bit	1, (UI_RequestBits:16)	; F7F0E7  bit 1,(0x2075)
	jr	z, ScreenLeaveBody_MeasureDelete_Skip5	; F7F0EB  jr Z,0xf7f0f1
	call	T_Blink_Stop	; F7F0ED  call 0xf42e24
ScreenLeaveBody_MeasureDelete_Skip5:
	or	(UI_RequestBits:16), 0x08	; F7F0F1  or (0x2075),0x08
	ld	(3608:16), 4	; F7F0F6  ld (0x0e18),0x04
	bit	7, w	; F7F0FB  bit 0x07,W
	jr	z, ScreenLeaveBody_MeasureDelete_Skip6	; F7F0FE  jr Z,0xf7f106
	call	T_MeasureDelete_StepFieldDown	; F7F100  call 0xf42974
	jr	ScreenLeaveBody_MeasureDelete_Join2	; F7F104  jr T,0xf7f10a
ScreenLeaveBody_MeasureDelete_Skip6:
	call	T_MeasureDelete_StepFieldUp	; F7F106  call 0xf42970
ScreenLeaveBody_MeasureDelete_Join2:
	calr	Draw_LastMeasure	; F7F10A  calr 0xf7f01a
	ret	; F7F10D  ret
ButtonTable_MeasureDelete_StageZero_Nop22:
	ret	; F7F10E  ret   <- button table 0xF7D7D8 entry 22 (MEASURE DELETE) and 4 more slot(s)

; ---------------------------------------------------------------------
; NumberPadKey_MeasureDelete_StageZero -- the NUMBER PAD on the
;           MeasureDelete_StageZero screen
; Reached by: code 0x1B from SW9..SW16 NUMBER PAD "0"..NUMBER PAD "7" (segment
;           1 bits 0-7, wire 0xC1, one 8-bit field, no pair position);
;           SW17..SW20 NUMBER PAD "8"..ENTER (segment 2 bits 0-3, wire 0xC2,
;           one 4-bit field, no pair position) -- then prom_a
;           PanelButton_Route `and L,0x1f` at 0xF861AE, then slot 0x1B of the
;           screen's button table.
; Evidence: code 0x1B is emitted only by PanelGroupEventLists_Variant2, from
;           the two number-pad wires, as WHOLE FIELDS with no pair position;
;           variant 1 sends those same wires as class 0xA8 code 0x08, a
;           different event class that never reaches a button table, so no
;           other control can reach this slot under either map. 0x1B - 0x11 =
;           0x0A is not a rewritable base. ★ And the body this forwards to
;           opens `ld A,(0x2267) / cp A,0x0f` -- the same two constants
;           prom_b's own PanelCode_ToSlotAndFlags pairs at 0xF5508C-0xF5509A
;           when it sets flag bit 5 for index 0x1B. All five in-span slot-0x1B
;           handlers do it. Re-derived by notes/prom_b_panel_names_round11.py
;           --selftest.
; ---------------------------------------------------------------------
NumberPadKey_MeasureDelete_StageZero:
	calr	MeasureDelete_StageZero_NumberPadKey	; F7F10F  calr 0xf7f114
	ret	; F7F112  ret
ButtonTable_MeasureDelete_StageZero_Nop28:
	ret	; F7F113  ret   <- button table 0xF7D7D8 entry 28 (MEASURE DELETE) and 3 more slot(s)

; Evidence: reached from calr from prom_b 0xF7F10F, and from nothing else
;           the scans see.
; MeasureDelete_StageZero_NumberPadKey: the NumberPadKey action of MeasureDelete_StageZero -- called only by NumberPadKey_MeasureDelete_StageZero.
MeasureDelete_StageZero_NumberPadKey:
	ld	a, (8807:16)	; F7F114  ld A,(0x2267)
	cp	a, 15	; F7F118  cp A,0x0f
	jr	z, MeasureDelete_StageZero_NumberPadKey_Skip2	; F7F11B  jr Z,0xf7f12e
	cp	a, 128	; F7F11D  cp A,0x80
	jr	z, MeasureDelete_StageZero_NumberPadKey_Skip3	; F7F120  jr Z,0xf7f133
	cp	a, 9	; F7F122  cp A,0x09
	jr	ule, MeasureDelete_StageZero_NumberPadKey_Skip	; F7F125  jr ULE,0xf7f129
	jr	MeasureDelete_StageZero_NumberPadKey_Join	; F7F127  jr T,0xf7f136
MeasureDelete_StageZero_NumberPadKey_Skip:
	calr	Blink_SetEnable_1_6	; F7F129  calr 0xf7f13a
	jr	MeasureDelete_StageZero_NumberPadKey_Join	; F7F12C  jr T,0xf7f136
MeasureDelete_StageZero_NumberPadKey_Skip2:
	calr	MeasureDelete_KeypadCommit	; F7F12E  calr 0xf7f144
	jr	MeasureDelete_StageZero_NumberPadKey_Join	; F7F131  jr T,0xf7f136
MeasureDelete_StageZero_NumberPadKey_Skip3:
	calr	Var2820_Set2B	; F7F133  calr 0xf7f1c2
MeasureDelete_StageZero_NumberPadKey_Join:
	calr	MeasureDelete_BlinkSelectedField	; F7F136  calr 0xf7f1c8
	ret	; F7F139  ret

; Evidence: reached from calr from prom_b 0xF7F129, and from nothing else
;           the scans see.
Blink_SetEnable_1_6:
	pushw	1	; F7F13A  push 0x0001
	call	T_Blink_SetEnable	; F7F13D  call 0xf42e28
	inc	2, xsp	; F7F141  inc 2,XSP
	ret	; F7F143  ret

; Evidence: reached from calr from prom_b 0xF7F12E, and from nothing else
;           the scans see.
; MeasureDelete_KeypadCommit: MEASURE DELETE, keypad code 0x0F (ENTER): converts the typed digits
;   (T_AsciiDigits3_ToValue) and, if 1..999, stores them in the field (0x0DD4) selects -- 2: first measure (0x0DD6),
;   also (0x0C18) and saved 0x60345D; 3: last measure (0x0DD8) -- keeping first <= last; saved count 0x60345F := last
;   - first + 1; then T_Blink_Stop and Draw_LastMeasure. Twin of prom_a AdvanceDelay_KeypadCommit. Basis: caller +
;   body + siblings. (notes/naming-pilot-2026-10-06/proposals_wave8_b8.json)
MeasureDelete_KeypadCommit:
	ld	(10278:16), 3	; F7F144  ld (0x2826),0x03
	call	T_AsciiDigits3_ToValue	; F7F149  call 0xf432f0
	cp	wa, 1:i3	; F7F14D  cp WA,1
	jr	c, MeasureDelete_KeypadCommit_Return	; F7F14F  jr C,0xf7f1c1
	cp	wa, 999	; F7F151  cp WA,0x03e7
	jr	ugt, MeasureDelete_KeypadCommit_Return	; F7F155  jr UGT,0xf7f1c1
	cp	(0x0dd4:16), 0x02	; F7F157  cp (0x0dd4),0x02
	jr	z, MeasureDelete_KeypadCommit_Skip	; F7F15C  jr Z,0xf7f167
	cp	(0x0dd4:16), 0x03	; F7F15E  cp (0x0dd4),0x03
	jr	z, MeasureDelete_KeypadCommit_Skip3	; F7F163  jr Z,0xf7f188
	jr	MeasureDelete_KeypadCommit_Return	; F7F165  jr T,0xf7f1c1
MeasureDelete_KeypadCommit_Skip:
	ld	(3096:16), wa	; F7F167  ld (0x0c18),WA
	ld	(6304861:24), wa	; F7F16B  ld (0x60345d),WA
	cp	wa, (0x0dd8:16)	; F7F170  cp WA,(0x0dd8)
	jr	ule, MeasureDelete_KeypadCommit_Skip2	; F7F174  jr ULE,0xf7f17e
	ld	(3544:16), wa	; F7F176  ld (0x0dd8),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7F17A  ld (0x12f9),WA
MeasureDelete_KeypadCommit_Skip2:
	ld	(3542:16), wa	; F7F17E  ld (0x0dd6),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7F182  ld (0x12f7),WA
	jr	MeasureDelete_KeypadCommit_Join	; F7F186  jr T,0xf7f1ab
MeasureDelete_KeypadCommit_Skip3:
	ld	(3544:16), wa	; F7F188  ld (0x0dd8),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7F18C  ld (0x12f9),WA
	cp	wa, (0x0dd6:16)	; F7F190  cp WA,(0x0dd6)
	jr	nc, MeasureDelete_KeypadCommit_Skip4	; F7F194  jr NC,0xf7f1a7
	ld	(3542:16), wa	; F7F196  ld (0x0dd6),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7F19A  ld (0x12f7),WA
	ld	(3096:16), wa	; F7F19E  ld (0x0c18),WA
	ld	(6304861:24), wa	; F7F1A2  ld (0x60345d),WA
MeasureDelete_KeypadCommit_Skip4:
	ld	(3544:16), wa	; F7F1A7  ld (0x0dd8),WA
MeasureDelete_KeypadCommit_Join:
	ld	wa, (3544:16)	; F7F1AB  ld WA,(0x0dd8)
	sub	wa, (0x0dd6:16)	; F7F1AF  sub WA,(0x0dd6)
	inc	1, wa	; F7F1B3  inc 1,WA
	ld	(6304863:24), wa	; F7F1B5  ld (0x60345f),WA
	call	T_Blink_Stop	; F7F1BA  call 0xf42e24
	calr	Draw_LastMeasure	; F7F1BE  calr 0xf7f01a
MeasureDelete_KeypadCommit_Return:
	ret	; F7F1C1  ret

; Evidence: reached from calr from prom_b 0xF7F133, and from nothing else
;           the scans see.
; Var2820_Set2B: ld (10272:16), 43 (single-cell template; the cell's meaning is not established unless it is named)
Var2820_Set2B:
	ld	(10272:16), 43	; F7F1C2  ld (0x2820),0x2b
	ret	; F7F1C7  ret

; Evidence: reached from calr from prom_b 0xF7F136, and from nothing else
;           the scans see.
; MeasureDelete_BlinkSelectedField: MEASURE DELETE: unless blinking is off ((0x2075) bit 1 clear) or the key was ENTER
;   ((0x2267) = 0x0F), starts the field blink on layer 0 with template BlinkArgPtrs_F7F1F5[(0x0DD4)]
;   (T_Blink_Command). Run after every number-pad key by MeasureDelete_StageZero_NumberPadKey. Twin of prom_a
;   AdvanceDelay_BlinkSelectedField. Basis: caller + body + siblings. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_b8.json)
MeasureDelete_BlinkSelectedField:
	bit	1, (UI_RequestBits:16)	; F7F1C8  bit 1,(0x2075)
	jr	z, MeasureDelete_BlinkSelectedField_Return	; F7F1CC  jr Z,0xf7f1f4
	cp	(0x2267:16), 0x0f	; F7F1CE  cp (0x2267),0x0f
	jr	z, MeasureDelete_BlinkSelectedField_Return	; F7F1D3  jr Z,0xf7f1f4
	xor	xwa, xwa	; F7F1D5  xor XWA,XWA
	ld	a, (3540:16)	; F7F1D7  ld A,(0x0dd4)
	sla	xwa, 2	; F7F1DB  sla 0x02,XWA
	ld	(LCD_CurrentLayer:16), 0	; F7F1DE  ld (0x2540),0x00
	ld	xiy, BlinkArgPtrs_F7F1F5	; F7F1E3  ld XIY,0x00f7f1f5
	ld	xiy, (xiy+wa)	; F7F1E8  ld XIY,(XIY+WA)
	push	xiy	; F7F1ED  push XIY
	call	T_Blink_Command	; F7F1EE  call 0xf42e20
	inc	4, xsp	; F7F1F2  inc 4,XSP
MeasureDelete_BlinkSelectedField_Return:
	ret	; F7F1F4  ret
; ---------------------------------------------------------------------
; BlinkArgPtrs_F7F1F5 -- pointers to blink templates, read through
;                        Blink_Command
;
; Evidence: read by `ld XIY,0x00F7F1F5` at 0xF7F1E3 followed by `ld
;           XIY,(XIY+WA)`, `push XIY` and `call 0xF42E20` --
;           T_Blink_Command, prom_b 0xF0E9CF
;           (notes/FINDINGS-prom_b-field-blink.md). Same shape, same callee
;           and the same two leading NULL entries as prom_a's
;           BlinkArgPtrs_F8024D. FRAMED on purpose: nothing bounds the
;           index, and what the 2 templates it names are for is not
;           established.
; ---------------------------------------------------------------------
BlinkArgPtrs_F7F1F5:
	.long 0x00000000	; F7F1F5  [0]  NULL
	.long 0x00000000	; F7F1F9  [1]  NULL
	.long DL_LastMeasure + 0xF	; F7F1FD  [2]
	.long DL_LastMeasure + 0x19	; F7F201  [3]

ButtonTable_MeasureDelete_StageNonZero_Nop0:
	ret	; F7F205  ret   <- button table 0xF7D858 entry 0 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageNonZero_Nop1:
	ret	; F7F206  ret   <- button table 0xF7D858 entry 1 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageNonZero_Nop2:
	ret	; F7F207  ret   <- button table 0xF7D858 entry 2 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageNonZero_Nop3:
	ret	; F7F208  ret   <- button table 0xF7D858 entry 3 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageNonZero_Nop4:
	ret	; F7F209  ret   <- button table 0xF7D858 entry 4 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageNonZero_Nop5:
	ret	; F7F20A  ret   <- button table 0xF7D858 entry 5 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageNonZero_Nop6:
	ret	; F7F20B  ret   <- button table 0xF7D858 entry 6 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageNonZero_Nop7:
	ret	; F7F20C  ret   <- button table 0xF7D858 entry 7 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageNonZero_Nop8:
	ret	; F7F20D  ret   <- button table 0xF7D858 entry 8 (MEASURE DELETE) and 1 more slot(s)

; ---------------------------------------------------------------------
; LcdKeyRow3_MeasureDelete_StageNonZero -- row 3 of the five key pairs flanking
;           the LCD, on the MeasureDelete_StageNonZero screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_MeasureDelete_StageNonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_MeasureDelete_StageNonZero:
	bit	7, w	; F7F20E  bit 0x07,W
	jr	nz, LcdKeyRow3_MeasureDelete_StageNonZero_Return	; F7F211  jr NZ,0xf7f21c
	and	(UI_RequestBits:16), 0x6f	; F7F213  and (0x2075),0x6f
	call	T_MeasureDelete_LcdKeyRow3	; F7F218  call 0xf42978
LcdKeyRow3_MeasureDelete_StageNonZero_Return:
	ret	; F7F21C  ret

; ---------------------------------------------------------------------
; LcdKeyRow4_MeasureDelete_StageNonZero -- row 4 of the five key pairs flanking
;           the LCD, on the MeasureDelete_StageNonZero screen
; Reached by: SW28 "LCD RIGHT 4" (matrix segment 3 bit 3, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AE
;           {class 0xA9, code 0x0B} -> delivered code 0x0B; SW76 "LCD LEFT 4"
;           (matrix segment 9 bit 3, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72B
;           {class 0xA9, code 0x0B} -> delivered code 0x8B. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0B of ButtonTable_MeasureDelete_StageNonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW76 LCD LEFT 4
;           (segment 9 bit 3, fitted); SW84 [no legend: matrix position
;           outside every diode list] (segment 10 bit 3, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW28 is row 4 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow4_MeasureDelete_StageNonZero:
	bit	7, w	; F7F21D  bit 0x07,W
	jr	nz, LcdKeyRow4_MeasureDelete_StageNonZero_Return	; F7F220  jr NZ,0xf7f228
	call	T_MeasureDelete_StepFieldUp	; F7F222  call 0xf42970
	jr	LcdKeyRow4_MeasureDelete_StageNonZero_Return	; F7F226  jr T,0xf7f228
LcdKeyRow4_MeasureDelete_StageNonZero_Return:
	ret	; F7F228  ret
ButtonTable_MeasureDelete_StageNonZero_Nop12:
	ret	; F7F229  ret   <- button table 0xF7D858 entry 12 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageNonZero_Nop13:
	ret	; F7F22A  ret   <- button table 0xF7D858 entry 13 (MEASURE DELETE)
ButtonTable_MeasureDelete_StageNonZero_Nop14:
	ret	; F7F22B  ret   <- button table 0xF7D858 entry 14 (MEASURE DELETE)

; ---------------------------------------------------------------------
; ExitKey_MeasureDelete_StageNonZero -- the EXIT key on the
;           MeasureDelete_StageNonZero screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_MeasureDelete_StageNonZero:
	bit	7, w	; F7F22C  bit 0x07,W
	jr	nz, ExitKey_MeasureDelete_StageNonZero_Return	; F7F22F  jr NZ,0xf7f235
	call	T_MeasureDelete_StepFieldUp	; F7F231  call 0xf42970
ExitKey_MeasureDelete_StageNonZero_Return:
	ret	; F7F235  ret
ButtonTable_MeasureDelete_StageNonZero_Nop16:
	ret	; F7F236  ret   <- button table 0xF7D858 entry 16 (MEASURE DELETE) and 15 more slot(s)

; Evidence: reached from calr from prom_b 0xF7F094; calr from prom_b
;           0xF7F0BF, and from nothing else the scans see.
; Blink_EnableThenStop_Copy: byte-for-byte Blink_EnableThenStop: T_Blink_SetEnable(1), T_Blink_Stop.
Blink_EnableThenStop_Copy:
	pushw	1	; F7F237  push 0x0001
	call	T_Blink_SetEnable	; F7F23A  call 0xf42e28
	inc	2, xsp	; F7F23E  inc 2,XSP
	call	T_Blink_Stop	; F7F240  call 0xf42e24
	ret	; F7F244  ret

; Evidence: reached from calr from prom_b 0xF7F070; calr from prom_b
;           0xF7F0AB, and from nothing else the scans see.
; Blink_DisableThenStop: T_Blink_SetEnable(0), T_Blink_Stop.
Blink_DisableThenStop:
	pushw	0	; F7F245  push 0x0000
	call	T_Blink_SetEnable	; F7F248  call 0xf42e28
	inc	2, xsp	; F7F24C  inc 2,XSP
	call	T_Blink_Stop	; F7F24E  call 0xf42e24
	ret	; F7F252  ret
	ret	; F7F253  ret

; ---------------------------------------------------------------------
; Paint_MeasureErase -- paints the panel screen whose own title text reads
;                       "MEASURE ERASE"
;
; Reached by: the +0 method stub of screen object 0xF430B0, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D0FE
; Evidence: the routine loads XIY = 0xF3A8F5 and calls the display-list
;           interpreter; the leading run of op-0x1C records in that list
;           spells "MEASURE ERASE", and the name is that text CamelCased,
;           with the ROM's own spelling kept (zeros for O's included). The
;           rule is round 7's, calibrated on seven screens prom_a had named
;           independently: notes/prom_b_screens_round8.py --calibrate.
; ---------------------------------------------------------------------
Paint_MeasureErase:
	call	T_CallbackQueue_ResetAndRestartTask2	; F7F254  call 0xf42e80
	cp	(UI_ScreenStage:16), 0x00	; F7F258  cp (0x207e),0x00
	jr	nz, Paint_MeasureErase_Skip	; F7F25D  jr NZ,0xf7f27a
	call	T_MeasureErase_InitFields	; F7F25F  call 0xf42980
	or	(UI_RequestBits:16), 0x09	; F7F263  or (0x2075),0x09
	ldw	(PanelDial_DownButton:16), 1156	; F7F268  ld (0x209b),0x0484  <- arms prom_a PanelButton_Accept's substitution for panel button code 0x0D (0xF86615); see the 0xF7D2D8 banner
	ldw	(9830:16), 65535	; F7F26E  ld (0x2666),0xffff
	ldw	(9834:16), 65535	; F7F274  ld (0x266a),0xffff
Paint_MeasureErase_Skip:
	calr	LCD_ScreenRedraw_Begin	; F7F27A  calr 0xf7e2d9
	ld	(LCD_CurrentLayer:16), 0	; F7F27D  ld (0x2540),0x00
	ld	xiy, DL_MeasureEraseTrackFirstMeasure	; F7F282  ld XIY,0x00f3a8f5
	ld	xix, Paint_MeasureErase_DL	; F7F287  ld XIX,0x00f3a99d
	call	T_DisplayList_Run	; F7F28C  call 0xf417f0
	cp	(UI_ScreenStage:16), 0x00	; F7F290  cp (0x207e),0x00
	jr	nz, Paint_MeasureErase_Skip2	; F7F295  jr NZ,0xf7f2a7
	ld	xiy, Paint_MeasureErase_DL	; F7F297  ld XIY,0x00f3a99d
	ld	xix, DL_F3A9DA	; F7F29C  ld XIX,0x00f3a9da
	call	T_DisplayList_Run	; F7F2A1  call 0xf417f0
	jr	Paint_MeasureErase_Join	; F7F2A5  jr T,0xf7f2c3
Paint_MeasureErase_Skip2:
	ld	xiy, DL_F3AB9C	; F7F2A7  ld XIY,0x00f3ab9c
	ld	xix, DL_QuantizeTrackStrengthFirstMeasure	; F7F2AC  ld XIX,0x00f3abdb
	call	T_DisplayList_Run	; F7F2B1  call 0xf417f0
	ld	xiy, DL_AreYouSure	; F7F2B5  ld XIY,0x00f3a461
	ld	xix, DL_TrackMergeOkTrackTrackTrack	; F7F2BA  ld XIX,0x00f3a47f
	call	T_DisplayList_Run	; F7F2BF  call 0xf417f0
Paint_MeasureErase_Join:
	ld	xiy, DL_F3A9DA	; F7F2C3  ld XIY,0x00f3a9da
	ld	xix, DLBoxes_F3AA17	; F7F2C8  ld XIX,0x00f3aa17
	call	T_DisplayListB_Run	; F7F2CD  call 0xf417f4
	calr	LCD_ScreenRedraw_End	; F7F2D1  calr 0xf7e2e7
	ret	; F7F2D4  ret

; ---------------------------------------------------------------------
; ScreenLeaveBody_MeasureErase -- the whole body of the MeasureErase
;                                 screen's Leave method
;
; Reached by: the +4 method stub of screen object 0xF430B0, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D103
; Evidence: the whole body of screen object 0xF430B0's +4 method. prom_a's
;           PanelScreen_VtableTable names that object, and its readers take
;           +0 Enter, +4 Leave, +8 Button; the stub at 0xF7D103 is `call
;           0xF7F2D5` then `ret` and nothing else calls this address. The
;           screen's own name is round 7's, from its title text.
; ---------------------------------------------------------------------
ScreenLeaveBody_MeasureErase:
	call	T_MeasureErase_OnLeave	; F7F2D5  call 0xf42984
	ret	; F7F2D9  ret
ButtonTable_MeasureErase_StageZero_Nop0:
	ret	; F7F2DA  ret   <- button table 0xF7D8D8 entry 0 (MEASURE ERASE)
ButtonTable_MeasureErase_StageZero_Nop1:
	ret	; F7F2DB  ret   <- button table 0xF7D8D8 entry 1 (MEASURE ERASE)
ButtonTable_MeasureErase_StageZero_Nop2:
	ret	; F7F2DC  ret   <- button table 0xF7D8D8 entry 2 (MEASURE ERASE)
ButtonTable_MeasureErase_StageZero_Nop3:
	ret	; F7F2DD  ret   <- button table 0xF7D8D8 entry 3 (MEASURE ERASE)

; ---------------------------------------------------------------------
; SoftKeyCol5_MeasureErase_StageZero -- the 5th of the eight SOFT KEYS in the
;           row under the LCD, on the MeasureErase_StageZero screen
; Reached by: SW41 "SOFT KEY col 5 lower" (matrix segment 5 bit 0, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6E4 {class 0xA9, code 0x04} -> delivered code 0x84; SW42
;           "SOFT KEY col 5 upper" (matrix segment 5 bit 1, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6E8
;           {class 0xA9, code 0x04} -> delivered code 0x04. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x04 of ButtonTable_MeasureErase_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW25 LCD RIGHT 1
;           (top) (segment 3 bit 0, fitted); SW26 LCD RIGHT 2 (segment 3 bit
;           1, fitted); SW33 SOFT KEY col 1 lower (segment 4 bit 0, fitted);
;           SW34 SOFT KEY col 1 upper (segment 4 bit 1, fitted). The model
;           strap is the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW41/SW42 are the two switches of its 5th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW41, so "col 5" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol5_MeasureErase_StageZero:
	bit	1, (UI_RequestBits:16)	; F7F2DE  bit 1,(0x2075)
	jr	z, ScreenLeaveBody_MeasureErase_Skip	; F7F2E2  jr Z,0xf7f2e8
	call	T_Blink_Stop	; F7F2E4  call 0xf42e24
ScreenLeaveBody_MeasureErase_Skip:
	or	(UI_RequestBits:16), 0x08	; F7F2E8  or (0x2075),0x08
	ld	(3608:16), 1	; F7F2ED  ld (0x0e18),0x01
	bit	7, w	; F7F2F2  bit 0x07,W
	jr	nz, ScreenLeaveBody_MeasureErase_Skip2	; F7F2F5  jr NZ,0xf7f2fd
	call	T_MeasureErase_StepFieldUp	; F7F2F7  call 0xf42998
	jr	ScreenLeaveBody_MeasureErase_Join	; F7F2FB  jr T,0xf7f301
ScreenLeaveBody_MeasureErase_Skip2:
	call	T_MeasureErase_StepFieldDown	; F7F2FD  call 0xf4299c
ScreenLeaveBody_MeasureErase_Join:
	calr	MeasureErase_DrawValues	; F7F301  calr 0xf7f397
	ret	; F7F304  ret
ButtonTable_MeasureErase_StageZero_Nop5:
	ret	; F7F305  ret   <- button table 0xF7D8D8 entry 5 (MEASURE ERASE)
ButtonTable_MeasureErase_StageZero_Nop6:
	ret	; F7F306  ret   <- button table 0xF7D8D8 entry 6 (MEASURE ERASE)
ButtonTable_MeasureErase_StageZero_Nop7:
	ret	; F7F307  ret   <- button table 0xF7D8D8 entry 7 (MEASURE ERASE)

; ---------------------------------------------------------------------
; LcdKeyRow1_MeasureErase_StageZero -- row 1 of the five key pairs flanking the
;           LCD, on the MeasureErase_StageZero screen
; Reached by: SW25 "LCD RIGHT 1 (top)" (matrix segment 3 bit 0, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A2
;           {class 0xA9, code 0x08} -> delivered code 0x08; SW73 "LCD LEFT 1
;           (top)" (matrix segment 9 bit 0, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B71F
;           {class 0xA9, code 0x08} -> delivered code 0x88. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x08 of ButtonTable_MeasureErase_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW73 LCD LEFT 1
;           (top) (segment 9 bit 0, fitted); SW81 [no legend: matrix position
;           outside every diode list] (segment 10 bit 0, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW25 is row 1 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow1_MeasureErase_StageZero:
	bit	7, w	; F7F308  bit 0x07,W
	jr	z, ScreenLeaveBody_MeasureErase_Return	; F7F30B  jr Z,0xf7f329
	cp	(0x0dbb:16), 0x01	; F7F30D  cp (0x0dbb),0x01
	jr	z, ScreenLeaveBody_MeasureErase_Return	; F7F312  jr Z,0xf7f329
	calr	Blink_DisableThenStop	; F7F314  calr 0xf7f245
	call	T_MeasureErase_SelectField1	; F7F317  call 0xf42988
	ld	a, (3515:16)	; F7F31B  ld A,(0x0dbb)
	ld	(DisplayListB_Stage+6:16), a	; F7F31F  ld (0x12fc),A
	calr	MeasureErase_DrawValues	; F7F323  calr 0xf7f397
	calr	MeasureErase_RedrawFields	; F7F326  calr 0xf7f32a
ScreenLeaveBody_MeasureErase_Return:
	ret	; F7F329  ret

; Evidence: reached from calr from prom_b 0xF7F326; calr from prom_b
;           0xF7F368, and from nothing else the scans see.
; MeasureErase_RedrawFields: clears the value area (DL_F39551) and redraws the page's fields with
;   T_DLB_Handler_Array8 -- ld xiy, DL_F3A9DA + 0x32 (notes/prom_ab_stage_zero_names.py).
MeasureErase_RedrawFields:
	ld	(LCD_CurrentLayer:16), 1	; F7F32A  ld (0x2540),0x01
	calr	ButtonTable_SequencerMedley_Nop	; F7F32F  calr 0xf7e2d8
	ld	xiy, DL_F39551	; F7F332  ld XIY,0x00f39551
	ld	xix, Data_F39559	; F7F337  ld XIX,0x00f39559
	call	T_DisplayList_Run	; F7F33C  call 0xf417f0
	ld	xiy, DL_F3A9DA + 0x32	; F7F340  ld XIY,0x00f3aa0c
	call	T_DLB_Handler_Array8	; F7F345  call 0xf4181c
	ret	; F7F349  ret

; ---------------------------------------------------------------------
; LcdKeyRow2_MeasureErase_StageZero -- row 2 of the five key pairs flanking the
;           LCD, on the MeasureErase_StageZero screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_MeasureErase_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_MeasureErase_StageZero:
	bit	7, w	; F7F34A  bit 0x07,W
	jr	z, LcdKeyRow2_MeasureErase_StageZero_Skip	; F7F34D  jr Z,0xf7f36d
	cp	(0x0dbb:16), 0x02	; F7F34F  cp (0x0dbb),0x02
	jr	z, LcdKeyRow2_MeasureErase_StageZero_Return	; F7F354  jr Z,0xf7f374
	calr	Blink_EnableThenStop_Copy	; F7F356  calr 0xf7f237
	call	T_MeasureErase_SelectField2	; F7F359  call 0xf4298c
	ld	a, (3515:16)	; F7F35D  ld A,(0x0dbb)
	ld	(DisplayListB_Stage+6:16), a	; F7F361  ld (0x12fc),A
	calr	MeasureErase_DrawValues	; F7F365  calr 0xf7f397
	calr	MeasureErase_RedrawFields	; F7F368  calr 0xf7f32a
	jr	LcdKeyRow2_MeasureErase_StageZero_Return	; F7F36B  jr T,0xf7f374
LcdKeyRow2_MeasureErase_StageZero_Skip:
	calr	Blink_DisableThenStop	; F7F36D  calr 0xf7f245
	call	T_MeasureErase_LcdKeyRow2	; F7F370  call 0xf429a0
LcdKeyRow2_MeasureErase_StageZero_Return:
	ret	; F7F374  ret

; ---------------------------------------------------------------------
; LcdKeyRow3_MeasureErase_StageZero -- row 3 of the five key pairs flanking the
;           LCD, on the MeasureErase_StageZero screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_MeasureErase_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_MeasureErase_StageZero:
	bit	7, w	; F7F375  bit 0x07,W
	jr	z, LcdKeyRow3_MeasureErase_StageZero_Return2	; F7F378  jr Z,0xf7f396
	cp	(0x0dbb:16), 0x03	; F7F37A  cp (0x0dbb),0x03
	jr	z, LcdKeyRow3_MeasureErase_StageZero_Return2	; F7F37F  jr Z,0xf7f396
	calr	Blink_EnableThenStop_Copy	; F7F381  calr 0xf7f237
	call	T_MeasureErase_SelectField3	; F7F384  call 0xf42990
	ld	a, (3515:16)	; F7F388  ld A,(0x0dbb)
	ld	(DisplayListB_Stage+6:16), a	; F7F38C  ld (0x12fc),A
	calr	MeasureErase_DrawValues	; F7F390  calr 0xf7f397
	calr	MeasureErase_RedrawFields	; F7F393  calr 0xf7f32a
LcdKeyRow3_MeasureErase_StageZero_Return2:
	ret	; F7F396  ret

; Evidence: reached from calr from prom_b 0xF7F301; calr from prom_b
;           0xF7F323, and from nothing else the scans see.
; MeasureErase_DrawValues: MEASURE ERASE: on layer 0, runs DL_F3A9DA up to its cursor-box record: the track
;   (0-16/MASTER/ALL, DisplayListB_Stage+0), the ALL/NOTE/CONTROL choice (+5) and two 3-digit values (+1, +3). Every
;   MEASURE ERASE field key calls it after changing a field, then MeasureErase_RedrawFields. Basis: callers + body.
;   (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
MeasureErase_DrawValues:
	ld	(LCD_CurrentLayer:16), 0	; F7F397  ld (0x2540),0x00
	calr	ButtonTable_SequencerMedley_Nop	; F7F39C  calr 0xf7e2d8
	ld	xiy, DL_F3A9DA	; F7F39F  ld XIY,0x00f3a9da
	ld	xix, DL_F3A9DA + 0x32	; F7F3A4  ld XIX,0x00f3aa0c
	call	T_DisplayListB_Run	; F7F3A9  call 0xf417f4
	ret	; F7F3AD  ret

; ---------------------------------------------------------------------
; LcdKeyRow4_MeasureErase_StageZero -- row 4 of the five key pairs flanking the
;           LCD, on the MeasureErase_StageZero screen
; Reached by: SW28 "LCD RIGHT 4" (matrix segment 3 bit 3, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AE
;           {class 0xA9, code 0x0B} -> delivered code 0x0B; SW76 "LCD LEFT 4"
;           (matrix segment 9 bit 3, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72B
;           {class 0xA9, code 0x0B} -> delivered code 0x8B. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0B of ButtonTable_MeasureErase_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW76 LCD LEFT 4
;           (segment 9 bit 3, fitted); SW84 [no legend: matrix position
;           outside every diode list] (segment 10 bit 3, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW28 is row 4 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow4_MeasureErase_StageZero:
	bit	7, w	; F7F3AE  bit 0x07,W
	jr	z, LcdKeyRow4_MeasureErase_StageZero_Return	; F7F3B1  jr Z,0xf7f3cf
	cp	(0x0dbb:16), 0x04	; F7F3B3  cp (0x0dbb),0x04
	jr	z, LcdKeyRow4_MeasureErase_StageZero_Return	; F7F3B8  jr Z,0xf7f3cf
	calr	Blink_DisableThenStop	; F7F3BA  calr 0xf7f245
	call	T_MeasureErase_SelectField4	; F7F3BD  call 0xf42994
	ld	a, (3515:16)	; F7F3C1  ld A,(0x0dbb)
	ld	(DisplayListB_Stage+6:16), a	; F7F3C5  ld (0x12fc),A
	calr	MeasureErase_DrawValues	; F7F3C9  calr 0xf7f397
	calr	MeasureErase_RedrawFields	; F7F3CC  calr 0xf7f32a
LcdKeyRow4_MeasureErase_StageZero_Return:
	ret	; F7F3CF  ret
ButtonTable_MeasureErase_StageZero_Nop12:
	ret	; F7F3D0  ret   <- button table 0xF7D8D8 entry 12 (MEASURE ERASE)
ButtonTable_MeasureErase_StageZero_Nop13:
	ret	; F7F3D1  ret   <- button table 0xF7D8D8 entry 13 (MEASURE ERASE)
ButtonTable_MeasureErase_StageZero_Nop14:
	ret	; F7F3D2  ret   <- button table 0xF7D8D8 entry 14 (MEASURE ERASE)

; ---------------------------------------------------------------------
; ExitKey_MeasureErase_StageZero -- the EXIT key on the MeasureErase_StageZero
;           screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_MeasureErase_StageZero:
	bit	7, w	; F7F3D3  bit 0x07,W
	jr	z, ExitKey_MeasureErase_StageZero_Skip	; F7F3D6  jr Z,0xf7f3da
	jr	ExitKey_MeasureErase_StageZero_Return2	; F7F3D8  jr T,0xf7f3e0
ExitKey_MeasureErase_StageZero_Skip:
	ldw	(UI_Request:16), 32794	; F7F3DA  ld (0x2070),0x801a
ExitKey_MeasureErase_StageZero_Return2:
	ret	; F7F3E0  ret
ButtonTable_MeasureErase_StageZero_Nop16:
	ret	; F7F3E1  ret   <- button table 0xF7D8D8 entry 16 (MEASURE ERASE) and 4 more slot(s)

; ---------------------------------------------------------------------
; MeasureErase_StageZero_Button21 -- panel button slot 0x15 of
;           MeasureErase_StageZero, NOT NAMED
; Unknown:  NO NAME. This routine is registered ONLY at slot 0x15, which is
;           the VARIANT-1 already-held rewrite of base code 0x04 (`add
;           (XIX-1),0x11` at prom_a 0xF8AE7E/0xF8AEF1). The SX-WSA1R is
;           VARIANT 2 (notes/wave7_panel_names_round11.py --variant), and the
;           two rewriting action handlers are variant-1 handlers, so ON THIS
;           MACHINE THE SLOT IS NEVER DELIVERED and the routine is
;           unreachable. On the SX-WSA1, where it can fire, its base 0x04 is
;           the code variant 1 produces from TWO byte-identical group lists --
;           SW25/SW26 (LCD RIGHT) and SW33/SW34 (SOFT KEY col 1), both fitted
;           -- so even there the wire is ambiguous.
; Evidence: the table slot and the screen are re-read from the ROM, and the
;           reachability argument above is reproduced by
;           notes/prom_b_panel_names_round12.py --0x0d (slot 0x0D) and --plan
;           (the rest).
; ---------------------------------------------------------------------
MeasureErase_StageZero_Button21:
	bit	1, (UI_RequestBits:16)	; F7F3E2  bit 1,(0x2075)
	jr	z, MeasureErase_StageZero_Button21_Skip2	; F7F3E6  jr Z,0xf7f3ec
	call	T_Blink_Stop	; F7F3E8  call 0xf42e24
MeasureErase_StageZero_Button21_Skip2:
	or	(UI_RequestBits:16), 0x08	; F7F3EC  or (0x2075),0x08
	ld	(3608:16), 4	; F7F3F1  ld (0x0e18),0x04
	bit	7, w	; F7F3F6  bit 0x07,W
	jr	nz, MeasureErase_StageZero_Button21_Skip3	; F7F3F9  jr NZ,0xf7f401
	call	T_MeasureErase_StepFieldUp	; F7F3FB  call 0xf42998
	jr	MeasureErase_StageZero_Button21_Join	; F7F3FF  jr T,0xf7f405
MeasureErase_StageZero_Button21_Skip3:
	call	T_MeasureErase_StepFieldDown	; F7F401  call 0xf4299c
MeasureErase_StageZero_Button21_Join:
	calr	MeasureErase_DrawValues	; F7F405  calr 0xf7f397
	ret	; F7F408  ret
ButtonTable_MeasureErase_StageZero_Nop22:
	ret	; F7F409  ret   <- button table 0xF7D8D8 entry 22 (MEASURE ERASE) and 4 more slot(s)

; ---------------------------------------------------------------------
; NumberPadKey_MeasureErase_StageZero -- the NUMBER PAD on the
;           MeasureErase_StageZero screen
; Reached by: code 0x1B from SW9..SW16 NUMBER PAD "0"..NUMBER PAD "7" (segment
;           1 bits 0-7, wire 0xC1, one 8-bit field, no pair position);
;           SW17..SW20 NUMBER PAD "8"..ENTER (segment 2 bits 0-3, wire 0xC2,
;           one 4-bit field, no pair position) -- then prom_a
;           PanelButton_Route `and L,0x1f` at 0xF861AE, then slot 0x1B of the
;           screen's button table.
; Evidence: code 0x1B is emitted only by PanelGroupEventLists_Variant2, from
;           the two number-pad wires, as WHOLE FIELDS with no pair position;
;           variant 1 sends those same wires as class 0xA8 code 0x08, a
;           different event class that never reaches a button table, so no
;           other control can reach this slot under either map. 0x1B - 0x11 =
;           0x0A is not a rewritable base. ★ And the body this forwards to
;           opens `ld A,(0x2267) / cp A,0x0f` -- the same two constants
;           prom_b's own PanelCode_ToSlotAndFlags pairs at 0xF5508C-0xF5509A
;           when it sets flag bit 5 for index 0x1B. All five in-span slot-0x1B
;           handlers do it. Re-derived by notes/prom_b_panel_names_round11.py
;           --selftest.
; ---------------------------------------------------------------------
NumberPadKey_MeasureErase_StageZero:
	calr	MeasureErase_StageZero_NumberPadKey	; F7F40A  calr 0xf7f440
	ret	; F7F40D  ret
ButtonTable_MeasureErase_StageZero_Nop28:
	ret	; F7F40E  ret   <- button table 0xF7D8D8 entry 28 (MEASURE ERASE) and 3 more slot(s)
ButtonTable_MeasureErase_StageNonZero_Nop0:
	ret	; F7F40F  ret   <- button table 0xF7D958 entry 0 (MEASURE ERASE)
ButtonTable_MeasureErase_StageNonZero_Nop1:
	ret	; F7F410  ret   <- button table 0xF7D958 entry 1 (MEASURE ERASE)
ButtonTable_MeasureErase_StageNonZero_Nop2:
	ret	; F7F411  ret   <- button table 0xF7D958 entry 2 (MEASURE ERASE)
ButtonTable_MeasureErase_StageNonZero_Nop3:
	ret	; F7F412  ret   <- button table 0xF7D958 entry 3 (MEASURE ERASE)
ButtonTable_MeasureErase_StageNonZero_Nop4:
	ret	; F7F413  ret   <- button table 0xF7D958 entry 4 (MEASURE ERASE)
ButtonTable_MeasureErase_StageNonZero_Nop5:
	ret	; F7F414  ret   <- button table 0xF7D958 entry 5 (MEASURE ERASE)
ButtonTable_MeasureErase_StageNonZero_Nop6:
	ret	; F7F415  ret   <- button table 0xF7D958 entry 6 (MEASURE ERASE)
ButtonTable_MeasureErase_StageNonZero_Nop7:
	ret	; F7F416  ret   <- button table 0xF7D958 entry 7 (MEASURE ERASE)
ButtonTable_MeasureErase_StageNonZero_Nop8:
	ret	; F7F417  ret   <- button table 0xF7D958 entry 8 (MEASURE ERASE)

; ---------------------------------------------------------------------
; LcdKeyRow2_MeasureErase_StageNonZero -- row 2 of the five key pairs flanking
;           the LCD, on the MeasureErase_StageNonZero screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_MeasureErase_StageNonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_MeasureErase_StageNonZero:
	bit	7, w	; F7F418  bit 0x07,W
	jr	nz, LcdKeyRow2_MeasureErase_StageNonZero_Return3	; F7F41B  jr NZ,0xf7f426
	and	(UI_RequestBits:16), 0x6f	; F7F41D  and (0x2075),0x6f
	call	T_MeasureErase_LcdKeyRow2	; F7F422  call 0xf429a0
LcdKeyRow2_MeasureErase_StageNonZero_Return3:
	ret	; F7F426  ret

; ---------------------------------------------------------------------
; LcdKeyRow3_MeasureErase_StageNonZero -- row 3 of the five key pairs flanking
;           the LCD, on the MeasureErase_StageNonZero screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_MeasureErase_StageNonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_MeasureErase_StageNonZero:
	bit	7, w	; F7F427  bit 0x07,W
	jr	nz, LcdKeyRow3_MeasureErase_StageNonZero_Return4	; F7F42A  jr NZ,0xf7f430
	call	T_MeasureErase_StepFieldUp	; F7F42C  call 0xf42998
LcdKeyRow3_MeasureErase_StageNonZero_Return4:
	ret	; F7F430  ret
ButtonTable_MeasureErase_StageNonZero_Nop11:
	ret	; F7F431  ret   <- button table 0xF7D958 entry 11 (MEASURE ERASE)
ButtonTable_MeasureErase_StageNonZero_Nop12:
	ret	; F7F432  ret   <- button table 0xF7D958 entry 12 (MEASURE ERASE)
ButtonTable_MeasureErase_StageNonZero_Nop13:
	ret	; F7F433  ret   <- button table 0xF7D958 entry 13 (MEASURE ERASE)
ButtonTable_MeasureErase_StageNonZero_Nop14:
	ret	; F7F434  ret   <- button table 0xF7D958 entry 14 (MEASURE ERASE)

; ---------------------------------------------------------------------
; ExitKey_MeasureErase_StageNonZero -- the EXIT key on the
;           MeasureErase_StageNonZero screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_MeasureErase_StageNonZero:
	bit	7, w	; F7F435  bit 0x07,W
	jr	nz, ExitKey_MeasureErase_StageNonZero_Return5	; F7F438  jr NZ,0xf7f43e
	call	T_MeasureErase_StepFieldUp	; F7F43A  call 0xf42998
ExitKey_MeasureErase_StageNonZero_Return5:
	ret	; F7F43E  ret
ButtonTable_MeasureErase_StageNonZero_Nop16:
	ret	; F7F43F  ret   <- button table 0xF7D958 entry 16 (MEASURE ERASE) and 15 more slot(s)

; Evidence: reached from calr from prom_b 0xF7F40A, and from nothing else
;           the scans see.
; MeasureErase_StageZero_NumberPadKey: the NumberPadKey action of MeasureErase_StageZero -- called only by NumberPadKey_MeasureErase_StageZero.
MeasureErase_StageZero_NumberPadKey:
	ld	a, (8807:16)	; F7F440  ld A,(0x2267)
	cp	a, 9	; F7F444  cp A,0x09
	jr	le, MeasureErase_StageZero_NumberPadKey_Skip	; F7F447  jr LE,0xf7f455
	cp	a, 15	; F7F449  cp A,0x0f
	jr	z, MeasureErase_StageZero_NumberPadKey_Skip2	; F7F44C  jr Z,0xf7f45a
	cp	a, 128	; F7F44E  cp A,0x80
	jr	z, MeasureErase_StageZero_NumberPadKey_Skip3	; F7F451  jr Z,0xf7f45f
	jr	MeasureErase_StageZero_NumberPadKey_Join	; F7F453  jr T,0xf7f462
MeasureErase_StageZero_NumberPadKey_Skip:
	calr	Blink_SetEnable_1_7	; F7F455  calr 0xf7f466
	jr	MeasureErase_StageZero_NumberPadKey_Join	; F7F458  jr T,0xf7f462
MeasureErase_StageZero_NumberPadKey_Skip2:
	calr	MeasureErase_KeypadCommit	; F7F45A  calr 0xf7f470
	jr	MeasureErase_StageZero_NumberPadKey_Join	; F7F45D  jr T,0xf7f462
MeasureErase_StageZero_NumberPadKey_Skip3:
	calr	Var2820_Set2B_2	; F7F45F  calr 0xf7f4ee
MeasureErase_StageZero_NumberPadKey_Join:
	calr	MeasureErase_BlinkSelectedField	; F7F462  calr 0xf7f4f4
	ret	; F7F465  ret

; Evidence: reached from calr from prom_b 0xF7F455, and from nothing else
;           the scans see.
Blink_SetEnable_1_7:
	pushw	1	; F7F466  push 0x0001
	call	T_Blink_SetEnable	; F7F469  call 0xf42e28
	inc	2, xsp	; F7F46D  inc 2,XSP
	ret	; F7F46F  ret

; Evidence: reached from calr from prom_b 0xF7F45A, and from nothing else
;           the scans see.
; MeasureErase_KeypadCommit: MEASURE ERASE, keypad code 0x0F: converts the typed digits and, if 1..999, stores them in
;   the field (0x0DBB) selects -- 2: first measure (0x0C2A), also (0x0C18) and saved 0x603462; 3: last measure
;   (0x0C2C) -- keeping first <= last; saved count 0x603464 := last - first + 1; then T_Blink_Stop and
;   MeasureErase_DrawValues. Twin of AdvanceDelay_KeypadCommit. Basis: caller + body + siblings. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_b8.json)
MeasureErase_KeypadCommit:
	ld	(10278:16), 3	; F7F470  ld (0x2826),0x03
	call	T_AsciiDigits3_ToValue	; F7F475  call 0xf432f0
	cp	wa, 1:i3	; F7F479  cp WA,1
	jr	lt, MeasureErase_KeypadCommit_Return	; F7F47B  jr LT,0xf7f4ed
	cp	wa, 999	; F7F47D  cp WA,0x03e7
	jr	gt, MeasureErase_KeypadCommit_Return	; F7F481  jr GT,0xf7f4ed
	cp	(0x0dbb:16), 0x02	; F7F483  cp (0x0dbb),0x02
	jr	z, MeasureErase_KeypadCommit_Skip	; F7F488  jr Z,0xf7f493
	cp	(0x0dbb:16), 0x03	; F7F48A  cp (0x0dbb),0x03
	jr	z, MeasureErase_KeypadCommit_Skip3	; F7F48F  jr Z,0xf7f4b4
	jr	MeasureErase_KeypadCommit_Return	; F7F491  jr T,0xf7f4ed
MeasureErase_KeypadCommit_Skip:
	ld	(3096:16), wa	; F7F493  ld (0x0c18),WA
	ld	(6304866:24), wa	; F7F497  ld (0x603462),WA
	cp	wa, (0x0c2c:16)	; F7F49C  cp WA,(0x0c2c)
	jr	ule, MeasureErase_KeypadCommit_Skip2	; F7F4A0  jr ULE,0xf7f4aa
	ld	(3116:16), wa	; F7F4A2  ld (0x0c2c),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7F4A6  ld (0x12f9),WA
MeasureErase_KeypadCommit_Skip2:
	ld	(3114:16), wa	; F7F4AA  ld (0x0c2a),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7F4AE  ld (0x12f7),WA
	jr	MeasureErase_KeypadCommit_Join	; F7F4B2  jr T,0xf7f4d7
MeasureErase_KeypadCommit_Skip3:
	ld	(3116:16), wa	; F7F4B4  ld (0x0c2c),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7F4B8  ld (0x12f9),WA
	cp	wa, (0x0c2a:16)	; F7F4BC  cp WA,(0x0c2a)
	jr	nc, MeasureErase_KeypadCommit_Skip4	; F7F4C0  jr NC,0xf7f4d3
	ld	(3114:16), wa	; F7F4C2  ld (0x0c2a),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7F4C6  ld (0x12f7),WA
	ld	(3096:16), wa	; F7F4CA  ld (0x0c18),WA
	ld	(6304866:24), wa	; F7F4CE  ld (0x603462),WA
MeasureErase_KeypadCommit_Skip4:
	ld	(3116:16), wa	; F7F4D3  ld (0x0c2c),WA
MeasureErase_KeypadCommit_Join:
	ld	wa, (3116:16)	; F7F4D7  ld WA,(0x0c2c)
	sub	wa, (0x0c2a:16)	; F7F4DB  sub WA,(0x0c2a)
	inc	1, wa	; F7F4DF  inc 1,WA
	ld	(6304868:24), wa	; F7F4E1  ld (0x603464),WA
	call	T_Blink_Stop	; F7F4E6  call 0xf42e24
	calr	MeasureErase_DrawValues	; F7F4EA  calr 0xf7f397
MeasureErase_KeypadCommit_Return:
	ret	; F7F4ED  ret

; Evidence: reached from calr from prom_b 0xF7F45F, and from nothing else
;           the scans see.
; Var2820_Set2B_2: ld (10272:16), 43 (single-cell template; the cell's meaning is not established unless it is named)
Var2820_Set2B_2:
	ld	(10272:16), 43	; F7F4EE  ld (0x2820),0x2b
	ret	; F7F4F3  ret

; Evidence: reached from calr from prom_b 0xF7F462, and from nothing else
;           the scans see.
; MeasureErase_BlinkSelectedField: MEASURE ERASE: unless (0x2075) bit 1 is clear or (0x2267) = 0x0F, starts the field
;   blink on layer 0 with template BlinkArgPtrs_F7F521[(0x0DBB)]. MeasureErase_StageZero_NumberPadKey's common tail.
;   Twin of AdvanceDelay_BlinkSelectedField. Basis: caller + body + siblings. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_b8.json)
MeasureErase_BlinkSelectedField:
	bit	1, (UI_RequestBits:16)	; F7F4F4  bit 1,(0x2075)
	jr	z, MeasureErase_BlinkSelectedField_Return	; F7F4F8  jr Z,0xf7f520
	cp	(0x2267:16), 0x0f	; F7F4FA  cp (0x2267),0x0f
	jr	z, MeasureErase_BlinkSelectedField_Return	; F7F4FF  jr Z,0xf7f520
	xor	xwa, xwa	; F7F501  xor XWA,XWA
	ld	a, (3515:16)	; F7F503  ld A,(0x0dbb)
	sla	xwa, 2	; F7F507  sla 0x02,XWA
	ld	(LCD_CurrentLayer:16), 0	; F7F50A  ld (0x2540),0x00
	ld	xiy, BlinkArgPtrs_F7F521	; F7F50F  ld XIY,0x00f7f521
	ld	xiy, (xiy+wa)	; F7F514  ld XIY,(XIY+WA)
	push	xiy	; F7F519  push XIY
	call	T_Blink_Command	; F7F51A  call 0xf42e20
	inc	4, xsp	; F7F51E  inc 4,XSP
MeasureErase_BlinkSelectedField_Return:
	ret	; F7F520  ret
; ---------------------------------------------------------------------
; BlinkArgPtrs_F7F521 -- pointers to blink templates, read through
;                        Blink_Command
;
; Evidence: read by `ld XIY,0x00F7F521` at 0xF7F50F followed by `ld
;           XIY,(XIY+WA)`, `push XIY` and `call 0xF42E20` --
;           T_Blink_Command, prom_b 0xF0E9CF
;           (notes/FINDINGS-prom_b-field-blink.md). Same shape, same callee
;           and the same two leading NULL entries as prom_a's
;           BlinkArgPtrs_F8024D. FRAMED on purpose: nothing bounds the
;           index, and what the 2 templates it names are for is not
;           established.
; ---------------------------------------------------------------------
BlinkArgPtrs_F7F521:
	.long 0x00000000	; F7F521  [0]  NULL
	.long 0x00000000	; F7F525  [1]  NULL
	.long DL_F3A9DA + 0x1E	; F7F529  [2]
	.long DL_F3A9DA + 0x28	; F7F52D  [3]
	.long 0x00000000	; F7F531  [4]  NULL

	.fill	1, 1, 0x0E	; F7F535-F7F535  `ret` padding below the table above


; ---------------------------------------------------------------------
; Paint_PanelWrite -- paints the panel screen whose own title text reads
;                     "PANEL WRITE"
;
; Reached by: the +0 method stub of screen object 0xF43130, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D11F
; Evidence: the routine loads XIY = 0xF3AD88 and calls the display-list
;           interpreter; the leading run of op-0x1C records in that list
;           spells "PANEL WRITE", and the name is that text CamelCased, with
;           the ROM's own spelling kept (zeros for O's included). The rule
;           is round 7's, calibrated on seven screens prom_a had named
;           independently: notes/prom_b_screens_round8.py --calibrate.
; ---------------------------------------------------------------------
Paint_PanelWrite:
	call	T_CallbackQueue_ResetAndRestartTask2	; F7F536  call 0xf42e80
	call	T_PanelWrite_OnEnter	; F7F53A  call 0xf42ab4
	calr	LCD_ScreenRedraw_Begin	; F7F53E  calr 0xf7e2d9
	ld	(LCD_CurrentLayer:16), 0	; F7F541  ld (0x2540),0x00
	ld	xiy, DL_PanelWritePanelWriteReplacesTheSoundsAnd	; F7F546  ld XIY,0x00f3ad88
	ld	xix, DL_N0teChangeTargetNoteTrack	; F7F54B  ld XIX,0x00f3aeaf
	call	T_DisplayList_Run	; F7F550  call 0xf417f0
	calr	LCD_ScreenRedraw_End	; F7F554  calr 0xf7e2e7
	ret	; F7F557  ret
ScreenLeave_PanelWrite_Nop:
	ret	; F7F558  ret

; ---------------------------------------------------------------------
; ScreenButtonBody_PanelWrite -- the whole body of the PanelWrite screen's
;                                Button method
;
; Reached by: the +8 method stub of screen object 0xF43130, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D129
; Evidence: the whole body of screen object 0xF43130's +8 method. prom_a's
;           PanelScreen_VtableTable names that object, and its readers take
;           +0 Enter, +4 Leave, +8 Button; the stub at 0xF7D129 is `call
;           0xF7F559` then `ret` and nothing else calls this address. The
;           screen's own name is round 7's, from its title text.
; ---------------------------------------------------------------------
ScreenButtonBody_PanelWrite:
	cp	hl, 6:i3	; F7F559  cp HL,6
	jr	z, ScreenButtonBody_PanelWrite_Skip	; F7F55B  jr Z,0xf7f563
	cp	hl, 23	; F7F55D  cp HL,0x0017
	jr	nz, ScreenButtonBody_PanelWrite_Skip2	; F7F561  jr NZ,0xf7f569
ScreenButtonBody_PanelWrite_Skip:
	call	T_PanelWrite_Execute	; F7F563  call 0xf42abc
	jr	ScreenButtonBody_PanelWrite_Return	; F7F567  jr T,0xf7f573
ScreenButtonBody_PanelWrite_Skip2:
	cp	hl, 15	; F7F569  cp HL,0x000f
	jr	nz, ScreenButtonBody_PanelWrite_Return	; F7F56D  jr NZ,0xf7f573
	call	ExitKey_PanelWrite	; F7F56F  call 0xf7f574
ScreenButtonBody_PanelWrite_Return:
	ret	; F7F573  ret

; Evidence: reached from call from prom_b 0xF7F56F, and from nothing else
;           the scans see.
; ExitKey_PanelWrite: PANEL WRITE's EXIT key (button code 0x0F): at pair position 1 (W bit 7 clear) UI_Request :=
;   0x801A, back to the EDIT screen (0x1A); otherwise nothing. ScreenButtonBody_PanelWrite calls it for HL = 15.
;   Basis: caller + body + siblings (ExitKey_TrackAssignPresets). (notes/naming-
;   pilot-2026-10-06/proposals_wave8_b8.json)
ExitKey_PanelWrite:
	bit	7, w	; F7F574  bit 0x07,W
	jr	z, ExitKey_PanelWrite_Skip	; F7F577  jr Z,0xf7f57b
	jr	ExitKey_PanelWrite_Return	; F7F579  jr T,0xf7f581
ExitKey_PanelWrite_Skip:
	ldw	(UI_Request:16), 32794	; F7F57B  ld (0x2070),0x801a
ExitKey_PanelWrite_Return:
	ret	; F7F581  ret

; ---------------------------------------------------------------------
; Paint_Quantize -- paints the panel screen whose own title text reads
;                   "QUANTIZE"
;
; Reached by: the +0 method stub of screen object 0xF43090, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D12F
; Evidence: the routine loads XIY = 0xF3ABDB and calls the display-list
;           interpreter; the leading run of op-0x1C records in that list
;           spells "QUANTIZE", and the name is that text CamelCased, with
;           the ROM's own spelling kept (zeros for O's included). The rule
;           is round 7's, calibrated on seven screens prom_a had named
;           independently: notes/prom_b_screens_round8.py --calibrate.
; ---------------------------------------------------------------------
Paint_Quantize:
	call	T_CallbackQueue_ResetAndRestartTask2	; F7F582  call 0xf42e80
	cp	(UI_ScreenStage:16), 0x00	; F7F586  cp (0x207e),0x00
	jr	nz, Paint_Quantize_Skip	; F7F58B  jr NZ,0xf7f5a8
	call	T_Quantize_InitFields	; F7F58D  call 0xf42908
	or	(UI_RequestBits:16), 0x01	; F7F591  or (0x2075),0x01
	ldw	(PanelDial_DownButton:16), 1156	; F7F596  ld (0x209b),0x0484  <- arms prom_a PanelButton_Accept's substitution for panel button code 0x0D (0xF86615); see the 0xF7D2D8 banner
	ldw	(9830:16), 65535	; F7F59C  ld (0x2666),0xffff
	ldw	(9834:16), 65535	; F7F5A2  ld (0x266a),0xffff
Paint_Quantize_Skip:
	calr	LCD_ScreenRedraw_Begin	; F7F5A8  calr 0xf7e2d9
	ld	(LCD_CurrentLayer:16), 0	; F7F5AB  ld (0x2540),0x00
	ld	xiy, DL_QuantizeTrackStrengthFirstMeasure	; F7F5B0  ld XIY,0x00f3abdb
	ld	xix, Paint_Quantize_DL	; F7F5B5  ld XIX,0x00f3acb3
	call	T_DisplayList_Run	; F7F5BA  call 0xf417f0
	cp	(UI_ScreenStage:16), 0x00	; F7F5BE  cp (0x207e),0x00
	jr	nz, Paint_Quantize_Skip2	; F7F5C3  jr NZ,0xf7f5d5
	ld	xiy, Paint_Quantize_DL	; F7F5C5  ld XIY,0x00f3acb3
	ld	xix, DL_TrackValueFirstMeasureLastMeasureStrengthWindow	; F7F5CA  ld XIX,0x00f3acf0
	call	T_DisplayList_Run	; F7F5CF  call 0xf417f0
	jr	Paint_Quantize_Join	; F7F5D3  jr T,0xf7f5f1
Paint_Quantize_Skip2:
	ld	xiy, DL_F3A7DA	; F7F5D5  ld XIY,0x00f3a7da
	ld	xix, DL_MeasureEraseTrackFirstMeasure	; F7F5DA  ld XIX,0x00f3a8f5
	call	T_DisplayList_Run	; F7F5DF  call 0xf417f0
	ld	xiy, DL_AreYouSure	; F7F5E3  ld XIY,0x00f3a461
	ld	xix, DL_TrackMergeOkTrackTrackTrack	; F7F5E8  ld XIX,0x00f3a47f
	call	T_DisplayList_Run	; F7F5ED  call 0xf417f0
Paint_Quantize_Join:
	ld	xiy, DL_TrackValueFirstMeasureLastMeasureStrengthWindow	; F7F5F1  ld XIY,0x00f3acf0
	ld	xix, DLBoxes_F3AD42	; F7F5F6  ld XIX,0x00f3ad42
	call	T_DisplayListB_Run	; F7F5FB  call 0xf417f4
	calr	LCD_ScreenRedraw_End	; F7F5FF  calr 0xf7e2e7
	ret	; F7F602  ret

; ---------------------------------------------------------------------
; ScreenLeaveBody_Quantize -- the whole body of the Quantize screen's Leave
;                             method
;
; Reached by: the +4 method stub of screen object 0xF43090, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D134
; Evidence: the whole body of screen object 0xF43090's +4 method. prom_a's
;           PanelScreen_VtableTable names that object, and its readers take
;           +0 Enter, +4 Leave, +8 Button; the stub at 0xF7D134 is `call
;           0xF7F603` then `ret` and nothing else calls this address. The
;           screen's own name is round 7's, from its title text.
; ---------------------------------------------------------------------
ScreenLeaveBody_Quantize:
	call	T_Quantize_OnLeave	; F7F603  call 0xf4290c
	ret	; F7F607  ret
ButtonTable_Quantize_StageZero_Nop0:
	ret	; F7F608  ret   <- button table 0xF7D9D8 entry 0 (QUANTIZE)
ButtonTable_Quantize_StageZero_Nop1:
	ret	; F7F609  ret   <- button table 0xF7D9D8 entry 1 (QUANTIZE)
ButtonTable_Quantize_StageZero_Nop2:
	ret	; F7F60A  ret   <- button table 0xF7D9D8 entry 2 (QUANTIZE)
ButtonTable_Quantize_StageZero_Nop3:
	ret	; F7F60B  ret   <- button table 0xF7D9D8 entry 3 (QUANTIZE)

; ---------------------------------------------------------------------
; SoftKeyCol5_Quantize_StageZero -- the 5th of the eight SOFT KEYS in the row
;           under the LCD, on the Quantize_StageZero screen
; Reached by: SW41 "SOFT KEY col 5 lower" (matrix segment 5 bit 0, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6E4 {class 0xA9, code 0x04} -> delivered code 0x84; SW42
;           "SOFT KEY col 5 upper" (matrix segment 5 bit 1, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6E8
;           {class 0xA9, code 0x04} -> delivered code 0x04. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x04 of ButtonTable_Quantize_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW25 LCD RIGHT 1
;           (top) (segment 3 bit 0, fitted); SW26 LCD RIGHT 2 (segment 3 bit
;           1, fitted); SW33 SOFT KEY col 1 lower (segment 4 bit 0, fitted);
;           SW34 SOFT KEY col 1 upper (segment 4 bit 1, fitted). The model
;           strap is the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW41/SW42 are the two switches of its 5th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW41, so "col 5" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol5_Quantize_StageZero:
	bit	1, (UI_RequestBits:16)	; F7F60C  bit 1,(0x2075)
	jr	z, ScreenLeaveBody_Quantize_Skip	; F7F610  jr Z,0xf7f616
	call	T_Blink_Stop	; F7F612  call 0xf42e24
ScreenLeaveBody_Quantize_Skip:
	or	(UI_RequestBits:16), 0x08	; F7F616  or (0x2075),0x08
	ld	(3608:16), 1	; F7F61B  ld (0x0e18),0x01
	bit	7, w	; F7F620  bit 0x07,W
	jr	z, ScreenLeaveBody_Quantize_Skip2	; F7F623  jr Z,0xf7f62b
	call	T_Quantize_StepFieldDown	; F7F625  call 0xf4292c
	jr	ScreenLeaveBody_Quantize_Join	; F7F629  jr T,0xf7f62f
ScreenLeaveBody_Quantize_Skip2:
	call	T_Quantize_StepFieldUp	; F7F62B  call 0xf42928
ScreenLeaveBody_Quantize_Join:
	calr	Draw_TrackValueFirstMeasureLastMeasureStrengthWindow	; F7F62F  calr 0xf7f6e5
	ret	; F7F632  ret
ButtonTable_Quantize_StageZero_Nop5:
	ret	; F7F633  ret   <- button table 0xF7D9D8 entry 5 (QUANTIZE)
ButtonTable_Quantize_StageZero_Nop6:
	ret	; F7F634  ret   <- button table 0xF7D9D8 entry 6 (QUANTIZE)
ButtonTable_Quantize_StageZero_Nop7:
	ret	; F7F635  ret   <- button table 0xF7D9D8 entry 7 (QUANTIZE)

; ---------------------------------------------------------------------
; LcdKeyRow1_Quantize_StageZero -- row 1 of the five key pairs flanking the
;           LCD, on the Quantize_StageZero screen
; Reached by: SW25 "LCD RIGHT 1 (top)" (matrix segment 3 bit 0, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A2
;           {class 0xA9, code 0x08} -> delivered code 0x08; SW73 "LCD LEFT 1
;           (top)" (matrix segment 9 bit 0, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B71F
;           {class 0xA9, code 0x08} -> delivered code 0x88. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x08 of ButtonTable_Quantize_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW73 LCD LEFT 1
;           (top) (segment 9 bit 0, fitted); SW81 [no legend: matrix position
;           outside every diode list] (segment 10 bit 0, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW25 is row 1 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow1_Quantize_StageZero:
	bit	7, w	; F7F636  bit 0x07,W
	jr	z, ScreenLeaveBody_Quantize_Skip3	; F7F639  jr Z,0xf7f64b
	cp	(0x0db9:16), 0x01	; F7F63B  cp (0x0db9),0x01
	jr	z, ScreenLeaveBody_Quantize_Return	; F7F640  jr Z,0xf7f667
	calr	Blink_DisableThenStop	; F7F642  calr 0xf7f245
	call	T_Quantize_SelectField1	; F7F645  call 0xf42910
	jr	ScreenLeaveBody_Quantize_Join2	; F7F649  jr T,0xf7f659
ScreenLeaveBody_Quantize_Skip3:
	cp	(0x0db9:16), 0x05	; F7F64B  cp (0x0db9),0x05
	jr	z, ScreenLeaveBody_Quantize_Return	; F7F650  jr Z,0xf7f667
	calr	Blink_DisableThenStop	; F7F652  calr 0xf7f245
	call	T_Quantize_SelectField5	; F7F655  call 0xf42920
ScreenLeaveBody_Quantize_Join2:
	ld	a, (3513:16)	; F7F659  ld A,(0x0db9)
	ld	(DisplayListB_Stage+8:16), a	; F7F65D  ld (0x12fe),A
	calr	Draw_TrackValueFirstMeasureLastMeasureStrengthWindow	; F7F661  calr 0xf7f6e5
	calr	Quantize_RedrawFields	; F7F664  calr 0xf7f668
ScreenLeaveBody_Quantize_Return:
	ret	; F7F667  ret

; Evidence: reached from calr from prom_b 0xF7F664; calr from prom_b
;           0xF7F6B6, and from nothing else the scans see.
; Quantize_RedrawFields: clears the value area (DL_F39551) and redraws the page's fields with
;   T_DLB_Handler_Array8 -- ld xiy, DL_TrackValueFirstMeasureLastMeasureStrengthWindow + 0x47 (notes/prom_ab_stage_zero_names.py).
Quantize_RedrawFields:
	ld	(LCD_CurrentLayer:16), 1	; F7F668  ld (0x2540),0x01
	calr	ButtonTable_SequencerMedley_Nop	; F7F66D  calr 0xf7e2d8
	ld	xiy, DL_F39551	; F7F670  ld XIY,0x00f39551
	ld	xix, Data_F39559	; F7F675  ld XIX,0x00f39559
	call	T_DisplayList_Run	; F7F67A  call 0xf417f0
	ld	xiy, DL_TrackValueFirstMeasureLastMeasureStrengthWindow + 0x47	; F7F67E  ld XIY,0x00f3ad37
	call	T_DLB_Handler_Array8	; F7F683  call 0xf4181c
	ret	; F7F687  ret

; ---------------------------------------------------------------------
; LcdKeyRow2_Quantize_StageZero -- row 2 of the five key pairs flanking the
;           LCD, on the Quantize_StageZero screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_Quantize_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_Quantize_StageZero:
	bit	7, w	; F7F688  bit 0x07,W
	jr	z, LcdKeyRow2_Quantize_StageZero_Skip	; F7F68B  jr Z,0xf7f69d
	cp	(0x0db9:16), 0x02	; F7F68D  cp (0x0db9),0x02
	jr	z, LcdKeyRow2_Quantize_StageZero_Return	; F7F692  jr Z,0xf7f6b9
	calr	Blink_EnableThenStop_Copy	; F7F694  calr 0xf7f237
	call	T_Quantize_SelectField2	; F7F697  call 0xf42914
	jr	LcdKeyRow2_Quantize_StageZero_Join	; F7F69B  jr T,0xf7f6ab
LcdKeyRow2_Quantize_StageZero_Skip:
	cp	(0x0db9:16), 0x06	; F7F69D  cp (0x0db9),0x06
	jr	z, LcdKeyRow2_Quantize_StageZero_Return	; F7F6A2  jr Z,0xf7f6b9
	calr	Blink_DisableThenStop	; F7F6A4  calr 0xf7f245
	call	T_Quantize_SelectField6	; F7F6A7  call 0xf42924
LcdKeyRow2_Quantize_StageZero_Join:
	ld	a, (3513:16)	; F7F6AB  ld A,(0x0db9)
	ld	(DisplayListB_Stage+8:16), a	; F7F6AF  ld (0x12fe),A
	calr	Draw_TrackValueFirstMeasureLastMeasureStrengthWindow	; F7F6B3  calr 0xf7f6e5
	calr	Quantize_RedrawFields	; F7F6B6  calr 0xf7f668
LcdKeyRow2_Quantize_StageZero_Return:
	ret	; F7F6B9  ret

; ---------------------------------------------------------------------
; LcdKeyRow3_Quantize_StageZero -- row 3 of the five key pairs flanking the
;           LCD, on the Quantize_StageZero screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_Quantize_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_Quantize_StageZero:
	bit	7, w	; F7F6BA  bit 0x07,W
	jr	z, LcdKeyRow3_Quantize_StageZero_Skip2	; F7F6BD  jr Z,0xf7f6dd
	cp	(0x0db9:16), 0x03	; F7F6BF  cp (0x0db9),0x03
	jr	z, LcdKeyRow3_Quantize_StageZero_Return2	; F7F6C4  jr Z,0xf7f6e4
	calr	Blink_EnableThenStop_Copy	; F7F6C6  calr 0xf7f237
	call	T_Quantize_SelectField3	; F7F6C9  call 0xf42918
	ld	a, (3513:16)	; F7F6CD  ld A,(0x0db9)
	ld	(DisplayListB_Stage+8:16), a	; F7F6D1  ld (0x12fe),A
	calr	Draw_TrackValueFirstMeasureLastMeasureStrengthWindow	; F7F6D5  calr 0xf7f6e5
	calr	Quantize_RedrawFields	; F7F6D8  calr 0xf7f668
	jr	LcdKeyRow3_Quantize_StageZero_Return2	; F7F6DB  jr T,0xf7f6e4
LcdKeyRow3_Quantize_StageZero_Skip2:
	calr	Blink_DisableThenStop	; F7F6DD  calr 0xf7f245
	call	T_Quantize_LcdKeyRow3	; F7F6E0  call 0xf42930
LcdKeyRow3_Quantize_StageZero_Return2:
	ret	; F7F6E4  ret

; Evidence: reached from calr from prom_b 0xF7F62F; calr from prom_b
;           0xF7F661, and from nothing else the scans see.
Draw_TrackValueFirstMeasureLastMeasureStrengthWindow:
	ld	(LCD_CurrentLayer:16), 0	; F7F6E5  ld (0x2540),0x00
	calr	ButtonTable_SequencerMedley_Nop	; F7F6EA  calr 0xf7e2d8
	ld	xiy, DL_TrackValueFirstMeasureLastMeasureStrengthWindow	; F7F6ED  ld XIY,0x00f3acf0
	ld	xix, DL_TrackValueFirstMeasureLastMeasureStrengthWindow + 0x47	; F7F6F2  ld XIX,0x00f3ad37
	call	T_DisplayListB_Run	; F7F6F7  call 0xf417f4
	ret	; F7F6FB  ret

; ---------------------------------------------------------------------
; LcdKeyRow4_Quantize_StageZero -- row 4 of the five key pairs flanking the
;           LCD, on the Quantize_StageZero screen
; Reached by: SW28 "LCD RIGHT 4" (matrix segment 3 bit 3, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AE
;           {class 0xA9, code 0x0B} -> delivered code 0x0B; SW76 "LCD LEFT 4"
;           (matrix segment 9 bit 3, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72B
;           {class 0xA9, code 0x0B} -> delivered code 0x8B. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0B of ButtonTable_Quantize_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW76 LCD LEFT 4
;           (segment 9 bit 3, fitted); SW84 [no legend: matrix position
;           outside every diode list] (segment 10 bit 3, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW28 is row 4 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow4_Quantize_StageZero:
	bit	7, w	; F7F6FC  bit 0x07,W
	jr	z, Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Return	; F7F6FF  jr Z,0xf7f71d
	cp	(0x0db9:16), 0x04	; F7F701  cp (0x0db9),0x04
	jr	z, Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Return	; F7F706  jr Z,0xf7f71d
	calr	Blink_DisableThenStop	; F7F708  calr 0xf7f245
	call	T_Quantize_SelectField4	; F7F70B  call 0xf4291c
	ld	a, (3513:16)	; F7F70F  ld A,(0x0db9)
	ld	(DisplayListB_Stage+8:16), a	; F7F713  ld (0x12fe),A
	calr	Draw_TrackValueFirstMeasureLastMeasureStrengthWindow	; F7F717  calr 0xf7f6e5
	calr	Quantize_RedrawFields	; F7F71A  calr 0xf7f668
Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Return:
	ret	; F7F71D  ret
ButtonTable_Quantize_StageZero_Nop12:
	ret	; F7F71E  ret   <- button table 0xF7D9D8 entry 12 (QUANTIZE)
ButtonTable_Quantize_StageZero_Nop13:
	ret	; F7F71F  ret   <- button table 0xF7D9D8 entry 13 (QUANTIZE)
ButtonTable_Quantize_StageZero_Nop14:
	ret	; F7F720  ret   <- button table 0xF7D9D8 entry 14 (QUANTIZE)

; ---------------------------------------------------------------------
; ExitKey_Quantize_StageZero -- the EXIT key on the Quantize_StageZero screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_Quantize_StageZero:
	bit	7, w	; F7F721  bit 0x07,W
	jr	z, Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Skip	; F7F724  jr Z,0xf7f728
	jr	Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Return2	; F7F726  jr T,0xf7f74c
Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Skip:
	cp	(0x133f:16), 0x1a	; F7F728  cp (0x133f),0x1a
	jr	z, Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Skip2	; F7F72D  jr Z,0xf7f746
	bit	2, (TransportB_State:8)	; F7F72F  bit 2,(0x96)
	jr	nz, Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Return2	; F7F732  jr NZ,0xf7f74c
	xor	xwa, xwa	; F7F734  xor XWA,XWA
	ld	(12296:16), xwa	; F7F736  ld (0x3008),XWA
	ld	(12300:16), xwa	; F7F73A  ld (0x300c),XWA
	ldw	(UI_Request:16), 32774	; F7F73E  ld (0x2070),0x8006
	jr	Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Return2	; F7F744  jr T,0xf7f74c
Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Skip2:
	ldw	(UI_Request:16), 32794	; F7F746  ld (0x2070),0x801a
Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Return2:
	ret	; F7F74C  ret
ButtonTable_Quantize_StageZero_Nop16:
	ret	; F7F74D  ret   <- button table 0xF7D9D8 entry 16 (QUANTIZE) and 4 more slot(s)

; ---------------------------------------------------------------------
; Quantize_StageZero_Button21 -- panel button slot 0x15 of Quantize_StageZero,
;           NOT NAMED
; Unknown:  NO NAME. This routine is registered ONLY at slot 0x15, which is
;           the VARIANT-1 already-held rewrite of base code 0x04 (`add
;           (XIX-1),0x11` at prom_a 0xF8AE7E/0xF8AEF1). The SX-WSA1R is
;           VARIANT 2 (notes/wave7_panel_names_round11.py --variant), and the
;           two rewriting action handlers are variant-1 handlers, so ON THIS
;           MACHINE THE SLOT IS NEVER DELIVERED and the routine is
;           unreachable. On the SX-WSA1, where it can fire, its base 0x04 is
;           the code variant 1 produces from TWO byte-identical group lists --
;           SW25/SW26 (LCD RIGHT) and SW33/SW34 (SOFT KEY col 1), both fitted
;           -- so even there the wire is ambiguous.
; Evidence: the table slot and the screen are re-read from the ROM, and the
;           reachability argument above is reproduced by
;           notes/prom_b_panel_names_round12.py --0x0d (slot 0x0D) and --plan
;           (the rest).
; ---------------------------------------------------------------------
Quantize_StageZero_Button21:
	bit	1, (UI_RequestBits:16)	; F7F74E  bit 1,(0x2075)
	jr	z, Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Skip3	; F7F752  jr Z,0xf7f758
	call	T_Blink_Stop	; F7F754  call 0xf42e24
Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Skip3:
	or	(UI_RequestBits:16), 0x08	; F7F758  or (0x2075),0x08
	ld	(3608:16), 4	; F7F75D  ld (0x0e18),0x04
	bit	7, w	; F7F762  bit 0x07,W
	jr	z, Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Skip4	; F7F765  jr Z,0xf7f76d
	call	T_Quantize_StepFieldDown	; F7F767  call 0xf4292c
	jr	Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Join	; F7F76B  jr T,0xf7f771
Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Skip4:
	call	T_Quantize_StepFieldUp	; F7F76D  call 0xf42928
Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Join:
	calr	Draw_TrackValueFirstMeasureLastMeasureStrengthWindow	; F7F771  calr 0xf7f6e5
	ret	; F7F774  ret
ButtonTable_Quantize_StageZero_Nop22:
	ret	; F7F775  ret   <- button table 0xF7D9D8 entry 22 (QUANTIZE) and 4 more slot(s)

; ---------------------------------------------------------------------
; NumberPadKey_Quantize_StageZero -- the NUMBER PAD on the Quantize_StageZero
;           screen
; Reached by: code 0x1B from SW9..SW16 NUMBER PAD "0"..NUMBER PAD "7" (segment
;           1 bits 0-7, wire 0xC1, one 8-bit field, no pair position);
;           SW17..SW20 NUMBER PAD "8"..ENTER (segment 2 bits 0-3, wire 0xC2,
;           one 4-bit field, no pair position) -- then prom_a
;           PanelButton_Route `and L,0x1f` at 0xF861AE, then slot 0x1B of the
;           screen's button table.
; Evidence: code 0x1B is emitted only by PanelGroupEventLists_Variant2, from
;           the two number-pad wires, as WHOLE FIELDS with no pair position;
;           variant 1 sends those same wires as class 0xA8 code 0x08, a
;           different event class that never reaches a button table, so no
;           other control can reach this slot under either map. 0x1B - 0x11 =
;           0x0A is not a rewritable base. ★ And the body this forwards to
;           opens `ld A,(0x2267) / cp A,0x0f` -- the same two constants
;           prom_b's own PanelCode_ToSlotAndFlags pairs at 0xF5508C-0xF5509A
;           when it sets flag bit 5 for index 0x1B. All five in-span slot-0x1B
;           handlers do it. Re-derived by notes/prom_b_panel_names_round11.py
;           --selftest.
; ---------------------------------------------------------------------
NumberPadKey_Quantize_StageZero:
	calr	Quantize_StageZero_NumberPadKey	; F7F776  calr 0xf7f7ac
	ret	; F7F779  ret
ButtonTable_Quantize_StageZero_Nop28:
	ret	; F7F77A  ret   <- button table 0xF7D9D8 entry 28 (QUANTIZE) and 3 more slot(s)
ButtonTable_Quantize_StageNonZero_Nop0:
	ret	; F7F77B  ret   <- button table 0xF7DA58 entry 0 (QUANTIZE)
ButtonTable_Quantize_StageNonZero_Nop1:
	ret	; F7F77C  ret   <- button table 0xF7DA58 entry 1 (QUANTIZE)
ButtonTable_Quantize_StageNonZero_Nop2:
	ret	; F7F77D  ret   <- button table 0xF7DA58 entry 2 (QUANTIZE)
ButtonTable_Quantize_StageNonZero_Nop3:
	ret	; F7F77E  ret   <- button table 0xF7DA58 entry 3 (QUANTIZE)
ButtonTable_Quantize_StageNonZero_Nop4:
	ret	; F7F77F  ret   <- button table 0xF7DA58 entry 4 (QUANTIZE)
ButtonTable_Quantize_StageNonZero_Nop5:
	ret	; F7F780  ret   <- button table 0xF7DA58 entry 5 (QUANTIZE)
ButtonTable_Quantize_StageNonZero_Nop6:
	ret	; F7F781  ret   <- button table 0xF7DA58 entry 6 (QUANTIZE)
ButtonTable_Quantize_StageNonZero_Nop7:
	ret	; F7F782  ret   <- button table 0xF7DA58 entry 7 (QUANTIZE)
ButtonTable_Quantize_StageNonZero_Nop8:
	ret	; F7F783  ret   <- button table 0xF7DA58 entry 8 (QUANTIZE) and 1 more slot(s)

; ---------------------------------------------------------------------
; LcdKeyRow3_Quantize_StageNonZero -- row 3 of the five key pairs flanking the
;           LCD, on the Quantize_StageNonZero screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_Quantize_StageNonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_Quantize_StageNonZero:
	bit	7, w	; F7F784  bit 0x07,W
	jr	nz, Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Return3	; F7F787  jr NZ,0xf7f792
	and	(UI_RequestBits:16), 0x6f	; F7F789  and (0x2075),0x6f
	call	T_Quantize_LcdKeyRow3	; F7F78E  call 0xf42930
Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Return3:
	ret	; F7F792  ret

; ---------------------------------------------------------------------
; LcdKeyRow4_Quantize_StageNonZero -- row 4 of the five key pairs flanking the
;           LCD, on the Quantize_StageNonZero screen
; Reached by: SW28 "LCD RIGHT 4" (matrix segment 3 bit 3, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AE
;           {class 0xA9, code 0x0B} -> delivered code 0x0B; SW76 "LCD LEFT 4"
;           (matrix segment 9 bit 3, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72B
;           {class 0xA9, code 0x0B} -> delivered code 0x8B. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0B of ButtonTable_Quantize_StageNonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW76 LCD LEFT 4
;           (segment 9 bit 3, fitted); SW84 [no legend: matrix position
;           outside every diode list] (segment 10 bit 3, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW28 is row 4 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow4_Quantize_StageNonZero:
	bit	7, w	; F7F793  bit 0x07,W
	jr	nz, Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Return4	; F7F796  jr NZ,0xf7f79c
	call	T_Quantize_StepFieldUp	; F7F798  call 0xf42928
Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Return4:
	ret	; F7F79C  ret
ButtonTable_Quantize_StageNonZero_Nop12:
	ret	; F7F79D  ret   <- button table 0xF7DA58 entry 12 (QUANTIZE)
ButtonTable_Quantize_StageNonZero_Nop13:
	ret	; F7F79E  ret   <- button table 0xF7DA58 entry 13 (QUANTIZE)
ButtonTable_Quantize_StageNonZero_Nop14:
	ret	; F7F79F  ret   <- button table 0xF7DA58 entry 14 (QUANTIZE)

; ---------------------------------------------------------------------
; ExitKey_Quantize_StageNonZero -- the EXIT key on the Quantize_StageNonZero
;           screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_Quantize_StageNonZero:
	bit	7, w	; F7F7A0  bit 0x07,W
	jr	nz, Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Return5	; F7F7A3  jr NZ,0xf7f7a9
	call	T_Quantize_StepFieldUp	; F7F7A5  call 0xf42928
Draw_TrackValueFirstMeasureLastMeasureStrengthWindow_Return5:
	ret	; F7F7A9  ret
ButtonTable_Quantize_StageNonZero_Nop16:
	ret	; F7F7AA  ret   <- button table 0xF7DA58 entry 16 (QUANTIZE) and 15 more slot(s)
	ret	; F7F7AB  ret

; Evidence: reached from calr from prom_b 0xF7F776, and from nothing else
;           the scans see.
; Quantize_StageZero_NumberPadKey: the NumberPadKey action of Quantize_StageZero -- called only by NumberPadKey_Quantize_StageZero.
Quantize_StageZero_NumberPadKey:
	ld	a, (8807:16)	; F7F7AC  ld A,(0x2267)
	cp	a, 9	; F7F7B0  cp A,0x09
	jr	le, Quantize_StageZero_NumberPadKey_Skip	; F7F7B3  jr LE,0xf7f7c1
	cp	a, 15	; F7F7B5  cp A,0x0f
	jr	z, Quantize_StageZero_NumberPadKey_Skip2	; F7F7B8  jr Z,0xf7f7c6
	cp	a, 128	; F7F7BA  cp A,0x80
	jr	z, Quantize_StageZero_NumberPadKey_Skip3	; F7F7BD  jr Z,0xf7f7cb
	jr	Quantize_StageZero_NumberPadKey_Join	; F7F7BF  jr T,0xf7f7ce
Quantize_StageZero_NumberPadKey_Skip:
	calr	Blink_SetEnable_1_8	; F7F7C1  calr 0xf7f7d2
	jr	Quantize_StageZero_NumberPadKey_Join	; F7F7C4  jr T,0xf7f7ce
Quantize_StageZero_NumberPadKey_Skip2:
	calr	Quantize_KeypadCommit	; F7F7C6  calr 0xf7f7dc
	jr	Quantize_StageZero_NumberPadKey_Join	; F7F7C9  jr T,0xf7f7ce
Quantize_StageZero_NumberPadKey_Skip3:
	calr	Var2820_Set2B_3	; F7F7CB  calr 0xf7f85a
Quantize_StageZero_NumberPadKey_Join:
	calr	Quantize_BlinkSelectedField	; F7F7CE  calr 0xf7f860
	ret	; F7F7D1  ret

; Evidence: reached from calr from prom_b 0xF7F7C1, and from nothing else
;           the scans see.
Blink_SetEnable_1_8:
	pushw	1	; F7F7D2  push 0x0001
	call	T_Blink_SetEnable	; F7F7D5  call 0xf42e28
	inc	2, xsp	; F7F7D9  inc 2,XSP
	ret	; F7F7DB  ret

; Evidence: reached from calr from prom_b 0xF7F7C6, and from nothing else
;           the scans see.
; Quantize_KeypadCommit: QUANTIZE, keypad code 0x0F: converts the typed digits and, if 1..999, stores them in the
;   field (0x0DB9) selects -- 2: first measure (0x0C26), also (0x0C4A) and saved 0x603478; 3: last measure (0x0C28) --
;   keeping first <= last; saved count 0x60347A := last - first + 1; then T_Blink_Stop and
;   Draw_TrackValueFirstMeasureLastMeasureStrengthWindow. Twin of AdvanceDelay_KeypadCommit. Basis: caller + body +
;   siblings. (notes/naming-pilot-2026-10-06/proposals_wave8_b8.json)
Quantize_KeypadCommit:
	ld	(10278:16), 3	; F7F7DC  ld (0x2826),0x03
	call	T_AsciiDigits3_ToValue	; F7F7E1  call 0xf432f0
	cp	wa, 1:i3	; F7F7E5  cp WA,1
	jr	lt, Quantize_KeypadCommit_Return	; F7F7E7  jr LT,0xf7f859
	cp	wa, 999	; F7F7E9  cp WA,0x03e7
	jr	gt, Quantize_KeypadCommit_Return	; F7F7ED  jr GT,0xf7f859
	cp	(0x0db9:16), 0x02	; F7F7EF  cp (0x0db9),0x02
	jr	z, Quantize_KeypadCommit_Skip	; F7F7F4  jr Z,0xf7f7ff
	cp	(0x0db9:16), 0x03	; F7F7F6  cp (0x0db9),0x03
	jr	z, Quantize_KeypadCommit_Skip3	; F7F7FB  jr Z,0xf7f820
	jr	Quantize_KeypadCommit_Return	; F7F7FD  jr T,0xf7f859
Quantize_KeypadCommit_Skip:
	ld	(6304888:24), wa	; F7F7FF  ld (0x603478),WA
	ld	(3146:16), wa	; F7F804  ld (0x0c4a),WA
	cp	wa, (0x0c28:16)	; F7F808  cp WA,(0x0c28)
	jr	ule, Quantize_KeypadCommit_Skip2	; F7F80C  jr ULE,0xf7f816
	ld	(3112:16), wa	; F7F80E  ld (0x0c28),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7F812  ld (0x12f9),WA
Quantize_KeypadCommit_Skip2:
	ld	(3110:16), wa	; F7F816  ld (0x0c26),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7F81A  ld (0x12f7),WA
	jr	Quantize_KeypadCommit_Join	; F7F81E  jr T,0xf7f843
Quantize_KeypadCommit_Skip3:
	ld	(3112:16), wa	; F7F820  ld (0x0c28),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7F824  ld (0x12f9),WA
	cp	wa, (0x0c26:16)	; F7F828  cp WA,(0x0c26)
	jr	nc, Quantize_KeypadCommit_Skip4	; F7F82C  jr NC,0xf7f83f
	ld	(3110:16), wa	; F7F82E  ld (0x0c26),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7F832  ld (0x12f7),WA
	ld	(6304888:24), wa	; F7F836  ld (0x603478),WA
	ld	(3146:16), wa	; F7F83B  ld (0x0c4a),WA
Quantize_KeypadCommit_Skip4:
	ld	(3112:16), wa	; F7F83F  ld (0x0c28),WA
Quantize_KeypadCommit_Join:
	ld	wa, (3112:16)	; F7F843  ld WA,(0x0c28)
	sub	wa, (0x0c26:16)	; F7F847  sub WA,(0x0c26)
	inc	1, wa	; F7F84B  inc 1,WA
	ld	(6304890:24), wa	; F7F84D  ld (0x60347a),WA
	call	T_Blink_Stop	; F7F852  call 0xf42e24
	calr	Draw_TrackValueFirstMeasureLastMeasureStrengthWindow	; F7F856  calr 0xf7f6e5
Quantize_KeypadCommit_Return:
	ret	; F7F859  ret

; Evidence: reached from calr from prom_b 0xF7F7CB, and from nothing else
;           the scans see.
; Var2820_Set2B_3: ld (10272:16), 43 (single-cell template; the cell's meaning is not established unless it is named)
Var2820_Set2B_3:
	ld	(10272:16), 43	; F7F85A  ld (0x2820),0x2b
	ret	; F7F85F  ret

; Evidence: reached from calr from prom_b 0xF7F7CE, and from nothing else
;           the scans see.
; Quantize_BlinkSelectedField: QUANTIZE: unless (0x2075) bit 1 is clear or (0x2267) = 0x0F, starts the field blink on
;   layer 0 with template BlinkArgPtrs_F7F88D[(0x0DB9)]. Quantize_StageZero_NumberPadKey's common tail. Twin of
;   AdvanceDelay_BlinkSelectedField. Basis: caller + body + siblings. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_b8.json)
Quantize_BlinkSelectedField:
	bit	1, (UI_RequestBits:16)	; F7F860  bit 1,(0x2075)
	jr	z, Quantize_BlinkSelectedField_Return	; F7F864  jr Z,0xf7f88c
	cp	(0x2267:16), 0x0f	; F7F866  cp (0x2267),0x0f
	jr	z, Quantize_BlinkSelectedField_Return	; F7F86B  jr Z,0xf7f88c
	xor	xwa, xwa	; F7F86D  xor XWA,XWA
	ld	a, (3513:16)	; F7F86F  ld A,(0x0db9)
	sla	xwa, 2	; F7F873  sla 0x02,XWA
	ld	(LCD_CurrentLayer:16), 0	; F7F876  ld (0x2540),0x00
	ld	xiy, BlinkArgPtrs_F7F88D	; F7F87B  ld XIY,0x00f7f88d
	ld	xiy, (xiy+wa)	; F7F880  ld XIY,(XIY+WA)
	push	xiy	; F7F885  push XIY
	call	T_Blink_Command	; F7F886  call 0xf42e20
	inc	4, xsp	; F7F88A  inc 4,XSP
Quantize_BlinkSelectedField_Return:
	ret	; F7F88C  ret
; ---------------------------------------------------------------------
; BlinkArgPtrs_F7F88D -- pointers to blink templates, read through
;                        Blink_Command
;
; Evidence: read by `ld XIY,0x00F7F88D` at 0xF7F87B followed by `ld
;           XIY,(XIY+WA)`, `push XIY` and `call 0xF42E20` --
;           T_Blink_Command, prom_b 0xF0E9CF
;           (notes/FINDINGS-prom_b-field-blink.md). Same shape, same callee
;           and the same two leading NULL entries as prom_a's
;           BlinkArgPtrs_F8024D. FRAMED on purpose: nothing bounds the
;           index, and what the 2 templates it names are for is not
;           established.
; ---------------------------------------------------------------------
BlinkArgPtrs_F7F88D:
	.long 0x00000000	; F7F88D  [0]  NULL
	.long 0x00000000	; F7F891  [1]  NULL
	.long DL_TrackValueFirstMeasureLastMeasureStrengthWindow + 0x1E	; F7F895  [2]
	.long DL_TrackValueFirstMeasureLastMeasureStrengthWindow + 0x28	; F7F899  [3]
	.long 0x00000000	; F7F89D  [4]  NULL
	.long 0x00000000	; F7F8A1  [5]  NULL
	.long 0x00000000	; F7F8A5  [6]  NULL


; ---------------------------------------------------------------------
; Paint_Vel0cityChange -- paints the panel screen whose own title text reads
;                         "VEL0CITY CHANGE"
;
; Reached by: the +0 method stub of screen object 0xF43080, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D150
; Evidence: the routine loads XIY = 0xF3AA54 and calls the display-list
;           interpreter; the leading run of op-0x1C records in that list
;           spells "VEL0CITY CHANGE", and the name is that text CamelCased,
;           with the ROM's own spelling kept (zeros for O's included). The
;           rule is round 7's, calibrated on seven screens prom_a had named
;           independently: notes/prom_b_screens_round8.py --calibrate.
; ---------------------------------------------------------------------
Paint_Vel0cityChange:
	call	T_CallbackQueue_ResetAndRestartTask2	; F7F8A9  call 0xf42e80
	cp	(UI_ScreenStage:16), 0x00	; F7F8AD  cp (0x207e),0x00
	jr	nz, Paint_Vel0cityChange_Skip	; F7F8B2  jr NZ,0xf7f8cf
	call	T_Vel0cityChange_InitFields	; F7F8B4  call 0xf428e0
	or	(UI_RequestBits:16), 0x01	; F7F8B8  or (0x2075),0x01
	ldw	(PanelDial_DownButton:16), 1156	; F7F8BD  ld (0x209b),0x0484  <- arms prom_a PanelButton_Accept's substitution for panel button code 0x0D (0xF86615); see the 0xF7D2D8 banner
	ldw	(9830:16), 65535	; F7F8C3  ld (0x2666),0xffff
	ldw	(9834:16), 65535	; F7F8C9  ld (0x266a),0xffff
Paint_Vel0cityChange_Skip:
	calr	LCD_ScreenRedraw_Begin	; F7F8CF  calr 0xf7e2d9
	ld	(LCD_CurrentLayer:16), 0	; F7F8D2  ld (0x2540),0x00
	cp	(UI_ScreenStage:16), 0x00	; F7F8D7  cp (0x207e),0x00
	jr	nz, Paint_Vel0cityChange_Skip2	; F7F8DC  jr NZ,0xf7f8ee
	ld	xiy, DL_Vel0cityChangeTrackFirstMeasure	; F7F8DE  ld XIY,0x00f3aa54
	ld	xix, DL_F3AB3B	; F7F8E3  ld XIX,0x00f3ab3b
	call	T_DisplayList_Run	; F7F8E8  call 0xf417f0
	jr	Paint_Vel0cityChange_Join	; F7F8EC  jr T,0xf7f918
Paint_Vel0cityChange_Skip2:
	ld	xiy, DL_Vel0cityChangeTrackFirstMeasure	; F7F8EE  ld XIY,0x00f3aa54
	ld	xix, DL_Vel0cityChangeTrackFirstMeasure + 0xAA	; F7F8F3  ld XIX,0x00f3aafe
	call	T_DisplayList_Run	; F7F8F8  call 0xf417f0
	ld	xiy, DL_F3AB9C	; F7F8FC  ld XIY,0x00f3ab9c
	ld	xix, DL_QuantizeTrackStrengthFirstMeasure	; F7F901  ld XIX,0x00f3abdb
	call	T_DisplayList_Run	; F7F906  call 0xf417f0
	ld	xiy, DL_AreYouSure	; F7F90A  ld XIY,0x00f3a461
	ld	xix, DL_TrackMergeOkTrackTrackTrack	; F7F90F  ld XIX,0x00f3a47f
	call	T_DisplayList_Run	; F7F914  call 0xf417f0
Paint_Vel0cityChange_Join:
	ld	(LCD_CurrentLayer:16), 0	; F7F918  ld (0x2540),0x00
	calr	ButtonTable_SequencerMedley_Nop	; F7F91D  calr 0xf7e2d8
	calr	Vel0cityChange_FormatSignedValue	; F7F920  calr 0xf7f935
	ld	xiy, DL_F3AB3B	; F7F923  ld XIY,0x00f3ab3b
	ld	xix, DLBoxes_F3AB74	; F7F928  ld XIX,0x00f3ab74
	call	T_DisplayListB_Run	; F7F92D  call 0xf417f4
	calr	LCD_ScreenRedraw_End	; F7F931  calr 0xf7e2e7
	ret	; F7F934  ret

; Evidence: reached from calr from prom_b 0xF7F920; calr from prom_b
;           0xF7FA03, and from nothing else the scans see.
; Vel0cityChange_FormatSignedValue: Formats the VEL0CITY CHANGE value (0x0C24) as a sign cell + 3 right-justified
;   digits at 0x2660 (T_Value_ToSignedAsciiDigits3_RightJustified with DE = 127); the BC/HL/XIY/A it then loads are
;   not used by either caller. Paint_Vel0cityChange and Vel0cityChange_DrawValues call it before the value list runs.
;   Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave3_g.json)
Vel0cityChange_FormatSignedValue:
	ld	a, (3108:16)	; F7F935  ld A,(0x0c24)
	xor	w, w	; F7F939  xor W,W
	ldw	de, 127	; F7F93B  ld DE,0x007f
	call	T_Value_ToSignedAsciiDigits3_RightJustified	; F7F93E  call 0xf41af8
	ldw	bc, 4	; F7F942  ld BC,0x0004
	xor	hl, hl	; F7F945  xor HL,HL
	ld	xiy, Value_AsciiSign	; F7F947  ld XIY,0x00002660
	ld	a, 7:opc	; F7F94C  ld A,0x07
	ret	; F7F94E  ret

; ---------------------------------------------------------------------
; ScreenLeaveBody_Vel0cityChange -- the whole body of the Vel0cityChange
;                                   screen's Leave method
;
; Reached by: the +4 method stub of screen object 0xF43080, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D155
; Evidence: the whole body of screen object 0xF43080's +4 method. prom_a's
;           PanelScreen_VtableTable names that object, and its readers take
;           +0 Enter, +4 Leave, +8 Button; the stub at 0xF7D155 is `call
;           0xF7F94F` then `ret` and nothing else calls this address. The
;           screen's own name is round 7's, from its title text.
; ---------------------------------------------------------------------
ScreenLeaveBody_Vel0cityChange:
	call	T_Vel0cityChange_OnLeave	; F7F94F  call 0xf428e4
	ret	; F7F953  ret
ButtonTable_Vel0cityChange_StageZero_Nop0:
	ret	; F7F954  ret   <- button table 0xF7DAD8 entry 0 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageZero_Nop1:
	ret	; F7F955  ret   <- button table 0xF7DAD8 entry 1 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageZero_Nop2:
	ret	; F7F956  ret   <- button table 0xF7DAD8 entry 2 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageZero_Nop3:
	ret	; F7F957  ret   <- button table 0xF7DAD8 entry 3 (VEL0CITY CHANGE)

; ---------------------------------------------------------------------
; SoftKeyCol5_Vel0cityChange_StageZero -- the 5th of the eight SOFT KEYS in the
;           row under the LCD, on the Vel0cityChange_StageZero screen
; Reached by: SW41 "SOFT KEY col 5 lower" (matrix segment 5 bit 0, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6E4 {class 0xA9, code 0x04} -> delivered code 0x84; SW42
;           "SOFT KEY col 5 upper" (matrix segment 5 bit 1, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6E8
;           {class 0xA9, code 0x04} -> delivered code 0x04. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x04 of ButtonTable_Vel0cityChange_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW25 LCD RIGHT 1
;           (top) (segment 3 bit 0, fitted); SW26 LCD RIGHT 2 (segment 3 bit
;           1, fitted); SW33 SOFT KEY col 1 lower (segment 4 bit 0, fitted);
;           SW34 SOFT KEY col 1 upper (segment 4 bit 1, fitted). The model
;           strap is the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW41/SW42 are the two switches of its 5th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW41, so "col 5" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol5_Vel0cityChange_StageZero:
	bit	1, (UI_RequestBits:16)	; F7F958  bit 1,(0x2075)
	jr	z, ScreenLeaveBody_Vel0cityChange_Skip	; F7F95C  jr Z,0xf7f962
	call	T_Blink_Stop	; F7F95E  call 0xf42e24
ScreenLeaveBody_Vel0cityChange_Skip:
	or	(UI_RequestBits:16), 0x08	; F7F962  or (0x2075),0x08
	ld	(3608:16), 1	; F7F967  ld (0x0e18),0x01
	bit	7, w	; F7F96C  bit 0x07,W
	jr	z, ScreenLeaveBody_Vel0cityChange_Skip2	; F7F96F  jr Z,0xf7f977
	call	T_Vel0cityChange_StepFieldDown	; F7F971  call 0xf428fc
	jr	ScreenLeaveBody_Vel0cityChange_Join	; F7F975  jr T,0xf7f97b
ScreenLeaveBody_Vel0cityChange_Skip2:
	call	T_Vel0cityChange_StepFieldUp	; F7F977  call 0xf428f8
ScreenLeaveBody_Vel0cityChange_Join:
	calr	Vel0cityChange_DrawValues	; F7F97B  calr 0xf7f9fb
	ret	; F7F97E  ret
ButtonTable_Vel0cityChange_StageZero_Nop5:
	ret	; F7F97F  ret   <- button table 0xF7DAD8 entry 5 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageZero_Nop6:
	ret	; F7F980  ret   <- button table 0xF7DAD8 entry 6 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageZero_Nop7:
	ret	; F7F981  ret   <- button table 0xF7DAD8 entry 7 (VEL0CITY CHANGE)

; ---------------------------------------------------------------------
; LcdKeyRow1_Vel0cityChange_StageZero -- row 1 of the five key pairs flanking
;           the LCD, on the Vel0cityChange_StageZero screen
; Reached by: SW25 "LCD RIGHT 1 (top)" (matrix segment 3 bit 0, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A2
;           {class 0xA9, code 0x08} -> delivered code 0x08; SW73 "LCD LEFT 1
;           (top)" (matrix segment 9 bit 0, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B71F
;           {class 0xA9, code 0x08} -> delivered code 0x88. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x08 of ButtonTable_Vel0cityChange_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW73 LCD LEFT 1
;           (top) (segment 9 bit 0, fitted); SW81 [no legend: matrix position
;           outside every diode list] (segment 10 bit 0, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW25 is row 1 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow1_Vel0cityChange_StageZero:
	bit	7, w	; F7F982  bit 0x07,W
	jr	z, ScreenLeaveBody_Vel0cityChange_Return	; F7F985  jr Z,0xf7f99b
	cp	(0x0db8:16), 0x01	; F7F987  cp (0x0db8),0x01
	jr	z, ScreenLeaveBody_Vel0cityChange_Return	; F7F98C  jr Z,0xf7f99b
	calr	Blink_DisableThenStop	; F7F98E  calr 0xf7f245
	call	T_Vel0cityChange_StageZero_LcdKeyRow1	; F7F991  call 0xf428e8
	calr	Vel0cityChange_DrawValues	; F7F995  calr 0xf7f9fb
	calr	Vel0cityChange_RedrawFields	; F7F998  calr 0xf7f99c
ScreenLeaveBody_Vel0cityChange_Return:
	ret	; F7F99B  ret

; Evidence: reached from calr from prom_b 0xF7F998; calr from prom_b
;           0xF7F9D2, and from nothing else the scans see.
; Vel0cityChange_RedrawFields: clears the value area (DL_F39551) and redraws the page's fields with
;   T_DLB_Handler_Array8 -- ld xiy, DL_F3AB3B + 0x2E (notes/prom_ab_stage_zero_names.py).
Vel0cityChange_RedrawFields:
	ld	(LCD_CurrentLayer:16), 1	; F7F99C  ld (0x2540),0x01
	calr	ButtonTable_SequencerMedley_Nop	; F7F9A1  calr 0xf7e2d8
	ld	xiy, DL_F39551	; F7F9A4  ld XIY,0x00f39551
	ld	xix, Data_F39559	; F7F9A9  ld XIX,0x00f39559
	call	T_DisplayList_Run	; F7F9AE  call 0xf417f0
	ld	xiy, DL_F3AB3B + 0x2E	; F7F9B2  ld XIY,0x00f3ab69
	call	T_DLB_Handler_Array8	; F7F9B7  call 0xf4181c
	ret	; F7F9BB  ret

; ---------------------------------------------------------------------
; LcdKeyRow2_Vel0cityChange_StageZero -- row 2 of the five key pairs flanking
;           the LCD, on the Vel0cityChange_StageZero screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_Vel0cityChange_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_Vel0cityChange_StageZero:
	bit	7, w	; F7F9BC  bit 0x07,W
	jr	z, LcdKeyRow2_Vel0cityChange_StageZero_Skip	; F7F9BF  jr Z,0xf7f9d7
	cp	(0x0db8:16), 0x02	; F7F9C1  cp (0x0db8),0x02
	jr	z, LcdKeyRow2_Vel0cityChange_StageZero_Return	; F7F9C6  jr Z,0xf7f9de
	calr	Blink_EnableThenStop_Copy	; F7F9C8  calr 0xf7f237
	call	T_Vel0cityChange_StageZero_LcdKeyRow2	; F7F9CB  call 0xf428ec
	calr	Vel0cityChange_DrawValues	; F7F9CF  calr 0xf7f9fb
	calr	Vel0cityChange_RedrawFields	; F7F9D2  calr 0xf7f99c
	jr	LcdKeyRow2_Vel0cityChange_StageZero_Return	; F7F9D5  jr T,0xf7f9de
LcdKeyRow2_Vel0cityChange_StageZero_Skip:
	calr	Blink_DisableThenStop	; F7F9D7  calr 0xf7f245
	call	T_Vel0cityChange_LcdKeyRow2	; F7F9DA  call 0xf42900
LcdKeyRow2_Vel0cityChange_StageZero_Return:
	ret	; F7F9DE  ret

; ---------------------------------------------------------------------
; LcdKeyRow3_Vel0cityChange_StageZero -- row 3 of the five key pairs flanking
;           the LCD, on the Vel0cityChange_StageZero screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_Vel0cityChange_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_Vel0cityChange_StageZero:
	bit	7, w	; F7F9DF  bit 0x07,W
	jr	z, LcdKeyRow3_Vel0cityChange_StageZero_Return2	; F7F9E2  jr Z,0xf7f9fa
	cp	(0x0db8:16), 0x03	; F7F9E4  cp (0x0db8),0x03
	jr	z, LcdKeyRow3_Vel0cityChange_StageZero_Return2	; F7F9E9  jr Z,0xf7f9fa
	calr	Blink_EnableThenStop_Copy	; F7F9EB  calr 0xf7f237
	call	T_Vel0cityChange_StageZero_LcdKeyRow3	; F7F9EE  call 0xf428f0
	calr	Vel0cityChange_DrawValues	; F7F9F2  calr 0xf7f9fb
	calr	Vel0cityChange_RedrawFields	; F7F9F5  calr 0xf7f99c
	jr	LcdKeyRow3_Vel0cityChange_StageZero_Return2	; F7F9F8  jr T,0xf7f9fa
LcdKeyRow3_Vel0cityChange_StageZero_Return2:
	ret	; F7F9FA  ret

; Evidence: reached from calr from prom_b 0xF7F97B; calr from prom_b
;           0xF7F995, and from nothing else the scans see.
; Vel0cityChange_DrawValues: VEL0CITY CHANGE: on layer 0, formats (0x0C24) as signed digits (Vel0cityChange_FormatSignedValue) and runs
;   DL_F3AB3B up to its cursor-box record: the track (0-16/ALL, DisplayListB_Stage+0), two 3-digit values (+1, +3) and
;   a signed value (+5). Every VEL0CITY CHANGE field key calls it after changing a field. Basis: callers + body.
;   (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
Vel0cityChange_DrawValues:
	ld	(LCD_CurrentLayer:16), 0	; F7F9FB  ld (0x2540),0x00
	calr	ButtonTable_SequencerMedley_Nop	; F7FA00  calr 0xf7e2d8
	calr	Vel0cityChange_FormatSignedValue	; F7FA03  calr 0xf7f935
	ld	xiy, DL_F3AB3B	; F7FA06  ld XIY,0x00f3ab3b
	ld	xix, DL_F3AB3B + 0x2E	; F7FA0B  ld XIX,0x00f3ab69
	call	T_DisplayListB_Run	; F7FA10  call 0xf417f4
	ret	; F7FA14  ret

; ---------------------------------------------------------------------
; LcdKeyRow4_Vel0cityChange_StageZero -- row 4 of the five key pairs flanking
;           the LCD, on the Vel0cityChange_StageZero screen
; Reached by: SW28 "LCD RIGHT 4" (matrix segment 3 bit 3, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AE
;           {class 0xA9, code 0x0B} -> delivered code 0x0B; SW76 "LCD LEFT 4"
;           (matrix segment 9 bit 3, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72B
;           {class 0xA9, code 0x0B} -> delivered code 0x8B. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0B of ButtonTable_Vel0cityChange_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW76 LCD LEFT 4
;           (segment 9 bit 3, fitted); SW84 [no legend: matrix position
;           outside every diode list] (segment 10 bit 3, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW28 is row 4 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow4_Vel0cityChange_StageZero:
	bit	7, w	; F7FA15  bit 0x07,W
	jr	z, LcdKeyRow4_Vel0cityChange_StageZero_Return	; F7FA18  jr Z,0xf7fa30
	cp	(0x0db8:16), 0x04	; F7FA1A  cp (0x0db8),0x04
	jr	z, LcdKeyRow4_Vel0cityChange_StageZero_Return	; F7FA1F  jr Z,0xf7fa30
	calr	Blink_EnableThenStop_Copy	; F7FA21  calr 0xf7f237
	call	T_Vel0cityChange_StageZero_LcdKeyRow4	; F7FA24  call 0xf428f4
	calr	Vel0cityChange_DrawValues	; F7FA28  calr 0xf7f9fb
	calr	Vel0cityChange_RedrawFields	; F7FA2B  calr 0xf7f99c
	jr	LcdKeyRow4_Vel0cityChange_StageZero_Return	; F7FA2E  jr T,0xf7fa30
LcdKeyRow4_Vel0cityChange_StageZero_Return:
	ret	; F7FA30  ret
ButtonTable_Vel0cityChange_StageZero_Nop12:
	ret	; F7FA31  ret   <- button table 0xF7DAD8 entry 12 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageZero_Nop13:
	ret	; F7FA32  ret   <- button table 0xF7DAD8 entry 13 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageZero_Nop14:
	ret	; F7FA33  ret   <- button table 0xF7DAD8 entry 14 (VEL0CITY CHANGE)

; ---------------------------------------------------------------------
; ExitKey_Vel0cityChange_StageZero -- the EXIT key on the
;           Vel0cityChange_StageZero screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_Vel0cityChange_StageZero:
	bit	7, w	; F7FA34  bit 0x07,W
	jr	z, ExitKey_Vel0cityChange_StageZero_Skip	; F7FA37  jr Z,0xf7fa3b
	jr	ExitKey_Vel0cityChange_StageZero_Return2	; F7FA39  jr T,0xf7fa41
ExitKey_Vel0cityChange_StageZero_Skip:
	ldw	(UI_Request:16), 32794	; F7FA3B  ld (0x2070),0x801a
ExitKey_Vel0cityChange_StageZero_Return2:
	ret	; F7FA41  ret
ButtonTable_Vel0cityChange_StageZero_Nop16:
	ret	; F7FA42  ret   <- button table 0xF7DAD8 entry 16 (VEL0CITY CHANGE) and 4 more slot(s)

; ---------------------------------------------------------------------
; Vel0cityChange_StageZero_Button21 -- panel button slot 0x15 of
;           Vel0cityChange_StageZero, NOT NAMED
; Unknown:  NO NAME. This routine is registered ONLY at slot 0x15, which is
;           the VARIANT-1 already-held rewrite of base code 0x04 (`add
;           (XIX-1),0x11` at prom_a 0xF8AE7E/0xF8AEF1). The SX-WSA1R is
;           VARIANT 2 (notes/wave7_panel_names_round11.py --variant), and the
;           two rewriting action handlers are variant-1 handlers, so ON THIS
;           MACHINE THE SLOT IS NEVER DELIVERED and the routine is
;           unreachable. On the SX-WSA1, where it can fire, its base 0x04 is
;           the code variant 1 produces from TWO byte-identical group lists --
;           SW25/SW26 (LCD RIGHT) and SW33/SW34 (SOFT KEY col 1), both fitted
;           -- so even there the wire is ambiguous.
; Evidence: the table slot and the screen are re-read from the ROM, and the
;           reachability argument above is reproduced by
;           notes/prom_b_panel_names_round12.py --0x0d (slot 0x0D) and --plan
;           (the rest).
; ---------------------------------------------------------------------
Vel0cityChange_StageZero_Button21:
	bit	1, (UI_RequestBits:16)	; F7FA43  bit 1,(0x2075)
	jr	z, Vel0cityChange_StageZero_Button21_Skip2	; F7FA47  jr Z,0xf7fa4d
	call	T_Blink_Stop	; F7FA49  call 0xf42e24
Vel0cityChange_StageZero_Button21_Skip2:
	or	(UI_RequestBits:16), 0x08	; F7FA4D  or (0x2075),0x08
	ld	(3608:16), 4	; F7FA52  ld (0x0e18),0x04
	bit	7, w	; F7FA57  bit 0x07,W
	jr	z, Vel0cityChange_StageZero_Button21_Skip3	; F7FA5A  jr Z,0xf7fa62
	call	T_Vel0cityChange_StepFieldDown	; F7FA5C  call 0xf428fc
	jr	Vel0cityChange_StageZero_Button21_Join	; F7FA60  jr T,0xf7fa66
Vel0cityChange_StageZero_Button21_Skip3:
	call	T_Vel0cityChange_StepFieldUp	; F7FA62  call 0xf428f8
Vel0cityChange_StageZero_Button21_Join:
	calr	Vel0cityChange_DrawValues	; F7FA66  calr 0xf7f9fb
	ret	; F7FA69  ret
ButtonTable_Vel0cityChange_StageZero_Nop22:
	ret	; F7FA6A  ret   <- button table 0xF7DAD8 entry 22 (VEL0CITY CHANGE) and 4 more slot(s)

; ---------------------------------------------------------------------
; NumberPadKey_Vel0cityChange_StageZero -- the NUMBER PAD on the
;           Vel0cityChange_StageZero screen
; Reached by: code 0x1B from SW9..SW16 NUMBER PAD "0"..NUMBER PAD "7" (segment
;           1 bits 0-7, wire 0xC1, one 8-bit field, no pair position);
;           SW17..SW20 NUMBER PAD "8"..ENTER (segment 2 bits 0-3, wire 0xC2,
;           one 4-bit field, no pair position) -- then prom_a
;           PanelButton_Route `and L,0x1f` at 0xF861AE, then slot 0x1B of the
;           screen's button table.
; Evidence: code 0x1B is emitted only by PanelGroupEventLists_Variant2, from
;           the two number-pad wires, as WHOLE FIELDS with no pair position;
;           variant 1 sends those same wires as class 0xA8 code 0x08, a
;           different event class that never reaches a button table, so no
;           other control can reach this slot under either map. 0x1B - 0x11 =
;           0x0A is not a rewritable base. ★ And the body this forwards to
;           opens `ld A,(0x2267) / cp A,0x0f` -- the same two constants
;           prom_b's own PanelCode_ToSlotAndFlags pairs at 0xF5508C-0xF5509A
;           when it sets flag bit 5 for index 0x1B. All five in-span slot-0x1B
;           handlers do it. Re-derived by notes/prom_b_panel_names_round11.py
;           --selftest.
; ---------------------------------------------------------------------
NumberPadKey_Vel0cityChange_StageZero:
	calr	Vel0cityChange_StageZero_NumberPadKey	; F7FA6B  calr 0xf7faa2
	ret	; F7FA6E  ret
ButtonTable_Vel0cityChange_StageZero_Nop28:
	ret	; F7FA6F  ret   <- button table 0xF7DAD8 entry 28 (VEL0CITY CHANGE) and 3 more slot(s)
ButtonTable_Vel0cityChange_StageNonZero_Nop0:
	ret	; F7FA70  ret   <- button table 0xF7DB58 entry 0 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageNonZero_Nop1:
	ret	; F7FA71  ret   <- button table 0xF7DB58 entry 1 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageNonZero_Nop2:
	ret	; F7FA72  ret   <- button table 0xF7DB58 entry 2 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageNonZero_Nop3:
	ret	; F7FA73  ret   <- button table 0xF7DB58 entry 3 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageNonZero_Nop4:
	ret	; F7FA74  ret   <- button table 0xF7DB58 entry 4 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageNonZero_Nop5:
	ret	; F7FA75  ret   <- button table 0xF7DB58 entry 5 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageNonZero_Nop6:
	ret	; F7FA76  ret   <- button table 0xF7DB58 entry 6 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageNonZero_Nop7:
	ret	; F7FA77  ret   <- button table 0xF7DB58 entry 7 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageNonZero_Nop8:
	ret	; F7FA78  ret   <- button table 0xF7DB58 entry 8 (VEL0CITY CHANGE)

; ---------------------------------------------------------------------
; LcdKeyRow2_Vel0cityChange_StageNonZero -- row 2 of the five key pairs
;           flanking the LCD, on the Vel0cityChange_StageNonZero screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_Vel0cityChange_StageNonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_Vel0cityChange_StageNonZero:
	bit	7, w	; F7FA79  bit 0x07,W
	jr	nz, LcdKeyRow2_Vel0cityChange_StageNonZero_Return3	; F7FA7C  jr NZ,0xf7fa87
	and	(UI_RequestBits:16), 0x6f	; F7FA7E  and (0x2075),0x6f
	call	T_Vel0cityChange_LcdKeyRow2	; F7FA83  call 0xf42900
LcdKeyRow2_Vel0cityChange_StageNonZero_Return3:
	ret	; F7FA87  ret

; ---------------------------------------------------------------------
; LcdKeyRow3_Vel0cityChange_StageNonZero -- row 3 of the five key pairs
;           flanking the LCD, on the Vel0cityChange_StageNonZero screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_Vel0cityChange_StageNonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_Vel0cityChange_StageNonZero:
	bit	7, w	; F7FA88  bit 0x07,W
	jr	nz, LcdKeyRow3_Vel0cityChange_StageNonZero_Return4	; F7FA8B  jr NZ,0xf7fa91
	call	T_Vel0cityChange_StepFieldUp	; F7FA8D  call 0xf428f8
LcdKeyRow3_Vel0cityChange_StageNonZero_Return4:
	ret	; F7FA91  ret
ButtonTable_Vel0cityChange_StageNonZero_Nop11:
	ret	; F7FA92  ret   <- button table 0xF7DB58 entry 11 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageNonZero_Nop12:
	ret	; F7FA93  ret   <- button table 0xF7DB58 entry 12 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageNonZero_Nop13:
	ret	; F7FA94  ret   <- button table 0xF7DB58 entry 13 (VEL0CITY CHANGE)
ButtonTable_Vel0cityChange_StageNonZero_Nop14:
	ret	; F7FA95  ret   <- button table 0xF7DB58 entry 14 (VEL0CITY CHANGE)

; ---------------------------------------------------------------------
; ExitKey_Vel0cityChange_StageNonZero -- the EXIT key on the
;           Vel0cityChange_StageNonZero screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_Vel0cityChange_StageNonZero:
	bit	7, w	; F7FA96  bit 0x07,W
	jr	nz, ExitKey_Vel0cityChange_StageNonZero_Return5	; F7FA99  jr NZ,0xf7fa9f
	call	T_Vel0cityChange_StepFieldUp	; F7FA9B  call 0xf428f8
ExitKey_Vel0cityChange_StageNonZero_Return5:
	ret	; F7FA9F  ret
ButtonTable_Vel0cityChange_StageNonZero_Nop16:
	ret	; F7FAA0  ret   <- button table 0xF7DB58 entry 16 (VEL0CITY CHANGE) and 15 more slot(s)
	ret	; F7FAA1  ret

; Evidence: reached from calr from prom_b 0xF7FA6B, and from nothing else
;           the scans see.
; Vel0cityChange_StageZero_NumberPadKey: the NumberPadKey action of Vel0cityChange_StageZero -- called only by NumberPadKey_Vel0cityChange_StageZero.
Vel0cityChange_StageZero_NumberPadKey:
	ld	a, (8807:16)	; F7FAA2  ld A,(0x2267)
	cp	a, 9	; F7FAA6  cp A,0x09
	jr	ule, Vel0cityChange_StageZero_NumberPadKey_Skip	; F7FAA9  jr ULE,0xf7fab7
	cp	a, 15	; F7FAAB  cp A,0x0f
	jr	z, Vel0cityChange_StageZero_NumberPadKey_Skip2	; F7FAAE  jr Z,0xf7fabc
	cp	a, 128	; F7FAB0  cp A,0x80
	jr	z, Vel0cityChange_StageZero_NumberPadKey_Skip3	; F7FAB3  jr Z,0xf7fac1
	jr	Vel0cityChange_StageZero_NumberPadKey_Join	; F7FAB5  jr T,0xf7fac4
Vel0cityChange_StageZero_NumberPadKey_Skip:
	calr	Blink_SetEnable_1_9	; F7FAB7  calr 0xf7fac8
	jr	Vel0cityChange_StageZero_NumberPadKey_Join	; F7FABA  jr T,0xf7fac4
Vel0cityChange_StageZero_NumberPadKey_Skip2:
	calr	Vel0cityChange_KeypadCommit	; F7FABC  calr 0xf7fad2
	jr	Vel0cityChange_StageZero_NumberPadKey_Join	; F7FABF  jr T,0xf7fac4
Vel0cityChange_StageZero_NumberPadKey_Skip3:
	calr	Vel0cityChange_KeypadSign	; F7FAC1  calr 0xf7fba4
Vel0cityChange_StageZero_NumberPadKey_Join:
	calr	Vel0cityChange_BlinkSelectedField	; F7FAC4  calr 0xf7fbb7
	ret	; F7FAC7  ret

; Evidence: reached from calr from prom_b 0xF7FAB7, and from nothing else
;           the scans see.
Blink_SetEnable_1_9:
	pushw	1	; F7FAC8  push 0x0001
	call	T_Blink_SetEnable	; F7FACB  call 0xf42e28
	inc	2, xsp	; F7FACF  inc 2,XSP
	ret	; F7FAD1  ret

; Evidence: reached from calr from prom_b 0xF7FABC, and from nothing else
;           the scans see.
; Vel0cityChange_KeypadCommit: VEL0CITY CHANGE, keypad code 0x0F: field 4 converts signed (T_AsciiField_ToSignedValue,
;   -127..+127 by the sign cell (0x2820)) into (0x0C1E), saved 0x6034BC, (0x0C24) and Stage+5; fields 2/3 convert
;   1..999 into first (0x0C20, also (0x0C18), saved 0x6034B2) / last (0x0C22) measure, keeping first <= last, saved
;   count 0x6034B4; then T_Blink_Stop and Vel0cityChange_DrawValues. Twin of AdvanceDelay_KeypadCommit. Basis: caller
;   + body + siblings. (notes/naming-pilot-2026-10-06/proposals_wave8_b8.json)
Vel0cityChange_KeypadCommit:
	cp	(0x0db8:16), 0x04	; F7FAD2  cp (0x0db8),0x04
	jr	nz, Vel0cityChange_KeypadCommit_Skip	; F7FAD7  jr NZ,0xf7fae9
	ld	(10278:16), 3	; F7FAD9  ld (0x2826),0x03
	ld	(10276:16), 0	; F7FADE  ld (0x2824),0x00
	call	T_AsciiField_ToSignedValue	; F7FAE3  call 0xf432f4
	jr	Vel0cityChange_KeypadCommit_Join	; F7FAE7  jr T,0xf7faf2
Vel0cityChange_KeypadCommit_Skip:
	ld	(10278:16), 3	; F7FAE9  ld (0x2826),0x03
	call	T_AsciiDigits3_ToValue	; F7FAEE  call 0xf432f0
Vel0cityChange_KeypadCommit_Join:
	cp	(0x0db8:16), 0x02	; F7FAF2  cp (0x0db8),0x02
	jr	z, Vel0cityChange_KeypadCommit_Skip2	; F7FAF7  jr Z,0xf7fb0b
	cp	(0x0db8:16), 0x03	; F7FAF9  cp (0x0db8),0x03
	jr	z, Vel0cityChange_KeypadCommit_Skip4	; F7FAFE  jr Z,0xf7fb38
	cp	(0x0db8:16), 0x04	; F7FB00  cp (0x0db8),0x04
	jrl	z, Vel0cityChange_KeypadCommit_Skip6	; F7FB05  jrl Z,0xf7fb76
	jrl	Vel0cityChange_KeypadCommit_Return	; F7FB08  jrl T,0xf7fba3
Vel0cityChange_KeypadCommit_Skip2:
	cp	wa, 1:i3	; F7FB0B  cp WA,1
	jrl	lt, Vel0cityChange_KeypadCommit_Return	; F7FB0D  jrl LT,0xf7fba3
	cp	wa, 999	; F7FB10  cp WA,0x03e7
	jrl	gt, Vel0cityChange_KeypadCommit_Return	; F7FB14  jrl GT,0xf7fba3
	ld	(3096:16), wa	; F7FB17  ld (0x0c18),WA
	ld	(6304946:24), wa	; F7FB1B  ld (0x6034b2),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7FB20  ld (0x12f7),WA
	cp	wa, (0x0c22:16)	; F7FB24  cp WA,(0x0c22)
	jr	ule, Vel0cityChange_KeypadCommit_Skip3	; F7FB28  jr ULE,0xf7fb32
	ld	(3106:16), wa	; F7FB2A  ld (0x0c22),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7FB2E  ld (0x12f9),WA
Vel0cityChange_KeypadCommit_Skip3:
	ld	(3104:16), wa	; F7FB32  ld (0x0c20),WA
	jr	Vel0cityChange_KeypadCommit_Join2	; F7FB36  jr T,0xf7fb65
Vel0cityChange_KeypadCommit_Skip4:
	cp	wa, 1:i3	; F7FB38  cp WA,1
	jr	lt, Vel0cityChange_KeypadCommit_Return	; F7FB3A  jr LT,0xf7fba3
	cp	wa, 999	; F7FB3C  cp WA,0x03e7
	jr	gt, Vel0cityChange_KeypadCommit_Return	; F7FB40  jr GT,0xf7fba3
	ld	(3106:16), wa	; F7FB42  ld (0x0c22),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7FB46  ld (0x12f9),WA
	cp	wa, (0x0c20:16)	; F7FB4A  cp WA,(0x0c20)
	jr	nc, Vel0cityChange_KeypadCommit_Skip5	; F7FB4E  jr NC,0xf7fb61
	ld	(3104:16), wa	; F7FB50  ld (0x0c20),WA
	ld	(3096:16), wa	; F7FB54  ld (0x0c18),WA
	ld	(6304946:24), wa	; F7FB58  ld (0x6034b2),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7FB5D  ld (0x12f7),WA
Vel0cityChange_KeypadCommit_Skip5:
	ld	(3106:16), wa	; F7FB61  ld (0x0c22),WA
Vel0cityChange_KeypadCommit_Join2:
	ld	wa, (3106:16)	; F7FB65  ld WA,(0x0c22)
	sub	wa, (0x0c20:16)	; F7FB69  sub WA,(0x0c20)
	inc	1, wa	; F7FB6D  inc 1,WA
	ld	(6304948:24), wa	; F7FB6F  ld (0x6034b4),WA
	jr	Vel0cityChange_KeypadCommit_Join4	; F7FB74  jr T,0xf7fb9c
Vel0cityChange_KeypadCommit_Skip6:
	cp	(0x2820:16), 0x2b	; F7FB76  cp (0x2820),0x2b
	jr	z, Vel0cityChange_KeypadCommit_Skip7	; F7FB7B  jr Z,0xf7fb85
	cp	wa, 65409	; F7FB7D  cp WA,0xff81
	jr	lt, Vel0cityChange_KeypadCommit_Return	; F7FB81  jr LT,0xf7fba3
	jr	Vel0cityChange_KeypadCommit_Join3	; F7FB83  jr T,0xf7fb8b
Vel0cityChange_KeypadCommit_Skip7:
	cp	wa, 127	; F7FB85  cp WA,0x007f
	jr	gt, Vel0cityChange_KeypadCommit_Return	; F7FB89  jr GT,0xf7fba3
Vel0cityChange_KeypadCommit_Join3:
	ld	(3102:16), a	; F7FB8B  ld (0x0c1e),A
	ld	(6304956:24), a	; F7FB8F  ld (0x6034bc),A
	ld	(3108:16), a	; F7FB94  ld (0x0c24),A
	ld	(DisplayListB_Stage+5:16), a	; F7FB98  ld (0x12fb),A
Vel0cityChange_KeypadCommit_Join4:
	call	T_Blink_Stop	; F7FB9C  call 0xf42e24
	calr	Vel0cityChange_DrawValues	; F7FBA0  calr 0xf7f9fb
Vel0cityChange_KeypadCommit_Return:
	ret	; F7FBA3  ret

; Evidence: reached from calr from prom_b 0xF7FAC1, and from nothing else
;           the scans see.
; Vel0cityChange_KeypadSign: VEL0CITY CHANGE, keypad code 0x80: while blinking ((0x2075) bit 1) and unless field 4
;   (the signed value) is selected, puts '+' back in the sign cell (0x2820). Twin of prom_a AdvanceDelay_KeypadSign.
;   Basis: caller + body + siblings. (notes/naming-pilot-2026-10-06/proposals_wave8_b8.json)
Vel0cityChange_KeypadSign:
	bit	1, (UI_RequestBits:16)	; F7FBA4  bit 1,(0x2075)
	jr	z, Vel0cityChange_KeypadSign_Return	; F7FBA8  jr Z,0xf7fbb6
	cp	(0x0db8:16), 0x04	; F7FBAA  cp (0x0db8),0x04
	jr	z, Vel0cityChange_KeypadSign_Return	; F7FBAF  jr Z,0xf7fbb6
	ld	(10272:16), 43	; F7FBB1  ld (0x2820),0x2b
Vel0cityChange_KeypadSign_Return:
	ret	; F7FBB6  ret

; Evidence: reached from calr from prom_b 0xF7FAC4, and from nothing else
;           the scans see.
; Vel0cityChange_BlinkSelectedField: VEL0CITY CHANGE: unless (0x2075) bit 1 is clear or (0x2267) = 0x0F, starts the
;   field blink on layer 0 with template BlinkArgPtrs_F7FBE4[(0x0DB8)]. Vel0cityChange_StageZero_NumberPadKey's common
;   tail. Twin of AdvanceDelay_BlinkSelectedField. Basis: caller + body + siblings. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_b8.json)
Vel0cityChange_BlinkSelectedField:
	bit	1, (UI_RequestBits:16)	; F7FBB7  bit 1,(0x2075)
	jr	z, Vel0cityChange_BlinkSelectedField_Return	; F7FBBB  jr Z,0xf7fbe3
	cp	(0x2267:16), 0x0f	; F7FBBD  cp (0x2267),0x0f
	jr	z, Vel0cityChange_BlinkSelectedField_Return	; F7FBC2  jr Z,0xf7fbe3
	xor	xwa, xwa	; F7FBC4  xor XWA,XWA
	ld	a, (3512:16)	; F7FBC6  ld A,(0x0db8)
	sla	xwa, 2	; F7FBCA  sla 0x02,XWA
	ld	(LCD_CurrentLayer:16), 0	; F7FBCD  ld (0x2540),0x00
	ld	xiy, BlinkArgPtrs_F7FBE4	; F7FBD2  ld XIY,0x00f7fbe4
	ld	xiy, (xiy+wa)	; F7FBD7  ld XIY,(XIY+WA)
	push	xiy	; F7FBDC  push XIY
	call	T_Blink_Command	; F7FBDD  call 0xf42e20
	inc	4, xsp	; F7FBE1  inc 4,XSP
Vel0cityChange_BlinkSelectedField_Return:
	ret	; F7FBE3  ret
; ---------------------------------------------------------------------
; BlinkArgPtrs_F7FBE4 -- pointers to blink templates, read through
;                        Blink_Command
;
; Evidence: read by `ld XIY,0x00F7FBE4` at 0xF7FBD2 followed by `ld
;           XIY,(XIY+WA)`, `push XIY` and `call 0xF42E20` --
;           T_Blink_Command, prom_b 0xF0E9CF
;           (notes/FINDINGS-prom_b-field-blink.md). Same shape, same callee
;           and the same two leading NULL entries as prom_a's
;           BlinkArgPtrs_F8024D. FRAMED on purpose: nothing bounds the
;           index, and what the 3 templates it names are for is not
;           established.
; ---------------------------------------------------------------------
BlinkArgPtrs_F7FBE4:
	.long 0x00000000	; F7FBE4  [0]  NULL
	.long 0x00000000	; F7FBE8  [1]  NULL
	.long DL_F3AB3B + 0xF	; F7FBEC  [2]
	.long DL_F3AB3B + 0x19	; F7FBF0  [3]
	.long DL_F3AB3B + 0x23	; F7FBF4  [4]


; ---------------------------------------------------------------------
; Paint_Transp0se -- paints the panel screen whose own title text reads
;                    "TRANSP0SE"
;
; Reached by: the +0 method stub of screen object 0xF43100, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D171
; Evidence: the routine loads XIY = 0xF3B102 and calls the display-list
;           interpreter; the leading run of op-0x1C records in that list
;           spells "TRANSP0SE", and the name is that text CamelCased, with
;           the ROM's own spelling kept (zeros for O's included). The rule
;           is round 7's, calibrated on seven screens prom_a had named
;           independently: notes/prom_b_screens_round8.py --calibrate.
; ---------------------------------------------------------------------
Paint_Transp0se:
	call	T_CallbackQueue_ResetAndRestartTask2	; F7FBF8  call 0xf42e80
	cp	(UI_ScreenStage:16), 0x00	; F7FBFC  cp (0x207e),0x00
	jr	nz, Paint_Transp0se_Join	; F7FC01  jr NZ,0xf7fc36
	call	T_Transp0se_InitFields	; F7FC03  call 0xf42a38
	or	(UI_RequestBits:16), 0x01	; F7FC07  or (0x2075),0x01
	ldw	(PanelDial_DownButton:16), 1156	; F7FC0C  ld (0x209b),0x0484  <- arms prom_a PanelButton_Accept's substitution for panel button code 0x0D (0xF86615); see the 0xF7D2D8 banner
	ldw	(9830:16), 65535	; F7FC12  ld (0x2666),0xffff
	ldw	(9834:16), 65535	; F7FC18  ld (0x266a),0xffff
	ld	a, (3574:16)	; F7FC1E  ld A,(0x0df6)
	cp	a, 2:i3	; F7FC22  cp A,2
	jr	z, Paint_Transp0se_Skip	; F7FC24  jr Z,0xf7fc33
	cp	a, 3:i3	; F7FC26  cp A,3
	jr	z, Paint_Transp0se_Skip	; F7FC28  jr Z,0xf7fc33
	cp	a, 4:i3	; F7FC2A  cp A,4
	jr	z, Paint_Transp0se_Skip	; F7FC2C  jr Z,0xf7fc33
	calr	Blink_DisableThenStop	; F7FC2E  calr 0xf7f245
	jr	Paint_Transp0se_Join	; F7FC31  jr T,0xf7fc36
Paint_Transp0se_Skip:
	calr	Blink_EnableThenStop_Copy	; F7FC33  calr 0xf7f237
Paint_Transp0se_Join:
	calr	LCD_ScreenRedraw_Begin	; F7FC36  calr 0xf7e2d9
	ld	(LCD_CurrentLayer:16), 0	; F7FC39  ld (0x2540),0x00
	cp	(UI_ScreenStage:16), 0x00	; F7FC3E  cp (0x207e),0x00
	jr	nz, Paint_Transp0se_Skip2	; F7FC43  jr NZ,0xf7fc55
	ld	xiy, DL_Transp0seTrackFirstMeasure	; F7FC45  ld XIY,0x00f3b102
	ld	xix, DL_F3B1E3	; F7FC4A  ld XIX,0x00f3b1e3
	call	T_DisplayList_Run	; F7FC4F  call 0xf417f0
	jr	Paint_Transp0se_Join2	; F7FC53  jr T,0xf7fc7f
Paint_Transp0se_Skip2:
	ld	xiy, DL_Transp0seTrackFirstMeasure	; F7FC55  ld XIY,0x00f3b102
	ld	xix, DL_Transp0seTrackFirstMeasure + 0xA4	; F7FC5A  ld XIX,0x00f3b1a6
	call	T_DisplayList_Run	; F7FC5F  call 0xf417f0
	ld	xiy, DL_F3AB9C	; F7FC63  ld XIY,0x00f3ab9c
	ld	xix, DL_QuantizeTrackStrengthFirstMeasure	; F7FC68  ld XIX,0x00f3abdb
	call	T_DisplayList_Run	; F7FC6D  call 0xf417f0
	ld	xiy, DL_AreYouSure	; F7FC71  ld XIY,0x00f3a461
	ld	xix, DL_TrackMergeOkTrackTrackTrack	; F7FC76  ld XIX,0x00f3a47f
	call	T_DisplayList_Run	; F7FC7B  call 0xf417f0
Paint_Transp0se_Join2:
	ld	(LCD_CurrentLayer:16), 0	; F7FC7F  ld (0x2540),0x00
	calr	ButtonTable_SequencerMedley_Nop	; F7FC84  calr 0xf7e2d8
	ld	xiy, DL_F3B1E3	; F7FC87  ld XIY,0x00f3b1e3
	ld	xix, DLBoxes_F3B21C	; F7FC8C  ld XIX,0x00f3b21c
	call	T_DisplayListB_Run	; F7FC91  call 0xf417f4
	calr	LCD_ScreenRedraw_End	; F7FC95  calr 0xf7e2e7
	ret	; F7FC98  ret

; ---------------------------------------------------------------------
; ScreenLeaveBody_Transp0se -- the whole body of the Transp0se screen's
;                              Leave method
;
; Reached by: the +4 method stub of screen object 0xF43100, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D176
; Evidence: the whole body of screen object 0xF43100's +4 method. prom_a's
;           PanelScreen_VtableTable names that object, and its readers take
;           +0 Enter, +4 Leave, +8 Button; the stub at 0xF7D176 is `call
;           0xF7FC99` then `ret` and nothing else calls this address. The
;           screen's own name is round 7's, from its title text.
; ---------------------------------------------------------------------
ScreenLeaveBody_Transp0se:
	call	T_Transp0se_OnLeave	; F7FC99  call 0xf42a3c
	ret	; F7FC9D  ret
ButtonTable_Transp0se_StageZero_Nop0:
	ret	; F7FC9E  ret   <- button table 0xF7DBD8 entry 0 (TRANSP0SE)
ButtonTable_Transp0se_StageZero_Nop1:
	ret	; F7FC9F  ret   <- button table 0xF7DBD8 entry 1 (TRANSP0SE)
ButtonTable_Transp0se_StageZero_Nop2:
	ret	; F7FCA0  ret   <- button table 0xF7DBD8 entry 2 (TRANSP0SE)
ButtonTable_Transp0se_StageZero_Nop3:
	ret	; F7FCA1  ret   <- button table 0xF7DBD8 entry 3 (TRANSP0SE)

; ---------------------------------------------------------------------
; SoftKeyCol5_Transp0se_StageZero -- the 5th of the eight SOFT KEYS in the row
;           under the LCD, on the Transp0se_StageZero screen
; Reached by: SW41 "SOFT KEY col 5 lower" (matrix segment 5 bit 0, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6E4 {class 0xA9, code 0x04} -> delivered code 0x84; SW42
;           "SOFT KEY col 5 upper" (matrix segment 5 bit 1, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6E8
;           {class 0xA9, code 0x04} -> delivered code 0x04. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x04 of ButtonTable_Transp0se_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW25 LCD RIGHT 1
;           (top) (segment 3 bit 0, fitted); SW26 LCD RIGHT 2 (segment 3 bit
;           1, fitted); SW33 SOFT KEY col 1 lower (segment 4 bit 0, fitted);
;           SW34 SOFT KEY col 1 upper (segment 4 bit 1, fitted). The model
;           strap is the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW41/SW42 are the two switches of its 5th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW41, so "col 5" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol5_Transp0se_StageZero:
	bit	1, (UI_RequestBits:16)	; F7FCA2  bit 1,(0x2075)
	jr	z, ScreenLeaveBody_Transp0se_Skip	; F7FCA6  jr Z,0xf7fcac
	call	T_Blink_Stop	; F7FCA8  call 0xf42e24
ScreenLeaveBody_Transp0se_Skip:
	or	(UI_RequestBits:16), 0x08	; F7FCAC  or (0x2075),0x08
	ld	(3608:16), 1	; F7FCB1  ld (0x0e18),0x01
	bit	7, w	; F7FCB6  bit 0x07,W
	jr	z, ScreenLeaveBody_Transp0se_Skip2	; F7FCB9  jr Z,0xf7fcc1
	call	T_Transp0se_StepSelectedFieldDown	; F7FCBB  call 0xf42a54
	jr	ScreenLeaveBody_Transp0se_Join	; F7FCBF  jr T,0xf7fcc5
ScreenLeaveBody_Transp0se_Skip2:
	call	T_Transp0se_StepFieldUp	; F7FCC1  call 0xf42a50
ScreenLeaveBody_Transp0se_Join:
	calr	Transp0se_DrawValues	; F7FCC5  calr 0xf7fd45
	ret	; F7FCC8  ret
ButtonTable_Transp0se_StageZero_Nop5:
	ret	; F7FCC9  ret   <- button table 0xF7DBD8 entry 5 (TRANSP0SE)
ButtonTable_Transp0se_StageZero_Nop6:
	ret	; F7FCCA  ret   <- button table 0xF7DBD8 entry 6 (TRANSP0SE)
ButtonTable_Transp0se_StageZero_Nop7:
	ret	; F7FCCB  ret   <- button table 0xF7DBD8 entry 7 (TRANSP0SE)

; ---------------------------------------------------------------------
; LcdKeyRow1_Transp0se_StageZero -- row 1 of the five key pairs flanking the
;           LCD, on the Transp0se_StageZero screen
; Reached by: SW25 "LCD RIGHT 1 (top)" (matrix segment 3 bit 0, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A2
;           {class 0xA9, code 0x08} -> delivered code 0x08; SW73 "LCD LEFT 1
;           (top)" (matrix segment 9 bit 0, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B71F
;           {class 0xA9, code 0x08} -> delivered code 0x88. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x08 of ButtonTable_Transp0se_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW73 LCD LEFT 1
;           (top) (segment 9 bit 0, fitted); SW81 [no legend: matrix position
;           outside every diode list] (segment 10 bit 0, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW25 is row 1 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow1_Transp0se_StageZero:
	bit	7, w	; F7FCCC  bit 0x07,W
	jr	z, ScreenLeaveBody_Transp0se_Return	; F7FCCF  jr Z,0xf7fce5
	cp	(0x0df6:16), 0x01	; F7FCD1  cp (0x0df6),0x01
	jr	z, ScreenLeaveBody_Transp0se_Return	; F7FCD6  jr Z,0xf7fce5
	calr	Blink_DisableThenStop	; F7FCD8  calr 0xf7f245
	call	T_Transp0se_SelectField1	; F7FCDB  call 0xf42a40
	calr	Transp0se_DrawValues	; F7FCDF  calr 0xf7fd45
	calr	Transp0se_RedrawFields	; F7FCE2  calr 0xf7fce6
ScreenLeaveBody_Transp0se_Return:
	ret	; F7FCE5  ret

; Evidence: reached from calr from prom_b 0xF7FCE2; calr from prom_b
;           0xF7FD1C, and from nothing else the scans see.
; Transp0se_RedrawFields: clears the value area (DL_F39551) and redraws the page's fields with
;   T_DLB_Handler_Array8 -- ld xiy, DL_F3B1E3 + 0x2E (notes/prom_ab_stage_zero_names.py).
Transp0se_RedrawFields:
	ld	(LCD_CurrentLayer:16), 1	; F7FCE6  ld (0x2540),0x01
	calr	ButtonTable_SequencerMedley_Nop	; F7FCEB  calr 0xf7e2d8
	ld	xiy, DL_F39551	; F7FCEE  ld XIY,0x00f39551
	ld	xix, Data_F39559	; F7FCF3  ld XIX,0x00f39559
	call	T_DisplayList_Run	; F7FCF8  call 0xf417f0
	ld	xiy, DL_F3B1E3 + 0x2E	; F7FCFC  ld XIY,0x00f3b211
	call	T_DLB_Handler_Array8	; F7FD01  call 0xf4181c
	ret	; F7FD05  ret

; ---------------------------------------------------------------------
; LcdKeyRow2_Transp0se_StageZero -- row 2 of the five key pairs flanking the
;           LCD, on the Transp0se_StageZero screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_Transp0se_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_Transp0se_StageZero:
	bit	7, w	; F7FD06  bit 0x07,W
	jr	z, LcdKeyRow2_Transp0se_StageZero_Skip	; F7FD09  jr Z,0xf7fd21
	cp	(0x0df6:16), 0x02	; F7FD0B  cp (0x0df6),0x02
	jr	z, LcdKeyRow2_Transp0se_StageZero_Return	; F7FD10  jr Z,0xf7fd28
	calr	Blink_EnableThenStop_Copy	; F7FD12  calr 0xf7f237
	call	T_Transp0se_SelectField2	; F7FD15  call 0xf42a44
	calr	Transp0se_DrawValues	; F7FD19  calr 0xf7fd45
	calr	Transp0se_RedrawFields	; F7FD1C  calr 0xf7fce6
	jr	LcdKeyRow2_Transp0se_StageZero_Return	; F7FD1F  jr T,0xf7fd28
LcdKeyRow2_Transp0se_StageZero_Skip:
	calr	Blink_DisableThenStop	; F7FD21  calr 0xf7f245
	call	T_Transp0se_LcdKeyRow2	; F7FD24  call 0xf42a58
LcdKeyRow2_Transp0se_StageZero_Return:
	ret	; F7FD28  ret

; ---------------------------------------------------------------------
; LcdKeyRow3_Transp0se_StageZero -- row 3 of the five key pairs flanking the
;           LCD, on the Transp0se_StageZero screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_Transp0se_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_Transp0se_StageZero:
	bit	7, w	; F7FD29  bit 0x07,W
	jr	z, LcdKeyRow3_Transp0se_StageZero_Return2	; F7FD2C  jr Z,0xf7fd44
	cp	(0x0df6:16), 0x03	; F7FD2E  cp (0x0df6),0x03
	jr	z, LcdKeyRow3_Transp0se_StageZero_Return2	; F7FD33  jr Z,0xf7fd44
	calr	Blink_EnableThenStop_Copy	; F7FD35  calr 0xf7f237
	call	T_Transp0se_SelectField3	; F7FD38  call 0xf42a48
	calr	Transp0se_DrawValues	; F7FD3C  calr 0xf7fd45
	calr	Transp0se_RedrawFields	; F7FD3F  calr 0xf7fce6
	jr	LcdKeyRow3_Transp0se_StageZero_Return2	; F7FD42  jr T,0xf7fd44
LcdKeyRow3_Transp0se_StageZero_Return2:
	ret	; F7FD44  ret

; Evidence: reached from calr from prom_b 0xF7FCC5; calr from prom_b
;           0xF7FCDF, and from nothing else the scans see.
; Transp0se_DrawValues: TRANSP0SE: on layer 0, runs DL_F3B1E3 up to its cursor-box record: the track (0-16/ALL,
;   DisplayListB_Stage+0), two 3-digit values (+1, +3) and a signed value (+5). Every TRANSP0SE field key calls it
;   after changing a field, then Transp0se_RedrawFields. Basis: callers + body. (wsa1/notes/naming-
;   pilot-2026-10-06/proposals_prom_b.json)
Transp0se_DrawValues:
	ld	(LCD_CurrentLayer:16), 0	; F7FD45  ld (0x2540),0x00
	calr	ButtonTable_SequencerMedley_Nop	; F7FD4A  calr 0xf7e2d8
	ld	xiy, DL_F3B1E3	; F7FD4D  ld XIY,0x00f3b1e3
	ld	xix, DL_F3B1E3 + 0x2E	; F7FD52  ld XIX,0x00f3b211
	call	T_DisplayListB_Run	; F7FD57  call 0xf417f4
	ret	; F7FD5B  ret

; ---------------------------------------------------------------------
; LcdKeyRow4_Transp0se_StageZero -- row 4 of the five key pairs flanking the
;           LCD, on the Transp0se_StageZero screen
; Reached by: SW28 "LCD RIGHT 4" (matrix segment 3 bit 3, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AE
;           {class 0xA9, code 0x0B} -> delivered code 0x0B; SW76 "LCD LEFT 4"
;           (matrix segment 9 bit 3, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72B
;           {class 0xA9, code 0x0B} -> delivered code 0x8B. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0B of ButtonTable_Transp0se_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW76 LCD LEFT 4
;           (segment 9 bit 3, fitted); SW84 [no legend: matrix position
;           outside every diode list] (segment 10 bit 3, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW28 is row 4 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow4_Transp0se_StageZero:
	bit	7, w	; F7FD5C  bit 0x07,W
	jr	z, LcdKeyRow4_Transp0se_StageZero_Return	; F7FD5F  jr Z,0xf7fd77
	cp	(0x0df6:16), 0x04	; F7FD61  cp (0x0df6),0x04
	jr	z, LcdKeyRow4_Transp0se_StageZero_Return	; F7FD66  jr Z,0xf7fd77
	calr	Blink_EnableThenStop_Copy	; F7FD68  calr 0xf7f237
	call	T_Transp0se_SelectField4	; F7FD6B  call 0xf42a4c
	calr	Transp0se_DrawValues	; F7FD6F  calr 0xf7fd45
	calr	Transp0se_RedrawFields	; F7FD72  calr 0xf7fce6
	jr	LcdKeyRow4_Transp0se_StageZero_Return	; F7FD75  jr T,0xf7fd77
LcdKeyRow4_Transp0se_StageZero_Return:
	ret	; F7FD77  ret
ButtonTable_Transp0se_StageZero_Nop12:
	ret	; F7FD78  ret   <- button table 0xF7DBD8 entry 12 (TRANSP0SE)
ButtonTable_Transp0se_StageZero_Nop13:
	ret	; F7FD79  ret   <- button table 0xF7DBD8 entry 13 (TRANSP0SE)
ButtonTable_Transp0se_StageZero_Nop14:
	ret	; F7FD7A  ret   <- button table 0xF7DBD8 entry 14 (TRANSP0SE)

; ---------------------------------------------------------------------
; ExitKey_Transp0se_StageZero -- the EXIT key on the Transp0se_StageZero screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_Transp0se_StageZero:
	bit	7, w	; F7FD7B  bit 0x07,W
	jr	z, ExitKey_Transp0se_StageZero_Skip	; F7FD7E  jr Z,0xf7fd82
	jr	ExitKey_Transp0se_StageZero_Return2	; F7FD80  jr T,0xf7fd88
ExitKey_Transp0se_StageZero_Skip:
	ldw	(UI_Request:16), 32794	; F7FD82  ld (0x2070),0x801a
ExitKey_Transp0se_StageZero_Return2:
	ret	; F7FD88  ret
ButtonTable_Transp0se_StageZero_Nop16:
	ret	; F7FD89  ret   <- button table 0xF7DBD8 entry 16 (TRANSP0SE) and 4 more slot(s)

; ---------------------------------------------------------------------
; Transp0se_StageZero_Button21 -- panel button slot 0x15 of
;           Transp0se_StageZero, NOT NAMED
; Unknown:  NO NAME. This routine is registered ONLY at slot 0x15, which is
;           the VARIANT-1 already-held rewrite of base code 0x04 (`add
;           (XIX-1),0x11` at prom_a 0xF8AE7E/0xF8AEF1). The SX-WSA1R is
;           VARIANT 2 (notes/wave7_panel_names_round11.py --variant), and the
;           two rewriting action handlers are variant-1 handlers, so ON THIS
;           MACHINE THE SLOT IS NEVER DELIVERED and the routine is
;           unreachable. On the SX-WSA1, where it can fire, its base 0x04 is
;           the code variant 1 produces from TWO byte-identical group lists --
;           SW25/SW26 (LCD RIGHT) and SW33/SW34 (SOFT KEY col 1), both fitted
;           -- so even there the wire is ambiguous.
; Evidence: the table slot and the screen are re-read from the ROM, and the
;           reachability argument above is reproduced by
;           notes/prom_b_panel_names_round12.py --0x0d (slot 0x0D) and --plan
;           (the rest).
; ---------------------------------------------------------------------
Transp0se_StageZero_Button21:
	bit	1, (UI_RequestBits:16)	; F7FD8A  bit 1,(0x2075)
	jr	z, Transp0se_StageZero_Button21_Skip2	; F7FD8E  jr Z,0xf7fd94
	call	T_Blink_Stop	; F7FD90  call 0xf42e24
Transp0se_StageZero_Button21_Skip2:
	or	(UI_RequestBits:16), 0x08	; F7FD94  or (0x2075),0x08
	ld	(3608:16), 4	; F7FD99  ld (0x0e18),0x04
	bit	7, w	; F7FD9E  bit 0x07,W
	jr	z, Transp0se_StageZero_Button21_Skip3	; F7FDA1  jr Z,0xf7fda9
	call	T_Transp0se_StepSelectedFieldDown	; F7FDA3  call 0xf42a54
	jr	Transp0se_StageZero_Button21_Join	; F7FDA7  jr T,0xf7fdad
Transp0se_StageZero_Button21_Skip3:
	call	T_Transp0se_StepFieldUp	; F7FDA9  call 0xf42a50
Transp0se_StageZero_Button21_Join:
	calr	Transp0se_DrawValues	; F7FDAD  calr 0xf7fd45
	ret	; F7FDB0  ret
ButtonTable_Transp0se_StageZero_Nop22:
	ret	; F7FDB1  ret   <- button table 0xF7DBD8 entry 22 (TRANSP0SE) and 4 more slot(s)

; ---------------------------------------------------------------------
; NumberPadKey_Transp0se_StageZero -- the NUMBER PAD on the Transp0se_StageZero
;           screen
; Reached by: code 0x1B from SW9..SW16 NUMBER PAD "0"..NUMBER PAD "7" (segment
;           1 bits 0-7, wire 0xC1, one 8-bit field, no pair position);
;           SW17..SW20 NUMBER PAD "8"..ENTER (segment 2 bits 0-3, wire 0xC2,
;           one 4-bit field, no pair position) -- then prom_a
;           PanelButton_Route `and L,0x1f` at 0xF861AE, then slot 0x1B of the
;           screen's button table.
; Evidence: code 0x1B is emitted only by PanelGroupEventLists_Variant2, from
;           the two number-pad wires, as WHOLE FIELDS with no pair position;
;           variant 1 sends those same wires as class 0xA8 code 0x08, a
;           different event class that never reaches a button table, so no
;           other control can reach this slot under either map. 0x1B - 0x11 =
;           0x0A is not a rewritable base. ★ And the body this forwards to
;           opens `ld A,(0x2267) / cp A,0x0f` -- the same two constants
;           prom_b's own PanelCode_ToSlotAndFlags pairs at 0xF5508C-0xF5509A
;           when it sets flag bit 5 for index 0x1B. All five in-span slot-0x1B
;           handlers do it. Re-derived by notes/prom_b_panel_names_round11.py
;           --selftest.
; ---------------------------------------------------------------------
NumberPadKey_Transp0se_StageZero:
	calr	Transp0se_StageZero_NumberPadKey	; F7FDB2  calr 0xf7fde9
	ret	; F7FDB5  ret
ButtonTable_Transp0se_StageZero_Nop28:
	ret	; F7FDB6  ret   <- button table 0xF7DBD8 entry 28 (TRANSP0SE) and 3 more slot(s)
ButtonTable_Transp0se_StageNonZero_Nop0:
	ret	; F7FDB7  ret   <- button table 0xF7DC58 entry 0 (TRANSP0SE)
ButtonTable_Transp0se_StageNonZero_Nop1:
	ret	; F7FDB8  ret   <- button table 0xF7DC58 entry 1 (TRANSP0SE)
ButtonTable_Transp0se_StageNonZero_Nop2:
	ret	; F7FDB9  ret   <- button table 0xF7DC58 entry 2 (TRANSP0SE)
ButtonTable_Transp0se_StageNonZero_Nop3:
	ret	; F7FDBA  ret   <- button table 0xF7DC58 entry 3 (TRANSP0SE)
ButtonTable_Transp0se_StageNonZero_Nop4:
	ret	; F7FDBB  ret   <- button table 0xF7DC58 entry 4 (TRANSP0SE)
ButtonTable_Transp0se_StageNonZero_Nop5:
	ret	; F7FDBC  ret   <- button table 0xF7DC58 entry 5 (TRANSP0SE)
ButtonTable_Transp0se_StageNonZero_Nop6:
	ret	; F7FDBD  ret   <- button table 0xF7DC58 entry 6 (TRANSP0SE)
ButtonTable_Transp0se_StageNonZero_Nop7:
	ret	; F7FDBE  ret   <- button table 0xF7DC58 entry 7 (TRANSP0SE)
ButtonTable_Transp0se_StageNonZero_Nop8:
	ret	; F7FDBF  ret   <- button table 0xF7DC58 entry 8 (TRANSP0SE)

; ---------------------------------------------------------------------
; LcdKeyRow2_Transp0se_StageNonZero -- row 2 of the five key pairs flanking the
;           LCD, on the Transp0se_StageNonZero screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x09 of ButtonTable_Transp0se_StageNonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_Transp0se_StageNonZero:
	bit	7, w	; F7FDC0  bit 0x07,W
	jr	nz, LcdKeyRow2_Transp0se_StageNonZero_Return3	; F7FDC3  jr NZ,0xf7fdce
	and	(UI_RequestBits:16), 0x6f	; F7FDC5  and (0x2075),0x6f
	call	T_Transp0se_LcdKeyRow2	; F7FDCA  call 0xf42a58
LcdKeyRow2_Transp0se_StageNonZero_Return3:
	ret	; F7FDCE  ret

; ---------------------------------------------------------------------
; LcdKeyRow3_Transp0se_StageNonZero -- row 3 of the five key pairs flanking the
;           LCD, on the Transp0se_StageNonZero screen
; Reached by: SW27 "LCD RIGHT 3" (matrix segment 3 bit 2, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AA
;           {class 0xA9, code 0x0A} -> delivered code 0x0A; SW75 "LCD LEFT 3"
;           (matrix segment 9 bit 2, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B727
;           {class 0xA9, code 0x0A} -> delivered code 0x8A. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x0A of ButtonTable_Transp0se_StageNonZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW75 LCD LEFT 3
;           (segment 9 bit 2, fitted); SW83 [no legend: matrix position
;           outside every diode list] (segment 10 bit 2, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW27 is row 3 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow3_Transp0se_StageNonZero:
	bit	7, w	; F7FDCF  bit 0x07,W
	jr	nz, LcdKeyRow3_Transp0se_StageNonZero_Return4	; F7FDD2  jr NZ,0xf7fdd8
	call	T_Transp0se_ReturnToStageZero	; F7FDD4  call 0xf42a5c
LcdKeyRow3_Transp0se_StageNonZero_Return4:
	ret	; F7FDD8  ret
ButtonTable_Transp0se_StageNonZero_Nop11:
	ret	; F7FDD9  ret   <- button table 0xF7DC58 entry 11 (TRANSP0SE)
ButtonTable_Transp0se_StageNonZero_Nop12:
	ret	; F7FDDA  ret   <- button table 0xF7DC58 entry 12 (TRANSP0SE)
ButtonTable_Transp0se_StageNonZero_Nop13:
	ret	; F7FDDB  ret   <- button table 0xF7DC58 entry 13 (TRANSP0SE)
ButtonTable_Transp0se_StageNonZero_Nop14:
	ret	; F7FDDC  ret   <- button table 0xF7DC58 entry 14 (TRANSP0SE)

; ---------------------------------------------------------------------
; ExitKey_Transp0se_StageNonZero -- the EXIT key on the Transp0se_StageNonZero
;           screen
; Reached by: code 0x0F from SW32 EXIT (segment 3 bit 7, wire 0xC3, pair
;           position 1) -- then prom_a PanelButton_Route `and L,0x1f` at
;           0xF861AE, then slot 0x0F of the screen's button table.
; Evidence: code 0x0F's ONLY fitted producer is SW32 EXIT, under BOTH wire
;           maps -- variant 1 sources it from segment 10 bit 7 = SW88, a
;           position no diode list fits -- and no rewrite can reach it,
;           because the action handlers only add 0x11 to a base or clamp to
;           0x19. On the consumer side slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 tables (32 distinct
;           handlers, 0 `ret` stubs); in the 23-entry dispatch family its slot
;           15 is filled in all four too, though there slots 1, 2, 4 and 5 are
;           as well, so the universality argument is the 32-table one. This
;           body opens `bit 0x07,W` and runs only when that bit is CLEAR,
;           which is pair position 1 -- the only position code 0x0F is ever
;           delivered at; 20 of 20 in-span EXIT handlers do the same.
;           Re-derived by notes/prom_b_panel_names_round11.py --selftest.
; ---------------------------------------------------------------------
ExitKey_Transp0se_StageNonZero:
	bit	7, w	; F7FDDD  bit 0x07,W
	jr	nz, ExitKey_Transp0se_StageNonZero_Return5	; F7FDE0  jr NZ,0xf7fde6
	call	T_Transp0se_ReturnToStageZero	; F7FDE2  call 0xf42a5c
ExitKey_Transp0se_StageNonZero_Return5:
	ret	; F7FDE6  ret
ButtonTable_Transp0se_StageNonZero_Nop16:
	ret	; F7FDE7  ret   <- button table 0xF7DC58 entry 16 (TRANSP0SE) and 15 more slot(s)
	ret	; F7FDE8  ret

; Evidence: reached from calr from prom_b 0xF7FDB2, and from nothing else
;           the scans see.
; Transp0se_StageZero_NumberPadKey: the NumberPadKey action of Transp0se_StageZero -- called only by NumberPadKey_Transp0se_StageZero.
Transp0se_StageZero_NumberPadKey:
	ld	a, (8807:16)	; F7FDE9  ld A,(0x2267)
	cp	a, 9	; F7FDED  cp A,0x09
	jr	ule, Transp0se_StageZero_NumberPadKey_Skip	; F7FDF0  jr ULE,0xf7fdfe
	cp	a, 15	; F7FDF2  cp A,0x0f
	jr	z, Transp0se_StageZero_NumberPadKey_Skip2	; F7FDF5  jr Z,0xf7fe03
	cp	a, 128	; F7FDF7  cp A,0x80
	jr	z, Transp0se_StageZero_NumberPadKey_Skip3	; F7FDFA  jr Z,0xf7fe08
	jr	Transp0se_StageZero_NumberPadKey_Join	; F7FDFC  jr T,0xf7fe0b
Transp0se_StageZero_NumberPadKey_Skip:
	calr	Blink_SetEnable_1_10	; F7FDFE  calr 0xf7fe0f
	jr	Transp0se_StageZero_NumberPadKey_Join	; F7FE01  jr T,0xf7fe0b
Transp0se_StageZero_NumberPadKey_Skip2:
	calr	Transp0se_KeypadCommit	; F7FE03  calr 0xf7fe19
	jr	Transp0se_StageZero_NumberPadKey_Join	; F7FE06  jr T,0xf7fe0b
Transp0se_StageZero_NumberPadKey_Skip3:
	calr	Transp0se_KeypadSign	; F7FE08  calr 0xf7fed3
Transp0se_StageZero_NumberPadKey_Join:
	calr	Transp0se_BlinkSelectedField	; F7FE0B  calr 0xf7fee6
	ret	; F7FE0E  ret

; Evidence: reached from calr from prom_b 0xF7FDFE, and from nothing else
;           the scans see.
Blink_SetEnable_1_10:
	pushw	1	; F7FE0F  push 0x0001
	call	T_Blink_SetEnable	; F7FE12  call 0xf42e28
	inc	2, xsp	; F7FE16  inc 2,XSP
	ret	; F7FE18  ret

; Evidence: reached from calr from prom_b 0xF7FE03, and from nothing else
;           the scans see.
; Transp0se_KeypadCommit: TRANSP0SE, keypad code 0x0F: field 4 converts signed (-127..+127 by the sign cell (0x2820))
;   into (0x0DFC), Stage+5 and (0x129C); fields 2/3 convert 1..999 into (0x0DF8) / (0x0DFA), keeping (0x0DF8) <=
;   (0x0DFA), with (0x0E08) = (0x0E00) := (0x0DFA) - (0x0DF8) + 1; then T_Blink_Stop and Transp0se_DrawValues. Twin of
;   AdvanceDelay_KeypadCommit. Basis: caller + body + siblings. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_b8.json)
Transp0se_KeypadCommit:
	cp	(0x0df6:16), 0x04	; F7FE19  cp (0x0df6),0x04
	jr	nz, Transp0se_KeypadCommit_Skip	; F7FE1E  jr NZ,0xf7fe30
	ld	(10278:16), 3	; F7FE20  ld (0x2826),0x03
	ld	(10276:16), 0	; F7FE25  ld (0x2824),0x00
	call	T_AsciiField_ToSignedValue	; F7FE2A  call 0xf432f4
	jr	Transp0se_KeypadCommit_Join	; F7FE2E  jr T,0xf7fe39
Transp0se_KeypadCommit_Skip:
	ld	(10278:16), 3	; F7FE30  ld (0x2826),0x03
	call	T_AsciiDigits3_ToValue	; F7FE35  call 0xf432f0
Transp0se_KeypadCommit_Join:
	cp	(0x0df6:16), 0x02	; F7FE39  cp (0x0df6),0x02
	jr	z, Transp0se_KeypadCommit_Skip2	; F7FE3E  jr Z,0xf7fe51
	cp	(0x0df6:16), 0x03	; F7FE40  cp (0x0df6),0x03
	jr	z, Transp0se_KeypadCommit_Skip4	; F7FE45  jr Z,0xf7fe73
	cp	(0x0df6:16), 0x04	; F7FE47  cp (0x0df6),0x04
	jr	z, Transp0se_KeypadCommit_Skip5	; F7FE4C  jr Z,0xf7fea7
	jrl	Transp0se_KeypadCommit_Return	; F7FE4E  jrl T,0xf7fed2
Transp0se_KeypadCommit_Skip2:
	cp	wa, 1:i3	; F7FE51  cp WA,1
	jr	lt, Transp0se_KeypadCommit_Return	; F7FE53  jr LT,0xf7fed2
	cp	wa, 999	; F7FE55  cp WA,0x03e7
	jr	gt, Transp0se_KeypadCommit_Return	; F7FE59  jr GT,0xf7fed2
	ld	(3576:16), wa	; F7FE5B  ld (0x0df8),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7FE5F  ld (0x12f7),WA
	cp	wa, (0x0dfa:16)	; F7FE63  cp WA,(0x0dfa)
	jr	ule, Transp0se_KeypadCommit_Skip3	; F7FE67  jr ULE,0xf7fe71
	ld	(3578:16), wa	; F7FE69  ld (0x0dfa),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7FE6D  ld (0x12f9),WA
Transp0se_KeypadCommit_Skip3:
	jr	Transp0se_KeypadCommit_Join2	; F7FE71  jr T,0xf7fe93
Transp0se_KeypadCommit_Skip4:
	cp	wa, 1:i3	; F7FE73  cp WA,1
	jr	lt, Transp0se_KeypadCommit_Return	; F7FE75  jr LT,0xf7fed2
	cp	wa, 999	; F7FE77  cp WA,0x03e7
	jr	gt, Transp0se_KeypadCommit_Return	; F7FE7B  jr GT,0xf7fed2
	ld	(3578:16), wa	; F7FE7D  ld (0x0dfa),WA
	ld	(DisplayListB_Stage+3:16), wa	; F7FE81  ld (0x12f9),WA
	cp	wa, (0x0df8:16)	; F7FE85  cp WA,(0x0df8)
	jr	nc, Transp0se_KeypadCommit_Join2	; F7FE89  jr NC,0xf7fe93
	ld	(3576:16), wa	; F7FE8B  ld (0x0df8),WA
	ld	(DisplayListB_Stage+1:16), wa	; F7FE8F  ld (0x12f7),WA
Transp0se_KeypadCommit_Join2:
	ld	wa, (3578:16)	; F7FE93  ld WA,(0x0dfa)
	sub	wa, (0x0df8:16)	; F7FE97  sub WA,(0x0df8)
	inc	1, wa	; F7FE9B  inc 1,WA
	ld	(3592:16), wa	; F7FE9D  ld (0x0e08),WA
	ld	(3584:16), wa	; F7FEA1  ld (0x0e00),WA
	jr	Transp0se_KeypadCommit_Join4	; F7FEA5  jr T,0xf7fecb
Transp0se_KeypadCommit_Skip5:
	cp	(0x2820:16), 0x2b	; F7FEA7  cp (0x2820),0x2b
	jr	z, Transp0se_KeypadCommit_Skip6	; F7FEAC  jr Z,0xf7feb6
	cp	wa, 65409	; F7FEAE  cp WA,0xff81
	jr	lt, Transp0se_KeypadCommit_Return	; F7FEB2  jr LT,0xf7fed2
	jr	Transp0se_KeypadCommit_Join3	; F7FEB4  jr T,0xf7febc
Transp0se_KeypadCommit_Skip6:
	cp	wa, 127	; F7FEB6  cp WA,0x007f
	jr	gt, Transp0se_KeypadCommit_Return	; F7FEBA  jr GT,0xf7fed2
Transp0se_KeypadCommit_Join3:
	ld	(3580:16), a	; F7FEBC  ld (0x0dfc),A
	ld	(DisplayListB_Stage+5:16), a	; F7FEC0  ld (0x12fb),A
	ld	(4764:16), a	; F7FEC4  ld (0x129c),A
	ldw	de, 127	; F7FEC8  ld DE,0x007f
Transp0se_KeypadCommit_Join4:
	call	T_Blink_Stop	; F7FECB  call 0xf42e24
	calr	Transp0se_DrawValues	; F7FECF  calr 0xf7fd45
Transp0se_KeypadCommit_Return:
	ret	; F7FED2  ret

; Evidence: reached from calr from prom_b 0xF7FE08, and from nothing else
;           the scans see.
; Transp0se_KeypadSign: TRANSP0SE, keypad code 0x80: while blinking ((0x2075) bit 1) and unless field 4 (the signed
;   value) is selected, puts '+' back in the sign cell (0x2820). Twin of AdvanceDelay_KeypadSign. Basis: caller + body
;   + siblings. (notes/naming-pilot-2026-10-06/proposals_wave8_b8.json)
Transp0se_KeypadSign:
	bit	1, (UI_RequestBits:16)	; F7FED3  bit 1,(0x2075)
	jr	z, Transp0se_KeypadSign_Return	; F7FED7  jr Z,0xf7fee5
	cp	(0x0df6:16), 0x04	; F7FED9  cp (0x0df6),0x04
	jr	z, Transp0se_KeypadSign_Return	; F7FEDE  jr Z,0xf7fee5
	ld	(10272:16), 43	; F7FEE0  ld (0x2820),0x2b
Transp0se_KeypadSign_Return:
	ret	; F7FEE5  ret

; Evidence: reached from calr from prom_b 0xF7FE0B, and from nothing else
;           the scans see.
; Transp0se_BlinkSelectedField: TRANSP0SE: unless (0x2075) bit 1 is clear or (0x2267) = 0x0F, starts the field blink
;   on layer 0 with template BlinkArgPtrs_F7FF13[(0x0DF6)]. Transp0se_StageZero_NumberPadKey's common tail. Twin of
;   AdvanceDelay_BlinkSelectedField. Basis: caller + body + siblings. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_b8.json)
Transp0se_BlinkSelectedField:
	bit	1, (UI_RequestBits:16)	; F7FEE6  bit 1,(0x2075)
	jr	z, Transp0se_BlinkSelectedField_Return	; F7FEEA  jr Z,0xf7ff12
	cp	(0x2267:16), 0x0f	; F7FEEC  cp (0x2267),0x0f
	jr	z, Transp0se_BlinkSelectedField_Return	; F7FEF1  jr Z,0xf7ff12
	xor	xwa, xwa	; F7FEF3  xor XWA,XWA
	ld	a, (3574:16)	; F7FEF5  ld A,(0x0df6)
	sla	xwa, 2	; F7FEF9  sla 0x02,XWA
	ld	(LCD_CurrentLayer:16), 0	; F7FEFC  ld (0x2540),0x00
	ld	xiy, BlinkArgPtrs_F7FF13	; F7FF01  ld XIY,0x00f7ff13
	ld	xiy, (xiy+wa)	; F7FF06  ld XIY,(XIY+WA)
	push	xiy	; F7FF0B  push XIY
	call	T_Blink_Command	; F7FF0C  call 0xf42e20
	inc	4, xsp	; F7FF10  inc 4,XSP
Transp0se_BlinkSelectedField_Return:
	ret	; F7FF12  ret
; ---------------------------------------------------------------------
; BlinkArgPtrs_F7FF13 -- pointers to blink templates, read through
;                        Blink_Command
;
; Evidence: read by `ld XIY,0x00F7FF13` at 0xF7FF01 followed by `ld
;           XIY,(XIY+WA)`, `push XIY` and `call 0xF42E20` --
;           T_Blink_Command, prom_b 0xF0E9CF
;           (notes/FINDINGS-prom_b-field-blink.md). Same shape, same callee
;           and the same two leading NULL entries as prom_a's
;           BlinkArgPtrs_F8024D. FRAMED on purpose: nothing bounds the
;           index, and what the 3 templates it names are for is not
;           established.
; ---------------------------------------------------------------------
BlinkArgPtrs_F7FF13:
	.long 0x00000000	; F7FF13  [0]  NULL
	.long 0x00000000	; F7FF17  [1]  NULL
	.long DL_F3B1E3 + 0xF	; F7FF1B  [2]
	.long DL_F3B1E3 + 0x19	; F7FF1F  [3]
	.long DL_F3B1E3 + 0x23	; F7FF23  [4]


; ---------------------------------------------------------------------
; Paint_AdvanceDelay -- paints the panel screen whose own title text reads
;                       "ADVANCE/DELAY"
;
; Reached by: the +0 method stub of screen object 0xF43110, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D1D5
; Evidence: the routine loads XIY = 0xF3B294 and calls the display-list
;           interpreter; the leading run of op-0x1C records in that list
;           spells "ADVANCE/DELAY", and the name is that text CamelCased,
;           with the ROM's own spelling kept (zeros for O's included). The
;           rule is round 7's, calibrated on seven screens prom_a had named
;           independently: notes/prom_b_screens_round8.py --calibrate.
; ---------------------------------------------------------------------
Paint_AdvanceDelay:
	call	T_CallbackQueue_ResetAndRestartTask2	; F7FF27  call 0xf42e80
	cp	(UI_ScreenStage:16), 0x00	; F7FF2B  cp (0x207e),0x00
	jr	nz, Paint_AdvanceDelay_Join	; F7FF30  jr NZ,0xf7ff65
	call	T_AdvanceDelay_InitFields	; F7FF32  call 0xf42a60
	or	(UI_RequestBits:16), 0x01	; F7FF36  or (0x2075),0x01
	ldw	(PanelDial_DownButton:16), 1156	; F7FF3B  ld (0x209b),0x0484  <- arms prom_a PanelButton_Accept's substitution for panel button code 0x0D (0xF86615); see the 0xF7D2D8 banner
	ldw	(9830:16), 65535	; F7FF41  ld (0x2666),0xffff
	ldw	(9834:16), 65535	; F7FF47  ld (0x266a),0xffff
	ld	a, (AdvanceDelay_Field:16)	; F7FF4D  ld A,(0x0de5)
	cp	a, 2:i3	; F7FF51  cp A,2
	jr	z, Paint_AdvanceDelay_Skip	; F7FF53  jr Z,0xf7ff62
	cp	a, 3:i3	; F7FF55  cp A,3
	jr	z, Paint_AdvanceDelay_Skip	; F7FF57  jr Z,0xf7ff62
	cp	a, 4:i3	; F7FF59  cp A,4
	jr	z, Paint_AdvanceDelay_Skip	; F7FF5B  jr Z,0xf7ff62
	calr	Blink_DisableThenStop	; F7FF5D  calr 0xf7f245
	jr	Paint_AdvanceDelay_Join	; F7FF60  jr T,0xf7ff65
Paint_AdvanceDelay_Skip:
	calr	Blink_EnableThenStop_Copy	; F7FF62  calr 0xf7f237
Paint_AdvanceDelay_Join:
	calr	LCD_ScreenRedraw_Begin	; F7FF65  calr 0xf7e2d9
	ld	(LCD_CurrentLayer:16), 0	; F7FF68  ld (0x2540),0x00
	ld	xiy, DL_AdvanceDelayTrackFirstMeasure	; F7FF6D  ld XIY,0x00f3b294
	ld	xix, Paint_AdvanceDelay_DL	; F7FF72  ld XIX,0x00f3b33c
	call	T_DisplayList_Run	; F7FF77  call 0xf417f0
	cp	(UI_ScreenStage:16), 0x00	; F7FF7B  cp (0x207e),0x00
	jr	nz, Paint_AdvanceDelay_Skip2	; F7FF80  jr NZ,0xf7ff92
	ld	xiy, Paint_AdvanceDelay_DL	; F7FF82  ld XIY,0x00f3b33c
	ld	xix, DL_F3B379	; F7FF87  ld XIX,0x00f3b379
	call	T_DisplayList_Run	; F7FF8C  call 0xf417f0
	jr	Paint_AdvanceDelay_Join2	; F7FF90  jr T,0xf7ffae
Paint_AdvanceDelay_Skip2:
	ld	xiy, DL_F3A7DA	; F7FF92  ld XIY,0x00f3a7da
	ld	xix, DL_MeasureEraseTrackFirstMeasure	; F7FF97  ld XIX,0x00f3a8f5
	call	T_DisplayList_Run	; F7FF9C  call 0xf417f0
	ld	xiy, DL_AreYouSure	; F7FFA0  ld XIY,0x00f3a461
	ld	xix, DL_TrackMergeOkTrackTrackTrack	; F7FFA5  ld XIX,0x00f3a47f
	call	T_DisplayList_Run	; F7FFAA  call 0xf417f0
Paint_AdvanceDelay_Join2:
	ld	(LCD_CurrentLayer:16), 0	; F7FFAE  ld (0x2540),0x00
	calr	ButtonTable_SequencerMedley_Nop	; F7FFB3  calr 0xf7e2d8
	ld	xiy, DL_F3B379	; F7FFB6  ld XIY,0x00f3b379
	ld	xix, DLBoxes_F3B3B2	; F7FFBB  ld XIX,0x00f3b3b2
	call	T_DisplayListB_Run	; F7FFC0  call 0xf417f4
	calr	LCD_ScreenRedraw_End	; F7FFC4  calr 0xf7e2e7
	ret	; F7FFC7  ret

; ---------------------------------------------------------------------
; ScreenLeaveBody_AdvanceDelay -- the whole body of the AdvanceDelay
;                                 screen's Leave method
;
; Reached by: the +4 method stub of screen object 0xF43110, which prom_a's
;             PanelScreen_VtableTable names.
; Called from: call from prom_b 0xF7D1DA
; Evidence: the whole body of screen object 0xF43110's +4 method. prom_a's
;           PanelScreen_VtableTable names that object, and its readers take
;           +0 Enter, +4 Leave, +8 Button; the stub at 0xF7D1DA is `call
;           0xF7FFC8` then `ret` and nothing else calls this address. The
;           screen's own name is round 7's, from its title text.
; ---------------------------------------------------------------------
ScreenLeaveBody_AdvanceDelay:
	call	T_AdvanceDelay_OnLeave	; F7FFC8  call 0xf42a64
	ret	; F7FFCC  ret
ButtonTable_AdvanceDelay_StageZero_Nop0:
	ret	; F7FFCD  ret   <- button table 0xF7DCD8 entry 0 (ADVANCE/DELAY)
ButtonTable_AdvanceDelay_StageZero_Nop1:
	ret	; F7FFCE  ret   <- button table 0xF7DCD8 entry 1 (ADVANCE/DELAY)
ButtonTable_AdvanceDelay_StageZero_Nop2:
	ret	; F7FFCF  ret   <- button table 0xF7DCD8 entry 2 (ADVANCE/DELAY)
ButtonTable_AdvanceDelay_StageZero_Nop3:
	ret	; F7FFD0  ret   <- button table 0xF7DCD8 entry 3 (ADVANCE/DELAY)

; ---------------------------------------------------------------------
; SoftKeyCol5_AdvanceDelay_StageZero -- the 5th of the eight SOFT KEYS in the
;           row under the LCD, on the AdvanceDelay_StageZero screen
; Reached by: SW41 "SOFT KEY col 5 lower" (matrix segment 5 bit 0, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6E4 {class 0xA9, code 0x04} -> delivered code 0x84; SW42
;           "SOFT KEY col 5 upper" (matrix segment 5 bit 1, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6E8
;           {class 0xA9, code 0x04} -> delivered code 0x04. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x04 of ButtonTable_AdvanceDelay_StageZero.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW25 LCD RIGHT 1
;           (top) (segment 3 bit 0, fitted); SW26 LCD RIGHT 2 (segment 3 bit
;           1, fitted); SW33 SOFT KEY col 1 lower (segment 4 bit 0, fitted);
;           SW34 SOFT KEY col 1 upper (segment 4 bit 1, fitted). The model
;           strap is the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW41/SW42 are the two switches of its 5th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW41, so "col 5" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
SoftKeyCol5_AdvanceDelay_StageZero:
	bit	1, (UI_RequestBits:16)	; F7FFD1  bit 1,(0x2075)
	jr	z, SoftKeyCol5_AdvanceDelay_StageZero_Skip	; F7FFD5  jr Z,0xf7ffdb
	call	T_Blink_Stop	; F7FFD7  call 0xf42e24
SoftKeyCol5_AdvanceDelay_StageZero_Skip:
	or	(UI_RequestBits:16), 0x08	; F7FFDB  or (0x2075),0x08
	ld	(3608:16), 1	; F7FFE0  ld (0x0e18),0x01
	bit	7, w	; F7FFE5  bit 0x07,W
	jr	z, SoftKeyCol5_AdvanceDelay_StageZero_Skip2	; F7FFE8  jr Z,0xf7fff0
	call	T_AdvanceDelay_StepFieldDown	; F7FFEA  call 0xf42a7c
	jr	SoftKeyCol5_AdvanceDelay_StageZero_Skip3	; F7FFEE  jr T,0xf7fff4
SoftKeyCol5_AdvanceDelay_StageZero_Skip2:
	call	T_AdvanceDelay_StepFieldUp	; F7FFF0  call 0xf42a78
SoftKeyCol5_AdvanceDelay_StageZero_Skip3:
	calr	AdvanceDelay_DrawValues - 0xF7FFF7	; F7FFF4  calr 0xf80086
	ret	; F7FFF7  ret
ButtonTable_AdvanceDelay_StageZero_Nop5:
	ret	; F7FFF8  ret   <- button table 0xF7DCD8 entry 5 (ADVANCE/DELAY)
ButtonTable_AdvanceDelay_StageZero_Nop6:
	ret	; F7FFF9  ret   <- button table 0xF7DCD8 entry 6 (ADVANCE/DELAY)
ButtonTable_AdvanceDelay_StageZero_Nop7:
	ret	; F7FFFA  ret   <- button table 0xF7DCD8 entry 7 (ADVANCE/DELAY)

; ---------------------------------------------------------------------
; LcdKeyRow1_AdvanceDelay_StageZero -- row 1 of the five key pairs flanking the
;           LCD, on the AdvanceDelay_StageZero screen
; Reached by: SW25 "LCD RIGHT 1 (top)" (matrix segment 3 bit 0, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A2
;           {class 0xA9, code 0x08} -> delivered code 0x08; SW73 "LCD LEFT 1
;           (top)" (matrix segment 9 bit 0, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B71F
;           {class 0xA9, code 0x08} -> delivered code 0x88. prom_a
;           PanelButton_Route then does `and L,0x1f` at 0xF861AE and prom_a
;           PanelButton_CallTableEntry masks it AGAIN and indexes the table -- `and L,0x1f /
;           sla 0x02,L / ld XIX,(XIX+L) / call (XIX)` at 0xF8BDEA-0xF8BDF5 --
;           so this is slot 0x08 of ButtonTable_AdvanceDelay_StageZero.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW73 LCD LEFT 1
;           (top) (segment 9 bit 0, fitted); SW81 [no legend: matrix position
;           outside every diode list] (segment 10 bit 0, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW25 is row 1 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow1_AdvanceDelay_StageZero:
	bit	7, w	; F7FFFB  bit 0x07,W
	jr	z, AdvanceDelay_SelectField1_Ret - 0xF80000	; F7FFFE  jr Z,0xf80019

; ★ RENAMED 2026-08-30 from `end`.  It is an end-of-image marker -- the
; address one past the last byte -- and nothing in this tree references it,
; but prom_a and prom_b both called it `end` and they are ONE program in one
; address space, so the joined listing had two labels of that name for two
; different addresses.  Checked, not assumed: notes/maincpu_join_probe.py
; --selftest asserts nothing uses the symbol and that it is the last thing in
; each file.  ⚠ prom_c still spells it `end`; that image is another lane's.
prom_b_image_end:
