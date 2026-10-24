; =============================================================================
; SepaOut Config & Resource Info Handler Offsets
; RESOURCE_INFO_HANDLER_OFFSETS dispatch table and SepaOut_* layout/config data
; Extracted from kn5000_v10_program.s
; =============================================================================

RESOURCE_INFO_HANDLER_OFFSETS:
	; Precomputed relative offsets (identical in v7 and v9)

; SepaOut configuration data (826 bytes, compiled from sepaout_config.c)
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x18, 0x00, 0x31, 0x00, 0x73, 0x00
	.byte	0x83, 0x00, 0x9c, 0x00, 0x4a, 0x00, 0xb5, 0x00
	.byte	0xce, 0x00, 0x63, 0x00
SepaOut_Config_0:	.incbin "includes/generated/sepaout_config.bin", 0x0, 0x4
; SepaOut_Msg_CC9B_Value32: 4-byte sub-CPU control-change template B0 <part> 9B 20 (status, part placeholder,
;   controller 0x9B, value 0x20 = 32); SetSepaOutMode patches the part to 0x14/0x13/0x16 and sends it with sendCOMM.
;   Basis: readers + bytes -- used for part 0x14 in modes 1-3 and for all three parts in modes 2-3; mode 0 sends
;   SepaOut_Config_0 (B0 xx 9B 01) instead.
SepaOut_Msg_CC9B_Value32:	.incbin "includes/generated/sepaout_config.bin", 0x4, 0x4
; SepaOut_Msg_CC9D_Value0: 4-byte sub-CPU control-change template B0 <part> 9D 00 (controller 0x9D, value 0);
;   SetSepaOutMode sends it for parts 0x14, 0x13 and 0x16 in modes 0, 1 and 2. Basis: readers + bytes.
SepaOut_Msg_CC9D_Value0:	.incbin "includes/generated/sepaout_config.bin", 0x8, 0x4
; SepaOut_Msg_CC9D_Value1: 4-byte sub-CPU control-change template B0 <part> 9D 01 (controller 0x9D, value 1);
;   SetSepaOutMode sends it only in mode 3, for parts 0x13 and 0x16. Basis: readers + bytes.
SepaOut_Msg_CC9D_Value1:	.incbin "includes/generated/sepaout_config.bin", 0xC, 0x4
; SepaOut_Msg_CC9D_Value2: 4-byte sub-CPU control-change template B0 <part> 9D 02 (controller 0x9D, value 2);
;   SetSepaOutMode sends it only in mode 3, for part 0x14. Basis: readers + bytes.
SepaOut_Msg_CC9D_Value2:	.incbin "includes/generated/sepaout_config.bin", 0x10, 0x4
SqSngSelTtlFunc_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x0e, 0x00, 0x1a, 0x00, 0x1a, 0x00
	.byte	0x1a, 0x00, 0x1a, 0x00
SqSngNameTtlFunc_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x0e, 0x00, 0x1a, 0x00, 0x1a, 0x00
	.byte	0x1a, 0x00, 0x1a, 0x00
SqTrAsTtlFunc_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x33, 0x00, 0xa3, 0x00, 0x4c, 0x00
	.byte	0xa3, 0x00, 0xa3, 0x00
SqTrAsPsTtlFunc_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x3e, 0x00, 0x60, 0x00, 0x60, 0x00
	.byte	0x60, 0x00, 0x60, 0x00
CDlike_KeepTitleCaseMap:			.incbin "includes/generated/sepaout_config.bin", 0x44, 0xE
SqTrAsPsTtl_CaseF_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x0c, 0x00, 0x00, 0x00
SqMdlyPlyTtlFunc_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x0e, 0x00, 0x5a, 0x00, 0x5a, 0x00
	.byte	0x5a, 0x00, 0x5a, 0x00
DkMdlyPlyTtlFunc_CaseTable:
; DkMdlyPly_BitMaskByIndex: 16 x u16 single-bit masks, entry n = 1 << n; DkMdlyPly_SendAudioCmd ANDs each with WA and
;   returns HL = the index of the lowest set bit of WA (16 when none). Basis: readers + bytes.
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x0e, 0x00, 0x5a, 0x00, 0x5a, 0x00
	.byte	0x5a, 0x00, 0x5a, 0x00
DkMdlyPly_BitMaskByIndex:			.incbin "includes/generated/sepaout_config.bin", 0x6E, 0x20
; DkMdlyPly_PartIndexTable: 32 x u16 part numbers 0..31 (entry i = i) through which DkMdlyPly_CheckState walks the
;   parts: the entry is passed to SndParam_LookupViaEncode with BC = 0x401 and, on a match with the lowest set bit of
;   the mask (DkMdlyPly_SendAudioCmd), written to PART_SELECT. Basis: readers + bytes.
DkMdlyPly_PartIndexTable:			.incbin "includes/generated/sepaout_config.bin", 0x8E, 0x40
DisplayMode_DispatchEvents_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x1e, 0x00, 0x7a, 0x00, 0xb8, 0x00
	.byte	0x0f, 0x00, 0x4c, 0x00, 0x98, 0x00
DpMdlyDocTtlFunc_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x1b, 0x00, 0x74, 0x00, 0x74, 0x00
	.byte	0x74, 0x00, 0x74, 0x00
DpMdlyPdTtlFunc_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x1b, 0x00, 0x74, 0x00, 0x74, 0x00
	.byte	0x74, 0x00, 0x74, 0x00
DpMdlySmfTtlFunc_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x28, 0x00, 0x81, 0x00, 0x81, 0x00
	.byte	0x81, 0x00, 0x81, 0x00
DpMdlySmfLyrTtlFunc_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x49, 0x00, 0xa7, 0x00, 0x5a, 0x00
	.byte	0xa7, 0x00, 0xa7, 0x00
NameGetFuncCall_Dispatch_Str_Fmt2d_Fmts:	.incbin "includes/generated/sepaout_config.bin", 0x10C, 0xA
NameGetFuncCall_Dispatch_Str_FILE_Fmt2d_Fmts:	.incbin "includes/generated/sepaout_config.bin", 0x116, 0xC
NameGetFuncCall_Dispatch_Str_Fmt3d_Fmts:	.incbin "includes/generated/sepaout_config.bin", 0x122, 0x8
NameGetFuncCall_Dispatch_Str_Fmt2d_Fmts_2:	.incbin "includes/generated/sepaout_config.bin", 0x12A, 0x8
NameGetFuncCall_Dispatch_Str_Fmt2d_Fmts_3:	.incbin "includes/generated/sepaout_config.bin", 0x132, 0x8
NameGetFuncCall_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x48, 0x00, 0x81, 0x00, 0xc1, 0x00
	.byte	0xb9, 0x02, 0x3b, 0x01, 0x0d, 0x01, 0xb5, 0x01
	.byte	0x87, 0x01, 0xb9, 0x02, 0xb9, 0x02, 0xb9, 0x02
	.byte	0xfd, 0x01, 0x59, 0x02
DpDoc_CaseA_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x05, 0x00, 0x29, 0x00, 0x6b, 0x00
	.byte	0x2e, 0x00, 0x6b, 0x00, 0x6b, 0x00, 0x6b, 0x00
	.byte	0x3a, 0x00, 0x35, 0x00
DpDocTtlFunc_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x13, 0x00, 0xe1, 0x00, 0xe1, 0x00
	.byte	0xe1, 0x00, 0xe1, 0x00
DpPd_CaseA_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x05, 0x00, 0x29, 0x00, 0x6b, 0x00
	.byte	0x2e, 0x00, 0x6b, 0x00, 0x6b, 0x00, 0x6b, 0x00
	.byte	0x3a, 0x00, 0x35, 0x00
DpPdTtlFunc_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x13, 0x00, 0xe1, 0x00, 0xe1, 0x00
	.byte	0xe1, 0x00, 0xe1, 0x00
DpSmf_CaseA_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x05, 0x00, 0x29, 0x00, 0x6b, 0x00
	.byte	0x2e, 0x00, 0x6b, 0x00, 0x6b, 0x00, 0x6b, 0x00
	.byte	0x3a, 0x00, 0x35, 0x00
DpSmfTtlFunc_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x21, 0x00, 0x07, 0x01, 0x07, 0x01
	.byte	0x07, 0x01, 0x07, 0x01
DpSmfLyrTtlFunc_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x0e, 0x00, 0xd5, 0x00, 0x14, 0x00
	.byte	0xd5, 0x00, 0xd5, 0x00
SqTrSelTtlFunc_CaseTable:
; SqStepTtlFunc_Methods: The TT_SQSTEP title's 4-entry DirmdEmulator method vector: [0] Display_InitGraphicsAndScreen
;   (draw), [1] Display_CallConditionalCompare (EVT_HIDE), [2] Display_CallPollAudioUpdate, [3] SqTrSel_CaseA. Basis:
;   readers + bytes -- SqStepTtlFunc copies it to the stack and calls DirmdEmulator, like SeMenuTitleFunc_Methods /
;   DirmdTitle_EmulatorMethods.
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x0e, 0x00, 0x1a, 0x00, 0x1a, 0x00
	.byte	0x1a, 0x00, 0x1a, 0x00
SqStepTtlFunc_Methods:				.incbin "includes/generated/sepaout_config.bin", 0x1CE, 0x10
DemoStyleTtlFunc_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x8f, 0x00, 0x8f, 0x00, 0x8f, 0x00
	.byte	0x8f, 0x00, 0x8f, 0x00
DemoSoundTtlFunc_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x8a, 0x00, 0x8a, 0x00, 0x8a, 0x00
	.byte	0x8a, 0x00, 0x8a, 0x00
DemoRhyTtlFunc_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x8a, 0x00, 0x8a, 0x00, 0x8a, 0x00
	.byte	0x8a, 0x00, 0x8a, 0x00
MiddleFuncCall_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x13, 0x00, 0x97, 0x00, 0x97, 0x00
	.byte	0x2e, 0x00, 0x3c, 0x00, 0x66, 0x00, 0x74, 0x00
	.byte	0x4a, 0x00, 0x58, 0x00, 0x82, 0x00, 0x88, 0x00
	.byte	0x8d, 0x00
SongBankLookup_BuildAudioCmd_Str_Fmt3d_FmtPct:	.incbin "includes/generated/sepaout_config.bin", 0x21C, 0x6
; Demo_SongViewIdTable: 18 x u32 NAKA view ids of the demo song selectors DemoSong0..DemoSong17 (0xE10001-0xE10006,
;   0xE20001-0xE20006, 0xE30001-0xE30006), indexed by DEMO_ACTIVE_ENTRY; SeqInit_PostDispatchEvent sends
;   EVT_SET_SELECTED 1 to the entry's view. Basis: readers + bytes.
Demo_SongViewIdTable:		.incbin "includes/generated/sepaout_config.bin", 0x222, 0x48
SqTrSel_CaseG_CaseTable:
; TODO(port): v6 bytes with no v7 line -- disassemble
	.byte	0x00, 0x00, 0x03, 0x00, 0x06, 0x00, 0x00, 0x00
	.byte	0x09, 0x00, 0x23, 0x00, 0x30, 0x00, 0x16, 0x00
Yoko_ApFunctionTable_127:			.incbin "includes/generated/sepaout_config.bin", 0x27A, 0xBC
Yoko_ApFunctionTable_427:			.incbin "includes/generated/sepaout_config.bin", 0x336, 0x4

; SepaOut_FormatData_Tail is at offset 263 within the C data blob
; (referenced by extensions/extension_data.s)
.set SepaOut_FormatData_Tail, SepaOut_Config_0 + 263
