; =============================================================================
; Common Assembly Macros
; =============================================================================

; aligned_string - Null-terminated string with 16-bit alignment padding
; Emits the string with null terminator, then pads with 0xff if needed
; to align the next item to an even address.
.macro aligned_string str:vararg
	.asciz \str
	.p2align 1, 0xff
.endm

; =============================================================================
; NAKA UI Widget System
; =============================================================================

; NAKA class indices.  A widget record's first word is its class id 0x016000TT (the bytes
; TT, 0x00, 0x60, 0x01 that naka_header emits).  TT is the entry of InitializeRoot's class table
; (registry slot 0x160, read by ClassProc) and each name is that class's own name string, the same
; in v10/v9/v7/v6/v5 (scripts/analysis/nakarest_objtab_map.py --classes): all 109 root classes.
.equ NAKA_TYPE_Object,			0x00
.equ NAKA_TYPE_Function,		0x01
.equ NAKA_TYPE_ApFunction,		0x02
.equ NAKA_TYPE_MainFunction,		0x03
.equ NAKA_TYPE_Class,			0x04
.equ NAKA_TYPE_SupportClass,		0x05
.equ NAKA_TYPE_Mode,			0x06
.equ NAKA_TYPE_Title,			0x07
.equ NAKA_TYPE_ResBitmap,		0x08
.equ NAKA_TYPE_ResFrame,		0x09
.equ NAKA_TYPE_ResIcon,			0x0a
.equ NAKA_TYPE_ResFont,			0x0b
.equ NAKA_TYPE_ResEvent,		0x0c
.equ NAKA_TYPE_ResMethod,		0x0d
.equ NAKA_TYPE_ResString,		0x0e
.equ NAKA_TYPE_ResName,			0x0f
.equ NAKA_TYPE_Viewable,		0x10
.equ NAKA_TYPE_VwBox,			0x11
.equ NAKA_TYPE_PsParaBox,		0x12
.equ NAKA_TYPE_AcLswBox,		0x13
.equ NAKA_TYPE_AcTempoBox,		0x14
.equ NAKA_TYPE_PsEditBox,		0x15
.equ NAKA_TYPE_PsNumEditBox,		0x16
.equ NAKA_TYPE_PsTblEditBox,		0x17
.equ NAKA_TYPE_AcOnOffBox,		0x18
.equ NAKA_TYPE_AcNumEditBox,		0x19
.equ NAKA_TYPE_AcLswEditBox,		0x1a
.equ NAKA_TYPE_AcRamEditBox,		0x1b
.equ NAKA_TYPE_PsMenuBox,		0x1c
.equ NAKA_TYPE_AcTitleMenu,		0x1d
.equ NAKA_TYPE_PsEditSwBox,		0x1e
.equ NAKA_TYPE_AcIndexEditSw,		0x1f
.equ NAKA_TYPE_AcFuncEditSw,		0x20
.equ NAKA_TYPE_PsWideESBox,		0x21
.equ NAKA_TYPE_AcIndexWideES,		0x22
.equ NAKA_TYPE_AcFuncWideES,		0x23
.equ NAKA_TYPE_PsPageBox,		0x24
.equ NAKA_TYPE_AcWindowPage,		0x25
.equ NAKA_TYPE_PsToggleBox,		0x26
.equ NAKA_TYPE_PsInvisibleBox,		0x27
.equ NAKA_TYPE_IvPageControl,		0x28
.equ NAKA_TYPE_IvMainEditSw,		0x29
.equ NAKA_TYPE_AcSoundName,		0x2a
.equ NAKA_TYPE_Label,			0x2b
.equ NAKA_TYPE_Bitmap,			0x2c
.equ NAKA_TYPE_Icon,			0x2d
.equ NAKA_TYPE_Line,			0x2e
.equ NAKA_TYPE_Frame,			0x2f
.equ NAKA_TYPE_EditSw,			0x30
.equ NAKA_TYPE_Box,			0x31
.equ NAKA_TYPE_GroupBox,		0x32
.equ NAKA_TYPE_Screen,			0x33
.equ NAKA_TYPE_TtlScreen,		0x34
.equ NAKA_TYPE_Window,			0x35
.equ NAKA_TYPE_TextBox,			0x36
.equ NAKA_TYPE_StringBox,		0x37
.equ NAKA_TYPE_ModeEdit,		0x38
.equ NAKA_TYPE_TitleEdit,		0x39
.equ NAKA_TYPE_AcRhythmName,		0x3a
.equ NAKA_TYPE_AcPmemName,		0x3b
.equ NAKA_TYPE_AcMixerVol,		0x3c
.equ NAKA_TYPE_VwMenuBox,		0x3d
.equ NAKA_TYPE_VwEditSwBox,		0x3e
.equ NAKA_TYPE_VwWideESBox,		0x3f
.equ NAKA_TYPE_AcModeMenu,		0x40
.equ NAKA_TYPE_AcScreenMenu,		0x41
.equ NAKA_TYPE_AcWindowMenu,		0x42
.equ NAKA_TYPE_AcBitEditBox,		0x43
.equ NAKA_TYPE_AcFuncToggle,		0x44
.equ NAKA_TYPE_PsWideToggle,		0x45
.equ NAKA_TYPE_DbMemo,			0x46
.equ NAKA_TYPE_IvExit,			0x47
.equ NAKA_TYPE_IvExitMode,		0x48
.equ NAKA_TYPE_IvExitScreen,		0x49
.equ NAKA_TYPE_IvFixWin,		0x4a
.equ NAKA_TYPE_AcNamingWindow,		0x4b
.equ NAKA_TYPE_PsCursorBox,		0x4c
.equ NAKA_TYPE_IvNaming,		0x4d
.equ NAKA_TYPE_AcIndexToggle,		0x4e
.equ NAKA_TYPE_AcRamBox,		0x4f
.equ NAKA_TYPE_PsRadioBox,		0x50
.equ NAKA_TYPE_AcStrRadioBox,		0x51
.equ NAKA_TYPE_IvCatchEvent,		0x52
.equ NAKA_TYPE_PsListBox,		0x53
.equ NAKA_TYPE_PsGridBox,		0x54
.equ NAKA_TYPE_AcListBox,		0x55
.equ NAKA_TYPE_AcGridBox,		0x56
.equ NAKA_TYPE_DbDebugMenu,		0x57
.equ NAKA_TYPE_PsTrackSwitch,		0x58
.equ NAKA_TYPE_AcTrackSwitch,		0x59
.equ NAKA_TYPE_IvDirmdScreen,		0x5a
.equ NAKA_TYPE_IvTrackSwitch,		0x5b
.equ NAKA_TYPE_IvExitWindow,		0x5c
.equ NAKA_TYPE_DbMemoryDump,		0x5d
.equ NAKA_TYPE_IvInterrupt,		0x5e
.equ NAKA_TYPE_IvIntReminder,		0x5f
.equ NAKA_TYPE_IvIntError,		0x60
.equ NAKA_TYPE_IvIntComplete,		0x61
.equ NAKA_TYPE_IvIntVari,		0x62
.equ NAKA_TYPE_IvIntEasySet,		0x63
.equ NAKA_TYPE_IvShowHide,		0x64
.equ NAKA_TYPE_PsTextBox,		0x65
.equ NAKA_TYPE_AcLanguageText,		0x66
.equ NAKA_TYPE_TrTransposeBox,		0x67
.equ NAKA_TYPE_TrChordBox,		0x68
.equ NAKA_TYPE_VwUserBitmap,		0x69
.equ NAKA_TYPE_IvScreen,		0x6a
.equ NAKA_TYPE_IvIntWelcome,		0x6b
.equ NAKA_TYPE_VwUserBitmapByName,	0x6c

; Common constants
.equ NAKA_HEADER_HI,  0x0160  ; Fixed upper 16 bits of header
.equ NAKA_INDEX_NONE, 0xffff  ; Unused index slot

; naka_header - Emit the 4-byte NAKA widget header
; Usage: naka_header NAKA_TYPE_Label
.macro naka_header type
	.byte \type, 0x00, 0x60, 0x01
.endm

; addr24 - Emit a 24-bit little-endian address from a .set constant
; Usage: addr24 SymbolName
; Used for embedded addresses in bytecode/data tables where the
; assembler cannot emit 3-byte relocations for positional labels.
.macro addr24 sym
	.reloc ., R_TLCS900_24, \sym
	.space 3
.endm
