; ===========================================================================
; Voice_CtrlChange - Process MIDI Control Change messages
; ===========================================================================
; Entry: XWA = pointer to 4-byte CC data:
;        +0 = status byte (0xBn where n=channel)
;        +1 = channel number (0-25)
;        +2 = controller number
;        +3 = controller value
; Exit:  Voice parameters updated based on CC number
; Notes: Handles standard MIDI CCs: Mod Wheel(1), Volume(7), Pan(10),
;        Expression(11), Sustain(64), and the KN5000 part parameters the main CPU's SndPart_SetParam sends
;        as the controller of their Lsw number: 0x5B reverb send, 0x5D DSP-effect send, 0x80 bend range,
;        0x81 tuning, 0x82 key shift, 0x95 glide pedal, 0x97 sustain length, 0x9C key scaling.  0x91 (the
;        part's velocity-switch configuration) comes from SwbtB2_Code9A_Listener; 0x9B (gate routing override)
;        and 0x9D (TG pan override) are read by the voice code but no main-CPU sender was found in v10
; ===========================================================================
; MIDI Control Change entry point, called from MIDI_Dispatch (0x034D93 family).
; XWA -> 4-byte message: +0 status, +1 part 0..0x19, +2 controller, +3 value.
; Rejects part >= 0x1A immediately.  Explicit compares route CC 0x9D, 0x9C, 0x9B, 0x97,
; 0x95, 0x91, 0x5E, 0x5D, 0x5B, 0x40, 0x0B, 0x0A, 0x07 and 0x01 to the handlers below.
; Everything else falls into the CHANNEL-MODE range check: (cc - 0x78) must be 0..0x0A,
; then a word from the table at 0x00F739 is added to the base 0x02A306 and jumped to.
; Decoded targets: 0x78->0x02A3EB, 0x79->0x02A3F6, 0x7B->0x02A402, 0x80->0x02A41D,
; 0x81->0x02A433, 0x82->0x02A457; 0x7A, 0x7C, 0x7D, 0x7E and 0x7F all land on
; Voice_CC_Exit, i.e. Local Control and the Omni/Mono/Poly mode messages are ignored.
Voice_CtrlChange:	.include "includes/generated/cc900/Voice_CtrlChange.s"	; C: cc900/voice_ctrlchange_af_20a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_CC_ModWheel, Voice_CtrlChange + 132
	.set	Voice_CC_Volume, Voice_CtrlChange + 154
	.set	Voice_CC_Pan, Voice_CtrlChange + 190
	.set	Voice_CC_Expression, Voice_CtrlChange + 221
	.set	Voice_CC_Sustain, Voice_CtrlChange + 257
	.set	Voice_CC_ReverbSend, Voice_CtrlChange + 295
	.set	Voice_CC_DspEffectSend, Voice_CtrlChange + 317
	.set	Voice_CC_Portamento, Voice_CtrlChange + 339
	.set	Voice_CC_Num120, Voice_CtrlChange + 361
	.set	Voice_CC_Num121, Voice_CtrlChange + 372
	.set	Voice_CC_Num123, Voice_CtrlChange + 384
	.set	Voice_CC_BendRange, Voice_CtrlChange + 411
	.set	Voice_CC_Tuning, Voice_CtrlChange + 433
	.set	Voice_CC_KeyShift, Voice_CtrlChange + 469
	.set	Voice_CC_VelSwitchConfig, Voice_CtrlChange + 490
	.set	Voice_CC_GlidePedal, Voice_CtrlChange + 511
	.set	Voice_CC_SustainLength, Voice_CtrlChange + 532
	.set	Voice_CC_GateRoutingMode, Voice_CtrlChange + 553
	.set	Voice_CC_KeyScaling, Voice_CtrlChange + 574
	.set	Voice_CC_TgPanMode, Voice_CtrlChange + 595
	.set	Voice_CC_Exit, Voice_CtrlChange + 614

; MIDI 0xD0 channel pressure.  XWA -> message (+1 part, +2 = 0, +3 value; MIDI_SendChannelPressure on the main CPU).  Rejects part >= 0x1A,
; follows the patch pointer at part+0x06 and switches on (patch+0x10) & 0xC0 exactly as
; Voice_ModWheel_Apply does, then runs two descriptor loops (0x02A530 stereo, 0x02A589 mono)
; that each call AudioChannel_Dispatch twice.
Voice_ChanPressure:
	lda xsp, (xsp - 10)
	pushw_erp 0xFA
	ld (xsp + 8), xwa
	ld xwa, (xsp + 8)
	cp (xwa + 1), 0x1A
	jrl nc, Voice_ChanPressure_Exit
	ld xwa, (xsp + 8)
	ld a, (xwa + 1)
	ld (xsp + 6), a
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld a, (xwa + 16)
	and a, 0xC0
	cp a, 0x80
	jr z, Voice_ChanPressure_MonoLoopStart
	cp a, 0x40
	jr z, Voice_ChanPressure_StereoLoopStart
	cp a, 0xC0
	jr z, Voice_ChanPressure_StereoLoopStart
	cp a, 0:i3
	jrl nz, Voice_ChanPressure_Exit

; StereoLoopStart of Voice_ChanPressure.
Voice_ChanPressure_StereoLoopStart:
	ld a, (xsp + 6)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld (xsp + 2), xwa
	ldib_erp 0xFB, 0
	cpib_erp 0xFB, 2
	jrl nc, Voice_ChanPressure_Exit

; StereoLoopBody of Voice_ChanPressure.
Voice_ChanPressure_StereoLoopBody:
	ld a, (xsp + 6)
	ldfr_berp A, 0xF0
	extz ix
	ld xwa, (xsp + 8)
	ld a, (xwa + 3)
	ld l, a
	extz hl
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x3
	ld bc, wa
	add bc, 0x23
	ld xwa, (xsp + 2)
	lda	xde, (xwa+bc)
	ld wa, ix
	ld bc, hl
	calr AudioChannel_Dispatch
	inc1b_erp 0xFB
	cpib_erp 0xFB, 2
	jr c, Voice_ChanPressure_StereoLoopBody
	jr Voice_ChanPressure_Exit

; MonoLoopStart of Voice_ChanPressure.
Voice_ChanPressure_MonoLoopStart:
	ld a, (xsp + 6)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld (xsp + 2), xwa
	ldib_erp 0xFB, 0
	cpib_erp 0xFB, 2
	jr nc, Voice_ChanPressure_Exit

; MonoLoopBody of Voice_ChanPressure.
Voice_ChanPressure_MonoLoopBody:
	ld a, (xsp + 6)
	ldfr_berp A, 0xF0
	extz ix
	ld xwa, (xsp + 8)
	ld a, (xwa + 3)
	ld l, a
	extz hl
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x3
	ld bc, wa
	add bc, 0x21
	ld xwa, (xsp + 2)
	lda	xde, (xwa+bc)
	ld wa, ix
	ld bc, hl
	calr AudioChannel_Dispatch
	inc1b_erp 0xFB
	cpib_erp 0xFB, 2
	jr c, Voice_ChanPressure_MonoLoopBody

; common exit of Voice_ChanPressure.
Voice_ChanPressure_Exit:
	popw_erp 0xFA
	lda xsp, (xsp + 10)
	ret

; MIDI 0xE0.  XWA -> message: +1 part, +2 LSB, +3 MSB.  Rejects part >= 0x1A.  Assembles the
; 14-bit value as ((MSB << 7) | LSB) with bit 15 forced set, follows the patch pointer, and
; tail-jumps to AudioChannel_Dispatch with XDE = patch+0x14 (classes 0x40/0xC0/0x00) or
; patch+0x12 (class 0x80).  The forced bit 15 is what marks the value as pitch-bend for the
; downstream handlers.
Voice_PitchBend:	.include "includes/generated/cc900/Voice_PitchBend.s"	; C: cc900/voice_ctrlchange_p_17a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_PitchBend_BranchA, Voice_PitchBend + 72
	.set	Voice_PitchBend_BranchB, Voice_PitchBend + 102

; Calls Voice_NoteState_Clear for parts 0..0x19, then walks the voice list from
; Voice_Query_AllChannels and issues per-voice tone-generator writes with the standard strobe.
; Called from Voice_ResetAllControllers.
Voice_AllVoices_PortamentoReset:
	push xiz
	ldib_erp 0xFB, 0
	cp_erpb 0xFB, 0x1A
	jr nc, Voice_AllVoices_PortamentoReset_NopCont1

; loop body of Voice_AllVoices_PortamentoReset.
Voice_AllVoices_PortamentoReset_LoopBody:
	ldto_berp A, 0xFB
	extz wa
	call Voice_NoteState_Clear
	inc1b_erp 0xFB
	cp_erpb 0xFB, 0x1A
	jr c, Voice_AllVoices_PortamentoReset_LoopBody

; NopCont1: settling gap plus the next address/data pair of Voice_AllVoices_PortamentoReset.
Voice_AllVoices_PortamentoReset_NopCont1:
	call Voice_Query_AllChannels
	lda xwa, (xhl + 5)
	ld xiz, xwa
	cp (xiz), 0x40
	jr nc, Voice_AllVoices_PortamentoReset_Exit

; NopCont2: settling gap plus the next address/data pair of Voice_AllVoices_PortamentoReset.
Voice_AllVoices_PortamentoReset_NopCont2:
	res	7, (P6:8)
	ld a, (xiz)
	extz wa
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xa200
	jr Voice_AllVoices_PortamentoReset_NopCont3

; NopCont3: settling gap plus the next address/data pair of Voice_AllVoices_PortamentoReset.
Voice_AllVoices_PortamentoReset_NopCont3:
	nop
	nop
	nop
	res	7, (P6:8)
	ld a, (xiz)
	extz wa
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xa280
	jr Voice_AllVoices_PortamentoReset_LoopStep

; loop step of Voice_AllVoices_PortamentoReset.
Voice_AllVoices_PortamentoReset_LoopStep:
	nop
	nop
	nop
	inc 1, xiz
	cp (xiz), 0x40
	jr c, Voice_AllVoices_PortamentoReset_NopCont2

; common exit of Voice_AllVoices_PortamentoReset.
Voice_AllVoices_PortamentoReset_Exit:
	pop xiz
	ret

; A = value.  Stores the global pitch-bend range and then drives
; Voice_PerVoice_PortamentoPitchUpdate so sounding notes pick it up.  Reached from SysEx
; dispatch entry 3 and from Voice_ResetAllControllers with WA = 0x40.
; ★ CORRECTED 2026-09-25: the code below calls Voice_SetMasterTune (the (A - 0x40) * 2 word at
; 0x041347), not the pitch-bend-range setter, and then Pitch_Refresh_Sounding_Voices over
; Voice_Query_AllChannels, not Voice_PerVoice_PortamentoPitchUpdate; and its table slot is
; Voice_SystemMsg_CaseOffsets index 2 (sub-command 0x82).  Renamed from
; Voice_SetPitchBendRangeAndApply to Voice_SetMasterTuneAndApply to say what it calls.
Voice_SetMasterTuneAndApply:	.include "includes/generated/cc900/Voice_SetMasterTuneAndApply.s"	; C: cc900/voice_ctrlchange_a_7a.c

; A = enable flag: Voice_SetKeyShiftEnable(A), then Pitch_Refresh_Sounding_Voices over
; Voice_Query_AllChannels -- the "...AndApply" shape of the entry above.  It had no label; no
; caller in v1.42 (address as 3-byte LE value, calr displacement searched).
Voice_SetKeyShiftEnableAndApply:	.include "includes/generated/cc900/Voice_SetKeyShiftEnableAndApply.s"	; C: cc900/voice_ctrlchange_a_7a.c

; WA = part index.  Recomputes the part's portamento pitch state; two internal branches
; (0x02A771, 0x02A77B) select between the target-reached and still-gliding cases.
Voice_PerVoice_PortamentoPitchUpdate:	.include "includes/generated/cc900/Voice_PerVoice_PortamentoPitchUpdate.s"	; C: cc900/voice_ctrlchange.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_PerVoice_PortamentoPitchUpdate_BranchA, Voice_PerVoice_PortamentoPitchUpdate + 122
	.set	Voice_PerVoice_PortamentoPitchUpdate_BranchB, Voice_PerVoice_PortamentoPitchUpdate + 132
	.set	Voice_PerVoice_PortamentoPitchUpdate_Exit, Voice_PerVoice_PortamentoPitchUpdate + 148

; Calls Voice_PerVoice_PortamentoPitchUpdate for parts 0..0x19.  Reached from SysEx dispatch
; entry 1 (sub-command 0x92) and from Voice_ResetAllControllers.
Voice_AllVoices_PortamentoUpdate:	.include "includes/generated/cc900/Voice_AllVoices_PortamentoUpdate.s"	; C: cc900/voice_ctrlchange_a_8a_qizinc.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_AllVoices_PortamentoUpdate_LoopBody, Voice_AllVoices_PortamentoUpdate + 12
	.set	Voice_AllVoices_PortamentoUpdate_Exit, Voice_AllVoices_PortamentoUpdate + 29

; MIDI 0xF0 / manufacturer sub-command dispatcher.  XWA -> message, C = (XWA+2) is the
; sub-command byte.  Three sub-commands are special-cased first: 0x99 -> DispatchEntry2,
; 0x92 -> DispatchEntry1, 0x91 -> DispatchEntry0, 0x09 -> the head of the stub table.
; Otherwise index = C - 0x80; accepted if 0 <= index <= 7 (sub-commands 0x80..0x87), or,
; after a further -0x1B, if 8 <= index <= 0x16 (sub-commands 0xA3..0xB1).  Everything else
; returns.  The accepted index is doubled, used to read a word from the table at 0x00F74F
; and added to the stub-table base 0x02A7FC.
Voice_SystemMsg:	.include "includes/generated/cc900/Voice_SystemMsg.s"	; C: cc900/voice_ctrlchange_af_20a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_SystemMsg_DispatchJump, Voice_SystemMsg + 55
	.set	Voice_SystemMsg_DispatchTable, Voice_SystemMsg + 77
	.set	Voice_SystemMsg_CallStubRet1, Voice_SystemMsg + 85
	.set	Voice_SystemMsg_CallStubRet2, Voice_SystemMsg + 93
	.set	Voice_SystemMsg_SetMasterTune, Voice_SystemMsg + 101
	.set	Voice_SystemMsg_SetPitchBendRange, Voice_SystemMsg + 107
	.set	Voice_SystemMsg_SetKeyShiftEnable, Voice_SystemMsg + 113
	.set	Voice_SystemMsg_SetScaleTuneMode, Voice_SystemMsg + 121
	.set	Voice_SystemMsg_SetRhythmMode, Voice_SystemMsg + 129
	.set	Voice_SystemMsg_DispatchEntry0, Voice_SystemMsg + 137
	.set	Voice_SystemMsg_DispatchEntry1, Voice_SystemMsg + 145
	.set	Voice_SystemMsg_DispatchEntry2, Voice_SystemMsg + 148
	.set	Voice_SystemMsg_SubA3, Voice_SystemMsg + 156
	.set	Voice_SystemMsg_SubA4, Voice_SystemMsg + 159
	.set	Voice_SystemMsg_SubA5, Voice_SystemMsg + 171
	.set	Voice_SystemMsg_SubA6, Voice_SystemMsg + 183
	.set	Voice_SystemMsg_SubA7, Voice_SystemMsg + 195
	.set	Voice_SystemMsg_SubA8, Voice_SystemMsg + 207
	.set	Voice_SystemMsg_SubA9, Voice_SystemMsg + 219
	.set	Voice_SystemMsg_SubAA, Voice_SystemMsg + 231
	.set	Voice_SystemMsg_SubAB, Voice_SystemMsg + 243
	.set	Voice_SystemMsg_SubAC, Voice_SystemMsg + 255
	.set	Voice_SystemMsg_SubAD, Voice_SystemMsg + 268
	.set	Voice_SystemMsg_SubAE, Voice_SystemMsg + 281
	.set	Voice_SystemMsg_SubAF, Voice_SystemMsg + 294
	.set	Voice_SystemMsg_SubB0, Voice_SystemMsg + 307
	.set	Voice_SystemMsg_SubB1, Voice_SystemMsg + 315
	.set	Voice_SystemMsg_Ignore, Voice_SystemMsg + 323

; Full audio-side reset.  Reached by `jp` from the audio init sequence (right after
; DSP_Config_Init, DSP_Reset, Voice_Reset_Engine(0), DSP_ResetWriteBufferPtr,
; VoiceSlot_ClearAll and `0x041342 = 0`), and from CC 0x79.
; Per part 0..0x19 it applies, in order: mod wheel 0, volume 0x7F, pan 0x40, expression 0x7F,
; sustain 0, reverb send 0, DSP-effect send 0, portamento 0, Voice_PortamentoSlots_WriteHW,
; Voice_NoteState_Clear, Voice_SetLFO_ActiveFlag, bend range 2, tuning 0x80 (centre),
; key shift 0x40 (none), velocity-switch configuration 0, glide pedal 0, sustain length 6, gate routing
; mode 1, key scaling 0, TG pan mode 0.
; Then globally: Voice_SetPolyphonyMode(2), the two ret-stubs with 0x7F,
; Voice_SetMasterTuneAndApply(0x40), Voice_SetPitchBendRange(0), Voice_SetKeyShiftEnable(0),
; ScaleTune_Set_Global_Mode(0), Voice_SetRhythmMode(0), Voice_SetVelSwitchConfig(0),
; Voice_AllVoices_PortamentoUpdate, Voice_SetCCMaxFlag(0), Voice_AllVoices_PortamentoReset,
; ScaleTune_Set_User_Offset(index 0..0x0B, value 0), Voice_AllVoices_UpdateVelocity(1),
; ScaleTune_Set_Global_Enabled(0).
; ★ The 0..0x0B loop is TWELVE iterations, not 26 -- one per pitch class, which is the
; strongest evidence that the 0x04134E array is a scale-tune table.
Voice_ResetAllControllers:
	pushw_erp 0xFA
	ldib_erp 0xFB, 0
	cp_erpb 0xFB, 0x1A
	jrl nc, Voice_ResetAllControllers_PostLoop

; loop body of Voice_ResetAllControllers.
Voice_ResetAllControllers_LoopBody:
	ldto_berp A, 0xFB
	extz wa
	ld bc, 0:i3
	calr Voice_ModWheel_Apply
	ldto_berp A, 0xFB
	extz wa
	ldw bc, 0x7F
	calr Voice_CC_SetVolume
	ldto_berp A, 0xFB
	extz wa
	ldw bc, 0x40
	calr Voice_CC_SetPan
	ldto_berp A, 0xFB
	extz wa
	ldw bc, 0x7F
	calr Voice_CC_SetExpression
	ldto_berp A, 0xFB
	extz wa
	ld bc, 0:i3
	calr Voice_CC_SetSustain
	ldto_berp A, 0xFB
	extz wa
	ld bc, 0:i3
	calr Voice_CC_SetReverbSend
	ldto_berp A, 0xFB
	extz wa
	ld bc, 0:i3
	calr Voice_CC_SetDspEffectSend
	ldto_berp A, 0xFB
	extz wa
	ld bc, 0:i3
	calr Voice_Portamento_OnHandler
	ldto_berp A, 0xFB
	extz wa
	calr Voice_PortamentoSlots_WriteHW
	ldto_berp A, 0xFB
	extz wa
	call Voice_NoteState_Clear
	ldto_berp A, 0xFB
	extz wa
	call Voice_SetLFO_ActiveFlag
	ldto_berp A, 0xFB
	extz wa
	ld bc, 2:i3
	calr Voice_CC_SetBendRange
	ldto_berp A, 0xFB
	extz wa
	ldw bc, 0x80
	calr Voice_CC_SetTuning
	ldto_berp A, 0xFB
	extz wa
	ldw bc, 0x40
	calr Voice_CC_SetKeyShift
	ldto_berp A, 0xFB
	extz wa
	ld bc, 0:i3
	calr Voice_CC_SetVelSwitchConfig
	ldto_berp A, 0xFB
	extz wa
	ld bc, 0:i3
	calr Voice_CC_SetGlidePedal
	ldto_berp A, 0xFB
	extz wa
	ld bc, 6:i3
	calr Voice_CC_SetSustainLength
	ldto_berp A, 0xFB
	extz wa
	ld bc, 1:i3
	calr Voice_CC_SetGateRoutingMode
	ldto_berp A, 0xFB
	extz wa
	ld bc, 0:i3
	calr Voice_CC_SetKeyScaling
	ldto_berp A, 0xFB
	extz wa
	ld bc, 0:i3
	calr Voice_CC_SetTgPanMode
	inc1b_erp 0xFB
	cp_erpb 0xFB, 0x1A
	jrl c, Voice_ResetAllControllers_LoopBody

; PostLoop of Voice_ResetAllControllers.
Voice_ResetAllControllers_PostLoop:
	ld wa, 2:i3
	calr Voice_SetPolyphonyMode
	ldw wa, 0x7F
	calr VoiceCC_Stub_Ret1
	ldw wa, 0x7F
	calr VoiceCC_Stub_Ret2
	ldw wa, 0x40
	calr Voice_SetMasterTuneAndApply
	ld wa, 0:i3
	calr Voice_SetPitchBendRange
	ld wa, 0:i3
	calr Voice_SetKeyShiftEnable
	ld wa, 0:i3
	calr ScaleTune_Set_Global_Mode
	ld wa, 0:i3
	calr Voice_SetRhythmMode
	ld wa, 0:i3
	calr Voice_SetVelSwitchConfig
	calr Voice_AllVoices_PortamentoUpdate
	ld wa, 0:i3
	calr Voice_SetCCMaxFlag
	calr Voice_AllVoices_PortamentoReset
	ldib_erp 0xFB, 0
	cp_erpb 0xFB, 0x0C
	jr nc, Voice_ResetAllControllers_ChanModeExit

; The twelve-iteration loop; see the note above about its real meaning.
Voice_ResetAllControllers_ChanModeLoop:
	ldto_berp A, 0xFB
	extz wa
	ld bc, 0:i3
	calr ScaleTune_Set_User_Offset
	inc1b_erp 0xFB
	cp_erpb 0xFB, 0x0C
	jr c, Voice_ResetAllControllers_ChanModeLoop

; ChanModeExit of Voice_ResetAllControllers.
Voice_ResetAllControllers_ChanModeExit:
	ld wa, 1:i3
	calr Voice_AllVoices_UpdateVelocity
	ld wa, 0:i3
	calr ScaleTune_Set_Global_Enabled
	popw_erp 0xFA
	ret

; A = part index.  For each of the 4 output slots i = 0..3: computes the slot address
; part_base + 0x6E + i*0x25 via Math_Multiply32 (0x03D8CA), dereferences the long pointer at
; slot+0x00, takes bytes +2 and +3 of that record, assembles them as (b3 << 8) | b2, masks
; to 12 bits and stores the word at part_base + 0x102 + i*2.
; So the portamento target for each slot is a 12-bit pitch value copied out of the slot's
; tone record.  Pure memory; no hardware.
Voice_PortamentoTargets_SetAll:	.include "includes/generated/cc900/Voice_PortamentoTargets_SetAll.s"	; C: cc900/voice_ctrlchange_p_17c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_PortamentoTargets_SetAll_LoopBody, Voice_PortamentoTargets_SetAll + 15
	.set	Voice_PortamentoTargets_SetAll_Exit, Voice_PortamentoTargets_SetAll + 171

; A = part, C = slot 0..3.  Stores A into slot+0x00 of part_base + 0x6E + slot*0x25 and
; installs the constant long pointer 0x00F8B0 at slot+0x04.  0x00F8B0 is therefore the
; default (ROM) tone record used when no patch record has been bound to the slot.
Voice_PortamentoTarget_SetSlot:	.include "includes/generated/cc900/Voice_PortamentoTarget_SetSlot.s"	; C: cc900/voice_ctrlchange_p_17a.c

; A = part, C = slot.  Reads (slotrecord+3) & 0x30 >> 4 as a 2-bit selector, fetches a
; 32-bit base from [0x045314]+0x70 and a 16-bit multiplier from [0x045314]+0xEC, computes
; base + multiplier*selector + 0x045310, and stores the 32-bit result at slot+0x08.
; 0x045314 is a long pointer into the shared DSP/tone parameter block.
Voice_PortamentoTarget_ComputePitch:	.include "includes/generated/cc900/Voice_PortamentoTarget_ComputePitch.s"	; C: cc900/voice_ctrlchange_m_16a.c

; A = part index.  Compares the four words at part_base+0x00, +0x02, +0x04 and +0x06 of the
; slot-selection block against zero and mirrors the results into bits 0..3 of the part flags
; word at part_base+0x02.  Set = that slot is in use.  Called first thing by
; Voice_InitFromSlot (0x02ADC1).
Voice_UpdateFlagsFromSlot:	.include "includes/generated/cc900/Voice_UpdateFlagsFromSlot.s"	; C: cc900/voice_ctrlchange.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_UpdateFlagsFromSlot_BranchA, Voice_UpdateFlagsFromSlot + 52
	.set	Voice_UpdateFlagsFromSlot_BranchB, Voice_UpdateFlagsFromSlot + 56
	.set	Voice_UpdateFlagsFromSlot_BranchC, Voice_UpdateFlagsFromSlot + 69
	.set	Voice_UpdateFlagsFromSlot_BranchD, Voice_UpdateFlagsFromSlot + 73
	.set	Voice_UpdateFlagsFromSlot_BranchE, Voice_UpdateFlagsFromSlot + 86
	.set	Voice_UpdateFlagsFromSlot_BranchF, Voice_UpdateFlagsFromSlot + 90
	.set	Voice_UpdateFlagsFromSlot_Exit, Voice_UpdateFlagsFromSlot + 102

; E = group number 0..2, BC = a packed word of three 4-bit fields.  For each of the three
; fields it reads a destination byte-offset from the 3-byte-stride tables at 0x00F77D,
; 0x00F77E and 0x00F77F (indexed by E*3), and stores (BC & 0x0F) at that offset in the
; caller's 9-byte stack scratch array, shifting BC right by 4 between fields.
; Together the three calls expand three packed words into a flat 9-entry priority array.
Voice_Selector_Unpack3Groups:	.include "includes/generated/cc900/Voice_Selector_Unpack3Groups.s"	; C: cc900/voice_ctrlchange.c

; XWA -> three packed words, XDE -> result index byte, XBC -> a counter word, plus a fourth
; pointer pushed by the caller and read at (XSP+26).
; Builds the 9-byte array with three Voice_Selector_Unpack3Groups calls, then scans entries
; d = 0..8 twice over:
;   * L remembers the FIRST entry whose value is non-zero;
;   * E remembers the FIRST entry whose value is >= 4, and every such entry increments the
;     counter word pointed to by XBC.
; If any entry reached 4 the E candidate wins, otherwise the L candidate is used.  The chosen
; index goes to *XDE and the corresponding array value to *(XSP+26).  Returns with `retd 4`.
; ★ Both candidates start at 0xFF and there is NO fallback: if all nine entries are zero,
; 0xFF is written out as the selected index.  See findings.
Voice_Selector_FindBestSlot:	.include "includes/generated/cc900/Voice_Selector_FindBestSlot.s"	; C: cc900/voice_ctrlchange_a_9b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Selector_FindBestSlot_InnerLoop, Voice_Selector_FindBestSlot + 61
	.set	Voice_Selector_FindBestSlot_SlotCheck, Voice_Selector_FindBestSlot + 83
	.set	Voice_Selector_FindBestSlot_Update, Voice_Selector_FindBestSlot + 110
	.set	Voice_Selector_FindBestSlot_InnerStep, Voice_Selector_FindBestSlot + 117
	.set	Voice_Selector_FindBestSlot_OuterStep, Voice_Selector_FindBestSlot + 146
	.set	Voice_Selector_FindBestSlot_Exit, Voice_Selector_FindBestSlot + 168

; Recomputes the three mix-weight / pitch-offset words of one part from that part's four
; articulation words.
; IN : A = part index (0..0x19).  OUT: none in registers.
; Writes part+0x10E, part+0x110, part+0x112 (0x041476/0x041478/0x04147A + part*0x11F).
; Body: forms XHL = part+0x102 (the articulation word array) and calls
; Voice_Selector_FindBestSlot with three output pointers into its own frame --
; XBC -> COUNT, XDE -> INDEX, pushed arg -> VALUE. FindBestSlot scatters the 3x3 nibbles of
; artic[0..2] into a 9-byte scratch buffer through the permutation table at
; 0x00F77D..0x00F785 (3 bytes per group), then returns INDEX = the first scratch entry >= 4
; (else the first non-zero entry), VALUE = that entry, COUNT = how many entries are >= 4.
; The three results are then table-mapped:
;   part+0x10E = u16 [0x00F786 + COUNT*2]            (10-entry table)
;   part+0x112 = u16 [0x00F79A + INDEX*2]            (9-entry table)
;   part+0x110 = u16[0x00F7D2 + COUNT*2]
;              + u16[0x00F7AC + INDEX*2]
;              + u16[0x00F7BE + VALUE*2]
; The FIVE tables are exactly 10/9/9/10/10 entries and butt up against each other
; (0x00F786+0x14 = 0x00F79A, 0x00F79A+0x12 = 0x00F7AC, 0x00F7AC+0x12 = 0x00F7BE,
; 0x00F7BE+0x14 = 0x00F7D2, 0x00F7D2+0x14 = 0x00F7E6), so the five spans tile
; 0x00F786-0x00F7E5 exactly and end where Voice_Portamento_Rate_Table begins.  Their
; labels are Voice_Part_Trim_Table_A (was Const_Zero_Byte + PitchDetune_OffsetTable) / Voice_Part_Trim_Table_B /
; Voice_Part_Trim_Addend_1 / Voice_Part_Trim_Addend_2 / Voice_Part_Trim_Base.
; ★ CORRECTED: this used to read "The four tables are exactly 10/9/9/10 entries ... which
; is what pins COUNT to 0..9 and INDEX to 0..8".  The fifth table (0x00F7D2, loaded two
; instructions below) was missing from the count, and the causality was backwards: a
; table's size cannot bound its own subscript.  What the code does guarantee:
;   COUNT is bounded.  Voice_Selector_FindBestSlot (0x02AC54) zeroes the counter
;     (`ld (xwa),0x0`) and increments it at most once per entry over d = 0..8, so COUNT is
;     0..9 and the two 10-entry tables (0x00F786, 0x00F7D2) cannot be over-run.
;   INDEX is NOT bounded.  Both candidates start at 0xFF (`ldb e,0xFF / ldb l,0xFF`) and
;     there is no post-loop fallback, so an all-zero scratch array leaves INDEX = 0xFF; the
;     0x00F79A read would then address 0x00F79A + 0x1FE = 0x00F998, inside
;     AUDIO_CMD_TONEEDIT_JUMPTABLE (0x00F973-0x00F99A), putting a jump-table word into
;     part+0x112.  [INFERENCE] the mechanism is read off the code; whether the all-zero case
;     is REACHABLE at run time is unproven -- symbols/proposals/subcpu-region-07.txt reaches
;     the same limit and declines to call it a defect.
;   VALUE is a nibble.  Voice_Selector_Unpack3Groups masks each field with 0x0F, so VALUE is
;     0..15 while Voice_Part_Trim_Addend_2 (0x00F7BE) holds only 10 entries; VALUE >= 10
;     reads on into Voice_Part_Trim_Base.  [INFERENCE] whether VALUE ever exceeds 9 at run
;     time is likewise unproven.
; Touches no hardware. Only caller: Voice_InitFromSlot (0x02ADC1), i.e. it runs whenever an
; articulation parameter changes, never per note.
Voice_Selector_ComputeMixWeights:	.include "includes/generated/cc900/Voice_Selector_ComputeMixWeights.s"	; C: cc900/voice_ctrlchange_p_17a.c

; "An articulation parameter of this part changed" -- recompute everything derived from it.
; IN : A = part index. Calls Voice_UpdateFlagsFromSlot (0x02AB83), which sets/clears bits
; 0..3 of the part's layer-enable mask (part+0x02) according to whether each of the four
; articulation words is non-zero, then Voice_Selector_ComputeMixWeights, then zeroes the
; four articulation depth bytes part+0x10A..+0x10D (0x041472..0x041475).
; Called from VoiceSlot_AltInit (0x02F7C4 region). Touches no hardware.
Voice_InitFromSlot:	.include "includes/generated/cc900/Voice_InitFromSlot.s"	; C: cc900/voice_ctrlchange_a_8a.c

; NOT a data table -- it is the first of seven articulation-parameter setter routines that
; run from 0x02AE22 to 0x02AFF6 (see [UNCERTAIN] on the name).
; IN : A = part index, C = new value byte.
; This one replaces the LOW BYTE (bits 0..7) of articulation word 0, i.e.
; part+0x102 = (part+0x102 & 0xFF00) | C. Then calls Voice_UpdateFlagsFromSlot and
; Voice_Selector_ComputeMixWeights so the derived words are refreshed.
; Called from VoiceAlloc_CheckAndInit_FromRecord+0x102 (0x02EDE7) with A taken from the command
; record byte +0x01 (part) and C from byte +0x04 (value) -- i.e. it is the handler for one
; parameter number of the external/SysEx parameter-change dispatcher.
; ★ Renamed 2026-09-25 from VoiceSlot_DataTable_02AE22: header: replaces the low byte of articulation word 0, part+0x102 = (.. & 0xFF00) | C.
Voice_SetArticWord0_LowByte:	.include "includes/generated/cc900/Voice_SetArticWord0_LowByte.s"	; C: cc900/voice_ctrlchange_a_8a.c
; Second of the seven articulation setters. IN: A = part index, C = value byte.
; part+0x106 = (part+0x106 & 0xFFF0) | (C & 0x0F)   (articulation word 2, bits 0..3)
; part+0x104 = (part+0x104 & 0xFFF0) | (C >> 4)     (articulation word 1, bits 0..3)
; Then Voice_UpdateFlagsFromSlot + Voice_Selector_ComputeMixWeights.
; Called from 0x02EE06. No symbol exists for this address in either the LLVM build or the
; reference file -- this is a new name.
Voice_Artic_SetWord2Word1_Nibble0:	.include "includes/generated/cc900/Voice_Artic_SetWord2Word1_Nibble0.s"	; C: cc900/voice_ctrlchange_a_8a.c
; Third setter. IN: A = part index, C = value byte.
; part+0x106 = (part+0x106 & 0xFF0F) | ((C & 0x0F) << 4)
; part+0x104 = (part+0x104 & 0xFF0F) | (C & 0xF0)
; Then Voice_UpdateFlagsFromSlot + Voice_Selector_ComputeMixWeights. Called from 0x02EE25.
; New name -- no symbol at this address in either source.
Voice_Artic_SetWord2Word1_Nibble1:	.include "includes/generated/cc900/Voice_Artic_SetWord2Word1_Nibble1.s"	; C: cc900/voice_ctrlchange_a_8a.c
; Fourth setter. IN: A = part index, C = value byte.
; part+0x102 = (part+0x102 & 0xF0FF) | ((C & 0x0F) << 8)
; part+0x106 = (part+0x106 & 0xF0FF) | ((C & 0xF0) << 4)
; Then Voice_UpdateFlagsFromSlot + Voice_Selector_ComputeMixWeights. Called from 0x02EE44.
; New name -- no symbol at this address in either source.
Voice_Artic_SetWord0Word2_Nibble2:	.include "includes/generated/cc900/Voice_Artic_SetWord0Word2_Nibble2.s"	; C: cc900/voice_ctrlchange_a_8a.c
; Fifth setter. IN: A = part index, C = value byte.
; part+0x104 = (part+0x104 & 0xF0FF) | ((C & 0x0F) << 8)
; part+0x108 = C >> 4                               (articulation word 3, whole word)
; Then Voice_UpdateFlagsFromSlot + Voice_Selector_ComputeMixWeights. Called from 0x02EE63.
; New name -- no symbol at this address in either source.
Voice_Artic_SetWord1Nibble2_And_Word3:	.include "includes/generated/cc900/Voice_Artic_SetWord1Nibble2_And_Word3.s"	; C: cc900/voice_ctrlchange_a_8a.c
; Sixth setter, and the first that writes DEPTH bytes rather than articulation nibbles.
; IN: A = part index, C = packed value byte. Signed, and it does NOT refresh the derived
; words (no Voice_UpdateFlagsFromSlot / ComputeMixWeights call), unlike the five above.
;   part+0x10A (0x041472) = ((i8)C >> 4) * 4          [sra 4 then sla 2 on E]
;   part+0x10B (0x041473) = sign_extend_nibble(C & 0x0F) * 2
; These two bytes are the depths applied in Voice_Slot_CalcArticParams' i==3 arm.
; Called from 0x02EEFE. New name -- no symbol at this address in either source.
Voice_Artic_SetDepthPair_A:	.include "includes/generated/cc900/Voice_Artic_SetDepthPair_A.s"	; C: cc900/voice_ctrlchange.c
; Seventh setter, the sibling of 0x02AF82 for the other depth pair.
; IN: A = part index, C = packed value byte.
;   part+0x10C (0x041474) = ((i8)C >> 4) * 4
;   part+0x10D (0x041475) = sign_extend_nibble(C & 0x0F) * 8
; These are the depths applied in Voice_Slot_CalcArticParams' i==0..2 arm.
; Called from 0x02EF6A. New name -- no symbol at this address in either source.
Voice_Artic_SetDepthPair_B:	.include "includes/generated/cc900/Voice_Artic_SetDepthPair_B.s"	; C: cc900/voice_ctrlchange.c

; Read-modify-write of one unsigned byte with a signed delta and a clamp.
; IN : XWA = address of the byte, C = signed delta (sign-extended to 16 bits),
;      DE = upper bound, one stacked word = lower bound.  OUT: the byte is updated.
; value = zero_extend((XWA)); value += (i16)C; if (value > DE) value = DE;
; if (value < lower) value = lower; (XWA) = (u8)value. Returns with `retd 2` (pops the
; stacked lower bound). Only callers are the two arms of Voice_Slot_CalcArticParams.
Voice_SignedClamp:	.include "includes/generated/cc900/Voice_SignedClamp.s"	; C: cc900/voice_ctrlchange.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_SignedClamp_ClampHi, Voice_SignedClamp + 16
	.set	Voice_SignedClamp_ClampLo, Voice_SignedClamp + 24

; Applies this part's articulation words and depth bytes to four consecutive 0x51-byte
; (81) parameter blocks.
; IN : A = part index. Reads part+0x10C and part+0x10D into locals, and loads the u32
; pointer at part+0x6E (0x0413D6) into XIZ -- that is the head of the block array.
; For i = 0..3, with BC = the u16 articulation word at part+0x102+i*2:
;   (XIZ+0x02) = BC & 0xFF
;   (XIZ+0x03) = ((XIZ+0x03) & 0xF0) | ((BC >> 8) & 0x0F)
;   if i < 3 : Voice_SignedClamp(&XIZ+0x27, delta = part+0x10C, 0..0x64)
;              Voice_SignedClamp(&XIZ+0x2D, delta = part+0x10D, 0..0x64)
;   if i == 3: Voice_SignedClamp(&XIZ+0x17, delta = part+0x10A, 0..0x7F)
;              Voice_SignedClamp(&XIZ+0x29, delta = part+0x10B, 0..0x64)
;              Voice_SignedClamp(&XIZ+0x2B, delta = part+0x10B, 0..0x64)
;   XIZ += 0x51
; The 0x51 stride is the same 81 that Voice_KeyIndex_Pack3Nibbles uses as its outer digit
; weight, so the array being walked is one plane of a 9x9x9 table.
; Only caller: DSP_Cmd2B_AlgoSelect -- i.e. this runs when the DSP algorithm is (re)selected,
; not per note. Touches no hardware.
Voice_Slot_CalcArticParams:
	dec 8, xsp
	push xiz
	ld (xsp + 10), a
	ld a, (xsp + 10)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x25fe:24)
	ld	a, (xbc+wa)
	ld (xsp + 6), a
	ld a, (xsp + 10)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x25ff:24)
	ld	a, (xbc+wa)
	ld (xsp + 8), a
	ld a, (xsp + 10)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2560:24)
	ld	xiz, (xbc+wa)
	ldw (xsp + 4), 0x0
	cpw (xsp + 4), 0x4
	jrl nc, Voice_Slot_CalcArticParams_Exit

; Top of the i = 0..3 loop; unpacks articulation word i into (XIZ+0x02)/(XIZ+0x03).
Voice_Slot_CalcArticParams_LoopBody:
	ld wa, (xsp + 4)
	extz xwa
	add xwa, xwa
	ld xde, xwa
	add xde, 0x102
	ld a, (xsp + 10)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	add xwa, xde
	ld bc, (xwa)
	ld a, c
	ld (xiz + 2), a
	andmi8 (xiz + 3), 0xF0
	ld wa, bc
	srl wa, 8
	and wa, 0xF
	or (xiz + 3), a
	cpw (xsp + 4), 0x3
	jr nc, Voice_Slot_CalcArticParams_Type3Branch
	lda xde, (xiz + 39)
	ld a, (xsp + 6)
	ld c, a
	exts bc
	pushw 0x0
	ld xwa, xde
	ldw de, 0x64
	calr Voice_SignedClamp
	lda xde, (xiz + 45)
	ld a, (xsp + 8)
	ld c, a
	exts bc
	pushw 0x0
	ld xwa, xde
	ldw de, 0x64
	calr Voice_SignedClamp
	jr Voice_Slot_CalcArticParams_LoopStep

; The i == 3 arm: clamps fields +0x17, +0x29 and +0x2B using depths part+0x10A/+0x10B.
Voice_Slot_CalcArticParams_Type3Branch:
	lda xde, (xiz + 23)
	ld a, (xsp + 10)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x25fc:24)
	ld	a, (xbc+wa)
	ld c, a
	exts bc
	pushw 0x0
	ld xwa, xde
	ldw de, 0x7F
	calr Voice_SignedClamp
	lda xde, (xiz + 41)
	ld a, (xsp + 10)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x25fd:24)
	ld	a, (xbc+wa)
	ld c, a
	exts bc
	pushw 0x0
	ld xwa, xde
	ldw de, 0x64
	calr Voice_SignedClamp
	lda xde, (xiz + 43)
	ld a, (xsp + 10)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x25fd:24)
	ld	a, (xbc+wa)
	ld c, a
	exts bc
	pushw 0x0
	ld xwa, xde
	ldw de, 0x64
	calr Voice_SignedClamp

; i++, XIZ += 0x51, loop while i < 4.
Voice_Slot_CalcArticParams_LoopStep:
	incw 1, (xsp + 4)
	lda xiz, (xiz + 81)
	cpw (xsp + 4), 0x4
	jrl c, Voice_Slot_CalcArticParams_LoopBody

; Restore XIZ and return.
Voice_Slot_CalcArticParams_Exit:
	pop xiz
	inc 8, xsp
	ret

; Picks/repacks one articulation word according to how low the sounding key is.
; IN : A = part index, C = physical TG slot, E = which articulation word (0..3).
; OUT: HL = the resulting word. Touches no hardware.
; note = (u16 at 0x04308E + C*0x47 + 6) >> 8, i.e. the LIVE slot record's final pitch word,
; high byte = the key number. If note + 12 >= 0x24 the articulation word is returned
; unchanged. Otherwise (very low keys) the low nibble n0 = w & 0x0F and the next nibble
; n1 = (w >> 4) & 0x0F are compared: if n0 < n1 the result is w & 0x0FF0, else it is
; (w & 0x0F00) | (n0 << 4). Only caller: WaveSel_StageB_Build_Reg040_Footage (0x0238F8).
Voice_Slot_CalcAmpNibble:	.include "includes/generated/cc900/Voice_Slot_CalcAmpNibble.s"	; C: cc900/voice_ctrlchange.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Slot_CalcAmpNibble_BranchA, Voice_Slot_CalcAmpNibble + 65
	.set	Voice_Slot_CalcAmpNibble_BranchB, Voice_Slot_CalcAmpNibble + 119
	.set	Voice_Slot_CalcAmpNibble_Exit, Voice_Slot_CalcAmpNibble + 139

; The high-key counterpart of Voice_Slot_CalcAmpNibble: selects among the nibbles of one
; articulation word according to how many octaves above the top break point the key is.
; IN : A = part index, C = physical TG slot, E = which articulation word (0..3).
; OUT: HL = the resulting word. Touches no hardware.
; L counts how many times 12 must be subtracted from (slotpitch >> 8) - 12 before it drops
; below 0x54; that count is the "octave offset".
;   L == 0 : return the articulation word unchanged.
;   L == 1 : with n1 = (w>>4)&0x0F and n2 = (w>>8)&0x0F, return unchanged if n1 >= n2, else
;            (w & 0x000F) | (n2 << 4).
;   L >= 2 : with n0 = w & 0x0F, return whichever of n0 / n1 / n2 the two comparisons pick
;            (effectively the value that survives the highest key range).
; Only caller: WaveSel_StageB_Build_Reg040_Footage_StateB.
Voice_Slot_FindOctaveOffset:	.include "includes/generated/cc900/Voice_Slot_FindOctaveOffset.s"	; C: cc900/voice_ctrlchange.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Slot_FindOctaveOffset_BranchA, Voice_Slot_FindOctaveOffset + 54
	.set	Voice_Slot_FindOctaveOffset_BranchB, Voice_Slot_FindOctaveOffset + 66
	.set	Voice_Slot_FindOctaveOffset_BranchC, Voice_Slot_FindOctaveOffset + 84
	.set	Voice_Slot_FindOctaveOffset_BranchD, Voice_Slot_FindOctaveOffset + 152
	.set	Voice_Slot_FindOctaveOffset_BranchE, Voice_Slot_FindOctaveOffset + 215
	.set	Voice_Slot_FindOctaveOffset_BranchF, Voice_Slot_FindOctaveOffset + 219
	.set	Voice_Slot_FindOctaveOffset_Exit, Voice_Slot_FindOctaveOffset + 225

; Converts three packed 4-bit digits into a linear index of a 9 x 9 x 9 table.
; IN : WA = the packed word.  OUT: HL = ((WA>>8)&0x0F)*0x51 + ((WA>>4)&0x0F)*9 + (WA&0x0F).
; 0x51 = 81 = 9*9, so the digits are base-9 and each entry of the outer plane is the same
; 0x51 stride that Voice_Slot_CalcArticParams steps by. Callers: WaveSel_StageB_Build_Reg040_Footage and
; WaveSel_StageB_Build_Reg040_Footage_StateB. Touches no hardware.
Voice_KeyIndex_Pack3Nibbles:	.include "includes/generated/cc900/Voice_KeyIndex_Pack3Nibbles.s"	; C: cc900/voice_ctrlchange.c

; IN : XWA = live voice-slot record. Adds the u16 at part+0x10E (via the slot's +0x23 part
; pointer) into the slot's pitch accumulator at +0x0D. That word is the one
; Voice_Selector_ComputeMixWeights derives from the COUNT result. Called only from
; Voice_Release_Type4 (0x02BD51).
Voice_Slot_LoadPitchOffset_A:	.include "includes/generated/cc900/Voice_Slot_LoadPitchOffset_A.s"	; C: cc900/voice_ctrlchange.c

; Same as 0x02B2E9 but adds part+0x110 (the summed mix-weight word) into slot+0x0D.
; Called only from Voice_Init_Type1 (0x02C434).
Voice_Slot_LoadPitchOffset_B:	.include "includes/generated/cc900/Voice_Slot_LoadPitchOffset_B.s"	; C: cc900/voice_ctrlchange.c

; Advances one voice slot's portamento by the time elapsed since the part's last stamp.
; IN : XWA = live voice-slot record. XIZ := (slot+0x23) = the part record.
; Step 1: slot+0x0D += (i8)part+0x10A  (the coarse per-tick offset).
; Step 2: if bit 7 of part+0x118 is SET, re-stamp part+0x114 with the current value of the
;   32-bit free-running counter at 0x001040 (read with interrupts masked to level 6:
;   `ei 6` ... `ei 0`) and RETURN WITHOUT APPLYING ANY SWEEP. Otherwise:
;   elapsed = counter - part+0x114, clamped (unsigned) to 0x7FFF;
;   rate = (i8)part+0x10B + zero_extend((slot+0x17)->+0x29), clamped to 0..0x64 and then to
;          >= 0 (0x02B37C..0x02B386);
;   product = Math_Multiply32(u16 [0x00F7E6 + rate*2], elapsed) >> 10;
;   if product > 0x0FFF then slot+0x0D = 0xC000 (the "swept out" sentinel) else
;   slot+0x0D -= product.
; Only caller: Voice_Release_Type4_BranchA (0x02BD6B). Touches no hardware other than the
; software tick at 0x001040.
Voice_Slot_ApplyPortamentoDelta:
	dec 8, xsp
	push xiz
	ld (xsp + 8), xwa
	ld xwa, (xsp + 8)
	ld xiz, (xwa + 35)
	ld	a, (xiz+266)
	ld c, a
	exts bc
	ld xwa, (xsp + 8)
	add (xwa + 13), bc
	bit	7, (xiz+280)
	jr z, Voice_Slot_ApplyPortamentoDelta_BranchA
	ei 6
	ld xwa, (4160:16)
	ld	(xiz+276), xwa
	ei 0
	jrl Voice_Slot_ApplyPortamentoDelta_Exit

; part+0x118 bit 7 clear: compute elapsed = tick(0x001040) - part+0x114 under mask level 6.
Voice_Slot_ApplyPortamentoDelta_BranchA:
	ei 6
	ld xwa, (4160:16)
	ld (xsp + 4), xwa
	ld XWA, (xiz + 0x0114)
	sub (xsp + 4), xwa
	ei 0
	ld xwa, (xsp + 4)
	cp xwa, 0x7FFF
	jr ule, Voice_Slot_ApplyPortamentoDelta_BranchB
	ld xwa, 0x7FFF
	ld (xsp + 4), xwa

; elapsed clamped to 0x7FFF; now build the rate from part+0x10B and (slot+0x17)->+0x29.
Voice_Slot_ApplyPortamentoDelta_BranchB:
	ld	a, (xiz+267)
	ld c, a
	exts bc
	ld xwa, (xsp + 8)
	ld xwa, (xwa + 23)
	ld a, (xwa + 41)
	ld e, a
	extz de
	add de, bc
	ldw wa, 0x64
	cp de, 0x64
	jr gt, Voice_Slot_ApplyPortamentoDelta_BranchC
	ld wa, de

; Rate exceeded 0x64: use 0x64.
Voice_Slot_ApplyPortamentoDelta_BranchC:
	ld de, wa
	ld wa, 0:i3
	cp de, 0:i3
	jr lt, Voice_Slot_ApplyPortamentoDelta_BranchD
	ld wa, de

; Rate floored at 0; look the coefficient up in the u16 table at 0x00F7E6 and multiply.
Voice_Slot_ApplyPortamentoDelta_BranchD:
	ld de, wa
	add wa, wa
	lda xbc, (Voice_Portamento_Rate_Table:24)
	ld	wa, (xbc+wa)
	extz xwa
	ld xbc, (xsp + 4)
	call Math_Multiply32
	ld xwa, xhl
	srl xwa, 10
	cp xwa, 0xFFF
	jr ule, Voice_Slot_ApplyPortamentoDelta_BranchE
	ld xwa, (xsp + 8)
	ldw (xwa + 13), 0xC000
	jr Voice_Slot_ApplyPortamentoDelta_Exit

; Normal case: subtract the scaled product from the slot's pitch accumulator (+0x0D).
Voice_Slot_ApplyPortamentoDelta_BranchE:
	ld bc, wa
	ld xwa, (xsp + 8)
	sub (xwa + 13), bc

; Restore XIZ and return.
Voice_Slot_ApplyPortamentoDelta_Exit:
	pop xiz
	inc 8, xsp
	ret

; Adds a 3-bit pseudo-random value to a 16-bit word.
; IN : XWA = address of the word.  The randomness is the low 3 bits of the free-running
; 32-bit counter at 0x001040, sampled with interrupts masked to level 6, so the value is
; (tick & 7) -- a cheap dither, not a real PRNG. (XWA) += that.
; Only caller: Voice_Init_Type1 (0x02C3F0), where XWA = 0x0451CE, i.e. the WAVEFORM/
; multisample word of the tone-generator parameter staging block. Touches no hardware.
WaveSel_AddRandomEntryOffset:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xwa
	ei 6
	ld xwa, (4160:16)
	ld iz, wa
	and iz, 0x7
	ei 0
	ld xwa, (xsp + 2)
	add (xwa), iz
	popw iz
	inc 4, xsp
	ret

; Builds the final and base pitch words for one STAGING voice-slot record.
; IN : XWA = staging slot record (0x002942 + i*0x47).
; Reads XBC = slot+0x23 (part record), and the two parameter-block pointers slot+0x17 and
; slot+0x1F. Accumulates in IZ:
;   IZ  = ((slot+0x05 & 0x7F) << 8) + 0x80        key, in 1/256-semitone units
;   IZ += part+0x112                              mix-weight word (INDEX-derived)
;   IZ += u16 at 0x041349                         a GLOBAL (not part-indexed) master tune
;   IZ += (i8)(part+0x16) << 8
;   IZ += (i8)(part+0x6D) << 8
;   slot+0x08 = Pitch_Saturate_15bit(IZ)                the BASE pitch
;   IZ -= ((slot+0x1F)->+0x0B << 8) + 0x80
;   IZ += u16 (slot+0x1F)->+0x0C
;   IZ += (i8)(slot+0x17)->+0x03 << 8
;   IZ += (i8)(slot+0x17)->+0x04
;   slot+0x06 = Pitch_Fold_Octaves_Into_Range(WA = IZ, BC = (slot+0x1F)->+0x09,
;                                        DE = (slot+0x1F)->+0x0A)   the FINAL pitch
; slot+0x06 is exactly the word that Voice_Slot_CalcAmpNibble and
; Voice_Slot_FindOctaveOffset later read back as the sounding key.
; Only caller: Voice_Allocate_1of4 (0x02C5A0). Touches no hardware.
Voice_Slot_ComputePitch:	.include "includes/generated/cc900/Voice_Slot_ComputePitch.s"	; C: cc900/voice_ctrlchange_p_17b.c

; Signed three-way clamp. IN: WA = value, DE = lower bound, BC = upper bound.
; OUT: HL = min(max(WA, DE), BC). Callers: Voice_Build_Partial_Descriptor_BranchB/BranchC and
; Voice_Allocate_Type2 -- all three use it to keep a transposed key inside 0..0x7F.
Voice_Pitch_ClampRange:	.include "includes/generated/cc900/Voice_Pitch_ClampRange.s"	; C: cc900/voice_ctrlchange.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Pitch_ClampRange_Hi, Voice_Pitch_ClampRange + 8
	.set	Voice_Pitch_ClampRange_Lo, Voice_Pitch_ClampRange + 14

; RELEASES one physical tone-generator voice.  (Was ToneGen_WriteNoteKey; it writes no note
; key -- the second register/data pair is the 0x7E00 "free this voice" word.  The curated
; reference already called it ToneGen_SilenceChannel and that name is now used everywhere.)
; IN : A = physical TG slot (0..0x3F). No outputs. THIS IS THE ONLY VOICE-FREEING PATH IN
; THE REGION and it is the routine that emits the 0x7E00 "free a voice" word documented in
; the sub-CPU memory map.
; Sequence, twice over: clear P6.7 (SFR 0x18 bit 7); write the register number to 0x100000;
; `nop`; set P6.7; write the data word to 0x100002; three `nop`s reached through a
; `jr T,<next>`. First pair: register 0xC0 + slot, data 0x0000. Second pair: register
; 0x0000 + slot, data 0x7E00 (= FREE).
; Only caller: Voice_Manager_PollBank_SlotLoop (0x022C58 region), which XORs the freshly read
; active-voice bitmap from 0x100000 against its previous copy and calls this for every slot
; whose bit just went 1 -> 0.
ToneGen_SilenceChannel:	.include "includes/generated/cc900/ToneGen_SilenceChannel.s"	; C: cc900/voice_ctrlchange_u_18a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_SilenceChannel_NopCont1, ToneGen_SilenceChannel + 32
	.set	ToneGen_SilenceChannel_NopCont2, ToneGen_SilenceChannel + 60

; NAME LEFT AS-IS (the reference file's existing non-LABEL_ name). The LLVM build calls this
; address Voice_Build_Register_Set. Documentation only; nothing is renamed.
; Full parameter rebuild + emit for one physical TG slot, "type 4" (the 4-layer voice path).
; IN : A = physical TG slot. XIZ := 0x04308E + A*0x47 (the LIVE slot record).
; Calls, in order and each with XWA = XIZ: WaveSel_StageB_Build_Reg040,
; Pitch_Apply_Partial_Detune, Pitch_Emit_Reg400,
; Voice_Level_ComputeTriplet, TVF_Build_Dispatch, TVF_Emit_Registers,
; Voice_StereoLevel_Compute, Voice_PortaLevel_Compute, ExtVoice_Build_SlotRegisters,
; Voice_SubVoice_ComputeAndTrigger, Voice2_UpdatePitch, Level_Build_Reg0C0,
; Voice_Build_GateCommand, Voice_Calc_LevelPair_PatchAtk, Voice_WriteChPanShift (BC = 0),
; Voice_ComputePitch, Voice_ApplyPortamento. Every one of those fills part of the 68-byte
; staging block at 0x0451CC (see the region-4 notes). Finally
; ToneGen_WriteVoiceParams(WA = slot, XBC = 0x0451CC) walks that block and emits the whole
; register set to IC303. Only caller: Voice_SetVelocity_Type0_BranchA (0x02C9??).
Voice_Build_Register_Set:	.include "includes/generated/cc900/Voice_Build_Register_Set.s"	; C: cc900/voice_ctrlchange.c

; Builds ONE staging voice-slot record (0x002942 + layer*0x47) for a note-on and marks the
; layer as "requested" in the caller's note request record.
; Arguments (mixed registers + stack, `retd 0x0A`): XWA = note request record,
; C = part index, DE = layer-enable bitmask to test, and stacked words: +0x1E = a packed
; buffer selector, +0x20 = request priority, +0x22 = key, +0x24 = a sub-index,
; +0x26 = layer index (0..3).
; Body: ToneDB_Find_ToneRecord + ToneDB_Find_SubToneRecord resolve the tone parameter
; block; if (block+0x0D & DE) == 0 the layer is REFUSED (ExitA). Otherwise
; WaveSel_StageA1_FromToneSlot + Velocity_Select_Split_Zone_Alt + WaveSel_StageA2_FromVelZone derive
; the level, and the staging record is filled: +0x01 = velocityindex<<6 | 0x12,
; +0x03 = layer, +0x04 = part, +0x05 = key | 0x80, +0x0C = priority,
; +0x23 = &part record, +0x27 = &part layer sub-block (part + 0x6E + layer*0x25),
; +0x13/+0x17/+0x1B/+0x1F = the four resolved parameter-block pointers. Then
; Voice_Pitch_CopyBase. Finally requestrec+0x02+layer = 0x80 | selector.
; Called only from Voice_Build_Partial_Descriptor. Touches no hardware.
Voice_Allocate_Typed:
	lda xsp, (xsp - 24)
	pushw_erp 0xFA
	ld (xsp + 18), de
	ld (xsp + 20), c
	ld (xsp + 22), xwa
	ld a, (xsp + 38)
	extz wa
	muls wa, 0x47
	lda xbc, (10562:16)
	exts xwa
	add xwa, xbc
	ld (xsp + 2), xwa
	ld wa, (xsp + 30)
	ld e, a
	extz de
	ld wa, (xsp + 30)
	srl wa, 8
	ld c, a
	extz bc
	ld wa, de
	call ToneDB_Find_ToneRecord
	ld a, (xsp + 36)
	ld c, a
	extz bc
	ld a, (xsp + 20)
	ld e, a
	extz de
	ld xwa, xhl
	call ToneDB_Find_SubToneRecord
	ld (xsp + 6), xhl
	ld xwa, (xsp + 6)
	ld a, (xwa + 13)
	extz wa
	and wa, (xsp + 18)
	jrl z, Voice_Allocate_Typed_ExitA
	ld a, (xsp + 38)
	extz wa
	muls wa, 0x15
	ld bc, wa
	add bc, 0x10
	ld xwa, (xsp + 6)
	lda	xwa, (xwa+bc)
	ld (xsp + 10), xwa
	ld a, (xsp + 38)
	ld c, a
	extz bc
	ld a, (xsp + 36)
	ld e, a
	extz de
	ld a, (xsp + 20)
	extz wa
	pushw wa
	ld wa, bc
	ld xbc, (xsp + 12)
	call WaveSel_StageA1_FromToneSlot
	ld (xsp + 14), xhl
	ld a, (xsp + 34)
	extz wa
	ld xbc, (xsp + 14)
	call Velocity_Select_Split_Zone_Alt
	ldfr_berp L, 0xFB
	ldto_berp A, 0xFB
	extz wa
	ld xbc, (xsp + 14)
	call WaveSel_StageA2_FromVelZone
	ldto_berp A, 0xFB
	sll a, 6
	or a, 0x12
	ld c, a
	extz bc
	ld xwa, (xsp + 2)
	ld (xwa + 1), bc
	ld xbc, (xsp + 2)
	ld a, (xsp + 38)
	ld (xbc + 3), a
	ld xbc, (xsp + 2)
	ld a, (xsp + 20)
	ld (xbc + 4), a
	ld c, (xsp + 36)
	set 7, c
	ld xwa, (xsp + 2)
	ld (xwa + 5), c
	ld xbc, (xsp + 2)
	ld a, (xsp + 34)
	ld (xbc + 12), a
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	lda	xbc, (xbc+wa)
	ld xwa, (xsp + 2)
	ld (xwa + 35), xbc
	ld a, (xsp + 38)
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, 0x6E
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	lda	xbc, (xwa+de)
	ld xwa, (xsp + 2)
	ld (xwa + 39), xbc
	ld xwa, (xsp + 2)
	ld xbc, (xsp + 6)
	ld (xwa + 19), xbc
	ld xwa, (xsp + 2)
	ld xbc, (xsp + 10)
	ld (xwa + 23), xbc
	ld xwa, (xsp + 2)
	ld xbc, (xsp + 14)
	ld (xwa + 27), xbc
	ld xwa, (xsp + 2)
	ld (xwa + 31), xhl
	ld xwa, (xsp + 2)
	call Voice_Pitch_CopyBase
	ld a, (xsp + 38)
	extz wa
	ld bc, wa
	inc 2, bc
	ld e, (xsp + 32)
	set 7, e
	ld xwa, (xsp + 22)
	ld	(xwa+bc), e
	jr Voice_Allocate_Typed_ExitB

; Refusal path: requestrec+0x02+layer = 0 (this layer will not be allocated).
Voice_Allocate_Typed_ExitA:
	ld a, (xsp + 38)
	extz wa
	ld bc, wa
	inc 2, bc
	ld xwa, (xsp + 22)
	ld	(xwa+bc), 0x00

; Common tail: requestrec+0x06+layer = 0, unwind and `retd 0x0A`.
Voice_Allocate_Typed_ExitB:
	ld a, (xsp + 38)
	extz wa
	ld bc, wa
	inc 6, bc
	ld xwa, (xsp + 22)
	ld	(xwa+bc), 0x00
	popw_erp 0xFA
	lda xsp, (xsp + 24)
	retd 0xA

; NAME LEFT AS-IS (the reference file's existing non-LABEL_ name). The LLVM build calls this
; address Voice_Build_Partial_Descriptor. Documentation only; nothing is renamed.
; The per-layer note-on worker. Arguments: XWA = note request record, C = part index,
; DE = the layer bit to test in the part's layer-enable mask, plus stacked words
; +0x1E = selector, +0x20 = velocity, +0x22 = key, +0x24 = source layer, +0x26 = target
; layer index. `retd 0x0A`.
; FIRST TEST (0x02B72A): if (part+0x02 & DE) == 0 the routine jumps straight to ExitA, which
; writes requestrec+0x02+layer = 0 and requestrec+0x06+layer = 0 and returns. No error is
; reported anywhere. This is the primary "note silently does nothing" gate.
; If the key >= 0x78 and bit 1 of the layer parameter block is set, the work is delegated to
; Voice_Allocate_Typed with the key rebased by -0x78; if the key >= 0x78 and that bit is
; clear the layer is dropped (BranchA). For keys < 0x78 the staging record at
; 0x002942 + layer*0x47 is filled inline: +0x01 = velidx<<6 with bit 2 set, +0x03 = layer,
; +0x04 = part, +0x05 = key | 0x80, +0x0C = velocity (optionally transposed, see BranchB/C),
; +0x23 = &part record, +0x13 = the u32 at part+0x06 (tone record), +0x17/+0x1B/+0x1F/+0x27
; = the resolved parameter pointers, then Voice_Pitch_Compute. Algorithm words +0x2F and
; +0x31 come from Algo_SubTable_Bit15Dispatch and Voice_SecondaryParam_Fetch, and +0x35/
; +0x36/+0x38/+0x3A are looked up in the ROM tables at 0x012038, 0x012057 and 0x012095 using
; bytes +0x5E..+0x61 of the tone record.
; Last: requestrec+0x02+layer = 0x80 | selector, and requestrec+0x06+layer is set to 0x80
; unless (+0x2F == 0 && +0x31 == 0xFF && bit 15 of (layerblock+0x18) is clear), in which
; case it is 0. Touches no hardware.
Voice_Build_Partial_Descriptor:
	lda xsp, (xsp - 22)
	push xiz
	ld (xsp + 20), c
	ld (xsp + 22), xwa
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PresentWord:24)
	ld	wa, (xbc+wa)
	and wa, de
	jrl z, Voice_Build_Partial_Descriptor_ExitA
	ld a, (xsp + 36)
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, 0x6E
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	lda	xwa, (xwa+de)
	ld xwa, (xwa + 4)
	ld (xsp + 8), xwa
	ld a, (xsp + 32)
	extz wa
	ld xbc, (xsp + 8)
	call Velocity_Select_Split_Zone
	ld a, (xsp + 36)
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, 0x6E
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	ld	xwa, (xwa+de)
	ld (xsp + 4), xwa
	ld a, l
	extz wa
	ld bc, wa
	sla bc, 2
	ld a, (xsp + 36)
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, bc
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	lda	xwa, (xwa+de)
	ld xwa, (xwa + 118)
	ld (xsp + 12), xwa
	ld a, (xsp + 38)
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, 0x6E
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	lda	xwa, (xwa+de)
	ld (xsp + 16), xwa
	cp (xsp + 34), 0x78
	jr c, Voice_Build_Partial_Descriptor_BranchB
	ld xwa, (xsp + 12)
	bitm 1, (xwa)
	jr z, Voice_Build_Partial_Descriptor_BranchA
	ld c, (xsp + 34)
	sub c, 0x78
	ld xwa, (xsp + 12)
	add c, (xwa + 11)
	ld e, c
	ld a, (xsp + 20)
	ld c, a
	extz bc
	pushw 0x0
	ld a, e
	extz wa
	pushw wa
	ld a, (xsp + 36)
	extz wa
	pushw wa
	pushw 0x3
	ld xwa, (xsp + 20)
	pushm (xwa + 12)
	ld xwa, (xsp + 32)
	ld de, 1:i3
	calr Voice_Allocate_Typed
	jrl Voice_Build_Partial_Descriptor_ExitB

; Key >= 0x78 but the layer block's bit 1 is clear: drop the layer (both request bytes = 0).
Voice_Build_Partial_Descriptor_BranchA:
	ld a, (xsp + 38)
	extz wa
	ld bc, wa
	inc 2, bc
	ld xwa, (xsp + 22)
	ld	(xwa+bc), 0x00
	ld a, (xsp + 38)
	extz wa
	ld bc, wa
	inc 6, bc
	ld xwa, (xsp + 22)
	ld	(xwa+bc), 0x00
	jrl Voice_Build_Partial_Descriptor_ExitB

; Normal key range: start filling the staging record at 0x002942 + layer*0x47.
Voice_Build_Partial_Descriptor_BranchB:
	ld a, (xsp + 38)
	extz wa
	muls wa, 0x47
	lda xbc, (10562:16)
	lda	xiz, (xbc+wa)
	sll l, 6
	set 2, l
	ld a, l
	extz wa
	ld (xiz + 1), wa
	ld a, (xsp + 38)
	ld (xiz + 3), a
	ld a, (xsp + 20)
	ld (xiz + 4), a
	ld a, (xsp + 34)
	set 7, a
	ld (xiz + 5), a
	ld wa, (Voice_GlobalFlags:24)
	bit 1, wa
	jr z, Voice_Build_Partial_Descriptor_BranchD
	cp (xsp + 20), 0x0
	jr nz, Voice_Build_Partial_Descriptor_BranchC
	ld a, (xsp + 32)
	add a, 0x28
	extz wa
	ldw bc, 0x7F
	ld de, 0:i3
	calr Voice_Pitch_ClampRange
	ld (xsp + 32), l
	jr Voice_Build_Partial_Descriptor_BranchD

; Global 0x041343 bit 0 set and part == 1: velocity += 0x0C, clamped to 0..0x7F.
Voice_Build_Partial_Descriptor_BranchC:
	cp (xsp + 20), 0x1
	jr nz, Voice_Build_Partial_Descriptor_BranchD
	ld a, (xsp + 32)
	add a, 0xC
	extz wa
	ldw bc, 0x7F
	ld de, 0:i3
	calr Voice_Pitch_ClampRange
	ld (xsp + 32), l

; Store the (possibly transposed) velocity to +0x0C and wire up all the record pointers.
Voice_Build_Partial_Descriptor_BranchD:
	ld a, (xsp + 32)
	ld (xiz + 12), a
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	ld (xiz + 35), xwa
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld (xiz + 19), xwa
	ld xwa, (xsp + 4)
	ld (xiz + 23), xwa
	ld xwa, (xsp + 16)
	ld (xiz + 39), xwa
	ld xwa, (xsp + 8)
	ld (xiz + 27), xwa
	ld xwa, (xsp + 12)
	ld (xiz + 31), xwa
	ld xwa, xiz
	call Voice_Pitch_Compute
	ld a, (xsp + 20)
	ld e, a
	extz de
	ld a, (xsp + 38)
	ld c, a
	extz bc
	ld wa, de
	call Algo_SubTable_Bit15Dispatch
	ld a, l
	extz wa
	ld (xiz + 47), wa
	ld a, (xsp + 20)
	extz wa
	call Voice_SecondaryParam_Fetch
	ld a, l
	extz wa
	ld (xiz + 49), wa
	ld xwa, (xiz + 19)
	ld a, (xwa + 94)
	extz wa
	lda xbc, (Voice_SecondaryParam_Curve:24)
	ld	a, (xbc+wa)
	ld (xiz + 53), a
	ld xwa, (xiz + 19)
	ld a, (xwa + 95)
	extz wa
	add wa, wa
	lda xbc, (Voice_SecondaryParam_WordCurveA:24)
	ld	wa, (xbc+wa)
	ld (xiz + 54), wa
	ld xwa, (xiz + 19)
	ld a, (xwa + 96)
	extz wa
	add wa, wa
	lda xbc, (Voice_SecondaryParam_WordCurveB:24)
	ld	wa, (xbc+wa)
	ld (xiz + 58), wa
	ld xwa, (xiz + 19)
	ld a, (xwa + 97)
	extz wa
	add wa, wa
	lda xbc, (Voice_SecondaryParam_WordCurveA:24)
	ld	wa, (xbc+wa)
	ld (xiz + 56), wa
	ld a, (xsp + 38)
	extz wa
	ld bc, wa
	inc 2, bc
	ld e, (xsp + 30)
	set 7, e
	ld xwa, (xsp + 22)
	ld	(xwa+bc), e
	cpw (xiz + 47), 0x0
	jr nz, Voice_Build_Partial_Descriptor_BranchE
	cpw (xiz + 49), 0xFF
	jr nz, Voice_Build_Partial_Descriptor_BranchE
	ld xwa, (xsp + 16)
	ld wa, (xwa + 24)
	extz xwa
	bit 15, wa
	jr z, Voice_Build_Partial_Descriptor_BranchF

; "Layer has real content": requestrec+0x06+layer = 0x80.
Voice_Build_Partial_Descriptor_BranchE:
	ld a, (xsp + 38)
	extz wa
	ld bc, wa
	inc 6, bc
	ld xwa, (xsp + 22)
	ld	(xwa+bc), 0x80
	jr Voice_Build_Partial_Descriptor_ExitB

; "Layer is a null algorithm": requestrec+0x06+layer = 0.
Voice_Build_Partial_Descriptor_BranchF:
	ld a, (xsp + 38)
	extz wa
	ld bc, wa
	inc 6, bc
	ld xwa, (xsp + 22)
	ld	(xwa+bc), 0x00
	jr Voice_Build_Partial_Descriptor_ExitB

; Layer-enable mask test failed: zero BOTH request bytes for this layer and leave.
Voice_Build_Partial_Descriptor_ExitA:
	ld a, (xsp + 38)
	extz wa
	ld bc, wa
	inc 2, bc
	ld xwa, (xsp + 22)
	ld	(xwa+bc), 0x00
	ld a, (xsp + 38)
	extz wa
	ld bc, wa
	inc 6, bc
	ld xwa, (xsp + 22)
	ld	(xwa+bc), 0x00

; Common tail, `retd 0x0A`.
Voice_Build_Partial_Descriptor_ExitB:
	pop xiz
	lda xsp, (xsp + 22)
	retd 0xA

; NAME LEFT AS-IS (the reference file's existing non-LABEL_ name, which describes the code
; well). The LLVM build calls this address Voice_Build_Four_Partials. Documentation only.
; The four-layer note-on body. IN: XWA = note request record, C = part index, E = key,
; one stacked word = velocity. `retd 0x02`.
; requestrec+0x00 = key | part<<8 | 0x80. Then Voice_Build_Partial_Descriptor is called up to five times
; with different (layer bit, selector, source layer, target layer) tuples chosen by bits
; 0x0E and 0x0F of the part's layer-enable mask -- that is the 2x2 variant selector.
; Then Voice_Allocate_Nodes(requestrec) performs the actual physical allocation and writes the
; assigned slot numbers into requestrec+0x0A+i.
; COMMIT LOOP (SlotLoop, i = 0..3): if requestrec+0x0A+i >= 0x40 the layer is skipped
; entirely -- no record is committed, no register is written, and nothing is reported. Else
; the 0x47-byte staging record 0x002942 + i*0x47 is block-copied
; (`ld bc,0x23 / ldirw / ldi`) onto the live record 0x04308E + slot*0x47.
; For keys < 0x78 (AltSlotPath) three extra fixups run afterwards: live+0x00 = slot,
; live+0x2F = 0 if staging+0x2F == 0 else (staging+0x2F | (staging+0x2F<<8) | 0x8000), and
; live+0x31 = 0x00FF if staging+0x31 == 0xFF else (staging+0x31 | 0xC000).
; Finally bit 8 of live+0x01 is set or cleared depending on bit 15 of the word at
; ((live+0x27)->+0x18). Only caller: Voice_SetVelocity (0x02C8E4).
Voice_Build_Four_Partials:
	lda xsp, (xsp - 10)
	push xiz
	ld (xsp + 6), e
	ld (xsp + 8), c
	ld (xsp + 10), xwa
	ld a, (xsp + 6)
	ld c, a
	extz bc
	ld a, (xsp + 8)
	extz wa
	sll wa, 8
	or wa, bc
	ld bc, wa
	set 7, bc
	ld xwa, (xsp + 10)
	ld (xwa), bc
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PresentWord:24)
	ld	wa, (xbc+wa)
	bit 14, wa
	jr z, Voice_Build_Four_Partials_BranchA
	ld a, (xsp + 8)
	ld c, a
	extz bc
	pushw 0x0
	pushw 0x1
	ld a, (xsp + 10)
	extz wa
	pushw wa
	ld a, (xsp + 24)
	extz wa
	pushw wa
	pushw 0x0
	ld xwa, (xsp + 20)
	ld de, 1:i3
	calr Voice_Build_Partial_Descriptor
	jr Voice_Build_Four_Partials_BranchB

; Mask bit 0x0E clear: first Voice_Build_Partial_Descriptor call with selector 0 instead of 1.
Voice_Build_Four_Partials_BranchA:
	ld a, (xsp + 8)
	ld c, a
	extz bc
	pushw 0x0
	pushw 0x0
	ld a, (xsp + 10)
	extz wa
	pushw wa
	ld a, (xsp + 24)
	extz wa
	pushw wa
	pushw 0x0
	ld xwa, (xsp + 20)
	ld de, 1:i3
	calr Voice_Build_Partial_Descriptor

; Re-read the layer-enable mask and branch on bit 0x0F for the second layer pair.
Voice_Build_Four_Partials_BranchB:
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PresentWord:24)
	ld	wa, (xbc+wa)
	extz xwa
	bit 15, wa
	jr z, Voice_Build_Four_Partials_BranchC
	ld a, (xsp + 8)
	ld c, a
	extz bc
	pushw 0x1
	pushw 0x0
	ld a, (xsp + 10)
	extz wa
	pushw wa
	ld a, (xsp + 24)
	extz wa
	pushw wa
	pushw 0x1
	ld xwa, (xsp + 20)
	ld de, 2:i3
	calr Voice_Build_Partial_Descriptor
	jr Voice_Build_Four_Partials_BranchD

; Mask bit 0x0F clear variant of the second Voice_Build_Partial_Descriptor call.
Voice_Build_Four_Partials_BranchC:
	ld a, (xsp + 8)
	ld c, a
	extz bc
	pushw 0x1
	pushw 0x1
	ld a, (xsp + 10)
	extz wa
	pushw wa
	ld a, (xsp + 24)
	extz wa
	pushw wa
	pushw 0x1
	ld xwa, (xsp + 20)
	ld de, 2:i3
	calr Voice_Build_Partial_Descriptor

; Layers 2 and 3 (mask bits 4 and 8), then Voice_Allocate_Nodes and the commit loop.
Voice_Build_Four_Partials_BranchD:
	ld a, (xsp + 8)
	ld c, a
	extz bc
	pushw 0x2
	pushw 0x2
	ld a, (xsp + 10)
	extz wa
	pushw wa
	ld a, (xsp + 24)
	extz wa
	pushw wa
	pushw 0x5
	ld xwa, (xsp + 20)
	ld de, 4:i3
	calr Voice_Build_Partial_Descriptor
	ld a, (xsp + 8)
	ld c, a
	extz bc
	pushw 0x3
	pushw 0x3
	ld a, (xsp + 10)
	extz wa
	pushw wa
	ld a, (xsp + 24)
	extz wa
	pushw wa
	pushw 0x3
	ld xwa, (xsp + 20)
	ldw de, 0x8
	calr Voice_Build_Partial_Descriptor
	ld xwa, (xsp + 10)
	call Voice_Allocate_Nodes
	ld (xsp + 4), 0x0
	cp (xsp + 4), 0x4
	jrl nc, Voice_Build_Four_Partials_Exit

; Commit loop head: the `cp (requestrec+0x0A+i),0x40 / jr nc` polyphony gate.
Voice_Build_Four_Partials_SlotLoop:
	ld a, (xsp + 4)
	extz wa
	ld bc, wa
	add bc, 0xA
	ld xwa, (xsp + 10)
	cp	(xwa+bc), 0x40
	jrl nc, Voice_Build_Four_Partials_BranchK
	ld a, (xsp + 4)
	extz wa
	ld bc, wa
	add bc, 0xA
	ld xwa, (xsp + 10)
	ld	e, (xwa+bc)
	cp (xsp + 6), 0x78
	jr c, Voice_Build_Four_Partials_AltSlotPath
	ld a, e
	extz wa
	muls wa, 0x47
	ld hl, wa
	lda xiz, (Payload_Bss_Start+0x4218:24)
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x47
	lda xbc, (10562:16)
	lda	xiy, (xbc+wa)
	lda	xix, (xiz+hl)
	ldw bc, 0x23
	ldirw
	ldi85
	jrl Voice_Build_Four_Partials_BranchI

; Key < 0x78 commit: same block copy plus the live+0x00 / +0x2F / +0x31 fixups.
Voice_Build_Four_Partials_AltSlotPath:
	ld a, e
	extz wa
	muls wa, 0x47
	ld hl, wa
	lda xiz, (Payload_Bss_Start+0x4218:24)
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x47
	lda xbc, (10562:16)
	lda	xiy, (xbc+wa)
	lda	xix, (xiz+hl)
	ldw bc, 0x23
	ldirw
	ldi85
	ld a, e
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4218:24)
	ld	(xbc+wa), e
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x47
	lda xbc, (10609:16)
	ld	hl, (xbc+wa)
	cp hl, 0:i3
	jr z, Voice_Build_Four_Partials_BranchE
	ld wa, hl
	sll wa, 8
	extz xwa
	set 15, wa
	or hl, wa
	jr Voice_Build_Four_Partials_BranchF

; staging+0x2F was zero: live+0x2F = 0.
Voice_Build_Four_Partials_BranchE:
	ld hl, 0:i3

; Store the packed +0x2F word into the live record (0x0430BD + slot*0x47).
Voice_Build_Four_Partials_BranchF:
	ld a, e
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4247:24)
	ld	(xbc+wa), hl
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x47
	lda xbc, (10611:16)
	ld	hl, (xbc+wa)
	cp hl, 0xFF
	jr z, Voice_Build_Four_Partials_BranchG
	or hl, 0xC000
	jr Voice_Build_Four_Partials_BranchH

; staging+0x31 == 0xFF: live+0x31 = 0x00FF (the "no secondary parameter" sentinel).
Voice_Build_Four_Partials_BranchG:
	ldw hl, 0xFF

; Store the +0x31 word into the live record (0x0430BF + slot*0x47).
Voice_Build_Four_Partials_BranchH:
	ld a, e
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4249:24)
	ld	(xbc+wa), hl

; Read bit 15 of ((live+0x27)->+0x18) to decide the +0x01 bit-8 flag.
Voice_Build_Four_Partials_BranchI:
	ld a, e
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x423f:24)
	ld	xwa, (xbc+wa)
	ld wa, (xwa + 24)
	extz xwa
	bit 15, wa
	jr z, Voice_Build_Four_Partials_BranchJ
	ld a, e
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4219:24)
	orw	(xbc+wa), 0x0100
	jr Voice_Build_Four_Partials_BranchK

; Clear bit 8 of live+0x01 (0x04308F + slot*0x47 masked with 0xFEFF).
Voice_Build_Four_Partials_BranchJ:
	ld a, e
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4219:24)
	andw	(xbc+wa), 0xfeff

; i++, loop while i < 4. Also the landing point of the "slot >= 0x40" skip.
Voice_Build_Four_Partials_BranchK:
	incm8 1, (xsp + 4)
	cp (xsp + 4), 0x4
	jrl c, Voice_Build_Four_Partials_SlotLoop

; Unwind and `retd 0x02`.
Voice_Build_Four_Partials_Exit:
	pop xiz
	lda xsp, (xsp + 10)
	retd 0x2

; Per-tick parameter refresh for one already-sounding type-4 voice (the release/decay
; update, not the note-off itself).
; IN : A = physical TG slot. XIZ := 0x04308E + A*0x47.
; Runs WaveSel_StageB_Build_Reg040_Footage first (that is what distinguishes it from Voice_Build_Register_Set)
; then the same chain of parameter builders down to Voice_Build_GateCommand. It then
; splits on the record's layer index (+0x03): layers 0..2 take Voice_Calc_LevelPair_Full +
; Voice_ComputePitch + Voice_Slot_LoadPitchOffset_A + Voice_ApplyPortamento; layer 3 takes
; Voice_Calc_LevelPair_Mono + Voice_ComputePitch + Voice_Slot_ApplyPortamentoDelta +
; Voice_ApplyPortamento. Ends with ToneGen_WriteVoiceParams(slot, 0x0451CC), which is the
; only hardware contact. Only caller: Voice_SetVelocity_Type40_NopCont2.
Voice_Release_Type4:	.include "includes/generated/cc900/Voice_Release_Type4.s"	; C: cc900/voice_ctrlchange_callnames2.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Release_Type4_BranchA, Voice_Release_Type4 + 135
	.set	Voice_Release_Type4_BranchB, Voice_Release_Type4 + 159

; Single-layer note-on worker used by the type-2 path -- the leaner sibling of
; Voice_Build_Partial_Descriptor. IN: XWA = note request record, C = part index, DE = layer bit to test,
; plus stacked +0x10 selector, +0x12 velocity (bit 7 = an extra flag), +0x14 key,
; +0x16 target layer index. `retd 0x08`.
; Same first gate: if (part+0x02 & DE) == 0 it jumps to ExitA and zeroes both request bytes.
; Otherwise it fills 0x002942 + layer*0x47 with +0x01 = 0x0008 (| 0x0800 when bit 7 of the
; velocity argument is set), +0x03 = layer, +0x04 = part, +0x05 = key | 0x80,
; +0x0C = velocity & 0x7F, +0x23 = &part record, +0x13 = tone record pointer,
; +0x17/+0x1B/+0x1F/+0x27 = the layer sub-block pointers, calls Voice_Pitch_Compute, and
; then hard-codes the algorithm fields to the "no algorithm" values: +0x2F = 0,
; +0x31 = 0x00FF, +0x35 = 0, +0x36 = +0x38 = +0x3A = 0.
; Finishes with requestrec+0x02+layer = 0x80 | selector and requestrec+0x06+layer = 0.
; Callers: Voice_NoteOn_Type2_BranchB / _BranchC. Touches no hardware.
Voice_NoteOn_Type3:
	dec 8, xsp
	push xiz
	ld (xsp + 8), xwa
	ld a, c
	extz wa
	muls wa, 0x11F
	lda xhl, (Part_PresentWord:24)
	ld	wa, (xhl+wa)
	and wa, de
	jrl z, Voice_NoteOn_Type3_ExitA
	ld a, (xsp + 22)
	extz wa
	muls wa, 0x25
	ld hl, wa
	add hl, 0x6E
	ld a, c
	extz wa
	muls wa, 0x11F
	lda xde, (Part_Record_Base:24)
	exts xwa
	add xwa, xde
	lda	xwa, (xwa+hl)
	ld xwa, (xwa + 4)
	ld (xsp + 4), xwa
	ld a, (xsp + 22)
	extz wa
	muls wa, 0x25
	ld hl, wa
	add hl, 0x6E
	ld a, c
	extz wa
	muls wa, 0x11F
	lda xde, (Part_Record_Base:24)
	exts xwa
	add xwa, xde
	ld	xde, (xwa+hl)
	ld a, (xsp + 22)
	extz wa
	muls wa, 0x25
	ld ix, wa
	add ix, 0x6E
	ld a, c
	extz wa
	muls wa, 0x11F
	lda xhl, (Part_Record_Base:24)
	exts xwa
	add xwa, xhl
	lda	xwa, (xwa+ix)
	ld xhl, (xwa + 8)
	ld a, (xsp + 22)
	extz wa
	muls wa, 0x25
	ld iy, wa
	add iy, 0x6E
	ld a, c
	extz wa
	muls wa, 0x11F
	lda xix, (Part_Record_Base:24)
	exts xwa
	add xwa, xix
	lda	xix, (xwa+iy)
	ld a, (xsp + 22)
	extz wa
	muls wa, 0x47
	lda xiy, (10562:16)
	lda	xiz, (xiy+wa)
	ldw (xiz + 1), 0x8
	bitm 7, (xsp + 18)
	jr z, Voice_NoteOn_Type3_BranchA
	ormi16 (xiz + 1), 0x800

; Past the +0x01 flag word; fill the rest of the staging record.
Voice_NoteOn_Type3_BranchA:
	ld a, (xsp + 22)
	ld (xiz + 3), a
	ld (xiz + 4), c
	ld a, (xsp + 20)
	set 7, a
	ld (xiz + 5), a
	ld a, (xsp + 18)
	res 7, a
	ld (xiz + 12), a
	ld a, c
	extz wa
	muls wa, 0x11F
	lda xiy, (Part_Record_Base:24)
	exts xwa
	add xwa, xiy
	ld (xiz + 35), xwa
	ld a, c
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld (xiz + 19), xwa
	ld (xiz + 23), xde
	ld xwa, (xsp + 4)
	ld (xiz + 27), xwa
	ld (xiz + 31), xhl
	ld (xiz + 39), xix
	ld xwa, xiz
	call Voice_Pitch_Compute
	ldw (xiz + 47), 0x0
	ldw (xiz + 49), 0xFF
	ld (xiz + 53), 0x0
	ldw (xiz + 54), 0x0
	ldw (xiz + 58), 0x0
	ldw (xiz + 56), 0x0
	ld a, (xsp + 22)
	extz wa
	ld bc, wa
	inc 2, bc
	ld e, (xsp + 16)
	set 7, e
	ld xwa, (xsp + 8)
	ld	(xwa+bc), e
	jr Voice_NoteOn_Type3_ExitB

; Layer-enable mask test failed: requestrec+0x02+layer = 0.
Voice_NoteOn_Type3_ExitA:
	ld a, (xsp + 22)
	extz wa
	ld bc, wa
	inc 2, bc
	ld xwa, (xsp + 8)
	ld	(xwa+bc), 0x00

; Common tail: requestrec+0x06+layer = 0, `retd 0x08`.
Voice_NoteOn_Type3_ExitB:
	ld a, (xsp + 22)
	extz wa
	ld bc, wa
	inc 6, bc
	ld xwa, (xsp + 8)
	ld	(xwa+bc), 0x00
	pop xiz
	inc 8, xsp
	retd 0x8

; Four-layer note-on built out of four Voice_NoteOn_Type3 calls.
; IN : XWA = note request record, C = part index, E = key, stacked velocity. `retd 0x02`.
; First it mirrors bit 0x0D of the part's layer-enable mask into bit 7 of part+0x118
; (0x041480 + part*0x11F) -- that is the same flag Voice_Slot_ApplyPortamentoDelta reads to
; decide whether to re-stamp the portamento timestamp.
; requestrec+0x00 = key | part<<8 | 0x80. Then four Voice_NoteOn_Type3 calls with layer bits
; 1, 2, 4 and (8 or 0, chosen by bit 7 of the stacked velocity). Voice_Allocate_Nodes follows,
; then the same commit loop as type 4: skip any layer whose requestrec+0x0A+i >= 0x40, else
; block-copy staging[i] -> live[slot] and set live+0x00 = slot.
Voice_NoteOn_Type2:
	lda xsp, (xsp - 10)
	push xiz
	ld (xsp + 6), e
	ld (xsp + 8), c
	ld (xsp + 10), xwa
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PresentWord:24)
	ld	wa, (xbc+wa)
	bit 13, wa
	jr z, Voice_NoteOn_Type2_BranchA
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x260a:24)
	set	7, (xbc+wa)
	jr Voice_NoteOn_Type2_BranchB

; Mask bit 0x0D clear: clear bit 7 of part+0x118.
Voice_NoteOn_Type2_BranchA:
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x260a:24)
	res	7, (xbc+wa)

; Build the request word and issue the first three Voice_NoteOn_Type3 calls.
Voice_NoteOn_Type2_BranchB:
	ld a, (xsp + 6)
	ld c, a
	extz bc
	ld a, (xsp + 8)
	extz wa
	sll wa, 8
	or wa, bc
	ld bc, wa
	set 7, bc
	ld xwa, (xsp + 10)
	ld (xwa), bc
	ld a, (xsp + 8)
	ld c, a
	extz bc
	pushw 0x0
	ld a, (xsp + 8)
	extz wa
	pushw wa
	ld a, (xsp + 22)
	extz wa
	pushw wa
	pushw 0x0
	ld xwa, (xsp + 18)
	ld de, 1:i3
	calr Voice_NoteOn_Type3
	ld a, (xsp + 8)
	ld c, a
	extz bc
	pushw 0x1
	ld a, (xsp + 8)
	extz wa
	pushw wa
	ld a, (xsp + 22)
	extz wa
	pushw wa
	pushw 0x1
	ld xwa, (xsp + 18)
	ld de, 2:i3
	calr Voice_NoteOn_Type3
	ld a, (xsp + 8)
	ld c, a
	extz bc
	pushw 0x2
	ld a, (xsp + 8)
	extz wa
	pushw wa
	ld a, (xsp + 22)
	extz wa
	pushw wa
	pushw 0x1
	ld xwa, (xsp + 18)
	ld de, 4:i3
	calr Voice_NoteOn_Type3
	bitm 7, (xsp + 18)
	jr z, Voice_NoteOn_Type2_BranchC
	ld a, (xsp + 8)
	ld c, a
	extz bc
	pushw 0x3
	ld a, (xsp + 8)
	extz wa
	pushw wa
	ld a, (xsp + 22)
	extz wa
	pushw wa
	pushw 0x3
	ld xwa, (xsp + 18)
	ld de, 0:i3
	calr Voice_NoteOn_Type3
	jr Voice_NoteOn_Type2_BranchD

; Velocity bit 7 clear: the fourth layer uses mask bit 8 instead of 0.
Voice_NoteOn_Type2_BranchC:
	ld a, (xsp + 8)
	ld c, a
	extz bc
	pushw 0x3
	ld a, (xsp + 8)
	extz wa
	pushw wa
	ld a, (xsp + 22)
	extz wa
	pushw wa
	pushw 0x3
	ld xwa, (xsp + 18)
	ldw de, 0x8
	calr Voice_NoteOn_Type3

; All four layers staged: call Voice_Allocate_Nodes and enter the commit loop.
Voice_NoteOn_Type2_BranchD:
	ld xwa, (xsp + 10)
	call Voice_Allocate_Nodes
	ld e, 0x0:opc
	cp e, 4:i3
	jr nc, Voice_NoteOn_Type2_Exit

; Commit loop head with the `cp (requestrec+0x0A+i),0x40 / jr nc` polyphony gate.
Voice_NoteOn_Type2_BranchE:
	ld a, e
	extz wa
	ld bc, wa
	add bc, 0xA
	ld xwa, (xsp + 10)
	cp	(xwa+bc), 0x40
	jr nc, Voice_NoteOn_Type2_LoopStep
	ld a, e
	extz wa
	ld bc, wa
	add bc, 0xA
	ld xwa, (xsp + 10)
	ld	a, (xwa+bc)
	ld (xsp + 4), a
	extz wa
	muls wa, 0x47
	ld hl, wa
	lda xiz, (Payload_Bss_Start+0x4218:24)
	ld a, e
	extz wa
	muls wa, 0x47
	lda xbc, (10562:16)
	lda	xiy, (xbc+wa)
	lda	xix, (xiz+hl)
	ldw bc, 0x23
	ldirw
	ldi85
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x47
	ld bc, wa
	lda xhl, (Payload_Bss_Start+0x4218:24)
	ld a, (xsp + 4)
	ld	(xhl+bc), a

; i++, loop while i < 4; also the skip target for an unallocated layer.
Voice_NoteOn_Type2_LoopStep:
	inc 1, e
	cp e, 4:i3
	jr c, Voice_NoteOn_Type2_BranchE

; Unwind and `retd 0x02`.
Voice_NoteOn_Type2_Exit:
	pop xiz
	lda xsp, (xsp + 10)
	retd 0x2

; Parameter rebuild + emit for one physical TG slot, type-2 flavour.
; IN : A = physical TG slot. XIZ := 0x04308E + A*0x47.
; Chain: WaveSel_StageB_Build_Reg040, Pitch_Apply_Zone_Trim,
; Voice_Pitch_WriteOutputReg_Secondary, TVF_BuildEmit_Short_Dispatch,
; TVF_Emit_Registers_Type2, Voice_ComputePitchBend2, Voice_Build_GateCommand_NoPartial,
; Voice_Calc_LevelPair_FixedAtk, Voice_WriteChPanShift2 (BC = 0), Voice_Level_ClearAllOutputRegs,
; Voice_ComputePitch_Mono, Voice_ApplyPortamento2, then
; ToneGen_WriteVoiceParams(slot, 0x0451CC). Callers: Voice_SetVelocity_Type0_NopCont2 and
; Voice_SetVelocity_Type80_NopCont2.
Voice_Init_Type2:	.include "includes/generated/cc900/Voice_Init_Type2.s"	; C: cc900/voice_ctrlchange_callnames.c

; The type-2 per-layer staging builder -- the counterpart of Voice_Allocate_Typed.
; IN : XWA = note request record, C = part index, DE = a capability mask, plus stacked
; +0x22 selector, +0x24 velocity, +0x26 sub-index, +0x28 layer index. `retd 0x08`.
; Resolves the tone parameter block from part+0x06 through ToneDB_Find_SubToneRecord;
; refuses the layer (ExitA) if (block+0x0D & DE) == 0. Otherwise WaveSel_StageA1_FromToneSlot
; + Velocity_Select_Split_Zone_Alt + WaveSel_StageA2_FromVelZone derive the level, and the staging
; record 0x002942 + layer*0x47 gets +0x01 = velidx<<6 with bit 4 set, +0x03 = layer,
; +0x04 = part, +0x05 = subindex | 0x80, +0x0C = velocity (transposed by +0x10 and clamped
; to 0..0x7F when bit 0 of the global word at 0x041343 is set), +0x23 = &part record,
; +0x27 = &part layer sub-block, +0x13/+0x17/+0x1B/+0x1F = the resolved pointers, then
; Voice_Pitch_CopyBase and requestrec+0x02+layer = 0x80 | selector.
; Only caller: Voice_NoteOn_Type1. Touches no hardware.
Voice_Allocate_Type2:
	lda xsp, (xsp - 26)
	push xiz
	ld (xsp + 22), de
	ld (xsp + 24), c
	ld (xsp + 26), xwa
	ld a, (xsp + 24)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xhl, (xbc+wa)
	ld a, (xsp + 38)
	ld c, a
	extz bc
	ld a, (xsp + 24)
	ld e, a
	extz de
	ld xwa, xhl
	call ToneDB_Find_SubToneRecord
	ld (xsp + 4), xhl
	ld xwa, (xsp + 4)
	ld a, (xwa + 13)
	extz wa
	and wa, (xsp + 22)
	jrl z, Voice_Allocate_Type2_ExitA
	ld a, (xsp + 40)
	extz wa
	muls wa, 0x15
	ld bc, wa
	add bc, 0x10
	ld xwa, (xsp + 4)
	lda	xwa, (xwa+bc)
	ld (xsp + 8), xwa
	ld a, (xsp + 40)
	ld c, a
	extz bc
	ld a, (xsp + 38)
	ld e, a
	extz de
	ld a, (xsp + 24)
	extz wa
	pushw wa
	ld wa, bc
	ld xbc, (xsp + 10)
	call WaveSel_StageA1_FromToneSlot
	ld (xsp + 12), xhl
	ld a, (xsp + 36)
	extz wa
	ld xbc, (xsp + 12)
	call Velocity_Select_Split_Zone_Alt
	ld (xsp + 20), l
	ld a, (xsp + 20)
	extz wa
	ld xbc, (xsp + 12)
	call WaveSel_StageA2_FromVelZone
	ld (xsp + 16), xhl
	ld a, (xsp + 40)
	extz wa
	muls wa, 0x47
	lda xbc, (10562:16)
	lda	xiz, (xbc+wa)
	ld a, (xsp + 20)
	sll a, 6
	set 4, a
	extz wa
	ld (xiz + 1), wa
	ld a, (xsp + 40)
	ld (xiz + 3), a
	ld a, (xsp + 24)
	ld (xiz + 4), a
	ld a, (xsp + 38)
	set 7, a
	ld (xiz + 5), a
	ld wa, (Voice_GlobalFlags:24)
	bit 1, wa
	jr z, Voice_Allocate_Type2_BranchA
	ld a, (xsp + 36)
	add a, 0x10
	extz wa
	ldw bc, 0x7F
	ld de, 0:i3
	calr Voice_Pitch_ClampRange
	ld (xsp + 36), l

; Past the optional transpose; store the velocity and wire up the record pointers.
Voice_Allocate_Type2_BranchA:
	ld a, (xsp + 36)
	ld (xiz + 12), a
	ld a, (xsp + 24)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	ld (xiz + 35), xwa
	ld a, (xsp + 40)
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, 0x6E
	ld a, (xsp + 24)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	lda	xwa, (xwa+de)
	ld (xiz + 39), xwa
	ld xwa, (xsp + 4)
	ld (xiz + 19), xwa
	ld xwa, (xsp + 8)
	ld (xiz + 23), xwa
	ld xwa, (xsp + 12)
	ld (xiz + 27), xwa
	ld xwa, (xsp + 16)
	ld (xiz + 31), xwa
	ld xwa, xiz
	call Voice_Pitch_CopyBase
	ld a, (xsp + 40)
	extz wa
	ld bc, wa
	inc 2, bc
	ld e, (xsp + 34)
	set 7, e
	ld xwa, (xsp + 26)
	ld	(xwa+bc), e
	jr Voice_Allocate_Type2_ExitB

; Refusal path: requestrec+0x02+layer = 0.
Voice_Allocate_Type2_ExitA:
	ld a, (xsp + 40)
	extz wa
	ld bc, wa
	inc 2, bc
	ld xwa, (xsp + 26)
	ld	(xwa+bc), 0x00

; Common tail: requestrec+0x06+layer = 0, `retd 0x08`.
Voice_Allocate_Type2_ExitB:
	ld a, (xsp + 40)
	extz wa
	ld bc, wa
	inc 6, bc
	ld xwa, (xsp + 26)
	ld	(xwa+bc), 0x00
	pop xiz
	lda xsp, (xsp + 26)
	retd 0x8

; Two-layer note-on. IN: XWA = note request record, C = part index, E = key, stacked
; velocity. `retd 0x02`.
; requestrec+0x00 = key | part<<8 | 0x80; two Voice_Allocate_Type2 calls (capability masks 1
; and 4, selectors 0 and 1); then it explicitly zeroes requestrec+0x04, +0x05, +0x08 and
; +0x09 so layers 2 and 3 cannot be requested; then Voice_Allocate_Nodes and a commit loop over
; i = 0..1 only, with the same `>= 0x40` gate, the same 0x47-byte block copy and
; live+0x00 = slot. Only caller: Voice_SetVelocity_DrumKit.
Voice_NoteOn_Type1:
	lda xsp, (xsp - 10)
	push xiz
	ld (xsp + 6), e
	ld (xsp + 8), c
	ld (xsp + 10), xwa
	ld a, (xsp + 6)
	ld c, a
	extz bc
	ld a, (xsp + 8)
	extz wa
	sll wa, 8
	or wa, bc
	ld bc, wa
	set 7, bc
	ld xwa, (xsp + 10)
	ld (xwa), bc
	ld a, (xsp + 8)
	ld c, a
	extz bc
	pushw 0x0
	ld a, (xsp + 8)
	extz wa
	pushw wa
	ld a, (xsp + 22)
	extz wa
	pushw wa
	pushw 0x0
	ld xwa, (xsp + 18)
	ld de, 1:i3
	calr Voice_Allocate_Type2
	ld a, (xsp + 8)
	ld c, a
	extz bc
	pushw 0x1
	ld a, (xsp + 8)
	extz wa
	pushw wa
	ld a, (xsp + 22)
	extz wa
	pushw wa
	pushw 0x1
	ld xwa, (xsp + 18)
	ld de, 4:i3
	calr Voice_Allocate_Type2
	ld xwa, (xsp + 10)
	ld (xwa + 4), 0x0
	ld xwa, (xsp + 10)
	ld (xwa + 8), 0x0
	ld xwa, (xsp + 10)
	ld (xwa + 5), 0x0
	ld xwa, (xsp + 10)
	ld (xwa + 9), 0x0
	ld xwa, (xsp + 10)
	call Voice_Allocate_Nodes
	ld e, 0x0:opc
	cp e, 2:i3
	jr nc, Voice_NoteOn_Type1_Exit

; Commit loop head for i = 0..1, including the `cp (requestrec+0x0A+i),0x40` gate.
Voice_NoteOn_Type1_LoopBody:
	ld a, e
	extz wa
	ld bc, wa
	add bc, 0xA
	ld xwa, (xsp + 10)
	cp	(xwa+bc), 0x40
	jr nc, Voice_NoteOn_Type1_LoopStep
	ld a, e
	extz wa
	ld bc, wa
	add bc, 0xA
	ld xwa, (xsp + 10)
	ld	a, (xwa+bc)
	ld (xsp + 4), a
	extz wa
	muls wa, 0x47
	ld hl, wa
	lda xiz, (Payload_Bss_Start+0x4218:24)
	ld a, e
	extz wa
	muls wa, 0x47
	lda xbc, (10562:16)
	lda	xiy, (xbc+wa)
	lda	xix, (xiz+hl)
	ldw bc, 0x23
	ldirw
	ldi85
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x47
	ld bc, wa
	lda xhl, (Payload_Bss_Start+0x4218:24)
	ld a, (xsp + 4)
	ld	(xhl+bc), a

; i++, loop while i < 2; also the skip target for an unallocated layer.
Voice_NoteOn_Type1_LoopStep:
	inc 1, e
	cp e, 2:i3
	jr c, Voice_NoteOn_Type1_LoopBody

; Unwind and `retd 0x02`.
Voice_NoteOn_Type1_Exit:
	pop xiz
	lda xsp, (xsp + 10)
	retd 0x2

; Parameter rebuild + emit for one physical TG slot, type-1 flavour. IN: A = slot.
; Identical to Voice_Init_Type2 except that (a) right after WaveSel_StageB_Build_Reg040 it
; calls WaveSel_AddRandomEntryOffset(0x0451CE), dithering the staged waveform word by
; (tick & 7), and (b) it uses Voice_Slot_LoadPitchOffset_B instead of the mono pitch step.
; Ends with ToneGen_WriteVoiceParams(slot, 0x0451CC). Callers: the tails of Voice_SetPitch
; and Voice_NoteOff.
Voice_Init_Type1:	.include "includes/generated/cc900/Voice_Init_Type1.s"	; C: cc900/voice_ctrlchange_callnames.c

; Single-layer staging builder for the Voice_NoteOn_Rhythm path.
; IN : XWA = note request record, C = part index, DE = capability mask, plus stacked
; +0x1E selector, +0x20 velocity, +0x22 sub-index, +0x24 layer index. `retd 0x08`.
; Resolves the layer sub-block at part + 0x6E + layer*0x25, follows its +0x08 pointer, and
; refuses (ExitA) if bit 1 of that block is clear OR if (paramblock+0x0D & DE) == 0.
; Otherwise it fills 0x002942 + layer*0x47 exactly like Voice_Allocate_Typed does
; (+0x01 = velidx<<6 | 0x12, +0x03/+0x04/+0x05/+0x0C, +0x23, +0x13/+0x17/+0x1B/+0x1F) and
; then calls Voice_Slot_ComputePitch to fill +0x06 and +0x08. Sets requestrec+0x02+layer =
; 0x80 | selector. NOTE it does NOT touch requestrec+0x06+layer on the success path.
; Callers: Voice_NoteOn_Rhythm and Voice_NoteOn_Rhythm_BranchA. Touches no hardware.
Voice_Allocate_1of4:
	lda xsp, (xsp - 24)
	pushw_erp 0xFA
	ld (xsp + 18), de
	ld (xsp + 20), c
	ld (xsp + 22), xwa
	ldib_erp 0xFB, 0
	ldto_berp A, 0xFB
	extz wa
	ld bc, wa
	sla bc, 2
	ld a, (xsp + 36)
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, bc
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	lda	xwa, (xwa+de)
	ld xwa, (xwa + 118)
	ld (xsp + 14), xwa
	ld bc, (xwa + 12)
	ld a, c
	ld e, a
	extz de
	ld wa, bc
	srl wa, 8
	ld c, a
	extz bc
	ld wa, de
	call ToneDB_Find_ToneRecord
	ld xwa, (xsp + 14)
	ld a, (xwa + 11)
	ld c, a
	extz bc
	ld a, (xsp + 20)
	ld e, a
	extz de
	ld xwa, xhl
	call ToneDB_Find_SubToneRecord
	ld (xsp + 2), xhl
	ld xwa, (xsp + 14)
	bitm 1, (xwa)
	jrl z, Voice_Allocate_1of4_ExitA
	ld xwa, (xsp + 2)
	ld a, (xwa + 13)
	extz wa
	and wa, (xsp + 18)
	jrl z, Voice_Allocate_1of4_ExitA
	ld a, (xsp + 36)
	extz wa
	muls wa, 0x15
	ld bc, wa
	add bc, 0x10
	ld xwa, (xsp + 2)
	lda	xwa, (xwa+bc)
	ld (xsp + 6), xwa
	ld a, (xsp + 36)
	ld c, a
	extz bc
	ld a, (xsp + 34)
	ld e, a
	extz de
	ld a, (xsp + 20)
	extz wa
	pushw wa
	ld wa, bc
	ld xbc, (xsp + 8)
	call WaveSel_StageA1_FromToneSlot
	ld (xsp + 10), xhl
	ld a, (xsp + 32)
	extz wa
	ld xbc, (xsp + 10)
	call Velocity_Select_Split_Zone_Alt
	ldfr_berp L, 0xFB
	ldto_berp A, 0xFB
	extz wa
	ld xbc, (xsp + 10)
	call WaveSel_StageA2_FromVelZone
	ld (xsp + 14), xhl
	ld a, (xsp + 36)
	extz wa
	muls wa, 0x47
	lda xbc, (10562:16)
	lda	xbc, (xbc+wa)
	ldto_berp A, 0xFB
	sll a, 6
	or a, 0x12
	extz wa
	ld (xbc + 1), wa
	ld a, (xsp + 36)
	ld (xbc + 3), a
	ld a, (xsp + 20)
	ld (xbc + 4), a
	ld a, (xsp + 34)
	set 7, a
	ld (xbc + 5), a
	ld a, (xsp + 32)
	ld (xbc + 12), a
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xde, (Part_Record_Base:24)
	exts xwa
	add xwa, xde
	ld (xbc + 35), xwa
	ld xwa, (xsp + 2)
	ld (xbc + 19), xwa
	ld xwa, (xsp + 6)
	ld (xbc + 23), xwa
	ld xwa, (xsp + 10)
	ld (xbc + 27), xwa
	ld xwa, (xsp + 14)
	ld (xbc + 31), xwa
	ld xwa, xbc
	call Voice_Slot_ComputePitch
	ld a, (xsp + 36)
	extz wa
	ld bc, wa
	inc 2, bc
	ld e, (xsp + 30)
	set 7, e
	ld xwa, (xsp + 22)
	ld	(xwa+bc), e
	jr Voice_Allocate_1of4_ExitB

; Refusal path: requestrec+0x02+layer = 0.
Voice_Allocate_1of4_ExitA:
	ld a, (xsp + 36)
	extz wa
	ld bc, wa
	inc 2, bc
	ld xwa, (xsp + 22)
	ld	(xwa+bc), 0x00

; Unwind and `retd 0x08`.
Voice_Allocate_1of4_ExitB:
	popw_erp 0xFA
	lda xsp, (xsp + 24)
	retd 0x8

; Allocates and commits ONE physical voice for a single-layer part. Despite the name it is
; used for both the note-on and the note-off half of a key event -- see [UNCERTAIN].
; IN : XWA = a caller-owned note request record (both callers put it on their own stack),
; C = part index, E = key, one stacked byte = velocity. `retd 0x02`.
; requestrec+0x00 = key | part<<8 | 0x80. Then:
;   velocity != 0 : layer index 0, Voice_Allocate_1of4(mask 1, selector 3, velocity),
;                   requestrec+0x06 = 0x40, +0x03 = 0, +0x07 = 0.
;   velocity == 0 : layer index 1, velocity forced to 0x50,
;                   requestrec+0x02 = 0, +0x06 = 0,
;                   Voice_Allocate_1of4(mask 4, selector 3), requestrec+0x07 = 0.
; Both paths then zero requestrec+0x04/+0x05/+0x08/+0x09, call Voice_Allocate_Nodes, and commit
; the one layer: if requestrec+0x0A+layer >= 0x40 the whole event evaporates, else the
; 0x47-byte staging record is copied to 0x04308E + slot*0x47 and live+0x00 = slot.
Voice_NoteOn_Rhythm:
	dec 2, xsp
	push xiz
	ld xiz, xwa
	ld l, (xsp + 10)
	ldfr_berp E, 0xF0
	extz ix
	ld a, c
	extz wa
	sll wa, 8
	or wa, ix
	set 7, wa
	ld (xiz), wa
	cp l, 0:i3
	jr z, Voice_NoteOn_Rhythm_BranchA
	ld (xsp + 4), 0x0
	extz bc
	ld a, (xsp + 4)
	extz wa
	pushw wa
	ld a, e
	extz wa
	pushw wa
	ld a, l
	extz wa
	pushw wa
	pushw 0x3
	ld xwa, xiz
	ld de, 1:i3
	calr Voice_Allocate_1of4
	ld (xiz + 6), 0x40
	ld (xiz + 3), 0x0
	ld (xiz + 7), 0x0
	jr Voice_NoteOn_Rhythm_BranchB

; Zero-velocity arm: layer index 1, velocity forced to 0x50, capability mask 4.
Voice_NoteOn_Rhythm_BranchA:
	ld (xsp + 4), 0x1
	ld l, 0x50:opc
	ld (xiz + 2), 0x0
	ld (xiz + 6), 0x0
	extz bc
	ld a, (xsp + 4)
	extz wa
	pushw wa
	ld a, e
	extz wa
	pushw wa
	ld a, l
	extz wa
	pushw wa
	pushw 0x3
	ld xwa, xiz
	ld de, 4:i3
	calr Voice_Allocate_1of4
	ld (xiz + 7), 0x0

; Join point: zero the unused request bytes, Voice_Allocate_Nodes, then the commit gate.
Voice_NoteOn_Rhythm_BranchB:
	ld (xiz + 4), 0x0
	ld (xiz + 8), 0x0
	ld (xiz + 5), 0x0
	ld (xiz + 9), 0x0
	ld xwa, xiz
	call Voice_Allocate_Nodes
	ld a, (xsp + 4)
	extz wa
	add wa, 0xA
	cp	(xiz+wa), 0x40
	jr nc, Voice_NoteOn_Rhythm_Exit
	ld a, (xsp + 4)
	extz wa
	add wa, 0xA
	ld	e, (xiz+wa)
	ld a, e
	extz wa
	muls wa, 0x47
	ld hl, wa
	lda xiz, (Payload_Bss_Start+0x4218:24)
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x47
	lda xbc, (10562:16)
	lda	xiy, (xbc+wa)
	lda	xix, (xiz+hl)
	ldw bc, 0x23
	ldirw
	ldi85
	ld a, e
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4218:24)
	ld	(xbc+wa), e

; Unwind and `retd 0x02`. Also the landing point of the `slot >= 0x40` skip.
Voice_NoteOn_Rhythm_Exit:
	pop xiz
	inc 2, xsp
	retd 0x2

; NAME LEFT AS-IS (the reference file's existing non-LABEL_ name). The LLVM build calls this
; address Voice_SetPitch; the two agree in meaning. Documentation only.
; The SECOND half of a real note-on, for parts whose tone record selects this path.
; IN : A = part index, C = key, E = velocity, one stacked word. `retd 0x02`.
; Three guards, all of which return silently:
;   0x02C6EF : (tonerec+0x10 & 0xC0) must equal 0x40, where tonerec = the u32 at part+0x06;
;   0x02C70E : (part+0x02 & 0x0007) must be non-zero;
;   0x02C715 : bit 7 of the velocity argument must be CLEAR.
; Then Voice_Env_ApplyVelocity_Type0 and Voice_Env_UpdateVelocityCounters run, a request
; record is built on this routine's own stack (at xsp+2) and handed to Voice_NoteOn_Rhythm.
; The assigned slot is read back from requestrec+0x0A (layer 0) and must be < 0x40.
; It then talks to IC303 DIRECTLY, twice, with the P6.7 bracket described in the header:
;   register 0x0840 + slot <- 0xFF00
;   register 0x0800 + slot <- 0xFF80   (the documented "mute" level word)
; i.e. the voice is parked silent BEFORE its parameters exist. Voice_Init_Type1(slot) then
; builds and emits the whole register block, and finally
; ToneGen_WriteSingleReg(WA = slot, BC = the u16 at 0x0430BB + slot*0x47 = live+0x2D)
; writes the key-on word. Only caller: Voice_NoteOn (0x02CFDB region).
Voice_SetPitch:
	lda xsp, (xsp - 20)
	pushw_erp 0xFA
	ld (xsp + 16), e
	ld (xsp + 18), c
	ld (xsp + 20), a
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld a, (xwa + 16)
	and a, 0xC0
	cp a, 0x40
	jrl nz, Voice_SetPitch_Exit
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PresentWord:24)
	ld	wa, (xbc+wa)
	and wa, 0x7
	jrl z, Voice_SetPitch_Exit
	bitm 7, (xsp + 16)
	jrl nz, Voice_SetPitch_Exit
	ld a, (xsp + 20)
	ld e, a
	extz de
	ld a, (xsp + 26)
	ld c, a
	extz bc
	ld wa, de
	call Voice_Env_ApplyVelocity_Type0
	ld a, (xsp + 20)
	extz wa
	call Voice_Env_UpdateVelocityCounters
	lda xwa, (xsp + 2)
	ld xhl, xwa
	ld a, (xsp + 20)
	ld c, a
	extz bc
	ld a, (xsp + 18)
	ld e, a
	extz de
	ld a, (xsp + 16)
	extz wa
	pushw wa
	ld xwa, xhl
	calr Voice_NoteOn_Rhythm
	ld a, (xsp + 12)
	ldfr_berp A, 0xFB
	cp_erpb 0xFB, 0x40
	jr nc, Voice_SetPitch_Exit
	res	7, (P6:8)
	ldto_berp A, 0xFB
	extz wa
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff00
	jr Voice_SetPitch_NopCont1

; Bus-settling pad (3 nops) after writing 0xFF00 to TG register 0x0840 + slot.
Voice_SetPitch_NopCont1:
	nop
	nop
	nop
	res	7, (P6:8)
	ldto_berp A, 0xFB
	extz wa
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff80
	jr Voice_SetPitch_NopCont2

; Bus-settling pad (3 nops) after writing 0xFF80 to TG register 0x0800 + slot.
Voice_SetPitch_NopCont2:
	nop
	nop
	nop
	ldto_berp A, 0xFB
	extz wa
	calr Voice_Init_Type1
	ldto_berp A, 0xFB
	ld l, a
	extz hl
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x47
	ld bc, wa
	lda xde, (Payload_Bss_Start+0x4245:24)
	ld wa, hl
	ld	bc, (xde+bc)
	call ToneGen_WriteSingleReg

; Common exit for all three guards and the normal path; `retd 0x02`.
Voice_SetPitch_Exit:
	popw_erp 0xFA
	lda xsp, (xsp + 20)
	retd 0x2

; NAME LEFT AS-IS (the reference file's existing non-LABEL_ name). The LLVM build calls this
; address Voice_NoteOff; the two agree in meaning. Documentation only.
; The note-off body, structurally identical to Voice_SetPitch.
; IN : A = part index, C = key, E = velocity, one stacked word. `retd 0x02`.
; Same two guards on (tonerec+0x10 & 0xC0) == 0x40 and (part+0x02 & 0x0007) != 0, but NO
; velocity-bit-7 guard. Voice_Env_ApplyVelocity_Type0 and Voice_Env_UpdateVelocityCounters
; run, then a request record on this routine's own stack goes to Voice_NoteOn_Rhythm --
; which, because a note-off carries velocity 0, takes its layer-1 arm. The slot is therefore
; read back from requestrec+0x0B (layer 1, one byte further along than Voice_SetPitch reads)
; and must be < 0x40.
; Same direct IC303 writes: register 0x0840 + slot <- 0xFF00 and 0x0800 + slot <- 0xFF80,
; then Voice_Init_Type1(slot), then ToneGen_WriteSingleReg(slot, live+0x2D), and finally
; VoiceSlot_NoteOff(slot) at 0x0225D3 -- the extra call that distinguishes this routine from
; Voice_SetPitch. Only caller: Voice_NoteOn_ZeroVelocity.
Voice_NoteOff:
	lda xsp, (xsp - 20)
	pushw_erp 0xFA
	ld (xsp + 16), e
	ld (xsp + 18), c
	ld (xsp + 20), a
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld a, (xwa + 16)
	and a, 0xC0
	cp a, 0x40
	jrl nz, Voice_NoteOff_Exit
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PresentWord:24)
	ld	wa, (xbc+wa)
	and wa, 0x7
	jrl z, Voice_NoteOff_Exit
	ld a, (xsp + 20)
	ld e, a
	extz de
	ld a, (xsp + 26)
	ld c, a
	extz bc
	ld wa, de
	call Voice_Env_ApplyVelocity_Type0
	ld a, (xsp + 20)
	extz wa
	call Voice_Env_UpdateVelocityCounters
	lda xwa, (xsp + 2)
	ld xhl, xwa
	ld a, (xsp + 20)
	ld c, a
	extz bc
	ld a, (xsp + 18)
	ld e, a
	extz de
	ld a, (xsp + 16)
	extz wa
	pushw wa
	ld xwa, xhl
	calr Voice_NoteOn_Rhythm
	ld a, (xsp + 13)
	ldfr_berp A, 0xFB
	cp_erpb 0xFB, 0x40
	jr nc, Voice_NoteOff_Exit
	res	7, (P6:8)
	ldto_berp A, 0xFB
	extz wa
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff00
	jr Voice_NoteOff_NopCont1

; Bus-settling pad (3 nops) after writing 0xFF00 to TG register 0x0840 + slot.
Voice_NoteOff_NopCont1:
	nop
	nop
	nop
	res	7, (P6:8)
	ldto_berp A, 0xFB
	extz wa
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff80
	jr Voice_NoteOff_NopCont2

; Bus-settling pad (3 nops) after writing 0xFF80 to TG register 0x0800 + slot.
Voice_NoteOff_NopCont2:
	nop
	nop
	nop
	ldto_berp A, 0xFB
	extz wa
	calr Voice_Init_Type1
	ldto_berp A, 0xFB
	ld l, a
	extz hl
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x47
	ld bc, wa
	lda xde, (Payload_Bss_Start+0x4245:24)
	ld wa, hl
	ld	bc, (xde+bc)
	call ToneGen_WriteSingleReg
	ldto_berp A, 0xFB
	extz wa
	call VoiceSlot_NoteOff

; Common exit for both guards and the normal path; `retd 0x02`. Last instruction of the
; region (ends at 0x02C8E3).
Voice_NoteOff_Exit:
	popw_erp 0xFA
	lda xsp, (xsp + 20)
	retd 0x2

; Already named in symbols/subcpu_symbols_reference.txt and in the LLVM build; entry kept
; unchanged, this entry only adds documentation.
; The note-on workhorse. Inputs: A = part index (0..0x19), C = MIDI note, E = velocity,
; plus one word pushed by the caller (Voice_NoteOn pushes MIDI status & 7 = the "source"
; tag). Stack frame: 20 bytes of scratch + saved 0xFA/0xFB byte temporaries; the caller's
; pushed word lands at (XSP+26); returns with retd 2.
; It reads the part descriptor pointer at 0x04136E + part*0x11F, dereferences it and
; switches on tone-header byte +0x10 masked with 0xC0 -- the PART MODE:
;   0xC0 -> falls straight through to VOICE_SETVELOCITY_EXIT: NOTHING IS ALLOCATED AND NO TG
;           REGISTER IS TOUCHED. This is a silent no-op path.
;   0x80 -> VOICE_SETVELOCITY_MODE80 (2 voice slots, Voice_NoteOn_Type1 @0x02C2C0)
;   0x40 -> VOICE_SETVELOCITY_MODE40 (4 slots, Voice_NoteOn_Type2 @0x02BF1B)
;   0x00 -> in-line mode-00 path      (4 slots, Voice_Build_Four_Partials @0x02BA2C)
;   anything else -> exit, also a no-op.
; The chosen Voice_NoteOn_TypeN fills the 20-byte scratch frame; scratch[0x0A + i] is the TG
; channel allocated for slot i (0xFF/>=0x40 means "no slot"). Two loops then follow: see
; VOICE_SETVELOCITY_MODE00_KEYON_LOOP and VOICE_SETVELOCITY_MODE00_PITCHFIX_LOOP.
; On exit it clears bits 2..3 of the part word at 0x041368 + part*0x11F.
; Callers: VOICE_NOTEON (0x02CF97) and the MIDI/keybed note path.
Voice_SetVelocity:
	lda xsp, (xsp - 20)
	pushw_erp 0xFA
	ld (xsp + 16), e
	ld (xsp + 18), c
	ld (xsp + 20), a
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld a, (xwa + 16)
	and a, 0xC0
	cp a, 0xC0
	jrl z, Voice_SetVelocity_Exit
	cp a, 0x80
	jrl z, Voice_SetVelocity_DrumKit
	cp a, 0x40
	jrl z, Voice_SetVelocity_Drawbar
	cp a, 0:i3
	jrl nz, Voice_SetVelocity_Exit
	ld a, (xsp + 20)
	ld e, a
	extz de
	ld a, (xsp + 26)
	ld c, a
	extz bc
	ld wa, de
	call Voice_Env_ApplyVelocity_Type0
	ld a, (xsp + 20)
	extz wa
	call Voice_Env_UpdateVelocityCounters
	call Voice_Vol_ScaleVelocityWord
	lda xwa, (xsp + 2)
	ld xhl, xwa
	ld a, (xsp + 20)
	ld c, a
	extz bc
	ld a, (xsp + 18)
	ld e, a
	extz de
	ld a, (xsp + 16)
	extz wa
	pushw wa
	ld xwa, xhl
	calr Voice_Build_Four_Partials
	ldib_erp 0xFA, 0
	cpib_erp 0xFA, 4
	jrl nc, Voice_SetVelocity_Type0_Loop2Start

; For each of the 4 allocated slots (channel = scratch[0x0A+i], skipped when >= 0x40): mute the
; voice by writing TG reg 0x0840+ch = 0xFF00 and reg 0x0800+ch = 0xFF80, then call
; Voice_Init_Type2 (0x02C0B6) or Voice_Build_Register_Set (0x02B4E3) depending on bit1 of the voice
; struct word at 0x04308F + ch*0x47.
Voice_SetVelocity_Type0_SlotLoop:
	ldto_berp A, 0xFA
	extz wa
	add wa, 0xA
	lda xbc, (xsp + 2)
	ld	a, (xbc+wa)
	ldfr_berp A, 0xFB
	cp_erpb 0xFB, 0x40
	jr nc, Voice_SetVelocity_Type0_BranchB
	res	7, (P6:8)
	ldto_berp A, 0xFB
	extz wa
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff00
	jr Voice_SetVelocity_Type0_NopCont1

Voice_SetVelocity_Type0_NopCont1:
	nop
	nop
	nop
	res	7, (P6:8)
	ldto_berp A, 0xFB
	extz wa
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff80
	jr Voice_SetVelocity_Type0_NopCont2

Voice_SetVelocity_Type0_NopCont2:
	nop
	nop
	nop
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4219:24)
	ld	wa, (xbc+wa)
	bit 1, wa
	jr z, Voice_SetVelocity_Type0_BranchA
	ldto_berp A, 0xFB
	extz wa
	calr Voice_Init_Type2
	jr Voice_SetVelocity_Type0_BranchB

; Bit1 of voicestruct+1 clear -> Voice_Build_Register_Set instead of Voice_Init_Type2.
Voice_SetVelocity_Type0_BranchA:
	ldto_berp A, 0xFB
	extz wa
	calr Voice_Build_Register_Set

Voice_SetVelocity_Type0_BranchB:
	inc1b_erp 0xFA
	cpib_erp 0xFA, 4
	jrl c, Voice_SetVelocity_Type0_SlotLoop

; Second pass over the same 4 slots. For each channel < 0x40 whose voice struct has word
; +0x2F == 0 and word +0x01 bit8 clear, it calls TONEGEN_WRITESINGLEREG(ch, voicestruct+0x2D),
; i.e. it writes TG register (0x0000 + ch) with the stored key-on word. THIS IS THE ACTUAL
; KEY-ON: bank 0x0000 is the per-voice note/key register (writing 0x7E00 there frees a voice).
; Slots whose +0x2F word is non-zero are deliberately left un-keyed.
Voice_SetVelocity_Type0_Loop2Start:
	ldib_erp 0xFA, 0
	cpib_erp 0xFA, 4
	jr nc, Voice_SetVelocity_Type0_Loop2Exit

Voice_SetVelocity_Type0_Loop2Body:
	ldto_berp A, 0xFA
	extz wa
	add wa, 0xA
	lda xbc, (xsp + 2)
	cp	(xbc+wa), 0x40
	jr nc, Voice_SetVelocity_Type0_Loop2Step
	ldto_berp A, 0xFA
	extz wa
	add wa, 0xA
	lda xbc, (xsp + 2)
	ld	a, (xbc+wa)
	ldfr_berp A, 0xFB
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4247:24)
	cpw	(xbc+wa), 0x0000
	jr nz, Voice_SetVelocity_Type0_Loop2Step
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4219:24)
	ld	wa, (xbc+wa)
	bit 8, wa
	jr nz, Voice_SetVelocity_Type0_Loop2Step
	ldto_berp A, 0xFB
	ld l, a
	extz hl
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x47
	ld bc, wa
	lda xde, (Payload_Bss_Start+0x4245:24)
	ld wa, hl
	ld	bc, (xde+bc)
	call ToneGen_WriteSingleReg

Voice_SetVelocity_Type0_Loop2Step:
	inc1b_erp 0xFA
	cpib_erp 0xFA, 4
	jr c, Voice_SetVelocity_Type0_Loop2Body

; Calls Voice_ClearLFO_ActiveFlag(part) (0x027CD1) and jumps to the common exit.
Voice_SetVelocity_Type0_Loop2Exit:
	ld a, (xsp + 20)
	extz wa
	call Voice_ClearLFO_ActiveFlag
	jrl Voice_SetVelocity_Exit

; Part-mode 0x40 branch of VOICE_SETVELOCITY. Same shape as the mode-00 path but it uses
; Voice_NoteOn_Type2 and, in the per-slot loop, Voice_Release_Type4 (0x02BCD6) instead of the
; Init_Type2/Type4 pair. Falls into the same key-on loop and the same exit.
; Voice_SetVelocity_Drawbar: Part-mode 0x40 arm of Voice_SetVelocity -- the drawbar organ presets: four-layer
;   allocation by Voice_NoteOn_Type2, then the same key-on loop and exit as the melodic path. Basis: caller (dispatch
;   on tone byte +0x10 & 0xC0) + the tone database's part-mode values.
Voice_SetVelocity_Drawbar:
	ld a, (xsp + 20)
	ld e, a
	extz de
	ld a, (xsp + 26)
	ld c, a
	extz bc
	ld wa, de
	call Voice_Env_ApplyVelocity_Type0
	ld a, (xsp + 20)
	extz wa
	call Voice_Env_UpdateVelocityCounters
	lda xwa, (xsp + 2)
	ld xhl, xwa
	ld a, (xsp + 20)
	ld c, a
	extz bc
	ld a, (xsp + 18)
	ld e, a
	extz de
	ld a, (xsp + 16)
	extz wa
	pushw wa
	ld xwa, xhl
	calr Voice_NoteOn_Type2
	ldib_erp 0xFA, 0
	cpib_erp 0xFA, 4
	jr nc, Voice_SetVelocity_Type40_Loop2Start

Voice_SetVelocity_Type40_SlotLoop:
	ldto_berp A, 0xFA
	extz wa
	add wa, 0xA
	lda xbc, (xsp + 2)
	ld	a, (xbc+wa)
	ldfr_berp A, 0xFB
	cp_erpb 0xFB, 0x40
	jr nc, Voice_SetVelocity_Type40_LoopStep
	res	7, (P6:8)
	ldto_berp A, 0xFB
	extz wa
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff00
	jr Voice_SetVelocity_Type40_NopCont1

Voice_SetVelocity_Type40_NopCont1:
	nop
	nop
	nop
	res	7, (P6:8)
	ldto_berp A, 0xFB
	extz wa
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff80
	jr Voice_SetVelocity_Type40_NopCont2

Voice_SetVelocity_Type40_NopCont2:
	nop
	nop
	nop
	ldto_berp A, 0xFB
	extz wa
	calr Voice_Release_Type4

Voice_SetVelocity_Type40_LoopStep:
	inc1b_erp 0xFA
	cpib_erp 0xFA, 4
	jr c, Voice_SetVelocity_Type40_SlotLoop

Voice_SetVelocity_Type40_Loop2Start:
	ldib_erp 0xFA, 0
	cpib_erp 0xFA, 4
	jr nc, Voice_SetVelocity_Type40_Loop2Exit

Voice_SetVelocity_Type40_Loop2Body:
	ldto_berp A, 0xFA
	extz wa
	add wa, 0xA
	lda xbc, (xsp + 2)
	ld	a, (xbc+wa)
	ldfr_berp A, 0xFB
	cp_erpb 0xFB, 0x40
	jr nc, Voice_SetVelocity_Type40_Loop2Step
	ldto_berp A, 0xFB
	ld l, a
	extz hl
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x47
	ld bc, wa
	lda xde, (Payload_Bss_Start+0x4245:24)
	ld wa, hl
	ld	bc, (xde+bc)
	call ToneGen_WriteSingleReg

Voice_SetVelocity_Type40_Loop2Step:
	inc1b_erp 0xFA
	cpib_erp 0xFA, 4
	jr c, Voice_SetVelocity_Type40_Loop2Body

Voice_SetVelocity_Type40_Loop2Exit:
	ld a, (xsp + 20)
	extz wa
	call Voice_ClearLFO_ActiveFlag
	jrl Voice_SetVelocity_Exit

; Part-mode 0x80 branch. Only TWO slots (loop bound 2, not 4) and it additionally calls
; Voice_WriteChPitchWithVib (0x0266D8) per slot before muting, then Voice_Init_Type2.
; Voice allocation is done by Voice_NoteOn_Type1 (0x02C2C0).
; Voice_SetVelocity_DrumKit: Part-mode 0x80 arm of Voice_SetVelocity -- drum kits: two-layer allocation by
;   Voice_NoteOn_Type1 (a percussion record has two 21-byte layers), a 2-slot key-on loop with
;   Voice_WriteChPitchWithVib per slot. Basis: caller (dispatch on tone byte +0x10 & 0xC0) + the tone database's part-
;   mode values.
Voice_SetVelocity_DrumKit:
	lda xwa, (xsp + 2)
	ld xhl, xwa
	ld a, (xsp + 20)
	ld c, a
	extz bc
	ld a, (xsp + 18)
	ld e, a
	extz de
	ld a, (xsp + 16)
	extz wa
	pushw wa
	ld xwa, xhl
	calr Voice_NoteOn_Type1
	ldib_erp 0xFA, 0
	cpib_erp 0xFA, 2
	jrl nc, Voice_SetVelocity_Type80_Loop2Start

Voice_SetVelocity_Type80_SlotLoop:
	ldto_berp A, 0xFA
	extz wa
	add wa, 0xA
	lda xbc, (xsp + 2)
	ld	a, (xbc+wa)
	ldfr_berp A, 0xFB
	cp_erpb 0xFB, 0x40
	jr nc, Voice_SetVelocity_Type80_LoopStep
	ld a, (xsp + 20)
	ld e, a
	extz de
	ldto_berp A, 0xFB
	ld c, a
	extz bc
	ld wa, de
	call Voice_WriteChPitchWithVib
	res	7, (P6:8)
	ldto_berp A, 0xFB
	extz wa
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff00
	jr Voice_SetVelocity_Type80_NopCont1

Voice_SetVelocity_Type80_NopCont1:
	nop
	nop
	nop
	res	7, (P6:8)
	ldto_berp A, 0xFB
	extz wa
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff80
	jr Voice_SetVelocity_Type80_NopCont2

Voice_SetVelocity_Type80_NopCont2:
	nop
	nop
	nop
	ldto_berp A, 0xFB
	extz wa
	calr Voice_Init_Type2

Voice_SetVelocity_Type80_LoopStep:
	inc1b_erp 0xFA
	cpib_erp 0xFA, 2
	jr c, Voice_SetVelocity_Type80_SlotLoop

Voice_SetVelocity_Type80_Loop2Start:
	ldib_erp 0xFA, 0
	cpib_erp 0xFA, 2
	jr nc, Voice_SetVelocity_Type80_Loop2Exit

Voice_SetVelocity_Type80_Loop2Body:
	ldto_berp A, 0xFA
	extz wa
	add wa, 0xA
	lda xbc, (xsp + 2)
	ld	a, (xbc+wa)
	ldfr_berp A, 0xFB
	cp_erpb 0xFB, 0x40
	jr nc, Voice_SetVelocity_Type80_Loop2Step
	ldto_berp A, 0xFB
	ld l, a
	extz hl
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x47
	ld bc, wa
	lda xde, (Payload_Bss_Start+0x4245:24)
	ld wa, hl
	ld	bc, (xde+bc)
	call ToneGen_WriteSingleReg

Voice_SetVelocity_Type80_Loop2Step:
	inc1b_erp 0xFA
	cpib_erp 0xFA, 2
	jr c, Voice_SetVelocity_Type80_Loop2Body

Voice_SetVelocity_Type80_Loop2Exit:
	ld a, (xsp + 20)
	extz wa
	call Voice_ClearLFO_ActiveFlag

; Common tail: clears bits 2-3 (mask 0xF3FF) of the part status word at 0x041368+part*0x11F,
; restores the frame and returns with retd 2. Note that the 0xC0 part-mode reaches this point
; without having touched the tone generator at all.
Voice_SetVelocity_Exit:
	ld a, (xsp + 20)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	andw	(xbc+wa), 0xfff3
	popw_erp 0xFA
	lda xsp, (xsp + 20)
	retd 0x2

; Already named in the reference file; kept, documentation only.
; Despite the name this does NOT allocate: it builds a 5-byte request packet in the DRAM
; scratch at 0x2A5E and calls NoteOn_RoutePacket (0x022691), which WALKS the 0x40-entry voice
; table at 0x00148D (stride 0x27) and writes the list of matching channel numbers, 0xFF
; terminated, into packet+5. Returns XHL = the packet.
; Packet layout: [0] = filter mode byte, [1..2] = selector word (bits 0-6 note, bits 8-12 part
; index, bit15 = flag), [3..4] = mask word (bits 8-12 non-zero means "match every voice").
; This variant: mode 0x80, selector = (A<<8) | C | 0x8000, mask 0x0000; A = part, C = note.
; The five siblings below differ only in those three constants.
Voice_Allocate:	.include "includes/generated/cc900/Voice_Allocate.s"	; C: cc900/voice_ctrlchange.c

; Same packet builder as VOICE_ALLOCATE: mode 0x80, selector = (A<<8) | 0x8000 (no note),
; mask 0x007F. A = part index. Returns XHL = packet at 0x2A5E, packet+5 = 0xFF-terminated
; list of matching TG channels.
Voice_AllocateForRelease:	.include "includes/generated/cc900/Voice_AllocateForRelease.s"	; C: cc900/voice_ctrlchange.c

; Packet builder: mode 0x40, selector = (A<<8) (bit15 clear), mask 0x007F.
; Called from VoiceParam_Set_Tone_Option case 6 (0x02E90C) before
; Voice_AllNotes_SustainRetrigger (0x028E26).
Voice_AllocateForSustain:	.include "includes/generated/cc900/Voice_AllocateForSustain.s"	; C: cc900/voice_ctrlchange.c

; ** MISIDENTIFIED AS DATA. ** The LLVM source emits this as ".byte" under the name
; VoiceAllocate_DataTable_02CD14, but it is live code: it is CALLed from 0x0291CF and the
; only pointer to it in the whole ROM is that call.
; Packet builder: mode 0x00, selector = (A<<8) | 0x8000, mask 0x007F. A = part index.
; The caller at 0x02919E selects between this routine and VOICE_QUERY_REQ_MODE00_MASKFF
; (0x02CD36) on the part mode: mode 0x00 -> here, mode 0x80 -> 0x02CD36, modes 0x40/0xC0 ->
; neither (the query is skipped entirely).
; ★ Renamed 2026-09-25 from VoiceAllocate_DataTable_02CD14: header: the mode-0x00 query-packet builder (mask 0x007F) beside Voice_Query_PartVoices.
Voice_Query_PartVoices_Mask7F:	.include "includes/generated/cc900/Voice_Query_PartVoices_Mask7F.s"	; C: cc900/voice_ctrlchange.c

; Packet builder: mode 0x00, selector = (A<<8), mask 0x00FF. A = part index.
; Called from 0x0291DD.  (Was Voice_AllocateForFull; it allocates nothing -- it fills the
; query packet at 0x2A5E, hands it to NoteOn_RoutePacket and returns XHL = the packet,
; whose body is the list of voice channels belonging to that part.)
Voice_Query_PartVoices:	.include "includes/generated/cc900/Voice_Query_PartVoices.s"	; C: cc900/voice_ctrlchange.c

; Packet builder with mode 0x00, selector 0x0000
; and mask 0x1FFF; because mask bits 8-12 are non-zero, NoteOn_RoutePacket takes its
; "enumerate everything" path and returns every voice channel whose table entry +0x22 bit0 is
; set.  (Was Voice_AllocateForAny; it allocates nothing -- it builds a query packet and
; returns the matching voice list.)
Voice_Query_AllChannels:	.include "includes/generated/cc900/Voice_Query_AllChannels.s"	; C: cc900/voice_ctrlchange.c

; Existing curated name kept; documentation only. A = TG channel. Points XIZ at the voice
; struct 0x04308E + ch*0x47, clears bit7 of +0x05 (the "active" flag) and then picks one of
; four teardown shapes from struct word +0x01 bit15, the owning part record's word +0x0A bit0,
; and struct word +0x01 bit8:
;   bit8 set  -> Voice_Calc_LevelPair_EGA, ToneGen_WriteSegRegs_SameLevel(ch, 0x0451CC),
;                TONEGEN_WRITESINGLEREG(ch, struct+0x2D), Voice_Clear_HoldBit(ch), then clears
;                bit8 of struct+0x01.
;   bit8 clear-> the three Voice_ComputeAndWriteVolume{1,2,3} calls then
;                ToneGen_WriteLevelBurst(ch, 0x0451CC), or (branch D) Voice_Stage_EnvSegments and
;                ToneGen_WriteEnvSegments.
; All four paths end at 0x02CE48. The LLVM build calls this Voice_Reload_Levels.
Voice_Reload_Levels:	.include "includes/generated/cc900/Voice_Reload_Levels.s"	; C: cc900/voice_ctrlchange.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Reload_Levels_BranchA, Voice_Reload_Levels + 49
	.set	Voice_Reload_Levels_BranchB, Voice_Reload_Levels + 105
	.set	Voice_Reload_Levels_BranchC, Voice_Reload_Levels + 139
	.set	Voice_Reload_Levels_BranchD, Voice_Reload_Levels + 195
	.set	Voice_Reload_Levels_Exit, Voice_Reload_Levels + 215

; A = TG channel. Same preamble as 0x02CD71 (XIZ = voice struct, clear +0x05 bit7) but it
; SAVES the owning part record's word +0x0A across the call and restores it at 0x02CEC8, so
; the part-level state is deliberately left unchanged. When struct byte +0x03 == 3 it also
; clears bit0 of the part word before running. Writes the three volume registers and then
; ToneGen_WriteLevelBurst(ch, 0x0451CC). Named Voice_Cut in the LLVM build.
Voice_Cut:	.include "includes/generated/cc900/Voice_Cut.s"	; C: cc900/voice_ctrlchange.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Cut_BranchA, Voice_Cut + 57
	.set	Voice_Cut_BranchB, Voice_Cut + 78
	.set	Voice_Cut_BranchC, Voice_Cut + 92
	.set	Voice_Cut_BranchD, Voice_Cut + 98
	.set	Voice_Cut_Exit, Voice_Cut + 124

; A = TG channel. The cheapest teardown: clears bit7 of voice struct +0x05, and only if
; struct byte +0x46 is non-zero calls Voice_Calc_LevelPair_Silence followed by
; ToneGen_WriteLevelBurst(ch, 0x0451CC). Does not touch the part record at all.
Voice_ReleaseSingle:	.include "includes/generated/cc900/Voice_ReleaseSingle.s"	; C: cc900/voice_ctrlchange.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_ReleaseSingle_Exit, Voice_ReleaseSingle + 47

; Existing name kept; documentation only. XWA = pointer to a packet as returned by the
; VOICE_QUERY_* builders; the routine advances it by 5 to reach the 0xFF-terminated channel
; list and walks it until a byte >= 0x40 is seen. For each listed channel it reads the voice
; struct word +0x01 masked with 0x3C and dispatches the correct teardown:
;   0x20 -> Voice_Reload_Levels     0x10 -> VOICE_RELEASE_SINGLE
;   0x08 -> VOICE_CUT               0x04 -> if struct word +0x2F != 0 set bit7 of it; else if
;                                          word +0x31 != 0xFF rewrite it as (v & 0x9FFF)|0x1000
;                                          else Voice_Reload_Levels
;   other -> nothing.
; This is the routine that turns a "which channels belong to this part" query into note-offs.
Voice_ParamInit:
	dec 4, xsp
	push xiz
	inc 5, xwa
	ld xiz, xwa
	lda xwa, (Payload_Bss_Start+0x4218:24)
	ld (xsp + 4), xwa
	cp (xiz), 0x40
	jr nc, Voice_ParamInit_LoopStep

Voice_ParamInit_LoopBody:
	ld a, (xiz)
	extz wa
	muls wa, 0x47
	ld bc, wa
	ld xwa, (xsp + 4)
	exts xbc
	add xbc, xwa
	ld wa, (xbc + 1)
	and wa, 0x3C
	cp wa, 0x20
	jr z, Voice_ParamInit_BranchE
	cp wa, 0x10
	jr z, Voice_ParamInit_BranchD
	cp wa, 0x8
	jr z, Voice_ParamInit_BranchC
	cp wa, 4:i3
	jr nz, Voice_ParamInit_BranchF
	cpw (xbc + 47), 0x0
	jr z, Voice_ParamInit_BranchA
	ormi16 (xbc + 47), 0x80
	jr Voice_ParamInit_BranchF

Voice_ParamInit_BranchA:
	cpw (xbc + 49), 0xFF
	jr z, Voice_ParamInit_BranchB
	andmi16 (xbc + 49), 0x9FFF
	ormi16 (xbc + 49), 0x1000
	jr Voice_ParamInit_BranchF

Voice_ParamInit_BranchB:
	ld a, (xiz)
	extz wa
	calr Voice_Reload_Levels
	jr Voice_ParamInit_BranchF

Voice_ParamInit_BranchC:
	ld a, (xiz)
	extz wa
	calr Voice_Cut
	jr Voice_ParamInit_BranchF

Voice_ParamInit_BranchD:
	ld a, (xiz)
	extz wa
	calr Voice_ReleaseSingle
	jr Voice_ParamInit_BranchF

Voice_ParamInit_BranchE:
	ld a, (xiz)
	extz wa
	calr Voice_Reload_Levels

Voice_ParamInit_BranchF:
	inc 1, xiz
	cp (xiz), 0x40
	jr c, Voice_ParamInit_LoopBody

Voice_ParamInit_LoopStep:
	pop xiz
	inc 4, xsp
	ret

