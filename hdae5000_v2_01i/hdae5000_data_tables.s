HDAE5000_UI_Config:
	; UI configuration strings
	.asciz "adraw"
	.asciz "auto_inc"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "dial"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "sel_num"
	.asciz "row"
	.asciz "column"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "str_adr"
	.asciz "main_func"
	.asciz "fontcolor"
	.asciz "font"
	.zero 3
	.asciz "fontcolor"
	.asciz "color"
	.zero 6
	.asciz "func"
	.zero 15
	.asciz "infocolor"
	.asciz "infofont"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "reversecolor"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "fontcolor"
	.asciz "font"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "pEnable"
	.zero 2
	.asciz "sel_pos"
	.asciz "sel_num"
	.asciz "dial"
	.byte 0x00

HDAE5000_RECORD_TABLE:
	; Record/entry data table -- CONFIRMED DATA, not code.
; ============================================================================
; HDAE5000_RECORD_TABLE  (0x29C0AA - 0x29D97D, 6,356 bytes)
; ============================================================================
; This span was previously disassembled as ~6,150 lines of TLCS-900 instruction
; mnemonics.  It is DATA.  The only reference to this address
; (hd-ae5000_v2_06i.s:312, `lda_24 xwa, (0x29c0aa)`) loads it as an ADDRESS for the
; "DISK MENU / UI" handler registration (see the Handler Registration Table just
; above HDAE5000_Handler_Registration in hd-ae5000_v2_06i.s); there is no call or
; jump site anywhere in the tree.  hdae5000_init_data.s:23 already documents the
; record layout below from the RAM-image side; this header confirms it against the
; raw ROM bytes and extends it to the full 6,356-byte span.
;
; DECOMPOSITION (confirmed byte-exact, see EVIDENCE below):
;   0x29C0AA-0x29C1E1   312 B   the 13 x 24-byte record array itself
;   0x29C1E2-0x29D8A9 5,832 B   all-zero reserved gap (verified, every byte 0x00)
;   0x29D8AA-0x29D97D   212 B   packed pool of the 26 NUL-terminated strings the
;                              records above point at (13 class names + 13
;                              parameter type-signature strings, in reverse record
;                              order, several signatures empty)
;
; RECORD LAYOUT (24 bytes), matching hdae5000_init_data.s:23-28:
;   +0x00  .long  ProcPtr        class procedure entry point (ROM); matches an
;                                already-named *Proc routine in this tree for all
;                                13 records (e.g. record 7 -> HDAE5000_TtlScreenR3Proc
;                                at 0x280645, byte-identical address)
;   +0x04  .long  parent         the parent CLASS ID (0x0160_00xx: a class of the main
;                                CPU's root class table, NAKA_CLASS_*) -- the class
;                                definition layout of the main CPU's class system
;                                (scripts/analysis/nakarest_objtab_map.py, THE CLASS
;                                SYSTEM): proc, parent, allsize, selfsize, name,
;                                propdata, propname.  Once Field_04 / Field_06
;                                (UNDECODED); decoded 2026-10-02.
;   +0x08  .short allsize        record size of an instance, the parent's included
;   +0x0A  .short selfsize       bytes this class adds (its own fields)
;                                Proved for all 13 by notes/hdae-class-records-2026-10-02/
;                                hdae_class_fields_probe.py: selfsize == the summed
;                                sizes of the signature's characters, and allsize ==
;                                the parent's allsize + selfsize.
;   +0x0C  .long  NamePtr        -> class name string, in the pool below
;   +0x10  .long  SigPtr         -> parameter type-signature string (may be empty);
;                                signature length == parameter count, matching
;                                hdae5000_init_data.s:26-28 exactly for all 13
;                                records (11,2,0,0,1,0,0,0,0,0,0,6,3)
;   +0x14  .long  ParamListPtr   RAM address of this class's parameter-name list,
;                                confirmed against hdae5000_init_data.s's own table:
;                                record 0's 0x23975A == the documented
;                                "0x2f96e2 -> 0x23975a, 13 lists" first entry
;
; EVIDENCE.  Every claim above is checked by the committed probe
; hdae5000/tools/verify_record_table.py, run from the repo root; it reads
; original_ROMs/hd-ae5000_v2_06i.ic4 at load base 0x280000 and nothing else:
;  * all 13 ProcPtr values land exactly on an already-named *Proc label's address
;  * the reserved gap (0x29C1E2-0x29D8A9) is 5,832 bytes of 0x00, no exception
;  * the string pool (0x29D8AA-0x29D97D) decomposes into exactly 26 NUL-terminated
;    runs with zero leftover bytes, and every NamePtr/SigPtr in the record array
;    resolves to the start of one of those runs
;  * SigPtr string length equals the parameter count already published in
;    hdae5000_init_data.s, for all 13 records with no exception
; ============================================================================

HDAE5000_Record_SelectList:	; class 'SelectList'
	.long HDAE5000_SelectListProc                     ; +0x00 ProcPtr (== named routine in this tree)
	.long NAKA_CLASS_VwBox		; +0x04 parent class
	.short 60, 32			; +0x08 allsize, +0x0A selfsize
	.long ClassName_SelectList                     ; +0x0C NamePtr  -> 'SelectList'
	.long ClassSig_SelectList                     ; +0x10 SigPtr   -> 'c^ksAAnGGmA' (11 params)
	.long HDAE5000_ParamNames_ListBox - HDAE5000_DataSegmentImage + HDAE5000_DATA_COPY_DEST	; +0x14 propname list (its RAM copy)

HDAE5000_Record_DbMemoCl:	; class 'DbMemoCl'
	.long HDAE5000_DbMemoClProc                     ; +0x00 ProcPtr (== named routine in this tree)
	.long NAKA_CLASS_DbMemo		; +0x04 parent class
	.short 26, 4			; +0x08 allsize, +0x0A selfsize
	.long ClassName_DbMemoCl                     ; +0x0C NamePtr  -> 'DbMemoCl'
	.long ClassSig_DbMemoCl                     ; +0x10 SigPtr   -> '^^' (2 params)
	.long HDAE5000_ParamNames_DbMemoCl - HDAE5000_DataSegmentImage + HDAE5000_DATA_COPY_DEST	; +0x14 propname list (its RAM copy)

HDAE5000_Record_TtlScreenR:	; class 'TtlScreenR'
	.long HDAE5000_TtlScreenRProc                     ; +0x00 ProcPtr (== named routine in this tree)
	.long NAKA_CLASS_TtlScreen		; +0x04 parent class
	.short 42, 0			; +0x08 allsize, +0x0A selfsize
	.long ClassName_TtlScreenR                     ; +0x0C NamePtr  -> 'TtlScreenR'
	.long ClassSig_TtlScreenR                     ; +0x10 SigPtr   -> '' (0 params)
	.long HDAE5000_ParamNames_TtlScreenR - HDAE5000_DataSegmentImage + HDAE5000_DATA_COPY_DEST	; +0x14 propname list (its RAM copy)

HDAE5000_Record_AcHddNamingWindow:	; class 'AcHddNamingWindow'
	.long HDAE5000_AcHddNamingWindowProc                     ; +0x00 ProcPtr (== named routine in this tree)
	.long NAKA_CLASS_Window		; +0x04 parent class
	.short 36, 0			; +0x08 allsize, +0x0A selfsize
	.long ClassName_AcHddNamingWindow                     ; +0x0C NamePtr  -> 'AcHddNamingWindow'
	.long ClassSig_AcHddNamingWindow                     ; +0x10 SigPtr   -> '' (0 params)
	.long HDAE5000_ParamNames_AcHddNamingWindow - HDAE5000_DataSegmentImage + HDAE5000_DATA_COPY_DEST	; +0x14 propname list (its RAM copy)

HDAE5000_Record_IvHddNaming:	; class 'IvHddNaming'
	.long HDAE5000_IvHddNamingProc                     ; +0x00 ProcPtr (== named routine in this tree)
	.long NAKA_CLASS_PsInvisibleBox		; +0x04 parent class
	.short 26, 4			; +0x08 allsize, +0x0A selfsize
	.long ClassName_IvHddNaming                     ; +0x0C NamePtr  -> 'IvHddNaming'
	.long ClassSig_IvHddNaming                     ; +0x10 SigPtr   -> 'j' (1 params)
	.long HDAE5000_ParamNames_IvHddNaming - HDAE5000_DataSegmentImage + HDAE5000_DATA_COPY_DEST	; +0x14 propname list (its RAM copy)

HDAE5000_Record_HDTitleMenu:	; class 'HDTitleMenu'
	.long HDAE5000_HDTitleMenuProc                     ; +0x00 ProcPtr (== named routine in this tree)
	.long NAKA_CLASS_AcTitleMenu		; +0x04 parent class
	.short 54, 0			; +0x08 allsize, +0x0A selfsize
	.long ClassName_HDTitleMenu                     ; +0x0C NamePtr  -> 'HDTitleMenu'
	.long ClassSig_HDTitleMenu                     ; +0x10 SigPtr   -> '' (0 params)
	.long HDAE5000_ParamNames_HDTitleMenu - HDAE5000_DataSegmentImage + HDAE5000_DATA_COPY_DEST	; +0x14 propname list (its RAM copy)

HDAE5000_Record_TtlScreenR2:	; class 'TtlScreenR2'
	.long HDAE5000_TtlScreenR2Proc                     ; +0x00 ProcPtr (== named routine in this tree)
	.long NAKA_CLASS_TtlScreen		; +0x04 parent class
	.short 42, 0			; +0x08 allsize, +0x0A selfsize
	.long ClassName_TtlScreenR2                     ; +0x0C NamePtr  -> 'TtlScreenR2'
	.long ClassSig_TtlScreenR2                     ; +0x10 SigPtr   -> '' (0 params)
	.long HDAE5000_ParamNames_TtlScreenR2 - HDAE5000_DataSegmentImage + HDAE5000_DATA_COPY_DEST	; +0x14 propname list (its RAM copy)

HDAE5000_Record_TtlScreenR3:	; class 'TtlScreenR3'
	.long HDAE5000_TtlScreenR3Proc                     ; +0x00 ProcPtr (== named routine in this tree)
	.long NAKA_CLASS_TtlScreen		; +0x04 parent class
	.short 42, 0			; +0x08 allsize, +0x0A selfsize
	.long ClassName_TtlScreenR3                     ; +0x0C NamePtr  -> 'TtlScreenR3'
	.long ClassSig_TtlScreenR3                     ; +0x10 SigPtr   -> '' (0 params)
	.long HDAE5000_ParamNames_TtlScreenR3 - HDAE5000_DataSegmentImage + HDAE5000_DATA_COPY_DEST	; +0x14 propname list (its RAM copy)

HDAE5000_Record_AcWindowPage1:	; class 'AcWindowPage1'
	.long HDAE5000_AcWindowPage1Proc                     ; +0x00 ProcPtr (== named routine in this tree)
	.long NAKA_CLASS_AcWindowPage		; +0x04 parent class
	.short 36, 0			; +0x08 allsize, +0x0A selfsize
	.long ClassName_AcWindowPage1                     ; +0x0C NamePtr  -> 'AcWindowPage1'
	.long ClassSig_AcWindowPage1                     ; +0x10 SigPtr   -> '' (0 params)
	.long HDAE5000_ParamNames_AcWindowPage1 - HDAE5000_DataSegmentImage + HDAE5000_DATA_COPY_DEST	; +0x14 propname list (its RAM copy)

HDAE5000_Record_IvScreenR2:	; class 'IvScreenR2'
	.long HDAE5000_IvScreenR2Proc                     ; +0x00 ProcPtr (== named routine in this tree)
	.long NAKA_CLASS_IvScreen		; +0x04 parent class
	.short 34, 0			; +0x08 allsize, +0x0A selfsize
	.long ClassName_IvScreenR2                     ; +0x0C NamePtr  -> 'IvScreenR2'
	.long ClassSig_IvScreenR2                     ; +0x10 SigPtr   -> '' (0 params)
	.long HDAE5000_ParamNames_IvScreenR2 - HDAE5000_DataSegmentImage + HDAE5000_DATA_COPY_DEST	; +0x14 propname list (its RAM copy)

HDAE5000_Record_AcLanguageText1:	; class 'AcLanguageText1'
	.long HDAE5000_AcLanguageText1Proc                     ; +0x00 ProcPtr (== named routine in this tree)
	.long NAKA_CLASS_AcLanguageText		; +0x04 parent class
	.short 42, 0			; +0x08 allsize, +0x0A selfsize
	.long ClassName_AcLanguageText1                     ; +0x0C NamePtr  -> 'AcLanguageText1'
	.long ClassSig_AcLanguageText1                     ; +0x10 SigPtr   -> '' (0 params)
	.long HDAE5000_ParamNames_AcLanguageText1 - HDAE5000_DataSegmentImage + HDAE5000_DATA_COPY_DEST	; +0x14 propname list (its RAM copy)

HDAE5000_Record_LyricBox:	; class 'LyricBox'
	.long HDAE5000_LyricBoxProc                     ; +0x00 ProcPtr (== named routine in this tree)
	.long NAKA_CLASS_VwBox		; +0x04 parent class
	.short 46, 18			; +0x08 allsize, +0x0A selfsize
	.long ClassName_LyricBox                     ; +0x0C NamePtr  -> 'LyricBox'
	.long ClassSig_LyricBox                     ; +0x10 SigPtr   -> 'mc^^c^' (6 params)
	.long HDAE5000_ParamNames_LyricBox - HDAE5000_DataSegmentImage + HDAE5000_DATA_COPY_DEST	; +0x14 propname list (its RAM copy)

HDAE5000_Record_FDFileSelect:	; class 'FDFileSelect'
	.long HDAE5000_FDFileSelectProc                     ; +0x00 ProcPtr (== named routine in this tree)
	.long NAKA_CLASS_PsInvisibleBox		; +0x04 parent class
	.short 32, 10			; +0x08 allsize, +0x0A selfsize
	.long ClassName_FDFileSelect                     ; +0x0C NamePtr  -> 'FDFileSelect'
	.long ClassSig_FDFileSelect                     ; +0x10 SigPtr   -> 'Gnn' (3 params)
	.long HDAE5000_ParamNames_FDFileSelect - HDAE5000_DataSegmentImage + HDAE5000_DATA_COPY_DEST	; +0x14 propname list (its RAM copy)

; ---------------------------------------------------------------------------
; reserved gap: 5832 bytes, all 0x00 (verified above)
; ---------------------------------------------------------------------------
.zero 5832

; ---------------------------------------------------------------------------
; string pool referenced by NamePtr/SigPtr above, in reverse record order
; ---------------------------------------------------------------------------
ClassSig_FDFileSelect:
	.asciz "Gnn"			; 0x29D14A
ClassName_FDFileSelect:
	.asciz "FDFileSelect"			; 0x29D14E
	.zero 1			; 0x29D8BB (unreferenced pad)
ClassSig_LyricBox:
	.asciz "mc^^c^"			; 0x29D15C
	.zero 1			; 0x29D8C3 (unreferenced pad)
ClassName_LyricBox:
	.asciz "LyricBox"			; 0x29D164
	.zero 1			; 0x29D8CD (unreferenced pad)
ClassSig_AcLanguageText1:
	.byte 0x00			; 0x29D16E (SigPtr target of AcLanguageText1, empty signature)
	.zero 1			; 0x29D8CF (unreferenced pad)
ClassName_AcLanguageText1:
	.asciz "AcLanguageText1"			; 0x29D170
ClassSig_IvScreenR2:
	.byte 0x00			; 0x29D180 (SigPtr target of IvScreenR2, empty signature)
	.zero 1			; 0x29D8E1 (unreferenced pad)
ClassName_IvScreenR2:
	.asciz "IvScreenR2"			; 0x29D182
	.zero 1			; 0x29D8ED (unreferenced pad)
ClassSig_AcWindowPage1:
	.byte 0x00			; 0x29D8EE (SigPtr target of AcWindowPage1, empty signature)
	.zero 1			; 0x29D8EF (unreferenced pad)
ClassName_AcWindowPage1:
	.asciz "AcWindowPage1"			; 0x29D190
ClassSig_TtlScreenR3:
	.byte 0x00			; 0x29D19E (SigPtr target of TtlScreenR3, empty signature)
	.zero 1			; 0x29D8FF (unreferenced pad)
ClassName_TtlScreenR3:
	.asciz "TtlScreenR3"			; 0x29D1A0
ClassSig_TtlScreenR2:
	.byte 0x00			; 0x29D1AC (SigPtr target of TtlScreenR2, empty signature)
	.zero 1			; 0x29D90D (unreferenced pad)
ClassName_TtlScreenR2:
	.asciz "TtlScreenR2"			; 0x29D1AE
ClassSig_HDTitleMenu:
	.byte 0x00			; 0x29D1BA (SigPtr target of HDTitleMenu, empty signature)
	.zero 1			; 0x29D91B (unreferenced pad)
ClassName_HDTitleMenu:
	.asciz "HDTitleMenu"			; 0x29D1BC
ClassSig_IvHddNaming:
	.asciz "j"			; 0x29D1C8
ClassName_IvHddNaming:
	.asciz "IvHddNaming"			; 0x29D1CA
ClassSig_AcHddNamingWindow:
	.byte 0x00			; 0x29D1D6 (SigPtr target of AcHddNamingWindow, empty signature)
	.zero 1			; 0x29D937 (unreferenced pad)
ClassName_AcHddNamingWindow:
	.asciz "AcHddNamingWindow"			; 0x29D1D8
ClassSig_TtlScreenR:
	.byte 0x00			; 0x29D1EA (SigPtr target of TtlScreenR, empty signature)
	.zero 1			; 0x29D94B (unreferenced pad)
ClassName_TtlScreenR:
	.asciz "TtlScreenR"			; 0x29D1EC
	.zero 1			; 0x29D957 (unreferenced pad)
ClassSig_DbMemoCl:
	.asciz "^^"			; 0x29D958
	.zero 1			; 0x29D95B (unreferenced pad)
ClassName_DbMemoCl:
	.asciz "DbMemoCl"			; 0x29D1FC
	.zero 1			; 0x29D965 (unreferenced pad)
ClassSig_SelectList:
	.asciz "c^ksAAnGGmA"			; 0x29D206
ClassName_SelectList:
	.asciz "SelectList"			; 0x29D212
	.zero 1			; 0x29D97D (unreferenced pad)
HDAE5000_RECORD_COUNT:
	; Record count data
	.byte 0x0d, 0x00                       ; u16 count = 13 (LE); matches HDAE5000_RECORD_TABLE's 13
	                                       ; records and the 13 UI class procedures/names
	                                       ; hdae5000_init_data.s documents at 0x2f97fa/0x2f9832.
	                                       ; hd-ae5000_v2_06i.s:310 `ldw_da xwa, (0x29d97e)` reads
	                                       ; this exact word -- NOT alignment padding, real data;
	                                       ; it also happens to word-align the string pool below.
	.asciz "EV_DrawFDText"
	.asciz "EV_InitFDFileSelect"
	.asciz "EV_Scrollline"
	.asciz "EV_Drawsyllable"
	.asciz "EV_Alldraw"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "EV_Initlyrics"
	.asciz "EV_SETPOSITION"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "EV_BEATMESSAGE"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "EV_TICKS"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "EV_INITLYRICPARAM"
	.asciz "EV_TimerBack"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "EV_AfterLoad"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "EV_SeqStop"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "MT_FdSaveLyric"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "MT_FdLoadLyric"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "MT_FdInfo"
	.asciz "MT_FdFreshUp"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "MT_SelectDelFile"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "MT_SelectDEL"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "MT_LOOP"
	.asciz "MT_SetStrAdr"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "MT_SelectAll"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "MT_SelectSAVE"
	.asciz "MT_SelectOK2"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "MT_SelectOK"
	.asciz "MT_AckSelNum"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "MT_ReqSelNum"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "MT_SetSelNum"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "MT_ChangeSelNum"
	.asciz "MT_UnderFlow"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "MT_OverFlow"
	.zero 2
	.asciz "FDFileSelectProc"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "LyricBoxProc"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "AcLanguageText1Proc"
	.asciz "IvScreenR2Proc"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "AcWindowPage1Proc"
	.asciz "TtlScreenR3Proc"
	.asciz "TtlScreenR2Proc"
	.asciz "HDTitleMenuProc"
	.asciz "IvHddNamingProc"
	.asciz "AcHddNamingWindowProc"
	.asciz "TtlScreenRProc"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "DbMemoClProc"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "SelectListProc"
	.balign 2, 0x00                       ; word-align pad to the pool boundary 0x29D4B2 (see the
	                                       ; "HD-AE5000 UI OBJECT DESCRIPTOR POOL" header just below)

	.include	"hdae5000_ui_tree.s"	; the GUI: objects, object / name tables, names


; ============================================================================
; HD-AE5000 GRAPHICS BANK -- 256-colour palettes and 8bpp indexed bitmaps
; ROM 0x2A849A - 0x2E1C81.  (A fifth palette/bitmap pair, the boot splash,
; sits further down at 0x2E5DCE - 0x2F8DCD under HDAE5000_Palette_BootSplash.)
;
; Layout rule, taken from the copy code inside HDAE5000_UiState_Reset and
; [the addresses below (0x2804BB..) are in the title-screen procedures
;  HDAE5000_TtlScreenRProc / _TtlScreenR2Proc / _TtlScreenR3Proc, which sat in
;  the conversion region once labelled Register_Frame -- now the small
;  HDAE5000_UiState_Reset]
; confirmed byte-wise over the whole region: every bitmap is immediately
; preceded by its own palette, with no padding between the two.
;   * a palette is 0x400 bytes = 256 RGBX entries.  Byte 3 of every entry is
;     0x00 in all five palettes of this ROM (checked exhaustively, 5 x 256).
;   * a full-screen bitmap is 0x12C00 bytes = 320 x 240 at 8 bits per pixel.
;
; The firmware never moves a full-screen bitmap in one go.  It issues two
; 0x9600-byte MemCopy calls (top half -> 0x056800, bottom half -> 0x05FE00)
; and then a 0x400-byte copy of the palette -> 0x069400.  Those hard-coded
; source addresses are the primary evidence for the boundaries below:
;
;   0x2804BB  lda XWA,0x2A898E   0x9600 -> 0x056800   ] bitmap 1, top half
;   0x2804CE  lda XWA,0x2B1F8E   0x9600 -> 0x05FE00   ] bitmap 1, bottom half
;   0x2804E1  lda XWA,0x2A858E   0x0400 -> 0x069400   ] palette 1
;   0x280599 / 0x2805AC / 0x2805BF   same shape: bitmap 2 halves + palette 2
;   0x280677 / 0x28068A / 0x28069D   same shape: bitmap 3 halves + palette 3
;   0x280753  reloads palette 2 on its own (0x400 -> 0x069400)
;
; The lookup routines hand the same bases, plus the dimensions, to the main
; CPU (request type A1 = base address, A2 = width, A3 = height):
;
;   0x28032A  HDAE5000_Alloc_Memory_1 -> 0x2A898E, 0x140 (320) x 0xF0 (240)
;   0x280357  HDAE5000_Alloc_Memory_2 -> 0x2BB98E, 0x140 x 0xF0
;   0x280384  HDAE5000_Alloc_Memory_3 -> 0x2CE98E, 0x140 x 0xF0
;   0x2803B1  HDAE5000_BitmapHdd_icon -> 0x2E198E, 0x1B (27) x 0x1B (27)
;   0x28F55F  HDAE5000_Alloc_Memory   -> 0x2E61CE, 0x140 x 0xF0 (boot splash)
;
; Only the fourth of these carries a name from the firmware: it is entry 39 of
; HDAE5000_ObjHandler_Table and the parallel HDAE5000_ObjName_Table entry reads
; "BitmapHdd_icon".  The other four appear in no registry table, so they keep
; the Alloc_Memory_* labels for now -- they allocate nothing either.
;
; RETIRED LABEL -- HDAE5000_Font_Data, "Font bitmap data (large block)",
; formerly covering 0x2BA1A6-0x2E1C81.  It was wrong twice over: the region
; holds no font data at all (it is three palette+bitmap pairs and an icon),
; and 0x2BA1A6 falls 0x11818 bytes INSIDE bitmap 1, so the old slice cut a
; picture in half and the following slice began mid-picture.  The old name is
; kept in this comment only, so that greps for it still land here.
; ============================================================================

HDAE5000_GFX_INIT_PARAMS:
	; MISNOMER retained for cross-reference (it is the name the ASL mirror
	; and symbols/hdae5000_symbols_reference.txt already use).  This is not
	; a graphics parameter block: it is the NUL-terminated name table for
	; the HD-AE5000 screens and switch-catch handlers.  "TT_HDDEXT" is
	; passed by the lda at 0x2802E4; the other fourteen names are reached
	; through the descending 32-bit pointer table at 0x2F9F96..0x2F9FD1,
	; inside HDAE5000_DataSegmentImage.  Pointer -> string:
	;   0x2F9F96 -> 0x2A8580   0x2F9F9A -> 0x2A8570   0x2F9F9E -> 0x2A855E
	;   0x2F9FA2 -> 0x2A854A   0x2F9FA6 -> 0x2A853A   0x2F9FAA -> 0x2A852A
	;   0x2F9FAE -> 0x2A851C   0x2F9FB2 -> 0x2A850E   0x2F9FB6 -> 0x2A84FE
	;   0x2F9FBA -> 0x2A84EC   0x2F9FBE -> 0x2A84DC   0x2F9FC2 -> 0x2A84C6
	;   0x2F9FC6 -> 0x2A84B6   0x2F9FCA -> 0x2A84A6   0x2F9FCE -> 0x2A84A4
	.asciz "TT_HDDEXT"		; 0x2A7CA8  (from 0x2802E4)
	.byte 0x00			; 0x2A7CB2  empty name, target of 0x2F9FCE
	.byte 0x00			; 0x2A84A5  pad
	.asciz "FileLoadSwCatch"	; 0x2A7CB4
	.asciz "HDDTitleSwCatch"	; 0x2A7CC4
	.asciz "CopyToHDDirSelScreen"	; 0x2A7CD4
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "CopyToHDScreen"	; 0x2A7CEA
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "FlsFileSelScreen"	; 0x2A7CFA
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "FlsDirSelScreen"	; 0x2A7D0C
	.asciz "FlsEditScreen"		; 0x2A7D1C
	.asciz "FlsLoadScreen"		; 0x2A7D2A
	.asciz "SelectFlsScreen"	; 0x2A7D38
	.asciz "SetupP2SwCatch"	; 0x2A7D48
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "FILE_Naming_Screen"	; 0x2A7D58
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "FILE_LOAD_Screen"	; 0x2A7D6C
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "SEL_DIR_Screen"	; 0x2A7D7E
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	.asciz "HDAETitleFunc"		; 0x2A7D8E

HDAE5000_Palette_TitleLogo:
	; 0x400 B = 256 RGBX entries, 205 distinct colours.  Copied to 0x069400
	; by the lda at 0x2804E1.  Byte-identical to HDAE5000_Palette_DriveMech
	; (0x2BB58E) -- the two title frames share one palette.
	; Built from images/HDAE5000_Palette_Logo.txt by scripts/build/hdae5000_images.py.
	; Was: .incbin "includes/code_29af2d_2fffff.bin", 54881, 1024
	.incbin "includes/generated/HDAE5000_Palette_Logo.bin"

HDAE5000_Bitmap_TitleLogo:
	; 320 x 240 @ 8bpp = 0x12C00 B.  The "HD-AE5000" wordmark embossed over
	; a photograph of a bare hard-disk mechanism.  Moved as two halves,
	; 0x2A898E -> 0x056800 and 0x2B1F8E -> 0x05FE00.  Already extracted as
	; hdae5000/images/HDAE5000_Logo.bin (byte-identical to this slice).
	; Built from images/HDAE5000_Logo.png by scripts/build/hdae5000_images.py.
	; Was: .incbin "includes/code_29af2d_2fffff.bin", 55905, 76800
	.incbin "includes/generated/HDAE5000_Logo.bin"

HDAE5000_Palette_DriveMech:
	; 0x400 B = 256 RGBX entries.  Copied to 0x069400 by 0x2805BF, and again
	; on its own by 0x280753.  Byte-identical to HDAE5000_Palette_TitleLogo.
	; Built from images/HDAE5000_Palette_Hands.txt by scripts/build/hdae5000_images.py.
	; Was: .incbin "includes/code_29af2d_2fffff.bin", 132705, 1024
	.incbin "includes/generated/HDAE5000_Palette_Hands.bin"

HDAE5000_Bitmap_DriveMech:
	; 320 x 240 @ 8bpp.  The same drive-mechanism photograph WITHOUT the
	; wordmark -- the second frame of the title sequence.  Halves at
	; 0x2BB98E and 0x2C4F8E.  Extracted as images/HDAE5000_Hands.bin, whose
	; "Hands operating HD-AE5000 unit" caption is wrong: no hands appear in
	; the picture (see the hdae-docs / gallery follow-up).
	; Built from images/HDAE5000_Hands.png by scripts/build/hdae5000_images.py.
	; Was: .incbin "includes/code_29af2d_2fffff.bin", 133729, 76800
	.incbin "includes/generated/HDAE5000_Hands.bin"

HDAE5000_Palette_FilePanel:
	; v2.01i's own palette for its own backdrop below (v2.06i's differs in
	; 326 of the 1,024 bytes).  Built from
	; hdae5000_v2_01i/images/HDAE5000_Palette_FilePanel_v2_01i.txt by
	; scripts/build/hdae5000_images.py.
	.incbin "includes/generated/HDAE5000_Palette_FilePanel_v2_01i.bin"

HDAE5000_Bitmap_FilePanel:
	; 320 x 240 @ 8bpp.  The file-selection panel background, as v2.01i draws
	; it: the same three sunken list wells as v2.06i's, but over a magenta
	; marble fill instead of a plain dark one, and with five buttons in the
	; grey strip along the bottom where v2.06i has three.  Built from
	; hdae5000_v2_01i/images/HDAE5000_FilePanel_v2_01i.png by
	; scripts/build/hdae5000_images.py.
	.incbin "includes/generated/HDAE5000_FilePanel_v2_01i.bin"

HDAE5000_Palette_HddIcon:
	; 0x400 B = 256 RGBX entries, all 256 distinct -- the Windows halftone
	; palette.  It has no lda site of its own in this ROM; it pairs with the
	; icon that follows by the same "palette immediately before the bitmap"
	; rule as the four pairs above, and the pairing is visually decisive:
	; the icon uses only indices 0/1/3/7/248/251/252/255 (the Windows
	; reserved entries at both ends) and is legible with this palette only.
	; Extracted as images/HDAE5000_Palette.bin.
	; Built from images/HDAE5000_Palette_Icon.txt by scripts/build/hdae5000_images.py.
	; Was: .incbin "includes/code_29af2d_2fffff.bin", 288353, 1024
	.incbin "includes/generated/HDAE5000_Palette_Icon.bin"

HDAE5000_Bitmap_HddIcon:
	; 27 x 27 @ 8bpp with a 28-byte row stride (one 0x00 pad byte at the end
	; of every row) = 756 B: the hard-disk-platter-and-head icon.  The
	; 27 x 27 geometry is HDAE5000_BitmapHdd_icon (0x2803B1) returning 0x1B
	; for BOTH the A2 (width) and A3 (height) requests.
	; NOTE hdae5000/images/HDAE5000_Icon.bin is 784 B: its extraction
	; assumed 28 x 28 and over-reads 28 bytes into HDAE5000_Config_Strings.
	; Built from images/HDAE5000_Icon.png by scripts/build/hdae5000_images.py.
	; Was: .incbin "includes/code_29af2d_2fffff.bin", 289377, 756
	.incbin "includes/generated/HDAE5000_Icon.bin"

; ============================================================================
; HD-AE5000 PROGRAM .RODATA, 0x2E1C82-0x2E3703 (the C program's read-only data)
; Rebuilt object by object by scripts/generators/gen_hdae5000_rodata.py: every
; object starts at an address the code names (lda / ld # / ld (mem) / add #
; operands and pushw 0x002e/low pairs) or that a pointer table here points
; at, and its note names the routines that read it.  String-pointer tables
; are `.long <label>`; the compiled `switch` tables (their own headers) are
; kept from scripts/converters/hdae5000_switch_tables.py.  This replaces six
; coarse blocks named by guess (HDAE5000_Config_Strings, _Test_Strings,
; _Dir_Strings, _Char_Tables, _Path_Strings, _UI_Icons) whose bytes were
; typed as text throughout.
; ============================================================================
HDAE5000_Str_V201i:
	; read by CopyVersionString at 0x28B20D (ld #, pushed operand)
	.asciz "V2.01i"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_TypeSel_TemplateAllNo:
	; read by FILE_LOAD_Screen, HDDNamingCheck, SaveOptSwEventCatch at 0x283E0A (lda operand)
	; a part-selection record template (HDAE5000_TypeSel_Init copies 12 bytes: u16 mask, nine part flags, pad): mask 0, every flag 1 ("NO ")
	.byte 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00
HDAE5000_TypeSel_TemplateBlank:
	; read by FILE_LOAD_Screen, FlsFileSelScreen, LBNLoadSwCatch, Lbn_StepDigit, Lbn_TypeDigit, UiState_Reset at 0x2803E5 (ld #, lda operand)
	; a part-selection record template: mask 0, every flag 0 ("---")
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
HDAE5000_Lbn_BlockTemplate:
	; read by UiState_Reset at 0x2803D7 (ld # operand)
	; the 10-byte load-by-number block copied to 0x22AA58 by HDAE5000_UiState_Reset (5 words, all 0)
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
HDAE5000_Str_Blank3Tab:
	; read by Lbn_ShowEntry at 0x287104 (lda operand)
	.asciz "   \t"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Blank16Tab:
	; read by Lbn_ShowEntry at 0x287117 (lda operand)
	.asciz "                \t"
HDAE5000_Str_Blank3Tab_Lbn_ShowEntry:
	; read by Lbn_ShowEntry at 0x28712A (lda operand)
	.asciz "   \t"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Blank26Tab:
	; read by Lbn_ShowEntry at 0x287140 (lda operand)
	.asciz "                          \t"
HDAE5000_Str_Blank12Tab:
	; read by FdList_Clear at 0x282D31 (lda operand)
	.asciz "            \t"
HDAE5000_FdList_RowsTemplate:
	; read by FdList_Clear at 0x282D89 (lda operand)
	.asciz "01:        \t02:        \t03:        \t04:        \t05:        \t06:        \t07:        \t08:        \t09:        \t10:        \t11:        \t12:        \t13:        \t14:        \t15:        \t16:        \t17:        \t18:        \t19:        \t20:        \t"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_STATUS:
	; read by HDAETitleFunc at 0x2835EB (lda operand)
	.asciz "STATUS:                        \t"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_DelOpt_TemplateBlank:
	; read by DelOptSwEventCatch, DelOpt_InitFromSong at 0x28A577 (lda operand)
	; the delete-option record template: mask 0, every flag 0 ("---")
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL:	; 3 x .long -> string
	; read by DelCmpEditCheck, DelLswEditCheck, DelMdEditCheck, DelMspEditCheck, DelOpt_ShowFlags, DelPmtEditCheck, DelRcmEditCheck, DelSqtEditCheck, DelTlxEditCheck, DelTmEditCheck at 0x28A2FA (ld #, lda operand); 3 string pointers, 4 bytes each, entry i at +4*i
	.long	HDAE5000_Str_Chr2D2D2D
	.long	HDAE5000_Str_OFF
	.long	HDAE5000_Str_DEL
HDAE5000_Str_DEL:
	; pointed at by entry 2 of HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL, a table read by DelCmpEditCheck, DelLswEditCheck, DelMdEditCheck, DelMspEditCheck, DelOpt_ShowFlags, DelPmtEditCheck, DelRcmEditCheck, DelSqtEditCheck, DelTlxEditCheck, DelTmEditCheck
	.asciz "DEL"
HDAE5000_Str_OFF:
	; pointed at by entry 1 of HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL, a table read by DelCmpEditCheck, DelLswEditCheck, DelMdEditCheck, DelMspEditCheck, DelOpt_ShowFlags, DelPmtEditCheck, DelRcmEditCheck, DelSqtEditCheck, DelTlxEditCheck, DelTmEditCheck
	.asciz "OFF"
HDAE5000_Str_Chr2D2D2D:
	; pointed at by entry 0 of HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL, a table read by DelCmpEditCheck, DelLswEditCheck, DelMdEditCheck, DelMspEditCheck, DelOpt_ShowFlags, DelPmtEditCheck, DelRcmEditCheck, DelSqtEditCheck, DelTlxEditCheck, DelTmEditCheck
	.asciz "---"
; HDAE5000_Str_HdFormatCode: "050354": the six-digit code that, typed on the ATTEN_HD_FORMAT dialog, makes
;   HDAE5000_FormatDialog_CodeDigit return 2, on which HDAE5000_AttenHDFormatSwCatch shows WAIT_HD_FORMAT and formats
;   the hard disk. Basis: StrPrefixCmp in CodeDigit + the result-2 branch.
HDAE5000_Str_HdFormatCode:
	; read by FormatDialog_CodeDigit at 0x286617 (pushed operand)
	.asciz "050354"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
; HDAE5000_Str_Track0RecoverCode: "965768": the six-digit code that, typed on the ATTEN_HD_FORMAT dialog, makes
;   HDAE5000_FormatDialog_CodeDigit return 3, on which HDAE5000_AttenHDFormatSwCatch shows WAIT_TR0_RECOVER ("Track O
;   will be recovered:") and rewrites the settings sector. Basis: StrPrefixCmp in CodeDigit + the result-3 branch.
HDAE5000_Str_Track0RecoverCode:
	; read by FormatDialog_CodeDigit at 0x286631 (pushed operand)
	.asciz "965768"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_TextPtrs_OFF_ON:	; 2 x .long -> string
	; read by TitleInfo_Build, WriteConfirmEditCheck, WriteProtectEditCheck at 0x283313 (ld #, lda operand); 2 string pointers, 4 bytes each, entry i at +4*i
	.long	HDAE5000_Str_OFF_2
	.long	HDAE5000_Str_ON
HDAE5000_Str_ON:
	; pointed at by entry 1 of HDAE5000_TextPtrs_OFF_ON, a table read by TitleInfo_Build, WriteConfirmEditCheck, WriteProtectEditCheck
	.asciz "ON "
HDAE5000_Str_OFF_2:
	; pointed at by entry 0 of HDAE5000_TextPtrs_OFF_ON, a table read by TitleInfo_Build, WriteConfirmEditCheck, WriteProtectEditCheck
	.asciz "OFF"
HDAE5000_TextPtrs_01Selectlist0203040506070809:	; 1 x .long -> string
	; read by SelectListProc at 0x280AB3 (ld (mem) operand); 1 string pointer, 4 bytes each, entry i at +4*i
	.long	HDAE5000_SelectList_Text
HDAE5000_SelectList_Text:
	; pointed at by entry 0 of HDAE5000_TextPtrs_01Selectlist0203040506070809, a table read by SelectListProc
	.asciz "01:SelectList\t02\t03\t04\t05\t06\t07\t08\t09\t10\t11\t12\t13\t14\t15\t16\t17\t18\t19\t20\t21\t22\t23\t24\t25\t26\t27\t28\t29\t30"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_DebugTime:
	; read by DbMemoClProc at 0x2812CA (lda operand)
	.asciz "Debug Time!"
HDAE5000_TextPtrs_ABC123_Abc123_Chr202123242526:	; 3 x .long -> string
	; read by AcHddNamingWindowProc at 0x28228E (ld # operand); 3 string pointers, 4 bytes each, entry i at +4*i
	.long	HDAE5000_Str_NamingPageUpperCase
	.long	HDAE5000_Str_Abc123
	.long	HDAE5000_Str_Chr202123242526
HDAE5000_Str_Chr202123242526:
	; pointed at by entry 2 of HDAE5000_TextPtrs_ABC123_Abc123_Chr202123242526, a table read by AcHddNamingWindowProc
	.asciz " !#$%&?.... "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Abc123:
	; pointed at by entry 1 of HDAE5000_TextPtrs_ABC123_Abc123_Chr202123242526, a table read by AcHddNamingWindowProc
	.asciz "abc...123..."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
; HDAE5000_Str_NamingPageUpperCase: "ABC...123...": caption of character page 0 (upper case + digits) of the HDD
;   naming window, drawn into HddNamingLabel. Basis: entry 0 of the 3-entry caption table that
;   HDAE5000_AcHddNamingWindowProc indexes by the page number (0x22A02A).
HDAE5000_Str_NamingPageUpperCase:
	; pointed at by entry 0 of HDAE5000_TextPtrs_ABC123_Abc123_Chr202123242526, a table read by AcHddNamingWindowProc
	.asciz "ABC...123..."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_TextPtrs_A_to_SPC:	; 38 x .long -> string
	; pointed at by entry 0 of HDAE5000_TablePtrs_AcHddNamingWindowProc, a table read by AcHddNamingWindowProc; 38 string pointers, 4 bytes each, entry i at +4*i
	.long	HDAE5000_Str_A
	.long	HDAE5000_Str_B
	.long	HDAE5000_Str_C
	.long	HDAE5000_Str_D
	.long	HDAE5000_Str_E
	.long	HDAE5000_Str_F
	.long	HDAE5000_Str_G
	.long	HDAE5000_Str_H
	.long	HDAE5000_Str_I
	.long	HDAE5000_Str_J
	.long	HDAE5000_Str_K
	.long	HDAE5000_Str_L
	.long	HDAE5000_Str_M
	.long	HDAE5000_Str_N
	.long	HDAE5000_Str_O
	.long	HDAE5000_Str_P
	.long	HDAE5000_Str_Q
	.long	HDAE5000_Str_R
	.long	HDAE5000_Str_S
	.long	HDAE5000_Str_T
	.long	HDAE5000_Str_U
	.long	HDAE5000_Str_V
	.long	HDAE5000_Str_W
	.long	HDAE5000_Str_X
	.long	HDAE5000_Str_Y
	.long	HDAE5000_Str_Z
	.long	HDAE5000_Str_Chr5F
	.long	HDAE5000_Str_0
	.long	HDAE5000_Str_1
	.long	HDAE5000_Str_2
	.long	HDAE5000_Str_3
	.long	HDAE5000_Str_4
	.long	HDAE5000_Str_5
	.long	HDAE5000_Str_6
	.long	HDAE5000_Str_7
	.long	HDAE5000_Str_8
	.long	HDAE5000_Str_9
	.long	HDAE5000_Str_SPC
	.byte 0xa2, 0x17
	.asciz "."
	.zero 2
HDAE5000_Str_SPC:
	; pointed at by entry 37 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "SPC"
HDAE5000_Str_9:
	; pointed at by entry 36 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "9"
HDAE5000_Str_8:
	; pointed at by entry 35 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "8"
HDAE5000_Str_7:
	; pointed at by entry 34 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "7"
HDAE5000_Str_6:
	; pointed at by entry 33 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "6"
HDAE5000_Str_5:
	; pointed at by entry 32 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "5"
HDAE5000_Str_4:
	; pointed at by entry 31 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "4"
HDAE5000_Str_3:
	; pointed at by entry 30 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "3"
HDAE5000_Str_2:
	; pointed at by entry 29 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "2"
HDAE5000_Str_1:
	; pointed at by entry 28 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "1"
HDAE5000_Str_0:
	; pointed at by entry 27 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "0"
HDAE5000_Str_Chr5F:
	; pointed at by entry 26 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "_"
HDAE5000_Str_Z:
	; pointed at by entry 25 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "Z"
HDAE5000_Str_Y:
	; pointed at by entry 24 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "Y"
HDAE5000_Str_X:
	; pointed at by entry 23 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "X"
HDAE5000_Str_W:
	; pointed at by entry 22 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "W"
HDAE5000_Str_V:
	; pointed at by entry 21 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "V"
HDAE5000_Str_U:
	; pointed at by entry 20 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "U"
HDAE5000_Str_T:
	; pointed at by entry 19 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "T"
HDAE5000_Str_S:
	; pointed at by entry 18 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "S"
HDAE5000_Str_R:
	; pointed at by entry 17 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "R"
HDAE5000_Str_Q:
	; pointed at by entry 16 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "Q"
HDAE5000_Str_P:
	; pointed at by entry 15 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "P"
HDAE5000_Str_O:
	; pointed at by entry 14 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "O"
HDAE5000_Str_N:
	; pointed at by entry 13 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "N"
HDAE5000_Str_M:
	; pointed at by entry 12 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "M"
HDAE5000_Str_L:
	; pointed at by entry 11 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "L"
HDAE5000_Str_K:
	; pointed at by entry 10 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "K"
HDAE5000_Str_J:
	; pointed at by entry 9 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "J"
HDAE5000_Str_I:
	; pointed at by entry 8 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "I"
HDAE5000_Str_H:
	; pointed at by entry 7 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "H"
HDAE5000_Str_G:
	; pointed at by entry 6 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "G"
HDAE5000_Str_F:
	; pointed at by entry 5 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "F"
HDAE5000_Str_E:
	; pointed at by entry 4 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "E"
HDAE5000_Str_D:
	; pointed at by entry 3 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "D"
HDAE5000_Str_C:
	; pointed at by entry 2 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "C"
HDAE5000_Str_B:
	; pointed at by entry 1 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "B"
HDAE5000_Str_A:
	; pointed at by entry 0 of HDAE5000_TextPtrs_A_to_SPC
	.asciz "A"
HDAE5000_TextPtrs_A_to_SPC_2:	; 38 x .long -> string
	; pointed at by entry 1 of HDAE5000_TablePtrs_AcHddNamingWindowProc, a table read by AcHddNamingWindowProc; 38 string pointers, 4 bytes each, entry i at +4*i
	.long	HDAE5000_Str_A_2
	.long	HDAE5000_Str_B_2
	.long	HDAE5000_Str_C_2
	.long	HDAE5000_Str_D_2
	.long	HDAE5000_Str_E_2
	.long	HDAE5000_Str_F_2
	.long	HDAE5000_Str_G_2
	.long	HDAE5000_Str_H_2
	.long	HDAE5000_Str_I_2
	.long	HDAE5000_Str_J_2
	.long	HDAE5000_Str_K_2
	.long	HDAE5000_Str_L_2
	.long	HDAE5000_Str_M_2
	.long	HDAE5000_Str_N_2
	.long	HDAE5000_Str_O_2
	.long	HDAE5000_Str_P_2
	.long	HDAE5000_Str_Q_2
	.long	HDAE5000_Str_R_2
	.long	HDAE5000_Str_S_2
	.long	HDAE5000_Str_T_2
	.long	HDAE5000_Str_U_2
	.long	HDAE5000_Str_V_2
	.long	HDAE5000_Str_W_2
	.long	HDAE5000_Str_X_2
	.long	HDAE5000_Str_Y_2
	.long	HDAE5000_Str_Z_2
	.long	HDAE5000_Str_Chr5F_2
	.long	HDAE5000_Str_0_2
	.long	HDAE5000_Str_1_2
	.long	HDAE5000_Str_2_2
	.long	HDAE5000_Str_3_2
	.long	HDAE5000_Str_4_2
	.long	HDAE5000_Str_5_2
	.long	HDAE5000_Str_6_2
	.long	HDAE5000_Str_7_2
	.long	HDAE5000_Str_8_2
	.long	HDAE5000_Str_9_2
	.long	HDAE5000_Str_SPC_2
	.byte 0x8e
	.asciz "\030."
	.zero 2
HDAE5000_Str_SPC_2:
	; pointed at by entry 37 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "SPC"
HDAE5000_Str_9_2:
	; pointed at by entry 36 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "9"
HDAE5000_Str_8_2:
	; pointed at by entry 35 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "8"
HDAE5000_Str_7_2:
	; pointed at by entry 34 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "7"
HDAE5000_Str_6_2:
	; pointed at by entry 33 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "6"
HDAE5000_Str_5_2:
	; pointed at by entry 32 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "5"
HDAE5000_Str_4_2:
	; pointed at by entry 31 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "4"
HDAE5000_Str_3_2:
	; pointed at by entry 30 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "3"
HDAE5000_Str_2_2:
	; pointed at by entry 29 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "2"
HDAE5000_Str_1_2:
	; pointed at by entry 28 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "1"
HDAE5000_Str_0_2:
	; pointed at by entry 27 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "0"
HDAE5000_Str_Chr5F_2:
	; pointed at by entry 26 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "_"
HDAE5000_Str_Z_2:
	; pointed at by entry 25 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "z"
HDAE5000_Str_Y_2:
	; pointed at by entry 24 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "y"
HDAE5000_Str_X_2:
	; pointed at by entry 23 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "x"
HDAE5000_Str_W_2:
	; pointed at by entry 22 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "w"
HDAE5000_Str_V_2:
	; pointed at by entry 21 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "v"
HDAE5000_Str_U_2:
	; pointed at by entry 20 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "u"
HDAE5000_Str_T_2:
	; pointed at by entry 19 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "t"
HDAE5000_Str_S_2:
	; pointed at by entry 18 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "s"
HDAE5000_Str_R_2:
	; pointed at by entry 17 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "r"
HDAE5000_Str_Q_2:
	; pointed at by entry 16 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "q"
HDAE5000_Str_P_2:
	; pointed at by entry 15 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "p"
HDAE5000_Str_O_2:
	; pointed at by entry 14 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "o"
HDAE5000_Str_N_2:
	; pointed at by entry 13 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "n"
HDAE5000_Str_M_2:
	; pointed at by entry 12 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "m"
HDAE5000_Str_L_2:
	; pointed at by entry 11 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "l"
HDAE5000_Str_K_2:
	; pointed at by entry 10 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "k"
HDAE5000_Str_J_2:
	; pointed at by entry 9 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "j"
HDAE5000_Str_I_2:
	; pointed at by entry 8 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "i"
HDAE5000_Str_H_2:
	; pointed at by entry 7 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "h"
HDAE5000_Str_G_2:
	; pointed at by entry 6 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "g"
HDAE5000_Str_F_2:
	; pointed at by entry 5 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "f"
HDAE5000_Str_E_2:
	; pointed at by entry 4 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "e"
HDAE5000_Str_D_2:
	; pointed at by entry 3 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "d"
HDAE5000_Str_C_2:
	; pointed at by entry 2 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "c"
HDAE5000_Str_B_2:
	; pointed at by entry 1 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "b"
HDAE5000_Str_A_2:
	; pointed at by entry 0 of HDAE5000_TextPtrs_A_to_SPC_2
	.asciz "a"
HDAE5000_TextPtrs_Chr21_to_Chr7D:	; 32 x .long -> string
	; pointed at by entry 2 of HDAE5000_TablePtrs_AcHddNamingWindowProc, a table read by AcHddNamingWindowProc; also read by AcHddNamingWindowProc at 0x282435 (lda operand); 32 string pointers, 4 bytes each, entry i at +4*i
	.long	HDAE5000_Str_Chr21
	.long	HDAE5000_Str_Chr23
	.long	HDAE5000_Str_Chr24
	.long	HDAE5000_Str_Chr25
	.long	HDAE5000_Str_Chr26
	.long	HDAE5000_Str_Chr3F
	.long	HDAE5000_Str_40
	.long	HDAE5000_Str_5c
	.long	HDAE5000_Str_Chr5E
	.long	HDAE5000_Str_Chr7C
	.long	HDAE5000_Str_22
	.long	HDAE5000_Str_27
	.long	HDAE5000_Str_Chr60
	.long	HDAE5000_Str_Chr2C
	.long	HDAE5000_Str_Chr2E
	.long	HDAE5000_Str_Chr3A
	.long	HDAE5000_Str_Chr3B
	.long	HDAE5000_Str_Chr2B
	.long	HDAE5000_Str_Chr2D
	.long	HDAE5000_Str_Chr2A
	.long	HDAE5000_Str_Chr2F
	.long	HDAE5000_Str_Chr3D
	.long	HDAE5000_Str_8b
	.long	HDAE5000_Str_8d
	.long	HDAE5000_Str_Chr28
	.long	HDAE5000_Str_Chr29
	.long	HDAE5000_Str_Chr3C
	.long	HDAE5000_Str_Chr3E
	.long	HDAE5000_Str_Chr5B
	.long	HDAE5000_Str_Chr5D
	.long	HDAE5000_Str_Chr7B
	.long	HDAE5000_Str_Chr7D
	.asciz "b\031."
	.zero 2
HDAE5000_Str_Chr7D:
	; pointed at by entry 31 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "}"
HDAE5000_Str_Chr7B:
	; pointed at by entry 30 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "{"
HDAE5000_Str_Chr5D:
	; pointed at by entry 29 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "]"
HDAE5000_Str_Chr5B:
	; pointed at by entry 28 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "["
HDAE5000_Str_Chr3E:
	; pointed at by entry 27 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz ">"
HDAE5000_Str_Chr3C:
	; pointed at by entry 26 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "<"
HDAE5000_Str_Chr29:
	; pointed at by entry 25 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz ")"
HDAE5000_Str_Chr28:
	; pointed at by entry 24 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "("
HDAE5000_Str_8d:
	; pointed at by entry 23 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "~8d"
HDAE5000_Str_8b:
	; pointed at by entry 22 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "~8b"
HDAE5000_Str_Chr3D:
	; pointed at by entry 21 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "="
HDAE5000_Str_Chr2F:
	; pointed at by entry 20 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "/"
HDAE5000_Str_Chr2A:
	; pointed at by entry 19 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "*"
HDAE5000_Str_Chr2D:
	; pointed at by entry 18 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "-"
HDAE5000_Str_Chr2B:
	; pointed at by entry 17 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "+"
HDAE5000_Str_Chr3B:
	; pointed at by entry 16 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz ";"
HDAE5000_Str_Chr3A:
	; pointed at by entry 15 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz ":"
HDAE5000_Str_Chr2E:
	; pointed at by entry 14 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "."
HDAE5000_Str_Chr2C:
	; pointed at by entry 13 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz ","
HDAE5000_Str_Chr60:
	; pointed at by entry 12 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "`"
HDAE5000_Str_27:
	; pointed at by entry 11 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "~27"
HDAE5000_Str_22:
	; pointed at by entry 10 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "~22"
HDAE5000_Str_Chr7C:
	; pointed at by entry 9 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "|"
HDAE5000_Str_Chr5E:
	; pointed at by entry 8 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "^"
HDAE5000_Str_5c:
	; pointed at by entry 7 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "~5c"
HDAE5000_Str_40:
	; pointed at by entry 6 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "~40"
HDAE5000_Str_Chr3F:
	; pointed at by entry 5 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "?"
HDAE5000_Str_Chr26:
	; pointed at by entry 4 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "&"
HDAE5000_Str_Chr25:
	; pointed at by entry 3 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "%"
HDAE5000_Str_Chr24:
	; pointed at by entry 2 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "$"
HDAE5000_Str_Chr23:
	; pointed at by entry 1 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "#"
HDAE5000_Str_Chr21:
	; pointed at by entry 0 of HDAE5000_TextPtrs_Chr21_to_Chr7D, a table read by AcHddNamingWindowProc
	.asciz "!"
HDAE5000_TablePtrs_AcHddNamingWindowProc:	; 3 x .long -> string
	; read by AcHddNamingWindowProc at 0x281764 (ld # operand); 3 string pointers, 4 bytes each, entry i at +4*i
	.long	HDAE5000_TextPtrs_A_to_SPC
	.long	HDAE5000_TextPtrs_A_to_SPC_2
	.long	HDAE5000_TextPtrs_Chr21_to_Chr7D
HDAE5000_Str_Chr25_AcHddNamingWindowProc:
	; read by AcHddNamingWindowProc at 0x28199F (ld # operand)
	; u16 x 6, indexed by (0x22A032 * 3 + 0x22A02A) * 2 and compared with the column (`cp iz,(xbc)`) by HDAE5000_AcHddNamingWindowProc: the last column of each name-editor character page
	.short 37, 37, 31, 36, 36, 31
HDAE5000_TextPtrs_Blank1_Chr5F:	; 2 x .long -> string
	; read by AcHddNamingWindowProc at 0x281557 (ld # operand); 2 string pointers, 4 bytes each, entry i at +4*i
	.long	HDAE5000_Str_Blank1
	.long	HDAE5000_Str_Chr5F_3
HDAE5000_Str_Chr5F_3:
	; pointed at by entry 1 of HDAE5000_TextPtrs_Blank1_Chr5F, a table read by AcHddNamingWindowProc
	.asciz "_"
HDAE5000_Str_Blank1:
	; pointed at by entry 0 of HDAE5000_TextPtrs_Blank1_Chr5F, a table read by AcHddNamingWindowProc
	.asciz " "
;
; HDAE5000_AcHddNamingWindowProc_CaseTable (0x2E21C6, 9 x u16): the switch of HDAE5000_AcHddNamingWindowProc
; (dispatch at 0x2819FA, hd-ae5000_v2_06i.s:2472: `dec 1,xwa`, bound `cp xwa,8`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_AcHddNamingWindowProc_OnPositionLeft)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_AcHddNamingWindowProc_OnPositionLeft of the case for value 1+i; 9 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_AcHddNamingWindowProc_CaseTable:
	.short	HDAE5000_AcHddNamingWindowProc_OnPositionLeft - HDAE5000_AcHddNamingWindowProc_OnPositionLeft	; 1
	.short	HDAE5000_AcHddNamingWindowProc_OnPositionRight - HDAE5000_AcHddNamingWindowProc_OnPositionLeft	; 2
	.short	HDAE5000_AcHddNamingWindowProc_OnPrevCharacter - HDAE5000_AcHddNamingWindowProc_OnPositionLeft	; 3
	.short	HDAE5000_AcHddNamingWindowProc_OnCharacterRowUpDown - HDAE5000_AcHddNamingWindowProc_OnPositionLeft	; 4
	.short	HDAE5000_AcHddNamingWindowProc_OnNextCharacter - HDAE5000_AcHddNamingWindowProc_OnPositionLeft	; 5
	.short	HDAE5000_AcHddNamingWindowProc_OnInsert - HDAE5000_AcHddNamingWindowProc_OnPositionLeft	; 6
	.short	HDAE5000_AcHddNamingWindowProc_OnDelete - HDAE5000_AcHddNamingWindowProc_OnPositionLeft	; 7
	.short	HDAE5000_AcHddNamingWindowProc_OnCenterName - HDAE5000_AcHddNamingWindowProc_OnPositionLeft	; 8
	.short	HDAE5000_AcHddNamingWindowProc_OnClear - HDAE5000_AcHddNamingWindowProc_OnPositionLeft	; 9
HDAE5000_Str_Name:
	; read by IvHddNamingProc at 0x2826DD (lda operand)
	.asciz "Name"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Test:
	; read by HardTestPage at 0x282856 (lda operand)
	.asciz "Test"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_PPORTTEST:
	; read by HardTestPage at 0x2828D5 (lda operand)
	.asciz "PPORT TEST"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_HDDIDREAD:
	; read by HardTestPage at 0x282981 (lda operand)
	.asciz "HDD ID READ"
HDAE5000_Str_FDTEST:
	; read by HardTestPage at 0x282A2D (lda operand)
	.asciz "FD TEST"
HDAE5000_Str_OK:
	; read by HardTestPage at 0x282A5F (lda operand)
	.asciz "OK"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_ERROR:
	; read by HardTestPage at 0x282A69 (lda operand)
	.asciz "ERROR"
HDAE5000_Str_ERROR_HardTestPage:
	; read by HardTestPage at 0x282A73 (lda operand)
	.asciz "ERROR"
HDAE5000_Str_STOPTESTLOOP:
	; read by HardTestPage at 0x282B2C (lda operand)
	.asciz "STOP TEST LOOP"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_STARTTESTLOOP:
	; read by HardTestPage at 0x282B53 (lda operand)
	.asciz "START TEST LOOP"
HDAE5000_Str_PortTestOK:
	; read by HardTest_PortTest at 0x282C58 (lda operand)
	.asciz "=======> Port Test OK"
HDAE5000_Str_PortTestError:
	; read by HardTest_PortTest at 0x282C62 (lda operand)
	.asciz "=======> Port Test Error"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_HDTYPE:
	; read by HardTest_HddIdRead at 0x282C94 (pushed operand)
	.asciz "HD-TYPE : "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_Fre_Capa_3_1f_MB:
	; read by HardTest_HddIdRead at 0x282CFC (pushed operand)
	.asciz "Fre Capa: %3.1f [MB]"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Empty:
	; read by HardTest_HddIdRead at 0x282D10 (lda operand)
	.zero 2
HDAE5000_Str_HDDOK:
	; read by HardTest_HddIdRead at 0x282D18 (lda operand)
	.asciz "=======> HDD OK"
HDAE5000_Str_HDDNG:
	; read by HardTest_HddIdRead at 0x282D22 (lda operand)
	.asciz "=======> HDD NG!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Float_100_HddIdRead:
	; read by HardTest_HddIdRead at 0x282CD9 (lda operand)
	; IEEE single 100.0 (0x42C80000): the divisor HDAE5000_HardTest_HddIdRead passes to HDAE5000_FloatDiv to turn the free space (units of 10,000 bytes) into MB for "Fre Capa: %3.1f [MB]"
	.long 0x42c80000		; 100.0f
HDAE5000_Fmt_2_2d:
	; read by FdName_SongNumber at 0x282E4E (pushed operand)
	.asciz "%2.2d"
HDAE5000_Str_AllFilesPattern:
	; read by FdList_Scan at 0x282F46 (lda operand)
	.asciz "*.*"
HDAE5000_Str_Cphd:
	; read by AttenCpToHDSwCatch at 0x2831C6 (lda operand)
	.asciz "CpHD"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Cphd_AttenCpToMarkSwCatch:
	; read by AttenCpToMarkSwCatch at 0x283282 (lda operand)
	.asciz "CpHD"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_TitleInfo_Template:
	; read by TitleInfo_Build at 0x2832F9 (lda operand)
	.asciz "WRITE PROTECTION   :ON     QUICK LOAD MODE:     1\tWRITE CONFIRM      :OFF    JUMP AFTER LOAD:     2\tLOAD BY NUMBER MODE:  1    FREE HDD SPACE :1251MB\t"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_s:
	; read by TitleInfo_Build at 0x283321 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_s_TitleInfo_Build:
	; read by TitleInfo_Build at 0x28335E (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_d:
	; read by TitleInfo_Build at 0x28338E (pushed operand)
	.asciz "  %d"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_d_TitleInfo_Build:
	; read by TitleInfo_Build at 0x2833BE (pushed operand)
	.asciz "     %d"
HDAE5000_Fmt_d_TitleInfo_Build_2:
	; read by TitleInfo_Build at 0x2833EE (pushed operand)
	.asciz "     %d"
HDAE5000_Fmt_4ldMB:
	; read by TitleInfo_Build at 0x28342D (pushed operand)
	.asciz "%4ldMB"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_HDAE:
	; read by HdTitleEventCatch at 0x2834F0 (lda operand)
	.asciz "HDAE"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_HDAETitleFunc_ObjIds:
	; read by HDAETitleFunc at 0x2836FC (lda operand); UI object ids (0x007F0000 + index into HDAE5000_UiObjectName_PtrTable), 4 bytes each
	.long HDAE5000_OBJ_HDDMENU		; UI object 0 "HDDMENU"
	.long HDAE5000_OBJ_ERR_HD_NOT_FMT		; UI object 594 "ERR_HD_NOT_FMT"
	.long HDAE5000_OBJ_ERR_HD_SRAM		; UI object 599 "ERR_HD_SRAM"
	.long HDAE5000_OBJ_ERR_HD_RESET		; UI object 604 "ERR_HD_RESET"
	.long HDAE5000_OBJ_ERR_HD_READ		; UI object 609 "ERR_HD_READ"
	.long HDAE5000_OBJ_ERR_HD_ID_READ		; UI object 614 "ERR_HD_ID_READ"
	.long HDAE5000_OBJ_ERR_HD_TRACK_0		; UI object 619 "ERR_HD_TRACK_0"
	.long HDAE5000_OBJ_ERR_HD_FAT		; UI object 624 "ERR_HD_FAT"
	.long HDAE5000_OBJ_ERR_HD_FSB		; UI object 629 "ERR_HD_FSB"
;
; HDAE5000_HDAETitleFunc_CaseTable (0x2E23AC, 8 x u16): the switch of HDAE5000_HDAETitleFunc
; (dispatch at 0x283546, hdae5000_hd_driver.s:629: `dec 2,xwa`, bound `cp xwa,7`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(.Lri_jt_base)`, `jp T,XIX+WA`).  Entry i is the offset from
; .Lri_jt_base of the case for value 2+i; 8 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_HDAETitleFunc_CaseTable:
	.short	.Lri_jt_base - .Lri_jt_base	; 2
	.short	.Lri_done - .Lri_jt_base	; 3 (default)
	.short	.Lri_done - .Lri_jt_base	; 4 (default)
	.short	.Lri_done - .Lri_jt_base	; 5 (default)
	.short	.Lri_case6 - .Lri_jt_base	; 6
	.short	.Lri_done - .Lri_jt_base	; 7 (default)
	.short	.Lri_case8 - .Lri_jt_base	; 8
	.short	.Lri_case9 - .Lri_jt_base	; 9
HDAE5000_Str_Chr2020203A2020:
	; read by DirList_BuildPage at 0x283732 (lda operand)
	.asciz "   :                \t"
HDAE5000_Fmt_3_3d:
	; read by DirList_BuildPage at 0x283758 (pushed operand)
	.asciz "%3.3d"
HDAE5000_PartNames_Text:
	; read by PartList_Build at 0x2839FD (lda operand)
	.asciz "CURRENT PANEL\t PANEL MEMORY\t  SEQUENCER  \t  COMPOSER   \t SOUND MEMORY\t     MSP     \tRHYTHM CUSTOM\t  USER MIDI  \t    LYRICS   \t"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PartNames_BlankText:
	; read by PartList_Build at 0x2839E4 (lda operand)
	.asciz "             \t             \t             \t             \t             \t             \t             \t             \t             \t"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PartName_Blank:
	; read by PartList_Build at 0x283A1F (lda operand)
	.asciz "             \t"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_SongScreen_Refresh_ObjIds:
	; read by SongScreen_Refresh at 0x283C05 (lda operand); UI object ids (0x007F0000 + index into HDAE5000_UiObjectName_PtrTable), 4 bytes each
	.long HDAE5000_OBJ_FILE_LOAD_DIRBOX		; UI object 260 "FILE_LOAD_DIRBOX"
	.long HDAE5000_OBJ_FLS_FILE_SEL_DIRBOX		; UI object 347 "FLS_FILE_SEL_DIRBOX"
HDAE5000_SongScreen_Refresh_ObjIds_2:
	; read by SongScreen_Refresh at 0x283CED (lda operand); UI object ids (0x007F0000 + index into HDAE5000_UiObjectName_PtrTable), 4 bytes each
	.long HDAE5000_OBJ_HD_FILE_LIST		; UI object 259 "HD_FILE_LIST"
	.long HDAE5000_OBJ_FLS_FILE_SEL_LISTBOX		; UI object 348 "FLS_FILE_SEL_LISTBOX"
HDAE5000_SongScreen_Refresh_ObjIds_3:
	; read by SongScreen_Refresh at 0x283D63 (lda operand); UI object ids (0x007F0000 + index into HDAE5000_UiObjectName_PtrTable), 4 bytes each
	.long HDAE5000_OBJ_HD_FILE_OPTION		; UI object 258 "HD_FILE_OPTION"
	.long HDAE5000_OBJ_FLS_FILE_SEL_OPTBOX		; UI object 352 "FLS_FILE_SEL_OPTBOX"
HDAE5000_Str_DIRECTORY:
	; read by SongScreen_Refresh at 0x283B8C (pushed operand)
	.asciz "DIRECTORY "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_2_2d_SongScreen_Refresh:
	; read by SongScreen_Refresh at 0x283BA4 (pushed operand)
	.asciz "%2.2d"
HDAE5000_Str_Chr3A_SongScreen_Refresh:
	; read by SongScreen_Refresh at 0x283BC3 (pushed operand)
	.asciz ":"
HDAE5000_Str_Blank0Tab:
	; read by SongScreen_Refresh at 0x283BED (pushed operand)
	.asciz "\t"
HDAE5000_Str_Chr3A2020202020:
	; read by SongScreen_Refresh at 0x283C6F (lda operand)
	.asciz ":                          \t"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_2_2d_SongScreen_Refresh_2:
	; read by SongScreen_Refresh at 0x283C90 (pushed operand)
	.asciz "%2.2d"
;
; HDAE5000_FILE_LOAD_Screen_CaseTable (0x2E253A, 14 x u16): the switch of HDAE5000_FILE_LOAD_Screen
; (dispatch at 0x283DDD, hdae5000_hd_driver.s:1447: `sub xwa,0x01ea0000`, bound `cp xwa,13`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_FILE_LOAD_Screen_Ev01C00001)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_FILE_LOAD_Screen_Ev01C00001 of the case for event 0x01EA0000+i; 14 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_FILE_LOAD_Screen_CaseTable:
	.short	HDAE5000_FILE_LOAD_Screen_Ev01EA0000 - HDAE5000_FILE_LOAD_Screen_Ev01C00001	; 0x01EA0000
	.short	HDAE5000_FILE_LOAD_Screen_Ev01EA0001 - HDAE5000_FILE_LOAD_Screen_Ev01C00001	; 0x01EA0001
	.short	HDAE5000_FILE_LOAD_Screen_Ev01EA0002 - HDAE5000_FILE_LOAD_Screen_Ev01C00001	; 0x01EA0002
	.short	HDAE5000_FILE_LOAD_Screen_Default - HDAE5000_FILE_LOAD_Screen_Ev01C00001	; 0x01EA0003 (default)
	.short	HDAE5000_FILE_LOAD_Screen_Default - HDAE5000_FILE_LOAD_Screen_Ev01C00001	; 0x01EA0004 (default)
	.short	HDAE5000_FILE_LOAD_Screen_Default - HDAE5000_FILE_LOAD_Screen_Ev01C00001	; 0x01EA0005 (default)
	.short	HDAE5000_FILE_LOAD_Screen_Default - HDAE5000_FILE_LOAD_Screen_Ev01C00001	; 0x01EA0006 (default)
	.short	HDAE5000_FILE_LOAD_Screen_Default - HDAE5000_FILE_LOAD_Screen_Ev01C00001	; 0x01EA0007 (default)
	.short	HDAE5000_FILE_LOAD_Screen_Ev01EA0008 - HDAE5000_FILE_LOAD_Screen_Ev01C00001	; 0x01EA0008
	.short	HDAE5000_FILE_LOAD_Screen_Default - HDAE5000_FILE_LOAD_Screen_Ev01C00001	; 0x01EA0009 (default)
	.short	HDAE5000_FILE_LOAD_Screen_Default - HDAE5000_FILE_LOAD_Screen_Ev01C00001	; 0x01EA000A (default)
	.short	HDAE5000_FILE_LOAD_Screen_Default - HDAE5000_FILE_LOAD_Screen_Ev01C00001	; 0x01EA000B (default)
	.short	HDAE5000_FILE_LOAD_Screen_Ev01EA000C - HDAE5000_FILE_LOAD_Screen_Ev01C00001	; 0x01EA000C
	.short	HDAE5000_FILE_LOAD_Screen_Ev01EA000D - HDAE5000_FILE_LOAD_Screen_Ev01C00001	; 0x01EA000D
HDAE5000_Str_DELD:
	; read by AttenDelDirSwCatch at 0x283FCA (lda operand)
	.asciz "DELD"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_DELF:
	; read by AttenDelFileSwCatch at 0x2840EE (lda operand)
	.asciz "DELF"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_UTIL:
	; read by HDD_UTIL_PAGE at 0x2845DB (lda operand)
	.asciz "UTIL"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_FORMATTRY:
	; only in v2.01i
	.asciz "FORMAT TRY !!!"
	.balign 2, 0x00                       ; word-align pad
HDAE5000_Str_PleaseWait:
	; only in v2.01i
	.asciz "Please Wait...."
HDAE5000_Str_FORMATFINISHED:
	; only in v2.01i
	.asciz "FORMAT FINISHED !!!"
HDAE5000_Str_FORMATERROR:
	; only in v2.01i
	.asciz "FORMAT ERROR !!!"
	.balign 2, 0x00                       ; word-align pad
HDAE5000_Str_ERRORNO:
	; only in v2.01i
	.asciz "ERROR NO. : "
	.balign 2, 0x00                       ; word-align pad
HDAE5000_Str_LSWFileInfo:
	; read by HDD_UTIL_PAGE at 0x28463A (pushed operand)
	.asciz "---[ LSW File Info. ]---"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Adr:
	; read by HDD_UTIL_PAGE at 0x28465F (pushed operand)
	.asciz "adr  : "
HDAE5000_Str_Size:
	; read by HDD_UTIL_PAGE at 0x28469E (pushed operand)
	.asciz "size : "
HDAE5000_Str_SDAFileInfo:
	; read by HDD_UTIL_PAGE at 0x2846F5 (pushed operand)
	.asciz "---[ SDA File Info. ]---"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Adr_HDD_UTIL_PAGE:
	; read by HDD_UTIL_PAGE at 0x28471A (pushed operand)
	.asciz "adr  : "
HDAE5000_Str_Size_HDD_UTIL_PAGE:
	; read by HDD_UTIL_PAGE at 0x284759 (pushed operand)
	.asciz "size : "
HDAE5000_Str_PMTFileInfo:
	; read by HDD_UTIL_PAGE at 0x2847B0 (pushed operand)
	.asciz "---[ PMT File Info. ]---"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Adr_HDD_UTIL_PAGE_2:
	; read by HDD_UTIL_PAGE at 0x2847D5 (pushed operand)
	.asciz "adr  : "
HDAE5000_Str_Size_HDD_UTIL_PAGE_2:
	; read by HDD_UTIL_PAGE at 0x284814 (pushed operand)
	.asciz "size : "
HDAE5000_Str_SQFFileInfo:
	; read by HDD_UTIL_PAGE at 0x28486B (pushed operand)
	.asciz "---[ SQF File Info. ]---"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Adr_HDD_UTIL_PAGE_3:
	; read by HDD_UTIL_PAGE at 0x284890 (pushed operand)
	.asciz "adr  : "
HDAE5000_Str_Size_HDD_UTIL_PAGE_3:
	; read by HDD_UTIL_PAGE at 0x2848CF (pushed operand)
	.asciz "size : "
HDAE5000_Str_PCLK:
	; read by PC_DATA_LINK_PAGE at 0x284E97 (lda operand)
	.asciz "PCLK"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_PORTISACTIVE:
	; read by PC_DATA_LINK_PAGE at 0x284EF8 (lda operand)
	.asciz "PORT IS ACTIVE"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Blank14:
	; read by PC_DATA_LINK_PAGE at 0x284F0A (lda operand)
	.asciz "              "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_SeparateOutput_MsgTemplateA:
	; read by SeparateOutput_SendPartMsg at 0x284F50 (ld # operand)
	.byte 0xb0
	.zero 1
	.byte 0x9b
	.zero 1
HDAE5000_SeparateOutput_MsgTemplateB:
	; read by SeparateOutput_SendPartMsg at 0x284F5C (ld # operand)
	.byte 0xb0
	.zero 1
	.byte 0x9d
	.zero 1
HDAE5000_TextPtrs_OFF_DRUMSLR_BASSDRUMSMIX_BASSDRUMSMONO:	; 4 x .long -> string
	; read by SeparateOutputModeCheck at 0x28512B (ld # operand); 4 string pointers, 4 bytes each, entry i at +4*i
	.long	HDAE5000_Str_OFF_3
	.long	HDAE5000_Str_DRUMSLR
	.long	HDAE5000_Str_BASSDRUMSMIX
	.long	HDAE5000_Str_BASSDRUMSMONO
HDAE5000_Str_BASSDRUMSMONO:
	; pointed at by entry 3 of HDAE5000_TextPtrs_OFF_DRUMSLR_BASSDRUMSMIX_BASSDRUMSMONO, a table read by SeparateOutputModeCheck
	.asciz "BASS/DRUMS MONO"
HDAE5000_Str_BASSDRUMSMIX:
	; pointed at by entry 2 of HDAE5000_TextPtrs_OFF_DRUMSLR_BASSDRUMSMIX_BASSDRUMSMONO, a table read by SeparateOutputModeCheck
	.asciz "BASS+DRUMS MIX "
HDAE5000_Str_DRUMSLR:
	; pointed at by entry 1 of HDAE5000_TextPtrs_OFF_DRUMSLR_BASSDRUMSMIX_BASSDRUMSMONO, a table read by SeparateOutputModeCheck
	.asciz "   DRUMS L/R   "
HDAE5000_Str_OFF_3:
	; pointed at by entry 0 of HDAE5000_TextPtrs_OFF_DRUMSLR_BASSDRUMSMIX_BASSDRUMSMONO, a table read by SeparateOutputModeCheck
	.asciz "      OFF      "
HDAE5000_Fmt_s_SeparateOutputModeCheck:
	; read by SeparateOutputModeCheck at 0x285138 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_SeparateOutputModeCheck_CaseTable (0x2E278A, 10 x u16): the switch of HDAE5000_SeparateOutputModeCheck
; (dispatch at 0x285120, hdae5000_hd_driver.s:3139: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(.LHD_SC__h1_case9)`, `jp T,XIX+WA`).  Entry i is the offset from
; .LHD_SC__h1_case9 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_SeparateOutputModeCheck_CaseTable:
	.short	.LHD_SC__h1_case0 - .LHD_SC__h1_case9	; 0x01E0003E
	.short	.LHD_SC__h1_case1 - .LHD_SC__h1_case9	; 0x01E0003F
	.short	.LHD_SC__h1_default - .LHD_SC__h1_case9	; 0x01E00040 (default)
	.short	.LHD_SC__h1_default - .LHD_SC__h1_case9	; 0x01E00041 (default)
	.short	.LHD_SC__h1_default - .LHD_SC__h1_case9	; 0x01E00042 (default)
	.short	.LHD_SC__h1_case5 - .LHD_SC__h1_case9	; 0x01E00043
	.short	.LHD_SC__h1_case6 - .LHD_SC__h1_case9	; 0x01E00044
	.short	.LHD_SC__h1_case7 - .LHD_SC__h1_case9	; 0x01E00045
	.short	.LHD_SC__h1_case8 - .LHD_SC__h1_case9	; 0x01E00046
	.short	.LHD_SC__h1_case9 - .LHD_SC__h1_case9	; 0x01E00047
HDAE5000_TextPtrs_NONE_to_16:	; 17 x .long -> string
	; read by SeparateDrumPartCheck at 0x2851D1 (ld # operand); 17 string pointers, 4 bytes each, entry i at +4*i
	.long	HDAE5000_Str_NONE
	.long	HDAE5000_Str_1_3
	.long	HDAE5000_Str_2_3
	.long	HDAE5000_Str_3_3
	.long	HDAE5000_Str_4_3
	.long	HDAE5000_Str_5_3
	.long	HDAE5000_Str_6_3
	.long	HDAE5000_Str_7_3
	.long	HDAE5000_Str_8_3
	.long	HDAE5000_Str_9_3
	.long	HDAE5000_Str_10
	.long	HDAE5000_Str_11
	.long	HDAE5000_Str_12
	.long	HDAE5000_Str_13
	.long	HDAE5000_Str_14
	.long	HDAE5000_Str_15
	.long	HDAE5000_Str_16
HDAE5000_Str_16:
	; pointed at by entry 16 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz " 16 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_15:
	; pointed at by entry 15 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz " 15 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_14:
	; pointed at by entry 14 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz " 14 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_13:
	; pointed at by entry 13 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz " 13 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_12:
	; pointed at by entry 12 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz " 12 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_11:
	; pointed at by entry 11 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz " 11 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_10:
	; pointed at by entry 10 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz " 10 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_9_3:
	; pointed at by entry 9 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz "  9 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_8_3:
	; pointed at by entry 8 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz "  8 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_7_3:
	; pointed at by entry 7 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz "  7 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_6_3:
	; pointed at by entry 6 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz "  6 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_5_3:
	; pointed at by entry 5 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz "  5 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_4_3:
	; pointed at by entry 4 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz "  4 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_3_3:
	; pointed at by entry 3 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz "  3 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_2_3:
	; pointed at by entry 2 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz "  2 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_1_3:
	; pointed at by entry 1 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz "  1 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_NONE:
	; pointed at by entry 0 of HDAE5000_TextPtrs_NONE_to_16, a table read by SeparateDrumPartCheck
	.asciz "NONE"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_s_SeparateDrumPartCheck:
	; read by SeparateDrumPartCheck at 0x2851DE (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_SeparateDrumPartCheck_CaseTable (0x2E284C, 10 x u16): the switch of HDAE5000_SeparateDrumPartCheck
; (dispatch at 0x2851C6, hdae5000_hd_driver.s:3208: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(.LHD_SC__h2_case9)`, `jp T,XIX+WA`).  Entry i is the offset from
; .LHD_SC__h2_case9 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_SeparateDrumPartCheck_CaseTable:
	.short	.LHD_SC__h2_case0 - .LHD_SC__h2_case9	; 0x01E0003E
	.short	.LHD_SC__h2_case1 - .LHD_SC__h2_case9	; 0x01E0003F
	.short	.LHD_SC__h2_default - .LHD_SC__h2_case9	; 0x01E00040 (default)
	.short	.LHD_SC__h2_default - .LHD_SC__h2_case9	; 0x01E00041 (default)
	.short	.LHD_SC__h2_default - .LHD_SC__h2_case9	; 0x01E00042 (default)
	.short	.LHD_SC__h2_case5 - .LHD_SC__h2_case9	; 0x01E00043
	.short	.LHD_SC__h2_case6 - .LHD_SC__h2_case9	; 0x01E00044
	.short	.LHD_SC__h2_case7 - .LHD_SC__h2_case9	; 0x01E00045
	.short	.LHD_SC__h2_case8 - .LHD_SC__h2_case9	; 0x01E00046
	.short	.LHD_SC__h2_case9 - .LHD_SC__h2_case9	; 0x01E00047
HDAE5000_TextPtrs_NONE_to_16_2:	; 17 x .long -> string
	; read by SeparateBassPartCheck at 0x28527A (ld # operand); 17 string pointers, 4 bytes each, entry i at +4*i
	.long	HDAE5000_Str_NONE_2
	.long	HDAE5000_Str_1_4
	.long	HDAE5000_Str_2_4
	.long	HDAE5000_Str_3_4
	.long	HDAE5000_Str_4_4
	.long	HDAE5000_Str_5_4
	.long	HDAE5000_Str_6_4
	.long	HDAE5000_Str_7_4
	.long	HDAE5000_Str_8_4
	.long	HDAE5000_Str_9_4
	.long	HDAE5000_Str_10_2
	.long	HDAE5000_Str_11_2
	.long	HDAE5000_Str_12_2
	.long	HDAE5000_Str_13_2
	.long	HDAE5000_Str_14_2
	.long	HDAE5000_Str_15_2
	.long	HDAE5000_Str_16_2
HDAE5000_Str_16_2:
	; pointed at by entry 16 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz " 16 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_15_2:
	; pointed at by entry 15 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz " 15 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_14_2:
	; pointed at by entry 14 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz " 14 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_13_2:
	; pointed at by entry 13 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz " 13 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_12_2:
	; pointed at by entry 12 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz " 12 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_11_2:
	; pointed at by entry 11 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz " 11 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_10_2:
	; pointed at by entry 10 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz " 10 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_9_4:
	; pointed at by entry 9 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz "  9 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_8_4:
	; pointed at by entry 8 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz "  8 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_7_4:
	; pointed at by entry 7 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz "  7 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_6_4:
	; pointed at by entry 6 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz "  6 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_5_4:
	; pointed at by entry 5 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz "  5 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_4_4:
	; pointed at by entry 4 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz "  4 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_3_4:
	; pointed at by entry 3 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz "  3 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_2_4:
	; pointed at by entry 2 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz "  2 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_1_4:
	; pointed at by entry 1 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz "  1 "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_NONE_2:
	; pointed at by entry 0 of HDAE5000_TextPtrs_NONE_to_16_2, a table read by SeparateBassPartCheck
	.asciz "NONE"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_s_SeparateBassPartCheck:
	; read by SeparateBassPartCheck at 0x285287 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_SeparateBassPartCheck_CaseTable (0x2E290E, 10 x u16): the switch of HDAE5000_SeparateBassPartCheck
; (dispatch at 0x28526F, hdae5000_hd_driver.s:3277: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(.LHD_SC__h3_case9)`, `jp T,XIX+WA`).  Entry i is the offset from
; .LHD_SC__h3_case9 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_SeparateBassPartCheck_CaseTable:
	.short	.LHD_SC__h3_case0 - .LHD_SC__h3_case9	; 0x01E0003E
	.short	.LHD_SC__h3_case1 - .LHD_SC__h3_case9	; 0x01E0003F
	.short	.LHD_SC__h3_default - .LHD_SC__h3_case9	; 0x01E00040 (default)
	.short	.LHD_SC__h3_default - .LHD_SC__h3_case9	; 0x01E00041 (default)
	.short	.LHD_SC__h3_default - .LHD_SC__h3_case9	; 0x01E00042 (default)
	.short	.LHD_SC__h3_case5 - .LHD_SC__h3_case9	; 0x01E00043
	.short	.LHD_SC__h3_case6 - .LHD_SC__h3_case9	; 0x01E00044
	.short	.LHD_SC__h3_case7 - .LHD_SC__h3_case9	; 0x01E00045
	.short	.LHD_SC__h3_case8 - .LHD_SC__h3_case9	; 0x01E00046
	.short	.LHD_SC__h3_case9 - .LHD_SC__h3_case9	; 0x01E00047
HDAE5000_TextPtrs_Chr2D2D2D_NO_YES:	; 3 x .long -> string
	; read by LBNCmpBitCheck, LBNLswBitCheck, LBNMdBitCheck, LBNMspBitCheck, LBNPmtBitCheck, LBNRcmBitCheck, LBNSqtBitCheck, LBNTlxBitCheck_Unregistered, LBNTmBitCheck, SfxCmpBitCheck, SfxLswBitCheck, SfxMdBitCheck, SfxMspBitCheck, SfxPmtBitCheck, SfxRcmBitCheck, SfxSqtBitCheck, SfxTlxBitCheck, SfxTmBitCheck, TypeSel_ShowSaveFlags at 0x285426 (ld #, ld (mem), lda operand); 3 string pointers, 4 bytes each, entry i at +4*i
	.long	HDAE5000_Str_Chr2D2D2D_2
	.long	HDAE5000_Str_NO
	.long	HDAE5000_Str_YES
HDAE5000_Str_YES:
	; pointed at by entry 2 of HDAE5000_TextPtrs_Chr2D2D2D_NO_YES, a table read by LBNCmpBitCheck, LBNLswBitCheck, LBNMdBitCheck, LBNMspBitCheck, LBNPmtBitCheck, LBNRcmBitCheck, LBNSqtBitCheck, LBNTlxBitCheck_Unregistered, LBNTmBitCheck, SfxCmpBitCheck, SfxLswBitCheck, SfxMdBitCheck, SfxMspBitCheck, SfxPmtBitCheck, SfxRcmBitCheck, SfxSqtBitCheck, SfxTlxBitCheck, SfxTmBitCheck, TypeSel_ShowSaveFlags
	.asciz "YES"
HDAE5000_Str_NO:
	; pointed at by entry 1 of HDAE5000_TextPtrs_Chr2D2D2D_NO_YES, a table read by LBNCmpBitCheck, LBNLswBitCheck, LBNMdBitCheck, LBNMspBitCheck, LBNPmtBitCheck, LBNRcmBitCheck, LBNSqtBitCheck, LBNTlxBitCheck_Unregistered, LBNTmBitCheck, SfxCmpBitCheck, SfxLswBitCheck, SfxMdBitCheck, SfxMspBitCheck, SfxPmtBitCheck, SfxRcmBitCheck, SfxSqtBitCheck, SfxTlxBitCheck, SfxTmBitCheck, TypeSel_ShowSaveFlags
	.asciz "NO "
HDAE5000_Str_Chr2D2D2D_2:
	; pointed at by entry 0 of HDAE5000_TextPtrs_Chr2D2D2D_NO_YES, a table read by LBNCmpBitCheck, LBNLswBitCheck, LBNMdBitCheck, LBNMspBitCheck, LBNPmtBitCheck, LBNRcmBitCheck, LBNSqtBitCheck, LBNTlxBitCheck_Unregistered, LBNTmBitCheck, SfxCmpBitCheck, SfxLswBitCheck, SfxMdBitCheck, SfxMspBitCheck, SfxPmtBitCheck, SfxRcmBitCheck, SfxSqtBitCheck, SfxTlxBitCheck, SfxTmBitCheck, TypeSel_ShowSaveFlags
	.asciz "---"
HDAE5000_Fmt_s_SaveOptNameCheck:
	; read by SaveOptNameCheck at 0x2853DF (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_SaveOptNameCheck_CaseTable (0x2E293E, 10 x u16): the switch of HDAE5000_SaveOptNameCheck
; (dispatch at 0x2853D1, hdae5000_hd_driver.s:3440: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(.Lhbi_case0)`, `jp T,XIX+WA`).  Entry i is the offset from
; .Lhbi_case0 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_SaveOptNameCheck_CaseTable:
	.short	.Lhbi_case1 - .Lhbi_case0	; 0x01E0003E
	.short	.Lhbi_case2 - .Lhbi_case0	; 0x01E0003F
	.short	.Lhbi_default - .Lhbi_case0	; 0x01E00040 (default)
	.short	.Lhbi_default - .Lhbi_case0	; 0x01E00041 (default)
	.short	.Lhbi_default - .Lhbi_case0	; 0x01E00042 (default)
	.short	.Lhbi_case3 - .Lhbi_case0	; 0x01E00043
	.short	.Lhbi_case4 - .Lhbi_case0	; 0x01E00044
	.short	.Lhbi_case5 - .Lhbi_case0	; 0x01E00045
	.short	.Lhbi_case6 - .Lhbi_case0	; 0x01E00046
	.short	.Lhbi_case0 - .Lhbi_case0	; 0x01E00047
HDAE5000_Str_SVOP:
	; read by SaveOptSwEventCatch at 0x28560E (lda operand)
	.asciz "SVOP"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_s_FileOptNameCheck:
	; read by FileOptNameCheck at 0x2857CA (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_FileOptNameCheck_CaseTable (0x2E295C, 10 x u16): the switch of HDAE5000_FileOptNameCheck
; (dispatch at 0x2857B1, hdae5000_hd_driver.s:3742: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_FileOptNameCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_FileOptNameCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_FileOptNameCheck_CaseTable:
	.short	HDAE5000_FileOptNameCheck_Ev01E0003E - HDAE5000_FileOptNameCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_FileOptNameCheck_Ev01E0003F - HDAE5000_FileOptNameCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_FileOptNameCheck_Default - HDAE5000_FileOptNameCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_FileOptNameCheck_Default - HDAE5000_FileOptNameCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_FileOptNameCheck_Default - HDAE5000_FileOptNameCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_FileOptNameCheck_Ev01E00043 - HDAE5000_FileOptNameCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_FileOptNameCheck_Ev01E00044 - HDAE5000_FileOptNameCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_FileOptNameCheck_Ev01E00045 - HDAE5000_FileOptNameCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_FileOptNameCheck_Ev01E00046 - HDAE5000_FileOptNameCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_FileOptNameCheck_Ev01E00047 - HDAE5000_FileOptNameCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_SfxLswBitCheck:
	; read by SfxLswBitCheck at 0x28584F (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_SfxLswBitCheck_CaseTable (0x2E2974, 10 x u16): the switch of HDAE5000_SfxLswBitCheck
; (dispatch at 0x285837, hdae5000_hd_driver.s:3794: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_SfxLswBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_SfxLswBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_SfxLswBitCheck_CaseTable:
	.short	HDAE5000_SfxLswBitCheck_Ev01E0003E - HDAE5000_SfxLswBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_SfxLswBitCheck_Ev01E0003F - HDAE5000_SfxLswBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_SfxLswBitCheck_Default - HDAE5000_SfxLswBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_SfxLswBitCheck_Default - HDAE5000_SfxLswBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_SfxLswBitCheck_Default - HDAE5000_SfxLswBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_SfxLswBitCheck_Ev01E00043 - HDAE5000_SfxLswBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_SfxLswBitCheck_Ev01E00044 - HDAE5000_SfxLswBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_SfxLswBitCheck_Ev01E00045 - HDAE5000_SfxLswBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_SfxLswBitCheck_Ev01E00046 - HDAE5000_SfxLswBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_SfxLswBitCheck_Ev01E00047 - HDAE5000_SfxLswBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_SfxPmtBitCheck:
	; read by SfxPmtBitCheck at 0x285905 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_SfxPmtBitCheck_CaseTable (0x2E298C, 10 x u16): the switch of HDAE5000_SfxPmtBitCheck
; (dispatch at 0x2858ED, hdae5000_hd_driver.s:3862: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_SfxPmtBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_SfxPmtBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_SfxPmtBitCheck_CaseTable:
	.short	HDAE5000_SfxPmtBitCheck_Ev01E0003E - HDAE5000_SfxPmtBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_SfxPmtBitCheck_Ev01E0003F - HDAE5000_SfxPmtBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_SfxPmtBitCheck_Default - HDAE5000_SfxPmtBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_SfxPmtBitCheck_Default - HDAE5000_SfxPmtBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_SfxPmtBitCheck_Default - HDAE5000_SfxPmtBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_SfxPmtBitCheck_Ev01E00043 - HDAE5000_SfxPmtBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_SfxPmtBitCheck_Ev01E00044 - HDAE5000_SfxPmtBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_SfxPmtBitCheck_Ev01E00045 - HDAE5000_SfxPmtBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_SfxPmtBitCheck_Ev01E00046 - HDAE5000_SfxPmtBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_SfxPmtBitCheck_Ev01E00047 - HDAE5000_SfxPmtBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_SfxSqtBitCheck:
	; read by SfxSqtBitCheck at 0x2859BB (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_SfxSqtBitCheck_CaseTable (0x2E29A4, 10 x u16): the switch of HDAE5000_SfxSqtBitCheck
; (dispatch at 0x2859A3, hdae5000_hd_driver.s:3930: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_SfxSqtBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_SfxSqtBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_SfxSqtBitCheck_CaseTable:
	.short	HDAE5000_SfxSqtBitCheck_Ev01E0003E - HDAE5000_SfxSqtBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_SfxSqtBitCheck_Ev01E0003F - HDAE5000_SfxSqtBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_SfxSqtBitCheck_Default - HDAE5000_SfxSqtBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_SfxSqtBitCheck_Default - HDAE5000_SfxSqtBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_SfxSqtBitCheck_Default - HDAE5000_SfxSqtBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_SfxSqtBitCheck_Ev01E00043 - HDAE5000_SfxSqtBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_SfxSqtBitCheck_Ev01E00044 - HDAE5000_SfxSqtBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_SfxSqtBitCheck_Ev01E00045 - HDAE5000_SfxSqtBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_SfxSqtBitCheck_Ev01E00046 - HDAE5000_SfxSqtBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_SfxSqtBitCheck_Ev01E00047 - HDAE5000_SfxSqtBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_SfxCmpBitCheck:
	; read by SfxCmpBitCheck at 0x285A71 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_SfxCmpBitCheck_CaseTable (0x2E29BC, 10 x u16): the switch of HDAE5000_SfxCmpBitCheck
; (dispatch at 0x285A59, hdae5000_hd_driver.s:3998: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_SfxCmpBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_SfxCmpBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_SfxCmpBitCheck_CaseTable:
	.short	HDAE5000_SfxCmpBitCheck_Ev01E0003E - HDAE5000_SfxCmpBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_SfxCmpBitCheck_Ev01E0003F - HDAE5000_SfxCmpBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_SfxCmpBitCheck_Default - HDAE5000_SfxCmpBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_SfxCmpBitCheck_Default - HDAE5000_SfxCmpBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_SfxCmpBitCheck_Default - HDAE5000_SfxCmpBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_SfxCmpBitCheck_Ev01E00043 - HDAE5000_SfxCmpBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_SfxCmpBitCheck_Ev01E00044 - HDAE5000_SfxCmpBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_SfxCmpBitCheck_Ev01E00045 - HDAE5000_SfxCmpBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_SfxCmpBitCheck_Ev01E00046 - HDAE5000_SfxCmpBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_SfxCmpBitCheck_Ev01E00047 - HDAE5000_SfxCmpBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_SfxTmBitCheck:
	; read by SfxTmBitCheck at 0x285B27 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_SfxTmBitCheck_CaseTable (0x2E29D4, 10 x u16): the switch of HDAE5000_SfxTmBitCheck
; (dispatch at 0x285B0F, hdae5000_hd_driver.s:4066: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_SfxTmBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_SfxTmBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_SfxTmBitCheck_CaseTable:
	.short	HDAE5000_SfxTmBitCheck_Ev01E0003E - HDAE5000_SfxTmBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_SfxTmBitCheck_Ev01E0003F - HDAE5000_SfxTmBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_SfxTmBitCheck_Default - HDAE5000_SfxTmBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_SfxTmBitCheck_Default - HDAE5000_SfxTmBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_SfxTmBitCheck_Default - HDAE5000_SfxTmBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_SfxTmBitCheck_Ev01E00043 - HDAE5000_SfxTmBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_SfxTmBitCheck_Ev01E00044 - HDAE5000_SfxTmBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_SfxTmBitCheck_Ev01E00045 - HDAE5000_SfxTmBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_SfxTmBitCheck_Ev01E00046 - HDAE5000_SfxTmBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_SfxTmBitCheck_Ev01E00047 - HDAE5000_SfxTmBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_SfxMspBitCheck:
	; read by SfxMspBitCheck at 0x285BDD (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_SfxMspBitCheck_CaseTable (0x2E29EC, 10 x u16): the switch of HDAE5000_SfxMspBitCheck
; (dispatch at 0x285BC5, hdae5000_hd_driver.s:4134: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_SfxMspBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_SfxMspBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_SfxMspBitCheck_CaseTable:
	.short	HDAE5000_SfxMspBitCheck_Ev01E0003E - HDAE5000_SfxMspBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_SfxMspBitCheck_Ev01E0003F - HDAE5000_SfxMspBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_SfxMspBitCheck_Default - HDAE5000_SfxMspBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_SfxMspBitCheck_Default - HDAE5000_SfxMspBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_SfxMspBitCheck_Default - HDAE5000_SfxMspBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_SfxMspBitCheck_Ev01E00043 - HDAE5000_SfxMspBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_SfxMspBitCheck_Ev01E00044 - HDAE5000_SfxMspBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_SfxMspBitCheck_Ev01E00045 - HDAE5000_SfxMspBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_SfxMspBitCheck_Ev01E00046 - HDAE5000_SfxMspBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_SfxMspBitCheck_Ev01E00047 - HDAE5000_SfxMspBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_SfxRcmBitCheck:
	; read by SfxRcmBitCheck at 0x285C93 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_SfxRcmBitCheck_CaseTable (0x2E2A04, 10 x u16): the switch of HDAE5000_SfxRcmBitCheck
; (dispatch at 0x285C7B, hdae5000_hd_driver.s:4202: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_SfxRcmBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_SfxRcmBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_SfxRcmBitCheck_CaseTable:
	.short	HDAE5000_SfxRcmBitCheck_Ev01E0003E - HDAE5000_SfxRcmBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_SfxRcmBitCheck_Ev01E0003F - HDAE5000_SfxRcmBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_SfxRcmBitCheck_Default - HDAE5000_SfxRcmBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_SfxRcmBitCheck_Default - HDAE5000_SfxRcmBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_SfxRcmBitCheck_Default - HDAE5000_SfxRcmBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_SfxRcmBitCheck_Ev01E00043 - HDAE5000_SfxRcmBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_SfxRcmBitCheck_Ev01E00044 - HDAE5000_SfxRcmBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_SfxRcmBitCheck_Ev01E00045 - HDAE5000_SfxRcmBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_SfxRcmBitCheck_Ev01E00046 - HDAE5000_SfxRcmBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_SfxRcmBitCheck_Ev01E00047 - HDAE5000_SfxRcmBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_SfxMdBitCheck:
	; read by SfxMdBitCheck at 0x285D49 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_SfxMdBitCheck_CaseTable (0x2E2A1C, 10 x u16): the switch of HDAE5000_SfxMdBitCheck
; (dispatch at 0x285D31, hdae5000_hd_driver.s:4270: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_SfxMdBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_SfxMdBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_SfxMdBitCheck_CaseTable:
	.short	HDAE5000_SfxMdBitCheck_Ev01E0003E - HDAE5000_SfxMdBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_SfxMdBitCheck_Ev01E0003F - HDAE5000_SfxMdBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_SfxMdBitCheck_Default - HDAE5000_SfxMdBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_SfxMdBitCheck_Default - HDAE5000_SfxMdBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_SfxMdBitCheck_Default - HDAE5000_SfxMdBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_SfxMdBitCheck_Ev01E00043 - HDAE5000_SfxMdBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_SfxMdBitCheck_Ev01E00044 - HDAE5000_SfxMdBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_SfxMdBitCheck_Ev01E00045 - HDAE5000_SfxMdBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_SfxMdBitCheck_Ev01E00046 - HDAE5000_SfxMdBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_SfxMdBitCheck_Ev01E00047 - HDAE5000_SfxMdBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_SfxTlxBitCheck:
	; read by SfxTlxBitCheck at 0x285E04 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_SfxTlxBitCheck_CaseTable (0x2E2A34, 10 x u16): the switch of HDAE5000_SfxTlxBitCheck
; (dispatch at 0x285DEA, hdae5000_hd_driver.s:4339: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_SfxTlxBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_SfxTlxBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_SfxTlxBitCheck_CaseTable:
	.short	HDAE5000_SfxTlxBitCheck_Ev01E0003E - HDAE5000_SfxTlxBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_SfxTlxBitCheck_Ev01E0003F - HDAE5000_SfxTlxBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_SfxTlxBitCheck_Default - HDAE5000_SfxTlxBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_SfxTlxBitCheck_Default - HDAE5000_SfxTlxBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_SfxTlxBitCheck_Default - HDAE5000_SfxTlxBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_SfxTlxBitCheck_Ev01E00043 - HDAE5000_SfxTlxBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_SfxTlxBitCheck_Ev01E00044 - HDAE5000_SfxTlxBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_SfxTlxBitCheck_Ev01E00045 - HDAE5000_SfxTlxBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_SfxTlxBitCheck_Ev01E00046 - HDAE5000_SfxTlxBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_SfxTlxBitCheck_Ev01E00047 - HDAE5000_SfxTlxBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_WriteProtectEditCheck:
	; read by WriteProtectEditCheck at 0x285EE1 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_WriteProtectEditCheck_CaseTable (0x2E2A4C, 10 x u16): the switch of HDAE5000_WriteProtectEditCheck
; (dispatch at 0x285EC9, hdae5000_hd_driver.s:4422: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_WriteProtectEditCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_WriteProtectEditCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_WriteProtectEditCheck_CaseTable:
	.short	HDAE5000_WriteProtectEditCheck_Ev01E0003E - HDAE5000_WriteProtectEditCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_WriteProtectEditCheck_Ev01E0003E - HDAE5000_WriteProtectEditCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_WriteProtectEditCheck_Default - HDAE5000_WriteProtectEditCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_WriteProtectEditCheck_Default - HDAE5000_WriteProtectEditCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_WriteProtectEditCheck_Default - HDAE5000_WriteProtectEditCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_WriteProtectEditCheck_Ev01E00043 - HDAE5000_WriteProtectEditCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_WriteProtectEditCheck_Ev01E00044 - HDAE5000_WriteProtectEditCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_WriteProtectEditCheck_Ev01E00045 - HDAE5000_WriteProtectEditCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_WriteProtectEditCheck_Ev01E00046 - HDAE5000_WriteProtectEditCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_WriteProtectEditCheck_Ev01E00047 - HDAE5000_WriteProtectEditCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_1d:
	; read by LyricJumpEditCheck at 0x285F5A (pushed operand)
	.asciz "%1d"
;
; HDAE5000_LyricJumpEditCheck_CaseTable (0x2E2A64, 10 x u16): the switch of HDAE5000_LyricJumpEditCheck
; (dispatch at 0x285F4E, hdae5000_hd_driver.s:4475: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_LyricJumpEditCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_LyricJumpEditCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_LyricJumpEditCheck_CaseTable:
	.short	HDAE5000_LyricJumpEditCheck_Ev01E0003E - HDAE5000_LyricJumpEditCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_LyricJumpEditCheck_Ev01E0003E - HDAE5000_LyricJumpEditCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_LyricJumpEditCheck_Default - HDAE5000_LyricJumpEditCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_LyricJumpEditCheck_Default - HDAE5000_LyricJumpEditCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_LyricJumpEditCheck_Default - HDAE5000_LyricJumpEditCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_LyricJumpEditCheck_Ev01E00043 - HDAE5000_LyricJumpEditCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_LyricJumpEditCheck_Ev01E00044 - HDAE5000_LyricJumpEditCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_LyricJumpEditCheck_Ev01E00045 - HDAE5000_LyricJumpEditCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_LyricJumpEditCheck_Ev01E00046 - HDAE5000_LyricJumpEditCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_LyricJumpEditCheck_Ev01E00047 - HDAE5000_LyricJumpEditCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_WriteConfirmEditCheck:
	; read by WriteConfirmEditCheck at 0x28612E (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_WriteConfirmEditCheck_CaseTable (0x2E2B28, 10 x u16): the switch of HDAE5000_WriteConfirmEditCheck
; (dispatch at 0x286116, hdae5000_hd_driver.s:4661: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_WriteConfirmEditCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_WriteConfirmEditCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_WriteConfirmEditCheck_CaseTable:
	.short	HDAE5000_WriteConfirmEditCheck_Ev01E0003E - HDAE5000_WriteConfirmEditCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_WriteConfirmEditCheck_Ev01E0003E - HDAE5000_WriteConfirmEditCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_WriteConfirmEditCheck_Default - HDAE5000_WriteConfirmEditCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_WriteConfirmEditCheck_Default - HDAE5000_WriteConfirmEditCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_WriteConfirmEditCheck_Default - HDAE5000_WriteConfirmEditCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_WriteConfirmEditCheck_Ev01E00043 - HDAE5000_WriteConfirmEditCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_WriteConfirmEditCheck_Ev01E00044 - HDAE5000_WriteConfirmEditCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_WriteConfirmEditCheck_Ev01E00045 - HDAE5000_WriteConfirmEditCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_WriteConfirmEditCheck_Ev01E00046 - HDAE5000_WriteConfirmEditCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_WriteConfirmEditCheck_Ev01E00047 - HDAE5000_WriteConfirmEditCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_1d_QuickLoadModeEditCheck:
	; read by QuickLoadModeEditCheck at 0x28619D (pushed operand)
	.asciz "%1d"
;
; HDAE5000_QuickLoadModeEditCheck_CaseTable (0x2E2B40, 10 x u16): the switch of HDAE5000_QuickLoadModeEditCheck
; (dispatch at 0x286191, hdae5000_hd_driver.s:4711: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_QuickLoadModeEditCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_QuickLoadModeEditCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_QuickLoadModeEditCheck_CaseTable:
	.short	HDAE5000_QuickLoadModeEditCheck_Ev01E0003E - HDAE5000_QuickLoadModeEditCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_QuickLoadModeEditCheck_Ev01E0003E - HDAE5000_QuickLoadModeEditCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_QuickLoadModeEditCheck_Default - HDAE5000_QuickLoadModeEditCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_QuickLoadModeEditCheck_Default - HDAE5000_QuickLoadModeEditCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_QuickLoadModeEditCheck_Default - HDAE5000_QuickLoadModeEditCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_QuickLoadModeEditCheck_Ev01E00043 - HDAE5000_QuickLoadModeEditCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_QuickLoadModeEditCheck_Ev01E00044 - HDAE5000_QuickLoadModeEditCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_QuickLoadModeEditCheck_Ev01E00045 - HDAE5000_QuickLoadModeEditCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_QuickLoadModeEditCheck_Ev01E00046 - HDAE5000_QuickLoadModeEditCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_QuickLoadModeEditCheck_Ev01E00047 - HDAE5000_QuickLoadModeEditCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_1d_LoadByNumberModeEditCheck:
	; read by LoadByNumberModeEditCheck at 0x28620C (pushed operand)
	.asciz "%1d"
;
; HDAE5000_LoadByNumberModeEditCheck_CaseTable (0x2E2B58, 10 x u16): the switch of HDAE5000_LoadByNumberModeEditCheck
; (dispatch at 0x286200, hdae5000_hd_driver.s:4757: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_LoadByNumberModeEditCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_LoadByNumberModeEditCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_LoadByNumberModeEditCheck_CaseTable:
	.short	HDAE5000_LoadByNumberModeEditCheck_Ev01E0003E - HDAE5000_LoadByNumberModeEditCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_LoadByNumberModeEditCheck_Ev01E0003E - HDAE5000_LoadByNumberModeEditCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_LoadByNumberModeEditCheck_Default - HDAE5000_LoadByNumberModeEditCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_LoadByNumberModeEditCheck_Default - HDAE5000_LoadByNumberModeEditCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_LoadByNumberModeEditCheck_Default - HDAE5000_LoadByNumberModeEditCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_LoadByNumberModeEditCheck_Ev01E00043 - HDAE5000_LoadByNumberModeEditCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_LoadByNumberModeEditCheck_Ev01E00044 - HDAE5000_LoadByNumberModeEditCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_LoadByNumberModeEditCheck_Ev01E00045 - HDAE5000_LoadByNumberModeEditCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_LoadByNumberModeEditCheck_Ev01E00046 - HDAE5000_LoadByNumberModeEditCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_LoadByNumberModeEditCheck_Ev01E00047 - HDAE5000_LoadByNumberModeEditCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_1d_JumpAfterLoadModeEditCheck:
	; read by JumpAfterLoadModeEditCheck at 0x28627B (pushed operand)
	.asciz "%1d"
;
; HDAE5000_JumpAfterLoadModeEditCheck_CaseTable (0x2E2B70, 10 x u16): the switch of HDAE5000_JumpAfterLoadModeEditCheck
; (dispatch at 0x28626F, hdae5000_hd_driver.s:4803: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_JumpAfterLoadModeEditCheck_CaseTable:
	.short	HDAE5000_JumpAfterLoadModeEditCheck_Ev01E0003E - HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_JumpAfterLoadModeEditCheck_Ev01E0003E - HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_JumpAfterLoadModeEditCheck_Default - HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_JumpAfterLoadModeEditCheck_Default - HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_JumpAfterLoadModeEditCheck_Default - HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00043 - HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00044 - HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00045 - HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00046 - HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00047 - HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00047	; 0x01E00047
HDAE5000_DriveInfo_Template:
	; read by SetupPage_BuildDriveInfo at 0x2862B2 (lda operand)
	.asciz "HD-TYPE             :                 \tTRACKS              :                 \tHEADS               :                 \tSECTORS PER TRACK   :                 \tTOTAL HD       (MB) :                 \tUSED BY SYSTEM (MB) :                 \tFREE FOR USE   (MB) :                 \tSOFTWARE RELEASE    :                 \t"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_6_1f:
	; read by SetupPage_BuildDriveInfo at 0x28639D (pushed operand)
	.asciz "%6.1f"
HDAE5000_Fmt_6_1f_SetupPage_BuildDriveInfo:
	; read by SetupPage_BuildDriveInfo at 0x286403 (pushed operand)
	.asciz "%6.1f"
HDAE5000_Fmt_6_1f_SetupPage_BuildDriveInfo_2:
	; read by SetupPage_BuildDriveInfo at 0x286466 (pushed operand)
	.asciz "%6.1f"
HDAE5000_Float_100_DriveInfo:
	; read by SetupPage_BuildDriveInfo at 0x28637A (lda operand)
	; IEEE single 100.0: a divisor of HDAE5000_SetupPage_BuildDriveInfo (10,000-byte units -> MB)
	.long 0x42c80000		; 100.0f
HDAE5000_Float_100_DriveInfo_2:
	; read by SetupPage_BuildDriveInfo at 0x2863E0 (lda operand)
	; IEEE single 100.0: a divisor of HDAE5000_SetupPage_BuildDriveInfo
	.long 0x42c80000		; 100.0f
HDAE5000_Float_100_DriveInfo_3:
	; read by SetupPage_BuildDriveInfo at 0x286443 (lda operand)
	; IEEE single 100.0: a divisor of HDAE5000_SetupPage_BuildDriveInfo
	.long 0x42c80000		; 100.0f
HDAE5000_Str_FMT:
	; read by AttenHDFormatSwCatch at 0x2866C5 (lda operand)
	.asciz "FMT!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_AttenHDFormatSwCatch_CaseTable (0x2E2CE2, 8 x u16): the switch of HDAE5000_AttenHDFormatSwCatch
; (dispatch at 0x286728, hdae5000_hd_driver.s:5233: bound `cp xwa,7`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_AttenHDFormatSwCatch_OnCodeDigit0Or1)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_AttenHDFormatSwCatch_OnCodeDigit0Or1 of the case for value 0+i; 8 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_AttenHDFormatSwCatch_CaseTable:
	.short	HDAE5000_AttenHDFormatSwCatch_OnCodeDigit0Or1 - HDAE5000_AttenHDFormatSwCatch_OnCodeDigit0Or1	; 0
	.short	HDAE5000_AttenHDFormatSwCatch_OnCodeDigit2Or3 - HDAE5000_AttenHDFormatSwCatch_OnCodeDigit0Or1	; 1
	.short	HDAE5000_AttenHDFormatSwCatch_OnCodeDigit4Or5 - HDAE5000_AttenHDFormatSwCatch_OnCodeDigit0Or1	; 2
	.short	HDAE5000_AttenHDFormatSwCatch_OnCodeDigit6Or7 - HDAE5000_AttenHDFormatSwCatch_OnCodeDigit0Or1	; 3
	.short	HDAE5000_AttenHDFormatSwCatch_OnCodeDigit8Or9 - HDAE5000_AttenHDFormatSwCatch_OnCodeDigit0Or1	; 4
	.short	.LCHSC__post_switch - HDAE5000_AttenHDFormatSwCatch_OnCodeDigit0Or1	; 5 (default)
	.short	HDAE5000_AttenHDFormatSwCatch_OnCancel - HDAE5000_AttenHDFormatSwCatch_OnCodeDigit0Or1	; 6
	.short	HDAE5000_AttenHDFormatSwCatch_OnCancel - HDAE5000_AttenHDFormatSwCatch_OnCodeDigit0Or1	; 7
;
; HDAE5000_Lbn_StepDigit_CaseTable (0x2E2CF2, 6 x u16): the switch of HDAE5000_Lbn_StepDigit
; (dispatch at 0x286A49, hdae5000_hd_driver.s:5493: bound `cp xwa,5`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_Lbn_StepDigit_NoDigitTyped)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_Lbn_StepDigit_NoDigitTyped of the case for value 0+i; 6 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_Lbn_StepDigit_CaseTable:
	.short	HDAE5000_Lbn_StepDigit_NoDigitTyped - HDAE5000_Lbn_StepDigit_NoDigitTyped	; 0
	.short	HDAE5000_Lbn_StepDigit_DirHundreds - HDAE5000_Lbn_StepDigit_NoDigitTyped	; 1
	.short	HDAE5000_Lbn_StepDigit_DirTens - HDAE5000_Lbn_StepDigit_NoDigitTyped	; 2
	.short	HDAE5000_Lbn_StepDigit_DirUnits - HDAE5000_Lbn_StepDigit_NoDigitTyped	; 3
	.short	HDAE5000_Lbn_StepDigit_SongTens - HDAE5000_Lbn_StepDigit_NoDigitTyped	; 4
	.short	HDAE5000_Lbn_StepDigit_SongUnits - HDAE5000_Lbn_StepDigit_NoDigitTyped	; 5
HDAE5000_Str_LBNS:
	; read by LBNPage1SwCatch at 0x286BB7 (lda operand)
	.asciz "LBNS"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_LBNPage1SwCatch_CaseTable (0x2E2D04, 13 x u16): the switch of HDAE5000_LBNPage1SwCatch
; (dispatch at 0x286C15, hdae5000_hd_driver.s:5660: bound `cp xwa,12`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_LBNPage1SwCatch_OnClear)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_LBNPage1SwCatch_OnClear of the case for value 0+i; 13 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_LBNPage1SwCatch_CaseTable:
	.short	HDAE5000_LBNPage1SwCatch_OnDigit0Or1 - HDAE5000_LBNPage1SwCatch_OnClear	; 0
	.short	HDAE5000_LBNPage1SwCatch_OnDigit2Or3 - HDAE5000_LBNPage1SwCatch_OnClear	; 1
	.short	HDAE5000_LBNPage1SwCatch_OnDigit4Or5 - HDAE5000_LBNPage1SwCatch_OnClear	; 2
	.short	HDAE5000_LBNPage1SwCatch_OnDigit6Or7 - HDAE5000_LBNPage1SwCatch_OnClear	; 3
	.short	HDAE5000_LBNPage1SwCatch_OnDigit8Or9 - HDAE5000_LBNPage1SwCatch_OnClear	; 4
	.short	HDAE5000_LBNPage1SwCatch_OnStepDigit - HDAE5000_LBNPage1SwCatch_OnClear	; 5
	.short	HDAE5000_LBNPage1SwCatch_OnStepDigit - HDAE5000_LBNPage1SwCatch_OnClear	; 6
	.short	HDAE5000_LBNPage1SwCatch_OnStepDigit - HDAE5000_LBNPage1SwCatch_OnClear	; 7
	.short	.LHD_SR__a_exit - HDAE5000_LBNPage1SwCatch_OnClear	; 8 (default)
	.short	.LHD_SR__a_exit - HDAE5000_LBNPage1SwCatch_OnClear	; 9 (default)
	.short	.LHD_SR__a_exit - HDAE5000_LBNPage1SwCatch_OnClear	; 10 (default)
	.short	.LHD_SR__a_exit - HDAE5000_LBNPage1SwCatch_OnClear	; 11 (default)
	.short	HDAE5000_LBNPage1SwCatch_OnClear - HDAE5000_LBNPage1SwCatch_OnClear	; 12
HDAE5000_Str_LBN:
	; read by LBNLoadSwCatch at 0x286D7A (lda operand)
	.asciz "LBN!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_1_1d:
	; read by Lbn_ShowEntry at 0x287162 (pushed operand)
	.asciz "%1.1d"
HDAE5000_Fmt_2_2d_Lbn_ShowEntry:
	; read by Lbn_ShowEntry at 0x287196 (pushed operand)
	.asciz "%2.2d"
HDAE5000_Fmt_3_3d_Lbn_ShowEntry:
	; read by Lbn_ShowEntry at 0x2871C2 (pushed operand)
	.asciz "%3.3d"
HDAE5000_Fmt_1_1d_Lbn_ShowEntry:
	; read by Lbn_ShowEntry at 0x287222 (pushed operand)
	.asciz " %1.1d"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_2_2d_Lbn_ShowEntry_2:
	; read by Lbn_ShowEntry at 0x287250 (pushed operand)
	.asciz " %2.2d"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_Lbn_ShowEntry_CaseTable (0x2E2D46, 7 x u16): the switch of HDAE5000_Lbn_ShowEntry
; (dispatch at 0x2870FC, hdae5000_filesystem.s:17: bound `cp xwa,6`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_Lbn_ShowEntry_NoDigitTyped)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_Lbn_ShowEntry_NoDigitTyped of the case for value 0+i; 7 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_Lbn_ShowEntry_CaseTable:
	.short	HDAE5000_Lbn_ShowEntry_NoDigitTyped - HDAE5000_Lbn_ShowEntry_NoDigitTyped	; 0
	.short	HDAE5000_Lbn_ShowEntry_DirHundredsTyped - HDAE5000_Lbn_ShowEntry_NoDigitTyped	; 1
	.short	HDAE5000_Lbn_ShowEntry_DirTensTyped - HDAE5000_Lbn_ShowEntry_NoDigitTyped	; 2
	.short	HDAE5000_Lbn_ShowEntry_DirUnitsTyped - HDAE5000_Lbn_ShowEntry_NoDigitTyped	; 3
	.short	HDAE5000_Lbn_ShowEntry_SongTensTyped - HDAE5000_Lbn_ShowEntry_NoDigitTyped	; 4
	.short	HDAE5000_Lbn_ShowEntry_SongUnitsTyped - HDAE5000_Lbn_ShowEntry_NoDigitTyped	; 5
	.short	HDAE5000_Lbn_ShowEntry_Reset - HDAE5000_Lbn_ShowEntry_NoDigitTyped	; 6
HDAE5000_Str_Blank26:
	; read by FileLBNNameCheck at 0x2875C4 (pushed operand)
	.asciz "                          "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_s_FileLBNNameCheck:
	; read by FileLBNNameCheck at 0x2875B1 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_FileLBNNameCheck_CaseTable (0x2E2D74, 10 x u16): the switch of HDAE5000_FileLBNNameCheck
; (dispatch at 0x28758F, hdae5000_filesystem.s:362: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_FileLBNNameCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_FileLBNNameCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_FileLBNNameCheck_CaseTable:
	.short	HDAE5000_FileLBNNameCheck_Ev01E0003E - HDAE5000_FileLBNNameCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_FileLBNNameCheck_Ev01E0003F - HDAE5000_FileLBNNameCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_FileLBNNameCheck_Default - HDAE5000_FileLBNNameCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_FileLBNNameCheck_Default - HDAE5000_FileLBNNameCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_FileLBNNameCheck_Default - HDAE5000_FileLBNNameCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_FileLBNNameCheck_Ev01E00043 - HDAE5000_FileLBNNameCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_FileLBNNameCheck_Ev01E00044 - HDAE5000_FileLBNNameCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_FileLBNNameCheck_Ev01E00045 - HDAE5000_FileLBNNameCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_FileLBNNameCheck_Ev01E00046 - HDAE5000_FileLBNNameCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_FileLBNNameCheck_Ev01E00047 - HDAE5000_FileLBNNameCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_LBNLswBitCheck:
	; read by LBNLswBitCheck at 0x287651 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_LBNLswBitCheck_CaseTable (0x2E2D8C, 10 x u16): the switch of HDAE5000_LBNLswBitCheck
; (dispatch at 0x287630, hdae5000_filesystem.s:425: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_LBNLswBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_LBNLswBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_LBNLswBitCheck_CaseTable:
	.short	HDAE5000_LBNLswBitCheck_Ev01E0003E - HDAE5000_LBNLswBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_LBNLswBitCheck_Ev01E0003F - HDAE5000_LBNLswBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_LBNLswBitCheck_Default - HDAE5000_LBNLswBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_LBNLswBitCheck_Default - HDAE5000_LBNLswBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_LBNLswBitCheck_Default - HDAE5000_LBNLswBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_LBNLswBitCheck_Ev01E00043 - HDAE5000_LBNLswBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_LBNLswBitCheck_Ev01E00044 - HDAE5000_LBNLswBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_LBNLswBitCheck_Ev01E00045 - HDAE5000_LBNLswBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_LBNLswBitCheck_Ev01E00046 - HDAE5000_LBNLswBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_LBNLswBitCheck_Ev01E00047 - HDAE5000_LBNLswBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_LBNPmtBitCheck:
	; read by LBNPmtBitCheck at 0x28775B (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_LBNPmtBitCheck_CaseTable (0x2E2DA4, 10 x u16): the switch of HDAE5000_LBNPmtBitCheck
; (dispatch at 0x28773A, hdae5000_filesystem.s:524: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_LBNPmtBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_LBNPmtBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_LBNPmtBitCheck_CaseTable:
	.short	HDAE5000_LBNPmtBitCheck_Ev01E0003E - HDAE5000_LBNPmtBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_LBNPmtBitCheck_Ev01E0003F - HDAE5000_LBNPmtBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_LBNPmtBitCheck_Default - HDAE5000_LBNPmtBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_LBNPmtBitCheck_Default - HDAE5000_LBNPmtBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_LBNPmtBitCheck_Default - HDAE5000_LBNPmtBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_LBNPmtBitCheck_Ev01E00043 - HDAE5000_LBNPmtBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_LBNPmtBitCheck_Ev01E00044 - HDAE5000_LBNPmtBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_LBNPmtBitCheck_Ev01E00045 - HDAE5000_LBNPmtBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_LBNPmtBitCheck_Ev01E00046 - HDAE5000_LBNPmtBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_LBNPmtBitCheck_Ev01E00047 - HDAE5000_LBNPmtBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_LBNSqtBitCheck:
	; read by LBNSqtBitCheck at 0x287865 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_LBNSqtBitCheck_CaseTable (0x2E2DBC, 10 x u16): the switch of HDAE5000_LBNSqtBitCheck
; (dispatch at 0x287844, hdae5000_filesystem.s:623: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_LBNSqtBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_LBNSqtBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_LBNSqtBitCheck_CaseTable:
	.short	HDAE5000_LBNSqtBitCheck_Ev01E0003E - HDAE5000_LBNSqtBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_LBNSqtBitCheck_Ev01E0003F - HDAE5000_LBNSqtBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_LBNSqtBitCheck_Default - HDAE5000_LBNSqtBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_LBNSqtBitCheck_Default - HDAE5000_LBNSqtBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_LBNSqtBitCheck_Default - HDAE5000_LBNSqtBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_LBNSqtBitCheck_Ev01E00043 - HDAE5000_LBNSqtBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_LBNSqtBitCheck_Ev01E00044 - HDAE5000_LBNSqtBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_LBNSqtBitCheck_Ev01E00045 - HDAE5000_LBNSqtBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_LBNSqtBitCheck_Ev01E00046 - HDAE5000_LBNSqtBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_LBNSqtBitCheck_Ev01E00047 - HDAE5000_LBNSqtBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_LBNCmpBitCheck:
	; read by LBNCmpBitCheck at 0x28796F (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_LBNCmpBitCheck_CaseTable (0x2E2DD4, 10 x u16): the switch of HDAE5000_LBNCmpBitCheck
; (dispatch at 0x28794E, hdae5000_filesystem.s:722: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_LBNCmpBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_LBNCmpBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_LBNCmpBitCheck_CaseTable:
	.short	HDAE5000_LBNCmpBitCheck_Ev01E0003E - HDAE5000_LBNCmpBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_LBNCmpBitCheck_Ev01E0003F - HDAE5000_LBNCmpBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_LBNCmpBitCheck_Default - HDAE5000_LBNCmpBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_LBNCmpBitCheck_Default - HDAE5000_LBNCmpBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_LBNCmpBitCheck_Default - HDAE5000_LBNCmpBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_LBNCmpBitCheck_Ev01E00043 - HDAE5000_LBNCmpBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_LBNCmpBitCheck_Ev01E00044 - HDAE5000_LBNCmpBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_LBNCmpBitCheck_Ev01E00045 - HDAE5000_LBNCmpBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_LBNCmpBitCheck_Ev01E00046 - HDAE5000_LBNCmpBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_LBNCmpBitCheck_Ev01E00047 - HDAE5000_LBNCmpBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_LBNTmBitCheck:
	; read by LBNTmBitCheck at 0x287A79 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_LBNTmBitCheck_CaseTable (0x2E2DEC, 10 x u16): the switch of HDAE5000_LBNTmBitCheck
; (dispatch at 0x287A58, hdae5000_filesystem.s:821: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_LBNTmBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_LBNTmBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_LBNTmBitCheck_CaseTable:
	.short	HDAE5000_LBNTmBitCheck_Ev01E0003E - HDAE5000_LBNTmBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_LBNTmBitCheck_Ev01E0003F - HDAE5000_LBNTmBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_LBNTmBitCheck_Default - HDAE5000_LBNTmBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_LBNTmBitCheck_Default - HDAE5000_LBNTmBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_LBNTmBitCheck_Default - HDAE5000_LBNTmBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_LBNTmBitCheck_Ev01E00043 - HDAE5000_LBNTmBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_LBNTmBitCheck_Ev01E00044 - HDAE5000_LBNTmBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_LBNTmBitCheck_Ev01E00045 - HDAE5000_LBNTmBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_LBNTmBitCheck_Ev01E00046 - HDAE5000_LBNTmBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_LBNTmBitCheck_Ev01E00047 - HDAE5000_LBNTmBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_LBNMspBitCheck:
	; read by LBNMspBitCheck at 0x287B83 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_LBNMspBitCheck_CaseTable (0x2E2E04, 10 x u16): the switch of HDAE5000_LBNMspBitCheck
; (dispatch at 0x287B62, hdae5000_filesystem.s:920: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_LBNMspBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_LBNMspBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_LBNMspBitCheck_CaseTable:
	.short	HDAE5000_LBNMspBitCheck_Ev01E0003E - HDAE5000_LBNMspBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_LBNMspBitCheck_Ev01E0003F - HDAE5000_LBNMspBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_LBNMspBitCheck_Default - HDAE5000_LBNMspBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_LBNMspBitCheck_Default - HDAE5000_LBNMspBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_LBNMspBitCheck_Default - HDAE5000_LBNMspBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_LBNMspBitCheck_Ev01E00043 - HDAE5000_LBNMspBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_LBNMspBitCheck_Ev01E00044 - HDAE5000_LBNMspBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_LBNMspBitCheck_Ev01E00045 - HDAE5000_LBNMspBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_LBNMspBitCheck_Ev01E00046 - HDAE5000_LBNMspBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_LBNMspBitCheck_Ev01E00047 - HDAE5000_LBNMspBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_LBNRcmBitCheck:
	; read by LBNRcmBitCheck at 0x287C8D (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_LBNRcmBitCheck_CaseTable (0x2E2E1C, 10 x u16): the switch of HDAE5000_LBNRcmBitCheck
; (dispatch at 0x287C6C, hdae5000_filesystem.s:1019: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_LBNRcmBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_LBNRcmBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_LBNRcmBitCheck_CaseTable:
	.short	HDAE5000_LBNRcmBitCheck_Ev01E0003E - HDAE5000_LBNRcmBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_LBNRcmBitCheck_Ev01E0003F - HDAE5000_LBNRcmBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_LBNRcmBitCheck_Default - HDAE5000_LBNRcmBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_LBNRcmBitCheck_Default - HDAE5000_LBNRcmBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_LBNRcmBitCheck_Default - HDAE5000_LBNRcmBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_LBNRcmBitCheck_Ev01E00043 - HDAE5000_LBNRcmBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_LBNRcmBitCheck_Ev01E00044 - HDAE5000_LBNRcmBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_LBNRcmBitCheck_Ev01E00045 - HDAE5000_LBNRcmBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_LBNRcmBitCheck_Ev01E00046 - HDAE5000_LBNRcmBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_LBNRcmBitCheck_Ev01E00047 - HDAE5000_LBNRcmBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_LBNMdBitCheck:
	; read by LBNMdBitCheck at 0x287D97 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_LBNMdBitCheck_CaseTable (0x2E2E34, 10 x u16): the switch of HDAE5000_LBNMdBitCheck
; (dispatch at 0x287D76, hdae5000_filesystem.s:1118: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_LBNMdBitCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_LBNMdBitCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_LBNMdBitCheck_CaseTable:
	.short	HDAE5000_LBNMdBitCheck_Ev01E0003E - HDAE5000_LBNMdBitCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_LBNMdBitCheck_Ev01E0003F - HDAE5000_LBNMdBitCheck_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_LBNMdBitCheck_Default - HDAE5000_LBNMdBitCheck_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_LBNMdBitCheck_Default - HDAE5000_LBNMdBitCheck_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_LBNMdBitCheck_Default - HDAE5000_LBNMdBitCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_LBNMdBitCheck_Ev01E00043 - HDAE5000_LBNMdBitCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_LBNMdBitCheck_Ev01E00044 - HDAE5000_LBNMdBitCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_LBNMdBitCheck_Ev01E00045 - HDAE5000_LBNMdBitCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_LBNMdBitCheck_Ev01E00046 - HDAE5000_LBNMdBitCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_LBNMdBitCheck_Ev01E00047 - HDAE5000_LBNMdBitCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_LBNTlxBitCheck_Unregistered:
	; read by LBNTlxBitCheck_Unregistered at 0x287EA1 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_LBNTlxBitCheck_Unregistered_CaseTable (0x2E2E4C, 10 x u16): the switch of HDAE5000_LBNTlxBitCheck_Unregistered
; (dispatch at 0x287E80, hdae5000_filesystem.s:1222: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_LBNTlxBitCheck_Unregistered_CaseTable:
	.short	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E0003E - HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E0003F - HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047	; 0x01E0003F
	.short	HDAE5000_LBNTlxBitCheck_Unregistered_Default - HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047	; 0x01E00040 (default)
	.short	HDAE5000_LBNTlxBitCheck_Unregistered_Default - HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047	; 0x01E00041 (default)
	.short	HDAE5000_LBNTlxBitCheck_Unregistered_Default - HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00043 - HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047	; 0x01E00043
	.short	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00044 - HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047	; 0x01E00044
	.short	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00045 - HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047	; 0x01E00045
	.short	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00046 - HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047	; 0x01E00046
	.short	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047 - HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047	; 0x01E00047
HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage:
	; read by FlsList_BuildPage at 0x287F77 (lda operand)
	.asciz "   :                \t"
HDAE5000_Fmt_3_3d_FlsList_BuildPage:
	; read by FlsList_BuildPage at 0x287F9B (pushed operand)
	.asciz "%3.3d"
HDAE5000_FlsScreen_Refresh_ObjIds:
	; read by FlsScreen_Refresh at 0x288338 (lda operand); UI object ids (0x007F0000 + index into HDAE5000_UiObjectName_PtrTable), 4 bytes each
	.long HDAE5000_OBJ_FLS_NAME_BOX		; UI object 325 "FLS_NAME_BOX"
	.long HDAE5000_OBJ_FLS_EDIT_NAME_BOX		; UI object 358 "FLS_EDIT_NAME_BOX"
HDAE5000_FlsScreen_Refresh_ObjIds_2:
	; read by FlsScreen_Refresh at 0x28848E (lda operand); UI object ids (0x007F0000 + index into HDAE5000_UiObjectName_PtrTable), 4 bytes each
	.long HDAE5000_OBJ_FLS_FILE_BOX		; UI object 328 "FLS_FILE_BOX"
	.long HDAE5000_OBJ_FLS_EDIT_LIST_BOX		; UI object 361 "FLS_EDIT_LIST_BOX"
HDAE5000_FlsScreen_Refresh_ObjIds_3:
	; read by FlsScreen_Refresh at 0x288566 (lda operand); UI object ids (0x007F0000 + index into HDAE5000_UiObjectName_PtrTable), 4 bytes each
	.long HDAE5000_OBJ_FLS_LOC_BOX		; UI object 324 "FLS_LOC_BOX"
	.long HDAE5000_OBJ_FLS_EDIT_LOC_BOX		; UI object 374 "FLS_EDIT_LOC_BOX"
HDAE5000_FlsScreen_Refresh_ObjIds_4:
	; read by FlsScreen_Refresh at 0x2885D8 (lda operand); UI object ids (0x007F0000 + index into HDAE5000_UiObjectName_PtrTable), 4 bytes each
	.long HDAE5000_OBJ_FLS_OPT_BOX		; UI object 323 "FLS_OPT_BOX"
	.long HDAE5000_OBJ_FLS_EDIT_OPT_BOX		; UI object 375 "FLS_EDIT_OPT_BOX"
HDAE5000_FlsScreen_Refresh_ObjIds_5:
	; read by FlsScreen_Refresh at 0x28861A (lda operand); UI object ids (0x007F0000 + index into HDAE5000_UiObjectName_PtrTable), 4 bytes each
	.long HDAE5000_OBJ_FLS_LOAD_LINE1		; UI object 329 "FLS_LOAD_LINE1"
	.long HDAE5000_OBJ_FLS_EDIT_LINE1		; UI object 363 "FLS_EDIT_LINE1"
HDAE5000_FlsScreen_Refresh_ObjIds_6:
	; read by FlsScreen_Refresh at 0x288644 (lda operand); UI object ids (0x007F0000 + index into HDAE5000_UiObjectName_PtrTable), 4 bytes each
	.long HDAE5000_OBJ_FLS_LOAD_LINE2		; UI object 330 "FLS_LOAD_LINE2"
	.long HDAE5000_OBJ_FLS_EDIT_LINE2		; UI object 362 "FLS_EDIT_LINE2"
HDAE5000_Str_FLSNAME:
	; read by FlsScreen_Refresh at 0x2882BF (pushed operand)
	.asciz "FLS NAME "
HDAE5000_Fmt_2_2d_FlsScreen_Refresh:
	; read by FlsScreen_Refresh at 0x2882D7 (pushed operand)
	.asciz "%2.2d"
HDAE5000_Str_Chr3A_FlsScreen_Refresh:
	; read by FlsScreen_Refresh at 0x2882F6 (pushed operand)
	.asciz ":"
HDAE5000_Str_Blank0Tab_FlsScreen_Refresh:
	; read by FlsScreen_Refresh at 0x288320 (pushed operand)
	.asciz "\t"
HDAE5000_Str_Chr3A2020202020_FlsScreen_Refresh:
	; read by FlsScreen_Refresh at 0x2883A9 (lda operand)
	.asciz ":                                 \t"
HDAE5000_Fmt_2_2d_FlsScreen_Refresh_2:
	; read by FlsScreen_Refresh at 0x2883D1 (pushed operand)
	.asciz "%2.2d"
HDAE5000_Fmt_LOC_3_3d_2_2d:
	; read by FlsScreen_Refresh at 0x288524 (pushed operand)
	.asciz " LOC. %3.3d/%2.2d\t"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_LOC00000:
	; read by FlsScreen_Refresh at 0x288537 (pushed operand)
	.asciz " LOC. 000/00\t"
HDAE5000_Str_FLS:
	; read by FlsFileLoadSwCatch at 0x288C64 (lda operand)
	.asciz "FLS!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_DEL1:
	; read by FlsDel1SwCatch at 0x289038 (lda operand)
	.asciz "DEL1"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_DEL2:
	; read by FlsDel2SwCatch at 0x289135 (lda operand)
	.asciz "DEL2"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_OVWR:
	; read by FlsOverWrSwCatch at 0x289579 (lda operand)
	.asciz "OVWR"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_2_2d_CopyToHd_Execute:
	; read by CopyToHd_Execute at 0x2898D2 (pushed operand)
	.asciz "%2.2d"
HDAE5000_Str_LSW:
	; read by CopyToHd_Execute at 0x28996D (pushed operand)
	.asciz ".LSW"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_PMT:
	; read by CopyToHd_Execute at 0x2899BA (pushed operand)
	.asciz ".PMT"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_SQT:
	; read by CopyToHd_Execute at 0x289A08 (pushed operand)
	.asciz ".SQT"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_CMP:
	; read by CopyToHd_Execute at 0x289A56 (pushed operand)
	.asciz ".CMP"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_TM:
	; read by CopyToHd_Execute at 0x289AA4 (pushed operand)
	.asciz ".TM"
HDAE5000_Str_MSP:
	; read by CopyToHd_Execute at 0x289AF2 (pushed operand)
	.asciz ".MSP"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_RCM:
	; read by CopyToHd_Execute at 0x289B40 (pushed operand)
	.asciz ".RCM"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_MD:
	; read by CopyToHd_Execute at 0x289B8E (pushed operand)
	.asciz ".MD"
HDAE5000_Str_TLX:
	; read by CopyToHd_Execute at 0x289BDC (pushed operand)
	.asciz ".TLX"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Wrcn:
	; read by WrConfirmEventCatch at 0x28A1EB (lda operand)
	.asciz "WrCn"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_DEL_DelOptSwEventCatch:
	; read by DelOptSwEventCatch at 0x28A4DB (lda operand)
	.asciz "DEL!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_s_DelOptNameCheck:
	; read by DelOptNameCheck at 0x28A665 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_DelOptNameCheck_CaseTable (0x2E2F6C, 10 x u16): the switch of HDAE5000_DelOptNameCheck
; (dispatch at 0x28A64C, hdae5000_filesystem.s:4440: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_DelOptNameCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_DelOptNameCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_DelOptNameCheck_CaseTable:
	.short	HDAE5000_DelOptNameCheck_Ev01E0003E - HDAE5000_DelOptNameCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_DelOptNameCheck_Ev01E0003F - HDAE5000_DelOptNameCheck_Ev01E00047	; 0x01E0003F
	.short	.LDUO__hA_default - HDAE5000_DelOptNameCheck_Ev01E00047	; 0x01E00040 (default)
	.short	.LDUO__hA_default - HDAE5000_DelOptNameCheck_Ev01E00047	; 0x01E00041 (default)
	.short	.LDUO__hA_default - HDAE5000_DelOptNameCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_DelOptNameCheck_Ev01E00043 - HDAE5000_DelOptNameCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_DelOptNameCheck_Ev01E00044 - HDAE5000_DelOptNameCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_DelOptNameCheck_Ev01E00045 - HDAE5000_DelOptNameCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_DelOptNameCheck_Ev01E00046 - HDAE5000_DelOptNameCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_DelOptNameCheck_Ev01E00047 - HDAE5000_DelOptNameCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_DelLswEditCheck:
	; read by DelLswEditCheck at 0x28A6E7 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_DelLswEditCheck_CaseTable (0x2E2F84, 10 x u16): the switch of HDAE5000_DelLswEditCheck
; (dispatch at 0x28A6CF, hdae5000_filesystem.s:4500: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_DelLswEditCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_DelLswEditCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_DelLswEditCheck_CaseTable:
	.short	HDAE5000_DelLswEditCheck_Ev01E0003E - HDAE5000_DelLswEditCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_DelLswEditCheck_Ev01E0003F - HDAE5000_DelLswEditCheck_Ev01E00047	; 0x01E0003F
	.short	.LDUO__hB_default - HDAE5000_DelLswEditCheck_Ev01E00047	; 0x01E00040 (default)
	.short	.LDUO__hB_default - HDAE5000_DelLswEditCheck_Ev01E00047	; 0x01E00041 (default)
	.short	.LDUO__hB_default - HDAE5000_DelLswEditCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_DelLswEditCheck_Ev01E00043 - HDAE5000_DelLswEditCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_DelLswEditCheck_Ev01E00044 - HDAE5000_DelLswEditCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_DelLswEditCheck_Ev01E00045 - HDAE5000_DelLswEditCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_DelLswEditCheck_Ev01E00046 - HDAE5000_DelLswEditCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_DelLswEditCheck_Ev01E00047 - HDAE5000_DelLswEditCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_DelPmtEditCheck:
	; read by DelPmtEditCheck at 0x28A782 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_DelPmtEditCheck_CaseTable (0x2E2F9C, 10 x u16): the switch of HDAE5000_DelPmtEditCheck
; (dispatch at 0x28A76A, hdae5000_filesystem.s:4570: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_DelPmtEditCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_DelPmtEditCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_DelPmtEditCheck_CaseTable:
	.short	HDAE5000_DelPmtEditCheck_Ev01E0003E - HDAE5000_DelPmtEditCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_DelPmtEditCheck_Ev01E0003F - HDAE5000_DelPmtEditCheck_Ev01E00047	; 0x01E0003F
	.short	.LDUO__hC_default - HDAE5000_DelPmtEditCheck_Ev01E00047	; 0x01E00040 (default)
	.short	.LDUO__hC_default - HDAE5000_DelPmtEditCheck_Ev01E00047	; 0x01E00041 (default)
	.short	.LDUO__hC_default - HDAE5000_DelPmtEditCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_DelPmtEditCheck_Ev01E00043 - HDAE5000_DelPmtEditCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_DelPmtEditCheck_Ev01E00044 - HDAE5000_DelPmtEditCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_DelPmtEditCheck_Ev01E00045 - HDAE5000_DelPmtEditCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_DelPmtEditCheck_Ev01E00046 - HDAE5000_DelPmtEditCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_DelPmtEditCheck_Ev01E00047 - HDAE5000_DelPmtEditCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_DelSqtEditCheck:
	; read by DelSqtEditCheck at 0x28A81D (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_DelSqtEditCheck_CaseTable (0x2E2FB4, 10 x u16): the switch of HDAE5000_DelSqtEditCheck
; (dispatch at 0x28A805, hdae5000_filesystem.s:4640: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_DelSqtEditCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_DelSqtEditCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_DelSqtEditCheck_CaseTable:
	.short	HDAE5000_DelSqtEditCheck_Ev01E0003E - HDAE5000_DelSqtEditCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_DelSqtEditCheck_Ev01E0003F - HDAE5000_DelSqtEditCheck_Ev01E00047	; 0x01E0003F
	.short	.LDUO__hD_default - HDAE5000_DelSqtEditCheck_Ev01E00047	; 0x01E00040 (default)
	.short	.LDUO__hD_default - HDAE5000_DelSqtEditCheck_Ev01E00047	; 0x01E00041 (default)
	.short	.LDUO__hD_default - HDAE5000_DelSqtEditCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_DelSqtEditCheck_Ev01E00043 - HDAE5000_DelSqtEditCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_DelSqtEditCheck_Ev01E00044 - HDAE5000_DelSqtEditCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_DelSqtEditCheck_Ev01E00045 - HDAE5000_DelSqtEditCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_DelSqtEditCheck_Ev01E00046 - HDAE5000_DelSqtEditCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_DelSqtEditCheck_Ev01E00047 - HDAE5000_DelSqtEditCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_DelCmpEditCheck:
	; read by DelCmpEditCheck at 0x28A8B8 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_DelCmpEditCheck_CaseTable (0x2E2FCC, 10 x u16): the switch of HDAE5000_DelCmpEditCheck
; (dispatch at 0x28A8A0, hdae5000_filesystem.s:4710: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_DelCmpEditCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_DelCmpEditCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_DelCmpEditCheck_CaseTable:
	.short	HDAE5000_DelCmpEditCheck_Ev01E0003E - HDAE5000_DelCmpEditCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_DelCmpEditCheck_Ev01E0003F - HDAE5000_DelCmpEditCheck_Ev01E00047	; 0x01E0003F
	.short	.LDUO__hE_default - HDAE5000_DelCmpEditCheck_Ev01E00047	; 0x01E00040 (default)
	.short	.LDUO__hE_default - HDAE5000_DelCmpEditCheck_Ev01E00047	; 0x01E00041 (default)
	.short	.LDUO__hE_default - HDAE5000_DelCmpEditCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_DelCmpEditCheck_Ev01E00043 - HDAE5000_DelCmpEditCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_DelCmpEditCheck_Ev01E00044 - HDAE5000_DelCmpEditCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_DelCmpEditCheck_Ev01E00045 - HDAE5000_DelCmpEditCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_DelCmpEditCheck_Ev01E00046 - HDAE5000_DelCmpEditCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_DelCmpEditCheck_Ev01E00047 - HDAE5000_DelCmpEditCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_DelTmEditCheck:
	; read by DelTmEditCheck at 0x28A953 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_DelTmEditCheck_CaseTable (0x2E2FE4, 10 x u16): the switch of HDAE5000_DelTmEditCheck
; (dispatch at 0x28A93B, hdae5000_filesystem.s:4780: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_DelTmEditCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_DelTmEditCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_DelTmEditCheck_CaseTable:
	.short	HDAE5000_DelTmEditCheck_Ev01E0003E - HDAE5000_DelTmEditCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_DelTmEditCheck_Ev01E0003F - HDAE5000_DelTmEditCheck_Ev01E00047	; 0x01E0003F
	.short	.LDUO__hF_default - HDAE5000_DelTmEditCheck_Ev01E00047	; 0x01E00040 (default)
	.short	.LDUO__hF_default - HDAE5000_DelTmEditCheck_Ev01E00047	; 0x01E00041 (default)
	.short	.LDUO__hF_default - HDAE5000_DelTmEditCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_DelTmEditCheck_Ev01E00043 - HDAE5000_DelTmEditCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_DelTmEditCheck_Ev01E00044 - HDAE5000_DelTmEditCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_DelTmEditCheck_Ev01E00045 - HDAE5000_DelTmEditCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_DelTmEditCheck_Ev01E00046 - HDAE5000_DelTmEditCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_DelTmEditCheck_Ev01E00047 - HDAE5000_DelTmEditCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_DelMspEditCheck:
	; read by DelMspEditCheck at 0x28A9EE (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_DelMspEditCheck_CaseTable (0x2E2FFC, 10 x u16): the switch of HDAE5000_DelMspEditCheck
; (dispatch at 0x28A9D6, hdae5000_filesystem.s:4850: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_DelMspEditCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_DelMspEditCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_DelMspEditCheck_CaseTable:
	.short	HDAE5000_DelMspEditCheck_Ev01E0003E - HDAE5000_DelMspEditCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_DelMspEditCheck_Ev01E0003F - HDAE5000_DelMspEditCheck_Ev01E00047	; 0x01E0003F
	.short	.LDUO__hG_default - HDAE5000_DelMspEditCheck_Ev01E00047	; 0x01E00040 (default)
	.short	.LDUO__hG_default - HDAE5000_DelMspEditCheck_Ev01E00047	; 0x01E00041 (default)
	.short	.LDUO__hG_default - HDAE5000_DelMspEditCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_DelMspEditCheck_Ev01E00043 - HDAE5000_DelMspEditCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_DelMspEditCheck_Ev01E00044 - HDAE5000_DelMspEditCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_DelMspEditCheck_Ev01E00045 - HDAE5000_DelMspEditCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_DelMspEditCheck_Ev01E00046 - HDAE5000_DelMspEditCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_DelMspEditCheck_Ev01E00047 - HDAE5000_DelMspEditCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_DelRcmEditCheck:
	; read by DelRcmEditCheck at 0x28AA89 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_DelRcmEditCheck_CaseTable (0x2E3014, 10 x u16): the switch of HDAE5000_DelRcmEditCheck
; (dispatch at 0x28AA71, hdae5000_filesystem.s:4920: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_DelRcmEditCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_DelRcmEditCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_DelRcmEditCheck_CaseTable:
	.short	HDAE5000_DelRcmEditCheck_Ev01E0003E - HDAE5000_DelRcmEditCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_DelRcmEditCheck_Ev01E0003F - HDAE5000_DelRcmEditCheck_Ev01E00047	; 0x01E0003F
	.short	.LDUO__hH_default - HDAE5000_DelRcmEditCheck_Ev01E00047	; 0x01E00040 (default)
	.short	.LDUO__hH_default - HDAE5000_DelRcmEditCheck_Ev01E00047	; 0x01E00041 (default)
	.short	.LDUO__hH_default - HDAE5000_DelRcmEditCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_DelRcmEditCheck_Ev01E00043 - HDAE5000_DelRcmEditCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_DelRcmEditCheck_Ev01E00044 - HDAE5000_DelRcmEditCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_DelRcmEditCheck_Ev01E00045 - HDAE5000_DelRcmEditCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_DelRcmEditCheck_Ev01E00046 - HDAE5000_DelRcmEditCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_DelRcmEditCheck_Ev01E00047 - HDAE5000_DelRcmEditCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_DelMdEditCheck:
	; read by DelMdEditCheck at 0x28AB24 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_DelMdEditCheck_CaseTable (0x2E302C, 10 x u16): the switch of HDAE5000_DelMdEditCheck
; (dispatch at 0x28AB0C, hdae5000_filesystem.s:4990: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_DelMdEditCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_DelMdEditCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_DelMdEditCheck_CaseTable:
	.short	HDAE5000_DelMdEditCheck_Ev01E0003E - HDAE5000_DelMdEditCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_DelMdEditCheck_Ev01E0003F - HDAE5000_DelMdEditCheck_Ev01E00047	; 0x01E0003F
	.short	.LDUO__hI_default - HDAE5000_DelMdEditCheck_Ev01E00047	; 0x01E00040 (default)
	.short	.LDUO__hI_default - HDAE5000_DelMdEditCheck_Ev01E00047	; 0x01E00041 (default)
	.short	.LDUO__hI_default - HDAE5000_DelMdEditCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_DelMdEditCheck_Ev01E00043 - HDAE5000_DelMdEditCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_DelMdEditCheck_Ev01E00044 - HDAE5000_DelMdEditCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_DelMdEditCheck_Ev01E00045 - HDAE5000_DelMdEditCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_DelMdEditCheck_Ev01E00046 - HDAE5000_DelMdEditCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_DelMdEditCheck_Ev01E00047 - HDAE5000_DelMdEditCheck_Ev01E00047	; 0x01E00047
HDAE5000_Fmt_s_DelTlxEditCheck:
	; read by DelTlxEditCheck at 0x28ABC2 (pushed operand)
	.asciz "%s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_DelTlxEditCheck_CaseTable (0x2E3044, 10 x u16): the switch of HDAE5000_DelTlxEditCheck
; (dispatch at 0x28ABAA, hdae5000_filesystem.s:5060: `sub xwa,0x01e0003e`, bound `cp xwa,9`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_DelTlxEditCheck_Ev01E00047)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_DelTlxEditCheck_Ev01E00047 of the case for event 0x01E0003E+i; 10 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_DelTlxEditCheck_CaseTable:
	.short	HDAE5000_DelTlxEditCheck_Ev01E0003E - HDAE5000_DelTlxEditCheck_Ev01E00047	; 0x01E0003E
	.short	HDAE5000_DelTlxEditCheck_Ev01E0003F - HDAE5000_DelTlxEditCheck_Ev01E00047	; 0x01E0003F
	.short	.LDUO__hJ_default - HDAE5000_DelTlxEditCheck_Ev01E00047	; 0x01E00040 (default)
	.short	.LDUO__hJ_default - HDAE5000_DelTlxEditCheck_Ev01E00047	; 0x01E00041 (default)
	.short	.LDUO__hJ_default - HDAE5000_DelTlxEditCheck_Ev01E00047	; 0x01E00042 (default)
	.short	HDAE5000_DelTlxEditCheck_Ev01E00043 - HDAE5000_DelTlxEditCheck_Ev01E00047	; 0x01E00043
	.short	HDAE5000_DelTlxEditCheck_Ev01E00044 - HDAE5000_DelTlxEditCheck_Ev01E00047	; 0x01E00044
	.short	HDAE5000_DelTlxEditCheck_Ev01E00045 - HDAE5000_DelTlxEditCheck_Ev01E00047	; 0x01E00045
	.short	HDAE5000_DelTlxEditCheck_Ev01E00046 - HDAE5000_DelTlxEditCheck_Ev01E00047	; 0x01E00046
	.short	HDAE5000_DelTlxEditCheck_Ev01E00047 - HDAE5000_DelTlxEditCheck_Ev01E00047	; 0x01E00047
HDAE5000_Str_Timb:
	; read by ErrMsgTimerCatch at 0x28B44C (lda operand)
	.asciz "TimB"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_TLBN:
	; read by ErrMsgTimerCatchLBN at 0x28B4D8 (lda operand)
	.asciz "TLBN"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_Palette_Button01 (0x2E3064, 1024 B): 256 RGBX entries, entry i =
; (i, i, i, 0) -- a grey ramp -- placed, as everywhere in this ROM's
; graphics bank, immediately before its bitmap (HDAE5000_Bitmap_Button01).
; No code in this ROM reads it; whether the main CPU does (at the bitmap
; pointer - 0x400) is not established.
;
HDAE5000_Palette_Button01:
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x00, 0x02, 0x02, 0x02, 0x00, 0x03, 0x03, 0x03, 0x00
	.byte 0x04, 0x04, 0x04, 0x00, 0x05, 0x05, 0x05, 0x00, 0x06, 0x06, 0x06, 0x00, 0x07, 0x07, 0x07, 0x00
	.byte 0x08, 0x08, 0x08, 0x00, 0x09, 0x09, 0x09, 0x00, 0x0a, 0x0a, 0x0a, 0x00, 0x0b, 0x0b, 0x0b, 0x00
	.byte 0x0c, 0x0c, 0x0c, 0x00, 0x0d, 0x0d, 0x0d, 0x00, 0x0e, 0x0e, 0x0e, 0x00, 0x0f, 0x0f, 0x0f, 0x00
	.byte 0x10, 0x10, 0x10, 0x00, 0x11, 0x11, 0x11, 0x00, 0x12, 0x12, 0x12, 0x00, 0x13, 0x13, 0x13, 0x00
	.byte 0x14, 0x14, 0x14, 0x00, 0x15, 0x15, 0x15, 0x00, 0x16, 0x16, 0x16, 0x00, 0x17, 0x17, 0x17, 0x00
	.byte 0x18, 0x18, 0x18, 0x00, 0x19, 0x19, 0x19, 0x00, 0x1a, 0x1a, 0x1a, 0x00, 0x1b, 0x1b, 0x1b, 0x00
	.byte 0x1c, 0x1c, 0x1c, 0x00, 0x1d, 0x1d, 0x1d, 0x00, 0x1e, 0x1e, 0x1e, 0x00, 0x1f, 0x1f, 0x1f, 0x00
	.byte 0x20, 0x20, 0x20, 0x00, 0x21, 0x21, 0x21, 0x00, 0x22, 0x22, 0x22, 0x00, 0x23, 0x23, 0x23, 0x00
	.byte 0x24, 0x24, 0x24, 0x00, 0x25, 0x25, 0x25, 0x00, 0x26, 0x26, 0x26, 0x00, 0x27, 0x27, 0x27, 0x00
	.byte 0x28, 0x28, 0x28, 0x00, 0x29, 0x29, 0x29, 0x00, 0x2a, 0x2a, 0x2a, 0x00, 0x2b, 0x2b, 0x2b, 0x00
	.byte 0x2c, 0x2c, 0x2c, 0x00, 0x2d, 0x2d, 0x2d, 0x00, 0x2e, 0x2e, 0x2e, 0x00, 0x2f, 0x2f, 0x2f, 0x00
	.byte 0x30, 0x30, 0x30, 0x00, 0x31, 0x31, 0x31, 0x00, 0x32, 0x32, 0x32, 0x00, 0x33, 0x33, 0x33, 0x00
	.byte 0x34, 0x34, 0x34, 0x00, 0x35, 0x35, 0x35, 0x00, 0x36, 0x36, 0x36, 0x00, 0x37, 0x37, 0x37, 0x00
	.byte 0x38, 0x38, 0x38, 0x00, 0x39, 0x39, 0x39, 0x00, 0x3a, 0x3a, 0x3a, 0x00, 0x3b, 0x3b, 0x3b, 0x00
	.byte 0x3c, 0x3c, 0x3c, 0x00, 0x3d, 0x3d, 0x3d, 0x00, 0x3e, 0x3e, 0x3e, 0x00, 0x3f, 0x3f, 0x3f, 0x00
	.byte 0x40, 0x40, 0x40, 0x00, 0x41, 0x41, 0x41, 0x00, 0x42, 0x42, 0x42, 0x00, 0x43, 0x43, 0x43, 0x00
	.byte 0x44, 0x44, 0x44, 0x00, 0x45, 0x45, 0x45, 0x00, 0x46, 0x46, 0x46, 0x00, 0x47, 0x47, 0x47, 0x00
	.byte 0x48, 0x48, 0x48, 0x00, 0x49, 0x49, 0x49, 0x00, 0x4a, 0x4a, 0x4a, 0x00, 0x4b, 0x4b, 0x4b, 0x00
	.byte 0x4c, 0x4c, 0x4c, 0x00, 0x4d, 0x4d, 0x4d, 0x00, 0x4e, 0x4e, 0x4e, 0x00, 0x4f, 0x4f, 0x4f, 0x00
	.byte 0x50, 0x50, 0x50, 0x00, 0x51, 0x51, 0x51, 0x00, 0x52, 0x52, 0x52, 0x00, 0x53, 0x53, 0x53, 0x00
	.byte 0x54, 0x54, 0x54, 0x00, 0x55, 0x55, 0x55, 0x00, 0x56, 0x56, 0x56, 0x00, 0x57, 0x57, 0x57, 0x00
	.byte 0x58, 0x58, 0x58, 0x00, 0x59, 0x59, 0x59, 0x00, 0x5a, 0x5a, 0x5a, 0x00, 0x5b, 0x5b, 0x5b, 0x00
	.byte 0x5c, 0x5c, 0x5c, 0x00, 0x5d, 0x5d, 0x5d, 0x00, 0x5e, 0x5e, 0x5e, 0x00, 0x5f, 0x5f, 0x5f, 0x00
	.byte 0x60, 0x60, 0x60, 0x00, 0x61, 0x61, 0x61, 0x00, 0x62, 0x62, 0x62, 0x00, 0x63, 0x63, 0x63, 0x00
	.byte 0x64, 0x64, 0x64, 0x00, 0x65, 0x65, 0x65, 0x00, 0x66, 0x66, 0x66, 0x00, 0x67, 0x67, 0x67, 0x00
	.byte 0x68, 0x68, 0x68, 0x00, 0x69, 0x69, 0x69, 0x00, 0x6a, 0x6a, 0x6a, 0x00, 0x6b, 0x6b, 0x6b, 0x00
	.byte 0x6c, 0x6c, 0x6c, 0x00, 0x6d, 0x6d, 0x6d, 0x00, 0x6e, 0x6e, 0x6e, 0x00, 0x6f, 0x6f, 0x6f, 0x00
	.byte 0x70, 0x70, 0x70, 0x00, 0x71, 0x71, 0x71, 0x00, 0x72, 0x72, 0x72, 0x00, 0x73, 0x73, 0x73, 0x00
	.byte 0x74, 0x74, 0x74, 0x00, 0x75, 0x75, 0x75, 0x00, 0x76, 0x76, 0x76, 0x00, 0x77, 0x77, 0x77, 0x00
	.byte 0x78, 0x78, 0x78, 0x00, 0x79, 0x79, 0x79, 0x00, 0x7a, 0x7a, 0x7a, 0x00, 0x7b, 0x7b, 0x7b, 0x00
	.byte 0x7c, 0x7c, 0x7c, 0x00, 0x7d, 0x7d, 0x7d, 0x00, 0x7e, 0x7e, 0x7e, 0x00, 0x7f, 0x7f, 0x7f, 0x00
	.byte 0x80, 0x80, 0x80, 0x00, 0x81, 0x81, 0x81, 0x00, 0x82, 0x82, 0x82, 0x00, 0x83, 0x83, 0x83, 0x00
	.byte 0x84, 0x84, 0x84, 0x00, 0x85, 0x85, 0x85, 0x00, 0x86, 0x86, 0x86, 0x00, 0x87, 0x87, 0x87, 0x00
	.byte 0x88, 0x88, 0x88, 0x00, 0x89, 0x89, 0x89, 0x00, 0x8a, 0x8a, 0x8a, 0x00, 0x8b, 0x8b, 0x8b, 0x00
	.byte 0x8c, 0x8c, 0x8c, 0x00, 0x8d, 0x8d, 0x8d, 0x00, 0x8e, 0x8e, 0x8e, 0x00, 0x8f, 0x8f, 0x8f, 0x00
	.byte 0x90, 0x90, 0x90, 0x00, 0x91, 0x91, 0x91, 0x00, 0x92, 0x92, 0x92, 0x00, 0x93, 0x93, 0x93, 0x00
	.byte 0x94, 0x94, 0x94, 0x00, 0x95, 0x95, 0x95, 0x00, 0x96, 0x96, 0x96, 0x00, 0x97, 0x97, 0x97, 0x00
	.byte 0x98, 0x98, 0x98, 0x00, 0x99, 0x99, 0x99, 0x00, 0x9a, 0x9a, 0x9a, 0x00, 0x9b, 0x9b, 0x9b, 0x00
	.byte 0x9c, 0x9c, 0x9c, 0x00, 0x9d, 0x9d, 0x9d, 0x00, 0x9e, 0x9e, 0x9e, 0x00, 0x9f, 0x9f, 0x9f, 0x00
	.byte 0xa0, 0xa0, 0xa0, 0x00, 0xa1, 0xa1, 0xa1, 0x00, 0xa2, 0xa2, 0xa2, 0x00, 0xa3, 0xa3, 0xa3, 0x00
	.byte 0xa4, 0xa4, 0xa4, 0x00, 0xa5, 0xa5, 0xa5, 0x00, 0xa6, 0xa6, 0xa6, 0x00, 0xa7, 0xa7, 0xa7, 0x00
	.byte 0xa8, 0xa8, 0xa8, 0x00, 0xa9, 0xa9, 0xa9, 0x00, 0xaa, 0xaa, 0xaa, 0x00, 0xab, 0xab, 0xab, 0x00
	.byte 0xac, 0xac, 0xac, 0x00, 0xad, 0xad, 0xad, 0x00, 0xae, 0xae, 0xae, 0x00, 0xaf, 0xaf, 0xaf, 0x00
	.byte 0xb0, 0xb0, 0xb0, 0x00, 0xb1, 0xb1, 0xb1, 0x00, 0xb2, 0xb2, 0xb2, 0x00, 0xb3, 0xb3, 0xb3, 0x00
	.byte 0xb4, 0xb4, 0xb4, 0x00, 0xb5, 0xb5, 0xb5, 0x00, 0xb6, 0xb6, 0xb6, 0x00, 0xb7, 0xb7, 0xb7, 0x00
	.byte 0xb8, 0xb8, 0xb8, 0x00, 0xb9, 0xb9, 0xb9, 0x00, 0xba, 0xba, 0xba, 0x00, 0xbb, 0xbb, 0xbb, 0x00
	.byte 0xbc, 0xbc, 0xbc, 0x00, 0xbd, 0xbd, 0xbd, 0x00, 0xbe, 0xbe, 0xbe, 0x00, 0xbf, 0xbf, 0xbf, 0x00
	.byte 0xc0, 0xc0, 0xc0, 0x00, 0xc1, 0xc1, 0xc1, 0x00, 0xc2, 0xc2, 0xc2, 0x00, 0xc3, 0xc3, 0xc3, 0x00
	.byte 0xc4, 0xc4, 0xc4, 0x00, 0xc5, 0xc5, 0xc5, 0x00, 0xc6, 0xc6, 0xc6, 0x00, 0xc7, 0xc7, 0xc7, 0x00
	.byte 0xc8, 0xc8, 0xc8, 0x00, 0xc9, 0xc9, 0xc9, 0x00, 0xca, 0xca, 0xca, 0x00, 0xcb, 0xcb, 0xcb, 0x00
	.byte 0xcc, 0xcc, 0xcc, 0x00, 0xcd, 0xcd, 0xcd, 0x00, 0xce, 0xce, 0xce, 0x00, 0xcf, 0xcf, 0xcf, 0x00
	.byte 0xd0, 0xd0, 0xd0, 0x00, 0xd1, 0xd1, 0xd1, 0x00, 0xd2, 0xd2, 0xd2, 0x00, 0xd3, 0xd3, 0xd3, 0x00
	.byte 0xd4, 0xd4, 0xd4, 0x00, 0xd5, 0xd5, 0xd5, 0x00, 0xd6, 0xd6, 0xd6, 0x00, 0xd7, 0xd7, 0xd7, 0x00
	.byte 0xd8, 0xd8, 0xd8, 0x00, 0xd9, 0xd9, 0xd9, 0x00, 0xda, 0xda, 0xda, 0x00, 0xdb, 0xdb, 0xdb, 0x00
	.byte 0xdc, 0xdc, 0xdc, 0x00, 0xdd, 0xdd, 0xdd, 0x00, 0xde, 0xde, 0xde, 0x00, 0xdf, 0xdf, 0xdf, 0x00
	.byte 0xe0, 0xe0, 0xe0, 0x00, 0xe1, 0xe1, 0xe1, 0x00, 0xe2, 0xe2, 0xe2, 0x00, 0xe3, 0xe3, 0xe3, 0x00
	.byte 0xe4, 0xe4, 0xe4, 0x00, 0xe5, 0xe5, 0xe5, 0x00, 0xe6, 0xe6, 0xe6, 0x00, 0xe7, 0xe7, 0xe7, 0x00
	.byte 0xe8, 0xe8, 0xe8, 0x00, 0xe9, 0xe9, 0xe9, 0x00, 0xea, 0xea, 0xea, 0x00, 0xeb, 0xeb, 0xeb, 0x00
	.byte 0xec, 0xec, 0xec, 0x00, 0xed, 0xed, 0xed, 0x00, 0xee, 0xee, 0xee, 0x00, 0xef, 0xef, 0xef, 0x00
	.byte 0xf0, 0xf0, 0xf0, 0x00, 0xf1, 0xf1, 0xf1, 0x00, 0xf2, 0xf2, 0xf2, 0x00, 0xf3, 0xf3, 0xf3, 0x00
	.byte 0xf4, 0xf4, 0xf4, 0x00, 0xf5, 0xf5, 0xf5, 0x00, 0xf6, 0xf6, 0xf6, 0x00, 0xf7, 0xf7, 0xf7, 0x00
	.byte 0xf8, 0xf8, 0xf8, 0x00, 0xf9, 0xf9, 0xf9, 0x00, 0xfa, 0xfa, 0xfa, 0x00, 0xfb, 0xfb, 0xfb, 0x00
	.byte 0xfc, 0xfc, 0xfc, 0x00, 0xfd, 0xfd, 0xfd, 0x00, 0xfe, 0xfe, 0xfe, 0x00, 0xff, 0xff, 0xff, 0x00
;
; HDAE5000_Bitmap_Button01 (0x2E3464, 42 x 15 = 630 B, 8 bpp, one row per
; line): the image of UI object "BitmapButt01".  Its handler
; HDAE5000_BitmapButt01 (0x28B527) answers EVT_GET_BITMAP_DATA 0x01E000A1 with
; this address, EVT_GET_BITMAP_WIDTH 0x01E000A2 with 42 and EVT_GET_BITMAP_HEIGHT
; 0x01E000A3 with 15 (the same protocol the main CPU's bitmap objects use).
;
HDAE5000_Bitmap_Button01:	.incbin	"images/HDAE5000_Bitmap_Button01.bin"	; census: generated -- scripts/build/indexed_images.py, from hdae5000/images/HDAE5000_Bitmap_Button01.png
HDAE5000_Str_Aclanguage1:
	; read by AcLanguageText1Proc at 0x28B5A1 (lda operand)
	.asciz "AcLanguage1"
HDAE5000_Str_LANENG00:
	; read by AcLanguageText1Proc at 0x28B60B (pushed operand)
	.asciz "LANENG00"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_LANDEU00:
	; read by AcLanguageText1Proc at 0x28B62A (pushed operand)
	.asciz "LANDEU00"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_LANFRA00:
	; read by AcLanguageText1Proc at 0x28B649 (pushed operand)
	.asciz "LANFRA00"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)

; ----------------------------------------------------------------------------
; HDAE5000_Multilingual_Messages (0x2E3704-0x2E5ADF, 9,180 bytes): the texts of
; UI class 016A:000A ("AcLanguageText1Proc", 122 objects in the UI pool), 232
; NUL-terminated strings, word-aligned.
; READER: HDAE5000_AcLanguageText1Proc (0x28B554).  It takes a message number
; N from its object (+0x1A of the descriptor it fetches), switches through
; HDAE5000_LangText_CaseTable (below, after the strings), and each case copies
; one of three strings -- by the language word at (xsp+4): 1 English, 2
; German, 3 French -- into its buffer with HDAE5000_StrCpy.  The pointer is
; pushed as two halves (`pushw 0x002e` / `pushw 0xLLLL`; the low-half line
; names the string label).  N = 1..67 and 200..212; 63, 204, 205 and any
; out-of-range N print "No Message".  Every string here is used by exactly the
; cases found (scripts/converters/hdae5000_label_langtext.py asserts it and
; prints the counts); each carries a label HDAE5000_LangMsg_<N>_<EN|DE|FR>.
; This block label and the first string's label mark the same byte.
; ----------------------------------------------------------------------------
HDAE5000_Multilingual_Messages:
	; Trilingual UI messages (EN/DE/FR)
HDAE5000_LangMsg_001_EN:
	; message 1, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Would you really delete the selected directory?"
HDAE5000_LangMsg_001_DE:
	; message 1, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Moechten Sie das angewaehlte Verzeichnis wirklich loeschen?"
HDAE5000_LangMsg_001_FR:
	; message 1, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Voulez-vous effacer ce r"
	.byte 0xe9  ; "é"
	.asciz "pertoir?"
HDAE5000_LangMsg_002_EN:
	; message 2, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Would you really delete the selected title?"
HDAE5000_LangMsg_002_DE:
	; message 2, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Moechten Sie den angewaehlten Titel wirklich loeschen?"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_002_FR:
	; message 2, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Voulez-vous effacer ce titre?"
HDAE5000_LangMsg_003_EN:
	; message 3, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "COPY FD TO HARD DISK"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_003_DE:
	; message 3, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "COPY FD TO HARD DISK"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_003_FR:
	; message 3, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "COPY FD TO HARD DISK"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_004_EN:
	; message 4, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "OUTPUT SETTING"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_004_DE:
	; message 4, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "OUTPUT SETTING"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_004_FR:
	; message 4, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "OUTPUT SETTING"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_005_EN:
	; message 5, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "SELECT BY   NAME    "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_005_DE:
	; message 5, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "SELECT BY   NAME    "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_005_FR:
	; message 5, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "SELECT BY   NAME    "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_006_EN:
	; message 6, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "LOAD BY     NUMBER"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_006_DE:
	; message 6, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "LOAD BY     NUMBER"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_006_FR:
	; message 6, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "LOAD BY     NUMBER"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_007_EN:
	; message 7, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "SELECT FILE LOAD SCRIPT"
HDAE5000_LangMsg_007_DE:
	; message 7, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "SELECT FILE LOAD SCRIPT"
HDAE5000_LangMsg_007_FR:
	; message 7, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "SELECT FILE LOAD SCRIPT"
HDAE5000_LangMsg_008_EN:
	; message 8, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "WRITE PROTECT: "
HDAE5000_LangMsg_008_DE:
	; message 8, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "WRITE PROTECT: "
HDAE5000_LangMsg_008_FR:
	; message 8, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "WRITE PROTECT: "
HDAE5000_LangMsg_009_EN:
	; message 9, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "WRITE CONFIRM: "
HDAE5000_LangMsg_009_DE:
	; message 9, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "WRITE CONFIRM: "
HDAE5000_LangMsg_009_FR:
	; message 9, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "WRITE CONFIRM: "
HDAE5000_LangMsg_010_EN:
	; message 10, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "ABOUT & HELP "
HDAE5000_LangMsg_010_DE:
	; message 10, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "ABOUT & HELP "
HDAE5000_LangMsg_010_FR:
	; message 10, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "ABOUT & HELP "
HDAE5000_LangMsg_011_EN:
	; message 11, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "SAVE SETUP"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_011_DE:
	; message 11, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "SAVE SETUP"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_011_FR:
	; message 11, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "SAVE SETUP"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_012_EN:
	; message 12, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "OUTPUT SETTING"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_012_DE:
	; message 12, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "OUTPUT SETTING"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_012_FR:
	; message 12, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "OUTPUT SETTING"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_013_EN:
	; message 13, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "SEPARATE OUTPUT MODE:"
HDAE5000_LangMsg_013_DE:
	; message 13, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "SEPARATE OUTPUT MODE:"
HDAE5000_LangMsg_013_FR:
	; message 13, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "SEPARATE OUTPUT MODE:"
HDAE5000_LangMsg_014_EN:
	; message 14, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "PART SELECT FOR SEQ.DRUMS OUT:"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_014_DE:
	; message 14, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "PART SELECT FOR SEQ.DRUMS OUT:"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_014_FR:
	; message 14, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "PART SELECT FOR SEQ.DRUMS OUT:"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_015_EN:
	; message 15, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "PART SELECT FOR SEQ.BASS  OUT:"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_015_DE:
	; message 15, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "PART SELECT FOR SEQ.BASS  OUT:"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_015_FR:
	; message 15, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "PART SELECT FOR SEQ.BASS  OUT:"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_016_EN:
	; message 16, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "! The separate outputs cannot be controlled by the internal volume control."
HDAE5000_LangMsg_016_DE:
	; message 16, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "! Die separaten Ausgaenge werden nicht durch Volumen am Keyboard kontrolliert."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_016_FR:
	; message 16, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "! Les sortie s"
	.byte 0xe9  ; "é"
	.ascii "par"
	.byte 0xe9  ; "é"
	.ascii "es ne peuvent pas "
	.byte 0xea  ; "ê"
	.ascii "tre control"
	.byte 0xe9  ; "é"
	.asciz "es par les volume du calvier."
HDAE5000_LangMsg_017_EN:
	; message 17, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Hardware and software developement:"
HDAE5000_LangMsg_017_DE:
	; message 17, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Hardware und Software Entwicklung:"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_017_FR:
	; message 17, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Hardware et Software developement:"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_018_EN:
	; message 18, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Conception, marketing, sales and service:"
HDAE5000_LangMsg_018_DE:
	; message 18, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Konzeption, Marketing, Verkauf und Service:"
HDAE5000_LangMsg_018_FR:
	; message 18, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Conception, Marketing, Vente et Service:"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_019_EN:
	; message 19, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "All rigths reserved by the called companies"
HDAE5000_LangMsg_019_DE:
	; message 19, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Alle Rechte bei den obengenannten Firmen"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_019_FR:
	; message 19, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "All rigths reserved by the called companies"
HDAE5000_LangMsg_020_EN:
	; message 20, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Special thanks to:"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_020_DE:
	; message 20, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Spezieller Dank an:"
HDAE5000_LangMsg_020_FR:
	; message 20, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Special thanks to:"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_021_EN:
	; message 21, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Press 3 digits for directory and 2 digits for the file."
HDAE5000_LangMsg_021_DE:
	; message 21, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Geben Sie 3 Ziffern fuer das Verzeichnis und 2 Ziffern fuer den Titel ein."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_021_FR:
	; message 21, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Introduisez 3 chiffres pour le r"
	.byte 0xe9  ; "é"
	.asciz "pertoir at 2 chiffres pour le titre."
HDAE5000_LangMsg_022_EN:
	; message 22, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Do you really want to overwrite this FLS entry?"
HDAE5000_LangMsg_022_DE:
	; message 22, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Wollen Sie den bestehenden FLS Eintrag wirklich ueberschreiben?"
HDAE5000_LangMsg_022_FR:
	; message 22, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Voulez-vous vraiment "
	.byte 0xe9  ; "é"
	.asciz "crire par dessus le FLS?"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_023_EN:
	; message 23, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Do you really want to delete this FLS entry?"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_023_DE:
	; message 23, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Wollen Sie den bestehenden FLS Eintrag wirklich loeschen?"
HDAE5000_LangMsg_023_FR:
	; message 23, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Voulez-vous vraiment effacer ce FLS?"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_024_EN:
	; message 24, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "HD FORMAT will erase all files at once."
HDAE5000_LangMsg_024_DE:
	; message 24, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "HD FORMAT loescht alle Daten auf der Festplatte."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_024_FR:
	; message 24, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "HD-FORMAT effacera toutes les donn"
	.byte 0xe9  ; "é"
	.asciz "es de votre disque dur."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_025_EN:
	; message 25, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Therefore you need a 6-digit key code. Please refer your owners manual chapter SETUP & TOOLS."
HDAE5000_LangMsg_025_DE:
	; message 25, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Geben Sie auf dieser Seite den 6-stelligen Code ein. Schauen Sie in der Anleitung unter SETUP & TOOLS nach."
HDAE5000_LangMsg_025_FR:
	; message 25, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Indroduisez le code "
	.byte 0xe0  ; "à"
	.ascii " 6 chiffres et r"
	.byte 0xe9  ; "é"
	.ascii "f"
	.byte 0xe9  ; "é"
	.ascii "rez-vous "
	.byte 0xe0  ; "à"
	.asciz " votre manuel dans (SETUP & TOOLS)."
HDAE5000_LangMsg_026_EN:
	; message 26, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "After your code input all data will be deleted irrevocable!"
HDAE5000_LangMsg_026_DE:
	; message 26, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Nach der Codeeingabe werden alle Daten unwiderruflich geloescht!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_026_FR:
	; message 26, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Apr"
	.byte 0xe8  ; "è"
	.ascii "s l'introduction du code, toutes les donn"
	.byte 0xe9  ; "é"
	.ascii "es seront effac"
	.byte 0xe9  ; "é"
	.asciz "es."
HDAE5000_LangMsg_027_EN:
	; message 27, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "You are going to delete a FLS entry. Are you sure?"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_027_DE:
	; message 27, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Sie haben einen FLS Eintrag zum Loeschen markiert. Sind Sie sicher?"
HDAE5000_LangMsg_027_FR:
	; message 27, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Vous avez marquer un FLS connection pour effacer. Vous ait sure?"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_028_EN:
	; message 28, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "You are going to overwrite a FLS entry. Are you sure?"
HDAE5000_LangMsg_028_DE:
	; message 28, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Sie ueberschreiben eine bestehenden FLS Eintrag. Sind Sie sicher?"
HDAE5000_LangMsg_028_FR:
	; message 28, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Voulez-vous vraiment transcrire ce FLS enregistration?"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_029_EN:
	; message 29, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "The hard disk is write protected!"
HDAE5000_LangMsg_029_DE:
	; message 29, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.ascii "Die Festplatte ist schreibgesch"
	.byte 0xfc  ; "ü"
	.asciz "tzt!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_029_FR:
	; message 29, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Le disque dur est prot"
	.byte 0xe9  ; "é"
	.ascii "ger contre l'"
	.byte 0xe9  ; "é"
	.asciz "ctriture!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_030_EN:
	; message 30, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Please set the write protect mode to OFF."
HDAE5000_LangMsg_030_DE:
	; message 30, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Schalten Sie WRITE PROTECT im SETUP & TOOLS auf OFF."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_030_FR:
	; message 30, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Pour "
	.byte 0xe9  ; "é"
	.asciz "crire mettez la protection sur OFF."
HDAE5000_LangMsg_031_EN:
	; message 31, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "The hard disk is not formatted!"
HDAE5000_LangMsg_031_DE:
	; message 31, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Die Festplatte ist nicht formatiert!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_031_FR:
	; message 31, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Le disque dur n'est pas format"
	.byte 0xe9  ; "é"
	.asciz "."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_032_EN:
	; message 32, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Hard disk SRAM error."
HDAE5000_LangMsg_032_DE:
	; message 32, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Im HD-AE5000 SRAM ist ein Fehler aufgetreten."
HDAE5000_LangMsg_032_FR:
	; message 32, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Il y a un problem avec le SRAM de HD-AE5000."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_033_EN:
	; message 33, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Hard disk reset error."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_033_DE:
	; message 33, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Die Festplatte konnte nicht initialisiert werden."
HDAE5000_LangMsg_033_FR:
	; message 33, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Votre disque dur n'est pas reconnu."
HDAE5000_LangMsg_034_EN:
	; message 34, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Hard disk read error."
HDAE5000_LangMsg_034_DE:
	; message 34, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Beim Lesen der Festplatte ist ein Fehler aufgetreten."
HDAE5000_LangMsg_034_FR:
	; message 34, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Il y a un probl"
	.byte 0xe9  ; "é"
	.asciz "me de leture du disque."
HDAE5000_LangMsg_035_EN:
	; message 35, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Hard disk ID read error."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_035_DE:
	; message 35, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Die ID der Festplatte konnte nicht gelesen werden."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_035_FR:
	; message 35, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "L'ID du disque dur n'a pas pu "
	.byte 0xea  ; "ê"
	.asciz "tre lue."
HDAE5000_LangMsg_036_EN:
	; message 36, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Hard disk track 0 error."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_036_DE:
	; message 36, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Track O der Festplatte konnte nicht gelesen werden."
HDAE5000_LangMsg_036_FR:
	; message 36, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "La piste 0 du disque dur n'a pas pu "
	.byte 0xea  ; "ê"
	.asciz "tre lue."
HDAE5000_LangMsg_037_EN:
	; message 37, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Hard disk FAT read error."
HDAE5000_LangMsg_037_DE:
	; message 37, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Die FAT der Festplatte konnte nicht gelesen werden."
HDAE5000_LangMsg_037_FR:
	; message 37, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Le FAT du disque dur n'a pas pu "
	.byte 0xea  ; "ê"
	.asciz "tre lue."
HDAE5000_LangMsg_038_EN:
	; message 38, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Hard disk FSB read error."
HDAE5000_LangMsg_038_DE:
	; message 38, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Der FSB der Festplatte konnte nicht gelesen werden."
HDAE5000_LangMsg_038_FR:
	; message 38, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Le FSB du disque dur n'a pas pu "
	.byte 0xea  ; "ê"
	.asciz "tre lue."
HDAE5000_LangMsg_039_EN:
	; message 39, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "There are no files marked for copy to HD!"
HDAE5000_LangMsg_039_DE:
	; message 39, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Es wurden keine Titel zum Kopieren gefunden."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_039_FR:
	; message 39, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Aucun titre n'a "
	.byte 0xe9  ; "é"
	.ascii "t"
	.byte 0xe9  ; "é"
	.ascii " marqu"
	.byte 0xe9  ; "é"
	.asciz " pour faire des copies."
HDAE5000_LangMsg_040_EN:
	; message 40, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Please make a safety backup of your data and call your service center."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_040_DE:
	; message 40, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Sichern Sie alle Ihre Daten auf Diskette oder den PC und rufen Sie Ihre Service-Stelle an."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_040_FR:
	; message 40, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Sauvez vos donn"
	.byte 0xe9  ; "é"
	.asciz "e sur disquette ou l'ordinateur et contactez votre service assistance."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_041_EN:
	; message 41, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Please make a safety backup of your data and call your service center."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_041_DE:
	; message 41, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Sichern Sie alle Ihre Daten auf Diskette oder den PC und rufen Sie Ihre Service-Stelle an."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_041_FR:
	; message 41, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Sauvez vos donn"
	.byte 0xe9  ; "é"
	.asciz "e sur disquette ou l'ordinateur et contactez votre service assistance."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_042_EN:
	; message 42, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "The data on the disk you would like to copy to HD has no KN5000 format or some data are corrupted."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_042_DE:
	; message 42, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Die Daten auf der Diskette die Sie kopieren moechten, haben keine KN5000 ID oder sind fehlerhaft."
HDAE5000_LangMsg_042_FR:
	; message 42, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Les donn"
	.byte 0xe9  ; "é"
	.ascii "es que vous voulez charger ne sont pas du KN5000 format ou ont des d"
	.byte 0xe9  ; "é"
	.asciz "faults."
HDAE5000_LangMsg_043_EN:
	; message 43, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "The number or marked songs cannot fit in the free space of the selected directory."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_043_DE:
	; message 43, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Im gewuenschten Verzeichnis sind nicht genuegend freie Plaetze fuer die Anzahl markierter Titel."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_043_FR:
	; message 43, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Le r"
	.byte 0xe9  ; "é"
	.ascii "pertoir est satur"
	.byte 0xe9  ; "é"
	.ascii ", il n'y "
	.byte 0xe0  ; "à"
	.asciz " plus de place pour d'autres titre."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_044_EN:
	; message 44, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Reduce the number of selected songs or find a free directory."
HDAE5000_LangMsg_044_DE:
	; message 44, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Reduzieren Sie die Zahl der Titel oder waehlen Sie ein anderes Verzeichnis."
HDAE5000_LangMsg_044_FR:
	; message 44, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Changer de r"
	.byte 0xe9  ; "é"
	.asciz "pertoire ou supprimez des titres."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_045_EN:
	; message 45, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "You cannot copy files/songs to an unnamed directory."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_045_DE:
	; message 45, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Kopieren Sie keine Titel in ein nicht beschriftetes Verzeichnis."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_045_FR:
	; message 45, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Vous ne pouvez pas copier des titres dans un r"
	.byte 0xe9  ; "é"
	.ascii "pertoire pas pr"
	.byte 0xe9  ; "é"
	.ascii "par"
	.byte 0xe9  ; "é"
	.asciz "."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_046_EN:
	; message 46, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Please use a named directory or create the new directory with EDIT first."
HDAE5000_LangMsg_046_DE:
	; message 46, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Waehlen Sie ein bereits beschriftetes Verzeichnis oder benennen Sie es zuvor mit EDIT."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_046_FR:
	; message 46, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Nommez-le d'abord par example avec EDIT."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_047_EN:
	; message 47, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "The DIR number is out of range."
HDAE5000_LangMsg_047_DE:
	; message 47, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Sie haben eine ungueltige Verzeichnis Nummer eingegeben."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_047_FR:
	; message 47, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Le r"
	.byte 0xe9  ; "é"
	.asciz "pertoire choisi n'existe pas."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_048_EN:
	; message 48, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "The file number is out of range."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_048_DE:
	; message 48, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Die eingegebene Nummer existiert nicht."
HDAE5000_LangMsg_048_FR:
	; message 48, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Le titre choisi n'existe pas."
HDAE5000_LangMsg_049_EN:
	; message 49, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Please wait ..."
HDAE5000_LangMsg_049_DE:
	; message 49, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Bitte warten ..."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_049_FR:
	; message 49, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Attendre S.V.P."
HDAE5000_LangMsg_050_EN:
	; message 50, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "!FORMAT ERROR!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_050_DE:
	; message 50, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "!FORMAT FEHLER!"
HDAE5000_LangMsg_050_FR:
	; message 50, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "!FORMAT ERREUR!"
HDAE5000_LangMsg_051_EN:
	; message 51, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "The automatic HD format was not successful!"
HDAE5000_LangMsg_051_DE:
	; message 51, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Die Formatierung war nicht erfolgreich!"
HDAE5000_LangMsg_051_FR:
	; message 51, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Le formatage du disque dur n'a pas pu se faire correctement!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_052_EN:
	; message 52, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Please try once more, refer your owners manual or ask your dealer/service center."
HDAE5000_LangMsg_052_DE:
	; message 52, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Versuchen Sie es nochmals, schauen Sie in der Anleitung nach oder rufen Sie Ihre Service-Stelle an."
HDAE5000_LangMsg_052_FR:
	; message 52, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "R"
	.byte 0xe9  ; "é"
	.ascii "p"
	.byte 0xe9  ; "é"
	.ascii "tez l'operation en vous r"
	.byte 0xe9  ; "é"
	.ascii "f"
	.byte 0xe9  ; "é"
	.ascii "rent au manuel ou en cas d'"
	.byte 0xe9  ; "é"
	.asciz "chec, contactez votre service assistance."
HDAE5000_LangMsg_053_EN:
	; message 53, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Input error!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_053_DE:
	; message 53, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Eingabe-Fehler!"
HDAE5000_LangMsg_053_FR:
	; message 53, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Erreur d'operation!"
HDAE5000_LangMsg_054_EN:
	; message 54, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "The key code input was wrong!"
HDAE5000_LangMsg_054_DE:
	; message 54, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Die Nummerneingabe war falsch!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_054_FR:
	; message 54, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Le cocde n'est pas correct!"
HDAE5000_LangMsg_055_EN:
	; message 55, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Please try once more, refer your owners manual or ask your dealer/service center."
HDAE5000_LangMsg_055_DE:
	; message 55, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Versuchen Sie es nochmals, schauen Sie in der Anleitung nach oder rufen Sie Ihre Service-Stelle an."
HDAE5000_LangMsg_055_FR:
	; message 55, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Veuillez r"
	.byte 0xe9  ; "é"
	.ascii "p"
	.byte 0xe9  ; "é"
	.ascii "ter l'ex"
	.byte 0xe9  ; "é"
	.ascii "cution et vous r"
	.byte 0xe9  ; "é"
	.ascii "f"
	.byte 0xe9  ; "é"
	.asciz "rez au manuel ou contactez votre service assistance."
HDAE5000_LangMsg_056_EN:
	; message 56, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Delete file from hard disk:"
HDAE5000_LangMsg_056_DE:
	; message 56, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Loesche Titel von Festplatte:"
HDAE5000_LangMsg_056_FR:
	; message 56, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Effacer titre du disque dur:"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_057_EN:
	; message 57, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "The hard disk will now be formatted. This procedure can take about 2-3 minutes."
HDAE5000_LangMsg_057_DE:
	; message 57, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Die Festplatte wird nun neu formatiert. Dieser Vorgang dauert ca. 2-3 Minuten."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	; message 57, language 3 (French): read by HDAE5000_AcLanguageText1Proc
HDAE5000_LangMsg_057_FR:
	; empty in v2.01i (v2.06i repeats the English text here)
	.asciz ""
	.balign 2, 0x00                       ; word-align pad
HDAE5000_LangMsg_058_EN:
	; message 58, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "We recommend to turn ON and OFF again the power after the complete format."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_058_DE:
	; message 58, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Wir empfehlen, nach der Formatierung das Keyboard aus und wieder einzuschalten."
	; message 58, language 3 (French): read by HDAE5000_AcLanguageText1Proc
HDAE5000_LangMsg_058_FR:
	; empty in v2.01i (v2.06i repeats the English text here)
	.asciz ""
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_059_EN:
	; message 59, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Track O will be recovered:"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_059_DE:
	; message 59, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Track 0 wird kontrolliert:"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	; message 59, language 3 (French): read by HDAE5000_AcLanguageText1Proc
HDAE5000_LangMsg_059_FR:
	; empty in v2.01i (v2.06i repeats the English text here)
	.asciz ""
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_060_EN:
	; message 60, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "The FLS entry remains free."
HDAE5000_LangMsg_060_DE:
	; message 60, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Der FLS Eintrag bleibt frei."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_060_FR:
	; message 60, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Ce FLS registartion reste libre."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_061_EN:
	; message 61, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "All following entries will be moved."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_061_DE:
	; message 61, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Alle nachfolgenden Eintraege werden nachgeschoben."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_061_FR:
	; message 61, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Tous les registartion suivant seront d"
	.byte 0xe9  ; "é"
	.asciz "placer."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_062_EN:
	; message 62, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Evaluation 01-01-99"
HDAE5000_LangMsg_062_DE:
	; message 62, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Test-Version 01-01-99"
HDAE5000_LangMsg_062_FR:
	; message 62, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.ascii "Version d'"
	.byte 0xe9  ; "é"
	.asciz "valuation"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
	; message 64, language 1 (English): read by HDAE5000_AcLanguageText1Proc.  v2.01i
	; only: its message 64 is the jump-after-load setting; v2.06i's is "LYRICS LOAD
	; MODE", and v2.06i adds messages 65-67 (lyric colour settings, overwrite query).
HDAE5000_LangMsg_064_EN:
	.asciz "Jump after Load"
HDAE5000_LangMsg_064_DE:
	; message 64, language 2 (German)
	.asciz "Springe nach laden"
	.balign 2, 0x00                       ; word-align pad
HDAE5000_LangMsg_064_FR:
	; message 64, language 3 (French), as the ROM has it
	.asciz "Gump\351\351 apr\350s ski"
	.balign 2, 0x00                       ; word-align pad
HDAE5000_LangMsg_200_EN:
	; message 200, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "YES"
HDAE5000_LangMsg_200_DE:
	; message 200, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "JA"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_200_FR:
	; message 200, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "OUI"
HDAE5000_LangMsg_201_EN:
	; message 201, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "NO"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_201_DE:
	; message 201, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "NEIN"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_201_FR:
	; message 201, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "NON"
HDAE5000_LangMsg_202_EN:
	; message 202, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "OK"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_202_DE:
	; message 202, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "OK"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_202_FR:
	; message 202, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "OK"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_203_EN:
	; message 203, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "CANCEL"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_203_DE:
	; message 203, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Abbruch"
HDAE5000_LangMsg_203_FR:
	; message 203, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "CANCEL"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_206_EN:
	; message 206, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Operation error!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_206_DE:
	; message 206, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Bedienungsfehler!"
HDAE5000_LangMsg_206_FR:
	; message 206, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Error d'operation!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_207_EN:
	; message 207, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "!SAVE ERROR!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_207_DE:
	; message 207, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "!SAVE-FEHLER!"
HDAE5000_LangMsg_207_FR:
	; message 207, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "!SAVE ERREUR!"
HDAE5000_LangMsg_208_EN:
	; message 208, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "!LOAD ERROR!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_208_DE:
	; message 208, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "!LOAD-FEHLER!"
HDAE5000_LangMsg_208_FR:
	; message 208, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "!LOAD ERREUR!"
HDAE5000_LangMsg_209_EN:
	; message 209, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "!SYSTEM ERROR!"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_209_DE:
	; message 209, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "!SYSTEM-FEHLER!"
HDAE5000_LangMsg_209_FR:
	; message 209, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "!SYSTEM ERREUR!"
HDAE5000_LangMsg_210_EN:
	; message 210, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "!ATTENTION!"
HDAE5000_LangMsg_210_DE:
	; message 210, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "!ACHTUNG!"
HDAE5000_LangMsg_210_FR:
	; message 210, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "!ATTENTION!"
HDAE5000_LangMsg_211_EN:
	; message 211, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Press YES for confirmation, NO to abort."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_211_DE:
	; message 211, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Bestaetigen Sie den Vorgang mit JA oder druecken Sie die NEIN Taste."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_211_FR:
	; message 211, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Pressez OUI pour confirmer ou NON pour annuler."
HDAE5000_LangMsg_212_EN:
	; message 212, language 1 (English): read by HDAE5000_AcLanguageText1Proc
	.asciz "Please call your dealer or service center."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_LangMsg_212_DE:
	; message 212, language 2 (German): read by HDAE5000_AcLanguageText1Proc
	.asciz "Bitte rufen Sie Ihre Service-Stelle an."
HDAE5000_LangMsg_212_FR:
	; message 212, language 3 (French): read by HDAE5000_AcLanguageText1Proc
	.asciz "Contactez votre service assistance."
HDAE5000_LangMsg_NoMessage:
	; the default text, all three languages: read by HDAE5000_AcLanguageText1Proc
	.asciz "No Message"
	.balign 2, 0x00					; pad after "No Message"
;
; HDAE5000_LangText_CaseTable (77 x u16): the message switch of
; HDAE5000_AcLanguageText1Proc.  Entry i serves message i+1 (i <= 0x3f) or
; i+0x88 (0x40 <= i <= 0x4c, the `sub wa,0x87` range); each value is an offset
; from HDAE5000_AcLanguageText1Proc_Msg001, the first case, and the reader
; jumps there (`jp T,XIX+WA`).  Messages 63, 204 and 205, and every number
; out of range, share the _NoMessage case.  v2.01i has no messages 65-67
; (v2.06i's table has 80 entries: 1-67 and 200-212).
;
HDAE5000_LangText_CaseTable:
	.short	HDAE5000_AcLanguageText1Proc_Msg001 - HDAE5000_AcLanguageText1Proc_Msg001	; message 1
	.short	HDAE5000_AcLanguageText1Proc_Msg002 - HDAE5000_AcLanguageText1Proc_Msg001	; message 2
	.short	HDAE5000_AcLanguageText1Proc_Msg003 - HDAE5000_AcLanguageText1Proc_Msg001	; message 3
	.short	HDAE5000_AcLanguageText1Proc_Msg004 - HDAE5000_AcLanguageText1Proc_Msg001	; message 4
	.short	HDAE5000_AcLanguageText1Proc_Msg005 - HDAE5000_AcLanguageText1Proc_Msg001	; message 5
	.short	HDAE5000_AcLanguageText1Proc_Msg006 - HDAE5000_AcLanguageText1Proc_Msg001	; message 6
	.short	HDAE5000_AcLanguageText1Proc_Msg007 - HDAE5000_AcLanguageText1Proc_Msg001	; message 7
	.short	HDAE5000_AcLanguageText1Proc_Msg008 - HDAE5000_AcLanguageText1Proc_Msg001	; message 8
	.short	HDAE5000_AcLanguageText1Proc_Msg009 - HDAE5000_AcLanguageText1Proc_Msg001	; message 9
	.short	HDAE5000_AcLanguageText1Proc_Msg010 - HDAE5000_AcLanguageText1Proc_Msg001	; message 10
	.short	HDAE5000_AcLanguageText1Proc_Msg011 - HDAE5000_AcLanguageText1Proc_Msg001	; message 11
	.short	HDAE5000_AcLanguageText1Proc_Msg012 - HDAE5000_AcLanguageText1Proc_Msg001	; message 12
	.short	HDAE5000_AcLanguageText1Proc_Msg013 - HDAE5000_AcLanguageText1Proc_Msg001	; message 13
	.short	HDAE5000_AcLanguageText1Proc_Msg014 - HDAE5000_AcLanguageText1Proc_Msg001	; message 14
	.short	HDAE5000_AcLanguageText1Proc_Msg015 - HDAE5000_AcLanguageText1Proc_Msg001	; message 15
	.short	HDAE5000_AcLanguageText1Proc_Msg016 - HDAE5000_AcLanguageText1Proc_Msg001	; message 16
	.short	HDAE5000_AcLanguageText1Proc_Msg017 - HDAE5000_AcLanguageText1Proc_Msg001	; message 17
	.short	HDAE5000_AcLanguageText1Proc_Msg018 - HDAE5000_AcLanguageText1Proc_Msg001	; message 18
	.short	HDAE5000_AcLanguageText1Proc_Msg019 - HDAE5000_AcLanguageText1Proc_Msg001	; message 19
	.short	HDAE5000_AcLanguageText1Proc_Msg020 - HDAE5000_AcLanguageText1Proc_Msg001	; message 20
	.short	HDAE5000_AcLanguageText1Proc_Msg021 - HDAE5000_AcLanguageText1Proc_Msg001	; message 21
	.short	HDAE5000_AcLanguageText1Proc_Msg022 - HDAE5000_AcLanguageText1Proc_Msg001	; message 22
	.short	HDAE5000_AcLanguageText1Proc_Msg023 - HDAE5000_AcLanguageText1Proc_Msg001	; message 23
	.short	HDAE5000_AcLanguageText1Proc_Msg024 - HDAE5000_AcLanguageText1Proc_Msg001	; message 24
	.short	HDAE5000_AcLanguageText1Proc_Msg025 - HDAE5000_AcLanguageText1Proc_Msg001	; message 25
	.short	HDAE5000_AcLanguageText1Proc_Msg026 - HDAE5000_AcLanguageText1Proc_Msg001	; message 26
	.short	HDAE5000_AcLanguageText1Proc_Msg027 - HDAE5000_AcLanguageText1Proc_Msg001	; message 27
	.short	HDAE5000_AcLanguageText1Proc_Msg028 - HDAE5000_AcLanguageText1Proc_Msg001	; message 28
	.short	HDAE5000_AcLanguageText1Proc_Msg029 - HDAE5000_AcLanguageText1Proc_Msg001	; message 29
	.short	HDAE5000_AcLanguageText1Proc_Msg030 - HDAE5000_AcLanguageText1Proc_Msg001	; message 30
	.short	HDAE5000_AcLanguageText1Proc_Msg031 - HDAE5000_AcLanguageText1Proc_Msg001	; message 31
	.short	HDAE5000_AcLanguageText1Proc_Msg032 - HDAE5000_AcLanguageText1Proc_Msg001	; message 32
	.short	HDAE5000_AcLanguageText1Proc_Msg033 - HDAE5000_AcLanguageText1Proc_Msg001	; message 33
	.short	HDAE5000_AcLanguageText1Proc_Msg034 - HDAE5000_AcLanguageText1Proc_Msg001	; message 34
	.short	HDAE5000_AcLanguageText1Proc_Msg035 - HDAE5000_AcLanguageText1Proc_Msg001	; message 35
	.short	HDAE5000_AcLanguageText1Proc_Msg036 - HDAE5000_AcLanguageText1Proc_Msg001	; message 36
	.short	HDAE5000_AcLanguageText1Proc_Msg037 - HDAE5000_AcLanguageText1Proc_Msg001	; message 37
	.short	HDAE5000_AcLanguageText1Proc_Msg038 - HDAE5000_AcLanguageText1Proc_Msg001	; message 38
	.short	HDAE5000_AcLanguageText1Proc_Msg039 - HDAE5000_AcLanguageText1Proc_Msg001	; message 39
	.short	HDAE5000_AcLanguageText1Proc_Msg040 - HDAE5000_AcLanguageText1Proc_Msg001	; message 40
	.short	HDAE5000_AcLanguageText1Proc_Msg041 - HDAE5000_AcLanguageText1Proc_Msg001	; message 41
	.short	HDAE5000_AcLanguageText1Proc_Msg042 - HDAE5000_AcLanguageText1Proc_Msg001	; message 42
	.short	HDAE5000_AcLanguageText1Proc_Msg043 - HDAE5000_AcLanguageText1Proc_Msg001	; message 43
	.short	HDAE5000_AcLanguageText1Proc_Msg044 - HDAE5000_AcLanguageText1Proc_Msg001	; message 44
	.short	HDAE5000_AcLanguageText1Proc_Msg045 - HDAE5000_AcLanguageText1Proc_Msg001	; message 45
	.short	HDAE5000_AcLanguageText1Proc_Msg046 - HDAE5000_AcLanguageText1Proc_Msg001	; message 46
	.short	HDAE5000_AcLanguageText1Proc_Msg047 - HDAE5000_AcLanguageText1Proc_Msg001	; message 47
	.short	HDAE5000_AcLanguageText1Proc_Msg048 - HDAE5000_AcLanguageText1Proc_Msg001	; message 48
	.short	HDAE5000_AcLanguageText1Proc_Msg049 - HDAE5000_AcLanguageText1Proc_Msg001	; message 49
	.short	HDAE5000_AcLanguageText1Proc_Msg050 - HDAE5000_AcLanguageText1Proc_Msg001	; message 50
	.short	HDAE5000_AcLanguageText1Proc_Msg051 - HDAE5000_AcLanguageText1Proc_Msg001	; message 51
	.short	HDAE5000_AcLanguageText1Proc_Msg052 - HDAE5000_AcLanguageText1Proc_Msg001	; message 52
	.short	HDAE5000_AcLanguageText1Proc_Msg053 - HDAE5000_AcLanguageText1Proc_Msg001	; message 53
	.short	HDAE5000_AcLanguageText1Proc_Msg054 - HDAE5000_AcLanguageText1Proc_Msg001	; message 54
	.short	HDAE5000_AcLanguageText1Proc_Msg055 - HDAE5000_AcLanguageText1Proc_Msg001	; message 55
	.short	HDAE5000_AcLanguageText1Proc_Msg056 - HDAE5000_AcLanguageText1Proc_Msg001	; message 56
	.short	HDAE5000_AcLanguageText1Proc_Msg057 - HDAE5000_AcLanguageText1Proc_Msg001	; message 57
	.short	HDAE5000_AcLanguageText1Proc_Msg058 - HDAE5000_AcLanguageText1Proc_Msg001	; message 58
	.short	HDAE5000_AcLanguageText1Proc_Msg059 - HDAE5000_AcLanguageText1Proc_Msg001	; message 59
	.short	HDAE5000_AcLanguageText1Proc_Msg060 - HDAE5000_AcLanguageText1Proc_Msg001	; message 60
	.short	HDAE5000_AcLanguageText1Proc_Msg061 - HDAE5000_AcLanguageText1Proc_Msg001	; message 61
	.short	HDAE5000_AcLanguageText1Proc_Msg062 - HDAE5000_AcLanguageText1Proc_Msg001	; message 62
	.short	HDAE5000_AcLanguageText1Proc_NoMessage - HDAE5000_AcLanguageText1Proc_Msg001	; message 63
	.short	HDAE5000_AcLanguageText1Proc_Msg064 - HDAE5000_AcLanguageText1Proc_Msg001	; message 64
	.short	HDAE5000_AcLanguageText1Proc_Msg200 - HDAE5000_AcLanguageText1Proc_Msg001	; message 200
	.short	HDAE5000_AcLanguageText1Proc_Msg201 - HDAE5000_AcLanguageText1Proc_Msg001	; message 201
	.short	HDAE5000_AcLanguageText1Proc_Msg202 - HDAE5000_AcLanguageText1Proc_Msg001	; message 202
	.short	HDAE5000_AcLanguageText1Proc_Msg203 - HDAE5000_AcLanguageText1Proc_Msg001	; message 203
	.short	HDAE5000_AcLanguageText1Proc_NoMessage - HDAE5000_AcLanguageText1Proc_Msg001	; message 204
	.short	HDAE5000_AcLanguageText1Proc_NoMessage - HDAE5000_AcLanguageText1Proc_Msg001	; message 205
	.short	HDAE5000_AcLanguageText1Proc_Msg206 - HDAE5000_AcLanguageText1Proc_Msg001	; message 206
	.short	HDAE5000_AcLanguageText1Proc_Msg207 - HDAE5000_AcLanguageText1Proc_Msg001	; message 207
	.short	HDAE5000_AcLanguageText1Proc_Msg208 - HDAE5000_AcLanguageText1Proc_Msg001	; message 208
	.short	HDAE5000_AcLanguageText1Proc_Msg209 - HDAE5000_AcLanguageText1Proc_Msg001	; message 209
	.short	HDAE5000_AcLanguageText1Proc_Msg210 - HDAE5000_AcLanguageText1Proc_Msg001	; message 210
	.short	HDAE5000_AcLanguageText1Proc_Msg211 - HDAE5000_AcLanguageText1Proc_Msg001	; message 211
	.short	HDAE5000_AcLanguageText1Proc_Msg212 - HDAE5000_AcLanguageText1Proc_Msg001	; message 212

; ============================================================================
; LYRICS MODULE .RODATA, 0x2E5B80-0x2E5DCD: the read-only data of the code
; around HDAE5000_LyricBoxProc and HDAE5000_FDFileSelectProc (lyric files
; "TLhd"/"TLtr", ".TLX"/".TTX"/".MID", the lyric messages), laid out
; after the trilingual message block.  Rebuilt object by object by
; scripts/generators/gen_hdae5000_rodata.py --block2, as the main .rodata
; block above: every object starts where the code names it, and its note
; names the readers; the switch tables keep their own headers.
; ============================================================================
HDAE5000_Str_Blank34:
	; only in v2.01i
	.asciz "                                  "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Reset:
	; read by LyricBoxProc at 0x28D261 (lda operand)
	.asciz "Reset"
HDAE5000_Str_Load:
	; read by LyricBoxProc at 0x28D283 (lda operand)
	.asciz "Load"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_03i_i:
	; read by LyricBoxProc at 0x28D4B7 (pushed operand)
	.asciz "%03i - %i "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_LyricBoxProc_CaseTable2 (0x2E5BC2, 8 x u16): the switch of HDAE5000_LyricBoxProc
; (dispatch at 0x28D57C, hdae5000_ui_display.s:3786: bound `cp xwa,7`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_LyricBoxProc_OnReset)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_LyricBoxProc_OnReset of the case for value 0+i; 8 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_LyricBoxProc_CaseTable2:
	.short	HDAE5000_LyricBoxProc_OnReset - HDAE5000_LyricBoxProc_OnReset	; 0
	.short	HDAE5000_LyricBoxProc_Default2 - HDAE5000_LyricBoxProc_OnReset	; 1 (default)
	.short	HDAE5000_LyricBoxProc_Default2 - HDAE5000_LyricBoxProc_OnReset	; 2 (default)
	.short	HDAE5000_LyricBoxProc_Default2 - HDAE5000_LyricBoxProc_OnReset	; 3 (default)
	.short	HDAE5000_LyricBoxProc_Default2 - HDAE5000_LyricBoxProc_OnReset	; 4 (default)
	.short	HDAE5000_LyricBoxProc_Default2 - HDAE5000_LyricBoxProc_OnReset	; 5 (default)
	.short	HDAE5000_LyricBoxProc_Default2 - HDAE5000_LyricBoxProc_OnReset	; 6 (default)
	.short	HDAE5000_LyricBoxProc_OnLoad - HDAE5000_LyricBoxProc_OnReset	; 7
;
; HDAE5000_LyricBoxProc_CaseTable1 (0x2E5BD2, 7 x u16): the switch of HDAE5000_LyricBoxProc
; (dispatch at 0x28CD6A, hdae5000_ui_display.s:3194: `sub xwa,0x01ca0003`, bound `cp xwa,6`, `add xwa,xwa`, `ld wa,(<table>+2i)`,
; `lda xix,(HDAE5000_LyricBoxProc_Ev01C0000D)`, `jp T,XIX+WA`).  Entry i is the offset from
; HDAE5000_LyricBoxProc_Ev01C0000D of the case for event 0x01CA0003+i; 7 entries, pinned by the bound
; compare.  Asserted and written by scripts/converters/hdae5000_switch_tables.py.
;
HDAE5000_LyricBoxProc_CaseTable1:
	.short	HDAE5000_LyricBoxProc_Ev01CA0003 - HDAE5000_LyricBoxProc_Ev01C0000D	; 0x01CA0003
	.short	HDAE5000_LyricBoxProc_Ev01CA0004 - HDAE5000_LyricBoxProc_Ev01C0000D	; 0x01CA0004
	.short	HDAE5000_LyricBoxProc_Ev01CA0005 - HDAE5000_LyricBoxProc_Ev01C0000D	; 0x01CA0005
	.short	HDAE5000_LyricBoxProc_Default1 - HDAE5000_LyricBoxProc_Ev01C0000D	; 0x01CA0006 (default)
	.short	HDAE5000_LyricBoxProc_Ev01CA0007 - HDAE5000_LyricBoxProc_Ev01C0000D	; 0x01CA0007
	.short	HDAE5000_LyricBoxProc_Ev01CA0008 - HDAE5000_LyricBoxProc_Ev01C0000D	; 0x01CA0008
	.short	HDAE5000_LyricBoxProc_Ev01CA0009 - HDAE5000_LyricBoxProc_Ev01C0000D	; 0x01CA0009
HDAE5000_Str_Rb:
	; read by Display_Error at 0x28D67B (lda operand)
	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_TESTTESTTLX:
	; read by Display_Error at 0x28D676 (lda operand)
	.asciz "TESTTEST.TLX"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fmt_Fault_No_Lyrics_loaded_o:
	; read by File_Operation at 0x28D78B (pushed operand)
	.asciz "Fault : No Lyrics loaded or corrupt Data - Code %i %i %i     "
HDAE5000_Fmt_i_i:
	; read by File_Operation at 0x28D9F3 (pushed operand)
	.asciz " %i/%i "
HDAE5000_Fmt_Chord_s:
	; read by File_Operation at 0x28DA35 (pushed operand)
	.asciz "Chord : %s               "
HDAE5000_Str_Info:
	; read by File_Save at 0x28DB2F (pushed operand)
	.asciz "Info :                            "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_NoCopyrightInfo:
	; read by File_Load at 0x28DC63 (pushed operand)
	.asciz "No Copyright Info"
HDAE5000_Str_NoSongTitle:
	; read by File_Load at 0x28DCDD (pushed operand)
	.asciz "No Song Title"
HDAE5000_Fmt_i_i_File_Load:
	; read by File_Load at 0x28DDB7 (pushed operand)
	.asciz " %i/%i "
HDAE5000_Str_Empty_File_Delete:
	; read by File_Delete at 0x28DF7B (pushed operand)
	.zero 2
HDAE5000_Str_Empty_File_Delete_2:
	; read by File_Delete at 0x28DFF0 (pushed operand)
	.zero 2
HDAE5000_Str_Tlhd:
	; read by Display_Notify at 0x28E540 (lda operand)
	.asciz "TLhd"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Tltr:
	; read by Display_Progress at 0x28E5B1 (lda operand)
	.asciz "TLtr"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Empty_FDFileSelectProc:
	; read by FDFileSelectProc at 0x28E78D (pushed operand)
	.zero 2
HDAE5000_Str_Blank27:
	; read by FDFileSelectProc at 0x28E85E (lda operand)
	.asciz "                           "
HDAE5000_Str_Blank27_FDFileSelectProc:
	; read by FDFileSelectProc at 0x28E917 (lda operand)
	.asciz "                           "
HDAE5000_Str_Mid:
	; read by FDFileSelectProc at 0x28E9EA (lda operand)
	.asciz "mid"
HDAE5000_Str_Blank3:
	; read by FDFileSelectProc at 0x28EA19 (lda operand)
	.asciz "   "
HDAE5000_Str_Blank49:
	; read by FDFileSelectProc at 0x28EB62 (lda operand)
	.asciz "                                                 "
HDAE5000_Fmt_s_s:
	; read by FDFileSelectProc at 0x28EBC8 (pushed operand)
	.asciz "%s %s"
HDAE5000_Fmt_s_s_FDFileSelectProc:
	; read by FDFileSelectProc at 0x28EBF7 (pushed operand)
	.asciz "%s %s"
HDAE5000_Str_TLX_FDFileSelectProc:
	; read by FDFileSelectProc at 0x28EEE1 (pushed operand)
	.asciz ".TLX"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Rb_FDFileSelectProc:
	; read by FDFileSelectProc at 0x28EEF2 (lda operand)
	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
;
; HDAE5000_FDFileSelectProc_KeyCaseTable (16 x u16): the switch of
; HDAE5000_FDFileSelectProc's event 0x01C00007.  A key code k = 0..7, or
; 0x80..0x87 folded to 8..15 by `sub xwa,0x78`, doubled, indexes this table
; (`add xwa,<table>`, `ld wa,(xwa)`), whose entries are offsets from
; .Lsc_07_btn_k1 (`lda xix,(.Lsc_07_btn_k1)`, `jp T,XIX+WA`).  v2.06i folds
; the keys through a byte map into 4 cases first; v2.01i indexes directly, and
; differs in two keys: 1 / 0x81 have their own case (.Lsc_07_btn_k1, where
; v2.06i returns 0) and 7 / 0x87 return 0 (where v2.06i takes the enter case).
;
HDAE5000_FDFileSelectProc_KeyCaseTable:
	.short	.Lsc_ret0 - .Lsc_07_btn_k1	; key code 0x00
	.short	.Lsc_07_btn_k1 - .Lsc_07_btn_k1	; key code 0x01
	.short	.Lsc_07_btn_down - .Lsc_07_btn_k1	; key code 0x02
	.short	.Lsc_07_btn_down - .Lsc_07_btn_k1	; key code 0x03
	.short	.Lsc_07_btn_down - .Lsc_07_btn_k1	; key code 0x04
	.short	.Lsc_07_btn_down - .Lsc_07_btn_k1	; key code 0x05
	.short	.Lsc_07_btn_enter - .Lsc_07_btn_k1	; key code 0x06
	.short	.Lsc_ret0 - .Lsc_07_btn_k1	; key code 0x07
	.short	.Lsc_ret0 - .Lsc_07_btn_k1	; key code 0x80
	.short	.Lsc_07_btn_k1 - .Lsc_07_btn_k1	; key code 0x81
	.short	.Lsc_07_btn_up - .Lsc_07_btn_k1	; key code 0x82
	.short	.Lsc_07_btn_up - .Lsc_07_btn_k1	; key code 0x83
	.short	.Lsc_07_btn_up - .Lsc_07_btn_k1	; key code 0x84
	.short	.Lsc_07_btn_up - .Lsc_07_btn_k1	; key code 0x85
	.short	.Lsc_07_btn_enter - .Lsc_07_btn_k1	; key code 0x86
	.short	.Lsc_ret0 - .Lsc_07_btn_k1	; key code 0x87
HDAE5000_Str_Chr202D3E:
	; read by FdLyricList_Scan at 0x28EFF1 (pushed operand)
	.asciz " ->"
HDAE5000_Str_Chr2A2E2A:
	; read by FdLyricList_Scan at 0x28F000 (lda operand)
	.asciz "*.*"
HDAE5000_Str_TTX:
	; read by FdLyricList_Scan at 0x28F08E (pushed operand)
	.asciz ".TTX"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Rb_FdLyricTtx:
	; read by FdLyricList_Scan at 0x28F0A3 (lda operand)
	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_MID:
	; read by FdLyricList_Scan at 0x28F114 (pushed operand)
	.asciz ".MID"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_Rb_FdLyricMid:
	; read by FdLyricList_Scan at 0x28F129 (lda operand)
	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Str_XLT:
	; read by FdLyricList_AddTlx at 0x28F1BA (pushed operand)
	.asciz "XLT."
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_TextPtrs_LANENG001_to_LANENG006:	; 6 x .long -> string
	; read by LanguageTextReturn at 0x28F2FF (lda operand); 6 string pointers, 4 bytes each, entry i at +4*i
	.long	HDAE5000_Str_LANENG001
	.long	HDAE5000_Str_LANDEU002
	.long	HDAE5000_Str_LANFRA003
	.long	HDAE5000_Str_LANENG004
	.long	HDAE5000_Str_LANENG005
	.long	HDAE5000_Str_LANENG006
HDAE5000_Str_LANENG006:
	; pointed at by entry 5 of HDAE5000_TextPtrs_LANENG001_to_LANENG006, a table read by LanguageTextReturn
	.asciz "LANENG006"
HDAE5000_Str_LANENG005:
	; pointed at by entry 4 of HDAE5000_TextPtrs_LANENG001_to_LANENG006, a table read by LanguageTextReturn
	.asciz "LANENG005"
HDAE5000_Str_LANENG004:
	; pointed at by entry 3 of HDAE5000_TextPtrs_LANENG001_to_LANENG006, a table read by LanguageTextReturn
	.asciz "LANENG004"
HDAE5000_Str_LANFRA003:
	; pointed at by entry 2 of HDAE5000_TextPtrs_LANENG001_to_LANENG006, a table read by LanguageTextReturn
	.asciz "LANFRA003"
HDAE5000_Str_LANDEU002:
	; pointed at by entry 1 of HDAE5000_TextPtrs_LANENG001_to_LANENG006, a table read by LanguageTextReturn
	.asciz "LANDEU002"
HDAE5000_Str_LANENG001:
	; pointed at by entry 0 of HDAE5000_TextPtrs_LANENG001_to_LANENG006, a table read by LanguageTextReturn
	.asciz "LANENG001"
HDAE5000_Str_XAP:
	; read by PPORT_Svc28_FlashXapFile at 0x28F314 (pushed operand)
	.asciz "XAP"
HDAE5000_Str_Rb_Smf_ReadHeader:
	; read by HDAE5000_Smf_ReadHeader (lda operand): the fopen mode of the SMF header read
	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)

; HDAE5000_Palette_BootSplash: Boot-splash palette: 256 RGBX entries loaded by HDAE5000_Boot_Init right before it
;   blits HDAE5000_Bitmap_BootSplash. Basis: Boot_Init's lda + HDAE5000_Load_Palette, and the bitmap renders correctly
;   only with it.
HDAE5000_Palette_BootSplash:
	; Boot-splash palette: 0x400 B = 256 RGBX entries (202 distinct colours).
	; Loaded by HDAE5000_Boot_Init, which does `lda XWA,0x2E5DCE` at 0x28F586
	; and calls HDAE5000_Load_Palette.  The name is kept as-is because it is
	; the only one of the five palettes referenced by name from the ASL
	; mirror (archive/asl/hdae5000/hd-ae5000_v2_06i.asm) and from
	; hdae5000_ui_display.s.  Extracted as images/HDAE5000_Palette_0x65dce.bin.
	;
	; The old slice here claimed "VGA palette data (256 entries)" but ran for
	; 0x13000 bytes -- 0x400 of palette followed by a whole 320 x 240 bitmap
	; that had never been identified.  They are now separated.
	; Built from images/HDAE5000_Palette_Splash.txt by scripts/build/hdae5000_images.py.
	; Was: .incbin "includes/code_29af2d_2fffff.bin", 306849, 1024
	.incbin "includes/generated/HDAE5000_Palette_Splash.bin"

HDAE5000_Bitmap_BootSplash:
	; 320 x 240 @ 8bpp = 0x12C00 B -- the HD-AE5000 start-up screen: a red
	; "HD-AE5000" wordmark over a photograph of an open disk platter, with
	; "Version 2" beneath it and "Start-up !  Please wait . . ." below that.
	; Rendered with HDAE5000_Palette_BootSplash (0x2E5DCE) it is unambiguous.
	;
	; HDAE5000_Boot_Init obtains this base from HDAE5000_Alloc_Memory
	; (request A1, the lda at 0x28F55F, with A2 = 0x140 and A3 = 0xF0) and
	; copies it into VRAM as two 0x9600-byte halves, to 0x1A0000 and
	; 0x1A9600.  0x2E61CE + 0x12C00 = 0x2F8DCE = HDAE5000_Display_Params,
	; so the bitmap tiles the gap exactly.
	; Not yet extracted to hdae5000/images/ -- see the hdae-splash package.
	; Built from images/HDAE5000_SplashScreen.png by scripts/build/hdae5000_images.py.
	; Was: .incbin "includes/code_29af2d_2fffff.bin", 307873, 76800
	.incbin "includes/generated/HDAE5000_SplashScreen.bin"

HDAE5000_Display_Params:
	; Display configuration parameters
	.asciz "HD-AE5000"
; HDAE5000_RcmStream_InitialState: 8 zero bytes copied over the RCM stream context at RAM 0x238F1C (u16 state, u16
;   dir, u16 song, u16 last result) before each RCM load/save. Basis: `ldirw` (95 11 = LDIRW (XIX+),(XIY+)) in
;   HDAE5000_LoadSong_Rcm/SaveSong_Rcm copies XIY = this ROM block to XIX = 0x238F1C; the source comments
;   'destination'/'source' are swapped.
HDAE5000_RcmStream_InitialState:
	.zero 8
HDAE5000_Dir_IsBlankName_Str_Blank16:	.asciz "                "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_Fls_IsBlankName_Str_Blank16:	.asciz "                "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FlsItem_SongRecord_Str_Blank26:	.asciz "                          "
	.byte 0x00
; HDAE5000_PartSignatureTable: Song-part file signature table, 9 x 8-byte records {u32 signature string; u16 offset in
;   file; u16 compare length} indexed by part (LSW, PMT, SQT, CMP, TM, MSP, RCM, MD, TLX); this label is record 0 =
;   the string-pointer column. Basis: HDAE5000_CheckFileSignature reads (base + part*8) and passes it to
;   HDAE5000_StrNCmp.
HDAE5000_PartSignatureTable:		.long	HDAE5000_PartSig_LSW
; HDAE5000_PartSignatureTable_FileOffset: HDAE5000_PartSignatureTable + 4: the u16 column giving where in the part
;   file's first 512 bytes the signature sits. Basis: HDAE5000_CheckFileSignature adds (this + part*8) to the buffer
;   pointer before HDAE5000_StrNCmp.
HDAE5000_PartSignatureTable_FileOffset:	.short	4
; HDAE5000_PartSignatureTable_Length: HDAE5000_PartSignatureTable + 6: the u16 column giving how many signature bytes
;   to compare. Basis: HDAE5000_CheckFileSignature pushes (this + part*8) as the HDAE5000_StrNCmp count.
HDAE5000_PartSignatureTable_Length:	.short	2
	.long	HDAE5000_PartSig_PMT
	.short	0, 2
	.long	HDAE5000_PartSig_SQT
	.short	5, 2
	.long	HDAE5000_PartSig_CMP
	.short	0, 3
	.long	HDAE5000_PartSig_TM
	.short	0, 16
	.long	HDAE5000_PartSig_MSP
	.short	0, 3
	.long	HDAE5000_PartSig_RCM
	.short	0, 3
	.long	HDAE5000_PartSig_MD
	.short	0, 2
	.long	HDAE5000_PartSig_TLX
	.short	0, 4
; The signature strings the table points at (offset and compare length in the table): CMP, MSP and RCM files start
;   with 'H', 0, 'K' (3 bytes); PMT and MD files with "HK", LSW files have "HK" at offset 4; SQT files the bytes 01 08
;   at offset 5; TM files start with "KN5000 SOUND RAM" (16 bytes), TLX files with "TLhd".
HDAE5000_PartSig_TLX:	.asciz "TLhd"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PartSig_MD:	.asciz "HK"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PartSig_RCM:	.asciz "H"
	.asciz "K"
HDAE5000_PartSig_MSP:	.asciz "H"
	.asciz "K"
HDAE5000_PartSig_TM:	.asciz "KN5000 SOUND RAM"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PartSig_CMP:	.asciz "H"
	.asciz "K"
HDAE5000_PartSig_SQT:	.byte 0x01, 0x08
	.zero 2
HDAE5000_PartSig_PMT:	.asciz "HK"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PartSig_LSW:	.asciz "HK"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_SEQ:	.asciz ".SEQ"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_SQF:	.asciz ".SQF"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_LSW:	.asciz ".LSW"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_rb:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_PMT:	.asciz ".PMT"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_rb_2:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_SQT:	.asciz ".SQT"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_rb_3:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_CMP:	.asciz ".CMP"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_rb_4:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_TM:	.asciz ".TM"
HDAE5000_FdSong_CheckFiles_Str_rb_5:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_MSP:	.asciz ".MSP"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_rb_6:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_RCM:	.asciz ".RCM"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_rb_7:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_MD:	.asciz ".MD"
HDAE5000_FdSong_CheckFiles_Str_rb_8:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_TLX:	.asciz ".TLX"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_FdSong_CheckFiles_Str_rb_9:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_CopyFdSongToHd_Lsw_Str_LSW:	.asciz ".LSW"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_CopyFdSongToHd_Lsw_Str_rb:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_CopyFdSongToHd_Pmt_Str_PMT:	.asciz ".PMT"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_CopyFdSongToHd_Pmt_Str_rb:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_CopyFdSongToHd_Sqt_Str_SQT:	.asciz ".SQT"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_CopyFdSongToHd_Sqt_Str_rb:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_CopyFdSongToHd_Cmp_Str_CMP:	.asciz ".CMP"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_CopyFdSongToHd_Cmp_Str_rb:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_CopyFdSongToHd_Tm_Str_TM:	.asciz ".TM"
HDAE5000_CopyFdSongToHd_Tm_Str_rb:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_CopyFdSongToHd_Msp_Str_MSP:	.asciz ".MSP"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_CopyFdSongToHd_Msp_Str_rb:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_CopyFdSongToHd_Rcm_Str_RCM:	.asciz ".RCM"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_CopyFdSongToHd_Rcm_Str_rb:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_CopyFdSongToHd_Md_Str_MD:	.asciz ".MD"
HDAE5000_CopyFdSongToHd_Md_Str_rb:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_CopyFdSongToHd_Tlx_Str_TLX:	.asciz ".TLX"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_CopyFdSongToHd_Tlx_Str_rb:	.asciz "rb"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc01_GetInfoBlockPointer_Str_GetInfoBlockPointer:	.asciz "---[ GetInfoBlockPointer ]---"
HDAE5000_PPORT_Svc01_GetInfoBlockPointer_Str_ppib_adr_Fmtx:		.asciz "ppib adr = %lx"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc01_GetInfoBlockPointer_Str_Blank1:	.asciz " "
HDAE5000_PPORT_Svc02_TurnHdMotorOff_Str_TurnHdMotorOff:	.asciz "---[ TurnHdMotorOff ]---"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc02_TurnHdMotorOff_Str_Blank1:			.asciz " "
HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_SendInfosAboutHd:	.asciz "---[ SendInfosAboutHd ]---"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddname:	.asciz "hddname : "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddtrck_Fmtd:	.asciz "hddtrck : %d"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddhead_Fmtd:	.asciz "hddhead : %d"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddsctr_Fmtd:	.asciz "hddsctr : %d"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddscby_Fmtd:	.asciz "hddscby : %d"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_Blank1:			.asciz " "
HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock_Str_SendInfosAboutDirBlock:	.asciz "---[ SendInfosAboutDirBlock ]---"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock_Str_FGB_ptr_Fmtx:	.asciz "FGB ptr : %lx"
HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock_Str_FGB_wid_Fmtd:	.asciz "FGB wid : %d"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock_Str_FGB_num_Fmtd:	.asciz "FGB num : %d"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock_Str_Blank1:					.asciz " "
HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock_Str_SendInfosAboutFileSystemBlock:	.asciz "---[ SendInfosAboutFileSystemBlock ]---"
HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock_Str_FEB_ptr_Fmtx:			.asciz "FEB ptr : %lx"
HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock_Str_FEB_wid_Fmtd:			.asciz "FEB wid : %d"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock_Str_FEB_num_Fmtd:	.asciz "FEB num : %d"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock_Str_Blank1:		.asciz " "
HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_SendInfosAboutFlsBlock:	.asciz "---[ SendInfosAboutFlsBlock ]---"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_FLS_ptr_Fmtx:	.asciz "FLS ptr : %lx"
HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_FLS_wid_Fmtd:	.asciz "FLS wid : %d"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_FLS_num_Fmtd:	.asciz "FLS num : %d"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_FLS_ent_Fmtd:	.asciz "FLS ent : %d"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_Blank1:		.asciz " "
HDAE5000_PPORT_Svc07_ReadDirBlockFromHd_Str_ReadDirBlockFromHd:	.asciz "---[ ReadDirBlockFromHd ]---"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc07_ReadDirBlockFromHd_Str_Blank1:			.asciz " "
HDAE5000_PPORT_Svc08_ReadFileBlockFromHd_Str_ReadFileBlockFromHd:	.asciz "---[ ReadFileBlockFromHd ]---"
HDAE5000_PPORT_Svc08_ReadFileBlockFromHd_Str_Blank1:			.asciz " "
HDAE5000_PPORT_Svc09_ReadFlsBlockFromHd_Str_ReadFlsBlockFromHd:		.asciz "---[ ReadFlsBlockFromHd ]---"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc09_ReadFlsBlockFromHd_Str_Blank1:				.asciz " "
HDAE5000_PPORT_Svc10_WriteDirBlockToHd_Str_WriteDirBlockToHd:			.asciz "---[ WriteDirBlockToHd ]---"
HDAE5000_PPORT_Svc10_WriteDirBlockToHd_Str_Blank1:				.asciz " "
HDAE5000_PPORT_Svc11_WriteFileSystemBlockToHd_Str_WriteFileSystemBlockToHd:	.asciz "---[ WriteFileSystemBlockToHd ]---"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc11_WriteFileSystemBlockToHd_Str_Blank1:	.asciz " "
HDAE5000_PPORT_Svc12_WriteFlsBlockToHd_Str_WriteFlsBlockToHd:	.asciz "---[ WriteFlsBlockToHd ]---"
HDAE5000_PPORT_Svc12_WriteFlsBlockToHd_Str_Blank1:		.asciz " "
HDAE5000_PPORT_Svc13_SendInfosAboutSong_Str_SendInfosAboutSong:	.asciz "---[ SendInfosAboutSong ]--- "
HDAE5000_PPORT_Svc13_SendInfosAboutSong_Str_dirname_Fmts:	.asciz "dirname : %s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc13_SendInfosAboutSong_Str_sngname_Fmts:	.asciz "sngname : %s"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc13_SendInfosAboutSong_Str_Blank1:			.asciz " "
HDAE5000_PPORT_Svc14_LoadSongFromHdToMemory_Str_LoadSongFromHdToMemory:	.asciz "---[ LoadSongFromHdToMemory ]---"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc14_LoadSongFromHdToMemory_Str_Blank1:			.asciz " "
HDAE5000_PPORT_Svc15_SaveSongInMemoryToHd_Str_SaveSongInMemoryToHd:	.asciz "---[ SaveSongInMemoryToHd ]---"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc15_SaveSongInMemoryToHd_Str_Blank1:			.asciz " "
HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Str_InitWholeSongInMemory:	.asciz "---[ InitWholeSongInMemory ]---"
HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Str_Blank1:			.asciz " "
HDAE5000_PPORT_Svc17_FormatHd_Str_FormatHd:				.asciz "---[ FormatHd ]---"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc17_FormatHd_Str_Blank1:						.asciz " "
HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace_Str_SendPointerToFreeBufferSpace:	.asciz "---[ SendPointerToFreeBufferSpace ]---"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace_Str_work_adr_Fmtx:	.asciz "work adr : %lx"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace_Str_Blank1:		.asciz " "
HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Str_PreWholeSongInMemory:	.asciz "---[ PreWholeSongInMemory ]---"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Str_Blank1:	.asciz " "
HDAE5000_PPORT_Svc21_WriteOpenHD_Str_WriteOpenHD:	.asciz "---[ WriteOpenHD ]--- "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc21_WriteOpenHD_Str_SUFFIX_Fmtd:	.asciz "SUFFIX : %d"
HDAE5000_PPORT_Svc22_WriteCloseHD_Str_WriteCloseHD:	.asciz "---[ WriteCloseHD ]--- "
HDAE5000_PPORT_Svc23_WriteFileHD_Str_WriteFileHD:	.asciz "---[ WriteFileHD ]--- "
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_PPORT_Svc24_ReadOpenHD_Str_ReadOpenHD:	.asciz "---[ ReadOpenHD ]--- "
HDAE5000_PPORT_Svc25_ReadFileHD_Str_ReadFileHD:	.asciz "---[ ReadFileHD ]--- "

; ----------------------------------------------------------------------------
; HDAE5000_CType_Table  (0x2F9362 - 0x2F9461, 256 bytes): the C library's
; character-class table, indexed by the unsigned char itself (entry 0 = NUL).
; Bit meanings, and the reader that tests each:
;   bit 0  upper case       hd-ae5000_v2_06i.s near 0x2823xx (`bit 0,(XBC+WA)`)
;   bit 1  lower case       HDAE5000_StrUpr, HDAE5000_FormatFloat_Fixed/_Exp
;                           (toupper of the conversion letter), and 0x2823xx
;   bit 2  decimal digit    HDAE5000_DoPrintf width/precision parsing, 0x2823xx
;   bit 3  white space, bit 4 punctuation, bit 5 control, bit 6 the space
;   character, bit 7 hex digit: no reader in this ROM (searched every
;   `lda ..,(HDAE5000_CType_Table:24)` site: they test bits 0-2 only); meanings read off
;   the contents -- '0'-'9' = 0x84, 'A'-'F' = 0x81, 'a'-'f' = 0x82, TAB..CR =
;   0x28, ' ' = 0x48, DEL = 0x20, 0x80-0xFF = 0.
; Was written as `.ascii "         (((((..."` plus loose .byte rows.
; ----------------------------------------------------------------------------
HDAE5000_CType_Table:
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x28, 0x28, 0x28, 0x28, 0x28, 0x20, 0x20	; 0x00-0x0F 0x00..0x0F
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20	; 0x10-0x1F 0x10..0x1F
	.byte 0x48, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10	; 0x20-0x2F ' '..'/'
	.byte 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x84, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10	; 0x30-0x3F '0'..'?'
	.byte 0x10, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01	; 0x40-0x4F '@'..'O'
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x10, 0x10, 0x10, 0x10, 0x10	; 0x50-0x5F 'P'..'_'
	.byte 0x10, 0x82, 0x82, 0x82, 0x82, 0x82, 0x82, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02	; 0x60-0x6F '`'..'o'
	.byte 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x10, 0x10, 0x10, 0x10, 0x20	; 0x70-0x7F 'p'..0x7F
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; 0x80-0x8F 0x80..0x8F
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; 0x90-0x9F 0x90..0x9F
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; 0xA0-0xAF 0xA0..0xAF
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; 0xB0-0xBF 0xB0..0xBF
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; 0xC0-0xCF 0xC0..0xCF
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; 0xD0-0xDF 0xD0..0xDF
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; 0xE0-0xEF 0xE0..0xEF
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; 0xF0-0xFF 0xF0..0xFF

; ----------------------------------------------------------------------------
; HDAE5000_DoPrintf_ConvTable  (0x2F9462 - 0x2F948D, 22 x u16)
; Conversion-letter jump table of HDAE5000_DoPrintf: it computes
; WA = letter - 'c', refuses WA < 0 or WA > 0x15 (22 entries, 'c'..'x'),
; loads WA = table[WA] (`ld WA,(XIX+WA)` after `add wa,wa`) and jumps to
; HDAE5000_DoPrintf_Case_Char + WA (`jp T,XIX+WA`).  Each entry is therefore
; an offset from that base, written below as a label difference; every one
; lands on an instruction boundary of HDAE5000_DoPrintf (checked against the
; line map).  Letters with no conversion go to HDAE5000_DoPrintf_NextChar.
; ----------------------------------------------------------------------------
HDAE5000_DoPrintf_ConvTable:
	.short	HDAE5000_DoPrintf_Case_Char - HDAE5000_DoPrintf_Case_Char	; 'c'
	.short	HDAE5000_DoPrintf_Case_Int - HDAE5000_DoPrintf_Case_Char	; 'd'
	.short	HDAE5000_DoPrintf_Case_Float - HDAE5000_DoPrintf_Case_Char	; 'e'
	.short	HDAE5000_DoPrintf_Case_Float - HDAE5000_DoPrintf_Case_Char	; 'f'
	.short	HDAE5000_DoPrintf_Case_Float - HDAE5000_DoPrintf_Case_Char	; 'g'
	.short	HDAE5000_DoPrintf_NextChar - HDAE5000_DoPrintf_Case_Char	; 'h'
	.short	HDAE5000_DoPrintf_Case_Int - HDAE5000_DoPrintf_Case_Char	; 'i'
	.short	HDAE5000_DoPrintf_NextChar - HDAE5000_DoPrintf_Case_Char	; 'j'
	.short	HDAE5000_DoPrintf_NextChar - HDAE5000_DoPrintf_Case_Char	; 'k'
	.short	HDAE5000_DoPrintf_NextChar - HDAE5000_DoPrintf_Case_Char	; 'l'
	.short	HDAE5000_DoPrintf_NextChar - HDAE5000_DoPrintf_Case_Char	; 'm'
	.short	HDAE5000_DoPrintf_Case_Count - HDAE5000_DoPrintf_Case_Char	; 'n'
	.short	HDAE5000_DoPrintf_Case_Octal - HDAE5000_DoPrintf_Case_Char	; 'o'
	.short	HDAE5000_DoPrintf_Case_Pointer - HDAE5000_DoPrintf_Case_Char	; 'p'
	.short	HDAE5000_DoPrintf_NextChar - HDAE5000_DoPrintf_Case_Char	; 'q'
	.short	HDAE5000_DoPrintf_NextChar - HDAE5000_DoPrintf_Case_Char	; 'r'
	.short	HDAE5000_DoPrintf_Case_String - HDAE5000_DoPrintf_Case_Char	; 's'
	.short	HDAE5000_DoPrintf_NextChar - HDAE5000_DoPrintf_Case_Char	; 't'
	.short	HDAE5000_DoPrintf_Case_Unsigned - HDAE5000_DoPrintf_Case_Char	; 'u'
	.short	HDAE5000_DoPrintf_NextChar - HDAE5000_DoPrintf_Case_Char	; 'v'
	.short	HDAE5000_DoPrintf_NextChar - HDAE5000_DoPrintf_Case_Char	; 'w'
	.short	HDAE5000_DoPrintf_Case_Hex - HDAE5000_DoPrintf_Case_Char	; 'x'

; Hex digit strings.  HDAE5000_Int_To_Hex_String loads _Upper by default and
; _Lower when the conversion letter is 'x' (`cpw (xsp+12),0x0078`).
HDAE5000_HexDigits_Lower:
	.asciz "0123456789abcdef"
	.balign 2, 0x00                       ; word-align pad (proven: see convert_align_pads.py header)
HDAE5000_HexDigits_Upper:
	.asciz "0123456789ABCDEF"
	.byte 0x00

	.include "hdae5000_init_data.s"

; ============================================================================
; END OF ROM (0x300000)
; ============================================================================

end:

; Labels emitted as .set (exact addresses from ORG/name)
