; =============================================================================
; midi_encoder_constants.asm - MIDI and Encoder Constants for Main CPU
; =============================================================================
; This file contains all MIDI controller and encoder-related constants,
; including RAM addresses for controller values and ROM addresses for
; lookup tables.
;
; The KN5000 uses analog encoders (modwheel, volume slider, breath, foot,
; expression) that are converted to MIDI CC values via lookup tables.
;
; Contents:
;   - MIDI CC value storage addresses (RAM)
;   - Raw encoder input storage (RAM)
;   - Encoder configuration variables (RAM)
;   - Encoder lookup tables (ROM addresses)
;   - Encoder state tracking (RAM)
;   - Encoder handler jump table (ROM address)
; =============================================================================

; =============================================================================
; Analog controller values (RAM at 0x8exxh)
; =============================================================================
; One byte per analog control after its curve.  The *_PENDING bytes hold the last value sent, bit 7
; set while a send is pending.  Physical controls from the service manual: CPL board M37471 AD1 =
; BEND, AD2 = MOD, AD3 = MAIN VOLUME (frames 0xD1/0xD2/0xD3 = ids 25/26/27); main CPU AN0 = EXP
; (expression pedal jack), AN1 = AFT (after-touch sensor).

.equ ANALOG_EXPRESSION_PEDAL_PENDING, 0x8e20	; last expression-pedal value sent, bit 7 = send pending	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ee0	; v7: 0x8e44
.equ ANALOG_MAIN_VOLUME_PENDING, 0x8e22	; last MAIN VOLUME value sent, bit 7 = send pending	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ee2	; v7: 0x8e46
.equ ANALOG_EXPRESSION_PEDAL_VALUE, 0x8e24	; expression pedal (CPU AN0, Encoder_ProcessExpressionPedal), 0..127	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ee4	; v7: 0x8e48
.equ ANALOG_MAIN_VOLUME_VALUE, 0x8e26	; MAIN VOLUME (CPL AD3, id 27, Encoder_ProcessMainVolume), 0..127	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ee6	; v7: 0x8e4a
.equ ANALOG_PITCHBEND_VALUE, 0x8e28	; pitch bend wheel (CPL AD1, id 25, Encoder_ProcessPitchBend), 0..255, centre 0x80	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ee8	; v7: 0x8e4c
.equ ANALOG_MODULATION_VALUE, 0x8e2a	; modulation wheel (CPL AD2, id 26, Encoder_ProcessModulation), 0..127	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8eea	; v7: 0x8e4e
.equ ANALOG_AFTERTOUCH_VALUE, 0x8e34	; after touch (CPU AN1, Encoder_ProcessAfterTouch), 0..127	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ef4	; v7: 0x8e58

; =============================================================================
; Encoder Raw Input Storage (RAM at 0x8exxh)
; =============================================================================
; Raw A/D values before the curve tables (~ = stored inverted)

.equ ENCODER_RAW_EXPRESSION_PEDAL, 0x8e0a	; ~ADREG04 high byte (CPU AN0, expression pedal)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8eca	; v7: 0x8e2e
.equ ENCODER_RAW_AFTERTOUCH, 0x8e0c	; ADREG15 high byte (CPU AN1, after touch)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ecc	; v7: 0x8e30
.equ ENCODER_RAW_PITCHBEND, 0x8e14	; ~raw byte of CPL frame 0xD1 (AD1, pitch bend wheel)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ed4	; v7: 0x8e38
.equ ENCODER_RAW_MODULATION, 0x8e16	; raw byte of CPL frame 0xD2 (AD2, modulation wheel)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ed6	; v7: 0x8e3a
.equ ENCODER_RAW_MAIN_VOLUME, 0x8e18	; ~raw byte of CPL frame 0xD3 (AD3, MAIN VOLUME VR1)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ed8	; v7: 0x8e3c

; =============================================================================
; Encoder Configuration/Mode Values (RAM at 0x8exxh)
; =============================================================================
; Configuration values that control encoder behavior

.equ ENCODER_BEND_RANGE, 0x8e1a	; record 0x93 byte +4 bits 0-3 (Encoder_OnTouchSensitivityChange): 0 = bend off while recording, 1..12 = semitones	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8eda	; v7: 0x8e3e
.equ ENCODER_AFTERTOUCH_CURVE, 0x8e1c	; record 0x93 byte +5, AFTER TOUCH curve (SndParam_AfterTouch_Curve, 1..10)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8edc	; v7: 0x8e40
.equ ENCODER_AFTERTOUCH_THRESHOLD, 0x8e1e	; record 0x93 byte +6 bits 0-6, AFTER TOUCH threshold (SndParam_AfterTouch_Threshold)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ede	; v7: 0x8e42

; =============================================================================
; Encoder Lookup Tables (ROM at 0xedaxxxh)
; =============================================================================
; These tables convert raw encoder values to MIDI CC values.
; Each table is 128 bytes (one entry per raw value 0-127).

	; (EQU->inline label) ENCODER_LUT_EXPRESSION_PEDAL = 0xeda13c
	; (EQU->inline label) ENCODER_LUT_AFTERTOUCH = 0xeda1bc
	; (EQU->inline label) ENCODER_LUT_AFTERTOUCH_CURVE_MULT = 0xeda2bc
	; (EQU->inline label) ENCODER_LUT_PITCHBEND = 0xeda2d2
	; (EQU->inline label) ENCODER_LUT_BEND_RANGE_MULT = 0xeda3d2
	; (EQU->inline label) ENCODER_LUT_BEND_RANGE_OFFSET = 0xeda3ea
	; (EQU->inline label) ENCODER_LUT_MODULATION = 0xeda402
	; (EQU->inline label) ENCODER_LUT_MAIN_VOLUME = 0xeda482

; =============================================================================
; Encoder State Tracking (RAM at 0x8fxxh)
; =============================================================================
; Variables for tracking encoder state changes

.equ ADC_AN0_LAST_VALUE, 0x8e3c	; last accepted ADREG04 high byte (expression pedal)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8efc	; v7: 0x8e60
.equ ADC_AN1_LAST_VALUE, 0x8e3e	; last accepted ADREG15 high byte (after touch)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8efe	; v7: 0x8e62
.equ ADC_AN0_STATUS, 0x8e44	; AN0 debounce state (AnalogIn_DebounceChange): bits 0-1 count, bit 2 pending, bit 3 accepted	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8f04	; v7: 0x8e68
.equ ADC_AN1_STATUS, 0x8e46	; AN1 debounce state, as ADC_AN0_STATUS	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8f06	; v7: 0x8e6a
.equ ADC_AN0_OUTPUT, 0x8e50	; expression-pedal value + flags (bit 7 of +1 = queue event 26)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8f10	; v7: 0x8e74
.equ ADC_AN1_OUTPUT, 0x8e56	; after-touch value + flags (bit 7 of +1 = queue event 27)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8f16	; v7: 0x8e7a
.equ CPANEL_LED_IMAGE, 0x8e58	; 16 B: wanted pattern of LED rows 0..14 (Protocol_values_for_LED_rows order)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8f18	; v7: 0x8e7c
.equ CPANEL_LED_IMAGE_SENT, CPANEL_LED_IMAGE + 0x10	; 16 B: rows as last sent (CPanel_LED_FlushImage)

; =============================================================================
; Encoder Handler Jump Table (ROM at 0xeda0bch)
; =============================================================================
; Jump table for encoder-specific value processing routines.
; Indexed by 5-bit encoder ID (0-31). Each entry is a 32-bit address.
; See ENCODER_HANDLER_TABLE_DATA in main source for the actual table contents.

	; (EQU->inline label) ENCODER_HANDLER_TABLE = 0xeda0bc

; End of MIDI/Encoder constants

; Rhythm Data ROM (IC14, at 0x400000) status/base, 32-bit: RhythmROM_ValidateHeader stores 0
; when the ROM starts with its 12-byte signature (00 01 04 05 83 00 01 04 05 83 00 01) and
; 0xffffffff when not (RhythmROM_CheckValid tests that); the rhythm readers add it to
; 0x400000 + a RhythmROM_BankProgramLocators offset.
.equ RHYTHM_ROM_BASE, 0x31bf	; v7: 0x31db
