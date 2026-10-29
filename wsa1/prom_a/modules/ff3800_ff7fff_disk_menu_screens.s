; ==============================================================================
; 0xFF3800-0xFF7C65 -- A UI SCREEN MODULE, and its fourteen dispatch tables
; ==============================================================================
;
; Converted 2026-08-25.  Chosen because `notes/prom_a_module_frontier.py` ranks
; the directory run T_F423A0-T_F42428 first in prom_a -- 35 slots over a
; contiguous 10,578-byte unconverted extent -- and it lands here.
;
; WHAT THE MODULE IS, with the evidence and with what is NOT claimed.
; 0xFF42EE is one of the 111 sites of the model-variant strap `(0x0000C4)`, and
; it is the one `kn7000_mame/notes/WSA1-EMULATION-DISASM-GAPS.md` already
; disassembled from the emulation side: it chooses between display list
; 0xF580B0 (MIDI FILE LOAD / MIDI FILE SAVE / LOAD SINGLE SOUND / LOAD SINGLE
; COMBI.) and 0xF58127 (only the last two).  That is the DISK MENU.  So this
; module owns the screen the disk functions live on -- which is exactly where
; emulation gap V said to look.  ⚠ What is NOT claimed is which of the fourteen
; tables below is the disk menu's: the tables are indexed by an argument, and
; nothing here ties an index to a legend.
;
; THE SHAPE, which is the same in all fourteen readers and is why they can be
; tabulated at all.  Each reader is
;
;     link XIZ,0 / push HL
;     ld H,(XIZ+0x08)            ; the control index
;     cp H,0x20 / jr NC, out     ; <- THE BOUND: 32 entries per row
;     [ cp (0x2229),#n / jr NC, out ]   ; <- optional: n rows
;     push (XIZ+0x0A)            ; the argument passed to the handler
;     C = 4 * (32*(0x2229) + H)
;     add XBC, <table base> / ld XBC,(XBC)
;     push <return address> / jp (XBC)
;
; so every table's BASE and every table's ENTRY COUNT are literals in its own
; reader.  That is how the counts below were established -- not by a shape run,
; and not by where the next table starts.  `(0x2229)` is a page/mode byte.
;
; ★ AND THE TABLES TILE 0xFF3800-0xFF42B1 EXACTLY, with no gap and no overlap,
; which is the independent check on all fourteen counts at once:
;
;   0xFF3800  32          reader 0xFF431C     0xFF4041    2         0xFF672D
;   0xFF3880  32          reader 0xFF4596     0xFF4049    2 x 32    0xFF68D8
;   0xFF3900  32          reader 0xFF4995     0xFF4149    2         0xFF6DB7
;   0xFF3980  32          reader 0xFF522F     0xFF4151    2 x 32    0xFF6F21
;   0xFF3A00   6          reader 0xFF548A     0xFF4251   16 ptrs    0xFF70B6
;   0xFF3A18  text, 17 B                      0xFF4291   text, 16 B
;   0xFF3A29  6 x 32      reader 0xFF572E     0xFF42A1   text, 4x4  0xFF744E
;   0xFF3D29   4          reader 0xFF5C3E
;   0xFF3D39  6 x 32      readers 0xFF5ED1 (rows 0-4), 0xFF6550 (row 4),
;                                 0xFF66AA (row 5)
;   0xFF4039  4 words     reader 0xFF6789
;
; ★ THE DEFAULT ENTRY IS 0xFF42B1, AND 0xFF42B1 IS A BARE `ret`.  Of the 654
; slots in the twelve pointer tables, 459 -- seventy per cent -- are that one
; address, and only 112 distinct targets appear in all of them together.  So
; most of the matrix is "this control does nothing on this page" and the live
; handlers are the sparse exceptions.  104 of the 112 targets are inside this
; module; the other eight are the prom_b directory slots 0xF42F84-0xF42FA0.
; Per-table counts: notes/prom_a_uiscreen_checks.py.
;
; Every handler is `sub_XXXXXX`.  Nothing in this module names a control.
;
; ★ SUPERSEDED 2026-08-31, and the sentence above is kept because it is
;   what was true before.  The 32 indices ARE the panel's controls: the
;   5-bit event code, composed out of the wire->group map (0xF8A189) and
;   the group event lists (0xF8B4B2) and checked against the service
;   manual's switch matrix.  Every table below now carries the legend and
;   its own live-entry list; the derivation, the variant adjudication it
;   inherits from round 11, and its corroborations are in
;   notes/FINDINGS-prom_a-panel-control-map.md.
;   ★ AND EACH TABLE'S SCREEN IS NAMED TOO, from the screen object that
;   installs the reader as its BUTTON method -- so the handlers read
;   LcdKeyRow1_DiskMenu and ExitKey_MidiFileL0ad rather than carrying a
;   table address.  This module owns ten screens: the DISK MENU, MIDI
;   FILE LOAD / SAVE / DIRECT PLAY, DISK LOAD FILE / SAVE FILE, LOAD
;   SINGLE SOUND / COMBINATION, and the two floppy-format screens.
;   ⚠ It ties an index to a CONTROL, not to a FUNCTION.  What a handler
;   DOES with the button is still open, and a target reached at two
;   different indices is refused -- so many handlers here are still
;   `sub_XXXXXX` on purpose.
;
; ---------------------------------------------------------------------
; Dispatch_FF3800 -- 32 handler pointers, indexed by the control number
;
; Read by: 0xFF431C.  ENTRY COUNT 32, from that reader's own `cp H,0x20 /
;          jr NC` at 0xFF4324 -- an index of 32 or more returns without
;          touching the table.
; ★ LAST-ENTRY TEST: entry 31 is at 0xFF387C and the word at 0xFF3880 is the
;          first entry of the NEXT table, which has its own reader and its own
;          bound; the run cannot be extended without colliding with it.
; Evidence: the reader's `add XBC,0x00FF3800 / ld XBC,(XBC) / push <retaddr> /
;          jp (XBC)` -- these are called, not jumped to.
; Unknown:  what the control index means.  ⚠ Not one entry is tied to a legend.
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; ★ CONTROL LEGEND, added 2026-08-31. The header above ends "⚠ Not one entry
;          is tied to a legend." This table's are, now -- with a map this
;          lane did not invent.
;
; The index is the 5-bit PANEL EVENT CODE PanelButton_Route produces (`and
;          L,0x1f`, 0xF861AE). ROUNDS 9-12 established what each code is, and
;          named 131 handlers in prom_b for these same codes (SoftKeyColN /
;          LcdKeyRowN / ExitKey); the tables in THIS module were never tied
;          to it. notes/prom_a_panel_control_map.py re-derives the map from
;          the ROM by an independent route -- the wire->group map at 0xF8A189
;          and the group event lists at 0xF8B4B2, composed with the service
;          manual's switch matrix -- and AGREES with prom_b's SLOT_CONTROL
;          slot for slot. Its corroborations all pass -- run --checks; a
;          count is not quoted here because a hand-copied count rots.
;          Write-up: notes/FINDINGS-prom_a-panel-control-map.md.
;
;   [00]..[07]  SOFT KEY columns 1..8; a column's lower and upper
;               key share a code
;   [08]..[0C]  the five LCD-row buttons, top to bottom; a row's
;               left-hand and right-hand key share a code
;   [0D]        the -1 / +1 pair          [0F]  EXIT
;   [0E]        nothing on this panel raises it
;   [10]        the PAGE v / PAGE ^ pair  [1E]  COMPARE
;   [1B]        the number pad, whole field
;   [20]        mode/menu select -- OUT OF RANGE for a 32-entry
;               table; PanelEvent_Code20_SetScreen takes it instead
;
; LIVE in this table: [08], [09], [0A], [0B], [0F].
; Everything else is this module's do-nothing default.
; ⚠ A live index names the CONTROL, not the FUNCTION.
; ---------------------------------------------------------------------
Dispatch_FF3800:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8,	DispatchMatrix_NoAction
	on_key	KEY_LcdRow1,		LcdKeyRow1_DiskMenu
	on_key	KEY_LcdRow2,		LcdKeyRow2_DiskMenu
	on_key	KEY_LcdRow3,		LcdKeyRow3_DiskMenu
	on_key	KEY_LcdRow4,		LcdKeyRow4_DiskMenu
	on_key	KEY_LcdRow5,		DispatchMatrix_NoAction
	on_key	KEY_MinusPlus,		DispatchMatrix_NoAction
	on_key	KEY_Code0E,		DispatchMatrix_NoAction
	on_key	KEY_Exit,		ExitKey_DiskMenu
	on_key	KEY_Page,		DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol1Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8Alt,	DispatchMatrix_NoAction
	on_key	KEY_PageAlt,		DispatchMatrix_NoAction
	on_key	KEY_Code1A,		DispatchMatrix_NoAction
	on_key	KEY_NumberPad,		DispatchMatrix_NoAction
	on_key	KEY_Code1C,		DispatchMatrix_NoAction
	on_key	KEY_Code1D,		DispatchMatrix_NoAction
	on_key	KEY_Compare,		DispatchMatrix_NoAction
	on_key	KEY_Code1F,		DispatchMatrix_NoAction
	keymap_end
; ---------------------------------------------------------------------
; Dispatch_FF3880 -- 32 handler pointers.  Read by 0xFF4596, whose bound is the
; same `cp H,0x20 / jr NC` at 0xFF459E.  As Dispatch_FF3800 in every other way.
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; ★ CONTROL LEGEND, added 2026-08-31. The header above ends "⚠ Not one entry
;          is tied to a legend." This table's are, now -- with a map this
;          lane did not invent.
;
; The index is the 5-bit PANEL EVENT CODE PanelButton_Route produces (`and
;          L,0x1f`, 0xF861AE). ROUNDS 9-12 established what each code is, and
;          named 131 handlers in prom_b for these same codes (SoftKeyColN /
;          LcdKeyRowN / ExitKey); the tables in THIS module were never tied
;          to it. notes/prom_a_panel_control_map.py re-derives the map from
;          the ROM by an independent route -- the wire->group map at 0xF8A189
;          and the group event lists at 0xF8B4B2, composed with the service
;          manual's switch matrix -- and AGREES with prom_b's SLOT_CONTROL
;          slot for slot. Its corroborations all pass -- run --checks; a
;          count is not quoted here because a hand-copied count rots.
;          Write-up: notes/FINDINGS-prom_a-panel-control-map.md.
;
;   [00]..[07]  SOFT KEY columns 1..8; a column's lower and upper
;               key share a code
;   [08]..[0C]  the five LCD-row buttons, top to bottom; a row's
;               left-hand and right-hand key share a code
;   [0D]        the -1 / +1 pair          [0F]  EXIT
;   [0E]        nothing on this panel raises it
;   [10]        the PAGE v / PAGE ^ pair  [1E]  COMPARE
;   [1B]        the number pad, whole field
;   [20]        mode/menu select -- OUT OF RANGE for a 32-entry
;               table; PanelEvent_Code20_SetScreen takes it instead
;
; LIVE in this table: [08], [09], [0A], [0B], [0C], [0F].
; Everything else is this module's do-nothing default.
; ⚠ A live index names the CONTROL, not the FUNCTION.
; ---------------------------------------------------------------------
Dispatch_FF3880:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8,	DispatchMatrix_NoAction
	on_key	KEY_LcdRow1,		LcdKeyRow1_MidiFileDirectPlay
	on_key	KEY_LcdRow2,		LcdKeyRow2_MidiFileDirectPlay
	on_key	KEY_LcdRow3,		LcdKeyRow3_MidiFileDirectPlay
	on_key	KEY_LcdRow4,		LcdKeyRow4_MidiFileDirectPlay
	on_key	KEY_LcdRow5,		LcdKeyRow5_MidiFileDirectPlay
	on_key	KEY_MinusPlus,		DispatchMatrix_NoAction
	on_key	KEY_Code0E,		DispatchMatrix_NoAction
	on_key	KEY_Exit,		ExitKey_MidiFileDirectPlay
	on_key	KEY_Page,		DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol1Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8Alt,	DispatchMatrix_NoAction
	on_key	KEY_PageAlt,		DispatchMatrix_NoAction
	on_key	KEY_Code1A,		DispatchMatrix_NoAction
	on_key	KEY_NumberPad,		DispatchMatrix_NoAction
	on_key	KEY_Code1C,		DispatchMatrix_NoAction
	on_key	KEY_Code1D,		DispatchMatrix_NoAction
	on_key	KEY_Compare,		DispatchMatrix_NoAction
	on_key	KEY_Code1F,		DispatchMatrix_NoAction
	keymap_end
; ---------------------------------------------------------------------
; Dispatch_FF3900 -- 32 handler pointers.  Read by 0xFF4995 (`cp H,0x20` at
; 0xFF499D).
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; ★ CONTROL LEGEND, added 2026-08-31. The header above ends "⚠ Not one entry
;          is tied to a legend." This table's are, now -- with a map this
;          lane did not invent.
;
; The index is the 5-bit PANEL EVENT CODE PanelButton_Route produces (`and
;          L,0x1f`, 0xF861AE). ROUNDS 9-12 established what each code is, and
;          named 131 handlers in prom_b for these same codes (SoftKeyColN /
;          LcdKeyRowN / ExitKey); the tables in THIS module were never tied
;          to it. notes/prom_a_panel_control_map.py re-derives the map from
;          the ROM by an independent route -- the wire->group map at 0xF8A189
;          and the group event lists at 0xF8B4B2, composed with the service
;          manual's switch matrix -- and AGREES with prom_b's SLOT_CONTROL
;          slot for slot. Its corroborations all pass -- run --checks; a
;          count is not quoted here because a hand-copied count rots.
;          Write-up: notes/FINDINGS-prom_a-panel-control-map.md.
;
;   [00]..[07]  SOFT KEY columns 1..8; a column's lower and upper
;               key share a code
;   [08]..[0C]  the five LCD-row buttons, top to bottom; a row's
;               left-hand and right-hand key share a code
;   [0D]        the -1 / +1 pair          [0F]  EXIT
;   [0E]        nothing on this panel raises it
;   [10]        the PAGE v / PAGE ^ pair  [1E]  COMPARE
;   [1B]        the number pad, whole field
;   [20]        mode/menu select -- OUT OF RANGE for a 32-entry
;               table; PanelEvent_Code20_SetScreen takes it instead
;
; LIVE in this table: [08], [09], [0A], [0B], [0C], [0F].
; Everything else is this module's do-nothing default.
; ⚠ A live index names the CONTROL, not the FUNCTION.
; ---------------------------------------------------------------------
Dispatch_FF3900:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8,	DispatchMatrix_NoAction
	on_key	KEY_LcdRow1,		LcdKeyRow1_DiskL0adFile
	on_key	KEY_LcdRow2,		LcdKeyRow2_DiskL0adFile
	on_key	KEY_LcdRow3,		LcdKeyRow3_DiskL0adFile
	on_key	KEY_LcdRow4,		LcdKeyRow4_DiskL0adFile
	on_key	KEY_LcdRow5,		LcdKeyRow5_DiskL0adFile
	on_key	KEY_MinusPlus,		DispatchMatrix_NoAction
	on_key	KEY_Code0E,		DispatchMatrix_NoAction
	on_key	KEY_Exit,		ExitKey_DiskL0adFile
	on_key	KEY_Page,		DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol1Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8Alt,	DispatchMatrix_NoAction
	on_key	KEY_PageAlt,		DispatchMatrix_NoAction
	on_key	KEY_Code1A,		DispatchMatrix_NoAction
	on_key	KEY_NumberPad,		DispatchMatrix_NoAction
	on_key	KEY_Code1C,		DispatchMatrix_NoAction
	on_key	KEY_Code1D,		DispatchMatrix_NoAction
	on_key	KEY_Compare,		DispatchMatrix_NoAction
	on_key	KEY_Code1F,		DispatchMatrix_NoAction
	keymap_end
; ---------------------------------------------------------------------
; Dispatch_FF3980 -- 32 handler pointers.  Read by 0xFF522F (`cp H,0x20` at
; 0xFF5237).
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; ★ CONTROL LEGEND, added 2026-08-31. The header above ends "⚠ Not one entry
;          is tied to a legend." This table's are, now -- with a map this
;          lane did not invent.
;
; The index is the 5-bit PANEL EVENT CODE PanelButton_Route produces (`and
;          L,0x1f`, 0xF861AE). ROUNDS 9-12 established what each code is, and
;          named 131 handlers in prom_b for these same codes (SoftKeyColN /
;          LcdKeyRowN / ExitKey); the tables in THIS module were never tied
;          to it. notes/prom_a_panel_control_map.py re-derives the map from
;          the ROM by an independent route -- the wire->group map at 0xF8A189
;          and the group event lists at 0xF8B4B2, composed with the service
;          manual's switch matrix -- and AGREES with prom_b's SLOT_CONTROL
;          slot for slot. Its corroborations all pass -- run --checks; a
;          count is not quoted here because a hand-copied count rots.
;          Write-up: notes/FINDINGS-prom_a-panel-control-map.md.
;
;   [00]..[07]  SOFT KEY columns 1..8; a column's lower and upper
;               key share a code
;   [08]..[0C]  the five LCD-row buttons, top to bottom; a row's
;               left-hand and right-hand key share a code
;   [0D]        the -1 / +1 pair          [0F]  EXIT
;   [0E]        nothing on this panel raises it
;   [10]        the PAGE v / PAGE ^ pair  [1E]  COMPARE
;   [1B]        the number pad, whole field
;   [20]        mode/menu select -- OUT OF RANGE for a 32-entry
;               table; PanelEvent_Code20_SetScreen takes it instead
;
; LIVE in this table: [08], [09], [0A], [0B], [0C], [0F].
; Everything else is this module's do-nothing default.
; ⚠ A live index names the CONTROL, not the FUNCTION.
; ---------------------------------------------------------------------
Dispatch_FF3980:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8,	DispatchMatrix_NoAction
	on_key	KEY_LcdRow1,		LcdKeyRow1_MidiFileL0ad
	on_key	KEY_LcdRow2,		LcdKeyRow2_MidiFileL0ad
	on_key	KEY_LcdRow3,		LcdKeyRow3_MidiFileL0ad
	on_key	KEY_LcdRow4,		LcdKeyRow4_MidiFileL0ad
	on_key	KEY_LcdRow5,		LcdKeyRow5_MidiFileL0ad
	on_key	KEY_MinusPlus,		DispatchMatrix_NoAction
	on_key	KEY_Code0E,		DispatchMatrix_NoAction
	on_key	KEY_Exit,		ExitKey_MidiFileL0ad
	on_key	KEY_Page,		DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol1Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8Alt,	DispatchMatrix_NoAction
	on_key	KEY_PageAlt,		DispatchMatrix_NoAction
	on_key	KEY_Code1A,		DispatchMatrix_NoAction
	on_key	KEY_NumberPad,		DispatchMatrix_NoAction
	on_key	KEY_Code1C,		DispatchMatrix_NoAction
	on_key	KEY_Code1D,		DispatchMatrix_NoAction
	on_key	KEY_Compare,		DispatchMatrix_NoAction
	on_key	KEY_Code1F,		DispatchMatrix_NoAction
	keymap_end
; ---------------------------------------------------------------------
; ScreenEnterPages_DiskSaveFile -- SIX handler pointers, indexed by the page byte (0x2229)
;
; Read by: 0xFF548A.  ENTRY COUNT 6, from `cp (0x2229),0x06 / jr NC` at
;          0xFF548A itself -- and the six entries are all distinct, which the
;          32-entry tables' entries are not.
; ★ LAST-ENTRY TEST: 6 x 4 = 24 bytes ends at 0xFF3A18, which is where the
;          16-character text field begins; a seventh entry would read
;          "??  " as an address.
; Evidence: this table is indexed by the PAGE and not by the control -- the
;          reader multiplies (0x2229) by 4 and nothing else.
; ---------------------------------------------------------------------
; ScreenEnterPages_DiskSaveFile: PageDispatch_DiskSaveFile's per-page ENTER table, indexed by UI_ScreenPage (0..5)
;   (notes/prom_a_page_enter_names.py).
ScreenEnterPages_DiskSaveFile:
	.long ScreenEnter_DiskSaveFile_Page0                                 ; FF3A00  [  0]
	.long ScreenEnter_DiskSaveFile_Page1                                 ; FF3A04  [  1]
	.long ScreenEnter_DiskSaveFile_Page2                                 ; FF3A08  [  2]
	.long ScreenEnter_DiskSaveFile_Page3                                 ; FF3A0C  [  3]
	.long ScreenEnter_DiskSaveFile_Page4                                 ; FF3A10  [  4]
	.long ScreenEnter_DiskSaveFile_Page5                                 ; FF3A14  [  5]
; ---------------------------------------------------------------------
; Text_FF3A18 -- 17 bytes: "??" then 14 spaces then a NUL
;
; A 16-character display field with a NUL terminator.  Named by `lda_24` at
; 0xFF5628 and 0xFF5677 -- two sites, both inside this module, and it is passed
; as a pointer rather than indexed.
; ⚠ It is what makes the table region UNALIGNED: 17 is odd, so every table
; after it sits at an odd offset from 0xFF3800.  Any tool that assumes a single
; aligned array here is wrong, and one did before this header was written.
; Unknown:  which field shows "??", though a two-character unknown-value
;          placeholder is the obvious reading and is not claimed.
; ---------------------------------------------------------------------
Text_FF3A18:
	.byte 0x3f, 0x3f, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; FF3A18
	.byte 0x00                                                                ; FF3A28
; ---------------------------------------------------------------------
; Dispatch_FF3A29 -- a 6 x 32 handler MATRIX: page (0x2229) by control index
;
; Read by: 0xFF572E.  ENTRY COUNT 192, from TWO bounds in that reader --
;          `cp H,0x20 / jr NC` at 0xFF5736 and `cp (0x2229),0x06 / jr NC` at
;          0xFF573B -- and the index it forms is `((0x2229) << 5) + H`, so the
;          row stride is 32 and there are 6 rows.
; ★ LAST-ENTRY TEST: 6 x 32 x 4 = 768 bytes ends at 0xFF3D29, which is the base
;          the reader at 0xFF5C4D names for the NEXT table.
; 129 of the 192 slots are the default 0xFF42B1.
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; ★ CONTROL LEGEND, added 2026-08-31. The header above ends "⚠ Not one entry
;          is tied to a legend." This table's are, now -- with a map this
;          lane did not invent.
;
; The index is the 5-bit PANEL EVENT CODE PanelButton_Route produces (`and
;          L,0x1f`, 0xF861AE). ROUNDS 9-12 established what each code is, and
;          named 131 handlers in prom_b for these same codes (SoftKeyColN /
;          LcdKeyRowN / ExitKey); the tables in THIS module were never tied
;          to it. notes/prom_a_panel_control_map.py re-derives the map from
;          the ROM by an independent route -- the wire->group map at 0xF8A189
;          and the group event lists at 0xF8B4B2, composed with the service
;          manual's switch matrix -- and AGREES with prom_b's SLOT_CONTROL
;          slot for slot. Its corroborations all pass -- run --checks; a
;          count is not quoted here because a hand-copied count rots.
;          Write-up: notes/FINDINGS-prom_a-panel-control-map.md.
;
;   [00]..[07]  SOFT KEY columns 1..8; a column's lower and upper
;               key share a code
;   [08]..[0C]  the five LCD-row buttons, top to bottom; a row's
;               left-hand and right-hand key share a code
;   [0D]        the -1 / +1 pair          [0F]  EXIT
;   [0E]        nothing on this panel raises it
;   [10]        the PAGE v / PAGE ^ pair  [1E]  COMPARE
;   [1B]        the number pad, whole field
;   [20]        mode/menu select -- OUT OF RANGE for a 32-entry
;               table; PanelEvent_Code20_SetScreen takes it instead
;
; LIVE in this table: [00], [01], [02], [03], [04], [05], [06], [07], [08],
;          [09], [0A], [0B], [0C], [0F], [11], [12], [13], [14], [15], [16],
;          [17], [18].
; Everything else is this module's do-nothing default.
; ⚠ A live index names the CONTROL, not the FUNCTION.
; ---------------------------------------------------------------------
Dispatch_FF3A29:
; row 0 of 6
	keymap_begin
	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_DiskSaveFile_Page0
	on_key	KEY_SoftKeyCol2,	SoftKeyCol2_DiskSaveFile_Page0
	on_key	KEY_SoftKeyCol3,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_DiskSaveFile_Page0
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_DiskSaveFile_Page0
	on_key	KEY_SoftKeyCol6,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7,	SoftKeyCol7_DiskSaveFile_Page0
	on_key	KEY_SoftKeyCol8,	DispatchMatrix_NoAction
	on_key	KEY_LcdRow1,		LcdKeyRow1_DiskSaveFile_Page0
	on_key	KEY_LcdRow2,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow3,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow4,		LcdKeyRow4_DiskSaveFile_Page0
	on_key	KEY_LcdRow5,		DispatchMatrix_NoAction
	on_key	KEY_MinusPlus,		DispatchMatrix_NoAction
	on_key	KEY_Code0E,		DispatchMatrix_NoAction
	on_key	KEY_Exit,		ExitKey_DiskSaveFile_Page0
	on_key	KEY_Page,		DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol1Alt,	SoftKeyCol1_DiskSaveFile_Page0
	on_key	KEY_SoftKeyCol2Alt,	SoftKeyCol2_DiskSaveFile_Page0
	on_key	KEY_SoftKeyCol3Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4Alt,	SoftKeyCol4_DiskSaveFile_Page0
	on_key	KEY_SoftKeyCol5Alt,	SoftKeyCol5_DiskSaveFile_Page0
	on_key	KEY_SoftKeyCol6Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7Alt,	SoftKeyCol7_DiskSaveFile_Page0
	on_key	KEY_SoftKeyCol8Alt,	DispatchMatrix_NoAction
	on_key	KEY_PageAlt,		DispatchMatrix_NoAction
	on_key	KEY_Code1A,		DispatchMatrix_NoAction
	on_key	KEY_NumberPad,		DispatchMatrix_NoAction
	on_key	KEY_Code1C,		DispatchMatrix_NoAction
	on_key	KEY_Code1D,		DispatchMatrix_NoAction
	on_key	KEY_Compare,		DispatchMatrix_NoAction
	on_key	KEY_Code1F,		DispatchMatrix_NoAction
	keymap_end
; row 1 of 6
	keymap_begin
	on_key	KEY_SoftKeyCol1,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_DiskSaveFile_Page1
	on_key	KEY_SoftKeyCol5,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8,	DispatchMatrix_NoAction
	on_key	KEY_LcdRow1,		LcdKeyRow1_DiskSaveFile_Page1
	on_key	KEY_LcdRow2,		LcdKeyRow2_DiskSaveFile_Page1
	on_key	KEY_LcdRow3,		LcdKeyRow3_DiskSaveFile_Page1
	on_key	KEY_LcdRow4,		LcdKeyRow4_DiskSaveFile_Page1
	on_key	KEY_LcdRow5,		LcdKeyRow5_DiskSaveFile_Page1
	on_key	KEY_MinusPlus,		DispatchMatrix_NoAction
	on_key	KEY_Code0E,		DispatchMatrix_NoAction
	on_key	KEY_Exit,		ExitKey_DiskSaveFile_Page1
	on_key	KEY_Page,		DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol1Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4Alt,	SoftKeyCol4_DiskSaveFile_Page1
	on_key	KEY_SoftKeyCol5Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8Alt,	DispatchMatrix_NoAction
	on_key	KEY_PageAlt,		DispatchMatrix_NoAction
	on_key	KEY_Code1A,		DispatchMatrix_NoAction
	on_key	KEY_NumberPad,		DispatchMatrix_NoAction
	on_key	KEY_Code1C,		DispatchMatrix_NoAction
	on_key	KEY_Code1D,		DispatchMatrix_NoAction
	on_key	KEY_Compare,		DispatchMatrix_NoAction
	on_key	KEY_Code1F,		DispatchMatrix_NoAction
	keymap_end
; row 2 of 6
	keymap_begin
	on_key	KEY_SoftKeyCol1,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8,	DispatchMatrix_NoAction
	on_key	KEY_LcdRow1,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow2,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow3,		LcdKeyRow3_DiskSaveFile_Page2
	on_key	KEY_LcdRow4,		LcdKeyRow4_DiskSaveFile_Page2
	on_key	KEY_LcdRow5,		DispatchMatrix_NoAction
	on_key	KEY_MinusPlus,		DispatchMatrix_NoAction
	on_key	KEY_Code0E,		DispatchMatrix_NoAction
	on_key	KEY_Exit,		ExitKey_DiskSaveFile_Page2
	on_key	KEY_Page,		DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol1Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8Alt,	DispatchMatrix_NoAction
	on_key	KEY_PageAlt,		DispatchMatrix_NoAction
	on_key	KEY_Code1A,		DispatchMatrix_NoAction
	on_key	KEY_NumberPad,		DispatchMatrix_NoAction
	on_key	KEY_Code1C,		DispatchMatrix_NoAction
	on_key	KEY_Code1D,		DispatchMatrix_NoAction
	on_key	KEY_Compare,		DispatchMatrix_NoAction
	on_key	KEY_Code1F,		DispatchMatrix_NoAction
	keymap_end
; row 3 of 6
	keymap_begin
	on_key	KEY_SoftKeyCol1,	T_SoundEditNaming_SoftKeyCol1
	on_key	KEY_SoftKeyCol2,	T_SoundEditNaming_SoftKeyCol2
	on_key	KEY_SoftKeyCol3,	T_SoundEditNaming_SoftKeyCol3
	on_key	KEY_SoftKeyCol4,	T_SoundEditNaming_SoftKeyCol4
	on_key	KEY_SoftKeyCol5,	T_SoundEditNaming_SoftKeyCol5
	on_key	KEY_SoftKeyCol6,	T_SoundEditNaming_SoftKeyCol6
	on_key	KEY_SoftKeyCol7,	T_SoundEditNaming_SoftKeyCol7
	on_key	KEY_SoftKeyCol8,	T_SoundEditNaming_SoftKeyCol8
	on_key	KEY_LcdRow1,		LcdKeyRow1_DiskSaveFile_Page3
	on_key	KEY_LcdRow2,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow3,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow4,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow5,		DispatchMatrix_NoAction
	on_key	KEY_MinusPlus,		DispatchMatrix_NoAction
	on_key	KEY_Code0E,		DispatchMatrix_NoAction
	on_key	KEY_Exit,		ExitKey_DiskSaveFile_Pages3_4
	on_key	KEY_Page,		DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol1Alt,	T_SoundEditNaming_SoftKeyCol1
	on_key	KEY_SoftKeyCol2Alt,	T_SoundEditNaming_SoftKeyCol2
	on_key	KEY_SoftKeyCol3Alt,	T_SoundEditNaming_SoftKeyCol3
	on_key	KEY_SoftKeyCol4Alt,	T_SoundEditNaming_SoftKeyCol4
	on_key	KEY_SoftKeyCol5Alt,	T_SoundEditNaming_SoftKeyCol5
	on_key	KEY_SoftKeyCol6Alt,	T_SoundEditNaming_SoftKeyCol6
	on_key	KEY_SoftKeyCol7Alt,	T_SoundEditNaming_SoftKeyCol7
	on_key	KEY_SoftKeyCol8Alt,	T_SoundEditNaming_SoftKeyCol8
	on_key	KEY_PageAlt,		DispatchMatrix_NoAction
	on_key	KEY_Code1A,		DispatchMatrix_NoAction
	on_key	KEY_NumberPad,		DispatchMatrix_NoAction
	on_key	KEY_Code1C,		DispatchMatrix_NoAction
	on_key	KEY_Code1D,		DispatchMatrix_NoAction
	on_key	KEY_Compare,		DispatchMatrix_NoAction
	on_key	KEY_Code1F,		DispatchMatrix_NoAction
	keymap_end
; row 4 of 6
	keymap_begin
	on_key	KEY_SoftKeyCol1,	T_SoundEditNaming_SoftKeyCol1
	on_key	KEY_SoftKeyCol2,	T_SoundEditNaming_SoftKeyCol2
	on_key	KEY_SoftKeyCol3,	T_SoundEditNaming_SoftKeyCol3
	on_key	KEY_SoftKeyCol4,	T_SoundEditNaming_SoftKeyCol4
	on_key	KEY_SoftKeyCol5,	T_SoundEditNaming_SoftKeyCol5
	on_key	KEY_SoftKeyCol6,	T_SoundEditNaming_SoftKeyCol6
	on_key	KEY_SoftKeyCol7,	T_SoundEditNaming_SoftKeyCol7
	on_key	KEY_SoftKeyCol8,	T_SoundEditNaming_SoftKeyCol8
	on_key	KEY_LcdRow1,		LcdKeyRow1_DiskSaveFile_Page4
	on_key	KEY_LcdRow2,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow3,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow4,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow5,		DispatchMatrix_NoAction
	on_key	KEY_MinusPlus,		DispatchMatrix_NoAction
	on_key	KEY_Code0E,		DispatchMatrix_NoAction
	on_key	KEY_Exit,		ExitKey_DiskSaveFile_Pages3_4
	on_key	KEY_Page,		DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol1Alt,	T_SoundEditNaming_SoftKeyCol1
	on_key	KEY_SoftKeyCol2Alt,	T_SoundEditNaming_SoftKeyCol2
	on_key	KEY_SoftKeyCol3Alt,	T_SoundEditNaming_SoftKeyCol3
	on_key	KEY_SoftKeyCol4Alt,	T_SoundEditNaming_SoftKeyCol4
	on_key	KEY_SoftKeyCol5Alt,	T_SoundEditNaming_SoftKeyCol5
	on_key	KEY_SoftKeyCol6Alt,	T_SoundEditNaming_SoftKeyCol6
	on_key	KEY_SoftKeyCol7Alt,	T_SoundEditNaming_SoftKeyCol7
	on_key	KEY_SoftKeyCol8Alt,	T_SoundEditNaming_SoftKeyCol8
	on_key	KEY_PageAlt,		DispatchMatrix_NoAction
	on_key	KEY_Code1A,		DispatchMatrix_NoAction
	on_key	KEY_NumberPad,		DispatchMatrix_NoAction
	on_key	KEY_Code1C,		DispatchMatrix_NoAction
	on_key	KEY_Code1D,		DispatchMatrix_NoAction
	on_key	KEY_Compare,		DispatchMatrix_NoAction
	on_key	KEY_Code1F,		DispatchMatrix_NoAction
	keymap_end
; row 5 of 6
	keymap_begin
	on_key	KEY_SoftKeyCol1,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8,	DispatchMatrix_NoAction
	on_key	KEY_LcdRow1,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow2,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow3,		LcdKeyRow3_DiskSaveFile_Page5
	on_key	KEY_LcdRow4,		LcdKeyRow4_DiskSaveFile_Page5
	on_key	KEY_LcdRow5,		DispatchMatrix_NoAction
	on_key	KEY_MinusPlus,		DispatchMatrix_NoAction
	on_key	KEY_Code0E,		DispatchMatrix_NoAction
	on_key	KEY_Exit,		ExitKey_DiskSaveFile_Page5
	on_key	KEY_Page,		DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol1Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8Alt,	DispatchMatrix_NoAction
	on_key	KEY_PageAlt,		DispatchMatrix_NoAction
	on_key	KEY_Code1A,		DispatchMatrix_NoAction
	on_key	KEY_NumberPad,		DispatchMatrix_NoAction
	on_key	KEY_Code1C,		DispatchMatrix_NoAction
	on_key	KEY_Code1D,		DispatchMatrix_NoAction
	on_key	KEY_Compare,		DispatchMatrix_NoAction
	on_key	KEY_Code1F,		DispatchMatrix_NoAction
	keymap_end
; ---------------------------------------------------------------------
; ScreenEnterPages_MidiFileSave -- FOUR handler pointers, indexed by the page byte (0x2229)
;
; Read by: 0xFF5C3E.  ENTRY COUNT 4, from `cp (0x2229),0x03 / jr UGT` --
;          note UGT, not NC: this bound admits 3, so it is four entries and not
;          three.  All four are distinct.
; ---------------------------------------------------------------------
; ScreenEnterPages_MidiFileSave: PageDispatch_MidiFileSave's per-page ENTER table, indexed by UI_ScreenPage (0..3)
;   (notes/prom_a_page_enter_names.py).
ScreenEnterPages_MidiFileSave:
	.long ScreenEnter_MidiFileSave_Page0                                 ; FF3D29  [  0]
	.long ScreenEnter_MidiFileSave_Page1                                 ; FF3D2D  [  1]
	.long ScreenEnter_MidiFileSave_Page2                                 ; FF3D31  [  2]
	.long ScreenEnter_MidiFileSave_Page3                                 ; FF3D35  [  3]
; ---------------------------------------------------------------------
; Dispatch_FF3D39 -- a 6 x 32 handler MATRIX with THREE readers
;
; Read by: 0xFF5ED1 for rows 0-4 (`cp H,0x20` at 0xFF5ED9, `cp (0x2229),0x05 /
;          jr NC` at 0xFF5EDE), and by two readers that address a single row
;          directly and have only the 32-entry bound:
;            0xFF6550 -> base 0xFF3F39 = 0xFF3D39 + 4 x 128, i.e. ROW 4;
;            0xFF66AA -> base 0xFF3FB9 = 0xFF3D39 + 5 x 128, i.e. ROW 5.
;          So the matrix is SIX rows even though its matrix reader reaches
;          five, and row 5 exists only because a dedicated reader names it.
; ★ LAST-ENTRY TEST: 6 x 32 x 4 = 768 bytes ends at 0xFF4039, which is the base
;          the readers at 0xFF6789 and six other sites name for the next table.
; 159 of the 192 slots are the default.
; Unknown:  why row 4 has both a matrix reader and a dedicated one.
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; ★ CONTROL LEGEND, added 2026-08-31. The header above ends "⚠ Not one entry
;          is tied to a legend." This table's are, now -- with a map this
;          lane did not invent.
;
; The index is the 5-bit PANEL EVENT CODE PanelButton_Route produces (`and
;          L,0x1f`, 0xF861AE). ROUNDS 9-12 established what each code is, and
;          named 131 handlers in prom_b for these same codes (SoftKeyColN /
;          LcdKeyRowN / ExitKey); the tables in THIS module were never tied
;          to it. notes/prom_a_panel_control_map.py re-derives the map from
;          the ROM by an independent route -- the wire->group map at 0xF8A189
;          and the group event lists at 0xF8B4B2, composed with the service
;          manual's switch matrix -- and AGREES with prom_b's SLOT_CONTROL
;          slot for slot. Its corroborations all pass -- run --checks; a
;          count is not quoted here because a hand-copied count rots.
;          Write-up: notes/FINDINGS-prom_a-panel-control-map.md.
;
;   [00]..[07]  SOFT KEY columns 1..8; a column's lower and upper
;               key share a code
;   [08]..[0C]  the five LCD-row buttons, top to bottom; a row's
;               left-hand and right-hand key share a code
;   [0D]        the -1 / +1 pair          [0F]  EXIT
;   [0E]        nothing on this panel raises it
;   [10]        the PAGE v / PAGE ^ pair  [1E]  COMPARE
;   [1B]        the number pad, whole field
;   [20]        mode/menu select -- OUT OF RANGE for a 32-entry
;               table; PanelEvent_Code20_SetScreen takes it instead
;
; LIVE in this table: [00], [01], [03], [04], [06], [08], [09], [0A], [0B],
;          [0C], [0F], [11], [12], [14], [15], [17].
; Everything else is this module's do-nothing default.
; ⚠ A live index names the CONTROL, not the FUNCTION.
; ---------------------------------------------------------------------
Dispatch_FF3D39:
; row 0 of 6
	keymap_begin
	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_MidiFileSave_Page0
	on_key	KEY_SoftKeyCol2,	SoftKeyCol2_MidiFileSave_Page0
	on_key	KEY_SoftKeyCol3,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_MidiFileSave_Page0
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_MidiFileSave_Page0
	on_key	KEY_SoftKeyCol6,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7,	SoftKeyCol7_MidiFileSave_Page0
	on_key	KEY_SoftKeyCol8,	DispatchMatrix_NoAction
	on_key	KEY_LcdRow1,		LcdKeyRow1_MidiFileSave_Page0
	on_key	KEY_LcdRow2,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow3,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow4,		LcdKeyRow4_MidiFileSave_Page0
	on_key	KEY_LcdRow5,		DispatchMatrix_NoAction
	on_key	KEY_MinusPlus,		DispatchMatrix_NoAction
	on_key	KEY_Code0E,		DispatchMatrix_NoAction
	on_key	KEY_Exit,		ExitKey_MidiFileSave_Pages0_1_2_3
	on_key	KEY_Page,		DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol1Alt,	SoftKeyCol1_MidiFileSave_Page0
	on_key	KEY_SoftKeyCol2Alt,	SoftKeyCol2_MidiFileSave_Page0
	on_key	KEY_SoftKeyCol3Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4Alt,	SoftKeyCol4_MidiFileSave_Page0
	on_key	KEY_SoftKeyCol5Alt,	SoftKeyCol5_MidiFileSave_Page0
	on_key	KEY_SoftKeyCol6Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7Alt,	SoftKeyCol7_MidiFileSave_Page0
	on_key	KEY_SoftKeyCol8Alt,	DispatchMatrix_NoAction
	on_key	KEY_PageAlt,		DispatchMatrix_NoAction
	on_key	KEY_Code1A,		DispatchMatrix_NoAction
	on_key	KEY_NumberPad,		DispatchMatrix_NoAction
	on_key	KEY_Code1C,		DispatchMatrix_NoAction
	on_key	KEY_Code1D,		DispatchMatrix_NoAction
	on_key	KEY_Compare,		DispatchMatrix_NoAction
	on_key	KEY_Code1F,		DispatchMatrix_NoAction
	keymap_end
; row 1 of 6
	keymap_begin
	on_key	KEY_SoftKeyCol1,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8,	DispatchMatrix_NoAction
	on_key	KEY_LcdRow1,		LcdKeyRow1_MidiFileSave_Page1
	on_key	KEY_LcdRow2,		LcdKeyRow2_MidiFileSave_Page1
	on_key	KEY_LcdRow3,		LcdKeyRow3_MidiFileSave_Page1
	on_key	KEY_LcdRow4,		LcdKeyRow4_MidiFileSave_Page1
	on_key	KEY_LcdRow5,		LcdKeyRow5_MidiFileSave_Page1
	on_key	KEY_MinusPlus,		DispatchMatrix_NoAction
	on_key	KEY_Code0E,		DispatchMatrix_NoAction
	on_key	KEY_Exit,		ExitKey_MidiFileSave_Pages0_1_2_3
	on_key	KEY_Page,		DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol1Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8Alt,	DispatchMatrix_NoAction
	on_key	KEY_PageAlt,		DispatchMatrix_NoAction
	on_key	KEY_Code1A,		DispatchMatrix_NoAction
	on_key	KEY_NumberPad,		DispatchMatrix_NoAction
	on_key	KEY_Code1C,		DispatchMatrix_NoAction
	on_key	KEY_Code1D,		DispatchMatrix_NoAction
	on_key	KEY_Compare,		DispatchMatrix_NoAction
	on_key	KEY_Code1F,		DispatchMatrix_NoAction
	keymap_end
; row 2 of 6
	keymap_begin
	on_key	KEY_SoftKeyCol1,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8,	DispatchMatrix_NoAction
	on_key	KEY_LcdRow1,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow2,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow3,		LcdKeyRow3_MidiFileSave_Page2
	on_key	KEY_LcdRow4,		LcdKeyRow4_MidiFileSave_Page2
	on_key	KEY_LcdRow5,		DispatchMatrix_NoAction
	on_key	KEY_MinusPlus,		DispatchMatrix_NoAction
	on_key	KEY_Code0E,		DispatchMatrix_NoAction
	on_key	KEY_Exit,		ExitKey_MidiFileSave_Pages0_1_2_3
	on_key	KEY_Page,		DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol1Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8Alt,	DispatchMatrix_NoAction
	on_key	KEY_PageAlt,		DispatchMatrix_NoAction
	on_key	KEY_Code1A,		DispatchMatrix_NoAction
	on_key	KEY_NumberPad,		DispatchMatrix_NoAction
	on_key	KEY_Code1C,		DispatchMatrix_NoAction
	on_key	KEY_Code1D,		DispatchMatrix_NoAction
	on_key	KEY_Compare,		DispatchMatrix_NoAction
	on_key	KEY_Code1F,		DispatchMatrix_NoAction
	keymap_end
; row 3 of 6
	keymap_begin
	on_key	KEY_SoftKeyCol1,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8,	DispatchMatrix_NoAction
	on_key	KEY_LcdRow1,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow2,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow3,		LcdKeyRow3_MidiFileSave_Page3
	on_key	KEY_LcdRow4,		LcdKeyRow4_MidiFileSave_Page3
	on_key	KEY_LcdRow5,		DispatchMatrix_NoAction
	on_key	KEY_MinusPlus,		DispatchMatrix_NoAction
	on_key	KEY_Code0E,		DispatchMatrix_NoAction
	on_key	KEY_Exit,		ExitKey_MidiFileSave_Pages0_1_2_3
	on_key	KEY_Page,		DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol1Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8Alt,	DispatchMatrix_NoAction
	on_key	KEY_PageAlt,		DispatchMatrix_NoAction
	on_key	KEY_Code1A,		DispatchMatrix_NoAction
	on_key	KEY_NumberPad,		DispatchMatrix_NoAction
	on_key	KEY_Code1C,		DispatchMatrix_NoAction
	on_key	KEY_Code1D,		DispatchMatrix_NoAction
	on_key	KEY_Compare,		DispatchMatrix_NoAction
	on_key	KEY_Code1F,		DispatchMatrix_NoAction
	keymap_end
; row 4 of 6
	keymap_begin
	on_key	KEY_SoftKeyCol1,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4,	sub_FF657B
	on_key	KEY_SoftKeyCol5,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8,	DispatchMatrix_NoAction
	on_key	KEY_LcdRow1,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow2,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow3,		LcdKeyRow3_MidiFileSave_Page4
	on_key	KEY_LcdRow4,		LcdKeyRow4_MidiFileSave_Page4
	on_key	KEY_LcdRow5,		DispatchMatrix_NoAction
	on_key	KEY_MinusPlus,		DispatchMatrix_NoAction
	on_key	KEY_Code0E,		DispatchMatrix_NoAction
	on_key	KEY_Exit,		ExitKey_MidiFileSave_Page4
	on_key	KEY_Page,		DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol1Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5Alt,	sub_FF657B
	on_key	KEY_SoftKeyCol6Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8Alt,	DispatchMatrix_NoAction
	on_key	KEY_PageAlt,		DispatchMatrix_NoAction
	on_key	KEY_Code1A,		DispatchMatrix_NoAction
	on_key	KEY_NumberPad,		DispatchMatrix_NoAction
	on_key	KEY_Code1C,		DispatchMatrix_NoAction
	on_key	KEY_Code1D,		DispatchMatrix_NoAction
	on_key	KEY_Compare,		DispatchMatrix_NoAction
	on_key	KEY_Code1F,		DispatchMatrix_NoAction
	keymap_end
; row 5 of 6
	keymap_begin
	on_key	KEY_SoftKeyCol1,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8,	DispatchMatrix_NoAction
	on_key	KEY_LcdRow1,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow2,		DispatchMatrix_NoAction
	on_key	KEY_LcdRow3,		LcdKeyRow3_MidiFileSave_Page5
	on_key	KEY_LcdRow4,		LcdKeyRow4_MidiFileSave_Page5
	on_key	KEY_LcdRow5,		DispatchMatrix_NoAction
	on_key	KEY_MinusPlus,		DispatchMatrix_NoAction
	on_key	KEY_Code0E,		DispatchMatrix_NoAction
	on_key	KEY_Exit,		ExitKey_MidiFileSave_Page5
	on_key	KEY_Page,		DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol1Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol2Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol3Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol4Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol5Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol6Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol7Alt,	DispatchMatrix_NoAction
	on_key	KEY_SoftKeyCol8Alt,	DispatchMatrix_NoAction
	on_key	KEY_PageAlt,		DispatchMatrix_NoAction
	on_key	KEY_Code1A,		DispatchMatrix_NoAction
	on_key	KEY_NumberPad,		DispatchMatrix_NoAction
	on_key	KEY_Code1C,		DispatchMatrix_NoAction
	on_key	KEY_Code1D,		DispatchMatrix_NoAction
	on_key	KEY_Compare,		DispatchMatrix_NoAction
	on_key	KEY_Code1F,		DispatchMatrix_NoAction
	keymap_end
; ---------------------------------------------------------------------
; Table_FF4039 -- FOUR 16-bit values: 0x0008, 0x0009, 0x0028, 0x0029
;
; Emitted as `.byte` because the framing is 16-bit, not 32-bit, and this file's
; `.long` renderer would misstate it.
; Read by: eight sites, the clearest being 0xFF6789 `ld C,2 / mul (0x2736),3 /
;          extz XBC / add XBC,0x00FF4039 / ld BC,(XBC)` -- a 16-bit load at a
;          stride of 2, indexed by (0x2736).
; ⚠ ENTRY COUNT 4 is from the EXTENT (8 bytes between two tables whose bases
;          are both named by readers), NOT from a bound: no reader here bounds
;          (0x2736).  That is weaker than every other count in this module and
;          is stated as such.
; Unknown:  what the four values are.  They are two consecutive pairs 8 apart
;          in the low nibble, which is a pattern and not a meaning.
; ---------------------------------------------------------------------
Table_FF4039:
	.byte 0x08, 0x00, 0x09, 0x00, 0x28, 0x00, 0x29, 0x00                      ; FF4039
; ---------------------------------------------------------------------
; ScreenEnterPages_L0adSingleS0und -- TWO handler pointers, indexed by the page byte (0x2229)
; Read by: 0xFF672D.  ENTRY COUNT 2, from `cp (0x2229),0x02 / jr NC`.
; ---------------------------------------------------------------------
; ScreenEnterPages_L0adSingleS0und: PageDispatch_L0adSingleS0und's per-page ENTER table, indexed by UI_ScreenPage (0..1)
;   (notes/prom_a_page_enter_names.py).
ScreenEnterPages_L0adSingleS0und:
	.long ScreenEnter_L0adSingleS0und_Page0                                 ; FF4041  [  0]
	.long ScreenEnter_L0adSingleS0und_Page1                                 ; FF4045  [  1]
; ---------------------------------------------------------------------
; Dispatch_FF4049 -- a 2 x 32 handler matrix: page by control index
;
; Read by: 0xFF68D8, which forms `((0x2229) << 5) + H` exactly as the other
;          matrix readers do but carries NO bound of its own.
; ★ ENTRY COUNT 64 rests on two things and both are named: the extent between
;          this base and the next reader-named base (0xFF4149) is 256 bytes =
;          64 entries; and the sibling table ScreenEnterPages_L0adSingleS0und, which is indexed
;          by the SAME page byte, is bounded at 2 by its own reader -- so two
;          rows is what the page byte can address.
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; ★ CONTROL LEGEND, added 2026-08-31. The header above ends "⚠ Not one entry
;          is tied to a legend." This table's are, now -- with a map this
;          lane did not invent.
;
; The index is the 5-bit PANEL EVENT CODE PanelButton_Route produces (`and
;          L,0x1f`, 0xF861AE). ROUNDS 9-12 established what each code is, and
;          named 131 handlers in prom_b for these same codes (SoftKeyColN /
;          LcdKeyRowN / ExitKey); the tables in THIS module were never tied
;          to it. notes/prom_a_panel_control_map.py re-derives the map from
;          the ROM by an independent route -- the wire->group map at 0xF8A189
;          and the group event lists at 0xF8B4B2, composed with the service
;          manual's switch matrix -- and AGREES with prom_b's SLOT_CONTROL
;          slot for slot. Its corroborations all pass -- run --checks; a
;          count is not quoted here because a hand-copied count rots.
;          Write-up: notes/FINDINGS-prom_a-panel-control-map.md.
;
;   [00]..[07]  SOFT KEY columns 1..8; a column's lower and upper
;               key share a code
;   [08]..[0C]  the five LCD-row buttons, top to bottom; a row's
;               left-hand and right-hand key share a code
;   [0D]        the -1 / +1 pair          [0F]  EXIT
;   [0E]        nothing on this panel raises it
;   [10]        the PAGE v / PAGE ^ pair  [1E]  COMPARE
;   [1B]        the number pad, whole field
;   [20]        mode/menu select -- OUT OF RANGE for a 32-entry
;               table; PanelEvent_Code20_SetScreen takes it instead
;
; LIVE in this table: [00], [01], [02], [03], [04], [05], [06], [07], [08],
;          [0F], [11], [12], [13], [14], [15], [16], [17], [18].
; Everything else is this module's do-nothing default.
; ⚠ A live index names the CONTROL, not the FUNCTION.
; ---------------------------------------------------------------------
Dispatch_FF4049:
	.long SoftKeyCol1_L0adSingle_AllPages                                 ; FF4049  [  0]
	.long SoftKeyCol2_L0adSingleS0und_Page0                                 ; FF404D  [  1]
	.long SoftKeyCols3_4_L0adSingleS0und_Page0                                 ; FF4051  [  2]
	.long SoftKeyCols3_4_L0adSingleS0und_Page0                                 ; FF4055  [  3]
	.long SoftKeyCol5_L0adSingleS0und_Page0                                 ; FF4059  [  4]
	.long SoftKeyCol6_L0adSingle_Page0                                 ; FF405D  [  5]
	.long SoftKeyCols7_8_L0adSingleS0und_Page0                                 ; FF4061  [  6]
	.long SoftKeyCols7_8_L0adSingleS0und_Page0                                 ; FF4065  [  7]
	.long LcdKeyRow1_L0adSingleS0und_Page0           ; FF4069  [  8]
	.long DispatchMatrix_NoAction                                 ; FF406D  [  9]
	.long DispatchMatrix_NoAction                                 ; FF4071  [ 10]
	.long DispatchMatrix_NoAction                                 ; FF4075  [ 11]
	.long DispatchMatrix_NoAction                                 ; FF4079  [ 12]
	.long DispatchMatrix_NoAction                                 ; FF407D  [ 13]
	.long DispatchMatrix_NoAction                                 ; FF4081  [ 14]
	.long ExitKey_L0adSingleS0und_Pages0_1           ; FF4085  [ 15]
	.long DispatchMatrix_NoAction                                 ; FF4089  [ 16]
	.long SoftKeyCol1_L0adSingle_AllPages                                 ; FF408D  [ 17]
	.long SoftKeyCol2_L0adSingleS0und_Page0                                 ; FF4091  [ 18]
	.long SoftKeyCols3_4_L0adSingleS0und_Page0                                 ; FF4095  [ 19]
	.long SoftKeyCols3_4_L0adSingleS0und_Page0                                 ; FF4099  [ 20]
	.long SoftKeyCol5_L0adSingleS0und_Page0                                 ; FF409D  [ 21]
	.long SoftKeyCol6_L0adSingle_Page0                                 ; FF40A1  [ 22]
	.long SoftKeyCols7_8_L0adSingleS0und_Page0                                 ; FF40A5  [ 23]
	.long SoftKeyCols7_8_L0adSingleS0und_Page0                                 ; FF40A9  [ 24]
	.long DispatchMatrix_NoAction                                 ; FF40AD  [ 25]
	.long DispatchMatrix_NoAction                                 ; FF40B1  [ 26]
	.long DispatchMatrix_NoAction                                 ; FF40B5  [ 27]
	.long DispatchMatrix_NoAction                                 ; FF40B9  [ 28]
	.long DispatchMatrix_NoAction                                 ; FF40BD  [ 29]
	.long DispatchMatrix_NoAction                                 ; FF40C1  [ 30]
	.long DispatchMatrix_NoAction                                 ; FF40C5  [ 31]
	.long SoftKeyCol1_L0adSingle_AllPages                                 ; FF40C9  [ 32]
	.long SoftKeyCol2_L0adSingleS0und_Page1                                 ; FF40CD  [ 33]
	.long SoftKeyCols3_4_L0adSingle_Page1                                 ; FF40D1  [ 34]
	.long SoftKeyCols3_4_L0adSingle_Page1                                 ; FF40D5  [ 35]
	.long SoftKeyCols5_6_L0adSingleS0und_Page1                                 ; FF40D9  [ 36]
	.long SoftKeyCols5_6_L0adSingleS0und_Page1                                 ; FF40DD  [ 37]
	.long SoftKeyCols7_8_L0adSingle_Page1                                 ; FF40E1  [ 38]
	.long SoftKeyCols7_8_L0adSingle_Page1                                 ; FF40E5  [ 39]
	.long LcdKeyRow1_L0adSingleS0und_Page1           ; FF40E9  [ 40]
	.long DispatchMatrix_NoAction                                 ; FF40ED  [ 41]
	.long DispatchMatrix_NoAction                                 ; FF40F1  [ 42]
	.long DispatchMatrix_NoAction                                 ; FF40F5  [ 43]
	.long DispatchMatrix_NoAction                                 ; FF40F9  [ 44]
	.long DispatchMatrix_NoAction                                 ; FF40FD  [ 45]
	.long DispatchMatrix_NoAction                                 ; FF4101  [ 46]
	.long ExitKey_L0adSingleS0und_Pages0_1           ; FF4105  [ 47]
	.long DispatchMatrix_NoAction                                 ; FF4109  [ 48]
	.long SoftKeyCol1_L0adSingle_AllPages                                 ; FF410D  [ 49]
	.long SoftKeyCol2_L0adSingleS0und_Page1                                 ; FF4111  [ 50]
	.long SoftKeyCols3_4_L0adSingle_Page1                                 ; FF4115  [ 51]
	.long SoftKeyCols3_4_L0adSingle_Page1                                 ; FF4119  [ 52]
	.long SoftKeyCols5_6_L0adSingleS0und_Page1                                 ; FF411D  [ 53]
	.long SoftKeyCols5_6_L0adSingleS0und_Page1                                 ; FF4121  [ 54]
	.long SoftKeyCols7_8_L0adSingle_Page1                                 ; FF4125  [ 55]
	.long SoftKeyCols7_8_L0adSingle_Page1                                 ; FF4129  [ 56]
	.long DispatchMatrix_NoAction                                 ; FF412D  [ 57]
	.long DispatchMatrix_NoAction                                 ; FF4131  [ 58]
	.long DispatchMatrix_NoAction                                 ; FF4135  [ 59]
	.long DispatchMatrix_NoAction                                 ; FF4139  [ 60]
	.long DispatchMatrix_NoAction                                 ; FF413D  [ 61]
	.long DispatchMatrix_NoAction                                 ; FF4141  [ 62]
	.long DispatchMatrix_NoAction                                 ; FF4145  [ 63]
; ---------------------------------------------------------------------
; ScreenEnterPages_L0adSingleC0mbination -- TWO handler pointers, indexed by the page byte (0x2229)
; Read by: 0xFF6DB7.  ENTRY COUNT 2, from `cp (0x2229),0x02 / jr NC`.
; ---------------------------------------------------------------------
; ScreenEnterPages_L0adSingleC0mbination: PageDispatch_L0adSingleC0mbination's per-page ENTER table, indexed by UI_ScreenPage (0..1)
;   (notes/prom_a_page_enter_names.py).
ScreenEnterPages_L0adSingleC0mbination:
	.long ScreenEnter_L0adSingleC0mbination_Page0                                 ; FF4149  [  0]
	.long ScreenEnter_L0adSingleC0mbination_Page1                                 ; FF414D  [  1]
; ---------------------------------------------------------------------
; Dispatch_FF4151 -- a 2 x 32 handler matrix.  Read by 0xFF6F21, and the entry
; count rests on the same two things as Dispatch_FF4049's: the 256-byte extent
; to the next reader-named base, and the bound of 2 that its sibling
; ScreenEnterPages_L0adSingleC0mbination carries on the same page byte.
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; ★ CONTROL LEGEND, added 2026-08-31. The header above ends "⚠ Not one entry
;          is tied to a legend." This table's are, now -- with a map this
;          lane did not invent.
;
; The index is the 5-bit PANEL EVENT CODE PanelButton_Route produces (`and
;          L,0x1f`, 0xF861AE). ROUNDS 9-12 established what each code is, and
;          named 131 handlers in prom_b for these same codes (SoftKeyColN /
;          LcdKeyRowN / ExitKey); the tables in THIS module were never tied
;          to it. notes/prom_a_panel_control_map.py re-derives the map from
;          the ROM by an independent route -- the wire->group map at 0xF8A189
;          and the group event lists at 0xF8B4B2, composed with the service
;          manual's switch matrix -- and AGREES with prom_b's SLOT_CONTROL
;          slot for slot. Its corroborations all pass -- run --checks; a
;          count is not quoted here because a hand-copied count rots.
;          Write-up: notes/FINDINGS-prom_a-panel-control-map.md.
;
;   [00]..[07]  SOFT KEY columns 1..8; a column's lower and upper
;               key share a code
;   [08]..[0C]  the five LCD-row buttons, top to bottom; a row's
;               left-hand and right-hand key share a code
;   [0D]        the -1 / +1 pair          [0F]  EXIT
;   [0E]        nothing on this panel raises it
;   [10]        the PAGE v / PAGE ^ pair  [1E]  COMPARE
;   [1B]        the number pad, whole field
;   [20]        mode/menu select -- OUT OF RANGE for a 32-entry
;               table; PanelEvent_Code20_SetScreen takes it instead
;
; LIVE in this table: [00], [02], [03], [05], [06], [07], [08], [0F], [11],
;          [13], [14], [16], [17], [18].
; Everything else is this module's do-nothing default.
; ⚠ A live index names the CONTROL, not the FUNCTION.
; ---------------------------------------------------------------------
Dispatch_FF4151:
	.long SoftKeyCol1_L0adSingle_AllPages                                 ; FF4151  [  0]
	.long DispatchMatrix_NoAction                                 ; FF4155  [  1]
	.long SoftKeyCols3_4_L0adSingleC0mbination_Page0                                 ; FF4159  [  2]
	.long SoftKeyCols3_4_L0adSingleC0mbination_Page0                                 ; FF415D  [  3]
	.long DispatchMatrix_NoAction                                 ; FF4161  [  4]
	.long SoftKeyCol6_L0adSingle_Page0                                 ; FF4165  [  5]
	.long SoftKeyCols7_8_L0adSingleC0mbination_Page0                                 ; FF4169  [  6]
	.long SoftKeyCols7_8_L0adSingleC0mbination_Page0                                 ; FF416D  [  7]
	.long LcdKeyRow1_L0adSingleC0mbination_Page0     ; FF4171  [  8]
	.long DispatchMatrix_NoAction                                 ; FF4175  [  9]
	.long DispatchMatrix_NoAction                                 ; FF4179  [ 10]
	.long DispatchMatrix_NoAction                                 ; FF417D  [ 11]
	.long DispatchMatrix_NoAction                                 ; FF4181  [ 12]
	.long DispatchMatrix_NoAction                                 ; FF4185  [ 13]
	.long DispatchMatrix_NoAction                                 ; FF4189  [ 14]
	.long ExitKey_L0adSingleC0mbination_Pages0_1     ; FF418D  [ 15]
	.long DispatchMatrix_NoAction                                 ; FF4191  [ 16]
	.long SoftKeyCol1_L0adSingle_AllPages                                 ; FF4195  [ 17]
	.long DispatchMatrix_NoAction                                 ; FF4199  [ 18]
	.long SoftKeyCols3_4_L0adSingleC0mbination_Page0                                 ; FF419D  [ 19]
	.long SoftKeyCols3_4_L0adSingleC0mbination_Page0                                 ; FF41A1  [ 20]
	.long DispatchMatrix_NoAction                                 ; FF41A5  [ 21]
	.long SoftKeyCol6_L0adSingle_Page0                                 ; FF41A9  [ 22]
	.long SoftKeyCols7_8_L0adSingleC0mbination_Page0                                 ; FF41AD  [ 23]
	.long SoftKeyCols7_8_L0adSingleC0mbination_Page0                                 ; FF41B1  [ 24]
	.long DispatchMatrix_NoAction                                 ; FF41B5  [ 25]
	.long DispatchMatrix_NoAction                                 ; FF41B9  [ 26]
	.long DispatchMatrix_NoAction                                 ; FF41BD  [ 27]
	.long DispatchMatrix_NoAction                                 ; FF41C1  [ 28]
	.long DispatchMatrix_NoAction                                 ; FF41C5  [ 29]
	.long DispatchMatrix_NoAction                                 ; FF41C9  [ 30]
	.long DispatchMatrix_NoAction                                 ; FF41CD  [ 31]
	.long SoftKeyCol1_L0adSingle_AllPages                                 ; FF41D1  [ 32]
	.long DispatchMatrix_NoAction                                 ; FF41D5  [ 33]
	.long SoftKeyCols3_4_L0adSingle_Page1                                 ; FF41D9  [ 34]
	.long SoftKeyCols3_4_L0adSingle_Page1                                 ; FF41DD  [ 35]
	.long DispatchMatrix_NoAction                                 ; FF41E1  [ 36]
	.long DispatchMatrix_NoAction                                 ; FF41E5  [ 37]
	.long SoftKeyCols7_8_L0adSingle_Page1                                 ; FF41E9  [ 38]
	.long SoftKeyCols7_8_L0adSingle_Page1                                 ; FF41ED  [ 39]
	.long LcdKeyRow1_L0adSingleC0mbination_Page1     ; FF41F1  [ 40]
	.long DispatchMatrix_NoAction                                 ; FF41F5  [ 41]
	.long DispatchMatrix_NoAction                                 ; FF41F9  [ 42]
	.long DispatchMatrix_NoAction                                 ; FF41FD  [ 43]
	.long DispatchMatrix_NoAction                                 ; FF4201  [ 44]
	.long DispatchMatrix_NoAction                                 ; FF4205  [ 45]
	.long DispatchMatrix_NoAction                                 ; FF4209  [ 46]
	.long ExitKey_L0adSingleC0mbination_Pages0_1     ; FF420D  [ 47]
	.long DispatchMatrix_NoAction                                 ; FF4211  [ 48]
	.long SoftKeyCol1_L0adSingle_AllPages                                 ; FF4215  [ 49]
	.long DispatchMatrix_NoAction                                 ; FF4219  [ 50]
	.long SoftKeyCols3_4_L0adSingle_Page1                                 ; FF421D  [ 51]
	.long SoftKeyCols3_4_L0adSingle_Page1                                 ; FF4221  [ 52]
	.long DispatchMatrix_NoAction                                 ; FF4225  [ 53]
	.long DispatchMatrix_NoAction                                 ; FF4229  [ 54]
	.long SoftKeyCols7_8_L0adSingle_Page1                                 ; FF422D  [ 55]
	.long SoftKeyCols7_8_L0adSingle_Page1                                 ; FF4231  [ 56]
	.long DispatchMatrix_NoAction                                 ; FF4235  [ 57]
	.long DispatchMatrix_NoAction                                 ; FF4239  [ 58]
	.long DispatchMatrix_NoAction                                 ; FF423D  [ 59]
	.long DispatchMatrix_NoAction                                 ; FF4241  [ 60]
	.long DispatchMatrix_NoAction                                 ; FF4245  [ 61]
	.long DispatchMatrix_NoAction                                 ; FF4249  [ 62]
	.long DispatchMatrix_NoAction                                 ; FF424D  [ 63]
; ---------------------------------------------------------------------
; PtrTable_FF4251 -- SIXTEEN 32-bit RAM addresses
;
;   0x000076AF 0x000076EF 0x0000772F 0x0000776F 0x000077AF 0x000077EF
;   0x0000782F 0x0000786F 0x000078EF 0x0000792F 0x0000796F 0x000079AF
;   0x000079EF 0x00007A2F 0x00007A6F 0x00007AAF
;
; These are RAM pointers, not code: the whole run is below 0x8000 and the step
; is 0x40 between neighbours -- except between entries 7 and 8, where it is
; 0x80.  Sixteen records of 64 bytes with one 64-byte hole.
; Read by: 0xFF70B6 and 0xFF70E2, both `lda_24 xix,(0xFF4251) / ld XBC,(XIX)`
;          walking forward.
; ENTRY COUNT 16, from the reader's own bound: 0xFF70B6 walks the table with
;          `inc 4,XIX / inc 1,HL / cp HL,0x0010 / jr LT` at 0xFF70CB-0xFF70D3,
;          and 16 x 4 = 64 bytes ends exactly at the text field 0xFF4291.
; ★ WHAT THE READER DOES also says what the pointers point AT: it loads the
;          BYTE at each pointer and stores it at RAM 0x26B2 + i, i = 0..15 --
;          so this is sixteen scattered one-byte variables mirrored into a
;          16-byte shadow.  Its sibling 0xFF70E2 walks the same table and
;          compares each byte against the same shadow, writing back on a
;          difference: a change detector.
; Unknown:  what the sixteen variables are.
; ---------------------------------------------------------------------
PtrTable_FF4251:
	.long 0x000076af                                 ; FF4251  [  0]
	.long 0x000076ef                                 ; FF4255  [  1]
	.long 0x0000772f                                 ; FF4259  [  2]
	.long 0x0000776f                                 ; FF425D  [  3]
	.long 0x000077af                                 ; FF4261  [  4]
	.long 0x000077ef                                 ; FF4265  [  5]
	.long 0x0000782f                                 ; FF4269  [  6]
	.long 0x0000786f                                 ; FF426D  [  7]
	.long 0x000078ef                                 ; FF4271  [  8]
	.long 0x0000792f                                 ; FF4275  [  9]
	.long 0x0000796f                                 ; FF4279  [ 10]
	.long 0x000079af                                 ; FF427D  [ 11]
	.long 0x000079ef                                 ; FF4281  [ 12]
	.long 0x00007a2f                                 ; FF4285  [ 13]
	.long 0x00007a6f                                 ; FF4289  [ 14]
	.long 0x00007aaf                                 ; FF428D  [ 15]
; ---------------------------------------------------------------------
; Text_FF4291 -- 16 spaces
;
; Passed by `lda_24` at 0xFF71A5, 0xFF72D9 and 0xFF73DC, in each case pushed
; with the two literals 0x10 and 0x06 -- a 16-character blank field.
; ---------------------------------------------------------------------
Text_FF4291:
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; FF4291
; ---------------------------------------------------------------------
; Text_UserBankAbbrevs -- FOUR four-character labels: "U1 -" "U2 -" "UD1-" "UD2-"
;
; Read by: 0xFF744E, `ld C,4 / mul (0x2728),3 / extz XBC / add XBC,0x00FF42A1 /
;          push XBC` -- stride 4, indexed by (0x2728).  Four labels fill the 16
;          bytes to 0xFF42B1, where the module's code begins.
; ⚠ WHAT "U1" AND "UD1" STAND FOR IS NOT ESTABLISHED.  They are four literal
;          strings and the tree's rule is not to invent an expansion.
;
; ★ AND THE VERY NEXT BYTE, 0xFF42B1, IS THE TABLES' DEFAULT HANDLER: a bare
;   `ret`, named by 459 of the 654 slots above.  It gets no label of its own
;   because this generator labels only call/jp/calr targets and every one of
;   those 459 references is a 32-bit POINTER, not an instruction -- so the
;   handler that runs most often in this module is the one line in it with no
;   name.  Recorded here rather than left to be rediscovered.
; ---------------------------------------------------------------------
; RESOLVED 2026-10-04: U1 / U2 / UD1 / UD2 are USER 1 / USER 2 / USER1 DRUM / USER2 DRUM.  prom_b DLText_F59128 holds those
;   long forms in the same order, and DL_F590F1's first record reads them by the same index (0x2728).  Read by
;   L0adSingle_DrawBankAndNumber.
Text_UserBankAbbrevs:
	.byte 0x55, 0x31, 0x20, 0x2d, 0x55, 0x32, 0x20, 0x2d, 0x55, 0x44, 0x31, 0x2d, 0x55, 0x44, 0x32, 0x2d  ; FF42A1
; DispatchMatrix_NoAction: the bare `ret` that 459 of the 654 slots of this module's dispatch tables name -- a
;   control with nothing to do on that page (FINDINGS-prom_a-dispatch-matrix-and-drum-names.md section 1).
DispatchMatrix_NoAction:
	ret                                                  ; FF42B1  0e
CallbackQueue_ResetAndRestartTask2_Call:
	call T_CallbackQueue_ResetAndRestartTask2            ; FF42B2  1d 80 2e f4
	ret                                                  ; FF42B6  0e
; ModeEnter_SoundCopy: the +0 ENTER of panel mode 14 (T_ModeEnter_SoundCopy); PanelMode_ToScreenIdMap[14] = 0x5E, Screen_SoundCopy.
ModeEnter_SoundCopy:
	set	1, (0x2134:16)                               ; FF42B7  f1 34 21 b9
	call T_SoundGroup_ReloadSelection                                        ; FF42BB  1d c8 15 f4
	ret                                                  ; FF42BF  0e
; Var2134_SetBit1_3: m_set 1, MD16, 0x2134 (single-cell template; the cell's meaning is not established unless it is named)
Var2134_SetBit1_3:
	set	1, (0x2134:16)                               ; FF42C0  f1 34 21 b9
	ret                                                  ; FF42C4  0e
; ModeEnter_SoundCopy_Call: calls ModeEnter_SoundCopy and returns (notes/prom_ab_wrapper_names.py; DERIVATIVE)
ModeEnter_SoundCopy_Call:
	calr ModeEnter_SoundCopy                                      ; FF42C5  1e ef ff
	ret                                                  ; FF42C8  0e
; Var2134_SetBit1_3_Call: calls Var2134_SetBit1_3 and returns -- `calr Var2134_SetBit1_3 / ret`.
Var2134_SetBit1_3_Call:
	calr Var2134_SetBit1_3                                      ; FF42C9  1e f4 ff
	ret                                                  ; FF42CC  0e
; ---------------------------------------------------------------------
; Paint_DiskMenu -- the ENTER method (painter) of the screen object at
;          PanelScreen_VtableTable entry 0x60, i.e. SCREEN ID 0x40 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x60, +0 slot, called by
;          PanelScreen_CallEnter_A/B with the id that has just become
;          current.
; Evidence: round 7 identified 0xFF42CD as "the DISK menu's INDEX" and
;          refused to name it after a CAPTION (its header below); wave8's
;          SCREEN_DECLARED then declared screen 0x60 = DiskMenu. This names
;          it after the MENU, which both point at: it hands the interpreter
;          the lists at 0xF58014 ("DISK"), 0xF580B0 ("MIDI FILE LOAD") and
;          0xF58127 ("LOAD"), choosing on the model strap (0xC4) at 0xFF42EE
;          -- the site this module's banner already calls the disk menu.
;          wave8 named the screen's READER (PanelButtonDispatch_DiskMenu)
;          from this same object.
; See notes/FINDINGS-prom_a-panel-control-map.md and wave8's SCREEN_DECLARED.
;          This name is the MENU, not a caption, so it does not fall to round
;          7's refusal below -- it is what that refusal pointed at.
; Was `sub_FF42CD`.
;
; ★ THIS ANSWERS THE HEADER BELOW, kept verbatim. Its refusal was of a
;          CAPTION name ("naming it after one would claim a screen another
;          routine paints") and it was right; this names the MENU the header
;          itself identifies, which no caption does. Its opening line now
;          carries the new label because the rename is file-wide; every other
;          word, refusal included, is the record of how the gap closed.
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; Paint_DiskMenu -- a screen painter this round REFUSED to name.
; ^ SUPERSEDED: this auto-generated refusal line predates the naming of
;   Paint_DiskMenu (0xFF42CD); it is NOT refused. See the ENTER-method
;   header above and the Screen: line below for its real identity.
;
; It hands 3 display list(s) to the interpreter ON THE STACK.
;     site 0xFF42D7  list 0xF58014-0xF580B0 (156 B, leaves by call)
;        text: "DISK"; "DISK L0AD"; "DISK SAVE"; "MIDI FILE"; "DIRECT PLAY"; ...
;     site 0xFF42F4  list 0xF580B0-0xF58127 (119 B, leaves by jr)
;        text: "MIDI FILE LOAD"; "MIDI FILE SAVE"; "LOAD"; "SINGLE SOUND"; "LOAD"; ...
;     site 0xFF4302  list 0xF58127-0xF58162 (59 B, leaves by call)
;        text: "LOAD"; "SINGLE SOUND"; "LOAD"; "SINGLE COMBI.#"
; Evidence: the two 24-bit immediates of the 12-byte push idiom at
;          the cited site; the record walk from <start> lands exactly
;          on <end>; the text is the `.ascii` the interpreter draws.
; NOT NAMED because its list is the DISK menu's INDEX of seven captions
;          (DISK L0AD, DISK SAVE, MIDI FILE DIRECT PLAY, FL0PPY DISK
;          F0RMAT); naming it after one would claim a screen another
;          routine paints.
;          A wrong name passes the byte gate forever, so this keeps
;          sub_XXXXXX and states the gap.
; Recorded by notes/prom_a_understanding_round7.py --apply.
; ---------------------------------------------------------------------
Paint_DiskMenu:
	calr CallbackQueue_ResetAndRestartTask2_Call                                      ; FF42CD  1e e2 ff
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF42D0  1d 04 76 ff
	pushw 0x00                                           ; FF42D4  0b 00 00
	lda xbc, (DL_MidiFileLoadMidiFileSave:24)            ; FF42D7  f2 b0 80 f5 31
	push XBC                                             ; FF42DC  39
	lda xwa, (DL_DiskDiskL0adDiskSaveMidiFile:24)        ; FF42DD  f2 14 80 f5 30
	push XWA                                             ; FF42E2  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF42E3  1d d3 75 ff
	inc 8,XSP                                            ; FF42E7  ef 60
	inc 2,XSP                                            ; FF42E9  ef 62
	pushw 0x00                                           ; FF42EB  0b 00 00
	cp	(Variant_Flag:8), 0x01                               ; FF42EE  c0 c4 3f 01
	jr nz, .LFF4302                                      ; FF42F2  6e 0e
	lda xbc, (DL_LoadSingleSoundLoadSingleCombi:24)      ; FF42F4  f2 27 81 f5 31
	push XBC                                             ; FF42F9  39
	lda xwa, (DL_MidiFileLoadMidiFileSave:24)            ; FF42FA  f2 b0 80 f5 30
	push XWA                                             ; FF42FF  38
	jr .LFF430E                                          ; FF4300  68 0c
.LFF4302:
	lda xbc, (DL_F58162:24)                              ; FF4302  f2 62 81 f5 31
	push XBC                                             ; FF4307  39
	lda xwa, (DL_LoadSingleSoundLoadSingleCombi:24)      ; FF4308  f2 27 81 f5 30
	push XWA                                             ; FF430D  38
.LFF430E:
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF430E  1d d3 75 ff
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF4312  1d 15 76 ff
	inc 8,XSP                                            ; FF4316  ef 60
	inc 2,XSP                                            ; FF4318  ef 62
	ret                                                  ; FF431A  0e
; ---------------------------------------------------------------------
; ScreenLeave_DiskMenu -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0x60, i.e. SCREEN ID 0x40 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x60 -> the screen object at
;          0xF42264, whose +4 slot is `jp 0xFF431B`, and from no other live
;          screen object's two callable slots.
; Evidence: the +4 offset is PanelScreen_VtableTable's own (its header's
;          checks V1-V6): +0 ENTER is called by PanelScreen_CallEnter_A/B, +4
;          LEAVE by PanelScreen_CallLeave_A/B with the id that just STOPPED
;          being current, +8 BUTTON by PanelButton_Route (0xF8621E).
; Screen:   DiskMenu -- inherited from the +0 ENTER label Paint_DiskMenu, not
;          from any text this pass read.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing on
;          leave; the slot exists to keep the three-method shape.
; Was `sub_FF431B`.
; ---------------------------------------------------------------------
ScreenLeave_DiskMenu:
	ret                                                  ; FF431B  0e
; ---------------------------------------------------------------------
; PanelButtonDispatch_DiskMenu -- run Dispatch_FF3800's handler for one PANEL
;          CONTROL
;
; Inputs:   (XIZ+0x08) = the 5-bit panel control index; (XIZ+0x0A) =
;          the argument this reader forwards to the handler.
; Evidence: `cp H,0x20` at 0xFF4324 bounds the index to the 32-code
;          panel space PanelButton_Route's `and L,0x1f`
;          (0xF861AE) produces, and `add XBC,0x00FF3800` at 0xFF4332
;          names the table.
;          The handler is CALLED, not jumped to: the reader pushes
;          a return address before `jp (XBC)`.
; Control legend: notes/FINDINGS-prom_a-panel-control-map.md, and
;          `python3 notes/prom_a_panel_control_map.py --map`.
; Screen:   DiskMenu -- the screen object at PanelScreen_VtableTable entry
;          0x60, i.e. SCREEN ID 0x40 through PanelScreen_VtableTable_ViewB
;          names this reader as its BUTTON method, and its Enter method
;          (0xFF42CD) hands the interpreter the lists at 0xF58014 ("DISK"),
;          0xF580B0 ("MIDI FILE LOAD") and 0xF58127 ("LOAD"), choosing
;          between the last two on the model strap (0xC4) at 0xFF42EE -- the
;          site this module's own banner already calls THE DISK MENU.
; Was `sub_FF431C`, named by notes/prom_a_naming_wave8_apply.py.
; ---------------------------------------------------------------------
PanelButtonDispatch_DiskMenu:
	link XIZ,0x0000                                      ; FF431C  ee 0c 00 00
	pushw hl                                             ; FF4320  2b
	ld H,(XIZ+0x08)                                      ; FF4321  8e 08 26
	cp H,0x20                                            ; FF4324  ce cf 20
	jr nc, .LFF4343                                      ; FF4327  6f 1a
	pushw	(xiz+10)                                     ; FF4329  9e 0a 04
	ld c, 0x04:opc                                          ; FF432C  23 04
	mul bc, h                                          ; FF432E  ce 43
	extz XBC                                             ; FF4330  e9 12
	add XBC,Dispatch_FF3800                              ; FF4332  e9 c8 00 38 ff 00
	ld XBC,(XBC)                                         ; FF4338  a1 21
	lda xiy, (.LFF4342:24)                               ; FF433A  f2 42 43 ff 35
	push XIY                                             ; FF433F  3d
	jp (xbc)                                             ; FF4340  b1 d8
.LFF4342:
	popw bc                                              ; FF4342  49
.LFF4343:
	popw hl                                              ; FF4343  4b
	unlk XIZ                                             ; FF4344  ee 0d
	ret                                                  ; FF4346  0e
; ---------------------------------------------------------------------
; LcdKeyRow1_DiskMenu -- what Dispatch_FF3800 runs for panel control 0x08
;
; Reached from: Dispatch_FF3800 entry [8] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x08 is the LCD row 1 button pair -- the left-hand and
;          right-hand buttons of the display's TOP row. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskMenu -- the screen object at PanelScreen_VtableTable entry
;          0x60, i.e. SCREEN ID 0x40 through PanelScreen_VtableTable_ViewB
;          names this reader as its BUTTON method, and its Enter method
;          (0xFF42CD) hands the interpreter the lists at 0xF58014 ("DISK"),
;          0xF580B0 ("MIDI FILE LOAD") and 0xF58127 ("LOAD"), choosing
;          between the last two on the model strap (0xC4) at 0xFF42EE -- the
;          site this module's own banner already calls THE DISK MENU.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow1_DiskMenu:
	link XIZ,0x0000                                      ; FF4347  ee 0c 00 00
	push XIX                                             ; FF434B  3c
	lda xix, (UI_Request:16)                                ; FF434C  f1 70 20 34
	ld BC,(XIZ+0x08)                                     ; FF4350  9e 08 21
	and BC,0x0080                                        ; FF4353  d9 cc 80 00
	jr z, .LFF435E                                       ; FF4357  66 05
	ld (XIX),0x47                                        ; FF4359  b4 00 47
	jr .LFF436A                                          ; FF435C  68 0c
.LFF435E:
	ld (XIX),0x54                                        ; FF435E  b4 00 54
	cp	(Variant_Flag:8), 0x01                               ; FF4361  c0 c4 3f 01
	jr nz, .LFF436A                                      ; FF4365  6e 03
	ld (XIX),0x49                                        ; FF4367  b4 00 49
.LFF436A:
	ld (UI_Request_Hi:16), 0x80                                 ; FF436A  f1 71 20 00 80
	pop XIX                                              ; FF436F  5c
	unlk XIZ                                             ; FF4370  ee 0d
	ret                                                  ; FF4372  0e
; ---------------------------------------------------------------------
; LcdKeyRow2_DiskMenu -- what Dispatch_FF3800 runs for panel control 0x09
;
; Reached from: Dispatch_FF3800 entry [9] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x09 is the LCD row 2 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskMenu -- the screen object at PanelScreen_VtableTable entry
;          0x60, i.e. SCREEN ID 0x40 through PanelScreen_VtableTable_ViewB
;          names this reader as its BUTTON method, and its Enter method
;          (0xFF42CD) hands the interpreter the lists at 0xF58014 ("DISK"),
;          0xF580B0 ("MIDI FILE LOAD") and 0xF58127 ("LOAD"), choosing
;          between the last two on the model strap (0xC4) at 0xFF42EE -- the
;          site this module's own banner already calls THE DISK MENU.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow2_DiskMenu:
	link XIZ,0x0000                                      ; FF4373  ee 0c 00 00
	push XIX                                             ; FF4377  3c
	lda xix, (UI_Request:16)                                ; FF4378  f1 70 20 34
	ld BC,(XIZ+0x08)                                     ; FF437C  9e 08 21
	and BC,0x0080                                        ; FF437F  d9 cc 80 00
	jr z, .LFF438A                                       ; FF4383  66 05
	ld (XIX),0x4c                                        ; FF4385  b4 00 4c
	jr .LFF4396                                          ; FF4388  68 0c
.LFF438A:
	ld (XIX),0x53                                        ; FF438A  b4 00 53
	cp	(Variant_Flag:8), 0x01                               ; FF438D  c0 c4 3f 01
	jr nz, .LFF4396                                      ; FF4391  6e 03
	ld (XIX),0x4e                                        ; FF4393  b4 00 4e
.LFF4396:
	ld (UI_Request_Hi:16), 0x80                                 ; FF4396  f1 71 20 00 80
	pop XIX                                              ; FF439B  5c
	unlk XIZ                                             ; FF439C  ee 0d
	ret                                                  ; FF439E  0e
; ---------------------------------------------------------------------
; LcdKeyRow3_DiskMenu -- what Dispatch_FF3800 runs for panel control 0x0A
;
; Reached from: Dispatch_FF3800 entry [10] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0A is the LCD row 3 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskMenu -- the screen object at PanelScreen_VtableTable entry
;          0x60, i.e. SCREEN ID 0x40 through PanelScreen_VtableTable_ViewB
;          names this reader as its BUTTON method, and its Enter method
;          (0xFF42CD) hands the interpreter the lists at 0xF58014 ("DISK"),
;          0xF580B0 ("MIDI FILE LOAD") and 0xF58127 ("LOAD"), choosing
;          between the last two on the model strap (0xC4) at 0xFF42EE -- the
;          site this module's own banner already calls THE DISK MENU.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow3_DiskMenu:
	link XIZ,0x0000                                      ; FF439F  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF43A3  9e 08 21
	and BC,0x0080                                        ; FF43A6  d9 cc 80 00
	jr z, .LFF43B3                                       ; FF43AA  66 07
	ld (UI_Request:16), 0x45                                 ; FF43AC  f1 70 20 00 45
	jr .LFF43BE                                          ; FF43B1  68 0b
.LFF43B3:
	cp	(Variant_Flag:8), 0x01                               ; FF43B3  c0 c4 3f 01
	jr nz, .LFF43C3                                      ; FF43B7  6e 0a
	ld (UI_Request:16), 0x54                                 ; FF43B9  f1 70 20 00 54
.LFF43BE:
	ld (UI_Request_Hi:16), 0x80                                 ; FF43BE  f1 71 20 00 80
.LFF43C3:
	unlk XIZ                                             ; FF43C3  ee 0d
	ret                                                  ; FF43C5  0e
; ---------------------------------------------------------------------
; LcdKeyRow4_DiskMenu -- what Dispatch_FF3800 runs for panel control 0x0B
;
; Reached from: Dispatch_FF3800 entry [11] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0B is the LCD row 4 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskMenu -- the screen object at PanelScreen_VtableTable entry
;          0x60, i.e. SCREEN ID 0x40 through PanelScreen_VtableTable_ViewB
;          names this reader as its BUTTON method, and its Enter method
;          (0xFF42CD) hands the interpreter the lists at 0xF58014 ("DISK"),
;          0xF580B0 ("MIDI FILE LOAD") and 0xF58127 ("LOAD"), choosing
;          between the last two on the model strap (0xC4) at 0xFF42EE -- the
;          site this module's own banner already calls THE DISK MENU.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow4_DiskMenu:
	link XIZ,0x0000                                      ; FF43C6  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF43CA  9e 08 21
	and BC,0x0080                                        ; FF43CD  d9 cc 80 00
	jr z, .LFF43DA                                       ; FF43D1  66 07
	ld (UI_Request:16), 0x50                                 ; FF43D3  f1 70 20 00 50
	jr .LFF43E5                                          ; FF43D8  68 0b
.LFF43DA:
	cp	(Variant_Flag:8), 0x01                               ; FF43DA  c0 c4 3f 01
	jr nz, .LFF43EA                                      ; FF43DE  6e 0a
	ld (UI_Request:16), 0x53                                 ; FF43E0  f1 70 20 00 53
.LFF43E5:
	ld (UI_Request_Hi:16), 0x80                                 ; FF43E5  f1 71 20 00 80
.LFF43EA:
	unlk XIZ                                             ; FF43EA  ee 0d
	ret                                                  ; FF43EC  0e
; ---------------------------------------------------------------------
; ExitKey_DiskMenu -- what Dispatch_FF3800 runs for panel control 0x0F
;
; Reached from: Dispatch_FF3800 entry [15] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0F is the EXIT key. The pair position -- which of the two
;          keys -- reaches the handler in the argument the reader forwards;
;          this pass did NOT establish that argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskMenu -- the screen object at PanelScreen_VtableTable entry
;          0x60, i.e. SCREEN ID 0x40 through PanelScreen_VtableTable_ViewB
;          names this reader as its BUTTON method, and its Enter method
;          (0xFF42CD) hands the interpreter the lists at 0xF58014 ("DISK"),
;          0xF580B0 ("MIDI FILE LOAD") and 0xF58127 ("LOAD"), choosing
;          between the last two on the model strap (0xC4) at 0xFF42EE -- the
;          site this module's own banner already calls THE DISK MENU.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
ExitKey_DiskMenu:
	link XIZ,0x0000                                      ; FF43ED  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF43F1  9e 08 21
	and BC,0x0080                                        ; FF43F4  d9 cc 80 00
	jr nz, .LFF4404                                      ; FF43F8  6e 0a
	ld (UI_Request:16), 0x01                                 ; FF43FA  f1 70 20 00 01
	ld (UI_Request_Hi:16), 0x02                                 ; FF43FF  f1 71 20 00 02
.LFF4404:
	unlk XIZ                                             ; FF4404  ee 0d
	ret                                                  ; FF4406  0e
T_F42270_Nop:
	ret                                                  ; FF4407  0e
; ---------------------------------------------------------------------
; Paint_MidiFileDirectPlay -- paints the screen whose own text reads "MIDI FILE DIRECT PLAY"
;
; Called from: prom_b T_F42274 (`jp`)
;
; It hands 7 display list(s) to the interpreter ON THE STACK --
;          lda XBC,<end> / push XBC / lda XWA,<start> / push XWA,
;          then the stack veneer.  The lists, and the text each draws:
;     site 0xFF4473  list 0xF5950D-0xF59517 (10 B, leaves by jp(XIX))
;     site 0xFF448A  list 0xF5944C-0xF594F9 (173 B, leaves by jp(XIX))
;        text: "MIDI FILE DIRECT PLAY"; "PLAY AS GM   :"; "MIXER"
;     site 0xFF44A1  list 0xF5933B-0xF59340 (5 B, leaves by jp(XIX))
;     site 0xFF44B8  list 0xF58000-0xF58014 (20 B, leaves by jp(XIX))
;        text: "DISK"
;     site 0xFF44CF  list 0xF594F9-0xF59503 (10 B, leaves by jp(XIX))
;        text: "PLAY"
;     site 0xFF4550  list 0xF59503-0xF5950D (10 B, leaves by jr)
;        text: "STOP"
;     site 0xFF455E  list 0xF594F9-0xF59503 (10 B, leaves by jp(XIX))
;        text: "PLAY"
; From the captions: "MIDI FILE DIRECT PLAY"; "PLAY AS GM :"
; Evidence: the list bounds are the two 24-bit IMMEDIATES of the
;          12-byte push idiom at the cited site, and the record
;          length bytes walked from <start> land EXACTLY on <end>
;          (368 of 368 in both images do -- notes/prom_a_dl_stack_map.py).
;          The quoted text is the `.ascii` the interpreter draws
;          verbatim.  Every morpheme of this name occurs in it;
;          notes/prom_a_understanding_round7.py --morphemes checks that.
;          `Paint_` is a structural verb, not ROM text.
; Unknown: whether this routine also handles input for the screen,
;          and whether another routine paints it too.  Neither was
;          searched.  ⚠ The register-form scan of rounds 5 and 6 does
;          not see this call shape at all, which is why this routine
;          was sub_XXXXXX until round 7.
; Named by notes/prom_a_understanding_round7.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_MidiFileDirectPlay:
	push XIX                                             ; FF4408  3c
	lda xix, (DisplayList_RunOnLayer_SaveRegs:24)                             ; FF4409  f2 d3 75 ff 34
	call T_CallbackQueue_ResetAndRestartTask2            ; FF440E  1d 80 2e f4
	ld c, (UI_ScreenLatch:16)                                   ; FF4412  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FF4416  c1 7b 20 f3
	jr z, .LFF4463                                       ; FF441A  66 47
	call Mode_SwitchToSound_SaveRegs2                                      ; FF441C  1d db 79 ff
	call MidiFileDirectPlay_SaveTrackToPartMap                                      ; FF4420  1d 3f 79 ff
	calr MidiFilePlay_SnapshotRecordBytes                                      ; FF4424  1e 8f 2c
	res	4, (UI_ScreenFlags:16)                               ; FF4427  f1 95 20 b4
	call T_MidiFileDirectPlay_InitOnEntry                                        ; FF442B  1d 58 09 f4
	call T_Transport_StopAllRunning                                        ; FF442F  1d ac 09 f4
	call T_Disk_MountAndScanMidiFilesResetRings                                        ; FF4433  1d 14 26 f4
	calr UI_StatusCode_Is0or2or4                                      ; FF4437  1e 62 31
	cp wa, 0x00:i3                                         ; FF443A  d8 d8
	jr z, .LFF444B                                       ; FF443C  66 0d
	ld (UI_Request:16), 0x40                                 ; FF443E  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF4443  f1 71 20 00 80
	jrl .LFF457A                                         ; FF4448  78 2f 01
.LFF444B:
	set	6, (0x2094:16)                               ; FF444B  f1 94 20 be
	ld (Disk_SelectedEntry:16), 0x00                                 ; FF444F  f1 24 27 00 00
	ld (0x272d:16), 0x00                                 ; FF4454  f1 2d 27 00 00
	ld (0x272e:16), 0x00                                 ; FF4459  f1 2e 27 00 00
	ld (0x2730:16), 0x00                                 ; FF445E  f1 30 27 00 00
.LFF4463:
	pushw 0x0b                                           ; FF4463  0b 0b 00
	pushw 0x0c                                           ; FF4466  0b 0c 00
	calr PanelDial_SetButtonPair                                      ; FF4469  1e be 2c
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF446C  1d 04 76 ff
	pushw 0x02                                           ; FF4470  0b 02 00
	lda xbc, (DL_F59517:24)                              ; FF4473  f2 17 95 f5 31
	push XBC                                             ; FF4478  39
	lda xwa, (Paint_MidiFileDirectPlay_DL:24)                              ; FF4479  f2 0d 95 f5 30
	push XWA                                             ; FF447E  38
	lda xiy, (.LFF4487:24)                               ; FF447F  f2 87 44 ff 35
	push XIY                                             ; FF4484  3d
	jp (xix)                                             ; FF4485  b4 d8
.LFF4487:
	pushw 0x00                                           ; FF4487  0b 00 00
	lda xbc, (DL_Play:24)                                ; FF448A  f2 f9 94 f5 31
	push XBC                                             ; FF448F  39
	lda xwa, (DL_MidiFileDirectPlayPlayAsGm:24)          ; FF4490  f2 4c 94 f5 30
	push XWA                                             ; FF4495  38
	lda xiy, (.LFF449E:24)                               ; FF4496  f2 9e 44 ff 35
	push XIY                                             ; FF449B  3d
	jp (xix)                                             ; FF449C  b4 d8
.LFF449E:
	pushw 0x00                                           ; FF449E  0b 00 00
	lda xbc, (0xf59340:24)                               ; FF44A1  f2 40 93 f5 31
	push XBC                                             ; FF44A6  39
	lda xwa, (DL_ToS0ngNumberL0adAsGm:24)                ; FF44A7  f2 3b 93 f5 30
	push XWA                                             ; FF44AC  38
	lda xiy, (.LFF44B5:24)                               ; FF44AD  f2 b5 44 ff 35
	push XIY                                             ; FF44B2  3d
	jp (xix)                                             ; FF44B3  b4 d8
.LFF44B5:
	pushw 0x00                                           ; FF44B5  0b 00 00
	lda xbc, (DL_DiskDiskL0adDiskSaveMidiFile:24)        ; FF44B8  f2 14 80 f5 31
	push XBC                                             ; FF44BD  39
	lda xwa, (DL_Disk:24)                                ; FF44BE  f2 00 80 f5 30
	push XWA                                             ; FF44C3  38
	lda xiy, (.LFF44CC:24)                               ; FF44C4  f2 cc 44 ff 35
	push XIY                                             ; FF44C9  3d
	jp (xix)                                             ; FF44CA  b4 d8
.LFF44CC:
	pushw 0x02                                           ; FF44CC  0b 02 00
	lda xbc, (DL_Stop:24)                                ; FF44CF  f2 03 95 f5 31
	push XBC                                             ; FF44D4  39
	lda xwa, (DL_Play:24)                                ; FF44D5  f2 f9 94 f5 30
	push XWA                                             ; FF44DA  38
	lda xiy, (.LFF44E3:24)                               ; FF44DB  f2 e3 44 ff 35
	push XIY                                             ; FF44E0  3d
	jp (xix)                                             ; FF44E1  b4 d8
.LFF44E3:
	calr MidiFile_CountFileList                                      ; FF44E3  1e 02 0c
	pushw 0x05                                           ; FF44E6  0b 05 00
	pushw 0x0a                                           ; FF44E9  0b 0a 00
	calr MidiFile_DrawFileList                                      ; FF44EC  1e 29 0c
	lda xbc, (DL_F59567:24)                              ; FF44EF  f2 67 95 f5 31
	push XBC                                             ; FF44F4  39
	call DLB_Array8_SaveRegs                                      ; FF44F5  1d 3f 76 ff
	add XSP,0x0000003e                                   ; FF44F9  ef c8 3e 00 00 00
	cp	(0x2730:16), 0x00                            ; FF44FF  c1 30 27 3f 00
	jr nz, .LFF4512                                      ; FF4504  6e 0c
	lda xbc, (DL_F59522:24)                              ; FF4506  f2 22 95 f5 31
	push XBC                                             ; FF450B  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF450C  1d 23 76 ff
	jr .LFF451C                                          ; FF4510  68 0a
.LFF4512:
	lda xbc, (DL_F59517:24)                              ; FF4512  f2 17 95 f5 31
	push XBC                                             ; FF4517  39
	call DLB_Array8_SaveRegs                                      ; FF4518  1d 3f 76 ff
.LFF451C:
	pop XIY                                              ; FF451C  5d
	pushw 0x06                                           ; FF451D  0b 06 00
	pushw 0x03                                           ; FF4520  0b 03 00
	pushw 0x1e3d                                         ; FF4523  0b 3d 1e
	cp	(0x2732:16), 0xff                            ; FF4526  c1 32 27 3f ff
	jr nz, .LFF4535                                      ; FF452B  6e 08
	lda xbc, (0xf59538:24)                               ; FF452D  f2 38 95 f5 31
	push XBC                                             ; FF4532  39
	jr .LFF453B                                          ; FF4533  68 06
.LFF4535:
	lda xbc, (DLText_F59535:24)                          ; FF4535  f2 35 95 f5 31
	push XBC                                             ; FF453A  39
.LFF453B:
	call LCD_SwiTextCall_SaveRegs                                      ; FF453B  1d 95 78 ff
	inc 8,XSP                                            ; FF453F  ef 60
	inc 2,XSP                                            ; FF4541  ef 62
	pushw 0x02                                           ; FF4543  0b 02 00
	ld c, (0x60505e:24)                                 ; FF4546  c2 5e 50 60 23
	and C,0x02                                           ; FF454B  cb cc 02
	jr z, .LFF455E                                       ; FF454E  66 0e
	lda xbc, (Paint_MidiFileDirectPlay_DL:24)                              ; FF4550  f2 0d 95 f5 31
	push XBC                                             ; FF4555  39
	lda xwa, (DL_Stop:24)                                ; FF4556  f2 03 95 f5 30
	push XWA                                             ; FF455B  38
	jr .LFF456A                                          ; FF455C  68 0c
.LFF455E:
	lda xbc, (DL_Stop:24)                                ; FF455E  f2 03 95 f5 31
	push XBC                                             ; FF4563  39
	lda xwa, (DL_Play:24)                                ; FF4564  f2 f9 94 f5 30
	push XWA                                             ; FF4569  38
.LFF456A:
	lda xiy, (.LFF4572:24)                               ; FF456A  f2 72 45 ff 35
	push XIY                                             ; FF456F  3d
	jp (xix)                                             ; FF4570  b4 d8
.LFF4572:
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF4572  1d 15 76 ff
	inc 8,XSP                                            ; FF4576  ef 60
	inc 2,XSP                                            ; FF4578  ef 62
.LFF457A:
	pop XIX                                              ; FF457A  5c
	ret                                                  ; FF457B  0e
; ---------------------------------------------------------------------
; ScreenLeave_MidiFileDirectPlay -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0x65, i.e. SCREEN ID 0x45 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x65 -> the screen object at
;          0xF42274, whose +4 slot is `jp 0xFF457C`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the LEAVE method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   MidiFileDirectPlay -- the same object's +0 ENTER method carries
;          the label Paint_MidiFileDirectPlay, a name an earlier round
;          derived from the screen's own text.
; Was `sub_FF457C`.
; ---------------------------------------------------------------------
ScreenLeave_MidiFileDirectPlay:
	ld c, (UI_ScreenLatch:16)                                   ; FF457C  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FF4580  c1 7b 20 f3
	jr z, .LFF4595                                       ; FF4584  66 0f
	call DiskFileScreen_LeaveCommon                                      ; FF4586  1d 8c 79 ff
	call T_MidiFileDirectPlay_RestoreOnLeave                                        ; FF458A  1d 5c 09 f4
	call MidiFileDirectPlay_RestoreTrackToPartMap                                      ; FF458E  1d 4c 79 ff
	calr PartRecords_RestoreShadowedField                                      ; FF4592  1e 43 2b
.LFF4595:
	ret                                                  ; FF4595  0e
; ---------------------------------------------------------------------
; PanelButtonDispatch_MidiFileDirectPlay -- run Dispatch_FF3880's handler for
;          one PANEL CONTROL
;
; Inputs:   (XIZ+0x08) = the 5-bit panel control index; (XIZ+0x0A) =
;          the argument this reader forwards to the handler.
; Evidence: `cp H,0x20` at 0xFF459E bounds the index to the 32-code
;          panel space PanelButton_Route's `and L,0x1f`
;          (0xF861AE) produces, and `add XBC,0x00FF3880` at 0xFF45AC
;          names the table.
;          The handler is CALLED, not jumped to: the reader pushes
;          a return address before `jp (XBC)`.
; Control legend: notes/FINDINGS-prom_a-panel-control-map.md, and
;          `python3 notes/prom_a_panel_control_map.py --map`.
; Screen:   MidiFileDirectPlay -- the screen object at
;          PanelScreen_VtableTable entry 0x65, i.e. SCREEN ID 0x45 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4408 as its ENTER method, and that address carries
;          the label Paint_MidiFileDirectPlay -- a name an earlier round
;          derived from the screen's own text.
; Was `sub_FF4596`, named by notes/prom_a_naming_wave8_apply.py.
; ---------------------------------------------------------------------
PanelButtonDispatch_MidiFileDirectPlay:
	link XIZ,0x0000                                      ; FF4596  ee 0c 00 00
	pushw hl                                             ; FF459A  2b
	ld H,(XIZ+0x08)                                      ; FF459B  8e 08 26
	cp H,0x20                                            ; FF459E  ce cf 20
	jr nc, .LFF45BD                                      ; FF45A1  6f 1a
	pushw	(xiz+10)                                     ; FF45A3  9e 0a 04
	ld c, 0x04:opc                                          ; FF45A6  23 04
	mul bc, h                                          ; FF45A8  ce 43
	extz XBC                                             ; FF45AA  e9 12
	add XBC,Dispatch_FF3880                              ; FF45AC  e9 c8 80 38 ff 00
	ld XBC,(XBC)                                         ; FF45B2  a1 21
	lda xiy, (.LFF45BC:24)                               ; FF45B4  f2 bc 45 ff 35
	push XIY                                             ; FF45B9  3d
	jp (xbc)                                             ; FF45BA  b1 d8
.LFF45BC:
	popw bc                                              ; FF45BC  49
.LFF45BD:
	popw hl                                              ; FF45BD  4b
	unlk XIZ                                             ; FF45BE  ee 0d
	ret                                                  ; FF45C0  0e
; ---------------------------------------------------------------------
; LcdKeyRow1_MidiFileDirectPlay -- what Dispatch_FF3880 runs for panel
;          control 0x08
;
; Reached from: Dispatch_FF3880 entry [8] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x08 is the LCD row 1 button pair -- the left-hand and
;          right-hand buttons of the display's TOP row. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileDirectPlay -- the screen object at
;          PanelScreen_VtableTable entry 0x65, i.e. SCREEN ID 0x45 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4408 as its ENTER method, and that address carries
;          the label Paint_MidiFileDirectPlay -- a name an earlier round
;          derived from the screen's own text.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow1_MidiFileDirectPlay:
	link XIZ,0x0000                                      ; FF45C1  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF45C5  9e 08 21
	and BC,0x0080                                        ; FF45C8  d9 cc 80 00
	jr nz, .LFF45EC                                      ; FF45CC  6e 1e
	ld bc, (Disk_SelectedEntry:16)                                 ; FF45CE  d1 24 27 21
	extz BC                                              ; FF45D2  d9 12
	pushw bc                                             ; FF45D4  29
	calr MidiFileList_CopyEntryToFileName                                      ; FF45D5  1e 84 01
	ld c, (Disk_FileName:16)                                   ; FF45D8  c1 c8 21 23
	popw wa                                              ; FF45DC  48
	cp C,0x20                                            ; FF45DD  cb cf 20
	jr z, .LFF45F3                                       ; FF45E0  66 11
	call T_MidiFileDirectPlay_LcdKeyRow1                                        ; FF45E2  1d 54 09 f4
	set	4, (UI_ScreenFlags:16)                               ; FF45E6  f1 95 20 bc
	jr .LFF45F3                                          ; FF45EA  68 07
.LFF45EC:
	pushw	(xiz+8)                                      ; FF45EC  9e 08 04
	calr LcdKeyRow2_MidiFileDirectPlay                                      ; FF45EF  1e 04 00
	popw bc                                              ; FF45F2  49
.LFF45F3:
	unlk XIZ                                             ; FF45F3  ee 0d
	ret                                                  ; FF45F5  0e
; ---------------------------------------------------------------------
; LcdKeyRow2_MidiFileDirectPlay -- what Dispatch_FF3880 runs for panel
;          control 0x09
;
; Reached from: Dispatch_FF3880 entry [9] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x09 is the LCD row 2 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileDirectPlay -- the screen object at
;          PanelScreen_VtableTable entry 0x65, i.e. SCREEN ID 0x45 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4408 as its ENTER method, and that address carries
;          the label Paint_MidiFileDirectPlay -- a name an earlier round
;          derived from the screen's own text.
; Unknown:  what this screen does with the button.
; Was `sub_FF45F6`.
; ---------------------------------------------------------------------
LcdKeyRow2_MidiFileDirectPlay:
	link XIZ,0x0000                                      ; FF45F6  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF45FA  9e 08 21
	and BC,0x0080                                        ; FF45FD  d9 cc 80 00
	jr z, .LFF4613                                       ; FF4601  66 10
	lda xbc, (DL_F59522:24)                              ; FF4603  f2 22 95 f5 31
	push XBC                                             ; FF4608  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF4609  1d 23 76 ff
	ld (0x2730:16), 0x00                                 ; FF460D  f1 30 27 00 00
	pop XIY                                              ; FF4612  5d
.LFF4613:
	unlk XIZ                                             ; FF4613  ee 0d
	ret                                                  ; FF4615  0e
; ---------------------------------------------------------------------
; LcdKeyRow3_MidiFileDirectPlay -- what Dispatch_FF3880 runs for panel
;          control 0x0A
;
; Reached from: Dispatch_FF3880 entry [10] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0A is the LCD row 3 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileDirectPlay -- the screen object at
;          PanelScreen_VtableTable entry 0x65, i.e. SCREEN ID 0x45 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4408 as its ENTER method, and that address carries
;          the label Paint_MidiFileDirectPlay -- a name an earlier round
;          derived from the screen's own text.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow3_MidiFileDirectPlay:
	link XIZ,0x0000                                      ; FF4616  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF461A  9e 08 21
	and BC,0x0080                                        ; FF461D  d9 cc 80 00
	jr z, .LFF4635                                       ; FF4621  66 12
	lda xbc, (DL_F59522:24)                              ; FF4623  f2 22 95 f5 31
	push XBC                                             ; FF4628  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF4629  1d 23 76 ff
	ld (0x2730:16), 0x00                                 ; FF462D  f1 30 27 00 00
	pop XIY                                              ; FF4632  5d
	jr .LFF463F                                          ; FF4633  68 0a
.LFF4635:
	ld (UI_Request:16), 0xb7                                 ; FF4635  f1 70 20 00 b7
	ld (UI_Request_Hi:16), 0x40                                 ; FF463A  f1 71 20 00 40
.LFF463F:
	unlk XIZ                                             ; FF463F  ee 0d
	ret                                                  ; FF4641  0e
; ---------------------------------------------------------------------
; LcdKeyRow4_MidiFileDirectPlay -- what Dispatch_FF3880 runs for panel
;          control 0x0B
;
; Reached from: Dispatch_FF3880 entry [11] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0B is the LCD row 4 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileDirectPlay -- the screen object at
;          PanelScreen_VtableTable entry 0x65, i.e. SCREEN ID 0x45 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4408 as its ENTER method, and that address carries
;          the label Paint_MidiFileDirectPlay -- a name an earlier round
;          derived from the screen's own text.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow4_MidiFileDirectPlay:
	link XIZ,0x0000                                      ; FF4642  ee 0c 00 00
	ld c, (0x60505e:24)                                 ; FF4646  c2 5e 50 60 23
	and C,0x02                                           ; FF464B  cb cc 02
	jrl nz, .LFF46BD                                     ; FF464E  7e 6c 00
	set	3, (UI_RequestBits:16)                               ; FF4651  f1 75 20 bb
	ld BC,(XIZ+0x08)                                     ; FF4655  9e 08 21
	and BC,0x0080                                        ; FF4658  d9 cc 80 00
	jr nz, .LFF46B6                                      ; FF465C  6e 58
	ld bc, (0x2730:16)                                 ; FF465E  d1 30 27 21
	extz BC                                              ; FF4662  d9 12
	cp bc, 0x00:i3                                         ; FF4664  d9 d8
	jr z, .LFF466E                                       ; FF4666  66 06
	cp bc, 0x01:i3                                         ; FF4668  d9 d9
	jr z, .LFF4691                                       ; FF466A  66 25
	jr .LFF46BD                                          ; FF466C  68 4f
.LFF466E:
	lda xbc, (DL_F59572:24)                              ; FF466E  f2 72 95 f5 31
	push XBC                                             ; FF4673  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF4674  1d 23 76 ff
	pushw 0x05                                           ; FF4678  0b 05 00
	pushw 0x0a                                           ; FF467B  0b 0a 00
	calr MidiFile_LcdKeyRow4                                      ; FF467E  1e 07 1d
	lda xbc, (DL_F59567:24)                              ; FF4681  f2 67 95 f5 31
	push XBC                                             ; FF4686  39
	call DLB_Array8_SaveRegs                                      ; FF4687  1d 3f 76 ff
	inc 8,XSP                                            ; FF468B  ef 60
	inc 4,XSP                                            ; FF468D  ef 64
	jr .LFF46BD                                          ; FF468F  68 2c
.LFF4691:
	cp	(0x2732:16), 0x00                            ; FF4691  c1 32 27 3f 00
	jr nz, .LFF46BD                                      ; FF4696  6e 25
	ld (0x2732:16), 0xff                                 ; FF4698  f1 32 27 00 ff
	pushw 0x06                                           ; FF469D  0b 06 00
	pushw 0x03                                           ; FF46A0  0b 03 00
	pushw 0x1e3d                                         ; FF46A3  0b 3d 1e
	lda xbc, (0xf59538:24)                               ; FF46A6  f2 38 95 f5 31
	push XBC                                             ; FF46AB  39
	call LCD_SwiTextCall_SaveRegs                                      ; FF46AC  1d 95 78 ff
	inc 8,XSP                                            ; FF46B0  ef 60
	inc 2,XSP                                            ; FF46B2  ef 62
	jr .LFF46BD                                          ; FF46B4  68 07
.LFF46B6:
	pushw	(xiz+8)                                      ; FF46B6  9e 08 04
	calr LcdKeyRow2_MidiFileDirectPlay                                      ; FF46B9  1e 3a ff
	popw bc                                              ; FF46BC  49
.LFF46BD:
	unlk XIZ                                             ; FF46BD  ee 0d
	ret                                                  ; FF46BF  0e
; ---------------------------------------------------------------------
; LcdKeyRow5_MidiFileDirectPlay -- what Dispatch_FF3880 runs for panel
;          control 0x0C
;
; Reached from: Dispatch_FF3880 entry [12] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0C is the LCD row 5 button pair -- the BOTTOM row. The
;          pair position -- which of the two keys -- reaches the handler in
;          the argument the reader forwards; this pass did NOT establish that
;          argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileDirectPlay -- the screen object at
;          PanelScreen_VtableTable entry 0x65, i.e. SCREEN ID 0x45 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4408 as its ENTER method, and that address carries
;          the label Paint_MidiFileDirectPlay -- a name an earlier round
;          derived from the screen's own text.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow5_MidiFileDirectPlay:
	link XIZ,0x0000                                      ; FF46C0  ee 0c 00 00
	ld c, (0x60505e:24)                                 ; FF46C4  c2 5e 50 60 23
	and C,0x02                                           ; FF46C9  cb cc 02
	jrl nz, .LFF473E                                     ; FF46CC  7e 6f 00
	set	3, (UI_RequestBits:16)                               ; FF46CF  f1 75 20 bb
	ld BC,(XIZ+0x08)                                     ; FF46D3  9e 08 21
	and BC,0x0080                                        ; FF46D6  d9 cc 80 00
	jr nz, .LFF472E                                      ; FF46DA  6e 52
	ld bc, (0x2730:16)                                 ; FF46DC  d1 30 27 21
	extz BC                                              ; FF46E0  d9 12
	cp bc, 0x00:i3                                         ; FF46E2  d9 d8
	jr z, .LFF46EC                                       ; FF46E4  66 06
	cp bc, 0x01:i3                                         ; FF46E6  d9 d9
	jr z, .LFF4709                                       ; FF46E8  66 1f
	jr .LFF473E                                          ; FF46EA  68 52
.LFF46EC:
	lda xbc, (DL_F59572:24)                              ; FF46EC  f2 72 95 f5 31
	push XBC                                             ; FF46F1  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF46F2  1d 23 76 ff
	pushw 0x05                                           ; FF46F6  0b 05 00
	pushw 0x0a                                           ; FF46F9  0b 0a 00
	calr MidiFile_LcdKeyRow5                                      ; FF46FC  1e c9 1c
	inc 8,XSP                                            ; FF46FF  ef 60
	lda xbc, (DL_F59567:24)                              ; FF4701  f2 67 95 f5 31
	push XBC                                             ; FF4706  39
	jr .LFF4739                                          ; FF4707  68 30
.LFF4709:
	cp	(0x2732:16), 0xff                            ; FF4709  c1 32 27 3f ff
	jr nz, .LFF473E                                      ; FF470E  6e 2e
	ld (0x2732:16), 0x00                                 ; FF4710  f1 32 27 00 00
	pushw 0x06                                           ; FF4715  0b 06 00
	pushw 0x03                                           ; FF4718  0b 03 00
	pushw 0x1e3d                                         ; FF471B  0b 3d 1e
	lda xbc, (DLText_F59535:24)                          ; FF471E  f2 35 95 f5 31
	push XBC                                             ; FF4723  39
	call LCD_SwiTextCall_SaveRegs                                      ; FF4724  1d 95 78 ff
	inc 8,XSP                                            ; FF4728  ef 60
	inc 2,XSP                                            ; FF472A  ef 62
	jr .LFF473E                                          ; FF472C  68 10
.LFF472E:
	ld (0x2730:16), 0x01                                 ; FF472E  f1 30 27 00 01
	lda xbc, (DL_F59517:24)                              ; FF4733  f2 17 95 f5 31
	push XBC                                             ; FF4738  39
.LFF4739:
	call DLB_Array8_SaveRegs                                      ; FF4739  1d 3f 76 ff
	pop XIY                                              ; FF473D  5d
.LFF473E:
	unlk XIZ                                             ; FF473E  ee 0d
	ret                                                  ; FF4740  0e
; ---------------------------------------------------------------------
; ExitKey_MidiFileDirectPlay -- what Dispatch_FF3880 runs for panel control
;          0x0F
;
; Reached from: Dispatch_FF3880 entry [15] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0F is the EXIT key. The pair position -- which of the two
;          keys -- reaches the handler in the argument the reader forwards;
;          this pass did NOT establish that argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileDirectPlay -- the screen object at
;          PanelScreen_VtableTable entry 0x65, i.e. SCREEN ID 0x45 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4408 as its ENTER method, and that address carries
;          the label Paint_MidiFileDirectPlay -- a name an earlier round
;          derived from the screen's own text.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
ExitKey_MidiFileDirectPlay:
	link XIZ,0x0000                                      ; FF4741  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF4745  9e 08 21
	and BC,0x0080                                        ; FF4748  d9 cc 80 00
	jr nz, .LFF4758                                      ; FF474C  6e 0a
	ld (UI_Request:16), 0x40                                 ; FF474E  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF4753  f1 71 20 00 80
.LFF4758:
	unlk XIZ                                             ; FF4758  ee 0d
	ret                                                  ; FF475A  0e
T_F42280_Nop:
	ret                                                  ; FF475B  0e
; MidiFileList_CopyEntryToFileName: Copies 11 bytes of MIDI-file listing entry n (arg) at 0x60A480 + 8*n to
;   Disk_FileName -- the 8-byte stride of the MIDI-file listing, not the 16-byte disk directory. The MIDI FILE DIRECT
;   PLAY / LOAD / SAVE keys pass Disk_SelectedEntry, then test for a blank name or write the MID extension. Basis:
;   callers + body. (notes/naming-pilot-2026-10-06/proposals_wave2_e.json)
MidiFileList_CopyEntryToFileName:
	link XIZ,0x0000                                      ; FF475C  ee 0c 00 00
	pushw 0x0b                                           ; FF4760  0b 0b 00
	ldw bc, 0x08                                         ; FF4763  31 08 00
	muls	xbc, (xiz+8)                                 ; FF4766  9e 08 49
	add XBC,0x00000480                                   ; FF4769  e9 c8 80 04 00 00
	add XBC,0x0060a000                                   ; FF476F  e9 c8 00 a0 60 00
	push XBC                                             ; FF4775  39
	lda xbc, (Disk_FileName:16)                                ; FF4776  f1 c8 21 31
	push XBC                                             ; FF477A  39
	call MemCpy_C                                      ; FF477B  1d b5 78 ff
	inc 8,XSP                                            ; FF477F  ef 60
	inc 2,XSP                                            ; FF4781  ef 62
	unlk XIZ                                             ; FF4783  ee 0d
	ret                                                  ; FF4785  0e
; ---------------------------------------------------------------------
; Paint_DiskL0adFile -- paints the screen whose own text reads "L0AD FILE" / "L0AD 0PTI0N" over the FLOPPY DISK file list
;
; Called from: prom_b T_F423A0 (`jp`)
;
; It hands 8 display list(s) to the interpreter ON THE STACK --
;          lda XBC,<end> / push XBC / lda XWA,<start> / push XWA,
;          then the stack veneer.  The lists, and the text each draws:
;     site 0xFF47FF  list 0xF581B0-0xF581F8 (72 B, leaves by jp(XIX))
;        text: "LOAD"; "L0AD FILE"; "LOAD"; "L0AD 0PTI0N"
;     site 0xFF4816  list 0xF58288-0xF583AB (291 B, leaves by jp(XIX))
;        text: "FLOPPY"; "DISK"; "01 :"; "02 :"; "03 :"; "04 :"; "1O :"; "11 :"; ...
;     site 0xFF483B  list 0xF583E5-0xF5840A (37 B, leaves by call)
;        text: "$'?"
;     site 0xFF486A  list 0xF583D0-0xF583E5 (21 B, leaves by jp(XIX))
;        text: "TO S0NG NUMBER  :"
;     site 0xFF4881  list 0xF583AB-0xF583BA (15 B, leaves by jp(XIX))
;     site 0xFF48A2  list 0xF5840A-0xF5841F (21 B, leaves by call)
;     site 0xFF48B9  list 0xF583AB-0xF583BA (15 B, leaves by jp(XIX))
;     site 0xFF48D0  list 0xF59C4B-0xF59C5B (16 B, leaves by jp(XIX))
;        text: "1-10"
; From the captions: "DISK"; "L0AD FILE"
; Evidence: the list bounds are the two 24-bit IMMEDIATES of the
;          12-byte push idiom at the cited site, and the record
;          length bytes walked from <start> land EXACTLY on <end>
;          (368 of 368 in both images do -- notes/prom_a_dl_stack_map.py).
;          The quoted text is the `.ascii` the interpreter draws
;          verbatim.  Every morpheme of this name occurs in it;
;          notes/prom_a_understanding_round7.py --morphemes checks that.
;          `Paint_` is a structural verb, not ROM text.
; Unknown: whether this routine also handles input for the screen,
;          and whether another routine paints it too.  Neither was
;          searched.  ⚠ The register-form scan of rounds 5 and 6 does
;          not see this call shape at all, which is why this routine
;          was sub_XXXXXX until round 7.
; Named by notes/prom_a_understanding_round7.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_DiskL0adFile:
	push XIX                                             ; FF4786  3c
	lda xix, (DisplayList_RunOnLayer_SaveRegs:24)                             ; FF4787  f2 d3 75 ff 34
	ld (0x21fa:16), 0x00                                 ; FF478C  f1 fa 21 00 00
	call T_CallbackQueue_ResetAndRestartTask2            ; FF4791  1d 80 2e f4
	cpw	(PanelHold_Index:16), 0x0007                          ; FF4795  d1 96 20 3f 07 00
	jr nz, .LFF47B3                                      ; FF479B  6e 16
	ldw (PanelHold_Index:16), 0x00                                ; FF479D  f1 96 20 02 00 00
	inc 0x01, (Disk_SelectedEntry:16)                                ; FF47A3  c1 24 27 61
	cp	(Disk_SelectedEntry:16), 0x13                            ; FF47A7  c1 24 27 3f 13
	jr ule, .LFF47B3                                     ; FF47AC  63 05
	ld (Disk_SelectedEntry:16), 0x00                                 ; FF47AE  f1 24 27 00 00
.LFF47B3:
	cp	(Disk_SelectedEntry:16), 0x13                            ; FF47B3  c1 24 27 3f 13
	jr ule, .LFF47BF                                     ; FF47B8  63 05
	ld (Disk_SelectedEntry:16), 0x00                                 ; FF47BA  f1 24 27 00 00
.LFF47BF:
	ld c, (UI_ScreenLatch:16)                                   ; FF47BF  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FF47C3  c1 7b 20 f3
	jr z, .LFF47EB                                       ; FF47C7  66 22
	call T_Playback_StopAllAndIgnoreMidiStart                                        ; FF47C9  1d 94 25 f4
	call T_DiskLoadScreen_MountAndScanDirectory                                        ; FF47CD  1d b4 25 f4
	calr UI_StatusCode_Is0or2or4                                      ; FF47D1  1e c8 2d
	cp wa, 0x00:i3                                         ; FF47D4  d8 d8
	jr z, .LFF47E2                                       ; FF47D6  66 0a
	ld (UI_Request:16), 0x40                                 ; FF47D8  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF47DD  f1 71 20 00 80
.LFF47E2:
	ld (UI_ScreenItem:16), 0x00                                 ; FF47E2  f1 20 27 00 00
	set	6, (0x2094:16)                               ; FF47E7  f1 94 20 be
.LFF47EB:
	pushw 0x0b                                           ; FF47EB  0b 0b 00
	pushw 0x0c                                           ; FF47EE  0b 0c 00
	calr PanelDial_SetButtonPair                                      ; FF47F1  1e 36 29
	call T_CallbackQueue_ResetAndRestartTask2            ; FF47F4  1d 80 2e f4
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF47F8  1d 04 76 ff
	pushw 0x00                                           ; FF47FC  0b 00 00
	lda xbc, (DL_SaveSaveFileSaveSave0pti0n:24)          ; FF47FF  f2 f8 81 f5 31
	push XBC                                             ; FF4804  39
	lda xwa, (DL_LoadL0adFileLoadL0ad0pti0n:24)          ; FF4805  f2 b0 81 f5 30
	push XWA                                             ; FF480A  38
	lda xiy, (.LFF4813:24)                               ; FF480B  f2 13 48 ff 35
	push XIY                                             ; FF4810  3d
	jp (xix)                                             ; FF4811  b4 d8
.LFF4813:
	pushw 0x00                                           ; FF4813  0b 00 00
	lda xbc, (DL_F583AB:24)                              ; FF4816  f2 ab 83 f5 31
	push XBC                                             ; FF481B  39
	lda xwa, (DL_FloppyDisk:24)                          ; FF481C  f2 88 82 f5 30
	push XWA                                             ; FF4821  38
	lda xiy, (.LFF482A:24)                               ; FF4822  f2 2a 48 ff 35
	push XIY                                             ; FF4827  3d
	jp (xix)                                             ; FF4828  b4 d8
.LFF482A:
	call Disk_DrawDirectory20                                      ; FF482A  1d 7f 76 ff
	calr DiskLoad_SetContentTypeFromSelectedEntry                                      ; FF482E  1e bf 00
	ld c, (Disk_SeqBank:16)                                   ; FF4831  c1 2b 27 23
	inc 1,C                                              ; FF4835  cb 61
	ld (0x2733:16), c                                   ; FF4837  f1 33 27 43
	lda xbc, (DL_F5840A:24)                              ; FF483B  f2 0a 84 f5 31
	push XBC                                             ; FF4840  39
	lda xwa, (DL_F583E5:24)                              ; FF4841  f2 e5 83 f5 30
	push XWA                                             ; FF4846  38
	call T_DisplayListB_Run_Stack                        ; FF4847  1d 04 2e f4
	add XSP,0x00000020                                   ; FF484B  ef c8 20 00 00 00
	cp	(Variant_Flag:8), 0x02                               ; FF4851  c0 c4 3f 02
	jrl z, .LFF48EA                                      ; FF4855  76 92 00
	cp	(Disk_ContentType:16), 0x00                            ; FF4858  c1 25 27 3f 00
	jr z, .LFF4867                                       ; FF485D  66 08
	cp	(Disk_ContentType:16), 0x01                            ; FF485F  c1 25 27 3f 01
	jrl nz, .LFF48EA                                     ; FF4864  7e 83 00
.LFF4867:
	pushw 0x00                                           ; FF4867  0b 00 00
	lda xbc, (DL_F583E5:24)                              ; FF486A  f2 e5 83 f5 31
	push XBC                                             ; FF486F  39
	lda xwa, (DL_ToS0ngNumber:24)                        ; FF4870  f2 d0 83 f5 30
	push XWA                                             ; FF4875  38
	lda xiy, (.LFF487E:24)                               ; FF4876  f2 7e 48 ff 35
	push XIY                                             ; FF487B  3d
	jp (xix)                                             ; FF487C  b4 d8
.LFF487E:
	pushw 0x00                                           ; FF487E  0b 00 00
	lda xbc, (DL_FromS0ngNumber:24)                      ; FF4881  f2 ba 83 f5 31
	push XBC                                             ; FF4886  39
	lda xwa, (DL_F583AB:24)                              ; FF4887  f2 ab 83 f5 30
	push XWA                                             ; FF488C  38
	lda xiy, (.LFF4895:24)                               ; FF488D  f2 95 48 ff 35
	push XIY                                             ; FF4892  3d
	jp (xix)                                             ; FF4893  b4 d8
.LFF4895:
	add XSP,0x00000014                                   ; FF4895  ef c8 14 00 00 00
	cp	(Disk_ContentType:16), 0x01                            ; FF489B  c1 25 27 3f 01
	jr nz, .LFF48B6                                      ; FF48A0  6e 14
	lda xbc, (DLTab_F5841F:24)                           ; FF48A2  f2 1f 84 f5 31
	push XBC                                             ; FF48A7  39
	lda xwa, (DL_F5840A:24)                              ; FF48A8  f2 0a 84 f5 30
	push XWA                                             ; FF48AD  38
	call T_DisplayListB_Run_Stack                        ; FF48AE  1d 04 2e f4
	inc 8,XSP                                            ; FF48B2  ef 60
	jr .LFF48EA                                          ; FF48B4  68 34
.LFF48B6:
	pushw 0x00                                           ; FF48B6  0b 00 00
	lda xbc, (DL_FromS0ngNumber:24)                      ; FF48B9  f2 ba 83 f5 31
	push XBC                                             ; FF48BE  39
	lda xwa, (DL_F583AB:24)                              ; FF48BF  f2 ab 83 f5 30
	push XWA                                             ; FF48C4  38
	lda xiy, (.LFF48CD:24)                               ; FF48C5  f2 cd 48 ff 35
	push XIY                                             ; FF48CA  3d
	jp (xix)                                             ; FF48CB  b4 d8
.LFF48CD:
	pushw 0x00                                           ; FF48CD  0b 00 00
	lda xbc, (0xf59c5b:24)                               ; FF48D0  f2 5b 9c f5 31
	push XBC                                             ; FF48D5  39
	lda xwa, (DL_F59C4B:24)                              ; FF48D6  f2 4b 9c f5 30
	push XWA                                             ; FF48DB  38
	lda xiy, (.LFF48E4:24)                               ; FF48DC  f2 e4 48 ff 35
	push XIY                                             ; FF48E1  3d
	jp (xix)                                             ; FF48E2  b4 d8
.LFF48E4:
	add XSP,0x00000014                                   ; FF48E4  ef c8 14 00 00 00
.LFF48EA:
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF48EA  1d 15 76 ff
	pop XIX                                              ; FF48EE  5c
	ret                                                  ; FF48EF  0e
; DiskLoad_SetContentTypeFromSelectedEntry: Reads directory entry 0x60A480 + 16*min(Disk_SelectedEntry, 0x13),
;   classifies it with DiskEntry_GetContentType and, unless that says 9 (no type), stores it in Disk_ContentType. DISK
;   L0AD FILE runs it after drawing the directory and after its LcdKeyRow4/5 move the selection. Basis: callers +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave2_f.json)
DiskLoad_SetContentTypeFromSelectedEntry:
	pushw hl                                             ; FF48F0  2b
	push 0x00                                            ; FF48F1  09 00
	push	(Disk_SelectedEntry:16)                                  ; FF48F3  c1 24 27 04
	calr DiskEntry_GetPointer                                      ; FF48F7  1e 15 00
	inc 8,XIY                                            ; FF48FA  ed 60
	push XIY                                             ; FF48FC  3d
	calr DiskEntry_GetContentType                                      ; FF48FD  1e 36 00
	ld H,A                                               ; FF4900  c9 8e
	inc 6,XSP                                            ; FF4902  ef 66
	cp A,0x09                                            ; FF4904  c9 cf 09
	jr z, .LFF490D                                       ; FF4907  66 04
	ld (Disk_ContentType:16), a                                   ; FF4909  f1 25 27 41
.LFF490D:
	popw hl                                              ; FF490D  4b
	ret                                                  ; FF490E  0e
; DiskEntry_GetPointer: (n): XIY := 0x60A480 + 16 * min(n, 19) -- the 16-byte directory-listing entry n of the disk
;   screens. DISK L0AD's LCD rows pass Disk_SelectedEntry and hand XIY+8 to DiskEntry_GetContentType. Basis: callers +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave2_c.json)
DiskEntry_GetPointer:
	link XIZ,0x0000                                      ; FF490F  ee 0c 00 00
	pushw hl                                             ; FF4913  2b
	ld H,(XIZ+0x08)                                      ; FF4914  8e 08 26
	cp H,0x13                                            ; FF4917  ce cf 13
	jr ule, .LFF491E                                     ; FF491A  63 02
	ld h, 0x13:opc                                          ; FF491C  26 13
.LFF491E:
	ld c, 0x10:opc                                          ; FF491E  23 10
	mul bc, h                                          ; FF4920  ce 43
	extz XBC                                             ; FF4922  e9 12
	add XBC,0x00000480                                   ; FF4924  e9 c8 80 04 00 00
	add XBC,0x0060a000                                   ; FF492A  e9 c8 00 a0 60 00
	ld XIY,XBC                                           ; FF4930  e9 8d
	popw hl                                              ; FF4932  4b
	unlk XIZ                                             ; FF4933  ee 0d
	ret                                                  ; FF4935  0e
; DiskEntry_GetContentType: Returns the content type of a directory entry from its 8 per-type bytes at +6 (0x80 =
;   absent): none -> 9, one at index i -> i + 1, several -> 0 (ALL). The codes are Disk_ContentType's and index
;   '.ALL.SEQ.CMB...DRM'; Disk_DrawDirEntry and DISK L0AD skip type 9. Basis: callers + body + extension table.
;   (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_a.json)
DiskEntry_GetContentType:
	link XIZ,0x0000                                      ; FF4936  ee 0c 00 00
	pushw hl                                             ; FF493A  2b
	pushw de                                             ; FF493B  2a
	push XIX                                             ; FF493C  3c
	ld h, 0x00:opc                                          ; FF493D  26 00
	ld d, 0x00:opc                                          ; FF493F  24 00
	ld l, 0x00:opc                                          ; FF4941  27 00
	ld XIX,(XIZ+0x08)                                    ; FF4943  ae 08 24
.LFF4946:
	ld C,(XIX)                                           ; FF4946  84 23
	cp C,0x80                                            ; FF4948  cb cf 80
	jr z, .LFF4951                                       ; FF494B  66 04
	ld D,H                                               ; FF494D  ce 8c
	inc 1,L                                              ; FF494F  cf 61
.LFF4951:
	inc 1,H                                              ; FF4951  ce 61
	inc 1,XIX                                            ; FF4953  ec 61
	cp H,0x08                                            ; FF4955  ce cf 08
	jr c, .LFF4946                                       ; FF4958  67 ec
	ld C,L                                               ; FF495A  cf 8b
	extz BC                                              ; FF495C  d9 12
	cp bc, 0x00:i3                                         ; FF495E  d9 d8
	jr z, .LFF4972                                       ; FF4960  66 10
	cp bc, 0x01:i3                                         ; FF4962  d9 d9
	jr z, .LFF4968                                       ; FF4964  66 02
	jr .LFF497E                                          ; FF4966  68 16
.LFF4968:
	cp	(Variant_Flag:8), 0x02                               ; FF4968  c0 c4 3f 02
	jr nz, .LFF4976                                      ; FF496C  6e 08
	cp d, 0x00:i3                                          ; FF496E  cc d8
	jr nz, .LFF4976                                      ; FF4970  6e 04
.LFF4972:
	ld a, 0x09:opc                                          ; FF4972  21 09
	jr .LFF4980                                          ; FF4974  68 0a
.LFF4976:
	ld C,D                                               ; FF4976  cc 8b
	inc 1,C                                              ; FF4978  cb 61
	ld A,C                                               ; FF497A  cb 89
	jr .LFF4980                                          ; FF497C  68 02
.LFF497E:
	sub A,A                                              ; FF497E  c9 a1
.LFF4980:
	pop XIX                                              ; FF4980  5c
	popw de                                              ; FF4981  4a
	popw hl                                              ; FF4982  4b
	unlk XIZ                                             ; FF4983  ee 0d
	ret                                                  ; FF4985  0e
; ---------------------------------------------------------------------
; ScreenLeave_DiskL0adFile -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0x67, i.e. SCREEN ID 0x47 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x67 -> the screen object at
;          0xF423A0, whose +4 slot is `jp 0xFF4986`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the LEAVE method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   DiskL0adFile -- the same object's +0 ENTER method carries the
;          label Paint_DiskL0adFile, a name an earlier round derived from the
;          screen's own text.
; Was `sub_FF4986`.
; ---------------------------------------------------------------------
ScreenLeave_DiskL0adFile:
	ld c, (UI_ScreenLatch:16)                                   ; FF4986  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FF498A  c1 7b 20 f3
	jr z, .LFF4994                                       ; FF498E  66 04
	call DiskFileScreen_LeaveCommon                                      ; FF4990  1d 8c 79 ff
.LFF4994:
	ret                                                  ; FF4994  0e
; ---------------------------------------------------------------------
; PanelButtonDispatch_DiskL0adFile -- run Dispatch_FF3900's handler for one
;          PANEL CONTROL
;
; Inputs:   (XIZ+0x08) = the 5-bit panel control index; (XIZ+0x0A) =
;          the argument this reader forwards to the handler.
; Evidence: `cp H,0x20` at 0xFF499D bounds the index to the 32-code
;          panel space PanelButton_Route's `and L,0x1f`
;          (0xF861AE) produces, and `add XBC,0x00FF3900` at 0xFF49AB
;          names the table.
;          The handler is CALLED, not jumped to: the reader pushes
;          a return address before `jp (XBC)`.
; Control legend: notes/FINDINGS-prom_a-panel-control-map.md, and
;          `python3 notes/prom_a_panel_control_map.py --map`.
; Screen:   DiskL0adFile -- the screen object at PanelScreen_VtableTable
;          entry 0x67, i.e. SCREEN ID 0x47 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4786 as its ENTER method, and that address carries
;          the label Paint_DiskL0adFile -- a name an earlier round derived
;          from the screen's own text.
; Was `sub_FF4995`, named by notes/prom_a_naming_wave8_apply.py.
; ---------------------------------------------------------------------
PanelButtonDispatch_DiskL0adFile:
	link XIZ,0x0000                                      ; FF4995  ee 0c 00 00
	pushw hl                                             ; FF4999  2b
	ld H,(XIZ+0x08)                                      ; FF499A  8e 08 26
	cp H,0x20                                            ; FF499D  ce cf 20
	jr nc, .LFF49BC                                      ; FF49A0  6f 1a
	pushw	(xiz+10)                                     ; FF49A2  9e 0a 04
	ld c, 0x04:opc                                          ; FF49A5  23 04
	mul bc, h                                          ; FF49A7  ce 43
	extz XBC                                             ; FF49A9  e9 12
	add XBC,Dispatch_FF3900                              ; FF49AB  e9 c8 00 39 ff 00
	ld XBC,(XBC)                                         ; FF49B1  a1 21
	lda xiy, (.LFF49BB:24)                               ; FF49B3  f2 bb 49 ff 35
	push XIY                                             ; FF49B8  3d
	jp (xbc)                                             ; FF49B9  b1 d8
.LFF49BB:
	popw bc                                              ; FF49BB  49
.LFF49BC:
	popw hl                                              ; FF49BC  4b
	unlk XIZ                                             ; FF49BD  ee 0d
	ret                                                  ; FF49BF  0e
; ---------------------------------------------------------------------
; LcdKeyRow1_DiskL0adFile -- what Dispatch_FF3900 runs for panel control 0x08
;
; Reached from: Dispatch_FF3900 entry [8] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x08 is the LCD row 1 button pair -- the left-hand and
;          right-hand buttons of the display's TOP row. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskL0adFile -- the screen object at PanelScreen_VtableTable
;          entry 0x67, i.e. SCREEN ID 0x47 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4786 as its ENTER method, and that address carries
;          the label Paint_DiskL0adFile -- a name an earlier round derived
;          from the screen's own text.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow1_DiskL0adFile:
	link XIZ,0x0000                                      ; FF49C0  ee 0c 00 00
	push XIX                                             ; FF49C4  3c
	lda xix, (Var7FD6_IsBitClear:24)                             ; FF49C5  f2 3b 75 ff 34
	ld BC,(XIZ+0x08)                                     ; FF49CA  9e 08 21
	and BC,0x0080                                        ; FF49CD  d9 cc 80 00
	jrl nz, .LFF4A55                                     ; FF49D1  7e 81 00
	push 0x00                                            ; FF49D4  09 00
	push	(Disk_SelectedEntry:16)                                  ; FF49D6  c1 24 27 04
	calr DiskEntry_GetPointer                                      ; FF49DA  1e 32 ff
	inc 8,XIY                                            ; FF49DD  ed 60
	push XIY                                             ; FF49DF  3d
	calr DiskEntry_GetContentType                                      ; FF49E0  1e 53 ff
	inc 6,XSP                                            ; FF49E3  ef 66
	cp A,0x09                                            ; FF49E5  c9 cf 09
	jrl z, .LFF4A7F                                      ; FF49E8  76 94 00
	cp	(Disk_ContentType:16), 0x00                            ; FF49EB  c1 25 27 3f 00
	jr nz, .LFF4A14                                      ; FF49F0  6e 22
	pushw 0x00                                           ; FF49F2  0b 00 00
	lda xiy, (.LFF49FD:24)                               ; FF49F5  f2 fd 49 ff 35
	push XIY                                             ; FF49FA  3d
	jp (xix)                                             ; FF49FB  b4 d8
.LFF49FD:
	popw bc                                              ; FF49FD  49
	cp wa, 0x00:i3                                         ; FF49FE  d8 d8
	jr z, .LFF4A44                                       ; FF4A00  66 42
	pushw 0x01                                           ; FF4A02  0b 01 00
	lda xiy, (.LFF4A0D:24)                               ; FF4A05  f2 0d 4a ff 35
	push XIY                                             ; FF4A0A  3d
	jp (xix)                                             ; FF4A0B  b4 d8
.LFF4A0D:
	popw bc                                              ; FF4A0D  49
	cp wa, 0x00:i3                                         ; FF4A0E  d8 d8
	jr nz, .LFF4A50                                      ; FF4A10  6e 3e
	jr .LFF4A44                                          ; FF4A12  68 30
.LFF4A14:
	cp	(Disk_ContentType:16), 0x03                            ; FF4A14  c1 25 27 3f 03
	jr nz, .LFF4A2D                                      ; FF4A19  6e 12
	pushw 0x00                                           ; FF4A1B  0b 00 00
	lda xiy, (.LFF4A26:24)                               ; FF4A1E  f2 26 4a ff 35
	push XIY                                             ; FF4A23  3d
	jp (xix)                                             ; FF4A24  b4 d8
.LFF4A26:
	popw bc                                              ; FF4A26  49
	cp wa, 0x00:i3                                         ; FF4A27  d8 d8
	jr nz, .LFF4A50                                      ; FF4A29  6e 25
	jr .LFF4A44                                          ; FF4A2B  68 17
.LFF4A2D:
	cp	(Disk_ContentType:16), 0x02                            ; FF4A2D  c1 25 27 3f 02
	jr nz, .LFF4A50                                      ; FF4A32  6e 1c
	pushw 0x01                                           ; FF4A34  0b 01 00
	lda xiy, (.LFF4A3F:24)                               ; FF4A37  f2 3f 4a ff 35
	push XIY                                             ; FF4A3C  3d
	jp (xix)                                             ; FF4A3D  b4 d8
.LFF4A3F:
	popw bc                                              ; FF4A3F  49
	cp wa, 0x00:i3                                         ; FF4A40  d8 d8
	jr nz, .LFF4A50                                      ; FF4A42  6e 0c
.LFF4A44:
	ld (UI_Request:16), 0xb3                                 ; FF4A44  f1 70 20 00 b3
	ld (UI_Request_Hi:16), 0x40                                 ; FF4A49  f1 71 20 00 40
	jr .LFF4A7F                                          ; FF4A4E  68 2f
.LFF4A50:
	calr DiskL0adFile_LcdKeyRow1                                      ; FF4A50  1e 11 2b
	jr .LFF4A7F                                          ; FF4A53  68 2a
.LFF4A55:
	lda xbc, (DL_F5843F:24)                              ; FF4A55  f2 3f 84 f5 31
	push XBC                                             ; FF4A5A  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF4A5B  1d 23 76 ff
	ld (UI_ScreenItem:16), 0x00                                 ; FF4A5F  f1 20 27 00 00
	pushw 0x0b                                           ; FF4A64  0b 0b 00
	pushw 0x0c                                           ; FF4A67  0b 0c 00
	calr PanelDial_SetButtonPair                                      ; FF4A6A  1e bd 26
	lda xbc, (DL_F583E5:24)                              ; FF4A6D  f2 e5 83 f5 31
	push XBC                                             ; FF4A72  39
	call DLB_Array8_SaveRegs                                      ; FF4A73  1d 3f 76 ff
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF4A77  1d 15 76 ff
	inc 8,XSP                                            ; FF4A7B  ef 60
	inc 4,XSP                                            ; FF4A7D  ef 64
.LFF4A7F:
	pop XIX                                              ; FF4A7F  5c
	unlk XIZ                                             ; FF4A80  ee 0d
	ret                                                  ; FF4A82  0e
; ---------------------------------------------------------------------
; LcdKeyRow2_DiskL0adFile -- what Dispatch_FF3900 runs for panel control 0x09
;
; Reached from: Dispatch_FF3900 entry [9] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x09 is the LCD row 2 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskL0adFile -- the screen object at PanelScreen_VtableTable
;          entry 0x67, i.e. SCREEN ID 0x47 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4786 as its ENTER method, and that address carries
;          the label Paint_DiskL0adFile -- a name an earlier round derived
;          from the screen's own text.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow2_DiskL0adFile:
	link XIZ,0x0000                                      ; FF4A83  ee 0c 00 00
	pushw	(xiz+8)                                      ; FF4A87  9e 08 04
	calr LcdKeyRow3_DiskL0adFile                                      ; FF4A8A  1e 04 00
	popw bc                                              ; FF4A8D  49
	unlk XIZ                                             ; FF4A8E  ee 0d
	ret                                                  ; FF4A90  0e
; ---------------------------------------------------------------------
; LcdKeyRow3_DiskL0adFile -- what Dispatch_FF3900 runs for panel control 0x0A
;
; Reached from: Dispatch_FF3900 entry [10] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0A is the LCD row 3 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskL0adFile -- the screen object at PanelScreen_VtableTable
;          entry 0x67, i.e. SCREEN ID 0x47 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4786 as its ENTER method, and that address carries
;          the label Paint_DiskL0adFile -- a name an earlier round derived
;          from the screen's own text.
; Unknown:  what this screen does with the button.
; Was `sub_FF4A91`.
; ---------------------------------------------------------------------
LcdKeyRow3_DiskL0adFile:
	link XIZ,0x0000                                      ; FF4A91  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF4A95  9e 08 21
	and BC,0x0080                                        ; FF4A98  d9 cc 80 00
	jr z, .LFF4AC8                                       ; FF4A9C  66 2a
	lda xbc, (DL_F5843F:24)                              ; FF4A9E  f2 3f 84 f5 31
	push XBC                                             ; FF4AA3  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF4AA4  1d 23 76 ff
	ld (UI_ScreenItem:16), 0x00                                 ; FF4AA8  f1 20 27 00 00
	pushw 0x0b                                           ; FF4AAD  0b 0b 00
	pushw 0x0c                                           ; FF4AB0  0b 0c 00
	calr PanelDial_SetButtonPair                                      ; FF4AB3  1e 74 26
	lda xbc, (DL_F583E5:24)                              ; FF4AB6  f2 e5 83 f5 31
	push XBC                                             ; FF4ABB  39
	call DLB_Array8_SaveRegs                                      ; FF4ABC  1d 3f 76 ff
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF4AC0  1d 15 76 ff
	inc 8,XSP                                            ; FF4AC4  ef 60
	inc 4,XSP                                            ; FF4AC6  ef 64
.LFF4AC8:
	unlk XIZ                                             ; FF4AC8  ee 0d
	ret                                                  ; FF4ACA  0e
; ---------------------------------------------------------------------
; LcdKeyRow4_DiskL0adFile -- what Dispatch_FF3900 runs for panel control 0x0B
;
; Reached from: Dispatch_FF3900 entry [11] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0B is the LCD row 4 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskL0adFile -- the screen object at PanelScreen_VtableTable
;          entry 0x67, i.e. SCREEN ID 0x47 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4786 as its ENTER method, and that address carries
;          the label Paint_DiskL0adFile -- a name an earlier round derived
;          from the screen's own text.
; Unknown:  what this screen does with the button.
; Was `sub_FF4ACB`.
;
; ★ THIS ANSWERS THE HEADER BELOW, which is left verbatim.
;   Its reasoning was about what the routine DRAWS, and it was
;   right that nothing there tells this routine from its
;   sibling.  The DISPATCH SLOT does: they are two different
;   entries of one table, i.e. two different buttons of one
;   screen.  The older block's opening line now carries the new
;   name because the rename was applied file-wide; every other
;   word of it, including its refusal, is untouched and is the
;   record of how the gap was closed.
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; LcdKeyRow4_DiskL0adFile -- a screen painter this round REFUSED to name.
;
; It hands 14 display list(s) to the interpreter ON THE STACK.
;     site 0xFF4AEE  list 0xF5844A-0xF58455 (11 B, leaves by call)
;        text: "$'?"
;     site 0xFF4B48  list 0xF583BA-0xF583D0 (22 B, leaves by jr)
;        text: "FROM S0NG NUMBER :"
;     site 0xFF4B56  list 0xF583D0-0xF583E5 (21 B, leaves by call)
;        text: "TO S0NG NUMBER  :"
;     site 0xFF4B6D  list 0xF583AB-0xF583BA (15 B, leaves by jr)
;     site 0xFF4BFB  list 0xF583BA-0xF583D0 (22 B, leaves by call)
;        text: "FROM S0NG NUMBER :"
;     site 0xFF4C0E  list 0xF583AB-0xF583BA (15 B, leaves by call)
;     site 0xFF4C30  list 0xF583AB-0xF583BA (15 B, leaves by call)
;     site 0xFF4C58  list 0xF583D0-0xF583E5 (21 B, leaves by jr)
;        text: "TO S0NG NUMBER  :"
;     site 0xFF4C70  list 0xF5840A-0xF5841F (21 B, leaves by call)
;     site 0xFF4C9A  list 0xF583D0-0xF583E5 (21 B, leaves by call)
;        text: "TO S0NG NUMBER  :"
;     site 0xFF4CB1  list 0xF583AB-0xF583BA (15 B, leaves by call)
;     site 0xFF4CC8  list 0xF59C4B-0xF59C5B (16 B, leaves by jr)
;        text: "1-10"
;     site 0xFF4CD9  list 0xF59952-0xF5995C (10 B, leaves by call)
;     site 0xFF4CED  list 0xF583F0-0xF5840A (26 B, leaves by call)
;        text: "$'?"
; Evidence: the two 24-bit immediates of the 12-byte push idiom at
;          the cited site; the record walk from <start> lands exactly
;          on <end>; the text is the `.ascii` the interpreter draws.
; NOT NAMED because it and LcdKeyRow5_DiskL0adFile draw the SAME caption set (FROM S0NG
;          NUMBER, TO S0NG NUMBER, 1-10) and nothing in their own lists
;          tells the two apart.
;          A wrong name passes the byte gate forever, so this keeps
;          sub_XXXXXX and states the gap.
; Recorded by notes/prom_a_understanding_round7.py --apply.
; ---------------------------------------------------------------------
LcdKeyRow4_DiskL0adFile:
	link XIZ,0x0000                                      ; FF4ACB  ee 0c 00 00
	pushw hl                                             ; FF4ACF  2b
	push XIX                                             ; FF4AD0  3c
	lda xix, (Disk_ContentType:16)                                ; FF4AD1  f1 25 27 34
	pushw 0x0b                                           ; FF4AD5  0b 0b 00
	pushw 0x0c                                           ; FF4AD8  0b 0c 00
	calr PanelDial_SetButtonPair                                      ; FF4ADB  1e 4c 26
	ld BC,(XIZ+0x08)                                     ; FF4ADE  9e 08 21
	and BC,0x0080                                        ; FF4AE1  d9 cc 80 00
	pop XIY                                              ; FF4AE5  5d
	jrl nz, .LFF4CFF                                     ; FF4AE6  7e 16 02
	ld (LCD_CurrentLayer:16), 0x01                                 ; FF4AE9  f1 40 25 00 01
	lda xbc, (DLTab_F58455:24)                           ; FF4AEE  f2 55 84 f5 31
	push XBC                                             ; FF4AF3  39
	lda xwa, (DL_F5844A:24)                              ; FF4AF4  f2 4a 84 f5 30
	push XWA                                             ; FF4AF9  38
	call T_DisplayListB_Run_Stack                        ; FF4AFA  1d 04 2e f4
	ld bc, (UI_ScreenItem:16)                                 ; FF4AFE  d1 20 27 21
	extz BC                                              ; FF4B02  d9 12
	inc 8,XSP                                            ; FF4B04  ef 60
	cp bc, 0x00:i3                                         ; FF4B06  d9 d8
	jr z, .LFF4B17                                       ; FF4B08  66 0d
	cp bc, 0x01:i3                                         ; FF4B0A  d9 d9
	jrl z, .LFF4B95                                      ; FF4B0C  76 86 00
	cp bc, 0x02:i3                                         ; FF4B0F  d9 da
	jrl z, .LFF4BC9                                      ; FF4B11  76 b5 00
	jrl .LFF4CED                                         ; FF4B14  78 d6 01
.LFF4B17:
	ld h, (Disk_SelectedEntry:16)                                   ; FF4B17  c1 24 27 26
	dec 0x01, (Disk_SelectedEntry:16)                                ; FF4B1B  c1 24 27 69
	cp h, 0x00:i3                                          ; FF4B1F  ce d8
	jr nz, .LFF4B28                                      ; FF4B21  6e 05
	ld (Disk_SelectedEntry:16), 0x00                                 ; FF4B23  f1 24 27 00 00
.LFF4B28:
	cp	(UI_ScreenLatch:16), 0x47                            ; FF4B28  c1 7a 20 3f 47
	jr nz, .LFF4B32                                      ; FF4B2D  6e 03
	calr DiskLoad_SetContentTypeFromSelectedEntry                                      ; FF4B2F  1e be fd
.LFF4B32:
	ld C,(XIX)                                           ; FF4B32  84 23
	cp c, 0x01:i3                                          ; FF4B34  cb d9
	jr nz, .LFF4B7C                                      ; FF4B36  6e 44
	cp	(Variant_Flag:8), 0x01                               ; FF4B38  c0 c4 3f 01
	jr nz, .LFF4B7C                                      ; FF4B3C  6e 3e
	pushw 0x00                                           ; FF4B3E  0b 00 00
	cp	(UI_ScreenLatch:16), 0x4c                            ; FF4B41  c1 7a 20 3f 4c
	jr nz, .LFF4B56                                      ; FF4B46  6e 0e
	lda xbc, (DL_ToS0ngNumber:24)                        ; FF4B48  f2 d0 83 f5 31
	push XBC                                             ; FF4B4D  39
	lda xwa, (DL_FromS0ngNumber:24)                      ; FF4B4E  f2 ba 83 f5 30
	push XWA                                             ; FF4B53  38
	jr .LFF4B62                                          ; FF4B54  68 0c
.LFF4B56:
	lda xbc, (DL_F583E5:24)                              ; FF4B56  f2 e5 83 f5 31
	push XBC                                             ; FF4B5B  39
	lda xwa, (DL_ToS0ngNumber:24)                        ; FF4B5C  f2 d0 83 f5 30
	push XWA                                             ; FF4B61  38
.LFF4B62:
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF4B62  1d d3 75 ff
	inc 8,XSP                                            ; FF4B66  ef 60
	inc 2,XSP                                            ; FF4B68  ef 62
	pushw 0x00                                           ; FF4B6A  0b 00 00
	lda xbc, (DL_FromS0ngNumber:24)                      ; FF4B6D  f2 ba 83 f5 31
	push XBC                                             ; FF4B72  39
	lda xwa, (DL_F583AB:24)                              ; FF4B73  f2 ab 83 f5 30
	push XWA                                             ; FF4B78  38
	jrl .LFF4C68                                         ; FF4B79  78 ec 00
.LFF4B7C:
	ld C,(XIX)                                           ; FF4B7C  84 23
	cp c, 0x00:i3                                          ; FF4B7E  cb d8
	jrl nz, .LFF4CD6                                     ; FF4B80  7e 53 01
	cp	(Variant_Flag:8), 0x01                               ; FF4B83  c0 c4 3f 01
	jrl nz, .LFF4CD6                                     ; FF4B87  7e 4c 01
	cp	(UI_ScreenLatch:16), 0x47                            ; FF4B8A  c1 7a 20 3f 47
	jrl nz, .LFF4CED                                     ; FF4B8F  7e 5b 01
	jrl .LFF4C97                                         ; FF4B92  78 02 01
.LFF4B95:
	pushw 0x0c                                           ; FF4B95  0b 0c 00
	pushw 0x0b                                           ; FF4B98  0b 0b 00
	calr PanelDial_SetButtonPair                                      ; FF4B9B  1e 8c 25
	ld h, (Disk_SeqBank:16)                                   ; FF4B9E  c1 2b 27 26
	inc 0x01, (Disk_SeqBank:16)                                ; FF4BA2  c1 2b 27 61
	pop XIY                                              ; FF4BA6  5d
	cp H,0x09                                            ; FF4BA7  ce cf 09
	jr c, .LFF4BB1                                       ; FF4BAA  67 05
	ld (Disk_SeqBank:16), 0x09                                 ; FF4BAC  f1 2b 27 00 09
.LFF4BB1:
	ld c, (Disk_SeqBank:16)                                   ; FF4BB1  c1 2b 27 23
	inc 1,C                                              ; FF4BB5  cb 61
	ld (0x2733:16), c                                   ; FF4BB7  f1 33 27 43
	lda xbc, (0xf58415:24)                               ; FF4BBB  f2 15 84 f5 31
	push XBC                                             ; FF4BC0  39
	call DLB_Handler_Decimal_Veneer                                      ; FF4BC1  1d 68 76 ff
	pop XIY                                              ; FF4BC5  5d
	jrl .LFF4CED                                         ; FF4BC6  78 24 01
.LFF4BC9:
	ld H,(XIX)                                           ; FF4BC9  84 26
	ld C,H                                               ; FF4BCB  ce 8b
	dec 1,C                                              ; FF4BCD  cb 69
	ld (XIX),C                                           ; FF4BCF  b4 43
	cp h, 0x00:i3                                          ; FF4BD1  ce d8
	jr nz, .LFF4BD8                                      ; FF4BD3  6e 03
	ld (XIX),0x00                                        ; FF4BD5  b4 00 00
.LFF4BD8:
	cp	(Variant_Flag:8), 0x02                               ; FF4BD8  c0 c4 3f 02
	jr nz, .LFF4BEA                                      ; FF4BDC  6e 0c
	ld C,(XIX)                                           ; FF4BDE  84 23
	cp c, 0x01:i3                                          ; FF4BE0  cb d9
	jr nz, .LFF4BEA                                      ; FF4BE2  6e 06
	ld (XIX),0x00                                        ; FF4BE4  b4 00 00
	jrl .LFF4C8A                                         ; FF4BE7  78 a0 00
.LFF4BEA:
	ld C,(XIX)                                           ; FF4BEA  84 23
	cp c, 0x01:i3                                          ; FF4BEC  cb d9
	jrl nz, .LFF4C84                                     ; FF4BEE  7e 93 00
	pushw 0x00                                           ; FF4BF1  0b 00 00
	cp	(UI_ScreenLatch:16), 0x4c                            ; FF4BF4  c1 7a 20 3f 4c
	jr nz, .LFF4C30                                      ; FF4BF9  6e 35
	lda xbc, (DL_ToS0ngNumber:24)                        ; FF4BFB  f2 d0 83 f5 31
	push XBC                                             ; FF4C00  39
	lda xwa, (DL_FromS0ngNumber:24)                      ; FF4C01  f2 ba 83 f5 30
	push XWA                                             ; FF4C06  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF4C07  1d d3 75 ff
	pushw 0x00                                           ; FF4C0B  0b 00 00
	lda xbc, (DL_FromS0ngNumber:24)                      ; FF4C0E  f2 ba 83 f5 31
	push XBC                                             ; FF4C13  39
	lda xwa, (DL_F583AB:24)                              ; FF4C14  f2 ab 83 f5 30
	push XWA                                             ; FF4C19  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF4C1A  1d d3 75 ff
	ld c, (Disk_SeqBank:16)                                   ; FF4C1E  c1 2b 27 23
	inc 1,C                                              ; FF4C22  cb 61
	ld (0x2733:16), c                                   ; FF4C24  f1 33 27 43
	add XSP,0x00000014                                   ; FF4C28  ef c8 14 00 00 00
	jr .LFF4C70                                          ; FF4C2E  68 40
.LFF4C30:
	lda xbc, (DL_FromS0ngNumber:24)                      ; FF4C30  f2 ba 83 f5 31
	push XBC                                             ; FF4C35  39
	lda xwa, (DL_F583AB:24)                              ; FF4C36  f2 ab 83 f5 30
	push XWA                                             ; FF4C3B  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF4C3C  1d d3 75 ff
	push 0x00                                            ; FF4C40  09 00
	push	(Disk_SelectedEntry:16)                                  ; FF4C42  c1 24 27 04
	calr DiskEntry_GetPointer                                      ; FF4C46  1e c6 fc
	inc 8,XIY                                            ; FF4C49  ed 60
	push XIY                                             ; FF4C4B  3d
	calr DiskEntry_GetContentType                                      ; FF4C4C  1e e7 fc
	ld H,A                                               ; FF4C4F  c9 8e
	inc 8,XSP                                            ; FF4C51  ef 60
	inc 8,XSP                                            ; FF4C53  ef 60
	pushw 0x00                                           ; FF4C55  0b 00 00
	lda xbc, (DL_F583E5:24)                              ; FF4C58  f2 e5 83 f5 31
	push XBC                                             ; FF4C5D  39
	lda xwa, (DL_ToS0ngNumber:24)                        ; FF4C5E  f2 d0 83 f5 30
	push XWA                                             ; FF4C63  38
	cp h, 0x00:i3                                          ; FF4C64  ce d8
	jr z, .LFF4CBD                                       ; FF4C66  66 55
.LFF4C68:
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF4C68  1d d3 75 ff
	inc 8,XSP                                            ; FF4C6C  ef 60
	inc 2,XSP                                            ; FF4C6E  ef 62
.LFF4C70:
	lda xbc, (DLTab_F5841F:24)                           ; FF4C70  f2 1f 84 f5 31
	push XBC                                             ; FF4C75  39
	lda xwa, (DL_F5840A:24)                              ; FF4C76  f2 0a 84 f5 30
	push XWA                                             ; FF4C7B  38
	call T_DisplayListB_Run_Stack                        ; FF4C7C  1d 04 2e f4
	inc 8,XSP                                            ; FF4C80  ef 60
	jr .LFF4CED                                          ; FF4C82  68 69
.LFF4C84:
	ld C,(XIX)                                           ; FF4C84  84 23
	cp c, 0x00:i3                                          ; FF4C86  cb d8
	jr nz, .LFF4CD6                                      ; FF4C88  6e 4c
.LFF4C8A:
	cp	(Variant_Flag:8), 0x01                               ; FF4C8A  c0 c4 3f 01
	jr nz, .LFF4CD6                                      ; FF4C8E  6e 46
	cp	(UI_ScreenLatch:16), 0x47                            ; FF4C90  c1 7a 20 3f 47
	jr nz, .LFF4CD6                                      ; FF4C95  6e 3f
.LFF4C97:
	pushw 0x00                                           ; FF4C97  0b 00 00
	lda xbc, (DL_F583E5:24)                              ; FF4C9A  f2 e5 83 f5 31
	push XBC                                             ; FF4C9F  39
	lda xwa, (DL_ToS0ngNumber:24)                        ; FF4CA0  f2 d0 83 f5 30
	push XWA                                             ; FF4CA5  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF4CA6  1d d3 75 ff
	inc 8,XSP                                            ; FF4CAA  ef 60
	inc 2,XSP                                            ; FF4CAC  ef 62
	pushw 0x00                                           ; FF4CAE  0b 00 00
	lda xbc, (DL_FromS0ngNumber:24)                      ; FF4CB1  f2 ba 83 f5 31
	push XBC                                             ; FF4CB6  39
	lda xwa, (DL_F583AB:24)                              ; FF4CB7  f2 ab 83 f5 30
	push XWA                                             ; FF4CBC  38
.LFF4CBD:
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF4CBD  1d d3 75 ff
	inc 8,XSP                                            ; FF4CC1  ef 60
	inc 2,XSP                                            ; FF4CC3  ef 62
	pushw 0x00                                           ; FF4CC5  0b 00 00
	lda xbc, (0xf59c5b:24)                               ; FF4CC8  f2 5b 9c f5 31
	push XBC                                             ; FF4CCD  39
	lda xwa, (DL_F59C4B:24)                              ; FF4CCE  f2 4b 9c f5 30
	push XWA                                             ; FF4CD3  38
	jr .LFF4CE5                                          ; FF4CD4  68 0f
.LFF4CD6:
	pushw 0x00                                           ; FF4CD6  0b 00 00
	lda xbc, (DL_F5995C:24)                              ; FF4CD9  f2 5c 99 f5 31
	push XBC                                             ; FF4CDE  39
	lda xwa, (DL_F59952:24)                              ; FF4CDF  f2 52 99 f5 30
	push XWA                                             ; FF4CE4  38
.LFF4CE5:
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF4CE5  1d d3 75 ff
	inc 8,XSP                                            ; FF4CE9  ef 60
	inc 2,XSP                                            ; FF4CEB  ef 62
.LFF4CED:
	lda xbc, (DL_F5840A:24)                              ; FF4CED  f2 0a 84 f5 31
	push XBC                                             ; FF4CF2  39
	lda xwa, (DL_F583F0:24)                              ; FF4CF3  f2 f0 83 f5 30
	push XWA                                             ; FF4CF8  38
	call T_DisplayListB_Run_Stack                        ; FF4CF9  1d 04 2e f4
	jr .LFF4D52                                          ; FF4CFD  68 53
.LFF4CFF:
	cp	(Variant_Flag:8), 0x02                               ; FF4CFF  c0 c4 3f 02
	jr z, .LFF4D54                                       ; FF4D03  66 4f
	pushw 0x0c                                           ; FF4D05  0b 0c 00
	pushw 0x0b                                           ; FF4D08  0b 0b 00
	calr PanelDial_SetButtonPair                                      ; FF4D0B  1e 1c 24
	pop XIY                                              ; FF4D0E  5d
	cp	(UI_ScreenLatch:16), 0x4c                            ; FF4D0F  c1 7a 20 3f 4c
	jr z, .LFF4D33                                       ; FF4D14  66 1d
	ld C,(XIX)                                           ; FF4D16  84 23
	cp c, 0x01:i3                                          ; FF4D18  cb d9
	jr nz, .LFF4D54                                      ; FF4D1A  6e 38
	push 0x00                                            ; FF4D1C  09 00
	push	(Disk_SelectedEntry:16)                                  ; FF4D1E  c1 24 27 04
	calr DiskEntry_GetPointer                                      ; FF4D22  1e ea fb
	inc 8,XIY                                            ; FF4D25  ed 60
	push XIY                                             ; FF4D27  3d
	calr DiskEntry_GetContentType                                      ; FF4D28  1e 0b fc
	inc 6,XSP                                            ; FF4D2B  ef 66
	cp a, 0x00:i3                                          ; FF4D2D  c9 d8
	jr z, .LFF4D54                                       ; FF4D2F  66 23
	jr .LFF4D39                                          ; FF4D31  68 06
.LFF4D33:
	ld C,(XIX)                                           ; FF4D33  84 23
	cp c, 0x01:i3                                          ; FF4D35  cb d9
	jr nz, .LFF4D54                                      ; FF4D37  6e 1b
.LFF4D39:
	lda xbc, (DL_F5843F:24)                              ; FF4D39  f2 3f 84 f5 31
	push XBC                                             ; FF4D3E  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF4D3F  1d 23 76 ff
	ld (UI_ScreenItem:16), 0x01                                 ; FF4D43  f1 20 27 00 01
	lda xbc, (DL_F583E5:24)                              ; FF4D48  f2 e5 83 f5 31
	push XBC                                             ; FF4D4D  39
	call DLB_Array8_SaveRegs                                      ; FF4D4E  1d 3f 76 ff
.LFF4D52:
	inc 8,XSP                                            ; FF4D52  ef 60
.LFF4D54:
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF4D54  1d 15 76 ff
	pop XIX                                              ; FF4D58  5c
	popw hl                                              ; FF4D59  4b
	unlk XIZ                                             ; FF4D5A  ee 0d
	ret                                                  ; FF4D5C  0e
; ---------------------------------------------------------------------
; LcdKeyRow5_DiskL0adFile -- what Dispatch_FF3900 runs for panel control 0x0C
;
; Reached from: Dispatch_FF3900 entry [12] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0C is the LCD row 5 button pair -- the BOTTOM row. The
;          pair position -- which of the two keys -- reaches the handler in
;          the argument the reader forwards; this pass did NOT establish that
;          argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskL0adFile -- the screen object at PanelScreen_VtableTable
;          entry 0x67, i.e. SCREEN ID 0x47 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4786 as its ENTER method, and that address carries
;          the label Paint_DiskL0adFile -- a name an earlier round derived
;          from the screen's own text.
; Unknown:  what this screen does with the button.
; Was `sub_FF4D5D`.
;
; ★ THIS ANSWERS THE HEADER BELOW, which is left verbatim.
;   Its reasoning was about what the routine DRAWS, and it was
;   right that nothing there tells this routine from its
;   sibling.  The DISPATCH SLOT does: they are two different
;   entries of one table, i.e. two different buttons of one
;   screen.  The older block's opening line now carries the new
;   name because the rename was applied file-wide; every other
;   word of it, including its refusal, is untouched and is the
;   record of how the gap was closed.
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------
; LcdKeyRow5_DiskL0adFile -- a screen painter this round REFUSED to name.
;
; It hands 14 display list(s) to the interpreter ON THE STACK.
;     site 0xFF4D7F  list 0xF5844A-0xF58455 (11 B, leaves by call)
;        text: "$'?"
;     site 0xFF4DDC  list 0xF583BA-0xF583D0 (22 B, leaves by jr)
;        text: "FROM S0NG NUMBER :"
;     site 0xFF4DEA  list 0xF583D0-0xF583E5 (21 B, leaves by call)
;        text: "TO S0NG NUMBER  :"
;     site 0xFF4E01  list 0xF583AB-0xF583BA (15 B, leaves by jr)
;     site 0xFF4E97  list 0xF583BA-0xF583D0 (22 B, leaves by call)
;        text: "FROM S0NG NUMBER :"
;     site 0xFF4EAA  list 0xF583AB-0xF583BA (15 B, leaves by call)
;     site 0xFF4ECC  list 0xF583AB-0xF583BA (15 B, leaves by call)
;     site 0xFF4EF4  list 0xF583D0-0xF583E5 (21 B, leaves by jr)
;        text: "TO S0NG NUMBER  :"
;     site 0xFF4F0C  list 0xF5840A-0xF5841F (21 B, leaves by call)
;     site 0xFF4F30  list 0xF583D0-0xF583E5 (21 B, leaves by call)
;        text: "TO S0NG NUMBER  :"
;     site 0xFF4F47  list 0xF583AB-0xF583BA (15 B, leaves by call)
;     site 0xFF4F5E  list 0xF59C4B-0xF59C5B (16 B, leaves by jr)
;        text: "1-10"
;     site 0xFF4F6F  list 0xF59952-0xF5995C (10 B, leaves by call)
;     site 0xFF4F8D  list 0xF583F0-0xF5840A (26 B, leaves by call)
;        text: "$'?"
; Evidence: the two 24-bit immediates of the 12-byte push idiom at
;          the cited site; the record walk from <start> lands exactly
;          on <end>; the text is the `.ascii` the interpreter draws.
; NOT NAMED because it and LcdKeyRow4_DiskL0adFile draw the SAME caption set (FROM S0NG
;          NUMBER, TO S0NG NUMBER, 1-10) and nothing in their own lists
;          tells the two apart.
;          A wrong name passes the byte gate forever, so this keeps
;          sub_XXXXXX and states the gap.
; Recorded by notes/prom_a_understanding_round7.py --apply.
; ---------------------------------------------------------------------
LcdKeyRow5_DiskL0adFile:
	link XIZ,0x0000                                      ; FF4D5D  ee 0c 00 00
	pushw hl                                             ; FF4D61  2b
	push XIX                                             ; FF4D62  3c
	lda xix, (Disk_ContentType:16)                                ; FF4D63  f1 25 27 34
	ld BC,(XIZ+0x08)                                     ; FF4D67  9e 08 21
	and BC,0x0080                                        ; FF4D6A  d9 cc 80 00
	jrl nz, .LFF4F9F                                     ; FF4D6E  7e 2e 02
	pushw 0x0b                                           ; FF4D71  0b 0b 00
	pushw 0x0c                                           ; FF4D74  0b 0c 00
	calr PanelDial_SetButtonPair                                      ; FF4D77  1e b0 23
	ld (LCD_CurrentLayer:16), 0x01                                 ; FF4D7A  f1 40 25 00 01
	lda xbc, (DLTab_F58455:24)                           ; FF4D7F  f2 55 84 f5 31
	push XBC                                             ; FF4D84  39
	lda xwa, (DL_F5844A:24)                              ; FF4D85  f2 4a 84 f5 30
	push XWA                                             ; FF4D8A  38
	call T_DisplayListB_Run_Stack                        ; FF4D8B  1d 04 2e f4
	ld bc, (UI_ScreenItem:16)                                 ; FF4D8F  d1 20 27 21
	extz BC                                              ; FF4D93  d9 12
	inc 8,XSP                                            ; FF4D95  ef 60
	inc 4,XSP                                            ; FF4D97  ef 64
	cp bc, 0x00:i3                                         ; FF4D99  d9 d8
	jr z, .LFF4DAA                                       ; FF4D9B  66 0d
	cp bc, 0x01:i3                                         ; FF4D9D  d9 d9
	jrl z, .LFF4E29                                      ; FF4D9F  76 87 00
	cp bc, 0x02:i3                                         ; FF4DA2  d9 da
	jrl z, .LFF4E5C                                      ; FF4DA4  76 b5 00
	jrl .LFF4F83                                         ; FF4DA7  78 d9 01
.LFF4DAA:
	ld h, (Disk_SelectedEntry:16)                                   ; FF4DAA  c1 24 27 26
	inc 0x01, (Disk_SelectedEntry:16)                                ; FF4DAE  c1 24 27 61
	cp H,0x13                                            ; FF4DB2  ce cf 13
	jr c, .LFF4DBC                                       ; FF4DB5  67 05
	ld (Disk_SelectedEntry:16), 0x13                                 ; FF4DB7  f1 24 27 00 13
.LFF4DBC:
	cp	(UI_ScreenLatch:16), 0x47                            ; FF4DBC  c1 7a 20 3f 47
	jr nz, .LFF4DC6                                      ; FF4DC1  6e 03
	calr DiskLoad_SetContentTypeFromSelectedEntry                                      ; FF4DC3  1e 2a fb
.LFF4DC6:
	ld C,(XIX)                                           ; FF4DC6  84 23
	cp c, 0x01:i3                                          ; FF4DC8  cb d9
	jr nz, .LFF4E10                                      ; FF4DCA  6e 44
	cp	(Variant_Flag:8), 0x01                               ; FF4DCC  c0 c4 3f 01
	jr nz, .LFF4E10                                      ; FF4DD0  6e 3e
	pushw 0x00                                           ; FF4DD2  0b 00 00
	cp	(UI_ScreenLatch:16), 0x4c                            ; FF4DD5  c1 7a 20 3f 4c
	jr nz, .LFF4DEA                                      ; FF4DDA  6e 0e
	lda xbc, (DL_ToS0ngNumber:24)                        ; FF4DDC  f2 d0 83 f5 31
	push XBC                                             ; FF4DE1  39
	lda xwa, (DL_FromS0ngNumber:24)                      ; FF4DE2  f2 ba 83 f5 30
	push XWA                                             ; FF4DE7  38
	jr .LFF4DF6                                          ; FF4DE8  68 0c
.LFF4DEA:
	lda xbc, (DL_F583E5:24)                              ; FF4DEA  f2 e5 83 f5 31
	push XBC                                             ; FF4DEF  39
	lda xwa, (DL_ToS0ngNumber:24)                        ; FF4DF0  f2 d0 83 f5 30
	push XWA                                             ; FF4DF5  38
.LFF4DF6:
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF4DF6  1d d3 75 ff
	inc 8,XSP                                            ; FF4DFA  ef 60
	inc 2,XSP                                            ; FF4DFC  ef 62
	pushw 0x00                                           ; FF4DFE  0b 00 00
	lda xbc, (DL_FromS0ngNumber:24)                      ; FF4E01  f2 ba 83 f5 31
	push XBC                                             ; FF4E06  39
	lda xwa, (DL_F583AB:24)                              ; FF4E07  f2 ab 83 f5 30
	push XWA                                             ; FF4E0C  38
	jrl .LFF4F04                                         ; FF4E0D  78 f4 00
.LFF4E10:
	ld C,(XIX)                                           ; FF4E10  84 23
	cp c, 0x00:i3                                          ; FF4E12  cb d8
	jrl nz, .LFF4F6C                                     ; FF4E14  7e 55 01
	cp	(Variant_Flag:8), 0x01                               ; FF4E17  c0 c4 3f 01
	jrl nz, .LFF4F6C                                     ; FF4E1B  7e 4e 01
	cp	(UI_ScreenLatch:16), 0x47                            ; FF4E1E  c1 7a 20 3f 47
	jrl nz, .LFF4F83                                     ; FF4E23  7e 5d 01
	jrl .LFF4F2D                                         ; FF4E26  78 04 01
.LFF4E29:
	pushw 0x0c                                           ; FF4E29  0b 0c 00
	pushw 0x0b                                           ; FF4E2C  0b 0b 00
	calr PanelDial_SetButtonPair                                      ; FF4E2F  1e f8 22
	ld h, (Disk_SeqBank:16)                                   ; FF4E32  c1 2b 27 26
	dec 0x01, (Disk_SeqBank:16)                                ; FF4E36  c1 2b 27 69
	pop XIY                                              ; FF4E3A  5d
	cp h, 0x00:i3                                          ; FF4E3B  ce d8
	jr nz, .LFF4E44                                      ; FF4E3D  6e 05
	ld (Disk_SeqBank:16), 0x00                                 ; FF4E3F  f1 2b 27 00 00
.LFF4E44:
	ld c, (Disk_SeqBank:16)                                   ; FF4E44  c1 2b 27 23
	inc 1,C                                              ; FF4E48  cb 61
	ld (0x2733:16), c                                   ; FF4E4A  f1 33 27 43
	lda xbc, (0xf58415:24)                               ; FF4E4E  f2 15 84 f5 31
	push XBC                                             ; FF4E53  39
	call DLB_Handler_Decimal_Veneer                                      ; FF4E54  1d 68 76 ff
	pop XIY                                              ; FF4E58  5d
	jrl .LFF4F83                                         ; FF4E59  78 27 01
.LFF4E5C:
	cp	(UI_ScreenLatch:16), 0x4c                            ; FF4E5C  c1 7a 20 3f 4c
	jr nz, .LFF4E6C                                      ; FF4E61  6e 09
	ld C,(XIX)                                           ; FF4E63  84 23
	cp C,0x08                                            ; FF4E65  cb cf 08
	jr nc, .LFF4E74                                      ; FF4E68  6f 0a
	jr .LFF4E72                                          ; FF4E6A  68 06
.LFF4E6C:
	ld C,(XIX)                                           ; FF4E6C  84 23
	cp c, 0x04:i3                                          ; FF4E6E  cb dc
	jr nc, .LFF4E74                                      ; FF4E70  6f 02
.LFF4E72:
	incm8 0x01, (xix)                                    ; FF4E72  84 61
.LFF4E74:
	cp	(Variant_Flag:8), 0x02                               ; FF4E74  c0 c4 3f 02
	jr nz, .LFF4E86                                      ; FF4E78  6e 0c
	ld C,(XIX)                                           ; FF4E7A  84 23
	cp c, 0x01:i3                                          ; FF4E7C  cb d9
	jr nz, .LFF4E86                                      ; FF4E7E  6e 06
	ld (XIX),0x02                                        ; FF4E80  b4 00 02
	jrl .LFF4F6C                                         ; FF4E83  78 e6 00
.LFF4E86:
	ld C,(XIX)                                           ; FF4E86  84 23
	cp c, 0x01:i3                                          ; FF4E88  cb d9
	jrl nz, .LFF4F20                                     ; FF4E8A  7e 93 00
	pushw 0x00                                           ; FF4E8D  0b 00 00
	cp	(UI_ScreenLatch:16), 0x4c                            ; FF4E90  c1 7a 20 3f 4c
	jr nz, .LFF4ECC                                      ; FF4E95  6e 35
	lda xbc, (DL_ToS0ngNumber:24)                        ; FF4E97  f2 d0 83 f5 31
	push XBC                                             ; FF4E9C  39
	lda xwa, (DL_FromS0ngNumber:24)                      ; FF4E9D  f2 ba 83 f5 30
	push XWA                                             ; FF4EA2  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF4EA3  1d d3 75 ff
	pushw 0x00                                           ; FF4EA7  0b 00 00
	lda xbc, (DL_FromS0ngNumber:24)                      ; FF4EAA  f2 ba 83 f5 31
	push XBC                                             ; FF4EAF  39
	lda xwa, (DL_F583AB:24)                              ; FF4EB0  f2 ab 83 f5 30
	push XWA                                             ; FF4EB5  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF4EB6  1d d3 75 ff
	ld c, (Disk_SeqBank:16)                                   ; FF4EBA  c1 2b 27 23
	inc 1,C                                              ; FF4EBE  cb 61
	ld (0x2733:16), c                                   ; FF4EC0  f1 33 27 43
	add XSP,0x00000014                                   ; FF4EC4  ef c8 14 00 00 00
	jr .LFF4F0C                                          ; FF4ECA  68 40
.LFF4ECC:
	lda xbc, (DL_FromS0ngNumber:24)                      ; FF4ECC  f2 ba 83 f5 31
	push XBC                                             ; FF4ED1  39
	lda xwa, (DL_F583AB:24)                              ; FF4ED2  f2 ab 83 f5 30
	push XWA                                             ; FF4ED7  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF4ED8  1d d3 75 ff
	push 0x00                                            ; FF4EDC  09 00
	push	(Disk_SelectedEntry:16)                                  ; FF4EDE  c1 24 27 04
	calr DiskEntry_GetPointer                                      ; FF4EE2  1e 2a fa
	inc 8,XIY                                            ; FF4EE5  ed 60
	push XIY                                             ; FF4EE7  3d
	calr DiskEntry_GetContentType                                      ; FF4EE8  1e 4b fa
	ld H,A                                               ; FF4EEB  c9 8e
	inc 8,XSP                                            ; FF4EED  ef 60
	inc 8,XSP                                            ; FF4EEF  ef 60
	pushw 0x00                                           ; FF4EF1  0b 00 00
	lda xbc, (DL_F583E5:24)                              ; FF4EF4  f2 e5 83 f5 31
	push XBC                                             ; FF4EF9  39
	lda xwa, (DL_ToS0ngNumber:24)                        ; FF4EFA  f2 d0 83 f5 30
	push XWA                                             ; FF4EFF  38
	cp h, 0x00:i3                                          ; FF4F00  ce d8
	jr z, .LFF4F53                                       ; FF4F02  66 4f
.LFF4F04:
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF4F04  1d d3 75 ff
	inc 8,XSP                                            ; FF4F08  ef 60
	inc 2,XSP                                            ; FF4F0A  ef 62
.LFF4F0C:
	lda xbc, (DLTab_F5841F:24)                           ; FF4F0C  f2 1f 84 f5 31
	push XBC                                             ; FF4F11  39
	lda xwa, (DL_F5840A:24)                              ; FF4F12  f2 0a 84 f5 30
	push XWA                                             ; FF4F17  38
	call T_DisplayListB_Run_Stack                        ; FF4F18  1d 04 2e f4
	inc 8,XSP                                            ; FF4F1C  ef 60
	jr .LFF4F83                                          ; FF4F1E  68 63
.LFF4F20:
	ld C,(XIX)                                           ; FF4F20  84 23
	cp c, 0x00:i3                                          ; FF4F22  cb d8
	jr nz, .LFF4F6C                                      ; FF4F24  6e 46
	cp	(UI_ScreenLatch:16), 0x47                            ; FF4F26  c1 7a 20 3f 47
	jr nz, .LFF4F6C                                      ; FF4F2B  6e 3f
.LFF4F2D:
	pushw 0x00                                           ; FF4F2D  0b 00 00
	lda xbc, (DL_F583E5:24)                              ; FF4F30  f2 e5 83 f5 31
	push XBC                                             ; FF4F35  39
	lda xwa, (DL_ToS0ngNumber:24)                        ; FF4F36  f2 d0 83 f5 30
	push XWA                                             ; FF4F3B  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF4F3C  1d d3 75 ff
	inc 8,XSP                                            ; FF4F40  ef 60
	inc 2,XSP                                            ; FF4F42  ef 62
	pushw 0x00                                           ; FF4F44  0b 00 00
	lda xbc, (DL_FromS0ngNumber:24)                      ; FF4F47  f2 ba 83 f5 31
	push XBC                                             ; FF4F4C  39
	lda xwa, (DL_F583AB:24)                              ; FF4F4D  f2 ab 83 f5 30
	push XWA                                             ; FF4F52  38
.LFF4F53:
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF4F53  1d d3 75 ff
	inc 8,XSP                                            ; FF4F57  ef 60
	inc 2,XSP                                            ; FF4F59  ef 62
	pushw 0x00                                           ; FF4F5B  0b 00 00
	lda xbc, (0xf59c5b:24)                               ; FF4F5E  f2 5b 9c f5 31
	push XBC                                             ; FF4F63  39
	lda xwa, (DL_F59C4B:24)                              ; FF4F64  f2 4b 9c f5 30
	push XWA                                             ; FF4F69  38
	jr .LFF4F7B                                          ; FF4F6A  68 0f
.LFF4F6C:
	pushw 0x00                                           ; FF4F6C  0b 00 00
	lda xbc, (DL_F5995C:24)                              ; FF4F6F  f2 5c 99 f5 31
	push XBC                                             ; FF4F74  39
	lda xwa, (DL_F59952:24)                              ; FF4F75  f2 52 99 f5 30
	push XWA                                             ; FF4F7A  38
.LFF4F7B:
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF4F7B  1d d3 75 ff
	inc 8,XSP                                            ; FF4F7F  ef 60
	inc 2,XSP                                            ; FF4F81  ef 62
.LFF4F83:
	ld c, (Disk_SeqBank:16)                                   ; FF4F83  c1 2b 27 23
	inc 1,C                                              ; FF4F87  cb 61
	ld (0x2733:16), c                                   ; FF4F89  f1 33 27 43
	lda xbc, (DL_F5840A:24)                              ; FF4F8D  f2 0a 84 f5 31
	push XBC                                             ; FF4F92  39
	lda xwa, (DL_F583F0:24)                              ; FF4F93  f2 f0 83 f5 30
	push XWA                                             ; FF4F98  38
	call T_DisplayListB_Run_Stack                        ; FF4F99  1d 04 2e f4
	jr .LFF4FD4                                          ; FF4F9D  68 35
.LFF4F9F:
	cp	(UI_ScreenLatch:16), 0x4c                            ; FF4F9F  c1 7a 20 3f 4c
	jr z, .LFF4FBB                                       ; FF4FA4  66 15
	push 0x00                                            ; FF4FA6  09 00
	push	(Disk_SelectedEntry:16)                                  ; FF4FA8  c1 24 27 04
	calr DiskEntry_GetPointer                                      ; FF4FAC  1e 60 f9
	inc 8,XIY                                            ; FF4FAF  ed 60
	push XIY                                             ; FF4FB1  3d
	calr DiskEntry_GetContentType                                      ; FF4FB2  1e 81 f9
	inc 6,XSP                                            ; FF4FB5  ef 66
	cp a, 0x00:i3                                          ; FF4FB7  c9 d8
	jr nz, .LFF4FD6                                      ; FF4FB9  6e 1b
.LFF4FBB:
	lda xbc, (DL_F5843F:24)                              ; FF4FBB  f2 3f 84 f5 31
	push XBC                                             ; FF4FC0  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF4FC1  1d 23 76 ff
	ld (UI_ScreenItem:16), 0x02                                 ; FF4FC5  f1 20 27 00 02
	lda xbc, (DL_F583E5:24)                              ; FF4FCA  f2 e5 83 f5 31
	push XBC                                             ; FF4FCF  39
	call DLB_Array8_SaveRegs                                      ; FF4FD0  1d 3f 76 ff
.LFF4FD4:
	inc 8,XSP                                            ; FF4FD4  ef 60
.LFF4FD6:
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF4FD6  1d 15 76 ff
	pop XIX                                              ; FF4FDA  5c
	popw hl                                              ; FF4FDB  4b
	unlk XIZ                                             ; FF4FDC  ee 0d
	ret                                                  ; FF4FDE  0e
; ---------------------------------------------------------------------
; ExitKey_DiskL0adFile -- what Dispatch_FF3900 runs for panel control 0x0F
;
; Reached from: Dispatch_FF3900 entry [15] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0F is the EXIT key. The pair position -- which of the two
;          keys -- reaches the handler in the argument the reader forwards;
;          this pass did NOT establish that argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskL0adFile -- the screen object at PanelScreen_VtableTable
;          entry 0x67, i.e. SCREEN ID 0x47 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4786 as its ENTER method, and that address carries
;          the label Paint_DiskL0adFile -- a name an earlier round derived
;          from the screen's own text.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
ExitKey_DiskL0adFile:
	link XIZ,0x0000                                      ; FF4FDF  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF4FE3  9e 08 21
	and BC,0x0080                                        ; FF4FE6  d9 cc 80 00
	jr nz, .LFF4FF6                                      ; FF4FEA  6e 0a
	ld (UI_Request:16), 0x40                                 ; FF4FEC  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF4FF1  f1 71 20 00 80
.LFF4FF6:
	unlk XIZ                                             ; FF4FF6  ee 0d
	ret                                                  ; FF4FF8  0e
T_F423AC_Nop:
	ret                                                  ; FF4FF9  0e
; ---------------------------------------------------------------------
; Paint_MidiFileL0ad -- paints the screen whose own text reads "MIDI FILE L0AD"
;
; Called from: prom_b T_F42400 (`jp`)
;
; It hands 2 display list(s) to the interpreter ON THE STACK --
;          lda XBC,<end> / push XBC / lda XWA,<start> / push XWA,
;          then the stack veneer.  The lists, and the text each draws:
;     site 0xFF506C  list 0xF5930B-0xF593E9 (222 B, leaves by call)
;        text: "MIDI FILE L0AD"; "L0AD"; "TO S0NG NUMBER  :"; "L0AD AS GM   :"
;     site 0xFF507F  list 0xF593E9-0xF593F3 (10 B, leaves by call)
; From the captions: "MIDI FILE L0AD"; "L0AD"
; Evidence: the list bounds are the two 24-bit IMMEDIATES of the
;          12-byte push idiom at the cited site, and the record
;          length bytes walked from <start> land EXACTLY on <end>
;          (368 of 368 in both images do -- notes/prom_a_dl_stack_map.py).
;          The quoted text is the `.ascii` the interpreter draws
;          verbatim.  Every morpheme of this name occurs in it;
;          notes/prom_a_understanding_round7.py --morphemes checks that.
;          `Paint_` is a structural verb, not ROM text.
; Unknown: whether this routine also handles input for the screen,
;          and whether another routine paints it too.  Neither was
;          searched.  ⚠ The register-form scan of rounds 5 and 6 does
;          not see this call shape at all, which is why this routine
;          was sub_XXXXXX until round 7.
; Named by notes/prom_a_understanding_round7.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_MidiFileL0ad:
	push XIX                                             ; FF4FFA  3c
	lda xix, (UI_ScreenPage:16)                                ; FF4FFB  f1 29 22 34
	call T_CallbackQueue_ResetAndRestartTask2            ; FF4FFF  1d 80 2e f4
	ld (0x21fa:16), 0x00                                 ; FF5003  f1 fa 21 00 00
	ld c, (UI_ScreenLatch:16)                                   ; FF5008  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FF500C  c1 7b 20 f3
	jr z, .LFF5043                                       ; FF5010  66 31
	ld (Disk_SelectedEntry:16), 0x00                                 ; FF5012  f1 24 27 00 00
	ld (0x2732:16), 0xff                                 ; FF5017  f1 32 27 00 ff
	call T_Playback_StopAllAndIgnoreMidiStart                                        ; FF501C  1d 94 25 f4
	ld (XIX),0x00                                        ; FF5020  b4 00 00
	call T_Disk_MountAndScanMidiFilesResetRings                                        ; FF5023  1d 14 26 f4
	ld (0x2730:16), 0x00                                 ; FF5027  f1 30 27 00 00
	calr UI_StatusCode_Is0or2or4                                      ; FF502C  1e 6d 25
	cp wa, 0x00:i3                                         ; FF502F  d8 d8
	jr nz, .LFF504C                                      ; FF5031  6e 19
	set	6, (0x2094:16)                               ; FF5033  f1 94 20 be
	ld (0x272d:16), 0x00                                 ; FF5037  f1 2d 27 00 00
	ld (0x272e:16), 0x00                                 ; FF503C  f1 2e 27 00 00
	jr .LFF5059                                          ; FF5041  68 16
.LFF5043:
	ld C,(XIX)                                           ; FF5043  84 23
	cp c, 0x01:i3                                          ; FF5045  cb d9
	jr nz, .LFF5059                                      ; FF5047  6e 10
	ld (XIX),0x00                                        ; FF5049  b4 00 00
.LFF504C:
	ld (UI_Request:16), 0x40                                 ; FF504C  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF5051  f1 71 20 00 80
	jrl .LFF50E6                                         ; FF5056  78 8d 00
.LFF5059:
	pushw 0x0b                                           ; FF5059  0b 0b 00
	pushw 0x0c                                           ; FF505C  0b 0c 00
	calr PanelDial_SetButtonPair                                      ; FF505F  1e c8 20
	calr MidiFile_CountFileList                                      ; FF5062  1e 83 00
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF5065  1d 04 76 ff
	pushw 0x00                                           ; FF5069  0b 00 00
	lda xbc, (Paint_MidiFileL0ad_DL:24)                              ; FF506C  f2 e9 93 f5 31
	push XBC                                             ; FF5071  39
	lda xwa, (DL_MidiFileL0adL0ad:24)                    ; FF5072  f2 0b 93 f5 30
	push XWA                                             ; FF5077  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF5078  1d d3 75 ff
	pushw 0x02                                           ; FF507C  0b 02 00
	lda xbc, (DL_F593F3:24)                              ; FF507F  f2 f3 93 f5 31
	push XBC                                             ; FF5084  39
	lda xwa, (Paint_MidiFileL0ad_DL:24)                              ; FF5085  f2 e9 93 f5 30
	push XWA                                             ; FF508A  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF508B  1d d3 75 ff
	pushw 0x00                                           ; FF508F  0b 00 00
	pushw 0x0a                                           ; FF5092  0b 0a 00
	calr MidiFile_DrawFileList                                      ; FF5095  1e 80 00
	lda xbc, (DL_F5953B:24)                              ; FF5098  f2 3b 95 f5 31
	push XBC                                             ; FF509D  39
	call DLB_Array8_SaveRegs                                      ; FF509E  1d 3f 76 ff
	ld c, (Disk_SeqBank:16)                                   ; FF50A2  c1 2b 27 23
	inc 1,C                                              ; FF50A6  cb 61
	ld (0x2733:16), c                                   ; FF50A8  f1 33 27 43
	lda xbc, (DL_F59948:24)                              ; FF50AC  f2 48 99 f5 31
	push XBC                                             ; FF50B1  39
	call DLB_Handler_Decimal_Veneer                                      ; FF50B2  1d 68 76 ff
	add XSP,0x00000024                                   ; FF50B6  ef c8 24 00 00 00
	pushw 0x06                                           ; FF50BC  0b 06 00
	pushw 0x03                                           ; FF50BF  0b 03 00
	pushw 0x215d                                         ; FF50C2  0b 5d 21
	cp	(0x2732:16), 0xff                            ; FF50C5  c1 32 27 3f ff
	jr nz, .LFF50D4                                      ; FF50CA  6e 08
	lda xbc, (0xf59538:24)                               ; FF50CC  f2 38 95 f5 31
	push XBC                                             ; FF50D1  39
	jr .LFF50DA                                          ; FF50D2  68 06
.LFF50D4:
	lda xbc, (DLText_F59535:24)                          ; FF50D4  f2 35 95 f5 31
	push XBC                                             ; FF50D9  39
.LFF50DA:
	call LCD_SwiTextCall_SaveRegs                                      ; FF50DA  1d 95 78 ff
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF50DE  1d 15 76 ff
	inc 8,XSP                                            ; FF50E2  ef 60
	inc 2,XSP                                            ; FF50E4  ef 62
.LFF50E6:
	pop XIX                                              ; FF50E6  5c
	ret                                                  ; FF50E7  0e
; MidiFile_CountFileList: UI_ScreenItem := the number of entries in the MIDI file list at 0x60A480 (8-byte names, up
;   to the first that starts with a space, at most 100), or 1 when there are none. Basis: callers + body -- the three
;   MIDI FILE screens call it right before MidiFile_DrawFileList, which reads the same 8-byte entries. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_d.json)
MidiFile_CountFileList:
	pushw hl                                             ; FF50E8  2b
	push XIX                                             ; FF50E9  3c
	ldw hl, 0x00                                         ; FF50EA  33 00 00
	ld XIX,0x00000480                                    ; FF50ED  44 80 04 00 00
.LFF50F2:
	lda xbc, (0x60a000:24)                               ; FF50F2  f2 00 a0 60 31
	add XBC,XIX                                          ; FF50F7  ec 81
	ld A,(XBC)                                           ; FF50F9  81 21
	cp A,0x20                                            ; FF50FB  c9 cf 20
	jr Z,.LFF510A                                        ; FF50FE  66 0a
	inc 8,XIX                                            ; FF5100  ec 60
	inc 1,HL                                             ; FF5102  db 61
	cp HL,0x0064                                         ; FF5104  db cf 64 00
	jr lt, .LFF50F2                                      ; FF5108  61 e8
.LFF510A:
	cp hl, 0x00:i3                                         ; FF510A  db d8
	jr nz, .LFF5111                                      ; FF510C  6e 03
	ldw hl, 0x01                                         ; FF510E  33 01 00
.LFF5111:
	ld (UI_ScreenItem:16), l                                   ; FF5111  f1 20 27 47
	pop XIX                                              ; FF5115  5c
	popw hl                                              ; FF5116  4b
	ret                                                  ; FF5117  0e
; MidiFile_DrawFileList: MidiFile_DrawFileList(rows, rowOffset): per row, the ' NN:' tag and the 8-character name of
;   entry (0x272E) + row from 0x60A480, plus the 'MID' / blank tag. Paint_MidiFileL0ad / _DirectPlay / MidiFileSave
;   page 1 call it with (10, 0); MidiFile_LcdKeyRow4/5 after scrolling. Basis: callers + body. (wsa1/notes/naming-
;   pilot-2026-10-06/proposals_prom_a.json)
MidiFile_DrawFileList:
	link XIZ,0xfff6                                      ; FF5118  ee 0c f6 ff
	pushw hl                                             ; FF511C  2b
	pushw de                                             ; FF511D  2a
	pushw ix                                             ; FF511E  2c
	ld DE,(XIZ+0x0a)                                     ; FF511F  9e 0a 22
	add DE,0x0017                                        ; FF5122  da c8 17 00
	ldw hl, 0x00                                         ; FF5126  33 00 00
	cpw	(xiz+8), 0x0000                              ; FF5129  9e 08 3f 00 00
	jrl le, .LFF5206                                     ; FF512E  72 d5 00
	lda xbc, (0x60a480:24)                               ; FF5131  f2 80 a4 60 31
	ld (xiz-8), xbc                                      ; FF5136  be f8 61
	ld WA,(XIZ+0x08)                                     ; FF5139  9e 08 20
	dec 1,WA                                             ; FF513C  d8 69
	ld (xiz-4), wa                                       ; FF513E  be fc 50
	ldw iy, 0x28                                         ; FF5141  35 28 00
	muls xiy, de                                        ; FF5144  da 4d
	ld (xiz-10), iy                                      ; FF5146  be f6 55
	ld IX,IY                                             ; FF5149  dd 8c
	add IX,0x0009                                        ; FF514B  dc c8 09 00
	add IY,0x000e                                        ; FF514F  dd c8 0e 00
	ld (xiz-2), iy                                       ; FF5153  be fe 55
	ld de, (xiz-10)                                      ; FF5156  9e f6 22
	add DE,0x0016                                        ; FF5159  da c8 16 00
.LFF515D:
	pushw hl                                             ; FF515D  2b
	pushw ix                                             ; FF515E  2c
	call LCD_DrawVar272ENumberTag_SaveRegs                                      ; FF515F  1d 46 78 ff
	pushw 0x06                                           ; FF5163  0b 06 00
	pushw 0x08                                           ; FF5166  0b 08 00
	pushw	(xiz-2)                                      ; FF5169  9e fe 04
	ld bc, (0x272e:16)                                 ; FF516C  d1 2e 27 21
	extz BC                                              ; FF5170  d9 12
	add BC,HL                                            ; FF5172  db 81
	mul BC,0x0008                                        ; FF5174  d9 08 08 00
	add XBC,0x00000480                                   ; FF5178  e9 c8 80 04 00 00
	add XBC,0x0060a000                                   ; FF517E  e9 c8 00 a0 60 00
	push XBC                                             ; FF5184  39
	call LCD_SwiTextCall_SaveRegs                                      ; FF5185  1d 95 78 ff
	ld xbc, (xiz-8)                                      ; FF5189  ae f8 21
	ld A,(XBC)                                           ; FF518C  81 21
	inc 8,XSP                                            ; FF518E  ef 60
	inc 6,XSP                                            ; FF5190  ef 66
	cp A,0x20                                            ; FF5192  c9 cf 20
	jr z, .LFF51F1                                       ; FF5195  66 5a
	cp	(UI_ScreenLatch:16), 0x4e                            ; FF5197  c1 7a 20 3f 4e
	jr nz, .LFF51C7                                      ; FF519C  6e 29
	ld wa, (UI_ScreenItem:16)                                 ; FF519E  d1 20 27 20
	extz WA                                              ; FF51A2  d8 12
	dec 1,WA                                             ; FF51A4  d8 69
	ld (xiz-10), wa                                      ; FF51A6  be f6 50
	ld iy, (Disk_SelectedEntry:16)                                 ; FF51A9  d1 24 27 25
	extz IY                                              ; FF51AD  dd 12
	cp WA,IY                                             ; FF51AF  dd f0
	jr nz, .LFF51C7                                      ; FF51B1  6e 14
	cp	hl, (xiz-4)                                  ; FF51B3  9e fc f3
	jr nz, .LFF51C7                                      ; FF51B6  6e 0f
	pushw 0x06                                           ; FF51B8  0b 06 00
	pushw 0x04                                           ; FF51BB  0b 04 00
	pushw de                                             ; FF51BE  2a
	lda xwa, (0xf58649:24)                               ; FF51BF  f2 49 86 f5 30
	push XWA                                             ; FF51C4  38
	jr .LFF51E9                                          ; FF51C5  68 22
.LFF51C7:
	ld bc, (0x272e:16)                                 ; FF51C7  d1 2e 27 21
	extz BC                                              ; FF51CB  d9 12
	add BC,HL                                            ; FF51CD  db 81
	ld (xiz-10), bc                                      ; FF51CF  be f6 51
	ld wa, (UI_ScreenItem:16)                                 ; FF51D2  d1 20 27 20
	extz WA                                              ; FF51D6  d8 12
	cp WA,BC                                             ; FF51D8  d9 f0
	jr ule, .LFF51F1                                     ; FF51DA  63 15
	pushw 0x06                                           ; FF51DC  0b 06 00
	pushw 0x04                                           ; FF51DF  0b 04 00
	pushw de                                             ; FF51E2  2a
	lda xbc, (DLText_F59857_MID:24)                      ; FF51E3  f2 57 98 f5 31
	push XBC                                             ; FF51E8  39
.LFF51E9:
	call LCD_SwiTextCall_SaveRegs                                      ; FF51E9  1d 95 78 ff
	inc 8,XSP                                            ; FF51ED  ef 60
	inc 2,XSP                                            ; FF51EF  ef 62
.LFF51F1:
	add DE,0x0230                                        ; FF51F1  da c8 30 02
	addw	(xiz-2), 0x0230                              ; FF51F5  9e fe 38 30 02
	add IX,0x0230                                        ; FF51FA  dc c8 30 02
	inc 1,HL                                             ; FF51FE  db 61
	cp HL,(XIZ+0x08)                                     ; FF5200  9e 08 f3
	jrl lt, .LFF515D                                     ; FF5203  71 57 ff
.LFF5206:
	popw ix                                              ; FF5206  4c
	popw de                                              ; FF5207  4a
	popw hl                                              ; FF5208  4b
	unlk XIZ                                             ; FF5209  ee 0d
	ret                                                  ; FF520B  0e
; ---------------------------------------------------------------------
; ScreenLeave_MidiFileL0ad -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0x69, i.e. SCREEN ID 0x49 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x69 -> the screen object at
;          0xF42400, whose +4 slot is `jp 0xFF520C`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the LEAVE method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   MidiFileL0ad -- the same object's +0 ENTER method carries the
;          label Paint_MidiFileL0ad, a name an earlier round derived from the
;          screen's own text.
; Was `sub_FF520C`.
; ---------------------------------------------------------------------
ScreenLeave_MidiFileL0ad:
	ld c, (UI_ScreenLatch:16)                                   ; FF520C  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FF5210  c1 7b 20 f3
	jr z, .LFF522E                                       ; FF5214  66 18
	call DiskFileScreen_LeaveCommon                                      ; FF5216  1d 8c 79 ff
	ld (0x272f:16), 0x00                                 ; FF521A  f1 2f 27 00 00
	ld (0x272e:16), 0x00                                 ; FF521F  f1 2e 27 00 00
	ld (0x272d:16), 0x00                                 ; FF5224  f1 2d 27 00 00
	ld (Disk_SelectedEntry:16), 0x00                                 ; FF5229  f1 24 27 00 00
.LFF522E:
	ret                                                  ; FF522E  0e
; ---------------------------------------------------------------------
; PanelButtonDispatch_MidiFileL0ad -- run Dispatch_FF3980's handler for one
;          PANEL CONTROL
;
; Inputs:   (XIZ+0x08) = the 5-bit panel control index; (XIZ+0x0A) =
;          the argument this reader forwards to the handler.
; Evidence: `cp H,0x20` at 0xFF5237 bounds the index to the 32-code
;          panel space PanelButton_Route's `and L,0x1f`
;          (0xF861AE) produces, and `add XBC,0x00FF3980` at 0xFF5245
;          names the table.
;          The handler is CALLED, not jumped to: the reader pushes
;          a return address before `jp (XBC)`.
; Control legend: notes/FINDINGS-prom_a-panel-control-map.md, and
;          `python3 notes/prom_a_panel_control_map.py --map`.
; Screen:   MidiFileL0ad -- the screen object at PanelScreen_VtableTable
;          entry 0x69, i.e. SCREEN ID 0x49 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4FFA as its ENTER method, and that address carries
;          the label Paint_MidiFileL0ad -- a name an earlier round derived
;          from the screen's own text.
; Was `sub_FF522F`, named by notes/prom_a_naming_wave8_apply.py.
; ---------------------------------------------------------------------
PanelButtonDispatch_MidiFileL0ad:
	link XIZ,0x0000                                      ; FF522F  ee 0c 00 00
	pushw hl                                             ; FF5233  2b
	ld H,(XIZ+0x08)                                      ; FF5234  8e 08 26
	cp H,0x20                                            ; FF5237  ce cf 20
	jr nc, .LFF5256                                      ; FF523A  6f 1a
	pushw	(xiz+10)                                     ; FF523C  9e 0a 04
	ld c, 0x04:opc                                          ; FF523F  23 04
	mul bc, h                                          ; FF5241  ce 43
	extz XBC                                             ; FF5243  e9 12
	add XBC,Dispatch_FF3980                              ; FF5245  e9 c8 80 39 ff 00
	ld XBC,(XBC)                                         ; FF524B  a1 21
	lda xiy, (.LFF5255:24)                               ; FF524D  f2 55 52 ff 35
	push XIY                                             ; FF5252  3d
	jp (xbc)                                             ; FF5253  b1 d8
.LFF5255:
	popw bc                                              ; FF5255  49
.LFF5256:
	popw hl                                              ; FF5256  4b
	unlk XIZ                                             ; FF5257  ee 0d
	ret                                                  ; FF5259  0e
; ---------------------------------------------------------------------
; LcdKeyRow1_MidiFileL0ad -- what Dispatch_FF3980 runs for panel control 0x08
;
; Reached from: Dispatch_FF3980 entry [8] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x08 is the LCD row 1 button pair -- the left-hand and
;          right-hand buttons of the display's TOP row. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileL0ad -- the screen object at PanelScreen_VtableTable
;          entry 0x69, i.e. SCREEN ID 0x49 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4FFA as its ENTER method, and that address carries
;          the label Paint_MidiFileL0ad -- a name an earlier round derived
;          from the screen's own text.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow1_MidiFileL0ad:
	link XIZ,0x0000                                      ; FF525A  ee 0c 00 00
	pushw hl                                             ; FF525E  2b
	push XIX                                             ; FF525F  3c
	lda xix, (UI_Request:16)                                ; FF5260  f1 70 20 34
	ld BC,(XIZ+0x08)                                     ; FF5264  9e 08 21
	and BC,0x0080                                        ; FF5267  d9 cc 80 00
	jr z, .LFF527F                                       ; FF526B  66 12
	lda xbc, (DL_F593FE:24)                              ; FF526D  f2 fe 93 f5 31
	push XBC                                             ; FF5272  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF5273  1d 23 76 ff
	ld (0x2730:16), 0x00                                 ; FF5277  f1 30 27 00 00
	pop XIY                                              ; FF527C  5d
	jr .LFF52DD                                          ; FF527D  68 5e
.LFF527F:
	res	3, (UI_RequestBits:16)                               ; FF527F  f1 75 20 b3
	ld bc, (Disk_SelectedEntry:16)                                 ; FF5283  d1 24 27 21
	extz BC                                              ; FF5287  d9 12
	pushw bc                                             ; FF5289  29
	calr MidiFileList_CopyEntryToFileName                                      ; FF528A  1e cf f4
	ld c, (Disk_FileName:16)                                   ; FF528D  c1 c8 21 23
	popw wa                                              ; FF5291  48
	cp C,0x20                                            ; FF5292  cb cf 20
	jr z, .LFF52DD                                       ; FF5295  66 46
	call T_MidiFileL0ad_LcdKeyRow1                                        ; FF5297  1d 80 33 f4
	call SC1_CmdEFAndClearHeldButtons                                      ; FF529B  1d 59 79 ff
	cp	(UI_StatusCode:16), 0x23                            ; FF529F  c1 80 28 3f 23
	jr z, .LFF52B0                                       ; FF52A4  66 0a
	ld (XIX),0xab                                        ; FF52A6  b4 00 ab
	ld (UI_Request_Hi:16), 0x40                                 ; FF52A9  f1 71 20 00 40
	jr .LFF52DD                                          ; FF52AE  68 2d
.LFF52B0:
	ld xbc, (0x60341e:24)                               ; FF52B0  e2 1e 34 60 21
	or XBC,XBC                                           ; FF52B5  e9 e1
	jr z, .LFF52D5                                       ; FF52B7  66 1c
	ld h, 0x00:opc                                          ; FF52B9  26 00
.LFF52BB:
	ld C,H                                               ; FF52BB  ce 8b
	exts BC                                              ; FF52BD  d9 13
	exts XBC                                             ; FF52BF  e9 13
	add XBC,BStore_SongName                                   ; FF52C1  e9 c8 ca 34 60 00
	ld (XBC),0x5f                                        ; FF52C7  b1 00 5f
	inc 1,H                                              ; FF52CA  ce 61
	cp h, 0x06:i3                                          ; FF52CC  ce de
	jr lt, .LFF52BB                                      ; FF52CE  61 eb
	ld (XIX),0x08                                        ; FF52D0  b4 00 08
	jr .LFF52D8                                          ; FF52D3  68 03
.LFF52D5:
	ld (XIX),0x01                                        ; FF52D5  b4 00 01
.LFF52D8:
	ld (UI_Request_Hi:16), 0x02                                 ; FF52D8  f1 71 20 00 02
.LFF52DD:
	pop XIX                                              ; FF52DD  5c
	popw hl                                              ; FF52DE  4b
	unlk XIZ                                             ; FF52DF  ee 0d
	ret                                                  ; FF52E1  0e
; ---------------------------------------------------------------------
; LcdKeyRow2_MidiFileL0ad -- what Dispatch_FF3980 runs for panel control 0x09
;
; Reached from: Dispatch_FF3980 entry [9] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x09 is the LCD row 2 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileL0ad -- the screen object at PanelScreen_VtableTable
;          entry 0x69, i.e. SCREEN ID 0x49 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4FFA as its ENTER method, and that address carries
;          the label Paint_MidiFileL0ad -- a name an earlier round derived
;          from the screen's own text.
; Unknown:  what this screen does with the button.
; Was `sub_FF52E2`.
; ---------------------------------------------------------------------
LcdKeyRow2_MidiFileL0ad:
	link XIZ,0x0000                                      ; FF52E2  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF52E6  9e 08 21
	and BC,0x0080                                        ; FF52E9  d9 cc 80 00
	jr z, .LFF52FF                                       ; FF52ED  66 10
	lda xbc, (DL_F593FE:24)                              ; FF52EF  f2 fe 93 f5 31
	push XBC                                             ; FF52F4  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF52F5  1d 23 76 ff
	ld (0x2730:16), 0x00                                 ; FF52F9  f1 30 27 00 00
	pop XIY                                              ; FF52FE  5d
.LFF52FF:
	unlk XIZ                                             ; FF52FF  ee 0d
	ret                                                  ; FF5301  0e
; ---------------------------------------------------------------------
; LcdKeyRow3_MidiFileL0ad -- what Dispatch_FF3980 runs for panel control 0x0A
;
; Reached from: Dispatch_FF3980 entry [10] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0A is the LCD row 3 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileL0ad -- the screen object at PanelScreen_VtableTable
;          entry 0x69, i.e. SCREEN ID 0x49 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4FFA as its ENTER method, and that address carries
;          the label Paint_MidiFileL0ad -- a name an earlier round derived
;          from the screen's own text.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow3_MidiFileL0ad:
	link XIZ,0x0000                                      ; FF5302  ee 0c 00 00
	pushw	(xiz+8)                                      ; FF5306  9e 08 04
	calr LcdKeyRow2_MidiFileL0ad                                      ; FF5309  1e d6 ff
	popw bc                                              ; FF530C  49
	unlk XIZ                                             ; FF530D  ee 0d
	ret                                                  ; FF530F  0e
; ---------------------------------------------------------------------
; LcdKeyRow4_MidiFileL0ad -- what Dispatch_FF3980 runs for panel control 0x0B
;
; Reached from: Dispatch_FF3980 entry [11] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0B is the LCD row 4 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileL0ad -- the screen object at PanelScreen_VtableTable
;          entry 0x69, i.e. SCREEN ID 0x49 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4FFA as its ENTER method, and that address carries
;          the label Paint_MidiFileL0ad -- a name an earlier round derived
;          from the screen's own text.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow4_MidiFileL0ad:
	link XIZ,0x0000                                      ; FF5310  ee 0c 00 00
	push XIX                                             ; FF5314  3c
	lda xix, (Disk_SeqBank:16)                                ; FF5315  f1 2b 27 34
	set	3, (UI_RequestBits:16)                               ; FF5319  f1 75 20 bb
	ld BC,(XIZ+0x08)                                     ; FF531D  9e 08 21
	and BC,0x0080                                        ; FF5320  d9 cc 80 00
	jrl nz, .LFF53A7                                     ; FF5324  7e 80 00
	ld bc, (0x2730:16)                                 ; FF5327  d1 30 27 21
	extz BC                                              ; FF532B  d9 12
	cp bc, 0x00:i3                                         ; FF532D  d9 d8
	jr z, .LFF533C                                       ; FF532F  66 0b
	cp bc, 0x01:i3                                         ; FF5331  d9 d9
	jr z, .LFF5365                                       ; FF5333  66 30
	cp bc, 0x02:i3                                         ; FF5335  d9 da
	jr z, .LFF5382                                       ; FF5337  66 49
	jrl .LFF53C2                                         ; FF5339  78 86 00
.LFF533C:
	lda xbc, (DL_F593FE:24)                              ; FF533C  f2 fe 93 f5 31
	push XBC                                             ; FF5341  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF5342  1d 23 76 ff
	lda xbc, (DL_F59546:24)                              ; FF5346  f2 46 95 f5 31
	push XBC                                             ; FF534B  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF534C  1d 23 76 ff
	pushw 0x00                                           ; FF5350  0b 00 00
	pushw 0x0a                                           ; FF5353  0b 0a 00
	calr MidiFile_LcdKeyRow4                                      ; FF5356  1e 2f 10
	inc 8,XSP                                            ; FF5359  ef 60
	inc 4,XSP                                            ; FF535B  ef 64
	lda xbc, (DL_F5953B:24)                              ; FF535D  f2 3b 95 f5 31
	push XBC                                             ; FF5362  39
	jr .LFF53BD                                          ; FF5363  68 58
.LFF5365:
	ld C,(XIX)                                           ; FF5365  84 23
	cp C,0x09                                            ; FF5367  cb cf 09
	jr nc, .LFF536E                                      ; FF536A  6f 02
	incm8 0x01, (xix)                                    ; FF536C  84 61
.LFF536E:
	ld C,(XIX)                                           ; FF536E  84 23
	inc 1,C                                              ; FF5370  cb 61
	ld (0x2733:16), c                                   ; FF5372  f1 33 27 43
	lda xbc, (DL_F59948:24)                              ; FF5376  f2 48 99 f5 31
	push XBC                                             ; FF537B  39
	call DLB_Handler_Decimal_Veneer                                      ; FF537C  1d 68 76 ff
	jr .LFF53C1                                          ; FF5380  68 3f
.LFF5382:
	cp	(0x2732:16), 0x00                            ; FF5382  c1 32 27 3f 00
	jr nz, .LFF53C2                                      ; FF5387  6e 39
	ld (0x2732:16), 0xff                                 ; FF5389  f1 32 27 00 ff
	pushw 0x06                                           ; FF538E  0b 06 00
	pushw 0x03                                           ; FF5391  0b 03 00
	pushw 0x215d                                         ; FF5394  0b 5d 21
	lda xbc, (0xf59538:24)                               ; FF5397  f2 38 95 f5 31
	push XBC                                             ; FF539C  39
	call LCD_SwiTextCall_SaveRegs                                      ; FF539D  1d 95 78 ff
	inc 8,XSP                                            ; FF53A1  ef 60
	inc 2,XSP                                            ; FF53A3  ef 62
	jr .LFF53C2                                          ; FF53A5  68 1b
.LFF53A7:
	lda xbc, (DL_F593FE:24)                              ; FF53A7  f2 fe 93 f5 31
	push XBC                                             ; FF53AC  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF53AD  1d 23 76 ff
	ld (0x2730:16), 0x01                                 ; FF53B1  f1 30 27 00 01
	pop XIY                                              ; FF53B6  5d
	lda xbc, (DL_F593F3:24)                              ; FF53B7  f2 f3 93 f5 31
	push XBC                                             ; FF53BC  39
.LFF53BD:
	call DLB_Array8_SaveRegs                                      ; FF53BD  1d 3f 76 ff
.LFF53C1:
	pop XIY                                              ; FF53C1  5d
.LFF53C2:
	pop XIX                                              ; FF53C2  5c
	unlk XIZ                                             ; FF53C3  ee 0d
	ret                                                  ; FF53C5  0e
; ---------------------------------------------------------------------
; LcdKeyRow5_MidiFileL0ad -- what Dispatch_FF3980 runs for panel control 0x0C
;
; Reached from: Dispatch_FF3980 entry [12] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0C is the LCD row 5 button pair -- the BOTTOM row. The
;          pair position -- which of the two keys -- reaches the handler in
;          the argument the reader forwards; this pass did NOT establish that
;          argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileL0ad -- the screen object at PanelScreen_VtableTable
;          entry 0x69, i.e. SCREEN ID 0x49 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4FFA as its ENTER method, and that address carries
;          the label Paint_MidiFileL0ad -- a name an earlier round derived
;          from the screen's own text.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow5_MidiFileL0ad:
	link XIZ,0x0000                                      ; FF53C6  ee 0c 00 00
	push XIX                                             ; FF53CA  3c
	lda xix, (Disk_SeqBank:16)                                ; FF53CB  f1 2b 27 34
	set	3, (UI_RequestBits:16)                               ; FF53CF  f1 75 20 bb
	ld BC,(XIZ+0x08)                                     ; FF53D3  9e 08 21
	and BC,0x0080                                        ; FF53D6  d9 cc 80 00
	jrl nz, .LFF5450                                     ; FF53DA  7e 73 00
	ld bc, (0x2730:16)                                 ; FF53DD  d1 30 27 21
	extz BC                                              ; FF53E1  d9 12
	cp bc, 0x00:i3                                         ; FF53E3  d9 d8
	jr z, .LFF53F2                                       ; FF53E5  66 0b
	cp bc, 0x01:i3                                         ; FF53E7  d9 d9
	jr z, .LFF540F                                       ; FF53E9  66 24
	cp bc, 0x02:i3                                         ; FF53EB  d9 da
	jr z, .LFF542B                                       ; FF53ED  66 3c
	jrl .LFF546B                                         ; FF53EF  78 79 00
.LFF53F2:
	lda xbc, (DL_F59546:24)                              ; FF53F2  f2 46 95 f5 31
	push XBC                                             ; FF53F7  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF53F8  1d 23 76 ff
	pushw 0x00                                           ; FF53FC  0b 00 00
	pushw 0x0a                                           ; FF53FF  0b 0a 00
	calr MidiFile_LcdKeyRow5                                      ; FF5402  1e c3 0f
	inc 8,XSP                                            ; FF5405  ef 60
	lda xbc, (DL_F5953B:24)                              ; FF5407  f2 3b 95 f5 31
	push XBC                                             ; FF540C  39
	jr .LFF5466                                          ; FF540D  68 57
.LFF540F:
	ld C,(XIX)                                           ; FF540F  84 23
	cp c, 0x00:i3                                          ; FF5411  cb d8
	jr z, .LFF5417                                       ; FF5413  66 02
	decm8 0x01, (xix)                                    ; FF5415  84 69
.LFF5417:
	ld C,(XIX)                                           ; FF5417  84 23
	inc 1,C                                              ; FF5419  cb 61
	ld (0x2733:16), c                                   ; FF541B  f1 33 27 43
	lda xbc, (DL_F59948:24)                              ; FF541F  f2 48 99 f5 31
	push XBC                                             ; FF5424  39
	call DLB_Handler_Decimal_Veneer                                      ; FF5425  1d 68 76 ff
	jr .LFF546A                                          ; FF5429  68 3f
.LFF542B:
	cp	(0x2732:16), 0xff                            ; FF542B  c1 32 27 3f ff
	jr nz, .LFF546B                                      ; FF5430  6e 39
	ld (0x2732:16), 0x00                                 ; FF5432  f1 32 27 00 00
	pushw 0x06                                           ; FF5437  0b 06 00
	pushw 0x03                                           ; FF543A  0b 03 00
	pushw 0x215d                                         ; FF543D  0b 5d 21
	lda xbc, (DLText_F59535:24)                          ; FF5440  f2 35 95 f5 31
	push XBC                                             ; FF5445  39
	call LCD_SwiTextCall_SaveRegs                                      ; FF5446  1d 95 78 ff
	inc 8,XSP                                            ; FF544A  ef 60
	inc 2,XSP                                            ; FF544C  ef 62
	jr .LFF546B                                          ; FF544E  68 1b
.LFF5450:
	lda xbc, (DL_F593FE:24)                              ; FF5450  f2 fe 93 f5 31
	push XBC                                             ; FF5455  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF5456  1d 23 76 ff
	ld (0x2730:16), 0x02                                 ; FF545A  f1 30 27 00 02
	pop XIY                                              ; FF545F  5d
	lda xbc, (DL_F593F3:24)                              ; FF5460  f2 f3 93 f5 31
	push XBC                                             ; FF5465  39
.LFF5466:
	call DLB_Array8_SaveRegs                                      ; FF5466  1d 3f 76 ff
.LFF546A:
	pop XIY                                              ; FF546A  5d
.LFF546B:
	pop XIX                                              ; FF546B  5c
	unlk XIZ                                             ; FF546C  ee 0d
	ret                                                  ; FF546E  0e
; ---------------------------------------------------------------------
; ExitKey_MidiFileL0ad -- what Dispatch_FF3980 runs for panel control 0x0F
;
; Reached from: Dispatch_FF3980 entry [15] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0F is the EXIT key. The pair position -- which of the two
;          keys -- reaches the handler in the argument the reader forwards;
;          this pass did NOT establish that argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileL0ad -- the screen object at PanelScreen_VtableTable
;          entry 0x69, i.e. SCREEN ID 0x49 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF4FFA as its ENTER method, and that address carries
;          the label Paint_MidiFileL0ad -- a name an earlier round derived
;          from the screen's own text.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
ExitKey_MidiFileL0ad:
	link XIZ,0x0000                                      ; FF546F  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF5473  9e 08 21
	and BC,0x0080                                        ; FF5476  d9 cc 80 00
	jr nz, .LFF5486                                      ; FF547A  6e 0a
	ld (UI_Request:16), 0x40                                 ; FF547C  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF5481  f1 71 20 00 80
.LFF5486:
	unlk XIZ                                             ; FF5486  ee 0d
	ret                                                  ; FF5488  0e
T_F4240C_Nop:
	ret                                                  ; FF5489  0e
; ---------------------------------------------------------------------
; PageDispatch_DiskSaveFile -- run ScreenEnterPages_DiskSaveFile's entry for the CURRENT
;          PAGE
;
; ★ NOT a panel-control table.  This reader indexes with the page
;          byte (0x2229) ALONE and never reads an argument, so its
;          6 entries are pages of one screen and not buttons.
; Evidence: `cp (0x2229),0x06` at 0xFF548A is the bound, the index is
;          `(0x2229) * 4` (`m_mul MB16,0x2229,3` -- the operand is
;          width-1), and `add XBC,0x00FF3A00` at 0xFF5499 names the table.
;          The entry is CALLED: a return address is pushed before
;          `jp (XBC)`.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its ENTER
;          method, and its BUTTON method is that screen's control table.
; Was `sub_FF548A`, named by notes/prom_a_naming_wave8_apply.py.
; ---------------------------------------------------------------------
PageDispatch_DiskSaveFile:
	cp	(UI_ScreenPage:16), 0x06                            ; FF548A  c1 29 22 3f 06
	jr nc, .LFF54A9                                      ; FF548F  6f 18
	ld c, 0x04:opc                                          ; FF5491  23 04
	mul	bc, (UI_ScreenPage:16)                              ; FF5493  c1 29 22 43
	extz XBC                                             ; FF5497  e9 12
	add XBC,ScreenEnterPages_DiskSaveFile                              ; FF5499  e9 c8 00 3a ff 00
	ld XBC,(XBC)                                         ; FF549F  a1 21
	lda xiy, (.LFF54A9:24)                               ; FF54A1  f2 a9 54 ff 35
	push XIY                                             ; FF54A6  3d
	jp (xbc)                                             ; FF54A7  b1 d8
.LFF54A9:
	ret                                                  ; FF54A9  0e
; ScreenEnter_DiskSaveFile_Page0: ScreenEnterPages_DiskSaveFile[0] -- what PageDispatch_DiskSaveFile, the ENTER method of the DiskSaveFile screen, runs
;   when UI_ScreenPage is 0 (notes/prom_a_page_enter_names.py).
ScreenEnter_DiskSaveFile_Page0:   ; entry: named by 1 `.long` operand, first at 0xFF3A00
	push XHL                                             ; FF54AA  3b
	call T_CallbackQueue_ResetAndRestartTask2            ; FF54AB  1d 80 2e f4
	ld c, (UI_ScreenLatch:16)                                   ; FF54AF  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FF54B3  c1 7b 20 f3
	jr z, .LFF54E4                                       ; FF54B7  66 2b
	call T_Playback_StopAllAndIgnoreMidiStart                                        ; FF54B9  1d 94 25 f4
	set	6, (0x2094:16)                               ; FF54BD  f1 94 20 be
	call T_F42610                                        ; FF54C1  1d 10 26 f4
	ldw hl, 0x00                                         ; FF54C5  33 00 00
.LFF54C8:
	extz XHL                                             ; FF54C8  eb 12
	ld C,(XHL+Disk_FileName)                                    ; FF54CA  c3 ed c8 21 23
	cp C,0x20                                            ; FF54CF  cb cf 20
	jr nz, .LFF54DC                                      ; FF54D2  6e 08
	extz XHL                                             ; FF54D4  eb 12
	ld (XHL+Disk_FileName),0x5f                                 ; FF54D6  f3 ed c8 21 00 5f
.LFF54DC:
	inc 1,HL                                             ; FF54DC  db 61
	cp HL,0x0008                                         ; FF54DE  db cf 08 00
	jr lt, .LFF54C8                                      ; FF54E2  61 e4
.LFF54E4:
	ld (NameEdit_CursorPos:16), 0x03                                 ; FF54E4  f1 2d 22 00 03
	ld (0x2721:16), 0x02                                 ; FF54E9  f1 21 27 00 02
	call T_NameEdit_SyncCharIndex_Call                                        ; FF54EE  1d f8 25 f4
	cp	(Disk_SelectedEntry:16), 0x13                            ; FF54F2  c1 24 27 3f 13
	jr ule, .LFF54FE                                     ; FF54F7  63 05
	ld (Disk_SelectedEntry:16), 0x00                                 ; FF54F9  f1 24 27 00 00
.LFF54FE:
	pushw 0x03                                           ; FF54FE  0b 03 00
	pushw 0x04                                           ; FF5501  0b 04 00
	calr PanelDial_SetButtonPair                                      ; FF5504  1e 23 1c
	ld c, (NameEdit_CharIndex:16)                                   ; FF5507  c1 f9 21 23
	ld (0x2729:16), c                                   ; FF550B  f1 29 27 43
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF550F  1d 04 76 ff
	pushw 0x00                                           ; FF5513  0b 00 00
	lda xbc, (DL_F58786:24)                              ; FF5516  f2 86 87 f5 31
	push XBC                                             ; FF551B  39
	lda xwa, (DL_DiskSaveFileNaming:24)                  ; FF551C  f2 56 86 f5 30
	push XWA                                             ; FF5521  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF5522  1d d3 75 ff
	call LCD_DrawDiskFileName6_SaveRegs                                      ; FF5526  1d 0f 77 ff
	lda xbc, (DL_F5879C:24)                              ; FF552A  f2 9c 87 f5 31
	push XBC                                             ; FF552F  39
	lda xwa, (DL_F58786:24)                              ; FF5530  f2 86 87 f5 30
	push XWA                                             ; FF5535  38
	call T_DisplayListB_Run_Stack                        ; FF5536  1d 04 2e f4
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF553A  1d 15 76 ff
	add XSP,0x00000016                                   ; FF553E  ef c8 16 00 00 00
	pop XHL                                              ; FF5544  5b
	ret                                                  ; FF5545  0e
; ScreenEnter_DiskSaveFile_Page1: ScreenEnterPages_DiskSaveFile[1] -- what PageDispatch_DiskSaveFile, the ENTER method of the DiskSaveFile screen, runs
;   when UI_ScreenPage is 1 (notes/prom_a_page_enter_names.py).
ScreenEnter_DiskSaveFile_Page1:   ; entry: named by 1 `.long` operand, first at 0xFF3A04
	call T_CallbackQueue_ResetAndRestartTask2            ; FF5546  1d 80 2e f4
	pushw 0x0b                                           ; FF554A  0b 0b 00
	pushw 0x0c                                           ; FF554D  0b 0c 00
	calr PanelDial_SetButtonPair                                      ; FF5550  1e d7 1b
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF5553  1d 04 76 ff
	ld (Disk_ContentType:16), 0x00                                 ; FF5557  f1 25 27 00 00
	ld (UI_ScreenItem:16), 0x00                                 ; FF555C  f1 20 27 00 00
	pop XIY                                              ; FF5561  5d
	pushw 0x00                                           ; FF5562  0b 00 00
	ld c, (0x2726:16)                                   ; FF5565  c1 26 27 23
	and C,0x01                                           ; FF5569  cb cc 01
	jr z, .LFF557C                                       ; FF556C  66 0e
	lda xbc, (DL_FloppyDisk:24)                          ; FF556E  f2 88 82 f5 31
	push XBC                                             ; FF5573  39
	lda xwa, (DL_SaveSaveFileDelSave0pti0n:24)           ; FF5574  f2 40 82 f5 30
	push XWA                                             ; FF5579  38
; ---------------------------------------------------------------------
; Paint_DiskSaveFile -- paints the screen whose own text reads "SAVE FILE" / "SAVE 0PTI0N" over the FLOPPY DISK file list
;
; Called from: nothing in either image names this address.
;
; It hands 3 display list(s) to the interpreter ON THE STACK --
;          lda XBC,<end> / push XBC / lda XWA,<start> / push XWA,
;          then the stack veneer.  The lists, and the text each draws:
;     site 0xFF557C  list 0xF581F8-0xF58240 (72 B, leaves by call)
;        text: "SAVE"; "SAVE FILE"; "SAVE"; "SAVE 0PTI0N"
;     site 0xFF558F  list 0xF58288-0xF583AB (291 B, leaves by call)
;        text: "FLOPPY"; "DISK"; "01 :"; "02 :"; "03 :"; "04 :"; "1O :"; "11 :"; ...
;     site 0xFF55A3  list 0xF583E5-0xF5840A (37 B, leaves by call)
;        text: "$'?"
; From the captions: "DISK"; "SAVE"; "SAVE FILE"
; Evidence: the list bounds are the two 24-bit IMMEDIATES of the
;          12-byte push idiom at the cited site, and the record
;          length bytes walked from <start> land EXACTLY on <end>
;          (368 of 368 in both images do -- notes/prom_a_dl_stack_map.py).
;          The quoted text is the `.ascii` the interpreter draws
;          verbatim.  Every morpheme of this name occurs in it;
;          notes/prom_a_understanding_round7.py --morphemes checks that.
;          `Paint_` is a structural verb, not ROM text.
; Unknown: whether this routine also handles input for the screen,
;          and whether another routine paints it too.  Neither was
;          searched.  ⚠ The register-form scan of rounds 5 and 6 does
;          not see this call shape at all, which is why this routine
;          was sub_XXXXXX until round 7.
; Named by notes/prom_a_understanding_round7.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_DiskSaveFile:
	jr .LFF5588                                          ; FF557A  68 0c
.LFF557C:
	lda xbc, (DL_SaveSaveFileDelSave0pti0n:24)           ; FF557C  f2 40 82 f5 31
	push XBC                                             ; FF5581  39
	lda xwa, (DL_SaveSaveFileSaveSave0pti0n:24)          ; FF5582  f2 f8 81 f5 30
	push XWA                                             ; FF5587  38
.LFF5588:
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF5588  1d d3 75 ff
	pushw 0x00                                           ; FF558C  0b 00 00
	lda xbc, (DL_F583AB:24)                              ; FF558F  f2 ab 83 f5 31
	push XBC                                             ; FF5594  39
	lda xwa, (DL_FloppyDisk:24)                          ; FF5595  f2 88 82 f5 30
	push XWA                                             ; FF559A  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF559B  1d d3 75 ff
	call Disk_DrawDirectory20                                      ; FF559F  1d 7f 76 ff
	lda xbc, (DL_F5840A:24)                              ; FF55A3  f2 0a 84 f5 31
	push XBC                                             ; FF55A8  39
	lda xwa, (DL_F583E5:24)                              ; FF55A9  f2 e5 83 f5 30
	push XWA                                             ; FF55AE  38
	call DisplayListB_Run_SaveRegs                                      ; FF55AF  1d ef 75 ff
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF55B3  1d 15 76 ff
	add XSP,0x0000001c                                   ; FF55B7  ef c8 1c 00 00 00
	ret                                                  ; FF55BD  0e
; ScreenEnter_DiskSaveFile_Page2: ScreenEnterPages_DiskSaveFile[2] -- what PageDispatch_DiskSaveFile, the ENTER method of the DiskSaveFile screen, runs
;   when UI_ScreenPage is 2 (notes/prom_a_page_enter_names.py).
ScreenEnter_DiskSaveFile_Page2:   ; entry: named by 1 `.long` operand, first at 0xFF3A08
	push XIX                                             ; FF55BE  3c
	lda xix, (DisplayList_RunOnLayer_SaveRegs:24)                             ; FF55BF  f2 d3 75 ff 34
	call T_CallbackQueue_ResetAndRestartTask2            ; FF55C4  1d 80 2e f4
	call T_Playback_StopAllAndIgnoreMidiStart                                        ; FF55C8  1d 94 25 f4
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF55CC  1d 04 76 ff
	pushw 0x00                                           ; FF55D0  0b 00 00
	lda xbc, (DL_AttentionAFileAlreadyExistsAtThe:24)    ; FF55D3  f2 86 9b f5 31
	push XBC                                             ; FF55D8  39
	lda xwa, (DL_DiskSave:24)                            ; FF55D9  f2 79 9b f5 30
	push XWA                                             ; FF55DE  38
	lda xiy, (.LFF55E7:24)                               ; FF55DF  f2 e7 55 ff 35
	push XIY                                             ; FF55E4  3d
	jp (xix)                                             ; FF55E5  b4 d8
.LFF55E7:
	pushw 0x00                                           ; FF55E7  0b 00 00
	lda xbc, (DL_LoadL0adFileLoadL0ad0pti0n:24)          ; FF55EA  f2 b0 81 f5 31
	push XBC                                             ; FF55EF  39
	lda xwa, (DL_F58162:24)                              ; FF55F0  f2 62 81 f5 30
	push XWA                                             ; FF55F5  38
	lda xiy, (.LFF55FE:24)                               ; FF55F6  f2 fe 55 ff 35
	push XIY                                             ; FF55FB  3d
	jp (xix)                                             ; FF55FC  b4 d8
.LFF55FE:
	pushw 0x00                                           ; FF55FE  0b 00 00
	lda xbc, (DLText_F59C2C:24)                          ; FF5601  f2 2c 9c f5 31
	push XBC                                             ; FF5606  39
	lda xwa, (DL_AttentionAFileAlreadyExistsAtThe:24)    ; FF5607  f2 86 9b f5 30
	push XWA                                             ; FF560C  38
	lda xiy, (.LFF5615:24)                               ; FF560D  f2 15 56 ff 35
	push XIY                                             ; FF5612  3d
	jp (xix)                                             ; FF5613  b4 d8
.LFF5615:
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF5615  1d 15 76 ff
	add XSP,0x0000001e                                   ; FF5619  ef c8 1e 00 00 00
	pop XIX                                              ; FF561F  5c
	ret                                                  ; FF5620  0e
; ScreenEnter_DiskSaveFile_Page3: ScreenEnterPages_DiskSaveFile[3] -- what PageDispatch_DiskSaveFile, the ENTER method of the DiskSaveFile screen, runs
;   when UI_ScreenPage is 3 (notes/prom_a_page_enter_names.py).
ScreenEnter_DiskSaveFile_Page3:   ; entry: named by 1 `.long` operand, first at 0xFF3A0C
	call T_CallbackQueue_ResetAndRestartTask2            ; FF5621  1d 80 2e f4
	pushw 0x10                                           ; FF5625  0b 10 00
	lda xbc, (Text_FF3A18:24)                            ; FF5628  f2 18 3a ff 31
	push XBC                                             ; FF562D  39
	lda xwa, (DiskSave_PasswordEntry:16)                                ; FF562E  f1 f0 22 30
	push XWA                                             ; FF5632  38
	call MemCpy_C                                      ; FF5633  1d b5 78 ff
	pushw 0x02                                           ; FF5637  0b 02 00
	call T_NameEntry_Begin                                        ; FF563A  1d 80 2f f4
	pushw 0x00                                           ; FF563E  0b 00 00
	lda xbc, (DL_F5999A:24)                              ; FF5641  f2 9a 99 f5 31
	push XBC                                             ; FF5646  39
	lda xwa, (DL_DiskSavePasswordSave:24)                ; FF5647  f2 66 99 f5 30
	push XWA                                             ; FF564C  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF564D  1d d3 75 ff
	pushw 0x00                                           ; FF5651  0b 00 00
	lda xbc, (DL_PasswordIsAlreadySetPleaseSetThe:24)    ; FF5654  f2 b5 99 f5 31
	push XBC                                             ; FF5659  39
	lda xwa, (DL_F5999A:24)                              ; FF565A  f2 9a 99 f5 30
	push XWA                                             ; FF565F  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF5660  1d d3 75 ff
	add XSP,0x00000020                                   ; FF5664  ef c8 20 00 00 00
	ret                                                  ; FF566A  0e
; ScreenEnter_DiskSaveFile_Page4: ScreenEnterPages_DiskSaveFile[4] -- what PageDispatch_DiskSaveFile, the ENTER method of the DiskSaveFile screen, runs
;   when UI_ScreenPage is 4 (notes/prom_a_page_enter_names.py).
ScreenEnter_DiskSaveFile_Page4:   ; entry: named by 1 `.long` operand, first at 0xFF3A10
	push XIX                                             ; FF566B  3c
	lda xix, (DiskSave_PasswordEntry:16)                                ; FF566C  f1 f0 22 34
	call T_CallbackQueue_ResetAndRestartTask2            ; FF5670  1d 80 2e f4
	pushw 0x10                                           ; FF5674  0b 10 00
	lda xbc, (Text_FF3A18:24)                            ; FF5677  f2 18 3a ff 31
	push XBC                                             ; FF567C  39
	push XIX                                             ; FF567D  3c
	call MemCpy_C                                      ; FF567E  1d b5 78 ff
	ld (XIX),0x5f                                        ; FF5682  b4 00 5f
	extz XIX                                             ; FF5685  ec 12
	ld (XIX+0x01),0x5f                                   ; FF5687  bc 01 00 5f
	pushw 0x02                                           ; FF568B  0b 02 00
	call T_NameEntry_Begin                                        ; FF568E  1d 80 2f f4
	pushw 0x00                                           ; FF5692  0b 00 00
	lda xbc, (DL_F5999A:24)                              ; FF5695  f2 9a 99 f5 31
	push XBC                                             ; FF569A  39
	lda xwa, (DL_DiskSavePasswordSave:24)                ; FF569B  f2 66 99 f5 30
	push XWA                                             ; FF56A0  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF56A1  1d d3 75 ff
	pushw 0x00                                           ; FF56A5  0b 00 00
	lda xbc, (CharTable_F599F5:24)                       ; FF56A8  f2 f5 99 f5 31
	push XBC                                             ; FF56AD  39
	lda xwa, (DL_PasswordIsAlreadySetPleaseSetThe:24)    ; FF56AE  f2 b5 99 f5 30
	push XWA                                             ; FF56B3  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF56B4  1d d3 75 ff
	add XSP,0x00000020                                   ; FF56B8  ef c8 20 00 00 00
	pop XIX                                              ; FF56BE  5c
	ret                                                  ; FF56BF  0e
; ScreenEnter_DiskSaveFile_Page5: ScreenEnterPages_DiskSaveFile[5] -- what PageDispatch_DiskSaveFile, the ENTER method of the DiskSaveFile screen, runs
;   when UI_ScreenPage is 5 (notes/prom_a_page_enter_names.py).
ScreenEnter_DiskSaveFile_Page5:   ; entry: named by 1 `.long` operand, first at 0xFF3A14
	push XIX                                             ; FF56C0  3c
	lda xix, (DisplayList_RunOnLayer_SaveRegs:24)                             ; FF56C1  f2 d3 75 ff 34
	call T_CallbackQueue_ResetAndRestartTask2            ; FF56C6  1d 80 2e f4
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF56CA  1d 04 76 ff
	pushw 0x00                                           ; FF56CE  0b 00 00
	lda xbc, (DL_AttentionUsingFileDeleteWillErase:24)   ; FF56D1  f2 d0 9a f5 31
	push XBC                                             ; FF56D6  39
	lda xwa, (DL_DiskSaveFileDelete:24)                  ; FF56D7  f2 b5 9a f5 30
	push XWA                                             ; FF56DC  38
	lda xiy, (.LFF56E5:24)                               ; FF56DD  f2 e5 56 ff 35
	push XIY                                             ; FF56E2  3d
	jp (xix)                                             ; FF56E3  b4 d8
.LFF56E5:
	pushw 0x00                                           ; FF56E5  0b 00 00
	lda xbc, (DL_LoadL0adFileLoadL0ad0pti0n:24)          ; FF56E8  f2 b0 81 f5 31
	push XBC                                             ; FF56ED  39
	lda xwa, (DL_F58162:24)                              ; FF56EE  f2 62 81 f5 30
	push XWA                                             ; FF56F3  38
	lda xiy, (.LFF56FC:24)                               ; FF56F4  f2 fc 56 ff 35
	push XIY                                             ; FF56F9  3d
	jp (xix)                                             ; FF56FA  b4 d8
.LFF56FC:
	pushw 0x00                                           ; FF56FC  0b 00 00
	lda xbc, (DL_DiskSave:24)                            ; FF56FF  f2 79 9b f5 31
	push XBC                                             ; FF5704  39
	lda xwa, (DL_AttentionUsingFileDeleteWillErase:24)   ; FF5705  f2 d0 9a f5 30
	push XWA                                             ; FF570A  38
	lda xiy, (.LFF5713:24)                               ; FF570B  f2 13 57 ff 35
	push XIY                                             ; FF5710  3d
	jp (xix)                                             ; FF5711  b4 d8
.LFF5713:
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF5713  1d 15 76 ff
	add XSP,0x0000001e                                   ; FF5717  ef c8 1e 00 00 00
	pop XIX                                              ; FF571D  5c
	ret                                                  ; FF571E  0e
; ---------------------------------------------------------------------
; ScreenLeave_DiskSaveFile -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x6C -> the screen object at
;          0xF423B0, whose +4 slot is `jp 0xFF571F`, and from no other live
;          screen object's two callable slots.
; Evidence: the +4 offset is PanelScreen_VtableTable's own (its header's
;          checks V1-V6): +0 ENTER is called by PanelScreen_CallEnter_A/B, +4
;          LEAVE by PanelScreen_CallLeave_A/B with the id that just STOPPED
;          being current, +8 BUTTON by PanelButton_Route (0xF8621E).
; Screen:   DiskSaveFile -- inherited from the +0 ENTER label
;          PageDispatch_DiskSaveFile, not from any text this pass read.
; Was `sub_FF571F`.
; ---------------------------------------------------------------------
ScreenLeave_DiskSaveFile:
	ld c, (UI_ScreenLatch:16)                                   ; FF571F  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FF5723  c1 7b 20 f3
	jr z, .LFF572D                                       ; FF5727  66 04
	call DiskFileScreen_LeaveCommon                                      ; FF5729  1d 8c 79 ff
.LFF572D:
	ret                                                  ; FF572D  0e
; ---------------------------------------------------------------------
; PanelButtonDispatch_DiskSaveFile -- run Dispatch_FF3A29's handler for one
;          PANEL CONTROL
;
; Inputs:   (XIZ+0x08) = the 5-bit panel control index; (XIZ+0x0A) =
;          the argument this reader forwards to the handler.
; Evidence: `cp H,0x20` at 0xFF5736 bounds the index to the 32-code
;          panel space PanelButton_Route's `and L,0x1f`
;          (0xF861AE) produces, and `add XBC,0x00FF3A29` at 0xFF5753
;          names the table.
;          The handler is CALLED, not jumped to: the reader pushes
;          a return address before `jp (XBC)`.
; Control legend: notes/FINDINGS-prom_a-panel-control-map.md, and
;          `python3 notes/prom_a_panel_control_map.py --map`.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Was `sub_FF572E`, named by notes/prom_a_naming_wave8_apply.py.
; ---------------------------------------------------------------------
PanelButtonDispatch_DiskSaveFile:
	link XIZ,0x0000                                      ; FF572E  ee 0c 00 00
	pushw hl                                             ; FF5732  2b
	ld H,(XIZ+0x08)                                      ; FF5733  8e 08 26
	cp H,0x20                                            ; FF5736  ce cf 20
	jr nc, .LFF5764                                      ; FF5739  6f 29
	cp	(UI_ScreenPage:16), 0x06                            ; FF573B  c1 29 22 3f 06
	jr nc, .LFF5764                                      ; FF5740  6f 22
	pushw	(xiz+10)                                     ; FF5742  9e 0a 04
	ld c, (UI_ScreenPage:16)                                   ; FF5745  c1 29 22 23
	sll c, 0x05                                          ; FF5749  cb ee 05
	add C,H                                              ; FF574C  ce 83
	mul C,0x04                                           ; FF574E  cb 08 04
	extz XBC                                             ; FF5751  e9 12
	add XBC,Dispatch_FF3A29                              ; FF5753  e9 c8 29 3a ff 00
	ld XBC,(XBC)                                         ; FF5759  a1 21
	lda xiy, (.LFF5763:24)                               ; FF575B  f2 63 57 ff 35
	push XIY                                             ; FF5760  3d
	jp (xbc)                                             ; FF5761  b1 d8
.LFF5763:
	popw bc                                              ; FF5763  49
.LFF5764:
	popw hl                                              ; FF5764  4b
	unlk XIZ                                             ; FF5765  ee 0d
	ret                                                  ; FF5767  0e
; SoftKeyCol1_DiskSaveFile_Page0: Dispatch_FF3A29+0[0] -- the SoftKeyCol1 handler of DiskSaveFile_Page0; the table's other named entries sit at their own
;   controls' slots and name the same screen (notes/prom_ab_button_table_siblings.py).
SoftKeyCol1_DiskSaveFile_Page0:   ; entry: named by 2 `.long` operands, first at 0xFF3A29
	pushw 0x03                                           ; FF5768  0b 03 00
	pushw 0x04                                           ; FF576B  0b 04 00
	calr PanelDial_SetButtonPair                                      ; FF576E  1e b9 19
	ld (LCD_CurrentLayer:16), 0x01                                 ; FF5771  f1 40 25 00 01
	ld c, (NameEdit_CharIndex:16)                                   ; FF5776  c1 f9 21 23
	ld (0x2729:16), c                                   ; FF577A  f1 29 27 43
	lda xbc, (CharPalette_F587B2:24)                     ; FF577E  f2 b2 87 f5 31
	push XBC                                             ; FF5783  39
	lda xwa, (DL_F5879C:24)                              ; FF5784  f2 9c 87 f5 30
	push XWA                                             ; FF5789  38
	call T_DisplayListB_Run_Stack                        ; FF578A  1d 04 2e f4
	ld (0x272c:16), 0x81                                 ; FF578E  f1 2c 27 00 81
	call T_NameEdit_MoveCursor_Call                                        ; FF5793  1d d4 25 f4
	ld c, (NameEdit_CursorPos:16)                                   ; FF5797  c1 2d 22 23
	dec 1,C                                              ; FF579B  cb 69
	ld (0x2721:16), c                                   ; FF579D  f1 21 27 43
	ld a, (NameEdit_CharIndex:16)                                   ; FF57A1  c1 f9 21 21
	ld (0x2729:16), a                                   ; FF57A5  f1 29 27 41
	lda xbc, (DL_F5879C:24)                              ; FF57A9  f2 9c 87 f5 31
	push XBC                                             ; FF57AE  39
	lda xwa, (DL_F58786:24)                              ; FF57AF  f2 86 87 f5 30
	push XWA                                             ; FF57B4  38
	call T_DisplayListB_Run_Stack                        ; FF57B5  1d 04 2e f4
	add XSP,0x00000014                                   ; FF57B9  ef c8 14 00 00 00
	ret                                                  ; FF57BF  0e
; SoftKeyCol2_DiskSaveFile_Page0: Dispatch_FF3A29+0[1] -- the SoftKeyCol2 handler of DiskSaveFile_Page0; the table's other named entries sit at their own
;   controls' slots and name the same screen (notes/prom_ab_button_table_siblings.py).
SoftKeyCol2_DiskSaveFile_Page0:   ; entry: named by 2 `.long` operands, first at 0xFF3A2D
	pushw 0x03                                           ; FF57C0  0b 03 00
	pushw 0x04                                           ; FF57C3  0b 04 00
	calr PanelDial_SetButtonPair                                      ; FF57C6  1e 61 19
	ld (LCD_CurrentLayer:16), 0x01                                 ; FF57C9  f1 40 25 00 01
	ld c, (NameEdit_CharIndex:16)                                   ; FF57CE  c1 f9 21 23
	ld (0x2729:16), c                                   ; FF57D2  f1 29 27 43
	lda xbc, (CharPalette_F587B2:24)                     ; FF57D6  f2 b2 87 f5 31
	push XBC                                             ; FF57DB  39
	lda xwa, (DL_F5879C:24)                              ; FF57DC  f2 9c 87 f5 30
	push XWA                                             ; FF57E1  38
	call T_DisplayListB_Run_Stack                        ; FF57E2  1d 04 2e f4
	ld (0x272c:16), 0x01                                 ; FF57E6  f1 2c 27 00 01
	call T_NameEdit_MoveCursor_Call                                        ; FF57EB  1d d4 25 f4
	ld c, (NameEdit_CursorPos:16)                                   ; FF57EF  c1 2d 22 23
	dec 1,C                                              ; FF57F3  cb 69
	ld (0x2721:16), c                                   ; FF57F5  f1 21 27 43
	ld a, (NameEdit_CharIndex:16)                                   ; FF57F9  c1 f9 21 21
	ld (0x2729:16), a                                   ; FF57FD  f1 29 27 41
	lda xbc, (DL_F5879C:24)                              ; FF5801  f2 9c 87 f5 31
	push XBC                                             ; FF5806  39
	lda xwa, (DL_F58786:24)                              ; FF5807  f2 86 87 f5 30
	push XWA                                             ; FF580C  38
	call T_DisplayListB_Run_Stack                        ; FF580D  1d 04 2e f4
	add XSP,0x00000014                                   ; FF5811  ef c8 14 00 00 00
	ret                                                  ; FF5817  0e
; SoftKeyCol4_DiskSaveFile_Page0: Dispatch_FF3A29+0[3] -- the SoftKeyCol4 handler of DiskSaveFile_Page0; the table's other named entries sit at their own
;   controls' slots and name the same screen (notes/prom_ab_button_table_siblings.py).
SoftKeyCol4_DiskSaveFile_Page0:   ; entry: named by 2 `.long` operands, first at 0xFF3A35
	pushw 0x03                                           ; FF5818  0b 03 00
	pushw 0x04                                           ; FF581B  0b 04 00
	calr PanelDial_SetButtonPair                                      ; FF581E  1e 09 19
	ld c, (NameEdit_CharIndex:16)                                   ; FF5821  c1 f9 21 23
	ld (0x2729:16), c                                   ; FF5825  f1 29 27 43
	lda xbc, (0xf587a7:24)                               ; FF5829  f2 a7 87 f5 31
	push XBC                                             ; FF582E  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF582F  1d 23 76 ff
	ld (0x272c:16), 0x81                                 ; FF5833  f1 2c 27 00 81
	call T_NameEdit_StepChar_Call                                        ; FF5838  1d d8 25 f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF583C  f1 40 25 00 00
	call LCD_DrawDiskFileName6_SaveRegs                                      ; FF5841  1d 0f 77 ff
	ld c, (NameEdit_CharIndex:16)                                   ; FF5845  c1 f9 21 23
	ld (0x2729:16), c                                   ; FF5849  f1 29 27 43
	lda xbc, (0xf58791:24)                               ; FF584D  f2 91 87 f5 31
	push XBC                                             ; FF5852  39
	call DLB_Array8_SaveRegs                                      ; FF5853  1d 3f 76 ff
	inc 8,XSP                                            ; FF5857  ef 60
	inc 4,XSP                                            ; FF5859  ef 64
	ret                                                  ; FF585B  0e
; SoftKeyCol5_DiskSaveFile_Page0: Dispatch_FF3A29+0[4] -- the SoftKeyCol5 handler of DiskSaveFile_Page0; the table's other named entries sit at their own
;   controls' slots and name the same screen (notes/prom_ab_button_table_siblings.py).
SoftKeyCol5_DiskSaveFile_Page0:   ; entry: named by 2 `.long` operands, first at 0xFF3A39
	pushw 0x03                                           ; FF585C  0b 03 00
	pushw 0x04                                           ; FF585F  0b 04 00
	calr PanelDial_SetButtonPair                                      ; FF5862  1e c5 18
	ld c, (NameEdit_CharIndex:16)                                   ; FF5865  c1 f9 21 23
	ld (0x2729:16), c                                   ; FF5869  f1 29 27 43
	lda xbc, (0xf587a7:24)                               ; FF586D  f2 a7 87 f5 31
	push XBC                                             ; FF5872  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF5873  1d 23 76 ff
	ld (0x272c:16), 0x01                                 ; FF5877  f1 2c 27 00 01
	call T_NameEdit_StepChar_Call                                        ; FF587C  1d d8 25 f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF5880  f1 40 25 00 00
	call LCD_DrawDiskFileName6_SaveRegs                                      ; FF5885  1d 0f 77 ff
	ld c, (NameEdit_CharIndex:16)                                   ; FF5889  c1 f9 21 23
	ld (0x2729:16), c                                   ; FF588D  f1 29 27 43
	lda xbc, (0xf58791:24)                               ; FF5891  f2 91 87 f5 31
	push XBC                                             ; FF5896  39
	call DLB_Array8_SaveRegs                                      ; FF5897  1d 3f 76 ff
	inc 8,XSP                                            ; FF589B  ef 60
	inc 4,XSP                                            ; FF589D  ef 64
	ret                                                  ; FF589F  0e
; SoftKeyCol7_DiskSaveFile_Page0: Dispatch_FF3A29+0[6] -- the SoftKeyCol7 handler of DiskSaveFile_Page0; the table's other named entries sit at their own
;   controls' slots and name the same screen (notes/prom_ab_button_table_siblings.py).
SoftKeyCol7_DiskSaveFile_Page0:   ; entry: named by 2 `.long` operands, first at 0xFF3A41
	pushw hl                                             ; FF58A0  2b
	pushw de                                             ; FF58A1  2a
	push XIX                                             ; FF58A2  3c
	ld c, (NameEdit_CharIndex:16)                                   ; FF58A3  c1 f9 21 23
	ld (0x2729:16), c                                   ; FF58A7  f1 29 27 43
	pushw 0x03                                           ; FF58AB  0b 03 00
	pushw 0x04                                           ; FF58AE  0b 04 00
	calr PanelDial_SetButtonPair                                      ; FF58B1  1e 76 18
	ld (LCD_CurrentLayer:16), 0x01                                 ; FF58B4  f1 40 25 00 01
	lda xbc, (CharPalette_F587B2:24)                     ; FF58B9  f2 b2 87 f5 31
	push XBC                                             ; FF58BE  39
	lda xwa, (DL_F5879C:24)                              ; FF58BF  f2 9c 87 f5 30
	push XWA                                             ; FF58C4  38
	call T_DisplayListB_Run_Stack                        ; FF58C5  1d 04 2e f4
	ldw de, 0x02                                         ; FF58C9  32 02 00
	ld h, 0x06:opc                                          ; FF58CC  26 06
	inc 8,XSP                                            ; FF58CE  ef 60
	inc 4,XSP                                            ; FF58D0  ef 64
.LFF58D2:
	ld IX,DE                                             ; FF58D2  da 8c
	extz XIX                                             ; FF58D4  ec 12
	ld (XIX+Disk_FileName),0x5f                                 ; FF58D6  f3 f1 c8 21 00 5f
	ld DE,IX                                             ; FF58DC  dc 8a
	inc 1,DE                                             ; FF58DE  da 61
	dec 1,H                                              ; FF58E0  ce 69
	cp h, 0x00:i3                                          ; FF58E2  ce d8
	jr nz, .LFF58D2                                      ; FF58E4  6e ec
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF58E6  f1 40 25 00 00
	ld (NameEdit_CursorPos:16), 0x03                                 ; FF58EB  f1 2d 22 00 03
	ld (NameEdit_CharIndex:16), 0x00                                 ; FF58F0  f1 f9 21 00 00
	ld (0x2729:16), 0x00                                 ; FF58F5  f1 29 27 00 00
	call LCD_DrawDiskFileName6_SaveRegs                                      ; FF58FA  1d 0f 77 ff
	ld (0x2721:16), 0x02                                 ; FF58FE  f1 21 27 00 02
	lda xbc, (DL_F5879C:24)                              ; FF5903  f2 9c 87 f5 31
	push XBC                                             ; FF5908  39
	lda xwa, (DL_F58786:24)                              ; FF5909  f2 86 87 f5 30
	push XWA                                             ; FF590E  38
	call T_DisplayListB_Run_Stack                        ; FF590F  1d 04 2e f4
	inc 8,XSP                                            ; FF5913  ef 60
	pop XIX                                              ; FF5915  5c
	popw de                                              ; FF5916  4a
	popw hl                                              ; FF5917  4b
	ret                                                  ; FF5918  0e
; ---------------------------------------------------------------------
; LcdKeyRow1_DiskSaveFile_Page0 -- what Dispatch_FF3A29 runs for panel
;          control 0x08
;
; Reached from: Dispatch_FF3A29 entry [8] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x08 is the LCD row 1 button pair -- the left-hand and
;          right-hand buttons of the display's TOP row. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow1_DiskSaveFile_Page0:
	link XIZ,0x0000                                      ; FF5919  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF591D  9e 08 21
	and BC,0x0080                                        ; FF5920  d9 cc 80 00
	jr nz, .LFF5951                                      ; FF5924  6e 2b
	res	3, (UI_RequestBits:16)                               ; FF5926  f1 75 20 b3
	ld (UI_ScreenPage:16), 0x01                                 ; FF592A  f1 29 22 00 01
	ld (UI_Request_Hi:16), 0x10                                 ; FF592F  f1 71 20 00 10
	res	0, (0x2726:16)                               ; FF5934  f1 26 27 b0
	call T_Playback_StopAllAndIgnoreMidiStart                                        ; FF5938  1d 94 25 f4
	call T_DiskSaveScreen_MountAndScanDirectory                                        ; FF593C  1d b8 25 f4
	calr UI_StatusCode_Is0or2or4                                      ; FF5940  1e 59 1c
	cp wa, 0x00:i3                                         ; FF5943  d8 d8
	jr z, .LFF5951                                       ; FF5945  66 0a
	ld (UI_Request:16), 0x40                                 ; FF5947  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF594C  f1 71 20 00 80
.LFF5951:
	unlk XIZ                                             ; FF5951  ee 0d
	ret                                                  ; FF5953  0e
; ---------------------------------------------------------------------
; LcdKeyRow4_DiskSaveFile_Page0 -- what Dispatch_FF3A29 runs for panel
;          control 0x0B
;
; Reached from: Dispatch_FF3A29 entry [11] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0B is the LCD row 4 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow4_DiskSaveFile_Page0:
	link XIZ,0x0000                                      ; FF5954  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF5958  9e 08 21
	and BC,0x0080                                        ; FF595B  d9 cc 80 00
	jr nz, .LFF5988                                      ; FF595F  6e 27
	set	0, (0x2726:16)                               ; FF5961  f1 26 27 b8
	ld (UI_ScreenPage:16), 0x01                                 ; FF5965  f1 29 22 00 01
	ld (UI_Request_Hi:16), 0x10                                 ; FF596A  f1 71 20 00 10
	call T_Playback_StopAllAndIgnoreMidiStart                                        ; FF596F  1d 94 25 f4
	call T_DiskSaveScreen_MountAndScanDirectory                                        ; FF5973  1d b8 25 f4
	calr UI_StatusCode_Is0or2or4                                      ; FF5977  1e 22 1c
	cp wa, 0x00:i3                                         ; FF597A  d8 d8
	jr z, .LFF5988                                       ; FF597C  66 0a
	ld (UI_Request:16), 0x40                                 ; FF597E  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF5983  f1 71 20 00 80
.LFF5988:
	unlk XIZ                                             ; FF5988  ee 0d
	ret                                                  ; FF598A  0e
; ---------------------------------------------------------------------
; ExitKey_DiskSaveFile_Page0 -- what Dispatch_FF3A29 runs for panel control
;          0x0F
;
; Reached from: Dispatch_FF3A29 entry [15] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0F is the EXIT key. The pair position -- which of the two
;          keys -- reaches the handler in the argument the reader forwards;
;          this pass did NOT establish that argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
ExitKey_DiskSaveFile_Page0:
	link XIZ,0x0000                                      ; FF598B  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF598F  9e 08 21
	and BC,0x0080                                        ; FF5992  d9 cc 80 00
	jr nz, .LFF59A2                                      ; FF5996  6e 0a
	ld (UI_Request:16), 0x40                                 ; FF5998  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF599D  f1 71 20 00 80
.LFF59A2:
	unlk XIZ                                             ; FF59A2  ee 0d
	ret                                                  ; FF59A4  0e
; SoftKeyCol4_DiskSaveFile_Page1: Dispatch_FF3A29+128[3] -- the SoftKeyCol4 handler of DiskSaveFile_Page1; the table's other named entries sit at their own
;   controls' slots and name the same screen (notes/prom_ab_button_table_siblings.py).
SoftKeyCol4_DiskSaveFile_Page1:   ; entry: named by 2 `.long` operands, first at 0xFF3AB5
	push XIX                                             ; FF59A5  3c
	lda xix, (DiskSave_PasswordUnlockCount:16)                                ; FF59A6  f1 0c 22 34
	ld c, (0x2726:16)                                   ; FF59AA  c1 26 27 23
	and C,0x01                                           ; FF59AE  cb cc 01
	jr nz, .LFF59E7                                      ; FF59B1  6e 34
	incm8 0x01, (xix)                                    ; FF59B3  84 61
	ld C,(XIX)                                           ; FF59B5  84 23
	cp c, 0x06:i3                                          ; FF59B7  cb de
	jr ule, .LFF59E7                                     ; FF59B9  63 2c
	cpw	(BStore_Password:24), 0x0000                        ; FF59BB  d2 1c 34 60 3f 00 00
	jr nz, .LFF59D0                                      ; FF59C2  6e 0c
	ld (UI_ScreenPage:16), 0x03                                 ; FF59C4  f1 29 22 00 03
	ld (UI_Request_Hi:16), 0x10                                 ; FF59C9  f1 71 20 00 10
	jr .LFF59E7                                          ; FF59CE  68 17
.LFF59D0:
	ld (XIX),0x00                                        ; FF59D0  b4 00 00
	ld (DiskSave_Password:16), 0x00                                 ; FF59D3  f1 0f 22 00 00
	ld (UI_StatusCode:16), 0x0a                                 ; FF59D8  f1 80 28 00 0a
	ld (UI_Request:16), 0xab                                 ; FF59DD  f1 70 20 00 ab
	ld (UI_Request_Hi:16), 0x40                                 ; FF59E2  f1 71 20 00 40
.LFF59E7:
	pop XIX                                              ; FF59E7  5c
	ret                                                  ; FF59E8  0e
; ---------------------------------------------------------------------
; LcdKeyRow1_DiskSaveFile_Page1 -- what Dispatch_FF3A29 runs for panel
;          control 0x08
;
; Reached from: Dispatch_FF3A29 entry [40] (page 1, control 0x08) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x08 is the LCD row 1 button pair -- the left-hand and
;          right-hand buttons of the display's TOP row. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow1_DiskSaveFile_Page1:
	link XIZ,0x0000                                      ; FF59E9  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF59ED  9e 08 21
	and BC,0x0080                                        ; FF59F0  d9 cc 80 00
	jr z, .LFF59FF                                       ; FF59F4  66 09
	pushw	(xiz+8)                                      ; FF59F6  9e 08 04
	calr LcdKeyRow2_DiskSaveFile_Page1                                      ; FF59F9  1e 6d 00
	popw bc                                              ; FF59FC  49
	jr .LFF5A2A                                          ; FF59FD  68 2b
.LFF59FF:
	res	3, (UI_RequestBits:16)                               ; FF59FF  f1 75 20 b3
	call Disk_CopyEntry2724HeadToFileName_SaveRegs                                      ; FF5A03  1d 32 78 ff
	ld c, (0x2726:16)                                   ; FF5A07  c1 26 27 23
	and C,0x01                                           ; FF5A0B  cb cc 01
	jr nz, .LFF5A1A                                      ; FF5A0E  6e 0a
	call T_DiskSaveFile_Execute_Entry                                        ; FF5A10  1d cc 25 f4
	call SC1_CmdEFAndClearHeldButtons                                      ; FF5A14  1d 59 79 ff
	jr .LFF5A2A                                          ; FF5A18  68 10
.LFF5A1A:
	calr DiskSaveFile_Page1_LcdKeyRow1                                      ; FF5A1A  1e 10 00
	cp wa, 0x00:i3                                         ; FF5A1D  d8 d8
	jr z, .LFF5A2A                                       ; FF5A1F  66 09
	ld (UI_ScreenPage:16), 0x05                                 ; FF5A21  f1 29 22 00 05
	set	4, (UI_Request_Hi:16)                               ; FF5A26  f1 71 20 bc
.LFF5A2A:
	unlk XIZ                                             ; FF5A2A  ee 0d
	ret                                                  ; FF5A2C  0e
; DiskSaveFile_Page1_LcdKeyRow1: the LcdKeyRow1 action of DiskSaveFile_Page1 -- called only by LcdKeyRow1_DiskSaveFile_Page1.
DiskSaveFile_Page1_LcdKeyRow1:
	pushw hl                                             ; FF5A2D  2b
	pushw de                                             ; FF5A2E  2a
	push XIX                                             ; FF5A2F  3c
	ldw de, 0x00                                         ; FF5A30  32 00 00
	ldw hl, 0x00                                         ; FF5A33  33 00 00
	ld c, 0x10:opc                                          ; FF5A36  23 10
	mul	bc, (Disk_SelectedEntry:16)                              ; FF5A38  c1 24 27 43
	extz XBC                                             ; FF5A3C  e9 12
	ld XIX,XBC                                           ; FF5A3E  e9 8c
	add XBC,0x00000488                                   ; FF5A40  e9 c8 88 04 00 00
	ld XIX,XBC                                           ; FF5A46  e9 8c
.LFF5A48:
	lda xbc, (0x60a000:24)                               ; FF5A48  f2 00 a0 60 31
	add XBC,XIX                                          ; FF5A4D  ec 81
	ld A,(XBC)                                           ; FF5A4F  81 21
	cp A,0x80                                            ; FF5A51  c9 cf 80
	jr z, .LFF5A59                                       ; FF5A54  66 03
	ldw de, 0x01                                         ; FF5A56  32 01 00
.LFF5A59:
	inc 1,XIX                                            ; FF5A59  ec 61
	inc 1,HL                                             ; FF5A5B  db 61
	cp HL,0x0008                                         ; FF5A5D  db cf 08 00
	jr lt, .LFF5A48                                      ; FF5A61  61 e5
	ld WA,DE                                             ; FF5A63  da 88
	pop XIX                                              ; FF5A65  5c
	popw de                                              ; FF5A66  4a
	popw hl                                              ; FF5A67  4b
	ret                                                  ; FF5A68  0e
; ---------------------------------------------------------------------
; LcdKeyRow2_DiskSaveFile_Page1 -- what Dispatch_FF3A29 runs for panel
;          control 0x09
;
; Reached from: Dispatch_FF3A29 entry [41] (page 1, control 0x09) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x09 is the LCD row 2 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; Was `sub_FF5A69`.
; ---------------------------------------------------------------------
LcdKeyRow2_DiskSaveFile_Page1:
	link XIZ,0x0000                                      ; FF5A69  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF5A6D  9e 08 21
	and BC,0x0080                                        ; FF5A70  d9 cc 80 00
	jr z, .LFF5A9C                                       ; FF5A74  66 26
	pushw 0x0b                                           ; FF5A76  0b 0b 00
	pushw 0x0c                                           ; FF5A79  0b 0c 00
	calr PanelDial_SetButtonPair                                      ; FF5A7C  1e ab 16
	lda xbc, (DL_F5843F:24)                              ; FF5A7F  f2 3f 84 f5 31
	push XBC                                             ; FF5A84  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF5A85  1d 23 76 ff
	ld (UI_ScreenItem:16), 0x00                                 ; FF5A89  f1 20 27 00 00
	lda xbc, (DL_F583E5:24)                              ; FF5A8E  f2 e5 83 f5 31
	push XBC                                             ; FF5A93  39
	call DLB_Array8_SaveRegs                                      ; FF5A94  1d 3f 76 ff
	inc 8,XSP                                            ; FF5A98  ef 60
	inc 4,XSP                                            ; FF5A9A  ef 64
.LFF5A9C:
	unlk XIZ                                             ; FF5A9C  ee 0d
	ret                                                  ; FF5A9E  0e
; ---------------------------------------------------------------------
; LcdKeyRow3_DiskSaveFile_Page1 -- what Dispatch_FF3A29 runs for panel
;          control 0x0A
;
; Reached from: Dispatch_FF3A29 entry [42] (page 1, control 0x0A) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x0A is the LCD row 3 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow3_DiskSaveFile_Page1:
	link XIZ,0x0000                                      ; FF5A9F  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF5AA3  9e 08 21
	and BC,0x0080                                        ; FF5AA6  d9 cc 80 00
	jr z, .LFF5AB3                                       ; FF5AAA  66 07
	pushw	(xiz+8)                                      ; FF5AAC  9e 08 04
	calr LcdKeyRow2_DiskSaveFile_Page1                                      ; FF5AAF  1e b7 ff
	popw bc                                              ; FF5AB2  49
.LFF5AB3:
	unlk XIZ                                             ; FF5AB3  ee 0d
	ret                                                  ; FF5AB5  0e
; ---------------------------------------------------------------------
; LcdKeyRow4_DiskSaveFile_Page1 -- what Dispatch_FF3A29 runs for panel
;          control 0x0B
;
; Reached from: Dispatch_FF3A29 entry [43] (page 1, control 0x0B) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x0B is the LCD row 4 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow4_DiskSaveFile_Page1:
	link XIZ,0x0000                                      ; FF5AB6  ee 0c 00 00
	pushw	(xiz+8)                                      ; FF5ABA  9e 08 04
	calr LcdKeyRow4_DiskL0adFile                                      ; FF5ABD  1e 0b f0
	popw bc                                              ; FF5AC0  49
	unlk XIZ                                             ; FF5AC1  ee 0d
	ret                                                  ; FF5AC3  0e
; ---------------------------------------------------------------------
; LcdKeyRow5_DiskSaveFile_Page1 -- what Dispatch_FF3A29 runs for panel
;          control 0x0C
;
; Reached from: Dispatch_FF3A29 entry [44] (page 1, control 0x0C) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x0C is the LCD row 5 button pair -- the BOTTOM row. The
;          pair position -- which of the two keys -- reaches the handler in
;          the argument the reader forwards; this pass did NOT establish that
;          argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow5_DiskSaveFile_Page1:
	link XIZ,0x0000                                      ; FF5AC4  ee 0c 00 00
	pushw	(xiz+8)                                      ; FF5AC8  9e 08 04
	calr LcdKeyRow5_DiskL0adFile                                      ; FF5ACB  1e 8f f2
	popw bc                                              ; FF5ACE  49
	unlk XIZ                                             ; FF5ACF  ee 0d
	ret                                                  ; FF5AD1  0e
; ---------------------------------------------------------------------
; ExitKey_DiskSaveFile_Page1 -- what Dispatch_FF3A29 runs for panel control
;          0x0F
;
; Reached from: Dispatch_FF3A29 entry [47] (page 1, control 0x0F) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x0F is the EXIT key. The pair position -- which of the two
;          keys -- reaches the handler in the argument the reader forwards;
;          this pass did NOT establish that argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
ExitKey_DiskSaveFile_Page1:
	link XIZ,0x0000                                      ; FF5AD2  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF5AD6  9e 08 21
	and BC,0x0080                                        ; FF5AD9  d9 cc 80 00
	jr nz, .LFF5AE9                                      ; FF5ADD  6e 0a
	ld (UI_Request:16), 0x40                                 ; FF5ADF  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF5AE4  f1 71 20 00 80
.LFF5AE9:
	unlk XIZ                                             ; FF5AE9  ee 0d
	ret                                                  ; FF5AEB  0e
; ---------------------------------------------------------------------
; LcdKeyRow3_DiskSaveFile_Page2 -- what Dispatch_FF3A29 runs for panel
;          control 0x0A
;
; Reached from: Dispatch_FF3A29 entry [74] (page 2, control 0x0A) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x0A is the LCD row 3 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow3_DiskSaveFile_Page2:
	link XIZ,0x0000                                      ; FF5AEC  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF5AF0  9e 08 21
	and BC,0x0080                                        ; FF5AF3  d9 cc 80 00
	jr nz, .LFF5B01                                      ; FF5AF7  6e 08
	call T_DiskSaveFile_Execute_Entry                                        ; FF5AF9  1d cc 25 f4
	call SC1_CmdEFAndClearHeldButtons                                      ; FF5AFD  1d 59 79 ff
.LFF5B01:
	unlk XIZ                                             ; FF5B01  ee 0d
	ret                                                  ; FF5B03  0e
; ---------------------------------------------------------------------
; LcdKeyRow4_DiskSaveFile_Page2 -- what Dispatch_FF3A29 runs for panel
;          control 0x0B
;
; Reached from: Dispatch_FF3A29 entry [75] (page 2, control 0x0B) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x0B is the LCD row 4 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow4_DiskSaveFile_Page2:
	link XIZ,0x0000                                      ; FF5B04  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF5B08  9e 08 21
	and BC,0x0080                                        ; FF5B0B  d9 cc 80 00
	jr nz, .LFF5B1B                                      ; FF5B0F  6e 0a
	ld (UI_ScreenPage:16), 0x01                                 ; FF5B11  f1 29 22 00 01
	ld (UI_Request_Hi:16), 0x10                                 ; FF5B16  f1 71 20 00 10
.LFF5B1B:
	unlk XIZ                                             ; FF5B1B  ee 0d
	ret                                                  ; FF5B1D  0e
; ---------------------------------------------------------------------
; ExitKey_DiskSaveFile_Page2 -- what Dispatch_FF3A29 runs for panel control
;          0x0F
;
; Reached from: Dispatch_FF3A29 entry [79] (page 2, control 0x0F) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x0F is the EXIT key. The pair position -- which of the two
;          keys -- reaches the handler in the argument the reader forwards;
;          this pass did NOT establish that argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
ExitKey_DiskSaveFile_Page2:
	link XIZ,0x0000                                      ; FF5B1E  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF5B22  9e 08 21
	and BC,0x0080                                        ; FF5B25  d9 cc 80 00
	jr nz, .LFF5B35                                      ; FF5B29  6e 0a
	ld (UI_Request:16), 0x40                                 ; FF5B2B  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF5B30  f1 71 20 00 80
.LFF5B35:
	unlk XIZ                                             ; FF5B35  ee 0d
	ret                                                  ; FF5B37  0e
; ---------------------------------------------------------------------
; LcdKeyRow1_DiskSaveFile_Page3 -- what Dispatch_FF3A29 runs for panel
;          control 0x08
;
; Reached from: Dispatch_FF3A29 entry [104] (page 3, control 0x08) -- and
;          from no other slot of any 32-entry control table in prom_a. A
;          target reached at two DIFFERENT indices is refused by the script
;          that wrote this.
; Control:  index 0x08 is the LCD row 1 button pair -- the left-hand and
;          right-hand buttons of the display's TOP row. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow1_DiskSaveFile_Page3:
	link XIZ,0x0000                                      ; FF5B38  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF5B3C  9e 08 21
	and BC,0x0080                                        ; FF5B3F  d9 cc 80 00
	jr nz, .LFF5B4F                                      ; FF5B43  6e 0a
	pushw	(xiz+8)                                      ; FF5B45  9e 08 04
	call T_SoundEditNaming_LcdKeyRow1                                        ; FF5B48  1d a4 2f f4
	popw bc                                              ; FF5B4C  49
	jr .LFF5B53                                          ; FF5B4D  68 04
.LFF5B4F:
	call DiskSaveFile_Page3_LcdKeyRow1                                      ; FF5B4F  1d c9 78 ff
.LFF5B53:
	unlk XIZ                                             ; FF5B53  ee 0d
	ret                                                  ; FF5B55  0e
; ---------------------------------------------------------------------
; ExitKey_DiskSaveFile_Pages3_4 -- what Dispatch_FF3A29 runs for panel
;          control 0x0F
;
; Reached from: Dispatch_FF3A29 entry [111] (page 3, control 0x0F),
;          Dispatch_FF3A29 entry [143] (page 4, control 0x0F) -- and from no
;          other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x0F is the EXIT key. The pair position -- which of the two
;          keys -- reaches the handler in the argument the reader forwards;
;          this pass did NOT establish that argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
ExitKey_DiskSaveFile_Pages3_4:
	link XIZ,0x0000                                      ; FF5B56  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF5B5A  9e 08 21
	and BC,0x0080                                        ; FF5B5D  d9 cc 80 00
	jr nz, .LFF5B6D                                      ; FF5B61  6e 0a
	ld (UI_Request:16), 0x40                                 ; FF5B63  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF5B68  f1 71 20 00 80
.LFF5B6D:
	unlk XIZ                                             ; FF5B6D  ee 0d
	ret                                                  ; FF5B6F  0e
; ---------------------------------------------------------------------
; LcdKeyRow1_DiskSaveFile_Page4 -- what Dispatch_FF3A29 runs for panel
;          control 0x08
;
; Reached from: Dispatch_FF3A29 entry [136] (page 4, control 0x08) -- and
;          from no other slot of any 32-entry control table in prom_a. A
;          target reached at two DIFFERENT indices is refused by the script
;          that wrote this.
; Control:  index 0x08 is the LCD row 1 button pair -- the left-hand and
;          right-hand buttons of the display's TOP row. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow1_DiskSaveFile_Page4:
	link XIZ,0x0000                                      ; FF5B70  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF5B74  9e 08 21
	and BC,0x0080                                        ; FF5B77  d9 cc 80 00
	jr nz, .LFF5B87                                      ; FF5B7B  6e 0a
	pushw	(xiz+8)                                      ; FF5B7D  9e 08 04
	call T_SoundEditNaming_LcdKeyRow1                                        ; FF5B80  1d a4 2f f4
	popw bc                                              ; FF5B84  49
	jr .LFF5B90                                          ; FF5B85  68 09
.LFF5B87:
	ld (0x222a:16), 0x00                                 ; FF5B87  f1 2a 22 00 00
	call DiskSaveFile_Page4_LcdKeyRow1                                      ; FF5B8C  1d b1 79 ff
.LFF5B90:
	unlk XIZ                                             ; FF5B90  ee 0d
	ret                                                  ; FF5B92  0e
	link XIZ,0x0000                                      ; FF5B93  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF5B97  9e 08 21
	and BC,0x0080                                        ; FF5B9A  d9 cc 80 00
	jr nz, .LFF5BAF                                      ; FF5B9E  6e 0f
	ld (0x222a:16), 0x00                                 ; FF5BA0  f1 2a 22 00 00
	ld (UI_Request:16), 0x40                                 ; FF5BA5  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF5BAA  f1 71 20 00 80
.LFF5BAF:
	unlk XIZ                                             ; FF5BAF  ee 0d
	ret                                                  ; FF5BB1  0e
; ---------------------------------------------------------------------
; LcdKeyRow3_DiskSaveFile_Page5 -- what Dispatch_FF3A29 runs for panel
;          control 0x0A
;
; Reached from: Dispatch_FF3A29 entry [170] (page 5, control 0x0A) -- and
;          from no other slot of any 32-entry control table in prom_a. A
;          target reached at two DIFFERENT indices is refused by the script
;          that wrote this.
; Control:  index 0x0A is the LCD row 3 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow3_DiskSaveFile_Page5:
	link XIZ,0xfff4                                      ; FF5BB2  ee 0c f4 ff
	ld BC,(XIZ+0x08)                                     ; FF5BB6  9e 08 21
	and BC,0x0080                                        ; FF5BB9  d9 cc 80 00
	jr nz, .LFF5C07                                      ; FF5BBD  6e 48
	res	3, (UI_RequestBits:16)                               ; FF5BBF  f1 75 20 b3
	pushw 0x0b                                           ; FF5BC3  0b 0b 00
	lda xbc, (Disk_FileName:16)                                ; FF5BC6  f1 c8 21 31
	push XBC                                             ; FF5BCA  39
	lda xwa, (xiz-12)                                    ; FF5BCB  be f4 30
	push XWA                                             ; FF5BCE  38
	call MemCpy_C                                      ; FF5BCF  1d b5 78 ff
	calr DiskEntry_CopySelectedToFileName                                      ; FF5BD3  1e ae 14
	call T_DiskSaveFile_Page5_LcdKeyRow3                                        ; FF5BD6  1d f4 25 f4
	pushw 0x0b                                           ; FF5BDA  0b 0b 00
	lda xbc, (xiz-12)                                    ; FF5BDD  be f4 31
	push XBC                                             ; FF5BE0  39
	lda xwa, (Disk_FileName:16)                                ; FF5BE1  f1 c8 21 30
	push XWA                                             ; FF5BE5  38
	call MemCpy_C                                      ; FF5BE6  1d b5 78 ff
	call SC1_CmdEFAndClearHeldButtons                                      ; FF5BEA  1d 59 79 ff
	res	0, (0x2726:16)                               ; FF5BEE  f1 26 27 b0
	ld (UI_ScreenPage:16), 0x00                                 ; FF5BF2  f1 29 22 00 00
	ld (UI_Request:16), 0x40                                 ; FF5BF7  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF5BFC  f1 71 20 00 80
	add XSP,0x00000014                                   ; FF5C01  ef c8 14 00 00 00
.LFF5C07:
	unlk XIZ                                             ; FF5C07  ee 0d
	ret                                                  ; FF5C09  0e
; ---------------------------------------------------------------------
; LcdKeyRow4_DiskSaveFile_Page5 -- what Dispatch_FF3A29 runs for panel
;          control 0x0B
;
; Reached from: Dispatch_FF3A29 entry [171] (page 5, control 0x0B) -- and
;          from no other slot of any 32-entry control table in prom_a. A
;          target reached at two DIFFERENT indices is refused by the script
;          that wrote this.
; Control:  index 0x0B is the LCD row 4 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow4_DiskSaveFile_Page5:
	link XIZ,0x0000                                      ; FF5C0A  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF5C0E  9e 08 21
	and BC,0x0080                                        ; FF5C11  d9 cc 80 00
	jr nz, .LFF5C20                                      ; FF5C15  6e 09
	ld (UI_ScreenPage:16), 0x01                                 ; FF5C17  f1 29 22 00 01
	set	4, (UI_Request_Hi:16)                               ; FF5C1C  f1 71 20 bc
.LFF5C20:
	unlk XIZ                                             ; FF5C20  ee 0d
	ret                                                  ; FF5C22  0e
; ---------------------------------------------------------------------
; ExitKey_DiskSaveFile_Page5 -- what Dispatch_FF3A29 runs for panel control
;          0x0F
;
; Reached from: Dispatch_FF3A29 entry [175] (page 5, control 0x0F) -- and
;          from no other slot of any 32-entry control table in prom_a. A
;          target reached at two DIFFERENT indices is refused by the script
;          that wrote this.
; Control:  index 0x0F is the EXIT key. The pair position -- which of the two
;          keys -- reaches the handler in the argument the reader forwards;
;          this pass did NOT establish that argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   DiskSaveFile -- the screen object at PanelScreen_VtableTable
;          entry 0x6C, i.e. SCREEN ID 0x4C through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its Enter method is the page dispatcher
;          PageDispatch_FF3A00, and four of that table's six pages are
;          Paint_DiskSaveFile.
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
ExitKey_DiskSaveFile_Page5:
	link XIZ,0x0000                                      ; FF5C23  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF5C27  9e 08 21
	and BC,0x0080                                        ; FF5C2A  d9 cc 80 00
	jr nz, .LFF5C3A                                      ; FF5C2E  6e 0a
	ld (UI_Request:16), 0x40                                 ; FF5C30  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF5C35  f1 71 20 00 80
.LFF5C3A:
	unlk XIZ                                             ; FF5C3A  ee 0d
	ret                                                  ; FF5C3C  0e
T_F423BC_Nop:
	ret                                                  ; FF5C3D  0e
; ---------------------------------------------------------------------
; PageDispatch_MidiFileSave -- run ScreenEnterPages_MidiFileSave's entry for the CURRENT
;          PAGE
;
; ★ NOT a panel-control table.  This reader indexes with the page
;          byte (0x2229) ALONE and never reads an argument, so its
;          3 entries are pages of one screen and not buttons.
; Evidence: `cp (0x2229),0x03` at 0xFF5C3E is the bound, the index is
;          `(0x2229) * 4` (`m_mul MB16,0x2229,3` -- the operand is
;          width-1), and `add XBC,0x00FF3D29` at 0xFF5C4D names the table.
;          The entry is CALLED: a return address is pushed before
;          `jp (XBC)`.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its ENTER
;          method, and its BUTTON method is that screen's control table.
; Was `sub_FF5C3E`, named by notes/prom_a_naming_wave8_apply.py.
; ---------------------------------------------------------------------
PageDispatch_MidiFileSave:
	cp	(UI_ScreenPage:16), 0x03                            ; FF5C3E  c1 29 22 3f 03
	jr ugt, .LFF5C5D                                     ; FF5C43  6b 18
	ld c, 0x04:opc                                          ; FF5C45  23 04
	mul	bc, (UI_ScreenPage:16)                              ; FF5C47  c1 29 22 43
	extz XBC                                             ; FF5C4B  e9 12
	add XBC,ScreenEnterPages_MidiFileSave                              ; FF5C4D  e9 c8 29 3d ff 00
	ld XBC,(XBC)                                         ; FF5C53  a1 21
	lda xiy, (.LFF5C5D:24)                               ; FF5C55  f2 5d 5c ff 35
	push XIY                                             ; FF5C5A  3d
	jp (xbc)                                             ; FF5C5B  b1 d8
.LFF5C5D:
	ret                                                  ; FF5C5D  0e
; ScreenEnter_MidiFileSave_Page0: ScreenEnterPages_MidiFileSave[0] -- what PageDispatch_MidiFileSave, the ENTER method of the MidiFileSave screen, runs
;   when UI_ScreenPage is 0 (notes/prom_a_page_enter_names.py).
ScreenEnter_MidiFileSave_Page0:   ; entry: named by 1 `.long` operand, first at 0xFF3D29
	push XHL                                             ; FF5C5E  3b
	ld (0x21fa:16), 0x00                                 ; FF5C5F  f1 fa 21 00 00
	call T_CallbackQueue_ResetAndRestartTask2            ; FF5C64  1d 80 2e f4
	ld c, (UI_ScreenLatch:16)                                   ; FF5C68  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FF5C6C  c1 7b 20 f3
	jr z, .LFF5CBE                                       ; FF5C70  66 4c
	call T_Playback_StopAllAndIgnoreMidiStart                                        ; FF5C72  1d 94 25 f4
	ld (0x2730:16), 0x00                                 ; FF5C76  f1 30 27 00 00
	set	6, (0x2094:16)                               ; FF5C7B  f1 94 20 be
	and	(0x133e:16), 0xfc                            ; FF5C7F  c1 3e 13 3c fc
	ld h, (Disk_FileName:16)                                   ; FF5C84  c1 c8 21 26
	cp H,0x30                                            ; FF5C88  ce cf 30
	jr z, .LFF5C9C                                       ; FF5C8B  66 0f
	cp H,0x31                                            ; FF5C8D  ce cf 31
	jr z, .LFF5C9C                                       ; FF5C90  66 0a
	cp H,0x32                                            ; FF5C92  ce cf 32
	jr z, .LFF5C9C                                       ; FF5C95  66 05
	cp H,0x3f                                            ; FF5C97  ce cf 3f
	jr nz, .LFF5CAF                                      ; FF5C9A  6e 13
.LFF5C9C:
	ldw hl, 0x00                                         ; FF5C9C  33 00 00
.LFF5C9F:
	extz XHL                                             ; FF5C9F  eb 12
	ld (XHL+Disk_FileName),0x5f                                 ; FF5CA1  f3 ed c8 21 00 5f
	inc 1,HL                                             ; FF5CA7  db 61
	cp HL,0x000b                                         ; FF5CA9  db cf 0b 00
	jr lt, .LFF5C9F                                      ; FF5CAD  61 f0
.LFF5CAF:
	ld (0x272e:16), 0x00                                 ; FF5CAF  f1 2e 27 00 00
	ld (Disk_SelectedEntry:16), 0x00                                 ; FF5CB4  f1 24 27 00 00
	ld (0x272d:16), 0x00                                 ; FF5CB9  f1 2d 27 00 00
.LFF5CBE:
	ld (NameEdit_CursorPos:16), 0x01                                 ; FF5CBE  f1 2d 22 00 01
	ld (0x2721:16), 0x01                                 ; FF5CC3  f1 21 27 00 01
	call T_NameEdit_SyncCharIndex_Call                                        ; FF5CC8  1d f8 25 f4
	pushw 0x03                                           ; FF5CCC  0b 03 00
	pushw 0x04                                           ; FF5CCF  0b 04 00
	calr PanelDial_SetButtonPair                                      ; FF5CD2  1e 55 14
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF5CD5  1d 04 76 ff
	pushw 0x00                                           ; FF5CD9  0b 00 00
	lda xbc, (ScreenEnter_MidiFileSave_Page0_DL:24)                              ; FF5CDC  f2 41 8a f5 31
	push XBC                                             ; FF5CE1  39
	lda xwa, (DL_MidiFileSaveFileNaming:24)              ; FF5CE2  f2 21 8a f5 30
	push XWA                                             ; FF5CE7  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF5CE8  1d d3 75 ff
	pushw 0x00                                           ; FF5CEC  0b 00 00
	lda xbc, (DL_F58786:24)                              ; FF5CEF  f2 86 87 f5 31
	push XBC                                             ; FF5CF4  39
	lda xwa, (DL_SaveFileDeletePositionAbc789:24)        ; FF5CF5  f2 71 86 f5 30
	push XWA                                             ; FF5CFA  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF5CFB  1d d3 75 ff
	call LCD_DrawDiskFileName8_SaveRegs                                      ; FF5CFF  1d 29 77 ff
	ld c, (NameEdit_CharIndex:16)                                   ; FF5D03  c1 f9 21 23
	ld (0x2729:16), c                                   ; FF5D07  f1 29 27 43
	lda xbc, (DL_F5879C:24)                              ; FF5D0B  f2 9c 87 f5 31
	push XBC                                             ; FF5D10  39
	lda xwa, (DL_F58786:24)                              ; FF5D11  f2 86 87 f5 30
	push XWA                                             ; FF5D16  38
	call DisplayListB_Run_SaveRegs                                      ; FF5D17  1d ef 75 ff
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF5D1B  1d 15 76 ff
	add XSP,0x00000020                                   ; FF5D1F  ef c8 20 00 00 00
	pop XHL                                              ; FF5D25  5b
	ret                                                  ; FF5D26  0e
; ScreenEnter_MidiFileSave_Page1: ScreenEnterPages_MidiFileSave[1] -- what PageDispatch_MidiFileSave, the ENTER method of the MidiFileSave screen, runs
;   when UI_ScreenPage is 1 (notes/prom_a_page_enter_names.py).
ScreenEnter_MidiFileSave_Page1:   ; entry: named by 1 `.long` operand, first at 0xFF3D2D
	push XIX                                             ; FF5D27  3c
	lda xix, (DisplayList_RunOnLayer_SaveRegs:24)                             ; FF5D28  f2 d3 75 ff 34
	call T_CallbackQueue_ResetAndRestartTask2            ; FF5D2D  1d 80 2e f4
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF5D31  1d 04 76 ff
	pushw 0x00                                           ; FF5D35  0b 00 00
	ld c, (0x2726:16)                                   ; FF5D38  c1 26 27 23
	and C,0x01                                           ; FF5D3C  cb cc 01
	jr z, .LFF5D4F                                       ; FF5D3F  66 0e
	lda xbc, (ScreenEnter_MidiFileSave_Page1_DL1:24)                              ; FF5D41  f2 18 92 f5 31
	push XBC                                             ; FF5D46  39
	lda xwa, (DL_F5920E:24)                              ; FF5D47  f2 0e 92 f5 30
	push XWA                                             ; FF5D4C  38
	jr .LFF5D5B                                          ; FF5D4D  68 0c
.LFF5D4F:
	lda xbc, (DL_MidiFileSaveFileSelecti0n:24)           ; FF5D4F  f2 22 92 f5 31
	push XBC                                             ; FF5D54  39
	lda xwa, (ScreenEnter_MidiFileSave_Page1_DL1:24)                              ; FF5D55  f2 18 92 f5 30
	push XWA                                             ; FF5D5A  38
.LFF5D5B:
	lda xiy, (.LFF5D63:24)                               ; FF5D5B  f2 63 5d ff 35
	push XIY                                             ; FF5D60  3d
	jp (xix)                                             ; FF5D61  b4 d8
.LFF5D63:
	pushw 0x00                                           ; FF5D63  0b 00 00
	lda xbc, (ScreenEnter_MidiFileSave_Page1_DL2:24)                              ; FF5D66  f2 01 93 f5 31
	push XBC                                             ; FF5D6B  39
	lda xwa, (DL_MidiFileSaveFileSelecti0n:24)           ; FF5D6C  f2 22 92 f5 30
	push XWA                                             ; FF5D71  38
	lda xiy, (.LFF5D7A:24)                               ; FF5D72  f2 7a 5d ff 35
	push XIY                                             ; FF5D77  3d
	jp (xix)                                             ; FF5D78  b4 d8
.LFF5D7A:
	pushw 0x02                                           ; FF5D7A  0b 02 00
	lda xbc, (DL_MidiFileL0adL0ad:24)                    ; FF5D7D  f2 0b 93 f5 31
	push XBC                                             ; FF5D82  39
	lda xwa, (ScreenEnter_MidiFileSave_Page1_DL2:24)                              ; FF5D83  f2 01 93 f5 30
	push XWA                                             ; FF5D88  38
	lda xiy, (.LFF5D91:24)                               ; FF5D89  f2 91 5d ff 35
	push XIY                                             ; FF5D8E  3d
	jp (xix)                                             ; FF5D8F  b4 d8
.LFF5D91:
	calr MidiFile_CountFileList                                      ; FF5D91  1e 54 f3
	pushw 0x0b                                           ; FF5D94  0b 0b 00
	pushw 0x0c                                           ; FF5D97  0b 0c 00
	calr PanelDial_SetButtonPair                                      ; FF5D9A  1e 8d 13
	pushw 0x00                                           ; FF5D9D  0b 00 00
	pushw 0x08                                           ; FF5DA0  0b 08 00
	calr MidiFile_DrawFileList                                      ; FF5DA3  1e 72 f3
	lda xbc, (DL_F5953B:24)                              ; FF5DA6  f2 3b 95 f5 31
	push XBC                                             ; FF5DAB  39
	call DLB_Array8_SaveRegs                                      ; FF5DAC  1d 3f 76 ff
	ld c, (Disk_SeqBank:16)                                   ; FF5DB0  c1 2b 27 23
	inc 1,C                                              ; FF5DB4  cb 61
	ld (0x2733:16), c                                   ; FF5DB6  f1 33 27 43
	lda xbc, (DL_F5993E:24)                              ; FF5DBA  f2 3e 99 f5 31
	push XBC                                             ; FF5DBF  39
	call DLB_Handler_Decimal_Veneer                                      ; FF5DC0  1d 68 76 ff
	ld c, (0x133e:16)                                   ; FF5DC4  c1 3e 13 23
	ld (0x2731:16), c                                   ; FF5DC8  f1 31 27 43
	lda xbc, (DL_F5993E:24)                              ; FF5DCC  f2 3e 99 f5 31
	push XBC                                             ; FF5DD1  39
	lda xwa, (ScreenEnter_MidiFileSave_Page1_DL3:24)                              ; FF5DD2  f2 15 99 f5 30
	push XWA                                             ; FF5DD7  38
	call T_DisplayListB_Run_Stack                        ; FF5DD8  1d 04 2e f4
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF5DDC  1d 15 76 ff
	add XSP,0x00000036                                   ; FF5DE0  ef c8 36 00 00 00
	pop XIX                                              ; FF5DE6  5c
	ret                                                  ; FF5DE7  0e
; ScreenEnter_MidiFileSave_Page2: ScreenEnterPages_MidiFileSave[2] -- what PageDispatch_MidiFileSave, the ENTER method of the MidiFileSave screen, runs
;   when UI_ScreenPage is 2 (notes/prom_a_page_enter_names.py).
ScreenEnter_MidiFileSave_Page2:   ; entry: named by 1 `.long` operand, first at 0xFF3D31
	push XIX                                             ; FF5DE8  3c
	lda xix, (DisplayList_RunOnLayer_SaveRegs:24)                             ; FF5DE9  f2 d3 75 ff 34
	call T_CallbackQueue_ResetAndRestartTask2            ; FF5DEE  1d 80 2e f4
	call T_Playback_StopAllAndIgnoreMidiStart                                        ; FF5DF2  1d 94 25 f4
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF5DF6  1d 04 76 ff
	pushw 0x00                                           ; FF5DFA  0b 00 00
	lda xbc, (DL_MidiFileSaveFileDelete:24)              ; FF5DFD  f2 b7 8a f5 31
	push XBC                                             ; FF5E02  39
	lda xwa, (DL_MidiFileSave:24)                        ; FF5E03  f2 a5 8a f5 30
	push XWA                                             ; FF5E08  38
	lda xiy, (.LFF5E11:24)                               ; FF5E09  f2 11 5e ff 35
	push XIY                                             ; FF5E0E  3d
	jp (xix)                                             ; FF5E0F  b4 d8
.LFF5E11:
	pushw 0x00                                           ; FF5E11  0b 00 00
	lda xbc, (DL_LoadL0adFileLoadL0ad0pti0n:24)          ; FF5E14  f2 b0 81 f5 31
	push XBC                                             ; FF5E19  39
	lda xwa, (DL_F58162:24)                              ; FF5E1A  f2 62 81 f5 30
	push XWA                                             ; FF5E1F  38
	lda xiy, (.LFF5E28:24)                               ; FF5E20  f2 28 5e ff 35
	push XIY                                             ; FF5E25  3d
	jp (xix)                                             ; FF5E26  b4 d8
.LFF5E28:
	pushw 0x00                                           ; FF5E28  0b 00 00
	lda xbc, (DLText_F59C2C:24)                          ; FF5E2B  f2 2c 9c f5 31
	push XBC                                             ; FF5E30  39
	lda xwa, (DL_AttentionAFileAlreadyExistsAtThe:24)    ; FF5E31  f2 86 9b f5 30
	push XWA                                             ; FF5E36  38
	lda xiy, (.LFF5E3F:24)                               ; FF5E37  f2 3f 5e ff 35
	push XIY                                             ; FF5E3C  3d
	jp (xix)                                             ; FF5E3D  b4 d8
.LFF5E3F:
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF5E3F  1d 15 76 ff
	add XSP,0x0000001e                                   ; FF5E43  ef c8 1e 00 00 00
	pop XIX                                              ; FF5E49  5c
	ret                                                  ; FF5E4A  0e
; ScreenEnter_MidiFileSave_Page3: ScreenEnterPages_MidiFileSave[3] -- what PageDispatch_MidiFileSave, the ENTER method of the MidiFileSave screen, runs
;   when UI_ScreenPage is 3 (notes/prom_a_page_enter_names.py).
ScreenEnter_MidiFileSave_Page3:   ; entry: named by 1 `.long` operand, first at 0xFF3D35
	push XIX                                             ; FF5E4B  3c
	lda xix, (DisplayList_RunOnLayer_SaveRegs:24)                             ; FF5E4C  f2 d3 75 ff 34
	call T_CallbackQueue_ResetAndRestartTask2            ; FF5E51  1d 80 2e f4
	call T_Playback_StopAllAndIgnoreMidiStart                                        ; FF5E55  1d 94 25 f4
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF5E59  1d 04 76 ff
	pushw 0x00                                           ; FF5E5D  0b 00 00
	lda xbc, (DL_LoadSingleSoundDiskGr0upSingleFileBankS0undGr0up:24) ; FF5E60  f2 d7 8a f5 31
	push XBC                                             ; FF5E65  39
	lda xwa, (DL_MidiFileSaveFileDelete:24)              ; FF5E66  f2 b7 8a f5 30
	push XWA                                             ; FF5E6B  38
	lda xiy, (.LFF5E74:24)                               ; FF5E6C  f2 74 5e ff 35
	push XIY                                             ; FF5E71  3d
	jp (xix)                                             ; FF5E72  b4 d8
.LFF5E74:
	pushw 0x00                                           ; FF5E74  0b 00 00
	lda xbc, (DL_LoadL0adFileLoadL0ad0pti0n:24)          ; FF5E77  f2 b0 81 f5 31
	push XBC                                             ; FF5E7C  39
	lda xwa, (DL_F58162:24)                              ; FF5E7D  f2 62 81 f5 30
	push XWA                                             ; FF5E82  38
	lda xiy, (.LFF5E8B:24)                               ; FF5E83  f2 8b 5e ff 35
	push XIY                                             ; FF5E88  3d
	jp (xix)                                             ; FF5E89  b4 d8
.LFF5E8B:
	pushw 0x00                                           ; FF5E8B  0b 00 00
	lda xbc, (DL_DiskSave:24)                            ; FF5E8E  f2 79 9b f5 31
	push XBC                                             ; FF5E93  39
	lda xwa, (DL_AttentionUsingFileDeleteWillErase:24)   ; FF5E94  f2 d0 9a f5 30
	push XWA                                             ; FF5E99  38
	lda xiy, (.LFF5EA2:24)                               ; FF5E9A  f2 a2 5e ff 35
	push XIY                                             ; FF5E9F  3d
	jp (xix)                                             ; FF5EA0  b4 d8
.LFF5EA2:
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF5EA2  1d 15 76 ff
	add XSP,0x0000001e                                   ; FF5EA6  ef c8 1e 00 00 00
	pop XIX                                              ; FF5EAC  5c
	ret                                                  ; FF5EAD  0e
; ---------------------------------------------------------------------
; ScreenLeave_MidiFileSave -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x6E -> the screen object at
;          0xF423C0, whose +4 slot is `jp 0xFF5EAE`, and from no other live
;          screen object's two callable slots.
; Evidence: the +4 offset is PanelScreen_VtableTable's own (its header's
;          checks V1-V6): +0 ENTER is called by PanelScreen_CallEnter_A/B, +4
;          LEAVE by PanelScreen_CallLeave_A/B with the id that just STOPPED
;          being current, +8 BUTTON by PanelButton_Route (0xF8621E).
; Screen:   MidiFileSave -- inherited from the +0 ENTER label
;          PageDispatch_MidiFileSave, not from any text this pass read.
; Was `sub_FF5EAE`.
; ---------------------------------------------------------------------
ScreenLeave_MidiFileSave:
	ld c, (UI_ScreenLatch:16)                                   ; FF5EAE  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FF5EB2  c1 7b 20 f3
	jr z, .LFF5ED0                                       ; FF5EB6  66 18
	call DiskFileScreen_LeaveCommon                                      ; FF5EB8  1d 8c 79 ff
	ld (0x272f:16), 0x00                                 ; FF5EBC  f1 2f 27 00 00
	ld (0x272e:16), 0x00                                 ; FF5EC1  f1 2e 27 00 00
	ld (0x272d:16), 0x00                                 ; FF5EC6  f1 2d 27 00 00
	ld (Disk_SelectedEntry:16), 0x00                                 ; FF5ECB  f1 24 27 00 00
.LFF5ED0:
	ret                                                  ; FF5ED0  0e
; ---------------------------------------------------------------------
; PanelButtonDispatch_MidiFileSave -- run Dispatch_FF3D39's handler for one
;          PANEL CONTROL
;
; Inputs:   (XIZ+0x08) = the 5-bit panel control index; (XIZ+0x0A) =
;          the argument this reader forwards to the handler.
; Evidence: `cp H,0x20` at 0xFF5ED9 bounds the index to the 32-code
;          panel space PanelButton_Route's `and L,0x1f`
;          (0xF861AE) produces, and `add XBC,0x00FF3D39` at 0xFF5EF6
;          names the table.
;          The handler is CALLED, not jumped to: the reader pushes
;          a return address before `jp (XBC)`.
; Control legend: notes/FINDINGS-prom_a-panel-control-map.md, and
;          `python3 notes/prom_a_panel_control_map.py --map`.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Was `sub_FF5ED1`, named by notes/prom_a_naming_wave8_apply.py.
; ---------------------------------------------------------------------
PanelButtonDispatch_MidiFileSave:
	link XIZ,0x0000                                      ; FF5ED1  ee 0c 00 00
	pushw hl                                             ; FF5ED5  2b
	ld H,(XIZ+0x08)                                      ; FF5ED6  8e 08 26
	cp H,0x20                                            ; FF5ED9  ce cf 20
	jr nc, .LFF5F07                                      ; FF5EDC  6f 29
	cp	(UI_ScreenPage:16), 0x05                            ; FF5EDE  c1 29 22 3f 05
	jr nc, .LFF5F07                                      ; FF5EE3  6f 22
	pushw	(xiz+10)                                     ; FF5EE5  9e 0a 04
	ld c, (UI_ScreenPage:16)                                   ; FF5EE8  c1 29 22 23
	sll c, 0x05                                          ; FF5EEC  cb ee 05
	add C,H                                              ; FF5EEF  ce 83
	mul C,0x04                                           ; FF5EF1  cb 08 04
	extz XBC                                             ; FF5EF4  e9 12
	add XBC,Dispatch_FF3D39                              ; FF5EF6  e9 c8 39 3d ff 00
	ld XBC,(XBC)                                         ; FF5EFC  a1 21
	lda xiy, (.LFF5F06:24)                               ; FF5EFE  f2 06 5f ff 35
	push XIY                                             ; FF5F03  3d
	jp (xbc)                                             ; FF5F04  b1 d8
.LFF5F06:
	popw bc                                              ; FF5F06  49
.LFF5F07:
	popw hl                                              ; FF5F07  4b
	unlk XIZ                                             ; FF5F08  ee 0d
	ret                                                  ; FF5F0A  0e
; SoftKeyCol1_MidiFileSave_Page0: Dispatch_FF3D39+0[0] -- the SoftKeyCol1 handler of MidiFileSave_Page0; the table's other named entries sit at their own
;   controls' slots and name the same screen (notes/prom_ab_button_table_siblings.py).
SoftKeyCol1_MidiFileSave_Page0:   ; entry: named by 2 `.long` operands, first at 0xFF3D39
	pushw 0x01                                           ; FF5F0B  0b 01 00
	calr MidiFileSave_MoveNameCursor                                      ; FF5F0E  1e 0a 00
	popw bc                                              ; FF5F11  49
	ret                                                  ; FF5F12  0e
; SoftKeyCol2_MidiFileSave_Page0: Dispatch_FF3D39+0[1] -- the SoftKeyCol2 handler of MidiFileSave_Page0; the table's other named entries sit at their own
;   controls' slots and name the same screen (notes/prom_ab_button_table_siblings.py).
SoftKeyCol2_MidiFileSave_Page0:   ; entry: named by 2 `.long` operands, first at 0xFF3D3D
	pushw 0x00                                           ; FF5F13  0b 00 00
	calr MidiFileSave_MoveNameCursor                                      ; FF5F16  1e 02 00
	popw bc                                              ; FF5F19  49
	ret                                                  ; FF5F1A  0e
; MidiFileSave_MoveNameCursor: (dir): NameEdit_CursorPos -1 (not below 1) when dir != 0, else +1 (not above 8),
;   mirrored in (0x2721), NameEdit_SyncCharIndex, (0x2729) := NameEdit_CharIndex; the cursor cell is redrawn on layer
;   1 before and after (DL_F5879C / DL_F58786). SoftKeyCol1 (dir 1) and SoftKeyCol2 (dir 0) of MIDI FILE SAVE page 0
;   -- that screen's counterpart of NameEdit_MoveCursor. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_g.json)
MidiFileSave_MoveNameCursor:
	link XIZ,0x0000                                      ; FF5F1B  ee 0c 00 00
	push XIX                                             ; FF5F1F  3c
	lda xix, (NameEdit_CursorPos:16)                                ; FF5F20  f1 2d 22 34
	ld c, (NameEdit_CharIndex:16)                                   ; FF5F24  c1 f9 21 23
	ld (0x2729:16), c                                   ; FF5F28  f1 29 27 43
	pushw 0x03                                           ; FF5F2C  0b 03 00
	pushw 0x04                                           ; FF5F2F  0b 04 00
; (sub_FF5F32 removed 2026-10-04: no code names it and the line above falls through into it -- part of MidiFileSave_MoveNameCursor;
;  notes/prom_a_stray_label_removal.py)
	calr PanelDial_SetButtonPair                                      ; FF5F32  1e f5 11
	ld (LCD_CurrentLayer:16), 0x01                                 ; FF5F35  f1 40 25 00 01
	lda xbc, (CharPalette_F587B2:24)                     ; FF5F3A  f2 b2 87 f5 31
	push XBC                                             ; FF5F3F  39
	lda xwa, (DL_F5879C:24)                              ; FF5F40  f2 9c 87 f5 30
	push XWA                                             ; FF5F45  38
	call T_DisplayListB_Run_Stack                        ; FF5F46  1d 04 2e f4
	inc 8,XSP                                            ; FF5F4A  ef 60
	inc 4,XSP                                            ; FF5F4C  ef 64
	cpw	(xiz+8), 0x0000                              ; FF5F4E  9e 08 3f 00 00
	jr z, .LFF5F5F                                       ; FF5F53  66 0a
	ld C,(XIX)                                           ; FF5F55  84 23
	cp c, 0x01:i3                                          ; FF5F57  cb d9
	jr ule, .LFF5F68                                     ; FF5F59  63 0d
	decm8 0x01, (xix)                                    ; FF5F5B  84 69
	jr .LFF5F68                                          ; FF5F5D  68 09
.LFF5F5F:
	ld C,(XIX)                                           ; FF5F5F  84 23
	cp C,0x08                                            ; FF5F61  cb cf 08
	jr nc, .LFF5F68                                      ; FF5F64  6f 02
	incm8 0x01, (xix)                                    ; FF5F66  84 61
.LFF5F68:
	ld C,(XIX)                                           ; FF5F68  84 23
	ld (0x2721:16), c                                   ; FF5F6A  f1 21 27 43
	call T_NameEdit_SyncCharIndex_Call                                        ; FF5F6E  1d f8 25 f4
	ld c, (NameEdit_CharIndex:16)                                   ; FF5F72  c1 f9 21 23
	ld (0x2729:16), c                                   ; FF5F76  f1 29 27 43
	lda xbc, (DL_F5879C:24)                              ; FF5F7A  f2 9c 87 f5 31
	push XBC                                             ; FF5F7F  39
	lda xwa, (DL_F58786:24)                              ; FF5F80  f2 86 87 f5 30
	push XWA                                             ; FF5F85  38
	call T_DisplayListB_Run_Stack                        ; FF5F86  1d 04 2e f4
	inc 8,XSP                                            ; FF5F8A  ef 60
	pop XIX                                              ; FF5F8C  5c
	unlk XIZ                                             ; FF5F8D  ee 0d
	ret                                                  ; FF5F8F  0e
; SoftKeyCol4_MidiFileSave_Page0: Dispatch_FF3D39+0[3] -- the SoftKeyCol4 handler of MidiFileSave_Page0; the table's other named entries sit at their own
;   controls' slots and name the same screen (notes/prom_ab_button_table_siblings.py).
SoftKeyCol4_MidiFileSave_Page0:   ; entry: named by 2 `.long` operands, first at 0xFF3D45
	pushw 0x81                                           ; FF5F90  0b 81 00
	calr MidiFileSave_StepNameChar                                      ; FF5F93  1e 0a 00
	popw bc                                              ; FF5F96  49
	ret                                                  ; FF5F97  0e
; SoftKeyCol5_MidiFileSave_Page0: Dispatch_FF3D39+0[4] -- the SoftKeyCol5 handler of MidiFileSave_Page0; the table's other named entries sit at their own
;   controls' slots and name the same screen (notes/prom_ab_button_table_siblings.py).
SoftKeyCol5_MidiFileSave_Page0:   ; entry: named by 2 `.long` operands, first at 0xFF3D49
	pushw 0x01                                           ; FF5F98  0b 01 00
; (sub_FF5F9B removed 2026-10-04: no code names it and the line above falls through into it -- part of SoftKeyCol5_MidiFileSave_Page0;
;  notes/prom_a_stray_label_removal.py)
	calr MidiFileSave_StepNameChar                                      ; FF5F9B  1e 02 00
	popw bc                                              ; FF5F9E  49
	ret                                                  ; FF5F9F  0e
; MidiFileSave_StepNameChar: Steps the file-name character at the cursor: (0x272C) := the key code (0x81 back, 0x01
;   forward) for NameEdit_StepChar, with the character palette highlight redrawn and the 8-character file name
;   repainted. Soft keys 4 and 5 of MIDI FILE SAVE page 0. Basis: callers + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_h.json)
MidiFileSave_StepNameChar:
	link XIZ,0x0000                                      ; FF5FA0  ee 0c 00 00
	ld c, (NameEdit_CharIndex:16)                                   ; FF5FA4  c1 f9 21 23
	ld (0x2729:16), c                                   ; FF5FA8  f1 29 27 43
	pushw 0x03                                           ; FF5FAC  0b 03 00
	pushw 0x04                                           ; FF5FAF  0b 04 00
	calr PanelDial_SetButtonPair                                      ; FF5FB2  1e 75 11
	ld (LCD_CurrentLayer:16), 0x01                                 ; FF5FB5  f1 40 25 00 01
	lda xbc, (CharPalette_F587B2:24)                     ; FF5FBA  f2 b2 87 f5 31
	push XBC                                             ; FF5FBF  39
	lda xwa, (DL_F5879C:24)                              ; FF5FC0  f2 9c 87 f5 30
	push XWA                                             ; FF5FC5  38
	call T_DisplayListB_Run_Stack                        ; FF5FC6  1d 04 2e f4
	ld C,(XIZ+0x08)                                      ; FF5FCA  8e 08 23
	ld (0x272c:16), c                                   ; FF5FCD  f1 2c 27 43
	call T_NameEdit_StepChar_Call                                        ; FF5FD1  1d d8 25 f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF5FD5  f1 40 25 00 00
	call LCD_DrawDiskFileName8_SaveRegs                                      ; FF5FDA  1d 29 77 ff
	ld c, (NameEdit_CharIndex:16)                                   ; FF5FDE  c1 f9 21 23
	ld (0x2729:16), c                                   ; FF5FE2  f1 29 27 43
	lda xbc, (DL_F5879C:24)                              ; FF5FE6  f2 9c 87 f5 31
	push XBC                                             ; FF5FEB  39
	lda xwa, (DL_F58786:24)                              ; FF5FEC  f2 86 87 f5 30
	push XWA                                             ; FF5FF1  38
	call T_DisplayListB_Run_Stack                        ; FF5FF2  1d 04 2e f4
	add XSP,0x00000014                                   ; FF5FF6  ef c8 14 00 00 00
	unlk XIZ                                             ; FF5FFC  ee 0d
	ret                                                  ; FF5FFE  0e
; SoftKeyCol7_MidiFileSave_Page0: Dispatch_FF3D39+0[6] -- the SoftKeyCol7 handler of MidiFileSave_Page0; the table's other named entries sit at their own
;   controls' slots and name the same screen (notes/prom_ab_button_table_siblings.py).
SoftKeyCol7_MidiFileSave_Page0:   ; entry: named by 2 `.long` operands, first at 0xFF3D51
	push XHL                                             ; FF5FFF  3b
	pushw 0x03                                           ; FF6000  0b 03 00
	pushw 0x04                                           ; FF6003  0b 04 00
	calr PanelDial_SetButtonPair                                      ; FF6006  1e 21 11
	ld c, (NameEdit_CharIndex:16)                                   ; FF6009  c1 f9 21 23
	ld (0x2729:16), c                                   ; FF600D  f1 29 27 43
	ld (LCD_CurrentLayer:16), 0x01                                 ; FF6011  f1 40 25 00 01
	lda xbc, (CharPalette_F587B2:24)                     ; FF6016  f2 b2 87 f5 31
	push XBC                                             ; FF601B  39
	lda xwa, (DL_F5879C:24)                              ; FF601C  f2 9c 87 f5 30
	push XWA                                             ; FF6021  38
	call T_DisplayListB_Run_Stack                        ; FF6022  1d 04 2e f4
	ldw hl, 0x00                                         ; FF6026  33 00 00
	inc 8,XSP                                            ; FF6029  ef 60
	inc 4,XSP                                            ; FF602B  ef 64
.LFF602D:
	extz XHL                                             ; FF602D  eb 12
	ld (XHL+Disk_FileName),0x5f                                 ; FF602F  f3 ed c8 21 00 5f
	inc 1,HL                                             ; FF6035  db 61
	cp HL,0x0008                                         ; FF6037  db cf 08 00
	jr lt, .LFF602D                                      ; FF603B  61 f0
	ld (0x2721:16), 0x01                                 ; FF603D  f1 21 27 00 01
	ld (NameEdit_CursorPos:16), 0x01                                 ; FF6042  f1 2d 22 00 01
	ld (NameEdit_CharIndex:16), 0x00                                 ; FF6047  f1 f9 21 00 00
	ld (0x2729:16), 0x00                                 ; FF604C  f1 29 27 00 00
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF6051  f1 40 25 00 00
	call LCD_DrawDiskFileName8_SaveRegs                                      ; FF6056  1d 29 77 ff
	lda xbc, (DL_F5879C:24)                              ; FF605A  f2 9c 87 f5 31
	push XBC                                             ; FF605F  39
	lda xwa, (DL_F58786:24)                              ; FF6060  f2 86 87 f5 30
	push XWA                                             ; FF6065  38
	call T_DisplayListB_Run_Stack                        ; FF6066  1d 04 2e f4
	inc 8,XSP                                            ; FF606A  ef 60
	pop XHL                                              ; FF606C  5b
	ret                                                  ; FF606D  0e
; ---------------------------------------------------------------------
; LcdKeyRow1_MidiFileSave_Page0 -- what Dispatch_FF3D39 runs for panel
;          control 0x08
;
; Reached from: Dispatch_FF3D39 entry [8] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x08 is the LCD row 1 button pair -- the left-hand and
;          right-hand buttons of the display's TOP row. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow1_MidiFileSave_Page0:
	link XIZ,0x0000                                      ; FF606E  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF6072  9e 08 21
	and BC,0x0080                                        ; FF6075  d9 cc 80 00
	jr nz, .LFF60A6                                      ; FF6079  6e 2b
	res	3, (UI_RequestBits:16)                               ; FF607B  f1 75 20 b3
	ld (UI_ScreenPage:16), 0x01                                 ; FF607F  f1 29 22 00 01
	ld (UI_Request_Hi:16), 0x10                                 ; FF6084  f1 71 20 00 10
	res	0, (0x2726:16)                               ; FF6089  f1 26 27 b0
	call T_Playback_StopAllAndIgnoreMidiStart                                        ; FF608D  1d 94 25 f4
	call T_Disk_MountAndScanMidiFilesResetRings                                        ; FF6091  1d 14 26 f4
	calr UI_StatusCode_Is0or2or4                                      ; FF6095  1e 04 15
	cp wa, 0x00:i3                                         ; FF6098  d8 d8
	jr z, .LFF60A6                                       ; FF609A  66 0a
	ld (UI_Request:16), 0x40                                 ; FF609C  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF60A1  f1 71 20 00 80
.LFF60A6:
	unlk XIZ                                             ; FF60A6  ee 0d
	ret                                                  ; FF60A8  0e
; ---------------------------------------------------------------------
; LcdKeyRow4_MidiFileSave_Page0 -- what Dispatch_FF3D39 runs for panel
;          control 0x0B
;
; Reached from: Dispatch_FF3D39 entry [11] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x0B is the LCD row 4 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow4_MidiFileSave_Page0:
	link XIZ,0x0000                                      ; FF60A9  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF60AD  9e 08 21
	and BC,0x0080                                        ; FF60B0  d9 cc 80 00
	jr nz, .LFF60DD                                      ; FF60B4  6e 27
	set	0, (0x2726:16)                               ; FF60B6  f1 26 27 b8
	ld (UI_ScreenPage:16), 0x01                                 ; FF60BA  f1 29 22 00 01
	ld (UI_Request_Hi:16), 0x10                                 ; FF60BF  f1 71 20 00 10
	call T_Playback_StopAllAndIgnoreMidiStart                                        ; FF60C4  1d 94 25 f4
	call T_Disk_MountAndScanMidiFilesResetRings                                        ; FF60C8  1d 14 26 f4
	calr UI_StatusCode_Is0or2or4                                      ; FF60CC  1e cd 14
	cp wa, 0x00:i3                                         ; FF60CF  d8 d8
	jr z, .LFF60DD                                       ; FF60D1  66 0a
	ld (UI_Request:16), 0x40                                 ; FF60D3  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF60D8  f1 71 20 00 80
.LFF60DD:
	unlk XIZ                                             ; FF60DD  ee 0d
	ret                                                  ; FF60DF  0e
; ---------------------------------------------------------------------
; ExitKey_MidiFileSave_Pages0_1_2_3 -- what Dispatch_FF3D39 runs for panel
;          control 0x0F
;
; Reached from: Dispatch_FF3D39 entry [15], Dispatch_FF3D39 entry [47] (page
;          1, control 0x0F), Dispatch_FF3D39 entry [79] (page 2, control
;          0x0F), Dispatch_FF3D39 entry [111] (page 3, control 0x0F) -- and
;          from no other slot of any 32-entry control table in prom_a. A
;          target reached at two DIFFERENT indices is refused by the script
;          that wrote this.
; Control:  index 0x0F is the EXIT key. The pair position -- which of the two
;          keys -- reaches the handler in the argument the reader forwards;
;          this pass did NOT establish that argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
ExitKey_MidiFileSave_Pages0_1_2_3:
	link XIZ,0x0000                                      ; FF60E0  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF60E4  9e 08 21
	and BC,0x0080                                        ; FF60E7  d9 cc 80 00
	jr nz, .LFF60F7                                      ; FF60EB  6e 0a
	ld (UI_Request:16), 0x40                                 ; FF60ED  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF60F2  f1 71 20 00 80
.LFF60F7:
	unlk XIZ                                             ; FF60F7  ee 0d
	ret                                                  ; FF60F9  0e
; ---------------------------------------------------------------------
; LcdKeyRow1_MidiFileSave_Page1 -- what Dispatch_FF3D39 runs for panel
;          control 0x08
;
; Reached from: Dispatch_FF3D39 entry [40] (page 1, control 0x08) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x08 is the LCD row 1 button pair -- the left-hand and
;          right-hand buttons of the display's TOP row. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow1_MidiFileSave_Page1:
	link XIZ,0xfffc                                      ; FF60FA  ee 0c fc ff
	push XIX                                             ; FF60FE  3c
	lda xix, (UI_Request_Hi:16)                                ; FF60FF  f1 71 20 34
	ld BC,(XIZ+0x08)                                     ; FF6103  9e 08 21
	and BC,0x0080                                        ; FF6106  d9 cc 80 00
	jr nz, .LFF6163                                      ; FF610A  6e 57
	ld c, (0x2726:16)                                   ; FF610C  c1 26 27 23
	and C,0x01                                           ; FF6110  cb cc 01
	jr nz, .LFF6140                                      ; FF6113  6e 2b
	call T_MidiFileSave_WriteSeqBankSmf                                        ; FF6115  1d 84 33 f4
	cp	(UI_ScreenPage:16), 0x02                            ; FF6119  c1 29 22 3f 02
	jr z, .LFF615E                                       ; FF611E  66 3e
	cp	(UI_StatusCode:16), 0x23                            ; FF6120  c1 80 28 3f 23
	jr nz, .LFF6136                                      ; FF6125  6e 0f
	ld (UI_ScreenPage:16), 0x00                                 ; FF6127  f1 29 22 00 00
	ld (UI_Request:16), 0x01                                 ; FF612C  f1 70 20 00 01
	ld (XIX),0x02                                        ; FF6131  b4 00 02
	jr .LFF617E                                          ; FF6134  68 48
.LFF6136:
	ld (UI_Request:16), 0xab                                 ; FF6136  f1 70 20 00 ab
	ld (XIX),0x40                                        ; FF613B  b4 00 40
	jr .LFF617E                                          ; FF613E  68 3e
.LFF6140:
	lda xbc, (0x60a480:24)                               ; FF6140  f2 80 a4 60 31
	ld (xiz-4), xbc                                      ; FF6145  be fc 61
	ld a, 0x08:opc                                          ; FF6148  21 08
	mul	wa, (Disk_SelectedEntry:16)                              ; FF614A  c1 24 27 41
	extz XWA                                             ; FF614E  e8 12
	add XBC,XWA                                          ; FF6150  e8 81
	ld A,(XBC)                                           ; FF6152  81 21
	cp A,0x20                                            ; FF6154  c9 cf 20
	jr z, .LFF617E                                       ; FF6157  66 25
	ld (UI_ScreenPage:16), 0x03                                 ; FF6159  f1 29 22 00 03
.LFF615E:
	or	(xix), 0x10                                  ; FF615E  84 3e 10
	jr .LFF617E                                          ; FF6161  68 1b
.LFF6163:
	lda xbc, (DL_F59409:24)                              ; FF6163  f2 09 94 f5 31
	push XBC                                             ; FF6168  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF6169  1d 23 76 ff
	ld (0x2730:16), 0x00                                 ; FF616D  f1 30 27 00 00
	lda xbc, (0xf59933:24)                               ; FF6172  f2 33 99 f5 31
	push XBC                                             ; FF6177  39
	call DLB_Array8_SaveRegs                                      ; FF6178  1d 3f 76 ff
	inc 8,XSP                                            ; FF617C  ef 60
.LFF617E:
	pop XIX                                              ; FF617E  5c
	unlk XIZ                                             ; FF617F  ee 0d
	ret                                                  ; FF6181  0e
; ---------------------------------------------------------------------
; LcdKeyRow2_MidiFileSave_Page1 -- what Dispatch_FF3D39 runs for panel
;          control 0x09
;
; Reached from: Dispatch_FF3D39 entry [41] (page 1, control 0x09) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x09 is the LCD row 2 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow2_MidiFileSave_Page1:
	link XIZ,0x0000                                      ; FF6182  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF6186  9e 08 21
	and BC,0x0080                                        ; FF6189  d9 cc 80 00
	jr z, .LFF61AA                                       ; FF618D  66 1b
	lda xbc, (DL_F59409:24)                              ; FF618F  f2 09 94 f5 31
	push XBC                                             ; FF6194  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF6195  1d 23 76 ff
	ld (0x2730:16), 0x00                                 ; FF6199  f1 30 27 00 00
	lda xbc, (0xf59933:24)                               ; FF619E  f2 33 99 f5 31
	push XBC                                             ; FF61A3  39
	call DLB_Array8_SaveRegs                                      ; FF61A4  1d 3f 76 ff
	inc 8,XSP                                            ; FF61A8  ef 60
.LFF61AA:
	unlk XIZ                                             ; FF61AA  ee 0d
	ret                                                  ; FF61AC  0e
; ---------------------------------------------------------------------
; LcdKeyRow3_MidiFileSave_Page1 -- what Dispatch_FF3D39 runs for panel
;          control 0x0A
;
; Reached from: Dispatch_FF3D39 entry [42] (page 1, control 0x0A) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x0A is the LCD row 3 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow3_MidiFileSave_Page1:
	link XIZ,0x0000                                      ; FF61AD  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF61B1  9e 08 21
	and BC,0x0080                                        ; FF61B4  d9 cc 80 00
	jr z, .LFF61D5                                       ; FF61B8  66 1b
	lda xbc, (DL_F59409:24)                              ; FF61BA  f2 09 94 f5 31
	push XBC                                             ; FF61BF  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF61C0  1d 23 76 ff
	ld (0x2730:16), 0x01                                 ; FF61C4  f1 30 27 00 01
	lda xbc, (0xf59933:24)                               ; FF61C9  f2 33 99 f5 31
	push XBC                                             ; FF61CE  39
	call DLB_Array8_SaveRegs                                      ; FF61CF  1d 3f 76 ff
	inc 8,XSP                                            ; FF61D3  ef 60
.LFF61D5:
	unlk XIZ                                             ; FF61D5  ee 0d
	ret                                                  ; FF61D7  0e
; ---------------------------------------------------------------------
; LcdKeyRow4_MidiFileSave_Page1 -- what Dispatch_FF3D39 runs for panel
;          control 0x0B
;
; Reached from: Dispatch_FF3D39 entry [43] (page 1, control 0x0B) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x0B is the LCD row 4 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow4_MidiFileSave_Page1:
	link XIZ,0x0000                                      ; FF61D8  ee 0c 00 00
	push XIX                                             ; FF61DC  3c
	lda xix, (0x133e:16)                                ; FF61DD  f1 3e 13 34
	pushw 0x0b                                           ; FF61E1  0b 0b 00
	pushw 0x0c                                           ; FF61E4  0b 0c 00
	calr PanelDial_SetButtonPair                                      ; FF61E7  1e 40 0f
	ld BC,(XIZ+0x08)                                     ; FF61EA  9e 08 21
	and BC,0x0080                                        ; FF61ED  d9 cc 80 00
	pop XIY                                              ; FF61F1  5d
	jrl nz, .LFF6291                                     ; FF61F2  7e 9c 00
	ld bc, (0x2730:16)                                 ; FF61F5  d1 30 27 21
	extz BC                                              ; FF61F9  d9 12
	cp bc, 0x00:i3                                         ; FF61FB  d9 d8
	jr z, .LFF620E                                       ; FF61FD  66 0f
	cp bc, 0x01:i3                                         ; FF61FF  d9 d9
	jr z, .LFF6238                                       ; FF6201  66 35
	cp bc, 0x02:i3                                         ; FF6203  d9 da
	jr z, .LFF6259                                       ; FF6205  66 52
	cp bc, 0x03:i3                                         ; FF6207  d9 db
	jr z, .LFF626E                                       ; FF6209  66 63
	jrl .LFF62AC                                         ; FF620B  78 9e 00
.LFF620E:
	lda xbc, (DL_F59409:24)                              ; FF620E  f2 09 94 f5 31
	push XBC                                             ; FF6213  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF6214  1d 23 76 ff
	lda xbc, (DL_F59546:24)                              ; FF6218  f2 46 95 f5 31
	push XBC                                             ; FF621D  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF621E  1d 23 76 ff
	pushw 0x00                                           ; FF6222  0b 00 00
	pushw 0x08                                           ; FF6225  0b 08 00
	calr MidiFile_LcdKeyRow4                                      ; FF6228  1e 5d 01
	inc 8,XSP                                            ; FF622B  ef 60
	inc 4,XSP                                            ; FF622D  ef 64
	lda xbc, (DL_F5953B:24)                              ; FF622F  f2 3b 95 f5 31
	push XBC                                             ; FF6234  39
	jrl .LFF62A7                                         ; FF6235  78 6f 00
.LFF6238:
	cp	(Disk_SeqBank:16), 0x09                            ; FF6238  c1 2b 27 3f 09
	jr nc, .LFF6243                                      ; FF623D  6f 04
	inc 0x01, (Disk_SeqBank:16)                                ; FF623F  c1 2b 27 61
.LFF6243:
	ld c, (Disk_SeqBank:16)                                   ; FF6243  c1 2b 27 23
	inc 1,C                                              ; FF6247  cb 61
	ld (0x2733:16), c                                   ; FF6249  f1 33 27 43
	lda xbc, (DL_F5993E:24)                              ; FF624D  f2 3e 99 f5 31
	push XBC                                             ; FF6252  39
	call DLB_Handler_Decimal_Veneer                                      ; FF6253  1d 68 76 ff
	jr .LFF62AB                                          ; FF6257  68 52
.LFF6259:
	ld C,(XIX)                                           ; FF6259  84 23
	and C,0x01                                           ; FF625B  cb cc 01
	jr nz, .LFF62AC                                      ; FF625E  6e 4c
	or	(xix), 0x01                                  ; FF6260  84 3e 01
	pushw 0x06                                           ; FF6263  0b 06 00
	pushw 0x03                                           ; FF6266  0b 03 00
	pushw 0x1b6e                                         ; FF6269  0b 6e 1b
	jr .LFF6281                                          ; FF626C  68 13
.LFF626E:
	ld C,(XIX)                                           ; FF626E  84 23
	and C,0x02                                           ; FF6270  cb cc 02
	jr nz, .LFF62AC                                      ; FF6273  6e 37
	or	(xix), 0x02                                  ; FF6275  84 3e 02
	pushw 0x06                                           ; FF6278  0b 06 00
	pushw 0x03                                           ; FF627B  0b 03 00
	pushw 0x201e                                         ; FF627E  0b 1e 20
.LFF6281:
	lda xbc, (0xf59538:24)                               ; FF6281  f2 38 95 f5 31
	push XBC                                             ; FF6286  39
	call LCD_SwiTextCall_SaveRegs                                      ; FF6287  1d 95 78 ff
	inc 8,XSP                                            ; FF628B  ef 60
	inc 2,XSP                                            ; FF628D  ef 62
	jr .LFF62AC                                          ; FF628F  68 1b
.LFF6291:
	lda xbc, (DL_F59409:24)                              ; FF6291  f2 09 94 f5 31
	push XBC                                             ; FF6296  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF6297  1d 23 76 ff
	ld (0x2730:16), 0x02                                 ; FF629B  f1 30 27 00 02
	pop XIY                                              ; FF62A0  5d
	lda xbc, (0xf59933:24)                               ; FF62A1  f2 33 99 f5 31
	push XBC                                             ; FF62A6  39
.LFF62A7:
	call DLB_Array8_SaveRegs                                      ; FF62A7  1d 3f 76 ff
.LFF62AB:
	pop XIY                                              ; FF62AB  5d
.LFF62AC:
	pop XIX                                              ; FF62AC  5c
	unlk XIZ                                             ; FF62AD  ee 0d
	ret                                                  ; FF62AF  0e
; ---------------------------------------------------------------------
; LcdKeyRow5_MidiFileSave_Page1 -- what Dispatch_FF3D39 runs for panel
;          control 0x0C
;
; Reached from: Dispatch_FF3D39 entry [44] (page 1, control 0x0C) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x0C is the LCD row 5 button pair -- the BOTTOM row. The
;          pair position -- which of the two keys -- reaches the handler in
;          the argument the reader forwards; this pass did NOT establish that
;          argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow5_MidiFileSave_Page1:
	link XIZ,0x0000                                      ; FF62B0  ee 0c 00 00
	push XIX                                             ; FF62B4  3c
	lda xix, (0x133e:16)                                ; FF62B5  f1 3e 13 34
	pushw 0x0b                                           ; FF62B9  0b 0b 00
	pushw 0x0c                                           ; FF62BC  0b 0c 00
	calr PanelDial_SetButtonPair                                      ; FF62BF  1e 68 0e
	ld BC,(XIZ+0x08)                                     ; FF62C2  9e 08 21
	and BC,0x0080                                        ; FF62C5  d9 cc 80 00
	pop XIY                                              ; FF62C9  5d
	jrl nz, .LFF6369                                     ; FF62CA  7e 9c 00
	ld bc, (0x2730:16)                                 ; FF62CD  d1 30 27 21
	extz BC                                              ; FF62D1  d9 12
	cp bc, 0x00:i3                                         ; FF62D3  d9 d8
	jr z, .LFF62E6                                       ; FF62D5  66 0f
	cp bc, 0x01:i3                                         ; FF62D7  d9 d9
	jr z, .LFF6310                                       ; FF62D9  66 35
	cp bc, 0x02:i3                                         ; FF62DB  d9 da
	jr z, .LFF6331                                       ; FF62DD  66 52
	cp bc, 0x03:i3                                         ; FF62DF  d9 db
	jr z, .LFF6346                                       ; FF62E1  66 63
	jrl .LFF6384                                         ; FF62E3  78 9e 00
.LFF62E6:
	lda xbc, (DL_F59409:24)                              ; FF62E6  f2 09 94 f5 31
	push XBC                                             ; FF62EB  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF62EC  1d 23 76 ff
	lda xbc, (DL_F59546:24)                              ; FF62F0  f2 46 95 f5 31
	push XBC                                             ; FF62F5  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF62F6  1d 23 76 ff
	pushw 0x00                                           ; FF62FA  0b 00 00
	pushw 0x08                                           ; FF62FD  0b 08 00
	calr MidiFile_LcdKeyRow5                                      ; FF6300  1e c5 00
	inc 8,XSP                                            ; FF6303  ef 60
	inc 4,XSP                                            ; FF6305  ef 64
	lda xbc, (DL_F5953B:24)                              ; FF6307  f2 3b 95 f5 31
	push XBC                                             ; FF630C  39
	jrl .LFF637F                                         ; FF630D  78 6f 00
.LFF6310:
	cp	(Disk_SeqBank:16), 0x00                            ; FF6310  c1 2b 27 3f 00
	jr z, .LFF631B                                       ; FF6315  66 04
	dec 0x01, (Disk_SeqBank:16)                                ; FF6317  c1 2b 27 69
.LFF631B:
	ld c, (Disk_SeqBank:16)                                   ; FF631B  c1 2b 27 23
	inc 1,C                                              ; FF631F  cb 61
	ld (0x2733:16), c                                   ; FF6321  f1 33 27 43
	lda xbc, (DL_F5993E:24)                              ; FF6325  f2 3e 99 f5 31
	push XBC                                             ; FF632A  39
	call DLB_Handler_Decimal_Veneer                                      ; FF632B  1d 68 76 ff
	jr .LFF6383                                          ; FF632F  68 52
.LFF6331:
	ld C,(XIX)                                           ; FF6331  84 23
	and C,0x01                                           ; FF6333  cb cc 01
	jr z, .LFF6384                                       ; FF6336  66 4c
	and (XIX),0xfe                                       ; FF6338  84 3c fe
	pushw 0x06                                           ; FF633B  0b 06 00
	pushw 0x03                                           ; FF633E  0b 03 00
	pushw 0x1b6e                                         ; FF6341  0b 6e 1b
	jr .LFF6359                                          ; FF6344  68 13
.LFF6346:
	ld C,(XIX)                                           ; FF6346  84 23
	and C,0x02                                           ; FF6348  cb cc 02
	jr z, .LFF6384                                       ; FF634B  66 37
	and (XIX),0xfd                                       ; FF634D  84 3c fd
	pushw 0x06                                           ; FF6350  0b 06 00
	pushw 0x03                                           ; FF6353  0b 03 00
	pushw 0x201e                                         ; FF6356  0b 1e 20
.LFF6359:
	lda xbc, (DLText_F59535:24)                          ; FF6359  f2 35 95 f5 31
	push XBC                                             ; FF635E  39
	call LCD_SwiTextCall_SaveRegs                                      ; FF635F  1d 95 78 ff
	inc 8,XSP                                            ; FF6363  ef 60
	inc 2,XSP                                            ; FF6365  ef 62
	jr .LFF6384                                          ; FF6367  68 1b
.LFF6369:
	lda xbc, (DL_F59409:24)                              ; FF6369  f2 09 94 f5 31
	push XBC                                             ; FF636E  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF636F  1d 23 76 ff
	ld (0x2730:16), 0x03                                 ; FF6373  f1 30 27 00 03
	pop XIY                                              ; FF6378  5d
	lda xbc, (0xf59933:24)                               ; FF6379  f2 33 99 f5 31
	push XBC                                             ; FF637E  39
.LFF637F:
	call DLB_Array8_SaveRegs                                      ; FF637F  1d 3f 76 ff
.LFF6383:
	pop XIY                                              ; FF6383  5d
.LFF6384:
	pop XIX                                              ; FF6384  5c
	unlk XIZ                                             ; FF6385  ee 0d
	ret                                                  ; FF6387  0e
; MidiFile_LcdKeyRow4: the LcdKeyRow4 action of MidiFileDirectPlay, MidiFileL0ad, MidiFileSave_Page1 -- called only by LcdKeyRow4_MidiFileDirectPlay, LcdKeyRow4_MidiFileL0ad, LcdKeyRow4_MidiFileSave_Page1.
MidiFile_LcdKeyRow4:
	link XIZ,0x0000                                      ; FF6388  ee 0c 00 00
	push XIX                                             ; FF638C  3c
	lda xix, (0x272e:16)                                ; FF638D  f1 2e 27 34
	pushw 0x0b                                           ; FF6391  0b 0b 00
	pushw 0x0c                                           ; FF6394  0b 0c 00
	calr PanelDial_SetButtonPair                                      ; FF6397  1e 90 0d
	pop XIY                                              ; FF639A  5d
	cp	(0x272d:16), 0x00                            ; FF639B  c1 2d 27 3f 00
	jr nz, .LFF63B6                                      ; FF63A0  6e 14
	ld C,(XIX)                                           ; FF63A2  84 23
	cp c, 0x00:i3                                          ; FF63A4  cb d8
	jr z, .LFF63BA                                       ; FF63A6  66 12
	decm8 0x01, (xix)                                    ; FF63A8  84 69
	pushw	(xiz+10)                                     ; FF63AA  9e 0a 04
	pushw	(xiz+8)                                      ; FF63AD  9e 08 04
	calr MidiFile_DrawFileList                                      ; FF63B0  1e 65 ed
	pop XIY                                              ; FF63B3  5d
	jr .LFF63BA                                          ; FF63B4  68 04
.LFF63B6:
	dec 0x01, (0x272d:16)                                ; FF63B6  c1 2d 27 69
.LFF63BA:
	ld C,(XIX)                                           ; FF63BA  84 23
	add c, (0x272d:16)                                   ; FF63BC  c1 2d 27 83
	ld (Disk_SelectedEntry:16), c                                   ; FF63C0  f1 24 27 43
	pop XIX                                              ; FF63C4  5c
	unlk XIZ                                             ; FF63C5  ee 0d
	ret                                                  ; FF63C7  0e
; MidiFile_LcdKeyRow5: the LcdKeyRow5 action of MidiFileDirectPlay, MidiFileL0ad, MidiFileSave_Page1 -- called only by LcdKeyRow5_MidiFileDirectPlay, LcdKeyRow5_MidiFileL0ad, LcdKeyRow5_MidiFileSave_Page1.
MidiFile_LcdKeyRow5:
	link XIZ,0xfffe                                      ; FF63C8  ee 0c fe ff
	pushw hl                                             ; FF63CC  2b
	pushw de                                             ; FF63CD  2a
	push XIX                                             ; FF63CE  3c
	lda xix, (0x272d:16)                                ; FF63CF  f1 2d 27 34
	ld DE,(XIZ+0x08)                                     ; FF63D3  9e 08 22
	ld l, (UI_ScreenItem:16)                                   ; FF63D6  c1 20 27 27
	cp	(UI_ScreenLatch:16), 0x4e                            ; FF63DA  c1 7a 20 3f 4e
	jr z, .LFF63F1                                       ; FF63DF  66 10
	ld h, 0x00:opc                                          ; FF63E1  26 00
	cp l, 0x00:i3                                          ; FF63E3  cf d8
	jr z, .LFF63F3                                       ; FF63E5  66 0c
	ld C,L                                               ; FF63E7  cf 8b
	extz BC                                              ; FF63E9  d9 12
	dec 1,BC                                             ; FF63EB  d9 69
	ld H,C                                               ; FF63ED  cb 8e
	jr .LFF63F3                                          ; FF63EF  68 02
.LFF63F1:
	ld H,L                                               ; FF63F1  cf 8e
.LFF63F3:
	cp	(UI_ScreenLatch:16), 0x4e                            ; FF63F3  c1 7a 20 3f 4e
	jr nz, .LFF6404                                      ; FF63F8  6e 0a
	ld c, (0x60a480:24)                                 ; FF63FA  c2 80 a4 60 23
; (sub_FF63FF removed 2026-10-04: no code names it and the line above falls through into it -- part of MidiFile_LcdKeyRow5;
;  notes/prom_a_stray_label_removal.py)
	cp C,0x20                                            ; FF63FF  cb cf 20
	jr z, .LFF644C                                       ; FF6402  66 48
.LFF6404:
	pushw 0x0b                                           ; FF6404  0b 0b 00
	pushw 0x0c                                           ; FF6407  0b 0c 00
	calr PanelDial_SetButtonPair                                      ; FF640A  1e 1d 0d
	ld C,(XIX)                                           ; FF640D  84 23
	add c, (0x272e:16)                                   ; FF640F  c1 2e 27 83
	pop XIY                                              ; FF6413  5d
	cp H,C                                               ; FF6414  cb f6
	jr ule, .LFF6442                                     ; FF6416  63 2a
	ld BC,DE                                             ; FF6418  da 89
	dec 1,BC                                             ; FF641A  d9 69
	ld (xiz-2), bc                                       ; FF641C  be fe 51
	ld A,(XIX)                                           ; FF641F  84 21
	extz WA                                              ; FF6421  d8 12
	cp WA,BC                                             ; FF6423  d9 f0
	jr nz, .LFF6440                                      ; FF6425  6e 19
	ldw bc, 0x64                                         ; FF6427  31 64 00
	sub BC,DE                                            ; FF642A  da a1
	cp (0x272e:16), c                                    ; FF642C  c1 2e 27 fb
	jr nc, .LFF6442                                      ; FF6430  6f 10
	inc 0x01, (0x272e:16)                                ; FF6432  c1 2e 27 61
	pushw	(xiz+10)                                     ; FF6436  9e 0a 04
	pushw de                                             ; FF6439  2a
	calr MidiFile_DrawFileList                                      ; FF643A  1e db ec
	pop XIY                                              ; FF643D  5d
	jr .LFF6442                                          ; FF643E  68 02
.LFF6440:
	incm8 0x01, (xix)                                    ; FF6440  84 61
.LFF6442:
	ld C,(XIX)                                           ; FF6442  84 23
	add c, (0x272e:16)                                   ; FF6444  c1 2e 27 83
	ld (Disk_SelectedEntry:16), c                                   ; FF6448  f1 24 27 43
.LFF644C:
	pop XIX                                              ; FF644C  5c
	popw de                                              ; FF644D  4a
	popw hl                                              ; FF644E  4b
	unlk XIZ                                             ; FF644F  ee 0d
	ret                                                  ; FF6451  0e
; ---------------------------------------------------------------------
; LcdKeyRow3_MidiFileSave_Page2 -- what Dispatch_FF3D39 runs for panel
;          control 0x0A
;
; Reached from: Dispatch_FF3D39 entry [74] (page 2, control 0x0A) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x0A is the LCD row 3 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow3_MidiFileSave_Page2:
	link XIZ,0x0000                                      ; FF6452  ee 0c 00 00
	push XIX                                             ; FF6456  3c
	lda xix, (UI_Request_Hi:16)                                ; FF6457  f1 71 20 34
	ld BC,(XIZ+0x08)                                     ; FF645B  9e 08 21
	and BC,0x0080                                        ; FF645E  d9 cc 80 00
	jr nz, .LFF6481                                      ; FF6462  6e 1d
	call T_MidiFileSave_WriteSeqBankSmf                                        ; FF6464  1d 84 33 f4
	cp	(UI_StatusCode:16), 0x23                            ; FF6468  c1 80 28 3f 23
	jr nz, .LFF6479                                      ; FF646D  6e 0a
	ld (UI_ScreenPage:16), 0x00                                 ; FF646F  f1 29 22 00 00
	or	(xix), 0x10                                  ; FF6474  84 3e 10
	jr .LFF6481                                          ; FF6477  68 08
.LFF6479:
	ld (UI_Request:16), 0xab                                 ; FF6479  f1 70 20 00 ab
	or	(xix), 0x40                                  ; FF647E  84 3e 40
.LFF6481:
	pop XIX                                              ; FF6481  5c
	unlk XIZ                                             ; FF6482  ee 0d
	ret                                                  ; FF6484  0e
; ---------------------------------------------------------------------
; LcdKeyRow4_MidiFileSave_Page2 -- what Dispatch_FF3D39 runs for panel
;          control 0x0B
;
; Reached from: Dispatch_FF3D39 entry [75] (page 2, control 0x0B) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x0B is the LCD row 4 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow4_MidiFileSave_Page2:
	link XIZ,0x0000                                      ; FF6485  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF6489  9e 08 21
	and BC,0x0080                                        ; FF648C  d9 cc 80 00
	jr nz, .LFF649B                                      ; FF6490  6e 09
	ld (UI_ScreenPage:16), 0x01                                 ; FF6492  f1 29 22 00 01
	set	4, (UI_Request_Hi:16)                               ; FF6497  f1 71 20 bc
.LFF649B:
	unlk XIZ                                             ; FF649B  ee 0d
	ret                                                  ; FF649D  0e
; ---------------------------------------------------------------------
; LcdKeyRow3_MidiFileSave_Page3 -- what Dispatch_FF3D39 runs for panel
;          control 0x0A
;
; Reached from: Dispatch_FF3D39 entry [106] (page 3, control 0x0A) -- and
;          from no other slot of any 32-entry control table in prom_a. A
;          target reached at two DIFFERENT indices is refused by the script
;          that wrote this.
; Control:  index 0x0A is the LCD row 3 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow3_MidiFileSave_Page3:
	link XIZ,0xfff4                                      ; FF649E  ee 0c f4 ff
	push XIX                                             ; FF64A2  3c
	lda xix, (Disk_FileName:16)                                ; FF64A3  f1 c8 21 34
	ld BC,(XIZ+0x08)                                     ; FF64A7  9e 08 21
	and BC,0x0080                                        ; FF64AA  d9 cc 80 00
	jr nz, .LFF64F4                                      ; FF64AE  6e 44
	pushw 0x0b                                           ; FF64B0  0b 0b 00
	push XIX                                             ; FF64B3  3c
	lda xbc, (xiz-12)                                    ; FF64B4  be f4 31
	push XBC                                             ; FF64B7  39
	call MemCpy_C                                      ; FF64B8  1d b5 78 ff
	ld bc, (Disk_SelectedEntry:16)                                 ; FF64BC  d1 24 27 21
	extz BC                                              ; FF64C0  d9 12
	pushw bc                                             ; FF64C2  29
	calr MidiFileList_CopyEntryToFileName                                      ; FF64C3  1e 96 e2
	extz XIX                                             ; FF64C6  ec 12
	ld (XIX+0x08),0x4d                                   ; FF64C8  bc 08 00 4d
	ld (XIX+0x09),0x49                                   ; FF64CC  bc 09 00 49
	ld (XIX+0x0a),0x44                                   ; FF64D0  bc 0a 00 44
	call T_MidiFileSave_Page3_LcdKeyRow3                                        ; FF64D4  1d 34 26 f4
	pushw 0x0b                                           ; FF64D8  0b 0b 00
	lda xbc, (xiz-12)                                    ; FF64DB  be f4 31
	push XBC                                             ; FF64DE  39
	push XIX                                             ; FF64DF  3c
	call MemCpy_C                                      ; FF64E0  1d b5 78 ff
	ld (UI_Request:16), 0x40                                 ; FF64E4  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF64E9  f1 71 20 00 80
	add XSP,0x00000016                                   ; FF64EE  ef c8 16 00 00 00
.LFF64F4:
	pop XIX                                              ; FF64F4  5c
	unlk XIZ                                             ; FF64F5  ee 0d
	ret                                                  ; FF64F7  0e
; ---------------------------------------------------------------------
; LcdKeyRow4_MidiFileSave_Page3 -- what Dispatch_FF3D39 runs for panel
;          control 0x0B
;
; Reached from: Dispatch_FF3D39 entry [107] (page 3, control 0x0B) -- and
;          from no other slot of any 32-entry control table in prom_a. A
;          target reached at two DIFFERENT indices is refused by the script
;          that wrote this.
; Control:  index 0x0B is the LCD row 4 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow4_MidiFileSave_Page3:
	link XIZ,0x0000                                      ; FF64F8  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF64FC  9e 08 21
	and BC,0x0080                                        ; FF64FF  d9 cc 80 00
	jr nz, .LFF650E                                      ; FF6503  6e 09
	ld (UI_ScreenPage:16), 0x01                                 ; FF6505  f1 29 22 00 01
	set	4, (UI_Request_Hi:16)                               ; FF650A  f1 71 20 bc
.LFF650E:
	unlk XIZ                                             ; FF650E  ee 0d
	ret                                                  ; FF6510  0e
T_F423CC_Nop:
	ret                                                  ; FF6511  0e
; ---------------------------------------------------------------------
; Paint_FloppyDiskFormatSelectType -- paints the screen whose own text reads "FLOPPY DISK FORMAT" / "Select the F0RMAT type for your disk."
;
; Called from: prom_b T_F423D0 (`jp`)
;
; It hands 2 display list(s) to the interpreter ON THE STACK --
;          lda XBC,<end> / push XBC / lda XWA,<start> / push XWA,
;          then the stack veneer.  The lists, and the text each draws:
;     site 0xFF6521  list 0xF5985B-0xF59904 (169 B, leaves by call)
;        text: "FLOPPY DISK FORMAT"; "Select the F0RMAT type for your disk."; ...
;     site 0xFF6534  list 0xF58000-0xF58014 (20 B, leaves by call)
;        text: "DISK"
; From the captions: "FLOPPY DISK FORMAT"; "Select the F0RMAT type for
;          your disk."; "2DD:720K Byte format for 2DD disk."
; Evidence: the list bounds are the two 24-bit IMMEDIATES of the
;          12-byte push idiom at the cited site, and the record
;          length bytes walked from <start> land EXACTLY on <end>
;          (368 of 368 in both images do -- notes/prom_a_dl_stack_map.py).
;          The quoted text is the `.ascii` the interpreter draws
;          verbatim.  Every morpheme of this name occurs in it;
;          notes/prom_a_understanding_round7.py --morphemes checks that.
;          `Paint_` is a structural verb, not ROM text.
; Unknown: whether this routine also handles input for the screen,
;          and whether another routine paints it too.  Neither was
;          searched.  ⚠ The register-form scan of rounds 5 and 6 does
;          not see this call shape at all, which is why this routine
;          was sub_XXXXXX until round 7.
; Named by notes/prom_a_understanding_round7.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_FloppyDiskFormatSelectType:
	ld (0x2730:16), 0x00                                 ; FF6512  f1 30 27 00 00
	calr CallbackQueue_ResetAndRestartTask2_Call                                      ; FF6517  1e 98 dd
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF651A  1d 04 76 ff
	pushw 0x00                                           ; FF651E  0b 00 00
	lda xbc, (DL_ComposerLoad:24)                        ; FF6521  f2 04 99 f5 31
	push XBC                                             ; FF6526  39
	lda xwa, (DL_FloppyDiskFormatSelectTheF0rmatTypeForYo:24) ; FF6527  f2 5b 98 f5 30
	push XWA                                             ; FF652C  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF652D  1d d3 75 ff
	pushw 0x00                                           ; FF6531  0b 00 00
	lda xbc, (DL_DiskDiskL0adDiskSaveMidiFile:24)        ; FF6534  f2 14 80 f5 31
	push XBC                                             ; FF6539  39
	lda xwa, (DL_Disk:24)                                ; FF653A  f2 00 80 f5 30
	push XWA                                             ; FF653F  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF6540  1d d3 75 ff
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF6544  1d 15 76 ff
	add XSP,0x00000014                                   ; FF6548  ef c8 14 00 00 00
	ret                                                  ; FF654E  0e
; ---------------------------------------------------------------------
; ScreenLeave_FloppyDiskFormatSelectType -- the LEAVE method of the screen
;          object at PanelScreen_VtableTable entry 0x70, i.e. SCREEN ID 0x50
;          through PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x70 -> the screen object at
;          0xF423D0, whose +4 slot is `jp 0xFF654F`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the LEAVE method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   FloppyDiskFormatSelectType -- the same object's +0 ENTER method
;          carries the label Paint_FloppyDiskFormatSelectType, a name an
;          earlier round derived from the screen's own text.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing at all
;          on leave, and the slot exists to keep the three-method shape.
; Was `sub_FF654F`.
; ---------------------------------------------------------------------
ScreenLeave_FloppyDiskFormatSelectType:
	ret                                                  ; FF654F  0e
; ---------------------------------------------------------------------
; PanelButtonDispatch_FloppyDiskFormatSelectType -- run Dispatch_FF3F39's
;          handler for one PANEL CONTROL
;
; Inputs:   (XIZ+0x08) = the 5-bit panel control index; (XIZ+0x0A) =
;          the argument this reader forwards to the handler.
; Evidence: `cp H,0x20` at 0xFF6558 bounds the index to the 32-code
;          panel space PanelButton_Route's `and L,0x1f`
;          (0xF861AE) produces, and `add XBC,0x00FF3F39` at 0xFF6566
;          names the table.
;          The handler is CALLED, not jumped to: the reader pushes
;          a return address before `jp (XBC)`.
; Control legend: notes/FINDINGS-prom_a-panel-control-map.md, and
;          `python3 notes/prom_a_panel_control_map.py --map`.
; Screen:   FloppyDiskFormatSelectType -- the screen object at
;          PanelScreen_VtableTable entry 0x70, i.e. SCREEN ID 0x50 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF6512 as its ENTER method, and that address carries
;          the label Paint_FloppyDiskFormatSelectType -- a name an earlier
;          round derived from the screen's own text.
; Was `sub_FF6550`, named by notes/prom_a_naming_wave8_apply.py.
; ---------------------------------------------------------------------
PanelButtonDispatch_FloppyDiskFormatSelectType:
	link XIZ,0x0000                                      ; FF6550  ee 0c 00 00
	pushw hl                                             ; FF6554  2b
	ld H,(XIZ+0x08)                                      ; FF6555  8e 08 26
	cp H,0x20                                            ; FF6558  ce cf 20
	jr nc, .LFF6577                                      ; FF655B  6f 1a
	pushw	(xiz+10)                                     ; FF655D  9e 0a 04
	ld c, 0x04:opc                                          ; FF6560  23 04
	mul bc, h                                          ; FF6562  ce 43
	extz XBC                                             ; FF6564  e9 12
	add XBC,Dispatch_FF3D39+0x200                        ; FF6566  e9 c8 39 3f ff 00
	ld XBC,(XBC)                                         ; FF656C  a1 21
	lda xiy, (.LFF6576:24)                               ; FF656E  f2 76 65 ff 35
	push XIY                                             ; FF6573  3d
	jp (xbc)                                             ; FF6574  b1 d8
.LFF6576:
	popw bc                                              ; FF6576  49
.LFF6577:
	popw hl                                              ; FF6577  4b
	unlk XIZ                                             ; FF6578  ee 0d
	ret                                                  ; FF657A  0e
sub_FF657B:   ; entry: named by 2 `.long` operands, first at 0xFF3F45
	link XIZ,0x0000                                      ; FF657B  ee 0c 00 00
	push XIX                                             ; FF657F  3c
	lda xix, (0x2730:16)                                ; FF6580  f1 30 27 34
	ld c, (0x21e8:16)                                   ; FF6584  c1 e8 21 23
	and C,0x04                                           ; FF6588  cb cc 04
	jr z, .LFF65AE                                       ; FF658B  66 21
	ld BC,(XIZ+0x08)                                     ; FF658D  9e 08 21
	and BC,0x0080                                        ; FF6590  d9 cc 80 00
	jr z, .LFF65AE                                       ; FF6594  66 18
	ld C,(XIX)                                           ; FF6596  84 23
	cp C,0x08                                            ; FF6598  cb cf 08
	jr nc, .LFF65A1                                      ; FF659B  6f 04
	incm8 0x01, (xix)                                    ; FF659D  84 61
	jr .LFF65AE                                          ; FF659F  68 0d
.LFF65A1:
	ld (UI_Request:16), 0x52                                 ; FF65A1  f1 70 20 00 52
	ld (UI_Request_Hi:16), 0x80                                 ; FF65A6  f1 71 20 00 80
	ld (XIX),0x00                                        ; FF65AB  b4 00 00
.LFF65AE:
	pop XIX                                              ; FF65AE  5c
	unlk XIZ                                             ; FF65AF  ee 0d
	ret                                                  ; FF65B1  0e
; ---------------------------------------------------------------------
; LcdKeyRow3_MidiFileSave_Page4 -- what Dispatch_FF3D39 runs for panel
;          control 0x0A
;
; Reached from: Dispatch_FF3D39 entry [138] (page 4, control 0x0A) -- and
;          from no other slot of any 32-entry control table in prom_a. A
;          target reached at two DIFFERENT indices is refused by the script
;          that wrote this.
; Control:  index 0x0A is the LCD row 3 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow3_MidiFileSave_Page4:
	link XIZ,0x0000                                      ; FF65B2  ee 0c 00 00
	ld (0x2730:16), 0x00                                 ; FF65B6  f1 30 27 00 00
	ld BC,(XIZ+0x08)                                     ; FF65BB  9e 08 21
	and BC,0x0080                                        ; FF65BE  d9 cc 80 00
	jr z, .LFF65D2                                       ; FF65C2  66 0e
	res	3, (0x21e8:16)                               ; FF65C4  f1 e8 21 b3
	ld (UI_Request:16), 0x51                                 ; FF65C8  f1 70 20 00 51
	ld (UI_Request_Hi:16), 0x80                                 ; FF65CD  f1 71 20 00 80
.LFF65D2:
	unlk XIZ                                             ; FF65D2  ee 0d
	ret                                                  ; FF65D4  0e
; ---------------------------------------------------------------------
; LcdKeyRow4_MidiFileSave_Page4 -- what Dispatch_FF3D39 runs for panel
;          control 0x0B
;
; Reached from: Dispatch_FF3D39 entry [139] (page 4, control 0x0B) -- and
;          from no other slot of any 32-entry control table in prom_a. A
;          target reached at two DIFFERENT indices is refused by the script
;          that wrote this.
; Control:  index 0x0B is the LCD row 4 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow4_MidiFileSave_Page4:
	link XIZ,0x0000                                      ; FF65D5  ee 0c 00 00
	ld (0x2730:16), 0x00                                 ; FF65D9  f1 30 27 00 00
	ld BC,(XIZ+0x08)                                     ; FF65DE  9e 08 21
	and BC,0x0080                                        ; FF65E1  d9 cc 80 00
	jr z, .LFF65F5                                       ; FF65E5  66 0e
	set	3, (0x21e8:16)                               ; FF65E7  f1 e8 21 bb
	ld (UI_Request:16), 0x51                                 ; FF65EB  f1 70 20 00 51
	ld (UI_Request_Hi:16), 0x80                                 ; FF65F0  f1 71 20 00 80
.LFF65F5:
	unlk XIZ                                             ; FF65F5  ee 0d
	ret                                                  ; FF65F7  0e
; ---------------------------------------------------------------------
; ExitKey_MidiFileSave_Page4 -- what Dispatch_FF3D39 runs for panel control
;          0x0F
;
; Reached from: Dispatch_FF3D39 entry [143] (page 4, control 0x0F) -- and
;          from no other slot of any 32-entry control table in prom_a. A
;          target reached at two DIFFERENT indices is refused by the script
;          that wrote this.
; Control:  index 0x0F is the EXIT key. The pair position -- which of the two
;          keys -- reaches the handler in the argument the reader forwards;
;          this pass did NOT establish that argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
ExitKey_MidiFileSave_Page4:
	link XIZ,0x0000                                      ; FF65F8  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF65FC  9e 08 21
	and BC,0x0080                                        ; FF65FF  d9 cc 80 00
	jr nz, .LFF660F                                      ; FF6603  6e 0a
	ld (UI_Request:16), 0x40                                 ; FF6605  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF660A  f1 71 20 00 80
.LFF660F:
	unlk XIZ                                             ; FF660F  ee 0d
	ret                                                  ; FF6611  0e
T_F423DC_Nop:
	ret                                                  ; FF6612  0e
; ---------------------------------------------------------------------
; Paint_FloppyDiskFormatAreYouSure -- paints the "FLOPPY DISK FORMAT" confirmation whose own text reads "ATTENTION!" / "Are You Sure?"
;
; Called from: prom_b T_F423F0 (`jp`)
;
; It hands 5 display list(s) to the interpreter ON THE STACK --
;          lda XBC,<end> / push XBC / lda XWA,<start> / push XWA,
;          then the stack veneer.  The lists, and the text each draws:
;     site 0xFF6629  list 0xF59A35-0xF59A4B (22 B, leaves by jp(XIX))
;        text: "FLOPPY DISK FORMAT"
;     site 0xFF6640  list 0xF58162-0xF581B0 (78 B, leaves by jp(XIX))
;        text: "YES"; "NO"
;     site 0xFF6657  list 0xF59A4B-0xF59AB5 (106 B, leaves by jp(XIX))
;        text: "ATTENTION!"; "Using DISK FORMAT will erase"; ...
;     site 0xFF667D  list 0xF59205-0xF5920E (9 B, leaves by jr)
;        text: "(2HD)"
;     site 0xFF668B  list 0xF591FC-0xF59205 (9 B, leaves by jp(XIX))
;        text: "(2DD)"
; From the captions: "FLOPPY DISK FORMAT"; "Using DISK FORMAT will erase";
;          "Are You Sure?"
; Evidence: the list bounds are the two 24-bit IMMEDIATES of the
;          12-byte push idiom at the cited site, and the record
;          length bytes walked from <start> land EXACTLY on <end>
;          (368 of 368 in both images do -- notes/prom_a_dl_stack_map.py).
;          The quoted text is the `.ascii` the interpreter draws
;          verbatim.  Every morpheme of this name occurs in it;
;          notes/prom_a_understanding_round7.py --morphemes checks that.
;          `Paint_` is a structural verb, not ROM text.
; Unknown: whether this routine also handles input for the screen,
;          and whether another routine paints it too.  Neither was
;          searched.  ⚠ The register-form scan of rounds 5 and 6 does
;          not see this call shape at all, which is why this routine
;          was sub_XXXXXX until round 7.
; Named by notes/prom_a_understanding_round7.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_FloppyDiskFormatAreYouSure:
	push XIX                                             ; FF6613  3c
	lda xix, (DisplayList_RunOnLayer_SaveRegs:24)                             ; FF6614  f2 d3 75 ff 34
	ld (0x2730:16), 0x00                                 ; FF6619  f1 30 27 00 00
	call T_CallbackQueue_ResetAndRestartTask2            ; FF661E  1d 80 2e f4
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF6622  1d 04 76 ff
	pushw 0x00                                           ; FF6626  0b 00 00
	lda xbc, (DL_AttentionUsingDiskFormatWillErase:24)   ; FF6629  f2 4b 9a f5 31
	push XBC                                             ; FF662E  39
	lda xwa, (DL_FloppyDiskFormat:24)                    ; FF662F  f2 35 9a f5 30
	push XWA                                             ; FF6634  38
	lda xiy, (.LFF663D:24)                               ; FF6635  f2 3d 66 ff 35
	push XIY                                             ; FF663A  3d
	jp (xix)                                             ; FF663B  b4 d8
.LFF663D:
	pushw 0x00                                           ; FF663D  0b 00 00
	lda xbc, (DL_LoadL0adFileLoadL0ad0pti0n:24)          ; FF6640  f2 b0 81 f5 31
	push XBC                                             ; FF6645  39
	lda xwa, (DL_F58162:24)                              ; FF6646  f2 62 81 f5 30
	push XWA                                             ; FF664B  38
	lda xiy, (.LFF6654:24)                               ; FF664C  f2 54 66 ff 35
	push XIY                                             ; FF6651  3d
	jp (xix)                                             ; FF6652  b4 d8
.LFF6654:
	pushw 0x00                                           ; FF6654  0b 00 00
	lda xbc, (DL_DiskSaveFileDelete:24)                  ; FF6657  f2 b5 9a f5 31
	push XBC                                             ; FF665C  39
	lda xwa, (DL_AttentionUsingDiskFormatWillErase:24)   ; FF665D  f2 4b 9a f5 30
	push XWA                                             ; FF6662  38
	lda xiy, (.LFF666B:24)                               ; FF6663  f2 6b 66 ff 35
	push XIY                                             ; FF6668  3d
	jp (xix)                                             ; FF6669  b4 d8
.LFF666B:
	add XSP,0x0000001e                                   ; FF666B  ef c8 1e 00 00 00
	pushw 0x00                                           ; FF6671  0b 00 00
	ld c, (0x21e8:16)                                   ; FF6674  c1 e8 21 23
	and C,0x08                                           ; FF6678  cb cc 08
	jr z, .LFF668B                                       ; FF667B  66 0e
	lda xbc, (DL_F5920E:24)                              ; FF667D  f2 0e 92 f5 31
	push XBC                                             ; FF6682  39
	lda xwa, (DL_2hd:24)                                 ; FF6683  f2 05 92 f5 30
	push XWA                                             ; FF6688  38
	jr .LFF6697                                          ; FF6689  68 0c
.LFF668B:
	lda xbc, (DL_2hd:24)                                 ; FF668B  f2 05 92 f5 31
	push XBC                                             ; FF6690  39
	lda xwa, (DL_2dd:24)                                 ; FF6691  f2 fc 91 f5 30
	push XWA                                             ; FF6696  38
.LFF6697:
	lda xiy, (.LFF669F:24)                               ; FF6697  f2 9f 66 ff 35
	push XIY                                             ; FF669C  3d
	jp (xix)                                             ; FF669D  b4 d8
.LFF669F:
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF669F  1d 15 76 ff
	inc 8,XSP                                            ; FF66A3  ef 60
	inc 2,XSP                                            ; FF66A5  ef 62
	pop XIX                                              ; FF66A7  5c
	ret                                                  ; FF66A8  0e
; ---------------------------------------------------------------------
; ScreenLeave_FloppyDiskFormatAreYouSure -- the LEAVE method of the screen
;          object at PanelScreen_VtableTable entry 0x71, i.e. SCREEN ID 0x51
;          through PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x71 -> the screen object at
;          0xF423F0, whose +4 slot is `jp 0xFF66A9`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the LEAVE method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   FloppyDiskFormatAreYouSure -- the same object's +0 ENTER method
;          carries the label Paint_FloppyDiskFormatAreYouSure, a name an
;          earlier round derived from the screen's own text.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing at all
;          on leave, and the slot exists to keep the three-method shape.
; Was `sub_FF66A9`.
; ---------------------------------------------------------------------
ScreenLeave_FloppyDiskFormatAreYouSure:
	ret                                                  ; FF66A9  0e
; ---------------------------------------------------------------------
; PanelButtonDispatch_FloppyDiskFormatAreYouSure -- run Dispatch_FF3FB9's
;          handler for one PANEL CONTROL
;
; Inputs:   (XIZ+0x08) = the 5-bit panel control index; (XIZ+0x0A) =
;          the argument this reader forwards to the handler.
; Evidence: `cp H,0x20` at 0xFF66B2 bounds the index to the 32-code
;          panel space PanelButton_Route's `and L,0x1f`
;          (0xF861AE) produces, and `add XBC,0x00FF3FB9` at 0xFF66C0
;          names the table.
;          The handler is CALLED, not jumped to: the reader pushes
;          a return address before `jp (XBC)`.
; Control legend: notes/FINDINGS-prom_a-panel-control-map.md, and
;          `python3 notes/prom_a_panel_control_map.py --map`.
; Screen:   FloppyDiskFormatAreYouSure -- the screen object at
;          PanelScreen_VtableTable entry 0x71, i.e. SCREEN ID 0x51 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method and 0xFF6613 as its ENTER method, and that address carries
;          the label Paint_FloppyDiskFormatAreYouSure -- a name an earlier
;          round derived from the screen's own text.
; Was `sub_FF66AA`, named by notes/prom_a_naming_wave8_apply.py.
; ---------------------------------------------------------------------
PanelButtonDispatch_FloppyDiskFormatAreYouSure:
	link XIZ,0x0000                                      ; FF66AA  ee 0c 00 00
	pushw hl                                             ; FF66AE  2b
	ld H,(XIZ+0x08)                                      ; FF66AF  8e 08 26
	cp H,0x20                                            ; FF66B2  ce cf 20
	jr nc, .LFF66D1                                      ; FF66B5  6f 1a
	pushw	(xiz+10)                                     ; FF66B7  9e 0a 04
	ld c, 0x04:opc                                          ; FF66BA  23 04
	mul bc, h                                          ; FF66BC  ce 43
	extz XBC                                             ; FF66BE  e9 12
	add XBC,Dispatch_FF3D39+0x280                        ; FF66C0  e9 c8 b9 3f ff 00
	ld XBC,(XBC)                                         ; FF66C6  a1 21
	lda xiy, (.LFF66D0:24)                               ; FF66C8  f2 d0 66 ff 35
	push XIY                                             ; FF66CD  3d
	jp (xbc)                                             ; FF66CE  b1 d8
.LFF66D0:
	popw bc                                              ; FF66D0  49
.LFF66D1:
	popw hl                                              ; FF66D1  4b
	unlk XIZ                                             ; FF66D2  ee 0d
	ret                                                  ; FF66D4  0e
; ---------------------------------------------------------------------
; LcdKeyRow3_MidiFileSave_Page5 -- what Dispatch_FF3D39 runs for panel
;          control 0x0A
;
; Reached from: Dispatch_FF3D39 entry [170] (page 5, control 0x0A) -- and
;          from no other slot of any 32-entry control table in prom_a. A
;          target reached at two DIFFERENT indices is refused by the script
;          that wrote this.
; Control:  index 0x0A is the LCD row 3 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow3_MidiFileSave_Page5:
	link XIZ,0x0000                                      ; FF66D5  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF66D9  9e 08 21
	and BC,0x0080                                        ; FF66DC  d9 cc 80 00
	jr nz, .LFF66F5                                      ; FF66E0  6e 13
	ld (0x21fa:16), 0x00                                 ; FF66E2  f1 fa 21 00 00
	call T_MidiFileSave_Page5_LcdKeyRow3                                        ; FF66E7  1d d0 25 f4
	ld (UI_Request:16), 0x01                                 ; FF66EB  f1 70 20 00 01
	ld (UI_Request_Hi:16), 0x02                                 ; FF66F0  f1 71 20 00 02
.LFF66F5:
	unlk XIZ                                             ; FF66F5  ee 0d
	ret                                                  ; FF66F7  0e
; ---------------------------------------------------------------------
; LcdKeyRow4_MidiFileSave_Page5 -- what Dispatch_FF3D39 runs for panel
;          control 0x0B
;
; Reached from: Dispatch_FF3D39 entry [171] (page 5, control 0x0B) -- and
;          from no other slot of any 32-entry control table in prom_a. A
;          target reached at two DIFFERENT indices is refused by the script
;          that wrote this.
; Control:  index 0x0B is the LCD row 4 button pair. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow4_MidiFileSave_Page5:
	link XIZ,0x0000                                      ; FF66F8  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF66FC  9e 08 21
	and BC,0x0080                                        ; FF66FF  d9 cc 80 00
	jr nz, .LFF670F                                      ; FF6703  6e 0a
	ld (UI_Request:16), 0x50                                 ; FF6705  f1 70 20 00 50
	ld (UI_Request_Hi:16), 0x80                                 ; FF670A  f1 71 20 00 80
.LFF670F:
	unlk XIZ                                             ; FF670F  ee 0d
	ret                                                  ; FF6711  0e
; ---------------------------------------------------------------------
; ExitKey_MidiFileSave_Page5 -- what Dispatch_FF3D39 runs for panel control
;          0x0F
;
; Reached from: Dispatch_FF3D39 entry [175] (page 5, control 0x0F) -- and
;          from no other slot of any 32-entry control table in prom_a. A
;          target reached at two DIFFERENT indices is refused by the script
;          that wrote this.
; Control:  index 0x0F is the EXIT key. The pair position -- which of the two
;          keys -- reaches the handler in the argument the reader forwards;
;          this pass did NOT establish that argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   MidiFileSave -- the screen object at PanelScreen_VtableTable
;          entry 0x6E, i.e. SCREEN ID 0x4E through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58A21, whose first
;          record reads "MIDI FILE SAVE : FILE NAMING", and its page 1 the
;          list at 0xF59222, "MIDI FILE SAVE : FILE SELECTI0N".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
ExitKey_MidiFileSave_Page5:
	link XIZ,0x0000                                      ; FF6712  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF6716  9e 08 21
	and BC,0x0080                                        ; FF6719  d9 cc 80 00
	jr nz, .LFF6729                                      ; FF671D  6e 0a
	ld (UI_Request:16), 0x40                                 ; FF671F  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF6724  f1 71 20 00 80
.LFF6729:
	unlk XIZ                                             ; FF6729  ee 0d
	ret                                                  ; FF672B  0e
T_F423FC_Nop:
	ret                                                  ; FF672C  0e
; ---------------------------------------------------------------------
; PageDispatch_L0adSingleS0und -- run ScreenEnterPages_L0adSingleS0und's entry for the CURRENT
;          PAGE
;
; ★ NOT a panel-control table.  This reader indexes with the page
;          byte (0x2229) ALONE and never reads an argument, so its
;          2 entries are pages of one screen and not buttons.
; Evidence: `cp (0x2229),0x02` at 0xFF672D is the bound, the index is
;          `(0x2229) * 4` (`m_mul MB16,0x2229,3` -- the operand is
;          width-1), and `add XBC,0x00FF4041` at 0xFF673C names the table.
;          The entry is CALLED: a return address is pushed before
;          `jp (XBC)`.
; Screen:   L0adSingleS0und -- the screen object at PanelScreen_VtableTable
;          entry 0x74, i.e. SCREEN ID 0x54 through
;          PanelScreen_VtableTable_ViewB names this reader as its ENTER
;          method, and its BUTTON method is that screen's control table.
; Was `sub_FF672D`, named by notes/prom_a_naming_wave8_apply.py.
; ---------------------------------------------------------------------
PageDispatch_L0adSingleS0und:
	cp	(UI_ScreenPage:16), 0x02                            ; FF672D  c1 29 22 3f 02
	jr nc, .LFF674C                                      ; FF6732  6f 18
	ld c, 0x04:opc                                          ; FF6734  23 04
	mul	bc, (UI_ScreenPage:16)                              ; FF6736  c1 29 22 43
	extz XBC                                             ; FF673A  e9 12
	add XBC,ScreenEnterPages_L0adSingleS0und                              ; FF673C  e9 c8 41 40 ff 00
	ld XBC,(XBC)                                         ; FF6742  a1 21
	lda xiy, (.LFF674C:24)                               ; FF6744  f2 4c 67 ff 35
	push XIY                                             ; FF6749  3d
	jp (xbc)                                             ; FF674A  b1 d8
.LFF674C:
	ret                                                  ; FF674C  0e
; ScreenEnter_L0adSingleS0und_Page0: ScreenEnterPages_L0adSingleS0und[0] -- what PageDispatch_L0adSingleS0und, the ENTER method of the L0adSingleS0und screen, runs
;   when UI_ScreenPage is 0 (notes/prom_a_page_enter_names.py).
ScreenEnter_L0adSingleS0und_Page0:   ; entry: named by 1 `.long` operand, first at 0xFF4041
	pushw hl                                             ; FF674D  2b
	push XIX                                             ; FF674E  3c
	lda xix, (DisplayList_RunOnLayer_SaveRegs:24)                             ; FF674F  f2 d3 75 ff 34
	ld (0x21fa:16), 0x00                                 ; FF6754  f1 fa 21 00 00
	ld c, (UI_ScreenLatch:16)                                   ; FF6759  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FF675D  c1 7b 20 f3
	jr z, .LFF6781                                       ; FF6761  66 1e
	call T_Playback_StopAllAndIgnoreMidiStart                                        ; FF6763  1d 94 25 f4
	ld (UI_ScreenItem:16), 0x00                                 ; FF6767  f1 20 27 00 00
	call T_DiskLoadScreen_MountAndScanDirectory                                        ; FF676C  1d b4 25 f4
	calr UI_StatusCode_Is0or2or4                                      ; FF6770  1e 29 0e
	cp wa, 0x00:i3                                         ; FF6773  d8 d8
	jr z, .LFF6781                                       ; FF6775  66 0a
	ld (UI_Request:16), 0x40                                 ; FF6777  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF677C  f1 71 20 00 80
.LFF6781:
	call T_CallbackQueue_ResetAndRestartTask2            ; FF6781  1d 80 2e f4
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF6785  1d 04 76 ff
	ld c, 0x02:opc                                          ; FF6789  23 02
	mul	bc, (0x2736:16)                              ; FF678B  c1 36 27 43
	extz XBC                                             ; FF678F  e9 12
	add XBC,Table_FF4039                                 ; FF6791  e9 c8 39 40 ff 00
	ld BC,(XBC)                                          ; FF6797  91 21
	pushw bc                                             ; FF6799  29
	push 0x00                                            ; FF679A  09 00
	push	(0x2737:16)                                  ; FF679C  c1 37 27 04
	call T_SoundGroup_MaxMemberIndex_ByStack                                        ; FF67A0  1d 08 34 f4
	ld H,A                                               ; FF67A4  c9 8e
	pop XIY                                              ; FF67A6  5d
	cp	a, (0x2738:16)                               ; FF67A7  c1 38 27 f1
	jr nc, .LFF67B1                                      ; FF67AB  6f 04
	ld (0x2738:16), a                                   ; FF67AD  f1 38 27 41
.LFF67B1:
	pushw 0x00                                           ; FF67B1  0b 00 00
	lda xbc, (ScreenEnter_L0adSingleS0und_Page0_DL:24)                              ; FF67B4  f2 f0 8d f5 31
	push XBC                                             ; FF67B9  39
	lda xwa, (DL_LoadSingleSoundDiskGr0upSingleFileBankS0und:24) ; FF67BA  f2 53 8c f5 30
	push XWA                                             ; FF67BF  38
	lda xiy, (.LFF67C8:24)                               ; FF67C0  f2 c8 67 ff 35
	push XIY                                             ; FF67C5  3d
	jp (xix)                                             ; FF67C6  b4 d8
.LFF67C8:
	pushw 0x02                                           ; FF67C8  0b 02 00
	lda xbc, (DL_LoadSingleCombinationDiskGr0upSingleUser1FileBankUser1S0und:24) ; FF67CB  f2 04 8e f5 31
	push XBC                                             ; FF67D0  39
	lda xwa, (ScreenEnter_L0adSingleS0und_Page0_DL:24)                              ; FF67D1  f2 f0 8d f5 30
	push XWA                                             ; FF67D6  38
	lda xiy, (.LFF67DF:24)                               ; FF67D7  f2 df 67 ff 35
	push XIY                                             ; FF67DC  3d
	jp (xix)                                             ; FF67DD  b4 d8
.LFF67DF:
	pushw 0x00                                           ; FF67DF  0b 00 00
	lda xbc, (DL_F590F1:24)                              ; FF67E2  f2 f1 90 f5 31
	push XBC                                             ; FF67E7  39
	lda xwa, (DL_F590E7:24)                              ; FF67E8  f2 e7 90 f5 30
	push XWA                                             ; FF67ED  38
	lda xiy, (.LFF67F6:24)                               ; FF67EE  f2 f6 67 ff 35
	push XIY                                             ; FF67F3  3d
	jp (xix)                                             ; FF67F4  b4 d8
.LFF67F6:
	calr L0adSingleS0und_DrawGroupName                                      ; FF67F6  1e 2b 0a
	calr L0adSingleS0und_DrawGroupSounds                                      ; FF67F9  1e 9a 0a
	push 0x00                                            ; FF67FC  09 00
	push	(0x2735:16)                                  ; FF67FE  c1 35 27 04
	calr L0adSingle_DrawBankAndNumber                                      ; FF6802  1e 31 0c
	call Disk_FormatSelectedEntry_SaveRegs                                      ; FF6805  1d 76 77 ff
	lda xbc, (0xf5911e:24)                               ; FF6809  f2 1e 91 f5 31
	push XBC                                             ; FF680E  39
	lda xwa, (DL_F590F1:24)                              ; FF680F  f2 f1 90 f5 30
	push XWA                                             ; FF6814  38
	call T_DisplayListB_Run_Stack                        ; FF6815  1d 04 2e f4
	lda xbc, (DL_F591A6:24)                              ; FF6819  f2 a6 91 f5 31
	push XBC                                             ; FF681E  39
	call DLB_Array8_SaveRegs                                      ; FF681F  1d 3f 76 ff
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF6823  f1 40 25 00 00
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF6828  1d 15 76 ff
	add XSP,0x0000002c                                   ; FF682C  ef c8 2c 00 00 00
	pop XIX                                              ; FF6832  5c
	popw hl                                              ; FF6833  4b
	ret                                                  ; FF6834  0e
; ScreenEnter_L0adSingleS0und_Page1: ScreenEnterPages_L0adSingleS0und[1] -- what PageDispatch_L0adSingleS0und, the ENTER method of the L0adSingleS0und screen, runs
;   when UI_ScreenPage is 1 (notes/prom_a_page_enter_names.py).
ScreenEnter_L0adSingleS0und_Page1:   ; entry: named by 1 `.long` operand, first at 0xFF4045
	push XIX                                             ; FF6835  3c
	lda xix, (DisplayList_RunOnLayer_SaveRegs:24)                             ; FF6836  f2 d3 75 ff 34
	call T_CallbackQueue_ResetAndRestartTask2            ; FF683B  1d 80 2e f4
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF683F  1d 04 76 ff
	pushw 0x00                                           ; FF6843  0b 00 00
	lda xbc, (ScreenEnter_L0adSingleS0und_Page1_DL:24)                              ; FF6846  f2 49 8c f5 31
	push XBC                                             ; FF684B  39
	lda xwa, (DL_LoadSingleSoundDiskGr0upSingleFileBankS0undGr0up:24) ; FF684C  f2 d7 8a f5 30
	push XWA                                             ; FF6851  38
	lda xiy, (.LFF685A:24)                               ; FF6852  f2 5a 68 ff 35
	push XIY                                             ; FF6857  3d
	jp (xix)                                             ; FF6858  b4 d8
.LFF685A:
	pushw 0x02                                           ; FF685A  0b 02 00
	lda xbc, (DL_LoadSingleSoundDiskGr0upSingleFileBankS0und:24) ; FF685D  f2 53 8c f5 31
	push XBC                                             ; FF6862  39
	lda xwa, (ScreenEnter_L0adSingleS0und_Page1_DL:24)                              ; FF6863  f2 49 8c f5 30
	push XWA                                             ; FF6868  38
	lda xiy, (.LFF6871:24)                               ; FF6869  f2 71 68 ff 35
	push XIY                                             ; FF686E  3d
	jp (xix)                                             ; FF686F  b4 d8
.LFF6871:
	pushw 0x00                                           ; FF6871  0b 00 00
	lda xbc, (DL_F590E7:24)                              ; FF6874  f2 e7 90 f5 31
	push XBC                                             ; FF6879  39
	lda xwa, (DL_F590DD:24)                              ; FF687A  f2 dd 90 f5 30
	push XWA                                             ; FF687F  38
	lda xiy, (.LFF6888:24)                               ; FF6880  f2 88 68 ff 35
	push XIY                                             ; FF6885  3d
	jp (xix)                                             ; FF6886  b4 d8
.LFF6888:
	push 0x00                                            ; FF6888  09 00
	push	(0x273a:16)                                  ; FF688A  c1 3a 27 04
	calr L0adSingleS0und_DrawGroupList                                      ; FF688E  1e c2 08
	call Disk_FormatSelectedEntry_SaveRegs                                      ; FF6891  1d 76 77 ff
	ld c, (0x2727:16)                                   ; FF6895  c1 27 27 23
	inc 1,C                                              ; FF6899  cb 61
	ld (0x2730:16), c                                   ; FF689B  f1 30 27 43
	lda xbc, (DLText_F59128:24)                          ; FF689F  f2 28 91 f5 31
	push XBC                                             ; FF68A4  39
	lda xwa, (DL_F590F1:24)                              ; FF68A5  f2 f1 90 f5 30
	push XWA                                             ; FF68AA  38
	call T_DisplayListB_Run_Stack                        ; FF68AB  1d 04 2e f4
	lda xbc, (DL_F59150:24)                              ; FF68AF  f2 50 91 f5 31
	push XBC                                             ; FF68B4  39
	call DLB_Array8_SaveRegs                                      ; FF68B5  1d 3f 76 ff
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF68B9  f1 40 25 00 00
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF68BE  1d 15 76 ff
	add XSP,0x0000002c                                   ; FF68C2  ef c8 2c 00 00 00
	pop XIX                                              ; FF68C8  5c
	ret                                                  ; FF68C9  0e
; ---------------------------------------------------------------------
; ScreenLeave_L0adSingleS0und -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0x74, i.e. SCREEN ID 0x54 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x74 -> the screen object at
;          0xF423E0, whose +4 slot is `jp 0xFF68CA`, and from no other live
;          screen object's two callable slots.
; Evidence: the +4 offset is PanelScreen_VtableTable's own (its header's
;          checks V1-V6): +0 ENTER is called by PanelScreen_CallEnter_A/B, +4
;          LEAVE by PanelScreen_CallLeave_A/B with the id that just STOPPED
;          being current, +8 BUTTON by PanelButton_Route (0xF8621E).
; Screen:   L0adSingleS0und -- inherited from the +0 ENTER label
;          PageDispatch_L0adSingleS0und, not from any text this pass read.
; Was `sub_FF68CA`.
; ---------------------------------------------------------------------
ScreenLeave_L0adSingleS0und:
	call DiskScreen_LeaveOnScreenChange                                      ; FF68CA  1d 6c 79 ff
	call T_Disk_PortA3_Release_Call_Call                                        ; FF68CE  1d 90 25 f4
	ld (0x21fa:16), 0x00                                 ; FF68D2  f1 fa 21 00 00
	ret                                                  ; FF68D7  0e
; ---------------------------------------------------------------------
; PanelButtonDispatch_L0adSingleS0und -- run Dispatch_FF4049's handler for
;          one PANEL CONTROL
;
; Inputs:   (XIZ+0x08) = the 5-bit panel control index; (XIZ+0x0A) =
;          the argument this reader forwards to the handler.
; Evidence: the index is `((0x2229) << 5) + H` -- the page byte
;          times the 32-entry row length, plus the control --
;          and `add XBC,0x00FF4049` at 0xFF68F1 names the table.
; ⚠ No explicit `cp H,0x20` here, unlike its single-row
;          siblings: H arrives already masked to five bits.
;          The handler is CALLED, not jumped to: the reader pushes
;          a return address before `jp (XBC)`.
; Control legend: notes/FINDINGS-prom_a-panel-control-map.md, and
;          `python3 notes/prom_a_panel_control_map.py --map`.
; Screen:   L0adSingleS0und -- the screen object at PanelScreen_VtableTable
;          entry 0x74, i.e. SCREEN ID 0x54 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58C53, whose first
;          record reads "LOAD SINGLE SOUND".
; Was `sub_FF68D8`, named by notes/prom_a_naming_wave8_apply.py.
; ---------------------------------------------------------------------
PanelButtonDispatch_L0adSingleS0und:
	link XIZ,0x0000                                      ; FF68D8  ee 0c 00 00
	pushw hl                                             ; FF68DC  2b
	ld H,(XIZ+0x08)                                      ; FF68DD  8e 08 26
	pushw	(xiz+10)                                     ; FF68E0  9e 0a 04
	ld c, (UI_ScreenPage:16)                                   ; FF68E3  c1 29 22 23
	sll c, 0x05                                          ; FF68E7  cb ee 05
	add C,H                                              ; FF68EA  ce 83
	mul C,0x04                                           ; FF68EC  cb 08 04
	extz XBC                                             ; FF68EF  e9 12
	add XBC,Dispatch_FF4049                              ; FF68F1  e9 c8 49 40 ff 00
	ld XBC,(XBC)                                         ; FF68F7  a1 21
	lda xiy, (.LFF6901:24)                               ; FF68F9  f2 01 69 ff 35
	push XIY                                             ; FF68FE  3d
	jp (xbc)                                             ; FF68FF  b1 d8
.LFF6901:
	popw bc                                              ; FF6901  49
	popw hl                                              ; FF6902  4b
	unlk XIZ                                             ; FF6903  ee 0d
	ret                                                  ; FF6905  0e
; SoftKeyCol1_L0adSingle_AllPages: slot 0 (and its held form 0x11) of all four pages of both screens: PanelDial_SetButtonPair(0, 0x80),
;   UI_ScreenItem_StepByDial, Disk_FormatSelectedEntry_SaveRegs, then the string-table list DL_F5910F -- steps the
;   selected disk file entry.
SoftKeyCol1_L0adSingle_AllPages:   ; entry: named by 8 `.long` operands, first at 0xFF4049
	pushw 0x80                                           ; FF6906  0b 80 00
	pushw 0x00                                           ; FF6909  0b 00 00
	calr PanelDial_SetButtonPair                                      ; FF690C  1e 1b 08
	call UI_ScreenItem_StepByDial                                      ; FF690F  1d 43 77 ff
	call Disk_FormatSelectedEntry_SaveRegs                                      ; FF6913  1d 76 77 ff
	lda xbc, (DL_F5910F:24)                              ; FF6917  f2 0f 91 f5 31
	push XBC                                             ; FF691C  39
	call DLB_Handler_StringTable_Veneer                                      ; FF691D  1d 56 76 ff
	inc 8,XSP                                            ; FF6921  ef 60
	ret                                                  ; FF6923  0e
; SoftKeyCol2_L0adSingleS0und_Page1: Dispatch_FF4049+128[1] -- the SoftKeyCol2 handler of L0adSingleS0und_Page1; the table's other named entries sit at their own
;   controls' slots and name the same screen (notes/prom_ab_button_table_siblings.py).
SoftKeyCol2_L0adSingleS0und_Page1:   ; entry: named by 2 `.long` operands, first at 0xFF40CD
	link XIZ,0x0000                                      ; FF6924  ee 0c 00 00
	push XIX                                             ; FF6928  3c
	lda xix, (0x2728:16)                                ; FF6929  f1 28 27 34
	pushw 0x81                                           ; FF692D  0b 81 00
	pushw 0x01                                           ; FF6930  0b 01 00
	calr PanelDial_SetButtonPair                                      ; FF6933  1e f4 07
	ld BC,(XIZ+0x08)                                     ; FF6936  9e 08 21
	and BC,0x0080                                        ; FF6939  d9 cc 80 00
	pop XIY                                              ; FF693D  5d
	jr z, .LFF694A                                       ; FF693E  66 0a
	ld C,(XIX)                                           ; FF6940  84 23
	cp c, 0x00:i3                                          ; FF6942  cb d8
	jr z, .LFF6952                                       ; FF6944  66 0c
	decm8 0x01, (xix)                                    ; FF6946  84 69
	jr .LFF6952                                          ; FF6948  68 08
.LFF694A:
	ld C,(XIX)                                           ; FF694A  84 23
	cp c, 0x03:i3                                          ; FF694C  cb db
	jr nc, .LFF6952                                      ; FF694E  6f 02
	incm8 0x01, (xix)                                    ; FF6950  84 61
.LFF6952:
	lda xbc, (DL_F590F1:24)                              ; FF6952  f2 f1 90 f5 31
	push XBC                                             ; FF6957  39
	call DLB_Handler_StringTable_Veneer                                      ; FF6958  1d 56 76 ff
	lda xbc, (0xf59100:24)                               ; FF695C  f2 00 91 f5 31
	push XBC                                             ; FF6961  39
	call DLB_Handler_StringTable_Veneer                                      ; FF6962  1d 56 76 ff
	push 0x00                                            ; FF6966  09 00
	push	(0x273a:16)                                  ; FF6968  c1 3a 27 04
	calr L0adSingleS0und_DrawGroupList                                      ; FF696C  1e e4 07
	calr Var2728_Is2or3                                      ; FF696F  1e b3 0b
	inc 8,XSP                                            ; FF6972  ef 60
	inc 2,XSP                                            ; FF6974  ef 62
	cp wa, 0x00:i3                                         ; FF6976  d8 d8
	jr z, .LFF69B5                                       ; FF6978  66 3b
	lda xbc, (DL_F5915B:24)                              ; FF697A  f2 5b 91 f5 31
	push XBC                                             ; FF697F  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF6980  1d 23 76 ff
	ld (0x273a:16), 0x00                                 ; FF6984  f1 3a 27 00 00
	ld (0x2739:16), 0x00                                 ; FF6989  f1 39 27 00 00
	ld (0x2737:16), 0x00                                 ; FF698E  f1 37 27 00 00
	ld (0x2727:16), 0x00                                 ; FF6993  f1 27 27 00 00
	ld (0x2730:16), 0x01                                 ; FF6998  f1 30 27 00 01
	lda xbc, (0xf5911e:24)                               ; FF699D  f2 1e 91 f5 31
	push XBC                                             ; FF69A2  39
	call DLB_Handler_Decimal_Veneer                                      ; FF69A3  1d 68 76 ff
	lda xbc, (DL_F59150:24)                              ; FF69A7  f2 50 91 f5 31
	push XBC                                             ; FF69AC  39
	call DLB_Array8_SaveRegs                                      ; FF69AD  1d 3f 76 ff
	inc 8,XSP                                            ; FF69B1  ef 60
	inc 4,XSP                                            ; FF69B3  ef 64
.LFF69B5:
	pop XIX                                              ; FF69B5  5c
	unlk XIZ                                             ; FF69B6  ee 0d
	ret                                                  ; FF69B8  0e
; SoftKeyCols3_4_L0adSingle_Page1: slots 2 and 3 of page 1 of both screens: steps (0x2727) within 0..15 (0..0 for a drum bank) and shows it 1-based
;   through (0x2730), the decimal readout of DL_F5910F's second record.
SoftKeyCols3_4_L0adSingle_Page1:   ; entry: named by 8 `.long` operands, first at 0xFF40D1
	link XIZ,0x0000                                      ; FF69B9  ee 0c 00 00
	pushw hl                                             ; FF69BD  2b
	pushw de                                             ; FF69BE  2a
	push XIX                                             ; FF69BF  3c
	lda xix, (0x2727:16)                                ; FF69C0  f1 27 27 34
	ld h, 0x10:opc                                          ; FF69C4  26 10
	calr Var2728_Is2or3                                      ; FF69C6  1e 5c 0b
	cp wa, 0x00:i3                                         ; FF69C9  d8 d8
	jr z, .LFF69CF                                       ; FF69CB  66 02
	ld h, 0x01:opc                                          ; FF69CD  26 01
.LFF69CF:
	pushw 0x83                                           ; FF69CF  0b 83 00
	pushw 0x02                                           ; FF69D2  0b 02 00
	calr PanelDial_SetButtonPair                                      ; FF69D5  1e 52 07
	ld BC,(XIZ+0x08)                                     ; FF69D8  9e 08 21
	and BC,0x0080                                        ; FF69DB  d9 cc 80 00
	pop XIY                                              ; FF69DF  5d
	jr z, .LFF69EC                                       ; FF69E0  66 0a
	ld C,(XIX)                                           ; FF69E2  84 23
	cp c, 0x00:i3                                          ; FF69E4  cb d8
	jr z, .LFF69FE                                       ; FF69E6  66 16
	decm8 0x01, (xix)                                    ; FF69E8  84 69
	jr .LFF69FE                                          ; FF69EA  68 12
.LFF69EC:
	ld C,H                                               ; FF69EC  ce 8b
	extz BC                                              ; FF69EE  d9 12
	ld DE,BC                                             ; FF69F0  d9 8a
	dec 1,DE                                             ; FF69F2  da 69
	ld C,(XIX)                                           ; FF69F4  84 23
	extz BC                                              ; FF69F6  d9 12
	cp BC,DE                                             ; FF69F8  da f1
	jr nc, .LFF69FE                                      ; FF69FA  6f 02
	incm8 0x01, (xix)                                    ; FF69FC  84 61
.LFF69FE:
	ld C,(XIX)                                           ; FF69FE  84 23
	inc 1,C                                              ; FF6A00  cb 61
	ld (0x2730:16), c                                   ; FF6A02  f1 30 27 43
	lda xbc, (0xf5911e:24)                               ; FF6A06  f2 1e 91 f5 31
	push XBC                                             ; FF6A0B  39
	call DLB_Handler_Decimal_Veneer                                      ; FF6A0C  1d 68 76 ff
	pop XBC                                              ; FF6A10  59
	pop XIX                                              ; FF6A11  5c
	popw de                                              ; FF6A12  4a
	popw hl                                              ; FF6A13  4b
	unlk XIZ                                             ; FF6A14  ee 0d
	ret                                                  ; FF6A16  0e
; SoftKeyCols5_6_L0adSingleS0und_Page1: slots 4 and 5 of L0adSingleS0und page 1: (0x2736) = 0 / 1 (2 / 3 for a drum bank) by the argument's bit 7
;   (the direction) -- USER 1 / USER 2 (/ USER1 DRUM / USER2 DRUM) in DLText_F59128 -- then redraws the (0x2736) string-table record at 0xF59100.
SoftKeyCols5_6_L0adSingleS0und_Page1:   ; entry: named by 4 `.long` operands, first at 0xFF40D9
	link XIZ,0x0000                                      ; FF6A17  ee 0c 00 00
	push XIX                                             ; FF6A1B  3c
	lda xix, (0x2736:16)                                ; FF6A1C  f1 36 27 34
	pushw 0x84                                           ; FF6A20  0b 84 00
	pushw 0x04                                           ; FF6A23  0b 04 00
	calr PanelDial_SetButtonPair                                      ; FF6A26  1e 01 07
	ld BC,(XIZ+0x08)                                     ; FF6A29  9e 08 21
	and BC,0x0080                                        ; FF6A2C  d9 cc 80 00
	pop XIY                                              ; FF6A30  5d
	jr nz, .LFF6A44                                      ; FF6A31  6e 11
	calr Var2728_Is2or3                                      ; FF6A33  1e ef 0a
	cp wa, 0x00:i3                                         ; FF6A36  d8 d8
	jr nz, .LFF6A3F                                      ; FF6A38  6e 05
	ld (XIX),0x01                                        ; FF6A3A  b4 00 01
	jr .LFF6A53                                          ; FF6A3D  68 14
.LFF6A3F:
	ld (XIX),0x03                                        ; FF6A3F  b4 00 03
	jr .LFF6A53                                          ; FF6A42  68 0f
.LFF6A44:
	calr Var2728_Is2or3                                      ; FF6A44  1e de 0a
	cp wa, 0x00:i3                                         ; FF6A47  d8 d8
	jr nz, .LFF6A50                                      ; FF6A49  6e 05
	ld (XIX),0x00                                        ; FF6A4B  b4 00 00
	jr .LFF6A53                                          ; FF6A4E  68 03
.LFF6A50:
	ld (XIX),0x02                                        ; FF6A50  b4 00 02
.LFF6A53:
	lda xbc, (0xf59100:24)                               ; FF6A53  f2 00 91 f5 31
	push XBC                                             ; FF6A58  39
	call DLB_Handler_StringTable_Veneer                                      ; FF6A59  1d 56 76 ff
	push 0x00                                            ; FF6A5D  09 00
	push	(0x273a:16)                                  ; FF6A5F  c1 3a 27 04
	calr L0adSingleS0und_DrawGroupList                                      ; FF6A63  1e ed 06
	inc 6,XSP                                            ; FF6A66  ef 66
	pop XIX                                              ; FF6A68  5c
	unlk XIZ                                             ; FF6A69  ee 0d
	ret                                                  ; FF6A6B  0e
; SoftKeyCols7_8_L0adSingle_Page1: slots 6 and 7 of page 1 of both screens: moves the cursor row (0x2739, 0..7) and scrolls the list top (0x273A, up to 8)
;   when the cursor is at an end; refused for a drum bank.  DL_F5915B is the row highlight (source 0x2739).
SoftKeyCols7_8_L0adSingle_Page1:   ; entry: named by 8 `.long` operands, first at 0xFF40E1
	link XIZ,0x0000                                      ; FF6A6C  ee 0c 00 00
	push XIX                                             ; FF6A70  3c
	lda xix, (0x273a:16)                                ; FF6A71  f1 3a 27 34
	calr Var2728_Is2or3                                      ; FF6A75  1e ad 0a
	cp wa, 0x00:i3                                         ; FF6A78  d8 d8
	jrl nz, .LFF6AFA                                     ; FF6A7A  7e 7d 00
	pushw 0x06                                           ; FF6A7D  0b 06 00
	pushw 0x86                                           ; FF6A80  0b 86 00
	calr PanelDial_SetButtonPair                                      ; FF6A83  1e a4 06
	lda xbc, (DL_F5915B:24)                              ; FF6A86  f2 5b 91 f5 31
	push XBC                                             ; FF6A8B  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF6A8C  1d 23 76 ff
	ld BC,(XIZ+0x08)                                     ; FF6A90  9e 08 21
	and BC,0x0080                                        ; FF6A93  d9 cc 80 00
	inc 8,XSP                                            ; FF6A97  ef 60
	jr nz, .LFF6AB9                                      ; FF6A99  6e 1e
	cp	(0x2739:16), 0x00                            ; FF6A9B  c1 39 27 3f 00
	jr nz, .LFF6AB3                                      ; FF6AA0  6e 11
	ld C,(XIX)                                           ; FF6AA2  84 23
	cp c, 0x00:i3                                          ; FF6AA4  cb d8
	jr z, .LFF6AE5                                       ; FF6AA6  66 3d
	decm8 0x01, (xix)                                    ; FF6AA8  84 69
	cp	(UI_ScreenLatch:16), 0x54                            ; FF6AAA  c1 7a 20 3f 54
	jr nz, .LFF6AD8                                      ; FF6AAF  6e 27
	jr .LFF6AD0                                          ; FF6AB1  68 1d
.LFF6AB3:
	dec 0x01, (0x2739:16)                                ; FF6AB3  c1 39 27 69
	jr .LFF6AE5                                          ; FF6AB7  68 2c
.LFF6AB9:
	cp	(0x2739:16), 0x07                            ; FF6AB9  c1 39 27 3f 07
	jr nz, .LFF6AE1                                      ; FF6ABE  6e 21
	ld C,(XIX)                                           ; FF6AC0  84 23
	cp C,0x08                                            ; FF6AC2  cb cf 08
	jr nc, .LFF6AE5                                      ; FF6AC5  6f 1e
	incm8 0x01, (xix)                                    ; FF6AC7  84 61
	cp	(UI_ScreenLatch:16), 0x54                            ; FF6AC9  c1 7a 20 3f 54
	jr nz, .LFF6AD8                                      ; FF6ACE  6e 08
.LFF6AD0:
	ld C,(XIX)                                           ; FF6AD0  84 23
	pushw bc                                             ; FF6AD2  29
	calr L0adSingleS0und_DrawGroupList                                      ; FF6AD3  1e 7d 06
	jr .LFF6ADE                                          ; FF6AD6  68 06
.LFF6AD8:
	ld C,(XIX)                                           ; FF6AD8  84 23
	pushw bc                                             ; FF6ADA  29
	calr L0adSingleC0mbination_DrawGroupList                                      ; FF6ADB  1e 55 08
.LFF6ADE:
	popw bc                                              ; FF6ADE  49
	jr .LFF6AE5                                          ; FF6ADF  68 04
.LFF6AE1:
	inc 0x01, (0x2739:16)                                ; FF6AE1  c1 39 27 61
.LFF6AE5:
	ld C,(XIX)                                           ; FF6AE5  84 23
	add c, (0x2739:16)                                   ; FF6AE7  c1 39 27 83
	ld (0x2737:16), c                                   ; FF6AEB  f1 37 27 43
	lda xbc, (DL_F59150:24)                              ; FF6AEF  f2 50 91 f5 31
	push XBC                                             ; FF6AF4  39
	call DLB_Array8_SaveRegs                                      ; FF6AF5  1d 3f 76 ff
	pop XIY                                              ; FF6AF9  5d
.LFF6AFA:
	pop XIX                                              ; FF6AFA  5c
	unlk XIZ                                             ; FF6AFB  ee 0d
	ret                                                  ; FF6AFD  0e
; ---------------------------------------------------------------------
; LcdKeyRow1_L0adSingleS0und_Page1 -- what Dispatch_FF4049 runs for panel
;          control 0x08
;
; Reached from: Dispatch_FF4049 entry [40] (page 1, control 0x08) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x08 is the LCD row 1 button pair -- the left-hand and
;          right-hand buttons of the display's TOP row. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   L0adSingleS0und -- the screen object at PanelScreen_VtableTable
;          entry 0x74, i.e. SCREEN ID 0x54 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58C53, whose first
;          record reads "LOAD SINGLE SOUND".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow1_L0adSingleS0und_Page1:
	link XIZ,0x0000                                      ; FF6AFE  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF6B02  9e 08 21
	and BC,0x0080                                        ; FF6B05  d9 cc 80 00
	jr nz, .LFF6B17                                      ; FF6B09  6e 0c
	ld (UI_Request_Hi:16), 0x10                                 ; FF6B0B  f1 71 20 00 10
	ld (UI_ScreenPage:16), 0x00                                 ; FF6B10  f1 29 22 00 00
	jr .LFF6B32                                          ; FF6B15  68 1b
.LFF6B17:
	pushw 0x00                                           ; FF6B17  0b 00 00
	calr Var7FD6_IsBitClear                                      ; FF6B1A  1e 1e 0a
	popw bc                                              ; FF6B1D  49
	cp wa, 0x00:i3                                         ; FF6B1E  d8 d8
	jr z, .LFF6B28                                       ; FF6B20  66 06
	call Disk_CheckSelectedEntrySignature                                      ; FF6B22  1d e3 77 ff
	jr .LFF6B32                                          ; FF6B26  68 0a
.LFF6B28:
	ld (UI_Request:16), 0xb3                                 ; FF6B28  f1 70 20 00 b3
	ld (UI_Request_Hi:16), 0x40                                 ; FF6B2D  f1 71 20 00 40
.LFF6B32:
	unlk XIZ                                             ; FF6B32  ee 0d
	ret                                                  ; FF6B34  0e
; SoftKeyCol2_L0adSingleS0und_Page0: Dispatch_FF4049+0[1] -- the SoftKeyCol2 handler of L0adSingleS0und_Page0; the table's other named entries sit at their own
;   controls' slots and name the same screen (notes/prom_ab_button_table_siblings.py).
SoftKeyCol2_L0adSingleS0und_Page0:   ; entry: named by 2 `.long` operands, first at 0xFF404D
	link XIZ,0x0000                                      ; FF6B35  ee 0c 00 00
	pushw hl                                             ; FF6B39  2b
	push XIX                                             ; FF6B3A  3c
	lda xix, (0x2728:16)                                ; FF6B3B  f1 28 27 34
	ld h, 0x00:opc                                          ; FF6B3F  26 00
	pushw 0x81                                           ; FF6B41  0b 81 00
	pushw 0x01                                           ; FF6B44  0b 01 00
	calr PanelDial_SetButtonPair                                      ; FF6B47  1e e0 05
	ld BC,(XIZ+0x08)                                     ; FF6B4A  9e 08 21
	and BC,0x0080                                        ; FF6B4D  d9 cc 80 00
	pop XIY                                              ; FF6B51  5d
	jr z, .LFF6B69                                       ; FF6B52  66 15
	ld C,(XIX)                                           ; FF6B54  84 23
	cp c, 0x00:i3                                          ; FF6B56  cb d8
	jr z, .LFF6B5C                                       ; FF6B58  66 02
	decm8 0x01, (xix)                                    ; FF6B5A  84 69
.LFF6B5C:
	ld C,(XIX)                                           ; FF6B5C  84 23
	cp c, 0x01:i3                                          ; FF6B5E  cb d9
	jr nz, .LFF6B7E                                      ; FF6B60  6e 1c
	ld (0x2736:16), 0x01                                 ; FF6B62  f1 36 27 00 01
	jr .LFF6B7C                                          ; FF6B67  68 13
.LFF6B69:
	ld C,(XIX)                                           ; FF6B69  84 23
	cp c, 0x03:i3                                          ; FF6B6B  cb db
	jr nc, .LFF6B71                                      ; FF6B6D  6f 02
	incm8 0x01, (xix)                                    ; FF6B6F  84 61
.LFF6B71:
	ld C,(XIX)                                           ; FF6B71  84 23
	cp c, 0x02:i3                                          ; FF6B73  cb da
	jr nz, .LFF6B7E                                      ; FF6B75  6e 07
	ld (0x2736:16), 0x02                                 ; FF6B77  f1 36 27 00 02
.LFF6B7C:
	ld h, 0x01:opc                                          ; FF6B7C  26 01
.LFF6B7E:
	lda xbc, (DL_F590F1:24)                              ; FF6B7E  f2 f1 90 f5 31
	push XBC                                             ; FF6B83  39
	call DLB_Handler_StringTable_Veneer                                      ; FF6B84  1d 56 76 ff
	pop XIY                                              ; FF6B88  5d
	cp h, 0x00:i3                                          ; FF6B89  ce d8
	jr z, .LFF6BB2                                       ; FF6B8B  66 25
	lda xbc, (DL_F591B1:24)                              ; FF6B8D  f2 b1 91 f5 31
	push XBC                                             ; FF6B92  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF6B93  1d 23 76 ff
	ld (0x2737:16), 0x00                                 ; FF6B97  f1 37 27 00 00
	ld (0x2738:16), 0x00                                 ; FF6B9C  f1 38 27 00 00
	ld (0x2735:16), 0x00                                 ; FF6BA1  f1 35 27 00 00
	lda xbc, (DL_F591A6:24)                              ; FF6BA6  f2 a6 91 f5 31
	push XBC                                             ; FF6BAB  39
	call DLB_Array8_SaveRegs                                      ; FF6BAC  1d 3f 76 ff
	inc 8,XSP                                            ; FF6BB0  ef 60
.LFF6BB2:
	lda xbc, (0xf59100:24)                               ; FF6BB2  f2 00 91 f5 31
	push XBC                                             ; FF6BB7  39
	call DLB_Handler_StringTable_Veneer                                      ; FF6BB8  1d 56 76 ff
	calr L0adSingleS0und_DrawGroupName                                      ; FF6BBC  1e 65 06
	calr L0adSingleS0und_DrawGroupSounds                                      ; FF6BBF  1e d4 06
	push 0x00                                            ; FF6BC2  09 00
	push	(0x2735:16)                                  ; FF6BC4  c1 35 27 04
	calr L0adSingle_DrawBankAndNumber                                      ; FF6BC8  1e 6b 08
	inc 6,XSP                                            ; FF6BCB  ef 66
	pop XIX                                              ; FF6BCD  5c
	popw hl                                              ; FF6BCE  4b
	unlk XIZ                                             ; FF6BCF  ee 0d
	ret                                                  ; FF6BD1  0e
; SoftKeyCols3_4_L0adSingleS0und_Page0: slots 2 and 3 of L0adSingleS0und page 0: steps (0x2735) down (argument bit 7 set) or up within 0..0x7F, 0..1 when
;   Var2728_Is2or3 (a drum bank), then L0adSingle_DrawBankAndNumber((0x2735)).
SoftKeyCols3_4_L0adSingleS0und_Page0:   ; entry: named by 4 `.long` operands, first at 0xFF4051
	link XIZ,0x0000                                      ; FF6BD2  ee 0c 00 00
	pushw hl                                             ; FF6BD6  2b
	pushw de                                             ; FF6BD7  2a
	push XIX                                             ; FF6BD8  3c
	lda xix, (0x2735:16)                                ; FF6BD9  f1 35 27 34
	ld h, 0x80:opc                                          ; FF6BDD  26 80
	calr Var2728_Is2or3                                      ; FF6BDF  1e 43 09
	cp wa, 0x00:i3                                         ; FF6BE2  d8 d8
	jr z, .LFF6BE8                                       ; FF6BE4  66 02
	ld h, 0x02:opc                                          ; FF6BE6  26 02
.LFF6BE8:
	pushw 0x82                                           ; FF6BE8  0b 82 00
	pushw 0x02                                           ; FF6BEB  0b 02 00
	calr PanelDial_SetButtonPair                                      ; FF6BEE  1e 39 05
	ld BC,(XIZ+0x08)                                     ; FF6BF1  9e 08 21
	and BC,0x0080                                        ; FF6BF4  d9 cc 80 00
	pop XIY                                              ; FF6BF8  5d
	jr z, .LFF6C05                                       ; FF6BF9  66 0a
	ld C,(XIX)                                           ; FF6BFB  84 23
	cp c, 0x00:i3                                          ; FF6BFD  cb d8
	jr z, .LFF6C17                                       ; FF6BFF  66 16
	decm8 0x01, (xix)                                    ; FF6C01  84 69
	jr .LFF6C17                                          ; FF6C03  68 12
.LFF6C05:
	ld C,H                                               ; FF6C05  ce 8b
	extz BC                                              ; FF6C07  d9 12
	ld DE,BC                                             ; FF6C09  d9 8a
	dec 1,DE                                             ; FF6C0B  da 69
	ld C,(XIX)                                           ; FF6C0D  84 23
	extz BC                                              ; FF6C0F  d9 12
	cp BC,DE                                             ; FF6C11  da f1
	jr nc, .LFF6C17                                      ; FF6C13  6f 02
	incm8 0x01, (xix)                                    ; FF6C15  84 61
.LFF6C17:
	ld C,(XIX)                                           ; FF6C17  84 23
	pushw bc                                             ; FF6C19  29
	calr L0adSingle_DrawBankAndNumber                                      ; FF6C1A  1e 19 08
	popw bc                                              ; FF6C1D  49
	pop XIX                                              ; FF6C1E  5c
	popw de                                              ; FF6C1F  4a
	popw hl                                              ; FF6C20  4b
	unlk XIZ                                             ; FF6C21  ee 0d
	ret                                                  ; FF6C23  0e
; SoftKeyCol5_L0adSingleS0und_Page0: Dispatch_FF4049+0[4] -- the SoftKeyCol5 handler of L0adSingleS0und_Page0; the table's other named entries sit at their own
;   controls' slots and name the same screen (notes/prom_ab_button_table_siblings.py).
SoftKeyCol5_L0adSingleS0und_Page0:   ; entry: named by 2 `.long` operands, first at 0xFF4059
	link XIZ,0x0000                                      ; FF6C24  ee 0c 00 00
	pushw hl                                             ; FF6C28  2b
	push XIX                                             ; FF6C29  3c
	lda xix, (0x2736:16)                                ; FF6C2A  f1 36 27 34
	pushw 0x84                                           ; FF6C2E  0b 84 00
	pushw 0x04                                           ; FF6C31  0b 04 00
	calr PanelDial_SetButtonPair                                      ; FF6C34  1e f3 04
	ld BC,(XIZ+0x08)                                     ; FF6C37  9e 08 21
	and BC,0x0080                                        ; FF6C3A  d9 cc 80 00
	pop XIY                                              ; FF6C3E  5d
	jr z, .LFF6C52                                       ; FF6C3F  66 11
	calr Var2728_Is2or3                                      ; FF6C41  1e e1 08
	cp wa, 0x00:i3                                         ; FF6C44  d8 d8
	jr z, .LFF6C4D                                       ; FF6C46  66 05
	ld (XIX),0x02                                        ; FF6C48  b4 00 02
	jr .LFF6C61                                          ; FF6C4B  68 14
.LFF6C4D:
	ld (XIX),0x00                                        ; FF6C4D  b4 00 00
	jr .LFF6C61                                          ; FF6C50  68 0f
.LFF6C52:
	calr Var2728_Is2or3                                      ; FF6C52  1e d0 08
	cp wa, 0x00:i3                                         ; FF6C55  d8 d8
	jr z, .LFF6C5E                                       ; FF6C57  66 05
	ld (XIX),0x03                                        ; FF6C59  b4 00 03
	jr .LFF6C61                                          ; FF6C5C  68 03
.LFF6C5E:
	ld (XIX),0x01                                        ; FF6C5E  b4 00 01
.LFF6C61:
	lda xbc, (0xf59100:24)                               ; FF6C61  f2 00 91 f5 31
	push XBC                                             ; FF6C66  39
	call DLB_Handler_StringTable_Veneer                                      ; FF6C67  1d 56 76 ff
	calr L0adSingleS0und_DrawGroupName                                      ; FF6C6B  1e b6 05
	ld C,(XIX)                                           ; FF6C6E  84 23
	mul C,0x02                                           ; FF6C70  cb 08 02
	extz XBC                                             ; FF6C73  e9 12
	add XBC,Table_FF4039                                 ; FF6C75  e9 c8 39 40 ff 00
	ld BC,(XBC)                                          ; FF6C7B  91 21
	pushw bc                                             ; FF6C7D  29
	push 0x00                                            ; FF6C7E  09 00
	push	(0x2737:16)                                  ; FF6C80  c1 37 27 04
	call T_SoundGroup_MaxMemberIndex_ByStack                                        ; FF6C84  1d 08 34 f4
	ld H,A                                               ; FF6C88  c9 8e
	inc 8,XSP                                            ; FF6C8A  ef 60
	cp	a, (0x2738:16)                               ; FF6C8C  c1 38 27 f1
	jr nc, .LFF6C96                                      ; FF6C90  6f 04
	ld (0x2738:16), a                                   ; FF6C92  f1 38 27 41
.LFF6C96:
	calr L0adSingleS0und_DrawGroupSounds                                      ; FF6C96  1e fd 05
	pop XIX                                              ; FF6C99  5c
	popw hl                                              ; FF6C9A  4b
	unlk XIZ                                             ; FF6C9B  ee 0d
	ret                                                  ; FF6C9D  0e
; SoftKeyCol6_L0adSingle_Page0: slot 5 of page 0 of both screens: steps (0x2737) within 0..15 (forced 0 for a drum bank), then the group's name and
;   members -- L0adSingleS0und_DrawGroupName / _DrawGroupSounds when UI_ScreenLatch is 0x54, else the C0mbination pair.
SoftKeyCol6_L0adSingle_Page0:   ; entry: named by 4 `.long` operands, first at 0xFF405D
	link XIZ,0x0000                                      ; FF6C9E  ee 0c 00 00
	push XIX                                             ; FF6CA2  3c
	lda xix, (0x2737:16)                                ; FF6CA3  f1 37 27 34
	pushw 0x85                                           ; FF6CA7  0b 85 00
	pushw 0x05                                           ; FF6CAA  0b 05 00
	calr PanelDial_SetButtonPair                                      ; FF6CAD  1e 7a 04
	ld BC,(XIZ+0x08)                                     ; FF6CB0  9e 08 21
	and BC,0x0080                                        ; FF6CB3  d9 cc 80 00
	pop XIY                                              ; FF6CB7  5d
	jr nz, .LFF6CC4                                      ; FF6CB8  6e 0a
	ld C,(XIX)                                           ; FF6CBA  84 23
	cp c, 0x00:i3                                          ; FF6CBC  cb d8
	jr z, .LFF6CCD                                       ; FF6CBE  66 0d
	decm8 0x01, (xix)                                    ; FF6CC0  84 69
	jr .LFF6CCD                                          ; FF6CC2  68 09
.LFF6CC4:
	ld C,(XIX)                                           ; FF6CC4  84 23
	cp C,0x0f                                            ; FF6CC6  cb cf 0f
	jr nc, .LFF6CCD                                      ; FF6CC9  6f 02
	incm8 0x01, (xix)                                    ; FF6CCB  84 61
.LFF6CCD:
	calr Var2728_Is2or3                                      ; FF6CCD  1e 55 08
	cp wa, 0x00:i3                                         ; FF6CD0  d8 d8
	jr z, .LFF6CD7                                       ; FF6CD2  66 03
	ld (XIX),0x00                                        ; FF6CD4  b4 00 00
.LFF6CD7:
	cp	(UI_ScreenLatch:16), 0x54                            ; FF6CD7  c1 7a 20 3f 54
	jr nz, .LFF6CE6                                      ; FF6CDC  6e 08
	calr L0adSingleS0und_DrawGroupSounds                                      ; FF6CDE  1e b5 05
	calr L0adSingleS0und_DrawGroupName                                      ; FF6CE1  1e 40 05
	jr .LFF6CEC                                          ; FF6CE4  68 06
.LFF6CE6:
	calr L0adSingleC0mbination_DrawGroupCombinations                                      ; FF6CE6  1e b0 06
	calr L0adSingleC0mbination_DrawGroupName                                      ; FF6CE9  1e 71 05
.LFF6CEC:
	pop XIX                                              ; FF6CEC  5c
	unlk XIZ                                             ; FF6CED  ee 0d
	ret                                                  ; FF6CEF  0e
; SoftKeyCols7_8_L0adSingleS0und_Page0: slots 6 and 7 of L0adSingleS0und page 0: steps (0x2738) within 0..T_SoundGroup_MaxMemberIndex_ByStack(bank
;   Table_FF4039[(0x2736)], group (0x2737)) and redraws the member highlight (DL_F591A6 / DL_F591B1, source 0x2738).
SoftKeyCols7_8_L0adSingleS0und_Page0:   ; entry: named by 4 `.long` operands, first at 0xFF4061
	link XIZ,0x0000                                      ; FF6CF0  ee 0c 00 00
	pushw hl                                             ; FF6CF4  2b
	push XIX                                             ; FF6CF5  3c
	lda xix, (0x2738:16)                                ; FF6CF6  f1 38 27 34
	ld c, 0x02:opc                                          ; FF6CFA  23 02
	mul	bc, (0x2736:16)                              ; FF6CFC  c1 36 27 43
	extz XBC                                             ; FF6D00  e9 12
	add XBC,Table_FF4039                                 ; FF6D02  e9 c8 39 40 ff 00
	ld BC,(XBC)                                          ; FF6D08  91 21
	pushw bc                                             ; FF6D0A  29
	push 0x00                                            ; FF6D0B  09 00
	push	(0x2737:16)                                  ; FF6D0D  c1 37 27 04
	call T_SoundGroup_MaxMemberIndex_ByStack                                        ; FF6D11  1d 08 34 f4
	ld H,A                                               ; FF6D15  c9 8e
	pop XIY                                              ; FF6D17  5d
	cp A,0xff                                            ; FF6D18  c9 cf ff
	jr z, .LFF6D60                                       ; FF6D1B  66 43
	pushw 0x06                                           ; FF6D1D  0b 06 00
	pushw 0x86                                           ; FF6D20  0b 86 00
	calr PanelDial_SetButtonPair                                      ; FF6D23  1e 04 04
	lda xbc, (DL_F591B1:24)                              ; FF6D26  f2 b1 91 f5 31
	push XBC                                             ; FF6D2B  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF6D2C  1d 23 76 ff
	ld BC,(XIZ+0x08)                                     ; FF6D30  9e 08 21
	and BC,0x0080                                        ; FF6D33  d9 cc 80 00
	inc 8,XSP                                            ; FF6D37  ef 60
	jr nz, .LFF6D45                                      ; FF6D39  6e 0a
	ld C,(XIX)                                           ; FF6D3B  84 23
	cp c, 0x00:i3                                          ; FF6D3D  cb d8
	jr z, .LFF6D50                                       ; FF6D3F  66 0f
	decm8 0x01, (xix)                                    ; FF6D41  84 69
	jr .LFF6D4D                                          ; FF6D43  68 08
.LFF6D45:
	ld C,(XIX)                                           ; FF6D45  84 23
	cp C,H                                               ; FF6D47  ce f3
	jr nc, .LFF6D50                                      ; FF6D49  6f 05
	incm8 0x01, (xix)                                    ; FF6D4B  84 61
.LFF6D4D:
	calr L0adSingleS0und_DrawGroupSounds                                      ; FF6D4D  1e 46 05
.LFF6D50:
	lda xbc, (DL_F591A6:24)                              ; FF6D50  f2 a6 91 f5 31
	push XBC                                             ; FF6D55  39
	call DLB_Array8_SaveRegs                                      ; FF6D56  1d 3f 76 ff
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF6D5A  f1 40 25 00 00
	pop XIY                                              ; FF6D5F  5d
.LFF6D60:
	pop XIX                                              ; FF6D60  5c
	popw hl                                              ; FF6D61  4b
	unlk XIZ                                             ; FF6D62  ee 0d
	ret                                                  ; FF6D64  0e
; ---------------------------------------------------------------------
; LcdKeyRow1_L0adSingleS0und_Page0 -- what Dispatch_FF4049 runs for panel
;          control 0x08
;
; Reached from: Dispatch_FF4049 entry [8] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x08 is the LCD row 1 button pair -- the left-hand and
;          right-hand buttons of the display's TOP row. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   L0adSingleS0und -- the screen object at PanelScreen_VtableTable
;          entry 0x74, i.e. SCREEN ID 0x54 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58C53, whose first
;          record reads "LOAD SINGLE SOUND".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow1_L0adSingleS0und_Page0:
	link XIZ,0x0000                                      ; FF6D65  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF6D69  9e 08 21
	and BC,0x0080                                        ; FF6D6C  d9 cc 80 00
	jr nz, .LFF6D7E                                      ; FF6D70  6e 0c
	ld (UI_Request_Hi:16), 0x10                                 ; FF6D72  f1 71 20 00 10
	ld (UI_ScreenPage:16), 0x01                                 ; FF6D77  f1 29 22 00 01
	jr .LFF6D99                                          ; FF6D7C  68 1b
.LFF6D7E:
	pushw 0x00                                           ; FF6D7E  0b 00 00
	calr Var7FD6_IsBitClear                                      ; FF6D81  1e b7 07
	popw bc                                              ; FF6D84  49
	cp wa, 0x00:i3                                         ; FF6D85  d8 d8
	jr z, .LFF6D8F                                       ; FF6D87  66 06
	call Disk_CheckSelectedEntrySignature                                      ; FF6D89  1d e3 77 ff
	jr .LFF6D99                                          ; FF6D8D  68 0a
.LFF6D8F:
	ld (UI_Request:16), 0xb3                                 ; FF6D8F  f1 70 20 00 b3
	ld (UI_Request_Hi:16), 0x40                                 ; FF6D94  f1 71 20 00 40
.LFF6D99:
	unlk XIZ                                             ; FF6D99  ee 0d
	ret                                                  ; FF6D9B  0e
; ---------------------------------------------------------------------
; ExitKey_L0adSingleS0und_Pages0_1 -- what Dispatch_FF4049 runs for panel
;          control 0x0F
;
; Reached from: Dispatch_FF4049 entry [15], Dispatch_FF4049 entry [47] (page
;          1, control 0x0F) -- and from no other slot of any 32-entry control
;          table in prom_a. A target reached at two DIFFERENT indices is
;          refused by the script that wrote this.
; Control:  index 0x0F is the EXIT key. The pair position -- which of the two
;          keys -- reaches the handler in the argument the reader forwards;
;          this pass did NOT establish that argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   L0adSingleS0und -- the screen object at PanelScreen_VtableTable
;          entry 0x74, i.e. SCREEN ID 0x54 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 0 draws the list at 0xF58C53, whose first
;          record reads "LOAD SINGLE SOUND".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
ExitKey_L0adSingleS0und_Pages0_1:
	link XIZ,0x0000                                      ; FF6D9C  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF6DA0  9e 08 21
	and BC,0x0080                                        ; FF6DA3  d9 cc 80 00
	jr nz, .LFF6DB3                                      ; FF6DA7  6e 0a
	ld (UI_Request:16), 0x40                                 ; FF6DA9  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF6DAE  f1 71 20 00 80
.LFF6DB3:
	unlk XIZ                                             ; FF6DB3  ee 0d
	ret                                                  ; FF6DB5  0e
T_F423EC_Nop:
	ret                                                  ; FF6DB6  0e
; ---------------------------------------------------------------------
; PageDispatch_L0adSingleC0mbination -- run ScreenEnterPages_L0adSingleC0mbination's entry for the
;          CURRENT PAGE
;
; ★ NOT a panel-control table.  This reader indexes with the page
;          byte (0x2229) ALONE and never reads an argument, so its
;          2 entries are pages of one screen and not buttons.
; Evidence: `cp (0x2229),0x02` at 0xFF6DB7 is the bound, the index is
;          `(0x2229) * 4` (`m_mul MB16,0x2229,3` -- the operand is
;          width-1), and `add XBC,0x00FF4149` at 0xFF6DC6 names the table.
;          The entry is CALLED: a return address is pushed before
;          `jp (XBC)`.
; Screen:   L0adSingleC0mbination -- the screen object at
;          PanelScreen_VtableTable entry 0x73, i.e. SCREEN ID 0x53 through
;          PanelScreen_VtableTable_ViewB names this reader as its ENTER
;          method, and its BUTTON method is that screen's control table.
; Was `sub_FF6DB7`, named by notes/prom_a_naming_wave8_apply.py.
; ---------------------------------------------------------------------
PageDispatch_L0adSingleC0mbination:
	cp	(UI_ScreenPage:16), 0x02                            ; FF6DB7  c1 29 22 3f 02
	jr nc, .LFF6DD6                                      ; FF6DBC  6f 18
	ld c, 0x04:opc                                          ; FF6DBE  23 04
	mul	bc, (UI_ScreenPage:16)                              ; FF6DC0  c1 29 22 43
	extz XBC                                             ; FF6DC4  e9 12
	add XBC,ScreenEnterPages_L0adSingleC0mbination                              ; FF6DC6  e9 c8 49 41 ff 00
	ld XBC,(XBC)                                         ; FF6DCC  a1 21
	lda xiy, (.LFF6DD6:24)                               ; FF6DCE  f2 d6 6d ff 35
	push XIY                                             ; FF6DD3  3d
	jp (xbc)                                             ; FF6DD4  b1 d8
.LFF6DD6:
	ret                                                  ; FF6DD6  0e
; ScreenEnter_L0adSingleC0mbination_Page0: ScreenEnterPages_L0adSingleC0mbination[0] -- what PageDispatch_L0adSingleC0mbination, the ENTER method of the L0adSingleC0mbination screen, runs
;   when UI_ScreenPage is 0 (notes/prom_a_page_enter_names.py).
ScreenEnter_L0adSingleC0mbination_Page0:   ; entry: named by 1 `.long` operand, first at 0xFF4149
	push XIX                                             ; FF6DD7  3c
	lda xix, (DisplayList_RunOnLayer_SaveRegs:24)                             ; FF6DD8  f2 d3 75 ff 34
	ld (0x21fa:16), 0x00                                 ; FF6DDD  f1 fa 21 00 00
	ld c, (UI_ScreenLatch:16)                                   ; FF6DE2  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FF6DE6  c1 7b 20 f3
	jr z, .LFF6E0A                                       ; FF6DEA  66 1e
	call T_Playback_StopAllAndIgnoreMidiStart                                        ; FF6DEC  1d 94 25 f4
	ld (UI_ScreenItem:16), 0x00                                 ; FF6DF0  f1 20 27 00 00
	call T_DiskLoadScreen_MountAndScanDirectory                                        ; FF6DF5  1d b4 25 f4
	calr UI_StatusCode_Is0or2or4                                      ; FF6DF9  1e a0 07
	cp wa, 0x00:i3                                         ; FF6DFC  d8 d8
	jr Z,.LFF6E0A                                        ; FF6DFE  66 0a
	ld (UI_Request:16), 0x40                                 ; FF6E00  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF6E05  f1 71 20 00 80
.LFF6E0A:
	call T_CallbackQueue_ResetAndRestartTask2            ; FF6E0A  1d 80 2e f4
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF6E0E  1d 04 76 ff
	pushw 0x00                                           ; FF6E12  0b 00 00
	lda xbc, (ScreenEnter_L0adSingleC0mbination_Page0_DL:24)                              ; FF6E15  f2 c9 90 f5 31
	push XBC                                             ; FF6E1A  39
	lda xwa, (DL_LoadSingleCombinationDiskGr0upSingleUser1FileBankUser1C0mbi:24) ; FF6E1B  f2 55 8f f5 30
	push XWA                                             ; FF6E20  38
	lda xiy, (.LFF6E29:24)                               ; FF6E21  f2 29 6e ff 35
	push XIY                                             ; FF6E26  3d
	jp (xix)                                             ; FF6E27  b4 d8
.LFF6E29:
	pushw 0x00                                           ; FF6E29  0b 00 00
	lda xbc, (DL_F590F1:24)                              ; FF6E2C  f2 f1 90 f5 31
	push XBC                                             ; FF6E31  39
	lda xwa, (DL_F590E7:24)                              ; FF6E32  f2 e7 90 f5 30
	push XWA                                             ; FF6E37  38
	lda xiy, (.LFF6E40:24)                               ; FF6E38  f2 40 6e ff 35
	push XIY                                             ; FF6E3D  3d
	jp (xix)                                             ; FF6E3E  b4 d8
.LFF6E40:
	pushw 0x02                                           ; FF6E40  0b 02 00
	lda xbc, (DL_F590DD:24)                              ; FF6E43  f2 dd 90 f5 31
	push XBC                                             ; FF6E48  39
	lda xwa, (ScreenEnter_L0adSingleC0mbination_Page0_DL:24)                              ; FF6E49  f2 c9 90 f5 30
	push XWA                                             ; FF6E4E  38
	lda xiy, (.LFF6E57:24)                               ; FF6E4F  f2 57 6e ff 35
	push XIY                                             ; FF6E54  3d
	jp (xix)                                             ; FF6E55  b4 d8
.LFF6E57:
	calr L0adSingleC0mbination_DrawGroupName                                      ; FF6E57  1e 03 04
	calr L0adSingleC0mbination_DrawGroupCombinations                                      ; FF6E5A  1e 3c 05
	push 0x00                                            ; FF6E5D  09 00
	push	(0x2735:16)                                  ; FF6E5F  c1 35 27 04
	calr L0adSingle_DrawBankAndNumber                                      ; FF6E63  1e d0 05
	call Disk_FormatSelectedEntry_SaveRegs                                      ; FF6E66  1d 76 77 ff
	lda xbc, (0xf5911e:24)                               ; FF6E6A  f2 1e 91 f5 31
	push XBC                                             ; FF6E6F  39
	lda xwa, (DL_F5910F:24)                              ; FF6E70  f2 0f 91 f5 30
	push XWA                                             ; FF6E75  38
	call T_DisplayListB_Run_Stack                        ; FF6E76  1d 04 2e f4
	lda xbc, (DL_F591A6:24)                              ; FF6E7A  f2 a6 91 f5 31
	push XBC                                             ; FF6E7F  39
	call DLB_Array8_SaveRegs                                      ; FF6E80  1d 3f 76 ff
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF6E84  f1 40 25 00 00
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF6E89  1d 15 76 ff
	add XSP,0x0000002c                                   ; FF6E8D  ef c8 2c 00 00 00
	pop XIX                                              ; FF6E93  5c
	ret                                                  ; FF6E94  0e
; ScreenEnter_L0adSingleC0mbination_Page1: ScreenEnterPages_L0adSingleC0mbination[1] -- what PageDispatch_L0adSingleC0mbination, the ENTER method of the L0adSingleC0mbination screen, runs
;   when UI_ScreenPage is 1 (notes/prom_a_page_enter_names.py).
ScreenEnter_L0adSingleC0mbination_Page1:   ; entry: named by 1 `.long` operand, first at 0xFF414D
	call T_CallbackQueue_ResetAndRestartTask2            ; FF6E95  1d 80 2e f4
	call LCD_BlankAndSetPanel3Layer_SaveRegs                                      ; FF6E99  1d 04 76 ff
	ld (0x2736:16), 0x00                                 ; FF6E9D  f1 36 27 00 00
	ld (0x2728:16), 0x00                                 ; FF6EA2  f1 28 27 00 00
	pushw 0x00                                           ; FF6EA7  0b 00 00
	lda xbc, (DL_LoadSingleCombinationDiskGr0upSingleUser1FileBankUser1C0mbi:24) ; FF6EAA  f2 55 8f f5 31
	push XBC                                             ; FF6EAF  39
	lda xwa, (DL_LoadSingleCombinationDiskGr0upSingleUser1FileBankUser1S0und:24) ; FF6EB0  f2 04 8e f5 30
	push XWA                                             ; FF6EB5  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF6EB6  1d d3 75 ff
	pushw 0x00                                           ; FF6EBA  0b 00 00
	lda xbc, (DL_F590E7:24)                              ; FF6EBD  f2 e7 90 f5 31
	push XBC                                             ; FF6EC2  39
	lda xwa, (DL_F590DD:24)                              ; FF6EC3  f2 dd 90 f5 30
	push XWA                                             ; FF6EC8  38
	call DisplayList_RunOnLayer_SaveRegs                                      ; FF6EC9  1d d3 75 ff
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF6ECD  f1 40 25 00 00
	push 0x00                                            ; FF6ED2  09 00
	push	(0x273a:16)                                  ; FF6ED4  c1 3a 27 04
	calr L0adSingleC0mbination_DrawGroupList                                      ; FF6ED8  1e 58 04
	call Disk_FormatSelectedEntry_SaveRegs                                      ; FF6EDB  1d 76 77 ff
	ld c, (0x2727:16)                                   ; FF6EDF  c1 27 27 23
	inc 1,C                                              ; FF6EE3  cb 61
	ld (0x2730:16), c                                   ; FF6EE5  f1 30 27 43
	lda xbc, (DLText_F59128:24)                          ; FF6EE9  f2 28 91 f5 31
	push XBC                                             ; FF6EEE  39
	lda xwa, (DL_F5910F:24)                              ; FF6EEF  f2 0f 91 f5 30
	push XWA                                             ; FF6EF4  38
	call T_DisplayListB_Run_Stack                        ; FF6EF5  1d 04 2e f4
	lda xbc, (DL_F59150:24)                              ; FF6EF9  f2 50 91 f5 31
	push XBC                                             ; FF6EFE  39
	call DLB_Array8_SaveRegs                                      ; FF6EFF  1d 3f 76 ff
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF6F03  f1 40 25 00 00
	call LCD_ShowAllThreeLayers_SaveRegs                                      ; FF6F08  1d 15 76 ff
	add XSP,0x00000022                                   ; FF6F0C  ef c8 22 00 00 00
	ret                                                  ; FF6F12  0e
; ---------------------------------------------------------------------
; ScreenLeave_L0adSingleC0mbination -- the LEAVE method of the screen object
;          at PanelScreen_VtableTable entry 0x73, i.e. SCREEN ID 0x53 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0x73 -> the screen object at
;          0xF4241C, whose +4 slot is `jp 0xFF6F13`, and from no other live
;          screen object's two callable slots.
; Evidence: the +4 offset is PanelScreen_VtableTable's own (its header's
;          checks V1-V6): +0 ENTER is called by PanelScreen_CallEnter_A/B, +4
;          LEAVE by PanelScreen_CallLeave_A/B with the id that just STOPPED
;          being current, +8 BUTTON by PanelButton_Route (0xF8621E).
; Screen:   L0adSingleC0mbination -- inherited from the +0 ENTER label
;          PageDispatch_L0adSingleC0mbination, not from any text this pass
;          read.
; Was `sub_FF6F13`.
; ---------------------------------------------------------------------
ScreenLeave_L0adSingleC0mbination:
	call DiskScreen_LeaveOnScreenChange                                      ; FF6F13  1d 6c 79 ff
	call T_Disk_PortA3_Release_Call_Call                                        ; FF6F17  1d 90 25 f4
	ld (0x21fa:16), 0x00                                 ; FF6F1B  f1 fa 21 00 00
	ret                                                  ; FF6F20  0e
; ---------------------------------------------------------------------
; PanelButtonDispatch_L0adSingleC0mbination -- run Dispatch_FF4151's handler
;          for one PANEL CONTROL
;
; Inputs:   (XIZ+0x08) = the 5-bit panel control index; (XIZ+0x0A) =
;          the argument this reader forwards to the handler.
; Evidence: the index is `((0x2229) << 5) + H` -- the page byte
;          times the 32-entry row length, plus the control --
;          and `add XBC,0x00FF4151` at 0xFF6F3A names the table.
; ⚠ No explicit `cp H,0x20` here, unlike its single-row
;          siblings: H arrives already masked to five bits.
;          The handler is CALLED, not jumped to: the reader pushes
;          a return address before `jp (XBC)`.
; Control legend: notes/FINDINGS-prom_a-panel-control-map.md, and
;          `python3 notes/prom_a_panel_control_map.py --map`.
; Screen:   L0adSingleC0mbination -- the screen object at
;          PanelScreen_VtableTable entry 0x73, i.e. SCREEN ID 0x53 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 1 draws the list at 0xF58F55, whose first
;          record reads "LOAD SINGLE COMBINATION".
; Was `sub_FF6F21`, named by notes/prom_a_naming_wave8_apply.py.
; ---------------------------------------------------------------------
PanelButtonDispatch_L0adSingleC0mbination:
	link XIZ,0x0000                                      ; FF6F21  ee 0c 00 00
	pushw hl                                             ; FF6F25  2b
	ld H,(XIZ+0x08)                                      ; FF6F26  8e 08 26
	pushw	(xiz+10)                                     ; FF6F29  9e 0a 04
	ld c, (UI_ScreenPage:16)                                   ; FF6F2C  c1 29 22 23
	sll c, 0x05                                          ; FF6F30  cb ee 05
	add C,H                                              ; FF6F33  ce 83
	mul C,0x04                                           ; FF6F35  cb 08 04
	extz XBC                                             ; FF6F38  e9 12
	add XBC,Dispatch_FF4151                              ; FF6F3A  e9 c8 51 41 ff 00
	ld XBC,(XBC)                                         ; FF6F40  a1 21
	lda xiy, (.LFF6F4A:24)                               ; FF6F42  f2 4a 6f ff 35
	push XIY                                             ; FF6F47  3d
	jp (xbc)                                             ; FF6F48  b1 d8
.LFF6F4A:
	popw bc                                              ; FF6F4A  49
	popw hl                                              ; FF6F4B  4b
	unlk XIZ                                             ; FF6F4C  ee 0d
	ret                                                  ; FF6F4E  0e
; ---------------------------------------------------------------------
; LcdKeyRow1_L0adSingleC0mbination_Page1 -- what Dispatch_FF4151 runs for
;          panel control 0x08
;
; Reached from: Dispatch_FF4151 entry [40] (page 1, control 0x08) -- and from
;          no other slot of any 32-entry control table in prom_a. A target
;          reached at two DIFFERENT indices is refused by the script that
;          wrote this.
; Control:  index 0x08 is the LCD row 1 button pair -- the left-hand and
;          right-hand buttons of the display's TOP row. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   L0adSingleC0mbination -- the screen object at
;          PanelScreen_VtableTable entry 0x73, i.e. SCREEN ID 0x53 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 1 draws the list at 0xF58F55, whose first
;          record reads "LOAD SINGLE COMBINATION".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow1_L0adSingleC0mbination_Page1:
	link XIZ,0x0000                                      ; FF6F4F  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF6F53  9e 08 21
	and BC,0x0080                                        ; FF6F56  d9 cc 80 00
	jr nz, .LFF6F68                                      ; FF6F5A  6e 0c
	ld (UI_Request_Hi:16), 0x10                                 ; FF6F5C  f1 71 20 00 10
	ld (UI_ScreenPage:16), 0x00                                 ; FF6F61  f1 29 22 00 00
	jr .LFF6F83                                          ; FF6F66  68 1b
.LFF6F68:
	pushw 0x01                                           ; FF6F68  0b 01 00
	calr Var7FD6_IsBitClear                                      ; FF6F6B  1e cd 05
	popw bc                                              ; FF6F6E  49
	cp wa, 0x00:i3                                         ; FF6F6F  d8 d8
	jr z, .LFF6F79                                       ; FF6F71  66 06
	call Disk_CheckSelectedEntrySignature                                      ; FF6F73  1d e3 77 ff
	jr .LFF6F83                                          ; FF6F77  68 0a
.LFF6F79:
	ld (UI_Request:16), 0xb3                                 ; FF6F79  f1 70 20 00 b3
	ld (UI_Request_Hi:16), 0x40                                 ; FF6F7E  f1 71 20 00 40
.LFF6F83:
	unlk XIZ                                             ; FF6F83  ee 0d
	ret                                                  ; FF6F85  0e
; SoftKeyCols3_4_L0adSingleC0mbination_Page0: slots 2 and 3 of L0adSingleC0mbination page 0: the same step of (0x2735) within 0..0x7F, then
;   L0adSingle_DrawBankAndNumber((0x2735)).
SoftKeyCols3_4_L0adSingleC0mbination_Page0:   ; entry: named by 4 `.long` operands, first at 0xFF4159
	link XIZ,0x0000                                      ; FF6F86  ee 0c 00 00
	push XIX                                             ; FF6F8A  3c
	lda xix, (0x2735:16)                                ; FF6F8B  f1 35 27 34
	pushw 0x82                                           ; FF6F8F  0b 82 00
	pushw 0x02                                           ; FF6F92  0b 02 00
	calr PanelDial_SetButtonPair                                      ; FF6F95  1e 92 01
	ld BC,(XIZ+0x08)                                     ; FF6F98  9e 08 21
	and BC,0x0080                                        ; FF6F9B  d9 cc 80 00
	pop XIY                                              ; FF6F9F  5d
	jr z, .LFF6FAC                                       ; FF6FA0  66 0a
	ld C,(XIX)                                           ; FF6FA2  84 23
	cp c, 0x00:i3                                          ; FF6FA4  cb d8
	jr z, .LFF6FB5                                       ; FF6FA6  66 0d
	decm8 0x01, (xix)                                    ; FF6FA8  84 69
	jr .LFF6FB5                                          ; FF6FAA  68 09
.LFF6FAC:
	ld C,(XIX)                                           ; FF6FAC  84 23
	cp C,0x7f                                            ; FF6FAE  cb cf 7f
	jr nc, .LFF6FB5                                      ; FF6FB1  6f 02
	incm8 0x01, (xix)                                    ; FF6FB3  84 61
.LFF6FB5:
	ld C,(XIX)                                           ; FF6FB5  84 23
	pushw bc                                             ; FF6FB7  29
	calr L0adSingle_DrawBankAndNumber                                      ; FF6FB8  1e 7b 04
	popw bc                                              ; FF6FBB  49
	pop XIX                                              ; FF6FBC  5c
	unlk XIZ                                             ; FF6FBD  ee 0d
	ret                                                  ; FF6FBF  0e
; SoftKeyCols7_8_L0adSingleC0mbination_Page0: the same as SoftKeyCols7_8_L0adSingleS0und_Page0 with T_CombiGroup_MaxMemberIndex_ByStack.
SoftKeyCols7_8_L0adSingleC0mbination_Page0:   ; entry: named by 4 `.long` operands, first at 0xFF4169
	link XIZ,0x0000                                      ; FF6FC0  ee 0c 00 00
	pushw hl                                             ; FF6FC4  2b
	push XIX                                             ; FF6FC5  3c
	lda xix, (0x2738:16)                                ; FF6FC6  f1 38 27 34
	ld c, 0x02:opc                                          ; FF6FCA  23 02
	mul	bc, (0x2736:16)                              ; FF6FCC  c1 36 27 43
	extz XBC                                             ; FF6FD0  e9 12
	add XBC,Table_FF4039                                 ; FF6FD2  e9 c8 39 40 ff 00
	ld BC,(XBC)                                          ; FF6FD8  91 21
	pushw bc                                             ; FF6FDA  29
	push 0x00                                            ; FF6FDB  09 00
	push	(0x2737:16)                                  ; FF6FDD  c1 37 27 04
	call T_CombiGroup_MaxMemberIndex_ByStack                                        ; FF6FE1  1d 14 34 f4
	ld H,A                                               ; FF6FE5  c9 8e
	pop XIY                                              ; FF6FE7  5d
	cp A,0xff                                            ; FF6FE8  c9 cf ff
	jr z, .LFF702D                                       ; FF6FEB  66 40
	pushw 0x06                                           ; FF6FED  0b 06 00
	pushw 0x86                                           ; FF6FF0  0b 86 00
	calr PanelDial_SetButtonPair                                      ; FF6FF3  1e 34 01
	lda xbc, (DL_F591B1:24)                              ; FF6FF6  f2 b1 91 f5 31
	push XBC                                             ; FF6FFB  39
	call DLB_Array8_2_OnLayer1_SaveRegs                                      ; FF6FFC  1d 23 76 ff
	ld BC,(XIZ+0x08)                                     ; FF7000  9e 08 21
	and BC,0x0080                                        ; FF7003  d9 cc 80 00
	inc 8,XSP                                            ; FF7007  ef 60
	jr nz, .LFF7015                                      ; FF7009  6e 0a
	ld C,(XIX)                                           ; FF700B  84 23
	cp c, 0x00:i3                                          ; FF700D  cb d8
	jr z, .LFF701D                                       ; FF700F  66 0c
	decm8 0x01, (xix)                                    ; FF7011  84 69
	jr .LFF701D                                          ; FF7013  68 08
.LFF7015:
	ld C,(XIX)                                           ; FF7015  84 23
	cp C,H                                               ; FF7017  ce f3
	jr nc, .LFF701D                                      ; FF7019  6f 02
	incm8 0x01, (xix)                                    ; FF701B  84 61
.LFF701D:
	lda xbc, (DL_F591A6:24)                              ; FF701D  f2 a6 91 f5 31
	push XBC                                             ; FF7022  39
	call DLB_Array8_SaveRegs                                      ; FF7023  1d 3f 76 ff
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF7027  f1 40 25 00 00
	pop XIY                                              ; FF702C  5d
.LFF702D:
	pop XIX                                              ; FF702D  5c
	popw hl                                              ; FF702E  4b
	unlk XIZ                                             ; FF702F  ee 0d
	ret                                                  ; FF7031  0e
; ---------------------------------------------------------------------
; LcdKeyRow1_L0adSingleC0mbination_Page0 -- what Dispatch_FF4151 runs for
;          panel control 0x08
;
; Reached from: Dispatch_FF4151 entry [8] -- and from no other slot of any
;          32-entry control table in prom_a. A target reached at two
;          DIFFERENT indices is refused by the script that wrote this.
; Control:  index 0x08 is the LCD row 1 button pair -- the left-hand and
;          right-hand buttons of the display's TOP row. The pair position --
;          which of the two keys -- reaches the handler in the argument the
;          reader forwards; this pass did NOT establish that argument's bit
;          layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   L0adSingleC0mbination -- the screen object at
;          PanelScreen_VtableTable entry 0x73, i.e. SCREEN ID 0x53 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 1 draws the list at 0xF58F55, whose first
;          record reads "LOAD SINGLE COMBINATION".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
LcdKeyRow1_L0adSingleC0mbination_Page0:
	link XIZ,0x0000                                      ; FF7032  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF7036  9e 08 21
	and BC,0x0080                                        ; FF7039  d9 cc 80 00
	jr nz, .LFF704B                                      ; FF703D  6e 0c
	ld (UI_Request_Hi:16), 0x10                                 ; FF703F  f1 71 20 00 10
	ld (UI_ScreenPage:16), 0x01                                 ; FF7044  f1 29 22 00 01
	jr .LFF7066                                          ; FF7049  68 1b
.LFF704B:
	pushw 0x01                                           ; FF704B  0b 01 00
	calr Var7FD6_IsBitClear                                      ; FF704E  1e ea 04
	popw bc                                              ; FF7051  49
	cp wa, 0x00:i3                                         ; FF7052  d8 d8
	jr z, .LFF705C                                       ; FF7054  66 06
	call Disk_CheckSelectedEntrySignature                                      ; FF7056  1d e3 77 ff
	jr .LFF7066                                          ; FF705A  68 0a
.LFF705C:
	ld (UI_Request:16), 0xb3                                 ; FF705C  f1 70 20 00 b3
	ld (UI_Request_Hi:16), 0x40                                 ; FF7061  f1 71 20 00 40
.LFF7066:
	unlk XIZ                                             ; FF7066  ee 0d
	ret                                                  ; FF7068  0e
; ---------------------------------------------------------------------
; ExitKey_L0adSingleC0mbination_Pages0_1 -- what Dispatch_FF4151 runs for
;          panel control 0x0F
;
; Reached from: Dispatch_FF4151 entry [15], Dispatch_FF4151 entry [47] (page
;          1, control 0x0F) -- and from no other slot of any 32-entry control
;          table in prom_a. A target reached at two DIFFERENT indices is
;          refused by the script that wrote this.
; Control:  index 0x0F is the EXIT key. The pair position -- which of the two
;          keys -- reaches the handler in the argument the reader forwards;
;          this pass did NOT establish that argument's bit layout.
; Evidence: the code->control map is rounds 9-12's, re-derived from the ROM
;          by notes/prom_a_panel_control_map.py, which agrees with prom_b's
;          SLOT_CONTROL slot for slot; what is new here is only that THIS
;          module's tables are tied to it. See
;          notes/FINDINGS-prom_a-panel-control-map.md.
; Screen:   L0adSingleC0mbination -- the screen object at
;          PanelScreen_VtableTable entry 0x73, i.e. SCREEN ID 0x53 through
;          PanelScreen_VtableTable_ViewB names this reader as its BUTTON
;          method, and its page 1 draws the list at 0xF58F55, whose first
;          record reads "LOAD SINGLE COMBINATION".
; Unknown:  what this screen does with the button.
; ---------------------------------------------------------------------
ExitKey_L0adSingleC0mbination_Pages0_1:
	link XIZ,0x0000                                      ; FF7069  ee 0c 00 00
	ld BC,(XIZ+0x08)                                     ; FF706D  9e 08 21
	and BC,0x0080                                        ; FF7070  d9 cc 80 00
	jr nz, .LFF7080                                      ; FF7074  6e 0a
	ld (UI_Request:16), 0x40                                 ; FF7076  f1 70 20 00 40
	ld (UI_Request_Hi:16), 0x80                                 ; FF707B  f1 71 20 00 80
.LFF7080:
	unlk XIZ                                             ; FF7080  ee 0d
	ret                                                  ; FF7082  0e
T_F42428_Nop:
	ret                                                  ; FF7083  0e
; DiskEntry_CopySelectedToFileName: Copies the 16 bytes of directory-listing entry Disk_SelectedEntry
;   (DiskEntry_GetPointer: 0x60A480 + 16n) to Disk_FileName. DISK LOAD's row 1 key runs it before the load; DISK SAVE
;   page 5's row 3 key runs it around its action with Disk_FileName saved and restored. Basis: callers + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave3_i.json)
DiskEntry_CopySelectedToFileName:
	link XIZ,0xfffc                                      ; FF7084  ee 0c fc ff
	pushw hl                                             ; FF7088  2b
	push XIX                                             ; FF7089  3c
	push 0x00                                            ; FF708A  09 00
	push	(Disk_SelectedEntry:16)                                  ; FF708C  c1 24 27 04
	calr DiskEntry_GetPointer                                      ; FF7090  1e 7c d8
	ld (xiz-4), xiy                                      ; FF7093  be fc 65
	lda xix, (Disk_FileName:16)                                ; FF7096  f1 c8 21 34
	ld h, 0x10:opc                                          ; FF709A  26 10
	popw bc                                              ; FF709C  49
.LFF709D:
	ld xbc, (xiz-4)                                      ; FF709D  ae fc 21
	ld A,(XBC)                                           ; FF70A0  81 21
	ld (XIX),A                                           ; FF70A2  b4 41
	sub XBC,XBC                                          ; FF70A4  e9 a1
	inc 1,XBC                                            ; FF70A6  e9 61
	add (xiz-4), xbc                                     ; FF70A8  ae fc 89
	add XIX,XBC                                          ; FF70AB  e9 84
	sub H,C                                              ; FF70AD  cb a6
	jr nz, .LFF709D                                      ; FF70AF  6e ec
	pop XIX                                              ; FF70B1  5c
	popw hl                                              ; FF70B2  4b
	unlk XIZ                                             ; FF70B3  ee 0d
	ret                                                  ; FF70B5  0e
; MidiFilePlay_SnapshotRecordBytes: Copies the byte at each of PtrTable_FF4251's 16 pointers (field +0x0D of the
;   64-byte records at 0x76A2) into the shadow 0x26B2..0x26C1. Run on entry to MIDI FILE DIRECT PLAY and SEQUENCER
;   MEDLEY. Its pair PartRecords_RestoreShadowedField, run by ScreenLeave_MidiFileDirectPlay and SequencerMedley_OnLeave, writes changed
;   bytes back and posts each through T_PendingEventQueue_AppendStackArgs as (byte at pointer-15, 0x0D, value, 0x0F).
;   Basis: callers + body + the restore pair. (notes/naming-pilot-2026-10-06/proposals_wave3_j.json)
MidiFilePlay_SnapshotRecordBytes:
	push XHL                                             ; FF70B6  3b
	push XIX                                             ; FF70B7  3c
	ldw hl, 0x00                                         ; FF70B8  33 00 00
	lda xix, (PtrTable_FF4251:24)                        ; FF70BB  f2 51 42 ff 34
.LFF70C0:
	ld XBC,(XIX)                                         ; FF70C0  a4 21
	ld A,(XBC)                                           ; FF70C2  81 21
	extz XHL                                             ; FF70C4  eb 12
	ld (XHL+0x26b2),A                                    ; FF70C6  f3 ed b2 26 41
	inc 4,XIX                                            ; FF70CB  ec 64
	inc 1,HL                                             ; FF70CD  db 61
	cp HL,0x0010                                         ; FF70CF  db cf 10 00
	jr lt, .LFF70C0                                      ; FF70D3  61 eb
	pop XIX                                              ; FF70D5  5c
	pop XHL                                              ; FF70D6  5b
	ret                                                  ; FF70D7  0e
; PartRecords_RestoreShadowedField: For the 16 part-record bytes PtrTable_FF4251 names (+0x0D of the 64-byte records
;   at 0x76A2..): where one differs from the shadow 0x26B2[i] taken on entry (MidiFilePlay_SnapshotRecordBytes), writes it back and posts
;   {id, 0x0D, value, 0x0F}. Run on leaving MIDI FILE DIRECT PLAY and the SEQUENCER MEDLEY, both of which snapshot on
;   entry. Basis: callers + body + sibling. (notes/naming-pilot-2026-10-06/proposals_wave3_g.json)
PartRecords_RestoreShadowedField:
	link XIZ,0xfff8                                      ; FF70D8  ee 0c f8 ff
	pushw hl                                             ; FF70DC  2b
	push XDE                                             ; FF70DD  3a
	push XIX                                             ; FF70DE  3c
	ldw de, 0x00                                         ; FF70DF  32 00 00
	lda xix, (PtrTable_FF4251:24)                        ; FF70E2  f2 51 42 ff 34
.LFF70E7:
	ld XBC,(XIX)                                         ; FF70E7  a4 21
	ld (xiz-4), xbc                                      ; FF70E9  be fc 61
	ld L,(XBC)                                           ; FF70EC  81 27
	extz XDE                                             ; FF70EE  ea 12
	ld H,(XDE+0x26b2)                                    ; FF70F0  c3 e9 b2 26 26
	cp L,H                                               ; FF70F5  ce f7
	jr z, .LFF711A                                       ; FF70F7  66 21
	ld (XBC),H                                           ; FF70F9  b1 46
	pushw 0x0f                                           ; FF70FB  0b 0f 00
	ld XBC,(XIX)                                         ; FF70FE  a4 21
	ld (xiz-8), xbc                                      ; FF7100  be f8 61
	ld A,(XBC)                                           ; FF7103  81 21
	extz WA                                              ; FF7105  d8 12
	pushw wa                                             ; FF7107  28
	pushw 0x0d                                           ; FF7108  0b 0d 00
	dec 8,XBC                                            ; FF710B  e9 68
	dec 7,XBC                                            ; FF710D  e9 6f
	ld A,(XBC)                                           ; FF710F  81 21
	extz WA                                              ; FF7111  d8 12
	pushw wa                                             ; FF7113  28
	call T_PendingEventQueue_AppendStackArgs                                        ; FF7114  1d 18 1b f4
	inc 8,XSP                                            ; FF7118  ef 60
.LFF711A:
	inc 4,XIX                                            ; FF711A  ec 64
	inc 1,DE                                             ; FF711C  da 61
	cp DE,0x0010                                         ; FF711E  da cf 10 00
	jr lt, .LFF70E7                                      ; FF7122  61 c3
	pop XIX                                              ; FF7124  5c
	pop XDE                                              ; FF7125  5a
	popw hl                                              ; FF7126  4b
	unlk XIZ                                             ; FF7127  ee 0d
	ret                                                  ; FF7129  0e
; PanelDial_SetButtonPair(up, down): UI_RequestBits |= 0x09 (dial acts as buttons, redraw), PanelDial_UpButton = up,
;   PanelDial_DownButton = down, (0x2666) = (0x266A) = 0xFFFF.  The explicit-pair form of PanelDial_ActAsButton.
PanelDial_SetButtonPair:
	link XIZ,0x0000                                      ; FF712A  ee 0c 00 00
	push XIX                                             ; FF712E  3c
	or	(UI_RequestBits:16), 0x09                            ; FF712F  c1 75 20 3e 09
	ld C,(XIZ+0x0a)                                      ; FF7134  8e 0a 23
	ld (PanelDial_DownButton:16), c                                   ; FF7137  f1 9b 20 43
	ld A,(XIZ+0x08)                                      ; FF713B  8e 08 21
	ld (PanelDial_UpButton:16), a                                   ; FF713E  f1 9c 20 41
	ld XIX,0x0000ffff                                    ; FF7142  44 ff ff 00 00
	ld (0x266a:16), xix                                 ; FF7147  f1 6a 26 64
	ld (0x2666:16), xix                                 ; FF714B  f1 66 26 64
	pop XIX                                              ; FF714F  5c
	unlk XIZ                                             ; FF7150  ee 0d
	ret                                                  ; FF7152  0e
; ---------------------------------------------------------------------
; L0adSingleS0und_DrawGroupList -- loads a pointer straight at ROM TEXT.  NOT NAMED.
;
; Called from: prom_a PageDispatch_L0adSingleS0und (`calr`) at 0xFF688E
;          prom_a PanelButtonDispatch_L0adSingleS0und (`calr`) at 0xFF696C
;          prom_a PanelButtonDispatch_L0adSingleS0und (`calr`) at 0xFF6A63
;          prom_a PanelButtonDispatch_L0adSingleS0und (`calr`) at 0xFF6AD3
;
;     0xFF71A5 loads 0xFF4291, where the ROM reads:
;        "                U1 -U2 -UD1-UD2-"
; Evidence: the immediate at the cited instruction, and the bytes
;          at that address in original_ROMs/, read as printable
;          ASCII until the first non-printable byte.
; NOT NAMED because the text says what the routine READS, not what it DOES
;          with it; a name taken from it would claim a role nothing here
;          establishes. The string is recorded so the next round starts
;          from evidence instead of a search.
; Recorded by notes/prom_a_understanding_round7.py --apply-strings.
; ---------------------------------------------------------------------
; L0adSingleS0und_DrawGroupList: Draws the page's 8-row list of sound-group names of bank Table_FF4039[(0x2736)],
;   starting at group arg (callers pass (0x273A)), rows 0x0D36 + n*0x230; when Var2728_Is2or3, only group 0's name and
;   seven blank rows. Shared by the L0AD SINGLE SOUND page-1 enter and soft-key handlers. Basis: callers + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave2_e.json)
L0adSingleS0und_DrawGroupList:
	link XIZ,0xfffe                                      ; FF7153  ee 0c fe ff
	pushw hl                                             ; FF7157  2b
	pushw de                                             ; FF7158  2a
	pushw ix                                             ; FF7159  2c
	calr Var2728_Is2or3                                      ; FF715A  1e c8 03
	cp wa, 0x00:i3                                         ; FF715D  d8 d8
	jr z, .LFF71C5                                       ; FF715F  66 64
	lda xbc, (0x2940:16)                                ; FF7161  f1 40 29 31
	push XBC                                             ; FF7165  39
	ld a, 0x02:opc                                          ; FF7166  21 02
	mul	wa, (0x2736:16)                              ; FF7168  c1 36 27 41
	extz XWA                                             ; FF716C  e8 12
	add XWA,Table_FF4039                                 ; FF716E  e8 c8 39 40 ff 00
	ld WA,(XWA)                                          ; FF7174  90 20
	pushw wa                                             ; FF7176  28
	pushw 0x00                                           ; FF7177  0b 00 00
	call T_SoundGroupName_CopyToBuffer                                        ; FF717A  1d 04 34 f4
	pushw 0x06                                           ; FF717E  0b 06 00
	pushw 0x10                                           ; FF7181  0b 10 00
	pushw 0x0d36                                         ; FF7184  0b 36 0d
	lda xbc, (0x2940:16)                                ; FF7187  f1 40 29 31
	push XBC                                             ; FF718B  39
	call LCD_SwiTextCall_SaveRegs                                      ; FF718C  1d 95 78 ff
	ldw hl, 0x0230                                       ; FF7190  33 30 02
	ldw de, 0x0f66                                       ; FF7193  32 66 0f
	add XSP,0x00000012                                   ; FF7196  ef c8 12 00 00 00
.LFF719C:
	pushw 0x06                                           ; FF719C  0b 06 00
	pushw 0x10                                           ; FF719F  0b 10 00
	ld IX,DE                                             ; FF71A2  da 8c
	pushw ix                                             ; FF71A4  2c
	lda xbc, (Text_FF4291:24)                            ; FF71A5  f2 91 42 ff 31
	push XBC                                             ; FF71AA  39
	call LCD_SwiTextCall_SaveRegs                                      ; FF71AB  1d 95 78 ff
	add HL,0x0230                                        ; FF71AF  db c8 30 02
	ld DE,IX                                             ; FF71B3  dc 8a
	add DE,0x0230                                        ; FF71B5  da c8 30 02
	inc 8,XSP                                            ; FF71B9  ef 60
	inc 2,XSP                                            ; FF71BB  ef 62
	cp HL,0x1180                                         ; FF71BD  db cf 80 11
	jr lt, .LFF719C                                      ; FF71C1  61 d9
	jr .LFF721E                                          ; FF71C3  68 59
.LFF71C5:
	ldw de, 0x00                                         ; FF71C5  32 00 00
	ldw hl, 0x00                                         ; FF71C8  33 00 00
	ldw ix, 0x0d36                                       ; FF71CB  34 36 0d
.LFF71CE:
	lda xbc, (0x2940:16)                                ; FF71CE  f1 40 29 31
	push XBC                                             ; FF71D2  39
	ld a, 0x02:opc                                          ; FF71D3  21 02
	mul	wa, (0x2736:16)                              ; FF71D5  c1 36 27 41
	extz XWA                                             ; FF71D9  e8 12
	add XWA,Table_FF4039                                 ; FF71DB  e8 c8 39 40 ff 00
	ld WA,(XWA)                                          ; FF71E1  90 20
	pushw wa                                             ; FF71E3  28
	ld WA,(XIZ+0x08)                                     ; FF71E4  9e 08 20
	extz WA                                              ; FF71E7  d8 12
	add WA,DE                                            ; FF71E9  da 80
	pushw wa                                             ; FF71EB  28
	call T_SoundGroupName_CopyToBuffer                                        ; FF71EC  1d 04 34 f4
	pushw 0x06                                           ; FF71F0  0b 06 00
	pushw 0x10                                           ; FF71F3  0b 10 00
	ld (xiz-2), ix                                       ; FF71F6  be fe 54
	pushw	(xiz-2)                                      ; FF71F9  9e fe 04
	lda xbc, (0x2940:16)                                ; FF71FC  f1 40 29 31
	push XBC                                             ; FF7200  39
	call LCD_SwiTextCall_SaveRegs                                      ; FF7201  1d 95 78 ff
	add HL,0x0230                                        ; FF7205  db c8 30 02
	ld ix, (xiz-2)                                       ; FF7209  9e fe 24
	add IX,0x0230                                        ; FF720C  dc c8 30 02
	inc 1,DE                                             ; FF7210  da 61
	add XSP,0x00000012                                   ; FF7212  ef c8 12 00 00 00
	cp HL,0x1180                                         ; FF7218  db cf 80 11
	jr lt, .LFF71CE                                      ; FF721C  61 b0
.LFF721E:
	popw ix                                              ; FF721E  4c
	popw de                                              ; FF721F  4a
	popw hl                                              ; FF7220  4b
	unlk XIZ                                             ; FF7221  ee 0d
	ret                                                  ; FF7223  0e
; L0adSingleS0und_DrawGroupName: T_SoundGroupName_CopyToBuffer(bank Table_FF4039[(0x2736)], group (0x2737)) into 0x2940, drawn at 0x0C1E.
L0adSingleS0und_DrawGroupName:
	lda xbc, (0x2940:16)                                ; FF7224  f1 40 29 31
	push XBC                                             ; FF7228  39
	ld a, 0x02:opc                                          ; FF7229  21 02
	mul	wa, (0x2736:16)                              ; FF722B  c1 36 27 41
	extz XWA                                             ; FF722F  e8 12
	add XWA,Table_FF4039                                 ; FF7231  e8 c8 39 40 ff 00
	ld WA,(XWA)                                          ; FF7237  90 20
	pushw wa                                             ; FF7239  28
	push 0x00                                            ; FF723A  09 00
	push	(0x2737:16)                                  ; FF723C  c1 37 27 04
	call T_SoundGroupName_CopyToBuffer                                        ; FF7240  1d 04 34 f4
	pushw 0x06                                           ; FF7244  0b 06 00
	pushw 0x10                                           ; FF7247  0b 10 00
	pushw 0x0c1e                                         ; FF724A  0b 1e 0c
	lda xbc, (0x2940:16)                                ; FF724D  f1 40 29 31
	push XBC                                             ; FF7251  39
	call LCD_SwiTextCall_SaveRegs                                      ; FF7252  1d 95 78 ff
	add XSP,0x00000012                                   ; FF7256  ef c8 12 00 00 00
	ret                                                  ; FF725C  0e
; L0adSingleC0mbination_DrawGroupName: the same with T_CombiGroupName_CopyToBuffer.
L0adSingleC0mbination_DrawGroupName:
	lda xbc, (0x2940:16)                                ; FF725D  f1 40 29 31
	push XBC                                             ; FF7261  39
	ld a, 0x02:opc                                          ; FF7262  21 02
	mul	wa, (0x2736:16)                              ; FF7264  c1 36 27 41
	extz XWA                                             ; FF7268  e8 12
	add XWA,Table_FF4039                                 ; FF726A  e8 c8 39 40 ff 00
	ld WA,(XWA)                                          ; FF7270  90 20
	pushw wa                                             ; FF7272  28
	push 0x00                                            ; FF7273  09 00
	push	(0x2737:16)                                  ; FF7275  c1 37 27 04
	call T_CombiGroupName_CopyToBuffer                                        ; FF7279  1d 10 34 f4
	pushw 0x06                                           ; FF727D  0b 06 00
	pushw 0x10                                           ; FF7280  0b 10 00
	pushw 0x0c1e                                         ; FF7283  0b 1e 0c
	lda xbc, (0x2940:16)                                ; FF7286  f1 40 29 31
	push XBC                                             ; FF728A  39
	call LCD_SwiTextCall_SaveRegs                                      ; FF728B  1d 95 78 ff
	add XSP,0x00000012                                   ; FF728F  ef c8 12 00 00 00
	ret                                                  ; FF7295  0e
; ---------------------------------------------------------------------
; L0adSingleS0und_DrawGroupSounds -- loads a pointer straight at ROM TEXT.  NOT NAMED.
;
; Called from: prom_a PageDispatch_L0adSingleS0und (`calr`) at 0xFF67F9
;          prom_a PanelButtonDispatch_L0adSingleS0und (`calr`) at 0xFF6BBF
;          prom_a PanelButtonDispatch_L0adSingleS0und (`calr`) at 0xFF6C96
;          prom_a PanelButtonDispatch_L0adSingleS0und (`calr`) at 0xFF6CDE
;          ... and 1 more
;
;     0xFF72D9 loads 0xFF4291, where the ROM reads:
;        "                U1 -U2 -UD1-UD2-"
; Evidence: the immediate at the cited instruction, and the bytes
;          at that address in original_ROMs/, read as printable
;          ASCII until the first non-printable byte.
; NOT NAMED because the text says what the routine READS, not what it DOES
;          with it; a name taken from it would claim a role nothing here
;          establishes. The string is recorded so the next round starts
;          from evidence instead of a search.
; Recorded by notes/prom_a_understanding_round7.py --apply-strings.
; ---------------------------------------------------------------------
; L0adSingleS0und_DrawGroupSounds: eight lines from 0x0EEE, 0x208 apart: member k's name (T_SoundName_CopyToBuffer, bank Table_FF4039[(0x2736)],
;   group (0x2737)) up to T_SoundGroup_MaxMemberIndex_ByStack, Text_FF4291 after it.
L0adSingleS0und_DrawGroupSounds:
	link XIZ,0xfffe                                      ; FF7296  ee 0c fe ff
	pushw hl                                             ; FF729A  2b
	pushw de                                             ; FF729B  2a
	pushw ix                                             ; FF729C  2c
	ld c, 0x02:opc                                          ; FF729D  23 02
	mul	bc, (0x2736:16)                              ; FF729F  c1 36 27 43
	extz XBC                                             ; FF72A3  e9 12
	add XBC,Table_FF4039                                 ; FF72A5  e9 c8 39 40 ff 00
	ld BC,(XBC)                                          ; FF72AB  91 21
	pushw bc                                             ; FF72AD  29
	push 0x00                                            ; FF72AE  09 00
	push	(0x2737:16)                                  ; FF72B0  c1 37 27 04
	call T_SoundGroup_MaxMemberIndex_ByStack                                        ; FF72B4  1d 08 34 f4
	extz WA                                              ; FF72B8  d8 12
	ld (xiz-2), wa                                       ; FF72BA  be fe 50
	pop XIY                                              ; FF72BD  5d
	cp WA,0x00ff                                         ; FF72BE  d8 cf ff 00
	jr z, .LFF732D                                       ; FF72C2  66 69
	ldw ix, 0x00                                         ; FF72C4  34 00 00
	ldw de, 0x00                                         ; FF72C7  32 00 00
	ldw hl, 0x0eee                                       ; FF72CA  33 ee 0e
.LFF72CD:
	cp	ix, (xiz-2)                                  ; FF72CD  9e fe f4
	jr le, .LFF72E1                                      ; FF72D0  62 0f
	pushw 0x06                                           ; FF72D2  0b 06 00
	pushw 0x10                                           ; FF72D5  0b 10 00
	pushw hl                                             ; FF72D8  2b
	lda xbc, (Text_FF4291:24)                            ; FF72D9  f2 91 42 ff 31
	push XBC                                             ; FF72DE  39
	jr .LFF7315                                          ; FF72DF  68 34
.LFF72E1:
	lda xbc, (0x2940:16)                                ; FF72E1  f1 40 29 31
	push XBC                                             ; FF72E5  39
	ld a, 0x02:opc                                          ; FF72E6  21 02
	mul	wa, (0x2736:16)                              ; FF72E8  c1 36 27 41
	extz XWA                                             ; FF72EC  e8 12
	add XWA,Table_FF4039                                 ; FF72EE  e8 c8 39 40 ff 00
	ld WA,(XWA)                                          ; FF72F4  90 20
	pushw wa                                             ; FF72F6  28
	ld_erpb_rr a, 0xf0                                   ; FF72F7  c7 f0 89   ld A,IXL
	pushw wa                                             ; FF72FA  28
	push 0x00                                            ; FF72FB  09 00
	push	(0x2737:16)                                  ; FF72FD  c1 37 27 04
	call T_SoundName_CopyToBuffer                                        ; FF7301  1d 00 34 f4
	inc 8,XSP                                            ; FF7305  ef 60
	inc 2,XSP                                            ; FF7307  ef 62
	pushw 0x06                                           ; FF7309  0b 06 00
	pushw 0x10                                           ; FF730C  0b 10 00
	pushw hl                                             ; FF730F  2b
	lda xbc, (0x2940:16)                                ; FF7310  f1 40 29 31
	push XBC                                             ; FF7314  39
.LFF7315:
	call LCD_SwiTextCall_SaveRegs                                      ; FF7315  1d 95 78 ff
	add DE,0x0208                                        ; FF7319  da c8 08 02
	add HL,0x0208                                        ; FF731D  db c8 08 02
	inc 1,IX                                             ; FF7321  dc 61
	inc 8,XSP                                            ; FF7323  ef 60
	inc 2,XSP                                            ; FF7325  ef 62
	cp DE,0x1040                                         ; FF7327  da cf 40 10
	jr lt, .LFF72CD                                      ; FF732B  61 a0
.LFF732D:
	popw ix                                              ; FF732D  4c
	popw de                                              ; FF732E  4a
	popw hl                                              ; FF732F  4b
	unlk XIZ                                             ; FF7330  ee 0d
	ret                                                  ; FF7332  0e
; L0adSingleC0mbination_DrawGroupList: Draws the page's 8-row list of combination-group names of bank
;   Table_FF4039[(0x2736)] from group arg (callers pass (0x273A)), rows at 0x0D36 + n*0x230
;   (CombiGroupName_CopyToBuffer, 16 chars). The COMBINATION twin of L0adSingleS0und_DrawGroupList; run on page-1
;   entry and by the shared scroll keys. Basis: callers + body + sibling. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_h.json)
L0adSingleC0mbination_DrawGroupList:
	link XIZ,0xfffe                                      ; FF7333  ee 0c fe ff
	pushw hl                                             ; FF7337  2b
	pushw de                                             ; FF7338  2a
	pushw ix                                             ; FF7339  2c
	ldw ix, 0x00                                         ; FF733A  34 00 00
	ldw hl, 0x00                                         ; FF733D  33 00 00
	ldw de, 0x0d36                                       ; FF7340  32 36 0d
.LFF7343:
	lda xbc, (0x2940:16)                                ; FF7343  f1 40 29 31
	push XBC                                             ; FF7347  39
	ld a, 0x02:opc                                          ; FF7348  21 02
	mul	wa, (0x2736:16)                              ; FF734A  c1 36 27 41
	extz XWA                                             ; FF734E  e8 12
	add XWA,Table_FF4039                                 ; FF7350  e8 c8 39 40 ff 00
	ld WA,(XWA)                                          ; FF7356  90 20
	pushw wa                                             ; FF7358  28
	ld WA,(XIZ+0x08)                                     ; FF7359  9e 08 20
	extz WA                                              ; FF735C  d8 12
	add WA,IX                                            ; FF735E  dc 80
	pushw wa                                             ; FF7360  28
	call T_CombiGroupName_CopyToBuffer                                        ; FF7361  1d 10 34 f4
	pushw 0x06                                           ; FF7365  0b 06 00
	pushw 0x10                                           ; FF7368  0b 10 00
	ld (xiz-2), de                                       ; FF736B  be fe 52
	pushw	(xiz-2)                                      ; FF736E  9e fe 04
	lda xbc, (0x2940:16)                                ; FF7371  f1 40 29 31
	push XBC                                             ; FF7375  39
	call LCD_SwiTextCall_SaveRegs                                      ; FF7376  1d 95 78 ff
	add HL,0x0230                                        ; FF737A  db c8 30 02
	ld de, (xiz-2)                                       ; FF737E  9e fe 22
	add DE,0x0230                                        ; FF7381  da c8 30 02
	inc 1,IX                                             ; FF7385  dc 61
	add XSP,0x00000012                                   ; FF7387  ef c8 12 00 00 00
	cp HL,0x1180                                         ; FF738D  db cf 80 11
	jr lt, .LFF7343                                      ; FF7391  61 b0
	popw ix                                              ; FF7393  4c
	popw de                                              ; FF7394  4a
	popw hl                                              ; FF7395  4b
	unlk XIZ                                             ; FF7396  ee 0d
	ret                                                  ; FF7398  0e
; ---------------------------------------------------------------------
; L0adSingleC0mbination_DrawGroupCombinations -- loads a pointer straight at ROM TEXT.  NOT NAMED.
;
; Called from: prom_a PanelButtonDispatch_L0adSingleS0und (`calr`) at 0xFF6CE6
;          prom_a PageDispatch_L0adSingleC0mbination (`calr`) at 0xFF6E5A
;
;     0xFF73DC loads 0xFF4291, where the ROM reads:
;        "                U1 -U2 -UD1-UD2-"
; Evidence: the immediate at the cited instruction, and the bytes
;          at that address in original_ROMs/, read as printable
;          ASCII until the first non-printable byte.
; NOT NAMED because the text says what the routine READS, not what it DOES
;          with it; a name taken from it would claim a role nothing here
;          establishes. The string is recorded so the next round starts
;          from evidence instead of a search.
; Recorded by notes/prom_a_understanding_round7.py --apply-strings.
; ---------------------------------------------------------------------
; L0adSingleC0mbination_DrawGroupCombinations: the same over a combination group (T_CombiGroup_MaxMemberIndex_ByStack).
L0adSingleC0mbination_DrawGroupCombinations:
	link XIZ,0xfffe                                      ; FF7399  ee 0c fe ff
	pushw hl                                             ; FF739D  2b
	pushw de                                             ; FF739E  2a
	pushw ix                                             ; FF739F  2c
	ld c, 0x02:opc                                          ; FF73A0  23 02
	mul	bc, (0x2736:16)                              ; FF73A2  c1 36 27 43
	extz XBC                                             ; FF73A6  e9 12
	add XBC,Table_FF4039                                 ; FF73A8  e9 c8 39 40 ff 00
	ld BC,(XBC)                                          ; FF73AE  91 21
	pushw bc                                             ; FF73B0  29
	push 0x00                                            ; FF73B1  09 00
	push	(0x2737:16)                                  ; FF73B3  c1 37 27 04
	call T_CombiGroup_MaxMemberIndex_ByStack                                        ; FF73B7  1d 14 34 f4
	extz WA                                              ; FF73BB  d8 12
	ld (xiz-2), wa                                       ; FF73BD  be fe 50
	pop XIY                                              ; FF73C0  5d
	cp WA,0x00ff                                         ; FF73C1  d8 cf ff 00
	jr z, .LFF7430                                       ; FF73C5  66 69
	ldw ix, 0x00                                         ; FF73C7  34 00 00
	ldw de, 0x00                                         ; FF73CA  32 00 00
	ldw hl, 0x0eee                                       ; FF73CD  33 ee 0e
.LFF73D0:
	cp	ix, (xiz-2)                                  ; FF73D0  9e fe f4
	jr le, .LFF73E4                                      ; FF73D3  62 0f
	pushw 0x06                                           ; FF73D5  0b 06 00
	pushw 0x10                                           ; FF73D8  0b 10 00
	pushw hl                                             ; FF73DB  2b
	lda xbc, (Text_FF4291:24)                            ; FF73DC  f2 91 42 ff 31
	push XBC                                             ; FF73E1  39
	jr .LFF7418                                          ; FF73E2  68 34
.LFF73E4:
	lda xbc, (0x2940:16)                                ; FF73E4  f1 40 29 31
	push XBC                                             ; FF73E8  39
	ld a, 0x02:opc                                          ; FF73E9  21 02
	mul	wa, (0x2736:16)                              ; FF73EB  c1 36 27 41
	extz XWA                                             ; FF73EF  e8 12
	add XWA,Table_FF4039                                 ; FF73F1  e8 c8 39 40 ff 00
	ld WA,(XWA)                                          ; FF73F7  90 20
	pushw wa                                             ; FF73F9  28
	ld_erpb_rr a, 0xf0                                   ; FF73FA  c7 f0 89   ld A,IXL
	pushw wa                                             ; FF73FD  28
	push 0x00                                            ; FF73FE  09 00
	push	(0x2737:16)                                  ; FF7400  c1 37 27 04
	call T_CombiName_CopyToBuffer                                        ; FF7404  1d 0c 34 f4
	inc 8,XSP                                            ; FF7408  ef 60
	inc 2,XSP                                            ; FF740A  ef 62
	pushw 0x06                                           ; FF740C  0b 06 00
	pushw 0x10                                           ; FF740F  0b 10 00
	pushw hl                                             ; FF7412  2b
	lda xbc, (0x2940:16)                                ; FF7413  f1 40 29 31
	push XBC                                             ; FF7417  39
.LFF7418:
	call LCD_SwiTextCall_SaveRegs                                      ; FF7418  1d 95 78 ff
	add DE,0x0208                                        ; FF741C  da c8 08 02
	add HL,0x0208                                        ; FF7420  db c8 08 02
	inc 1,IX                                             ; FF7424  dc 61
	inc 8,XSP                                            ; FF7426  ef 60
	inc 2,XSP                                            ; FF7428  ef 62
	cp DE,0x1040                                         ; FF742A  da cf 40 10
	jr lt, .LFF73D0                                      ; FF742E  61 a0
.LFF7430:
	popw ix                                              ; FF7430  4c
	popw de                                              ; FF7431  4a
	popw hl                                              ; FF7432  4b
	unlk XIZ                                             ; FF7433  ee 0d
	ret                                                  ; FF7435  0e
; ---------------------------------------------------------------------
; L0adSingle_DrawBankAndNumber -- loads a pointer straight at ROM TEXT.  NOT NAMED.
;
; Called from: prom_a PageDispatch_L0adSingleS0und (`calr`) at 0xFF6802
;          prom_a PanelButtonDispatch_L0adSingleS0und (`calr`) at 0xFF6BC8
;          prom_a PanelButtonDispatch_L0adSingleS0und (`calr`) at 0xFF6C1A
;          prom_a PageDispatch_L0adSingleC0mbination (`calr`) at 0xFF6E63
;          ... and 1 more
;
;     0xFF744E loads 0xFF42A1, where the ROM reads:
;        "U1 -U2 -UD1-UD2-"
; Evidence: the immediate at the cited instruction, and the bytes
;          at that address in original_ROMs/, read as printable
;          ASCII until the first non-printable byte.
; NOT NAMED because the text says what the routine READS, not what it DOES
;          with it; a name taken from it would claim a role nothing here
;          establishes. The string is recorded so the next round starts
;          from evidence instead of a search.
; Recorded by notes/prom_a_understanding_round7.py --apply-strings.
; ---------------------------------------------------------------------
; L0adSingle_DrawBankAndNumber: (n): Text_UserBankAbbrevs[(0x2728)]'s 4 characters, then n + 1 in 1..3 digits, drawn at 0x19A5.  Called by the
;   SoftKeyCols3_4 page-0 handlers with (0x2735).
L0adSingle_DrawBankAndNumber:
	link XIZ,0xfff6                                      ; FF7436  ee 0c f6 ff
	pushw hl                                             ; FF743A  2b
	pushw de                                             ; FF743B  2a
	push XIX                                             ; FF743C  3c
	lda xix, (xiz-10)                                    ; FF743D  be f6 34
	ld L,(XIZ+0x08)                                      ; FF7440  8e 08 27
	pushw 0x04                                           ; FF7443  0b 04 00
	ld c, 0x04:opc                                          ; FF7446  23 04
	mul	bc, (0x2728:16)                              ; FF7448  c1 28 27 43
	extz XBC                                             ; FF744C  e9 12
	add XBC,Text_UserBankAbbrevs                                  ; FF744E  e9 c8 a1 42 ff 00
	push XBC                                             ; FF7454  39
	push XIX                                             ; FF7455  3c
	call MemCpy_C                                      ; FF7456  1d b5 78 ff
	ld D,L                                               ; FF745A  cf 8c
	inc 1,L                                              ; FF745C  cf 61
	inc 8,XSP                                            ; FF745E  ef 60
	inc 2,XSP                                            ; FF7460  ef 62
	cp L,0x0a                                            ; FF7462  cf cf 0a
	jr nc, .LFF7475                                      ; FF7465  6f 0e
	ld C,L                                               ; FF7467  cf 8b
	add C,0x30                                           ; FF7469  cb c8 30
	ld (XIX+0x04),C                                      ; FF746C  bc 04 43
	ld (XIX+0x05),0x20                                   ; FF746F  bc 05 00 20
	jr .LFF7494                                          ; FF7473  68 1f
.LFF7475:
	cp L,0x64                                            ; FF7475  cf cf 64
	jr nc, .LFF749A                                      ; FF7478  6f 20
	ld C,L                                               ; FF747A  cf 8b
	extz BC                                              ; FF747C  d9 12
	div C,0x0a                                           ; FF747E  cb 0a 0a
	add C,0x30                                           ; FF7481  cb c8 30
	ld (XIX+0x04),C                                      ; FF7484  bc 04 43
	ld C,L                                               ; FF7487  cf 8b
	extz BC                                              ; FF7489  d9 12
	div C,0x0a                                           ; FF748B  cb 0a 0a
	add B,0x30                                           ; FF748E  ca c8 30
	ld (XIX+0x05),B                                      ; FF7491  bc 05 42
.LFF7494:
	ld (XIX+0x06),0x20                                   ; FF7494  bc 06 00 20
	jr .LFF74BD                                          ; FF7498  68 23
.LFF749A:
	ld (XIX+0x04),0x31                                   ; FF749A  bc 04 00 31
	ld H,L                                               ; FF749E  cf 8e
	sub H,0x64                                           ; FF74A0  ce ca 64
	ld C,H                                               ; FF74A3  ce 8b
	extz BC                                              ; FF74A5  d9 12
	div C,0x0a                                           ; FF74A7  cb 0a 0a
	add C,0x30                                           ; FF74AA  cb c8 30
	ld (XIX+0x05),C                                      ; FF74AD  bc 05 43
	ld C,H                                               ; FF74B0  ce 8b
	extz BC                                              ; FF74B2  d9 12
	div C,0x0a                                           ; FF74B4  cb 0a 0a
	add B,0x30                                           ; FF74B7  ca c8 30
	ld (XIX+0x06),B                                      ; FF74BA  bc 06 42
.LFF74BD:
	pushw 0x06                                           ; FF74BD  0b 06 00
	pushw 0x07                                           ; FF74C0  0b 07 00
	pushw 0x19a5                                         ; FF74C3  0b a5 19
	push XIX                                             ; FF74C6  3c
	call LCD_SwiTextCall_SaveRegs                                      ; FF74C7  1d 95 78 ff
	ld H,D                                               ; FF74CB  cc 8e
	srl h, 0x03                                          ; FF74CD  ce ef 03
	inc 1,H                                              ; FF74D0  ce 61
	inc 8,XSP                                            ; FF74D2  ef 60
	inc 2,XSP                                            ; FF74D4  ef 62
	cp H,0x0a                                            ; FF74D6  ce cf 0a
	jr nc, .LFF74E8                                      ; FF74D9  6f 0d
	ld (XIX),0x30                                        ; FF74DB  b4 00 30
	ld C,H                                               ; FF74DE  ce 8b
	add C,0x30                                           ; FF74E0  cb c8 30
	ld (XIX+0x01),C                                      ; FF74E3  bc 01 43
	jr .LFF74F3                                          ; FF74E6  68 0b
.LFF74E8:
	ld (XIX),0x31                                        ; FF74E8  b4 00 31
	ld C,H                                               ; FF74EB  ce 8b
	add C,0x26                                           ; FF74ED  cb c8 26
	ld (XIX+0x01),C                                      ; FF74F0  bc 01 43
.LFF74F3:
	pushw 0x06                                           ; FF74F3  0b 06 00
	pushw 0x02                                           ; FF74F6  0b 02 00
	pushw 0x1c2a                                         ; FF74F9  0b 2a 1c
	push XIX                                             ; FF74FC  3c
	call LCD_SwiTextCall_SaveRegs                                      ; FF74FD  1d 95 78 ff
	ld C,D                                               ; FF7501  cc 8b
	and C,0x07                                           ; FF7503  cb cc 07
	add C,0x31                                           ; FF7506  cb c8 31
	ld (XIX),C                                           ; FF7509  b4 43
	pushw 0x06                                           ; FF750B  0b 06 00
	pushw 0x01                                           ; FF750E  0b 01 00
	pushw 0x1c2d                                         ; FF7511  0b 2d 1c
	push XIX                                             ; FF7514  3c
	call LCD_SwiTextCall_SaveRegs                                      ; FF7515  1d 95 78 ff
	add XSP,0x00000014                                   ; FF7519  ef c8 14 00 00 00
	pop XIX                                              ; FF751F  5c
	popw de                                              ; FF7520  4a
	popw hl                                              ; FF7521  4b
	unlk XIZ                                             ; FF7522  ee 0d
	ret                                                  ; FF7524  0e
; Var2728_Is2or3: WA = 1 when (0x2728) is 2 or 3, else 0.
Var2728_Is2or3:
	cp	(0x2728:16), 0x02                            ; FF7525  c1 28 27 3f 02
	jr z, .LFF7533                                       ; FF752A  66 07
	cp	(0x2728:16), 0x03                            ; FF752C  c1 28 27 3f 03
	jr nz, .LFF7538                                      ; FF7531  6e 05
.LFF7533:
	ldw wa, 0x01                                         ; FF7533  30 01 00
	jr .LFF753A                                          ; FF7536  68 02
.LFF7538:
	sub WA,WA                                            ; FF7538  d8 a0
.LFF753A:
	ret                                                  ; FF753A  0e
; Var7FD6_IsBitClear(which): WA = 1 when bit 0 (which == 0) or bit 1 (which != 0) of (0x7FD6) is clear, else 0.
Var7FD6_IsBitClear:
	link XIZ,0x0000                                      ; FF753B  ee 0c 00 00
	cpw	(xiz+8), 0x0000                              ; FF753F  9e 08 3f 00 00
	jr nz, .LFF7551                                      ; FF7544  6e 0b
	ld c, (0x7fd6:16)                                   ; FF7546  c1 d6 7f 23
	and C,0x01                                           ; FF754A  cb cc 01
	jr z, .LFF755E                                       ; FF754D  66 0f
	jr .LFF755A                                          ; FF754F  68 09
.LFF7551:
	ld c, (0x7fd6:16)                                   ; FF7551  c1 d6 7f 23
	and C,0x02                                           ; FF7555  cb cc 02
	jr z, .LFF755E                                       ; FF7558  66 04
.LFF755A:
	sub WA,WA                                            ; FF755A  d8 a0
	jr .LFF7561                                          ; FF755C  68 03
.LFF755E:
	ldw wa, 0x01                                         ; FF755E  30 01 00
.LFF7561:
	unlk XIZ                                             ; FF7561  ee 0d
	ret                                                  ; FF7563  0e
; DiskL0adFile_LcdKeyRow1: the LcdKeyRow1 action of DiskL0adFile -- called only by LcdKeyRow1_DiskL0adFile.
DiskL0adFile_LcdKeyRow1:
	pushw hl                                             ; FF7564  2b
	res	3, (UI_RequestBits:16)                               ; FF7565  f1 75 20 b3
	ld h, (Disk_ContentType:16)                                   ; FF7569  c1 25 27 26
	calr DiskEntry_CopySelectedToFileName                                      ; FF756D  1e 14 fb
	call T_DiskLoadFile_Execute                                        ; FF7570  1d c8 25 f4
	call SC1_CmdEFAndClearHeldButtons                                      ; FF7574  1d 59 79 ff
	ld xbc, (0x60341e:24)                               ; FF7578  e2 1e 34 60 21
	or XBC,XBC                                           ; FF757D  e9 e1
	jr z, .LFF7590                                       ; FF757F  66 0f
	cp h, 0x00:i3                                          ; FF7581  ce d8
	jr z, .LFF7589                                       ; FF7583  66 04
	cp h, 0x01:i3                                          ; FF7585  ce d9
	jr nz, .LFF759A                                      ; FF7587  6e 11
.LFF7589:
	ld (UI_Request:16), 0x08                                 ; FF7589  f1 70 20 00 08
	jr .LFF7595                                          ; FF758E  68 05
.LFF7590:
	ld (UI_Request:16), 0x01                                 ; FF7590  f1 70 20 00 01
.LFF7595:
	ld (UI_Request_Hi:16), 0x02                                 ; FF7595  f1 71 20 00 02
.LFF759A:
	popw hl                                              ; FF759A  4b
	ret                                                  ; FF759B  0e
; UI_StatusCode_Is0or2or4: WA = 1 when UI_StatusCode is 0, 2 or 4, else 0.  What those codes mean is not established.
UI_StatusCode_Is0or2or4:
	pushw hl                                             ; FF759C  2b
	ld h, (UI_StatusCode:16)                                   ; FF759D  c1 80 28 26
	cp h, 0x00:i3                                          ; FF75A1  ce d8
	jr z, .LFF75AD                                       ; FF75A3  66 08
	cp h, 0x02:i3                                          ; FF75A5  ce da
	jr z, .LFF75AD                                       ; FF75A7  66 04
	cp h, 0x04:i3                                          ; FF75A9  ce dc
	jr nz, .LFF75B2                                      ; FF75AB  6e 05
.LFF75AD:
	ldw wa, 0x01                                         ; FF75AD  30 01 00
	jr .LFF75B4                                          ; FF75B0  68 02
.LFF75B2:
	sub WA,WA                                            ; FF75B2  d8 a0
.LFF75B4:
	popw hl                                              ; FF75B4  4b
	ret                                                  ; FF75B5  0e
; DiskScreens_PhaseVector: module 18's boot phase vector -- ModuleInitDirectory_F82641[18] reaches it through prom_b's
;   pointer slot T_DiskScreens_PhaseVector (0xF42250, a word, not a `jp`); the walker calls slot k (4 bytes) for boot
;   phase k.  The slots are short code: phase 0 `jr DiskScreens_InitSelectedEntry`, phases 1-4 `nop / nop / ret`, and
;   a sixth slot no phase reaches (notes/prom_a_module18_phase_vector.py).
DiskScreens_PhaseVector:
	jr DiskScreens_InitSelectedEntry                                          ; FF75B6  68 15
	ret                                                  ; FF75B8  0e
	nop                                                  ; FF75B9  00
	nop                                                  ; FF75BA  00
	nop                                                  ; FF75BB  00
	ret                                                  ; FF75BC  0e
	nop                                                  ; FF75BD  00
	nop                                                  ; FF75BE  00
	nop                                                  ; FF75BF  00
	ret                                                  ; FF75C0  0e
	nop                                                  ; FF75C1  00
	nop                                                  ; FF75C2  00
	nop                                                  ; FF75C3  00
	ret                                                  ; FF75C4  0e
	nop                                                  ; FF75C5  00
	nop                                                  ; FF75C6  00
	nop                                                  ; FF75C7  00
	ret                                                  ; FF75C8  0e
	nop                                                  ; FF75C9  00
	nop                                                  ; FF75CA  00
	nop                                                  ; FF75CB  00
	ret                                                  ; FF75CC  0e
; DiskScreens_InitSelectedEntry: boot phase 0 of module 18 -- Disk_SelectedEntry = 0x14, one past the largest entry
;   (0x13) the Medley code stores.
DiskScreens_InitSelectedEntry:
	ld (Disk_SelectedEntry:16), 0x14                                 ; FF75CD  f1 24 27 00 14
	ret                                                  ; FF75D2  0e
; DisplayList_RunOnLayer_SaveRegs(list, xix, layer): LCD_CurrentLayer = layer, then T_DisplayList_Run; C-callable, XIX/XHL/XDE kept.
DisplayList_RunOnLayer_SaveRegs:
	push XIZ                                             ; FF75D3  3e
	ld XIZ,XSP                                           ; FF75D4  ef 8e
	push XIX                                             ; FF75D6  3c
	push XHL                                             ; FF75D7  3b
	push XDE                                             ; FF75D8  3a
	ld XIY,(XIZ+0x08)                                    ; FF75D9  ae 08 25
	ld XIX,(XIZ+0x0c)                                    ; FF75DC  ae 0c 24
	ld DE,(XIZ+0x10)                                     ; FF75DF  9e 10 22
	ld (LCD_CurrentLayer:16), e                                   ; FF75E2  f1 40 25 45
	call T_DisplayList_Run                               ; FF75E6  1d f0 17 f4
	pop XDE                                              ; FF75EA  5a
	pop XHL                                              ; FF75EB  5b
	pop XIX                                              ; FF75EC  5c
	pop XIZ                                              ; FF75ED  5e
	ret                                                  ; FF75EE  0e
; DisplayListB_Run_SaveRegs(list, xix): T_DisplayListB_Run; C-callable, XIX/XHL/XDE kept.
DisplayListB_Run_SaveRegs:
	push XIZ                                             ; FF75EF  3e
	ld XIZ,XSP                                           ; FF75F0  ef 8e
	push XIX                                             ; FF75F2  3c
	push XHL                                             ; FF75F3  3b
	push XDE                                             ; FF75F4  3a
	ld XIY,(XIZ+0x08)                                    ; FF75F5  ae 08 25
	ld XIX,(XIZ+0x0c)                                    ; FF75F8  ae 0c 24
	call T_DisplayListB_Run                              ; FF75FB  1d f4 17 f4
	pop XDE                                              ; FF75FF  5a
	pop XHL                                              ; FF7600  5b
	pop XIX                                              ; FF7601  5c
	pop XIZ                                              ; FF7602  5e
	ret                                                  ; FF7603  0e
; LCD_BlankAndSetPanel3Layer_SaveRegs: SWI7 service 0x0C with C = 0 (every layer off), then service 0x10 (SYSTEM SET, three-layer panel).
LCD_BlankAndSetPanel3Layer_SaveRegs:
	push XIZ                                             ; FF7604  3e
	push XIX                                             ; FF7605  3c
	push XHL                                             ; FF7606  3b
	push XDE                                             ; FF7607  3a
	xor C,C                                              ; FF7608  cb d3
	ld a, 0x0c:opc                                          ; FF760A  21 0c
	swi 7                                                ; FF760C  ff
	ld a, 0x10:opc                                          ; FF760D  21 10
	swi 7                                                ; FF760F  ff
	pop XDE                                              ; FF7610  5a
	pop XHL                                              ; FF7611  5b
	pop XIX                                              ; FF7612  5c
	pop XIZ                                              ; FF7613  5e
	ret                                                  ; FF7614  0e
; ---------------------------------------------------------------------
; LCD_ShowAllThreeLayers_SaveRegs -- service 0x0C with C = 7, with four registers preserved
;
; Called from: prom_a Paint_DiskMenu (`call`) at 0xFF4312
;          prom_a Paint_MidiFileDirectPlay (`call`) at 0xFF4572
;          prom_a Paint_DiskL0adFile (`call`) at 0xFF48EA
;          prom_a PanelButtonDispatch_DiskL0adFile (`call`) at 0xFF4A77
;          prom_a LcdKeyRow3_DiskL0adFile (`call`) at 0xFF4AC0
;          prom_a LcdKeyRow4_DiskL0adFile (`call`) at 0xFF4D54
;          prom_a LcdKeyRow5_DiskL0adFile (`call`) at 0xFF4FD6
;          prom_a Paint_MidiFileL0ad (`call`) at 0xFF50DE
;          prom_a PageDispatch_DiskSaveFile (`call`) at 0xFF553A
;          prom_a Paint_DiskSaveFile (`call`) at 0xFF55B3, 0xFF5615, 0xFF5713
;          prom_a PageDispatch_MidiFileSave (`call`) at 0xFF5D1B, 0xFF5DDC, 0xFF5E3F, 0xFF5EA2
;          prom_a Paint_FloppyDiskFormatSelectType (`call`) at 0xFF6544
;          prom_a Paint_FloppyDiskFormatAreYouSure (`call`) at 0xFF669F
;          prom_a PageDispatch_L0adSingleS0und (`call`) at 0xFF6828, 0xFF68BE
;          prom_a PageDispatch_L0adSingleC0mbination (`call`) at 0xFF6E89, 0xFF6F08
; Issues:  SWI7 service 0x0C at 0xFF761D -- LCD_Svc_0C_SetLayersOn, rebuild DISP ON: C bits 0/1/2 = layers 1/2/3 steady on
; Evidence: `push XIZ/XIX/XHL/XDE`, `ld C,0x07`, service 0x0C, then the four pops.
;           Same effect as LCD_ScreenRedraw_End; the pushes are what distinguish it.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_ShowAllThreeLayers_SaveRegs:
	push XIZ                                             ; FF7615  3e
	push XIX                                             ; FF7616  3c
	push XHL                                             ; FF7617  3b
	push XDE                                             ; FF7618  3a
	ld c, 0x07:opc                                          ; FF7619  23 07
	ld a, 0x0c:opc                                          ; FF761B  21 0c
	swi 7                                                ; FF761D  ff
	pop XDE                                              ; FF761E  5a
	pop XHL                                              ; FF761F  5b
	pop XIX                                              ; FF7620  5c
	pop XIZ                                              ; FF7621  5e
	ret                                                  ; FF7622  0e
; DLB_Array8_2_OnLayer1_SaveRegs(list): T_DLB_Handler_Array8_2 with LCD_CurrentLayer = 1, then layer 0 again.
DLB_Array8_2_OnLayer1_SaveRegs:
	push XIZ                                             ; FF7623  3e
	ld XIZ,XSP                                           ; FF7624  ef 8e
	push XIX                                             ; FF7626  3c
	push XHL                                             ; FF7627  3b
	push XDE                                             ; FF7628  3a
	ld (LCD_CurrentLayer:16), 0x01                                 ; FF7629  f1 40 25 00 01
	ld XIY,(XIZ+0x08)                                    ; FF762E  ae 08 25
	call T_DLB_Handler_Array8_2                                        ; FF7631  1d 20 18 f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF7635  f1 40 25 00 00
	pop XDE                                              ; FF763A  5a
	pop XHL                                              ; FF763B  5b
	pop XIX                                              ; FF763C  5c
	pop XIZ                                              ; FF763D  5e
	ret                                                  ; FF763E  0e
; DLB_Array8_SaveRegs(list): T_DLB_Handler_Array8, then LCD_CurrentLayer = 0.
DLB_Array8_SaveRegs:
	push XIZ                                             ; FF763F  3e
	ld XIZ,XSP                                           ; FF7640  ef 8e
	push XIX                                             ; FF7642  3c
	push XHL                                             ; FF7643  3b
	push XDE                                             ; FF7644  3a
	ld XIY,(XIZ+0x08)                                    ; FF7645  ae 08 25
	call T_DLB_Handler_Array8                                        ; FF7648  1d 1c 18 f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF764C  f1 40 25 00 00
	pop XDE                                              ; FF7651  5a
	pop XHL                                              ; FF7652  5b
	pop XIX                                              ; FF7653  5c
	pop XIZ                                              ; FF7654  5e
	ret                                                  ; FF7655  0e
; ---------------------------------------------------------------------
; DLB_Handler_StringTable_Veneer -- calls display-list-B's string-table handler with the list
;                                   pointer taken from the caller's frame at +8
;
; Evidence: 0xFF7656/0xFF7657 build a frame with XIZ; 0xFF765C `ld
;           XIY,(XIZ+0x08)` loads the argument the handler reads;
;           0xFF765F `call 0xF417F8` is prom_b slot
;           T_DLB_Handler_StringTable, whose `jp` target 0xF31B21
;           carries the label DLB_Handler_StringTable in prom_b;
;           0xFF7663-0xFF7666 restore XDE, XHL, XIX and XIZ. Seven call
;           sites, the first at 0xFF691D. DERIVATIVE
; Unknown:  what the +8 argument is beyond a list pointer
; Was `sub_FF7656`, named by notes/prom_a_census_round8.py (bucket round 9).
; ---------------------------------------------------------------------
DLB_Handler_StringTable_Veneer:
	push XIZ                                             ; FF7656  3e
	ld XIZ,XSP                                           ; FF7657  ef 8e
	push XIX                                             ; FF7659  3c
	push XHL                                             ; FF765A  3b
	push XDE                                             ; FF765B  3a
	ld XIY,(XIZ+0x08)                                    ; FF765C  ae 08 25
	call T_DLB_Handler_StringTable                       ; FF765F  1d f8 17 f4
	pop XDE                                              ; FF7663  5a
	pop XHL                                              ; FF7664  5b
	pop XIX                                              ; FF7665  5c
	pop XIZ                                              ; FF7666  5e
	ret                                                  ; FF7667  0e
; ---------------------------------------------------------------------
; DLB_Handler_Decimal_Veneer -- the same veneer for display-list-B's decimal handler, and
;                               it clears (0x2540) first
;
; Evidence: 0xFF766E `stdi8 (0x2540), 0x00` -- the layer select this
;           module writes before every draw -- then 0xFF7673 `ld
;           XIY,(XIZ+0x08)` and 0xFF7676 `call 0xF41800` = prom_b slot
;           T_DLB_Handler_Decimal, whose `jp` target 0xF31BA1 carries the label
;           DLB_Handler_Decimal. Ten call sites, the first at 0xFF4BC1.
;           DERIVATIVE, and the (0x2540) store is the one thing it adds
; Unknown:  as above
; Was `sub_FF7668`, named by notes/prom_a_census_round8.py (bucket round 9).
; ---------------------------------------------------------------------
DLB_Handler_Decimal_Veneer:
	push XIZ                                             ; FF7668  3e
	ld XIZ,XSP                                           ; FF7669  ef 8e
	push XIX                                             ; FF766B  3c
	push XHL                                             ; FF766C  3b
	push XDE                                             ; FF766D  3a
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF766E  f1 40 25 00 00
	ld XIY,(XIZ+0x08)                                    ; FF7673  ae 08 25
	call T_DLB_Handler_Decimal                                        ; FF7676  1d 00 18 f4
	pop XDE                                              ; FF767A  5a
	pop XHL                                              ; FF767B  5b
	pop XIX                                              ; FF767C  5c
	pop XIZ                                              ; FF767D  5e
	ret                                                  ; FF767E  0e
; Disk_DrawDirectory20: Disk_DrawDirEntry for the 20 16-byte entries at 0x60A482, two columns (screen positions 0x052E + 0x230*k, then 0x053D after entry 10).
Disk_DrawDirectory20:
	push XIZ                                             ; FF767F  3e
	push XIX                                             ; FF7680  3c
	push XHL                                             ; FF7681  3b
	push XDE                                             ; FF7682  3a
	ld XIY,0x0060a482                                    ; FF7683  45 82 a4 60 00
	ldw ix, 0x052e                                       ; FF7688  34 2e 05
	xor WA,WA                                            ; FF768B  d8 d0
	xor HL,HL                                            ; FF768D  db d3
.LFF768F:
	call Disk_DrawDirEntry                                      ; FF768F  1d b5 76 ff
	xor HL,HL                                            ; FF7693  db d3
	add IY,0x0010                                        ; FF7695  dd c8 10 00
	inc 1,W                                              ; FF7699  c8 61
	cp W,0x13                                            ; FF769B  c8 cf 13
	jr ugt, .LFF76B0                                     ; FF769E  6b 10
	cp W,0x0a                                            ; FF76A0  c8 cf 0a
	jr z, .LFF76AB                                       ; FF76A3  66 06
	add IX,0x0230                                        ; FF76A5  dc c8 30 02
	jr .LFF768F                                          ; FF76A9  68 e4
.LFF76AB:
	ldw ix, 0x053d                                       ; FF76AB  34 3d 05
	jr .LFF768F                                          ; FF76AE  68 df
.LFF76B0:
	pop XDE                                              ; FF76B0  5a
	pop XHL                                              ; FF76B1  5b
	pop XIX                                              ; FF76B2  5c
	pop XIZ                                              ; FF76B3  5e
	ret                                                  ; FF76B4  0e
; ---------------------------------------------------------------------
; Disk_DrawDirEntry -- loads a pointer straight at ROM TEXT.  NOT NAMED.
;
; Called from: prom_a Disk_DrawDirectory20 (`call`) at 0xFF768F
;
;     0xFF76DD loads 0xF58625, where the ROM reads:
;        ".ALL.SEQ.CMB.SND.PNL.MDS.SRM.CRM.DRM            "
; Evidence: the immediate at the cited instruction, and the bytes
;          at that address in original_ROMs/, read as printable
;          ASCII until the first non-printable byte.
; NOT NAMED because the text says what the routine READS, not what it DOES
;          with it; a name taken from it would claim a role nothing here
;          establishes. The string is recorded so the next round starts
;          from evidence instead of a search.
; Recorded by notes/prom_a_understanding_round7.py --apply-strings.
; ---------------------------------------------------------------------
; Disk_DrawDirEntry(XIY = entry, IX = position): 6 name characters and the 4-character extension (DLText_F58625: .ALL .SEQ ...) for the entry's type, or 9 blanks for type 9.
Disk_DrawDirEntry:
	push XIY                                             ; FF76B5  3d
	pushw wa                                             ; FF76B6  28
	push XIY                                             ; FF76B7  3d
	inc 6,XIY                                            ; FF76B8  ed 66
	push XIY                                             ; FF76BA  3d
	call DiskEntry_GetContentType                                      ; FF76BB  1d 36 49 ff
	ld L,A                                               ; FF76BF  c9 8f
	inc 4,XSP                                            ; FF76C1  ef 64
	pop XIY                                              ; FF76C3  5d
	xor H,H                                              ; FF76C4  ce d6
	and L,0x0f                                           ; FF76C6  cf cc 0f
	cp L,0x09                                            ; FF76C9  cf cf 09
	jr z, .LFF76ED                                       ; FF76CC  66 1f
	pushw hl                                             ; FF76CE  2b
	xor HL,HL                                            ; FF76CF  db d3
	ldw bc, 0x06                                         ; FF76D1  31 06 00
	call LCD_DrawText8x14_Layer0_SaveRegs                                      ; FF76D4  1d fe 76 ff
	popw hl                                              ; FF76D8  4b
	push XIX                                             ; FF76D9  3c
	ldw bc, 0x04                                         ; FF76DA  31 04 00
	ld XIY,DLText_F58625                                 ; FF76DD  45 25 86 f5 00
	add IX,0x0006                                        ; FF76E2  dc c8 06 00
	call LCD_DrawText8x14_Layer0_SaveRegs                                      ; FF76E6  1d fe 76 ff
	pop XIX                                              ; FF76EA  5c
	jr .LFF76FB                                          ; FF76EB  68 0e
.LFF76ED:
	xor HL,HL                                            ; FF76ED  db d3
	ldw bc, 0x09                                         ; FF76EF  31 09 00
	ld XIY,DLText_F5864D_Blank9                          ; FF76F2  45 4d 86 f5 00
	call LCD_DrawText8x14_Layer0_SaveRegs                                      ; FF76F7  1d fe 76 ff
.LFF76FB:
	popw wa                                              ; FF76FB  48
	pop XIY                                              ; FF76FC  5d
	ret                                                  ; FF76FD  0e
; ---------------------------------------------------------------------
; LCD_DrawText8x14_Layer0_SaveRegs -- draw the caller's 8x14 string on layer 0, preserving four registers
;
; Called from: prom_a Disk_DrawDirEntry (`call`) at 0xFF76D4, 0xFF76E6, 0xFF76F7
; Issues:  SWI7 service 0x06 at 0xFF7709 -- LCD_Svc_06_DrawText8x14, draw 8x14 text
; Evidence: `push WA/BC/XIY/XIX`, `ld (0x2540),0x00`, service 0x06, then the four pops.
;           None of XIY, BC, HL or IX is loaded in the body, so every argument of the
;           text service is the caller's; the routine contributes the layer and the
;           register discipline.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_DrawText8x14_Layer0_SaveRegs:
	pushw wa                                             ; FF76FE  28
	pushw bc                                             ; FF76FF  29
	push XIY                                             ; FF7700  3d
	push XIX                                             ; FF7701  3c
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF7702  f1 40 25 00 00
	ld a, 0x06:opc                                          ; FF7707  21 06
	swi 7                                                ; FF7709  ff
	pop XIX                                              ; FF770A  5c
	pop XIY                                              ; FF770B  5d
	popw bc                                              ; FF770C  49
	popw wa                                              ; FF770D  48
	ret                                                  ; FF770E  0e
; LCD_DrawDiskFileName6_SaveRegs: 6 characters from Disk_FileName+2 at screen position 0x05AF (SWI7 service 0x08).
LCD_DrawDiskFileName6_SaveRegs:
	push XIZ                                             ; FF770F  3e
	push XIX                                             ; FF7710  3c
	push XHL                                             ; FF7711  3b
	push XDE                                             ; FF7712  3a
	ldw hl, 0x00                                         ; FF7713  33 00 00
	ldw bc, 0x06                                         ; FF7716  31 06 00
	ld XIY,Disk_FileName+2                                    ; FF7719  45 ca 21 00 00
	ldw ix, 0x05af                                       ; FF771E  34 af 05
	ld a, 0x08:opc                                          ; FF7721  21 08
	swi 7                                                ; FF7723  ff
	pop XDE                                              ; FF7724  5a
	pop XHL                                              ; FF7725  5b
	pop XIX                                              ; FF7726  5c
	pop XIZ                                              ; FF7727  5e
	ret                                                  ; FF7728  0e
; LCD_DrawDiskFileName8_SaveRegs: 8 characters from Disk_FileName at screen position 0x05AD (SWI7 service 0x08).
LCD_DrawDiskFileName8_SaveRegs:
	push XIZ                                             ; FF7729  3e
	push XIX                                             ; FF772A  3c
	push XHL                                             ; FF772B  3b
	push XDE                                             ; FF772C  3a
	ldw hl, 0x00                                         ; FF772D  33 00 00
	ldw bc, 0x08                                         ; FF7730  31 08 00
	ld XIY,Disk_FileName                                    ; FF7733  45 c8 21 00 00
	ldw ix, 0x05ad                                       ; FF7738  34 ad 05
	ld a, 0x08:opc                                          ; FF773B  21 08
	swi 7                                                ; FF773D  ff
	pop XDE                                              ; FF773E  5a
	pop XHL                                              ; FF773F  5b
	pop XIX                                              ; FF7740  5c
	pop XIZ                                              ; FF7741  5e
	ret                                                  ; FF7742  0e
; UI_ScreenItem_StepByDial(W): UI_RequestBits |= 0x09, PanelDial_DownButton = 0x80; steps UI_ScreenItem by +-1 (bit 7 of W = down), clamped 0..0x13.
UI_ScreenItem_StepByDial:
	push XIZ                                             ; FF7743  3e
	push XIX                                             ; FF7744  3c
	push XHL                                             ; FF7745  3b
	push XDE                                             ; FF7746  3a
	or	(UI_RequestBits:16), 0x09                            ; FF7747  c1 75 20 3e 09
	ld (PanelDial_DownButton:16), 0x80                                 ; FF774C  f1 9b 20 00 80
	and W,0x80                                           ; FF7751  c8 cc 80
	inc 1,W                                              ; FF7754  c8 61
	ld a, (UI_ScreenItem:16)                                   ; FF7756  c1 20 27 21
	and A,0x1f                                           ; FF775A  c9 cc 1f
	ld L,A                                               ; FF775D  c9 8f
	ld b, 0x13:opc                                          ; FF775F  22 13
	ld c, 0x00:opc                                          ; FF7761  23 00
	pushw hl                                             ; FF7763  2b
	call T_Value_ApplyNibbleDeltaClamped                                        ; FF7764  1d 04 1b f4
	popw hl                                              ; FF7768  4b
	cp A,L                                               ; FF7769  cf f1
	jr z, .LFF7771                                       ; FF776B  66 04
	ld (UI_ScreenItem:16), a                                   ; FF776D  f1 20 27 41
.LFF7771:
	pop XDE                                              ; FF7771  5a
	pop XHL                                              ; FF7772  5b
	pop XIX                                              ; FF7773  5c
	pop XIZ                                              ; FF7774  5e
	ret                                                  ; FF7775  0e
; Disk_FormatSelectedEntry_SaveRegs: Disk_FormatSelectedEntry with XIX/XHL/XDE/XIZ kept.
Disk_FormatSelectedEntry_SaveRegs:
	push XIZ                                             ; FF7776  3e
	push XIX                                             ; FF7777  3c
	push XHL                                             ; FF7778  3b
	push XDE                                             ; FF7779  3a
	call Disk_FormatSelectedEntry                                      ; FF777A  1d 83 77 ff
	pop XDE                                              ; FF777E  5a
	pop XHL                                              ; FF777F  5b
	pop XIX                                              ; FF7780  5c
	pop XIZ                                              ; FF7781  5e
	ret                                                  ; FF7782  0e
; Disk_FormatSelectedEntry: UI_DrawScratch = entry word 0, ':', then the next 6 bytes of directory entry UI_ScreenItem.
Disk_FormatSelectedEntry:
	ld a, (UI_ScreenItem:16)                                   ; FF7783  c1 20 27 21
	call Disk_DirEntryPtr                                      ; FF7787  1d a7 77 ff
	ld XIX,UI_DrawScratch                                    ; FF778B  44 40 26 00 00
	ld WA,(XIY)                                          ; FF7790  95 20
	add IY,0x0002                                        ; FF7792  dd c8 02 00
	ld (XIX),WA                                          ; FF7796  b4 50
	add IX,0x0002                                        ; FF7798  dc c8 02 00
	ld (XIX),0x3a                                        ; FF779C  b4 00 3a
	inc 1,IX                                             ; FF779F  dc 61
	ldw bc, 0x03                                         ; FF77A1  31 03 00
	ldirw                                                ; FF77A4  95 11
	ret                                                  ; FF77A6  0e
; Disk_DirEntryPtr(A = index): XIY = 0x60A480 + 16 * min(A, 0x13), the directory entry (Disk_DrawDirectory20 draws from +2).
Disk_DirEntryPtr:
	pushw bc                                             ; FF77A7  29
	cp A,0x13                                            ; FF77A8  c9 cf 13
	jr ule, .LFF77AF                                     ; FF77AB  63 02
	ld a, 0x13:opc                                          ; FF77AD  21 13
.LFF77AF:
	ld c, 0x10:opc                                          ; FF77AF  23 10
	mul wa, c                                          ; FF77B1  cb 41
	ld XIY,0x0060a480                                    ; FF77B3  45 80 a4 60 00
	add IY,WA                                            ; FF77B8  d8 85
	popw bc                                              ; FF77BA  49
	ret                                                  ; FF77BB  0e
; Disk_SetStatusFromCheck(A): A = 1 -> UI_StatusCode 0x23, 4 -> 0x03, 0x2B -> 0x2B, each then UI_Request = 0x40AB; else nothing.
Disk_SetStatusFromCheck:
	cp a, 0x01:i3                                          ; FF77BC  c9 d9
	jr nz, .LFF77C7                                      ; FF77BE  6e 07
	ld (UI_StatusCode:16), 0x23                                 ; FF77C0  f1 80 28 00 23
	jr .LFF77DC                                          ; FF77C5  68 15
.LFF77C7:
	cp a, 0x04:i3                                          ; FF77C7  c9 dc
	jr nz, .LFF77D2                                      ; FF77C9  6e 07
	ld (UI_StatusCode:16), 0x03                                 ; FF77CB  f1 80 28 00 03
	jr .LFF77DC                                          ; FF77D0  68 0a
.LFF77D2:
	cp A,0x2b                                            ; FF77D2  c9 cf 2b
	jr nz, .LFF77E2                                      ; FF77D5  6e 0b
	ld (UI_StatusCode:16), 0x2b                                 ; FF77D7  f1 80 28 00 2b
.LFF77DC:
	ldw (UI_Request:16), 0x40ab                              ; FF77DC  f1 70 20 02 ab 40
.LFF77E2:
	ret                                                  ; FF77E2  0e
; Disk_CheckSelectedEntrySignature: with Disk_FileName saved, copies directory entry UI_ScreenItem into it, runs
;   T_DiskFile_CheckSignature, restores Disk_FileName and passes the result to Disk_SetStatusFromCheck.
Disk_CheckSelectedEntrySignature:
	push XIZ                                             ; FF77E3  3e
	push XIX                                             ; FF77E4  3c
	push XHL                                             ; FF77E5  3b
	push XDE                                             ; FF77E6  3a
	and	(UI_RequestBits:16), 0x6f                            ; FF77E7  c1 75 20 3c 6f
	ld XIX,Disk_FileName                                    ; FF77EC  44 c8 21 00 00
	pushw	(xix+0:8)                                    ; FF77F1  9c 00 04
	pushw	(xix+2)                                      ; FF77F4  9c 02 04
	pushw	(xix+4)                                      ; FF77F7  9c 04 04
	pushw	(xix+6)                                      ; FF77FA  9c 06 04
	ld a, (UI_ScreenItem:16)                                   ; FF77FD  c1 20 27 21
	ldw bc, 0x04                                         ; FF7801  31 04 00
	call Disk_CopyDirEntryToFileName                                      ; FF7804  1d 26 78 ff
	call T_DiskFile_CheckSignature                                        ; FF7808  1d 30 34 f4
	ld XIX,Disk_FileName                                    ; FF780C  44 c8 21 00 00
	popw	(xix+6)                                      ; FF7811  bc 06 06
	popw	(xix+4)                                      ; FF7814  bc 04 06
	popw	(xix+2)                                      ; FF7817  bc 02 06
	popw	(xix+0:8)                                    ; FF781A  bc 00 06
	call Disk_SetStatusFromCheck                                      ; FF781D  1d bc 77 ff
	pop XDE                                              ; FF7821  5a
	pop XHL                                              ; FF7822  5b
	pop XIX                                              ; FF7823  5c
	pop XIZ                                              ; FF7824  5e
	ret                                                  ; FF7825  0e
; Disk_CopyDirEntryToFileName(A = index, BC = words): ldirw from Disk_DirEntryPtr(A) to Disk_FileName.
Disk_CopyDirEntryToFileName:
	call Disk_DirEntryPtr                                      ; FF7826  1d a7 77 ff
	ld XIX,Disk_FileName                                    ; FF782A  44 c8 21 00 00
	ldirw                                                ; FF782F  95 11
	ret                                                  ; FF7831  0e
; Disk_CopyEntry2724HeadToFileName_SaveRegs: the first word of directory entry (0x2724) to Disk_FileName.
Disk_CopyEntry2724HeadToFileName_SaveRegs:
	push XIZ                                             ; FF7832  3e
	push XIX                                             ; FF7833  3c
	push XHL                                             ; FF7834  3b
	push XDE                                             ; FF7835  3a
	ld a, (Disk_SelectedEntry:16)                                   ; FF7836  c1 24 27 21
	ldw bc, 0x01                                         ; FF783A  31 01 00
	call Disk_CopyDirEntryToFileName                                      ; FF783D  1d 26 78 ff
	pop XDE                                              ; FF7841  5a
	pop XHL                                              ; FF7842  5b
	pop XIX                                              ; FF7843  5c
	pop XIZ                                              ; FF7844  5e
	ret                                                  ; FF7845  0e
; LCD_DrawVar272ENumberTag_SaveRegs(pos, row): draws DLText_F595CD[(0x272E)] (" 01:", " 02:" ...) on layer 0, SWI7 service 6.
LCD_DrawVar272ENumberTag_SaveRegs:
	push XIZ                                             ; FF7846  3e
	ld XIZ,XSP                                           ; FF7847  ef 8e
	push XIX                                             ; FF7849  3c
	push XHL                                             ; FF784A  3b
	push XDE                                             ; FF784B  3a
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF784C  f1 40 25 00 00
	ld IX,(XIZ+0x08)                                     ; FF7851  9e 08 24
	ld XIY,DLText_F595CD                                 ; FF7854  45 cd 95 f5 00
	ld XWA,0x00000000                                    ; FF7859  40 00 00 00 00
	ld a, (0x272e:16)                                   ; FF785E  c1 2e 27 21
	mul WA,0x0004                                        ; FF7862  d8 08 04 00
	add XIY,XWA                                          ; FF7866  e8 85
	ld HL,(XIZ+0x0a)                                     ; FF7868  9e 0a 23
	ldw bc, 0x04                                         ; FF786B  31 04 00
	ld a, 0x06:opc                                          ; FF786E  21 06
	swi 7                                                ; FF7870  ff
	pop XDE                                              ; FF7871  5a
	pop XHL                                              ; FF7872  5b
	pop XIX                                              ; FF7873  5c
	pop XIZ                                              ; FF7874  5e
	ret                                                  ; FF7875  0e
; LCD_DrawText16_SaveRegs(pos, text): 16 characters of text at pos on layer 0, SWI7 service 6.  No reference found
;   (no call site, no pointer in either ROM).
LCD_DrawText16_SaveRegs:
	push XIZ                                             ; FF7876  3e
	ld XIZ,XSP                                           ; FF7877  ef 8e
	push XIX                                             ; FF7879  3c
	push XHL                                             ; FF787A  3b
	push XDE                                             ; FF787B  3a
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF787C  f1 40 25 00 00
	ld IX,(XIZ+0x08)                                     ; FF7881  9e 08 24
	ld XIY,(XIZ+0x0a)                                    ; FF7884  ae 0a 25
	ldw hl, 0x00                                         ; FF7887  33 00 00
	ldw bc, 0x10                                         ; FF788A  31 10 00
	ld a, 0x06:opc                                          ; FF788D  21 06
	swi 7                                                ; FF788F  ff
	pop XDE                                              ; FF7890  5a
	pop XHL                                              ; FF7891  5b
	pop XIX                                              ; FF7892  5c
	pop XIZ                                              ; FF7893  5e
	ret                                                  ; FF7894  0e
; LCD_SwiTextCall_SaveRegs(text, -, pos, count, service): layer 0, then SWI7 with A = service; C-callable.
LCD_SwiTextCall_SaveRegs:
	push XIZ                                             ; FF7895  3e
	ld XIZ,XSP                                           ; FF7896  ef 8e
	push XIX                                             ; FF7898  3c
	push XHL                                             ; FF7899  3b
	push XDE                                             ; FF789A  3a
	ld (LCD_CurrentLayer:16), 0x00                                 ; FF789B  f1 40 25 00 00
	ld IX,(XIZ+0x0c)                                     ; FF78A0  9e 0c 24
	ld XIY,(XIZ+0x08)                                    ; FF78A3  ae 08 25
	ldw hl, 0x00                                         ; FF78A6  33 00 00
	ld BC,(XIZ+0x0e)                                     ; FF78A9  9e 0e 21
	ld WA,(XIZ+0x10)                                     ; FF78AC  9e 10 20
	swi 7                                                ; FF78AF  ff
	pop XDE                                              ; FF78B0  5a
	pop XHL                                              ; FF78B1  5b
	pop XIX                                              ; FF78B2  5c
	pop XIZ                                              ; FF78B3  5e
	ret                                                  ; FF78B4  0e
; MemCpy_C(dst, src, count): ldir (XIX+) <- (XIY+), count bytes; C-callable.
MemCpy_C:
	push XIZ                                             ; FF78B5  3e
	ld XIZ,XSP                                           ; FF78B6  ef 8e
	push XIX                                             ; FF78B8  3c
	ld BC,(XIZ+0x10)                                     ; FF78B9  9e 10 21
	extz XBC                                             ; FF78BC  e9 12
	ld XIX,(XIZ+0x08)                                    ; FF78BE  ae 08 24
	ld XIY,(XIZ+0x0c)                                    ; FF78C1  ae 0c 25
	ldir85                                               ; FF78C4  85 11
	pop XIX                                              ; FF78C6  5c
	pop XIZ                                              ; FF78C7  5e
	ret                                                  ; FF78C8  0e
; DiskSaveFile_Page3_LcdKeyRow1: the LcdKeyRow1 action of DiskSaveFile_Page3 -- called only by LcdKeyRow1_DiskSaveFile_Page3.
DiskSaveFile_Page3_LcdKeyRow1:
	push XIZ                                             ; FF78C9  3e
	push XIX                                             ; FF78CA  3c
	push XHL                                             ; FF78CB  3b
	push XDE                                             ; FF78CC  3a
	ld XIX,DiskSave_PasswordEntry                                    ; FF78CD  44 f0 22 00 00
	ld A,(XIX)                                           ; FF78D2  84 21
	ld (DiskSave_Password:16), a                                   ; FF78D4  f1 0f 22 41
	ld A,(XIX+0x01)                                      ; FF78D8  8c 01 21
	ld (DiskSave_Password+1:16), a                                   ; FF78DB  f1 10 22 41
	ld a, (Disk_SelectedEntry:16)                                   ; FF78DF  c1 24 27 21
	ldw bc, 0x01                                         ; FF78E3  31 01 00
	call Disk_CopyDirEntryToFileName                                      ; FF78E6  1d 26 78 ff
	call T_DiskSaveFile_SaveOrConfirmOverwrite_Call                                        ; FF78EA  1d 08 26 f4
	pop XDE                                              ; FF78EE  5a
	pop XHL                                              ; FF78EF  5b
	pop XIX                                              ; FF78F0  5c
	pop XIZ                                              ; FF78F1  5e
	ret                                                  ; FF78F2  0e
	push XIZ                                             ; FF78F3  3e
	ld XIZ,XSP                                           ; FF78F4  ef 8e
	push XIX                                             ; FF78F6  3c
	push XHL                                             ; FF78F7  3b
	push XDE                                             ; FF78F8  3a
	ld XIX,Disk_FileName                                    ; FF78F9  44 c8 21 00 00
	pushw	(xix+0:8)                                    ; FF78FE  9c 00 04
	pushw	(xix+2)                                      ; FF7901  9c 02 04
	pushw	(xix+4)                                      ; FF7904  9c 04 04
	pushw	(xix+6)                                      ; FF7907  9c 06 04
	ld a, (Disk_SelectedEntry:16)                                   ; FF790A  c1 24 27 21
	ldw bc, 0x04                                         ; FF790E  31 04 00
	call Disk_CopyDirEntryToFileName                                      ; FF7911  1d 26 78 ff
	ld XIY,Disk_FileName                                    ; FF7915  45 c8 21 00 00
	ldw wa, 0x3f3f                                       ; FF791A  30 3f 3f
	ld (XIY+0x08),WA                                     ; FF791D  bd 08 50
	ld a, 0x3f:opc                                          ; FF7920  21 3f
	ld (XIY+0x0a),A                                      ; FF7922  bd 0a 41
	call T_DiskApi_DeleteFile_Call                                        ; FF7925  1d b0 25 f4
	ld XIX,Disk_FileName                                    ; FF7929  44 c8 21 00 00
	popw	(xix+6)                                      ; FF792E  bc 06 06
	popw	(xix+4)                                      ; FF7931  bc 04 06
	popw	(xix+2)                                      ; FF7934  bc 02 06
	popw	(xix+0:8)                                    ; FF7937  bc 00 06
	pop XDE                                              ; FF793A  5a
	pop XHL                                              ; FF793B  5b
	pop XIX                                              ; FF793C  5c
	pop XIZ                                              ; FF793D  5e
	ret                                                  ; FF793E  0e
; MidiFileDirectPlay_SaveTrackToPartMap: Register-saving call of T_BStore_TrackToPart_SaveBackup -> prom_b BStore_TrackToPart_SaveBackup -> BStore_TrackToPart_CopyToBackup, which
;   copies the 17-byte BStore_TrackToPart map (0x603422) to its backup at 0x34BC. Paint_MidiFileDirectPlay (the
;   screen's ENTER) runs it on a real screen change, before the player's set-up rewrites the map. Basis: caller + body
;   (callee read). (notes/naming-pilot-2026-10-06/proposals_wave9_d9.json)
MidiFileDirectPlay_SaveTrackToPartMap:
	push XIZ                                             ; FF793F  3e
	push XIX                                             ; FF7940  3c
	push XHL                                             ; FF7941  3b
	push XDE                                             ; FF7942  3a
	call T_BStore_TrackToPart_SaveBackup                                        ; FF7943  1d ec 09 f4
	pop XDE                                              ; FF7947  5a
	pop XHL                                              ; FF7948  5b
	pop XIX                                              ; FF7949  5c
	pop XIZ                                              ; FF794A  5e
	ret                                                  ; FF794B  0e
; MidiFileDirectPlay_RestoreTrackToPartMap: Register-saving call of T_BStore_TrackToPart_RestoreBackup -> prom_b BStore_TrackToPart_RestoreBackup -> BStore_TrackToPart_CopyFromBackup, which
;   copies the 17-byte backup at 0x34BC back into BStore_TrackToPart (0x603422). ScreenLeave_MidiFileDirectPlay runs
;   it right after T_MidiFileDirectPlay_RestoreOnLeave; inverse of MidiFileDirectPlay_SaveTrackToPartMap. Basis:
;   caller + body (callee read) + inverse. (notes/naming-pilot-2026-10-06/proposals_wave9_d9.json)
MidiFileDirectPlay_RestoreTrackToPartMap:
	push XIZ                                             ; FF794C  3e
	push XIX                                             ; FF794D  3c
	push XHL                                             ; FF794E  3b
	push XDE                                             ; FF794F  3a
	call T_BStore_TrackToPart_RestoreBackup                                        ; FF7950  1d f0 09 f4
	pop XDE                                              ; FF7954  5a
	pop XHL                                              ; FF7955  5b
	pop XIX                                              ; FF7956  5c
	pop XIZ                                              ; FF7957  5e
	ret                                                  ; FF7958  0e
; SC1_CmdEFAndClearHeldButtons: T_F40F1C (SC1_Cmd_EF: empties SC1's receive ring, sends 0xEF then 0xE3 0x10) and
;   PanelButton_HeldMask := 0; what 0xEF asks of the SC1 peer is not established. The DISK / MIDI FILE L0AD and DISK
;   SAVE FILE execute keys call it right after the transfer. Basis: callers + body. (wsa1/notes/naming-
;   pilot-2026-10-06/proposals_prom_a.json)
SC1_CmdEFAndClearHeldButtons:
	push XIZ                                             ; FF7959  3e
	push XIX                                             ; FF795A  3c
	push XHL                                             ; FF795B  3b
	push XDE                                             ; FF795C  3a
	call T_F40F1C                                        ; FF795D  1d 1c 0f f4
	sub XBC,XBC                                          ; FF7961  e9 a1
	ld (PanelButton_HeldMask:16), xbc                                 ; FF7963  f1 88 20 61
	pop XDE                                              ; FF7967  5a
	pop XHL                                              ; FF7968  5b
	pop XIX                                              ; FF7969  5c
	pop XIZ                                              ; FF796A  5e
	ret                                                  ; FF796B  0e
; DiskScreen_LeaveOnScreenChange: Only when the screen really changed (UI_ScreenLatch != _Previous): Playback_AcceptMidiStartAndRequestPositionReset via
;   T_Playback_AcceptMidiStartAgain ((0x34BB) bits 2+3 cleared, (0x34D4) bit 4 set), (0x2094) bit 6 cleared, UI_ScreenPage := 0. Bit 6 makes
;   MIDI_RT_Received ignore real-time bytes; the disk/MIDI-file screens set it on entry. Shared Leave step of the
;   disk-file and L0AD SINGLE screens. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave2_e.json)
DiskScreen_LeaveOnScreenChange:
	push XIZ                                             ; FF796C  3e
	push XIX                                             ; FF796D  3c
	push XHL                                             ; FF796E  3b
	push XDE                                             ; FF796F  3a
	ld c, (UI_ScreenLatch:16)                                   ; FF7970  c1 7a 20 23
	cp	c, (UI_ScreenLatch_Previous:16)                               ; FF7974  c1 7b 20 f3
	jr z, .LFF7987                                       ; FF7978  66 0d
	call T_Playback_AcceptMidiStartAgain                                        ; FF797A  1d dc 25 f4
	res	6, (0x2094:16)                               ; FF797E  f1 94 20 b6
	ld (UI_ScreenPage:16), 0x00                                 ; FF7982  f1 29 22 00 00
.LFF7987:
	pop XDE                                              ; FF7987  5a
	pop XHL                                              ; FF7988  5b
	pop XIX                                              ; FF7989  5c
	pop XIZ                                              ; FF798A  5e
	ret                                                  ; FF798B  0e
; DiskFileScreen_LeaveCommon: the shared Leave of the disk file screens (ScreenLeave_MidiFileSave / _MidiFileL0ad /
;   _MidiFileDirectPlay / _DiskSaveFile): release port A3, DiskScreen_LeaveOnScreenChange, clear (0x220F) and (0x220C), set bit 4 of (0x34D4), clear bit 3 of (0x34BB).
DiskFileScreen_LeaveCommon:
	push XIZ                                             ; FF798C  3e
	push XIX                                             ; FF798D  3c
	push XHL                                             ; FF798E  3b
	push XDE                                             ; FF798F  3a
	call T_Disk_PortA3_Release_Call_Call                                        ; FF7990  1d 90 25 f4
	call DiskScreen_LeaveOnScreenChange                                      ; FF7994  1d 6c 79 ff
	ldw (DiskSave_Password:16), 0x00                                ; FF7998  f1 0f 22 02 00 00
	ld (DiskSave_PasswordUnlockCount:16), 0x00                                 ; FF799E  f1 0c 22 00 00
	or	(0x34d4:16), 0x10                            ; FF79A3  c1 d4 34 3e 10
	res	3, (0x34bb:16)                               ; FF79A8  f1 bb 34 b3
	pop XDE                                              ; FF79AC  5a
	pop XHL                                              ; FF79AD  5b
	pop XIX                                              ; FF79AE  5c
	pop XIZ                                              ; FF79AF  5e
	ret                                                  ; FF79B0  0e
; DiskSaveFile_Page4_LcdKeyRow1: the LcdKeyRow1 action of DiskSaveFile_Page4 -- called only by LcdKeyRow1_DiskSaveFile_Page4.
DiskSaveFile_Page4_LcdKeyRow1:
	push XIZ                                             ; FF79B1  3e
	push XIX                                             ; FF79B2  3c
	push XHL                                             ; FF79B3  3b
	push XDE                                             ; FF79B4  3a
	ld XIX,DiskSave_PasswordEntry                                    ; FF79B5  44 f0 22 00 00
	ld A,(XIX)                                           ; FF79BA  84 21
	ld (DiskSave_Password:16), a                                   ; FF79BC  f1 0f 22 41
	ld A,(XIX+0x01)                                      ; FF79C0  8c 01 21
	ld (DiskSave_Password+1:16), a                                   ; FF79C3  f1 10 22 41
	ld a, (Disk_SelectedEntry:16)                                   ; FF79C7  c1 24 27 21
	ldw bc, 0x01                                         ; FF79CB  31 01 00
	call Disk_CopyDirEntryToFileName                                      ; FF79CE  1d 26 78 ff
	call T_DiskSaveFile_CheckPasswordThenSave_Call                                        ; FF79D2  1d 0c 26 f4
	pop XDE                                              ; FF79D6  5a
	pop XHL                                              ; FF79D7  5b
	pop XIX                                              ; FF79D8  5c
	pop XIZ                                              ; FF79D9  5e
	ret                                                  ; FF79DA  0e
; Mode_SwitchToSound_SaveRegs2: Calls T_Mode_SwitchToSound (Mode_SwitchToSound) with XIZ, XIX, XIY, XHL and XDE saved
;   -- a second register-saving wrapper beside Mode_SwitchToSound_SaveRegs (which does not save XIY).
;   Paint_MidiFileDirectPlay calls it first on a real screen change. Basis: caller + body (wrapper; the tree's
;   _SaveRegs2 precedent). (notes/naming-pilot-2026-10-06/proposals_wave9_d9.json)
Mode_SwitchToSound_SaveRegs2:
	push XIZ                                             ; FF79DB  3e
	push XIX                                             ; FF79DC  3c
	push XIY                                             ; FF79DD  3d
	push XHL                                             ; FF79DE  3b
	push XDE                                             ; FF79DF  3a
	call T_Mode_SwitchToSound                                        ; FF79E0  1d c4 15 f4
	pop XDE                                              ; FF79E4  5a
	pop XHL                                              ; FF79E5  5b
	pop XIY                                              ; FF79E6  5d
	pop XIX                                              ; FF79E7  5c
	pop XIZ                                              ; FF79E8  5e
	ret                                                  ; FF79E9  0e
; ---------------------------------------------------------------------
; 0xFF79EA-0xFF7C64 -- 100 bytes of display-list-shaped records, then 535
; bytes of 0x00, after Mode_SwitchToSound_SaveRegs2's `ret`
;
; Was framed as code (`ld W,0x3A / ei 8 / swi 4 / call 0x20208E / ... /
; normal / normal`, then 535 `nop`).  It is not code: the byte before it is
; Mode_SwitchToSound_SaveRegs2's `ret`, no label lies inside, no branch in this source reaches
; it, and no 32-bit immediate or `.long` in prom_a or prom_b (hex or decimal)
; names an address in it (notes/proma-2026-09-25/retire_zero_runs.py).
; The first 100 bytes walk as display-list records -- `06 08`, `0a 0a` x2,
; `09 0a` x6, `02 0a` from 0xFF79EC, or `20 3a` then `09 0a` x2, `02 0a`
; from 0xFF79EA -- and both walks land exactly on 0xFF7A4E, where the
; zeros begin; which start is real is not established, so they stay `.byte`.
; ⚠ No reader is known for any of it.
; ---------------------------------------------------------------------
	.byte 0x20, 0x3a, 0x06, 0x08, 0xfc, 0x1d, 0x8e, 0x20, 0x20, 0x11, 0x0a, 0x0a, 0x0b, 0x00, 0x17, 0x00  ; FF79EA
	.byte 0x01, 0x01, 0xaf, 0x00, 0x0a, 0x0a, 0x0b, 0x00, 0xb7, 0x00, 0x01, 0x01, 0xcc, 0x00, 0x09, 0x0a  ; FF79FA
	.byte 0x0c, 0x01, 0x1c, 0x00, 0x34, 0x01, 0x2f, 0x00, 0x09, 0x0a, 0x0e, 0x01, 0x1e, 0x00, 0x32, 0x01  ; FF7A0A
	.byte 0x2d, 0x00, 0x09, 0x0a, 0x14, 0x01, 0x92, 0x00, 0x34, 0x01, 0xa5, 0x00, 0x09, 0x0a, 0x16, 0x01  ; FF7A1A
	.byte 0x94, 0x00, 0x32, 0x01, 0xa3, 0x00, 0x09, 0x0a, 0x14, 0x01, 0xba, 0x00, 0x34, 0x01, 0xcd, 0x00  ; FF7A2A
	.byte 0x09, 0x0a, 0x16, 0x01, 0xbc, 0x00, 0x32, 0x01, 0xcb, 0x00, 0x02, 0x0a, 0x85, 0x00, 0x17, 0x00  ; FF7A3A
	.byte 0x85, 0x00, 0xb1, 0x00  ; FF7A4A
	.fill 535, 1, 0x00                                 ; FF7A4E
	ret                                                  ; FF7C65  0e

; 0xFF7C66-0xFF7FFF -- 922 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 922, 1, 0x0E
