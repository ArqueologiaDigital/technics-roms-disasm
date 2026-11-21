Audio_Process_DSP:
	lda xsp, (xsp - 10)
	push xiz
	lda xwa, (DSP2_RingBuffer:16)
	ld (xsp + 4), xwa
	ld wa, (xwa + 4)
	calr DSP_StoreBufferCount
	cpw (17548:16), 0
	jrl z, DSP_Process_ReadNext
	jrl DSP_Process_Exit

; Message-length pre-check, and the source of the wedge above. Peeks the byte five positions
; ahead of the ring read index -- that is header byte 0x436D's position, i.e. the message
; length -- and compares it against the ring's byte count.
;   length <= count : proceed to Audio_Process_DSP_MsgSizeCheck
;   length >  count : un-read the type byte (--read index at 0x035B09, ++count at 0x035B0F),
;                     set (0x448C) = 1 at 0x035B12, exit.
; Because the length is read from the ring without any sanity limit, one corrupt byte
; (0x00..0xFF, so up to 255) is enough to take the second branch permanently.
DSP_Process_NextCmd:
	ld xwa, (xsp + 4)
	ld wa, (xwa + 2)
	inc 5, wa
	and wa, 0x7FF
	extz xwa
	inc 6, xwa
	add xwa, (xsp + 4)
	ld a, (xwa)
	ld c, a
	extz bc
	ld xwa, (xsp + 4)
	cp bc, (xwa + 4)
	jr ule, Audio_Process_DSP_MsgSizeCheck
	ld xwa, (xsp + 4)
	decm 1, (xwa + 2)
	ld xwa, (xsp + 4)
	incw 1, (xwa + 4)
	ldw (17548:16), 1
	jrl DSP_Process_Exit

; The real header decode and dispatch, despite the name (the size was already checked).
; Calls DSP_Cmd_DequeueHeader, stores the type byte at 0x4368, then:
;   0x2D -> DSP_CmdHandler_2D    0x2C -> DSP_CmdHandler_2C    0x2B -> falls through
;   anything else -> DSP_Cmd_DefaultSkip
; For 0x2B it reads the payload with DSP_RingBuf_ReadAndCompare into 0x4370, then switches on
; the target selector 0x4369: below 0x30 or above 0x3F -> SkipAndContinue; 0x436A != 0x7F ->
; VoiceParamWrite; otherwise the channel is 0x4369 & 0xF and the sub-command is 0x436B:
;   0x30 -> Noop            0x27 -> ReadParam11      0x24 -> SetParam
;   0x22 -> ReadParam5D     0x20 -> MixSendConfig    0x03 -> StateControl
;   0x00 -> AlgoSelect      0x10..0x17 -> the eight stubs below, via the offset table at
;                            ROM 0x0121DB added to the base 0x035BC6
;   anything else -> UnknownSkip
Audio_Process_DSP_MsgSizeCheck:
	ld xwa, (xsp + 4)
	calr DSP_Cmd_DequeueHeader
	ld wa, (xsp + 12)
	ld (17256:16), a
	cp a, 0x2D
	jrl z, DSP_CmdHandler_2D
	cp a, 0x2C
	jrl z, DSP_CmdHandler_2C
	cp a, 0x2B
	jrl nz, DSP_Cmd_DefaultSkip
	lda xwa, (17264:16)
	ld xbc, xwa
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_ReadAndCompare
	ld a, (17257:16)
	ldfr_berp A, 0xFB
	cp_erpb 0xFB, 0x30
	jrl c, DSP_Cmd2B_SkipAndContinue
	cp_erpb 0xFB, 0x3F
	jrl ugt, DSP_Cmd2B_SkipAndContinue
	cp (17258:16), 127
	jrl nz, DSP_Cmd2B_VoiceParamWrite
	ldto_berp A, 0xFB
	ldfr_berp A, 0xF8
	extz iz
	and iz, 0xF
	lda xwa, (17264:16)
	ld (xsp + 10), xwa
	ld a, (17259:16)
	cp a, 0x30
	jrl z, DSP_Cmd2B_Noop
	cp a, 0x27
	jrl z, DSP_Cmd2B_ReadParam11
	cp a, 0x24
	jrl z, DSP_Cmd2B_SetParam
	cp a, 0x22
	jrl z, DSP_Cmd2B_ReadParam5D
	cp a, 0x20
	jrl z, DSP_Cmd2B_MixSendConfig
	cp a, 3:i3
	jr z, DSP_Cmd2B_StateControl
	cp a, 0:i3
	jr z, DSP_Cmd2B_AlgoSelect
	extz wa
	sub wa, 0x10
	cp wa, 0:i3
	jrl lt, DSP_Cmd2B_UnknownSkip
	cp wa, 7:i3
	jrl gt, DSP_Cmd2B_UnknownSkip
	add wa, wa
	lda xix, (DSP_Cmd2B_DispatchOffsets:24)
	ld	wa, (xix+wa)
	lda xix, (DSP_Cmd2B_AlgoSelect:24)
	jp	t, (xix+wa)

; Sub-command 0x00. If CheckStatusBits_40(channel) returns 0 it first calls
; Voice_Slot_CalcArticParams(channel), then DSP_AlgoSelect(WA = channel, BC = payload[0]
; from 0x4370, XDE = 0x4370). Also the base address the 0x0121DB offset table is added to.
DSP_Cmd2B_AlgoSelect:
	ld wa, iz
	call CheckStatusBits_40
	cp hl, 0:i3
	jr z, DSP_Cmd2B_AlgoSelect_Continue
	ld wa, iz
	call Voice_Slot_CalcArticParams

; Join point that performs the DSP_AlgoSelect call.
DSP_Cmd2B_AlgoSelect_Continue:
	ldto_berp A, 0xF8
	ld e, a
	extz de
	ld a, (17264:16)
	ld c, a
	extz bc
	ld wa, de
	ld xde, (xsp + 10)
	call DSP_AlgoSelect
	jrl DSP_Cmd2B_PostProcess

; Sub-command 0x03: DSP_EffectStateQuery(WA = channel & 0xF, XBC = 0x4370) (0x030618).
DSP_Cmd2B_StateControl:
	ld a, (xsp + 8)
	and a, 0xF
	extz wa
	ld xbc, (xsp + 10)
	call DSP_EffectStateQuery
	jrl DSP_Cmd2B_PostProcess
; ★ NEW NAME -- this address currently has NO symbol in either the ELF or the reference file.
; First of eight 20-byte stubs reached through the offset table at ROM 0x0121DB
; (offsets 0x3D, 0x51, 0x65, 0x79, 0x8D, 0xA1, 0xB5, 0xC9 added to 0x035BC6 give 0x035C03,
; 0x035C17, 0x035C2B, 0x035C3F, 0x035C53, 0x035C67, 0x035C7B, 0x035C8F). Each stub is
;   ld A,(XSP+8) / and A,0x0F / extz WA / ld XDE,(XSP+0x0A) / ld BC,<n> / call 0x030F7D
;   / jrl 0x035D4A
; i.e. DSP_VoiceParamReadWrite(WA = channel, XDE = 0x4370, BC = n) followed by the common
; reply path. Sub-command 0x10 selects n = 0. Verified by disassembling 0x035BF1..0x035CA2.
DSP_Cmd2B_ParamStub0:
	ld a, (xsp + 8)
	and a, 0xF
	extz wa
	ld xde, (xsp + 10)
	ld bc, 0:i3
	call DSP_VoiceParamReadWrite
	jrl DSP_Cmd2B_PostProcess
; ★ NEW NAME. As above with BC = 1; sub-command 0x11.
DSP_Cmd2B_ParamStub1:
	ld a, (xsp + 8)
	and a, 0xF
	extz wa
	ld xde, (xsp + 10)
	ld bc, 1:i3
	call DSP_VoiceParamReadWrite
	jrl DSP_Cmd2B_PostProcess
; ★ NEW NAME. BC = 2; sub-command 0x12.
DSP_Cmd2B_ParamStub2:
	ld a, (xsp + 8)
	and a, 0xF
	extz wa
	ld xde, (xsp + 10)
	ld bc, 2:i3
	call DSP_VoiceParamReadWrite
	jrl DSP_Cmd2B_PostProcess
; ★ NEW NAME. BC = 3; sub-command 0x13.
DSP_Cmd2B_ParamStub3:
	ld a, (xsp + 8)
	and a, 0xF
	extz wa
	ld xde, (xsp + 10)
	ld bc, 3:i3
	call DSP_VoiceParamReadWrite
	jrl DSP_Cmd2B_PostProcess
; ★ NEW NAME. BC = 4; sub-command 0x14.
DSP_Cmd2B_ParamStub4:
	ld a, (xsp + 8)
	and a, 0xF
	extz wa
	ld xde, (xsp + 10)
	ld bc, 4:i3
	call DSP_VoiceParamReadWrite
	jrl DSP_Cmd2B_PostProcess
; ★ NEW NAME. BC = 5; sub-command 0x15.
DSP_Cmd2B_ParamStub5:
	ld a, (xsp + 8)
	and a, 0xF
	extz wa
	ld xde, (xsp + 10)
	ld bc, 5:i3
	call DSP_VoiceParamReadWrite
	jrl DSP_Cmd2B_PostProcess
; ★ NEW NAME. BC = 6; sub-command 0x16.
DSP_Cmd2B_ParamStub6:
	ld a, (xsp + 8)
	and a, 0xF
	extz wa
	ld xde, (xsp + 10)
	ld bc, 6:i3
	call DSP_VoiceParamReadWrite
	jrl DSP_Cmd2B_PostProcess
; ★ NEW NAME. BC = 7; sub-command 0x17.
DSP_Cmd2B_ParamStub7:
	ld a, (xsp + 8)
	and a, 0xF
	extz wa
	ld xde, (xsp + 10)
	ld bc, 7:i3
	call DSP_VoiceParamReadWrite
	jrl DSP_Cmd2B_PostProcess

; Sub-command 0x20: DSP_MixSendConfig(WA = payload[0] at 0x4370, BC = payload[1] at 0x4371,
; XDE = 0x4370).
DSP_Cmd2B_MixSendConfig:
	ld a, (17264:16)
	ld e, a
	extz de
	ld a, (17265:16)
	ld c, a
	extz bc
	ld wa, de
	ld xde, (xsp + 10)
	call DSP_MixSendConfig
	jrl DSP_Cmd2B_PostProcess

; Sub-command 0x22: DSP_ReadVoiceParam5D with the same three arguments.
DSP_Cmd2B_ReadParam5D:
	ld a, (17264:16)
	ld e, a
	extz de
	ld a, (17265:16)
	ld c, a
	extz bc
	ld wa, de
	ld xde, (xsp + 10)
	call DSP_ReadVoiceParam5D
	jr DSP_Cmd2B_PostProcess

; Sub-command 0x24: DSP_SetVoiceCoefficients with the same three arguments.
DSP_Cmd2B_SetParam:
	ld a, (17264:16)
	ld e, a
	extz de
	ld a, (17265:16)
	ld c, a
	extz bc
	ld wa, de
	ld xde, (xsp + 10)
	call DSP_SetVoiceCoefficients
	jr DSP_Cmd2B_PostProcess

; Sub-command 0x27: DSP_ReadVoiceParam11 with the same three arguments.
DSP_Cmd2B_ReadParam11:
	ld a, (17264:16)
	ld e, a
	extz de
	ld a, (17265:16)
	ld c, a
	extz bc
	ld wa, de
	ld xde, (xsp + 10)
	call DSP_ReadVoiceParam11
	jr DSP_Cmd2B_PostProcess

; Sub-command 0x30: HL = 0, i.e. accepted and silently ignored, and (HL == 0) means no reply.
DSP_Cmd2B_Noop:
	ld hl, 0:i3
	jr DSP_Cmd2B_PostProcess

; Unrecognised sub-command: DSP_RingBuf_Skip (which resynchronises the WHOLE ring), HL = 0.
DSP_Cmd2B_UnknownSkip:
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_Skip
	ld hl, 0:i3
	jr DSP_Cmd2B_PostProcess

; Taken when 0x436A != 0x7F: the message carries a 14-bit parameter index
; (Extract_14Bit_VoiceParam on the header copy) and a 14-bit value
; (Extract_14Bit_PayloadSize), which are handed to DSP_WriteVoiceParam together with the
; channel (0x4369 & 0xF) and a pushed pointer to 0x4370.
DSP_Cmd2B_VoiceParamWrite:
	ldto_berp A, 0xFB
	extz wa
	ld iz, wa
	and iz, 0xF
	lda xwa, (17256:16)
	calr Extract_14Bit_VoiceParam
	ldfr_werp HL, 0xFA
	lda xwa, (17256:16)
	calr Extract_14Bit_PayloadSize
	lda xwa, (17264:16)
	push xwa
	ld wa, iz
	ldto_werp BC, 0xFA
	ld de, hl
	call DSP_WriteVoiceParam

; ★ THE ONLY SUB->MAIN PRODUCER IN THIS REGION. Common tail of every 0x2B sub-command.
;   if HL == 0 : no reply at all, straight back to DSP_Process_ReadNext
;   else       : InterCPU_DMA_Send(WA = 3, XDE = 0x4368, BC = HL + 8)
; XDE = 0x4368 is the verbatim copy of the message just processed (type byte + 7 header bytes
; + payload), so the reply is an echo of length HL + 8. Command class 3 on the inter-CPU
; link. Every handler that returns 0 -- DSP_Cmd2B_Noop, DSP_Cmd2B_UnknownSkip, and any
; handler whose own result is zero -- is silently unacknowledged by design.
DSP_Cmd2B_PostProcess:
	cp hl, 0:i3
	jrl z, DSP_Process_ReadNext
	inc 8, hl
	lda xde, (17256:16)
	ld bc, hl
	ld wa, 3:i3
	call InterCPU_DMA_Send
	jrl DSP_Process_ReadNext

; Target selector outside 0x30..0x3F: DSP_RingBuf_Skip either way, the 0x40 test only picks
; which of two identical code paths runs.
DSP_Cmd2B_SkipAndContinue:
	cp_erpb 0xFB, 0x40
	jr nz, DSP_Cmd2B_SkipPath
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_Skip
	jrl DSP_Process_ReadNext

; The other identical skip path.
DSP_Cmd2B_SkipPath:
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_Skip
	jrl DSP_Process_ReadNext

; Message type 0x2C: channel and global configuration. Reads the payload into 0x4370 with
; DSP_RingBuf_ReadAndCompare, then splits on the target selector 0x4369:
;   0x4369 == 0 : global. Requires 0x436A == 8, then the sub-command byte 0x436B is mapped to
;                 a table index: raw 0..8 map to entries 0..8; raw 0x20..0x25 map to entries
;                 9..14 (the code does `wa -= 0x17` and accepts 9..0x0E); everything else,
;                 including any negative value, goes to CmdHandler2C_SubCmd0 (discard).
;   0x4369 != 0 : per-channel, see CmdHandler2C_SubCmd1.
; No reply is ever produced by the 0x2C path -- every route ends at DSP_Process_ReadNext.
DSP_CmdHandler_2C:
	lda xwa, (17264:16)
	ld xbc, xwa
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_ReadAndCompare
	ld a, (17257:16)
	ldfr_berp A, 0xFB
	cpib_erp 0xFB, 0
	jrl nz, CmdHandler2C_SubCmd1
	cp (17258:16), 8
	jrl nz, DSP_Process_ReadNext
	ld a, (17259:16)
	extz wa
	cp wa, 0:i3
	jrl mi, CmdHandler2C_SubCmd0
	cp wa, 0x8
	jr le, CmdHandler2C_JumpDispatch
	sub wa, 0x17
	cp wa, 0x9
	jrl lt, CmdHandler2C_SubCmd0
	cp wa, 0xE
	jrl gt, CmdHandler2C_SubCmd0

; index *= 2; word from ROM 0x0121BD + index; jp (0x035DD2 + that word).
CmdHandler2C_JumpDispatch:
	add wa, wa
	lda xix, (CmdHandler2C_DispatchOffsets:24)
	ld	wa, (xix+wa)
	lda xix, (CmdHandler2C_TableData:24)
	jp	t, (xix+wa)
; ★ NEW MEANING for an address currently labelled as the start of a `.byte` blob.
; Table entry 0 (sub-command 0x00). `ld A,(0x4370) / exts WA / call Voice_SetMasterTune
; (0x028B23) / jrl DSP_Process_ReadNext`. SIGN-extended -- master tune is signed.
; The thirteen stubs at 0x035DD2..0x035E7A are all this shape and are all CODE.
; --- 0x035DD2-0x035E7A  CmdHandler2C_TableData -- NOT DATA, thirteen 13-byte dispatch stubs
; Reached by `lda XIX,0x0121BD / ldw WA,(XIX+index*2) / lda XIX,0x035DD2 / jp (XIX+WA)`.
; The 15-entry offset table itself lives in ROM at 0x0121BD:
;   0x0000 0x000D 0x001A 0x0027 0x0034 0x0261 0x0041 0x004E
;   0x005B 0x0261 0x0068 0x0075 0x0082 0x008F 0x009C
; Adding 0x035DD2 gives 0x035DD2, 0x035DDF, 0x035DEC, 0x035DF9, 0x035E06, 0x036033 (= the
; "ignore" target DSP_Process_ReadNext), 0x035E13, 0x035E20, 0x035E2D, 0x036033, 0x035E3A,
; 0x035E47, 0x035E54, 0x035E61, 0x035E6E -- all named above. Verified by disassembly.
CmdHandler2C_TableData:
	ld	a, (17264:16)
	exts	wa
	call	Voice_SetMasterTune
	jrl	DSP_Process_ReadNext
; ★ NEW NAME. Table entry 1: zero-extends (0x4370) and calls DSP_SET_MIXPARAM_45B2 (0x036205).
CmdHandler2C_Global_MixParamA:
	ld	a, (17264:16)
	extz	wa
	call	DSP_Set_MixParam_45B2
	jrl	DSP_Process_ReadNext
; ★ NEW NAME. Table entry 2: calls DSP_Set_MixParam_45B4 (0x03621C).
CmdHandler2C_Global_MixParamB:
	ld	a, (17264:16)
	extz	wa
	call	DSP_Set_MixParam_45B4
	jrl	DSP_Process_ReadNext
; ★ NEW NAME. Table entry 3: calls ScaleTune_Set_Global_Enabled (0x028D2E).
CmdHandler2C_Global_MonoMode:
	ld	a, (17264:16)
	extz	wa
	call	ScaleTune_Set_Global_Enabled
	jrl	DSP_Process_ReadNext
; ★ NEW NAME. Table entry 4: SIGN-extends (0x4370) and calls Voice_SetPitchBendRange
; (0x028B30).
CmdHandler2C_Global_BendRange:
	ld	a, (17264:16)
	exts	wa
	call	Voice_SetPitchBendRange
	jrl	DSP_Process_ReadNext
; ★ NEW NAME. Table entry 6: calls DSP_Set_FadeLevel (0x036237).
; (Table entries 5 and 9 point straight at DSP_Process_ReadNext, i.e. accepted and ignored.)
CmdHandler2C_Global_MixParamC:
	ld	a, (17264:16)
	extz	wa
	call	DSP_Set_FadeLevel
	jrl	DSP_Process_ReadNext
; ★ NEW NAME. Table entry 7: calls DSP_Set_MicLevel (0x036252).
CmdHandler2C_Global_SetValue45B8:
	ld	a, (17264:16)
	extz	wa
	call	DSP_Set_MicLevel
	jrl	DSP_Process_ReadNext
; ★ NEW NAME. Table entry 8: calls DSP_Set_MicSense (0x03627A).
CmdHandler2C_Global_SetEnable45BA:
	ld	a, (17264:16)
	extz	wa
	call	DSP_Set_MicSense
	jrl	DSP_Process_ReadNext
; ★ NEW NAME. Table entry 10 (raw sub-command 0x21): calls DSP_Set_DigitalReverbOnOff (0x0362A2).
CmdHandler2C_Global_SetValue4504:
	ld	a, (17264:16)
	extz	wa
	call	DSP_Set_DigitalReverbOnOff
	jrl	DSP_Process_ReadNext
; ★ NEW NAME. Table entry 11 (raw 0x22): calls DSP_Set_AcousticIllusionOnOff (0x0362B6).
CmdHandler2C_Global_SetValue453C:
	ld	a, (17264:16)
	extz	wa
	call	DSP_Set_AcousticIllusionOnOff
	jrl	DSP_Process_ReadNext
; ★ NEW NAME. Table entry 12 (raw 0x23): calls DSP_Set_RotarySpeed (0x0362CA), the one
; global setter that re-runs DSP_ApplyAlgoForVoiceType instead of DSP_State_ApplyBuf.
CmdHandler2C_Global_SetAlgoType:
	ld	a, (17264:16)
	extz	wa
	call	DSP_Set_RotarySpeed
	jrl	DSP_Process_ReadNext
; ★ NEW NAME. Table entry 13 (raw 0x24): calls DSP_Set_MicReverbOnOff (0x0362DD).
CmdHandler2C_Global_SetValue4574:
	ld	a, (17264:16)
	extz	wa
	call	DSP_Set_MicReverbOnOff
	jrl	DSP_Process_ReadNext
; ★ NEW NAME. Table entry 14 (raw 0x25): calls DSP_Set_EqualizerOnOff (0x0362F1).
CmdHandler2C_Global_SetValue45AC:
	ld	a, (17264:16)
	extz	wa
	call	DSP_Set_EqualizerOnOff
	jrl	DSP_Process_ReadNext

; Out-of-range global sub-command: DSP_RingBuf_Skip, continue.
CmdHandler2C_SubCmd0:
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_Skip
	jrl DSP_Process_ReadNext

; Per-channel branch. Requires the selector in 0x30..0x3F and 0x436A == 0x7F; channel =
; 0x4369 & 0xF. Sub-command 0x436B: 0x08 -> SubCmd5, 0x06 -> SubCmd4, 0x04 -> SubCmd3,
; 0x03 -> ignore, 0x10..0x17 -> ignore, anything above 0x17 -> SubCmd2 (skip).
CmdHandler2C_SubCmd1:
	cp_erpb 0xFB, 0x30
	jrl c, CmdHandler2C_SubCmd6
	cp_erpb 0xFB, 0x3F
	jrl ugt, CmdHandler2C_SubCmd6
	cp (17258:16), 127
	jrl nz, DSP_Process_ReadNext
	ldto_berp A, 0xFB
	ldfr_berp A, 0xF8
	extz iz
	and iz, 0xF
	lda xwa, (17264:16)
	ld (xsp + 10), xwa
	ld a, (17259:16)
	cp a, 0x8
	jr z, CmdHandler2C_SubCmd5
	cp a, 6:i3
	jr z, CmdHandler2C_SubCmd4
	cp a, 4:i3
	jr z, CmdHandler2C_SubCmd3
	cp a, 3:i3
	jrl z, DSP_Process_ReadNext
	cp a, 0x17
	jr ugt, CmdHandler2C_SubCmd2
	cp a, 0x10
	jrl nc, DSP_Process_ReadNext

; DSP_RingBuf_Skip, continue.
CmdHandler2C_SubCmd2:
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_Skip
	jrl DSP_Process_ReadNext

; Sub-command 0x04: DSP_Reinit_VoiceSlots(WA = payload[0], BC = payload[1]) followed by
; DSP_VoiceState_Dispatch(WA = 0xFF, BC = 0xFF) -- i.e. rebuild every part.
CmdHandler2C_SubCmd3:
	ld a, (17264:16)
	ld e, a
	extz de
	ld a, (17265:16)
	ld c, a
	extz bc
	ld wa, de
	call DSP_Reinit_VoiceSlots
	ldw wa, 0xFF
	ldw bc, 0xFF
	call DSP_VoiceState_Dispatch
	jrl DSP_Process_ReadNext

; Sub-command 0x06: DSP_VoiceState_Dispatch(WA = payload[0], BC = payload[1]).
CmdHandler2C_SubCmd4:
	ld a, (17264:16)
	ld e, a
	extz de
	ld a, (17265:16)
	ld c, a
	extz bc
	ld wa, de
	call DSP_VoiceState_Dispatch
	jrl DSP_Process_ReadNext

; Sub-command 0x08: Voice_AllVoices_PortamentoUpdate().
CmdHandler2C_SubCmd5:
	call Voice_AllVoices_PortamentoUpdate
	jrl DSP_Process_ReadNext

; Selector outside 0x30..0x3F: skip either way (the 0x40 test again picks between two
; identical paths).
CmdHandler2C_SubCmd6:
	cp_erpb 0xFB, 0x40
	jr nz, CmdHandler2C_Epilogue
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_Skip
	jrl DSP_Process_ReadNext

; The other identical skip path.
CmdHandler2C_Epilogue:
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_Skip
	jrl DSP_Process_ReadNext

; Message type 0x2D: effect preset and per-slot configuration.
;   0x4369 == 0 and 0x436A == 0x09 : whole-preset load. DSP_Cmd_LoadEffectPreset; if it
;        returns 0xFFFF the message is dropped, otherwise DSP_ReconfigAndStatus re-applies
;        the buffer.
;   0x4369 == 0 and 0x436A in 0x0A..0x0E : single-slot load, slot = 0x436A - 0x0A, see
;        CmdHandler2D_PathA.
;   0x4369 in 0x30..0x3F : per-channel, see CmdHandler2D_PathD.
;   anything else : skip.
; Like 0x2C, the 0x2D path never sends a reply.
DSP_CmdHandler_2D:
	ld a, (17257:16)
	ldfr_berp A, 0xFB
	cpib_erp 0xFB, 0
	jrl nz, CmdHandler2D_PathD
	ld a, (17258:16)
	ldfr_berp A, 0xFB
	cp_erpb 0xFB, 0x09
	jr nz, CmdHandler2D_PathA
	ld xwa, (xsp + 4)
	calr DSP_Cmd_LoadEffectPreset
	ld wa, hl
	exts xwa
	cp xwa, 0xFFFFFFFF
	jrl z, DSP_Process_ReadNext
	call DSP_ReconfigAndStatus
	jrl DSP_Process_ReadNext

; Single-slot preset. buffer = EFF_GetSlotBuffer(0x436A - 0x0A); if that is 0xFFFFFFFF the
; message is dropped. If the declared payload size (0x436E) exceeds the ring's byte count the
; message is skipped (PathB). Otherwise DSP_RingBuf_ReadAndCompare reads into the slot buffer
; and its result L is passed as E to DSP_ApplyConfig(WA = slot, XBC = 0x4370, E = compare
; result) -- E == 0xFF is the "nothing changed" signal.
CmdHandler2D_PathA:
	cp_erpb 0xFB, 0x0A
	jr c, CmdHandler2D_PathC
	cp_erpb 0xFB, 0x0E
	jr ugt, CmdHandler2D_PathC
	ldto_berp A, 0xFB
	sub a, 0xA
	extz wa
	call EFF_GetSlotBuffer
	ld (xsp + 10), xhl
	ld xwa, (xsp + 10)
	cp xwa, 0xFFFFFFFF
	jrl z, DSP_Process_ReadNext
	ld a, (17262:16)
	ld c, a
	extz bc
	ld xwa, (xsp + 4)
	cp bc, (xwa + 4)
	jr ugt, CmdHandler2D_PathB
	ld xwa, (xsp + 4)
	ld xbc, (xsp + 10)
	calr DSP_RingBuf_ReadAndCompare
	ldto_berp A, 0xFB
	sub a, 0xA
	ldfr_berp A, 0xF0
	extz ix
	lda xwa, (17264:16)
	ld xbc, xwa
	ld e, l
	extz de
	ld wa, ix
	call DSP_ApplyConfig
	jr DSP_Process_ReadNext

; Payload longer than what is queued: skip.
CmdHandler2D_PathB:
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_Skip
	jr DSP_Process_ReadNext

; Slot index out of 0x0A..0x0E: skip.
CmdHandler2D_PathC:
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_Skip
	jr DSP_Process_ReadNext

; Per-channel 0x2D. Reads one payload byte into XBC (zero-extended) with
; DSP_RingBuf_ReadAndCompare; if 0x436A == 0x7F the message is then skipped, otherwise the
; channel (0x4369 - 0x30) is computed into a local and... nothing further is done with it.
; This branch has no observable effect beyond consuming the message.
CmdHandler2D_PathD:
	cp_erpb 0xFB, 0x30
	jr c, CmdHandler2D_EnqueueOrReturn
	cp_erpb 0xFB, 0x3F
	jr ugt, CmdHandler2D_EnqueueOrReturn
	ld a, (17264:16)
	ld xbc, 0:i3
	ld c, a
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_ReadAndCompare
	cp (17258:16), 127
	jr z, CmdHandler2D_MsgSizeMatch
	ldto_berp A, 0xFB
	sub a, 0x30
	ldfr_berp A, 0xF8
	extz iz
	jr DSP_Process_ReadNext

; skip; continue.
CmdHandler2D_MsgSizeMatch:
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_Skip
	jr DSP_Process_ReadNext

; Selector 0x40: read one payload byte, then skip the rest.
CmdHandler2D_EnqueueOrReturn:
	cp_erpb 0xFB, 0x40
	jr nz, CmdHandler2D_QueuedPath
	ld a, (17264:16)
	ld xbc, 0:i3
	ld c, a
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_ReadAndCompare
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_Skip
	jr DSP_Process_ReadNext

; Any other selector: skip.
CmdHandler2D_QueuedPath:
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_Skip
	jr DSP_Process_ReadNext

; Unknown message type (not 0x2B/0x2C/0x2D): DSP_RingBuf_Skip, i.e. the ENTIRE queue is
; resynchronised and discarded.
DSP_Cmd_DefaultSkip:
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_Skip

; Loop head: pop the next type byte from the ring; while it is >= 0 (i.e. not the 0xFFFF
; empty sentinel) go round to DSP_Process_NextCmd. Every handler in the region ends here.
DSP_Process_ReadNext:
	ld xwa, (xsp + 4)
	calr DSP_RingBuf_Read
	ld (xsp + 12), hl
	ld wa, (xsp + 12)
	cp wa, 0:i3
	jrl ge, DSP_Process_NextCmd

; pop xiz; unwind the 10-byte frame; ret.
DSP_Process_Exit:
	pop xiz
	lda xsp, (xsp + 10)
	ret
