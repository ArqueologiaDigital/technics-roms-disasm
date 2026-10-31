; =============================================================================
; midi_encoder_routines.asm - MIDI Encoder Processing Routines
; =============================================================================
; This file contains the encoder dispatch and MIDI CC value processing
; routines for the KN5000 Main CPU.
;
; The encoder system works as follows:
; 1. Raw ADC values come from analog controllers (modwheel, volume, etc.)
; 2. CPanel_EncoderDispatch routes to encoder-specific handlers
; 3. Each handler uses lookup tables to convert raw -> MIDI CC values
; 4. Processed values are stored in MIDI_CC_*_VALUE variables
;
; Routines:
;   CPanel_EncoderDispatch    - Dispatch to encoder-specific handler
;   Encoder_ProcessExpressionPedal   - Process modulation wheel (ID 2)
;   Encoder_ProcessAfterTouch     - Process volume slider (ID 5)
;   Encoder_ClampScaleAndNormalize      - Clamp value to configured range
;   Encoder_ProcessPitchBend     - Process breath controller (ID 25)
;   Encoder_ProcessModulation       - Process foot controller (ID 26)
;   Encoder_ProcessMainVolume - Process expression (ID 27)
;   Encoder_PassthroughIdentity       - Simple passthrough (ID 31)
;   Encoder_ReturnDefaultConstant         - Return constant 1 (default/unused)
;   Encoder_TouchSettingsListener        - Select processing mode based on system state
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

; Encoder_ProcessExpressionPedal - Process modulation wheel input (Encoder ID 2)
; Input: A = raw encoder value
; Output: HL = processed MIDI CC value, or 0xffff if unchanged
; Encoder_ProcessExpressionPedal: Analog ID 2, which only the main CPU's own A/D channel 0 produces
;   (MidiParam_ProcessChannel0 / MidiParam_ForceResync pass BC = 2; no panel header maps to it): the expression pedal.
;   Inverts the raw byte, maps (~raw) >> 1 through ENCODER_LUT_EXPRESSION_PEDAL into EXPRESSION_PEDAL_VALUE (EXPRESSION_PEDAL_VALUE); HL = the
;   value, or 0xFFFF if unchanged. Basis: callers + readers of its output.
Encoder_ProcessExpressionPedal:
	ldw hl, 0xffff	; Default return = no change
	cpl a	; Invert input value
	ld c, a
	ld (ENCODER_RAW_EXPRESSION_PEDAL:16), c; Store raw value
	srl a, 1	; Divide by 2
	extz wa
	lda xbc, (ENCODER_LUT_EXPRESSION_PEDAL:24); Lookup table address
	ld	a, (xbc+wa)	; Get processed value from table
	ld c, (EXPRESSION_PEDAL_VALUE:16); Get current value
	res 7, c	; Clear change flag
	cp c, a	; Compare with new value
	ret z	; Return if unchanged
	ld (EXPRESSION_PEDAL_VALUE:16), a; Store new value
	ld l, a
	extz hl	; Return value in HL
	ret
Encoder_ProcessExpressionPedal_End:

; Encoder_ProcessAfterTouch - Process volume/expression slider (Encoder ID 5)
; Input: A = raw encoder value
; Output: HL = processed MIDI CC value, or 0xffff if unchanged
; Encoder_ProcessAfterTouch: Analog ID 5, produced only by the main CPU's A/D channel 1 (MidiParam_ProcessChannel1, BC
;   = 5): the after-touch sensor. Maps the raw byte through ENCODER_LUT_AFTERTOUCH, applies the AFTER TOUCH threshold and
;   curve (Encoder_ClampScaleAndNormalize) and stores AFTERTOUCH_VALUE (AFTERTOUCH_VALUE); HL = the value or 0xFFFF. Basis:
;   callers + readers of its output.
Encoder_ProcessAfterTouch:
	pushw iz
	ldw iz, 0xffff	; Default return = no change
	ld (ENCODER_RAW_AFTERTOUCH:16), a; Store raw value
	extz wa
	lda xbc, (ENCODER_LUT_AFTERTOUCH:24); Lookup table address
	ld	a, (xbc+wa)	; Get processed value
	calr Encoder_ClampScaleAndNormalize	; Clamp to valid range
	ld a, l
	cp a, (AFTERTOUCH_VALUE:16)	; Compare with current
	jr z, Encoder_ProcessAfterTouch_NoChange
	ld (AFTERTOUCH_VALUE:16), a; Store new value
	ldfr_berp A, 0xf8
	extz iz	; IZ = new value

Encoder_ProcessAfterTouch_NoChange:
	ld hl, iz	; Return value in HL
	popw iz
	ret

; Encoder_ClampScaleAndNormalize - Clamp value L to minimum in AFTERTOUCH_THRESHOLD
; Input: L = value to clamp, A = raw lookup value
; Output: HL = clamped and scaled value
Encoder_ClampScaleAndNormalize:
	ld l, a
	ld c, (AFTERTOUCH_THRESHOLD:16); Get minimum limit
	cp l, c	; Compare with limit
	jr nc, Encoder_PerformScaling	; Skip if >= limit
	ld l, c	; Clamp to minimum

Encoder_PerformScaling:
	sub l, c	; Subtract minimum
	ld h, 0x0:opc
	extz xhl
	sll xhl, 8	; Scale up (multiply by 256)
	ld xwa, xhl
	ld xbc, 0xec	; Divisor
	call Math_DivideU32	; Division routine
	ld a, (AFTERTOUCH_CURVE:16); Get mode value
	extz wa
	add wa, wa	; Double for word table index
	lda xbc, (ENCODER_LUT_AFTERTOUCH_CURVE:24); Index table
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
Encoder_ClampScaleAndNormalize_End:

; Encoder_ProcessPitchBend - Process breath controller input
; Input: A = raw encoder value
; Output: HL = processed MIDI CC value, or 0xffff if unchanged
; Encoder_ProcessPitchBend: Analog ID 25 = left-panel header 0xD1, the pitch-bend wheel: inverts the raw byte, maps it
;   through ENCODER_LUT_PITCH_BEND (flat 0x80 centre) and stores PITCH_BEND_VALUE (PITCH_BEND_VALUE) -- directly, or, when
;   (CMP_RECORD_PART) & 0x0F or (0x7F0B) is non-zero, narrowed to COMPOSER_BEND_RANGE / 12 around the centre (0 = no event). HL
;   = the value or 0xFFFF. Basis: header map + readers of its output.
Encoder_ProcessPitchBend:
	ldw hl, 0xffff	; Default return = no change
	cpl a	; Invert input
	ld (ENCODER_RAW_PITCH_BEND:16), a; Store raw value
	extz wa
	lda xbc, (ENCODER_LUT_PITCH_BEND:24); Lookup table
	ld	a, (xbc+wa)	; Get processed value
	ld c, (CMP_RECORD_PART:16); Get system mode flags
	and c, 0xf	; Mask relevant bits
	jr nz, Encoder_ProcessPitchBend_Scaled	; If mode active, process
	cp (0x7f0b:16), 0; Check alternate condition
	jr z, Encoder_ProcessPitchBend_Direct	; Simple processing if clear

Encoder_ProcessPitchBend_Scaled:
	ld c, (COMPOSER_BEND_RANGE:16); Get breath mode
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
	ld (PITCH_BEND_VALUE:16), a; Store result
	jr Encoder_ProcessPitchBend_Return

Encoder_ProcessPitchBend_Direct:
	cp (PITCH_BEND_VALUE:16), a	; Compare with current
	ret z	; Return if unchanged
	ld (PITCH_BEND_VALUE:16), a; Store new value
	ld l, a
	extz hl

Encoder_ProcessPitchBend_Return:
	ret
Encoder_ProcessPitchBend_End:

; Encoder_ProcessModulation - Process foot controller input
; Input: A = raw encoder value
; Output: HL = processed MIDI CC value, or 0xffff if unchanged
; Encoder_ProcessModulation: Analog ID 26 = left-panel header 0xD2, the modulation wheel: maps raw >> 1 through
;   ENCODER_LUT_MODULATION into MODULATION_VALUE (MODULATION_VALUE); HL = the value or 0xFFFF if unchanged. Basis: header map +
;   readers of its output.
Encoder_ProcessModulation:
	ldw hl, 0xffff	; Default return = no change
	ld (ENCODER_RAW_MODULATION:16), a; Store raw value
	srl a, 1	; Divide by 2
	extz wa
	lda xbc, (ENCODER_LUT_MODULATION:24); Lookup table
	ld	a, (xbc+wa)	; Get processed value
	ld c, (MODULATION_VALUE:16); Get current value
	res 7, c	; Clear change flag
	cp c, a	; Compare
	ret z	; Return if unchanged
	ld (MODULATION_VALUE:16), a; Store new value
	ld l, a
	extz hl	; Return value in HL
	ret
Encoder_ProcessModulation_End:

; Encoder_ProcessMainVolume - Process expression controller input
; Input: A = raw encoder value
; Output: HL = processed MIDI CC value (always returns value, no skip)
; Encoder_ProcessMainVolume: Analog ID 27 = left-panel header 0xD3, the MAIN VOLUME slider: inverts the raw byte, maps
;   (~raw) >> 1 through ENCODER_LUT_MAIN_VOLUME into MAIN_VOLUME_VALUE (MAIN_VOLUME_VALUE) and always returns it in HL. Basis:
;   header map + readers of its output (identity as MAIN_VOLUME_VALUE).
Encoder_ProcessMainVolume:
	cpl a	; Invert input
	ld c, a
	ld (ENCODER_RAW_MAIN_VOLUME:16), c; Store raw value
	srl a, 1	; Divide by 2
	extz wa
	lda xbc, (ENCODER_LUT_MAIN_VOLUME:24); Lookup table
	ld	a, (xbc+wa)	; Get processed value
	ld (MAIN_VOLUME_VALUE:16), a; Store value
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

; Encoder_TouchSettingsListener - Select processing mode based on system state
; Reads mode value from 0xc07d and configures encoder processing accordingly
; Encoder_TouchSettingsListener: Listener of record 0x93 (OVERALL TOUCH SENSITIVITY): copies byte 4 low nibble (key
;   0x28403, the Composer bend range) to COMPOSER_BEND_RANGE, byte 5 (0x102 AFTER TOUCH curve) to AFTERTOUCH_CURVE and
;   byte 6 bits 0-6 (0x103 threshold) to AFTERTOUCH_THRESHOLD when their bits changed. Basis: listener table + body.
Encoder_TouchSettingsListener:
	ld a, (SWBTWR_PAYLOAD_1:16); Get mode selector
	cp a, 6:i3
	jr z, Encoder_TouchSettingsListener_Threshold	; Jump if mode 6
	cp a, 5:i3
	jr z, Encoder_TouchSettingsListener_Curve	; Jump if mode 5
	cp a, 4:i3
	ret nz	; Return if not mode 4
	; Mode 4: Configure breath mode
	ld a, (SWBTWR_PAYLOAD_3:16)
	and a, 0xf	; Mask low nibble
	ret z	; Return if zero
	ld a, (SWBTWR_PAYLOAD_2:16)
	and a, 0xf	; Mask low nibble
	ld (COMPOSER_BEND_RANGE:16), a; Set breath mode
	ret

Encoder_TouchSettingsListener_Curve:
	ld a, (SWBTWR_PAYLOAD_3:16)
	and a, 0xff	; Full byte check
	ret z	; Return if zero
	ld a, (SWBTWR_PAYLOAD_2:16)
	and a, 0xff	; Full byte
	ld (AFTERTOUCH_CURVE:16), a; Set volume mode
	ret

Encoder_TouchSettingsListener_Threshold:
	ld a, (SWBTWR_PAYLOAD_3:16)
	res 7, a	; Clear bit 7
	cp a, 0:i3
	ret z	; Return if zero
	ld a, (SWBTWR_PAYLOAD_2:16)
	res 7, a	; Clear bit 7
	ld (AFTERTOUCH_THRESHOLD:16), a; Set range limit
	ret

; End of MIDI encoder routines
