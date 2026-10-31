; GUI_FormatStrings: GUI format string data
; Total: 704 bytes
; Source: e0cd1e_e0cfdd.bin
; Format: a 4-byte CELL GRID at the head (0xE0CD1E-0xE0CD92, 29 cells:
;   13 pointers, 9 inline format strings, 4 zero cells and 3 bounds words) followed by
;   34-byte NAKA records, which do not fit a 4-byte grid and are left as
;   `.byte`.  The grid's PHASE is measured, not assumed: over the whole
;   704-byte region phase 0 explains 50.0% of cells against 19.4/32.6/17.1%
;   for phases 1/2/3.  See scripts/converters/gui_format_strings_cells.py
;   (v10).  That script counted the bounds word 0x00EF013F as a 16th pointer;
;   it is the pair 319, 239 after a zero pair, the 320x240 screen's corners,
;   now `.short 0, 0, 319, 239`.  v9 and v7 were given the same form by
;   scripts/tools/sync_gui_format_strings_head.py (2026-10-03).

	.short	0, 0, 319, 239	; copied as 4 words by Scoop_BoundOp0A_PrintByte: the 320x240 screen's corners
Scoop_EventLoop_36Entry_Branch3_Str_Fmt1d:	.asciz "%1d"
Scoop_EventLoop_36Entry_Branch3_Str_Fmt2d:	.asciz "%2d"
Scoop_EventLoop_36Entry_Branch3_Str_Fmt3d:	.asciz "%3d"
Scoop_EventLoop_36Entry_Branch3_Str_Fmt2d_2:	.asciz "%2d"
Scoop_EventLoop_36Entry_Branch3_Str_Fmt3d_2:	.asciz "%3d"
Scoop_EventLoop_36Entry_Branch3_Str_Fmt4d:	.asciz "%4d"
; Scoop_BoundOp0A_ClipBox: 4 x u16 {0, 0, 319, 239}: text clip box (the whole 320 x 240 screen) of Scoop bound display
;   op 0x0A, copied with ldirw into its frame and passed to DrawString. Basis: readers + bytes (cf.
;   SeGfx_StaticOp06_ClipBox).
Scoop_BoundOp0A_ClipBox:
	.short	0, 0, 319, 239	; copied as 4 words by Scoop_BoundOp0A_PrintByte: the 320x240 screen's corners
Scoop_EventLoop_36Entry_Branch3_Str_Fmt1d_2:	.asciz "%1d"
Scoop_EventLoop_36Entry_Branch3_Str_Fmt2d_3:	.asciz "%2d"
Scoop_EventLoop_36Entry_Branch3_Str_Fmt3d_3:	.asciz "%3d"
; Scoop_BoundOp07_ClipBox: 4 x u16 {0, 0, 319, 239}: text clip box (whole 320 x 240 screen) of Scoop bound display op
;   7, which draws a string picked from a table by a masked, shifted RAM byte. Basis: readers + bytes (cf.
;   SeGfx_StaticOp06_ClipBox).
Scoop_BoundOp07_ClipBox:	.short	0, 0, 319, 239	; copied as 4 words by Scoop_BoundOp0A_PrintByte: the 320x240 screen's corners
; Scoop_BoundOpHandlerTable: 12 x u32: handler of each op (record byte 0, 0..11) of a Scoop bound display list (values
;   read from RAM); Scoop_EventLoop_12Entry_Alt copies it to its frame and calls [op] with XWA = record, byte 1 =
;   record length. Same op shape as GraphicsRender_Start_PtrTable: op 3 = ColorBlit_WithPaletteSave, op 10 prints a
;   RAM byte with %1d/%2d/%3d. Basis: readers + bytes.
Scoop_BoundOpHandlerTable:	.long Scoop_EnvProcessor_Data
	.long Scoop_Dispatch_Nop
	.long Scoop_EnvelopeCalc_Data
	.long ColorBlit_WithPaletteSave
	.long Scoop_BoundOp04_DrawBoxByField
	.long Scoop_BoundOp05_PrintFieldAtCell
	.long Scoop_EventLoop_36Entry
	.long Scoop_BoundOp07_DrawStringByField
	.long Scoop_BoundOp08_DrawRectByField
	.long Scoop_EventLoop_36Entry_Data
	.long Scoop_BoundOp0A_PrintByte
	.long Scoop_BoundOp0B_PrintSignedField
Scoop_ApFunctionTable_126:	.long 0x00000000
Scoop_ApFunctionTable_426:	.long Scoop_ApFunctionTable_426_EndName
Scoop_ApFunctionTable_426_EndName:
	.byte	0x00, 0xff
Scoop_ClassTable_166:	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
Scoop_ClassCount_166:	.byte	0x00, 0x00
Scoop_ResEventTable_1C6:	.byte	0x00, 0x00, 0x00, 0x00
Scoop_ResEventCount_1C6:	.byte	0x00, 0x00
Scoop_ResMethodTable_1E6:	.byte	0x00, 0x00, 0x00, 0x00
Scoop_ResMethodCount_1E6:	.byte	0x00, 0x00
Scoop_FunctionTable_106:	.byte	0x00, 0x00, 0x00, 0x00
Scoop_FunctionTable_406:	.byte	0xc2, 0xcd, 0xe0, 0x00, 0x00, 0xff
NakaWidget_semenu:
	NAKA_REC_IvDirmdScreen super=NAKA_INDEX_NONE, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3d530
NakaWidget_seeasy:
	NAKA_REC_IvDirmdScreen super=NAKA_INDEX_NONE, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3d534
NakaWidget_setonton1:
	NAKA_REC_IvDirmdScreen super=NAKA_INDEX_NONE, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3d538
NakaWidget_setonton2:
	NAKA_REC_IvDirmdScreen super=NAKA_INDEX_NONE, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3d53c
NakaWidget_setonran1:
	NAKA_REC_IvDirmdScreen super=NAKA_INDEX_NONE, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3d540
NakaWidget_setonran2:
	NAKA_REC_IvDirmdScreen super=NAKA_INDEX_NONE, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3d544
NakaWidget_setonhyb1:
	NAKA_REC_IvDirmdScreen super=NAKA_INDEX_NONE, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3d548
NakaWidget_sepitpit1:
	NAKA_REC_IvDirmdScreen super=NAKA_INDEX_NONE, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3d54c
NakaWidget_sepitenv1:
	NAKA_REC_IvDirmdScreen super=NAKA_INDEX_NONE, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3d550
NakaWidget_sepitenv2:
	NAKA_REC_IvDirmdScreen super=NAKA_INDEX_NONE, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3d554
NakaWidget_sepitlfo1:
	NAKA_REC_IvDirmdScreen super=NAKA_INDEX_NONE, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3d558
NakaWidget_seampamp1:
	NAKA_REC_IvDirmdScreen super=NAKA_INDEX_NONE, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3d55c
NakaWidget_seampamp2:
	NAKA_REC_IvDirmdScreen super=NAKA_INDEX_NONE, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3d560
NakaWidget_seampenv1:
	NAKA_REC_IvDirmdScreen super=NAKA_INDEX_NONE, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3d564
NakaWidget_seampenv2:
	NAKA_REC_IvDirmdScreen super=NAKA_INDEX_NONE, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3d568
NakaWidget_seamplfo1:	.byte	0x5a, 0x00, 0x60, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
	.byte 0x0a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3f, 0x01, 0xef, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00