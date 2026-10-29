; ==============================================================================
; include/wsa1_gui.inc -- the SX-WSA1R's GUI records, one macro per record kind
; ==============================================================================
;
; The WSA1 has no widget classes and no string table.  Everything its 320 x 240
; LCD shows -- every caption, box, rule, bitmap and live value -- is one RECORD of
; a DISPLAY LIST, and a screen is the code that runs a few lists (its Enter / Paint
; method) plus a table that maps each panel key to a handler (its Button method).
; This file names the records; the screens, their key maps and their transitions
; are indexed in wsa1/docs/gui-menu-map.md (generated from the sources by
; scripts/analysis/gui_menu_map.py).
;
;   record     +0 opcode   +1 length of the WHOLE record   +2.. operands
;
; Two interpreters run the lists, both in prom_b (FINDINGS-ui-display-list.md,
; FINDINGS-ui-display-list-interpreter-b.md):
;
;   DisplayList_Run  (0xF31A09, `dl_*` below) draws what the RECORD says.  Its
;       opcode IS the SWI7 graphics service number: DLHandler_IX_Text does
;       `ld A,(XIY)` / `swi 7`, and SWI7_ServiceTable (prom_a 0xF8E9C6) names the
;       service.  Each macro is named after its service.
;   DisplayListB_Run (0xF31AF0, `dlb_*` below) draws what a VARIABLE says: every
;       handler first reads ((var) & mask) >> shift (DisplayListB_ExtractField)
;       and then draws that value as digits, as entry [value] of a string table,
;       or as the rectangle in entry [value] of a table.
;
; GEOMETRY IS IN PANEL PIXELS, x right and y down, origin top left:
;   * x0, y0, x1, y1 are the four words DLHandler_4Words copies to LCD_X0, LCD_Y0,
;     LCD_X1, LCD_Y1 -- the corners LCD_Svc_00_DrawLine / LCD_Svc_05_FillRect /
;     LCD_Svc_09_DrawBox walk ("(0x2536)-(0x2532)+1" rows, inclusive);
;   * a text or bitmap position is a display-RAM BYTE OFFSET within the layer
;     (LCD_Svc_06_DrawText8x14, LCD_Svc_03_BlitColumns: `ld WA,IX` /
;     `add WA,(LCD_CurrentLayerBase)`), and LCD_Init_SED1330 programmes AP = 40
;     bytes per line with 8 pixels per byte.  So offset = y * 40 + x / 8, and x
;     must be a multiple of 8 -- _dl_at checks it.  The packed-text services 0x17
;     and 0x1C instead take a pixel x and y in LCD_X0 / LCD_Y0 (DLHandler_2Words_Text).
;   * w is in pixels (BC counts byte columns, so w / 8 is emitted); h is in rows.
;
; Which layer a list draws into is not in the list: the caller sets
; LCD_CurrentLayer (0x2540) before `call T_DisplayList_Run`.
;
; Every macro computes its own length byte from its operands, so a mis-read text
; or field cannot rebuild the ROM: the byte gate checks every record.
; Converted by scripts/tools/gui_display_list_macros.py (its docstring says how a
; record's interpreter is decided); counted by scripts/analysis/gui_readability_census.py.
; ==============================================================================

.ifndef WSA1_GUI_INC
.equ WSA1_GUI_INC, 1

; ---- SWI7 graphics services (SWI7_ServiceTable, prom_a 0xF8E9C6): the `svc`
;      field of an interpreter-B record, and the opcode of an interpreter-A one.
	.equ LCDSVC_DrawLine,			0x00
	.equ LCDSVC_DrawHLine,			0x01
	.equ LCDSVC_DrawVLine,			0x02
	.equ LCDSVC_BlitColumns,		0x03
	.equ LCDSVC_ReadColumns,		0x04
	.equ LCDSVC_FillRect,			0x05
	.equ LCDSVC_DrawText8x14,		0x06
	.equ LCDSVC_DrawText8x16,		0x07
	.equ LCDSVC_DrawText16x16,		0x08
	.equ LCDSVC_DrawBox,			0x09
	.equ LCDSVC_DrawBoxShadow2,		0x0a
	.equ LCDSVC_PlotPoint,			0x0b
	.equ LCDSVC_SetLayersOn,		0x0c
	.equ LCDSVC_SetLayersFlashing,		0x0d
	.equ LCDSVC_ClearColumns,		0x0e
	.equ LCDSVC_SetPanel2Layer,		0x0f
	.equ LCDSVC_SetPanel3Layer,		0x10
	.equ LCDSVC_DrawHLineDither,		0x11
	.equ LCDSVC_DrawVLineDashed,		0x12
	.equ LCDSVC_DrawBoxPatterned,		0x13
	.equ LCDSVC_FillRectPattern,		0x14
	.equ LCDSVC_DrawLineDashed,		0x15
	.equ LCDSVC_DrawKatakanaHalfWidth,	0x16
	.equ LCDSVC_DrawText8x8Packed,		0x17
	.equ LCDSVC_DrawKatakana16x16,		0x19
	.equ LCDSVC_DrawKanjiSetA16x16,		0x1a
	.equ LCDSVC_EraseRect,			0x1b
	.equ LCDSVC_DrawText16x16Packed,	0x1c
	.equ LCDSVC_DrawHiragana16x16,		0x1d
	.equ LCDSVC_ScrollCurrentLayer,		0x1e
	.equ LCDSVC_DrawKanjiSetB16x16,		0x1f
	.equ LCDSVC_DrawText8x10,		0x20
	.equ LCDSVC_DrawText16x24,		0x21
	.equ LCDSVC_DrawBoxShadow1,		0x22

; ---- how the macros below are written ------------------------------------------
; Each macro body is ONLY data directives -- no helper-macro calls -- so that the
; repository's source censuses (scripts/analysis/data_range_census.py, which judges
; a macro by its body) see every record as data.  Two idioms repeat:
;   * the length byte of a variable-length record is measured from a local label at
;     the record's start to one at its end:  .byte <op>, .Ldl_e\@ - .Ldl_s\@
;   * a display-RAM position (see GEOMETRY above) is emitted as y * 40 + x / 8, after
;     an .if that refuses an x that is not a multiple of 8.

; ==============================================================================
; INTERPRETER A -- DisplayList_Run (prom_b 0xF31A09), DisplayList_HandlerTable
; ==============================================================================

; ---- four corners -> DLHandler_4Words copies them to LCD_X0 / LCD_Y0 / LCD_X1 /
;      LCD_Y1 -> SWI7 service <opcode>.  10 bytes.
.macro dl_line x0, y0, x1, y1		; LCD_Svc_00_DrawLine
	.byte 0x00, 10
	.short \x0, \y0, \x1, \y1
.endm
.macro dl_hline x0, y0, x1, y1		; LCD_Svc_01_DrawHLine
	.byte 0x01, 10
	.short \x0, \y0, \x1, \y1
.endm
.macro dl_vline x0, y0, x1, y1		; LCD_Svc_02_DrawVLine
	.byte 0x02, 10
	.short \x0, \y0, \x1, \y1
.endm
.macro dl_fill_rect x0, y0, x1, y1		; LCD_Svc_05_FillRect
	.byte 0x05, 10
	.short \x0, \y0, \x1, \y1
.endm
.macro dl_box x0, y0, x1, y1		; LCD_Svc_09_DrawBox
	.byte 0x09, 10
	.short \x0, \y0, \x1, \y1
.endm
.macro dl_box_shadow2 x0, y0, x1, y1		; LCD_Svc_0A_DrawBoxShadow2
	.byte 0x0a, 10
	.short \x0, \y0, \x1, \y1
.endm
.macro dl_hline_dither x0, y0, x1, y1		; LCD_Svc_11_DrawHLineDither
	.byte 0x11, 10
	.short \x0, \y0, \x1, \y1
.endm
.macro dl_vline_dashed x0, y0, x1, y1		; LCD_Svc_12_DrawVLineDashed
	.byte 0x12, 10
	.short \x0, \y0, \x1, \y1
.endm
.macro dl_box_patterned x0, y0, x1, y1		; LCD_Svc_13_DrawBoxPatterned
	.byte 0x13, 10
	.short \x0, \y0, \x1, \y1
.endm
.macro dl_line_dashed x0, y0, x1, y1		; LCD_Svc_15_DrawLineDashed
	.byte 0x15, 10
	.short \x0, \y0, \x1, \y1
.endm
.macro dl_erase_rect x0, y0, x1, y1		; LCD_Svc_1B_EraseRect
	.byte 0x1b, 10
	.short \x0, \y0, \x1, \y1
.endm
.macro dl_box_shadow1 x0, y0, x1, y1		; LCD_Svc_22_DrawBoxShadow1
	.byte 0x22, 10
	.short \x0, \y0, \x1, \y1
.endm

; ---- text at a display-RAM position -> DLHandler_IX_Text: IX = position,
;      BC = length - 4 characters from +4, service <opcode>.  Characters below
;      0x20 and above 0x7E are the font's own glyphs (FINDINGS-fonts.md) and are
;      written as octal escapes.
.macro dl_text8x14 x, y, text		; LCD_Svc_06_DrawText8x14
.Ldl_s\@:
	.byte 0x06, .Ldl_e\@ - .Ldl_s\@
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.ascii "\text"
.Ldl_e\@:
.endm
.macro dl_text8x16 x, y, text		; LCD_Svc_07_DrawText8x16
.Ldl_s\@:
	.byte 0x07, .Ldl_e\@ - .Ldl_s\@
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.ascii "\text"
.Ldl_e\@:
.endm
.macro dl_text16x16 x, y, text		; LCD_Svc_08_DrawText16x16
.Ldl_s\@:
	.byte 0x08, .Ldl_e\@ - .Ldl_s\@
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.ascii "\text"
.Ldl_e\@:
.endm
.macro dl_kana_halfwidth x, y, text		; LCD_Svc_16_DrawKatakanaHalfWidth
.Ldl_s\@:
	.byte 0x16, .Ldl_e\@ - .Ldl_s\@
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.ascii "\text"
.Ldl_e\@:
.endm
.macro dl_svc18_unimplemented x, y, text		; LCD_Svc_Unimplemented
.Ldl_s\@:
	.byte 0x18, .Ldl_e\@ - .Ldl_s\@
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.ascii "\text"
.Ldl_e\@:
.endm
.macro dl_katakana16 x, y, text		; LCD_Svc_19_DrawKatakana16x16
.Ldl_s\@:
	.byte 0x19, .Ldl_e\@ - .Ldl_s\@
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.ascii "\text"
.Ldl_e\@:
.endm
.macro dl_kanji_a16 x, y, text		; LCD_Svc_1A_DrawKanjiSetA16x16
.Ldl_s\@:
	.byte 0x1a, .Ldl_e\@ - .Ldl_s\@
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.ascii "\text"
.Ldl_e\@:
.endm
.macro dl_hiragana16 x, y, text		; LCD_Svc_1D_DrawHiragana16x16
.Ldl_s\@:
	.byte 0x1d, .Ldl_e\@ - .Ldl_s\@
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.ascii "\text"
.Ldl_e\@:
.endm
.macro dl_scroll_layer x, y, text		; LCD_Svc_1E_ScrollCurrentLayer
.Ldl_s\@:
	.byte 0x1e, .Ldl_e\@ - .Ldl_s\@
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.ascii "\text"
.Ldl_e\@:
.endm
.macro dl_kanji_b16 x, y, text		; LCD_Svc_1F_DrawKanjiSetB16x16
.Ldl_s\@:
	.byte 0x1f, .Ldl_e\@ - .Ldl_s\@
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.ascii "\text"
.Ldl_e\@:
.endm
.macro dl_text8x10 x, y, text		; LCD_Svc_20_DrawText8x10
.Ldl_s\@:
	.byte 0x20, .Ldl_e\@ - .Ldl_s\@
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.ascii "\text"
.Ldl_e\@:
.endm
.macro dl_text16x24 x, y, text		; LCD_Svc_21_DrawText16x24
.Ldl_s\@:
	.byte 0x21, .Ldl_e\@ - .Ldl_s\@
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.ascii "\text"
.Ldl_e\@:
.endm

; ---- text at any pixel -> DLHandler_2Words_Text: LCD_X0 = x, LCD_Y0 = y,
;      BC = length - 6 characters from +6.  Service 0x17 is the 8x8 face, 0x1C the
;      16x16 face set 11 pixels apart (LCD_Svc_1C_DrawText16x16Packed).
.macro dl_text8x8_packed x, y, text		; LCD_Svc_17_DrawText8x8Packed
.Ldl_s\@:
	.byte 0x17, .Ldl_e\@ - .Ldl_s\@
	.short \x, \y
	.ascii "\text"
.Ldl_e\@:
.endm
.macro dl_text16x16_packed x, y, text		; LCD_Svc_1C_DrawText16x16Packed
.Ldl_s\@:
	.byte 0x1c, .Ldl_e\@ - .Ldl_s\@
	.short \x, \y
	.ascii "\text"
.Ldl_e\@:
.endm

; ---- one pixel -> DLHandler_2Words -> LCD_Svc_0B_PlotPoint.  6 bytes.
.macro dl_plot x, y
	.byte 0x0b, 6
	.short \x, \y
.endm

; ---- zero a w x h area -> DLHandler_IY_BC_HL -> LCD_Svc_0E_ClearColumns
;      (IY = position, BC = byte columns, HL = rows).  8 bytes.
.macro dl_clear_area x, y, w, h
	.byte 0x0e, 8
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.short (\w) / 8, \h
.endm

; ---- a bitmap that lives outside the list -> DLHandler_FarPtr: XIY = bitmap,
;      IX = position, BC = byte columns, HL = rows -> LCD_Svc_03_BlitColumns
;      (dl_bitmap) or LCD_Svc_04_ReadColumns (dl_read_area: the display copied
;      INTO the buffer).  12 bytes.  A bitmap is column-major, w / 8 columns of h
;      bytes (FINDINGS-image-files.md).
.macro dl_bitmap bitmap, x, y, w, h
	.byte 0x03, 12
	.long \bitmap
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.short (\w) / 8, \h
.endm
.macro dl_read_area buffer, x, y, w, h
	.byte 0x04, 12
	.long \buffer
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.short (\w) / 8, \h
.endm

; ---- one 24 x 24 value glyph -> DLHandler_Glyph24x24: glyph <n> of the 72-byte
;      array DLGlyph_000_F78028 (prom_b), blitted 3 bytes x 24 rows at x, y.  5 bytes.
.macro dl_value_glyph glyph, x, y
	.byte 0x23, 5, \glyph
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
.endm

; ==============================================================================
; INTERPRETER B -- DisplayListB_Run (prom_b 0xF31AF0), DisplayListB_HandlerTable
;
; length= (every dlb_* macro, default = the record's own length) is the +1 byte when
; it is NOT the record's extent.  DisplayListB_Run advances by that byte without
; looking at the opcode (`ld A,(XIY+0x01)`, 0xF31B15), while the handler reads only
; the extent; the two differ in three records: TrackAssign_PaintTrackGroup_DL
; (advance 11, extent 10 -- the loop's `cp XIX,XIY / jr ULE` stops on it) and two
; entries of the fixed-stride run at DL_F3D3AD (0x0D and 0x14 where 15 is meant).
;
; Common to every record: var = the 16-bit address the value is read from,
; mask / shift = the bit-field ((var) & mask) >> (shift & 7)
; (DisplayListB_ExtractField), and svc = the SWI7 service that draws it
; (LCDSVC_* above).  Each opcode has ONE length in the whole image, the one its
; handler implies (FINDINGS-ui-display-list-interpreter-b.md).
; ==============================================================================

; ---- var= of a record whose mask is 0: DisplayListB_ExtractField computes
;      A = (var) & mask, so with mask 0 the field is 0 whatever var names and the
;      record always draws value 0 / entry 0 -- the address is not a variable.
	.equ DLB_NoVariable, 0x0000

; ---- the value as decimal digits at a display-RAM position -> DLB_Handler_Decimal
;      (T_Value_ToAsciiDigits3_RightJustified; digits = 3 / 2 / else 1 picks the
;      first of the three digits drawn).  10 bytes.  dlb_number16 reads the
;      variable as a 16-bit word instead of through the bit-field (`cp A,6`).
.macro dlb_number var, mask, shift, svc, x, y, digits, length=10
	.byte 0x00, \length
	.short \var
	.byte \mask, \shift, \svc
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.byte \digits
.endm
.macro dlb_number16 var, mask, shift, svc, x, y, digits, length=10
	.byte 0x06, \length
	.short \var
	.byte \mask, \shift, \svc
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.byte \digits
.endm
; ---- signed: one more character, the sign, unless bit 7 of signflag is set
;      (DisplayListB_ExtractFieldSigned).  11 bytes.
.macro dlb_number_signed var, mask, shift, svc, x, y, digits, signflag, length=11
	.byte 0x05, \length
	.short \var
	.byte \mask, \shift, \svc
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
	.byte \digits, \signflag
.endm
; ---- the same at a pixel position (LCD_X0 / LCD_Y0) -> DLB_Handler_Decimal2Words
;      (opcode 0x0A: the 16-bit read) and DLB_Handler_DecimalSigned2Words.
.macro dlb_number_xy var, mask, shift, svc, x, y, digits, length=12
	.byte 0x09, \length
	.short \var
	.byte \mask, \shift, \svc
	.short \x, \y
	.byte \digits
.endm
.macro dlb_number16_xy var, mask, shift, svc, x, y, digits, length=12
	.byte 0x0a, \length
	.short \var
	.byte \mask, \shift, \svc
	.short \x, \y
	.byte \digits
.endm
.macro dlb_number_signed_xy var, mask, shift, svc, x, y, digits, signflag, length=13
	.byte 0x0b, \length
	.short \var
	.byte \mask, \shift, \svc
	.short \x, \y
	.byte \digits, \signflag
.endm

; ---- entry [value] of a string table of <width>-character entries, at a
;      display-RAM position -> DLB_Handler_StringTable.  15 bytes.
.macro dlb_string var, mask, shift, svc, table, width, x, y, length=15
	.byte 0x02, \length
	.short \var
	.byte \mask, \shift, \svc
	.long \table
	.short \width
	.if ((\x) % 8) <> 0
	.error "display-list position: x must be a multiple of 8 (one display byte = 8 pixels)"
	.endif
	.short (\y) * 40 + (\x) / 8
.endm
; ---- the same at a pixel position -> DLB_Handler_StringTable2.  17 bytes.
.macro dlb_string_xy var, mask, shift, svc, table, width, x, y, length=17
	.byte 0x07, \length
	.short \var
	.byte \mask, \shift, \svc
	.long \table
	.short \width, \x, \y
.endm

; ---- entry [value] of a table of 8-byte (x0, y0, x1, y1) rectangles, drawn by
;      service svc -> DLB_Handler_Array8.  11 bytes.  Opcodes 0x03 and 0x08 share
;      the handler.  TODO: what tells them apart -- nothing in DLB_Handler_Array8
;      reads the opcode.
.macro dlb_rect_entry var, mask, shift, svc, table, length=11
	.byte 0x03, \length
	.short \var
	.byte \mask, \shift, \svc
	.long \table
.endm
.macro dlb_rect_entry_op08 var, mask, shift, svc, table, length=11
	.byte 0x08, \length
	.short \var
	.byte \mask, \shift, \svc
	.long \table
.endm
; ---- entry [value] of a table of 6-byte (position, columns, rows) areas -> IY / BC
;      / HL -> DLB_Handler_Array6.  11 bytes.
.macro dlb_area_entry var, mask, shift, svc, table, length=11
	.byte 0x04, \length
	.short \var
	.byte \mask, \shift, \svc
	.long \table
.endm
; ---- a box whose top edge rises by value / 2 above y1 -> DLB_Handler_CentredSpan
;      (service 0x0A hard-coded).  12 bytes.
.macro dlb_centred_span var, mask, shift, x0, x1, y1, length=12
	.byte 0x01, \length
	.short \var
	.byte \mask, \shift
	.short \x0, \x1, \y1
.endm

; ==============================================================================
; PANEL KEY MAPS -- a screen's Button method: 32 handlers, one per panel key code
;
; PanelButton_Route (prom_a 0xF8621E) reduces a panel event to a 5-bit KEY CODE
; (`and L,0x1f` at 0xF861AE) and calls the current screen object's +8 Button
; method (PanelScreen_VtableTable), which indexes its key map with that code --
; `cp BC,0x1F / sll 2,BC / add XBC,<map> / ld XBC,(XBC) / jp (XBC)`, or the same
; through T_F41B08 / T_F41B0C (`cp HL,0x001F`).  The key behind each code is
; re-derived from the ROM by notes/prom_a_panel_control_map.py (the wire -> group
; map and the group event lists, composed with the service manual's switch
; matrix) and agrees with prom_b's round-12 SLOT_CONTROL slot for slot:
; FINDINGS-prom_a-panel-control-map.md section 1.  The handler receives the pair
; position in bit 7 of the delivered code (W).
;
;	keymap_begin
;	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_TrackClear_StageZero
;	...				(all 32, in code order -- the macros refuse a gap)
;	keymap_end
; ==============================================================================
	.equ KEY_SoftKeyCol1,	0x00	; SOFT KEY column 1; the column's lower and upper key share the code (pair position 0 = lower, 1 = upper)
	.equ KEY_SoftKeyCol2,	0x01	; SOFT KEY column 2
	.equ KEY_SoftKeyCol3,	0x02	; SOFT KEY column 3
	.equ KEY_SoftKeyCol4,	0x03	; SOFT KEY column 4
	.equ KEY_SoftKeyCol5,	0x04	; SOFT KEY column 5
	.equ KEY_SoftKeyCol6,	0x05	; SOFT KEY column 6
	.equ KEY_SoftKeyCol7,	0x06	; SOFT KEY column 7
	.equ KEY_SoftKeyCol8,	0x07	; SOFT KEY column 8
	.equ KEY_LcdRow1,	0x08	; LCD-row key pair 1, top to bottom; position 0 = the left (CP2) key, 1 = the right (CP1) key
	.equ KEY_LcdRow2,	0x09	; LCD-row key pair 2
	.equ KEY_LcdRow3,	0x0a	; LCD-row key pair 3
	.equ KEY_LcdRow4,	0x0b	; LCD-row key pair 4
	.equ KEY_LcdRow5,	0x0c	; LCD-row key pair 5
	.equ KEY_MinusPlus,	0x0d	; the -1 / +1 pair; position 0 = -1, 1 = +1
	.equ KEY_Code0E,	0x0e	; TODO: nothing on this panel raises code 0x0E (no template emits it)
	.equ KEY_Exit,		0x0f	; EXIT (position 1 only); the one slot all 32 prom_b ButtonTable_* maps fill, with an ExitKey_* handler
	.equ KEY_Page,		0x10	; the PAGE v / PAGE ^ pair; position 0 = v, 1 = ^
	.equ KEY_SoftKeyCol1Alt,	0x11	; the soft-key column's SECOND event: PanelEvent_ToFieldIndex (prom_a) folds codes 0x11-0x18 onto ops 0-7, the codes of KEY_SoftKeyCol1-8, and sets bit 7 of its flag byte; in the 87 key maps 182 of these slots repeat the column's own handler, 41 differ.  TODO: which physical action raises it -- no prom_a panel template emits it
	.equ KEY_SoftKeyCol2Alt,	0x12	; as KEY_SoftKeyCol1Alt, for column 2
	.equ KEY_SoftKeyCol3Alt,	0x13	; as KEY_SoftKeyCol1Alt, for column 3
	.equ KEY_SoftKeyCol4Alt,	0x14	; as KEY_SoftKeyCol1Alt, for column 4
	.equ KEY_SoftKeyCol5Alt,	0x15	; as KEY_SoftKeyCol1Alt, for column 5
	.equ KEY_SoftKeyCol6Alt,	0x16	; as KEY_SoftKeyCol1Alt, for column 6
	.equ KEY_SoftKeyCol7Alt,	0x17	; as KEY_SoftKeyCol1Alt, for column 7
	.equ KEY_SoftKeyCol8Alt,	0x18	; as KEY_SoftKeyCol1Alt, for column 8
	.equ KEY_PageAlt,	0x19	; PAGE's second event: PanelEvent_ToFieldIndex folds code 0x19 onto op 0x10, KEY_Page's.  TODO: as KEY_SoftKeyCol1Alt
	.equ KEY_Code1A,	0x1a	; TODO: no template emits this code and no control is known for it
	.equ KEY_NumberPad,	0x1b	; the number pad, the whole field
	.equ KEY_Code1C,	0x1c	; TODO: no template emits this code and no control is known for it
	.equ KEY_Code1D,	0x1d	; TODO: no template emits this code and no control is known for it
	.equ KEY_Compare,	0x1e	; COMPARE (position 1); no screen's key map handles it
	.equ KEY_Code1F,	0x1f	; TODO: no template emits this code and no control is known for it

.macro keymap_begin
	.set _keymap_next, 0
.endm
.macro on_key key, handler
	.if (\key) <> _keymap_next
	.error "on_key: a key map lists every key code once, in code order (KEY_* above)"
	.endif
	.set _keymap_next, _keymap_next + 1
	.long \handler
.endm
.macro keymap_end
	.if _keymap_next <> 32
	.error "keymap_end: a key map has exactly 32 entries, one per key code"
	.endif
.endm

; ---- a tone-edit page's FIELD OPERATION table: the same idea, 17 entries.
;      PanelEvent_ToFieldIndex (prom_a 0xFD7905) turns the key code into an
;      operation 0..16 before the page dispatches: codes 0x00-0x10 are their own
;      operation (`cp DE,0x0010 / jr ugt`, 0xFD7946), 0x11-0x18 become 0-7 with
;      bit 7 of the flag byte set (`sub C,0x11` / `or (XIX),0x80`, 0xFD796A),
;      0x19 becomes 0x10 (0xFD7986), and every other code is refused.  So entry k
;      is the handler of KEY code k for k = 0..16, and the table ends in a zero
;      word no reader can index.
;	keymap_begin
;	on_key	KEY_SoftKeyCol1,	...	(17 entries, KEY_SoftKeyCol1 .. KEY_Page)
;	fieldops_end
.macro fieldops_end
	.if _keymap_next <> 17
	.error "fieldops_end: a field-operation table has exactly 17 entries, key codes 0x00-0x10"
	.endif
	.long 0
.endm

.endif
