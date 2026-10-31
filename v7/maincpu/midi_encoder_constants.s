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

.equ ANALOG_EXPRESSION_PEDAL_PENDING, 0x8e44	; last expression-pedal value sent, bit 7 = send pending	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8ee0
.equ ANALOG_MAIN_VOLUME_PENDING, 0x8e46	; last MAIN VOLUME value sent, bit 7 = send pending	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8ee2
.equ ANALOG_EXPRESSION_PEDAL_VALUE, 0x8e48	; expression pedal (CPU AN0, Encoder_ProcessExpressionPedal), 0..127	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8ee4
.equ ANALOG_MAIN_VOLUME_VALUE, 0x8e4a	; MAIN VOLUME (CPL AD3, id 27, Encoder_ProcessMainVolume), 0..127	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8ee6
.equ ANALOG_PITCHBEND_VALUE, 0x8e4c	; pitch bend wheel (CPL AD1, id 25, Encoder_ProcessPitchBend), 0..255, centre 0x80	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8ee8
.equ ANALOG_MODULATION_VALUE, 0x8e4e	; modulation wheel (CPL AD2, id 26, Encoder_ProcessModulation), 0..127	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8eea
.equ ANALOG_AFTERTOUCH_VALUE, 0x8e58	; after touch (CPU AN1, Encoder_ProcessAfterTouch), 0..127	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8ef4

; =============================================================================
; Encoder Raw Input Storage (RAM at 0x8exxh)
; =============================================================================
; Raw A/D values before the curve tables (~ = stored inverted)

.equ ENCODER_RAW_EXPRESSION_PEDAL, 0x8e2e	; ~ADREG04 high byte (CPU AN0, expression pedal)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8eca
.equ ENCODER_RAW_AFTERTOUCH, 0x8e30	; ADREG15 high byte (CPU AN1, after touch)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8ecc
.equ ENCODER_RAW_PITCHBEND, 0x8e38	; ~raw byte of CPL frame 0xD1 (AD1, pitch bend wheel)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8ed4
.equ ENCODER_RAW_MODULATION, 0x8e3a	; raw byte of CPL frame 0xD2 (AD2, modulation wheel)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8ed6
.equ ENCODER_RAW_MAIN_VOLUME, 0x8e3c	; ~raw byte of CPL frame 0xD3 (AD3, MAIN VOLUME VR1)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8ed8

; =============================================================================
; Encoder Configuration/Mode Values (RAM at 0x8exxh)
; =============================================================================
; Configuration values that control encoder behavior

.equ ENCODER_BEND_RANGE, 0x8e3e	; record 0x93 byte +4 bits 0-3 (Encoder_OnTouchSensitivityChange): 0 = bend off while recording, 1..12 = semitones	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8eda
.equ ENCODER_AFTERTOUCH_CURVE, 0x8e40	; record 0x93 byte +5, AFTER TOUCH curve (SndParam_AfterTouch_Curve, 1..10)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8edc
.equ ENCODER_AFTERTOUCH_THRESHOLD, 0x8e42	; record 0x93 byte +6 bits 0-6, AFTER TOUCH threshold (SndParam_AfterTouch_Threshold)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8ede

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

.equ ADC_AN0_LAST_VALUE, 0x8e60	; last accepted ADREG04 high byte (expression pedal)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8efc
.equ ADC_AN1_LAST_VALUE, 0x8e62	; last accepted ADREG15 high byte (after touch)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8efe
.equ ADC_AN0_STATUS, 0x8e68	; AN0 debounce state (AnalogIn_DebounceChange): bits 0-1 count, bit 2 pending, bit 3 accepted	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8f04
.equ ADC_AN1_STATUS, 0x8e6a	; AN1 debounce state, as ADC_AN0_STATUS	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8f06
.equ ADC_AN0_OUTPUT, 0x8e74	; expression-pedal value + flags (bit 7 of +1 = queue event 26)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8f10
.equ ADC_AN1_OUTPUT, 0x8e7a	; after-touch value + flags (bit 7 of +1 = queue event 27)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8f16
.equ CPANEL_LED_IMAGE, 0x8e7c	; 16 B: wanted pattern of LED rows 0..14 (Protocol_values_for_LED_rows order)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8f18
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
.equ RHYTHM_ROM_BASE, 0x31db
