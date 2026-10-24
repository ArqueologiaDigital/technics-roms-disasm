
; --- 0xF4F800-0xF4F90F  romtab (272 bytes) ---

; --------------------------------------------------------------------------
; PtrTable_F4F800 -- 34 32-bit pointers, 34 into prom_a and 0 into prom_b
; Read by: prom_a 0xFB21AF `add XWA,0x00f4f800`
; Entry count: 34, measured by abutment: 34 x 4 = 136 bytes reaches 0xF4F888
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
PtrTable_F4F800:
	.long SysExCmd_ResetSession                       ; F4F800  [0]   -> prom_a 0xFB22C8
	.long SysExSession_Run                       ; F4F804  [1]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F808  [2]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F80C  [3]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F810  [4]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F814  [5]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F818  [6]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F81C  [7]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F820  [8]   -> prom_a 0xFB2820
	.long SysExCmd_TempoReceive                       ; F4F824  [9]   -> prom_a 0xFB33FE
	.long SysExSession_Run                       ; F4F828  [10]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F82C  [11]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F830  [12]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F834  [13]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F838  [14]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F83C  [15]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F840  [16]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F844  [17]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F848  [18]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F84C  [19]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F850  [20]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F854  [21]   -> prom_a 0xFB2820
	.long SysExSession_Run                       ; F4F858  [22]   -> prom_a 0xFB2820
	.long SysExCmd_ThirdRegionWrite                       ; F4F85C  [23]   -> prom_a 0xFB3483
	.long SysExCmd_ParamWrite                       ; F4F860  [24]   -> prom_a 0xFB34CA
	.long SysExCmd_ThirdRegionRequest                       ; F4F864  [25]   -> prom_a 0xFB3495
	.long SysExParam_Request_DispatchGroup                       ; F4F868  [26]   -> prom_a 0xFB42AB
	.long SysExCmd_DumpRequest_SystemPartMidi                       ; F4F86C  [27]   -> prom_a 0xFB5122
	.long SysExCmd_DumpRequest_Sound                       ; F4F870  [28]   -> prom_a 0xFB512C
	.long SysExCmd_DumpRequest_Job1                       ; F4F874  [29]   -> prom_a 0xFB5136
	.long SysExCmd_DumpRequest_Sequencer                       ; F4F878  [30]   -> prom_a 0xFB5140
	.long SysExCmd_DumpRequest_Combination                       ; F4F87C  [31]   -> prom_a 0xFB514A
	.long SysExCmd_GmSystemOn                       ; F4F880  [32]   -> prom_a 0xFB51E7
	.long SysExCmd_GmSystemOff                       ; F4F884  [33]   -> prom_a 0xFB520C

; --------------------------------------------------------------------------
; PtrTable_F4F888 -- 34 32-bit pointers, 34 into prom_a and 0 into prom_b
; Read by: prom_a 0xFB22AC `add XWA,0x00f4f888`
; Entry count: 34, measured by abutment: 34 x 4 = 136 bytes reaches 0xF4F910
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
PtrTable_F4F888:
	.long SysExCmd_ResetSession                       ; F4F888  [0]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F88C  [1]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F890  [2]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F894  [3]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F898  [4]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F89C  [5]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F8A0  [6]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F8A4  [7]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F8A8  [8]   -> prom_a 0xFB22C8
	.long SysExCmd_TempoReceive                       ; F4F8AC  [9]   -> prom_a 0xFB33FE
	.long SysExCmd_ResetSession                       ; F4F8B0  [10]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F8B4  [11]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F8B8  [12]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F8BC  [13]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F8C0  [14]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F8C4  [15]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F8C8  [16]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F8CC  [17]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F8D0  [18]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F8D4  [19]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F8D8  [20]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F8DC  [21]   -> prom_a 0xFB22C8
	.long SysExCmd_ResetSession                       ; F4F8E0  [22]   -> prom_a 0xFB22C8
	.long SysExCmd_ThirdRegionWrite                       ; F4F8E4  [23]   -> prom_a 0xFB3483
	.long SysExCmd_ParamWrite                       ; F4F8E8  [24]   -> prom_a 0xFB34CA
	.long SysExCmd_ThirdRegionRequest                       ; F4F8EC  [25]   -> prom_a 0xFB3495
	.long SysExParam_Request_DispatchGroup                       ; F4F8F0  [26]   -> prom_a 0xFB42AB
	.long SysExCmd_DumpRequest_SystemPartMidi                       ; F4F8F4  [27]   -> prom_a 0xFB5122
	.long SysExCmd_DumpRequest_Sound                       ; F4F8F8  [28]   -> prom_a 0xFB512C
	.long SysExCmd_DumpRequest_Job1                       ; F4F8FC  [29]   -> prom_a 0xFB5136
	.long SysExCmd_DumpRequest_Sequencer                       ; F4F900  [30]   -> prom_a 0xFB5140
	.long SysExCmd_DumpRequest_Combination                       ; F4F904  [31]   -> prom_a 0xFB514A
	.long SysExCmd_GmSystemOn                       ; F4F908  [32]   -> prom_a 0xFB51E7
	.long SysExCmd_GmSystemOff                       ; F4F90C  [33]   -> prom_a 0xFB520C

; --- 0xF4F910-0xF4F915  data (6 bytes) ---
	.byte 0x88, 0x00, 0x18, 0x00, 0x00, 0x00   ; F4F910  ......

; --- 0xF4F916-0xF4FA79  romtab (356 bytes) ---

; --------------------------------------------------------------------------
; PtrTable_F4F916 -- 34 32-bit pointers, 34 into prom_a and 0 into prom_b
; Read by: prom_a 0xFB28A1 `add XWA,0x00f4f916`
; Entry count: 34, measured by abutment: 34 x 4 = 136 bytes reaches 0xF4F99E
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
PtrTable_F4F916:
	.long SysExSession_Ignore                       ; F4F916  [0]   -> prom_a 0xFB3230
	.long SysExSession_Cmd01_Nop                       ; F4F91A  [1]   -> prom_a 0xFB3231
	.long SysExSession_Cmd02_Nop                       ; F4F91E  [2]   -> prom_a 0xFB3232
	.long SysExSession_CategoryEnd                       ; F4F922  [3]   -> prom_a 0xFB3041
	.long SysExSession_DumpEnd                       ; F4F926  [4]   -> prom_a 0xFB30F7
	.long SysExSession_Abort                       ; F4F92A  [5]   -> prom_a 0xFB3244
	.long SysExSession_Cmd06_Nop                       ; F4F92E  [6]   -> prom_a 0xFB3233
	.long SysExSession_Enquiry                       ; F4F932  [7]   -> prom_a 0xFB28FF
	.long SysExSession_StartTransfer                       ; F4F936  [8]   -> prom_a 0xFB291D
	.long SysExSession_Ignore                       ; F4F93A  [9]   -> prom_a 0xFB3230
	.long SysExSession_Continuation                       ; F4F93E  [10]   -> prom_a 0xFB2C6C
	.long SysExSession_RecvSystemPart1                       ; F4F942  [11]   -> prom_a 0xFB2978
	.long SysExSession_RecvSystemPart2                       ; F4F946  [12]   -> prom_a 0xFB29BB
	.long SysExSession_RecvSoundOrphan                       ; F4F94A  [13]   -> prom_a 0xFB29F1
	.long SysExSession_RecvSound                       ; F4F94E  [14]   -> prom_a 0xFB2A27
	.long SysExSession_RecvStub0F                       ; F4F952  [15]   -> prom_a 0xFB2A7B
	.long SysExSession_RecvStub10                       ; F4F956  [16]   -> prom_a 0xFB2ABE
	.long SysExSession_RecvStub11                       ; F4F95A  [17]   -> prom_a 0xFB2AF5
	.long SysExSession_RecvSequencerPart1                       ; F4F95E  [18]   -> prom_a 0xFB2B30
	.long SysExSession_RecvSequencerPart2                       ; F4F962  [19]   -> prom_a 0xFB2B6F
	.long SysExSession_RecvSequencerPart3                       ; F4F966  [20]   -> prom_a 0xFB2BA6
	.long SysExSession_RecvCombinationPart1                       ; F4F96A  [21]   -> prom_a 0xFB2BE1
	.long SysExSession_RecvCombinationPart2                       ; F4F96E  [22]   -> prom_a 0xFB2C35
	.long SysExSession_Ignore                       ; F4F972  [23]   -> prom_a 0xFB3230
	.long SysExSession_Ignore                       ; F4F976  [24]   -> prom_a 0xFB3230
	.long SysExSession_Ignore                       ; F4F97A  [25]   -> prom_a 0xFB3230
	.long SysExSession_Ignore                       ; F4F97E  [26]   -> prom_a 0xFB3230
	.long SysExSession_Ignore                       ; F4F982  [27]   -> prom_a 0xFB3230
	.long SysExSession_Ignore                       ; F4F986  [28]   -> prom_a 0xFB3230
	.long SysExSession_Ignore                       ; F4F98A  [29]   -> prom_a 0xFB3230
	.long SysExSession_Ignore                       ; F4F98E  [30]   -> prom_a 0xFB3230
	.long SysExSession_Ignore                       ; F4F992  [31]   -> prom_a 0xFB3230
	.long SysExSession_Ignore                       ; F4F996  [32]   -> prom_a 0xFB3230
	.long SysExSession_Ignore                       ; F4F99A  [33]   -> prom_a 0xFB3230

; --------------------------------------------------------------------------
; SysExSession_ContinuationTable -- 18 32-bit pointers, 18 into prom_a and 0 into prom_b
; Read by: prom_a 0xFB2C88 `add XWA,0x00f4f99e`
; Entry count: 18, measured by abutment: 18 x 4 = 72 bytes reaches 0xF4F9E6
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
SysExSession_ContinuationTable:
	.long SysExSession_RecvBody_HeaderExpected                       ; F4F99E  [0]   -> prom_a 0xFB2C9A
	.long SysExSession_RecvBody_SystemPart1                       ; F4F9A2  [1]   -> prom_a 0xFB2CAD
	.long SysExSession_RecvBody_SystemPart2                       ; F4F9A6  [2]   -> prom_a 0xFB2CE7
	.long SysExSession_RecvBody_HeaderExpected                       ; F4F9AA  [3]   -> prom_a 0xFB2C9A
	.long SysExSession_RecvBody_SoundOrphan                       ; F4F9AE  [4]   -> prom_a 0xFB2D21
	.long SysExSession_RecvBody_Sound                       ; F4F9B2  [5]   -> prom_a 0xFB328D
	.long SysExSession_RecvBody_HeaderExpected                       ; F4F9B6  [6]   -> prom_a 0xFB2C9A
	.long SysExSession_RecvBody_Stub0F                       ; F4F9BA  [7]   -> prom_a 0xFB2D72
	.long SysExSession_RecvBody_Stub10                       ; F4F9BE  [8]   -> prom_a 0xFB2DAC
	.long SysExSession_RecvBody_Stub11                       ; F4F9C2  [9]   -> prom_a 0xFB2DE6
	.long SysExSession_RecvBody_HeaderExpected                       ; F4F9C6  [10]   -> prom_a 0xFB2C9A
	.long SysExSession_RecvBody_SequencerPart1                       ; F4F9CA  [11]   -> prom_a 0xFB2E20
	.long SysExSession_RecvBody_SequencerPart2                       ; F4F9CE  [12]   -> prom_a 0xFB2E69
	.long SysExSession_RecvBody_SequencerPart3                       ; F4F9D2  [13]   -> prom_a 0xFB2EB2
	.long SysExSession_RecvBody_HeaderExpected                       ; F4F9D6  [14]   -> prom_a 0xFB2C9A
	.long SysExSession_RecvBody_CombinationPart1                       ; F4F9DA  [15]   -> prom_a 0xFB2EFB
	.long SysExSession_RecvBody_CombinationPart2                       ; F4F9DE  [16]   -> prom_a 0xFB2F35
	.long SysExSession_RecvBody_HeaderExpected                       ; F4F9E2  [17]   -> prom_a 0xFB2C9A

; --------------------------------------------------------------------------
; SysExSession_CategoryEndTable -- 18 32-bit pointers, 18 into prom_a and 0 into prom_b
; Read by: prom_a 0xFB3055 `add XWA,0x00f4f9e6`
; Entry count: 18, measured by abutment: 18 x 4 = 72 bytes reaches 0xF4FA2E
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
SysExSession_CategoryEndTable:
	.long SysExSession_CategoryEnd_WrongStep                       ; F4F9E6  [0]   -> prom_a 0xFB306C
	.long SysExSession_CategoryEnd_WrongStep                       ; F4F9EA  [1]   -> prom_a 0xFB306C
	.long SysExSession_CategoryEnd_WrongStep                       ; F4F9EE  [2]   -> prom_a 0xFB306C
	.long SysExSession_CategoryEnd_SystemPartMidi                       ; F4F9F2  [3]   -> prom_a 0xFB307F
	.long SysExSession_CategoryEnd_WrongStep                       ; F4F9F6  [4]   -> prom_a 0xFB306C
	.long SysExSession_CategoryEnd_WrongStep                       ; F4F9FA  [5]   -> prom_a 0xFB306C
	.long SysExSession_CategoryEnd_Sound                       ; F4F9FE  [6]   -> prom_a 0xFB3097
	.long SysExSession_CategoryEnd_WrongStep                       ; F4FA02  [7]   -> prom_a 0xFB306C
	.long SysExSession_CategoryEnd_WrongStep                       ; F4FA06  [8]   -> prom_a 0xFB306C
	.long SysExSession_CategoryEnd_WrongStep                       ; F4FA0A  [9]   -> prom_a 0xFB306C
	.long SysExSession_CategoryEnd_Stub                       ; F4FA0E  [10]   -> prom_a 0xFB30AF
	.long SysExSession_CategoryEnd_WrongStep                       ; F4FA12  [11]   -> prom_a 0xFB306C
	.long SysExSession_CategoryEnd_WrongStep                       ; F4FA16  [12]   -> prom_a 0xFB306C
	.long SysExSession_CategoryEnd_WrongStep                       ; F4FA1A  [13]   -> prom_a 0xFB306C
	.long SysExSession_CategoryEnd_Sequencer                       ; F4FA1E  [14]   -> prom_a 0xFB30C7
	.long SysExSession_CategoryEnd_WrongStep                       ; F4FA22  [15]   -> prom_a 0xFB306C
	.long SysExSession_CategoryEnd_WrongStep                       ; F4FA26  [16]   -> prom_a 0xFB306C
	.long SysExSession_CategoryEnd_Combination                       ; F4FA2A  [17]   -> prom_a 0xFB30DF

; --------------------------------------------------------------------------
; SysExSession_AbortTable -- 18 32-bit pointers, 18 into prom_a and 0 into prom_b
; Read by: prom_a 0xFB3265 `add XWA,0x00f4fa2e`
; Entry count: 18, measured by abutment: 18 x 4 = 72 bytes reaches 0xF4FA76
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
SysExSession_AbortTable:
	.long SysExSession_AbortStep_Idle                       ; F4FA2E  [0]   -> prom_a 0xFB3277
	.long SysExSession_AbortStep_SystemPartMidi                       ; F4FA32  [1]   -> prom_a 0xFB3278
	.long SysExSession_AbortStep_SystemPartMidi                       ; F4FA36  [2]   -> prom_a 0xFB3278
	.long SysExSession_AbortStep_SystemPartMidi                       ; F4FA3A  [3]   -> prom_a 0xFB3278
	.long SysExSession_AbortStep_Sound                       ; F4FA3E  [4]   -> prom_a 0xFB327D
	.long SysExSession_AbortStep_Sound                       ; F4FA42  [5]   -> prom_a 0xFB327D
	.long SysExSession_AbortStep_Sound                       ; F4FA46  [6]   -> prom_a 0xFB327D
	.long SysExSession_AbortStep_Stub                       ; F4FA4A  [7]   -> prom_a 0xFB3282
	.long SysExSession_AbortStep_Stub                       ; F4FA4E  [8]   -> prom_a 0xFB3282
	.long SysExSession_AbortStep_Stub                       ; F4FA52  [9]   -> prom_a 0xFB3282
	.long SysExSession_AbortStep_Stub                       ; F4FA56  [10]   -> prom_a 0xFB3282
	.long SysExSession_AbortStep_Sequencer                       ; F4FA5A  [11]   -> prom_a 0xFB3287
	.long SysExSession_AbortStep_Sequencer                       ; F4FA5E  [12]   -> prom_a 0xFB3287
	.long SysExSession_AbortStep_Sequencer                       ; F4FA62  [13]   -> prom_a 0xFB3287
	.long SysExSession_AbortStep_Sequencer                       ; F4FA66  [14]   -> prom_a 0xFB3287
	.long SysExSession_AbortStep_Combination                       ; F4FA6A  [15]   -> prom_a 0xFB328C
	.long SysExSession_AbortStep_Combination                       ; F4FA6E  [16]   -> prom_a 0xFB328C
	.long SysExSession_AbortStep_Combination                       ; F4FA72  [17]   -> prom_a 0xFB328C

; --------------------------------------------------------------------------
; MidiSysEx_Tail3Init -- not a pointer: three bytes that prom_a's SysExTx_Tempo copies into its frame
;          (`lda xiy,(this)` / `ldw bc,3` / `ldir`, 0xFB3360-0xFB336B), the C compiler's initializer for
;          a 3-byte local.  The routine overwrites the first two with computed values
;          (0xFB33CF, 0xFB33DA) and passes all three to SysExTx_Append, so the 0xF7 (MIDI
;          end-of-exclusive) stays as the last byte.  This was read as `.long 0x00F70708`,
;          a pointer that lands inside an instruction.
MidiSysEx_Tail3Init:	.byte	0x08, 0x07, 0xf7	; F4FA76
	.byte	0x00	; F4FA79

; --- 0xF4FA7A-0xF4FA9A  data (33 bytes) ---
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F4FA7A  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F4FA8A  ................
	.byte 0x00   ; F4FA9A  .

; --- 0xF4FA9B-0xF4FB1B  bytemap (129 bytes) ---

; --------------------------------------------------------------------------
; IndexMap_F4FA9B -- 129 bytes: a code -> dense-index map, 0xFF = no entry
; Read by: prom_a 0xFB3AE2 `add XWA,0x00f4fa9c`; prom_a 0xFB4A28 `add
;          XWA,0x00f4fa9c`.  Note the base is 0xF4FA9C, ONE BYTE PAST the
;          object, so the reader's input k reads entry k+1.
; Contents: 69 live entries out of 129, and they are strictly increasing:
;           entry 0 is 0, then three contiguous input bands 33-55, 65-87,
;           97-118 map onto 1-23, 24-46 and 47-68.  Everything else is 0xFF.
; ⚠ NOT a monotone map: the layout classifies this segment with
;                       monotone_maps(), and the 129 bytes are NOT monotone
;                       -- 59 adjacent pairs are equal or falling, because
;                       of the 0xFF holes.  It is the LIVE entries that
;                       increase.  Stated here rather than repeating the
;                       rule's name as if it were a description.
; Evidence: the bands and the live count are re-derived by index_bands() and
;           checked in --selftest, last band included.
; ⚠ ANSWERED 2026-09-25 (lane promb): what the two index spaces are.  The input k is
;   a SYSEX MESSAGE BYTE: both readers first call prom_a U8Rec16_GetField for field 11
;   of the decode result at (0x60FCD8), the byte SysExDecodeTree_Root's walk
;   matched at level 6 -- the parameter byte of `.. gg pp` -- and the dense index
;   is an EFFECT PARAMETER NUMBER: 0xFB3AFD hands it to T_DspParam_WriteByNumber =
;   DspParam_WriteByNumber and 0xFB4A41 to T_DspParam_ReadByNumber = DspParam_ReadByNumber, which
;   look it up in EffectParamNumberMap.  So byte 0x20+i is the i-th addressable
;   byte of DSP effect block 97 (i < 23), 0x40+i of block 98 and 0x60+i of block
;   99 (i < 22, block 99 having no byte 21).  Checked by
;   python3 notes/promb-2026-09-25/dsp_effect_tables.py.
; --------------------------------------------------------------------------
IndexMap_F4FA9B:
	.byte 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; F4FA9B  ................
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; F4FAAB  ................
	.byte 0xff, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f   ; F4FABB  ................
	.byte 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; F4FACB  ................
	.byte 0xff, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26   ; F4FADB  ......... !"#$%&
	.byte 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; F4FAEB  '()*+,-.........
	.byte 0xff, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d   ; F4FAFB  ./0123456789:;<=
	.byte 0x3e, 0x3f, 0x40, 0x41, 0x42, 0x43, 0x44, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; F4FB0B  >?@ABCD.........
	.byte 0xff   ; F4FB1B  .

; --- 0xF4FB1C-0xF4FE37  romtab (796 bytes) ---

; --------------------------------------------------------------------------
; SysExInitial_ItemTable -- 7 32-bit pointers, 7 into prom_a and 0 into prom_b
; Read by: prom_a 0xFB3E87 `add XBC,0x00f4fb1c`
; Entry count: 7, measured by abutment: 7 x 4 = 28 bytes reaches 0xF4FB38
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
; SysExInitial_ItemTable: the seven INITIAL arms SysExParam_SetInitial (prom_a 0xFB3E5A) jumps through, in the screen's item order (notes/FINDINGS-prom_a-initial.md)
SysExInitial_ItemTable:
	.long SysExInitial_Total                       ; F4FB1C  [0]   -> prom_a 0xFB3DBC
	.long SysExInitial_PartSetting                       ; F4FB20  [1]   -> prom_a 0xFB3DCD
	.long SysExInitial_System                       ; F4FB24  [2]   -> prom_a 0xFB3DD2
	.long SysExInitial_MidiSetting                       ; F4FB28  [3]   -> prom_a 0xFB3DE6
	.long SysExInitial_ReMap                       ; F4FB2C  [4]   -> prom_a 0xFB3E02
	.long SysExInitial_DrumsMap                       ; F4FB30  [5]   -> prom_a 0xFB3E22
	.long SysExInitial_Sequencer                       ; F4FB34  [6]   -> prom_a 0xFB3E3E

; --------------------------------------------------------------------------
; SysExTx_StagedParamHandlers -- 192 32-bit pointers, 192 into prom_a and 0 into prom_b
; Read by: prom_a 0xFB4BC5 `add XWA,0x00f4fb38`
; Entry count: 192, measured by abutment: 192 x 4 = 768 bytes reaches
;              0xF4FE38 exactly, which is the next address an instruction
;              names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
SysExTx_StagedParamHandlers:
	.long SysExTx_StagedParam_Ignore                       ; F4FB38  [0]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB3C  [1]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB40  [2]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB44  [3]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB48  [4]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB4C  [5]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB50  [6]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB54  [7]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB58  [8]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB5C  [9]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB60  [10]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB64  [11]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB68  [12]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB6C  [13]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB70  [14]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB74  [15]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB78  [16]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB7C  [17]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB80  [18]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB84  [19]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB88  [20]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB8C  [21]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB90  [22]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB94  [23]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB98  [24]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FB9C  [25]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBA0  [26]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBA4  [27]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBA8  [28]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBAC  [29]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBB0  [30]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBB4  [31]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBB8  [32]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBBC  [33]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBC0  [34]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBC4  [35]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBC8  [36]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBCC  [37]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBD0  [38]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBD4  [39]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBD8  [40]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBDC  [41]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBE0  [42]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBE4  [43]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBE8  [44]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBEC  [45]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBF0  [46]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBF4  [47]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBF8  [48]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FBFC  [49]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC00  [50]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC04  [51]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC08  [52]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC0C  [53]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC10  [54]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC14  [55]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC18  [56]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC1C  [57]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC20  [58]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC24  [59]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC28  [60]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC2C  [61]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC30  [62]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC34  [63]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC38  [64]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC3C  [65]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC40  [66]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC44  [67]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC48  [68]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC4C  [69]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC50  [70]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC54  [71]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Record48                       ; F4FC58  [72]   -> prom_a 0xFB4BDE
	.long SysExTx_StagedParam_Ignore                       ; F4FC5C  [73]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC60  [74]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC64  [75]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC68  [76]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC6C  [77]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC70  [78]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC74  [79]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC78  [80]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC7C  [81]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC80  [82]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC84  [83]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC88  [84]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC8C  [85]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC90  [86]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC94  [87]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC98  [88]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FC9C  [89]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCA0  [90]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCA4  [91]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCA8  [92]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCAC  [93]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCB0  [94]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCB4  [95]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Record60                       ; F4FCB8  [96]   -> prom_a 0xFB4C12
	.long SysExTx_StagedParam_Ignore                       ; F4FCBC  [97]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCC0  [98]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCC4  [99]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCC8  [100]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCCC  [101]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCD0  [102]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCD4  [103]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCD8  [104]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCDC  [105]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCE0  [106]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCE4  [107]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCE8  [108]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCEC  [109]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCF0  [110]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FCF4  [111]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Record70                       ; F4FCF8  [112]   -> prom_a 0xFB4C46
	.long SysExTx_StagedParam_Ignore                       ; F4FCFC  [113]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD00  [114]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD04  [115]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD08  [116]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD0C  [117]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD10  [118]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD14  [119]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD18  [120]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD1C  [121]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD20  [122]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD24  [123]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD28  [124]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD2C  [125]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD30  [126]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD34  [127]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD38  [128]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD3C  [129]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD40  [130]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD44  [131]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD48  [132]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD4C  [133]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD50  [134]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD54  [135]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD58  [136]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD5C  [137]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD60  [138]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD64  [139]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD68  [140]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD6C  [141]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD70  [142]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD74  [143]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD78  [144]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD7C  [145]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD80  [146]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD84  [147]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD88  [148]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD8C  [149]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD90  [150]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FD94  [151]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Record98                       ; F4FD98  [152]   -> prom_a 0xFB4C7A
	.long SysExTx_StagedParam_Ignore                       ; F4FD9C  [153]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDA0  [154]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDA4  [155]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDA8  [156]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDAC  [157]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDB0  [158]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDB4  [159]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDB8  [160]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDBC  [161]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDC0  [162]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDC4  [163]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDC8  [164]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDCC  [165]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDD0  [166]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDD4  [167]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDD8  [168]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDDC  [169]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDE0  [170]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDE4  [171]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDE8  [172]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDEC  [173]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDF0  [174]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FDF4  [175]   -> prom_a 0xFB4BDD
	.long SysExTx_GmSystemOnOff                       ; F4FDF8  [176]   -> prom_a 0xFB4CAE
	.long SysExTx_StagedParam_Ignore                       ; F4FDFC  [177]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FE00  [178]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FE04  [179]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FE08  [180]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FE0C  [181]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FE10  [182]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FE14  [183]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FE18  [184]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FE1C  [185]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FE20  [186]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FE24  [187]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FE28  [188]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FE2C  [189]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FE30  [190]   -> prom_a 0xFB4BDD
	.long SysExTx_StagedParam_Ignore                       ; F4FE34  [191]   -> prom_a 0xFB4BDD

; --- 0xF4FE38-0xF4FF60  data (297 bytes) ---
; ==========================================================================
; 0xF4FE38-0xF4FF60 -- five objects, typed 2026-09-25 (lane promb).  Until
;   then these 297 bytes were one untyped `.byte` run after SysExTx_StagedParamHandlers,
;   and the census counted them as part of that table.
; ==========================================================================

; --------------------------------------------------------------------------
; ParamFieldInit_x32_F4FE38 -- 6 records of 4 bytes {parameter number, field
;   offset, value, mask}.  Read by prom_a GmReset_FieldTablesAndEffectAlgorithms (0xFB558F, called from
;   0xFB58FF): each record is copied to a local and handed to prom_a
;   IndexedTable_MergeMaskedByte THIRTY-TWO times, the parameter number incremented each time
;   (`ld H,0x20` / `incm8 1,(XIZ-4)`).  IndexedTable_MergeMaskedByte looks the parameter number up
;   with IndexedTable_GetPtr -- i.e. in prom_a's ParamNumber_RecordPtrs, the
;   work-RAM record of that parameter -- and, unless the lookup gives
;   0xFFFFFFFF, writes (record[field] AND NOT mask) OR (value AND mask).  So
;   each row sets one field of 32 consecutive parameter records (numbers
;   0x00-0x1F for row 0, 0x20-0x3F for the others).
; Unknown: what the fields are and what the routine initialises them for.
; --------------------------------------------------------------------------
ParamFieldInit_x32_F4FE38:
	.byte	0x00, 0x0C, 0x00, 0x08	; F4FE38  [0] param 0x00, field +12, value 0x00, mask 0x08
	.byte	0x20, 0x03, 0x01, 0xFF	; F4FE3C  [1] param 0x20, field +3, value 0x01, mask 0xFF
	.byte	0x20, 0x04, 0x00, 0xFF	; F4FE40  [2] param 0x20, field +4, value 0x00, mask 0xFF
	.byte	0x20, 0x05, 0x18, 0xFF	; F4FE44  [3] param 0x20, field +5, value 0x18, mask 0xFF
	.byte	0x20, 0x06, 0x00, 0x0F	; F4FE48  [4] param 0x20, field +6, value 0x00, mask 0x0F
	.byte	0x20, 0x17, 0x40, 0xFF	; F4FE4C  [5] param 0x20, field +23, value 0x40, mask 0xFF

; --------------------------------------------------------------------------
; ParamFieldInit_F4FE50 -- 6 records of the same shape, applied ONCE each by
;   the second loop of prom_a GmReset_FieldTablesAndEffectAlgorithms (`ld H,0x06`, one IndexedTable_MergeMaskedByte call per
;   record).  Two rows write the same field of parameter 0x79 through the two
;   nibble masks 0x0F and 0xF0.
; --------------------------------------------------------------------------
ParamFieldInit_F4FE50:
	.byte	0x60, 0x00, 0x00, 0xFF	; F4FE50  [0] param 0x60, field +0, value 0x00, mask 0xFF
	.byte	0x7A, 0x02, 0x00, 0x0F	; F4FE54  [1] param 0x7A, field +2, value 0x00, mask 0x0F
	.byte	0x98, 0x09, 0x01, 0x01	; F4FE58  [2] param 0x98, field +9, value 0x01, mask 0x01
	.byte	0x79, 0x05, 0x01, 0x0F	; F4FE5C  [3] param 0x79, field +5, value 0x01, mask 0x0F
	.byte	0x79, 0x05, 0x10, 0xF0	; F4FE60  [4] param 0x79, field +5, value 0x10, mask 0xF0
	.byte	0x91, 0x04, 0x00, 0xFF	; F4FE64  [5] param 0x91, field +4, value 0x00, mask 0xFF

; --------------------------------------------------------------------------
; Word_F4FE68 -- one word, 0xF700.  Read by prom_a SysExTx_AppendChecksumF7 (0xFB7119
;   `ld BC,(0xF4FE68)`), which works on the output buffer at (0x60FC88).
; WordTables_F4FE6A / _F4FE76 -- two 6-entry tables of 16-bit words, read by
;   prom_a SysEx_FeatureWordForVariant: for an argument k < 6 it takes 0xF4FE6A when the strap
;   byte (0xC4) is 1 and 0xF4FE76 otherwise, and returns word [k] (`mul
;   BC,2`).  The first table is all zero; the second is 0, 0, 0, 0xFFFF, 0,
;   0xFFFF.  What k and the words mean is not decoded here.
; (Lane promb, 2026-09-25: a first draft of this block said nothing reads
;   these 26 bytes.  It had searched 32-bit spellings only; prom_a names them
;   with 24-bit operands.)
; --------------------------------------------------------------------------
Word_F4FE68:
	.short	0xF700	; F4FE68
WordTable_F4FE6A:
	.short	0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	; F4FE6A  [0..5]  (0xC4) == 1
WordTable_F4FE76:
	.short	0x0000, 0x0000, 0x0000, 0xFFFF, 0x0000, 0xFFFF	; F4FE76  [0..5]  otherwise

; --------------------------------------------------------------------------
; SysExRxClass_ByResult -- 34 bytes, indexed by the result code the SysEx
;   decode tree (SysExDecodeTree_Root) leaves in field 0: 1..33 are the codes
;   its leaves carry.  Read by prom_a SysExRx_CheckCommandClass (0xFB6BAE `add
;   XWA,0x00F4FE82`), which then gates the message on the byte at (0x7FD6):
;   class 1 needs bit 1, class 2 bit 0, class 3 either; when the bit is clear
;   it writes 0x21 into field 4 (the failure field), and class 0 passes.
; Values: codes 10, 11, 12 -> class 3; 13, 14, 23 -> class 2; 21, 22 ->
;   class 1; every other code -> 0.
; --------------------------------------------------------------------------
SysExRxClass_ByResult:
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x03, 0x03, 0x02, 0x02, 0x00	; F4FE82  [0..15]
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F4FE92  [16..31]
	.byte	0x00, 0x00	; F4FEA2  [32..33]
; ZeroBlock16_F4FEA4 -- 16 zero bytes, an initializer: prom_a SysExXfer_ClearJobRecords
;   copies them (`ldirw`, 8 words) to 0x60FCE8 and then copies that on to
;   0x60FCF8 and 0x60FD08.
ZeroBlock16_F4FEA4:
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F4FEA4

; --------------------------------------------------------------------------
; SysExMessageStrings_F4FEB4 -- 22 System Exclusive byte strings, 173 bytes:
;   Technics (ID 0x50) and universal non-real-time (0x7E) messages.  Each line
;   below carries what SysExDecodeTree_Root makes of it (after F0 and the ID,
;   without the closing F7), re-derived from the ROM when this block was
;   emitted: 20 are complete paths ending on a leaf, one (`2C 04 00 11`) is
;   the prefix of the parameter-change family (the 3-byte address follows),
;   and one is not accepted.
; Read by: prom_a's SysEx TRANSMIT code.  Every string start is the operand of
;   at least one `lda XBC,(0xF4FExx:24)` / `lda XWA,...` in prom_a, in the
;   shape `pushw n / lda XBC,<string> / push XBC / call SysExTx_AppendAndSendOnF7`;
;   SysExTx_AppendAndSendOnF7 appends n bytes to the output buffer whose descriptor is at
;   (0x60FC88) (+0x0A = write pointer), writes a 0xFF after them, and when the
;   last byte is 0xF7 hands the message on (SysExTx_SendFrameMidi1, SysExSession_RefreshProgressScreen,
;   SysExTx_SwapBuffers).  `2C 04 00 11` alone is named by nine sites: the header of a
;   parameter change whose address and data the caller appends.  So these are
;   the messages this machine SENDS, and the decode tree accepts the same
;   ones on the way in.
; ⚠ prom_a's header at 0xFB248A calls the 12 bytes at 0xF4FF10 "one 12-byte
;   display list"; they are this SysEx string (F0 50 2D 04 00 11 20 00 00 00
;   00 10), sent by the same `call SysExTx_AppendAndSendOnF7`.  (Not this lane's file.)
; --------------------------------------------------------------------------
SysExMessageStrings_F4FEB4:
	.byte	0xF0, 0x50, 0x23, 0x7E, 0xF7	; F4FEB4  F0 50 23 7E F7 -- decode-tree result 1
	.byte	0xF0, 0x50, 0x24, 0x7E, 0xF7	; F4FEB9  F0 50 24 7E F7 -- decode-tree result 2
	.byte	0xF0, 0x50, 0x27, 0x7E, 0xF7	; F4FEBE  F0 50 27 7E F7 -- decode-tree result 3
	.byte	0xF0, 0x50, 0x28, 0x7E, 0xF7	; F4FEC3  F0 50 28 7E F7 -- decode-tree result 4
	.byte	0xF0, 0x50, 0x29, 0x7E, 0xF7	; F4FEC8  F0 50 29 7E F7 -- decode-tree result 5
	.byte	0xF0, 0x50, 0x2A, 0x7E, 0xF7	; F4FECD  F0 50 2A 7E F7 -- decode-tree result 4
	.byte	0xF0, 0x50, 0x7E	; F4FED2  F0 50 7E -- decode-tree result 10
	.byte	0xF0, 0x50, 0x21, 0x04, 0x00, 0x11, 0xF7	; F4FED5  F0 50 21 04 00 11 F7 -- decode-tree result 7
	.byte	0xF0, 0x50, 0x22, 0x04, 0x00, 0x11, 0xF7	; F4FEDC  F0 50 22 04 00 11 F7 -- decode-tree result 8
	.byte	0xF0, 0x50, 0x25	; F4FEE3  F0 50 25 -- decode-tree result 9
	.byte	0xF0, 0x7E, 0x7F, 0x09, 0x01, 0xF7	; F4FEE6  F0 7E 7F 09 01 F7 -- decode-tree result 32
	.byte	0xF0, 0x7E, 0x7F, 0x09, 0x02, 0xF7	; F4FEEC  F0 7E 7F 09 02 F7 -- decode-tree result 33
	.byte	0xF0, 0x50, 0x2C, 0x04, 0x00, 0x11	; F4FEF2  F0 50 2C 04 00 11 -- a prefix of the tree (needs more bytes)
	.byte	0xF0, 0x50, 0x2D, 0x04, 0x00, 0x11, 0x40, 0x00, 0x00, 0x00, 0x00, 0x20	; F4FEF8  F0 50 2D 04 00 11 40 00 00 00 00 20 -- decode-tree result 11
	.byte	0xF0, 0x50, 0x2D, 0x04, 0x00, 0x11, 0x40, 0x00, 0x20, 0x00, 0x12, 0x60	; F4FF04  F0 50 2D 04 00 11 40 00 20 00 12 60 -- decode-tree result 12
	.byte	0xF0, 0x50, 0x2D, 0x04, 0x00, 0x11, 0x20, 0x00, 0x00, 0x00, 0x00, 0x10	; F4FF10  F0 50 2D 04 00 11 20 00 00 00 00 10 -- not decoded (fails at byte 8)
	.byte	0xF0, 0x50, 0x2D, 0x04, 0x00, 0x11, 0x20, 0x00, 0x00, 0x10, 0x00, 0x00	; F4FF1C  F0 50 2D 04 00 11 20 00 00 10 00 00 -- decode-tree result 14
	.byte	0xF0, 0x50, 0x2D, 0x04, 0x00, 0x11, 0x60, 0x00, 0x00, 0x00, 0x18, 0x00	; F4FF28  F0 50 2D 04 00 11 60 00 00 00 18 00 -- decode-tree result 18
	.byte	0xF0, 0x50, 0x2D, 0x04, 0x00, 0x11, 0x60, 0x18, 0x00, 0x01, 0x70, 0x00	; F4FF34  F0 50 2D 04 00 11 60 18 00 01 70 00 -- decode-tree result 19
	.byte	0xF0, 0x50, 0x2D, 0x04, 0x00, 0x11, 0x62, 0x08, 0x00	; F4FF40  F0 50 2D 04 00 11 62 08 00 -- decode-tree result 20
	.byte	0xF0, 0x50, 0x2D, 0x04, 0x00, 0x11, 0x50, 0x00, 0x00, 0x00, 0x06, 0x00	; F4FF49  F0 50 2D 04 00 11 50 00 00 00 06 00 -- decode-tree result 21
	.byte	0xF0, 0x50, 0x2D, 0x04, 0x00, 0x11, 0x50, 0x06, 0x00, 0x05, 0x40, 0x00	; F4FF55  F0 50 2D 04 00 11 50 06 00 05 40 00 -- decode-tree result 22

; --- 0xF4FF61-0xF511B4  link (4692 bytes) ---

; --------------------------------------------------------------------------
; LinkTable_F4FF61 -- 782 records of `[u16 key][u32 next]`
; Evidence: 779 of the 782 `next` pointers are non-zero and ALL 779 of them
;           land exactly on a record boundary of this table -- the rule the
;           layout's link_tables() walks, whose null corpus is 107,345 bytes
;           of proven prom_b instruction text on which it fires zero times.
; Read by: prom_a 0xFB63FC does `add XBC,0x00f5115b`, and 0xF5115B is record
;          767 of this table exactly -- so prom_a indexes a sub-array that
;          begins 767 records in.
; Keys:    353 distinct over 782 records, spanning 0x0000-0xFFFF.
;          ⚠ CORRECTED 2026-09-25: this line used to file what the keys mean
;          and where the traversal is under the open questions; both are
;          answered in the ANSWERED block below -- a "key" is a match byte
;          and a result byte, and the traversal is prom_a SysExRx_MatchTrie.
; --------------------------------------------------------------------------
; ⚠ ANSWERED 2026-09-25 (lane promb): the traversal IS located, and the
;   "keys" are two bytes, not one u16.  This is a SYSEX DECODE TREE.
; Read by: prom_a SysExRx_MatchTrie (0xFB63D1), called from SysExRx_ParseMessage (0xFB63AF)
;   after the MIDI receiver around 0xFB20E3 has collected a System Exclusive
;   message -- it waits for 0xF0, accepts ID 0x50 or 0x7E, appends data bytes
;   to the buffer at (0x60FC80) and calls the parse on 0xF7.  The walk starts
;   at record 767, SysExDecodeTree_Root (0xF5115B, `add XBC,0x00F5115B` at
;   0xFB63FC), and descends ONE MESSAGE BYTE PER LEVEL, levels 0..9: it reads
;   the next byte (SysExBuf_ReadByte; 0xFF ends the message), scans the current list
;   of 6-byte records for +0 == byte (+0 == 0xFE matches any byte, below the
;   top level), stores the byte in field 5+level of the result object at
;   (0x60FCD8) (U8Rec16_SetField), and then
;     +1 == 0   descend: +2 is the next level's list;
;     +1 != 0   a LEAF: field 0 := +1, and the first two bytes of the record
;               +2 points at become fields 1 and 2;
;     +0 == 0xFF (end of list) fails the parse with code 7+level in field 4.
; Record layout: +0 u8 match byte, +1 u8 result, +2 u32 pointer (this
;   table's own records only).  The 782 records are 127 lists (562 records)
;   reachable from the root, 213 leaf PAYLOAD records (+0/+1 are the two
;   result bytes, +2 always names record 0) and 7 reached by neither.
; What it decodes: the top-level match bytes are 0x21-0x2D, 0x7E and 0x7F,
;   i.e. the byte after the SysEx ID -- `2C 04 00 11 00 gg pp` is a
;   parameter-change address, and all 74 bodies SmfExport_ParamSysExTemplates
;   writes (from their +4 byte) are complete 7-byte paths ending on a leaf, so
;   an exported file's setup messages are ones this machine decodes.
; Check: every list's terminator carries 7+depth in its +1 byte in 123 of the
;   127 lists -- the very code the reader stores on failing at that depth
;   (it does not read the byte; four depth-8/9 lists say 14).
;   python3 notes/promb-2026-09-25/sysex_decode_tree_probe.py re-derives all
;   of the above from the ROMs (reader decode included).
; Unknown: what the leaf's result and pair bytes select -- they are
;   consumed after the walk (prom_a 0xFB6B87 onwards), not here.
LinkTable_F4FF61:
	.byte 0xff, 0xff, 0x61, 0xff, 0xf4, 0x00   ; F4FF61  [  0] key 0xFFFF  -> rec 0
	.byte 0x11, 0x07, 0x61, 0xff, 0xf4, 0x00   ; F4FF67  [  1] key 0x0711  -> rec 0
	.byte 0xff, 0x0a, 0x61, 0xff, 0xf4, 0x00   ; F4FF6D  [  2] key 0x0AFF  -> rec 0
	.byte 0x00, 0x00, 0x67, 0xff, 0xf4, 0x00   ; F4FF73  [  3] key 0x0000  -> rec 1
	.byte 0x01, 0x00, 0x67, 0xff, 0xf4, 0x00   ; F4FF79  [  4] key 0x0001  -> rec 1
	.byte 0xff, 0x09, 0x61, 0xff, 0xf4, 0x00   ; F4FF7F  [  5] key 0x09FF  -> rec 0
	.byte 0x04, 0x00, 0x73, 0xff, 0xf4, 0x00   ; F4FF85  [  6] key 0x0004  -> rec 3
	.byte 0xff, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F4FF8B  [  7] key 0x08FF  -> rec 0
	.byte 0x11, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F4FF91  [  8] key 0x0811  -> rec 0
	.byte 0xff, 0x0a, 0x61, 0xff, 0xf4, 0x00   ; F4FF97  [  9] key 0x0AFF  -> rec 0
	.byte 0x00, 0x00, 0x91, 0xff, 0xf4, 0x00   ; F4FF9D  [ 10] key 0x0000  -> rec 8
	.byte 0x01, 0x00, 0x91, 0xff, 0xf4, 0x00   ; F4FFA3  [ 11] key 0x0001  -> rec 8
	.byte 0xff, 0x09, 0x61, 0xff, 0xf4, 0x00   ; F4FFA9  [ 12] key 0x09FF  -> rec 0
	.byte 0x04, 0x00, 0x9d, 0xff, 0xf4, 0x00   ; F4FFAF  [ 13] key 0x0004  -> rec 10
	.byte 0xff, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F4FFB5  [ 14] key 0x08FF  -> rec 0
	.byte 0x01, 0x20, 0x61, 0xff, 0xf4, 0x00   ; F4FFBB  [ 15] key 0x2001  -> rec 0
	.byte 0x02, 0x21, 0x61, 0xff, 0xf4, 0x00   ; F4FFC1  [ 16] key 0x2102  -> rec 0
	.byte 0xff, 0x09, 0x61, 0xff, 0xf4, 0x00   ; F4FFC7  [ 17] key 0x09FF  -> rec 0
	.byte 0x09, 0x00, 0xbb, 0xff, 0xf4, 0x00   ; F4FFCD  [ 18] key 0x0009  -> rec 15
	.byte 0xff, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F4FFD3  [ 19] key 0x08FF  -> rec 0
	.byte 0x7e, 0x01, 0x61, 0xff, 0xf4, 0x00   ; F4FFD9  [ 20] key 0x017E  -> rec 0
	.byte 0xff, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F4FFDF  [ 21] key 0x08FF  -> rec 0
	.byte 0x7e, 0x02, 0x61, 0xff, 0xf4, 0x00   ; F4FFE5  [ 22] key 0x027E  -> rec 0
	.byte 0xff, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F4FFEB  [ 23] key 0x08FF  -> rec 0
	.byte 0x7e, 0x03, 0x61, 0xff, 0xf4, 0x00   ; F4FFF1  [ 24] key 0x037E  -> rec 0
	.byte 0xff, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F4FFF7  [ 25] key 0x08FF  -> rec 0
	.byte 0x7e, 0x04, 0x61, 0xff, 0xf4, 0x00   ; F4FFFD  [ 26] key 0x047E  -> rec 0
	.byte 0xff, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F50003  [ 27] key 0x08FF  -> rec 0
	.byte 0x7e, 0x05, 0x61, 0xff, 0xf4, 0x00   ; F50009  [ 28] key 0x057E  -> rec 0
	.byte 0xff, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F5000F  [ 29] key 0x08FF  -> rec 0
	.byte 0x7e, 0x04, 0x61, 0xff, 0xf4, 0x00   ; F50015  [ 30] key 0x047E  -> rec 0
	.byte 0xff, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F5001B  [ 31] key 0x08FF  -> rec 0
	.byte 0x00, 0x14, 0x61, 0xff, 0xf4, 0x00   ; F50021  [ 32] key 0x1400  -> rec 0
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50027  [ 33] key 0x0DFF  -> rec 0
	.byte 0x08, 0x00, 0x21, 0x00, 0xf5, 0x00   ; F5002D  [ 34] key 0x0008  -> rec 32
	.byte 0xff, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F50033  [ 35] key 0x0CFF  -> rec 0
	.byte 0x00, 0x13, 0x61, 0xff, 0xf4, 0x00   ; F50039  [ 36] key 0x1300  -> rec 0
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F5003F  [ 37] key 0x10FF  -> rec 0
	.byte 0x70, 0x00, 0x39, 0x00, 0xf5, 0x00   ; F50045  [ 38] key 0x0070  -> rec 36
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F5004B  [ 39] key 0x0FFF  -> rec 0
	.byte 0x01, 0x00, 0x45, 0x00, 0xf5, 0x00   ; F50051  [ 40] key 0x0001  -> rec 38
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F50057  [ 41] key 0x0EFF  -> rec 0
	.byte 0x00, 0x00, 0x51, 0x00, 0xf5, 0x00   ; F5005D  [ 42] key 0x0000  -> rec 40
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50063  [ 43] key 0x0DFF  -> rec 0
	.byte 0x00, 0x12, 0x61, 0xff, 0xf4, 0x00   ; F50069  [ 44] key 0x1200  -> rec 0
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F5006F  [ 45] key 0x10FF  -> rec 0
	.byte 0x18, 0x00, 0x69, 0x00, 0xf5, 0x00   ; F50075  [ 46] key 0x0018  -> rec 44
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F5007B  [ 47] key 0x0FFF  -> rec 0
	.byte 0x00, 0x00, 0x75, 0x00, 0xf5, 0x00   ; F50081  [ 48] key 0x0000  -> rec 46
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F50087  [ 49] key 0x0EFF  -> rec 0
	.byte 0x00, 0x00, 0x81, 0x00, 0xf5, 0x00   ; F5008D  [ 50] key 0x0000  -> rec 48
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50093  [ 51] key 0x0DFF  -> rec 0
	.byte 0x00, 0x00, 0x8d, 0x00, 0xf5, 0x00   ; F50099  [ 52] key 0x0000  -> rec 50
	.byte 0x18, 0x00, 0x5d, 0x00, 0xf5, 0x00   ; F5009F  [ 53] key 0x0018  -> rec 42
	.byte 0xff, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F500A5  [ 54] key 0x0CFF  -> rec 0
	.byte 0x00, 0x16, 0x61, 0xff, 0xf4, 0x00   ; F500AB  [ 55] key 0x1600  -> rec 0
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F500B1  [ 56] key 0x10FF  -> rec 0
	.byte 0x40, 0x00, 0xab, 0x00, 0xf5, 0x00   ; F500B7  [ 57] key 0x0040  -> rec 55
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F500BD  [ 58] key 0x0FFF  -> rec 0
	.byte 0x05, 0x00, 0xb7, 0x00, 0xf5, 0x00   ; F500C3  [ 59] key 0x0005  -> rec 57
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F500C9  [ 60] key 0x0EFF  -> rec 0
	.byte 0x00, 0x00, 0xc3, 0x00, 0xf5, 0x00   ; F500CF  [ 61] key 0x0000  -> rec 59
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F500D5  [ 62] key 0x0DFF  -> rec 0
	.byte 0x00, 0x15, 0x61, 0xff, 0xf4, 0x00   ; F500DB  [ 63] key 0x1500  -> rec 0
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F500E1  [ 64] key 0x10FF  -> rec 0
	.byte 0x06, 0x00, 0xdb, 0x00, 0xf5, 0x00   ; F500E7  [ 65] key 0x0006  -> rec 63
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F500ED  [ 66] key 0x0FFF  -> rec 0
	.byte 0x00, 0x00, 0xe7, 0x00, 0xf5, 0x00   ; F500F3  [ 67] key 0x0000  -> rec 65
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F500F9  [ 68] key 0x0EFF  -> rec 0
	.byte 0x00, 0x00, 0xf3, 0x00, 0xf5, 0x00   ; F500FF  [ 69] key 0x0000  -> rec 67
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50105  [ 70] key 0x0DFF  -> rec 0
	.byte 0x00, 0x00, 0xff, 0x00, 0xf5, 0x00   ; F5010B  [ 71] key 0x0000  -> rec 69
	.byte 0x06, 0x00, 0xcf, 0x00, 0xf5, 0x00   ; F50111  [ 72] key 0x0006  -> rec 61
	.byte 0xff, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F50117  [ 73] key 0x0CFF  -> rec 0
	.byte 0x00, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F5011D  [ 74] key 0x0E00  -> rec 0
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F50123  [ 75] key 0x10FF  -> rec 0
	.byte 0x00, 0x00, 0x1d, 0x01, 0xf5, 0x00   ; F50129  [ 76] key 0x0000  -> rec 74
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F5012F  [ 77] key 0x0FFF  -> rec 0
	.byte 0x10, 0x00, 0x29, 0x01, 0xf5, 0x00   ; F50135  [ 78] key 0x0010  -> rec 76
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F5013B  [ 79] key 0x0EFF  -> rec 0
	.byte 0x00, 0x00, 0x35, 0x01, 0xf5, 0x00   ; F50141  [ 80] key 0x0000  -> rec 78
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50147  [ 81] key 0x0DFF  -> rec 0
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F5014D  [ 82] key 0x0000  
	.byte 0x00, 0x00, 0x41, 0x01, 0xf5, 0x00   ; F50153  [ 83] key 0x0000  -> rec 80
	.byte 0xff, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F50159  [ 84] key 0x0CFF  -> rec 0
	.byte 0x60, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F5015F  [ 85] key 0x0C60  -> rec 0
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F50165  [ 86] key 0x10FF  -> rec 0
	.byte 0x12, 0x00, 0x5f, 0x01, 0xf5, 0x00   ; F5016B  [ 87] key 0x0012  -> rec 85
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F50171  [ 88] key 0x0FFF  -> rec 0
	.byte 0x00, 0x00, 0x6b, 0x01, 0xf5, 0x00   ; F50177  [ 89] key 0x0000  -> rec 87
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F5017D  [ 90] key 0x0EFF  -> rec 0
	.byte 0x20, 0x00, 0x77, 0x01, 0xf5, 0x00   ; F50183  [ 91] key 0x0020  -> rec 89
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50189  [ 92] key 0x0DFF  -> rec 0
	.byte 0x00, 0x00, 0x83, 0x01, 0xf5, 0x00   ; F5018F  [ 93] key 0x0000  -> rec 91
	.byte 0xff, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F50195  [ 94] key 0x0CFF  -> rec 0
	.byte 0x20, 0x0b, 0x61, 0xff, 0xf4, 0x00   ; F5019B  [ 95] key 0x0B20  -> rec 0
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F501A1  [ 96] key 0x10FF  -> rec 0
	.byte 0x00, 0x00, 0x9b, 0x01, 0xf5, 0x00   ; F501A7  [ 97] key 0x0000  -> rec 95
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F501AD  [ 98] key 0x0FFF  -> rec 0
	.byte 0x00, 0x00, 0xa7, 0x01, 0xf5, 0x00   ; F501B3  [ 99] key 0x0000  -> rec 97
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F501B9  [100] key 0x0EFF  -> rec 0
	.byte 0x00, 0x00, 0xb3, 0x01, 0xf5, 0x00   ; F501BF  [101] key 0x0000  -> rec 99
	.byte 0x20, 0x00, 0x77, 0x01, 0xf5, 0x00   ; F501C5  [102] key 0x0020  -> rec 89
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F501CB  [103] key 0x0DFF  -> rec 0
	.byte 0x00, 0x00, 0xbf, 0x01, 0xf5, 0x00   ; F501D1  [104] key 0x0000  -> rec 101
	.byte 0xff, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F501D7  [105] key 0x0CFF  -> rec 0
	.byte 0x40, 0x00, 0xd1, 0x01, 0xf5, 0x00   ; F501DD  [106] key 0x0040  -> rec 104
	.byte 0x20, 0x00, 0x53, 0x01, 0xf5, 0x00   ; F501E3  [107] key 0x0020  -> rec 83
	.byte 0x50, 0x00, 0x0b, 0x01, 0xf5, 0x00   ; F501E9  [108] key 0x0050  -> rec 71
	.byte 0x60, 0x00, 0x99, 0x00, 0xf5, 0x00   ; F501EF  [109] key 0x0060  -> rec 52
	.byte 0x62, 0x00, 0x2d, 0x00, 0xf5, 0x00   ; F501F5  [110] key 0x0062  -> rec 34
	.byte 0xff, 0x0b, 0x61, 0xff, 0xf4, 0x00   ; F501FB  [111] key 0x0BFF  -> rec 0
	.byte 0x11, 0x00, 0xdd, 0x01, 0xf5, 0x00   ; F50201  [112] key 0x0011  -> rec 106
	.byte 0xff, 0x0a, 0x61, 0xff, 0xf4, 0x00   ; F50207  [113] key 0x0AFF  -> rec 0
	.byte 0x00, 0x00, 0x01, 0x02, 0xf5, 0x00   ; F5020D  [114] key 0x0000  -> rec 112
	.byte 0x01, 0x00, 0x01, 0x02, 0xf5, 0x00   ; F50213  [115] key 0x0001  -> rec 112
	.byte 0xff, 0x09, 0x61, 0xff, 0xf4, 0x00   ; F50219  [116] key 0x09FF  -> rec 0
	.byte 0x04, 0x00, 0x0d, 0x02, 0xf5, 0x00   ; F5021F  [117] key 0x0004  -> rec 114
	.byte 0xff, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F50225  [118] key 0x08FF  -> rec 0
	.byte 0x01, 0x01, 0x61, 0xff, 0xf4, 0x00   ; F5022B  [119] key 0x0101  -> rec 0
	.byte 0x01, 0x01, 0x61, 0xff, 0xf4, 0x00   ; F50231  [120] key 0x0101  -> rec 0
	.byte 0x01, 0x02, 0x61, 0xff, 0xf4, 0x00   ; F50237  [121] key 0x0201  -> rec 0
	.byte 0x01, 0x02, 0x61, 0xff, 0xf4, 0x00   ; F5023D  [122] key 0x0201  -> rec 0
	.byte 0x01, 0x03, 0x61, 0xff, 0xf4, 0x00   ; F50243  [123] key 0x0301  -> rec 0
	.byte 0x01, 0x03, 0x61, 0xff, 0xf4, 0x00   ; F50249  [124] key 0x0301  -> rec 0
	.byte 0x01, 0x04, 0x61, 0xff, 0xf4, 0x00   ; F5024F  [125] key 0x0401  -> rec 0
	.byte 0x01, 0x04, 0x61, 0xff, 0xf4, 0x00   ; F50255  [126] key 0x0401  -> rec 0
	.byte 0x01, 0x05, 0x61, 0xff, 0xf4, 0x00   ; F5025B  [127] key 0x0501  -> rec 0
	.byte 0x01, 0x05, 0x61, 0xff, 0xf4, 0x00   ; F50261  [128] key 0x0501  -> rec 0
	.byte 0x01, 0x06, 0x61, 0xff, 0xf4, 0x00   ; F50267  [129] key 0x0601  -> rec 0
	.byte 0x01, 0x06, 0x61, 0xff, 0xf4, 0x00   ; F5026D  [130] key 0x0601  -> rec 0
	.byte 0x01, 0x07, 0x61, 0xff, 0xf4, 0x00   ; F50273  [131] key 0x0701  -> rec 0
	.byte 0x01, 0x07, 0x61, 0xff, 0xf4, 0x00   ; F50279  [132] key 0x0701  -> rec 0
	.byte 0x01, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F5027F  [133] key 0x0801  -> rec 0
	.byte 0x01, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F50285  [134] key 0x0801  -> rec 0
	.byte 0x01, 0x09, 0x61, 0xff, 0xf4, 0x00   ; F5028B  [135] key 0x0901  -> rec 0
	.byte 0x01, 0x09, 0x61, 0xff, 0xf4, 0x00   ; F50291  [136] key 0x0901  -> rec 0
	.byte 0x01, 0x0a, 0x61, 0xff, 0xf4, 0x00   ; F50297  [137] key 0x0A01  -> rec 0
	.byte 0x01, 0x0a, 0x61, 0xff, 0xf4, 0x00   ; F5029D  [138] key 0x0A01  -> rec 0
	.byte 0x01, 0x0b, 0x61, 0xff, 0xf4, 0x00   ; F502A3  [139] key 0x0B01  -> rec 0
	.byte 0x01, 0x0b, 0x61, 0xff, 0xf4, 0x00   ; F502A9  [140] key 0x0B01  -> rec 0
	.byte 0x01, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F502AF  [141] key 0x0C01  -> rec 0
	.byte 0x01, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F502B5  [142] key 0x0C01  -> rec 0
	.byte 0x01, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F502BB  [143] key 0x0D01  -> rec 0
	.byte 0x01, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F502C1  [144] key 0x0D01  -> rec 0
	.byte 0x01, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F502C7  [145] key 0x0E01  -> rec 0
	.byte 0x01, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F502CD  [146] key 0x0E01  -> rec 0
	.byte 0x01, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F502D3  [147] key 0x0F01  -> rec 0
	.byte 0x01, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F502D9  [148] key 0x0F01  -> rec 0
	.byte 0x01, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F502DF  [149] key 0x1001  -> rec 0
	.byte 0x02, 0x18, 0xdf, 0x02, 0xf5, 0x00   ; F502E5  [150] key 0x1802  -> rec 149
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F502EB  [151] key 0x10FF  -> rec 0
	.byte 0x00, 0x00, 0xe5, 0x02, 0xf5, 0x00   ; F502F1  [152] key 0x0000  -> rec 150
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F502F7  [153] key 0x0FFF  -> rec 0
	.byte 0x00, 0x00, 0xf1, 0x02, 0xf5, 0x00   ; F502FD  [154] key 0x0000  -> rec 152
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F50303  [155] key 0x0EFF  -> rec 0
	.byte 0x01, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F50309  [156] key 0x1001  -> rec 0
	.byte 0x02, 0x1a, 0x09, 0x03, 0xf5, 0x00   ; F5030F  [157] key 0x1A02  -> rec 156
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F50315  [158] key 0x10FF  -> rec 0
	.byte 0x00, 0x00, 0x0f, 0x03, 0xf5, 0x00   ; F5031B  [159] key 0x0000  -> rec 157
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F50321  [160] key 0x0FFF  -> rec 0
	.byte 0x00, 0x00, 0x1b, 0x03, 0xf5, 0x00   ; F50327  [161] key 0x0000  -> rec 159
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F5032D  [162] key 0x0EFF  -> rec 0
	.byte 0x01, 0x11, 0x61, 0xff, 0xf4, 0x00   ; F50333  [163] key 0x1101  -> rec 0
	.byte 0x01, 0x11, 0x61, 0xff, 0xf4, 0x00   ; F50339  [164] key 0x1101  -> rec 0
	.byte 0x01, 0x12, 0x61, 0xff, 0xf4, 0x00   ; F5033F  [165] key 0x1201  -> rec 0
	.byte 0x01, 0x12, 0x61, 0xff, 0xf4, 0x00   ; F50345  [166] key 0x1201  -> rec 0
	.byte 0x01, 0x13, 0x61, 0xff, 0xf4, 0x00   ; F5034B  [167] key 0x1301  -> rec 0
	.byte 0x01, 0x13, 0x61, 0xff, 0xf4, 0x00   ; F50351  [168] key 0x1301  -> rec 0
	.byte 0x01, 0x14, 0x61, 0xff, 0xf4, 0x00   ; F50357  [169] key 0x1401  -> rec 0
	.byte 0x01, 0x14, 0x61, 0xff, 0xf4, 0x00   ; F5035D  [170] key 0x1401  -> rec 0
	.byte 0x01, 0x15, 0x61, 0xff, 0xf4, 0x00   ; F50363  [171] key 0x1501  -> rec 0
	.byte 0x01, 0x15, 0x61, 0xff, 0xf4, 0x00   ; F50369  [172] key 0x1501  -> rec 0
	.byte 0x01, 0x16, 0x61, 0xff, 0xf4, 0x00   ; F5036F  [173] key 0x1601  -> rec 0
	.byte 0x01, 0x16, 0x61, 0xff, 0xf4, 0x00   ; F50375  [174] key 0x1601  -> rec 0
	.byte 0x00, 0x18, 0x2b, 0x02, 0xf5, 0x00   ; F5037B  [175] key 0x1800  -> rec 119
	.byte 0x01, 0x18, 0x37, 0x02, 0xf5, 0x00   ; F50381  [176] key 0x1801  -> rec 121
	.byte 0x08, 0x18, 0x43, 0x02, 0xf5, 0x00   ; F50387  [177] key 0x1808  -> rec 123
	.byte 0x10, 0x18, 0x4f, 0x02, 0xf5, 0x00   ; F5038D  [178] key 0x1810  -> rec 125
	.byte 0x11, 0x18, 0x5b, 0x02, 0xf5, 0x00   ; F50393  [179] key 0x1811  -> rec 127
	.byte 0x12, 0x18, 0x67, 0x02, 0xf5, 0x00   ; F50399  [180] key 0x1812  -> rec 129
	.byte 0x13, 0x18, 0x73, 0x02, 0xf5, 0x00   ; F5039F  [181] key 0x1813  -> rec 131
	.byte 0x20, 0x18, 0x7f, 0x02, 0xf5, 0x00   ; F503A5  [182] key 0x1820  -> rec 133
	.byte 0x30, 0x18, 0x8b, 0x02, 0xf5, 0x00   ; F503AB  [183] key 0x1830  -> rec 135
	.byte 0x31, 0x18, 0x97, 0x02, 0xf5, 0x00   ; F503B1  [184] key 0x1831  -> rec 137
	.byte 0x32, 0x18, 0xa3, 0x02, 0xf5, 0x00   ; F503B7  [185] key 0x1832  -> rec 139
	.byte 0x33, 0x18, 0xaf, 0x02, 0xf5, 0x00   ; F503BD  [186] key 0x1833  -> rec 141
	.byte 0x34, 0x18, 0xbb, 0x02, 0xf5, 0x00   ; F503C3  [187] key 0x1834  -> rec 143
	.byte 0x35, 0x18, 0xc7, 0x02, 0xf5, 0x00   ; F503C9  [188] key 0x1835  -> rec 145
	.byte 0x36, 0x18, 0xd3, 0x02, 0xf5, 0x00   ; F503CF  [189] key 0x1836  -> rec 147
	.byte 0x40, 0x00, 0xfd, 0x02, 0xf5, 0x00   ; F503D5  [190] key 0x0040  -> rec 154
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F503DB  [191] key 0x0DFF  -> rec 0
	.byte 0x00, 0x18, 0x33, 0x03, 0xf5, 0x00   ; F503E1  [192] key 0x1800  -> rec 163
	.byte 0x01, 0x18, 0x3f, 0x03, 0xf5, 0x00   ; F503E7  [193] key 0x1801  -> rec 165
	.byte 0x02, 0x18, 0x4b, 0x03, 0xf5, 0x00   ; F503ED  [194] key 0x1802  -> rec 167
	.byte 0x03, 0x18, 0x57, 0x03, 0xf5, 0x00   ; F503F3  [195] key 0x1803  -> rec 169
	.byte 0x04, 0x18, 0x63, 0x03, 0xf5, 0x00   ; F503F9  [196] key 0x1804  -> rec 171
	.byte 0x05, 0x18, 0x6f, 0x03, 0xf5, 0x00   ; F503FF  [197] key 0x1805  -> rec 173
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50405  [198] key 0x0DFF  -> rec 0
	.byte 0x00, 0x1a, 0x31, 0x02, 0xf5, 0x00   ; F5040B  [199] key 0x1A00  -> rec 120
	.byte 0x01, 0x1a, 0x3d, 0x02, 0xf5, 0x00   ; F50411  [200] key 0x1A01  -> rec 122
	.byte 0x08, 0x1a, 0x49, 0x02, 0xf5, 0x00   ; F50417  [201] key 0x1A08  -> rec 124
	.byte 0x10, 0x1a, 0x55, 0x02, 0xf5, 0x00   ; F5041D  [202] key 0x1A10  -> rec 126
	.byte 0x11, 0x1a, 0x61, 0x02, 0xf5, 0x00   ; F50423  [203] key 0x1A11  -> rec 128
	.byte 0x12, 0x1a, 0x6d, 0x02, 0xf5, 0x00   ; F50429  [204] key 0x1A12  -> rec 130
	.byte 0x13, 0x1a, 0x79, 0x02, 0xf5, 0x00   ; F5042F  [205] key 0x1A13  -> rec 132
	.byte 0x20, 0x1a, 0x85, 0x02, 0xf5, 0x00   ; F50435  [206] key 0x1A20  -> rec 134
	.byte 0x30, 0x1a, 0x91, 0x02, 0xf5, 0x00   ; F5043B  [207] key 0x1A30  -> rec 136
	.byte 0x31, 0x1a, 0x9d, 0x02, 0xf5, 0x00   ; F50441  [208] key 0x1A31  -> rec 138
	.byte 0x32, 0x1a, 0xa9, 0x02, 0xf5, 0x00   ; F50447  [209] key 0x1A32  -> rec 140
	.byte 0x33, 0x1a, 0xb5, 0x02, 0xf5, 0x00   ; F5044D  [210] key 0x1A33  -> rec 142
	.byte 0x34, 0x1a, 0xc1, 0x02, 0xf5, 0x00   ; F50453  [211] key 0x1A34  -> rec 144
	.byte 0x35, 0x1a, 0xcd, 0x02, 0xf5, 0x00   ; F50459  [212] key 0x1A35  -> rec 146
	.byte 0x36, 0x1a, 0xd9, 0x02, 0xf5, 0x00   ; F5045F  [213] key 0x1A36  -> rec 148
	.byte 0x40, 0x00, 0x27, 0x03, 0xf5, 0x00   ; F50465  [214] key 0x0040  -> rec 161
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F5046B  [215] key 0x0DFF  -> rec 0
	.byte 0x00, 0x1a, 0x39, 0x03, 0xf5, 0x00   ; F50471  [216] key 0x1A00  -> rec 164
	.byte 0x01, 0x1a, 0x45, 0x03, 0xf5, 0x00   ; F50477  [217] key 0x1A01  -> rec 166
	.byte 0x02, 0x1a, 0x51, 0x03, 0xf5, 0x00   ; F5047D  [218] key 0x1A02  -> rec 168
	.byte 0x03, 0x1a, 0x5d, 0x03, 0xf5, 0x00   ; F50483  [219] key 0x1A03  -> rec 170
	.byte 0x04, 0x1a, 0x69, 0x03, 0xf5, 0x00   ; F50489  [220] key 0x1A04  -> rec 172
	.byte 0x05, 0x1a, 0x75, 0x03, 0xf5, 0x00   ; F5048F  [221] key 0x1A05  -> rec 174
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50495  [222] key 0x0DFF  -> rec 0
	.byte 0x02, 0x01, 0x61, 0xff, 0xf4, 0x00   ; F5049B  [223] key 0x0102  -> rec 0
	.byte 0x02, 0x02, 0x61, 0xff, 0xf4, 0x00   ; F504A1  [224] key 0x0202  -> rec 0
	.byte 0x02, 0x03, 0x61, 0xff, 0xf4, 0x00   ; F504A7  [225] key 0x0302  -> rec 0
	.byte 0x02, 0x04, 0x61, 0xff, 0xf4, 0x00   ; F504AD  [226] key 0x0402  -> rec 0
	.byte 0x03, 0x18, 0xad, 0x04, 0xf5, 0x00   ; F504B3  [227] key 0x1803  -> rec 226
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F504B9  [228] key 0x10FF  -> rec 0
	.byte 0x00, 0x00, 0xb3, 0x04, 0xf5, 0x00   ; F504BF  [229] key 0x0000  -> rec 227
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F504C5  [230] key 0x0FFF  -> rec 0
	.byte 0x00, 0x00, 0xbf, 0x04, 0xf5, 0x00   ; F504CB  [231] key 0x0000  -> rec 229
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F504D1  [232] key 0x0EFF  -> rec 0
	.byte 0x00, 0x18, 0x9b, 0x04, 0xf5, 0x00   ; F504D7  [233] key 0x1800  -> rec 223
	.byte 0x08, 0x18, 0xa1, 0x04, 0xf5, 0x00   ; F504DD  [234] key 0x1808  -> rec 224
	.byte 0x10, 0x18, 0xa7, 0x04, 0xf5, 0x00   ; F504E3  [235] key 0x1810  -> rec 225
	.byte 0x11, 0x00, 0xcb, 0x04, 0xf5, 0x00   ; F504E9  [236] key 0x0011  -> rec 231
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F504EF  [237] key 0x0DFF  -> rec 0
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F504F5  [238] key 0x0DFF  -> rec 0
	.byte 0x03, 0x01, 0x61, 0xff, 0xf4, 0x00   ; F504FB  [239] key 0x0103  -> rec 0
	.byte 0x03, 0x01, 0x61, 0xff, 0xf4, 0x00   ; F50501  [240] key 0x0103  -> rec 0
	.byte 0x03, 0x02, 0x61, 0xff, 0xf4, 0x00   ; F50507  [241] key 0x0203  -> rec 0
	.byte 0x03, 0x02, 0x61, 0xff, 0xf4, 0x00   ; F5050D  [242] key 0x0203  -> rec 0
	.byte 0x03, 0x03, 0x61, 0xff, 0xf4, 0x00   ; F50513  [243] key 0x0303  -> rec 0
	.byte 0x03, 0x03, 0x61, 0xff, 0xf4, 0x00   ; F50519  [244] key 0x0303  -> rec 0
	.byte 0x03, 0x04, 0x61, 0xff, 0xf4, 0x00   ; F5051F  [245] key 0x0403  -> rec 0
	.byte 0x03, 0x04, 0x61, 0xff, 0xf4, 0x00   ; F50525  [246] key 0x0403  -> rec 0
	.byte 0x03, 0x05, 0x61, 0xff, 0xf4, 0x00   ; F5052B  [247] key 0x0503  -> rec 0
	.byte 0x03, 0x05, 0x61, 0xff, 0xf4, 0x00   ; F50531  [248] key 0x0503  -> rec 0
	.byte 0x03, 0x06, 0x61, 0xff, 0xf4, 0x00   ; F50537  [249] key 0x0603  -> rec 0
	.byte 0x03, 0x06, 0x61, 0xff, 0xf4, 0x00   ; F5053D  [250] key 0x0603  -> rec 0
	.byte 0x03, 0x07, 0x61, 0xff, 0xf4, 0x00   ; F50543  [251] key 0x0703  -> rec 0
	.byte 0x03, 0x07, 0x61, 0xff, 0xf4, 0x00   ; F50549  [252] key 0x0703  -> rec 0
	.byte 0x03, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F5054F  [253] key 0x0803  -> rec 0
	.byte 0x03, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F50555  [254] key 0x0803  -> rec 0
	.byte 0x03, 0x09, 0x61, 0xff, 0xf4, 0x00   ; F5055B  [255] key 0x0903  -> rec 0
	.byte 0x03, 0x09, 0x61, 0xff, 0xf4, 0x00   ; F50561  [256] key 0x0903  -> rec 0
	.byte 0x03, 0x0a, 0x61, 0xff, 0xf4, 0x00   ; F50567  [257] key 0x0A03  -> rec 0
	.byte 0x03, 0x0a, 0x61, 0xff, 0xf4, 0x00   ; F5056D  [258] key 0x0A03  -> rec 0
	.byte 0x03, 0x0b, 0x61, 0xff, 0xf4, 0x00   ; F50573  [259] key 0x0B03  -> rec 0
	.byte 0x03, 0x0b, 0x61, 0xff, 0xf4, 0x00   ; F50579  [260] key 0x0B03  -> rec 0
	.byte 0x03, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F5057F  [261] key 0x0C03  -> rec 0
	.byte 0x03, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F50585  [262] key 0x0C03  -> rec 0
	.byte 0x03, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F5058B  [263] key 0x0D03  -> rec 0
	.byte 0x03, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50591  [264] key 0x0D03  -> rec 0
	.byte 0x03, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F50597  [265] key 0x0E03  -> rec 0
	.byte 0x03, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F5059D  [266] key 0x0E03  -> rec 0
	.byte 0x03, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F505A3  [267] key 0x0F03  -> rec 0
	.byte 0x03, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F505A9  [268] key 0x0F03  -> rec 0
	.byte 0x03, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F505AF  [269] key 0x1003  -> rec 0
	.byte 0x03, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F505B5  [270] key 0x1003  -> rec 0
	.byte 0x03, 0x11, 0x61, 0xff, 0xf4, 0x00   ; F505BB  [271] key 0x1103  -> rec 0
	.byte 0x03, 0x11, 0x61, 0xff, 0xf4, 0x00   ; F505C1  [272] key 0x1103  -> rec 0
	.byte 0x03, 0x12, 0x61, 0xff, 0xf4, 0x00   ; F505C7  [273] key 0x1203  -> rec 0
	.byte 0x03, 0x12, 0x61, 0xff, 0xf4, 0x00   ; F505CD  [274] key 0x1203  -> rec 0
	.byte 0x03, 0x13, 0x61, 0xff, 0xf4, 0x00   ; F505D3  [275] key 0x1303  -> rec 0
	.byte 0x03, 0x13, 0x61, 0xff, 0xf4, 0x00   ; F505D9  [276] key 0x1303  -> rec 0
	.byte 0x03, 0x14, 0x61, 0xff, 0xf4, 0x00   ; F505DF  [277] key 0x1403  -> rec 0
	.byte 0x03, 0x14, 0x61, 0xff, 0xf4, 0x00   ; F505E5  [278] key 0x1403  -> rec 0
	.byte 0x03, 0x15, 0x61, 0xff, 0xf4, 0x00   ; F505EB  [279] key 0x1503  -> rec 0
	.byte 0x03, 0x15, 0x61, 0xff, 0xf4, 0x00   ; F505F1  [280] key 0x1503  -> rec 0
	.byte 0x03, 0x16, 0x61, 0xff, 0xf4, 0x00   ; F505F7  [281] key 0x1603  -> rec 0
	.byte 0x03, 0x16, 0x61, 0xff, 0xf4, 0x00   ; F505FD  [282] key 0x1603  -> rec 0
	.byte 0x03, 0x17, 0x61, 0xff, 0xf4, 0x00   ; F50603  [283] key 0x1703  -> rec 0
	.byte 0x03, 0x17, 0x61, 0xff, 0xf4, 0x00   ; F50609  [284] key 0x1703  -> rec 0
	.byte 0x03, 0x18, 0x61, 0xff, 0xf4, 0x00   ; F5060F  [285] key 0x1803  -> rec 0
	.byte 0x03, 0x18, 0x61, 0xff, 0xf4, 0x00   ; F50615  [286] key 0x1803  -> rec 0
	.byte 0x00, 0x18, 0xfb, 0x04, 0xf5, 0x00   ; F5061B  [287] key 0x1800  -> rec 239
	.byte 0x10, 0x18, 0x07, 0x05, 0xf5, 0x00   ; F50621  [288] key 0x1810  -> rec 241
	.byte 0x11, 0x18, 0x13, 0x05, 0xf5, 0x00   ; F50627  [289] key 0x1811  -> rec 243
	.byte 0x12, 0x18, 0x1f, 0x05, 0xf5, 0x00   ; F5062D  [290] key 0x1812  -> rec 245
	.byte 0x13, 0x18, 0x2b, 0x05, 0xf5, 0x00   ; F50633  [291] key 0x1813  -> rec 247
	.byte 0x14, 0x18, 0x37, 0x05, 0xf5, 0x00   ; F50639  [292] key 0x1814  -> rec 249
	.byte 0x15, 0x18, 0x43, 0x05, 0xf5, 0x00   ; F5063F  [293] key 0x1815  -> rec 251
	.byte 0x16, 0x18, 0x4f, 0x05, 0xf5, 0x00   ; F50645  [294] key 0x1816  -> rec 253
	.byte 0x17, 0x18, 0x5b, 0x05, 0xf5, 0x00   ; F5064B  [295] key 0x1817  -> rec 255
	.byte 0x18, 0x18, 0x67, 0x05, 0xf5, 0x00   ; F50651  [296] key 0x1818  -> rec 257
	.byte 0x19, 0x18, 0x73, 0x05, 0xf5, 0x00   ; F50657  [297] key 0x1819  -> rec 259
	.byte 0x1a, 0x18, 0x7f, 0x05, 0xf5, 0x00   ; F5065D  [298] key 0x181A  -> rec 261
	.byte 0x1b, 0x18, 0x8b, 0x05, 0xf5, 0x00   ; F50663  [299] key 0x181B  -> rec 263
	.byte 0x1c, 0x18, 0x97, 0x05, 0xf5, 0x00   ; F50669  [300] key 0x181C  -> rec 265
	.byte 0x1d, 0x18, 0xa3, 0x05, 0xf5, 0x00   ; F5066F  [301] key 0x181D  -> rec 267
	.byte 0x1e, 0x18, 0xaf, 0x05, 0xf5, 0x00   ; F50675  [302] key 0x181E  -> rec 269
	.byte 0x20, 0x18, 0xbb, 0x05, 0xf5, 0x00   ; F5067B  [303] key 0x1820  -> rec 271
	.byte 0x21, 0x18, 0xc7, 0x05, 0xf5, 0x00   ; F50681  [304] key 0x1821  -> rec 273
	.byte 0x22, 0x18, 0xd3, 0x05, 0xf5, 0x00   ; F50687  [305] key 0x1822  -> rec 275
	.byte 0x23, 0x18, 0xdf, 0x05, 0xf5, 0x00   ; F5068D  [306] key 0x1823  -> rec 277
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50693  [307] key 0x0DFF  -> rec 0
	.byte 0x00, 0x18, 0xeb, 0x05, 0xf5, 0x00   ; F50699  [308] key 0x1800  -> rec 279
	.byte 0x01, 0x18, 0xf7, 0x05, 0xf5, 0x00   ; F5069F  [309] key 0x1801  -> rec 281
	.byte 0x02, 0x18, 0x03, 0x06, 0xf5, 0x00   ; F506A5  [310] key 0x1802  -> rec 283
	.byte 0xfe, 0x18, 0x0f, 0x06, 0xf5, 0x00   ; F506AB  [311] key 0x18FE  -> rec 285
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F506B1  [312] key 0x0DFF  -> rec 0
	.byte 0x00, 0x1a, 0x01, 0x05, 0xf5, 0x00   ; F506B7  [313] key 0x1A00  -> rec 240
	.byte 0x10, 0x1a, 0x0d, 0x05, 0xf5, 0x00   ; F506BD  [314] key 0x1A10  -> rec 242
	.byte 0x11, 0x1a, 0x19, 0x05, 0xf5, 0x00   ; F506C3  [315] key 0x1A11  -> rec 244
	.byte 0x12, 0x1a, 0x25, 0x05, 0xf5, 0x00   ; F506C9  [316] key 0x1A12  -> rec 246
	.byte 0x13, 0x1a, 0x31, 0x05, 0xf5, 0x00   ; F506CF  [317] key 0x1A13  -> rec 248
	.byte 0x14, 0x1a, 0x3d, 0x05, 0xf5, 0x00   ; F506D5  [318] key 0x1A14  -> rec 250
	.byte 0x15, 0x1a, 0x49, 0x05, 0xf5, 0x00   ; F506DB  [319] key 0x1A15  -> rec 252
	.byte 0x16, 0x1a, 0x55, 0x05, 0xf5, 0x00   ; F506E1  [320] key 0x1A16  -> rec 254
	.byte 0x17, 0x1a, 0x61, 0x05, 0xf5, 0x00   ; F506E7  [321] key 0x1A17  -> rec 256
	.byte 0x18, 0x1a, 0x6d, 0x05, 0xf5, 0x00   ; F506ED  [322] key 0x1A18  -> rec 258
	.byte 0x19, 0x1a, 0x79, 0x05, 0xf5, 0x00   ; F506F3  [323] key 0x1A19  -> rec 260
	.byte 0x1a, 0x1a, 0x85, 0x05, 0xf5, 0x00   ; F506F9  [324] key 0x1A1A  -> rec 262
	.byte 0x1b, 0x1a, 0x91, 0x05, 0xf5, 0x00   ; F506FF  [325] key 0x1A1B  -> rec 264
	.byte 0x1c, 0x1a, 0x9d, 0x05, 0xf5, 0x00   ; F50705  [326] key 0x1A1C  -> rec 266
	.byte 0x1d, 0x1a, 0xa9, 0x05, 0xf5, 0x00   ; F5070B  [327] key 0x1A1D  -> rec 268
	.byte 0x1e, 0x1a, 0xb5, 0x05, 0xf5, 0x00   ; F50711  [328] key 0x1A1E  -> rec 270
	.byte 0x20, 0x1a, 0xc1, 0x05, 0xf5, 0x00   ; F50717  [329] key 0x1A20  -> rec 272
	.byte 0x21, 0x1a, 0xcd, 0x05, 0xf5, 0x00   ; F5071D  [330] key 0x1A21  -> rec 274
	.byte 0x22, 0x1a, 0xd9, 0x05, 0xf5, 0x00   ; F50723  [331] key 0x1A22  -> rec 276
	.byte 0x23, 0x1a, 0xe5, 0x05, 0xf5, 0x00   ; F50729  [332] key 0x1A23  -> rec 278
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F5072F  [333] key 0x0DFF  -> rec 0
	.byte 0x00, 0x1a, 0xf1, 0x05, 0xf5, 0x00   ; F50735  [334] key 0x1A00  -> rec 280
	.byte 0x01, 0x1a, 0xfd, 0x05, 0xf5, 0x00   ; F5073B  [335] key 0x1A01  -> rec 282
	.byte 0x02, 0x1a, 0x09, 0x06, 0xf5, 0x00   ; F50741  [336] key 0x1A02  -> rec 284
	.byte 0xfe, 0x1a, 0x15, 0x06, 0xf5, 0x00   ; F50747  [337] key 0x1AFE  -> rec 286
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F5074D  [338] key 0x0DFF  -> rec 0
	.byte 0x05, 0x01, 0x61, 0xff, 0xf4, 0x00   ; F50753  [339] key 0x0105  -> rec 0
	.byte 0x03, 0x18, 0x53, 0x07, 0xf5, 0x00   ; F50759  [340] key 0x1803  -> rec 339
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F5075F  [341] key 0x10FF  -> rec 0
	.byte 0x00, 0x00, 0x59, 0x07, 0xf5, 0x00   ; F50765  [342] key 0x0000  -> rec 340
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F5076B  [343] key 0x0FFF  -> rec 0
	.byte 0x00, 0x00, 0x65, 0x07, 0xf5, 0x00   ; F50771  [344] key 0x0000  -> rec 342
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F50777  [345] key 0x0EFF  -> rec 0
	.byte 0x05, 0x01, 0x61, 0xff, 0xf4, 0x00   ; F5077D  [346] key 0x0105  -> rec 0
	.byte 0x03, 0x1a, 0x7d, 0x07, 0xf5, 0x00   ; F50783  [347] key 0x1A03  -> rec 346
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F50789  [348] key 0x10FF  -> rec 0
	.byte 0x00, 0x00, 0x83, 0x07, 0xf5, 0x00   ; F5078F  [349] key 0x0000  -> rec 347
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F50795  [350] key 0x0FFF  -> rec 0
	.byte 0x00, 0x00, 0x8f, 0x07, 0xf5, 0x00   ; F5079B  [351] key 0x0000  -> rec 349
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F507A1  [352] key 0x0EFF  -> rec 0
	.byte 0x05, 0x02, 0x61, 0xff, 0xf4, 0x00   ; F507A7  [353] key 0x0205  -> rec 0
	.byte 0x05, 0x02, 0x61, 0xff, 0xf4, 0x00   ; F507AD  [354] key 0x0205  -> rec 0
	.byte 0x05, 0x03, 0x61, 0xff, 0xf4, 0x00   ; F507B3  [355] key 0x0305  -> rec 0
	.byte 0x05, 0x03, 0x61, 0xff, 0xf4, 0x00   ; F507B9  [356] key 0x0305  -> rec 0
	.byte 0x05, 0x04, 0x61, 0xff, 0xf4, 0x00   ; F507BF  [357] key 0x0405  -> rec 0
	.byte 0x05, 0x04, 0x61, 0xff, 0xf4, 0x00   ; F507C5  [358] key 0x0405  -> rec 0
	.byte 0x05, 0x05, 0x61, 0xff, 0xf4, 0x00   ; F507CB  [359] key 0x0505  -> rec 0
	.byte 0x05, 0x05, 0x61, 0xff, 0xf4, 0x00   ; F507D1  [360] key 0x0505  -> rec 0
	.byte 0x05, 0x06, 0x61, 0xff, 0xf4, 0x00   ; F507D7  [361] key 0x0605  -> rec 0
	.byte 0x05, 0x06, 0x61, 0xff, 0xf4, 0x00   ; F507DD  [362] key 0x0605  -> rec 0
	.byte 0x05, 0x07, 0x61, 0xff, 0xf4, 0x00   ; F507E3  [363] key 0x0705  -> rec 0
	.byte 0x05, 0x07, 0x61, 0xff, 0xf4, 0x00   ; F507E9  [364] key 0x0705  -> rec 0
	.byte 0x05, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F507EF  [365] key 0x0805  -> rec 0
	.byte 0x05, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F507F5  [366] key 0x0805  -> rec 0
	.byte 0x05, 0x09, 0x61, 0xff, 0xf4, 0x00   ; F507FB  [367] key 0x0905  -> rec 0
	.byte 0x05, 0x09, 0x61, 0xff, 0xf4, 0x00   ; F50801  [368] key 0x0905  -> rec 0
	.byte 0x05, 0x0a, 0x61, 0xff, 0xf4, 0x00   ; F50807  [369] key 0x0A05  -> rec 0
	.byte 0x05, 0x0a, 0x61, 0xff, 0xf4, 0x00   ; F5080D  [370] key 0x0A05  -> rec 0
	.byte 0x05, 0x0b, 0x61, 0xff, 0xf4, 0x00   ; F50813  [371] key 0x0B05  -> rec 0
	.byte 0x05, 0x0b, 0x61, 0xff, 0xf4, 0x00   ; F50819  [372] key 0x0B05  -> rec 0
	.byte 0x05, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F5081F  [373] key 0x0C05  -> rec 0
	.byte 0x05, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F50825  [374] key 0x0C05  -> rec 0
	.byte 0x05, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F5082B  [375] key 0x0D05  -> rec 0
	.byte 0x05, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50831  [376] key 0x0D05  -> rec 0
	.byte 0x05, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F50837  [377] key 0x0E05  -> rec 0
	.byte 0x05, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F5083D  [378] key 0x0E05  -> rec 0
	.byte 0x05, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F50843  [379] key 0x0F05  -> rec 0
	.byte 0x05, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F50849  [380] key 0x0F05  -> rec 0
	.byte 0x05, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F5084F  [381] key 0x1005  -> rec 0
	.byte 0x05, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F50855  [382] key 0x1005  -> rec 0
	.byte 0x05, 0x11, 0x61, 0xff, 0xf4, 0x00   ; F5085B  [383] key 0x1105  -> rec 0
	.byte 0x05, 0x11, 0x61, 0xff, 0xf4, 0x00   ; F50861  [384] key 0x1105  -> rec 0
	.byte 0x05, 0x12, 0x61, 0xff, 0xf4, 0x00   ; F50867  [385] key 0x1205  -> rec 0
	.byte 0x05, 0x12, 0x61, 0xff, 0xf4, 0x00   ; F5086D  [386] key 0x1205  -> rec 0
	.byte 0x06, 0x01, 0x61, 0xff, 0xf4, 0x00   ; F50873  [387] key 0x0106  -> rec 0
	.byte 0x06, 0x01, 0x61, 0xff, 0xf4, 0x00   ; F50879  [388] key 0x0106  -> rec 0
	.byte 0x06, 0x02, 0x61, 0xff, 0xf4, 0x00   ; F5087F  [389] key 0x0206  -> rec 0
	.byte 0x06, 0x02, 0x61, 0xff, 0xf4, 0x00   ; F50885  [390] key 0x0206  -> rec 0
	.byte 0x06, 0x03, 0x61, 0xff, 0xf4, 0x00   ; F5088B  [391] key 0x0306  -> rec 0
	.byte 0x06, 0x03, 0x61, 0xff, 0xf4, 0x00   ; F50891  [392] key 0x0306  -> rec 0
	.byte 0x06, 0x04, 0x61, 0xff, 0xf4, 0x00   ; F50897  [393] key 0x0406  -> rec 0
	.byte 0x06, 0x04, 0x61, 0xff, 0xf4, 0x00   ; F5089D  [394] key 0x0406  -> rec 0
	.byte 0x06, 0x05, 0x61, 0xff, 0xf4, 0x00   ; F508A3  [395] key 0x0506  -> rec 0
	.byte 0x06, 0x05, 0x61, 0xff, 0xf4, 0x00   ; F508A9  [396] key 0x0506  -> rec 0
	.byte 0x06, 0x06, 0x61, 0xff, 0xf4, 0x00   ; F508AF  [397] key 0x0606  -> rec 0
	.byte 0x06, 0x06, 0x61, 0xff, 0xf4, 0x00   ; F508B5  [398] key 0x0606  -> rec 0
	.byte 0x06, 0x07, 0x61, 0xff, 0xf4, 0x00   ; F508BB  [399] key 0x0706  -> rec 0
	.byte 0x06, 0x07, 0x61, 0xff, 0xf4, 0x00   ; F508C1  [400] key 0x0706  -> rec 0
	.byte 0x06, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F508C7  [401] key 0x0806  -> rec 0
	.byte 0x06, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F508CD  [402] key 0x0806  -> rec 0
	.byte 0x06, 0x09, 0x61, 0xff, 0xf4, 0x00   ; F508D3  [403] key 0x0906  -> rec 0
	.byte 0x06, 0x09, 0x61, 0xff, 0xf4, 0x00   ; F508D9  [404] key 0x0906  -> rec 0
	.byte 0x06, 0x0a, 0x61, 0xff, 0xf4, 0x00   ; F508DF  [405] key 0x0A06  -> rec 0
	.byte 0x06, 0x0a, 0x61, 0xff, 0xf4, 0x00   ; F508E5  [406] key 0x0A06  -> rec 0
	.byte 0x06, 0x0b, 0x61, 0xff, 0xf4, 0x00   ; F508EB  [407] key 0x0B06  -> rec 0
	.byte 0x06, 0x0b, 0x61, 0xff, 0xf4, 0x00   ; F508F1  [408] key 0x0B06  -> rec 0
	.byte 0x06, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F508F7  [409] key 0x0C06  -> rec 0
	.byte 0x06, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F508FD  [410] key 0x0C06  -> rec 0
	.byte 0x06, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50903  [411] key 0x0D06  -> rec 0
	.byte 0x06, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50909  [412] key 0x0D06  -> rec 0
	.byte 0x06, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F5090F  [413] key 0x0E06  -> rec 0
	.byte 0x06, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F50915  [414] key 0x0E06  -> rec 0
	.byte 0x06, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F5091B  [415] key 0x0F06  -> rec 0
	.byte 0x06, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F50921  [416] key 0x0F06  -> rec 0
	.byte 0x06, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F50927  [417] key 0x1006  -> rec 0
	.byte 0x06, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F5092D  [418] key 0x1006  -> rec 0
	.byte 0x06, 0x11, 0x61, 0xff, 0xf4, 0x00   ; F50933  [419] key 0x1106  -> rec 0
	.byte 0x06, 0x11, 0x61, 0xff, 0xf4, 0x00   ; F50939  [420] key 0x1106  -> rec 0
	.byte 0x06, 0x12, 0x61, 0xff, 0xf4, 0x00   ; F5093F  [421] key 0x1206  -> rec 0
	.byte 0x06, 0x12, 0x61, 0xff, 0xf4, 0x00   ; F50945  [422] key 0x1206  -> rec 0
	.byte 0x06, 0x13, 0x61, 0xff, 0xf4, 0x00   ; F5094B  [423] key 0x1306  -> rec 0
	.byte 0x06, 0x13, 0x61, 0xff, 0xf4, 0x00   ; F50951  [424] key 0x1306  -> rec 0
	.byte 0x06, 0x14, 0x61, 0xff, 0xf4, 0x00   ; F50957  [425] key 0x1406  -> rec 0
	.byte 0x06, 0x14, 0x61, 0xff, 0xf4, 0x00   ; F5095D  [426] key 0x1406  -> rec 0
	.byte 0x06, 0x15, 0x61, 0xff, 0xf4, 0x00   ; F50963  [427] key 0x1506  -> rec 0
	.byte 0x06, 0x15, 0x61, 0xff, 0xf4, 0x00   ; F50969  [428] key 0x1506  -> rec 0
	.byte 0x06, 0x16, 0x61, 0xff, 0xf4, 0x00   ; F5096F  [429] key 0x1606  -> rec 0
	.byte 0x06, 0x16, 0x61, 0xff, 0xf4, 0x00   ; F50975  [430] key 0x1606  -> rec 0
	.byte 0x06, 0x17, 0x61, 0xff, 0xf4, 0x00   ; F5097B  [431] key 0x1706  -> rec 0
	.byte 0x06, 0x17, 0x61, 0xff, 0xf4, 0x00   ; F50981  [432] key 0x1706  -> rec 0
	.byte 0x06, 0x18, 0x61, 0xff, 0xf4, 0x00   ; F50987  [433] key 0x1806  -> rec 0
	.byte 0x02, 0x18, 0x87, 0x09, 0xf5, 0x00   ; F5098D  [434] key 0x1802  -> rec 433
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F50993  [435] key 0x10FF  -> rec 0
	.byte 0x00, 0x00, 0x8d, 0x09, 0xf5, 0x00   ; F50999  [436] key 0x0000  -> rec 434
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F5099F  [437] key 0x0FFF  -> rec 0
	.byte 0x00, 0x00, 0x99, 0x09, 0xf5, 0x00   ; F509A5  [438] key 0x0000  -> rec 436
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F509AB  [439] key 0x0EFF  -> rec 0
	.byte 0x06, 0x18, 0x61, 0xff, 0xf4, 0x00   ; F509B1  [440] key 0x1806  -> rec 0
	.byte 0x02, 0x1a, 0xb1, 0x09, 0xf5, 0x00   ; F509B7  [441] key 0x1A02  -> rec 440
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F509BD  [442] key 0x10FF  -> rec 0
	.byte 0x00, 0x00, 0xb7, 0x09, 0xf5, 0x00   ; F509C3  [443] key 0x0000  -> rec 441
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F509C9  [444] key 0x0FFF  -> rec 0
	.byte 0x00, 0x00, 0xc3, 0x09, 0xf5, 0x00   ; F509CF  [445] key 0x0000  -> rec 443
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F509D5  [446] key 0x0EFF  -> rec 0
	.byte 0x06, 0x19, 0x61, 0xff, 0xf4, 0x00   ; F509DB  [447] key 0x1906  -> rec 0
	.byte 0x06, 0x19, 0x61, 0xff, 0xf4, 0x00   ; F509E1  [448] key 0x1906  -> rec 0
	.byte 0x06, 0x1a, 0x61, 0xff, 0xf4, 0x00   ; F509E7  [449] key 0x1A06  -> rec 0
	.byte 0x06, 0x1a, 0x61, 0xff, 0xf4, 0x00   ; F509ED  [450] key 0x1A06  -> rec 0
	.byte 0x06, 0x1b, 0x61, 0xff, 0xf4, 0x00   ; F509F3  [451] key 0x1B06  -> rec 0
	.byte 0x06, 0x1b, 0x61, 0xff, 0xf4, 0x00   ; F509F9  [452] key 0x1B06  -> rec 0
	.byte 0x06, 0x1c, 0x61, 0xff, 0xf4, 0x00   ; F509FF  [453] key 0x1C06  -> rec 0
	.byte 0x06, 0x1c, 0x61, 0xff, 0xf4, 0x00   ; F50A05  [454] key 0x1C06  -> rec 0
	.byte 0x06, 0x1d, 0x61, 0xff, 0xf4, 0x00   ; F50A0B  [455] key 0x1D06  -> rec 0
	.byte 0x06, 0x1d, 0x61, 0xff, 0xf4, 0x00   ; F50A11  [456] key 0x1D06  -> rec 0
	.byte 0x06, 0x1e, 0x61, 0xff, 0xf4, 0x00   ; F50A17  [457] key 0x1E06  -> rec 0
	.byte 0x06, 0x1e, 0x61, 0xff, 0xf4, 0x00   ; F50A1D  [458] key 0x1E06  -> rec 0
	.byte 0x06, 0x1f, 0x61, 0xff, 0xf4, 0x00   ; F50A23  [459] key 0x1F06  -> rec 0
	.byte 0x06, 0x1f, 0x61, 0xff, 0xf4, 0x00   ; F50A29  [460] key 0x1F06  -> rec 0
	.byte 0x06, 0x20, 0x61, 0xff, 0xf4, 0x00   ; F50A2F  [461] key 0x2006  -> rec 0
	.byte 0x06, 0x20, 0x61, 0xff, 0xf4, 0x00   ; F50A35  [462] key 0x2006  -> rec 0
	.byte 0x06, 0x21, 0x61, 0xff, 0xf4, 0x00   ; F50A3B  [463] key 0x2106  -> rec 0
	.byte 0x06, 0x21, 0x61, 0xff, 0xf4, 0x00   ; F50A41  [464] key 0x2106  -> rec 0
	.byte 0x06, 0x22, 0x61, 0xff, 0xf4, 0x00   ; F50A47  [465] key 0x2206  -> rec 0
	.byte 0x06, 0x22, 0x61, 0xff, 0xf4, 0x00   ; F50A4D  [466] key 0x2206  -> rec 0
	.byte 0x06, 0x23, 0x61, 0xff, 0xf4, 0x00   ; F50A53  [467] key 0x2306  -> rec 0
	.byte 0x06, 0x23, 0x61, 0xff, 0xf4, 0x00   ; F50A59  [468] key 0x2306  -> rec 0
	.byte 0x06, 0x24, 0x61, 0xff, 0xf4, 0x00   ; F50A5F  [469] key 0x2406  -> rec 0
	.byte 0x06, 0x24, 0x61, 0xff, 0xf4, 0x00   ; F50A65  [470] key 0x2406  -> rec 0
	.byte 0x06, 0x25, 0x61, 0xff, 0xf4, 0x00   ; F50A6B  [471] key 0x2506  -> rec 0
	.byte 0x06, 0x25, 0x61, 0xff, 0xf4, 0x00   ; F50A71  [472] key 0x2506  -> rec 0
	.byte 0x06, 0x26, 0x61, 0xff, 0xf4, 0x00   ; F50A77  [473] key 0x2606  -> rec 0
	.byte 0x06, 0x26, 0x61, 0xff, 0xf4, 0x00   ; F50A7D  [474] key 0x2606  -> rec 0
	.byte 0x06, 0x27, 0x61, 0xff, 0xf4, 0x00   ; F50A83  [475] key 0x2706  -> rec 0
	.byte 0x06, 0x27, 0x61, 0xff, 0xf4, 0x00   ; F50A89  [476] key 0x2706  -> rec 0
	.byte 0x00, 0x00, 0x71, 0x07, 0xf5, 0x00   ; F50A8F  [477] key 0x0000  -> rec 344
	.byte 0x03, 0x18, 0xa7, 0x07, 0xf5, 0x00   ; F50A95  [478] key 0x1803  -> rec 353
	.byte 0x04, 0x18, 0xb3, 0x07, 0xf5, 0x00   ; F50A9B  [479] key 0x1804  -> rec 355
	.byte 0x05, 0x18, 0xbf, 0x07, 0xf5, 0x00   ; F50AA1  [480] key 0x1805  -> rec 357
	.byte 0x06, 0x18, 0xcb, 0x07, 0xf5, 0x00   ; F50AA7  [481] key 0x1806  -> rec 359
	.byte 0x07, 0x18, 0xd7, 0x07, 0xf5, 0x00   ; F50AAD  [482] key 0x1807  -> rec 361
	.byte 0x08, 0x18, 0xe3, 0x07, 0xf5, 0x00   ; F50AB3  [483] key 0x1808  -> rec 363
	.byte 0x09, 0x18, 0xef, 0x07, 0xf5, 0x00   ; F50AB9  [484] key 0x1809  -> rec 365
	.byte 0x0a, 0x18, 0xfb, 0x07, 0xf5, 0x00   ; F50ABF  [485] key 0x180A  -> rec 367
	.byte 0x10, 0x18, 0x07, 0x08, 0xf5, 0x00   ; F50AC5  [486] key 0x1810  -> rec 369
	.byte 0x14, 0x18, 0x13, 0x08, 0xf5, 0x00   ; F50ACB  [487] key 0x1814  -> rec 371
	.byte 0x20, 0x18, 0x1f, 0x08, 0xf5, 0x00   ; F50AD1  [488] key 0x1820  -> rec 373
	.byte 0x28, 0x18, 0x2b, 0x08, 0xf5, 0x00   ; F50AD7  [489] key 0x1828  -> rec 375
	.byte 0x29, 0x18, 0x37, 0x08, 0xf5, 0x00   ; F50ADD  [490] key 0x1829  -> rec 377
	.byte 0x2a, 0x18, 0x43, 0x08, 0xf5, 0x00   ; F50AE3  [491] key 0x182A  -> rec 379
	.byte 0x2b, 0x18, 0x4f, 0x08, 0xf5, 0x00   ; F50AE9  [492] key 0x182B  -> rec 381
	.byte 0x30, 0x18, 0x5b, 0x08, 0xf5, 0x00   ; F50AEF  [493] key 0x1830  -> rec 383
	.byte 0x31, 0x18, 0x67, 0x08, 0xf5, 0x00   ; F50AF5  [494] key 0x1831  -> rec 385
	.byte 0x40, 0x18, 0x73, 0x08, 0xf5, 0x00   ; F50AFB  [495] key 0x1840  -> rec 387
	.byte 0x41, 0x18, 0x7f, 0x08, 0xf5, 0x00   ; F50B01  [496] key 0x1841  -> rec 389
	.byte 0x42, 0x18, 0x8b, 0x08, 0xf5, 0x00   ; F50B07  [497] key 0x1842  -> rec 391
	.byte 0x43, 0x18, 0x97, 0x08, 0xf5, 0x00   ; F50B0D  [498] key 0x1843  -> rec 393
	.byte 0x48, 0x18, 0xa3, 0x08, 0xf5, 0x00   ; F50B13  [499] key 0x1848  -> rec 395
	.byte 0x49, 0x18, 0xaf, 0x08, 0xf5, 0x00   ; F50B19  [500] key 0x1849  -> rec 397
	.byte 0x4a, 0x18, 0xbb, 0x08, 0xf5, 0x00   ; F50B1F  [501] key 0x184A  -> rec 399
	.byte 0x50, 0x18, 0xc7, 0x08, 0xf5, 0x00   ; F50B25  [502] key 0x1850  -> rec 401
	.byte 0x51, 0x18, 0xd3, 0x08, 0xf5, 0x00   ; F50B2B  [503] key 0x1851  -> rec 403
	.byte 0x52, 0x18, 0xdf, 0x08, 0xf5, 0x00   ; F50B31  [504] key 0x1852  -> rec 405
	.byte 0x53, 0x18, 0xeb, 0x08, 0xf5, 0x00   ; F50B37  [505] key 0x1853  -> rec 407
	.byte 0x54, 0x18, 0xf7, 0x08, 0xf5, 0x00   ; F50B3D  [506] key 0x1854  -> rec 409
	.byte 0x55, 0x18, 0x03, 0x09, 0xf5, 0x00   ; F50B43  [507] key 0x1855  -> rec 411
	.byte 0x56, 0x18, 0x0f, 0x09, 0xf5, 0x00   ; F50B49  [508] key 0x1856  -> rec 413
	.byte 0x57, 0x18, 0x1b, 0x09, 0xf5, 0x00   ; F50B4F  [509] key 0x1857  -> rec 415
	.byte 0x58, 0x18, 0x27, 0x09, 0xf5, 0x00   ; F50B55  [510] key 0x1858  -> rec 417
	.byte 0x59, 0x18, 0x33, 0x09, 0xf5, 0x00   ; F50B5B  [511] key 0x1859  -> rec 419
	.byte 0x5a, 0x18, 0x3f, 0x09, 0xf5, 0x00   ; F50B61  [512] key 0x185A  -> rec 421
	.byte 0x5b, 0x18, 0x4b, 0x09, 0xf5, 0x00   ; F50B67  [513] key 0x185B  -> rec 423
	.byte 0x5c, 0x18, 0x57, 0x09, 0xf5, 0x00   ; F50B6D  [514] key 0x185C  -> rec 425
	.byte 0x5d, 0x18, 0x63, 0x09, 0xf5, 0x00   ; F50B73  [515] key 0x185D  -> rec 427
	.byte 0x5e, 0x18, 0x6f, 0x09, 0xf5, 0x00   ; F50B79  [516] key 0x185E  -> rec 429
	.byte 0x60, 0x18, 0x7b, 0x09, 0xf5, 0x00   ; F50B7F  [517] key 0x1860  -> rec 431
	.byte 0x61, 0x00, 0xa5, 0x09, 0xf5, 0x00   ; F50B85  [518] key 0x0061  -> rec 438
	.byte 0x63, 0x18, 0xdb, 0x09, 0xf5, 0x00   ; F50B8B  [519] key 0x1863  -> rec 447
	.byte 0x64, 0x18, 0xe7, 0x09, 0xf5, 0x00   ; F50B91  [520] key 0x1864  -> rec 449
	.byte 0x65, 0x18, 0xf3, 0x09, 0xf5, 0x00   ; F50B97  [521] key 0x1865  -> rec 451
	.byte 0x66, 0x18, 0xff, 0x09, 0xf5, 0x00   ; F50B9D  [522] key 0x1866  -> rec 453
	.byte 0x68, 0x18, 0x0b, 0x0a, 0xf5, 0x00   ; F50BA3  [523] key 0x1868  -> rec 455
	.byte 0x70, 0x18, 0x17, 0x0a, 0xf5, 0x00   ; F50BA9  [524] key 0x1870  -> rec 457
	.byte 0x71, 0x18, 0x23, 0x0a, 0xf5, 0x00   ; F50BAF  [525] key 0x1871  -> rec 459
	.byte 0x72, 0x18, 0x2f, 0x0a, 0xf5, 0x00   ; F50BB5  [526] key 0x1872  -> rec 461
	.byte 0x73, 0x18, 0x3b, 0x0a, 0xf5, 0x00   ; F50BBB  [527] key 0x1873  -> rec 463
	.byte 0x74, 0x18, 0x47, 0x0a, 0xf5, 0x00   ; F50BC1  [528] key 0x1874  -> rec 465
	.byte 0x75, 0x18, 0x53, 0x0a, 0xf5, 0x00   ; F50BC7  [529] key 0x1875  -> rec 467
	.byte 0x76, 0x18, 0x5f, 0x0a, 0xf5, 0x00   ; F50BCD  [530] key 0x1876  -> rec 469
	.byte 0x77, 0x18, 0x6b, 0x0a, 0xf5, 0x00   ; F50BD3  [531] key 0x1877  -> rec 471
	.byte 0x78, 0x18, 0x77, 0x0a, 0xf5, 0x00   ; F50BD9  [532] key 0x1878  -> rec 473
	.byte 0x79, 0x18, 0x83, 0x0a, 0xf5, 0x00   ; F50BDF  [533] key 0x1879  -> rec 475
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50BE5  [534] key 0x0DFF  -> rec 0
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F50BEB  [535] key 0x0000  
	.byte 0x00, 0x00, 0x9b, 0x07, 0xf5, 0x00   ; F50BF1  [536] key 0x0000  -> rec 351
	.byte 0x03, 0x1a, 0xad, 0x07, 0xf5, 0x00   ; F50BF7  [537] key 0x1A03  -> rec 354
	.byte 0x04, 0x1a, 0xb9, 0x07, 0xf5, 0x00   ; F50BFD  [538] key 0x1A04  -> rec 356
	.byte 0x05, 0x1a, 0xc5, 0x07, 0xf5, 0x00   ; F50C03  [539] key 0x1A05  -> rec 358
	.byte 0x06, 0x1a, 0xd1, 0x07, 0xf5, 0x00   ; F50C09  [540] key 0x1A06  -> rec 360
	.byte 0x07, 0x1a, 0xdd, 0x07, 0xf5, 0x00   ; F50C0F  [541] key 0x1A07  -> rec 362
	.byte 0x08, 0x1a, 0xe9, 0x07, 0xf5, 0x00   ; F50C15  [542] key 0x1A08  -> rec 364
	.byte 0x09, 0x1a, 0xf5, 0x07, 0xf5, 0x00   ; F50C1B  [543] key 0x1A09  -> rec 366
	.byte 0x0a, 0x1a, 0x01, 0x08, 0xf5, 0x00   ; F50C21  [544] key 0x1A0A  -> rec 368
	.byte 0x10, 0x1a, 0x0d, 0x08, 0xf5, 0x00   ; F50C27  [545] key 0x1A10  -> rec 370
	.byte 0x14, 0x1a, 0x19, 0x08, 0xf5, 0x00   ; F50C2D  [546] key 0x1A14  -> rec 372
	.byte 0x20, 0x1a, 0x25, 0x08, 0xf5, 0x00   ; F50C33  [547] key 0x1A20  -> rec 374
	.byte 0x28, 0x1a, 0x31, 0x08, 0xf5, 0x00   ; F50C39  [548] key 0x1A28  -> rec 376
	.byte 0x29, 0x1a, 0x3d, 0x08, 0xf5, 0x00   ; F50C3F  [549] key 0x1A29  -> rec 378
	.byte 0x2a, 0x1a, 0x49, 0x08, 0xf5, 0x00   ; F50C45  [550] key 0x1A2A  -> rec 380
	.byte 0x2b, 0x1a, 0x55, 0x08, 0xf5, 0x00   ; F50C4B  [551] key 0x1A2B  -> rec 382
	.byte 0x30, 0x1a, 0x61, 0x08, 0xf5, 0x00   ; F50C51  [552] key 0x1A30  -> rec 384
	.byte 0x31, 0x1a, 0x6d, 0x08, 0xf5, 0x00   ; F50C57  [553] key 0x1A31  -> rec 386
	.byte 0x40, 0x1a, 0x79, 0x08, 0xf5, 0x00   ; F50C5D  [554] key 0x1A40  -> rec 388
	.byte 0x41, 0x1a, 0x85, 0x08, 0xf5, 0x00   ; F50C63  [555] key 0x1A41  -> rec 390
	.byte 0x42, 0x1a, 0x91, 0x08, 0xf5, 0x00   ; F50C69  [556] key 0x1A42  -> rec 392
	.byte 0x43, 0x1a, 0x9d, 0x08, 0xf5, 0x00   ; F50C6F  [557] key 0x1A43  -> rec 394
	.byte 0x48, 0x1a, 0xa9, 0x08, 0xf5, 0x00   ; F50C75  [558] key 0x1A48  -> rec 396
	.byte 0x49, 0x1a, 0xb5, 0x08, 0xf5, 0x00   ; F50C7B  [559] key 0x1A49  -> rec 398
	.byte 0x4a, 0x1a, 0xc1, 0x08, 0xf5, 0x00   ; F50C81  [560] key 0x1A4A  -> rec 400
	.byte 0x50, 0x1a, 0xcd, 0x08, 0xf5, 0x00   ; F50C87  [561] key 0x1A50  -> rec 402
	.byte 0x51, 0x1a, 0xd9, 0x08, 0xf5, 0x00   ; F50C8D  [562] key 0x1A51  -> rec 404
	.byte 0x52, 0x1a, 0xe5, 0x08, 0xf5, 0x00   ; F50C93  [563] key 0x1A52  -> rec 406
	.byte 0x53, 0x1a, 0xf1, 0x08, 0xf5, 0x00   ; F50C99  [564] key 0x1A53  -> rec 408
	.byte 0x54, 0x1a, 0xfd, 0x08, 0xf5, 0x00   ; F50C9F  [565] key 0x1A54  -> rec 410
	.byte 0x55, 0x1a, 0x09, 0x09, 0xf5, 0x00   ; F50CA5  [566] key 0x1A55  -> rec 412
	.byte 0x56, 0x1a, 0x15, 0x09, 0xf5, 0x00   ; F50CAB  [567] key 0x1A56  -> rec 414
	.byte 0x57, 0x1a, 0x21, 0x09, 0xf5, 0x00   ; F50CB1  [568] key 0x1A57  -> rec 416
	.byte 0x58, 0x1a, 0x2d, 0x09, 0xf5, 0x00   ; F50CB7  [569] key 0x1A58  -> rec 418
	.byte 0x59, 0x1a, 0x39, 0x09, 0xf5, 0x00   ; F50CBD  [570] key 0x1A59  -> rec 420
	.byte 0x5a, 0x1a, 0x45, 0x09, 0xf5, 0x00   ; F50CC3  [571] key 0x1A5A  -> rec 422
	.byte 0x5b, 0x1a, 0x51, 0x09, 0xf5, 0x00   ; F50CC9  [572] key 0x1A5B  -> rec 424
	.byte 0x5c, 0x1a, 0x5d, 0x09, 0xf5, 0x00   ; F50CCF  [573] key 0x1A5C  -> rec 426
	.byte 0x5d, 0x1a, 0x69, 0x09, 0xf5, 0x00   ; F50CD5  [574] key 0x1A5D  -> rec 428
	.byte 0x5e, 0x1a, 0x75, 0x09, 0xf5, 0x00   ; F50CDB  [575] key 0x1A5E  -> rec 430
	.byte 0x60, 0x1a, 0x81, 0x09, 0xf5, 0x00   ; F50CE1  [576] key 0x1A60  -> rec 432
	.byte 0x61, 0x00, 0xcf, 0x09, 0xf5, 0x00   ; F50CE7  [577] key 0x0061  -> rec 445
	.byte 0x63, 0x1a, 0xe1, 0x09, 0xf5, 0x00   ; F50CED  [578] key 0x1A63  -> rec 448
	.byte 0x64, 0x1a, 0xed, 0x09, 0xf5, 0x00   ; F50CF3  [579] key 0x1A64  -> rec 450
	.byte 0x65, 0x1a, 0xf9, 0x09, 0xf5, 0x00   ; F50CF9  [580] key 0x1A65  -> rec 452
	.byte 0x66, 0x1a, 0x05, 0x0a, 0xf5, 0x00   ; F50CFF  [581] key 0x1A66  -> rec 454
	.byte 0x68, 0x1a, 0x11, 0x0a, 0xf5, 0x00   ; F50D05  [582] key 0x1A68  -> rec 456
	.byte 0x70, 0x1a, 0x1d, 0x0a, 0xf5, 0x00   ; F50D0B  [583] key 0x1A70  -> rec 458
	.byte 0x71, 0x1a, 0x29, 0x0a, 0xf5, 0x00   ; F50D11  [584] key 0x1A71  -> rec 460
	.byte 0x72, 0x1a, 0x35, 0x0a, 0xf5, 0x00   ; F50D17  [585] key 0x1A72  -> rec 462
	.byte 0x73, 0x1a, 0x41, 0x0a, 0xf5, 0x00   ; F50D1D  [586] key 0x1A73  -> rec 464
	.byte 0x74, 0x1a, 0x4d, 0x0a, 0xf5, 0x00   ; F50D23  [587] key 0x1A74  -> rec 466
	.byte 0x75, 0x1a, 0x59, 0x0a, 0xf5, 0x00   ; F50D29  [588] key 0x1A75  -> rec 468
	.byte 0x76, 0x1a, 0x65, 0x0a, 0xf5, 0x00   ; F50D2F  [589] key 0x1A76  -> rec 470
	.byte 0x77, 0x1a, 0x71, 0x0a, 0xf5, 0x00   ; F50D35  [590] key 0x1A77  -> rec 472
	.byte 0x78, 0x1a, 0x7d, 0x0a, 0xf5, 0x00   ; F50D3B  [591] key 0x1A78  -> rec 474
	.byte 0x79, 0x1a, 0x89, 0x0a, 0xf5, 0x00   ; F50D41  [592] key 0x1A79  -> rec 476
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50D47  [593] key 0x0DFF  -> rec 0
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F50D4D  [594] key 0x0000  
	.byte 0x07, 0x01, 0x61, 0xff, 0xf4, 0x00   ; F50D53  [595] key 0x0107  -> rec 0
	.byte 0x07, 0x01, 0x61, 0xff, 0xf4, 0x00   ; F50D59  [596] key 0x0107  -> rec 0
	.byte 0x00, 0x18, 0x53, 0x0d, 0xf5, 0x00   ; F50D5F  [597] key 0x1800  -> rec 595
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50D65  [598] key 0x0DFF  -> rec 0
	.byte 0x00, 0x1a, 0x59, 0x0d, 0xf5, 0x00   ; F50D6B  [599] key 0x1A00  -> rec 596
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50D71  [600] key 0x0DFF  -> rec 0
	.byte 0x00, 0x00, 0x7b, 0x03, 0xf5, 0x00   ; F50D77  [601] key 0x0000  -> rec 175
	.byte 0x01, 0x00, 0xe1, 0x03, 0xf5, 0x00   ; F50D7D  [602] key 0x0001  -> rec 192
	.byte 0x08, 0x00, 0xd7, 0x04, 0xf5, 0x00   ; F50D83  [603] key 0x0008  -> rec 233
	.byte 0x10, 0x00, 0x1b, 0x06, 0xf5, 0x00   ; F50D89  [604] key 0x0010  -> rec 287
	.byte 0x11, 0x00, 0x99, 0x06, 0xf5, 0x00   ; F50D8F  [605] key 0x0011  -> rec 308
	.byte 0x20, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50D95  [606] key 0x0020  -> rec 477
	.byte 0x21, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50D9B  [607] key 0x0021  -> rec 477
	.byte 0x22, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50DA1  [608] key 0x0022  -> rec 477
	.byte 0x23, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50DA7  [609] key 0x0023  -> rec 477
	.byte 0x24, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50DAD  [610] key 0x0024  -> rec 477
	.byte 0x25, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50DB3  [611] key 0x0025  -> rec 477
	.byte 0x26, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50DB9  [612] key 0x0026  -> rec 477
	.byte 0x27, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50DBF  [613] key 0x0027  -> rec 477
	.byte 0x28, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50DC5  [614] key 0x0028  -> rec 477
	.byte 0x29, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50DCB  [615] key 0x0029  -> rec 477
	.byte 0x2a, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50DD1  [616] key 0x002A  -> rec 477
	.byte 0x2b, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50DD7  [617] key 0x002B  -> rec 477
	.byte 0x2c, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50DDD  [618] key 0x002C  -> rec 477
	.byte 0x2d, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50DE3  [619] key 0x002D  -> rec 477
	.byte 0x2e, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50DE9  [620] key 0x002E  -> rec 477
	.byte 0x2f, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50DEF  [621] key 0x002F  -> rec 477
	.byte 0x30, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50DF5  [622] key 0x0030  -> rec 477
	.byte 0x31, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50DFB  [623] key 0x0031  -> rec 477
	.byte 0x32, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50E01  [624] key 0x0032  -> rec 477
	.byte 0x33, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50E07  [625] key 0x0033  -> rec 477
	.byte 0x34, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50E0D  [626] key 0x0034  -> rec 477
	.byte 0x35, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50E13  [627] key 0x0035  -> rec 477
	.byte 0x36, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50E19  [628] key 0x0036  -> rec 477
	.byte 0x37, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50E1F  [629] key 0x0037  -> rec 477
	.byte 0x38, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50E25  [630] key 0x0038  -> rec 477
	.byte 0x39, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50E2B  [631] key 0x0039  -> rec 477
	.byte 0x3a, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50E31  [632] key 0x003A  -> rec 477
	.byte 0x3b, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50E37  [633] key 0x003B  -> rec 477
	.byte 0x3c, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50E3D  [634] key 0x003C  -> rec 477
	.byte 0x3d, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50E43  [635] key 0x003D  -> rec 477
	.byte 0x3e, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50E49  [636] key 0x003E  -> rec 477
	.byte 0x3f, 0x00, 0x8f, 0x0a, 0xf5, 0x00   ; F50E4F  [637] key 0x003F  -> rec 477
	.byte 0x60, 0x00, 0x5f, 0x0d, 0xf5, 0x00   ; F50E55  [638] key 0x0060  -> rec 597
	.byte 0xff, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F50E5B  [639] key 0x0CFF  -> rec 0
	.byte 0x00, 0x00, 0x0b, 0x04, 0xf5, 0x00   ; F50E61  [640] key 0x0000  -> rec 199
	.byte 0x01, 0x00, 0x71, 0x04, 0xf5, 0x00   ; F50E67  [641] key 0x0001  -> rec 216
	.byte 0x08, 0x00, 0xf5, 0x04, 0xf5, 0x00   ; F50E6D  [642] key 0x0008  -> rec 238
	.byte 0x10, 0x00, 0xb7, 0x06, 0xf5, 0x00   ; F50E73  [643] key 0x0010  -> rec 313
	.byte 0x11, 0x00, 0x35, 0x07, 0xf5, 0x00   ; F50E79  [644] key 0x0011  -> rec 334
	.byte 0x20, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50E7F  [645] key 0x0020  -> rec 536
	.byte 0x21, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50E85  [646] key 0x0021  -> rec 536
	.byte 0x22, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50E8B  [647] key 0x0022  -> rec 536
	.byte 0x23, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50E91  [648] key 0x0023  -> rec 536
	.byte 0x24, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50E97  [649] key 0x0024  -> rec 536
	.byte 0x25, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50E9D  [650] key 0x0025  -> rec 536
	.byte 0x26, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50EA3  [651] key 0x0026  -> rec 536
	.byte 0x27, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50EA9  [652] key 0x0027  -> rec 536
	.byte 0x28, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50EAF  [653] key 0x0028  -> rec 536
	.byte 0x29, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50EB5  [654] key 0x0029  -> rec 536
	.byte 0x2a, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50EBB  [655] key 0x002A  -> rec 536
	.byte 0x2b, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50EC1  [656] key 0x002B  -> rec 536
	.byte 0x2c, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50EC7  [657] key 0x002C  -> rec 536
	.byte 0x2d, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50ECD  [658] key 0x002D  -> rec 536
	.byte 0x2e, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50ED3  [659] key 0x002E  -> rec 536
	.byte 0x2f, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50ED9  [660] key 0x002F  -> rec 536
	.byte 0x30, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50EDF  [661] key 0x0030  -> rec 536
	.byte 0x31, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50EE5  [662] key 0x0031  -> rec 536
	.byte 0x32, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50EEB  [663] key 0x0032  -> rec 536
	.byte 0x33, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50EF1  [664] key 0x0033  -> rec 536
	.byte 0x34, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50EF7  [665] key 0x0034  -> rec 536
	.byte 0x35, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50EFD  [666] key 0x0035  -> rec 536
	.byte 0x36, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50F03  [667] key 0x0036  -> rec 536
	.byte 0x37, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50F09  [668] key 0x0037  -> rec 536
	.byte 0x38, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50F0F  [669] key 0x0038  -> rec 536
	.byte 0x39, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50F15  [670] key 0x0039  -> rec 536
	.byte 0x3a, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50F1B  [671] key 0x003A  -> rec 536
	.byte 0x3b, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50F21  [672] key 0x003B  -> rec 536
	.byte 0x3c, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50F27  [673] key 0x003C  -> rec 536
	.byte 0x3d, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50F2D  [674] key 0x003D  -> rec 536
	.byte 0x3e, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50F33  [675] key 0x003E  -> rec 536
	.byte 0x3f, 0x00, 0xf1, 0x0b, 0xf5, 0x00   ; F50F39  [676] key 0x003F  -> rec 536
	.byte 0x60, 0x00, 0x6b, 0x0d, 0xf5, 0x00   ; F50F3F  [677] key 0x0060  -> rec 599
	.byte 0xff, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F50F45  [678] key 0x0CFF  -> rec 0
	.byte 0xfe, 0x17, 0x61, 0xff, 0xf4, 0x00   ; F50F4B  [679] key 0x17FE  -> rec 0
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F50F51  [680] key 0x0EFF  -> rec 0
	.byte 0xfe, 0x00, 0x4b, 0x0f, 0xf5, 0x00   ; F50F57  [681] key 0x00FE  -> rec 679
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F50F5D  [682] key 0x0EFF  -> rec 0
	.byte 0xfe, 0x00, 0x57, 0x0f, 0xf5, 0x00   ; F50F63  [683] key 0x00FE  -> rec 681
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F50F69  [684] key 0x0EFF  -> rec 0
	.byte 0xfe, 0x00, 0x63, 0x0f, 0xf5, 0x00   ; F50F6F  [685] key 0x00FE  -> rec 683
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50F75  [686] key 0x0DFF  -> rec 0
	.byte 0xfe, 0x00, 0x6f, 0x0f, 0xf5, 0x00   ; F50F7B  [687] key 0x00FE  -> rec 685
	.byte 0xff, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F50F81  [688] key 0x0CFF  -> rec 0
	.byte 0x00, 0x00, 0x77, 0x0d, 0xf5, 0x00   ; F50F87  [689] key 0x0000  -> rec 601
	.byte 0x10, 0x00, 0x7b, 0x0f, 0xf5, 0x00   ; F50F8D  [690] key 0x0010  -> rec 687
	.byte 0x18, 0x00, 0x7b, 0x0f, 0xf5, 0x00   ; F50F93  [691] key 0x0018  -> rec 687
	.byte 0x19, 0x00, 0x7b, 0x0f, 0xf5, 0x00   ; F50F99  [692] key 0x0019  -> rec 687
	.byte 0xff, 0x0b, 0x61, 0xff, 0xf4, 0x00   ; F50F9F  [693] key 0x0BFF  -> rec 0
	.byte 0x11, 0x00, 0x87, 0x0f, 0xf5, 0x00   ; F50FA5  [694] key 0x0011  -> rec 689
	.byte 0xff, 0x0a, 0x61, 0xff, 0xf4, 0x00   ; F50FAB  [695] key 0x0AFF  -> rec 0
	.byte 0x00, 0x00, 0xa5, 0x0f, 0xf5, 0x00   ; F50FB1  [696] key 0x0000  -> rec 694
	.byte 0x01, 0x00, 0xa5, 0x0f, 0xf5, 0x00   ; F50FB7  [697] key 0x0001  -> rec 694
	.byte 0xff, 0x09, 0x61, 0xff, 0xf4, 0x00   ; F50FBD  [698] key 0x09FF  -> rec 0
	.byte 0x04, 0x00, 0xb1, 0x0f, 0xf5, 0x00   ; F50FC3  [699] key 0x0004  -> rec 696
	.byte 0xff, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F50FC9  [700] key 0x08FF  -> rec 0
	.byte 0xfe, 0x1e, 0x61, 0xff, 0xf4, 0x00   ; F50FCF  [701] key 0x1EFE  -> rec 0
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F50FD5  [702] key 0x10FF  -> rec 0
	.byte 0xfe, 0x00, 0xcf, 0x0f, 0xf5, 0x00   ; F50FDB  [703] key 0x00FE  -> rec 701
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F50FE1  [704] key 0x0FFF  -> rec 0
	.byte 0xfe, 0x00, 0xdb, 0x0f, 0xf5, 0x00   ; F50FE7  [705] key 0x00FE  -> rec 703
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F50FED  [706] key 0x0EFF  -> rec 0
	.byte 0x00, 0x00, 0xe7, 0x0f, 0xf5, 0x00   ; F50FF3  [707] key 0x0000  -> rec 705
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F50FF9  [708] key 0x0DFF  -> rec 0
	.byte 0x00, 0x00, 0xf3, 0x0f, 0xf5, 0x00   ; F50FFF  [709] key 0x0000  -> rec 707
	.byte 0xff, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F51005  [710] key 0x0CFF  -> rec 0
	.byte 0xfe, 0x1f, 0x61, 0xff, 0xf4, 0x00   ; F5100B  [711] key 0x1FFE  -> rec 0
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F51011  [712] key 0x10FF  -> rec 0
	.byte 0xfe, 0x00, 0x0b, 0x10, 0xf5, 0x00   ; F51017  [713] key 0x00FE  -> rec 711
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F5101D  [714] key 0x0FFF  -> rec 0
	.byte 0xfe, 0x00, 0x17, 0x10, 0xf5, 0x00   ; F51023  [715] key 0x00FE  -> rec 713
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F51029  [716] key 0x0EFF  -> rec 0
	.byte 0x00, 0x00, 0x23, 0x10, 0xf5, 0x00   ; F5102F  [717] key 0x0000  -> rec 715
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F51035  [718] key 0x0DFF  -> rec 0
	.byte 0x00, 0x00, 0x2f, 0x10, 0xf5, 0x00   ; F5103B  [719] key 0x0000  -> rec 717
	.byte 0xff, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F51041  [720] key 0x0CFF  -> rec 0
	.byte 0xfe, 0x1c, 0x61, 0xff, 0xf4, 0x00   ; F51047  [721] key 0x1CFE  -> rec 0
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F5104D  [722] key 0x10FF  -> rec 0
	.byte 0xfe, 0x00, 0x47, 0x10, 0xf5, 0x00   ; F51053  [723] key 0x00FE  -> rec 721
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F51059  [724] key 0x0FFF  -> rec 0
	.byte 0xfe, 0x00, 0x53, 0x10, 0xf5, 0x00   ; F5105F  [725] key 0x00FE  -> rec 723
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F51065  [726] key 0x0EFF  -> rec 0
	.byte 0x00, 0x00, 0x5f, 0x10, 0xf5, 0x00   ; F5106B  [727] key 0x0000  -> rec 725
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F51071  [728] key 0x0DFF  -> rec 0
	.byte 0x00, 0x00, 0x6b, 0x10, 0xf5, 0x00   ; F51077  [729] key 0x0000  -> rec 727
	.byte 0xff, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F5107D  [730] key 0x0CFF  -> rec 0
	.byte 0xfe, 0x1b, 0x61, 0xff, 0xf4, 0x00   ; F51083  [731] key 0x1BFE  -> rec 0
	.byte 0xff, 0x10, 0x61, 0xff, 0xf4, 0x00   ; F51089  [732] key 0x10FF  -> rec 0
	.byte 0xfe, 0x00, 0x83, 0x10, 0xf5, 0x00   ; F5108F  [733] key 0x00FE  -> rec 731
	.byte 0xff, 0x0f, 0x61, 0xff, 0xf4, 0x00   ; F51095  [734] key 0x0FFF  -> rec 0
	.byte 0xfe, 0x00, 0x8f, 0x10, 0xf5, 0x00   ; F5109B  [735] key 0x00FE  -> rec 733
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F510A1  [736] key 0x0EFF  -> rec 0
	.byte 0x00, 0x00, 0x9b, 0x10, 0xf5, 0x00   ; F510A7  [737] key 0x0000  -> rec 735
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F510AD  [738] key 0x0DFF  -> rec 0
	.byte 0x00, 0x00, 0xa7, 0x10, 0xf5, 0x00   ; F510B3  [739] key 0x0000  -> rec 737
	.byte 0xff, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F510B9  [740] key 0x0CFF  -> rec 0
	.byte 0xfe, 0x19, 0x61, 0xff, 0xf4, 0x00   ; F510BF  [741] key 0x19FE  -> rec 0
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F510C5  [742] key 0x0EFF  -> rec 0
	.byte 0xfe, 0x00, 0xbf, 0x10, 0xf5, 0x00   ; F510CB  [743] key 0x00FE  -> rec 741
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F510D1  [744] key 0x0EFF  -> rec 0
	.byte 0xfe, 0x00, 0xcb, 0x10, 0xf5, 0x00   ; F510D7  [745] key 0x00FE  -> rec 743
	.byte 0xff, 0x0e, 0x61, 0xff, 0xf4, 0x00   ; F510DD  [746] key 0x0EFF  -> rec 0
	.byte 0xfe, 0x00, 0xd7, 0x10, 0xf5, 0x00   ; F510E3  [747] key 0x00FE  -> rec 745
	.byte 0xff, 0x0d, 0x61, 0xff, 0xf4, 0x00   ; F510E9  [748] key 0x0DFF  -> rec 0
	.byte 0xfe, 0x00, 0xe3, 0x10, 0xf5, 0x00   ; F510EF  [749] key 0x00FE  -> rec 747
	.byte 0xff, 0x0c, 0x61, 0xff, 0xf4, 0x00   ; F510F5  [750] key 0x0CFF  -> rec 0
	.byte 0x00, 0x00, 0x61, 0x0e, 0xf5, 0x00   ; F510FB  [751] key 0x0000  -> rec 640
	.byte 0x10, 0x00, 0xef, 0x10, 0xf5, 0x00   ; F51101  [752] key 0x0010  -> rec 749
	.byte 0x18, 0x00, 0xef, 0x10, 0xf5, 0x00   ; F51107  [753] key 0x0018  -> rec 749
	.byte 0x19, 0x00, 0xef, 0x10, 0xf5, 0x00   ; F5110D  [754] key 0x0019  -> rec 749
	.byte 0x40, 0x00, 0xb3, 0x10, 0xf5, 0x00   ; F51113  [755] key 0x0040  -> rec 739
	.byte 0x20, 0x00, 0x77, 0x10, 0xf5, 0x00   ; F51119  [756] key 0x0020  -> rec 729
	.byte 0x50, 0x00, 0x3b, 0x10, 0xf5, 0x00   ; F5111F  [757] key 0x0050  -> rec 719
	.byte 0x60, 0x00, 0xff, 0x0f, 0xf5, 0x00   ; F51125  [758] key 0x0060  -> rec 709
	.byte 0xff, 0x0b, 0x61, 0xff, 0xf4, 0x00   ; F5112B  [759] key 0x0BFF  -> rec 0
	.byte 0x11, 0x00, 0xfb, 0x10, 0xf5, 0x00   ; F51131  [760] key 0x0011  -> rec 751
	.byte 0xff, 0x0a, 0x61, 0xff, 0xf4, 0x00   ; F51137  [761] key 0x0AFF  -> rec 0
	.byte 0x00, 0x00, 0x31, 0x11, 0xf5, 0x00   ; F5113D  [762] key 0x0000  -> rec 760
	.byte 0x01, 0x00, 0x31, 0x11, 0xf5, 0x00   ; F51143  [763] key 0x0001  -> rec 760
	.byte 0xff, 0x09, 0x61, 0xff, 0xf4, 0x00   ; F51149  [764] key 0x09FF  -> rec 0
	.byte 0x04, 0x00, 0x3d, 0x11, 0xf5, 0x00   ; F5114F  [765] key 0x0004  -> rec 762
	.byte 0xff, 0x08, 0x61, 0xff, 0xf4, 0x00   ; F51155  [766] key 0x08FF  -> rec 0
; SysExDecodeTree_Root -- record 767: the level-0 list prom_a SysExRx_MatchTrie
;   starts from (14 entries and the 0xFF terminator with code 7).
SysExDecodeTree_Root:
	.byte 0x25, 0x09, 0x61, 0xff, 0xf4, 0x00   ; F5115B  [767] key 0x0925  -> rec 0
	.byte 0x7e, 0x0a, 0x61, 0xff, 0xf4, 0x00   ; F51161  [768] key 0x0A7E  -> rec 0
	.byte 0x23, 0x00, 0xd9, 0xff, 0xf4, 0x00   ; F51167  [769] key 0x0023  -> rec 20
	.byte 0x24, 0x00, 0xe5, 0xff, 0xf4, 0x00   ; F5116D  [770] key 0x0024  -> rec 22
	.byte 0x2d, 0x00, 0x1f, 0x02, 0xf5, 0x00   ; F51173  [771] key 0x002D  -> rec 117
	.byte 0x27, 0x00, 0xf1, 0xff, 0xf4, 0x00   ; F51179  [772] key 0x0027  -> rec 24
	.byte 0x28, 0x00, 0xfd, 0xff, 0xf4, 0x00   ; F5117F  [773] key 0x0028  -> rec 26
	.byte 0x2c, 0x00, 0xc3, 0x0f, 0xf5, 0x00   ; F51185  [774] key 0x002C  -> rec 699
	.byte 0x2b, 0x00, 0x4f, 0x11, 0xf5, 0x00   ; F5118B  [775] key 0x002B  -> rec 765
	.byte 0x7f, 0x00, 0xcd, 0xff, 0xf4, 0x00   ; F51191  [776] key 0x007F  -> rec 18
	.byte 0x29, 0x00, 0x09, 0x00, 0xf5, 0x00   ; F51197  [777] key 0x0029  -> rec 28
	.byte 0x2a, 0x00, 0x15, 0x00, 0xf5, 0x00   ; F5119D  [778] key 0x002A  -> rec 30
	.byte 0x21, 0x00, 0x85, 0xff, 0xf4, 0x00   ; F511A3  [779] key 0x0021  -> rec 6
	.byte 0x22, 0x00, 0xaf, 0xff, 0xf4, 0x00   ; F511A9  [780] key 0x0022  -> rec 13
	.byte 0xff, 0x07, 0x61, 0xff, 0xf4, 0x00   ; F511AF  [781] key 0x07FF  -> rec 0

; --- 0xF511B5-0xF511C6  data (18 bytes) ---
	.byte 0x00, 0x01, 0x01, 0x02, 0x03, 0x03, 0x04, 0x05, 0x05, 0x05, 0x06, 0x07, 0x07, 0x07, 0x08, 0x09   ; F511B5  ................
	.byte 0x09, 0x0a   ; F511C5  ..

; --- 0xF511C7-0xF511DC  ascii (22 bytes) ---

; --------------------------------------------------------------------------
; SysExStatus_MessageIdMap -- 22 bytes that are printable but are not text:
;           '#!!!!!!!"""!!!!!!!!!!!'
; Read by: prom_a 0xFB7E54 `add XWA,0x00f511c7` -- an INDEXED TABLE, not a
;          string.
; Evidence: the layout's ascii rule fires on it at threshold 20, but the 22
;           bytes span only 0x21-0x23 (3 distinct values), so it is a small-
;           integer table that happens to land in the printable range.
;           Named for what it IS.
; --------------------------------------------------------------------------
SysExStatus_MessageIdMap:
	.byte 0x23, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x22, 0x22, 0x22, 0x21, 0x21, 0x21, 0x21, 0x21   ; F511C7  #!!!!!!!"""!!!!!
	.byte 0x21, 0x21, 0x21, 0x21, 0x21, 0x21   ; F511D7  !!!!!!

; --- 0xF511DD-0xF51E1F  data (3139 bytes) ---

; --------------------------------------------------------------------------
; RecordArray_F511DD -- 110 variable-length records, framed by RecordIndex_F51E8A
; ★ CORRECTION C5: the layout's HOLES table says "the record boundary is not
;                  pinned by anything this lane could measure".  It is
;                  pinned. The 225 entries of RecordIndex_F51E8A resolve to
;                  110 distinct addresses, every one of them inside this
;                  segment, and 109 of the 110 carry the prom_a callback
;                  word 0x00FB4D61 or 0x00FB4D62 at exactly +0x10.  Those
;                  110 ARE the record starts.
; Record shape: 16 parameter bytes, then three 32-bit prom_a pointers at
;               +0x10, +0x14 and +0x18, then 0 or more trailing bytes.
;               Head-to-head strides: 28 x99, 32 x7, 2 x1, 43 x1, 30 x1.
; ⚠ The one exception: 0xF514B9 carries the callback at +0x12, not +0x10,
;                      and sits 2 bytes in front of 0xF514BB, which is also
;                      an index entry.  Reported, not smoothed.
; Evidence: 109 of the 110 index targets carry 0x00FB4D61/0x00FB4D62 at
;           +0x10; the dominant head-to-head stride, 28, is exactly 16
;           parameter bytes plus three pointers; and the last record start,
;           0xF51DF8, is checked as well as the first.
; Unknown: what the 16 parameter bytes mean, and why the first 28 bytes of
;          the segment (0xF511DD-0xF511F8) are in front of the first record.
; --------------------------------------------------------------------------
; 2026-10-04: LAID OUT as the 109 descriptors the twelve descriptor tables name, each labelled after its parameter
;   (notes/prom_b_sysex_param_descriptors.py); the bytes are unchanged and re-checked against the ROM.
RecordArray_F511DD:
	.byte 0x0f, 0x21, 0x20, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x20, 0x20, 0x21, 0x00, 0x00, 0x00, 0x00   ; F511DD  .! !!!!!!  !....
	.byte 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; F511ED  ............
; SysExParamDesc_Placeholder: the placeholder descriptor, index 0 of every descriptor table (setter SysExParam_SetPlaceholder)
SysExParamDesc_Placeholder:
;   area 00 adr 10 00  size 00 00 01  rec B0 off 01 mask 7F  range 0..127
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x01, 0xb0, 0x01, 0x7f, 0x00, 0x7f, 0x00, 0x00, 0x00, 0xff, 0x00   ; F511F9  ................
	.long SysExParam_NoTransmitOnChange	; F51209  +0x10 transmit-on-change
	.long SysExParam_SetPlaceholder	; F5120D  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51211  +0x18 reader (2B request)
; SysExParamDesc_SoundMemoryProtect: SOUND MEMORY PROTECT -- SysEx address 00 00 00 (Technics Reference Guide)
SysExParamDesc_SoundMemoryProtect:
;   area 00 adr 00 00  size 00 00 01  rec 00 off 00 mask 01  range 0..1
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00   ; F51215  ................
	.long SysExParam_NoTransmitOnChange	; F51225  +0x10 transmit-on-change
	.long SysExParam_SetMemoryProtect	; F51229  +0x14 setter (2C)
	.long SysExParam_GetMemoryProtect	; F5122D  +0x18 reader (2B request)
; SysExParamDesc_CombinationMemoryProtect: COMBINATION MEMORY PROTECT -- SysEx address 00 00 01 (Technics Reference Guide)
SysExParamDesc_CombinationMemoryProtect:
;   area 00 adr 00 01  size 00 00 01  rec 00 off 00 mask 02  range 0..1
	.byte 0x00, 0x00, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x02, 0x00, 0x01, 0x01, 0x01, 0x00, 0x01, 0x00   ; F51231  ................
	.long SysExParam_NoTransmitOnChange	; F51241  +0x10 transmit-on-change
	.long SysExParam_SetMemoryProtect	; F51245  +0x14 setter (2C)
	.long SysExParam_GetMemoryProtect	; F51249  +0x18 reader (2B request)
; SysExParamDesc_MasterTuning: MASTER TUNING -- SysEx address 00 00 08 (Technics Reference Guide)
SysExParamDesc_MasterTuning:
;   area 00 adr 00 08  size 00 00 01  rec 91 off 00 mask FF  range 48..192
	.byte 0x00, 0x00, 0x08, 0x00, 0x00, 0x01, 0x91, 0x00, 0xff, 0x30, 0xc0, 0x00, 0x01, 0x00, 0xff, 0x00   ; F5124D  .........0......
	.long SysExParam_NoTransmitOnChange	; F5125D  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51261  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51265  +0x18 reader (2B request)
; SysExParamDesc_VelocityCurve: VELOCITY CURVE -- SysEx address 00 00 10 (Technics Reference Guide)
SysExParamDesc_VelocityCurve:
;   area 00 adr 00 10  size 00 00 01  rec 93 off 00 mask 0F  range 0..9
	.byte 0x00, 0x00, 0x10, 0x00, 0x00, 0x01, 0x93, 0x00, 0x0f, 0x00, 0x09, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51269  ................
	.long SysExParam_NoTransmitOnChange	; F51279  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F5127D  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51281  +0x18 reader (2B request)
; SysExParamDesc_VelocityOffset_0011: VELOCITY OFFSET -- SysEx address 00 00 11 (Technics Reference Guide)
SysExParamDesc_VelocityOffset_0011:
;   area 00 adr 00 11  size 00 00 01  rec 93 off 02 mask 7F  range 0..127
	.byte 0x00, 0x00, 0x11, 0x00, 0x00, 0x01, 0x93, 0x02, 0x7f, 0x00, 0x7f, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51285  ................
	.long SysExParam_NoTransmitOnChange	; F51295  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51299  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F5129D  +0x18 reader (2B request)
; SysExParamDesc_AfterTouchCurve: AFTER TOUCH CURVE -- SysEx address 00 00 12 (Technics Reference Guide)
SysExParamDesc_AfterTouchCurve:
;   area 00 adr 00 12  size 00 00 01  rec 93 off 05 mask FF  range 0..10
	.byte 0x00, 0x00, 0x12, 0x00, 0x00, 0x01, 0x93, 0x05, 0xff, 0x00, 0x0a, 0x00, 0x01, 0x00, 0xff, 0x00   ; F512A1  ................
	.long SysExParam_NoTransmitOnChange	; F512B1  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F512B5  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F512B9  +0x18 reader (2B request)
; SysExParamDesc_AfterTouchThreshold: AFTER TOUCH THRESHOLD -- SysEx address 00 00 13 (Technics Reference Guide)
SysExParamDesc_AfterTouchThreshold:
;   area 00 adr 00 13  size 00 00 01  rec 93 off 06 mask 7F  range 0..127
	.byte 0x00, 0x00, 0x13, 0x00, 0x00, 0x01, 0x93, 0x06, 0x7f, 0x00, 0x7f, 0x00, 0x01, 0x00, 0xff, 0x00   ; F512BD  ................
	.long SysExParam_NoTransmitOnChange	; F512CD  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F512D1  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F512D5  +0x18 reader (2B request)
; SysExParamDesc_DrumsMapSelect: DRUMS MAP SELECT -- SysEx address 00 00 20 (Technics Reference Guide)
SysExParamDesc_DrumsMapSelect:
;   area 00 adr 00 20  size 00 00 01  rec 91 off 04 mask FF  range 0..66
	.byte 0x00, 0x00, 0x20, 0x00, 0x00, 0x01, 0x91, 0x04, 0xff, 0x00, 0x42, 0x00, 0x01, 0x00, 0x00, 0x00   ; F512D9  .. .......B.....
	.long SysExParam_NoTransmitOnChange	; F512E9  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F512ED  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F512F1  +0x18 reader (2B request)
	.byte 0x00, 0x40, 0x41, 0x42   ; F512F5  .@AB
; SysExParamDesc_DataLoadFilterEffectAndOutput: DATA LOAD FILTER: EFFECT & OUTPUT -- SysEx address 00 00 30 (Technics Reference Guide)
SysExParamDesc_DataLoadFilterEffectAndOutput:
;   area 00 adr 00 30  size 00 00 01  rec 7A off 02 mask 0F  range 0..2
	.byte 0x00, 0x00, 0x30, 0x00, 0x00, 0x01, 0x7a, 0x02, 0x0f, 0x00, 0x02, 0x00, 0x01, 0x00, 0xff, 0x00   ; F512F9  ..0...z.........
	.long SysExParam_NoTransmitOnChange	; F51309  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F5130D  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51311  +0x18 reader (2B request)
; SysExParamDesc_DataLoadFilterRealTimeCreator16: DATA LOAD FILTER: REAL-TIME CREATOR 1-6 -- SysEx address 00 00 31 (Technics Reference Guide)
SysExParamDesc_DataLoadFilterRealTimeCreator16:
;   area 00 adr 00 31  size 00 00 01  rec 7A off 02 mask F0  range 0..2
	.byte 0x00, 0x00, 0x31, 0x00, 0x00, 0x01, 0x7a, 0x02, 0xf0, 0x00, 0x02, 0x04, 0x01, 0x00, 0xff, 0x00   ; F51315  ..1...z.........
	.long SysExParam_NoTransmitOnChange	; F51325  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51329  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F5132D  +0x18 reader (2B request)
; SysExParamDesc_DataLoadFilterCombinationOctave: DATA LOAD FILTER: COMBINATION OCTAVE -- SysEx address 00 00 32 (Technics Reference Guide)
SysExParamDesc_DataLoadFilterCombinationOctave:
;   area 00 adr 00 32  size 00 00 01  rec 98 off 05 mask 04  range 0..1
	.byte 0x00, 0x00, 0x32, 0x00, 0x00, 0x01, 0x98, 0x05, 0x04, 0x00, 0x01, 0x02, 0x01, 0x00, 0xff, 0xff   ; F51331  ..2.............
	.long SysExParam_NoTransmitOnChange	; F51341  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51345  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51349  +0x18 reader (2B request)
; SysExParamDesc_DataLoadFilterMidiSetting: DATA LOAD FILTER: MIDI SETTING -- SysEx address 00 00 33 (Technics Reference Guide)
SysExParamDesc_DataLoadFilterMidiSetting:
;   area 00 adr 00 33  size 00 00 01  rec 98 off 05 mask 02  range 0..1
	.byte 0x00, 0x00, 0x33, 0x00, 0x00, 0x01, 0x98, 0x05, 0x02, 0x00, 0x01, 0x01, 0x01, 0x00, 0xff, 0xff   ; F5134D  ..3.............
	.long SysExParam_NoTransmitOnChange	; F5135D  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51361  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51365  +0x18 reader (2B request)
; SysExParamDesc_DataLoadFilterKeyAndVelocityLayer: DATA LOAD FILTER: KEY & VELOCITY LAYER -- SysEx address 00 00 34 (Technics Reference Guide)
SysExParamDesc_DataLoadFilterKeyAndVelocityLayer:
;   area 00 adr 00 34  size 00 00 01  rec 98 off 05 mask 01  range 0..1
	.byte 0x00, 0x00, 0x34, 0x00, 0x00, 0x01, 0x98, 0x05, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0xff, 0xff   ; F51369  ..4.............
	.long SysExParam_NoTransmitOnChange	; F51379  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F5137D  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51381  +0x18 reader (2B request)
; SysExParamDesc_DataLoadFilterMainOutEqualizer: DATA LOAD FILTER: MAIN OUT EQUALIZER -- SysEx address 00 00 35 (Technics Reference Guide)
SysExParamDesc_DataLoadFilterMainOutEqualizer:
;   area 00 adr 00 35  size 00 00 01  rec 98 off 05 mask 08  range 0..1
	.byte 0x00, 0x00, 0x35, 0x00, 0x00, 0x01, 0x98, 0x05, 0x08, 0x00, 0x01, 0x03, 0x01, 0x00, 0xff, 0xff   ; F51385  ..5.............
	.long SysExParam_NoTransmitOnChange	; F51395  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51399  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F5139D  +0x18 reader (2B request)
; SysExParamDesc_DataLoadFilterKeyScaling: DATA LOAD FILTER: KEY SCALING -- SysEx address 00 00 36 (Technics Reference Guide)
SysExParamDesc_DataLoadFilterKeyScaling:
;   area 00 adr 00 36  size 00 00 01  rec 98 off 05 mask 10  range 0..1
	.byte 0x00, 0x00, 0x36, 0x00, 0x00, 0x01, 0x98, 0x05, 0x10, 0x00, 0x01, 0x04, 0x01, 0x00, 0xff, 0xff   ; F513A1  ..6.............
	.long SysExParam_NoTransmitOnChange	; F513B1  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F513B5  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F513B9  +0x18 reader (2B request)
; SysExParamDesc_CombinationNumberAndBank: COMBINATION NUMBER and BANK -- SysEx address 00 00 40 (Technics Reference Guide)
SysExParamDesc_CombinationNumberAndBank:
;   area 00 adr 00 40  size 00 00 02  rec 98 off 01 mask 7F  range 0..127
	.byte 0x00, 0x00, 0x40, 0x00, 0x00, 0x02, 0x98, 0x01, 0x7f, 0x00, 0x7f, 0x00, 0x01, 0x00, 0xff, 0x00   ; F513BD  ..@.............
	.long SysExParam_NoTransmitOnChange	; F513CD  +0x10 transmit-on-change
	.long SysExParam_SetCombinationNumberAndBank	; F513D1  +0x14 setter (2C)
	.long SysExParam_GetCombinationNumberAndBank	; F513D5  +0x18 reader (2B request)
; SysExParamDesc_MidiInputMode: MIDI INPUT MODE -- SysEx address 00 01 00 (Technics Reference Guide)
SysExParamDesc_MidiInputMode:
;   area 00 adr 01 00  size 00 00 01  rec 80 off 03 mask 0F  range 0..2
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x80, 0x03, 0x0f, 0x00, 0x02, 0x00, 0x01, 0x00, 0xff, 0x00   ; F513D9  ................
	.long SysExParam_NoTransmitOnChange	; F513E9  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F513ED  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F513F1  +0x18 reader (2B request)
; SysExParamDesc_MidiOutputMode: MIDI OUTPUT MODE -- SysEx address 00 01 01 (Technics Reference Guide)
SysExParamDesc_MidiOutputMode:
;   area 00 adr 01 01  size 00 00 01  rec 80 off 03 mask F0  range 0..1
	.byte 0x00, 0x01, 0x01, 0x00, 0x00, 0x01, 0x80, 0x03, 0xf0, 0x00, 0x01, 0x04, 0x01, 0x00, 0xff, 0x00   ; F513F5  ................
	.long SysExParam_NoTransmitOnChange	; F51405  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51409  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F5140D  +0x18 reader (2B request)
; SysExParamDesc_SingleChannel: SINGLE CHANNEL -- SysEx address 00 01 02 (Technics Reference Guide)
SysExParamDesc_SingleChannel:
;   area 00 adr 01 02  size 00 00 01  rec 80 off 04 mask 1F  range 0..15
	.byte 0x00, 0x01, 0x02, 0x00, 0x00, 0x01, 0x80, 0x04, 0x1f, 0x00, 0x0f, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51411  ................
	.long SysExParam_NoTransmitOnChange	; F51421  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51425  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51429  +0x18 reader (2B request)
; SysExParamDesc_LocalTotal: LOCAL TOTAL -- SysEx address 00 01 03 (Technics Reference Guide)
SysExParamDesc_LocalTotal:
;   area 00 adr 01 03  size 00 00 01  rec 80 off 04 mask 20  range 0..1
	.byte 0x00, 0x01, 0x03, 0x00, 0x00, 0x01, 0x80, 0x04, 0x20, 0x00, 0x01, 0x05, 0x01, 0x00, 0xff, 0xff   ; F5142D  ........ .......
	.long SysExParam_NoTransmitOnChange	; F5143D  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51441  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51445  +0x18 reader (2B request)
; SysExParamDesc_ProgramChangeMode: PROGRAM CHANGE MODE -- SysEx address 00 01 04 (Technics Reference Guide)
SysExParamDesc_ProgramChangeMode:
;   area 00 adr 01 04  size 00 00 01  rec 80 off 00 mask 03  range 0..1
	.byte 0x00, 0x01, 0x04, 0x00, 0x00, 0x01, 0x80, 0x00, 0x03, 0x00, 0x01, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51449  ................
	.long SysExParam_NoTransmitOnChange	; F51459  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F5145D  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51461  +0x18 reader (2B request)
; SysExParamDesc_SingleChannelProgramChange: SINGLE CHANNEL PROGRAM CHANGE -- SysEx address 00 01 05 (Technics Reference Guide)
SysExParamDesc_SingleChannelProgramChange:
;   area 00 adr 01 05  size 00 00 01  rec 80 off 00 mask 08  range 0..1
	.byte 0x00, 0x01, 0x05, 0x00, 0x00, 0x01, 0x80, 0x00, 0x08, 0x00, 0x01, 0x03, 0x01, 0x00, 0xff, 0x00   ; F51465  ................
	.long SysExParam_NoTransmitOnChange	; F51475  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51479  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F5147D  +0x18 reader (2B request)
; SysExParamDesc_Initial: INITIAL -- SysEx address 00 08 00 (Technics Reference Guide)
SysExParamDesc_Initial:
;   area 00 adr 08 00  size 00 00 01  rec 00 off 00 mask 00  range 0..6
	.byte 0x00, 0x08, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51481  ................
	.long SysExTx_SendParamValue	; F51491  +0x10 transmit-on-change
	.long SysExParam_SetInitial	; F51495  +0x14 setter (2C)
	.long SysExParam_ReceiveOnly	; F51499  +0x18 reader (2B request)
; SysExParamDesc_PlayModeRequest: PLAY MODE REQUEST -- SysEx address 00 08 08 (Technics Reference Guide)
SysExParamDesc_PlayModeRequest:
;   area 00 adr 08 08  size 00 00 01  rec 98 off 00 mask F0  range 0..1
	.byte 0x00, 0x08, 0x08, 0x00, 0x00, 0x01, 0x98, 0x00, 0xf0, 0x00, 0x01, 0x04, 0x01, 0x00, 0x00, 0x00   ; F5149D  ................
	.long SysExTx_SendParamValue	; F514AD  +0x10 transmit-on-change
	.long SysExParam_SetPlayModeRequest	; F514B1  +0x14 setter (2C)
	.long SysExParam_ReceiveOnly	; F514B5  +0x18 reader (2B request)
	.byte 0x01, 0x02   ; F514B9  ..
; SysExParamDesc_CombinationWriteRequest: COMBINATION WRITE REQUEST -- SysEx address 00 08 10 (Technics Reference Guide)
SysExParamDesc_CombinationWriteRequest:
;   area 00 adr 08 10  size 00 00 01  rec 00 off 00 mask 00  range 0..127
	.byte 0x00, 0x08, 0x10, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x7f, 0x00, 0x01, 0x00, 0xff, 0x00   ; F514BB  ................
	.long SysExTx_SendParamValue	; F514CB  +0x10 transmit-on-change
	.long SysExParam_SetCombinationWriteRequest	; F514CF  +0x14 setter (2C)
	.long SysExParam_ReceiveOnly	; F514D3  +0x18 reader (2B request)
; SysExParamDesc_SoundWriteRequest: SOUND WRITE REQUEST -- SysEx address 00 08 11 (Technics Reference Guide)
SysExParamDesc_SoundWriteRequest:
;   area 00 adr 08 11  size 00 00 03  rec 00 off 00 mask 00  range 0..1
	.byte 0x00, 0x08, 0x11, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0xff, 0x00   ; F514D7  ................
	.long SysExTx_SendParamValue	; F514E7  +0x10 transmit-on-change
	.long SysExParam_SetSoundWriteRequest	; F514EB  +0x14 setter (2C)
	.long SysExParam_ReceiveOnly	; F514EF  +0x18 reader (2B request)
; SysExParamDesc_KeyTranspose: KEY TRANSPOSE -- SysEx address 00 10 00 (Technics Reference Guide)
SysExParamDesc_KeyTranspose:
;   area 00 adr 10 00  size 00 00 01  rec 79 off 00 mask 7F  range 28..100
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x01, 0x79, 0x00, 0x7f, 0x1c, 0x64, 0x00, 0x01, 0x00, 0xff, 0x00   ; F514F3  ......y...d.....
	.long SysExTx_SendParamValue	; F51503  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51507  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F5150B  +0x18 reader (2B request)
; SysExParamDesc_KeyScalingMode: KEY SCALING MODE -- SysEx address 00 10 10 (Technics Reference Guide)
SysExParamDesc_KeyScalingMode:
;   area 00 adr 10 10  size 00 00 01  rec 92 off 01 mask 80  range 0..1
	.byte 0x00, 0x10, 0x10, 0x00, 0x00, 0x01, 0x92, 0x01, 0x80, 0x00, 0x01, 0x07, 0x01, 0x00, 0xff, 0x00   ; F5150F  ................
	.long SysExTx_SendParamValue	; F5151F  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51523  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51527  +0x18 reader (2B request)
; SysExParamDesc_TotalKeyScaling: TOTAL KEY SCALING -- SysEx address 00 10 11 (Technics Reference Guide)
SysExParamDesc_TotalKeyScaling:
;   area 00 adr 10 11  size 00 00 01  rec 92 off 00 mask FF  range 0..128
	.byte 0x00, 0x10, 0x11, 0x00, 0x00, 0x01, 0x92, 0x00, 0xff, 0x00, 0x80, 0x00, 0x01, 0x00, 0x02, 0x00   ; F5152B  ................
	.long SysExTx_SendParamValue	; F5153B  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F5153F  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51543  +0x18 reader (2B request)
	.byte 0x00, 0x40, 0x41, 0x42   ; F51547  .@AB
	.byte 0x03, 0x04, 0x06, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x80   ; F5154B  ...........
; SysExParamDesc_KeyScalingShift: KEY SCALING SHIFT -- SysEx address 00 10 12 (Technics Reference Guide)
SysExParamDesc_KeyScalingShift:
;   area 00 adr 10 12  size 00 00 01  rec 92 off 01 mask 0F  range 0..11
	.byte 0x00, 0x10, 0x12, 0x00, 0x00, 0x01, 0x92, 0x01, 0x0f, 0x00, 0x0b, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51556  ................
	.long SysExTx_SendParamValue	; F51566  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F5156A  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F5156E  +0x18 reader (2B request)
; SysExParamDesc_CkeyDetuneSetting: Ckey DETUNE SETTING -- SysEx address 00 10 13 (Technics Reference Guide)
SysExParamDesc_CkeyDetuneSetting:
;   area 00 adr 10 13  size 00 00 01  rec 92 off 02 mask FF  range 0..255
	.byte 0x00, 0x10, 0x13, 0x00, 0x00, 0x01, 0x92, 0x02, 0xff, 0x00, 0xff, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51572  ................
	.long SysExTx_SendParamValue	; F51582  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51586  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F5158A  +0x18 reader (2B request)
; SysExParamDesc_DbkeyDetuneSetting: Dbkey DETUNE SETTING -- SysEx address 00 10 14 (Technics Reference Guide)
SysExParamDesc_DbkeyDetuneSetting:
;   area 00 adr 10 14  size 00 00 01  rec 92 off 03 mask FF  range 0..255
	.byte 0x00, 0x10, 0x14, 0x00, 0x00, 0x01, 0x92, 0x03, 0xff, 0x00, 0xff, 0x00, 0x01, 0x00, 0xff, 0x00   ; F5158E  ................
	.long SysExTx_SendParamValue	; F5159E  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F515A2  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F515A6  +0x18 reader (2B request)
; SysExParamDesc_DkeyDetuneSetting: Dkey DETUNE SETTING -- SysEx address 00 10 15 (Technics Reference Guide)
SysExParamDesc_DkeyDetuneSetting:
;   area 00 adr 10 15  size 00 00 01  rec 92 off 04 mask FF  range 0..255
	.byte 0x00, 0x10, 0x15, 0x00, 0x00, 0x01, 0x92, 0x04, 0xff, 0x00, 0xff, 0x00, 0x01, 0x00, 0xff, 0x00   ; F515AA  ................
	.long SysExTx_SendParamValue	; F515BA  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F515BE  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F515C2  +0x18 reader (2B request)
; SysExParamDesc_EbkeyDetuneSetting: Ebkey DETUNE SETTING -- SysEx address 00 10 16 (Technics Reference Guide)
SysExParamDesc_EbkeyDetuneSetting:
;   area 00 adr 10 16  size 00 00 01  rec 92 off 05 mask FF  range 0..255
	.byte 0x00, 0x10, 0x16, 0x00, 0x00, 0x01, 0x92, 0x05, 0xff, 0x00, 0xff, 0x00, 0x01, 0x00, 0xff, 0x00   ; F515C6  ................
	.long SysExTx_SendParamValue	; F515D6  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F515DA  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F515DE  +0x18 reader (2B request)
; SysExParamDesc_EkeyDetuneSetting: Ekey DETUNE SETTING -- SysEx address 00 10 17 (Technics Reference Guide)
SysExParamDesc_EkeyDetuneSetting:
;   area 00 adr 10 17  size 00 00 01  rec 92 off 06 mask FF  range 0..255
	.byte 0x00, 0x10, 0x17, 0x00, 0x00, 0x01, 0x92, 0x06, 0xff, 0x00, 0xff, 0x00, 0x01, 0x00, 0xff, 0x00   ; F515E2  ................
	.long SysExTx_SendParamValue	; F515F2  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F515F6  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F515FA  +0x18 reader (2B request)
; SysExParamDesc_FkeyDetuneSetting: Fkey DETUNE SETTING -- SysEx address 00 10 18 (Technics Reference Guide)
SysExParamDesc_FkeyDetuneSetting:
;   area 00 adr 10 18  size 00 00 01  rec 92 off 07 mask FF  range 0..255
	.byte 0x00, 0x10, 0x18, 0x00, 0x00, 0x01, 0x92, 0x07, 0xff, 0x00, 0xff, 0x00, 0x01, 0x00, 0xff, 0x00   ; F515FE  ................
	.long SysExTx_SendParamValue	; F5160E  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51612  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51616  +0x18 reader (2B request)
; SysExParamDesc_GbkeyDetuneSetting: Gbkey DETUNE SETTING -- SysEx address 00 10 19 (Technics Reference Guide)
SysExParamDesc_GbkeyDetuneSetting:
;   area 00 adr 10 19  size 00 00 01  rec 92 off 08 mask FF  range 0..255
	.byte 0x00, 0x10, 0x19, 0x00, 0x00, 0x01, 0x92, 0x08, 0xff, 0x00, 0xff, 0x00, 0x01, 0x00, 0xff, 0x00   ; F5161A  ................
	.long SysExTx_SendParamValue	; F5162A  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F5162E  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51632  +0x18 reader (2B request)
; SysExParamDesc_GkeyDetuneSetting: Gkey DETUNE SETTING -- SysEx address 00 10 1A (Technics Reference Guide)
SysExParamDesc_GkeyDetuneSetting:
;   area 00 adr 10 1A  size 00 00 01  rec 92 off 09 mask FF  range 0..255
	.byte 0x00, 0x10, 0x1a, 0x00, 0x00, 0x01, 0x92, 0x09, 0xff, 0x00, 0xff, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51636  ................
	.long SysExTx_SendParamValue	; F51646  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F5164A  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F5164E  +0x18 reader (2B request)
; SysExParamDesc_AbkeyDetuneSetting: Abkey DETUNE SETTING -- SysEx address 00 10 1B (Technics Reference Guide)
SysExParamDesc_AbkeyDetuneSetting:
;   area 00 adr 10 1B  size 00 00 01  rec 92 off 0A mask FF  range 0..255
	.byte 0x00, 0x10, 0x1b, 0x00, 0x00, 0x01, 0x92, 0x0a, 0xff, 0x00, 0xff, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51652  ................
	.long SysExTx_SendParamValue	; F51662  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51666  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F5166A  +0x18 reader (2B request)
; SysExParamDesc_AkeyDetuneSetting: Akey DETUNE SETTING -- SysEx address 00 10 1C (Technics Reference Guide)
SysExParamDesc_AkeyDetuneSetting:
;   area 00 adr 10 1C  size 00 00 01  rec 92 off 0B mask FF  range 0..255
	.byte 0x00, 0x10, 0x1c, 0x00, 0x00, 0x01, 0x92, 0x0b, 0xff, 0x00, 0xff, 0x00, 0x01, 0x00, 0xff, 0x00   ; F5166E  ................
	.long SysExTx_SendParamValue	; F5167E  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51682  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51686  +0x18 reader (2B request)
; SysExParamDesc_BbkeyDetuneSetting: Bbkey DETUNE SETTING -- SysEx address 00 10 1D (Technics Reference Guide)
SysExParamDesc_BbkeyDetuneSetting:
;   area 00 adr 10 1D  size 00 00 01  rec 92 off 0C mask FF  range 0..255
	.byte 0x00, 0x10, 0x1d, 0x00, 0x00, 0x01, 0x92, 0x0c, 0xff, 0x00, 0xff, 0x00, 0x01, 0x00, 0xff, 0x00   ; F5168A  ................
	.long SysExTx_SendParamValue	; F5169A  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F5169E  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F516A2  +0x18 reader (2B request)
; SysExParamDesc_BkeyDetuneSetting: Bkey DETUNE SETTING -- SysEx address 00 10 1E (Technics Reference Guide)
SysExParamDesc_BkeyDetuneSetting:
;   area 00 adr 10 1E  size 00 00 01  rec 92 off 0D mask FF  range 0..255
	.byte 0x00, 0x10, 0x1e, 0x00, 0x00, 0x01, 0x92, 0x0d, 0xff, 0x00, 0xff, 0x00, 0x01, 0x00, 0xff, 0x00   ; F516A6  ................
	.long SysExTx_SendParamValue	; F516B6  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F516BA  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F516BE  +0x18 reader (2B request)
; SysExParamDesc_MainOutEqualizerLowFreq: MAIN OUT EQUALIZER LOW-FREQ -- SysEx address 00 10 20 (Technics Reference Guide)
SysExParamDesc_MainOutEqualizerLowFreq:
;   area 00 adr 10 20  size 00 00 01  rec 79 off 01 mask 1F  range 0..17
	.byte 0x00, 0x10, 0x20, 0x00, 0x00, 0x01, 0x79, 0x01, 0x1f, 0x00, 0x11, 0x06, 0x01, 0x00, 0xff, 0x00   ; F516C2  .. ...y.........
	.long SysExTx_SendParamValue	; F516D2  +0x10 transmit-on-change
	.long SysExParam_SetMainOutEqualizerFreq	; F516D6  +0x14 setter (2C)
	.long SysExParam_GetMainOutEqualizerFreq	; F516DA  +0x18 reader (2B request)
; SysExParamDesc_MainOutEqualizerLowGain: MAIN OUT EQUALIZER LOW-GAIN -- SysEx address 00 10 21 (Technics Reference Guide)
SysExParamDesc_MainOutEqualizerLowGain:
;   area 00 adr 10 21  size 00 00 01  rec 79 off 01 mask 3F  range 0..48
	.byte 0x00, 0x10, 0x21, 0x00, 0x00, 0x01, 0x79, 0x01, 0x3f, 0x00, 0x30, 0x00, 0x01, 0x00, 0xff, 0x00   ; F516DE  ..!...y.?.0.....
	.long SysExTx_SendParamValue	; F516EE  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F516F2  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F516F6  +0x18 reader (2B request)
; SysExParamDesc_MainOutEqualizerHighFreq: MAIN OUT EQUALIZER HIGH-FREQ -- SysEx address 00 10 22 (Technics Reference Guide)
SysExParamDesc_MainOutEqualizerHighFreq:
;   area 00 adr 10 22  size 00 00 01  rec 79 off 03 mask 1F  range 17..26
	.byte 0x00, 0x10, 0x22, 0x00, 0x00, 0x01, 0x79, 0x03, 0x1f, 0x11, 0x1a, 0x06, 0x01, 0x00, 0xff, 0x00   ; F516FA  .."...y.........
	.long SysExTx_SendParamValue	; F5170A  +0x10 transmit-on-change
	.long SysExParam_SetMainOutEqualizerFreq	; F5170E  +0x14 setter (2C)
	.long SysExParam_GetMainOutEqualizerFreq	; F51712  +0x18 reader (2B request)
; SysExParamDesc_MainOutEqualizerHighGain: MAIN OUT EQUALIZER HIGH-GAIN -- SysEx address 00 10 23 (Technics Reference Guide)
SysExParamDesc_MainOutEqualizerHighGain:
;   area 00 adr 10 23  size 00 00 01  rec 79 off 03 mask 3F  range 0..48
	.byte 0x00, 0x10, 0x23, 0x00, 0x00, 0x01, 0x79, 0x03, 0x3f, 0x00, 0x30, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51716  ..#...y.?.0.....
	.long SysExTx_SendParamValue	; F51726  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F5172A  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F5172E  +0x18 reader (2B request)
; SysExParamDesc_EffectCommonAlgorithm: EFFECT COMMON ALGORITHM -- SysEx address 00 11 00 (Technics Reference Guide)
SysExParamDesc_EffectCommonAlgorithm:
;   area 00 adr 11 00  size 00 00 01  rec 60 off 00 mask 01  range 0..1
	.byte 0x00, 0x11, 0x00, 0x00, 0x00, 0x01, 0x60, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51732  ......`.........
	.long SysExTx_SendParamValue	; F51742  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51746  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F5174A  +0x18 reader (2B request)
; SysExParamDesc_Effect1OutputSelect: EFFECT1 OUTPUT SELECT -- SysEx address 00 11 01 (Technics Reference Guide)
SysExParamDesc_Effect1OutputSelect:
;   area 00 adr 11 01  size 00 00 01  rec 79 off 05 mask 0F  range 1..4
	.byte 0x00, 0x11, 0x01, 0x00, 0x00, 0x01, 0x79, 0x05, 0x0f, 0x01, 0x04, 0x00, 0x01, 0x00, 0xff, 0x00   ; F5174E  ......y.........
	.long SysExTx_SendParamValue	; F5175E  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51762  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51766  +0x18 reader (2B request)
; SysExParamDesc_Effect2OutputSelect: EFFECT2 OUTPUT SELECT -- SysEx address 00 11 02 (Technics Reference Guide)
SysExParamDesc_Effect2OutputSelect:
;   area 00 adr 11 02  size 00 00 01  rec 79 off 05 mask F0  range 1..4
	.byte 0x00, 0x11, 0x02, 0x00, 0x00, 0x01, 0x79, 0x05, 0xf0, 0x01, 0x04, 0x04, 0x01, 0x00, 0xff, 0x00   ; F5176A  ......y.........
	.long SysExTx_SendParamValue	; F5177A  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F5177E  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51782  +0x18 reader (2B request)
; SysExParamDesc_Effect1Type: EFFECT1 TYPE -- SysEx address 00 11 20 (Technics Reference Guide)
SysExParamDesc_Effect1Type:
;   area 00 adr 11 20  size 00 00 01  rec 00 off 00 mask 00  range 0..0
	.byte 0x00, 0x11, 0x20, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51786  .. .............
	.long SysExTx_SendParamValue	; F51796  +0x10 transmit-on-change
	.long SysExParam_SetEffect1Type	; F5179A  +0x14 setter (2C)
	.long SysExParam_GetEffect1Type	; F5179E  +0x18 reader (2B request)
; SysExParamDesc_ProgramChangeAndBank: PROGRAM CHANGE & BANK -- SysEx address 00 20 00 (Technics Reference Guide)
SysExParamDesc_ProgramChangeAndBank:
;   area 00 adr 20 00  size 00 00 03  rec 00 off 00 mask FF  range 0..127
	.byte 0x00, 0x20, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0xff, 0x00, 0x7f, 0x00, 0x01, 0x00, 0xff, 0x00   ; F517A2  . ..............
	.long SysExTx_SendParamValue	; F517B2  +0x10 transmit-on-change
	.long SysExParam_SetProgramChangeAndBank	; F517B6  +0x14 setter (2C)
	.long SysExParam_GetProgramChangeAndBank	; F517BA  +0x18 reader (2B request)
; SysExParamDesc_Volume: VOLUME -- SysEx address 00 20 03 (Technics Reference Guide)
SysExParamDesc_Volume:
;   area 00 adr 20 03  size 00 00 01  rec 00 off 03 mask 7F  range 0..127
	.byte 0x00, 0x20, 0x03, 0x00, 0x00, 0x01, 0x00, 0x03, 0x7f, 0x00, 0x7f, 0x00, 0x01, 0x00, 0xff, 0x00   ; F517BE  . ..............
	.long SysExTx_SendParamValue	; F517CE  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F517D2  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F517D6  +0x18 reader (2B request)
; SysExParamDesc_Effect1Send: EFFECT1 SEND -- SysEx address 00 20 04 (Technics Reference Guide)
SysExParamDesc_Effect1Send:
;   area 00 adr 20 04  size 00 00 01  rec 00 off 05 mask 7F  range 0..127
	.byte 0x00, 0x20, 0x04, 0x00, 0x00, 0x01, 0x00, 0x05, 0x7f, 0x00, 0x7f, 0x00, 0x01, 0x00, 0xff, 0x00   ; F517DA  . ..............
	.long SysExTx_SendParamValue	; F517EA  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F517EE  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F517F2  +0x18 reader (2B request)
; SysExParamDesc_Effect2OnOff: EFFECT2 ON/OFF -- SysEx address 00 20 05 (Technics Reference Guide)
SysExParamDesc_Effect2OnOff:
;   area 00 adr 20 05  size 00 00 01  rec 00 off 06 mask 7F  range 0..127
	.byte 0x00, 0x20, 0x05, 0x00, 0x00, 0x01, 0x00, 0x06, 0x7f, 0x00, 0x7f, 0x00, 0x01, 0x00, 0x00, 0x00   ; F517F6  . ..............
	.long SysExTx_SendParamValue	; F51806  +0x10 transmit-on-change
	.long SysExParam_SetEffect2OnOff	; F5180A  +0x14 setter (2C)
	.long SysExParam_GetEffect2OnOff	; F5180E  +0x18 reader (2B request)
	.byte 0x00, 0x7f   ; F51812  ..
; SysExParamDesc_ReverbSend: REVERB SEND -- SysEx address 00 20 06 (Technics Reference Guide)
SysExParamDesc_ReverbSend:
;   area 00 adr 20 06  size 00 00 01  rec 00 off 07 mask 7F  range 0..127
	.byte 0x00, 0x20, 0x06, 0x00, 0x00, 0x01, 0x00, 0x07, 0x7f, 0x00, 0x7f, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51814  . ..............
	.long SysExTx_SendParamValue	; F51824  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51828  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F5182C  +0x18 reader (2B request)
; SysExParamDesc_Panpot: PANPOT -- SysEx address 00 20 07 (Technics Reference Guide)
SysExParamDesc_Panpot:
;   area 00 adr 20 07  size 00 00 01  rec 00 off 08 mask 7F  range 0..127
	.byte 0x00, 0x20, 0x07, 0x00, 0x00, 0x01, 0x00, 0x08, 0x7f, 0x00, 0x7f, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51830  . ..............
	.long SysExTx_SendParamValue	; F51840  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51844  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51848  +0x18 reader (2B request)
; SysExParamDesc_KeyShift: KEY SHIFT -- SysEx address 00 20 08 (Technics Reference Guide)
SysExParamDesc_KeyShift:
;   area 00 adr 20 08  size 00 00 01  rec 00 off 09 mask 7F  range 28..100
	.byte 0x00, 0x20, 0x08, 0x00, 0x00, 0x01, 0x00, 0x09, 0x7f, 0x1c, 0x64, 0x00, 0x01, 0x00, 0xff, 0x00   ; F5184C  . ........d.....
	.long SysExTx_SendParamValue	; F5185C  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51860  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51864  +0x18 reader (2B request)
; SysExParamDesc_FineTune: FINE TUNE -- SysEx address 00 20 09 (Technics Reference Guide)
SysExParamDesc_FineTune:
;   area 00 adr 20 09  size 00 00 01  rec 00 off 0A mask FF  range 0..255
	.byte 0x00, 0x20, 0x09, 0x00, 0x00, 0x01, 0x00, 0x0a, 0xff, 0x00, 0xff, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51868  . ..............
	.long SysExTx_SendParamValue	; F51878  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F5187C  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51880  +0x18 reader (2B request)
; SysExParamDesc_PitchBendRange: PITCH BEND RANGE -- SysEx address 00 20 0A (Technics Reference Guide)
SysExParamDesc_PitchBendRange:
;   area 00 adr 20 0A  size 00 00 01  rec 00 off 0B mask 7F  range 0..12
	.byte 0x00, 0x20, 0x0a, 0x00, 0x00, 0x01, 0x00, 0x0b, 0x7f, 0x00, 0x0c, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51884  . ..............
	.long SysExTx_SendParamValue	; F51894  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51898  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F5189C  +0x18 reader (2B request)
; SysExParamDesc_AssignMode: ASSIGN MODE -- SysEx address 00 20 10 (Technics Reference Guide)
SysExParamDesc_AssignMode:
;   area 00 adr 20 10  size 00 00 01  rec 20 off 06 mask 0F  range 0..1
	.byte 0x00, 0x20, 0x10, 0x00, 0x00, 0x01, 0x20, 0x06, 0x0f, 0x00, 0x01, 0x00, 0x01, 0x00, 0xff, 0x00   ; F518A0  . .... .........
	.long SysExTx_SendParamValue	; F518B0  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F518B4  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F518B8  +0x18 reader (2B request)
; SysExParamDesc_KeyScaling: KEY SCALING -- SysEx address 00 20 14 (Technics Reference Guide)
SysExParamDesc_KeyScaling:
;   area 00 adr 20 14  size 00 00 01  rec 00 off 0C mask 08  range 0..1
	.byte 0x00, 0x20, 0x14, 0x00, 0x00, 0x01, 0x00, 0x0c, 0x08, 0x00, 0x01, 0x03, 0x01, 0x00, 0xff, 0x00   ; F518BC  . ..............
	.long SysExTx_SendParamValue	; F518CC  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F518D0  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F518D4  +0x18 reader (2B request)
; SysExParamDesc_VelocityOffset_2020: VELOCITY OFFSET -- SysEx address 00 20 20 (Technics Reference Guide)
SysExParamDesc_VelocityOffset_2020:
;   area 00 adr 20 20  size 00 00 01  rec 20 off 05 mask FF  range 0..48
	.byte 0x00, 0x20, 0x20, 0x00, 0x00, 0x01, 0x20, 0x05, 0xff, 0x00, 0x30, 0x00, 0x01, 0x00, 0xff, 0x00   ; F518D8  .  ... ...0.....
	.long SysExTx_SendParamValue	; F518E8  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F518EC  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F518F0  +0x18 reader (2B request)
; SysExParamDesc_KeyLayerLow: KEY LAYER LOW -- SysEx address 00 20 28 (Technics Reference Guide)
SysExParamDesc_KeyLayerLow:
;   area 00 adr 20 28  size 00 00 01  rec 20 off 07 mask 7F  range 0..127
	.byte 0x00, 0x20, 0x28, 0x00, 0x00, 0x01, 0x20, 0x07, 0x7f, 0x00, 0x7f, 0x00, 0x01, 0x00, 0xff, 0x00   ; F518F4  . (... .........
	.long SysExTx_SendParamValue	; F51904  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51908  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F5190C  +0x18 reader (2B request)
; SysExParamDesc_KeyLayerHigh: KEY LAYER HIGH -- SysEx address 00 20 29 (Technics Reference Guide)
SysExParamDesc_KeyLayerHigh:
;   area 00 adr 20 29  size 00 00 01  rec 20 off 08 mask 7F  range 0..127
	.byte 0x00, 0x20, 0x29, 0x00, 0x00, 0x01, 0x20, 0x08, 0x7f, 0x00, 0x7f, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51910  . )... .........
	.long SysExTx_SendParamValue	; F51920  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51924  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51928  +0x18 reader (2B request)
; SysExParamDesc_VelocityLayerLow: VELOCITY LAYER LOW -- SysEx address 00 20 2A (Technics Reference Guide)
SysExParamDesc_VelocityLayerLow:
;   area 00 adr 20 2A  size 00 00 01  rec 20 off 09 mask 7F  range 0..127
	.byte 0x00, 0x20, 0x2a, 0x00, 0x00, 0x01, 0x20, 0x09, 0x7f, 0x00, 0x7f, 0x00, 0x01, 0x00, 0xff, 0x00   ; F5192C  . *... .........
	.long SysExTx_SendParamValue	; F5193C  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51940  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51944  +0x18 reader (2B request)
; SysExParamDesc_VelocityLayerHigh: VELOCITY LAYER HIGH -- SysEx address 00 20 2B (Technics Reference Guide)
SysExParamDesc_VelocityLayerHigh:
;   area 00 adr 20 2B  size 00 00 01  rec 20 off 0A mask 7F  range 0..127
	.byte 0x00, 0x20, 0x2b, 0x00, 0x00, 0x01, 0x20, 0x0a, 0x7f, 0x00, 0x7f, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51948  . +... .........
	.long SysExTx_SendParamValue	; F51958  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F5195C  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51960  +0x18 reader (2B request)
; SysExParamDesc_MainOut: MAIN OUT -- SysEx address 00 20 30 (Technics Reference Guide)
SysExParamDesc_MainOut:
;   area 00 adr 20 30  size 00 00 01  rec 20 off 03 mask FF  range 0..1
	.byte 0x00, 0x20, 0x30, 0x00, 0x00, 0x01, 0x20, 0x03, 0xff, 0x00, 0x01, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51964  . 0... .........
	.long SysExTx_SendParamValue	; F51974  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51978  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F5197C  +0x18 reader (2B request)
; SysExParamDesc_SubOut: SUB OUT -- SysEx address 00 20 31 (Technics Reference Guide)
SysExParamDesc_SubOut:
;   area 00 adr 20 31  size 00 00 01  rec 20 off 04 mask FF  range 0..4
	.byte 0x00, 0x20, 0x31, 0x00, 0x00, 0x01, 0x20, 0x04, 0xff, 0x00, 0x04, 0x00, 0x01, 0x00, 0x03, 0x00   ; F51980  . 1... .........
	.long SysExTx_SendParamValue	; F51990  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51994  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51998  +0x18 reader (2B request)
	.byte 0x00, 0x02, 0x03, 0x04   ; F5199C  ....
; SysExParamDesc_LocalControl: LOCAL CONTROL -- SysEx address 00 20 40 (Technics Reference Guide)
SysExParamDesc_LocalControl:
;   area 00 adr 20 40  size 00 00 01  rec 00 off 0D mask 20  range 0..1
	.byte 0x00, 0x20, 0x40, 0x00, 0x00, 0x01, 0x00, 0x0d, 0x20, 0x00, 0x01, 0x05, 0x01, 0x00, 0xff, 0x00   ; F519A0  . @..... .......
	.long SysExTx_SendParamValue	; F519B0  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F519B4  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F519B8  +0x18 reader (2B request)
; SysExParamDesc_BasicChannel: BASIC CHANNEL -- SysEx address 00 20 41 (Technics Reference Guide)
SysExParamDesc_BasicChannel:
;   area 00 adr 20 41  size 00 00 01  rec 00 off 0D mask 1F  range 0..31
	.byte 0x00, 0x20, 0x41, 0x00, 0x00, 0x01, 0x00, 0x0d, 0x1f, 0x00, 0x1f, 0x00, 0x01, 0x00, 0xff, 0x00   ; F519BC  . A.............
	.long SysExTx_SendParamValue	; F519CC  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F519D0  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F519D4  +0x18 reader (2B request)
; SysExParamDesc_MidiOutSetting: MIDI OUT SETTING -- SysEx address 00 20 42 (Technics Reference Guide)
SysExParamDesc_MidiOutSetting:
;   area 00 adr 20 42  size 00 00 01  rec 00 off 0D mask 40  range 0..1
	.byte 0x00, 0x20, 0x42, 0x00, 0x00, 0x01, 0x00, 0x0d, 0x40, 0x00, 0x01, 0x06, 0x01, 0x00, 0xff, 0x00   ; F519D8  . B.....@.......
	.long SysExTx_SendParamValue	; F519E8  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F519EC  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F519F0  +0x18 reader (2B request)
; SysExParamDesc_MidiInSetting: MIDI IN SETTING -- SysEx address 00 20 43 (Technics Reference Guide)
SysExParamDesc_MidiInSetting:
;   area 00 adr 20 43  size 00 00 01  rec 00 off 0D mask 80  range 0..1
	.byte 0x00, 0x20, 0x43, 0x00, 0x00, 0x01, 0x00, 0x0d, 0x80, 0x00, 0x01, 0x07, 0x01, 0x00, 0xff, 0x00   ; F519F4  . C.............
	.long SysExTx_SendParamValue	; F51A04  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51A08  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51A0C  +0x18 reader (2B request)
; SysExParamDesc_MidiInputFilterProgramChange: MIDI INPUT FILTER: PROGRAM CHANGE -- SysEx address 00 20 48 (Technics Reference Guide)
SysExParamDesc_MidiInputFilterProgramChange:
;   area 00 adr 20 48  size 00 00 01  rec 20 off 0F mask 10  range 0..1
	.byte 0x00, 0x20, 0x48, 0x00, 0x00, 0x01, 0x20, 0x0f, 0x10, 0x00, 0x01, 0x04, 0x01, 0x00, 0xff, 0x00   ; F51A10  . H... .........
	.long SysExTx_SendParamValue	; F51A20  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51A24  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51A28  +0x18 reader (2B request)
; SysExParamDesc_MidiInputFilterBankSelect: MIDI INPUT FILTER: BANK SELECT -- SysEx address 00 20 49 (Technics Reference Guide)
SysExParamDesc_MidiInputFilterBankSelect:
;   area 00 adr 20 49  size 00 00 01  rec 20 off 10 mask 80  range 0..1
	.byte 0x00, 0x20, 0x49, 0x00, 0x00, 0x01, 0x20, 0x10, 0x80, 0x00, 0x01, 0x07, 0x01, 0x00, 0xff, 0x00   ; F51A2C  . I... .........
	.long SysExTx_SendParamValue	; F51A3C  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51A40  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51A44  +0x18 reader (2B request)
; SysExParamDesc_MidiInputFilterVolume: MIDI INPUT FILTER: VOLUME -- SysEx address 00 20 4A (Technics Reference Guide)
SysExParamDesc_MidiInputFilterVolume:
;   area 00 adr 20 4A  size 00 00 01  rec 20 off 10 mask 04  range 0..1
	.byte 0x00, 0x20, 0x4a, 0x00, 0x00, 0x01, 0x20, 0x10, 0x04, 0x00, 0x01, 0x02, 0x01, 0x00, 0xff, 0x00   ; F51A48  . J... .........
	.long SysExTx_SendParamValue	; F51A58  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51A5C  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51A60  +0x18 reader (2B request)
; SysExParamDesc_MidiOutputFilterProgramChange: MIDI OUTPUT FILTER: PROGRAM CHANGE -- SysEx address 00 20 50 (Technics Reference Guide)
SysExParamDesc_MidiOutputFilterProgramChange:
;   area 00 adr 20 50  size 00 00 01  rec 20 off 13 mask 10  range 0..1
	.byte 0x00, 0x20, 0x50, 0x00, 0x00, 0x01, 0x20, 0x13, 0x10, 0x00, 0x01, 0x04, 0x01, 0x00, 0xff, 0x00   ; F51A64  . P... .........
	.long SysExTx_SendParamValue	; F51A74  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51A78  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51A7C  +0x18 reader (2B request)
; SysExParamDesc_MidiOutputFilterBankSelect: MIDI OUTPUT FILTER: BANK SELECT -- SysEx address 00 20 51 (Technics Reference Guide)
SysExParamDesc_MidiOutputFilterBankSelect:
;   area 00 adr 20 51  size 00 00 01  rec 20 off 14 mask 80  range 0..1
	.byte 0x00, 0x20, 0x51, 0x00, 0x00, 0x01, 0x20, 0x14, 0x80, 0x00, 0x01, 0x07, 0x01, 0x00, 0xff, 0x00   ; F51A80  . Q... .........
	.long SysExTx_SendParamValue	; F51A90  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51A94  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51A98  +0x18 reader (2B request)
; SysExParamDesc_MidiOutputFilterVolume: MIDI OUTPUT FILTER: VOLUME -- SysEx address 00 20 52 (Technics Reference Guide)
SysExParamDesc_MidiOutputFilterVolume:
;   area 00 adr 20 52  size 00 00 01  rec 20 off 14 mask 04  range 0..1
	.byte 0x00, 0x20, 0x52, 0x00, 0x00, 0x01, 0x20, 0x14, 0x04, 0x00, 0x01, 0x02, 0x01, 0x00, 0xff, 0x00   ; F51A9C  . R... .........
	.long SysExTx_SendParamValue	; F51AAC  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51AB0  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51AB4  +0x18 reader (2B request)
; SysExParamDesc_MidiOutputFilterPanpot: MIDI OUTPUT FILTER: PANPOT -- SysEx address 00 20 53 (Technics Reference Guide)
SysExParamDesc_MidiOutputFilterPanpot:
;   area 00 adr 20 53  size 00 00 01  rec 20 off 14 mask 10  range 0..1
	.byte 0x00, 0x20, 0x53, 0x00, 0x00, 0x01, 0x20, 0x14, 0x10, 0x00, 0x01, 0x04, 0x01, 0x00, 0xff, 0x00   ; F51AB8  . S... .........
	.long SysExTx_SendParamValue	; F51AC8  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51ACC  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51AD0  +0x18 reader (2B request)
; SysExParamDesc_MidiOutputFilterEffectDepth: MIDI OUTPUT FILTER: EFFECT DEPTH -- SysEx address 00 20 54 (Technics Reference Guide)
SysExParamDesc_MidiOutputFilterEffectDepth:
;   area 00 adr 20 54  size 00 00 01  rec 20 off 14 mask 20  range 0..1
	.byte 0x00, 0x20, 0x54, 0x00, 0x00, 0x01, 0x20, 0x14, 0x20, 0x00, 0x01, 0x05, 0x01, 0x00, 0xff, 0x00   ; F51AD4  . T... . .......
	.long SysExTx_SendParamValue	; F51AE4  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51AE8  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51AEC  +0x18 reader (2B request)
; SysExParamDesc_MidiOutputFilterPitchBend: MIDI OUTPUT FILTER: PITCH BEND -- SysEx address 00 20 55 (Technics Reference Guide)
SysExParamDesc_MidiOutputFilterPitchBend:
;   area 00 adr 20 55  size 00 00 01  rec 20 off 13 mask 40  range 0..1
	.byte 0x00, 0x20, 0x55, 0x00, 0x00, 0x01, 0x20, 0x13, 0x40, 0x00, 0x01, 0x06, 0x01, 0x00, 0xff, 0x00   ; F51AF0  . U... .@.......
	.long SysExTx_SendParamValue	; F51B00  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51B04  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51B08  +0x18 reader (2B request)
; SysExParamDesc_MidiOutputFilterModulation1: MIDI OUTPUT FILTER: MODULATION1 -- SysEx address 00 20 56 (Technics Reference Guide)
SysExParamDesc_MidiOutputFilterModulation1:
;   area 00 adr 20 56  size 00 00 01  rec 20 off 14 mask 02  range 0..1
	.byte 0x00, 0x20, 0x56, 0x00, 0x00, 0x01, 0x20, 0x14, 0x02, 0x00, 0x01, 0x01, 0x01, 0x00, 0xff, 0x00   ; F51B0C  . V... .........
	.long SysExTx_SendParamValue	; F51B1C  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51B20  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51B24  +0x18 reader (2B request)
; SysExParamDesc_MidiOutputFilterModulation2: MIDI OUTPUT FILTER: MODULATION2 -- SysEx address 00 20 57 (Technics Reference Guide)
SysExParamDesc_MidiOutputFilterModulation2:
;   area 00 adr 20 57  size 00 00 01  rec 20 off 16 mask 10  range 0..1
	.byte 0x00, 0x20, 0x57, 0x00, 0x00, 0x01, 0x20, 0x16, 0x10, 0x00, 0x01, 0x04, 0x01, 0x00, 0xff, 0x00   ; F51B28  . W... .........
	.long SysExTx_SendParamValue	; F51B38  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51B3C  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51B40  +0x18 reader (2B request)
; SysExParamDesc_MidiOutputFilterRealTimeCreatorX: MIDI OUTPUT FILTER: REAL-TIME CREATOR-X -- SysEx address 00 20 58 (Technics Reference Guide)
SysExParamDesc_MidiOutputFilterRealTimeCreatorX:
;   area 00 adr 20 58  size 00 00 01  rec 20 off 16 mask 01  range 0..1
	.byte 0x00, 0x20, 0x58, 0x00, 0x00, 0x01, 0x20, 0x16, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51B44  . X... .........
	.long SysExTx_SendParamValue	; F51B54  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51B58  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51B5C  +0x18 reader (2B request)
; SysExParamDesc_MidiOutputFilterRealTimeCreatorY: MIDI OUTPUT FILTER: REAL-TIME CREATOR-Y -- SysEx address 00 20 59 (Technics Reference Guide)
SysExParamDesc_MidiOutputFilterRealTimeCreatorY:
;   area 00 adr 20 59  size 00 00 01  rec 20 off 16 mask 02  range 0..1
	.byte 0x00, 0x20, 0x59, 0x00, 0x00, 0x01, 0x20, 0x16, 0x02, 0x00, 0x01, 0x01, 0x01, 0x00, 0xff, 0x00   ; F51B60  . Y... .........
	.long SysExTx_SendParamValue	; F51B70  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51B74  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51B78  +0x18 reader (2B request)
; SysExParamDesc_MidiOutputFilterRealTimeControllerX: MIDI OUTPUT FILTER: REAL-TIME CONTROLLER-X -- SysEx address 00 20 5A (Technics Reference Guide)
SysExParamDesc_MidiOutputFilterRealTimeControllerX:
;   area 00 adr 20 5A  size 00 00 01  rec 20 off 16 mask 04  range 0..1
	.byte 0x00, 0x20, 0x5a, 0x00, 0x00, 0x01, 0x20, 0x16, 0x04, 0x00, 0x01, 0x02, 0x01, 0x00, 0xff, 0x00   ; F51B7C  . Z... .........
	.long SysExTx_SendParamValue	; F51B8C  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51B90  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51B94  +0x18 reader (2B request)
; SysExParamDesc_MidiOutputFilterRealTimeControllerY: MIDI OUTPUT FILTER: REAL-TIME CONTROLLER-Y -- SysEx address 00 20 5B (Technics Reference Guide)
SysExParamDesc_MidiOutputFilterRealTimeControllerY:
;   area 00 adr 20 5B  size 00 00 01  rec 20 off 16 mask 08  range 0..1
	.byte 0x00, 0x20, 0x5b, 0x00, 0x00, 0x01, 0x20, 0x16, 0x08, 0x00, 0x01, 0x03, 0x01, 0x00, 0xff, 0x00   ; F51B98  . [... .........
	.long SysExTx_SendParamValue	; F51BA8  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51BAC  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51BB0  +0x18 reader (2B request)
; SysExParamDesc_MidiOutputFilterHold1: MIDI OUTPUT FILTER: HOLD1 -- SysEx address 00 20 5C (Technics Reference Guide)
SysExParamDesc_MidiOutputFilterHold1:
;   area 00 adr 20 5C  size 00 00 01  rec 20 off 14 mask 01  range 0..1
	.byte 0x00, 0x20, 0x5c, 0x00, 0x00, 0x01, 0x20, 0x14, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51BB4  . \... .........
	.long SysExTx_SendParamValue	; F51BC4  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51BC8  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51BCC  +0x18 reader (2B request)
; SysExParamDesc_MidiOutputFilterControlPedal: MIDI OUTPUT FILTER: CONTROL PEDAL -- SysEx address 00 20 5D (Technics Reference Guide)
SysExParamDesc_MidiOutputFilterControlPedal:
;   area 00 adr 20 5D  size 00 00 01  rec 20 off 16 mask 20  range 0..1
	.byte 0x00, 0x20, 0x5d, 0x00, 0x00, 0x01, 0x20, 0x16, 0x20, 0x00, 0x01, 0x05, 0x01, 0x00, 0xff, 0x00   ; F51BD0  . ]... . .......
	.long SysExTx_SendParamValue	; F51BE0  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51BE4  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51BE8  +0x18 reader (2B request)
; SysExParamDesc_MidiOutputFilterAfterTouch: MIDI OUTPUT FILTER: AFTER TOUCH -- SysEx address 00 20 5E (Technics Reference Guide)
SysExParamDesc_MidiOutputFilterAfterTouch:
;   area 00 adr 20 5E  size 00 00 01  rec 20 off 13 mask 20  range 0..1
	.byte 0x00, 0x20, 0x5e, 0x00, 0x00, 0x01, 0x20, 0x13, 0x20, 0x00, 0x01, 0x05, 0x01, 0x00, 0xff, 0x00   ; F51BEC  . ^... . .......
	.long SysExTx_SendParamValue	; F51BFC  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51C00  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51C04  +0x18 reader (2B request)
; SysExParamDesc_MidiMultipleMessagesOutputProgramChange: MIDI MULTIPLE MESSAGES OUTPUT: PROGRAM CHANGE -- SysEx address 00 20 60 (Technics Reference Guide)
SysExParamDesc_MidiMultipleMessagesOutputProgramChange:
;   area 00 adr 20 60  size 00 00 01  rec 00 off 0E mask FF  range 0..129
	.byte 0x00, 0x20, 0x60, 0x00, 0x00, 0x01, 0x00, 0x0e, 0xff, 0x00, 0x81, 0x00, 0x01, 0x00, 0x00, 0x00   ; F51C08  . `.............
	.long SysExTx_SendParamValue	; F51C18  +0x10 transmit-on-change
	.long SysExParam_SetMidiMultipleMessagesOutput	; F51C1C  +0x14 setter (2C)
	.long SysExParam_GetMidiMultipleMessagesOutput	; F51C20  +0x18 reader (2B request)
	.byte 0x00, 0x15, 0x01, 0x01   ; F51C24  ....
; SysExParamDesc_MidiMultipleMessagesOutputBankSelect: MIDI MULTIPLE MESSAGES OUTPUT: BANK SELECT -- SysEx address 00 20 61 (Technics Reference Guide)
SysExParamDesc_MidiMultipleMessagesOutputBankSelect:
;   area 00 adr 20 61  size 00 00 02  rec 00 off 0F mask FF  range 0..129
	.byte 0x00, 0x20, 0x61, 0x00, 0x00, 0x02, 0x00, 0x0f, 0xff, 0x00, 0x81, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51C28  . a.............
	.long SysExTx_SendParamValue	; F51C38  +0x10 transmit-on-change
	.long SysExParam_SetMidiMultipleMessagesOutputBankSelect	; F51C3C  +0x14 setter (2C)
	.long SysExParam_GetMidiMultipleMessagesOutputBankSelect	; F51C40  +0x18 reader (2B request)
; SysExParamDesc_MidiMultipleMessagesOutputVolume: MIDI MULTIPLE MESSAGES OUTPUT: VOLUME -- SysEx address 00 20 63 (Technics Reference Guide)
SysExParamDesc_MidiMultipleMessagesOutputVolume:
;   area 00 adr 20 63  size 00 00 01  rec 00 off 11 mask FF  range 0..129
	.byte 0x00, 0x20, 0x63, 0x00, 0x00, 0x01, 0x00, 0x11, 0xff, 0x00, 0x81, 0x00, 0x01, 0x00, 0x01, 0x00   ; F51C44  . c.............
	.long SysExTx_SendParamValue	; F51C54  +0x10 transmit-on-change
	.long SysExParam_SetMidiMultipleMessagesOutput	; F51C58  +0x14 setter (2C)
	.long SysExParam_GetMidiMultipleMessagesOutput	; F51C5C  +0x18 reader (2B request)
	.byte 0x00, 0x15, 0x02, 0x02   ; F51C60  ....
; SysExParamDesc_MidiMultipleMessagesOutputPanpot: MIDI MULTIPLE MESSAGES OUTPUT: PANPOT -- SysEx address 00 20 64 (Technics Reference Guide)
SysExParamDesc_MidiMultipleMessagesOutputPanpot:
;   area 00 adr 20 64  size 00 00 01  rec 00 off 12 mask FF  range 0..129
	.byte 0x00, 0x20, 0x64, 0x00, 0x00, 0x01, 0x00, 0x12, 0xff, 0x00, 0x81, 0x00, 0x01, 0x00, 0x02, 0x00   ; F51C64  . d.............
	.long SysExTx_SendParamValue	; F51C74  +0x10 transmit-on-change
	.long SysExParam_SetMidiMultipleMessagesOutput	; F51C78  +0x14 setter (2C)
	.long SysExParam_GetMidiMultipleMessagesOutput	; F51C7C  +0x18 reader (2B request)
	.byte 0x00, 0x15, 0x04, 0x04   ; F51C80  ....
; SysExParamDesc_MidiMultipleMessagesOutputReverbDepth: MIDI MULTIPLE MESSAGES OUTPUT: REVERB DEPTH -- SysEx address 00 20 65 (Technics Reference Guide)
SysExParamDesc_MidiMultipleMessagesOutputReverbDepth:
;   area 00 adr 20 65  size 00 00 01  rec 00 off 14 mask FF  range 0..129
	.byte 0x00, 0x20, 0x65, 0x00, 0x00, 0x01, 0x00, 0x14, 0xff, 0x00, 0x81, 0x00, 0x01, 0x00, 0x03, 0x00   ; F51C84  . e.............
	.long SysExTx_SendParamValue	; F51C94  +0x10 transmit-on-change
	.long SysExParam_SetMidiMultipleMessagesOutput	; F51C98  +0x14 setter (2C)
	.long SysExParam_GetMidiMultipleMessagesOutput	; F51C9C  +0x18 reader (2B request)
	.byte 0x00, 0x15, 0x10, 0x10   ; F51CA0  ....
; SysExParamDesc_MidiMultipleMessagesOutputChorusDepth: MIDI MULTIPLE MESSAGES OUTPUT: CHORUS DEPTH -- SysEx address 00 20 66 (Technics Reference Guide)
SysExParamDesc_MidiMultipleMessagesOutputChorusDepth:
;   area 00 adr 20 66  size 00 00 01  rec 00 off 13 mask FF  range 0..129
	.byte 0x00, 0x20, 0x66, 0x00, 0x00, 0x01, 0x00, 0x13, 0xff, 0x00, 0x81, 0x00, 0x01, 0x00, 0x04, 0x00   ; F51CA4  . f.............
	.long SysExTx_SendParamValue	; F51CB4  +0x10 transmit-on-change
	.long SysExParam_SetMidiMultipleMessagesOutput	; F51CB8  +0x14 setter (2C)
	.long SysExParam_GetMidiMultipleMessagesOutput	; F51CBC  +0x18 reader (2B request)
	.byte 0x00, 0x15, 0x08, 0x08   ; F51CC0  ....
; SysExParamDesc_MidiOutKeyTranspose: MIDI OUT KEY TRANSPOSE -- SysEx address 00 20 68 (Technics Reference Guide)
SysExParamDesc_MidiOutKeyTranspose:
;   area 00 adr 20 68  size 00 00 01  rec 20 off 17 mask FF  range 28..100
	.byte 0x00, 0x20, 0x68, 0x00, 0x00, 0x01, 0x20, 0x17, 0xff, 0x1c, 0x64, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51CC4  . h... ...d.....
	.long SysExTx_SendParamValue	; F51CD4  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51CD8  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51CDC  +0x18 reader (2B request)
; SysExParamDesc_ControllerInternalFilterPitchBend: CONTROLLER INTERNAL FILTER: PITCH BEND -- SysEx address 00 20 70 (Technics Reference Guide)
SysExParamDesc_ControllerInternalFilterPitchBend:
;   area 00 adr 20 70  size 00 00 01  rec 20 off 0B mask 40  range 0..1
	.byte 0x00, 0x20, 0x70, 0x00, 0x00, 0x01, 0x20, 0x0b, 0x40, 0x00, 0x01, 0x06, 0x01, 0x00, 0xff, 0x00   ; F51CE0  . p... .@.......
	.long SysExTx_SendParamValue	; F51CF0  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51CF4  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51CF8  +0x18 reader (2B request)
; SysExParamDesc_ControllerInternalFilterModulation1: CONTROLLER INTERNAL FILTER: MODULATION1 -- SysEx address 00 20 71 (Technics Reference Guide)
SysExParamDesc_ControllerInternalFilterModulation1:
;   area 00 adr 20 71  size 00 00 01  rec 20 off 0C mask 02  range 0..1
	.byte 0x00, 0x20, 0x71, 0x00, 0x00, 0x01, 0x20, 0x0c, 0x02, 0x00, 0x01, 0x01, 0x01, 0x00, 0xff, 0x00   ; F51CFC  . q... .........
	.long SysExTx_SendParamValue	; F51D0C  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51D10  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51D14  +0x18 reader (2B request)
; SysExParamDesc_ControllerInternalFilterModulation2: CONTROLLER INTERNAL FILTER: MODULATION2 -- SysEx address 00 20 72 (Technics Reference Guide)
SysExParamDesc_ControllerInternalFilterModulation2:
;   area 00 adr 20 72  size 00 00 01  rec 20 off 0E mask 10  range 0..1
	.byte 0x00, 0x20, 0x72, 0x00, 0x00, 0x01, 0x20, 0x0e, 0x10, 0x00, 0x01, 0x04, 0x01, 0x00, 0xff, 0x00   ; F51D18  . r... .........
	.long SysExTx_SendParamValue	; F51D28  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51D2C  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51D30  +0x18 reader (2B request)
; SysExParamDesc_ControllerInternalFilterRealTimeCreatorX: CONTROLLER INTERNAL FILTER: REAL-TIME CREATOR-X -- SysEx address 00 20 73 (Technics Reference Guide)
SysExParamDesc_ControllerInternalFilterRealTimeCreatorX:
;   area 00 adr 20 73  size 00 00 01  rec 20 off 0E mask 01  range 0..1
	.byte 0x00, 0x20, 0x73, 0x00, 0x00, 0x01, 0x20, 0x0e, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51D34  . s... .........
	.long SysExTx_SendParamValue	; F51D44  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51D48  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51D4C  +0x18 reader (2B request)
; SysExParamDesc_ControllerInternalFilterRealTimeCreatorY: CONTROLLER INTERNAL FILTER: REAL-TIME CREATOR-Y -- SysEx address 00 20 74 (Technics Reference Guide)
SysExParamDesc_ControllerInternalFilterRealTimeCreatorY:
;   area 00 adr 20 74  size 00 00 01  rec 20 off 0E mask 02  range 0..1
	.byte 0x00, 0x20, 0x74, 0x00, 0x00, 0x01, 0x20, 0x0e, 0x02, 0x00, 0x01, 0x01, 0x01, 0x00, 0xff, 0x00   ; F51D50  . t... .........
	.long SysExTx_SendParamValue	; F51D60  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51D64  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51D68  +0x18 reader (2B request)
; SysExParamDesc_ControllerInternalFilterRealTimeControllerX: CONTROLLER INTERNAL FILTER: REAL-TIME CONTROLLER-X -- SysEx address 00 20 75 (Technics Reference Guide)
SysExParamDesc_ControllerInternalFilterRealTimeControllerX:
;   area 00 adr 20 75  size 00 00 01  rec 20 off 0E mask 04  range 0..1
	.byte 0x00, 0x20, 0x75, 0x00, 0x00, 0x01, 0x20, 0x0e, 0x04, 0x00, 0x01, 0x02, 0x01, 0x00, 0xff, 0x00   ; F51D6C  . u... .........
	.long SysExTx_SendParamValue	; F51D7C  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51D80  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51D84  +0x18 reader (2B request)
; SysExParamDesc_ControllerInternalFilterRealTimeControllerY: CONTROLLER INTERNAL FILTER: REAL-TIME CONTROLLER-Y -- SysEx address 00 20 76 (Technics Reference Guide)
SysExParamDesc_ControllerInternalFilterRealTimeControllerY:
;   area 00 adr 20 76  size 00 00 01  rec 20 off 0E mask 08  range 0..1
	.byte 0x00, 0x20, 0x76, 0x00, 0x00, 0x01, 0x20, 0x0e, 0x08, 0x00, 0x01, 0x03, 0x01, 0x00, 0xff, 0x00   ; F51D88  . v... .........
	.long SysExTx_SendParamValue	; F51D98  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51D9C  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51DA0  +0x18 reader (2B request)
; SysExParamDesc_ControllerInternalFilterHold1: CONTROLLER INTERNAL FILTER: HOLD1 -- SysEx address 00 20 77 (Technics Reference Guide)
SysExParamDesc_ControllerInternalFilterHold1:
;   area 00 adr 20 77  size 00 00 01  rec 20 off 0C mask 01  range 0..1
	.byte 0x00, 0x20, 0x77, 0x00, 0x00, 0x01, 0x20, 0x0c, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51DA4  . w... .........
	.long SysExTx_SendParamValue	; F51DB4  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51DB8  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51DBC  +0x18 reader (2B request)
; SysExParamDesc_ControllerInternalFilterControlPedal: CONTROLLER INTERNAL FILTER: CONTROL PEDAL -- SysEx address 00 20 78 (Technics Reference Guide)
SysExParamDesc_ControllerInternalFilterControlPedal:
;   area 00 adr 20 78  size 00 00 01  rec 20 off 0E mask 20  range 0..1
	.byte 0x00, 0x20, 0x78, 0x00, 0x00, 0x01, 0x20, 0x0e, 0x20, 0x00, 0x01, 0x05, 0x01, 0x00, 0xff, 0x00   ; F51DC0  . x... . .......
	.long SysExTx_SendParamValue	; F51DD0  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51DD4  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51DD8  +0x18 reader (2B request)
; SysExParamDesc_ControllerInternalFilterAfterTouch: CONTROLLER INTERNAL FILTER: AFTER TOUCH -- SysEx address 00 20 79 (Technics Reference Guide)
SysExParamDesc_ControllerInternalFilterAfterTouch:
;   area 00 adr 20 79  size 00 00 01  rec 20 off 0B mask 20  range 0..1
	.byte 0x00, 0x20, 0x79, 0x00, 0x00, 0x01, 0x20, 0x0b, 0x20, 0x00, 0x01, 0x05, 0x01, 0x00, 0xff, 0x00   ; F51DDC  . y... . .......
	.long SysExTx_SendParamValue	; F51DEC  +0x10 transmit-on-change
	.long SysExParam_SetPartField	; F51DF0  +0x14 setter (2C)
	.long SysExParam_GetPartField	; F51DF4  +0x18 reader (2B request)
; SysExParamDesc_MetronomeVolume: METRONOME VOLUME -- SysEx address 00 60 00 (Technics Reference Guide)
SysExParamDesc_MetronomeVolume:
;   area 00 adr 60 00  size 00 00 01  rec 98 off 03 mask 7F  range 0..127
	.byte 0x00, 0x60, 0x00, 0x00, 0x00, 0x01, 0x98, 0x03, 0x7f, 0x00, 0x7f, 0x00, 0x01, 0x00, 0xff, 0x00   ; F51DF8  .`..............
	.long SysExTx_SendParamValue	; F51E08  +0x10 transmit-on-change
	.long SysExParam_SetCommonField	; F51E0C  +0x14 setter (2C)
	.long SysExParam_GetCommonField	; F51E10  +0x18 reader (2B request)
	.byte 0xf9, 0x11, 0xf5, 0x00   ; F51E14  ....
	.byte 0xf9, 0x11, 0xf5, 0x00, 0x00, 0x00, 0x00, 0x00   ; F51E18  ........

; --- 0xF51E20-0xF51E2B  ptrtab (12 bytes) ---

; --------------------------------------------------------------------------
; Pointer_F51E20 -- 1 32-bit pointer, 0 into prom_a and 1 into prom_b
; Read by: prom_a 0xFB4C4E `lda_24 xbc, (0xf51e20)`
; Entry count: 1, measured by abutment: 1 x 4 = 4 bytes reaches 0xF51E24
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
Pointer_F51E20:
	.long SysExParamDesc_Placeholder                       ; F51E20  [0]   -> 0xF511F9

; --------------------------------------------------------------------------
; Pointer_F51E24 -- 1 32-bit pointer, 0 into prom_a and 1 into prom_b
; Read by: prom_a 0xFB4C82 `lda_24 xbc, (0xf51e24)`
; Entry count: 1, measured by abutment: 1 x 4 = 4 bytes reaches 0xF51E28
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
Pointer_F51E24:
	.long SysExParamDesc_Placeholder                       ; F51E24  [0]   -> 0xF511F9

; --------------------------------------------------------------------------
; Pointer_F51E28 -- 1 32-bit pointer, 0 into prom_a and 1 into prom_b
; Read by: prom_a 0xFB4CF3 `lda_24 xbc, (0xf51e28)`
; Entry count: 1, measured by abutment: 1 x 4 = 4 bytes reaches 0xF51E2C
;              exactly, which is the end of the segment.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
Pointer_F51E28:
	.long SysExParamDesc_Placeholder                       ; F51E28  [0]   -> 0xF511F9

; --- 0xF51E2C-0xF51E6B  data (64 bytes) ---
	.byte 0x00, 0x00, 0x00, 0x00, 0xf9, 0x11, 0xf5, 0x00, 0x38, 0x7f, 0x00, 0x00, 0x08, 0x08, 0x38, 0x7f   ; F51E2C  ........8.....8.
	.byte 0x00, 0x00, 0x08, 0x08, 0x38, 0x7f, 0x00, 0x00, 0x04, 0x04, 0x38, 0x7f, 0x00, 0x00, 0x08, 0x08   ; F51E3C  ....8.....8.....
	.byte 0x3b, 0x7f, 0x00, 0x00, 0x20, 0x20, 0x3b, 0x7f, 0x00, 0x00, 0x40, 0x40, 0x04, 0x00, 0xf5, 0x12   ; F51E4C  ;...  ;...@@....
	.byte 0xf5, 0x00, 0x00, 0x00, 0xd6, 0x7f, 0x00, 0x00, 0x0f, 0x00, 0x47, 0x15, 0xf5, 0x00, 0x04, 0x00   ; F51E5C  ..........G.....

; --- 0xF51E6C-0xF51E87  romtab (28 bytes) ---

; --------------------------------------------------------------------------
; Pointer_F51E6C -- 1 32-bit pointer, 0 into prom_a and 1 into prom_b
; Read by: it is the head of a segment and nothing names it directly -- the
;          addresses prom_a does name inside it are labelled below.
;          Measured: no instruction in the PROVEN text of either image
;          spells it; its 32-bit spelling occurs 0 time(s) in the prom_a
;          image and 0 in prom_b, counted over the raw bytes.
; Entry count: 1, measured by abutment: 1 x 4 = 4 bytes reaches 0xF51E70
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
Pointer_F51E6C:
	.long RecordArray_F511DD + 0x7BF                       ; F51E6C  [0]   -> 0xF5199C

; --------------------------------------------------------------------------
; PtrTable_F51E70 -- 5 32-bit pointers, 0 into prom_a and 5 into prom_b
; Read by: prom_a 0xFB3B39 `add XWA,0x00f51e70`; prom_a 0xFB47BD `add
;          XWA,0x00f51e70`
; Entry count: 5, measured by abutment: 5 x 4 = 20 bytes reaches 0xF51E84
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
PtrTable_F51E70:
	.long RecordArray_F511DD + 0xA47                       ; F51E70  [0]   -> 0xF51C24
	.long RecordArray_F511DD + 0xA83                       ; F51E74  [1]   -> 0xF51C60
	.long RecordArray_F511DD + 0xAA3                       ; F51E78  [2]   -> 0xF51C80
	.long RecordArray_F511DD + 0xAC3                       ; F51E7C  [3]   -> 0xF51CA0
	.long RecordArray_F511DD + 0xAE3                       ; F51E80  [4]   -> 0xF51CC0

; --------------------------------------------------------------------------
; Pointer_F51E84 -- 1 32-bit pointer, 0 into prom_a and 1 into prom_b
; Read by: prom_a 0xFB3D4D `add XWA,0x00f51e84`; prom_a 0xFB49A9 `add
;          XBC,0x00f51e84`
; Entry count: 1, measured by abutment: 1 x 4 = 4 bytes reaches 0xF51E88
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
Pointer_F51E84:
	.long RecordArray_F511DD + 0x635                       ; F51E84  [0]   -> 0xF51812

; --- 0xF51E88-0xF51E89  data (2 bytes) ---

; --------------------------------------------------------------------------
; RecordIndex_Count -- the two bytes 0x02 0x00 in front of
;           RecordIndex_F51E8A
; Evidence: prom_a 0xFB4288 does `add XBC,0x00f51e88`.
; Unknown: 0x0002 is not 225, so it is NOT the entry count of the table
;          behind it.  The layout's HOLES table calls it "a count word";
;          that reading is not supported and is corrected here to a
;          stated gap.
; --------------------------------------------------------------------------
RecordIndex_Count:
	.byte 0x02, 0x00   ; F51E88  ..

; --- 0xF51E8A-0xF5220D  romtab (900 bytes) ---

; --------------------------------------------------------------------------
; RecordIndex_F51E8A -- 225 pointers into RecordArray_F511DD
; Evidence: all 225 entries land inside 0xF511DD-0xF51E1F, and they
;           resolve to 110 distinct addresses; 0xF51E8A + 225*4 =
;           0xF5220E, exactly where the 0x0E padding run begins.
; Read by: prom_a spells 8 addresses inside it (`add XWA,0x00f51e8e`
;          at 0xFB3578 and seven more at a 0x5C/0x50 spacing), so the
;          225 entries are read as several sub-arrays, not one.
; Unknown: where each sub-array starts and how long it is.
; --------------------------------------------------------------------------
RecordIndex_F51E8A:
	.long RecordArray_F511DD + 0x2DC                       ; F51E8A  [0]   -> 0xF514B9

; --------------------------------------------------------------------------
; PtrTable_F51E8E -- 23 32-bit pointers, 0 into prom_a and 23 into prom_b
; Read by: prom_a 0xFB3578 `add XWA,0x00f51e8e`; prom_a 0xFB358B `lda_24
;          xbc, (0xf51e8e)`
; Entry count: 23, measured by abutment: 23 x 4 = 92 bytes reaches 0xF51EEA
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
PtrTable_F51E8E:
	.long SysExParamDesc_Placeholder                       ; F51E8E  [0]   -> 0xF511F9
	.long SysExParamDesc_SoundMemoryProtect                       ; F51E92  [1]   -> 0xF51215
	.long SysExParamDesc_CombinationMemoryProtect                       ; F51E96  [2]   -> 0xF51231
	.long SysExParamDesc_MasterTuning                       ; F51E9A  [3]   -> 0xF5124D
	.long SysExParamDesc_VelocityCurve                       ; F51E9E  [4]   -> 0xF51269
	.long SysExParamDesc_VelocityOffset_0011                       ; F51EA2  [5]   -> 0xF51285
	.long SysExParamDesc_AfterTouchCurve                       ; F51EA6  [6]   -> 0xF512A1
	.long SysExParamDesc_AfterTouchThreshold                       ; F51EAA  [7]   -> 0xF512BD
	.long SysExParamDesc_DrumsMapSelect                       ; F51EAE  [8]   -> 0xF512D9
	.long SysExParamDesc_DataLoadFilterEffectAndOutput                       ; F51EB2  [9]   -> 0xF512F9
	.long SysExParamDesc_DataLoadFilterRealTimeCreator16                       ; F51EB6  [10]   -> 0xF51315
	.long SysExParamDesc_DataLoadFilterCombinationOctave                       ; F51EBA  [11]   -> 0xF51331
	.long SysExParamDesc_DataLoadFilterMidiSetting                       ; F51EBE  [12]   -> 0xF5134D
	.long SysExParamDesc_DataLoadFilterKeyAndVelocityLayer                       ; F51EC2  [13]   -> 0xF51369
	.long SysExParamDesc_DataLoadFilterMainOutEqualizer                       ; F51EC6  [14]   -> 0xF51385
	.long SysExParamDesc_DataLoadFilterKeyScaling                       ; F51ECA  [15]   -> 0xF513A1
	.long SysExParamDesc_CombinationNumberAndBank                       ; F51ECE  [16]   -> 0xF513BD
	.long SysExParamDesc_MidiInputMode                       ; F51ED2  [17]   -> 0xF513D9
	.long SysExParamDesc_MidiOutputMode                       ; F51ED6  [18]   -> 0xF513F5
	.long SysExParamDesc_SingleChannel                       ; F51EDA  [19]   -> 0xF51411
	.long SysExParamDesc_LocalTotal                       ; F51EDE  [20]   -> 0xF5142D
	.long SysExParamDesc_ProgramChangeMode                       ; F51EE2  [21]   -> 0xF51449
	.long SysExParamDesc_SingleChannelProgramChange                       ; F51EE6  [22]   -> 0xF51465

; --------------------------------------------------------------------------
; PtrTable_F51EEA -- 23 32-bit pointers, 0 into prom_a and 23 into prom_b
; Read by: prom_a 0xFB4332 `add XWA,0x00f51eea`; prom_a 0xFB4345 `lda_24
;          xbc, (0xf51eea)`
; Entry count: 23, measured by abutment: 23 x 4 = 92 bytes reaches 0xF51F46
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
PtrTable_F51EEA:
	.long SysExParamDesc_Placeholder                       ; F51EEA  [0]   -> 0xF511F9
	.long SysExParamDesc_SoundMemoryProtect                       ; F51EEE  [1]   -> 0xF51215
	.long SysExParamDesc_CombinationMemoryProtect                       ; F51EF2  [2]   -> 0xF51231
	.long SysExParamDesc_MasterTuning                       ; F51EF6  [3]   -> 0xF5124D
	.long SysExParamDesc_VelocityCurve                       ; F51EFA  [4]   -> 0xF51269
	.long SysExParamDesc_VelocityOffset_0011                       ; F51EFE  [5]   -> 0xF51285
	.long SysExParamDesc_AfterTouchCurve                       ; F51F02  [6]   -> 0xF512A1
	.long SysExParamDesc_AfterTouchThreshold                       ; F51F06  [7]   -> 0xF512BD
	.long SysExParamDesc_DrumsMapSelect                       ; F51F0A  [8]   -> 0xF512D9
	.long SysExParamDesc_DataLoadFilterEffectAndOutput                       ; F51F0E  [9]   -> 0xF512F9
	.long SysExParamDesc_DataLoadFilterRealTimeCreator16                       ; F51F12  [10]   -> 0xF51315
	.long SysExParamDesc_DataLoadFilterCombinationOctave                       ; F51F16  [11]   -> 0xF51331
	.long SysExParamDesc_DataLoadFilterMidiSetting                       ; F51F1A  [12]   -> 0xF5134D
	.long SysExParamDesc_DataLoadFilterKeyAndVelocityLayer                       ; F51F1E  [13]   -> 0xF51369
	.long SysExParamDesc_DataLoadFilterMainOutEqualizer                       ; F51F22  [14]   -> 0xF51385
	.long SysExParamDesc_DataLoadFilterKeyScaling                       ; F51F26  [15]   -> 0xF513A1
	.long SysExParamDesc_CombinationNumberAndBank                       ; F51F2A  [16]   -> 0xF513BD
	.long SysExParamDesc_MidiInputMode                       ; F51F2E  [17]   -> 0xF513D9
	.long SysExParamDesc_MidiOutputMode                       ; F51F32  [18]   -> 0xF513F5
	.long SysExParamDesc_SingleChannel                       ; F51F36  [19]   -> 0xF51411
	.long SysExParamDesc_LocalTotal                       ; F51F3A  [20]   -> 0xF5142D
	.long SysExParamDesc_ProgramChangeMode                       ; F51F3E  [21]   -> 0xF51449
	.long SysExParamDesc_SingleChannelProgramChange                       ; F51F42  [22]   -> 0xF51465

; --------------------------------------------------------------------------
; PtrTable_F51F46 -- 5 32-bit pointers, 0 into prom_a and 5 into prom_b
; Read by: prom_a 0xFB35CB `add XWA,0x00f51f46`; prom_a 0xFB35DE `lda_24
;          xbc, (0xf51f46)`
; Entry count: 5, measured by abutment: 5 x 4 = 20 bytes reaches 0xF51F5A
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
PtrTable_F51F46:
	.long SysExParamDesc_Placeholder                       ; F51F46  [0]   -> 0xF511F9
	.long SysExParamDesc_Initial                       ; F51F4A  [1]   -> 0xF51481
	.long SysExParamDesc_PlayModeRequest                       ; F51F4E  [2]   -> 0xF5149D
	.long SysExParamDesc_CombinationWriteRequest                       ; F51F52  [3]   -> 0xF514BB
	.long SysExParamDesc_SoundWriteRequest                       ; F51F56  [4]   -> 0xF514D7

; --------------------------------------------------------------------------
; Pointer_F51F5A -- 1 32-bit pointer, 0 into prom_a and 1 into prom_b
; Read by: prom_a 0xFB4385 `add XWA,0x00f51f5a`; prom_a 0xFB4398 `lda_24
;          xbc, (0xf51f5a)`
; Entry count: 1, measured by abutment: 1 x 4 = 4 bytes reaches 0xF51F5E
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
Pointer_F51F5A:
	.long SysExParamDesc_Placeholder                       ; F51F5A  [0]   -> 0xF511F9

; --------------------------------------------------------------------------
; PtrTable_F51F5E -- 25 32-bit pointers, 0 into prom_a and 25 into prom_b
; Read by: prom_a 0xFB361F `add XWA,0x00f51f5e`; prom_a 0xFB3632 `lda_24
;          xbc, (0xf51f5e)`
; Entry count: 25, measured by abutment: 25 x 4 = 100 bytes reaches 0xF51FC2
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
PtrTable_F51F5E:
	.long SysExParamDesc_Placeholder                       ; F51F5E  [0]   -> 0xF511F9
	.long SysExParamDesc_KeyTranspose                       ; F51F62  [1]   -> 0xF514F3
	.long SysExParamDesc_KeyScalingMode                       ; F51F66  [2]   -> 0xF5150F
	.long SysExParamDesc_TotalKeyScaling                       ; F51F6A  [3]   -> 0xF5152B
	.long SysExParamDesc_KeyScalingShift                       ; F51F6E  [4]   -> 0xF51556
	.long SysExParamDesc_CkeyDetuneSetting                       ; F51F72  [5]   -> 0xF51572
	.long SysExParamDesc_DbkeyDetuneSetting                       ; F51F76  [6]   -> 0xF5158E
	.long SysExParamDesc_DkeyDetuneSetting                       ; F51F7A  [7]   -> 0xF515AA
	.long SysExParamDesc_EbkeyDetuneSetting                       ; F51F7E  [8]   -> 0xF515C6
	.long SysExParamDesc_EkeyDetuneSetting                       ; F51F82  [9]   -> 0xF515E2
	.long SysExParamDesc_FkeyDetuneSetting                       ; F51F86  [10]   -> 0xF515FE
	.long SysExParamDesc_GbkeyDetuneSetting                       ; F51F8A  [11]   -> 0xF5161A
	.long SysExParamDesc_GkeyDetuneSetting                       ; F51F8E  [12]   -> 0xF51636
	.long SysExParamDesc_AbkeyDetuneSetting                       ; F51F92  [13]   -> 0xF51652
	.long SysExParamDesc_AkeyDetuneSetting                       ; F51F96  [14]   -> 0xF5166E
	.long SysExParamDesc_BbkeyDetuneSetting                       ; F51F9A  [15]   -> 0xF5168A
	.long SysExParamDesc_BkeyDetuneSetting                       ; F51F9E  [16]   -> 0xF516A6
	.long SysExParamDesc_MainOutEqualizerLowFreq                       ; F51FA2  [17]   -> 0xF516C2
	.long SysExParamDesc_MainOutEqualizerLowGain                       ; F51FA6  [18]   -> 0xF516DE
	.long SysExParamDesc_MainOutEqualizerHighFreq                       ; F51FAA  [19]   -> 0xF516FA
	.long SysExParamDesc_MainOutEqualizerHighGain                       ; F51FAE  [20]   -> 0xF51716
	.long SysExParamDesc_EffectCommonAlgorithm                       ; F51FB2  [21]   -> 0xF51732
	.long SysExParamDesc_Effect1OutputSelect                       ; F51FB6  [22]   -> 0xF5174E
	.long SysExParamDesc_Effect2OutputSelect                       ; F51FBA  [23]   -> 0xF5176A
	.long SysExParamDesc_Effect1Type                       ; F51FBE  [24]   -> 0xF51786

; --------------------------------------------------------------------------
; PtrTable_F51FC2 -- 25 32-bit pointers, 0 into prom_a and 25 into prom_b
; Read by: prom_a 0xFB43D9 `add XWA,0x00f51fc2`; prom_a 0xFB43EC `lda_24
;          xbc, (0xf51fc2)`
; Entry count: 25, measured by abutment: 25 x 4 = 100 bytes reaches 0xF52026
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
PtrTable_F51FC2:
	.long SysExParamDesc_Placeholder                       ; F51FC2  [0]   -> 0xF511F9
	.long SysExParamDesc_KeyTranspose                       ; F51FC6  [1]   -> 0xF514F3
	.long SysExParamDesc_KeyScalingMode                       ; F51FCA  [2]   -> 0xF5150F
	.long SysExParamDesc_TotalKeyScaling                       ; F51FCE  [3]   -> 0xF5152B
	.long SysExParamDesc_KeyScalingShift                       ; F51FD2  [4]   -> 0xF51556
	.long SysExParamDesc_CkeyDetuneSetting                       ; F51FD6  [5]   -> 0xF51572
	.long SysExParamDesc_DbkeyDetuneSetting                       ; F51FDA  [6]   -> 0xF5158E
	.long SysExParamDesc_DkeyDetuneSetting                       ; F51FDE  [7]   -> 0xF515AA
	.long SysExParamDesc_EbkeyDetuneSetting                       ; F51FE2  [8]   -> 0xF515C6
	.long SysExParamDesc_EkeyDetuneSetting                       ; F51FE6  [9]   -> 0xF515E2
	.long SysExParamDesc_FkeyDetuneSetting                       ; F51FEA  [10]   -> 0xF515FE
	.long SysExParamDesc_GbkeyDetuneSetting                       ; F51FEE  [11]   -> 0xF5161A
	.long SysExParamDesc_GkeyDetuneSetting                       ; F51FF2  [12]   -> 0xF51636
	.long SysExParamDesc_AbkeyDetuneSetting                       ; F51FF6  [13]   -> 0xF51652
	.long SysExParamDesc_AkeyDetuneSetting                       ; F51FFA  [14]   -> 0xF5166E
	.long SysExParamDesc_BbkeyDetuneSetting                       ; F51FFE  [15]   -> 0xF5168A
	.long SysExParamDesc_BkeyDetuneSetting                       ; F52002  [16]   -> 0xF516A6
	.long SysExParamDesc_MainOutEqualizerLowFreq                       ; F52006  [17]   -> 0xF516C2
	.long SysExParamDesc_MainOutEqualizerLowGain                       ; F5200A  [18]   -> 0xF516DE
	.long SysExParamDesc_MainOutEqualizerHighFreq                       ; F5200E  [19]   -> 0xF516FA
	.long SysExParamDesc_MainOutEqualizerHighGain                       ; F52012  [20]   -> 0xF51716
	.long SysExParamDesc_EffectCommonAlgorithm                       ; F52016  [21]   -> 0xF51732
	.long SysExParamDesc_Effect1OutputSelect                       ; F5201A  [22]   -> 0xF5174E
	.long SysExParamDesc_Effect2OutputSelect                       ; F5201E  [23]   -> 0xF5176A
	.long SysExParamDesc_Effect1Type                       ; F52022  [24]   -> 0xF51786

; --------------------------------------------------------------------------
; PtrTable_F52026 -- 19 32-bit pointers, 0 into prom_a and 19 into prom_b
; Read by: prom_a 0xFB3674 `add XWA,0x00f52026`; prom_a 0xFB3687 `lda_24
;          xbc, (0xf52026)`
; Entry count: 19, measured by abutment: 19 x 4 = 76 bytes reaches 0xF52072
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
PtrTable_F52026:
	.long SysExParamDesc_Placeholder                       ; F52026  [0]   -> 0xF511F9
	.long SysExParamDesc_ProgramChangeAndBank                       ; F5202A  [1]   -> 0xF517A2
	.long SysExParamDesc_Volume                       ; F5202E  [2]   -> 0xF517BE
	.long SysExParamDesc_Effect1Send                       ; F52032  [3]   -> 0xF517DA
	.long SysExParamDesc_Effect2OnOff                       ; F52036  [4]   -> 0xF517F6
	.long SysExParamDesc_ReverbSend                       ; F5203A  [5]   -> 0xF51814
	.long SysExParamDesc_Panpot                       ; F5203E  [6]   -> 0xF51830
	.long SysExParamDesc_KeyShift                       ; F52042  [7]   -> 0xF5184C
	.long SysExParamDesc_FineTune                       ; F52046  [8]   -> 0xF51868
	.long SysExParamDesc_PitchBendRange                       ; F5204A  [9]   -> 0xF51884
	.long SysExParamDesc_AssignMode                       ; F5204E  [10]   -> 0xF518A0
	.long SysExParamDesc_KeyScaling                       ; F52052  [11]   -> 0xF518BC
	.long SysExParamDesc_VelocityOffset_2020                       ; F52056  [12]   -> 0xF518D8
	.long SysExParamDesc_KeyLayerLow                       ; F5205A  [13]   -> 0xF518F4
	.long SysExParamDesc_KeyLayerHigh                       ; F5205E  [14]   -> 0xF51910
	.long SysExParamDesc_VelocityLayerLow                       ; F52062  [15]   -> 0xF5192C
	.long SysExParamDesc_VelocityLayerHigh                       ; F52066  [16]   -> 0xF51948
	.long SysExParamDesc_MainOut                       ; F5206A  [17]   -> 0xF51964
	.long SysExParamDesc_SubOut                       ; F5206E  [18]   -> 0xF51980

; --------------------------------------------------------------------------
; PtrTable_F52072 -- 19 32-bit pointers, 0 into prom_a and 19 into prom_b
; Read by: prom_a 0xFB442E `add XWA,0x00f52072`; prom_a 0xFB4441 `lda_24
;          xbc, (0xf52072)`
; Entry count: 19, measured by abutment: 19 x 4 = 76 bytes reaches 0xF520BE
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
PtrTable_F52072:
	.long SysExParamDesc_Placeholder                       ; F52072  [0]   -> 0xF511F9
	.long SysExParamDesc_ProgramChangeAndBank                       ; F52076  [1]   -> 0xF517A2
	.long SysExParamDesc_Volume                       ; F5207A  [2]   -> 0xF517BE
	.long SysExParamDesc_Effect1Send                       ; F5207E  [3]   -> 0xF517DA
	.long SysExParamDesc_Effect2OnOff                       ; F52082  [4]   -> 0xF517F6
	.long SysExParamDesc_ReverbSend                       ; F52086  [5]   -> 0xF51814
	.long SysExParamDesc_Panpot                       ; F5208A  [6]   -> 0xF51830
	.long SysExParamDesc_KeyShift                       ; F5208E  [7]   -> 0xF5184C
	.long SysExParamDesc_FineTune                       ; F52092  [8]   -> 0xF51868
	.long SysExParamDesc_PitchBendRange                       ; F52096  [9]   -> 0xF51884
	.long SysExParamDesc_AssignMode                       ; F5209A  [10]   -> 0xF518A0
	.long SysExParamDesc_KeyScaling                       ; F5209E  [11]   -> 0xF518BC
	.long SysExParamDesc_VelocityOffset_2020                       ; F520A2  [12]   -> 0xF518D8
	.long SysExParamDesc_KeyLayerLow                       ; F520A6  [13]   -> 0xF518F4
	.long SysExParamDesc_KeyLayerHigh                       ; F520AA  [14]   -> 0xF51910
	.long SysExParamDesc_VelocityLayerLow                       ; F520AE  [15]   -> 0xF5192C
	.long SysExParamDesc_VelocityLayerHigh                       ; F520B2  [16]   -> 0xF51948
	.long SysExParamDesc_MainOut                       ; F520B6  [17]   -> 0xF51964
	.long SysExParamDesc_SubOut                       ; F520BA  [18]   -> 0xF51980

; --------------------------------------------------------------------------
; PtrTable_F520BE -- 40 32-bit pointers, 0 into prom_a and 40 into prom_b
; Read by: prom_a 0xFB36C8 `add XWA,0x00f520be`; prom_a 0xFB36DB `lda_24
;          xbc, (0xf520be)`
; Entry count: 40, measured by abutment: 40 x 4 = 160 bytes reaches 0xF5215E
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
PtrTable_F520BE:
	.long SysExParamDesc_Placeholder                       ; F520BE  [0]   -> 0xF511F9
	.long SysExParamDesc_LocalControl                       ; F520C2  [1]   -> 0xF519A0
	.long SysExParamDesc_BasicChannel                       ; F520C6  [2]   -> 0xF519BC
	.long SysExParamDesc_MidiOutSetting                       ; F520CA  [3]   -> 0xF519D8
	.long SysExParamDesc_MidiInSetting                       ; F520CE  [4]   -> 0xF519F4
	.long SysExParamDesc_MidiInputFilterProgramChange                       ; F520D2  [5]   -> 0xF51A10
	.long SysExParamDesc_MidiInputFilterBankSelect                       ; F520D6  [6]   -> 0xF51A2C
	.long SysExParamDesc_MidiInputFilterVolume                       ; F520DA  [7]   -> 0xF51A48
	.long SysExParamDesc_MidiOutputFilterProgramChange                       ; F520DE  [8]   -> 0xF51A64
	.long SysExParamDesc_MidiOutputFilterBankSelect                       ; F520E2  [9]   -> 0xF51A80
	.long SysExParamDesc_MidiOutputFilterVolume                       ; F520E6  [10]   -> 0xF51A9C
	.long SysExParamDesc_MidiOutputFilterPanpot                       ; F520EA  [11]   -> 0xF51AB8
	.long SysExParamDesc_MidiOutputFilterEffectDepth                       ; F520EE  [12]   -> 0xF51AD4
	.long SysExParamDesc_MidiOutputFilterPitchBend                       ; F520F2  [13]   -> 0xF51AF0
	.long SysExParamDesc_MidiOutputFilterModulation1                       ; F520F6  [14]   -> 0xF51B0C
	.long SysExParamDesc_MidiOutputFilterModulation2                       ; F520FA  [15]   -> 0xF51B28
	.long SysExParamDesc_MidiOutputFilterRealTimeCreatorX                       ; F520FE  [16]   -> 0xF51B44
	.long SysExParamDesc_MidiOutputFilterRealTimeCreatorY                       ; F52102  [17]   -> 0xF51B60
	.long SysExParamDesc_MidiOutputFilterRealTimeControllerX                       ; F52106  [18]   -> 0xF51B7C
	.long SysExParamDesc_MidiOutputFilterRealTimeControllerY                       ; F5210A  [19]   -> 0xF51B98
	.long SysExParamDesc_MidiOutputFilterHold1                       ; F5210E  [20]   -> 0xF51BB4
	.long SysExParamDesc_MidiOutputFilterControlPedal                       ; F52112  [21]   -> 0xF51BD0
	.long SysExParamDesc_MidiOutputFilterAfterTouch                       ; F52116  [22]   -> 0xF51BEC
	.long SysExParamDesc_MidiMultipleMessagesOutputProgramChange                       ; F5211A  [23]   -> 0xF51C08
	.long SysExParamDesc_MidiMultipleMessagesOutputBankSelect                       ; F5211E  [24]   -> 0xF51C28
	.long SysExParamDesc_MidiMultipleMessagesOutputVolume                       ; F52122  [25]   -> 0xF51C44
	.long SysExParamDesc_MidiMultipleMessagesOutputPanpot                       ; F52126  [26]   -> 0xF51C64
	.long SysExParamDesc_MidiMultipleMessagesOutputReverbDepth                       ; F5212A  [27]   -> 0xF51C84
	.long SysExParamDesc_MidiMultipleMessagesOutputChorusDepth                       ; F5212E  [28]   -> 0xF51CA4
	.long SysExParamDesc_MidiOutKeyTranspose                       ; F52132  [29]   -> 0xF51CC4
	.long SysExParamDesc_ControllerInternalFilterPitchBend                       ; F52136  [30]   -> 0xF51CE0
	.long SysExParamDesc_ControllerInternalFilterModulation1                       ; F5213A  [31]   -> 0xF51CFC
	.long SysExParamDesc_ControllerInternalFilterModulation2                       ; F5213E  [32]   -> 0xF51D18
	.long SysExParamDesc_ControllerInternalFilterRealTimeCreatorX                       ; F52142  [33]   -> 0xF51D34
	.long SysExParamDesc_ControllerInternalFilterRealTimeCreatorY                       ; F52146  [34]   -> 0xF51D50
	.long SysExParamDesc_ControllerInternalFilterRealTimeControllerX                       ; F5214A  [35]   -> 0xF51D6C
	.long SysExParamDesc_ControllerInternalFilterRealTimeControllerY                       ; F5214E  [36]   -> 0xF51D88
	.long SysExParamDesc_ControllerInternalFilterHold1                       ; F52152  [37]   -> 0xF51DA4
	.long SysExParamDesc_ControllerInternalFilterControlPedal                       ; F52156  [38]   -> 0xF51DC0
	.long SysExParamDesc_ControllerInternalFilterAfterTouch                       ; F5215A  [39]   -> 0xF51DDC

; --------------------------------------------------------------------------
; PtrTable_F5215E -- 40 32-bit pointers, 0 into prom_a and 40 into prom_b
; Read by: prom_a 0xFB4482 `add XWA,0x00f5215e`; prom_a 0xFB4495 `lda_24
;          xbc, (0xf5215e)`
; Entry count: 40, measured by abutment: 40 x 4 = 160 bytes reaches 0xF521FE
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
PtrTable_F5215E:
	.long SysExParamDesc_Placeholder                       ; F5215E  [0]   -> 0xF511F9
	.long SysExParamDesc_LocalControl                       ; F52162  [1]   -> 0xF519A0
	.long SysExParamDesc_BasicChannel                       ; F52166  [2]   -> 0xF519BC
	.long SysExParamDesc_MidiOutSetting                       ; F5216A  [3]   -> 0xF519D8
	.long SysExParamDesc_MidiInSetting                       ; F5216E  [4]   -> 0xF519F4
	.long SysExParamDesc_MidiInputFilterProgramChange                       ; F52172  [5]   -> 0xF51A10
	.long SysExParamDesc_MidiInputFilterBankSelect                       ; F52176  [6]   -> 0xF51A2C
	.long SysExParamDesc_MidiInputFilterVolume                       ; F5217A  [7]   -> 0xF51A48
	.long SysExParamDesc_MidiOutputFilterProgramChange                       ; F5217E  [8]   -> 0xF51A64
	.long SysExParamDesc_MidiOutputFilterBankSelect                       ; F52182  [9]   -> 0xF51A80
	.long SysExParamDesc_MidiOutputFilterVolume                       ; F52186  [10]   -> 0xF51A9C
	.long SysExParamDesc_MidiOutputFilterPanpot                       ; F5218A  [11]   -> 0xF51AB8
	.long SysExParamDesc_MidiOutputFilterEffectDepth                       ; F5218E  [12]   -> 0xF51AD4
	.long SysExParamDesc_MidiOutputFilterPitchBend                       ; F52192  [13]   -> 0xF51AF0
	.long SysExParamDesc_MidiOutputFilterModulation1                       ; F52196  [14]   -> 0xF51B0C
	.long SysExParamDesc_MidiOutputFilterModulation2                       ; F5219A  [15]   -> 0xF51B28
	.long SysExParamDesc_MidiOutputFilterRealTimeCreatorX                       ; F5219E  [16]   -> 0xF51B44
	.long SysExParamDesc_MidiOutputFilterRealTimeCreatorY                       ; F521A2  [17]   -> 0xF51B60
	.long SysExParamDesc_MidiOutputFilterRealTimeControllerX                       ; F521A6  [18]   -> 0xF51B7C
	.long SysExParamDesc_MidiOutputFilterRealTimeControllerY                       ; F521AA  [19]   -> 0xF51B98
	.long SysExParamDesc_MidiOutputFilterHold1                       ; F521AE  [20]   -> 0xF51BB4
	.long SysExParamDesc_MidiOutputFilterControlPedal                       ; F521B2  [21]   -> 0xF51BD0
	.long SysExParamDesc_MidiOutputFilterAfterTouch                       ; F521B6  [22]   -> 0xF51BEC
	.long SysExParamDesc_MidiMultipleMessagesOutputProgramChange                       ; F521BA  [23]   -> 0xF51C08
	.long SysExParamDesc_MidiMultipleMessagesOutputBankSelect                       ; F521BE  [24]   -> 0xF51C28
	.long SysExParamDesc_MidiMultipleMessagesOutputVolume                       ; F521C2  [25]   -> 0xF51C44
	.long SysExParamDesc_MidiMultipleMessagesOutputPanpot                       ; F521C6  [26]   -> 0xF51C64
	.long SysExParamDesc_MidiMultipleMessagesOutputReverbDepth                       ; F521CA  [27]   -> 0xF51C84
	.long SysExParamDesc_MidiMultipleMessagesOutputChorusDepth                       ; F521CE  [28]   -> 0xF51CA4
	.long SysExParamDesc_MidiOutKeyTranspose                       ; F521D2  [29]   -> 0xF51CC4
	.long SysExParamDesc_ControllerInternalFilterPitchBend                       ; F521D6  [30]   -> 0xF51CE0
	.long SysExParamDesc_ControllerInternalFilterModulation1                       ; F521DA  [31]   -> 0xF51CFC
	.long SysExParamDesc_ControllerInternalFilterModulation2                       ; F521DE  [32]   -> 0xF51D18
	.long SysExParamDesc_ControllerInternalFilterRealTimeCreatorX                       ; F521E2  [33]   -> 0xF51D34
	.long SysExParamDesc_ControllerInternalFilterRealTimeCreatorY                       ; F521E6  [34]   -> 0xF51D50
	.long SysExParamDesc_ControllerInternalFilterRealTimeControllerX                       ; F521EA  [35]   -> 0xF51D6C
	.long SysExParamDesc_ControllerInternalFilterRealTimeControllerY                       ; F521EE  [36]   -> 0xF51D88
	.long SysExParamDesc_ControllerInternalFilterHold1                       ; F521F2  [37]   -> 0xF51DA4
	.long SysExParamDesc_ControllerInternalFilterControlPedal                       ; F521F6  [38]   -> 0xF51DC0
	.long SysExParamDesc_ControllerInternalFilterAfterTouch                       ; F521FA  [39]   -> 0xF51DDC

; --------------------------------------------------------------------------
; PtrTable_F521FE -- 2 32-bit pointers, 0 into prom_a and 2 into prom_b
; Read by: prom_a 0xFB371B `add XWA,0x00f521fe`; prom_a 0xFB372E `lda_24
;          xbc, (0xf521fe)`
; Entry count: 2, measured by abutment: 2 x 4 = 8 bytes reaches 0xF52206
;              exactly, which is the next address an instruction names.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
PtrTable_F521FE:
	.long SysExParamDesc_Placeholder                       ; F521FE  [0]   -> 0xF511F9
	.long SysExParamDesc_MetronomeVolume                       ; F52202  [1]   -> 0xF51DF8

; --------------------------------------------------------------------------
; PtrTable_F52206 -- 2 32-bit pointers, 0 into prom_a and 2 into prom_b
; Read by: prom_a 0xFB44D5 `add XWA,0x00f52206`; prom_a 0xFB44E8 `lda_24
;          xbc, (0xf52206)`
; Entry count: 2, measured by abutment: 2 x 4 = 8 bytes reaches 0xF5220E
;              exactly, which is the end of the segment.
; Evidence: every word in the range is a 32-bit value inside the
;           0x00F00000-0x00FFFFFF program window -- the layout's romtab
;           rule, whose null corpus is 107,345 bytes of proven prom_b
;           instruction text on which it fires zero times.  The BASE is the
;           address an instruction spells, not a boundary this file chose.
; --------------------------------------------------------------------------
PtrTable_F52206:
	.long SysExParamDesc_Placeholder                       ; F52206  [0]   -> 0xF511F9
	.long SysExParamDesc_MetronomeVolume                       ; F5220A  [1]   -> 0xF51DF8

; --- 0xF5220E-0xF52FFF  fill (3570 bytes) ---
	.fill	3570, 1, 0x0E	; asserted a single value
