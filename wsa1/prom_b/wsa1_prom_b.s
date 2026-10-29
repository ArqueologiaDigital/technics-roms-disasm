	.text

; ==============================================================================
; Technics SX-WSA1R -- wsa1_prom_b.ic13
; Target CPU: Toshiba TMP95C061 (TLCS-900/H), "CPU 1" / IC1
; ==============================================================================
;
; IC13, the second program EPROM on CPU 1's bus, base 0xF00000.
;
; ⚠ The base is now CONFIRMED, not inferred.  Four independent proofs are
; written out in prom_b/prom_b.ld; the short form is that prom_a's interrupt
; vectors, its reset path, a PC-relative call across the boundary and the
; expansion-board probe's thunk all land on well-formed code in this image at
; exactly this base, and none of them survives a one-byte error in it.
;
; prom_a + prom_b are ONE contiguous 1 MiB image on CS2.  This half is not a
; boot image: its own file 0x7FF00 holds only 3 vector-shaped words, and its
; 0x7FFF0 -- where the other three images carry a lowercase `wsaX_NNN` build
; tag -- is code.
;
; STATUS: partially converted.  Converted so far, as real assembly:
;   0xF01800-0xF3E15B  129 spans of UI DISPLAY-LIST data (39,329 bytes) -- the
;                      machine's screen text and layout, in records.  Each record
;                      is rendered with the field layout of the interpreter that
;                      RUNS it; there are two, and they do not share a layout.
;                      13 of the gaps between the spans (999 bytes) hold the
;                      operand tables those records point at, and are decoded
;                      here too -- including the 64 eight-character resonator
;                      names at 0xF03241.
;   0xF0E800-0xF0EA9E  the FIELD-BLINK ENGINE -- 16 labels: 11 routines, 4
;                      dispatch arms reached only by `jp`, and a 12-entry
;                      command table.  Blinks at 1.27 Hz; the whole clock chain
;                      is re-derived by notes/prom_b_blink_rate.py.  The two
;                      display-list record TEMPLATES it patches on the stack are
;                      at 0xF78000, below.
;   0xF31800-0xF32708  BOTH display-list interpreters, their handler tables, the
;                      quantiser, 29 value glyphs and 3 fixed bitmaps
;   0xF40000-0xF44017  the THUNK TABLE -- the image's routine directory
;   0xF44018-0xF477FF  THE MODULE THAT OPENS RIGHT AFTER IT -- 128 routines and
;                      two data objects, 14,312 bytes.  64 thunk slots point in,
;                      resolving to 62 distinct targets; three adjacent runs with
;                      the highest summed reference count in the image (129).
;                      Dispatch_3629's 5 pointers (two of them dead) and the
;                      161-byte WorkspaceDefaults that seeds 0x00603400.
;   0xF55000-0xF5535A  nine parameter-edit primitives and table accessors, four
;                      of them named by top-ranked thunk slots
;   0xF5535B-0xF5553E  two more of the same family: IndexedParam_AdjustField and
;                      IndexedParam_SetBit, which resolve their target through
;                      IndexedTable_GetPtr and journal every change
;   0xF5B8B6-0xF5BAB7  two selector dispatchers and their 48-entry tables
;   0xF5BBE7-0xF62BFF  THE 96-STEP ROUNDING MAPS and the code that uses them --
;                      the whole span, 28,697 bytes, closed in one piece.  113
;                      routines, 11 data objects: seven 96-entry maps whose entry
;                      k is `g * round(k / g)` for g = 96, 48, 24, 12, 32, 16 and
;                      8 (with 96 written as 0x7F), their 7-pointer selector
;                      table, a 32-byte identity map, and the two 36-byte lists
;                      of the maps' own step boundaries.  Every one of the 17
;                      thunk slots that point into the span lands on an
;                      instruction boundary of the transcription.
;   0xF62C00-0xF64FFF  THE BLOCK STORE -- a heap of chained 256-byte blocks,
;                      the 3-byte directory at 0x00603500 that names their
;                      chains, and the 3 KiB workspace at 0x00603400 that is
;                      banked to 0x00610000 + n*0xC00.  49 thunk slots point
;                      into it, including the two most-referenced unconverted
;                      targets in the image.  Three data islands inside it are
;                      emitted as .byte; 1,008 bytes of 0x0E tail as .fill.
;   0xF78000-0xF78028  the two interpreter-B record templates and the eight-space
;                      blank the blink engine erases with
;   0xF7D000-0xF7E2D7  a stub/veneer block and 32 tables of 32 routine pointers
;
; ⚠ ADDED 2026-08-25 (round 5), AND THE LIST ABOVE WAS ALREADY THREE MODULES
; STALE when this was written -- 0xF47800-0xF4EFFF (round 3),
; 0xF5A800-0xF5B7FF (round 1) and 0xF65000-0xF6D001 (round 4) are all converted
; in this file and none of them appears above.  A status list nobody owns goes
; stale silently; scripts/analysis/source_coverage.py is the number that cannot.
;   0xF47800-0xF4EFFF  eight modules at the head of the 0x047800 span (round 3)
;   0xF5A800-0xF5B7FF  SERIAL CHANNEL 1 -- one 4 KiB module, three interrupt
;                      vectors (round 1)
;   0xF65000-0xF6D001  three modules at the head of the 0x065000 span (round 4)
;   0xF0EA9F-0xF13D33  THE BLOCK THE FRONTIER'S TOP RUN POINTS INTO -- 21,141
;                      bytes, of which 13,357 BYTES are code, in 21 code
;                      segments holding 5,067 INSTRUCTIONS (2.64 bytes each).
;                      ⚠ CORRECTED 2026-08-25 (round-2 audit F2): this line
;                      read "13,357 of them decoded instructions", which was
;                      the BYTE total of the code segments -- the figure in the
;                      `bytes` column of the LAYOUT table below -- worn as an
;                      instruction count, a 2.6x overstatement.  The
;                      instruction figure comes from
;                      `python3 notes/prom_b_instr_census.py --module f0ea9f`,
;                      which decodes every code segment and checks its starts
;                      against this file's own address comments (0 missing,
;                      0 extra).  135 routines, 23 pointer tables classified
;                      TRANSFER/DEREF/STRIDED/UNKNOWN by what the firmware DOES
;                      with an entry, 6 byte maps and no `.fill` at all.  Every
;                      routine header carries a PROVENANCE GRADE.  Read
;                      notes/FINDINGS-prom_b-f0ea9f-module.md sec.2 before
;                      reusing the 0xF65000 method anywhere: three of its rules
;                      produce false code here and two more had to be switched
;                      off.
;   0xF6D002-0xF77FFF  THE PERFORMANCE / ACCOMPANIMENT SCREEN LAYER (round 6)
;                      -- 45,054 bytes, 44,189 of them substantive and 865 an
;                      asserted `.fill` of 0x0E.  32,569 BYTES of code in 75
;                      segments, holding 11,299 INSTRUCTIONS (2.88 bytes each,
;                      `python3 notes/prom_b_instr_census.py --module f6d002`).
;                      316 routines, 104 data objects, every routine
;                      `sub_XXXXXX`.  ⚠ CHOSEN WITH A DIFFERENT TOOL: the thunk
;                      frontier ranks this span THIRTEENTH (2 slots, extent 4);
;                      notes/prom_b_span_frontier.py ranks it FIRST, on 76
;                      distinct already-proven call targets -- more than every
;                      other unconverted prom_b span put together.  Contains a
;                      STANDARD MIDI FILE reader whose parse is decoded and
;                      checked (notes/prom_b_smf_reader.py, 40 checks).
;   0xF17559-0xF1B3FF  THE COMBINATION / INTERNAL SOUND / MIDI SOUND PARAMETER
;                      SCREENS (round 3, wave 7) -- 16,039 bytes, 299 objects,
;                      no code at all.  297 labels, every header with an
;                      Evidence: line; 33 display lists named from their own
;                      captions.  Carries the EIGHT corrections
;                      notes/prom_b_f17559_reaudit.py established.
;                      notes/gen_prom_b_f17559_module.py, --selftest 53 checks.
;   0xF4F000-0xF54FFF  THE NINE-DRAWBAR ORGAN REGISTRATION SCREEN and the two
;                      table modules in front of it (round 3, wave 7) -- 24,576
;                      bytes, the largest `.incbin` that was left in this image.
;                      118 labels, 76 of them semantic; every header carries an
;                      Evidence: line.  notes/gen_prom_b_f4f000_module.py, whose
;                      --selftest is 104 checks.
;   0xF147AC-0xF14FAB  EffectNames -- 128 entries of 16 characters, 56 real
;                      effect names and 72 `----------` placeholders
;   0xF15024-0xF157A7  EffectParamNames -- the effect parameter labels
;   0xF14FAC-0xF15023  DL_EffectParamPage -- the DSP EFFECT screen's eight
;                      parameter-name rows, eight interpreter-B records of 15
;                      (wave 8).  With EffectParamDescriptors_F12F24 and
;                      DspEffect_LoadParamNames it closes `entry k of
;                      EffectNames is effect algorithm k` --
;                      notes/FINDINGS-prom_b-dsp-effect-parameters.md.
;   0xF3C947-0xF3C991  (wave 2, lane PROMBCONV) the STEP-RECORD "part select"
;                      list's last 5 records -- 4 interpreter-A + 1
;                      interpreter-B -- plus the 4-entry, 7-char string table
;                      (CHORD/MELODY/CONTROL/RHYTHM) the B record's own +7/
;                      +0x0B fields name.  Not a new format; wave 1's naive
;                      interp-A walk did not know interpreter B's op 0x02.
;                      notes/gen_prom_b_f3c947_module.py.
;   0xF3D5E5-0xF3DA6E  (wave 2) a 64-entry FIXED-STRIDE field/pointer array
;                      (15 bytes/entry) plus the three small string tables its
;                      own pointer fields name -- chromatic note letters, 32
;                      chord-quality suffixes, 4 tail suffixes.  Not a new
;                      format either: "op 0x2B" was never an opcode, just the
;                      byte after a fixed 15-byte stride, proved by the walk
;                      landing exactly on the note table regardless of one
;                      entry's stray length-shaped byte.
;                      notes/gen_prom_b_f3d5e5_module.py.
;   0xF3F400-0xF3FFFF  (wave 2) a THIRD record format, cracked: [op,len-of-
;                      payload] back to back, op 0xFF a 2-byte section
;                      terminator.  413 steps with zero drift land exactly on
;                      a verified 672-byte 0x00 pad running to the image's own
;                      end.  64 of the records (op 0x00-0x3F, once each) are a
;                      uniform 32-byte slot table; field semantics deferred.
;                      notes/gen_prom_b_f3f400_module.py.
; â ADDED 2026-09-02 (lane promB1):
;   0xF00C4D-0xF017FF  THE LARGEST `.incbin` THIS IMAGE HAD LEFT -- 2,995 bytes,
;                      28% of prom_b's whole verbatim debt.  Three objects and a
;                      two-byte remainder, not one thing: 21 `.long` closing the
;                      pointer array that starts at 0xF00C46; 2,124 bytes of CODE
;                      in 828 instructions, 0 of them left as `.byte`; a
;                      196-entry pointer array in 18-slot records; and 2 bytes
;                      REFUSED at the site, because the entry they begin cannot
;                      be completed without overrunning the display list at
;                      0xF01800.
;                      â THE CODE IS UNREACHED AND ITS CALL TARGETS ARE NOT
;                      prom_a ENTRY POINTS.  Read the ANOMALY section of
;                      notes/gen_prom_b_f00c4d_module.py before naming anything
;                      in it -- naming a routine after what its target does in
;                      the prom_a we have would invent a whole module of
;                      semantics.  --selftest is 20 checks; the reference census,
;                      with a positive control for each instrument, is
;                      notes/prom_b_f00c4d_xrefs.py.
; Everything else is still .incbin, so it builds byte-exact by construction and
; asserts nothing.  The gate (scripts/analysis/assert_byte_identical.py) must
; print PASS after every edit.
;
; PROVENANCE: this is not a chip read.  It is the publicly redistributed v2
; firmware set (../technics_roms/roms/wsa1/PROVENANCE.md).

; ------------------------------------------------------------------------------
; THE TLCS-900 BYTE-EMITTER MACROS -- the same file prom_a and the kernel use.
;
; ★ WHY THIS FILE NOW HAS THEM.  This image was generated with a decoder that
; wrote every operand llvm-mc's tlcs900 backend has no spelling for as a raw
; `.byte` row with the disassembler's text in the comment:
;
;     .byte 0xC1, 0xB8, 0x20, 0x3F, 0x11	; F0003C  cp (0x20b8),0x11   [llvm-mc cannot encode this]
;
; prom_a wrote the SAME BYTES as `m_cp_mi8 MB16, 0x20b8, 0x11`, because prom_a
; developed the macro set.  Sharing that set retires those rows here.  The
; instruction that replaces a row emits exactly the bytes the row held -- the
; byte gate is what says so -- and the `; ADDR <disassembler text>` comment,
; which is the DECODE AUTHORITY for every line in this file, is kept verbatim.
;
; ⚠ The `[llvm-mc cannot encode this]` marker is dropped on a converted row and
;   only there: it explained why the row was a `.byte`, and a row that is no
;   longer a `.byte` no longer needs the excuse.  Every row still spelled
;   `.byte` keeps its marker.  Counted by notes/promb_macro_rewrite.py --census.
; ------------------------------------------------------------------------------
	.include "include/tmp95c061_sfr.inc"
	.include "include/tlcs900_mem_ops.inc"
	.include "include/wsa1_ram.inc"
	.include "include/wsa1_gui.inc"	; the display-list record macros (dl_*, dlb_*) and LCDSVC_* service numbers

; >>> BEGIN prom_a ADDRESS EQUATES (generated by scripts/converters/symbolize_wsa1_rom_addresses.py)
; prom_a is linked separately, so prom_b cannot name its labels directly.  Each
; line below is a prom_a label and the address prom_a's own ELF gives it; prom_b's
; `jp`/`call`/`.long` operands into prom_a use these names instead of numbers.
; The byte gate protects every VALUE (it is encoded in the operand that uses it);
; it does NOT protect a NAME.  After any prom_a rename run
;     python3 scripts/converters/symbolize_wsa1_rom_addresses.py --check-equates
; Never edit by hand: re-run the tool with --apply, which rewrites this block.
	.set	AdvanceDelay_SelectField1_Ret, 0xf80019
	.set	LcdKeyRow2_AdvanceDelay_StageZero, 0xf8003a
	.set	LcdKeyRow3_AdvanceDelay_StageZero, 0xf80059
	.set	AdvanceDelay_DrawValues, 0xf80086
	.set	LcdKeyRow4_AdvanceDelay_StageZero, 0xf8009d
	.set	ButtonTable_AdvanceDelay_StageZero_Nop12, 0xf800be
	.set	ButtonTable_AdvanceDelay_StageZero_Nop13, 0xf800bf
	.set	ButtonTable_AdvanceDelay_StageZero_Nop14, 0xf800c0
	.set	ExitKey_AdvanceDelay_StageZero, 0xf800c1
	.set	ButtonTable_AdvanceDelay_StageZero_Nop16, 0xf800cf
	.set	AdvanceDelay_StageZero_Button21, 0xf800d0
	.set	ButtonTable_AdvanceDelay_StageZero_Nop22, 0xf800f7
	.set	NumberPadKey_AdvanceDelay_StageZero, 0xf800f8
	.set	ButtonTable_AdvanceDelay_StageZero_Nop28, 0xf800fc
	.set	ButtonTable_AdvanceDelay_StageNonZero_Nop0, 0xf800fd
	.set	ButtonTable_AdvanceDelay_StageNonZero_Nop1, 0xf800fe
	.set	ButtonTable_AdvanceDelay_StageNonZero_Nop2, 0xf800ff
	.set	ButtonTable_AdvanceDelay_StageNonZero_Nop3, 0xf80100
	.set	ButtonTable_AdvanceDelay_StageNonZero_Nop4, 0xf80101
	.set	ButtonTable_AdvanceDelay_StageNonZero_Nop5, 0xf80102
	.set	ButtonTable_AdvanceDelay_StageNonZero_Nop6, 0xf80103
	.set	ButtonTable_AdvanceDelay_StageNonZero_Nop7, 0xf80104
	.set	ButtonTable_AdvanceDelay_StageNonZero_Nop8, 0xf80105
	.set	ButtonTable_AdvanceDelay_StageNonZero_Nop9, 0xf80106
	.set	LcdKeyRow3_AdvanceDelay_StageNonZero, 0xf80107
	.set	LcdKeyRow4_AdvanceDelay_StageNonZero, 0xf80116
	.set	ButtonTable_AdvanceDelay_StageNonZero_Nop12, 0xf80120
	.set	ButtonTable_AdvanceDelay_StageNonZero_Nop13, 0xf80121
	.set	ButtonTable_AdvanceDelay_StageNonZero_Nop14, 0xf80122
	.set	ExitKey_AdvanceDelay_StageNonZero, 0xf80123
	.set	ButtonTable_AdvanceDelay_StageNonZero_Nop16, 0xf8012d
	.set	Paint_S0ngC0py, 0xf80261
	.set	ScreenLeave_S0ngC0py_Nop, 0xf803c8
	.set	SoftKeyCol1_S0ngC0py_StageZero, 0xf803c9
	.set	SoftKeyCol2_S0ngC0py_StageZero, 0xf803d2
	.set	SoftKeyCol3_S0ngC0py_StageZero, 0xf803db
	.set	SoftKeyCol4_S0ngC0py_StageZero, 0xf803e4
	.set	SoftKeyCol5_S0ngC0py_StageZero, 0xf803ed
	.set	SoftKeyCol6_S0ngC0py_StageZero, 0xf803f6
	.set	SoftKeyCol7_S0ngC0py_StageZero, 0xf803ff
	.set	SoftKeyCol8_S0ngC0py_StageZero, 0xf80408
	.set	ButtonTable_S0ngC0py_StageZero_Nop8, 0xf80411
	.set	LcdKeyRow2_S0ngC0py_StageZero, 0xf80412
	.set	ButtonTable_S0ngC0py_StageZero_Nop10, 0xf80417
	.set	ExitKey_S0ngC0py_StageZero, 0xf80418
	.set	ButtonTable_S0ngC0py_StageZero_Nop16, 0xf80426
	.set	ButtonTable_S0ngC0py_StageNonZero_Nop0, 0xf80427
	.set	LcdKeyRow2_S0ngC0py_StageNonZero, 0xf80428
	.set	LcdKeyRow3_S0ngC0py_StageNonZero, 0xf8042d
	.set	ButtonTable_S0ngC0py_StageNonZero_Nop11, 0xf80432
	.set	ExitKey_S0ngC0py_StageNonZero, 0xf80433
	.set	ButtonTable_S0ngC0py_StageNonZero_Nop16, 0xf80438
	.set	Paint_N0teChange, 0xf80439
	.set	ScreenLeaveBody_N0teChange, 0xf804ec
	.set	ButtonTable_N0teChange_StageZero_Nop0, 0xf804f1
	.set	ButtonTable_N0teChange_StageZero_Nop1, 0xf804f2
	.set	ButtonTable_N0teChange_StageZero_Nop2, 0xf804f3
	.set	ButtonTable_N0teChange_StageZero_Nop3, 0xf804f4
	.set	SoftKeyCol5_N0teChange_StageZero, 0xf804f5
	.set	ButtonTable_N0teChange_StageZero_Nop5, 0xf8051c
	.set	ButtonTable_N0teChange_StageZero_Nop6, 0xf8051d
	.set	ButtonTable_N0teChange_StageZero_Nop7, 0xf8051e
	.set	LcdKeyRow2_N0teChange_StageZero, 0xf8051f
	.set	LcdKeyRow3_N0teChange_StageZero, 0xf80569
	.set	LcdKeyRow4_N0teChange_StageZero, 0xf80595
	.set	ButtonTable_N0teChange_StageZero_Nop12, 0xf805cf
	.set	ButtonTable_N0teChange_StageZero_Nop13, 0xf805d0
	.set	ButtonTable_N0teChange_StageZero_Nop14, 0xf805d1
	.set	ExitKey_N0teChange_StageZero, 0xf805d2
	.set	ButtonTable_N0teChange_StageZero_Nop16, 0xf805e0
	.set	N0teChange_StageZero_Button21, 0xf805e1
	.set	ButtonTable_N0teChange_StageZero_Nop22, 0xf80608
	.set	NumberPadKey_N0teChange_StageZero, 0xf80609
	.set	ButtonTable_N0teChange_StageZero_Nop28, 0xf8060d
	.set	ButtonTable_N0teChange_StageNonZero_Nop0, 0xf8060e
	.set	LcdKeyRow4_N0teChange_StageNonZero, 0xf8060f
	.set	LcdKeyRow5_N0teChange_StageNonZero, 0xf80619
	.set	ButtonTable_N0teChange_StageNonZero_Nop13, 0xf80623
	.set	ExitKey_N0teChange_StageNonZero, 0xf80624
	.set	ButtonTable_N0teChange_StageNonZero_Nop16, 0xf80629
	.set	Paint_MeasureC0py, 0xf8076c
	.set	ScreenLeaveBody_MeasureC0py, 0xf80809
	.set	ButtonTable_MeasureC0py_StageZero_Nop0, 0xf8080e
	.set	ButtonTable_MeasureC0py_StageZero_Nop1, 0xf8080f
	.set	ButtonTable_MeasureC0py_StageZero_Nop2, 0xf80810
	.set	ButtonTable_MeasureC0py_StageZero_Nop3, 0xf80811
	.set	SoftKeyCol5_MeasureC0py_StageZero, 0xf80812
	.set	ButtonTable_MeasureC0py_StageZero_Nop5, 0xf8084c
	.set	ButtonTable_MeasureC0py_StageZero_Nop6, 0xf8084d
	.set	ButtonTable_MeasureC0py_StageZero_Nop7, 0xf8084e
	.set	LcdKeyRow1_MeasureC0py_StageZero, 0xf8084f
	.set	LcdKeyRow2_MeasureC0py_StageZero, 0xf8085c
	.set	LcdKeyRow3_MeasureC0py_StageZero, 0xf808b1
	.set	LcdKeyRow4_MeasureC0py_StageZero, 0xf808e6
	.set	ButtonTable_MeasureC0py_StageZero_Nop12, 0xf8091b
	.set	ButtonTable_MeasureC0py_StageZero_Nop13, 0xf8091c
	.set	ButtonTable_MeasureC0py_StageZero_Nop14, 0xf8091d
	.set	ExitKey_MeasureC0py_StageZero, 0xf8091e
	.set	ButtonTable_MeasureC0py_StageZero_Nop16, 0xf8092c
	.set	MeasureC0py_StageZero_Button21, 0xf8092d
	.set	ButtonTable_MeasureC0py_StageZero_Nop22, 0xf80967
	.set	NumberPadKey_MeasureC0py_StageZero, 0xf80968
	.set	ButtonTable_MeasureC0py_StageZero_Nop28, 0xf8096c
	.set	ButtonTable_MeasureC0py_StageNonZero_Nop0, 0xf8096d
	.set	ButtonTable_MeasureC0py_StageNonZero_Nop1, 0xf8096e
	.set	ButtonTable_MeasureC0py_StageNonZero_Nop2, 0xf8096f
	.set	ButtonTable_MeasureC0py_StageNonZero_Nop3, 0xf80970
	.set	ButtonTable_MeasureC0py_StageNonZero_Nop4, 0xf80971
	.set	ButtonTable_MeasureC0py_StageNonZero_Nop5, 0xf80972
	.set	ButtonTable_MeasureC0py_StageNonZero_Nop6, 0xf80973
	.set	ButtonTable_MeasureC0py_StageNonZero_Nop7, 0xf80974
	.set	LcdKeyRow1_MeasureC0py_StageNonZero, 0xf80975
	.set	ButtonTable_MeasureC0py_StageNonZero_Nop9, 0xf80984
	.set	ButtonTable_MeasureC0py_StageNonZero_Nop10, 0xf80985
	.set	LcdKeyRow5_MeasureC0py_StageNonZero, 0xf80986
	.set	ButtonTable_MeasureC0py_StageNonZero_Nop13, 0xf80990
	.set	ButtonTable_MeasureC0py_StageNonZero_Nop14, 0xf80991
	.set	ExitKey_MeasureC0py_StageNonZero, 0xf80992
	.set	ButtonTable_MeasureC0py_StageNonZero_Nop16, 0xf8099c
	.set	Paint_MeasureInsert, 0xf80ac9
	.set	ScreenLeaveBody_MeasureInsert, 0xf80b66
	.set	ButtonTable_MeasureInsert_StageZero_Nop0, 0xf80b6b
	.set	ButtonTable_MeasureInsert_StageZero_Nop1, 0xf80b6c
	.set	ButtonTable_MeasureInsert_StageZero_Nop2, 0xf80b6d
	.set	ButtonTable_MeasureInsert_StageZero_Nop3, 0xf80b6e
	.set	SoftKeyCol5_MeasureInsert_StageZero, 0xf80b6f
	.set	ButtonTable_MeasureInsert_StageZero_Nop5, 0xf80ba9
	.set	ButtonTable_MeasureInsert_StageZero_Nop6, 0xf80baa
	.set	ButtonTable_MeasureInsert_StageZero_Nop7, 0xf80bab
	.set	LcdKeyRow1_MeasureInsert_StageZero, 0xf80bac
	.set	LcdKeyRow2_MeasureInsert_StageZero, 0xf80bb9
	.set	LcdKeyRow3_MeasureInsert_StageZero, 0xf80c0e
	.set	LcdKeyRow4_MeasureInsert_StageZero, 0xf80c43
	.set	ButtonTable_MeasureInsert_StageZero_Nop12, 0xf80c78
	.set	ButtonTable_MeasureInsert_StageZero_Nop13, 0xf80c79
	.set	ButtonTable_MeasureInsert_StageZero_Nop14, 0xf80c7a
	.set	ExitKey_MeasureInsert_StageZero, 0xf80c7b
	.set	ButtonTable_MeasureInsert_StageZero_Nop16, 0xf80c89
	.set	MeasureInsert_StageZero_Button21, 0xf80c8a
	.set	ButtonTable_MeasureInsert_StageZero_Nop22, 0xf80cc4
	.set	NumberPadKey_MeasureInsert_StageZero, 0xf80cc5
	.set	ButtonTable_MeasureInsert_StageZero_Nop28, 0xf80cc9
	.set	ButtonTable_MeasureInsert_StageNonZero_Nop0, 0xf80cca
	.set	ButtonTable_MeasureInsert_StageNonZero_Nop1, 0xf80ccb
	.set	ButtonTable_MeasureInsert_StageNonZero_Nop2, 0xf80ccc
	.set	ButtonTable_MeasureInsert_StageNonZero_Nop3, 0xf80ccd
	.set	ButtonTable_MeasureInsert_StageNonZero_Nop4, 0xf80cce
	.set	ButtonTable_MeasureInsert_StageNonZero_Nop5, 0xf80ccf
	.set	ButtonTable_MeasureInsert_StageNonZero_Nop6, 0xf80cd0
	.set	ButtonTable_MeasureInsert_StageNonZero_Nop7, 0xf80cd1
	.set	LcdKeyRow1_MeasureInsert_StageNonZero, 0xf80cd2
	.set	ButtonTable_MeasureInsert_StageNonZero_Nop9, 0xf80ce1
	.set	ButtonTable_MeasureInsert_StageNonZero_Nop10, 0xf80ce2
	.set	ButtonTable_MeasureInsert_StageNonZero_Nop11, 0xf80ce3
	.set	LcdKeyRow5_MeasureInsert_StageNonZero, 0xf80ce4
	.set	ButtonTable_MeasureInsert_StageNonZero_Nop13, 0xf80cee
	.set	ButtonTable_MeasureInsert_StageNonZero_Nop14, 0xf80cef
	.set	ExitKey_MeasureInsert_StageNonZero, 0xf80cf0
	.set	ButtonTable_MeasureInsert_StageNonZero_Nop16, 0xf80cfa
	.set	Paint_S0ngSelectName, 0xf80e2e
	.set	ScreenLeaveBody_S0ngSelectName, 0xf80eaf
	.set	ScreenButtonBody_S0ngSelectName, 0xf80eb4
	.set	ModeEnterBody_StepRecord, 0xf80f3a
	.set	sub_F80F4F, 0xf80f4f
	.set	Paint_StepRecordPartSelect, 0xf80f5a
	.set	ScreenLeaveBody_StepRecordPartSelect, 0xf80fc0
	.set	SoftKeyCol1_StepRecordPartSelect, 0xf80fc5
	.set	SoftKeyCol2_StepRecordPartSelect, 0xf80fce
	.set	SoftKeyCol3_StepRecordPartSelect, 0xf80fd7
	.set	SoftKeyCol4_StepRecordPartSelect, 0xf80fe0
	.set	SoftKeyCol5_StepRecordPartSelect, 0xf80fe9
	.set	SoftKeyCol6_StepRecordPartSelect, 0xf80ff2
	.set	SoftKeyCol7_StepRecordPartSelect, 0xf80ffb
	.set	SoftKeyCol8_StepRecordPartSelect, 0xf81004
	.set	ButtonTable_StepRecordPartSelect_Nop8, 0xf8100d
	.set	ButtonTable_StepRecordPartSelect_Nop9, 0xf8100e
	.set	ExitKey_StepRecordPartSelect, 0xf8100f
	.set	ButtonTable_StepRecordPartSelect_Nop16, 0xf8101d
	.set	ScreenEnterBody_StepRecord, 0xf8101e
	.set	ScreenLeaveBody_StepRecord, 0xf81039
	.set	Paint_SequencerMedley, 0xf81048
	.set	ScreenLeaveBody_SequencerMedley, 0xf810f0
	.set	ButtonTable_SequencerMedley_Nop0, 0xf81101
	.set	SoftKeyCol2_SequencerMedley, 0xf81102
	.set	SoftKeyCol3_SequencerMedley, 0xf8111e
	.set	ButtonTable_SequencerMedley_Nop3, 0xf81136
	.set	SoftKeyCol5_SequencerMedley, 0xf81137
	.set	ButtonTable_SequencerMedley_Nop5, 0xf81165
	.set	SoftKeyCol7_SequencerMedley, 0xf81166
	.set	SoftKeyCol8_SequencerMedley, 0xf81185
	.set	ButtonTable_SequencerMedley_Nop8, 0xf8119d
	.set	LcdKeyRow2_SequencerMedley, 0xf8119e
	.set	LcdKeyRow3_SequencerMedley, 0xf811e2
	.set	LcdKeyRow4_SequencerMedley, 0xf811ff
	.set	ExitKey_SequencerMedley, 0xf81224
	.set	ButtonTable_SequencerMedley_Nop12, 0xf81230
	.set	NumberPadKey_SequencerMedley, 0xf81231
	.set	ButtonTable_SequencerMedley_Nop28, 0xf81235
	.set	SongStore_MeasureSongSize, 0xf819e9
	.set	Paint_StepRecord, 0xf81acb
	.set	Paint_StepRecordTrackClrMeas, 0xf81bd4
	.set	sub_F81C15, 0xf81c15
	.set	sub_F81C33, 0xf81c33
	.set	sub_F81C90, 0xf81c90
	.set	sub_F81D41, 0xf81d41
	.set	LCD_ClearLayer2_32Cols10Rows_Nop, 0xf81e7c
	.set	sub_F81E7E, 0xf81e7e
	.set	MainTask_PhaseVector, 0xf82010
	.set	MainTask_Loop, 0xf82028
	.set	Queue2C00_DrainPassAB, 0xf823ac
	.set	Queue2C00_DrainPassB, 0xf823c8
	.set	TimedEvents_DrainDue, 0xf82407
	.set	SeqBuf_FlushStaged, 0xf82557
	.set	Ring601850_ServiceIfNotEmpty, 0xf825c7
	.set	T_F4001C_Nop, 0xf8262e
	.set	ModuleInit_Phase0Veneer, 0xf82630
	.set	ModuleInit_Phase1Veneer, 0xf82634
	.set	ModuleInit_Phase2Veneer, 0xf82638
	.set	MainTask_Entry, 0xf827c8
	.set	Dev7F_WriteSlot8_Slot0, 0xf83171
	.set	Dev7F_WriteSlot8_Slot1, 0xf83179
	.set	Dev7F_WriteSlot8_Slot2, 0xf83181
	.set	Dev7F_WriteSlot8_Slot3, 0xf83189
	.set	Ring608A0A_Get, 0xf842df
	.set	Ring608A0A_Put, 0xf842ed
	.set	Ring608A0A_PutBlock, 0xf84304
	.set	Ring608A0A_IsEmpty, 0xf84327
	.set	Ring608A0A_Init, 0xf8433c
	.set	Ring608A0A_ScanRewind, 0xf8434a
	.set	Ring608A0A_Scan, 0xf84357
	.set	Ring608A0A_ScanToPut, 0xf84366
	.set	Ring608A0A_GetCommit, 0xf84375
	.set	Ring60480A_Get, 0xf84382
	.set	Ring60480A_Put, 0xf84390
	.set	Ring60480A_PutBlock, 0xf843a7
	.set	Ring60480A_IsEmpty, 0xf843ca
	.set	Ring60480A_Init, 0xf843df
	.set	Ring60480A_ScanRewind, 0xf843ed
	.set	Ring60480A_Scan, 0xf843fa
	.set	Ring60480A_ScanToPut, 0xf84409
	.set	Ring60480A_GetCommit, 0xf84418
	.set	Ring601B64_Get, 0xf84425
	.set	Ring601B64_Put, 0xf84433
	.set	Ring601B64_PutBlock, 0xf8444a
	.set	Ring601B64_IsEmpty, 0xf8446d
	.set	Ring601B64_Init, 0xf84482
	.set	Ring601B64_ScanRewind, 0xf84490
	.set	Ring601B64_Scan, 0xf8449d
	.set	Ring601B64_ScanToPut, 0xf844ac
	.set	Ring601B64_GetCommit, 0xf844bb
	.set	Ring60000C_Get, 0xf844c8
	.set	Ring60000C_Put, 0xf844d6
	.set	Ring60000C_PutBlock, 0xf844ed
	.set	Ring60000C_IsEmpty, 0xf84510
	.set	Ring60000C_Init, 0xf84525
	.set	Ring60000C_ScanRewind, 0xf84533
	.set	Ring60000C_Scan, 0xf84540
	.set	Ring60000C_ScanToPut, 0xf8454f
	.set	Ring60000C_GetCommit, 0xf8455e
	.set	TimedEventRing_Get, 0xf8456b
	.set	TimedEventRing_Put, 0xf84579
	.set	TimedEventRing_PutBlock, 0xf84590
	.set	TimedEventRing_IsEmpty, 0xf845b3
	.set	TimedEventRing_Init, 0xf845c8
	.set	TimedEventRing_ScanRewind, 0xf845d6
	.set	TimedEventRing_Scan, 0xf845e3
	.set	TimedEventRing_ScanToPut, 0xf845f2
	.set	TimedEventRing_GetCommit, 0xf84601
	.set	SeqBufRing_Get, 0xf8460e
	.set	SeqBufRing_Put, 0xf8461c
	.set	SeqBufRing_PutBlock, 0xf84633
	.set	SeqBufRing_IsEmpty, 0xf84656
	.set	SeqBufRing_Init, 0xf8466b
	.set	SeqBufRing_ScanRewind, 0xf84679
	.set	SeqBufRing_Scan, 0xf84686
	.set	SeqBufRing_ScanToPut, 0xf84695
	.set	SeqBufRing_GetCommit, 0xf846a4
	.set	MidiInARing_Get, 0xf846b1
	.set	MidiInARing_Put, 0xf846bf
	.set	MidiInARing_PutBlock, 0xf846d6
	.set	MidiInARing_IsEmpty, 0xf846f9
	.set	MidiInARing_Init, 0xf8470e
	.set	MidiInARing_ScanRewind, 0xf8471c
	.set	MidiInARing_Scan, 0xf84729
	.set	MidiInARing_ScanToPut, 0xf84738
	.set	MidiInARing_GetCommit, 0xf84747
	.set	MidiInBRing_Get, 0xf84754
	.set	MidiInBRing_Put, 0xf84762
	.set	MidiInBRing_PutBlock, 0xf84779
	.set	MidiInBRing_IsEmpty, 0xf8479c
	.set	MidiInBRing_Init, 0xf847b1
	.set	MidiInBRing_ScanRewind, 0xf847bf
	.set	MidiInBRing_Scan, 0xf847cc
	.set	MidiInBRing_ScanToPut, 0xf847db
	.set	MidiInBRing_GetCommit, 0xf847ea
	.set	Ring601432_Get, 0xf847f7
	.set	Ring601432_Put, 0xf84805
	.set	Ring601432_PutBlock, 0xf8481c
	.set	Ring601432_IsEmpty, 0xf8483f
	.set	Ring601432_Init, 0xf84854
	.set	Ring601432_ScanRewind, 0xf84862
	.set	Ring601432_Scan, 0xf8486f
	.set	Ring601432_ScanToPut, 0xf8487e
	.set	Ring601432_GetCommit, 0xf8488d
	.set	Ring60153C_Get, 0xf8489a
	.set	Ring60153C_Put, 0xf848a8
	.set	Ring60153C_PutBlock, 0xf848bf
	.set	Ring60153C_IsEmpty, 0xf848e2
	.set	Ring60153C_Init, 0xf848f7
	.set	Ring60153C_ScanRewind, 0xf84905
	.set	Ring60153C_Scan, 0xf84912
	.set	Ring60153C_ScanToPut, 0xf84921
	.set	Ring60153C_GetCommit, 0xf84930
	.set	Ring60195A_Get, 0xf8493d
	.set	Ring60195A_Put, 0xf8494b
	.set	Ring60195A_PutBlock, 0xf84962
	.set	Ring60195A_IsEmpty, 0xf84985
	.set	Ring60195A_Init, 0xf8499a
	.set	Ring60195A_ScanRewind, 0xf849a8
	.set	Ring60195A_Scan, 0xf849b5
	.set	Ring60195A_ScanToPut, 0xf849c4
	.set	Ring60195A_GetCommit, 0xf849d3
	.set	Ring601646_Get, 0xf849e0
	.set	Ring601646_Put, 0xf849ee
	.set	Ring601646_PutBlock, 0xf84a05
	.set	Ring601646_IsEmpty, 0xf84a28
	.set	Ring601646_Init, 0xf84a3d
	.set	Ring601646_ScanRewind, 0xf84a4b
	.set	Ring601646_Scan, 0xf84a58
	.set	Ring601646_ScanToPut, 0xf84a67
	.set	Ring601646_GetCommit, 0xf84a76
	.set	Ring601C6E_Get, 0xf84a83
	.set	Ring601C6E_Put, 0xf84a91
	.set	Ring601C6E_PutBlock, 0xf84aa8
	.set	Ring601C6E_IsEmpty, 0xf84acb
	.set	Ring601C6E_Init, 0xf84ae0
	.set	Ring601C6E_ScanRewind, 0xf84aee
	.set	Ring601C6E_Scan, 0xf84afb
	.set	Ring601C6E_ScanToPut, 0xf84b0a
	.set	Ring601C6E_GetCommit, 0xf84b19
	.set	Ring601850_Get, 0xf84b26
	.set	Ring601850_Put, 0xf84b34
	.set	Ring601850_PutBlock, 0xf84b4b
	.set	Ring601850_IsEmpty, 0xf84b6e
	.set	Ring601850_Init, 0xf84b83
	.set	Ring601850_ScanRewind, 0xf84b91
	.set	Ring601850_Scan, 0xf84b9e
	.set	Ring601850_ScanToPut, 0xf84bad
	.set	Ring601850_GetCommit, 0xf84bbc
	.set	INTT3_KernelTick, 0xf85600
	.set	Kernel_InitRam, 0xf85606
	.set	IRQ_Epilogue, 0xf857b7
	.set	Kernel_StartTask_StackArg, 0xf857d6
	.set	Kernel_StartTask, 0xf857d9
	.set	Kernel_ExitTask, 0xf8584a
	.set	Kernel_YieldRotate_StackArg, 0xf85874
	.set	Kernel_YieldRotate, 0xf85877
	.set	Kernel_RotateQueue, 0xf858c0
	.set	Kernel_BlockSelf, 0xf85904
	.set	Kernel_ReadyTask_StackArg, 0xf8592a
	.set	Kernel_ReadyTask, 0xf8592d
	.set	Kernel_ReadyTask_NoDispatch, 0xf8596d
	.set	Kernel_SemaSignal_StackArg, 0xf859ab
	.set	Kernel_SemaSignal, 0xf859ae
	.set	Kernel_SemaSignal_NoDispatch, 0xf85a22
	.set	Kernel_SemaWait_StackArg, 0xf85a93
	.set	Kernel_SemaWait, 0xf85a96
	.set	Kernel_SemaTryWait, 0xf85aef
	.set	MsgQueue_Send_StackArg, 0xf85b0d
	.set	MsgQueue_Send, 0xf85b1f
	.set	MsgQueue_Send_NoDispatch, 0xf85bd4
	.set	MsgQueue_ReceiveBlocking_StackArg, 0xf85c89
	.set	MsgQueue_ReceiveBlocking, 0xf85c8c
	.set	MsgQueue_Receive_NoBlock, 0xf85d1c
	.set	Kernel_SetTaskLevel_StackArg, 0xf85da2
	.set	Kernel_SetTaskLevel, 0xf85da8
	.set	Kernel_SetTaskLevel_NoDispatch, 0xf85e02
	.set	Kernel_KillTask_StackArg, 0xf85e5b
	.set	Kernel_KillTask, 0xf85e5e
	.set	DSP_ChannelRegs_Write8, 0xf85f59
	.set	DSP_WriteAllChannelRegs, 0xf85f7c
	.set	PanelTask_EntryVectors, 0xf86000
	.set	PanelTask_Step, 0xf86066
	.set	UiEventList_Publish, 0xf860a6
	.set	UiEvent_RouteByCode, 0xf8659b
	.set	PanelEvent_Code03, 0xf865bc
	.set	PanelTimers_Step, 0xf86903
	.set	UiEventList_RunPassA, 0xf8697e
	.set	UiEventList_RunPassB, 0xf8699d
	.set	UiEventList_RunPassC, 0xf869bc
	.set	Queue2C00_AppendRegs, 0xf86a81
	.set	Queue2E00_AppendRegs, 0xf86aa3
	.set	List2030_AppendRegs, 0xf86ac7
	.set	PanelState_CheckRequestAllowed, 0xf86ae9
	.set	EditValue_ApplyStep, 0xf86b43
	.set	EditStep_UseCurveA, 0xf86b6f
	.set	EditStep_UseCurveC, 0xf86b7f
	.set	PanelEvent_Code01_ArmHold, 0xf86bc0
	.set	PanelEvent_ReadPayload_F86BF4, 0xf86bf4
	.set	PanelEvent_ReadPayload_F86C01, 0xf86c01
	.set	PanelEvent_Code20_ArmHold, 0xf86c0e
	.set	PanelEvent_NoOp_T40F88, 0xf86c59
	.set	PanelEvent_NoOp_T40F8C, 0xf86c5a
	.set	PanelEvent_NoOp_T40F94, 0xf86c5b
	.set	PanelHold_Tick, 0xf86c5c
	.set	Ctrl_Normalise, 0xf89800
	.set	Ctrl_Nop_Ret, 0xf89804
	.set	PanelWire_EntryThunks, 0xf8a000
	.set	PanelWire_Service, 0xf8a023
	.set	T_F40618_Nop, 0xf8a027
	.set	PanelEvent_PhaseVector, 0xf8a800
	.set	PanelEvent_Service, 0xf8a81d
	.set	FixedEventList_AppendStackArgs, 0xf8bc00
	.set	EventQueue_AppendStackArgs, 0xf8bc04
	.set	PendingEventQueue_AppendStackArgs, 0xf8bc08
	.set	AsciiDigits3_ToValue, 0xf8bc0c
	.set	AsciiField_ToSignedValue, 0xf8bc67
	.set	AsciiField_Clear, 0xf8bc78
	.set	Value_ToAsciiDigits3_LeftJustified, 0xf8bc8a
	.set	Value_ToAsciiDigits3_RightJustified, 0xf8bcaf
	.set	Value_ToSignedAsciiDigits3_RightJustified, 0xf8bcc9
	.set	Value_ToSignedAsciiDigits3_LeftJustified, 0xf8bcd0
	.set	Value_ToAsciiDigits3, 0xf8bcd7
	.set	Value_ApplyNibbleDeltaClamped, 0xf8bd73
	.set	PanelButton_CallTableEntry, 0xf8bdc5
	.set	PanelButton_CallPageTableEntry, 0xf8bdf8
	.set	PanelLed_PhaseVector, 0xf8c000
	.set	PanelLed_OnPartEvent, 0xf8c032
	.set	PanelLed_OnClass20Event, 0xf8c04e
	.set	PanelLed_OnClass90Event, 0xf8c071
	.set	T_F40684_Nop, 0xf8c095
	.set	T_F40688_Nop, 0xf8c096
	.set	PanelLed_OnClassA8Event, 0xf8c097
	.set	T_F40690_Nop, 0xf8c0b3
	.set	PanelLed_OnClass98Event, 0xf8c0b4
	.set	PanelLed_OnCtrlParamEvent, 0xf8c0d0
	.set	PanelLed_ProcessRequests, 0xf8c18b
	.set	PanelLed_Refresh, 0xf8c338
	.set	PanelLed_ToggleActivityLed, 0xf8c3fb
	.set	PanelLed_SendByte, 0xf8c842
	.set	PanelLed_SendByteUnconditional, 0xf8c846
	.set	T_F4066C_Nop, 0xf8c8c2
	.set	PanelLed_FlashTransportBeat, 0xf8c8c3
	.set	Task2_CallbackDispatcher, 0xf8da00
	.set	CallbackQueue_Post, 0xf8da16
	.set	CallbackQueue_ResetAndRestartTask2, 0xf8da83
	.set	AnalogScan_PhaseVector, 0xf8dc00
	.set	AnalogScan_All, 0xf8dc25
	.set	LinkSelector1_NoAction, 0xf8e000
	.set	Link_Init_DmaAndTimer, 0xf8e001
	.set	Link_SendBlockIn32ByteChunks, 0xf8e02c
	.set	Link_SendCommandE2, 0xf8e0fe
	.set	Link_SendCommand3_WaitTicks, 0xf8e1fe
	.set	Link_SendCommand5_WaitDone, 0xf8e222
	.set	Link_SendCommandE1, 0xf8e26f
	.set	Link_SendCommandE4, 0xf8e320
	.set	Link_SendCommandE7, 0xf8e3d1
	.set	INT0_LinkByte, 0xf8e47f
	.set	INTTC2_uDMA2Done, 0xf8e52d
	.set	INTTC3_LinkDmaDone, 0xf8e54f
	.set	Link_ServiceTask, 0xf8e5f6
	.set	Link_WaitBlockDone, 0xf8e66d
	.set	LCD_EntryThunks, 0xf8e800
	.set	SWI7_ServiceCall_Dispatch, 0xf8e9a5
	.set	ModeEnter_Sound, 0xf90c00
	.set	T_F41504_Nop, 0xf90c12
	.set	ModeEnter_Combination, 0xf90c13
	.set	T_F4150C_Nop, 0xf90c20
	.set	Mode_SwitchToCombination, 0xf90c21
	.set	Mode_SwitchToSound, 0xf90c72
	.set	InstallPainter_SoundMode_Entry, 0xf90cc2
	.set	ScreenLeave_SoundMode, 0xf90cc6
	.set	ScreenButton_SoundMode, 0xf90cca
	.set	sub_F90CD4, 0xf90cd4
	.set	GmMode_RepaintModeScreen, 0xf914af
	.set	InstallPainter_C0mbinati0nM0de_Entry, 0xf914d9
	.set	ScreenLeave_C0mbinati0nM0de, 0xf914dd
	.set	ScreenButton_C0mbinati0nM0de, 0xf914e1
	.set	sub_F914F7, 0xf914f7
	.set	InstallPainter_SoundGroupMenu_Entry, 0xf92710
	.set	ScreenLeave_SoundGroupMenu, 0xf92714
	.set	ScreenButton_SoundGroupMenu, 0xf92718
	.set	sub_F92722, 0xf92722
	.set	InstallPainter_GroupSoundDisplayHold_Entry, 0xf92c50
	.set	ScreenLeave_GroupSoundDisplayHold, 0xf92c54
	.set	ScreenButton_GroupSoundDisplayHold, 0xf92c58
	.set	sub_F92C62, 0xf92c62
	.set	InstallPainter_CombinationGroupMenu_Entry, 0xf93541
	.set	ScreenLeave_CombinationGroupMenu, 0xf93545
	.set	ScreenButton_CombinationGroupMenu, 0xf93549
	.set	sub_F93553, 0xf93553
	.set	InstallPainter_GroupCombiDisplayHold_Entry, 0xf93823
	.set	ScreenLeave_GroupCombiDisplayHold, 0xf93827
	.set	ScreenButton_GroupCombiDisplayHold, 0xf9382b
	.set	sub_F93835, 0xf93835
	.set	UiEvent_MarkRedrawFromPartClass, 0xf93f4e
	.set	UiEvent_MarkRedrawFromClass20Block, 0xf93ff2
	.set	ScreenEnter_PowerOnSplash, 0xf94078
	.set	ScreenLeave_PowerOnSplash, 0xf9407c
	.set	ScreenButton_PowerOnSplash, 0xf94080
	.set	sub_F9408A, 0xf9408a
	.set	UiEvent_SyncSoundSelection, 0xf9427d
	.set	SoundGroup_ReloadSelection, 0xf9433a
	.set	UiEventClassA8_ShowGroupScreen, 0xf943ee
	.set	LCD_BlitValueBar, 0xf9458c
	.set	UiEventClass7A_QueueDialValueRedraw, 0xf945f4
	.set	PanelDial_QueueValueRedraw_Entry, 0xf94600
	.set	DebugMonitor_PhaseVector, 0xf94c00
	.set	CheckingDevice_RunSelfTest, 0xf95137
	.set	TestMode_SelectFromPowerOnKeys, 0xf952fc
	.set	TestMode_Tick, 0xf95444
	.set	T_F40150_Nop, 0xf95646
	.set	T_F40154_Nop, 0xf95647
	.set	PanelCpuCheck_FlashStatusOnLed, 0xf95648
	.set	T_F4015C_Nop, 0xf95659
	.set	PartNotes_ReleaseReceivedOnScreenChange, 0xf9565a
	.set	T_F40164_Nop, 0xf95669
	.set	PanelSwLedCheck_Step, 0xf9566a
	.set	T_F4016C_Nop, 0xf95731
	.set	T_F40170_Nop, 0xf95732
	.set	T_F40174_Nop, 0xf95733
	.set	Paint_GateArrayCheck, 0xf95734
	.set	ScreenLeave_GateArrayCheck, 0xf95765
	.set	ScreenButton_GateArrayCheck, 0xf95766
	.set	T_F400DC_Nop, 0xf95767
	.set	Paint_PanelCpuCheck, 0xf95768
	.set	ScreenLeave_PanelCpuCheck, 0xf95795
	.set	ScreenButton_PanelCpuCheck, 0xf95796
	.set	T_F400EC_Nop, 0xf95797
	.set	Paint_SineWaveCheckMode, 0xf95798
	.set	ScreenLeave_SineWaveCheckMode, 0xf95890
	.set	ScreenButton_SineWaveCheckMode, 0xf95891
	.set	T_F400FC_Nop, 0xf9598f
	.set	Paint_PanelSwLedCheck, 0xf95990
	.set	ScreenLeave_PanelSwLedCheck, 0xf959bd
	.set	ScreenButton_PanelSwLedCheck, 0xf959be
	.set	T_F4010C_Nop, 0xf959bf
	.set	T_F40110_Nop, 0xf959c0
	.set	T_F40114_Nop, 0xf959c1
	.set	T_F40118_Nop, 0xf959c2
	.set	T_F4011C_Nop, 0xf959c3
	.set	T_F40120_Nop, 0xf959c4
	.set	T_F40124_Nop, 0xf959c5
	.set	T_F40128_Nop, 0xf959c6
	.set	T_F4012C_Nop, 0xf959c7
	.set	ScreenEnter_DebugMonitor, 0xf959c8
	.set	T_F40134_Nop, 0xf959e1
	.set	ScreenButton_DebugMonitor, 0xf959e2
	.set	T_F4013C_Nop, 0xf95c14
	.set	T_F401D4_Nop, 0xf96018
	.set	ParamImage_SnapshotAll, 0xf96019
	.set	ParamImage_QueueDiffAll, 0xf9601d
	.set	T_F401E8_Nop, 0xf96021
	.set	T_F401EC_Nop, 0xf96022
	.set	T_F401F0_Nop, 0xf96023
	.set	T_F401E0_Nop, 0xf96257
	.set	T_F401E4_Nop, 0xf96258
	.set	ParamImage_SanitizeAll_Entry, 0xf96418
	.set	T_F40218_Nop, 0xf9641d
	.set	ParamImage_SanitizeAllAndHook_Entry, 0xf9641e
	.set	ParamImage_ApplyAndMaskTable_Entry, 0xf96423
	.set	ParamImage_WriteRecordHeaders_Entry, 0xf96428
	.set	ParamImageAlt_SanitizeCombination_Entry, 0xf9642d
	.set	Combination_RecallOnSelect, 0xf97593
	.set	Combination_Recall, 0xf9759e
	.set	Combination_ReadFromCpu2, 0xf98927
	.set	ParamImage_SnapshotCombination_Entry, 0xf98984
	.set	ParamImage_SnapshotCombinationAndParts_Entry, 0xf98989
	.set	ParamImage_QueueDiffCombination, 0xf9898e
	.set	ParamImage_QueueDiffCombinationAndParts, 0xf98ade
	.set	InstallPainter_MessageScreen, 0xf99021
	.set	T_F41608_Nop, 0xf9904c
	.set	ScreenButton_MessageScreen, 0xf9904d
	.set	T_F41610_Nop, 0xf99097
	.set	MessageScreen_Paint, 0xf99098
	.set	PanelScreen_RequestRedrawIfFieldQueued, 0xf99400
	.set	SysexBulkDump_PhaseVector, 0xf99800
	.set	T_F41660_Nop, 0xf99821
	.set	T_F416E0_Nop, 0xf99822
	.set	T_F416F0_Nop, 0xf99823
	.set	T_F41700_Nop, 0xf99824
	.set	T_F41670_Nop, 0xf99825
	.set	T_F41680_Nop, 0xf99826
	.set	T_F416A0_Nop, 0xf99827
	.set	T_F416B0_Nop, 0xf99828
	.set	T_F416C0_Nop, 0xf9982b
	.set	T_F416D0_Nop, 0xf9982c
	.set	Paint_SysexBulkDump_Entry, 0xf9982d
	.set	ScreenLeave_SysexBulkDump_Entry, 0xf99831
	.set	ScreenButton_SysexBulkDump_Entry, 0xf99835
	.set	T_F4171C_Nop, 0xf99843
	.set	Paint_GeneralMidiMode_Entry, 0xf99844
	.set	ScreenLeave_GeneralMidiMode_Entry, 0xf99848
	.set	ScreenButton_GeneralMidiMode_Entry, 0xf9984c
	.set	T_F4172C_Nop, 0xf9985a
	.set	Paint_Sending_Entry, 0xf9985b
	.set	Paint_SystemExclusivePleaseWait_Entry, 0xf9985f
	.set	T_F41738_Nop, 0xf99863
	.set	PanelMode_MidiEnter, 0xf99f04
	.set	PanelMode_MidiLeave, 0xf99f15
	.set	Var2134_SetBit1, 0xf99f1a
	.set	Var2134_SetBit1_2, 0xf99f1f
	.set	Paint_MidiMenu, 0xf99f24
	.set	T_F41654_Nop, 0xf99f5c
	.set	T_F4165C_Nop, 0xf99f5d
	.set	ScreenButton_MidiMenu, 0xf99f5e
	.set	Paint_MidiTotalMode, 0xf9a1a8
	.set	ScreenLeave_MidiTotalMode, 0xf9a26d
	.set	T_F41748_Nop, 0xf9a26e
	.set	ScreenButton_MidiTotalMode, 0xf9a26f
	.set	Paint_MidiRealtimeMessages, 0xf9a6c0
	.set	ScreenLeave_MidiRealtimeMessages, 0xf9a754
	.set	T_F4169C_Nop, 0xf9a755
	.set	ScreenButton_MidiRealtimeMessages, 0xf9a756
	.set	Paint_MidiInputOutputFilter, 0xf9a998
	.set	ScreenLeave_MidiInputOutputFilter, 0xf9aa4f
	.set	T_F41758_Nop, 0xf9aa50
	.set	ScreenButton_MidiInputOutputFilter, 0xf9aa51
	.set	Paint_MidiOutProgramChange, 0xf9af61
	.set	ScreenLeave_MidiOutProgramChange, 0xf9b05e
	.set	T_F41768_Nop, 0xf9b05f
	.set	ScreenButton_MidiOutProgramChange, 0xf9b060
	.set	Screen_ReMapEdit_Enter, 0xf9c087
	.set	Screen_ReMapEdit_Leave, 0xf9c0c1
	.set	Screen_ReMapEdit_Button, 0xf9c0c2
	.set	T_F41974_Nop, 0xf9c0e9
	.set	Screen_SoundCombinationManager_Enter, 0xf9c9f4
	.set	T_F4197C_Nop, 0xf9ca0c
	.set	Screen_SoundCombinationManager_Button, 0xf9ca0d
	.set	T_F41984_Nop, 0xf9ca34
	.set	Screen_SoundGroupNaming_Enter, 0xf9cb00
	.set	Screen_SoundGroupNaming_Leave, 0xf9cb52
	.set	Screen_SoundGroupNaming_Button, 0xf9cb53
	.set	T_F4268C_Nop, 0xf9cb7a
	.set	Screen_CombinationGroupNaming_Enter, 0xf9cf68
	.set	Screen_CombinationGroupNaming_Leave, 0xf9cfba
	.set	Screen_CombinationGroupNaming_Button, 0xf9cfbb
	.set	T_F4269C_Nop, 0xf9cfe2
	.set	Screen_SoundCopy_Enter, 0xf9d3ba
	.set	Screen_SoundCopy_Leave, 0xf9d3f4
	.set	Screen_SoundCopy_Button, 0xf9d404
	.set	T_F426AC_Nop, 0xf9d432
	.set	Screen_CombinationCopy_Enter, 0xf9df91
	.set	T_F426B4_Nop, 0xf9dfcb
	.set	Screen_CombinationCopy_Button, 0xf9dfcc
	.set	T_F426BC_Nop, 0xf9dff3
	.set	Screen_DataLoadFilter_Enter, 0xf9eb75
	.set	T_F4199C_Nop, 0xf9ebed
	.set	Screen_DataLoadFilter_Button, 0xf9ebee
	.set	T_F419A4_Nop, 0xf9ec15
	.set	Screen_MemoryProtect_Enter, 0xf9ed34
	.set	T_F4198C_Nop, 0xf9eda1
	.set	Screen_MemoryProtect_Button, 0xf9eda2
	.set	T_F41994_Nop, 0xf9edc9
	.set	Screen_SoundMute_Enter, 0xf9eeab
	.set	T_F434C4_Nop, 0xf9eedf
	.set	Screen_SoundMute_Button, 0xf9eee0
	.set	T_F434CC_Nop, 0xf9ef07
	.set	Screen_MainOutEqualizer_Enter, 0xf9ef6c
	.set	T_F4195C_Nop, 0xf9ef71
	.set	Screen_MainOutEqualizer_Button, 0xf9ef72
	.set	T_F41964_Nop, 0xf9ef84
	.set	Screen_DrumsMapNaming_Enter, 0xf9ef85
	.set	Screen_DrumsMapNaming_Leave, 0xf9eff6
	.set	Screen_DrumsMapNaming_Button, 0xf9f006
	.set	T_F419C4_Nop, 0xf9f034
	.set	DrumsMap_RefreshSoundColumn, 0xf9f457
	.set	SoundName_CopyToBuffer, 0xf9f5e8
	.set	SoundGroupName_CopyToBuffer, 0xf9f65b
	.set	SoundGroup_MaxMemberIndex_ByStack, 0xf9f6b2
	.set	CombiName_CopyToBuffer, 0xf9f6ec
	.set	CombiGroupName_CopyToBuffer, 0xf9f75c
	.set	CombiGroup_MaxMemberIndex_ByStack, 0xf9f7b8
	.set	SoundCopy_HandleReceivedSound, 0xf9fbde
	.set	SoundCopy_ReadExtGroupDrumFlag, 0xf9fdc8
	.set	PanelMode_System_Enter, 0xf9fed1
	.set	PanelMode_System_Leave, 0xf9fee2
	.set	Screen_System_Enter, 0xf9fee7
	.set	T_F4191C_Nop, 0xf9feff
	.set	Screen_System_Button, 0xf9ff00
	.set	T_F41924_Nop, 0xf9ff27
	.set	TuneScale_KeyScalingCodeToIndex, 0xfa0054
	.set	Screen_DspEffect_Enter, 0xfa007b
	.set	T_F419AC_Nop, 0xfa0080
	.set	Screen_DspEffect_Button, 0xfa0081
	.set	T_F419B4_Nop, 0xfa0093
	.set	Screen_TuneScale_Enter, 0xfa0094
	.set	T_F4192C_Nop, 0xfa00e9
	.set	Screen_TuneScale_Button, 0xfa00ea
	.set	T_F41934_Nop, 0xfa0111
	.set	Screen_TouchSensitivityOrTest_Enter, 0xfa0689
	.set	T_F4193C_Nop, 0xfa07a1
	.set	Screen_TouchSensitivityOrTest_Button, 0xfa07a2
	.set	T_F41944_Nop, 0xfa07ea
	.set	SystemTest_PlayNotesOnPanelKey, 0xfa0d10
	.set	Screen_ControllerAssign_Enter, 0xfa0df3
	.set	Screen_ControllerAssign_Leave, 0xfa0e4d
	.set	Screen_ControllerAssign_Button, 0xfa0eea
	.set	T_F41954_Nop, 0xfa0f11
	.set	Screen_Initial_Enter, 0xfa129d
	.set	Screen_Initial_Leave, 0xfa12ce
	.set	Screen_Initial_Button, 0xfa12dd
	.set	T_F4267C_Nop, 0xfa1304
	.set	MIDI_EntryThunks, 0xfa5400
	.set	MIDI_RX_ErrorReset, 0xfa5418
	.set	MIDI_TX_Ready, 0xfa542f
	.set	MIDI_RX_Byte, 0xfa5496
	.set	MIDI_Clock_CatchUpIfAnySlot, 0xfa55f4
	.set	MIDI_PostSendWork, 0xfa590f
	.set	MIDI_DrainQueue, 0xfa5942
	.set	MIDI_SendBankAndProgram, 0xfa5b5f
	.set	MIDI_PostSendWork_PortB, 0xfa5c12
	.set	MIDI_SendAllNotesOff_AllChannels, 0xfa5c54
	.set	MidiIn_EntryThunks, 0xfa6000
	.set	MidiIn_PumpPortA, 0xfa6018
	.set	MidiIn_PumpPortB, 0xfa60c2
	.set	MidiIn_ReqRouteRebuild_Msg0D, 0xfa6eef
	.set	MidiIn_ServiceDeferred, 0xfa6f04
	.set	MidiOut_ParamChanged, 0xfa70f5
	.set	MidiOut_PutByteA_SetStatus, 0xfa7d92
	.set	MidiOut_PutByteA, 0xfa7d95
	.set	MidiOut_RunPeriodicTimeouts, 0xfa7da3
	.set	MidiOut_ResyncChangedParts, 0xfa7e0c
	.set	MidiIn_ReqListRebuild_Msg13_16, 0xfa835e
	.set	MidiIn_ReqRebuild_Msg03_0A, 0xfa8378
	.set	ParamModule_PhaseVector, 0xfaa400
	.set	SoundSel_ClampToProgramAndBankRegs, 0xfaa418
	.set	SoundSel_FromProgramAndBankRegs, 0xfaa43a
	.set	CombiSel_ClampToNumberAndBankRegs, 0xfaa45c
	.set	sub_FAA47E, 0xfaa47e
	.set	Queue2C00_PublishStagedIfPending, 0xfaa4a0
	.set	Queue2C00_PublishStagedDrainPassB, 0xfaa550
	.set	T_F407BC_Nop, 0xfaa5a4
	.set	T_F407C0_Nop, 0xfaa5a5
	.set	T_F407C8_Nop, 0xfaa5a6
	.set	ParamChange_NotifyClearSource, 0xfaa5fe
	.set	ParamChange_Notify, 0xfaa604
	.set	ParamRecord_WriteFieldAndStage, 0xfaa623
	.set	ParamRecord_WriteFieldAndStage_Copy, 0xfaa66a
	.set	sub_FAA6B1, 0xfaa6b1
	.set	T_F407E0_Nop, 0xfaa71c
	.set	T_F407E8_Nop, 0xfaa71d
	.set	T_F407E4_Nop, 0xfaa71e
	.set	ParamB0_PublishField0IfPending, 0xfaa71f
	.set	Tempo_ApplyBpm, 0xfaa742
	.set	T_F407A4_Nop, 0xfaa7ab
	.set	MidiSettings_ResetToDefault, 0xfaa967
	.set	sub_FAAA8F, 0xfaaa8f
	.set	ParamImage_PostAllAsChangeEvents_Call, 0xfaaab1
	.set	ParamImage_PostAllAsChangeEvents, 0xfaaab5
	.set	ParamImage_LoadFactoryDefaults, 0xfaab28
	.set	Mode_InitSavedPartBlocks, 0xfaabb3
	.set	PartSettings_ResetToDefault, 0xfaae2a
	.set	SystemSettings_ResetToDefault, 0xfaaf91
	.set	T_F407A8_Nop, 0xfab5e9
	.set	T_F407A0_Nop, 0xfab5ea
	.set	ProgramChangeMode_OnEvent, 0xfab643
	.set	T_F407C4_Nop, 0xfab657
	.set	SoundSel_ClampToProgramAndBank, 0xfab658
	.set	SoundSel_GroupMemberFromProgramAndBank, 0xfab6d7
	.set	CombiSel_GroupMemberFromNumberAndBank, 0xfab728
	.set	CombiSel_ClampToNumberAndBank, 0xfab779
	.set	List2030_ProcessEvents, 0xfab7e6
	.set	T_F407F0_Nop, 0xfabbd6
	.set	Seq_PublishPendingParamB0, 0xfabd33
	.set	MidiIn_ControlRecord_Dispatch, 0xfabefb
	.set	ParamMsg_RefreshPartMasks, 0xfabfe2
	.set	ParamMsg_ResendTwoAssignedCtrls, 0xfabfff
	.set	ParamMsg_RefreshMasksOnCtrlFieldChange, 0xfac786
	.set	ParamRecord_SetPartsField18Bit0, 0xfac7c4
	.set	Queue2E00_PostParam98Fields, 0xfac80f
	.set	T_F40860_Nop, 0xfad800
	.set	T_F4085C_Nop, 0xfad805
	.set	ParamApply_MaskedWriteAndPublish, 0xfad80a
	.set	ParamShadow_SetField3, 0xfad81d
	.set	ParamShadow_SetExpression, 0xfad84a
	.set	ParamShadow_SetPitchBend, 0xfad870
	.set	ParamShadow_SetModulation1, 0xfad88a
	.set	ParamApply_WriteStagedAndPublish, 0xfad8a1
	.set	ParamApply_PublishStagedPair, 0xfad8bc
	.set	ParamApply_PublishStagedPair_Copy, 0xfad8dd
	.set	ParamApply_PublishStagedAndPostSeven, 0xfad8fe
	.set	ParamApply_PublishStagedPairBCDE, 0xfad98f
	.set	ParamApply_WriteStagedAndPublish_Copy, 0xfad9b0
	.set	ParamApply_OneHotOfSix, 0xfad9cb
	.set	ParamShadow_FlushAll, 0xfada26
	.set	Evt2030_RunList, 0xfadb2c
	.set	ParamReset_SixParamsForIndex, 0xfade8d
	.set	Msg0716_AllPartsResetBendAndModulation_Call, 0xfadf08
	.set	ParamApply_ByModeOfParam80, 0xfadf1e
	.set	ParamApply_StorePairAndDerive, 0xfae223
	.set	T_F41F2C_Nop, 0xfae800
	.set	T_F41F3C_Nop, 0xfae829
	.set	T_F41F38_Nop, 0xfae84c
	.set	SeqBuf_RecordQueuedEvents, 0xfae84d
	.set	SeqBuf_PickRecordPartMask, 0xfae872
	.set	SeqBuf_EncodeQueue2C00, 0xfae921
	.set	T_F41F24_Nop, 0xfaebaa
	.set	T_F41F1C_Nop, 0xfaec78
	.set	SeqEvt_ResetPlayingSlotControllers, 0xfaec8a
	.set	SeqEvt_PlayRun, 0xfaed76
	.set	T_F41F20_Nop, 0xfaf48f
	.set	T_F41F28_Nop, 0xfaf490
	.set	PatchLists_ApplyAll, 0xfb1800
	.set	SysExModule_EntryThunks, 0xfb2000
	.set	T_F408F8_Nop, 0xfb2022
	.set	SysExDump_RunSendJob, 0xfb2049
	.set	SysExRx_PollRing601646, 0xfb20ce
	.set	SysExRx_PollRing601C6E, 0xfb21cb
	.set	SysExCmd_ResetSession, 0xfb22c8
	.set	SysExSession_Run, 0xfb2820
	.set	SysExSession_Enquiry, 0xfb28ff
	.set	SysExSession_StartTransfer, 0xfb291d
	.set	SysExSession_RecvSystemPart1, 0xfb2978
	.set	SysExSession_RecvSystemPart2, 0xfb29bb
	.set	SysExSession_RecvSoundOrphan, 0xfb29f1
	.set	SysExSession_RecvSound, 0xfb2a27
	.set	SysExSession_RecvStub0F, 0xfb2a7b
	.set	SysExSession_RecvStub10, 0xfb2abe
	.set	SysExSession_RecvStub11, 0xfb2af5
	.set	SysExSession_RecvSequencerPart1, 0xfb2b30
	.set	SysExSession_RecvSequencerPart2, 0xfb2b6f
	.set	SysExSession_RecvSequencerPart3, 0xfb2ba6
	.set	SysExSession_RecvCombinationPart1, 0xfb2be1
	.set	SysExSession_RecvCombinationPart2, 0xfb2c35
	.set	SysExSession_Continuation, 0xfb2c6c
	.set	SysExSession_RecvBody_HeaderExpected, 0xfb2c9a
	.set	SysExSession_RecvBody_SystemPart1, 0xfb2cad
	.set	SysExSession_RecvBody_SystemPart2, 0xfb2ce7
	.set	SysExSession_RecvBody_SoundOrphan, 0xfb2d21
	.set	SysExSession_RecvBody_Stub0F, 0xfb2d72
	.set	SysExSession_RecvBody_Stub10, 0xfb2dac
	.set	SysExSession_RecvBody_Stub11, 0xfb2de6
	.set	SysExSession_RecvBody_SequencerPart1, 0xfb2e20
	.set	SysExSession_RecvBody_SequencerPart2, 0xfb2e69
	.set	SysExSession_RecvBody_SequencerPart3, 0xfb2eb2
	.set	SysExSession_RecvBody_CombinationPart1, 0xfb2efb
	.set	SysExSession_RecvBody_CombinationPart2, 0xfb2f35
	.set	SysExSession_CategoryEnd, 0xfb3041
	.set	SysExSession_CategoryEnd_WrongStep, 0xfb306c
	.set	SysExSession_CategoryEnd_SystemPartMidi, 0xfb307f
	.set	SysExSession_CategoryEnd_Sound, 0xfb3097
	.set	SysExSession_CategoryEnd_Stub, 0xfb30af
	.set	SysExSession_CategoryEnd_Sequencer, 0xfb30c7
	.set	SysExSession_CategoryEnd_Combination, 0xfb30df
	.set	SysExSession_DumpEnd, 0xfb30f7
	.set	SysExSession_Ignore, 0xfb3230
	.set	SysExSession_Cmd01_Nop, 0xfb3231
	.set	SysExSession_Cmd02_Nop, 0xfb3232
	.set	SysExSession_Cmd06_Nop, 0xfb3233
	.set	SysExSession_Abort, 0xfb3244
	.set	SysExSession_AbortStep_Idle, 0xfb3277
	.set	SysExSession_AbortStep_SystemPartMidi, 0xfb3278
	.set	SysExSession_AbortStep_Sound, 0xfb327d
	.set	SysExSession_AbortStep_Stub, 0xfb3282
	.set	SysExSession_AbortStep_Sequencer, 0xfb3287
	.set	SysExSession_AbortStep_Combination, 0xfb328c
	.set	SysExSession_RecvBody_Sound, 0xfb328d
	.set	SysExTx_Tempo, 0xfb3355
	.set	SysExCmd_TempoReceive, 0xfb33fe
	.set	SysExCmd_ThirdRegionWrite, 0xfb3483
	.set	SysExCmd_ThirdRegionRequest, 0xfb3495
	.set	SysExCmd_ParamWrite, 0xfb34ca
	.set	SysExParam_SetPlaceholder, 0xfb374c
	.set	SysExParam_SetCommonField, 0xfb3778
	.set	SysExParam_SetMainOutEqualizerFreq, 0xfb381f
	.set	SysExParam_SetMemoryProtect, 0xfb3882
	.set	SysExParam_SetPartField, 0xfb38e4
	.set	SysExParam_SetProgramChangeAndBank, 0xfb39a4
	.set	SysExParam_SetEffect1Type, 0xfb3ac4
	.set	SysExParam_SetMidiMultipleMessagesOutput, 0xfb3b04
	.set	SysExParam_SetMidiMultipleMessagesOutputBankSelect, 0xfb3bcf
	.set	SysExParam_SetEffect2OnOff, 0xfb3d13
	.set	SysExInitial_Total, 0xfb3dbc
	.set	SysExInitial_PartSetting, 0xfb3dcd
	.set	SysExInitial_System, 0xfb3dd2
	.set	SysExInitial_MidiSetting, 0xfb3de6
	.set	SysExInitial_ReMap, 0xfb3e02
	.set	SysExInitial_DrumsMap, 0xfb3e22
	.set	SysExInitial_Sequencer, 0xfb3e3e
	.set	SysExParam_SetInitial, 0xfb3e5a
	.set	SysExParam_SetSoundWriteRequest, 0xfb3ea3
	.set	SysExParam_SetCombinationNumberAndBank, 0xfb3f9d
	.set	SysExParam_SetPlayModeRequest, 0xfb4223
	.set	SysExParam_Request_DispatchGroup, 0xfb42ab
	.set	SysExParam_ReceiveOnly, 0xfb4506
	.set	SysExParam_GetMemoryProtect, 0xfb4507
	.set	SysExParam_GetCommonField, 0xfb4562
	.set	SysExParam_GetMainOutEqualizerFreq, 0xfb45a5
	.set	SysExParam_GetCombinationNumberAndBank, 0xfb461a
	.set	SysExParam_GetPartField, 0xfb4698
	.set	SysExParam_GetProgramChangeAndBank, 0xfb46ff
	.set	SysExParam_GetMidiMultipleMessagesOutput, 0xfb4753
	.set	SysExParam_GetMidiMultipleMessagesOutputBankSelect, 0xfb484a
	.set	SysExParam_GetEffect2OnOff, 0xfb496e
	.set	SysExParam_GetEffect1Type, 0xfb49ff
	.set	SysExTx_EmitStagedParams, 0xfb4b7d
	.set	SysExTx_StagedParam_Ignore, 0xfb4bdd
	.set	SysExTx_StagedParam_Record48, 0xfb4bde
	.set	SysExTx_StagedParam_Record60, 0xfb4c12
	.set	SysExTx_StagedParam_Record70, 0xfb4c46
	.set	SysExTx_StagedParam_Record98, 0xfb4c7a
	.set	SysExTx_GmSystemOnOff, 0xfb4cae
	.set	SysExParam_NoTransmitOnChange, 0xfb4d61
	.set	SysExTx_SendParamValue, 0xfb4d62
	.set	sub_FB50EE, 0xfb50ee
	.set	SysExCmd_DumpRequest_SystemPartMidi, 0xfb5122
	.set	SysExCmd_DumpRequest_Sound, 0xfb512c
	.set	SysExCmd_DumpRequest_Job1, 0xfb5136
	.set	SysExCmd_DumpRequest_Sequencer, 0xfb5140
	.set	SysExCmd_DumpRequest_Combination, 0xfb514a
	.set	SysExCmd_GmSystemOn, 0xfb51e7
	.set	SysExCmd_GmSystemOff, 0xfb520c
	.set	SysExParam_SetCombinationWriteRequest, 0xfb5241
	.set	BStore_Workspace_StoreGmModeDefaults, 0xfb585e
	.set	GmMode_HandleChange, 0xfb590a
	.set	GmMode_OnEventPassB, 0xfb5ee9
	.set	SysEx_Checksum, 0xfb7a90
	.set	SysExTx_SendBytes, 0xfb7ac2
	.set	MidiFileDirectPlay_InitOnEntry, 0xfb9b41
	.set	MidiFileDirectPlay_RestoreOnLeave, 0xfb9b73
	.set	MidiFilePlay_ApplyGmOnPartSetup, 0xfb9ba4
	.set	MidiFilePlay_ApplyGmOffPartSetup, 0xfb9c52
	.set	sub_FB9D2C, 0xfb9d2c
	.set	sub_FB9D43, 0xfb9d43
	.set	Medley_ToggleMidiFileStream, 0xfb9da0
	.set	MidiFileDirectPlay_LcdKeyRow1, 0xfb9dfe
	.set	MidiFilePlay_Tick, 0xfb9e79
	.set	SeqFile_Load, 0xfbac00
	.set	SeqFile_Save, 0xfbae5a
	.set	BStore_GetDiskBankPassword, 0xfbb392
	.set	BStore_GetAnyBankPassword, 0xfbb3dc
	.set	PartParam_StepFieldById, 0xfbb800
	.set	PartParam_EnterFieldById, 0xfbb93c
	.set	PartParam_RefuseNumberEntry, 0xfbba83
	.set	PartParam_StepSound, 0xfbba8e
	.set	PartParam_StepVolume, 0xfbbaa3
	.set	PartParam_EnterVolume, 0xfbbabb
	.set	PartParam_StepPanpot, 0xfbbad3
	.set	PartParam_StepKeyShift, 0xfbbaeb
	.set	PartParam_EnterKeyShift, 0xfbbb03
	.set	PartParam_StepFineTune, 0xfbbb1b
	.set	PartParam_EnterFineTune, 0xfbbb33
	.set	PartParam_StepPitchBendRange, 0xfbbb4b
	.set	PartParam_EnterPitchBendRange, 0xfbbb63
	.set	PartParam_StepEffect1Send, 0xfbbb7b
	.set	PartParam_EnterEffect1Send, 0xfbbb93
	.set	PartParam_StepEffect2, 0xfbbbab
	.set	PartParam_StepReverbSend, 0xfbbc2b
	.set	PartParam_EnterReverbSend, 0xfbbc43
	.set	PartParam_StepLocalControl, 0xfbbc5b
	.set	PartParam_StepMidiOutSetting, 0xfbbc73
	.set	PartParam_StepMidiInSetting, 0xfbbc8b
	.set	PartParam_StepIgnored, 0xfbbca3
	.set	PartParam_StepKeyScaling, 0xfbbca4
	.set	PartParam_StepMainOut, 0xfbbcbc
	.set	PartParam_StepSubOut, 0xfbbd4f
	.set	PartParam_StepAssignMode, 0xfbbdf9
	.set	PartParam_StepVelocityOffset, 0xfbbe11
	.set	PartParam_EnterVelocityOffset, 0xfbbe29
	.set	PartParam_StepBasicChannel, 0xfbbe41
	.set	PartParam_StepKeyLayerLow, 0xfbbe59
	.set	PartParam_StepKeyLayerHigh, 0xfbbe94
	.set	PartParam_StepVelocityLayerLow, 0xfbbecf
	.set	PartParam_StepVelocityLayerHigh, 0xfbbf0a
	.set	PartParam_StepControllerInternalFilterPitchBend, 0xfbbf45
	.set	PartParam_StepControllerInternalFilterModulation1, 0xfbbf5d
	.set	PartParam_StepControllerInternalFilterModulation2, 0xfbbf75
	.set	PartParam_StepControllerInternalFilterRealTimeCreatorX, 0xfbbf8d
	.set	PartParam_StepControllerInternalFilterRealTimeCreatorY, 0xfbbfa5
	.set	PartParam_StepControllerInternalFilterRealTimeControllerX, 0xfbbfbd
	.set	PartParam_StepControllerInternalFilterRealTimeControllerY, 0xfbbfd5
	.set	PartParam_StepControllerInternalFilterHold1, 0xfbbfed
	.set	PartParam_StepControllerInternalFilterControlPedal, 0xfbc005
	.set	PartParam_StepControllerInternalFilterAfterTouch, 0xfbc01d
	.set	PartParam_StepMidiInputFilterProgramChange, 0xfbc035
	.set	PartParam_StepMidiInputFilterBankSelect, 0xfbc04d
	.set	PartParam_StepMidiInputFilterVolume, 0xfbc065
	.set	PartParam_StepMidiOutputFilterProgramChange, 0xfbc07d
	.set	PartParam_StepMidiOutputFilterBankSelect, 0xfbc095
	.set	PartParam_StepMidiOutputFilterVolume, 0xfbc0ad
	.set	PartParam_StepMidiOutputFilterPanpot, 0xfbc0c5
	.set	PartParam_StepMidiOutputFilterEffectDepth_FBC0DD, 0xfbc0dd
	.set	PartParam_StepMidiOutputFilterEffectDepth_FBC0F5, 0xfbc0f5
	.set	PartParam_StepMidiOutKeyTranspose_F1ADAC, 0xfbc10d
	.set	PartParam_EnterMidiOutKeyTranspose_F1ADAC, 0xfbc125
	.set	PartParam_StepMidiOutputFilterPitchBend, 0xfbc13d
	.set	PartParam_StepMidiOutputFilterModulation1, 0xfbc155
	.set	PartParam_StepMidiOutputFilterModulation2, 0xfbc16d
	.set	PartParam_StepMidiOutputFilterRealTimeCreatorX, 0xfbc185
	.set	PartParam_StepMidiOutputFilterRealTimeCreatorY, 0xfbc19d
	.set	PartParam_StepMidiOutputFilterRealTimeControllerX, 0xfbc1b5
	.set	PartParam_StepMidiOutputFilterRealTimeControllerY, 0xfbc1cd
	.set	PartParam_StepMidiOutputFilterHold1, 0xfbc1e5
	.set	PartParam_StepMidiOutputFilterControlPedal, 0xfbc1fd
	.set	PartParam_StepMidiOutputFilterAfterTouch, 0xfbc215
	.set	PartParam_StepMidiMultipleMessagesOutputProgramChange, 0xfbc2ff
	.set	PartParam_EnterMidiMultipleMessagesOutputProgramChange, 0xfbc316
	.set	PartParam_StepMidiMultipleMessagesOutputBankSelectMsb, 0xfbc352
	.set	PartParam_EnterMidiMultipleMessagesOutputBankSelectMsb, 0xfbc38f
	.set	PartParam_StepMidiMultipleMessagesOutputBankSelectLsb, 0xfbc3d8
	.set	PartParam_EnterMidiMultipleMessagesOutputBankSelectLsb, 0xfbc3ef
	.set	PartParam_StepMidiMultipleMessagesOutputVolume, 0xfbc42b
	.set	PartParam_EnterMidiMultipleMessagesOutputVolume, 0xfbc442
	.set	PartParam_StepMidiMultipleMessagesOutputPanpot, 0xfbc47e
	.set	PartParam_StepMidiMultipleMessagesOutputReverbDepth, 0xfbc495
	.set	PartParam_EnterMidiMultipleMessagesOutputReverbDepth, 0xfbc4ac
	.set	PartParam_StepMidiMultipleMessagesOutputChorusDepth, 0xfbc4e8
	.set	PartParam_EnterMidiMultipleMessagesOutputChorusDepth, 0xfbc4ff
	.set	PartParam_StepMidiOutKeyTranspose_F1AE12, 0xfbc53b
	.set	PartParam_EnterMidiOutKeyTranspose_F1AE12, 0xfbc553
	.set	ScreenEnter_CombiEditConfigure_B2, 0xfbc56b
	.set	ScreenLeave_CombiEditConfigure_B2, 0xfbc56f
	.set	ScreenButton_CombiEditConfigure_B2, 0xfbc573
	.set	T_F41874_Nop, 0xfbc584
	.set	ScreenEnter_CombiEditConfigure_35, 0xfbc585
	.set	ScreenLeave_CombiEditConfigure_35, 0xfbc589
	.set	ScreenButton_CombiEditConfigure_35, 0xfbc58d
	.set	T_F41A34_Nop, 0xfbc59e
	.set	ScreenEnter_CombinationNaming, 0xfbc59f
	.set	ScreenLeave_CombinationNaming, 0xfbc5a3
	.set	ScreenButton_CombinationNaming, 0xfbc5a7
	.set	T_F41A44_Nop, 0xfbc5b8
	.set	T_F41A88_Nop, 0xfbc5b9
	.set	T_F41A8C_Nop, 0xfbc5ba
	.set	T_F41A90_Nop, 0xfbc5bb
	.set	T_F41A94_Nop, 0xfbc5bc
	.set	ScreenEnter_WriteProtectError, 0xfbc5bd
	.set	Var2075_ClrBit7_Entry, 0xfbc5c1
	.set	ScreenButton_WriteProtectError, 0xfbc5c5
	.set	T_F41884_Nop, 0xfbc5d6
	.set	ScreenEnter_Effect2OutputConflict, 0xfbc5d7
	.set	ScreenLeave_Effect2OutputConflict, 0xfbc5db
	.set	ScreenButton_Effect2OutputConflict, 0xfbc5df
	.set	T_F418B4_Nop, 0xfbc5f0
	.set	CombiEdit_OnPartParamEvent, 0xfbc5f1
	.set	CombiEdit_RunPendingRepaint, 0xfbc64f
	.set	CombiEditMixer_OnSoundPanVolumePageEvent, 0xfbc768
	.set	CombiEditMixer_OnSendsPageEvent, 0xfbc82c
	.set	CombiEditMixer_OnMidiPageEvent, 0xfbc90d
	.set	ModeEnter_CombiEditPart, 0xfbcb06
	.set	sub_FBCB31, 0xfbcb31
	.set	ScreenEnter_CombiEditPartMenu, 0xfbcb40
	.set	T_F4184C_Nop, 0xfbcb81
	.set	ScreenButton_CombiEditPartMenu, 0xfbcb82
	.set	T_F41854_Nop, 0xfbcba9
	.set	LcdKeyRow1_CombiEditPartSelect, 0xfbcbaa
	.set	LcdKeyRow2_CombiEditPartSelect, 0xfbcbf1
	.set	LcdKeyRow3_CombiEditPartMenu, 0xfbcc3d
	.set	LcdKeyRow4_CombiEditPartMenu, 0xfbcc64
	.set	LcdKeyRow5_CombiEditPartMenu, 0xfbcc8b
	.set	ExitKey_CombiEditPartMenu, 0xfbcc9e
	.set	ScreenEnter_CombiEditInternalSound_B4, 0xfbcdec
	.set	ScreenEnter_CombiEditInternalSound_B5, 0xfbcdf0
	.set	ScreenEnter_CombiEditInternalSound_37, 0xfbcdf4
	.set	ScreenEnter_CombiEditInternalSound_38, 0xfbcdf8
	.set	ScreenEnter_CombiEditInternalSound, 0xfbcdfc
	.set	ScreenLeave_CombiEditInternalSound_B4, 0xfbcee7
	.set	ScreenLeave_CombiEditInternalSound_B5, 0xfbceeb
	.set	ScreenLeave_CombiEditInternalSound_37, 0xfbceef
	.set	ScreenLeave_CombiEditInternalSound_38, 0xfbcef3
	.set	T_F4185C_Nop, 0xfbcef7
	.set	ScreenButton_CombiEditInternalSound_B4, 0xfbcef8
	.set	ScreenButton_CombiEditInternalSound_B5, 0xfbcf09
	.set	ScreenButton_CombiEditInternalSound_37, 0xfbcf1a
	.set	ScreenButton_CombiEditInternalSound_38, 0xfbcf2b
	.set	ScreenButton_CombiEditInternalSound, 0xfbcf3c
	.set	T_F41894_Nop, 0xfbcf7d
	.set	T_F418A4_Nop, 0xfbcf7e
	.set	T_F41A54_Nop, 0xfbcf7f
	.set	T_F41A64_Nop, 0xfbcf80
	.set	T_F41864_Nop, 0xfbcf81
	.set	SoftKeyCols1to4_CombiEditInternalSound, 0xfbcf82
	.set	SoftKeyCols5to8_CombiEditInternalSound, 0xfbcfd1
	.set	ExitKey_CombiEditInternalSound, 0xfbd016
	.set	PageKey_CombiEditInternalSound, 0xfbd044
	.set	NumberPadKey_CombiEditInternalSound, 0xfbd0a4
	.set	CombiEditSound_PaintLevelsPage, 0xfbd3e8
	.set	CombiEditSound_PaintControllerFilterPage, 0xfbd593
	.set	CombiEditSound_PaintAssignAndInputFilterPage, 0xfbd5e8
	.set	CombiEditSound_PaintMidiOutPage, 0xfbd6b8
	.set	CombiEditSound_PaintMidiOutFilterPage, 0xfbd784
	.set	CombiEditSound_PaintMultipleMessagesPage, 0xfbd7d9
	.set	ScreenEnter_CombiEditMixer, 0xfbdb91
	.set	ScreenEnterBody_CombiEditMixer, 0xfbdb95
	.set	ScreenLeave_CombiEditMixer, 0xfbdd0d
	.set	ScreenLeaveBody_CombiEditMixer, 0xfbdd11
	.set	ScreenButton_CombiEditMixer, 0xfbdd80
	.set	ScreenButtonBody_CombiEditMixer, 0xfbdd91
	.set	sub_FBDDD2, 0xfbddd2
	.set	T_F418C4_Nop, 0xfbddd6
	.set	SoftKeyCols1to8_CombiEditMixer, 0xfbddd7
	.set	LcdKeyRow1_CombiEditMixer, 0xfbddf9
	.set	LcdKeyRow2_CombiEditMixer, 0xfbde6b
	.set	LcdKeyRow3_CombiEditMixer, 0xfbdecc
	.set	LcdKeyRow4_CombiEditMixer, 0xfbdf26
	.set	LcdKeyRow5_CombiEditMixer, 0xfbdf86
	.set	ExitKey_CombiEditMixer, 0xfbdfcc
	.set	PageKey_CombiEditMixer, 0xfbe038
	.set	CombiEditMixer_PaintSoundPanVolumePage, 0xfbe3f1
	.set	CombiEditMixer_PaintSendsPage, 0xfbe433
	.set	CombiEditMixer_PaintMidiPage, 0xfbe467
	.set	CombiEdit_Begin, 0xfbecc3
	.set	CombiEdit_End, 0xfbed02
	.set	CompareKey_CombiEdit, 0xfbedbe
	.set	CombiEdit_RestoreEditedIfComparing, 0xfbee83
	.set	ScreenEnter_CombiEditMenuRedirect, 0xfbeed9
	.set	T_F41A0C_Nop, 0xfbeee3
	.set	T_F41A10_Nop, 0xfbeee4
	.set	T_F41A14_Nop, 0xfbeee5
	.set	ScreenEnter_CombiEditDspEffect, 0xfbeee6
	.set	T_F41A6C_Nop, 0xfbeeeb
	.set	ScreenButton_CombiEditDspEffect, 0xfbeeec
	.set	T_F41A74_Nop, 0xfbef1b
	.set	Screen_CombinationNaming_Enter, 0xfbef1c
	.set	Screen_CombinationNaming_Leave, 0xfbef75
	.set	Screen_CombinationNaming_Button, 0xfbef76
	.set	T_F41AA4_Nop, 0xfbefb0
	.set	LcdKeyRow1_CombinationNaming, 0xfbefb1
	.set	LcdKeyRow3_CombinationNaming, 0xfbefd2
	.set	LcdKeyRow4_CombinationNaming, 0xfbefe6
	.set	LcdKeyRow5_CombinationNaming, 0xfbeffa
	.set	ExitKey_CombinationNaming, 0xfbf00d
	.set	CombinationNamingWrite_NoAction, 0xfbf235
	.set	LcdKeyRow1_CombinationNamingWrite, 0xfbf274
	.set	LcdKeyRow2_CombinationNamingWrite, 0xfbf295
	.set	ExitKey_CombinationNamingWrite, 0xfbf2ab
	.set	SoftKeyCol2_CombiEditConfigure, 0xfbf499
	.set	SoftKeyCol4_CombiEditConfigure, 0xfbf50f
	.set	SoftKeyCol5_CombiEditConfigure, 0xfbf53a
	.set	SoftKeyCol6_CombiEditConfigure, 0xfbf582
	.set	SoftKeyCol7_CombiEditConfigure, 0xfbf5ca
	.set	LcdKeyRow1_CombiEditConfigure, 0xfbf5f5
	.set	LcdKeyRow2_CombiEditConfigure, 0xfbf609
	.set	LcdKeyRow3_CombiEditConfigure, 0xfbf62f
	.set	LcdKeyRow4_CombiEditConfigure, 0xfbf655
	.set	ExitKey_CombiEditConfigure, 0xfbf67b
	.set	ScreenEnter_CombiEditMenu, 0xfbfab0
	.set	T_F41A1C_Nop, 0xfbfaf1
	.set	ScreenButton_CombiEditMenu, 0xfbfaf2
	.set	T_F41A24_Nop, 0xfbfb33
	.set	LcdKeyRow1_CombiEditMenu, 0xfbfb34
	.set	LcdKeyRow2_CombiEditMenu, 0xfbfb68
	.set	LcdKeyRow3_CombiEditMenu, 0xfbfb9a
	.set	LcdKeyRow4_CombiEditMenu, 0xfbfbc1
	.set	LcdKeyRow5_CombiEditMenu, 0xfbfbe8
	.set	ExitKey_CombiEditMenu, 0xfbfc0f
	.set	SoftKeyCol1_CombiEditMenu, 0xfbfc53
	.set	ExitKey_Effect2OutputConflict, 0xfbfe1f
	.set	LcdKeyRow3_WriteProtectError, 0xfbff02
	.set	WriteProtectError_Dismiss, 0xfbff19
	.set	Msg0716_InitAllRecords_Entry, 0xfc0000
	.set	T_F40FF4_Nop, 0xfc018d
	.set	SoundRemap_ResetToDefault, 0xfc01b1
	.set	CombiRemap_ResetToDefault, 0xfc01c7
	.set	DrumMap_ResetToDefault, 0xfc01dd
	.set	Msg0716_PostClearSoundRamAndRestageAllParts, 0xfc01f3
	.set	Msg0716_PostRestageAllParts, 0xfc0206
	.set	Msg0716_PostSysEx50_92_SaveRegs, 0xfc020f
	.set	T_F40FF8_Nop, 0xfc024f
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_Msg0716_HandlerTables_13, 0xfc0250
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_8_Msg0716_HandlerTables_13, 0xfc0260
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_16_Msg0716_HandlerTables_13, 0xfc0270
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_24_Msg0716_HandlerTables_13, 0xfc0280
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_32_Msg0716_HandlerTables_13, 0xfc0290
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_40_Msg0716_HandlerTables_13, 0xfc02a0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_48_Msg0716_HandlerTables_13, 0xfc02b0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_56_Msg0716_HandlerTables_13, 0xfc02c0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_64_Msg0716_HandlerTables_13, 0xfc02d0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_72_Msg0716_HandlerTables_13, 0xfc02e0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_80_Msg0716_HandlerTables_13, 0xfc02f0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_88_Msg0716_HandlerTables_13, 0xfc0300
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_96_Msg0716_HandlerTables_13, 0xfc0310
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_104_Msg0716_HandlerTables_13, 0xfc0320
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_112_Msg0716_HandlerTables_13, 0xfc0330
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_120_Msg0716_HandlerTables_13, 0xfc0340
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_128_Msg0716_HandlerTables_13, 0xfc0350
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_136_Msg0716_HandlerTables_13, 0xfc0360
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_144_Msg0716_HandlerTables_13, 0xfc0370
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_152_Msg0716_HandlerTables_13, 0xfc0380
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_160_Msg0716_HandlerTables_13, 0xfc0390
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_168_Msg0716_HandlerTables_13, 0xfc03a0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_176_Msg0716_HandlerTables_13, 0xfc03b0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_184_Msg0716_HandlerTables_13, 0xfc03c0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_192_Msg0716_HandlerTables_13, 0xfc03d0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_200_Msg0716_HandlerTables_13, 0xfc03e0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_208_Msg0716_HandlerTables_13, 0xfc03f0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_216_Msg0716_HandlerTables_13, 0xfc0400
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_224_Msg0716_HandlerTables_13, 0xfc0410
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_232_Msg0716_HandlerTables_13, 0xfc0420
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_240_Msg0716_HandlerTables_13, 0xfc0430
	.set	Msg0716_DispatchIndex_Entry, 0xfc043c
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_248_Msg0716_HandlerTables_13, 0xfc0440
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_Msg0716_HandlerTables_56_26, 0xfc0450
	.set	Msg0716_DispatchIndex_Msg0716_HandlerTables_56_26, 0xfc0455
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_8_Msg0716_HandlerTables_56_26, 0xfc0460
	.set	Msg0716_DispatchIndex_26, 0xfc046a
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_16_Msg0716_HandlerTables_56_26, 0xfc0470
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_24_Msg0716_HandlerTables_56_26, 0xfc0480
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_32_Msg0716_HandlerTables_56_26, 0xfc0490
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_40_Msg0716_HandlerTables_56_26, 0xfc04a0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_48_Msg0716_HandlerTables_56_26, 0xfc04b0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_56_Msg0716_HandlerTables_56_26, 0xfc04c0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_64_Msg0716_HandlerTables_56_26, 0xfc04d0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_72_Msg0716_HandlerTables_56_26, 0xfc04e0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_80_Msg0716_HandlerTables_56_26, 0xfc04f0
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_88_Msg0716_HandlerTables_56_26, 0xfc0500
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_96_Msg0716_HandlerTables_56_26, 0xfc0510
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_104_Msg0716_HandlerTables_56_26, 0xfc0520
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_112_Msg0716_HandlerTables_56_26, 0xfc0530
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_120_Msg0716_HandlerTables_56_26, 0xfc0540
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_128_Msg0716_HandlerTables_56_26, 0xfc0551
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_136_Msg0716_HandlerTables_56_26, 0xfc0561
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_144_Msg0716_HandlerTables_56_26, 0xfc0571
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_152_Msg0716_HandlerTables_56_26, 0xfc0581
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_160_Msg0716_HandlerTables_56_26, 0xfc0591
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_168_Msg0716_HandlerTables_56_26, 0xfc05a1
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_176_Msg0716_HandlerTables_56_26, 0xfc05b1
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_184_Msg0716_HandlerTables_56_26, 0xfc05c1
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_192_Msg0716_HandlerTables_56_26, 0xfc05d1
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_200_Msg0716_HandlerTables_56_26, 0xfc05e1
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_208_Msg0716_HandlerTables_56_26, 0xfc05f1
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_216_Msg0716_HandlerTables_56_26, 0xfc0601
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_224_Msg0716_HandlerTables_56_26, 0xfc0611
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_232_Msg0716_HandlerTables_56_26, 0xfc0621
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_240_Msg0716_HandlerTables_56_26, 0xfc0631
	.set	Msg0716_DispatchIndex_Msg0716_ObjectRecords_248_Msg0716_HandlerTables_56_26, 0xfc0641
	.set	T_F410F0_Nop, 0xfc0651
	.set	T_F410F4_Nop, 0xfc0653
	.set	T_F410F8_Nop, 0xfc0654
	.set	T_F410FC_Nop, 0xfc0655
	.set	T_F41100_Nop, 0xfc0656
	.set	T_F41104_Nop, 0xfc0657
	.set	T_F41108_Nop, 0xfc0658
	.set	T_F4110C_Nop, 0xfc0659
	.set	Msg0716_SetPendingBit0, 0xfc065a
	.set	Msg0716_SetPendingBit1, 0xfc0663
	.set	Msg0716_SetPendingBit2, 0xfc066c
	.set	Msg0716_SetPendingBit3, 0xfc0675
	.set	T_F41120_Nop, 0xfc067e
	.set	T_F41124_Nop, 0xfc067f
	.set	T_F41128_Nop, 0xfc0680
	.set	T_F4112C_Nop, 0xfc0681
	.set	T_F41130_Nop, 0xfc0682
	.set	T_F41134_Nop, 0xfc0683
	.set	T_F41138_Nop, 0xfc0684
	.set	T_F4113C_Nop, 0xfc0685
	.set	Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_164_6, 0xfc0686
	.set	T_F41144_Nop, 0xfc0691
	.set	Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_280_2, 0xfc0692
	.set	T_F4114C_Nop, 0xfc069d
	.set	T_F41150_Nop, 0xfc069e
	.set	Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_292_14, 0xfc069f
	.set	Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_192_13, 0xfc06aa
	.set	Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_248_7, 0xfc06b5
	.set	Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_352_4, 0xfc06c0
	.set	T_F41164_Nop, 0xfc06cb
	.set	UiListB_Class9A_Nop, 0xfc06cc
	.set	Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_372_19, 0xfc06d0
	.set	T_F41170_Nop, 0xfc06db
	.set	T_F41174_Nop, 0xfc06dc
	.set	T_F41178_Nop, 0xfc06dd
	.set	T_F4117C_Nop, 0xfc06de
	.set	Msg0716_EventPartPostCC78_AllSoundOff, 0xfc06df
	.set	Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_452_17, 0xfc06f4
	.set	Msg0716_OnPitchBendEvent, 0xfc06ff
	.set	Msg0716_EventPartPostCC01_ModulationIfEnabled, 0xfc0724
	.set	Msg0716_EventPartPostCC0B_Expression, 0xfc0749
	.set	Msg0716_OnChannelPressureEvent, 0xfc075e
	.set	Msg0716_EventPartPostCC40_SustainFromValueIfEnabled, 0xfc078a
	.set	T_F42508_Nop, 0xfc07af
	.set	T_F4250C_Nop, 0xfc07b0
	.set	Msg0716_EventPartPostCC10_GeneralPurpose1IfEnabled, 0xfc07b1
	.set	Msg0716_EventPartPostCC11_GeneralPurpose2IfEnabled, 0xfc07d6
	.set	Msg0716_EventPartPostCC12_GeneralPurpose3IfEnabled, 0xfc07fb
	.set	Msg0716_EventPartPostCC13_GeneralPurpose4IfEnabled, 0xfc0820
	.set	Msg0716_EventPartPostCC02_BreathIfEnabled, 0xfc0845
	.set	Msg0716_EventPartPostCC04_FootIfEnabled, 0xfc086a
	.set	Msg0716_FlushIfPending, 0xfc0e56
	.set	Msg0716_FlushPending, 0xfc0e6b
	.set	T_F40FB8_Nop, 0xfc0fbd
	.set	T_F40FBC_Nop, 0xfc0fbe
	.set	T_F40FE4_Nop, 0xfc10da
	.set	T_F40FE0_Nop, 0xfc10db
	.set	Msg0716_AllPartsResetBendAndModulation, 0xfc10dd
	.set	Msg0716_AllPartsSustainOff, 0xfc10fa
	.set	sub_FC1116, 0xfc1116
	.set	Cpu2Query_RefreshPartSoundRecord, 0xfc11fb
	.set	Msg0716_PostGmSystemOnOff, 0xfc182f
	.set	Msg0716_PostSysEx50_A3, 0xfc188f
	.set	Msg0716_PostSysEx50_87_StackArg, 0xfc18aa
	.set	Msg0716_PostSysEx50_87, 0xfc18b2
	.set	T_F40FD8_Nop, 0xfc19dc
	.set	SoundName_Lookup, 0xfc1b81
	.set	CombiName_Lookup, 0xfc1c59
	.set	T_F40FC8_Nop, 0xfc1cd1
	.set	Cpu2Query_DrainRecordReplies, 0xfc1d92
	.set	CreatorSelect_ReadSlotLabelIds, 0xfc1e68
	.set	SoundGroupName_Lookup, 0xfc2035
	.set	CombiGroupName_Lookup, 0xfc2155
	.set	sub_FC2213, 0xfc2213
	.set	SoundGroup_MaxMemberIndex_Get, 0xfc2222
	.set	SoundGroup_MaxMemberIndex_GetToneCopy, 0xfc2282
	.set	SoundSel_ToProgramAndBank, 0xfc22ba
	.set	CombiSel_ToNumberAndBank, 0xfc239b
	.set	SoundSel_FromProgramAndBank, 0xfc2403
	.set	CombiSel_FromNumberAndBank, 0xfc24e3
	.set	PartSound_FromProgramChange, 0xfc24eb
	.set	PartSound_ToProgramChange, 0xfc2526
	.set	DrumMap_MapNoteForPart_StackArgs, 0xfc25a2
	.set	DrumMap_MapNoteForPart, 0xfc25a8
	.set	DigitalEffect_Frame, 0xfc4000
	.set	DigitalEffect_Frame_End, 0xfc40b4
	.set	SoundEditDigitalEffect_Paint_DL2, 0xfc40d2
	.set	DigitalEffect_Header, 0xfc40f0
	.set	SoundEditDigitalEffect_Paint_DL1, 0xfc410f
	.set	DigitalEffect_Header_End, 0xfc420f
	.set	DigitalEffect_ParamLabelLists, 0xfc4532
	.set	DigitalEffect_Values, 0xfc4592
	.set	SoundEditDigitalEffect_RepaintField_DL, 0xfc45a1
	.set	DLRec_FC45BF, 0xfc45bf
	.set	DLRec_FC45CA, 0xfc45ca
	.set	DigitalEffect_ParamValueLists, 0xfc45d5
	.set	DigitalEffect_FieldRecords_FC46BD, 0xfc46bd
	.set	DigitalEffect_FieldRecordArrays, 0xfc47cf
	.set	DigitalEffect_FrameEnds, 0xfc47ff
	.set	Widget_FC48D7, 0xfc48d7
	.set	Widget_FC4931, 0xfc4931
	.set	Widget_FC498B, 0xfc498b
	.set	Widget_FC49E5, 0xfc49e5
	.set	Widget_FC4A3F, 0xfc4a3f
	.set	Widget_FC4A99, 0xfc4a99
	.set	Widget_FC4AF3, 0xfc4af3
	.set	Widget_FC4B4D, 0xfc4b4d
	.set	SoundEditCopy_Frame, 0xfc4ba7
	.set	SoundEditCopy_Frame_End, 0xfc4d77
	.set	SoundEditCopy_DrumLabels, 0xfc4deb
	.set	SoundEditCopy_DrumLabels_End, 0xfc4e54
	.set	SoundEditCopy_DrumValues, 0xfc4e8c
	.set	SoundEditCopy_DrumValues_End, 0xfc4ec4
	.set	SoundEditCopy_Field2Box, 0xfc4ee2
	.set	SoundEditCopy_Field2Box_End, 0xfc4eec
	.set	SoundEditCopy_ToneFieldRecords, 0xfc4fa6
	.set	SoundEditCopy_DrumFieldRecords, 0xfc4fb6
	.set	DisplayList_FC5110_End, 0xfc512e
	.set	DisplayList_FC517E, 0xfc517e
	.set	SoundEditMenu_RepaintField_DL3, 0xfc51b1
	.set	DLRec_FC51D3, 0xfc51d3
	.set	SoundEditMenu_RepaintField_DL4, 0xfc51f9
	.set	DLRec_FC521B, 0xfc521b
	.set	SoundEditMenu_RepaintField_DL1, 0xfc524d
	.set	DLRec_FC526F, 0xfc526f
	.set	DisplayList_FC517E_End, 0xfc527a
	.set	SoundEditMenu_RepaintField_DL2, 0xfc52aa
	.set	DisplayList_FC52AA_End, 0xfc52b4
	.set	NoteRouting_PhaseVector, 0xfc5400
	.set	NoteRouting_RebuildIfPending, 0xfc546a
	.set	NoteRouting_RebuildForSong, 0xfc54c6
	.set	NoteRouting_Rebuild, 0xfc5518
	.set	NoteRouting_SetSoloAndRebuild, 0xfc5566
	.set	NoteRouting_OnPartMidiEvent, 0xfc55ca
	.set	NoteRouting_OnPartPlayParamEvent, 0xfc57f0
	.set	T_F411E8_Nop, 0xfc596c
	.set	T_F411C8_Nop, 0xfc596d
	.set	T_F411CC_Nop, 0xfc596e
	.set	NoteRouting_OnPlayModeRequest, 0xfc596f
	.set	NoteRouting_OnMidiSystemEvent, 0xfc59ac
	.set	T_F411D8_Nop, 0xfc5aca
	.set	T_F411DC_Nop, 0xfc5acb
	.set	NoteRouting_SetMidiOutPorts, 0xfc5acc
	.set	T_F411E4_Nop, 0xfc5b25
	.set	Ram3800_Start_Entry, 0xfc8000
	.set	Ram3800_InitDataImage, 0xfc807d
	.set	T_F413E4_Nop, 0xfc80dc
	.set	T_F413E8_Nop, 0xfc80dd
	.set	T_F413EC_Nop, 0xfc80de
	.set	T_F413F0_Nop, 0xfc80df
	.set	T_F413F4_Nop, 0xfc80e0
	.set	MidiInA_ProcessRing, 0xfc80e2
	.set	MidiInB_ProcessRing, 0xfc8448
	.set	Ring601850_ProcessNoteEvents, 0xfc87ae
	.set	TimedEvents_ProcessRing, 0xfc8960
	.set	PartNotes_ReleaseAllReceivedMidiIn, 0xfc8a8d
	.set	NoteList_ReleaseAllSource0, 0xfc8b36
	.set	PartNotes_ReleaseAllTrackNotes, 0xfc8ce0
	.set	sub_FC8D45, 0xfc8d45
	.set	NoteRouting_ApplyQueuedChanges, 0xfc8d49
	.set	PartNoteList_NextHeldNote, 0xfc8e7b
	.set	ToneGen_SendSoundSelNote, 0xfc8fd7
	.set	MidiOut_SendNote, 0xfc9016
	.set	NoteRouting_DefaultRecordPtrs, 0xfcad7c
	.set	PartNotes_ResoundOnToneGen, 0xfcb2f0
	.set	PanelOpTable_FCF383, 0xfcf383
	.set	PanelOpTable_FCF3CB, 0xfcf3cb
	.set	PanelOpTable_FCF413, 0xfcf413
	.set	PanelOpTable_FCF45B, 0xfcf45b
	.set	PanelOpTable_FCFB6C, 0xfcfb6c
	.set	PanelOpTable_FCFBB4, 0xfcfbb4
	.set	PanelOpTable_FCFBFC, 0xfcfbfc
	.set	PanelOpTable_FCFC44, 0xfcfc44
	.set	PanelOpTable_FCFC8C, 0xfcfc8c
	.set	IndexMap_FCFCD4, 0xfcfcd4
	.set	StepValues_FCFCD8, 0xfcfcd8
	.set	StepValues_FCFCDF, 0xfcfcdf
	.set	StepValues_FCFCE1, 0xfcfce1
	.set	ScreenButton_SoundEditMenu, 0xfcfda7
	.set	ScreenButton_SoundEditControllerPage1, 0xfd053d
	.set	ScreenButton_SoundEditControllerPage2, 0xfd058e
	.set	ScreenButton_SoundEditModelingToneTemplate, 0xfd0aa5
	.set	ScreenButton_SoundEditToneLayerPanning, 0xfd0af6
	.set	ScreenButton_SoundEditToneLayerKeyLayer, 0xfd0b47
	.set	ScreenButton_SoundEditToneLayerVelocityLayer, 0xfd0ba7
	.set	ScreenButton_SoundEditModelingDriverWaveform, 0xfd0c07
	.set	Ring608A0A_DrainAll, 0xfd2504
	.set	ScreenButton_SoundEditAmpLevel1, 0xfd2751
	.set	ScreenButton_SoundEditAmpLevel2, 0xfd27a2
	.set	ScreenButton_SoundEditAmpEnvelope1, 0xfd27f2
	.set	ScreenButton_SoundEditAmpEnvelope2, 0xfd2852
	.set	ScreenButton_SoundEditAmpLfo, 0xfd28b2
	.set	ToneEditPage_A0_KeyDispatch, 0xfd3da7
	.set	T_F41F84_Nop, 0xfd3df8
	.set	T_F41F94_Nop, 0xfd3df9
	.set	ToneEditPage_A3_KeyDispatch, 0xfd3dfa
	.set	ToneEditPage_A4_KeyDispatch, 0xfd3e4b
	.set	ToneEditPage_A5_KeyDispatch, 0xfd3e9c
	.set	ToneEditPage_A6_KeyDispatch, 0xfd3eed
	.set	ToneEditPage_A7_KeyDispatch, 0xfd3f3e
	.set	ToneEditPage_A8_KeyDispatch, 0xfd3f8f
	.set	PanelScreen_PostRequest, 0xfd608b
	.set	PanelScreen_RequestPending, 0xfd60b9
	.set	PanelScreen_PostRequestBit6, 0xfd60d9
	.set	Var27DF_Set, 0xfd6104
	.set	Var2250_Get, 0xfd6122
	.set	ToneMsg_SendParam, 0xfd616a
	.set	ToneMsg80_SendParam, 0xfd61cf
	.set	ToneMsg80_Id01, 0xfd622b
	.set	ToneMsg85_SendParam, 0xfd63d7
	.set	ToneMsg80_Id00, 0xfd6447
	.set	ToneMsg80_Id04, 0xfd648d
	.set	ToneMsg80_Id15_Part0, 0xfd64d1
	.set	ToneMsg80_Id16, 0xfd6513
	.set	ToneMsg88_Id13, 0xfd665c
	.set	ToneMsg88_Id14, 0xfd66a6
	.set	ToneMsg8D_SendParam, 0xfd6704
	.set	ToneMsg88_Id1A, 0xfd6811
	.set	ToneMsg_SendP23FromArr2800, 0xfd69e0
	.set	Var27A3_GetValidSlot, 0xfd6b4d
	.set	Arr27A6_Set, 0xfd6c65
	.set	Arr27A6_Get, 0xfd6c7b
	.set	U8_ShiftLeft, 0xfd6c94
	.set	ToneEdit_ApplyStep, 0xfd6ce1
	.set	Var27A2_ToggleWithP23, 0xfd6e90
	.set	ToneEdit_CommitField, 0xfd7435
	.set	Var27A3_ChangeSlot, 0xfd74ae
	.set	SoundEditLfo_CycleLfoState, 0xfd74e0
	.set	SoundEditText_SetSlot, 0xfd77b3
	.set	SoundEditText_GetSlot, 0xfd785c
	.set	PanelEvent_ToFieldIndex, 0xfd7905
	.set	Mem_CopyBytes, 0xfd79dc
	.set	SoundConv_SetArgs4, 0xfd7add
	.set	SoundConv_GetResults, 0xfd7b00
	.set	Var27E9_Get, 0xfd7b6b
	.set	Var27E9_Set, 0xfd7b7b
	.set	Arr22F0_Set, 0xfd7b89
	.set	Arr22F0_Get, 0xfd7ba5
	.set	PanelDial_SetButtonMode, 0xfd7bc3
	.set	PanelDial_SetDirectionButton, 0xfd7bde
	.set	PanelDial_ActAsButton, 0xfd7c01
	.set	ToneEdit_StepFromEvent, 0xfd7c2d
	.set	NameChar_IndexToAsciiOrSpace, 0xfd7c5a
	.set	NameChar_AsciiToIndexClamped, 0xfd7c83
	.set	SoundEditLfo_SoftKeyCol2, 0xfd7e1a
	.set	SoundEditLfo_SoftKeyCol3, 0xfd7e66
	.set	SoundEditLfo_SoftKeyCol4, 0xfd7ed9
	.set	SoundEditLfo_SoftKeyCol5, 0xfd7f4c
	.set	SoundEditLfo_SoftKeyCol6, 0xfd7fbf
	.set	SoundEditLfo_SoftKeyCol7, 0xfd8030
	.set	SoundEditLfo_SoftKeyCol8, 0xfd80a3
	.set	SoundEditEnvelope1_SetField0AndRedraw, 0xfd8116
	.set	SoundEditEnvelope1_SoftKeyCol1, 0xfd8155
	.set	SoundEditEnvelope1_SoftKeyCol2, 0xfd81c8
	.set	SoundEditEnvelope1_SoftKeyCol3, 0xfd823b
	.set	SoundEditEnvelope1_SoftKeyCol4, 0xfd82d8
	.set	SoundEditEnvelope1_SoftKeyCol5, 0xfd834b
	.set	SoundEditEnvelope1_SoftKeyCol6, 0xfd83e8
	.set	SoundEditEnvelope1_SoftKeyCol7, 0xfd845b
	.set	SoundEditEnvelope2_SoftKeyCol2, 0xfd84f8
	.set	SoundEditEnvelope2_SoftKeyCol3, 0xfd859b
	.set	SoundEditEnvelope2_SoftKeyCol4, 0xfd863e
	.set	SoundEditEnvelope2_SoftKeyCol5, 0xfd86e1
	.set	SoundEditEnvelope2_SoftKeyCol7, 0xfd8747
	.set	SoundEditEnvelope2_SoftKeyCol8, 0xfd87a5
	.set	Var27A3_SelectSlot, 0xfd9863
	.set	Var27F4_Get, 0xfd9d5c
	.set	ModelingPage_GroupStartIndex, 0xfda002
	.set	ModelingPage_GetItemGroup, 0xfda05e
	.set	Var27F6_Set, 0xfda0ac
	.set	Var27F6_Get, 0xfda0ba
	.set	Var27F5_Get, 0xfda0ca
	.set	Var27F7_GetW, 0xfda0f6
	.set	Var27F9_GetW, 0xfda114
	.set	Var27FC_Get, 0xfda142
	.set	Var27FC_Set, 0xfda152
	.set	PartNotes_GetCurrentPartHeldNote, 0xfda194
	.set	DrumSoundNames_FetchNext, 0xfda252
	.set	Var27FE_Set, 0xfda341
	.set	UiRequestBits_SetBit3, 0xfda467
	.set	sub_FDA6FC, 0xfda6fc
	.set	SoundEditPitchTune_KeyScalingPosToParam, 0xfda777
	.set	MemoryProtect_IsSoundOn, 0xfda901
	.set	DspEffect_SendAllToCpu2, 0xfda911
	.set	LCD_SetPanelDarkFlag, 0xfdac5b
	.set	ModeEnter_SoundEdit, 0xfdac6b
	.set	sub_FDACBD, 0xfdacbd
	.set	ScreenEnter_SoundEditMenu, 0xfdad44
	.set	ScreenEnter_SoundEditPitchTune, 0xfdb22f
	.set	sub_FDB30B, 0xfdb30b
	.set	ScreenEnter_SoundEditPitchEnvelope1, 0xfdb38c
	.set	ScreenEnter_SoundEditPitchEnvelope2, 0xfdb44d
	.set	ScreenEnter_SoundEditPitchLfo, 0xfdb529
	.set	ScreenEnter_SoundEditAmpLevel1, 0xfdb693
	.set	sub_FDB858, 0xfdb858
	.set	sub_FDB8D1, 0xfdb8d1
	.set	ScreenEnter_SoundEditAmpLevel2, 0xfdb8d9
	.set	ScreenEnter_SoundEditAmpEnvelope1, 0xfdb9ab
	.set	ScreenEnter_SoundEditAmpEnvelope2, 0xfdbae7
	.set	ScreenEnter_SoundEditAmpLfo, 0xfdbbc3
	.set	ScreenEnter_SoundEditControllerPage1, 0xfdbbd6
	.set	ScreenEnter_SoundEditControllerPage2, 0xfdbede
	.set	ScreenEnter_SoundEditDigitalEffectFromMenu, 0xfdc0e1
	.set	ScreenEnter_SoundEditFilterLpf12, 0xfdc0ed
	.set	sub_FDC0FD, 0xfdc0fd
	.set	sub_FDC22F, 0xfdc22f
	.set	ScreenEnter_SoundEditFilterHpf12, 0xfdc27b
	.set	sub_FDC2A2, 0xfdc2a2
	.set	ScreenEnter_SoundEditFilterLpf24, 0xfdc2a7
	.set	ScreenEnter_SoundEditFilterHpf24, 0xfdc2cf
	.set	ScreenEnter_SoundEditFilterBpf, 0xfdc2f7
	.set	ScreenEnter_SoundEditFilterThrough, 0xfdc317
	.set	ScreenEnter_SoundEditFilterKeyFollow, 0xfdc333
	.set	sub_FDC3F9, 0xfdc3f9
	.set	ScreenEnter_SoundEditFilterEnvelope1, 0xfdc405
	.set	sub_FDC438, 0xfdc438
	.set	ScreenEnter_SoundEditFilterEnvelope2, 0xfdc4c6
	.set	ScreenEnter_SoundEditFilterLfo, 0xfdc5a2
	.set	ScreenEnter_SoundEditModelingToneTemplate, 0xfdc5b5
	.set	sub_FDC5BB, 0xfdc5bb
	.set	sub_FDC62E, 0xfdc62e
	.set	sub_FDC6CB, 0xfdc6cb
	.set	ScreenEnter_SoundEditToneLayerPanning, 0xfdc84c
	.set	sub_FDC87E, 0xfdc87e
	.set	ScreenEnter_SoundEditToneLayerKeyLayer, 0xfdc95b
	.set	sub_FDC9C4, 0xfdc9c4
	.set	ScreenEnter_SoundEditToneLayerVelocityLayer, 0xfdca77
	.set	ScreenEnter_SoundEditModelingDriverWaveform, 0xfdcb93
	.set	ScreenEnter_SoundEditMemoryWrite, 0xfdcde0
	.set	ScreenEnter_SoundEditNaming, 0xfdcfeb
	.set	ScreenEnter_SoundEditDigitalEffect, 0xfdd02d
	.set	ScreenEnter_SoundEditCopy, 0xfdd0d4
	.set	ScreenEnter_SoundEditDspEffect, 0xfdd272
	.set	ScreenEnter_SoundEditDrumMenu, 0xfdd27f
	.set	T_F42340_Nop, 0xfdd436
	.set	ToneEditPage_A0_ModelingTop, 0xfdd437
	.set	T_F41F7C_Nop, 0xfdd7f7
	.set	T_F41F8C_Nop, 0xfdd7f8
	.set	ToneEditPage_A3_PositionParameter, 0xfdd7f9
	.set	ToneEditPage_A4_PositionMovement, 0xfdd958
	.set	ToneEditPage_A5_FittingMutingTuning, 0xfdda1c
	.set	ToneEditPage_A6_TouchDepth, 0xfddc3a
	.set	ToneEditPage_A7_ResoModeKeyFollow, 0xfdddaa
	.set	ToneEditPage_A8_SerialParallel, 0xfddf36
	.set	T_F433E0_Nop, 0xfde151
	.set	ScreenLeave_SoundEditMenu, 0xfde152
	.set	T_F41F68_Nop, 0xfde15f
	.set	ScreenLeave_SoundEditPitchTune, 0xfde160
	.set	T_F42008_Nop, 0xfde16d
	.set	ScreenLeave_SoundEditPitchEnvelope1, 0xfde16e
	.set	T_F42018_Nop, 0xfde17b
	.set	ScreenLeave_SoundEditPitchEnvelope2, 0xfde17c
	.set	T_F42028_Nop, 0xfde189
	.set	ScreenLeave_SoundEditPitchLfo, 0xfde18a
	.set	T_F42038_Nop, 0xfde197
	.set	ScreenLeave_SoundEditAmpLevel1, 0xfde198
	.set	T_F42048_Nop, 0xfde1a5
	.set	ScreenLeave_SoundEditAmpLevel2, 0xfde1a6
	.set	T_F42058_Nop, 0xfde1b3
	.set	ScreenLeave_SoundEditAmpEnvelope1, 0xfde1b4
	.set	ScreenLeave_SoundEditAmpEnvelope2, 0xfde1c2
	.set	T_F42078_Nop, 0xfde1cf
	.set	ScreenLeave_SoundEditAmpLfo, 0xfde1d0
	.set	T_F42068_Nop, 0xfde1dd
	.set	ScreenLeave_SoundEditControllerPage1, 0xfde1de
	.set	T_F42098_Nop, 0xfde1eb
	.set	ScreenLeave_SoundEditControllerPage2, 0xfde1ec
	.set	T_F420A8_Nop, 0xfde1f9
	.set	ScreenLeave_SoundEditDigitalEffectFromMenu, 0xfde1fa
	.set	T_F420B8_Nop, 0xfde207
	.set	ScreenLeave_SoundEditModelingToneTemplate, 0xfde208
	.set	T_F42168_Nop, 0xfde215
	.set	ScreenLeave_SoundEditToneLayerPanning, 0xfde216
	.set	T_F42178_Nop, 0xfde223
	.set	ScreenLeave_SoundEditToneLayerKeyLayer, 0xfde224
	.set	T_F42188_Nop, 0xfde231
	.set	ScreenLeave_SoundEditToneLayerVelocityLayer, 0xfde232
	.set	T_F42198_Nop, 0xfde23f
	.set	ScreenLeave_SoundEditModelingDriverWaveform, 0xfde240
	.set	T_F421A8_Nop, 0xfde24d
	.set	ScreenLeave_SoundEditFilterLpf12, 0xfde24e
	.set	T_F420C8_Nop, 0xfde25b
	.set	ScreenLeave_SoundEditFilterHpf12, 0xfde25c
	.set	T_F420D8_Nop, 0xfde269
	.set	ScreenLeave_SoundEditFilterLpf24, 0xfde26a
	.set	T_F420E8_Nop, 0xfde277
	.set	ScreenLeave_SoundEditFilterHpf24, 0xfde278
	.set	T_F420F8_Nop, 0xfde285
	.set	ScreenLeave_SoundEditFilterBpf, 0xfde286
	.set	T_F42108_Nop, 0xfde293
	.set	ScreenLeave_SoundEditFilterThrough, 0xfde294
	.set	T_F42118_Nop, 0xfde2a1
	.set	ScreenLeave_SoundEditFilterKeyFollow, 0xfde2a2
	.set	T_F42128_Nop, 0xfde2af
	.set	ScreenLeave_SoundEditFilterEnvelope1, 0xfde2b0
	.set	T_F42138_Nop, 0xfde2bd
	.set	ScreenLeave_SoundEditFilterEnvelope2, 0xfde2be
	.set	T_F42148_Nop, 0xfde2cb
	.set	ScreenLeave_SoundEditFilterLfo, 0xfde2cc
	.set	T_F42158_Nop, 0xfde2d9
	.set	T_F42364_Nop, 0xfde2da
	.set	T_F4236C_Nop, 0xfde2db
	.set	T_F42374_Nop, 0xfde2dc
	.set	T_F4237C_Nop, 0xfde2dd
	.set	ScreenLeave_SoundEditDigitalEffect, 0xfde2ec
	.set	T_F433DC_Nop, 0xfde2f9
	.set	ScreenLeave_SoundEditCopy, 0xfde2fa
	.set	T_F4235C_Nop, 0xfde307
	.set	ScreenLeave_SoundEditDspEffect, 0xfde308
	.set	T_F4232C_Nop, 0xfde315
	.set	ScreenLeave_SoundEditDrumMenu, 0xfde316
	.set	T_F4233C_Nop, 0xfde323
	.set	ScreenLeave_CodeCC, 0xfde324
	.set	T_F4234C_Nop, 0xfde331
	.set	ToneEditPage_A0_Leave, 0xfde332
	.set	T_F41F78_Nop, 0xfde33f
	.set	ToneEditPage_A1_Leave, 0xfde340
	.set	T_F41F88_Nop, 0xfde34d
	.set	ToneEditPage_A2_Leave, 0xfde34e
	.set	T_F41F98_Nop, 0xfde35b
	.set	ToneEditPage_A3_Leave, 0xfde35c
	.set	T_F41FA8_Nop, 0xfde369
	.set	ToneEditPage_A4_Leave, 0xfde36a
	.set	T_F41FB8_Nop, 0xfde377
	.set	ToneEditPage_A5_Leave, 0xfde378
	.set	T_F41FC8_Nop, 0xfde385
	.set	ToneEditPage_A6_Leave, 0xfde386
	.set	T_F41FD8_Nop, 0xfde393
	.set	ToneEditPage_A7_Leave, 0xfde394
	.set	T_F41FE8_Nop, 0xfde3a1
	.set	ToneEditPage_A8_Leave, 0xfde3a2
	.set	T_F41FF8_Nop, 0xfde3af
	.set	ScreenLeave_CodeCE, 0xfde3b0
	.set	T_F433EC_Nop, 0xfde3bd
	.set	ScreenButton_SoundEditFilterLpf12, 0xfde3be
	.set	ScreenButton_SoundEditFilterHpf12, 0xfde41e
	.set	ScreenButton_SoundEditFilterLpf24, 0xfde47e
	.set	ScreenButton_SoundEditFilterHpf24, 0xfde4de
	.set	ScreenButton_SoundEditFilterBpf, 0xfde53e
	.set	ScreenButton_SoundEditFilterThrough, 0xfde59e
	.set	ScreenButton_SoundEditFilterKeyFollow, 0xfde5ef
	.set	ScreenButton_SoundEditFilterEnvelope1, 0xfde64f
	.set	ScreenButton_SoundEditFilterEnvelope2, 0xfde6af
	.set	ScreenButton_SoundEditFilterLfo, 0xfde70f
	.set	Disk_PhaseVector, 0xfe0000
	.set	MidiFileStream_ReaderTask, 0xfe02ab
	.set	MidiFileStream_GetByte, 0xfe0391
	.set	MidiFileStream_Close, 0xfe0435
	.set	MidiFileStream_Open, 0xfe04be
	.set	MidiFilePlay_OnSongSelect, 0xfe144e
	.set	Medley_NormFileCommand, 0xfe152e
	.set	SysPartMidi_ResetBlock1Default_Call, 0xfe1bca
	.set	BStore_Workspace_StoreParamImage, 0xfe1bce
	.set	sub_FE1BDE, 0xfe1bde
	.set	Disk_LoadSqfToWorkspace_Entry, 0xfe1beb
	.set	Disk_LoadSeqToHeap_Entry, 0xfe1bf3
	.set	Disk_SaveSqfFromStaging_Entry, 0xfe1bfb
	.set	Disk_SaveSeqFile_Entry, 0xfe1c03
	.set	Disk_MountAndScanMidiFilesResetRings, 0xfe1c0b
	.set	T_F42580_Nop, 0xfe1c16
	.set	sub_FE1C17, 0xfe1c17
	.set	T_F4258C_Nop, 0xfe1c1e
	.set	Disk_PortA3_Release_Call_Call, 0xfe1c1f
	.set	Playback_StopAllAndIgnoreMidiStart, 0xfe1c23
	.set	Disk_MountAndScanDirectory_Call, 0xfe1c27
	.set	Disk_MountAndScanDirectory_LeaveOnError_Call, 0xfe1c2b
	.set	sub_FE1C2F, 0xfe1c2f
	.set	sub_FE1C33, 0xfe1c33
	.set	DiskApi_ReadFileToWindow_Entry, 0xfe1c3a
	.set	DiskApi_WriteFileFromWindow_Entry, 0xfe1c4d
	.set	DiskApi_DeleteFile_Call, 0xfe1c55
	.set	MidiFileSave_Page3_LcdKeyRow3, 0xfe1c59
	.set	DiskLoadScreen_MountAndScanDirectory, 0xfe1c5d
	.set	DiskSaveScreen_MountAndScanDirectory, 0xfe1c67
	.set	Notes_ReleaseAllSources_Call_Call, 0xfe1c71
	.set	Disk_TickCountdowns, 0xfe1c75
	.set	DiskLoadFile_Execute, 0xfe1c79
	.set	DiskSaveFile_Execute_Entry, 0xfe1c80
	.set	MidiFileSave_Page5_LcdKeyRow3, 0xfe1c98
	.set	NameEdit_MoveCursor_Call, 0xfe1c9f
	.set	NameEdit_StepChar_Call, 0xfe1ca3
	.set	Playback_AcceptMidiStartAgain, 0xfe1ca7
	.set	Disk_SaveFileName_Call, 0xfe1cab
	.set	DiskApi_CloseFile_Call, 0xfe1caf
	.set	DiskSave_CheckFreeSpace, 0xfe1cb3
	.set	Disk_ResetAndMountFloppy_Call, 0xfe1cc0
	.set	Disk_PortA3_Release_Entry, 0xfe1cc4
	.set	DiskSaveFile_Page5_LcdKeyRow3, 0xfe1cc8
	.set	NameEdit_SyncCharIndex_Call, 0xfe1ccc
	.set	DiskSave_IsSelectedFileNew_Call, 0xfe1cd0
	.set	Var2216_SetW145C_Call, 0xfe1cd4
	.set	DiskProgress_PrintDotForSmf, 0xfe1cd8
	.set	DiskSaveFile_SaveOrConfirmOverwrite_Call, 0xfe1cdc
	.set	DiskSaveFile_CheckPasswordThenSave_Call, 0xfe1ce0
	.set	sub_FE1CE4, 0xfe1ce4
	.set	Disk_CommandDispatch_Thunk_Entry, 0xfe3000
	.set	Fdc_Request_Thunk_Entry, 0xfe3004
	.set	INT5_Dev7B_Receive_Alias, 0xfe3008
	.set	Fdc_ServiceDataByte_Isr_Entry, 0xfe300c
	.set	INTTC0_uDMA0Done_Alias, 0xfe3010
	.set	Disk_CommandDispatch_SaveRegs_Entry, 0xfe3014
	.set	Fdc_Request_SaveRegs_Entry, 0xfe3018
	.set	Disk_FormatSelectedMedia, 0xfe7200
	.set	Medley_Start, 0xfe7800
	.set	Medley_Stop, 0xfe782c
	.set	Medley_Next, 0xfe7848
	.set	Medley_AdvanceInternalSong, 0xfe7927
	.set	Medley_Tick, 0xfe7950
	.set	Medley_ScheduleNextMidiFile, 0xfe7a49
	.set	EditScreen_Tick_Call, 0xfe8000
	.set	PowerFail_PrepareSongWorkspace, 0xfe8005
	.set	Transport_ResetAndStartBC, 0xfe8026
	.set	ScreenLeave_DrumEditPartSelect, 0xfe8045
	.set	EditScreen_PhaseVector, 0xfe8046
	.set	T_F402B8_Nop, 0xfe805f
	.set	ScreenButton_Sequencer, 0xfe8060
	.set	ModeEnter_Sequencer, 0xfe810b
	.set	sub_FE8116, 0xfe8116
	.set	Paint_Sequencer, 0xfe812c
	.set	ScreenLeave_Sequencer, 0xfe8165
	.set	EditScreen_Tick, 0xfe82d7
	.set	EditScreen_BootPhase2And4, 0xfe833f
	.set	ShowScreen_NoteEditPartSelect, 0xfe836f
	.set	ShowScreen_DrumEditPartSelect, 0xfe83a3
	.set	ScreenLeave_NoteEditPartSelect, 0xfe8564
	.set	ScreenButton_EditPartSelect, 0xfe8565
	.set	EditScreen_EnterDrumEdit, 0xfe8868
	.set	EditScreen_EnterNoteEdit, 0xfe88aa
	.set	ScreenLeave_DrumEdit, 0xfe8c1f
	.set	ScreenLeave_NoteEdit, 0xfe8c3a
	.set	T_F402D8_Nop, 0xfe8cb3
	.set	ScreenButton_NoteEdit, 0xfe9a33
	.set	ScreenButton_DrumEdit, 0xfe9b8d
	.set	ModeEnter_SoundCopy, 0xff42b7
	.set	Var2134_SetBit1_3, 0xff42c0
	.set	ModeEnter_SoundCopy_Call, 0xff42c5
	.set	Var2134_SetBit1_3_Call, 0xff42c9
	.set	Paint_DiskMenu, 0xff42cd
	.set	ScreenLeave_DiskMenu, 0xff431b
	.set	PanelButtonDispatch_DiskMenu, 0xff431c
	.set	T_F42270_Nop, 0xff4407
	.set	Paint_MidiFileDirectPlay, 0xff4408
	.set	ScreenLeave_MidiFileDirectPlay, 0xff457c
	.set	PanelButtonDispatch_MidiFileDirectPlay, 0xff4596
	.set	T_F42280_Nop, 0xff475b
	.set	Paint_DiskL0adFile, 0xff4786
	.set	DiskLoad_SetContentTypeFromSelectedEntry, 0xff48f0
	.set	ScreenLeave_DiskL0adFile, 0xff4986
	.set	PanelButtonDispatch_DiskL0adFile, 0xff4995
	.set	T_F423AC_Nop, 0xff4ff9
	.set	Paint_MidiFileL0ad, 0xff4ffa
	.set	ScreenLeave_MidiFileL0ad, 0xff520c
	.set	PanelButtonDispatch_MidiFileL0ad, 0xff522f
	.set	T_F4240C_Nop, 0xff5489
	.set	PageDispatch_DiskSaveFile, 0xff548a
	.set	ScreenLeave_DiskSaveFile, 0xff571f
	.set	PanelButtonDispatch_DiskSaveFile, 0xff572e
	.set	T_F423BC_Nop, 0xff5c3d
	.set	PageDispatch_MidiFileSave, 0xff5c3e
	.set	ScreenLeave_MidiFileSave, 0xff5eae
	.set	PanelButtonDispatch_MidiFileSave, 0xff5ed1
	.set	T_F423CC_Nop, 0xff6511
	.set	Paint_FloppyDiskFormatSelectType, 0xff6512
	.set	ScreenLeave_FloppyDiskFormatSelectType, 0xff654f
	.set	PanelButtonDispatch_FloppyDiskFormatSelectType, 0xff6550
	.set	T_F423DC_Nop, 0xff6612
	.set	Paint_FloppyDiskFormatAreYouSure, 0xff6613
	.set	ScreenLeave_FloppyDiskFormatAreYouSure, 0xff66a9
	.set	PanelButtonDispatch_FloppyDiskFormatAreYouSure, 0xff66aa
	.set	T_F423FC_Nop, 0xff672c
	.set	PageDispatch_L0adSingleS0und, 0xff672d
	.set	ScreenLeave_L0adSingleS0und, 0xff68ca
	.set	PanelButtonDispatch_L0adSingleS0und, 0xff68d8
	.set	T_F423EC_Nop, 0xff6db6
	.set	PageDispatch_L0adSingleC0mbination, 0xff6db7
	.set	ScreenLeave_L0adSingleC0mbination, 0xff6f13
	.set	PanelButtonDispatch_L0adSingleC0mbination, 0xff6f21
	.set	T_F42428_Nop, 0xff7083
	.set	MidiFilePlay_SnapshotRecordBytes, 0xff70b6
	.set	PartRecords_RestoreShadowedField, 0xff70d8
	.set	DiskScreens_PhaseVector, 0xff75b6
	.set	MIDI_UART_Configure_Data, 0xfffff8
; <<< END prom_a ADDRESS EQUATES
.equ KERNEL_MEM_OPS_PROVIDED, 1	; records "already provided"; this image does not include the kernel

; >>> BEGIN MODULE INCLUDES (generated by scripts/tools/split_cpu1_images.py; do not edit by hand)
; prom_b is assembled from these 42 module sources, in address order.  A module ends where
; its 0x0E (`ret`) padding reaches an aligned address -- the firmware's own link layout;
; the rule, its two written-out exceptions and the proof that the cut changes no byte are
; in scripts/tools/split_cpu1_images.py.  Edit the module files; this block is regenerated.

	.include "prom_b/modules/f00000_f067ff_old_copies_and_display_lists.s"
	.include "prom_b/modules/f06800_f097ff_scale_and_sound_group_tables.s"
	.include "prom_b/modules/f09800_f0c7ff_sound_edit_screens.s"
	.include "prom_b/modules/f0c800_f0e7ff_midi_screen_display_lists.s"
	.include "prom_b/modules/f0e800_f1b3ff_blink_and_dsp_effect_editor.s"
	.include "prom_b/modules/f1b400_f27bff_fonts.s"
	.include "prom_b/modules/f27c00_f2c7ff_mode_screen_display_lists.s"
	.include "prom_b/modules/f2c800_f2cfff_test_mode_display_lists.s"
	.include "prom_b/modules/f2d000_f2d7ff_screen_field_lists.s"
	.include "prom_b/modules/f2d800_f327ff_messages_and_display_list_interpreter.s"
	.include "prom_b/modules/f32800_f33fff_sound_edit_display_lists.s"
	.include "prom_b/modules/f34000_f367ff_sequencer_display_lists.s"
	.include "prom_b/modules/f36800_f387ff_sysex_param_ranges.s"
	.include "prom_b/modules/f38800_f38fff_param_image_copy.s"
	.include "prom_b/modules/f39000_f3f3ff_sequencer_job_display_lists.s"
	.include "prom_b/modules/f3f400_f3ffff_factory_default_records.s"
	.include "prom_b/modules/f40000_f44017_routine_directory.s"
	.include "prom_b/modules/f44018_f477ff_sequencer_core.s"
	.include "prom_b/modules/f47800_f48bff_bstore_cursor_and_seq_cycle.s"
	.include "prom_b/modules/f48c00_f497ff_disk_file_signature.s"
	.include "prom_b/modules/f49800_f4bfff_seq_record.s"
	.include "prom_b/modules/f4c000_f4c7ff_creator_select_controller_screen.s"
	.include "prom_b/modules/f4c800_f4cfff_bstore_compaction.s"
	.include "prom_b/modules/f4d000_f4dfff_bstore_track_cursor.s"
	.include "prom_b/modules/f4e000_f4ebff_track_key_handlers.s"
	.include "prom_b/modules/f4ec00_f4efff_realtime_record.s"
	.include "prom_b/modules/f4f000_f4f7ff_part_sound_stepping.s"
	.include "prom_b/modules/f4f800_f52fff_sysex_param_descriptors.s"
	.include "prom_b/modules/f53000_f54fff_drawbar_screen.s"
	.include "prom_b/modules/f55000_f557ff_param_edit_primitives.s"
	.include "prom_b/modules/f55800_f57bff_seq_play_screens.s"
	.include "prom_b/modules/f57c00_f57fff_ring_put_block.s"
	.include "prom_b/modules/f58000_f5b7ff_disk_display_lists_and_sc1_link.s"
	.include "prom_b/modules/f5b800_f62bff_song_edit_jobs_and_tone_edit_draws.s"
	.include "prom_b/modules/f62c00_f64fff_block_store.s"
	.include "prom_b/modules/f65000_f65bff_song_edit_time_signatures.s"
	.include "prom_b/modules/f65c00_f673ff_track_assign_and_medley_screens.s"
	.include "prom_b/modules/f67400_f6efff_step_record.s"
	.include "prom_b/modules/f6f000_f7a3ff_smf_file_io_and_old_copy.s"
	.include "prom_b/modules/f7a400_f7a9ff_bstore_allocator.s"
	.include "prom_b/modules/f7aa00_f7cfff_song_store_commands.s"
	.include "prom_b/modules/f7d000_f7ffff_panel_screen_methods.s"
; <<< END MODULE INCLUDES
