; ===========================================================================
; Style UI Parameter Blocks & Screen Data
; ===========================================================================
;
; Style UI widget definitions for the accompaniment style editor.
; ParamBlock variants define different parameter layouts (BAL, VALUE, MEAS,
; Short, Medium, Extended, Common, Alt A-E). The pointer table maps UI
; screen indices to the appropriate ParamBlock.
;
; ScreenData blocks define full screen layouts (Main, MeasCursor, YesCtl,
; CtlOnly) referenced by the style editor's display system.
;
; ===========================================================================

; [nakarest] StyleUI_ParamBlock_BAL: Style-UI ScreenData bytecode -- the sd_* commands of
; [nakarest] style_ui/screendata_types.h (lines, rects, labelled refs, strings), typed in
; [nakarest] style_ui/paramblock/bal.c -- drawn by UIRender_TwoTableGeneral, which hands its
; [nakarest] xiy/xix pair to Scoop_EventLoop_12Entry (display/scoop_display.s).  Reached through
; [nakarest] StyleUI_ParamBlockPtrTable entries 0, 38.
StyleUI_ParamBlock_BAL:		.incbin "includes/generated/style_ui_paramblock_bal.bin"
; [nakarest] StyleUI_ParamBlock_VALUE: Style-UI ScreenData bytecode -- the sd_* commands of
; [nakarest] style_ui/screendata_types.h (lines, rects, labelled refs, strings), typed in
; [nakarest] style_ui/paramblock/value.c -- drawn by UIRender_TwoTableGeneral, which hands its
; [nakarest] xiy/xix pair to Scoop_EventLoop_12Entry (display/scoop_display.s).  Reached through
; [nakarest] StyleUI_ParamBlockPtrTable entries 9-10, 19, 47-48, 57.
StyleUI_ParamBlock_VALUE:	.incbin "includes/generated/style_ui_paramblock_value.bin"
; [nakarest] StyleUI_ParamBlock_Common: Style-UI ScreenData bytecode -- the sd_* commands of
; [nakarest] style_ui/screendata_types.h (lines, rects, labelled refs, strings), typed in
; [nakarest] style_ui/paramblock/common.c -- drawn by UIRender_TwoTableGeneral, which hands its
; [nakarest] xiy/xix pair to Scoop_EventLoop_12Entry (display/scoop_display.s).  Reached through
; [nakarest] StyleUI_ParamBlockPtrTable entries 4-5, 7-8, 39, 42-43, 45-46.
StyleUI_ParamBlock_Common:	.incbin "includes/generated/style_ui_paramblock_common.bin"
; [nakarest] StyleUI_ParamBlock_Short: Style-UI ScreenData bytecode -- the sd_* commands of
; [nakarest] style_ui/screendata_types.h (lines, rects, labelled refs, strings), typed in
; [nakarest] style_ui/paramblock/short.c -- drawn by UIRender_TwoTableGeneral, which hands its
; [nakarest] xiy/xix pair to Scoop_EventLoop_12Entry (display/scoop_display.s).  Reached through
; [nakarest] StyleUI_ParamBlockPtrTable entries 23-24, 27-29, 58, 61-62, 65-67.
StyleUI_ParamBlock_Short:	.incbin "includes/generated/style_ui_paramblock_short.bin"
; [nakarest] StyleUI_ParamBlock_Extended: Style-UI ScreenData bytecode -- the sd_* commands of
; [nakarest] style_ui/screendata_types.h (lines, rects, labelled refs, strings), typed in
; [nakarest] style_ui/paramblock/extended.c -- drawn by UIRender_TwoTableGeneral, which hands
; [nakarest] its xiy/xix pair to Scoop_EventLoop_12Entry (display/scoop_display.s).  Reached
; [nakarest] through StyleUI_ParamBlockPtrTable entries 2, 6, 26, 40, 44, 64.
StyleUI_ParamBlock_Extended:	.incbin "includes/generated/style_ui_paramblock_extended.bin"
; [nakarest] StyleUI_ParamBlock_Medium: Style-UI ScreenData bytecode -- the sd_* commands of
; [nakarest] style_ui/screendata_types.h (lines, rects, labelled refs, strings), typed in
; [nakarest] style_ui/paramblock/medium.c -- drawn by UIRender_TwoTableGeneral, which hands its
; [nakarest] xiy/xix pair to Scoop_EventLoop_12Entry (display/scoop_display.s).  Reached through
; [nakarest] StyleUI_ParamBlockPtrTable entries 3, 21, 25, 41, 59, 63.
StyleUI_ParamBlock_Medium:	.incbin "includes/generated/style_ui_paramblock_medium.bin"
; [nakarest] StyleUI_ParamBlock_MEAS: Style-UI ScreenData bytecode -- the sd_* commands of
; [nakarest] style_ui/screendata_types.h (lines, rects, labelled refs, strings), typed in
; [nakarest] style_ui/paramblock/meas.c -- drawn by UIRender_TwoTableGeneral, which hands its
; [nakarest] xiy/xix pair to Scoop_EventLoop_12Entry (display/scoop_display.s).  Reached through
; [nakarest] StyleUI_ParamBlockPtrTable entries 12-15, 17, 22, 50-53, 55, 60.
StyleUI_ParamBlock_MEAS:	.incbin "includes/generated/style_ui_paramblock_meas.bin"
; [nakarest] StyleUI_ParamBlock_AltA: Style-UI ScreenData bytecode -- the sd_* commands of
; [nakarest] style_ui/screendata_types.h (lines, rects, labelled refs, strings), typed in
; [nakarest] style_ui/paramblock/alta.c -- drawn by UIRender_TwoTableGeneral, which hands its
; [nakarest] xiy/xix pair to Scoop_EventLoop_12Entry (display/scoop_display.s).  Reached through
; [nakarest] StyleUI_ParamBlockPtrTable entries 31-34, 69-72.
StyleUI_ParamBlock_AltA:	.incbin "includes/generated/style_ui_paramblock_alta.bin"
; [nakarest] StyleUI_ParamBlock_AltB: Style-UI ScreenData bytecode -- the sd_* commands of
; [nakarest] style_ui/screendata_types.h (lines, rects, labelled refs, strings), typed in
; [nakarest] style_ui/paramblock/altb.c -- drawn by UIRender_TwoTableGeneral, which hands its
; [nakarest] xiy/xix pair to Scoop_EventLoop_12Entry (display/scoop_display.s).  Reached through
; [nakarest] StyleUI_ParamBlockPtrTable entries 36, 74; loaded directly by
; [nakarest] Scoop_SetupDisplayTables.
StyleUI_ParamBlock_AltB:	.incbin "includes/generated/style_ui_paramblock_altb.bin"
; [nakarest] StyleUI_ParamBlock_AltC: Style-UI ScreenData bytecode -- the sd_* commands of
; [nakarest] style_ui/screendata_types.h (lines, rects, labelled refs, strings), typed in
; [nakarest] style_ui/paramblock/altc.c -- drawn by UIRender_TwoTableGeneral, which hands its
; [nakarest] xiy/xix pair to Scoop_EventLoop_12Entry (display/scoop_display.s).  Reached through
; [nakarest] StyleUI_ParamBlockPtrTable entries 16, 54; loaded directly by
; [nakarest] Scoop_SetupDisplayTables.
StyleUI_ParamBlock_AltC:	.incbin "includes/generated/style_ui_paramblock_altc.bin"
; [nakarest] StyleUI_ParamBlock_AltD: Style-UI ScreenData bytecode -- the sd_* commands of
; [nakarest] style_ui/screendata_types.h (lines, rects, labelled refs, strings), typed in
; [nakarest] style_ui/paramblock/altd.c -- drawn by UIRender_TwoTableGeneral, which hands its
; [nakarest] xiy/xix pair to Scoop_EventLoop_12Entry (display/scoop_display.s).  Reached through
; [nakarest] StyleUI_ParamBlockPtrTable entries 18, 35, 56, 73; loaded directly by
; [nakarest] Display_RedrawStatusBar.
StyleUI_ParamBlock_AltD:	.incbin "includes/generated/style_ui_paramblock_altd.bin"
; [nakarest] StyleUI_ParamBlock_AltE: Style-UI ScreenData bytecode -- the sd_* commands of
; [nakarest] style_ui/screendata_types.h (lines, rects, labelled refs, strings), typed in
; [nakarest] style_ui/paramblock/alte.c -- drawn by UIRender_TwoTableGeneral, which hands its
; [nakarest] xiy/xix pair to Scoop_EventLoop_12Entry (display/scoop_display.s).  Reached through
; [nakarest] StyleUI_ParamBlockPtrTable entries 37, 75; loaded directly by
; [nakarest] Display_RedrawStatusBar, Scoop_InitDisplayFull.
StyleUI_ParamBlock_AltE:	.incbin "includes/generated/style_ui_paramblock_alte.bin"

; [nakarest] StyleUI_ParamBlockPtrTable: 4 tables x 19 pointers (76 entries).
; [nakarest] Scoop_InitPartDisplay and Scoop_SelectModeTable_2Part scale a mode index by 4 (`sla
; [nakarest] hl, 2`), load xiy from +0x00 and xix from +0x4c -- or from +0x98 and +0xe4 when the
; [nakarest] byte at 0x0d65 is 2 -- and hand the pair to UIRender_TwoTableGeneral;
; [nakarest] Scoop_InitDisplayFull reads it too.  Every entry is one of the ParamBlock /
; [nakarest] ScreenData objects of this file (the .long lines below).
StyleUI_ParamBlockPtrTable:
	.long StyleUI_ParamBlock_BAL
	.long StyleUI_ScreenData_MeasCursor
	.long StyleUI_ParamBlock_Extended
	.long StyleUI_ParamBlock_Medium
	.long StyleUI_ParamBlock_Common
	.long StyleUI_ParamBlock_Common
	.long StyleUI_ParamBlock_Extended
	.long StyleUI_ParamBlock_Common
	.long StyleUI_ParamBlock_Common
	.long StyleUI_ParamBlock_VALUE
	.long StyleUI_ParamBlock_VALUE
	.long StyleUI_ScreenData_YesCtl
	.long StyleUI_ParamBlock_MEAS
	.long StyleUI_ParamBlock_MEAS
	.long StyleUI_ParamBlock_MEAS
	.long StyleUI_ParamBlock_MEAS
	.long StyleUI_ParamBlock_AltC
	.long StyleUI_ParamBlock_MEAS
	.long StyleUI_ParamBlock_AltD
; StyleUI_ParamBlockEndPtrTable: 19 x u32: the END pointers of the display lists that StyleUI_ParamBlockPtrTable's
;   entries start (the second of the 4 x 19 tables): Scoop_InitPartDisplay loads xiy = StyleUI_ParamBlockPtrTable[k]
;   and xix = this[k] and draws [xiy, xix) with the Scoop static interpreter (UIRender_TwoTableGeneral) on the step-
;   record screen, unless the display mode (0x0D65) is 2 (CONTROL track). Basis: readers + bytes -- each entry is the
;   object that follows (or the one after) the matching start block, as in Scoop_InitDisplayFull's AltE /
;   StyleUI_ParamBlockPtrTable pair.
StyleUI_ParamBlockEndPtrTable:
	.long StyleUI_ParamBlock_VALUE
	.long StyleUI_ScreenData_YesCtl
	.long StyleUI_ParamBlock_Medium
	.long StyleUI_ParamBlock_MEAS
	.long StyleUI_ParamBlock_Short
	.long StyleUI_ParamBlock_Short
	.long StyleUI_ParamBlock_Medium
	.long StyleUI_ParamBlock_Extended
	.long StyleUI_ParamBlock_Short
	.long StyleUI_ParamBlock_Short
	.long StyleUI_ParamBlock_Short
	.long StyleUI_ScreenData_CtlOnly
	.long StyleUI_ParamBlock_AltA
	.long StyleUI_ParamBlock_AltA
	.long StyleUI_ParamBlock_AltA
	.long StyleUI_ParamBlock_AltA
	.long StyleUI_ParamBlock_AltD
	.long StyleUI_ParamBlock_AltB
	.long StyleUI_ParamBlock_AltE
; StyleUI_ControlTrackParamBlockPtrTable: 19 x u32: the START pointers Scoop_InitPartDisplay uses instead of
;   StyleUI_ParamBlockPtrTable when the step-record display mode (0x0D65) is 2, the CONTROL track (third of the 4 x 19
;   tables); identical to it except entry 1 (ParamBlock_Common instead of ScreenData_MeasCursor). Basis: readers +
;   bytes.
StyleUI_ControlTrackParamBlockPtrTable:
	.long StyleUI_ParamBlock_BAL
	.long StyleUI_ParamBlock_Common
	.long StyleUI_ParamBlock_Extended
	.long StyleUI_ParamBlock_Medium
	.long StyleUI_ParamBlock_Common
	.long StyleUI_ParamBlock_Common
	.long StyleUI_ParamBlock_Extended
	.long StyleUI_ParamBlock_Common
	.long StyleUI_ParamBlock_Common
	.long StyleUI_ParamBlock_VALUE
	.long StyleUI_ParamBlock_VALUE
	.long StyleUI_ScreenData_YesCtl
	.long StyleUI_ParamBlock_MEAS
	.long StyleUI_ParamBlock_MEAS
	.long StyleUI_ParamBlock_MEAS
	.long StyleUI_ParamBlock_MEAS
	.long StyleUI_ParamBlock_AltC
	.long StyleUI_ParamBlock_MEAS
	.long StyleUI_ParamBlock_AltD
; StyleUI_ControlTrackParamBlockEndPtrTable: 19 x u32: the END pointers paired with
;   StyleUI_ControlTrackParamBlockPtrTable (fourth of the 4 x 19 tables), used when the step-record display mode
;   (0x0D65) is 2 (CONTROL track); entry 1 is ParamBlock_Short where the default end table has ScreenData_YesCtl.
;   Basis: readers + bytes.
StyleUI_ControlTrackParamBlockEndPtrTable:
	.long StyleUI_ParamBlock_VALUE
	.long StyleUI_ParamBlock_Short
	.long StyleUI_ParamBlock_Medium
	.long StyleUI_ParamBlock_MEAS
	.long StyleUI_ParamBlock_Short
	.long StyleUI_ParamBlock_Short
	.long StyleUI_ParamBlock_Medium
	.long StyleUI_ParamBlock_Extended
	.long StyleUI_ParamBlock_Short
	.long StyleUI_ParamBlock_Short
	.long StyleUI_ParamBlock_Short
	.long StyleUI_ScreenData_CtlOnly
	.long StyleUI_ParamBlock_AltA
	.long StyleUI_ParamBlock_AltA
	.long StyleUI_ParamBlock_AltA
	.long StyleUI_ParamBlock_AltA
	.long StyleUI_ParamBlock_AltD
	.long StyleUI_ParamBlock_AltB
	.long StyleUI_ParamBlock_AltE

; [nakarest] StyleUI_ScreenData_Main: Style-UI ScreenData bytecode -- the sd_* commands of
; [nakarest] style_ui/screendata_types.h (lines, rects, labelled refs, strings), typed in
; [nakarest] style_ui/main.c -- drawn by UIRender_TwoTableGeneral, which hands its xiy/xix pair
; [nakarest] to Scoop_EventLoop_12Entry (display/scoop_display.s).  Reached through no
; [nakarest] StyleUI_ParamBlockPtrTable entry; loaded directly by
; [nakarest] Scoop_TitleBar_DisplayPartTable.
StyleUI_ScreenData_Main:		.incbin "includes/generated/style_ui_screendata_main.bin", 0x0, 0xB4
; SqStep_RowSegmentLines: Static display records of the step-record screen (TT_SQSTEP): three 90-byte blocks, one per
;   row, each a vertical tick then 4 x {64-px horizontal line, tick} -- the segment rulers at y = 75-80, 120-125,
;   165-170. Scoop_TitleBar_GetPartConfig draws block [row] up to 10 + 20 * count bytes, count = byte 0x0E52 / 0x0E53
;   / 0x0E54 (row's segment count). Basis: readers + bytes.
SqStep_RowSegmentLines:	.incbin "includes/generated/style_ui_screendata_main.bin", 0xB4, 0x10E
Scoop_TitleBar_ShowBPM_Part0_Data:	.incbin "includes/generated/style_ui_screendata_main.bin", 0x1C2, 0xA
Scoop_TitleBar_ShowBPM_Part1_Data:	.incbin "includes/generated/style_ui_screendata_main.bin", 0x1CC, 0xA
Scoop_TitleBar_ShowBPM_Part2_Data:	.incbin "includes/generated/style_ui_screendata_main.bin", 0x1D6, 0xA
; SqStep_Row1NumberDash: Static record op 06 (cell text, font 0) "-" at (8, 40): Display_RedrawTitleBar draws it in
;   place of row 1's number (word 0x0E4C) when that is 1000 or more; below 1000 it prints the number with
;   Scoop_TitleBar_ShowBPM_Part0_Data (bound op 06, 3 digits, same cell). Basis: readers + bytes.
SqStep_Row1NumberDash:		.incbin "includes/generated/style_ui_screendata_main.bin", 0x1E0, 0x5
; SqStep_Row2NumberDash: Static record op 06 "-" at (8, 85): drawn in place of row 2's number (word 0x0E4E) when it is
;   1000 or more (otherwise Scoop_TitleBar_ShowBPM_Part1_Data prints it). Basis: readers + bytes.
SqStep_Row2NumberDash:		.incbin "includes/generated/style_ui_screendata_main.bin", 0x1E5, 0x5
; SqStep_Row3NumberDash: Static record op 06 "-" at (8, 130): drawn in place of row 3's number (word 0x0E50) when it
;   is 1000 or more (otherwise Scoop_TitleBar_ShowBPM_Part2_Data prints it). Basis: readers + bytes.
SqStep_Row3NumberDash:		.incbin "includes/generated/style_ui_screendata_main.bin", 0x1EA, 0x5
; SqStep_TrackNumberField: Bound record op 00 (print a RAM byte with %Nd): byte 0x118E, mask 0xFF, 2 digits at (168,
;   16) -- the step-record screen's track number; Scoop_InitPartDisplay and Scoop_InitDisplayFull copy the selected
;   track (0x0D60, 1..16) to 0x118E and draw it with DrawFunc_Init. Basis: readers + bytes.
SqStep_TrackNumberField:		.incbin "includes/generated/style_ui_screendata_main.bin", 0x1EF, 0xA
; SqStep_PopupLineField: Bound record op 02 (string from a table by a RAM byte): mask 0, so always entry 0 of the
;   30-character line buffer at RAM 0x0ECA, drawn at (8, 180) -- the step-record screen's pop-up text line. The
;   slice's last 20 bytes are a separate unlabelled table, 5 x 4-character end/repeat marks (" ", "END ", "REP ",
;   0x1B, 0x1C), which SqStep_EndRepMarkFields points at (0xE0BD98). Basis: readers + bytes.
SqStep_PopupLineField:		.incbin "includes/generated/style_ui_screendata_main.bin", 0x1F9, 0x23
; SqStep_Rows1To2LineFields: 4 bound op-02 records for rows 1-2 of the step-record screen: row 1's 30-character line
;   buffer RAM 0x0EF8 at (8, 52) and a 1-character mark (SqStep_CellFlagGlyphs entry (0x1191) & 3) at (8, 66); row 2's
;   buffer 0x0F16 at (8, 97) and the mark of ((0x1192) & 0x0C) >> 2 at (8, 111). Display_RedrawFooter draws them with
;   GraphicsRender_Start, followed by row 3's pair when word 0x0E50 is not 0. Basis: readers + bytes.
SqStep_Rows1To2LineFields:		.incbin "includes/generated/style_ui_screendata_main.bin", 0x21C, 0x3C
; SqStep_Row3LineFields: 2 bound op-02 records for row 3 of the step-record screen: the 30-character line buffer RAM
;   0x0F34 at (8, 142) and the mark ((0x1193) & 0x30) >> 4 from SqStep_CellFlagGlyphs at (8, 156).
;   Display_RedrawFooter draws them only when row 3's word 0x0E50 is not 0 (the end of its first range otherwise).
;   Basis: readers + bytes.
SqStep_Row3LineFields:		.incbin "includes/generated/style_ui_screendata_main.bin", 0x258, 0x1E
; SqStep_EndRepMarkFields: 24 bound op-02 records, 3 rows x 8 cells: the 4-character end/repeat mark of each cell ("
;   ", "END ", "REP " or the 0x1B / 0x1C symbol, from the table at 0xE0BD98) selected by RAM bytes 0x119B..0x11B2, at
;   x = 8 + 32k on y = 52 / 97 / 142. Display_RedrawButtonLabels draws them as [this,
;   SqStep_Row1ChordCells); Display_RedrawFooter uses this address as the end of its row records. Basis:
;   readers + bytes.
SqStep_EndRepMarkFields:		.incbin "includes/generated/style_ui_screendata_main.bin", 0x276, 0x168
; SqStep_Row1ChordCells: Row 1 of the step-record chord cells: 8 cells x 3 bound op-02 records (45 bytes each) -- the
;   2-character chord root (RAM 0x11A3 + 2k, root table "C ", "D(flat)" ...), the 5-character chord type (0x11A4 + 2k,
;   "7", "Maj7", "aug" ...) and the alternative 2-character suffix ("_ ", "7 ", "6 " by 0x11B3) -- at x = 8 + 32k, y =
;   52. Scoop_ButtonLabels_DrawCategory walks it with XIX = the row's cell records at RAM 0x0E55 (4 bytes each),
;   drawing the type or, when cell bit 7 is set, the suffix record. Basis: readers + bytes.
SqStep_Row1ChordCells:	.incbin "includes/generated/style_ui_screendata_main.bin", 0x3DE, 0x168
; SqStep_Row2ChordCells: Row 2 of the step-record chord cells: 8 cells x 3 bound op-02 records (root / type / suffix,
;   as SqStep_Row1ChordCells) at x = 8 + 32k, y = 97, walked by Scoop_ButtonLabels_DrawCategory with the cell records
;   at RAM 0x0E75. Basis: readers + bytes.
SqStep_Row2ChordCells:	.incbin "includes/generated/style_ui_screendata_main.bin", 0x546, 0x168
; SqStep_Row3ChordCells: Row 3 of the step-record chord cells: 8 cells x 3 bound op-02 records at x = 8 + 32k, y =
;   142, walked by Scoop_ButtonLabels_DrawCategory with the cell records at RAM 0x0E95. The slice continues with the
;   unlabelled tables the chord records point at: 16 x 2-character roots (0xE0C3A6), 64 x 5-character types (0xE0C3C6)
;   and 4 x 2-character suffixes (0xE0C506). Basis: readers + bytes.
SqStep_Row3ChordCells:	.incbin "includes/generated/style_ui_screendata_main.bin", 0x6AE, 0x2D0
; SqStep_CursorRowBlitBand: Static record op 0E (colour-blit a band from a text cell): cell 0x1159 = (8, 111), 33
;   characters wide, 11 pixels high -- the band of the step-record screen's cursor row. Display_RedrawSelection draws
;   it (COLORBLIT_MODE 1, GraphicsRender_ProcessEntries) before the cursor highlight in display mode 0 (CHORD/APC
;   track) and mode 3 (RHYTHM track). Basis: readers + bytes -- entry 14 of GraphicsRender_ProcessEntries_PtrTable is
;   ColorBlit_ComputeRectAndBlit; Scoop_AltContent_ClearOneRegion builds the same 8-byte record shape at RAM 0x11EA.
SqStep_CursorRowBlitBand:	.incbin "includes/generated/style_ui_screendata_main.bin", 0x97E, 0x8
; SqStep_CursorRowEndBar: Static record op 1B (DrawBox, colour 0xF5) from (264, 111) to (264, 121): a vertical bar at
;   the right end of the step-record cursor row, drawn by the Scoop static interpreter in display modes 1-2 (note and
;   CONTROL tracks) before the step-cursor highlight; it is also the end address of SqStep_CursorRowBlitBand's one-
;   record list. Basis: readers + bytes.
SqStep_CursorRowEndBar:	.incbin "includes/generated/style_ui_screendata_main.bin", 0x986, 0xA
; SqStep_RhythmCursor: Bound record op 03 (colour-blit the rectangle picked by a RAM value): RAM 0x1192, mask 0x0C,
;   shift 2, list of 4 rectangles that are all (8, 111) - (16, 121) -- the fixed one-character highlight
;   Display_RedrawSelection draws in display mode 3 (RHYTHM track). It is also the end address of
;   SqStep_CursorRowEndBar's list in modes 1-2. Basis: readers + bytes.
SqStep_RhythmCursor:		.incbin "includes/generated/style_ui_screendata_main.bin", 0x990, 0x2B
; SqStep_ChordCellCursor: Bound record op 03: the chord-cell cursor of the step-record screen -- 8 rectangles (8 +
;   32k, 111) - (16 + 32k, 121), one per chord cell, picked by RAM byte 0x1191, which Display_RedrawSelection loads
;   from 0x0EEF before drawing it in display mode 0 (CHORD/APC track). Basis: readers + bytes.
SqStep_ChordCellCursor:	.incbin "includes/generated/style_ui_screendata_main.bin", 0x9BB, 0x4B
; SqStep_StepCursor: Bound record op 03: the step-cursor highlight of the step-record screen -- 33 rectangles, entry 0
;   empty and entry n = (8n, 111) - (8n + 8, 121), picked by RAM byte 0x118F, which Display_RedrawSelection loads from
;   the step-cursor position 0x370F (1..32, 0 = off) in display modes 1-2 (note and CONTROL tracks). Basis: readers +
;   bytes.
SqStep_StepCursor:	.incbin "includes/generated/style_ui_screendata_main.bin", 0xA06, 0x113
; SqStep_RowCountBoxRecords: 3 Scoop bound records op 04, one per row of the step-record screen: RAM 0x119B / 0x119C /
;   0x119D (the rows' segment counts 0x0E52-0x0E54, copied by Display_RedrawSidePanel) select an entry of the row's
;   table in SqStep_RowCountBoxTables, and op 04 draws that box (DrawBox colour 245) from the entry's cell, width and
;   height. Basis: readers + bytes.
SqStep_RowCountBoxRecords:	.incbin "includes/generated/style_ui_screendata_main.bin", 0xB19, 0x21
; SqStep_RowCountBoxTables: 3 x 5 x {u16 text cell, u16 width in characters, u16 height}: the boxes Scoop bound op 04
;   draws for row segment count 0..4 -- for row 1 (8, 66) 32 x 10, (72, 66) 24, (136, 66) 16, (200, 66) 8, then {0, 1,
;   1}; rows 2 and 3 the same at y = 111 / 156 shifted by one cell -- each ending at x = 264, i.e. the part of the row
;   beyond its count. Basis: readers + bytes -- SqStep_RowCountBoxRecords point at the three tables; op 04 takes entry
;   3 * value words in.
SqStep_RowCountBoxTables:	.incbin "includes/generated/style_ui_screendata_main.bin", 0xB3A, 0x5A
; SqStep_NibbleMarkPatterns: 16 x 4 characters: a 4-bit value drawn as 4 marks, bit i -> '*' when set, glyph 0x91 when
;   clear (entry 0 = 4 x 0x91 ... entry 15 = "****"). Scoop_SidePanel_DrawOneSlot copies entry [nibble] into a static
;   op-06 text record at RAM 0x11D4 and draws it; Display_RedrawSidePanel runs it for both nibbles of each byte of the
;   rows' bit maps at RAM 0x372E. Basis: readers + bytes.
SqStep_NibbleMarkPatterns:	.incbin "includes/generated/style_ui_screendata_main.bin", 0xB94, 0x40
; SqStep_CellFlagFields: 24 bound op-02 records, 3 rows x 8 cells: a 1-character flag mark (SqStep_CellFlagGlyphs
;   entry (byte & 0x60) >> 5: blank, '*' or glyph 0x91) under each cell at x = 8 + 32k, y = 66 / 111 / 156, from RAM
;   bytes 0x11B3.., 0x1192.., 0x119A.., which Scoop_ButtonLabels_CopySlotData fills with byte 0 of each cell record
;   (RAM 0x0E55 / 0x0E75 / 0x0E95 + 4k). Display_RedrawButtonLabels draws them with GraphicsRender_Start. Basis:
;   readers + bytes.
SqStep_CellFlagFields:	.incbin "includes/generated/style_ui_screendata_main.bin", 0xBD4, 0x168
; SqStep_CellFlagGlyphs: 3 x 1 character {' ', '*', 0x91}: the flag-mark table at 0xE0C8CC that SqStep_CellFlagFields
;   and the row-mark records of SqStep_Rows1To2LineFields / SqStep_Row3LineFields index (width 1); also the end
;   address of the SqStep_CellFlagFields list. Basis: readers + bytes.
SqStep_CellFlagGlyphs:	.incbin "includes/generated/style_ui_screendata_main.bin", 0xD3C, 0x3
; SqStep_BottomBarBoxes: Static records of the step-record screen's bottom bar: 8 op-0A boxes, 30 pixels wide at x = 5
;   + 40k, y = 210-236, then 6 op-01 lines at y = 223 inside the first six; Scoop_InitPartDisplay draws [this,
;   StyleUI_ScreenData_MeasCursor) with the Scoop static interpreter after the parameter block when the block index is
;   0. Basis: readers + bytes.
SqStep_BottomBarBoxes:	.incbin "includes/generated/style_ui_screendata_main.bin", 0xD3F, 0x8C
; [nakarest] StyleUI_ScreenData_MeasCursor: Style-UI ScreenData bytecode -- the sd_* commands of
; [nakarest] style_ui/screendata_types.h (lines, rects, labelled refs, strings), typed in
; [nakarest] style_ui/meascursor.c -- drawn by UIRender_TwoTableGeneral, which hands its xiy/xix
; [nakarest] pair to Scoop_EventLoop_12Entry (display/scoop_display.s).  Reached through
; [nakarest] StyleUI_ParamBlockPtrTable entries 1; loaded directly by
; [nakarest] Scoop_SelectModeTable_2Part_XIX.
StyleUI_ScreenData_MeasCursor:	.incbin "includes/generated/style_ui_screendata_meascursor.bin"
; [nakarest] StyleUI_ScreenData_YesCtl: Style-UI ScreenData bytecode -- the sd_* commands of
; [nakarest] style_ui/screendata_types.h (lines, rects, labelled refs, strings), typed in
; [nakarest] style_ui/yesctl.c -- drawn by UIRender_TwoTableGeneral, which hands its xiy/xix
; [nakarest] pair to Scoop_EventLoop_12Entry (display/scoop_display.s).  Reached through
; [nakarest] StyleUI_ParamBlockPtrTable entries 11, 20, 49.
StyleUI_ScreenData_YesCtl:	.incbin "includes/generated/style_ui_screendata_yesctl.bin"
; [nakarest] StyleUI_ScreenData_CtlOnly: Style-UI ScreenData bytecode -- the sd_* commands of
; [nakarest] style_ui/screendata_types.h (lines, rects, labelled refs, strings), typed in
; [nakarest] style_ui/ctlonly.c -- drawn by UIRender_TwoTableGeneral, which hands its xiy/xix
; [nakarest] pair to Scoop_EventLoop_12Entry (display/scoop_display.s).  Reached through
; [nakarest] StyleUI_ParamBlockPtrTable entries 30, 68.
StyleUI_ScreenData_CtlOnly:				.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x0, 0x20
Display_RedrawAltContent_Str_END:			.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x20, 0x3
; Scoop_CharGlyphMap: 256 x u8 character code -> font glyph code, byte-identical to Text_CharGlyphMap (ASCII to itself
;   except '\' -> 0xA5, 0x10-0x1F to UI symbols, 0x80-0xAB to the accent page): the Scoop text records (static ops 06
;   and 20, the table-string op of Scoop_CurveUpdate_SegmentEnd) map every character through it before DrawString.
;   Basis: readers + bytes.
Scoop_CharGlyphMap:			.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x23, 0x100
; Scoop_StaticOp20_ClipBox: 4 x u16 {0, 0, 319, 239}: text clip box (the whole 320 x 240 screen) of Scoop static
;   display op 0x20 (cell text, font 6): Scoop_EnvCalc_Handler1 copies it with ldirw into its frame and passes the
;   copy to DrawString as the clip rectangle. Basis: readers + bytes (cf. SeGfx_StaticOp20_ClipBox).
Scoop_StaticOp20_ClipBox:				.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x123, 0x8
Scoop_GlideParam_Configure_Data:			.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x12B, 0x8
; Scoop_StaticOp08_ClipBox: 4 x u16 {0, 0, 319, 239}: text clip box (the whole 320 x 240 screen) of Scoop static
;   display op 08 (cell text, font 2): Scoop_GlideCalc_Handler0 copies it with ldirw into its frame and passes the
;   copy to DrawString. Basis: readers + bytes (cf. SeGfx_StaticOp08_ClipBox).
Scoop_StaticOp08_ClipBox:				.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x133, 0x8
; Scoop_StaticOpHandlerTable: 36 x u32: the handler of each Scoop static display-record op 0x00..0x23 ({u8 op, u8 len,
;   payload}); Scoop_EventLoop_12Entry copies the 0x48 words into its frame and calls [op] with XWA = the record for
;   every record from XWA up to XBC, stopping at an op above 0x23. Cell text 06 / 07 / 08 / 20, op 1B DrawBox, op 0E
;   Scoop_EnvCalc_Handler0, 01 / 02 / 09 / 0A / 23 drawing handlers, the rest Scoop_Dispatch_Nop. Basis: readers +
;   bytes -- the static twin of Scoop_BoundOpHandlerTable.
Scoop_StaticOpHandlerTable:
	.long	Scoop_Dispatch_Nop
	.long	Scoop_EnvCalc_Handler2
	.long	Scoop_Dispatch_CallFAA98A
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_GlideParam_Setup
	.long	Scoop_GlideParam_Data
	.long	Scoop_GlideCalc_Handler0
	.long	Scoop_GlideCalc_Handler1
	.long	Scoop_GlideCalc_Handler2
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_EnvCalc_Handler0
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_CallFAB273
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_EnvCalc_Handler1
	.long	Scoop_Dispatch_Nop
	.long	Scoop_Dispatch_Nop
	.long	Scoop_EnvCalc_Handler3
Scoop_EventLoop_12Entry_Process_Data:			.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x1CB, 0x8
Scoop_EventLoop_12Entry_Process_Str_Fmt1d:		.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x1D3, 0x4
Scoop_EventLoop_12Entry_Process_Str_Fmt2d:		.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x1D7, 0x4
Scoop_EventLoop_12Entry_Process_Str_Fmt3d:		.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x1DB, 0x4
; Scoop_BoundOp05_ClipBox: 4 x u16 {0, 0, 319, 239}: text clip box (the whole 320 x 240 screen) of Scoop bound display
;   op 05: Scoop_EventLoop_12Entry_Alt_Data_Target5 copies it with ldirw into its frame and passes the copy to
;   DrawString. Basis: readers + bytes (cf. Scoop_BoundOp07_ClipBox, Scoop_BoundOp0A_ClipBox).
Scoop_BoundOp05_ClipBox:		.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x1DF, 0x8
Scoop_EventLoop_12Entry_Alt_Data_Target5_Str_Fmt1d:	.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x1E7, 0x4
Scoop_EventLoop_12Entry_Alt_Data_Target5_Str_Fmt2d:	.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x1EB, 0x4
Scoop_EventLoop_12Entry_Alt_Data_Target5_Str_Fmt3d:	.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x1EF, 0x4
Scoop_EventLoop_12Entry_Alt_Data_Target5_Str_Fmt2d_2:	.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x1F3, 0x4
Scoop_EventLoop_12Entry_Alt_Data_Target5_Str_Fmt3d_2:	.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x1F7, 0x4
Scoop_EventLoop_12Entry_Alt_Data_Target5_Str_Fmt4d:	.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x1FB, 0x4
; Scoop_BoundOp06_ClipBox: 4 x u16 {0, 0, 319, 239}: text clip box (the whole 320 x 240 screen) of Scoop bound display
;   op 06, which prints a RAM word with %1d / %2d / %3d: Scoop_EventLoop_36Entry copies it with ldirw into its frame
;   and passes the copy to DrawString. Basis: readers + bytes.
Scoop_BoundOp06_ClipBox:				.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x1FF, 0x8
Scoop_EventLoop_36Entry_Str_Fmt1d:			.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x207, 0x4
Scoop_EventLoop_36Entry_Branch1_Str_Fmt2d:		.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x20B, 0x4
Scoop_EventLoop_36Entry_Branch2_Str_Fmt3d:		.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x20F, 0x4
Scoop_EventLoop_36Entry_Branch3_Data_4:			.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x213, 0x8
Scoop_EventLoop_36Entry_Branch3_Str_Fmt1d_3:		.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x21B, 0x4
Scoop_EventLoop_36Entry_Branch3_Str_Fmt2d_4:		.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x21F, 0x4
Scoop_EventLoop_36Entry_Branch3_Str_Fmt3d_4:		.incbin "includes/generated/style_ui_screendata_ctlonly.bin", 0x223, 0x4

