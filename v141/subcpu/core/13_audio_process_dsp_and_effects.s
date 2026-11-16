; ===========================================================================
; Audio_Process_DSP - DSP audio processing main loop
; ===========================================================================
; Entry: Called from main audio loop after MIDI_Dispatch
; Exit:  DSP state updated, audio buffers processed
; Notes: Processes pending DSP commands from buffer at 0x3B60
;        Updates DSP2 voice parameters and effect processing
;        Part of main audio loop: ToneGen -> MIDI -> DSP -> Final
; ===========================================================================
; =============================================================================
; Audio_Process_DSP -- Main DSP command processing loop
; =============================================================================
; Consumes commands from the DSP ring buffer (2KB at 0x3B60).
; Each message is 1 framing byte + 7 header bytes:
;   0x2B = voice DSP param update (per-voice effects)
;   0x2C = channel/voice configuration
;   0x2D = DSP effect configuration (preset loads)
; Sub-commands for 0x2B (header byte 2):
;   0x00 -> DSP_AlgoSelect (select algorithm)
;   0x03 -> DSP_EffectStateQuery (state control)
;   0x10-0x17 -> DSP_VoiceParamReadWrite (set param 0-7)
;   0x20 -> DSP_MixSendConfig (mix/send routing)
; Jump table for params 0-7 at Sub CPU ROM 0x0121DB.
; ALREADY NAMED -- doc header only. THIS IS THE ROUTINE THE OPEN BUG SHOULD BE CHECKED
; AGAINST FIRST; see the wedge note below and 'findings'.
; The DSP ring consumer. Called unconditionally once per pass of Audio_Main_Loop (0x01FAE6),
; from the call block at 0x01FB2F, between MIDI_Dispatch and Audio_Process_Final. No entry
; parameters. Local frame of 10 bytes; (XSP+4) holds the ring control-block pointer 0x3B60
; and (XSP+12) holds the current message's type byte.
; Sequence:
;   (0x4366) = ring byte count                                (DSP_StoreBufferCount)
;   if (0x448C) != 0  -> jump straight to DSP_Process_Exit    ** the gate **
;   otherwise -> DSP_Process_ReadNext, which pops one type byte and loops while it is >= 0.
;
; ★★ WEDGE (in-region, address-precise). The word at 0x448C gates the entire consumer, and
;    it is written from exactly five instructions in the firmware (byte-verified with
;    unidasm; grep the source for 17548 to see the same five):
;      0x0358BB  ++(0x448C)     Audio_CmdHandler_60_7F, chunk accumulated
;      0x0358C7  (0x448C) = 0   Audio_CmdHandler_60_7F, stream complete
;      0x0358F6  (0x448C) = 1   Audio_CmdHandler_60_7F, stream header accepted
;      0x035904  (0x448C) = 0   Audio_CmdHandler_60_7F, malformed opening chunk
;      0x035B12  (0x448C) = 1   Audio_Process_DSP itself, TRUNCATED-MESSAGE path
;    and read from exactly two: 0x035899/0x0358A1 (the handler) and 0x035AD9 (the gate).
;    The last one is the problem: DSP_Process_NextCmd sets the same flag that means "a bulk
;    stream is in flight" to mean "the message I am looking at is not fully queued yet".
;    Once it is set, Audio_Process_DSP does nothing at all on every subsequent pass, forever,
;    unless a NEW inter-CPU command in the 0x60..0x7F class arrives AND the byte accounting
;    in 0x4488/0x448A happens to reach completion (or the chunk is malformed). DSP2_Init does
;    not clear it; DSP_Reset does not clear it; nothing in the audio loop clears it.
;    Downstream effect: DSP_Cmd2B_PostProcess (0x035D4A) is the ONLY producer of sub->main
;    traffic in this region, and it is only reachable through this consumer. So the wedge
;    presents exactly as "the sub-CPU keeps consuming main->sub commands (they are still
;    enqueued by Audio_CmdHandler_60_7F) but stops replying, at a fixed point".
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

; Emits an audible/internal confirmation for the current algorithm class. Entry WA = the
; algorithm/voice-type word. Calls DSP_State_LookupAlgoIndex(WA) and, on the result 2 / 1 /
; anything else, pushes the 4-byte canned message at ROM 0x0121F3 / 0x0121EF / 0x0121EB
; (`F0 50 B0 06`, `F0 50 B0 05`, `F0 50 B0 01`) into the MIDI ring via
; Audio_CmdHandler_00_1F(count = 4, ptr) and then tail-jumps to MIDI_Dispatch so the packet
; is consumed immediately. Because the status byte is 0xF0, MIDI_Dispatch routes it to
; Voice_Poly_NoteOn, which allocates one of the eight auxiliary tone-generator voices.
; Called from DSP_Reset. Hardware: the tone generator, indirectly, one note.
DSP_WriteAlgoInitPreset:	.include "includes/generated/cc900/DSP_WriteAlgoInitPreset.s"	; C: cc900/audio_process_dsp_and_effects.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_WriteAlgoInitPreset_PresetPath, DSP_WriteAlgoInitPreset + 27
	.set	DSP_WriteAlgoInitPreset_DefaultPath, DSP_WriteAlgoInitPreset + 48
	.set	DSP_WriteAlgoInitPreset_Epilogue, DSP_WriteAlgoInitPreset + 63

; ALREADY NAMED -- doc header only.
; Entry WA = voice-type word. Returns immediately unless WA is 0x35 or 0x0F. For those two
; it copies the word (0x45B0) into (0x44B4) -- which is 0x4496 + 0x1E, i.e. SLOT 0's record
; at offset +0x1E, the same field EFF_SlotActive_LoopNext reads as a dirty-array index --
; and then calls DSP_State_ApplyBuf(XWA = 0x448E) to push the whole
; configuration to the DSP. Callers: DSP_Reset, DSP_ApplyConfig, DSP_ReconfigAndStatus, and
; the global setter DSP_Set_RotarySpeed.
DSP_ApplyAlgoForVoiceType:
	cp wa, 0x35
	jr z, DSP_ApplyAlgoForVoiceType_TypeF
	cp wa, 0xF
	ret nz

; The shared body for both accepted voice types.
DSP_ApplyAlgoForVoiceType_TypeF:
	ldmm16 17588, 17840	; LDW_16_16 (044b4h), (045b0h)
	lda xwa, (DSP_ConfigBuffer:16)
	call DSP_State_ApplyBuf
	ret

; ALREADY NAMED -- doc header only. Full DSP subsystem reset; called once from the audio
; init path at 0x032183. No parameters.
;   (0x45B0) = 1 ; (0x45B2) = (0x45B4) = (0x45B6) = (0x45B8) = (0x45BA) = 0
;   DSP_MixerCoeff_Compute(WA = (0x45B2), BC = (0x45B4), DE = (0x45B6))   [0x03C067]
;   copy 0x91 words (290 bytes) from 0xF01E in internal RAM to 0x448E -- this is where the
;     default effect configuration comes from, and 290 == the 0x122 size guard elsewhere
;   DSP_State_LoadAndApplyAll(XWA = 0x448E) ; (0x4492) = 0 ; DSP_State_DmaLoadPresets()
;   IZ = word at 0xF026 (a firmware-config word in internal RAM);
;     DSP_WriteAlgoInitPreset(IZ) then DSP_ApplyAlgoForVoiceType(IZ)
;   DSP_MixerCoeff_Compute again with the (now possibly changed) three words.
; ★ Does NOT clear 0x4488/0x448A/0x448C, so a DSP reset does not clear the consumer wedge.
DSP_Reset:	.include "includes/generated/cc900/DSP_Reset.s"	; C: cc900/audio_process_dsp_and_effects_d_6a.c

; A lone `ret`: the do-nothing task body that entries 1, 2 and 3 of DSP_ResetTask_PtrTable
; (subcpu_data_tables.s) point to, beside entry 0 = DSP_Reset -- the same shape as
; DSP2_InitTask_NullStub.  ★ Renamed 2026-09-25 from DSP_ApplyAlgoForVoiceType_Data and written as
; the instruction it is (it was `.byte 0x0e`).
DSP_ResetTask_NullStub:	.include "includes/generated/cc900/DSP_ResetTask_NullStub.s"	; C: cc900/audio_process_dsp_and_effects.c

; Entry: none. Calls DSP_SlotMuteState_ReadAndClear(0) and, on the returned value 3 / 2 / 1,
; injects the same canned pseudo-MIDI packet as DSP_WriteAlgoInitPreset (ROM 0x0121F3 /
; 0x0121EF / 0x0121EB) through Audio_CmdHandler_00_1F + MIDI_Dispatch. Value 0 does nothing.
; Called from Audio_Process_Init (0x034CDB) when the audio-tick phase byte at 0x041342 is 0,
; right after Audio_Tick_ServiceVoices_A -- i.e. this is the "re-announce the effect state
; after a mode change" path.
DSP_SlotState_DisplayRestore:	.include "includes/generated/cc900/DSP_SlotState_DisplayRestore.s"	; C: cc900/audio_process_dsp_and_effects.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_SlotState_DisplayRestore_ActivePath, DSP_SlotState_DisplayRestore + 29
	.set	DSP_SlotState_DisplayRestore_Epilogue, DSP_SlotState_DisplayRestore + 52

; ALREADY NAMED -- doc header only.
; Applies one effect slot's configuration. Entry WA (low byte A) = slot 0..4, E = the
; "changed" indicator from DSP_RingBuf_ReadAndCompare, XBC = 0x4370.
;   (0x448E) = 1 when E == 0xFF (nothing changed), else 0. That header word is therefore the
;   "this configuration is unchanged / not freshly loaded" flag that DSP_State_ApplyBuf reads.
; Then, on the slot number: 1, 2 or 4 -> tail-jump DSP_State_ApplyBuf(0x448E);
;   3 -> BufSelectB (see below); 0 -> DSP_State_ApplyBuf followed by
;   DSP_ApplyAlgoForVoiceType(word at 0x4496, i.e. slot 0's algorithm number);
;   anything else -> return without doing anything.
DSP_ApplyConfig:	.include "includes/generated/cc900/DSP_ApplyConfig.s"	; C: cc900/audio_process_dsp_and_effects_d_6c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_ApplyConfig_ActivePath, DSP_ApplyConfig + 13
	.set	DSP_ApplyConfig_InactivePath, DSP_ApplyConfig + 19
	.set	DSP_ApplyConfig_BufSelectA, DSP_ApplyConfig + 54
	.set	DSP_ApplyConfig_BufSelectB, DSP_ApplyConfig + 62
	.set	DSP_ApplyConfig_Epilogue, DSP_ApplyConfig + 80

; ALREADY NAMED -- doc header only. DSP_State_ApplyBuf(0x448E) then
; DSP_ApplyAlgoForVoiceType(word at 0x4496). The unconditional form of DSP_ApplyConfig's
; slot-0 case; called after a successful whole-preset load in DSP_CmdHandler_2D.
DSP_ReconfigAndStatus:	.include "includes/generated/cc900/DSP_ReconfigAndStatus.s"	; C: cc900/audio_process_dsp_and_effects_d_6a.c

; ALREADY NAMED -- doc header only. XHL = 0x448E. Three bytes.
DSP_GetConfigBuffer:	.include "includes/generated/cc900/DSP_GetConfigBuffer.s"	; C: cc900/audio_process_dsp_and_effects.c

; ALREADY NAMED -- doc header only.
; Entry WA = slot. Exit XHL = 0x4496 + slot * 0x38 for slot in 0..4, or 0xFFFFFFFF for any
; other slot. The five explicit `cps bc,n / jr z` tests for 0..4 are the range check; the
; fall-through to EFF_GetSlotBuffer_LoopBody is the error case.
EFF_GetSlotBuffer:	.include "includes/generated/cc900/EFF_GetSlotBuffer.s"	; C: cc900/audio_process_dsp_and_effects_d_7a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	EFF_GetSlotBuffer_NoSlot, EFF_GetSlotBuffer + 22
	.set	EFF_GetSlotBuffer_LoopBody, EFF_GetSlotBuffer + 38
	.set	EFF_GetSlotBuffer_Epilogue, EFF_GetSlotBuffer + 43

; ★ NEW MEANING. This address is currently labelled DSP_StateTable_DefaultData and its 256
; bytes are emitted as `.byte`. They are ten subroutines; this is the first.
; (0x45B2) = zero-extended WA, then tail-jump DSP_MixerCoeff_Compute(WA = (0x45B2),
; BC = (0x45B4), DE = (0x45B6)) at 0x03C067 -- the identical three-argument call DSP_Reset
; makes. Reached only from CmdHandler2C global sub-command 0x01.
; The four bytes at 0x036217 (`ld HL,(0x45B2) / ret`) are UNREACHABLE -- the `jp` above them
; is unconditional. Same dead tail appears in the next two setters; they look like a
; hand-optimised `return value` that the compiler/author replaced with a tail call.
; --- 0x036205-0x036304  DSP_StateTable_DefaultData -- NOT DATA, ten subroutines
; See the ten [ROUTINE] entries at 0x036205, 0x03621C, 0x036237, 0x036252, 0x03627A,
; 0x0362A2, 0x0362B6, 0x0362CA, 0x0362DD, 0x0362F1. Reached only from the thirteen stubs
; above. Includes four unreachable 5-byte tails at 0x036217, 0x036232, 0x03624D and
; 0x036275.
; ★ Renamed 2026-09-25 from DSP_StateTable_DefaultData: header: (0x45B2) = WA then DSP_MixerCoeff_Compute; siblings DSP_Set_MixParam_45B4/_45B6.
DSP_Set_MixParam_45B2:	.include "includes/generated/cc900/DSP_Set_MixParam_45B2.s"	; C: cc900/audio_process_dsp_and_effects_b.c
	ld	hl, (17842:16)
	ret
; ★ NEW NAME. (0x45B4) = WA, reload all three, tail-jump DSP_MixerCoeff_Compute. Dead tail at
; 0x036232. CmdHandler2C global sub-command 0x02.
DSP_Set_MixParam_45B4:	.include "includes/generated/cc900/DSP_Set_MixParam_45B4.s"	; C: cc900/audio_process_dsp_and_effects.c
	ld	hl, (17844:16)
	ret
; ★ NEW NAME. (0x45B6) = WA, reload all three, tail-jump DSP_MixerCoeff_Compute. Dead tail at
; 0x03624D. CmdHandler2C global sub-command 0x06.
; DSP_Set_FadeLevel: Global 0x2C sub-command 0x06: stores the FADE IN/OUT level (main-CPU parameter 0x4005, 0..127,
;   ramped by the fade logic) at 0x45B6 and recomputes the DSP2 output gain through DSP_MixerCoeff_Compute (its DE
;   index into DSP2_MixerGain_Curve, registers 0xD0/0xD3). Basis: caller + main-CPU sender + body.
DSP_Set_FadeLevel:	.include "includes/generated/cc900/DSP_Set_FadeLevel.s"	; C: cc900/audio_process_dsp_and_effects.c
	ld	hl, (17846:16)
	ret
; ★ NEW NAME. (0x45B8) = WA. Returns immediately if (0x45BA) == 0 -- i.e. the value is only
; propagated when its enable word is set. Otherwise (0x448E) = 0 ("changed"),
; (0x454A) = (0x45B8), then DSP_State_ApplyBuf(XWA = 0x448E). Dead tail at 0x036275.
; CmdHandler2C global sub-command 0x07.
; DSP_Set_MicLevel: Global 0x2C sub-command 0x07: stores the microphone level (main-CPU parameter 0x4141, 0..127, sent
;   as 0 while 0x4142 is set) at 0x45B8 and, if MICSNS (0x45BA) is set, copies it into EFF slot 3's parameter word
;   +0x0C (0x454A) and applies the block. Basis: caller + main-CPU sender + body.
DSP_Set_MicLevel:
	; Converted from a 80-byte `.byte` run. Framing: unidasm; every
	; instruction re-encoded and the whole run compared byte for byte.
	; 22 instructions, of which 3 needed a spelling search because
	; llvm-mc --disassemble refuses them (it can still ASSEMBLE them).
	extz	wa
	ld	(17848:16), wa
	cpw	(17850:16), 0
	ret	z
	ldw	(DSP_ConfigBuffer:16), 0
	ldmm16	17738, 17848
	lda	xwa, (DSP_ConfigBuffer:16)
	call	DSP_State_ApplyBuf
	ret
	ld	hl, (17848:16)
	ret
; ★ NEW NAME. (0x45BA) = zero-extended A (the enable for the value above). (0x448E) = 0, then
; (0x454A) = (0x45B8) if A != 0 else 0, then tail-jump DSP_State_ApplyBuf(0x448E).
; CmdHandler2C global sub-command 0x08. Together with the previous routine this is a classic
; "depth + on/off" pair where 0x454A is the effective value handed to the DSP.
; DSP_Set_MicSense: Global 0x2C sub-command 0x08: stores the main CPU's MICSNS level (PE.4, sent on every change) at
;   0x45BA; while it is non-zero the mic level (0x45B8) is copied into EFF slot 3's parameter word +0x0C (0x454A),
;   otherwise 0, and the block is applied. Basis: caller + main-CPU sender + body.
DSP_Set_MicSense:
	ld	c, a
	extz	bc
	ld	(17850:16), bc
	ldw	(DSP_ConfigBuffer:16), 0
	cp	a, 0:i3
	jr	z, DSP_Set_Enable_45BA_Skip
	ldmm16	17738, 17848
	jr	DSP_Set_Enable_45BA_Join
DSP_Set_Enable_45BA_Skip:
	ldw	(17738:16), 0
DSP_Set_Enable_45BA_Join:
	lda	xwa, (DSP_ConfigBuffer:16)
	jp	DSP_State_ApplyBuf
; ★ NEW NAME. (0x448E) = 0 ; (0x4504) = WA ; tail-jump DSP_State_ApplyBuf(0x448E).
; 0x4504 = 0x4496 + 0x6E = slot 1 record + 0x36. CmdHandler2C global sub-command 0x21.
; DSP_Set_DigitalReverbOnOff: Global 0x2C sub-command 0x21: stores WA (0/1) in EFF slot 1's +0x36 link word (0x4504)
;   and hands the config block to DSP_State_ApplyBuf -- the DIGITAL REVERB on/off switch. Basis: caller + main-CPU
;   sender + readers -- 1 = EFF_LinkLoop links the slot into the chain, 0 = EFF_SecondaryLinkPath disconnects it.
DSP_Set_DigitalReverbOnOff:	.include "includes/generated/cc900/DSP_Set_DigitalReverbOnOff.s"	; C: cc900/audio_process_dsp_and_effects.c
; ★ NEW NAME. Same shape, target (0x453C) = 0x4496 + 0xA6 = slot 2 record + 0x36.
; CmdHandler2C global sub-command 0x22.
; DSP_Set_AcousticIllusionOnOff: Global 0x2C sub-command 0x22: stores WA (0/1) in EFF slot 2's +0x36 link word
;   (0x453C) and hands the config block to DSP_State_ApplyBuf -- the ACOUSTIC ILLUSION on/off switch. Basis: caller +
;   main-CPU sender + readers -- 1 = EFF_LinkLoop links the slot into the chain, 0 = EFF_SecondaryLinkPath disconnects
;   it.
DSP_Set_AcousticIllusionOnOff:	.include "includes/generated/cc900/DSP_Set_AcousticIllusionOnOff.s"	; C: cc900/audio_process_dsp_and_effects.c
; ★ NEW NAME. (0x448E) = 0 ; (0x45B0) = WA ; then WA = (0x4496) (slot 0's algorithm number)
; and a long jump to DSP_ApplyAlgoForVoiceType (0x03608C) -- the only one of the ten setters
; that goes through the algorithm path rather than straight to DSP_State_ApplyBuf.
; CmdHandler2C global sub-command 0x23.
; DSP_Set_RotarySpeed: Global 0x2C sub-command 0x23: stores the rotary-speaker speed switch (main-CPU parameter
;   0x4003, sent as 0/1) at 0x45B0, then DSP_ApplyAlgoForVoiceType copies it into DSP EFFECT slot 0's parameter word
;   +0x1E only when slot 0's algorithm is 15 ROCK ROTARY or 53 ROTARY SPEAKER. Basis: caller + main-CPU sender +
;   reader.
DSP_Set_RotarySpeed:	.include "includes/generated/cc900/DSP_Set_RotarySpeed.s"	; C: cc900/audio_process_dsp_and_effects_d_6a.c
; ★ NEW NAME. Target (0x4574) = 0x4496 + 0xDE = slot 3 record + 0x36. Global sub-command 0x24.
; DSP_Set_MicReverbOnOff: Global 0x2C sub-command 0x24: stores WA (0/1) in EFF slot 3's +0x36 link word (0x4574) and
;   hands the config block to DSP_State_ApplyBuf -- the microphone reverb (slot 3: ROOM/KARAOKE/BATH ROOM/STAGE)
;   on/off switch. Basis: caller + main-CPU sender + readers -- 1 = EFF_LinkLoop links the slot into the chain, 0 =
;   EFF_SecondaryLinkPath disconnects it.
DSP_Set_MicReverbOnOff:	.include "includes/generated/cc900/DSP_Set_MicReverbOnOff.s"	; C: cc900/audio_process_dsp_and_effects.c
; ★ NEW NAME. Target (0x45AC) = 0x4496 + 0x116 = slot 4 record + 0x36. Global sub-command
; 0x25. Note the four addresses 0x4504/0x453C/0x4574/0x45AC together with 0x44CC (slot 0)
; form the per-slot +0x36 word that DSP_EFFParam_DiffAlgoSection diffs -- so global
; sub-commands 0x21..0x25 set that one word for slots 1,2,-,3,4 respectively. Slot 0's
; equivalent is not exposed here.
; DSP_Set_EqualizerOnOff: Global 0x2C sub-command 0x25: stores WA (0/1) in EFF slot 4's +0x36 link word (0x45AC) and
;   hands the config block to DSP_State_ApplyBuf -- the EQUALIZER on/off switch. Basis: caller + main-CPU sender +
;   readers -- 1 = EFF_LinkLoop links the slot into the chain, 0 = EFF_SecondaryLinkPath disconnects it.
DSP_Set_EqualizerOnOff:	.include "includes/generated/cc900/DSP_Set_EqualizerOnOff.s"	; C: cc900/audio_process_dsp_and_effects.c

; ALREADY NAMED -- doc header only.
; Blocking delay measured on the 32-bit free-running tick at 0x1040.
; Entry WA = delay in half-ticks: target = (0x1040) + ((WA + 1) >> 1). While (0x1040) is
; below the target it calls Kernel_YieldRotate(3) and re-tests.
; ★ There is NO iteration cap. If the tick at 0x1040 stops advancing this never returns.
; Callers are outside the region (0x039128 and a tail jump at 0x039472, both in the DSP
; microprogram download path).
DSP_WaitForDelay:	.include "includes/generated/cc900/DSP_WaitForDelay.s"	; C: cc900/audio_process_dsp_and_effects_kernel.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_WaitForTaskSlot_Loop, DSP_WaitForDelay + 20
	.set	DSP_WaitForTaskSlot_Epilogue, DSP_WaitForDelay + 32

; --- 0x036327-0x03632A  DSP_WaitForTaskSlot_Data -- four bytes 1b 0f 8e 03
; ★ CORRECTED: this is TASK 3's ENTRY POINT, not "an unreachable tail jump".  Record 3 of
; TaskSched_TaskDescriptorTable holds 0x00036327 in its +0 (entry PC) field; Kernel_StartTask(3),
; called from DSP_State_DmaLoadPresets, puts it in the saved-PC slot of task 3's first context
; frame, so the first dispatch of task 3 lands here and jumps to the task body
; DSP_State_ApplyTask (0x038E0F, formerly DSP_State_InlineData).  Renamed from
; DSP_WaitForTaskSlot_Data.
; Task3_EnterDspApplyLoop: Entry PC of task 3 (TaskSched_TaskDescriptorTable record 3): `jp DSP_State_ApplyTask`, the
;   forever loop that takes DSP configuration images from message queue 2, applies them with DSP_State_ApplyAll and
;   returns the buffers to queue 1. Basis: descriptor table + body + its spawner DSP_State_DmaLoadPresets.
Task3_EnterDspApplyLoop:	.include "includes/generated/cc900/Task3_EnterDspApplyLoop.s"	; C: cc900/audio_process_dsp_and_effects.c

; ALREADY NAMED -- doc header only. `Kernel_SemaWait(1)` as a tail jump. Called at the top of
; DSP2_Send_Command so the bit-bang burst starts on a fresh scheduler slice.
DSP_WakeAudioTask:	.include "includes/generated/cc900/DSP_WakeAudioTask.s"	; C: cc900/audio_process_dsp_and_effects_kernel.c

; ----------------------------------------------------------------------------
; DSP_Send_Command - Send a command byte to DSP chip
; Entry: BC = chip number (0=DSP1, 1=DSP2)
;        A  = command byte to send
; Exit:  HL = 0 on success, 1 on timeout
; Notes: Polls DSP status with timeout of 0x1F40 iterations (~8000)
;        Writes command byte to port PZ when DSP is ready
; ----------------------------------------------------------------------------
; ALREADY NAMED -- doc header only. Transport for DSP1 (IC311, the parallel-bus DSP).
; Entry BC = chip number, A = command byte. Exit HL = 0 on success, 1 on timeout/error.
; Ready poll: DSP_Deassert_Read, DSP_Deassert_Write, DSP_Select_Chip, DSP_Read_Status,
; DSP_Deselect_Chip -- all bracketed by `ei 6` / `ei 0`, i.e. interrupts below level 6 are
; masked for the duration of each poll and re-enabled between polls. Timeout counter starts
; at 0x1F40 (8000) polls, so this ALWAYS terminates.
; On ready: DSP_Assert_Write, DSP_Set_Command_Mode, re-read status, and if status is non-zero
; write the byte to SFR 0x68 (port PZ). Cleanup always runs DSP_Deselect_Chip,
; DSP_Deassert_Write, DSP_Set_Data_Mode.
; ★ Unconditionally calls Debug_Print_String(ROM 0x012207 = "\n[") + Debug_Print_Byte(cmd) +
;   Debug_Print_String(ROM 0x01220A = "]\n") on EVERY byte, success or failure.
DSP_Send_Command:	; 036331h
	dec 8, xsp
	pushw iz
	ld (xsp + 6), bc	; Save chip number
	ld (xsp + 8), a	; Save command byte
	ldw (xsp + 4), 0x0	; Result = success
	ldw (xsp + 2), 0x1F40	; Timeout counter
	ei 6
	call DSP_Deassert_Read
	call DSP_Deassert_Write
	ld wa, (xsp + 6)
	call DSP_Select_Chip
	ld wa, (xsp + 6)
	call DSP_Read_Status
	ld iz, hl
	ld wa, (xsp + 6)
	call DSP_Deselect_Chip
	ei 0
	cp iz, 0:i3
	jr nz, DSP_Send_Cmd_Ready

; Timeout decrement; on expiry set result = 1 and go to cleanup.
DSP_Send_Cmd_WaitLoop:
	ld wa, (xsp + 2)	; Get timeout counter
	decm 1, (xsp + 2)	; Decrement
	cp wa, 0:i3
	jr nz, DSP_Send_Cmd_Poll
	ldw (xsp + 4), 0x1	; Timeout - set error
	jr DSP_Send_Cmd_Cleanup

; One status poll.
DSP_Send_Cmd_Poll:
	ei 6
	call DSP_Deassert_Read
	call DSP_Deassert_Write
	ld wa, (xsp + 6)
	call DSP_Select_Chip
	ld wa, (xsp + 6)
	call DSP_Read_Status
	ld iz, hl
	ld wa, (xsp + 6)
	call DSP_Deselect_Chip
	ei 0
	cp iz, 0:i3
	jr z, DSP_Send_Cmd_WaitLoop	; Still not ready, keep waiting

; DSP reported ready: switch to command mode and write SFR 0x68.
DSP_Send_Cmd_Ready:
	ei 6
	ld wa, (xsp + 6)
	call DSP_Deselect_Chip
	call DSP_Deassert_Read
	call DSP_Assert_Write
	call DSP_Set_Command_Mode
	ld wa, (xsp + 6)
	call DSP_Select_Chip
	ld wa, (xsp + 6)
	call DSP_Read_Status
	cp hl, 0:i3
	jr z, DSP_Send_Cmd_Error
	ld a, (xsp + 8)	; Get command byte
	ld	(PZ:8), a	; Write to DSP data port
	jr DSP_Send_Cmd_Cleanup

; Status went back to zero between poll and write: result = 1.
DSP_Send_Cmd_Error:
	ldw (xsp + 4), 0x1	; Set error flag

; Deselect, deassert, back to data mode, print, return the result word.
DSP_Send_Cmd_Cleanup:
	ld wa, (xsp + 6)
	call DSP_Deselect_Chip
	call DSP_Deassert_Write
	call DSP_Set_Data_Mode
	ei 0
	lda xwa, (Str_DspTrace_CmdOpen:24)
	call Debug_Print_String
	ld a, (xsp + 8)
	extz wa
	call Debug_Print_Byte
	lda xwa, (Str_DspTrace_CmdClose:24)
	call Debug_Print_String
	ld hl, (xsp + 4)	; Return result
	popw iz
	inc 8, xsp
	ret

; ALREADY NAMED -- doc header only, and see [UNCERTAIN]: this is a START condition, not a
; clock pulse.
; Bit-bangs the two-wire link to the second DSP (IC310, MN19413) on port PF (SFR 0x3C):
;   PF bit 2 = clock, PF bit 0 = data.
; Sequence, with all delays realised as chains of `nop` + `jr $+2`:
;   set 2,(PF)        clock high
;   ~19 nops
;   set 0,(PF)        data high
;   1 nop
;   res 0,(PF)        data LOW while clock is HIGH   <-- this is an I2C-style START
;   ~16 nops
;   res 2,(PF)        clock low
;   ~19 nops
;   jp Debug_Print_String(ROM 0x01220D = "\n<sta>\n")
; The trace string "<sta>" is the firmware author's own confirmation that this is "start".
DSP2_SPI_ClockPulseHigh:	.include "includes/generated/cc900/DSP2_SPI_ClockPulseHigh.s"	; C: cc900/audio_process_dsp_and_effects_inlinejr.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP2_ClkHigh_Nop01, DSP2_SPI_ClockPulseHigh + 5
	.set	DSP2_ClkHigh_Nop02, DSP2_SPI_ClockPulseHigh + 8
	.set	DSP2_ClkHigh_Nop03, DSP2_SPI_ClockPulseHigh + 11
	.set	DSP2_ClkHigh_Nop04, DSP2_SPI_ClockPulseHigh + 14
	.set	DSP2_ClkHigh_Nop05, DSP2_SPI_ClockPulseHigh + 17
	.set	DSP2_ClkHigh_Nop06, DSP2_SPI_ClockPulseHigh + 20
	.set	DSP2_ClkHigh_Nop07, DSP2_SPI_ClockPulseHigh + 23
	.set	DSP2_ClkHigh_Nop08, DSP2_SPI_ClockPulseHigh + 26
	.set	DSP2_ClkHigh_Nop09, DSP2_SPI_ClockPulseHigh + 29
	.set	DSP2_ClkHigh_Nop10, DSP2_SPI_ClockPulseHigh + 32
	.set	DSP2_ClkHigh_Nop11, DSP2_SPI_ClockPulseHigh + 35
	.set	DSP2_ClkHigh_Nop12, DSP2_SPI_ClockPulseHigh + 38
	.set	DSP2_ClkHigh_Nop13, DSP2_SPI_ClockPulseHigh + 41
	.set	DSP2_ClkHigh_Nop14, DSP2_SPI_ClockPulseHigh + 44
	.set	DSP2_ClkHigh_Nop15, DSP2_SPI_ClockPulseHigh + 47
	.set	DSP2_ClkHigh_Nop16, DSP2_SPI_ClockPulseHigh + 50
	.set	DSP2_ClkHigh_Nop17, DSP2_SPI_ClockPulseHigh + 53
	.set	DSP2_ClkHigh_Nop18, DSP2_SPI_ClockPulseHigh + 56
	.set	DSP2_ClkHigh_Nop19, DSP2_SPI_ClockPulseHigh + 59
	.set	DSP2_ClkHigh_Nop20, DSP2_SPI_ClockPulseHigh + 65
	.set	DSP2_ClkHigh_Nop21, DSP2_SPI_ClockPulseHigh + 71
	.set	DSP2_ClkHigh_Nop22, DSP2_SPI_ClockPulseHigh + 74
	.set	DSP2_ClkHigh_Nop23, DSP2_SPI_ClockPulseHigh + 77
	.set	DSP2_ClkHigh_Nop24, DSP2_SPI_ClockPulseHigh + 80
	.set	DSP2_ClkHigh_Nop25, DSP2_SPI_ClockPulseHigh + 83
	.set	DSP2_ClkHigh_Nop26, DSP2_SPI_ClockPulseHigh + 86
	.set	DSP2_ClkHigh_Nop27, DSP2_SPI_ClockPulseHigh + 89
	.set	DSP2_ClkHigh_Nop28, DSP2_SPI_ClockPulseHigh + 92
	.set	DSP2_ClkHigh_Nop29, DSP2_SPI_ClockPulseHigh + 95
	.set	DSP2_ClkHigh_Nop30, DSP2_SPI_ClockPulseHigh + 98
	.set	DSP2_ClkHigh_Nop31, DSP2_SPI_ClockPulseHigh + 101
	.set	DSP2_ClkHigh_Nop32, DSP2_SPI_ClockPulseHigh + 104
	.set	DSP2_ClkHigh_Nop33, DSP2_SPI_ClockPulseHigh + 107
	.set	DSP2_ClkHigh_Nop34, DSP2_SPI_ClockPulseHigh + 110
	.set	DSP2_ClkHigh_Nop35, DSP2_SPI_ClockPulseHigh + 113
	.set	DSP2_ClkHigh_Nop36, DSP2_SPI_ClockPulseHigh + 116
	.set	DSP2_ClkHigh_Nop37, DSP2_SPI_ClockPulseHigh + 122
	.set	DSP2_ClkHigh_Nop38, DSP2_SPI_ClockPulseHigh + 125
	.set	DSP2_ClkHigh_Nop39, DSP2_SPI_ClockPulseHigh + 128
	.set	DSP2_ClkHigh_Nop40, DSP2_SPI_ClockPulseHigh + 131
	.set	DSP2_ClkHigh_Nop41, DSP2_SPI_ClockPulseHigh + 134
	.set	DSP2_ClkHigh_Nop42, DSP2_SPI_ClockPulseHigh + 137
	.set	DSP2_ClkHigh_Nop43, DSP2_SPI_ClockPulseHigh + 140
	.set	DSP2_ClkHigh_Nop44, DSP2_SPI_ClockPulseHigh + 143
	.set	DSP2_ClkHigh_Nop45, DSP2_SPI_ClockPulseHigh + 146
	.set	DSP2_ClkHigh_Nop46, DSP2_SPI_ClockPulseHigh + 149
	.set	DSP2_ClkHigh_Nop47, DSP2_SPI_ClockPulseHigh + 152
	.set	DSP2_ClkHigh_Nop48, DSP2_SPI_ClockPulseHigh + 155
	.set	DSP2_ClkHigh_Nop49, DSP2_SPI_ClockPulseHigh + 158
	.set	DSP2_ClkHigh_Nop50, DSP2_SPI_ClockPulseHigh + 161
	.set	DSP2_ClkHigh_Nop51, DSP2_SPI_ClockPulseHigh + 164
	.set	DSP2_ClkHigh_Nop52, DSP2_SPI_ClockPulseHigh + 167
	.set	DSP2_ClkHigh_Nop53, DSP2_SPI_ClockPulseHigh + 170
	.set	DSP2_ClkHigh_Nop54, DSP2_SPI_ClockPulseHigh + 173
	.set	DSP2_ClkHigh_Nop55, DSP2_SPI_ClockPulseHigh + 176

; ALREADY NAMED. Same bus, the STOP condition: res 2,(PF), res 0,(PF), ~96 nops,
; set 2,(PF) (clock high), ~24 nops, set 0,(PF) (data goes HIGH while clock is HIGH = STOP),
; then ~134 nops of guaranteed bus-idle time, then jp Debug_Print_String(ROM 0x012215 =
; "\n<stp>\n"). Port writes are at 0x0364C4, 0x0364C7, 0x036538, 0x03656B only.
DSP2_SPI_BusIdle:	.include "includes/generated/cc900/DSP2_SPI_BusIdle.s"	; C: cc900/audio_process_dsp_and_effects_inlinejr.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP2_BusIdle_Nop01, DSP2_SPI_BusIdle + 8
	.set	DSP2_BusIdle_Nop02, DSP2_SPI_BusIdle + 11
	.set	DSP2_BusIdle_Nop03, DSP2_SPI_BusIdle + 14
	.set	DSP2_BusIdle_Nop04, DSP2_SPI_BusIdle + 17
	.set	DSP2_BusIdle_Nop05, DSP2_SPI_BusIdle + 20
	.set	DSP2_BusIdle_Nop06, DSP2_SPI_BusIdle + 23
	.set	DSP2_BusIdle_Nop07, DSP2_SPI_BusIdle + 26
	.set	DSP2_BusIdle_Nop08, DSP2_SPI_BusIdle + 29
	.set	DSP2_BusIdle_Nop09, DSP2_SPI_BusIdle + 32
	.set	DSP2_BusIdle_Nop10, DSP2_SPI_BusIdle + 35
	.set	DSP2_BusIdle_Nop11, DSP2_SPI_BusIdle + 38
	.set	DSP2_BusIdle_Nop12, DSP2_SPI_BusIdle + 41
	.set	DSP2_BusIdle_Nop13, DSP2_SPI_BusIdle + 44
	.set	DSP2_BusIdle_Nop14, DSP2_SPI_BusIdle + 47
	.set	DSP2_BusIdle_Nop15, DSP2_SPI_BusIdle + 50
	.set	DSP2_BusIdle_Nop16, DSP2_SPI_BusIdle + 53
	.set	DSP2_BusIdle_Nop17, DSP2_SPI_BusIdle + 56
	.set	DSP2_BusIdle_Nop18, DSP2_SPI_BusIdle + 59
	.set	DSP2_BusIdle_Nop19, DSP2_SPI_BusIdle + 62
	.set	DSP2_BusIdle_Nop20, DSP2_SPI_BusIdle + 68
	.set	DSP2_BusIdle_Nop21, DSP2_SPI_BusIdle + 71
	.set	DSP2_BusIdle_Nop22, DSP2_SPI_BusIdle + 74
	.set	DSP2_BusIdle_Nop23, DSP2_SPI_BusIdle + 77
	.set	DSP2_BusIdle_Nop24, DSP2_SPI_BusIdle + 80
	.set	DSP2_BusIdle_Nop25, DSP2_SPI_BusIdle + 83
	.set	DSP2_BusIdle_Nop26, DSP2_SPI_BusIdle + 86
	.set	DSP2_BusIdle_Nop27, DSP2_SPI_BusIdle + 89
	.set	DSP2_BusIdle_Nop28, DSP2_SPI_BusIdle + 92
	.set	DSP2_BusIdle_Nop29, DSP2_SPI_BusIdle + 95
	.set	DSP2_BusIdle_Nop30, DSP2_SPI_BusIdle + 98
	.set	DSP2_BusIdle_Nop31, DSP2_SPI_BusIdle + 101
	.set	DSP2_BusIdle_Nop32, DSP2_SPI_BusIdle + 104
	.set	DSP2_BusIdle_Nop33, DSP2_SPI_BusIdle + 107
	.set	DSP2_BusIdle_Nop34, DSP2_SPI_BusIdle + 110
	.set	DSP2_BusIdle_Nop35, DSP2_SPI_BusIdle + 113
	.set	DSP2_BusIdle_Nop36, DSP2_SPI_BusIdle + 116
	.set	DSP2_BusIdle_Nop37, DSP2_SPI_BusIdle + 119
	.set	DSP2_BusIdle_Nop38, DSP2_SPI_BusIdle + 122
	.set	DSP2_BusIdle_Nop39, DSP2_SPI_BusIdle + 128
	.set	DSP2_BusIdle_Nop40, DSP2_SPI_BusIdle + 131
	.set	DSP2_BusIdle_Nop41, DSP2_SPI_BusIdle + 134
	.set	DSP2_BusIdle_Nop42, DSP2_SPI_BusIdle + 137
	.set	DSP2_BusIdle_Nop43, DSP2_SPI_BusIdle + 140
	.set	DSP2_BusIdle_Nop44, DSP2_SPI_BusIdle + 143
	.set	DSP2_BusIdle_Nop45, DSP2_SPI_BusIdle + 146
	.set	DSP2_BusIdle_Nop46, DSP2_SPI_BusIdle + 149
	.set	DSP2_BusIdle_Nop47, DSP2_SPI_BusIdle + 152
	.set	DSP2_BusIdle_Nop48, DSP2_SPI_BusIdle + 155
	.set	DSP2_BusIdle_Nop49, DSP2_SPI_BusIdle + 158
	.set	DSP2_BusIdle_Nop50, DSP2_SPI_BusIdle + 161
	.set	DSP2_BusIdle_Nop51, DSP2_SPI_BusIdle + 164
	.set	DSP2_BusIdle_Nop52, DSP2_SPI_BusIdle + 167
	.set	DSP2_BusIdle_Nop53, DSP2_SPI_BusIdle + 170
	.set	DSP2_BusIdle_Nop54, DSP2_SPI_BusIdle + 173
	.set	DSP2_BusIdle_Nop55, DSP2_SPI_BusIdle + 176
	.set	DSP2_BusIdle_Nop56, DSP2_SPI_BusIdle + 179
	.set	DSP2_BusIdle_Nop57, DSP2_SPI_BusIdle + 182
	.set	DSP2_BusIdle_Nop58, DSP2_SPI_BusIdle + 185
	.set	DSP2_BusIdle_Nop59, DSP2_SPI_BusIdle + 188
	.set	DSP2_BusIdle_Nop60, DSP2_SPI_BusIdle + 191
	.set	DSP2_BusIdle_Nop61, DSP2_SPI_BusIdle + 194
	.set	DSP2_BusIdle_Nop62, DSP2_SPI_BusIdle + 197
	.set	DSP2_BusIdle_Nop63, DSP2_SPI_BusIdle + 200
	.set	DSP2_BusIdle_Nop64, DSP2_SPI_BusIdle + 203
	.set	DSP2_BusIdle_Nop65, DSP2_SPI_BusIdle + 206
	.set	DSP2_BusIdle_Nop66, DSP2_SPI_BusIdle + 209
	.set	DSP2_BusIdle_Nop67, DSP2_SPI_BusIdle + 212
	.set	DSP2_BusIdle_Nop68, DSP2_SPI_BusIdle + 215
	.set	DSP2_BusIdle_Nop69, DSP2_SPI_BusIdle + 218
	.set	DSP2_BusIdle_Nop70, DSP2_SPI_BusIdle + 221
	.set	DSP2_BusIdle_Nop71, DSP2_SPI_BusIdle + 224
	.set	DSP2_BusIdle_Nop72, DSP2_SPI_BusIdle + 227
	.set	DSP2_BusIdle_Nop73, DSP2_SPI_BusIdle + 230
	.set	DSP2_BusIdle_Nop74, DSP2_SPI_BusIdle + 233
	.set	DSP2_BusIdle_Nop75, DSP2_SPI_BusIdle + 236
	.set	DSP2_BusIdle_Nop76, DSP2_SPI_BusIdle + 239
	.set	DSP2_BusIdle_Nop77, DSP2_SPI_BusIdle + 242
	.set	DSP2_BusIdle_Nop78, DSP2_SPI_BusIdle + 245
	.set	DSP2_BusIdle_Nop79, DSP2_SPI_BusIdle + 248
	.set	DSP2_BusIdle_Nop80, DSP2_SPI_BusIdle + 251
	.set	DSP2_BusIdle_Nop81, DSP2_SPI_BusIdle + 254
	.set	DSP2_BusIdle_Nop82, DSP2_SPI_BusIdle + 257
	.set	DSP2_BusIdle_Nop83, DSP2_SPI_BusIdle + 260
	.set	DSP2_BusIdle_Nop84, DSP2_SPI_BusIdle + 263
	.set	DSP2_BusIdle_Nop85, DSP2_SPI_BusIdle + 266
	.set	DSP2_BusIdle_Nop86, DSP2_SPI_BusIdle + 269
	.set	DSP2_BusIdle_Nop87, DSP2_SPI_BusIdle + 272
	.set	DSP2_BusIdle_Nop88, DSP2_SPI_BusIdle + 275
	.set	DSP2_BusIdle_Nop89, DSP2_SPI_BusIdle + 278
	.set	DSP2_BusIdle_Nop90, DSP2_SPI_BusIdle + 281
	.set	DSP2_BusIdle_Nop91, DSP2_SPI_BusIdle + 284
	.set	DSP2_BusIdle_Nop92, DSP2_SPI_BusIdle + 287
	.set	DSP2_BusIdle_Nop93, DSP2_SPI_BusIdle + 290
	.set	DSP2_BusIdle_Nop94, DSP2_SPI_BusIdle + 293
	.set	DSP2_BusIdle_Nop95, DSP2_SPI_BusIdle + 296
	.set	DSP2_BusIdle_Nop96, DSP2_SPI_BusIdle + 299
	.set	DSP2_BusIdle_Nop97, DSP2_SPI_BusIdle + 302
	.set	DSP2_BusIdle_Nop98, DSP2_SPI_BusIdle + 305
	.set	DSP2_BusIdle_Nop99, DSP2_SPI_BusIdle + 308
	.set	DSP2_BusIdle_Nop100, DSP2_SPI_BusIdle + 311
	.set	DSP2_BusIdle_Nop101, DSP2_SPI_BusIdle + 314
	.set	DSP2_BusIdle_Nop102, DSP2_SPI_BusIdle + 317
	.set	DSP2_BusIdle_Nop103, DSP2_SPI_BusIdle + 320
	.set	DSP2_BusIdle_Nop104, DSP2_SPI_BusIdle + 323
	.set	DSP2_BusIdle_Nop105, DSP2_SPI_BusIdle + 326
	.set	DSP2_BusIdle_Nop106, DSP2_SPI_BusIdle + 329
	.set	DSP2_BusIdle_Nop107, DSP2_SPI_BusIdle + 332
	.set	DSP2_BusIdle_Nop108, DSP2_SPI_BusIdle + 335
	.set	DSP2_BusIdle_Nop109, DSP2_SPI_BusIdle + 338
	.set	DSP2_BusIdle_Nop110, DSP2_SPI_BusIdle + 341
	.set	DSP2_BusIdle_Nop111, DSP2_SPI_BusIdle + 344
	.set	DSP2_BusIdle_Nop112, DSP2_SPI_BusIdle + 347
	.set	DSP2_BusIdle_Nop113, DSP2_SPI_BusIdle + 350
	.set	DSP2_BusIdle_Nop114, DSP2_SPI_BusIdle + 353
	.set	DSP2_BusIdle_Nop115, DSP2_SPI_BusIdle + 356
	.set	DSP2_BusIdle_Nop116, DSP2_SPI_BusIdle + 359
	.set	DSP2_BusIdle_Nop117, DSP2_SPI_BusIdle + 362
	.set	DSP2_BusIdle_Nop118, DSP2_SPI_BusIdle + 365
	.set	DSP2_BusIdle_Nop119, DSP2_SPI_BusIdle + 368
	.set	DSP2_BusIdle_Nop120, DSP2_SPI_BusIdle + 371
	.set	DSP2_BusIdle_Nop121, DSP2_SPI_BusIdle + 374
	.set	DSP2_BusIdle_Nop122, DSP2_SPI_BusIdle + 377
	.set	DSP2_BusIdle_Nop123, DSP2_SPI_BusIdle + 380
	.set	DSP2_BusIdle_Nop124, DSP2_SPI_BusIdle + 383
	.set	DSP2_BusIdle_Nop125, DSP2_SPI_BusIdle + 386
	.set	DSP2_BusIdle_Nop126, DSP2_SPI_BusIdle + 389
	.set	DSP2_BusIdle_Nop127, DSP2_SPI_BusIdle + 392
	.set	DSP2_BusIdle_Nop128, DSP2_SPI_BusIdle + 395
	.set	DSP2_BusIdle_Nop129, DSP2_SPI_BusIdle + 398
	.set	DSP2_BusIdle_Nop130, DSP2_SPI_BusIdle + 401
	.set	DSP2_BusIdle_Nop131, DSP2_SPI_BusIdle + 404
	.set	DSP2_BusIdle_Nop132, DSP2_SPI_BusIdle + 407
	.set	DSP2_BusIdle_Nop133, DSP2_SPI_BusIdle + 410
	.set	DSP2_BusIdle_Nop134, DSP2_SPI_BusIdle + 413

; ALREADY NAMED -- doc header only. Sends one command byte to DSP2 over the bit-banged
; two-wire bus. Entry BC = chip number, A = byte. Exit HL = 0 (the result word is initialised
; to 0 and never set to anything else -- this transport has NO error detection and NO
; timeout, only fixed delays).
;   DSP_WakeAudioTask() ; ei 6 ; DSP_Select_Chip(BC) ; DSP2_SPI_ClockPulseHigh() [= START]
;   8 iterations of: emit bit 7 of the shifting byte on PF.0, ~1 nop, shift left, clock high
;     (set 2,(PF)), ~16 nops, clock low (res 2,(PF)), ~20 nops
;   then a 9th clock pulse with the data line left as-is (the acknowledge slot):
;     ~1 nop, set 2,(PF), ~17 nops, res 2,(PF), ~19 nops
;   DSP_Deselect_Chip(BC) ; ~16 nops ; ei 0
;   Debug_Print_Byte(byte) + Debug_Print_String(ROM 0x01221F)
; The whole burst runs with interrupts below level 6 masked -- roughly 250 nop slots, which
; is the longest interrupt-masked window in the audio path.
DSP2_Send_Command:
	dec 6, xsp
	push xiz
	ld (xsp + 6), bc
	ld (xsp + 8), a
	ldw (xsp + 4), 0x0
	calr DSP_WakeAudioTask
	ei 6
	ld a, (xsp + 8)
	ldfr_berp A, 0xFB
	ld wa, (xsp + 6)
	call DSP_Select_Chip
	calr DSP2_SPI_ClockPulseHigh
	ldw iz, 0x8
	cp iz, 0:i3
	jrl le, DSP2_SendCmd_TrailingClock

; Test bit 7 of the shift register and drive PF.0 accordingly.
DSP2_SendCmd_BitLoop:
	bit_erpb 0xFB, 0x07
	jr z, DSP2_SendCmd_BitClear
	set	0, (PF:8)
	jr DSP2_SendCmd_BitSet_Done

; res 0,(PF) -- data line low.
DSP2_SendCmd_BitClear:
	res	0, (PF:8)

; Join point; the shift and the clock-high edge follow one nop later.
DSP2_SendCmd_BitSet_Done:
	jr DSP2_SendCmd_ClkHigh_Nop01

DSP2_SendCmd_ClkHigh_Nop01:
	nop
	sll_erpb 0xFB, 0x01
	set	2, (PF:8)
	jr DSP2_SendCmd_ClkHigh_Nop02

DSP2_SendCmd_ClkHigh_Nop02:
	nop
	jr DSP2_SendCmd_ClkHigh_Nop03

DSP2_SendCmd_ClkHigh_Nop03:
	nop
	jr DSP2_SendCmd_ClkHigh_Nop04

DSP2_SendCmd_ClkHigh_Nop04:
	nop
	jr DSP2_SendCmd_ClkHigh_Nop05

DSP2_SendCmd_ClkHigh_Nop05:
	nop
	jr DSP2_SendCmd_ClkHigh_Nop06

DSP2_SendCmd_ClkHigh_Nop06:
	nop
	jr DSP2_SendCmd_ClkHigh_Nop07

DSP2_SendCmd_ClkHigh_Nop07:
	nop
	jr DSP2_SendCmd_ClkHigh_Nop08

DSP2_SendCmd_ClkHigh_Nop08:
	nop
	jr DSP2_SendCmd_ClkHigh_Nop09

DSP2_SendCmd_ClkHigh_Nop09:
	nop
	jr DSP2_SendCmd_ClkHigh_Nop10

DSP2_SendCmd_ClkHigh_Nop10:
	nop
	jr DSP2_SendCmd_ClkHigh_Nop11

DSP2_SendCmd_ClkHigh_Nop11:
	nop
	jr DSP2_SendCmd_ClkHigh_Nop12

DSP2_SendCmd_ClkHigh_Nop12:
	nop
	jr DSP2_SendCmd_ClkHigh_Nop13

DSP2_SendCmd_ClkHigh_Nop13:
	nop
	jr DSP2_SendCmd_ClkHigh_Nop14

DSP2_SendCmd_ClkHigh_Nop14:
	nop
	jr DSP2_SendCmd_ClkHigh_Nop15

DSP2_SendCmd_ClkHigh_Nop15:
	nop
	jr DSP2_SendCmd_ClkHigh_Nop16

DSP2_SendCmd_ClkHigh_Nop16:
	nop
	jr DSP2_SendCmd_ClkLow_Nop01

DSP2_SendCmd_ClkLow_Nop01:
	nop
	res	2, (PF:8)
	jr DSP2_SendCmd_ClkLow_Nop02

DSP2_SendCmd_ClkLow_Nop02:
	nop
	jr DSP2_SendCmd_ClkLow_Nop03

DSP2_SendCmd_ClkLow_Nop03:
	nop
	jr DSP2_SendCmd_ClkLow_Nop04

DSP2_SendCmd_ClkLow_Nop04:
	nop
	jr DSP2_SendCmd_ClkLow_Nop05

DSP2_SendCmd_ClkLow_Nop05:
	nop
	jr DSP2_SendCmd_ClkLow_Nop06

DSP2_SendCmd_ClkLow_Nop06:
	nop
	jr DSP2_SendCmd_ClkLow_Nop07

DSP2_SendCmd_ClkLow_Nop07:
	nop
	jr DSP2_SendCmd_ClkLow_Nop08

DSP2_SendCmd_ClkLow_Nop08:
	nop
	jr DSP2_SendCmd_ClkLow_Nop09

DSP2_SendCmd_ClkLow_Nop09:
	nop
	jr DSP2_SendCmd_ClkLow_Nop10

DSP2_SendCmd_ClkLow_Nop10:
	nop
	jr DSP2_SendCmd_ClkLow_Nop11

DSP2_SendCmd_ClkLow_Nop11:
	nop
	jr DSP2_SendCmd_ClkLow_Nop12

DSP2_SendCmd_ClkLow_Nop12:
	nop
	jr DSP2_SendCmd_ClkLow_Nop13

DSP2_SendCmd_ClkLow_Nop13:
	nop
	jr DSP2_SendCmd_ClkLow_Nop14

DSP2_SendCmd_ClkLow_Nop14:
	nop
	jr DSP2_SendCmd_ClkLow_Nop15

DSP2_SendCmd_ClkLow_Nop15:
	nop
	jr DSP2_SendCmd_ClkLow_Nop16

DSP2_SendCmd_ClkLow_Nop16:
	nop
	jr DSP2_SendCmd_ClkLow_Nop17

DSP2_SendCmd_ClkLow_Nop17:
	nop
	jr DSP2_SendCmd_ClkLow_Nop18

DSP2_SendCmd_ClkLow_Nop18:
	nop
	jr DSP2_SendCmd_ClkLow_Nop19

DSP2_SendCmd_ClkLow_Nop19:
	nop
	jr DSP2_SendCmd_ClkLow_Nop20

DSP2_SendCmd_ClkLow_Nop20:
	nop
	sub iz, 0x1
	jrl gt, DSP2_SendCmd_BitLoop

; The 9th (acknowledge) clock pulse after the 8 data bits.
DSP2_SendCmd_TrailingClock:
	jr DSP2_SendCmd_PostLoop_Nop01

DSP2_SendCmd_PostLoop_Nop01:
	nop
	set	2, (PF:8)
	jr DSP2_SendCmd_PostLoop_Nop02

DSP2_SendCmd_PostLoop_Nop02:
	nop
	jr DSP2_SendCmd_PostLoop_Nop03

DSP2_SendCmd_PostLoop_Nop03:
	nop
	jr DSP2_SendCmd_PostLoop_Nop04

DSP2_SendCmd_PostLoop_Nop04:
	nop
	jr DSP2_SendCmd_PostLoop_Nop05

DSP2_SendCmd_PostLoop_Nop05:
	nop
	jr DSP2_SendCmd_PostLoop_Nop06

DSP2_SendCmd_PostLoop_Nop06:
	nop
	jr DSP2_SendCmd_PostLoop_Nop07

DSP2_SendCmd_PostLoop_Nop07:
	nop
	jr DSP2_SendCmd_PostLoop_Nop08

DSP2_SendCmd_PostLoop_Nop08:
	nop
	jr DSP2_SendCmd_PostLoop_Nop09

DSP2_SendCmd_PostLoop_Nop09:
	nop
	jr DSP2_SendCmd_PostLoop_Nop10

DSP2_SendCmd_PostLoop_Nop10:
	nop
	jr DSP2_SendCmd_PostLoop_Nop11

DSP2_SendCmd_PostLoop_Nop11:
	nop
	jr DSP2_SendCmd_PostLoop_Nop12

DSP2_SendCmd_PostLoop_Nop12:
	nop
	jr DSP2_SendCmd_PostLoop_Nop13

DSP2_SendCmd_PostLoop_Nop13:
	nop
	jr DSP2_SendCmd_PostLoop_Nop14

DSP2_SendCmd_PostLoop_Nop14:
	nop
	jr DSP2_SendCmd_PostLoop_Nop15

DSP2_SendCmd_PostLoop_Nop15:
	nop
	jr DSP2_SendCmd_PostLoop_Nop16

DSP2_SendCmd_PostLoop_Nop16:
	nop
	jr DSP2_SendCmd_PostLoop_Nop17

DSP2_SendCmd_PostLoop_Nop17:
	nop
	res	2, (PF:8)
	jr DSP2_SendCmd_PostClkLow_Nop01

DSP2_SendCmd_PostClkLow_Nop01:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop02

DSP2_SendCmd_PostClkLow_Nop02:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop03

DSP2_SendCmd_PostClkLow_Nop03:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop04

DSP2_SendCmd_PostClkLow_Nop04:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop05

DSP2_SendCmd_PostClkLow_Nop05:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop06

DSP2_SendCmd_PostClkLow_Nop06:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop07

DSP2_SendCmd_PostClkLow_Nop07:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop08

DSP2_SendCmd_PostClkLow_Nop08:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop09

DSP2_SendCmd_PostClkLow_Nop09:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop10

DSP2_SendCmd_PostClkLow_Nop10:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop11

DSP2_SendCmd_PostClkLow_Nop11:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop12

DSP2_SendCmd_PostClkLow_Nop12:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop13

DSP2_SendCmd_PostClkLow_Nop13:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop14

DSP2_SendCmd_PostClkLow_Nop14:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop15

DSP2_SendCmd_PostClkLow_Nop15:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop16

DSP2_SendCmd_PostClkLow_Nop16:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop17

DSP2_SendCmd_PostClkLow_Nop17:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop18

DSP2_SendCmd_PostClkLow_Nop18:
	nop
	jr DSP2_SendCmd_PostClkLow_Nop19

DSP2_SendCmd_PostClkLow_Nop19:
	nop
	ld wa, (xsp + 6)
	call DSP_Deselect_Chip
	jr DSP2_SendCmd_Epilogue_Nop01

DSP2_SendCmd_Epilogue_Nop01:
	nop
	jr DSP2_SendCmd_Epilogue_Nop02

DSP2_SendCmd_Epilogue_Nop02:
	nop
	jr DSP2_SendCmd_Epilogue_Nop03

DSP2_SendCmd_Epilogue_Nop03:
	nop
	jr DSP2_SendCmd_Epilogue_Nop04

DSP2_SendCmd_Epilogue_Nop04:
	nop
	jr DSP2_SendCmd_Epilogue_Nop05

DSP2_SendCmd_Epilogue_Nop05:
	nop
	jr DSP2_SendCmd_Epilogue_Nop06

DSP2_SendCmd_Epilogue_Nop06:
	nop
	jr DSP2_SendCmd_Epilogue_Nop07

DSP2_SendCmd_Epilogue_Nop07:
	nop
	jr DSP2_SendCmd_Epilogue_Nop08

DSP2_SendCmd_Epilogue_Nop08:
	nop
	jr DSP2_SendCmd_Epilogue_Nop09

DSP2_SendCmd_Epilogue_Nop09:
	nop
	jr DSP2_SendCmd_Epilogue_Nop10

DSP2_SendCmd_Epilogue_Nop10:
	nop
	jr DSP2_SendCmd_Epilogue_Nop11

DSP2_SendCmd_Epilogue_Nop11:
	nop
	jr DSP2_SendCmd_Epilogue_Nop12

DSP2_SendCmd_Epilogue_Nop12:
	nop
	jr DSP2_SendCmd_Epilogue_Nop13

DSP2_SendCmd_Epilogue_Nop13:
	nop
	jr DSP2_SendCmd_Epilogue_Nop14

DSP2_SendCmd_Epilogue_Nop14:
	nop
	jr DSP2_SendCmd_Epilogue_Nop15

DSP2_SendCmd_Epilogue_Nop15:
	nop
	jr DSP2_SendCmd_Epilogue_Nop16

DSP2_SendCmd_Epilogue_Nop16:
	nop
	ei 0
	lda xwa, (Str_DspTrace_AngleOpen:24)
	call Debug_Print_String
	ld a, (xsp + 8)
	extz wa
	call Debug_Print_Byte
	lda xwa, (Str_DspTrace_AngleClose:24)
	call Debug_Print_String
	ld hl, (xsp + 4)
	pop xiz
	inc 6, xsp
	ret

; ----------------------------------------------------------------------------
; DSP_Send_Data - Send a data byte to DSP chip
; Entry: BC = chip number (0=DSP1, 1=DSP2)
;        A  = data byte to send
; Exit:  HL = 0 on success, 1 on timeout
; Notes: Similar to DSP_Send_Command but uses data mode
; ----------------------------------------------------------------------------
; ALREADY NAMED -- doc header only. Identical in shape to DSP_Send_Command (same 0x1F40
; timeout, same ei 6 / ei 0 bracketing, same SFR 0x68 write) except that it calls
; DSP_Set_Data_Mode instead of DSP_Set_Command_Mode before selecting the chip, and its
; cleanup does not restore data mode (it is already in it). Trace string ROM 0x012222.
DSP_Send_Data:	; 0367EEh
	dec 8, xsp
	pushw iz
	ld (xsp + 6), bc	; Save chip number
	ld (xsp + 8), a	; Save data byte
	ldw (xsp + 4), 0x0	; Result = success
	ldw (xsp + 2), 0x1F40	; Timeout counter
	ei 6
	call DSP_Deassert_Read
	call DSP_Deassert_Write
	ld wa, (xsp + 6)
	call DSP_Select_Chip
	ld wa, (xsp + 6)
	call DSP_Read_Status
	ld iz, hl
	ld wa, (xsp + 6)
	call DSP_Deselect_Chip
	ei 0
	cp iz, 0:i3
	jr nz, DSP_Send_Data_Ready

; Timeout decrement.
DSP_Send_Data_WaitLoop:
	ld wa, (xsp + 2)
	decm 1, (xsp + 2)
	cp wa, 0:i3
	jr nz, DSP_Send_Data_Poll
	ldw (xsp + 4), 0x1	; Timeout error
	jr DSP_Send_Data_Cleanup

; One status poll.
DSP_Send_Data_Poll:
	ei 6
	call DSP_Deassert_Read
	call DSP_Deassert_Write
	ld wa, (xsp + 6)
	call DSP_Select_Chip
	ld wa, (xsp + 6)
	call DSP_Read_Status
	ld iz, hl
	ld wa, (xsp + 6)
	call DSP_Deselect_Chip
	ei 0
	cp iz, 0:i3
	jr z, DSP_Send_Data_WaitLoop

; Data mode, assert write, re-check status, write SFR 0x68.
DSP_Send_Data_Ready:
	ei 6
	call DSP_Set_Data_Mode	; Set data mode (unlike command routine)
	ld wa, (xsp + 6)
	call DSP_Deselect_Chip
	call DSP_Deassert_Read
	call DSP_Assert_Write
	ld wa, (xsp + 6)
	call DSP_Select_Chip
	ld wa, (xsp + 6)
	call DSP_Read_Status
	cp hl, 0:i3
	jr z, DSP_Send_Data_Error
	ld a, (xsp + 8)	; Get data byte
	ld	(PZ:8), a	; Write to DSP data port
	jr DSP_Send_Data_Cleanup

; result = 1.
DSP_Send_Data_Error:
	ldw (xsp + 4), 0x1

; Deselect, deassert, print, return the result.
DSP_Send_Data_Cleanup:
	ld wa, (xsp + 6)
	call DSP_Deselect_Chip
	call DSP_Deassert_Write
	ei 0
	ld a, (xsp + 8)
	extz wa
	call Debug_Print_Byte
	lda xwa, (Str_DspTrace_DataSep:24)
	call Debug_Print_String
	ld hl, (xsp + 4)	; Return result
	popw iz
	inc 8, xsp
	ret

; ALREADY NAMED -- doc header only. The DSP2 data-byte transmitter. Byte-for-byte the same
; bit-bang loop as DSP2_Send_Command with two differences: it does NOT call
; DSP_WakeAudioTask, and it does NOT emit a START condition -- it just selects the chip and
; clocks 8 bits plus the acknowledge pulse. So a DSP2 transaction is
; DSP2_Send_Command (START + opcode) followed by N x DSP2_Send_Data, terminated by
; DSP2_SPI_BusIdle (STOP) from the caller. Trace string ROM 0x012224. Always returns HL = 0.
DSP2_Send_Data:
	dec 6, xsp
	push xiz
	ld (xsp + 6), bc
	ld (xsp + 8), a
	ldw (xsp + 4), 0x0
	ei 6
	ld a, (xsp + 8)
	ldfr_berp A, 0xFB
	ld wa, (xsp + 6)
	call DSP_Select_Chip
	ldw iz, 0x8
	cp iz, 0:i3
	jrl le, DSP2_SendData_TrailingClock

; Bit test and PF.0 drive.
DSP2_SendData_BitLoop:
	bit_erpb 0xFB, 0x07
	jr z, DSP2_SendData_BitClear
	set	0, (PF:8)
	jr DSP2_SendData_BitSet_Done

; res 0,(PF).
DSP2_SendData_BitClear:
	res	0, (PF:8)

; Join point.
DSP2_SendData_BitSet_Done:
	jr DSP2_SendData_ClkHigh_Nop01

DSP2_SendData_ClkHigh_Nop01:
	nop
	sll_erpb 0xFB, 0x01
	set	2, (PF:8)
	jr DSP2_SendData_ClkHigh_Nop02

DSP2_SendData_ClkHigh_Nop02:
	nop
	jr DSP2_SendData_ClkHigh_Nop03

DSP2_SendData_ClkHigh_Nop03:
	nop
	jr DSP2_SendData_ClkHigh_Nop04

DSP2_SendData_ClkHigh_Nop04:
	nop
	jr DSP2_SendData_ClkHigh_Nop05

DSP2_SendData_ClkHigh_Nop05:
	nop
	jr DSP2_SendData_ClkHigh_Nop06

DSP2_SendData_ClkHigh_Nop06:
	nop
	jr DSP2_SendData_ClkHigh_Nop07

DSP2_SendData_ClkHigh_Nop07:
	nop
	jr DSP2_SendData_ClkHigh_Nop08

DSP2_SendData_ClkHigh_Nop08:
	nop
	jr DSP2_SendData_ClkHigh_Nop09

DSP2_SendData_ClkHigh_Nop09:
	nop
	jr DSP2_SendData_ClkHigh_Nop10

DSP2_SendData_ClkHigh_Nop10:
	nop
	jr DSP2_SendData_ClkHigh_Nop11

DSP2_SendData_ClkHigh_Nop11:
	nop
	jr DSP2_SendData_ClkHigh_Nop12

DSP2_SendData_ClkHigh_Nop12:
	nop
	jr DSP2_SendData_ClkHigh_Nop13

DSP2_SendData_ClkHigh_Nop13:
	nop
	jr DSP2_SendData_ClkHigh_Nop14

DSP2_SendData_ClkHigh_Nop14:
	nop
	jr DSP2_SendData_ClkHigh_Nop15

DSP2_SendData_ClkHigh_Nop15:
	nop
	jr DSP2_SendData_ClkHigh_Nop16

DSP2_SendData_ClkHigh_Nop16:
	nop
	jr DSP2_SendData_ClkHigh_Nop17

DSP2_SendData_ClkHigh_Nop17:
	nop
	res	2, (PF:8)
	jr DSP2_SendData_ClkLow_Nop01

DSP2_SendData_ClkLow_Nop01:
	nop
	jr DSP2_SendData_ClkLow_Nop02

DSP2_SendData_ClkLow_Nop02:
	nop
	jr DSP2_SendData_ClkLow_Nop03

DSP2_SendData_ClkLow_Nop03:
	nop
	jr DSP2_SendData_ClkLow_Nop04

DSP2_SendData_ClkLow_Nop04:
	nop
	jr DSP2_SendData_ClkLow_Nop05

DSP2_SendData_ClkLow_Nop05:
	nop
	jr DSP2_SendData_ClkLow_Nop06

DSP2_SendData_ClkLow_Nop06:
	nop
	jr DSP2_SendData_ClkLow_Nop07

DSP2_SendData_ClkLow_Nop07:
	nop
	jr DSP2_SendData_ClkLow_Nop08

DSP2_SendData_ClkLow_Nop08:
	nop
	jr DSP2_SendData_ClkLow_Nop09

DSP2_SendData_ClkLow_Nop09:
	nop
	jr DSP2_SendData_ClkLow_Nop10

DSP2_SendData_ClkLow_Nop10:
	nop
	jr DSP2_SendData_ClkLow_Nop11

DSP2_SendData_ClkLow_Nop11:
	nop
	jr DSP2_SendData_ClkLow_Nop12

DSP2_SendData_ClkLow_Nop12:
	nop
	jr DSP2_SendData_ClkLow_Nop13

DSP2_SendData_ClkLow_Nop13:
	nop
	jr DSP2_SendData_ClkLow_Nop14

DSP2_SendData_ClkLow_Nop14:
	nop
	jr DSP2_SendData_ClkLow_Nop15

DSP2_SendData_ClkLow_Nop15:
	nop
	jr DSP2_SendData_ClkLow_Nop16

DSP2_SendData_ClkLow_Nop16:
	nop
	jr DSP2_SendData_ClkLow_Nop17

DSP2_SendData_ClkLow_Nop17:
	nop
	jr DSP2_SendData_ClkLow_Nop18

DSP2_SendData_ClkLow_Nop18:
	nop
	jr DSP2_SendData_ClkLow_Nop19

DSP2_SendData_ClkLow_Nop19:
	nop
	sub iz, 0x1
	jrl gt, DSP2_SendData_BitLoop

; The 9th (acknowledge) clock pulse.
DSP2_SendData_TrailingClock:
	jr DSP2_SendData_PostLoop_Nop01

DSP2_SendData_PostLoop_Nop01:
	nop
	set	2, (PF:8)
	jr DSP2_SendData_PostLoop_Nop02

DSP2_SendData_PostLoop_Nop02:
	nop
	jr DSP2_SendData_PostLoop_Nop03

DSP2_SendData_PostLoop_Nop03:
	nop
	jr DSP2_SendData_PostLoop_Nop04

DSP2_SendData_PostLoop_Nop04:
	nop
	jr DSP2_SendData_PostLoop_Nop05

DSP2_SendData_PostLoop_Nop05:
	nop
	jr DSP2_SendData_PostLoop_Nop06

DSP2_SendData_PostLoop_Nop06:
	nop
	jr DSP2_SendData_PostLoop_Nop07

DSP2_SendData_PostLoop_Nop07:
	nop
	jr DSP2_SendData_PostLoop_Nop08

DSP2_SendData_PostLoop_Nop08:
	nop
	jr DSP2_SendData_PostLoop_Nop09

DSP2_SendData_PostLoop_Nop09:
	nop
	jr DSP2_SendData_PostLoop_Nop10

DSP2_SendData_PostLoop_Nop10:
	nop
	jr DSP2_SendData_PostLoop_Nop11

DSP2_SendData_PostLoop_Nop11:
	nop
	jr DSP2_SendData_PostLoop_Nop12

DSP2_SendData_PostLoop_Nop12:
	nop
	jr DSP2_SendData_PostLoop_Nop13

DSP2_SendData_PostLoop_Nop13:
	nop
	jr DSP2_SendData_PostLoop_Nop14

DSP2_SendData_PostLoop_Nop14:
	nop
	jr DSP2_SendData_PostLoop_Nop15

DSP2_SendData_PostLoop_Nop15:
	nop
	jr DSP2_SendData_PostLoop_Nop16

DSP2_SendData_PostLoop_Nop16:
	nop
	jr DSP2_SendData_PostLoop_Nop17

DSP2_SendData_PostLoop_Nop17:
	nop
	res	2, (PF:8)
	jr DSP2_SendData_PostClkLow_Nop01

DSP2_SendData_PostClkLow_Nop01:
	nop
	jr DSP2_SendData_PostClkLow_Nop02

DSP2_SendData_PostClkLow_Nop02:
	nop
	jr DSP2_SendData_PostClkLow_Nop03

DSP2_SendData_PostClkLow_Nop03:
	nop
	jr DSP2_SendData_PostClkLow_Nop04

DSP2_SendData_PostClkLow_Nop04:
	nop
	jr DSP2_SendData_PostClkLow_Nop05

DSP2_SendData_PostClkLow_Nop05:
	nop
	jr DSP2_SendData_PostClkLow_Nop06

DSP2_SendData_PostClkLow_Nop06:
	nop
	jr DSP2_SendData_PostClkLow_Nop07

DSP2_SendData_PostClkLow_Nop07:
	nop
	jr DSP2_SendData_PostClkLow_Nop08

DSP2_SendData_PostClkLow_Nop08:
	nop
	jr DSP2_SendData_PostClkLow_Nop09

DSP2_SendData_PostClkLow_Nop09:
	nop
	jr DSP2_SendData_PostClkLow_Nop10

DSP2_SendData_PostClkLow_Nop10:
	nop
	jr DSP2_SendData_PostClkLow_Nop11

DSP2_SendData_PostClkLow_Nop11:
	nop
	jr DSP2_SendData_PostClkLow_Nop12

DSP2_SendData_PostClkLow_Nop12:
	nop
	jr DSP2_SendData_PostClkLow_Nop13

DSP2_SendData_PostClkLow_Nop13:
	nop
	jr DSP2_SendData_PostClkLow_Nop14

DSP2_SendData_PostClkLow_Nop14:
	nop
	jr DSP2_SendData_PostClkLow_Nop15

DSP2_SendData_PostClkLow_Nop15:
	nop
	jr DSP2_SendData_PostClkLow_Nop16

DSP2_SendData_PostClkLow_Nop16:
	nop
	jr DSP2_SendData_PostClkLow_Nop17

DSP2_SendData_PostClkLow_Nop17:
	nop
	jr DSP2_SendData_PostClkLow_Nop18

DSP2_SendData_PostClkLow_Nop18:
	nop
	jr DSP2_SendData_PostClkLow_Nop19

DSP2_SendData_PostClkLow_Nop19:
	nop
	ld wa, (xsp + 6)
	call DSP_Deselect_Chip
	jr DSP2_SendData_Epilogue_Nop01

DSP2_SendData_Epilogue_Nop01:
	nop
	jr DSP2_SendData_Epilogue_Nop02

DSP2_SendData_Epilogue_Nop02:
	nop
	jr DSP2_SendData_Epilogue_Nop03

DSP2_SendData_Epilogue_Nop03:
	nop
	jr DSP2_SendData_Epilogue_Nop04

DSP2_SendData_Epilogue_Nop04:
	nop
	jr DSP2_SendData_Epilogue_Nop05

DSP2_SendData_Epilogue_Nop05:
	nop
	jr DSP2_SendData_Epilogue_Nop06

DSP2_SendData_Epilogue_Nop06:
	nop
	jr DSP2_SendData_Epilogue_Nop07

DSP2_SendData_Epilogue_Nop07:
	nop
	jr DSP2_SendData_Epilogue_Nop08

DSP2_SendData_Epilogue_Nop08:
	nop
	jr DSP2_SendData_Epilogue_Nop09

DSP2_SendData_Epilogue_Nop09:
	nop
	jr DSP2_SendData_Epilogue_Nop10

DSP2_SendData_Epilogue_Nop10:
	nop
	jr DSP2_SendData_Epilogue_Nop11

DSP2_SendData_Epilogue_Nop11:
	nop
	jr DSP2_SendData_Epilogue_Nop12

DSP2_SendData_Epilogue_Nop12:
	nop
	jr DSP2_SendData_Epilogue_Nop13

DSP2_SendData_Epilogue_Nop13:
	nop
	jr DSP2_SendData_Epilogue_Nop14

DSP2_SendData_Epilogue_Nop14:
	nop
	jr DSP2_SendData_Epilogue_Nop15

DSP2_SendData_Epilogue_Nop15:
	nop
	jr DSP2_SendData_Epilogue_Nop16

DSP2_SendData_Epilogue_Nop16:
	nop
	ei 0
	ld a, (xsp + 8)
	extz wa
	call Debug_Print_Byte
	lda xwa, (Str_DspTrace_DataSep2:24)
	call Debug_Print_String
	ld hl, (xsp + 4)
	pop xiz
	inc 6, xsp
	ret

; ALREADY NAMED -- doc header only. The one place that knows which DSP is which.
; Entry BC = chip selector, A = byte. BC == 0 -> DSP_Send_Command (IC311, parallel);
; BC == 1 -> DSP2_Send_Command (IC310, bit-banged); anything else -> HL = 1 (invalid chip).
; Exit HL = 0 ok / 1 error. Eight call sites, all in the DSP microprogram loader outside
; this region.
DSP_DispatchCommand:	.include "includes/generated/cc900/DSP_DispatchCommand.s"	; C: cc900/audio_process_dsp_and_effects_d_6a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_DispatchCommand_DSP2Path, DSP_DispatchCommand + 20
	.set	DSP_DispatchCommand_InvalidChip, DSP_DispatchCommand + 27
	.set	DSP_DispatchCommand_Epilogue, DSP_DispatchCommand + 29

; ALREADY NAMED -- doc header only. Same shape for data bytes: BC == 0 -> DSP_Send_Data,
; BC == 1 -> DSP2_Send_Data, else HL = 1. The transports' results are discarded in the same
; way.
DSP_DispatchData:	.include "includes/generated/cc900/DSP_DispatchData.s"	; C: cc900/audio_process_dsp_and_effects_d_6a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_DispatchData_DSP2Path, DSP_DispatchData + 20
	.set	DSP_DispatchData_InvalidChip, DSP_DispatchData + 27
	.set	DSP_DispatchData_Epilogue, DSP_DispatchData + 29

; ALREADY NAMED -- doc header only. Copies 0x91 words (290 bytes) from XWA to 0x45CA, i.e.
; snapshots the live effect configuration into the shadow that all the diff routines compare
; against. Called at the end of DSP_State_ApplyAll, so "shadow" means "state as of the last
; successful apply". Uses `ldirw` with XIX = destination, XIY = source.
DSP_StateTable_Save:	.include "includes/generated/cc900/DSP_StateTable_Save.s"	; C: cc900/audio_process_dsp_and_effects.c

; ALREADY NAMED -- doc header only. Entry XWA = live config buffer (0x448E).
; Sets the global flag (0x493E) to 0 only when ALL THREE of these hold:
;   (XWA+6) == (0x45D0)   [config header word 6 equals its shadow]
;   (XWA+2) != 1
;   (XWA+4) == 1
; otherwise (0x493E) = 1. Downstream, (0x493E) == 1 is the "algorithm did NOT change" case
; that makes EFF_SlotActive_UpdateFlags mark all five slots live and
; EFF_DspChannel_InitFlags force every dirty bit -- so the polarity of this flag is
; "1 = full rewrite needed". Note the sense of the name is therefore inverted; see
; [UNCERTAIN].
DSP_AlgoChange_CheckAndFlag:	.include "includes/generated/cc900/DSP_AlgoChange_CheckAndFlag.s"	; C: cc900/audio_process_dsp_and_effects.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_AlgoChange_NoChange, DSP_AlgoChange_CheckAndFlag + 23
	.set	DSP_AlgoChange_FlagAndClear, DSP_AlgoChange_CheckAndFlag + 30

; ALREADY NAMED -- doc header only. Entry XWA = live config buffer.
; For each slot n = 0..4: compares the word at slot-record +0x00 (the algorithm number)
; against its shadow at 0x45D2 + n*0x38, and writes 1 (differs) or 0 (same) to the per-slot
; dirty word at 0x4940 + n*0x32. Pure comparison, nothing is copied.
DSP_SlotParam_DiffAndFlag:	.include "includes/generated/cc900/DSP_SlotParam_DiffAndFlag.s"	; C: cc900/audio_process_dsp_and_effects_d_7a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_SlotParam_DiffLoop, DSP_SlotParam_DiffAndFlag + 6
	.set	DSP_SlotParam_DiffMatch, DSP_SlotParam_DiffAndFlag + 66
	.set	DSP_SlotParam_DiffMismatch, DSP_SlotParam_DiffAndFlag + 84

; ALREADY NAMED -- doc header only. The big four-level parameter diff. Entry XWA = live
; config buffer; no output register, everything lands in the dirty arrays.
; For each slot n = 0..4 it clears the slot summary word (0x4960 + n*0x32 + 0x10) and then
; compares, live against shadow, writing per-item 1/0 flags:
;   slot +0x02                 vs 0x45D4 + n*0x38   -> flag at 0x4942 + n*0x32
;   slot +0x04 .. +0x24 (17 w) vs 0x45D6 + n*0x38   -> flags at 0x4944 + n*0x32 + i*2
;   slot +0x28                 vs 0x45FA + n*0x38   -> flag at 0x4966 + n*0x32
;   slot +0x36                 vs 0x4600 + n*0x38+8 -> flag at 0x495E + n*0x32 + 0x10
; Any difference also sets the slot summary word to 1. Finally it clears the three words at
; 0x4958/0x495A/0x495C + n*0x32 + 0x10 for the slot.
DSP_EFFParam_DiffAllAndFlag:
	push xiz
	ld de, 0:i3
	cp de, 5:i3
	jrl nc, DSP_EFFParam_DiffEpilogue

; Per-slot entry; clears the slot summary word.
DSP_EFFParam_DiffOuter:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18784:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0
	ld hl, 0:i3
	cp hl, 1:i3
	jrl nc, DSP_EFFParam_DiffInner

; The single word at slot +0x02.
DSP_EFFParam_DiffMid:
	ld ix, hl
	add ix, ix
	ld bc, de
	mul bc, 0x38
	add bc, ix
	lda xix, (17876:16)
	ld iz, bc
	extz xiz
	add xiz, xix
	ld bc, hl
	extz xbc
	ld xix, xbc
	add xix, xix
	ld bc, de
	extz xbc
	ld xiy, xbc
	sll xiy, 3
	sub xiy, xbc
	sll xiy, 3
	add xiy, xix
	add xiy, xwa
	ld bc, (xiy + 10)
	cp bc, (xiz)
	jr z, DSP_EFFParam_DiffMidMatch
	ld ix, hl
	add ix, ix
	ld bc, de
	mul bc, 0x32
	add bc, ix
	lda xix, (18754:16)
	extz xbc
	add xbc, xix
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xix, (18784:16)
	extz xbc
	add xbc, xix
	ldw (xbc), 0x1
	jr DSP_EFFParam_DiffMidNext

; Equal: flag = 0.
DSP_EFFParam_DiffMidMatch:
	ld ix, hl
	add ix, ix
	ld bc, de
	mul bc, 0x32
	add bc, ix
	lda xix, (18754:16)
	extz xbc
	add xbc, xix
	ldw (xbc), 0x0

; Loop tail (the loop bound is 1, so it runs exactly once).
DSP_EFFParam_DiffMidNext:
	inc 1, hl
	cp hl, 1:i3
	jrl c, DSP_EFFParam_DiffMid

; Sets up the 17-word coefficient loop.
DSP_EFFParam_DiffInner:
	ld hl, 0:i3
	cp hl, 0x11
	jrl nc, DSP_EFFParam_DiffLevel4

; One coefficient: slot +0x04 + i*2 vs shadow 0x45D6 + n*0x38 + i*2.
DSP_EFFParam_DiffInnerBody:
	ld ix, hl
	add ix, ix
	ld bc, de
	mul bc, 0x38
	add bc, ix
	lda xix, (17878:16)
	ld iz, bc
	extz xiz
	add xiz, xix
	ld bc, hl
	extz xbc
	ld xix, xbc
	add xix, xix
	ld bc, de
	extz xbc
	ld xiy, xbc
	sll xiy, 3
	sub xiy, xbc
	sll xiy, 3
	add xiy, xix
	add xiy, xwa
	ld bc, (xiy + 12)
	cp bc, (xiz)
	jr z, DSP_EFFParam_DiffInnerMatch
	ld ix, hl
	add ix, ix
	ld bc, de
	mul bc, 0x32
	add bc, ix
	lda xix, (18756:16)
	extz xbc
	add xbc, xix
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xix, (18784:16)
	extz xbc
	add xbc, xix
	ldw (xbc), 0x1
	jr DSP_EFFParam_DiffInnerNext

; Equal: flag = 0.
DSP_EFFParam_DiffInnerMatch:
	ld ix, hl
	add ix, ix
	ld bc, de
	mul bc, 0x32
	add bc, ix
	lda xix, (18756:16)
	extz xbc
	add xbc, xix
	ldw (xbc), 0x0

; ++i while i < 0x11.
DSP_EFFParam_DiffInnerNext:
	inc 1, hl
	cp hl, 0x11
	jrl c, DSP_EFFParam_DiffInnerBody

; Sets up the single-word +0x28 comparison.
DSP_EFFParam_DiffLevel4:
	ld hl, 0:i3
	cp hl, 1:i3
	jrl nc, DSP_EFFParam_DiffAlgoSection

; slot +0x28 vs shadow 0x45FA + n*0x38.
DSP_EFFParam_DiffLevel4Body:
	ld ix, hl
	add ix, ix
	ld bc, de
	mul bc, 0x38
	add bc, ix
	lda xix, (17914:16)
	ld iz, bc
	extz xiz
	add xiz, xix
	ld bc, hl
	extz xbc
	ld xix, xbc
	add xix, xix
	ld bc, de
	extz xbc
	ld xiy, xbc
	sll xiy, 3
	sub xiy, xbc
	sll xiy, 3
	add xiy, xix
	add xiy, xwa
	ld bc, (xiy + 48)
	cp bc, (xiz)
	jr z, DSP_EFFParam_DiffLevel4Match
	ld ix, hl
	add ix, ix
	ld bc, de
	mul bc, 0x32
	add bc, ix
	lda xix, (18790:16)
	extz xbc
	add xbc, xix
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xix, (18784:16)
	extz xbc
	add xbc, xix
	ldw (xbc), 0x1
	jr DSP_EFFParam_DiffLevel4Next

; Equal: flag = 0.
DSP_EFFParam_DiffLevel4Match:
	ld ix, hl
	add ix, ix
	ld bc, de
	mul bc, 0x32
	add bc, ix
	lda xix, (18790:16)
	extz xbc
	add xbc, xix
	ldw (xbc), 0x0

; Loop tail (bound 1).
DSP_EFFParam_DiffLevel4Next:
	inc 1, hl
	cp hl, 1:i3
	jrl c, DSP_EFFParam_DiffLevel4Body

; slot +0x36 vs shadow 0x4600 + n*0x38 + 8 -- the word the five global setters
; DSP_SET_CFGWORD_* write.
DSP_EFFParam_DiffAlgoSection:
	ld bc, de
	mul bc, 0x38
	inc 8, bc
	lda xhl, (17920:16)
	ld ix, bc
	extz xix
	add xix, xhl
	ld bc, de
	extz xbc
	ld xhl, xbc
	sll xhl, 3
	sub xhl, xbc
	sll xhl, 3
	inc 8, xhl
	add xhl, xwa
	ld bc, (xhl + 54)
	cp bc, (xix)
	jr z, DSP_EFFParam_AlgoChangePath
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18782:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18784:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	jr DSP_EFFParam_DiffOuterNext

; Equal: flag at 0x495E + n*0x32 + 0x10 = 0. (The name suggests the opposite of what it does.)
DSP_EFFParam_AlgoChangePath:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18782:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0

; Clears 0x4958/0x495A/0x495C + n*0x32 + 0x10, then ++n while n < 5.
DSP_EFFParam_DiffOuterNext:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18776:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18778:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18780:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0
	inc 1, de
	cp de, 5:i3
	jrl c, DSP_EFFParam_DiffOuter

; pop; ret.
DSP_EFFParam_DiffEpilogue:
	pop xiz
	ret

; ALREADY NAMED -- doc header only. XWA = live config buffer; runs, in order,
; DSP_AlgoChange_CheckAndFlag, DSP_SlotParam_DiffAndFlag, DSP_EFFParam_DiffAllAndFlag.
DSP_State_DiffAll:	.include "includes/generated/cc900/DSP_State_DiffAll.s"	; C: cc900/audio_process_dsp_and_effects_d_6a.c

; ALREADY NAMED -- doc header only. DSP_State_DiffAll followed by EFF_StateLoad_Prepare
; (outside the region), both with XWA = the live config buffer.
DSP_State_DiffAndPrepare:	.include "includes/generated/cc900/DSP_State_DiffAndPrepare.s"	; C: cc900/audio_process_dsp_and_effects_d_6a.c

; ALREADY NAMED -- doc header only. Entry XWA = live config buffer.
; Clamps the header word at +6 to 0 or 1 (anything above 1 becomes 0), then clamps each of
; the five slots' word at slot-record +0x00 to a maximum of 0x63 (99). That 0..99 ceiling is
; the strongest evidence that slot +0x00 is the DSP algorithm NUMBER: it matches the
; instrument's 0..99 effect numbering, and EFF_SlotActive_UpdateFlags tests it against the
; specific values 0x33, 0x34, 0x45 and 0x46.
DSP_Config_ClampLimits:	.include "includes/generated/cc900/DSP_Config_ClampLimits.s"	; C: cc900/audio_process_dsp_and_effects_d_7a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_Config_ClampLoop, DSP_Config_ClampLimits + 12
	.set	DSP_Config_ClampApply, DSP_Config_ClampLimits + 18
	.set	DSP_Config_ClampNext, DSP_Config_ClampLimits + 64

; --- 0x036DEA-0x036DF4  DSP_Config_ClampData -- eleven bytes d2 66 55 04 23 d2 44 54 04 83 0e
; Disassembles exactly as `ld HL,(0x045566) / add HL,(0x045444) / ret`, i.e. another
; unreachable routine tail, not a data table.
; ★ Renamed 2026-09-25 from DSP_Config_ClampData: header: an unreachable tail `ld HL,(0x045566) / add HL,(0x045444) / ret`.
DSP_Config_DeadTail_SumWords:	.include "includes/generated/cc900/DSP_Config_DeadTail_SumWords.s"	; C: cc900/audio_process_dsp_and_effects.c

; ALREADY NAMED -- doc header only. Entry WA = index. Returns HL = (0x45BC + index*2) and
; then writes 0 to the same word -- a destructive read of a five-word pending-state array.
; Only caller in the firmware is DSP_SlotState_DisplayRestore, with index 0.
DSP_SlotMuteState_ReadAndClear:	.include "includes/generated/cc900/DSP_SlotMuteState_ReadAndClear.s"	; C: cc900/audio_process_dsp_and_effects.c

; --- CalcSampleAddr: Compute sample address from 2-byte index ---
; Entry: XWA = pointer to structure with byte[0] and byte[1]
; Exit: XHL = XWA + computed offset (address into sample data)
;   offset = (byte[0] << 8) + byte[1], capped at 0xF0
; ALREADY NAMED -- doc header only. XHL = XWA + ((XWA[0] << 8) + XWA[1]), except that when
; the resulting offset's high byte equals 0xF0 the add is skipped (a 6-byte forward branch
; over the add), leaving XHL undefined on that path. No caller anywhere in this build; the
; existing header comment's "capped at 0xF0" is a fair reading. Kept as-is.
CalcSampleAddr:	.include "includes/generated/cc900/CalcSampleAddr.s"	; C: cc900/audio_process_dsp_and_effects_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_SlotMuteState_ReadAndClear_Skip, CalcSampleAddr + 40

; ALREADY NAMED -- doc header only. The whole apply pipeline. Entry XWA = live config buffer.
;   (0x45C8) = 0
;   DSP_Config_ClampLimits ; DSP_State_DiffAndPrepare ; DSP_State_Dispatcher ;
;   DSP_StateTable_Save
;   HL = (0x45C8)
; So DSP_State_Dispatcher (outside the region) is what actually pushes bytes at the DSPs, and
; it reports through 0x45C8. The unconditional DSP_StateTable_Save at the end means the
; shadow is updated even if the dispatch failed. Called from 0x040592.
DSP_State_ApplyAll:	.include "includes/generated/cc900/DSP_State_ApplyAll.s"	; C: cc900/audio_process_dsp_and_effects_d_6a.c

; ALREADY NAMED -- doc header only. Entry XWA = live config buffer.
; If the global flag (0x493E) == 1 (see DSP_AlgoChange_CheckAndFlag) it simply marks all five
; slots live: (0x4930 + n*2) = 1 for n = 0..4, and returns.
; Otherwise, per slot n: reads the algorithm number at slot +0x00; if it is 0x33, 0x34, 0x45
; or 0x46 a local "voice-linked" flag DE is set to 1. Then, if the slot's dirty word
; (0x4940 + n*0x32) is 1, or the config header word (XWA+0) is 1 and the slot summary
; (0x4960 + n*0x32 + 0x10) is 1, or the summary is 1 while DE == 1, the slot is marked live
; and a batch of dirty bits is forced: (0x4930 + n*2) = 1, the coefficient flag indexed by
; slot +0x1E doubled, and the words at 0x495A / 0x495C / 0x4960 (+ n*0x32 + 0x10) = 1, plus
; 0x4958 + n*0x32 + 0x10 = 1 unless slot +0x30 equals 0x63. Otherwise (0x4930 + n*2) = 0.
EFF_SlotActive_UpdateFlags:
	ld de, 0:i3
	cpw (DSP_AlgoChangedFlag:16), 1
	jr nz, EFF_SlotActive_SlotActive
	ld hl, 0:i3
	cp hl, 5:i3
	ret nc

; The "mark all five live" loop taken when (0x493E) == 1.
EFF_SlotActive_CheckSlot:
	ld wa, hl
	add wa, wa
	lda xbc, (EFF_SlotActiveFlags:16)
	extz xwa
	add xwa, xbc
	ldw (xwa), 0x1
	inc 1, hl
	cp hl, 5:i3
	jr c, EFF_SlotActive_CheckSlot
	ret

; Per-slot loop set-up (n = 0..4).
EFF_SlotActive_SlotActive:
	ld hl, 0:i3
	cp hl, 5:i3
	ret nc

; Per-slot loop body: reads the algorithm number and tests it against 0x33/0x34/0x45/0x46.
EFF_SlotActive_SlotInactive:
	ld bc, hl
	extz xbc
	ld xix, xbc
	sll xix, 3
	sub xix, xbc
	sll xix, 3
	inc 8, xix
	add xix, xwa
	ld bc, (xix)
	cp bc, 0x33
	jr z, EFF_SlotActive_VoiceCheck
	cp bc, 0x34
	jr z, EFF_SlotActive_VoiceCheck
	cp bc, 0x45
	jr z, EFF_SlotActive_VoiceCheck
	cp bc, 0x46
	jr nz, EFF_SlotActive_VoiceInactive

; One of those four algorithms: DE = 1.
EFF_SlotActive_VoiceCheck:
	ld de, 1:i3

; The three-way "does this slot need a rewrite" test.
EFF_SlotActive_VoiceInactive:
	ld bc, hl
	mul bc, 0x32
	lda xix, (18752:16)
	extz xbc
	add xbc, xix
	cpw (xbc), 0x1
	jr z, EFF_SlotActive_LoopNext
	cpw (xwa), 0x1
	jr nz, EFF_SlotActive_AlgoCheck
	ld bc, hl
	mul bc, 0x32
	add bc, 0x10
	lda xix, (18784:16)
	extz xbc
	add xbc, xix
	cpw (xbc), 0x1
	jr z, EFF_SlotActive_LoopNext

; Summary-word test combined with the DE flag.
EFF_SlotActive_AlgoCheck:
	ld bc, hl
	mul bc, 0x32
	add bc, 0x10
	lda xix, (18784:16)
	extz xbc
	add xbc, xix
	cpw (xbc), 0x1
	jrl nz, EFF_SlotActive_InnerLoopNext
	cp de, 1:i3
	jrl nz, EFF_SlotActive_InnerLoopNext

; The "slot is live" body that forces the batch of dirty flags. Not a loop tail.
EFF_SlotActive_LoopNext:
	ld bc, hl
	add bc, bc
	lda xix, (EFF_SlotActiveFlags:16)
	extz xbc
	add xbc, xix
	ldw (xbc), 0x1
	ld bc, hl
	extz xbc
	ld xix, xbc
	sll xix, 3
	sub xix, xbc
	sll xix, 3
	inc 8, xix
	add xix, xwa
	ld ix, (xix + 38)
	sll ix, 1
	ld bc, hl
	mul bc, 0x32
	add bc, ix
	lda xix, (18756:16)
	extz xbc
	add xbc, xix
	ldw (xbc), 0x1
	ld bc, hl
	mul bc, 0x32
	add bc, 0x10
	lda xix, (18778:16)
	extz xbc
	add xbc, xix
	ldw (xbc), 0x1
	ld bc, hl
	mul bc, 0x32
	add bc, 0x10
	lda xix, (18780:16)
	extz xbc
	add xbc, xix
	ldw (xbc), 0x1
	ld bc, hl
	mul bc, 0x32
	add bc, 0x10
	lda xix, (18784:16)
	extz xbc
	add xbc, xix
	ldw (xbc), 0x1
	ld bc, hl
	extz xbc
	ld xix, xbc
	sll xix, 3
	sub xix, xbc
	sll xix, 3
	inc 8, xix
	add xix, xwa
	cpw (xix + 48), 0x63
	jr z, EFF_SlotActive_Epilogue
	ld bc, hl
	mul bc, 0x32
	add bc, 0x10
	lda xix, (18776:16)
	extz xbc
	add xbc, xix
	ldw (xbc), 0x1
	jr EFF_SlotActive_Epilogue

; The "slot is not live" body: (0x4930 + n*2) = 0.
EFF_SlotActive_InnerLoopNext:
	ld bc, hl
	add bc, bc
	lda xix, (EFF_SlotActiveFlags:16)
	extz xbc
	add xbc, xix
	ldw (xbc), 0x0

; ++n while n < 5, then ret. This is the actual loop tail.
EFF_SlotActive_Epilogue:
	inc 1, hl
	cp hl, 5:i3
	jrl c, EFF_SlotActive_SlotInactive
	ret

; ALREADY NAMED -- doc header only. No parameters.
; If (0x493E) == 1: (0x493A) = 1 and then (0x493A + i*2) = 0 for i = 1 only, i.e. the pair
; becomes {1, 0}. Otherwise both words (0x493A) and (0x493C) are cleared.
; Called from 0x038078, immediately after EFF_SlotActive_UpdateFlags and immediately before
; EFF_DspChannel_InitFlags -- the three form one "prepare the dirty state" block.
EFF_DSPLink_ResetFlags:	.include "includes/generated/cc900/EFF_DSPLink_ResetFlags.s"	; C: cc900/audio_process_dsp_and_effects.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	EFF_DSPLink_ResetFlags_ZeroPath, EFF_DSPLink_ResetFlags + 20
	.set	EFF_DSPLink_ResetFlags_LoopNext, EFF_DSPLink_ResetFlags + 43
	.set	EFF_DSPLink_ResetFlags_InnerBody, EFF_DSPLink_ResetFlags + 49

; ALREADY NAMED -- doc header only. Entry: none (it works purely on the dirty arrays).
; For each slot n = 0..4:
;   if (0x493E) == 1, force the slot dirty word (0x4940 + n*0x32) = 1
;   if that word is now 1, set every dirty flag the slot owns:
;       (0x4944 + n*0x32 + i*2) = 1 for i = 0..0x10   (17 coefficient flags)
;       (0x4942 + n*0x32 + i*2) = 1 for i = 0..0      (1 flag)
;       (0x4966 + n*0x32 + i*2) = 1 for i = 0..0      (1 flag)
;       (0x4958 / 0x495A / 0x495C + n*0x32 + 0x10) = 1
;   ...continuing past this region's end at 0x0370BF (EFF_DspChannel_Init_MultiTableDirty).
; This is the "the algorithm changed, so re-send everything" hammer.
EFF_DspChannel_InitFlags:
	ld de, 0:i3
	cp de, 5:i3
	ret nc

; (0x493E) == 1 -> force this slot's dirty word to 1.
EFF_DspChannel_Init_AlgoCheck:
	cpw (DSP_AlgoChangedFlag:16), 1
	jr nz, EFF_DspChannel_Init_SlotNext
	ld bc, de
	mul bc, 0x32
	lda xhl, (18752:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1

; Tests the slot dirty word; if not 1, jump to the outer loop tail (outside this region).
EFF_DspChannel_Init_SlotNext:
	ld bc, de
	mul bc, 0x32
	lda xhl, (18752:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jrl nz, EFF_DspChannel_Init_OuterNext
	ld ix, 0:i3
	cp ix, 0x11
	jr nc, EFF_DspChannel_Init_CoeffLoop

; The 17-iteration loop that sets the coefficient flags at 0x4944 + n*0x32 + i*2.
EFF_DspChannel_Init_FreqLoop:
	ld hl, ix
	add hl, hl
	ld bc, de
	mul bc, 0x32
	add bc, hl
	lda xhl, (18756:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	inc 1, ix
	cp ix, 0x11
	jr c, EFF_DspChannel_Init_FreqLoop

; Sets up the single-iteration loop over 0x4942.
EFF_DspChannel_Init_CoeffLoop:
	ld ix, 0:i3
	cp ix, 1:i3
	jr nc, EFF_DspChannel_Init_Coeff2Loop

; That loop's body.
EFF_DspChannel_Init_CoeffNext:
	ld hl, ix
	add hl, hl
	ld bc, de
	mul bc, 0x32
	add bc, hl
	lda xhl, (18754:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	inc 1, ix
	cp ix, 1:i3
	jr c, EFF_DspChannel_Init_CoeffNext

; Sets up the single-iteration loop over 0x4966.
EFF_DspChannel_Init_Coeff2Loop:
	ld ix, 0:i3
	cp ix, 1:i3
	jr nc, EFF_DspChannel_Init_MultiTableDirty

; That loop's body. The region ends at 0x0370BE, one byte before
; EFF_DspChannel_Init_MultiTableDirty (0x0370BF), which continues the same routine.
EFF_DspChannel_Init_Coeff2Next:
	ld hl, ix
	add hl, hl
	ld bc, de
	mul bc, 0x32
	add bc, hl
	lda xhl, (18790:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	inc 1, ix
	cp ix, 1:i3
	jr c, EFF_DspChannel_Init_Coeff2Next

; Body of EFF_DspChannel_InitFlags, inside its slot loop (DE = slot, 0..4). Marks the five
; multi-table / auxiliary dirty words of the slot unconditionally dirty:
; 0x004968, 0x00496A, 0x00496C, 0x00496E (link) and 0x004970 (volume), each + 50*DE.
; Then, ONLY when DE == 1, it reaches across into SLOT 0's flags: it takes slot 0's volume
; parameter index n = block[+0x2E] (= record 0 field +0x26) and marks slot 0's parameter
; n+1 dirty at 0x004946 + 2*n -- or n+2 (0x004948 + 2*n) when slot 0's effect is 0x35 or
; 0x0F. This cross-slot dependency is the only place in the region where one slot's flags
; are written from another slot's iteration.
EFF_DspChannel_Init_MultiTableDirty:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18776:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18778:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18780:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18782:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18784:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	cp de, 1:i3
	jr nz, EFF_DspChannel_Init_OuterNext
	ld bc, (xwa + 46)
	inc 1, bc
	ld hl, (xwa + 8)
	cp hl, 0x35
	jr z, EFF_DspChannel_Init_AlgoTypePath
	cp hl, 0xF
	jr z, EFF_DspChannel_Init_AlgoTypePath
	add bc, bc
	add bc, 0x14
	lda xhl, (EFF_SlotActiveFlags:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	jr EFF_DspChannel_Init_OuterNext

; The "+2 instead of +1" arm of the cross-slot marking above, taken when slot 0's effect
; number is 0x35 or 0x0F (the two algorithms with a reordered parameter list).
EFF_DspChannel_Init_AlgoTypePath:
	inc 1, bc
	add bc, bc
	add bc, 0x14
	lda xhl, (EFF_SlotActiveFlags:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1

; Join point: loads the slot's effect number from block+8+56*DE and, if it is 0x27, falls
; into the five three-parameter coalescing blocks below; otherwise jumps straight to the
; 0x4F test at EFF_DspChanInit_AlgoType9_Dirty.
EFF_DspChannel_Init_OuterNext:
	ld bc, de
	extz xbc
	ld xhl, xbc
	sll xhl, 3
	sub xhl, xbc
	sll xhl, 3
	inc 8, xhl
	add xhl, xwa
	cpw (xhl), 0x27
	jrl nz, EFF_DspChanInit_AlgoType9_Dirty
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18740:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr z, EFF_DspChanInit_AlgoType0_Dirty
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18742:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr z, EFF_DspChanInit_AlgoType0_Dirty
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18744:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr nz, EFF_DspChanInit_AlgoType1_Dirty

; Effect 0x27, band 0: if any of param[0..2] is dirty, mark param[0] dirty and clear
; param[1] and param[2]. Five such blocks follow, covering param[0..14] in groups of
; three -- five bands of three values each (frequency / Q / gain), which is the shape of
; the PARAMETRIC EQ described in technics-docs/effects-dsp.md. Coalescing to the first flag
; is what makes the DSP-side biquad get designed once per band instead of three times.
EFF_DspChanInit_AlgoType0_Dirty:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18740:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18742:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18744:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0

; Effect 0x27, band 1 test: is any of param[3..5] dirty?
EFF_DspChanInit_AlgoType1_Dirty:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (DSP_ChipActiveFlags:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr z, EFF_DspChanInit_AlgoType2_Dirty
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18748:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr z, EFF_DspChanInit_AlgoType2_Dirty
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (DSP_AlgoChangedFlag:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr nz, EFF_DspChanInit_AlgoType3_Dirty

; Effect 0x27, band 1 coalesce: set param[3], clear param[4] and param[5].
EFF_DspChanInit_AlgoType2_Dirty:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (DSP_ChipActiveFlags:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18748:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (DSP_AlgoChangedFlag:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0

; Effect 0x27, band 2 test: is any of param[6..8] dirty?
EFF_DspChanInit_AlgoType3_Dirty:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18752:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr z, EFF_DspChanInit_AlgoType4_Dirty
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18754:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr z, EFF_DspChanInit_AlgoType4_Dirty
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18756:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr nz, EFF_DspChanInit_AlgoType5_Dirty

; Effect 0x27, band 2 coalesce: set param[6], clear param[7] and param[8].
EFF_DspChanInit_AlgoType4_Dirty:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18752:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18754:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18756:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0

; Effect 0x27, band 3 test: is any of param[9..11] dirty?
EFF_DspChanInit_AlgoType5_Dirty:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18758:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr z, EFF_DspChanInit_AlgoType6_Dirty
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18760:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr z, EFF_DspChanInit_AlgoType6_Dirty
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18762:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr nz, EFF_DspChanInit_AlgoType7_Dirty

; Effect 0x27, band 3 coalesce: set param[9], clear param[10] and param[11].
EFF_DspChanInit_AlgoType6_Dirty:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18758:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18760:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18762:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0

; Effect 0x27, band 4 test: is any of param[12..14] dirty?
EFF_DspChanInit_AlgoType7_Dirty:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18764:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr z, EFF_DspChanInit_AlgoType8_Dirty
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18766:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr z, EFF_DspChanInit_AlgoType8_Dirty
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18768:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr nz, EFF_DspChanInit_AlgoType9_Dirty

; Effect 0x27, band 4 coalesce: set param[12], clear param[13] and param[14].
EFF_DspChanInit_AlgoType8_Dirty:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18764:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18766:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18768:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0

; Effect 0x4F path. If the slot's effect number is 0x4F, coalesce four PAIRS instead of
; five triples: param[1]->param[0], param[3]->param[2], param[5]->param[4],
; param[7]->param[6]; in each pair the odd flag is cleared. Otherwise jump to the 0x35 /
; 0x0F test at EFF_DspChanInit_AlgoType4F_Epilogue.
EFF_DspChanInit_AlgoType9_Dirty:
	ld bc, de
	extz xbc
	ld xhl, xbc
	sll xhl, 3
	sub xhl, xbc
	sll xhl, 3
	inc 8, xhl
	add xhl, xwa
	cpw (xhl), 0x4F
	jrl nz, EFF_DspChanInit_AlgoType4F_Epilogue
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18742:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr nz, EFF_DspChanInit_AlgoType4F_SubA
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18740:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18742:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0

; Effect 0x4F, pair 2: if param[3] is dirty, set param[2] and clear param[3].
EFF_DspChanInit_AlgoType4F_SubA:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (DSP_ChipActiveFlags:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr nz, EFF_DspChanInit_AlgoType4F_SubB
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18744:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (DSP_ChipActiveFlags:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0

; Effect 0x4F, pair 3: if param[5] is dirty, set param[4] and clear param[5].
EFF_DspChanInit_AlgoType4F_SubB:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (DSP_AlgoChangedFlag:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr nz, EFF_DspChanInit_AlgoType4F_SubC
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18748:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (DSP_AlgoChangedFlag:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0

; Effect 0x4F, pair 4: if param[7] is dirty, set param[6] and clear param[7].
EFF_DspChanInit_AlgoType4F_SubC:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18754:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr nz, EFF_DspChanInit_AlgoType4F_Epilogue
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18752:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18754:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x0

; Dispatch on the slot's effect number for the remaining special cases: 0x35 and 0x0F go
; to EFF_DspChanInit_AlgoType35_Dirty, everything else falls through to the 0x3F test at
; EFF_DspChanInit_AlgoType35_SubC.
EFF_DspChanInit_AlgoType4F_Epilogue:
	ld bc, de
	extz xbc
	ld xhl, xbc
	sll xhl, 3
	sub xhl, xbc
	sll xhl, 3
	inc 8, xhl
	add xhl, xwa
	cpw (xhl), 0x35
	jr z, EFF_DspChanInit_AlgoType35_Dirty
	ld bc, de
	extz xbc
	ld xhl, xbc
	sll xhl, 3
	sub xhl, xbc
	sll xhl, 3
	inc 8, xhl
	add xhl, xwa
	cpw (xhl), 0xF
	jrl nz, EFF_DspChanInit_AlgoType35_SubC

; Effects 0x35 / 0x0F. Gate: only if param[13] is dirty. Then, depending on the record's
; variant flag (+0x1E == 1), mark either {param[3], param[8], param[5], param[10]} or
; {param[4], param[9], param[6], param[11]} dirty -- the two interleaved halves that the
; two parameter-order lists at 0x0122A6 / 0x0122B1 walk.
EFF_DspChanInit_AlgoType35_Dirty:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18766:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jrl nz, EFF_DspChanInit_AlgoType35_SubC
	ld bc, de
	extz xbc
	ld xhl, xbc
	sll xhl, 3
	sub xhl, xbc
	sll xhl, 3
	inc 8, xhl
	add xhl, xwa
	cpw (xhl + 30), 0x1
	jr nz, EFF_DspChanInit_AlgoType35_SubA
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (DSP_ChipActiveFlags:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18756:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (DSP_AlgoChangedFlag:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18760:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	jr EFF_DspChanInit_AlgoType35_SubB

; The variant-flag == 0 half: mark param[4], param[9], param[6], param[11] dirty.
EFF_DspChanInit_AlgoType35_SubA:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18748:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18758:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18752:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18762:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1

; Join of the two halves: also mark the slot's VOLUME dirty flag (0x004970 + 50*slot).
EFF_DspChanInit_AlgoType35_SubB:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18784:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1
	jr EFF_DspChanInit_AlgoType35_SubF

; Effect 0x3F path: if param[1] or param[2] is dirty, mark param[0] (the level) dirty.
; param[0] is the value EFF_VolumeLoop later rewrites through the 0x0122C4 table.
EFF_DspChanInit_AlgoType35_SubC:
	ld bc, de
	extz xbc
	ld xhl, xbc
	sll xhl, 3
	sub xhl, xbc
	sll xhl, 3
	inc 8, xhl
	add xhl, xwa
	cpw (xhl), 0x3F
	jr nz, EFF_DspChanInit_AlgoType35_SubE
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18742:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr z, EFF_DspChanInit_AlgoType35_SubD
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18744:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr nz, EFF_DspChanInit_AlgoType35_SubE

; Effect 0x3F: perform that param[0] marking.
EFF_DspChanInit_AlgoType35_SubD:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18740:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1

; Common tail for effect 0x3F and for every effect that took none of the special paths:
; mark the slot's VOLUME dirty flag (0x004970 + 50*slot).
EFF_DspChanInit_AlgoType35_SubE:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18784:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1

; If the slot's LINK dirty flag (0x00496E + 50*slot) is set, also mark the parameter that
; the record names as the volume parameter (record +0x26) dirty, at
; 0x004944 + 50*slot + 2*record[+0x26]. A link change therefore always forces the level to
; be re-sent, which is what stops a re-linked slot coming back at the wrong gain.
EFF_DspChanInit_AlgoType35_SubF:
	ld bc, de
	mul bc, 0x32
	add bc, 0x10
	lda xhl, (18782:16)
	extz xbc
	add xbc, xhl
	cpw (xbc), 0x1
	jr nz, EFF_DspChanInit_AlgoType35_Epilogue
	ld bc, de
	extz xbc
	ld xhl, xbc
	sll xhl, 3
	sub xhl, xbc
	sll xhl, 3
	inc 8, xhl
	add xhl, xwa
	ld hl, (xhl + 38)
	sll hl, 1
	ld bc, de
	mul bc, 0x32
	add bc, hl
	lda xhl, (18756:16)
	extz xbc
	add xbc, xhl
	ldw (xbc), 0x1

; Slot-loop step: DE += 1, repeat while DE < 5, then return from EFF_DspChannel_InitFlags.
EFF_DspChanInit_AlgoType35_Epilogue:
	inc 1, de
	cp de, 5:i3
	jrl c, EFF_DspChannel_Init_AlgoCheck
	ret

; Already correctly named in both sources; documented here only.
; Entry: XWA = pointer to the new 290-byte config block (in practice 0x045324).
; Runs the three flag-preparation passes in order, re-supplying XWA to each because they
; clobber it: EFF_SlotActive_UpdateFlags (rebuild 0x004930[]), EFF_DSPLink_ResetFlags, and
; EFF_DspChannel_InitFlags (the dirty-flag coalescing documented above). Called only from
; DSP_State_DiffAndPrepare, which is itself called only from DSP_State_ApplyAll.
EFF_StateLoad_Prepare:	.include "includes/generated/cc900/EFF_StateLoad_Prepare.s"	; C: cc900/audio_process_dsp_and_effects_d_6a.c

; Mute every ACTIVE effect slot before the reprogramming burst.
; Entry: XWA = new config block (accepted but NOT used -- see below). Uses IZ = slot 0..4.
; For each slot whose EFF_SlotActive word (0x004930 + 2*slot) is 1:
;   - if the slot's "needs programming" flag (0x004940 + 50*slot) is 1 AND the effect
;     number taken from the SHADOW block (0x0045D2 + 56*slot, i.e. shadow+8+56*slot)
;     has a non-zero entry in the class table at 0x012226, then latch
;     0x0045BC + 2*slot = 1;
;   - unconditionally call EFF_Mute_WithDebug(slot) and remember that something was muted.
; If anything was muted, finish with DSP_ScheduleDelay(0x14) = a 20 ms settle.
; NOTE, measured: this routine reads the SHADOW copy of the effect number while every
; other loop in the dispatcher reads the NEW block. That asymmetry is deliberate -- you
; have to mute what is currently loaded, not what is about to be.
EFF_MuteLoop:	.include "includes/generated/cc900/EFF_MuteLoop.s"	; C: cc900/audio_process_dsp_and_effects.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	EFF_MuteLoop_SlotBody, EFF_MuteLoop + 9
	.set	EFF_MuteLoop_NoMute, EFF_MuteLoop + 93
	.set	EFF_MuteLoop_SlotNext, EFF_MuteLoop + 101
	.set	EFF_MuteLoop_Epilogue, EFF_MuteLoop + 107
	.set	EFF_MuteLoop_NoFlush, EFF_MuteLoop + 118

; Already correctly named in both sources; documented here only.
; Hardware-resets both DSP chips: DSP_Reset_WithDebug(0), DSP_Reset_WithDebug(1).
; Taken instead of EFF_MuteLoop when the config block's flagC (+0x04) is 1, i.e. on a cold
; or full reload. Note that DSP_Reset_WithDebug ignores its argument for the pin sequence.
DSP_ResetLoop:	.include "includes/generated/cc900/DSP_ResetLoop.s"	; C: cc900/audio_process_dsp_and_effects.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_ResetLoop_ResetChip, DSP_ResetLoop + 7
	.set	DSP_ResetLoop_Epilogue, DSP_ResetLoop + 19

; Already correctly named in both sources; documented here only.
; For each chip c in 0..1 whose DSP_ChipActive word (0x00493A + 2*c) is 1, call
; DSP_Mute_WithDebug(c), which uploads the chip-mute bytecode program selected from the
; pointer table at 0x01F3D0.
DSP_MuteLoop:	.include "includes/generated/cc900/DSP_MuteLoop.s"	; C: cc900/audio_process_dsp_and_effects.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_MuteLoop_MuteActiveChip, DSP_MuteLoop + 7
	.set	DSP_MuteLoop_Next, DSP_MuteLoop + 31
	.set	DSP_MuteLoop_Epilogue, DSP_MuteLoop + 37

; Already correctly named in both sources; documented here only.
; Mirror of DSP_MuteLoop using DSP_Unmute_WithDebug and the pointer table at 0x01F3E0.
; The firmware's own debug string for this operation is "DSP %d antimute".
DSP_UnmuteLoop:	.include "includes/generated/cc900/DSP_UnmuteLoop.s"	; C: cc900/audio_process_dsp_and_effects.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_UnmuteLoop_UnmuteActiveChip, DSP_UnmuteLoop + 7
	.set	DSP_UnmuteLoop_Next, DSP_UnmuteLoop + 31
	.set	DSP_UnmuteLoop_Epilogue, DSP_UnmuteLoop + 37

; Already correctly named in both sources; documented here only.
; If the global "algorithm change pending" word at 0x00493E is 1, tail-call
; DSP_AlgorithmChange (0x03800D) with XWA still pointing at the config block; otherwise
; return immediately. The flag is set by DSP_AlgoChange_CheckAndFlag, outside this region.
DSP_AlgorithmChangeCheck:	.include "includes/generated/cc900/DSP_AlgorithmChangeCheck.s"	; C: cc900/audio_process_dsp_and_effects.c

; Already correctly named in both sources; documented here only.
; HL = max(WA, BC), unsigned (`cp bc,wa / jr ule` keeps WA when BC <= WA). Used only to
; reduce the per-slot settle times from 0x01ED72 down to a single worst case that is then
; handed to DSP_ScheduleDelay.
Unsigned_Max_Select:	.include "includes/generated/cc900/Unsigned_Max_Select.s"	; C: cc900/audio_process_dsp_and_effects.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Unsigned_Max_Select_Return, Unsigned_Max_Select + 6

; Already correctly named in both sources; documented here only.
; Send every dirty parameter of one slot to its DSP.
; Entry: WA = slot, XBC = config block. Frame of 6 bytes; slot at (xsp+8), block at
; (xsp+4).
; Two paths, chosen on the slot's effect number:
;  - GENERIC: iterate i = 0 .. min(record[+0x2C], 17) - 1. Skip i if the parameter's dirty
;    flag (0x004944 + 50*slot + 2*i) is not 1, and skip i if i equals the record's volume
;    parameter index (record[+0x26]) -- EFF_VolumeLoop owns that one. Otherwise call
;    EFF_ParamEdit_WithDebug(slot, effectnumber, i, block).
;  - ORDERED, for effect 0x0F and effect 0x35 only: walk a byte list instead of a counter.
;    XIZ = 0x0122A6 + 11 * (record[+0x1E] & 1), i.e. list A or list B; the list is walked
;    until the byte 0x0C is found. Same dirty-flag test, same EFF_ParamEdit_WithDebug call.
;    The two lists differ only in their middle four entries, which is how the firmware
;    programs the "other half" of that algorithm's paired parameters.
; Calls out to: EFF_ParamEdit_WithDebug (0x038200) -> DSP_WriteParameter (bytecode
; interpreter, outside the region).
EFF_ParamIterator_Process:
	dec 6, xsp
	push xiz
	ld (xsp + 4), xbc
	ld (xsp + 8), wa
	ld wa, (xsp + 8)
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	sub xbc, xwa
	sll xbc, 3
	inc 8, xbc
	add xbc, (xsp + 4)
	ld wa, (xbc)
	cp wa, 0xF
	jrl z, EFF_ParamIter_SpecialAlgoPath
	cp wa, 0x35
	jrl z, EFF_ParamIter_SpecialAlgoPath
	ld wa, (xsp + 8)
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	sub xbc, xwa
	sll xbc, 3
	inc 8, xbc
	add xbc, (xsp + 4)
	ld wa, (xbc + 44)
	ldfr_werp WA, 0xFA
	cp_erpw 0xFA, 0x11, 0x00
	jr ule, EFF_ParamIter_CountClamp
	ldi_erpw 0xFA, 0x11, 0x00

; The parameter count from record[+0x2C] has just been clamped to 0x11 = 17; start the
; generic loop with IZ = 0.
EFF_ParamIter_CountClamp:
	ld iz, 0:i3
	cpw_erp IZ, 0xFA
	jrl nc, EFF_ParamIter_Epilogue

; Generic-path loop body: dirty test at 0x004944 + 50*slot + 2*IZ, volume-index skip, and
; the EFF_ParamEdit_WithDebug call.
EFF_ParamIter_StdLoop:
	ld bc, iz
	add bc, bc
	ld wa, (xsp + 8)
	mul wa, 0x32
	add wa, bc
	lda xbc, (18756:16)
	extz xwa
	add xwa, xbc
	cpw (xwa), 0x1
	jr nz, EFF_ParamIter_StdLoopNext
	ld wa, (xsp + 8)
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	sub xbc, xwa
	sll xbc, 3
	inc 8, xbc
	add xbc, (xsp + 4)
	cp iz, (xbc + 38)
	jr z, EFF_ParamIter_StdLoopNext
	ld wa, (xsp + 8)
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	sub xbc, xwa
	sll xbc, 3
	inc 8, xbc
	add xbc, (xsp + 4)
	ld xwa, (xsp + 4)
	push xwa
	ld wa, (xsp + 12)
	ld bc, (xbc)
	ld de, iz
	call EFF_ParamEdit_WithDebug

; Generic-path loop step: IZ += 1, repeat while IZ < the clamped count.
EFF_ParamIter_StdLoopNext:
	inc 1, iz
	cpw_erp IZ, 0xFA
	jr c, EFF_ParamIter_StdLoop
	jr EFF_ParamIter_Epilogue

; Effects 0x0F / 0x35: select the parameter-order list, XIZ = 0x0122A6 + 11*(rec[+0x1E]&1)
; (encoded as `lda XIZ,XBC+WA`), and bail out immediately if the first byte is the 0x0C
; terminator.
EFF_ParamIter_SpecialAlgoPath:
	ld wa, (xsp + 8)
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	sub xbc, xwa
	sll xbc, 3
	inc 8, xbc
	add xbc, (xsp + 4)
	ld wa, (xbc + 30)
	and wa, 0x1
	muls wa, 0xB
	lda xbc, (EFF_ParamIter_OrderTable:24)
	lda	xiz, (xbc+wa)
	cp (xiz), 0xC
	jr z, EFF_ParamIter_Epilogue

; Ordered-path loop body: parameter index comes from (XIZ), same dirty test, same
; EFF_ParamEdit_WithDebug call.
EFF_ParamIter_SpecialLoop:
	ld a, (xiz)
	extz wa
	ld bc, wa
	add bc, bc
	ld wa, (xsp + 8)
	mul wa, 0x32
	add bc, wa
	lda xwa, (18756:16)
	extz xbc
	add xbc, xwa
	cpw (xbc), 0x1
	jr nz, EFF_ParamIter_SpecialLoopNext
	ld wa, (xsp + 8)
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	sub xbc, xwa
	sll xbc, 3
	inc 8, xbc
	add xbc, (xsp + 4)
	ld a, (xiz)
	ld e, a
	extz de
	ld xwa, (xsp + 4)
	push xwa
	ld wa, (xsp + 12)
	ld bc, (xbc)
	call EFF_ParamEdit_WithDebug

; Ordered-path loop step: advance XIZ, stop on the 0x0C terminator.
EFF_ParamIter_SpecialLoopNext:
	inc 1, xiz
	cp (xiz), 0xC
	jr nz, EFF_ParamIter_SpecialLoop

; Restore XIZ, drop the 6-byte frame, return.
EFF_ParamIter_Epilogue:
	pop xiz
	inc 6, xsp
	ret

; Already correctly named in both sources; documented here only.
; Entry: WA = slot, XBC = config block. If the slot's VOLUME dirty word
; (0x004970 + 50*slot) is 1, run EFF_ParamIterator_Process for that slot; otherwise return
; without touching the DSP. Called from EFF_Change_Handler's epilogue, so a parameter
; sweep only happens for slots whose volume word was marked -- which is why
; EFF_DspChannel_InitFlags is so careful to set 0x004970.
EFF_VolumeChange_Check:	.include "includes/generated/cc900/EFF_VolumeChange_Check.s"	; C: cc900/audio_process_dsp_and_effects_d_6a.c

; Already correctly named in both sources; documented here only.
; Apply one slot's algorithm/data change.
; Entry: WA = slot, XBC = config block. Returns nothing.
; 1. Do nothing at all unless the slot's "needs programming" flag (0x004940 + 50*slot)
;    is 1.
; 2. Disconnect the slot first: EFF_Disconnect(slot, block[+0x06]) -- unconditionally for
;    slots != 2, and for slot 2 only when block[+0x04] (cold reload) is not 1.
; 3. Dispatch: slots 2, 3, 4 take the "algo vs data" fork -- EFF_Change_WithDebug when
;    block[+0x04] == 1, EFF_DataChange_WithDebug otherwise. Slots 0 and 1 always take
;    EFF_Change_WithDebug.
; 4. Finish with EFF_VolumeChange_Check(slot, block).
EFF_Change_Handler:	.include "includes/generated/cc900/EFF_Change_Handler.s"	; C: cc900/audio_process_dsp_and_effects_d_8a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	EFF_Change_Handler_NonSlot2, EFF_Change_Handler + 59
	.set	EFF_Change_Handler_SlotDispatch, EFF_Change_Handler + 71
	.set	EFF_Change_Handler_Slot234_AlgoPath, EFF_Change_Handler + 114
	.set	EFF_Change_Handler_Slot234_AltPath, EFF_Change_Handler + 153
	.set	EFF_Change_Handler_Epilogue, EFF_Change_Handler + 180

; Already correctly named in both sources; documented here only.
; The main reprogramming sweep. Entry: XWA = config block. Frame of 4 bytes; block at
; (xsp+4). Uses QIZ (the alternate register bank word, `ldiw_erp 0xFA`) as the running
; worst-case settle time, initialised to 0.
; Walks slots from 4 DOWN TO 0 (the descending order matters: the chain is torn down from
; the tail). For each slot:
;   - if block[+0x02] == 1 (algorithm changed) or block[+0x04] == 1 (cold reload), first
;     call EFF_WriteHeader(slot);
;   - if the slot is dirty (0x004940 + 50*slot == 1) or block[+0x00] == 1, fold the slot's
;     settle time byte from 0x01ED72 into the running maximum via Unsigned_Max_Select;
;   - call EFF_Change_Handler(slot, block).
; When the sweep ends, if the accumulated maximum is non-zero, DSP_ScheduleDelay(max)
; blocks the task for that many milliseconds. With the shipped table the worst case is 46.
EFF_HeaderChangeDataLoop:	.include "includes/generated/cc900/EFF_HeaderChangeDataLoop.s"	; C: cc900/audio_process_dsp_and_effects_d_6a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	EFF_HeaderChangeLoop_TestHeaderRewrite, EFF_HeaderChangeDataLoop + 17
	.set	EFF_HeaderChangeLoop_CallAlgo, EFF_HeaderChangeDataLoop + 37
	.set	EFF_HeaderChangeLoop_PostAlgo, EFF_HeaderChangeDataLoop + 43
	.set	EFF_HeaderChangeLoop_ActiveSlot, EFF_HeaderChangeDataLoop + 72
	.set	EFF_HeaderChangeLoop_CallChange, EFF_HeaderChangeDataLoop + 95
	.set	EFF_HeaderChangeLoop_Epilogue, EFF_HeaderChangeDataLoop + 111
	.set	EFF_HeaderChangeLoop_SkipApply, EFF_HeaderChangeDataLoop + 123

; Already correctly named in both sources; documented here only.
; Entry: XWA = config block. Slots 4 down to 0. For each slot whose LINK dirty flag
; (0x00496E + 50*slot) is 1 AND whose record field +0x36 is 1, call
; EFF_Link(slot, block[+0x06]) -- i.e. connect the slot into the effect chain by uploading
; the link bytecode program from the pointer table at 0x01F404.
EFF_LinkLoop:	.include "includes/generated/cc900/EFF_LinkLoop.s"	; C: cc900/audio_process_dsp_and_effects_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	EFF_LinkLoop_LinkSlotIfOn, EFF_LinkLoop + 14
	.set	EFF_LinkLoop_Next, EFF_LinkLoop + 75
	.set	EFF_LinkLoop_Epilogue, EFF_LinkLoop + 83

; Already correctly named in both sources; documented here only.
; The mirror of EFF_LinkLoop for slots that are being taken OUT of the chain
; (record +0x36 == 0). Entry: XWA = config block. Two descending passes over slots 4..0,
; the slot counter living in QIZ:
;  - Pass 1 only measures: for every slot with the LINK dirty flag set and +0x36 == 0,
;    max-reduce a constant 0x14 (20 ms). If anything matched, DSP_ScheduleDelay(20).
;  - Pass 2 acts: same predicate, but slots 2 and 3 are EXEMPT (they are the pair whose
;    disconnect is handled by EFF_Change_Handler instead). Everything else gets
;    EFF_Disconnect(slot, block[+0x06]). Each matching slot folds its own settle time from
;    0x01ED72 into a second maximum, and pass 2 ends with another DSP_ScheduleDelay.
; So an unlink costs up to two scheduled delays, 20 ms plus up to 46 ms.
EFF_SecondaryLinkPath:
	dec 4, xsp
	push xiz
	ld (xsp + 4), xwa
	ld iz, 0:i3
	ldiw_erp 0xFA, 4
	cp_erpw 0xFA, 0xFF, 0xFF
	jr le, EFF_SecLinkPath_Pass1Epilogue

; Pass 1 body: link-dirty test plus the +0x36 == 0 test, then max-reduce 0x14.
EFF_SecLinkPath_Pass1Body:
	ldto_werp WA, 0xFA
	mul wa, 0x32
	add wa, 0x10
	lda xbc, (18782:16)
	extz xwa
	add xwa, xbc
	cpw (xwa), 0x1
	jr nz, EFF_SecLinkPath_Pass1Next
	ldto_werp WA, 0xFA
	muls wa, 0x38
	ld bc, wa
	inc 8, bc
	ld xwa, (xsp + 4)
	lda	xwa, (xwa+bc)
	cpw (xwa + 54), 0x0
	jr nz, EFF_SecLinkPath_Pass1Next
	ld wa, iz
	ldw bc, 0x14
	calr Unsigned_Max_Select
	ld iz, hl

; Pass 1 descending step (decrements the QIZ slot counter).
EFF_SecLinkPath_Pass1Next:
	dec1w_erp 0xFA
	cp_erpw 0xFA, 0xFF, 0xFF
	jr gt, EFF_SecLinkPath_Pass1Body

; If pass 1 matched anything, DSP_ScheduleDelay(20 ms) before pass 2 runs.
EFF_SecLinkPath_Pass1Epilogue:
	cp iz, 0:i3
	jr z, EFF_SecLinkPath_Pass2Start
	ld wa, iz
	call DSP_ScheduleDelay

; Reset the accumulator and the QIZ slot counter for pass 2.
EFF_SecLinkPath_Pass2Start:
	ld iz, 0:i3
	ldiw_erp 0xFA, 4
	cp_erpw 0xFA, 0xFF, 0xFF
	jr le, EFF_SecLinkPath_Pass2Epilogue

; Pass 2 body: same predicate; slots 3 and 2 skip the EFF_Disconnect call.
EFF_SecLinkPath_Pass2Body:
	ldto_werp WA, 0xFA
	mul wa, 0x32
	add wa, 0x10
	lda xbc, (18782:16)
	extz xwa
	add xwa, xbc
	cpw (xwa), 0x1
	jr nz, EFF_SecLinkPath_Pass2Next
	ldto_werp WA, 0xFA
	muls wa, 0x38
	ld bc, wa
	inc 8, bc
	ld xwa, (xsp + 4)
	lda	xwa, (xwa+bc)
	cpw (xwa + 54), 0x0
	jr nz, EFF_SecLinkPath_Pass2Next
	cpiw_erp 0xFA, 3
	jr z, EFF_SecLinkPath_Pass2MaxVol
	cpi3_erpw 2, 0xFA
	jr z, EFF_SecLinkPath_Pass2MaxVol
	ldto_werp WA, 0xFA
	ld xbc, (xsp + 4)
	ld bc, (xbc + 6)
	call EFF_Disconnect

; Fold this slot's settle time byte (0x01ED72 + slot) into the pass-2 maximum. The build's
; name is a little off -- this is a settle-time reduction, not a volume one.
EFF_SecLinkPath_Pass2MaxVol:
	ld de, iz
	lda xwa, (EFF_SlotSettleTime_Table:24)
	ld	a, (xwa+qiz)
	ld c, a
	extz bc
	ld wa, de
	calr Unsigned_Max_Select
	ld iz, hl

; Pass 2 descending step.
EFF_SecLinkPath_Pass2Next:
	dec1w_erp 0xFA
	cp_erpw 0xFA, 0xFF, 0xFF
	jr gt, EFF_SecLinkPath_Pass2Body

; If pass 2 matched anything, DSP_ScheduleDelay(max).
EFF_SecLinkPath_Pass2Epilogue:
	cp iz, 0:i3
	jr z, EFF_SecLinkPath_Epilogue
	ld wa, iz
	call DSP_ScheduleDelay

; Restore XIZ, drop the frame, return.
EFF_SecLinkPath_Epilogue:
	pop xiz
	inc 4, xsp
	ret

; Already correctly named in both sources; documented here only.
; Entry: XWA = config block. Slots 0..4 ascending. For each slot, look up its volume
; parameter index v = record[+0x26] and test that parameter's dirty flag
; (0x004944 + 50*slot + 2*v). If it is set:
;   - SPECIAL CASE effect 0x3F: recompute the level in place. Read the byte
;     table[0x0122C4 + record[+0x06]] (values 99,70,50,40,20,10,5,0), subtract it from
;     record[+0x04] (= param[0]) and store the difference back into record[+0x04],
;     flooring at 0. This is the only place in the region that MUTATES the config block.
;   - Then call EFF_VolumeUpdate_WithDebug(slot, effectnumber, v, block).
; The mutation matters for emulation: the block the caller handed in is not read-only.
EFF_VolumeLoop:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xwa
	ld iz, 0:i3
	cp iz, 5:i3
	jrl nc, EFF_VolumeLoop_Epilogue

; Slot body: the record[+0x26] lookup, the dirty test, and the effect-0x3F fork.
EFF_VolumeLoop_TestVolumeDirty:
	ld wa, iz
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	sub xbc, xwa
	sll xbc, 3
	inc 8, xbc
	add xbc, (xsp + 2)
	ld bc, (xbc + 38)
	sll bc, 1
	ld wa, iz
	mul wa, 0x32
	add wa, bc
	lda xbc, (18756:16)
	extz xwa
	add xwa, xbc
	cpw (xwa), 0x1
	jrl nz, EFF_VolumeLoop_Next
	ld wa, iz
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	sub xbc, xwa
	sll xbc, 3
	inc 8, xbc
	add xbc, (xsp + 2)
	ld de, (xbc + 38)
	ld wa, iz
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	sub xbc, xwa
	sll xbc, 3
	inc 8, xbc
	add xbc, (xsp + 2)
	cpw (xbc), 0x3F
	jrl nz, EFF_VolumeLoop_ApplyDelta
	ld wa, iz
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	sub xbc, xwa
	sll xbc, 3
	inc 8, xbc
	ld xix, xbc
	add xix, (xsp + 2)
	ld wa, iz
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	sub xbc, xwa
	sll xbc, 3
	inc 8, xbc
	add xbc, (xsp + 2)
	lda xhl, (EFF_VolumeReduction_Steps:24)
	ld wa, (xbc + 6)
	ld	a, (xhl+wa)
	extz wa
	ld hl, (xix + 4)
	sub hl, wa
	ld wa, iz
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	sub xbc, xwa
	sll xbc, 3
	inc 8, xbc
	add xbc, (xsp + 2)
	ld (xbc + 4), hl
	ld wa, iz
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	sub xbc, xwa
	sll xbc, 3
	inc 8, xbc
	add xbc, (xsp + 2)
	cpw (xbc + 4), 0x0
	jr ge, EFF_VolumeLoop_ApplyDelta
	ld wa, iz
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	sub xbc, xwa
	sll xbc, 3
	inc 8, xbc
	add xbc, (xsp + 2)
	ldw (xbc + 4), 0x0

; Join point: push the block pointer and call EFF_VolumeUpdate_WithDebug.
EFF_VolumeLoop_ApplyDelta:
	ld wa, iz
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	sub xbc, xwa
	sll xbc, 3
	inc 8, xbc
	add xbc, (xsp + 2)
	ld xwa, (xsp + 2)
	push xwa
	ld wa, iz
	ld bc, (xbc)
	call EFF_VolumeUpdate_WithDebug

; Ascending slot step, repeat while slot < 5.
EFF_VolumeLoop_Next:
	inc 1, iz
	cp iz, 5:i3
	jrl c, EFF_VolumeLoop_TestVolumeDirty

; Restore IZ, drop the frame, return.
EFF_VolumeLoop_Epilogue:
	popw iz
	inc 4, xsp
	ret

; Already correctly named in both sources; documented here only.
; Entry: XWA = config block. Slots 4 down to 0, SKIPPING slots 3 and 2, calls
; EFF_Disconnect(slot, block[+0x06]). Reached only on the cold-reload / header-rewrite
; path of DSP_State_Dispatcher, right after a header write with slot argument 0.
EFF_DisconnectLoop:	.include "includes/generated/cc900/EFF_DisconnectLoop.s"	; C: cc900/audio_process_dsp_and_effects.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	EFF_DisconnectLoop_DisconnectSlot, EFF_DisconnectLoop + 14
	.set	EFF_DisconnectLoop_Next, EFF_DisconnectLoop + 34
	.set	EFF_DisconnectLoop_Epilogue, EFF_DisconnectLoop + 42

; Already correctly named in both sources; documented here only.
; THE ORCHESTRATOR OF THIS ENTIRE REGION. Entry: XWA = the new 290-byte config block,
; kept in XIZ throughout. Called only from DSP_State_ApplyAll, which is called only from
; DSP_State_LoadAndApplyAll (0x038DEF area) -- it is NOT in the Audio_Main_Loop hot path.
; Exact order of operations:
;   1. block[+0x04] == 1 (cold reload) ? DSP_ResetLoop : EFF_MuteLoop
;   2. DSP_MuteLoop            (per-chip mute)
;   3. DSP_AlgorithmChangeCheck (uploads the common header set if 0x00493E is pending)
;   4. if block[+0x04] == 1 or block[+0x02] != 1:
;        EFF_WriteHeader(0), then EFF_DisconnectLoop
;   5. DSP_UnmuteLoop
;   6. EFF_HeaderChangeDataLoop   (the per-slot reprogramming sweep)
;   7. EFF_LinkLoop               (connect slots whose +0x36 is 1)
;   8. EFF_VolumeLoop             (levels)
;   9. EFF_SecondaryLinkPath      (disconnect slots whose +0x36 is 0)
;  10. refresh the per-slot class cache: for slots 4..0, if the slot is dirty
;      (0x004940 + 50*slot == 1), write 0x0045BC + 2*slot = classtable[effectnumber] + 1,
;      or 0 when the class byte is 0.
; Everything the chips see comes out of steps 1-9; step 10 is bookkeeping only.
DSP_State_Dispatcher:	.include "includes/generated/cc900/DSP_State_Dispatcher.s"	; C: cc900/audio_process_dsp_and_effects_d_6a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_StateDispatcher_MutePath, DSP_State_Dispatcher + 15
	.set	DSP_StateDispatcher_PostMute, DSP_State_Dispatcher + 20
	.set	DSP_StateDispatcher_DisconnectPath, DSP_State_Dispatcher + 42
	.set	DSP_StateDispatcher_UnmutePath, DSP_State_Dispatcher + 53
	.set	DSP_StateDispatcher_AlgoLoop, DSP_State_Dispatcher + 84
	.set	DSP_StateDispatcher_AlgoClear, DSP_State_Dispatcher + 168
	.set	DSP_StateDispatcher_AlgoNext, DSP_State_Dispatcher + 184
	.set	DSP_StateDispatcher_Epilogue, DSP_State_Dispatcher + 192

; Already correctly named in both sources; documented here only.
; HL = byte at 0x012226 + WA, zero-extended: the DSP class of an effect number. 0 means
; "this effect has no DSP program at all"; the shipped table has 46 zeros, 71 ones and
; 11 twos over effect numbers 0..127.
DSP_State_LookupAlgoIndex:	.include "includes/generated/cc900/DSP_State_LookupAlgoIndex.s"	; C: cc900/audio_process_dsp_and_effects.c

; NAME LEFT UNCHANGED per the rules (it is a real, non-LABEL_ name in both sources), but
; it is WRONG: this is not data, it is a complete 18-byte routine, and the 18 bytes after
; it are a second one. See [UNCERTAIN] for the rename argument.
; What it actually does: XIY = 0x0046EC (source), XIX = 0x00480E (destination), BC = 0x91,
; LDIRW -- i.e. copy 145 words = 290 bytes, exactly one config block, from 0x0046EC to
; 0x00480E. Returns HL = 0. A config-block SNAPSHOT/SAVE.
; It has NO caller: an exhaustive search of the payload's disassembly for the address
; 0x037E3E (and for the 3-byte little-endian pointer) returns nothing. Dead code.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
; Renamed from DSP_State_Dispatcher_Data.
; Note: the rename argued for above is applied.
EFF_ConfigSnapshot_Save:	.include "includes/generated/cc900/EFF_ConfigSnapshot_Save.s"	; C: cc900/audio_process_dsp_and_effects.c
; No symbol at this address in symbols/subcpu_symbols_reference.txt -- genuinely new.
; The exact inverse of the routine above: XIY = 0x00480E (source), XIX = 0x0046EC
; (destination), BC = 0x91, LDIRW, return HL = 0. Copies 290 bytes back.
; Also has no caller anywhere in the payload -- dead code. Note that 0x0046EC is exactly
; 0x0045CA + 290, i.e. the block immediately after the live shadow block, and 0x00480E is
; 290 bytes after that; this pair is almost certainly a vestige of an earlier RAM layout
; in which the shadow was double-buffered.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
EFF_ConfigSnapshot_Restore:	.include "includes/generated/cc900/EFF_ConfigSnapshot_Restore.s"	; C: cc900/audio_process_dsp_and_effects.c

; Already correctly named in both sources; documented here only.
; Entry: WA = chip number, used ONLY for the debug trace ("DSP %d reset", strings at
; 0x0122CC / 0x0122D2). The pin sequence is fixed and hits BOTH chips regardless of the
; argument: DSP1_Deassert_Reset, DSP2_Deassert_Reset, DSP1_Assert_Reset,
; DSP2_Assert_Reset, DSP1_Deassert_Reset. Net effect: DSP1 comes out of reset, DSP2 is
; LEFT ASSERTED (held in reset) until DSP_AntiReset_WithDebug releases it.
DSP_Reset_WithDebug:	.include "includes/generated/cc900/DSP_Reset_WithDebug.s"	; C: cc900/audio_process_dsp_and_effects_b.c

; Already correctly named in both sources; documented here only.
; Entry: WA = chip number (trace only; strings 0x0122DA / 0x0122E0, "DSP %d anti reset").
; Body is a single DSP2_Deassert_Reset -- the release of the reset that
; DSP_Reset_WithDebug deliberately left asserted. Called from DSP_AlgorithmChange when
; block[+0x04] == 1.
DSP_AntiReset_WithDebug:	.include "includes/generated/cc900/DSP_AntiReset_WithDebug.s"	; C: cc900/audio_process_dsp_and_effects_b.c

; Already correctly named in both sources; documented here only.
; Entry: WA = effect slot 0..4. Traces "EFF %d mute" (slot+1 is printed, so the firmware's
; own logs are 1-based) and then uploads the slot's mute bytecode program:
; XBC = *(0x01F3BC + 4*slot), then DSP_WriteEFFConfig(slot, program).
; The five programs are at 0x01EAB4, 0x01EAC8, 0x01EADC, 0x01EAE6, 0x01EAF0.
EFF_Mute_WithDebug:	.include "includes/generated/cc900/EFF_Mute_WithDebug.s"	; C: cc900/audio_process_dsp_and_effects_b.c

; Already correctly named in both sources; documented here only.
; Entry: WA = chip 0..1. Traces "DSP %d mute" and uploads *(0x01F3D0 + 4*chip) via
; DSP_WriteGlobalConfig(chip, program). Programs at 0x01EA24, 0x01EA39, 0x01EA4E,
; 0x01EA63 -- the table holds four entries although only two chips exist.
DSP_Mute_WithDebug:	.include "includes/generated/cc900/DSP_Mute_WithDebug.s"	; C: cc900/audio_process_dsp_and_effects_b.c

; Already correctly named in both sources; documented here only.
; Entry: WA = chip 0..1. Traces "DSP %d antimute" and uploads *(0x01F3E0 + 4*chip) via
; DSP_WriteGlobalConfig. Programs at 0x01EA78, 0x01EA87, 0x01EA96, 0x01EAA5.
DSP_Unmute_WithDebug:	.include "includes/generated/cc900/DSP_Unmute_WithDebug.s"	; C: cc900/audio_process_dsp_and_effects_b.c

; Already correctly named in both sources; documented here only.
; Entry: WA = effect slot 0..4, BC = mode (the config block's +0x06, 0 or 1).
; Traces "EFF %d disconnect", then:
;   chip = byte(0x01ED6D + slot)                      -- 0,0,1,1,1
;   program = *(0x01F3F0 + 12*mode + 4*slot)
;   DSP_WriteGlobalConfig(chip, program)
; NOTE THE STRIDE. The pointer table is laid out as two contiguous runs of five 32-bit
; pointers -- disconnect at 0x01F3F0..0x01F403 and link at 0x01F404..0x01F417 -- i.e. a
; natural mode stride of 20, but the code computes 12 (`xde = mode*3; sll 2`). See
; [UNCERTAIN]; with mode == 1 slots 2..4 read pointers out of the link run.
EFF_Disconnect:	.include "includes/generated/cc900/EFF_Disconnect.s"	; C: cc900/audio_process_dsp_and_effects_b.c

; Already correctly named in both sources; documented here only.
; Byte-for-byte the same shape as EFF_Disconnect with the trace string "EFF %d link" and
; the base 0x01F404, including the same 12-per-mode stride. Programs at 0x01E602,
; 0x01E60D, 0x01E618, 0x01E624, 0x01E630.
EFF_Link:	.include "includes/generated/cc900/EFF_Link.s"	; C: cc900/audio_process_dsp_and_effects_b.c

; Already correctly named in both sources; documented here only.
; Entry: XWA = config block. Traces "argo change %d" (the firmware's own typo for "algo")
; with block[+0x06] as the argument. Uploads the fixed common-header program at 0x01E63C
; to chip 0; if block[+0x04] == 1, releases DSP2 from reset via DSP_AntiReset_WithDebug;
; then falls into EFF_LoadConfigs_ForChannel.
DSP_AlgorithmChange:	.include "includes/generated/cc900/DSP_AlgorithmChange.s"	; C: cc900/audio_process_dsp_and_effects_d_6a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	EFF_LoadConfigs_ForChannel, DSP_AlgorithmChange + 55

; Already correctly named in both sources; documented here only.
; Entry: WA = effect slot. Traces "EFF %d headder" (sic). Looks up chip =
; byte(0x01ED6D + slot) and, ONLY IF that chip is 0, uploads the header program at
; 0x01E496 via DSP_WriteGlobalConfig(0, ...). Slots 2, 3 and 4 map to chip 1 and therefore
; do nothing here at all -- the per-sample common header is an IC311 concept only.
EFF_WriteHeader:	.include "includes/generated/cc900/EFF_WriteHeader.s"	; C: cc900/audio_process_dsp_and_effects_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	EFF_WriteHeader_Return, EFF_WriteHeader + 63

; Already correctly named in both sources; documented here only.
; Entry: WA = slot, BC = effect number. Traces "EFF %d change %02X".
; Uploads TWO programs per effect: the algorithm from *(0x01ED7C + 4*eff) and the
; parameter/coefficient set from *(0x01EF0C + 4*eff), both via DSP_WriteEFFConfig(slot,..).
; Slot 1 has two hard-coded overrides that bypass the tables entirely:
;   effect 0x09 -> programs 0x01DFA5 and 0x01E0B9
;   effect 0x0A -> programs 0x01E1DE and 0x01E342
; Those two are the only effects in the whole firmware with slot-specific microcode.
EFF_Change_WithDebug:	.include "includes/generated/cc900/EFF_Change_WithDebug.s"	; C: cc900/audio_process_dsp_and_effects_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	EFF_Change_Case0xA, EFF_Change_WithDebug + 86
	.set	EFF_Change_GenericLookup, EFF_Change_WithDebug + 110
	.set	EFF_Change_ChannelNot1, EFF_Change_WithDebug + 158
	.set	EFF_Change_Return, EFF_Change_WithDebug + 204

; Already correctly named in both sources; documented here only.
; Entry: WA = slot, BC = effect number. Traces "EFF %d data change %02X". Uploads ONLY the
; coefficient/parameter program *(0x01EF0C + 4*eff) -- the algorithm microcode is left
; alone. This is the cheap path taken by EFF_Change_Handler for slots 2/3/4 when the
; config block is not asking for a cold reload.
EFF_DataChange_WithDebug:	.include "includes/generated/cc900/EFF_DataChange_WithDebug.s"	; C: cc900/audio_process_dsp_and_effects_b.c

; Already correctly named in both sources; documented here only.
; Entry: WA = slot, BC = effect number, DE = parameter index, plus the config block PUSHED
; by the caller (read at (xsp+10)); returns with `retd 0x4`, i.e. it pops that argument.
; Traces "EFF %d para. edit %02X %04X", the last field being the parameter's current value
; read from block + 12 + 56*slot + 2*paramindex. Then calls DSP_WriteParameter(slot, eff,
; paramindex, block) -- the bytecode interpreter that walks the effect's parameter
; descriptor and emits the DSP_Write* sequences documented at the end of this region.
EFF_ParamEdit_WithDebug:	.include "includes/generated/cc900/EFF_ParamEdit_WithDebug.s"	; C: cc900/audio_process_dsp_and_effects_b.c

; Already correctly named in both sources; documented here only.
; Entry: WA = slot, BC = effect number, DE = parameter index, config block pushed by the
; caller; `retd 0x4`. Returns immediately (doing nothing) when DE == 0x63 (99), which is
; the "no volume parameter" sentinel.
; Traces "EFF %d vol %04X". Then the important part:
;   - if the record's link flag (+0x36) is non-zero, just DSP_WriteParameter(...);
;   - if it is ZERO (the slot is being unlinked), the value is TEMPORARILY forced to 0,
;     DSP_WriteParameter is called with that 0, and the original value is written back
;     into the block afterwards. That is how a slot is faded out of the chain without
;     losing the user's level setting.
EFF_VolumeUpdate_WithDebug:
	dec 6, xsp
	pushw iz
	ld (xsp + 4), de
	ld (xsp + 6), bc
	ld iz, wa
	cpw (xsp + 4), 0x63
	jrl z, EFF_VolumeUpdate_Return
	lda xwa, (Str_EffVolume_Prefix:24)
	call Debug_Print_String
	ld wa, iz
	inc 1, wa
	call Debug_Print_Byte
	lda xwa, (Str_EffVolume_Suffix:24)
	call Debug_Print_String
	ld wa, (xsp + 4)
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	ld wa, iz
	extz xwa
	ld xde, xwa
	sll xde, 3
	sub xde, xwa
	sll xde, 3
	add xde, xbc
	add xde, (xsp + 12)
	ld wa, (xde + 12)
	call Debug_Print_Word
	ld wa, iz
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	sub xbc, xwa
	sll xbc, 3
	inc 8, xbc
	add xbc, (xsp + 12)
	ld wa, (xbc + 54)
	cp wa, 0:i3
	jr z, EFF_VolumeUpdate_ZeroAndReload
	ld xwa, (xsp + 12)
	push xwa
	ld wa, iz
	ld bc, (xsp + 10)
	ld de, (xsp + 8)
	call DSP_WriteParameter
	jr EFF_VolumeUpdate_Return

; The unlinked branch: save the value, store 0, send it, restore the value.
EFF_VolumeUpdate_ZeroAndReload:
	ld wa, (xsp + 4)
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	ld wa, iz
	extz xwa
	ld xde, xwa
	sll xde, 3
	sub xde, xwa
	sll xde, 3
	add xde, xbc
	add xde, (xsp + 12)
	ld wa, (xde + 12)
	ld (xsp + 2), wa
	ld wa, (xsp + 4)
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	ld wa, iz
	extz xwa
	ld xde, xwa
	sll xde, 3
	sub xde, xwa
	sll xde, 3
	add xde, xbc
	add xde, (xsp + 12)
	ldw (xde + 12), 0x0
	ld xwa, (xsp + 12)
	push xwa
	ld wa, iz
	ld bc, (xsp + 10)
	ld de, (xsp + 8)
	call DSP_WriteParameter
	ld wa, (xsp + 4)
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	ld wa, iz
	extz xwa
	ld xde, xwa
	sll xde, 3
	sub xde, xwa
	sll xde, 3
	add xde, xbc
	add xde, (xsp + 12)
	ld wa, (xsp + 2)
	ld (xde + 12), wa

; Restore IZ, drop the 6-byte frame, `retd 0x4`.
EFF_VolumeUpdate_Return:
	popw iz
	inc 6, xsp
	retd 0x4

; Cross-ROM call targets in the sub-CPU BOOT ROM (Cross-ref: subcpu/boot/kn5000_subcpu_boot.s,
; where these addresses carry the labels DEBUG_OUTPUT_STRING and HEX_BYTE_TO_ASCII; both are
; dumped bytes of IC30).  The boot ROM's character sink behind them, SUB_FEC1 (0xFFFEC1), is
; `ld iz,0xFE00` + 12 x nop + ret in the dump (IC30 is flagged BAD_DUMP, but these bytes are
; not 0xFF) -- it outputs nothing, so with that boot ROM every Debug_Print_* call below is a
; no-op apart from its cost.
	.equ	BootROM_DEBUG_OUTPUT_STRING, 0xFFFEA1
	.equ	BootROM_HEX_BYTE_TO_ASCII, 0xFFFE86

; ----------------------------------------------------------------------------
; Debug_Print_String - Print null-terminated string via serial port
; Entry: XWA = pointer to string
; Exit:  WA = 0
; Notes: Calls boot ROM serial output routine at 0xFFFEA1
; ----------------------------------------------------------------------------
Debug_Print_String:	.include "includes/generated/cc900/Debug_Print_String.s"	; C: cc900/audio_process_dsp_and_effects.c

; ----------------------------------------------------------------------------
; Debug_Print_Byte - Print single byte as hex via serial port
; Entry: A = byte value
; Exit:  WA = 0
; Notes: Calls boot ROM serial byte output routine at 0xFFFE86
; ----------------------------------------------------------------------------
Debug_Print_Byte:	.include "includes/generated/cc900/Debug_Print_Byte.s"	; C: cc900/audio_process_dsp_and_effects.c

; ----------------------------------------------------------------------------
; Debug_Print_Word - Print 16-bit word as hex via serial port
; Entry: WA = word value
; Exit:  WA = 0
; Notes: Prints high byte first, then low byte
; ----------------------------------------------------------------------------
Debug_Print_Word:	; 038375h
	pushw iz
	ld iz, wa
	ld wa, iz
	srl wa, 8	; Get high byte
	extz wa
	call BootROM_HEX_BYTE_TO_ASCII
	ld wa, 0:i3
	ldto_berp A, 0xF8	; Get low byte
	extz wa
	call BootROM_HEX_BYTE_TO_ASCII
	ld wa, 0:i3
	popw iz
	ret

; Already correctly named in both sources; documented here only.
; A one-instruction thunk: `jp 0x036305` (DSP_WaitForDelay). Entry: WA = milliseconds.
; DSP_WaitForDelay computes target = (WA + 1) >> 1 added to the 32-bit tick counter at
; 0x001040 and then loops calling Kernel_YieldRotate(3) until 0x001040 reaches it.
; This is a COOPERATIVE BLOCK, not a spin: the calling task is descheduled. It is the only
; thing in this region that can suspend the caller for a bounded-by-a-timer amount of
; time -- see the findings note about the sub->main stall.
; Call sites in this region: 0x0377D2 (20 ms after muting), 0x037ADE (up to 46 ms after
; the reprogramming sweep), 0x037B9C and 0x037C1D (the two unlink passes).
DSP_ScheduleDelay:
	jp DSP_WaitForDelay

