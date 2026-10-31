; =============================================================================
; midi_encoder_routines.asm - MIDI Encoder Processing Routines
; =============================================================================
; This file contains the encoder dispatch and MIDI CC value processing
; routines for the KN5000 Main CPU.
;
; The encoder system works as follows:
; 1. Raw A/D values come from the CPL board MCU (bend, modulation, MAIN VOLUME) and the main
;    CPU A/D (expression pedal AN0, after touch AN1)
; 2. CPanel_EncoderDispatch routes to encoder-specific handlers
; 3. Each handler uses lookup tables to convert raw -> MIDI CC values
; 4. Processed values are stored in MIDI_CC_*_VALUE variables
;
; Routines:
;   CPanel_EncoderDispatch    - Dispatch to encoder-specific handler
;   Encoder_ProcessExpressionPedal   - Expression pedal, CPU AN0 (ID 2)
;   Encoder_ProcessAfterTouch     - After touch, CPU AN1 (ID 5)
;   Encoder_AfterTouch_ApplyThresholdCurve      - After-touch threshold and curve
;   Encoder_ProcessPitchBend     - Pitch bend wheel, CPL AD1 (ID 25)
;   Encoder_ProcessModulation       - Modulation wheel, CPL AD2 (ID 26)
;   Encoder_ProcessMainVolume - MAIN VOLUME, CPL AD3 (ID 27)
;   Encoder_PassthroughIdentity       - Simple passthrough (ID 31)
;   Encoder_ReturnDefaultConstant         - Return constant 1 (default/unused)
;   Encoder_OnTouchSensitivityChange        - Record 0x93 listener: bend range, after-touch curve/threshold
;
; Required includes before this file:
;   - midi_encoder_constants.asm (or equivalent EQU definitions)
;
; =============================================================================

; CPanel_EncoderDispatch - Dispatch to encoder-specific handler
; Input: A = encoder data value, BC = encoder type/index
; Extracts encoder ID from bits 0-2 and 6-7, looks up handler in jump table
CPanel_EncoderDispatch:
	extz wa
	ld e, c
	and e, 0x7	; Extract bits 0-2 of encoder ID
	and c, 0xc0	; Extract bits 6-7
	srl c, 3	; Shift to bits 3-4
	or c, e	; Combine to form 5-bit index
	extz bc
	sla bc, 2	; Multiply by 4 (jump table entry size)
	lda xde, (ENCODER_HANDLER_TABLE:24)
	exts xbc
	add xbc, xde	; XBC = table entry address
	ld xix, (xbc)	; Load handler address
	jp (xix)	; Jump to handler

; ============================================================================
; Encoder Value Processing Handlers
; These routines process raw encoder inputs and convert them to MIDI CC values
; using lookup tables. Called via ENCODER_HANDLER_TABLE dispatch.
; ============================================================================

; Encoder_ProcessExpressionPedal - Expression pedal (main CPU AN0, ID 2, AnalogIn_PollExpressionPedal)
; Input: A = raw encoder value
; Output: HL = processed MIDI CC value, or 0xffff if unchanged
Encoder_ProcessExpressionPedal:
	ldw hl, 0xffff	; Default return = no change
	cpl a	; Invert input value
	ld c, a
	ld (ENCODER_RAW_EXPRESSION_PEDAL:16), c; Store raw value
	srl a, 1	; Divide by 2
	extz wa
	lda xbc, (ENCODER_LUT_EXPRESSION_PEDAL:24); Lookup table address
	ld	a, (xbc+wa)	; Get processed value from table
	ld c, (ANALOG_EXPRESSION_PEDAL_VALUE:16); Get current value
	res 7, c	; Clear change flag
	cp c, a	; Compare with new value
	ret z	; Return if unchanged
	ld (ANALOG_EXPRESSION_PEDAL_VALUE:16), a; Store new value
	ld l, a
	extz hl	; Return value in HL
	ret
Encoder_ProcessExpressionPedal_End:

; Encoder_ProcessAfterTouch - After-touch sensor (main CPU AN1, ID 5, AnalogIn_PollAfterTouch)
; Input: A = raw encoder value
; Output: HL = processed MIDI CC value, or 0xffff if unchanged
Encoder_ProcessAfterTouch:
	pushw iz
	ldw iz, 0xffff	; Default return = no change
	ld (ENCODER_RAW_AFTERTOUCH:16), a; Store raw value
	extz wa
	lda xbc, (ENCODER_LUT_AFTERTOUCH:24); Lookup table address
	ld	a, (xbc+wa)	; Get processed value
	calr Encoder_AfterTouch_ApplyThresholdCurve	; Clamp to valid range
	ld a, l
	cp a, (ANALOG_AFTERTOUCH_VALUE:16)	; Compare with current
	jr z, Encoder_ProcessAfterTouch_NoChange
	ld (ANALOG_AFTERTOUCH_VALUE:16), a; Store new value
	ldfr_berp A, 0xf8
	extz iz	; IZ = new value

Encoder_ProcessAfterTouch_NoChange:
	ld hl, iz	; Return value in HL
	popw iz
	ret

; Encoder_AfterTouch_ApplyThresholdCurve - Applies the AFTER TOUCH threshold and curve: (max(v, threshold) - threshold) * 256 / 236 * curve_mult[ENCODER_AFTERTOUCH_CURVE] / 20, clamped to 127
; Input: L = value to clamp, A = raw lookup value
; Output: HL = clamped and scaled value
Encoder_AfterTouch_ApplyThresholdCurve:
	ld l, a
	ld c, (ENCODER_AFTERTOUCH_THRESHOLD:16); Get minimum limit
	cp l, c	; Compare with limit
	jr nc, Encoder_AfterTouch_Scale	; Skip if >= limit
	ld l, c	; Clamp to minimum

Encoder_AfterTouch_Scale:
	sub l, c	; Subtract minimum
	ld h, 0x0:opc
	extz xhl
	sll xhl, 8	; Scale up (multiply by 256)
	ld xwa, xhl
	ld xbc, 0xec	; Divisor
	call Math_DivideU32	; Division routine
	ld a, (ENCODER_AFTERTOUCH_CURVE:16); Get mode value
	extz wa
	add wa, wa	; Double for word table index
	lda xbc, (ENCODER_LUT_AFTERTOUCH_CURVE_MULT:24); Index table
	ld	bc, (xbc+wa)	; Get index offset
	extz xbc
	ld xwa, xhl
	call Math_Multiply32	; Processing routine
	ld xwa, xhl
	ld xbc, 0x14	; Constant
	call Math_DivideU32	; Division
	cp xhl, 0x7f	; Clamp to 127 max
	ret ule	; Return if <= 127
	ld xhl, 0x7f	; Clamp to 127
	ret
Encoder_AfterTouch_ApplyThresholdCurve_End:

; Encoder_ProcessPitchBend - Pitch bend wheel (CPL AD1, frame 0xD1, ID 25).  While a part is being recorded
; (CMP_RECORD_PART bits 0-3) or (0x7f0b) is set, rescales to 64 + (v/2 - 64) * (n/12) for bend range n =
; ENCODER_BEND_RANGE (none when 0); else passes the curve value through.  PanelAction_PitchBend splits the byte
; into a 14-bit bend.
; Input: A = raw encoder value
; Output: HL = processed MIDI CC value, or 0xffff if unchanged
Encoder_ProcessPitchBend:
	ldw hl, 0xffff	; Default return = no change
	cpl a	; Invert input
	ld (ENCODER_RAW_PITCHBEND:16), a; Store raw value
	extz wa
	lda xbc, (ENCODER_LUT_PITCHBEND:24); Lookup table
	ld	a, (xbc+wa)	; Get processed value
	ld c, (CMP_RECORD_PART:16); Get system mode flags
	and c, 0xf	; Mask relevant bits
	jr nz, Encoder_ProcessPitchBend_ScaleToBendRange	; If mode active, process
	cp (0x7f0b:16), 0; Check alternate condition
	jr z, Encoder_ProcessPitchBend_Passthrough	; Simple processing if clear

Encoder_ProcessPitchBend_ScaleToBendRange:
	ld c, (ENCODER_BEND_RANGE:16); bend range
	cp c, 0:i3
	ret z	; Return if disabled
	srl a, 1	; Divide by 2
	ld l, a
	extz hl
	dec 1, c	; Decrement mode for index
	extz bc
	add bc, bc	; Word index
	lda xwa, (ENCODER_LUT_BEND_RANGE_MULT:24); Multiplier table
	ld	de, (xwa+bc)	; Get multiplier
	mul xhl, de	; Multiply
	lda xwa, (ENCODER_LUT_BEND_RANGE_OFFSET:24); Offset table
	ld	wa, (xwa+bc)	; Get offset
	sub hl, wa	; Subtract offset
	add hl, 0x4080	; Add center offset
	srl hl, 8	; Divide by 256
	add hl, hl	; Double
	ld a, l
	ld (ANALOG_PITCHBEND_VALUE:16), a; Store result
	jr Encoder_ProcessPitchBend_Return

Encoder_ProcessPitchBend_Passthrough:
	cp (ANALOG_PITCHBEND_VALUE:16), a	; Compare with current
	ret z	; Return if unchanged
	ld (ANALOG_PITCHBEND_VALUE:16), a; Store new value
	ld l, a
	extz hl

Encoder_ProcessPitchBend_Return:
	ret
Encoder_ProcessPitchBend_End:

; Encoder_ProcessModulation - Modulation wheel (CPL AD2, frame 0xD2, ID 26)
; Input: A = raw encoder value
; Output: HL = processed MIDI CC value, or 0xffff if unchanged
Encoder_ProcessModulation:
	ldw hl, 0xffff	; Default return = no change
	ld (ENCODER_RAW_MODULATION:16), a; Store raw value
	srl a, 1	; Divide by 2
	extz wa
	lda xbc, (ENCODER_LUT_MODULATION:24); Lookup table
	ld	a, (xbc+wa)	; Get processed value
	ld c, (ANALOG_MODULATION_VALUE:16); Get current value
	res 7, c	; Clear change flag
	cp c, a	; Compare
	ret z	; Return if unchanged
	ld (ANALOG_MODULATION_VALUE:16), a; Store new value
	ld l, a
	extz hl	; Return value in HL
	ret
Encoder_ProcessModulation_End:

; Encoder_ProcessMainVolume - MAIN VOLUME slider (CPL AD3, VR1, frame 0xD3, ID 27)
; Input: A = raw encoder value
; Output: HL = processed MIDI CC value (always returns value, no skip)
Encoder_ProcessMainVolume:
	cpl a	; Invert input
	ld c, a
	ld (ENCODER_RAW_MAIN_VOLUME:16), c; Store raw value
	srl a, 1	; Divide by 2
	extz wa
	lda xbc, (ENCODER_LUT_MAIN_VOLUME:24); Lookup table
	ld	a, (xbc+wa)	; Get processed value
	ld (ANALOG_MAIN_VOLUME_VALUE:16), a; Store value
	extz wa
	ld hl, wa	; Return value in HL
	ret
Encoder_ProcessMainVolume_End:

; Encoder_PassthroughIdentity - Simple passthrough: returns input value in HL
; Input: A = value
; Output: HL = value
Encoder_PassthroughIdentity:
	ld l, a
	extz hl
	ret
Encoder_PassthroughIdentity_End:

; Encoder_ReturnDefaultConstant - Returns constant 1
; Output: HL = 1
Encoder_ReturnDefaultConstant:
	ld hl, 1:i3
	ret
Encoder_ReturnDefaultConstant_End:

; Encoder_OnTouchSensitivityChange - Record 0x93 listener: bend range, after-touch curve/threshold
; Listener of record 0x93 (OVERALL TOUCH SENSITIVITY) in SwbtB2_Code93_Listeners: SWBTWR_PAYLOAD_1 = byte
; offset, _2 = new value, _3 = changed bits.  +4 bits 0-3 -> ENCODER_BEND_RANGE, +5 -> ENCODER_AFTERTOUCH_CURVE,
; +6 bits 0-6 -> ENCODER_AFTERTOUCH_THRESHOLD.
Encoder_OnTouchSensitivityChange:
	ld a, (SWBTWR_PAYLOAD_1:16); Get mode selector
	cp a, 6:i3
	jr z, Encoder_SetAfterTouchThreshold	; Jump if mode 6
	cp a, 5:i3
	jr z, Encoder_SetAfterTouchCurve	; Jump if mode 5
	cp a, 4:i3
	ret nz	; Return if not mode 4
	; byte +4: bend range
	ld a, (SWBTWR_PAYLOAD_3:16)
	and a, 0xf	; Mask low nibble
	ret z	; Return if zero
	ld a, (SWBTWR_PAYLOAD_2:16)
	and a, 0xf	; Mask low nibble
	ld (ENCODER_BEND_RANGE:16), a; bend range
	ret

Encoder_SetAfterTouchCurve:
	ld a, (SWBTWR_PAYLOAD_3:16)
	and a, 0xff	; Full byte check
	ret z	; Return if zero
	ld a, (SWBTWR_PAYLOAD_2:16)
	and a, 0xff	; Full byte
	ld (ENCODER_AFTERTOUCH_CURVE:16), a; Set volume mode
	ret

Encoder_SetAfterTouchThreshold:
	ld a, (SWBTWR_PAYLOAD_3:16)
	res 7, a	; Clear bit 7
	cp a, 0:i3
	ret z	; Return if zero
	ld a, (SWBTWR_PAYLOAD_2:16)
	res 7, a	; Clear bit 7
	ld (ENCODER_AFTERTOUCH_THRESHOLD:16), a; Set range limit
	ret

; End of MIDI encoder routines
