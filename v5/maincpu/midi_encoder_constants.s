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
; MIDI Controller Values (RAM at 0x8exxh)
; =============================================================================
; These store the current MIDI CC values. Bit 7 is used as a "pending change"
; flag for active sensing / change detection.

.equ TOTAL_EXPRESSION_PENDING, 0x8e20	; Modulation value with change flag (bit 7)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ee0	; v7: 0x8e44
.equ MAIN_VOLUME_PENDING, 0x8e22	; Expression value with change flag (bit 7)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ee2	; v7: 0x8e46
.equ EXPRESSION_PEDAL_VALUE, 0x8e24	; Current modulation wheel value (CC#1)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ee4	; v7: 0x8e48
.equ MAIN_VOLUME_VALUE, 0x8e26	; Current expression value (CC#0)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ee6	; v7: 0x8e4a
.equ PITCH_BEND_VALUE, 0x8e28	; Breath controller value (CC#2?)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ee8	; v7: 0x8e4c
.equ MODULATION_VALUE, 0x8e2a	; Foot controller value (CC#4?)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8eea	; v7: 0x8e4e
.equ AFTERTOUCH_VALUE, 0x8e34	; Volume controller value	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ef4	; v7: 0x8e58

; =============================================================================
; Encoder Raw Input Storage (RAM at 0x8exxh)
; =============================================================================
; Raw ADC values from encoders before lookup table processing

.equ ENCODER_RAW_EXPRESSION_PEDAL, 0x8e0a	; Raw modulation wheel input	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8eca	; v7: 0x8e2e
.equ ENCODER_RAW_AFTERTOUCH, 0x8e0c	; Raw volume input	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ecc	; v7: 0x8e30
.equ ENCODER_RAW_PITCH_BEND, 0x8e14	; Raw breath controller input	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ed4	; v7: 0x8e38
.equ ENCODER_RAW_MODULATION, 0x8e16	; Raw foot controller input	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ed6	; v7: 0x8e3a
.equ ENCODER_RAW_MAIN_VOLUME, 0x8e18	; Raw expression input	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ed8	; v7: 0x8e3c

; =============================================================================
; Encoder Configuration/Mode Values (RAM at 0x8exxh)
; =============================================================================
; Configuration values that control encoder behavior

.equ COMPOSER_BEND_RANGE, 0x8e1a	; Breath controller mode/enable	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8eda	; v7: 0x8e3e
.equ AFTERTOUCH_CURVE, 0x8e1c	; Volume mode value	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8edc	; v7: 0x8e40
.equ AFTERTOUCH_THRESHOLD, 0x8e1e	; Encoder range limit value	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8ede	; v7: 0x8e42

; =============================================================================
; Encoder Lookup Tables (ROM at 0xedaxxxh)
; =============================================================================
; These tables convert raw encoder values to MIDI CC values.
; Each table is 128 bytes (one entry per raw value 0-127).

	; (EQU->inline label) ENCODER_LUT_EXPRESSION_PEDAL = 0xeda13c
	; (EQU->inline label) ENCODER_LUT_AFTERTOUCH = 0xeda1bc
	; (EQU->inline label) ENCODER_LUT_AFTERTOUCH_CURVE = 0xeda2bc
	; (EQU->inline label) ENCODER_LUT_PITCH_BEND = 0xeda2d2
	; (EQU->inline label) ENCODER_LUT_BEND_RANGE_MULT = 0xeda3d2
	; (EQU->inline label) ENCODER_LUT_BEND_RANGE_OFFSET = 0xeda3ea
	; (EQU->inline label) ENCODER_LUT_MODULATION = 0xeda402
	; (EQU->inline label) ENCODER_LUT_MAIN_VOLUME = 0xeda482

; =============================================================================
; Encoder State Tracking (RAM at 0x8fxxh)
; =============================================================================
; Variables for tracking encoder state changes

.equ ENCODER_0_LAST_VALUE, 0x8e3c	; Previous encoder 0 reading (for delta)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8efc	; v7: 0x8e60
.equ ENCODER_1_LAST_VALUE, 0x8e3e	; Previous encoder 1 reading (for delta)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8efe	; v7: 0x8e62
.equ ENCODER_0_STATUS, 0x8e44	; Encoder 0 status flags (bit 3 = changed)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8f04	; v7: 0x8e68
.equ ENCODER_1_STATUS, 0x8e46	; Encoder 1 status flags (bit 3 = changed)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8f06	; v7: 0x8e6a
.equ ENCODER_0_OUTPUT, 0x8e50	; Encoder 0 output buffer (2 bytes: value + flags)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8f10	; v7: 0x8e74
.equ ENCODER_1_OUTPUT, 0x8e56	; Encoder 1 output buffer (2 bytes: value + flags)	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8f16	; v7: 0x8e7a
.equ PANEL_LED_IMAGE, 0x8e58	; Base of encoder state structure	; v6 address, from the v6 code's uses (port_maincpu_version.py); was a copy of v10's 0x8f18	; v7: 0x8e7c

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
