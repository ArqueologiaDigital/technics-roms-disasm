; ===========================================================================
; Voice_Calc_LevelPair_* -- the three-pair ENVELOPE writers.
; ===========================================================================
; These four routines (_PatchAtk 0x025636, _FixedAtk 0x025A35, _Full 0x025C87,
; _Mono 0x025F7F) were named Voice_ComputeAndWritePan / Voice_UpdatePan_*.
; Nothing in them computes a left/right balance.  Each builds THREE 16-bit words
; of the form (level << 8) | rate -- rate bit 7 being the "apply now" flag -- from
; the paramA (level,rate) couples (+39,+40), (+41,+42) and (+43,+44), and stores
; them to the shadows 0x0451E4 / 0x0451E6 / 0x0451E8 (TG registers 0x800 / 0x840 /
; 0x880).  That is an envelope-segment layout, which is why the curated symbol
; reference calls the single-pair siblings at 0x0267xx Voice_Calc_LevelPair_EG*.
; _PatchAtk takes its first-pair attack from the patch record, _FixedAtk uses a
; fixed one; _Full adds an oscillator-table branch and _Mono drops the base-pair
; oscillator trim.
;
; WHERE ENVELOPE 1'S SEGMENTS COME FROM. paramA = the u32 at slot+0x17, tonerec = the u32
; at slot+0x23 (both offsets hex; the code writes them as decimal 23 / 35). Targets index a
; DESCENDING attenuation curve (0xFF = silent); rates index Voice_EnvelopeRate_Table
; (0x011963, 0x00..0x7F, so bit 7 is always clear here -- unlike envelopes 2 and 3, whose
; low bytes are signed Detune_ScaleSymmetric outputs).
;
;   TYPE-4 voices -- _PatchAtk (note-on, from Voice_Build_Register_Set 0x02B4E3) and
;   _Full / _Mono (per-tick refresh, from Voice_Release_Type4 0x02BCD6 and its _BranchA):
;     seg 0  target Voice_LevelPair_AttackCurve[clamp(paramA+0x27 + (i8)tonerec[0x6B],
;                   0..0x64)]. _Full's bit-11-clear arm uses (i8)tonerec[0x010C] in place of
;                   tonerec[0x6B]; _Mono adds no trim byte and skips the clamp; _Full's
;                   bit-11-set arm substitutes the fixed byte at 0x0118B3.
;            rate   Voice_EnvelopeRate_Table[paramA+0x28]
;     seg 1  target Voice_EnvelopeLevel_Curve[paramA+0x29]
;            rate   max(4, Voice_EnvelopeRate_Table[paramA+0x2A])
;     seg 2  target Voice_EnvelopeLevel_Curve[paramA+0x2B]
;            rate   Voice_EnvelopeRate_Table[paramA+0x2C]     -- no floor
;     Modulation: key scale PitchBend_Scale(paramA+0x2E, slot+0x0C) on segment 0 and
;     paramA+0x2F on segments 1/2; Pan_ScaleWithVelocity with the control triple
;     paramA+0x30..0x32 and depths paramA+0x33 (seg 0) / paramA+0x34 (segs 1,2); every sum
;     re-clamped 0..0xFF.
;
;   TYPE-1/TYPE-2 voices -- _FixedAtk (from Voice_Init_Type1 0x02C3CC / _Type2 0x02C0B6):
;     seg 0  target Voice_LevelPair_AttackCurve[paramA+0x08], key scale paramA+0x0E
;            rate   the CONSTANT 0x7F -- the "FixedAtk" the name refers to
;     seg 1  target Voice_EnvelopeLevel_Curve[paramA+0x09]
;            rate   max(4, Voice_EnvelopeRate_Table[paramA+0x0A])
;     seg 2  target Voice_EnvelopeLevel_Curve[paramA+0x0B]
;            rate   Voice_EnvelopeRate_Table[paramA+0x0C], or 0 when bit 5 of
;                   (*(slot+0x13))[+0x0D] is clear. The bit-5-SET arm additionally caches
;                   Voice_EnvelopeLevel_Curve[paramA+0x0D] in slot+0x46; the clear arm
;                   zeroes that byte.
;     ★ paramA+0x0A and +0x0C are the very bytes Voice_Level_ComputeTriplet pushes through
;     Detune_ScaleSymmetric as SIGNED values on the type-4 path, while this routine uses them
;     as UNSIGNED rate-table indexes. (The two agree on the level bytes +0x09/+0x0B, which
;     both send through 0x0118FE.) There is no run-time conflict, because the type-1/2 chain calls
;     Voice_Level_ClearAllOutputRegs and never builds envelope 2 or 3, and the two allocation
;     paths (Voice_Allocate_Typed vs Voice_NoteOn_Type3) bind different record kinds to
;     slot+0x17. But it does mean the two readings cannot both describe the same field.
;
; _PatchAtk and _FixedAtk write only 0x0451E4 directly; segments 1 and 2 are cached in
; slot+0x3E / slot+0x40 and pushed to 0x0451E6 / 0x0451E8 by Voice_WriteChPanShift 0x02591D
; / _2 0x025B6F, which may add OR subtract (bit 9 of (*(slot+0x27))[+0x18] selects) the
; signed byte tonerec[0x20] against the RATE field, gated on bit 8 of the same word, and
; re-clamps segment 1's rate to [4..0x7F] and segment 2's to [0..0x7F]. _Full and _Mono
; write all three shadows themselves. The seg-0 word is additionally cached in slot+0x3C.
;
; [INFERENCE] RATE 0 IS SPECIAL, AND THE FIRMWARE GUARDS IT. Voice_EnvelopeRate_Table begins
; {0x00, 0x04, 0x08, 0x0A, ...}: entry 0 is the ONLY entry below 4. So the max(4, ...)
; applied to segment 1 in all four builders, and the [4..0x7F] clamp Voice_WriteChPanShift
; applies to the same field, have exactly one effect between them -- they turn a rate of 0
; into 4 -- while segments 0 and 2 are left free to carry 0. The natural reading is that
; rate 0 means "arrive immediately", harmless on an attack and on a final target but not on
; a segment that has to be heard falling. That is an inference from what the firmware
; AVOIDS, not a measurement: nothing here shows what IC303 does with rate 0, and the
; supporting mute idiom is weaker than it looks -- it pairs rate 0 with bit 7 SET on r0x20
; (0xFF80) and CLEAR on r0x21 (0xFF00), which would be redundant if rate 0 already meant
; "go now". Note also that the per-tick writers do NOT all emit rate 0: only
; Voice_Calc_LevelPair_EGA does; EGB and EGC emit signed Detune_ScaleSymmetric bytes.
Voice_Calc_LevelPair_PatchAtk:	.include "includes/generated/cc900/Voice_Calc_LevelPair_PatchAtk.s"	; C: cc900/voice_envelopes_and_channels_ag_21a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Calc_LevelPair_PatchAtk_SetInvFlag, Voice_Calc_LevelPair_PatchAtk + 52
	.set	Voice_Calc_LevelPair_PatchAtk_ApplyKeyTrack, Voice_Calc_LevelPair_PatchAtk + 60
	.set	Voice_Calc_LevelPair_PatchAtk_NoLFO, Voice_Calc_LevelPair_PatchAtk + 224
	.set	Voice_Calc_LevelPair_PatchAtk_NoOscLFO, Voice_Calc_LevelPair_PatchAtk + 241
	.set	Voice_Calc_LevelPair_PatchAtk_CheckMax, Voice_Calc_LevelPair_PatchAtk + 295
	.set	Voice_Calc_LevelPair_PatchAtk_WriteDSP, Voice_Calc_LevelPair_PatchAtk + 312
	.set	Voice_Calc_LevelPair_PatchAtk_NoModDepth, Voice_Calc_LevelPair_PatchAtk + 539
	.set	Voice_Calc_LevelPair_PatchAtk_NoDepth2, Voice_Calc_LevelPair_PatchAtk + 575
	.set	Voice_Calc_LevelPair_PatchAtk_WriteChans, Voice_Calc_LevelPair_PatchAtk + 648
	.set	Voice_Calc_LevelPair_PatchAtk_ClampDepth, Voice_Calc_LevelPair_PatchAtk + 678

; Emits the per-channel L/R level pair. In: XWA (frame (xsp+6)) = per-voice record.
; Left value starts from (patchrec+32) added to (voice+62 & 0x7F); right value from the same
; signed byte added to (voice+64 & 0x7F). Both clamped (right to 0..0x7F, left to 4..0x7F),
; merged into the cached words voice+62 / voice+64 keeping their high bytes, and stored to
; 0x0451E6 (TG reg 0x840) and 0x0451E8 (TG reg 0x880).
; If the "channel" flag in the frame is set, the right word gets bit 15 forced instead of
; the cached high byte.
Voice_WriteChPanShift:	.include "includes/generated/cc900/Voice_WriteChPanShift.s"	; C: cc900/voice_envelopes_and_channels_q_17a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_WriteChPanShift_AddShift, Voice_WriteChPanShift + 109
	.set	Voice_WriteChPanShift_ClampAndWrite, Voice_WriteChPanShift + 165
	.set	Voice_WriteChPanShift_NoChanFlag, Voice_WriteChPanShift + 209
	.set	Voice_WriteChPanShift_WriteL, Voice_WriteChPanShift + 230
	.set	Voice_WriteChPanShift_Passthrough, Voice_WriteChPanShift + 254
	.set	Voice_WriteChPanShift_Done, Voice_WriteChPanShift + 276

Voice_Calc_LevelPair_FixedAtk:	.include "includes/generated/cc900/Voice_Calc_LevelPair_FixedAtk.s"	; C: cc900/voice_envelopes_and_channels_ax_43b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Calc_LevelPair_FixedAtk_WriteLevel, Voice_Calc_LevelPair_FixedAtk + 105
	.set	Voice_Calc_LevelPair_FixedAtk_WriteChans, Voice_Calc_LevelPair_FixedAtk + 201
	.set	Voice_Calc_LevelPair_FixedAtk_NoChanFlag, Voice_Calc_LevelPair_FixedAtk + 291
	.set	Voice_Calc_LevelPair_FixedAtk_Done, Voice_Calc_LevelPair_FixedAtk + 309

; Second, instruction-identical copy of Voice_WriteChPanShift (0x02591D). Same inputs, same
; outputs (0x0451E6 / 0x0451E8 = TG regs 0x840 / 0x880); it exists so the "full" level path
; can call it with a `calr` in range.
Voice_WriteChPanShift2:	.include "includes/generated/cc900/Voice_WriteChPanShift2.s"	; C: cc900/voice_envelopes_and_channels_q_17a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_WriteChPanShift2_AddShift, Voice_WriteChPanShift2 + 109
	.set	Voice_WriteChPanShift2_ClampAndWrite, Voice_WriteChPanShift2 + 165
	.set	Voice_WriteChPanShift2_NoChanFlag, Voice_WriteChPanShift2 + 209
	.set	Voice_WriteChPanShift2_WriteL, Voice_WriteChPanShift2 + 230
	.set	Voice_WriteChPanShift2_Passthrough, Voice_WriteChPanShift2 + 254
	.set	Voice_WriteChPanShift2_Done, Voice_WriteChPanShift2 + 276

; Full level-pair recomputation for one voice; the body runs past the end of this region
; (to ~0x025F7E). In: XWA = per-voice record. Same shape as Voice_Calc_LevelPair_PatchAtk
; (0x025636) but with an extra oscillator-table branch at 0x025CCB. Ultimately writes
; 0x0451E4 / 0x0451E6 / 0x0451E8 (TG regs 0x800 / 0x840 / 0x880) via Voice_WriteChPanShift2.
Voice_Calc_LevelPair_Full:	.include "includes/generated/cc900/Voice_Calc_LevelPair_Full.s"	; C: cc900/voice_envelopes_and_channels_ag_21a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Calc_LevelPair_Full_SetInvFlag, Voice_Calc_LevelPair_Full + 37
	.set	Voice_Calc_LevelPair_Full_CheckBit11, Voice_Calc_LevelPair_Full + 45
	.set	Voice_Calc_LevelPair_Full_OscTablePath, Voice_Calc_LevelPair_Full + 68
	.set	Voice_Calc_LevelPair_Full_NoDepth, Voice_Calc_LevelPair_Full + 240
	.set	Voice_Calc_LevelPair_Full_NoLFO, Voice_Calc_LevelPair_Full + 257
	.set	Voice_Calc_LevelPair_Full_CheckMax, Voice_Calc_LevelPair_Full + 311
	.set	Voice_Calc_LevelPair_Full_WriteDSP, Voice_Calc_LevelPair_Full + 331
	.set	Voice_Calc_LevelPair_Full_NoModDepth, Voice_Calc_LevelPair_Full + 558
	.set	Voice_Calc_LevelPair_Full_NoDepth2, Voice_Calc_LevelPair_Full + 594
	.set	Voice_Calc_LevelPair_Full_WriteChDepth, Voice_Calc_LevelPair_Full + 667
	.set	Voice_Calc_LevelPair_Full_WriteCh2, Voice_Calc_LevelPair_Full + 697

; Voice_Calc_LevelPair_Mono(XWA = voice-slot record) -- the same three-pair computation as
; Voice_Calc_LevelPair_Full, for the voice type that has no per-oscillator trim on the base
; pair but does have one on pairs 2 and 3. Called from Voice_Release_Type4_BranchA.
;
; Differences from the _Full variant, all verified against the disassembly:
;   * pair 1 level is table_0x011899[paramA+39] with NO tonerec byte added and no
;     0..0x64 clamp before the lookup;
;   * pairs 2 and 3 add the signed tonerec[0x010B] byte to paramA+41 / paramA+43 and
;     clamp to 0..0x64 before the table_0x0118FE lookup;
;   * the modulation term for pairs 2/3 is added to BOTH pairs (the _Full variant adds
;     it to pair 2 and pair 3 separately, without the extra IZ term).
; The result words and their destinations (0x0451E4/E6/E8) are identical.
;
; Its tail labels (0x0261BC..0x026244) used to be named "..._Full2_..."; there is no
; "Full2" routine -- _Full ends at 0x025F7E with its own ret -- so they now carry the
; _Mono prefix they belong to.
Voice_Calc_LevelPair_Mono:
	lda xsp, (xsp - 14)
	push xiz
	ld (xsp + 14), xwa
	ld xwa, (xsp + 14)
	ld xwa, (xwa + 23)
	ld (xsp + 4), xwa
	ld xwa, (xsp + 14)
	ld xwa, (xwa + 19)
	bitm 4, (xwa + 16)
	jr z, Voice_Calc_LevelPair_Mono_SetInvFlag
	ld xwa, (xsp + 14)
	andmi16 (xwa + 1), 0x7FFF
	jr Voice_Calc_LevelPair_Mono_ComputeLevel

; Bit 4 of tonerec-ish record (slot+19)[+16] clear -> set bit 15 of slot+1; set -> clear
; it. Same polarity flag the _Full variant maintains.
Voice_Calc_LevelPair_Mono_SetInvFlag:
	ld xwa, (xsp + 14)
	ormi16 (xwa + 1), 0x8000

; Base level = table_0x011899[paramA+39]; then the LFO / depth modulation chain.
Voice_Calc_LevelPair_Mono_ComputeLevel:
	ld xwa, (xsp + 4)
	ld a, (xwa + 39)
	extz wa
	lda xbc, (Voice_LevelPair_AttackCurve:24)
	ld	a, (xbc+wa)
	extz wa
	ldfr_werp WA, 0xFA
	ld xwa, (xsp + 4)
	cp (xwa + 51), 0x0
	jrl z, Voice_Calc_LevelPair_Mono_NoLFO
	ld xwa, (xsp + 4)
	ld a, (xwa + 48)
	ld c, a
	extz bc
	ld xwa, (xsp + 4)
	ld a, (xwa + 49)
	ld e, a
	extz de
	ld xwa, (xsp + 4)
	ld a, (xwa + 50)
	extz wa
	pushw wa
	ld xwa, (xsp + 6)
	ld a, (xwa + 51)
	exts wa
	pushw wa
	ld xwa, (xsp + 18)
	ld wa, (xwa + 8)
	calr Pan_ScaleWithVelocity
	ld (xsp + 8), hl
	ld xwa, (xsp + 4)
	cp (xwa + 46), 0x0
	jr z, Voice_Calc_LevelPair_Mono_NoDepth
	ld xwa, (xsp + 4)
	ld a, (xwa + 46)
	ld e, a
	exts de
	ld xwa, (xsp + 14)
	ld a, (xwa + 12)
	ld c, a
	extz bc
	ld wa, de
	ld de, 4:i3
	calr PitchBend_Scale
	ld iz, hl
	ldto_werp WA, 0xFA
	add wa, (xsp + 8)
	add wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ldfr_werp HL, 0xFA
	jr Voice_Calc_LevelPair_Mono_CheckMax

; paramA+46 == 0: add only the Pan_ScaleWithVelocity term, clamp 0..0xFF.
Voice_Calc_LevelPair_Mono_NoDepth:
	ldto_werp WA, 0xFA
	add wa, (xsp + 8)
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ldfr_werp HL, 0xFA
	jr Voice_Calc_LevelPair_Mono_CheckMax

; paramA+51 == 0: skip the velocity/LFO scaler entirely.
Voice_Calc_LevelPair_Mono_NoLFO:
	ld xwa, (xsp + 4)
	cp (xwa + 46), 0x0
	jr z, Voice_Calc_LevelPair_Mono_CheckMax
	ld xwa, (xsp + 4)
	ld a, (xwa + 46)
	ld e, a
	exts de
	ld xwa, (xsp + 14)
	ld a, (xwa + 12)
	ld c, a
	extz bc
	ld wa, de
	ld de, 4:i3
	calr PitchBend_Scale
	ld iz, hl
	ldto_werp WA, 0xFA
	add wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ldfr_werp HL, 0xFA

; Same 0xFF reservation as Voice_Calc_LevelPair_Full_CheckMax.
Voice_Calc_LevelPair_Mono_CheckMax:
	ld xwa, (xsp + 14)
	ld xwa, (xwa + 31)
	bitm 0, (xwa)
	jr z, Voice_Calc_LevelPair_Mono_WriteDSP
	ldto_werp WA, 0xFA
	cp wa, 0xFF
	jr nz, Voice_Calc_LevelPair_Mono_WriteDSP
	dec1w_erp 0xFA

; Writes pair 1 to 0x0451E4 and slot+60, then builds pairs 2 and 3 with the tonerec
; [0x010B] trim added before the 0x0118FE lookup.
Voice_Calc_LevelPair_Mono_WriteDSP:
	ld xwa, (xsp + 4)
	ld a, (xwa + 40)
	extz wa
	lda xbc, (Voice_EnvelopeRate_Table:24)
	ld	a, (xbc+wa)
	extz wa
	ld w, 0x0:opc
	ldto_werp BC, 0xFA
	sla bc, 8
	or bc, wa
	ld (Payload_Bss_Start+0x636e:24), bc
	ld xwa, (xsp + 14)
	ld (xwa + 60), bc
	ld xwa, (xsp + 14)
	ld xwa, (xwa + 35)
	ld	a, (xwa+267)
	ld c, a
	exts bc
	ld xwa, (xsp + 4)
	ld a, (xwa + 41)
	extz wa
	add wa, bc
	ldw bc, 0x64
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 10), hl
	ld wa, (xsp + 10)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 10), wa
	ld xwa, (xsp + 14)
	ld xwa, (xwa + 35)
	ld	a, (xwa+267)
	ld c, a
	exts bc
	ld xwa, (xsp + 4)
	ld a, (xwa + 43)
	extz wa
	add wa, bc
	ldw bc, 0x64
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 12), hl
	ld wa, (xsp + 12)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 12), wa
	ld xwa, (xsp + 4)
	cp (xwa + 52), 0x0
	jrl z, Voice_Calc_LevelPair_Mono_NoDepth2
	ld xwa, (xsp + 4)
	ld a, (xwa + 48)
	ld c, a
	extz bc
	ld xwa, (xsp + 4)
	ld a, (xwa + 49)
	ld e, a
	extz de
	ld xwa, (xsp + 4)
	ld a, (xwa + 50)
	extz wa
	pushw wa
	ld xwa, (xsp + 6)
	ld a, (xwa + 52)
	exts wa
	pushw wa
	ld xwa, (xsp + 18)
	ld wa, (xwa + 8)
	calr Pan_ScaleWithVelocity
	ld (xsp + 8), hl
	ld xwa, (xsp + 4)
	cp (xwa + 47), 0x0
	jr z, Voice_Calc_LevelPair_Mono_NoModDepth
	ld xwa, (xsp + 4)
	ld a, (xwa + 47)
	ld e, a
	exts de
	ld xwa, (xsp + 14)
	ld a, (xwa + 12)
	ld c, a
	extz bc
	ld wa, de
	ld de, 4:i3
	calr PitchBend_Scale
	ld iz, hl
	ld wa, (xsp + 10)
	add wa, (xsp + 8)
	add wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 10), hl
	ld wa, (xsp + 12)
	add wa, (xsp + 8)
	add wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 12), hl
	jr Voice_Calc_LevelPair_Mono_WriteChDepth

; Tail of Voice_Calc_LevelPair_Mono: paramA+47 == 0 -> add only the LFO scaler to pairs 2/3.
Voice_Calc_LevelPair_Mono_NoModDepth:
	ld wa, (xsp + 10)
	add wa, (xsp + 8)
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 10), hl
	ld wa, (xsp + 12)
	add wa, (xsp + 8)
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 12), hl
	jr Voice_Calc_LevelPair_Mono_WriteChDepth

; Tail of Voice_Calc_LevelPair_Mono: paramA+52 == 0 -> apply only the paramA+47 depth term.
Voice_Calc_LevelPair_Mono_NoDepth2:
	ld xwa, (xsp + 4)
	cp (xwa + 47), 0x0
	jr z, Voice_Calc_LevelPair_Mono_WriteChDepth
	ld xwa, (xsp + 4)
	ld a, (xwa + 47)
	ld e, a
	exts de
	ld xwa, (xsp + 14)
	ld a, (xwa + 12)
	ld c, a
	extz bc
	ld wa, de
	ld de, 4:i3
	calr PitchBend_Scale
	ld iz, hl
	ld wa, (xsp + 10)
	add wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 10), hl
	ld wa, (xsp + 12)
	add wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 12), hl

; Tail of Voice_Calc_LevelPair_Mono: rate for pair 2, floored at 4.
Voice_Calc_LevelPair_Mono_WriteChDepth:
	ld xwa, (xsp + 4)
	ld a, (xwa + 42)
	extz wa
	lda xbc, (Voice_EnvelopeRate_Table:24)
	ld	a, (xbc+wa)
	extz wa
	ld hl, wa
	ld wa, 4:i3
	cp hl, 4:i3
	jr lt, Voice_Calc_LevelPair_Mono_WriteCh2
	ld wa, hl

; Tail of Voice_Calc_LevelPair_Mono: rate for pair 3; writes 0x0451E6 and 0x0451E8; returns.
Voice_Calc_LevelPair_Mono_WriteCh2:
	ld hl, wa
	ld xwa, (xsp + 4)
	ld a, (xwa + 44)
	extz wa
	lda xbc, (Voice_EnvelopeRate_Table:24)
	ld	a, (xbc+wa)
	extz wa
	ld de, wa
	ld wa, hl
	ld w, 0x0:opc
	ld bc, (xsp + 10)
	sla bc, 8
	or bc, wa
	ld (Payload_Bss_Start+0x6370:24), bc
	ld wa, de
	ld w, 0x0:opc
	ld bc, (xsp + 12)
	sla bc, 8
	or bc, wa
	ld (Payload_Bss_Start+0x6372:24), bc
	pop xiz
	lda xsp, (xsp + 14)
	ret

; Voice_InterpolatePanCurve(XWA = voice-slot record, XBC = paramA record) -> HL.
; Velocity crossfade/zone shaper. Takes the velocity byte from slot+8 (bits 8..14) and
; four breakpoints from the paramA record:
;     +30 = plateau low edge      +31 = fade-out low edge
;     +32 = plateau high edge     +33 = fade-out high edge
; Returns 0 inside the plateau [+30..+32]; a linear ramp in [0..-64] between +31 and +30
; and between +32 and +33 (numerator scaled by 0xFFC0 = -64, divided by the breakpoint
; span with a signed 32/16 divs); and the constant 0xFE00 (-512) outside [+31..+33].
; Pure computation; no hardware, no memory written.
; Sole caller: Voice_ComputePitch_ApplyLFO, which ADDS the result into the pitch
; accumulator -- so despite the "Pan" in the name this is a pitch-domain correction.
Voice_InterpolatePanCurve:	.include "includes/generated/cc900/Voice_InterpolatePanCurve.s"	; C: cc900/voice_envelopes_and_channels_v_18b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_InterpolatePanCurve_LowRange, Voice_InterpolatePanCurve + 33
	.set	Voice_InterpolatePanCurve_HighCheck, Voice_InterpolatePanCurve + 70
	.set	Voice_InterpolatePanCurve_HighRange, Voice_InterpolatePanCurve + 93
	.set	Voice_InterpolatePanCurve_Zero, Voice_InterpolatePanCurve + 134
	.set	Voice_InterpolatePanCurve_Done, Voice_InterpolatePanCurve + 136

; Voice_InterpolateNoteCurve(XWA = voice-slot record, XBC = paramA record) -> HL.
; Byte-for-byte the same shaper as Voice_InterpolatePanCurve, but keyed on the MIDI note
; number (slot+12 & 0x7F) and using paramA breakpoints +34/+35/+36/+37 instead of
; +30..+33. Returns 0 / [0..-64] / -512 with the same meanings.
; Sole caller: Voice_ComputePitch_ApplyLFO, added to the pitch accumulator.
Voice_InterpolateNoteCurve:	.include "includes/generated/cc900/Voice_InterpolateNoteCurve.s"	; C: cc900/voice_envelopes_and_channels_ad_20b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_InterpolateNoteCurve_LowRange, Voice_InterpolateNoteCurve + 34
	.set	Voice_InterpolateNoteCurve_HighCheck, Voice_InterpolateNoteCurve + 71
	.set	Voice_InterpolateNoteCurve_HighRange, Voice_InterpolateNoteCurve + 94
	.set	Voice_InterpolateNoteCurve_Zero, Voice_InterpolateNoteCurve + 135
	.set	Voice_InterpolateNoteCurve_Done, Voice_InterpolateNoteCurve + 137

; Voice_ComputePitch(XWA = voice-slot record). Computes the voice's pitch word and
; stores it at slot+13; also clears the portamento offset at slot+51.
; Callers: Voice_Build_Register_Set, Voice_Release_Type4, Voice_Release_Type4_BranchA.
;
; Inputs: slot+12 = MIDI note (bit 7 is a flag, not part of the note -- if set, bit 11
; of slot+1 is raised); slot+23 = paramA record; slot+15, slot+35 = controller and tone
; records; global tuning-mode word 0x041343; global master offset dword at 0x045314.
;
; Two mutually exclusive note->pitch mappings:
;   * ALTERNATE mapping, taken when bit 0 of 0x041343 is set (set by
;     Voice_SetPolyphonyMode with A==1), or bit 1 is set (Voice_SetCCMaxFlag), or
;     paramA+25 == 0xE0: pitch = table_0x011C96[note] - 0x0C. That table is a plain
;     128-byte monotonic curve 0x00..0xFF -- a direct, un-detuned note->increment map.
;   * NORMAL mapping: table_0x00FEE4[note] fed through Voice_Colour_LookupIndex with
;     paramA+25, minus 0xD0, multiplied by the signed detune paramA+24, arithmetic-
;     shifted right by 5 and biased by +0xD8.
;
; Both paths then converge on _ApplyLFO, which sums: the LFO/velocity scaler
; (paramA+26..+29 via Voice_Colour_ClampUpper), table_0x011A4F[slot+43 & 0x7F] (a signed
; +-8 fine-tune curve), the signed byte at (slot+15)+3, the 32-bit global at 0x045314,
; the constant 0x2940, and the two crossfade corrections from
; Voice_InterpolatePanCurve / Voice_InterpolateNoteCurve. If bit 7 of paramA[0] is set,
; tonerec[0x011E] is added on top.
; Touches no hardware; the result reaches the TG later via Voice_ApplyPortamento ->
; Voice_Build_OutputLevel.
Voice_ComputePitch:	.include "includes/generated/cc900/Voice_ComputePitch.s"	; C: cc900/voice_envelopes_and_channels_v_18c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_ComputePitch_CheckSysExTune, Voice_ComputePitch + 38
	.set	Voice_ComputePitch_SysExTable, Voice_ComputePitch + 61
	.set	Voice_ComputePitch_CheckAltTune, Voice_ComputePitch + 85
	.set	Voice_ComputePitch_NormalTune, Voice_ComputePitch + 118
	.set	Voice_ComputePitch_PortaPositive, Voice_ComputePitch + 187
	.set	Voice_ComputePitch_PortaScale, Voice_ComputePitch + 224
	.set	Voice_ComputePitch_ApplyLFO, Voice_ComputePitch + 233
	.set	Voice_ComputePitch_WriteDone, Voice_ComputePitch + 378

; Int_ClampSignedToRange_B(WA = value, BC = high, DE = low) -> HL.  (Named Voice_ComputePitch_InlineData
; until 2026-11-16: these 17 bytes are code, and Toshiba V4.23 reproduces them from C.)
; "clamp WA into [DE..BC], return in HL" -- the same operation as
; Int_ClampSignedToRange at 0x022B19, with the low bound tested first (that routine tests
; the high bound first). Nothing in the image references it; it is dead code left between
; Voice_ComputePitch and Voice_ComputePitch_Mono.
; Converted from `.byte` to real mnemonics 2026-09-01 (lane SUB): `jr ge, 4` / `jr 6` /
; `jr le, 2` take the raw 8-bit displacement field, verified byte-identical via a llvm-mc
; round trip (assemble -> objcopy -> compare against the original 17 bytes).
Int_ClampSignedToRange_B:	.include "includes/generated/cc900/Int_ClampSignedToRange_B.s"	; C: cc900/voice_envelopes_and_channels_q_17a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_ComputePitch_Skip, Int_ClampSignedToRange_B + 8
	.set	Voice_ComputePitch_Join, Int_ClampSignedToRange_B + 14

; Voice_ComputePitch_Mono(XWA = voice-slot record). The cut-down pitch computation used
; by the mono/legato voice types; callers are Voice_Init_Type1 and Voice_Init_Type2.
; Same two mappings as Voice_ComputePitch (alternate table 0x011C96 gated on 0x041343
; bits 0/1 or paramA+7 == 0xE0; otherwise the 0x00FEE4 + Voice_Colour_LookupIndex path
; scaled by the signed detune at paramA+6), but it reads its detune/curve selectors from
; paramA+6/+7 instead of +24/+25, and its _ApplyLFO tail omits the velocity/key
; crossfades and the tonerec[0x011E] term. Writes slot+13 and clears slot+51.
Voice_ComputePitch_Mono:	.include "includes/generated/cc900/Voice_ComputePitch_Mono.s"	; C: cc900/voice_envelopes_and_channels_b_12a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_ComputePitch_Mono_SysExTable, Voice_ComputePitch_Mono + 42
	.set	Voice_ComputePitch_Mono_CheckAltTune, Voice_ComputePitch_Mono + 65
	.set	Voice_ComputePitch_Mono_CheckPorta, Voice_ComputePitch_Mono + 96
	.set	Voice_ComputePitch_Mono_PortaPositive, Voice_ComputePitch_Mono + 154
	.set	Voice_ComputePitch_Mono_PortaScale, Voice_ComputePitch_Mono + 183
	.set	Voice_ComputePitch_Mono_ApplyLFO, Voice_ComputePitch_Mono + 190

; Voice_ApplyPortamento(XWA = voice-slot record). Takes the pitch computed at slot+13,
; applies the channel detune and the key-shift correction, and tail-jumps into
; Voice_Build_OutputLevel (which adds tonerec[+12], tonerec[+16] and the portamento offset
; slot+51, clamps, and pushes the value at the tone generator).
; Detune: paramA+23 non-zero -> add (paramA+23 - 0x64); zero -> subtract 0x200.
; Then always add the signed byte (slot+39)[+34].
; If bit 1 of the global mode word 0x041343 is set: for slot+4 <= 1 subtract
; tonerec[+16] and a further 8; otherwise subtract 0x10.
; Callers: Voice_Build_Register_Set, Voice_Release_Type4(_BranchA),
; Voice_AllVoices_WriteAmplitude_BranchA, and both portamento ramp write-backs
; (Voice_Step_ExprRamp_Ascend_WritePitch / _Release_WritePitch).
Voice_ApplyPortamento:	.include "includes/generated/cc900/Voice_ApplyPortamento.s"	; C: cc900/voice_envelopes_and_channels_b_7i.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_ApplyPortamento_NoChanDetune, Voice_ApplyPortamento + 28
	.set	Voice_ApplyPortamento_ApplyDetune, Voice_ApplyPortamento + 32
	.set	Voice_ApplyPortamento_HighNote, Voice_ApplyPortamento + 68
	.set	Voice_ApplyPortamento_Done, Voice_ApplyPortamento + 72

; Voice_ApplyPortamento2(XWA = voice-slot record). The mono/legato counterpart of
; Voice_ApplyPortamento. Channel detune comes from paramA+5 (not +23), there is no
; (slot+39)[+34] term, and the key-shift arm additionally subtracts tonerec[+12] and then
; adds back a vibrato contribution of tonerec[+12] >> 2 -- except when tonerec[+12] is
; exactly 0xFE00, in which case the raw 0xFE00 is added (a sentinel, the same -512 value
; the crossfade shapers use). Tail-jumps to Voice_Build_OutputLevel.
; Callers: Voice_Init_Type1, Voice_Init_Type2, Voice_AllVoices_WriteAmplitude_BranchB.
Voice_ApplyPortamento2:	.include "includes/generated/cc900/Voice_ApplyPortamento2.s"	; C: cc900/voice_envelopes_and_channels_q_17a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_ApplyPortamento2_NoChanDetune, Voice_ApplyPortamento2 + 25
	.set	Voice_ApplyPortamento2_ApplyDetune, Voice_ApplyPortamento2 + 29
	.set	Voice_ApplyPortamento2_AddVibrato, Voice_ApplyPortamento2 + 77
	.set	Voice_ApplyPortamento2_Done, Voice_ApplyPortamento2 + 79

; Voice_WriteChPitchWithVib(WA = part index, BC = MIDI channel). Broadcasts one part's
; note-level register pair to every voice slot currently owned by that channel.
; Sole caller: Voice_SetVelocity_Type80_SlotLoop.
;
; Reads the per-channel record at 0x0430AD + ch*0x47; returns immediately unless bit 3 of
; its first byte is set. Byte +14 of that record indexes the 0x011AE8 table (a flat table
; of 0x96), and the result is staged as (v<<8)|0x80 at 0x0451F8 and (v<<8) at 0x0451FA --
; i.e. TG banks 0x800 and 0x840.
; It then calls Voice_Query_AllChannels's sibling Voice_Query_PartVoices to obtain a
; NUL-list of matching slot indices at (XHL+5) and, for each slot whose channel byte
; (record 0x0430AD + slot*0x47, offset +14) matches, calls ToneGen_WriteLevelPair to
; push shadow offsets +44/+46 into TG banks 0x800/0x840 through 0x100000/0x100002.
Voice_WriteChPitchWithVib:	.include "includes/generated/cc900/Voice_WriteChPitchWithVib.s"	; C: cc900/voice_envelopes_and_channels_q_17a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_WriteChPitchWithVib_Loop, Voice_WriteChPitchWithVib + 95
	.set	Voice_WriteChPitchWithVib_NextSlot, Voice_WriteChPitchWithVib + 134
	.set	Voice_WriteChPitchWithVib_Done, Voice_WriteChPitchWithVib + 141

Voice_Calc_LevelPair_EGA:	.include "includes/generated/cc900/Voice_Calc_LevelPair_EGA.s"	; C: cc900/voice_envelopes_and_channels_b_10a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Calc_LevelPair_EGA_ApplyLFO, Voice_Calc_LevelPair_EGA + 133
	.set	Voice_Calc_LevelPair_EGA_WriteDSP, Voice_Calc_LevelPair_EGA + 198

Voice_Stage_EnvSegments:	.include "includes/generated/cc900/Voice_Stage_EnvSegments.s"	; C: cc900/voice_envelopes_and_channels.c

; Voice_WriteVolume_SetFlag(XWA = voice-slot record). Two-instruction helper: copies the
; already-computed pair-1 word from slot+64 into shadow 0x0451F8 with bit 7 forced set,
; and the same word verbatim into 0x0451FA. Used to re-assert an existing level without
; recomputing it. Sole caller: Voice_AllNotes_SustainRetrigger_BranchE.
Voice_WriteVolume_SetFlag:	.include "includes/generated/cc900/Voice_WriteVolume_SetFlag.s"	; C: cc900/voice_envelopes_and_channels.c

; Voice_ComputeVolume_CappedLFO(XWA = voice-slot record). Variant of
; Voice_Calc_LevelPair_EGA used on the voice-cut path (sole caller:
; Voice_Cut_BranchB). Difference: when bit 0 of tonerec+10 is SET the level is taken as
; the SMALLER of table_0x0118FE[table_0x011ADF[tonerec+24]] and
; table_0x0118FE[paramA+45] -- i.e. the oscillator ceiling wins outright rather than only
; capping. When the bit is clear it falls back to the tonerec[0x010D] + paramA+45 path.
; Stages the result to 0x0451F8/0x0451FA exactly as Volume1 does.
Voice_ComputeVolume_CappedLFO:	.include "includes/generated/cc900/Voice_ComputeVolume_CappedLFO.s"	; C: cc900/voice_envelopes_and_channels_b_10a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_ComputeVolume_CappedLFO_UseOscMax, Voice_ComputeVolume_CappedLFO + 116
	.set	Voice_ComputeVolume_CappedLFO_ApplyLFO, Voice_ComputeVolume_CappedLFO + 170
	.set	Voice_ComputeVolume_CappedLFO_WriteDSP, Voice_ComputeVolume_CappedLFO + 235

Voice_Calc_LevelPair_EGB:	.include "includes/generated/cc900/Voice_Calc_LevelPair_EGB.s"	; C: cc900/voice_envelopes_and_channels_b_12a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Calc_LevelPair_EGB_ApplyLFO, Voice_Calc_LevelPair_EGB + 89
	.set	Voice_Calc_LevelPair_EGB_NoKeyTrack, Voice_Calc_LevelPair_EGB + 185
	.set	Voice_Calc_LevelPair_EGB_NoLFO, Voice_Calc_LevelPair_EGB + 199
	.set	Voice_Calc_LevelPair_EGB_WriteDSP, Voice_Calc_LevelPair_EGB + 249
	.set	Voice_Calc_LevelPair_EGB_PositiveDetune, Voice_Calc_LevelPair_EGB + 275
	.set	Voice_Calc_LevelPair_EGB_WriteResult, Voice_Calc_LevelPair_EGB + 286

Voice_Calc_LevelPair_EGC:	.include "includes/generated/cc900/Voice_Calc_LevelPair_EGC.s"	; C: cc900/voice_envelopes_and_channels_q_17a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Calc_LevelPair_EGC_ApplyLFO, Voice_Calc_LevelPair_EGC + 89
	.set	Voice_Calc_LevelPair_EGC_NoKeyTrack, Voice_Calc_LevelPair_EGC + 185
	.set	Voice_Calc_LevelPair_EGC_NoLFO, Voice_Calc_LevelPair_EGC + 199
	.set	Voice_Calc_LevelPair_EGC_WriteDSP, Voice_Calc_LevelPair_EGC + 249

Voice_Calc_LevelPair_Silence:	.include "includes/generated/cc900/Voice_Calc_LevelPair_Silence.s"	; C: cc900/voice_envelopes_and_channels_b.c

; Voice_WriteVolume_OrPan(XWA = voice-slot record). If bit 5 of (slot+19)[+13] is set,
; stage pair 1 from table_0x0118FE[paramA+13]: 0x0451FA = (v<<8), 0x0451F8 = (v<<8)|0x80.
; Otherwise stage 0x0451F8 = 0x0080 (target 0x00 with the apply-now bit SET) and
; 0x0451FA = 0x0000 (target 0x00, apply-now bit CLEAR). Under the 0xFF = silent polarity
; that is the LOUD extreme, not silence: the firmware's silence word is 0xFF80 / 0xFF00
; (Voice_SetPitch). [INFERENCE] 0x00 is below 0x04, the loudest byte Voice_EnvelopeLevel_
; Curve can produce, so "fully open" is an extrapolation past the end of the curve rather
; than a level the builders ever emit.
; Sole caller: Voice_AllNotes_SustainRetrigger_BranchF.
Voice_WriteVolume_OrPan:	.include "includes/generated/cc900/Voice_WriteVolume_OrPan.s"	; C: cc900/voice_envelopes_and_channels_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_WriteVolume_OrPan_Muted, Voice_WriteVolume_OrPan + 45

; Voice_AdvanceLFOPhase(XWA = 9-byte LFO sub-record) -> HL = phase output.
; The sub-record fields used are: +0 flags/mode, +7 period, +8 phase counter.
; Mode = (flags & 0x1C):
;   0x08 "triangle": ++phase; while phase < period return (phase<<8)/period; when it
;        reaches the period, reset phase to 0, clear flag bit 3, set bit 2, return 0x100.
;   0x10 "ramp/hold": ++phase; return 0; when phase reaches the period, reset it, clear
;        flag bit 4 and set bit 3.
;   anything else: return 0 (idle).
; Called only from the three loops of Voice_UpdateAllLFO.
Voice_AdvanceLFOPhase:	.include "includes/generated/cc900/Voice_AdvanceLFOPhase.s"	; C: cc900/voice_envelopes_and_channels_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_AdvanceLFOPhase_IncDone, Voice_AdvanceLFOPhase + 35
	.set	Voice_AdvanceLFOPhase_Triangle, Voice_AdvanceLFOPhase + 39
	.set	Voice_AdvanceLFOPhase_TriangleReset, Voice_AdvanceLFOPhase + 76
	.set	Voice_AdvanceLFOPhase_Idle, Voice_AdvanceLFOPhase + 89
	.set	Voice_AdvanceLFOPhase_Done, Voice_AdvanceLFOPhase + 91

; Voice_UpdateAllLFO(). The per-tick LFO service; the single heaviest thing in the audio
; tick. Sole caller: Audio_Tick_ServiceVoices_A.
;
; Walks the LFO record array at 0x04424E, 27 (0x1B) bytes per slot, as THREE interleaved
; 9-byte sub-records: base 0x04424E (128 slots), base 0x044257 (64 slots) and base
; 0x044260 (128 slots) -- 320 iterations per call, each doing a 64-bit multiply
; (Math_Multiply32) for the index scaling and, when the LFO is running, a full tone-
; generator register write.
;
; Per slot: skip unless (flags & 0x18); call Voice_AdvanceLFOPhase; skip if the phase
; output is 0. Otherwise convert the phase through EGEnv_Compute_A (group 1),
; EGEnv_Compute_B (group 2) or Voice_Freq_WriteLeft (group 3), keep the result in the
; scratch words 0x04520C / 0x045204 / 0x04520E, and unless the phase was exactly 0x0100
; fold (result & 0x1FFF) * phase >> 8 back into the low 13 bits of that scratch word.
; Finally dispatch the value into the TG shadow block at 0x0451CC via
; ToneGen_WriteExtParam_600 (group 1), ToneGen_WriteExtParam_1C0_Single (group 2) or
; ToneGen_WriteExtParam_TypeDispatch_Single (group 3).
; Hardware touched (indirectly, through those writers): the TG address/data latch pair at
; 0x100000 / 0x100002.
Voice_UpdateAllLFO:	.include "includes/generated/cc900/Voice_UpdateAllLFO.s"	; C: cc900/voice_envelopes_and_channels_ag_21a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_UpdateAllLFO_Loop1, Voice_UpdateAllLFO + 9
	.set	Voice_UpdateAllLFO_DispatchVoice1, Voice_UpdateAllLFO + 108
	.set	Voice_UpdateAllLFO_NextSlot1, Voice_UpdateAllLFO + 119
	.set	Voice_UpdateAllLFO_Loop2, Voice_UpdateAllLFO + 127
	.set	Voice_UpdateAllLFO_Loop2_ProcessSlot, Voice_UpdateAllLFO + 135
	.set	Voice_UpdateAllLFO_DispatchVoice2, Voice_UpdateAllLFO + 236
	.set	Voice_UpdateAllLFO_NextSlot2, Voice_UpdateAllLFO + 247
	.set	Voice_UpdateAllLFO_Loop3, Voice_UpdateAllLFO + 255
	.set	Voice_UpdateAllLFO_Loop3_ProcessSlot, Voice_UpdateAllLFO + 264
	.set	Voice_UpdateAllLFO_DispatchGroup3_High, Voice_UpdateAllLFO + 368
	.set	Voice_UpdateAllLFO_DispatchVoice3, Voice_UpdateAllLFO + 407
	.set	Voice_UpdateAllLFO_NextSlot3, Voice_UpdateAllLFO + 418
	.set	Voice_UpdateAllLFO_Done, Voice_UpdateAllLFO + 427

Voice_Step_DelayTimers:	.include "includes/generated/cc900/Voice_Step_DelayTimers.s"	; C: cc900/voice_envelopes_and_channels_q_17a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Step_DelayTimers_LowSlot, Voice_Step_DelayTimers + 64
	.set	Voice_Step_DelayTimers_Store, Voice_Step_DelayTimers + 94

Voice_Step_ExprRamp:	.include "includes/generated/cc900/Voice_Step_ExprRamp.s"	; C: cc900/voice_envelopes_and_channels_ax_43a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Step_ExprRamp_ModeCheck2, Voice_Step_ExprRamp + 91
	.set	Voice_Step_ExprRamp_ModeDefault, Voice_Step_ExprRamp + 135
	.set	Voice_Step_ExprRamp_ZeroState, Voice_Step_ExprRamp + 181
	.set	Voice_Step_ExprRamp_DispatchMode, Voice_Step_ExprRamp + 198
	.set	Voice_Step_ExprRamp_Ascend_Tick, Voice_Step_ExprRamp + 282
	.set	Voice_Step_ExprRamp_Ascend_Tick2, Voice_Step_ExprRamp + 314
	.set	Voice_Step_ExprRamp_Ascend_ClampFloor, Voice_Step_ExprRamp + 349
	.set	Voice_Step_ExprRamp_Ascend_WritePitch, Voice_Step_ExprRamp + 372
	.set	Voice_Step_ExprRamp_Descend_Tick, Voice_Step_ExprRamp + 406
	.set	Voice_Step_ExprRamp_Descend_Tick2, Voice_Step_ExprRamp + 438
	.set	Voice_Step_ExprRamp_Descend_WritePitch, Voice_Step_ExprRamp + 473
	.set	Voice_Step_ExprRamp_Release_Start, Voice_Step_ExprRamp + 493
	.set	Voice_Step_ExprRamp_Release_Tick, Voice_Step_ExprRamp + 549
	.set	Voice_Step_ExprRamp_Release_Tick2, Voice_Step_ExprRamp + 581
	.set	Voice_Step_ExprRamp_Release_WritePitch, Voice_Step_ExprRamp + 616
	.set	Voice_Step_ExprRamp_NullMode, Voice_Step_ExprRamp + 652
	.set	Voice_Step_ExprRamp_ActiveCount, Voice_Step_ExprRamp + 659
	.set	Voice_Step_ExprRamp_CountTick, Voice_Step_ExprRamp + 702
	.set	Voice_Step_ExprRamp_CountTick2, Voice_Step_ExprRamp + 737
	.set	Voice_Step_ExprRamp_CountDecrement, Voice_Step_ExprRamp + 745
	.set	Voice_Step_ExprRamp_StoreDone, Voice_Step_ExprRamp + 748

Pitch_Bend_Ramp_Tick:	.include "includes/generated/cc900/Pitch_Bend_Ramp_Tick.s"	; C: cc900/voice_envelopes_and_channels.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Pitch_Bend_Ramp_Tick_Bit12, Pitch_Bend_Ramp_Tick + 44
	.set	Pitch_Bend_Ramp_Tick_Bit13Check, Pitch_Bend_Ramp_Tick + 67
	.set	Pitch_Bend_Ramp_Tick_Bit14Clear, Pitch_Bend_Ramp_Tick + 127
	.set	Pitch_Bend_Ramp_Tick_ZeroPitch, Pitch_Bend_Ramp_Tick + 178
	.set	Pitch_Bend_Ramp_Tick_CheckCounter, Pitch_Bend_Ramp_Tick + 192
	.set	Pitch_Bend_Ramp_Tick_ClearMode, Pitch_Bend_Ramp_Tick + 223

; Voice_InitVoiceState(WA = channel index). Loads the whole 22-word tone-generator shadow
; block at 0x0451CC with power-on defaults, immediately before the caller pushes it to
; the chip. Sole caller: Voice_TickNoteDecay.
; Notable defaults: 0x0451E4 = 0xFF7F (register pair 1 = maximum attenuation, maximum
; rate -- i.e. silent); 0x0451E6 and 0x0451E8 copied from the global word 0x041362 (set
; to 0x8000 or 0xA000 by Voice_SetRhythmMode); 0x0451DA from 0x041360; 0x0451D4 = 0x017F,
; 0x0451D6 = 0x7F7F, 0x0451D8 = 0x0040; 0x0451D0 = table_0x010764[0x041364] * 4; every
; other word zeroed. Finally stores 0xF0 into the per-channel record byte at
; 0x0430BB + ch*0x47.
Voice_InitVoiceState:	.include "includes/generated/cc900/Voice_InitVoiceState.s"	; C: cc900/voice_envelopes_and_channels_m_16b.c

; Voice_TickNoteDecay(). Rhythm/percussion decay tick. Sole caller:
; Audio_Tick_ServiceVoices_B (first thing it does).
; Returns immediately unless the mode byte 0x04135E is non-zero. Decrements the counter
; at 0x04135F and returns unless it reached zero. On the zero tick it calls
; Voice_SetPanning on a stack scratch structure and, if the channel index in that
; structure is below 0x40, calls Voice_InitVoiceState followed by
; ToneGen_WriteVoiceParams (base 0x0451CC) -- a full 22-register reload of that channel --
; and then one further ToneGen_WriteSingleReg using the word at 0x0430BB + ch*0x47.
; 0x04135E/0x04135F are set by Voice_SetRhythmMode.
Voice_TickNoteDecay:
	lda xsp, (xsp - 14)
	pushw_erp 0xFA
	cp (Payload_Bss_Start+0x24e8:24), 0x00
	jr z, Voice_TickNoteDecay_Done
	dec 1, (Payload_Bss_Start+0x24e9:24)
	cp (Payload_Bss_Start+0x24e9:24), 0x00
	jr nz, Voice_TickNoteDecay_Done
	lda xwa, (xsp + 2)
	call Voice_SetPanning
	cp (xsp + 12), 0x40
	jr nc, Voice_TickNoteDecay_Reload
	ld a, (xsp + 12)
	ldfr_berp A, 0xFB
	extz wa
	calr Voice_InitVoiceState
	ldto_berp A, 0xFB
	extz wa
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteVoiceParams
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

; Reload the divider: decrement the counter at 0x04135E and reset 0x04135F to 4.
Voice_TickNoteDecay_Reload:
	dec 1, (Payload_Bss_Start+0x24e8:24)
	ld (Payload_Bss_Start+0x24e9:24), 0x04

; Restore and return.
Voice_TickNoteDecay_Done:
	popw_erp 0xFA
	lda xsp, (xsp + 14)
	ret

; Voice_LoadPitchTable_Ch(A = part index, C = ramp position). Despite the name it does
; not load a table: it SCALES two DSP algorithm parameters by the ramp position and
; broadcasts the result to every voice of the part.
; Steps: DSP_AlgoType_Dispatch2(part, 1) * C >> 8, floored at 0x2C, stored to the scratch
; 0x045208 and to the per-part word 0x0413C5 + part*0x11F; then
; DSP_AlgoType_Dispatch1(part, 1) * table_0x010DCE[C] >> 8 stored to 0x04520C and to
; 0x0413C3 + part*0x11F; then Voice_BuildOutputList(part, 0x0D, 0) and, for every entry,
; ToneGen_WriteExtParams_56 with the shadow base 0x0451CC.
; The output list is a 16-bit array in the scratch buffer at 0x27E9, terminated by
; 0xFFFF; the loop runs while (entry & 0xFF) < 0x80, so at most 27 entries.
; Callers: Voice_ToneTableRamp_Up_Increment, Voice_ToneTableRamp_Down_Decrement,
; Voice_ToneTableApply_Pitch_Loop, Voice_ToneTableApply_Filter_Loop.
Voice_LoadPitchTable_Ch:	.include "includes/generated/cc900/Voice_LoadPitchTable_Ch.s"	; C: cc900/voice_envelopes_and_channels_v_18a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_LoadPitchTable_Ch_NoClamp, Voice_LoadPitchTable_Ch + 76
	.set	Voice_LoadPitchTable_Ch_ScanLoop, Voice_LoadPitchTable_Ch + 102
	.set	Voice_LoadPitchTable_Ch_LoopBody, Voice_LoadPitchTable_Ch + 190
	.set	Voice_LoadPitchTable_Ch_LoopCheck, Voice_LoadPitchTable_Ch + 214

; Voice_LoadPitchTable_All(A = part index). The ramp-position-independent form of
; Voice_LoadPitchTable_Ch: stores the raw DSP_AlgoType_Dispatch2/Dispatch1 results to
; 0x045208 and 0x04520C (no scaling, no per-part write-back) and broadcasts them with the
; same ToneGen_WriteExtParams_56 loop.
; Sole caller: Voice_ToneTableRamp_Up, when the pitch ramp has reached its ceiling.
Voice_LoadPitchTable_All:	.include "includes/generated/cc900/Voice_LoadPitchTable_All.s"	; C: cc900/voice_envelopes_and_channels_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_LoadPitchTable_All_LoopBody, Voice_LoadPitchTable_All + 60
	.set	Voice_LoadPitchTable_All_LoopCheck, Voice_LoadPitchTable_All + 85

; Voice_LoadFilterTable_Ch(A = part index, C = ramp position). Same shape as
; Voice_LoadPitchTable_Ch for the filter parameter set: DSP_AlgoType_Dispatch2(part, 0)
; scaled by C, floored at 0x1C, into 0x04520A and 0x0413C1 + part*0x11F;
; DSP_AlgoType_Dispatch1(part, 0) scaled by table_0x010ECE[C] into 0x04520E and
; 0x0413BF + part*0x11F; broadcast with Voice_BuildOutputList(part, 0x0C, 0) and
; ToneGen_WriteExtParams_56b.
Voice_LoadFilterTable_Ch:	.include "includes/generated/cc900/Voice_LoadFilterTable_Ch.s"	; C: cc900/voice_envelopes_and_channels_v_18a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_LoadFilterTable_Ch_NoClamp, Voice_LoadFilterTable_Ch + 76
	.set	Voice_LoadFilterTable_Ch_ScanFilter, Voice_LoadFilterTable_Ch + 102
	.set	Voice_LoadFilterTable_Ch_LoopBody, Voice_LoadFilterTable_Ch + 190
	.set	Voice_LoadFilterTable_Ch_LoopCheck, Voice_LoadFilterTable_Ch + 214

; Voice_LoadFilterTable_All(A = part index). Unscaled counterpart of
; Voice_LoadFilterTable_Ch; writes 0x04520A / 0x04520E and broadcasts with
; ToneGen_WriteExtParams_56b. Sole caller: Voice_ToneTableRamp_Up_CheckFilter.
Voice_LoadFilterTable_All:	.include "includes/generated/cc900/Voice_LoadFilterTable_All.s"	; C: cc900/voice_envelopes_and_channels_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_LoadFilterTable_All_LoopBody, Voice_LoadFilterTable_All + 60
	.set	Voice_LoadFilterTable_All_LoopCheck, Voice_LoadFilterTable_All + 85

; Voice_LoadToneTable_Ch(A = part index, C = ramp position). Third member of the family.
; Uses DSP_ChanFreq_WritePacket2(part) as its source value, scales it by C, floors at
; 0x1C, stores to 0x045206 and to 0x0413C9 + part*0x11F, then broadcasts with
; Voice_BuildOutputList(part, 0x10, 0) and ToneGen_WriteExtParams_15_Alt.
; Note its list terminator differs: the loop runs while (entry & 0xFF) < 0x40, not 0x80.
Voice_LoadToneTable_Ch:	.include "includes/generated/cc900/Voice_LoadToneTable_Ch.s"	; C: cc900/voice_envelopes_and_channels_v_18a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_LoadToneTable_Ch_NoClamp, Voice_LoadToneTable_Ch + 74
	.set	Voice_LoadToneTable_Ch_ScanLoop, Voice_LoadToneTable_Ch + 100
	.set	Voice_LoadToneTable_Ch_LoopBody, Voice_LoadToneTable_Ch + 123
	.set	Voice_LoadToneTable_Ch_LoopCheck, Voice_LoadToneTable_Ch + 148

; Voice_LoadToneTable_All(A = part index). Unscaled counterpart of
; Voice_LoadToneTable_Ch. Sole caller: Voice_ToneTableRamp_Up_CheckFilter.
Voice_LoadToneTable_All:	.include "includes/generated/cc900/Voice_LoadToneTable_All.s"	; C: cc900/voice_envelopes_and_channels_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_LoadToneTable_All_LoopBody, Voice_LoadToneTable_All + 42
	.set	Voice_LoadToneTable_All_LoopCheck, Voice_LoadToneTable_All + 67

; Voice_ToneTableRamp_Up(A = part index, XBC = part record at 0x041368 + part*0x11F).
; One step of the "sweep up" of the two DSP-parameter ramps a part owns:
;   +100 = pitch ramp position, range 0..0x4F (indexes the 80-entry curve 0x010D64)
;   +101 = filter ramp position, range 0..0x96 (divided by 6 to index the 26-entry curve
;          0x010DB4)
;   +99  = the ramp state-flag byte (bits 0..4)
; If +100 has reached 0x4F it sets flag bit 3 and calls Voice_LoadPitchTable_All;
; otherwise it increments +100, clears bit 3, and calls Voice_LoadPitchTable_Ch with
; table_0x010D64[+100]. The filter half behaves the same way against 0x96 / 6, calling
; Voice_LoadFilterTable_All + Voice_LoadToneTable_All, or _Ch with table_0x010DB4[+101/6].
; Sole caller: Audio_Tick_ServiceVoices_B_LFOLoopBody.
Voice_ToneTableRamp_Up:	.include "includes/generated/cc900/Voice_ToneTableRamp_Up.s"	; C: cc900/voice_envelopes_and_channels_q_17c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_ToneTableRamp_Up_Increment, Voice_ToneTableRamp_Up + 27
	.set	Voice_ToneTableRamp_Up_CheckFilter, Voice_ToneTableRamp_Up + 66
	.set	Voice_ToneTableRamp_Up_FilterIncrement, Voice_ToneTableRamp_Up + 90
	.set	Voice_ToneTableRamp_Up_Done, Voice_ToneTableRamp_Up + 161

; Voice_ToneTableRamp_Down(A = part index, XBC = part record). The mirror of
; Voice_ToneTableRamp_Up: when +100 is already 0 it sets flag bit 4 and skips to the
; filter half; otherwise it decrements +100, clears bit 4, and pushes
; table_0x010DB4[+100 >> 1]. The filter half decrements +101 and pushes
; table_0x010DB4[+101 / 5] to both the filter and tone parameter sets.
; Sole caller: Audio_Tick_ServiceVoices_B_LFO_CheckRampDown.
; ⚠ The two halves index the SAME 26-entry table 0x010DB4 with different scales -- >>1
; (max 0x4F/2 = 39) and /5 (max 0x96/5 = 30) -- both of which exceed the table's 26
; entries and read into the adjacent table at 0x010DCE. See [UNCERTAIN].
Voice_ToneTableRamp_Down:	.include "includes/generated/cc900/Voice_ToneTableRamp_Down.s"	; C: cc900/voice_envelopes_and_channels_b_ic03.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_ToneTableRamp_Down_Decrement, Voice_ToneTableRamp_Down + 19
	.set	Voice_ToneTableRamp_Down_CheckFilter, Voice_ToneTableRamp_Down + 61
	.set	Voice_ToneTableRamp_Down_Done, Voice_ToneTableRamp_Down + 138

; Voice_ToneTableApply_Pitch(A = part index, XBC = part record). Jumps the ramp straight
; to the position that matches the current pitch value, instead of stepping.
; Clears flag bits 3 and 4 of +99, reads L = table_0x010D64[+100], then searches DOWNWARD
; from index 0x19 for the largest index whose table_0x010DB4 entry is <= L. That index
; becomes the new +100; +101 is rescaled from the /6 domain into the /5 domain
; ((+101 / 6) is discarded and the found index * 5 is stored). Finally it pushes all
; three parameter sets with Voice_LoadPitchTable_Ch, Voice_LoadFilterTable_Ch and
; Voice_LoadToneTable_Ch.
; Sole caller: Audio_Tick_ServiceVoices_B_LFO_RampDown.
Voice_ToneTableApply_Pitch:	.include "includes/generated/cc900/Voice_ToneTableApply_Pitch.s"	; C: cc900/voice_envelopes_and_channels_ag_20a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_ToneTableApply_Pitch_Decrement, Voice_ToneTableApply_Pitch + 42
	.set	Voice_ToneTableApply_Pitch_Loop, Voice_ToneTableApply_Pitch + 45

; Voice_ToneTableApply_Filter(A = part index, XBC = part record). The mirror of
; Voice_ToneTableApply_Pitch: reads E = table_0x010DB4[+100 >> 1] and searches UPWARD
; from index 0 for the first index whose table_0x010D64 entry is >= E. That index becomes
; +100; +101 is rescaled from the /5 domain into the /6 domain (index * 6). Then pushes
; all three parameter sets with the three _Ch broadcasters.
; Sole caller: Audio_Tick_ServiceVoices_B_LFO_ApplyFilter.
Voice_ToneTableApply_Filter:	.include "includes/generated/cc900/Voice_ToneTableApply_Filter.s"	; C: cc900/voice_envelopes_and_channels_ag_20a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_ToneTableApply_Filter_Increment, Voice_ToneTableApply_Filter + 44
	.set	Voice_ToneTableApply_Filter_Loop, Voice_ToneTableApply_Filter + 47

Audio_Tick_ServiceVoices_A:	.include "includes/generated/cc900/Audio_Tick_ServiceVoices_A.s"	; C: cc900/voice_envelopes_and_channels_b_11a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Audio_Tick_ServiceVoices_A_Loop, Audio_Tick_ServiceVoices_A + 21
	.set	Audio_Tick_ServiceVoices_A_ClearSlot, Audio_Tick_ServiceVoices_A + 75
	.set	Audio_Tick_ServiceVoices_A_NextSlot, Audio_Tick_ServiceVoices_A + 109
	.set	Audio_Tick_ServiceVoices_A_Done, Audio_Tick_ServiceVoices_A + 122

; Per-audio-tick voice state machine, phase B.  Called from Audio_Process_Init (0x031F..,
; `call Audio_Tick_ServiceVoices_B`) which alternates between this and
; Audio_Tick_ServiceVoices_A every tick by XORing the byte at 0x041342 with 0xFF.
; Prologue: calr Voice_TickNoteDecay (0x027363), calr Pitch_Bend_Ramp_Tick (0x0271BC).
; Then reads the global flag word 0x041343 and tests bit 10:
;   bit 10 SET   -> loop A (0x027AE8): additionally re-writes the pitch register, twice --
;                   Pitch_Emit_Reg400 (0x023A4A) and ToneGen_WriteVoicePitch (0x02D0BA),
;                   both of which write +0x400 -- for every voice whose flags word
;                   (voice+0x01) has bit 10 set;
;   bit 10 CLEAR -> loop B (0x027BA0): the same retire/portamento bookkeeping WITHOUT any
;                   pitch register traffic.
; Both loops walk the part's voice-index list obtained from Voice_Query_AllChannels (0x02CD55),
; list pointer = XHL+5, terminated by a byte >= 0x40, voice record = 0x04308E + idx*0x47.
; Per voice: if [voice+0x23]+0x0A bit 15 is SET the note is still held -> Voice_Step_DelayTimers
; (0x026E5B) or Voice_Step_ExprRamp (0x026EC3); if CLEAR, and the matching request bit in
; (voice+0x2F) mask 0x8080 or (voice+0x31) bit 15 is set, the voice is released
; (Voice_Clear_HoldBit + Voice_Reload_Levels) and the request word is zeroed.
; Ends with the LFO/tone-table scan at 0x027C48.  Touches no hardware directly in loop B.
Audio_Tick_ServiceVoices_B:	.include "includes/generated/cc900/Audio_Tick_ServiceVoices_B.s"	; C: cc900/voice_envelopes_and_channels_ag_21a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Audio_Tick_ServiceVoices_B_LoopA, Audio_Tick_ServiceVoices_B + 36
	.set	Audio_Tick_ServiceVoices_B_CheckPortaA, Audio_Tick_ServiceVoices_B + 86
	.set	Audio_Tick_ServiceVoices_B_CheckPortamento2A, Audio_Tick_ServiceVoices_B + 119
	.set	Audio_Tick_ServiceVoices_B_ClearNoteOffA, Audio_Tick_ServiceVoices_B + 136
	.set	Audio_Tick_ServiceVoices_B_ClearPorta2A, Audio_Tick_ServiceVoices_B + 172
	.set	Audio_Tick_ServiceVoices_B_NextSlotA, Audio_Tick_ServiceVoices_B + 203
	.set	Audio_Tick_ServiceVoices_B_LoopB_Start, Audio_Tick_ServiceVoices_B + 220
	.set	Audio_Tick_ServiceVoices_B_LoopB, Audio_Tick_ServiceVoices_B + 236
	.set	Audio_Tick_ServiceVoices_B_CheckPortamento2B, Audio_Tick_ServiceVoices_B + 290
	.set	Audio_Tick_ServiceVoices_B_ClearNoteOffB, Audio_Tick_ServiceVoices_B + 307
	.set	Audio_Tick_ServiceVoices_B_ClearPorta2B, Audio_Tick_ServiceVoices_B + 343
	.set	Audio_Tick_ServiceVoices_B_NextSlotB, Audio_Tick_ServiceVoices_B + 374
	.set	Audio_Tick_ServiceVoices_B_ScanLFO, Audio_Tick_ServiceVoices_B + 388
	.set	Audio_Tick_ServiceVoices_B_LFOLoopBody, Audio_Tick_ServiceVoices_B + 397
	.set	Audio_Tick_ServiceVoices_B_LFO_ApplyFilter, Audio_Tick_ServiceVoices_B + 449
	.set	Audio_Tick_ServiceVoices_B_LFO_CheckRampDown, Audio_Tick_ServiceVoices_B + 462
	.set	Audio_Tick_ServiceVoices_B_LFO_RampDown, Audio_Tick_ServiceVoices_B + 482
	.set	Audio_Tick_ServiceVoices_B_LFONextSlot, Audio_Tick_ServiceVoices_B + 493
	.set	Audio_Tick_ServiceVoices_B_Done, Audio_Tick_ServiceVoices_B + 502

; WA = part index.  ORs 0x0020 into the part flags word at part+0x02 (0x04136A + idx*0x11F).
; Called once per part from Voice_ResetAllControllers.
Voice_SetLFO_ActiveFlag:	.include "includes/generated/cc900/Voice_SetLFO_ActiveFlag.s"	; C: cc900/voice_envelopes_and_channels.c

; WA = part index.  ANDs 0xFFDF into the same word.  Inverse of the above.
Voice_ClearLFO_ActiveFlag:	.include "includes/generated/cc900/Voice_ClearLFO_ActiveFlag.s"	; C: cc900/voice_envelopes_and_channels.c

; ----------------------------------------------------------------------------
; Voice_DSP_OutputConfig - Configure voice-to-DSP output routing
; Entry: A = voice number, C = channel
; Notes: Calls DSP_AlgoType_Dispatch1 for algorithm type lookup
;        Stores result to DSP state at 0x04520E
;        Iterates voice output list via Voice_BuildOutputList
;        Configures tone generator params via ToneGen_WriteReg0640
;        Two-pass: first updates 0x04520E, then 0x04520C
; ----------------------------------------------------------------------------
; Emitted as `.byte` in the LLVM source but is ordinary code.  A = voice, C = channel.
; Walks the voice output list (Voice_BuildOutputList 0x021A8E), consults
; DSP_AlgoType_Dispatch1 (0x0337D2) and writes the effect-routing shadow words at 0x04520E
; and then 0x04520C.  Twin of Voice_DSP_OutputConfig2 with different shadow offsets.
Voice_DSP_OutputConfig:	.include "includes/generated/cc900/Voice_DSP_OutputConfig.s"	; C: cc900/voice_envelopes_and_channels_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_DSP_OutputConfig_Loop, Voice_DSP_OutputConfig + 77
	.set	Voice_DSP_OutputConfig_Join, Voice_DSP_OutputConfig + 102
	.set	Voice_DSP_OutputConfig_Skip, Voice_DSP_OutputConfig + 125
	.set	Voice_DSP_OutputConfig_Loop2, Voice_DSP_OutputConfig + 187
	.set	Voice_DSP_OutputConfig_Join2, Voice_DSP_OutputConfig + 212
	.set	Voice_DSP_OutputConfig_Epilogue, Voice_DSP_OutputConfig + 233
; ----------------------------------------------------------------------------
; Voice_DSP_OutputConfig2 - Configure voice-to-DSP output routing (type 2)
; Entry: A = voice number, C = channel
; Notes: Same algorithm as Voice_DSP_OutputConfig with different table offsets
; ----------------------------------------------------------------------------
; NOT PRESENT in symbols/subcpu_symbols_reference.txt -- add it.
; Same body as Voice_DSP_OutputConfig but targets shadow words 0x04520A / 0x045208.
Voice_DSP_OutputConfig2:	.include "includes/generated/cc900/Voice_DSP_OutputConfig2.s"	; C: cc900/voice_envelopes_and_channels_b_callnames.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_DSP_OutputConfig2_Loop, Voice_DSP_OutputConfig2 + 77
	.set	Voice_DSP_OutputConfig2_Join, Voice_DSP_OutputConfig2 + 102
	.set	Voice_DSP_OutputConfig2_Skip, Voice_DSP_OutputConfig2 + 125
	.set	Voice_DSP_OutputConfig2_Loop2, Voice_DSP_OutputConfig2 + 187
	.set	Voice_DSP_OutputConfig2_Join2, Voice_DSP_OutputConfig2 + 212
	.set	Voice_DSP_OutputConfig2_Epilogue, Voice_DSP_OutputConfig2 + 233
; ----------------------------------------------------------------------------
; Voice_DSP_SimpleCopy - Simple voice-to-DSP parameter copy
; Entry: A = voice number
; Notes: Calls DSP function at 0x033B8B, stores to 0x045204
;        Iterates voice output list (max 64 entries)
; ----------------------------------------------------------------------------
; NOT PRESENT in symbols/subcpu_symbols_reference.txt -- add it.
; A = voice.  Calls 0x033B8B, stores to 0x045204, iterates the voice output list (<= 64).
Voice_DSP_SimpleCopy:	.include "includes/generated/cc900/Voice_DSP_SimpleCopy.s"	; C: cc900/voice_envelopes_and_channels_b_callnames.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_DSP_SimpleCopy_Loop, Voice_DSP_SimpleCopy + 42
	.set	Voice_DSP_SimpleCopy_Join, Voice_DSP_SimpleCopy + 67
; ----------------------------------------------------------------------------
; Voice_DSP_SimpleCopy2 - Simple voice-to-DSP parameter copy (type 2)
; Entry: A = voice number
; Notes: Same algorithm as Voice_DSP_SimpleCopy with different offsets
; ----------------------------------------------------------------------------
; NOT PRESENT in symbols/subcpu_symbols_reference.txt -- add it.
; As above with target 0x045206 and callee 0x033C6B.
Voice_DSP_SimpleCopy2:	.include "includes/generated/cc900/Voice_DSP_SimpleCopy2.s"	; C: cc900/voice_envelopes_and_channels_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_DSP_SimpleCopy2_Loop, Voice_DSP_SimpleCopy2 + 42
	.set	Voice_DSP_SimpleCopy2_Join, Voice_DSP_SimpleCopy2 + 67

; Writes ONE tone-generator register: latch = voice + 0x0400 (register 0x10 = PITCH),
; data = word at XBC+0x0E (normally the staging record 0x0451CC).
; Entry WA = voice number 0..0x3F, XBC = source record.  Clobbers nothing (XIZ saved).
; Caller: Pitch_Refresh_Sounding_Voices/Pitch_Refresh_Sounding_Voices (0x028D4C) and the sustain
; retrigger scan.  These four writers were prefixed DSP_WriteVoiceParam_*, which was wrong:
; they drive the TONE GENERATOR at 0x100000/0x100002, never IC311 at 0x130000.
ToneGen_WriteVoice_Long:	.include "includes/generated/cc900/ToneGen_WriteVoice_Long.s"	; C: cc900/voice_envelopes_and_channels_lane_23w1a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_WriteVoice_Long_NopGap, ToneGen_WriteVoice_Long + 29

; latch = voice + 0x0080 (register 0x02 = AMPLITUDE / level), data = word at XBC+0x04 with
; bit 15 forcibly cleared.  Called from Voice_AllVoices_WriteAmplitude, i.e. this is the
; register that CC 7 (volume) and CC 11 (expression) ultimately reach.
ToneGen_WriteVoice_Short:	.include "includes/generated/cc900/ToneGen_WriteVoice_Short.s"	; C: cc900/voice_envelopes_and_channels_lane_23w1a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_WriteVoice_Short_NopGap, ToneGen_WriteVoice_Short + 32

; latch = WA + 0x0000, data = the 16-bit value already in IZ.  The only writer in the region
; that sends a caller-supplied word rather than a staged one.
;
; Bank 0x0000 is the per-voice CONTROL/gate register, and BC = (voice+0x2D) is the HAND-OFF
; word with bit 15 set -- built by Voice_Build_GateCommand (0x025589) / _NoPartial
; (0x0255F3), which carry the full command set and the measurement. Both call sites are in
; Voice_AllNotes_SustainRetrigger (0x028E26), branches B and D: each does
; Voice_Calc_LevelPair_EGA, ToneGen_WriteSegRegs_SameLevel, then this write, then
; Voice_Clear_HoldBit. So the sustain retrigger re-gates the voice by re-issuing the SAME
; stored control word -- it does not build a new one.
; MEASURED (demo capture, 1705 note-ons; harness in kn7000_mame,
; tools/rigs/kn5000_demo_capture.lua): the values seen on this register are only F0FF,
; F000, F1D7 and F187; the low byte is an output level, 0xFF full and 0x00 silent.
ToneGen_WriteVoice_Direct:	.include "includes/generated/cc900/ToneGen_WriteVoice_Direct.s"	; C: cc900/voice_envelopes_and_channels_inlinejr.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_WriteVoice_Direct_NopGap, ToneGen_WriteVoice_Direct + 22

; Six-register burst for one voice.  WA = voice, XBC = staging record.
; latch/source pairs, in program order:
;   0x0840 (reg 0x21) <- +0x2E   0x0940 (reg 0x25) <- +0x32   0x0A00 (reg 0x28) <- +0x36
;   0x0800 (reg 0x20) <- +0x2C   0x0900 (reg 0x24) <- +0x30   0x09C0 (reg 0x27) <- +0x34
; i.e. three (even,odd) register pairs, matching the three Voice_Calc_LevelPair_EGA/2/3
; calls that precede it in Voice_AllNotes_SustainRetrigger_BranchC.
ToneGen_WriteVoice_6Words:	.include "includes/generated/cc900/ToneGen_WriteVoice_6Words.s"	; C: cc900/voice_envelopes_and_channels_lane_23w1a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_WriteVoice_6Words_Word2, ToneGen_WriteVoice_6Words + 39
	.set	ToneGen_WriteNote6ch_NopCont1, ToneGen_WriteVoice_6Words + 73
	.set	ToneGen_WriteNote6ch_NopCont2, ToneGen_WriteVoice_6Words + 107
	.set	ToneGen_WriteNote6ch_NopCont3, ToneGen_WriteVoice_6Words + 141
	.set	ToneGen_WriteNote6ch_NopCont4, ToneGen_WriteVoice_6Words + 175
	.set	ToneGen_WriteNote6ch_NopCont5, ToneGen_WriteVoice_6Words + 209

; Two-register variant: latch 0x0840 (reg 0x21) <- XBC+0x2E, latch 0x0800 (reg 0x20) <- +0x2C.
; Same entry convention as ToneGen_WriteVoice_6Words.  Used where only the first volume/EG
; pair needs refreshing (Voice_AllNotes_SustainRetrigger branches E and F).
ToneGen_WriteNote2ch:	.include "includes/generated/cc900/ToneGen_WriteNote2ch.s"	; C: cc900/voice_envelopes_and_channels_lane_23w1a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_WriteNote2ch_NopCont1, ToneGen_WriteNote2ch + 39
	.set	ToneGen_WriteNote2ch_NopCont2, ToneGen_WriteNote2ch + 73

; --- 0x0280FE-0x028838  ToneGen_WriteVoice_Reg21 -- was MISLABELLED, now fully code
; All 1851 bytes are TLCS-900H instructions, byte-for-byte (round-trip verified against
; kn5000_subprogram_v142.rom).  Most of this span had already been converted from `.byte` by
; an earlier pass; the last 134 bytes (AudioMod_Scale_To_Part_1C/1B) resisted the automated
; convert because llvm-mc's own disassembler cannot DECODE the `st_rrb`/register-indexed
; forms it can ENCODE -- MAME unidasm framing plus a hand round trip closed them 2026-09-02.
; It contains 21 subroutines, every one of them reached by `calr` from named code or from the
; 0x028F75 block.  The 21 entry points are proposed individually below.  Nothing in here is data.
; RENAME APPLIED.
; ToneGen_WriteVoice_Reg21, the name this note proposed for VoiceCC_DataTable_0280FE, was applied on
; 2026-11-16 (scripts/renaming/rename_subcpu_dsp_cells.sed, lane_sub).
; WA = voice 0..0x3F, XBC = source record.  Writes TG register 0x21 (latch = voice + 0x0840)
; with the word at XBC+0x2E.  Single-register writer, same 5-step strobe as all the others.
ToneGen_WriteVoice_Reg21:
	push	xiz
	ld	xiz, xbc
	res	7, (P6:8)
	add	wa, 2112
	ld	(ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ld	wa, (xiz+46)
	ld	(ToneGen_RegDataPort:24), wa
	jr	ToneGen_WriteVoice_Reg21_Next	; `jr` to the next instruction + three `nop`s: the settling gap after the register write
ToneGen_WriteVoice_Reg21_Next:
	nop
	nop
	nop
	pop	xiz
	ret
; ToneGen_WriteVoice_TvfPair: Writes voice WA's TVF (filter) register pair: TG 0x100 + voice <- (XBC + 8) and
;   0x140 + voice <- (XBC + 10), each latch / data write with P6.7 low / high and a three-`nop` settling gap.
;   Basis: callers + body -- TVF_Refresh_Sounding_Voices calls it with XBC = the staging record 0x0451CC right
;   after TVF_Emit_Registers / TVF_Emit_Registers_Type2 put the clamped cutoff word and the second filter
;   word at staging +8 / +10; 0x100 / 0x140 is the filter pair (tone-generator.md).  Was
;   ToneGen_WriteVoice_Pan_Pair: those registers are not the pan.
ToneGen_WriteVoice_TvfPair:	.include "includes/generated/cc900/ToneGen_WriteVoice_TvfPair.s"	; C: cc900/voice_envelopes_and_channels_lane_23w1a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_WriteVoice_TvfPair_Next, ToneGen_WriteVoice_TvfPair + 39
	.set	ToneGen_WriteVoice_TvfPair_Next2, ToneGen_WriteVoice_TvfPair + 73
; WA = voice, XBC = source record.  Writes register 0x21 (voice+0x0840) from XBC+0x1A and
; register 0x22 (voice+0x0880) from XBC+0x1C.  Called after Voice_WriteChPanShift (0x02591D)
; and Voice_WriteChPanShift2 (0x025B6F), so the pair is the pan-shift/detune result, but the
; exact meaning of registers 0x21/0x22 is not proven here.
ToneGen_WriteVoice_Reg21_Reg22:	.include "includes/generated/cc900/ToneGen_WriteVoice_Reg21_Reg22.s"	; C: cc900/voice_envelopes_and_channels_lane_23w1a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_WriteVoice_Reg21_Reg22_Next, ToneGen_WriteVoice_Reg21_Reg22 + 39
	.set	ToneGen_WriteVoice_Reg21_Reg22_Next2, ToneGen_WriteVoice_Reg21_Reg22 + 73
; WA = voice, XBC = source record.  Writes register 0x06 (latch = voice + 0x0180) from
; XBC+0x0C.  Register 6 is the per-voice ENVELOPE LEVEL -- the MAME memory map already
; documents latch 0x0180+ch as the envelope-level read-back address, and this is the write
; side of the same register.
ToneGen_WriteVoice_EnvLevel:	.include "includes/generated/cc900/ToneGen_WriteVoice_EnvLevel.s"	; C: cc900/voice_envelopes_and_channels_lane_23w1a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_WriteVoice_EnvLevel_Next, ToneGen_WriteVoice_EnvLevel + 29
; Writes register 0x11 (latch voice+0x0440) from XBC+0x10.
ToneGen_WriteVoice_Reg11:	.include "includes/generated/cc900/ToneGen_WriteVoice_Reg11.s"	; C: cc900/voice_envelopes_and_channels_lane_23w1a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_WriteVoice_Reg11_Next, ToneGen_WriteVoice_Reg11 + 29
; Writes register 0x13 (latch voice+0x04C0) from XBC+0x14.
ToneGen_WriteVoice_Reg13:	.include "includes/generated/cc900/ToneGen_WriteVoice_Reg13.s"	; C: cc900/voice_envelopes_and_channels_lane_23w1a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_WriteVoice_Reg13_Next, ToneGen_WriteVoice_Reg13 + 29
; Writes register 0x18 (latch voice+0x0600) from XBC+0x40.
ToneGen_WriteVoice_Reg18:	.include "includes/generated/cc900/ToneGen_WriteVoice_Reg18.s"	; C: cc900/voice_envelopes_and_channels_lane_23w1a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_WriteVoice_Reg18_Next, ToneGen_WriteVoice_Reg18 + 29
; Writes register 0x16 (latch voice+0x0580) from XBC+0x3C.
ToneGen_WriteVoice_Reg16:	.include "includes/generated/cc900/ToneGen_WriteVoice_Reg16.s"	; C: cc900/voice_envelopes_and_channels_lane_23w1a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_WriteVoice_Reg16_Next, ToneGen_WriteVoice_Reg16 + 29
; Writes register 0x07 (latch voice+0x01C0) from XBC+0x38.
ToneGen_WriteVoice_Reg07:	.include "includes/generated/cc900/ToneGen_WriteVoice_Reg07.s"	; C: cc900/voice_envelopes_and_channels_lane_23w1a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_WriteVoice_Reg07_Next, ToneGen_WriteVoice_Reg07 + 29
; Writes register 0x15 (latch voice+0x0540) from XBC+0x3A.
ToneGen_WriteVoice_Reg15:	.include "includes/generated/cc900/ToneGen_WriteVoice_Reg15.s"	; C: cc900/voice_envelopes_and_channels_lane_23w1a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_WriteVoice_Reg15_Next, ToneGen_WriteVoice_Reg15 + 29
; Range-split writer.  If WA < 0x40 it writes register 0x07 from XBC+0x38 (the normal 64
; voices); otherwise it writes register 0x18 from XBC+0x42.  Proof that the tone generator
; has addressable slots beyond voice 0x3F for some register groups, and that the software
; deliberately re-targets them.
ToneGen_WriteVoice_Reg07_Or_Reg18:	.include "includes/generated/cc900/ToneGen_WriteVoice_Reg07_Or_Reg18.s"	; C: cc900/voice_envelopes_and_channels_lane_23w1a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_WriteVoice_Reg07_Or_Reg18_Next, ToneGen_WriteVoice_Reg07_Or_Reg18 + 35
	.set	ToneGen_WriteVoice_Reg07_Or_Reg18_Skip, ToneGen_WriteVoice_Reg07_Or_Reg18 + 40
	.set	ToneGen_WriteVoice_Reg07_Or_Reg18_Next2, ToneGen_WriteVoice_Reg07_Or_Reg18 + 66
	.set	ToneGen_WriteVoice_Reg07_Or_Reg18_Epilogue, ToneGen_WriteVoice_Reg07_Or_Reg18 + 69
; Same shape: WA < 0x40 -> register 0x15 from XBC+0x3A, else register 0x16 from XBC+0x3E.
ToneGen_WriteVoice_Reg15_Or_Reg16:	.include "includes/generated/cc900/ToneGen_WriteVoice_Reg15_Or_Reg16.s"	; C: cc900/voice_envelopes_and_channels_lane_23w1a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_WriteVoice_Reg15_Or_Reg16_Next, ToneGen_WriteVoice_Reg15_Or_Reg16 + 35
	.set	ToneGen_WriteVoice_Reg15_Or_Reg16_Skip, ToneGen_WriteVoice_Reg15_Or_Reg16 + 40
	.set	ToneGen_WriteVoice_Reg15_Or_Reg16_Next2, ToneGen_WriteVoice_Reg15_Or_Reg16 + 66
	.set	ToneGen_WriteVoice_Reg15_Or_Reg16_Epilogue, ToneGen_WriteVoice_Reg15_Or_Reg16 + 69
; A = part index, C = a bus mask, XDE and XIX = bit patterns to set/clear, one word on the
; stack.  For each of the 4 output buses w = 0..3 it reads two 4-byte mask tables at
; 0x00F6D7 and 0x00F6DB, tests bit (1<<w) of C against each, and then sets or clears bits in
; the word at  0x041368 + part*0x11F + 0x6E + w*0x25 + 0x18  (i.e. output-slot record w,
; field +0x18) using OR / AND-with-complement.  Returns with `retd 2`.
; This is the routine that turns a "send this modulation to buses X" request into the
; per-slot enable bitmap.
AudioMod_Apply_BusRouting:	.include "includes/generated/cc900/AudioMod_Apply_BusRouting.s"	; C: cc900/voice_envelopes_and_channels_q_17b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AudioMod_Apply_BusRouting_Loop, AudioMod_Apply_BusRouting + 11
	.set	AudioMod_Apply_BusRouting_Skip, AudioMod_Apply_BusRouting + 94
	.set	AudioMod_Apply_BusRouting_Skip2, AudioMod_Apply_BusRouting + 178
	.set	AudioMod_Apply_BusRouting_Join, AudioMod_Apply_BusRouting + 223
	.set	AudioMod_Apply_BusRouting_Epilogue, AudioMod_Apply_BusRouting + 230
; A = part index, BC = controller value, XDE = 3-byte modulation-routing descriptor.
; Descriptor layout, proven by every user in this block:
;     +0 : (unused here)
;     +1 : bit 7 = BIPOLAR flag, bits 0..5 = destination command id (see AudioChannel_Dispatch)
;     +2 : depth / scale, 0..0x7F
; Computes  E = ((bipolar ? (BC-0x40)*2 : BC) * depth) >> 6  and stores the byte at
; 0x041384 + part*0x11F  (part+0x1C).
AudioMod_Scale_To_Part_1C:
	bit	7, (xde+1)
	jr	z, AudioMod_Scale_To_Part_1C_Unipolar
	ld	e, (xde+2)
	ld	l, e
	extz	hl
	extz	bc
	sub	bc, 64
	ld	de, bc
	add	de, de
	ld	bc, de
	mul	xbc, hl
	ld	de, bc
	jr	AudioMod_Scale_To_Part_1C_Common
AudioMod_Scale_To_Part_1C_Unipolar:
	ld	e, (xde+2)
	ld	l, e
	extz	hl
	ld	e, c
	extz	de
	ld	bc, de
	mul	xbc, hl
	ld	de, bc
AudioMod_Scale_To_Part_1C_Common:
	srl	de, 6
	extz	wa
	muls	wa, 0x11F
	lda	xbc, (Payload_Bss_Start+0x250e:24)
	ld	(xbc+wa), e
	ret
; Identical to AudioMod_Scale_To_Part_1C but stores to 0x041383 + part*0x11F (part+0x1B).
AudioMod_Scale_To_Part_1B:
	bit	7, (xde+1)
	jr	z, AudioMod_Scale_To_Part_1B_Unipolar
	ld	e, (xde+2)
	ld	l, e
	extz	hl
	extz	bc
	sub	bc, 64
	ld	de, bc
	add	de, de
	ld	bc, de
	mul	xbc, hl
	ld	de, bc
	jr	AudioMod_Scale_To_Part_1B_Common
AudioMod_Scale_To_Part_1B_Unipolar:
	ld	e, (xde+2)
	ld	l, e
	extz	hl
	ld	e, c
	extz	de
	ld	bc, de
	mul	xbc, hl
	ld	de, bc
AudioMod_Scale_To_Part_1B_Common:
	srl	de, 6
	extz	wa
	muls	wa, 0x11F
	lda	xbc, (Payload_Bss_Start+0x250d:24)
	ld	(xbc+wa), e
	ret
; A = part index (saved on the stack), BC = value, XDE = routing descriptor.
; Bipolar branch subtracts 0x2000 from the sign-extended value, unipolar branch halves it;
; scales by descriptor+2 via Math_Multiply32 (0x03D8CA), then, for A-0x10 in 0..9, takes a
; 10-way jump through the word table at 0x00F6DF with base 0x028500 to apply a per-curve
; shaping step.  The default path (index out of range) instead scales by the part's
; portamento-rate byte at 0x04137B.  Result is clamped to +/-0x4000 through
; Long_SignedDiv (0x03DC5F) and stored as a word at 0x041385 + part*0x11F
; (part+0x1D).
AudioMod_Apply_Porta_Curve:	.include "includes/generated/cc900/AudioMod_Apply_Porta_Curve.s"	; C: cc900/voice_envelopes_and_channels_ag_21c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AudioMod_Apply_Porta_Curve_Skip2, AudioMod_Apply_Porta_Curve + 21
	.set	AudioMod_Apply_Porta_Curve_Join, AudioMod_Apply_Porta_Curve + 28
	.set	AudioMod_Porta_Curve_JumpBase, AudioMod_Apply_Porta_Curve + 84
	.set	AudioMod_Apply_Porta_Curve_Skip, AudioMod_Apply_Porta_Curve + 95
	.set	AudioMod_Apply_Porta_Curve_Join2, AudioMod_Apply_Porta_Curve + 123
	.set	AudioMod_Apply_Porta_Curve_Skip3, AudioMod_Apply_Porta_Curve + 147
	.set	AudioMod_Apply_Porta_Curve_Join3, AudioMod_Apply_Porta_Curve + 158
; Same descriptor convention as AudioMod_Scale_To_Part_1C but SIGNED (muls), arithmetic
; shift right 1, then divided by 0x7F; stores the byte at 0x041387 + part*0x11F (part+0x1F).
AudioMod_Scale_To_Part_1F:
	bit	7, (xde+1)	; bit 7,(XDE+0x01)
	jr	z, AudioMod_Scale_To_Part_1F_Skip
	ld	e, (xde+2)
	ld	l, e
	extz	hl
	extz	bc
	sub	bc, 64
	ld	de, bc
	add	de, de
	ld	bc, de
	muls	xbc, hl
	ld	de, bc
	jr	AudioMod_Scale_To_Part_1F_Join
AudioMod_Scale_To_Part_1F_Skip:
	ld	e, (xde+2)
	ld	l, e
	extz	hl
	ld	e, c
	extz	de
	ld	bc, de
	muls	xbc, hl
	ld	de, bc
AudioMod_Scale_To_Part_1F_Join:
	sra	de, 1
	ld	bc, de
	exts	xbc
	divs	bc, 127
	ld	de, bc
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x2511:24)
	ld	(xbc+wa), e
	ret
; As above without the >>1; stores the byte at 0x041388 + part*0x11F (part+0x20).
; AudioMod_Scale_To_LevelPairShift: Audio-channel command 2 scaler: E = ((bipolar ? (BC-0x40)*2 : BC) * depth) / 127,
;   signed, stored as the part's level-pair shift byte part+0x20 (0x041388 + part*0x11F). Basis: caller + readers --
;   AudioChannel_Handler_Cmd02 is the only caller; the only readers, Voice_WriteChPanShift/2, add (layer-word bit 9
;   clear) or subtract it from the 7-bit level pair voice+62/+64 (TG regs 0x21/0x22) while layer-word bit 8 is set.
AudioMod_Scale_To_LevelPairShift:
	bit	7, (xde+1)	; bit 7,(XDE+0x01)
	jr	z, AudioMod_Scale_To_Part_20_Skip
	ld	e, (xde+2)
	ld	l, e
	extz	hl
	extz	bc
	sub	bc, 64
	ld	de, bc
	add	de, de
	ld	bc, de
	muls	xbc, hl
	ld	de, bc
	jr	AudioMod_Scale_To_Part_20_Join
AudioMod_Scale_To_Part_20_Skip:
	ld	e, (xde+2)
	ld	l, e
	extz	hl
	ld	e, c
	extz	de
	ld	bc, de
	muls	xbc, hl
	ld	de, bc
AudioMod_Scale_To_Part_20_Join:
	ld	bc, de
	exts	xbc
	divs	bc, 127
	ld	de, bc
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x2512:24)
	ld	(xbc+wa), e
	ret
; A = part, C = controller value, XDE = routing descriptor, plus L and W taken from the
; caller's stack frame (they select one of the part's four output-slot records and a
; sub-index).  Bipolar values below 0x40 are forced to zero, otherwise folded to
; (C-0x40)*2.  Merges the odd/even bit halves (masks 0x55 / 0xAA) of the descriptor byte
; with the existing per-slot byte at slot+0x28, then writes the byte at slot+0x2A.
; Slot address = 0x041368 + part*0x11F + 0x6E + (L<<4) + (W<<2).  Returns with `retd 4`.
; The routine body runs to the `retd 4` at 0x02870C; it has two interior entry points,
; 0x02860D and 0x0286D9, each taken by exactly one external caller.
AudioMod_Apply_Slot_Field2A:	.include "includes/generated/cc900/AudioMod_Apply_Slot_Field2A.s"	; C: cc900/voice_envelopes_and_channels_am_23a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AudioMod_Apply_Slot_Field2A_Skip, AudioMod_Apply_Slot_Field2A + 28
	.set	AudioMod_Apply_Slot_Field2A_Join, AudioMod_Apply_Slot_Field2A + 30
	.set	AudioMod_Apply_Slot_Field2A_Skip2, AudioMod_Apply_Slot_Field2A + 155
	.set	AudioMod_Apply_Slot_Field2A_Join2, AudioMod_Apply_Slot_Field2A + 201
	.set	AudioMod_Apply_Slot_Field2A_Skip3, AudioMod_Apply_Slot_Field2A + 231
; Byte-for-byte the same algorithm as AudioMod_Apply_Slot_Field2A except that the result is
; stored at slot+0x29 instead of slot+0x2A.  Also returns with `retd 4` (at 0x028825).
; Six callers, all of them dispatch handlers inside the 0x028F75 block.
AudioMod_Apply_Slot_Field29:	.include "includes/generated/cc900/AudioMod_Apply_Slot_Field29.s"	; C: cc900/voice_envelopes_and_channels_am_23a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AudioMod_Apply_Slot_Field29_Skip, AudioMod_Apply_Slot_Field29 + 28
	.set	AudioMod_Apply_Slot_Field29_Join, AudioMod_Apply_Slot_Field29 + 30
	.set	AudioMod_Apply_Slot_Field29_Skip2, AudioMod_Apply_Slot_Field29 + 155
	.set	AudioMod_Apply_Slot_Field29_Join2, AudioMod_Apply_Slot_Field29 + 201
	.set	AudioMod_Apply_Slot_Field29_Skip3, AudioMod_Apply_Slot_Field29 + 231
; Eleven bytes, no prologue.  HL = min(max(WA, DE), BC), i.e. clamp WA to the inclusive
; range [DE, BC] using signed comparisons.  Tail utility of the 0x0280FE block.
Audio_Clamp_To_Range:	.include "includes/generated/cc900/Audio_Clamp_To_Range.s"	; C: cc900/voice_envelopes_and_channels.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Audio_Clamp_To_Range_Skip, Audio_Clamp_To_Range + 8
	.set	Audio_Clamp_To_Range_Join, Audio_Clamp_To_Range + 14

; Voice_CC_SetVolume -- CC 0x07: Store volume via lookup table
; Uses non-linear lookup table at ROM 0x011D16. Mute value: 0xFE00.
; WA = part index, BC = CC 7 value 0..0x7F.  Three-way behaviour selected by the global flag
; word 0x041343: bit 0 set and bit 1 set both map the value through the 128-entry word table
; at 0x011D16; otherwise the raw path stores (value - 0x7F).  Value 0 takes the mute path.
; Result is the word at 0x041374 + part*0x11F (part+0x0C).  Does not touch hardware -- the
; caller (Voice_CC_Volume) follows up with Voice_AllVoices_WriteAmplitude.
Voice_CC_SetVolume:	.include "includes/generated/cc900/Voice_CC_SetVolume.s"	; C: cc900/voice_envelopes_and_channels_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	VoiceCC_SetVolume_Bit1Set, Voice_CC_SetVolume + 49
	.set	VoiceCC_SetVolume_RawSub, Voice_CC_SetVolume + 94
	.set	VoiceCC_SetVolume_Mute, Voice_CC_SetVolume + 121

; Voice_CC_SetPan -- CC 0x0A: Store pan value at voice + 0x0E
; WA = part, C = CC 10 value.  Stores the byte at 0x041376 + part*0x11F (part+0x0E); the
; hardware side is done by EnvTranspose_UpdateLoop (0x032E1E) from Voice_CC_Pan.
Voice_CC_SetPan:	.include "includes/generated/cc900/Voice_CC_SetPan.s"	; C: cc900/voice_envelopes_and_channels.c

; Voice_CC_SetExpression -- CC 0x0B: Store expression via lookup table
; Uses same lookup table as Volume (0x011D16). Mute value: 0xFE00.
; WA = part, BC = CC 11 value.  Structurally identical to Voice_CC_SetVolume (same 0x041343
; bit 0 / bit 1 selection, same 0x011D16 table) but the destination is the word at
; 0x041378 + part*0x11F (part+0x10).  Mute path writes 0xFE00.
Voice_CC_SetExpression:	.include "includes/generated/cc900/Voice_CC_SetExpression.s"	; C: cc900/voice_envelopes_and_channels_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	VoiceCC_SetExpression_Bit1Set, Voice_CC_SetExpression + 49
	.set	VoiceCC_SetExpression_RawSub, Voice_CC_SetExpression + 94
	.set	VoiceCC_SetExpression_Mute, Voice_CC_SetExpression + 121

; Voice_CC_SetSustain -- CC 0x40: Set/clear sustain bit 0 at voice+0x0A
; WA = part, BC = CC 64 value.  Sets (BC != 0) or clears bit 0 of the part flags word 2 at
; 0x041372 + part*0x11F (part+0x0A).
Voice_CC_SetSustain:	.include "includes/generated/cc900/Voice_CC_SetSustain.s"	; C: cc900/voice_envelopes_and_channels.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	VoiceCC_SetSustain_ClearBit, Voice_CC_SetSustain + 23

; WA = part, C = the part's reverb send level.  Stores the byte at 0x041377 + part*0x11F (part+0x0F).
Voice_CC_SetReverbSend:	.include "includes/generated/cc900/Voice_CC_SetReverbSend.s"	; C: cc900/voice_envelopes_and_channels.c

; WA = part, C = the part's DSP-effect send level.  Stores the byte at 0x04137A + part*0x11F (part+0x12).
Voice_CC_SetDspEffectSend:	.include "includes/generated/cc900/Voice_CC_SetDspEffectSend.s"	; C: cc900/voice_envelopes_and_channels.c

; WA = part, BC = value.  Sets/clears bit 6 (0x0040) of part flags word 2 (part+0x0A).
Voice_CC_SetSostenutoFlag:	.include "includes/generated/cc900/Voice_CC_SetSostenutoFlag.s"	; C: cc900/voice_envelopes_and_channels.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	VoiceCC_SetSostenuto_ClearFlag, Voice_CC_SetSostenutoFlag + 23

; WA = part, C = the part's BEND RANGE (main-CPU Lsw 0x080, 0..12; was read as a portamento rate).  Stores the
; byte at 0x04137B + part*0x11F (part+0x13).  This is the byte AudioMod_Apply_Porta_Curve falls back to.
Voice_CC_SetBendRange:	.include "includes/generated/cc900/Voice_CC_SetBendRange.s"	; C: cc900/voice_envelopes_and_channels.c

; WA = part, C = the part's TUNING (main-CPU Lsw 0x081, 0..255 centred on 0x80).  Stores the word
; ((C - 0x80) * 2) at 0x04137C + part*0x11F (part+0x14); Voice_CC_Tuning then refreshes the sounding pitches.
Voice_CC_SetTuning:	.include "includes/generated/cc900/Voice_CC_SetTuning.s"	; C: cc900/voice_envelopes_and_channels.c

; WA = part, C = the part's KEY SHIFT (main-CPU Lsw 0x082, 52..76 = 64 +- 12 semitones).  Stores (C - 0x40) at
; 0x04137E + part*0x11F (part+0x16).
Voice_CC_SetKeyShift:	.include "includes/generated/cc900/Voice_CC_SetKeyShift.s"	; C: cc900/voice_envelopes_and_channels.c

; Ordinary code, not data: if C != 0 stores +2 into the word at
; 0x041372 + part*0x11F, otherwise stores -3 (0xFFFD).  Two-valued, so "range" is a guess --
; what it really does is force a small signed constant into part flags word 2.
Voice_CC_SetModWheelRange:	.include "includes/generated/cc900/Voice_CC_SetModWheelRange.s"	; C: cc900/voice_envelopes_and_channels.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_CC_SetModWheelRange_Else, Voice_CC_SetModWheelRange + 23

; WA = part, C = CC 0x91 value.  Stores the byte at 0x04137F + part*0x11F (part+0x17): the part's own
; velocity-switch configuration, the per-part twin of the global byte 0x04134B (Voice_SetVelSwitchConfig,
; F0 50 91).  Its only readers are the Voice_Env_ApplyVelocity_Type0/_Type2 dispatchers (sub-cases 2 and 3):
; bit 3 (type 0/1) or bit 4 (type 2) set = do nothing, else bit 0 (case 2) or bit 0 with bit 1 clear
; (case 3) installs the patch's +0x2A octave-shift nibble.  Main-CPU sender: SwbtB2_Code9A_Listener (parts
; 0..2).  Was called "reverb depth" (no reader supports that), renamed 2026-10-31.
Voice_CC_SetVelSwitchConfig:	.include "includes/generated/cc900/Voice_CC_SetVelSwitchConfig.s"	; C: cc900/voice_envelopes_and_channels.c

; Voice_CC_SetGlidePedal -- CC 0x95 (GLIDE PEDAL, called chorus enable until 2026-10-17): set/clear bit 2 at voice+0x0A
; WA = part, BC = CC 0x95 value.  Sets/clears bit 2 (0x0004) of part flags word 2.
Voice_CC_SetGlidePedal:	.include "includes/generated/cc900/Voice_CC_SetGlidePedal.s"	; C: cc900/voice_envelopes_and_channels.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	VoiceCC_SetGlidePedal_ClearBit, Voice_CC_SetGlidePedal + 23

; Voice_CC_SetSustainLength -- CC 0x97 (SUSTAIN LENGTH, called chorus depth until 2026-10-17): store at voice+0x18
; WA = part, C = CC 0x97 value.  Stores the byte at 0x041380 + part*0x11F (part+0x18).
Voice_CC_SetSustainLength:	.include "includes/generated/cc900/Voice_CC_SetSustainLength.s"	; C: cc900/voice_envelopes_and_channels.c

; WA = part, C = CC 0x9B value.  Stores the byte at 0x04138D + part*0x11F (part+0x25).  Its only reader is
; Voice_Apply_GateRouting, which patches the gate/control word of every voice of the part: low nibble 0 = force
; bits [11:9] to 7, 1 = leave them, 2 = force them to 1; high nibble 0x00 / 0x10 / 0x20 does the same to
; [14:12].  Reset value 1.  No main-CPU sender was found in v10 (the CC numbers above 0x7F cannot arrive
; from MIDI IN).  Was called "delay depth", renamed 2026-10-31.
Voice_CC_SetGateRoutingMode:	.include "includes/generated/cc900/Voice_CC_SetGateRoutingMode.s"	; C: cc900/voice_envelopes_and_channels.c

; Voice_CC_SetKeyScaling -- CC 0x9C (KEY SCALING, called delay enable until 2026-10-17): set/clear bit 8 at voice+0x02
; WA = part, BC = CC 0x9C value.  Sets/clears bit 0 of the part flags word at
; 0x04136A + part*0x11F (part+0x02).
Voice_CC_SetKeyScaling:	.include "includes/generated/cc900/Voice_CC_SetKeyScaling.s"	; C: cc900/voice_envelopes_and_channels.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	VoiceCC_SetKeyScaling_ClearBit, Voice_CC_SetKeyScaling + 23

; WA = part, C = CC 0x9D value.  Stores the byte at 0x04138E + part*0x11F (part+0x26).  Its readers
; (Voice_Level_ClearAllOutputRegs, Voice1_UpdatePitch_WriteStereoField, Voice_Step_ExprRamp) choose the low 7
; bits of the voice's TG register 0x180 (pan on technics-docs/tone-generator.md, 0x40 = centre): 1 = 0x00,
; 2 = 0x7F, anything else = the voice's own value.  Reset value 0.  No main-CPU sender was found in v10.
; Was called "delay feedback", renamed 2026-10-31.
Voice_CC_SetTgPanMode:	.include "includes/generated/cc900/Voice_CC_SetTgPanMode.s"	; C: cc900/voice_envelopes_and_channels.c

; A = mode.  A == 1 sets bit 0 of the global flag word 0x041343 and calls
; Voice_Reset_Engine (0x021ECB) with WA = 1; anything else clears bit 0 and calls it
; with WA = 0.  Then VoiceSlot_ClearAll (0x034B4B) and
; Voice_PerVoice_PortamentoPitchUpdate for parts 0..0x0F.
; ★ This is the one routine in the region that both writes a global mode bit AND drops the
; entire voice-slot allocation on the floor; see [UNCERTAIN]/findings.
Voice_SetPolyphonyMode:	.include "includes/generated/cc900/Voice_SetPolyphonyMode.s"	; C: cc900/voice_envelopes_and_channels_b_7j_qizinc.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_SetPolyphonyMode_Else, Voice_SetPolyphonyMode + 22
	.set	Voice_SetPolyphonyMode_Apply, Voice_SetPolyphonyMode + 35
	.set	Voice_SetPolyphonyMode_LoopBody, Voice_SetPolyphonyMode + 48
	.set	Voice_SetPolyphonyMode_LoopExit, Voice_SetPolyphonyMode + 65

; A bare `ret`.  Reached from SysEx dispatch-table entry 1 and from
; Voice_ResetAllControllers_PostLoop with WA = 0x7F.  Deliberate no-op, not padding.
VoiceCC_Stub_Ret1:	.include "includes/generated/cc900/VoiceCC_Stub_Ret1.s"	; C: cc900/voice_envelopes_and_channels.c

; Second bare `ret`, dispatch entry 2, likewise called with WA = 0x7F.
VoiceCC_Stub_Ret2:	.include "includes/generated/cc900/VoiceCC_Stub_Ret2.s"	; C: cc900/voice_envelopes_and_channels.c

; A = raw value.  Stores sign-extended ((A - 0x40) * 2) as a word at 0x041347.
Voice_SetMasterTune:	.include "includes/generated/cc900/Voice_SetMasterTune.s"	; C: cc900/voice_envelopes_and_channels.c

; A = semitones.  Stores (sign-extended A) << 8 at 0x041349.
Voice_SetPitchBendRange:	.include "includes/generated/cc900/Voice_SetPitchBendRange.s"	; C: cc900/voice_envelopes_and_channels.c

; A = 0 falls through into Voice_SetKeyShiftRange (disable).  Otherwise, if bit 12 of the
; global flag word 0x041343 is already set it returns; else it sets bit 11 (0x0800) and
; zeroes the word at 0x04135C.
Voice_SetKeyShiftEnable:	.include "includes/generated/cc900/Voice_SetKeyShiftEnable.s"	; C: cc900/voice_envelopes_and_channels.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_SetKeyShiftRange, Voice_SetKeyShiftEnable + 29
	.set	Voice_SetKeyShiftRange_BranchA, Voice_SetKeyShiftEnable + 69
	.set	Voice_SetKeyShiftRange_BranchB, Voice_SetKeyShiftEnable + 72

; A -> byte 0x04134D.  Reached from SysEx dispatch entry 6 and from
; Voice_ResetAllControllers with A = 0.  The reference file calls the getter
; ScaleTune_Get_Global_Mode; see [UNCERTAIN].
ScaleTune_Set_Global_Mode:	.include "includes/generated/cc900/ScaleTune_Set_Global_Mode.s"	; C: cc900/voice_envelopes_and_channels.c

ScaleTune_Get_Global_Mode:	.include "includes/generated/cc900/ScaleTune_Get_Global_Mode.s"	; C: cc900/voice_envelopes_and_channels.c

; A = packed rhythm-mode byte from a SysEx message.  Decodes it into the 0x04135E block:
;   bit 3      -> 0x04135E = 3 (else 1)
;                 0x04135F = 1 unconditionally
;   bits 7..4  -> index x2 into the word table at 0x00F6F3, result -> 0x041360
;   bit 2      -> 0x041362 = 0x8000 (else 0xA000)
;   bits 1..0  -> 0x041364 = 0xC8 - ((A & 3) << 3)
; Pure state; no hardware touched here.
Voice_SetRhythmMode:	.include "includes/generated/cc900/Voice_SetRhythmMode.s"	; C: cc900/voice_envelopes_and_channels.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_SetRhythmMode_BranchA, Voice_SetRhythmMode + 13
	.set	Voice_SetRhythmMode_BranchB, Voice_SetRhythmMode + 19
	.set	Voice_SetRhythmMode_BranchC, Voice_SetRhythmMode + 66
	.set	Voice_SetRhythmMode_BranchD, Voice_SetRhythmMode + 73

; A -> byte 0x04134B.  SysEx dispatch entry 0 (sub-command 0x91).
; That byte is read only by the Voice_Env_ApplyVelocity_* velocity-switch dispatchers (bits 0,
; 1, 3 and 4 select their predicates).  Renamed 2026-09-25 from Voice_SetParam_04134B.
Voice_SetVelSwitchConfig:	.include "includes/generated/cc900/Voice_SetVelSwitchConfig.s"	; C: cc900/voice_envelopes_and_channels.c

; A == 0x7F sets bit 1 of the global flag word 0x041343, anything else clears it.
; Bit 1 is one of the two selectors Voice_CC_SetVolume / Voice_CC_SetExpression test.
Voice_SetCCMaxFlag:	.include "includes/generated/cc900/Voice_SetCCMaxFlag.s"	; C: cc900/voice_envelopes_and_channels.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_SetCCMaxFlag_Clear, Voice_SetCCMaxFlag + 13

; WA = index, C = value.  Stores (C - 0x80) at 0x041342 + (index + 0x0C), i.e. into the
; 12-byte array 0x04134E..0x041359.  Voice_ResetAllControllers zeroes exactly indices 0..0x0B,
; and 12 entries is one per pitch class -- which is why the reference file calls the reader
; ScaleTune_Get_User_Offset.  See [UNCERTAIN]: I believe the reference name is the correct
; one and "ChannelAssign" is wrong, but I have not renamed anything.
ScaleTune_Set_User_Offset:	.include "includes/generated/cc900/ScaleTune_Set_User_Offset.s"	; C: cc900/voice_envelopes_and_channels_h_14c.c

ScaleTune_Get_User_Offset:	.include "includes/generated/cc900/ScaleTune_Get_User_Offset.s"	; C: cc900/voice_envelopes_and_channels_h_14c.c

; A = a 4-bit selector, stored to 0x04134C.  Outer loop over parts 0..0x19; a part is skipped
; unless bit 1 of its flags word 2 (0x041372 + part*0x11F) is set.  For each such part it
; walks the voice list from Voice_Query_PartVoices (0x02CD36), reads the owning part from
; voice+0x04 (0x043092 + idx*0x47), follows the patch pointer at part+0x06 (0x04136E) and
; branches on (patch+0x10) & 0xC0:
;   0x80          -> Voice_ComputePitchBend2 (0x025499) + Voice_Build_GateCommand_NoPartial (0x0255F3)
;   0x40 or 0xC0  -> Level_Build_Reg0C0 (0x0253FE) + Voice_Build_GateCommand (0x025589)
;   0x00          -> skip
; and then unconditionally calls ToneGen_ReadPitch_AndScale (0x02E18D) per voice.
; ★ That last call is a tone-generator READ inside a doubly-nested loop -- relevant to the
; sine-mode bug, see findings.
Voice_AllVoices_UpdateVelocity:	.include "includes/generated/cc900/Voice_AllVoices_UpdateVelocity.s"	; C: cc900/voice_envelopes_and_channels_q_17a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_AllVoices_UpdateVelocity_LoopStart, Voice_AllVoices_UpdateVelocity + 22
	.set	Voice_AllVoices_UpdateVelocity_InnerLoop, Voice_AllVoices_UpdateVelocity + 67
	.set	Voice_AllVoices_UpdateVelocity_TypeA, Voice_AllVoices_UpdateVelocity + 129
	.set	Voice_AllVoices_UpdateVelocity_TypeB, Voice_AllVoices_UpdateVelocity + 173
	.set	Voice_AllVoices_UpdateVelocity_NextOuter, Voice_AllVoices_UpdateVelocity + 215
	.set	Voice_AllVoices_UpdateVelocity_InnerStep, Voice_AllVoices_UpdateVelocity + 231
	.set	Voice_AllVoices_UpdateVelocity_Exit, Voice_AllVoices_UpdateVelocity + 241

; A == 0 SETS bit 9 (0x0200) of the global flag word 0x041343; any other value clears it.
; The inverted sense makes the "MonoMode" reading doubtful -- see [UNCERTAIN].
ScaleTune_Set_Global_Enabled:	.include "includes/generated/cc900/ScaleTune_Set_Global_Enabled.s"	; C: cc900/voice_envelopes_and_channels.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ScaleTune_Set_Global_Enabled_Clear, ScaleTune_Set_Global_Enabled + 12

; Returns HL = 0x041343 & 0x0200.  Getter for the bit the routine above writes.
ScaleTune_Is_Global_Enabled:	.include "includes/generated/cc900/ScaleTune_Is_Global_Enabled.s"	; C: cc900/voice_envelopes_and_channels.c

; XWA = the part record whose voice list starts at +5 (as returned by Voice_AllocateFor*).
; Walks the list; for each voice whose (voice+0x01) & 0x3C is 4, 8 or 0x20 it calls
; Pitch_Emit_Reg400 (0x023A4A), and for 0x10 it calls
; Voice_Pitch_WriteOutputReg_Secondary; in both cases it then calls
; ToneGen_WriteVoice_Long -- which writes TG register 0x10, the PITCH register.
; ★ It writes no pan register at all.  The reference file's Pitch_Refresh_Sounding_Voices is
; the accurate name; see [UNCERTAIN].
Pitch_Refresh_Sounding_Voices:	.include "includes/generated/cc900/Pitch_Refresh_Sounding_Voices.s"	; C: cc900/voice_envelopes_and_channels_b_7h.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Pitch_Refresh_Sounding_Voices_LoopBody, Pitch_Refresh_Sounding_Voices + 20
	.set	Pitch_Refresh_Sounding_Voices_BranchA, Pitch_Refresh_Sounding_Voices + 66
	.set	Pitch_Refresh_Sounding_Voices_BranchB, Pitch_Refresh_Sounding_Voices + 86
	.set	Pitch_Refresh_Sounding_Voices_LoopStep, Pitch_Refresh_Sounding_Voices + 104
	.set	Pitch_Refresh_Sounding_Voices_Exit, Pitch_Refresh_Sounding_Voices + 111

; XWA = part record (voice list at +5).  Same walk and same (voice+0x01)&0x3C classification
; as Pitch_Refresh_Sounding_Voices, but the hardware call is ToneGen_WriteVoice_Short, i.e. TG
; register 0x02 -- amplitude.  This is the routine Voice_CC_Volume and Voice_CC_Expression
; call to push a new CC 7 / CC 11 value out to every sounding voice of the part.
Voice_AllVoices_WriteAmplitude:	.include "includes/generated/cc900/Voice_AllVoices_WriteAmplitude.s"	; C: cc900/voice_envelopes_and_channels_b_7h.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_AllVoices_WriteAmplitude_LoopBody, Voice_AllVoices_WriteAmplitude + 20
	.set	Voice_AllVoices_WriteAmplitude_BranchA, Voice_AllVoices_WriteAmplitude + 66
	.set	Voice_AllVoices_WriteAmplitude_BranchB, Voice_AllVoices_WriteAmplitude + 74
	.set	Voice_AllVoices_WriteAmplitude_LoopStep, Voice_AllVoices_WriteAmplitude + 80
	.set	Voice_AllVoices_WriteAmplitude_Exit, Voice_AllVoices_WriteAmplitude + 99

; The heaviest routine in the region.  Walks a part's voice list and, per voice, decides
; between five outcomes based on (voice+0x01)&0x3C, bit 15 and bit 8 of (voice+0x01), and
; bit 0 of [voice+0x23]+0x0A:
;   BranchB/BranchD -- Voice_Calc_LevelPair_EGA, ToneGen_WriteSegRegs_SameLevel,
;                      ToneGen_WriteVoice_Direct with BC = (voice+0x2D),
;                      then Voice_Clear_HoldBit (0x022587) and clear bit 8 of (voice+0x01);
;   BranchC        -- Voice_Calc_LevelPair_EGA/2/3 then ToneGen_WriteVoice_6Words
;                      (six TG registers, the full re-trigger);
;   BranchE        -- only if (voice+0x40) & 0xFF is zero: Voice_WriteVolume_SetFlag then
;                      ToneGen_WriteNote2ch;
;   BranchF        -- Voice_WriteVolume_OrPan then ToneGen_WriteNote2ch.
; ★ BranchB and BranchD call Voice_Clear_HoldBit WITHOUT calling Voice_Reload_Levels, i.e. they give
; back the tone-generator slot but keep the software voice -- the asymmetry matters for any
; voice-leak analysis.
Voice_AllNotes_SustainRetrigger:	.include "includes/generated/cc900/Voice_AllNotes_SustainRetrigger.s"	; C: cc900/voice_envelopes_and_channels_b_11c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_AllNotes_SustainRetrigger_LoopBody, Voice_AllNotes_SustainRetrigger + 26
	.set	Voice_AllNotes_SustainRetrigger_BranchA, Voice_AllNotes_SustainRetrigger + 78
	.set	Voice_AllNotes_SustainRetrigger_BranchB, Voice_AllNotes_SustainRetrigger + 99
	.set	Voice_AllNotes_SustainRetrigger_BranchC, Voice_AllNotes_SustainRetrigger + 161
	.set	Voice_AllNotes_SustainRetrigger_BranchD, Voice_AllNotes_SustainRetrigger + 196
	.set	Voice_AllNotes_SustainRetrigger_BranchE, Voice_AllNotes_SustainRetrigger + 257
	.set	Voice_AllNotes_SustainRetrigger_BranchF, Voice_AllNotes_SustainRetrigger + 289
	.set	Voice_AllNotes_SustainRetrigger_LoopStep, Voice_AllNotes_SustainRetrigger + 316
	.set	Voice_AllNotes_SustainRetrigger_Exit, Voice_AllNotes_SustainRetrigger + 330

; --- 0x028F75-0x029E30  TVF_Refresh_Sounding_Voices -- was MISLABELLED, now fully code
; All 3772 bytes are TLCS-900H instructions (previously `.byte`; converted in an earlier pass,
; before this note was checked -- this is a corrected marker, not a new conversion). It is the
; body of the audio-channel command handlers: the nine entry points below are all reached by
; `calr`/`jrl` from AudioChannel_DispatchTable at 0x029E5B or by absolute `call` from outside
; the region.  Nothing in here is data.
; ⚠ RENAME PROPOSAL, NOT A PLACEHOLDER FILL: this address already carries the real name
; TVF_Refresh_Sounding_Voices.  Left alone; maintainer's call.  See [UNCERTAIN].
; XWA = part record (voice list at +5).  Walks the list, classifies each voice by
; (voice+0x01)&0x3C and calls TVF_Emit_Registers (0x024444) for 4/0x20 or
; TVF_Emit_Registers_Type2 (0x024554) for 0x10, then pushes the result to TG registers
; 0x100/0x140 + voice (the filter pair) via ToneGen_WriteVoice_TvfPair with XBC = the staging record 0x0451CC.
; TVF_Refresh_Sounding_Voices: Re-emits the TVF (filter) registers of every voice in a part's voice list: classes
;   (voice+1) & 0x3C = 4 / 0x20 through TVF_Emit_Registers, 0x10 through TVF_Emit_Registers_Type2 (class 8
;   skipped), then TG 0x100/0x140 via ToneGen_WriteVoice_TvfPair -- the filter counterpart of
;   Pitch_Refresh_Sounding_Voices. Basis: caller + body -- AudioChannel_Handler_Cmd03 calls it after storing the
;   part's cutoff offset part+0x1F, which TVF_Emit_Offset_Reg100 adds to the cutoff field.
;   (scripts/lanes/verify_mislabel_markers.py lists the old name.)
TVF_Refresh_Sounding_Voices:	.include "includes/generated/cc900/TVF_Refresh_Sounding_Voices.s"	; C: cc900/voice_envelopes_and_channels_b_7h.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	VoiceCC_DataTable_028F75_Loop, TVF_Refresh_Sounding_Voices + 20
	.set	VoiceCC_DataTable_028F75_Skip, TVF_Refresh_Sounding_Voices + 66
	.set	VoiceCC_DataTable_028F75_Skip2, TVF_Refresh_Sounding_Voices + 86
	.set	VoiceCC_DataTable_028F75_Join, TVF_Refresh_Sounding_Voices + 104
	.set	VoiceCC_DataTable_028F75_Epilogue, TVF_Refresh_Sounding_Voices + 111
; Same walk as above with two extra gates: bit 7 of (voice+0x05) must be set, and for class
; 0x10 also bit 5 of [voice+0x13]+0x0D.  Calls Voice_WriteChPanShift (0x02591D) or
; Voice_WriteChPanShift2 (0x025B6F) with BC = 1 and then
; ToneGen_WriteVoice_Reg21_Reg22 (registers 0x21/0x22).
AudioChannel_AllVoices_Update_PanShift:	.include "includes/generated/cc900/AudioChannel_AllVoices_Update_PanShift.s"	; C: cc900/voice_envelopes_and_channels_b_7h.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AudioChannel_AllVoices_Update_PanShift_Loop, AudioChannel_AllVoices_Update_PanShift + 20
	.set	AudioChannel_AllVoices_Update_PanShift_Skip, AudioChannel_AllVoices_Update_PanShift + 66
	.set	AudioChannel_AllVoices_Update_PanShift_Skip2, AudioChannel_AllVoices_Update_PanShift + 93
	.set	AudioChannel_AllVoices_Update_PanShift_Skip3, AudioChannel_AllVoices_Update_PanShift + 106
	.set	AudioChannel_AllVoices_Update_PanShift_Join, AudioChannel_AllVoices_Update_PanShift + 126
	.set	AudioChannel_AllVoices_Update_PanShift_Epilogue, AudioChannel_AllVoices_Update_PanShift + 133
; Third member of the same family; the ONLY interior address in either code blob that is
; reached by an absolute `call` (from 0x0304C1).  Uses `lda XIZ,XWA+BC` to form the voice
; pointer rather than the store-to-XIZ idiom of its siblings, and branches on the same
; (voice+0x01)&0x3C classes in a different order (0x10 first).
AudioChannel_AllVoices_Update_Variant3:	.include "includes/generated/cc900/AudioChannel_AllVoices_Update_Variant3.s"	; C: cc900/voice_envelopes_and_channels_ad_21a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AudioChannel_AllVoices_Update_Variant3_Loop, AudioChannel_AllVoices_Update_Variant3 + 21
	.set	AudioChannel_AllVoices_Update_Variant3_Skip, AudioChannel_AllVoices_Update_Variant3 + 69
	.set	AudioChannel_AllVoices_Update_Variant3_Join, AudioChannel_AllVoices_Update_Variant3 + 101
	.set	AudioChannel_AllVoices_Update_Variant3_Epilogue, AudioChannel_AllVoices_Update_Variant3 + 114
; Handler for audio-channel command 1.  Reached by `jrl` from dispatch stub 0 (0x029E5B).
; Entry WA = value, BC = value2, XDE = the 3-byte routing descriptor.  Calls
; AudioMod_Apply_BusRouting / AudioMod_Apply_Porta_Curve in the 0x0280FE block.
AudioChannel_Handler_Cmd01:	.include "includes/generated/cc900/AudioChannel_Handler_Cmd01.s"	; C: cc900/voice_envelopes_and_channels_q_17a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AudioChannel_Handler_Cmd01_Skip, AudioChannel_Handler_Cmd01 + 22
	.set	AudioChannel_Handler_Cmd01_Join, AudioChannel_Handler_Cmd01 + 25
; Handler for audio-channel command 3.  Reached by `jrl` from dispatch stub 2 (0x029E65).
AudioChannel_Handler_Cmd03:	.include "includes/generated/cc900/AudioChannel_Handler_Cmd03.s"	; C: cc900/voice_envelopes_and_channels_q_17a.c
; Handler for audio-channel command 2.  Reached by `jrl` from dispatch stub 1 (0x029E60).
; Note the table order is 1, 2, 3 but the code order is CMD01, CMD03, CMD02.
AudioChannel_Handler_Cmd02:	.include "includes/generated/cc900/AudioChannel_Handler_Cmd02.s"	; C: cc900/voice_envelopes_and_channels_q_17a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AudioChannel_Handler_Cmd02_Skip, AudioChannel_Handler_Cmd02 + 102
	.set	AudioChannel_Handler_Cmd02_Join, AudioChannel_Handler_Cmd02 + 114
; Shared body for audio-channel commands 4..7.  The four dispatch stubs at 0x029E6A,
; 0x029E75, 0x029E80 and 0x029E8B differ only in the sub-index 0..3 they `push` before the
; `calr`, so the pushed word is the handler's bus/slot selector.
; Entry: WA = value (zero-extended), BC = value2 (zero-extended), XDE = routing descriptor,
; (SP+n) = sub-index.
AudioChannel_Handler_Cmd04_07:	.include "includes/generated/cc900/AudioChannel_Handler_Cmd04_07.s"	; C: cc900/voice_envelopes_and_channels_ad_20a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AudioChannel_Handler_Cmd04_07_Loop, AudioChannel_Handler_Cmd04_07 + 112
	.set	AudioChannel_Handler_Cmd04_07_Skip, AudioChannel_Handler_Cmd04_07 + 140
	.set	AudioChannel_Handler_Cmd04_07_Loop2, AudioChannel_Handler_Cmd04_07 + 189
	.set	AudioChannel_Handler_Cmd04_07_Skip2, AudioChannel_Handler_Cmd04_07 + 233
	.set	AudioChannel_Handler_Cmd04_07_Loop3, AudioChannel_Handler_Cmd04_07 + 291
	.set	AudioChannel_Handler_Cmd04_07_Skip3, AudioChannel_Handler_Cmd04_07 + 319
	.set	AudioChannel_Handler_Cmd04_07_Loop4, AudioChannel_Handler_Cmd04_07 + 355
	.set	AudioChannel_Handler_Cmd04_07_Skip4, AudioChannel_Handler_Cmd04_07 + 454
	.set	AudioChannel_Handler_Cmd04_07_Join, AudioChannel_Handler_Cmd04_07 + 468
	.set	AudioChannel_Handler_Cmd04_07_Join2, AudioChannel_Handler_Cmd04_07 + 484
	.set	AudioChannel_Handler_Cmd04_07_Epilogue, AudioChannel_Handler_Cmd04_07 + 507
; Shared body for commands 0x10..0x13; stubs at 0x029EF5/0x029F00/0x029F0B/0x029F16.
AudioChannel_Handler_Cmd10_13:	.include "includes/generated/cc900/AudioChannel_Handler_Cmd10_13.s"	; C: cc900/voice_envelopes_and_channels_ad_20a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AudioChannel_Handler_Cmd10_13_Loop, AudioChannel_Handler_Cmd10_13 + 112
	.set	AudioChannel_Handler_Cmd10_13_Skip, AudioChannel_Handler_Cmd10_13 + 140
	.set	AudioChannel_Handler_Cmd10_13_Loop2, AudioChannel_Handler_Cmd10_13 + 189
	.set	AudioChannel_Handler_Cmd10_13_Skip2, AudioChannel_Handler_Cmd10_13 + 233
	.set	AudioChannel_Handler_Cmd10_13_Loop3, AudioChannel_Handler_Cmd10_13 + 291
	.set	AudioChannel_Handler_Cmd10_13_Skip3, AudioChannel_Handler_Cmd10_13 + 319
	.set	AudioChannel_Handler_Cmd10_13_Loop4, AudioChannel_Handler_Cmd10_13 + 355
	.set	AudioChannel_Handler_Cmd10_13_Skip4, AudioChannel_Handler_Cmd10_13 + 467
	.set	AudioChannel_Handler_Cmd10_13_Join, AudioChannel_Handler_Cmd10_13 + 494
	.set	AudioChannel_Handler_Cmd10_13_Join2, AudioChannel_Handler_Cmd10_13 + 497
	.set	AudioChannel_Handler_Cmd10_13_Epilogue, AudioChannel_Handler_Cmd10_13 + 520
; Shared body for commands 8..0x0B; stubs at 0x029E96/0x029EA1/0x029EAC/0x029EB7.
AudioChannel_Handler_Cmd08_0B:	.include "includes/generated/cc900/AudioChannel_Handler_Cmd08_0B.s"	; C: cc900/voice_envelopes_and_channels_ad_20a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AudioChannel_Handler_Cmd08_0B_Loop, AudioChannel_Handler_Cmd08_0B + 112
	.set	AudioChannel_Handler_Cmd08_0B_Skip, AudioChannel_Handler_Cmd08_0B + 140
	.set	AudioChannel_Handler_Cmd08_0B_Loop2, AudioChannel_Handler_Cmd08_0B + 189
	.set	AudioChannel_Handler_Cmd08_0B_Skip2, AudioChannel_Handler_Cmd08_0B + 233
	.set	AudioChannel_Handler_Cmd08_0B_Loop3, AudioChannel_Handler_Cmd08_0B + 291
	.set	AudioChannel_Handler_Cmd08_0B_Skip3, AudioChannel_Handler_Cmd08_0B + 319
	.set	AudioChannel_Handler_Cmd08_0B_Loop4, AudioChannel_Handler_Cmd08_0B + 358
	.set	AudioChannel_Handler_Cmd08_0B_Skip4, AudioChannel_Handler_Cmd08_0B + 457
	.set	AudioChannel_Handler_Cmd08_0B_Join, AudioChannel_Handler_Cmd08_0B + 471
	.set	AudioChannel_Handler_Cmd08_0B_Join2, AudioChannel_Handler_Cmd08_0B + 487
	.set	AudioChannel_Handler_Cmd08_0B_Epilogue, AudioChannel_Handler_Cmd08_0B + 510
; Shared body for commands 0x14..0x17; stubs at 0x029F21/0x029F2C/0x029F37/0x029F42.
AudioChannel_Handler_Cmd14_17:	.include "includes/generated/cc900/AudioChannel_Handler_Cmd14_17.s"	; C: cc900/voice_envelopes_and_channels_ad_20a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AudioChannel_Handler_Cmd14_17_Loop, AudioChannel_Handler_Cmd14_17 + 112
	.set	AudioChannel_Handler_Cmd14_17_Skip, AudioChannel_Handler_Cmd14_17 + 140
	.set	AudioChannel_Handler_Cmd14_17_Loop2, AudioChannel_Handler_Cmd14_17 + 189
	.set	AudioChannel_Handler_Cmd14_17_Skip2, AudioChannel_Handler_Cmd14_17 + 233
	.set	AudioChannel_Handler_Cmd14_17_Loop3, AudioChannel_Handler_Cmd14_17 + 291
	.set	AudioChannel_Handler_Cmd14_17_Skip3, AudioChannel_Handler_Cmd14_17 + 319
	.set	AudioChannel_Handler_Cmd14_17_Loop4, AudioChannel_Handler_Cmd14_17 + 358
	.set	AudioChannel_Handler_Cmd14_17_Skip4, AudioChannel_Handler_Cmd14_17 + 470
	.set	AudioChannel_Handler_Cmd14_17_Join, AudioChannel_Handler_Cmd14_17 + 497
	.set	AudioChannel_Handler_Cmd14_17_Join2, AudioChannel_Handler_Cmd14_17 + 500
	.set	AudioChannel_Handler_Cmd14_17_Epilogue, AudioChannel_Handler_Cmd14_17 + 523
; Shared body for commands 0x0C..0x0F; stubs at 0x029EC9/0x029ED4/0x029EDF/0x029EEA.
AudioChannel_Handler_Cmd0C_0F:	.include "includes/generated/cc900/AudioChannel_Handler_Cmd0C_0F.s"	; C: cc900/voice_envelopes_and_channels_ad_20a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AudioChannel_Handler_Cmd0C_0F_Loop, AudioChannel_Handler_Cmd0C_0F + 112
	.set	AudioChannel_Handler_Cmd0C_0F_Skip, AudioChannel_Handler_Cmd0C_0F + 140
	.set	AudioChannel_Handler_Cmd0C_0F_Loop2, AudioChannel_Handler_Cmd0C_0F + 189
	.set	AudioChannel_Handler_Cmd0C_0F_Skip2, AudioChannel_Handler_Cmd0C_0F + 233
	.set	AudioChannel_Handler_Cmd0C_0F_Loop3, AudioChannel_Handler_Cmd0C_0F + 291
	.set	AudioChannel_Handler_Cmd0C_0F_Skip3, AudioChannel_Handler_Cmd0C_0F + 319
	.set	AudioChannel_Handler_Cmd0C_0F_Loop4, AudioChannel_Handler_Cmd0C_0F + 358
	.set	AudioChannel_Handler_Cmd0C_0F_Skip4, AudioChannel_Handler_Cmd0C_0F + 464
	.set	AudioChannel_Handler_Cmd0C_0F_Join, AudioChannel_Handler_Cmd0C_0F + 473
	.set	AudioChannel_Handler_Cmd0C_0F_Join2, AudioChannel_Handler_Cmd0C_0F + 489
	.set	AudioChannel_Handler_Cmd0C_0F_Epilogue, AudioChannel_Handler_Cmd0C_0F + 512
; Shared body for commands 0x18..0x1B; stubs at 0x029F4D/0x029F58/0x029F63/0x029F6E.
; Command 0x1B is the last index the bound check in AudioChannel_Dispatch admits.
AudioChannel_Handler_Cmd18_1B:	.include "includes/generated/cc900/AudioChannel_Handler_Cmd18_1B.s"	; C: cc900/voice_envelopes_and_channels_ad_20a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AudioChannel_Handler_Cmd18_1B_Loop, AudioChannel_Handler_Cmd18_1B + 112
	.set	AudioChannel_Handler_Cmd18_1B_Skip, AudioChannel_Handler_Cmd18_1B + 140
	.set	AudioChannel_Handler_Cmd18_1B_Loop2, AudioChannel_Handler_Cmd18_1B + 189
	.set	AudioChannel_Handler_Cmd18_1B_Skip2, AudioChannel_Handler_Cmd18_1B + 233
	.set	AudioChannel_Handler_Cmd18_1B_Loop3, AudioChannel_Handler_Cmd18_1B + 291
	.set	AudioChannel_Handler_Cmd18_1B_Skip3, AudioChannel_Handler_Cmd18_1B + 319
	.set	AudioChannel_Handler_Cmd18_1B_Loop4, AudioChannel_Handler_Cmd18_1B + 358
	.set	AudioChannel_Handler_Cmd18_1B_Skip4, AudioChannel_Handler_Cmd18_1B + 477
	.set	AudioChannel_Handler_Cmd18_1B_Join, AudioChannel_Handler_Cmd18_1B + 499
	.set	AudioChannel_Handler_Cmd18_1B_Join2, AudioChannel_Handler_Cmd18_1B + 502
	.set	AudioChannel_Handler_Cmd18_1B_Epilogue, AudioChannel_Handler_Cmd18_1B + 525

; The modulation-routing dispatcher.  Entry XDE = a 3-byte routing descriptor; WA and BC
; carry the value pair.  Reads L = (XDE+1) & 0x3F, that is the DESTINATION COMMAND ID, and
; rejects it unless 1 <= id <= 0x1B.  index = id - 1, doubled, used to read a word from the
; offset table at 0x00F703; that offset is added to the stub-table base 0x029E5B and jumped
; to.  Bit 7 of (XDE+1) is NOT part of the id -- it is the bipolar flag the handlers test.
; Callers: Voice_ModWheel_Apply (twice), Voice_ChanPressure (twice), Voice_PitchBend
; (twice, as a tail `jrl`), and the 0x02A061 block.
AudioChannel_Dispatch:	.include "includes/generated/cc900/AudioChannel_Dispatch.s"	; C: cc900/voice_envelopes_and_channels_d_13a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AudioChannel_DispatchTable, AudioChannel_Dispatch + 42
	.set	AudioChannel_Stub_Cmd02, AudioChannel_Dispatch + 47
	.set	AudioChannel_Stub_Cmd03, AudioChannel_Dispatch + 52
	.set	AudioChannel_Stub_Cmd04, AudioChannel_Dispatch + 57
	.set	AudioChannel_Stub_Cmd05, AudioChannel_Dispatch + 68
	.set	AudioChannel_Stub_Cmd06, AudioChannel_Dispatch + 79
	.set	AudioChannel_Stub_Cmd07, AudioChannel_Dispatch + 90
	.set	AudioChannel_Stub_Cmd08, AudioChannel_Dispatch + 101
	.set	AudioChannel_Stub_Cmd09, AudioChannel_Dispatch + 112
	.set	AudioChannel_Stub_Cmd0A, AudioChannel_Dispatch + 123
	.set	AudioChannel_Stub_Cmd0B, AudioChannel_Dispatch + 134
	.set	AudioChannel_Stub_Cmd0C, AudioChannel_Dispatch + 145
	.set	AudioChannel_Stub_Cmd0D, AudioChannel_Dispatch + 156
	.set	AudioChannel_Stub_Cmd0E, AudioChannel_Dispatch + 167
	.set	AudioChannel_Stub_Cmd0F, AudioChannel_Dispatch + 178
	.set	AudioChannel_Stub_Cmd10, AudioChannel_Dispatch + 189
	.set	AudioChannel_Stub_Cmd11, AudioChannel_Dispatch + 200
	.set	AudioChannel_Stub_Cmd12, AudioChannel_Dispatch + 211
	.set	AudioChannel_Stub_Cmd13, AudioChannel_Dispatch + 222
	.set	AudioChannel_Stub_Cmd14, AudioChannel_Dispatch + 233
	.set	AudioChannel_Stub_Cmd15, AudioChannel_Dispatch + 244
	.set	AudioChannel_Stub_Cmd16, AudioChannel_Dispatch + 255
	.set	AudioChannel_Stub_Cmd17, AudioChannel_Dispatch + 266
	.set	AudioChannel_Stub_Cmd18, AudioChannel_Dispatch + 277
	.set	AudioChannel_Stub_Cmd19, AudioChannel_Dispatch + 288
	.set	AudioChannel_Stub_Cmd1A, AudioChannel_Dispatch + 299
	.set	AudioChannel_Stub_Cmd1B, AudioChannel_Dispatch + 310

; Entry WA = part index, BC = CC 1 value.  Follows the patch pointer at part+0x06
; (0x04136E + part*0x11F) and switches on (patch+0x10) & 0xC0:
;   0x80              -> stereo path: descriptors at patch+0x15 + 3*i, i = 0..1
;   0x40 / 0xC0       -> poly path:   descriptors at patch+0x17 + 3*i, i = 0..1
;   0x00              -> return
; Each iteration calls AudioChannel_Dispatch with XDE pointing at the 3-byte descriptor.
; So a patch declares, per modulation source, up to two destination commands with depths.
Voice_ModWheel_Apply:	.include "includes/generated/cc900/Voice_ModWheel_Apply.s"	; C: cc900/voice_envelopes_and_channels_ag_20a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_ModWheel_Apply_StereoPath, Voice_ModWheel_Apply + 55
	.set	Voice_ModWheel_Apply_PolyPath, Voice_ModWheel_Apply + 68
	.set	Voice_ModWheel_Apply_StereoLoopA, Voice_ModWheel_Apply + 145
	.set	Voice_ModWheel_Apply_StereoLoopB, Voice_ModWheel_Apply + 179
	.set	Voice_ModWheel_Apply_Exit, Voice_ModWheel_Apply + 233

; --- 0x02A061-0x02A0E8  VoiceModWheel_DataTable_02A061 -- was MISLABELLED, now fully code
; All 136 bytes are TLCS-900H instructions (round-trip verified byte-identical to
; kn5000_subprogram_v142.rom, converted 2026-09-02).  llvm-mc's own disassembler cannot decode
; this span cleanly (the `ld r, (xrr+rr)`/`lda_rr`/`*_erp` register-indexed forms it can ENCODE but
; not auto-DECODE), so MAME unidasm supplied the framing and the mnemonics were hand-matched to
; the encoder, then proved by re-assembling to the exact original bytes.
; ★ No caller found: an exhaustive scan of the whole 0x30000-byte ROM for CALL (0x1D),
; CALR (0x1E) and JRL (0x78) encodings targeting 0x02A061 returns nothing.  It is either
; dead code or reached through a pointer I have not located.
; ⚠ RENAME PROPOSAL, NOT A PLACEHOLDER FILL: this address already carries the real name
; VoiceModWheel_DataTable_02A061.  Left alone; maintainer's call.  See [UNCERTAIN].
; A = part index, C = value.  Follows the patch pointer at part+0x06, requires
; (patch+0x10) & 0xC0 to be 0x40, 0xC0 or 0x00, and then for i = 0..1 calls
; AudioChannel_Dispatch with XDE = patch + 0x1D + 3*i.  Identical in shape to the two loops
; inside Voice_ModWheel_Apply but with descriptor base 0x1D instead of 0x15 / 0x17 -- i.e.
; this is the applier for a THIRD modulation source.  See the no-caller warning above.
VoiceModWheel_DataTable_02A061:	.include "includes/generated/cc900/VoiceModWheel_DataTable_02A061.s"	; C: cc900/voice_envelopes_and_channels_ag_21a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	VoiceModWheel_DataTable_02A061_Check, VoiceModWheel_DataTable_02A061 + 50
	.set	VoiceModWheel_DataTable_02A061_Loop, VoiceModWheel_DataTable_02A061 + 58
	.set	VoiceModWheel_DataTable_02A061_Exit, VoiceModWheel_DataTable_02A061 + 130

; A = part index, C = CC 0x5E value.  Reads the patch pointer at part+0x06 and takes a
; different path when (patch+0x10) & 0xC0 == 0xC0.  Updates the part's portamento state and
; then hands over to Voice_PortamentoSlots_WriteHW.
Voice_Portamento_OnHandler:	.include "includes/generated/cc900/Voice_Portamento_OnHandler.s"	; C: cc900/voice_envelopes_and_channels_b_7j.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Portamento_OnHandler_C0Mode, Voice_Portamento_OnHandler + 51
	.set	Voice_Portamento_OnHandler_Exit, Voice_Portamento_OnHandler + 163

; Walks a voice list (cursor on the stack, terminated by a byte >= 0x40) and for every voice
; writes two LITERAL constants into the tone generator:
;   register 0x21 (latch voice+0x0840) <- 0xA200
;   register 0x20 (latch voice+0x0800) <- 0xA280
; via the standard P6.7 strobe.  A branch at 0x02A22F selects a second, identical constant
; pair for the other case.  These are the only hard-coded TG data values in the region.
; Called once per part from Voice_ResetAllControllers.
Voice_PortamentoSlots_WriteHW:
	dec 6, xsp
	ld (xsp + 4), a
	ld a, (xsp + 4)
	extz wa
	call Voice_AllocateForRelease
	ld a, (xsp + 4)
	extz wa
	call Voice_SetLFO_ActiveFlag
	ld a, (xsp + 4)
	extz wa
	call Voice_Query_PartVoices
	lda xwa, (xhl + 5)
	ld (xsp), xwa
	cp (xwa), 0x40
	jrl nc, Voice_PortamentoSlots_WriteHW_Exit

; loop body of Voice_PortamentoSlots_WriteHW.
Voice_PortamentoSlots_WriteHW_LoopBody:
	ld xwa, (xsp)
	ld a, (xwa)
	extz wa
	muls wa, 0x47
	lda xbc, (Payload_Bss_Start+0x4219:24)
	ld	wa, (xbc+wa)
	and wa, 0x3C
	cp wa, 0x8
	jr z, Voice_PortamentoSlots_WriteHW_BranchSkip
	cp wa, 0x20
	jr z, Voice_PortamentoSlots_WriteHW_NopCont1
	cp wa, 0x10
	jr z, Voice_PortamentoSlots_WriteHW_NopCont1
	cp wa, 4:i3
	jrl nz, Voice_PortamentoSlots_WriteHW_LoopStep

; NopCont1: settling gap plus the next address/data pair of Voice_PortamentoSlots_WriteHW.
Voice_PortamentoSlots_WriteHW_NopCont1:
	res	7, (P6:8)
	ld xwa, (xsp)
	ld a, (xwa)
	extz wa
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xa200
	jr Voice_PortamentoSlots_WriteHW_NopCont2

; NopCont2: settling gap plus the next address/data pair of Voice_PortamentoSlots_WriteHW.
Voice_PortamentoSlots_WriteHW_NopCont2:
	nop
	nop
	nop
	res	7, (P6:8)
	ld xwa, (xsp)
	ld a, (xwa)
	extz wa
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xa280
	jr Voice_PortamentoSlots_WriteHW_NopCont3

; NopCont3: settling gap plus the next address/data pair of Voice_PortamentoSlots_WriteHW.
Voice_PortamentoSlots_WriteHW_NopCont3:
	nop
	nop
	nop
	jr Voice_PortamentoSlots_WriteHW_LoopStep

; BranchSkip of Voice_PortamentoSlots_WriteHW.
Voice_PortamentoSlots_WriteHW_BranchSkip:
	res	7, (P6:8)
	ld xwa, (xsp)
	ld a, (xwa)
	extz wa
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xa200
	jr Voice_PortamentoSlots_WriteHW_NopCont4

; NopCont4: settling gap plus the next address/data pair of Voice_PortamentoSlots_WriteHW.
Voice_PortamentoSlots_WriteHW_NopCont4:
	nop
	nop
	nop
	res	7, (P6:8)
	ld xwa, (xsp)
	ld a, (xwa)
	extz wa
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xa280
	jr Voice_PortamentoSlots_WriteHW_NopCont5

; NopCont5: settling gap plus the next address/data pair of Voice_PortamentoSlots_WriteHW.
Voice_PortamentoSlots_WriteHW_NopCont5:
	nop
	nop
	nop

; loop step of Voice_PortamentoSlots_WriteHW.
Voice_PortamentoSlots_WriteHW_LoopStep:
	ld xwa, 1:i3
	add (xsp), xwa
	ld xwa, (xsp)
	cp (xwa), 0x40
	jrl c, Voice_PortamentoSlots_WriteHW_LoopBody

; common exit of Voice_PortamentoSlots_WriteHW.
Voice_PortamentoSlots_WriteHW_Exit:
	inc 6, xsp
	ret

